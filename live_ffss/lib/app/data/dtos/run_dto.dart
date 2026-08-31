// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/data/dtos/heat_dto.dart';
import 'package:live_ffss/app/data/dtos/live_result_dto.dart';

part 'run_dto.freezed.dart';
part 'run_dto.g.dart';

/// Vérifié contre un vrai payload le 2026-08-31 (compétition 1451, course 20),
/// première course jamais créée sur l'API : les clés `id`, `Nom`, `label`,
/// `fullLabel`, `statut`, `statutLabel`, `site`, `debut`, `fin` et `serie`
/// correspondent.
///
/// Une seule ne correspond pas : les résultats arrivent sous `places`, pas
/// `liveResults`. Le champ ci-dessous reste donc toujours vide. La clé n'est
/// pas corrigée tant que la forme d'un élément de `places` n'a pas été
/// observée peuplée — la renommer à l'aveugle échangerait un champ mort
/// contre un plantage au parsing.
@freezed
class RunDto with _$RunDto {
  const factory RunDto({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'Nom') required String name,
    @JsonKey(name: 'label') required String label,
    @JsonKey(name: 'fullLabel') required String fullLabel,
    @JsonKey(name: 'statut') required int status,
    @JsonKey(name: 'statutLabel') required String statusLabel,
    @JsonKey(name: 'site') required String site,
    @JsonKey(name: 'debut') required String beginTime,
    @JsonKey(name: 'fin') required String endTime,
    @JsonKey(name: 'serie') HeatDto? heat,
    @JsonKey(name: 'liveResults') @Default(<LiveResultDto>[]) List<LiveResultDto> liveResults,
  }) = _RunDto;

  factory RunDto.fromJson(Map<String, dynamic> json) => _$RunDtoFromJson(json);
}
