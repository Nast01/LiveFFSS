import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/mappers/athlete_mapper.dart' show genderCode;
import 'package:live_ffss/app/data/repositories/race_format_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
// Prefixed: the controller exposes `moveLevel`/`canMoveLevel` of its own, which
// delegate to the same-named pure functions here.
import 'package:live_ffss/app/domain/models/round_order.dart' as round_order;
import 'package:live_ffss/app/domain/models/structure_generator.dart';
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

/// What became of a round the operator asked to remove.
///
/// The distinction is the view's business: a round FFSS refused to drop can be
/// dropped from the device anyway — a partie the server no longer holds would
/// otherwise sit in the editor for good — whereas a round left because nobody
/// is signed in is alive on FFSS, and hiding it would orphan it.
enum LevelRemoval { removed, serverRefused, needsLogin }

class StructureEditorArgs {
  const StructureEditorArgs({
    required this.competitionId,
    required this.raceId,
    required this.categoryId,
    required this.raceLabel,
    required this.categoryLabel,
    required this.entryCount,
    required this.eligibleCount,
    this.disciplineId = 0,
    this.raceFormatId = 0,
    this.gender = Gender.unknown,
    this.defaultSpotsPerRace = defaultPoolSpotsPerRace,
    this.serverDetails = const [],
  });

  final int competitionId;
  final int raceId;
  final int categoryId;
  final String raceLabel;
  final String categoryLabel;
  final int entryCount;

  /// Entries that will actually start — forfeits excluded. This is the figure
  /// a round is sized on; [entryCount] is the roster, not the field.
  final int eligibleCount;

  /// With [gender] and the category, identifies the déroulement — that is what
  /// `deroulement/submit` takes when one has to be created here.
  final int disciplineId;

  /// The FFSS déroulement holding this épreuve × category, 0 when none exists
  /// yet. A round can only be pushed once there is one to hang it on.
  final int raceFormatId;

  /// Carried for the heading only: [EventStructure] has no gender of its own,
  /// yet the editor must be titled exactly like the row it was opened from.
  final Gender gender;

  /// Heat size for a structure that does not exist yet — 16 coastal, 8 pool.
  /// Only seeds a new structure; a stored one keeps whatever was authored.
  final int defaultSpotsPerRace;

  /// Rounds FFSS already holds for this épreuve × category. When present they
  /// seed a brand-new structure, which beats guessing from the entry count.
  final List<RaceFormatDetail> serverDetails;
}

class StructureEditorController extends GetxController {
  StructureEditorController(this._programme, this._raceFormatRepo, this._user);

  final ProgrammeService _programme;
  final RaceFormatRepository _raceFormatRepo;
  final UserService _user;

  /// Whether anything can be written to FFSS. Everything this editor reads is
  /// public, so a signed-out operator gets all the way here; without the check
  /// the server answers an anonymous write with a bare "Invalid Token", which
  /// reads as a server fault rather than a missing session.
  bool get canWriteToFfss => _user.currentUser.value != null;

  final Rxn<EventStructure> structure = Rxn<EventStructure>();

  /// True while a round is being deleted on the FFSS server.
  final RxBool isDeletingLevel = false.obs;

  /// True while rounds are being pushed to FFSS, with the progress of the run.
  /// One request per round, so a bare spinner would not say whether a long
  /// push is advancing or stuck. Both fall back to zero when it ends.
  final RxBool isPushing = false.obs;
  final RxInt pushDone = 0.obs;
  final RxInt pushTotal = 0.obs;

  final Rxn<UiMessage> message = Rxn<UiMessage>();
  late StructureEditorArgs _args;

  /// Assigned when a déroulement is created from here, so the rounds that
  /// follow hang off it rather than off nothing.
  int _raceFormatId = 0;

  Gender get gender => _args.gender;
  int get entryCount => _args.entryCount;
  int get eligibleCount => _args.eligibleCount;

