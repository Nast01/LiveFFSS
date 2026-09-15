import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/repositories/race_format_repository.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/data/services/meeting_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/competitor.dart' show competitorsOf;
import 'package:live_ffss/app/domain/models/course_penalty.dart';
import 'package:live_ffss/app/domain/models/course_ranking.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/lane.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/run.dart';
import 'package:live_ffss/app/domain/models/slot.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/domain/models/structure_generator.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/data/mappers/athlete_mapper.dart'
    show parseGender;
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';

/// One entry of the round menu bar: a round of one category's structure.
/// Carries no label of its own — translating is the view's job.
class RoundTab {
  const RoundTab({
    required this.structure,
    required this.level,
    required this.levelIndex,
  });

  final EventStructure structure;
  final RoundLevel level;

  /// Position of [level] within its own structure's chain.
  final int levelIndex;

  int get categoryId => structure.categoryId;
  String get categoryLabel => structure.categoryLabel;
  RoundType get type => level.type;

  /// Whether this round opens its structure's chain. Only an opening round is
  /// drawn from the athletes present — every later round is seated by whoever
  /// qualifies out of the one before it.
  bool get isFirstRound => levelIndex == 0;
}

/// Feeds the race-detail "Séries" tab with the locally-defined structure(s) for
/// this race (one per category), plus per-category engaged counts. Read-only.
class RaceStructureController extends GetxController {
  RaceStructureController(
    this._programme,
    this._raceRepo,
    this._clubRepo,
    this._meetings,
    this._raceFormatRepo,
    this._meetingTree,
  );

  final ProgrammeService _programme;
  final RaceRepository _raceRepo;
  final ClubRepository _clubRepo;
  final MeetingRepository _meetings;
  final RaceFormatRepository _raceFormatRepo;

  /// Le propriétaire de l'arbre réunion. Cet écran le lit sans en être
  /// responsable : il s'en remet à ce que le service détient plutôt que de
  /// redemander une requête par créneau de la compétition à chaque ouverture.
  final MeetingService _meetingTree;

  final Rxn<Race> race = Rxn<Race>();
  final Rxn<Competition> competition = Rxn<Competition>();
  final RxBool isLoading = true.obs;
  final RxList<EventStructure> structures = <EventStructure>[].obs;

  Map<int, int> _entryCountByCategory = const {};

  /// The competition's réunions, for the créneaux and courses the rounds of
  /// this race were scheduled into.
  /// Les réunions de la compétition, telles que le service les détient.
  List<Meeting> get _meetingsOfCompetition => _meetingTree.meetings;

  /// Ce que FFSS porte pour une course tirée, indexé par id de ProgrammeRace
  /// puis par engagement. Rempli seulement pour les courses qui portent une
  /// `serie` ; ailleurs l'écran continue de lire l'ordre d'arrivée propre à
  /// l'appareil.
  final Map<int, Map<int, HeatResult>> _serverResults = {};

  /// Id de série FFSS d'une course, par id de ProgrammeRace — vide quand la
  /// course n'en porte aucune. Passé tel quel à l'écran de saisie, qui n'a
  /// ainsi pas besoin de refaire l'arbre des réunions pour retrouver la
  /// série qu'il doit relire. Memo de passe comme `_seatsByCourse`, vidé à
  /// chaque `load()`.
  final Map<int, int> _courseHeatIds = {};

  /// Places lues pendant ce `load()`, par id de course.
  ///
  /// Les deux passes d'import interrogent largement les memes courses :
  /// `_importCompositions` pour savoir qui est place, `_importResults` pour
  /// relier un classement a des athletes. Sans ce memo chacune paie son propre
  /// aller-retour sur les memes places.
  ///
  /// Memo de passe et non cache : vide a chaque `load()`, parce qu'un
  /// rechargement doit justement relire ce que le serveur a change depuis.
  final Map<int, List<LaneSeat>> _seatsByCourse = {};

