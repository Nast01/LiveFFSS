import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/data/models/meeting_model.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

class ProgramController extends GetxController {
  ProgramController(this._meetingRepo);

  final MeetingRepository _meetingRepo;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxBool isCreatingMeeting = false.obs;
  final RxList<MeetingModel> meetings = <MeetingModel>[].obs;
  final Rxn<UiMessage> message = Rxn<UiMessage>();

  void setCompetition(Competition? newCompetition) {
    competition.value = newCompetition;
    if (newCompetition != null) {
      loadMeetings();
    } else {
      meetings.clear();
    }
  }

  Future<void> loadMeetings() async {
    final id = competition.value?.id;
    if (id == null) return;
    try {
      isLoading.value = true;
      hasError.value = false;

      final loaded = await _meetingRepo.getMeetings(id);
      loaded.sort((a, b) {
        final dateCmp = a.date.compareTo(b.date);
        if (dateCmp != 0) return dateCmp;
        return a.beginHour.compareTo(b.beginHour);
      });
      meetings.value = loaded;
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitMeeting({
    required String name,
    required String description,
    required DateTime date,
    required TimeOfDay beginTime,
    required TimeOfDay endTime,
  }) async {
    final competitionId = competition.value?.id;
    if (competitionId == null) return false;

    final beginDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      beginTime.hour,
      beginTime.minute,
    );
    final endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    if (endDateTime.isBefore(beginDateTime)) {
      message.value = const UiMessageError('end_time_must_be_after_begin_time');
      return false;
    }

    try {
      isCreatingMeeting.value = true;
      final meeting = MeetingModel(
        id: 0,
        name: name.trim(),
        description: description.trim(),
        date: date,
        beginHour: beginDateTime,
        endHour: endDateTime,
      );
      await _meetingRepo.createMeeting(meeting, competitionId);
      message.value = const UiMessageSuccess('meeting_created_successfully');
      await loadMeetings();
      return true;
    } catch (_) {
      message.value = const UiMessageError('failed_to_create_meeting');
      return false;
    } finally {
      isCreatingMeeting.value = false;
    }
  }

  Future<void> deleteMeeting(MeetingModel meeting) async {
    if (competition.value == null) return;
    try {
      final success = await _meetingRepo.deleteMeeting(meeting.id);
      if (success) {
        meetings.remove(meeting);
        message.value = const UiMessageSuccess('meeting_deleted_successfully');
      } else {
        message.value = const UiMessageError('failed_to_delete_meeting');
      }
    } catch (_) {
      message.value = const UiMessageError('failed_to_delete_meeting');
    }
  }

  int get totalSlotsCount =>
      meetings.isNotEmpty ? meetings.first.slots.length : 0;
}
