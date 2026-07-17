import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/rfid/rfid_writer.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockPrefs extends Mock implements UserPreferencesService {}

class _MockRfidWriter extends Mock implements RfidWriter {}

void main() {
  late _MockPrefs prefs;
  late _MockRfidWriter writer;

  setUp(() {
    prefs = _MockPrefs();
    writer = _MockRfidWriter();
  });

  group('canWriteBracelets', () {
    test('is true when the writer is supported', () {
      when(() => writer.isSupported).thenReturn(true);
      final controller = CompetitionDetailController(prefs, writer);
      expect(controller.canWriteBracelets, isTrue);
    });

    test('is false when the writer is a stub', () {
      when(() => writer.isSupported).thenReturn(false);
      final controller = CompetitionDetailController(prefs, writer);
      expect(controller.canWriteBracelets, isFalse);
    });
  });

  group('favorites', () {
    test('favoriteIds is delegated to the preferences service', () {
      final ids = <int>{7}.obs;
      when(() => prefs.favoriteIds).thenReturn(ids);
      when(() => writer.isSupported).thenReturn(true);

      final controller = CompetitionDetailController(prefs, writer);

      expect(controller.favoriteIds, ids);
    });

    test('toggleFavorite is delegated to the preferences service', () async {
      when(() => prefs.toggleFavorite(7)).thenAnswer((_) async {});
      when(() => writer.isSupported).thenReturn(true);

      await CompetitionDetailController(prefs, writer).toggleFavorite(7);

      verify(() => prefs.toggleFavorite(7)).called(1);
    });
  });
}
