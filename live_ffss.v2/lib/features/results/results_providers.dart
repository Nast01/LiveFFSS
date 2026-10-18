import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/results_repository.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/domain/event_ranking.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/series_link.dart';
import 'package:live_ffss_v2/domain/standings.dart';
import 'package:live_ffss_v2/features/programme/programme_providers.dart';

part 'results_providers.freezed.dart';

/// Lectures de séries en vol à la fois pour les classements : une par
/// épreuve, une soixantaine pour une compétition.
const int maxConcurrentSeries = 6;

/// Les épreuves et le programme qui les ordonne et rattache leurs séries.
/// Le programme est lu sans être observé : sa relecture de 30 s ne doit pas
/// refaire les résultats, que seul le rafraîchissement manuel relit. L'écoute
/// le garde en vie (`autoDispose`) pendant l'attente de son premier chargement,
/// puis se ferme : sans autre écran, sa minuterie de 30 s s'arrête avec lui.
final _resultsSourceProvider = FutureProvider.autoDispose
    .family<({List<CompetitionEvent> events, Programme programme}), int>((
      ref,
      competitionId,
    ) async {
      // Tout ce qui sert de `ref` est pris avant la première attente.
      final repository = ref.read(resultsRepositoryProvider);
      final subscription = ref.listen(
        programmeProvider(competitionId),
        (_, _) {},
      );
      final Programme programme;
      try {
        // `.future` attendrait un programme qui se relit, sa dernière valeur
        // suffit.
        programme =
            subscription.read().value ??
            await ref.read(programmeProvider(competitionId).future);
      } finally {
        subscription.close();
      }
      final events = await repository.getEvents(competitionId);
      return (events: orderEvents(events, programme), programme: programme);
    });

/// Le programme que les résultats ont lu : la fiche d'un athlète et « Trouver
/// sa série » y prennent les courses, sans la relecture de 30 s du programme.
final resultsProgrammeProvider = FutureProvider.autoDispose
    .family<Programme, int>(
      (ref, competitionId) async => (await ref.watch(
        _resultsSourceProvider(competitionId).future,
      )).programme,
    );

/// Un rafraîchissement manuel relance aussi un programme en échec : sa
/// dernière erreur ne doit pas bloquer les résultats. Un premier chargement
/// en cours n'est pas relancé, il serait lu deux fois.
void _retryFailedProgramme(Ref ref, int competitionId) {
  final programme = ref.read(programmeProvider(competitionId));
  if (programme.hasError) {
    ref.invalidate(programmeProvider(competitionId));
  }
}

/// Les épreuves eau plate de la compétition, dans l'ordre du déroulement de
/// leur programme puis de leur id ; celles qu'aucun déroulement ne couvre
/// viennent en dernier.
final eventsProvider = AsyncNotifierProvider.autoDispose
    .family<EventsNotifier, List<CompetitionEvent>, int>(EventsNotifier.new);

class EventsNotifier extends AsyncNotifier<List<CompetitionEvent>> {
  EventsNotifier(this.competitionId);

  final int competitionId;

  @override
  Future<List<CompetitionEvent>> build() async =>
      (await ref.watch(_resultsSourceProvider(competitionId).future)).events;

  /// Relit les épreuves ; les classements écoutés, qui en dépendent, suivent.
  Future<void> refresh() async {
    // Onglet fermé : plus rien à relire, et `ref` ne sert plus.
    if (!ref.mounted) return;
    _refreshSource(ref, competitionId);
    try {
      await future;
    } on AppException {
      // L'échec est dans `state`, que la page montre.
    }
  }
}

/// Relit les épreuves et, s'il a échoué, le programme ; les classements qui
/// en dépendent suivent.
void _refreshSource(Ref ref, int competitionId) {
  _retryFailedProgramme(ref, competitionId);
  ref.invalidate(_resultsSourceProvider(competitionId));
}

/// Voir [eventsProvider].
List<CompetitionEvent> orderEvents(
  List<CompetitionEvent> events,
  Programme programme,
) {
  final progressions = programme.progressions;
  int order(CompetitionEvent event) {
    final progression = progressionOfEvent(progressions, event);
    return progression == null
        ? progressions.length
        : progressions.indexOf(progression);
  }

  final flatWater = [
    for (final event in events)
      if (event.discipline == Discipline.flatWater)
        (event: event, order: order(event)),
  ];
  flatWater.sort((a, b) {
    final byOrder = a.order.compareTo(b.order);
    return byOrder != 0 ? byOrder : a.event.id.compareTo(b.event.id);
  });
  return [for (final entry in flatWater) entry.event];
}

EventRanking _rank(
  Programme programme,
  CompetitionEvent event,
  List<EventSeries> series,
) => rankEvent(
  event,
  linkSeries(programme, event, series),
  finalStage: finalStageOf(programme, event),
);

