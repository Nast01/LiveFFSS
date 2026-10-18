import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/now_running.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/my_space/my_space_formatting.dart';
import 'package:live_ffss_v2/features/my_space/official_space_providers.dart';
import 'package:live_ffss_v2/features/my_space/widgets/my_space_rows.dart';
import 'package:live_ffss_v2/features/officiel/entry_view.dart';
import 'package:live_ffss_v2/features/officiel/outbox_service.dart';
import 'package:live_ffss_v2/features/programme/programme_formatting.dart';
import 'package:live_ffss_v2/features/programme/programme_providers.dart';
import 'package:live_ffss_v2/features/results/results_formatting.dart';
import 'package:live_ffss_v2/features/results/widgets/results_messages.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

/// L'espace officiel : la série en cours et sa saisie, les saisies du
/// compte, puis ce qui se lit à la demande (séries à saisir, DQ et
/// forfaits) et les officiels.
class OfficialSpacePage extends ConsumerStatefulWidget {
  const OfficialSpacePage({super.key, required this.competitionId});

  final int competitionId;

  @override
  ConsumerState<OfficialSpacePage> createState() => _OfficialSpacePageState();
}

class _OfficialSpacePageState extends ConsumerState<OfficialSpacePage> {
  @override
  void initState() {
    super.initState();
    activateFromLink(ref, widget.competitionId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = widget.competitionId;
    final programme = ref.watch(programmeProvider(id)).value;
    final entries = myEntries(
      ref.watch(outboxProvider),
      ref.watch(sessionProvider).value?.label,
      id,
      ref.watch(clockProvider)(),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.officialSpaceTitle)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [
          _QuickAccessCard(competitionId: id),
          MySpaceHeader(l10n.officialMyEntries),
          MySpaceBox(
            children: [
              if (entries.isEmpty) MySpaceRow(title: l10n.officialNoEntries),
              for (final op in [
                ...entries.rejected,
                ...entries.pending,
                ...entries.sent,
              ])
                _EntryRow(competitionId: id, op: op, programme: programme),
            ],
          ),
          MySpaceHeader(l10n.officialCompetition),
          MySpaceBox(
            children: [
              MySpaceRow(
                icon: Icons.edit_note,
                title: l10n.officialHeatsToEnter,
                subtitle: l10n.officialHeatsToEnterSubtitle,
                onTap: () => context.push(Routes.mySpaceHeatsToEnter(id)),
              ),
              MySpaceRow(
                icon: Icons.gavel,
                title: l10n.officialDecisions,
                subtitle: l10n.officialDecisionsSubtitle,
                onTap: () => context.push(Routes.mySpaceDecisions(id)),
              ),
              MySpaceRow(
                icon: Icons.groups_outlined,
                title: l10n.mySpaceOfficials,
                subtitle: l10n.mySpaceOfficialsSubtitle,
                onTap: () => context.push(Routes.mySpaceOfficials(id)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends ConsumerWidget {
  const _QuickAccessCard({required this.competitionId});

  final int competitionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(officialQuickAccessProvider(competitionId));
    final access = async.value;
    final route = quickEntryRoute(
      access,
      competitionId,
      canEnter: ref.watch(canEnterProvider(competitionId)),
    );
    final Widget content;
    if (access == null) {
      content = async.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Text(
              async.hasError
                  ? l10n.officialHeatsError
                  : l10n.officialNothingRunning,
              style: const TextStyle(color: Colors.white70),
            );
    } else {
      final following = access.following;
      content = Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  access.current.kind == NowRunningKind.now
                      ? l10n.nowRunning
                      : l10n.nextUp,
                  style: const TextStyle(
                    color: AppColors.yellow,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  officialHeatTitle((
                    item: access.item,
                    heat: access.current.heat,
                  ), l10n),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (following != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    followingHeatLabel(following, l10n),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
          if (route != null) ...[
            const SizedBox(width: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: AppColors.navy,
              ),
              onPressed: () => context.push(route),
              child: Text(l10n.enterResults),
            ),
          ],
        ],
      );
    }
    return Card(
      color: AppColors.navy,
      margin: EdgeInsets.zero,
      child: Padding(padding: const EdgeInsets.all(16), child: content),
    );
  }
}

/// Une saisie du compte : refusée, avec Réessayer (si un nouvel essai a une
/// chance) et Ignorer ; toucher la ligne rouvre la saisie de sa série.
class _EntryRow extends ConsumerWidget {
  const _EntryRow({
    required this.competitionId,
    required this.op,
    required this.programme,
  });

  final int competitionId;
  final OutboxOperation op;
  final Programme? programme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final at = entrySeries(programme, op);
    final rejected = op.state == OutboxState.rejected;
    return MySpaceRow(
      title: at == null
          ? l10n.officialUnknownSeries
          : officialHeatTitle(at, l10n),
      subtitle: myEntryLine(op, l10n),
      trailing: rejected
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canRetryRejection(op))
                  TextButton(
                    onPressed: () => _act(
                      context,
                      () => ref.read(outboxProvider.notifier).retry(op.id),
                    ),
                    child: Text(l10n.retry),
                  ),
                TextButton(
                  onPressed: () => _act(
                    context,
                    () => ref.read(outboxProvider.notifier).dismiss(op.id),
                  ),
                  child: Text(l10n.entryDismiss),
                ),
              ],
            )
          : null,
      onTap: at == null
          ? null
          : () => context.push(officialEntryRoute(competitionId, at)),
    );
  }

  Future<void> _act(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      await action();
    } on AppException {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.entryNotPersisted)));
      }
    }
  }
}

