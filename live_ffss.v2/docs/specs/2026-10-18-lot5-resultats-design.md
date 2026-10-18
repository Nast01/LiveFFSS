# LiveFFSS v2 — Lot 5 : résultats, classements, recherche

> Spec issue du brainstorming du 2026-10-18. Maquette de référence : *FFSS LIVE — visualisation*, écrans 4, 5 et 6 (hors dépôt). S'appuie sur les lots 2 (programme, déroulement, places) et 3 (Live). **Eau plate seulement.**

## 1. Intention

L'onglet **Résultats**, vide jusqu'ici, donne pour la compétition active :
1. le **classement de chaque épreuve** (une épreuve = discipline × genre × catégorie, par ex. « 200 m Obstacles · Dames · Cadet ») ;
2. le **classement des clubs** et le **classement individuel des licenciés** (par sexe et par catégorie) ;
3. une **recherche d'athlète** : ses résultats et ses courses pas encore nagées.

Tout est **calculé dans l'app** à partir des résultats que l'API publie, avec les **règles de FFSSCompetition V3**, et marqué **provisoire**. Pour les classements club et licenciés, c'est un **calcul provisoire** pour voir comment l'app se comporte : l'utilisateur doit discuter avec le développeur de l'API (les routes de classement de l'API sont fausses selon lui), et la source sera revue ensuite (décision du 2026-10-18).

### Ce que le lot 5 n'est pas

- **Pas de côtier** : une compétition côtière garde « Côtier : bientôt disponible » dans l'onglet Résultats (décision du 2026-10-18).
- **Pas de Clubs (OPC)** : l'API ne transmet pas le groupe OPC des athlètes (décision du 2026-10-18).
- **Pas de recherche de club**, pas de recherche d'épreuve (décision du 2026-10-18).
- **Pas de lecture des routes de classement de l'API** (`evenement/:id/participant/classement`, `evenement/:id/organisme/classement`) : jugées fausses par l'utilisateur.
- **Pas de vue « Paramètres » officiel** (lot 2) : elle attend la discussion avec le développeur de l'API (décision du 2026-10-18).
- **Pas de composition des séries** depuis l'app (décision du 2026-10-18).
- **Pas d'écriture** sur le serveur.

## 2. API (lue sur la recette le 2026-10-18, compétition 1416, GET seulement)

- **Épreuves** : `GET competition/epreuve?evenement=:id` → `{success, count, data: Epreuve[]}` (60 pour 1416). `Epreuve` : `Id`, `Genre` (`H`, `F`, `M` mixte), `discipline` (`Id`, `label`, `Distance`, `NbAthleteParEquipe` : 1 individuel, ≥ 2 relais ou équipe, `Specialite` 2 eau plate), `categories` (le plus souvent **une** : `Cadet`, `Junior`, `Seniors et Masters`, `Youth`, `Open`).
- **Une série** : `GET competition/serie/:id` (≈ 15 Ko). **Séries d'une épreuve** : `GET competition/serie?epreuve=:id` (≈ 250 Ko). `Serie` : `Id`, `Numero`, `Nom`, `Debut`, `Fin`, `Fini`, `UpdatedAt`, `epreuve`, `resultats[]`.
- **Résultat** (`resultats[]`) : `Id`, `Statut` (0 OK, 1 DQ, 2 F, 3 F/DQ), `Temps` (centièmes, entier), `tempsLabel`, `Rang`, `points` (null), `complement` (`QFA`, `QFB`, `FF`, `HT`, code de DQ…), `isValid`, `Athletes[]` (`Id`, `label`, `nom`, `prenom`, `sexe`, `annee`, `clubLabel`, `nationaliteCode`, `isInvite`, `dossard`…), `engagement` (`Id`, `IdEpreuve`, `categorie {Id, Nom}`, `IdOrganisme`, `clubLabel`).
  - **Données personnelles** : `Athletes[].Licencie` porte l'e-mail et la date de naissance. Ne jamais les lire ni les mettre dans une fixture.
- **Participants** : `GET competition/evenement/:id/participants` → `{success, data: Participant[]}` (346 athlètes, **3,6 Mo** pour 1416). `Participant` : `Id`, `Nom`, `Prenom`, `Sexe`, `Annee`, `clubLabel`, `idClub`, `Dossard`, `isInvite`, `nationaliteCode`, `engagements[] {id, categorie {id, label}, epreuve {Id, …}}`. **Pas de place** (série, ligne) sur un engagement.
- **Engagements** : `GET competition/engagement?epreuve=` ne donne pas non plus la place.
- **Places** : celles des réponses `reunion`/`creneau` sont vides (lot 2) ; `course/place/:id` donne l'engagement d'une place, une requête par place (comme le Live).
- **Finales** : le déroulement (`competition/:id/deroulement`) porte `niveau` (`heat`, `final`) et `niveauLabel` ; les noms des séries de finale commencent par « Finale A » ou « Finale B ».

### Ce que V3 publie (lu dans le code de V3, `Core/Ffss/ResultPublisher.cs`)

- **`Rang`** : en série, la place **dans la série pour la catégorie** ; en finale, le rang final (A 1-8, B 9-16). **Ce n'est pas le rang dans l'épreuve** : l'app le recalcule.
- **`points`** : jamais envoyés.
- **`complement`** : `QFA`/`QFB` une fois toutes les séries du tour validées ; `FF`, `HT`, `F`, code de DQ.
- **Statut de série** : toujours « en attente » ; le **définitif** passe par l'état de la **course** (« Terminé », 3), déjà lu au lot 3 (`isProvisional`).

### Anomalie de la recette

`serie?epreuve=36073` (200 m Obstacles Dames Cadet) rend **22 séries** : les 10 du programme actuel (publiées par V3, octobre, avec un `Debut`) et **12 anciennes** (avril : 10 séries, finales A et B, avec des points, `Debut` nul). Selon l'utilisateur, c'est un reste d'essais sur 1416 qui **ne se reproduira pas** sur une vraie compétition. L'app reste prudente : une série qu'elle ne rattache à aucune course du programme est ignorée (§ 3).

### Le programme ne porte qu'une série par course (relecture du 2026-10-18)

Une course où nagent plusieurs catégories (ex. 200 m Obstacles Dames : Cadet, Junior, Seniors et Masters) ne pointe, dans `reunion`, que vers **la série d'une catégorie** (ex. course 479 → série 94894, Cadet) ; V3 publie **une série par épreuve**, donc par catégorie, et les séries des autres catégories (94897… pour Junior) n'apparaissent ni dans `reunion` ni dans `deroulement`. Les ids d'épreuve de `competition/epreuve` (36073 = Cadet) ne sont pas ceux du déroulement (501 = discipline × genre, catégories 1005/1006/1007) : le lien passe par discipline, genre et catégorie. Les finales sont par catégorie (« Finale A - Cadet »), leur `serie` est nulle tant qu'elle n'est pas générée.

## 3. Décisions

| Sujet | Décision |
|---|---|
| Source des résultats | **`serie?epreuve=:id`** par épreuve (décision du 2026-10-18, option A) : ≈ 250 Ko pour une épreuve ; les classements club et licenciés lisent les **60 épreuves** (≈ 15 Mo pour 1416), une fois puis au rafraîchissement manuel seulement, 6 requêtes au plus en vol. |
| Rattachement série → course du programme | Chaque série d'épreuve est rattachée à une course du programme de la même discipline × genre : par le **tour** (séries / finale A / finale B, d'après le déroulement et les noms) et le **numéro** (`Numero` = numéro de la série dans le tour ; « Série 3 » ↔ course « Série 3 »), avec l'heure (`Debut` ≈ début de la course) comme contrôle. Une série sans course (ex. anciennes séries de 1416, `Debut` nul) est **ignorée**. |
| État d'une série de catégorie | Celui de la **course** à laquelle elle est rattachée : terminée ou non, provisoire ou non (`isProvisional`, lot 3) — choix du rédacteur. |
| Classement d'une épreuve | Calculé dans l'app, règles V3 (§ 5). |
| Classements club et licenciés | Calculés dans l'app, règles V3 (§ 5), **provisoires** ; à revoir après la discussion avec le développeur de l'API. |
| Réglages V3 absents de l'API | Valeurs par défaut de V3 (choix du rédacteur) : étrangers et invités marquent des points ; par club, 3 résultats individuels et 1 relais comptent par épreuve et catégorie. |
| Provisoire / définitif | Une épreuve (catégorie) est **définitive** quand toutes ses séries rattachées sont terminées et non provisoires, sinon **provisoire**. Les classements club et licenciés sont **toujours** marqués provisoires dans ce lot. |
| Rafraîchissement | **Manuel** (geste tirer, bouton) ; pas de minuterie. Les résultats lus sont gardés en mémoire pour la compétition tant que l'onglet vit. |
| Recherche | Participants lus **une fois** à l'ouverture de la recherche (3,6 Mo), filtrés dans l'app. |
| Série et ligne d'une course à venir | **Option A** (décision du 2026-10-18) : bouton « Trouver sa série » qui lit les places de **cette épreuve seulement**, s'arrête dès l'athlète trouvé. |
| Côtier | « Côtier : bientôt disponible ». |

