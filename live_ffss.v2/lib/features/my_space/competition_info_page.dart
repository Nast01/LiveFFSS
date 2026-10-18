import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/features/my_space/my_space_formatting.dart';
import 'package:live_ffss_v2/features/my_space/my_space_providers.dart';
import 'package:live_ffss_v2/features/my_space/widgets/my_space_rows.dart';
import 'package:live_ffss_v2/features/results/widgets/results_messages.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

/// Lieu, dates, organisateur, nombres d'engagés, et la liste des clubs, qui
/// ouvre l'espace de chacun (ouvert à tout le monde).
class CompetitionInfoPage extends ConsumerStatefulWidget {
  const CompetitionInfoPage({super.key, required this.competitionId});

  final int competitionId;

  @override
  ConsumerState<CompetitionInfoPage> createState() =>
      _CompetitionInfoPageState();
}

class _CompetitionInfoPageState extends ConsumerState<CompetitionInfoPage> {
  @override
  void initState() {
    super.initState();
    activateFromLink(ref, widget.competitionId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = ref.watch(competitionInfoProvider(widget.competitionId));
    final value = info.value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.mySpaceInfos)),
      body: value != null
          ? _content(context, value, l10n)
          : info.hasError
          ? ResultsMessage(
              text: l10n.mySpaceInfosError,
              onRetry: () => retryCompetitionInfo(
                ProviderScope.containerOf(context, listen: false),
                widget.competitionId,
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _content(
    BuildContext context,
    CompetitionInfo info,
    AppLocalizations l10n,
  ) {
    final competition = info.competition;
    final organizer = competition.organizer;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16 + MediaQuery.of(context).viewPadding.bottom,
      ),
      children: [
        MySpaceHeader(competition.name),
        MySpaceBox(
          children: [
            MySpaceRow(
              title: competitionPlace(competition),
              subtitle: competitionDatesLine(competition, l10n),
            ),
            if (organizer != null && organizer.isNotEmpty)
              MySpaceRow(title: l10n.mySpaceOrganizer, subtitle: organizer),
            MySpaceRow(title: competitionCountsLine(info, l10n)),
          ],
        ),
        if (info.clubs.isNotEmpty) ...[
          MySpaceHeader(l10n.mySpaceClubs),
          MySpaceBox(
            children: [
              for (final club in info.clubs)
                MySpaceRow(
                  title: club.label,
                  subtitle: clubAthletesLabel(club.athletes, l10n),
                  onTap: () => context.push(
                    Routes.mySpaceClub(widget.competitionId, club.id),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
