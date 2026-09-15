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
| Unité de classement | **L'engagement**, en individuel comme en relais |
| Libellé de la ligne | `Entry.organisme` si renseigné, sinon club du **premier athlète** — la règle de `entryClubId` |
| Pointage marshalling | **Par athlète** ; la ligne d'équipe agrège et un appui dessus pointe toute l'équipe |
| Statut agrégé | **Présent ssi tous présents, en attente sinon.** Jamais « absent » agrégé |
| Jauge de pointage | Reste en **têtes**, plus une mention « n/m équipes complètes » |
| Tri par nom | Sur le **libellé affiché** : club en relais, nom de l'athlète en individuel |
| Classement d'un relais | Une ligne = une équipe ; **le premier bracelet lu classe l'équipe** |
| Pénalités | Au niveau de **l'engagement seulement** |
| Remplacement d'un membre | **Placeholder inerte + seam** : bouton sur chaque athlète déplié, message « bientôt disponible » |
| Épreuves individuelles | **Même composant**, sans chevron ni bouton de remplacement |
| Classements locaux hérités | **Pas de migration** : ils sont écartés, et l'écran de saisie apprend à relire les résultats publiés sur FFSS |

## Le compétiteur est l'engagement

`ProgrammeRace.finishOrder` et `CoursePenalty` sont aujourd'hui indexés par id
d'athlète. Ils passent à l'**id d'engagement**. Un engagement porte un athlète ou
quatre, mais il reste la seule chose qui prend une place, et FFSS le dit déjà à
sa façon : `submitResult` veut un `engagement`, `HeatResult` en porte un.

Côté Dart les champs se renomment pour dire ce qu'ils contiennent —
`ProgrammeRace.competitorOrder`, `CoursePenalty.competitorId` — en gardant leurs
clés JSON (`finishOrder`, `athleteId`) : rien à réécrire dans le stockage, et la
règle de lecture ci-dessous rend l'ancienne donnée inoffensive.

Ce que ça simplifie, en plus de rendre le relais saisissable :

| | aujourd'hui | avec l'engagement |
|---|---|---|
| `_outcomesFor` | balaie les athlètes d'une place pour y trouver rang et pénalité | `places[seat.entryId]`, direct |
| `_serverResults` | recopie le résultat FFSS sur **chaque** athlète du siège | indexé par engagement, plus de fan-out |
| `_rankedEntriesOf` | reconstruit athlète → engagement, faux en relais | l'ordre **est** une liste d'engagements : la fonction disparaît |

Les fonctions de `course_ranking.dart` (`placesOf`, `withFinisher`, `withPlace`,
`withoutAthlete`) sont agnostiques de ce que l'id désigne : seuls leurs noms de
paramètres changent (`athleteId` → `competitorId`).

Un module `lib/app/domain/models/competitor.dart` porte ce que l'affichage
réclame, en fonctions pures testées sans mock, à côté de `course_ranking.dart` :

```dart
/// Les engagements d'une course tirée, dans l'ordre des couloirs.
///
/// Reconstruits depuis `entryIds` ; quand il est vide — un tirage antérieur au
/// champ — chaque athlète de `athleteIds` devient son propre engagement, ce qui
/// redonne exactement le comportement individuel d'avant.
List<Entry> competitorsOf(
  ProgrammeRace race, {
  required Map<int, Entry> entries,
  required Map<int, Athlete> athletes,
});

/// Vrai quand l'ordre stocké ne nomme que des compétiteurs de cette course.
///
/// Un ordre hérité de relais contient des ids d'athlètes, dont aucun n'est un
/// engagement de la course : il se reconnaît sans drapeau de version. Un
/// tirage individuel ancien, lui, reste valide — son engagement de repli porte
/// l'id de son athlète, donc l'ordre déjà saisi est conservé tel quel.
bool isCompetitorOrder(List<List<int>> order, List<Entry> competitors);
```

## Les classements hérités : écartés, puis relus depuis FFSS

Un `finishOrder` déjà stocké contient des ids d'athlètes, et rien dans le JSON
ne dit lequel des deux sens il porte. **Il n'est pas converti.**
`isCompetitorOrder` reste un contrôle strict — vrai seulement quand *tous* les
ids de l'ordre nomment un compétiteur de la course — mais la **politique** de
lecture, dans `RaceCourseController._readStoredRanking`, distingue trois cas
plutôt que de tout garder ou tout jeter :

1. **Ordre valide** (`isCompetitorOrder` vrai) : conservé tel quel.
2. **Ordre courant amputé** — au moins un id nomme encore un compétiteur de la
   course, mais pas tous. C'est un ordre actuel qui a perdu des engagements
   (retrait depuis le tirage, ou `getEntries` tronqué) : il est conservé
   **moins** les ids disparus, densément renuméroté, et signalé par
   `course_ranking_competitor_gone`.
3. **Ordre hérité** — aucun id ne nomme un compétiteur de la course. C'est
   l'ancien sens, indexé par athlète : il est écarté en bloc, pénalités
   comprises. Seuls les relais sont concernés : sur un tirage individuel
   antérieur à `entryIds`, le compétiteur de repli porte l'id de son athlète,
   donc le classement déjà saisi reste dans le cas 1.

