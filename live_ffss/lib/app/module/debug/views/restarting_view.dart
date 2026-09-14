import 'package:flutter/material.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';

/// L'écran affiché pendant qu'une bascule d'environnement reconstruit
/// l'injection de dépendances.
///
/// Volontairement sans binding et sans contrôleur : sa seule raison d'être est
/// qu'aucune vue vivante n'exécute un `Get.find` entre le `Get.deleteAll()` et
/// le `InitialBinding.register()` d'[AppRestart.switchTo].
class RestartingView extends StatelessWidget {
  const RestartingView({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: LoadingIndicator(),
      );
}
