# LiveFFSS v2 — Lot 2 : programme public

> Spec issue du brainstorming du 2026-10-17. Maquette de référence : *FFSS LIVE — visualisation*, écran 2. Les faits sur l'API ont été vérifiés le 2026-10-17 sur la **recette** (`https://site.ffss.io/api/v1.0/`), compétition **1416** (Championnats de France N1 2026, 27–29 mars 2026), celle qui a servi aux tests de FFSSCompetition V3.

## 1. Intention

Un spectateur a choisi une compétition. Dans l'onglet **Programme**, il voit **tout le planning, jour par jour**, que les séries soient générées ou non : les réunions de chaque jour et leurs créneaux. Un créneau qui porte une épreuve s'ouvre sur un **détail** qui montre :

- le **déroulement** de l'épreuve (comment on passe des séries aux finales), sous forme de frise ;
- le **contenu des séries** : couloir, nageur ou équipe, club, puis temps, rang officiel et statut dès qu'ils sont publiés.

Le lot 2 est **en lecture seule** et public : aucune connexion.

### Ce que le lot 2 n'est pas

- **Pas le live d'une série** (lot 3) : le suivi d'une seule série, temps qui tombent un par un. Le lot 2 affiche ce qui est publié et se rafraîchit toutes les 30 s.
- **Pas les résultats ni les classements** (lot 5).
- **Pas de classement d'épreuve calculé par l'app** : voir § 9.

## 2. Ce que l'API donne vraiment (recette, compétition 1416)

Ces constats l'emportent sur `../docs/FFSS_API.md`. Ils sont à reporter dans `../docs/FFSS_API_CONTRACT.md` pendant le lot.

| Appel | Ce qu'il porte | Ce qui manque |
|---|---|---|
| `GET competition/:id/reunion` | Toutes les réunions (`Jour`, `Debut`, `Fin`, `Nom`), leurs créneaux (`Nom`, `Debut`, `Fin`), les courses de chaque créneau (`id`, `Nom`, `statut`, `statutLabel`, `debut`, `fin`), pour les courses dont la série est générée un objet `serie` réduit (`id`, `nom`, `niveau`, `fullLabel`, **sans `Numero` ni `epreuve`**), et pour chaque créneau d'épreuve sa **`partie`** (`id`, `ordre`, `niveau`, `nbCourses`, `nbPlaceParCourse`, `nbPlaceQualificative`, `logiqueQualification`), **sans le `deroulement`** | La `partie` est `null` pour les créneaux sans épreuve. Les places des courses ont leur `Numero` mais **`engagement`, `resultat` et `athletes` à `null`** |
| `GET competition/reunion/creneau/:id` | Le créneau, ses courses, et **sa `partie` avec le `deroulement` complet et toutes ses `parties`** (ordre, niveau, `nbCourses`, `nbPlaceParCourse`, `nbPlaceQualificative`, `logiqueQualification`, catégories) | Places vides, comme ci-dessus. **Ni la réunion ni la compétition** : seulement `Id`, `Nom`, `Debut`, `Fin` (heures `HH:mm`), `courses`, `partie` |
| `GET competition/reunion/creneau/course/place/:id` | La place complète : `Numero`, `engagement` (`athletes[]` avec `publicLabel`, `nationaliteCode`, `clubLabel` ; `clubLabel` ; `isForfait` ; `EpreuveCategorie.Epreuve` avec `label` « 200m Obstacles Femme (Cadet) », `genre`, `Discipline.Nom`), `resultat` (`statutLabel`, `tempsLabel`, **`rangLabel`** « 5ème », `performanceLabel`, `isDisqualifie`, `isRecord`, `isRecordDeFrance`) | Le résultat n'a **ni `Rang` numérique, ni code `Statut`, ni `complement`** (QFA, QFB, FF). `rangLabel` est le rang officiel **par catégorie** (ATHLETE Un : « 5ème », 5e des Cadettes de la série 94894). Elle porte aussi des **données personnelles** du licencié (e-mail, date de naissance, numéro de licence) que l'app ne lit pas |
| `GET competition/evenement/:id` | La compétition (essayé sur 1416 : répond) | — |
| `GET competition/serie/:id` | Les résultats d'**une** série FFSS avec leur `Rang` | Pas de couloir. Une course qui mélange plusieurs catégories n'est liée qu'à **la série d'une seule catégorie** (la course 479 « Série 1 » → série 94894, Cadettes seulement) |
| `GET competition/reunion/creneau/:id/course` | — | **Cassée** : `success: false`, « filterByCreneau() only accepts arguments of type … Creneau or Collection » |

