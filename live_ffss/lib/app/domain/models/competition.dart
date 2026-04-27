import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/club.dart';

part 'competition.freezed.dart';
part 'competition.g.dart';

enum EntryStatus { open, closed, soon, unknown }

enum CompetitionStatus { coming, onGoing, done, unknown }

@freezed
class Competition with _$Competition {
  const factory Competition({
    required int id,
    required String name,
    DateTime? beginDate,
    DateTime? endDate,
    DateTime? beginEntryLimitDate,
    DateTime? endEntryLimitDate,
    String? location,
    required int statusCode,
    required String statusLabel,
    String? description,
    required int speciality,
    required String specialityLabel,
    required String typeWater,
    required String typePool,
    required String typeChrono,
    required bool isEligibleToNationalRecord,
    required int numberOfLanes,
    required String organizer,
    required bool hasBegun,
    required bool hasResult,
    required bool hasPassed,
    required int level,
    required String levelLabel,
    required Club organizerClub,
    String? refereePrincipal,
  }) = _Competition;

  factory Competition.fromJson(Map<String, dynamic> json) =>
      _$CompetitionFromJson(json);
}
