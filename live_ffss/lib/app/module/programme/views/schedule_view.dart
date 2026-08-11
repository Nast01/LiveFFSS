import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/const/format_const.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:live_ffss/app/module/programme/controllers/schedule_controller.dart';
import 'package:live_ffss/app/module/programme/views/sites_view.dart';
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';
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
              _SiteChips(
                  controller: _controller,
                  onEditStart: _pickStart,
                  hhmm: _hhmm),
              const SizedBox(height: AppSpacing.xs),
              Expanded(
                child: (siteId == null || day == null)
                    ? EmptyState(
                        icon: Icons.place_outlined, title: 'no_sites'.tr)
                    : _Timeline(
                        controller: _controller,
                        siteId: siteId,
                        day: day,
                        onEditLabel: _editLabel,
                      ),
              ),
              const Divider(height: 1),
              _Palette(
                controller: _controller,
                // EventStructure carries no gender; the overview rows do.
                genderOf: _programme.genderForRace,
              ),
            ],
          ),
          if (siteId != null && day != null)
            Positioned(
              right: AppSpacing.md,
              // Sits clear of the palette, whose height varies with the screen.
              bottom: _paletteHeight(context) + AppSpacing.lg,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
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
              onMinus: () =>
                  controller.setDuration(b.id, b.durationMinutes - 5),
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

/// Height of the unscheduled palette. A share of the screen rather than a fixed
/// number so a small phone keeps a usable timeline above it. The FAB is placed
/// clear of the palette, so both read it and cannot drift apart.
double _paletteHeight(BuildContext context) =>
    (MediaQuery.sizeOf(context).height * 0.35).clamp(150.0, 320.0);

/// The unscheduled races, one collapsible section per épreuve.
///
/// Sections start collapsed so the whole programme is visible at a glance —
/// with "add all" on the header, a full épreuve is scheduled without ever
/// opening one. A single épreuve opens on its own: there is nothing to choose.
class _Palette extends StatefulWidget {
  const _Palette({required this.controller, required this.genderOf});

  final ScheduleController controller;
  final Gender Function(int structureRaceId) genderOf;

  @override
  State<_Palette> createState() => _PaletteState();
}

class _PaletteState extends State<_Palette> {
  /// Keyed by (épreuve, category) — the pair identifying a group.
  final Set<(int, int)> _expanded = <(int, int)>{};

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final groups = widget.controller.unscheduledGroups;
      final total = groups.fold<int>(0, (sum, g) => sum + g.items.length);
      final siteId = widget.controller.selectedSiteId.value;
      final day = widget.controller.selectedDay;
      // Resolved here, not in the itemBuilder below: that builder runs during
      // layout, outside this Obx, so reading the épreuve rows from there
      // registers no dependency and the badges stay stale until some other
      // rebuild happens to come along.
      final genders = <int, Gender>{
        for (final g in groups)
          g.structureRaceId: widget.genderOf(g.structureRaceId),
      };
      return Container(
        constraints: BoxConstraints(maxHeight: _paletteHeight(context)),
        color: AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text('${'unscheduled'.tr} ($total)',
                  style: AppTypography.caption),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: groups.length,
                itemBuilder: (_, i) {
                  final group = groups[i];
                  final key = (group.structureRaceId, group.categoryId);
                  return _GroupSection(
                    group: group,
                    gender: genders[group.structureRaceId] ?? Gender.unknown,
                    expanded: groups.length == 1 || _expanded.contains(key),
                    onToggle: () => setState(() {
                      if (!_expanded.remove(key)) _expanded.add(key);
                    }),
                    onAdd: (siteId == null || day == null)
                        ? null
                        : (raceId) =>
                            widget.controller.addRace(raceId, siteId, day),
                    onAddAll: (siteId == null || day == null)
                        ? null
                        : () => widget.controller.addRaces(
                            group.items.map((it) => it.raceId).toList(),
                            siteId,
                            day),
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

class _GroupSection extends StatelessWidget {
  const _GroupSection({
    required this.group,
    required this.gender,
    required this.expanded,
    required this.onToggle,
    required this.onAdd,
    required this.onAddAll,
  });

  final ScheduleGroup group;
  final Gender gender;
  final bool expanded;
  final VoidCallback onToggle;
  final void Function(int raceId)? onAdd;
  final VoidCallback? onAddAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 6),
            child: Row(
              children: [
                Icon(expanded ? Icons.expand_more : Icons.chevron_right,
                    size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 2),
                _GenderBadge(gender: gender),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('${group.raceLabel} · ${group.categoryLabel}',
                      style: AppTypography.body
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                Text('${group.items.length}', style: AppTypography.caption),
                IconButton(
                  icon: const Icon(Icons.playlist_add),
                  color: AppColors.primary,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'add_all_races'.tr,
                  onPressed: onAddAll,
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          for (final item in group.items)
            InkWell(
              onTap: onAdd == null ? null : () => onAdd!(item.raceId),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 46, right: AppSpacing.sm, top: 4, bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        // The heading names the épreuve and the category; only
                        // the round is left to tell these rows apart.
                        '${item.roundType.labelKey.tr} ${item.number}',
                        style: AppTypography.body,
                      ),
                    ),
                    Icon(Icons.add_circle_outline,
                        size: 20,
                        color: onAdd == null
                            ? AppColors.textMuted
                            : AppColors.primary),
                  ],
                ),
              ),
            ),
        const Divider(height: 1),
      ],
    );
  }
}

/// The gender as a coloured letter. The letter carries the meaning on its own,
/// so the colour never has to be told apart to read the badge.
class _GenderBadge extends StatelessWidget {
  const _GenderBadge({required this.gender});

  final Gender gender;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration:
          BoxDecoration(color: gender.badgeColor, shape: BoxShape.circle),
      child: Text(
        gender.shortLabel,
        style: AppTypography.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
