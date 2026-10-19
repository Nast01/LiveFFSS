# Lot 6b — Forfaits du club : plan d'implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** le référent sportif d'un club (ou un admin) déclare ou annule un forfait depuis l'onglet Forfaits de la vue club, jusqu'à 10 min avant la course.

**Architecture:** une écriture `engagement/:id/submit` dans un repository ; l'état lu sur les places des séries non terminées des épreuves du club ; un fournisseur par club qui expose les lignes et une bascule optimiste ; l'onglet Forfaits de `club_page.dart` active ses interrupteurs selon `clubRole`.

**Tech Stack:** Flutter 3.47.7 / Dart 3.13.5, flutter_riverpod 3.4, freezed 4, mocktail, fake_async, gen-l10n.

**Spec:** `live_ffss.v2/docs/specs/2026-10-19-lot6b-forfaits-design.md`

## Global Constraints

- Règles de `live_ffss.v2/CLAUDE.md` (sections Mon espace lot 6a, lots 4 et 5) : `features` → `data` → `domain` ; `clockProvider` ; `retry: noRetry` ; `ref.mounted` après chaque `await` ; `AppException` seulement ; pas de test de widget ; logique d'affichage dans `my_space_formatting.dart` ou un fournisseur, testée ; commentaires qui disent pourquoi.
- **Écriture** : `POST competition/engagement/:id/submit` avec `forfait` `1` ou `0` **dans l'adresse** (`HttpClient.post(path, query: {...})`, sans corps), jeton ajouté par `HttpClient`. **Aucun agent n'appelle le serveur FFSS** : simulacres seulement.
- Lectures de places : `MeetingRepository.getLanes`, **6 au plus en vol**, à la demande ; aucune minuterie.
- Échéance : départ prévu − **10 minutes**.
- Eau plate seulement (garde côtier du lot 6a). Traductions fr de référence / en symétrique, pas de clé morte, `flutter gen-l10n`.
- Avant chaque commit, depuis `live_ffss.v2/` : `flutter analyze`, `flutter test`, `dart format lib test` propres ; fichiers générés modifiés seulement par les fins de ligne : revenir dessus. Commits en français avec `Co-Authored-By`. Ne jamais pousser ni changer de branche (`feat/v2-lot6b-forfaits`).

## Review Focus

1. **Échec d'envoi** (hors ligne, 403 session expirée, refus du site) : l'interrupteur revient à l'état précédent, un message le dit, rien n'est perdu ni affiché à tort → test en Task 2.
2. **Échéance passée pendant que l'écran est ouvert** : l'interrupteur se verrouille au prochain affichage ; un envoi lancé après l'échéance est refusé côté app → test en Task 2.
3. **Relais** : un seul interrupteur par relais, même si plusieurs relayeurs du club sont listés → test en Task 2.
4. **Compte sans droit sur ce club** (autre club, public) : aucune écriture possible, interrupteurs absents → test en Task 2.
5. **Places illisibles** : engagement « état inconnu », pas de faux « pas forfait » → test en Task 2.

---

### Task 1 : écriture du forfait et calculs purs

**Files:** Create `lib/data/repositories/engagement_repository.dart` ; Modify `lib/core/config/app_config.dart` (`engagementSubmit = 'competition/engagement/:id/submit'`), `lib/domain/my_space.dart` ; Tests `test/data/repositories/engagement_repository_test.dart`, `test/domain/my_space_test.dart`.

**Produces :**
- `abstract class EngagementRepository { Future<void> setForfeit(int entryId, {required bool forfeit}); }` + `EngagementRepositoryImpl(HttpClient)` + `engagementRepositoryProvider`. `post('competition/engagement/$id/submit', query: {'forfait': forfeit ? '1' : '0'})` ; réponse `success: false` → `ApiException` avec le message du site.
- `DateTime? forfeitDeadline(DateTime? heatStart)` = départ − 10 min ; `const forfeitLead = Duration(minutes: 10)`.
- `bool forfeitLocked(DateTime? deadline, DateTime now)` : vrai si l'échéance est passée (`!now.isBefore(deadline)`) ; échéance nulle → non verrouillé.

