# Affichage d'un relais par engagement — plan d'implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Afficher et manipuler un relais comme **un engagement** — une ligne dépliable portant le club et ses athlètes — dans les quatre écrans qui montrent des compétiteurs, et faire porter le classement sur l'engagement plutôt que sur l'athlète.

**Architecture:** Un compétiteur est un `Entry`, en individuel comme en relais. `ProgrammeRace.competitorOrder` et `CoursePenalty.competitorId` (clés JSON inchangées) portent des ids d'engagements ; les classements locaux hérités sont reconnus et écartés, et l'écran de saisie relit alors ce que FFSS détient. Un composant présentationnel unique, `EntryGroupTile`, sert les quatre écrans avec des slots.

**Tech Stack:** Flutter 3.41.9 / Dart 3.11.5, GetX, freezed + json_serializable, mocktail.

**Spec:** [docs/superpowers/specs/2026-09-15-relay-entry-display-design.md](../specs/2026-09-15-relay-entry-display-design.md)

## Global Constraints

- **Architecture** : `Controller → Repository → DataSource`, injection par constructeur uniquement. Pas de `Get.find()` dans un corps de contrôleur.
- **Discipline contrôleur** : pas de `Get.context!`, pas de `Get.snackbar`, pas de `Get.dialog`, pas de `.tr`, pas de `BuildContext` en paramètre. Les messages passent par `Rxn<UiMessage>` et la vue les affiche avec `showUiMessages`.
- **Traductions** : toute clé ajoutée l'est dans **les deux** fichiers (`lib/app/core/translations/fr_fr.dart` et `en_us.dart`). Aucune clé morte.
- **Codegen** : après toute modification d'un fichier freezed, `dart run build_runner build --delete-conflicting-outputs`, et les `.freezed.dart` / `.g.dart` sont commités avec la source.
- **Tests** : mocktail, `class _MockX extends Mock implements X {}`. **Aucun test de widget, aucun test d'intégration.**
- **Commandes** : `flutter test`, `dart format lib/ test/`, `flutter analyze` — en formes courtes (l'allowlist de permissions matche dessus).
- **Analyzer** : `strict-casts` et `strict-raw-types` sont actifs. Pas de `dynamic`.
- **Commentaires** : uniquement là où le *pourquoi* n'est pas évident. Pas de narration de la ligne suivante.
- **Vérification sur appareil** : impossible ici (ni toolchain Windows, ni Android). Les tâches s'arrêtent à `flutter test` + `flutter analyze` ; le parcours réel revient à l'utilisateur.

---

### Task 1: `HeatResult` porte son statut

FFSS renvoie `Statut` (0 classé, 1 disqualifié, 2 forfait) sur chaque résultat de série, et le repository le jette. Sans lui, un forfait relu depuis le serveur est indiscernable d'un « pas encore classé » — ce dont la tâche 9 a besoin, et qui manque déjà à l'onglet Séries.

**Files:**
- Modify: `lib/app/data/repositories/meeting_repository.dart:436-447` (`_getHeatResults`) et `:476-481` (typedef `HeatResult`)
- Test: `test/data/repositories/meeting_repository_test.dart` (groupe `getHeatResultsByHeat`, ~ligne 608)

**Interfaces:**
- Consumes: `HeatResultDto` (déjà porteur de `@JsonKey(name: 'Statut') int? status`)
- Produces: `typedef HeatResult = ({int entryId, int? rank, bool isDisqualified, String? complement, int status})` — `status` vaut 0 quand FFSS ne le renseigne pas.

- [ ] **Step 1: Écrire le test qui échoue**

Dans `test/data/repositories/meeting_repository_test.dart`, groupe `getHeatResultsByHeat` :

```dart
    test('le statut FFSS remonte tel quel', () async {
      when(() => ds.getHeatResults(1)).thenAnswer((_) async => const [
            HeatResultDto(
              rank: null,
              status: 2,
              entry: HeatResultEntryDto(id: 301),
            ),
          ]);

      final byHeat = await repo.getHeatResultsByHeat([1]);

      expect(byHeat[1]!.single.status, 2);
    });

    // Un resultat sans `Statut` est un classe ordinaire : inventer un forfait
    // sortirait l'engagement du classement sans que FFSS l'ait dit.
    test('un statut absent vaut classe', () async {
      when(() => ds.getHeatResults(1)).thenAnswer((_) async => const [
            HeatResultDto(rank: 1, entry: HeatResultEntryDto(id: 101)),
          ]);

      final byHeat = await repo.getHeatResultsByHeat([1]);

      expect(byHeat[1]!.single.status, 0);
    });
```

- [ ] **Step 2: Lancer le test et vérifier qu'il échoue**

Run: `flutter test test/data/repositories/meeting_repository_test.dart`
Expected: FAIL — `The getter 'status' isn't defined for the type ...`

- [ ] **Step 3: Ajouter le champ**

Dans `lib/app/data/repositories/meeting_repository.dart`, le typedef :

```dart
/// What FFSS holds for one competitor of a heat, as the Séries screen
/// redisplays it.
///
/// [status] is FFSS's own: 0 ranked, 1 disqualified, 2 forfeit. Absent on the
/// wire it reads 0 — a competitor FFSS says nothing about is a plain ranked
/// one, and inventing a withdrawal would take them out of a classification the
/// referee never touched.
typedef HeatResult = ({
  int entryId,
  int? rank,
  bool isDisqualified,
  String? complement,
  int status,
});
```

et `_getHeatResults` :

```dart
  Future<List<HeatResult>> _getHeatResults(int heatId) async {
    final dtos = await _dataSource.getHeatResults(heatId);
    return [
      for (final dto in dtos)
        if ((dto.entry?.id ?? 0) != 0)
          (
            entryId: dto.entry!.id,
            rank: dto.rank,
            isDisqualified: dto.isDisqualified,
            complement: dto.complement,
            status: dto.status ?? 0,
          ),
    ];
  }
```

- [ ] **Step 4: Réparer le seul autre constructeur de `HeatResult`**

`test/presentation/modules/competitions/controllers/race_structure_controller_test.dart` construit des `HeatResult` littéraux (helper `loadWithResults`, ~ligne 1374). Ajouter `status: 0` à chacun — ou `status: 1` là où le test pose déjà `isDisqualified: true`, ce qui est le même fait dit deux fois.

- [ ] **Step 5: Lancer toute la suite**

Run: `flutter test`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
dart format lib/ test/
git add lib/app/data/repositories/meeting_repository.dart test/data/repositories/meeting_repository_test.dart test/presentation/modules/competitions/controllers/race_structure_controller_test.dart
git commit -m "feat(results): HeatResult porte le statut FFSS"
```

---

### Task 2: Le module `competitor`

Deux fonctions pures : reconstruire les engagements d'une course tirée, et reconnaître un ordre de classement hérité. Aucun mock, sur le modèle de `course_ranking.dart`.

**Files:**
- Create: `lib/app/domain/models/competitor.dart`
- Test: `test/data/models/competitor_test.dart`

**Interfaces:**
- Consumes: `Entry`, `Athlete`, `ProgrammeRace`
- Produces:
  - `List<Entry> competitorsOf(ProgrammeRace race, {required Map<int, Entry> entries, required Map<int, Athlete> athletes})`
  - `bool isCompetitorOrder(List<List<int>> order, List<Entry> competitors)`

- [ ] **Step 1: Écrire les tests qui échouent**

Create `test/data/models/competitor_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/competitor.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';

void main() {
  Athlete athlete(int id) => Athlete(
        id: id,
        licenseeNumber: 'L$id',
        firstName: 'A$id',
        lastName: 'B$id',
        gender: Gender.female,
        year: 2000,
        nationalityCode: '',
        nationality: '',
        isValid: true,
      );

  Entry entry(int id, List<int> athleteIds) => Entry(
        id: id,
        category: const Category(id: 1, name: 'Senior'),
        status: 1,
        statusLabel: 'Engagé',
        athletes: [for (final a in athleteIds) athlete(a)],
      );

  group('competitorsOf', () {
    test('rend les engagements dans l ordre des couloirs', () {
      const race = ProgrammeRace(
        id: 7,
        number: 1,
        entryIds: [20, 10],
        athleteIds: [201, 202, 101, 102],
      );

      final competitors = competitorsOf(
        race,
        entries: {10: entry(10, [101, 102]), 20: entry(20, [201, 202])},
        athletes: const {},
      );

      expect([for (final c in competitors) c.id], [20, 10]);
      expect(competitors.first.athletes.length, 2);
    });

    test('un engagement que les engages ne portent plus est saute', () {
      const race = ProgrammeRace(id: 7, number: 1, entryIds: [10, 99]);

      final competitors = competitorsOf(
        race,
        entries: {10: entry(10, [101])},
        athletes: const {},
      );

      expect([for (final c in competitors) c.id], [10]);
    });

    // Un tirage anterieur au champ `entryIds` : chaque athlete devient son
    // propre engagement, et porte son id — ce qui garde lisible le classement
    // deja saisi sur cette course.
    test('sans entryIds, chaque athlete est son propre engagement', () {
      const race = ProgrammeRace(id: 7, number: 1, athleteIds: [101, 102]);

      final competitors = competitorsOf(
        race,
        entries: const {},
        athletes: {101: athlete(101), 102: athlete(102)},
      );

      expect([for (final c in competitors) c.id], [101, 102]);
      expect(competitors.first.athletes.single.id, 101);
    });
  });

  group('isCompetitorOrder', () {
    test('un ordre vide est valide', () {
      expect(isCompetitorOrder(const [], [entry(10, [101])]), isTrue);
    });

    test('un ordre d engagements est reconnu', () {
      expect(
        isCompetitorOrder(const [
          [10],
          [20]
        ], [entry(10, [101]), entry(20, [201])]),
        isTrue,
      );
    });

    test('un ordre d athletes de relais est rejete', () {
      expect(
        isCompetitorOrder(const [
          [101],
          [102]
        ], [entry(10, [101, 102])]),
        isFalse,
      );
    });

    test('un ordre partiellement etranger est rejete en entier', () {
      expect(
        isCompetitorOrder(const [
          [10, 101]
        ], [entry(10, [101])]),
        isFalse,
      );
    });
  });
}
```

- [ ] **Step 2: Lancer le test et vérifier qu'il échoue**

Run: `flutter test test/data/models/competitor_test.dart`
Expected: FAIL — `Target of URI doesn't exist: '.../competitor.dart'`

- [ ] **Step 3: Écrire le module**

Create `lib/app/domain/models/competitor.dart` :

```dart
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';

/// Ce qui prend une place dans une course : l'engagement.
///
/// Un engagement porte un athlète ou quatre, mais il reste l'unité du
/// classement — c'est aussi ce que FFSS attend (`submitResult` veut un
/// `engagement`). Les fonctions de `course_ranking.dart` manipulent des ids de
/// compétiteurs, c'est-à-dire des ids d'engagements.
library;

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
```

- [ ] **Step 4: Lancer le test et vérifier qu'il passe**

Run: `flutter test test/data/models/competitor_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
dart format lib/ test/
git add lib/app/domain/models/competitor.dart test/data/models/competitor_test.dart
git commit -m "feat(domain): le competiteur d une course est son engagement"
```

---

### Task 3: Renommer ce que le classement indexe

Renommage mécanique, sans changement de comportement : les champs disent « compétiteur » là où ils disaient « athlète ». **Les clés JSON ne bougent pas** (`finishOrder`, `athleteId`), donc le stockage sécurisé reste lisible. Les valeurs stockées restent des ids d'athlètes jusqu'aux tâches 7 et 8 — c'est voulu : cette tâche compile et laisse la suite verte.

**Files:**
- Modify: `lib/app/domain/models/programme_race.dart:29` (`finishOrder` → `competitorOrder`)
- Modify: `lib/app/domain/models/course_penalty.dart:17` (`athleteId` → `competitorId`)
- Modify: `lib/app/domain/models/course_ranking.dart` (noms de paramètres + `withoutAthlete` → `withoutCompetitor`)
- Modify: `lib/app/module/competitions/controllers/race_course_controller.dart`, `race_structure_controller.dart`, `heat_draw_controller.dart:532`
- Test: `test/data/models/course_ranking_test.dart`, `test/presentation/modules/competitions/controllers/{race_course,race_structure,heat_draw}_controller_test.dart`

**Interfaces:**
- Produces :
  - `ProgrammeRace.competitorOrder` (`List<List<int>>`, clé JSON `finishOrder`)
  - `CoursePenalty.competitorId` (`int`, clé JSON `athleteId`)
  - `course_ranking.dart` : `placesOf`, `nextPlace`, `withFinisher(order, competitorId, {required bool tied})`, `withoutCompetitor(order, competitorId)`, `withoutLastFinisher`, `withPlace(order, competitorId, place)`

- [ ] **Step 1: Renommer dans les deux modèles freezed**

`lib/app/domain/models/programme_race.dart` :

```dart
    // Les compétiteurs dans l'ordre où ils ont franchi la ligne, un groupe par
    // arrivée — un groupe de plusieurs étant un ex-aequo déclaré. Des
    // engagements : voir `competitor.dart`. La clé JSON reste `finishOrder`,
    // le stockage étant antérieur au renommage.
    @JsonKey(name: 'finishOrder')
    @Default(<List<int>>[])
    List<List<int>> competitorOrder,
```

`lib/app/domain/models/course_penalty.dart` :

```dart
/// Un compétiteur hors classement. [code] est le code de disqualification que
/// donne l'arbitre ; il reste vide pour un forfait.
@freezed
class CoursePenalty with _$CoursePenalty {
  const factory CoursePenalty({
    // Un engagement (voir `competitor.dart`). Clé JSON héritée.
    @JsonKey(name: 'athleteId') required int competitorId,
    @JsonKey(unknownEnumValue: CoursePenaltyKind.unknown)
    required CoursePenaltyKind kind,
    @Default('') String code,
  }) = _CoursePenalty;
```

- [ ] **Step 2: Régénérer le codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: succès ; `programme_race.freezed.dart`, `programme_race.g.dart`, `course_penalty.freezed.dart`, `course_penalty.g.dart` régénérés.

- [ ] **Step 3: Renommer dans `course_ranking.dart`**

Remplacer partout `athleteId` par `competitorId` et `withoutAthlete` par `withoutCompetitor`, et ajuster les doc comments qui parlent d'athlètes (« deux firsts leave nobody second » reste vrai ; « an athlete already placed » devient « un compétiteur déjà placé »). Aucune logique ne change.

- [ ] **Step 4: Suivre les appelants**

Run: `flutter analyze`
Expected: des erreurs dans `race_course_controller.dart`, `race_structure_controller.dart`, `heat_draw_controller.dart`. Les corriger **par renommage seulement** :
- `stored.finishOrder` → `stored.competitorOrder`, `finishOrder: [...]` → `competitorOrder: [...]` dans les `copyWith` et constructeurs (dont `heat_draw_controller.dart:532`) ;
- `penalty.athleteId` → `penalty.competitorId`, `CoursePenalty(athleteId: ...)` → `CoursePenalty(competitorId: ...)` ;
- `withoutAthlete(...)` → `withoutCompetitor(...)`.

Le champ `RxList<List<int>> finishOrder` de `RaceCourseController` devient `competitorOrder` ; `race_course_view.dart` ne le lit pas directement, seul le contrôleur s'en sert.

- [ ] **Step 5: Suivre les tests**

Même renommage dans les quatre fichiers de test listés plus haut. Run: `flutter test`
Expected: PASS — aucun test n'a changé de sens.

- [ ] **Step 6: Vérifier que le stockage n'a pas bougé**

Run: `flutter test test/data/services/` puis `grep -rn "finishOrder\|athleteId" lib/app/domain/models/*.g.dart`
Expected: les clés `finishOrder` et `athleteId` apparaissent bien dans le JSON généré.

- [ ] **Step 7: Commit**

```bash
dart format lib/ test/
git add -A
git commit -m "refactor(results): le classement indexe des competiteurs"
```

---

### Task 4: `EntryGroupTile` et le formatage d'un engagement

Le composant partagé et ses deux fonctions de libellé. Il n'a pas encore de consommateur à la fin de cette tâche — les quatre écrans arrivent ensuite. Seules les fonctions de formatage sont testées : pas de test de widget dans ce dépôt.

**Files:**
- Create: `lib/app/presentation/modules/competitions/entry_formatting.dart`
- Create: `lib/app/presentation/shared/entry_group_tile.dart`
- Modify: `lib/app/core/translations/fr_fr.dart`, `lib/app/core/translations/en_us.dart`
- Test: `test/presentation/modules/competitions/entry_formatting_test.dart`

**Interfaces:**
- Consumes: `Entry`, `Athlete`, `entryClubId` (dans `heat_draw.dart`), `ClubAvatar`, `AthleteFormatting.displayName`
- Produces:
  - `bool isTeamEntry(Entry entry)` — plus d'un athlète
  - `String entryTitle(Entry entry)` — club/organisme en relais, `displayName` en individuel. **Sans `.tr`** : un contrôleur trie dessus (tâche 5)
  - `String entryClubLabel(Entry entry)` — le club de l'engagement, chaîne vide sans. **Sans `.tr`**
  - `String entrySubtitle(Entry entry)` — club en individuel, « n athlètes » en relais. Traduit, donc réservé aux vues
  - `Club? entryClub(Entry entry)` — le `Club` résolu porté par l'engagement, pour `ClubAvatar`
  - Le widget `EntryGroupTile` (signature au Step 4)

- [ ] **Step 1: Écrire les tests de formatage qui échouent**

Create `test/presentation/modules/competitions/entry_formatting_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/presentation/modules/competitions/entry_formatting.dart';

void main() {
  Athlete athlete(int id, {String clubLabel = ''}) => Athlete(
        id: id,
        licenseeNumber: 'L$id',
        firstName: 'Jean',
        lastName: 'Dupont',
        gender: Gender.male,
        year: 2000,
        nationalityCode: '',
        nationality: '',
        isValid: true,
        clubLabel: clubLabel,
      );

  Entry entry(List<Athlete> athletes, {Club? organisme}) => Entry(
        id: 1,
        category: const Category(id: 1, name: 'Senior'),
        status: 1,
        statusLabel: 'Engagé',
        organisme: organisme,
        athletes: athletes,
      );

  test('un engagement a un athlete n est pas une equipe', () {
    expect(isTeamEntry(entry([athlete(1)])), isFalse);
    expect(isTeamEntry(entry([athlete(1), athlete(2)])), isTrue);
  });

  test('en individuel le titre est le nom de l athlete', () {
    expect(entryTitle(entry([athlete(1, clubLabel: 'SNS Nice')])),
        'DUPONT Jean');
  });

  // La regle de `entryClubId` : l'organisme de l'engagement l'emporte, le club
  // du premier athlete prend le relais.
  test('en relais le titre est l organisme, sinon le club du premier', () {
    expect(
      entryTitle(entry(
        [athlete(1, clubLabel: 'SNS Nice'), athlete(2)],
        organisme: const Club(id: 3, name: 'Nice Sauvetage'),
      )),
      'Nice Sauvetage',
    );
    expect(
      entryTitle(entry([athlete(1, clubLabel: 'SNS Nice'), athlete(2)])),
      'SNS Nice',
    );
  });

  test('un relais sans club ni organisme se nomme par ses athletes', () {
    expect(entryTitle(entry([athlete(1), athlete(2)])),
        'DUPONT Jean / DUPONT Jean');
  });

  test('le sous-titre porte le club en individuel', () {
    expect(entrySubtitle(entry([athlete(1, clubLabel: 'SNS Nice')])),
        'SNS Nice');
  });

  // `entrySubtitle` traduit le mot « athletes » ; sans GetX charge dans un
  // test, `.tr` rend la cle. Seul l'effectif est donc affirme ici.
  test('le sous-titre porte l effectif en relais', () {
    expect(entrySubtitle(entry([athlete(1), athlete(2)])), startsWith('2 '));
  });

  test('le club de l equipe se lit sans traduction', () {
    expect(entryClubLabel(entry([athlete(1, clubLabel: 'SNS Nice'), athlete(2)])),
        'SNS Nice');
    expect(entryClubLabel(entry([athlete(1)])), '');
  });
}
```

- [ ] **Step 2: Lancer le test et vérifier qu'il échoue**

Run: `flutter test test/presentation/modules/competitions/entry_formatting_test.dart`
Expected: FAIL — `Target of URI doesn't exist`

- [ ] **Step 3: Écrire le formatage**

Create `lib/app/presentation/modules/competitions/entry_formatting.dart` :

```dart
import 'package:get/get.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/presentation/modules/competitions/athlete_formatting.dart';

/// Un engagement qui porte plus d'un athlète : un relais.
bool isTeamEntry(Entry entry) => entry.athletes.length > 1;

/// Ce qu'une ligne repliée annonce.
///
/// Une équipe court sous un club, pas sous un nom : l'organisme de
/// l'engagement l'emporte, le club du premier athlète prend le relais — la
/// règle qu'applique déjà `entryClubId` pour répartir les clubs dans un
/// tirage. Sans ni l'un ni l'autre, les noms restent le seul repère.
String entryTitle(Entry entry) {
  if (!isTeamEntry(entry)) {
    return entry.athletes.isEmpty ? '' : entry.athletes.first.displayName;
  }
  final label = entryClubLabel(entry);
  if (label.isNotEmpty) return label;
  return [for (final athlete in entry.athletes) athlete.displayName].join(' / ');
}

/// La seconde ligne : le club en individuel, l'effectif en relais.
///
/// Traduite, donc à n'appeler que depuis une vue. Un contrôleur qui trie sur
/// le club passe par [entryClubLabel], qui ne traduit rien.
String entrySubtitle(Entry entry) => isTeamEntry(entry)
    ? '${entry.athletes.length} ${'athletes_lower'.tr}'
    : entryClubLabel(entry);

/// Le club résolu que porte l'engagement, pour [ClubAvatar].
Club? entryClub(Entry entry) {
  final organisme = entry.organisme;
  if (organisme != null && organisme.name.isNotEmpty) return organisme;
  for (final athlete in entry.athletes) {
    final club = athlete.club;
    if (club != null && club.name.isNotEmpty) return club;
  }
  return null;
}

/// Le club sous lequel l'engagement court, chaîne vide quand il n'en a aucun.
String entryClubLabel(Entry entry) {
  final club = entryClub(entry);
  if (club != null) return club.name;
  for (final athlete in entry.athletes) {
    if (athlete.clubLabel.isNotEmpty) return athlete.clubLabel;
  }
  return '';
}
```

- [ ] **Step 4: Lancer le test et vérifier qu'il passe**

Run: `flutter test test/presentation/modules/competitions/entry_formatting_test.dart`
Expected: PASS

- [ ] **Step 5: Écrire le composant**

Create `lib/app/presentation/shared/entry_group_tile.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/theme/app_colors.dart';
import 'package:live_ffss/app/core/theme/app_radius.dart';
import 'package:live_ffss/app/core/theme/app_spacing.dart';
import 'package:live_ffss/app/core/theme/app_typography.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/entry.dart';
import 'package:live_ffss/app/presentation/modules/competitions/athlete_formatting.dart';
import 'package:live_ffss/app/presentation/modules/competitions/entry_formatting.dart';
import 'package:live_ffss/app/presentation/shared/club_avatar.dart';

/// Un engagement, sur une ligne : ce que tous les écrans de compétiteurs
/// montrent.
///
/// Un relais est une équipe derrière un club, dépliable sur ses athlètes ; un
/// engagement individuel rend la même ligne sans chevron ni athlètes. Les
/// écrans n'ont ni le même contenu à gauche ni le même à droite — d'où les
/// slots plutôt que quatre variantes.
class EntryGroupTile extends StatelessWidget {
  const EntryGroupTile({
    super.key,
    required this.entry,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.expanded = false,
    this.onToggle,
    this.onTap,
    this.onLongPress,
    this.athleteTrailing,
    this.onSubstitute,
    this.highlight = false,
    this.avatarSize = 32,
  });

  final Entry entry;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  final bool expanded;

  /// Null pour un engagement individuel : il n'y a rien à déplier.
  final VoidCallback? onToggle;

  final VoidCallback? onTap;
  final ValueChanged<Offset>? onLongPress;

  /// Ce que l'écran accroche à droite de chaque athlète déplié — un statut de
  /// présence, rien du tout.
  final Widget? Function(Athlete athlete)? athleteTrailing;

  /// Le bouton « remplacer un membre ». Absent, le bouton ne s'affiche pas.
  final void Function(Entry entry, Athlete athlete)? onSubstitute;

  final bool highlight;
  final double avatarSize;

  bool get _isTeam => isTeamEntry(entry);

  @override
  Widget build(BuildContext context) {
    final head = Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.sm),
          ],
          ClubAvatar(
            club: entryClub(entry),
            size: avatarSize,
            shape: ClubAvatarShape.circle,
            fallbackLabel: title,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.body
                      .copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle?.isNotEmpty == true)
                  Text(
                    subtitle!,
                    style: AppTypography.caption.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (_isTeam && onToggle != null)
            IconButton(
              onPressed: onToggle,
              icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
              color: AppColors.textMuted,
              visualDensity: VisualDensity.compact,
              tooltip: 'athletes'.tr,
            ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: highlight ? AppColors.primarySurface : null,
        borderRadius: AppRadius.mdRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onLongPressStart: onLongPress == null
                ? null
                : (d) => onLongPress!(d.globalPosition),
            child: Material(
              type: MaterialType.transparency,
              borderRadius: AppRadius.mdRadius,
              child: InkWell(
                onTap: onTap,
                borderRadius: AppRadius.mdRadius,
                child: head,
              ),
            ),
          ),
          if (_isTeam && expanded)
            for (final athlete in entry.athletes)
              _AthleteLine(
                entry: entry,
                athlete: athlete,
                trailing: athleteTrailing?.call(athlete),
                onSubstitute: onSubstitute,
              ),
        ],
      ),
    );
  }
}

class _AthleteLine extends StatelessWidget {
  const _AthleteLine({
    required this.entry,
    required this.athlete,
    required this.trailing,
    required this.onSubstitute,
  });

  final Entry entry;
  final Athlete athlete;
  final Widget? trailing;
  final void Function(Entry entry, Athlete athlete)? onSubstitute;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 2, AppSpacing.sm, AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              athlete.displayName,
              style: AppTypography.caption.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing!,
          if (onSubstitute != null)
            IconButton(
              onPressed: () => onSubstitute!(entry, athlete),
              icon: const Icon(Icons.swap_horizontal_circle_outlined),
              iconSize: 20,
              color: AppColors.textMuted,
              visualDensity: VisualDensity.compact,
              tooltip: 'relay_substitute'.tr,
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: Ajouter les trois clés dans les deux langues**

`lib/app/core/translations/fr_fr.dart` :

```dart
  'relay_substitute': 'Remplacer',
  'relay_substitute_coming_soon': 'Le remplacement arrive bientôt',
  'teams_complete': 'équipes complètes',
```

`lib/app/core/translations/en_us.dart` :

```dart
  'relay_substitute': 'Substitute',
  'relay_substitute_coming_soon': 'Substitution is coming soon',
  'teams_complete': 'complete teams',
```

Vérifier que `athletes` existe déjà dans les deux fichiers (`race_structure_view` s'en sert comme tooltip) : `grep -n "'athletes'" lib/app/core/translations/*.dart`.

- [ ] **Step 7: Analyser et commiter**

Run: `flutter analyze && flutter test`
Expected: PASS, aucun avertissement sur le nouveau fichier.

```bash
dart format lib/ test/
git add lib/app/presentation/ lib/app/core/translations/ test/presentation/modules/competitions/entry_formatting_test.dart
git commit -m "feat(ui): un composant unique pour afficher un engagement"
```

---

### Task 5: Le marshalling par engagement

Les lignes deviennent des engagements. Le pointage reste par athlète — c'est ce qu'un bracelet pointe — mais la ligne d'équipe agrège et pointe d'un coup.

**Files:**
- Modify: `lib/app/module/competitions/controllers/race_detail_controller.dart`
- Modify: `lib/app/module/competitions/views/race_detail_entries_view.dart`
- Test: `test/presentation/modules/competitions/controllers/race_detail_controller_test.dart`

**Interfaces:**
- Consumes: `EntryGroupTile`, `entryTitle`, `entrySubtitle`, `isTeamEntry` (tâche 4)
- Produces sur `RaceDetailController` :
  - `List<Entry> get sortedEntries`
  - `AttendanceStatus teamAttendance(Entry entry)`
  - `void cycleTeamAttendance(Entry entry)`
  - `({int complete, int total}) get teamCounts`
  - `bool isEntryExpanded(Entry entry)` / `void toggleEntry(Entry entry)`
  - `enum CompetitorSortMode { name, club, attendance }` (remplace `AthleteSortMode`), `setSortMode(CompetitorSortMode)`
  - `Rxn<UiMessage> message` (nouveau : porte `relay_substitute_coming_soon`)

- [ ] **Step 1: Écrire les tests qui échouent**

Dans `test/presentation/modules/competitions/controllers/race_detail_controller_test.dart`, ajouter un groupe. Les helpers existants du fichier (`athlete(...)`, la construction du contrôleur) servent tels quels ; construire les engagements avec plusieurs athlètes.

```dart
  group('RaceDetailController relais', () {
    test('une equipe est en attente tant qu elle n est pas complete', () async {
      final controller = await loadWith([
        entry(1, [athlete(11), athlete(12)]),
      ]);

      expect(controller.teamAttendance(controller.entries.single),
          AttendanceStatus.waiting);

      controller.setAttendance(athlete(11), AttendanceStatus.present);
      expect(controller.teamAttendance(controller.entries.single),
          AttendanceStatus.waiting);

      controller.setAttendance(athlete(12), AttendanceStatus.present);
      expect(controller.teamAttendance(controller.entries.single),
          AttendanceStatus.present);
    });

    // Le statut agrege ne vaut jamais « absent » : le cycle se lit donc sur les
    // statuts reels de l'equipe, pas sur ce que la ligne affiche.
    test('le cycle groupe passe par absent puis revient en attente', () async {
      final controller = await loadWith([
        entry(1, [athlete(11), athlete(12)]),
      ]);
      final team = controller.entries.single;

      controller.cycleTeamAttendance(team);
      expect(controller.attendanceOf(athlete(11)), AttendanceStatus.present);
      expect(controller.attendanceOf(athlete(12)), AttendanceStatus.present);

      controller.cycleTeamAttendance(team);
      expect(controller.attendanceOf(athlete(11)), AttendanceStatus.absent);

      controller.cycleTeamAttendance(team);
      expect(controller.attendanceOf(athlete(11)), AttendanceStatus.waiting);
    });

    test('la jauge compte des tetes, le compteur d equipes des equipes',
        () async {
      final controller = await loadWith([
        entry(1, [athlete(11), athlete(12)]),
        entry(2, [athlete(21)]),
      ]);

      controller.setAttendance(athlete(11), AttendanceStatus.present);
      controller.setAttendance(athlete(21), AttendanceStatus.present);

      expect(controller.attendanceCounts.present, 2);
      expect(controller.attendanceCounts.total, 3);
      expect(controller.teamCounts, (complete: 1, total: 2));
    });

    test('le tri par nom suit le libelle affiche', () async {
      final controller = await loadWith([
        entry(1, [athlete(11, lastName: 'Zola')]),
        entry(2, [
          athlete(21, lastName: 'Adam', clubLabel: 'Antibes'),
          athlete(22, lastName: 'Bic', clubLabel: 'Antibes'),
        ]),
      ]);

      controller.setSortMode(CompetitorSortMode.name);

      // « Antibes » (le club de l'equipe) passe avant « ZOLA ».
      expect([for (final e in controller.sortedEntries) e.id], [2, 1]);
    });

    test('deplier et replier une equipe', () async {
      final controller = await loadWith([
        entry(1, [athlete(11), athlete(12)]),
      ]);
      final team = controller.entries.single;

      expect(controller.isEntryExpanded(team), isFalse);
      controller.toggleEntry(team);
      expect(controller.isEntryExpanded(team), isTrue);
      controller.toggleEntry(team);
      expect(controller.isEntryExpanded(team), isFalse);
    });
  });
```

Ajouter au fichier les helpers manquants s'ils n'existent pas : `Entry entry(int id, List<Athlete> athletes)` et un `athlete(int id, {String lastName = '...', String clubLabel = ''})`, et un `loadWith(List<Entry> entries)` qui stubbe `raceRepo.getEntries`.

- [ ] **Step 2: Lancer les tests et vérifier qu'ils échouent**

Run: `flutter test test/presentation/modules/competitions/controllers/race_detail_controller_test.dart`
Expected: FAIL — `teamAttendance` non défini.

- [ ] **Step 3: Implémenter dans le contrôleur**

Dans `race_detail_controller.dart`, remplacer `sortedAthletes` (et l'enum) par :

```dart
  /// Les engagements, ordonnés selon [sortMode]. Lit [entries], [sortMode] et
  /// — quand on trie par présence — [attendance], donc se recalcule dans un
  /// `Obx`.
  List<Entry> get sortedEntries {
    final all = entries.toList();
    all.sort(switch (sortMode.value) {
      CompetitorSortMode.name => _byTitle,
      CompetitorSortMode.club => (a, b) {
          final byClub = _clubOf(a).compareTo(_clubOf(b));
          return byClub != 0 ? byClub : _byTitle(a, b);
        },
      CompetitorSortMode.attendance => (a, b) {
          final byStatus = teamAttendance(a).index.compareTo(
                teamAttendance(b).index,
              );
          return byStatus != 0 ? byStatus : _byTitle(a, b);
        },
    });
    return all;
  }

  int _byTitle(Entry a, Entry b) =>
      entryTitle(a).toLowerCase().compareTo(entryTitle(b).toLowerCase());

  String _clubOf(Entry entry) => entryClubLabel(entry).toLowerCase();

  /// Ce que la ligne repliée annonce : présent si toute l'équipe l'est, en
  /// attente sinon. Jamais « absent » — un membre manquant n'absente pas
  /// l'équipe, il l'empêche seulement d'être prête, ce que le décompte
  /// d'athlètes de la ligne dit déjà.
  AttendanceStatus teamAttendance(Entry entry) {
    if (entry.athletes.isEmpty) return AttendanceStatus.waiting;
    for (final athlete in entry.athletes) {
      if (attendanceOf(athlete) != AttendanceStatus.present) {
        return AttendanceStatus.waiting;
      }
    }
    return AttendanceStatus.present;
  }

  /// Pointe toute l'équipe d'un coup : tous présents → tous absents → tous en
  /// attente. Le cycle se lit sur les statuts réels et non sur [teamAttendance],
  /// qui ne vaut jamais « absent » et bloquerait le tour.
  void cycleTeamAttendance(Entry entry) {
    final statuses = {for (final a in entry.athletes) attendanceOf(a)};
    final next = switch (statuses) {
      _ when statuses.length == 1 &&
          statuses.first == AttendanceStatus.present =>
        AttendanceStatus.absent,
      _ when statuses.length == 1 && statuses.first == AttendanceStatus.absent =>
        AttendanceStatus.waiting,
      _ => AttendanceStatus.present,
    };
    for (final athlete in entry.athletes) {
      attendance[athlete.id] = next;
    }
    _persistAttendance();
  }

  /// Équipes dont tout le monde est pointé présent, sur le total — ce que le
  /// tirage exigera pour les faire partir.
  ({int complete, int total}) get teamCounts {
    var complete = 0;
    for (final entry in entries) {
      if (teamAttendance(entry) == AttendanceStatus.present) complete++;
    }
    return (complete: complete, total: entries.length);
  }

  final RxSet<int> expandedEntries = <int>{}.obs;

  bool isEntryExpanded(Entry entry) => expandedEntries.contains(entry.id);

  void toggleEntry(Entry entry) {
    if (!expandedEntries.remove(entry.id)) expandedEntries.add(entry.id);
  }

  final Rxn<UiMessage> message = Rxn<UiMessage>();

  /// Le remplacement d'un membre n'est pas encore câblé côté FFSS ; l'écran
  /// montre le bouton pour que le geste existe, et dit que la suite arrive.
  void requestSubstitution(Entry entry, Athlete athlete) {
    message.trigger(const UiMessageError('relay_substitute_coming_soon'));
  }
```

Renommer `AthleteSortMode` en `CompetitorSortMode` (valeurs inchangées) et déclarer `final Rx<CompetitorSortMode> sortMode = CompetitorSortMode.name.obs;`.

Le contrôleur importe `entryTitle` et `entryClubLabel` de `entry_formatting.dart` : trier « sur le libellé affiché » est la décision de la spec, et ces deux fonctions sont pures et ne traduisent rien. `entrySubtitle`, qui traduit, ne doit **pas** remonter jusqu'ici.

- [ ] **Step 4: Lancer les tests et vérifier qu'ils passent**

Run: `flutter test test/presentation/modules/competitions/controllers/race_detail_controller_test.dart`
Expected: PASS

- [ ] **Step 5: Brancher la vue**

Dans `race_detail_entries_view.dart` :
- `final athletes = controller.sortedAthletes;` devient `final competitors = controller.sortedEntries;` (et l'`EmptyState` / le `ListView` suivent) ;
- `itemBuilder` rend un `EntryGroupTile` :

```dart
                      itemBuilder: (_, i) {
                        final entry = competitors[i];
                        return EntryGroupTile(
                          key: ValueKey(entry.id),
                          entry: entry,
                          title: entryTitle(entry),
                          subtitle: _subtitleOf(entry),
                          expanded: controller.isEntryExpanded(entry),
                          onToggle: () => controller.toggleEntry(entry),
                          trailing: _TeamStatusChip(entry: entry),
                          athleteTrailing: (athlete) =>
                              _AthleteStatusChip(athlete: athlete),
                          onSubstitute: controller.requestSubstitution,
                          avatarSize: 40,
                        );
                      },
```

- `_StatusChip` se dédouble : `_AthleteStatusChip` garde le corps actuel (tap → `cycleAttendance`, appui long → menu `setAttendance`), `_TeamStatusChip` fait la même chose avec `teamAttendance` / `cycleTeamAttendance` et n'offre pas le menu, un statut d'équipe ne se choisissant pas à la main ;
- `_subtitleOf(entry)` compose l'existant :

```dart
  String _subtitleOf(Entry entry) {
    if (!isTeamEntry(entry)) {
      final athlete = entry.athletes.first;
      return [
        if (athlete.year > 0) '${athlete.year}',
        if (athlete.clubLabel.isNotEmpty) athlete.clubLabel,
      ].join(' • ');
    }
    final present = entry.athletes
        .where((a) =>
            controller.attendanceOf(a) == AttendanceStatus.present)
        .length;
    return '${entrySubtitle(entry)} · $present/${entry.athletes.length}';
  }
```

- `_AttendanceSummary` gagne, sous la légende, `'${controller.teamCounts.complete}/${controller.teamCounts.total} ${'teams_complete'.tr}'` — **seulement si au moins un engagement est une équipe** (`controller.entries.any(isTeamEntry)`), sans quoi la mention répéterait la jauge ;
- la vue devient `StatefulWidget` et branche `_worker = showUiMessages(controller.message);` dans `initState`, `_worker.dispose()` dans `dispose` — c'est le seul chemin autorisé pour afficher un message.

- [ ] **Step 6: Vérifier**

Run: `flutter analyze && flutter test`
Expected: PASS. Vérifier qu'aucune référence à `sortedAthletes` / `AthleteSortMode` ne subsiste : `grep -rn "sortedAthletes\|AthleteSortMode" lib/ test/`

- [ ] **Step 7: Commit**

```bash
dart format lib/ test/
git add -A
git commit -m "feat(marshalling): pointer un relais comme une equipe"
```

---

### Task 6: Le tirage des séries

`_LaneRow` devient un `EntryGroupTile`. Le contrôleur tire déjà des engagements : il ne gagne que le dépliage.

**Files:**
- Modify: `lib/app/module/competitions/controllers/heat_draw_controller.dart`
- Modify: `lib/app/module/competitions/views/heat_draw_view.dart:601-680` (`_LaneRow`)
- Test: `test/presentation/modules/competitions/controllers/heat_draw_controller_test.dart`

**Interfaces:**
- Consumes: `EntryGroupTile`, `entryTitle`, `entrySubtitle`
- Produces sur `HeatDrawController` : `bool isEntryExpanded(Entry)`, `void toggleEntry(Entry)`, `void requestSubstitution(Entry, Athlete)`

- [ ] **Step 1: Écrire le test qui échoue**

```dart
    test('deplier une equipe, puis la replier', () async {
      final controller = await loadedController();
      final team = controller.presentEntries.first;

      expect(controller.isEntryExpanded(team), isFalse);
      controller.toggleEntry(team);
      expect(controller.isEntryExpanded(team), isTrue);
      controller.toggleEntry(team);
      expect(controller.isEntryExpanded(team), isFalse);
    });

    test('le remplacement annonce qu il arrive', () async {
      final controller = await loadedController();
      final team = controller.presentEntries.first;

      controller.requestSubstitution(team, team.athletes.first);

      expect(controller.message.value,
          const UiMessageError('relay_substitute_coming_soon'));
    });
```

(`loadedController()` : réutiliser le helper de chargement déjà présent dans ce fichier de test.)

- [ ] **Step 2: Lancer le test et vérifier qu'il échoue**

Run: `flutter test test/presentation/modules/competitions/controllers/heat_draw_controller_test.dart`
Expected: FAIL — `isEntryExpanded` non défini.

- [ ] **Step 3: Implémenter**

Dans `heat_draw_controller.dart`, mêmes quatre membres qu'en tâche 5 (`expandedEntries`, `isEntryExpanded`, `toggleEntry`, `requestSubstitution`). `message` existe déjà sur ce contrôleur.

- [ ] **Step 4: Lancer le test et vérifier qu'il passe**

Run: `flutter test test/presentation/modules/competitions/controllers/heat_draw_controller_test.dart`
Expected: PASS

- [ ] **Step 5: Remplacer `_LaneRow` par le composant**

Dans `heat_draw_view.dart`, `_HeatCard` rend :

```dart
          for (var lane = 0; lane < entries.length; lane++)
            Builder(builder: (_) {
              final entry = entries[lane];
              final ctrl = Get.find<HeatDrawController>();
              return Obx(() => EntryGroupTile(
                    key: ValueKey(entry.id),
                    entry: entry,
                    title: entryTitle(entry),
                    subtitle: entrySubtitle(entry),
                    leading: _LaneNumber(lane: lane + 1),
                    trailing: const Icon(Icons.swap_horiz,
                        size: 18, color: AppColors.textMuted),
                    expanded: ctrl.isEntryExpanded(entry),
                    onToggle: () => ctrl.toggleEntry(entry),
                    onTap: () => onTapEntry(entry),
                    onSubstitute: ctrl.requestSubstitution,
                    avatarSize: 28,
                  ));
            }),
```

`_LaneNumber` reprend tel quel le `Container` 28×28 du `_LaneRow` actuel ([heat_draw_view.dart:633-647](../../../lib/app/module/competitions/views/heat_draw_view.dart#L633-L647)). Supprimer `_LaneRow` — y compris ses getters `_lead`, `_label`, `_clubName`, que `entry_formatting.dart` remplace.

- [ ] **Step 6: Vérifier et commiter**

Run: `flutter analyze && flutter test`
Expected: PASS

```bash
dart format lib/ test/
git add -A
git commit -m "feat(tirage): une serie montre ses engagements, depliables"
```

---

### Task 7: L'onglet Séries lit par engagement

Le lecteur bascule avant l'écrivain : à la fin de cette tâche, l'onglet Séries lit `competitorOrder` comme une liste d'engagements. Les classements FFSS (le cas normal d'une course validée) continuent de s'afficher ; un classement local hérité de relais disparaît, ce qui est la décision de la spec.

**Files:**
- Modify: `lib/app/module/competitions/controllers/race_structure_controller.dart` (`athletesOf`, `placeIn*`, `penaltyIn*`, `_importResults`, index des engagements)
- Modify: `lib/app/module/competitions/views/race_structure_view.dart:427-600` (`_CourseTile`, `_CompetitorRow`)
- Test: `test/presentation/modules/competitions/controllers/race_structure_controller_test.dart`

**Interfaces:**
- Consumes: `competitorsOf` (tâche 2), `HeatResult.status` (tâche 1), `EntryGroupTile` (tâche 4)
- Produces sur `RaceStructureController` :
  - `List<Entry> entriesOf(ProgrammeRace race)`
  - `int? placeIn(ProgrammeRace race, Entry entry)` / `int? placeInRace(ProgrammeRace race, int competitorId)`
  - `CoursePenalty? penaltyIn(ProgrammeRace race, Entry entry)` / `penaltyInRace(ProgrammeRace, int competitorId)`
  - `bool matchesEntry(Entry entry)` — vrai si **un** athlète correspond au filtre
  - `bool isEntryExpanded(Entry)` / `void toggleEntry(Entry)`
  - `int heatIdOf(ProgrammeRace race)` — l'id de série FFSS de cette course, 0 sans, consommé par la tâche 9

- [ ] **Step 1: Écrire les tests qui échouent**

```dart
    test('une course rend ses engagements dans l ordre des couloirs', () async {
      final controller = await loadWithDraw(
        entryIds: [20, 10],
        athleteIds: [201, 202, 101],
      );
      final race = controller.racesOf(RoundType.serie).single;

      expect([for (final e in controller.entriesOf(race)) e.id], [20, 10]);
    });

    test('la place se lit sur l engagement', () async {
      final controller = await loadWithDraw(
        entryIds: [10, 20],
        athleteIds: [101, 201],
        competitorOrder: const [
          [20],
          [10]
        ],
      );
      final race = controller.racesOf(RoundType.serie).single;

      expect(controller.placeInRace(race, 20), 1);
      expect(controller.placeInRace(race, 10), 2);
    });

    // Le serveur porte desormais un statut : un forfait relu n'est plus
    // indiscernable d'un « pas encore classe ».
    test('un forfait FFSS revient comme forfait', () async {
      final controller = await loadWithResults([
        (
          entryId: 10,
          rank: null,
          isDisqualified: false,
          complement: null,
          status: 2
        ),
      ]);
      final race = controller.racesOf(RoundType.serie).single;

      expect(controller.penaltyInRace(race, 10)?.kind,
          CoursePenaltyKind.forfeit);
    });

    test('le filtre trouve une equipe par un seul de ses athletes', () async {
      final controller = await loadWithDraw(
        entryIds: [10],
        athleteIds: [101, 102],
      );
      controller.setFilter('B102');

      expect(controller.matchesEntry(controller.entriesOf(
        controller.racesOf(RoundType.serie).single,
      ).single), isTrue);
    });
```

Les helpers `loadWithDraw` / `loadWithResults` / `racesOf` existent déjà ou s'adaptent de ceux du fichier ; `loadWithDraw` doit stubber `raceRepo.getEntries` avec des engagements de plusieurs athlètes.

- [ ] **Step 2: Lancer les tests et vérifier qu'ils échouent**

Run: `flutter test test/presentation/modules/competitions/controllers/race_structure_controller_test.dart`
Expected: FAIL — `entriesOf` non défini.

- [ ] **Step 3: Implémenter dans le contrôleur**

- indexer les engagements à côté des athlètes :

```dart
  /// Id d'engagement -> engagement, bâti sur les engagés de l'épreuve. C'est
  /// ce qui rend à une course tirée ses compétiteurs.
  Map<int, Entry> _entriesById = const {};
```

rempli dans `load()`, au même endroit que `_athletesById` (~ligne 168) : `_entriesById = {for (final e in entries) e.id: e};`.

- remplacer `athletesOf` par :

```dart
  /// Les engagements d'une course tirée, dans l'ordre des couloirs.
  List<Entry> entriesOf(ProgrammeRace race) => competitorsOf(
        race,
        entries: _entriesById,
        athletes: _athletesById,
      );
```

- `placeInRace` / `penaltyInRace` prennent un `competitorId` (le corps ne change pas, seul le nom du paramètre et la clé de `_serverResults`) ;
- `penaltyInRace` reconstruit aussi le forfait :

```dart
      final kind = switch (result.status) {
        1 => CoursePenaltyKind.disqualified,
        2 => CoursePenaltyKind.forfeit,
        // Statut muet : la disqualification reste lisible sur son booléen, et
        // tout le reste est un classé ordinaire.
        _ => result.isDisqualified ? CoursePenaltyKind.disqualified : null,
      };
      if (kind == null) return null;
      return CoursePenalty(
        competitorId: competitorId,
        kind: kind,
        code: result.complement ?? '',
      );
```

- `_importResults` cesse d'éventer le résultat sur les athlètes ([race_structure_controller.dart:466-476](../../../lib/app/module/competitions/controllers/race_structure_controller.dart#L466-L476)) :

```dart
          final results = resultsByHeat[heatId] ?? const <HeatResult>[];
          if (results.isEmpty) continue;
          _serverResults[stored.id] = {for (final r in results) r.entryId: r};
```

(le `final seats = await _seatsOf(course);` et son garde `if (seats.isEmpty) continue;` disparaissent de cette boucle — `_importCompositions` continue d'utiliser `_seatsOf`.)

- `matchesEntry`, `isEntryExpanded`/`toggleEntry` (mêmes corps qu'en tâche 5), et :

```dart
  /// L'id de la série FFSS que porte cette course, 0 quand elle n'en a pas.
  /// Passé à l'écran de saisie pour qu'il relise le classement déjà publié
  /// sans refaire l'arbre des réunions.
  int heatIdOf(ProgrammeRace race) => _courseHeatIds[race.id] ?? 0;
```

alimenté dans `_importResults` (`_courseHeatIds[stored.id] = heatId;`), champ `final Map<int, int> _courseHeatIds = {};` vidé à chaque `load()` comme `_seatsByCourse`.

- le filtre de course ([race_structure_controller.dart:233](../../../lib/app/module/competitions/controllers/race_structure_controller.dart#L233)) passe par `entriesOf(race).any(matchesEntry)`.

- [ ] **Step 4: Lancer les tests et vérifier qu'ils passent**

Run: `flutter test test/presentation/modules/competitions/controllers/race_structure_controller_test.dart`
Expected: PASS

- [ ] **Step 5: Brancher la vue**

Dans `race_structure_view.dart`, `_CourseTile` : `final athletes = controller.athletesOf(race);` devient `final competitors = controller.entriesOf(race);`, et les lignes dépliées rendent :

```dart
            if (expanded)
              for (final entry in competitors)
                Obx(() => EntryGroupTile(
                      key: ValueKey('${race.id}-${entry.id}'),
                      entry: entry,
                      title: entryTitle(entry),
                      subtitle: entrySubtitle(entry),
                      leading: _PlaceBadge(
                        place: controller.placeIn(race, entry),
                        penalty: controller.penaltyIn(race, entry),
                      ),
                      highlight: controller.filter.value.isNotEmpty &&
                          controller.matchesEntry(entry),
                      expanded: controller.isEntryExpanded(entry) ||
                          (controller.filter.value.isNotEmpty &&
                              controller.matchesEntry(entry)),
                      onToggle: () => controller.toggleEntry(entry),
                      avatarSize: 28,
                    )),
```

L'onglet Séries ne passe **pas** de `onSubstitute` : c'est un récapitulatif de ce qui a été tiré et couru, et remplacer un relayeur s'y ferait hors de tout contexte de marshalling. Le bouton vit dans les trois autres écrans.

`_PlaceBadge` reprend le badge gauche de l'actuel `_CompetitorRow` (`courseBadgeLabel` / `courseBadgeColor`) ; supprimer `_CompetitorRow` de ce fichier. Le compteur d'en-tête reste `race.athleteIds.length` — il compte des têtes.

- [ ] **Step 6: Vérifier et commiter**

Run: `flutter analyze && flutter test`
Expected: PASS ; `grep -rn "athletesOf" lib/` ne renvoie plus rien.

```bash
dart format lib/ test/
git add -A
git commit -m "feat(series): l onglet lit les places par engagement"
```

---

### Task 8: La saisie des places par engagement

L'écrivain bascule. Une ligne = une équipe, un bracelet quelconque de l'équipe la classe, et les pénalités portent sur l'engagement.

**Files:**
- Modify: `lib/app/module/competitions/controllers/race_course_controller.dart`
- Modify: `lib/app/module/competitions/views/race_course_view.dart`
- Test: `test/presentation/modules/competitions/controllers/race_course_controller_test.dart`

**Interfaces:**
- Consumes: `competitorsOf`, `isCompetitorOrder` (tâche 2), `EntryGroupTile` (tâche 4)
- Produces sur `RaceCourseController` :
  - `RxList<Entry> competitors`, `List<Entry> get orderedCompetitors`
  - `int? placeOf(Entry)`, `CoursePenalty? penaltyOf(Entry)`
  - `void assign(Entry)`, `void remove(Entry)`, `void setPlace(Entry, int)`
  - `void setPenalty(Entry, CoursePenaltyKind, {String code})`, `void clearPenalty(Entry)`
  - `bool get isComplete`, `bool isEntryExpanded(Entry)`, `void toggleEntry(Entry)`, `void requestSubstitution(Entry, Athlete)`

- [ ] **Step 1: Adapter les fixtures du test**

`loadWith(List<int> athleteIds)` met aujourd'hui **tous** les athlètes dans un seul `Entry` — ce qui en fait désormais un relais de quatre et fausserait tout le fichier. Le remplacer par :

```dart
  /// Un engagement par athlète : l'épreuve individuelle ordinaire.
  Future<RaceCourseController> loadWith(List<int> athleteIds) =>
      loadWithEntries([
        for (final id in athleteIds) (entryId: id * 10, athleteIds: [id]),
      ]);

  Future<RaceCourseController> loadWithEntries(
    List<({int entryId, List<int> athleteIds})> spec, {
    List<List<int>> competitorOrder = const [],
  }) async {
    programme = _FakeProgrammeService(programmeWith(ProgrammeRace(
      id: programmeRaceId,
      number: 1,
      entryIds: [for (final e in spec) e.entryId],
      athleteIds: [for (final e in spec) ...e.athleteIds],
      competitorOrder: competitorOrder,
    )));
    when(() => raceRepo.getEntries(raceId)).thenAnswer((_) async => [
          for (final e in spec)
            Entry(
              id: e.entryId,
              category: const Category(id: categoryId, name: 'Senior'),
              status: 1,
              statusLabel: 'Engagé',
              athletes: [for (final id in e.athleteIds) athlete(id)],
            ),
        ]);
    final controller =
        RaceCourseController(programme, raceRepo, clubRepo, rfid, meetingRepo)
          ..applyArguments(arguments());
    await controller.load();
    return controller;
  }
```

Les tests existants qui appellent `controller.assign(athlete(1))` deviennent `controller.assign(controller.competitors.first)` ; ceux qui lisent `controller.athletes` lisent `controller.competitors`. C'est mécanique : les ids d'engagement valent `id * 10`.

- [ ] **Step 2: Écrire les tests relais qui échouent**

```dart
  group('RaceCourseController relais', () {
    test('une equipe prend une seule place', () async {
      final controller = await loadWithEntries([
        (entryId: 10, athleteIds: [101, 102]),
        (entryId: 20, athleteIds: [201, 202]),
      ]);

      controller.assign(controller.competitors.first);
      controller.assign(controller.competitors.last);

      expect(controller.placeOf(controller.competitors.first), 1);
      expect(controller.placeOf(controller.competitors.last), 2);
    });

    test('le premier bracelet lu classe l equipe', () async {
      final controller = await loadWithEntries([
        (entryId: 10, athleteIds: [101, 102]),
      ]);
      // Le deuxieme relayeur franchit la ligne : c'est l'equipe qui est classee.
      controller.startScan();
      stream.add('L102;B102');
      await pumpEventQueue();

      expect(controller.placeOf(controller.competitors.single), 1);
    });

    test('un coequipier lu ensuite est un doublon', () async {
      final controller = await loadWithEntries([
        (entryId: 10, athleteIds: [101, 102]),
        (entryId: 20, athleteIds: [201]),
      ]);
      controller.startScan();
      stream.add('L101;B101');
      await pumpEventQueue();
      stream.add('L102;B102');
      await pumpEventQueue();

      expect(controller.message.value,
          const UiMessageError('course_athlete_already_ranked'));
      expect(controller.competitorOrder.length, 1);
    });

    test('la course est complete quand toutes les equipes sont placees',
        () async {
      final controller = await loadWithEntries([
        (entryId: 10, athleteIds: [101, 102]),
        (entryId: 20, athleteIds: [201, 202]),
      ]);

      controller.assign(controller.competitors.first);
      expect(controller.isComplete, isFalse);
      controller.assign(controller.competitors.last);
      expect(controller.isComplete, isTrue);
    });

    test('un forfait sort toute l equipe du classement', () async {
      final controller = await loadWithEntries([
        (entryId: 10, athleteIds: [101, 102]),
        (entryId: 20, athleteIds: [201]),
      ]);

      controller.setPenalty(
          controller.competitors.first, CoursePenaltyKind.forfeit);
      controller.assign(controller.competitors.last);

      expect(controller.placeOf(controller.competitors.last), 1);
      expect(saved().penalties.single.competitorId, 10);
    });

    // Le classement stocke par l'ancien code nomme des athletes : il ne nomme
    // aucun engagement de la course, donc il est ecarte plutot que mal relu.
    test('un classement herite de relais est ecarte au chargement', () async {
      final controller = await loadWithEntries(
        [
          (entryId: 10, athleteIds: [101, 102]),
        ],
        competitorOrder: const [
          [101],
          [102]
        ],
      );

      expect(controller.competitorOrder, isEmpty);
    });

    test('un classement d engagements est relu tel quel', () async {
      final controller = await loadWithEntries(
        [
          (entryId: 10, athleteIds: [101, 102]),
          (entryId: 20, athleteIds: [201]),
        ],
        competitorOrder: const [
          [20],
          [10]
        ],
      );

      expect(controller.placeOf(controller.competitors.last), 1);
    });
  });
```

Les deux tests de bracelet passent par le flux que le groupe `scanning` installe déjà — pas de porte dérobée sur `_onBracelet`. Reprendre son harnais dans ce groupe :

```dart
    late StreamController<String> stream;

    setUp(() {
      stream = StreamController<String>();
      when(() => rfid.readBracelets()).thenAnswer((_) => stream.stream);
      when(() => rfid.isSupported).thenReturn(true);
    });

    tearDown(() {
      if (!stream.isClosed) stream.close();
    });
```

et remplacer `controller.onBraceletForTest('L102')` par :

```dart
      controller.startScan();
      stream.add('L102;B102');
      await pumpEventQueue();
```

(le payload est `licence;bracelet`, comme dans les tests de scan existants ; `athlete(id)` donne la licence `L$id`.)

- [ ] **Step 3: Lancer les tests et vérifier qu'ils échouent**

Run: `flutter test test/presentation/modules/competitions/controllers/race_course_controller_test.dart`
Expected: FAIL — `competitors` non défini.

- [ ] **Step 4: Basculer le contrôleur**

- `final RxList<Entry> competitors = <Entry>[].obs;` remplace `athletes` ;
- dans `load()`, après avoir lu les engagements :

```dart
      final entries = await _raceRepo.getEntries(raceIdValue);
      final byEntry = {for (final entry in entries) entry.id: entry};
      final byAthlete = <int, Athlete>{
        for (final entry in entries)
          for (final athlete in entry.athletes) athlete.id: athlete,
      };
      final lineUp = competitorsOf(
        stored ?? const ProgrammeRace(id: 0, number: 0),
        entries: byEntry,
        athletes: byAthlete,
      );

      final storedOrder = [
        for (final group in stored?.competitorOrder ?? const <List<int>>[])
          [...group],
      ];
      // Un classement écrit quand le compétiteur était l'athlète ne nomme aucun
      // engagement de cette course : le relire serait inventer des places.
      final kept = isCompetitorOrder(storedOrder, lineUp);
      competitorOrder.value = kept ? storedOrder : const [];
      penalties.value = kept ? [...?stored?.penalties] : const [];
```

puis la résolution des clubs porte sur `[for (final entry in lineUp) ...entry.athletes]`, et `competitors.value` reçoit les engagements avec leurs athlètes patchés de leur club ;
- `placeOf`, `penaltyOf`, `assign`, `remove`, `setPlace`, `setPenalty`, `clearPenalty` prennent un `Entry` et passent `entry.id` aux fonctions de `course_ranking.dart` ;
- `orderedCompetitors` reprend `orderedAthletes` en substituant `competitors` ;
- `isComplete` parcourt `competitors` ;
- `_onBracelet` résout l'engagement :

```dart
  void _onBracelet(String payload) {
    final licence = parseBraceletLicence(payload);
    Entry? match;
    for (final entry in competitors) {
      if (entry.athletes.any((a) => a.licenseeNumber == licence)) {
        match = entry;
        break;
      }
    }
    if (match == null) {
      message.trigger(const UiMessageError('course_bracelet_not_in_race'));
      return;
    }
    // Une equipe franchit la ligne une fois : le bracelet d'un coequipier lu
    // ensuite retombe sur le doublon que `assign` signale deja.
    assign(match);
    if (isComplete) stopScan();
  }
```

- `_outcomesFor` se simplifie :

```dart
  List<CourseOutcome> _outcomesFor(List<LaneSeat> seats) {
    final places = placesOf(competitorOrder);
    final penaltyOf = <int, CoursePenalty>{
      for (final penalty in penalties) penalty.competitorId: penalty,
    };
    return [
      for (final seat in seats)
        () {
          final penalty = penaltyOf[seat.entryId];
          final status = switch (penalty?.kind) {
            CoursePenaltyKind.disqualified => 1,
            CoursePenaltyKind.forfeit => 2,
            CoursePenaltyKind.unknown => 2,
            null => 0,
          };
          return (
            entryId: seat.entryId,
            laneId: seat.laneId,
            rank: penalty == null ? places[seat.entryId] : null,
            status: status,
            complement: (penalty?.code.isEmpty ?? true) ? null : penalty!.code,
          );
        }(),
    ];
  }
```

- `_rankedEntriesOf` perd sa reconstruction :

```dart
  /// Les engagements d'une course, du premier au dernier, hors retraits.
  ///
  /// Pour la course en cours de validation l'écran l'emporte sur le stockage :
  /// `_persist` n'est délibérément pas attendu, et qualifier sans lui laisserait
  /// cette course hors de sa propre finale.
  List<int> _rankedEntriesOf(ProgrammeRace stored) {
    final mine = stored.id == programmeRaceId;
    final order = mine
        ? [
            for (final group in competitorOrder) [...group],
          ]
        : stored.competitorOrder;
    final applied = mine ? penalties.toList() : stored.penalties;
    final penalised = {for (final p in applied) p.competitorId};
    return [
      for (final group in order)
        for (final id in group)
          if (!penalised.contains(id)) id,
    ];
  }
```

- ajouter `expandedEntries` / `isEntryExpanded` / `toggleEntry` / `requestSubstitution` comme en tâche 5.

- [ ] **Step 5: Lancer les tests et vérifier qu'ils passent**

Run: `flutter test test/presentation/modules/competitions/controllers/race_course_controller_test.dart`
Expected: PASS

- [ ] **Step 6: Brancher la vue**

Dans `race_course_view.dart` :
- `_ctrl.athletes` → `_ctrl.competitors`, `_ctrl.orderedAthletes` → `_ctrl.orderedCompetitors` ;
- `_openRowMenu(Athlete, Offset)` → `_openRowMenu(Entry, Offset)`, `_askDisqualification(Entry)` ;
- `_PlaceField({required Athlete athlete, ...})` → `_PlaceField({required Entry entry, ...})`, son `setPlace` prenant l'engagement ;
- `_CompetitorRow` devient un `EntryGroupTile` : `leading` = le `SizedBox(width: 40)` portant `_PlaceField` ou le badge, `trailing` = les deux `IconButton` existants (assigner/retirer, puis le menu) dans un `Row(mainAxisSize: MainAxisSize.min, ...)`, `onLongPress` = le menu, `athleteTrailing` = `null` (un athlète de relais ne porte ni place ni menu), `onSubstitute` = `controller.requestSubstitution`.

- [ ] **Step 7: Vérifier et commiter**

Run: `flutter analyze && flutter test`
Expected: PASS

```bash
dart format lib/ test/
git add -A
git commit -m "feat(course): une equipe prend une place, pas quatre"
```

---

### Task 9: Relire le classement déjà publié

Sans migration, une course validée avant la bascule rouvre vide. L'écran de saisie va donc chercher ce que FFSS détient — et retrouve du même coup la série existante, ce qui évite d'en créer une seconde à la revalidation.

**Files:**
- Modify: `lib/app/module/competitions/controllers/race_course_controller.dart` (`applyArguments`, `load`, `_heatId`)
- Modify: `lib/app/module/competitions/views/race_structure_view.dart:457` (arguments de navigation)
- Test: `test/presentation/modules/competitions/controllers/race_course_controller_test.dart`

**Interfaces:**
- Consumes: `MeetingRepository.getHeatResultsByHeat` avec `HeatResult.status` (tâche 1), `RaceStructureController.heatIdOf` (tâche 7)
- Produces: l'argument de route `'heatId'` (int, optionnel) accepté par `RaceCourseController.applyArguments`

- [ ] **Step 1: Écrire les tests qui échouent**

```dart
  group('RaceCourseController relecture serveur', () {
    test('une course sans classement local reprend celui de FFSS', () async {
      when(() => meetingRepo.getHeatResultsByHeat(any()))
          .thenAnswer((_) async => {
                55: [
                  (
                    entryId: 20,
                    rank: 1,
                    isDisqualified: false,
                    complement: null,
                    status: 0
                  ),
                  (
                    entryId: 10,
                    rank: 2,
                    isDisqualified: false,
                    complement: null,
                    status: 0
                  ),
                ]
              });

      final controller = await loadWithEntries(
        [
          (entryId: 10, athleteIds: [101]),
          (entryId: 20, athleteIds: [201]),
        ],
        heatId: 55,
      );

      expect(controller.placeOf(controller.competitors.last), 1);
      expect(controller.placeOf(controller.competitors.first), 2);
    });

    test('un forfait relu revient comme forfait, sans place', () async {
      when(() => meetingRepo.getHeatResultsByHeat(any()))
          .thenAnswer((_) async => {
                55: [
                  (
                    entryId: 10,
                    rank: null,
                    isDisqualified: false,
                    complement: null,
                    status: 2
                  ),
                ]
              });

      final controller = await loadWithEntries(
        [
          (entryId: 10, athleteIds: [101]),
        ],
        heatId: 55,
      );

      expect(controller.penaltyOf(controller.competitors.single)?.kind,
          CoursePenaltyKind.forfeit);
      expect(controller.placeOf(controller.competitors.single), isNull);
    });

    // La saisie en cours ne se fait pas ecraser par le serveur : l'operateur
    // est peut-etre en train de corriger ce que FFSS detient encore.
    test('un classement local l emporte sur le serveur', () async {
      final controller = await loadWithEntries(
        [
          (entryId: 10, athleteIds: [101]),
          (entryId: 20, athleteIds: [201]),
        ],
        competitorOrder: const [
          [10],
          [20]
        ],
        heatId: 55,
      );

      expect(controller.placeOf(controller.competitors.first), 1);
      verifyNever(() => meetingRepo.getHeatResultsByHeat(any()));
    });

    // `_heatId` repartait a 0 a chaque ouverture, et `submitHeat(id: null)`
    // cree une serie : revalider apres avoir rouvert l'ecran en empilait une
    // seconde.
    test('la serie retrouvee est celle que la revalidation reecrit', () async {
      when(() => meetingRepo.getHeatResultsByHeat(any()))
          .thenAnswer((_) async => const {55: <HeatResult>[]});
      final controller = await loadWithEntries(
        [
          (entryId: 10, athleteIds: [101]),
        ],
        heatId: 55,
        runId: 3,
      );
      // Le meme harnais que le groupe `validate` : l'arbre des reunions rend
      // la course 3, ses places, et `publishCourseResults` rend une serie.
      stubMeetingTreeForValidate(runId: 3, laneEntryIds: const [10]);
      controller.assign(controller.competitors.single);

      await controller.validate();

      verify(() => meetingRepo.publishCourseResults(
            raceId: any(named: 'raceId'),
            heatName: any(named: 'heatName'),
            heatNumber: any(named: 'heatNumber'),
            outcomes: any(named: 'outcomes'),
            heatId: 55,
            link: any(named: 'link'),
          )).called(1);
    });
  });
```

`loadWithEntries` gagne deux paramètres nommés optionnels de plus : `int heatId = 0` (ajouté à `arguments()`) et `int runId = 0` (posé sur le `ProgrammeRace`). `stubMeetingTreeForValidate` est le harnais que le groupe `validate` monte déjà en place — `getMeetings` rendant une réunion, un créneau et une course portant ses `Lane`, `getLaneSeats` rendant un siège par engagement, `publishCourseResults` rendant un id de série — à extraire en helper du fichier de test lors de cette tâche plutôt qu'à recopier.

- [ ] **Step 2: Lancer les tests et vérifier qu'ils échouent**

Run: `flutter test test/presentation/modules/competitions/controllers/race_course_controller_test.dart`
Expected: FAIL — la course reste vide.

- [ ] **Step 3: Implémenter**

Dans `applyArguments` :

```dart
    // L'onglet Séries connaît déjà la série de cette course : la recevoir
    // épargne un parcours complet de l'arbre des réunions, et surtout évite de
    // revalider dans une seconde série.
    final heat = arg['heatId'];
    if (heat is int) _heatId = heat;
```

À la fin de `load()`, une fois `competitors` et `competitorOrder` posés :

```dart
      if (competitorOrder.isEmpty && penalties.isEmpty) {
        await _seedFromPublished(stored);
      }
```

et :

```dart
  /// Reprend le classement que FFSS détient pour cette course.
  ///
  /// Sans migration des classements locaux hérités, c'est ce qui évite qu'une
  /// course déjà validée rouvre vide. Best-effort : une lecture qui échoue
  /// laisse la course à saisir, ce qui est toujours mieux qu'un écran d'erreur
  /// au bord du bassin.
  Future<void> _seedFromPublished(ProgrammeRace? stored) async {
    if (_heatId == 0) _heatId = await _resolveHeatId(stored);
    if (_heatId == 0) return;
    try {
      final byHeat = await _meetings.getHeatResultsByHeat([_heatId]);
      final results = byHeat[_heatId] ?? const <HeatResult>[];
      if (results.isEmpty) return;

      final known = {for (final entry in competitors) entry.id};
      final ranked = [
        for (final result in results)
          if (result.rank != null && known.contains(result.entryId)) result,
      ]..sort((a, b) => a.rank!.compareTo(b.rank!));
      // Un rang partagé est un ex-aequo déclaré : il reste un seul groupe.
      final groups = <int, List<int>>{};
      for (final result in ranked) {
        (groups[result.rank!] ??= []).add(result.entryId);
      }
      final ranks = groups.keys.toList()..sort();
      competitorOrder.value = [for (final rank in ranks) groups[rank]!];

      penalties.value = [
        for (final result in results)
          if (known.contains(result.entryId))
            if (_penaltyKindOf(result) case final CoursePenaltyKind kind)
              CoursePenalty(
                competitorId: result.entryId,
                kind: kind,
                code: result.complement ?? '',
              ),
      ];
    } on AppException {
      // La course reste à saisir.
    }
  }

  CoursePenaltyKind? _penaltyKindOf(HeatResult result) => switch (result.status) {
        1 => CoursePenaltyKind.disqualified,
        2 => CoursePenaltyKind.forfeit,
        _ => result.isDisqualified ? CoursePenaltyKind.disqualified : null,
      };

  /// La série de cette course quand l'appelant ne l'a pas donnée : le repli,
  /// qui paie l'arbre des réunions.
  Future<int> _resolveHeatId(ProgrammeRace? stored) async {
    final competitionId = competition.value?.id;
    if (stored == null || stored.runId == 0 || competitionId == null) return 0;
    try {
      final located = _locate(await _meetings.getMeetings(competitionId),
          stored.runId);
      return located?.$2.heat?.id ?? 0;
    } on AppException {
      return 0;
    }
  }
```

- [ ] **Step 4: Passer l'id de série depuis l'onglet Séries**

`race_structure_view.dart:457`, ajouter à la map d'arguments : `'heatId': controller.heatIdOf(race),`.

- [ ] **Step 5: Lancer les tests et vérifier qu'ils passent**

Run: `flutter test`
Expected: PASS

- [ ] **Step 6: Vérifier l'ensemble**

Run: `flutter analyze && flutter test`
Expected: aucun avertissement, toute la suite verte.

- [ ] **Step 7: Commit**

```bash
dart format lib/ test/
git add -A
git commit -m "feat(course): relire le classement deja publie sur FFSS"
```

---

### Task 10: Mettre CLAUDE.md à jour

Le dépôt documente ses conventions dans `CLAUDE.md` ; trois affirmations y deviennent fausses.

**Files:**
- Modify: `live_ffss/CLAUDE.md`

- [ ] **Step 1: Corriger les trois passages**

- section **domain/models** : ajouter `competitor` à la liste des modèles, en précisant que c'est une fonction pure comme `course_ranking` ;
- section **presentation/shared** : ajouter `EntryGroupTile` à la liste des widgets partagés, avec la règle « tout affichage d'un compétiteur passe par lui — jamais une ligne d'athlète à la main » ;
- section **Things to NOT do** : ajouter « Ne pas indexer un classement par athlète. `ProgrammeRace.competitorOrder` et `CoursePenalty.competitorId` nomment des **engagements** ; un ordre qui nomme des athlètes est un héritage, reconnu par `isCompetitorOrder` et écarté. »
- section **Known gaps** : noter que le remplacement d'un membre de relais est un seam inerte (`requestSubstitution`), et que les classements locaux hérités des relais ne sont pas migrés mais relus depuis FFSS quand la course a été validée.

- [ ] **Step 2: Commit**

```bash
git add live_ffss/CLAUDE.md
git commit -m "docs: le competiteur est l engagement, et EntryGroupTile l affiche"
```

---

## Notes d'exécution

**État transitoire assumé entre les tâches 7 et 8.** La tâche 7 fait lire l'onglet Séries en engagements pendant que l'écran de saisie écrit encore des athlètes. Entre les deux commits, un classement **local** saisi avant la bascule n'apparaît plus dans l'onglet Séries ; un classement validé sur FFSS, lui, s'affiche normalement, le serveur étant déjà indexé par engagement. C'est l'état final voulu pour les relais, atteint un commit trop tôt pour les épreuves individuelles en cours de saisie.

**Ordre des tâches.** 1 → 2 → 3 posent les fondations ; 4 fabrique le composant ; 5 et 6 sont indépendantes l'une de l'autre et de la bascule de clé ; 7 puis 8 basculent lecture puis écriture ; 9 dépend de 1, 7 et 8 ; 10 clôt.

**Ce qui n'est pas vérifiable ici.** Ni toolchain Windows ni appareil Android dans cet environnement : chaque tâche s'arrête à `flutter test` et `flutter analyze`. Le rendu des lignes dépliées, le scan d'un bracelet de relais et la relecture d'une vraie série FFSS demandent un passage sur appareil, qui revient à l'utilisateur.
