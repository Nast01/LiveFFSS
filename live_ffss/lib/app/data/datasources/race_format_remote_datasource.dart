import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/data/dtos/race_format_configuration_dto.dart';

abstract class RaceFormatRemoteDataSource {
  Future<List<RaceFormatConfigurationDto>> getRaceFormats(int competitionId);

  /// Creates a déroulement, or updates one when [id] is given. Returns the id
  /// FFSS assigned, or 0 when the call reported a failure.
  Future<int> submitRaceFormat({
    required int competitionId,
    required int disciplineId,
    required String gender,
    required List<int> categoryIds,
    int? id,
  });

  Future<bool> deleteRaceFormat(int raceFormatId);

  /// Deletes one round ("partie") of a déroulement.
  Future<bool> deleteRaceFormatDetail(int detailId);
}

class RaceFormatRemoteDataSourceImpl implements RaceFormatRemoteDataSource {
  RaceFormatRemoteDataSourceImpl(this._http);

  final HttpClient _http;

  @override
  Future<List<RaceFormatConfigurationDto>> getRaceFormats(
      int competitionId) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.raceFormatList,
      {'id': competitionId.toString()},
    );
    final body = await _http.get(endpoint);
    final list = (body['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(RaceFormatConfigurationDto.fromJson)
        .toList();
  }

  @override
  Future<int> submitRaceFormat({
    required int competitionId,
    required int disciplineId,
    required String gender,
    required List<int> categoryIds,
    int? id,
  }) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.raceFormatSubmit,
      {'competition': competitionId.toString()},
    );
    final body = await _http.post(endpoint, query: {
      // Empty means "create"; a value means "update", exactly like the
      // reunion/submit contract.
      'id': id?.toString() ?? '',
      'discipline': disciplineId,
      'genre': gender,
      // PHP array notation: HttpClient turns the list into one repeated key
      // per entry — categories[]=10&categories[]=24.
      'categories[]': categoryIds,
    });
    if (body['success'] != true) return 0;
    final assigned = body['id'];
    return assigned is int ? assigned : int.tryParse('$assigned') ?? 0;
  }

  @override
  Future<bool> deleteRaceFormat(int raceFormatId) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.raceFormatDelete,
      {'id': raceFormatId.toString()},
    );
    final body = await _http.post(endpoint);
    return body['success'] == true;
  }

  @override
  Future<bool> deleteRaceFormatDetail(int detailId) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.raceFormatDetailDelete,
      {'id': detailId.toString()},
    );
    final body = await _http.post(endpoint);
    return body['success'] == true;
  }
}
