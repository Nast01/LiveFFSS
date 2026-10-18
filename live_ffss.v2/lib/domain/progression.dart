import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/gender.dart';

part 'progression.freezed.dart';

/// Niveau d'une étape, comme `StageLevel` dans FFSSCompetition V3. `final`
/// étant un mot réservé en Dart, la finale s'appelle `finalStage`.
enum StageLevel {
  heats,
  quarterFinal,
  semiFinal,
  finalStage;

  /// Nulle pour un code inconnu : l'étape est alors écartée plutôt que
  /// rangée au mauvais niveau.
  static StageLevel? fromCode(String? code) => switch (code?.trim()) {
    'heat' => StageLevel.heats,
    'quarter' => StageLevel.quarterFinal,
    'semi' => StageLevel.semiFinal,
    'final' => StageLevel.finalStage,
    _ => null,
  };
}

/// Façon dont les qualifiés d'une étape sont retenus, comme
/// `QualificationMethod` dans V3.
enum QualificationMethod {
  none,
  byHeat,
  byStage;

  static QualificationMethod fromCode(String? code) => switch (code?.trim()) {
    'course' => QualificationMethod.byHeat,
    'partie' => QualificationMethod.byStage,
    _ => QualificationMethod.none,
  };
}

/// Une étape d'un déroulement (une « partie » FFSS), comme `Stage` dans V3.
@freezed
abstract class Stage with _$Stage {
  const factory Stage({
    required int id,
    required int order,
    required StageLevel level,

    /// Le `label` FFSS, par exemple « Finale - Cadet ».
    required String name,
    required QualificationMethod qualification,
    required int heatCount,
    required int placesPerHeat,

    /// Nul quand l'API publie 0, c'est-à-dire aucune place qualificative.
    int? qualifyingPlaces,
  }) = _Stage;
}

/// Le déroulement d'une épreuve : ses étapes dans l'ordre, comme
/// `Progression` dans V3.
@freezed
abstract class Progression with _$Progression {
  const Progression._();

  const factory Progression({
    required int id,
    required String name,
    @Default('') String disciplineName,

    /// Lie le déroulement aux épreuves de `competition/epreuve`, qui ne portent
    /// que la discipline, le genre et la catégorie.
    int? disciplineId,
    Gender? gender,
    @Default(<String>[]) List<String> categories,
    @Default(<Stage>[]) List<Stage> stages,
  }) = _Progression;

  Stage? stageById(int id) {
    for (final stage in stages) {
      if (stage.id == id) return stage;
    }
    return null;
  }
}
