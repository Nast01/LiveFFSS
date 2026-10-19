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

/// Le contrôle d'une compétition : rien n'est lu d'une compétition côtière
/// ([coastal]), dont l'app ne lit pas les résultats.
typedef DataCheck = ({bool coastal, List<DataIssue> issues});

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

/// Le contrôle des données de la compétition, lu à l'ouverture de la page et
/// par [DataCheckNotifier.refresh], sans minuterie. Lu directement aux
/// repositories, sans passer par les fournisseurs des onglets : c'est l'état
/// du site qu'on veut, pas celui d'un cache. Les étapes se suivent, et
/// chacune lit 6 au plus en vol : séries de chaque épreuve eau plate, puis
/// résultats des séries terminées, puis places.
final dataCheckProvider = AsyncNotifierProvider.autoDispose
    .family<DataCheckNotifier, DataCheck, int>(DataCheckNotifier.new);

class DataCheckNotifier extends AsyncNotifier<DataCheck> {
  DataCheckNotifier(this.competitionId);

  final int competitionId;

  static const DataCheck _none = (coastal: false, issues: <DataIssue>[]);

  @override
  Future<DataCheck> build() async {
    await requireAdmin(ref, competitionId);
    if (!ref.mounted) return _none;
    final competition = await ref.watch(
      spaceCompetitionProvider(competitionId).future,
    );
    if (!ref.mounted) return _none;
    if (isCoastalOnly(competition)) {
      return (coastal: true, issues: const <DataIssue>[]);
    }

    final results = ref.read(resultsRepositoryProvider);
    final meetings = ref.read(meetingRepositoryProvider);
    final heatResults = ref.read(resultRepositoryProvider);
    final issues = <DataIssue>[];

    // Lancées ensemble : quatre lectures, sous le plafond de 6.
    final eventsRead = _attempt(() => results.getEvents(competitionId));
    final programmeRead = _attempt(() => meetings.getProgramme(competitionId));
    final rolesRead = _readOnce(competitionRolesProvider(competitionId).future);
    final participantsRead = _readOnce(
      participantsProvider(competitionId).future,
    );
    final events = await eventsRead;
    final programme = await programmeRead;
    final rolesOk = await rolesRead;
    final participantsOk = await participantsRead;
    if (!ref.mounted) return _none;
    if (!rolesOk) issues.add(_issue(DataIssueKind.rolesFailed));
    if (!participantsOk) {
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
    if (programme == null) return (coastal: false, issues: _byKind(issues));

    final orphans = <int, List<DataIssue>>{};
    await inPool(flatWater, () => ref.mounted, (event) async {
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
    if (!ref.mounted) return _none;
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
    final byHeat = <int, List<DataIssue>>{};
    await inPool(
      [
        for (final at in heats)
          if (finished.contains(at.heat.id)) at,
      ],
      () => ref.mounted,
      (at) async {
        try {
          final read = (await heatResults.getHeatResults(
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
      },
    );
    if (!ref.mounted) return _none;
    for (final at in heats) {
      issues.addAll(byHeat[at.heat.id] ?? const []);
    }

    // `getLanes` garde lui-même 6 places au plus en vol, et ne lève pas :
    // une clé absente est une place non lue.
    final lanes = await meetings.getLanes([
      for (final at in heats) ...at.heat.placeIds,
    ]);
    if (!ref.mounted) return _none;
    for (final at in heats) {
      final unread = at.heat.placeIds.toSet().where(
        (id) => !lanes.containsKey(id),
      );
      if (unread.isNotEmpty) {
        issues.add(
          _issue(
            DataIssueKind.unreadablePlaces,
            heat: at,
            count: unread.length,
          ),
        );
      }
    }

    return (coastal: false, issues: _byKind(issues));
  }

  /// Relit tout : les rôles et participants seulement s'ils ont échoué, les
  /// autres pages s'en servent.
  Future<void> refresh() async {
    if (!ref.mounted) return;
    for (final provider in <ProviderBase<AsyncValue<Object?>>>[
      competitionRolesProvider(competitionId),
      participantsProvider(competitionId),
    ]) {
      if (ref.exists(provider) && ref.read(provider).hasError) {
        ref.invalidate(provider);
      }
    }
    ref.invalidateSelf();
    try {
      await future;
    } on AppException {
      // L'échec est dans `state`, que la page montre.
    }
  }

  Future<T?> _attempt<T>(Future<T> Function() read) async {
    try {
      return await read();
    } on AppException {
      return null;
    }
  }

  /// Lu sans être suivi : la relecture d'un autre écran ne relance pas le
  /// contrôle. Vrai si la lecture a abouti.
  Future<bool> _readOnce<T>(ProviderListenable<Future<T>> provider) async {
    final subscription = ref.listen(provider, (_, _) {});
    try {
      await subscription.read();
      return true;
    } on AppException {
      return false;
    } finally {
      subscription.close();
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
