import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class UserPreferencesService extends GetxService {
  UserPreferencesService(this._storage);

  static const _favoritesKey = 'favorite_competitions';
  static const _lastViewedKey = 'last_viewed_competitions';
  static const _lastViewedCap = 20;

  final FlutterSecureStorage _storage;
  final RxSet<int> favoriteIds = <int>{}.obs;
  final RxList<int> lastViewedIds = <int>[].obs; // newest first

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
    await _storage.write(
      key: _favoritesKey,
      value: jsonEncode(favoriteIds.toList()),
    );
  }

  Future<void> recordView(int id) async {
    final updated = [id, ...lastViewedIds.where((existing) => existing != id)];
    if (updated.length > _lastViewedCap) {
      updated.removeRange(_lastViewedCap, updated.length);
    }
    lastViewedIds.value = updated;
    await _storage.write(
      key: _lastViewedKey,
      value: jsonEncode(updated),
    );
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
