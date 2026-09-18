import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/core/const/format_const.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/module/programme/controllers/meeting_editor_controller.dart';
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';
import 'package:live_ffss/app/presentation/modules/programme/day_sections.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/gender_badge.dart';
import 'package:live_ffss/app/presentation/shared/progress_overlay.dart';
import 'package:live_ffss/app/presentation/shared/ui_message_display.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

class MeetingEditorView extends StatefulWidget {
  const MeetingEditorView({super.key});

  @override
  State<MeetingEditorView> createState() => _MeetingEditorViewState();
}

class _MeetingEditorViewState extends State<MeetingEditorView> {
  final _controller = Get.find<MeetingEditorController>();
  final _programme = Get.find<ProgrammeController>();
  late final Worker _messageWorker;
  bool _paletteOpen = false;

  @override
  void initState() {
    super.initState();
    _messageWorker = showUiMessages(_controller.message);
  }

  @override
  void dispose() {
    _messageWorker.dispose();
    super.dispose();
  }

  /// « Séries - Surfski - Dames - Junior » — composé ici et non dans le
  /// contrôleur, qui n'a pas à résoudre un genre traduit.
  String _nameFor(UnscheduledRound round, Gender gender) =>
      '${round.type.labelKey.tr} - ${round.raceLabel} - ${gender.label}'
      ' - ${round.categoryLabel}';

  /// Un nom par course, en ordre de passage : « Demie 1 - Surfski -
  /// Messieurs - Junior ». Le rang tombe quand le tour ne court qu'une course
  /// — « Finale 1 » ne nomme rien de plus que « Finale ».
  /// Nomme la course en position [index] du tour : « Demie 1 - Surfski -
  /// Messieurs - Junior ».
  ///
  /// Par position et non par rang de pose : l'opérateur peut poser la
  /// troisième course seule, et elle doit garder son nom de troisième. Le
  /// rang tombe quand le tour ne court qu'une course — « Finale 1 » ne nomme
  /// rien de plus que « Finale ».
  String _courseNameAt(UnscheduledRound round, Gender gender, int index) =>
      '${heatName(round.type, index, round.courseCount)} - '
      '${round.raceLabel} - ${gender.label} - ${round.categoryLabel}';

