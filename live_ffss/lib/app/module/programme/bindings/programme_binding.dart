import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/repositories/race_format_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/meeting_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import '../controllers/meeting_list_controller.dart';
import '../controllers/programme_controller.dart';

class ProgrammeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgrammeController>(
      () => ProgrammeController(
        Get.find<RaceRepository>(),
        Get.find<ProgrammeService>(),
        Get.find<RaceFormatRepository>(),
        Get.find<UserService>(),
      ),
    );
    Get.lazyPut<MeetingListController>(
      () => MeetingListController(
        Get.find<MeetingService>(),
        Get.find<MeetingRepository>(),
        Get.find<ProgrammeService>(),
        Get.find<UserService>(),
      ),
    );
  }
}
