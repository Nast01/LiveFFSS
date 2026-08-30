import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/const/format_const.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:live_ffss/app/module/programme/controllers/schedule_controller.dart';
import 'package:live_ffss/app/module/programme/views/sites_view.dart';
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/gender_badge.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  final _controller = Get.find<ScheduleController>();
  final _programme = Get.find<ProgrammeController>();
  Worker? _compWorker;
  late final Worker _messageWorker;

  @override
  void initState() {
    super.initState();
    _compWorker =
        ever<Competition?>(_programme.competition, _onCompetitionChanged);
    _onCompetitionChanged(_programme.competition.value);
    _messageWorker = ever<UiMessage?>(_controller.message, (m) {
      if (m == null || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(m.text),
        backgroundColor:
            m is UiMessageError ? AppColors.statusError : AppColors.primary,
      ));
    });
  }

  @override
  void dispose() {
    _compWorker?.dispose();
    _messageWorker.dispose();
    super.dispose();
  }

  // setCompetition derives the local days/site selection synchronously;
  // reload() then pulls the FFSS réunion tree for whichever competition that
  // just resolved to. Fire-and-forget: the Timeline below renders its own
  // isLoading/hasError state off the controller.
  void _onCompetitionChanged(Competition? comp) {
    _controller.setCompetition(comp);
    unawaited(_controller.reload());
  }

  String _hhmm(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  /// Prompts for a label only: the item's timing is not the operator's to
  /// choose — it starts at the day's current end and lasts
  /// [defaultItemMinutes], per the design.
  Future<void> _addManualItem(DateTime day) async {
    final labelController = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('add_manual_item'.tr),
          content: TextField(
            controller: labelController,
            decoration: InputDecoration(labelText: 'manual_label'.tr),
            autofocus: true,
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
      final label = labelController.text.trim();
      if (ok != true || label.isEmpty) return;
      // Awaited: the write reports its own outcome through `message`, and a
      // failure left unawaited would be an unobserved async error with
      // nothing whatsoever on screen.
      await _controller.addManualItem(label, day);
    } finally {
      // In a `finally` so the controller is released whichever way the dialog
      // was left — cancelled, dismissed, or thrown out of.
      labelController.dispose();
    }
  }

  /// A créneau is deleted from the federal server, for everyone, and nothing
  /// on this screen can bring it back — hence the confirmation, the same shape
  /// the round editor uses. The delete icon also sits right next to the
  /// duration tap target, so a miss is easy.
  Future<void> _confirmRemoveSlot(int slotId, String label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('schedule_delete_item_title'.tr),
        content: Text('schedule_delete_item_body'.trParams({'item': label})),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.statusError),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
    if (confirmed == true) _controller.removeSlot(slotId);
  }

  /// Lets the operator pick a new duration for an existing manual créneau,
  /// in 5-minute steps — the same increment the old local planner's dialog
  /// used.
  Future<void> _editSlotDuration(int slotId, int currentMinutes) async {
    var minutes = currentMinutes;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('edit_item'.tr),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed:
                      minutes > 5 ? () => setState(() => minutes -= 5) : null),
              Text('$minutes ${'min_short'.tr}', style: AppTypography.body),
              IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => minutes += 5)),
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
    if (ok == true && minutes != currentMinutes) {
      _controller.setSlotDuration(slotId, minutes);
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
              if (day != null)
                _DayRangeHeader(controller: _controller, day: day, hhmm: _hhmm),
              _SiteChips(controller: _controller),
              const SizedBox(height: AppSpacing.xs),
              Expanded(
                child: (siteId == null || day == null)
                    ? EmptyState(
                        icon: Icons.place_outlined, title: 'no_sites'.tr)
                    : _Timeline(
                        controller: _controller,
                        day: day,
                        onEditDuration: _editSlotDuration,
                        onDelete: _confirmRemoveSlot,
                      ),
              ),
              const Divider(height: 1),
              _Palette(
                controller: _controller,
                // EventStructure carries no gender; the overview rows do.
                genderOf: _programme.genderForRace,
                day: day,
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
                onPressed: () => _addManualItem(day),
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

/// The competition's sites, plus the way into their editor.
///
/// The chips no longer filter the timeline — the day's frise comes from FFSS
/// and carries each course's own site — but the selection still gates the
/// manual-item FAB, so it stays.
class _SiteChips extends StatelessWidget {
  const _SiteChips({required this.controller});
  final ScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
      child: Obx(() {
        final sites = controller.sites;
        final selectedId = controller.selectedSiteId.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The sites get the whole width. Sharing the line with the start
            // time and the settings button left room for barely one chip: the
            // bar scrolled, but there was nothing worth scrolling to.
            if (sites.isEmpty)
              Text('no_sites'.tr, style: AppTypography.caption)
            else
              SizedBox(
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
                          color: active ? AppColors.primary : AppColors.surface,
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
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.settings),
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                tooltip: 'sites'.tr,
                onPressed: () => Get.to<void>(() => const SitesView()),
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// The day's start → end range, e.g. "08:00 → 11:20". The start is the day's
/// réunion's own `beginHour` when FFSS holds one, [defaultMeetingStartMinutes]
/// otherwise; the end is [ScheduleController.endMinutesOfDay]'s maximum across
/// every site's frise.
/// Asks for the day's new start, then moves the whole day to it. Opened from
/// the view with its own [context] — controllers here never reach for a picker.
Future<void> _pickDayStart(
  BuildContext context,
  ScheduleController controller,
  DateTime day,
  int currentMinutes,
) async {
  final picked = await showTimePicker(
    context: context,
    initialTime:
        TimeOfDay(hour: currentMinutes ~/ 60, minute: currentMinutes % 60),
    helpText: 'schedule_start_title'.tr,
  );
  if (picked == null) return;
  await controller.setMeetingStart(day, picked.hour * 60 + picked.minute);
}

class _DayRangeHeader extends StatelessWidget {
  const _DayRangeHeader({
    required this.controller,
    required this.day,
    required this.hhmm,
  });
  final ScheduleController controller;
  final DateTime day;
  final String Function(int minutes) hhmm;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final meeting = controller.meetingFor(day);
      final begin = meeting == null
          ? defaultMeetingStartMinutes
          : meeting.beginHour.hour * 60 + meeting.beginHour.minute;
      final end = controller.endMinutesOfDay(day);
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'schedule_day_range'
                    .trParams({'begin': hhmm(begin), 'end': hhmm(end)}),
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
            // Only offered once FFSS holds the day: moving a start shifts the
            // créneaux that already exist, and there is nothing to shift —
            // nor anything to update — before the first item is added.
            if (meeting != null)
              TextButton.icon(
                onPressed: () => _pickDayStart(context, controller, day, begin),
                icon: const Icon(Icons.schedule, size: 16),
                label: Text(hhmm(begin)),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
      );
    });
  }
}

/// A single item on the day's réunion: either a course (a [Slot]'s [Run]) or,
/// when a créneau carries no course, the créneau itself — a manual item shown
/// at its own `beginHour`/`endHour`.
class _DayEntry {
  const _DayEntry(
      {required this.begin,
      required this.end,
      required this.label,
      this.slotId});
  final DateTime begin;
  final DateTime end;
  final String label;

  /// The créneau backing this row, set only for a manual item — the only
  /// kind this screen can resize or delete today. A course's duration and
  /// removal go through `course/submit`, still broken on FFSS (see design).
  final int? slotId;
}

/// A group of [_DayEntry]s sharing a site — [Run.site] for course entries, or
/// the générique bucket for manual (course-less) créneaux, which carry no
/// site of their own.
class _DaySection {
  const _DaySection({required this.title, required this.items});
  final String title;
  final List<_DayEntry> items;
}

/// Splits the réunion's créneaux into per-[Run.site] sections, plus one
/// générique section for the créneaux with no course. Sections are ordered by
/// their earliest item so the day reads top to bottom.
List<_DaySection> _sectionsFor(Meeting? meeting) {
  if (meeting == null) return const [];
  final bySite = <String, List<_DayEntry>>{};
  final manual = <_DayEntry>[];
  for (final slot in meeting.slots) {
    if (slot.runs.isEmpty) {
      manual.add(_DayEntry(
        begin: slot.beginHour,
        end: slot.endHour,
        label: slot.name,
        slotId: slot.id,
      ));
      continue;
    }
    for (final run in slot.runs) {
      (bySite[run.site] ??= []).add(_DayEntry(
          begin: run.beginTime, end: run.endTime, label: run.fullLabel));
    }
  }
  final sections = [
    for (final entry in bySite.entries)
      _DaySection(title: entry.key, items: entry.value..sort(_byBegin)),
    if (manual.isNotEmpty)
      _DaySection(
          title: 'schedule_manual_items'.tr, items: manual..sort(_byBegin)),
  ];
  sections.sort((a, b) => a.items.first.begin.compareTo(b.items.first.begin));
  return sections;
}

int _byBegin(_DayEntry a, _DayEntry b) => a.begin.compareTo(b.begin);

/// The day's réunion, read straight from FFSS: courses grouped by
/// [Run.site], manual créneaux under their own section. A manual item can be
/// resized or removed straight from here; a course still can't — that goes
/// through `course/submit`, still broken on FFSS (see design).
class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.controller,
    required this.day,
    required this.onEditDuration,
    required this.onDelete,
  });
  final ScheduleController controller;
  final DateTime day;
  final void Function(int slotId, int currentMinutes) onEditDuration;
  final void Function(int slotId, String label) onDelete;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return const LoadingIndicator();
      if (controller.hasError.value) {
        return ErrorState(
          message: 'error_occured'.tr,
          onRetry: controller.reload,
        );
      }
      final sections = _sectionsFor(controller.meetingFor(day));

      // Dragging reorders the day, and a créneau's rank on FFSS *is* its start
      // time — so a drop recomputes every time from the réunion's start. Only
      // offered while the day forms a single sequence: once courses land on
      // several sites, the day runs as parallel timelines and one flat list
      // could no longer say where an item was dropped.
      if (sections.length == 1) {
        final items = sections.single.items;
        return RefreshIndicator(
          onRefresh: () => controller.reload(silent: true),
          child: ReorderableListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, _fabClearance),
            onReorder: (oldIndex, newIndex) =>
                controller.reorderSlots(day, oldIndex, newIndex),
            header: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(sections.single.title,
                  style:
                      AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
            ),
            children: [
              for (final entry in items)
                Padding(
                  key: ValueKey(entry.slotId),
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: _DayEntryCard(
                    entry: entry,
                    onEditDuration: onEditDuration,
                    onDelete: onDelete,
                  ),
                ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        // Silent: the list must stay on screen while the wheel spins, or the
        // indicator is pulled out from under the finger.
        onRefresh: () => controller.reload(silent: true),
        child: ListView(
          // AlwaysScrollable so a short day — or an empty one — can still
          // overscroll: without it the gesture never fires, and an empty day
          // is exactly when an operator pulls, to collect what was created on
          // the website.
          physics: const AlwaysScrollableScrollPhysics(),
          // Clears the manual-item FAB, which floats over the bottom of this
          // list: without it the last section's last card sits under the FAB.
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, _fabClearance),
          children: [
            if (sections.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
                child: EmptyState(
                    icon: Icons.schedule, title: 'no_placement_here'.tr),
              )
            else
              for (final section in sections)
                _DaySectionView(
                  section: section,
                  onEditDuration: onEditDuration,
                  onDelete: onDelete,
                ),
          ],
        ),
      );
    });
  }
}

