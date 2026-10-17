# LiveFFSS v2 — Lot 3 : onglet Live

> Spec issue du brainstorming du 2026-10-17. Maquette de référence : *FFSS LIVE — visualisation*, écran 3. Faits d'API vérifiés le 2026-10-17 sur la **recette** (`https://site.ffss.io/api/v1.0/`), compétition **1416**. S'appuie sur le lot 2 (`docs/specs/2026-10-17-lot2-programme-design.md`) : programme, places, place dans la série.

## 1. Intention

L'onglet **Live** sert à **suivre en direct, ou presque, les résultats de la compétition active**. Un spectateur y voit **tout de suite les séries en train d'être courues**, et **les résultats dès qu'ils sont publiés en ligne**. Tant qu'une série n'est pas validée par les juges officiels, l'écran le dit : ses résultats sont **temporaires, en attente de validation**.

### Ce que le lot 3 n'est pas

- **Pas la saisie des temps** : `TempsLive1`, `TempsLive2`, `TempsLive3` servent aux chronométreurs pour saisir les temps à la main (lot 4, Officiel). L'app ne les lit pas.
- **Pas les classements d'épreuve** (lot 5, et § 9 de la spec du lot 2).
- **Pas de notification** : l'onglet se met à jour quand on le regarde.

## 2. Ce que l'API donne (recette 1416)

- Le programme (`GET competition/:id/reunion`, déjà lu par `getProgramme`) porte pour chaque course son statut (`statut` 0 En attente, 1 Marshalling, 2 En cours, 3 Terminé), ses heures prévues, ses places (ids) et, si sa série est générée, un objet `serie` avec un **`label`** : « Série 2 - **Résultats temporaires** ».
- **Deux validations distinctes** :
  1. **FFSSCompetition V3** met la course « En cours » tant que la série n'est pas validée dans le logiciel du bureau, et « Terminé » une fois validée (`ResultPublisher`). Des temps peuvent donc être publiés sur une course « En cours ».
  2. **Le site FFSS** reçoit chaque série « en attente » ; c'est **le juge principal qui la valide sur le site**. Tant qu'il ne l'a pas fait, le libellé de la série se termine par « Résultats temporaires » (`serie/:id` : `Fini` à `null`).
  À la 1416, les 61 courses qui ont une série sont toutes « Terminé » et toutes « Résultats temporaires » : aucune n'a été validée par un juge. **Le libellé d'une série validée n'a pas été observé** : à vérifier sur la première série validée.
- Les places se lisent une par une (`course/place/:id`, contournement du lot 2, 6 en parallèle). Elles donnent couloir, nageurs, club, catégorie, temps (`tempsLabel`), statut et, pour une DQ, son code.

## 3. Décisions

| Sujet | Décision | Origine |
|---|---|---|
| Contenu | **Une liste** : en haut les séries **en cours**, puis les **10 dernières séries courues**, la plus récente en premier | Utilisateur |
| Au-delà de 10 | Pas de pagination dans le Live : un bouton **« Voir tout le programme »** ouvre l'onglet Programme | Utilisateur |
| Carte d'une série courue | **Résultats complets** : tous les nageurs, triés par place (place recalculée, lot 2), DQ et sans-temps en fin de liste | Utilisateur (maquette A) |
| Série en cours | **Liste de départ** (couloir, nageurs, club) et un **texte d'attente** tant qu'aucun résultat n'est publié ; les temps s'affichent dès qu'ils arrivent | Utilisateur |
| Temporaire / validé | **Temporaire** si le libellé de la série contient « Résultats temporaires » **ou** si la course n'est pas « Terminé » ; **validé** sinon. Badge « Temporaire » + bandeau « Résultats en attente de validation par les juges » ; badge « Validé » ensuite | Utilisateur (intention) ; règle : rédacteur, d'après la recette |
| Rafraîchissement | **Toutes les 60 s** tant que l'onglet est affiché ; rafraîchissement manuel en tirant | Utilisateur |

## 4. Écran

De haut en bas :

