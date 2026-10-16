import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/competition_repository.dart';
import 'package:live_ffss_v2/features/home/home_providers.dart';
import 'package:live_ffss_v2/features/home/home_view.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/competitions.dart';
import '../../support/in_memory_local_store.dart';

class _MockCompetitionRepository extends Mock
    implements CompetitionRepository {}

void main() {
  late _MockCompetitionRepository repository;
  late ProviderContainer container;

  setUpAll(() => registerFallbackValue(DateTime(2000)));

  setUp(() {
    repository = _MockCompetitionRepository();
    container = ProviderContainer(
      overrides: [
        competitionRepositoryProvider.overrideWithValue(repository),
        localStoreProvider.overrideWithValue(InMemoryLocalStore()),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 17, 9, 42)),
      ],
      retry: noRetry,
    );
    addTearDown(container.dispose);
  });

  test(
    'demande les compétitions à partir d\'aujourd\'hui − 14 jours',
    () async {
      when(
        () => repository.getCompetitionsFrom(any()),
      ).thenAnswer((_) async => []);

      await container.read(homeCompetitionsProvider.future);

      verify(
        () => repository.getCompetitionsFrom(DateTime(2026, 9, 2)),
      ).called(1);
    },
  );

  test('la vue suit le filtre', () async {
    when(
      () => repository.getCompetitionsFrom(any()),
    ).thenAnswer((_) async => [competition(1, start: DateTime(2026, 10, 20))]);
    container.listen(homeViewProvider, (_, _) {});
    await container.read(homeCompetitionsProvider.future);

    expect(container.read(homeViewProvider)?.upcomingCount, 1);

    container.read(homeFilterProvider.notifier).select(HomeFilter.coastal);

    expect(container.read(homeViewProvider)?.upcomingCount, 0);
  });

  test('un rafraîchissement en échec garde la liste affichée', () async {
    var calls = 0;
    when(() => repository.getCompetitionsFrom(any())).thenAnswer((_) async {
      if (calls++ == 0) return [competition(1, start: DateTime(2026, 10, 20))];
      throw const NetworkException('offline');
    });
    container.listen(homeViewProvider, (_, _) {});
    await container.read(homeCompetitionsProvider.future);

    await expectLater(
      container.refresh(homeCompetitionsProvider.future),
      throwsA(isA<NetworkException>()),
    );

    final state = container.read(homeCompetitionsProvider);
    expect(state.hasError, isTrue);
    expect(state.hasValue, isTrue);
    expect(container.read(homeViewProvider)?.upcomingCount, 1);
  });

  test('la compétition courante par défaut est celle en direct', () async {
    final live = competition(7, start: DateTime(2026, 10, 17));
    when(
      () => repository.getCompetitionsFrom(any()),
    ).thenAnswer((_) async => [live]);
    container.listen(currentCompetitionProvider, (_, _) {});
    await container.read(homeCompetitionsProvider.future);

    expect(container.read(currentCompetitionProvider), live);
  });
}
