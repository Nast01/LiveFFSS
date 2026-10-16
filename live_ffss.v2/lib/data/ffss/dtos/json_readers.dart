/// FFSS sert certains nombres tantôt entiers, tantôt chaînes, selon la route.
Object? readInt(Map<dynamic, dynamic> json, String key) {
  final raw = json[key];
  if (raw is String) return int.tryParse(raw);
  return raw;
}

/// PHP sérialise un objet vide en `[]` : un objet attendu peut donc arriver
/// sous forme de tableau. Lu comme absent, au lieu de faire échouer la
/// lecture de toute la liste.
Object? readMap(Map<dynamic, dynamic> json, String key) {
  final raw = json[key];
  return raw is Map ? raw : null;
}
