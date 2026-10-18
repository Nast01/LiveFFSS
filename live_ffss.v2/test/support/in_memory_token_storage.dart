import 'package:live_ffss_v2/core/network/token_storage.dart';

/// Le jeton dans une variable, pour tester la session sans stockage sécurisé.
class InMemoryTokenStorage implements TokenStorage {
  String? token;

  @override
  Future<String?> getToken() async => token;

  @override
  Future<void> setToken(String token) async => this.token = token;

  @override
  Future<void> clearToken() async => token = null;
}
