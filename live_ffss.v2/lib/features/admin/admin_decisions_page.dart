import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/admin/admin_formatting.dart';
import 'package:live_ffss_v2/features/admin/admin_providers.dart';
import 'package:live_ffss_v2/features/admin/widgets/admin_gate.dart';
import 'package:live_ffss_v2/features/my_space/my_space_formatting.dart';
import 'package:live_ffss_v2/features/my_space/official_space_providers.dart';
import 'package:live_ffss_v2/features/my_space/widgets/my_space_rows.dart';
import 'package:live_ffss_v2/features/results/results_formatting.dart';
import 'package:live_ffss_v2/features/results/widgets/results_messages.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';
import 'package:live_ffss_v2/features/shell/space_competition.dart';

/// Les DQ et forfaits publiés de tous les clubs, filtrables par club et par
/// épreuve ; pour un club choisi, ses forfaits déclarés s'ouvrent dans son
/// espace.
class AdminDecisionsPage extends StatelessWidget {
  const AdminDecisionsPage({super.key, required this.competitionId});

  final int competitionId;

  @override
  Widget build(BuildContext context) => AdminGate(
    competitionId: competitionId,
    child: _AdminDecisions(competitionId: competitionId),
  );
}

class _AdminDecisions extends ConsumerStatefulWidget {
  const _AdminDecisions({required this.competitionId});

  final int competitionId;

  @override
  ConsumerState<_AdminDecisions> createState() => _AdminDecisionsState();
}

class _AdminDecisionsState extends ConsumerState<_AdminDecisions> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  String? _club;
  int? _eventId;

  @override
  void initState() {
    super.initState();
    activateFromLink(ref, widget.competitionId);
  }

  Future<void> _refresh() => refreshAdminDecisions(
    ProviderScope.containerOf(context, listen: false),
    widget.competitionId,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = widget.competitionId;
    final async = ref.watch(adminDecisionsProvider(id));
    final value = async.value;
    final gate = resultsGate(ref.watch(spaceCompetitionProvider(id)));
    final Widget body;
    if (gate == ResultsGate.coastal) {
      body = ResultsMessage(text: l10n.coastalComingSoon);
    } else if (value == null) {
      body = switch (async.error) {
        AdminOnlyException() => ResultsMessage(text: l10n.adminOnly),
        Object() => ResultsMessage(
          text: l10n.officialDecisionsError,
          onRetry: _refresh,
        ),
        null => const Center(child: CircularProgressIndicator()),
      };
    } else {
      body = _content(value, l10n);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDecisions),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.resultsRefresh,
            onPressed: value == null || gate == ResultsGate.coastal
                ? null
                : () => _refreshKey.currentState?.show(),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _content(OfficialDecisions value, AppLocalizations l10n) {
    final clubs = decisionClubs(value);
    final events = decisionEvents(value);
    // Un filtre qui ne correspond plus à rien (relu depuis) est oublié.
    final club = clubs.contains(_club) ? _club : null;
    final eventId = events.any((e) => e.id == _eventId) ? _eventId : null;
    final shown = filterDecisions(value.events, club: club, eventId: eventId);
    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [
          if (value.unreadEvents > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.officialDecisionsUnread(value.unreadEvents),
                style: const TextStyle(color: AppColors.red),
              ),
            ),
          if (value.events.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: ResultsMessage(text: l10n.officialDecisionsEmpty),
            )
          else ...[
            DropdownButton<String?>(
              isExpanded: true,
              value: club,
              items: [
                DropdownMenuItem(child: Text(l10n.adminAllClubs)),
                for (final label in clubs)
                  DropdownMenuItem(value: label, child: Text(label)),
              ],
              onChanged: (label) => setState(() => _club = label),
            ),
            DropdownButton<int?>(
              isExpanded: true,
              value: eventId,
              items: [
                DropdownMenuItem(child: Text(l10n.adminAllEvents)),
                for (final event in events)
                  DropdownMenuItem(
                    value: event.id,
                    child: Text(athleteRaceTitle(event, l10n)),
                  ),
              ],
              onChanged: (id) => setState(() => _eventId = id),
            ),
            if (club != null)
              _ClubForfeitsRow(competitionId: widget.competitionId, club: club),
            if (shown.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: ResultsMessage(text: l10n.adminFilteredEmpty),
              ),
            for (final event in shown) ...[
              MySpaceHeader(athleteRaceTitle(event.event, l10n)),
              MySpaceBox(
                children: [
                  for (final row in event.rows)
                    _DecisionRow(
                      names: decisionNames(row, event.event),
                      label: resultLabel(row.result),
                    ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Les forfaits déclarés d'un club, lus sur les places : dans son espace,
/// à l'onglet Forfaits, plutôt qu'en double ici. Son id vient des clubs
/// engagés, lus seulement quand un club est choisi.
class _ClubForfeitsRow extends ConsumerWidget {
  const _ClubForfeitsRow({required this.competitionId, required this.club});

  final int competitionId;
  final String club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubs = ref.watch(adminClubsProvider(competitionId)).value;
    final clubId = clubs == null ? null : clubIdOf(clubs, club);
    if (clubId == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: MySpaceBox(
        children: [
          MySpaceRow(
            icon: Icons.flag_outlined,
            title: AppLocalizations.of(context).adminClubForfeits,
            subtitle: club,
            onTap: () => context.push(
              Routes.mySpaceClub(competitionId, clubId, forfeits: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionRow extends StatelessWidget {
  const _DecisionRow({required this.names, required this.label});

  final ({String title, String subtitle}) names;
  final ResultLabel label;

  @override
  Widget build(BuildContext context) => MySpaceRow(
    title: names.title,
    subtitle: names.subtitle,
    trailing: ResultText(label: label),
  );
}
