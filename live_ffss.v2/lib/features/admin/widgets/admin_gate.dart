import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/features/auth/admin.dart';
import 'package:live_ffss_v2/features/results/widgets/results_messages.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

/// Une page de l'espace admin, montrée au compte qui y a droit
/// ([adminAccessProvider]) : un lien direct ou un changement de compte ne
/// l'ouvre pas à un autre. Ses fournisseurs refusent de toute façon.
class AdminGate extends ConsumerWidget {
  const AdminGate({super.key, this.competitionId, required this.child});

  /// Nul : la compétition active.
  final int? competitionId;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = competitionId ?? ref.watch(currentCompetitionProvider)?.id;
    final access = ref.watch(adminAccessProvider(id));
    if (access.value ?? false) return child;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminTitle)),
      body: access.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResultsMessage(text: l10n.adminOnly),
    );
  }
}
