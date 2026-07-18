import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/const/format_const.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:live_ffss/app/module/programme/controllers/schedule_controller.dart';
import 'package:live_ffss/app/module/programme/views/sites_view.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
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
  Worker? _messageWorker;

  @override
  void initState() {
    super.initState();
    // Feed the loaded competition (and its dates) into the schedule controller,
    // now and whenever it changes.
    _compWorker = ever(_programme.competition, _controller.setCompetition);
    _controller.setCompetition(_programme.competition.value);
    _messageWorker = ever<UiMessage?>(_controller.message, (m) {
      if (m is UiMessageError && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(m.translationKey.tr)));
      }
    });
  }

  @override
  void dispose() {
    _compWorker?.dispose();
    _messageWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.days.isEmpty) {
        return EmptyState(icon: Icons.event_busy, title: 'no_days'.tr);
      }
      return Column(
        children: [
          _DayBar(controller: _controller),
          Padding(
            padding: AppSpacing.pageHorizontal,
            child: Row(
              children: [
                Expanded(child: _SitePicker(controller: _controller)),
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'sites'.tr,
                  onPressed: () => Get.to<void>(() => const SitesView()),
                ),
              ],
            ),
          ),
          Expanded(child: _SiteTimeline(controller: _controller)),
          const Divider(height: 1),
          _UnscheduledPalette(controller: _controller),
        ],
      );
    });
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({required this.controller});
  final ScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Obx(() {
        final selectedIndex = controller.selectedDayIndex.value;
        return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.pageHorizontal,
            itemCount: controller.days.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (_, i) {
              final active = selectedIndex == i;
              final day = controller.days[i];
              return GestureDetector(
                onTap: () => controller.selectedDayIndex.value = i,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.surface,
                    borderRadius: AppRadius.pillRadius,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    FormatConst.dateFormat.format(day),
                    style: AppTypography.caption.copyWith(
                      color: active ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            },
          );
      }),
    );
  }
}

class _SitePicker extends StatelessWidget {
  const _SitePicker({required this.controller});
  final ScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sites = controller.sites;
      if (sites.isEmpty) {
        return Text('no_sites'.tr, style: AppTypography.caption);
      }
      return DropdownButton<int>(
        isExpanded: true,
        value: controller.selectedSiteId.value,
        items: [
          for (final s in sites)
            DropdownMenuItem(value: s.id, child: Text(s.name)),
        ],
        onChanged: (v) => controller.selectedSiteId.value = v,
      );
    });
  }
}

class _SiteTimeline extends StatelessWidget {
  const _SiteTimeline({required this.controller});
  final ScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final siteId = controller.selectedSiteId.value;
      final day = controller.selectedDay;
      if (siteId == null || day == null) {
        return EmptyState(icon: Icons.place_outlined, title: 'no_sites'.tr);
      }
      final placed = controller.placedOn(siteId, day);
      if (placed.isEmpty) {
        return EmptyState(
            icon: Icons.schedule, title: 'no_placement_here'.tr);
      }
      return ListView.separated(
        padding: AppSpacing.pageAll,
        itemCount: placed.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
        itemBuilder: (_, i) =>
            _PlacedCard(item: placed[i], controller: controller),
      );
    });
  }
}

class _PlacedCard extends StatelessWidget {
  const _PlacedCard({required this.item, required this.controller});
  final ScheduleItem item;
  final ScheduleController controller;

  @override
  Widget build(BuildContext context) {
    final p = item.placement!;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Text(FormatConst.timeFormat.format(p.beginHour),
            style: AppTypography.body),
        title:
            Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
            '${FormatConst.timeFormat.format(p.beginHour)}–${FormatConst.timeFormat.format(p.endHour)} · ${p.durationMinutes} ${'min_short'.tr}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () =>
                  controller.setDuration(item.raceId, p.durationMinutes - 5),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () =>
                  controller.setDuration(item.raceId, p.durationMinutes + 5),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'unscheduled'.tr,
              onPressed: () => controller.unschedule(item.raceId),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnscheduledPalette extends StatelessWidget {
  const _UnscheduledPalette({required this.controller});
  final ScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.unscheduled;
      final siteId = controller.selectedSiteId.value;
      final day = controller.selectedDay;
      return Container(
        constraints: const BoxConstraints(maxHeight: 160),
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
                    title: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: TextButton(
                      onPressed: (siteId == null || day == null)
                          ? null
                          : () => controller.place(item.raceId, siteId, day),
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
