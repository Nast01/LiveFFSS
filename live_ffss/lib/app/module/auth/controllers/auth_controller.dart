import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/domain/models/user.dart';

enum AuthEvent { loggedIn, loggedOut }

class AuthController extends GetxController {
  AuthController(this._auth);

  final AuthRepository _auth;

  final Rxn<User> user = Rxn<User>();
  final RxBool isLoading = false.obs;
  final Rxn<AppException> error = Rxn<AppException>();
  final Rxn<AuthEvent> event = Rxn<AuthEvent>();

  Future<void> login({
    required String login,
    required String password,
  }) async {
    isLoading.value = true;
    error.value = null;
    try {
      user.value = await _auth.login(login: login, password: password);
      event.value = AuthEvent.loggedIn;
    } on AppException catch (e) {
      error.value = e;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.logout();
      user.value = null;
      event.value = AuthEvent.loggedOut;
    } on AppException catch (e) {
      error.value = e;
    }
  }
}
