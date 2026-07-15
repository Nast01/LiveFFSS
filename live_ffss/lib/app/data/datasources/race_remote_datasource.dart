import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/data/dtos/entry_dto.dart';
import 'package:live_ffss/app/data/dtos/heat_dto.dart';
import 'package:live_ffss/app/data/dtos/race_dto.dart';

abstract class RaceRemoteDataSource {
  Future<List<RaceDto>> getRaces(int competitionId);
  Future<List<HeatDto>> getHeats(int raceId);
  Future<List<EntryDto>> getEntries(int raceId);
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

  @override
  Future<List<HeatDto>> getHeats(int raceId) async {
    final body = await _http.get(
      ApiEndpoints.heatList,
      query: {'epreuve': raceId},
    );
    final list = (body['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(HeatDto.fromJson)
        .toList();
  }

  @override
  Future<List<EntryDto>> getEntries(int raceId) async {
    final body = await _http.get(
      ApiEndpoints.entryList,
      query: {'epreuve': raceId},
    );
    final list = (body['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(EntryDto.fromJson)
        .toList();
  }
}
