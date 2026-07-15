import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/club.dart';

part 'entry.freezed.dart';
part 'entry.g.dart';

@freezed
class Entry with _$Entry {
  const factory Entry({
    required int id,
    @Default(0) int raceId,
    required Category category,
    Club? organisme,
    required int status,
    required String statusLabel,
    @Default(0) int entryTime,
    @Default('') String entryTimeLabel,
    @Default(false) bool isForfeit,
    @Default(<Athlete>[]) List<Athlete> athletes,
  }) = _Entry;

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);
}
