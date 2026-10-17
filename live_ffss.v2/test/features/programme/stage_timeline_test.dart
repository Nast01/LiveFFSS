import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/progression.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/features/programme/programme_formatting.dart';

Heat heat(RunStatus status, {int? seriesId = 1}) => Heat(
  id: status.index,
  name: 'Série',
  number: 1,
  status: status,
  seriesId: seriesId,
);

MeetingItem item(
  String name, {
  List<Heat> heats = const [],
  DateTime? start,
  DateTime? end,
}) => MeetingItem(
  id: name.hashCode,
  name: name,
  heats: heats,
  startTime: start,
  endTime: end,
);

Stage stage(String name) => Stage(
  id: 1,
  order: 1,
  level: StageLevel.finalStage,
  name: name,
  qualification: QualificationMethod.none,
  heatCount: 2,
  placesPerHeat: 8,
);

void main() {
  setUpAll(() => initializeDateFormatting('fr'));

  group('stageStatus', () {
    test('aucun créneau : rien', () {
      expect(stageStatus(const []), ItemStatus.none);
    });

    test('un créneau en direct : en direct', () {
      expect(
        stageStatus([
          item('B', heats: [heat(RunStatus.finished)]),
          item('A', heats: [heat(RunStatus.inProgress)]),
        ]),
        ItemStatus.live,
      );
    });

    test('tous terminés : terminé', () {
      expect(
        stageStatus([
          item('B', heats: [heat(RunStatus.finished)]),
          item('A', heats: [heat(RunStatus.finished)]),
        ]),
        ItemStatus.finished,
      );
    });

    test('aucune série générée : séries à venir', () {
      expect(
        stageStatus([
          item('B', heats: [heat(RunStatus.waiting, seriesId: null)]),
          item('A', heats: [heat(RunStatus.waiting, seriesId: null)]),
        ]),
        ItemStatus.seriesPending,
      );
    });

    test('un terminé, un à venir : à venir', () {
      expect(
        stageStatus([
          item('B', heats: [heat(RunStatus.finished)]),
          item('A', heats: [heat(RunStatus.waiting)]),
        ]),
        ItemStatus.upcoming,
      );
    });
  });

  test('stageCategories : la partie du nom après le niveau', () {
    expect(stageCategories(stage('Finale - Cadet')), 'Cadet');
    expect(
      stageCategories(stage('Série - Cadet, Junior, Seniors et Masters')),
      'Cadet, Junior, Seniors et Masters',
    );
    expect(stageCategories(stage('Finale')), isNull);
  });

  test('itemChipLabel : le début du nom du créneau et son heure', () {
    expect(
      itemChipLabel(
        item(
          'Finale B · 200m Obstacles Dames (Cadet)',
          start: DateTime(2026, 3, 27, 15, 0),
        ),
      ),
      'Finale B · 15:00',
    );
    expect(itemChipLabel(item('Finale A')), 'Finale A');
  });

  test('stageScheduleLabel : jour et plage horaire du créneau', () {
    expect(
      stageScheduleLabel(
        item(
          'Série',
          start: DateTime(2026, 3, 27, 8, 0),
          end: DateTime(2026, 3, 27, 8, 40),
        ),
        'fr',
      ),
      'ven. 27 · 08:00 – 08:40',
    );
    expect(stageScheduleLabel(item('Série'), 'fr'), '');
  });
}
