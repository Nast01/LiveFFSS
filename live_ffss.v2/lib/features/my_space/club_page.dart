import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';
import 'package:live_ffss_v2/core/theme/app_colors.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/follows/follows_providers.dart';
import 'package:live_ffss_v2/features/my_space/club_forfeits_providers.dart';
import 'package:live_ffss_v2/features/my_space/my_space_formatting.dart';
import 'package:live_ffss_v2/features/my_space/my_space_providers.dart';
import 'package:live_ffss_v2/features/my_space/widgets/my_space_rows.dart';
import 'package:live_ffss_v2/features/results/results_formatting.dart';
import 'package:live_ffss_v2/features/results/results_providers.dart';
import 'package:live_ffss_v2/features/results/widgets/choice_chips_row.dart';
import 'package:live_ffss_v2/features/results/widgets/results_messages.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';
import 'package:live_ffss_v2/features/shell/space_competition.dart';

enum _ClubTab { planning, results, forfeits }

/// L'espace d'un club, ouvert à tout le monde (décision du 2026-10-18) :
/// chiffres, planning et résultats de ses athlètes, forfaits publiés. Le
/// référent du club et l'admin y déclarent ou annulent les forfaits
/// (lot 6b).
class ClubPage extends ConsumerStatefulWidget {
  const ClubPage({
    super.key,
    required this.competitionId,
    required this.clubId,
  });

  final int competitionId;
  final int clubId;

