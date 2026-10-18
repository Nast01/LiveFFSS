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
  int byName(CompetitionOfficial a, CompetitionOfficial b) =>
      foldForSearch(a.name).compareTo(foldForSearch(b.name));

  final principals = officials.where((o) => o.principal).toList()..sort(byName);
  final byLevel = <String, List<CompetitionOfficial>>{};
  for (final official in officials) {
    if (official.principal) continue;
    byLevel.putIfAbsent(official.level, () => []).add(official);
  }
  // A, B, C avant tout autre code : un niveau inconnu ne passe pas devant.
  const known = ['A', 'B', 'C'];
  final levels = byLevel.keys.toList()
    ..sort((a, b) {
      final ia = known.indexOf(a);
      final ib = known.indexOf(b);
      if (ia >= 0 && ib >= 0) return ia.compareTo(ib);
      if (ia >= 0) return -1;
      if (ib >= 0) return 1;
      return a.compareTo(b);
    });
  return [
    if (principals.isNotEmpty) (label: null, officials: principals),
    for (final level in levels)
      (label: level, officials: byLevel[level]!..sort(byName)),
  ];
}
