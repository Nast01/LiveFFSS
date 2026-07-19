import 'package:get/get.dart';
import '../controllers/race_course_controller.dart';

class RaceCourseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RaceCourseController>(() => RaceCourseController());
  }
}
