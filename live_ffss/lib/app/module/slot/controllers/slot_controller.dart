import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/data/models/athlete_model.dart';
import 'package:live_ffss/app/data/models/slot_model.dart';
import 'package:live_ffss/app/data/models/run_model.dart';
import 'package:live_ffss/app/data/models/live_result_model.dart';
import 'package:live_ffss/app/data/services/api_service.dart';
import 'package:live_ffss/app/module/slot/views/beach_ranking_dialog.dart';

class SlotController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();

  late TabController tabController;

  Rxn<SlotModel> slot = Rxn<SlotModel>();
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Current selected run index
  final RxInt currentRunIndex = 0.obs;

  // Bottom navigation index (0: Results, 1: Athletes)
  final RxInt currentBottomTabIndex = 0.obs;

  // Live results for each run
  final RxMap<int, List<LiveResultModel>> runResults =
      <int, List<LiveResultModel>>{}.obs;

  // All athletes in the slot (from all runs)
  final RxList<AthleteModel> allAthletes = <AthleteModel>[].obs;

  // Form controllers for result entry
  final RxBool isUpdatingResults = false.obs;
  final RxBool isWithdrawingAthlete = false.obs;

  // Beach ranking data
  final RxMap<int, int> beachRankings = <int, int>{}.obs; // lane number -> rank

  // Swimming times data (up to 3 times per athlete)
  final RxMap<int, List<String>> swimmingTimes =
      <int, List<String>>{}.obs; // lane number -> [time1, time2, time3]

  @override
  void onInit() {
    super.onInit();

    // Get the slot from arguments
    slot.value = Get.arguments as SlotModel?;

    if (slot.value != null && slot.value!.runs.isNotEmpty) {
      // Initialize tab controller with the number of runs
      tabController =
          TabController(length: slot.value!.runs.length, vsync: this);

      // Load live results for all runs
      loadAllRunResults();

      // Load all athletes from the slot
      loadAllAthletes();
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> loadAllRunResults() async {
    if (slot.value == null) return;

    try {
      isLoading.value = true;
      hasError.value = false;

      // Load results for each run
      for (int i = 0; i < slot.value!.runs.length; i++) {
        final run = slot.value!.runs[i];
        await loadRunResults(run.id, i);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadRunResults(int runId, int runIndex) async {
    try {
      // This is a placeholder - you'll need to implement the actual API call
      // based on your backend API structure
      final results = await _loadRunResultsFromApi(runId);
      runResults[runIndex] = results;
    } catch (e) {
      // Handle individual run loading error
      runResults[runIndex] = [];
      debugPrint('Error loading results for run $runId: $e');
    }
  }

  // Placeholder method for API call - implement based on your actual API
  Future<List<LiveResultModel>> _loadRunResultsFromApi(int runId) async {
    // Use the actual API service method
    return List<LiveResultModel>.empty();
    //TODO: Uncomment and implement the actual API call
    //await _apiService.getRunResults(runId);
  }

  Future<void> refreshResults() async {
    await loadAllRunResults();
    await loadAllAthletes();
  }

  void goBack() {
    Get.back();
  }

  void onTabChanged(int index) {
    currentRunIndex.value = index;
  }

  void onBottomTabChanged(int index) {
    currentBottomTabIndex.value = index;
  }

  Future<void> loadAllAthletes() async {
    if (slot.value == null) return;

    try {
      Set<AthleteModel> athleteSet = {};

      // Collect athletes from all runs
      for (final run in slot.value!.runs) {
        final results = runResults[slot.value!.runs.indexOf(run)] ?? [];
        for (final result in results) {
          if (result.entry?.athletes.isNotEmpty == true) {
            athleteSet.addAll(result.entry!.athletes);
          }
        }
      }

      // Convert to list and sort by name
      allAthletes.value = athleteSet.toList()
        ..sort((a, b) => a.fullName.compareTo(b.fullName));
    } catch (e) {
      debugPrint('Error loading athletes: $e');
    }
  }

  // Check if current run is beach discipline
  bool get isBeachDiscipline {
    final run = currentRun;
    if (run == null || slot.value?.raceFormatDetailModel == null) return false;

    // Check if discipline is beach/coastal type
    return slot.value!.raceFormatDetailModel!.level
            .toLowerCase()
            .contains('côtier') ||
        slot.value!.raceFormatDetailModel!.level
            .toLowerCase()
            .contains('beach') ||
        slot.value!.raceFormatDetailModel!.level
            .toLowerCase()
            .contains('coastal');
  }

  // Check if current run is swimming discipline
  bool get isSwimmingDiscipline {
    final run = currentRun;
    if (run == null || slot.value?.raceFormatDetailModel == null) return false;

    // Check if discipline is swimming/pool type
    return slot.value!.raceFormatDetailModel!.level
            .toLowerCase()
            .contains('eau-plate') ||
        slot.value!.raceFormatDetailModel!.level
            .toLowerCase()
            .contains('swimming') ||
        slot.value!.raceFormatDetailModel!.level
            .toLowerCase()
            .contains('piscine');
  }

  void openResultEntryDialog() {
    if (isBeachDiscipline) {
      _openBeachRankingDialog();
    } else if (isSwimmingDiscipline) {
      _openSwimmingTimesDialog();
    }
  }

  void _openBeachRankingDialog() {
    // Initialize beach rankings if empty
    final currentResults = currentRunResults;
    if (beachRankings.isEmpty) {
      for (int i = 0; i < currentResults.length; i++) {
        final result = currentResults[i];
        final laneNumber = int.tryParse(result.number) ?? (i + 1);
        beachRankings[laneNumber] = result.currentRank ?? 0;
      }
    }

    //TODO: Use the actual dialog view
    // Get.dialog(
    //   BeachRankingDialog(),
    //   barrierDismissible: false,
    // );
  }

  void _openSwimmingTimesDialog() {
    // Initialize swimming times if empty
    final currentResults = currentRunResults;
    if (swimmingTimes.isEmpty) {
      for (int i = 0; i < currentResults.length; i++) {
        final result = currentResults[i];
        final laneNumber = int.tryParse(result.number) ?? (i + 1);
        swimmingTimes[laneNumber] = ['', '', '']; // 3 empty time slots
      }
    }

    //TODO: Use the actual dialog view
    // Get.dialog(
    //   _SwimmingTimesDialog(controller: this),
    //   barrierDismissible: false,
    // );
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
    try {
      isUpdatingResults.value = true;

      if (isBeachDiscipline) {
        await _saveBeachRankings();
      } else if (isSwimmingDiscipline) {
        await _saveSwimmingTimes();
      }

      Get.back(); // Close dialog
      Get.snackbar(
        'success'.tr,
        'results_updated_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );

      // Refresh results
      await refreshResults();
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_update_results'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isUpdatingResults.value = false;
    }
  }

  Future<void> _saveBeachRankings() async {
    // Use the actual API service method
    final success = false;
    //TODO - Uncomment and implement the actual API call
    // await _apiService.updateBeachRankings(currentRun!.id, beachRankings);
    if (!success) {
      throw Exception('Failed to save beach rankings');
    }
  }

  Future<void> _saveSwimmingTimes() async {
    // Use the actual API service method
    final success = false;
    //TODO - Uncomment and implement the actual API call
    // await _apiService.updateSwimmingTimes(currentRun!.id, swimmingTimes);
    if (!success) {
      throw Exception('Failed to save swimming times');
    }
  }

  Future<void> withdrawAthlete(AthleteModel athlete) async {
    try {
      isWithdrawingAthlete.value = true;

      // Use the actual API service method
      final success = false;
      //TODO - Uncomment and implement the actual API call
      // await _apiService.withdrawAthlete(athlete.id, currentRun?.id ?? 0);
      if (!success) {
        throw Exception('Failed to withdraw athlete');
      }

      // Remove from local list
      allAthletes.remove(athlete);

      Get.snackbar(
        'success'.tr,
        'athlete_withdrawn_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );

      // Refresh data
      await refreshResults();
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_withdraw_athlete'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isWithdrawingAthlete.value = false;
    }
  }

  void showWithdrawAthleteDialog(AthleteModel athlete) {
    Get.dialog(
      AlertDialog(
        title: Text('withdraw_athlete'.tr),
        content: Text(
          '${'confirm_withdraw_athlete'.tr}: ${athlete.fullName}?',
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

  // Helper getters
  String get slotTitle =>
      slot.value?.raceFormatDetailModel?.fullLabel ?? slot.value?.name ?? '';

  String get slotTimeRange {
    if (slot.value == null) return '';
    return '${_formatTime(slot.value!.beginHour)} - ${_formatTime(slot.value!.endHour)}';
  }

  RunModel? get currentRun {
    if (slot.value == null ||
        currentRunIndex.value >= slot.value!.runs.length) {
      return null;
    }
    return slot.value!.runs[currentRunIndex.value];
  }

  List<LiveResultModel> get currentRunResults {
    return runResults[currentRunIndex.value] ?? [];
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
