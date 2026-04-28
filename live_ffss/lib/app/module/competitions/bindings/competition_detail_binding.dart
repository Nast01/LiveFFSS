import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_clubs_controller.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_races_controller.dart';
import '../controllers/competition_detail_controller.dart';

class CompetitionDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompetitionDetailController>(
        () => CompetitionDetailController());
    Get.lazyPut<CompetitionDetailClubsController>(
        () => CompetitionDetailClubsController(Get.find<ClubRepository>()));
    Get.lazyPut<CompetitionDetailRacesController>(
        () => CompetitionDetailRacesController(Get.find<RaceRepository>()));
  }
}