  Future<void> _addManualItem() async {
    // Le libellé seulement : l'horaire de l'item n'est pas au choix de
    // l'opérateur, il démarre à la fin de la réunion.
    final labelController = TextEditingController();
    try {
      final label = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('add_manual_item'.tr),
          content: TextField(
            controller: labelController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: 'manual_label'.tr),
            onSubmitted: (value) => Navigator.of(ctx).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(labelController.text),
              child: Text('add_manual_item'.tr),
            ),
          ],
        ),
      );
      final trimmed = label?.trim() ?? '';
      if (trimmed.isEmpty) return;
      await _controller.addManualItem(trimmed);
    } finally {
      labelController.dispose();
    }
  }

  /// The chosen duration in minutes, or null when the operator backed out.
  ///
  /// A ±5-minute stepper with a floor of 5.
  Future<int?> _askDuration(int currentMinutes) async {
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
    return ok == true ? minutes : null;
  }

  Future<void> _editSlotDuration(MeetingItem item) async {
    final current = item.end.difference(item.begin).inMinutes;
    final minutes = await _askDuration(current);
    if (minutes == null || minutes == current) return;
    await _controller.setSlotDuration(item.slotId, minutes);
  }

  Future<void> _editCourseDuration(DayEntry course) async {
    final current = course.end.difference(course.begin).inMinutes;
    final minutes = await _askDuration(current);
    if (minutes == null || minutes == current) return;
    final runId = course.runId;
    if (runId != null) await _controller.setRunDuration(runId, minutes);
  }

  /// A créneau is deleted from the federal server, for everyone, and nothing
  /// on this screen can bring it back — hence the confirmation, the same shape
  /// the round editor uses. The delete icon also sits right next to the
  /// duration tap target, so a miss is easy.
  ///
  /// [count], when given, feeds `@count` alongside `@item` — only bodies
  /// that need it (a round dragging its courses along) declare the
  /// placeholder.
  Future<bool> _confirmRemoval(
    String label, {
    String body = 'schedule_delete_item_body',
    int? count,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('schedule_delete_item_title'.tr),
        content: Text(body.trParams({
          'item': label,
          if (count != null) 'count': '$count',
        })),
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
    return confirmed == true;
  }

  /// Its contract expects a [DayEntry] carrying exactly one of `slotId` /
  /// `runId` — matching how `daySections` builds one — so the call sites
  /// below construct that shape themselves rather than handing it a
  /// `meetingItems()` course entry, which carries both (see
  /// `day_sections.dart`'s doc comment on `slotId`).
  ///
  /// [body]/[count] override the slot branch's default — a round's courses
  /// are named in the confirmation, a manual item is not.
  Future<void> _confirmRemove(DayEntry entry,
      {String? body, int? count}) async {
    final slotId = entry.slotId;
    if (slotId != null) {
      if (await _confirmRemoval(entry.label,
          body: body ?? 'schedule_delete_item_body', count: count)) {
        _controller.removeSlot(slotId);
      }
      return;
    }
    final runId = entry.runId;
    if (runId == null) return;
    // Deleting a course can take its créneau with it — when it was the last
    // one — so the warning says so rather than letting the round vanish.
    if (await _confirmRemoval(entry.label,
        body: body ?? 'schedule_delete_course_body')) {
      _controller.removeRun(runId);
    }
  }

  /// A non-manual item carries its round's courses down with it — the
  /// default body only names the créneau itself, so this names the count too.
  Future<void> _deleteSlot(MeetingItem item) => _confirmRemove(
        DayEntry(
          begin: item.begin,
          end: item.end,
          label: item.label,
          slotId: item.slotId,
        ),
        body: item.isManual ? null : 'schedule_delete_round_body',
        count: item.isManual ? null : item.courses.length,
      );

  Future<void> _deleteCourse(DayEntry course) => _confirmRemove(DayEntry(
        begin: course.begin,
        end: course.end,
        label: course.label,
        runId: course.runId,
      ));

  void _openForm() => Get.toNamed<void>(
        Routes.programmeMeetingForm,
        arguments: {
          'competition': _programme.competition.value,
          'meeting': _controller.meeting,
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Obx(() => Text(
              _controller.meeting?.name ?? '',
              style: AppTypography.title
                  .copyWith(color: Colors.white, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
        actions: [
          // Hidden rather than reachable with no réunion to edit — opening
          // the form with a null `meeting` would create a second one.
          Obx(() => _controller.meeting == null
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: _openForm,
                  tooltip: 'meeting_edit'.tr,
                )),
        ],
      ),
      body: Obx(() {
        final meeting = _controller.meeting;
        if (meeting == null) {
          return EmptyState(
              icon: Icons.event_busy, title: 'schedule_no_meeting'.tr);
        }
        final items = _controller.items;
        return Stack(
          children: [
            // La barre d'actions — et la palette quand elle est ouverte —
            // ferme cette colonne : sans ça, la barre de navigation du
            // téléphone passe par-dessus et les deux boutons deviennent
            // inatteignables. `top: false` parce que l'AppBar tient déjà le
            // haut.
            SafeArea(
              top: false,
              child: Column(
                children: [
                  _Header(
                    date: meeting.date,
                    begin: meeting.beginHour,
                    end: meeting.endHour,
                    site: _controller.site,
                  ),
                  Expanded(
                    child: items.isEmpty
                        ? EmptyState(
                            icon: Icons.playlist_add, title: 'no_items'.tr)
                        : ReorderableListView(
                            padding: AppSpacing.pageAll,
                            onReorder: _controller.reorderItems,
                            children: [
                              for (final item in items)
                                _ItemCard(
                                  key: ValueKey(item.slotId),
                                  item: item,
                                  onEditSlotDuration: () =>
                                      _editSlotDuration(item),
                                  onDeleteSlot: () => _deleteSlot(item),
                                  onEditCourseDuration: _editCourseDuration,
                                  onDeleteCourse: _deleteCourse,
                                ),
                            ],
                          ),
                  ),
                  _Actions(
                    onManual: _addManualItem,
                    onRound: () => setState(() => _paletteOpen = !_paletteOpen),
                  ),
                  if (_paletteOpen)
                    _Palette(
                      controller: _controller,
                      nameFor: _nameFor,
                      nameAt: _courseNameAt,
                      genderOf: _programme.genderForRace,
                    ),
                ],
              ),
            ),
            if (_controller.isBusy.value)
              ProgressOverlay(message: 'meeting_pushing'.tr),
          ],
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.date,
    required this.begin,
    required this.end,
    required this.site,
  });

  final DateTime date;
  final DateTime begin;
  final DateTime end;
  final String site;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE d MMMM', Get.locale?.toString())
                      .format(date),
                  style:
                      AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'schedule_day_range'.trParams({
                    'begin': FormatConst.timeFormat.format(begin),
                    'end': FormatConst.timeFormat.format(end),
                  }),
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (site.isNotEmpty) Text(site, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    super.key,
    required this.item,
    required this.onEditSlotDuration,
    required this.onDeleteSlot,
    required this.onEditCourseDuration,
    required this.onDeleteCourse,
  });

  final MeetingItem item;
  final VoidCallback onEditSlotDuration;
  final VoidCallback onDeleteSlot;
  final void Function(DayEntry course) onEditCourseDuration;
  final void Function(DayEntry course) onDeleteCourse;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        children: [
          ListTile(
            title: Text(item.label, style: AppTypography.body),
            subtitle: Text(FormatConst.timeFormat.format(item.begin),
                style: AppTypography.caption),
            trailing: item.isManual
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: onEditSlotDuration,
                        child: Text(
                            '${item.end.difference(item.begin).inMinutes}'
                            ' ${'min_short'.tr}',
                            style: AppTypography.caption
                                .copyWith(color: AppColors.primaryDark)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        visualDensity: VisualDensity.compact,
                        color: AppColors.textSecondary,
                        onPressed: onDeleteSlot,
                      ),
                    ],
                  )
                : IconButton(
                    icon: const Icon(Icons.delete_outline),
                    visualDensity: VisualDensity.compact,
                    color: AppColors.textSecondary,
                    onPressed: onDeleteSlot,
                  ),
          ),
          if (!item.isManual)
            for (final course in item.courses)
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.only(
                    left: AppSpacing.lg, right: AppSpacing.sm),
                title: Text(course.label, style: AppTypography.body),
                subtitle: Text(FormatConst.timeFormat.format(course.begin),
                    style: AppTypography.caption),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => onEditCourseDuration(course),
                      child: Text(
                          '${course.end.difference(course.begin).inMinutes}'
                          ' ${'min_short'.tr}',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.primaryDark)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      visualDensity: VisualDensity.compact,
                      color: AppColors.textSecondary,
                      onPressed: () => onDeleteCourse(course),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.onManual, required this.onRound});

  final VoidCallback onManual;
  final VoidCallback onRound;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onManual,
              icon: const Icon(Icons.add),
              label: Text('add_manual_item'.tr),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onRound,
              icon: const Icon(Icons.playlist_add),
              label: Text('add_from_round'.tr),
            ),
          ),
        ],
      ),
    );
  }
}

