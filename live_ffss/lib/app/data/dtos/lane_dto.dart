// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/data/dtos/entry_dto.dart';
import 'package:live_ffss/app/data/dtos/result_dto.dart';

part 'lane_dto.freezed.dart';
part 'lane_dto.g.dart';

/// FFSS calls this a « place » — a numbered spot in one course, holding the
/// entry that starts there and the result it produced.
///
/// Clés relevées sur un vrai payload le 2026-09-01 (compétition 1451, course
/// 20). La documentation fédérale est fausse sur quatre points : elle annonce
/// `Id`, `Engagement` et `Resultat` capitalisés — ils arrivent en minuscules —
/// et un `Numero` de type String, qui est un entier. Les paramètres de
/// `place/submit` y sont eux aussi recopiés de ceux du créneau : le seul
/// attendu est `numero`.
///
/// Deux champs du payload ne sont volontairement pas portés. `fullLabel` vaut
/// le libellé collé à lui-même (« Place 1 - Place 1 »), quirk serveur connu,
/// et n'apporte rien. `remplacants` et `athletes` n'ont jamais été observés
/// peuplés : les modéliser reviendrait à deviner leur forme.
@freezed
class LaneDto with _$LaneDto {
  const factory LaneDto({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'Numero') @Default(0) int number,
    @JsonKey(name: 'label') @Default('') String label,
    @JsonKey(name: 'engagement') EntryDto? entry,
    @JsonKey(name: 'resultat') ResultDto? result,
  }) = _LaneDto;

  factory LaneDto.fromJson(Map<String, dynamic> json) =>
      _$LaneDtoFromJson(json);
}
