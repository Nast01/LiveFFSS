sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ApiException extends AppException {
  const ApiException(super.message, {this.statusCode, this.code});

  final int? statusCode;
  final String? code;
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}

class RfidException extends AppException {
  const RfidException(super.message);
}
