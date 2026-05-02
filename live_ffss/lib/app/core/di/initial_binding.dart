import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/routes/app_pages.dart';
import 'package:live_ffss/app/data/datasources/auth_remote_datasource.dart';
import 'package:live_ffss/app/data/datasources/club_remote_datasource.dart';
import 'package:live_ffss/app/data/datasources/competition_remote_datasource.dart';
import 'package:live_ffss/app/data/datasources/meeting_remote_datasource.dart';
import 'package:live_ffss/app/data/datasources/race_remote_datasource.dart';
import 'package:live_ffss/app/data/datasources/ranking_remote_datasource.dart';
import 'package:live_ffss/app/data/datasources/result_remote_datasource.dart';
import 'package:live_ffss/app/data/repositories/auth_repository.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/competition_repository.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/repositories/ranking_repository.dart';
import 'package:live_ffss/app/data/repositories/result_repository.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';

class InitialBinding {
  InitialBinding._();

  static Future<void> register() async {
    // 1. Config
    Get.put<AppConfig>(AppConfig.fromEnv(), permanent: true);

    // 2. Storage
    Get.put<FlutterSecureStorage>(
      const FlutterSecureStorage(),
      permanent: true,
    );
    Get.put<TokenStorage>(
      TokenStorage(Get.find<FlutterSecureStorage>()),
      permanent: true,
    );

    // 3. HTTP
    Get.put<HttpClient>(
      HttpClient(
        config: Get.find<AppConfig>(),
        tokenStorage: Get.find<TokenStorage>(),
      ),
      permanent: true,
    );

    // 4. Auth data layer
    Get.put<AuthRemoteDataSource>(
      AuthRemoteDataSourceImpl(Get.find<HttpClient>()),
      permanent: true,
    );
    Get.put<AuthRepository>(
      AuthRepositoryImpl(
        dataSource: Get.find<AuthRemoteDataSource>(),
        tokenStorage: Get.find<TokenStorage>(),
        secureStorage: Get.find<FlutterSecureStorage>(),
      ),
      permanent: true,
    );

    // 5. Competition data layer
    Get.put<CompetitionRemoteDataSource>(
      CompetitionRemoteDataSourceImpl(Get.find<HttpClient>()),
      permanent: true,
    );
    Get.put<CompetitionRepository>(
      CompetitionRepositoryImpl(Get.find<CompetitionRemoteDataSource>()),
      permanent: true,
    );

    // 6. Club data layer
    Get.put<ClubRemoteDataSource>(
      ClubRemoteDataSourceImpl(Get.find<HttpClient>()),
      permanent: true,
    );
    Get.put<ClubRepository>(
      ClubRepositoryImpl(Get.find<ClubRemoteDataSource>()),
      permanent: true,
    );

    // 7. Race data layer
    Get.put<RaceRemoteDataSource>(
      RaceRemoteDataSourceImpl(Get.find<HttpClient>()),
      permanent: true,
    );
    Get.put<RaceRepository>(
      RaceRepositoryImpl(Get.find<RaceRemoteDataSource>()),
      permanent: true,
    );

    // 5d. Meeting data layer
    Get.put<MeetingRemoteDataSource>(
      MeetingRemoteDataSourceImpl(Get.find<HttpClient>()),
      permanent: true,
    );
    Get.put<MeetingRepository>(
      MeetingRepositoryImpl(Get.find<MeetingRemoteDataSource>()),
      permanent: true,
    );

    // 5e. Result data layer (UnimplementedError stubs — see ResultRepository)
    Get.put<ResultRemoteDataSource>(
      ResultRemoteDataSourceImpl(),
      permanent: true,
    );
    Get.put<ResultRepository>(
      ResultRepositoryImpl(Get.find<ResultRemoteDataSource>()),
      permanent: true,
    );

    // 5f. Ranking data layer (stub returning empty lists — see datasource doc)
    Get.put<RankingRemoteDataSource>(
      RankingRemoteDataSourceImpl(),
      permanent: true,
    );
    Get.put<RankingRepository>(
      RankingRepositoryImpl(Get.find<RankingRemoteDataSource>()),
      permanent: true,
    );

    // 8. Long-lived state holders (depend on the auth repo)
    await Get.putAsync<UserService>(
      () async => UserService(Get.find<AuthRepository>()).init(),
    );
    await Get.putAsync<LanguageService>(
      () async => LanguageService().init(),
    );
    await Get.putAsync<UserPreferencesService>(
      () async => UserPreferencesService(
        Get.find<FlutterSecureStorage>(),
      ).init(),
    );

    // 9. Session expiration handling
    _wireSessionExpirationHandler();
  }

  static bool _handlingExpiry = false;

  /// Wires HttpClient.onAuthFailure to log out + navigate to /login + show a
  /// snackbar. The flag prevents duplicate handling when several in-flight
  /// requests all return 401 in the same microtask. The current-route check
  /// avoids re-navigating when the user is already on the login screen
  /// (e.g., a failed login attempt itself returns 401).
  static void _wireSessionExpirationHandler() {
    final http = Get.find<HttpClient>();
    final auth = Get.find<AuthRepository>();

    http.onAuthFailure = () async {
      if (_handlingExpiry) return;
      if (Get.currentRoute == Routes.login) return;
      _handlingExpiry = true;
      try {
        await auth.logout();
        await Get.offAllNamed<void>(Routes.login);
        Get.snackbar(
          'session_expired'.tr,
          'please_login_again'.tr,
          snackPosition: SnackPosition.TOP,
        );
      } finally {
        _handlingExpiry = false;
      }
    };
  }
}
