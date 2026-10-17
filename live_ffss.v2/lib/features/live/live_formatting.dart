import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/domain/live.dart';
import 'package:live_ffss_v2/features/home/competition_formatting.dart';
import 'package:live_ffss_v2/features/programme/programme_formatting.dart';

/// « 200m Obstacles · Messieurs » ; le nom du créneau quand la série n'a pas
/// d'épreuve.
String liveCardTitle(LiveEntry entry, AppLocalizations l10n) {
  final heat = entry.heat;
  if (heat.raceName.isEmpty) return entry.item.name;
  return [
    heat.raceName,
    if (heat.gender case final gender?) genderLabel(gender, l10n),
  ].join(' · ');
}

/// « Série 2/11 · 08:44 » ; le nom de la série quand elle est seule de son
/// tour, où un rang n'apprendrait rien.
String liveCardSubtitle(
  LiveEntry entry,
  ({int position, int total}) position,
  AppLocalizations l10n,
) => [
  if (position.total > 1)
    l10n.heatOfTotal(position.position, position.total)
  else
    entry.heat.name,
  timeLabel(entry.start),
].where((part) => part.isNotEmpty).join(' · ');
