import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/ffss/dtos/deroulement_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/epreuve_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/reunion_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/serie_results_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/deroulement_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/results_mapper.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/data/repositories/results_repository.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/series_link.dart';
import 'package:live_ffss_v2/features/results/results_providers.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockResultsRepository extends Mock implements ResultsRepository {}

class _MockMeetingRepository extends Mock implements MeetingRepository {}

List<Map<String, dynamic>> _rows(String name) =>
    (fixture(name)['data'] as List<dynamic>).cast<Map<String, dynamic>>();

Programme _fixtureProgramme() {
  final progressions = [
    for (final row in _rows('deroulement'))
      ?DeroulementDto.fromJson(row).toDomain(),
  ];
  final meetings = [
    for (final row in _rows('reunion')) ?ReunionDto.fromJson(row).toDomain(),
  ];
  return Programme(
    meetings: withRaces(meetings, progressions),
    progressions: progressions,
  );
}

List<CompetitionEvent> _fixtureEvents() => [
  for (final row in _rows('epreuves_1416'))
    ?EpreuveDto.fromJson(row).toDomain(),
];

List<EventSeries> _fixtureSeries(int eventId) => [
  for (final row in _rows('serie_epreuve_$eventId'))
    ?SerieResultsDto.fromJson(row).toDomain(),
];

const _withSeries = {36073, 36074, 36087};

