# Lot 6a — Mon espace (lecture) : plan d'implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** un onglet Mon espace par rôle sur la compétition active (athlète, club, officiel, admin, tout le monde), avec suivis locaux, infos, officiels, préférences et rappels locaux sur Android.

**Architecture:** les rôles détaillés de `evenement/:id/me` deviennent un objet de domaine ; chaque espace est une page alimentée par des fournisseurs qui réutilisent le lot 5 (participants, fiche d'athlète, classements) et le lot 4 (file d'envoi, saisie). Suivis et préférences dans `LocalStore` ; rappels par un planificateur abstrait (simulé en test) branché sur `flutter_local_notifications`.

**Tech Stack:** Flutter 3.47.7 / Dart 3.13.5, flutter_riverpod 3.4, go_router 18, freezed 4, json_serializable, mocktail, fake_async, gen-l10n, `flutter_local_notifications` (nouvelle dépendance).

**Spec:** `live_ffss.v2/docs/specs/2026-10-18-lot6a-mon-espace-design.md`

## Global Constraints

- Règles de `live_ffss.v2/CLAUDE.md` : `features` → `data` → `domain` ; `strict-casts`, `strict-raw-types` ; pas de `fromJson` écrit à la main ; DTO tout nullable, ligne illisible écartée seule (`decodeRows`) ; `clockProvider` ; `retry: noRetry` ; `ref.mounted` après chaque `await` ; `AppException` seulement ; pas de test de widget ; page sans logique testable (tout dans un `*_formatting.dart` ou un fournisseur, testé) ; commentaires qui disent pourquoi.
- **Lecture seule** côté FFSS (aucune écriture : forfait et relais au lot 6b). **Aucun agent n'appelle le serveur FFSS** : fixtures `test/fixtures/recette_1416/` (`evenement_me_1416` rôles détaillés, `officiels_1416`, `participants_1416` avec `idLicencie`/`idClub`, `evenement_1416`, et celles des lots 2-5) via `fixture(name)`.
- **Données personnelles** : ne jamais lire e-mail, téléphone, contacts de l'organisateur, date de naissance, année, numéro de licence ; fixtures pseudonymisées seulement.
- **Android seulement** pour les rappels ; le web et les tests utilisent un planificateur sans effet.
- Traductions : `app_fr.arb` de référence, `app_en.arb` mêmes clés et mêmes blocs `@`, pas de clé morte ; `flutter gen-l10n`. « Eau plate ».
- Bas de liste défilante : `+ MediaQuery.of(context).viewPadding.bottom`.
- Lectures à la demande : **6 au plus en vol** ; aucune nouvelle minuterie.
- Avant chaque commit, depuis `live_ffss.v2/` : `flutter analyze` propre, `flutter test` vert, `dart format lib test` sans changement ; après `build_runner`, revenir sur les fichiers générés modifiés seulement par les fins de ligne. Commits en français (`feat(v2):`, `fix(v2):`, `docs(v2):`) avec la ligne `Co-Authored-By` du modèle. Ne jamais pousser ni changer de branche (`feat/v2-lot6-mon-espace`) ; ne pas toucher `live_ffss/`.

## Review Focus

1. **Compte licencié non engagé** (le compte de test : licencié 1326 absent des participants de 1416) : pas de carte Athlète, aucune erreur → test en Task 1 et Task 5.
2. **Rôles en échec ou en lecture** (réseau de piscine) : Mon espace s'affiche avec la partie « tout le monde », les cartes de rôle attendent ou proposent Réessayer, sans bloquer → test en Task 5.
3. **Changement de compte ou déconnexion** : les cartes de rôle d'un autre compte ne restent jamais affichées ; les suivis (locaux, sans compte) restent → test en Task 5.
4. **Rappels** : un rappel déjà passé n'est jamais planifié ; une course déplacée replanifie ; désactiver efface tout → test en Task 8.
5. **Séries à saisir** sur une compétition où rien n'est terminé, ou dont une lecture de chronos échoue : liste vide ou partielle, signalée, sans échec global → test en Task 7.