Le cas 3 n'est annoncé (`course_ranking_dropped`) que si la relecture décrite
ci-dessous ne remplit pas la course à sa place — sinon rien n'a été perdu, et
le dire serait une fausse alerte sur les courses mêmes que cette relecture
sert.

Pour que l'opérateur ne retrouve pas une course validée affichée vide, l'écran de
saisie **relit ce que FFSS détient** :

1. `stored.runId` → la course dans l'arbre des réunions (`_locate`, déjà écrit
   pour la validation) → `run.heat?.id` ;
2. `getHeatResultsByHeat({heatId})` → un `HeatResult` par engagement ;
3. l'ordre se reconstitue par rang croissant, les engagements sans rang
   deviennent des pénalités.

Trois précisions :

- **Priorité** : la saisie locale gagne quand elle existe et qu'elle est bien un
  ordre d'engagements. La relecture ne sert que si le local est vide ou hérité —
  on ne réécrit jamais par-dessus ce que l'opérateur est en train de saisir.
- **`HeatResult` gagne son `status`.** Le DTO porte `Statut` (0 classé, 1
  disqualifié, 2 forfait) et le mapper le jette. Sans lui, un forfait relu
  devient indiscernable d'un « pas encore classé » — c'est d'ailleurs déjà le cas
  aujourd'hui dans `RaceStructureController.penaltyInRace`, qui ne sait
  reconstruire qu'une disqualification.
- **Le trajet évite un aller-retour** quand il peut : l'onglet Séries est le seul
  appelant de `Routes.raceCourse` et connaît déjà l'id de série et ses résultats.
  Il les passe en argument ; la résolution par `getMeetings` n'est que le repli.

**Défaut corrigé en chemin** : `_heatId` repart à 0 à chaque ouverture de
l'écran, et `submitHeat(id: null)` **crée** une série. Revalider une course après
avoir rouvert l'écran empile aujourd'hui une seconde série sur FFSS. La relecture
retrouve la série existante et la revalidation la réécrit.

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
un bracelet pointe son porteur, qu'il soit seul ou en équipe. La présence reste
stockée **par athlète** dans `AttendanceService` : c'est ce que le bracelet
pointe, et l'éligibilité au tirage (« tous présents ») s'en déduit.

### Tirage des séries

`_LaneRow` devient un `EntryGroupTile` : numéro de couloir à gauche,
`swap_horiz` à droite, le tap conserve « déplacer vers une autre série », le
chevron déplie. `HeatDrawController` travaille déjà en `List<List<Entry>>` : il
ne gagne que l'état déplié. `_ClubDistribution` est déjà par engagement et ne
change pas.

### Onglet Séries

`athletesOf(ProgrammeRace)` est doublé d'un `entriesOf(ProgrammeRace)` bâti sur
`competitorsOf`, avec un index `_entriesById` rempli au même endroit que
`_athletesById`. `placeInRace` et `penaltyInRace` prennent un id d'engagement, et
`_serverResults` cesse de recopier chaque résultat sur les athlètes du siège. Le
filtre de recherche fait mouche si **un** athlète de l'engagement correspond, et
déplie alors l'équipe. Le compteur de la tuile reste en têtes
(`race.athleteIds.length`).

### Saisie des places

Le vrai chantier. `athletes` devient `competitors` (des `Entry`),
`orderedAthletes` devient `orderedCompetitors`, et `assign`, `remove`,
`setPlace`, `setPenalty`, `clearPenalty` prennent un engagement. Conséquences :

- le scan résout bracelet → athlète → son engagement, puis classe l'équipe ; un
  coéquipier lu ensuite retombe sur `course_athlete_already_ranked`, le message
  de doublon qui existe déjà ;
- `isComplete` compte les engagements, donc la place la plus haute qu'une course
  distribue est son nombre d'équipes moins ses retraits ;
- `_PlaceField` s'accroche à la ligne d'équipe, pas aux athlètes dépliés ;
- le menu contextuel (forfait, DSQ, retrait) ne s'ouvre que sur la ligne
  d'équipe ;
- `load()` gagne la relecture serveur décrite plus haut ;
- `_outcomesFor` se simplifie, la publication FFSS ne change pas de forme.

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

- `test/data/models/competitor_test.dart` — reconstruction des engagements depuis
  un `ProgrammeRace`, repli quand `entryIds` est vide, reconnaissance d'un ordre
  hérité.
- `race_course_controller_test.dart` — une équipe classée au premier bracelet, le
  coéquipier lu ensuite signalé comme doublon, `isComplete` en équipes, ordre
  hérité écarté, relecture serveur qui reconstitue rangs **et** forfaits, et
  local qui l'emporte sur le serveur.
- `race_detail_controller_test.dart` — agrégation du statut d'équipe, cycle de
  présence groupée, `teamCounts`, tri sur le libellé affiché.
- `heat_draw_controller_test.dart` — déplié/replié.
- `race_structure_controller_test.dart` — `entriesOf`, repli sans `entryIds`,
  filtre qui déplie l'équipe, place et pénalité lues par engagement.
- `test/data/repositories/meeting_repository_test.dart` — `status` remonté dans
  `HeatResult`.

Pas de test de widget, conformément au dépôt : vérification à l'écran par
`flutter run`, et le parcours sur appareil revient à l'utilisateur.

## Traductions

Trois clés, dans **les deux** langues : `relay_substitute`,
`relay_substitute_coming_soon`, `teams_complete`.
