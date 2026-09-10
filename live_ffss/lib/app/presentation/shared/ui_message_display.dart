import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

/// Comment une vue montre les messages de son contrôleur.
///
/// Séparé de [UiMessage] à dessein : les contrôleurs construisent le type,
/// les vues seules l'affichent — c'est la même frontière que « les contrôleurs
/// stockent des clés, les vues traduisent ».
extension UiMessageDisplay<T extends StatefulWidget> on State<T> {
  /// Affiche chaque message poussé sur [message] dans la barre de cet écran.
  ///
  /// Rend le [Worker] : c'est à l'État qui l'a posé de le libérer dans son
  /// `dispose`. Un contrôleur permanent survit à sa vue, et sans cela il
  /// continuerait de pousser des messages vers un `context` démonté.
  Worker showUiMessages(Rx<UiMessage?> message) {
    return ever<UiMessage?>(message, (m) {
      if (m == null || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(m.text),
        backgroundColor:
            m is UiMessageError ? AppColors.statusError : AppColors.primary,
      ));
    });
  }
}
