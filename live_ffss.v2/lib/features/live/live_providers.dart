import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/live.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/common/serial_refresh.dart';
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
  List<LaneAssignment> lanesOf(Heat heat) => lanesOfHeat(heat, lanes);

  /// Faux tant qu'aucune place de [heat] n'est lue : la carte ne doit pas
  /// encore annoncer une série sans résultat.
  bool lanesReadFor(Heat heat) => lanesRead(heat, lanes);
}

final liveProvider = AsyncNotifierProvider.autoDispose
    .family<LiveNotifier, LiveView, int>(LiveNotifier.new);

class LiveNotifier extends AsyncNotifier<LiveView>
    with SerialRefresh<LiveView> {
  LiveNotifier(this.competitionId);

  final int competitionId;

  /// Les séries à relire au prochain tour même hors course : celles qui
  /// étaient en cours à la dernière lecture (une fois terminées, leurs
  /// résultats finaux restent à lire, une dernière fois) et celles dont une
  /// place a échoué (sinon il leur manquerait un nageur jusqu'au
  /// rafraîchissement manuel).
  final Set<int> _readNextTick = {};

  @override
  Future<LiveView> build() async {
    _readNextTick.clear();
    final timer = Timer.periodic(liveRefresh, (_) => tick());
    ref.onDispose(timer.cancel);
    // Lu avant toute attente : si la page se ferme pendant une requête,
    // `ref` ne peut plus servir.
    final runRef = ref;
    // Observé : un changement de serveur relit tout (un même id peut
    // désigner une autre compétition sur l'autre serveur).
    final repository = ref.watch(meetingRepositoryProvider);

    final programme = await repository.getProgramme(competitionId);
    final selection = liveSelection(programme.meetings);
    // Page fermée pendant la lecture du programme : ses places ne seraient
    // montrées à personne.
    if (runRef.mounted) {
      _readNextTick.addAll([
        for (final entry in selection.running) entry.heat.id,
      ]);
      // Une centaine de places à lire : le Live s'affiche sans attendre.
      runInSeries(() => _readFirstLanes(runRef, repository, selection));
    }

    return LiveView(
      meetings: programme.meetings,
      running: selection.running,
      recent: selection.recent,
    );
  }

  /// Les places du premier affichage : d'abord celles des séries en cours,
  /// que le spectateur est venu voir, puis celles des dernières séries.
  Future<void> _readFirstLanes(
    Ref runRef,
    MeetingRepository repository,
    ({List<LiveEntry> running, List<LiveEntry> recent}) selection,
  ) async {
    // La vue n'est installée qu'après le retour de `build` : écrire avant
    // serait écrasé par elle.
    await Future<void>.microtask(() {});
    if (!runRef.mounted) return;
    try {
      await future;
    } on AppException {
      return;
    }
    for (final batch in [selection.running, selection.recent]) {
      // Une construction remplacée (page fermée, ou `invalidateSelf`) ne doit
      // ni lire pour personne ni écrire dans le registre de celle qui l'a
      // remplacée.
      if (!runRef.mounted) return;
      final heats = [for (final entry in batch) entry.heat];
      final placeIds = _placeIds(heats);
      if (placeIds.isEmpty) continue;
      final fetched = await repository.getLanes(placeIds);
      if (!runRef.mounted) return;
      final current = state.value;
      if (current == null) return;
      _readNextTick.addAll(_incomplete(heats, fetched));
      state = AsyncData(
        current.copyWith(lanes: mergeLanes(current.lanes, fetched, placeIds)),
      );
    }
  }

  @override
  void beforeManualRefresh() => retryFailedRoles(ref, competitionId);

  /// Relit le programme et toutes les places, validées comprises : le juge
  /// principal peut encore corriger une série validée.
  @override
  Future<void> reloadAll() => _reload(everything: true);

  /// Le programme, puis les places des seules séries qui peuvent avoir
  /// changé : les autres (dernières courues, validées ou non) attendent le
  /// rafraîchissement manuel, décision du 2026-10-18 qui épargne une centaine
  /// de requêtes par minute.
  @override
  Future<void> reloadIncremental() => _reload(everything: false);

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
      final running = {for (final entry in selection.running) entry.heat.id};
      // Une série sans aucune place lue (nouvelle venue, ou tout en échec)
      // laisserait sa carte en chargement.
      final due = [
        for (final heat in selected)
          if (everything ||
              running.contains(heat.id) ||
              _readNextTick.contains(heat.id) ||
              !lanesRead(heat, current.lanes))
            heat,
      ];
      final placeIds = _placeIds(due);
      final fetched = placeIds.isEmpty
          ? const <int, LaneAssignment?>{}
          : await repository.getLanes(placeIds);
      if (!runRef.mounted) return;
      _readNextTick
        ..clear()
        ..addAll(running)
        ..addAll(_incomplete(due, fetched));
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

  /// Les séries de [heats] dont une place manque à [fetched].
  Iterable<int> _incomplete(
    Iterable<Heat> heats,
    Map<int, LaneAssignment?> fetched,
  ) => [
    for (final heat in heats)
      if (heat.seriesId != null && !heat.placeIds.every(fetched.containsKey))
        heat.id,
  ];
}
