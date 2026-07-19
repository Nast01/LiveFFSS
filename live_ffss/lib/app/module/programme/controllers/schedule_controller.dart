import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart' as planner;

class ScheduleController extends GetxController {
  ScheduleController(this._programme);

  final ProgrammeService _programme;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxList<DateTime> days = <DateTime>[].obs;
  final RxInt selectedDayIndex = 0.obs;
  final Rxn<int> selectedSiteId = Rxn<int>();

  Worker? _worker;

  @override
  void onInit() {
    super.onInit();
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

  DateTime? get selectedDay => days.isEmpty
      ? null
      : days[selectedDayIndex.value.clamp(0, days.length - 1)];

  void setCompetition(Competition? comp) {
    if (comp == competition.value) return;
    competition.value = comp;
    days.value = planner.competitionDays(comp?.beginDate, comp?.endDate);
    selectedDayIndex.value = 0;
    if (selectedSiteId.value == null && sites.isNotEmpty) {
      selectedSiteId.value = sites.first.id;
    }
  }

  List<planner.ScheduleRow> rowsFor(int siteId, DateTime day) {
    final p = _p;
    return p == null ? const [] : planner.scheduleRows(p, siteId, day);
  }

  List<planner.ScheduleItem> get unscheduled {
    final p = _p;
    return p == null ? const [] : planner.unscheduledRaces(p);
  }

  int startMinutesFor(int siteId, DateTime day) {
    final p = _p;
    return p == null ? planner.defaultStartMinutes : planner.dayStartMinutes(p, siteId, day);
  }

  Future<void> addRace(int raceId, int siteId, DateTime day) async {
    if (_p == null) return;
    final id = _programme.allocateId();
    await _programme.save(planner.addRaceBlock(_programme.current.value!, id, raceId, siteId, day));
  }

  Future<void> addManual(String label, int minutes, int siteId, DateTime day) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty || minutes < 1 || _p == null) return;
    final id = _programme.allocateId();
    await _programme.save(
        planner.addManualBlock(_programme.current.value!, id, trimmed, minutes, siteId, day));
  }

  Future<void> reorder(int siteId, DateTime day, int oldIndex, int newIndex) async {
    final p = _p;
    if (p == null) return;
    await _programme.save(planner.reorderBlocks(p, siteId, day, oldIndex, newIndex));
  }

  Future<void> setDuration(int blockId, int minutes) async {
    if (minutes < 1) return;
    final p = _p;
    if (p == null) return;
    await _programme.save(planner.setBlockDuration(p, blockId, minutes));
  }

  Future<void> setManualLabel(int blockId, String label) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;
    final p = _p;
    if (p == null) return;
    await _programme.save(planner.setManualLabel(p, blockId, trimmed));
  }

  Future<void> removeBlock(int blockId) async {
    final p = _p;
    if (p == null) return;
    await _programme.save(planner.removeBlock(p, blockId));
  }

  Future<void> setDayStart(int siteId, DateTime day, int minutes) async {
    final p = _p;
    if (p == null) return;
    await _programme.save(planner.setDayStart(p, siteId, day, minutes));
  }
}
