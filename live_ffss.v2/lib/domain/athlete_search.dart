import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/progression.dart';

/// Requête plus courte (repliée, rognée) : aucun résultat, une lettre en
/// donnerait des centaines.
const minSearchLength = 2;

const _accented = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿ';
const _plain = 'aaaaaaceeeeiiiinooooouuuuyy';

/// Minuscules sans accents (Latin-1) : « Élodie » se trouve en tapant
/// « elodie », et se range avec les « E ».
String foldForSearch(String value) {
  final lower = value.toLowerCase();
  final out = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    final i = _accented.indexOf(char);
    out.write(i < 0 ? char : _plain[i]);
  }
  return out.toString();
}

/// Espaces répétés réduits à un : « Martin  Hugo » tapé vite doit trouver.
String _normalize(String value) =>
    foldForSearch(value).trim().split(RegExp(r'\s+')).join(' ');

/// Les participants dont le prénom, le nom, « prénom nom » ou « nom prénom »
/// contient [query], sans accent ni casse ; triés par nom puis prénom.
List<Participant> searchParticipants(List<Participant> all, String query) {
  final needle = _normalize(query);
  if (needle.length < minSearchLength) return const [];
  final found = [
    for (final participant in all)
      if (_matches(participant, needle)) participant,
  ];
  found.sort((a, b) {
    final byLast = foldForSearch(
      a.lastName,
    ).compareTo(foldForSearch(b.lastName));
    if (byLast != 0) return byLast;
    final byFirst = foldForSearch(
      a.firstName,
    ).compareTo(foldForSearch(b.firstName));
    return byFirst != 0 ? byFirst : a.id.compareTo(b.id);
  });
  return found;
}

bool _matches(Participant participant, String needle) {
  final first = _normalize(participant.firstName);
  final last = _normalize(participant.lastName);
  return first.contains(needle) ||
      last.contains(needle) ||
      '$first $last'.contains(needle) ||
      '$last $first'.contains(needle);
}

/// Les courses du tour séries de [event], dans l'ordre du programme ; vide si
/// aucun déroulement ne le couvre.
List<Heat> heatsRoundOf(Programme programme, CompetitionEvent event) {
  final progression = progressionOfEvent(programme.progressions, event);
  if (progression == null) return const [];
  return [
    for (final meeting in programme.meetings)
      for (final item in meeting.items)
        if (item.roundId case final roundId?
            when progression.stageById(roundId)?.level == StageLevel.heats)
          ...item.heats,
  ];
}

/// Rang de chaque course dans le programme (réunions, créneaux, courses) :
/// l'ordre « du programme » d'une fiche.
Map<int, int> programmeOrder(Programme programme) {
  final order = <int, int>{};
  for (final meeting in programme.meetings) {
    for (final item in meeting.items) {
      for (final heat in item.heats) {
        order.putIfAbsent(heat.id, () => order.length);
      }
    }
  }
  return order;
}
