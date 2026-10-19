import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/network/network_log.dart';
import 'package:live_ffss_v2/features/admin/admin_formatting.dart';

NetworkLogEntry _entry(String path, {String? error}) => NetworkLogEntry(
  at: DateTime(2026, 10, 19),
  method: 'GET',
  path: path,
  duration: Duration.zero,
  server: 'Développement',
  error: error,
);

void main() {
  test('formatDuration: millisecondes sous la seconde, secondes au-delà', () {
    expect(formatDuration(const Duration(milliseconds: 85)), '85 ms');
    expect(formatDuration(const Duration(milliseconds: 999)), '999 ms');
    expect(formatDuration(const Duration(milliseconds: 1250)), '1.3 s');
    expect(formatDuration(const Duration(seconds: 30)), '30.0 s');
  });

  test('formatBytes: o, Ko, Mo, et un tiret sans réponse', () {
    expect(formatBytes(null), '-');
    expect(formatBytes(0), '0 o');
    expect(formatBytes(820), '820 o');
    expect(formatBytes(12595), '12.3 Ko');
    expect(formatBytes(1572864), '1.5 Mo');
  });

  test('visibleEntries: erreurs seulement, ordre conservé', () {
    final all = [
      _entry('/a'),
      _entry('/b', error: 'NetworkException'),
      _entry('/c'),
      _entry('/d', error: 'ApiException'),
    ];
    expect(visibleEntries(all, errorsOnly: false), all);
    expect(visibleEntries(all, errorsOnly: true).map((e) => e.path), [
      '/b',
      '/d',
    ]);
  });
}
