import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/now_running.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/features/home/competition_formatting.dart';

import '../../support/competitions.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('fr'));

  NowRunning now({
    String raceName = '200 m Obstacles',
    Gender? gender = Gender.female,
    String name = 'Série A',
    int position = 4,
    int total = 10,
  }) => NowRunning(
    heat: Heat(
      id: 1,
      name: name,
      number: position,
      status: RunStatus.inProgress,
      raceName: raceName,
      gender: gender,
    ),
    kind: NowRunningKind.now,
    position: position,
    total: total,
  );

  group('heatLine', () {
    test('ligne complète', () {
      expect(heatLine(now(), l10n), '200 m Obstacles · Dames · Série 4/10');
    });

    test('une seule série : retombe sur le nom de la série', () {
      expect(
        heatLine(now(total: 1), l10n),
        '200 m Obstacles · Dames · Série A',
      );
    });

    test('épreuve vide et sexe nul sont omis', () {
      expect(heatLine(now(raceName: '', gender: null), l10n), 'Série 4/10');
    });
  });

  group('disciplineLabel', () {
    String label(Set<Discipline> disciplines) => competition(
      1,
      start: DateTime(2026, 10, 17),
      disciplines: disciplines,
    ).disciplineLabel(l10n);

    test('eau plate', () {
      expect(label({Discipline.flatWater}), l10n.disciplineFlatWater);
    });

    test('côtier', () {
      expect(label({Discipline.coastal}), l10n.disciplineCoastal);
    });

    test('mixte', () {
      expect(
        label({Discipline.flatWater, Discipline.coastal}),
        l10n.disciplineMixed,
      );
    });
  });
}
