import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';

class InitialBinding {
  InitialBinding._();

  static Future<void> register() async {
    Get.put<AppConfig>(AppConfig.fromEnv(), permanent: true);

    Get.put<FlutterSecureStorage>(
      const FlutterSecureStorage(),
      permanent: true,
    );

    Get.put<TokenStorage>(
      TokenStorage(Get.find<FlutterSecureStorage>()),
      permanent: true,
    );

    Get.put<HttpClient>(
      HttpClient(
        config: Get.find<AppConfig>(),
        tokenStorage: Get.find<TokenStorage>(),
      ),
      permanent: true,
    );
  }
}
