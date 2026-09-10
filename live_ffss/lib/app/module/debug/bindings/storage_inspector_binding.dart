import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/module/debug/controllers/storage_inspector_controller.dart';

class StorageInspectorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StorageInspectorController>(
      () => StorageInspectorController(
        Get.find<FlutterSecureStorage>(),
        Get.find<AppConfig>(),
      ),
    );
  }
}
