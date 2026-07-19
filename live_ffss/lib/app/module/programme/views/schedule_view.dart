import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/const/format_const.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:live_ffss/app/module/programme/controllers/schedule_controller.dart';
import 'package:live_ffss/app/module/programme/views/sites_view.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  final _controller = Get.find<ScheduleController>();
  final _programme = Get.find<ProgrammeController>();
  Worker? _compWorker;

  @override
  void initState() {
    super.initState();
    _compWorker = ever(_programme.competition, _controller.setCompetition);
    _controller.setCompetition(_programme.competition.value);
  }

  @override
  void dispose() {
    _compWorker?.dispose();
    super.dispose();
  }

  String _hhmm(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  Future<void> _pickStart(int siteId, DateTime day) async {
    final current = _controller.startMinutesFor(siteId, day);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked != null) {
      _controller.setDayStart(siteId, day, picked.hour * 60 + picked.minute);
    }
  }

  Future<void> _addManual(int siteId, DateTime day) async {
    final labelController = TextEditingController();
    var minutes = 15;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('add_manual_item'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: InputDecoration(labelText: 'manual_label'.tr),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('duration_min'.tr, style: AppTypography.caption),
                  Row(children: [
                    IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: minutes > 5
                            ? () => setState(() => minutes -= 5)
                            : null),
                    Text('$minutes', style: AppTypography.body),
                    IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => minutes += 5)),
                  ]),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('cancel'.tr)),
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('save'.tr)),
          ],
        ),
      ),
    );
    if (ok == true) {
      _controller.addManual(labelController.text, minutes, siteId, day);
    }
  }

  Future<void> _editLabel(int blockId, String current) async {
    final labelController = TextEditingController(text: current);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('edit_item'.tr),
        content: TextField(
          controller: labelController,
          decoration: InputDecoration(labelText: 'manual_label'.tr),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('cancel'.tr)),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('save'.tr)),
        ],
      ),
    );
    if (ok == true) {
      _controller.setManualLabel(blockId, labelController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.days.isEmpty) {
        return EmptyState(icon: Icons.event_busy, title: 'no_days'.tr);
      }
      final siteId = _controller.selectedSiteId.value;
      final day = _controller.selectedDay;
      return Stack(
        children: [
          Column(
            children: [
              _DayChips(controller: _controller),
              _SiteChips(controller: _controller, onEditStart: _pickStart, hhmm: _hhmm),
              const SizedBox(height: AppSpacing.xs),
              Expanded(
                child: (siteId == null || day == null)
                    ? EmptyState(icon: Icons.place_outlined, title: 'no_sites'.tr)
                    : _Timeline(
                        controller: _controller,
                        siteId: siteId,
                        day: day,
                        onEditLabel: _editLabel,
                      ),
              ),
              const Divider(height: 1),
              _Palette(controller: _controller),
            ],
          ),
          if (siteId != null && day != null)
            Positioned(
              right: AppSpacing.md,
              bottom: 180,
              child: FloatingActionButton.extended(
                heroTag: 'addManual',
                onPressed: () => _addManual(siteId, day),
                icon: const Icon(Icons.add),
                label: Text('add_manual_item'.tr),
              ),
            ),
        ],
      );
    });
  }
}

