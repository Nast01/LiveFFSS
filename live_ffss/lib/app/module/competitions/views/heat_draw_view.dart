import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/module/competitions/controllers/heat_draw_controller.dart';
import 'package:live_ffss/app/module/competitions/views/heat_structure_dialog.dart';
import 'package:live_ffss/app/module/programme/controllers/structure_editor_controller.dart';
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/club_avatar.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

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
        content: Text(m.text),
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

  /// Coastal séries go through a structure check first; everything else draws
  /// straight away. The loop is what lets "Modifier la structure" come back to
  /// the dialog with the numbers the editor just changed.
  Future<void> _draw() async {
    if (!_ctrl.requiresStructureValidation) {
      _ctrl.drawFromPresent();
      return;
    }
    while (true) {
      // Explicit rather than relying on the loop condition: the analyzer only
      // treats an `if (!mounted) return;` immediately before a context use as
      // guarding it, not a `while (mounted)` on the loop itself.
      if (!mounted) return;
      final result = await showDialog<HeatStructureResult>(
        context: context,
        builder: (_) => HeatStructureDialog(
          presentCount: _ctrl.presentCount,
          engagedCount: _ctrl.engagedCount.value,
          declared: _ctrl.declaredPlan,
          proposed: _ctrl.proposedPlan,
        ),
      );
      if (!mounted) return;
      if (result == null) return;
      if (result.plan != null) {
        _ctrl.drawWithPlan(result.plan!);
        return;
      }
      await _openStructureEditor();
      if (!mounted) return;
      // The structure the on-screen heats (if any) were drawn against no
      // longer exists once the editor may have changed it — reopening the
      // dialog on a stale draw is the bug this loop exists to avoid.
      _ctrl.discardDraw();
      await _ctrl.load();
    }
  }

  Future<void> _openStructureEditor() async {
    final race = _ctrl.race.value;
    final competition = _ctrl.competition.value;
    if (race == null || competition == null) return;
    await Get.toNamed<void>(
      Routes.structureEditor,
      // serverDetails stays empty on purpose: the structure exists by the time
      // this dialog opens, so seeding cannot fire, and re-importing the FFSS
      // parties is not worth a network call from the beach.
      arguments: StructureEditorArgs(
        competitionId: competition.id,
        raceId: race.id,
        categoryId: _ctrl.categoryId,
        raceLabel: race.name,
        categoryLabel: _ctrl.categoryLabel,
        entryCount: _ctrl.engagedCount.value,
        gender: race.gender,
        defaultSpotsPerRace: race.defaultSpotsPerRace,
      ),
    );
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
        // No subtitle: the épreuve, gender, category and round are spelled out
        // by _DrawContext just below, and repeating half of them here only
        // competes with it.
        title: Text('heat_draw_title'.tr,
            style: AppTypography.title
                .copyWith(color: Colors.white, fontSize: 16)),
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
            const _DrawContext(),
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
                        const _ClubDistribution(),
                        for (var i = 0; i < _ctrl.heats.length; i++)
                          _HeatCard(
                            index: i,
                            athletes: _ctrl.heats[i],
                            onTapAthlete: _pickTargetHeat,
                          ),
                      ],
                    ),
            ),
            _Actions(onDraw: _draw, onSave: _save),
          ],
        );
      }),
    );
  }
}

/// What this draw is for, spelled out: épreuve, gender, category, round. The
/// round is not selectable here — only the round opening a chain is drawn from
/// the athletes present, and the caller says which one that is.
class _DrawContext extends GetView<HeatDrawController> {
  const _DrawContext();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final race = controller.race.value;
      final parts = <String>[
        if (race != null) ...[race.name, race.gender.label],
        if (controller.categoryLabel.isNotEmpty) controller.categoryLabel,
        if (controller.selectedLevel.value != null)
          controller.selectedLevel.value!.labelKey.tr,
      ];
      if (parts.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
        child: Text(
          parts.join(' · '),
          style: AppTypography.body.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    });
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

/// Club × heat matrix, collapsed by default. The draw spreads clubmates, and
/// this is how the operator checks it did: a cell holding more than one athlete
/// of the same club is the thing worth seeing, so those are the ones coloured.
class _ClubDistribution extends GetView<HeatDrawController> {
  const _ClubDistribution();

