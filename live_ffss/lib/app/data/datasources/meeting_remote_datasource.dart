import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/data/dtos/heat_result_dto.dart';
import 'package:live_ffss/app/data/dtos/lane_detail_dto.dart';
import 'package:live_ffss/app/data/dtos/meeting_dto.dart';
import 'package:live_ffss/app/data/dtos/run_dto.dart';

abstract class MeetingRemoteDataSource {
  /// One window of the competition's réunions. FFSS caps this list — it
  /// serves 30 rows when no window is asked for — so the caller has to page.
  Future<List<MeetingDto>> getMeetings(
    int competitionId, {
    required int start,
    required int length,
  });

  /// One window of a créneau's courses. `GET reunion` doesn't carry them.
  Future<List<RunDto>> getRuns(
    int slotId, {
    required int start,
    required int length,
  });

  /// Creates a réunion, or updates the one with the given [id]. Returns the
  /// id FFSS assigned, or 0 when the call reported a failure.
  Future<int> submitMeeting({
    required int competitionId,
    required String name,
    required String description,
    required String dayIso, // 'YYYY-MM-DD'
    required String beginTime, // 'HH:mm'
    required String endTime, // 'HH:mm'
    int? id,
  });

  /// Supprime une réunion. Emporte ses créneaux et ses courses côté serveur.
  Future<bool> deleteMeeting(int meetingId);

  /// Creates a créneau of a réunion, or updates the one with the given [id].
  ///
  /// [raceFormatDetailId] is the round ("partie") this créneau schedules;
  /// left null, the créneau is a plain informational item — that's the only
  /// difference between the two, and the response then shows `partie: null`.
  Future<int> submitSlot({
    required int meetingId,
    required String name,
    required String beginTime,
    required String endTime,
    int? raceFormatDetailId,
    int? id,
  });

  Future<bool> deleteSlot(int slotId);

  /// Creates a course inside a créneau, or updates the one with the given
  /// [id]. Returns the id FFSS assigned, or 0 when the call reported failure.
  ///
  /// [site] is free text — FFSS stores whatever it is given and the timeline
  /// groups courses by it, so two spellings make two columns.
  Future<int> submitRun({
    required int slotId,
    required String name,
    required String beginTime, // 'HH:mm'
    required String endTime, // 'HH:mm'
    required String site,
    int? id,
    int? heatId,
  });

  Future<bool> deleteRun(int runId);

  /// Crée une place numérotée sur une course, ou réécrit celle d'[id].
  /// Rend l'id attribué par FFSS, ou 0 quand l'appel a signalé un échec.
  ///
  /// [engagement] est envoyé tel quel, et ses trois valeurs ne sont pas
  /// interchangeables : `'0'` pour une place créée sans engagement associé,
  /// `''` pour LIBÉRER une place occupée (vérifié le 2026-09-03), l'id de
  /// l'engagement pour l'y asseoir. Le paramètre part toujours, y compris
  /// vide — c'est ce qui rend la libération possible.
  Future<int> submitLane({
    required int runId,
    required int number,
    required String engagement,
    int? id,
  });

  Future<bool> deleteLane(int laneId);

  /// One place, from the detail route — the only one that shows who sits in
  /// it; the réunion tree masks every place's engagement.
  Future<LaneDetailDto> getLaneDetail(int laneId);

  /// Creates the FFSS `serie` a course's results hang off, or updates the one
  /// with [id]. A série belongs to the épreuve; `submitRun`'s `serie`
  /// parameter is what ties it to the course.
  Future<int> submitHeat({
    required int raceId,
    required String name,
    required int number,
    int? id,
  });

  /// Records one competitor's result in a heat, seated in [laneId].
  ///
  /// [rank] is null for anyone out of the ranking — sending a rank would show
  /// them in the classification. [status]: 0 ranked, 1 disqualified,
  /// 2 forfeit (3 is F/DQ server-side, unused here). [complement] is the
  /// referee's free-text code (DNS, DNF, DSQ…).
  Future<int> submitResult({
    required int heatId,
    required int entryId,
    required int laneId,
    required int? rank,
    required int status,
    String? complement,
  });

  Future<List<HeatResultDto>> getHeatResults(int heatId);
}

class MeetingRemoteDataSourceImpl implements MeetingRemoteDataSource {
  MeetingRemoteDataSourceImpl(this._http);
  final HttpClient _http;

