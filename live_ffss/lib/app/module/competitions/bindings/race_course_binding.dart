import 'package:get/get.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import '../controllers/race_course_controller.dart';

class RaceCourseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RaceCourseController>(
      () => RaceCourseController(
        Get.find<ProgrammeService>(),
        Get.find<RaceRepository>(),
        Get.find<ClubRepository>(),
        Get.find<RfidWriter>(),
        Get.find<MeetingRepository>(),
      ),
    );
  }
}
