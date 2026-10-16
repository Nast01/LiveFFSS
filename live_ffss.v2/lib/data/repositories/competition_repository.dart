import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/ffss/dtos/evenement_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/evenement_mapper.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';

abstract class CompetitionRepository {
  /// Toutes les compétitions qui commencent à partir du jour [from], toutes
  /// pages lues.
  Future<List<CompetitionSummary>> getCompetitionsFrom(DateTime from);

  /// La recherche de l'API : une page, sans filtre de date, de la plus récente
  /// à la plus ancienne.
  Future<List<CompetitionSummary>> search(String query);
}

class CompetitionRepositoryImpl implements CompetitionRepository {
  CompetitionRepositoryImpl(this._http);

  final HttpClient _http;

  /// FFSS retombe à 30 lignes quand on ne demande rien.
  static const int pageSize = 100;

  static const int searchLimit = 50;

  /// `type` 3 (« mixte ») est la valeur qui rend les trois spécialités : c'est
  /// celle que la v1 envoyait pour « toutes ».
  static const int _allSpecialities = 3;

  static final DateFormat _day = DateFormat('yyyy-MM-dd');

  @override
  Future<List<CompetitionSummary>> getCompetitionsFrom(DateTime from) async {
    final all = <CompetitionSummary>[];
    for (var start = 0; ; start += pageSize) {
      final rows = await _rows({
        'debut': _day.format(from),
        'type': _allSpecialities,
        'start': start,
        'length': pageSize,
      });
      all.addAll(_summaries(rows));
      // Compté sur les entrées brutes : une entrée non-objet ou écartée par le
      // mapper ne doit pas faire passer une page pleine pour la dernière.
      if (rows.length < pageSize) return all;
    }
  }

  @override
  Future<List<CompetitionSummary>> search(String query) async {
    final text = query.trim();
    if (text.isEmpty) return const [];
    final rows = await _rows({
      'search': text,
      'type': _allSpecialities,
      'start': 0,
      'length': searchLimit,
    });
    return _summaries(rows)..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  /// Les entrées brutes de `data`, non filtrées : le compte de page en dépend.
  Future<List<Object?>> _rows(Map<String, dynamic> query) async {
    final body = await _http.get(ApiEndpoints.competitionList, query: query);
    final data = body['data'];
    return data is List ? data : const [];
  }

  List<CompetitionSummary> _summaries(List<Object?> rows) {
    final summaries = <CompetitionSummary>[];
    for (final row in rows.whereType<Map<String, dynamic>>()) {
      final EvenementDto dto;
      try {
        dto = EvenementDto.fromJson(row);
      } on TypeError {
        // Une valeur au mauvais type (`Nom: 123`) : la ligne est écartée seule,
        // comme celles que le mapper rejette, plutôt que de faire échouer la liste.
        continue;
      }
      final summary = dto.toDomain();
      if (summary != null) summaries.add(summary);
    }
    return summaries;
  }
}

final competitionRepositoryProvider = Provider<CompetitionRepository>(
  (ref) => CompetitionRepositoryImpl(ref.watch(httpClientProvider)),
);
