# LiveFFSS v2 — Lot 1 : fondations et accueil

> Spec validée section par section en brainstorming le 2026-10-16. Maquette de référence : *FFSS LIVE — visualisation* (13 écrans), écran 1.

## 1. Contexte

La v2 de l'application mobile est une **réécriture** dans un dossier frère, `LiveFFSS/live_ffss.v2/`, sur le modèle de `FFSS-Competition.V3` dans FFSSCompetition.

- **La v1 (`live_ffss/`) est gelée.** Elle est taguée `v1-cotier-final` et ne se modifie plus. Elle gère les épreuves côtières, a été testée en live et fonctionne : elle sert de **référence réutilisable**, et le côtier sera réintégré dans la v2 à partir de son code.
- **La v2 commence par l'eau plate**, pour faire le lien avec l'application de bureau FFSSCompetition V3.
- **Le seul lien avec FFSSCompetition est l'API FFSS.** Le bureau publie le programme, les séries et les résultats ; le mobile les lit, et à partir du lot 4 il en écrit aussi.
- **On reprend FFSSCompetition V3** : noms de classes et d'attributs, règles de calcul, décisions. Le domaine mobile est un **sous-ensemble** du domaine V3. Il garde les mêmes noms et les mêmes attributs, mais n'a que ce que l'API transporte.
- **On applique la règle de V3** : le bon code de la v1 est **copié, jamais partagé**. La v2 ne dépend pas de la v1.

## 2. Découpage en lots

| Lot | Contenu | Écrans de la maquette |
|---|---|---|
| **1** | **Fondations + Accueil** | 1 |
| 2 | Programme public | 2 |
| 3 | Live d'une série | 3 |
| 4 | Connexion + Officiel (composition des séries, saisie des temps) | 7, 11, 12 |
| 5 | Résultats, classements, recherche | 4, 5, 6 |
| 6 | Mon espace, espaces athlète et club | 8, 9, 10 |
| 7 | Organisateur | 13 |

Chaque lot a sa propre spec, son plan et son implémentation. Au lot 4, la gestion de la session doit être reprise : en v1, la connexion se perdait souvent pendant les tests. Le principe de `Ffss/FfssSession.cs` et `FfssSessionStore.cs` de V3, qui fonctionne bien, sert de modèle.

## 3. Décisions

| Sujet | Décision | Raison |
|---|---|---|
| Gestion d'état | **Riverpod** | Une compétition active dont dépendent les onglets, sans code de liaison ; des fournisseurs paramétrés par compétition, mis en cache et libérés automatiquement ; états de chargement et d'erreur prévus par le framework |
| Navigation | **go_router**, `StatefulShellRoute` | Une barre à 5 onglets qui garde la position dans chaque onglet ; des liens directs possibles plus tard (notifications) |
| GetX | **Abandonné** | Le CLAUDE.md de la v1 lui consacre une section entière d'interdits ; une maintenance qui repose sur très peu de personnes |
| Modèles | freezed + json_serializable | Repris de la v1 |
| Traductions | `gen-l10n` (ARB) ; le français est la référence, l'anglais est tenu symétrique | Le système standard de Flutter remplace celui de GetX |
| Persistance | `flutter_secure_storage`, clés préfixées par environnement | Repris de la v1 (règle `AppEnvironment.owner`), sans dépendance de plus |
| Live | Rafraîchissement périodique | L'API ne pousse rien |
| Police | Barlow, **embarquée** dans l'app | Fonctionne hors réseau |
| Thème | Clair uniquement | Conforme à la maquette |

### Décisions sur l'accueil

