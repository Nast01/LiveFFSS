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

  /// La compétition chargée. Exposée pour les écritures qui l'exigent sans
  /// que le modèle `Meeting` la porte — `reunion/submit` en tête.
  int? get competitionId => _competitionId;

  // Le service est `permanent` mais les contrôleurs qui l'appellent sont
  // recréés à chaque entrée de route : un load() lancé par un écran déjà
  // quitté peut donc encore être en vol quand un load() plus récent, pour une
  // autre compétition, a déjà répondu. Ce compteur donne à chaque appel un
  // jeton ; un appel dont le jeton n'est plus le dernier en date sait que sa
  // réponse a été dépassée et n'écrit rien.
  int _requestToken = 0;

  // Le jeton répond à « ma réponse compte-t-elle encore ? » ; il ne peut pas
  // aussi répondre à « quelqu'un charge-t-il encore ? ». Un appel dépassé a
  // quand même levé [isLoading] à son tour et doit le rendre en le baissant à
  // sa sortie, sans quoi un rafraîchissement silencieux qui répond avant lui
  // laisserait le drapeau levé pour toujours. Compte les appels non
  // silencieux encore en vol ; [isLoading] ne redescend que lorsqu'il n'en
  // reste aucun.
  int _loadingCalls = 0;

  /// Rend si [meetings] reflète bien FFSS. Un appelant qui enchaîne sur une
  /// écriture dérivée de la liste doit le savoir : calculer une fin de réunion
  /// depuis une liste que le rechargement n'a pas pu rafraîchir pousserait une
  /// `fin` d'avant l'écriture, et la signalerait comme un succès. Un appel
  /// dépassé par un load() plus récent rend aussi `false`, pour la même
  /// raison : sa réponse n'a été écrite nulle part.
  ///
  /// Un échec lève [hasError] plutôt qu'un message one-shot : un opérateur qui
  /// ne voit pas pourquoi sa journée est vide a besoin d'un état que la vue
  /// continue de rendre, pas d'un toast déjà disparu. [meetings] est laissée
  /// en place — une journée périmée mais réelle vaut mieux qu'une page blanche.
  ///
  /// [silent] garde [isLoading] baissé pour qu'un tiré-pour-rafraîchir ne
  /// remplace pas la liste par un spinner sous le doigt de l'opérateur.
  Future<bool> load(int competitionId, {bool silent = false}) async {
    final token = ++_requestToken;
    // Changer de compétition vide d'abord : les réunions de la précédente
    // s'afficheraient sous la nouvelle si le chargement échouait. Ceci est
    // synchrone — pas d'await avant, donc pas de jeton à vérifier ici : aucun
    // autre appel ne peut s'intercaler.
    if (_competitionId != competitionId) meetings.clear();
    _competitionId = competitionId;
    try {
      if (!silent) {
        _loadingCalls++;
        isLoading.value = true;
      }
      hasError.value = false;
      final result = await _repo.getMeetings(competitionId);
      if (token != _requestToken) return false;
      meetings.value = result;
      return true;
    } on AppException {
      if (token != _requestToken) return false;
      hasError.value = true;
      return false;
    } finally {
      // Inconditionnel sur le jeton : cet appel a levé le drapeau, à lui de
      // le rendre même dépassé — seul le compte d'appels encore en vol décide
      // si [isLoading] doit redescendre.
      if (!silent) {
        _loadingCalls--;
        isLoading.value = _loadingCalls > 0;
      }
    }
  }

  /// Charge l'arbre seulement s'il n'est pas déjà celui de cette compétition.
  ///
  /// Pour un écran qui lit l'arbre sans en être responsable : l'onglet Séries
  /// n'en tire que le site et l'horaire de ses propres courses, et le
  /// redemander à chaque ouverture lui coûtait une requête par créneau de
  /// toute la compétition. Qui a besoin de fraîcheur appelle [reload] ;
  /// l'écriture d'une réunion, elle, recharge déjà de son côté.
  Future<bool> ensureLoaded(int competitionId, {bool silent = false}) async {
    if (_competitionId == competitionId && meetings.isNotEmpty) return true;
    return load(competitionId, silent: silent);
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

  /// Les ids de course que l'arbre porte encore, toutes réunions confondues.
  ///
  /// Ce qui rend « posé » vérifiable côté serveur plutôt que sur parole du
  /// blob local : un `ProgrammeRace.runId` que cet ensemble ne contient plus
  /// désigne une course supprimée — depuis cette app, depuis une autre, ou
  /// sur le site fédéral — donc un heat qu'il faut pouvoir reposer. Sans ça,
  /// supprimer une course condamnerait son heat à passer pour placé jusqu'à
  /// la fin des temps.
  Set<int> get liveRunIds => {
        for (final meeting in meetings)
          for (final slot in meeting.slots)
            for (final run in slot.runs) run.id,
      };

  /// Les parties qu'un créneau porte déjà, toutes réunions confondues. Un
  /// créneau sans partie est un item manuel et n'en place aucune.
  Set<int> get placedPartieIds => {
        for (final meeting in meetings)
          for (final slot in meeting.slots)
            if (slot.raceFormatDetail != null) slot.raceFormatDetail!.id,
      };
}
