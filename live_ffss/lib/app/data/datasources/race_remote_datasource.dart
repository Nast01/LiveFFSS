import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/data/dtos/race_dto.dart';

abstract class RaceRemoteDataSource {
  Future<List<RaceDto>> getRaces(int competitionId);
}

class RaceRemoteDataSourceImpl implements RaceRemoteDataSource {
  RaceRemoteDataSourceImpl(this._http);

  final HttpClient _http;

  @override
  Future<List<RaceDto>> getRaces(int competitionId) async {
    final body = await _http.get(
      ApiEndpoints.raceList,
      query: {'evenement': competitionId},
    );
    final list = (body['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(RaceDto.fromJson)
        .toList();
  }
}
