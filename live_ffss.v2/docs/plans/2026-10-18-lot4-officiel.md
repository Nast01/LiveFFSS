# LiveFFSS v2 — Lot 4 : connexion et saisie officiel — plan d'implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal :** permettre à un officiel déclaré d'une compétition de se connecter avec son compte FFSS, puis de saisir rapidement, couloir par couloir, les temps des chronométreurs (`TempsLive1..3`), une DQ (code libre) ou un forfait, avec envoi en file qui survit aux coupures, sans jamais écraser ce que FFSSCompetition V3 a posé.

**Architecture :** `features` → `data` → `domain`. Domaine : temps manuel, saisie au pavé, droits de saisie, fusion d'une modification dans un résultat (fonctions pures). Données : `AuthRepository`, `ResultRepository` (lecture-modification-écriture), identifiants d'écriture sur la place. État : `sessionProvider` (modèle `FfssSession` de V3), `competitionRolesProvider`, une **file d'envoi persistante** par compte (`OutboxService`). Écrans : connexion et Mon espace, écran de saisie (maquette B), temps manuel dans le détail pour les officiels.

**Tech Stack :** Flutter 3.47.7 / Dart 3.13.5, flutter_riverpod 3.4, go_router 18, freezed 4, flutter_secure_storage, mocktail, fake_async, gen-l10n.

**Spec :** [`docs/specs/2026-10-18-lot4-officiel-design.md`](../specs/2026-10-18-lot4-officiel-design.md) — à lire en entier, surtout les §§ 2, 3, 5, 5 bis et 7.

## Global Constraints

