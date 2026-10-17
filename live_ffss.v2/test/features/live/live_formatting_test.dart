import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/live.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/features/live/live_formatting.dart';

LiveEntry entry({
  String raceName = '200m Obstacles',
  Gender? gender = Gender.male,
  String heatName = 'Finale',
  DateTime? start,
}) => LiveEntry(
  meeting: Meeting(id: 1, name: 'Réunion 1', day: DateTime(2026, 3, 27)),
  item: const MeetingItem(id: 1, name: 'Créneau 200m'),
  heat: Heat(
    id: 1,
    name: heatName,
    number: 2,
    status: RunStatus.inProgress,
    raceName: raceName,
    gender: gender,
    plannedStart: start,
  ),
);

void main() {
  final l10n = lookupAppLocalizations(const Locale('fr'));

  group('liveCardTitle', () {
    test('épreuve et genre', () {
      expect(liveCardTitle(entry(), l10n), '200m Obstacles · Messieurs');
    });

    test('sans genre', () {
      expect(liveCardTitle(entry(gender: null), l10n), '200m Obstacles');
    });

    test('sans épreuve : le nom du créneau', () {
      expect(
        liveCardTitle(entry(raceName: '', gender: null), l10n),
        'Créneau 200m',
      );
    });
  });

  group('liveCardSubtitle', () {
    final start = DateTime(2026, 3, 27, 8, 44);

    test('rang, total et heure', () {
      expect(
        liveCardSubtitle(entry(start: start), (position: 2, total: 11), l10n),
        'Série 2/11 · 08:44',
      );
    });

    test('une seule série : le nom de la course', () {
      expect(
        liveCardSubtitle(entry(start: start), (position: 1, total: 1), l10n),
        'Finale · 08:44',
      );
    });

    test('sans heure', () {
      expect(
        liveCardSubtitle(entry(), (position: 2, total: 11), l10n),
        'Série 2/11',
      );
    });
  });

  group('liveNextLabel', () {
    test('épreuve, série et heure', () {
      expect(
        liveNextLabel(entry(start: DateTime(2026, 3, 27, 8, 44)), (
          position: 2,
          total: 11,
        ), l10n),
        'Prochaine série : 200m Obstacles · Messieurs · Série 2/11 · 08:44',
      );
    });

    test('sans épreuve ni heure : le créneau et la série', () {
      expect(
        liveNextLabel(entry(raceName: '', gender: null), (
          position: 1,
          total: 1,
        ), l10n),
        'Prochaine série : Créneau 200m · Finale',
      );
    });
  });

  group('carte du Live', () {
    const timed = LaneAssignment(
      id: 1,
      lane: 1,
      athletes: ['Alice'],
      performance: Performance(time: '50.00', timeHundredths: 5000),
    );
    const noTime = LaneAssignment(id: 1, lane: 1, athletes: ['Alice']);
    Heat heatOf(RunStatus status, {bool provisional = true}) => Heat(
      id: 1,
      name: 'Série 1',
      number: 1,
      status: status,
      resultsProvisional: provisional,
    );

    test('places pas encore lues : chargement, pas « en attente »', () {
      expect(
        liveCardBody(heatOf(RunStatus.finished), const [], lanesRead: false),
        LiveCardBody.loading,
      );
      expect(
        liveCardBody(heatOf(RunStatus.inProgress), const [], lanesRead: false),
        LiveCardBody.loading,
      );
    });

    test('places lues sans résultat', () {
      expect(
        liveCardBody(heatOf(RunStatus.inProgress), const [
          noTime,
        ], lanesRead: true),
        LiveCardBody.startList,
      );
      expect(
        liveCardBody(heatOf(RunStatus.finished), const [], lanesRead: true),
        LiveCardBody.waitingResults,
      );
    });

    test('un résultat publié : les résultats', () {
      expect(
        liveCardBody(heatOf(RunStatus.finished), const [
          timed,
        ], lanesRead: true),
        LiveCardBody.results,
      );
    });

    test('série en cours avec résultats : EN DIRECT et bandeau de '
        'validation', () {
      final heat = heatOf(RunStatus.inProgress, provisional: false);
      final body = liveCardBody(heat, const [timed], lanesRead: true);
      expect(body, LiveCardBody.results);
      expect(liveBadge(heat), LiveBadge.live);
      expect(livePendingBanner(heat, body), isTrue);
    });

    test('chambre d\'appel avec résultats : le badge reste', () {
      expect(liveBadge(heatOf(RunStatus.marshalling)), LiveBadge.marshalling);
    });

    test('série terminée : temporaire ou validée', () {
      final provisional = heatOf(RunStatus.finished);
      final validated = heatOf(RunStatus.finished, provisional: false);
      expect(liveBadge(provisional), LiveBadge.provisional);
      expect(liveBadge(validated), LiveBadge.validated);
      expect(livePendingBanner(provisional, LiveCardBody.results), isTrue);
      expect(livePendingBanner(validated, LiveCardBody.results), isFalse);
    });

    test('pas de bandeau sans résultats', () {
      expect(
        livePendingBanner(heatOf(RunStatus.inProgress), LiveCardBody.startList),
        isFalse,
      );
    });
  });

  test('libellés fr du Live', () {
    expect(l10n.liveTitle, 'Live');
    expect(l10n.liveRunning, 'En cours');
    expect(l10n.liveRecent, 'Dernières séries');
    expect(l10n.liveProvisional, 'Temporaire');
    expect(l10n.liveValidated, 'Validé');
    expect(l10n.liveMarshalling, "Chambre d'appel");
    expect(
      l10n.livePendingValidation,
      'Résultats en attente de validation par les juges',
    );
    expect(
      l10n.liveWaitingResults,
      "Résultats en attente : ils s'afficheront dès leur publication",
    );
    expect(l10n.liveNothingYet, "Aucune série courue pour l'instant");
    expect(l10n.liveNext('200m'), 'Prochaine série : 200m');
    expect(l10n.liveSeeProgramme, 'Voir tout le programme');
    expect(l10n.liveLoadError, 'Impossible de charger le direct.');
    expect(l10n.coastalComingSoon, 'Côtier : bientôt disponible');
  });
}
