# Le dossard d'un athlète — design

**Date** : 2026-09-15
**État** : validé au cadrage, à implémenter
**Touche** : le modèle `Athlete`, une route FFSS de plus, les cinq endroits où un
athlète s'affiche, et le contrat du bracelet — écriture comme lecture.

## Le problème

Un athlète porte, sur une compétition donnée, un **dossard** qui l'identifie de
façon unique. L'app ne le connaît pas : ni le modèle, ni les écrans, ni le
bracelet qu'elle écrit. Un marshall qui lit « DUPONT Jean » sur une ligne n'a
aucun moyen de le rapprocher du numéro épinglé sur le maillot qu'il a en face de
lui, et deux homonymes ne se départagent pas.

Le numéro existe pourtant côté FFSS, sur la route
`competition/evenement/:id/participants`, dans le champ `Dossard`.

## Décisions prises au cadrage

| Question | Décision |
|---|---|
| Nom du champ | `Athlete.orderNumber`, **chaîne** — FFSS type `Dossard` en `String`, comme `NumeroLicence` |
| Base API | La base courante (`ffss.fr/api/v1.0/` en prod, `site.ffss.io/api/v1.0/` en dév) ; `api.ffss.fr` n'est qu'un alias |
| Source | Un appel **dédié** à `participants`, par compétition, mémorisé |
| Écriture bracelet | `licence;nom;dossard` — le dossard **ajouté en fin** |
| Lecture bracelet | La **licence identifie**, le dossard **vérifie** |
| Style | Pastille sombre à chasse fixe, **sans préfixe**, masquée quand le dossard est vide |

## Le champ, et ce qu'il couvre gratuitement

Un élément `Participant` a **exactement la forme d'un `AthleteDto`** : `Id`,
`Prenom`, `Nom`, `NumeroLicence`, `Sexe`, `Annee`, `idClub`, `clubLabel`,
`isLicencie`, `isInvite`, `isValid` — plus `Dossard` et `epreuves`.

Donc un seul champ à ajouter au DTO existant :

```dart
@JsonKey(name: 'Dossard') @Default('') String orderNumber,
```

Le champ Dart s'appelle `orderNumber` ; `@JsonKey` ne nomme pas le champ, il dit
quelle clé lire sur le fil. C'est la convention du dépôt (`NumeroLicence` →
`licenseeNumber`) et `CLAUDE.md` l'impose.

`Athlete` gagne le même champ, sans annotation : `@Default('') String orderNumber`.

Ce mapping couvre **trois** routes d'un coup :

| Route | `Dossard` | Ce qui en dépend |
|---|---|---|
| `evenement/:id/participants` | présent | la source dédiée, ci-dessous |
| `evenement/:id/organismes` | présent | l'écran bracelet et l'effectif d'un club, **sans une ligne de plus** |
| `competition/engagement` | **absent** | les quatre écrans de course, d'où la jointure |

`epreuves` n'est pas modélisé : rien ne le lit.

## La source et sa diffusion

```dart
// ApiEndpoints
static const String participantList = 'competition/evenement/:id/participants';

// CompetitionRemoteDataSource
Future<List<AthleteDto>> getParticipants(int competitionId);

// CompetitionRepository
Future<List<Athlete>> getParticipants(int competitionId);
```

Pas de nouveau domaine : même racine `evenement` que `organismes`, et une route
ne justifie pas un triplet DI de plus. Pas de fenêtre `start`/`length` non plus —
`getClubs` appelle la route sœur sans en demander, et fait autorité ici.

**Risque assumé** : FFSS sert 30 lignes par défaut sur les routes en forme
DataTables. Si `participants` plafonne, les athlètes au-delà n'auront pas de
dossard, sans aucun signe à l'écran — le même trou que `CLAUDE.md` documente déjà
pour `engagement`. À vérifier au journal HTTP sur une compétition de plus de 30
participants, et à ne pas « corriger » avant de savoir.

`ParticipantService` — `permanent`, sur la forme de `MeetingService` :

```dart
Future<bool> ensureLoaded(int competitionId, {bool silent = false});
Future<bool> reload({bool silent = false});
String orderNumberOf(int athleteId);   // '' quand inconnu
```

