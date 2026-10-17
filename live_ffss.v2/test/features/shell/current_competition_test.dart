import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/competition_repository.dart';
import 'package:live_ffss_v2/features/home/home_providers.dart';
import 'package:live_ffss_v2/features/shell/active_competition.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/competitions.dart';
import '../../support/in_memory_local_store.dart';

class _MockCompetitionRepository extends Mock
    implements CompetitionRepository {}

void main() {
  final today = DateTime(2026, 10, 17);
  final liveA = competition(
    1,
    name: 'A',
    start: DateTime(2026, 10, 16),
    end: DateTime(2026, 10, 18),
  );
  final liveB = competition(
    2,
    name: 'B',
    start: DateTime(2026, 10, 15),
    end: DateTime(2026, 10, 18),
  );
  final upcoming = competition(3, start: DateTime(2026, 11, 1));

  test('la compétition choisie, si elle est dans la liste', () {
    expect(
      currentCompetition(
        competitions: [liveA, liveB, upcoming],
        selection: (id: 3, summary: null),
        favorites: {},
        today: today,
      ),
      upcoming,
    );
  });

  test('choisie hors de la liste : le résumé gardé en mémoire', () {
    final old = competition(99, start: DateTime(2025, 5, 1));

    expect(
      currentCompetition(
        competitions: [liveA],
        selection: (id: 99, summary: old),
        favorites: {},
        today: today,
      ),
      old,
    );
  });

  test('rien de choisi : la première du carrousel, favoris d\'abord', () {
    expect(
      currentCompetition(
        competitions: [liveA, liveB],
        selection: null,
        favorites: {1},
        today: today,
      ),
      liveA,
    );
    expect(
      currentCompetition(
        competitions: [liveA, liveB],
        selection: null,
        favorites: {},
        today: today,
      ),
      liveB,
    );
  });

  test('choisie mais introuvable, sans résumé : le défaut', () {
    expect(
      currentCompetition(
        competitions: [liveA],
        selection: (id: 99, summary: null),
        favorites: {},
        today: today,
      ),
      liveA,
    );
  });

  test('rien en direct et rien de choisi : aucune', () {
    expect(
      currentCompetition(
        competitions: [upcoming],
        selection: null,
        favorites: {},
        today: today,
      ),
      isNull,
    );
  });

  test('choisie hors de la liste et relue : la compétition relue', () {
    final fetched = competition(99, start: DateTime(2025, 5, 1));

    expect(
      currentCompetition(
        competitions: [liveA],
        selection: (id: 99, summary: null),
        fetched: fetched,
        favorites: {},
        today: today,
      ),
      fetched,
    );
  });

  group('needsActivation', () {
    test('la compétition suivie : rien à activer', () {
      expect(needsActivation(1453, 1453), isFalse);
    });

    test('une autre compétition, ou aucune : lien direct à activer', () {
      expect(needsActivation(7, 1453), isTrue);
      expect(needsActivation(null, 1453), isTrue);
    });
  });

  group('currentCompetitionProvider', () {
    late _MockCompetitionRepository repository;

    ProviderContainer containerWith(String? storedId) {
      final store = InMemoryLocalStore();
      if (storedId != null) {
        store.values[ActiveCompetitionNotifier.storageKey] = storedId;
      }
      final container = ProviderContainer(
        overrides: [
          competitionRepositoryProvider.overrideWithValue(repository),
          localStoreProvider.overrideWithValue(store),
          clockProvider.overrideWithValue(() => today),
        ],
        retry: noRetry,
      );
      addTearDown(container.dispose);
      return container;
    }

    Future<void> settle(ProviderContainer container, {int? fetchedId}) async {
      container.listen(currentCompetitionProvider, (_, _) {});
      await container
          .read(homeCompetitionsProvider.future)
          .then((_) {}, onError: (Object _) {});
      await container.read(activeCompetitionProvider.future);
      if (fetchedId != null) {
        await container
            .read(competitionByIdProvider(fetchedId).future)
            .then((_) {}, onError: (Object _) {});
      }
      await Future<void>.delayed(Duration.zero);
    }

    setUp(() {
      repository = _MockCompetitionRepository();
      registerFallbackValue(DateTime(2000));
      when(
        () => repository.getCompetitionsFrom(any()),
      ).thenAnswer((_) async => [liveA, liveB]);
    });

    test(
      'une compétition choisie absente de la liste est relue par son id',
      () async {
        final old = competition(99, name: 'Relue', start: DateTime(2025, 5, 1));
        when(() => repository.getCompetition(99)).thenAnswer((_) async => old);
        final container = containerWith('99');

        await settle(container);

        verify(() => repository.getCompetition(99)).called(1);
        expect(container.read(currentCompetitionProvider), old);
      },
    );

    test('pas de relecture quand la compétition est dans la liste', () async {
      final container = containerWith('2');

      await settle(container);

      verifyNever(() => repository.getCompetition(any()));
      expect(container.read(currentCompetitionProvider), liveB);
    });

    test('relecture en échec : le choix par défaut', () async {
      when(
        () => repository.getCompetition(99),
      ).thenAnswer((_) async => throw const NetworkException('hors ligne'));
      final container = containerWith('99');

      await settle(container, fetchedId: 99);

      expect(container.read(currentCompetitionProvider), liveB);
    });

    test('relecture en échec, accueil rechargé : relue et trouvée', () async {
      final old = competition(99, name: 'Relue', start: DateTime(2025, 5, 1));
      var calls = 0;
      when(() => repository.getCompetition(99)).thenAnswer((_) async {
        calls++;
        if (calls == 1) throw const NetworkException('hors ligne');
        return old;
      });
      final container = containerWith('99');
      await settle(container, fetchedId: 99);
      expect(container.read(currentCompetitionProvider), liveB);

      container.invalidate(homeCompetitionsProvider);
      await settle(container, fetchedId: 99);

      expect(calls, 2);
      expect(container.read(currentCompetitionProvider), old);
    });

    test(
      'accueil en échec : la compétition choisie est quand même relue',
      () async {
        final old = competition(99, name: 'Relue', start: DateTime(2025, 5, 1));
        when(
          () => repository.getCompetitionsFrom(any()),
        ).thenAnswer((_) async => throw const NetworkException('hors ligne'));
        when(() => repository.getCompetition(99)).thenAnswer((_) async => old);
        final container = containerWith('99');

        await settle(container, fetchedId: 99);

        expect(container.read(currentCompetitionProvider), old);
      },
    );
  });
}
