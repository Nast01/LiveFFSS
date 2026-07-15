import 'package:live_ffss/app/data/dtos/heat_dto.dart';
import 'package:live_ffss/app/data/mappers/race_mapper.dart';
import 'package:live_ffss/app/data/mappers/result_mapper.dart';
import 'package:live_ffss/app/domain/models/heat.dart';

extension HeatMapper on HeatDto {
  Heat toDomain() => Heat(
        id: id,
        name: name,
        done: done,
        number: number,
        updatedAt: _parseDate(updatedAt),
        startDate: _parseDate(startDate),
        endDate: _parseDate(endDate),
        race: race?.toDomain(),
        // Drop the back-ref to the parent heat to avoid Heat <-> Result cycle.
        results:
            results.map((r) => r.toDomain(includeParents: false)).toList(),
      );
}

// FFSS dates come as 'Y-m-d H:i:s'. Treat invalid/empty as null.
DateTime? _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw.replaceFirst(' ', 'T'));
}
