import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/home/home_providers.dart';
import 'package:live_ffss_v2/features/home/home_view.dart';
import 'package:live_ffss_v2/features/home/widgets/competition_section.dart';
import 'package:live_ffss_v2/features/home/widgets/filter_bar.dart';
import 'package:live_ffss_v2/features/home/widgets/home_header.dart';
import 'package:live_ffss_v2/features/home/widgets/live_carousel.dart';
import 'package:live_ffss_v2/features/home/widgets/search_entry.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    ref.listen(homeCompetitionsProvider, (previous, next) {
      // Un rafraîchissement en échec garde la liste : on le dit sans la vider.
      if (next.hasError && next.hasValue && !next.isLoading) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.refreshFailed)));
      }
    });
    final competitions = ref.watch(homeCompetitionsProvider);
    final view = ref.watch(homeViewProvider);

    final Widget body;
    if (view != null) {
      body = RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: _HomeContent(view: view),
      );
    } else if (competitions.hasError) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.loadError, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(homeCompetitionsProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    } else {
      body = const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          const HomeHeader(),
          Expanded(child: body),
        ],
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    try {
      ref.invalidate(homeCompetitionsProvider);
      await ref.read(homeCompetitionsProvider.future);
    } on AppException {
      // Signalé par le `ref.listen` de build, qui garde la liste affichée.
    }
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.view});

  final HomeView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      // Toujours défilable : sans cela, le geste de rafraîchissement ne
      // part pas sur un accueil plus court que l'écran.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewPadding.bottom,
      ),
      children: [
        const SearchEntry(),
        const SizedBox(height: 12),
        const FilterBar(),
        const SizedBox(height: 16),
        if (view.live.isNotEmpty) ...[
          LiveCarousel(competitions: view.live),
          const SizedBox(height: 16),
        ],
        if (view.upcomingCount > 0) ...[
          CompetitionSection(
            title: l10n.upcoming,
            competitions: view.upcoming,
            action: TextButton(
              onPressed: () => context.go(Routes.allCompetitions),
              child: Text(
                l10n.seeAll,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.blue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (view.recent.isNotEmpty)
          CompetitionSection(
            title: l10n.recentlyFinished,
            competitions: view.recent,
          ),
        if (view.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Text(
              l10n.noCompetition,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }
}
