import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/now_running.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/features/home/now_running_provider.dart';
import 'package:live_ffss_v2/features/programme/programme_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockMeetingRepository extends Mock implements MeetingRepository {}

void main() {
  late _MockMeetingRepository repository;

  setUp(() {
    repository = _MockMeetingRepository();
    when(() => repository.getProgramme(any())).thenAnswer(
      (_) async => Programme(
        meetings: [
          Meeting(
            id: 1,
            name: 'R',
            day: DateTime(2026, 3, 27),
            items: const [
              MeetingItem(
                id: 10,
                name: 'C',
                heats: [
                  Heat(
                    id: 20,
                    name: 'Série 1',
                    number: 1,
                    status: RunStatus.inProgress,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  });

  test('calcule la série en cours de la compétition', () async {
    final container = ProviderContainer(
      overrides: [meetingRepositoryProvider.overrideWithValue(repository)],
      retry: noRetry,
    );
    addTearDown(container.dispose);
    container.listen(nowRunningProvider(1453), (_, _) {});

    final result = await container.read(nowRunningProvider(1453).future);

    expect(result?.heat.id, 20);
    expect(result?.kind, NowRunningKind.now);
    verify(() => repository.getProgramme(1453)).called(1);
  });

  test('carte et onglet Programme ensemble : un seul appel par passage', () {
    fakeAsync((async) {
      final container = ProviderContainer(
        overrides: [meetingRepositoryProvider.overrideWithValue(repository)],
        retry: noRetry,
      );
      container.listen(nowRunningProvider(1453), (_, _) {});
      container.listen(programmeProvider(1453), (_, _) {});
      async.flushMicrotasks();
      verify(() => repository.getProgramme(1453)).called(1);
      expect(container.read(nowRunningProvider(1453)).value?.heat.id, 20);

      async.elapse(programmeRefresh);
      async.flushMicrotasks();
      verify(() => repository.getProgramme(1453)).called(1);

      container.dispose();
    });
  });

  test('se rafraîchit toutes les 30 s, et s\'arrête quand plus personne '
      'n\'écoute', () {
    fakeAsync((async) {
      final container = ProviderContainer(
        overrides: [meetingRepositoryProvider.overrideWithValue(repository)],
        retry: noRetry,
      );
      final subscription = container.listen(
        nowRunningProvider(1453),
        (_, _) {},
      );
      async.flushMicrotasks();
      verify(() => repository.getProgramme(1453)).called(1);

      async.elapse(programmeRefresh);
      async.flushMicrotasks();
      verify(() => repository.getProgramme(1453)).called(1);

      subscription.close();
      async.elapse(programmeRefresh * 3);
      async.flushMicrotasks();
      verifyNever(() => repository.getProgramme(1453));

      container.dispose();
    });
  });
}