## 4. Écrans

### Onglet Résultats (écrans 4 et 5)

- En-tête : nom de la compétition, **loupe** (recherche). Sans compétition active : comme les autres onglets (proposer d'en choisir une).
- Deux sous-onglets : **Épreuves** et **Classements**.

#### Épreuves (écran 4)

- Choix de l'**épreuve** (liste déroulante : discipline · genre, dans l'ordre du programme), puis **catégorie** en puces (les catégories de cette discipline × genre). Le dernier choix est gardé pendant la session.
- En-tête de liste : « CLASSEMENT PROVISOIRE · CADET » ou « CLASSEMENT · CADET » si définitif, et « n/N séries » (séries terminées / séries **de cette catégorie** rattachées au programme) — choix du rédacteur.
- Une ligne : **rang**, **athlète** (ou relais : équipe = club, athlètes en sous-titre), **club**, **temps** (`MM:SS.cc` comme ailleurs), badge **FA / FB** si qualifié (`QFA`/`QFB` du site, ou finaliste). Les non-classés en bas : `DQ` (avec code, rouge, comme au lot 2), `F`, `FF`, `HT`.
- Toucher un athlète ouvre **sa fiche** (recherche).
- Aucune série lue / aucun résultat : texte d'attente (comme le Live).

#### Classements (écran 5)

