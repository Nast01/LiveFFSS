import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/core/network/http_log.dart';

/// L'écran du journal HTTP. Le tampon vit hors de GetX ; ce contrôleur n'en
/// tient qu'un instantané, rafraîchi à la demande.
class HttpLogController extends GetxController {
  HttpLogController(this._storage);

  final FlutterSecureStorage _storage;

  final RxBool isEnabled = false.obs;
  final RxList<HttpLogEntry> entries = <HttpLogEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    isEnabled.value = httpLog.enabled;
    refreshEntries();
  }

  void refreshEntries() => entries.assignAll(httpLog.entries);

  Future<void> setEnabled(bool value) async {
    httpLog.enabled = value;
    isEnabled.value = value;
    await _storage.write(
      key: AppEnvironment.httpLogKey,
      value: value.toString(),
    );
  }

  void clear() {
    httpLog.clear();
    refreshEntries();
  }
}
