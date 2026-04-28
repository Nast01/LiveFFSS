import 'package:live_ffss/app/data/dtos/referee_dto.dart';
import 'package:live_ffss/app/data/mappers/athlete_mapper.dart';
import 'package:live_ffss/app/domain/models/referee.dart';

extension RefereeMapper on RefereeDto {
  Referee toDomain() => Referee(
        id: id,
        licenseeNumber: licenseeNumber,
        firstName: firstName,
        lastName: lastName,
        gender: parseGender(gender),
        year: year,
        level: level,
        levelMax: levelMax,
        nationalityCode: nationalityCode,
        nationality: nationality,
        isValid: isValid,
        isLicensee: isLicensee,
        isGuest: isGuest,
        isPrincipal: isPrincipal,
        availabilities: availabilities,
      );
}
