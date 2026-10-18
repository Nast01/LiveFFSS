import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/outbox.dart';

/// Pourquoi une connexion a échoué, du point de vue de la personne qui tape
/// son mot de passe : se corriger, réessayer plus tard, ou rien à y faire.
enum LoginFailure { rejected, unreachable, other }

LoginFailure loginFailureOf(AppException error) => switch (error) {
  AuthException() => LoginFailure.rejected,
  NetworkException() => LoginFailure.unreachable,
  // Une page de portail captif ou de proxy : le site n'a rien répondu.
  ApiException(malformedResponse: true) => LoginFailure.unreachable,
  _ => LoginFailure.other,
};

/// Les saisies que le compte [account] a encore à envoyer : celles-là
/// resteraient en file à la déconnexion.
int pendingOperationCount(List<OutboxOperation> queue, Account account) => queue
    .where(
      (o) =>
          o.state == OutboxState.pending &&
          isSameAccount(o.account, account.label),
    )
    .length;

/// Se déconnecter n'efface rien, mais les saisies en attente ne partent plus
/// avant la reconnexion : mieux vaut le dire avant.
bool logoutNeedsConfirmation(List<OutboxOperation> queue, Account account) =>
    pendingOperationCount(queue, account) > 0;

/// Le formulaire peut être envoyé : un identifiant et un mot de passe saisis.
bool canSubmitLogin(String login, String password) =>
    login.trim().isNotEmpty && password.isNotEmpty;
