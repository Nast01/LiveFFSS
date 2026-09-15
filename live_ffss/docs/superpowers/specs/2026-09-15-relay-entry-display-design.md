# Affichage d'un relais par engagement — design

**Date** : 2026-09-15
**État** : validé au cadrage, à implémenter
**Touche** : le marshalling, le tirage des séries, l'onglet Séries et la saisie
des places — les quatre écrans qui montrent des compétiteurs.

## Le problème

Un relais est **un engagement qui porte plusieurs athlètes**. Les données le
savent déjà : `Entry.athletes` est une liste, `drawHeats` tire des engagements
(« a lane seats one engagement whatever its size »), et `_outcomesFor` publie un
résultat par engagement. Les écrans, eux, aplatissent :

- **Marshalling** ([race_detail_entries_view.dart](../../../lib/app/module/competitions/views/race_detail_entries_view.dart)) —
  `sortedAthletes` fait `entries.expand((e) => e.athletes)` : une équipe de
  quatre occupe quatre lignes sans rien qui dise qu'elles vont ensemble.
- **Tirage** ([heat_draw_view.dart](../../../lib/app/module/competitions/views/heat_draw_view.dart)) —
  `_LaneRow` concatène « DUPONT Jean / MARTIN Luc / … » sur deux lignes, tronqué
  au-delà.
- **Onglet Séries** et **saisie des places** — les deux repartent de
  `ProgrammeRace.athleteIds`, donc à plat.

Pire que l'affichage, la **saisie des places** classe athlète par athlète :
`finishOrder` est une liste d'ids d'athlètes, `isComplete` exige que les quatre
membres soient placés, et une équipe de quatre consomme quatre places. Un relais
n'y est pas saisissable.

