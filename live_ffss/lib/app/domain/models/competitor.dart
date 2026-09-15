/// Ce qui prend une place dans une course : l'engagement.
///
/// Un engagement porte un athlète ou quatre, mais il reste l'unité du
/// classement — c'est aussi ce que FFSS attend (`submitResult` veut un
/// `engagement`). Les fonctions de `course_ranking.dart` manipulent des ids de
/// compétiteurs, c'est-à-dire des ids d'engagements.
library;

import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';

/// Les engagements d'une course tirée, dans l'ordre des couloirs.
///
/// Un id que les engagés ne portent plus est sauté plutôt que rendu en ligne
/// vide : un engagement retiré depuis le tirage est la façon ordinaire dont ça
/// arrive.
///
/// Quand [ProgrammeRace.entryIds] est vide — un tirage antérieur au champ —
/// chaque athlète de `athleteIds` devient son propre engagement, **et porte
/// l'id de cet athlète**. Le classement déjà saisi sur cette course reste donc
/// lisible tel quel, ce qui n'est vrai que parce qu'un tirage de cette époque
/// est nécessairement individuel.
List<Entry> competitorsOf(
  ProgrammeRace race, {
  required Map<int, Entry> entries,
  required Map<int, Athlete> athletes,
}) {
  if (race.entryIds.isEmpty) {
    return [
      for (final id in race.athleteIds)
        if (athletes[id] case final Athlete athlete)
          Entry(
            id: athlete.id,
            category: const Category(id: 0, name: ''),
            status: 0,
            statusLabel: '',
            athletes: [athlete],
          ),
    ];
  }
  return [
    for (final id in race.entryIds)
      if (entries[id] case final Entry entry) entry,
  ];
}

/// Vrai quand [order] ne nomme que des compétiteurs de cette course.
///
/// Sert à écarter un classement hérité sans drapeau de version : un ordre
/// écrit avant que le compétiteur soit l'engagement contient des ids
/// d'athlètes, dont aucun n'est un engagement de la course. Un seul id
/// étranger condamne l'ordre entier — un classement à moitié compris est pire
/// qu'un classement à refaire.
bool isCompetitorOrder(List<List<int>> order, List<Entry> competitors) {
  if (order.isEmpty) return true;
  final ids = {for (final competitor in competitors) competitor.id};
  for (final group in order) {
    for (final id in group) {
      if (!ids.contains(id)) return false;
    }
  }
  return true;
}
