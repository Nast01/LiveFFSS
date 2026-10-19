import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/notifications/reminder_scheduler.dart';
import 'package:live_ffss_v2/features/admin/admin_formatting.dart';
import 'package:live_ffss_v2/features/admin/maintenance_providers.dart';
import 'package:live_ffss_v2/features/admin/widgets/admin_gate.dart';
import 'package:live_ffss_v2/features/common/remount_progress.dart';
import 'package:live_ffss_v2/features/my_space/widgets/my_space_rows.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

/// La maintenance locale de la compétition : effacer ce que l'appareil en
/// garde, tout relire, vérifier les rappels, copier un rapport de
/// diagnostic.
class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key, required this.competitionId});

  final int competitionId;

  @override
  Widget build(BuildContext context) => AdminGate(
    competitionId: competitionId,
    child: _Maintenance(competitionId: competitionId),
  );
}

class _Maintenance extends ConsumerStatefulWidget {
  const _Maintenance({required this.competitionId});

  final int competitionId;

  @override
  ConsumerState<_Maintenance> createState() => _MaintenanceState();
}

class _MaintenanceState extends ConsumerState<_Maintenance> {
  @override
  void initState() {
    super.initState();
    activateFromLink(ref, widget.competitionId);
  }

  ProviderContainer get _container =>
      ProviderScope.containerOf(context, listen: false);

  void _tell(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirm(String title, String body, String action) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );
    return confirmed == true && mounted;
  }

  Future<void> _clear(AppLocalizations l10n) async {
    if (!await _confirm(
      l10n.maintenanceClearTitle,
      l10n.maintenanceClearBody,
      l10n.maintenanceClearConfirm,
    )) {
      return;
    }
    try {
      final cleared = await clearCompetitionData(
        _container,
        widget.competitionId,
      );
      _tell(cleared ? l10n.maintenanceCleared : l10n.maintenanceClearFailed);
    } on AdminOnlyException {
      _tell(l10n.adminOnly);
    }
  }

  Future<void> _reload(AppLocalizations l10n) async {
    if (!await _confirm(
      l10n.maintenanceReloadTitle,
      l10n.maintenanceReloadBody,
      l10n.maintenanceReloadConfirm,
    )) {
      return;
    }
    if (!mounted) return;
    // La page disparaît avec le conteneur qu'elle quitte.
    final container = _container;
    try {
      await remountWithProgress(
        context,
        () => forceReload(container, widget.competitionId),
      );
    } on AdminOnlyException {
      _tell(l10n.adminOnly);
    }
  }

  Future<void> _testNotification(AppLocalizations l10n) async {
    try {
      final outcome = await sendTestNotification(
        _container,
        widget.competitionId,
        title: l10n.maintenanceTestTitle,
        body: l10n.maintenanceTestBody,
      );
      _tell(testNotificationMessage(outcome, l10n));
    } on AdminOnlyException {
      _tell(l10n.adminOnly);
    }
  }

  Future<void> _copyReport(String? report, AppLocalizations l10n) async {
    if (report == null) {
      _tell(l10n.maintenanceReportFailed);
      return;
    }
    await Clipboard.setData(ClipboardData(text: report));
    _tell(l10n.maintenanceReportCopied);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final planned = ref.watch(plannedRemindersProvider(widget.competitionId));
    // Suivi plutôt que lu au geste : tenu à jour, il est prêt à copier.
    final report = ref
        .watch(diagnosticReportProvider(widget.competitionId))
        .value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminMaintenance)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [
          MySpaceHeader(l10n.adminCompetition),
          MySpaceBox(
            children: [
              MySpaceRow(
                icon: Icons.delete_outline,
                title: l10n.maintenanceClearTitle,
                subtitle: l10n.maintenanceClearSubtitle,
                onTap: () => _clear(l10n),
              ),
              MySpaceRow(
                icon: Icons.refresh,
                title: l10n.maintenanceReloadTitle,
                onTap: () => _reload(l10n),
              ),
            ],
          ),
          MySpaceHeader(l10n.maintenanceReminders),
          MySpaceBox(
            children: [
              MySpaceRow(
                icon: Icons.notifications_outlined,
                title: l10n.maintenanceTestNotification,
                onTap: () => _testNotification(l10n),
              ),
              ...switch (planned) {
                AsyncData(:final value) when value.isEmpty => [
                  MySpaceRow(title: l10n.maintenancePlannedNone),
                ],
                AsyncData(:final value) => [
                  for (final Reminder reminder in value)
                    MySpaceRow(
                      title: reminder.title,
                      subtitle: plannedReminderWhen(reminder.at, locale),
                    ),
                ],
                AsyncError() => [
                  MySpaceRow(title: l10n.maintenancePlannedError),
                ],
                _ => [const LinearProgressIndicator()],
              },
            ],
          ),
          MySpaceHeader(l10n.adminDiagnostic),
          MySpaceBox(
            children: [
              MySpaceRow(
                icon: Icons.content_copy,
                title: l10n.maintenanceReportTitle,
                subtitle: l10n.maintenanceReportSubtitle,
                onTap: () => _copyReport(report, l10n),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
