# Lot 5 — Résultats, classements, recherche : plan d'implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** remplir l'onglet Résultats : classement de chaque épreuve, classements club et licenciés provisoires, recherche d'un athlète avec ses courses nagées et à venir.

**Architecture:** l'app lit les épreuves (`competition/epreuve?evenement=`), les séries de chaque épreuve (`competition/serie?epreuve=`) et les participants ; elle rattache chaque série à une course du programme (lot 2), puis calcule rangs, points et cumuls par des fonctions pures du domaine reprises de V3. Fournisseurs Riverpod par compétition, rafraîchissement manuel.

**Tech Stack:** Flutter 3.47.7 / Dart 3.13.5, flutter_riverpod 3.4, go_router 18, freezed 4, json_serializable, mocktail, fake_async, gen-l10n.

**Spec:** `live_ffss.v2/docs/specs/2026-10-18-lot5-resultats-design.md`

## Global Constraints

- Règles de `live_ffss.v2/CLAUDE.md` : `features` → `data` → `domain` ; `strict-casts`, `strict-raw-types` ; pas de `fromJson` écrit à la main ; DTO tout nullable, mapper qui écarte une ligne illisible (`null`), `TypeError` d'une ligne écartée seule ; `clockProvider`, jamais `DateTime.now()` ; `retry: noRetry` ; `ref.mounted` après chaque `await` ; `AppException` seulement ; pas de test de widget ; page sans logique testable ; commentaires qui disent pourquoi.
- **Eau plate seulement** : compétition sans `Discipline.flatWater` → `l10n.coastalComingSoon` (comme `live_page.dart`).
- **Lecture seule**, aucun appel d'écriture. **Aucun agent n'appelle le serveur FFSS** : tout se teste sur les fixtures `test/fixtures/recette_1416/` (`serie_epreuve_36073`, `serie_epreuve_36074`, `serie_epreuve_36087`, `epreuves_1416`, `participants_1416`, `deroulement`, `reunion`), chargées par `fixture(name)` (`test/support/fixtures.dart`).
- **Données personnelles** : ne jamais lire `Licencie`, e-mail, date de naissance, année, numéro de licence ; fixtures pseudonymisées (`ATHLETE N001`…) — ne pas en ajouter d'autres sans pseudonymiser.
- Barème V3 : **20, 18, 16, 14, 13, 12, 11, 10, 8, 7, 6, 5, 4, 3, 2, 1**, 0 au-delà. Par club, **3** résultats individuels et **1** relais par épreuve. Étrangers et invités marquent des points.
- Lecture des séries : **6 requêtes au plus en vol** ; rafraîchissement **manuel** seulement (pas de minuterie).
- Traductions : `app_fr.arb` de référence, `app_en.arb` mêmes clés et mêmes blocs `@`, pas de clé morte ; `flutter gen-l10n`. « Eau plate », jamais « Piscine ».
- Bas de liste défilante : `+ MediaQuery.of(context).viewPadding.bottom`.
- Avant chaque commit, depuis `live_ffss.v2/` : `flutter analyze` propre, `flutter test` vert, `dart format lib test` sans changement. Après `build_runner`, revenir sur les fichiers générés modifiés seulement par les fins de ligne. Commits en français (`feat(v2):`, `test(v2):`, `docs(v2):`) avec la ligne `Co-Authored-By` du modèle. Ne jamais pousser ni changer de branche (`feat/v2-lot5-resultats`) ; ne pas toucher `live_ffss/`.

## Review Focus

1. **Catégories nagées ensemble** : une course du programme ne pointe que vers la série d'une catégorie ; les séries Junior (fixture 36074) doivent quand même se rattacher aux mêmes courses (par numéro et heure) → test en Task 3.
2. **Anciennes séries** (fixture 36073 : 12 séries `Debut` nul, finales d'avril) : jamais comptées → test en Task 3 (rien de rattaché) et Task 6 (classement d'épreuve sans doublon).
3. **Épreuve dont une lecture échoue** pendant le calcul club/licenciés : le classement s'affiche avec ce qui est lu et se dit incomplet, il n'échoue pas → test en Task 6.
4. **Ex æquo et non classés** (même temps, DQ en finale, FF avec temps, HT) : rangs 1, 2, 2, 4 et ordre V3 des non classés → tests en Task 4.
5. **Recherche** avec accents, casse, « nom prénom » inversé, chaîne vide → tests en Task 7.

