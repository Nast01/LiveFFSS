import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
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

  /// Creates a numbered spot on a course, or renumbers the one with the given
  /// [id]. Returns the id FFSS assigned, or 0 when the call reported failure.
  Future<int> submitLane({
    required int runId,
    required int number,
    int? id,
  });

  Future<bool> deleteLane(int laneId);
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
  Future<bool> deleteMeeting(int meetingId) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.meetingDelete,
      {'id': meetingId.toString()},
    );
    final body = await _http.post(endpoint);
    return body['success'] == true;
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
  Future<int> submitLane({
    required int runId,
    required int number,
    int? id,
  }) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.laneSubmit,
      {'course': runId.toString()},
    );
    final body = await _http.post(endpoint, query: {
      // Empty means "create"; a value means "update".
      'id': id?.toString() ?? '',
      'numero': number.toString(),
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
}
