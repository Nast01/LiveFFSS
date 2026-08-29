import 'package:get/get.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart' as planner;
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

/// A réunion with no item yet defaults to 08:00 — the FFSS réunion's own
/// default (see the design spec). This is deliberately its own constant
/// rather than [planner.defaultStartMinutes] (09:00): that one is the *local*
/// schedule planner's fallback for a site with no [planner.dayStartMinutes]
/// override, a different question the two planners simply answer differently.
const int defaultMeetingStartMinutes = 8 * 60;

class ScheduleController extends GetxController {
  ScheduleController(this._programme, this._meetings, this._user);

  final ProgrammeService _programme;
  final MeetingRepository _meetings;
  final UserService _user;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxList<DateTime> days = <DateTime>[].obs;
  final RxInt selectedDayIndex = 0.obs;
  final Rxn<int> selectedSiteId = Rxn<int>();

  /// The réunions of the current competition, as FFSS holds them — one per
  /// competition day, each with its créneaux and their courses.
  final RxList<Meeting> meetings = <Meeting>[].obs;

  final Rxn<UiMessage> message = Rxn<UiMessage>();

  Worker? _worker;

  @override
  void onInit() {
    super.onInit();
    _worker = ever<CompetitionProgramme?>(
        _programme.current, (_) => _ensureValidSite());
  }

  @override
  void onClose() {
    _worker?.dispose();
    super.onClose();
  }

  void _ensureValidSite() {
    final ids = sites.map((s) => s.id).toSet();
    if (selectedSiteId.value == null || !ids.contains(selectedSiteId.value)) {
      selectedSiteId.value = sites.isEmpty ? null : sites.first.id;
    }
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
    _ensureValidSite();
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
    return p == null
        ? planner.defaultStartMinutes
        : planner.dayStartMinutes(p, siteId, day);
  }

  Future<void> addRace(int raceId, int siteId, DateTime day) async {
    if (_p == null) return;
    final id = _programme.allocateId();
    await _programme.save(planner.addRaceBlock(
        _programme.current.value!, id, raceId, siteId, day));
  }

  /// Schedules a whole épreuve at once, in the order given, as one write.
  ///
  /// The ids are allocated first and the programme re-read afterwards:
  /// [ProgrammeService.allocateId] bumps `nextLocalId` on the live programme,
  /// so folding blocks onto a copy captured beforehand would save the old
  /// counter and hand the same ids out twice.
  Future<void> addRaces(List<int> raceIds, int siteId, DateTime day) async {
    if (_p == null || raceIds.isEmpty) return;
    final blockIds = [
      for (var i = 0; i < raceIds.length; i++) _programme.allocateId()
    ];
    var next = _programme.current.value!;
    for (var i = 0; i < raceIds.length; i++) {
      next = planner.addRaceBlock(next, blockIds[i], raceIds[i], siteId, day);
    }
    await _programme.save(next);
  }

  List<planner.ScheduleGroup> get unscheduledGroups =>
      planner.groupUnscheduled(unscheduled);

  Future<void> addManual(
      String label, int minutes, int siteId, DateTime day) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty || minutes < 1 || _p == null) return;
    final id = _programme.allocateId();
    await _programme.save(planner.addManualBlock(
        _programme.current.value!, id, trimmed, minutes, siteId, day));
  }

  Future<void> reorder(
      int siteId, DateTime day, int oldIndex, int newIndex) async {
    final p = _p;
    if (p == null) return;
    await _programme
        .save(planner.reorderBlocks(p, siteId, day, oldIndex, newIndex));
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

  planner.ScheduleItem? scheduleItemFor(int raceId) {
    final p = _p;
    return p == null ? null : planner.raceItemFor(p, raceId);
  }

  RoundType roundOf(int raceId) {
    final p = _p;
    return p == null
        ? RoundType.unknown
        : (planner.raceItemFor(p, raceId)?.roundType ?? RoundType.unknown);
  }

  /// Everything this screen reads is public, so a signed-out operator gets in
  /// without friction — only a write comes back refused.
  bool get canWriteToFfss => _user.currentUser.value != null;

  /// The réunion covering [day], if FFSS has one. Compared by calendar date,
  /// like [planner.sameDay]: [Meeting.date] carries the réunion's real day,
  /// while its slots'/runs' `DateTime`s do not (see [endMinutesOfDay]).
  Meeting? meetingFor(DateTime day) {
    for (final meeting in meetings) {
      if (planner.sameDay(meeting.date, day)) return meeting;
    }
    return null;
  }

  /// Minutes past midnight, ignoring the calendar date on [t].
  int _minutesOf(DateTime t) => t.hour * 60 + t.minute;

  /// The end of [day]'s réunion, in minutes past midnight: the latest item
  /// across every site. Sites run in parallel timelines, so this is a
  /// maximum, not a sum — and a réunion with nothing in it does not "last",
  /// it ends at its own start.
  ///
  /// In minutes rather than [DateTime]: a [Slot]/[Run]'s begin/end is parsed
  /// from a bare `HH:mm` and lands on 1970-01-01, while [Meeting.beginHour]
  /// carries the réunion's real date. Comparing the two as [DateTime]s would
  /// always read as "before". Everything here happens inside a single day, so
  /// minutes are enough — and the mappers, shared with the Slot module, stay
  /// untouched.
  int endMinutesOfDay(DateTime day) {
    final meeting = meetingFor(day);
    if (meeting == null) return defaultMeetingStartMinutes;
    var latest = _minutesOf(meeting.beginHour);
    for (final slot in meeting.slots) {
      // A créneau with no course is a manual item: its own times are all
      // there is, or it would not weigh on the day's end at all.
      final ends = slot.runs.isEmpty
          ? [_minutesOf(slot.endHour)]
          : [for (final run in slot.runs) _minutesOf(run.endTime)];
      for (final end in ends) {
        if (end > latest) latest = end;
      }
    }
    return latest;
  }

  /// Pulls the current competition's réunion tree from FFSS into [meetings].
  /// A no-op before a competition is known.
  Future<void> reload() async {
    final id = competition.value?.id;
    if (id == null) return;
    meetings.value = await _meetings.getMeetings(id);
  }
}