---

### Task 1 : DTO, mappers et repository des résultats

**Files:**
- Create: `lib/data/ffss/dtos/epreuve_dto.dart`, `lib/data/ffss/dtos/serie_results_dto.dart`, `lib/data/ffss/dtos/participant_dto.dart`, `lib/data/ffss/mappers/results_mapper.dart`, `lib/data/repositories/results_repository.dart`, `lib/domain/event_results.dart`
- Modify: `lib/core/config/app_config.dart` (endpoints `eventList = 'competition/epreuve'`, `eventSeries = 'competition/serie'`, `participants = 'competition/evenement/:id/participants'`)
- Test: `test/data/ffss/mappers/results_mapper_test.dart`, `test/data/repositories/results_repository_test.dart`

**Interfaces — Produces** (`lib/domain/event_results.dart`, freezed, sans JSON) :
- `CompetitionEvent { int id; int disciplineId; String disciplineName; Gender gender; int categoryId; String categoryName; int teamSize; bool get isRelay => teamSize > 1; }` — une épreuve = une catégorie (la première de `categories`).
- `ResultAthlete { int id; String name; Gender? gender; String club; String? nationality; bool isGuest; }`
- `EventResult { int id; int entryId; int eventId; String categoryName; int status; int? time; String complement; String club; List<ResultAthlete> athletes; }` — `time` en centièmes, `null` si absent ou ≤ 0 ; `club` = club du **premier athlète**, sinon celui de l'engagement ; `complement` `''` si nul.
- `EventSeries { int id; int eventId; int number; String name; DateTime? start; List<EventResult> results; }`
- `ParticipantEntry { int entryId; int eventId; String categoryName; }`
- `Participant { int id; String firstName; String lastName; Gender? gender; String club; bool isGuest; List<ParticipantEntry> entries; }`
- `abstract class ResultsRepository { Future<List<CompetitionEvent>> getEvents(int competitionId); Future<List<EventSeries>> getEventSeries(int eventId); Future<List<Participant>> getParticipants(int competitionId); }` + `ResultsRepositoryImpl(HttpClient)` + `resultsRepositoryProvider`.
- Requêtes : `getEvents` → `get('competition/epreuve', query: {'evenement': id})` ; `getEventSeries` → `get('competition/serie', query: {'epreuve': id})` ; `getParticipants` → `get('competition/evenement/:id/participants')`. Lecture de `data` (liste) ; une ligne non-objet ou qui lève `TypeError` est écartée seule.
- DTO : noms JSON exacts des fixtures (`Id`, `IdDiscipline`, `Genre`, `discipline.label`, `discipline.NbAthleteParEquipe`, `categories[].Id/Nom`, `Numero`, `Nom`, `Debut` `"yyyy-MM-dd HH:mm:ss"` heure locale, `resultats[]`, `Statut`, `Temps`, `complement`, `Athletes[] {Id, label, sexe, clubLabel, nationaliteCode, isInvite}`, `engagement {Id, IdEpreuve, categorie.Nom, clubLabel}`, participants `Id, Prenom, Nom, Sexe, clubLabel, isInvite, engagements[] {id, categorie.label, epreuve.Id}`) ; `readInt` pour les nombres servis en chaîne. Aucun champ `Licencie`, `annee`, `dossard`, `NumeroLicence`.

