import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/network/http_log.dart';
import 'package:live_ffss/app/module/debug/controllers/http_log_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

HttpLogEntry _entry(String url) => HttpLogEntry(
      at: DateTime(2026, 9, 10),
      method: 'GET',
      url: url,
      durationMs: 5,
      statusCode: 200,
    );

void main() {
  late _MockSecureStorage storage;
  late HttpLogController controller;

  setUp(() {
    storage = _MockSecureStorage();
    when(() =>
            storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    httpLog
      ..clear()
      ..enabled = false;
    controller = HttpLogController(storage);
  });

  tearDown(() {
    httpLog
      ..clear()
      ..enabled = false;
  });

  test('refreshEntries prend un instantane du journal', () {
    httpLog.enabled = true;
    httpLog.record(_entry('a'));

    controller.refreshEntries();

    expect(controller.entries.map((e) => e.url).toList(), ['a']);
  });

  test('setEnabled allume le journal et persiste le choix', () async {
    await controller.setEnabled(true);

    expect(httpLog.enabled, isTrue);
    expect(controller.isEnabled.value, isTrue);
    verify(() => storage.write(key: 'debug_http_log', value: 'true')).called(1);
  });

  test('setEnabled eteint le journal et persiste le choix', () async {
    await controller.setEnabled(true);

    await controller.setEnabled(false);

    expect(httpLog.enabled, isFalse);
    verify(() => storage.write(key: 'debug_http_log', value: 'false'))
        .called(1);
  });

  test('clear vide le journal et l\'instantane', () {
    httpLog.enabled = true;
    httpLog.record(_entry('a'));
    controller.refreshEntries();

    controller.clear();

    expect(httpLog.entries, isEmpty);
    expect(controller.entries, isEmpty);
  });
}
