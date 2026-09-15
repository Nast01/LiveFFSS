import 'package:get/get.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/presentation/modules/competitions/athlete_formatting.dart';

/// Un engagement qui porte plus d'un athlète : un relais.
bool isTeamEntry(Entry entry) => entry.athletes.length > 1;

/// Ce qu'une ligne repliée annonce.
///
/// Une équipe court sous un club, pas sous un nom : l'organisme de
/// l'engagement l'emporte, le club du premier athlète prend le relais — la
/// règle qu'applique déjà `entryClubId` pour répartir les clubs dans un
/// tirage. Sans ni l'un ni l'autre, les noms restent le seul repère.
String entryTitle(Entry entry) {
  if (!isTeamEntry(entry)) {
    return entry.athletes.isEmpty ? '' : entry.athletes.first.displayName;
  }
  final label = entryClubLabel(entry);
  if (label.isNotEmpty) return label;
  return [for (final athlete in entry.athletes) athlete.displayName]
      .join(' / ');
}

/// La seconde ligne : le club en individuel, l'effectif en relais.
///
/// Traduite, donc à n'appeler que depuis une vue. Un contrôleur qui trie sur
/// le club passe par [entryClubLabel], qui ne traduit rien.
String entrySubtitle(Entry entry) => isTeamEntry(entry)
    ? '${entry.athletes.length} ${'athletes_lower'.tr}'
    : entryClubLabel(entry);

/// Le club résolu que porte l'engagement, pour [ClubAvatar].
Club? entryClub(Entry entry) {
  final organisme = entry.organisme;
  if (organisme != null && organisme.name.isNotEmpty) return organisme;
  for (final athlete in entry.athletes) {
    final club = athlete.club;
    if (club != null && club.name.isNotEmpty) return club;
  }
  return null;
}

/// Le club sous lequel l'engagement court, chaîne vide quand il n'en a aucun.
String entryClubLabel(Entry entry) {
  final club = entryClub(entry);
  if (club != null) return club.name;
  for (final athlete in entry.athletes) {
    if (athlete.clubLabel.isNotEmpty) return athlete.clubLabel;
  }
  return '';
}
