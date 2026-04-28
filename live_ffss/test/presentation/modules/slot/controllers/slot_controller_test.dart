import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/result_repository.dart';
import 'package:live_ffss/app/domain/models/live_result.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/slot.dart';
import 'package:live_ffss/app/module/slot/controllers/slot_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockResultRepo extends Mock implements ResultRepository {}

Run makeRun(int id) => Run(
      id: id,
      name: 'R$id',
      label: 'L$id',
      fullLabel: 'FL$id',
      status: RunStatus.waiting,
      statusLabel: 'Waiting',
      site: 'X',
      beginTime: DateTime(2026, 5, 1, 10),
      endTime: DateTime(2026, 5, 1, 11),
    );

Slot makeSlot({required List<Run> runs}) => Slot(
      id: 1,
      name: 'S',
      beginHour: DateTime(2026, 5, 1, 10),
      endHour: DateTime(2026, 5, 1, 12),
      runs: runs,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockResultRepo repo;
  late SlotController controller;

  setUp(() {
    repo = _MockResultRepo();
    Get.testMode = true;
    controller = SlotController(repo);
  });

  tearDown(() {
    Get.reset();
  });

  group('SlotController.loadAllRunResults', () {
    test('keys runResults by runId, not list index', () async {
      controller.slot.value = makeSlot(runs: [makeRun(101), makeRun(202)]);
      when(() => repo.getRunResults(101))
          .thenAnswer((_) async => const <LiveResult>[]);
      when(() => repo.getRunResults(202))
          .thenAnswer((_) async => const <LiveResult>[]);

      await controller.loadAllRunResults();

      // Keyed by run id.
      expect(controller.runResults.containsKey(101), isTrue);
      expect(controller.runResults.containsKey(202), isTrue);
      // NOT keyed by list index.
      expect(controller.runResults.containsKey(0), isFalse);
      expect(controller.runResults.containsKey(1), isFalse);
    });

    test('on UnimplementedError, sets empty list and does not throw',
        () async {
      controller.slot.value = makeSlot(runs: [makeRun(1)]);
      when(() => repo.getRunResults(any()))
          .thenThrow(UnimplementedError('TBD'));

      await controller.loadAllRunResults();

      expect(controller.runResults[1], isEmpty);
      expect(controller.isLoading.value, false);
    });

    test('on success populates runResults', () async {
      controller.slot.value = makeSlot(runs: [makeRun(1)]);
      const sample = LiveResult(id: 99, number: '5');
      when(() => repo.getRunResults(1))
          .thenAnswer((_) async => const [sample]);

      await controller.loadAllRunResults();

      expect(controller.runResults[1], hasLength(1));
      expect(controller.runResults[1]!.first.id, 99);
    });
  });

  group('SlotController bottom tab', () {
    test('onBottomTabChanged updates currentBottomTabIndex', () {
      controller.onBottomTabChanged(1);
      expect(controller.currentBottomTabIndex.value, 1);
    });
  });
}
