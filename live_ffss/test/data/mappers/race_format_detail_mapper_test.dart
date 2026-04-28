import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/race_format_detail_dto.dart';
import 'package:live_ffss/app/data/mappers/race_format_detail_mapper.dart';

void main() {
  test('RaceFormatDetailMapper maps full DTO', () {
    const dto = RaceFormatDetailDto(
      id: 1,
      order: 2,
      label: 'L',
      fullLabel: 'FL',
      levelLabel: 'NL',
      level: 'eau-plate',
      numberOfRun: 4,
      qualificationMethod: 'time',
      qualificationMethodLabel: 'TimeLabel',
      spotsPerRace: 8,
      qualifyingSpots: 2,
    );
    final d = dto.toDomain();
    expect(d.id, 1);
    expect(d.numberOfRun, 4);
    expect(d.level, 'eau-plate');
  });
}