  @override
  ConsumerState<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends ConsumerState<ClubPage> {
  // Le bouton passe par l'indicateur du geste : même rond de chargement, et
  // un appui pendant un rafraîchissement n'en lance pas un second.
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  var _tab = _ClubTab.planning;

  // « Calculer » touché : les classements des clubs (une lecture par
  // épreuve) ne partent qu'à la demande, ou s'ils sont déjà calculés.
  var _rankAsked = false;

  @override
  void initState() {
    super.initState();
    activateFromLink(ref, widget.competitionId);
  }

  ClubKey get _key =>
      (competitionId: widget.competitionId, clubId: widget.clubId);

  ProviderContainer get _container =>
      ProviderScope.containerOf(context, listen: false);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clubState = ref.watch(clubProvider(_key));
    final club = clubState.value;
    final roles = ref
        .watch(competitionRolesProvider(widget.competitionId))
        .value;
    final role = clubRole(roles, widget.clubId);
    final title = clubTitle(club, roles, widget.clubId, l10n);
    final tag = clubRoleTag(role, l10n);
    final followed =
        ref
            .watch(followsProvider(widget.competitionId))
            .value
            ?.followsClub(widget.clubId) ??
        false;

    final body = switch (clubBody(club, failed: clubState.hasError)) {
      ClubBody.loading => const Center(child: CircularProgressIndicator()),
      ClubBody.failed => ResultsMessage(
        text: l10n.mySpaceClubError,
        onRetry: () => refreshClubSchedule(_container, _key),
      ),
      ClubBody.noAthlete => ResultsMessage(text: l10n.mySpaceClubNoAthlete),
      ClubBody.shown => _content(club!, role, l10n),
    };

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
            if (tag != null) ...[const SizedBox(width: 8), _Tag(tag)],
          ],
        ),
        actions: [
          // Le libellé suivi est celui des engagés : sans eux, rien à suivre.
          if (club != null && club.label.isNotEmpty)
            IconButton(
              icon: Icon(followed ? Icons.star : Icons.star_border),
              tooltip: followed ? l10n.unfollowClub : l10n.followClub,
              onPressed: () => ref
                  .read(followsProvider(widget.competitionId).notifier)
                  .toggleClub(widget.clubId, club.label),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.resultsRefresh,
            onPressed: club == null || club.athletes.isEmpty
                ? null
                : () => _refreshKey.currentState?.show(),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _content(ClubInfo club, ClubRole role, AppLocalizations l10n) {
    final coastal =
        resultsGate(
          ref.watch(spaceCompetitionProvider(widget.competitionId)),
        ) ==
        ResultsGate.coastal;
    final schedule = ref.watch(clubScheduleProvider(_key));
    final races = coastal ? null : schedule.value?.races;
    final forfeits = races == null ? null : clubForfeits(races);

    final standingsOfClubs = standingsProvider(widget.competitionId);
    // `exists` n'est pas suivi : des classements calculés par l'onglet
    // Résultats pendant que la page est ouverte n'y paraissent qu'à sa
    // prochaine reconstruction. Les suivre d'emblée les calculerait (une
    // lecture par épreuve) à chaque ouverture ; « Calculer » reste là.
    final rankAsked = !coastal && (_rankAsked || ref.exists(standingsOfClubs));
    final standings = rankAsked ? ref.watch(standingsOfClubs) : null;
    final rank = clubRankView(
      asked: rankAsked,
      failed: standings?.hasError ?? false,
      standings: standings?.value,
      club: club.label,
      coastal: coastal,
    );

    final canManage = canManageForfeits(role);
    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        // Pas de marge latérale : les puces défilent bord à bord, les autres
        // blocs prennent la leur.
        padding: EdgeInsets.only(
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [
          for (final child in [
            MySpaceBox(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      _Figure(
                        value: '${club.athletes.length}',
                        label: l10n.mySpaceFigureAthletes(club.athletes.length),
                      ),
                      Expanded(
                        child: switch (rank) {
                          RankShown() => _FigureContent(
                            value: clubRankLabel(rank, l10n),
                            label: l10n.mySpaceFigureRank,
                          ),
                          RankNotComputed() => _FigureAction(
                            label: l10n.mySpaceCompute,
                            caption: l10n.mySpaceFigureRank,
                            onPressed: () => setState(() => _rankAsked = true),
                          ),
                          RankFailed() => _FigureAction(
                            label: l10n.retry,
                            caption: l10n.mySpaceFigureRank,
                            onPressed: () =>
                                ref.read(standingsOfClubs.notifier).refresh(),
                          ),
                          RankComputing() => const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        },
                      ),
                      _Figure(
                        value: forfeitsFigure(forfeits),
                        label: l10n.mySpaceFigureForfeits(
                          forfeits?.length ?? 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ])
            _padded(child),
          const SizedBox(height: 12),
          if (coastal)
            ResultsMessage(text: l10n.coastalComingSoon)
          else ...[
            ChoiceChipsRow<_ClubTab>(
              options: _ClubTab.values,
              selected: _tab,
              label: (tab) => switch (tab) {
                _ClubTab.planning => l10n.mySpacePlanning,
                _ClubTab.results => l10n.tabResults,
                _ClubTab.forfeits => l10n.mySpaceForfeits,
              },
              onSelect: (tab) => setState(() => _tab = tab),
            ),
            for (final child in [
              // Les forfaits à déclarer se lisent sur les places, sans
              // attendre le planning.
              if (_tab == _ClubTab.forfeits && canManage)
                ..._declaredForfeits(club, l10n)
              else if (races == null)
                schedule.hasError
                    ? ResultsMessage(
                        text: l10n.mySpaceClubError,
                        onRetry: () => refreshClubSchedule(_container, _key),
                      )
                    : const Padding(
                        padding: EdgeInsets.only(top: 48),
                        child: Center(child: CircularProgressIndicator()),
                      )
              else ...[
                if (schedule.value!.failedAthletes > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      l10n.mySpaceCardsFailed(schedule.value!.failedAthletes),
                      style: const TextStyle(color: AppColors.red),
                    ),
                  ),
                ...switch (_tab) {
                  _ClubTab.planning => _planning(races, l10n),
                  _ClubTab.results => _results(races, l10n),
                  _ClubTab.forfeits => _forfeits(forfeits!, l10n),
                },
              ],
            ])
              _padded(child),
          ],
        ],
      ),
    );
  }

  Widget _padded(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: child,
  );

  List<Widget> _planning(List<ClubRace> races, AppLocalizations l10n) {
    final toRun = splitClubRaces(races).toRun;
    if (toRun.isEmpty) return [_Empty(l10n.mySpaceNoNextRace)];
    return [
      MySpaceHeader(l10n.mySpaceUpcoming),
      MySpaceBox(
        children: [
          for (final race in toRun)
            _ClubRaceTile(
              time: athleteRaceTime(race.race),
              title: clubRaceTitle(race),
              subtitle: clubRaceLine(race, l10n),
              onTap: () => _open(race.athletes),
            ),
        ],
      ),
    ];
  }

  List<Widget> _results(List<ClubRace> races, AppLocalizations l10n) {
    final groups = clubResultsByEvent(splitClubRaces(races).run);
    if (groups.isEmpty) return [_Empty(l10n.mySpaceNoRaceRun)];
    return [
      for (final group in groups) ...[
        MySpaceHeader(athleteRaceTitle(group.event, l10n)),
        MySpaceBox(
          children: [
            for (final race in group.races)
              _ClubRaceTile(
                time: athleteRaceTime(race.race),
                title: clubRaceTitle(race),
                subtitle: athleteRaceDetail(race.race, l10n),
                trailing: ResultText(label: resultLabel(race.race.row!.result)),
                onTap: () => _open(race.athletes),
              ),
          ],
        ),
      ],
    ];
  }

  Future<void> _refresh() async {
    final forfeits = clubForfeitsProvider(_key);
    await Future.wait([
      refreshClubSchedule(_container, _key),
      // Lus seulement si l'onglet les a montrés.
      if (_container.exists(forfeits))
        _container.read(forfeits.notifier).refresh(),
    ]);
  }

  /// Pour le référent et l'admin : un interrupteur par engagement, qui agit
  /// tout de suite.
  List<Widget> _declaredForfeits(ClubInfo club, AppLocalizations l10n) {
    final state = ref.watch(clubForfeitsProvider(_key));
    final list = state.value;
    final now = ref.read(clockProvider)();
    return [
      MySpaceHeader(l10n.mySpaceForfeits),
      Text(
        l10n.mySpaceForfeitsDeadline(forfeitLead.inMinutes),
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      const SizedBox(height: 8),
      if (list == null)
        state.hasError
            ? ResultsMessage(
                text: l10n.mySpaceClubError,
                onRetry: () =>
                    ref.read(clubForfeitsProvider(_key).notifier).refresh(),
              )
            : const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: CircularProgressIndicator()),
              )
      else if (list.isEmpty)
        _Empty(l10n.mySpaceForfeitNoEntry)
      else
        MySpaceBox(
          children: [
            for (final forfeit in list)
              _ForfeitTile(
                label: clubForfeitLabel(forfeit, club.label, l10n),
                value: forfeit.forfeit,
                state: forfeitSwitch(forfeit, canManage: true, now: now),
                onSet: (value) => _setForfeit(forfeit.entryId, value),
              ),
          ],
        ),
    ];
  }

  Future<void> _setForfeit(int entryId, bool forfeit) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final outcome = await ref
        .read(clubForfeitsProvider(_key).notifier)
        .setForfeit(entryId, forfeit: forfeit);
    final message = forfeitOutcomeMessage(outcome, l10n);
    if (!mounted || message == null) return;
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  /// Les forfaits des résultats publiés, pour qui ne peut pas en déclarer.
  List<Widget> _forfeits(List<ClubRace> forfeits, AppLocalizations l10n) => [
    MySpaceHeader(l10n.mySpaceForfeits),
    if (forfeits.isEmpty)
      _Empty(l10n.mySpaceNoForfeit)
    else
      MySpaceBox(
        children: [
          for (final race in forfeits)
            _ClubRaceTile(
              title: clubRaceTitle(race),
              subtitle: clubRaceLine(race, l10n),
              trailing: ResultText(label: resultLabel(race.race.row!.result)),
              onTap: () => _open(race.athletes),
            ),
        ],
      ),
    const SizedBox(height: 12),
    Text(
      l10n.mySpaceForfeitsHint,
      style: const TextStyle(color: AppColors.textSecondary),
    ),
  ];

  /// Un relais : on choisit lequel des relayeurs ouvrir.
  void _open(List<Participant> athletes) {
    void push(Participant athlete) => context.push(
      Routes.mySpaceParticipant(widget.competitionId, athlete.id),
    );
    if (athletes.length == 1) {
      push(athletes.single);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final athlete in athletes)
              ListTile(
                title: Text(participantName(athlete)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  push(athlete);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ClubRaceTile extends StatelessWidget {
  const _ClubRaceTile({
    this.time,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  final String? time;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final time = this.time;
    return ListTile(
      onTap: onTap,
      leading: time == null
          ? null
          : SizedBox(
              width: 44,
              child: Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: subtitle.isEmpty
          ? null
          : Text(
              subtitle,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
    );
  }
}

class _ForfeitTile extends StatelessWidget {
  const _ForfeitTile({
    required this.label,
    required this.value,
    required this.state,
    required this.onSet,
  });

  final ClubForfeitLabel label;

  /// Nul : état inconnu, qu'aucun interrupteur ne doit prétendre.
  final bool? value;
  final ForfeitSwitch state;
  final ValueChanged<bool> onSet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final value = this.value;
    const spinner = SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
    const lock = Icon(Icons.lock_outline, color: AppColors.textSecondary);
    return ListTile(
      title: Text(
        label.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.subtitle,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (state == ForfeitSwitch.unknown)
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => onSet(true),
                  child: Text(l10n.mySpaceForfeitDeclare),
                ),
                TextButton(
                  onPressed: () => onSet(false),
                  child: Text(l10n.mySpaceForfeitCancel),
                ),
              ],
            ),
        ],
      ),
      trailing: switch (state) {
        ForfeitSwitch.hidden || ForfeitSwitch.unknown => null,
        ForfeitSwitch.active when value != null => Switch(
          value: value,
          onChanged: onSet,
        ),
        ForfeitSwitch.sending when value != null => Switch(
          value: value,
          onChanged: null,
        ),
        ForfeitSwitch.locked when value != null => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            lock,
            Switch(value: value, onChanged: null),
          ],
        ),
        ForfeitSwitch.sending => spinner,
        ForfeitSwitch.locked || ForfeitSwitch.active => lock,
      },
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: _FigureContent(value: value, label: label),
  );
}

class _FigureContent extends StatelessWidget {
  const _FigureContent({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
      ),
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    ],
  );
}

class _FigureAction extends StatelessWidget {
  const _FigureAction({
    required this.label,
    required this.caption,
    required this.onPressed,
  });

  final String label;
  final String caption;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextButton(onPressed: onPressed, child: Text(label)),
      Text(
        caption,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    ],
  );
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.yellow,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
      ),
    ),
  );
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 32),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppColors.textSecondary),
    ),
  );
}
