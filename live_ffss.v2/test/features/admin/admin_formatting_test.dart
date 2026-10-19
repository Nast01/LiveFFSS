import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/network/network_log.dart';
import 'package:live_ffss_v2/domain/event_ranking.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/domain/series_link.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/features/admin/admin_formatting.dart';
import 'package:live_ffss_v2/features/admin/data_check_providers.dart';
import 'package:live_ffss_v2/features/admin/maintenance_providers.dart';
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

  group('contrôle des données', () {
    final fr = lookupAppLocalizations(const Locale('fr'));
    final en = lookupAppLocalizations(const Locale('en'));
    const item = MeetingItem(id: 10, name: 'Créneau 177');
    const heat = Heat(
      id: 479,
      name: 'Série 1',
      number: 1,
      status: RunStatus.finished,
      raceName: '200m Obstacles',
      gender: Gender.female,
    );
    DataIssue issue(
      DataIssueKind kind, {
      CompetitionEvent? event,
      bool onHeat = false,
      String where = '',
      int count = 1,
    }) => (
      kind: kind,
      event: event,
      heat: onHeat ? (item: item, heat: heat) : null,
      where: where,
      count: count,
    );

    test('groupées par sorte, dans l\'ordre', () {
      final a = issue(DataIssueKind.orphanSeries, where: 'a');
      final b = issue(DataIssueKind.orphanSeries, where: 'b');
      final c = issue(DataIssueKind.status3, onHeat: true);
      final groups = groupDataIssues([c, a, b]);
      expect(
        [for (final g in groups) g.kind],
        [DataIssueKind.orphanSeries, DataIssueKind.status3],
      );
      expect(
        [for (final g in groups) g.issues],
        [
          [a, b],
          [c],
        ],
      );
      expect(groupDataIssues(const []), isEmpty);
    });

    test('où : épreuve, série d\'épreuve ; course ; compte', () {
      expect(
        dataIssueWhere(
          issue(DataIssueKind.orphanSeries, event: _event(3), where: 'Série 8'),
          fr,
        ),
        'Épreuve 3 · Dames · Cadet · Série 8',
      );
      expect(
        dataIssueWhere(
          issue(DataIssueKind.status3, onHeat: true, count: 2),
          fr,
        ),
        '200m Obstacles · Dames · Série 1 · 2 résultats',
      );
      expect(
        dataIssueWhere(issue(DataIssueKind.unreadablePlaces, onHeat: true), fr),
        '200m Obstacles · Dames · Série 1 · 1 place',
      );
      expect(
        dataIssueWhere(issue(DataIssueKind.raceWithoutTime, onHeat: true), fr),
        '200m Obstacles · Dames · Série 1',
      );
      expect(dataIssueWhere(issue(DataIssueKind.rolesFailed), fr), '');
    });

    test('chaque sorte a un titre et une conséquence, en français et en '
        'anglais', () {
      for (final l10n in [fr, en]) {
        final titles = {
          for (final kind in DataIssueKind.values) dataIssueTitle(kind, l10n),
        };
        final consequences = {
          for (final kind in DataIssueKind.values)
            dataIssueConsequence(kind, l10n),
        };
        expect(titles, hasLength(DataIssueKind.values.length));
        expect(consequences, hasLength(DataIssueKind.values.length));
        expect(titles.every((t) => t.isNotEmpty), isTrue);
      }
    });
  });

  group('rapport de diagnostic', () {
    final now = DateTime(2026, 10, 19, 14, 30, 5);
    OutboxOperation op(OutboxState state) => OutboxOperation(
      id: '$state',
      account: 'ATHLETE Deux',
      competitionId: 1416,
      placeId: 1,
      seriesId: 2,
      entryId: 3,
      change: const ResultChange(mark: ResultMark.forfeit),
      state: state,
    );
    NetworkLogEntry failed(int i, {String path = '/api/v1.0/course/place/1'}) =>
        NetworkLogEntry(
          at: DateTime(2026, 10, 19, 14, 0, i),
          method: 'GET',
          path: path,
          status: i.isEven ? 500 : null,
          duration: Duration.zero,
          error: i.isEven ? 'ApiException' : 'NetworkException',
          server: 'Développement',
        );

    String report({
      List<OutboxOperation> queue = const [],
      List<NetworkLogEntry> log = const [],
      bool accountAdmin = true,
      String? name = 'Championnat',
    }) => diagnosticReport(
      version: '2.0.0+1',
      environment: AppEnvironment.development,
      competitionId: 1416,
      competitionName: name,
      accountAdmin: accountAdmin,
      queue: queue,
      log: log,
      now: now,
    );

    test('l\'en-tête : date, version, serveur, compétition, rôle, file', () {
      final text = report(
        queue: [
          op(OutboxState.pending),
          op(OutboxState.pending),
          op(OutboxState.sent),
          op(OutboxState.rejected),
        ],
      );
      expect(text, contains('2026-10-19 14:30:05'));
      expect(text, contains('2.0.0+1'));
      expect(text, contains('Développement (https://site.ffss.io)'));
      expect(text, contains('1416 · Championnat'));
      expect(text, contains('admin du compte'));
      expect(text, contains('2 en attente, 1 envoyée(s), 1 refusée(s)'));
      expect(text, isNot(contains('ATHLETE')));
      expect(
        report(accountAdmin: false, name: null),
        allOf(contains('admin de la compétition'), contains('1416\n')),
      );
    });

    test('les 20 dernières erreurs seulement, sans chaîne de requête', () {
      final log = [
        for (var i = 30; i >= 1; i--) failed(i),
        NetworkLogEntry(
          at: now,
          method: 'GET',
          path: '/api/v1.0/competition/1416/reunion',
          status: 200,
          duration: Duration.zero,
          server: 'Développement',
        ),
        failed(0, path: '/api/v1.0/licencie/recherche?q=DUPONT'),
      ];
      final lines = report(log: log).split('\n');
      final errors = [
        for (final line in lines)
          if (line.startsWith('14:00:')) line,
      ];
      expect(errors, hasLength(20));
      expect(
        errors.first,
        '14:00:30 GET /api/v1.0/course/place/1 500 '
        'ApiException [Développement]',
      );
      expect(
        errors[1],
        '14:00:29 GET /api/v1.0/course/place/1 - '
        'NetworkException [Développement]',
      );
      expect(lines.join('\n'), isNot(contains('reunion')));
      expect(
        report(log: [failed(0, path: '/api/v1.0/licencie/recherche?q=DUPONT')]),
        allOf(
          contains('/api/v1.0/licencie/recherche '),
          isNot(contains('DUPONT')),
        ),
      );
    });

    test('la version est celle du pubspec', () {
      final pubspec = File('pubspec.yaml').readAsLinesSync();
      final line = pubspec.firstWhere((l) => l.startsWith('version:'));
      expect(appVersion, line.substring('version:'.length).trim());
    });
  });

  test('le message de la notification de test', () {
    final fr = lookupAppLocalizations(const Locale('fr'));
    expect(
      testNotificationMessage(TestNotificationOutcome.sent, fr),
      'Notification envoyée.',
    );
    expect(
      testNotificationMessage(TestNotificationOutcome.notPermitted, fr),
      fr.reminderPermissionMissing,
    );
    expect({
      for (final outcome in TestNotificationOutcome.values)
        testNotificationMessage(outcome, fr),
    }, hasLength(TestNotificationOutcome.values.length));
  });

  test("l'heure d'un rappel planifié, avec son jour", () async {
    await initializeDateFormatting('fr');
    expect(
      plannedReminderWhen(DateTime(2026, 3, 27, 8, 15), 'fr'),
      '27 mars 08:15',
    );
  });
}
