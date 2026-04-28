import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/meeting_dto.dart';
import 'package:live_ffss/app/data/mappers/meeting_mapper.dart';

void main() {
  test('MeetingMapper composes date + times into full DateTimes', () {
    final dto = MeetingDto.fromJson(const {
      'Id': 1,
      'Nom': 'M',
      'Description': '',
      'Jour': '2026-05-01',
      'Debut': '10:00',
      'Fin': '12:00',
    });
    final m = dto.toDomain();
    expect(m.id, 1);
    expect(m.date, DateTime(2026, 5, 1));
    expect(m.beginHour, DateTime(2026, 5, 1, 10, 0));
    expect(m.endHour, DateTime(2026, 5, 1, 12, 0));
    expect(m.slots, isEmpty);
  });

  test('MeetingMapper parses embedded slots and sorts by begin time', () {
    final dto = MeetingDto.fromJson(const {
      'Id': 1,
      'Nom': 'M',
      'Description': '',
      'Jour': '2026-05-01',
      'Debut': '10:00',
      'Fin': '14:00',
      'creneaus': [
        {'id': 2, 'Nom': 'B', 'Debut': '12:00', 'Fin': '13:00'},
        {'id': 1, 'Nom': 'A', 'Debut': '10:30', 'Fin': '11:30'},
      ],
    });
    final m = dto.toDomain();
    expect(m.slots.length, 2);
    expect(m.slots.first.id, 1); // A first (10:30 < 12:00)
  });
}
