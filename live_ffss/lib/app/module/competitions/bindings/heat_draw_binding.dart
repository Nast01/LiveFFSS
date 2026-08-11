import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/attendance_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import '../controllers/heat_draw_controller.dart';

class HeatDrawBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HeatDrawController>(
      () => HeatDrawController(
        Get.find<RaceRepository>(),
        Get.find<AttendanceService>(),
        Get.find<ProgrammeService>(),
      ),
    );
  }
}
