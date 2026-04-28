import 'package:live_ffss/app/data/models/meeting_model.dart';
import 'package:live_ffss/app/data/services/api_service.dart';

/// Transitional shim around ApiService for the Program module.
///
/// Returns legacy [MeetingModel] — full domain migration of Meeting +
/// Slot + Run is bundled with Batch 5's slot work. This file goes away
/// when MeetingDto/Meeting domain land.
abstract class MeetingRepository {
  Future<List<MeetingModel>> getMeetings(int competitionId);
  Future<bool?> createMeeting(MeetingModel meeting, int competitionId);
  Future<bool> deleteMeeting(int meetingId);
}

class MeetingRepositoryImpl implements MeetingRepository {
  MeetingRepositoryImpl(this._api);

  final ApiService _api;

  @override
  Future<List<MeetingModel>> getMeetings(int competitionId) =>
      _api.getMeetings(competitionId);

  @override
  Future<bool?> createMeeting(MeetingModel meeting, int competitionId) =>
      _api.createMeeting(meeting, competitionId);

  @override
  Future<bool> deleteMeeting(int meetingId) => _api.deleteMeeting(meetingId);
}
