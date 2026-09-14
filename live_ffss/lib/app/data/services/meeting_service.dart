import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/meeting_repository.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';

/// L'arbre réunion FFSS d'une compétition — `Réunion → Créneau → Course` —
/// et son unique propriétaire.
///
/// Un service et non un contrôleur parce que trois contrôleurs lisent le même
/// arbre : la liste, le formulaire et l'éditeur. Ce dernier doit en outre
/// connaître les parties déjà placées *dans les autres réunions*, sinon il
/// proposerait deux fois le même tour.
class MeetingService extends GetxService {
  MeetingService(this._repo);

  final MeetingRepository _repo;

  final RxList<Meeting> meetings = <Meeting>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  int? _competitionId;

  /// Rend si [meetings] reflète bien FFSS. Un appelant qui enchaîne sur une
  /// écriture dérivée de la liste doit le savoir : calculer une fin de réunion
  /// depuis une liste que le rechargement n'a pas pu rafraîchir pousserait une
  /// `fin` d'avant l'écriture, et la signalerait comme un succès.
  ///
  /// Un échec lève [hasError] plutôt qu'un message one-shot : un opérateur qui
  /// ne voit pas pourquoi sa journée est vide a besoin d'un état que la vue
  /// continue de rendre, pas d'un toast déjà disparu. [meetings] est laissée
  /// en place — une journée périmée mais réelle vaut mieux qu'une page blanche.
  ///
  /// [silent] garde [isLoading] baissé pour qu'un tiré-pour-rafraîchir ne
  /// remplace pas la liste par un spinner sous le doigt de l'opérateur.
  Future<bool> load(int competitionId, {bool silent = false}) async {
    // Changer de compétition vide d'abord : les réunions de la précédente
    // s'afficheraient sous la nouvelle si le chargement échouait.
    if (_competitionId != competitionId) meetings.clear();
    _competitionId = competitionId;
    try {
      if (!silent) isLoading.value = true;
      hasError.value = false;
      meetings.value = await _repo.getMeetings(competitionId);
      return true;
    } on AppException {
      hasError.value = true;
      return false;
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  /// Recharge la compétition déjà chargée. Sans appel préalable à [load], il
  /// n'y a aucune compétition à recharger.
  Future<bool> reload({bool silent = false}) async {
    final id = _competitionId;
    if (id == null) return false;
    return load(id, silent: silent);
  }

  Meeting? byId(int id) {
    for (final meeting in meetings) {
      if (meeting.id == id) return meeting;
    }
    return null;
  }

  /// Les parties qu'un créneau porte déjà, toutes réunions confondues. Un
  /// créneau sans partie est un item manuel et n'en place aucune.
  Set<int> get placedPartieIds => {
        for (final meeting in meetings)
          for (final slot in meeting.slots)
            if (slot.raceFormatDetail != null) slot.raceFormatDetail!.id,
      };
}
