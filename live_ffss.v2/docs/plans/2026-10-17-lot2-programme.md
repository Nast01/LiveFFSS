# LiveFFSS v2 — Lot 2 : programme public — plan d'implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal :** remplacer l'onglet Programme provisoire par le planning de la compétition, jour par jour, et ouvrir chaque créneau d'épreuve sur un détail en lecture seule : frise du déroulement, séries, couloirs, temps et rang officiel.

**Architecture :** `features` → `data` → `domain`, comme au lot 1. Le domaine reçoit `Progression`/`Stage` et `LaneAssignment`/`Performance` (noms V3) et des fonctions pures pour le programme. `MeetingRepository` lit en plus les déroulements et les places. Deux nouveaux fournisseurs, `programmeProvider` et `meetingItemDetailProvider`, se rafraîchissent toutes les 30 s ; la politique de rafraîchissement du détail est une fonction pure.

**Tech Stack :** Flutter 3.47.7 / Dart 3.13.5, flutter_riverpod ^3.3.2 (Riverpod 3.4), go_router ^18.1.0, freezed ^4.0.2 + json_serializable ^6.14.1, mocktail, fake_async, gen-l10n.

**Spec :** [`docs/specs/2026-10-17-lot2-programme-design.md`](../specs/2026-10-17-lot2-programme-design.md) — à lire avant toute tâche, en particulier le § 2 (forme réelle des réponses).

## Global Constraints

- Règles du [`CLAUDE.md`](../../CLAUDE.md) de la v2 : architecture, `clockProvider` (jamais `DateTime.now()` dans un fournisseur ou une page), `retry: noRetry` dans les tests, pas de test de widget, une page sans logique testable, `AppException` seulement, commentaires qui disent pourquoi.
- Noms du domaine : ceux de FFSSCompetition V3 (`Progression`, `Stage`, `StageLevel`, `QualificationMethod`, `LaneAssignment`, `Performance`). Jamais de nom français de l'API dans le domaine.
- L'app **ne calcule aucun classement ni aucun rang** : elle affiche le `rangLabel` publié.
- L'app parle **à la production**. Pour essayer à la main sur la recette 1416, changer localement `appConfigProvider` en `AppConfig.forEnvironment(AppEnvironment.<recette>)`, **sans le commiter**.
- Aucune donnée personnelle (e-mail, date de naissance, numéro de licence, adresse, téléphone) dans `test/fixtures/` : le dépôt est sur GitHub.
- Traductions : `app_fr.arb` fait référence, `app_en.arb` a les mêmes clés ; `flutter gen-l10n` après chaque modification.
- Après une modification freezed/json : `dart run build_runner build --delete-conflicting-outputs`, fichiers générés commités.
- Chaque tâche se termine par `flutter analyze` (aucun problème), `flutter test` (tout vert) et `dart format lib test` (aucun changement) avant le commit.
- Commits en français, préfixe `feat(v2):`, `fix(v2):`, `test(v2):` ou `docs(v2):`, terminés par la ligne `Co-Authored-By` de la session.

## Review Focus

1. **Une compétition sans déroulement** (`competition/:id/deroulement` vide ou en échec) : le programme s'affiche quand même, sans nom d'épreuve ni frise — test dans la tâche 5.
2. **Un créneau dont toutes les places échouent** (réseau coupé au bord du bassin) : le détail s'affiche avec ses courses et sans nageurs au premier chargement ; au rafraîchissement, les nageurs déjà affichés restent — tests dans les tâches 6 et 10.
3. **Une compétition dont aucun jour n'est aujourd'hui** (passée ou future) : l'onglet s'ouvre sur le dernier ou le premier jour, jamais sur un onglet vide — test dans la tâche 7.
4. **Un créneau ouvert par lien direct alors que le programme n'est pas encore chargé** (ou pour une autre compétition) : le détail attend le programme, et la compétition du lien devient active — tests dans les tâches 8 et 10.
5. **Une heure FFSS illisible ou absente** sur un créneau ou une course : la ligne reste affichée, sans heure — test dans la tâche 4.

---

## Structure des fichiers

