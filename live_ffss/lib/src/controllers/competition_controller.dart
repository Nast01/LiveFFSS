import 'package:get/get.dart';
import 'package:live_ffss/src/controllers/authentication_controller.dart';
import 'package:live_ffss/src/model/competition.dart';
import 'package:live_ffss/src/services/competition_service.dart';

class CompetitionController extends GetxController {
  final CompetitionService _competitionService = CompetitionService();
  final AuthenticationController _authenticationController =
      AuthenticationController();

  var competitionList = <Competition>[].obs;
  var isLoading = false.obs;

  var competitionCount = 0.obs;

  @override
  void onInit() {
    super.onInit();

    fetchCompetitions();
  }

  Future<void> fetchCompetitions() async {
    isLoading.value = true; // Show loading state

    try {
      await _authenticationController.authenticate("", "");
      if (_authenticationController.token.value?.status == true) {
        // Call the service to fetch competitions
        competitionList.value = await _competitionService
            .fetchCompetitions(_authenticationController.token.value);

        competitionList.sort((a, b) => a.beginDate.compareTo(b.beginDate));
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
