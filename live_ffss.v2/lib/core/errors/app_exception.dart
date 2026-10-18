sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  /// A short technical reason, meant to sit under a translated failure line so
  /// the operator can say what actually went wrong. Never translated — it
  /// comes from the server or the platform, and its value is that it is raw.
  String get detail => message;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ApiException extends AppException {
  const ApiException(
    super.message, {
    this.statusCode,
    this.code,
    this.authenticated,
    this.malformedResponse = false,
  });

  final int? statusCode;
  final String? code;

  /// La réponse n'était pas une enveloppe FFSS : une page HTML (portail
  /// captif d'un Wi-Fi, proxy, panne) ou un JSON d'une autre forme. Ce n'est
  /// pas un refus du site, et un nouvel essai peut réussir.
  final bool malformedResponse;

  /// Whether the request that failed carried a token. Null when nobody
  /// recorded it.
  ///
  /// FFSS answers `Invalid Token` to a bad token and to no token alike, so its
  /// reply cannot tell "the session expired" from "nobody is logged in". Only
  /// the client knows which of the two just happened, and the diagnostic is
  /// worthless without it.
  final bool? authenticated;

  @override
  String get detail {
    final notes = [
      if (statusCode != null) 'HTTP $statusCode',
      if (authenticated == false) 'no token sent',
    ];
    return notes.isEmpty ? message : '$message (${notes.join(', ')})';
  }
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}

/// Ce qu'on demande n'existe pas, ou plus : un lien vers un créneau retiré du
/// programme, par exemple. Distinct d'une panne, qu'un nouvel essai réglerait.
class NotFoundException extends AppException {
  const NotFoundException(super.message);
}
