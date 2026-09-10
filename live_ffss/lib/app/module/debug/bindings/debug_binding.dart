import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/module/debug/controllers/debug_controller.dart';

class DebugBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DebugController>(
      () => DebugController(Get.find<AppConfig>()),
    );
  }
}
