import 'package:live_ffss/app/data/dtos/discipline_dto.dart';
import 'package:live_ffss/app/domain/models/discipline.dart';

extension DisciplineMapper on DisciplineDto {
  Discipline toDomain() => Discipline(
        id: id,
        name: name,
        speciality: speciality,
        specialityLabel: specialityLabel,
        distance: distance,
        numberOfAthletes: numberOfAthletes,
        isRelay: isRelay,
        hasTime: hasTime,
      );
}
