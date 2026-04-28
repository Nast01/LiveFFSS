import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/referee.dart';

part 'club.freezed.dart';
part 'club.g.dart';

@freezed
class Club with _$Club {
  const factory Club({
    required int id,
    required String name,
    String? shortName,
    String? logoUrl,
    String? capUrl,
    @Default(<Athlete>[]) List<Athlete> athletes,
    @Default(<Referee>[]) List<Referee> referees,
  }) = _Club;

  factory Club.fromJson(Map<String, dynamic> json) => _$ClubFromJson(json);
}
