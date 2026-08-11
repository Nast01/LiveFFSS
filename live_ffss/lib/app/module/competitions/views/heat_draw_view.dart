import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/module/competitions/controllers/heat_draw_controller.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/club_avatar.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

class HeatDrawView extends StatefulWidget {
  const HeatDrawView({super.key});

  @override
  State<HeatDrawView> createState() => _HeatDrawViewState();
}

class _HeatDrawViewState extends State<HeatDrawView> {
  late final HeatDrawController _ctrl;
  late final Worker _messageWorker;
  late final Worker _savedWorker;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<HeatDrawController>();
    _messageWorker = ever<UiMessage?>(_ctrl.message, (m) {
      if (m == null || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(m.translationKey.tr),
        backgroundColor:
            m is UiMessageError ? AppColors.statusError : AppColors.primary,
      ));
    });
    _savedWorker = ever<bool>(_ctrl.saved, (saved) {
      if (saved && mounted) Get.back<void>();
    });
  }

  @override
  void dispose() {
    _messageWorker.dispose();
    _savedWorker.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_ctrl.hasExistingComposition) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('heat_draw_overwrite_title'.tr),
          content: Text('heat_draw_overwrite_body'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('confirm'.tr),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    await _ctrl.save();
  }

  Future<void> _pickTargetHeat(Athlete athlete) async {
    final current = _ctrl.heatIndexOf(athlete);
    final target = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('heat_draw_move_to'.tr),
        children: [
          for (var i = 0; i < _ctrl.heats.length; i++)
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(i),
              child: Text(
                '${'heat'.tr} ${i + 1}${i == current ? ' · ${'heat_draw_current'.tr}' : ''}',
                style: AppTypography.body.copyWith(
                  color: i == current
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
    if (target != null) _ctrl.moveAthlete(athlete, target);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('heat_draw_title'.tr,
                style: AppTypography.title
                    .copyWith(color: Colors.white, fontSize: 16)),
            Obx(() => Text(
                  _ctrl.categoryLabel.isEmpty
                      ? _ctrl.race.value?.name ?? ''
                      : '${_ctrl.race.value?.name ?? ''} · ${_ctrl.categoryLabel}',
                  style: AppTypography.caption.copyWith(color: Colors.white70),
                )),
          ],
        ),
      ),
      body: Obx(() {
        if (_ctrl.isLoading.value) return const LoadingIndicator();
        if (_ctrl.error.value != null) {
          return ErrorState(message: 'error_occured'.tr, onRetry: _ctrl.load);
        }
        if (_ctrl.availableLevels.isEmpty) {
          return EmptyState(
            icon: Icons.account_tree_outlined,
            title: 'no_structure_defined'.tr,
          );
        }
        return Column(
          children: [
            const _LevelPicker(),
            const _PresenceBanner(),
            Expanded(
              child: _ctrl.heats.isEmpty
                  ? EmptyState(
                      icon: Icons.shuffle,
                      title: 'heat_draw_empty'.tr,
                    )
                  : ListView(
                      padding: AppSpacing.pageAll,
                      children: [
                        for (var i = 0; i < _ctrl.heats.length; i++)
                          _HeatCard(
                            index: i,
                            athletes: _ctrl.heats[i],
                            onTapAthlete: _pickTargetHeat,
                          ),
                      ],
                    ),
            ),
            _Actions(onSave: _save),
          ],
        );
      }),
    );
  }
}

class _LevelPicker extends GetView<HeatDrawController> {
  const _LevelPicker();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
          child: Row(
            children: [
              Text('heat_draw_level'.tr, style: AppTypography.caption),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    for (final level in controller.availableLevels)
                      ChoiceChip(
                        label: Text(level.labelKey.tr),
                        selected: controller.selectedLevel.value == level,
                        onSelected: (_) => controller.selectLevel(level),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

class _PresenceBanner extends GetView<HeatDrawController> {
  const _PresenceBanner();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final present = controller.presentCount;
      final engaged = controller.engagedCount.value;
      // Drawing before everyone is checked in is the easy mistake to make, so
      // the shortfall is called out rather than merely counted.
      final partial = present < engaged;
      return Container(
        margin: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: (partial ? AppColors.statusWaiting : AppColors.statusFinished)
              .withValues(alpha: 0.12),
          borderRadius: AppRadius.smRadius,
        ),
        child: Row(
          children: [
            Icon(partial ? Icons.info_outline : Icons.check_circle_outline,
                size: 16,
                color: partial
                    ? AppColors.statusWaiting
                    : AppColors.statusFinished),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'heat_draw_presence'.trParams({
                  'present': '$present',
                  'engaged': '$engaged',
                }),
                style: AppTypography.caption,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _HeatCard extends StatelessWidget {
  const _HeatCard({
    required this.index,
    required this.athletes,
    required this.onTapAthlete,
  });

  final int index;
  final List<Athlete> athletes;
  final ValueChanged<Athlete> onTapAthlete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, AppSpacing.xs),
            child: Row(
              children: [
                Text('${'heat'.tr} ${index + 1}',
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.w800)),
                const Spacer(),
                Text('${athletes.length} ${'athletes_lower'.tr}',
                    style: AppTypography.caption),
              ],
            ),
          ),
          for (var lane = 0; lane < athletes.length; lane++)
            _LaneRow(
              lane: lane + 1,
              athlete: athletes[lane],
              onTap: () => onTapAthlete(athletes[lane]),
            ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}

class _LaneRow extends StatelessWidget {
  const _LaneRow({
    required this.lane,
    required this.athlete,
    required this.onTap,
  });

  final int lane;
  final Athlete athlete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: AppRadius.smRadius,
              ),
              child: Text('$lane',
                  style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w800, color: AppColors.primary)),
            ),
            const SizedBox(width: AppSpacing.sm),
            ClubAvatar(
              club: athlete.club,
              size: 28,
              shape: ClubAvatarShape.circle,
              fallbackLabel: athlete.clubLabel,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '${athlete.lastName.toUpperCase()} ${athlete.firstName}'.trim(),
                style: AppTypography.body.copyWith(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.swap_horiz, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _Actions extends GetView<HeatDrawController> {
  const _Actions({required this.onSave});

  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return Obx(() => SafeArea(
          top: false,
          child: Padding(
            padding: AppSpacing.pageAll,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.drawFromPresent,
                    icon: const Icon(Icons.shuffle),
                    label: Text(controller.heats.isEmpty
                        ? 'heat_draw_action'.tr
                        : 'heat_draw_again'.tr),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.heats.isEmpty ? null : onSave,
                    icon: const Icon(Icons.check),
                    label: Text('save'.tr),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
