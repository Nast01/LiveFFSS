# LiveFFSS v2 — Lot 4 : connexion et saisie officiel

> Spec issue du brainstorming du 2026-10-18. Maquette de référence : *FFSS LIVE — visualisation*, écrans 7, 11 et 12. Premier lot qui **écrit** sur le serveur FFSS. S'appuie sur les lots 2 (programme, places) et 3 (Live).

## 1. Intention

Un **officiel** se connecte avec **son compte FFSS**. Sur une compétition où il est **déclaré officiel**, il peut, couloir par couloir :
1. **saisir les temps pris à la main** par jusqu'à **3 chronométreurs** (`TempsLive1`, `TempsLive2`, `TempsLive3`) ;
2. **saisir une DQ** avec son **code, en texte libre** ;
3. **saisir un forfait**.

La saisie doit être **simple et rapide** : les officiels ne doivent pas prendre de retard sur les courses qui se nagent. **Rien de ce qui est saisi n'est validé** : c'est le **juge des résultats** qui valide dans **FFSSCompetition V3**, qui récupère les temps et calcule le temps final.

Un compte qui n'est **pas** officiel de la compétition garde l'application spectateur, sans saisie.

### Ce que le lot 4 n'est pas

- **Pas de calcul ni d'envoi du temps final** (`temps`) : V3 s'en charge à partir des `TempsLive`.
- **Pas de liste de codes de DQ** venue de l'API (`competition/disqualification` n'est pas renseignée) : champ texte.
- **Pas de composition des séries** par l'app : V3 la publie (confirmé par l'utilisateur le 2026-10-18).
- **Pas de choix d'environnement dans l'app** : l'app reste sur la **recette** (décision du 2026-10-17) ; le sélecteur viendra quand on repassera en production.

## 2. API (doc + contrat ; à vérifier sur la recette avec un vrai compte)

