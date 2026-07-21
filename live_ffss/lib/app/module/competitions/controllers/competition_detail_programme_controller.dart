import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart' as planner;

/// Read-only view of a competition's stored programme for the "Programme" tab.
/// Loads the programme (from [ProgrammeService]) and the domain races (from
/// [RaceRepository]) so a scheduled race block can be bridged to its race
/// detail. No mutation.
class CompetitionDetailProgrammeController extends GetxController {
  CompetitionDetailProgrammeController(this._programme, this._raceRepo);

  final ProgrammeService _programme;
  final RaceRepository _raceRepo;

  final Rxn<Competition> competition = Rxn<Competition>();
  final RxBool isLoading = true.obs;
  final RxList<DateTime> days = <DateTime>[].obs;
  final RxInt selectedDayIndex = 0.obs;
  final Rxn<int> selectedSiteId = Rxn<int>();

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

  CompetitionProgramme? get _p => _programme.current.value;

  List<ProgrammeSite> get sites => _p?.sites ?? const [];

  bool get hasProgramme => (_p?.blocks ?? const []).isNotEmpty;

  DateTime? get selectedDay => days.isEmpty
      ? null
      : days[selectedDayIndex.value.clamp(0, days.length - 1)];

  Future<void> load(Competition comp) async {
    competition.value = comp;
    days.value = planner.competitionDays(comp.beginDate, comp.endDate);
    try {
      isLoading.value = true;
      await _programme.load(comp.id);
      final races = await _raceRepo.getRaces(comp.id);
      _racesByFfssId = {for (final r in races) r.id: r};
    } on AppException {
      // Races unavailable (offline / API error): the programme is local and
      // still renders; taps that need a domain race are inert.
      _racesByFfssId = const {};
    } finally {
      final s = sites;
      if (s.isNotEmpty) selectedSiteId.value = s.first.id;
      isLoading.value = false;
    }
  }

  List<planner.ScheduleRow> rowsFor(int siteId, DateTime day) {
    final p = _p;
    return p == null ? const [] : planner.scheduleRows(p, siteId, day);
  }

  int startMinutesFor(int siteId, DateTime day) {
    final p = _p;
    return p == null
        ? planner.defaultStartMinutes
        : planner.dayStartMinutes(p, siteId, day);
  }

  planner.ScheduleItem? itemFor(int blockRaceId) {
    final p = _p;
    return p == null ? null : planner.raceItemFor(p, blockRaceId);
  }

  RoundType roundOf(int blockRaceId) {
    final p = _p;
    return p == null
        ? RoundType.unknown
        : (planner.raceItemFor(p, blockRaceId)?.roundType ?? RoundType.unknown);
  }

  /// The domain [Race] for a scheduled race block, bridged via the owning
  /// structure's FFSS race id. Null for a manual block or when the race isn't
  /// among the loaded races.
  Race? raceForBlock(int blockRaceId) {
    final p = _p;
    if (p == null) return null;
    final ffssId = planner.structureRaceIdFor(p, blockRaceId);
    return ffssId == null ? null : _racesByFfssId[ffssId];
  }
}
