// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/data/ffss/dtos/json_readers.dart';

part 'officiel_dto.freezed.dart';
part 'officiel_dto.g.dart';

/// Un officiel de `competition/evenement/:id/officiels`. Ni `NumeroLicence`, ni
/// `Annee`, ni `Sexe` : ils ne sont pas lus.
@freezed
abstract class OfficielDto with _$OfficielDto {
  const factory OfficielDto({
    @JsonKey(name: 'Id', readValue: readInt) int? id,
    @JsonKey(name: 'Prenom') String? firstName,
    @JsonKey(name: 'Nom') String? lastName,
    @JsonKey(name: 'Niveau') String? level,
    @JsonKey(name: 'Principal') bool? principal,
    // Les jours sont servis en chaînes (`["3"]`) ; lus un à un par le mapper.
    @JsonKey(name: 'Jours', readValue: readList) List<Object?>? days,
    @JsonKey(name: 'joursLabel') String? daysLabel,
    @JsonKey(name: 'officielClubLabel') String? club,
  }) = _OfficielDto;

  factory OfficielDto.fromJson(Map<String, dynamic> json) =>
      _$OfficielDtoFromJson(json);
}
