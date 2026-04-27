import 'package:freezed_annotation/freezed_annotation.dart';

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
    @Default(<dynamic>[]) List<dynamic> athletes,
    @Default(<dynamic>[]) List<dynamic> referees,
  }) = _Club;

  factory Club.fromJson(Map<String, dynamic> json) => _$ClubFromJson(json);
}
