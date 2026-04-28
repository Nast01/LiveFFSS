import 'package:get/get.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import '../controllers/competition_detail_clubs_controller.dart';
import '../controllers/competition_detail_controller.dart';
import '../controllers/competition_detail_races_controller.dart';

class CompetitionDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompetitionDetailController>(
      () => CompetitionDetailController(Get.find<LanguageService>()),
    );
    Get.lazyPut<CompetitionDetailRacesController>(
      () => CompetitionDetailRacesController(Get.find<RaceRepository>()),
    );
    Get.lazyPut<CompetitionDetailClubsController>(
      () => CompetitionDetailClubsController(Get.find<ClubRepository>()),
    );
  }
}
