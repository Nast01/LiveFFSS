import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/features/auth/auth_formatting.dart';
import 'package:live_ffss_v2/features/auth/session.dart';

/// Le formulaire de connexion, affiché dans Mon espace tant que personne
/// n'est connecté.
class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _login = TextEditingController();
  final _password = TextEditingController();
  bool _obscured = true;
  bool _connecting = false;
  LoginFailure? _failure;

  @override
  void initState() {
    super.initState();
    _login.addListener(_changed);
    _password.addListener(_changed);
  }

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  void _changed() => setState(() {});

  Future<void> _submit() async {
    if (_connecting || !canSubmitLogin(_login.text, _password.text)) return;
    setState(() {
      _connecting = true;
      _failure = null;
    });
    try {
      await ref
          .read(sessionProvider.notifier)
          .login(_login.text, _password.text);
      if (!mounted) return;
      setState(() => _connecting = false);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _connecting = false;
        _failure = loginFailureOf(e);
        // Le mot de passe refusé ne reste pas dans le champ.
        _password.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final expired = ref.watch(sessionExpiredProvider);
    final failure = _failure;
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.loginTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            if (expired) ...[
              const SizedBox(height: 12),
              Text(
                l10n.sessionExpired,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _login,
              enabled: !_connecting,
              autocorrect: false,
              enableSuggestions: false,
              autofillHints: const [AutofillHints.username],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l10n.loginField),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              enabled: !_connecting,
              obscureText: _obscured,
              autocorrect: false,
              enableSuggestions: false,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: l10n.passwordField,
                suffixIcon: IconButton(
                  tooltip: _obscured ? l10n.showPassword : l10n.hidePassword,
                  icon: Icon(
                    _obscured ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscured = !_obscured),
                ),
              ),
            ),
            if (failure != null) ...[
              const SizedBox(height: 12),
              Text(switch (failure) {
                LoginFailure.rejected => l10n.loginErrorRejected,
                LoginFailure.unreachable => l10n.loginErrorUnreachable,
                LoginFailure.other => l10n.loginErrorOther,
              }, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed:
                  _connecting || !canSubmitLogin(_login.text, _password.text)
                  ? null
                  : _submit,
              child: _connecting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.signIn),
            ),
          ],
        ),
      ),
    );
  }
}