Un défaut caché en découle : `_rankedEntriesOf`
([race_course_controller.dart:629](../../../lib/app/module/competitions/controllers/race_course_controller.dart#L629))
apparie `entryIds[i]` ↔ `athleteIds[i]` un pour un pour reconstruire les
engagements qualifiés. Vrai en individuel, faux dès qu'un engagement porte
plusieurs athlètes : la qualification vers le tour suivant part alors sur les
mauvais engagements.

## Décisions prises au cadrage

| Question | Décision |
|---|---|
| Périmètre | Les **quatre** écrans, saisie des places comprise |
| Libellé de la ligne | `Entry.organisme` si renseigné, sinon club du **premier athlète** — la règle de `entryClubId` |
| Pointage marshalling | **Par athlète** ; la ligne d'équipe agrège et un appui dessus pointe toute l'équipe |
| Statut agrégé | **Présent ssi tous présents, en attente sinon.** Jamais « absent » agrégé |
| Jauge de pointage | Reste en **têtes**, plus une mention « n/m équipes complètes » |
| Tri par nom | Sur le **libellé affiché** : club en relais, nom de l'athlète en individuel |
| Classement d'un relais | Une ligne = une équipe ; **le premier bracelet lu classe l'équipe** |
| Pénalités | Au niveau de **l'engagement seulement** |
| Remplacement d'un membre | **Placeholder inerte + seam** : bouton sur chaque athlète déplié, message « bientôt disponible » |
| Épreuves individuelles | **Même composant**, sans chevron ni bouton de remplacement |

## La clé « compétiteur » : le premier athlète de l'engagement

`ProgrammeRace.finishOrder` et `CoursePenalty` sont indexés par id d'athlète.
Trois faits rendent toute migration inutile :

- `_outcomesFor` balaie **tous** les athlètes d'une place pour y trouver un rang
  ou une pénalité — « a team races as one, so any of its athletes speaks for it » ;
- à l'import, `_serverResults` recopie le résultat FFSS de l'engagement **sur
  chacun de ses athlètes**
  ([race_structure_controller.dart:470](../../../lib/app/module/competitions/controllers/race_structure_controller.dart#L470)) ;
- `placesOf`, `withFinisher`, `withPlace` et `withoutAthlete` sont agnostiques de
  ce que l'id désigne.

Donc : **un engagement est représenté dans le classement par l'id de son premier
athlète** — son chef de file. Pas de changement de schéma, pas de migration, et
les épreuves individuelles restent identiques au bit près, un athlète étant son
propre chef de file. La publication FFSS marche telle quelle.

La règle vit dans `lib/app/domain/models/competitor.dart`, en fonctions pures
testées sans mock, à côté de `course_ranking.dart` :

```dart
/// L'athlète qui représente l'engagement dans un classement, 0 s'il n'en
/// porte aucun.
int leadAthleteId(Entry entry);

/// Les engagements d'une course tirée, dans l'ordre des couloirs.
///
/// Reconstruits depuis `entryIds` ; quand il est vide — un tirage antérieur au
/// champ — chaque athlète de `athleteIds` devient son propre engagement, ce qui
/// redonne exactement le comportement individuel d'avant.
List<Entry> competitorsOf(ProgrammeRace race, Map<int, Entry> byId);

/// Un `finishOrder` où chaque engagement n'apparaît qu'une fois, par son chef
/// de file.
List<List<int>> normalizedOrder(List<List<int>> order, List<Entry> competitors);
```

Deux corollaires :

- **`_rankedEntriesOf` est réparé** : le découpage se fait par la taille réelle
  de chaque engagement, plus par un curseur qui avance d'un athlète par
  engagement.
- **Normalisation au chargement** : un `finishOrder` de relais écrit par le code
  actuel classe les quatre membres l'un derrière l'autre (1, 2, 3, 4 puis 5…).
  `normalizedOrder` ne garde que le premier athlète rencontré de chaque
  engagement, et le classement se redense de lui-même — l'équipe arrivée
  deuxième passe de la place 5 à la place 2. **Risque assumé** : cela réécrit un
  classement déjà saisi, au chargement, sans le dire. C'est voulu — l'ancien
  était faux — mais c'est silencieux.

## Le composant partagé

`lib/app/presentation/shared/entry_group_tile.dart`, purement présentationnel,
sans dépendance à un contrôleur. Les quatre écrans n'ont ni le même contenu à
gauche ni le même à droite : ils passent des slots.

```dart
EntryGroupTile({
  required Entry entry,
  required String title,          // club/organisme en relais, nom de l'athlète en individuel
  String? subtitle,               // « 4 athlètes · 3 présents », club, temps d'engagement…
  Widget? leading,                // n° de couloir, place, champ de saisie
  Widget? trailing,               // pastille de présence, icône d'action
  bool expanded = false,
  VoidCallback? onToggle,         // null ⇒ pas de chevron (individuel)
  VoidCallback? onTap,
  ValueChanged<Offset>? onLongPress,
  Widget? Function(Athlete)? athleteTrailing,   // statut par athlète, quand l'écran en a un
  void Function(Entry, Athlete)? onSubstitute,  // le bouton « remplacer »
  bool highlight = false,         // le surlignage de filtre de l'onglet Séries
})
```

Le libellé vient de deux fonctions libres dans
`presentation/modules/competitions/entry_formatting.dart` — `entryTitle(Entry)`
et `entrySubtitle(Entry)` — à côté des autres helpers de formatage, jamais
calculées dans un contrôleur. L'avatar reste `ClubAvatar`, qui garde son ordre de
repli logo → cap → initiale.

Un engagement à un athlète rend exactement la ligne d'aujourd'hui : ni chevron,
ni bouton de remplacement, aucun athlète déplié.

**L'état déplié vit dans le contrôleur**, pas dans le widget : `RxSet<int>
expandedEntries` plus `isEntryExpanded(Entry)` / `toggleEntry(Entry)`, sur le
modèle de `RaceStructureController.isExpanded(ProgrammeRace)` qui existe déjà. Un
état local au widget se perdrait au recyclage du `ListView` dès qu'on fait
défiler.

## Les quatre écrans

### Marshalling

Les lignes deviennent des engagements : `sortedEntries` remplace
`sortedAthletes`, et les trois tris (`AthleteSortMode`, renommé
`CompetitorSortMode`) s'appliquent au libellé affiché. Trois ajouts au
contrôleur :

- `teamAttendance(Entry)` — présent ssi tous présents, en attente sinon ;
- `cycleTeamAttendance(Entry)` — tous présents → tous absents → tous en attente →
  tous présents. Le cycle ne peut pas se lire sur le statut agrégé, qui ne vaut
  jamais « absent » : il se lit sur les statuts réels de l'équipe ;
- `teamCounts` — `(complete, total)` pour la mention « n/m équipes complètes ».

`attendanceCounts` et le scan RFID ne bougent pas : la jauge compte des têtes, et
un bracelet pointe son porteur, qu'il soit seul ou en équipe.

### Tirage des séries

`_LaneRow` devient un `EntryGroupTile` : numéro de couloir à gauche,
`swap_horiz` à droite, le tap conserve « déplacer vers une autre série », le
chevron déplie. `HeatDrawController` travaille déjà en `List<List<Entry>>` : il
ne gagne que l'état déplié. `_ClubDistribution` est déjà par engagement et ne
change pas.

### Onglet Séries

`athletesOf(ProgrammeRace)` est doublé d'un `entriesOf(ProgrammeRace)` bâti sur
`competitorsOf`, avec un index `_entriesById` rempli au même endroit que
`_athletesById`. Place et pénalité se lisent sur le chef de file
(`placeInRace(race, leadAthleteId(entry))`). Le filtre de recherche fait mouche
si **un** athlète de l'engagement correspond, et déplie alors l'équipe. Le
compteur de la tuile reste en têtes (`race.athleteIds.length`).

### Saisie des places

Le vrai chantier. `athletes` devient `competitors` (des `Entry`),
`orderedAthletes` devient `orderedCompetitors`, et `assign`, `remove`,
`setPlace`, `setPenalty`, `clearPenalty` prennent un engagement et écrivent sur
son chef de file. Conséquences :

- le scan résout bracelet → athlète → son engagement, puis classe l'équipe ; un
  coéquipier lu ensuite retombe sur `course_athlete_already_ranked`, le message
  de doublon qui existe déjà ;
- `isComplete` compte les engagements, donc la place la plus haute qu'une course
  distribue est son nombre d'équipes moins ses retraits ;
- `_PlaceField` s'accroche à la ligne d'équipe, pas aux athlètes dépliés ;
- le menu contextuel (forfait, DSQ, retrait) ne s'ouvre que sur la ligne
  d'équipe ;
- `_outcomesFor` et la publication FFSS ne changent pas.

## Le seam de remplacement

`onSubstitute` est un callback optionnel `(Entry, Athlete) => void`, porté par
chaque athlète déplié. Tant que le détail technique n'est pas fourni, les écrans
lui passent un déclencheur de `UiMessage` avec la clé
`relay_substitute_coming_soon`. Le câblage réel — choisir un remplaçant,
l'écrire côté FFSS — viendra sans retoucher le widget.

À noter pour ce jour-là : `Athlete.isSubstitute` existe déjà sur les athlètes
issus de l'endpoint engagement, et `withdrawAthlete` est toujours
`UnimplementedError`. Le remplacement passera vraisemblablement par là.

## Tests

- `test/data/models/competitor_test.dart` — chef de file, reconstruction depuis
  un `ProgrammeRace`, repli quand `entryIds` est vide, normalisation d'un
  `finishOrder` relais hérité.
- `race_detail_controller_test.dart` — agrégation du statut d'équipe, cycle de
  présence groupée, `teamCounts`, tri sur le libellé affiché.
- `race_course_controller_test.dart` — une équipe classée au premier bracelet, le
  coéquipier lu ensuite signalé comme doublon, `isComplete` en équipes,
  `_rankedEntriesOf` sur des engagements à quatre athlètes.
- `heat_draw_controller_test.dart` — déplié/replié.
- `race_structure_controller_test.dart` — `entriesOf`, repli sans `entryIds`,
  filtre qui déplie l'équipe.

Pas de test de widget, conformément au dépôt : vérification à l'écran par
`flutter run`, et le parcours sur appareil revient à l'utilisateur.

## Traductions

Trois clés, dans **les deux** langues : `relay_substitute`,
`relay_substitute_coming_soon`, `teams_complete`.