void main() {
  const competitionId = 1416;
  final programme = _fixtureProgramme();
  final fixtureEvents = _fixtureEvents();
  final series = {for (final id in _withSeries) id: _fixtureSeries(id)};

  // Une épreuve côtière glissée dans la liste : elle ne doit jamais sortir.
  final coastal = fixtureEvents.first.copyWith(
    id: 99999,
    discipline: Discipline.coastal,
  );

  late _MockResultsRepository results;
  late _MockMeetingRepository meetings;
  late DateTime now;
  late int inFlight;
  late int maxInFlight;
  late Set<int> failing;

  ProviderContainer container() => ProviderContainer(
    overrides: [
      resultsRepositoryProvider.overrideWithValue(results),
      meetingRepositoryProvider.overrideWithValue(meetings),
      clockProvider.overrideWithValue(() => now),
    ],
    retry: noRetry,
  );

  setUp(() {
    results = _MockResultsRepository();
    meetings = _MockMeetingRepository();
    now = DateTime(2026, 10, 18, 14, 30);
    inFlight = 0;
    maxInFlight = 0;
    failing = {};
    when(() => meetings.getProgramme(any())).thenAnswer((_) async => programme);
    when(
      () => results.getEvents(any()),
    ).thenAnswer((_) async => [coastal, ...fixtureEvents.reversed]);
    when(() => results.getEventSeries(any())).thenAnswer((invocation) async {
      final id = invocation.positionalArguments.first as int;
      inFlight++;
      if (inFlight > maxInFlight) maxInFlight = inFlight;
      try {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        if (failing.contains(id)) throw const NetworkException('hors ligne');
        return series[id] ?? const [];
      } finally {
        inFlight--;
      }
    });
  });

  group('eventsProvider', () {
    test(
      'eau plate seulement, dans l\'ordre du déroulement puis de l\'id',
      () async {
        final c = container();
        addTearDown(c.dispose);
        c.listen(eventsProvider(competitionId), (_, _) {});

        final events = await c.read(eventsProvider(competitionId).future);

        expect(events.map((e) => e.id), isNot(contains(coastal.id)));
        expect(events, hasLength(fixtureEvents.length));
        int order(CompetitionEvent event) {
          final progression = progressionOfEvent(programme.progressions, event);
          final index = progression == null
              ? -1
              : programme.progressions.indexOf(progression);
          return index < 0 ? programme.progressions.length : index;
        }

        for (var i = 1; i < events.length; i++) {
          final a = events[i - 1];
          final b = events[i];
          expect(
            order(a) < order(b) || (order(a) == order(b) && a.id < b.id),
            isTrue,
            reason: '${a.id} avant ${b.id}',
          );
        }
        // Au moins deux déroulements distincts : l'ordre n'est pas que l'id.
        expect(events.map(order).toSet().length, greaterThan(1));
      },
    );
  });

  group('eventsProvider.refresh', () {
    test('relit les épreuves et les classements écoutés', () async {
      final c = container();
      addTearDown(c.dispose);
      const key = (competitionId: competitionId, eventId: 36073);
      c.listen(eventRankingProvider(key), (_, _) {});
      await c.read(eventRankingProvider(key).future);
      clearInteractions(results);

      await c.read(eventsProvider(competitionId).notifier).refresh();
      await c.read(eventRankingProvider(key).future);

      verify(() => results.getEvents(competitionId)).called(1);
      verify(() => results.getEventSeries(36073)).called(1);
    });

    test('ne relance pas un premier programme encore en cours', () async {
      final programmeRead = Completer<Programme>();
      when(
        () => meetings.getProgramme(any()),
      ).thenAnswer((_) => programmeRead.future);
      final c = container();
      addTearDown(c.dispose);
      c.listen(eventsProvider(competitionId), (_, _) {});
      await pumpEventQueue();

      final refreshed = c
          .read(eventsProvider(competitionId).notifier)
          .refresh();
      await pumpEventQueue();
      programmeRead.complete(programme);
      await refreshed;

      verify(() => meetings.getProgramme(competitionId)).called(1);
      expect(c.read(eventsProvider(competitionId)).value, isNotEmpty);
    });

    test('après la fermeture : ni attente sans fin ni erreur', () async {
      final c = container();
      c.listen(eventsProvider(competitionId), (_, _) {});
      await c.read(eventsProvider(competitionId).future);
      final notifier = c.read(eventsProvider(competitionId).notifier);
      c.dispose();

      await notifier.refresh().timeout(const Duration(seconds: 1));
    });
  });

  group('eventRankingProvider', () {
    test('36073 : rattachée, classée, sans doublon d\'engagement', () async {
      final c = container();
      addTearDown(c.dispose);
      const key = (competitionId: competitionId, eventId: 36073);
      c.listen(eventRankingProvider(key), (_, _) {});

      final ranking = await c.read(eventRankingProvider(key).future);

      expect(ranking.event.id, 36073);
      final entries = [for (final row in ranking.rows) row.result.entryId];
      expect(entries, isNotEmpty);
      expect(entries.toSet().length, entries.length);
      expect(ranking.rows.first.rank, 1);
      // La finale prévue au déroulement est passée : les séries ne marquent
      // pas de points.
      final heatRows = [
        for (final row in ranking.rows)
          if (row.round == EventRound.heats) row,
      ];
      expect(heatRows, isNotEmpty);
      expect(heatRows.map((r) => r.points), everyElement(0));
      verify(() => results.getEventSeries(36073)).called(1);
    });

    test('une épreuve inconnue échoue', () async {
      final c = container();
      addTearDown(c.dispose);
      const key = (competitionId: competitionId, eventId: 1);
      c.listen(eventRankingProvider(key), (_, _) {});

      await expectLater(
        c.read(eventRankingProvider(key).future),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('standingsProvider', () {
    Future<Standings> standings(ProviderContainer c) {
      c.listen(standingsProvider(competitionId), (_, _) {});
      return c.read(standingsProvider(competitionId).future);
    }

    test('toutes les épreuves eau plate, 6 lectures au plus en vol', () async {
      final c = container();
      addTearDown(c.dispose);

      final result = await standings(c);

      verify(() => results.getEventSeries(any())).called(fixtureEvents.length);
      verifyNever(() => results.getEventSeries(coastal.id));
      expect(maxInFlight, 6);
      expect(result.clubs, isNotEmpty);
      expect(result.licensees, isNotEmpty);
      expect(result.failedEvents, 0);
      expect(result.totalSeries, greaterThan(0));
      expect(result.finishedSeries, lessThanOrEqualTo(result.totalSeries));
      expect(result.computedAt, now);
    });

    test(
      'une épreuve en échec est comptée et omise, le reste calculé',
      () async {
        final c = container();
        addTearDown(c.dispose);
        final all = await standings(c);
        c.dispose();

        failing = {36074};
        final c2 = container();
        addTearDown(c2.dispose);
        final partial = await standings(c2);

        expect(partial.failedEvents, 1);
        expect(partial.clubs, isNotEmpty);
        expect(partial.totalSeries, lessThan(all.totalSeries));
        expect(partial.totalSeries, greaterThan(0));
      },
    );

    test('refresh() relit les épreuves et leurs séries', () async {
      final c = container();
      addTearDown(c.dispose);
      final first = await standings(c);
      expect(first.computedAt, now);
      clearInteractions(results);

      now = now.add(const Duration(minutes: 3));
      await c.read(standingsProvider(competitionId).notifier).refresh();

      verify(() => results.getEvents(competitionId)).called(1);
      verify(() => results.getEventSeries(any())).called(fixtureEvents.length);
      final second = c.read(standingsProvider(competitionId)).value!;
      expect(second.computedAt, now);
    });

    test(
      'fermé pendant la lecture : plus aucune lecture, aucune erreur',
      () async {
        final reads = <Completer<List<EventSeries>>>[];
        when(() => results.getEventSeries(any())).thenAnswer((_) {
          final read = Completer<List<EventSeries>>();
          reads.add(read);
          return read.future;
        });
        final c = container();
        c.listen(standingsProvider(competitionId), (_, _) {});
        await pumpEventQueue();
        expect(reads, hasLength(maxConcurrentSeries));

        c.dispose();
        for (final read in reads) {
          read.complete(const []);
        }
        await pumpEventQueue();

        expect(reads, hasLength(maxConcurrentSeries));
      },
    );

    test(
      'refresh() après la fermeture : ni attente sans fin ni erreur',
      () async {
        final c = container();
        c.listen(standingsProvider(competitionId), (_, _) {});
        await c.read(standingsProvider(competitionId).future);
        final notifier = c.read(standingsProvider(competitionId).notifier);
        c.dispose();

        await notifier.refresh().timeout(const Duration(seconds: 1));
      },
    );

    test(
      'refresh() fermé en cours de route : ni attente sans fin ni erreur',
      () async {
        final c = container();
        c.listen(standingsProvider(competitionId), (_, _) {});
        await c.read(standingsProvider(competitionId).future);

        final refreshed = c
            .read(standingsProvider(competitionId).notifier)
            .refresh();
        await pumpEventQueue(times: 2);
        c.dispose();

        await refreshed.timeout(const Duration(seconds: 1));
      },
    );

    test('aucune minuterie : rien n\'est relu en 5 minutes', () {
      fakeAsync((async) {
        final c = container();
        c.listen(standingsProvider(competitionId), (_, _) {});
        c.listen(
          eventRankingProvider((competitionId: competitionId, eventId: 36073)),
          (_, _) {},
        );
        async.elapse(const Duration(seconds: 1));
        expect(c.read(standingsProvider(competitionId)).hasValue, isTrue);
        clearInteractions(results);

        async.elapse(const Duration(minutes: 5));

        verifyNever(() => results.getEvents(any()));
        verifyNever(() => results.getEventSeries(any()));
        // Le programme lu, son écoute est close : sa minuterie de 30 s ne
        // tourne plus pour les résultats.
        verify(() => meetings.getProgramme(competitionId)).called(1);
        c.dispose();
      });
    });
  });

  group('resultsSelectionProvider', () {
    test('la première épreuve par défaut, puis celle choisie', () async {
      final c = container();
      addTearDown(c.dispose);
      c.listen(resultsSelectionProvider(competitionId), (_, _) {});
      expect(c.read(resultsSelectionProvider(competitionId)).eventId, isNull);

      final events = await c.read(eventsProvider(competitionId).future);
      expect(
        c.read(resultsSelectionProvider(competitionId)).eventId,
        events.first.id,
      );

      c.read(resultsSelectionProvider(competitionId).notifier).select(36087);
      expect(c.read(resultsSelectionProvider(competitionId)).eventId, 36087);

      c.invalidate(eventsProvider(competitionId));
      await c.read(eventsProvider(competitionId).future);
      expect(c.read(resultsSelectionProvider(competitionId)).eventId, 36087);
    });

    test('une épreuve choisie disparue : retour à la première', () async {
      final c = container();
      addTearDown(c.dispose);
      c.listen(resultsSelectionProvider(competitionId), (_, _) {});
      final events = await c.read(eventsProvider(competitionId).future);
      c.read(resultsSelectionProvider(competitionId).notifier).select(36087);

      when(() => results.getEvents(any())).thenAnswer(
        (_) async => [
          for (final event in fixtureEvents)
            if (event.id != 36087) event,
        ],
      );
      await c.read(eventsProvider(competitionId).notifier).refresh();

      expect(
        c.read(resultsSelectionProvider(competitionId)).eventId,
        events.first.id,
      );
    });
  });

  group('standingsFilterProvider', () {
    test('clubs par défaut, puis le choix est gardé', () {
      final c = container();
      addTearDown(c.dispose);
      c.listen(standingsFilterProvider(competitionId), (_, _) {});
      final notifier = c.read(standingsFilterProvider(competitionId).notifier);

      expect(c.read(standingsFilterProvider(competitionId)), (
        kind: StandingsKind.clubs,
        gender: null,
        category: null,
      ));

      notifier
        ..selectKind(StandingsKind.licensees)
        ..selectGender(Gender.male)
        ..selectCategory('Cadet');
      expect(c.read(standingsFilterProvider(competitionId)), (
        kind: StandingsKind.licensees,
        gender: Gender.male,
        category: 'Cadet',
      ));

      // Changer de sexe garde la catégorie : elle peut exister des deux côtés.
      notifier.selectGender(Gender.female);
      expect(c.read(standingsFilterProvider(competitionId)).category, 'Cadet');
    });
  });
}
