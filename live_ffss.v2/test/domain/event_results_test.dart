import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/data/ffss/dtos/deroulement_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/deroulement_mapper.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/gender.dart';

import '../support/fixtures.dart';

CompetitionEvent event(int id, Gender gender, String category) =>
    CompetitionEvent(
      id: id,
      disciplineId: 24,
      disciplineName: '200m Obstacles',
      gender: gender,
      categoryId: 1,
      categoryName: category,
      teamSize: 1,
    );

void main() {
  final progressions = [
    for (final row in fixture('deroulement')['data'] as List<dynamic>)
      ?DeroulementDto.fromJson(row as Map<String, dynamic>).toDomain(),
  ];

  test(
    'une épreuve est reliée au déroulement de sa discipline et de son genre',
    () {
      expect(
        progressionOfEvent(
          progressions,
          event(36073, Gender.female, 'Cadet'),
        )?.id,
        501,
      );
      expect(
        progressionOfEvent(
          progressions,
          event(36074, Gender.female, 'Junior'),
        )?.id,
        501,
      );
    },
  );

  test('catégorie absente ou autre genre : aucun déroulement', () {
    expect(
      progressionOfEvent(progressions, event(1, Gender.female, 'Youth')),
      isNull,
    );
    expect(
      progressionOfEvent(progressions, event(2, Gender.male, 'Cadet')),
      isNull,
    );
  });

  test('un relais se reconnaît à sa taille d\'équipe', () {
    expect(event(1, Gender.male, 'Open').isRelay, isFalse);
    expect(event(1, Gender.male, 'Open').copyWith(teamSize: 4).isRelay, isTrue);
  });

  group('hasRun', () {
    EventResult result({int status = 0, int? time, String complement = ''}) =>
        EventResult(
          id: 1,
          entryId: 1,
          eventId: 1,
          categoryName: 'Cadet',
          status: status,
          time: time,
          complement: complement,
        );

    test('publiée sans rien : pas encore courue', () {
      expect(hasRun(result()), isFalse);
    });

    test('un temps, un statut ou un complément : courue', () {
      expect(hasRun(result(time: 16330)), isTrue);
      expect(hasRun(result(status: 1)), isTrue);
      expect(hasRun(result(status: 2)), isTrue);
      expect(hasRun(result(status: 5)), isTrue);
      expect(hasRun(result(complement: 'HT')), isTrue);
    });
  });

  group('personKey', () {
    test("le licencié, puis l'invité, puis l'id du résultat", () {
      const base = ResultAthlete(id: 1, name: 'A');
      expect(personKey(base.copyWith(licenseeId: 5, guestId: 6)), (0, 5));
      expect(personKey(base.copyWith(guestId: 6)), (1, 6));
      expect(personKey(base), (2, 1));
      // Deux résultats d'une même licenciée ont des id d'athlète différents.
      expect(
        personKey(base.copyWith(licenseeId: 5)),
        personKey(base.copyWith(id: 2, licenseeId: 5)),
      );
    });
  });

  group('participantOfEntry', () {
    Participant participant(int id, List<int> entries, {int? licenseeId}) =>
        Participant(
          id: id,
          firstName: 'P$id',
          lastName: 'ATHLETE',
          licenseeId: licenseeId,
          entries: [
            for (final entry in entries)
              ParticipantEntry(
                entryId: entry,
                eventId: 1,
                categoryName: 'Cadet',
              ),
          ],
        );

    final solo = participant(1, [10, 11], licenseeId: 100);
    final relay1 = participant(2, [20, 30], licenseeId: 200);
    final relay2 = participant(3, [30], licenseeId: 300);
    final all = [solo, relay1, relay2];

    test("l'unique porteur de l'engagement", () {
      expect(participantOfEntry(all, 11), same(solo));
      expect(participantOfEntry(all, 11, licenseeId: 100), same(solo));
    });

    test('un relais : le relayeur de ce licencié', () {
      expect(participantOfEntry(all, 30, licenseeId: 300), same(relay2));
    });

    test('rien de sûr : nul', () {
      // Plusieurs porteurs, et aucun licencié pour choisir.
      expect(participantOfEntry(all, 30), isNull);
      expect(participantOfEntry(all, 30, licenseeId: 999), isNull);
      expect(participantOfEntry(all, 99), isNull);
    });
  });
}
