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
- **`lib/features/<fonction>/`** : fournisseurs Riverpod, fonctions pures de présentation (`home_view.dart`), extensions de formatage (`competition_formatting.dart`), pages et `widgets/`.
- **`lib/core/`** : `config/` (environnements, endpoints), `errors/` (`AppException`), `network/` (`HttpClient`, `TokenStorage`), `storage/` (`LocalStore`), `providers.dart` (fournisseurs du cœur, dont `clockProvider`), `theme/`, `l10n/`, `router/`.

## État et navigation

- **Riverpod 3.** Fournisseurs déclarés à la main (pas de `riverpod_generator`). Les tests créent `ProviderContainer(overrides: [...], retry: noRetry)` et `main.dart` passe le même `noRetry` (`core/providers.dart`) à `ProviderScope` : Riverpod 3 relance par défaut un fournisseur en échec pendant près de 40 s, ce qui ferait attendre un test et, hors ligne, tournerait le rafraîchissement d'autant. Le rafraîchissement manuel et la minuterie de 30 s tiennent lieu de nouvelle tentative.
- **`clockProvider`** donne l'heure : ne jamais appeler `DateTime.now()` dans un fournisseur ou une page.
- **go_router 17**, `StatefulShellRoute.indexedStack` : une branche par onglet. Les routes sont dans `Routes` (`core/router/app_router.dart`).
- **Compétition active** : `activeCompetitionProvider` (id persisté, résumé en mémoire) ; `currentCompetitionProvider` en déduit la compétition des onglets. On ouvre une compétition avec `openCompetition(...)`.

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
- Au lot 1, l'app ne parle **qu'à la production**, debug compris ; le choix de l'environnement arrive au lot 4.
- `type=3` sur `competition/evenement` rend les trois spécialités.
- `MeetingRepository` lit les courses **dans la réponse `reunion`**, sans appeler `creneau/:id/course` (cassée depuis le 2026-08-31). À revoir si la route est réparée et que les courses portées par `reunion` s'avèrent tronquées.

## Lacunes connues

- Une compétition ouverte depuis la recherche et absente de l'accueil est oubliée au redémarrage (seul l'id est enregistré) : les onglets retombent sur le choix par défaut. Le lot 2 la relira par `GET competition/evenement/:id`.
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
