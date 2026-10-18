import 'package:live_ffss_v2/data/ffss/dtos/deroulement_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/results_mapper.dart';
import 'package:live_ffss_v2/data/ffss/mappers/reunion_mapper.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/progression.dart';

/// Le déroulement imbriqué dans un créneau ne sert pas `Genre`, seulement
/// son libellé.
Gender? _parseGenderLabel(String? label) => switch (label?.trim()) {
  'Homme' => Gender.male,
  'Femme' => Gender.female,
  'Mixte' => Gender.mixed,
  _ => null,
};

extension DeroulementMapper on DeroulementDto {
  /// Nulle sans id. Une partie inutilisable est écartée seule.
  Progression? toDomain() {
    final id = this.id;
    if (id == null) return null;
    final stages = [for (final partie in parties) ?partie.toDomain()]
      ..sort((a, b) => a.order.compareTo(b.order));
    return Progression(
      id: id,
      name: label?.trim() ?? '',
      disciplineName: discipline?.name?.trim() ?? '',
      disciplineId: disciplineId,
      gender: parseGender(gender) ?? _parseGenderLabel(genderLabel),
      categories: decodeRows(
        categories,
        DeroulementCategorieDto.fromJson,
        (DeroulementCategorieDto category) => switch (category.name?.trim()) {
          final name? when name.isNotEmpty => name,
          _ => null,
        },
      ),
      stages: stages,
    );
  }
}

extension PartieMapper on PartieDto {
  Stage? toDomain() {
    final id = this.id;
    final level = StageLevel.fromCode(this.level);
    if (id == null || level == null) return null;
    final qualifying = qualifyingPlaces;
    return Stage(
      id: id,
      order: order ?? 0,
      level: level,
      name: label?.trim() ?? '',
      qualification: QualificationMethod.fromCode(qualificationLogic),
      heatCount: heatCount ?? 0,
      placesPerHeat: placesPerHeat ?? 0,
      qualifyingPlaces: qualifying == null || qualifying == 0
          ? null
          : qualifying,
    );
  }
}
