import 'package:get/get.dart';
import 'en_US.dart';
import 'fr_FR.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'fr_FR': frFR,
      };
}
