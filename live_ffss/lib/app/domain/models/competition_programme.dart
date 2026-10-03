import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';

part 'competition_programme.freezed.dart';
part 'competition_programme.g.dart';

@freezed
class CompetitionProgramme with _$CompetitionProgramme {
  const factory CompetitionProgramme({
    required int competitionId,
    // Monotonic counter for local entity ids (races, sites). Starts at 1.
    @Default(1) int nextLocalId,
    @Default(<ProgrammeSite>[]) List<ProgrammeSite> sites,
    @Default(<EventStructure>[]) List<EventStructure> structures,
  }) = _CompetitionProgramme;

  factory CompetitionProgramme.fromJson(Map<String, dynamic> json) =>
      _$CompetitionProgrammeFromJson(json);
}

/// La structure d'une épreuve × catégorie, et son remplacement.
///
/// Une épreuve peut être partagée par deux catégories — les séries Junior et
/// Senior d'un même 50 m produisent deux structures de même `raceId` — donc la
/// paire est la clé, jamais le seul `raceId`. Quatre contrôleurs déroulaient
/// cette boucle.
extension CompetitionProgrammeStructures on CompetitionProgramme {
  /// La structure de cette épreuve × catégorie, ou nul s'il n'y en a pas.
  EventStructure? structureFor(int raceId, int categoryId) {
    for (final structure in structures) {
      if (structure.raceId == raceId && structure.categoryId == categoryId) {
        return structure;
      }
    }
    return null;
  }

  /// Le même programme, [updated] ayant pris la place de la structure qui
  /// porte sa clé — ou ajoutée à la fin quand il n'y en avait aucune.
  ///
  /// L'ordre des autres est conservé : l'aperçu des structures les affiche
  /// dans l'ordre du blob, et une édition ne doit pas réordonner la liste
  /// sous l'opérateur.
  CompetitionProgramme withStructure(EventStructure updated) {
    var replaced = false;
    final merged = [
      for (final structure in structures)
        if (structure.raceId == updated.raceId &&
            structure.categoryId == updated.categoryId)
          () {
            replaced = true;
            return updated;
          }()
        else
          structure,
    ];
    return copyWith(structures: replaced ? merged : [...merged, updated]);
  }
}
