# Flow de création d'un programme — design

**Date** : 2026-09-14
**État** : validé sur le fond, à implémenter
**Remplace** : la partie « écran » et « horaires » de
[2026-08-29-programme-server-backed-design.md](2026-08-29-programme-server-backed-design.md),
dont la correspondance FFSS et le contrat d'écriture restent valables.

## Le problème

L'onglet Programme ne permet pas de **créer une réunion**. Elle apparaît d'elle
même : `ScheduleController._ensureMeeting` la fabrique au premier item posé sur
une journée, la nomme d'après la date (`DateFormat('EEEE d MMMM y')`) et la fait
démarrer à 08:00. Une journée de compétition vaut une réunion, appariée par date.

Trois conséquences :

- **Pas de titre.** « Samedi 12 septembre 2026 » ne dit pas s'il s'agit du matin
  sur la plage ou de l'après-midi au bassin.
- **Une seule réunion par jour**, alors que FFSS n'impose rien de tel.
- **Les sites sont invisibles.** `SitesView` n'a pas de route : on y accède par un
  `Get.to` enfoui dans `schedule_view.dart`. Le site se choisit course par
  course, et la journée s'affiche en frises parallèles filtrables.

L'objectif est un flow explicite en quatre temps — réunion, sites, créneaux,
édition — sans perdre ce que la version serveur a apporté.

## Décisions prises au cadrage

| Question | Décision |
|---|---|
| Modèle de réunion | **N réunions par jour**, titre libre, date choisie parmi les jours de la compétition |
| Forme de la navigation | **Liste de réunions + éditeur** (maître-détail), pas un assistant |
| Portée des sites | **Une réunion = un site.** Toutes ses courses en héritent |
| Où vit le site | Dans la **`description` de la réunion** — donc partagé entre appareils |
| Source de l'épreuve | La **palette des parties déjà poussées** depuis l'onglet Structure. Inchangé |
| Horaires | **Durées libres, heures calculées.** L'invariant bout-à-bout est conservé |
| `engagement` | **`'0'`** sur une place créée libre |

### Pourquoi une liste et pas un assistant

Les quatre étapes sont un **parcours de première fois**, pas une structure
permanente. Une fois la réunion créée, l'opérateur ne veut plus « l'étape 3 », il
veut corriger le créneau de 10 h. Un assistant impose l'ordre mais mentirait sur
la réversibilité : chaque geste part immédiatement sur FFSS, il n'existe aucun
brouillon à valider à la fin. Le parcours est donc porté par des **états vides
qui guident**, et chaque écran reste éditable ensuite.

Les sites, par ailleurs, sont communs à toute la compétition : les redemander à
chaque réunion serait faux.

### Pourquoi le site dans la description

`reunion/submit` ne porte aucun champ site, et l'API n'en connaît aucun. Trois
pistes ont été pesées :

1. **La `description` de la réunion.** Champ libre qui fait déjà l'aller-retour
   complet (`MeetingDto.Description` → `Meeting.description` → `submitMeeting`) et
   que l'app remplit aujourd'hui toujours de la chaîne vide. Source unique, et
   surtout **partagée** : c'est un gain sur l'état actuel, où les sites sont
   purement locaux et où deux téléphones ne voient donc pas le même programme.
2. Un `Map<meetingId, site>` local. Aucun champ d'API détourné, mais rien n'est
   partagé, et des entrées orphelines s'accumulent dès qu'une réunion est
   supprimée ailleurs.
3. Dérivé de `course.site`, avec un mémo local pour la réunion encore vide. Or il
   faut le site *pour* créer la première course : le mémo devient obligatoire et
   l'on retombe sur la piste 2, plus une dérivation — deux sources de vérité.

**Retenu : la piste 1.** Le coût assumé est qu'une description saisie sur ffss.fr
se relit comme un nom de site, et sera écrasée à la première édition.

## Modèle

| Aujourd'hui | Après |
|---|---|
| Une réunion = un jour, appariée par date (`meetingFor(day)`) | **N réunions, identifiées par leur id.** Le jour n'est plus qu'un groupement d'affichage et la contrainte du sélecteur de date |
| Nom dérivé de la date | **Titre saisi**, libre |
| Création implicite (`_ensureMeeting`) | **Création explicite** |
| Début à 08:00 en dur, réglable après coup | **Heure de début saisie à la création** (08:00 proposé) |
| `description: ''` toujours | **`description` = le site de la réunion** |
| Site choisi par course, frises parallèles, filtre par site | **Le site vient de la réunion.** Plus de frises parallèles ni de filtre |
| `ProgrammeSite` local, liste globale à la compétition | Inchangé — devient le **sélecteur** du site d'une réunion |

