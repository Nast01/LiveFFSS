import 'package:freezed_annotation/freezed_annotation.dart';

part 'club_ranking.freezed.dart';
part 'club_ranking.g.dart';

@freezed
class ClubRanking with _$ClubRanking {
  const factory ClubRanking({
    @Default(0) int position,
    @Default('') String clubName,
    @Default(0) int points,
  }) = _ClubRanking;

  factory ClubRanking.fromJson(Map<String, dynamic> json) =>
      _$ClubRankingFromJson(json);
}
