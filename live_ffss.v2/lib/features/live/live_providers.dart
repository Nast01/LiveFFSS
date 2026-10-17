import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/live.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/features/programme/item_detail_refresh.dart';

part 'live_providers.freezed.dart';

/// L'API ne pousse rien : l'onglet Live se relit à ce rythme.
const Duration liveRefresh = Duration(seconds: 60);

/// L'onglet Live : le programme, les séries qui se courent, les dernières
/// courues, et les places de ces séries.
@freezed
abstract class LiveView with _$LiveView {
  const LiveView._();

  const factory LiveView({
    required List<Meeting> meetings,
    required List<LiveEntry> running,
    required List<LiveEntry> recent,

    /// Par id de place. Une valeur nulle est une place vide ; une clé absente,
    /// une place jamais lue.
    @Default(<int, LaneAssignment?>{}) Map<int, LaneAssignment?> lanes,
  }) = _LiveView;

  /// Les places occupées de [heat], dans l'ordre des couloirs.
  List<LaneAssignment> lanesOf(Heat heat) => [
    for (final id in heat.placeIds)
      if (lanes[id] case final lane? when !lane.isEmpty) lane,
  ]..sort((a, b) => a.lane.compareTo(b.lane));
}

final liveProvider = AsyncNotifierProvider.autoDispose
    .family<LiveNotifier, LiveView, int>(LiveNotifier.new);

class LiveNotifier extends AsyncNotifier<LiveView> {
  LiveNotifier(this.competitionId);

  final int competitionId;

  /// Les courses validées dont toutes les places ont été lues depuis leur
  /// validation : la minuterie ne les relit plus, seul le rafraîchissement
  /// manuel le fait (le juge principal peut encore les corriger).
  final Set<int> _validatedRead = {};

  /// Deux relectures qui se chevauchent écriraient l'une sur l'autre, la plus
  /// lente gagnant avec des données plus vieilles.
  Future<void>? _inFlight;

  @override
  Future<LiveView> build() async {
    _validatedRead.clear();
    final timer = Timer.periodic(liveRefresh, (_) => _tick());
    ref.onDispose(timer.cancel);
    // Lu avant toute attente : si la page se ferme pendant une requête,
    // `ref` ne peut plus servir.
    final runRef = ref;
    final repository = ref.read(meetingRepositoryProvider);

    final programme = await repository.getProgramme(competitionId);
    final selection = liveSelection(programme.meetings);
    final selected = _heats(selection);
    final placeIds = _placeIds(selected);
    // Page fermée pendant la lecture du programme : ses places ne seraient
    // montrées à personne.
    final fetched = placeIds.isEmpty || !runRef.mounted
        ? const <int, LaneAssignment?>{}
        : await repository.getLanes(placeIds);
    _recordReads(selected, {for (final heat in selected) heat.id}, fetched);

    return LiveView(
      meetings: programme.meetings,
      running: selection.running,
      recent: selection.recent,
      lanes: mergeLanes(const {}, fetched, placeIds),
    );
  }

  /// Relit le programme et toutes les places, validées comprises : le juge
  /// principal peut encore corriger une série validée.
  Future<void> refresh() async {
    final runRef = ref;
    // En boucle : un autre `refresh` peut avoir pris la place entre-temps.
    for (var running = _inFlight; running != null; running = _inFlight) {
      await running;
      // Page fermée pendant l'attente : `state` et `ref` ne servent plus.
      if (!runRef.mounted) return;
    }
    await _run(
      state.hasValue ? () => _reload(everything: true) : _reloadFromScratch,
    );
  }

  /// La minuterie tient aussi lieu de nouvel essai après un premier
  /// chargement en échec.
  void _tick() {
    if (_inFlight != null) return;
    if (state.hasValue) {
      _run(() => _reload(everything: false));
    } else if (state.hasError && !state.isLoading) {
      _run(_reloadFromScratch);
    }
  }

  Future<void> _run(Future<void> Function() reload) {
    late final Future<void> run;
    run = reload().whenComplete(() {
      if (identical(_inFlight, run)) _inFlight = null;
    });
    _inFlight = run;
    return run;
  }

  Future<void> _reloadFromScratch() async {
    ref.invalidateSelf();
    try {
      await future;
    } on AppException {
      // L'échec est déjà dans l'état, que la page affiche.
    }
  }

  Future<void> _reload({required bool everything}) async {
    final current = state.value;
    if (current == null) return;
    // Cette lecture peut survivre à la page : seul le `Ref` de son départ dit
    // si son résultat compte encore.
    final runRef = ref;
    final repository = ref.read(meetingRepositoryProvider);
    try {
      final programme = await repository.getProgramme(competitionId);
      if (!runRef.mounted) return;
      final selection = liveSelection(programme.meetings);
      final selected = _heats(selection);
      // Le registre date du tour précédent : une course redevenue temporaire
      // depuis y figure encore.
      final due = {
        for (final heat in selected)
          if (everything ||
              isProvisional(heat) ||
              !_validatedRead.contains(heat.id))
            heat.id,
      };
      final placeIds = _placeIds([
        for (final heat in selected)
          if (due.contains(heat.id)) heat,
      ]);
      final fetched = placeIds.isEmpty
          ? const <int, LaneAssignment?>{}
          : await repository.getLanes(placeIds);
      if (!runRef.mounted) return;
      _recordReads(selected, due, fetched);
      // Les places des séries sorties du Live ne servent plus.
      final kept = {for (final heat in selected) ...heat.placeIds};
      final merged = mergeLanes(current.lanes, fetched, placeIds)
        ..removeWhere((id, _) => !kept.contains(id));
      state = AsyncData(
        current.copyWith(
          meetings: programme.meetings,
          running: selection.running,
          recent: selection.recent,
          lanes: merged,
        ),
      );
    } on AppException catch (error, stackTrace) {
      if (!runRef.mounted) return;
      state = AsyncError(error, stackTrace);
    }
  }

  List<Heat> _heats(({List<LiveEntry> running, List<LiveEntry> recent}) s) => [
    for (final entry in [...s.running, ...s.recent]) entry.heat,
  ];

  /// Une course sans série (finale pas encore générée) n'est pas affichée :
  /// lire ses places ne servirait à rien.
  List<int> _placeIds(Iterable<Heat> heats) => [
    for (final heat in heats)
      if (heat.seriesId != null) ...heat.placeIds,
  ];

  /// Une course qui n'est pas (ou plus) validée, ou sortie du Live, quitte
  /// le registre : redevenue temporaire, elle est relue à chaque tour.
  /// Une course dont une place a échoué n'y entre pas : sinon il lui
  /// manquerait un nageur jusqu'au prochain rafraîchissement manuel.
  void _recordReads(
    List<Heat> selected,
    Set<int> due,
    Map<int, LaneAssignment?> fetched,
  ) {
    final validated = {
      for (final heat in selected)
        if (!isProvisional(heat)) heat.id,
    };
    _validatedRead.removeWhere((id) => !validated.contains(id));
    for (final heat in selected) {
      if (validated.contains(heat.id) &&
          due.contains(heat.id) &&
          heat.placeIds.every(fetched.containsKey)) {
        _validatedRead.add(heat.id);
      }
    }
  }
}
