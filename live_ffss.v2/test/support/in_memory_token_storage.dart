import 'package:flutter/services.dart';
import 'package:live_ffss_v2/core/network/token_storage.dart';

/// Le jeton dans une variable, pour tester la session sans stockage sécurisé.
class InMemoryTokenStorage implements TokenStorage {
  String? token;

  /// Fait lever à chaque accès l'erreur d'un stockage sécurisé en panne.
  bool failing = false;

  void _check() {
    if (failing) throw PlatformException(code: 'keystore');
  }

  @override
  Future<String?> getToken() async {
    _check();
    return token;
  }

  @override
  Future<void> setToken(String token) async {
    _check();
    this.token = token;
  }

  @override
  Future<void> clearToken() async {
    _check();
    token = null;
  }
}
