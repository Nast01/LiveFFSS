import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import '../controllers/program_controller.dart';

class ProgramBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgramController>(
      () => ProgramController(Get.find<MeetingRepository>()),
    );
  }
}