- **Connexion** : `POST /requestToken` (`login`, `password`, sans jeton) → `{ token, expiration }`. Jeton utilisateur valable 24 h, mais le contrat v1 note qu'il **meurt souvent avant** son expiration annoncée.
- **Authentification** : le jeton passe en **paramètre `token`** (query en GET, corps en POST) ; l'en-tête `Authorization` est ignoré.
- **Jeton mort** : **403 `{"error":"Forbiden","message":"Invalid token"}` à l'écriture**, jamais 401 ; à la lecture, le même jeton est servi comme anonyme (200). Une écriture refusée ainsi = session expirée.
- **Compte** : `GET /me` → `{ label, type, data }`.
- **Rôle sur la compétition** : `GET competition/evenement/:id/me` → `{"data": {"roles": [...]}}` ; sans jeton `["public"]` (vérifié le 2026-10-18). Rôles documentés : `public, admin, hote, organisme_participant, licencie, athlete, officiel, juge_principal`.
- **Écriture d'un résultat** : `POST competition/resultat/submit` — `id?` (mise à jour), `serie`, `engagement`, `temps?`, `tempsLive1..3?` (centièmes), `rang`, `statut` (0 OK, 1 DQ, 2 F), `complement` (code de DQ, `F`…), `points?`, `remplacants?`, `place?`.
  - **Risque à lever avant tout envoi réel** : un champ omis est-il conservé ou effacé ? Règle de sûreté (*choix du rédacteur*) : **lire le résultat** (`GET competition/resultat/:id`) puis **renvoyer tous ses champs** avec seulement ceux qu'on modifie changés (lecture-modification-écriture), pour ne jamais effacer un `temps`, un `rang` ou un `complement` posé par V3.
  - Une place sans résultat (`resultat` nul) : création avec `serie` (id de la série de la course) et `engagement` (id de l'engagement de la place).
- **Lecture des temps manuels** : `course/place/:id` ne porte pas `TempsLive1..3` ; `serie/:id` et `resultat/:id` les portent. *À vérifier sur la recette.*

## 2 bis. Faits vérifiés le 2026-10-18 (résumé, détail dans le contrat)

Paramètres d'écriture **dans l'adresse** (pas de JSON) ; **`statut` omis → 3 « F/DQ »** : toujours relire et renvoyer tous les champs ; chrono vidé → `0` (lu comme « pas de chrono ») ; **`complement` impossible à effacer** : « Annuler la DQ » remet `statut` 0 et laisse le code, l'app n'affiche le code que sur une DQ ; jeton invalide → 403. Rôles réels d'un officiel : `officiel {niveau, niveauLabel, principal}` ; rôle non documenté `referent_sportif`. `TempsLive1..3` dans `resultat/:id` et `serie/:id`, pas dans la place.

## 3. Décisions

| Sujet | Décision | Origine |
|---|---|---|
| Qui saisit | Rôle `officiel`, `juge_principal` ou `admin` sur la compétition (`evenement/:id/me`) | Utilisateur (officiel déclaré) ; liste des rôles : rédacteur |
| Champs écrits | **Seulement** `TempsLive1..3` pour les chronos ; `statut` 1 + `complement` (code) pour une DQ ; `statut` 2 + `complement` `F` pour un forfait (valeurs de `ResultPublisher` de V3) | Utilisateur ; codes : V3 |
| Temps manuel affiché | Tant que `temps` est vide : **temps manuel calculé** — 1 chrono → ce temps ; 2 → la **moyenne** ; 3 → la **valeur du milieu** — avec la mention « temps manuel, non définitif » | Utilisateur |
| Code de DQ | **Texte libre** | Utilisateur |
| Écran de saisie | **Un couloir en grand** (3 champs, pavé numérique, séparateurs placés seuls), « Enregistrer et passer à la série suivante » ; filtre de couloir (Tous / 1…n) gardé d'une série à l'autre ; « Tous » → liste des couloirs (Chronos / DQ / Forfait) | Utilisateur (maquette B) |
| Échec d'envoi | La saisie est **gardée sur le téléphone** et **renvoyée toute seule** ; indicateur « en attente d'envoi » sur le couloir ; l'officiel enchaîne sans attendre | Utilisateur (option a) |
| Session | Modèle `FfssSession` de V3 : le mot de passe n'est **jamais** gardé, seul le jeton l'est (stockage sécurisé, clé de l'environnement) ; reprise au démarrage **vérifiée** par `GET /me` ; une écriture refusée en 403 « Invalid token » ferme la session et **demande de se reconnecter sans perdre la file d'envoi** | Spec du lot 1 ; V3 |

## 4. Écrans

### Connexion (écran 7)
Accessible depuis l'accueil (« Se connecter », lot 1) et l'onglet **Mon espace** : identifiant, mot de passe, « Se connecter ». Erreurs lisibles (identifiants refusés, serveur injoignable). Une fois connecté, Mon espace montre le compte (`/me` : `label`, `type`) et « Se déconnecter ».

### Entrée dans la saisie
Pour un compte officiel de la compétition active : un bouton **« Saisir »** sur la carte d'une série (Live, lot 3) et dans le détail d'un créneau (lot 2). Un badge « OFFICIEL » dans l'en-tête de l'écran de saisie.

### Écran de saisie (écrans 11 et 12, maquette B)
- En-tête : épreuve, « Série n / total », heure, état ; **‹ ›** pour la série précédente / suivante (ordre du programme, même tour d'abord — *choix du rédacteur*).
- **Filtre de couloir** : Tous / 1 … n, **gardé** d'une série à l'autre et d'un lancement à l'autre (*choix du rédacteur* : enregistré sur l'appareil par compétition).
- **Un couloir** : nageur ou relais, club, catégorie ; **3 champs** Chrono 1 / 2 / 3 au format `mm'ss"cc`, saisie au **pavé numérique** (chiffres seulement, `'` et `"` placés seuls) ; en dessous, le **temps manuel calculé** et sa règle (« moyenne de 2 », « médiane de 3 »), « non définitif » ; boutons **DQ…** (champ texte du code, Enregistrer) et **Forfait** (confirmation d'un toucher) ; **« Enregistrer et passer à la série suivante »**.
- **Tous** : la liste des couloirs, chacun avec son temps manuel ou son statut (DQ code, Forfait) et les actions Chronos / DQ / Forfait (Chronos ouvre la saisie du couloir en grand).
- Chaque couloir montre son **état d'envoi** : envoyé, **en attente d'envoi**, refusé (avec la raison).
- Mention permanente : « Saisies non définitives — validation par le juge des résultats (FFSSCompetition) ».

### Affichage du temps manuel ailleurs
Le temps manuel est visible **seulement des officiels connectés** de la compétition (décision de l'utilisateur, 2026-10-18) : dans l'écran de saisie et dans le détail d'un créneau. Les spectateurs ne le voient pas, et l'app ne fait donc pas d'appel `serie/:id` supplémentaire pour eux. La place dans la série (lot 2) ne se calcule **pas** sur un temps manuel.

### Corriger une saisie (décision de l'utilisateur, 2026-10-18)
- Un chrono peut être **vidé** (le champ `TempsLiveN` est remis à vide).
- **« Annuler la DQ »** et **« Annuler le forfait »** remettent le statut à OK (`statut` 0, `complement` vide).
- Ces corrections passent par la même file d'envoi.

### Série déjà validée (décision de l'utilisateur, 2026-10-18)
Un couloir dont le résultat a déjà un **`temps`** (posé par le juge des résultats via V3) est **en lecture seule** dans l'écran de saisie, avec la mention « validé par le juge des résultats ». Au moment de l'envoi, si la relecture trouve un `temps` apparu entre-temps, l'opération est **refusée** avec ce motif au lieu d'être écrite.

## 5. Règles (fonctions pures)

- **Temps manuel** : sur les `TempsLive` non nuls et non zéro : 1 → lui ; 2 → moyenne arrondie au centième (*arrondi au centième inférieur ou au plus proche : à confirmer sur V3, `ResultPublisher`/calcul des chronos*) ; 3 → la valeur médiane ; 0 → aucun.
- **Saisie d'un temps** : chiffres seulement, au plus 6 (`mmsscc`), affichés `mm'ss"cc` ; secondes ≤ 59 ; valeur en centièmes.
- **Peut saisir** : rôles `officiel`, `juge_principal`, `admin`.
- **File d'envoi** : chaque saisie = une opération (place, résultat, champs à écrire) ; deux saisies sur le même couloir avant envoi fusionnent (la dernière gagne par champ) ; envoi dans l'ordre ; nouvel essai avec délai croissant ; arrêt sur 403 « Invalid token » (session expirée) jusqu'à la reconnexion ; une erreur métier (`success: false`) marque l'opération **refusée** avec le message, sans bloquer les autres.

## 5 bis. Précisions du rédacteur (relecture du 2026-10-18)

- **Lecture au moment de l'envoi** : une opération en file ne garde que les champs à écrire. Au moment de l'envoyer, le service **relit le résultat** (`resultat/:id`, ou la place si le résultat n'existe pas encore), fusionne et écrit. Une file restée longtemps hors ligne n'écrase donc pas un `temps`, un `rang` ou un `complement` posé entre-temps par V3.
- **Création sans doublon** : pour une place sans résultat, avant d'envoyer (ou de renvoyer) une création, le service relit la place ; si un résultat existe désormais (création précédente arrivée malgré une réponse perdue), il le met à jour au lieu d'en créer un second. L'`id` rendu par une création est gardé pour les opérations suivantes du même couloir.
- **Identifiants d'écriture** : la place doit exposer l'`id` de son résultat et l'`id` de son engagement (à ajouter aux DTO, mapper et `LaneAssignment`) ; l'`id` de la série vient de `Heat.seriesId`.
- **Une file par compte** : chaque opération porte le compte qui l'a saisie et n'est envoyée qu'avec la session de ce compte. « Se déconnecter » avec des opérations en attente demande confirmation (elles restent en attente jusqu'au retour de ce compte, ou sont abandonnées).
- **Connexion** : le jeton stocké est retiré avant `requestToken` (sinon un 403 « Invalid token » sur un jeton périmé interromprait la connexion).
- **Environnement** : tout le lot 4 sur la recette (déjà le cas, CLAUDE.md à jour).
- **Phases** : la première tâche du plan est la vérification manuelle du § 7, faite par l'utilisateur ; le code d'envoi suppose le cas le plus prudent (lecture puis renvoi de tous les champs) tant qu'elle n'a pas prouvé qu'on peut alléger.

## 6. Données et état

- `AuthRepository` (`requestToken`, `/me`), `CompetitionRoleRepository` (`evenement/:id/me`), `ResultRepository` (`resultat/:id`, `resultat/submit`) — noms au choix du plan.
- `sessionProvider` (connecté ou non, compte), restauré au démarrage ; `competitionRolesProvider(competitionId)`.
- **File d'envoi persistante** (stockage de l'appareil, par environnement), traitée par un service qui tourne tant que l'app est ouverte ; reprise au lancement.
- Le Live et le détail relisent les résultats comme aujourd'hui ; la lecture des `TempsLive` se fait par la route qui les porte (§ 2, à vérifier).

## 7. Vérifications sur la recette (avant d'écrire du code d'envoi)

Avec un **compte de test de l'utilisateur**, sur la compétition **1416** de la recette uniquement, et avec son accord à chaque écriture :
1. `requestToken`, `/me`, `evenement/1416/me` (rôles réels d'un officiel déclaré) ;
2. `resultat/:id` et `serie/:id` : présence et forme de `TempsLive1..3` ;
3. `resultat/submit` sur **un** résultat de test : un champ omis est-il conservé ? (confirme ou allège la règle lecture-modification-écriture) ;
4. un jeton expiré → 403 « Invalid token » à l'écriture.
Les faits vérifiés vont dans `../docs/FFSS_API_CONTRACT.md`.

## 8. Tests

Pas de test de widget. Domaine : temps manuel (0, 1, 2, 3 chronos, arrondi), saisie au pavé (chiffres → `mm'ss"cc`, bornes), rôles. Repositories (mocktail) : `requestToken`, rôles, lecture-modification-écriture d'un résultat (champs conservés). Session : restauration vérifiée, expiration sur 403. File d'envoi (`fake_async`) : persistance, fusion, ordre, nouvel essai, arrêt et reprise sur 403, erreur métier isolée.

## 9. Laissé au rédacteur du plan

Découpage, noms, stockage exact de la file, textes ARB fr/en, forme visuelle fine (conforme aux lots 2 et 3).
