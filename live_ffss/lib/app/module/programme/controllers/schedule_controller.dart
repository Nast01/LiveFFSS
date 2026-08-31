import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
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

/// A round of a structure that FFSS holds a `partie` for, and that no créneau
/// of the loaded réunions points at yet — one line of the palette.
///
/// The unit is the round, not the race: a créneau links to a partie, so a
/// whole round is what gets placed on a day at once.
class UnscheduledRound {
  const UnscheduledRound({
    required this.partieId,
    required this.raceId,
    required this.categoryId,
    required this.raceLabel,
    required this.categoryLabel,
    required this.type,
    required this.courseCount,
  });

  /// The FFSS `partie` this round became when the déroulement was pushed.
  final int partieId;
  final int raceId;
  final int categoryId;
  final String raceLabel;
  final String categoryLabel;
  final RoundType type;

  /// How many courses the round runs — shown so the operator knows what they
  /// will be creating on the federal site afterwards.
  final int courseCount;
}

class ScheduleController extends GetxController {
  ScheduleController(this._programme, this._meetings, this._user);

  final ProgrammeService _programme;
  final MeetingRepository _meetings;
  final UserService _user;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxList<DateTime> days = <DateTime>[].obs;
  final RxInt selectedDayIndex = 0.obs;

  /// The site the timeline is narrowed to; `null` means every site at once —
  /// the « Tous » chip, and the default.
  ///
  /// Keyed by name, not by local id: half the sites on screen come from the
  /// courses FFSS returns, and those carry a free-text site with no id to
  /// match on.
  final Rxn<String> selectedSite = Rxn<String>();

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

  /// Drops a selection whose site no longer exists anywhere — deleted from the
  /// local list *and* absent from every course. Falls back to « Tous » rather
  /// than to another site: silently narrowing the day to a site the operator
  /// never picked is worse than showing them everything.
  void _ensureValidSite() {
    final selected = selectedSite.value;
    if (selected != null && !_knownSiteNames.contains(selected)) {
      selectedSite.value = null;
    }
  }

  /// Every site name in play, across all days: the ones the operator declared
  /// locally and the ones FFSS puts on its courses.
  Set<String> get _knownSiteNames => {
        for (final site in sites)
          if (site.name.isNotEmpty) site.name,
        for (final meeting in meetings)
          for (final slot in meeting.slots)
            for (final run in slot.runs)
              if (run.site.isNotEmpty) run.site,
      };

  /// The sites [day] can be narrowed by: those its courses carry, plus those
  /// declared locally, merged and sorted. A site with no name would make a
  /// blank chip, so it is left out.
  List<String> siteNamesFor(DateTime day) {
    final names = <String>{
      for (final site in sites)
        if (site.name.isNotEmpty) site.name,
      for (final slot in meetingFor(day)?.slots ?? const <Slot>[])
        for (final run in slot.runs)
          if (run.site.isNotEmpty) run.site,
    }.toList()
      ..sort();
    return names;
  }

  /// Whether [site] passes the current selection. « Tous » lets everything by.
  bool showsSite(String site) =>
      selectedSite.value == null || selectedSite.value == site;

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

  // ---------------------------------------------------------------------
  // Local ScheduleBlock planner. Dormant: the timeline is drawn from the FFSS
  // réunion tree now, and no view calls into this group any more. It is kept
  // whole — with its tests — because placing a course on a créneau needs
  // `course/submit`, which answers every POST with
  // `500 Unknown named parameter $creneau` (verified in production). When FFSS
  // fixes it, this is what the palette writes through again.
  // ---------------------------------------------------------------------

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

