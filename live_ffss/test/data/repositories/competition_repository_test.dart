import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
import 'package:live_ffss/app/data/datasources/competition_remote_datasource.dart';
import 'package:live_ffss/app/data/dtos/competition_dto.dart';
import 'package:live_ffss/app/data/repositories/competition_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements CompetitionRemoteDataSource {}

void main() {
  late _MockDataSource ds;
  late CompetitionRepository repo;

  CompetitionDto makeDto(int id, {String name = 'Comp'}) => CompetitionDto(
        id: id,
        name: name,
        statusCode: 0,
        statusLabel: '',
        speciality: 0,
        specialityLabel: '',
        typeWater: '',
        typePool: '',
        typeChrono: '',
        isEligibleToNationalRecord: false,
        organisme: const CompetitionOrganismeDto(id: 1, organizerName: 'X'),
        hasBegun: false,
        hasResult: false,
        hasPassed: false,
        level: 0,
        levelLabel: '',
      );

  setUpAll(() {
    registerFallbackValue(CompetitionType.mixte);
    registerFallbackValue(CompetitionVisibility.incoming);
  });

  setUp(() {
    ds = _MockDataSource();
    repo = CompetitionRepositoryImpl(ds);
  });

  group('CompetitionRepository.getAllCompetitions', () {
    // Le forwarding se verifie ici depuis que la page brute est privee : c'est
    // getAllCompetitions qui porte type, visibility et pageSize jusqu'a la
    // source, et qui numerote les pages.
    test('forwards type, visibility and pageSize, and maps DTOs to domain',
        () async {
      when(() => ds.getCompetitions(
            season: any(named: 'season'),
            startDate: any(named: 'startDate'),
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => [makeDto(1), makeDto(2)]);

      final list = await repo.getAllCompetitions(
        type: CompetitionType.mixte,
        visibility: CompetitionVisibility.passed,
        pageSize: 25,
      );

      expect(list.length, 2);
      expect(list.first.id, 1);
      verify(() => ds.getCompetitions(
            season: any(named: 'season'),
            startDate: any(named: 'startDate'),
            type: CompetitionType.mixte,
            visibility: CompetitionVisibility.passed,
            page: 1,
            pageSize: 25,
          )).called(1);
    });

    test('paginates until a partial page is returned', () async {
      var calls = 0;
      when(() => ds.getCompetitions(
            season: any(named: 'season'),
            startDate: any(named: 'startDate'),
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((invocation) async {
        calls++;
        if (calls == 1) return [makeDto(1), makeDto(2), makeDto(3)];
        if (calls == 2) return [makeDto(4), makeDto(5), makeDto(6)];
        return [makeDto(7)];
      });

      final list = await repo.getAllCompetitions(pageSize: 3);

      expect(list.length, 7);
      expect(list.map((c) => c.id), [1, 2, 3, 4, 5, 6, 7]);
      expect(calls, 3);
    });

    test('stops immediately on empty first page', () async {
      when(() => ds.getCompetitions(
            season: any(named: 'season'),
            startDate: any(named: 'startDate'),
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => []);

      final list = await repo.getAllCompetitions();
      expect(list, isEmpty);
    });
  });

  group('CompetitionRepository.getCompetitionsForRange', () {
    test('forwards yyyy-MM-dd from/to dates to the data source', () async {
      when(() => ds.getCompetitions(
            season: any(named: 'season'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => [makeDto(1)]);

      await repo.getCompetitionsForRange(
        from: DateTime(2026, 4, 27),
        to: DateTime(2026, 5, 3),
      );

      verify(() => ds.getCompetitions(
            season: any(named: 'season'),
            startDate: '2026-04-27',
            endDate: '2026-05-03',
            type: CompetitionType.mixte,
            // Sans visibilite demandee, aucune ne part : le defaut valait
            // `passed`, qui n'avait jamais ete envoye et filtrerait desormais
            // pour de bon.
            visibility: null,
            page: 1,
            pageSize: any(named: 'pageSize'),
          )).called(1);
    });

    test('auto-paginates until a partial page is returned', () async {
      var calls = 0;
      when(() => ds.getCompetitions(
            season: any(named: 'season'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async {
        calls++;
        if (calls == 1) return [makeDto(1), makeDto(2), makeDto(3)];
        return [makeDto(4)];
      });

      final list = await repo.getCompetitionsForRange(
        from: DateTime(2026, 4, 27),
        to: DateTime(2026, 5, 3),
        pageSize: 3,
      );

      expect(list.length, 4);
      expect(list.map((c) => c.id), [1, 2, 3, 4]);
      expect(calls, 2);
    });
  });

  // La saison n'est plus une constante : elle se deduit de la date courante,
  // et la borne basse est le 1er octobre qui l'ouvre.
  group('CompetitionRepository saison courante', () {
    Future<Map<String, String>> captureWindow(DateTime today) async {
      final clockedRepo = CompetitionRepositoryImpl(ds, now: () => today);
      when(() => ds.getCompetitions(
            season: any(named: 'season'),
            startDate: any(named: 'startDate'),
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => const []);

      await clockedRepo.getAllCompetitions();

      final call = verify(() => ds.getCompetitions(
            season: captureAny(named: 'season'),
            startDate: captureAny(named: 'startDate'),
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).captured;
      return {
        'season': call[0] as String,
        'startDate': call[1] as String,
      };
    }

    test('un jour de saison ouverte en octobre porte cette saison', () async {
      expect(await captureWindow(DateTime(2026, 1, 15)), {
        'season': '2025-2026',
        'startDate': '2025-10-01',
      });
    });

    test('le 30 septembre tient encore a la saison precedente', () async {
      expect(await captureWindow(DateTime(2026, 9, 30)), {
        'season': '2025-2026',
        'startDate': '2025-10-01',
      });
    });

    test('le 1er octobre bascule la fenetre entiere', () async {
      expect(await captureWindow(DateTime(2026, 10, 1)), {
        'season': '2026-2027',
        'startDate': '2026-10-01',
      });
    });

    test('une plage passee part avec la saison de son debut, pas celle du jour',
        () async {
      final clockedRepo =
          CompetitionRepositoryImpl(ds, now: () => DateTime(2026, 10, 15));
      when(() => ds.getCompetitions(
            season: any(named: 'season'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => const []);

      await clockedRepo.getCompetitionsForRange(
        from: DateTime(2026, 4, 27),
        to: DateTime(2026, 5, 3),
      );

      verify(() => ds.getCompetitions(
            season: '2025-2026',
            startDate: '2026-04-27',
            endDate: '2026-05-03',
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).called(1);
    });
  });
}
