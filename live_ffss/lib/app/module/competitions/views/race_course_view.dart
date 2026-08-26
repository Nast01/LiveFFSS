import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/course_penalty.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_course_controller.dart';
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/club_avatar.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

class RaceCourseView extends StatefulWidget {
  const RaceCourseView({super.key});

  @override
  State<RaceCourseView> createState() => _RaceCourseViewState();
}

class _RaceCourseViewState extends State<RaceCourseView> {
  late final RaceCourseController _ctrl;
  late final Worker _messageWorker;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<RaceCourseController>();
    _messageWorker = ever<UiMessage?>(_ctrl.message, (m) {
      if (m == null || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(m.translationKey.tr),
        backgroundColor:
            m is UiMessageError ? AppColors.statusError : AppColors.primary,
      ));
    });
  }

  @override
  void dispose() {
    _messageWorker.dispose();
    super.dispose();
  }

  /// The row menu. Tapping a row is the fast path; this is where the cases that
  /// are not "they finished" live.
  Future<void> _openRowMenu(Athlete athlete, Offset at) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final ranked = _ctrl.placeOf(athlete) != null;
    final withdrawn = _ctrl.penaltyOf(athlete) != null;
    final action = await showMenu<String>(
      context: context,
      position:
          RelativeRect.fromRect(at & Size.zero, Offset.zero & overlay.size),
      items: [
        if (!withdrawn) ...[
          PopupMenuItem(value: 'forfeit', child: Text('course_forfeit'.tr)),
          PopupMenuItem(value: 'dq', child: Text('course_disqualify'.tr)),
        ],
        if (ranked)
          PopupMenuItem(value: 'unrank', child: Text('course_unrank'.tr)),
        if (withdrawn)
          PopupMenuItem(value: 'reinstate', child: Text('course_reinstate'.tr)),
      ],
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'forfeit':
        _ctrl.setPenalty(athlete, CoursePenaltyKind.forfeit);
      case 'dq':
        await _askDisqualification(athlete);
      case 'unrank':
        _ctrl.remove(athlete);
      case 'reinstate':
        _ctrl.clearPenalty(athlete);
    }
  }

  Future<void> _askDisqualification(Athlete athlete) async {
    final field = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('course_dq_title'.tr),
        content: TextField(
          controller: field,
          autofocus: true,
          decoration: InputDecoration(labelText: 'course_dq_code'.tr),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(field.text.trim()),
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
    field.dispose();
    if (code == null) return;
    _ctrl.setPenalty(athlete, CoursePenaltyKind.disqualified, code: code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('course_title'.tr,
            style: AppTypography.title
                .copyWith(color: Colors.white, fontSize: 16)),
      ),
      body: Obx(() {
        if (_ctrl.isLoading.value) return const LoadingIndicator();
        if (_ctrl.athletes.isEmpty) {
          return EmptyState(
              icon: Icons.timer_outlined, title: 'no_athletes_found'.tr);
        }
        final rows = _ctrl.orderedAthletes;
        return Column(
          children: [
            const _CourseContext(),
            const _EntryBar(),
            Expanded(
              child: ListView.builder(
                padding: AppSpacing.pageAll,
                itemCount: rows.length,
                itemBuilder: (_, i) => _CompetitorRow(
                  athlete: rows[i],
                  onTap: () => _ctrl.placeOf(rows[i]) == null
                      ? _ctrl.assign(rows[i])
                      : _ctrl.remove(rows[i]),
                  onMenu: (at) => _openRowMenu(rows[i], at),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// What is being scored: épreuve, gender, category, round.
class _CourseContext extends GetView<RaceCourseController> {
  const _CourseContext();

  @override
  Widget build(BuildContext context) {
    final race = controller.race.value;
    final parts = <String>[
      if (race != null) ...[race.name, race.gender.label],
      if (controller.categoryLabel.isNotEmpty) controller.categoryLabel,
      '${controller.roundType.labelKey.tr} ${controller.raceNumber}',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          parts.join(' · '),
          style: AppTypography.body
              .copyWith(fontSize: 13, fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// The next place, the tie lock, undo and the scan toggle — the one place the
/// operator checks that the screen agrees with them.
class _EntryBar extends GetView<RaceCourseController> {
  const _EntryBar();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final complete = controller.isComplete;
      final locked = controller.tieLock.value;
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
        child: Column(
          children: [
            Row(
              children: [
                Text('course_next_place'.tr, style: AppTypography.caption),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  complete
                      ? 'course_complete'.tr
                      : '${controller.nextPlaceValue}'
                          '${locked ? ' · ${'course_tie_locked'.tr}' : ''}',
                  style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w800,
                      color: complete
                          ? AppColors.statusFinished
                          : AppColors.textPrimary),
                ),
                const Spacer(),
                FilterChip(
                  label: Text('course_tie'.tr),
                  selected: locked,
                  onSelected: (_) => controller.toggleTieLock(),
                ),
                IconButton(
                  onPressed:
                      controller.finishOrder.isEmpty ? null : controller.undo,
                  icon: const Icon(Icons.undo),
                  tooltip: 'course_undo'.tr,
                ),
              ],
            ),
            if (controller.canScan && !complete)
              SizedBox(
                width: double.infinity,
                child: controller.isScanning.value
                    ? ElevatedButton.icon(
                        onPressed: controller.stopScan,
                        icon: const Icon(Icons.stop),
                        label: Text('course_scan_stop'.tr),
                      )
                    : OutlinedButton.icon(
                        onPressed: controller.startScan,
                        icon: const Icon(Icons.nfc),
                        label: Text('course_scan'.tr),
                      ),
              ),
          ],
        ),
      );
    });
  }
}

class _CompetitorRow extends GetView<RaceCourseController> {
  const _CompetitorRow({
    required this.athlete,
    required this.onTap,
    required this.onMenu,
  });

  final Athlete athlete;
  final VoidCallback onTap;
  final ValueChanged<Offset> onMenu;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final place = controller.placeOf(athlete);
      final penalty = controller.penaltyOf(athlete);
      final club = athlete.club?.name.isNotEmpty == true
          ? athlete.club!.name
          : athlete.clubLabel;
      final badge = switch (penalty?.kind) {
        CoursePenaltyKind.forfeit => 'forfeit_short'.tr,
        CoursePenaltyKind.disqualified => 'disqualified_short'.tr,
        _ => place?.toString() ?? '—',
      };
      final badgeColor = penalty != null
          ? AppColors.statusError
          : place != null
              ? AppColors.primary
              : AppColors.textMuted;

      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: GestureDetector(
          // InkWell has no onLongPressStart in this Flutter version; a
          // GestureDetector layered over it supplies the position without
          // taking over the tap the InkWell needs for its ripple.
          onLongPressStart: (d) => onMenu(d.globalPosition),
          child: InkWell(
            borderRadius: AppRadius.mdRadius,
            // A withdrawn athlete has no place to take; the menu reinstates them.
            onTap: penalty == null ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              child: Row(
                children: [
                  SizedBox(
                    width: 34,
                    child: Text(badge,
                        textAlign: TextAlign.center,
                        style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w800, color: badgeColor)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ClubAvatar(
                    club: athlete.club,
                    size: 28,
                    shape: ClubAvatarShape.circle,
                    fallbackLabel: club,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${athlete.lastName.toUpperCase()} ${athlete.firstName}'
                              .trim(),
                          style: AppTypography.body.copyWith(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (club.isNotEmpty)
                          Text(club,
                              style:
                                  AppTypography.caption.copyWith(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  if (penalty?.code.isNotEmpty == true) ...[
                    Text(penalty!.code,
                        style: AppTypography.caption
                            .copyWith(color: AppColors.statusError)),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Builder(
                    builder: (btnContext) => IconButton(
                      onPressed: () {
                        final box = btnContext.findRenderObject() as RenderBox;
                        onMenu(box.localToGlobal(Offset.zero));
                      },
                      icon: const Icon(Icons.more_vert),
                      color: AppColors.textMuted,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
