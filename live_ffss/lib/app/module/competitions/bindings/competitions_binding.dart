import 'package:get/get.dart';
import '../controllers/competitions_controller.dart';

class CompetitionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompetitionsController>(() => CompetitionsController());
  }
}
