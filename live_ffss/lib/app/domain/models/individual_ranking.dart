import 'package:freezed_annotation/freezed_annotation.dart';

part 'individual_ranking.freezed.dart';
part 'individual_ranking.g.dart';

@freezed
class IndividualRanking with _$IndividualRanking {
  const factory IndividualRanking({
    @Default(0) int position,
    @Default('') String athleteFirstName,
    @Default('') String athleteLastName,
    @Default('') String clubName,
    @Default(0) int points,
  }) = _IndividualRanking;

  factory IndividualRanking.fromJson(Map<String, dynamic> json) =>
      _$IndividualRankingFromJson(json);
}
