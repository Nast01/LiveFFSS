import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/meeting_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/meeting_timetable.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/slot.dart';
import 'package:live_ffss/app/presentation/modules/programme/day_sections.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

/// Durée d'un item nouvellement ajouté.
const int defaultItemMinutes = 10;

/// Un tour dont FFSS porte une `partie` et qu'aucun créneau ne pointe encore —
/// une ligne de la palette.
///
/// L'unité est le tour, pas la course : un créneau pointe une partie, donc
/// c'est un tour entier qui se pose d'un coup.
class UnscheduledRound {
  const UnscheduledRound({
    required this.partieId,
    required this.raceId,
    required this.categoryId,
    required this.raceLabel,
    required this.categoryLabel,
    required this.type,
    required this.courseCount,
    required this.spotsPerRace,
  });

  /// La `partie` FFSS que ce tour est devenu quand le déroulement a été poussé.
  final int partieId;
  final int raceId;
  final int categoryId;
  final String raceLabel;
  final String categoryLabel;
  final RoundType type;
  final int courseCount;
  final int spotsPerRace;
}

/// Les items d'une réunion : ajout, durées, ordre, suppression.
///
/// Chaque geste part immédiatement sur FFSS : la fin de la réunion dépend de
/// chaque durée et doit rester juste à tout instant.
class MeetingEditorController extends GetxController {
  MeetingEditorController(
    this._meetings,
    this._repo,
    this._programme,
    this._user,
  );

  final MeetingService _meetings;
  final MeetingRepository _repo;
  final ProgrammeService _programme;
  final UserService _user;

  final RxInt meetingId = 0.obs;
  final RxBool isBusy = false.obs;
  final Rxn<UiMessage> message = Rxn<UiMessage>();

  @override
  void onInit() {
    super.onInit();
    applyArguments(Get.arguments);
  }

  void applyArguments(Object? arg) {
    if (arg is Map && arg['meetingId'] is int) {
      meetingId.value = arg['meetingId'] as int;
    }
  }

  Meeting? get meeting => _meetings.byId(meetingId.value);

  List<MeetingItem> get items => meetingItems(meeting);

  /// Le site de la réunion, dont héritent toutes ses courses.
  String get site => meeting?.site ?? '';

  /// Tout ce que cet écran lit est public, donc un opérateur déconnecté entre
  /// sans friction — seule une écriture revient refusée.
  bool get canWriteToFfss => _user.currentUser.value != null;

