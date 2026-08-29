import 'package:intl/intl.dart';
import 'package:live_ffss/app/data/datasources/meeting_remote_datasource.dart';
import 'package:live_ffss/app/data/dtos/meeting_dto.dart';
import 'package:live_ffss/app/data/dtos/run_dto.dart';
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
    final all = <MeetingDto>[];
    var start = 0;
    while (true) {
      final batch = await _dataSource.getMeetings(
        competitionId,
        start: start,
        length: _pageSize,
      );
      all.addAll(batch);
      if (batch.length < _pageSize) break;
      start += _pageSize;
    }

    // One paged sequence of round trips per créneau, all créneaux in flight
    // at once: in series, a twenty-créneau day would pay twenty latencies
    // end to end. Each créneau's own courses still page like any FFSS list.
    final slotIds = [
      for (final meeting in all)
        for (final slot in meeting.slots) slot.id,
    ];
    final loaded = await Future.wait(slotIds.map(_getAllRuns));
    final runsBySlot = <int, List<RunDto>>{
      for (var i = 0; i < slotIds.length; i++) slotIds[i]: loaded[i],
    };

    return all.map((meeting) {
      final filledSlots = meeting.slots
          .map((slot) => slot.copyWith(runs: runsBySlot[slot.id] ?? const []))
          .toList();
      return meeting.copyWith(slots: filledSlots).toDomain();
    }).toList();
  }

  /// All courses of one créneau, paged the same way `getMeetings` pages
  /// réunions — FFSS serves this list 30 rows at a time when no window is
  /// asked for, and a créneau can hold more than one page of courses.
  Future<List<RunDto>> _getAllRuns(int slotId) async {
    final runs = <RunDto>[];
    var start = 0;
    while (true) {
      final batch = await _dataSource.getRuns(
        slotId,
        start: start,
        length: _pageSize,
      );
      runs.addAll(batch);
      if (batch.length < _pageSize) break;
      start += _pageSize;
    }
    return runs;
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
