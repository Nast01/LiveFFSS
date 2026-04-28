import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/data/dtos/club_dto.dart';

abstract class ClubRemoteDataSource {
  Future<List<ClubDto>> getClubs(int competitionId);
  Future<ClubDto> getClubDetail(int clubId);
}

class ClubRemoteDataSourceImpl implements ClubRemoteDataSource {
  ClubRemoteDataSourceImpl(this._http);

  final HttpClient _http;

  @override
  Future<List<ClubDto>> getClubs(int competitionId) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.clubList,
      {'id': competitionId.toString()},
    );
    final body = await _http.get(endpoint);
    final list = (body['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ClubDto.fromJson)
        .toList();
  }

  @override
  Future<ClubDto> getClubDetail(int clubId) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.clubDetail,
      {'id': clubId.toString()},
    );
    final body = await _http.get(endpoint);
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected club detail shape');
    }
    return ClubDto.fromJson(data);
  }
}
