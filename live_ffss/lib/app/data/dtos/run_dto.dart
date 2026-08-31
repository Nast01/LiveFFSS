// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/data/dtos/heat_dto.dart';
import 'package:live_ffss/app/data/dtos/lane_dto.dart';

part 'run_dto.freezed.dart';
part 'run_dto.g.dart';

/// Vérifié contre un vrai payload le 2026-08-31 (compétition 1451, course 20),
/// première course jamais créée sur l'API : les clés `id`, `Nom`, `label`,
/// `fullLabel`, `statut`, `statutLabel`, `site`, `debut`, `fin` et `serie`
/// correspondent.
///
/// `places` a été vérifié à son tour le 2026-09-01, sur la première place
/// jamais créée : voir [LaneDto], dont les clés ne sont celles ni de la
/// documentation ni de l'ancien `LiveResultDto`.
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
    @JsonKey(name: 'places') @Default(<LaneDto>[]) List<LaneDto> lanes,
  }) = _RunDto;

  factory RunDto.fromJson(Map<String, dynamic> json) => _$RunDtoFromJson(json);
}