```
lib/
├── core/config/app_config.dart            (mod.) nouveaux ApiEndpoints
├── core/router/app_router.dart            (mod.) Programme réel + route du détail
├── core/l10n/app_fr.arb, app_en.arb       (mod.) clés du programme
├── domain/
│   ├── progression.dart                   (nouv.) Progression, Stage, StageLevel, QualificationMethod
│   ├── lane_assignment.dart               (nouv.) LaneAssignment, Performance
│   ├── programme.dart                     (nouv.) Programme + fonctions pures du programme
│   ├── meeting.dart                       (mod.) MeetingItem.startTime/endTime
│   └── heat.dart                          (mod.) Heat.placeIds, Heat.seriesId
├── data/ffss/
│   ├── dtos/deroulement_dto.dart          (nouv.) DeroulementDto, PartieDto
│   ├── dtos/place_dto.dart                (nouv.) PlaceDto et ses sous-objets
│   ├── dtos/reunion_dto.dart              (mod.) créneau (heures, partie), course (places)
│   ├── mappers/deroulement_mapper.dart    (nouv.)
│   ├── mappers/place_mapper.dart          (nouv.)
│   └── mappers/reunion_mapper.dart        (mod.)
├── data/repositories/
│   ├── meeting_repository.dart            (mod.) getProgramme, getMeetingItem, getLanes
│   └── competition_repository.dart        (mod.) getCompetition
└── features/
    ├── home/now_running_provider.dart     (mod.) getProgramme
    ├── shell/active_competition.dart      (mod.) ensure(id)
    ├── shell/current_competition.dart     (mod.) relecture par id
    └── programme/
        ├── programme_providers.dart       programmeProvider, selectedDayProvider
        ├── item_detail_refresh.dart       politique de rafraîchissement (pure)
        ├── item_detail_providers.dart     meetingItemDetailProvider, progressionExpandedProvider
        ├── programme_formatting.dart      libellés (badge, règle, étape, rang)
        ├── programme_page.dart
        ├── item_detail_page.dart
        └── widgets/ day_tabs.dart, meeting_card.dart, item_row.dart, status_badge.dart,
                     progression_strip.dart, heat_card.dart, lane_row.dart
test/
├── fixtures/recette_1416/                 (nouv.) extraits réels, anonymisés
├── support/fixtures.dart                  (nouv.) lecture d'un extrait
└── … même arborescence que lib/
```

---

### Task 1 : extraits réels de la recette et contrat de l'API

**Files:**
- Create: `test/fixtures/recette_1416/reunion.json`, `deroulement.json`, `creneau_177.json`, `place_2816.json`, `place_2830.json`, `evenement_1416.json`
- Create: `test/support/fixtures.dart`
- Modify: `lib/core/config/app_config.dart` (`ApiEndpoints`)
- Modify: `../docs/FFSS_API_CONTRACT.md`

