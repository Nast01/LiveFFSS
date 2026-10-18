import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/standings.dart';
import 'package:live_ffss_v2/features/home/competition_formatting.dart';
import 'package:live_ffss_v2/features/results/results_formatting.dart';
import 'package:live_ffss_v2/features/results/results_providers.dart';
import 'package:live_ffss_v2/features/results/widgets/choice_chips_row.dart';
import 'package:live_ffss_v2/features/results/widgets/results_messages.dart';

/// Le sous-onglet Classements : clubs ou licenciés.
class StandingsView extends ConsumerStatefulWidget {
  const StandingsView({
    super.key,
    required this.competitionId,
    required this.refreshKey,
    required this.tabs,
  });

  final int competitionId;
  final GlobalKey<RefreshIndicatorState> refreshKey;

  /// Les puces Épreuves / Classements, en tête de la liste.
  final Widget tabs;

  @override
  ConsumerState<StandingsView> createState() => _StandingsViewState();
}

class _StandingsViewState extends ConsumerState<StandingsView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = standingsProvider(widget.competitionId);
    ref.listen(provider, (previous, next) {
      // Un rafraîchissement en échec garde les classements affichés.
      if (next.hasError && next.hasValue && !next.isLoading) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.refreshFailed)));
      }
    });
    final filter = ref.watch(standingsFilterProvider(widget.competitionId));
    final filters = ref.read(
      standingsFilterProvider(widget.competitionId).notifier,
    );
    final standings = ref.watch(provider);
    final value = standings.value;
    if (value == null) {
      return TabsAbove(
        tabs: widget.tabs,
        child: standings.hasError
            ? ResultsMessage(
                text: l10n.standingsLoadError,
                onRetry: () => ref.read(provider.notifier).refresh(),
              )
            : const Center(child: CircularProgressIndicator()),
      );
    }

    final incomplete = standingsIncompleteLabel(value, l10n);
    return RefreshIndicator(
      key: widget.refreshKey,
      onRefresh: _refresh,
      child: ListView(
        // Toujours défilable : sans cela, le geste de rafraîchissement ne
        // part pas sur une liste plus courte que l'écran.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [
          widget.tabs,
          const SizedBox(height: 8),
          ChoiceChipsRow<StandingsKind>(
            options: StandingsKind.values,
            selected: filter.kind,
            label: (kind) => switch (kind) {
              StandingsKind.clubs => l10n.standingsClubs,
              StandingsKind.licensees => l10n.standingsLicensees,
            },
            onSelect: filters.selectKind,
          ),
          const SizedBox(height: 12),
          ...switch (filter.kind) {
            StandingsKind.clubs => _clubs(value.clubs, l10n),
            StandingsKind.licensees => _licensees(
              value.licensees,
              filter,
              filters,
              l10n,
            ),
          },
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              standingsFooter(value, l10n),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (incomplete != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                incomplete,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.red),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    try {
      await ref
          .read(standingsProvider(widget.competitionId).notifier)
          .refresh();
    } on AppException {
      // Signalé par le `ref.listen` de build, qui garde l'affichage.
    }
  }

  Widget _empty(AppLocalizations l10n) => Padding(
    padding: const EdgeInsets.only(top: 32),
    child: Text(
      l10n.standingsEmpty,
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppColors.textSecondary),
    ),
  );

  List<Widget> _clubs(List<ClubStanding> clubs, AppLocalizations l10n) {
    if (clubs.isEmpty) return [_empty(l10n)];
    final split = splitPodium(clubs);
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final club in split.podium)
              Expanded(child: _PodiumStep(club: club)),
          ],
        ),
      ),
      if (split.rest.isNotEmpty)
        Card(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              for (final (i, club) in split.rest.indexed) ...[
                if (i > 0) const Divider(height: 1),
                _StandingTile(
                  rank: club.rank,
                  title: club.club,
                  subtitle: gapLabel(club.gapToPrevious, l10n),
                  points: l10n.standingsPoints(club.points),
                ),
              ],
            ],
          ),
        ),
    ];
  }

  List<Widget> _licensees(
    List<LicenseeStanding> licensees,
    StandingsFilter filter,
    StandingsFilterNotifier filters,
    AppLocalizations l10n,
  ) {
    final genders = licenseeGenders(licensees);
    final gender = chosenOrFirst(genders, filter.gender);
    if (gender == null) return [_empty(l10n)];
    final categories = licenseeCategories(licensees, gender);
    final category = chosenOrFirst(categories, filter.category);
    final shown = category == null
        ? const <LicenseeStanding>[]
        : licenseesOf(licensees, gender, category);
    return [
      ChoiceChipsRow<Gender>(
        options: genders,
        selected: gender,
        label: (g) => genderLabel(g, l10n),
        onSelect: filters.selectGender,
      ),
      const SizedBox(height: 8),
      ChoiceChipsRow<String>(
        options: categories,
        selected: category,
        label: (c) => c,
        onSelect: filters.selectCategory,
      ),
      if (shown.isEmpty)
        _empty(l10n)
      else
        Card(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              for (final (i, licensee) in shown.indexed) ...[
                if (i > 0) const Divider(height: 1),
                _StandingTile(
                  rank: licensee.rank,
                  title: licensee.name,
                  subtitle: licenseeSubtitle(licensee, l10n),
                  points: l10n.standingsPoints(licensee.points),
                  onTap: () => context.go(
                    Routes.resultsAthlete(
                      widget.competitionId,
                      licensee.athleteId,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
    ];
  }
}

class _PodiumStep extends StatelessWidget {
  const _PodiumStep({required this.club});

  final ClubStanding club;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Le premier plus haut que les suivants, comme sur un podium.
    final height = switch (club.rank) {
      1 => 72.0,
      2 => 56.0,
      _ => 44.0,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(
            club.club,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Container(
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: club.rank == 1 ? AppColors.yellow : AppColors.navy,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${club.rank}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: club.rank == 1 ? AppColors.navy : Colors.white,
                  ),
                ),
                Text(
                  l10n.standingsPoints(club.points),
                  style: TextStyle(
                    fontSize: 12,
                    color: club.rank == 1 ? AppColors.navy : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingTile extends StatelessWidget {
  const _StandingTile({
    required this.rank,
    required this.title,
    required this.subtitle,
    required this.points,
    this.onTap,
  });

  final int rank;
  final String title;
  final String subtitle;
  final String points;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(points, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    ),
  );
}
