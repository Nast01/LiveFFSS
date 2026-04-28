import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/result.dart';

part 'live_result.freezed.dart';
part 'live_result.g.dart';

@freezed
class LiveResult with _$LiveResult {
  const factory LiveResult({
    required int id,
    @Default('') String number,
    Entry? entry,
    Result? result,
  }) = _LiveResult;

  factory LiveResult.fromJson(Map<String, dynamic> json) =>
      _$LiveResultFromJson(json);
}

extension LiveResultX on LiveResult {
  int? get currentRank => result?.rank;
  int? get currentTime => result?.time;
  String? get currentTimeLabel => result?.timeLabel;
  bool get hasValidResult => result?.isValid == true;
  bool get isDisqualified => result?.isDisqualified == true;
}
