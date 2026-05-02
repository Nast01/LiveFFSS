import 'package:freezed_annotation/freezed_annotation.dart';

part 'relay_ranking.freezed.dart';
part 'relay_ranking.g.dart';

@freezed
class RelayRanking with _$RelayRanking {
  const factory RelayRanking({
    @Default(0) int position,
    @Default('') String clubName,
    @Default('') String teamName,
    @Default(0) int points,
  }) = _RelayRanking;

  factory RelayRanking.fromJson(Map<String, dynamic> json) =>
      _$RelayRankingFromJson(json);
}
