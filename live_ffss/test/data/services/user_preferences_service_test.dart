import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  setUpAll(() {
    registerFallbackValue('');
  });

  late _MockSecureStorage storage;
  late UserPreferencesService prefs;

  setUp(() {
    storage = _MockSecureStorage();
    prefs = UserPreferencesService(storage);
  });

  group('UserPreferencesService.init', () {
    test('reads existing JSON for both keys and populates Rx collections',
        () async {
      when(() => storage.read(key: 'favorite_competitions'))
          .thenAnswer((_) async => '[1,2,3]');
      when(() => storage.read(key: 'last_viewed_competitions'))
          .thenAnswer((_) async => '[10,20,30]');

      await prefs.init();

      expect(prefs.favoriteIds, {1, 2, 3});
      expect(prefs.lastViewedIds, [10, 20, 30]);
    });

    test('tolerates missing keys (empty defaults)', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      await prefs.init();

      expect(prefs.favoriteIds, isEmpty);
      expect(prefs.lastViewedIds, isEmpty);
    });

    test('tolerates corrupt JSON (returns empty defaults)', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'not-valid-json{{{');

      await prefs.init();

      expect(prefs.favoriteIds, isEmpty);
      expect(prefs.lastViewedIds, isEmpty);
    });
  });

  group('UserPreferencesService.toggleFavorite', () {
    test('adds id when absent, removes when present, persists JSON',
        () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      when(() => storage.write(
              key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});
      await prefs.init();

      await prefs.toggleFavorite(7);
      expect(prefs.favoriteIds, {7});
      verify(() => storage.write(
          key: 'favorite_competitions', value: jsonEncode([7]))).called(1);

      await prefs.toggleFavorite(7);
      expect(prefs.favoriteIds, isEmpty);
      verify(() => storage.write(
          key: 'favorite_competitions',
          value: jsonEncode(<int>[]))).called(1);
    });

    test('isFavorite reflects in-memory state', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => '[42]');
      await prefs.init();

      expect(prefs.isFavorite(42), isTrue);
      expect(prefs.isFavorite(99), isFalse);
    });
  });

  group('UserPreferencesService.recordView', () {
    test('moves id to front and dedupes', () async {
      when(() => storage.read(key: 'favorite_competitions'))
          .thenAnswer((_) async => null);
      when(() => storage.read(key: 'last_viewed_competitions'))
          .thenAnswer((_) async => '[3,1,2]');
      when(() => storage.write(
              key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});
      await prefs.init();

      await prefs.recordView(2);

      expect(prefs.lastViewedIds, [2, 3, 1]);
      verify(() => storage.write(
          key: 'last_viewed_competitions',
          value: jsonEncode([2, 3, 1]))).called(1);
    });

    test('caps the list at 20 entries', () async {
      when(() => storage.read(key: 'favorite_competitions'))
          .thenAnswer((_) async => null);
      // Initial list = [20, 19, ..., 1] (newest first, 20 items).
      final initial = List.generate(20, (i) => 20 - i);
      when(() => storage.read(key: 'last_viewed_competitions'))
          .thenAnswer((_) async => jsonEncode(initial));
      when(() => storage.write(
              key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});
      await prefs.init();

      await prefs.recordView(99);

      expect(prefs.lastViewedIds.length, 20);
      expect(prefs.lastViewedIds.first, 99);
      expect(prefs.lastViewedIds.last, 2); // 1 dropped from the tail
    });
  });
}
