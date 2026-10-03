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
    currentUser.value = await _auth.restoreStoredSession();
    // Abonné avant la sonde : c'est par ce flux que la fermeture de session
    // arrive si le serveur répond « vous n'êtes personne ».
    _sub = _auth.userStream.listen((user) => currentUser.value = user);
    // Délibérément non attendue. Attendue, elle tenait l'écran noir jusqu'à
    // quatre secondes plus la résolution DNS sur un réseau lent ou absent :
    // `InitialBinding.register()` tourne avant `runApp`. L'erreur est avalée
    // parce qu'une fermeture de session ratée laisse l'opérateur connecté
    // localement, et la première écriture retombera sur `onAuthFailure`.
    if (currentUser.value != null) {
      unawaited(_auth.revalidateSession().catchError((Object _) {}));
    }
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
