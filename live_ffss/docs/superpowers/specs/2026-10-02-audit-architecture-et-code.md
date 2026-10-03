# Audit de l'architecture et du code — état des lieux

**Date** : 2026-10-02
**État** : diagnostic, rien n'est corrigé par ce document
**Portée** : l'ensemble de `lib/` et de `test/`, la DI, le routage, la couche
réseau, les dépendances et la documentation du dépôt
**Méthode** : les 228 fichiers source hors codegen parcourus ; lus en entier les
quatre contrôleurs de plus de 500 lignes, `HttpClient`, `MeetingRepository`,
`MeetingRemoteDataSource`, `AuthRepository`, les cinq services, `InitialBinding`,
`app_pages.dart` et `app_config.dart`. Vérifié à la commande : `flutter analyze`
(aucune anomalie), `flutter test` (1171 tests verts), `flutter pub outdated`,
symétrie des deux fichiers de traduction (337 clés de chaque côté).

Les numéros (B1, A3, C2…) servent de référence courte ; ils ne valent pas un
ordre de traitement, lequel est donné par la priorisation en fin de document.

---

## Ce qui tient bien

Le socle est sain, et les problèmes relevés plus bas sont ceux d'un projet qui a
grandi vite, pas d'un projet mal parti :

- couches nettes `Controller → Repository → DataSource`, respectées sans
  exception ;
- injection par constructeur tenue partout sauf les deux dérogations déjà
  documentées (`ProfileController`, `UserController`) ;
- aucun `.tr`, `Get.snackbar`, `Get.dialog` ni `Get.context` hors du module auth ;
- exceptions typées, famille scellée `AppException`, et les replis best-effort
  sont explicités au lieu d'être subis ;
- DI en un point unique, codegen committé, 80 fichiers de tests sur les couches
  mappers / repositories / contrôleurs ;
- bascule d'environnement cloisonnée par préfixe de clé, rétro-compatible ;
- les commentaires expliquent le **pourquoi** des contournements FFSS — c'est
  rare, et c'est ce qui rend cet audit possible en une passe.

---

## 1. Bugs et incohérences fonctionnelles

### B1 — Saison et date de départ codées en dur, périmées

`lib/app/data/repositories/competition_repository.dart` (l. 25-26) :
`_defaultSeason = '2025-2026'` et `_defaultStartDate = '2025-09-29'`.

Nous sommes le 2 octobre 2026 : la saison 2026-2027 a commencé et la liste
d'accueil tire toujours depuis septembre 2025, donc elle grossit indéfiniment des
compétitions de la saison écoulée. À dériver de la date courante — la saison FFSS
court de septembre à août.

### B2 — Le paramètre `visibility` est accepté et jamais envoyé

`lib/app/data/datasources/competition_remote_datasource.dart` (l. 31-42)
construit la requête sans `visibility`, alors que `CompetitionRepository` et
`HomeController` le passent explicitement (`CompetitionVisibility.passed`). Le
filtre est un no-op silencieux.

Au passage, le code envoie `orderDirection` là où `docs/FFSS_API.md` annonce
`orderValue` — à confirmer au journal HTTP.

### B3 — Publication partielle de résultats sans aucun signal

`lib/app/data/repositories/meeting_repository.dart` (l. 427-437) :
`publishCourseResults` boucle sur `submitResult` et **jette** la valeur de retour
(0 = refusé). Une série dont trois résultats sur huit sont refusés remonte
`course_published` en vert.

C'est exactement le contrat que `createDefaultLanes` et `syncLanes` tiennent
— compter ce qui est passé et le rapporter — et que cette méthode oublie.

### B4 — `success: "false"` en chaîne passe pour un succès

`lib/app/core/network/http_client.dart` (l. 265) teste
`decoded['success'] == false`, alors que `docs/FFSS_API.md` §1 prévient que FFSS
renvoie parfois `"true"` / `"false"` en chaîne.

Même famille, côté datasources, où les quatre écritures ne se ressemblent pas :
`submitMeeting` et `submitSlot` vérifient `success != true` puis tolèrent un id
en chaîne via `int.tryParse` ; `submitLane`, `submitRun`, `submitHeat` et
`submitResult` ne vérifient rien et n'acceptent qu'un `int`. Un id rendu en
`"123"` ferait échouer une création réussie.

### B5 — Le démarrage à froid est bloqué par le réseau

