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
    return decodeRows(rows, EpreuveDto.fromJson, (dto) => dto.toDomain());
  }

  @override
  Future<List<EventSeries>> getEventSeries(int eventId) async {
    final rows = await _rows(
      ApiEndpoints.eventSeries,
      query: {'epreuve': eventId},
    );
    return decodeRows(
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
    return decodeRows(rows, ParticipantDto.fromJson, (dto) => dto.toDomain());
  }

  Future<List<Object?>> _rows(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final data = (await _http.get(path, query: query))['data'];
    return data is List ? data : const <Object?>[];
  }
}

final resultsRepositoryProvider = Provider<ResultsRepository>(
  (ref) => ResultsRepositoryImpl(ref.watch(httpClientProvider)),
);
