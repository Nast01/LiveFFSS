import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/const/format_const.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/course_penalty.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/module/competitions/controllers/race_structure_controller.dart';
import 'package:live_ffss/app/presentation/modules/competitions/course_formatting.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/club_avatar.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

class RaceStructureView extends GetView<RaceStructureController> {
  const RaceStructureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingIndicator();
      }
      final tab = controller.hasStructure ? controller.selectedTab : null;
      // The empty state is refreshable too, and that is the case that matters
      // most: a second device lands here until the déroulement reaches it.
      if (tab == null) return const _RefreshableEmpty();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _RoundBar(),
          Expanded(child: _RoundPane(tab: tab)),
        ],
      );
    });
  }
}

/// « Nothing here yet », pullable — a `RefreshIndicator` needs a scrollable
/// child, and an `EmptyState` is not one, hence the single-item list.
class _RefreshableEmpty extends StatelessWidget {
  const _RefreshableEmpty();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RaceStructureController>();
    return RefreshIndicator(
      onRefresh: controller.reload,
      child: LayoutBuilder(
        builder: (context, constraints) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: EmptyState(
                icon: Icons.account_tree_outlined,
                title: 'no_structure_defined'.tr,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The round menu bar: one pill per category × round, scrolling sideways when
/// the race carries more than a screenful.
class _RoundBar extends StatelessWidget {
  const _RoundBar();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RaceStructureController>();
    return Obx(() {
      final tabs = controller.tabs;
      final selected = controller.selectedTabIndex.value;
      // On a single-category race the category is the same on every pill, so
      // repeating it there says nothing — the round alone identifies the tab.
      final withCategory = controller.showCategoryHeaders;
      return SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: AppSpacing.pageHorizontal,
          itemCount: tabs.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (_, i) {
            final tab = tabs[i];
            final active = i == selected;
            final label = withCategory
                ? '${tab.categoryLabel} · ${tab.type.labelKey.tr}'
                : tab.type.labelKey.tr;
            return GestureDetector(
              onTap: () => controller.selectTab(i),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.surface,
                  borderRadius: AppRadius.pillRadius,
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                      color: active ? Colors.white : AppColors.textPrimary),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

/// What the selected pill opens: the chain recap of its category, the draw
/// action, then the races of that one round.
class _RoundPane extends StatelessWidget {
  const _RoundPane({required this.tab});
  final RoundTab tab;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RaceStructureController>();
    final structure = tab.structure;
    final level = tab.level;
    // The page above uses SafeArea(bottom: false) for an edge-to-edge list, so
    // the scroll content clears the system navigation bar itself — otherwise
    // the last card sits under it, unreachable however far the list is pulled.
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    return RefreshIndicator(
      onRefresh: controller.reload,
      child: ListView(
        // Always scrollable: a round of one série does not fill the screen,
        // and the gesture has to work there too.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.lg + bottomInset,
        ),
        children: [
          _ChainRecap(
            structure: structure,
            engaged: controller.entryCountFor(structure.categoryId),
          ),
          _SlotRecap(level: level),
          // Only the round that opens the chain is drawn from the athletes
          // present; the later ones are seated by who qualifies out of it.
          if (tab.isFirstRound)
            _DrawHeatsButton(structure: structure, roundType: level.type),
          if (level.races.isNotEmpty) const _FilterBar(),
          if (level.races.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text('no_races_in_round'.tr,
                  style: AppTypography.caption, textAlign: TextAlign.center),
            )
          else
            Obx(() {
              final visible = controller.matchingRaces(level.races);
              if (visible.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text('no_athletes_found'.tr,
                      style: AppTypography.caption,
                      textAlign: TextAlign.center),
                );
              }
              return Column(
                children: [
                  _RaceListHeader(visible: visible, total: level.races.length),
                  for (final r in visible)
                    _CourseTile(structure: structure, level: level, race: r),
                ],
              );
            }),
        ],
      ),
    );
  }
}

/// The créneaux this round was scheduled into, one line each: where it runs
/// and when.
///
/// Silent when the round has not been placed yet — an absent créneau is the
/// ordinary state of a structure being authored, not something to warn about.
class _SlotRecap extends StatelessWidget {
  const _SlotRecap({required this.level});
  final RoundLevel level;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RaceStructureController>();
    return Obx(() {
      final slots = controller.slotsForLevel(level);
      if (slots.isEmpty) return const SizedBox.shrink();
      final sites = controller.sitesOfLevel(level);
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final slot in slots)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 14, color: AppColors.primaryDark),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${FormatConst.timeFormat.format(slot.beginHour)}'
                        ' → ${FormatConst.timeFormat.format(slot.endHour)}'
                        '${sites.isEmpty ? '' : ' · ${sites.join(' · ')}'}',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.primaryDark),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

/// The whole chain of the selected category, so the structure stays readable
/// while only one of its rounds is on screen.
class _ChainRecap extends StatelessWidget {
  const _ChainRecap({required this.structure, required this.engaged});
  final EventStructure structure;
  final int engaged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${structure.categoryLabel} · $engaged ${'engaged'.tr}',
              style: AppTypography.subtitle),
          const SizedBox(height: 2),
          Text(structure.chainSummary, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _DrawHeatsButton extends StatelessWidget {
  const _DrawHeatsButton({required this.structure, required this.roundType});
  final EventStructure structure;
  final RoundType roundType;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RaceStructureController>();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.shuffle, size: 18),
          label: Text('heat_draw_action'.tr),
          onPressed: () async {
            await Get.toNamed<void>(Routes.heatDraw, arguments: {
              'race': controller.race.value,
              'competition': controller.competition.value,
              'categoryId': structure.categoryId,
              'categoryLabel': structure.categoryLabel,
              // Opens the draw on the round being shown rather than on the
              // first one of the structure.
              'roundType': roundType,
            });
            // The draw writes into the programme, so the structure shown here
            // is stale on the way back.
            final race = controller.race.value;
            final competition = controller.competition.value;
            if (race != null && competition != null) {
              await controller.load(race, competition);
            }
          },
        ),
      ),
    );
  }
}

/// Narrows the round to the races holding a given athlete, and carries the
/// expand-all control — both act on the same list, so they belong together.
///
/// The text controller lives here rather than on the GetX controller: it is
/// scoped to this one field, which is what makes the view stateful.
class _FilterBar extends StatefulWidget {
  const _FilterBar();

  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  final TextEditingController _field = TextEditingController();

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RaceStructureController>();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _field,
              onChanged: controller.setFilter,
              textInputAction: TextInputAction.search,
              style: AppTypography.body.copyWith(fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppColors.surface,
                hintText: 'filter_athlete_hint'.tr,
                hintStyle: AppTypography.caption.copyWith(fontSize: 13),
                prefixIcon: const Icon(Icons.search,
                    size: 18, color: AppColors.textMuted),
                suffixIcon: Obx(() => controller.filter.value.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: AppColors.textMuted,
                        onPressed: () {
                          _field.clear();
                          controller.setFilter('');
                        },
                      )),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.smRadius,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.smRadius,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sits directly above the races and says what the list is showing, with the
/// control that opens or closes all of it. Above the list rather than inside
/// the filter bar: an icon wedged against a text field reads as part of the
/// field, not as an action on what follows.
class _RaceListHeader extends StatelessWidget {
  const _RaceListHeader({required this.visible, required this.total});

