import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_detail_controller.dart';
import 'package:live_ffss/app/presentation/shared/club_avatar.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';

class RaceDetailEntriesView extends GetView<RaceDetailController> {
  const RaceDetailEntriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.entriesLoading.value) {
        return const LoadingIndicator();
      }
      if (controller.entriesError.value != null) {
        return ErrorState(
          message: 'error_occured'.tr,
          onRetry: controller.loadEntries,
        );
      }
      final athletes = controller.sortedAthletes;
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            child: Column(
              children: [
                if (controller.canScanBracelets) ...[
                  _ScanButton(onPressed: () => _openScanSheet(context)),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Row(
                  children: [
                    Text(
                      'sort_by'.tr,
                      style: AppTypography.caption.copyWith(fontSize: 12),
                    ),
                    const Spacer(),
                    const _SortDropdown(),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: athletes.isEmpty
                ? EmptyState(
                    icon: Icons.list_alt_outlined,
                    title: 'no_entries_yet'.tr,
                  )
                : RefreshIndicator(
                    onRefresh: controller.loadEntries,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.sm,
                        AppSpacing.xs,
                        AppSpacing.sm,
                        AppSpacing.lg,
                      ),
                      itemCount: athletes.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (_, i) => _AthleteRow(athlete: athletes[i]),
                    ),
                  ),
          ),
        ],
      );
    });
  }

  void _openScanSheet(BuildContext context) {
    controller.startScan();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => const _ScanSheet(),
    ).whenComplete(controller.stopScan);
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.nfc),
        label: Text('scan_bracelet'.tr),
      ),
    );
  }
}

class _SortDropdown extends GetView<RaceDetailController> {
  const _SortDropdown();

  static String _labelOf(AthleteSortMode mode) => switch (mode) {
        AthleteSortMode.name => 'sort_name'.tr,
        AthleteSortMode.club => 'sort_club'.tr,
        AthleteSortMode.attendance => 'sort_status'.tr,
      };

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DropdownButton<AthleteSortMode>(
        value: controller.sortMode.value,
        isDense: true,
        borderRadius: AppRadius.smRadius,
        underline: const SizedBox.shrink(),
        style: AppTypography.body.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        onChanged: (mode) {
          if (mode != null) controller.setSortMode(mode);
        },
        items: [
          for (final mode in AthleteSortMode.values)
            DropdownMenuItem(value: mode, child: Text(_labelOf(mode))),
        ],
      ),
    );
  }
}

class _AthleteRow extends StatelessWidget {
  const _AthleteRow({required this.athlete});

  final Athlete athlete;

  @override
  Widget build(BuildContext context) {
    final name =
        '${athlete.lastName.toUpperCase()} ${athlete.firstName}'.trim();
    final subtitle = _subtitle();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClubAvatar(
            club: athlete.club,
            size: 40,
            shape: ClubAvatarShape.circle,
            fallbackLabel: athlete.clubLabel,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _StatusChip(athlete: athlete),
        ],
      ),
    );
  }

  String _subtitle() {
    final parts = <String>[
      if (athlete.year > 0) '${athlete.year}',
      if (athlete.clubLabel.isNotEmpty) athlete.clubLabel,
    ];
    return parts.join(' • ');
  }
}

class _StatusChip extends GetView<RaceDetailController> {
  const _StatusChip({required this.athlete});

  final Athlete athlete;

  static Color _colorOf(AttendanceStatus status) => switch (status) {
        AttendanceStatus.waiting => AppColors.statusWaiting,
        AttendanceStatus.present => AppColors.statusFinished,
        AttendanceStatus.absent => AppColors.statusError,
      };

  static String _labelOf(AttendanceStatus status) => switch (status) {
        AttendanceStatus.waiting => 'attendance_waiting'.tr,
        AttendanceStatus.present => 'attendance_present'.tr,
        AttendanceStatus.absent => 'attendance_absent'.tr,
      };

  Future<void> _pickStatus(BuildContext context, Offset globalPosition) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final selected = await showMenu<AttendanceStatus>(
      context: context,
      position: RelativeRect.fromRect(
        globalPosition & Size.zero,
        Offset.zero & overlay.size,
      ),
      items: [
        for (final status in AttendanceStatus.values)
          PopupMenuItem(
            value: status,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _colorOf(status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(_labelOf(status)),
              ],
            ),
          ),
      ],
    );
    if (selected != null) controller.setAttendance(athlete, selected);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.attendanceOf(athlete);
      return GestureDetector(
        onTap: () => controller.cycleAttendance(athlete),
        onLongPressStart: (details) =>
            _pickStatus(context, details.globalPosition),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _colorOf(status),
            borderRadius: AppRadius.pillRadius,
          ),
          child: Text(
            _labelOf(status),
            style: AppTypography.badge.copyWith(fontSize: 11),
          ),
        ),
      );
    });
  }
}

class _ScanSheet extends GetView<RaceDetailController> {
  const _ScanSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppSpacing.pageAll,
        child: Obx(() {
          final log = controller.scanLog;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.nfc, size: 56, color: AppColors.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'approach_bracelets'.tr,
                style: AppTypography.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${controller.presentCount.value} ${'present_count'.tr}',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.statusFinished,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (log.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: log.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (_, i) => _ScanLogRow(result: log[i]),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: Get.back<void>,
                child: Text('finish'.tr),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ScanLogRow extends StatelessWidget {
  const _ScanLogRow({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final (String text, Color color) = switch (result.outcome) {
      ScanOutcome.present => (result.label, AppColors.statusFinished),
      ScanOutcome.notEntered => (
          '${result.label} · ${'not_entered'.tr}',
          AppColors.statusWaiting
        ),
      // For unreadable rows the label IS the RfidException translation key.
      ScanOutcome.unreadable => (result.label.tr, AppColors.statusError),
    };
    return Row(
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
