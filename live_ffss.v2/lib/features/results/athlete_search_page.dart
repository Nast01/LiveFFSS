import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/athlete_search.dart';
import 'package:live_ffss_v2/features/results/athlete_providers.dart';
import 'package:live_ffss_v2/features/results/results_formatting.dart';
import 'package:live_ffss_v2/features/results/widgets/results_messages.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

class AthleteSearchPage extends ConsumerStatefulWidget {
  const AthleteSearchPage({super.key, required this.competitionId});

  final int competitionId;

  @override
  ConsumerState<AthleteSearchPage> createState() => _AthleteSearchPageState();
}

class _AthleteSearchPageState extends ConsumerState<AthleteSearchPage> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    activateFromLink(ref, widget.competitionId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = participantsProvider(widget.competitionId);
    final participants = ref.watch(provider);
    final all = participants.value;

    final Widget results;
    if (all == null) {
      results = participants.hasError
          ? ResultsMessage(
              text: l10n.searchLoadError,
              onRetry: () => ref.invalidate(provider),
            )
          : const Center(child: CircularProgressIndicator());
    } else if (queryTooShort(_query)) {
      results = ResultsMessage(text: l10n.searchTooShort(minSearchLength));
    } else {
      final found = searchParticipants(all, _query);
      results = found.isEmpty
          ? ResultsMessage(text: l10n.searchNoResult)
          : ListView.separated(
              padding: EdgeInsets.only(
                bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
              ),
              itemCount: found.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final participant = found[index];
                final subtitle = participantSubtitle(participant);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    child: Text(participantInitials(participant)),
                  ),
                  title: Text(participantName(participant)),
                  subtitle: subtitle.isEmpty ? null : Text(subtitle),
                  // Empilée sur la recherche : le retour y ramène.
                  onTap: () => context.push(
                    Routes.resultsAthlete(widget.competitionId, participant.id),
                  ),
                );
              },
            );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.searchTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchFieldHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(child: results),
        ],
      ),
    );
  }
}
