import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/ffss/dtos/epreuve_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/participant_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/serie_results_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/results_mapper.dart';
import 'package:live_ffss_v2/domain/event_results.dart';

abstract class ResultsRepository {
  /// Les épreuves d'une compétition.
  Future<List<CompetitionEvent>> getEvents(int competitionId);

  /// Les séries d'une épreuve avec leurs résultats.
  Future<List<EventSeries>> getEventSeries(int eventId);

  /// Les participants d'une compétition avec leurs engagements.
  Future<List<Participant>> getParticipants(int competitionId);
}

class ResultsRepositoryImpl implements ResultsRepository {
  ResultsRepositoryImpl(this._http);

  final HttpClient _http;

  @override
  Future<List<CompetitionEvent>> getEvents(int competitionId) async {
    final rows = await _rows(
      ApiEndpoints.eventList,
      query: {'evenement': competitionId},
    );
    return _parse(rows, EpreuveDto.fromJson, (dto) => dto.toDomain());
  }

  @override
  Future<List<EventSeries>> getEventSeries(int eventId) async {
    final rows = await _rows(
      ApiEndpoints.eventSeries,
      query: {'epreuve': eventId},
    );
    return _parse(
      rows,
      SerieResultsDto.fromJson,
      (dto) => dto.toDomain(fallbackEventId: eventId),
    );
  }

  @override
  Future<List<Participant>> getParticipants(int competitionId) async {
    final path = ApiEndpoints.replacePath(ApiEndpoints.participants, {
      'id': competitionId.toString(),
    });
    final rows = await _rows(path);
    return _parse(rows, ParticipantDto.fromJson, (dto) => dto.toDomain());
  }

  Future<List<Object?>> _rows(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final data = (await _http.get(path, query: query))['data'];
    return data is List ? data : const <Object?>[];
  }

  /// Une ligne qui n'est pas un objet, ou dont un champ a le mauvais type
  /// (`TypeError`), ou que le mapper rejette, est écartée seule : elle ne doit
  /// pas faire échouer toute la liste.
  List<T> _parse<D, T>(
    List<Object?> rows,
    D Function(Map<String, dynamic>) fromJson,
    T? Function(D) toDomain,
  ) {
    final result = <T>[];
    for (final row in rows) {
      if (row is! Map<String, dynamic>) continue;
      final D dto;
      try {
        dto = fromJson(row);
      } on TypeError {
        continue;
      }
      final item = toDomain(dto);
      if (item != null) result.add(item);
    }
    return result;
  }
}

final resultsRepositoryProvider = Provider<ResultsRepository>(
  (ref) => ResultsRepositoryImpl(ref.watch(httpClientProvider)),
);
