import 'package:freezed_annotation/freezed_annotation.dart';

part 'heat.freezed.dart';
part 'heat.g.dart';

@freezed
class Heat with _$Heat {
  const factory Heat({
    required int id,
    required String name,
    required bool done,
    required int number,
  }) = _Heat;

  factory Heat.fromJson(Map<String, dynamic> json) => _$HeatFromJson(json);
}