  // ------------------------- end of the dormant planner ------------------

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
  ///
  /// Returns whether [meetings] now reflects FFSS. A write that follows up
  /// with [_pushMeetingEnd] has to know: computing the day's new end from a
  /// list the reload could not refresh would push a `fin` derived from the
  /// state *before* the write, and report it as a success.
  /// [silent] keeps [isLoading] down so the list stays on screen — a
  /// pull-to-refresh that swapped the day for a spinner would take the
  /// indicator out from under the operator's finger. A failure is still
  /// reported either way.
  Future<bool> reload({bool silent = false}) async {
    final id = competition.value?.id;
    if (id == null) return false;
    try {
      if (!silent) isLoading.value = true;
      hasError.value = false;
      meetings.value = await _meetings.getMeetings(id);
      return true;
    } on AppException {
      hasError.value = true;
      return false;
    } finally {
      if (!silent) isLoading.value = false;
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
  /// creation the design keeps for a day's first item. Returns 0 when the
  /// creation itself was refused or failed — either way, [message] carries
  /// why, so the caller can stop silently rather than send a créneau with no
  /// parent.
  Future<int> _ensureMeeting(DateTime day) async {
    final existing = meetingFor(day);
    if (existing != null) return existing.id;
    final competitionId = competition.value?.id;
    if (competitionId == null) return 0;
    int id;
    try {
      id = await _meetings.submitMeeting(
        competitionId: competitionId,
        name: _meetingName(day),
        description: '',
        date: day,
        beginHour: _atMinutes(day, defaultMeetingStartMinutes),
        endHour: _atMinutes(day, defaultMeetingStartMinutes),
      );
    } on AppException catch (e) {
      message.trigger(
          UiMessageError('failed_to_create_meeting', details: e.detail));
      return 0;
    }
    if (id <= 0) {
      message.trigger(const UiMessageError('failed_to_create_meeting'));
    }
    return id;
  }

  /// Pushes the réunion's `fin` back out to [endMinutesOfDay]'s current
  /// maximum, now that a write may have moved it. Passing the réunion's own
  /// [Meeting.id] turns this into an update rather than a duplicate.
  ///
  /// This runs *after* the item itself already landed, so a failure here
  /// leaves a stale `fin` on FFSS rather than an unsaved item — still worth
  /// reporting, since the app's own header recomputes from the slots and
  /// would otherwise never let the operator know the two have diverged.
  ///
  /// Every caller checks [reload] succeeded first: [endMinutesOfDay] reads
  /// [meetings], so a stale list would compute a `fin` for the day as it was
  /// before the write.
  Future<void> _pushMeetingEnd(DateTime day) async {
    final meeting = meetingFor(day);
    final competitionId = competition.value?.id;
    if (meeting == null || competitionId == null) return;
    int id;
    try {
      id = await _meetings.submitMeeting(
        competitionId: competitionId,
        name: meeting.name,
        description: meeting.description,
        date: day,
        beginHour: meeting.beginHour,
        endHour: _atMinutes(day, endMinutesOfDay(day)),
        id: meeting.id,
      );
    } on AppException catch (e) {
      message.trigger(
          UiMessageError('schedule_meeting_end_failed', details: e.detail));
      return;
    }
    if (id <= 0) {
      message.trigger(const UiMessageError('schedule_meeting_end_failed'));
    }
  }

  /// Moves the whole day to a new start time, in minutes past midnight.
  ///
  /// Every créneau shifts by the same amount, because a réunion that starts at
  /// 09:00 while its first item still says 08:00 states two different things
  /// about the same morning. The items go out first and the réunion last: if a
  /// créneau is refused the day is left where it was rather than half moved.
  ///
  /// Only shifts a day FFSS already holds. Creating a réunion here would leave
  /// an empty day on the federal site for nothing more than a change of mind
  /// about an hour.
  Future<void> setMeetingStart(DateTime day, int startMinutes) async {
    if (!canWriteToFfss) {
      message.trigger(const UiMessageError('login_required'));
      return;
    }
    final meeting = meetingFor(day);
    final competitionId = competition.value?.id;
    if (meeting == null || competitionId == null) {
      message.trigger(const UiMessageError('schedule_no_meeting'));
      return;
    }

    final delta = startMinutes - _minutesOf(meeting.beginHour);
    if (delta == 0) return;

    try {
      for (final slot in meeting.slots) {
        final moved = await _meetings.submitSlot(
          meetingId: meeting.id,
          name: slot.name,
          beginHour: _atMinutes(day, _minutesOf(slot.beginHour) + delta),
          endHour: _atMinutes(day, _minutesOf(slot.endHour) + delta),
          raceFormatDetailId: slot.raceFormatDetail?.id,
          id: slot.id,
        );
        if (moved <= 0) {
          message.trigger(const UiMessageError('schedule_item_failed'));
          return;
        }
      }

      final id = await _meetings.submitMeeting(
        competitionId: competitionId,
        name: meeting.name,
        description: meeting.description,
        date: day,
        beginHour: _atMinutes(day, startMinutes),
        endHour: _atMinutes(day, endMinutesOfDay(day) + delta),
        id: meeting.id,
      );
      if (id <= 0) {
        message.trigger(const UiMessageError('schedule_meeting_end_failed'));
        return;
      }
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('schedule_item_failed', details: e.detail));
      return;
    }

    await reload();
  }

  /// Repacks a day back-to-back from the réunion's start, in the order of
  /// [ordered], keeping each item's own duration — then pushes the réunion's
  /// new end.
  ///
  /// A créneau carries no rank of its own on FFSS: its place in the day *is*
  /// its start time. So reordering and repacking are the same operation, and
  /// removing or shortening an item without this leaves a hole — every item
  /// after it keeps the time it had, and the day reads wrong until the last
  /// one.
  ///
  /// Only the items whose times actually move are sent. On a day of twenty,
  /// deleting the last one should not rewrite the nineteen before it.
  Future<bool> _resequenceDay(DateTime day, List<Slot> ordered) async {
    final meeting = meetingFor(day);
    final competitionId = competition.value?.id;
    if (meeting == null || competitionId == null) return false;

    var cursor = _minutesOf(meeting.beginHour);
    try {
      for (final slot in ordered) {
        final duration = _minutesOf(slot.endHour) - _minutesOf(slot.beginHour);
        if (_minutesOf(slot.beginHour) != cursor) {
          final moved = await _meetings.submitSlot(
            meetingId: meeting.id,
            name: slot.name,
            beginHour: _atMinutes(day, cursor),
            endHour: _atMinutes(day, cursor + duration),
            raceFormatDetailId: slot.raceFormatDetail?.id,
            id: slot.id,
          );
          if (moved <= 0) {
            message.trigger(const UiMessageError('schedule_item_failed'));
            return false;
          }
        }
        cursor += duration;
      }

      final id = await _meetings.submitMeeting(
        competitionId: competitionId,
        name: meeting.name,
        description: meeting.description,
        date: day,
        beginHour: meeting.beginHour,
        endHour: _atMinutes(day, cursor),
        id: meeting.id,
      );
      if (id <= 0) {
        message.trigger(const UiMessageError('schedule_meeting_end_failed'));
        return false;
      }
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('schedule_item_failed', details: e.detail));
      return false;
    }
    return true;
  }

