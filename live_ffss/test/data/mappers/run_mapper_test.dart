import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/run_dto.dart';
import 'package:live_ffss/app/data/mappers/run_mapper.dart';
import 'package:live_ffss/app/domain/models/run.dart';

void main() {
  test('RunMapper parses begin/end times and status int', () {
    final dto = RunDto.fromJson(const {
      'id': 1,
      'Nom': 'Run 1',
      'label': 'L',
      'fullLabel': 'FL',
      'statut': 2,
      'statutLabel': 'In Progress',
      'site': 'Pool A',
      'debut': '10:00',
      'fin': '11:30',
    });
    final r = dto.toDomain();
    expect(r.id, 1);
    expect(r.status, RunStatus.inProgress);
    expect(r.beginTime.hour, 10);
    expect(r.endTime.hour, 11);
  });

  test('RunMapper handles unknown status code', () {
    final dto = RunDto.fromJson(const {
      'id': 1,
      'Nom': 'X',
      'label': 'X',
      'fullLabel': 'X',
      'statut': 99,
      'statutLabel': '',
      'site': '',
      'debut': '00:00',
      'fin': '00:00',
    });
    expect(dto.toDomain().status, RunStatus.unknown);
  });
}
