import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/module/competitions/controllers/rfid_writer_controller.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';
import 'package:live_ffss/app/presentation/shared/error_state.dart';
import 'package:live_ffss/app/presentation/shared/home_wave.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';

class RfidWriterView extends StatefulWidget {
  const RfidWriterView({super.key});

  @override
  State<RfidWriterView> createState() => _RfidWriterViewState();
}

class _RfidWriterViewState extends State<RfidWriterView> {
  // Lives in the view, not the controller: it is scoped to this screen only.
  final _searchController = TextEditingController();
  final _controller = Get.find<RfidWriterController>();
  Worker? _writeStateWorker;

  @override
  void initState() {
    super.initState();
    // The sheet is opened by the view, never by the controller — controllers
    // must not call Get.dialog / showModalBottomSheet.
    //
    // The `isCurrent` guard is not just defensive: Retry lives INSIDE the
    // sheet (see _WriteSheet), so pressing it drives `writeState` back to
    // `waiting` while the sheet route is still on top and this page's route
    // is no longer current. Without the guard, that would open a second
    // sheet stacked on the first. Dismissing the top one then runs
    // `cancelWrite` via `whenComplete`, killing the write behind a sheet
    // that is still showing "Approchez le bracelet".
    _writeStateWorker = ever<RfidWriteState>(_controller.writeState, (state) {
      if (state == RfidWriteState.waiting && ModalRoute.of(context)?.isCurrent == true) {
        _openSheet();
      }
    });
  }

  @override
  void dispose() {
    _writeStateWorker?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openSheet() {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.surface,
      builder: (_) => const _WriteSheet(),
      // Fires however the sheet closes — Annuler, Terminé, or a back gesture.
      // It MUST run on every one of those: it is what releases the NFC
      // session, and a session left open silently writes this payload to the
      // next bracelet presented.
    ).whenComplete(_controller.cancelWrite);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(searchController: _searchController),
            const HomeWave(),
            const SizedBox(height: AppSpacing.sm),
            const Expanded(child: _AthleteList()),
          ],
        ),
      ),
    );
  }
}

class _Header extends GetView<RfidWriterController> {
  const _Header({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: Get.back,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Obx(() {
                  final competition = controller.competition.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'bracelets'.tr,
                        style: AppTypography.title.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      if (competition != null)
                        Text(
                          competition.name,
                          style: AppTypography.body.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: AppSpacing.pageHorizontal,
            child: TextField(
              controller: searchController,
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'search_athlete'.tr,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.pillRadius,
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AthleteList extends GetView<RfidWriterController> {
  const _AthleteList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingIndicator();
      }
      if (controller.hasError.value) {
        return ErrorState(
          message: 'error_occured'.tr,
          onRetry: () {
            final competition = controller.competition.value;
            if (competition != null) {
              controller.loadAthletes(competition.id);
            }
          },
        );
      }
      final athletes = controller.filteredAthletes;
      if (athletes.isEmpty) {
        return EmptyState(
          icon: Icons.person_search,
          title: 'no_athletes_found'.tr,
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.xs,
          AppSpacing.sm,
          AppSpacing.lg,
        ),
        itemCount: athletes.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) => _AthleteRow(athlete: athletes[i]),
      );
    });
  }
}

class _AthleteRow extends GetView<RfidWriterController> {
  const _AthleteRow({required this.athlete});

  final Athlete athlete;

  @override
  Widget build(BuildContext context) {
    final club = athlete.club?.name;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => controller.writeBracelet(athlete),
        title: Text(
          '${athlete.lastName} ${athlete.firstName}',
          style: AppTypography.body,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // The licence number is what goes on the chip: showing it is how a
        // volunteer notices they picked the wrong athlete. The club name rides
        // in the subtitle rather than `trailing`: a variable-length Text in the
        // trailing slot overflows and leaves the whole ListTile unsized on a
        // narrow screen or with a long club name.
        subtitle: Text(
          club == null ? athlete.licenseeNumber : '${athlete.licenseeNumber} · $club',
          style: AppTypography.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _WriteSheet extends GetView<RfidWriterController> {
  const _WriteSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pageAll,
      child: Obx(() {
        final state = controller.writeState.value;
        final athlete = controller.selected.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            switch (state) {
              RfidWriteState.success => const Icon(
                  Icons.check_circle,
                  size: 64,
                  // The palette has no `statusSuccess`; `statusFinished` is
                  // its green (0xFF43A047).
                  color: AppColors.statusFinished,
                ),
              RfidWriteState.error => const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.statusError,
                ),
              _ => const Icon(Icons.nfc, size: 64, color: AppColors.primary),
            },
            const SizedBox(height: AppSpacing.md),
            Text(
              switch (state) {
                RfidWriteState.success => 'bracelet_written'.tr,
                RfidWriteState.error =>
                  (controller.message.value?.translationKey ??
                          'bracelet_write_failed')
                      .tr,
                _ => 'approach_bracelet'.tr,
              },
              style: AppTypography.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (athlete != null)
              Text(
                controller.payloadFor(athlete),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (state == RfidWriteState.error && athlete != null)
                  TextButton(
                    onPressed: () => controller.writeBracelet(athlete),
                    child: Text('retry'.tr),
                  ),
                TextButton(
                  onPressed: Get.back<void>,
                  child: Text(
                    state == RfidWriteState.success
                        ? 'finish'.tr
                        : 'cancel'.tr,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
