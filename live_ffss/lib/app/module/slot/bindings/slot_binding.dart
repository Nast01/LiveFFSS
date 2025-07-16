import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/api_service.dart';
import 'package:live_ffss/app/module/slot/controllers/slot_controller.dart';

class SlotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut<SlotController>(() => SlotController());
  }
}