class _DayChips extends StatelessWidget {
  const _DayChips({required this.controller});
  final ScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Obx(() {
        final selected = controller.selectedDayIndex.value;
        final days = controller.days;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: AppSpacing.pageHorizontal,
          itemCount: days.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (_, i) {
            final active = selected == i;
            return GestureDetector(
              onTap: () => controller.selectedDayIndex.value = i,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: active ? AppColors.statusWaiting : AppColors.surface,
                  borderRadius: AppRadius.pillRadius,
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  FormatConst.dateFormat.format(days[i]),
                  style: AppTypography.caption.copyWith(
                      color: active ? Colors.white : AppColors.textPrimary),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _SiteChips extends StatelessWidget {
  const _SiteChips({
    required this.controller,
    required this.onEditStart,
    required this.hhmm,
  });
  final ScheduleController controller;
  final Future<void> Function(int siteId, DateTime day) onEditStart;
  final String Function(int minutes) hhmm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
      child: Obx(() {
        final sites = controller.sites;
        final selectedId = controller.selectedSiteId.value;
        final day = controller.selectedDay;
        return Row(
          children: [
            Expanded(
              child: sites.isEmpty
                  ? Text('no_sites'.tr, style: AppTypography.caption)
                  : SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: sites.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.sm),
                        itemBuilder: (_, i) {
                          final s = sites[i];
                          final active = selectedId == s.id;
                          return GestureDetector(
                            onTap: () => controller.selectedSiteId.value = s.id,
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppColors.primary
                                    : AppColors.surface,
                                borderRadius: AppRadius.pillRadius,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                s.name,
                                style: AppTypography.caption.copyWith(
                                    color: active
                                        ? Colors.white
                                        : AppColors.textPrimary),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            if (selectedId != null && day != null)
              GestureDetector(
                onTap: () => onEditStart(selectedId, day),
                child: Container(
                  margin: const EdgeInsets.only(left: AppSpacing.sm),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: AppRadius.pillRadius,
                  ),
                  child: Text(
                    '${'starts_at'.tr} ${hhmm(controller.startMinutesFor(selectedId, day))} ▾',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.primaryDark),
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'sites'.tr,
              onPressed: () => Get.to<void>(() => const SitesView()),
            ),
          ],
        );
      }),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.controller,
    required this.siteId,
    required this.day,
    required this.onEditLabel,
  });
  final ScheduleController controller;
  final int siteId;
  final DateTime day;
  final Future<void> Function(int blockId, String current) onEditLabel;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Depend on the programme so reflows rebuild; rowsFor reads current.
      controller.selectedSiteId.value;
      final rows = controller.rowsFor(siteId, day);
      if (rows.isEmpty) {
        return EmptyState(icon: Icons.schedule, title: 'no_placement_here'.tr);
      }
      return ReorderableListView.builder(
        padding: AppSpacing.pageAll,
        itemCount: rows.length,
        onReorder: (oldIndex, newIndex) =>
            controller.reorder(siteId, day, oldIndex, newIndex),
        itemBuilder: (context, i) {
          final row = rows[i];
          final b = row.block;
          final isManual = b.raceId == null;
          return Padding(
            key: ValueKey(b.id),
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: _AccentCard(
              index: i,
              begin: FormatConst.timeFormat.format(row.begin),
              end: FormatConst.timeFormat.format(row.end),
              duration: b.durationMinutes,
              label: isManual
                  ? b.manualLabel
                  : (controller.scheduleItemFor(b.raceId!)?.label ?? ''),
              accent: isManual
                  ? AppColors.statusWaiting
                  : (controller.roundOf(b.raceId!) == RoundType.finale
                      ? AppColors.statusFinished
                      : AppColors.primary),
              onMinus: () => controller.setDuration(b.id, b.durationMinutes - 5),
              onPlus: () => controller.setDuration(b.id, b.durationMinutes + 5),
              onRemove: () => controller.removeBlock(b.id),
              onEditLabel:
                  isManual ? () => onEditLabel(b.id, b.manualLabel) : null,
            ),
          );
        },
      );
    });
  }
}

class _AccentCard extends StatelessWidget {
  const _AccentCard({
    required this.index,
    required this.begin,
    required this.end,
    required this.duration,
    required this.label,
    required this.accent,
    required this.onMinus,
    required this.onPlus,
    required this.onRemove,
    required this.onEditLabel,
  });
  final int index;
  final String begin;
  final String end;
  final int duration;
  final String label;
  final Color accent;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onRemove;
  final VoidCallback? onEditLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdRadius,
      elevation: 1,
      child: Row(
        children: [
          Container(
            width: 5,
            height: 56,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppRadius.md)),
            ),
          ),
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.drag_indicator, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onEditLabel,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      Text(begin,
                          style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark)),
                      const SizedBox(width: 6),
                      Text('→ $end · $duration ${'min_short'.tr}',
                          style: AppTypography.caption),
                    ]),
                    Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
              icon: const Icon(Icons.remove, size: 20), onPressed: onMinus),
          IconButton(icon: const Icon(Icons.add, size: 20), onPressed: onPlus),
          IconButton(
              icon: const Icon(Icons.close, size: 20), onPressed: onRemove),
        ],
      ),
    );
  }
}

class _Palette extends StatelessWidget {
  const _Palette({required this.controller});
  final ScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.unscheduled;
      final siteId = controller.selectedSiteId.value;
      final day = controller.selectedDay;
      return Container(
        constraints: const BoxConstraints(maxHeight: 150),
        color: AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text('${'unscheduled'.tr} (${items.length})',
                  style: AppTypography.caption),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  return ListTile(
                    dense: true,
                    title: Text(item.label,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: TextButton(
                      onPressed: (siteId == null || day == null)
                          ? null
                          : () => controller.addRace(item.raceId, siteId, day),
                      child: Text('add_race'.tr),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
