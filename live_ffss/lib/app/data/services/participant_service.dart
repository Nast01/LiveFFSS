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

  int? get competitionId => _competitionId;

  /// Le dossard de cet athlète, 0 quand l'index ne le connaît pas — athlète
  /// absent de la liste, ou lecture qui a échoué.
  int orderNumberOf(int athleteId) => _byAthlete[athleteId] ?? 0;

  /// Charge l'index seulement s'il n'est pas déjà celui de cette compétition.
  ///
  /// Qui a besoin de fraîcheur appelle [reload] ; un dossard ne change pas en
  /// cours de compétition, donc les écrans se contentent de celui-ci.
  Future<bool> ensureLoaded(int competitionId) async {
    if (_competitionId == competitionId && _byAthlete.isNotEmpty) return true;
    return _load(competitionId);
  }

  /// Relit la compétition déjà chargée. Sans appel préalable à [ensureLoaded],
  /// il n'y a aucune compétition à relire.
  Future<bool> reload() async {
    final id = _competitionId;
    if (id == null) return false;
    return _load(id);
  }

  Future<bool> _load(int competitionId) async {
    // Vider d'abord : les dossards de la compétition précédente désigneraient
    // les mauvais athlètes sous celle-ci.
    if (_competitionId != competitionId) _byAthlete.clear();
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
      return true;
    } on AppException {
      // Best-effort : l'écran s'affiche sans dossards plutôt que pas du tout.
      return false;
    }
  }
}
