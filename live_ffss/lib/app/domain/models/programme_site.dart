import 'package:freezed_annotation/freezed_annotation.dart';

part 'programme_site.freezed.dart';
part 'programme_site.g.dart';

enum SiteType { cotier, sable, unknown }

@freezed
class ProgrammeSite with _$ProgrammeSite {
  const factory ProgrammeSite({
    required int id,
    required String name,
    required SiteType type,
  }) = _ProgrammeSite;

  factory ProgrammeSite.fromJson(Map<String, dynamic> json) =>
      _$ProgrammeSiteFromJson(json);
}