Autres constats :
- La liste des réunions **n'est pas triée** par jour.
- Un créneau **sans course** est un créneau sans épreuve : « Ouverture des portes », « Échauffement », « Pause », « Cérémonie »… (35 sur 141 à la 1416). Un créneau d'épreuve a ses courses **dès la création du programme**, avant la génération des séries : ses courses sont « En attente » et sans `serie`.
- Le déroulement réel **se ramifie** : au 50 m mannequin Messieurs, une étape « Séries » toutes catégories (14 × 8, `logiqueQualification: partie`, au temps toutes courses confondues) mène à trois étapes « Finale » (Cadet, Junior, Seniors et Masters), de 2 courses chacune (A et B). `nbPlaceQualificative` vaut 0 partout à la 1416.
- **Une même partie couvre souvent plusieurs créneaux** : « Finale B · … (Cadet) » et « Finale A · … (Cadet) » pointent vers la même partie (36 parties sur 70 à la 1416).
- **Production** : les compétitions eau plate passées de la production (1290, 1339, 1430) n'ont pas de courses publiées dans leur programme, la forme n'a donc pas pu être comparée. L'utilisateur confirme que les deux environnements sont équivalents : la forme de la recette fait foi.
- **Écart avec le lot 1** : `SerieDto` (`lib/data/ffss/dtos/reunion_dto.dart`) lit `Numero` et `epreuve`, absents de l'objet `serie` de la réponse `reunion`. La carte « MAINTENANT » de l'accueil n'a donc ni nom d'épreuve, ni sexe, ni numéro fiables. Le lot 2 corrige ce mapper à partir de l'extrait réel (numéro tiré du `nom` de la course, épreuve et sexe tirés de la `partie` ou du `fullLabel`, au choix du rédacteur du plan, avec tests).
- `GET competition/:id/deroulement` fonctionne (36 déroulements) mais n'est pas nécessaire : `creneau/:id` porte déjà le déroulement du créneau.

Une demande a été faite au développeur de l'API (2026-10-17) : (1) `engagement` et `resultat` dans les places de `creneau/:id`, avec dans `resultat` le `complement` et le code `Statut` ; (2) ~~la `partie` dans la liste des réunions~~ — **demande retirée** : la liste la porte déjà, une première lecture erronée l'avait donnée pour `null` ; (3) la réparation de `creneau/:id/course`. Le lot 2 **n'attend pas** ces changements (§ 6).

## 3. Décisions

| Sujet | Décision | Origine |
|---|---|---|
| Jours | **Un onglet par jour** en haut de l'écran ; le jour courant est sélectionné à l'ouverture | Choix de l'utilisateur (maquette A) |
| Détail d'un créneau | **Frise du déroulement en haut, séries dessous** | Choix de l'utilisateur (maquette B) |
| Frise ramifiée | **Horizontale, en éventail** : une étape qui mène à plusieurs autres les empile à sa droite | Choix de l'utilisateur (maquette A) |
| Frise repliable | La frise peut être **affichée ou masquée** pour prendre moins de place | Demande de l'utilisateur |
| Contenu des séries | **Une requête par place** (`course/place/:id`) en attendant que l'API complète `creneau/:id` | Choix de l'utilisateur |
| Classement d'épreuve, vue Paramètres | Hors lot 2, à rediscuter après la refonte globale (§ 9) | Choix de l'utilisateur |
| Limite avec le lot 3 | Lot 2 = composition et résultats publiés, rafraîchis toutes les 30 s ; lot 3 = suivi en direct d'une seule série | Confirmé par l'utilisateur |

## 4. Écrans

### Onglet Programme (écran 2)

