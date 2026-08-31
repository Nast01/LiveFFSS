import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/result.dart';

part 'lane.freezed.dart';
part 'lane.g.dart';

/// One numbered spot in a course: FFSS's « place ».
///
/// Named a lane rather than a place because in English a competitor's *place*
/// is where they finished — [Result.rank] already means that. This is where
/// they start.
///
/// A course holds as many lanes as its round declares in
/// `RaceFormatDetail.spotsPerRace`; [entry] and [result] fill in as the
/// competition runs, and are null on a lane nobody has been assigned to yet.
@freezed
class Lane with _$Lane {
  const factory Lane({
    required int id,
    @Default(0) int number,
    @Default('') String label,
    Entry? entry,
    Result? result,
  }) = _Lane;

  factory Lane.fromJson(Map<String, dynamic> json) => _$LaneFromJson(json);
}

extension LaneX on Lane {
  bool get isEmpty => entry == null;
  int? get currentRank => result?.rank;
  int? get currentTime => result?.time;
  String? get currentTimeLabel => result?.timeLabel;
  bool get hasValidResult => result?.isValid == true;
  bool get isDisqualified => result?.isDisqualified == true;
}
