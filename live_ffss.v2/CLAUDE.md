# CLAUDE.md — LiveFFSS v2

Règles et conventions de la v2 de l'application mobile. Référence pour les sessions Claude futures.

## Contexte

- **Réécriture** de l'application mobile, sur le modèle de `FFSS-Competition.V3` dans le dépôt FFSSCompetition. La v1 (`../live_ffss/`, épreuves côtières, testée en live) est **gelée** au tag `v1-cotier-final` : on y puise, on ne la modifie pas.
- **Le code utile de la v1 est copié, jamais importé.** La v2 ne dépend pas de la v1.
- **Le seul lien avec FFSSCompetition (le bureau) est l'API FFSS.** Le bureau publie programme, séries et résultats ; le mobile les lit.
- **On reprend FFSSCompetition V3** : noms de classes et d'attributs, règles de calcul, décisions. Le domaine mobile est un sous-ensemble du domaine V3 (`FFSS-Competition.V3.Core/Domain`), limité à ce que l'API transporte. Le dossier `Core/Ffss` de V3 est la référence de la correspondance entre l'API et le domaine.
- Specs : `docs/specs/`. Plans : `docs/plans/`. Références par domaine : `docs/reference/` (voir plus bas). Lots : voir la spec du lot 1, § 2.

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

- **Riverpod 3.** Fournisseurs déclarés à la main (pas de `riverpod_generator`). Les tests créent `ProviderContainer(overrides: [...], retry: noRetry)` et `AppContainerHost` (`core/app_host.dart`) passe le même `noRetry` (`core/providers.dart`) à chaque conteneur qu'il crée : Riverpod 3 relance par défaut un fournisseur en échec pendant près de 40 s, ce qui ferait attendre un test et, hors ligne, tournerait le rafraîchissement d'autant. Le rafraîchissement manuel et la minuterie de 30 s tiennent lieu de nouvelle tentative.
- **`clockProvider`** donne l'heure : ne jamais appeler `DateTime.now()` dans un fournisseur ou une page.
- **go_router 18**, `StatefulShellRoute.indexedStack` : une branche par onglet. Les routes sont dans `Routes` (`core/router/app_router.dart`).
- **Compétition active** : `activeCompetitionProvider` (id persisté, résumé en mémoire) ; `currentCompetitionProvider` en déduit la compétition des onglets. On ouvre une compétition avec `openCompetition(...)`.
- Programme, détail d'un créneau, Live, saisies visibles de tous, place dans la série : `docs/reference/programme-live.md`.

## Invariants à ne jamais casser

Le détail et le pourquoi sont dans les références ; ces règles valent partout.

- **Secrets** : le mot de passe n'est jamais gardé, seul le jeton l'est (`TokenStorage`) ; identifiant et mot de passe partent dans un corps de formulaire. Aucun jeton dans un fichier du dépôt, un journal ou un rapport (le journal réseau coupe le chemin avant `?`).
- **Données personnelles** : `Licencie` (e-mail, date de naissance), servi sans jeton par `serie?epreuve=` et les places, n'est jamais lu ni ajouté aux fixtures ; les fixtures sont pseudonymisées.
- **Écritures FFSS** : paramètres dans l'adresse (un corps répond HTTP 500) ; `statut` toujours renvoyé (omis, il retombe à 3) ; `temps` et `rang` jamais envoyés ; `place` envoyée à la création d'un résultat seulement.
- **Rien n'est validé dans l'app** : le juge valide dans V3. Un couloir au temps du juge est en lecture seule.
- **Comptes** : une saisie en file ne part jamais sous la session d'un autre compte ; aucun droit n'est supposé quand les rôles sont illisibles.
- **Eau plate seulement** pour résultats, classements, rappels et forfaits : garde côtier (`isCoastalOnly`) dans les fournisseurs et les pages.
- **Réseau** : 6 lectures au plus en vol ; `ref.mounted` vérifié après chaque `await` ; on attrape `AppException`, jamais `Exception`.

## Références par domaine

À lire **avant** de modifier le domaine concerné (et à mettre à jour avec lui) :

