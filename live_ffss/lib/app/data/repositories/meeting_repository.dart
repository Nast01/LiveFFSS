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

  /// Lignes par requête. FFSS retombe à 30 quand on ne demande rien, ce qui
  /// est bien en dessous d'un vrai programme.
  static const _pageSize = 100;

  @override
  Future<List<Meeting>> getMeetings(int competitionId) async {
    final all = <Meeting>[];
    var start = 0;
    while (true) {
      final batch = await _dataSource.getMeetings(
        competitionId,
        start: start,
        length: _pageSize,
      );
      all.addAll(batch.map((d) => d.toDomain()));
      if (batch.length < _pageSize) break;
      start += _pageSize;
    }
    return all;
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
