import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/follows.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';

void main() {
  const follows = Follows(
    athletes: [
      FollowedAthlete(
        participantId: 1,
        name: 'ATHLETE Un',
        club: 'Club A',
        entryIds: [10, 11],
      ),
    ],
    clubs: [FollowedClub(id: 7, label: 'Club B')],
  );

  LaneAssignment lane({int? entryId, String club = '', bool relay = false}) =>
      LaneAssignment(
        id: 1,
        lane: 1,
        athletes: const ['X'],
        club: club,
        entryId: entryId,
        isRelay: relay,
      );

  EventResult result({int entryId = 99, String club = ''}) => EventResult(
    id: 1,
    entryId: entryId,
    eventId: 1,
    categoryName: 'Open',
    status: 0,
    club: club,
  );

  group('isFollowedLane', () {
    test("par engagement d'un athlète suivi", () {
      expect(isFollowedLane(follows, lane(entryId: 11)), isTrue);
    });

    test("un autre engagement, d'un autre club : pas suivi", () {
      expect(
        isFollowedLane(follows, lane(entryId: 12, club: 'Club C')),
        isFalse,
      );
    });

    test('un relais du club suivi', () {
      expect(
        isFollowedLane(follows, lane(entryId: 50, club: 'Club B', relay: true)),
        isTrue,
      );
    });

    test('un nageur du club suivi', () {
      expect(
        isFollowedLane(follows, lane(entryId: 51, club: 'Club B')),
        isTrue,
      );
    });

    test('sans engagement, le club décide', () {
      expect(isFollowedLane(follows, lane(club: 'Club B')), isTrue);
      expect(isFollowedLane(follows, lane()), isFalse);
    });

    test("le club d'un athlète suivi n'est pas suivi pour autant", () {
      expect(
        isFollowedLane(follows, lane(entryId: 12, club: 'Club A')),
        isFalse,
      );
    });

    test('rien de suivi : jamais', () {
      expect(isFollowedLane(const Follows(), lane(entryId: 10)), isFalse);
    });

    test('un club suivi sans libellé ne suit pas les places sans club', () {
      const blank = Follows(clubs: [FollowedClub(id: 1, label: '')]);
      expect(isFollowedLane(blank, lane()), isFalse);
    });
  });

  group('isFollowedResult', () {
    test('par engagement', () {
      expect(isFollowedResult(follows, result(entryId: 10)), isTrue);
    });

    test('par club', () {
      expect(isFollowedResult(follows, result(club: 'Club B')), isTrue);
    });

    test("ni l'un ni l'autre", () {
      expect(isFollowedResult(follows, result(club: 'Club C')), isFalse);
    });
  });

  test('FollowedAthlete.fromParticipant garde nom, club et engagements', () {
    const participant = Participant(
      id: 4,
      firstName: 'Un',
      lastName: 'ATHLETE',
      club: 'Club A',
      entries: [
        ParticipantEntry(entryId: 3, eventId: 1, categoryName: 'Open'),
        ParticipantEntry(entryId: 5, eventId: 2, categoryName: 'Open'),
      ],
    );

    final athlete = FollowedAthlete.fromParticipant(participant);

    expect(athlete.participantId, 4);
    expect(athlete.name, 'Un ATHLETE');
    expect(athlete.club, 'Club A');
    expect(athlete.entryIds, [3, 5]);
  });
}
