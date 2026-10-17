import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/features/programme/programme_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockMeetingRepository extends Mock implements MeetingRepository {}

void main() {
  late _MockMeetingRepository repository;

  Programme programme() => Programme(
    meetings: [
      Meeting(id: 1, name: 'R1', day: DateTime(2026, 3, 27)),
      Meeting(id: 2, name: 'R2', day: DateTime(2026, 3, 28)),
    ],
  );

  ProviderContainer containerAt(DateTime now) => ProviderContainer(
    overrides: [
      meetingRepositoryProvider.overrideWithValue(repository),
      clockProvider.overrideWithValue(() => now),
    ],
    retry: noRetry,
  );

  setUp(() {
    repository = _MockMeetingRepository();
    when(
      () => repository.getProgramme(any()),
    ).thenAnswer((_) async => programme());
  });

  test('relit le programme toutes les 30 s tant qu\'il est écouté', () {
    fakeAsync((async) {
      final container = containerAt(DateTime(2026, 3, 27));
      container.listen(programmeProvider(1453), (_, _) {});
      async.flushMicrotasks();
      verify(() => repository.getProgramme(1453)).called(1);

      async.elapse(programmeRefresh);
      async.flushMicrotasks();
      verify(() => repository.getProgramme(1453)).called(1);

      container.dispose();
    });
  });

  test('arrête de relire quand plus personne n\'écoute', () {
    fakeAsync((async) {
      final container = containerAt(DateTime(2026, 3, 27));
      final subscription = container.listen(programmeProvider(1453), (_, _) {});
      async.flushMicrotasks();
      verify(() => repository.getProgramme(1453)).called(1);

      subscription.close();
      async.elapse(programmeRefresh * 3);
      async.flushMicrotasks();
      verifyNever(() => repository.getProgramme(1453));

      container.dispose();
    });
  });

  test('un rafraîchissement en échec garde le programme', () {
    fakeAsync((async) {
      final container = containerAt(DateTime(2026, 3, 27));
      container.listen(programmeProvider(1453), (_, _) {});
      async.flushMicrotasks();

      when(
        () => repository.getProgramme(any()),
      ).thenAnswer((_) async => throw const NetworkException('hors ligne'));
      async.elapse(programmeRefresh);
      async.flushMicrotasks();

      final state = container.read(programmeProvider(1453));
      expect(state.hasValue, isTrue);
      expect(state.hasError, isTrue);
      expect(state.value?.meetings, hasLength(2));

      container.dispose();
    });
  });

  test('le jour choisi par défaut est aujourd\'hui', () async {
    final container = containerAt(DateTime(2026, 3, 28, 14));
    addTearDown(container.dispose);
    container.listen(selectedDayProvider(1453), (_, _) {});

    expect(container.read(selectedDayProvider(1453)), isNull);
    await container.read(programmeProvider(1453).future);

    expect(container.read(selectedDayProvider(1453)), DateTime(2026, 3, 28));
  });

  test('un jour choisi tient au rafraîchissement', () {
    fakeAsync((async) {
      final container = containerAt(DateTime(2026, 3, 27));
      container.listen(selectedDayProvider(1453), (_, _) {});
      async.flushMicrotasks();
      expect(container.read(selectedDayProvider(1453)), DateTime(2026, 3, 27));

      container
          .read(selectedDayProvider(1453).notifier)
          .select(DateTime(2026, 3, 28));
      expect(container.read(selectedDayProvider(1453)), DateTime(2026, 3, 28));

      async.elapse(programmeRefresh);
      async.flushMicrotasks();

      verify(() => repository.getProgramme(1453)).called(2);
      expect(container.read(selectedDayProvider(1453)), DateTime(2026, 3, 28));

      container.dispose();
    });
  });
}