/// Le classement d'une épreuve. Relu seulement à la demande
/// (`ref.invalidate`) : aucune minuterie.
final eventRankingProvider = FutureProvider.autoDispose
    .family<EventRanking, ({int competitionId, int eventId})>((ref, key) async {
      // Tout ce qui sert de `ref` est pris avant la première attente.
      final repository = ref.read(resultsRepositoryProvider);
      final source = await ref.watch(
        _resultsSourceProvider(key.competitionId).future,
      );
      final event = source.events.where((e) => e.id == key.eventId).firstOrNull;
      if (event == null) throw NotFoundException('event ${key.eventId}');
      final series = await repository.getEventSeries(event.id);
      return _rank(source.programme, event, series);
    });

@freezed
abstract class Standings with _$Standings {
  const factory Standings({
    required List<ClubStanding> clubs,
    required List<LicenseeStanding> licensees,
    required int finishedSeries,
    required int totalSeries,

    /// Épreuves dont les séries n'ont pu être lues : absentes des
    /// classements, que la page dit alors incomplets.
    required int failedEvents,
    required DateTime computedAt,
  }) = _Standings;
}

/// Les classements des clubs et des licenciés, sur toutes les épreuves eau
/// plate. Lourds (une lecture par épreuve) : relus seulement par [refresh].
final standingsProvider = AsyncNotifierProvider.autoDispose
    .family<StandingsNotifier, Standings, int>(StandingsNotifier.new);

class StandingsNotifier extends AsyncNotifier<Standings> {
  StandingsNotifier(this.competitionId);

  final int competitionId;

  @override
  Future<Standings> build() async {
    // Une construction remplacée (`refresh`, page fermée) ne doit plus rien
    // lire : seul le `Ref` de son départ le dit. Tout ce qui sert de `ref` est
    // pris avant la première attente.
    final runRef = ref;
    final repository = ref.read(resultsRepositoryProvider);
    final clock = ref.read(clockProvider);
    final source = await ref.watch(
      _resultsSourceProvider(competitionId).future,
    );
    final events = source.events;

    final rankings = <int, EventRanking>{};
    var failedEvents = 0;
    final pending = events.iterator;
    // Les travailleurs tirent dans le même itérateur : `moveNext` + `current`
    // sans `await` entre les deux est sûr, le code n'est pas préemptif.
    Future<void> worker() async {
      while (runRef.mounted && pending.moveNext()) {
        final event = pending.current;
        try {
          final series = await repository.getEventSeries(event.id);
          rankings[event.id] = _rank(source.programme, event, series);
        } on AppException {
          failedEvents++;
        }
      }
    }

    // Un `refresh` pendant la lecture lance ses travailleurs avant que ceux
    // de la construction remplacée n'aient fini leur lecture en cours : 12
    // lectures au plus en vol, brièvement.
    await Future.wait([for (var i = 0; i < maxConcurrentSeries; i++) worker()]);
    // Construction remplacée : son résultat est écarté, inutile de calculer.
    if (!runRef.mounted) {
      return Standings(
        clubs: const [],
        licensees: const [],
        finishedSeries: 0,
        totalSeries: 0,
        failedEvents: failedEvents,
        computedAt: clock(),
      );
    }

    // Dans l'ordre des épreuves, pas dans celui des réponses.
    final ordered = [for (final event in events) ?rankings[event.id]];
    return Standings(
      clubs: clubStandings(ordered),
      licensees: licenseeStandings(ordered),
      finishedSeries: ordered.fold(0, (sum, r) => sum + r.finishedSeries),
      totalSeries: ordered.fold(0, (sum, r) => sum + r.totalSeries),
      failedEvents: failedEvents,
      computedAt: clock(),
    );
  }

  /// Relit tout : les épreuves, leurs séries, et le programme s'il a échoué.
  /// Une relecture en cours est remplacée, non doublée : Riverpod écarte le
  /// résultat d'une construction remplacée.
  Future<void> refresh() async {
    // Onglet fermé : plus rien à relire, et `ref` ne sert plus.
    if (!ref.mounted) return;
    _refreshSource(ref, competitionId);
    ref.invalidateSelf();
    try {
      await future;
    } on AppException {
      // L'échec est dans `state`, que la page montre.
    }
  }
}

/// L'épreuve choisie dans l'onglet Résultats ; par défaut la première de
/// [eventsProvider], nulle tant qu'elle n'est pas connue.
final resultsSelectionProvider = NotifierProvider.autoDispose
    .family<ResultsSelectionNotifier, ({int? eventId}), int>(
      ResultsSelectionNotifier.new,
    );

class ResultsSelectionNotifier extends Notifier<({int? eventId})> {
  ResultsSelectionNotifier(this.competitionId);

  final int competitionId;

  // Dans un champ, pas seulement dans `state` : chaque relecture des épreuves
  // reconstruit ce notifier, et le choix ne doit pas s'y perdre.
  int? _chosen;

  @override
  ({int? eventId}) build() {
    final events = ref.watch(eventsProvider(competitionId)).value;
    // Une épreuve retirée de la liste ne peut plus être montrée.
    if (events != null && !events.any((e) => e.id == _chosen)) _chosen = null;
    final chosen = _chosen;
    if (chosen != null) return (eventId: chosen);
    return (eventId: events?.firstOrNull?.id);
  }

  void select(int eventId) {
    _chosen = eventId;
    state = (eventId: eventId);
  }
}