- [ ] Tests : paramètres exacts (`forfait` `1`/`0` dans la requête, pas de corps), `success: false` → `ApiException`, `AppException` propagée ; échéance et verrouillage (avant, pile à l'échéance, après, nul).
- [ ] Implémenter, vérifications. Commit `feat(v2): écriture du forfait d'un engagement`.

### Task 2 : forfaits du club — fournisseur et onglet

**Files:** Create `lib/features/my_space/club_forfeits_providers.dart` ; Modify `lib/features/my_space/club_page.dart` (onglet Forfaits), `my_space_formatting.dart`, ARB ; Tests `test/features/my_space/club_forfeits_test.dart`, `test/features/my_space/my_space_formatting_test.dart`.

**Consumes :** `clubProvider` / `clubAthletes` (athlètes du club et leurs `entries`), `eventsProvider` / `resultsProgrammeProvider` (programme sans l'observer), `heatsRoundOf` (series_link.dart), `MeetingRepository.getLanes`, `inPool` et `RefreshSignal` (my_space_providers.dart), `clubRole`, `spaceCompetitionProvider` / `isCoastalOnly`, `clockProvider`, `forfeitDeadline`, `forfeitLocked`, `engagementRepositoryProvider`.

**Produces :**
- `ClubForfeit { int entryId; CompetitionEvent event; List<String> athletes; Heat? heat; int? lane; bool? forfeit /* nul = inconnu */; DateTime? deadline; ForfeitSending sending /* idle, sending */; }` (freezed).
- `clubForfeitsProvider` : `AsyncNotifierProvider.autoDispose.family<ClubForfeitsNotifier, List<ClubForfeit>, ClubKey>` — engagements du club regroupés par `entryId` (un relais une fois) ; places des séries non terminées du tour séries de chaque épreuve lues 6 au plus en vol jusqu'à trouver chaque engagement ; place illisible → `forfeit` nul ; `refresh()` relit.
- `Future<ForfeitOutcome> toggle(int entryId)` (`ForfeitOutcome { done, locked, notAllowed, failed }`) : droit (`clubRole` référent de ce club ou admin) sinon `notAllowed` sans appel ; verrouillé (échéance passée à `clock()`) → `locked` sans appel ; sinon état optimiste + `sending`, `setForfeit`, succès → relecture de la place concernée, échec `AppException` → état précédent, `failed` ; `ref.mounted` après chaque `await`.
- Formatage : libellé de ligne (athlète / relais + relayeurs, épreuve, « Série n · couloir l » ou « pas encore placé »), état de l'interrupteur (`ForfeitSwitch { hidden, active, sending, locked, unknown }`), message de résultat (`ForfeitOutcome` → texte).
- Onglet Forfaits : pour le référent / admin, en-tête « jusqu'à 10 min avant la course », interrupteurs actifs ; pour les autres, la liste en lecture (forfaits publiés du lot 6a). Le texte « bientôt disponible » du lot 6a disparaît pour les forfaits.

- [ ] Tests (fixtures + simulacres) : regroupement relais, lecture plafonnée à 6, place illisible → inconnu, bascule réussie (appel `setForfeit` exact + relecture), échec → état précédent, verrouillé → aucun appel, pas de droit → aucun appel, compétition côtière → aucune lecture ; formatage.
- [ ] Implémenter, ARB, `flutter gen-l10n`, vérifications. Commit `feat(v2): déclarer ou annuler un forfait depuis la vue club`.

### Task 3 : documentation

- [ ] `live_ffss.v2/CLAUDE.md` : section Mon espace — forfaits (écriture, lecture par les places, échéance, envoi direct sans file, droits) ; lacunes : remplacement de relayeur impossible avant la course (routes de place absentes), forfait non lisible hors places. `docs/FFSS_API_CONTRACT.md` : faits du 2026-10-19 (forfait, routes de remplacement, `remplacant/available` et ses données personnelles). Commit `docs(v2): CLAUDE.md à jour du lot 6b`.
