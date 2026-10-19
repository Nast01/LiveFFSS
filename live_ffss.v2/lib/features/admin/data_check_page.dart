import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/admin/admin_formatting.dart';
import 'package:live_ffss_v2/features/admin/data_check_providers.dart';
import 'package:live_ffss_v2/features/admin/widgets/admin_gate.dart';
import 'package:live_ffss_v2/features/my_space/widgets/my_space_rows.dart';
import 'package:live_ffss_v2/features/results/widgets/results_messages.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

/// Ce que l'app écarte ou n'a pas pu lire de la compétition, par sorte, avec
/// sa conséquence dans l'app.
class DataCheckPage extends StatelessWidget {
  const DataCheckPage({super.key, required this.competitionId});

  final int competitionId;

  @override
  Widget build(BuildContext context) => AdminGate(
    competitionId: competitionId,
    child: _DataCheck(competitionId: competitionId),
  );
}

class _DataCheck extends ConsumerStatefulWidget {
  const _DataCheck({required this.competitionId});

  final int competitionId;

  @override
  ConsumerState<_DataCheck> createState() => _DataCheckState();
}

class _DataCheckState extends ConsumerState<_DataCheck> {
  @override
  void initState() {
    super.initState();
    activateFromLink(ref, widget.competitionId);
  }

  DataCheckNotifier get _notifier =>
      ref.read(dataCheckProvider(widget.competitionId).notifier);

  Future<void> _refresh() => _notifier.refresh();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(dataCheckProvider(widget.competitionId));
    final value = async.value;
    final Widget body;
    if (async.error is AdminOnlyException) {
      // Une déconnexion refuse aussitôt : l'ancien contrôle, gardé dans
      // l'état, ne doit plus se voir.
      body = ResultsMessage(text: l10n.adminOnly);
    } else if (async.isLoading) {
      // Une relecture complète prend du temps : l'ancien contrôle ne doit
      // pas passer pour le nouveau.
      body = const Center(child: CircularProgressIndicator());
    } else if (value == null) {
      body = switch (async.error) {
        AdminOnlyException() => ResultsMessage(text: l10n.adminOnly),
        _ => ResultsMessage(text: l10n.dataCheckError, onRetry: _refresh),
      };
    } else if (value.coastal) {
      body = ResultsMessage(text: l10n.coastalComingSoon);
    } else {
      body = _content(value, l10n);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDataCheck),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.resultsRefresh,
            onPressed: async.isLoading || (value?.busy ?? false)
                ? null
                : _refresh,
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _content(DataCheck value, AppLocalizations l10n) {
    final groups = groupDataIssues(value.issues);
    return RefreshIndicator(
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
          Text(l10n.dataCheckSeriesCost(value.seriesReads)),
          MySpaceHeader(l10n.dataCheckOnDemand),
          MySpaceBox(
            children: [
              _StepRow(
                icon: Icons.emoji_events_outlined,
                title: l10n.dataCheckResultsAction,
                step: value.results,
                cost: l10n.dataCheckResultsCost(value.resultReads),
                onTap: value.busy || value.resultReads == 0
                    ? null
                    : _notifier.checkResults,
              ),
              _StepRow(
                icon: Icons.view_week_outlined,
                title: l10n.dataCheckPlacesAction,
                step: value.places,
                cost: l10n.dataCheckPlacesCost(value.placeReads),
                onTap: value.busy || value.placeReads == 0
                    ? null
                    : _notifier.checkPlaces,
              ),
            ],
          ),
          if (groups.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: ResultsMessage(text: l10n.dataCheckNone),
            ),
          for (final group in groups) ...[
            MySpaceHeader(
              '${dataIssueTitle(group.kind, l10n)} (${group.issues.length})',
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                dataIssueConsequence(group.kind, l10n),
                style: const TextStyle(color: AppColors.red),
              ),
            ),
            if (group.issues.any(
              (issue) => dataIssueWhere(issue, l10n).isNotEmpty,
            ))
              MySpaceBox(
                children: [
                  for (final issue in group.issues)
                    MySpaceRow(title: dataIssueWhere(issue, l10n)),
                ],
              ),
          ],
        ],
      ),
    );
  }
}

/// Une étape coûteuse du contrôle : son coût, puis son avancement.
class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.icon,
    required this.title,
    required this.step,
    required this.cost,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final DataCheckStep step;
  final String cost;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => MySpaceRow(
    icon: icon,
    title: title,
    subtitle: dataCheckStepSubtitle(step, cost, AppLocalizations.of(context)),
    trailing: step == DataCheckStep.running
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : null,
    onTap: onTap,
  );
}
