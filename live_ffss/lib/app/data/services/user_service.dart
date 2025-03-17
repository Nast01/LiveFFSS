import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';

class UserService extends GetxService {
  final FlutterSecureStorage _storage = Get.find<FlutterSecureStorage>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  Future<UserService> init() async {
    // Check if user is already logged in
    await checkUserSession();
    return this;
  }

  Future<void> checkUserSession() async {
    try {
      final token = await _storage.read(key: 'token');

      if (token != null) {
        final tokenExpirationDate =
            await _storage.read(key: 'tokenExpirationDate') ?? '';
        final label = await _storage.read(key: 'label') ?? '';
        final type = await _storage.read(key: 'type') ?? '';
        final role = await _storage.read(key: 'role') ?? '';
        final lastName = await _storage.read(key: 'lastName') ?? '';
        final firstName = await _storage.read(key: 'firstName') ?? '';
        final number = await _storage.read(key: 'number') ?? '';
        final club = await _storage.read(key: 'club') ?? '';

        currentUser.value = UserModel(
          token: token,
          tokenExpirationDate: DateTime.parse(tokenExpirationDate),
          label: label,
          type: type,
          role: role,
          lastName: lastName,
          firstName: firstName,
          number: number,
          club: club,
        );
      }
    } catch (e) {
      // Handle error or just reset currentUser
      currentUser.value = null;
    }
  }

  void setCurrentUser(UserModel user) {
    currentUser.value = user;
  }

  void clearCurrentUser() {
    currentUser.value = null;
  }

  bool get isLoggedIn => currentUser.value != null;

  String? get userFirstLetter {
    if (!isLoggedIn || currentUser.value!.label.isEmpty) return null;
    return currentUser.value!.label[0].toUpperCase();
  }
}