| Fichier | Quand le lire |
|---|---|
| `docs/reference/programme-live.md` | programme, détail d'un créneau, Live, `SerialRefresh`, temps manuel affiché, place dans la série |
| `docs/reference/officiel.md` | connexion, session, rôles, écran de saisie, file d'envoi (`outbox`), temps manuel |
| `docs/reference/resultats.md` | onglet Résultats : rattachement série ↔ course, règles de classement de V3, coût réseau, fiche, recherche |
| `docs/reference/mon-espace.md` | Mon espace, vue club et forfaits (lot 6b), espace officiel, suivis, onglet d'ouverture, rappels, manifeste Android |
| `docs/reference/admin.md` | espace admin, choix du serveur et remontage, journal réseau, contrôle des données, maintenance |
| `docs/reference/lacunes.md` | avant d'annoncer un comportement comme sûr : ce qui n'est pas vérifié ou pas faisable avec l'API |
| `../docs/FFSS_API_CONTRACT.md` | avant tout nouvel appel à l'API : faits vérifiés, qui l'emportent sur `../docs/FFSS_API.md` |

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
- **Par défaut, l'app parle à la recette** (`site.ffss.io`, `AppEnvironment.development`, `defaultEnvironment` dans `core/providers.dart`), debug comme release : c'est là que FFSSCompetition V3 publie ses compétitions de test (décision du 2026-10-17). Un admin peut passer à la production depuis l'app (voir « Espace admin (lot 8) »). **Avant toute diffusion, mettre `defaultEnvironment` sur la production.** Les préférences liées au serveur (favoris, compétition active) sont préfixées `dev_` ; la langue et les autres clés de `AppEnvironment.globalKeys` sont globales.
- **Langue** : `appLanguageProvider` (onglet Mon espace) — langue du téléphone, français ou anglais, enregistrée sous la clé globale `language`. Langue du téléphone non prise en charge → français (`resolveAppLocale`).
- `type=3` sur `competition/evenement` rend les trois spécialités.
- `MeetingRepository` lit les courses **dans la réponse `reunion`**, sans appeler `creneau/:id/course` (cassée depuis le 2026-08-31). À revoir si la route est réparée et que les courses portées par `reunion` s'avèrent tronquées.
- **Couloirs** : les réponses `reunion` et `creneau` portent des places vides ; `getLanes` lit `course/place/:id` une à une, 6 au plus en vol ; clé absente = échec. **Sans jeton** (`HttpClient.get(anonymous: true)`) : cette route répond HTTP 500 dès qu'un jeton est envoyé, quel qu'il soit, alors que les autres lectures l'acceptent (vérifié le 2026-11-12 sur la recette) ; sans cela, un compte connecté ne voyait aucune composition. Retirer ce contournement (dans le repository seul) quand `creneau/:id` rend les places complètes (demande envoyée au développeur de l'API le 2026-10-17, avec `complement` et le code `Statut`).

## Tests

- `test/fixtures/recette_1416/` : vraies réponses de la recette, réduites et pseudonymisées (`ATHLETE Un`…). Ne jamais y commiter de donnée personnelle.

## Commandes

Depuis `live_ffss.v2/` :

    flutter test
    flutter analyze
    dart format lib test
    dart run build_runner build --delete-conflicting-outputs
    flutter gen-l10n
    flutter run -d chrome
    dart run flutter_launcher_icons

Nom affiché sur le téléphone : « FFSS Live » (manifeste Android, `Info.plist`, `web/`, et `appTitle` pour le sélecteur de tâches et l'en-tête de l'accueil). Icône : `assets/images/logo_ffss.png` mis au carré dans `assets/icon/` (`icon.png` plein, `icon_foreground.png` pour l'icône adaptative), générée par `flutter_launcher_icons` (config dans `pubspec.yaml`). Le paquet réécrit `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS` dans `ios/Runner.xcodeproj/project.pbxproj` : annuler ce changement après chaque génération.

Outils : Flutter 3.47.7 / Dart 3.13.5 depuis le 2026-10-17 (go_router 18, freezed 4). Le SDK est le clone git décrit dans la section Tooling pins du CLAUDE.md v1, partagé avec la v1, qui a été gelée en 3.41.9 : pour la recompiler, `git -C <flutterRoot> checkout 3.41.9` puis `flutter --version`. Les fichiers générés (`.freezed.dart`, `.g.dart`, `lib/core/l10n/gen/`) sont commités.