  /// Moves the item at [oldIndex] to [newIndex] within [day], then recomputes
  /// every time from the réunion's start.
  ///
  /// The new times *are* the new order — FFSS has nowhere else to record it —
  /// so this reuses the same repacking as a deletion.
  Future<void> reorderSlots(DateTime day, int oldIndex, int newIndex) async {
    if (!canWriteToFfss) {
      message.trigger(const UiMessageError('login_required'));
      return;
    }
    final meeting = meetingFor(day);
    if (meeting == null) return;
    final ordered = [...meeting.slots];
    if (oldIndex < 0 || oldIndex >= ordered.length) return;
    // A downward move is reported against the list *before* the item leaves
    // it, so the target index is one too high once it has been taken out.
    final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
    if (target == oldIndex) return;
    ordered.insert(
        target.clamp(0, ordered.length - 1), ordered.removeAt(oldIndex));

    if (await _resequenceDay(day, ordered)) await reload(silent: true);
  }

  /// The rounds still to place: those FFSS holds a `partie` for, minus those a
  /// créneau already points at.
  ///
  /// A round with no `serverId` is left out on purpose — nothing on FFSS could
  /// carry its créneau, so offering it would only earn the operator a refusal
  /// they could not act on. Pushing the déroulement from the Structure tab is
  /// what brings it into this list.
  List<UnscheduledRound> get unscheduledRounds {
    final placed = <int>{
      for (final meeting in meetings)
        for (final slot in meeting.slots)
          if (slot.raceFormatDetail != null) slot.raceFormatDetail!.id,
    };
    final rounds = <UnscheduledRound>[];
    for (final structure in _p?.structures ?? const <EventStructure>[]) {
      for (final level in structure.levels) {
        if (level.serverId <= 0 || placed.contains(level.serverId)) continue;
        rounds.add(UnscheduledRound(
          partieId: level.serverId,
          raceId: structure.raceId,
          categoryId: structure.categoryId,
          raceLabel: structure.raceLabel,
          categoryLabel: structure.categoryLabel,
          type: level.type,
          courseCount: level.races.length,
        ));
      }
    }
    return rounds;
  }