  /// The races actually on screen — what the toggle acts on.
  final List<ProgrammeRace> visible;
  final int total;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RaceStructureController>();
    return Obx(() {
      final filtering = controller.filter.value.isNotEmpty;
      final all = controller.allExpanded(visible);
      final label = 'heats'.tr.toLowerCase();
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: Row(
          children: [
            Text(
              filtering ? '${visible.length} / $total $label' : '$total $label',
              style: AppTypography.caption,
            ),
            const Spacer(),
            // While filtering, every surviving race is already open, so the
            // toggle could only lie about what pressing it would do.
            if (!filtering)
              TextButton.icon(
                onPressed: () => all
                    ? controller.collapseAll()
                    : controller.expandAll(visible),
                icon:
                    Icon(all ? Icons.unfold_less : Icons.unfold_more, size: 18),
                label: Text(all ? 'collapse_all'.tr : 'expand_all'.tr),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  textStyle: AppTypography.caption,
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({
    required this.structure,
    required this.level,
    required this.race,
  });
  final EventStructure structure;
  final RoundLevel level;
  final ProgrammeRace race;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RaceStructureController>();
    final accent = level.type == RoundType.finale
        ? AppColors.statusFinished
        : AppColors.primary;
    final athletes = controller.athletesOf(race);
    final expanded = controller.isExpanded(race);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.mdRadius,
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: AppRadius.mdRadius,
              onTap: () async {
                await Get.toNamed<void>(Routes.raceCourse, arguments: {
                  'race': controller.race.value,
                  'competition': controller.competition.value,
                  'categoryId': structure.categoryId,
                  'categoryLabel': structure.categoryLabel,
                  'roundType': level.type,
                  'raceNumber': race.number,
                  'programmeRaceId': race.id,
                });
                // The result screen writes into the same programme, so the
                // structure shown here is stale on the way back.
                final r = controller.race.value;
                final competition = controller.competition.value;
                if (r != null && competition != null) {
                  await controller.load(r, competition);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: AppRadius.smRadius,
                      ),
                      child: Text('${race.number}',
                          style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w800, color: accent)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              heatName(level.type, race.number - 1,
                                  level.races.length),
                              style: AppTypography.body
                                  .copyWith(color: AppColors.textPrimary)),
                          if (race.athleteIds.isNotEmpty)
                            Text(
                              '${race.athleteIds.length} ${'athletes_lower'.tr}',
                              style: AppTypography.caption,
                            ),
                          if (controller.scheduleFor(level, race)
                              case final RaceSchedule schedule)
                            Row(
                              children: [
                                Text(
                                  '${FormatConst.timeFormat.format(schedule.run.beginTime)}'
                                  '${schedule.run.site.isEmpty ? '' : ' · ${schedule.run.site}'}',
                                  style: AppTypography.caption
                                      .copyWith(color: AppColors.primaryDark),
                                ),
                                // A heat that recorded no course of its own was
                                // matched by rank. Ordinarily right, but the
                                // operator should know which of the two it is
                                // before trusting it on a start line.
                                if (schedule.isGuess) ...[
                                  const SizedBox(width: 4),
                                  Tooltip(
                                    message: 'heat_course_guessed'.tr,
                                    child: const Icon(Icons.help_outline,
                                        size: 13, color: AppColors.textMuted),
                                  ),
                                ],
                              ],
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted),
                    if (athletes.isNotEmpty)
                      // Its own tap target, so the row keeps opening the entry
                      // page — the gesture the operator already knows.
                      IconButton(
                        onPressed: () => controller.toggleExpanded(race),
                        icon: Icon(
                            expanded ? Icons.expand_less : Icons.expand_more),
                        color: AppColors.textMuted,
                        visualDensity: VisualDensity.compact,
                        tooltip: 'athletes'.tr,
                      ),
                  ],
                ),
              ),
            ),
            if (expanded)
              for (var i = 0; i < athletes.length; i++)
                _CompetitorRow(
                  athlete: athletes[i],
                  last: i == athletes.length - 1,
                  highlighted: controller.filter.value.isNotEmpty &&
                      controller.matchesFilter(athletes[i]),
                  place: controller.placeIn(race, athletes[i]),
                  penalty: controller.penaltyIn(race, athletes[i]),
                ),
          ],
        ),
      ),
    );
  }
}

