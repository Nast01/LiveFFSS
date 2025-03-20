import 'package:get/get.dart';
import 'en_us.dart';
import 'fr_fr.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'fr_FR': frFR,
      };
}
