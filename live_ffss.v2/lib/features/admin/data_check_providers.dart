import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/data/repositories/result_repository.dart';
import 'package:live_ffss_v2/data/repositories/results_repository.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/domain/series_link.dart';
import 'package:live_ffss_v2/features/auth/admin.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/my_space/my_space_providers.dart';
import 'package:live_ffss_v2/features/results/athlete_providers.dart';
import 'package:live_ffss_v2/features/shell/space_competition.dart';

/// Ce que le contrôle des données constate. Les lectures en échec ont leur
/// sorte : un contrôle partiel le dit au lieu d'échouer en entier.
enum DataIssueKind {
  orphanSeries,
  eventWithoutSpeciality,
  status3,
  finishedWithoutResult,
  raceWithoutTime,
  unreadablePlaces,
  rolesFailed,
  participantsFailed,
  eventsFailed,
  programmeFailed,
  seriesFailed,
  resultsFailed,
}

/// Une anomalie : sa sorte, et où (épreuve, course, série d'épreuve).
/// La conséquence dans l'app se tire de la sorte, traduite à l'affichage.
typedef DataIssue = ({
  DataIssueKind kind,
  CompetitionEvent? event,
  HeatInItem? heat,

  /// Le nom de la série d'épreuve (orpheline) ; vide sinon.
  String where,

  /// Résultats au statut 3, places non lues ; 1 sinon.
  int count,
});

DataIssue _issue(
  DataIssueKind kind, {
  CompetitionEvent? event,
  HeatInItem? heat,
  String where = '',
  int count = 1,
}) => (kind: kind, event: event, heat: heat, where: where, count: count);

/// Une étape coûteuse du contrôle, lancée seulement par un geste.
enum DataCheckStep { notRun, running, done }

/// Le contrôle d'une compétition : rien n'est lu d'une compétition côtière
/// ([coastal]), dont l'app ne lit pas les résultats.
@immutable
class DataCheck {
  const DataCheck({
    required this.coastal,
    required this.issues,
    this.seriesReads = 0,
    this.resultReads = 0,
    this.placeReads = 0,
    this.results = DataCheckStep.notRun,
    this.places = DataCheckStep.notRun,
  });

  final bool coastal;
  final List<DataIssue> issues;

  /// Les lectures `serie?epreuve=` faites à l'ouverture, une par épreuve
  /// eau plate : le coût des séries orphelines, annoncé.
  final int seriesReads;

  /// Ce que coûteraient les étapes à la demande : une lecture par course
  /// terminée, une par place.
  final int resultReads;
  final int placeReads;

  final DataCheckStep results;
  final DataCheckStep places;

  /// Une étape tourne : une seule à la fois, pour rester à 6 lectures en vol.
  bool get busy =>
      results == DataCheckStep.running || places == DataCheckStep.running;

  DataCheck copyWith({
    List<DataIssue>? issues,
    DataCheckStep? results,
    DataCheckStep? places,
  }) => DataCheck(
    coastal: coastal,
    issues: issues ?? this.issues,
    seriesReads: seriesReads,
    resultReads: resultReads,
    placeReads: placeReads,
    results: results ?? this.results,
    places: places ?? this.places,
  );
}

/// Les séries de [event] que l'app ne rattache à aucune course du
/// programme ([linkSeries]) : absentes des résultats de l'app.
List<EventSeries> orphanSeries(
  Programme programme,
  CompetitionEvent event,
  List<EventSeries> series,
) {
  final linked = {
    for (final one in linkSeries(programme, event, series)) one.series.id,
  };
  return [
    for (final one in series)
      if (!linked.contains(one.id)) one,
  ];
}

/// Un résultat publié : le temps du juge, ou sa DQ ou son forfait. Le
/// statut 3 n'est que la valeur de repli du site.
bool _published(RaceResult result) =>
    isValidatedByJudge(result) ||
    result.status == statusDisqualified ||
    result.status == statusForfeit;

const _status3 = 3;

/// Le contrôle des données de la compétition, sans minuterie, lu
/// directement aux repositories : c'est l'état du site qu'on veut, pas
/// celui d'un cache. À l'ouverture (et par [DataCheckNotifier.refresh]),
/// les contrôles bon marché : épreuves, programme, rôles, puis les séries
/// de chaque épreuve eau plate, dont le coût est annoncé. Les résultats des
/// courses terminées et les places (des centaines de lectures) attendent
/// un geste ([DataCheckNotifier.checkResults],
/// [DataCheckNotifier.checkPlaces]). Chaque étape lit 6 au plus en vol.
final dataCheckProvider = AsyncNotifierProvider.autoDispose
    .family<DataCheckNotifier, DataCheck, int>(DataCheckNotifier.new);

class DataCheckNotifier extends AsyncNotifier<DataCheck> {
  DataCheckNotifier(this.competitionId);

  final int competitionId;

  static const DataCheck _none = DataCheck(coastal: false, issues: []);

  /// Change à chaque lecture et à chaque refus : un travail lancé avant
  /// n'écrit plus rien.
  int _generation = 0;

  /// La session s'est fermée : refusé sans attendre de relire le droit.
  bool _refused = false;

