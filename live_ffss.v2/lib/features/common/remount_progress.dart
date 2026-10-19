import 'dart:async';

import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';

/// Lance [remount] (changement de serveur, rechargement forcé) derrière un
/// dialogue qui ne se ferme pas : une saisie en cours d'envoi peut le faire
/// attendre jusqu'à 20 s, et l'écran ne doit pas sembler figé. Refusé
/// ([remount] rend faux), un message le dit et l'app reste telle quelle.
/// Les exceptions de [remount] remontent à l'appelant.
Future<void> remountWithProgress(
  BuildContext context,
  Future<bool> Function() remount,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context, rootNavigator: true);
  var open = true;
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(l10n.remountWaiting)),
            ],
          ),
        ),
      ),
    ).whenComplete(() => open = false),
  );
  try {
    if (!await remount()) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.remountBusy)));
    }
  } finally {
    // Remontée, l'app jette cette page avec son dialogue à l'image suivante.
    if (open && navigator.mounted) navigator.pop();
  }
}