  /// Athlete id -> athlete, built from the entries this race already fetches,
  /// with clubs resolved. It is what turns a drawn race's `athleteIds` back
  /// into rows the operator can read.
  Map<int, Athlete> _athletesById = const {};

  /// Id d'engagement -> engagement, athlètes patchés avec le club déjà résolu
  /// par `_indexAthletes`. Sans ce patch, `entriesOf` — qui lit directement
  /// cette map dès qu'un tirage porte des `entryIds` — rendrait des athlètes
  /// sans club, et la ligne retomberait sur l'initiale au lieu du logo.
  Map<int, Entry> _entriesById = const {};

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    Race? r;
    Competition? c;
    if (arg is Map) {
      final ar = arg['race'];
      final ac = arg['competition'];
      if (ar is Race) r = ar;
      if (ac is Competition) c = ac;
    } else if (arg is Race) {
      r = arg;
    }
    if (r != null && c != null) {
      load(r, c);
    } else {
      if (r != null) race.value = r;
      if (c != null) competition.value = c;
      isLoading.value = false;
    }
  }

  /// Re-reads everything this screen shows, without blanking it: the pull
  /// gesture already shows its own indicator, and flipping [isLoading] would
  /// swap the list for a spinner under the operator's finger.
  Future<void> reload() async {
    final r = race.value;
    final comp = competition.value;
    if (r == null || comp == null) return;
    await load(r, comp, silent: true);
  }

  Future<void> load(
    Race race,
    Competition competition, {
    bool silent = false,
  }) async {
    this.race.value = race;
    this.competition.value = competition;
    _seatsByCourse.clear();
    _courseHeatIds.clear();
    if (!silent) isLoading.value = true;
    try {
      await _programme.load(competition.id);
      // Trois lectures qui ne s'attendent pas : le déroulement du serveur, les
      // engagés avec leurs clubs, et l'arbre des réunions. Lancées ensemble,
      // l'écran paie la plus lente au lieu de leur somme. Chacune ravale son
      // AppException et garde son propre repli — `Future.wait` abandonnerait
      // les trois au premier échec, là où deux d'entre elles n'empêchent pas
      // l'écran de s'afficher.
      await Future.wait([
        _seedStructures(race, competition.id),
        _loadEntries(race, competition.id),
        _loadMeetingTree(competition.id, refresh: silent),
      ]);
      structures.value = _structuresOf(race);
      // Clamped rather than reset: reloading after a draw must leave the
      // operator on the round they were looking at, while opening a race with
      // fewer rounds must not leave the selection past the end.
      final tabCount = tabs.length;
      selectedTabIndex.value =
          tabCount == 0 ? 0 : selectedTabIndex.value.clamp(0, tabCount - 1);
      // The draw a first device pushed lives in the FFSS places: this is what
      // makes it visible on every other device.
      try {
        await _prefetchSeats(race);
        await _importCompositions(race);
        await _importResults(race);
        structures.value = _structuresOf(race);
      } on AppException {
        // The local composition stands.
      }
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  /// Le déroulement que FFSS détient, versé dans le programme local.
  ///
  /// The déroulement lives on FFSS: a device that never authored it must still
  /// see the épreuve's rounds. Offline, whatever is stored locally still
  /// renders.
  Future<void> _seedStructures(Race race, int competitionId) async {
    try {
      await _seedStructuresFromServer(race, competitionId);
    } on AppException {
      // Local copy only.
    }
  }

  /// Les engagés de l'épreuve, indexés avec leurs clubs résolus.
  ///
  /// Indisponibles (hors ligne, erreur API), la structure s'affiche quand
  /// même : les comptes par catégorie retombent à zéro et une course tirée ne
  /// liste aucun athlète.
  Future<void> _loadEntries(Race race, int competitionId) async {
    try {
      final entries = await _raceRepo.getEntries(race.id);
      final counts = <int, int>{};
      for (final e in entries) {
        counts[e.category.id] = (counts[e.category.id] ?? 0) + 1;
      }
      _entryCountByCategory = counts;
      _athletesById = await _indexAthletes(entries, competitionId);
      _entriesById = _indexEntries(entries);
    } on AppException {
      _entryCountByCategory = const {};
      _athletesById = const {};
      _entriesById = const {};
    }
  }

  /// L'arbre des réunions, pour le site et l'horaire des courses.
  ///
  /// Une première ouverture se contente de ce que le service détient déjà ; le
  /// tiré-pour-rafraîchir, lui, redemande. Un échec laisse en place l'arbre
  /// précédent plutôt que de vider la colonne : un horaire périmé se lit,
  /// une case vide ne dit rien.
  Future<void> _loadMeetingTree(
    int competitionId, {
    required bool refresh,
  }) async {
    // `load` et `ensureLoaded` avalent leur propre AppException et rendent un
    // booléen : rien à rattraper ici.
    if (refresh) {
      await _meetingTree.load(competitionId, silent: true);
    } else {
      await _meetingTree.ensureLoaded(competitionId, silent: true);
    }
  }

  /// What the operator typed in the filter bar, already folded for comparison.
  final RxString filter = ''.obs;

  /// Races the operator opened by hand. A filtered race is open regardless —
  /// surviving the filter is itself the reason to show its line-up.
  final RxSet<int> _expandedRaceIds = <int>{}.obs;

  void setFilter(String value) => filter.value = _fold(value);

  bool isExpanded(ProgrammeRace race) =>
      filter.value.isNotEmpty || _expandedRaceIds.contains(race.id);

  void toggleExpanded(ProgrammeRace race) {
    if (!_expandedRaceIds.remove(race.id)) _expandedRaceIds.add(race.id);
  }

  void expandAll(Iterable<ProgrammeRace> races) =>
      _expandedRaceIds.addAll(races.map((r) => r.id));

  void collapseAll() => _expandedRaceIds.clear();

  /// Whether every one of [races] is open, which is what turns the expand-all
  /// button into a collapse-all button.
  bool allExpanded(Iterable<ProgrammeRace> races) =>
      races.isNotEmpty && races.every(isExpanded);

  /// The races holding an athlete the filter matches. An empty filter matches
  /// everything, so the list comes back untouched.
  List<ProgrammeRace> matchingRaces(Iterable<ProgrammeRace> races) {
    if (filter.value.isEmpty) return races.toList();
    return [
      for (final race in races)
        if (entriesOf(race).any(matchesEntry)) race,
    ];
  }

  /// Whether this athlete is what the operator is looking for — surname, first
  /// name or club, in any case and with or without the accents.
  bool matchesFilter(Athlete athlete) {
    final needle = filter.value;
    if (needle.isEmpty) return true;
    final club = athlete.club?.name.isNotEmpty == true
        ? athlete.club!.name
        : athlete.clubLabel;
    return _fold('${athlete.lastName} ${athlete.firstName} $club')
        .contains(needle);
  }

  /// Lowercases and strips the accents a marshal will not type: searching for
  /// "noel" has to find NOËL, and "remy" has to find Rémy.
  static String _fold(String value) {
    const accented = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿœæ';
    const plain = 'aaaaaaceeeeiiiinooooouuuuyyoa';
    final buffer = StringBuffer();
    for (final rune in value.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      final at = accented.indexOf(char);
      buffer.write(at < 0 ? char : plain[at]);
    }
    return buffer.toString().trim();
  }

  /// Vrai si un athlète de cet engagement correspond au filtre — un
  /// engagement survit sur un seul de ses membres, pas sur tous.
  bool matchesEntry(Entry entry) => entry.athletes.any(matchesFilter);

  /// Les engagements d'une course tirée, dans l'ordre des couloirs.
  List<Entry> entriesOf(ProgrammeRace race) => competitorsOf(
        race,
        entries: _entriesById,
        athletes: _athletesById,
      );

  /// La place que cet engagement a prise dans une course scorée, ou nul tant
  /// qu'il n'a pas de résultat. Calculée à partir de l'ordre stocké par la
  /// même fonction que l'écran de saisie — les deux ne peuvent donc pas se
  /// contredire sur un classement.
  int? placeIn(ProgrammeRace race, Entry entry) => placeInRace(race, entry.id);

  /// Idem, par id de compétiteur (engagement).
  ///
  /// FFSS l'emporte quand il porte un résultat pour cette course : un
  /// classement corrigé sur un autre appareil doit s'afficher ici, pas la
  /// copie locale devenue fausse. Sans résultat serveur, l'ordre de
  /// l'appareil reste en vigueur.
  int? placeInRace(ProgrammeRace race, int competitorId) {
    final server = _serverResultsFor(race);
    if (server != null) return server[competitorId]?.rank;
    return placesOf(race.competitorOrder)[competitorId];
  }

  /// Ce que FFSS porte pour cette course, ou nul quand il ne peut pas répondre.
  ///
  /// Un tirage sans `entryIds` a des athlètes pour compétiteurs, alors que le
  /// serveur indexe par engagement : les deux suites d'ids n'ont rien à voir,
  /// et une carte non nulle masquerait l'ordre local — la seule source qui
  /// puisse classer cette course-là.
  Map<int, HeatResult>? _serverResultsFor(ProgrammeRace race) =>
      race.entryIds.isEmpty ? null : _serverResults[race.id];

  /// La disqualification ou le forfait que porte cet engagement dans une
  /// course scorée, s'il y en a un.
  CoursePenalty? penaltyIn(ProgrammeRace race, Entry entry) =>
      penaltyInRace(race, entry.id);

  /// Idem, par id de compétiteur (engagement) — FFSS d'abord, pour la même
  /// raison que [placeInRace].
  ///
  /// Le serveur donne un statut, pas pourquoi : un code voyage dans
  /// `complement` et atterrit dans [CoursePenalty.code], exactement ce que
  /// l'arbitre a tapé sur l'appareil qui a validé.
  CoursePenalty? penaltyInRace(ProgrammeRace race, int competitorId) {
    final server = _serverResultsFor(race);
    if (server != null) {
      final result = server[competitorId];
      if (result == null) return null;
      final kind = switch (result.status) {
        1 => CoursePenaltyKind.disqualified,
        2 => CoursePenaltyKind.forfeit,
        // Statut muet : la disqualification reste lisible sur son booléen, et
        // tout le reste est un classé ordinaire.
        _ => result.isDisqualified ? CoursePenaltyKind.disqualified : null,
      };
      if (kind == null) return null;
      return CoursePenalty(
        competitorId: competitorId,
        kind: kind,
        code: result.complement ?? '',
      );
    }
    for (final penalty in race.penalties) {
      if (penalty.competitorId == competitorId) return penalty;
    }
    return null;
  }

  final RxSet<int> expandedEntries = <int>{}.obs;

  bool isEntryExpanded(Entry entry) => expandedEntries.contains(entry.id);

  void toggleEntry(Entry entry) {
    if (!expandedEntries.remove(entry.id)) expandedEntries.add(entry.id);
  }

  /// L'id de la série FFSS que porte cette course, 0 quand elle n'en a pas.
  /// Passé à l'écran de saisie pour qu'il relise le classement déjà publié
  /// sans refaire l'arbre des réunions.
  int heatIdOf(ProgrammeRace race) => _courseHeatIds[race.id] ?? 0;

  /// Indexes the engaged athletes and resolves their clubs. Best-effort on the
  /// clubs: without them the rows still read, only the logos fall back to the
  /// club initial.
  Future<Map<int, Athlete>> _indexAthletes(
    List<Entry> entries,
    int competitionId,
  ) async {
    final athletes = [for (final entry in entries) ...entry.athletes];
    if (athletes.isEmpty) return const {};
    Map<int, Club> clubs;
    try {
      clubs = await _clubRepo.getAthleteClubs(competitionId, athletes);
    } on AppException {
      clubs = const {};
    }
    return {
      for (final athlete in athletes)
        athlete.id: athlete.copyWith(club: clubs[athlete.id] ?? athlete.club),
    };
  }

  /// Les engagements de l'épreuve, athlètes patchés avec le club que
  /// `_athletesById` a déjà résolu — aucun aller-retour de plus, seulement une
  /// réutilisation de ce que `_indexAthletes` vient de lire. Doit être appelé
  /// après `_athletesById` pour le même chargement.
  Map<int, Entry> _indexEntries(List<Entry> entries) => {
        for (final e in entries)
          e.id: e.copyWith(
            athletes: [
              for (final a in e.athletes) _athletesById[a.id] ?? a,
            ],
          ),
      };

  /// The stored structures this race owns, by category label.
  ///
  /// Scoped to the categories the race declares: a device that ran the version
  /// which seeded a whole déroulement carries structures for categories this
  /// épreuve never runs, and they would show as extra pills. Filtering here
  /// repairs those without asking anyone to clear their storage. A race that
  /// declares no category cannot filter — nothing is hidden then.
  List<EventStructure> _structuresOf(Race race) {
    final all =
        _programme.current.value?.structures ?? const <EventStructure>[];
    final runs = {for (final c in race.categories) c.id};
    return all
        .where((s) =>
            s.raceId == race.id &&
            (runs.isEmpty || runs.contains(s.categoryId)))
        .toList()
      ..sort((a, b) => a.categoryLabel.compareTo(b.categoryLabel));
  }

  /// Materialises the server déroulements of this race into the local
  /// programme: a structure that does not exist locally is created, one whose
  /// rounds were emptied is reseeded — the same rule the Structure overview
  /// applies. A structure that holds rounds is authored work and stays.
  Future<void> _seedStructuresFromServer(Race race, int competitionId) async {
    final formats = await _raceFormatRepo.getRaceFormats(competitionId);
    final mine = [
      for (final format in formats)
        if (format.disciplineId == race.disciplineId &&
            parseGender(format.gender) == race.gender &&
            format.details.isNotEmpty)
          format,
    ];
    if (mine.isEmpty) return;

    // A déroulement covers (discipline, gender) and lists ITS categories,
    // which is wider than one épreuve: FFSS splits « 90m Sprint Cadet » and
    // « 90m Sprint Junior » into two races sharing both. Seeding the
    // déroulement's categories as-is hung the Junior rounds off the Cadet
    // race. Only what this race actually runs is seeded.
    final runs = {for (final c in race.categories) c.id};
    final programme = _programme.current.value ??
        CompetitionProgramme(competitionId: competitionId);
    final updated = [...programme.structures];
    var changed = false;
    for (final format in mine) {
      for (final category in format.categories) {
        // Même règle que `_structuresOf` : une épreuve qui ne déclare aucune
        // catégorie ne peut rien filtrer, et on ne la prive pas de ses tours.
        if (runs.isNotEmpty && !runs.contains(category.id)) continue;
        final at = updated.indexWhere(
            (s) => s.raceId == race.id && s.categoryId == category.id);
        if (at >= 0 && updated[at].levels.isNotEmpty) {
          // Authored rounds are never replaced — but their link to FFSS is
          // repaired. `serverId` is the only join to the créneau, its courses
          // and their places; a déroulement recreated on the federal side
          // leaves every stored id dangling, and nothing downstream matches.
          // The failure is silent, which is what made a second device show an
          // empty Séries screen with no error at all.
          final realigned = realignServerIds(
            levels: updated[at].levels,
            details: format.details,
          );
          if (realigned != null) {
            updated[at] = updated[at].copyWith(levels: realigned);
            changed = true;
          }
          continue;
        }
        final levels = buildLevelsFromDetails(
          details: format.details,
          allocateId: _programme.allocateId,
        );
        if (at >= 0) {
          updated[at] = updated[at].copyWith(levels: levels);
        } else {
          updated.add(EventStructure(
            raceId: race.id,
            categoryId: category.id,
            raceLabel: race.name,
            categoryLabel: category.name,
            spotsPerRace: race.defaultSpotsPerRace,
            levels: levels,
          ));
        }
        changed = true;
      }
    }
    if (!changed) return;
    await _programme.save(
      (_programme.current.value ?? programme).copyWith(structures: updated),
    );
  }

  /// Reads back what FFSS holds for the courses that have been validated, so
  /// this screen shows the ranking the federation records rather than the copy
  /// the device happens to keep.
  ///
  /// A course with no `serie` has never been validated: nothing is read, and
  /// the local order stays in charge. Best-effort per course — one unreadable
  /// heat costs its own ranking, not the screen.
  Future<void> _importResults(Race race) async {
    _serverResults.clear();
    final programme = _programme.current.value;
    if (programme == null) return;

    // Une seule lecture groupee pour toute l'epreuve, avant la boucle : lire
    // serie par serie faisait payer une latence a chaque course validee.
    final resultsByHeat = await _meetings.getHeatResultsByHeat({
      for (final structure in programme.structures)
        if (structure.raceId == race.id)
          for (final level in structure.levels)
            for (final course in coursesOfLevel(level))
              if ((course.heat?.id ?? 0) != 0) course.heat!.id,
    });

    for (final structure in programme.structures) {
      if (structure.raceId != race.id) continue;
      for (final level in structure.levels) {
        final courses = coursesOfLevel(level);
        if (courses.isEmpty) continue;
        for (final stored in level.races) {
          final course = _courseOf(courses, stored);
          final heatId = course?.heat?.id ?? 0;
          if (course == null || heatId == 0) continue;
          _courseHeatIds[stored.id] = heatId;
          // Le best-effort par serie est tenu par la lecture groupee : une
          // serie illisible revient vide, elle ne coute que son classement.
          final results = resultsByHeat[heatId] ?? const <HeatResult>[];
          if (results.isEmpty) continue;
          _serverResults[stored.id] = {for (final r in results) r.entryId: r};
        }
      }
    }
  }

  /// Remplit le memo pour toutes les courses de l'epreuve, en une lecture
  /// groupee.
  ///
  /// Sans lui, les deux passes d'import lisaient course par course, en file :
  /// un tour de huit courses payait huit latences bout a bout la ou il en paie
  /// une. Ce qui n'est pas prechargé — rien, en pratique — retombe sur la
  /// lecture unitaire de [_seatsOf].
  Future<void> _prefetchSeats(Race race) async {
    final programme = _programme.current.value;
    if (programme == null) return;
    final courses = <int, Run>{};
    for (final structure in programme.structures) {
      if (structure.raceId != race.id) continue;
      for (final level in structure.levels) {
        for (final course in coursesOfLevel(level)) {
          if (course.lanes.isNotEmpty) courses[course.id] = course;
        }
      }
    }
    if (courses.isEmpty) return;
    _seatsByCourse.addAll(await _meetings.getLaneSeatsByCourse(courses.values));
  }

  /// Les places d'une course, lues une seule fois par `load()`.
  Future<List<LaneSeat>> _seatsOf(Run course) async {
    final known = _seatsByCourse[course.id];
    if (known != null) return known;
    final seats =
        await _meetings.getLaneSeats([for (final l in course.lanes) l.id]);
    _seatsByCourse[course.id] = seats;
    return seats;
  }

  Run? _courseOf(List<Run> courses, ProgrammeRace stored) {
    for (final course in courses) {
      if (course.id == stored.runId) return course;
    }
    return null;
  }

  /// Adopts, into the local races, the compositions the FFSS places carry —
  /// what another device pushed when it saved its draw.
  ///
  /// The server is the shared truth, with one guard: a race holding recorded
  /// results is never overwritten, whatever the server says — losing a finish
  /// order to a sync would be worse than any stale seating. Empty seats adopt
  /// nothing either: a freshly placed round says nothing about the draw.
  Future<void> _importCompositions(Race race) async {
    final programme = _programme.current.value;
    if (programme == null) return;

    var changed = false;
    final updated = <EventStructure>[];
    for (final structure in programme.structures) {
      if (structure.raceId != race.id) {
        updated.add(structure);
        continue;
      }
      final levels = <RoundLevel>[];
      for (final level in structure.levels) {
        final imported = await _importLevel(level);
        if (!identical(imported, level)) changed = true;
        levels.add(imported);
      }
      updated.add(structure.copyWith(levels: levels));
    }
    if (!changed) return;
    await _programme.save(
      _programme.current.value!.copyWith(structures: updated),
    );
  }

  Future<RoundLevel> _importLevel(RoundLevel level) async {
    final courses = coursesOfLevel(level);
    // A round with no local heat is NOT an early exit: its courses may all
    // have been created on the federal site, and they are exactly the ones
    // this import has to bring in.
    if (courses.isEmpty) return level;

    // A course claims the race that recorded it; the leftovers pair by rank —
    // the order both sides were created in.
    final races = [...level.races];
    final claimed = <int>{};
    final pairs = <(int, Run)>[];
    final unmatchedCourses = <Run>[];
    final orphanCourses = <Run>[];
    for (final course in courses) {
      final at = races.indexWhere((r) => r.runId == course.id);
      at >= 0
          ? _claim(pairs, claimed, at, course)
          : unmatchedCourses.add(course);
    }
    var cursor = 0;
    for (final course in unmatchedCourses) {
      while (cursor < races.length &&
          (claimed.contains(cursor) || races[cursor].runId != 0)) {
        cursor++;
      }
      if (cursor >= races.length) {
        // More courses than heats: the surplus was created on the federal
        // site. Collected rather than dropped — [_adoptOrphanCourses] gives
        // each one a heat of its own.
        orphanCourses.add(course);
        continue;
      }
      _claim(pairs, claimed, cursor, course);
    }

    var changed = false;
    for (final (at, course) in pairs) {
      final race = races[at];
      if (race.competitorOrder.isNotEmpty || race.penalties.isNotEmpty) {
        continue;
      }
      if (course.lanes.isEmpty) continue;
      final seats = await _seatsOf(course);
      if (seats.isEmpty) continue;
      final entryIds = [for (final seat in seats) seat.entryId];
      final athleteIds = [
        for (final seat in seats) ...seat.athleteIds,
      ];
      if (race.runId == course.id &&
          _sameIds(race.entryIds, entryIds) &&
          _sameIds(race.athleteIds, athleteIds)) {
        continue;
      }
      races[at] = race.copyWith(
        runId: course.id,
        entryIds: entryIds,
        athleteIds: athleteIds,
      );
      changed = true;
    }
    if (await _adoptOrphanCourses(races, orphanCourses)) changed = true;
    return changed ? level.copyWith(races: races) : level;
  }

  /// Appends a heat for every course of [orphans] that holds a composition,
  /// so a course created on the federal site arrives with its places rather
  /// than as a row nothing fills.
  ///
  /// A course whose places are all free adopts nothing: it has no draw to
  /// show, and minting a heat for it would add an empty line to the round for
  /// every course merely on the timetable.
  ///
  /// Returns whether [races] gained anything.
  Future<bool> _adoptOrphanCourses(
      List<ProgrammeRace> races, List<Run> orphans) async {
    var added = false;
    for (final course in orphans) {
      if (course.lanes.isEmpty) continue;
      final seats = await _seatsOf(course);
      if (seats.isEmpty) continue;
      races.add(ProgrammeRace(
        // Allocating bumps `nextLocalId` on the live programme; the caller
        // saves from a re-read, so the bump is not lost.
        id: _programme.allocateId(),
        number: races.length + 1,
        runId: course.id,
        entryIds: [for (final seat in seats) seat.entryId],
        athleteIds: [for (final seat in seats) ...seat.athleteIds],
      ));
      added = true;
    }
    return added;
  }

  static void _claim(
    List<(int, Run)> pairs,
    Set<int> claimed,
    int at,
    Run course,
  ) {
    pairs.add((at, course));
    claimed.add(at);
  }

  static bool _sameIds(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// The créneaux FFSS holds for this round — those hung off its `partie`.
  /// Normally one; nothing on the federal side forbids several.
  List<Slot> slotsForLevel(RoundLevel level) {
    if (level.serverId <= 0) return const [];
    return [
      for (final meeting in _meetingsOfCompetition)
        for (final slot in meeting.slots)
          if (slot.raceFormatDetail?.id == level.serverId) slot,
    ];
  }

  /// The round's courses, in running order across its créneaux.
  List<Run> coursesOfLevel(RoundLevel level) => [
        for (final slot in slotsForLevel(level)) ...slot.runs,
      ]..sort((a, b) => a.beginTime.compareTo(b.beginTime));

  /// Where and when one drawn heat actually starts, or null while the round
  /// has no course to run it in.
  ///
  /// Prefers the course the heat recorded when it was created. Falls back to
  /// the course of the same rank — which is what a course created by hand on
  /// the federal site leaves us with — and says so, because rank is a
  /// reasonable guess and not a fact.
  RaceSchedule? scheduleFor(RoundLevel level, ProgrammeRace race) {
    final courses = coursesOfLevel(level);
    if (courses.isEmpty) return null;
    if (race.runId != 0) {
      for (final course in courses) {
        if (course.id == race.runId) {
          return RaceSchedule(run: course, isGuess: false);
        }
      }
    }
    final rank = level.races.indexWhere((r) => r.id == race.id);
    if (rank < 0 || rank >= courses.length) return null;
    return RaceSchedule(run: courses[rank], isGuess: true);
  }

  /// The distinct sites this round runs on, in course order. Empty while it
  /// has no course, or while its courses carry no site.
  List<String> sitesOfLevel(RoundLevel level) {
    final seen = <String>[];
    for (final course in coursesOfLevel(level)) {
      if (course.site.isNotEmpty && !seen.contains(course.site)) {
        seen.add(course.site);
      }
    }
    return seen;
  }

  bool get hasStructure => structures.any((s) => s.levels.isNotEmpty);

  int entryCountFor(int categoryId) => _entryCountByCategory[categoryId] ?? 0;

  bool get showCategoryHeaders => structures.length > 1;

  /// The menu bar: one entry per category × round actually defined, categories
  /// in the order [structures] holds them, rounds in the structure's own order.
  List<RoundTab> get tabs => [
        for (final s in structures)
          for (var i = 0; i < s.levels.length; i++)
            RoundTab(structure: s, level: s.levels[i], levelIndex: i),
      ];

  final RxInt selectedTabIndex = 0.obs;

  RoundTab? get selectedTab {
    final all = tabs;
    if (all.isEmpty) return null;
    return all[selectedTabIndex.value.clamp(0, all.length - 1)];
  }

  void selectTab(int index) {
    if (index < 0 || index >= tabs.length) return;
    selectedTabIndex.value = index;
  }
}

/// Where and when a drawn heat runs.
class RaceSchedule {
  const RaceSchedule({required this.run, required this.isGuess});

  final Run run;

  /// True when the heat recorded no course of its own — or recorded one that
  /// no longer exists — and this course was matched by rank instead. Right in
  /// the ordinary case, but the view says so rather than passing it off as
  /// established.
  final bool isGuess;
}