`competitionDays()` et `sameDay()` restent. Sur le domaine, un accesseur nommé
évite que `description` se fasse lire comme un site au petit bonheur :

```dart
extension MeetingSite on Meeting {
  /// FFSS ne porte aucun site sur une réunion : la description le transporte.
  /// Toutes les courses de la réunion sont créées sur ce site.
  String get site => description;
}
```

Il vit dans `meeting.dart` et non dans une extension de présentation : c'est une
relecture sémantique d'un champ du domaine, pas un formatage, et un contrôleur en
a besoin pour créer ses courses.

`SiteType` (`cotier` / `sable`) et le blob local `CompetitionProgramme` ne
changent pas.

## Écrans

Quatre écrans, dont un existe déjà. L'onglet `Programme` garde ses deux pastilles
`Structure | Programme`.

### ① Liste des réunions — l'onglet Programme

```
Structure  [Programme]              ⚙ Sites (3)
─────────────────────────────────────────────
 ⚠ 12 tours non planifiés
 SAM. 12 SEPT.
  Matin — Plage                              ›
  08:00 → 11:20 · 6 items
  Après-midi — Bassin                        ›
  14:00 → 16:30 · 4 items
 DIM. 13 SEPT.
  ┄ aucune réunion ┄
          + Nouvelle réunion
```

Le compteur de tours non planifiés est **informatif et non cliquable** : placer un
tour demande une réunion cible, geste qui n'a de sens que dans l'éditeur.

### ② Formulaire de réunion — `/programme/meeting-form`

Création *et* édition, même écran.

```
‹  Nouvelle réunion
─────────────────────────────────────────────
 Titre      [ Matin — Plage              ]
 Date       [ sam. 12 sept. 2026       ▾ ]
 Début      [ 08:00                     ]
 Site       ( Plage ) ( Bassin )  + gérer
                                  [ Créer ]
```

Le sélecteur de date est **restreint aux jours de la compétition**. Le sélecteur
de site liste les `ProgrammeSite` locaux ; vide, il renvoie vers ④.

### ③ Éditeur de réunion — `/programme/meeting`

```
‹  Matin — Plage                          ✎
   sam. 12 sept. · 08:00 → 11:20
─────────────────────────────────────────────
 ≡ 08:00  Accueil des clubs        10′   🗑
 ≡ 08:10  Séries 1 · Surfski D Junior 10′ 🗑
 ≡ 08:20  Séries 2 · Surfski D Junior 10′ 🗑
   + Item manuel        + Depuis une épreuve
─────────────────────────────────────────────
 NON PLANIFIÉ (12)                        ⌃
  Surfski · Dames · Junior
    Séries 3        Finale            [ + ]
```

Les heures de la colonne de gauche sont **calculées, jamais saisies**. Seules la
durée et l'ordre (glisser-déposer) s'éditent ; `✎` ouvre ② pour le titre, la date,
le site et l'heure de début.

### ④ Sites — `/programme/sites`

La `SitesView` existante, enfin routée au lieu du `Get.to` enfoui, et atteignable
aussi depuis le sélecteur de ②.

### Le parcours des quatre étapes

① vide → « Aucune réunion, commence par en créer une » → ② (dont le sélecteur de
site vide renvoie vers ④) → ③ vide → « Aucun item, ajoute un item ou une
épreuve ». L'ordre est suggéré par les états vides, jamais imposé.

## Découpage

`ScheduleController` porte aujourd'hui l'arbre serveur, la palette, la frise, les
écritures et le repacking — 912 lignes. Il éclate en quatre pièces.

### `MeetingService` — `lib/app/data/services/`

```dart
load(competitionId) → RxList<Meeting> meetings
```

Nouveau propriétaire de l'arbre réunion. Symétrique de `ProgrammeService` (même
forme : `load(competitionId)` plus un état observable) et pour la même raison :
**deux contrôleurs ont besoin du même arbre**. L'éditeur doit connaître les
parties déjà placées *dans les autres réunions*, sinon il proposerait deux fois le
même tour. Le confier à un service évite un contrôleur qui injecte un contrôleur.

Enregistré `permanent: true` en `InitialBinding`, **étape 4b**, après
`MeetingRepository` dont il dépend.

### `MeetingListController`

L'onglet Programme. Groupe `meetings` par jour, expose les jours de la
compétition, compte les tours non planifiés, crée / édite / supprime une réunion.

### `MeetingEditorController`

Une réunion, par son id. Items, ajout manuel, `scheduleRound`, durées,
réordonnancement, suppression, palette.

### `meeting_timetable.dart` — `lib/app/domain/models/`, fonctions pures