class _DaySectionView extends StatelessWidget {
  const _DaySectionView({
    required this.section,
    required this.onEditDuration,
    required this.onDelete,
  });
  final _DaySection section;
  final void Function(int slotId, int currentMinutes) onEditDuration;
  final void Function(int slotId, String label) onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.title,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xs),
          for (final entry in section.items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: _DayEntryCard(
                entry: entry,
                onEditDuration: onEditDuration,
                onDelete: onDelete,
              ),
            ),
        ],
      ),
    );
  }
}

class _DayEntryCard extends StatelessWidget {
  const _DayEntryCard({
    required this.entry,
    required this.onEditDuration,
    required this.onDelete,
  });
  final _DayEntry entry;
  final void Function(int slotId, int currentMinutes) onEditDuration;
  final void Function(int slotId, String label) onDelete;

  @override
  Widget build(BuildContext context) {
    final slotId = entry.slotId;
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdRadius,
      elevation: 1,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
        child: Row(
          children: [
            Text(FormatConst.timeFormat.format(entry.begin),
                style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
            const SizedBox(width: 6),
            Text('→ ${FormatConst.timeFormat.format(entry.end)}',
                style: AppTypography.caption),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(entry.label, style: AppTypography.body)),
            if (slotId != null) ...[
              InkWell(
                onTap: () => onEditDuration(
                    slotId, entry.end.difference(entry.begin).inMinutes),
                child: Text(
                    '${entry.end.difference(entry.begin).inMinutes} ${'min_short'.tr}',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.primaryDark)),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                color: AppColors.textSecondary,
                onPressed: () => onDelete(slotId, entry.label),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Room the timeline leaves under its last card for the manual-item FAB, which
/// floats over it: the FAB's own height plus the gap it keeps above the
/// palette. Without it the last card's delete button is unreachable.
const double _fabClearance = 80;

/// Height of the unscheduled palette. A share of the screen rather than a fixed
/// number so a small phone keeps a usable timeline above it. The FAB is placed
/// clear of the palette, so both read it and cannot drift apart.
double _paletteHeight(BuildContext context) =>
    (MediaQuery.sizeOf(context).height * 0.35).clamp(150.0, 320.0);

/// The unscheduled races, one collapsible section per épreuve.
///
/// Sections start collapsed so the whole programme is visible at a glance. A
/// single épreuve opens on its own: there is nothing to choose.
///
/// Read-only for now: scheduling a course means `course/submit`, which answers
/// every POST with `500 Unknown named parameter $creneau` — verified in
/// production. The add buttons are shown greyed out with the reason rather
/// than removed, because the palette is what the timeline is drawn from once
/// FFSS fixes the endpoint./// The rounds still to place on a day.
///
/// A line is a round, not a race: a créneau links to a `partie`, so placing is
/// what a whole round does at once. Its courses are not created here —
/// `course/submit` answers every POST with `500 Unknown named parameter
/// $creneau` on the FFSS side, so the operator adds them on the federal site
/// and pulls the timeline down to collect them onto the créneau this creates.
class _Palette extends StatelessWidget {
  const _Palette({
    required this.controller,
    required this.genderOf,
    required this.day,
  });

  final ScheduleController controller;
  final Gender Function(int raceId) genderOf;
  final DateTime? day;

  /// "Séries - Surfski - Dames - Junior" — composed here rather than in the
  /// controller, which has no business resolving a translated gender.
  String _nameFor(UnscheduledRound round, Gender gender) =>
      '${round.type.labelKey.tr} - ${round.raceLabel} - ${gender.label}'
      ' - ${round.categoryLabel}';

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rounds = controller.unscheduledRounds;
      // Resolved here, not in the itemBuilder below: that builder runs during
      // layout, outside this Obx, so reading the épreuve rows from there
      // registers no dependency and the badges stay stale until some other
      // rebuild happens to come along.
      final genders = <int, Gender>{
        for (final r in rounds) r.raceId: genderOf(r.raceId),
      };
      return Container(
        constraints: BoxConstraints(maxHeight: _paletteHeight(context)),
        color: AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text('${'unscheduled'.tr} (${rounds.length})',
                  style: AppTypography.caption),
            ),
            Expanded(
              child: rounds.isEmpty
                  ? Center(
                      child: Text('schedule_all_placed'.tr,
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textMuted)),
                    )
                  : ListView.builder(
                      itemCount: rounds.length,
                      itemBuilder: (_, i) {
                        final round = rounds[i];
                        final gender = genders[round.raceId] ?? Gender.unknown;
                        return _RoundRow(
                          round: round,
                          gender: gender,
                          // No day selected means nowhere to put it.
                          onAdd: day == null
                              ? null
                              : () => controller.scheduleRound(
                                    partieId: round.partieId,
                                    name: _nameFor(round, gender),
                                    day: day!,
                                    courseCount: round.courseCount,
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

class _RoundRow extends StatelessWidget {
  const _RoundRow({
    required this.round,
    required this.gender,
    required this.onAdd,
  });

  final UnscheduledRound round;
  final Gender gender;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      child: Row(
        children: [
          GenderBadge(gender: gender),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${round.type.labelKey.tr} · ${round.raceLabel}',
                  style: AppTypography.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${round.categoryLabel} · '
                  '${'schedule_course_count'.trParams({
                        'count': '${round.courseCount}'
                      })}',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.primary,
            tooltip: 'schedule_place_round'.tr,
          ),
        ],
      ),
    );
  }
}
