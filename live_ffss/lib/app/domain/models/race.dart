import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';

part 'race.freezed.dart';
part 'race.g.dart';

@freezed
class Race with _$Race {
  const factory Race({
    required int id,
    required String name,
    required String nameEnglish,
    required int distance,
    required Gender gender,
    required int athletesPerTeam,
    required int specialityId,
    required String specialityLabel,
    required int disciplineId,
    required bool isEligibleToNationalRecord,
    required List<Category> categories,
  }) = _Race;

  factory Race.fromJson(Map<String, dynamic> json) => _$RaceFromJson(json);
}