```dart
/// Pose les créneaux bout à bout depuis [startMinutes] et rend, pour chacun,
/// la minute où il commence et celle où il finit — courses comprises.
Timetable layOut(List<Slot> slots, int startMinutes);

/// Les seuls items dont l'horaire a bougé entre [current] et [target].
List<TimetableMove> moves(Timetable current, Timetable target);
```

C'est le gain réel du découpage. `_resequenceDay` **calcule et écrit dans la même
boucle**, ce qui la rend intestable et enfouit le « n'envoyer que ce qui bouge »
dans un `if`. En pur, le calcul se teste sans un seul mock et le contrôleur se
contente d'exécuter les `moves`.

Les règles que ces fonctions portent, déjà vraies aujourd'hui et à préserver :

- La durée d'un créneau **portant des courses** est la somme de ses courses, et
  non son propre `fin - debut` : FFSS conserve l'étendue avec laquelle il a été
  créé, et la lire laisserait la place qu'une course supprimée occupait.
- Une réunion sans item **finit à sa propre heure de début**.
- Un créneau ne porte aucun rang côté FFSS : **son heure de début EST sa place**
  dans la journée. Réordonner et recompacter sont donc le même geste.
- Un item nouvellement posé — manuel ou tour d'épreuve — **commence à la fin de
  la réunion**, et une durée par défaut de 10 minutes par course.

## Écritures FFSS

Chaque geste part immédiatement — invariant conservé : l'heure de fin de la
réunion doit rester juste à tout instant.

| Geste | Appels |
|---|---|
| Créer une réunion | `reunion/submit` — `nom`=titre, `jour`=date, `debut`=heure saisie, `fin`=`debut`, `description`=site |
| Éditer titre / site | `reunion/submit` avec `id` |
| Éditer date / heure de début | `reunion/submit` + un `creneau/submit` et un `course/submit` par item décalé (`moves`) |
| Supprimer une réunion | `reunion/:id/delete` — **à sonder**, voir limites |
| + item manuel | `creneau/submit` sans `partie` → `reunion/submit` (fin) |
| + épreuve | `creneau/submit` avec `partie` → *n* × `course/submit` (`site` = celui de la réunion) → *n* × `spotsPerRace` × `place/submit` avec **`engagement: '0'`** → `reunion/submit` (fin) |
| Durée d'un item | `creneau/submit` ou `course/submit` → `moves` → `reunion/submit` |
| Réordonner | `moves` seulement → `reunion/submit` |
| Supprimer un item | `…/delete` → `moves` → `reunion/submit` |

### `engagement` : trois valeurs, pas deux

Le passage à `'0'` demande de séparer deux intentions que `submitLane` confond
derrière un seul `int? entryId`, où `null` signifie à la fois « place créée
libre » et « libérer cette place » :

```dart
Future<int> submitLane({
  required int runId,
  required int number,
  /// `'0'` pour une place créée libre, `''` pour LIBÉRER une place occupée
  /// (vérifié le 2026-09-03), l'id de l'engagement pour l'asseoir. Trois
  /// valeurs distinctes parce que FFSS y répond différemment.
  required String engagement,
  int? id,
});
```

`createDefaultLanes` passe `'0'`, `syncLanes` passe `''` ou l'id : le choix remonte
au repository et la datasource arrête de deviner.

**`resultats = 0` n'a aucune écriture à changer.** Rien ne crée de résultat à la
création d'une course, et `course/submit` envoie déjà `statut: '0'`. La contrainte
est déjà tenue ; seul `engagement` change.

## Ce qui disparaît

| Supprimé | Remplacé par |
|---|---|
| `ScheduleView` (843 l.) | `MeetingListView` + `MeetingEditorView` + `MeetingFormView` |
| `ScheduleController` (912 l.) | `MeetingService` + `MeetingListController` + `MeetingEditorController` + `meeting_timetable.dart` |
| `_SiteChips`, `_SiteChip`, `selectedSite`, `showsSite`, `siteNamesFor`, `_knownSiteNames`, `_ensureValidSite` et son `Worker` | rien — **une réunion = un site** fait tomber tout le filtrage par site |
| `_DayChips`, `_DayRangeHeader` | les en-têtes de jour de la liste |
| `_ensureMeeting` | la création explicite |
| `meetingFor(day)`, `endMinutesOfDay(day)` | leurs équivalents par réunion |
| `DaySection` et le regroupement par site de `day_sections.dart` | `DayEntry` survit seul — l'éditeur liste les items dans l'ordre |

`SitesController` et `SitesView`, eux, ne changent pas d'une ligne : ils sont
simplement routés.

Environ **1 300 lignes retirées** pour moins réintroduit, dont une partie pure et
testable sans mock.

