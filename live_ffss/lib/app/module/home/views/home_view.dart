import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/module/auth/views/user_avatar.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';
import 'package:live_ffss/app/presentation/modules/home/competition_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/language_selector.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _HomeHero(),
            const _HomeWave(),
            const SizedBox(height: AppSpacing.md),
            const _HomeFiltersBar(),
            const SizedBox(height: AppSpacing.sm),
            const _HomeSearchBar(),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Obx(() {
                final isWeek =
                    controller.selectedTemporal.value == TemporalFilter.thisWeek;
                final loading = isWeek
                    ? controller.isLoadingThisWeek.value
                    : controller.isLoading.value;
                final hasErr = isWeek
                    ? controller.hasErrorThisWeek.value
                    : controller.hasError.value;
                if (loading) {
                  return const LoadingIndicator();
                }
                if (hasErr) {
                  return ErrorState(
                    message: 'error_occured'.tr,
                    onRetry: isWeek
                        ? controller.loadThisWeek
                        : controller.loadCompetitions,
                  );
                }
                return const _HomeList();
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHero extends GetView<HomeController> {
  const _HomeHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              const LanguageSelector(),
              const SizedBox(width: AppSpacing.sm),
              UserAvatar(
                size: 36,
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_ffss.png',
                height: 56,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.app_shortcut,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                controller.appTitleKey.tr,
                style: AppTypography.title.copyWith(
                  color: Colors.white,
                  fontSize: 24,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeroPill(
                label: 'last_viewed'.tr,
                temporal: TemporalFilter.lastViewed,
              ),
              const SizedBox(width: AppSpacing.sm),
              _HeroPill(
                label: 'this_week'.tr,
                temporal: TemporalFilter.thisWeek,
              ),
              const SizedBox(width: AppSpacing.sm),
              _HeroPill(
                label: 'all'.tr,
                temporal: TemporalFilter.all,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends GetView<HomeController> {
  const _HeroPill({required this.label, required this.temporal});

  final String label;
  final TemporalFilter temporal;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.selectedTemporal.value == temporal;
      return GestureDetector(
        onTap: () => controller.setTemporal(temporal),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: AppRadius.pillRadius,
            border: Border.all(color: Colors.white),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.primary : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      );
    });
  }
}

class _HomeWave extends StatelessWidget {
  const _HomeWave();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 24,
      child: CustomPaint(painter: _WavePainter()),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary;
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 2,
        size.width,
        0,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HomeFiltersBar extends GetView<HomeController> {
  const _HomeFiltersBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pageHorizontal,
      child: Row(
        children: [
          _DisciplinePill(label: 'all'.tr, filter: HomeFilter.all),
          const SizedBox(width: AppSpacing.sm),
          _DisciplinePill(label: 'swimming'.tr, filter: HomeFilter.pool),
          const SizedBox(width: AppSpacing.sm),
          _DisciplinePill(label: 'beach'.tr, filter: HomeFilter.coastal),
        ],
      ),
    );
  }
}

class _DisciplinePill extends GetView<HomeController> {
  const _DisciplinePill({required this.label, required this.filter});

  final String label;
  final HomeFilter filter;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.selectedDiscipline.value == filter;
      return GestureDetector(
        onTap: () => controller.setDiscipline(filter),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.white,
            borderRadius: AppRadius.pillRadius,
            border: Border.all(color: AppColors.primary),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      );
    });
  }
}

class _HomeSearchBar extends StatefulWidget {
  const _HomeSearchBar();

  @override
  State<_HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<_HomeSearchBar> {
  late final HomeController _home;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _home = Get.find<HomeController>();
    _controller = TextEditingController(text: _home.searchQuery.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pageHorizontal,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: AppRadius.pillRadius,
        ),
        child: TextField(
          controller: _controller,
          onChanged: _home.setSearchQuery,
          decoration: InputDecoration(
            hintText: 'search_competitions'.tr,
            hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
            prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          ),
        ),
      ),
    );
  }
}

class _HomeList extends GetView<HomeController> {
  const _HomeList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.filteredCompetitions;
      if (items.isEmpty) {
        final isLastViewed =
            controller.selectedTemporal.value == TemporalFilter.lastViewed;
        return EmptyState(
          icon: Icons.event_busy,
          title:
              isLastViewed ? 'no_last_viewed'.tr : 'no_competitions_found'.tr,
        );
      }
      return ListView.separated(
        padding: AppSpacing.pageHorizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) => _CompetitionCard(competition: items[i]),
      );
    });
  }
}

class _CompetitionCard extends GetView<HomeController> {
  const _CompetitionCard({required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.smRadius,
      child: InkWell(
        onTap: () => controller.navigateToCompetitionDetails(competition),
        borderRadius: AppRadius.smRadius,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: AppRadius.smRadius,
          ),
          child: Row(
            children: [
              _CardThumbnail(competition: competition),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _CardBody(competition: competition)),
              const SizedBox(width: AppSpacing.sm),
              _CardTrailing(competition: competition),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardThumbnail extends StatelessWidget {
  const _CardThumbnail({required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    final logoUrl = competition.organizerClub.logoUrl;
    if (logoUrl == null || logoUrl.isEmpty) {
      return _DateBlock(competition: competition);
    }
    return ClipRRect(
      borderRadius: AppRadius.smRadius,
      child: Image.network(
        logoUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _DateBlock(competition: competition),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _DateBlock(competition: competition),
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.smRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            competition.formattedBeginDateMonth,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            competition.formattedDayBeginDate,
            style: AppTypography.subtitle.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          competition.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.title.copyWith(fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          competition.formattedDateRange,
          style: AppTypography.body.copyWith(fontSize: 12),
        ),
        Text(
          competition.location ?? 'no_location'.tr,
          style: AppTypography.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

}

class _CardTrailing extends GetView<HomeController> {
  const _CardTrailing({required this.competition});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    final isLive = competition.phase == CompetitionStatus.onGoing;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isLive ? AppColors.statusError : competition.entryStatusColor,
            borderRadius: AppRadius.pillRadius,
          ),
          child: Text(
            isLive ? 'live'.tr : competition.entryStatusLabel,
            style: AppTypography.badge.copyWith(fontSize: 10),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              final favored =
                  controller.favoriteIds.contains(competition.id);
              return IconButton(
                onPressed: () => controller.toggleFavorite(competition.id),
                icon: Icon(
                  favored ? Icons.star : Icons.star_border,
                  color: favored
                      ? AppColors.statusWaiting
                      : AppColors.textMuted,
                  size: 22,
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              );
            }),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 22,
            ),
          ],
        ),
      ],
    );
  }
}
