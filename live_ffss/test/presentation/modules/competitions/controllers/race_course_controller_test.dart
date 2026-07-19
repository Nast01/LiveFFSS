import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_course_controller.dart';

void main() {
  const competition = Competition(
    id: 42,
    name: 'Championnat',
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

  const race = Race(
    id: 500,
    name: '100m Nage',
    nameEnglish: '100m Swim',
    distance: 100,
    gender: Gender.male,
    athletesPerTeam: 1,
    specialityId: 1,
    specialityLabel: 'Eau-plate',
    disciplineId: 1,
    isEligibleToNationalRecord: false,
    categories: [],
  );

  test('applyArguments parses every context field from the map', () {
    final controller = RaceCourseController();
    controller.applyArguments({
      'race': race,
      'competition': competition,
      'categoryId': 7,
      'categoryLabel': 'Cadets',
      'roundType': RoundType.serie,
      'raceNumber': 2,
      'programmeRaceId': 11,
    });

    expect(controller.race.value?.id, 500);
    expect(controller.competition.value?.id, 42);
    expect(controller.categoryId, 7);
    expect(controller.categoryLabel, 'Cadets');
    expect(controller.roundType, RoundType.serie);
    expect(controller.raceNumber, 2);
    expect(controller.programmeRaceId, 11);
  });

  test('applyArguments leaves defaults on a non-map argument', () {
    final controller = RaceCourseController();
    controller.applyArguments(null);

    expect(controller.race.value, isNull);
    expect(controller.categoryLabel, '');
    expect(controller.roundType, RoundType.unknown);
    expect(controller.raceNumber, 0);
  });
}