Il ne lit aucun stockage à la construction, donc un `Get.put` synchrone, enregistré
à côté de `MeetingService`.

**Le report se fait là où les clubs sont déjà reportés.** Quatre contrôleurs
appellent `getAthleteClubs` puis recopient le club sur chaque athlète —
`RaceDetailController`, `RaceCourseController`, `RaceStructureController`,
`HeatDrawController`. Le dossard se recopie dans le même geste : un seul endroit
par contrôleur, aucun aller-retour supplémentaire au-delà du premier
`ensureLoaded`.

Un échec de lecture laisse les dossards vides : la pastille disparaît, le reste
de l'écran est intact. Le dossard est un repère, pas une condition.

## L'affichage

`lib/app/presentation/shared/order_number_badge.dart` — pastille sombre, chiffres
à chasse fixe, sans préfixe, **rien du tout quand le dossard est vide**.

Le style doit rester impossible à confondre avec les autres nombres de l'écran :
une place est colorée par son rang, un couloir est un carré bleu pâle, une année
est du texte gris, un statut est une pilule verte ou rouge. La pastille dossard
est la seule forme sombre à chasse fixe.

| Où | Emplacement |
|---|---|
| Ligne d'un athlète déplié — les quatre écrans, via `EntryGroupTile` | avant le nom |
| Ligne d'un engagement **individuel** | avant le titre : c'est un athlète, il porte son numéro |
| Liste de l'écran bracelet | avant le nom |
| Effectif d'un club (détail compétition) | avant le nom |
| Journal de scan | dans le libellé de la ligne |

Une ligne de **relais** n'en porte pas : un dossard appartient à une personne, pas
à une équipe.

## Le bracelet

L'écriture passe de `<licence>;<nom>` à `<licence>;<nom>;<dossard>`
(`bracelet_payload.dart`). Le dossard **en fin** : la licence reste le premier
champ, donc un bracelet déjà écrit reste lisible tel quel.

La lecture garde la licence comme identifiant — c'est le seul qui vaille d'une
compétition à l'autre. Le dossard sert de **vérification** :

- absent du payload (bracelet hérité) → rien à dire, l'athlète est identifié ;
- présent et égal à celui de l'athlète dans cette compétition → rien à dire ;
- présent et **différent** → l'athlète est pointé, et l'app signale
  `bracelet_other_event` : le bracelet vient d'un autre événement et n'a pas été
  réécrit.

C'est ce qui empêche le bracelet de la compétition précédente de passer
inaperçu. Il n'identifie pas, précisément parce qu'un dossard ne vaut que pour sa
compétition : s'en servir comme clé ferait pointer, en silence, l'athlète qui
porte ce numéro **ici**.

Deux contrôleurs lisent les bracelets et doivent appliquer la même règle :
`RaceDetailController._onScanPayload` (marshalling) et
`RaceCourseController._onBracelet` (saisie des places).

## Tests

- `test/data/mappers/athlete_mapper_test.dart` — `Dossard` présent, absent, et
  servi en nombre plutôt qu'en chaîne (l'API l'a déjà fait pour `Annee`).
- `test/data/repositories/competition_repository_test.dart` — `getParticipants`
  rend les athlètes avec leur dossard.
- `test/data/services/participant_service_test.dart` — `ensureLoaded` ne
  recharge pas une compétition déjà tenue, `reload` si, `orderNumberOf` rend
  `''` sur un inconnu.
- Les quatre contrôleurs — le dossard arrive sur les athlètes affichés, et son
  absence ne casse rien.
- `test/core/rfid/bracelet_payload_test.dart` — aller-retour à trois champs, et
  un payload hérité à deux champs toujours lisible.
- `race_detail_controller_test.dart` / `race_course_controller_test.dart` — un
  bracelet dont le dossard diffère pointe quand même l'athlète **et** déclenche
  `bracelet_other_event`.

Pas de test de widget, conformément au dépôt : la pastille se vérifie à l'écran.

## Traductions

Une clé, dans **les deux** langues : `bracelet_other_event`.
