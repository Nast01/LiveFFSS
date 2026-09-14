import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';

void main() {
  Meeting meeting(String description) => Meeting(
        id: 1,
        name: 'Matin',
        description: description,
        date: DateTime(2026, 9, 12),
        beginHour: DateTime(2026, 9, 12, 8),
        endHour: DateTime(2026, 9, 12, 8),
      );

  test('the site is the réunion description', () {
    expect(meeting('Plage').site, 'Plage');
  });

  test('a réunion with no description has no site', () {
    expect(meeting('').site, isEmpty);
  });
}
