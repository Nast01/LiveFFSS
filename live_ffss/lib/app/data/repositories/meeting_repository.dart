import 'package:intl/intl.dart';
import 'package:live_ffss/app/data/datasources/meeting_remote_datasource.dart';
import 'package:live_ffss/app/data/mappers/meeting_mapper.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';

abstract class MeetingRepository {
  Future<List<Meeting>> getMeetings(int competitionId);
  Future<bool> createMeeting({
    required String name,
    required String description,
    required DateTime date,
    required DateTime beginHour,
    required DateTime endHour,
    required int competitionId,
  });
  Future<bool> deleteMeeting(int meetingId);
}

class MeetingRepositoryImpl implements MeetingRepository {
  MeetingRepositoryImpl(this._dataSource);
  final MeetingRemoteDataSource _dataSource;

  @override
  Future<List<Meeting>> getMeetings(int competitionId) async {
    final dtos = await _dataSource.getMeetings(competitionId);
    return dtos.map((d) => d.toDomain()).toList();
  }

  @override
  Future<bool> createMeeting({
    required String name,
    required String description,
    required DateTime date,
    required DateTime beginHour,
    required DateTime endHour,
    required int competitionId,
  }) =>
      _dataSource.createMeeting(
        name: name,
        description: description,
        dayIso: DateFormat('yyyy-MM-dd').format(date),
        beginTime: DateFormat('HH:mm').format(beginHour),
        endTime: DateFormat('HH:mm').format(endHour),
        competitionId: competitionId,
      );

  @override
  Future<bool> deleteMeeting(int meetingId) =>
      _dataSource.deleteMeeting(meetingId);
}
