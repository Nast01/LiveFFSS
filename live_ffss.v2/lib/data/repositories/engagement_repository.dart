import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/providers.dart';

abstract class EngagementRepository {
  /// Déclare ([forfeit] vrai) ou annule le forfait de l'engagement [entryId].
  Future<void> setForfeit(int entryId, {required bool forfeit});
}

class EngagementRepositoryImpl implements EngagementRepository {
  EngagementRepositoryImpl(this._http);

  final HttpClient _http;

  /// Le paramètre passe dans l'adresse, sans corps, comme `resultat/submit` :
  /// c'est ainsi que le site l'accepte (vérifié le 2026-10-19).
  @override
  Future<void> setForfeit(int entryId, {required bool forfeit}) async {
    final path = ApiEndpoints.replacePath(ApiEndpoints.engagementSubmit, {
      'id': entryId.toString(),
    });
    final body = await _http.post(
      path,
      query: {'forfait': forfeit ? '1' : '0'},
    );
    // HttpClient lève déjà sur un refus ; vérifié ici aussi pour qu'un
    // refus ne passe jamais pour un forfait enregistré.
    final success = body['success'];
    if (success == false || success == 'false') {
      throw ApiException(
        body['message']?.toString() ?? 'API returned success: false',
      );
    }
  }
}

final engagementRepositoryProvider = Provider<EngagementRepository>(
  (ref) => EngagementRepositoryImpl(ref.watch(httpClientProvider)),
);
