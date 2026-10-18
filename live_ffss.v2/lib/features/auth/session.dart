import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/token_storage.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/storage/local_store.dart';
import 'package:live_ffss_v2/data/repositories/auth_repository.dart';
import 'package:live_ffss_v2/domain/account.dart';

/// La connexion au site FFSS, sur le modèle de `FfssSession` de V3 : le mot
/// de passe n'est jamais gardé, seul le jeton l'est ([TokenStorage]), avec le
/// nom du compte pour vérifier qu'un jeton repris est toujours le sien.
/// Nul : personne n'est connecté.
class SessionNotifier extends AsyncNotifier<Account?> {
  /// Le nom du compte connecté. Le site ne donne pas d'identifiant de compte
  /// stable : c'est le nom qui dit si un jeton repris appartient au même
  /// compte (comme dans V3).
  static const accountKey = 'session_account';

  /// La reprise n'est acquise qu'une fois le jeton vérifié par `GET /me` :
  /// le site sert un jeton mort comme anonyme, et son expiration annoncée ne
  /// prouve rien.
  @override
  Future<Account?> build() async {
    // Branché avant toute attente : une écriture refusée pendant la reprise
    // doit déjà trouver qui prévenir.
    ref.watch(httpClientProvider).onAuthFailure = _expire;
    final tokens = ref.watch(tokenStorageProvider);
    final store = ref.watch(localStoreProvider);
    final auth = ref.watch(authRepositoryProvider);

    final token = await tokens.getToken();
    if (!ref.mounted || token == null || token.isEmpty) return null;
    final stored = await store.read(accountKey);
    if (!ref.mounted) return null;

    final Account account;
    try {
      account = await auth.me();
    } on NetworkException {
      // Hors ligne, la session enregistrée est supposée bonne : la première
      // écriture la vérifiera (un 403 « Invalid token » la ferme).
      if (stored != null) return Account(label: stored);
      // Sans nom enregistré, rien ne dirait plus tard à qui est ce jeton.
      await _forget(tokens, store);
      return null;
    } on AppException {
      await _forget(tokens, store);
      return null;
    }
    if (!ref.mounted) return null;

    if (stored != null && !_sameAccount(stored, account.label)) {
      await _forget(tokens, store);
      return null;
    }
    await store.write(accountKey, account.label);
    return account;
  }

  /// Lève une [AppException] si la connexion échoue ; la session reste alors
  /// fermée.
  Future<void> login(String login, String password) async {
    await future;
    if (!ref.mounted) return;
    final tokens = ref.read(tokenStorageProvider);
    final store = ref.read(localStoreProvider);
    final auth = ref.read(authRepositoryProvider);

    // Un jeton périmé partirait avec la demande : le 403 « Invalid token »
    // qu'il provoque interromprait la connexion.
    await tokens.clearToken();
    if (!ref.mounted) return;
    state = const AsyncData(null);

    final token = await auth.requestToken(login, password);
    if (!ref.mounted) return;
    await tokens.setToken(token);
    if (!ref.mounted) return;

    Account account;
    try {
      account = await auth.me();
    } on NetworkException {
      // Sans compte vérifié, pas de session à moitié ouverte.
      await tokens.clearToken();
      rethrow;
    } on AppException {
      // Comme V3 : le jeton vient d'être accordé, la connexion vaut ; seul le
      // nom manque, l'identifiant en tient lieu.
      account = Account(label: login.trim());
    }
    if (!ref.mounted) return;
    await store.write(accountKey, account.label);
    if (!ref.mounted) return;

    ref.read(sessionExpiredProvider.notifier)._set(false);
    state = AsyncData(account);
  }

  Future<void> logout() async {
    final tokens = ref.read(tokenStorageProvider);
    final store = ref.read(localStoreProvider);
    ref.read(sessionExpiredProvider.notifier)._set(false);
    state = const AsyncData(null);
    await _forget(tokens, store);
  }

  /// Seuls le jeton et l'état de la session changent : la file d'envoi et
  /// les autres préférences restent, pour être reprises après la
  /// reconnexion. Le nom du compte reste aussi, il dira à qui elles sont.
  Future<void> _expire() async {
    if (!ref.mounted || state.value == null) return;
    final tokens = ref.read(tokenStorageProvider);
    ref.read(sessionExpiredProvider.notifier)._set(true);
    state = const AsyncData(null);
    await tokens.clearToken();
  }

  static Future<void> _forget(TokenStorage tokens, LocalStore store) async {
    await tokens.clearToken();
    await store.delete(accountKey);
  }

  /// Même personne : même nom affiché, à la casse et aux espaces près.
  static bool _sameAccount(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();
}

final sessionProvider = AsyncNotifierProvider<SessionNotifier, Account?>(
  SessionNotifier.new,
);

/// Vrai quand le site a refusé le jeton à une écriture : la session est
/// fermée et il faut proposer de se reconnecter. Remis à faux par une
/// connexion ou une déconnexion.
class SessionExpiredNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void _set(bool expired) => state = expired;
}

final sessionExpiredProvider = NotifierProvider<SessionExpiredNotifier, bool>(
  SessionExpiredNotifier.new,
);
