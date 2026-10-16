import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/providers.dart';

/// Les compétitions favorites, gardées sur l'appareil.
class FavoritesNotifier extends AsyncNotifier<Set<int>> {
  static const storageKey = 'favorite_competitions';

  @override
  Future<Set<int>> build() async =>
      _decode(await ref.watch(localStoreProvider).read(storageKey));

  Future<void> toggle(int id) async {
    final next = {...(state.value ?? await future)};
    if (!next.remove(id)) next.add(id);
    state = AsyncData(next);
    await ref
        .read(localStoreProvider)
        .write(storageKey, jsonEncode(next.toList()..sort()));
  }

  /// Une valeur illisible vaut « aucun favori » : perdre des favoris est
  /// moins grave qu'un accueil qui ne s'ouvre plus.
  static Set<int> _decode(String? raw) {
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      return decoded is List ? decoded.whereType<int>().toSet() : {};
    } on FormatException {
      return {};
    }
  }
}

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, Set<int>>(
  FavoritesNotifier.new,
);