De haut en bas :
1. **En-tête** : « Programme » et le nom de la compétition active.
2. **Onglets des jours** : un par jour qui porte au moins une réunion, libellé court (« Ven 27 », « Sam 28 »…). À l'ouverture : le jour d'aujourd'hui s'il en fait partie ; sinon le premier jour si la compétition n'a pas commencé ; sinon le dernier.
3. **Une carte par réunion du jour**, triées par heure de début : nom, plage horaire. Dans la carte, **une ligne par créneau**, triés comme l'API les donne (*à vérifier : sinon par `Debut`*) :
   - heure de début, nom du créneau ;
   - pour un **créneau d'épreuve** (au moins une course) : un badge d'état et une flèche ›. La ligne s'ouvre sur le détail ;
   - pour un **créneau sans épreuve** : nom grisé, pas de badge, pas de flèche, ne s'ouvre pas.

**Badge d'un créneau d'épreuve**, déduit des statuts de ses courses :
- au moins une course `marshalling` ou `inProgress` → **EN DIRECT** (rouge) ;
- toutes `finished` → **Terminé** (vert) ;
- aucune course n'a de série générée → **Séries à venir** (gris) ;
- sinon → **À venir** (gris).

Sans compétition active, l'onglet garde le comportement du lot 1 (« Choisir une compétition »). Le rafraîchissement manuel (tirer vers le bas) et la minuterie de 30 s s'appliquent comme sur l'accueil.

### Détail d'un créneau

Ouvert par une route enfant de la branche Programme (le bouton retour ramène au jour d'où l'on vient). De haut en bas :

1. **En-tête** : fil « Programme · jour · réunion », nom de l'épreuve (discipline et sexe, tirés du déroulement), étape et heure du créneau.
2. **Frise du déroulement** (si le créneau a une partie) :
   - une case par étape : niveau (« Séries », « Demi-finale », « Finale ») suivi des catégories quand l'étape ne couvre pas toutes celles du déroulement (« Finale Cadet »), et le format « nbCourses × nbPlaceParCourse » ;
   - l'étape du créneau est **en jaune** ;
   - **ramification** : les étapes sont rangées par `ordre` ; les étapes de même niveau qui suivent une même étape s'empilent dans une colonne (cas réel : Séries → trois Finales par catégorie). *Choix du rédacteur* : on regroupe en colonne les étapes consécutives de même niveau ; les cas plus exotiques (demi-finales par catégorie puis finales par catégorie) s'affichent colonne par colonne, sans relier chaque branche à sa source ;
   - sous la frise, **la règle de qualification de l'étape en clair**, tirée de `logiqueQualification` : `partie` → « Classement au temps, toutes séries confondues » ; `course` → « Les N premiers de chaque série » (N = `nbPlaceQualificative`, omis s'il vaut 0) ; `none` → rien ;
   - **repliable** : un toucher sur l'en-tête de la frise la replie en une ligne (« Séries 14 × 8 › 3 finales »). *Choix du rédacteur* : dépliée à la première ouverture, et l'état replié/déplié est retenu pour toute la session (pas d'enregistrement sur l'appareil) ;
   - **Toucher une autre étape ouvre son créneau**, retrouvé dans la liste des réunions par l'id de la partie. *Choix du rédacteur* : si l'étape couvre plusieurs créneaux (Finale B et Finale A), un petit menu les propose, dans l'ordre du programme ; si elle n'en a aucun au programme, la case ne s'ouvre pas.
   - Épreuve à une seule étape : une seule case. Créneau sans partie (cas imprévu) : pas de frise.
3. **Une carte par course** (série), dans l'ordre de l'API : nom (« Série 1 », « Finale A »), heure prévue, badge d'état de la course. Dans la carte, **une ligne par place occupée**, triées par couloir :
   - couloir, nom du nageur (`publicLabel`) ou, pour un relais, le club et les noms des relayeurs, club, catégorie ;
   - quand un résultat est publié : temps (`tempsLabel`) ou statut (`statutLabel` quand ce n'est pas « OK » : DQ, forfait…), **rang officiel avec sa catégorie** (« 5e · Cadet », tiré de `rangLabel` et de la catégorie de l'engagement : le rang est publié par catégorie, pas pour toute la course), et un badge **record** ou **record de France** (`isRecord`, `isRecordDeFrance`) ;
   - **pas de badge de qualification au lot 2** : la place ne porte pas le `complement` (demande n° 1 à l'API) ;
   - les places vides ne s'affichent pas.
   - L'app **ne calcule aucun rang** (choix de l'utilisateur) : elle affiche le rang publié. Les lignes restent triées par couloir.
