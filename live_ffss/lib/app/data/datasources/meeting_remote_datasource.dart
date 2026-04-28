import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/data/dtos/meeting_dto.dart';

abstract class MeetingRemoteDataSource {
  Future<List<MeetingDto>> getMeetings(int competitionId);
  Future<bool> createMeeting({
    required String name,
    required String description,
    required String dayIso, // 'YYYY-MM-DD'
    required String beginTime, // 'HH:mm'
    required String endTime, // 'HH:mm'
    required int competitionId,
  });
  Future<bool> deleteMeeting(int meetingId);
}

class MeetingRemoteDataSourceImpl implements MeetingRemoteDataSource {
  MeetingRemoteDataSourceImpl(this._http);
  final HttpClient _http;

  @override
  Future<List<MeetingDto>> getMeetings(int competitionId) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.meetingList,
      {'id': competitionId.toString()},
    );
    final body = await _http.get(endpoint);
    final list = (body['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(MeetingDto.fromJson)
        .toList();
  }

  @override
  Future<bool> createMeeting({
    required String name,
    required String description,
    required String dayIso,
    required String beginTime,
    required String endTime,
    required int competitionId,
  }) async {
    final endpoint = ApiEndpoints.replacePath(
      ApiEndpoints.meetingSubmit,
      {'competition': competitionId.toString()},
    );
    final body = await _http.post(endpoint, query: {
      'id': '',
      'nom': name,
      'description': description,
      'jour': dayIso,
      'debut': beginTime,
      'fin': endTime,
    });
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
}
