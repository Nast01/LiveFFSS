import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/module/programme/controllers/sites_controller.dart';
import 'package:live_ffss/app/presentation/shared/empty_state.dart';

class SitesView extends StatelessWidget {
  const SitesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SitesController>();
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('sites'.tr,
            style: AppTypography.title.copyWith(color: Colors.white, fontSize: 16)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSiteDialog(context, controller),
        icon: const Icon(Icons.add),
        label: Text('add_site'.tr),
      ),
      body: Obx(() {
        final sites = controller.sites;
        if (sites.isEmpty) {
          return EmptyState(icon: Icons.place_outlined, title: 'no_sites'.tr);
        }
        return ListView.separated(
          padding: AppSpacing.pageAll,
          itemCount: sites.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) {
            final site = sites[i];
            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(site.type == SiteType.sable
                    ? Icons.beach_access
                    : Icons.waves),
                title: Text(site.name),
                subtitle: Text(_typeLabel(site.type)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => controller.deleteSite(site.id),
                ),
                onTap: () => _openSiteDialog(context, controller, site: site),
              ),
            );
          },
        );
      }),
    );
  }

  static String _typeLabel(SiteType type) =>
      (type == SiteType.sable ? 'site_sable' : 'site_cotier').tr;

  Future<void> _openSiteDialog(BuildContext context, SitesController controller,
      {ProgrammeSite? site}) async {
    final nameController = TextEditingController(text: site?.name ?? '');
    var type = site?.type ?? SiteType.cotier;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('add_site'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'site_name'.tr),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  for (final t in const [SiteType.cotier, SiteType.sable])
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChoiceChip(
                        label: Text(_typeLabel(t)),
                        selected: type == t,
                        onSelected: (_) => setState(() => type = t),
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () {
                if (site == null) {
                  controller.addSite(nameController.text, type);
                } else {
                  controller.renameSite(site.id, nameController.text, type);
                }
                Navigator.of(ctx).pop();
              },
              child: Text('add_site'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