---

### Task 1 : rôles détaillés sur la compétition

**Files:** Create `lib/domain/competition_roles.dart` ; Modify `lib/data/repositories/auth_repository.dart` (`competitionRoles`), `lib/features/auth/competition_roles.dart`, appelants de `competitionRolesProvider` ; Test `test/domain/competition_roles_test.dart`, `test/data/repositories/auth_repository_test.dart`, `test/features/auth/competition_roles_test.dart`.

**Produces :**
- `CompetitionRoles { List<String> roles; int? licenseeId; OfficialRole? official; List<ClubRef> refereeClubs; bool get isAdmin; bool get isOfficial; bool get isReferee; }` (freezed) ; `OfficialRole { String level; String levelLabel; bool principal; }` ; `ClubRef { int id; String label; }`.
- `AuthRepository.competitionRoles(int competitionId)` → `Future<CompetitionRoles>` : lit `data.roles`, `data.licencie.id`, `data.officiel {niveau, niveauLabel, principal}`, `data.referent_sportif[] {id, label}` ; rôles vides → `['public']` ; un objet illisible est ignoré seul (pas d'échec).
- `competitionRolesProvider` → `FutureProvider.autoDispose.family<CompetitionRoles, int>` ; sans session : `CompetitionRoles(roles: ['public'])` sans appel. `canEnterProvider` inchangé dans son comportement (`canEnterResults(roles.roles)`).

- [ ] Tests : fixture `evenement_me_1416` → rôles `public, licencie, officiel, referent_sportif`, `licenseeId` 1326, `official.level` `B`, `principal` faux, `refereeClubs` `[ClubRef(15, …)]` ; `admin` → `isAdmin` ; objet `officiel` mal typé → `official` nul, reste lu ; tests existants de `canEnterProvider` / `entryAccessProvider` / `retryFailedRoles` verts.
- [ ] Implémenter, build_runner, vérifications. Commit `feat(v2): rôles détaillés sur la compétition`.

### Task 2 : participants reliés au licencié et au club ; officiels ; infos

**Files:** Modify `lib/data/ffss/dtos/participant_dto.dart`, `lib/data/ffss/mappers/results_mapper.dart`, `lib/domain/event_results.dart` (`Participant`) ; Create `lib/domain/officials.dart`, `lib/data/ffss/dtos/officiel_dto.dart`, mapper, `lib/data/repositories/officials_repository.dart` ; Modify `lib/core/config/app_config.dart` (`officials = 'competition/evenement/:id/officiels'`) ; Tests correspondants.

**Produces :**
- `Participant` gagne `int? licenseeId` (`idLicencie`) et `int? clubId` (`idClub`).
- `CompetitionOfficial { int id; String name; String level; bool principal; List<int> days; String daysLabel; String club; }` ; `OfficialsRepository.getOfficials(int competitionId)` → `Future<List<CompetitionOfficial>>` + `officialsRepositoryProvider`. Ne lit ni `NumeroLicence`, ni `Annee`, ni `Sexe`.
- `List<({String? label, List<CompetitionOfficial> officials})> groupOfficials(List<CompetitionOfficial>)` : juge principal d'abord (groupe `label` nul), puis niveaux `A`, `B`, `C`, puis autres codes triés ; dans un groupe, tri par nom.

- [ ] Tests : `participants_1416` → `licenseeId` et `clubId` lus ; `officiels_1416` → 60 officiels, 1 principal, niveaux A/B/C, `days` `[3]`… ; `groupOfficials` (ordre, principal à part, niveau inconnu en dernier) ; ligne illisible écartée seule.
- [ ] Implémenter, vérifications. Commit `feat(v2): officiels de la compétition, participant relié au licencié et au club`.

### Task 3 : calculs purs de Mon espace

**Files:** Create `lib/domain/my_space.dart` ; Test `test/domain/my_space_test.dart`.

**Consumes :** `AthleteRace` (lot 5, `features/results/athlete_providers.dart` — si le type est en `features`, la fonction prend ses champs utiles ou vit dans `features/my_space/`), `Participant`, `Programme`, `Heat`, `RunStatus`, `OutboxOperation`.

**Produces :**
- `Participant? participantOfLicensee(List<Participant>, int? licenseeId)`.
- `List<Participant> clubAthletes(List<Participant>, int clubId)` (tri nom, prénom).
- `List<({int id, String label, int athletes})> competitionClubs(List<Participant>)` (par `clubId`, libellé du premier, tri libellé ; `clubId` nul écarté).
- `List<Heat> heatsToCheck(Programme programme)` : séries **terminées** avec `seriesId`, ordre du programme.
- `bool needsEntry(Map<int, List<int?>> chronos, Iterable<int> entryIdsWithPublishedTime, Iterable<OutboxOperation> pending)` : vrai si aucun chrono > 0, aucun temps publié et aucune saisie en file pour la série.
- `DateTime? reminderAt(DateTime? start, Duration before, DateTime now)` : `start − before` s'il est après `now`, sinon nul.

- [ ] Tests (valeurs construites et fixtures) pour chacune, y compris licencié absent → nul, `clubId` nul, aucune série terminée → liste vide, rappel passé → nul.
- [ ] Implémenter, vérifications. Commit `feat(v2): calculs de Mon espace`.

### Task 4 : suivis locaux et repère « Suivi »

**Files:** Create `lib/domain/follows.dart`, `lib/features/follows/follows_providers.dart` ; Modify `lib/features/programme/widgets/lane_row.dart` (repère), `lib/features/results/athlete_page.dart` (étoile), lignes de classement du lot 5 (repère) ; ARB ; Tests.

**Produces :**
- `Follows { List<FollowedAthlete> athletes; List<FollowedClub> clubs; }` ; `FollowedAthlete { int participantId; String name; String club; List<int> entryIds; }` ; `FollowedClub { int id; String label; }` (freezed + DTO local JSON dans le fichier du fournisseur, comme `outbox_store.dart`).
- `followsProvider` : `AsyncNotifierProvider.family<FollowsNotifier, Follows, int /*competitionId*/>` ; clé `LocalStore` `follows_<competitionId>` (préfixée par l'environnement) ; `toggleAthlete(Participant)`, `toggleClub(int id, String label)` (état d'abord, puis écriture ; `AppException` du stockage attrapée, choix en mémoire gardé) ; valeur illisible → vide.
- `bool isFollowedLane(Follows, LaneAssignment)` (par `entryId`, sinon libellé de club pour un relais) et `bool isFollowedResult(Follows, EventResult)` (par `entryId`, sinon club).

- [ ] Tests : persistance par compétition, bascule, valeur corrompue, échec d'écriture ; repères par `entryId` et par club.
- [ ] Implémenter (étoile sur la fiche d'athlète et sur la vue club de la Task 6, repère « Suivi » dans `LaneRow` et les lignes du classement d'épreuve), ARB, vérifications. Commit `feat(v2): suivre des athlètes et des clubs`.

### Task 5 : Mon espace — accueil, partie « tout le monde », préférences

**Files:** Create `lib/features/my_space/my_space_providers.dart`, `my_space_formatting.dart`, pages `competition_info_page.dart`, `officials_page.dart`, `follows_page.dart`, `widgets/…` ; Modify `my_space_page.dart`, `lib/core/router/app_router.dart` (enfants de `/espace` : `competition/:cid/infos`, `…/officiels`, `…/suivis`, `…/athlete`, `…/club/:clubId`, `…/officiel` ; lien illisible → `Routes.mySpace`) ; `lib/features/settings/` (préférence d'onglet d'ouverture) ; ARB ; Tests.

**Produces :**
- `MySpaceCard` (union : `athlete(Participant)`, `club(ClubRef)`, `official(OfficialRole)`, `admin`) et `mySpaceCardsProvider` : `FutureProvider.autoDispose.family<List<MySpaceCard>, int>` — rôles (Task 1) + participants (lot 5, gardés par `participantsKeeperProvider`) ; carte Athlète seulement si `participantOfLicensee` trouve le licencié ; une carte par club référent ; admin : carte Admin (liste des clubs → vue club).
- Badges (`my_space_formatting.dart`) : prochaine course de l'athlète (« dans 2 h » via `clockProvider`), nombre de saisies refusées de l'officiel (file du compte connecté, compétition active).
- `competitionInfoProvider(cid)` : `CompetitionSummary` (déjà lu) + nombres d'athlètes, de clubs (`competitionClubs`), d'épreuves (lot 5) ; liste des clubs → vue club.
- `officialsProvider(cid)` (Task 2) groupé.
- Préférence **onglet d'ouverture** : `startTabProvider` (`LocalStore`, clé globale non préfixée ajoutée à `AppEnvironment.globalKeys` si elle doit survivre au changement d'environnement — sinon préfixée ; choix à justifier dans le rapport), lu avant la construction du routeur ou appliqué par une redirection au premier affichage.
- Rôles en échec : la partie « tout le monde » s'affiche, les cartes montrent Réessayer (`retryFailedRoles`).

