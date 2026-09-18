import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/module/debug/controllers/storage_inspector_controller.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';

/// Textes en dur, non traduits : le module debug ne part jamais en release.
class StorageInspectorView extends GetView<StorageInspectorController> {
  const StorageInspectorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stockage local'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir',
            onPressed: controller.load,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingIndicator();
        return ListView(
          // Les cartes portent des boutons copier/supprimer : sans le retrait
          // de la barre de navigation, ceux de la dernière restent dessous.
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).viewPadding.bottom,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Cet écran écrit sur le disque, pas dans les objets vivants. '
                'Un service qui ne fait que lire (ex. UserService) ne verra '
                'pas la suppression avant un redémarrage ou un changement '
                'd\'environnement. Un service qui réécrit sa clé après coup '
                '(ProgrammeService, AttendanceService) restaurera la clé '
                'supprimée dès son prochain enregistrement — quittez l\'écran '
                'concerné, ou relancez l\'application, avant de supprimer.',
              ),
            ),
            const SizedBox(height: 16),
            ..._section(
              context,
              'Environnement courant — ${controller.environment.label}',
              controller.currentEnvironment,
            ),
            ..._section(
                context, 'Autre environnement', controller.otherEnvironment),
            ..._section(context, 'Clés globales', controller.global),
          ],
        );
      }),
    );
  }

  List<Widget> _section(
    BuildContext context,
    String title,
    List<StorageEntry> entries,
  ) =>
      [
        Text(
          '$title (${entries.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text('aucune clé',
                style: TextStyle(color: AppColors.textMuted)),
          )
        else
          ...entries.map((entry) => Card(
                child: ExpansionTile(
                  title: Text(entry.key),
                  subtitle: Text('${entry.sizeInBytes} octets'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: SelectableText(
                        StorageInspectorController.prettify(entry.value),
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
                    OverflowBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('Copier'),
                          onPressed: () => _copy(context, entry.value),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Supprimer'),
                          style:
                              TextButton.styleFrom(foregroundColor: Colors.red),
                          onPressed: () =>
                              _confirmDelete(context, controller, entry.key),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        const SizedBox(height: 16),
      ];
}

/// Copie la chaîne brute, pas la version ré-indentée : c'est elle qui peut être
/// ré-injectée ou jointe à un rapport.
Future<void> _copy(BuildContext context, String raw) async {
  await Clipboard.setData(ClipboardData(text: raw));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Copié')),
  );
}

Future<void> _confirmDelete(
  BuildContext context,
  StorageInspectorController controller,
  String key,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Supprimer cette clé ?'),
      content: Text(
        '« $key » sera effacée du stockage. Si un service la réécrit après '
        'coup (ex. Programme, Présence), la suppression peut ne pas tenir. '
        'Si elle tient et que la clé porte un tirage non poussé, il '
        'n\'existe nulle part ailleurs.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );
  if (confirmed == true) await controller.delete(key);
}
