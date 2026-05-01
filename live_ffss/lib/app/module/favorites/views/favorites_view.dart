import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/module/favorites/controllers/favorites_controller.dart';
import 'package:live_ffss/app/presentation/shared/competition_card.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/home_wave.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _FavoritesHeader(),
            const HomeWave(),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Obx(() {
                final hasAnyCompetitions = controller.competitions.isNotEmpty;
                if (controller.isLoading.value && !hasAnyCompetitions) {
                  return const LoadingIndicator();
                }
                if (controller.hasError.value && !hasAnyCompetitions) {
                  return ErrorState(
                    message: 'error_occured'.tr,
                    onRetry: controller.retry,
                  );
                }
                final items = controller.favoriteCompetitions;
                if (items.isEmpty) {
                  return EmptyState(
                    icon: Icons.star_border,
                    title: 'no_favorites_yet'.tr,
                  );
                }
                return ListView.separated(
                  padding: AppSpacing.pageHorizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) {
                    final competition = items[i];
                    return Obx(() => CompetitionCard(
                          competition: competition,
                          isFavorite: controller.favoriteIds
                              .contains(competition.id),
                          onTap: () => controller
                              .navigateToCompetitionDetails(competition),
                          onToggleFavorite: () =>
                              controller.toggleFavorite(competition.id),
                        ));
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Center(
        child: Text(
          'favorites'.tr,
          style: AppTypography.title.copyWith(
            color: Colors.white,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