  /// Places a round on [day] as a créneau linked to its `partie`, with no
  /// course of its own.
  ///
  /// The courses would belong here too, but `course/submit` answers every POST
  /// with `500 Unknown named parameter $creneau` on the FFSS side. Until that
  /// is fixed the operator creates them on the federal site and pulls this
  /// screen down to collect them — which works, because the créneau this
  /// creates is exactly what they hang off.
  ///
  /// The créneau lasts [defaultItemMinutes] per course it will hold, so a
  /// round of three séries takes three times the room of one — the operator
  /// still adjusts it, but the day is roughly right before they do.
  ///
  /// [name] is composed by the view: naming a round needs the gender, and a
  /// gender is a translated word this controller has no business resolving.
  Future<void> scheduleRound({
    required int partieId,
    required String name,
    required DateTime day,
    required int courseCount,
  }) async {
    if (!canWriteToFfss) {
      message.trigger(const UiMessageError('login_required'));
      return;
    }
    final meetingId = await _ensureMeeting(day);
    if (meetingId <= 0) return;

    final beginMinutes = endMinutesOfDay(day);
    // At least one course's worth: a zero-length créneau would be invisible on
    // the timeline and would let the next item start on the same minute.
    final duration = defaultItemMinutes * (courseCount < 1 ? 1 : courseCount);
    int slotId;
    try {
      slotId = await _meetings.submitSlot(
        meetingId: meetingId,
        name: name,
        beginHour: _atMinutes(day, beginMinutes),
        endHour: _atMinutes(day, beginMinutes + duration),
        raceFormatDetailId: partieId,
      );
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('schedule_item_failed', details: e.detail));
      return;
    }
    if (slotId <= 0) {
      message.trigger(const UiMessageError('schedule_item_failed'));
      return;
    }
    if (!await reload()) {
      message.trigger(const UiMessageError('schedule_meeting_end_failed'));
      return;
    }
    await _pushMeetingEnd(day);
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
    int slotId;
    try {
      slotId = await _meetings.submitSlot(
        meetingId: meetingId,
        name: label,
        beginHour: _atMinutes(day, beginMinutes),
        endHour: _atMinutes(day, endMinutes),
      );
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('schedule_item_failed', details: e.detail));
      return;
    }
    if (slotId <= 0) {
      message.trigger(const UiMessageError('schedule_item_failed'));
      return;
    }
    if (!await reload()) {
      message.trigger(const UiMessageError('schedule_meeting_end_failed'));
      return;
    }
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
    int updatedId;
    try {
      updatedId = await _meetings.submitSlot(
        meetingId: meeting.id,
        name: slot.name,
        beginHour: _atMinutes(meeting.date, beginMinutes),
        endHour: _atMinutes(meeting.date, beginMinutes + minutes),
        raceFormatDetailId: slot.raceFormatDetail?.id,
        id: slotId,
      );
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('schedule_item_failed', details: e.detail));
      return;
    }
    if (updatedId <= 0) {
      message.trigger(const UiMessageError('schedule_item_failed'));
      return;
    }
    if (!await reload()) {
      message.trigger(const UiMessageError('schedule_meeting_end_failed'));
      return;
    }
    // Repacked, not just re-ended: shortening an item leaves the same hole a
    // deletion does, and lengthening one has it overlap the next.
    final refreshed = meetingFor(meeting.date);
    if (refreshed != null) {
      await _resequenceDay(meeting.date, refreshed.slots);
    }
  }

  /// Deletes a créneau, then repacks the day so nothing is left floating.
  Future<void> removeSlot(int slotId) async {
    if (!canWriteToFfss) {
      message.trigger(const UiMessageError('login_required'));
      return;
    }
    final owner = _slotOwner(slotId);
    if (owner == null) return;
    final day = owner.$1.date;
    bool ok;
    try {
      ok = await _meetings.deleteSlot(slotId);
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('schedule_item_failed', details: e.detail));
      return;
    }
    if (!ok) {
      message.trigger(const UiMessageError('schedule_item_failed'));
      return;
    }
    if (!await reload()) {
      message.trigger(const UiMessageError('schedule_meeting_end_failed'));
      return;
    }
    // Repacked, not just re-ended: the items after the one that went keep the
    // times they had, leaving a hole where it used to be.
    final meeting = meetingFor(day);
    if (meeting != null) await _resequenceDay(day, meeting.slots);
  }
}
