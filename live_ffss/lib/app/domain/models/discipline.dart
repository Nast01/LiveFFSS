import 'package:freezed_annotation/freezed_annotation.dart';

part 'discipline.freezed.dart';
part 'discipline.g.dart';

@freezed
class Discipline with _$Discipline {
  const factory Discipline({
    required String id,
    required String name,
    required int speciality,
    required String specialityLabel,
    @Default(0) int distance,
    @Default(0) int numberOfAthletes,
    @Default(false) bool isRelay,
    @Default(false) bool hasTime,
  }) = _Discipline;

  factory Discipline.fromJson(Map<String, dynamic> json) =>
      _$DisciplineFromJson(json);
}