  static const double _cellWidth = 34;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final spread = controller.clubDistribution;
      if (spread.isEmpty) return const SizedBox.shrink();
      final heatCount = controller.heats.length;

      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: Theme(
          // The default divider would cut the card in two when expanded.
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            title: Text(
              'heat_draw_distribution'.tr,
              style: AppTypography.body
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(
                AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm),
            children: [
              _HorizontalFade(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderRow(heatCount: heatCount),
                    for (final row in spread) _SpreadRow(row: row),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Scrolls [child] sideways behind a right-edge fade, so a table wider than the
/// screen announces that it continues. The fade tracks the remaining scroll
/// extent and vanishes exactly when there is nothing left to reveal — including
/// when the table fits, where it never appears at all.
class _HorizontalFade extends StatefulWidget {
  const _HorizontalFade({required this.child});

  final Widget child;

  @override
  State<_HorizontalFade> createState() => _HorizontalFadeState();
}

class _HorizontalFadeState extends State<_HorizontalFade> {
  static const double _width = 28;

  final ScrollController _controller = ScrollController();
  double _remaining = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_sync);
    // The first frame is where a table that already overflows has to raise its
    // fade: nothing has scrolled yet, so no scroll event will say so.
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sync() {
    if (!mounted || !_controller.hasClients) return;
    final position = _controller.position;
    final remaining =
        (position.maxScrollExtent - position.pixels).clamp(0.0, _width);
    if (remaining != _remaining) setState(() => _remaining = remaining);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      // A redraw changes the heat count, so the table's width changes without
      // anyone scrolling.
      onNotification: (_) {
        _sync();
        return false;
      },
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            child: widget.child,
          ),
          if (_remaining > 0)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: IgnorePointer(
                // Thins out over the last pixels of travel rather than snapping
                // off when the end is reached.
                child: Opacity(
                  opacity: _remaining / _width,
                  child: Container(
                    width: _width,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.surface.withValues(alpha: 0),
                          AppColors.surface,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.heatCount});

  final int heatCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          const SizedBox(width: 120),
          for (var i = 0; i < heatCount; i++)
            SizedBox(
              width: _ClubDistribution._cellWidth,
              child: Text(
                'S${i + 1}',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SpreadRow extends StatelessWidget {
  const _SpreadRow({required this.row});

  final ClubSpread row;

  @override
  Widget build(BuildContext context) {
    // The unaffiliated pool shares no club, so two of them in one heat is not
    // a clustering — never flag it.
    final flagDuplicates = row.clubId > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              row.label.isEmpty ? 'heat_draw_no_club'.tr : row.label,
              style: AppTypography.caption.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          for (final count in row.perHeat)
            SizedBox(
              width: _ClubDistribution._cellWidth,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: flagDuplicates && count > 1
                      ? AppColors.statusWaiting.withValues(alpha: 0.18)
                      : null,
                  borderRadius: AppRadius.smRadius,
                ),
                child: Text(
                  count == 0 ? '·' : '$count',
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    fontSize: 12,
                    color: count == 0
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                    fontWeight: count > 1 ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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

  /// The resolved club when the index reached this athlete, otherwise whatever
  /// label the entry carried — the same source `ClubAvatar` falls back on.
  String get _clubName => athlete.club?.name.isNotEmpty == true
      ? athlete.club!.name
      : athlete.clubLabel;

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
                  if (_clubName.isNotEmpty)
                    Text(
                      _clubName,
                      style: AppTypography.caption.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
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
  const _Actions({required this.onDraw, required this.onSave});

  final Future<void> Function() onDraw;
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
                    onPressed: onDraw,
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
