import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/core/di/app_restart.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/domain/models/session_probe.dart';
import 'package:live_ffss/app/module/debug/controllers/debug_controller.dart';
import 'package:live_ffss/app/presentation/shared/loading_indicator.dart';
import 'package:live_ffss/app/routes/app_pages.dart';

/// Écran de debug. Ses textes sont en dur, non traduits : il ne part jamais en
/// release, et les deux fichiers de traduction sont tenus symétriques et sans
/// clé morte — huit clés de debug n'y rendraient service à personne.
class DebugView extends GetView<DebugController> {
  const DebugView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Environnement actif',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _row('Endpoint', controller.endpoint),
                  _row('Préfixe de stockage', controller.storagePrefixLabel),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Session',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => _row(
                        'Jeton',
                        controller.token.value == null
                            ? 'absent'
                            : 'présent (${controller.token.value!.length} caractères)',
                      )),
                  Obx(() => _row(
                        'Expiration annoncée',
                        controller.announcedExpiration?.toIso8601String() ??
                            'inconnue',
                      )),
                  const SizedBox(height: 8),
                  Obx(() {
                    final probe = controller.probe.value;
                    if (probe == null) return const SizedBox.shrink();
                    return _row('État réel', _probeLabel(probe));
                  }),
                  const SizedBox(height: 8),
                  Obx(() => OutlinedButton.icon(
                        onPressed: controller.isProbing.value
                            ? null
                            : controller.runProbe,
                        icon: controller.isProbing.value
                            ? const LoadingIndicator(compact: true, size: 16)
                            : const Icon(Icons.network_ping, size: 18),
                        label: const Text('Tester la session'),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Changer d\'environnement',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // ListTile plutôt que RadioListTile : `groupValue`/`onChanged` sont
          // dépréciés sur le SDK du projet, et une dépréciation fait sortir
          // `flutter analyze` en erreur.
          for (final environment in controller.environments)
            Card(
              child: ListTile(
                leading: Icon(
                  environment == controller.current
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: environment == controller.current
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
                title: Text(environment.label),
                subtitle: Text(environment.endpoint),
                onTap: environment == controller.current
                    ? null
                    : () => _confirmSwitch(context, environment),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: const Text('Stockage local'),
              subtitle: const Text('Voir, copier et supprimer les clés'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed<void>(Routes.debugStorage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      );
}

/// Confirme la bascule puis la déclenche. Portée par la vue, pas par le
/// contrôleur : `AppRestart.switchTo` détruit le contrôleur en cours de route.
Future<void> _confirmSwitch(
  BuildContext context,
  AppEnvironment environment,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Basculer sur ${environment.label} ?'),
      content: Text(
        'L\'application va redémarrer sur ${environment.endpoint}.\n\n'
        'Chaque environnement garde sa propre session et son propre '
        'programme local : tu repartiras sur ceux de celui-ci, '
        'probablement aucun la première fois. Rien n\'est effacé.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Basculer'),
        ),
      ],
    ),
  );
  if (confirmed == true) await AppRestart.switchTo(environment);
}

/// Ce que la sonde a constaté, dit en clair — l'écart entre cette ligne et
/// l'expiration annoncée est précisément ce que l'écran sert à voir.
String _probeLabel(SessionProbe probe) => switch (probe.outcome) {
      SessionProbeOutcome.signedIn => 'session vivante — ${probe.label}',
      SessionProbeOutcome.anonymous =>
        'jeton mort — FFSS répond « ${probe.label} »',
      SessionProbeOutcome.unreachable =>
        'indéterminé — ${probe.message ?? 'serveur injoignable'}',
    };
