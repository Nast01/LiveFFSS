import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:live_ffss/app/core/config/active_environment.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';

/// Le ruban « DEV », posé sur toutes les pages quand l'endpoint de
/// développement est actif — même mécanisme que
/// `debugShowCheckedModeBanner`.
///
/// Branché dans le `builder:` de `GetMaterialApp`, donc au-dessus du
/// `Navigator` : il couvre routes, dialogues et bottom sheets sans qu'aucune
/// vue ait à le savoir. Il lit [activeEnvironment] et non `AppConfig` parce
/// qu'il survit au `Get.deleteAll()` d'une bascule — voir la doc de ce
/// notifier.
class DevEnvironmentBanner extends StatelessWidget {
  const DevEnvironmentBanner({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return child;
    return ValueListenableBuilder<AppEnvironment>(
      valueListenable: activeEnvironment,
      builder: (context, environment, banneredChild) {
        if (environment != AppEnvironment.development) return banneredChild!;
        return Banner(
          message: 'DEV',
          location: BannerLocation.topEnd,
          color: AppColors.statusWaiting,
          child: banneredChild!,
        );
      },
      child: child,
    );
  }
}
