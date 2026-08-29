import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart' as planner;
import 'package:live_ffss/app/domain/models/slot.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

/// A réunion with no item yet defaults to 08:00 — the FFSS réunion's own
/// default (see the design spec). This is deliberately its own constant
/// rather than [planner.defaultStartMinutes] (09:00): that one is the *local*
/// schedule planner's fallback for a site with no [planner.dayStartMinutes]
/// override, a different question the two planners simply answer differently.
const int defaultMeetingStartMinutes = 8 * 60;

/// Duration of a newly added manual item — the value the local planner
/// already used, kept so the rhythm doesn't change for anyone who knows it.
const int defaultItemMinutes = 10;

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

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

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
  ///
  /// A failure flips [hasError] rather than the one-shot [message]: an
  /// operator who cannot see why the day looks empty needs a state the view
  /// keeps rendering (with a retry), not a toast that has already vanished by
  /// the time they look up — the same convention as
  /// `ProgrammeController.load`. [meetings] is left as it was rather than
  /// cleared, so a stale-but-real day beats a blank one.
  Future<void> reload() async {
    final id = competition.value?.id;
    if (id == null) return;
    try {
      isLoading.value = true;
      hasError.value = false;
      meetings.value = await _meetings.getMeetings(id);
    } on AppException {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Minutes past midnight → a real [DateTime] on [day] — the counterpart of
  /// [_minutesOf], needed because FFSS writes want a date-bearing time.
  DateTime _atMinutes(DateTime day, int minutes) =>
      DateTime(day.year, day.month, day.day, minutes ~/ 60, minutes % 60);

  /// The réunion's name follows **the application's language**, not a forced
  /// one: it will show up exactly like this on the federal site.
  String _meetingName(DateTime day) =>
      DateFormat('EEEE d MMMM y', Get.locale?.toString()).format(day);

  /// The id of the réunion covering [day], creating it at
  /// [defaultMeetingStartMinutes] first when FFSS has none yet — the implicit
  /// creation the design keeps for a day's first item. Returns 0 (or
  /// whatever FFSS answered) when the creation itself was refused.
  Future<int> _ensureMeeting(DateTime day) async {
    final existing = meetingFor(day);
    if (existing != null) return existing.id;
    final competitionId = competition.value?.id;
    if (competitionId == null) return 0;
    return _meetings.submitMeeting(
      competitionId: competitionId,
      name: _meetingName(day),
      description: '',
      date: day,
      beginHour: _atMinutes(day, defaultMeetingStartMinutes),
      endHour: _atMinutes(day, defaultMeetingStartMinutes),
    );
  }

  /// Pushes the réunion's `fin` back out to [endMinutesOfDay]'s current
  /// maximum, now that a write may have moved it. Passing the réunion's own
  /// [Meeting.id] turns this into an update rather than a duplicate.
  Future<void> _pushMeetingEnd(DateTime day) async {
    final meeting = meetingFor(day);
    final competitionId = competition.value?.id;
    if (meeting == null || competitionId == null) return;
    await _meetings.submitMeeting(
      competitionId: competitionId,
      name: meeting.name,
      description: meeting.description,
      date: day,
      beginHour: meeting.beginHour,
      endHour: _atMinutes(day, endMinutesOfDay(day)),
      id: meeting.id,
    );
  }

  /// The réunion holding [slotId] and the créneau itself, among the loaded
  /// [meetings] — a write needs the meetingId to resubmit its own créneau.
  (Meeting, Slot)? _slotOwner(int slotId) {
    for (final meeting in meetings) {
      for (final slot in meeting.slots) {
        if (slot.id == slotId) return (meeting, slot);
      }
    }
    return null;
  }

  /// Adds an informational item to [day], creating the réunion first when it
  /// doesn't exist yet, then pushes the new end of day back to FFSS.
  ///
  /// The item starts at the day's current end and lasts
  /// [defaultItemMinutes]. A signed-out operator is refused before anything
  /// leaves the device — FFSS would otherwise answer an anonymous write with
  /// a bare "Invalid Token" that reads like a server fault.
  Future<void> addManualItem(String label, DateTime day) async {
    if (!canWriteToFfss) {
      message.trigger(const UiMessageError('login_required'));
      return;
    }
    final meetingId = await _ensureMeeting(day);
    if (meetingId <= 0) return;

    final beginMinutes = endMinutesOfDay(day);
    final endMinutes = beginMinutes + defaultItemMinutes;
    final slotId = await _meetings.submitSlot(
      meetingId: meetingId,
      name: label,
      beginHour: _atMinutes(day, beginMinutes),
      endHour: _atMinutes(day, endMinutes),
    );
    if (slotId <= 0) {
      message.trigger(const UiMessageError('schedule_item_failed'));
      return;
    }
    await reload();
    await _pushMeetingEnd(day);
  }

  /// Resizes an existing créneau, keeping its own start time, then pushes the
  /// day's new end. Works on any créneau [_slotOwner] can find — a manual
  /// item today, since planning a course onto one is a later step.
  Future<void> setSlotDuration(int slotId, int minutes) async {
    if (minutes < 1) return;
    if (!canWriteToFfss) {
      message.trigger(const UiMessageError('login_required'));
      return;
    }
    final owner = _slotOwner(slotId);
    if (owner == null) return;
    final (meeting, slot) = owner;
    final beginMinutes = _minutesOf(slot.beginHour);
    final updatedId = await _meetings.submitSlot(
      meetingId: meeting.id,
      name: slot.name,
      beginHour: _atMinutes(meeting.date, beginMinutes),
      endHour: _atMinutes(meeting.date, beginMinutes + minutes),
      raceFormatDetailId: slot.raceFormatDetail?.id,
      id: slotId,
    );
    if (updatedId <= 0) {
      message.trigger(const UiMessageError('schedule_item_failed'));
      return;
    }
    await reload();
    await _pushMeetingEnd(meeting.date);
  }

  /// Deletes a créneau, then pushes the day's new (possibly shorter) end.
  Future<void> removeSlot(int slotId) async {
    if (!canWriteToFfss) {
      message.trigger(const UiMessageError('login_required'));
      return;
    }
    final owner = _slotOwner(slotId);
    if (owner == null) return;
    final day = owner.$1.date;
    final ok = await _meetings.deleteSlot(slotId);
    if (!ok) {
      message.trigger(const UiMessageError('schedule_item_failed'));
      return;
    }
    await reload();
    await _pushMeetingEnd(day);
  }
}