/// Height of the unscheduled palette. A share of the screen rather than a
/// fixed number so a small phone keeps a usable item list above it.
double _paletteHeight(BuildContext context) =>
    (MediaQuery.sizeOf(context).height * 0.35).clamp(150.0, 320.0);

/// Les tours dont au moins une course reste à poser dans cette réunion.
///
/// Chaque tour montre ses courses, les posées grisées : l'opérateur pose
/// tout d'un coup depuis l'en-tête, ou une course à la fois depuis sa
/// ligne.
///
/// No site resolution (`_siteFor`) and no `day` parameter here — the site and
/// the day both come from the réunion itself, not from a chip the operator
/// picked.
class _Palette extends StatelessWidget {
  const _Palette({
    required this.controller,
    required this.nameFor,
    required this.nameAt,
    required this.genderOf,
  });

  final MeetingEditorController controller;
  final String Function(UnscheduledRound round, Gender gender) nameFor;
  final String Function(UnscheduledRound round, Gender gender, int index)
      nameAt;
  final Gender Function(int raceId) genderOf;

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
                          nameAt: (index) => nameAt(round, gender, index),
                          onAdd: (indexes) => controller.scheduleRound(
                            partieId: round.partieId,
                            name: nameFor(round, gender),
                            courses: [
                              for (final index in indexes)
                                (
                                  index: index,
                                  name: nameAt(round, gender, index),
                                ),
                            ],
                            spotsPerRace: round.spotsPerRace,
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
    required this.nameAt,
    required this.onAdd,
  });

  final UnscheduledRound round;
  final Gender gender;
  final String Function(int index) nameAt;

  /// Reçoit les positions à poser : toutes celles qui restent depuis
  /// l'en-tête, une seule depuis une sous-ligne.
  final void Function(List<int> indexes) onAdd;

  @override
  Widget build(BuildContext context) {
    final placed = round.courseCount - round.pendingIndexes.length;
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      round.courseCount == 0
                          ? round.categoryLabel
                          : '${round.categoryLabel} · '
                              '${'course_placed_count'.trParams({
                                  'placed': '$placed',
                                  'total': '${round.courseCount}',
                                })}',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Un tour sans heat tiré n'a que son créneau à poser : le bouton
              // d'en-tête part alors avec une sélection vide, ce que
              // `scheduleRound` traite comme « le créneau seul ».
              IconButton(
                onPressed: () => onAdd(round.pendingIndexes),
                icon: const Icon(Icons.playlist_add_check),
                color: AppColors.primary,
                tooltip: round.courseCount == 0
                    ? 'schedule_place_round'.tr
                    : 'add_all_courses'.tr,
              ),
            ],
          ),
          // Toutes les courses, pas seulement celles qui restent : voir sa
          // progression vaut mieux qu'une liste qui rétrécit sans dire
          // pourquoi.
          for (var index = 0; index < round.courseCount; index++)
            _CourseRow(
              label: nameAt(index),
              placed: !round.pendingIndexes.contains(index),
              onAdd: () => onAdd([index]),
            ),
        ],
      ),
    );
  }
}

/// Une course d'un tour de la palette : posable, ou déjà posée et grisée.
class _CourseRow extends StatelessWidget {
  const _CourseRow({
    required this.label,
    required this.placed,
    required this.onAdd,
  });

  final String label;
  final bool placed;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 36, bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: placed ? AppColors.textMuted : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (placed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                'course_already_placed'.tr,
                style:
                    AppTypography.caption.copyWith(color: AppColors.textMuted),
              ),
            )
          else
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              color: AppColors.primary,
              tooltip: 'schedule_place_round'.tr,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
