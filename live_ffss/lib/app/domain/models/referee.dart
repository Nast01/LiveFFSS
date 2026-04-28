import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';

part 'referee.freezed.dart';
part 'referee.g.dart';

@freezed
class Referee with _$Referee {
  const factory Referee({
    required int id,
    required String licenseeNumber,
    required String firstName,
    required String lastName,
    required Gender gender,
    required int year,
    required String level,
    required String levelMax,
    required String nationalityCode,
    required String nationality,
    required bool isValid,
    @Default(false) bool isLicensee,
    @Default(false) bool isGuest,
    @Default(false) bool isPrincipal,
    @Default(<int>[]) List<int> availabilities,
  }) = _Referee;

  factory Referee.fromJson(Map<String, dynamic> json) =>
      _$RefereeFromJson(json);
}
