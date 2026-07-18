import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/programme/controllers/schedule_controller.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockStorage storage;
  late ProgrammeService service;
  late ScheduleController controller;

  setUpAll(() => registerFallbackValue(''));

  const competition = Competition(
    id: 42,
    name: 'Championnat',
    beginDate: null,
    statusCode: 0,
    statusLabel: '',
    speciality: 1,
    specialityLabel: '',
    typeWater: '',
    typePool: '',
    typeChrono: '',
    isEligibleToNationalRecord: false,
    numberOfLanes: 8,
    organizer: '',
    hasBegun: false,
    hasResult: false,
    hasPassed: false,
    level: 0,
    levelLabel: '',
    organizerClub: Club(id: 1, name: 'Club'),
  );

  final withDates = competition.copyWith(
    beginDate: DateTime(2026, 6, 13),
    endDate: DateTime(2026, 6, 14),
  );

  CompetitionProgramme seed() => const CompetitionProgramme(
        competitionId: 42,
        sites: [ProgrammeSite(id: 1, name: 'Côtier 1', type: SiteType.cotier)],
        structures: [
          EventStructure(
            raceId: 100,
            categoryId: 7,
            raceLabel: '100m',
            categoryLabel: 'Cadets',
            levels: [
              RoundLevel(type: RoundType.serie, races: [
                ProgrammeRace(id: 10, number: 1),
                ProgrammeRace(id: 11, number: 2),
              ]),
            ],
          ),
        ],
      );

  setUp(() async {
    storage = _MockStorage();
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenAnswer((_) async {});
    service = ProgrammeService(storage);
    await service.save(seed());
    controller = ScheduleController(service);
  });

  test('setCompetition derives the day list and defaults the site', () {
    controller.setCompetition(withDates);
    expect(controller.days, [DateTime(2026, 6, 13), DateTime(2026, 6, 14)]);
    expect(controller.selectedSiteId.value, 1);
  });

  test('unscheduled lists races with no placement', () {
    controller.setCompetition(withDates);
    expect(controller.unscheduled.map((i) => i.raceId), [10, 11]);
  });

  test('place puts a race at the day start, then the next appends after it',
      () async {
    controller.setCompetition(withDates);
    final day = DateTime(2026, 6, 13);

    await controller.place(10, 1, day);
    await controller.place(11, 1, day);

    final placed = controller.placedOn(1, day);
    expect(placed.map((i) => i.raceId), [10, 11]);
    expect(placed[0].placement!.beginHour, DateTime(2026, 6, 13, 9));
    expect(placed[1].placement!.beginHour, DateTime(2026, 6, 13, 9, 10));
    expect(controller.unscheduled, isEmpty);
  });

  test('unschedule returns a race to the palette', () async {
    controller.setCompetition(withDates);
    final day = DateTime(2026, 6, 13);
    await controller.place(10, 1, day);

    await controller.unschedule(10);

    expect(controller.placedOn(1, day), isEmpty);
    expect(controller.unscheduled.map((i) => i.raceId), contains(10));
  });

  test('setDuration extending into the next race is rejected with a message',
      () async {
    controller.setCompetition(withDates);
    final day = DateTime(2026, 6, 13);
    await controller.place(10, 1, day); // 09:00-09:10
    await controller.place(11, 1, day); // 09:10-09:20

    await controller.setDuration(10, 20); // would run 09:00-09:20, overlapping 11

    // rejected: duration unchanged, error message set
    final r10 = controller.placedOn(1, day).firstWhere((i) => i.raceId == 10);
    expect(r10.placement!.durationMinutes, 10);
    expect(controller.message.value, isA<UiMessageError>());
  });

  test('setDuration with no conflict applies', () async {
    controller.setCompetition(withDates);
    final day = DateTime(2026, 6, 13);
    await controller.place(10, 1, day);

    await controller.setDuration(10, 15);

    final r10 = controller.placedOn(1, day).single;
    expect(r10.placement!.durationMinutes, 15);
  });
}
