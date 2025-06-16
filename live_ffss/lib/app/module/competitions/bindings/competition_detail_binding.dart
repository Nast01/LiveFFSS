import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/api_service.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_clubs_controller.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_races_controller.dart';
import '../controllers/competition_detail_controller.dart';

class CompetitionDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut<CompetitionDetailController>(
        () => CompetitionDetailController());
    Get.lazyPut<CompetitionDetailClubsController>(
        () => CompetitionDetailClubsController());
    Get.lazyPut<CompetitionDetailRacesController>(
        () => CompetitionDetailRacesController());
  }
}
