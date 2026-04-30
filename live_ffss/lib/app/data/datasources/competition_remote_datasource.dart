import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/data/dtos/competition_dto.dart';

abstract class CompetitionRemoteDataSource {
  Future<List<CompetitionDto>> getCompetitions({
    required String season,
    required String startDate,
    String? endDate,
    required CompetitionType type,
    required CompetitionVisibility visibility,
    required int page,
    required int pageSize,
  });
}

class CompetitionRemoteDataSourceImpl implements CompetitionRemoteDataSource {
  CompetitionRemoteDataSourceImpl(this._http);

  final HttpClient _http;

  @override
  Future<List<CompetitionDto>> getCompetitions({
    required String season,
    required String startDate,
    String? endDate,
    required CompetitionType type,
    required CompetitionVisibility visibility,
    required int page,
    required int pageSize,
  }) async {
    final body = await _http.get(
      ApiEndpoints.competitionList,
      query: {
        'saison': season,
        'debut': startDate,
        if (endDate != null) 'fin': endDate,
        'type': type.index,
        'visibility': visibility.name,
        'length': pageSize,
        'start': pageSize * (page - 1),
        'order': 'DebutEngagement',
        'orderDirection': 'ASC',
      },
    );
    final list = (body['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(CompetitionDto.fromJson)
        .toList();
  }
}
