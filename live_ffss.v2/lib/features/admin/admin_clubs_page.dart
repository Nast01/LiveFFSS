import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/features/admin/admin_providers.dart';
import 'package:live_ffss_v2/features/admin/widgets/admin_gate.dart';
import 'package:live_ffss_v2/features/my_space/my_space_formatting.dart';
import 'package:live_ffss_v2/features/my_space/widgets/my_space_rows.dart';
import 'package:live_ffss_v2/features/results/widgets/results_messages.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';
import 'package:live_ffss_v2/features/shell/space_competition.dart';

/// Les clubs engagés : chacun ouvre son espace, ou directement ses forfaits
/// déclarés.
class AdminClubsPage extends StatelessWidget {
  const AdminClubsPage({super.key, required this.competitionId});

  final int competitionId;

  @override
  Widget build(BuildContext context) => AdminGate(
    competitionId: competitionId,
    child: _AdminClubs(competitionId: competitionId),
  );
}

class _AdminClubs extends ConsumerStatefulWidget {
  const _AdminClubs({required this.competitionId});

  final int competitionId;

  @override
  ConsumerState<_AdminClubs> createState() => _AdminClubsState();
}

class _AdminClubsState extends ConsumerState<_AdminClubs> {
  @override
  void initState() {
    super.initState();
    activateFromLink(ref, widget.competitionId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = widget.competitionId;
    final state = ref.watch(adminClubsProvider(id));
    final clubs = state.value;
    final gate = resultsGate(ref.watch(spaceCompetitionProvider(id)));
    final Widget body;
    if (gate == ResultsGate.coastal) {
      body = ResultsMessage(text: l10n.coastalComingSoon);
    } else if (clubs != null) {
      body = ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [
          MySpaceBox(
            children: [
              for (final club in clubs)
                MySpaceRow(
                  title: club.label,
                  subtitle: clubAthletesLabel(club.athletes, l10n),
                  trailing: TextButton(
                    onPressed: () => context.push(
                      Routes.mySpaceClub(id, club.id, forfeits: true),
                    ),
                    child: Text(l10n.mySpaceForfeits),
                  ),
                  onTap: () => context.push(Routes.mySpaceClub(id, club.id)),
                ),
            ],
          ),
        ],
      );
    } else {
      body = switch (state.error) {
        AdminOnlyException() => ResultsMessage(text: l10n.adminOnly),
        Object() => ResultsMessage(
          text: l10n.searchLoadError,
          onRetry: () => retryAdminClubs(
            ProviderScope.containerOf(context, listen: false),
            id,
          ),
        ),
        null => const Center(child: CircularProgressIndicator()),
      };
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.mySpaceClubs)),
      body: body,
    );
  }
}