1. **En-tête** : « Live » et le nom de la compétition active.
2. **Section « En cours »** (si au moins une course est `marshalling` ou `inProgress`) : une carte par course en cours, triées par heure de début prévue.
   - En-tête de carte : épreuve et sexe (`raceName`, `gender`, comme la carte « MAINTENANT »), « Série n / total » et heure prévue, badge **EN DIRECT** (`inProgress`) ou **Chambre d'appel** (`marshalling`) — *choix du rédacteur*.
   - Corps : la liste de départ, triée par couloir (couloir, nageur ou relais, club). Tant qu'aucune place n'a de temps : le texte d'attente « Résultats en attente : ils s'afficheront dès leur publication ». Dès qu'un temps arrive, la carte passe à l'affichage des résultats avec le bandeau de validation, le badge reste **EN DIRECT** (ou **Chambre d'appel**) — *décision du contrôleur après la revue finale*.
3. **Section « Dernières séries »** : les **10** courses « courues » les plus récentes (§ 5), de la plus récente à la plus ancienne. Chaque carte :
   - en-tête : épreuve et sexe, « Série n / total », heure, badge **Temporaire** ou **Validé** ;
   - si temporaire : bandeau « Résultats en attente de validation par les juges » ;
   - une ligne par nageur, **triées par place** (1er, 2e…), puis les lignes sans place (DQ, forfait, sans temps) par couloir : place, couloir, nageur ou relais, club, temps ou statut (« DQ 12 » en rouge), badges de record — mêmes règles que le détail du lot 2 ;
   - une course courue dont aucun temps n'est encore publié : le texte d'attente.
4. **Bouton « Voir tout le programme »** : ouvre l'onglet Programme (`context.go(Routes.programme)`), sans filtre ni défilement — *choix du rédacteur*.
5. Bas de liste : `MediaQuery.of(context).viewPadding.bottom` ajouté.

**Toucher l'en-tête d'une carte** ouvre le détail du créneau dans la branche du Live (`Routes.liveItem`, même page que `Routes.programmeItem` du lot 2) : le retour ramène au Live.

**États particuliers** (*choix du rédacteur*) :
- sans compétition active : le bloc « Choisir une compétition » des autres onglets ;
- compétition **sans eau plate** (côtier seul) : « Côtier : bientôt disponible » (décision 3 du lot 1) ;
- aucune course en cours ni courue : « Aucune série courue pour l'instant », et la prochaine course prévue (épreuve, série, heure) si le programme en a une ;
- erreurs : comme le Programme (premier chargement en échec → écran d'erreur et « Réessayer » ; rafraîchissement en échec → données gardées, message discret).

## 5. Règles (fonctions pures du domaine)

*Précisions du rédacteur après relecture.*

- **En cours** : course `marshalling` ou `inProgress`. Elle reste dans « En cours » même si des temps y sont publiés (V3 la garde « En cours » tant que la série n'est pas validée) : la carte montre alors les résultats et le bandeau de validation, le badge reste EN DIRECT (ou Chambre d'appel).
- **Courue** : course `finished` **dont la série est générée** (`seriesId` non nul). Une course `finished` sans série n'a rien à montrer : elle est écartée **avant** la limite de 10.
- **Résultat publié** (pour passer de la liste de départ aux résultats) : au moins une place avec un temps, une DQ ou un forfait. Un statut « OK » sans temps ne compte pas.
- **Ordre** : `Heat.plannedStart` (date et heure complètes, posées sur le jour de la réunion par le mapper ; à défaut, `MeetingItem.startTime`) décroissante ; à égalité, ordre du programme inversé (réunions, créneaux, courses tels que `getProgramme` les rend). Sans heure : en fin de liste.
- **Limite** : 10 courses courues (`liveRecentLimit = 10`).
- **Temporaire** : course non `finished`, **ou** pas de libellé de série, **ou** libellé contenant « Résultats temporaires » (insensible à la casse). **Validé** : course `finished` dont le libellé de série existe et ne contient pas cette mention. Par prudence, sans libellé on n'affiche jamais « Validé ».
- **Tri des lignes** : par place (`heatPlaces`, lot 2) croissante, puis lignes sans place par couloir.

## 6. Données et état

- **Domaine** : `Heat` reçoit `bool resultsProvisional` (nom proche de `IsPublishedProvisional` de V3), posé par le mapper de la réunion (le `SerieDto` lit `label`) : vrai sans série, sans libellé, ou avec un libellé contenant « Résultats temporaires ». La règle complète « temporaire » (§ 5) y ajoute la course non `finished`.
- **Repository** : rien de nouveau ; `getProgramme` (réunions + déroulements) et `getLanes` (places, 6 en parallèle).
- **Fournisseur** `liveProvider(competitionId)` : lit le programme (`getProgramme`), sélectionne les courses en cours et les 10 dernières courues, lit leurs places, et se relit **toutes les 60 s** tant qu'il est écouté (`autoDispose`), plus le rafraîchissement manuel. Il rend des entrées aplaties (réunion, créneau, course, places) : l'en-tête d'une carte ouvre `Routes.liveItem(competitionId, item.id)`.
  - *Choix du rédacteur* : un `AsyncNotifier` qui garde en mémoire les places déjà lues (comme le détail du lot 2) ; tout est perdu à la fermeture de l'onglet, et relu au retour — acceptable.
  - *Choix du rédacteur* : comme au lot 2, la minuterie tourne tant que la page est montée ; sous l'`IndexedStack` du `StatefulShellRoute`, c'est tant que l'onglet a été ouvert (lacune déjà notée dans le CLAUDE.md : la mise en pause des onglets cachés viendra plus tard).
  - *Choix du rédacteur* : à chaque passage de la minuterie, les places d'une course **validée** déjà lue ne sont pas relues ; celles des courses en cours ou temporaires le sont. Une place en échec garde sa dernière valeur (règle du lot 2).
  - **Une série validée peut encore changer** sur décision du juge principal (précision de l'utilisateur, 2026-10-17) : le **rafraîchissement manuel** (tirer vers le bas) relit **toutes** les places, validées comprises, et rouvrir l'onglet relit tout (l'état est perdu à la fermeture). Si le libellé d'une série redevient « Résultats temporaires », elle redevient temporaire et ses places sont relues à chaque passage.
- La carte « MAINTENANT » de l'accueil mène déjà à l'onglet Live (lot 1) : rien à changer.

## 7. Tests

Pas de test de widget. On teste :
- le mapper : `resultsProvisional` vrai pour « Série 2 - Résultats temporaires » (extrait réel de la recette), vrai sans série ou sans libellé, faux pour un libellé sans la mention ;
- les fonctions pures du § 5 : en cours / courue, ordre, limite de 10, temporaire, tri des lignes (places puis sans place) ;
- le fournisseur (`fake_async`) : relecture toutes les 60 s, arrêt quand plus personne n'écoute, places d'une course validée non relues, place en échec qui garde sa valeur, rafraîchissement en échec qui garde les données.

## 8. Laissé au rédacteur du plan

Découpage en tâches, noms exacts des fournisseurs et fichiers, textes ARB exacts (fr/en), forme visuelle fine (conforme au thème et aux cartes du lot 2).
