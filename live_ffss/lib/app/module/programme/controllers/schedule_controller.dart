import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/domain/models/race_placement.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

class ScheduleController extends GetxController {
  ScheduleController(this._programme);

  final ProgrammeService _programme;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxList<DateTime> days = <DateTime>[].obs;
  final RxInt selectedDayIndex = 0.obs;
  final Rxn<int> selectedSiteId = Rxn<int>();
  final Rxn<UiMessage> message = Rxn<UiMessage>();

  Worker? _worker;

  @override
  void onInit() {
    super.onInit();
    // Default the selected site once sites exist / change.
    _worker = ever<CompetitionProgramme?>(_programme.current, (_) {
      if (selectedSiteId.value == null && sites.isNotEmpty) {
        selectedSiteId.value = sites.first.id;
      }
    });
  }

  @override
  void onClose() {
    _worker?.dispose();
    super.onClose();
  }

  CompetitionProgramme? get _p => _programme.current.value;

  List<ProgrammeSite> get sites => _p?.sites ?? const [];

  DateTime? get selectedDay =>
      days.isEmpty ? null : days[selectedDayIndex.value.clamp(0, days.length - 1)];

  /// Idempotent: recomputes the day list from the competition's dates and
  /// defaults the selected site. Safe to call on every rebuild.
  void setCompetition(Competition? comp) {
    if (comp == competition.value) return;
    competition.value = comp;
    days.value = competitionDays(comp?.beginDate, comp?.endDate);
    selectedDayIndex.value = 0;
    if (selectedSiteId.value == null && sites.isNotEmpty) {
      selectedSiteId.value = sites.first.id;
    }
  }

  List<ScheduleItem> get unscheduled {
    final p = _p;
    if (p == null) return const [];
    final items = allScheduleItems(p).where((i) => i.placement == null).toList()
      ..sort((a, b) {
        final byLabel = a.raceLabel.compareTo(b.raceLabel);
        if (byLabel != 0) return byLabel;
        return a.number.compareTo(b.number);
      });
    return items;
  }

  List<ScheduleItem> placedOn(int siteId, DateTime day) {
    final p = _p;
    if (p == null) return const [];
    final items = allScheduleItems(p)
        .where((i) =>
            i.placement != null &&
            i.placement!.siteId == siteId &&
            sameDay(i.placement!.beginHour, day))
        .toList()
      ..sort((a, b) => a.placement!.beginHour.compareTo(b.placement!.beginHour));
    return items;
  }

  Future<void> place(int raceId, int siteId, DateTime day) async {
    final p = _p;
    if (p == null) return;
    final existing = placedOn(siteId, day).map((i) => i.placement!).toList();
    final start = nextFreeStart(day: day, onSiteDay: existing);
    await _programme.save(setPlacement(
      p,
      raceId,
      RacePlacement(siteId: siteId, beginHour: start),
    ));
  }

  Future<void> setDuration(int raceId, int minutes) async {
    if (minutes < 1) return;
    final p = _p;
    if (p == null) return;
    RacePlacement? current;
    for (final i in allScheduleItems(p)) {
      if (i.raceId == raceId) {
        current = i.placement;
        break;
      }
    }
    if (current == null) return;
    final candidate = current.copyWith(durationMinutes: minutes);
    final others = placedOn(current.siteId, current.beginHour)
        .where((i) => i.raceId != raceId)
        .map((i) => i.placement!);
    if (overlaps(candidate: candidate, others: others)) {
      message.value = const UiMessageError('schedule_overlap');
      return;
    }
    await _programme.save(setPlacement(p, raceId, candidate));
  }

  Future<void> unschedule(int raceId) async {
    final p = _p;
    if (p == null) return;
    await _programme.save(setPlacement(p, raceId, null));
  }
}
