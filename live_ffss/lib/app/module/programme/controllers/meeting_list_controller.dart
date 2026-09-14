import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/utils/competition_days.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/data/services/meeting_service.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

/// L'onglet Programme : les réunions de la compétition, groupées par jour.
class MeetingListController extends GetxController {
  MeetingListController(
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

  /// Les jours de la compétition. Un groupement d'affichage, et la contrainte
  /// du sélecteur de date du formulaire — plus un appariement : une journée
  /// porte autant de réunions que l'opérateur en crée.
  final RxList<DateTime> days = <DateTime>[].obs;

  final RxBool isDeleting = false.obs;
  final Rxn<UiMessage> message = Rxn<UiMessage>();

  RxBool get isLoading => _meetings.isLoading;
  RxBool get hasError => _meetings.hasError;
  RxList<Meeting> get meetings => _meetings.meetings;

  /// Tout ce que cet écran lit est public, donc un opérateur déconnecté entre
  /// sans friction — seule une écriture revient refusée.
  bool get canWriteToFfss => _user.currentUser.value != null;

  List<ProgrammeSite> get sites => _programme.current.value?.sites ?? const [];

  Future<void> setCompetition(Competition? comp) async {
    if (comp == competition.value) return;
    competition.value = comp;
    days.value = competitionDays(comp?.beginDate, comp?.endDate);
    if (comp != null) await _meetings.load(comp.id);
  }

  // Not named `refresh`: GetxController already inherits one from GetX's
  // ListNotifierMixin, whose contract is "notify listeners to rebuild" — a
  // caller expecting that would fire a network reload instead.
  Future<void> reloadFromServer() => _meetings.reload(silent: true);

  /// Les réunions de [day], la plus matinale d'abord. Comparées par date
  /// civile : [Meeting.date] porte le vrai jour, ses créneaux non.
  List<Meeting> meetingsOn(DateTime day) {
    final held = [
      for (final meeting in meetings)
        if (sameDay(meeting.date, day)) meeting,
    ]..sort((a, b) => a.beginHour.compareTo(b.beginHour));
    return held;
  }

  /// Les réunions dont la date ne correspond à aucun jour de la compétition
  /// — FFSS en garde que cette appli n'a pas écrites, ou laissées là après un
  /// resserrement des dates de la compétition. Sans ce groupe elles ne
  /// seraient ni visibles, ni éditables, ni supprimables : une réunion que
  /// personne ne peut atteindre est pire qu'une réunion mal rangée.
  List<Meeting> get meetingsOffDates {
    final held = [
      for (final meeting in meetings)
        if (!days.any((d) => sameDay(d, meeting.date))) meeting,
    ]..sort((a, b) => a.beginHour.compareTo(b.beginHour));
    return held;
  }

  /// Combien de tours restent à placer. Informatif : placer un tour demande
  /// une réunion cible, geste qui n'a de sens que dans l'éditeur.
  ///
  /// Un tour sans `serverId` ne compte pas — rien côté FFSS ne pourrait
  /// porter son créneau, et l'annoncer ne vaudrait à l'opérateur qu'un refus
  /// qu'il ne peut pas corriger d'ici.
  int get unscheduledRoundCount {
    final placed = _meetings.placedPartieIds;
    var count = 0;
    for (final structure
        in _programme.current.value?.structures ?? const <EventStructure>[]) {
      for (final level in structure.levels) {
        if (level.serverId > 0 && !placed.contains(level.serverId)) count++;
      }
    }
    return count;
  }

  /// Supprime une réunion. Emporte ses créneaux et ses courses côté serveur :
  /// la vue demande confirmation avant d'arriver ici.
  Future<void> deleteMeeting(int meetingId) async {
    if (!canWriteToFfss) {
      message.trigger(const UiMessageError('login_required'));
      return;
    }
    isDeleting.value = true;
    try {
      if (!await _repo.deleteMeeting(meetingId)) {
        message.trigger(const UiMessageError('meeting_delete_failed'));
        return;
      }
    } on AppException catch (e) {
      message
          .trigger(UiMessageError('meeting_delete_failed', details: e.detail));
      return;
    } finally {
      isDeleting.value = false;
    }
    await _meetings.reload();
  }
}