1. **Les onglets Programme, Live et Résultats suivent une compétition active** : la dernière ouverte, ou par défaut la première du carrousel « EN DIRECT » (voir point 2). Sans compétition active, l'onglet propose d'en choisir une.
2. **Plusieurs compétitions en direct s'affichent dans un carrousel horizontal** : les favoris d'abord, puis la compétition active, puis les autres par date de début. Quand aucune compétition n'est en direct, le carrousel disparaît et « À venir » remonte en tête.
3. **Une compétition côtière s'ouvre** et passe par les écrans génériques : le programme public, construit sur réunions, créneaux et courses, est le même pour toutes les disciplines. Les écrans propres à l'eau plate (live d'une série, saisie) affichent « Côtier : bientôt disponible ».
4. **Une compétition mixte apparaît sous les deux filtres** (Eau plate et Côtier).
5. **« À venir » montre les 5 prochaines compétitions.** « Tout voir » ouvre la liste complète avec recherche.
6. **« Terminées récemment » couvre les 14 derniers jours.**

## 4. Structure du projet

```
LiveFFSS/
├── live_ffss/            ← v1 gelée (référence)
├── live_ffss.v2/
│   ├── CLAUDE.md
│   ├── docs/specs/
│   ├── lib/
│   │   ├── core/         config (environnements), réseau (HttpClient, enveloppe), saison FFSS,
│   │   │                 erreurs, thème, traductions, routeur
│   │   ├── domain/       classes pures nommées comme V3 (sans JSON)
│   │   ├── data/
│   │   │   ├── ffss/         DTO de l'API (noms français mappés) + mappers DTO → domaine
│   │   │   └── repositories/ appels API, pagination, conversion
│   │   └── features/     un dossier par fonction : fournisseurs + widgets
│   │       ├── shell/    barre à 5 onglets, compétition active
│   │       └── home/     accueil
│   └── test/             même arborescence que lib/
└── docs/                 partagé par les deux apps : FFSS_API.md, contrat API
```

- **Une seule direction de dépendance** : `features` → `data` → `domain`. Le domaine ne dépend de rien, comme `Core/Domain` dans V3.
- **Pas de couche « datasource »** : le repository appelle directement `HttpClient` et convertit avec les mappers. En v1, la datasource ne faisait que passer les données au repository ; on la supprime sans rien perdre en testabilité, puisque les tests simulent `HttpClient`.
- **`data/ffss/` joue le rôle de `Core/Ffss` dans V3** : tout ce qui touche au format de l'API y reste confiné.
- **Chaque fonction regroupe ses fournisseurs et ses widgets dans un seul dossier** : pas de double emplacement comme les `module/` et `presentation/` de la v1.

### Copié depuis la v1

`HttpClient` (jeton passé en paramètre `token`, décodage UTF-8 de `bodyBytes`, `success: false` / `"false"`, 403 « Invalid token »), `api_envelope` (`assignedId`, `wasAccepted`), `ffss_season`, `AppEnvironment` et `owner`, la famille `AppException`, et la lecture de l'arbre des réunions avec son contournement de `creneau/:id/course`.

Le contrat API (section « API contract » du CLAUDE.md v1 et `docs/FFSS_API.md`) **remonte dans `LiveFFSS/docs/`**. Ce sont des faits constatés sur de vraies réponses du serveur, et ils valent pour les deux apps.

## 5. Modèle de domaine du lot 1

### `CompetitionSummary`

La même forme que `FfssCompetitionSummary` de V3 (`Ffss/FfssApiModels.cs`), celui qui sert à sa fenêtre « Récupérer une compétition ».

| Attribut | Type | Source dans l'API | Règle |
|---|---|---|---|
| `id` | `int` | `Id` | |
| `name` | `String` | `Nom` | |
| `startDate` | `DateTime` (date) | `Debut` | |
| `endDate` | `DateTime` (date) | `Fin` | absente, ou antérieure au début : prend la valeur du début (comme V3) |
| `disciplines` | `Set<Discipline>` | `Specialite` | 1 → `{coastal}`, 3 → `{flatWater, coastal}`, sinon `{flatWater}`. Sans code : `specialiteLabel` commençant par « C » → côtier, « Mixte » → les deux (règle de `ParseEventDisciplines` dans V3) |
| `organizer` | `String?` | `Organisme.NomOrga`, sinon `Organisme.label` | |
| `location` | `String?` | `Lieu` | absent de `FFSS_API.md`, mais présent dans les vraies réponses (V3 le lit) |

Une compétition sans `Id` ou sans `Nom` est écartée par le mapper, comme le fait V3.

### `Discipline`

`enum Discipline { flatWater, coastal }`, la même que V3 : « Eau plate » partout, jamais « Piscine ». Dart n'a pas d'énumération combinable comme le `[Flags] Disciplines` de C#, d'où le `Set<Discipline>`.

### Premières briques du programme

Elles portent leur nom V3 dès le lot 1, en version minimale ; le lot 2 les enrichit au lieu de les remplacer.

- **`Meeting`** (réunion FFSS) : `id`, `name`, `day`, `startTime`, `endTime`, `items`.
- **`MeetingItem`** (créneau FFSS) : `id`, `name`, `heats`.
- **`Heat`** (course FFSS) : `id`, `name`, `number`, `status`, `plannedStart`, `plannedEnd`, `raceName` (discipline de l'épreuve), `gender`, plus ce qu'il faut pour regrouper les séries d'une même épreuve et d'un même tour.
- **`RunStatus`** : `waiting` (0), `marshalling` (1), `inProgress` (2), `finished` (3). Ce sont les valeurs des constantes de `ResultPublisher` dans V3.

V3 fait passer une course « En cours » dès que son heure de début prévue est passée ou qu'un résultat y est saisi, et « Terminé » quand la série est validée (`ResultPublisher.RunStatus`).

### Règle « maintenant » (fonction pure)

`nowRunning(meetings)` → la série à afficher sur la carte en direct, ou rien :

1. **La dernière série `inProgress`**, d'après `plannedStart`, avec le libellé « MAINTENANT ».
2. Sinon, **la prochaine série `waiting`**, d'après `plannedStart`, avec le libellé « À SUIVRE ».
3. Sinon, rien : la ligne disparaît.

Le « 4/10 » est le rang de la série parmi celles de la même épreuve et du même tour. « Jour 1/3 » se calcule à partir de `startDate`, `endDate` et de la date du jour.

### Hors du domaine

Tout ce qui sert à l'affichage (« 27 – 29 mars 2026 », libellé et couleur des badges, « Jour 1/3 ») va dans des **extensions de présentation**.

## 6. Données et état

### Appels à l'API

| Besoin | Appel |
|---|---|
| Accueil | `GET competition/evenement`, `debut = aujourd'hui − 14 jours`, sans `fin`, pagination automatique |
| Recherche | `GET competition/evenement`, `search`, déclenché 300 ms après la dernière frappe |
| Ligne « MAINTENANT » | L'arbre des réunions de la compétition, **uniquement pour les compétitions en direct** |

On part d'aujourd'hui − 14 jours et non du début de saison : sinon, au 1er octobre, les compétitions terminées la semaine d'avant disparaîtraient de « Terminées récemment ».

`partitionHome(competitions, today)` est une **fonction pure** qui découpe la liste en trois groupes :
- **en direct** : `startDate ≤ today ≤ endDate` ;
- **à venir** : `startDate > today`, par date croissante, puis par nom ;
- **terminées récemment** : `today − 14 j ≤ endDate < today`, de la plus récente à la plus ancienne.

### Fournisseurs (Riverpod)

| Fournisseur | Rôle |
|---|---|
| `competitionRepositoryProvider` | le repository, remplaçable dans les tests |
| `homeCompetitionsProvider` | la liste chargée, découpée par `partitionHome` |
| `homeFilterProvider` | Toutes / Eau plate / Côtier / Mes favoris |
| `favoritesProvider` | les ids favoris, persistés |
| `activeCompetitionProvider` | la compétition active : la dernière ouverte, persistée ; par défaut la première en direct |
| `nowRunningProvider(id)` | la série à afficher pour une compétition, **rafraîchie toutes les 30 s** tant que la carte est écoutée |

Le rafraîchissement s'arrête de lui-même quand la carte n'est plus affichée (fournisseur `autoDispose`). Un geste de tirer vers le bas recharge l'accueil.

### Erreurs

- **Premier chargement en échec** : écran d'erreur avec un bouton « Réessayer ».
- **Rafraîchissement en échec alors que des données sont affichées** : on **garde les données** et un message discret le signale. Au bord d'un bassin, un écran qui se vide à chaque coupure serait pire que des données vieilles de 30 secondes.
- **Ligne « MAINTENANT » en échec** : elle disparaît sans erreur.
- Les erreurs restent la famille `AppException` de la v1, recopiée.

## 7. Écrans et navigation

### Barre à 5 onglets

| Onglet | Au lot 1 |
|---|---|
| Accueil | **complet** (écran 1) |
| Programme / Live / Résultats | avec une compétition active : son en-tête et « Disponible au lot N ». Sans compétition active : « Choisir une compétition », qui renvoie vers l'accueil |
| Mon espace | page « Bientôt » |

### Accueil (écran 1)

De haut en bas :
1. **En-tête** : logo FFSS, « FFSS-LIVE », « Sauvetage sportif en direct », bouton « Se connecter », qui mène à la page « Bientôt » de Mon espace.
2. **Champ de recherche** « Compétition, ville, club… » : ouvre l'écran « Tout voir » avec la recherche.
3. **Filtres** : Toutes / Eau plate / Côtier / Mes favoris. Ils s'appliquent aux trois groupes.
4. **Carrousel « EN DIRECT »** : une carte par compétition en direct, avec le badge, « Eau plate · Jour 1/3 », le nom, le lieu, les dates et la ligne « MAINTENANT » ou « À SUIVRE ».
5. **« À venir »** : 5 lignes (date, nom, organisateur, badge de discipline) et le lien « Tout voir ».
6. **« Terminées récemment »** : les 14 derniers jours.

### Écran « Tout voir »

La liste complète, avec le champ de recherche et les mêmes filtres.

### Navigation

- Toucher une compétition la rend active et ouvre l'onglet Programme.
- Toucher la ligne « MAINTENANT » ouvre l'onglet Live.
- L'étoile d'une compétition l'ajoute ou la retire des favoris.

### Bas d'écran

On garde la règle de la v1 : le dernier élément d'un écran ne passe jamais sous la barre de navigation du téléphone.

## 8. Thème

Les couleurs de la maquette deviennent des **variables de design** : bleu marine (en-têtes, onglet actif), jaune FFSS (accent, « MAINTENANT »), rouge (« EN DIRECT »), fond gris clair, cartes blanches, badges « Eau plate » (bleu pâle) et « Côtier » (vert pâle). Police **Barlow**, embarquée dans l'app.

## 9. Hors lot 1

La connexion et le choix de l'environnement de développement (lot 4, le premier lot qui écrit sur le serveur) ; les notifications ; le mode sombre ; tous les écrans des lots 2 à 7.

## 10. Mise en place du dépôt

- Créer le projet Flutter `live_ffss.v2/` et son `CLAUDE.md`.
- Remonter `docs/FFSS_API.md` et le contrat API dans `LiveFFSS/docs/`.
- Ajouter en tête du `CLAUDE.md` de `live_ffss/` la mention « Référence v1, ne pas modifier ».
- CI : analyse, tests et formatage sur les deux projets (une matrice), pour que la v1 reste au vert tant qu'on y puise du code.

## 11. Tests

Tests avec mocktail, sans test de widget (règle reprise de la v1) :
- `partitionHome` : les bornes de chaque groupe (début ou fin égaux au jour, exactement 14 jours), le tri ;
- la règle « maintenant » : une série en cours, plusieurs séries en cours, aucune série en cours, programme vide, rang « 4/10 » ;
- le mapper `Evenement` → `CompetitionSummary` : `Lieu`, `Specialite` et son libellé de secours, une fin antérieure au début, une compétition sans `Id` ou sans `Nom` écartée ;
- le repository : la pagination, les paramètres envoyés (`debut`, `search`) ;
- les fournisseurs (`ProviderContainer` avec un faux repository) : la compétition active par défaut, le filtre (dont le cas mixte), les favoris.
