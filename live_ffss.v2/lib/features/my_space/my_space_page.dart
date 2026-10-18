import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/features/auth/auth_formatting.dart';
import 'package:live_ffss_v2/features/auth/login_page.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/officiel/outbox_service.dart';
import 'package:live_ffss_v2/features/settings/language_selector.dart';

/// Mon espace : la connexion tant que personne n'est connecté, puis le compte.
class MySpacePage extends ConsumerWidget {
  const MySpacePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final account = session.value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabMySpace)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [
          if (account != null)
            _AccountCard(account: account)
          else if (session.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            const LoginForm(),
          const SizedBox(height: 16),
          const LanguageSelector(),
        ],
      ),
    );
  }
}

class _AccountCard extends ConsumerWidget {
  const _AccountCard({required this.account});

  final Account account;

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final queue = ref.read(outboxProvider);
    if (logoutNeedsConfirmation(queue, account)) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) =>
            _LogoutDialog(count: pendingOperationCount(queue, account)),
      );
      if (confirmed != true) return;
    }
    await ref.read(sessionProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final type = account.type;
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              account.label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            if (type != null && type.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                l10n.accountType(type),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => _logout(context, ref),
              child: Text(l10n.logOut),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.logOutConfirmTitle),
      content: Text(l10n.logOutConfirmBody(count)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.logOut),
        ),
      ],
    );
  }
}
