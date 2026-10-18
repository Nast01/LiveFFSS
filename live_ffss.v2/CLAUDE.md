# CLAUDE.md — LiveFFSS v2

Règles et conventions de la v2 de l'application mobile. Référence pour les sessions Claude futures.

## Contexte

- **Réécriture** de l'application mobile, sur le modèle de `FFSS-Competition.V3` dans le dépôt FFSSCompetition. La v1 (`../live_ffss/`, épreuves côtières, testée en live) est **gelée** au tag `v1-cotier-final` : on y puise, on ne la modifie pas.
- **Le code utile de la v1 est copié, jamais importé.** La v2 ne dépend pas de la v1.
- **Le seul lien avec FFSSCompetition (le bureau) est l'API FFSS.** Le bureau publie programme, séries et résultats ; le mobile les lit.
- **On reprend FFSSCompetition V3** : noms de classes et d'attributs, règles de calcul, décisions. Le domaine mobile est un sous-ensemble du domaine V3 (`FFSS-Competition.V3.Core/Domain`), limité à ce que l'API transporte. Le dossier `Core/Ffss` de V3 est la référence de la correspondance entre l'API et le domaine.
- Specs : `docs/specs/`. Plans : `docs/plans/`. Lots : voir la spec du lot 1, § 2.

## Architecture

`features` → `data` → `domain`, dans ce sens uniquement.

- **`lib/domain/`** : classes pures (freezed, sans JSON), nommées comme V3 : `CompetitionSummary`, `Discipline`, `Gender`, `Meeting`, `MeetingItem`, `Heat`, `RunStatus`. Les calculs purs y vivent (`partitionHome`, `nowRunning`) et se testent sans simulation.
- **`lib/data/ffss/`** : DTO freezed de l'API (noms français mappés par `@JsonKey`, tout nullable) et mappers `extension XMapper on XDto { X? toDomain() }`. Un mapper **écarte** une ligne inutilisable (renvoie `null`) au lieu de faire échouer la liste. `readInt` (nombre servi en chaîne) et `readMap` (objet vide servi en `[]` par PHP) sont dans `dtos/json_readers.dart`.
- **`lib/data/repositories/`** : `XRepository` abstrait + `XRepositoryImpl(HttpClient)` + `xRepositoryProvider`. Pagination et conversion ici. **Pas de couche datasource.**
  - Une ligne qui ne se décode pas au type attendu (`TypeError` levée par `XDto.fromJson`) est écartée seule, comme celles que le mapper rejette. Le compte de page pleine se fait sur la longueur brute de `data` : une entrée non-objet ne fait pas passer une page pleine pour la dernière.
  - `MeetingRepository.getProgramme(id)` lit `competition/:id/reunion` et `competition/:id/deroulement`, puis `withRaces` donne à chaque série sa course (discipline, genre) d'après le déroulement de sa partie : l'objet `serie` de la liste `reunion` ne porte ni `Numero` ni `epreuve`. Un échec du déroulement laisse le programme sans courses ni frise, il ne le fait jamais échouer.
- **`lib/features/<fonction>/`** : fournisseurs Riverpod, fonctions pures de présentation (`home_view.dart`), extensions de formatage (`competition_formatting.dart`), pages et `widgets/`.
- **`lib/core/`** : `config/` (environnements, endpoints), `errors/` (`AppException`), `network/` (`HttpClient`, `TokenStorage`), `storage/` (`LocalStore`), `providers.dart` (fournisseurs du cœur, dont `clockProvider`), `theme/`, `l10n/`, `router/`.

## État et navigation

