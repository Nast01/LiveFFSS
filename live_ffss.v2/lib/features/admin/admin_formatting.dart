import 'package:live_ffss_v2/core/network/network_log.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/features/my_space/my_space_providers.dart';
import 'package:live_ffss_v2/features/my_space/official_space_providers.dart';

/// « 85 ms » sous la seconde, « 1.3 s » au-delà : un journal se lit pour
/// repérer les lenteurs, pas pour mesurer au millième.
String formatDuration(Duration duration) {
  final ms = duration.inMilliseconds;
  if (ms < 1000) return '$ms ms';
  return '${(ms / 1000).toStringAsFixed(1)} s';
}

/// « 820 o », « 12.3 Ko », « 1.5 Mo » ; « - » quand rien n'est revenu.
String formatBytes(int? bytes) {
  if (bytes == null) return '-';
  if (bytes < 1024) return '$bytes o';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} Ko';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
}

/// Le journal à afficher : tout, ou seulement les requêtes en erreur. L'ordre
/// (plus récent d'abord) est celui du journal.
List<NetworkLogEntry> visibleEntries(
  List<NetworkLogEntry> entries, {
  required bool errorsOnly,
}) => errorsOnly ? entries.where((e) => e.failed).toList() : entries;

/// Les clubs des DQ et forfaits publiés, pour le filtre : un libellé par
/// club, trié ; un résultat sans club n'en propose pas.
List<String> decisionClubs(OfficialDecisions decisions) {
  final clubs = {
    for (final event in decisions.events)
      for (final row in event.rows)
        if (row.result.club.trim() case final club when club.isNotEmpty) club,
  }.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return clubs;
}

/// Les épreuves qui ont une DQ ou un forfait, dans leur ordre : le filtre
/// ne propose pas d'épreuve qui ne montrerait rien.
List<CompetitionEvent> decisionEvents(OfficialDecisions decisions) => [
  for (final event in decisions.events) event.event,
];

/// Les DQ et forfaits du club [club] (par libellé) et de l'épreuve
/// [eventId] ; nul : pas de filtre. Une épreuve sans ligne retenue
/// disparaît, son titre seul ne dirait rien.
List<EventDecisions> filterDecisions(
  List<EventDecisions> events, {
  String? club,
  int? eventId,
}) {
  final wanted = club?.trim();
  return [
    for (final event in events)
      if (eventId == null || event.event.id == eventId)
        if (wanted == null
                ? event
                : (
                    event: event.event,
                    rows: [
                      for (final row in event.rows)
                        if (row.result.club.trim() == wanted) row,
                    ],
                  )
            case final kept when kept.rows.isNotEmpty)
          kept,
  ];
}

/// Le club engagé de libellé [label] : les résultats ne portent que le
/// libellé, l'espace d'un club s'ouvre par son id.
int? clubIdOf(List<CompetitionClub> clubs, String label) {
  final wanted = label.trim();
  for (final club in clubs) {
    if (club.label.trim() == wanted) return club.id;
  }
  return null;
}
