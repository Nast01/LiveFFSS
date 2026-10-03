import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';

class UserPreferencesService extends GetxService {
  UserPreferencesService(
    this._storage, {
    AppEnvironment environment = AppEnvironment.production,
  })  : _favoritesKey = '${environment.storagePrefix}favorite_competitions',
        _lastViewedKey = '${environment.storagePrefix}last_viewed_competitions';

  final String _favoritesKey;
  final String _lastViewedKey;

  static const _lastViewedCap = 20;

  final FlutterSecureStorage _storage;
  final RxSet<int> favoriteIds = <int>{}.obs;
  final RxList<int> lastViewedIds = <int>[].obs; // newest first

  /// Sérialise les écritures, comme `AttendanceService` le fait déjà pour la
  /// même raison : deux bascules enchaînées calculent chacune sa charge utile
  /// correctement, mais rien ne garantissait leur ordre d'arrivée sur le
  /// disque — et la plus ancienne pouvait atterrir en dernier, remettant le
  /// favori que l'opérateur venait de retirer.
  Future<void> _writeQueue = Future.value();

  /// L'échec d'une écriture ne condamne pas les suivantes : la chaîne
  /// repart, et l'appelant garde l'erreur de la sienne.
  Future<void> _enqueueWrite(String key, String payload) {
    Future<void> write() => _storage.write(key: key, value: payload);
    final queued = _writeQueue.then((_) => write(), onError: (_) => write());
    _writeQueue = queued.catchError((Object _) {});
    return queued;
  }

  Future<UserPreferencesService> init() async {
    favoriteIds.assignAll((await _readIds(_favoritesKey)).toSet());
    lastViewedIds.value = await _readIds(_lastViewedKey);
    return this;
  }

  bool isFavorite(int id) => favoriteIds.contains(id);

  Future<void> toggleFavorite(int id) async {
    if (favoriteIds.contains(id)) {
      favoriteIds.remove(id);
    } else {
      favoriteIds.add(id);
    }
    await _enqueueWrite(_favoritesKey, jsonEncode(favoriteIds.toList()));
  }

  Future<void> recordView(int id) async {
    final updated = [id, ...lastViewedIds.where((existing) => existing != id)];
    if (updated.length > _lastViewedCap) {
      updated.removeRange(_lastViewedCap, updated.length);
    }
    lastViewedIds.value = updated;
    await _enqueueWrite(_lastViewedKey, jsonEncode(updated));
  }

  Future<List<int>> _readIds(String key) async {
    final raw = await _storage.read(key: key);
    if (raw == null || raw.isEmpty) return <int>[];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<int>();
    } catch (_) {
      // Corrupt or unexpected payload — treat as absent; the next write self-heals.
      return <int>[];
    }
  }
}
