import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/module/debug/controllers/http_log_controller.dart';

class HttpLogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HttpLogController>(
      () => HttpLogController(Get.find<FlutterSecureStorage>()),
    );
  }
}
