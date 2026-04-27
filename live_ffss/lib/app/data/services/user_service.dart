import 'dart:async';

import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/domain/models/user.dart';

class UserService extends GetxService {
  UserService(this._auth);

  final AuthRepository _auth;
  final Rx<User?> currentUser = Rx<User?>(null);
  StreamSubscription<User?>? _sub;

  Future<UserService> init() async {
    currentUser.value = await _auth.restoreSession();
    _sub = _auth.userStream.listen((user) => currentUser.value = user);
    return this;
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  bool get isLoggedIn => currentUser.value != null;

  String? get userFirstLetter {
    final u = currentUser.value;
    if (u == null || u.label.isEmpty) return null;
    return u.label[0].toUpperCase();
  }
}