  @override
  Future<List<MeetingDto>> getMeetings(
    int competitionId, {
    required int start,
    required int length,
  }) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.meetingList,
      {'id': competitionId.toString()},
    );
    final body = await _http.get(endpoint, query: {
      'start': start,
      'length': length,
    });
    final list = (body['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(MeetingDto.fromJson)
        .toList();
  }

  @override
  Future<List<RunDto>> getRuns(
    int slotId, {
    required int start,
    required int length,
  }) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.runList,
      {'id': slotId.toString()},
    );
    final body = await _http.get(endpoint, query: {
      'start': start,
      'length': length,
    });
    final list = (body['data'] as List?) ?? const [];
    return list.whereType<Map<String, dynamic>>().map(RunDto.fromJson).toList();
  }

  @override
  Future<int> submitMeeting({
    required int competitionId,
    required String name,
    required String description,
    required String dayIso,
    required String beginTime,
    required String endTime,
    int? id,
  }) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.meetingSubmit,
      {'competition': competitionId.toString()},
    );
    final body = await _http.post(endpoint, query: {
      // Empty means "create"; a value means "update".
      'id': id?.toString() ?? '',
      'nom': name,
      'description': description,
      'jour': dayIso,
      'debut': beginTime,
      'fin': endTime,
    });
    if (body['success'] != true) return 0;
    final assigned = body['id'];
    return assigned is int ? assigned : int.tryParse('$assigned') ?? 0;
  }

  @override
  Future<int> submitSlot({
    required int meetingId,
    required String name,
    required String beginTime,
    required String endTime,
    int? raceFormatDetailId,
    int? id,
  }) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.slotSubmit,
      {'reunion': meetingId.toString()},
    );
    final body = await _http.post(endpoint, query: {
      'id': id?.toString() ?? '',
      'nom': name,
      'debut': beginTime,
      'fin': endTime,
      'partie': raceFormatDetailId?.toString() ?? '',
    });
    if (body['success'] != true) return 0;
    final assigned = body['id'];
    return assigned is int ? assigned : int.tryParse('$assigned') ?? 0;
  }

  @override
  Future<bool> deleteSlot(int slotId) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.slotDelete,
      {'id': slotId.toString()},
    );
    final body = await _http.post(endpoint);
    return body['success'] == true;
  }

  @override
  Future<bool> deleteMeeting(int meetingId) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.meetingDelete,
      {'id': meetingId.toString()},
    );
    final body = await _http.post(endpoint);
    return body['success'] == true;
  }

  @override
  Future<int> submitLane({
    required int runId,
    required int number,
    required String engagement,
    int? id,
  }) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.laneSubmit,
      {'course': runId.toString()},
    );
    final body = await _http.post(endpoint, query: {
      // Vide = « créer » ; une valeur = « mettre à jour ».
      'id': id?.toString() ?? '',
      'numero': number.toString(),
      'engagement': engagement,
    });
    final assigned = body['id'];
    return assigned is int ? assigned : 0;
  }

  @override
  Future<bool> deleteLane(int laneId) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.laneDelete,
      {'id': laneId.toString()},
    );
    final body = await _http.post(endpoint);
    return body['success'] == true;
  }

  @override
  Future<int> submitRun({
    required int slotId,
    required String name,
    required String beginTime,
    required String endTime,
    required String site,
    int? id,
    int? heatId,
  }) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.runSubmit,
      {'creneau': slotId.toString()},
    );
    final body = await _http.post(endpoint, query: {
      // Empty means "create"; a value means "update".
      'id': id?.toString() ?? '',
      'nom': name,
      'debut': beginTime,
      'fin': endTime,
      'site': site,
      // 0 = waiting. A course is born before it is run; the marshalling and
      // result states are set from the slot screen, not here.
      'statut': '0',
      // Ties the course to the FFSS `serie` its results hang off. Omitted
      // rather than emptied: a course that already has one must not lose it
      // to a plain retiming.
      if (heatId != null) 'serie': heatId.toString(),
    });
    final assigned = body['id'];
    return assigned is int ? assigned : 0;
  }

  @override
  Future<bool> deleteRun(int runId) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.runDelete,
      {'id': runId.toString()},
    );
    final body = await _http.post(endpoint);
    return body['success'] == true;
  }

  @override
  Future<LaneDetailDto> getLaneDetail(int laneId) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.laneDetail,
      {'id': laneId.toString()},
    );
    final body = await _http.get(endpoint);
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Unexpected place payload');
    }
    return LaneDetailDto.fromJson(data);
  }

  @override
  Future<int> submitHeat({
    required int raceId,
    required String name,
    required int number,
    int? id,
  }) async {
    final body = await _http.post(ApiEndpoints.heatSubmit, query: {
      'id': id?.toString() ?? '',
      'epreuve': raceId.toString(),
      'nom': name,
      'numero': number.toString(),
    });
    final assigned = body['id'];
    return assigned is int ? assigned : 0;
  }

  @override
  Future<int> submitResult({
    required int heatId,
    required int entryId,
    required int laneId,
    required int? rank,
    required int status,
    String? complement,
  }) async {
    final body = await _http.post(ApiEndpoints.resultSubmit, query: {
      'serie': heatId.toString(),
      'engagement': entryId.toString(),
      'place': laneId.toString(),
      // Empty rather than absent: an out-of-ranking competitor must have any
      // previous rank cleared, not kept from an earlier validation.
      'rang': rank?.toString() ?? '',
      'statut': status.toString(),
      'complement': complement ?? '',
    });
    final assigned = body['id'];
    return assigned is int ? assigned : 0;
  }

  @override
  Future<List<HeatResultDto>> getHeatResults(int heatId) async {
    final body = await _http.get(ApiEndpoints.resultList, query: {
      'serie': heatId,
      'start': 0,
      // A heat never holds two hundred competitors; one window is the whole
      // list, so this route needs no paging loop.
      'length': 200,
    });
    final list = (body['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(HeatResultDto.fromJson)
        .toList();
  }
}
