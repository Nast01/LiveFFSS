import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/ffss/dtos/officiel_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/officiel_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/results_mapper.dart';
import 'package:live_ffss_v2/domain/officials.dart';

abstract class OfficialsRepository {
  /// Les officiels d'une compétition.
  Future<List<CompetitionOfficial>> getOfficials(int competitionId);
}

class OfficialsRepositoryImpl implements OfficialsRepository {
  OfficialsRepositoryImpl(this._http);

  final HttpClient _http;

  @override
  Future<List<CompetitionOfficial>> getOfficials(int competitionId) async {
    final path = ApiEndpoints.replacePath(ApiEndpoints.officials, {
      'id': competitionId.toString(),
    });
    final data = (await _http.get(path))['data'];
    return decodeRows(
      data is List ? data : const <Object?>[],
      OfficielDto.fromJson,
      (OfficielDto dto) => dto.toDomain(),
    );
  }
}

final officialsRepositoryProvider = Provider<OfficialsRepository>(
  (ref) => OfficialsRepositoryImpl(ref.watch(httpClientProvider)),
);