- [ ] Tests : cartes pour le compte de test (Club 15 + Officiel, **pas** Athlète), pour un licencié engagé (Athlète), admin ; rôles en échec ; changement de compte → cartes recalculées ; badges ; infos ; préférence d'onglet ; routes et redirections.
- [ ] Implémenter, ARB, vérifications. Commit `feat(v2): Mon espace — accueil, infos, officiels, suivis`.

### Task 6 : espace athlète et vue club

**Files:** Create `lib/features/my_space/athlete_space_page.dart`, `club_page.dart`, fournisseurs dans `my_space_providers.dart` ; ARB ; Tests.

**Contenu :**
- **Espace athlète** : la fiche du lot 5 (`athleteCardProvider`) du participant relié ; prochaine course en grand (heure, série, ligne via `laneFinderProvider` à la demande) ; onglets Mon planning / Mes résultats (`splitRaces`).
- **Vue club** (ouverte à tout le monde, depuis la fiche d'un athlète, la liste des clubs ou la carte Club) : en-tête + étiquette RÉFÉRENT / ADMIN si le compte l'est pour ce club ; chiffres (athlètes, rang provisoire si `standingsProvider` a déjà une valeur — sinon bouton « Calculer », forfaits) ; onglets Planning (courses à venir de ses athlètes par heure, à partir des fiches lot 5 lues à la demande, 6 au plus en vol) / Résultats (courues) / Forfaits (forfaits des résultats publiés : statut 2 ou complément `F`/`FF`, interrupteurs inactifs avec mention « lot 6b » pour le référent / admin seulement) ; étoile de suivi.
- `clubScheduleProvider((cid, clubId))` : liste triée (à venir puis courues) des `AthleteRace` de ses athlètes ; une fiche en échec n'empêche pas les autres.

- [ ] Tests : planning d'un club sur fixtures (ordre, une fiche en échec), forfaits tirés des résultats, étiquette référent pour le club 15 seulement, prochaine course.
- [ ] Implémenter, ARB, vérifications. Commit `feat(v2): espace athlète et vue club`.

### Task 7 : espace officiel

**Files:** Create `lib/features/my_space/official_space_page.dart`, fournisseurs ; ARB ; Tests.

**Contenu :**
- **Accès rapide** : `nowRunningProvider` → série en cours / suivante, bouton « Saisir » (`Routes.itemEntry`).
- **Mes saisies** : `outboxProvider` filtré sur le compte connecté et la compétition : refusées (motif, Réessayer / Ignorer), en attente, envoyées < 24 h ; toucher ouvre la saisie de la série.
- **Séries à saisir** : `heatsToEnterProvider(cid)` — `heatsToCheck` puis `getHeatChronos` (6 au plus en vol, à la demande, rafraîchissement manuel) et `needsEntry` ; une lecture en échec compte dans « n séries non lues ».
- **DQ et forfaits** : à partir des classements d'épreuve (lot 5, lus à la demande) : résultats DQ (code) et forfaits par épreuve, plus les saisies DQ / forfait en file du compte.
- **Officiels** : lien vers la page de la Task 5.

- [ ] Tests : séries à saisir (aucune terminée → vide ; chronos présents → exclue ; temps publié → exclue ; saisie en file → exclue ; une lecture en échec → signalée), plafond de 6, mes saisies filtrées par compte et compétition, DQ et forfaits.
- [ ] Implémenter, ARB, vérifications. Commit `feat(v2): espace officiel`.

### Task 8 : rappels locaux (Android) et permissions

**Files:** Modify `pubspec.yaml` (`flutter_local_notifications`, version stable récente compatible Flutter 3.47), `android/app/src/main/AndroidManifest.xml` (**`INTERNET`** — absente du manifeste principal, la release ne peut pas joindre l'API — et `POST_NOTIFICATIONS`), `android/app/build.gradle.kts` si la bibliothèque l'exige (désucrage) ; Create `lib/core/notifications/reminder_scheduler.dart`, `lib/features/reminders/reminders_providers.dart` ; préférence dans Mon espace ; ARB ; Tests.

**Produces :**
- `abstract interface class ReminderScheduler { Future<bool> requestPermission(); Future<void> replaceAll(List<Reminder> reminders); Future<void> cancelAll(); }` ; `Reminder { int id; DateTime at; String title; String body; }` ; implémentation `flutter_local_notifications` (alarmes inexactes) sur Android, sans effet ailleurs ; `reminderSchedulerProvider`.
- `reminderLeadProvider` : préférence (désactivé, 5, 15, 30 min ; défaut 15) dans `LocalStore`.
- `remindersProvider(cid)` : athlètes suivis (Task 4) + athlète connecté (Task 5) → leurs courses à venir (heure : `AthleteRace.plannedStart` si connue, sinon première série de l'épreuve dans le programme) → `reminderAt` → `replaceAll` quand la liste **change** (pas à chaque relecture identique) ; désactivé → `cancelAll` ; permission refusée → préférence remise à « désactivé » avec un message.
- Ids de rappel stables (dérivés de l'engagement et de l'épreuve).

- [ ] Tests (planificateur simulé, `fake_async`) : planification, rappel passé ignoré, liste inchangée → pas de nouvel appel, course déplacée → replanifiée, désactiver → `cancelAll`, permission refusée.
- [ ] Implémenter, ARB, vérifications (`flutter build apk --debug` si la chaîne Android est disponible ; sinon le dire dans le rapport). Commit `feat(v2): rappels avant les courses suivies (Android)`.

### Task 9 : documentation

- [ ] `live_ffss.v2/CLAUDE.md` : section « Mon espace (lot 6a) » (rôles détaillés, cartes, vue club ouverte, suivis locaux et clé, rappels Android et planificateur, préférence d'onglet, séries à saisir, permissions du manifeste dont `INTERNET`) ; lacunes (forfait avant course non lisible hors places, iPhone non pris en charge, rappels inexacts). `docs/FFSS_API_CONTRACT.md` : faits vérifiés le 2026-10-18 (rôles détaillés, numérotation des clubs, `officiels`, pas de champ `forfait` lu sur l'engagement). Commit `docs(v2): CLAUDE.md à jour du lot 6a`.
