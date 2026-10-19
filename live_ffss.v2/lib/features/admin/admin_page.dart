import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/features/admin/widgets/admin_gate.dart';
import 'package:live_ffss_v2/features/auth/admin.dart';
import 'package:live_ffss_v2/features/my_space/widgets/my_space_rows.dart';
import 'package:live_ffss_v2/features/settings/server_switch.dart';
import 'package:live_ffss_v2/features/shell/choose_competition_prompt.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

/// L'espace admin : le serveur, la supervision de la compétition active et
/// le diagnostic.
class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) => const AdminGate(child: _AdminContent());
}

class _AdminContent extends ConsumerWidget {
  const _AdminContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final competition = ref.watch(currentCompetitionProvider);
    final environment = ref.watch(appConfigProvider).environment;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminTitle)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [
          // Le choix du serveur vit dans les Préférences, montré dès qu'un
          // admin du compte s'est connecté : l'admin d'une seule compétition
          // ne l'a pas.
          if (ref.watch(isAdminProvider)) ...[
            MySpaceHeader(l10n.serverTitle),
            MySpaceBox(
              children: [
                MySpaceRow(
                  icon: Icons.dns_outlined,
                  title: serverLabel(environment, l10n),
                  subtitle: l10n.adminServerHint,
                  onTap: () => context.go(Routes.mySpace),
                ),
              ],
            ),
          ],
          MySpaceHeader(l10n.adminCompetition),
          if (competition == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: ChooseCompetitionPrompt(),
            )
          else ...[
            MySpaceBox(
              children: [
                MySpaceRow(
                  title: competition.name,
                  icon: Icons.emoji_events_outlined,
                ),
                MySpaceRow(
                  icon: Icons.gavel_outlined,
                  title: l10n.adminDecisions,
                  subtitle: l10n.officialDecisionsSubtitle,
                  onTap: () =>
                      context.go(Routes.adminDecisions(competition.id)),
                ),
                MySpaceRow(
                  icon: Icons.fact_check_outlined,
                  title: l10n.adminDataCheck,
                  subtitle: l10n.adminDataCheckSubtitle,
                  onTap: () =>
                      context.go(Routes.adminDataCheck(competition.id)),
                ),
              ],
            ),
            MySpaceHeader(l10n.adminOpenSpace),
            MySpaceBox(
              children: [
                MySpaceRow(
                  icon: Icons.groups_outlined,
                  title: l10n.mySpaceClubs,
                  subtitle: l10n.adminClubsSubtitle,
                  onTap: () => context.go(Routes.adminClubs(competition.id)),
                ),
                // La recherche et sa fiche vivent dans l'onglet Résultats.
                MySpaceRow(
                  icon: Icons.search,
                  title: l10n.searchTitle,
                  onTap: () => context.go(Routes.resultsSearch(competition.id)),
                ),
                MySpaceRow(
                  icon: Icons.timer_outlined,
                  title: l10n.mySpaceOfficial,
                  subtitle: l10n.mySpaceOfficialSubtitle,
                  onTap: () =>
                      context.push(Routes.mySpaceOfficial(competition.id)),
                ),
              ],
            ),
          ],
          MySpaceHeader(l10n.adminDiagnostic),
          MySpaceBox(
            children: [
              MySpaceRow(
                icon: Icons.swap_vert,
                title: l10n.networkLogTitle,
                onTap: () => context.go(Routes.adminNetworkLog),
              ),
              // Sur la compétition active : sans elle, l'invite à en choisir
              // une est déjà montrée plus haut.
              if (competition != null)
                MySpaceRow(
                  icon: Icons.build_outlined,
                  title: l10n.adminMaintenance,
                  subtitle: l10n.adminMaintenanceSubtitle,
                  onTap: () =>
                      context.go(Routes.adminMaintenance(competition.id)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