4. **Avant la génération des séries** (aucune course n'a de série) : « Séries à venir » à la place des cartes ; la frise reste visible.

## 5. Modèle de domaine

On reprend les noms de FFSSCompetition V3 (`Core/Domain`), en version réduite à ce que l'API transporte. Les briques du lot 1 (`Meeting`, `MeetingItem`, `Heat`, `RunStatus`) sont **enrichies**, pas remplacées.

| Mobile (V3) | FFSS | Contenu au lot 2 |
|---|---|---|
| `Progression` | déroulement | `id`, `name`, `gender`, `stages` |
| `Stage` | partie | `order`, `level` (`StageLevel` : heats, quarterFinal, semiFinal, final), `qualification` (`QualificationMethod` : none, byHeat, byStage), `heatCount`, `placesPerHeat`, `qualifyingPlaces`, `categories` (libellés), `ffssId` |
| `MeetingItem` | créneau | ajout de `startTime`, `endTime`. Le `roundId` du lot 1 désigne en fait la partie FFSS : à renommer selon V3 si besoin (dans V3, un créneau pointe vers un `Round`, tour généré, alors que FFSS pointe vers une partie, c'est-à-dire un `Stage`) |
| `Heat` | course | inchangé, plus `lanes` |
| `LaneAssignment` | place | `lane`, les athlètes (nom public, nationalité), club, catégorie, forfait, `performance` |
| `Performance` | résultat | `statusLabel`, `isDisqualified`, temps affiché, rang affiché (`rangLabel`), `isRecord`, `isNationalRecord`. Pas de `PerformanceStatus` au lot 2 : la place ne donne pas le code de statut |

Fonctions pures du domaine, testées sans simulation :
- **`dayTabs(meetings)`** et le choix du jour initial à partir de la date du jour ;
- **`itemStatus(item)`** : le badge d'un créneau (§ 4) ;
- **`progressionColumns(progression)`** : les étapes rangées en colonnes pour la frise ;
- **`qualificationRule(stage)`** : la règle en clair (la phrase elle-même vient des traductions).

## 6. Données et état

### Repositories

- **`MeetingRepository.getMeetings(competitionId)`** : déjà là (lot 1). On y ajoute `startTime`/`endTime` des créneaux.
- **`MeetingRepository.getMeetingItem(itemId)`** (nouveau) : `GET competition/reunion/creneau/:id` → le créneau, ses courses, sa partie et son `Progression`.
- **`LaneRepository.getLane(placeId)`** (nouveau, ou méthode de `MeetingRepository` au choix du rédacteur du plan) : `GET competition/reunion/creneau/course/place/:id`.

**Contournement provisoire** (à retirer quand l'API aura la demande n° 1) : le détail charge d'abord le créneau, puis **toutes ses places**, avec **au plus 6 requêtes en parallèle**. Le repository rend, pour chaque place, soit la place, soit l'échec, sans faire échouer le détail. *Choix du rédacteur* : au premier chargement, une place en échec s'affiche vide ; à un rafraîchissement, elle **garde sa dernière valeur connue** (des nageurs qui disparaissent toutes les 30 s seraient pires qu'une valeur vieille de 30 s). Cette fusion vit dans le fournisseur du détail ; l'appel place par place vit dans le repository, et c'est lui seul qui changera quand `creneau/:id` portera les places complètes.

### Fournisseurs (Riverpod)

| Fournisseur | Rôle |
|---|---|
| `programmeProvider(competitionId)` | les réunions de la compétition, regroupées par jour ; rafraîchi toutes les 30 s tant que l'onglet est écouté |
| `selectedDayProvider` | le jour affiché |
| `meetingItemDetailProvider(itemId)` | le créneau, sa progression, ses courses et leurs places |
| `progressionExpandedProvider` | frise dépliée ou repliée, pour la session |

**Rafraîchissement du détail** (*choix du rédacteur*) : toutes les 30 s, on relit le créneau, puis les places des courses qui ne sont pas « Terminé ». Les places d'une course terminée sont relues **une fois au passage à « Terminé »**, puis **toutes les 2 minutes** tant que le détail est ouvert : V3 ne publie le complément de qualification (`QFA`, `QFB`) qu'une fois toutes les séries du tour validées (`ResultPublisher.ResultsOf`), donc après que les premières séries sont terminées. Le rafraîchissement manuel relit tout.

**Erreurs** : mêmes règles qu'au lot 1. Premier chargement en échec → écran d'erreur et « Réessayer » ; rafraîchissement en échec → on garde les données et un message discret le signale.

### Lacune du lot 1 traitée ici

La compétition ouverte depuis la recherche et absente de l'accueil est oubliée au redémarrage (seul l'id est enregistré). Le lot 2 la relit par **`GET competition/evenement/:id`** au démarrage. Le CLAUDE.md retire la lacune une fois réglée.

### Environnement

L'application parle toujours **à la production** (le choix de l'environnement reste au lot 4). Les tests manuels du lot se font en pointant temporairement la configuration de debug sur la recette et la compétition 1416, sans le commiter. *Choix du rédacteur*, à reprendre si l'utilisateur préfère un réglage commité.

## 7. Navigation

- Toucher un créneau d'épreuve ouvre son détail (route enfant de la branche Programme). *Choix du rédacteur* : la route porte **l'id de la compétition et l'id du créneau**, parce que `creneau/:id` ne donne ni la réunion ni le jour : le fil « jour · réunion » et les heures du créneau (des `HH:mm` à poser sur le jour de la réunion) viennent de `programmeProvider(competitionId)`.
- Le détail est atteignable par lien direct, ce qui servira aux notifications plus tard. Un lien vers un créneau d'une autre compétition **rend cette compétition active**.
- Revenir à l'onglet Programme garde le jour sélectionné (branche du `StatefulShellRoute`).

## 8. Tests

Comme au lot 1 : pas de test de widget. On teste :
- les **mappers** sur des extraits **réels** de la recette 1416 (réunion, créneau 177, place 2816), capturés pendant le lot et placés dans `test/fixtures/`, **après suppression des données personnelles** (e-mail, date de naissance, numéro de licence, adresse) : le dépôt est sur GitHub ;
- les **fonctions pures** (§ 5), dont le cas ramifié du 50 m mannequin et le cas à une étape (lancer de corde) ;
- le **repository** : places chargées 6 par 6, une place en échec n'emporte pas le détail ;
- les **fournisseurs** : minuterie de 30 s avec `fake_async` ; places d'une course relues au passage à « Terminé », puis toutes les 2 minutes seulement ; une place en échec au rafraîchissement garde sa dernière valeur ;
- le **mapper de la réunion du lot 1** corrigé (numéro, épreuve et sexe de la série) sur l'extrait réel.

## 9. À rediscuter après la refonte globale

- **Classement d'une épreuve** : qui est qualifié pour le tour suivant. FFSSCompetition le calcule ; l'utilisateur demande au développeur de l'API de l'exposer pour que le mobile affiche le même. L'app **ne le calcule pas**. Rien n'est réservé à l'écran d'ici là.
- **Vue Paramètres**, réservée aux officiels et aux admins (donc après la connexion, lot 4) : comment les classements sont établis. Point de départ, les réglages de FFSSCompetition : classement club (sauveteurs et relais retenus), limites en finales (étrangers, invités, minimum de licenciés qualificatifs), attribution des points, mode de classement (par temps toutes séries confondues, ou par séries/finales, les finales primant), lignes d'eau du bassin. Le contenu reste à définir par l'utilisateur.
- **Retirer le contournement « une requête par place »**, quand `creneau/:id` portera les places complètes.

## 10. Laissé au rédacteur du plan

- Le découpage en tâches et l'ordre des commits.
- Les noms exacts des fournisseurs, routes et fichiers, dans les conventions du CLAUDE.md.
- La forme visuelle fine (espacements, icônes), conforme au thème du lot 1.
