import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/meeting_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import '../controllers/meeting_editor_controller.dart';

class MeetingEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MeetingEditorController>(
      () => MeetingEditorController(
        Get.find<MeetingService>(),
        Get.find<MeetingRepository>(),
        Get.find<ProgrammeService>(),
        Get.find<UserService>(),
      ),
    );
  }
}