/// Les séries terminées sans chrono ni temps, lues à l'ouverture de la page
/// et par le geste tirer.
class HeatsToEnterPage extends ConsumerStatefulWidget {
  const HeatsToEnterPage({super.key, required this.competitionId});

  final int competitionId;

  @override
  ConsumerState<HeatsToEnterPage> createState() => _HeatsToEnterPageState();
}

class _HeatsToEnterPageState extends ConsumerState<HeatsToEnterPage> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    activateFromLink(ref, widget.competitionId);
  }

  Future<void> _refresh() => refreshHeatsToEnter(
    ProviderScope.containerOf(context, listen: false),
    widget.competitionId,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = widget.competitionId;
    final async = ref.watch(heatsToEnterProvider(id));
    final value = async.value;
    final canEnter = ref.watch(canEnterProvider(id));
    final Widget body;
    if (value == null) {
      body = async.hasError
          ? ResultsMessage(text: l10n.officialHeatsError, onRetry: _refresh)
          : const Center(child: CircularProgressIndicator());
    } else {
      body = RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            16 + MediaQuery.of(context).viewPadding.bottom,
          ),
          children: [
            if (value.unread > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  l10n.officialHeatsUnread(value.unread),
                  style: const TextStyle(color: AppColors.red),
                ),
              ),
            if (value.heats.isEmpty)
              ResultsMessage(text: l10n.officialHeatsToEnterEmpty)
            else
              MySpaceBox(
                children: [
                  for (final at in value.heats)
                    MySpaceRow(
                      title: officialHeatTitle(at, l10n),
                      subtitle: timeLabel(at.heat.plannedStart),
                      onTap: canEnter
                          ? () => context.push(officialEntryRoute(id, at))
                          : null,
                    ),
                ],
              ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.officialHeatsToEnter),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.resultsRefresh,
            onPressed: value == null
                ? null
                : () => _refreshKey.currentState?.show(),
          ),
        ],
      ),
      body: body,
    );
  }
}

/// Les DQ et forfaits publiés, par épreuve, et ceux du compte encore en
/// file. Lus à l'ouverture de la page et par le geste tirer.
class OfficialDecisionsPage extends ConsumerStatefulWidget {
  const OfficialDecisionsPage({super.key, required this.competitionId});

  final int competitionId;

  @override
  ConsumerState<OfficialDecisionsPage> createState() =>
      _OfficialDecisionsPageState();
}

class _OfficialDecisionsPageState extends ConsumerState<OfficialDecisionsPage> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    activateFromLink(ref, widget.competitionId);
  }

  Future<void> _refresh() => refreshOfficialDecisions(
    ProviderScope.containerOf(context, listen: false),
    widget.competitionId,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = widget.competitionId;
    final async = ref.watch(officialDecisionsProvider(id));
    final value = async.value;
    final queued = queuedDecisions(
      ref.watch(outboxProvider),
      ref.watch(sessionProvider).value?.label,
      id,
    );
    final programme = ref.watch(programmeProvider(id)).value;
    final Widget body;
    if (value == null) {
      body = async.hasError
          ? ResultsMessage(text: l10n.officialDecisionsError, onRetry: _refresh)
          : const Center(child: CircularProgressIndicator());
    } else {
      body = RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16 + MediaQuery.of(context).viewPadding.bottom,
          ),
          children: [
            if (value.unreadEvents > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  l10n.officialDecisionsUnread(value.unreadEvents),
                  style: const TextStyle(color: AppColors.red),
                ),
              ),
            if (queued.isNotEmpty) ...[
              MySpaceHeader(l10n.officialQueued),
              MySpaceBox(
                children: [
                  for (final op in queued)
                    MySpaceRow(
                      title: queuedDecisionTitle(op, value, programme, l10n),
                      subtitle: myEntryLine(op, l10n),
                    ),
                ],
              ),
            ],
            if (value.events.isEmpty && queued.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: ResultsMessage(text: l10n.officialDecisionsEmpty),
              ),
            for (final event in value.events) ...[
              MySpaceHeader(athleteRaceTitle(event.event, l10n)),
              MySpaceBox(
                children: [
                  for (final row in event.rows)
                    _DecisionRow(
                      names: resultNames(
                        row.result,
                        relay: event.event.isRelay,
                      ),
                      label: resultLabel(row.result),
                      series: row.series.heat.name,
                    ),
                ],
              ),
            ],
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.officialDecisions),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.resultsRefresh,
            onPressed: value == null
                ? null
                : () => _refreshKey.currentState?.show(),
          ),
        ],
      ),
      body: body,
    );
  }
}

class _DecisionRow extends StatelessWidget {
  const _DecisionRow({
    required this.names,
    required this.label,
    required this.series,
  });

  final ({String title, String subtitle}) names;
  final ResultLabel label;
  final String series;

  @override
  Widget build(BuildContext context) => MySpaceRow(
    title: names.title,
    subtitle: [
      names.subtitle,
      series,
    ].where((part) => part.isNotEmpty).join(' · '),
    trailing: ResultText(label: label),
  );
}
