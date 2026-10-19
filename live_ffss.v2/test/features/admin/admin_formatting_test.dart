import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/network/network_log.dart';
import 'package:live_ffss_v2/domain/event_ranking.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/domain/series_link.dart';
import 'package:live_ffss_v2/features/admin/admin_formatting.dart';
import 'package:live_ffss_v2/features/my_space/official_space_providers.dart';

NetworkLogEntry _entry(String path, {String? error}) => NetworkLogEntry(
  at: DateTime(2026, 10, 19),
  method: 'GET',
  path: path,
  duration: Duration.zero,
  server: 'Développement',
  error: error,
);

CompetitionEvent _event(int id) => CompetitionEvent(
  id: id,
  disciplineId: id,
  disciplineName: 'Épreuve $id',
  gender: Gender.female,
  categoryId: 1,
  categoryName: 'Cadet',
  teamSize: 1,
);

RankingRow _row(int entryId, String club, {int status = 1}) => RankingRow(
  result: EventResult(
    id: entryId,
    entryId: entryId,
    eventId: 0,
    categoryName: 'Cadet',
    status: status,
    club: club,
  ),
  points: 0,
  qualification: Qualification.none,
  series: const LinkedSeries(
    series: EventSeries(id: 1, eventId: 0, number: 1, name: 'Série 1'),
    heat: Heat(id: 1, name: 'Série 1', number: 1, status: RunStatus.finished),
    round: EventRound.heats,
  ),
);

OfficialDecisions _decisions(List<EventDecisions> events) => (
  events: events,
  unreadEvents: 0,
  entries: const <int, ({CompetitionEvent event, EventResult result})>{},
);

void main() {
  test('formatDuration: millisecondes sous la seconde, secondes au-delà', () {
    expect(formatDuration(const Duration(milliseconds: 85)), '85 ms');
    expect(formatDuration(const Duration(milliseconds: 999)), '999 ms');
    expect(formatDuration(const Duration(milliseconds: 1250)), '1.3 s');
    expect(formatDuration(const Duration(seconds: 30)), '30.0 s');
  });

  test('formatBytes: o, Ko, Mo, et un tiret sans réponse', () {
    expect(formatBytes(null), '-');
    expect(formatBytes(0), '0 o');
    expect(formatBytes(820), '820 o');
    expect(formatBytes(12595), '12.3 Ko');
    expect(formatBytes(1572864), '1.5 Mo');
  });

  test('visibleEntries: erreurs seulement, ordre conservé', () {
    final all = [
      _entry('/a'),
      _entry('/b', error: 'NetworkException'),
      _entry('/c'),
      _entry('/d', error: 'ApiException'),
    ];
    expect(visibleEntries(all, errorsOnly: false), all);
    expect(visibleEntries(all, errorsOnly: true).map((e) => e.path), [
      '/b',
      '/d',
    ]);
  });
  group('forfaits et DQ de tous les clubs', () {
    final e1 = _event(1);
    final e2 = _event(2);
    final decisions = _decisions([
      (event: e1, rows: [_row(11, 'TOULON'), _row(12, ' ANTIBES ')]),
      (event: e2, rows: [_row(21, 'TOULON', status: 2), _row(22, '')]),
    ]);

    test('les clubs à filtrer : uniques, triés, sans libellé vide', () {
      expect(decisionClubs(decisions), ['ANTIBES', 'TOULON']);
    });

    test('les épreuves à filtrer : celles qui ont une décision, dans '
        'leur ordre', () {
      expect(decisionEvents(decisions), [e1, e2]);
    });

    test('sans filtre : tout', () {
      expect(filterDecisions(decisions.events), decisions.events);
    });

    test('par club : ses lignes, et les épreuves sans elles retirées', () {
      final antibes = filterDecisions(decisions.events, club: 'ANTIBES');
      expect(antibes.map((e) => e.event), [e1]);
      expect(antibes.single.rows.map((r) => r.result.entryId), [12]);

      final toulon = filterDecisions(decisions.events, club: 'TOULON');
      expect(toulon.map((e) => e.rows.single.result.entryId), [11, 21]);
    });

    test('par épreuve, et les deux ensemble', () {
      expect(filterDecisions(decisions.events, eventId: 2).single.event, e2);
      expect(
        filterDecisions(decisions.events, club: 'ANTIBES', eventId: 2),
        isEmpty,
      );
    });

    test("l'id d'un club par son libellé, nul s'il n'est pas engagé", () {
      const clubs = [
        (id: 16, label: 'ANTIBES', athletes: 1),
        (id: 15, label: 'TOULON ', athletes: 2),
      ];
      expect(clubIdOf(clubs, 'TOULON'), 15);
      expect(clubIdOf(clubs, ' ANTIBES'), 16);
      expect(clubIdOf(clubs, 'NICE'), isNull);
    });
  });
}
