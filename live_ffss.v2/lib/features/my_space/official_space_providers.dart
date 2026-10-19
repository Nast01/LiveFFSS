import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/data/repositories/result_repository.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/event_ranking.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/my_space/my_space_providers.dart';
import 'package:live_ffss_v2/features/officiel/outbox_service.dart';
import 'package:live_ffss_v2/features/programme/programme_providers.dart';
import 'package:live_ffss_v2/features/results/results_providers.dart';
import 'package:live_ffss_v2/features/shell/space_competition.dart';

/// L'accès rapide de l'espace officiel, tiré du programme comme la carte en
/// direct : aucune lecture de plus que celles du programme.
final officialQuickAccessProvider = FutureProvider.autoDispose
    .family<QuickAccess?, int>(
      (ref, competitionId) async =>
          quickAccess(await ref.watch(programmeProvider(competitionId).future)),
    );

/// Les séries à saisir et le nombre de celles qui n'ont pu être lues.
typedef HeatsToEnter = ({List<HeatInItem> heats, int unread});

/// Une série terminée lue sans chrono ni temps publié : ce qui reste à
/// savoir, c'est si une saisie l'attend dans la file.
typedef _BlankHeat = ({
  HeatInItem at,
  Map<int, List<int?>> chronos,
  Set<int> settled,
});

typedef _HeatReads = ({List<_BlankHeat> heats, int unread});

/// Les séries terminées lues une à une, 6 au plus en vol. Une lecture de la
/// série donne à la fois ses chronos et ses temps publiés : on ne lit pas
/// `getHeatChronos` en plus. Le programme est lu sans être suivi : sa
/// relecture de 30 s ne doit pas relancer ces lectures, que seul
/// [refreshHeatsToEnter] relance.
final _heatReadsProvider = FutureProvider.autoDispose.family<_HeatReads, int>((
  ref,
  competitionId,
) async {
  final repository = ref.read(resultRepositoryProvider);
  // Une compétition côtière n'a pas de série que l'app sache saisir.
  final competition = await ref.watch(
    spaceCompetitionProvider(competitionId).future,
  );
  if (!ref.mounted || isCoastalOnly(competition)) {
    return (heats: const <_BlankHeat>[], unread: 0);
  }
  final subscription = ref.listen(programmeProvider(competitionId), (_, _) {});
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
  if (!ref.mounted) return (heats: const <_BlankHeat>[], unread: 0);

  final heats = heatsToCheck(programme);
  final blank = <int, _BlankHeat>{};
  var unread = 0;
  await inPool(heats, () => ref.mounted, (heat) async {
    try {
      final results = (await repository.getHeatResults(heat.seriesId!)).values;
      final chronos = {for (final r in results) r.entryId: r.chronos};
      // Une DQ ou un forfait posé par le juge, même sans temps, est une
      // décision : la série n'attend pas de saisie. Le statut 3 n'est que la
      // valeur de repli du site, pas une décision.
      final settled = {
        for (final r in results)
          if (isValidatedByJudge(r) ||
              r.status == statusDisqualified ||
              r.status == statusForfeit)
            r.entryId,
      };
      if (!needsEntry(chronos, settled, const [])) return;
      final at = findHeat(programme, (h) => h.id == heat.id);
      if (at == null) return;
      blank[heat.id] = (at: at, chronos: chronos, settled: settled);
    } on AppException {
      unread++;
    }
  });
  return (heats: [for (final heat in heats) ?blank[heat.id]], unread: unread);
});

/// Les séries terminées de la compétition où personne n'a rien posé :
/// ni chronométreur, ni juge, ni saisie en file du compte connecté. Lues à
/// l'ouverture de la page et par [refreshHeatsToEnter], sans minuterie. La
/// file est suivie : une saisie retire sa série sans rien relire.
final heatsToEnterProvider = FutureProvider.autoDispose
    .family<HeatsToEnter, int>((ref, competitionId) async {
      // Lues ensemble ; celle qu'on n'attend pas encore ne doit pas remonter
      // son échec comme non traité.
      final readsRead = ref.watch(_heatReadsProvider(competitionId).future)
        ..ignore();
      final queue = ref.watch(outboxProvider);
      final account = (await ref.watch(sessionProvider.future))?.label;
      final reads = await readsRead;
      return (
        heats: [
          for (final blank in reads.heats)
            if (needsEntry(blank.chronos, blank.settled, [
              if (account != null)
                for (final op in queue)
                  if (op.competitionId == competitionId &&
                      op.seriesId == blank.at.heat.seriesId &&
                      isSameAccount(op.account, account))
                    op,
            ]))
              blank.at,
        ],
        unread: reads.unread,
      );
    });

