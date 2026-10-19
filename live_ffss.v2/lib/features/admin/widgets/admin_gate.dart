import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/features/admin/admin_formatting.dart';
import 'package:live_ffss_v2/features/auth/admin.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
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
    // Refusé, un compte qui n'est pas admin du compte a vu ses rôles lus :
    // les suivre ici ne lit rien de plus.
    final roles = access.value == false && id != null
        ? competitionRolesProvider(id)
        : null;
    final view = adminGateView(
      access: access.value,
      loading: access.isLoading,
      rolesFailed: roles != null && ref.watch(roles).hasError,
    );
    if (view == AdminGateView.open) return child;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminTitle)),
      body: switch (view) {
        AdminGateView.loading ||
        AdminGateView.open => const Center(child: CircularProgressIndicator()),
        AdminGateView.rolesFailed => ResultsMessage(
          text: l10n.adminRolesError,
          onRetry: () => ref.invalidate(roles!),
        ),
        AdminGateView.refused => ResultsMessage(text: l10n.adminOnly),
      },
    );
  }
}