  /// Les tours restant à placer : ceux dont FFSS porte une `partie`, moins
  /// ceux qu'un créneau pointe déjà — **toutes réunions confondues**, sinon le
  /// même tour serait proposé deux fois.
  ///
  /// Un tour sans `serverId` est écarté exprès : rien côté FFSS ne pourrait
  /// porter son créneau, donc l'offrir ne vaudrait à l'opérateur qu'un refus
  /// qu'il ne peut pas corriger d'ici. Pousser le déroulement depuis l'onglet
  /// Structure est ce qui le fait entrer dans cette liste.
  List<UnscheduledRound> get unscheduledRounds {
    final placed = _meetings.placedPartieIds;
    final rounds = <UnscheduledRound>[];
    for (final structure
        in _programme.current.value?.structures ?? const <EventStructure>[]) {
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
          spotsPerRace: structure.spotsForLevel(level),
        ));
      }
    }
    return rounds;
  }

  /// Ajoute un item informatif à la réunion, puis pousse sa nouvelle fin.
  ///
  /// L'item démarre à la fin actuelle de la réunion et dure
  /// [defaultItemMinutes]. Un opérateur déconnecté est refusé avant que quoi
  /// que ce soit quitte l'appareil — FFSS répondrait sinon à une écriture
  /// anonyme par un « Invalid Token » nu qui se lit comme une panne serveur.
  Future<void> addManualItem(String label) async {
    if (!_refuseWhenSignedOut()) return;
    final held = meeting;
    if (held == null) return;

    isBusy.value = true;
    try {
      final begin = _endMinutes(held);
      final slotId = await _repo.submitSlot(
        meetingId: held.id,
        name: label,
        beginHour: _atMinutes(held.date, begin),
        endHour: _atMinutes(held.date, begin + defaultItemMinutes),
      );
      if (slotId <= 0) {
        message.trigger(const UiMessageError('schedule_item_failed'));
        return;
      }
      if (!await _meetings.reload()) {
        message.trigger(const UiMessageError('schedule_meeting_end_failed'));
        return;
      }
      await _pushEnd();
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('schedule_item_failed', details: e.detail));
    } finally {
      isBusy.value = false;
    }
  }

  /// Place un tour : son créneau, puis les courses dedans, puis les places de
  /// départ de chaque course.
  ///
  /// Le créneau dure [defaultItemMinutes] par course et les courses le
  /// remplissent bout à bout — un tour de trois séries prend trois fois la
  /// place d'un tour d'une. L'opérateur ajuste ensuite, mais la journée est
  /// d'abord à peu près juste.
  ///
  /// [name] et [courseNames] sont composés par la vue : nommer un tour demande
  /// le genre, et un genre est un mot traduit que ce contrôleur n'a pas à
  /// résoudre. [courseNames] compte une entrée par course. [spotsPerRace] est
  /// ce que le tour déclare ; 0 ouvre les courses vides.
  ///
  /// Le site n'est pas un paramètre : il vient de la réunion, et toutes ses
  /// courses en héritent.
  Future<void> scheduleRound({
    required int partieId,
    required String name,
    required List<String> courseNames,
    required int spotsPerRace,
  }) async {
    if (!_refuseWhenSignedOut()) return;
    final held = meeting;
    if (held == null) return;
    // Une réunion migrée de l'ancien flow n'a pas de site (`description`
    // vide) : une course sans site atterrit dans une colonne sans nom sur
    // l'onglet Programme en lecture seule. Refuser ici, avant que quoi que
    // ce soit ne quitte l'appareil — l'opérateur a le ✎ pour corriger.
    if (held.site.isEmpty) {
      message.trigger(const UiMessageError('meeting_site_required'));
      return;
    }

    isBusy.value = true;
    try {
      final begin = _endMinutes(held);
      final courseCount = courseNames.length;
      // Au moins la place d'une course : un créneau de longueur nulle serait
      // invisible sur la frise et laisserait l'item suivant démarrer à la
      // même minute.
      final duration = defaultItemMinutes * (courseCount < 1 ? 1 : courseCount);

      final slotId = await _repo.submitSlot(
        meetingId: held.id,
        name: name,
        beginHour: _atMinutes(held.date, begin),
        endHour: _atMinutes(held.date, begin + duration),
        raceFormatDetailId: partieId,
      );
      if (slotId <= 0) {
        message.trigger(const UiMessageError('schedule_item_failed'));
        return;
      }

      final created = await _createRoundCourses(
        slotId: slotId,
        courseNames: courseNames,
        spotsPerRace: spotsPerRace,
        day: held.date,
        beginMinutes: begin,
      );
      await _linkRunsToRound(partieId, created.runIds);

      if (!await _meetings.reload()) {
        message.trigger(const UiMessageError('schedule_meeting_end_failed'));
        return;
      }
      await _pushEnd();

      // Signalé après le rechargement, pour que l'opérateur voie le tour qui
      // a bien atterri à côté de l'avertissement, plutôt qu'un échec nu
      // au-dessus d'une réunion vide.
      if (created.refused != null) {
        message.trigger(UiMessageError('schedule_courses_failed',
            details: created.refused));
      }
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('schedule_item_failed', details: e.detail));
    } finally {
      isBusy.value = false;
    }
  }

  /// Crée les courses du tour bout à bout dans son créneau, chacune ouvrant
  /// avec [spotsPerRace] places de départ.
  ///
  /// Un refus sur une course n'arrête pas les autres : une demi-manche sur le
  /// site est mauvaise, une demi-manche que l'opérateur croit complète est
  /// pire.
  Future<({List<int> runIds, String? refused})> _createRoundCourses({
    required int slotId,
    required List<String> courseNames,
    required int spotsPerRace,
    required DateTime day,
    required int beginMinutes,
  }) async {
    final failures = <String>[];
    // Une case par nom, portant 0 pour celles qui n'ont jamais atterri : un
    // refus ne doit pas faire glisser les heats d'après sur la mauvaise
    // course.
    final runIds = List<int>.filled(courseNames.length, 0);

    for (var i = 0; i < courseNames.length; i++) {
      final begin = beginMinutes + i * defaultItemMinutes;
      try {
        final runId = await _repo.submitRun(
          slotId: slotId,
          name: courseNames[i],
          beginHour: _atMinutes(day, begin),
          endHour: _atMinutes(day, begin + defaultItemMinutes),
          site: site,
        );
        if (runId <= 0) {
          failures.add(courseNames[i]);
          continue;
        }
        runIds[i] = runId;
        if (spotsPerRace > 0) {
          await _repo.createDefaultLanes(runId: runId, count: spotsPerRace);
        }
      } on AppException catch (e) {
        failures.add('${courseNames[i]} (${e.detail})');
      }
    }

    return (
      runIds: runIds,
      refused: failures.isEmpty ? null : failures.join(', '),
    );
  }

  /// Enregistre sur chaque heat tiré la course qu'il court, position par
  /// position : la n-ième course du tour a été créée depuis le n-ième heat,
  /// donc ils se correspondent par construction ici — ce qui est exactement
  /// pourquoi l'id est stocké maintenant plutôt que re-dérivé plus tard, une
  /// fois que des suppressions auront tout décalé.
  ///
  /// Une course refusée laisse l'id de son heat à 0 plutôt que de lui donner
  /// la course suivante.
  Future<void> _linkRunsToRound(int partieId, List<int> runIds) async {
    final programme = _programme.current.value;
    if (programme == null) return;
    var touched = false;
    final structures = [
      for (final structure in programme.structures)
        structure.copyWith(levels: [
          for (final level in structure.levels)
            if (level.serverId == partieId && level.races.isNotEmpty)
              () {
                touched = true;
                return level.copyWith(races: [
                  for (var i = 0; i < level.races.length; i++)
                    if (i < runIds.length && runIds[i] != 0)
                      level.races[i].copyWith(runId: runIds[i])
                    else
                      level.races[i],
                ]);
              }()
            else
              level,
        ]),
    ];
    if (!touched) return;
    await _programme.save(programme.copyWith(structures: structures));
  }

  /// Fixe la durée d'une course. Son début ne bouge pas ; tout ce qui suit,
  /// oui.
  ///
  /// Les courses d'un tour naissent toutes de la même longueur, mais une
  /// finale de plage ne prend pas ce qu'une série prend — l'opérateur ajuste
  /// donc celle qui diffère plutôt que le tour entier.
  Future<void> setRunDuration(int runId, int minutes) =>
      _resizeThenRepack(minutes, (held) async {
        final owner = _slotOfRun(held, runId);
        if (owner == null) return null;
        final run = owner.runs.firstWhere((r) => r.id == runId);
        final begin = minutesOf(run.beginTime);
        return await _repo.submitRun(
              slotId: owner.id,
              name: run.name,
              beginHour: _atMinutes(held.date, begin),
              endHour: _atMinutes(held.date, begin + minutes),
              site: run.site,
              id: runId,
            ) >
            0;
      });

  /// Redimensionne un créneau en gardant son propre début, puis recompacte.
  Future<void> setSlotDuration(int slotId, int minutes) =>
      _resizeThenRepack(minutes, (held) async {
        final slot = _slotById(held, slotId);
        if (slot == null) return null;
        final begin = minutesOf(slot.beginHour);
        return await _repo.submitSlot(
              meetingId: held.id,
              name: slot.name,
              beginHour: _atMinutes(held.date, begin),
              endHour: _atMinutes(held.date, begin + minutes),
              raceFormatDetailId: slot.raceFormatDetail?.id,
              id: slotId,
            ) >
            0;
      });

  /// Déplace l'item [oldIndex] en [newIndex], puis recalcule chaque horaire
  /// depuis le début de la réunion.
  ///
  /// Les nouvelles heures *sont* le nouvel ordre — FFSS n'a nulle part ailleurs
  /// pour l'enregistrer — donc ceci réutilise le même recompactage qu'une
  /// suppression.
  Future<void> reorderItems(int oldIndex, int newIndex) async {
    if (!_refuseWhenSignedOut()) return;
    final held = meeting;
    if (held == null) return;

    final ordered = _ordered(held);
    if (oldIndex < 0 || oldIndex >= ordered.length) return;
    // Un déplacement vers le bas est rapporté contre la liste *avant* que
    // l'item n'en sorte, donc l'index cible est trop haut d'un cran une fois
    // qu'il est retiré.
    final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
    if (target == oldIndex) return;
    ordered.insert(
        target.clamp(0, ordered.length - 1), ordered.removeAt(oldIndex));

    isBusy.value = true;
    try {
      if (await _repack(held, ordered)) await _meetings.reload(silent: true);
    } finally {
      isBusy.value = false;
    }
  }

  /// Retire une course de la réunion, et son créneau avec elle quand c'était
  /// la dernière.
  ///
  /// Un créneau vidé de ses courses n'est pas anodin : il n'a pas de site
  /// propre, donc la frise le range parmi les items manuels, là où personne
  /// n'ira chercher le tour qu'il vient de vider.
  Future<void> removeRun(int runId) async {
    if (!_refuseWhenSignedOut()) return;
    final held = meeting;
    if (held == null) return;
    final owner = _slotOfRun(held, runId);
    if (owner == null) return;

    isBusy.value = true;
    try {
      if (!await _repo.deleteRun(runId)) {
        message.trigger(const UiMessageError('schedule_item_failed'));
        return;
      }
      // Le run est parti ; un refus ici ne l'annule pas, il laisse juste le
      // créneau vidé sur FFSS — à signaler, pas à avaler.
      if (owner.runs.length == 1 && !await _repo.deleteSlot(owner.id)) {
        message.trigger(const UiMessageError('schedule_item_failed'));
      }
      await _reloadThenRepack();
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('schedule_item_failed', details: e.detail));
    } finally {
      isBusy.value = false;
    }
  }

  /// Supprime un créneau, puis recompacte pour ne rien laisser flotter.
  Future<void> removeSlot(int slotId) async {
    if (!_refuseWhenSignedOut()) return;
    if (meeting == null) return;

    isBusy.value = true;
    try {
      if (!await _repo.deleteSlot(slotId)) {
        message.trigger(const UiMessageError('schedule_item_failed'));
        return;
      }
      await _reloadThenRepack();
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('schedule_item_failed', details: e.detail));
    } finally {
      isBusy.value = false;
    }
  }

  // — Interne —

  /// Refuse l'écriture d'un opérateur déconnecté et rend `false`.
  bool _refuseWhenSignedOut() {
    if (canWriteToFfss) return true;
    message.trigger(const UiMessageError('login_required'));
    return false;
  }

  /// Le corps commun aux deux réglages de durée : refuser une durée nulle,
  /// envoyer le redimensionnement, puis recharger et recompacter.
  ///
  /// Recompacté et pas seulement re-terminé : allonger un item le fait
  /// chevaucher le suivant, le raccourcir laisse le même trou qu'une
  /// suppression.
  ///
  /// [resize] rend `null` quand l'item ciblé n'existe plus (rien à
  /// recompacter), `false` quand FFSS a refusé l'écriture (signalée et
  /// arrêtée là), `true` sur un succès.
  Future<void> _resizeThenRepack(
    int minutes,
    Future<bool?> Function(Meeting held) resize,
  ) async {
    if (minutes < 1) return;
    if (!_refuseWhenSignedOut()) return;
    final held = meeting;
    if (held == null) return;

    isBusy.value = true;
    try {
      final ok = await resize(held);
      if (ok == null) return;
      if (!ok) {
        message.trigger(const UiMessageError('schedule_item_failed'));
        return;
      }
      await _reloadThenRepack();
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('schedule_item_failed', details: e.detail));
    } finally {
      isBusy.value = false;
    }
  }

  /// Recharge l'arbre, puis recompacte la réunion telle qu'elle est revenue.
  ///
  /// Le rechargement d'abord : `layOut` lit les créneaux, donc une liste
  /// périmée calculerait une fin d'avant l'écriture et la signalerait comme un
  /// succès.
  Future<void> _reloadThenRepack() async {
    if (!await _meetings.reload()) {
      message.trigger(const UiMessageError('schedule_meeting_end_failed'));
      return;
    }
    final refreshed = meeting;
    if (refreshed != null) await _repack(refreshed, _ordered(refreshed));
  }

  /// Recompacte [held] depuis son heure de début dans l'ordre [ordered],
  /// n'envoie que ce qui a bougé, puis pousse la nouvelle fin.
  ///
  /// Seuls les items dont l'horaire change réellement partent : sur une
  /// journée de vingt, supprimer le dernier ne doit pas réécrire les
  /// dix-neuf d'avant.
  Future<bool> _repack(Meeting held, List<Slot> ordered) async {
    final competitionId = _meetings.competitionId;
    if (competitionId == null) return false;
    final target = layOut(ordered, minutesOf(held.beginHour));

    try {
      for (final move in moves(ordered, target)) {
        if (!await _applyMove(held, move)) {
          message.trigger(const UiMessageError('schedule_item_failed'));
          return false;
        }
      }
      final id = await _repo.submitMeeting(
        competitionId: competitionId,
        name: held.name,
        description: held.description,
        date: held.date,
        beginHour: held.beginHour,
        endHour: _atMinutes(held.date, target.endMinutes),
        id: held.id,
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

  /// Pousse la fin de la réunion à ce que ses items disent maintenant.
  ///
  /// Tourne *après* que l'item a atterri : un échec ici laisse une `fin`
  /// périmée sur FFSS plutôt qu'un item non enregistré — à signaler tout de
  /// même, puisque l'app recalcule la sienne depuis les créneaux et ne
  /// laisserait jamais l'opérateur savoir que les deux ont divergé.
  Future<void> _pushEnd() async {
    final held = meeting;
    final competitionId = _meetings.competitionId;
    if (held == null || competitionId == null) return;
    try {
      final id = await _repo.submitMeeting(
        competitionId: competitionId,
        name: held.name,
        description: held.description,
        date: held.date,
        beginHour: held.beginHour,
        endHour: _atMinutes(held.date, _endMinutes(held)),
        id: held.id,
      );
      if (id <= 0) {
        message.trigger(const UiMessageError('schedule_meeting_end_failed'));
      }
    } on AppException catch (e) {
      message.trigger(
          UiMessageError('schedule_meeting_end_failed', details: e.detail));
    }
  }

  Future<bool> _applyMove(Meeting held, TimetableMove move) async {
    final slot = _slotById(held, move.slotId);
    if (slot == null) return false;
    if (move.runId == null) {
      return await _repo.submitSlot(
            meetingId: held.id,
            name: slot.name,
            beginHour: _atMinutes(held.date, move.beginMinutes),
            endHour: _atMinutes(held.date, move.endMinutes),
            raceFormatDetailId: slot.raceFormatDetail?.id,
            id: slot.id,
          ) >
          0;
    }
    final run = slot.runs.firstWhere((r) => r.id == move.runId);
    return await _repo.submitRun(
          slotId: slot.id,
          name: run.name,
          beginHour: _atMinutes(held.date, move.beginMinutes),
          endHour: _atMinutes(held.date, move.endMinutes),
          site: run.site,
          id: run.id,
        ) >
        0;
  }

  /// La fin actuelle de la réunion, en minutes depuis minuit : là où se pose
  /// le prochain item.
  ///
  /// La vraie fin ([endMinutesOf]), pas celle d'un recompactage : l'arbre
  /// peut porter des trous — `addManualItem` et `scheduleRound` ne
  /// recompactent jamais, et `_repack` peut abandonner à mi-chemin sur un
  /// mouvement refusé — et `layOut` sur un tel arbre rendrait une fin plus
  /// tôt que le dernier item réel.
  int _endMinutes(Meeting held) => endMinutesOf(held);

  List<Slot> _ordered(Meeting held) =>
      [...held.slots]..sort((a, b) => a.beginHour.compareTo(b.beginHour));

  Slot? _slotById(Meeting held, int slotId) {
    for (final slot in held.slots) {
      if (slot.id == slotId) return slot;
    }
    return null;
  }

  Slot? _slotOfRun(Meeting held, int runId) {
    for (final slot in held.slots) {
      if (slot.runs.any((run) => run.id == runId)) return slot;
    }
    return null;
  }

  DateTime _atMinutes(DateTime day, int minutes) =>
      DateTime(day.year, day.month, day.day, minutes ~/ 60, minutes % 60);
}
