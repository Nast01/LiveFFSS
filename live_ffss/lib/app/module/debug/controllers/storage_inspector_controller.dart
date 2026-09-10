import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';

class StorageEntry {
  const StorageEntry({required this.key, required this.value});

  final String key;
  final String value;

  int get sizeInBytes => utf8.encode(value).length;
}

/// Ce que le téléphone garde, rangé par propriétaire.
class StorageInspectorController extends GetxController {
  StorageInspectorController(this._storage, this._config);

  final FlutterSecureStorage _storage;
  final AppConfig _config;

  final RxBool isLoading = false.obs;
  final RxList<StorageEntry> currentEnvironment = <StorageEntry>[].obs;
  final RxList<StorageEntry> otherEnvironment = <StorageEntry>[].obs;
  final RxList<StorageEntry> global = <StorageEntry>[].obs;

  AppEnvironment get environment => _config.environment;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final all = await _storage.readAll();
      final mine = <StorageEntry>[];
      final theirs = <StorageEntry>[];
      final globals = <StorageEntry>[];
      for (final raw in all.entries) {
        final entry = StorageEntry(key: raw.key, value: raw.value);
        final owner = AppEnvironment.owner(raw.key);
        if (owner == null) {
          globals.add(entry);
        } else if (owner == _config.environment) {
          mine.add(entry);
        } else {
          theirs.add(entry);
        }
      }
      for (final list in [mine, theirs, globals]) {
        list.sort((a, b) => a.key.compareTo(b.key));
      }
      currentEnvironment.assignAll(mine);
      otherEnvironment.assignAll(theirs);
      global.assignAll(globals);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
    await load();
  }

  /// Ré-indente si la valeur parse en JSON : c'est ce qui rend un blob
  /// `programme_412` lisible. La copie, elle, emporte la chaîne brute, pour
  /// qu'elle puisse être ré-injectée telle quelle.
  static String prettify(String raw) {
    try {
      return const JsonEncoder.withIndent('  ').convert(jsonDecode(raw));
    } on FormatException {
      return raw;
    }
  }
}
