import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/competition_repository.dart';
import 'package:live_ffss_v2/features/home/favorites.dart';
import 'package:live_ffss_v2/features/home/home_providers.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/competitions.dart';
import '../../support/in_memory_local_store.dart';

class _MockCompetitionRepository extends Mock
    implements CompetitionRepository {}

void main() {
  late _MockCompetitionRepository repository;
  late InMemoryLocalStore store;

  final recent = competition(1, name: 'Récente', start: DateTime(2026, 10, 4));
  final old = competition(1416, name: 'N1', start: DateTime(2026, 3, 27));
  final older = competition(
    1086,
    name: 'N1 2024',
    start: DateTime(2024, 3, 30),
  );

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        competitionRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 17)),
      ],
      retry: noRetry,
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    repository = _MockCompetitionRepository();
    store = InMemoryLocalStore();
    when(
      () => repository.getCompetitionsFrom(any()),
    ).thenAnswer((_) async => [recent]);
  });

  setUpAll(() => registerFallbackValue(DateTime(2026)));

  test('aucun favori : liste vide, sans appel par id', () async {
    final c = container();

    expect(await c.read(favoriteCompetitionsProvider.future), isEmpty);
    verifyNever(() => repository.getCompetition(any()));
  });

  test(
    'un favori hors de la liste de l\'accueil est relu par son id',
    () async {
      store.values[FavoritesNotifier.storageKey] = '[1,1416]';
      when(() => repository.getCompetition(1416)).thenAnswer((_) async => old);
      final c = container();

      final favorites = await c.read(favoriteCompetitionsProvider.future);

      expect(favorites, [old, recent]);
      verify(() => repository.getCompetition(1416)).called(1);
      verifyNever(() => repository.getCompetition(1));
    },
  );

  test('triés par date de début', () async {
    store.values[FavoritesNotifier.storageKey] = '[1,1086,1416]';
    when(() => repository.getCompetition(1416)).thenAnswer((_) async => old);
    when(() => repository.getCompetition(1086)).thenAnswer((_) async => older);
    final c = container();

    expect(await c.read(favoriteCompetitionsProvider.future), [
      older,
      old,
      recent,
    ]);
  });

  test('un favori illisible ou en échec est écarté, pas la liste', () async {
    store.values[FavoritesNotifier.storageKey] = '[1,1086,1416]';
    when(
      () => repository.getCompetition(1416),
    ).thenThrow(const NetworkException('hors ligne'));
    when(() => repository.getCompetition(1086)).thenAnswer((_) async => null);
    final c = container();

    expect(await c.read(favoriteCompetitionsProvider.future), [recent]);
  });

  test('accueil en échec : les favoris sont tous relus par id', () async {
    store.values[FavoritesNotifier.storageKey] = '[1416]';
    when(
      () => repository.getCompetitionsFrom(any()),
    ).thenThrow(const NetworkException('hors ligne'));
    when(() => repository.getCompetition(1416)).thenAnswer((_) async => old);
    final c = container();

    expect(await c.read(favoriteCompetitionsProvider.future), [old]);
  });
}
