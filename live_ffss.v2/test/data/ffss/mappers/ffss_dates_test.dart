import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/data/ffss/mappers/ffss_dates.dart';

void main() {
  group('parseFfssDay', () {
    test('lit une date seule ou une date avec heure, et garde le jour', () {
      expect(parseFfssDay('2026-03-27'), DateTime(2026, 3, 27));
      expect(parseFfssDay('2026-03-27 14:30:00'), DateTime(2026, 3, 27));
    });

    test('absente, vide ou illisible : nulle', () {
      expect(parseFfssDay(null), isNull);
      expect(parseFfssDay(''), isNull);
      expect(parseFfssDay('bientôt'), isNull);
    });
  });

  group('atFfssTime', () {
    final day = DateTime(2026, 3, 27);

    test('lit HH:mm, HH:mm:ss et une date-heure complète', () {
      expect(atFfssTime(day, '08:46'), DateTime(2026, 3, 27, 8, 46));
      expect(atFfssTime(day, '08:46:00'), DateTime(2026, 3, 27, 8, 46));
      expect(
        atFfssTime(day, '2026-03-27 08:46:00'),
        DateTime(2026, 3, 27, 8, 46),
      );
    });

    test('absente, vide ou illisible : nulle', () {
      expect(atFfssTime(day, null), isNull);
      expect(atFfssTime(day, ''), isNull);
      expect(atFfssTime(day, 'midi'), isNull);
      expect(atFfssTime(day, '25:00'), isNull);
    });
  });
}
