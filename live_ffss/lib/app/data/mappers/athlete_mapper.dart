import 'package:live_ffss/app/data/dtos/athlete_dto.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';

extension AthleteMapper on AthleteDto {
  Athlete toDomain() => Athlete(
        id: id,
        licenseeNumber: licenseeNumber,
        firstName: firstName,
        lastName: lastName,
        gender: parseGender(gender),
        year: year,
        nationalityCode: nationalityCode,
        nationality: nationality,
        isValid: isValid,
        isLicensee: isLicensee,
        isGuest: isGuest,
      );
}

Gender parseGender(String raw) => switch (raw) {
      'F' => Gender.female,
      'M' => Gender.mixed,
      _ => Gender.male,
    };
