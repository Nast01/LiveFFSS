import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/ranking_repository.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/club_ranking.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/individual_ranking.dart';
import 'package:live_ffss/app/domain/models/relay_ranking.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_points_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements RankingRepository {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.testMode = true;
  });

  Competition competitionFixture(int id) => Competition(
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

  late _MockRepo repo;
  late CompetitionDetailPointsController controller;

  setUp(() {
    repo = _MockRepo();
    when(() => repo.getClubRankings(any()))
        .thenAnswer((_) async => const <ClubRanking>[]);
    when(() => repo.getIndividualRankings(any()))
        .thenAnswer((_) async => const <IndividualRanking>[]);
    when(() => repo.getRelayRankings(any()))
        .thenAnswer((_) async => const <RelayRanking>[]);
    controller = CompetitionDetailPointsController(repo);
  });

  tearDown(() {
    Get.reset();
  });

  group('selectedPointsTab', () {
    test('starts at 0', () {
      expect(controller.selectedPointsTab.value, 0);
    });

    test('setPointsTab updates the value', () {
      controller.setPointsTab(2);
      expect(controller.selectedPointsTab.value, 2);
      controller.setPointsTab(0);
      expect(controller.selectedPointsTab.value, 0);
    });
  });

  group('loadRankings', () {
    test('populates all three RxList fields and clears flags', () async {
      when(() => repo.getClubRankings(any())).thenAnswer((_) async => const [
            ClubRanking(position: 1, clubName: 'Alpha', points: 100),
          ]);
      when(() => repo.getIndividualRankings(any()))
          .thenAnswer((_) async => const [
                IndividualRanking(
                  position: 1,
                  athleteFirstName: 'Alice',
                  athleteLastName: 'Doe',
                  clubName: 'Alpha',
                  points: 200,
                ),
              ]);
      when(() => repo.getRelayRankings(any())).thenAnswer((_) async => const [
            RelayRanking(
              position: 1,
              clubName: 'Alpha',
              teamName: 'A1',
              points: 150,
            ),
          ]);

      await controller.loadRankings(42);

      expect(controller.clubRankings, hasLength(1));
      expect(controller.individualRankings, hasLength(1));
      expect(controller.relayRankings, hasLength(1));
      expect(controller.isLoading.value, false);
      expect(controller.hasError.value, false);
    });

    test('on AppException sets hasError and clears loading', () async {
      when(() => repo.getClubRankings(any()))
          .thenThrow(const NetworkException('offline'));

      await controller.loadRankings(42);

      expect(controller.hasError.value, true);
      expect(controller.isLoading.value, false);
    });
  });

  group('onInit', () {
    test('does NOT load when Get.arguments is not a Competition', () {
      controller.onInit();

      verifyNever(() => repo.getClubRankings(any()));
      expect(controller.competition.value, isNull);
    });
  });

  group('retry', () {
    test('re-runs loadRankings using the stored competition id', () async {
      controller.competition.value = competitionFixture(99);

      await controller.retry();

      verify(() => repo.getClubRankings(99)).called(1);
      verify(() => repo.getIndividualRankings(99)).called(1);
      verify(() => repo.getRelayRankings(99)).called(1);
    });

    test('is a no-op when competition is null', () async {
      await controller.retry();

      verifyNever(() => repo.getClubRankings(any()));
    });
  });
}