  /// Whether FFSS already holds the déroulement these rounds belong to. When
  /// it does not, a round added here stays local until the next push creates
  /// the déroulement and sends it.
  bool get hasRaceFormat => _raceFormatId > 0;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is StructureEditorArgs) start(arg);
  }

  @override
  void onReady() {
    super.onReady();
    seedFromServerIfNeeded();
  }

  /// Loads the stored structure for this épreuve × category, or an empty one
  /// carrying the labels and the speciality's default race size.
  ///
  /// Reads only. Seeding from the server deliberately does NOT happen here:
  /// allocating ids and persisting both write to the shared [ProgrammeService],
  /// which the structure overview observes — doing that while this route builds
  /// would mark a mounted widget dirty mid-build. See [seedFromServerIfNeeded].
  void start(StructureEditorArgs args) {
    _args = args;
    _raceFormatId = args.raceFormatId;
    structure.value = _stored() ??
        EventStructure(
          raceId: args.raceId,
          categoryId: args.categoryId,
          raceLabel: args.raceLabel,
          categoryLabel: args.categoryLabel,
          spotsPerRace: args.defaultSpotsPerRace,
        );
  }

  /// Adopts the rounds FFSS declares whenever this structure holds none —
  /// whether it is brand new or had all of its rounds removed. Called from
  /// [onReady], i.e. after the first frame.
  ///
  /// The guard is "no rounds", not "never stored": a structure emptied by the
  /// operator used to stay empty for good, with no way to pull the server ones
  /// back. Authored rounds are still never overwritten — that is what makes the
  /// local copy authoritative. The result is persisted at once so the ids just
  /// allocated are not handed out twice.
  /// Whether FFSS declares any round for this épreuve × category — drives
  /// whether re-importing is offered at all.
  bool get hasServerRounds => _args.serverDetails.isNotEmpty;

  /// Replaces the local rounds with the ones FFSS declares, discarding whatever
  /// was authored — including any heats drawn into the replaced races.
  ///
  /// This is the deliberate opposite of [seedFromServerIfNeeded], which never
  /// touches existing rounds. Purely local: nothing is sent to the server, we
  /// only adopt what it already holds. The view confirms before calling it.
  void reimportFromServer() {
    if (!hasServerRounds || structure.value == null) return;
    _commit(structure.value!.copyWith(
      levels: buildLevelsFromDetails(
        details: _args.serverDetails,
        allocateId: _programme.allocateId,
      ),
    ));
    message.trigger(const UiMessageSuccess('round_reimport_done'));
  }

  void seedFromServerIfNeeded() {
    final current = structure.value;
    if (current == null ||
        current.levels.isNotEmpty ||
        _args.serverDetails.isEmpty) {
      return;
    }
    _commit(current.copyWith(
      levels: buildLevelsFromDetails(
        details: _args.serverDetails,
        allocateId: _programme.allocateId,
      ),
    ));
  }

  void proposeDefault() {
    final s = structure.value!;
    final levels = buildDefaultLevels(
      // The starters, not the roster: heats sized on entries that will not
      // swim leave an empty heat behind.
      entryCount: _args.eligibleCount,
      spotsPerRace: s.spotsPerRace,
      allocateId: _programme.allocateId,
    );
    _commit(s.copyWith(levels: levels));
  }

  /// Sets the race size of one round. Changing it does NOT recompute the
  /// levels — `proposeDefault` is the explicit way to do that.
  void setLevelSpotsPerRace(int levelIndex, int spots) {
    if (spots < 1) return;
    final levels = [...structure.value!.levels];
    levels[levelIndex] = levels[levelIndex].copyWith(spotsPerRace: spots);
    _commit(structure.value!.copyWith(levels: levels));
  }

  /// Adds a round **at its rank** in the hierarchy (série < quart < demi <
  /// finale) rather than at the end, so picking the rounds in any order can no
  /// longer produce a structure that runs a finale before its séries.
  ///
  /// The round arrives with the race count and qualifiers its level usually
  /// runs (see [defaultsForRound]) rather than empty, so the common bracket
  /// needs no stepper work at all.
  /// The round is created on FFSS straight away when a déroulement exists to
  /// hang it on, so the federal site never lags behind what is on screen.
  /// Without one it stays local and goes out with the next [pushAll], which
  /// creates the déroulement first. A refused or failed creation keeps the
  /// round rather than discarding the operator's edit — it simply carries no
  /// server id, and the next push will try again.
  Future<void> addLevel(RoundType type) async {
    final s = structure.value!;
    final at = round_order.insertionIndexFor(s.levels, type);
    final defaults = defaultsForRound(type);
    final levels = [...s.levels]..insert(
        at,
        RoundLevel(
          type: type,
          // A new round inherits the structure's default size rather than 0,
          // so it shows a real number straight away.
          spotsPerRace: s.spotsPerRace,
          qualifiersPerRace: defaults.qualifiersPerRace,
          races: [
            for (var n = 1; n <= defaults.raceCount; n++)
              ProgrammeRace(id: _programme.allocateId(), number: n),
          ],
        ),
      );
    final rewired = round_order.rewireRange(levels, at, at + 1);
    _commit(s.copyWith(levels: rewired));

    if (!hasRaceFormat) return;
    if (!canWriteToFfss) {
      message.trigger(const UiMessageError('login_required'));
      return;
    }
    int serverId;
    try {
      serverId = await _submitLevel(rewired[at], at);
    } on AppException catch (e) {
      message.trigger(UiMessageError('round_push_failed', details: e.detail));
      return;
    }
    if (serverId <= 0) {
      message.trigger(const UiMessageError('round_push_failed'));
      return;
    }
    final withId = [...structure.value!.levels];
    withId[at] = withId[at].copyWith(serverId: serverId);
    _commit(structure.value!.copyWith(levels: withId));
  }

  /// Sets the FFSS qualification logic of one round. Local until the next push.
  void setQualificationMethod(int levelIndex, String code) {
    final levels = [...structure.value!.levels];
    levels[levelIndex] = levels[levelIndex].copyWith(qualificationMethod: code);
    _commit(structure.value!.copyWith(levels: levels));
  }

  /// Pushes every round on screen to FFSS: a creation for those with no server
  /// id, an update for the rest.
  ///
  /// Nothing is compared against a previous state — the whole set is sent every
  /// time. Tracking which round is dirty would mean storing a snapshot of the
  /// last push on each one, a lot of machinery to save a few idempotent calls.
  ///
  /// When no déroulement exists yet it is created first, and a refusal there
  /// stops the run: rounds have nothing to hang on, so sending them would fail
  /// one by one for the same reason.
  Future<void> pushAll() async {
    final s = structure.value;
    if (s == null || s.levels.isEmpty || isPushing.value) return;
    if (!canWriteToFfss) {
      message.trigger(const UiMessageError('login_required'));
      return;
    }

    isPushing.value = true;
    pushDone.value = 0;
    pushTotal.value = s.levels.length;
    try {
      if (!hasRaceFormat && !await _createRaceFormat()) return;

      final updated = [...s.levels];
      var sent = 0;
      for (var i = 0; i < updated.length; i++) {
        final serverId = await _submitLevel(updated[i], i);
        if (serverId > 0) {
          updated[i] = updated[i].copyWith(serverId: serverId);
          sent++;
        }
        pushDone.value++;
      }
      _commit(structure.value!.copyWith(levels: updated));
      message.trigger(sent == updated.length
          ? const UiMessageSuccess('round_push_done')
          : UiMessageError('round_push_failed',
              details: '$sent/${updated.length}'));
    } on AppException catch (e) {
      message.trigger(UiMessageError('round_push_failed', details: e.detail));
    } finally {
      isPushing.value = false;
      pushDone.value = 0;
      pushTotal.value = 0;
    }
  }

  /// Creates the déroulement these rounds belong to. Reports whether the id it
  /// came back with is usable.
  Future<bool> _createRaceFormat() async {
    final id = await _raceFormatRepo.submitRaceFormat(
      competitionId: _args.competitionId,
      disciplineId: _args.disciplineId,
      gender: genderCode(_args.gender),
      categoryIds: [_args.categoryId],
    );
    if (id <= 0) {
      message.trigger(const UiMessageError('race_format_create_failed'));
      return false;
    }
    _raceFormatId = id;
    return true;
  }

  /// Sends one round as a `partie`. Returns the id FFSS assigned, or 0 when it
  /// refused — including for a round whose type has no code to send.
  ///
  /// Reporting is left to the callers: an [AppException] propagates so a push
  /// stops at the first transport failure instead of grinding through the rest
  /// of the rounds to fail identically.
  Future<int> _submitLevel(RoundLevel level, int index) {
    final code = roundTypeCode(level.type);
    if (code.isEmpty) return Future.value(0);
    return _raceFormatRepo.submitRaceFormatDetail(
      raceFormatId: _raceFormatId,
      id: level.serverId > 0 ? level.serverId : null,
      order: index + 1,
      level: code,
      raceCount: level.races.length,
      qualificationMethod: level.qualificationMethod,
      spotsPerRace: level.spotsPerRace > 0
          ? level.spotsPerRace
          : structure.value!.spotsPerRace,
      qualifyingSpots: level.qualifiersPerRace,
      categoryIds: [_args.categoryId],
    );
  }

  /// Whether the round at [index] can move by [delta] (-1 up, +1 down) without
  /// breaking the hierarchy. Drives the enabled state of the arrows.
  bool canMoveLevel(int index, int delta) {
    final s = structure.value;
    if (s == null) return false;
    return round_order.canMoveLevel(s.levels, index, delta);
  }

  /// Moves the round at [index] by [delta]. A move the hierarchy forbids is a
  /// no-op — the view greys the arrow out, this is the guard behind it.
  void moveLevel(int index, int delta) {
    final s = structure.value;
    if (s == null || !round_order.canMoveLevel(s.levels, index, delta)) return;
    _commit(s.copyWith(levels: round_order.moveLevel(s.levels, index, delta)));
  }

  /// Removes a round. When it came from FFSS (it carries a `serverId`), the
  /// server copy is deleted first and the round is kept on failure — leaving a
  /// round the operator believes gone still defined on a shared server would be
  /// worse than refusing the action. A hand-added round has nothing to call.
  Future<LevelRemoval> removeLevel(int levelIndex) async {
    final level = structure.value!.levels[levelIndex];
    if (level.serverId > 0) {
      // A round FFSS holds cannot be dropped anonymously, and removing it
      // locally alone would leave it defined on a server everyone shares.
      if (!canWriteToFfss) {
        message.trigger(const UiMessageError('login_required'));
        return LevelRemoval.needsLogin;
      }
      isDeletingLevel.value = true;
      bool deleted;
      // Kept rather than swallowed: "could not delete" says nothing an operator
      // can act on, while the server's own words tell a partie already gone
      // from a competition the account may not touch.
      String? reason;
      // FFSS answers 404 for a partie it no longer holds and 403 for a bad
      // token, never one for the other — so a 404 means the round is
      // definitively gone there, and dropping it here needs no question.
      var goneFromServer = false;
      try {
        deleted = await _raceFormatRepo.deleteRaceFormatDetail(level.serverId);
      } on AppException catch (e) {
        deleted = false;
        reason = e.detail;
        goneFromServer = e is ApiException && e.statusCode == 404;
      } finally {
        isDeletingLevel.value = false;
      }
      if (goneFromServer) {
        message.trigger(const UiMessageSuccess('round_delete_already_gone'));
        removeLevelLocally(levelIndex);
        return LevelRemoval.removed;
      }
      if (!deleted) {
        message.trigger(UiMessageError('round_delete_failed', details: reason));
        return LevelRemoval.serverRefused;
      }
    }
    removeLevelLocally(levelIndex);
    return LevelRemoval.removed;
  }

  /// Drops a round from the device without touching FFSS.
  ///
  /// The way out of a round whose partie the server refuses to delete — most
  /// often because it is already gone from FFSS. The view asks before calling
  /// this, since on a mere transport failure the partie is still alive there.
  void removeLevelLocally(int levelIndex) {
    final levels = [...structure.value!.levels]..removeAt(levelIndex);
    _commit(structure.value!.copyWith(levels: levels));
  }

  void setRaceCount(int levelIndex, int count) {
    if (count < 0) return;
    final levels = [...structure.value!.levels];
    final level = levels[levelIndex];
    final races = [...level.races];
    while (races.length < count) {
      races.add(ProgrammeRace(
        id: _programme.allocateId(),
        number: races.length + 1,
      ));
    }
    if (races.length > count) races.removeRange(count, races.length);
    levels[levelIndex] = level.copyWith(races: races);
    _commit(structure.value!.copyWith(levels: levels));
  }

  void setQualifiers(int levelIndex, int qualifiers) {
    if (qualifiers < 0) return;
    final levels = [...structure.value!.levels];
    levels[levelIndex] =
        levels[levelIndex].copyWith(qualifiersPerRace: qualifiers);
    _commit(structure.value!.copyWith(levels: levels));
  }

  void setWiring(int levelIndex, int raceId, List<int> sourceRaceIds) {
    final levels = [...structure.value!.levels];
    final races = levels[levelIndex]
        .races
        .map((r) =>
            r.id == raceId ? r.copyWith(sourceRaceIds: sourceRaceIds) : r)
        .toList();
    levels[levelIndex] = levels[levelIndex].copyWith(races: races);
    _commit(structure.value!.copyWith(levels: levels));
  }

  EventStructure? _stored() {
    final structures = _programme.current.value?.structures ?? const [];
    for (final s in structures) {
      if (s.raceId == _args.raceId && s.categoryId == _args.categoryId) {
        return s;
      }
    }
    return null;
  }

  /// Sets the reactive structure and persists it into the programme, replacing
  /// any prior structure for this épreuve × category.
  void _commit(EventStructure updated) {
    structure.value = updated;
    final p = _programme.current.value ??
        CompetitionProgramme(competitionId: _args.competitionId);
    final others = p.structures
        .where((s) =>
            !(s.raceId == updated.raceId && s.categoryId == updated.categoryId))
        .toList();
    _programme.save(p.copyWith(structures: [...others, updated]));
  }
}
