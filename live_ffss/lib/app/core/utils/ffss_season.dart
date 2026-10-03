/// La saison FFSS court du **1er octobre au 30 septembre** : le 1er octobre
/// 2025 ouvre la saison « 2025-2026 », que le 30 septembre 2026 referme. Un
/// mois de septembre appartient donc à la saison ouverte l'année précédente.
///
/// Dérivée de la date courante plutôt que fixée en constante : une saison
/// écrite en dur devient fausse au premier octobre qui suit, et la liste des
/// compétitions se met alors à remonter une saison révolue sans rien en dire.
int seasonOpeningYear(DateTime date) =>
    date.month >= 10 ? date.year : date.year - 1;

/// L'étiquette de saison telle que l'API l'attend : `2025-2026`.
String seasonLabel(DateTime date) {
  final opening = seasonOpeningYear(date);
  return '$opening-${opening + 1}';
}

/// Le 1er octobre qui ouvre la saison contenant [date].
DateTime seasonStart(DateTime date) => DateTime(seasonOpeningYear(date), 10, 1);
