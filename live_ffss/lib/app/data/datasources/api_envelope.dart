// Les deux lectures que toute écriture FFSS demande, au même endroit pour
// toutes. Les dix `submit*` de l'app les faisaient de quatre façons
// différentes : quatre toléraient un id rendu en chaîne, six exigeaient un
// entier, et quatre doublaient le test d'enveloppe que `HttpClient` fait déjà.
// Un id servi en `"123"` faisait donc passer une création réussie pour un
// refus, selon la route.

/// L'id que FFSS vient d'attribuer, 0 quand la réponse n'en porte aucun.
///
/// `id` arrive entier ou chaîne selon la route — voir la §1 de
/// `docs/FFSS_API.md`, qui prévient que l'API n'est pas constante là-dessus.
int assignedId(Map<String, dynamic> body) {
  final assigned = body['id'];
  if (assigned is int) return assigned;
  if (assigned is String) return int.tryParse(assigned) ?? 0;
  return 0;
}

/// Si l'écriture a été acceptée.
///
/// Seul un refus explicite — `false`, ou la chaîne `"false"` que FFSS sert
/// parfois — compte comme un échec. Un `success` absent vaut succès : une
/// bonne partie des routes omet le champ, et `HttpClient` a de toute façon
/// déjà levé sur un refus avant d'arriver ici.
bool wasAccepted(Map<String, dynamic> body) {
  final success = body['success'];
  return success != false && success != 'false';
}
