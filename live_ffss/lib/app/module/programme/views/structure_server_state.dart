import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/race_format_configuration.dart';
import 'package:live_ffss/app/module/programme/controllers/programme_controller.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

/// What FFSS holds against what the competition needs: the déroulements still
/// missing, and the ones the server carries for nothing.
///
/// Both live here rather than in the overview view, which is already long
/// enough — and both speak of the same thing, the gap between the device and
/// the federal site.
class StructureServerState extends StatelessWidget {
  const StructureServerState({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProgrammeController>();
    return Obx(() {
      final missing = controller.missingRaceFormatCount;
      final orphans = controller.orphanRaceFormats;
      if (missing == 0 && orphans.isEmpty) return const SizedBox.shrink();
      // Signed out, the two actions below cannot succeed — FFSS refuses an
      // anonymous write with a bare "Invalid Token". Say that instead of
      // offering a button that only fails at the far end.
      final signedOut = !controller.canWriteToFfss;
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm, AppSpacing.xs, AppSpacing.sm, 0),
        child: Column(
          children: [
            if (missing > 0)
              signedOut
                  ? const _SignInBanner()
                  : _MissingBanner(count: missing),
            if (orphans.isNotEmpty) _OrphanRow(orphans: orphans),
          ],
        ),
      );
    });
  }
}

/// Stands in for the creation banner when nobody is signed in. Every read on
/// this screen is public, so an operator can get all the way here without a
/// session and never be told — until a write comes back refused.
class _SignInBanner extends StatelessWidget {
  const _SignInBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: AppRadius.smRadius,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.primary, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'race_format_login_title'.tr,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text('race_format_login_body'.tr, style: AppTypography.caption),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: () => Get.toNamed<void>(Routes.login),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
            child: Text('login'.tr),
          ),
        ],
      ),
    );
  }
}

/// The déroulements FFSS does not hold yet. Loud on purpose: without them the
/// heat draw has nothing to hang on, and the old tonal button went unnoticed.
class _MissingBanner extends StatelessWidget {
  const _MissingBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProgrammeController>();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.statusWaiting.withValues(alpha: 0.12),
        borderRadius: AppRadius.smRadius,
        border: Border.all(
          color: AppColors.statusWaiting.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined,
              color: AppColors.statusWaiting, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'race_format_missing_title'.trParams({'count': '$count'}),
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'race_format_missing_body'.tr,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: controller.isSubmitting.value
                ? null
                : () => _confirmCreateMissing(context, controller),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.statusWaiting,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
            child: controller.isSubmitting.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text('create'.tr),
          ),
        ],
      ),
    );
  }
}

/// Creating a déroulement writes to the FFSS server, so it is confirmed, and
/// the wording says where it lands.
Future<void> _confirmCreateMissing(
  BuildContext context,
  ProgrammeController controller,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('race_format_create_title'.tr),
      content: Text('race_format_create_body'
          .trParams({'count': '${controller.missingRaceFormatCount}'})),
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
  if (confirmed == true) await controller.createMissingRaceFormats();
}

/// Server drift, stated plainly and left to the operator. Muted rather than
/// alarming: an orphan blocks nothing, it only means FFSS carries more than
/// this competition runs.
class _OrphanRow extends StatelessWidget {
  const _OrphanRow({required this.orphans});

  final List<RaceFormatConfiguration> orphans;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: InkWell(
        borderRadius: AppRadius.smRadius,
        onTap: () => _openOrphanSheet(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          child: Row(
            children: [
              const Icon(Icons.link_off,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'race_format_orphans'
                      .trParams({'count': '${orphans.length}'}),
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'see'.tr,
                style: AppTypography.caption.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _openOrphanSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) => const _OrphanSheet(),
  );
}

class _OrphanSheet extends StatelessWidget {
  const _OrphanSheet();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProgrammeController>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Obx(() {
          final orphans = controller.orphanRaceFormats;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('race_format_orphans_title'.tr,
                  style: AppTypography.subtitle),
              const SizedBox(height: AppSpacing.xs),
              Text('race_format_orphans_body'.tr, style: AppTypography.caption),
              const SizedBox(height: AppSpacing.sm),
              // The last deletion closes the sheet: an empty one would leave
              // the operator staring at a heading with nothing under it.
              if (orphans.isEmpty)
                const SizedBox.shrink()
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: orphans.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) => _OrphanTile(format: orphans[i]),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _OrphanTile extends StatelessWidget {
  const _OrphanTile({required this.format});

  final RaceFormatConfiguration format;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProgrammeController>();
    final rounds = format.details.length;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        format.fullLabel.isEmpty ? format.label : format.fullLabel,
        style: AppTypography.body,
      ),
      subtitle: Text(
        rounds == 0
            ? 'race_format_present_no_round'.tr
            : 'race_format_present'.trParams({'count': '$rounds'}),
        style: AppTypography.caption,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        color: AppColors.statusError,
        tooltip: 'race_format_delete_title'.tr,
        // Greyed out rather than hidden: the drift is still worth showing to a
        // signed-out operator, only not actionable.
        onPressed: !controller.canWriteToFfss
            ? null
            : () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('race_format_delete_title'.tr),
                    content: Text('race_format_delete_body'.tr),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text('cancel'.tr),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.statusError),
                        child: Text('delete'.tr),
                      ),
                    ],
                  ),
                );
                if (confirmed != true) return;
                await controller.deleteRaceFormat(format);
                if (context.mounted && controller.orphanRaceFormats.isEmpty) {
                  Navigator.of(context).pop();
                }
              },
      ),
    );
  }
}
