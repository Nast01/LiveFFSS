import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:live_ffss/app/core/const/format_const.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/domain/models/meeting.dart';
import 'package:live_ffss/app/module/programme/controllers/meeting_list_controller.dart';
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/presentation/shared/progress_overlay.dart';
import 'package:live_ffss/app/presentation/shared/ui_message_display.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

class MeetingListView extends StatefulWidget {
  const MeetingListView({super.key});

  @override
  State<MeetingListView> createState() => _MeetingListViewState();
}

class _MeetingListViewState extends State<MeetingListView> {
  final _controller = Get.find<MeetingListController>();
  final _programme = Get.find<ProgrammeController>();
  Worker? _compWorker;
  late final Worker _messageWorker;

  @override
  void initState() {
    super.initState();
    // La compétition arrive par l'onglet Structure, qui la porte.
    _compWorker = ever<Competition?>(_programme.competition, _onCompetition);
    _onCompetition(_programme.competition.value);
    _messageWorker = showUiMessages(_controller.message);
  }

  @override
  void dispose() {
    _compWorker?.dispose();
    _messageWorker.dispose();
    super.dispose();
  }

  // Sans attendre : la liste rend elle-même son isLoading et son hasError.
  void _onCompetition(Competition? comp) =>
      unawaited(_controller.setCompetition(comp));

  /// Le nom du jour suit **la langue de l'application** : il s'affichera comme
  /// ça sur le site fédéral si l'opérateur le reprend dans un titre.
  String _dayLabel(DateTime day) =>
      DateFormat('EEEE d MMMM', Get.locale?.toString()).format(day);

  Future<void> _openForm({Meeting? meeting}) async {
    // `Get.toNamed` returns a nullable Future — awaiting it directly is fine
    // and keeps this a plain `Future<void>` for its callers.
    await Get.toNamed<void>(
      Routes.programmeMeetingForm,
      arguments: {
        'competition': _controller.competition.value,
        'meeting': meeting,
      },
    );
  }

  void _openEditor(Meeting meeting) => Get.toNamed<void>(
        Routes.programmeMeeting,
        arguments: {'meetingId': meeting.id},
      );

  Future<void> _confirmDelete(Meeting meeting) async {
    // Le décompte compte les courses, pas les créneaux : c'est ce que
    // l'opérateur perd en supprimant la réunion, même si l'éditeur les montre
    // groupées sous leur créneau plutôt qu'à plat.
    final count = meeting.slots.fold<int>(
      0,
      (sum, slot) => sum + (slot.runs.isEmpty ? 1 : slot.runs.length),
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('meeting_delete_title'.tr),
        content: Text('meeting_delete_body'.trParams({
          'name': meeting.name,
          'count': '$count',
        })),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await _controller.deleteMeeting(meeting.id);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Widget content;
      if (_controller.isLoading.value) {
        content = const LoadingIndicator();
      } else if (_controller.hasError.value) {
        content = ErrorState(
          message: 'error_occured'.tr,
          onRetry: _controller.reloadFromServer,
        );
      } else if (_controller.days.isEmpty) {
        content = EmptyState(icon: Icons.event_busy, title: 'no_days'.tr);
      } else {
        content = _list();
      }
      return Stack(
        children: [
          content,
          if (_controller.isDeleting.value)
            ProgressOverlay(message: 'meeting_pushing'.tr),
        ],
      );
    });
  }

  Widget _list() {
    final days = _controller.days;
    final empty = _controller.meetings.isEmpty;
    final unscheduled = _controller.unscheduledRoundCount;
    final offDates = _controller.meetingsOffDates;

    return RefreshIndicator(
      onRefresh: _controller.reloadFromServer,
      child: ListView(
        // Le bouton « nouvelle réunion » ferme cette liste : sans le retrait
        // de la barre de navigation, il reste sous elle au bout du défilement.
        padding: AppSpacing.pageAll.add(
          EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
        ),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => Get.toNamed<void>(Routes.programmeSites),
              icon: const Icon(Icons.place_outlined, size: 18),
              label: Text('${'sites'.tr} (${_controller.sites.length})'),
            ),
          ),
          // Informatif et non cliquable : placer un tour demande une réunion
          // cible, geste qui n'a de sens que dans l'éditeur.
          if (unscheduled > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 18, color: AppColors.statusWaiting),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'unscheduled_round_count'
                        .trParams({'count': '$unscheduled'}),
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
          if (empty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: EmptyState(
                icon: Icons.event_note_outlined,
                title: 'no_meetings'.tr,
              ),
            ),
          for (final day in days) ..._daySection(day),
          if (offDates.isNotEmpty) ..._offDatesSection(offDates),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add),
            label: Text('meeting_new'.tr),
          ),
        ],
      ),
    );
  }

  /// FFSS peut porter des réunions que la compétition n'annonce plus dans ses
  /// dates : sans ce groupe, elles ne seraient ni visibles, ni éditables, ni
  /// supprimables.
  List<Widget> _offDatesSection(List<Meeting> meetings) {
    return [
      Padding(
        padding:
            const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
        child: Text(
          'meetings_off_dates'.tr.toUpperCase(),
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      ),
      for (final meeting in meetings)
        _MeetingCard(
            meeting: meeting,
            onTap: () => _openEditor(meeting),
            onEdit: () => _openForm(meeting: meeting),
            onDelete: () => _confirmDelete(meeting)),
    ];
  }

  List<Widget> _daySection(DateTime day) {
    final held = _controller.meetingsOn(day);
    return [
      Padding(
        padding:
            const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
        child: Text(
          _dayLabel(day).toUpperCase(),
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      ),
      if (held.isEmpty)
        Text(
          'no_meeting_on_day'.tr,
          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
        ),
      for (final meeting in held)
        _MeetingCard(
            meeting: meeting,
            onTap: () => _openEditor(meeting),
            onEdit: () => _openForm(meeting: meeting),
            onDelete: () => _confirmDelete(meeting)),
    ];
  }
}

class _MeetingCard extends StatelessWidget {
  const _MeetingCard({
    required this.meeting,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Meeting meeting;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final items = meeting.slots.fold<int>(
      0,
      (sum, slot) => sum + (slot.runs.isEmpty ? 1 : slot.runs.length),
    );
    final range = 'schedule_day_range'.trParams({
      'begin': FormatConst.timeFormat.format(meeting.beginHour),
      'end': FormatConst.timeFormat.format(meeting.endHour),
    });
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: onTap,
        title: Text(meeting.name.isEmpty ? '—' : meeting.name,
            style: AppTypography.body),
        subtitle: Text(
          '$range · ${'meeting_item_count'.trParams({'count': '$items'})}'
          '${meeting.site.isEmpty ? '' : ' · ${meeting.site}'}',
          style: AppTypography.caption,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
          itemBuilder: (_) => [
            PopupMenuItem(value: 'edit', child: Text('edit_item'.tr)),
            PopupMenuItem(value: 'delete', child: Text('delete'.tr)),
          ],
        ),
      ),
    );
  }
}
