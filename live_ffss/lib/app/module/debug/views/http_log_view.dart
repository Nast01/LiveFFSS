import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/network/http_log.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/module/debug/controllers/http_log_controller.dart';

/// Textes en dur, non traduits : le module debug ne part jamais en release.
class HttpLogView extends GetView<HttpLogController> {
  const HttpLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal HTTP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir',
            onPressed: controller.refreshEntries,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Vider',
            onPressed: controller.clear,
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() => SwitchListTile(
                value: controller.isEnabled.value,
                onChanged: controller.setEnabled,
                title: const Text('Enregistrer les requêtes'),
                subtitle: Text(
                  controller.isEnabled.value
                      ? 'Les ${HttpLog.capacity} dernières, corps tronqués à '
                          '${HttpLog.bodyLimit} caractères. L\'URL contient le '
                          'jeton en clair.'
                      : 'Éteint — rien n\'est capturé.',
                ),
              )),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              if (controller.entries.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Aucune requête enregistrée.\n'
                      'Allumez le journal, refaites l\'action, puis '
                      'rafraîchissez.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              // Chaque ligne du journal se déplie et porte un bouton copier :
              // sans le retrait de la barre de navigation, celui de la
              // dernière reste dessous.
              return ListView.builder(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewPadding.bottom,
                ),
                itemCount: controller.entries.length,
                itemBuilder: (context, index) =>
                    _tile(context, controller.entries[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, HttpLogEntry entry) {
    final status = entry.error != null ? 'échec' : '${entry.statusCode ?? '?'}';
    final failed = entry.error != null || (entry.statusCode ?? 0) >= 400;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ExpansionTile(
        leading: Text(
          entry.method,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        title: Text(
          Uri.parse(entry.url).path,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$status · ${entry.durationMs} ms',
          style: TextStyle(
            color: failed ? AppColors.statusError : AppColors.statusFinished,
          ),
        ),
        children: [
          _block(context, 'URL', entry.url),
          if (entry.requestBody != null)
            _block(context, 'Corps envoyé', entry.requestBody!),
          if (entry.responseBody != null)
            _block(context, 'Réponse', entry.responseBody!),
          if (entry.error != null) _block(context, 'Erreur', entry.error!),
        ],
      ),
    );
  }

  Widget _block(BuildContext context, String title, String content) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copier'),
                  onPressed: () => _copy(context, content),
                ),
              ],
            ),
            SelectableText(
              content,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
      );
}

Future<void> _copy(BuildContext context, String raw) async {
  await Clipboard.setData(ClipboardData(text: raw));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Copié')),
  );
}
