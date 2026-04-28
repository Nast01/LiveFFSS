import 'package:get/get.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/race.dart';

extension RaceFormatting on Race {
  String get distanceLabel => '$distance m';

  String get genderLabel => switch (gender) {
        Gender.female => 'women'.tr,
        Gender.mixed => 'mixed'.tr,
        Gender.male => 'men'.tr,
        Gender.unknown => 'men'.tr,
      };

  /// Combined label that mirrors the legacy RaceModel.label format.
  /// Picks French or English race name based on the active LanguageService.
  String get label {
    final isEnglish = LanguageService.to.isEnglish;
    final raceName = isEnglish ? nameEnglish : name;
    final categoriesText = categories.map((c) => c.name).join(', ');
    return '$raceName $genderLabel ($categoriesText)';
  }
}
