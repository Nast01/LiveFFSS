import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/competition_repository.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';

/// Les dossards d'une compétition, par athlète.
///
/// Un service et non un contrôleur parce que quatre écrans lisent le même
/// index : le marshalling, le tirage, l'onglet Séries et la saisie des places.
/// Ils reçoivent leurs athlètes de `competition/engagement`, qui ne sert pas le
/// dossard — c'est cette lecture-ci qui le leur donne, une fois par
/// compétition.
class ParticipantService extends GetxService {
  ParticipantService(this._repo);

  final CompetitionRepository _repo;

  final Map<int, int> _byAthlete = {};

  int? _competitionId;

  /// Distinct de `_byAthlete.isNotEmpty` : une lecture réussie peut ne
  /// rapporter aucun dossard (FFSS n'en a encore assigné aucun), et ce
  /// résultat vide doit rester tenu pour acquis au lieu d'être relu par
  /// chaque écran qui appelle [ensureLoaded].
  bool _loaded = false;

  // Les quatre écrans peuvent appeler [ensureLoaded] au montage pour une
  // compétition pas encore tenue, dans le même tick. La lecture en vol est
  // partagée plutôt que dupliquée ; elle est effacée dès qu'elle se
  // termine, succès ou échec, pour qu'un échec reste rejouable.
  int? _loadingCompetitionId;
  Future<bool>? _loadFuture;

  int? get competitionId => _competitionId;

  /// Le dossard de cet athlète, 0 quand l'index ne le connaît pas — athlète
  /// absent de la liste, ou lecture qui a échoué.
  int orderNumberOf(int athleteId) => _byAthlete[athleteId] ?? 0;

  /// Charge l'index seulement s'il n'est pas déjà celui de cette compétition.
  ///
  /// Qui a besoin de fraîcheur appelle [reload] ; un dossard ne change pas en
  /// cours de compétition, donc les écrans se contentent de celui-ci.
  Future<bool> ensureLoaded(int competitionId) {
    if (_competitionId == competitionId && _loaded) return Future.value(true);
    return _load(competitionId);
  }

  /// Relit la compétition déjà chargée. Sans appel préalable à [ensureLoaded],
  /// il n'y a aucune compétition à relire.
  Future<bool> reload() {
    final id = _competitionId;
    if (id == null) return Future.value(false);
    return _load(id);
  }

  Future<bool> _load(int competitionId) {
    if (_loadingCompetitionId == competitionId) return _loadFuture!;
    final future = _doLoad(competitionId);
    _loadingCompetitionId = competitionId;
    _loadFuture = future;
    return future;
  }

  Future<bool> _doLoad(int competitionId) async {
    // Vider d'abord : les dossards de la compétition précédente
    // désigneraient les mauvais athlètes sous celle-ci. Une relecture de la
    // même compétition (reload, ou après un échec) garde les siens jusqu'à
    // ce qu'une nouvelle lecture réussisse — le dernier résultat connu vaut
    // mieux qu'un index vidé sous le pied de l'écran qui le lit.
    if (_competitionId != competitionId) {
      _byAthlete.clear();
      _loaded = false;
    }
    _competitionId = competitionId;
    try {
      final participants = await _repo.getParticipants(competitionId);
      _byAthlete
        ..clear()
        ..addEntries([
          for (final Athlete participant in participants)
            if (participant.orderNumber > 0)
              MapEntry(participant.id, participant.orderNumber),
        ]);
      _loaded = true;
      return true;
    } on AppException {
      // Best-effort : l'écran s'affiche sans dossards plutôt que pas du
      // tout.
      return false;
    } finally {
      _loadingCompetitionId = null;
      _loadFuture = null;
    }
  }
}
