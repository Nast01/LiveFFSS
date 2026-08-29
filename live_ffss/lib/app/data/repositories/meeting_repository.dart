import 'package:intl/intl.dart';
import 'package:live_ffss/app/data/datasources/meeting_remote_datasource.dart';
import 'package:live_ffss/app/data/mappers/meeting_mapper.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';

abstract class MeetingRepository {
  Future<List<Meeting>> getMeetings(int competitionId);

  /// Creates a réunion, or updates the one with the given [id]. Returns the
  /// id FFSS assigned, or 0 when the call reported a failure.
  Future<int> submitMeeting({
    required int competitionId,
    required String name,
    required String description,
    required DateTime date,
    required DateTime beginHour,
    required DateTime endHour,
    int? id,
  });
  Future<bool> deleteMeeting(int meetingId);

  /// Creates a créneau of a réunion, or updates the one with the given [id].
  ///
  /// [raceFormatDetailId] is the round ("partie") this créneau schedules;
  /// left null, the créneau is a plain informational item.
  Future<int> submitSlot({
    required int meetingId,
    required String name,
    required DateTime beginHour,
    required DateTime endHour,
    int? raceFormatDetailId,
    int? id,
  });

  Future<bool> deleteSlot(int slotId);
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
  Future<int> submitMeeting({
    required int competitionId,
    required String name,
    required String description,
    required DateTime date,
    required DateTime beginHour,
    required DateTime endHour,
    int? id,
  }) =>
      _dataSource.submitMeeting(
        competitionId: competitionId,
        name: name,
        description: description,
        dayIso: DateFormat('yyyy-MM-dd').format(date),
        beginTime: DateFormat('HH:mm').format(beginHour),
        endTime: DateFormat('HH:mm').format(endHour),
        id: id,
      );

  @override
  Future<bool> deleteMeeting(int meetingId) =>
      _dataSource.deleteMeeting(meetingId);

  @override
  Future<int> submitSlot({
    required int meetingId,
    required String name,
    required DateTime beginHour,
    required DateTime endHour,
    int? raceFormatDetailId,
    int? id,
  }) =>
      _dataSource.submitSlot(
        meetingId: meetingId,
        name: name,
        beginTime: DateFormat('HH:mm').format(beginHour),
        endTime: DateFormat('HH:mm').format(endHour),
        raceFormatDetailId: raceFormatDetailId,
        id: id,
      );

  @override
  Future<bool> deleteSlot(int slotId) => _dataSource.deleteSlot(slotId);
}
