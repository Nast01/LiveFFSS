import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/features/programme/programme_providers.dart';
import 'package:live_ffss_v2/features/programme/widgets/day_tabs.dart';
import 'package:live_ffss_v2/features/programme/widgets/meeting_card.dart';
import 'package:live_ffss_v2/features/shell/choose_competition_prompt.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

class ProgrammePage extends ConsumerWidget {
  const ProgrammePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final competition = ref.watch(currentCompetitionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (competition != null)
              Text(
                competition.name,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            Text(
              l10n.programmeTitle,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      body: competition == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: ChooseCompetitionPrompt(),
              ),
            )
          : _ProgrammeBody(competitionId: competition.id),
    );
  }
}

class _ProgrammeBody extends ConsumerWidget {
  const _ProgrammeBody({required this.competitionId});

  final int competitionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = programmeProvider(competitionId);
    ref.listen(provider, (previous, next) {
      // Un rafraîchissement en échec garde le programme : on le dit sans le
      // vider.
      if (next.hasError && next.hasValue && !next.isLoading) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.refreshFailed)));
      }
    });
    final programme = ref.watch(provider);
    final value = programme.value;

    if (value == null) {
      if (programme.hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.programmeLoadError, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(provider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    final days = programmeDays(value.meetings);
    final selected = ref.watch(selectedDayProvider(competitionId));
    final meetings = selected == null
        ? const <Meeting>[]
        : meetingsOfDay(value.meetings, selected);
    final expansion = ref.watch(meetingExpansionProvider);
    final now = ref.watch(clockProvider)();

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: ListView(
        // Toujours défilable : sans cela, le geste de rafraîchissement ne
        // part pas sur un programme plus court que l'écran.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [
          if (days.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Text(
                l10n.programmeEmpty,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          else ...[
            DayTabs(
              days: days,
              selected: selected,
              onSelect: ref
                  .read(selectedDayProvider(competitionId).notifier)
                  .select,
            ),
            const SizedBox(height: 12),
            for (final meeting in meetings)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: MeetingCard(
                  meeting: meeting,
                  expanded: isMeetingExpanded(
                    expansion,
                    meeting.id,
                    finished: meetingFinished(meeting, now),
                  ),
                  onToggle: (expanded) => ref
                      .read(meetingExpansionProvider.notifier)
                      .toggle(meeting.id, currentlyExpanded: expanded),
                  onOpen: (item) =>
                      context.go(Routes.programmeItem(competitionId, item.id)),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    final provider = programmeProvider(competitionId);
    try {
      ref.invalidate(provider);
      await ref.read(provider.future);
    } on AppException {
      // Signalé par le `ref.listen` de build, qui garde le programme affiché.
    }
  }
}
