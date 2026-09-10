import 'package:flutter/foundation.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';

/// L'environnement actif, tenu hors de GetX délibérément.
///
/// Le ruban « DEV » vit dans le `builder:` de `GetMaterialApp`, donc au-dessus
/// du `Navigator` : il survit à la bascule, qui détruit et reconstruit tout le
/// conteneur d'injection sous lui. Un `Get.find<AppConfig>()` y lèverait
/// pendant la fenêtre de reconstruction, et une lecture ponctuelle resterait
/// figée sur l'ancienne valeur puisque `Get.offAllNamed` change la pile de
/// routes, pas le `builder`. Un ValueNotifier règle les deux.
///
/// C'est le seul état mutable global du dépôt ; il l'est parce qu'il doit
/// survivre à `Get.deleteAll()`.
final ValueNotifier<AppEnvironment> activeEnvironment =
    ValueNotifier<AppEnvironment>(AppEnvironment.production);
