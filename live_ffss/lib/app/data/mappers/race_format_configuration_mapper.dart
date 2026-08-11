import 'package:live_ffss/app/data/dtos/race_format_configuration_dto.dart';
import 'package:live_ffss/app/data/mappers/category_mapper.dart';
import 'package:live_ffss/app/data/mappers/discipline_mapper.dart';
import 'package:live_ffss/app/data/mappers/race_format_detail_mapper.dart';
import 'package:live_ffss/app/domain/models/race_format_configuration.dart';

extension RaceFormatConfigurationMapper on RaceFormatConfigurationDto {
  RaceFormatConfiguration toDomain() => RaceFormatConfiguration(
        id: id,
        competitionId: competitionId,
        disciplineId: disciplineId,
        label: label,
        fullLabel: fullLabel,
        gender: gender,
        genderLabel: genderLabel,
        discipline: discipline.toDomain(),
        categories: categories.map((c) => c.toDomain()).toList(),
        details: details.map((d) => d.toDomain()).toList(),
      );
}
