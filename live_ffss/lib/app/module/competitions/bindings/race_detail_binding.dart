import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import '../controllers/race_detail_controller.dart';
import '../controllers/race_structure_controller.dart';

class RaceDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RaceDetailController>(
      () => RaceDetailController(
        Get.find<RaceRepository>(),
        Get.find<ClubRepository>(),
      ),
    );
    Get.lazyPut<RaceStructureController>(
      () => RaceStructureController(
        Get.find<ProgrammeService>(),
        Get.find<RaceRepository>(),
      ),
    );
  }
}
