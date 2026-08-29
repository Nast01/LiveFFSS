# Programme piloté par FFSS — design

**Date** : 2026-08-29
**État** : validé sur le fond, à implémenter

## Le problème

L'onglet Programme compose aujourd'hui un horaire **qui n'existe que sur l'appareil**.
`ScheduleBlock` porte un site, un jour, un ordre et une durée ; `SiteDayStart`
porte l'heure de départ d'un site ; les horaires ne sont jamais stockés mais
recalculés à l'affichage. Rien de tout cela n'atteint le site fédéral, donc rien
n'est partagé entre les officiels d'une même compétition.

FFSS porte pourtant le modèle complet : **Réunion → Créneau → Course**. L'objectif
est que la vue Programme lise et écrive cet arbre, et devienne la source de
vérité partagée.

## Correspondance

| FFSS | Rôle |
|---|---|
| **Réunion** | une journée de compétition |
| **Créneau** | un item de la journée. Sans partie : item manuel. Avec partie : un tour d'épreuve |
| **Course** | une course d'un tour, avec son site, son statut et ses horaires |
| *(aucun)* | les **sites** — l'API n'en connaît aucun, ils restent locaux |

Une **partie** n'est jamais créée ici : elle vient de la vue Structure, et le
créneau ne fait que pointer vers elle. `partie/submit` ne porte d'ailleurs aucun
nom, c'est `creneau/submit` qui en a un.

Un tour donne **un créneau et autant de courses qu'il compte de courses**
(`Partie.NbCourse`). `Creneau.partie` ne pointe qu'une seule partie, ce qui rend
cette arborescence la seule cohérente avec le modèle serveur.

## L'écran

```
┌────────────────────────────────────────────────┐
│  Sam. 12  │ Dim. 13          [ ⏱ Départ 08:00 ]│
│  Sites :  ●Plage  ○Bassin      08:00 → 11:20   │
├────────────────────────────────────────────────┤
│  PLAGE                                          │
│  08:00  Accueil des clubs         10 min   🗑  │
│  08:10  Séries 1 · Surfski · D · Junior  10 🗑 │
│  08:20  Séries 2 · Surfski · D · Junior  10 🗑 │
│                          [ + Ajouter un item ] │
├────────────────────────────────────────────────┤
│ Non planifiées (12)                        ⌃   │
│  Surfski · Dames · Junior                      │
│    Séries 3    Finale               [ + ]      │
└────────────────────────────────────────────────┘
```

**Une frise par site, en parallèle.** Toutes démarrent à l'heure de la réunion.
La fin de la réunion est la plus tardive des frises. « L'heure de fin de
l'élément précédent » s'entend donc **au sein d'un même site**.

## Nommage

Le niveau vient en tête, et la course n'est que le créneau avec son numéro :

- Créneau : `Séries - Surfski - Dames - Junior`
- Course : `Séries 1 - Surfski - Dames - Junior`
- Réunion : `Samedi 12 septembre 2026`

Le nom de la réunion suit **la langue de l'application**, pas une langue forcée.
Conséquence assumée : un appareil configuré en anglais inscrit
`Saturday 12 September 2026` sur le site fédéral.

## Horaires

- Départ d'une réunion : **08:00** par défaut, réglable par le bouton « Départ ».
- Durée d'un item nouvellement ajouté : **10 minutes** — la valeur qu'utilise
  déjà `ScheduleBlock`, pour ne pas dérouter qui connaît l'app.
- Fin d'une réunion : la fin de la dernière course, tous sites confondus. Une
  journée sans item finit à son heure de début.

## Écritures

Chaque geste part immédiatement. Pas d'envoi groupé comme dans l'éditeur de
déroulement : l'heure de fin de la réunion dépend de chaque durée et doit rester
juste à tout instant.

