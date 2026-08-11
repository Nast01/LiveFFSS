import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/race.dart';

/// Heat size when nothing has been authored yet. Coastal races run far bigger
/// fields than pool ones, so the default differs by speciality.
const int defaultPoolSpotsPerRace = 8;
const int defaultCoastalSpotsPerRace = 16;

extension GenderFormatting on Gender {
  String get label => switch (this) {
        Gender.female => 'women'.tr,
        Gender.mixed => 'mixed'.tr,
        Gender.male => 'men'.tr,
        Gender.unknown => 'men'.tr,
      };

  /// One letter for a badge, where the full word would not fit. Translated:
  /// "H" reads as Hommes in French, "M" as Men in English.
  String get shortLabel => switch (this) {
        Gender.female => 'gender_short_women'.tr,
        Gender.mixed => 'gender_short_mixed'.tr,
        Gender.male => 'gender_short_men'.tr,
        Gender.unknown => 'gender_short_unknown'.tr,
      };

  Color get badgeColor => switch (this) {
        Gender.female => AppColors.genderFemale,
        Gender.mixed => AppColors.genderMixed,
        Gender.male => AppColors.genderMale,
        Gender.unknown => AppColors.textMuted,
      };
}

extension RaceFormatting on Race {
  String get distanceLabel => '$distance m';

  /// Same string-matching seam as `CompetitionFormatting.isBeach`, applied per
  /// race so a mixed programme resolves each épreuve on its own speciality.
  bool get isBeach {
    final s = specialityLabel.toLowerCase();
    return s.contains('côtier') || s.contains('cotier');
  }

  int get defaultSpotsPerRace =>
      isBeach ? defaultCoastalSpotsPerRace : defaultPoolSpotsPerRace;

  String get genderLabel => gender.label;

  /// Combined label that mirrors the legacy RaceModel.label format.
  /// Picks French or English race name based on the active LanguageService.
  String get label {
    final isEnglish = LanguageService.to.isEnglish;
    final raceName = isEnglish ? nameEnglish : name;
    final categoriesText = categories.map((c) => c.name).join(', ');
    return '$raceName $genderLabel ($categoriesText)';
  }
}