/// One competitor of a drawn race. The left badge shows the finishing place,
/// or a mention (DQ, FF…) for a withdrawal; the right slot carries the
/// disqualification code. Both stay blank until the race has been scored.
class _CompetitorRow extends StatelessWidget {
  const _CompetitorRow({
    required this.athlete,
    required this.last,
    required this.highlighted,
    required this.place,
    required this.penalty,
  });

  final Athlete athlete;
  final bool last;

  /// Whether this is one of the athletes the filter went looking for.
  final bool highlighted;

  /// The place this athlete took, null while the race has no result.
  final int? place;

  /// The withdrawal they carry, if any.
  final CoursePenalty? penalty;

  @override
  Widget build(BuildContext context) {
    final club = athlete.club?.name.isNotEmpty == true
        ? athlete.club!.name
        : athlete.clubLabel;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primarySurface : null,
        border: last
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              courseBadgeLabel(place, penalty),
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w800,
                color: courseBadgeColor(place, penalty),
              ),
            ),
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
                  Text(
                    club,
                    style: AppTypography.caption.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            penalty?.code.isNotEmpty == true ? penalty!.code : '—',
            style: AppTypography.caption.copyWith(
                color: penalty?.code.isNotEmpty == true
                    ? AppColors.statusError
                    : AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
