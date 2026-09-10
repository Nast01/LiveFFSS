import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/session_probe.dart';

/// L'état de l'écran de debug. La bascule d'environnement, elle, détruit ce
/// contrôleur : elle appartient à la vue.
class DebugController extends GetxController {
  DebugController(
    this._config,
    this._auth,
    this._userService,
    this._tokenStorage,
  );

  final AppConfig _config;
  final AuthRepository _auth;
  final UserService _userService;
  final TokenStorage _tokenStorage;

  final RxBool isProbing = false.obs;
  final Rxn<SessionProbe> probe = Rxn<SessionProbe>();
  final RxnString token = RxnString();

  AppEnvironment get current => _config.environment;

  List<AppEnvironment> get environments => AppEnvironment.values;

  String get endpoint => _config.environment.endpoint;

  String get storagePrefixLabel {
    final prefix = _config.environment.storagePrefix;
    return prefix.isEmpty ? 'aucun' : prefix;
  }

  /// La date que FFSS a annoncée à la connexion. Elle ne dit pas si le jeton
  /// est encore vivant — c'est tout l'objet de [runProbe].
  DateTime? get announcedExpiration =>
      _userService.currentUser.value?.tokenExpiration;

  @override
  void onInit() {
    super.onInit();
    loadToken();
  }

  Future<void> loadToken() async => token.value = await _tokenStorage.getToken();

  /// [AuthRepository.probeSession] ne lève pas : elle traduit ses échecs en
  /// `unreachable`.
  Future<void> runProbe() async {
    isProbing.value = true;
    try {
      probe.value = await _auth.probeSession();
    } finally {
      isProbing.value = false;
    }
  }
}
