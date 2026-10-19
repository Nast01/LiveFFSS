import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/follows/follows_providers.dart';
import 'package:live_ffss_v2/features/my_space/my_space_formatting.dart';
import 'package:live_ffss_v2/features/my_space/widgets/my_space_rows.dart';
import 'package:live_ffss_v2/features/my_space/my_space_providers.dart';
import 'package:live_ffss_v2/features/results/widgets/results_messages.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

/// Les athlètes et clubs suivis : la prochaine course de chaque athlète, tirée
/// du programme seul (`followedRacesProvider`), une étoile pour retirer.
class FollowsPage extends ConsumerStatefulWidget {
  const FollowsPage({super.key, required this.competitionId});

  final int competitionId;

  @override
  ConsumerState<FollowsPage> createState() => _FollowsPageState();
}

class _FollowsPageState extends ConsumerState<FollowsPage> {
  @override
  void initState() {
    super.initState();
    activateFromLink(ref, widget.competitionId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(followsProvider(widget.competitionId));
    final follows = state.value;
    if (follows == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.mySpaceFollows)),
        body: state.hasError
            ? ResultsMessage(
                text: l10n.mySpaceFollowsError,
                onRetry: () =>
                    ref.invalidate(followsProvider(widget.competitionId)),
              )
            : const Center(child: CircularProgressIndicator()),
      );
    }
    // Un programme illisible laisse chaque athlète sur la ligne de son club.
    final races = ref.watch(followedRacesProvider(widget.competitionId)).value;
    final notifier = ref.read(followsProvider(widget.competitionId).notifier);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.mySpaceFollows)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [
          if (follows.athletes.isNotEmpty || follows.clubs.isNotEmpty)
            MySpaceBox(
              children: [
                for (final athlete in follows.athletes)
                  MySpaceRow(
                    icon: Icons.person_outline,
                    title: athlete.name,
                    subtitle: followedAthleteLine(athlete, races, l10n),
                    onTap: () => context.push(
                      Routes.mySpaceParticipant(
                        widget.competitionId,
                        athlete.participantId,
                      ),
                    ),
                    trailing: _Star(
                      tooltip: l10n.unfollowAthlete,
                      onPressed: () =>
                          notifier.unfollowAthlete(athlete.participantId),
                    ),
                  ),
                for (final club in follows.clubs)
                  MySpaceRow(
                    icon: Icons.groups_outlined,
                    title: club.label,
                    onTap: () => context.push(
                      Routes.mySpaceClub(widget.competitionId, club.id),
                    ),
                    trailing: _Star(
                      tooltip: l10n.unfollowClub,
                      onPressed: () => notifier.toggleClub(club.id, club.label),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 12),
          Text(
            l10n.mySpaceFollowsHint,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Star extends StatelessWidget {
  const _Star({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.star, color: AppColors.yellow),
    tooltip: tooltip,
    onPressed: onPressed,
  );
}