`lib/main.dart` (l. 18) attend `InitialBinding.register()` avant `runApp`, qui
attend `UserService.init()` → `AuthRepository.restoreSession()` →
`probeSession()`, lui-même armé d'un timeout de 4 s
(`lib/app/data/repositories/auth_repository.dart`, l. 117-120).

Hors ligne ou sur réseau lent, l'écran reste noir jusqu'à 4 s plus le temps de
résolution DNS. La vérification de session doit tourner **après** `runApp`, en
fond, l'interface se corrigeant quand la réponse arrive.

### B6 — Écritures du programme non surveillées dans l'éditeur de structure

`lib/app/module/programme/controllers/structure_editor_controller.dart`
(l. 1104) : `_commit` appelle `_programme.save()` sans `await` ni `catchError`.

`RaceCourseController._persist` fait le même choix délibéré de ne pas attendre,
mais capte le `PlatformException` et déclenche `course_save_failed` ; ici l'erreur
part en *unhandled async error* et l'opérateur croit sa structure enregistrée.

Même défaut dans `UserPreferencesService.toggleFavorite` : deux bascules rapides
peuvent s'écraser, faute de la file d'écriture que `AttendanceService` et
`ProgrammeService` possèdent tous les deux.

### B7 — `allocateId()` lève si le programme n'est pas chargé

`lib/app/data/services/programme_service.dart` (l. 134) : `current.value!`. Tous
les appelants supposent qu'un `load()` a précédé, et rien ne le garantit — une
ouverture par argument qui ne passe pas par l'overview suffit.

### B8 — Deux `catch (_)` attrape-tout dans les contrôleurs

`lib/app/module/competitions/controllers/competition_detail_races_controller.dart`
(l. 145) et `lib/app/module/auth/controllers/profile_controller.dart` (l. 123)
avalent aussi les erreurs de programmation (`StateError`, `TypeError`), contre la
règle « catch `AppException`, laisse filer le reste ».

### B9 — Petites fuites et angles morts

- `AuthRepositoryImpl._userController` : `StreamController` jamais fermé.
- `LanguageService.changeLanguage` écrit dans le storage sans `await`.
- `HttpClient` capte `SocketException`, qui n'existe pas sur le web : le client
  `http` y lève `ClientException`, mappée en `UnknownException` au lieu de
  `NetworkException`, alors que `web/` est une cible déclarée.

---

## 2. Dette d'architecture

### A1 — Le secure storage sert de base de données

Le programme entier d'une compétition — structures, tirages, classements,
pénalités — est un blob JSON écrit dans `FlutterSecureStorage` sous
`programme_<id>` ; les présences suivent le même chemin, pour un maximum de 100
épreuves.

Le Keystore Android et le Keychain iOS sont faits pour des secrets de quelques
kilo-octets. Chaque `save()` rechiffre le blob entier, le Keychain plafonne et
ralentit, et `flutter_secure_storage` le déconseille explicitement. Le token et
le `user` y ont toute leur place ; le programme devrait vivre dans un fichier (ou
sqlite / hive) sous le même préfixe d'environnement.

C'est la dette la plus structurante du projet.

### A2 — Le programme local reste la source de vérité d'un système multi-appareils

La synchronisation avec FFSS est faite d'imports et de réconciliations par
heuristiques : `_importLevel` apparie par rang, `realignServerIds` répare les ids
pendants, `_adoptOrphanCourses` récupère les courses créées sur le site fédéral,
sans parler des cas « tirage sans `entryIds` » et « classement athlete-keyed
legacy ». Chaque cas réglé ajoute une branche à `RaceStructureController`.

À terme il faut inverser la charge : FFSS maître — parties, courses, places,
séries et résultats sont **tous** déjà lus et écrits —, le local réduit à ce que
FFSS ne porte pas (la présence, et un tirage encore en attente de pose). Ce n'est
pas un chantier d'un jour, mais chaque feature bâtie sur le blob local le rend
plus cher.

### A3 — Deux chemins concurrents vers l'arbre réunion

`MeetingService` existe pour être l'unique propriétaire de l'arbre. Pourtant
`race_course_controller.dart` (l. 677) et `heat_draw_controller.dart` (l. 447)
appellent directement `MeetingRepository.getMeetings`, soit un rechargement
complet — une requête plus une par créneau — à **chaque** validation de course et
à **chaque** sauvegarde de tirage, en court-circuitant le cache.

