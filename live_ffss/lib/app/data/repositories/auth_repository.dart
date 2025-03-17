import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider _authProvider = AuthProvider();
  final FlutterSecureStorage _storage = Get.find<FlutterSecureStorage>();

  Future<UserModel?> login(String id, String password) async {
    final user = await _authProvider.login(id, password);

    // Store user data securely
    await _storage.write(key: 'token', value: user?.token);
    await _storage.write(
        key: 'tokenExpirationDate',
        value: user?.tokenExpirationDate.toString());
    await _storage.write(key: 'label', value: user?.label);
    await _storage.write(key: 'type', value: user?.type);
    await _storage.write(key: 'role', value: user?.role);
    await _storage.write(key: 'lastName', value: user?.lastName);
    await _storage.write(key: 'firstName', value: user?.firstName);
    await _storage.write(key: 'number', value: user?.number);
    await _storage.write(key: 'club', value: user?.club);

    return user;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null;
  }
}
