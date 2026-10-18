import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

void main() {
  Participant p(
    int id,
    String last,
    String first, {
    int? clubId,
    int? licenseeId,
    String club = '',
  }) => Participant(
    id: id,
    firstName: first,
    lastName: last,
    clubId: clubId,
    licenseeId: licenseeId,
    club: club,
  );

  group('participantOfLicensee', () {
    final list = [p(1, 'A', 'a', licenseeId: 10), p(2, 'B', 'b')];

    test('trouve le participant du licencié', () {
      expect(participantOfLicensee(list, 10)?.id, 1);
    });

    test('licencié absent ou nul : nul', () {
      expect(participantOfLicensee(list, 99), isNull);
      expect(participantOfLicensee(list, null), isNull);
    });
  });

  group('clubAthletes', () {
    test('filtre le club et trie par nom puis prénom', () {
      final list = [
        p(1, 'Martin', 'Zoe', clubId: 5),
        p(2, 'Durand', 'Paul', clubId: 5),
        p(3, 'Martin', 'Alice', clubId: 5),
        p(4, 'Autre', 'X', clubId: 6),
        p(5, 'Sans', 'Club'),
      ];
      expect(clubAthletes(list, 5).map((e) => e.id), [2, 3, 1]);
    });

    test('club sans athlète : liste vide', () {
      expect(clubAthletes([p(1, 'A', 'a', clubId: 1)], 2), isEmpty);
    });
  });

  group('competitionClubs', () {
    test('un club par clubId, libellé du premier, trié, clubId nul écarté', () {
      final list = [
        p(1, 'A', 'a', clubId: 7, club: 'Zèbre'),
        p(2, 'B', 'b', clubId: 3, club: 'Alpha'),
        p(3, 'C', 'c', clubId: 7, club: 'Zèbre bis'),
        p(4, 'D', 'd', club: 'Sans id'),
      ];
      expect(competitionClubs(list), [
        (id: 3, label: 'Alpha', athletes: 1),
        (id: 7, label: 'Zèbre', athletes: 2),
      ]);
    });

    test('aucun participant : liste vide', () {
      expect(competitionClubs(const []), isEmpty);
    });
  });

  group('heatsToCheck', () {
    Heat heat(int id, RunStatus status, {int? seriesId}) => Heat(
      id: id,
      name: 'h$id',
      number: id,
      status: status,
      seriesId: seriesId,
    );

    Programme programme(List<List<Heat>> itemsHeats) => Programme(
      meetings: [
        Meeting(
          id: 1,
          name: 'm',
          day: DateTime(2026, 10, 18),
          items: [
            for (var i = 0; i < itemsHeats.length; i++)
              MeetingItem(id: i, name: 'i$i', heats: itemsHeats[i]),
          ],
        ),
      ],
    );

    test('séries terminées avec seriesId, dans l\'ordre du programme', () {
      final result = heatsToCheck(
        programme([
          [
            heat(1, RunStatus.finished, seriesId: 11),
            heat(2, RunStatus.inProgress, seriesId: 12),
          ],
          [
            heat(3, RunStatus.finished),
            heat(4, RunStatus.finished, seriesId: 14),
          ],
        ]),
      );
      expect(result.map((h) => h.id), [1, 4]);
    });

    test('aucune série terminée : liste vide', () {
      expect(
        heatsToCheck(
          programme([
            [heat(1, RunStatus.waiting, seriesId: 1)],
          ]),
        ),
        isEmpty,
      );
      expect(heatsToCheck(const Programme()), isEmpty);
    });
  });

  group('needsEntry', () {
    OutboxOperation op({OutboxState state = OutboxState.pending}) =>
        OutboxOperation(
          id: 'o',
          account: 'a',
          competitionId: 1,
          placeId: 1,
          seriesId: 5,
          entryId: 7,
          change: const ResultChange(),
          state: state,
        );

    test('rien de saisi ni publié : vrai', () {
      expect(
        needsEntry(
          {
            7: [null, 0, null],
          },
          const [],
          const [],
        ),
        isTrue,
      );
      expect(needsEntry(const {}, const [], const []), isTrue);
    });

    test('un chrono > 0 : faux', () {
      expect(
        needsEntry(
          {
            7: [null, 1234, null],
          },
          const [],
          const [],
        ),
        isFalse,
      );
    });

    test('un temps publié : faux', () {
      expect(needsEntry(const {}, const [7], const []), isFalse);
    });

    test('une saisie en file : faux', () {
      expect(needsEntry(const {}, const [], [op()]), isFalse);
    });

    test('une saisie refusée ne compte pas', () {
      expect(
        needsEntry(const {}, const [], [op(state: OutboxState.rejected)]),
        isTrue,
      );
    });
  });

  group('reminderAt', () {
    final now = DateTime(2026, 10, 18, 9);
    const before = Duration(minutes: 30);

    test('départ futur : départ moins le délai', () {
      expect(
        reminderAt(DateTime(2026, 10, 18, 10), before, now),
        DateTime(2026, 10, 18, 9, 30),
      );
    });

    test('rappel passé, égal à maintenant ou sans départ : nul', () {
      expect(reminderAt(DateTime(2026, 10, 18, 9, 10), before, now), isNull);
      expect(reminderAt(DateTime(2026, 10, 18, 9, 30), before, now), isNull);
      expect(reminderAt(null, before, now), isNull);
    });
  });
}
