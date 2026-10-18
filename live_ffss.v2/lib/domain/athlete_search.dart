import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/text_fold.dart';

/// Requête plus courte (repliée, rognée) : aucun résultat, une lettre en
/// donnerait des centaines.
const minSearchLength = 2;

// Traits d'union et apostrophes comptent pour des espaces : « jean pierre »
// trouve « Jean-Pierre », « d angelo » trouve « D'Angelo ».
final _separators = RegExp(r"[\s\-'’]+");

/// Espaces répétés réduits à un : « Martin  Hugo » tapé vite doit trouver.
String _normalize(String value) => foldForSearch(
  value,
).split(_separators).where((w) => w.isNotEmpty).join(' ');

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
