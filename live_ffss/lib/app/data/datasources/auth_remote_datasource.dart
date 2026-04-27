import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/data/dtos/auth_token_dto.dart';
import 'package:live_ffss/app/data/dtos/user_dto.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokenDto> requestToken({
    required String login,
    required String password,
  });

  Future<UserDto> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._http);

  final HttpClient _http;

  @override
  Future<AuthTokenDto> requestToken({
    required String login,
    required String password,
  }) async {
    final body = await _http.post(
      ApiEndpoints.requestToken,
      query: {'login': login, 'password': password},
    );
    return AuthTokenDto.fromJson(body);
  }

  @override
  Future<UserDto> getCurrentUser() async {
    final body = await _http.get(ApiEndpoints.me);
    return UserDto.fromJson(body);
  }
}
