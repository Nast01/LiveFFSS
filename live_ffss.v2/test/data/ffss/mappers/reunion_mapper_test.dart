import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/data/ffss/dtos/reunion_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

Map<String, dynamic> course([Map<String, dynamic> overrides = const {}]) => {
  'id': 20,
  'Nom': 'Série 4',
  'statut': 2,
  'debut': '06:54',
  'fin': '06:58',
  'serie': {
    'Id': 300,
    'Nom': 'Série 4',
    'Numero': 4,
    'epreuve': {
      'Id': 7,
      'Genre': 'F',
      'discipline': {'Nom': '200 m Obstacles'},
    },
  },
  ...overrides,
};

Map<String, dynamic> reunion({List<Map<String, dynamic>>? courses}) => {
  'Id': 1,
  'Nom': 'Eau Plate 1 – Séries',
  'Description': 'Piscine olympique',
  'Jour': '2026-03-27',
  'Debut': '06:45',
  'Fin': '11:30',
  'creneaus': [
    {
      'id': 10,
      'Nom': '200 m Obstacles D',
      'partie': {'id': 100},
      'courses': courses ?? [course()],
    },
  ],
};

void main() {
  test('une réunion, son créneau et sa course', () {
    final meeting = ReunionDto.fromJson(reunion()).toDomain()!;

    expect(meeting.id, 1);
    expect(meeting.name, 'Eau Plate 1 – Séries');
    expect(meeting.day, DateTime(2026, 3, 27));
    expect(meeting.startTime, DateTime(2026, 3, 27, 6, 45));
    expect(meeting.endTime, DateTime(2026, 3, 27, 11, 30));

    final item = meeting.items.single;
    expect(item.id, 10);
    expect(item.roundId, 100);

    final heat = item.heats.single;
    expect(heat.id, 20);
    expect(heat.name, 'Série 4');
    expect(heat.number, 4);
    expect(heat.status, RunStatus.inProgress);
    expect(heat.plannedStart, DateTime(2026, 3, 27, 6, 54));
    expect(heat.plannedEnd, DateTime(2026, 3, 27, 6, 58));
    expect(heat.raceId, 7);
    expect(heat.raceName, '200 m Obstacles');
    expect(heat.gender, Gender.female);
  });

  test('statut et numéro servis en chaîne', () {
    final heat = ReunionDto.fromJson(
      reunion(
        courses: [
          course({
            'statut': '3',
            'serie': {'Id': 300, 'Numero': '4'},
          }),
        ],
      ),
    ).toDomain()!.items.single.heats.single;

    expect(heat.status, RunStatus.finished);
    expect(heat.number, 4);
  });

  test('une heure de course mal formée garde la série, sans heure', () {
    final heat = ReunionDto.fromJson(
      reunion(
        courses: [
          course({'debut': '', 'fin': 'midi'}),
        ],
      ),
    ).toDomain()!.items.single.heats.single;

    expect(heat.plannedStart, isNull);
    expect(heat.plannedEnd, isNull);
  });

  test('une course sans série : numéro 0, sans épreuve ni genre', () {
    final heat = ReunionDto.fromJson(
      reunion(
        courses: [
          course({'serie': null}),
        ],
      ),
    ).toDomain()!.items.single.heats.single;

    expect(heat.number, 0);
    expect(heat.raceId, isNull);
    expect(heat.raceName, '');
    expect(heat.gender, isNull);
  });

  test('partie ou série servies en tableau vide (PHP)', () {
    final json = reunion(
      courses: [
        course({'serie': <Object>[]}),
      ],
    );
    (json['creneaus'] as List<Map<String, dynamic>>).single['partie'] =
        <Object>[];

    final item = ReunionDto.fromJson(json).toDomain()!.items.single;

    expect(item.roundId, isNull);
    expect(item.heats.single.raceId, isNull);
  });

  test('une course sans id est écartée, les autres restent', () {
    final item = ReunionDto.fromJson(
      reunion(
        courses: [
          course({'id': null}),
          course({'id': 21}),
        ],
      ),
    ).toDomain()!.items.single;

    expect([for (final h in item.heats) h.id], [21]);
  });

  test('une réunion sans jour lisible est écartée', () {
    expect(
      ReunionDto.fromJson({...reunion(), 'Jour': null}).toDomain(),
      isNull,
    );
  });

  test('parseGender : H, F, M et le reste', () {
    expect(parseGender('H'), Gender.male);
    expect(parseGender('F'), Gender.female);
    expect(parseGender('M'), Gender.mixed);
    expect(parseGender('X'), isNull);
    expect(parseGender(null), isNull);
  });
}