`RaceCourseBinding` et `HeatDrawBinding` n'injectent même pas `MeetingService`.

### A4 — Écritures multi-requêtes non transactionnelles

`MeetingEditorController._repack` envoie un `submitSlot` ou `submitRun` par item
déplacé, puis un `submitMeeting` ; `scheduleRound` enchaîne créneau → N courses →
N × places → relink local → reload → repack.

Un refus au milieu laisse la frise FFSS incohérente, et le code le sait (ses
commentaires l'écrivent). Sans transaction côté API, la seule parade est un
journal d'opérations rejouable, ou au minimum un état « réunion à recompacter »
visible à l'écran. Si l'on ne traite pas, il faut le documenter comme risque
assumé.

### A5 — Stubs orphelins maintenus en DI, dont trois sont désormais injustifiés

`ResultRepository`, `RankingRepository` et `ProgrammeRepository`, avec leurs
datasources, sont enregistrés `permanent` sans consommateur — à l'exception de
`CompetitionDetailPointsController`, qui lit des listes vides.

`ProgrammeRemoteDataSource.pushProgramme` est carrément **obsolète** : le
programme est serveur-backed via `MeetingRepository` depuis le 29 août.

Surtout, depuis l'arrivée de `docs/FFSS_API.md`, la justification « endpoints non
documentés » tombe pour trois chantiers :

| Besoin | Route documentée | Ce qui attend |
|---|---|---|
| Classements | `GET /competition/evenement/:id/participant/classement` et `/organisme/classement` (§4.2) | le stub `RankingRemoteDataSourceImpl` |
| Forfait d'un engagement | `POST /competition/engagement/:id/submit` avec `forfait` (§4.4) | `withdrawAthlete`, toujours `UnimplementedError` |
| Remplaçants de relais | `/competition/resultat/:id/remplacant/*` (§4.12) | `EntryGroupTile.onSubstitute`, inerte dans trois écrans |

`ApiEndpoints.competitionRanking` est par ailleurs une constante morte.

### A6 — Types de domaine définis dans la couche data

`CourseOutcome`, `CourseHeatLink` et `HeatResult` sont des `typedef` de records
déclarés dans `meeting_repository.dart` ; `LaneSeat` l'est dans
`lane_detail_mapper.dart`. Cinq contrôleurs importent donc un repository ou un
mapper pour obtenir un type. Même chose pour `parseGender` et `genderCode`, logés
dans `athlete_mapper.dart` et importés par trois contrôleurs.

Tout cela appartient à `lib/app/domain/models/`.

### A7 — Arguments de route non typés

Quatorze contrôleurs lisent `Get.arguments` comme une `Map` à clés chaînes
(`arg['race']`, `arg['heatId']`, `arg['programmeRaceId']`…). Seul
`StructureEditorArgs` est typé.

Une clé mal orthographiée côté vue donne un écran vide, sans erreur et sans
trace. Une classe `XArgs` par route, sur le modèle de l'éditeur de structure,
ferait du compilateur le garde-fou.

---

## 3. Dette de code

### C1 — Deux contrôleurs de 900 lignes qui font le travail d'un service

`RaceStructureController` (902 l.) mêle affichage, filtre, import des
compositions, adoption des courses orphelines, lecture des résultats serveur et
réalignement des ids. `RaceCourseController` (904 l.) mêle saisie, scan NFC,
lecture-retour FFSS, publication, qualification et **re-tirage du tour suivant**
— `_seedNextRound` duplique la logique de `HeatDrawController`.

Le code de synchronisation (`_importLevel`, `_adoptOrphanCourses`,
`_seedStructuresFromServer`, `_seedNextRound`) est de la logique métier testable
sans GetX. Il appartient à un `ProgrammeSyncService`, ou à des fonctions pures
dans `domain/models/` — ce que `meeting_timetable.dart` a déjà démontré.

### C2 — Quatre copies de « patcher les athlètes avec leur club »

Dans `race_course_controller.dart` (l. 174-190),
`race_structure_controller.dart` (l. 442-458), `heat_draw_controller.dart`
(l. 236-246) et `race_detail_controller.dart` (l. 158).

Le repository devrait exposer `getEntriesWithClubs(raceId, competitionId)`. Le
commentaire « Entries arrive with no club on their athletes — the mappers never
set one » revient comme un refrain : c'est le signe que l'abstraction manque.

### C3 — Cinq copies de « trouver la structure (raceId, categoryId) »

`_storedRace` / `_isOtherStructure` / `_structure` (race_course), `structure`
(heat_draw), `_stored` (structure_editor), `_structureFor` (programme),
`_structuresOf` (race_structure).

Un `CompetitionProgramme.structureFor(raceId, categoryId)` et un
`withStructure(...)` sur le modèle freezed suppriment une petite centaine de
lignes, dont les `copyWith` imbriqués sur quatre niveaux que `_persist` doit
écrire aujourd'hui.

### C4 — Les contrôleurs d'auth contredisent toutes les règles

`ProfileController` et `UserController` : `Get.find` en champ au lieu d'un
constructeur, `.tr` vingt-deux fois, `Get.snackbar` deux fois, un `catch (_)`.

C'est connu et différé. Il faut noter qu'ils sont aussi les **deux seuls
contrôleurs sans test**, ce qui n'est pas une coïncidence.

### C5 — Divers

- `HttpClient.post` porte un paramètre `body` que personne n'utilise : tous les
  POST passent leurs données en query string. Le token et la description d'une
  réunion voyagent donc dans l'URL — donc dans les logs serveur et les proxies —
  et la longueur d'URL devient un plafond, là où la documentation FFSS attend un
  corps de formulaire.
- Les commentaires de `InitialBinding` sont numérotés 1, 2, 3, 3b, 4, 5, 6, 7,
  7b, 5d, 5d bis, 5e… l'ordre réel ne suit plus les numéros.
- Commentaires et docstrings mi-français mi-anglais, parfois dans la même
  fonction.
- La clé de traduction `visibility` est probablement orpheline (les cinq
  `round_*_one` sont, elles, construites à l'exécution).

---

## 4. Dette de tests

**Non testés** : `ProfileController`, `UserController`, `UserService`,
`LanguageService`, `AppRestart`, `AuthRemoteDataSource`, `ClubRemoteDataSource`,
`RaceRemoteDataSource`, `discipline_mapper`, `race_format_configuration_mapper`,
`slot_mapper`.

**Cas manquants** dans ce qui existe : `success: "false"` et id en chaîne (B4),
`visibility` effectivement envoyé (B2), résultat refusé compté (B3), structure
sans `allocateId` possible (B7).

**Incohérence de rangement** : les modèles vivent dans `lib/app/domain/models/`
mais leurs tests dans `test/data/models/`, alors que `CLAUDE.md` demande de
refléter les chemins source.

**Pas de CI** : aucun `.github/workflows`, donc `analyze` et `test` ne tournent
que quand on y pense. Le hook `safe_area_check.py` est une bonne idée, mais il
n'a pas de test et n'est pas versionné — `.claude/` est dans le `.gitignore`.

---

## 5. Dette de dépendances et d'outillage

| Paquet | Actuel | Dernier | Note |
|---|---|---|---|
| `flutter_lints` | 3.0 | 6.0 | deux majeures de règles manquées |
| `freezed` / `freezed_annotation` | 2.5 / 2.4 | 4.0 / 3.1 | la 3.x change la syntaxe (`sealed`, `abstract`) ; diff massif sur 100+ fichiers générés |
| `flutter_secure_storage` | 9.2 | 11.2 | `flutter_secure_storage_macos` est discontinué dans la version actuelle |
| `json_serializable` / `build_runner` | 6.9 / 2.5 | 6.14 / 2.16 | `build_runner_core` et `build_resolvers` discontinués |
| `get` | 4.6.6 | — | GetX 5 au point mort depuis deux ans : risque stratégique à garder en tête, pas à traiter maintenant |

À quoi s'ajoutent :

- `environment.sdk: '>=3.4.3 <4.0.0'` ne reflète pas le SDK réellement utilisé
  (Dart 3.11 / Flutter 3.41) ;
- `model.txt` et `firebase.json` sont versionnés alors que rien ne les utilise ;
- deux dossiers parasites et vides à la racine, nommés
  `C:Usersnast0GitLiveFFSSlive_ffsstestcorenetwork` et
  `…live_ffsstestdatamappers` — des chemins Windows mal joints ;
- `.claude/settings.json` empile une quarantaine de permissions redondantes, les
  chemins complets vers `flutter.bat` étant devenus inutiles depuis que le PATH
  utilisateur les expose.

---

## 6. Dette documentaire

- `CLAUDE.md` affirme encore que les endpoints de classement ne sont pas
  documentés, que celui de `withdrawAthlete` est à déterminer et que la
  substitution de relais attend une confirmation : `docs/FFSS_API.md` documente
  les trois. La section « Known gaps » est à relire ligne par ligne contre la
  documentation.
- Le doute sur la troncature de `getEntries` à 30 lignes est probablement levé :
  la documentation donne `ListResponse<Engagement>` avec le seul paramètre
  `epreuve`, hors forme DataTables. À confirmer au journal HTTP, puis à retirer
  des gaps.
- `README.md` n'a pas été relu dans cette passe.

---

## Priorisation

Score = (Impact + Risque) × (6 − Effort), chaque critère noté sur 5.

| # | Item | Impact | Risque | Effort | Score |
|---|---|---|---|---|---|
| B1 | Saison et date en dur | 4 | 5 | 1 | **45** |
| B3 | Résultats refusés non comptés | 4 | 5 | 1 | **45** |
| B2 | `visibility` jamais envoyé | 3 | 3 | 1 | **30** |
| B4 | `success` et id en chaîne | 3 | 3 | 1 | **30** |
| B6 | `_commit` sans `catchError` | 3 | 3 | 1 | **30** |
| A3 | `getMeetings` direct → `MeetingService` | 4 | 3 | 2 | **28** |
| B5 | Probe réseau avant `runApp` | 4 | 3 | 2 | **28** |
| — | CI plus tests manquants | 3 | 4 | 2 | **28** |
| §6 | `CLAUDE.md` contre `FFSS_API.md` | 2 | 3 | 1 | **25** |
| A5 | Stubs obsolètes → endpoints réels | 3 | 2 | 2 | 20 |
| C2 | `getEntriesWithClubs` | 3 | 2 | 2 | 20 |
| C3 | `structureFor` sur le modèle | 3 | 2 | 2 | 20 |
| A7 | Arguments de route typés | 2 | 3 | 2 | 20 |
| A1 | Sortir le programme du secure storage | 4 | 4 | 4 | 16 |
| — | `flutter_lints` 6, `secure_storage` 11 | 2 | 2 | 2 | 16 |
| C1 | Découper les deux gros contrôleurs | 4 | 3 | 4 | 14 |
| C4 | Contrôleurs d'auth | 2 | 2 | 3 | 12 |
| A2 | FFSS source de vérité | 5 | 4 | 5 | 9 |
| A4 | Écritures non transactionnelles | 3 | 4 | 5 | 7 |
| — | `freezed` 3 ou 4 | 1 | 2 | 4 | 6 |

---

## Plan de remédiation

### Phase 1 — une demi-journée, avant toute nouvelle feature

B1, B2, B3, B4, B6, B7, B8, la suppression des fichiers parasites, et la
relecture des « Known gaps » contre `docs/FFSS_API.md`. Chaque item est un commit
d'une dizaine de lignes accompagné de son test.

B1 est le plus urgent : la liste d'accueil se dégrade un peu plus chaque jour.

### Phase 2 — un à deux jours, en parallèle des features

A3 — injecter `MeetingService` dans `RaceCourseController` et
`HeatDrawController`, supprimer les `getMeetings` directs. B5 — déplacer la
vérification de session après `runApp`. C2 et C3 — deux extractions qui allègent
immédiatement les quatre gros contrôleurs. A5 — supprimer
`ProgrammeRemoteDataSource`, brancher le classement et le forfait sur les vraies
routes. Plus une CI GitHub Actions (`analyze` et `test`) et `flutter_lints` 6.

### Phase 3 — au fil de l'eau, une feature à la fois

A7 : typer les arguments à chaque fois qu'on touche une route. C4 : nettoyer les
contrôleurs d'auth quand on touche leurs vues, comme `CLAUDE.md` le prévoit
déjà. C1 : extraire la synchronisation dans un service **la prochaine fois qu'on
y ajoute une branche**, pas avant. Puis A6, et la montée de
`flutter_secure_storage`.

### Phase 4 — à décider explicitement

A1 et A2 sont liés : sortir le programme du secure storage est l'occasion de
réduire ce qu'on y stocke. Cela mérite son propre design dans
`docs/superpowers/specs/`, et une décision sur ce que FFSS doit porter seul. A4
se traite dans le même mouvement, ou se documente comme risque accepté. La montée
de `freezed` et la question GetX attendent un créneau calme.
