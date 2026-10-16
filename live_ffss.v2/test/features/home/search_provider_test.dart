import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/competition_repository.dart';
import 'package:live_ffss_v2/features/home/search_provider.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/competitions.dart';

class _MockCompetitionRepository extends Mock
    implements CompetitionRepository {}

void main() {
  late _MockCompetitionRepository repository;

  setUp(() {
    repository = _MockCompetitionRepository();
    when(
      () => repository.search(any()),
    ).thenAnswer((_) async => [competition(1, start: DateTime(2026, 3, 27))]);
  });

  ProviderContainer containerFor() => ProviderContainer(
    overrides: [competitionRepositoryProvider.overrideWithValue(repository)],
    retry: noRetry,
  );

  test('moins de 2 caractères : aucun appel, aucun résultat', () async {
    final container = containerFor();
    addTearDown(container.dispose);
    container.listen(searchResultsProvider(' g '), (_, _) {});

    expect(await container.read(searchResultsProvider(' g ').future), isEmpty);
    verifyNever(() => repository.search(any()));
  });

  test('appelle la recherche 300 ms après la dernière frappe', () {
    fakeAsync((async) {
      final container = containerFor();
      container.listen(searchResultsProvider('gir'), (_, _) {});

      async.elapse(searchDebounce - const Duration(milliseconds: 1));
      verifyNever(() => repository.search(any()));

      async.elapse(const Duration(milliseconds: 1));
      async.flushMicrotasks();
      verify(() => repository.search('gir')).called(1);

      container.dispose();
    });
  });

  test('une frappe abandonnée avant 300 ms n\'appelle jamais l\'API', () {
    fakeAsync((async) {
      final container = containerFor();
      final subscription = container.listen(
        searchResultsProvider('gi'),
        (_, _) {},
      );

      async.elapse(const Duration(milliseconds: 100));
      subscription.close();
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();

      verifyNever(() => repository.search('gi'));
      container.dispose();
    });
  });
}
