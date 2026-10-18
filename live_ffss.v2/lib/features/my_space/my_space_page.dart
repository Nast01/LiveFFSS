import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/notifications/reminder_scheduler.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/features/auth/auth_formatting.dart';
import 'package:live_ffss_v2/features/auth/login_page.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/follows/follows_providers.dart';
import 'package:live_ffss_v2/features/my_space/my_space_formatting.dart';
import 'package:live_ffss_v2/features/my_space/my_space_providers.dart';
import 'package:live_ffss_v2/features/my_space/widgets/my_space_rows.dart';
import 'package:live_ffss_v2/features/officiel/outbox_service.dart';
import 'package:live_ffss_v2/features/reminders/reminder_lead_selector.dart';
import 'package:live_ffss_v2/features/results/athlete_providers.dart';
import 'package:live_ffss_v2/features/results/widgets/results_messages.dart';
import 'package:live_ffss_v2/features/settings/language_selector.dart';
import 'package:live_ffss_v2/features/settings/start_tab_selector.dart';
import 'package:live_ffss_v2/features/shell/choose_competition_prompt.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

/// Mon espace : le compte (ou la connexion), les espaces du compte sur la
/// compétition active, ce que tout le monde y consulte, et les préférences.
class MySpacePage extends ConsumerWidget {
  const MySpacePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final account = session.value;
    final competition = ref.watch(currentCompetitionProvider);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (competition != null)
              Text(
                competition.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            Text(l10n.tabMySpace),
          ],
        ),
      ),
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
          if (competition == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: ChooseCompetitionPrompt(),
            )
          else ...[
            if (account != null) ...[
              MySpaceHeader(l10n.mySpaceSpaces),
              _Spaces(competitionId: competition.id, account: account),
            ],
            MySpaceHeader(l10n.mySpaceEveryone),
            _Everyone(competitionId: competition.id),
          ],
          MySpaceHeader(l10n.mySpacePreferences),
          // Le web n'a pas de rappels.
          if (ref.watch(remindersSupportedProvider)) ...[
            const ReminderLeadSelector(),
            const SizedBox(height: 8),
          ],
          const StartTabSelector(),
          const SizedBox(height: 8),
          const LanguageSelector(),
        ],
      ),
    );
  }
}

/// Les cartes des espaces du compte. Rôles en échec : un message et
/// « Réessayer », le reste de la page s'affiche.
class _Spaces extends ConsumerWidget {
  const _Spaces({required this.competitionId, required this.account});

  final int competitionId;
  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(mySpaceCardsProvider(competitionId));
    void retry() => retryMySpaceCards(
      ProviderScope.containerOf(context, listen: false),
      competitionId,
    );
    switch (spacesView(
      loading: state.isLoading,
      failed: state.hasError,
      cards: state.value,
    )) {
      case SpacesLoading():
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      case SpacesFailed():
        return MySpaceBox(
          children: [
            ResultsMessage(text: l10n.mySpaceRolesError, onRetry: retry),
          ],
        );
      case SpacesNone():
        return MySpaceBox(children: [MySpaceRow(title: l10n.mySpaceNoSpace)]);
      case SpacesShown(:final cards):
        return MySpaceBox(
          children: [
            if (cards.athleteUnknown)
              MySpaceRow(
                icon: Icons.pool,
                title: l10n.mySpaceAthlete,
                subtitle: l10n.mySpaceAthleteUnknown,
                trailing: TextButton(onPressed: retry, child: Text(l10n.retry)),
              ),
            for (final card in cards.cards)
              switch (card) {
                AthleteSpaceCard(:final participant) => _AthleteRow(
                  competitionId: competitionId,
                  card: card,
                  participantId: participant.id,
                ),
                OfficialSpaceCard() => _OfficialRow(
                  competitionId: competitionId,
                  card: card,
                  account: account,
                ),
                _ => _CardRow(competitionId: competitionId, card: card),
              },
          ],
        );
    }
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({
    required this.competitionId,
    required this.card,
    this.badge,
    this.badgeTone = BadgeTone.neutral,
  });

  final int competitionId;
  final MySpaceCard card;
  final String? badge;
  final BadgeTone badgeTone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MySpaceRow(
      icon: switch (card) {
        AthleteSpaceCard() => Icons.pool,
        ClubSpaceCard() => Icons.groups_outlined,
        OfficialSpaceCard() => Icons.timer_outlined,
        AdminSpaceCard() => Icons.admin_panel_settings_outlined,
      },
      title: mySpaceCardTitle(card, l10n),
      subtitle: mySpaceCardSubtitle(card, l10n),
      badge: badge,
      badgeTone: badgeTone,
      onTap: () => context.go(mySpaceCardRoute(card, competitionId)),
    );
  }
}

/// Le badge dit quand part sa prochaine course.
class _AthleteRow extends ConsumerWidget {
  const _AthleteRow({
    required this.competitionId,
    required this.card,
    required this.participantId,
  });

  final int competitionId;
  final MySpaceCard card;
  final int participantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // La fiche lit les classements : pas de badge sans eau plate.
    final open =
        resultsGate(ref.watch(spaceCompetitionProvider(competitionId))) ==
        ResultsGate.open;
    final races = open
        ? ref
              .watch(
                athleteCardProvider((
                  competitionId: competitionId,
                  participantId: participantId,
                )),
              )
              .value
        : null;
    return _CardRow(
      competitionId: competitionId,
      card: card,
      badge: athleteBadge(
        races,
        ref.watch(clockProvider)(),
        AppLocalizations.of(context),
      ),
      badgeTone: BadgeTone.highlight,
    );
  }
}

/// Le badge compte ses saisies refusées.
class _OfficialRow extends ConsumerWidget {
  const _OfficialRow({
    required this.competitionId,
    required this.card,
    required this.account,
  });

  final int competitionId;
  final MySpaceCard card;
  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) => _CardRow(
    competitionId: competitionId,
    card: card,
    badge: officialBadge(
      ref.watch(outboxProvider),
      account.label,
      competitionId,
      AppLocalizations.of(context),
    ),
    badgeTone: BadgeTone.alert,
  );
}

/// Ce que tout le monde consulte, connecté ou non.
class _Everyone extends ConsumerWidget {
  const _Everyone({required this.competitionId});

  final int competitionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final follows = ref.watch(followsProvider(competitionId));
    final summary = followsSummaryOf(
      follows.value,
      l10n,
      failed: follows.hasError,
    );
    return MySpaceBox(
      children: [
        MySpaceRow(
          icon: Icons.star_outline,
          title: l10n.mySpaceFollows,
          subtitle: summary ?? l10n.mySpaceFollowsError,
          trailing: summary == null
              ? TextButton(
                  onPressed: () =>
                      ref.invalidate(followsProvider(competitionId)),
                  child: Text(l10n.retry),
                )
              : null,
          onTap: () => context.go(Routes.mySpaceFollows(competitionId)),
        ),
        MySpaceRow(
          icon: Icons.info_outline,
          title: l10n.mySpaceInfos,
          subtitle: l10n.mySpaceInfosSubtitle,
          onTap: () => context.go(Routes.mySpaceInfos(competitionId)),
        ),
        MySpaceRow(
          icon: Icons.gavel_outlined,
          title: l10n.mySpaceOfficials,
          subtitle: l10n.mySpaceOfficialsSubtitle,
          onTap: () => context.go(Routes.mySpaceOfficials(competitionId)),
        ),
      ],
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
