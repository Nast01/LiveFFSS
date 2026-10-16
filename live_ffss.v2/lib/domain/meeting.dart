import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/heat.dart';

part 'meeting.freezed.dart';

/// Un élément de réunion (un « créneau » FFSS), comme `MeetingItem` dans
/// FFSSCompetition V3.
@freezed
abstract class MeetingItem with _$MeetingItem {
  const factory MeetingItem({
    required int id,
    required String name,

    /// La « partie » FFSS que le créneau couvre, comme `MeetingItem.RoundId`
    /// dans V3. Nulle pour un créneau sans tour.
    int? roundId,
    @Default(<Heat>[]) List<Heat> heats,
  }) = _MeetingItem;
}

/// Une réunion d'une compétition, comme `Meeting` dans FFSSCompetition V3.
@freezed
abstract class Meeting with _$Meeting {
  const factory Meeting({
    required int id,
    required String name,
    required DateTime day,
    DateTime? startTime,
    DateTime? endTime,
    @Default(<MeetingItem>[]) List<MeetingItem> items,
  }) = _Meeting;
}
