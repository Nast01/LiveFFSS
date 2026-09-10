import 'package:flutter/material.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';

/// Le voile posé pendant un envoi au serveur qui ne doit pas être interrompu :
/// pousser un déroulement, créer les parties manquantes. Il assombrit l'écran
/// et prend les taps, parce qu'un second envoi lancé pendant le premier
/// dédoublerait ce que FFSS enregistre.
///
/// À poser dans un [Stack], d'où le [Positioned.fill].
class ProgressOverlay extends StatelessWidget {
  const ProgressOverlay({
    super.key,
    required this.message,
    this.progress,
  });

  /// Ce que l'envoi est en train de faire, déjà traduit.
  final String message;

  /// Le compteur d'avancement, quand l'appelant en tient un. Il reste chez
  /// l'appelant plutôt que de passer par deux entiers : c'est un `Obx` sur les
  /// `Rx` du contrôleur, et le rebâtir ici ferait redessiner tout le voile à
  /// chaque item envoyé.
  final Widget? progress;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.35),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.mdRadius,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.md),
                Text(message, style: AppTypography.body),
                if (progress != null) progress!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
