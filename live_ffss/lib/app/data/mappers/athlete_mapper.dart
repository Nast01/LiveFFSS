import 'package:live_ffss/app/data/dtos/athlete_dto.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';

extension AthleteMapper on AthleteDto {
  Athlete toDomain() => Athlete(
        id: id,
        // A guest carries no licence number: the API identifies them by
        // `idInvite` instead. Officiels are excluded from this — see
        // RefereeMapper, which always reads `NumeroLicence`.
        licenseeNumber:
            isGuest && guestId.isNotEmpty ? guestId : licenseeNumber,
        firstName: firstName,
        lastName: lastName,
        gender: parseGender(gender),
        year: year,
        nationalityCode: normalizeNationalityCode(nationalityCode),
        nationality: nationality,
        isValid: isValid,
        isLicensee: isLicensee,
        isGuest: isGuest,
        performanceTime: performanceTime,
        performanceLabel: performanceLabel,
        clubId: clubId,
        clubLabel: clubLabel,
        isSubstitute: isSubstitute,
      );
}

/// FFSS sends the ISO 3166 alpha-3 country code, but Switzerland is known by
/// its sport-federation code (SUI) on start lists and scoreboards.
String normalizeNationalityCode(String raw) => raw == 'CHE' ? 'SUI' : raw;

Gender parseGender(String raw) => switch (raw) {
      'F' => Gender.female,
      'M' => Gender.mixed,
      _ => Gender.male,
    };