| Geste | Appels |
|---|---|
| Ajouter un item manuel | `creneau/submit` sans partie → `reunion/submit` |
| Planifier une course | `creneau/submit` avec partie si absent → `course/submit` → `reunion/submit` |
| Changer une durée | `course/submit` ou `creneau/submit` → `reunion/submit` |
| Changer « Départ » | recalcul de la journée → `reunion/submit` + un `course/submit` par course décalée |
| Supprimer | `…/delete` → recalcul → `reunion/submit` + les courses décalées |

**Coût à assumer** : décaler l'heure de départ, ou supprimer un item en début de
journée, réécrit **toutes** les courses qui suivent — potentiellement des
dizaines d'appels. D'où un voile de progression comme celui des déroulements, un
envoi séquentiel, et un arrêt à la première panne.

La réunion n'est **pas créée à l'ouverture**. Une journée sans réunion s'affiche
vide, et le premier item ajouté la crée — la création implicite déjà retenue pour
les déroulements.

## Chargement

`GET competition/:id/reunion` renvoie les réunions et leurs créneaux, mais **pas
les courses** : il faut un `GET creneau/:id/course` par créneau.

Deux décisions prises d'avance, à partir de ce que le déroulement nous a coûté :

- **Pagination `start`/`length` dès le départ.** La réponse a la même forme
  DataTables que `deroulement`, qui servait 30 lignes en silence.
- **Chargement des courses en parallèle**, comme les engagés de la vue Structure :
  vingt créneaux ne doivent pas coûter vingt latences bout à bout.

## Paramètres d'API non documentés

`course/submit` accepte `site` et `statut` en plus des champs publiés
(`id`, `nom`, `description`, `jour`, `debut`, `fin`). `statut` vaut 0 à la
création.

Statuts : `0` en attente, `1` marshalling, `2` en cours, `3` terminé. Décodés
vers un enum avec un arm `unknown`, comme le veut la convention du projet pour
tout enum venant de l'API.

## Ce qui reste local

- **Les sites** (`ProgrammeSite`) : aucune API.
- **La sélection des sites d'une journée** : la réunion ne porte pas cette
  information.

Deux appareils ne verront donc pas forcément les mêmes sites ni la même
répartition — la même limite que le marshalling.

## Ce qui disparaît

`ScheduleBlock`, `SiteDayStart` et le planificateur local qui les exploite sont
remplacés par les créneaux et les courses FFSS.

**Un programme déjà composé sur un appareil est perdu et devra être ressaisi.**
Aucune migration n'est prévue : il faudrait deviner à quelle partie rattacher
chaque bloc, et pousser une migration approximative vers un serveur partagé est
pire que de repartir de zéro.

## Découpage proposé

1. **Couche données** — DTO Réunion/Créneau/Course, mapper, datasource,
   repository, avec pagination et les six endpoints.
2. **Lecture** — la vue affiche l'arbre FFSS ; aucune écriture. Vérifiable seul.
3. **Écriture des items** — ajout manuel, durée, suppression, fin de réunion.
4. **Planification des courses** — créneau lié à une partie, courses, palette.
5. **Départ et recalculs** — décalage global et ses écritures en cascade.

Chaque étape laisse l'app utilisable ; la 2 est un point d'arrêt sûr.

## Tests

Datasource : forme des requêtes des six endpoints, pagination, `site` et `statut`.
Mapper : décodage des statuts, créneau sans partie, courses absentes.
Repository : boucle de pagination, chargement parallèle des courses.
Contrôleur : calcul des horaires par site, fin de réunion = maximum des sites,
recalcul après suppression, création implicite de la réunion, refus hors session.

Pas de test widget, conformément à la convention du dépôt.

## Limites connues

- Le nom de la réunion dépend de la langue de l'appareil qui la crée.
- Un décalage de départ sur une grosse journée est long et non transactionnel :
  une panne en cours laisse la journée à moitié réécrite. Le rechargement qui
  suit montre l'état réel, mais l'opérateur devra reprendre.
- Rien ne protège de deux officiels modifiant la même journée en même temps.
