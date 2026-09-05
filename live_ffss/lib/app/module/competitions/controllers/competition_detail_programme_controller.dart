import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart' as planner;
import 'package:live_ffss/app/presentation/modules/programme/day_sections.dart';

/// Read-only view of a competition's programme for the "Programme" tab.
///
/// The timetable is read straight from the FFSS réunion tree, exactly like the
/// schedule editor — the federation is the source of truth, so a change made on
/// ffss.fr shows up here on the next open. The device-local programme is still
/// loaded, but for one job only: bridging a tapped course to its épreuve, which
/// nothing in the réunion payload can do (a course carries no race id).
class CompetitionDetailProgrammeController extends GetxController {
  CompetitionDetailProgrammeController(
      this._programme, this._raceRepo, this._meetings);

  final ProgrammeService _programme;
  final RaceRepository _raceRepo;
  final MeetingRepository _meetings;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxList<DateTime> days = <DateTime>[].obs;
  final RxInt selectedDayIndex = 0.obs;
  final RxList<Meeting> meetings = <Meeting>[].obs;

  /// The site the operator picked, by name — FFSS puts a free-text site on
  /// each course and gives it no id of its own.
  final Rxn<String> selectedSite = Rxn<String>();

  Map<int, Race> _racesByFfssId = const {};

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Competition) {
      load(arg);
    } else {
      isLoading.value = false;
    }
  }

  bool get hasProgramme => meetings.any((m) => m.slots.isNotEmpty);

  DateTime? get selectedDay => days.isEmpty
      ? null
      : days[selectedDayIndex.value.clamp(0, days.length - 1)];

  Future<void> load(Competition comp) async {
    competition.value = comp;
    days.value = planner.competitionDays(comp.beginDate, comp.endDate);
    isLoading.value = true;
    hasError.value = false;
    try {
      meetings.value = await _meetings.getMeetings(comp.id);
    } on AppException {
      meetings.clear();
      hasError.value = true;
    }
    // The local programme and the races only serve the tap bridge; neither is
    // worth failing the screen over.
    try {
      await _programme.load(comp.id);
    } on AppException {
      // Storage is device-local; a failure here just leaves taps inert.
    }
    try {
      final races = await _raceRepo.getRaces(comp.id);
      _racesByFfssId = {for (final r in races) r.id: r};
    } on AppException {
      _racesByFfssId = const {};
    }
    isLoading.value = false;
  }

  /// The réunion covering [day], compared by calendar date: [Meeting.date]
  /// carries the réunion's real day while its slots'/runs' times land on
  /// 1970-01-01.
  Meeting? meetingFor(DateTime day) {
    for (final meeting in meetings) {
      if (planner.sameDay(meeting.date, day)) return meeting;
    }
    return null;
  }

  List<DaySection> sectionsFor(DateTime day) => daySections(meetingFor(day));

  /// The sites [day] runs on, in running order. Manual créneaux belong to no
  /// site, so they are never offered as one.
  List<String> siteNamesFor(DateTime day) => [
        for (final section in sectionsFor(day))
          if (!section.isManual) section.title,
      ];

  /// The site [day] is narrowed to. [selectedSite] is an override, not a
  /// requirement: a site picked on one day may not exist on the next, and
  /// honouring it there would show an empty day instead of the schedule that
  /// is actually on.
  String? activeSiteFor(DateTime day) {
    final names = siteNamesFor(day);
    if (names.isEmpty) return null;
    final picked = selectedSite.value;
    return picked != null && names.contains(picked) ? picked : names.first;
  }

  /// [day]'s schedule as shown: the active site, plus the manual items, which
  /// concern the whole day and so survive any site filter.
  List<DaySection> visibleSectionsFor(DateTime day) {
    final active = activeSiteFor(day);
    return [
      for (final section in sectionsFor(day))
        if (section.isManual || section.title == active) section,
    ];
  }

  /// The domain [Race] a course belongs to.
  ///
  /// The réunion tree carries no race id, so the hop goes through the local
  /// programme: the course was recorded on a [ProgrammeRace] when it was
  /// created, and its structure names the épreuve. A programme authored on
  /// another device leaves this null, and the row is simply not tappable.
  Race? raceForRun(int runId) {
    final programme = _programme.current.value;
    if (programme == null) return null;
    for (final structure in programme.structures) {
      for (final level in structure.levels) {
        for (final race in level.races) {
          if (race.runId == runId) return _racesByFfssId[structure.raceId];
        }
      }
    }
    return null;
  }
}
