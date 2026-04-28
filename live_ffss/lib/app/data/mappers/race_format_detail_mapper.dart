import 'package:live_ffss/app/data/dtos/race_format_detail_dto.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';

extension RaceFormatDetailMapper on RaceFormatDetailDto {
  RaceFormatDetail toDomain() => RaceFormatDetail(
        id: id,
        order: order,
        label: label,
        fullLabel: fullLabel,
        levelLabel: levelLabel,
        level: level,
        numberOfRun: numberOfRun,
        qualificationMethod: qualificationMethod,
        qualificationMethodLabel: qualificationMethodLabel,
        spotsPerRace: spotsPerRace,
        qualifyingSpots: qualifyingSpots,
      );
}