- [ ] **Step 1 : tests de mapper** sur les fixtures : `epreuves_1416` → 60 épreuves, 36073 = `200m Obstacles` (`disciplineName` du libellé), `Gender.female`, `Cadet`, `teamSize` 1 ; 36087 `isRelay` vrai. `serie_epreuve_36073` → 22 séries, la série 94894 : `number` 1, `start` 2026-03-27 08:00, 5 résultats, le premier `time` 16330, `status` 0, `categoryName` `Cadet`. `serie_epreuve_36087` : résultats à 4 athlètes. Un résultat sans engagement ou sans id est écarté ; `Temps` 0 → `time` null. `participants_1416` → 19 participants, chacun avec ses engagements (`eventId`).
- [ ] **Step 2 : tests de repository** (mocktail sur `HttpClient`) : paramètres de requête exacts ; une ligne `TypeError` écartée sans faire échouer la liste ; `AppException` propagée.
- [ ] **Step 3 :** implémenter, `dart run build_runner build --delete-conflicting-outputs`, analyze/test/format.
- [ ] **Step 4 : commit** `feat(v2): lecture des épreuves, de leurs séries et des participants`.

### Task 2 : épreuve ↔ déroulement (discipline et catégories)

**Files:**
- Modify: `lib/data/ffss/dtos/deroulement_dto.dart` (lire `IdDiscipline` et `categories[].Nom`), `lib/data/ffss/mappers/deroulement_mapper.dart`, `lib/domain/progression.dart`
- Test: `test/data/ffss/mappers/deroulement_mapper_test.dart`, `test/domain/event_results_test.dart`

**Interfaces — Produces :**
- `Progression` gagne `int? disciplineId` et `List<String> categories` (défaut `[]`).
- `Progression? progressionOfEvent(List<Progression> progressions, CompetitionEvent event)` dans `lib/domain/event_results.dart` : même `disciplineId`, même `gender`, `categories` contenant `event.categoryName` ; `null` sinon.

- [ ] **Step 1 : tests** : fixture `deroulement` → progression 501 : `disciplineId` 24, `categories` `['Cadet', 'Junior', 'Seniors et Masters']` ; `progressionOfEvent` relie 36073 (24, F, Cadet) et 36074 (Junior) à 501, rend `null` pour une catégorie absente ou un autre genre.
- [ ] **Step 2 :** implémenter, build_runner, vérifications.
- [ ] **Step 3 : commit** `feat(v2): le déroulement porte sa discipline et ses catégories`.

### Task 3 : rattacher les séries d'une épreuve aux courses du programme

**Files:**
- Create: `lib/domain/series_link.dart`
- Test: `test/domain/series_link_test.dart`

**Interfaces — Consumes :** `Programme` (`meetings`, `progressions`, `MeetingItem.roundId`, `Stage.level`, `Heat.number/plannedStart/name/status/resultsProvisional`), `progressionOfEvent`, `isProvisional(Heat)`.
**Produces :**
- `enum EventRound { heats, finalA, finalB }`
- `LinkedSeries { EventSeries series; Heat heat; EventRound round; }` (freezed) avec `bool get provisional => isProvisional(heat)` et `bool get finished => heat.status == RunStatus.finished`.
- `List<LinkedSeries> linkSeries(Programme programme, CompetitionEvent event, List<EventSeries> series)`

**Règle** (spec § 3) : progression = `progressionOfEvent` ; courses candidates = heats des items dont `roundId` est un stage de cette progression ; tour = `Stage.level` (`heats` → `EventRound.heats` ; `finalStage` → `finalB` si le nom de la course contient « Finale B », sinon `finalA`) ; une série se rattache à la course de **même numéro** (`series.number == heat.number`) **dans le même tour** dont `plannedStart` est à **5 min au plus** de `series.start` ; si `series.start` est nul → **ignorée** ; si `heat.plannedStart` est nul → numéro seul, tour séries seulement. Une course ne prend qu'une série par épreuve. Les séries non rattachées sont **ignorées**.

- [ ] **Step 1 : tests** sur fixtures réelles (`reunion` + `deroulement` passés par les mappers existants et `withRaces`, + `serie_epreuve_36073/36074` par le mapper de Task 1) : 36073 → exactement les séries du programme d'octobre (aucune des 12 d'avril, `Debut` nul), chacune sur la course de même numéro, tour `heats` ; 36074 (Junior, absente de `reunion`) se rattache aux **mêmes courses** par numéro et heure. Tests construits : finale A / finale B reconnues au nom de course ; écart de 6 min → non rattachée ; série sans `start` ignorée.
- [ ] **Step 2 :** implémenter, vérifications.
- [ ] **Step 3 : commit** `feat(v2): séries d'une épreuve rattachées aux courses du programme`.