## Migration

**Aucun script, aucune perte.** Les réunions déjà créées par l'ancien flow
réapparaissent dans la liste avec leur nom dérivé de la date et **sans site**
(description vide). Elles s'éditent comme les autres : `✎`, un titre, un site.
Leurs courses existantes gardent le site avec lequel elles ont été créées.

Le blob local `CompetitionProgramme` ne change pas de schéma — `sites`,
`structures`, `nextLocalId` intacts. Rien à migrer côté appareil.

## Routes

Trois routes nouvelles, chacune avec son `GetPage` et son binding, conformément à
la règle « toute route déclarée est joignable » :

- `Routes.programmeMeetingForm = '/programme/meeting-form'`
- `Routes.programmeMeeting = '/programme/meeting'`
- `Routes.programmeSites = '/programme/sites'`

`MeetingEditorController` est construit par injection depuis son binding, avec
`Get.find<MeetingService>()` : `MeetingService` étant `permanent`, l'éditeur ne
dépend pas de la présence de `/programme` dans la pile.

## Discipline des contrôleurs

Les règles du `CLAUDE.md` s'appliquent sans exception nouvelle :

- Les sélecteurs de date et d'heure de ② vivent dans la vue, avec son `context` —
  aucun `Get.context!`.
- Les noms de réunion, de créneau et de course sont composés **par la vue** :
  nommer un tour demande le genre, donc un `.tr`, que le contrôleur ne fait
  jamais. C'est déjà le contrat de `scheduleRound(name:, courseNames:)`.
- Les messages passent par `Rxn<UiMessage>` et `showUiMessages`, jamais par
  `Get.snackbar`.
- Les `TextEditingController` du formulaire ② appartiennent à une vue
  `StatefulWidget`.

## Tests

Convention du projet : mocktail, pas de test de widget.

| Fichier | Ce qui est vérifié |
|---|---|
| `test/data/models/meeting_timetable_test.dart` | bout-à-bout depuis l'heure de début ; durée d'un créneau à courses = somme de ses courses ; réunion vide finissant à son propre début ; `moves` ne renvoyant **que** les items déplacés |
| `test/data/services/meeting_service_test.dart` | `load`, rechargement, état après échec |
| `test/presentation/modules/programme/controllers/meeting_list_controller_test.dart` | groupement par jour, N réunions le même jour, jour sans réunion, création / édition / suppression |
| `test/presentation/modules/programme/controllers/meeting_editor_controller_test.dart` | item manuel ; `scheduleRound` → **site hérité de la réunion** et **`engagement: '0'`** sur chaque place ; durée → `moves` ; suppression du dernier item d'un créneau |
| `test/data/repositories/meeting_repository_test.dart` (étendu) | `createDefaultLanes` envoie `'0'`, `syncLanes` envoie `''` pour libérer |
| `test/data/datasources/meeting_remote_datasource_test.dart` (étendu) | `submitLane` transmet `engagement` tel quel |

`schedule_controller_test.dart` disparaît avec son contrôleur ; ses cas utiles
migrent vers les deux nouveaux fichiers.

## Limites connues (documentées, pas des bugs)

- **Pas de suppression de réunion** tant que la route n'est pas confirmée.
  `ApiEndpoints` ne porte que `meetingSubmit` et `meetingList` ; par symétrie avec
  `creneau/:id/delete`, la route serait `competition/reunion/:id/delete`, mais rien
  ne le confirme. **Première tâche du plan** : la sonder sur l'environnement de
  développement, journal HTTP à l'appui. Si elle répond, on la câble ; sinon la
  liste n'offre pas de suppression et cette limite reste.
- **La liste des sites reste locale** : deux appareils ne proposent pas les mêmes
  choix. Seul le site *retenu* est partagé, via la description.
- **Une réunion issue de l'ancien flow n'a pas de site** jusqu'à ce qu'on l'édite,
  et peut porter des courses sur plusieurs sites. Aucune réconciliation : réécrire
  le site de courses existantes serait une surprise.
- **Deux réunions du même jour peuvent se chevaucher** sans avertissement. Sur des
  sites différents c'est légitime, et détecter le cas fautif ne vaut pas sa
  complexité ici.
- **Une description saisie sur ffss.fr se relit comme un nom de site**, et sera
  écrasée à la première édition de la réunion.
- **`GET creneau/:id/course` reste cassé** ; `MeetingRepository._getAllRuns`
  garde son repli sur les courses portées par la réponse `reunion`. Ce design n'y
  touche pas.
- **Vérification sur appareil** : ni toolchain Visual Studio ni appareil Android
  ici, donc le parcours réel revient à l'utilisateur.
