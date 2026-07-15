import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/result.dart';

part 'heat.freezed.dart';
part 'heat.g.dart';

@freezed
class Heat with _$Heat {
  const factory Heat({
    @Default(0) int id,
    @Default('') String name,
    @Default(false) bool done,
    @Default(0) int number,
    DateTime? updatedAt,
    DateTime? startDate,
    DateTime? endDate,
    Race? race,
    @Default(<Result>[]) List<Result> results,
  }) = _Heat;

  factory Heat.fromJson(Map<String, dynamic> json) => _$HeatFromJson(json);
}