- **Riverpod 3.** Fournisseurs déclarés à la main (pas de `riverpod_generator`). Les tests créent `ProviderContainer(overrides: [...], retry: noRetry)` et `main.dart` passe le même `noRetry` (`core/providers.dart`) à `ProviderScope` : Riverpod 3 relance par défaut un fournisseur en échec pendant près de 40 s, ce qui ferait attendre un test et, hors ligne, tournerait le rafraîchissement d'autant. Le rafraîchissement manuel et la minuterie de 30 s tiennent lieu de nouvelle tentative.
- **`clockProvider`** donne l'heure : ne jamais appeler `DateTime.now()` dans un fournisseur ou une page.
- **go_router 18**, `StatefulShellRoute.indexedStack` : une branche par onglet. Les routes sont dans `Routes` (`core/router/app_router.dart`).
- **Compétition active** : `activeCompetitionProvider` (id persisté, résumé en mémoire) ; `currentCompetitionProvider` en déduit la compétition des onglets. On ouvre une compétition avec `openCompetition(...)`.
- **Détail d'un créneau** : `meetingItemDetailProvider` relit le créneau toutes les 30 s, les couloirs des courses non terminées à chaque tick, ceux des courses terminées une fois au passage puis toutes les 2 min. Il lit le programme sans l'observer (pas de reconstruction toutes les 30 s) et vérifie `ref.mounted` après chaque `await`.
- **`SerialRefresh`** (`features/common/serial_refresh.dart`) : mécanique de relecture partagée par le détail d'un créneau et le Live. Une relecture à la fois (deux qui se chevauchent écriraient l'une sur l'autre, la plus lente gagnant avec des données plus vieilles), `runInSeries` (la suite d'un chargement) attend la relecture en cours et est abandonnée si le fournisseur est fermé entre-temps (une `AppException` y est avalée, les autres remontent), nouvel essai d'un premier chargement en échec par la minuterie ou le rafraîchissement manuel, `ref.mounted` vérifié après chaque `await`.
- **Onglet Live** (`features/live/`) : `liveProvider` (AsyncNotifier family par compétition, `autoDispose` : tout est perdu à la fermeture et relu au retour ; relu toutes les 60 s) montre `liveSelection` : les séries en cours (chambre d'appel ou en cours) et les 10 dernières courues (`liveRecentLimit`). Le Live s'affiche dès le programme lu ; les places suivent (séries en cours d'abord), lues en série avec la minuterie et le rafraîchissement (`SerialRefresh.runInSeries`) ; tant qu'aucune place d'une série n'est lue (`LiveView.lanesReadFor`), sa carte montre un indicateur et non « Résultats en attente ». La minuterie ne relit que les places des séries en cours, une dernière fois celles d'une série qui vient de se terminer, et celles d'une série dont aucune place n'est lue (ou dont une place a échoué) ; les autres (dernières courues, validées ou temporaires) ne sont relues que par le rafraîchissement manuel (geste tirer, ou bouton « Rafraîchir » de l'en-tête), qui relit tout : le juge principal peut encore corriger une série validée (décision du 2026-10-18).
- **Navigation du Live** : une carte ouvre `Routes.liveItem(competitionId, itemId)`, route enfant de `/live` (même `ItemDetailPage` que `Routes.programmeItem`, même redirection d'un lien illisible par `itemRedirect`, vers `Routes.live`) : le retour ramène au Live au lieu de laisser dans l'onglet Programme.
- **Temporaire / validé** : le site FFSS n'a pas de champ « validé ». `isProvisional(heat)` est vrai si la course n'est pas `finished` ou si `Heat.resultsProvisional` l'est, c'est-à-dire si le libellé de la série contient « Résultats temporaires », ou s'il n'y a pas de série ou de libellé. **À vérifier** : le libellé d'une série validée par un juge n'a pas encore été observé.
- **`TempsLive1/2/3`** : les temps saisis par les chronométreurs. Seuls les officiels connectés les lisent (voir Temps manuel) ; un spectateur ne les demande jamais.
- **Route du détail** : enfant de la branche Programme, `competition/:competitionId/creneau/:itemId` (`Routes.programmeItem`). L'ouvrir appelle `ensure` pour rendre la compétition active.
- **Place dans la série** : recalculée par l'app (`heatPlaces`) sur les temps de la série, toutes catégories ensemble (« 1er », « 2e »), décision du 2026-10-17 ; le `rangLabel` de FFSS, publié par catégorie, n'est pas lu. Le temps n'existe qu'en libellé (`MM'SS"CC`), converti en centièmes par `parseFfssTime`. Ex aequo : même place, la suivante sautée ; sans temps, DQ ou statut autre que OK : pas de place. Pas de badge de qualification : les places ne portent pas de `complement`. Le classement d'une épreuve (qualifiés pour le tour suivant) reste à l'API.

## Officiel (lot 4)

- **Connexion** (`features/auth/session.dart`, `login_page.dart`, `features/my_space/my_space_page.dart`, `data/repositories/auth_repository.dart`) : `sessionProvider` (AsyncNotifier, `Account?`). Le mot de passe n'est jamais gardé, seul le jeton l'est (`TokenStorage`), avec le nom du compte (`session_account`) pour vérifier qu'un jeton repris est bien le sien. Identifiant et mot de passe partent dans un corps de formulaire, jamais dans l'adresse (journaux du serveur et des relais). Un jeton accordé n'ouvre la session qu'avec le compte que `/me` décrit : tout échec de `/me` fait échouer la connexion et efface le jeton (sous l'identifiant tapé, les saisies seraient rangées sous un compte que le site ne rendrait plus).
- **Reprise au lancement, vérifiée** : le jeton enregistré n'ouvre la session qu'après `GET /me` (le site sert un jeton mort comme anonyme ; `me()` lève `AuthException` sur « Utilisateur Anonyme »). Hors ligne, la session enregistrée est supposée bonne si son nom est connu ; la première écriture la vérifiera.
- **Expiration** : un 403 « Invalid token » appelle `HttpClient.onAuthFailure`, qui ferme la session (`sessionExpiredProvider` passe à vrai, jusqu'à la prochaine connexion ou déconnexion). Seuls le jeton et l'état de session changent : la file d'envoi et les préférences restent, reprises à la reconnexion.
- **Rôles** : `competitionRolesProvider(id)` lit `evenement/:id/me` (relu à chaque changement de session ; sans session, `public` sans appel) ; `canEnterProvider(id)` est faux pendant la lecture ou en cas d'échec. Une lecture en échec avec une session ouverte (hors ligne au lancement, Wi-Fi de piscine) n'est pas un refus : `entryAccessProvider` rend `unverified`, l'écran de saisie dit « droits non vérifiés » et propose « Réessayer » ; le rafraîchissement manuel du Live, du détail d'un créneau et de la saisie relit aussi des rôles en échec (`retryFailedRoles`, par `SerialRefresh.beforeManualRefresh`), jamais la minuterie. La saisie est permise pour `officiel`, `juge_principal` et `admin` (`canEnterResults`). `referent_sportif` n'est pas documenté et ne donne aucun droit.
- **Saisie** (`features/officiel/` : `entry_page.dart`, `entry_providers.dart`, `entry_view.dart`) : route `Routes.itemEntry`, enfant du Live comme du Programme ; le bouton « Saisir » est dans une carte du Live et dans le détail d'un créneau. Le filtre de couloirs est gardé sous `entry_lane_filter_<id>`. La navigation ‹ › suit `entrySequence` et réécrit `?serie=` de l'adresse (`entryRouteHeat`) : rouvert, l'écran reprend sur la série atteinte. La page garde la clé de ses fournisseurs tant qu'elle est montrée (`entryScreenKey`), pour que la nouvelle adresse ne les remplace pas. Les saisies en file sont appliquées par-dessus la lecture du serveur (`sentAt` contre `readAt` : une saisie envoyée avant la lecture est déjà dans ce que le site rend). `getHeatResults` est une lecture tolérante, pour l'affichage seul, jamais renvoyée au site : un `Temps` présent mais illisible compte comme validé. **Rien n'est validé dans l'app** : le juge des résultats valide dans FFSSCompetition V3.
- **Session perdue pendant la saisie** (`entryGateProvider`, `entryGate`) : une session fermée l'écran ouvert (403 « Invalid token », déconnexion) gèle l'écran au lieu de le fermer : rien ne s'y tape ni ne s'enregistre (`EntrySaveOutcome.notConnected`), les chiffres tapés restent en mémoire, un bandeau « Session expirée — reconnectez-vous » mène à Mon espace (l'`IndexedStack` garde la branche montée). Reconnecté, le même compte reprend ses chiffres une fois ses droits relus (l'écran reste gelé pendant la relecture, ou si elle échoue) ; un autre compte ne reprend rien (l'éditeur se reconstruit sur le changement de `owner`). Le même compte reconnecté sans droit ferme l'écran.
- **File d'envoi** (`domain/outbox.dart`, `outbox_service.dart`, `outbox_store.dart`) : démarrée dès le lancement (`app.dart` l'écoute). Gardée sur l'appareil **par compte** : une saisie ne part jamais sous la session d'un autre. Une opération ne garde que ce qu'elle change (`ResultChange`) ; deux saisies du même couloir en attente fusionnent (la dernière gagne champ par champ).
  - **Lecture-modification-écriture** : à l'envoi, la place puis le résultat sont relus, la modification appliquée, puis `statut`, `complement` et `tempsLive1..3` renvoyés (avec `id`, `serie`, `engagement` et `points`). Un `statut` omis retomberait à 3. **`temps` et `rang` ne sont jamais envoyés** : omis, le site les garde, alors que les renvoyer écraserait un temps publié par le juge entre notre lecture et notre écriture.
  - **Les paramètres d'écriture passent dans l'adresse** : un corps JSON répond HTTP 500.
  - **Hors ligne ou portail captif** (réponse non JSON), 5xx, 408, 429 : jamais un refus, nouvel essai (5 s, 15 s, puis 60 s). Les autres échecs hors réseau (résultat illisible, `UnknownException`) comptent dans `faults` : au bout de `maxFaults` (5), l'opération est refusée avec un code (`OutboxRejection`), pour qu'une seule ne bloque pas la file. Un refus du site (`ApiException`) est immédiat. Un refus d'authentification arrête la file jusqu'au changement de session.
  - Une opération refusée reste jusqu'à `retry(id)` ou `dismiss(id)`. Une opération envoyée est écartée après 24 h (`sentRetention`).
  - Un couloir validé par le juge (`temps` > 0) est en lecture seule, et un envoi qui le trouve ainsi est refusé (`validatedByJudge`).
  - Une place relue, ou son résultat, qui porte un autre engagement que la saisie (série recomposée par le bureau) fait refuser l'opération aussitôt (`placeChanged`), sans compter dans `faults` ; comme `validatedByJudge`, elle ne se réessaie pas (`canRetryRejection`).
  - Une file enregistrée illisible est mise de côté (`backup`) avant d'être remplacée ; rien n'est écrit par-dessus tant qu'elle n'a pas été relue.
- **Temps manuel** (`domain/manual_timing.dart`) : 1 chrono donne ce chrono ; 2 donnent la moyenne arrondie au centième le plus proche, demi vers le haut (notre convention, V3 n'ayant pas encore ce calcul) ; 3 donnent la médiane. Les chronos nuls ou à 0 sont ignorés (un chrono vidé est servi `0`). Il n'est montré qu'aux officiels connectés, à l'écran de saisie et dans le détail d'un créneau (`getHeatChronos`, une requête par série, 6 au plus en vol, jamais pour un spectateur), avec le libellé « manuel, non définitif ». Une place avec un temps publié, un statut autre que OK ou un forfait n'en montre pas.

## Règles

- Analyseur : `strict-casts`, `strict-raw-types`. Pas de `dynamic` implicite, pas de `fromJson` écrit à la main.
- Pas de test de widget. On teste le domaine, les mappers, les repositories et les fournisseurs (mocktail, `fake_async` pour les minuteries).
- Une page ne contient pas de logique testable : elle la prend à une fonction pure ou à un fournisseur.
- Traductions : `lib/core/l10n/app_fr.arb` fait référence, `app_en.arb` a exactement les mêmes clés, sans clé morte. Après modification : `flutter gen-l10n`.
- « Eau plate » partout en français, jamais « Piscine ».
- Le dernier élément d'un écran ne passe jamais sous la barre de navigation du téléphone : ajouter `MediaQuery.of(context).viewPadding.bottom` au bas d'une liste défilante.
- Les commentaires disent pourquoi, jamais ce que fait la ligne suivante.
- Erreurs : on attrape `AppException`, jamais `Exception` brut.

## API FFSS

- Surface : `../docs/FFSS_API.md`. Faits vérifiés (qui l'emportent sur la doc) : `../docs/FFSS_API_CONTRACT.md`. Les lire avant d'ajouter un appel.
- **Pour le moment, l'app parle à la recette** (`site.ffss.io`, `AppEnvironment.development`), debug comme release : c'est là que FFSSCompetition V3 publie ses compétitions de test (décision du 2026-10-17, `appConfigProvider`). L'app reste sur la recette pendant le lot 4 (décision de l'utilisateur) : le choix de l'environnement dans l'app est reporté à un lot ultérieur ; repasser en production avant toute diffusion. Les préférences liées au serveur (favoris, compétition active) sont préfixées `dev_` ; la langue est une clé globale.
- **Langue** : `appLanguageProvider` (onglet Mon espace) — langue du téléphone, français ou anglais, enregistrée sous la clé globale `language`. Langue du téléphone non prise en charge → français (`resolveAppLocale`).
- `type=3` sur `competition/evenement` rend les trois spécialités.
- `MeetingRepository` lit les courses **dans la réponse `reunion`**, sans appeler `creneau/:id/course` (cassée depuis le 2026-08-31). À revoir si la route est réparée et que les courses portées par `reunion` s'avèrent tronquées.
- **Couloirs** : les réponses `reunion` et `creneau` portent des places vides ; `getLanes` lit `course/place/:id` une à une, 6 au plus en vol ; clé absente = échec. Retirer ce contournement (dans le repository seul) quand `creneau/:id` rend les places complètes (demande envoyée au développeur de l'API le 2026-10-17, avec `complement` et le code `Statut`).

## Tests

- `test/fixtures/recette_1416/` : vraies réponses de la recette, réduites et pseudonymisées (`ATHLETE Un`…). Ne jamais y commiter de donnée personnelle.

## Lacunes connues

- `requestToken` avec un corps de formulaire n'est pas encore vérifié sur une vraie connexion (les tests ne parlent pas au serveur).
- Les lignes de `serie/:id` portent-elles `Statut`, `complement` et `Temps` ? Non vérifié sur la recette : `getHeatResults` et les chronos en dépendent.
- Le `complement` ne s'efface pas côté site : l'app ne l'affiche que sur une DQ.
- Entre la relecture d'un résultat et son écriture, le juge peut changer le `statut` (ou le `complement`) : l'écriture, qui doit renvoyer le `statut` sous peine de le voir retomber à 3, écrase alors le sien. Cette fenêtre ne peut pas être évitée avec cette API (pas d'écriture conditionnelle ni de champ omis conservé pour `statut`).
- Les minuteries (30 s, 60 s pour le Live) ne s'arrêtent pas quand leur écran est caché : l'`IndexedStack` du `StatefulShellRoute` garde les branches montées, donc le programme d'un onglet quitté continue d'être relu, et un détail de créneau resté ouvert sous un autre onglet continue de relire ses places ; le Live caché relit de même le programme et ses places. La carte en direct n'ajoute pas d'appel : `nowRunningProvider` se tire de `programmeProvider`.
- Le paramètre `saison` n'est pas envoyé (la doc le dit désactivé). À vérifier au journal réseau si la liste de l'accueil semble incomplète.

## Commandes

Depuis `live_ffss.v2/` :

    flutter test
    flutter analyze
    dart format lib test
    dart run build_runner build --delete-conflicting-outputs
    flutter gen-l10n
    flutter run -d chrome

Outils : Flutter 3.47.7 / Dart 3.13.5 depuis le 2026-10-17 (go_router 18, freezed 4). Le SDK est le clone git décrit dans la section Tooling pins du CLAUDE.md v1, partagé avec la v1, qui a été gelée en 3.41.9 : pour la recompiler, `git -C <flutterRoot> checkout 3.41.9` puis `flutter --version`. Les fichiers générés (`.freezed.dart`, `.g.dart`, `lib/core/l10n/gen/`) sont commités.