**Interfaces:**
- Produces: `Map<String, dynamic> fixture(String name)` (lit `test/fixtures/recette_1416/<name>.json`, rend l'objet racine décodé) ; `ApiEndpoints.progressionList = 'competition/:id/deroulement'`, `ApiEndpoints.meetingItem = 'competition/reunion/creneau/:id'`, `ApiEndpoints.lane = 'competition/reunion/creneau/course/place/:id'`, `ApiEndpoints.competition = 'competition/evenement/:id'`.

- [ ] **Step 1 : capturer les réponses** (lecture seule, recette `https://site.ffss.io/api/v1.0/`) : `competition/1416/reunion?start=0&length=100`, `competition/1416/deroulement?start=0&length=100`, `competition/reunion/creneau/177`, `competition/reunion/creneau/course/place/2816`, `…/place/2830`, `competition/evenement/1416`. Enregistrer les réponses brutes **hors du dépôt**.
- [ ] **Step 2 : réduire et anonymiser**, en gardant l'enveloppe (`success`, `data`, `recordsTotal`…) et la casse exacte des clés :
  - `reunion.json` : les réunions **104** et **110** seulement ; dans 104, les créneaux **174** (sans course), **177** (avec ses 2 premières courses) et **185** ; dans 110, les créneaux **347** et **348** (Finale A Cadet, courses sans `serie`). Dans chaque course gardée, garder toutes les places.
  - `deroulement.json` : les déroulements **501** (200 m obstacles Femme, 4 parties : séries puis 3 finales) et **502** (lancer de corde, 1 partie).
  - `creneau_177.json` : ses 2 premières courses seulement, `partie` complète.
  - `place_*.json` : supprimer dans tout l'objet les clés `Licencie`, `numeroLicence`, `NumeroLicence`, `email`, `EmailLcs`, `DateNaissanceLcs`, `annee`, `Annee`, `dossard`, `idLicencie`, `organisme` et tout bloc d'adresse ou de contact. Garder `publicLabel`, `nationaliteCode`, `clubLabel`, `isForfait`, `EpreuveCategorie`, `resultat`.
  - `evenement_1416.json` : retirer `Organisme` sauf `NomOrga` et `label`, et toute coordonnée de contact.
  - Vérifier : `grep -riE "@|DateNaissance|NumeroLcs|numeroLicence" test/fixtures` ne trouve rien.
- [ ] **Step 3 : écrire `test/support/fixtures.dart`** (lecture synchrone depuis `test/fixtures/recette_1416/`, chemin relatif au dossier du projet, comme le lance `flutter test`).
- [ ] **Step 4 : ajouter les quatre endpoints** à `ApiEndpoints`.
- [ ] **Step 5 : reporter le § 2 de la spec dans `../docs/FFSS_API_CONTRACT.md`** (nouvelle section « Programme, vérifié le 2026-10-17 sur la recette 1416 ») : partie présente dans la liste sans déroulement ; places vides dans les listes ; `place/:id` complète, avec `rangLabel` par catégorie et sans `complement` ni code `Statut` ; `creneau/:id` sans réunion ; `creneau/:id/course` en échec avec son message ; déroulement de la liste avec `Discipline`/`Genre`, déroulement imbriqué avec `discipline`/`genreLabel` ; `serie` réduit sans `Numero` ni `epreuve`.
- [ ] **Step 6 : `flutter analyze` et `flutter test`**, puis commit : `test(v2): extraits réels de la recette 1416 et contrat du programme`.

### Task 2 : déroulement — `Progression` et `Stage`

**Files:**
- Create: `lib/domain/progression.dart`, `lib/data/ffss/dtos/deroulement_dto.dart`, `lib/data/ffss/mappers/deroulement_mapper.dart`
- Test: `test/data/ffss/mappers/deroulement_mapper_test.dart`

**Interfaces:**
- Consumes: `fixture()` (tâche 1), `Gender`, `parseGender` (`reunion_mapper.dart`).
- Produces:
  - `enum StageLevel { heats, quarterFinal, semiFinal, finalStage }` avec `static StageLevel? fromCode(String?)` (`heat`, `quarter`, `semi`, `final`).
  - `enum QualificationMethod { none, byHeat, byStage }` avec `static QualificationMethod fromCode(String?)` (`course` → byHeat, `partie` → byStage, autre → none).
  - `Stage({required int id, required int order, required StageLevel level, required String name, required QualificationMethod qualification, required int heatCount, required int placesPerHeat, int? qualifyingPlaces})` — `name` est le `label` FFSS (« Finale - Cadet ») ; `qualifyingPlaces` nul quand l'API donne 0.
  - `Progression({required int id, required String name, String disciplineName = '', Gender? gender, @Default([]) List<Stage> stages})` — `stages` triées par `order` ; `Stage? stageById(int id)`.
  - `PartieDto` (clés `id`, `ordre`, `niveau`, `label`, `nbCourses`, `nbPlaceParCourse`, `nbPlaceQualificative`, `logiqueQualification`, `deroulement` (lu par `readMap`)) et `DeroulementDto` (`Id`/`id`, `label`, `Genre`, `genreLabel`, `Discipline`/`discipline` → `Nom`, `parties`).
  - `extension DeroulementMapper on DeroulementDto { Progression? toDomain(); }`, `extension PartieMapper on PartieDto { Stage? toDomain(); }`.

- [ ] **Step 1 : écrire les tests** :
  - `'le 200 m obstacles Femme : séries puis trois finales'` — `DeroulementDto.fromJson(fixture('deroulement')['data'][0])` (501) → `id == 501`, `disciplineName == '200m Obstacles'`, `gender == Gender.female`, 4 étapes ; `stages[0]` : `level == StageLevel.heats`, `qualification == QualificationMethod.byStage`, `heatCount == 10`, `placesPerHeat == 8`, `qualifyingPlaces == null` ; `stages[1].name == 'Finale - Cadet'`, `stages[1].level == StageLevel.finalStage`.
  - `'le déroulement imbriqué dans un créneau se lit aussi'` — `fixture('creneau_177')['data']['partie']['deroulement']` → même `disciplineName`, `gender == Gender.female` (tiré de `genreLabel: 'Femme'` faute de `Genre`), 4 étapes.
  - `'une partie sans id est écartée, pas le déroulement'` et `'un déroulement sans id est écarté'`.
  - `'étapes triées par ordre même servies dans le désordre'`.
- [ ] **Step 2 : lancer** `flutter test test/data/ffss/mappers/deroulement_mapper_test.dart` — échec attendu (classes absentes).
- [ ] **Step 3 : écrire domaine, DTO et mapper.** Une lecture `readValue` par clé à deux casses (`Discipline` puis `discipline`, `Id` puis `id`) dans `deroulement_dto.dart`. Genre : `parseGender(Genre)`, sinon `genreLabel` (`Homme` → male, `Femme` → female, `Mixte` → mixed). `build_runner`.
- [ ] **Step 4 : relancer le test** — vert. Puis analyze/test/format et commit : `feat(v2): déroulement des épreuves — Progression et Stage`.

### Task 3 : place — `LaneAssignment` et `Performance`

**Files:**
- Create: `lib/domain/lane_assignment.dart`, `lib/data/ffss/dtos/place_dto.dart`, `lib/data/ffss/mappers/place_mapper.dart`
- Test: `test/data/ffss/mappers/place_mapper_test.dart`

**Interfaces:**
- Produces:
  - `Performance({String? time, String? statusLabel, String? rankLabel, @Default(false) bool isDisqualified, @Default(false) bool isRecord, @Default(false) bool isNationalRecord})` avec `bool get isOk` (`statusLabel` absent ou `OK`, insensible à la casse).
  - `LaneAssignment({required int id, required int lane, @Default([]) List<String> athletes, String club = '', String? category, @Default(false) bool forfeit, @Default(false) bool isRelay, Performance? performance})` — `id` est l'id FFSS de la place ; `bool get isEmpty => athletes.isEmpty`.
  - `extension PlaceMapper on PlaceDto { LaneAssignment? toDomain(); }` — nul sans `id` ni `Numero`.

- [ ] **Step 1 : écrire les tests** sur `fixture('place_2816')['data']` : `lane == 2`, `athletes == ['ATHLETE Un']`, `club == 'Biscarrosse Olympique Sauvetage et Secourisme'`, `category == 'Cadet'` (`engagement.EpreuveCategorie.Categorie.Nom`), `isRelay == false` (`EpreuveCategorie.Epreuve.Discipline.isRelais`), `performance.time == '02\'55"77'`, `performance.rankLabel == '5ème'`, `performance.isOk == true`. Puis :
  - `'une place sans engagement est vide, sans performance'` (JSON `{"id": 1, "Numero": 3, "engagement": null, "resultat": null}`) ;
  - `'engagement servi en [] par PHP : place vide, pas d\'erreur'` ;
  - `'un résultat DQ'` (`statutLabel: 'DQ'`, `isDisqualifie: true`, `tempsLabel` absent) → `isOk == false`, `isDisqualified == true`.
- [ ] **Step 2 : lancer** — échec attendu.
- [ ] **Step 3 : écrire domaine, DTO, mapper** (`readMap` sur `engagement`, `resultat`, `EpreuveCategorie`, `Categorie`, `Epreuve`, `Discipline` ; `readInt` sur `id`, `Numero`). `build_runner`.
- [ ] **Step 4 : vert**, puis analyze/test/format et commit : `feat(v2): places et résultats — LaneAssignment et Performance`.

### Task 4 : réunion — heures des créneaux, partie, places des courses

**Files:**
- Modify: `lib/domain/meeting.dart`, `lib/domain/heat.dart`, `lib/data/ffss/dtos/reunion_dto.dart`, `lib/data/ffss/mappers/reunion_mapper.dart`
- Test: `test/data/ffss/mappers/reunion_mapper_test.dart` (ajouts)

**Interfaces:**
- Consumes: `PartieDto` (tâche 2).
- Produces:
  - `MeetingItem` : ajout de `DateTime? startTime`, `DateTime? endTime`. `roundId` garde son nom et désigne l'id de la partie FFSS (un commentaire le dit, avec la correspondance V3 `Stage`).
  - `Heat` : ajout de `@Default(<int>[]) List<int> placeIds` (ids FFSS des places, dans l'ordre des couloirs) et `int? seriesId` (nul tant que la série n'est pas générée).
  - `CreneauDto` : `Debut`, `Fin`, et `partie` devient un `PartieDto?`. `PartieRefDto` disparaît. `CourseDto` : `places` (`List<PlaceRefDto>`, clés `id`, `Numero`). `SerieDto` lit `id` puis `Id`, et garde `Numero`/`epreuve` (absents de la recette, présents selon la v1).
  - `Heat.number` : `serie.Numero`, sinon le nombre en fin du nom de la course (`Série 3` → 3), sinon 0.

- [ ] **Step 1 : écrire les tests** sur `fixture('reunion')['data']` :
  - `'heures des créneaux posées sur le jour de la réunion'` — créneau 177 : `startTime == DateTime(2026, 3, 27, 8, 0)`, `endTime == DateTime(2026, 3, 27, 8, 40)`.
  - `'un créneau sans épreuve n\'a ni partie ni course'` — 174 : `roundId == null`, `heats` vide.
  - `'la partie d\'un créneau d\'épreuve vient de la liste'` — 177 : `roundId == 142`.
  - `'places de la course, dans l\'ordre des couloirs'` — course 479 : `placeIds == [2816, 2817, 2818, 2819, 2820, 2821]`, `seriesId == 94894`, `number == 1`.
  - `'une finale pas encore générée n\'a pas de série'` — créneau 347 : toutes ses courses `seriesId == null`.
  - `'une heure illisible laisse le créneau affiché sans heure'` — `Debut: '8h'` → `startTime == null`, créneau présent.
  - Les tests existants qui utilisaient `PartieRefDto` ou `Numero` passent toujours (les adapter s'ils construisent `PartieRefDto`).
- [ ] **Step 2 : échec attendu.**
- [ ] **Step 3 : modifier domaine, DTO, mapper** ; `build_runner`.
- [ ] **Step 4 : vert** (y compris `now_running_test.dart`), puis analyze/test/format et commit : `feat(v2): réunions — heures des créneaux, partie et places des courses`.

### Task 5 : `getProgramme` — réunions + déroulements, et la carte « MAINTENANT » réparée

**Files:**
- Create: `lib/domain/programme.dart` (classe `Programme` et `withRaces`)
- Modify: `lib/data/repositories/meeting_repository.dart`, `lib/features/home/now_running_provider.dart`
- Test: `test/data/repositories/meeting_repository_test.dart`, `test/domain/programme_test.dart` (création), `test/features/home/now_running_provider_test.dart`

**Interfaces:**
- Produces:
  - `Programme({@Default([]) List<Meeting> meetings, @Default([]) List<Progression> progressions})` avec `Progression? progressionOfStage(int stageId)` et `({Meeting meeting, MeetingItem item})? findItem(int itemId)`.
  - `List<Meeting> withRaces(List<Meeting> meetings, List<Progression> progressions)` (fonction pure) : pour chaque créneau dont `roundId` appartient à un déroulement, ses courses prennent `raceId = progression.id`, `raceName = progression.disciplineName`, `gender = progression.gender` — **sauf** si la course a déjà un `raceName` non vide (forme de la v1).
  - `MeetingRepository.getProgramme(int competitionId) → Future<Programme>` **remplace** `getMeetings`. Réunions comme avant (pagination, tri, ligne écartée seule) ; déroulements par `ApiEndpoints.progressionList`, même pagination ; puis `withRaces`.
  - `nowRunningProvider` lit `getProgramme(id)` puis `nowRunning(programme.meetings)`.

- [ ] **Step 1 : écrire les tests** :
  - `programme_test.dart` : `'withRaces donne nom, sexe et épreuve aux courses du déroulement'` (créneau `roundId: 142`, déroulement 501 contenant l'étape 142 → `raceName == '200m Obstacles'`, `gender == Gender.female`, `raceId == 501`) ; `'une course qui a déjà son épreuve la garde'` ; `'un créneau sans partie reste sans épreuve'` ; `findItem` et `progressionOfStage`.
  - `meeting_repository_test.dart` : `'getProgramme lit réunions et déroulements de la compétition'` (vérifie `competition/1416/reunion` et `competition/1416/deroulement`) ; `'déroulements en échec (AppException) : programme sans épreuves, pas d\'erreur'` ; `'déroulements vides : programme sans épreuves'` ; les tests existants de `getMeetings` renommés vers `getProgramme(...).meetings`.
  - `now_running_provider_test.dart` : adapter le simulacre à `getProgramme`.
- [ ] **Step 2 : échec attendu.**
- [ ] **Step 3 : implémenter.** Un échec des déroulements est attrapé comme `AppException` dans le repository : le programme passe avant la frise.
- [ ] **Step 4 : vert**, puis analyze/test/format et commit : `feat(v2): programme — réunions et déroulements, épreuve des séries réparée`.

### Task 6 : un créneau, ses places, une compétition par id

**Files:**
- Modify: `lib/data/repositories/meeting_repository.dart`, `lib/data/repositories/competition_repository.dart`
- Test: `test/data/repositories/meeting_repository_test.dart`, `test/data/repositories/competition_repository_test.dart`

**Interfaces:**
- Produces:
  - `MeetingRepository.getMeetingItem(int itemId, {required DateTime day}) → Future<MeetingItem?>` — `ApiEndpoints.meetingItem`, réponse `data` objet ; heures posées sur `day` ; nul si la réponse ne donne pas de créneau lisible.
  - `MeetingRepository.getLanes(Iterable<int> placeIds) → Future<Map<int, LaneAssignment?>>` — **au plus 6 requêtes en vol** (`static const int maxConcurrentLanes = 6`). Une clé présente = place lue (valeur nulle = place vide) ; **une clé absente = échec** de cette place (`AppException` attrapée). Ne lève jamais pour une place.
  - `CompetitionRepository.getCompetition(int id) → Future<CompetitionSummary?>` — `ApiEndpoints.competition`, mapper existant.

- [ ] **Step 1 : écrire les tests** :
  - `'getMeetingItem lit le créneau 177 et pose ses heures sur le jour donné'` (réponse = `fixture('creneau_177')` → 2 courses, `roundId == 142`, `startTime == DateTime(2026, 3, 27, 8, 0)`).
  - `'getLanes : jamais plus de 6 places en même temps'` — 14 ids ; le simulacre compte les appels en vol à l'aide de `Completer`s et relâche par lots ; maximum observé `== 6`, résultat de 14 clés.
  - `'getLanes : une place en échec est absente du résultat, les autres sont là'`.
  - `'getLanes : une place vide est présente avec la valeur nulle'`.
  - `'getCompetition lit la compétition 1416'` (`fixture('evenement_1416')`) et `'getCompetition rend nul pour une réponse sans compétition'`.
- [ ] **Step 2 : échec attendu.** — **Step 3 : implémenter** (file d'attente simple de 6 travailleurs sur un itérateur partagé, pas de dépendance nouvelle). — **Step 4 : vert**, analyze/test/format, commit : `feat(v2): lecture d'un créneau, de ses places, d'une compétition par id`.

### Task 7 : fonctions pures du programme

**Files:**
- Modify: `lib/domain/programme.dart`
- Test: `test/domain/programme_test.dart`

**Interfaces:**
- Produces :
  - `List<DateTime> programmeDays(List<Meeting> meetings)` — jours distincts, croissants, à minuit.
  - `DateTime? initialDay(List<DateTime> days, DateTime today)` — aujourd'hui s'il en fait partie ; sinon le premier jour si `today` le précède ; sinon le dernier ; nul si `days` est vide.
  - `enum ItemStatus { none, live, finished, seriesPending, upcoming }` et `ItemStatus itemStatus(MeetingItem item)` — `none` sans course ; `live` si une course est `marshalling` ou `inProgress` ; `finished` si toutes sont `finished` ; `seriesPending` si aucune n'a de `seriesId` ; sinon `upcoming`.
  - `List<List<Stage>> progressionColumns(Progression progression)` — étapes par `order` ; des étapes **consécutives de même niveau** partagent une colonne.
  - `List<MeetingItem> itemsOfStage(List<Meeting> meetings, int stageId)` — créneaux dont `roundId == stageId`, dans l'ordre du programme (jour, réunion, créneau).
  - `enum QualificationRuleKind { byStage, byHeat }` et `({QualificationRuleKind kind, int? places})? qualificationRule(Stage stage)` — `byStage` → `(kind: byStage, places: stage.qualifyingPlaces)` ; `byHeat` → `(kind: byHeat, places: stage.qualifyingPlaces)` ; `none` → nul.

- [ ] **Step 1 : écrire les tests** : jours de la fixture réunion (`[2026-03-27]`) ; `initialDay` pour aujourd'hui dedans, avant, après, liste vide ; `itemStatus` pour chacun des 5 cas ; `progressionColumns` sur 501 → `[[séries], [finale Cadet, finale Junior, finale Seniors et Masters]]`, sur 502 → `[[séries]]`, et `Séries → Demi → Finale` → 3 colonnes ; `itemsOfStage` avec deux créneaux (Finale B puis Finale A) sur la même partie → les deux dans l'ordre ; `qualificationRule` pour les trois logiques.
- [ ] **Step 2 : échec attendu.** — **Step 3 : implémenter.** — **Step 4 : vert**, analyze/test/format, commit : `feat(v2): programme — jours, état des créneaux, colonnes de la frise`.

### Task 8 : compétition active relue par son id (lacune du lot 1)

**Files:**
- Modify: `lib/features/shell/active_competition.dart`, `lib/features/shell/current_competition.dart`, `CLAUDE.md` (section « Lacunes connues »)
- Test: `test/features/shell/active_competition_test.dart`, `test/features/shell/current_competition_test.dart`

**Interfaces:**
- Produces:
  - `competitionByIdProvider = FutureProvider.family<CompetitionSummary?, int>` (lit `getCompetition`).
  - `currentCompetition(...)` reçoit `CompetitionSummary? fetched` : utilisé quand l'id choisi n'est ni dans la liste ni dans `selection.summary`. `currentCompetitionProvider` le lit par `competitionByIdProvider(selection.id)` **seulement dans ce cas**.
  - `ActiveCompetitionNotifier.ensure(int id) → Future<void>` — sans effet si l'id actif est déjà `id` ; sinon `(id: id, summary: null)` et enregistrement.

- [ ] **Step 1 : tests** : `'une compétition choisie absente de l\'accueil est relue par son id'` (le simulacre de `getCompetition` est appelé, le résultat est la compétition relue) ; `'pas de relecture quand la compétition est dans la liste'` (`verifyNever`) ; `'ensure ne réécrit pas le même id'` ; `'ensure enregistre un nouvel id'`.
- [ ] **Step 2–4** : échec, implémentation, vert. Retirer la lacune du `CLAUDE.md`. Commit : `fix(v2): la compétition ouverte depuis la recherche survit au redémarrage`.

### Task 9 : fournisseurs de l'onglet Programme

**Files:**
- Create: `lib/features/programme/programme_providers.dart`
- Test: `test/features/programme/programme_providers_test.dart`

**Interfaces:**
- Produces:
  - `const Duration programmeRefresh = Duration(seconds: 30)`.
  - `programmeProvider = FutureProvider.autoDispose.family<Programme, int>` — même minuterie que `nowRunningProvider` (`Timer(programmeRefresh, ref.invalidateSelf)`).
  - `selectedDayProvider = NotifierProvider.autoDispose.family<SelectedDayNotifier, DateTime?, int>` (par compétition) : `build()` rend `initialDay(programmeDays(meetings), clock())` dès que le programme est là ; `select(DateTime day)`.

- [ ] **Step 1 : tests** (`fake_async`, `retry: noRetry`) : `'relit le programme toutes les 30 s tant qu\'il est écouté'` (2 appels après 30 s) ; `'arrête de relire quand plus personne n\'écoute'` ; `'un rafraîchissement en échec garde le programme'` (`hasValue && hasError`) ; `'le jour choisi par défaut est aujourd\'hui'` avec `clockProvider` surchargé ; `'un jour choisi tient au rafraîchissement'`.
- [ ] **Step 2–4** : échec, implémentation, vert. Commit : `feat(v2): fournisseurs de l'onglet Programme`.

### Task 10 : détail d'un créneau — rafraîchissement et état

**Files:**
- Create: `lib/features/programme/item_detail_refresh.dart`, `lib/features/programme/item_detail_providers.dart`
- Test: `test/features/programme/item_detail_refresh_test.dart`, `test/features/programme/item_detail_providers_test.dart`

**Interfaces:**
- Consumes: `programmeProvider`, `getMeetingItem`, `getLanes`, `Programme.findItem`, `Programme.progressionOfStage`.
- Produces:
  - Dans `item_detail_refresh.dart` (pur) :
    - `const Duration finishedHeatRefresh = Duration(minutes: 2)`.
    - `Set<int> heatsToRefresh(List<Heat> heats, Map<int, DateTime> finishedReadAt, DateTime now)` — toute course non `finished` ; une course `finished` absente de `finishedReadAt` (jamais relue depuis sa fin) ; une course `finished` relue il y a `>= finishedHeatRefresh`.
    - `Map<int, LaneAssignment?> mergeLanes(Map<int, LaneAssignment?> previous, Map<int, LaneAssignment?> fetched, Iterable<int> requested)` — une place demandée et présente dans `fetched` prend la nouvelle valeur ; demandée et absente (échec) garde `previous` ; non demandée garde `previous`.
  - `MeetingItemDetail({required Meeting meeting, required MeetingItem item, Progression? progression, Stage? stage, @Default({}) Map<int, LaneAssignment?> lanes})` (freezed, dans `item_detail_providers.dart`) avec `List<LaneAssignment> lanesOf(Heat heat)` (places non vides de la course, triées par couloir).
  - `typedef ItemKey = ({int competitionId, int itemId})`.
  - `meetingItemDetailProvider = AsyncNotifierProvider.autoDispose.family<MeetingItemDetailNotifier, MeetingItemDetail, ItemKey>` :
    - `build()` attend `programmeProvider(competitionId).future`, trouve le créneau par `findItem`, lit `getMeetingItem(itemId, day: meeting.day)` puis **toutes** les places, démarre la minuterie de 30 s. Créneau absent du programme ou `getMeetingItem` nul : lever `const NotFoundException('meeting item <id>')`, nouvelle sous-classe de la famille scellée `AppException` (`lib/core/errors/app_exception.dart`), que la page traduit par `itemNotFound`. Ajouter un `case` pour elle partout où un `switch` exhaustif sur `AppException` existe.
    - à chaque tour : relit le créneau, calcule `heatsToRefresh`, relit leurs places, `mergeLanes`, met à jour `finishedReadAt` pour les courses `finished` relues. Un échec du créneau : `state = AsyncError(e, st)` (Riverpod 3 garde la valeur précédente).
    - `Future<void> refresh()` : relit tout (créneau et toutes les places).
  - `progressionExpandedProvider = NotifierProvider<ProgressionExpandedNotifier, bool>` — `true` au départ, `toggle()`. Pas d'`autoDispose` : l'état vaut pour la session.

- [ ] **Step 1 : tests purs** (`item_detail_refresh_test.dart`) : `heatsToRefresh` — course en cours toujours ; course terminée jamais relue → relue ; terminée relue il y a 1 min → non ; il y a 2 min → oui. `mergeLanes` — nouvelle valeur ; échec garde l'ancienne ; place devenue vide (valeur nulle) remplace ; non demandée intacte.
- [ ] **Step 2 : tests du fournisseur** (`fake_async`) : `'premier chargement : créneau puis toutes ses places'` ; `'toutes les places en échec au premier chargement : détail affiché sans nageurs'` ; `'au tour suivant, seules les places des courses non terminées sont relues'` ; `'une course qui passe à Terminé est relue une fois, puis toutes les 2 minutes'` ; `'une place en échec au rafraîchissement garde son nageur'` ; `'programme pas encore chargé : le détail l\'attend'` ; `'créneau absent du programme : erreur'` ; `'refresh relit tout'`.
- [ ] **Step 3–4** : échec, implémentation, vert. Commit : `feat(v2): détail d'un créneau — places relues selon l'état des courses`.

### Task 11 : libellés du programme

**Files:**
- Create: `lib/features/programme/programme_formatting.dart`
- Modify: `lib/core/l10n/app_fr.arb`, `lib/core/l10n/app_en.arb` (puis `flutter gen-l10n`)
- Test: `test/features/programme/programme_formatting_test.dart`

**Interfaces:**
- Produces (extensions prenant `AppLocalizations`, comme `competition_formatting.dart`) :
  - `ItemStatus.label(l10n)` : `live` → `liveBadge` (existe : « EN DIRECT »), `finished` → `statusFinished` « Terminé », `seriesPending` → `seriesPending` « Séries à venir », `upcoming` → `statusUpcoming` « À venir », `none` → `''`.
  - `String stageFormat(Stage s)` → `'${s.heatCount} × ${s.placesPerHeat}'`.
  - `String? qualificationText(Stage s, AppLocalizations l10n)` : byStage → `qualificationByStage` « Classement au temps, toutes séries confondues » ; byHeat avec places → `qualificationByHeat(n)` « Les {n} premiers de chaque série » ; byHeat sans places → `qualificationByHeatUnknown` « Qualification par série » ; none → nul.
  - `String collapsedProgression(Progression p, AppLocalizations l10n)` : première colonne puis le nombre d'étapes suivantes — ex. « Séries 10 × 8 › 3 finales » via `collapsedProgression(first, count)` ; une seule étape → son nom et son format.
  - `String? rankText(LaneAssignment lane)` → `'${rankLabel} · ${category}'`, `rankLabel` seul sans catégorie, nul sans `rankLabel`.
  - Clés fr/en en plus : `programmeTitle` « Programme », `programmeEmpty` « Programme pas encore publié », `programmeLoadError` « Impossible de charger le programme. », `itemLoadError` « Impossible de charger ce créneau. », `itemNotFound` « Ce créneau n'est plus au programme. », `noLanes` « Composition pas encore publiée », `recordBadge` « Record », `nationalRecordBadge` « Record de France », `chooseFinal` « Choisir la course », `progressionToggle` « Déroulement ».
- [ ] **Step 1–4** : tests (valeurs fr exactes ci-dessus, avec `lookupAppLocalizations(const Locale('fr'))`), échec, implémentation + ARB + `flutter gen-l10n`, vert. Commit : `feat(v2): libellés du programme et du détail`.

### Task 12 : onglet Programme

**Files:**
- Create: `lib/features/programme/programme_page.dart`, `widgets/day_tabs.dart`, `widgets/meeting_card.dart`, `widgets/item_row.dart`, `widgets/status_badge.dart`
- Modify: `lib/core/router/app_router.dart`, `lib/features/shell/tab_placeholders.dart` (`CompetitionTab.programme` ne sert plus au Programme)

**Interfaces:**
- Consumes: `currentCompetitionProvider`, `programmeProvider`, `selectedDayProvider`, `programmeDays`, `itemStatus`, formatage de la tâche 11.
- Produces: `Routes.programmeItem(int competitionId, int itemId)` → `'/programme/competition/$competitionId/creneau/$itemId'`, et la route enfant `competition/:competitionId/creneau/:itemId` sous `Routes.programme` (page de la tâche 13 ; jusque-là un `Placeholder` est accepté dans cette tâche seulement).

- [ ] **Step 1 : page** : sans compétition → le bloc « Choisir une compétition » du lot 1 (l'extraire de `tab_placeholders.dart` en widget réutilisable plutôt que le copier) ; en-tête « Programme » + nom de la compétition ; `DayTabs` (libellé court « Ven 27 » via `DateFormat('EEE d', locale)`) ; une `MeetingCard` par réunion du jour (nom, « 06:45 – 13:45 ») ; une `ItemRow` par créneau (heure, nom, `StatusBadge`, flèche ; grisé et non cliquable pour `ItemStatus.none`) ; toucher → `context.go(Routes.programmeItem(...))`. Erreurs comme `HomePage` : écran d'erreur + « Réessayer » au premier chargement, `SnackBar` `refreshFailed` sinon ; `RefreshIndicator` ; programme sans réunion → `programmeEmpty`. Bas de liste : `+ MediaQuery.of(context).viewPadding.bottom`.
- [ ] **Step 2 : `flutter analyze`, `flutter test`**, essai manuel sur Chrome contre la recette 1416 (réglage local non commité) : 3 onglets (27, 28, 29 mars) ; ouverture sur le 29 (dernier jour, compétition passée) ; « Pause » grisé et non cliquable ; « Série · 200m Obstacles Dames » le 27 avec le badge « Terminé ». Commit : `feat(v2): onglet Programme — jours, réunions, créneaux`.

### Task 13 : détail d'un créneau

**Files:**
- Create: `lib/features/programme/item_detail_page.dart`, `widgets/progression_strip.dart`, `widgets/heat_card.dart`, `widgets/lane_row.dart`
- Modify: `lib/core/router/app_router.dart` (brancher la page)

**Interfaces:**
- Consumes: `meetingItemDetailProvider`, `progressionExpandedProvider`, `progressionColumns`, `itemsOfStage`, `ActiveCompetitionNotifier.ensure`, formatage de la tâche 11.

- [ ] **Step 1 : page** (`ConsumerStatefulWidget`) : à l'ouverture, `ref.read(activeCompetitionProvider.notifier).ensure(competitionId)`. En-tête : fil « Programme · Sam 28 · Réunion 2 - Finales », `progression.disciplineName` + sexe (`genderFemale`…), nom du créneau et heure.
- [ ] **Step 2 : `ProgressionStrip`** : repliée → une ligne `collapsedProgression` ; dépliée → colonnes de `progressionColumns` (une colonne = cases empilées), séparées par « › », case de `stage` en jaune (`AppColors.yellow`), puis `qualificationText` de l'étape courante. Toucher l'en-tête → `toggle()`. Toucher une autre case → `itemsOfStage` dans le programme : 0 → rien ; 1 → `context.push(Routes.programmeItem(...))` ; plusieurs → feuille du bas `chooseFinal` listant nom et heure de chaque créneau. Pas de frise sans `progression` ou sans `stage`.
- [ ] **Step 3 : `HeatCard` / `LaneRow`** : une carte par course (nom, heure, badge de `RunStatus`), une ligne par `lanesOf(heat)` : couloir, athlètes (relais : club en titre, relayeurs dessous), club, catégorie ; si `performance` : `time` ou `statusLabel` quand `!isOk`, `rankText`, badges `recordBadge`/`nationalRecordBadge`. Course sans place lue → `noLanes`. Créneau dont aucune course n'a de `seriesId` → `seriesPending` à la place des cartes.
- [ ] **Step 4 : erreurs et rafraîchissement** comme l'onglet Programme ; `RefreshIndicator` → `notifier.refresh()` ; bas de liste avec `viewPadding.bottom`.
- [ ] **Step 5 : vérifications** `flutter analyze`, `flutter test`, essai manuel recette 1416 : créneau 177 (frise « Séries 10 × 8 › 3 finales », séries 1 et 2 avec temps et « 5ème · Cadet ») ; toucher « Finale - Cadet » → choix entre Finale B et Finale A. Commit : `feat(v2): détail d'un créneau — frise, séries, couloirs`.

### Task 14 : documentation et vérification finale

**Files:**
- Modify: `CLAUDE.md` (v2)

- [ ] **Step 1 :** dans « Architecture » / « API FFSS » : `getProgramme` (réunions + déroulements), le contournement « une requête par place, 6 en parallèle » et la condition pour le retirer (places complètes dans `creneau/:id`) ; le rang affiché est `rangLabel`, jamais calculé ; pas de badge de qualification faute de `complement`.
- [ ] **Step 2 :** `flutter analyze` (aucun problème), `flutter test` (tout vert), `dart format --output=none --set-exit-if-changed lib test` (aucun changement). Commit : `docs(v2): CLAUDE.md à jour du lot 2`.
