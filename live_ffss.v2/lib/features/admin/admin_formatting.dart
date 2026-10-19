import 'package:live_ffss_v2/core/network/network_log.dart';

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
