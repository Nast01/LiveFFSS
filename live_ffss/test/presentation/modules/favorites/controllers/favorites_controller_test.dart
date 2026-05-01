import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/module/favorites/controllers/favorites_controller.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockHome extends Mock implements HomeController {}

class _MockPrefs extends Mock implements UserPreferencesService {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.testMode = true;
  });

  Competition c(int id) => Competition(
        id: id,
        name: 'C$id',
        beginDate: null,
        endDate: null,
        location: null,
        statusCode: 0,
        statusLabel: '',
        speciality: 0,
        specialityLabel: '',
        typeWater: 'N/A',
        typePool: '',
        typeChrono: '',
        isEligibleToNationalRecord: false,
        numberOfLanes: 0,
        organizer: 'X',
        hasBegun: false,
        hasResult: false,
        hasPassed: false,
        level: 0,
        levelLabel: '',
        organizerClub: const Club(id: 1, name: 'X'),
      );

  late _MockHome home;
  late _MockPrefs prefs;
  late FavoritesController controller;

  setUp(() {
    home = _MockHome();
    prefs = _MockPrefs();
    when(() => home.competitions).thenReturn(<Competition>[].obs);
    when(() => home.isLoading).thenReturn(false.obs);
    when(() => home.hasError).thenReturn(false.obs);
    when(() => home.loadCompetitions()).thenAnswer((_) async {});
    when(() => prefs.favoriteIds).thenReturn(<int>{}.obs);
    when(() => prefs.toggleFavorite(any())).thenAnswer((_) async {});
    controller = FavoritesController(home, prefs);
  });

  tearDown(() {
    Get.reset();
  });

  group('favoriteCompetitions', () {
    test('returns competitions whose id is in favoriteIds', () {
      when(() => home.competitions)
          .thenReturn(<Competition>[c(1), c(2), c(3)].obs);
      when(() => prefs.favoriteIds).thenReturn(<int>{1, 3}.obs);

      final result =
          controller.favoriteCompetitions.map((x) => x.id).toList();
      expect(result, [1, 3]);
    });

    test('returns empty when no favorites', () {
      when(() => home.competitions)
          .thenReturn(<Competition>[c(1), c(2)].obs);
      when(() => prefs.favoriteIds).thenReturn(<int>{}.obs);

      expect(controller.favoriteCompetitions, isEmpty);
    });

    test('returns empty when home has no competitions loaded', () {
      when(() => home.competitions).thenReturn(<Competition>[].obs);
      when(() => prefs.favoriteIds).thenReturn(<int>{1, 2}.obs);

      expect(controller.favoriteCompetitions, isEmpty);
    });

    test('excludes favorited ids that are not in home.competitions', () {
      when(() => home.competitions).thenReturn(<Competition>[c(1)].obs);
      when(() => prefs.favoriteIds).thenReturn(<int>{1, 99}.obs);

      final result =
          controller.favoriteCompetitions.map((x) => x.id).toList();
      expect(result, [1]);
    });
  });

  group('onInit', () {
    test('triggers loadCompetitions when home is empty/idle/no-error', () {
      when(() => home.competitions).thenReturn(<Competition>[].obs);
      when(() => home.isLoading).thenReturn(false.obs);
      when(() => home.hasError).thenReturn(false.obs);

      controller.onInit();

      verify(() => home.loadCompetitions()).called(1);
    });

    test('does NOT trigger load when home is already loading', () {
      when(() => home.competitions).thenReturn(<Competition>[].obs);
      when(() => home.isLoading).thenReturn(true.obs);
      when(() => home.hasError).thenReturn(false.obs);

      controller.onInit();

      verifyNever(() => home.loadCompetitions());
    });

    test('does NOT trigger load when home already has competitions', () {
      when(() => home.competitions).thenReturn(<Competition>[c(1)].obs);
      when(() => home.isLoading).thenReturn(false.obs);
      when(() => home.hasError).thenReturn(false.obs);

      controller.onInit();

      verifyNever(() => home.loadCompetitions());
    });

    test('does NOT trigger load when home has errored', () {
      when(() => home.competitions).thenReturn(<Competition>[].obs);
      when(() => home.isLoading).thenReturn(false.obs);
      when(() => home.hasError).thenReturn(true.obs);

      controller.onInit();

      verifyNever(() => home.loadCompetitions());
    });
  });

  group('toggleFavorite', () {
    test('delegates to prefs.toggleFavorite', () async {
      await controller.toggleFavorite(42);
      verify(() => prefs.toggleFavorite(42)).called(1);
    });
  });

  group('pass-through getters', () {
    test('isLoading returns the home controller\'s observable', () {
      final isLoadingRx = false.obs;
      when(() => home.isLoading).thenReturn(isLoadingRx);
      expect(controller.isLoading, same(isLoadingRx));
    });

    test('hasError returns the home controller\'s observable', () {
      final hasErrorRx = false.obs;
      when(() => home.hasError).thenReturn(hasErrorRx);
      expect(controller.hasError, same(hasErrorRx));
    });

    test('competitions returns the home controller\'s list', () {
      final list = <Competition>[c(1), c(2)].obs;
      when(() => home.competitions).thenReturn(list);
      expect(controller.competitions, same(list));
    });

    test('favoriteIds returns the prefs service set', () {
      final favs = <int>{1, 2}.obs;
      when(() => prefs.favoriteIds).thenReturn(favs);
      expect(controller.favoriteIds, same(favs));
    });
  });
}
