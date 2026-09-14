import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/meeting_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import '../controllers/meeting_form_controller.dart';

class MeetingFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MeetingFormController>(
      () => MeetingFormController(
        Get.find<MeetingService>(),
        Get.find<MeetingRepository>(),
        Get.find<ProgrammeService>(),
        Get.find<UserService>(),
      ),
    );
  }
}
