import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import '../controllers/programme_controller.dart';

class ProgrammeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgrammeController>(
      () => ProgrammeController(
        Get.find<RaceRepository>(),
        Get.find<ProgrammeService>(),
      ),
    );
  }
}
