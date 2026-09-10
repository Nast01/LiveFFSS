import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Une requête telle qu'elle est passée, avec ce qu'il faut pour comprendre
/// après coup ce que FFSS a répondu.
@immutable
class HttpLogEntry {
  const HttpLogEntry({
    required this.at,
    required this.method,
    required this.url,
    required this.durationMs,
    this.statusCode,
    this.requestBody,
    this.responseBody,
    this.error,
  });

  final DateTime at;
  final String method;
  final String url;
  final int durationMs;
  final int? statusCode;
  final String? requestBody;
  final String? responseBody;

  /// Renseigné quand la requête n'a pas abouti — coupure réseau, timeout.
  final String? error;
}

/// Tampon circulaire des dernières requêtes, tenu **hors de GetX**.
///
/// Hors du conteneur d'injection pour la même raison qu'`activeEnvironment` :
/// une bascule d'environnement le détruit, et un journal qui s'effacerait au
/// moment précis où l'on change de backend n'aurait aucun intérêt.
///
/// Éteint par défaut : rien n'est capturé tant que [enabled] est faux, et rien
/// ne l'est jamais hors build debug.
///
/// N'expose aucun objet réactif : le contrôleur en prend un instantané à
/// l'ouverture de l'écran et sur son bouton « rafraîchir ». Un second système
/// réactif à côté de celui de GetX coûterait plus que ce que gagnerait une
/// liste qui s'anime seule, sur un écran qu'on ne regarde pas pendant que les
/// requêtes partent.
class HttpLog {
  static const int capacity = 50;
  static const int bodyLimit = 8192;

  bool enabled = false;

  final List<HttpLogEntry> _entries = [];

  /// Les plus récentes d'abord.
  List<HttpLogEntry> get entries => List.unmodifiable(_entries);

  void record(HttpLogEntry entry) {
    if (!kDebugMode || !enabled) return;
    _entries.insert(0, entry);
    if (_entries.length > capacity) {
      _entries.removeRange(capacity, _entries.length);
    }
  }

  void clear() => _entries.clear();

  /// Borne un corps à [bodyLimit] caractères, en disant qu'il a été coupé —
  /// sans quoi on lirait une réponse tronquée en la croyant complète.
  ///
  /// La mention ajoutée est retranchée de la coupe elle-même : sans ça, un
  /// corps qui ne dépasse [bodyLimit] que de quelques caractères ressortirait
  /// plus long qu'avant troncature.
  static String? truncate(String? body) {
    if (body == null) return null;
    if (body.length <= bodyLimit) return body;
    final notice = '\n… tronqué (${body.length} caractères au total)';
    // Bornée à 0 : si `bodyLimit` descend un jour sous la longueur de l'avis,
    // `cut` deviendrait négatif et `substring` planterait.
    final cut = math.max(0, bodyLimit - notice.length);
    return '${body.substring(0, cut)}$notice';
  }
}

final HttpLog httpLog = HttpLog();