- Puces **Clubs** / **Licenciés**.
- **Clubs** : podium des 3 premiers (points), puis liste : rang, club, points, « Écart au précédent −n ». Pied : « Provisoire · n / N séries terminées · calculé à HH:MM ».
- **Licenciés** : puces sexe (Dames / Messieurs) et catégorie ; liste rang, athlète, club, points, nombre de courses.

### Recherche d'athlète (écran 6)

- Champ de recherche (nom, prénom ; sans accent ni casse), résultats au fil de la frappe : initiales, nom, club · catégorie · dossard.
- **Fiche** d'un athlète :
  - **Courues** : par épreuve (dans l'ordre du programme) : heure, épreuve, série (« Série 4 », « Finale B »), ligne si connue, temps, **place dans la série**, **rang provisoire dans l'épreuve** ; ou DQ / F.
  - **À courir** : épreuves où il est engagé sans résultat : heure prévue (première série de l'épreuve au programme), épreuve, bouton **« Trouver sa série »** → série et ligne, ou « Pas encore placé » si aucune place ne le porte.
  - Les **relais** où il figure sont inclus.

## 5. Règles (fonctions pures, `lib/domain/`)

Reprises de V3 (`Core/Ranking/FlatWaterRanking.cs`, `RacePoints.cs`, `Standings.cs`).

- **Rang dans une épreuve** (par catégorie) :
  - **sans finale** : au temps, toutes séries confondues ;
  - **avec finales** : Finale A rangs 1-8, Finale B rangs 9-16 (décalage = nombre de places de finale A courues), puis les autres au temps des séries, décalés du nombre de finalistes ;
  - un tour (séries / finale) se reconnaît au `niveau` du déroulement ou au nom de la série ;
  - **égalités** : même temps, même rang, le suivant sauté (1, 2, 2, 4) ; ordre d'affichage des ex æquo : numéro de série puis ligne ;
  - **classés** : statut OK (0) avec un temps > 0, et `FF` avec un temps (classé en série, pas qualifiable) ;
  - **non classés**, en bas dans cet ordre : FF sans temps, HT, DQ, F, autres ;
  - une **DQ en finale** prend la dernière place de sa finale (8 en A, 16 en B).
- **Points** : barème V3 **20, 18, 16, 14, 13, 12, 11, 10, 8, 7, 6, 5, 4, 3, 2, 1**, 0 au-delà ; ex æquo, mêmes points. Avec finales A et B, les séries ne marquent rien (seules les finales marquent) ; sans finale, les séries marquent ; finale A seule : les non-qualifiés prennent 9-16 au temps des séries. DQ, F, HT : 0.
- **Classement des clubs** : le club d'un résultat est celui du **premier athlète** de l'engagement. Par (club, épreuve, catégorie), seuls comptent les **3** meilleurs résultats individuels et le **1** meilleur relais (points décroissants, puis rang). Total = somme ; ex æquo 1, 1, 3, puis ordre alphabétique.
- **Classement des licenciés** : par (sexe de l'athlète, catégorie de l'engagement), épreuves **individuelles** seulement, tous les résultats comptent ; total des points, nombre de courses ; ex æquo 1, 1, 3, puis nom.
- **Recherche** : correspondance sans accent ni casse sur prénom, nom, « prénom nom » et « nom prénom ».

## 6. Données et état

- `lib/domain/` : classes pures (nommées comme V3 quand elles existent) pour un résultat d'épreuve, une ligne de classement, un classement club / licencié ; fonctions de rang, de points, de cumul.
- `lib/data/` : DTO et mappers pour `serie?epreuve=` (séries et résultats complets), `epreuve?evenement=`, `evenement/:id/participants` ; une ligne illisible est écartée seule (règle du projet).
- `lib/features/results/` : fournisseurs (résultats de la compétition lus série par série, classements dérivés, participants, recherche, « trouver sa série »), pages et widgets. `ref.mounted` après chaque `await` ; `clockProvider` pour « calculé à ».
- Réutiliser : `programmeProvider` (courses du programme, déroulement, état des courses), `parseFfssTime` / libellés de temps, `isProvisional`, `getLanes`, `SerialRefresh` si une relecture est en jeu.

## 7. Tests

Domaine (rangs avec et sans finales, égalités, statuts, points, cumul club et licencié, recherche), mappers (fixtures de la recette **pseudonymisées**, sans e-mail ni date de naissance), repositories, fournisseurs (lecture par épreuve, séries rattachées aux courses, séries orphelines ignorées, rafraîchissement manuel, « trouver sa série » qui s'arrête au premier trouvé). Pas de test de widget.

## 8. À transmettre au développeur de l'API (liste de l'utilisateur)

- Les routes de classement (`participant/classement`, `organisme/classement`) : jugées fausses.
- Les anciennes séries restées sur la recette pour 1416 (`serie?epreuve=36073`).
- Une route qui donne la **place** (série, ligne) d'un engagement.
- Le programme (`reunion`) ne porte qu'une série par course : les séries des autres catégories nagées ensemble n'y sont pas ; une route de résultats plus légère que `serie?epreuve=` (≈ 250 Ko) aiderait.

## 9. Laissé au rédacteur du plan

- Le découpage en tâches, les noms exacts des classes et fournisseurs.
- Le détail du rattachement série ↔ course (tour, numéro, heure) et le lien épreuve (`competition/epreuve`) ↔ discipline × genre × catégorie du déroulement, à vérifier sur les fixtures.
- L'ordre des épreuves dans la liste déroulante si le programme ne le donne pas directement.