  List<HeatInItem> _heats = const [];
  List<HeatInItem> _finished = const [];
  List<DataIssue> _openIssues = const [];
  List<DataIssue> _resultIssues = const [];
  List<DataIssue> _placeIssues = const [];

  @override
  Future<DataCheck> build() async {
    final generation = ++_generation;
    _refused = false;
    _heats = _finished = const [];
    _openIssues = _resultIssues = _placeIssues = const [];
    // Le droit est lu une fois, pas suivi : une relecture des rôles par un
    // autre écran relancerait tout le contrôle. Une déconnexion refuse
    // aussitôt ; chaque geste le relit.
    ref.listen(sessionProvider, _sessionChanged);
    if (!await _readOnce(adminAccessProvider(competitionId).future)) {
      throw const AdminOnlyException();
    }
    if (_abandoned(generation)) return _none;
    final competition = await ref.watch(
      spaceCompetitionProvider(competitionId).future,
    );
    if (_abandoned(generation)) return _none;
    if (isCoastalOnly(competition)) {
      return const DataCheck(coastal: true, issues: []);
    }

    final results = ref.read(resultsRepositoryProvider);
    final meetings = ref.read(meetingRepositoryProvider);
    final issues = <DataIssue>[];

    // Lancées ensemble : trois lectures, sous le plafond de 6.
    final eventsRead = _attempt(() => results.getEvents(competitionId));
    final programmeRead = _attempt(() => meetings.getProgramme(competitionId));
    final rolesRead = _succeeds(competitionRolesProvider(competitionId).future);
    final events = await eventsRead;
    final programme = await programmeRead;
    final rolesOk = await rolesRead;
    if (_abandoned(generation)) return _none;
    if (!rolesOk) issues.add(_issue(DataIssueKind.rolesFailed));
    // Les participants (3,6 Mo) ne sont jamais lus pour le contrôle : seul
    // l'échec d'une lecture déjà faite par un autre écran est signalé.
    final participants = participantsProvider(competitionId);
    if (ref.exists(participants) && ref.read(participants).hasError) {
      issues.add(_issue(DataIssueKind.participantsFailed));
    }
    if (events == null) issues.add(_issue(DataIssueKind.eventsFailed));
    if (programme == null) issues.add(_issue(DataIssueKind.programmeFailed));

    final flatWater = <CompetitionEvent>[];
    for (final event in events ?? const <CompetitionEvent>[]) {
      switch (event.discipline) {
        case null:
          issues.add(
            _issue(DataIssueKind.eventWithoutSpeciality, event: event),
          );
        case Discipline.flatWater:
          flatWater.add(event);
        case _:
          // Le côtier d'une compétition mixte : l'app ne le lit pas.
          break;
      }
    }
    // Sans programme, ni rattachement ni course à contrôler.
    if (programme == null) {
      _openIssues = issues;
      return DataCheck(coastal: false, issues: _byKind(issues));
    }

    final orphans = <int, List<DataIssue>>{};
    await inPool(flatWater, () => !_stale(generation), (event) async {
      try {
        final series = await results.getEventSeries(event.id);
        orphans[event.id] = [
          for (final one in orphanSeries(programme, event, series))
            _issue(DataIssueKind.orphanSeries, event: event, where: one.name),
        ];
      } on AppException {
        orphans[event.id] = [_issue(DataIssueKind.seriesFailed, event: event)];
      }
    });
    if (_abandoned(generation)) return _none;
    for (final event in flatWater) {
      issues.addAll(orphans[event.id] ?? const []);
    }

    final heats = _heatsOf(programme);
    issues.addAll([
      for (final at in heats)
        if (at.heat.plannedStart == null)
          _issue(DataIssueKind.raceWithoutTime, heat: at),
    ]);
    final finished = heatsToCheck(programme).map((h) => h.id).toSet();
    _heats = heats;
    _finished = [
      for (final at in heats)
        if (finished.contains(at.heat.id)) at,
    ];
    _openIssues = issues;
    return DataCheck(
      coastal: false,
      issues: _byKind(issues),
      seriesReads: flatWater.length,
      resultReads: _finished.length,
      placeReads: _placeIds.length,
    );
  }

  /// Les résultats des courses terminées : statut 3, course terminée sans
  /// résultat publié. Une lecture par course, 6 au plus en vol.
  Future<void> checkResults() async {
    final generation = await _startStep(
      (check) => check.resultReads,
      (check) => check.copyWith(results: DataCheckStep.running),
    );
    if (generation == null) return;
    final repository = ref.read(resultRepositoryProvider);
    final byHeat = <int, List<DataIssue>>{};
    await inPool(_finished, () => !_stale(generation), (at) async {
      try {
        final read = (await repository.getHeatResults(
          at.heat.seriesId!,
        )).values;
        final fallback = read.where((r) => r.status == _status3).length;
        byHeat[at.heat.id] = [
          if (fallback > 0)
            _issue(DataIssueKind.status3, heat: at, count: fallback),
          if (!read.any(_published))
            _issue(DataIssueKind.finishedWithoutResult, heat: at),
        ];
      } on AppException {
        byHeat[at.heat.id] = [_issue(DataIssueKind.resultsFailed, heat: at)];
      }
    });
    if (_stale(generation)) return;
    _resultIssues = [for (final at in _finished) ...?byHeat[at.heat.id]];
    _publish((check) => check.copyWith(results: DataCheckStep.done));
  }

