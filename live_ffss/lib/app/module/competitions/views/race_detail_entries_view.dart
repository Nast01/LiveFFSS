import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/attendance_status.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_detail_controller.dart';
import 'package:live_ffss/app/presentation/modules/competitions/entry_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/entry_group_tile.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/presentation/shared/ui_message_display.dart';

class RaceDetailEntriesView extends StatefulWidget {
  const RaceDetailEntriesView({super.key});

  @override
  State<RaceDetailEntriesView> createState() => _RaceDetailEntriesViewState();
}

class _RaceDetailEntriesViewState extends State<RaceDetailEntriesView> {
  late final RaceDetailController _ctrl;
  late final Worker _worker;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<RaceDetailController>();
    _worker = showUiMessages(_ctrl.message);
  }

  @override
  void dispose() {
    _worker.dispose();
    super.dispose();
  }

  String _subtitleOf(Entry entry) {
    // No athletes, no year, no club, no roster: an empty subtitle is the
    // honest answer — same guard as teamAttendance and the trailing-chip pick.
    if (entry.athletes.isEmpty) return '';
    if (!isTeamEntry(entry)) {
      final athlete = entry.athletes.first;
      return [
        if (athlete.year > 0) '${athlete.year}',
        if (athlete.clubLabel.isNotEmpty) athlete.clubLabel,
      ].join(' • ');
    }
    final present = entry.athletes
        .where((a) => _ctrl.attendanceOf(a) == AttendanceStatus.present)
        .length;
    return '${entrySubtitle(entry)} · $present/${entry.athletes.length}';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_ctrl.entriesLoading.value) {
        return const LoadingIndicator();
      }
      if (_ctrl.entriesError.value != null) {
        return ErrorState(
          message: 'error_occured'.tr,
          onRetry: _ctrl.loadEntries,
        );
      }
      final competitors = _ctrl.sortedEntries;
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
                if (_ctrl.canScanBracelets) ...[
                  _ScanButton(onPressed: () => _openScanSheet(context)),
                  const SizedBox(height: AppSpacing.xs),
                ],
                if (competitors.isNotEmpty) ...[
                  const _AttendanceSummary(),
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
            child: competitors.isEmpty
                ? EmptyState(
                    icon: Icons.list_alt_outlined,
                    title: 'no_entries_yet'.tr,
                  )
                : RefreshIndicator(
                    onRefresh: _ctrl.loadEntries,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.sm,
                        AppSpacing.xs,
                        AppSpacing.sm,
                        AppSpacing.lg,
                      ),
                      itemCount: competitors.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (_, i) {
                        final entry = competitors[i];
                        // A solo engagement keeps today's chip verbatim — tap
                        // to cycle, long-press for the explicit menu — since
                        // there is only one athlete to point. A team's
                        // aggregated status isn't picked by hand, so it only
                        // gets the tap-to-cycle chip.
                        final trailing =
                            isTeamEntry(entry) || entry.athletes.isEmpty
                                ? _TeamStatusChip(entry: entry)
                                : _AthleteStatusChip(
                                    athlete: entry.athletes.single);
                        // One Obx per row: a ListView's itemBuilder runs during
                        // layout, outside the screen-level Obx's build, so a
                        // read of expandedEntries made here would never be
                        // registered as a dependency and the chevron would fold
                        // nothing. The draw and Séries screens wrap their tiles
                        // the same way.
                        //
                        // The card is painted here, not in EntryGroupTile: those
                        // two screens render their tiles flat inside a card of
                        // their own, and chrome in the shared widget would
                        // double it there.
                        return Obx(
                          () => Container(
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
                                vertical: AppSpacing.xs),
                            child: EntryGroupTile(
                              entry: entry,
                              title: entryTitle(entry),
                              subtitle: _subtitleOf(entry),
                              expanded: _ctrl.isEntryExpanded(entry),
                              onToggle: () => _ctrl.toggleEntry(entry),
                              trailing: trailing,
                              athleteTrailing: (athlete) =>
                                  _AthleteStatusChip(athlete: athlete),
                              onSubstitute: _ctrl.requestSubstitution,
                              avatarSize: 40,
                              // A relay's row is titled by its club, and the
                              // marshal reads that name to find their team:
                              // it is never worth truncating. Capping the
                              // lines would only move where it gets cut, so
                              // the title wraps as far as it needs and the row
                              // grows with it.
                              titleMaxLines: null,
                            ),
                          ),
                          key: ValueKey(entry.id),
                        );
                      },
                    ),
                  ),
          ),
        ],
      );
    });
  }

  void _openScanSheet(BuildContext context) {
    _ctrl.startScan();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => const _ScanSheet(),
    ).whenComplete(_ctrl.stopScan);
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

