import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_controller.dart';
import 'package:live_ffss/app/module/competitions/views/competition_detail_clubs_view.dart';
import 'package:live_ffss/app/module/competitions/views/competition_detail_points_view.dart';
import 'package:live_ffss/app/module/competitions/views/competition_detail_races_view.dart';
import 'package:live_ffss/app/presentation/modules/competitions/competition_formatting.dart';
import 'package:live_ffss/app/presentation/shared/home_wave.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

class CompetitionDetailView extends GetView<CompetitionDetailController> {
  const CompetitionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final competition = controller.competition.value;
          if (competition == null) {
            return Center(
              child: Text(
                'no_competition_selected'.tr,
                style: AppTypography.subtitle,
              ),
            );
          }
          return Column(
            children: [
              _CompetitionDetailHeader(competition: competition),
              const HomeWave(),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: Obx(() => IndexedStack(
                      index: controller.currentTabIndex.value,
                      children: const [
                        CompetitionDetailRacesView(),
                        CompetitionDetailClubsView(),
                        CompetitionDetailPointsView(),
                      ],
                    )),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CompetitionDetailHeader extends GetView<CompetitionDetailController> {
  const _CompetitionDetailHeader({required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.lg,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: Get.back,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.event_note, color: Colors.white),
                tooltip: 'programme'.tr,
                onPressed: () => Get.toNamed<void>(
                  Routes.programme,
                  arguments: competition,
                ),
              ),
              Obx(() {
                final favored =
                    controller.favoriteIds.contains(competition.id);
                return IconButton(
                  icon: Icon(
                    favored ? Icons.star : Icons.star_border,
                    color: favored ? AppColors.statusWaiting : Colors.white,
                    size: 28,
                  ),
                  onPressed: () => controller.toggleFavorite(competition.id),
                );
              }),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _HeaderThumbnail(competition: competition),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        competition.name,
                        style: AppTypography.title.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        competition.formattedDateRange,
                        style: AppTypography.body.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '🇫🇷 ${competition.location ?? 'no_location'.tr}',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.pageHorizontal,
            child: Row(
              children: [
                _DetailPill(label: 'events'.tr, index: 0),
                const SizedBox(width: AppSpacing.sm),
                _DetailPill(label: 'clubs'.tr, index: 1),
                const SizedBox(width: AppSpacing.sm),
                _DetailPill(label: 'points'.tr, index: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderThumbnail extends StatelessWidget {
  const _HeaderThumbnail({required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    final logoUrl = competition.organizerClub.logoUrl;
    if (logoUrl == null || logoUrl.isEmpty) {
      return _HeaderDateBlock(competition: competition);
    }
    return ClipRRect(
      borderRadius: AppRadius.smRadius,
      child: Image.network(
        logoUrl,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _HeaderDateBlock(competition: competition),
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : _HeaderDateBlock(competition: competition),
      ),
    );
  }
}

class _HeaderDateBlock extends StatelessWidget {
  const _HeaderDateBlock({required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.smRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            competition.formattedBeginDateMonth,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            competition.formattedDayBeginDate,
            style: AppTypography.title.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailPill extends GetView<CompetitionDetailController> {
  const _DetailPill({required this.label, required this.index});

  final String label;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.currentTabIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.statusWaiting : Colors.transparent,
            borderRadius: AppRadius.pillRadius,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.textPrimary : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      );
    });
  }
}
