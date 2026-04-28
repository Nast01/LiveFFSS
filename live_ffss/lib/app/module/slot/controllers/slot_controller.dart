import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/result_repository.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/live_result.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/slot.dart';

class SlotController extends GetxController
    with GetSingleTickerProviderStateMixin {
  SlotController(this._results);

  final ResultRepository _results;

  TabController? tabController;

  final Rxn<Slot> slot = Rxn<Slot>();
  final RxBool isLoading = false.obs;
  final Rxn<AppException> error = Rxn<AppException>();

  final RxInt currentRunIndex = 0.obs;
  final RxInt currentBottomTabIndex = 0.obs;

  // Keyed by runId — was list-index in legacy (spec bug #8 fix).
  final RxMap<int, List<LiveResult>> runResults =
      <int, List<LiveResult>>{}.obs;
  final RxList<Athlete> allAthletes = <Athlete>[].obs;

  final RxBool isUpdatingResults = false.obs;
  final RxBool isWithdrawingAthlete = false.obs;
  final RxMap<int, int> beachRankings = <int, int>{}.obs;
  final RxMap<int, List<String>> swimmingTimes =
      <int, List<String>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Slot) {
      slot.value = arg;
      if (arg.runs.isNotEmpty) {
        tabController = TabController(length: arg.runs.length, vsync: this);
        loadAllRunResults();
      }
    }
  }

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }

  Future<void> loadAllRunResults() async {
    final s = slot.value;
    if (s == null) return;
    isLoading.value = true;
    error.value = null;
    try {
      for (final run in s.runs) {
        try {
          runResults[run.id] = await _results.getRunResults(run.id);
        } on UnimplementedError {
          runResults[run.id] = const [];
        } on AppException catch (e) {
          runResults[run.id] = const [];
          error.value = e;
        }
      }
      _refreshAthletes();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshResults() => loadAllRunResults();

  void goBack() {
    Get.back();
  }

  void onTabChanged(int index) {
    currentRunIndex.value = index;
  }

  void onBottomTabChanged(int index) {
    currentBottomTabIndex.value = index;
  }

  void _refreshAthletes() {
    final athletes = <Athlete>{};
    for (final list in runResults.values) {
      for (final lr in list) {
        if (lr.entry != null) athletes.addAll(lr.entry!.athletes);
      }
    }
    allAthletes.value = athletes.toList()
      ..sort((a, b) =>
          '${a.firstName} ${a.lastName}'.compareTo('${b.firstName} ${b.lastName}'));
  }

  // Discipline checks — string-matching preserved (TODO(batch-6): typed enum).
  bool get isBeachDiscipline {
    final level = slot.value?.raceFormatDetail?.level.toLowerCase();
    if (level == null) return false;
    return level.contains('côtier') ||
        level.contains('beach') ||
        level.contains('coastal');
  }

  bool get isSwimmingDiscipline {
    final level = slot.value?.raceFormatDetail?.level.toLowerCase();
    if (level == null) return false;
    return level.contains('eau-plate') ||
        level.contains('swimming') ||
        level.contains('piscine');
  }

  void openResultEntryDialog() {
    // TODO(batch-6): wire BeachRankingDialog / SwimTimeDialog when the
    // backend mutation endpoints are documented. Currently dead code.
  }

  void updateBeachRanking(int laneNumber, int rank) {
    beachRankings[laneNumber] = rank;
  }

  void updateSwimmingTime(int laneNumber, int timeIndex, String time) {
    if (!swimmingTimes.containsKey(laneNumber)) {
      swimmingTimes[laneNumber] = ['', '', ''];
    }
    swimmingTimes[laneNumber]![timeIndex] = time;
  }

  Future<void> saveResults() async {
    final run = currentRun;
    if (run == null) return;
    try {
      isUpdatingResults.value = true;
      // TODO(batch-6): wire to FFSS backend once endpoint is documented.
      if (isBeachDiscipline) {
        await _results.updateBeachRankings(run.id, beachRankings);
      } else if (isSwimmingDiscipline) {
        await _results.updateSwimmingTimes(run.id, swimmingTimes);
      }
      _showSuccessSnackbar('results_updated_successfully');
      await refreshResults();
    } on UnimplementedError {
      _showErrorSnackbar('feature_not_yet_available');
    } catch (_) {
      _showErrorSnackbar('failed_to_update_results');
    } finally {
      isUpdatingResults.value = false;
    }
  }

  Future<void> withdrawAthlete(Athlete athlete) async {
    final run = currentRun;
    if (run == null) return;
    try {
      isWithdrawingAthlete.value = true;
      // TODO(batch-6): wire to FFSS backend once endpoint is documented.
      await _results.withdrawAthlete(athleteId: athlete.id, runId: run.id);
      allAthletes.remove(athlete);
      _showSuccessSnackbar('athlete_withdrawn_successfully');
      await refreshResults();
    } on UnimplementedError {
      _showErrorSnackbar('feature_not_yet_available');
    } catch (_) {
      _showErrorSnackbar('failed_to_withdraw_athlete');
    } finally {
      isWithdrawingAthlete.value = false;
    }
  }

  void showWithdrawAthleteDialog(Athlete athlete) {
    // TODO(batch-6): pure UI — view should host this dialog.
    Get.dialog(
      AlertDialog(
        title: Text('withdraw_athlete'.tr),
        content: Text(
          '${'confirm_withdraw_athlete'.tr}: ${athlete.firstName} ${athlete.lastName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              withdrawAthlete(athlete);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
              foregroundColor: Get.theme.colorScheme.onError,
            ),
            child: Text('withdraw'.tr),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(String key) {
    // TODO(batch-6): replace with Rxn<UiMessage> dispatch.
    Get.snackbar(
      'success'.tr,
      key.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }

  void _showErrorSnackbar(String key) {
    Get.snackbar(
      'error'.tr,
      key.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }

  String get slotTitle =>
      slot.value?.raceFormatDetail?.fullLabel ?? slot.value?.name ?? '';

  String get slotTimeRange {
    final s = slot.value;
    if (s == null) return '';
    return '${_formatTime(s.beginHour)} - ${_formatTime(s.endHour)}';
  }

  Run? get currentRun {
    final s = slot.value;
    if (s == null || currentRunIndex.value >= s.runs.length) return null;
    return s.runs[currentRunIndex.value];
  }

  List<LiveResult> get currentRunResults =>
      runResults[currentRun?.id] ?? const [];

  String _formatTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
