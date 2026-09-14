import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/utils/competition_days.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/meeting_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/meeting_timetable.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

/// Une réunion sans item démarre à 08:00 — le défaut de la réunion FFSS.
const int defaultMeetingStartMinutes = 8 * 60;

/// Créer ou éditer une réunion : titre, date, heure de début, site.
class MeetingFormController extends GetxController {
  MeetingFormController(
    this._meetings,
    this._repo,
    this._programme,
    this._user,
  );

  final MeetingService _meetings;
  final MeetingRepository _repo;
  final ProgrammeService _programme;
  final UserService _user;

  final Rxn<Competition> competition = Rxn<Competition>();

  /// La réunion éditée, null en création.
  final Rxn<Meeting> editing = Rxn<Meeting>();

  final RxList<DateTime> days = <DateTime>[].obs;
  final Rxn<DateTime> date = Rxn<DateTime>();
  final RxInt startMinutes = defaultMeetingStartMinutes.obs;
  final Rxn<String> site = Rxn<String>();
  final RxBool isSaving = false.obs;
  final Rxn<UiMessage> message = Rxn<UiMessage>();

  bool get isEditing => editing.value != null;
  bool get canWriteToFfss => _user.currentUser.value != null;
  List<ProgrammeSite> get sites => _programme.current.value?.sites ?? const [];

  @override
  void onInit() {
    super.onInit();
    applyArguments(Get.arguments);
  }

  void applyArguments(Object? arg) {
    if (arg is! Map) return;
    final comp = arg['competition'];
    if (comp is Competition) {
      competition.value = comp;
      days.value = competitionDays(comp.beginDate, comp.endDate);
    }
    final existing = arg['meeting'];
    if (existing is Meeting) {
      editing.value = existing;
      date.value =
          DateTime(existing.date.year, existing.date.month, existing.date.day);
      startMinutes.value = minutesOf(existing.beginHour);
      site.value = existing.site.isEmpty ? null : existing.site;
      return;
    }
    date.value = days.isEmpty ? null : days.first;
  }

  /// Enregistre la réunion. Rend `true` quand la vue peut se refermer.
  ///
  /// [title] vient de la vue : le champ de saisie appartient à un
  /// `StatefulWidget`, pas au contrôleur.
  Future<bool> save(String title) async {
    final trimmed = title.trim();
    final competitionId = competition.value?.id;
    final day = date.value;
    final chosenSite = site.value;

    if (!canWriteToFfss) {
      message.trigger(const UiMessageError('login_required'));
      return false;
    }
    if (trimmed.isEmpty) {
      message.trigger(const UiMessageError('meeting_title_required'));
      return false;
    }
    if (competitionId == null || day == null) {
      message.trigger(const UiMessageError('no_days'));
      return false;
    }
    // Le site n'est pas décoratif : toutes les courses de la réunion en
    // héritent, et une course sans site atterrit dans une colonne sans nom.
    if (chosenSite == null || chosenSite.isEmpty) {
      message.trigger(const UiMessageError('meeting_site_required'));
      return false;
    }

    isSaving.value = true;
    try {
      return await _push(
        competitionId: competitionId,
        title: trimmed,
        day: day,
        site: chosenSite,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> _push({
    required int competitionId,
    required String title,
    required DateTime day,
    required String site,
  }) async {
    final existing = editing.value;
    final slots = existing?.slots ?? const [];
    // Les items partent d'abord et la réunion en dernier : un créneau refusé
    // laisse la journée où elle était plutôt qu'à moitié déplacée.
    //
    // Seule l'heure de début décale quoi que ce soit. Changer la date n'en
    // décale aucun : submitSlot et submitRun n'envoient que `HH:mm`, jamais
    // le jour.
    final target = layOut(slots.toList(), startMinutes.value);
    final shifted = existing == null
        ? const <TimetableMove>[]
        : moves(slots.toList(), target);

    try {
      for (final move in shifted) {
        if (!await _applyMove(existing!, move, day)) {
          message.trigger(const UiMessageError('schedule_item_failed'));
          return false;
        }
      }

      final id = await _repo.submitMeeting(
        competitionId: competitionId,
        name: title,
        description: site,
        date: day,
        beginHour: _atMinutes(day, startMinutes.value),
        endHour: _atMinutes(day, target.endMinutes),
        id: existing?.id,
      );
      if (id <= 0) {
        message.trigger(const UiMessageError('meeting_save_failed'));
        return false;
      }
    } on AppException catch (e) {
      message.trigger(UiMessageError('meeting_save_failed', details: e.detail));
      return false;
    }

    await _meetings.reload();
    return true;
  }

  Future<bool> _applyMove(
      Meeting meeting, TimetableMove move, DateTime day) async {
    final slot = meeting.slots.firstWhere((s) => s.id == move.slotId);
    if (move.runId == null) {
      final id = await _repo.submitSlot(
        meetingId: meeting.id,
        name: slot.name,
        beginHour: _atMinutes(day, move.beginMinutes),
        endHour: _atMinutes(day, move.endMinutes),
        raceFormatDetailId: slot.raceFormatDetail?.id,
        id: slot.id,
      );
      return id > 0;
    }
    final run = slot.runs.firstWhere((r) => r.id == move.runId);
    final id = await _repo.submitRun(
      slotId: slot.id,
      name: run.name,
      beginHour: _atMinutes(day, move.beginMinutes),
      endHour: _atMinutes(day, move.endMinutes),
      site: run.site,
      id: run.id,
    );
    return id > 0;
  }

  /// Minutes depuis minuit → un vrai [DateTime] sur [day] : les écritures FFSS
  /// veulent une heure qui porte une date.
  DateTime _atMinutes(DateTime day, int minutes) =>
      DateTime(day.year, day.month, day.day, minutes ~/ 60, minutes % 60);
}
