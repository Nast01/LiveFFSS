import 'package:live_ffss_v2/data/ffss/dtos/officiel_dto.dart';
import 'package:live_ffss_v2/domain/officials.dart';

extension OfficielMapper on OfficielDto {
  /// Nul sans id.
  CompetitionOfficial? toDomain() {
    final id = this.id;
    if (id == null) return null;
    final name = [lastName, firstName]
        .map((part) => part?.trim() ?? '')
        .where((part) => part.isNotEmpty)
        .join(' ');
    return CompetitionOfficial(
      id: id,
      name: name,
      level: level?.trim() ?? '',
      principal: principal ?? false,
      days: [
        for (final day in days ?? const <Object?>[])
          if (day is int) day else if (day is String) ?int.tryParse(day),
      ],
      daysLabel: daysLabel?.trim() ?? '',
      club: club?.trim() ?? '',
    );
  }
}
