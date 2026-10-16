import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/home/home_providers.dart';
import 'package:live_ffss_v2/features/home/home_view.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(homeFilterProvider);
    String label(HomeFilter filter) => switch (filter) {
      HomeFilter.all => l10n.filterAll,
      HomeFilter.flatWater => l10n.filterFlatWater,
      HomeFilter.coastal => l10n.filterCoastal,
      HomeFilter.favorites => l10n.filterFavorites,
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in HomeFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label(filter)),
                selected: filter == selected,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: filter == selected
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
                onSelected: (_) =>
                    ref.read(homeFilterProvider.notifier).select(filter),
              ),
            ),
        ],
      ),
    );
  }
}
