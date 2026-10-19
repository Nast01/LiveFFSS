# LiveFFSS v2 — Lot 6a : Mon espace (lecture)

> Spec issue du brainstorming du 2026-10-18. Maquette de référence : *FFSS LIVE — visualisation*, écrans 8, 9, 10 (hors dépôt), et la visualisation validée le 2026-10-18 (5 écrans : accueil de Mon espace, espace athlète, espace club, espace officiel, mes suivis / infos). Le lot 6 est coupé en deux (décision du 2026-10-18) : **6a en lecture seule**, **6b** pour les écritures du club (forfait, remplacement d'un relayeur). S'appuie sur les lots 4 (connexion, rôles, file d'envoi, saisie) et 5 (classements, fiche d'athlète, « Trouver sa série »).

## 1. Intention

L'onglet **Mon espace** montre, pour la **compétition active**, ce qui sert à la personne selon **son rôle** sur cette compétition :

| Rôle | Contenu (décision de l'utilisateur, 2026-10-18) |
|---|---|
| **Public** (connecté ou non) | Options sur la compétition : mes suivis, infos de la compétition, liste des officiels, préférences (rappel de course, onglet d'ouverture, langue) |
| **Athlète** | Ses informations, son planning, ses résultats |
| **Club / référent sportif** | Informations du club, planning et résultats de tous ses athlètes ; forfaits et relais **en consultation** (écriture au lot 6b, **réservée** à un compte club ou référent sportif du club, ou admin) |
| **Officiel** | Mes saisies (file d'envoi), séries à saisir, DQ et forfaits de la compétition, officiels, accès rapide à la saisie |
| **Admin** | Tout |

Un compte peut cumuler des rôles : chaque espace est une **carte** dans « Mes espaces » (écran 1 de la visualisation).

### Ce que le lot 6a n'est pas

- **Pas d'écriture** : déclarer ou annuler un forfait, remplacer un relayeur → **lot 6b**, après vérification des routes sur la recette avec le compte référent fourni par l'utilisateur.
- **Pas de côtier pour ce qui dépend des résultats** : comme au lot 5, une compétition côtière garde « Côtier : bientôt disponible » pour ce qui dépend des résultats (planning, résultats, séries à saisir).
- **Pas de notification serveur** : les rappels sont **locaux** au téléphone.

## 2. API (doc, contrat, lectures du 2026-10-18 sur la recette 1416)

- **Rôles** : `GET competition/evenement/:id/me?token=` → `data.roles` et un objet par rôle : `licencie {id, nom, prenom}`, `officiel {id, niveau, niveauLabel, principal}`, `referent_sportif [{id, label, sigle, nom}]` (ids de club). `admin` documenté. Lu déjà par `competitionRolesProvider` (lot 4) — à étendre pour garder ces objets.
- **Compte** : `GET /me` → `label`, `type`, `data {club, nom, numero, prenom, role}`.
- **Compétition** : `GET competition/evenement/:id` → `Nom`, `Lieu`, `Debut`, `Fin`, `dateLabel`, `specialiteLabel`, `Organisme {label…}`. La réponse porte aussi **téléphone, e-mail et nom des contacts** de l'organisateur : l'app n'en lit que le **nom** (`Organisme.label`).
- **Officiels** : `GET competition/evenement/:id/officiels` (sans jeton) → 60 lignes : `Id, Prenom, Nom, Niveau, NiveauMax, Principal, Jours, joursLabel, organismeLabel, officielClubLabel, isValid` ; aussi `NumeroLicence, Annee, Sexe` que l'app **ne lit pas**.
- **Clubs** : `GET competition/evenement/:id/organismes` → 46 clubs `{Id, label, officiels[], athletes[]}`.
- **Participants, épreuves, séries** : lot 5 (`participantsProvider`, `eventRankingProvider`, `laneFinderProvider`). `Participant` gagne `idLicencie` (servi par `participants` et `organismes`, retiré par erreur de la fixture du lot 5 : à régénérer, pseudonymisée) pour relier un compte athlète à sa fiche.
- **Chronos saisis** : `getHeatChronos(seriesId)` (lot 4) pour « séries à saisir ».

### Vérifié le 2026-10-18 avec le compte de test fourni par l'utilisateur (GET seulement)

- `evenement/1416/me` : rôles `public, licencie, officiel, referent_sportif` ; `licencie.id` 1326 **n'est pas** un participant de 1416 → le rôle `licencie` ne veut pas dire « engagé ». `referent_sportif[].id` 15 = `/me data.club.id` 15 = `participants.idClub` = `organismes.Id` : **même numérotation des clubs**.
- `participants` porte `idLicencie`, `idInvite`, `idClub` (entier).
- **Forfait avant course** : ni `engagement?epreuve=`, ni `engagement/:id`, ni `participants` ne le portent (pas de champ `forfait` malgré la doc) ; seule la place (`engagement.isForfait`, lue une à une) le dit. À revoir au lot 6b après une écriture de test.
- Composition d'un relais : `engagement?epreuve=` → `athletes[]`.
- Officiels : `Niveau` / `NiveauMax` sont des codes `A`, `B`, `C` (1416 : 19 A, 24 B, 17 C, 1 juge principal) ; `Jours` liste de numéros de jour, `joursLabel`.

## 3. Décisions

| Sujet | Décision |
|---|---|
| Découpage | 6a lecture, 6b écritures du club (2026-10-18). |
| Rôles affichés | Une carte par rôle détenu sur la compétition active ; admin voit toutes les cartes et peut ouvrir l'espace de **n'importe quel club**. La carte **Athlète** n'apparaît que si le licencié est **engagé** (`idLicencie` trouvé dans les participants) — choix du rédacteur. |
| Vue club | **Ouverte à tout le monde** (décision du 2026-10-18) : planning et résultats des athlètes d'un club, depuis la fiche d'un athlète ou une liste des clubs (Infos de la compétition). Le **forfait** et le **remplacement d'un relayeur** (lot 6b) sont réservés à un compte **club ou référent sportif de ce club**, ou admin. |
| Sans compte | Formulaire de connexion (lot 4) puis la partie « Compétition (tout le monde) » et les préférences. |
| Athlète ↔ licencié | `roles.licencie.id` = `Participant.idLicencie` ; l'espace athlète réutilise la **fiche d'athlète** du lot 5 (planning = « à courir », résultats = « courues »), avec la prochaine course en grand. |
| Club | Un référent peut avoir plusieurs clubs : une carte par club. Athlètes du club = participants dont `idClub` est le club (même numérotation que `referent_sportif[].id`, vérifié) ; planning et résultats tirés des classements d'épreuve du lot 5 (lus à la demande, mis en mémoire). Chiffres : athlètes, rang provisoire du club (classement des clubs du lot 5 par libellé de club, lu seulement si déjà calculé ou à la demande), forfaits. Onglet Forfaits en 6a : forfaits tirés des **résultats publiés** (statut F, complément F/FF) — choix du rédacteur ; la liste complète des forfaits déclarés vient au lot 6b. |
| Suivis | **Locaux** au téléphone (préfixés par l'environnement, comme les favoris), par compétition : athlètes (id de participant, **ids d'engagement** et nom gardés à la création) et clubs (id et libellé) — choix du rédacteur, pour marquer le Live par `entryId` et libellé sans relire les participants. Une étoile sur la fiche d'athlète et sur l'espace d'un club. Les courses suivies ressortent dans le Live et les résultats (repère visuel « Suivi »). |
| Plateforme | **Android seulement** pour l'instant (décision du 2026-10-18) ; iPhone plus tard. Le web n'a pas de rappels. |
| Rappels | Notification **locale** X minutes avant une course d'un **athlète suivi** ou de l'athlète connecté (pas tous les athlètes d'un club suivi) (X réglable : désactivé, 5, 15, 30 min ; défaut 15). Heure : début prévu de la série si connue (après « Trouver sa série » ou fiche lue), sinon de la première série de l'épreuve, tirée du **programme seul** — choix du rédacteur. Bibliothèque `flutter_local_notifications` (ajout de dépendance), alarmes **inexactes** (pas de `SCHEDULE_EXACT_ALARM`), permission `POST_NOTIFICATIONS` (Android 13+) demandée à la première activation. Replanifiés au lancement et quand le programme change (pas à chaque relecture identique). |
| Onglet d'ouverture | Préférence locale (Accueil, Programme, Live, Résultats) appliquée au lancement. |
| Officiel — mes saisies | La file d'envoi du lot 4 pour le compte connecté : refusées (Réessayer / Ignorer), en attente, envoyées des dernières 24 h ; ouvre la saisie de la série concernée. |
| Officiel — séries à saisir | Séries **terminées** de la compétition (programme) dont **aucun couloir** n'a de `TempsLive` ni de temps publié, et sans saisie en file ; tous les officiels voient toutes les séries : lues à la demande (`getHeatChronos`, 6 en vol), pas de minuterie. |
| Officiel — DQ et forfaits | Liste tirée des classements d'épreuve (lot 5) : résultats DQ (avec code) et forfaits, par épreuve ; plus les saisies DQ / forfait en file de l'officiel. |
| Officiel — accès rapide | La série en cours (`nowRunning`, lot 1/3) et la suivante, bouton « Saisir » (lot 4). |
| Officiels de la compétition | Liste groupée : juge principal d'abord, puis par niveau A, B, C ; nom, niveau, jours, club. Visible de tout le monde (l'API la sert sans jeton). |
| Infos de la compétition | Lieu, dates, spécialité, organisateur (nom seul), nombre d'athlètes, de clubs, d'épreuves. |
| Rafraîchissement | Manuel ; aucune nouvelle minuterie. |

## 4. Écrans (visualisation du 2026-10-18)

1. **Mon espace** : compte (nom, club, déconnexion) ; « Mes espaces sur cette compétition » (cartes Athlète, Club ×n, Officiel, Admin) avec un badge d'état (prochaine course « dans 2 h », saisies refusées « 2 refusées ») ; « Compétition (tout le monde) » : Mes suivis, Infos, Officiels ; « Préférences » : rappel, onglet d'ouverture, langue. Sans compétition active : choisir une compétition.
2. **Espace athlète** : prochaine course en grand (heure, série, ligne — ligne et série par « Trouver sa série » si inconnues) ; onglets Mon planning / Mes résultats.
3. **Espace club** : en-tête club (+ étiquette RÉFÉRENT / ADMIN) ; chiffres ; onglets Planning (à venir, par heure) / Résultats (par épreuve) / Forfaits (liste en lecture ; interrupteurs inactifs « au lot 6b »). Toucher un athlète ouvre sa fiche (lot 5).
4. **Espace officiel** : en cours / suivante + Saisir ; Mes saisies ; Séries à saisir ; DQ et forfaits ; Officiels.
5. **Mes suivis** (prochaine course de chacun, étoile pour retirer) ; **Infos de la compétition** ; **Officiels**.

Règles communes : le dernier élément ne passe pas sous la barre du téléphone ; libellés fr de référence, en symétrique ; « Eau plate ».

## 5. Données et état

- `lib/domain/` : rôles détaillés (`CompetitionRoles` : rôles + licencié + officiel + clubs référents), officiel de compétition, infos de compétition ; fonctions pures (prochaine course, séries à saisir, regroupement des officiels, planning d'un club, heure de rappel).
- `lib/data/` : DTO / mappers `evenement/:id` (sans les contacts), `officiels` (sans licence ni année), `organismes` ; `Participant.idLicencie`.
- `lib/features/my_space/` : fournisseurs et pages ; `lib/features/follows/` (suivis, stockage local) ; `lib/features/reminders/` (planification locale).
- `clockProvider`, `ref.mounted` après chaque `await`, `AppException` seulement, pas de test de widget.

## 6. Tests

Domaine (rôles, prochaine course, séries à saisir, regroupement des officiels, planning d'un club, heure de rappel), mappers sur fixtures **pseudonymisées** (`evenement_1416`, `officiels_1416`, `organismes_1416` : sans nom réel, téléphone, e-mail, licence ni année), fournisseurs (suivis persistés, rappels planifiés avec un planificateur simulé, lecture à la demande des chronos limitée à 6).

## 7. Lot 6b (pour mémoire, spec à part)

Forfait d'un engagement (`POST competition/engagement/:id/submit`, `forfait`) et remplacement d'un relayeur (`place/:id/remplacant/submit` avant la course, `resultat/:id/remplacant/submit` après, `resultat/:id/remplacant/available`) : paramètres à vérifier sur la recette 1416 avec le compte référent fourni par l'utilisateur.

## 8. Laissé au rédacteur du plan

- Le découpage en tâches, les noms exacts.
- L'intégration du repère « Suivi » dans le Live et les résultats.
- Le mécanisme de replanification des rappels (au lancement et au rafraîchissement du programme).
