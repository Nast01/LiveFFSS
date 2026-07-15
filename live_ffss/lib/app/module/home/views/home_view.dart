import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/module/auth/views/user_avatar.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';
import 'package:live_ffss/app/presentation/shared/competition_card.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/home_wave.dart';
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
            const HomeWave(),
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
                backgroundColor: Colors.white.withValues(alpha: 0.2),
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
      return RefreshIndicator(
        onRefresh: controller.refreshVisible,
        child: items.isEmpty
            ? _emptyList()
            : ListView.separated(
                padding: AppSpacing.pageHorizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final competition = items[i];
                  return Obx(() => CompetitionCard(
                        competition: competition,
                        isFavorite:
                            controller.favoriteIds.contains(competition.id),
                        onTap: () => controller
                            .navigateToCompetitionDetails(competition),
                        onToggleFavorite: () =>
                            controller.toggleFavorite(competition.id),
                      ));
                },
              ),
      );
    });
  }

  Widget _emptyList() {
    final isLastViewed =
        controller.selectedTemporal.value == TemporalFilter.lastViewed;
    // A scrollable so pull-to-refresh works even with no results.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: AppSpacing.xl),
        EmptyState(
          icon: Icons.event_busy,
          title: isLastViewed ? 'no_last_viewed'.tr : 'no_competitions_found'.tr,
        ),
      ],
    );
  }
}