- Règles du [`CLAUDE.md`](../../CLAUDE.md) : `features` → `data` → `domain` ; `clockProvider` ; `retry: noRetry` ; pas de test de widget ; page sans logique testable ; `AppException` seulement ; `ref.mounted` après chaque `await` dans un notifier ; commentaires qui disent pourquoi.
- **L'app reste sur la recette.** Aucun appel d'écriture réel n'est fait par un agent : les écritures sur la recette sont faites par l'utilisateur (tâche 1 et essais manuels).
- **Le mot de passe n'est jamais stocké** ; seul le jeton l'est (`TokenStorage`, clé préfixée par l'environnement).
- **Champs écrits** : `tempsLive1..3` pour les chronos ; `statut` 1 + `complement` (code) pour une DQ ; `statut` 2 + `complement` `F` pour un forfait ; annulation : `statut` 0 + `complement` vide ; un chrono vidé : champ à vide. **Jamais** `temps`.
- **Lecture-modification-écriture au moment de l'envoi** : relire le résultat, refuser si un `temps` est apparu (validé par le juge), sinon fusionner et renvoyer **tous** les champs du résultat.
- **Temps manuel** : 1 chrono → lui ; 2 → moyenne ; 3 → médiane ; visible **seulement des officiels connectés** ; mention « manuel, non définitif ».
- Peut saisir : rôles `officiel`, `juge_principal`, `admin` sur la compétition.
- Traductions fr de référence / en symétrique, pas de clé morte, `flutter gen-l10n` ; freezed → `build_runner`, et revenir sur les fichiers générés réécrits seulement pour des fins de ligne.
- Avant chaque commit : `flutter analyze` propre, `flutter test` vert, `dart format lib test` propre. Commits en français, ligne `Co-Authored-By`. Branche `feat/v2-lot4-officiel`, jamais de push.

## Review Focus

1. **Coupure réseau pendant une série** : la saisie est gardée, marquée « en attente d'envoi », envoyée au retour du réseau, dans l'ordre — tâche 5.
2. **Session expirée en pleine réunion** (403 « Invalid token ») : la file s'arrête sans rien perdre, l'app demande de se reconnecter, la file repart avec le même compte — tâches 4 et 5.
3. **Le juge des résultats valide pendant qu'une saisie attend** : à l'envoi, la relecture voit le `temps` et l'opération est refusée avec le motif, rien n'est écrasé — tâches 3 et 5.
4. **Réponse perdue sur une création** : pas de second résultat pour la même place — tâche 5.
5. **Un compte non officiel** : aucune entrée de saisie visible, aucun appel `serie/:id` de plus — tâches 4 et 8.

---

### Task 1 : vérifications sur la recette (faites par l'utilisateur)

**Files :** Create `docs/checks/2026-10-18-lot4-recette.md` (liste de contrôle à remplir) ; Modify `../docs/FFSS_API_CONTRACT.md` une fois les résultats connus.

- [ ] **Step 1** : écrire la liste de contrôle du § 7 de la spec, avec pour chaque point la commande `curl` exacte (recette, compétition 1416, jeton en paramètre `token` saisi par l'utilisateur, jamais commité) et la case « résultat observé ».
- [ ] **Step 2** : commit `docs(v2): vérifications du lot 4 sur la recette`. **Le contrôleur demande à l'utilisateur de faire ces vérifications** et reporte ses réponses dans le contrat ; les tâches suivantes ne dépendent pas de ces réponses (cas le plus prudent).

### Task 2 : domaine — temps manuel, saisie au pavé, droits

**Files :** Create `lib/domain/manual_timing.dart` ; Test `test/domain/manual_timing_test.dart`.

**Interfaces :**
- `enum ManualTimeRule { single, average, median }` ; `({int hundredths, ManualTimeRule rule})? manualTime(List<int?> chronos)` — ignore nul et ≤ 0 ; 2 → moyenne **arrondie au centième le plus proche** (à aligner sur V3 si la tâche 1 montre autre chose) ; 3 → médiane.
- `int? parseChronoDigits(String digits)` — chiffres seulement, 1 à 6 chiffres lus `mmsscc` complétés à gauche (`4321` → 43"21) ; secondes > 59 → nul ; `String chronoDigitsLabel(String digits)` → `mm'ss"cc` partiel pour l'affichage pendant la frappe.
- `bool canEnterResults(Iterable<String> roles)` — `officiel`, `juge_principal`, `admin`.
- [ ] Tests (0, 1, 2, 3 chronos ; arrondi ; zéros ignorés ; saisie 1 à 6 chiffres ; secondes invalides ; rôles), échec, implémentation, vert. Commit : `feat(v2): temps manuel, saisie au pavé et droits de saisie`.

### Task 3 : données — résultat et identifiants d'écriture

**Files :** Modify `lib/data/ffss/dtos/place_dto.dart`, `lib/data/ffss/mappers/place_mapper.dart`, `lib/domain/lane_assignment.dart` ; Create `lib/data/ffss/dtos/resultat_dto.dart`, `lib/domain/race_result.dart`, `lib/data/repositories/result_repository.dart` ; Modify `lib/core/config/app_config.dart` (endpoints `resultat/:id`, `resultat/submit`, `serie/:id`) ; Tests.

**Interfaces :**
- `LaneAssignment` reçoit `int? resultId`, `int? entryId` (ids FFSS du résultat et de l'engagement).
- `RaceResult` (domaine, freezed) : `id`, `seriesId`, `entryId`, `int? time` (`Temps`), `List<int?> chronos` (TempsLive1..3), `int rank`, `int status`, `String complement`, `int? points` — tout ce que `resultat/submit` attend.
- `ResultChange` (domaine, freezed) : `List<int?>? chronos` (remplace les trois), `ResultMark? mark` avec `enum ResultMark { ok, disqualified, forfeit }` et `String? code`.
- `RaceResult applyChange(RaceResult current, ResultChange change)` (pur) ; `bool isValidatedByJudge(RaceResult r)` → `time != null && time > 0`.
- `ResultRepository` : `Future<RaceResult?> getResult(int id)` ; `Future<Map<int, List<int?>>> getHeatChronos(int seriesId)` (engagement → TempsLive, via `serie/:id`) ; `Future<int> submit(RaceResult r)` (POST `resultat/submit`, tous les champs, rend l'id) ; `Future<LaneAssignment?> getLane(int placeId)` existe déjà (`MeetingRepository.getLanes`).
- [ ] Tests : mapper de place (ids sur `place_2816`) ; `applyChange` (chronos seuls, DQ avec code, forfait, annulation → statut 0 et complément vide, chrono vidé) ; `isValidatedByJudge` ; repository (corps du POST complet, `id` absent pour une création, `success: false` → `ApiException`). Commit : `feat(v2): résultats — lecture, fusion d'une saisie, envoi`.

### Task 4 : session et rôles

**Files :** Create `lib/data/repositories/auth_repository.dart`, `lib/features/auth/session.dart`, `lib/features/auth/competition_roles.dart` ; Modify `lib/core/config/app_config.dart` (`requestToken`, `me`, `evenement/:id/me`) ; Tests.

**Interfaces :**
- `AuthRepository` : `Future<String> requestToken(String login, String password)` ; `Future<Account> me()` (`Account(label, type)`) ; `Future<List<String>> competitionRoles(int competitionId)`.
- `sessionProvider` (`AsyncNotifier<Account?>`) : `build()` restaure (jeton stocké → `me()` ; anonyme, refus ou autre compte → déconnecté, jeton effacé ; injoignable → garde la session supposée) ; `login(login, password)` (efface le jeton d'abord, `requestToken`, stocke, `me()`) ; `logout()` ; branche `HttpClient.onAuthFailure` → session fermée (`expired`) sans toucher à la file.
- `competitionRolesProvider(competitionId)` (`FutureProvider.autoDispose.family<List<String>, int>`) : `['public']` sans session ; relu quand la session change.
- `canEnterProvider(competitionId)` → `canEnterResults(roles)`.
- [ ] Tests (mocktail, `InMemory` stores) : restauration vérifiée, compte anonyme → déconnecté, connexion efface l'ancien jeton, déconnexion, 403 → expirée, rôles selon la session. Commit : `feat(v2): connexion FFSS et rôles sur la compétition`.

### Task 5 : file d'envoi

**Files :** Create `lib/domain/outbox.dart`, `lib/features/officiel/outbox_store.dart`, `lib/features/officiel/outbox_service.dart` ; Tests.

**Interfaces :**
- `OutboxOperation` (freezed, JSON pour le stockage — **seul fichier de l'app avec un `toJson` de domaine** : placer la sérialisation dans `outbox_store.dart` via un DTO dédié pour respecter « domaine sans JSON ») : `id`, `account`, `competitionId`, `placeId`, `int? resultId`, `int seriesId`, `int entryId`, `ResultChange change`, `OutboxState state` (`pending`, `sent`, `rejected`), `String? reason`, `int attempts`.
- `List<OutboxOperation> enqueue(List<OutboxOperation> queue, OutboxOperation op)` (pur) : fusionne avec une opération `pending` du même compte et de la même place (la dernière gagne par champ).
- `OutboxStore` (`LocalStore`, clé par environnement) : `load()`, `save(list)`.
- `OutboxService` (`Notifier<List<OutboxOperation>>`, sans `autoDispose`, démarré au lancement) : traite dans l'ordre les opérations `pending` du compte connecté ; pour chacune : relit la place (`getLanes([placeId])`) → `resultId` (création arrivée malgré une réponse perdue) ; si résultat : `getResult`, `isValidatedByJudge` → `rejected` (« validé par le juge des résultats »), sinon `applyChange` + `submit` ; sinon création `submit` avec un `RaceResult` neuf ; succès → `sent` (garder `resultId`) ; `NetworkException`/injoignable → nouvel essai avec délai croissant (5 s, 15 s, 60 s, plafonné) ; 403 / session expirée → arrêt jusqu'à la reconnexion ; `ApiException` métier → `rejected` avec le message, on passe à la suivante. Persiste à chaque changement.
- [ ] Tests (`fake_async`) : persistance et reprise, fusion, ordre, coupure puis reprise, 403 puis reprise après connexion, validé par le juge → refusé sans écriture, réponse perdue sur création → pas de doublon, compte différent → non envoyé. Commit : `feat(v2): file d'envoi des saisies, persistante et sûre`.

### Task 6 : connexion et Mon espace

**Files :** Create `lib/features/auth/login_page.dart`, `lib/features/my_space/my_space_page.dart` ; Modify routeur, `tab_placeholders.dart` (retirer `MySpacePlaceholder` si remplacé), `home_header.dart` (« Se connecter » → page de connexion), ARB.
- [ ] Connexion (identifiant, mot de passe masqué, erreurs lisibles), Mon espace : compte, « Se déconnecter » (confirmation si des saisies attendent), le sélecteur de langue existant. Commit : `feat(v2): page de connexion et Mon espace`.

### Task 7 : écran de saisie

**Files :** Create `lib/features/officiel/entry_page.dart`, `widgets/` (champ chrono, pavé, ligne de couloir), `entry_providers.dart` (filtre de couloir persistant par compétition, série courante, navigation ‹ ›) ; Modify Live (`live_heat_card.dart`) et détail (`item_detail_page.dart`) : bouton « Saisir » si `canEnterProvider` ; routeur ; ARB.
- [ ] Maquette B de la spec § 4 : couloir en grand (3 champs, pavé, `chronoDigitsLabel`, temps manuel + règle + « non définitif », DQ… / Forfait / annulations), « Enregistrer et passer à la série suivante » (met en file, n'attend pas le réseau), filtre Tous → liste des couloirs, état d'envoi par couloir, lecture seule si `isValidatedByJudge`, mention permanente de non-validation. Logique de navigation et d'état dans `entry_providers.dart`, testée. Commit : `feat(v2): écran de saisie officiel`.

### Task 8 : temps manuel dans le détail (officiels)

**Files :** Modify `lib/features/programme/item_detail_providers.dart` (ou un fournisseur dédié), `lane_row.dart`.
- [ ] Pour un officiel seulement (`canEnterProvider`) : chronos lus par `getHeatChronos(seriesId)` ; une place sans `temps` avec des chronos affiche le temps manuel « manuel, non définitif ». Aucun appel de plus pour un spectateur (test). Commit : `feat(v2): temps manuel visible des officiels dans le détail`.

### Task 9 : documentation

- [ ] `CLAUDE.md` : connexion (jeton, restauration vérifiée, 403), rôles, file d'envoi (règles), lecture-modification-écriture, temps manuel. Contrat API : faits de la tâche 1 reçus de l'utilisateur. Commit : `docs(v2): CLAUDE.md à jour du lot 4`.
