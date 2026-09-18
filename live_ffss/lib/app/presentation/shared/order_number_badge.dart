import 'package:flutter/material.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';

/// Le dossard d'un athlète : le numéro épinglé sur son maillot.
///
/// Rend `SizedBox.shrink()` quand l'athlète n'en a pas — une pastille « 0 »
/// dirait quelque chose de faux.
class OrderNumberBadge extends StatelessWidget {
  const OrderNumberBadge({
    super.key,
    required this.orderNumber,
    this.fontSize = 11,
  });

  final int orderNumber;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    if (orderNumber <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.orderNumberBadge,
        borderRadius: AppRadius.smRadius,
      ),
      child: Text(
        '$orderNumber',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          // Chiffres à chasse fixe sans embarquer de police : deux dossards
          // s'alignent en colonne quel que soit le nombre de chiffres.
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
