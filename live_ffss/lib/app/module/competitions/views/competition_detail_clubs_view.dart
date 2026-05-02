import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/referee.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_clubs_controller.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';

class CompetitionDetailClubsView
    extends GetView<CompetitionDetailClubsController> {
  const CompetitionDetailClubsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingIndicator();
      }
      if (controller.hasError.value) {
        return ErrorState(
          message: 'error_occured'.tr,
          onRetry: () =>
              controller.loadClubs(controller.competition.value?.id ?? 0),
        );
      }
      if (controller.filteredClubs.isEmpty) {
        return EmptyState(
          icon: Icons.group_off,
          title: 'no_clubs_found'.tr,
        );
      }
      return RefreshIndicator(
        onRefresh: () =>
            controller.loadClubs(controller.competition.value?.id ?? 0),
        child: ListView.separated(
          padding: AppSpacing.pageHorizontal,
          itemCount: controller.filteredClubs.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) => _ClubCard(club: controller.filteredClubs[i]),
        ),
      );
    });
  }
}

class _ClubCard extends StatelessWidget {
  const _ClubCard({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.smRadius,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
          leading: _ClubThumbnail(club: club),
          title: Text(
            club.name,
            style: AppTypography.title.copyWith(fontSize: 14),
          ),
          subtitle: Text(
            'athletes_and_referees'.trParams({
              'athleteCount': '${club.athletes.length}',
              'refereeCount': '${club.referees.length}',
            }),
            style: AppTypography.caption,
          ),
          children: [
            if (club.athletes.isNotEmpty) ...[
              const _SectionLabel(
                label: 'athletes_upper',
                color: AppColors.statusFinished,
              ),
              ...club.athletes.map(_AthleteTile.new),
            ],
            if (club.referees.isNotEmpty) ...[
              const _SectionLabel(
                label: 'referees_upper',
                color: AppColors.statusWaiting,
              ),
              ...club.referees.map(_RefereeTile.new),
            ],
          ],
        ),
      ),
    );
  }
}

class _ClubThumbnail extends StatelessWidget {
  const _ClubThumbnail({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final logoUrl = club.logoUrl;
    if (logoUrl == null || logoUrl.isEmpty) {
      return _ClubThumbnailFallback();
    }
    return ClipRRect(
      borderRadius: AppRadius.smRadius,
      child: Image.network(
        logoUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _ClubThumbnailFallback(),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _ClubThumbnailFallback(),
      ),
    );
  }
}

class _ClubThumbnailFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.smRadius,
      ),
      child: const Icon(
        Icons.groups,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.tr,
          style: AppTypography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AthleteTile extends StatelessWidget {
  const _AthleteTile(this.athlete);

  final Athlete athlete;

  @override
  Widget build(BuildContext context) {
    return _LicenseeRow(
      icon: Icons.pool,
      iconColor: AppColors.statusFinished,
      name: '${athlete.firstName} ${athlete.lastName}',
      badgeLabel: 'athlete_upper',
    );
  }
}

class _RefereeTile extends StatelessWidget {
  const _RefereeTile(this.referee);

  final Referee referee;

  @override
  Widget build(BuildContext context) {
    return _LicenseeRow(
      icon: Icons.sports_score,
      iconColor: AppColors.statusWaiting,
      name: '${referee.firstName} ${referee.lastName} (${referee.level})',
      badgeLabel: 'referee_upper',
    );
  }
}

class _LicenseeRow extends StatelessWidget {
  const _LicenseeRow({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.badgeLabel,
  });

  final IconData icon;
  final Color iconColor;
  final String name;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: AppRadius.smRadius,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              name,
              style: AppTypography.body.copyWith(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.pillRadius,
              border: Border.all(color: iconColor),
            ),
            child: Text(
              badgeLabel.tr,
              style: AppTypography.badge.copyWith(
                color: iconColor,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
