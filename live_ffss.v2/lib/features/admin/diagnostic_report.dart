import 'dart:ui';

import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/core/network/network_log.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/features/settings/server_switch.dart';

/// Les erreurs du journal que le rapport de diagnostic reprend.
const int diagnosticErrorLimit = 20;

/// Le nom du serveur tel que l'app le montre en français : « Recette »,
/// « Production ».
final _fr = lookupAppLocalizations(const Locale('fr'));

/// Le rapport de diagnostic, copié dans le presse-papiers pour être envoyé
/// au développeur. Il est en français, sans traduction : c'est un relevé
/// technique, pas une page. Rien n'y identifie quelqu'un : ni compte, ni
/// jeton, ni nom d'athlète, ni chaîne de requête (retirée encore ici, au
/// cas où un chemin en porterait une) ; la file d'envoi n'y est que
/// comptée.
String diagnosticReport({
  required String version,
  required AppEnvironment environment,
  required int competitionId,
  String? competitionName,
  required bool accountAdmin,
  required List<OutboxOperation> queue,
  required List<NetworkLogEntry> log,
  required DateTime now,
}) {
  int count(OutboxState state) => queue.where((op) => op.state == state).length;
  final errors = log.where((entry) => entry.failed).take(diagnosticErrorLimit);
  final name = competitionName?.trim() ?? '';
  return [
    'LiveFFSS · rapport de diagnostic',
    'Date : ${_date(now)} ${_time(now)}',
    'Version : $version',
    'Serveur : ${serverLabel(environment, _fr)} (${environment.baseUrl})',
    'Compétition : $competitionId${name.isEmpty ? '' : ' · $name'}',
    'Rôle : ${accountAdmin ? 'admin du compte' : 'admin de la compétition'}',
    "File d'envoi : ${count(OutboxState.pending)} en attente, "
        '${count(OutboxState.sent)} envoyée(s), '
        '${count(OutboxState.rejected)} refusée(s)',
    'Dernières erreurs (${errors.length}) :',
    for (final entry in errors)
      '${_time(entry.at)} ${entry.method} ${entry.path.split('?').first} '
          '${entry.status ?? '-'} ${entry.error} [${entry.server}]',
  ].join('\n');
}

String _two(int n) => n.toString().padLeft(2, '0');

String _date(DateTime at) => '${at.year}-${_two(at.month)}-${_two(at.day)}';

String _time(DateTime at) =>
    '${_two(at.hour)}:${_two(at.minute)}:${_two(at.second)}';
