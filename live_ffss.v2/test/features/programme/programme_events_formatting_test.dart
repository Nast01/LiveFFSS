import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/programme_events.dart';
import 'package:live_ffss_v2/domain/progression.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/features/programme/programme_formatting.dart';

final _saturday = DateTime(2026, 3, 28);
final _sunday = DateTime(2026, 3, 29);

Heat _heat(int id, RunStatus status) =>
    Heat(id: id, name: 'Série $id', number: id, status: status, seriesId: id);

MeetingItem _item(int id, List<Heat> heats, DateTime start) => MeetingItem(
  id: id,
  name: 'C$id',
  roundId: 1,
  startTime: start,
  heats: heats,
);

EventStep _step(
  StageLevel level,
  List<MeetingItem> items, {
  int stageCount = 1,
}) => EventStep(
  level: level,
  stageCount: stageCount,
  items: items,
  status: stageStatus(items),
);

void main() {
  final l10n = lookupAppLocalizations(const Locale('fr'));
  setUpAll(() => initializeDateFormatting('fr'));

  final heatsDone = _item(1, [
    _heat(1, RunStatus.finished),
    _heat(2, RunStatus.finished),
  ], DateTime(2026, 3, 28, 14, 30));
  final heatsLive = _item(1, [
    _heat(1, RunStatus.finished),
    _heat(2, RunStatus.finished),
    _heat(3, RunStatus.inProgress),
    _heat(4, RunStatus.waiting),
  ], DateTime(2026, 3, 28, 14, 52));
  final finals = _item(2, [
    _heat(5, RunStatus.waiting),
  ], DateTime(2026, 3, 29, 15));

  ProgrammeEvent event(MeetingItem heats, {bool withFinals = true}) =>
      ProgrammeEvent(
        key: 'p1',
        name: '100m Obstacles',
        gender: Gender.female,
        categories: const ['Cadet', 'Junior'],
        steps: [
          _step(StageLevel.heats, [heats]),
          if (withFinals) _step(StageLevel.finalStage, [finals], stageCount: 2),
        ],
        items: [heats],
        status: itemStatus(heats),
      );

  group('eventBadge', () {
    test('en cours : EN DIRECT', () {
      expect(eventBadge(event(heatsLive), l10n), (
        kind: EventBadgeKind.live,
        label: 'EN DIRECT',
      ));
    });

    test('séries courues, finales à venir : le tour coché', () {
      expect(eventBadge(event(heatsDone), l10n), (
        kind: EventBadgeKind.done,
        label: 'Séries ✓',
      ));
    });

    test('un seul tour, couru : Terminé', () {
      expect(eventBadge(event(heatsDone, withFinals: false), l10n), (
        kind: EventBadgeKind.done,
        label: 'Terminé',
      ));
    });

    test('à venir : l\'heure de son prochain créneau', () {
      final waiting = _item(1, [
        _heat(1, RunStatus.waiting),
      ], DateTime(2026, 3, 28, 15, 11));
      expect(eventBadge(event(waiting), l10n), (
        kind: EventBadgeKind.next,
        label: '15:11',
      ));
    });
  });

  test('stepLabel : plusieurs finales réunies se disent « Finales »', () {
    expect(stepLabel(_step(StageLevel.heats, [heatsDone]), l10n), 'Séries');
    expect(stepLabel(_step(StageLevel.finalStage, [finals]), l10n), 'Finale');
    expect(
      stepLabel(_step(StageLevel.finalStage, [finals], stageCount: 2), l10n),
      'Finales',
    );
  });

  group('stepDetail', () {
    test('couru : heure cochée', () {
      expect(
        stepDetail(_step(StageLevel.heats, [heatsDone]), _saturday, 'fr', l10n),
        '14:30 ✓',
      );
    });

    test('en cours : la série courue', () {
      expect(
        stepDetail(_step(StageLevel.heats, [heatsLive]), _saturday, 'fr', l10n),
        'Série 3/4',
      );
    });

    test('un autre jour : le jour avant l\'heure', () {
      expect(
        stepDetail(
          _step(StageLevel.finalStage, [finals]),
          _saturday,
          'fr',
          l10n,
        ),
        'dim. 29 15:00',
      );
      expect(
        stepDetail(_step(StageLevel.finalStage, [finals]), _sunday, 'fr', l10n),
        '15:00',
      );
    });

    test('prévu sans créneau : à venir', () {
      expect(
        stepDetail(
          const EventStep(
            level: StageLevel.finalStage,
            status: ItemStatus.none,
          ),
          _saturday,
          'fr',
          l10n,
        ),
        'À venir',
      );
    });
  });

  test('eventSubtitle : genre puis catégories', () {
    expect(eventSubtitle(event(heatsDone), l10n), 'Dames · Cadet, Junior');
    expect(
      eventSubtitle(
        const ProgrammeEvent(key: 'i1', name: 'x', status: ItemStatus.none),
        l10n,
      ),
      '',
    );
  });

  group('pastilles des séries', () {
    test('un seul tour, ou le tour en cours : montrées', () {
      expect(showsHeatDots(event(heatsDone, withFinals: false)), isTrue);
      expect(showsHeatDots(event(heatsLive)), isTrue);
      expect(showsHeatDots(event(heatsDone)), isFalse);
    });

    test('le libellé : la série en cours, sinon leur nombre', () {
      expect(heatDotsLabel(event(heatsLive), l10n), 'Série 3/4');
      expect(
        heatDotsLabel(event(heatsDone, withFinals: false), l10n),
        '2 séries',
      );
    });
  });

  test('meetingCollapsedLabel : une réunion terminée compte ses épreuves', () {
    final meeting = Meeting(
      id: 1,
      name: 'Réunion 1',
      day: _saturday,
      items: [
        const MeetingItem(id: 9, name: 'Échauffement'),
        heatsDone,
      ],
    );
    const programme = Programme();
    expect(
      meetingCollapsedLabel(meeting, programme, l10n, finished: true),
      'Terminée · 1 épreuve',
    );
    expect(
      meetingCollapsedLabel(meeting, programme, l10n, finished: false),
      '2 créneaux · 1 épreuve',
    );
  });
}