### Task 4 : classement d'une épreuve et points (règles V3)

**Files:**
- Create: `lib/domain/event_ranking.dart`
- Test: `test/domain/event_ranking_test.dart`

**Interfaces — Consumes :** `LinkedSeries`, `EventResult`, `EventRound`. **Produces :**
- `const pointScale = [20, 18, 16, 14, 13, 12, 11, 10, 8, 7, 6, 5, 4, 3, 2, 1];` et `int pointsFor(int rank)` (0 au-delà).
- `enum Qualification { none, finalA, finalB }`
- `RankingRow { EventResult result; int? rank; int points; Qualification qualification; int seriesNumber; EventRound round; }` — `rank` nul = non classé.
- `EventRanking { CompetitionEvent event; List<RankingRow> rows; int finishedSeries; int totalSeries; bool provisional; }`
- `EventRanking rankEvent(CompetitionEvent event, List<LinkedSeries> series)`
- `int? heatPlace(EventResult result, List<EventResult> heatResults)` (place dans la série, même règle de classés et d'égalités).

**Règles** (spec § 5, V3 `FlatWaterRanking.cs`, `RacePoints.cs`) :
- classé : `status == 0` et `time != null`, complément ≠ `HT` ; `FF` avec temps classé en série mais jamais finaliste ni qualifié ;
- sans finale rattachée : rang au temps, toutes séries ; avec finales : A rangs 1…, B à partir de `places + 1` (`places` = nombre de couloirs pris = 8), puis les non-finalistes (entrée absente des finales) au temps des séries, décalés de `places × nombre de finales non vides` ; une DQ en finale prend la dernière place de sa finale (8 en A, 16 en B) ;
- égalités : même temps → même rang, suivant sauté ; ordre d'affichage des ex æquo : numéro de série puis id de résultat ;
- non classés en bas : FF sans temps, HT, DQ, F, autres ;
- points : `pointsFor(rank)` ; avec finales A **et** B les séries ne marquent rien ; finale A seule : les non-finalistes prennent les rangs 9-16 au temps des séries et marquent ; sans finale, les séries marquent ; non classé 0 ;
- qualification : `QFA`/`QFB` du résultat de série, sinon présence en finale A/B ;
- `totalSeries` = séries rattachées, `finishedSeries` = celles dont la course est `finished` ; `provisional` = une série rattachée `provisional`, ou aucune.

- [ ] **Step 1 : tests** : sans finale (rangs, égalité 1, 2, 2, 4, points 20, 18, 18, 14) ; avec A et B (A 1-8, B 9-16, reste 17+, séries à 0 point) ; finale A seule (non-finalistes 9-16 marquent) ; DQ en finale A → 8 ; FF avec temps classé non qualifié ; ordre des non classés ; qualification depuis `QFA` ; fixture 36073 rattachée (Task 3) → aucun doublon d'engagement ; `heatPlace`.
- [ ] **Step 2 :** implémenter, vérifications.
- [ ] **Step 3 : commit** `feat(v2): classement d'une épreuve selon les règles de V3`.

### Task 5 : classements club et licenciés

**Files:**
- Create: `lib/domain/standings.dart`
- Test: `test/domain/standings_test.dart`

**Interfaces — Produces :**
- `ClubStanding { int rank; String club; int points; int? gapToPrevious; }`
- `LicenseeStanding { int rank; int athleteId; String name; String club; Gender gender; String categoryName; int points; int races; }`
- `List<ClubStanding> clubStandings(List<EventRanking> rankings, {int individualCounted = 3, int relayCounted = 1})`
- `List<LicenseeStanding> licenseeStandings(List<EventRanking> rankings)`

**Règles** (V3 `Standings.cs`) : club d'une ligne = `result.club` ; par (club, épreuve) seuls comptent les `individualCounted` meilleurs individuels ou les `relayCounted` meilleurs relais (points décroissants puis rang) ; total = somme ; clubs à 0 point inclus s'ils ont un résultat ; égalités 1, 1, 3, puis ordre alphabétique ; `gapToPrevious` = points du précédent − points (nul pour le premier). Licenciés : épreuves individuelles seulement, par (sexe de l'athlète, catégorie), somme des points et nombre de courses (lignes de classement de l'athlète), égalités 1, 1, 3 puis nom ; un athlète sans sexe est écarté.

- [ ] **Step 1 : tests** : 4 résultats d'un club dans une épreuve → 3 comptent ; 2 relais → 1 compte ; égalité 1, 1, 3 et ordre alphabétique ; écart au précédent ; licenciés séparés par sexe et catégorie, relais exclus.
- [ ] **Step 2 :** implémenter, vérifications.
- [ ] **Step 3 : commit** `feat(v2): classements des clubs et des licenciés (provisoires)`.

### Task 6 : fournisseurs des résultats

**Files:**
- Create: `lib/features/results/results_providers.dart`
- Test: `test/features/results/results_providers_test.dart`

**Interfaces — Consumes :** `resultsRepositoryProvider`, `programmeProvider(competitionId)` (lu par `ref.read(...future)`, pas observé), `linkSeries`, `rankEvent`, `clubStandings`, `licenseeStandings`, `clockProvider`. **Produces :**
- `eventsProvider` : `FutureProvider.autoDispose.family<List<CompetitionEvent>, int>` — épreuves eau plate de la compétition (`discipline.Specialite` 2 ; ordre : ordre du programme des progressions, puis id).
- `eventRankingProvider` : `FutureProvider.autoDispose.family<EventRanking, ({int competitionId, int eventId})>` — lit les séries de l'épreuve, rattache, classe.
- `standingsProvider` : `AsyncNotifierProvider.autoDispose.family<StandingsNotifier, Standings, int>` avec `Standings { List<ClubStanding> clubs; List<LicenseeStanding> licensees; int finishedSeries; int totalSeries; int failedEvents; DateTime computedAt; }` — lit les séries de **toutes** les épreuves, 6 au plus en vol ; une épreuve en échec (`AppException`) est comptée dans `failedEvents` et omise ; `refresh()` relit tout ; `ref.mounted` après chaque `await`.
- `resultsSelectionProvider` : `NotifierProvider.autoDispose.family<…, ({int? eventId}), int>` — épreuve choisie (par défaut la première épreuve de la liste) ; gardée tant que l'onglet vit.

- [ ] **Step 1 : tests** (mocktail, `retry: noRetry`) : `eventRankingProvider` sur fixtures → classement sans doublon ; `standingsProvider` : au plus 6 lectures simultanées (compteur dans le mock), une épreuve qui lève `NetworkException` → `failedEvents` 1, le reste calculé ; `refresh()` relit ; aucune minuterie (`fake_async` : rien après 5 min) ; `computedAt` = horloge simulée.
- [ ] **Step 2 :** implémenter, vérifications.
- [ ] **Step 3 : commit** `feat(v2): fournisseurs des résultats et des classements`.

### Task 7 : recherche d'athlète, fiche, « Trouver sa série »

**Files:**
- Create: `lib/domain/athlete_search.dart`, `lib/features/results/athlete_providers.dart`
- Test: `test/domain/athlete_search_test.dart`, `test/features/results/athlete_providers_test.dart`

**Interfaces — Produces :**
- `String foldForSearch(String s)` (minuscules, sans accents) ; `List<Participant> searchParticipants(List<Participant> all, String query)` : vide si la requête (repliée, rognée) fait moins de 2 caractères ; correspondance sur prénom, nom, « prénom nom », « nom prénom » ; tri par nom puis prénom.
- `participantsProvider` : `FutureProvider.autoDispose.family<List<Participant>, int>` (lu une fois tant que la recherche vit).
- `AthleteRace { CompetitionEvent event; ParticipantEntry entry; LinkedSeries? series; RankingRow? row; int? heatPlace; DateTime? plannedStart; }` — `series`/`row` nuls = à courir.
- `athleteCardProvider` : `FutureProvider.autoDispose.family<List<AthleteRace>, ({int competitionId, int participantId})>` — pour chaque engagement, le classement de son épreuve (`eventRankingProvider`) ; courues d'abord (ordre du programme), puis à courir avec `plannedStart` = première course du tour séries de l'épreuve.
- `laneFinderProvider` : `FutureProvider.autoDispose.family<LaneFound?, ({int competitionId, int eventId, int entryId})>` avec `LaneFound { Heat heat; int lane; }` — parcourt les courses du tour séries de l'épreuve **non terminées**, dans l'ordre, lit leurs places par `MeetingRepository.getLanes(heat.placeIds)` **course par course**, s'arrête à la première place dont `entryId` correspond ; `null` si aucune.

- [ ] **Step 1 : tests** : recherche (accent « é », casse, ordre inversé, 1 caractère → vide) ; fiche sur fixtures (un athlète de 36073 → course courue avec rang et place, une épreuve sans résultat → à courir) ; « Trouver sa série » : s'arrête à la première course trouvée (vérifier qu'aucune course suivante n'est lue), `null` si absent, courses terminées sautées.
- [ ] **Step 2 :** implémenter, vérifications.
- [ ] **Step 3 : commit** `feat(v2): recherche d'un athlète et sa fiche`.

### Task 8 : pages de l'onglet Résultats

**Files:**
- Create: `lib/features/results/results_page.dart`, `lib/features/results/athlete_search_page.dart`, `lib/features/results/athlete_page.dart`, `lib/features/results/results_formatting.dart`, `lib/features/results/widgets/…`
- Modify: `lib/core/router/app_router.dart` (route `Routes.results` → `ResultsPage` ; enfants `recherche` et `athlete/:participantId` sous la branche Résultats, avec la compétition en paramètre comme `Routes.programmeItem`), `lib/features/shell/tab_placeholders.dart` (retirer le cas `results` s'il devient mort), ARB fr/en
- Test: `test/features/results/results_formatting_test.dart`, `test/core/router/app_router_test.dart`

**Contenu** (spec § 4) : en-tête avec loupe ; sans compétition → `ChooseCompetitionPrompt` ; côtier seul → `coastalComingSoon` ; sous-onglets Épreuves / Classements en `ChoiceChip` (comme `DayTabs`) ; Épreuves : liste déroulante d'épreuves par discipline · genre puis puces de catégorie, en-tête « CLASSEMENT PROVISOIRE · CADET » / « CLASSEMENT · CADET » + « n/N séries », lignes rang / athlète(s) / club / temps (`hundredthsLabel`) / badge FA-FB, non classés en bas (DQ rouge avec son code sur la même ligne, comme au lot 2), texte d'attente si vide, toucher → fiche ; Classements : puces Clubs / Licenciés, podium + liste avec écart, pied « Provisoire · n / N séries terminées · calculé à HH:MM » et mention si des épreuves n'ont pu être lues ; licenciés : puces sexe et catégorie ; recherche : champ, résultats au fil de la frappe ; fiche : Courues / À courir, bouton « Trouver sa série » → « Série n · ligne l » ou « Pas encore placé ». Geste tirer + bouton Rafraîchir. Toute décision d'affichage testable dans `results_formatting.dart` (libellés d'en-tête, de rang, de non classé, de pied, d'écart).

- [ ] **Step 1 : tests** de `results_formatting.dart` et du routeur (routes de recherche et de fiche, lien illisible redirigé vers `Routes.results`).
- [ ] **Step 2 :** implémenter pages, routes, clés ARB, `flutter gen-l10n`, vérifications (clés fr/en identiques, pas de clé morte).
- [ ] **Step 3 : commit** `feat(v2): onglet Résultats`.

### Task 9 : documentation

- [ ] `live_ffss.v2/CLAUDE.md` : section Résultats (sources, rattachement série ↔ course, règles V3 reprises, classements provisoires, réglages par défaut, coût réseau, « Trouver sa série ») ; lacunes connues (une série par course dans `reunion`, classements de l'API non lus, relais de 1416 hors programme). `docs/FFSS_API_CONTRACT.md` : faits vérifiés le 2026-10-18 (forme de `serie?epreuve=`, `epreuve?evenement=`, `participants`, `Rang` de V3 = place dans la série, pas de points, données personnelles servies par `serie?epreuve=`). Commit `docs(v2): CLAUDE.md à jour du lot 5`.
