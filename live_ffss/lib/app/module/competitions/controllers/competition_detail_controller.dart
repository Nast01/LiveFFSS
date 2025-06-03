import 'package:get/get.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/data/models/competition_model.dart';
import 'package:live_ffss/app/data/services/api_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';

class CompetitionDetailController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final LanguageService _languageService = Get.find<LanguageService>();
  final ApiService _apiService = Get.find<ApiService>();

  final Rxn<CompetitionModel> competition = Rxn<CompetitionModel>();
}
