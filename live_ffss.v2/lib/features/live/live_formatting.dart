import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/live.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
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

/// « Prochaine série : 200m Obstacles · Messieurs · Série 2/11 · 08:44 »,
/// pour le Live où rien ne se court encore.
String liveNextLabel(
  LiveEntry entry,
  ({int position, int total}) position,
  AppLocalizations l10n,
) => l10n.liveNext(
  [
    liveCardTitle(entry, l10n),
    liveCardSubtitle(entry, position, l10n),
  ].where((part) => part.isNotEmpty).join(' · '),
);

/// Ce que montre le corps d'une carte du Live.
enum LiveCardBody {
  /// Aucune place encore lue (lecture en cours ou en échec) : rien ne dit
  /// encore que la série est sans résultat.
  loading,

  /// La liste de départ d'une série qui se court, avant le premier temps.
  startList,

  /// Une série courue dont aucun temps n'est publié.
  waitingResults,

  /// Les places, par place puis par couloir.
  results,
}

/// [lanes] : les places occupées de la série ; [lanesRead] : une au moins a
/// été lue (`LiveView.lanesReadFor`).
LiveCardBody liveCardBody(
  Heat heat,
  List<LaneAssignment> lanes, {
  required bool lanesRead,
}) {
  if (hasPublishedResults(lanes)) return LiveCardBody.results;
  if (!lanesRead) return LiveCardBody.loading;
  return heat.status == RunStatus.finished
      ? LiveCardBody.waitingResults
      : LiveCardBody.startList;
}

enum LiveBadge { live, marshalling, provisional, validated }

/// Une série qui se court garde son badge même avec des résultats : le
/// bandeau de validation dit déjà qu'ils sont temporaires.
LiveBadge liveBadge(Heat heat) => switch (heat.status) {
  RunStatus.inProgress => LiveBadge.live,
  RunStatus.marshalling => LiveBadge.marshalling,
  _ when isProvisional(heat) => LiveBadge.provisional,
  _ => LiveBadge.validated,
};

/// Le bandeau « en attente de validation » ne vaut que sur des résultats.
bool livePendingBanner(Heat heat, LiveCardBody body) =>
    body == LiveCardBody.results && isProvisional(heat);
