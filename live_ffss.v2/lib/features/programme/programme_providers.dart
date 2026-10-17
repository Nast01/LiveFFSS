import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/domain/programme.dart';

/// L'API ne pousse rien : le programme se relit à ce rythme.
const Duration programmeRefresh = Duration(seconds: 30);

/// Le programme d'une compétition. Libéré dès que plus aucun écran ne
/// l'écoute (`autoDispose`), ce qui annule la minuterie : aucun appel ne part
/// pour un onglet que personne ne regarde.
final programmeProvider = FutureProvider.autoDispose.family<Programme, int>((
  ref,
  competitionId,
) {
  final timer = Timer(programmeRefresh, ref.invalidateSelf);
  ref.onDispose(timer.cancel);
  return ref.watch(meetingRepositoryProvider).getProgramme(competitionId);
});

/// Le jour affiché, par compétition. Tant que l'utilisateur n'en a pas choisi,
/// c'est le jour d'ouverture (`initialDay`), connu dès que le programme l'est.
final selectedDayProvider = NotifierProvider.autoDispose
    .family<SelectedDayNotifier, DateTime?, int>(SelectedDayNotifier.new);

class SelectedDayNotifier extends Notifier<DateTime?> {
  SelectedDayNotifier(this.competitionId);

  final int competitionId;

  // Dans un champ, pas seulement dans `state` : chaque relecture du
  // programme reconstruit ce notifier, et le choix ne doit pas s'y perdre.
  DateTime? _chosen;

  @override
  DateTime? build() {
    final chosen = _chosen;
    if (chosen != null) return chosen;
    final programme = ref.watch(programmeProvider(competitionId)).value;
    if (programme == null) return null;
    return initialDay(
      programmeDays(programme.meetings),
      ref.read(clockProvider)(),
    );
  }

  void select(DateTime day) {
    _chosen = day;
    state = day;
  }
}

/// Les réunions que l'utilisateur a dépliées ou repliées à la main (id →
/// dépliée). Sans geste, une réunion suit [isMeetingExpanded]. Pas
/// d'autoDispose : le choix tient tant que l'application est ouverte, d'un
/// jour et d'une compétition à l'autre.
class MeetingExpansionNotifier extends Notifier<Map<int, bool>> {
  @override
  Map<int, bool> build() => const {};

  void toggle(int meetingId, {required bool currentlyExpanded}) =>
      state = {...state, meetingId: !currentlyExpanded};
}

final meetingExpansionProvider =
    NotifierProvider<MeetingExpansionNotifier, Map<int, bool>>(
      MeetingExpansionNotifier.new,
    );

/// Une réunion terminée se replie d'office ; un geste de l'utilisateur
/// l'emporte.
bool isMeetingExpanded(
  Map<int, bool> expansion,
  int meetingId, {
  required bool finished,
}) => expansion[meetingId] ?? !finished;
