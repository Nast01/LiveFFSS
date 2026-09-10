import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/network/http_log.dart';

HttpLogEntry _entry(String url) => HttpLogEntry(
      at: DateTime(2026, 9, 10),
      method: 'GET',
      url: url,
      durationMs: 12,
      statusCode: 200,
    );

void main() {
  setUp(() {
    httpLog
      ..clear()
      ..enabled = false;
  });

  group('HttpLog.record', () {
    test('n\'enregistre rien tant que le journal est eteint', () {
      httpLog.record(_entry('a'));

      expect(httpLog.entries, isEmpty);
    });

    test('enregistre les entrees les plus recentes en premier', () {
      httpLog.enabled = true;

      httpLog.record(_entry('a'));
      httpLog.record(_entry('b'));

      expect(httpLog.entries.map((e) => e.url).toList(), ['b', 'a']);
    });

    test('plafonne a 50 entrees en laissant tomber les plus anciennes', () {
      httpLog.enabled = true;

      for (var i = 0; i < 51; i++) {
        httpLog.record(_entry('url-$i'));
      }

      expect(httpLog.entries.length, HttpLog.capacity);
      expect(httpLog.entries.first.url, 'url-50');
      expect(httpLog.entries.last.url, 'url-1');
    });

    test('la liste exposee n\'est pas modifiable', () {
      httpLog.enabled = true;
      httpLog.record(_entry('a'));

      expect(() => httpLog.entries.add(_entry('b')), throwsUnsupportedError);
    });
  });

  group('HttpLog.truncate', () {
    test('laisse un corps court intact', () {
      expect(HttpLog.truncate('court'), 'court');
    });

    test('rend null pour un corps absent', () {
      expect(HttpLog.truncate(null), isNull);
    });

    test('tronque un corps trop long en le disant', () {
      final long = 'x' * (HttpLog.bodyLimit + 10);

      final result = HttpLog.truncate(long)!;

      expect(result.length, lessThan(long.length));
      expect(result, startsWith('x' * 100));
      expect(result, contains('tronqué'));
    });
  });

  group('HttpLog.clear', () {
    test('vide le journal', () {
      httpLog.enabled = true;
      httpLog.record(_entry('a'));

      httpLog.clear();

      expect(httpLog.entries, isEmpty);
    });
  });
}
