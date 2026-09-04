import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/course_penalty.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_course_controller.dart';
import 'package:live_ffss/app/presentation/modules/competitions/course_formatting.dart';
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
        content: Text(m.text),
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
            const _ModeBar(),
            const _EntryBar(),
            Expanded(
              child: ListView.builder(
                // The list runs to the bottom of the screen, so it clears the
                // system navigation bar itself — otherwise the last
                // competitors sit under it, out of reach however far the list
                // is scrolled. The bar above never needs this: it is not the
                // one touching the edge.
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.lg + MediaQuery.of(context).viewPadding.bottom,
                ),
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

/// The place, typed. Digits only — a rank is a whole number — and committed
/// when the field loses focus or the keyboard is validated, never on each
/// keystroke: typing « 12 » would otherwise rank the athlete first in passing.
///
/// Its own widget because the text controller belongs to one row and must
/// follow the model back: sharing a number declares a tie, so the place that
/// comes back can differ from the one typed.
class _PlaceField extends StatefulWidget {
  const _PlaceField({required this.athlete, required this.place});

  final Athlete athlete;
  final int? place;

  @override
  State<_PlaceField> createState() => _PlaceFieldState();
}

class _PlaceFieldState extends State<_PlaceField> {
  late final TextEditingController _text =
      TextEditingController(text: widget.place?.toString() ?? '');
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _commit();
    });
  }

  @override
  void didUpdateWidget(_PlaceField old) {
    super.didUpdateWidget(old);
    // The ranking moved under us — a tie renumbered the rest, or another row
    // was edited. Never while typing: that would fight the operator.
    if (!_focus.hasFocus && widget.place != old.place) {
      _text.text = widget.place?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    _text.dispose();
    super.dispose();
  }

  void _commit() {
    final typed = int.tryParse(_text.text.trim()) ?? 0;
    Get.find<RaceCourseController>().setPlace(widget.athlete, typed);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _text,
      focusNode: _focus,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _commit(),
      style: AppTypography.body
          .copyWith(fontWeight: FontWeight.w800, color: AppColors.primaryDark),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 6),
        border: OutlineInputBorder(),
      ),
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

/// How places are entered. Sits above everything else because it changes what
/// every row below does.
class _ModeBar extends GetView<RaceCourseController> {
  const _ModeBar();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mode = controller.entryMode.value;
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
        child: SegmentedButton<CourseEntryMode>(
          segments: [
            ButtonSegment(
              value: CourseEntryMode.automatic,
              icon: const Icon(Icons.playlist_add_check, size: 18),
              label: Text('course_mode_automatic'.tr),
            ),
            ButtonSegment(
              value: CourseEntryMode.manual,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text('course_mode_manual'.tr),
            ),
          ],
          selected: {mode},
          showSelectedIcon: false,
          onSelectionChanged: (s) => controller.setEntryMode(s.first),
        ),
      );
    });
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The state line keeps a row to itself: « Tous les athlètes sont
            // classés » is long enough to push the actions off-screen when
            // they share it. Expanded rather than Spacer, so it ellipses
            // instead of overflowing on a narrow phone.
            Row(
              children: [
                Text('course_next_place'.tr, style: AppTypography.caption),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    complete
                        ? 'course_complete'.tr
                        : '${controller.nextPlaceValue}'
                            '${locked ? ' · ${'course_tie_locked'.tr}' : ''}',
                    style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w800,
                        color: complete
                            ? AppColors.statusFinished
                            : AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
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
                const Spacer(),
                // Available whatever the state of the ranking: each press
                // republishes and recomputes the next round whole, so an
                // early one is corrected by the next rather than by an undo.
                ElevatedButton.icon(
                  onPressed: controller.isPublishing.value
                      ? null
                      : controller.validate,
                  icon: controller.isPublishing.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: Text('course_validate'.tr),
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
      final manual = controller.entryMode.value == CourseEntryMode.manual;
      final club = athlete.club?.name.isNotEmpty == true
          ? athlete.club!.name
          : athlete.clubLabel;
      final badge = courseBadgeLabel(place, penalty);
      final badgeColor = courseBadgeColor(place, penalty);

      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: GestureDetector(
          // The row no longer assigns on tap: brushing one while scrolling
          // ranked whoever it was, which is the handling problem this mode bar
          // exists to fix. Only the trailing control assigns now; the long
          // press still opens the menu.
          onLongPressStart: (d) => onMenu(d.globalPosition),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: AppRadius.mdRadius,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: manual && penalty == null
                        ? _PlaceField(athlete: athlete, place: place)
                        : Text(badge,
                            textAlign: TextAlign.center,
                            style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w800,
                                color: badgeColor)),
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
                  // Automatic mode's one way to rank: an explicit target,
                  // not the whole row. Ranked already, it takes the place back.
                  if (!manual && penalty == null)
                    IconButton(
                      onPressed: onTap,
                      icon: Icon(place == null
                          ? Icons.add_circle_outline
                          : Icons.remove_circle_outline),
                      iconSize: 22,
                      visualDensity: VisualDensity.compact,
                      color: place == null
                          ? AppColors.primary
                          : AppColors.textMuted,
                      tooltip: place == null
                          ? 'course_assign'.tr
                          : 'course_unassign'.tr,
                    ),
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
