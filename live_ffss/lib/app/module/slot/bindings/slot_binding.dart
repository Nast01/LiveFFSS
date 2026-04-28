import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/result_repository.dart';
import '../controllers/slot_controller.dart';

class SlotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SlotController>(
      () => SlotController(Get.find<ResultRepository>()),
    );
  }
}