  /// Les places de toutes les courses : la plus coûteuse des étapes, une
  /// lecture par place.
  Future<void> checkPlaces() async {
    final generation = await _startStep(
      (check) => check.placeReads,
      (check) => check.copyWith(places: DataCheckStep.running),
    );
    if (generation == null) return;
    // `getLanes` garde lui-même 6 places au plus en vol, et ne lève pas :
    // une clé absente est une place non lue.
    final lanes = await ref.read(meetingRepositoryProvider).getLanes(_placeIds);
    if (_stale(generation)) return;
    _placeIssues = [
      for (final at in _heats)
        if (at.heat.placeIds.toSet().where((id) => !lanes.containsKey(id))
            case final unread when unread.isNotEmpty)
          _issue(
            DataIssueKind.unreadablePlaces,
            heat: at,
            count: unread.length,
          ),
    ];
    _publish((check) => check.copyWith(places: DataCheckStep.done));
  }

  /// Relit ce que lit l'ouverture, droit compris ; les étapes à la demande
  /// sont à relancer. Les rôles ne sont relus que s'ils ont échoué, les
  /// participants jamais.
  Future<void> refresh() async {
    if (!ref.mounted) return;
    final roles = competitionRolesProvider(competitionId);
    if (ref.exists(roles) && ref.read(roles).hasError) ref.invalidate(roles);
    ref.invalidateSelf();
    try {
      await future;
    } on AppException {
      // L'échec est dans `state`, que la page montre.
    }
  }

  /// La génération de l'étape, une fois son droit relu et son état posé ;
  /// nulle si elle ne doit pas partir (rien à lire, une autre tourne, droit
  /// retiré).
  Future<int?> _startStep(
    int Function(DataCheck check) reads,
    DataCheck Function(DataCheck check) running,
  ) async {
    final check = state.value;
    if (check == null || state.isLoading || state.hasError) return null;
    if (check.busy || reads(check) == 0) return null;
    final generation = _generation;
    final bool admin;
    try {
      admin = await _readOnce(adminAccessProvider(competitionId).future);
    } on AppException {
      return null;
    }
    if (_stale(generation)) return null;
    if (!admin) {
      _refuse();
      return null;
    }
    final current = state.value;
    if (current == null || current.busy) return null;
    state = AsyncData(running(current));
    return generation;
  }

  void _publish(DataCheck Function(DataCheck check) done) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      done(
        current.copyWith(
          issues: _byKind([..._openIssues, ..._resultIssues, ..._placeIssues]),
        ),
      ),
    );
  }

  void _sessionChanged(
    AsyncValue<Object?>? previous,
    AsyncValue<Object?> next,
  ) {
    // Le premier chargement de la session n'est pas un changement.
    if (!(previous?.hasValue ?? false) || next.isLoading) return;
    if (previous?.value == next.value) return;
    if (next.value == null) {
      _refuse();
    } else {
      ref.invalidateSelf();
    }
  }

  void _refuse() {
    _refused = true;
    _generation++;
    state = AsyncError(const AdminOnlyException(), StackTrace.current);
  }

  /// Ce travail ne doit plus rien écrire : remplacé, ou page fermée.
  bool _stale(int generation) => !ref.mounted || generation != _generation;

  /// [_stale] pour la lecture d'ouverture, qui lève si la session s'est
  /// fermée entre-temps : rendre une valeur effacerait le refus.
  bool _abandoned(int generation) {
    if (_refused) throw const AdminOnlyException();
    return _stale(generation);
  }

  List<int> get _placeIds =>
      {for (final at in _heats) ...at.heat.placeIds}.toList();

  Future<T?> _attempt<T>(Future<T> Function() read) async {
    try {
      return await read();
    } on AppException {
      return null;
    }
  }

  /// Lu sans être suivi : la relecture d'un autre écran ne relance pas le
  /// contrôle.
  Future<T> _readOnce<T>(ProviderListenable<Future<T>> provider) async {
    final subscription = ref.listen(provider, (_, _) {});
    try {
      return await subscription.read();
    } finally {
      subscription.close();
    }
  }

  /// Vrai si la lecture a abouti.
  Future<bool> _succeeds<T>(ProviderListenable<Future<T>> provider) async {
    try {
      await _readOnce(provider);
      return true;
    } on AppException {
      return false;
    }
  }
}

/// Groupées par sorte, chacune dans l'ordre où elle a été trouvée (`sort`
/// n'est pas stable).
List<DataIssue> _byKind(List<DataIssue> issues) => [
  for (final kind in DataIssueKind.values)
    ...issues.where((issue) => issue.kind == kind),
];

List<HeatInItem> _heatsOf(Programme programme) => [
  for (final meeting in programme.meetings)
    for (final item in meeting.items)
      for (final heat in item.heats) (item: item, heat: heat),
];
