import 'package:flutter/material.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';

/// La place d'un espace pas encore construit (athlète, club, officiel) : les
/// cartes de Mon espace y mènent déjà.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabMySpace)),
      body: Center(
        child: Text(
          l10n.mySpaceComingSoon,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
