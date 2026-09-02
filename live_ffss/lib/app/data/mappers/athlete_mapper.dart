import 'package:live_ffss/app/data/dtos/athlete_dto.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';

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
        categories: _distinctCategories(),
      );

  /// One [Category] per distinct category across the athlete's entries. An
  /// athlete entered in seven épreuves is usually in the same category several
  /// times over, and repeating it would say nothing.
  List<Category> _distinctCategories() {
    final byId = <int, Category>{};
    for (final entry in entries) {
      final category = entry.category;
      if (category == null || category.id == 0) continue;
      byId.putIfAbsent(
          category.id, () => Category(id: category.id, name: category.name));
    }
    return byId.values.toList();
  }
}

/// FFSS sends the ISO 3166 alpha-3 country code, but Switzerland is known by
/// its sport-federation code (SUI) on start lists and scoreboards.
String normalizeNationalityCode(String raw) => raw == 'CHE' ? 'SUI' : raw;

/// Inverse of [parseGender], for the endpoints that take a gender back —
/// `deroulement/submit` expects H, F or M.
String genderCode(Gender gender) => switch (gender) {
      Gender.female => 'F',
      Gender.mixed => 'M',
      Gender.male => 'H',
      Gender.unknown => 'H',
    };

Gender parseGender(String raw) => switch (raw) {
      'F' => Gender.female,
      'M' => Gender.mixed,
      _ => Gender.male,
    };
