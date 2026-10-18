import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/text_fold.dart';

part 'officials.freezed.dart';

/// Un officiel de la compétition, tel que `competition/evenement/:id/officiels`
/// le publie. Ni licence, ni année, ni sexe : l'écran ne les montre pas.
@freezed
abstract class CompetitionOfficial with _$CompetitionOfficial {
  const factory CompetitionOfficial({
    required int id,

    /// « NOM Prénom », comme le libellé d'un compte.
    required String name,

    /// Le code du niveau (`A`, `B`, `C`…).
    required String level,
    required bool principal,

    /// Les jours de la compétition où il officie.
    required List<int> days,
    required String daysLabel,
    required String club,
  }) = _CompetitionOfficial;
}

/// Les officiels par groupe : le juge principal seul d'abord (libellé nul),
/// puis les niveaux A, B, C, puis les autres codes par ordre alphabétique ;
/// chaque groupe trié par nom.
List<({String? label, List<CompetitionOfficial> officials})> groupOfficials(
  List<CompetitionOfficial> officials,
) {
  // Le nom d'abord, l'id ensuite : deux homonymes gardent un ordre stable.
  int byName(CompetitionOfficial a, CompetitionOfficial b) {
    final byText = foldForSearch(a.name).compareTo(foldForSearch(b.name));
    return byText != 0 ? byText : a.id.compareTo(b.id);
  }

  final principals = officials.where((o) => o.principal).toList()..sort(byName);
  final byLevel = <String, List<CompetitionOfficial>>{};
  for (final official in officials) {
    if (official.principal) continue;
    byLevel
        .putIfAbsent(official.level.trim().toUpperCase(), () => [])
        .add(official);
  }
  // A, B, C avant tout autre code ; un niveau vide (non renseigné) en dernier.
  const known = ['A', 'B', 'C'];
  int rank(String level) {
    if (level.isEmpty) return 2;
    return known.contains(level) ? 0 : 1;
  }

  final levels = byLevel.keys.toList()
    ..sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      return byRank != 0 ? byRank : a.compareTo(b);
    });
  return [
    if (principals.isNotEmpty) (label: null, officials: principals),
    for (final level in levels)
      (label: level, officials: byLevel[level]!..sort(byName)),
  ];
}
