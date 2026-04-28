import 'package:live_ffss/app/data/dtos/race_dto.dart';
import 'package:live_ffss/app/data/mappers/athlete_mapper.dart';
import 'package:live_ffss/app/data/mappers/category_mapper.dart';
import 'package:live_ffss/app/domain/models/race.dart';

extension RaceMapper on RaceDto {
  Race toDomain() => Race(
        id: id,
        name: discipline.name,
        nameEnglish: discipline.nameEnglish,
        distance: discipline.distance,
        gender: parseGender(gender),
        athletesPerTeam: discipline.athletesPerTeam,
        specialityId: discipline.specialityId,
        specialityLabel: discipline.specialityLabel,
        disciplineId: disciplineId,
        isEligibleToNationalRecord: isEligibleToNationalRecord,
        categories: categories.map((c) => c.toDomain()).toList(),
      );
}
