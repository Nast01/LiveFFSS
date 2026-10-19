import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Une requête FFSS, telle que l'admin la voit. Rien de ce qui pourrait
/// identifier quelqu'un n'y entre : ni adresse complète, ni jeton, ni corps.
@immutable
class NetworkLogEntry {
  const NetworkLogEntry({
    required this.at,
    required this.method,
    required this.path,
    required this.duration,
    required this.server,
    this.status,
    this.bytes,
    this.error,
  });

  final DateTime at;
  final String method;

  /// Le chemin résolu, sans chaîne de requête.
  final String path;

  /// Absent quand rien n'est revenu du serveur (hors ligne, délai dépassé).
  final int? status;
  final Duration duration;
  final int? bytes;

  /// Le type de l'`AppException` levée (`NetworkException`, `ApiException`…).
  final String? error;

  /// Le libellé du serveur qui a reçu la requête.
  final String server;

  bool get failed => error != null;
}

/// Le journal lui-même, borné. Il n'appartient à aucun conteneur : changer de
/// serveur jette le conteneur, et le journal doit couvrir toute la vie de
/// l'app. La racine (`AppContainerHost`) le crée une fois et le prête à
/// chaque conteneur.
class NetworkLogStore extends ChangeNotifier {
  static const int limit = 200;

  List<NetworkLogEntry> _entries = const [];

  /// Le plus récent d'abord.
  List<NetworkLogEntry> get entries => _entries;

  void add(NetworkLogEntry entry) {
    _entries = [entry, ..._entries.take(limit - 1)];
    notifyListeners();
  }

  void clear() {
    _entries = const [];
    notifyListeners();
  }
}

final networkLogStoreProvider = Provider<NetworkLogStore>(
  (ref) => NetworkLogStore(),
);

/// Les entrées du journal, plus récente d'abord, 200 au plus.
final networkLogProvider =
    NotifierProvider<NetworkLogNotifier, List<NetworkLogEntry>>(
      NetworkLogNotifier.new,
    );

class NetworkLogNotifier extends Notifier<List<NetworkLogEntry>> {
  @override
  List<NetworkLogEntry> build() {
    final store = ref.watch(networkLogStoreProvider);
    void sync() => state = store.entries;
    store.addListener(sync);
    ref.onDispose(() => store.removeListener(sync));
    return store.entries;
  }

  void clear() => ref.read(networkLogStoreProvider).clear();
}
