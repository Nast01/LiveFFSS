import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/data/dtos/competition_dto.dart';

abstract class CompetitionRemoteDataSource {
  /// [visibility] laisse de cote `incoming` comme `passed` quand il est nul :
  /// FFSS rend alors la fenetre entiere, a venir et passees confondues.
  Future<List<CompetitionDto>> getCompetitions({
    required String season,
    required String startDate,
    String? endDate,
    required CompetitionType type,
    required CompetitionVisibility? visibility,
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
    required CompetitionVisibility? visibility,
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
        // Les deux noms de l'enum sont exactement ceux que l'API attend.
        // Absent = aucun filtre, ce qui n'est pas la meme chose que l'un des
        // deux : ce parametre etait accepte par toute la chaine et jamais
        // envoye, donc le filtre n'avait jamais agi.
        if (visibility != null) 'visibility': visibility.name,
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
