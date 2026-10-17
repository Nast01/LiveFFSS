import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/features/home/favorites.dart';
import 'package:live_ffss_v2/features/home/home_providers.dart';
import 'package:live_ffss_v2/features/home/home_view.dart';
import 'package:live_ffss_v2/features/home/search_provider.dart';
import 'package:live_ffss_v2/features/home/widgets/competition_row.dart';
import 'package:live_ffss_v2/features/home/widgets/filter_bar.dart';

/// La liste complète. Sans recherche : les compétitions de l'accueil, par
/// date de début ; avec « Mes favoris », tous les favoris, même anciens. Avec
/// au moins [searchMinLength] caractères : la recherche de l'API. Le filtre de
/// l'accueil s'applique dans tous les cas.
class AllCompetitionsPage extends ConsumerStatefulWidget {
  const AllCompetitionsPage({super.key});

  @override
  ConsumerState<AllCompetitionsPage> createState() =>
      _AllCompetitionsPageState();
}

class _AllCompetitionsPageState extends ConsumerState<AllCompetitionsPage> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = _query.text.trim();
    final searching = text.length >= searchMinLength;
    final filter = ref.watch(homeFilterProvider);
    // Les favoris ont leur propre liste : beaucoup sont plus anciens que la
    // fenêtre de l'accueil.
    final AsyncValue<List<CompetitionSummary>> source = searching
        ? ref.watch(searchResultsProvider(text))
        : filter == HomeFilter.favorites
        ? ref.watch(favoriteCompetitionsProvider)
        : ref
              .watch(homeCompetitionsProvider)
              .whenData(
                (list) =>
                    [...list]
                      ..sort((a, b) => a.startDate.compareTo(b.startDate)),
              );
    final favorites = ref.watch(favoritesProvider).value ?? const <int>{};

    return Scaffold(
      appBar: AppBar(title: Text(l10n.allCompetitions)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _query,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(_query.clear),
                      ),
                filled: true,
                fillColor: AppColors.surface,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: FilterBar(),
          ),
          Expanded(
            child: switch (source) {
              AsyncValue(:final value?) => _Results(
                competitions: [
                  for (final c in value)
                    if (matchesFilter(c, filter, favorites)) c,
                ],
              ),
              AsyncValue(hasError: true) => Center(child: Text(l10n.loadError)),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.competitions});

  final List<CompetitionSummary> competitions;

  @override
  Widget build(BuildContext context) {
    if (competitions.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).noCompetition,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
      ),
      itemCount: competitions.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.border),
      itemBuilder: (context, index) =>
          CompetitionRow(competition: competitions[index]),
    );
  }
}