/// Marshalling progress: how many of the engaged athletes have been pointed
/// (present or absent), as a headline, a proportional bar, and a legend.
class _AttendanceSummary extends GetView<RaceDetailController> {
  const _AttendanceSummary();

  static const double _barHeight = 8;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final counts = controller.attendanceCounts;
      // Pointing an athlete means deciding present OR absent — only `waiting`
      // is still outstanding, so the bar fills as marshalling progresses.
      final pointed = counts.present + counts.absent;
      final segments = <(int, Color)>[
        (counts.present, AppColors.statusFinished),
        (counts.absent, AppColors.statusError),
        (counts.waiting, AppColors.statusWaiting),
      ];
      // The team tally would just repeat the head-count gauge when every
      // engagement is individual, so it only shows up once a relay is entered.
      final hasTeams = controller.entries.any(isTeamEntry);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$pointed / ${counts.total} ${'pointed_count'.tr}',
            style: AppTypography.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: AppRadius.pillRadius,
            child: Container(
              height: _barHeight,
              color: AppColors.border,
              child: Row(
                // A childless ColoredBox collapses to zero height under the
                // loose cross-axis constraint the default `center` gives it.
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (count, color) in segments)
                    if (count > 0)
                      Expanded(
                        flex: count,
                        child: ColoredBox(color: color),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _LegendEntry(
                count: counts.present,
                label: 'present_count'.tr,
                color: AppColors.statusFinished,
              ),
              const SizedBox(width: AppSpacing.sm),
              _LegendEntry(
                count: counts.absent,
                label: 'absent_count'.tr,
                color: AppColors.statusError,
              ),
              const SizedBox(width: AppSpacing.sm),
              _LegendEntry(
                count: counts.waiting,
                label: 'waiting_count'.tr,
                color: AppColors.statusWaiting,
              ),
            ],
          ),
          if (hasTeams) ...[
            const SizedBox(height: 4),
            Text(
              '${controller.teamCounts.complete}/${controller.teamCounts.total}'
              ' ${'teams_complete'.tr}',
              style: AppTypography.caption.copyWith(fontSize: 12),
            ),
          ],
        ],
      );
    });
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Flexible, not Expanded: the three entries share the row but a zero-count
    // one ("0 absents") must not be padded out to a third of the width.
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$count $label',
              style: AppTypography.caption.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SortDropdown extends GetView<RaceDetailController> {
  const _SortDropdown();

  static String _labelOf(CompetitorSortMode mode) => switch (mode) {
        CompetitorSortMode.name => 'sort_name'.tr,
        CompetitorSortMode.club => 'sort_club'.tr,
        CompetitorSortMode.attendance => 'sort_status'.tr,
      };

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DropdownButton<CompetitorSortMode>(
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
          for (final mode in CompetitorSortMode.values)
            DropdownMenuItem(value: mode, child: Text(_labelOf(mode))),
        ],
      ),
    );
  }
}

Color _attendanceColor(AttendanceStatus status) => switch (status) {
      AttendanceStatus.waiting => AppColors.statusWaiting,
      AttendanceStatus.present => AppColors.statusFinished,
      AttendanceStatus.absent => AppColors.statusError,
    };

String _attendanceLabel(AttendanceStatus status) => switch (status) {
      AttendanceStatus.waiting => 'attendance_waiting'.tr,
      AttendanceStatus.present => 'attendance_present'.tr,
      AttendanceStatus.absent => 'attendance_absent'.tr,
    };

/// One athlete's status: tap to cycle, long-press to pick directly — the part
/// an RFID scan doesn't yet replace.
class _AthleteStatusChip extends GetView<RaceDetailController> {
  const _AthleteStatusChip({required this.athlete});

  final Athlete athlete;

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
                    color: _attendanceColor(status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(_attendanceLabel(status)),
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
            color: _attendanceColor(status),
            borderRadius: AppRadius.pillRadius,
          ),
          child: Text(
            _attendanceLabel(status),
            style: AppTypography.badge.copyWith(fontSize: 11),
          ),
        ),
      );
    });
  }
}

/// The engagement's aggregated status: one tap points the whole team at once.
/// No menu — a team status isn't picked by hand, it's derived from its
/// athletes.
class _TeamStatusChip extends GetView<RaceDetailController> {
  const _TeamStatusChip({required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.teamAttendance(entry);
      return GestureDetector(
        onTap: () => controller.cycleTeamAttendance(entry),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _attendanceColor(status),
            borderRadius: AppRadius.pillRadius,
          ),
          child: Text(
            _attendanceLabel(status),
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
