import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
import 'package:live_ffss/app/data/models/competition_model.dart';
import 'package:live_ffss/app/data/repositories/competition_repository.dart';

class CompetitionsController extends GetxController {
  final CompetitionRepository _competitionRepository = CompetitionRepository();

  final RxList<CompetitionModel> competitions = <CompetitionModel>[].obs;
  final RxList<CompetitionModel> upcomingCompetitions =
      <CompetitionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxInt currentPage = 1.obs;
  final RxString errorMessage = ''.obs;

  // Filter variables
  final Rx<DateTime> selectedDate =
      DateTime.now().subtract(const Duration(days: 3)).obs;
  final Rx<CompetitionType> selectedType = CompetitionType.mixte.obs;
  final Rx<CompetitionVisibility> selectedVisibility =
      CompetitionVisibility.incoming.obs;

  // Scroll controller for pagination
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();

    // Setup scroll controller for pagination
    scrollController.addListener(_scrollListener);

    // Load initial data
    loadCompetitions();
    loadNext5UpcomingCompetitions();
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }

  // Scroll listener for pagination
  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (!isLoading.value && hasMoreData.value) {
        loadMoreCompetitions();
      }
    }
  }

  // Load competitions with current filters
  Future<void> loadCompetitions() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      currentPage.value = 1;
      hasMoreData.value = true;

      final result = await _competitionRepository.getCompetitions(
        type: selectedType.value,
        visibility: selectedVisibility.value,
        page: currentPage.value,
      );

      competitions.value = result;

      if (result.length < 10) {
        hasMoreData.value = false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Load more competitions (pagination)
  Future<void> loadMoreCompetitions() async {
    try {
      isLoading.value = true;
      currentPage.value++;

      final result = await _competitionRepository.getCompetitions(
        type: selectedType.value,
        visibility: selectedVisibility.value,
        page: currentPage.value,
      );

      if (result.isEmpty || result.length < 10) {
        hasMoreData.value = false;
      }

      competitions.addAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
      currentPage.value--;
    } finally {
      isLoading.value = false;
    }
  }

  // Load all competitions (handles pagination internally)
  Future<void> loadAllCompetitions() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _competitionRepository.getAllCompetitions(
        type: selectedType.value,
        visibility: selectedVisibility.value,
      );

      competitions.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Load next 5 upcoming competitions
  Future<void> loadNext5UpcomingCompetitions() async {
    try {
      final result = await _competitionRepository.getNext5Competitions();
      upcomingCompetitions.value = result;
    } catch (e) {
      debugPrint('Error loading upcoming competitions: $e');
      // We don't set error message here to avoid disrupting the main view
    }
  }

  // Change filters and reload data
  void changeFilters({
    CompetitionType? type,
    CompetitionVisibility? visibility,
  }) {
    if (type != null) selectedType.value = type;
    if (visibility != null) selectedVisibility.value = visibility;

    loadCompetitions();
  }

  // Reset filters to default
  void resetFilters() {
    selectedType.value = CompetitionType.mixte;
    selectedVisibility.value = CompetitionVisibility.incoming;

    loadCompetitions();
  }
}