/// Rafraîchissement et « Réessayer » des séries à saisir : chacune relue,
/// et le programme s'il a échoué. La page passe le conteneur de son
/// `ProviderScope`.
Future<void> refreshHeatsToEnter(
  ProviderContainer container,
  int competitionId,
) async {
  retryFailedSpaceCompetition(container, competitionId);
  final programme = programmeProvider(competitionId);
  if (container.exists(programme) && container.read(programme).hasError) {
    container.invalidate(programme);
  }
  container.invalidate(_heatReadsProvider(competitionId));
  try {
    await container.read(heatsToEnterProvider(competitionId).future);
  } on AppException {
    // L'échec est dans l'état, que la page montre.
  }
}

/// Les DQ et forfaits publiés d'une épreuve ([isForfeit]).
typedef EventDecisions = ({CompetitionEvent event, List<RankingRow> rows});

typedef OfficialDecisions = ({
  List<EventDecisions> events,

  /// Les épreuves dont le classement n'a pu être lu.
  int unreadEvents,

  /// Chaque engagement lu, pour nommer une saisie en file.
  Map<int, ({CompetitionEvent event, EventResult result})> entries,
});

/// Les DQ et forfaits de la compétition, tirés des classements d'épreuve
/// (lot 5), dans l'ordre des épreuves. Lus à l'ouverture de la page et par
/// [refreshOfficialDecisions], 6 au plus en vol, sans minuterie.
///
/// Épreuves et classements sont lus sans être suivis, le temps du calcul,
/// comme pour le planning d'un club : suivis, le rafraîchissement de
/// l'onglet Résultats les relirait tous d'un coup, sans plafond.
final officialDecisionsProvider = FutureProvider.autoDispose
    .family<OfficialDecisions, int>((ref, competitionId) async {
      ref.watch(_decisionsRefreshProvider(competitionId));
      final refreshing = ref
          .read(_decisionsRefreshProvider(competitionId).notifier)
          .take();
      final subscriptions = <ProviderSubscription<Object?>>[];
      Future<T> readOnce<T>(ProviderListenable<Future<T>> provider) {
        final subscription = ref.listen(provider, (_, _) {});
        subscriptions.add(subscription);
        return subscription.read();
      }

      const none = (
        events: <EventDecisions>[],
        unreadEvents: 0,
        entries: <int, ({CompetitionEvent event, EventResult result})>{},
      );
      try {
        // Une compétition côtière n'a pas de classement : rien n'est lu.
        final competition = await ref.watch(
          spaceCompetitionProvider(competitionId).future,
        );
        if (!ref.mounted || isCoastalOnly(competition)) return none;
        final events = await readOnce(eventsProvider(competitionId).future);
        if (!ref.mounted) return none;
        final rankings = <int, EventRanking>{};
        var unread = 0;
        await inPool(events, () => ref.mounted, (event) async {
          final ranking = eventRankingProvider((
            competitionId: competitionId,
            eventId: event.id,
          ));
          // Invalidé juste avant sa lecture, pas tous d'avance : un
          // classement que l'onglet Résultats écoute se relirait aussitôt,
          // hors du plafond.
          if (refreshing) ref.invalidate(ranking);
          try {
            rankings[event.id] = await readOnce(ranking.future);
          } on AppException {
            unread++;
          }
        });
        if (!ref.mounted) return none;
        return officialDecisions(events, rankings, unread);
      } finally {
        for (final subscription in subscriptions) {
          subscription.close();
        }
      }
    });

final _decisionsRefreshProvider = NotifierProvider.autoDispose
    .family<RefreshSignal, int, int>((_) => RefreshSignal());

/// Voir [officialDecisionsProvider].
OfficialDecisions officialDecisions(
  List<CompetitionEvent> events,
  Map<int, EventRanking> rankings,
  int unreadEvents,
) {
  final decisions = <EventDecisions>[];
  final entries = <int, ({CompetitionEvent event, EventResult result})>{};
  for (final event in events) {
    final ranking = rankings[event.id];
    if (ranking == null) continue;
    final rows = <RankingRow>[];
    for (final row in ranking.rows) {
      entries[row.result.entryId] = (event: event, result: row.result);
      if (row.result.status == statusDisqualified || isForfeit(row.result)) {
        rows.add(row);
      }
    }
    if (rows.isNotEmpty) decisions.add((event: event, rows: rows));
  }
  return (events: decisions, unreadEvents: unreadEvents, entries: entries);
}

/// Rafraîchissement et « Réessayer » des DQ et forfaits : chaque classement
/// relu, 6 au plus en vol, et les épreuves si elles ont échoué.
Future<void> refreshOfficialDecisions(
  ProviderContainer container,
  int competitionId,
) async {
  retryFailedSpaceCompetition(container, competitionId);
  final events = eventsProvider(competitionId);
  if (container.exists(events) && container.read(events).hasError) {
    // `refresh` porte son échec dans l'état, qu'il n'y a pas à attendre.
    unawaited(container.read(events.notifier).refresh());
  }
  container.read(_decisionsRefreshProvider(competitionId).notifier).request();
  try {
    await container.read(officialDecisionsProvider(competitionId).future);
  } on AppException {
    // L'échec est dans l'état, que la page montre.
  }
}
