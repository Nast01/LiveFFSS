import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_clubs_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements ClubRepository {}

void main() {
  late _MockRepo repo;
  late CompetitionDetailClubsController controller;

  Club c(int id, String name) => Club(id: id, name: name);

  setUp(() {
    repo = _MockRepo();
    controller = CompetitionDetailClubsController(repo);
  });

  group('CompetitionDetailClubsController.loadClubs', () {
    test('loads, sorts by name', () async {
      when(() => repo.getClubs(any())).thenAnswer((_) async => [
            c(1, 'Beta'),
            c(2, 'Alpha'),
          ]);

      await controller.loadClubs(99);

      expect(controller.allClubs.length, 2);
      expect(controller.allClubs.first.name, 'Alpha');
      expect(controller.filteredClubs.length, 2);
      expect(controller.isLoading.value, false);
      expect(controller.hasError.value, false);
    });

    test('on AppException sets hasError', () async {
      when(() => repo.getClubs(any()))
          .thenThrow(const NetworkException('offline'));

      await controller.loadClubs(99);

      expect(controller.hasError.value, true);
      expect(controller.allClubs, isEmpty);
    });
  });
}
