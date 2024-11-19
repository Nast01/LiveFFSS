import 'package:get/get.dart';
import 'package:live_ffss/src/model/competition.dart';
import 'package:live_ffss/src/model/token.dart';
import 'package:live_ffss/src/services/authentication_service.dart';
import 'package:live_ffss/src/services/competition_service.dart';

class AuthenticationController extends GetxController {
  final AuthenticationService _authService = AuthenticationService();
  final CompetitionService _compService = CompetitionService();
  var isAuthenticated = false.obs;
  var errorMessage = ''.obs;
  var token = Rx<Token?>(null);
  set login(String login) {}

  Future<void> authenticate(String login, String password) async {
    try {
      final response = await _authService.authenticate(login, password);
      if (response != null) {
        token.value = response;
        isAuthenticated.value = token.value!.status;
        // Store the access token or other response data for future use
      } else {
        errorMessage.value = 'Authentication failed';
      }
    } on Exception catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      update(); // Update the UI to reflect changes
    }
  }

  Future<void> getCompetitionList()async {
    const login = "skr";
    const password = "skr123@";
    
    await authenticate(login, password);

    if(token.value?.status == true){
      List<Competition>? comps = await _compService.getCompetionList(token.value);

    }
  }
}