# LiveFFSS v2 — Lot 8 : espace admin

> Spec issue du brainstorming du 2026-10-19. Options retenues par l'utilisateur : 1 (choix du serveur), 2 (forfaits et DQ de tous les clubs), 3 (ouvrir n'importe quel espace), 5 (contrôle des données), 6 (journal réseau), 8 (outils de maintenance). Non retenues : comparaison des classements app / API, file d'envoi de tous les comptes.

## 1. Intention

Un **admin** trouve dans Mon espace une carte **Admin** qui donne des outils réservés : changer de serveur, superviser une compétition (forfaits et DQ de tous les clubs, tout espace ouvrable), voir ce que l'app a écarté ou n'a pas pu lire, voir les derniers appels à l'API, et faire de la maintenance locale. But : préparer la mise en production et diagnostiquer sur place, sans le PC.

## 2. Qui est admin (vérifié le 2026-10-19 sur la recette)

- **`GET /me`** d'un compte admin rend `type: "organisme"`, `data: {role: "admin", numAffiliation}`. Un licencié rend `type: "licencie"`, `data.role: "user"`. **Règle : admin = `/me` → `data.role == "admin"`** (décision du 2026-10-19), indépendante de toute compétition.
- Sur 1416, ce compte a aussi les rôles de compétition `admin`, `hote`, `organisme_participant`.
- Relu à chaque connexion et au lancement (comme `me()` aujourd'hui) ; perdu à la déconnexion.

## 3. Décisions

| Sujet | Décision |
|---|---|
| Carte Admin | Dans Mon espace, sans compétition requise, si le compte est admin (`/me`). Les outils liés à une compétition (forfaits et DQ, contrôle des données, ouvrir un espace) utilisent la compétition active ; sans elle, ils proposent d'en choisir une. |
| Choix du serveur (1) | Recette ou production. Visible sur **ce téléphone** dès qu'un admin s'y est connecté une fois (drapeau local global, non préfixé) — décision du 2026-10-19. Changer de serveur : confirmation, déconnexion (les jetons sont propres à chaque serveur), compétition active et caches remis à zéro, comptes et préférences de l'autre serveur conservés (préfixe `dev_` existant). Un bandeau **« RECETTE »** permanent tant que l'app n'est pas sur la production. **Par défaut : recette** (inchangé tant que l'utilisateur n'a pas basculé ; repasser le défaut à la production avant diffusion reste une décision séparée). |
| Forfaits et DQ (2) | Pour la compétition active, tous clubs confondus : DQ (avec code) et forfaits publiés dans les résultats (lot 5/6a, lus à la demande, 6 en vol), filtrables par club et par épreuve ; plus, par club et à la demande, les forfaits **déclarés** lus sur les places (lot 6b). |
| Ouvrir un espace (3) | Liste des clubs → vue club (forfaits modifiables, l'admin y a déjà les droits) ; recherche d'athlète → fiche ; espace officiel de la compétition (saisie déjà permise à l'admin). Pas d'usurpation d'identité : l'admin agit en son nom. |
| Contrôle des données (5) | Pour la compétition active, à la demande : séries orphelines (non rattachées au programme), épreuves sans spécialité (masquées), places illisibles, résultats au statut 3, séries terminées sans résultat publié, courses sans horaire, rôles ou participants illisibles. Chaque ligne dit quoi, où (épreuve, série, couloir) et la conséquence dans l'app. |
| Journal réseau (6) | Les **200** derniers appels de la session (mémoire seulement) : méthode, route **sans jeton ni paramètres sensibles**, statut, durée, taille de la réponse, type d'erreur (`AppException`). Filtre « erreurs seulement ». Effacer. |
| Maintenance (8) | Pour la compétition active : effacer les données locales (suivis, séries connues, enregistrement de l'athlète connecté, filtre de couloirs) ; forcer une relecture complète ; rappels : notification de test et liste des rappels planifiés ; **rapport de diagnostic** anonymisé (version, serveur, compétition, compteurs, derniers appels en erreur) **copié dans le presse-papiers** — choix du rédacteur, pas de dépendance de partage. |
| Sécurité | Aucun jeton, mot de passe, e-mail, téléphone ni date de naissance dans le journal ou le rapport. Les outils sont masqués et refusés (fournisseurs) pour un compte non admin. |

### Précisions (relecture du 2026-10-19, choix du rédacteur sauf mention)

- **Où est le choix du serveur** : hors de la carte Admin, dans les **Préférences** de Mon espace, derrière le drapeau local « un admin s'est connecté sur ce téléphone » (clé globale ajoutée à `AppEnvironment.globalKeys`). Ainsi on peut revenir à l'autre serveur même sans être connecté (décision du 2026-10-19 : visible dès qu'un admin s'y est connecté une fois).
- **Ce que fait un changement de serveur** : on **n'efface rien**. Le stockage est déjà séparé par serveur (`dev_`) : jeton, compte, compétition active, suivis, file d'envoi de chaque serveur restent où ils sont ; l'app **reconstruit son état** sur l'autre serveur (session, compétition active, caches en mémoire relus), et reprend la session enregistrée pour ce serveur s'il y en a une. L'environnement choisi est la clé globale existante `api_environment`, lue au lancement avant `runApp`. La page ouverte revient à l'onglet d'ouverture.
- **Saisies et rappels** : la file d'envoi de l'ancien serveur reste en sommeil (stockée pour lui) et repart au retour ; si elle a des saisies non envoyées, la confirmation le dit. Les rappels de l'ancien serveur sont annulés au changement et replanifiés au retour.
- **Droits** : le rôle admin global (`/me`) **montre les outils** ; les **actions** (forfait, saisie) restent soumises aux rôles de la compétition (`CompetitionRoles`), que le site vérifie de toute façon.
- **Hors ligne** : le rôle de `/me` est enregistré avec le compte (`session_role`, à côté de `session_account`) pour que la carte Admin reste visible au lancement sans réseau.
- **Contrôle des données — périmètre** : seulement ce que l'app peut constater sans changer ses repositories : séries orphelines (lecture `serie?epreuve=` de toutes les épreuves, 6 en vol, à la demande, avec le coût annoncé), épreuves sans spécialité, résultats au statut 3, séries terminées sans résultat publié, courses sans horaire, places non lues (échec réseau ou réponse illisible confondus), rôles et participants en échec. Le détail d'une **ligne JSON écartée** par un mapper n'est pas remonté (il faudrait changer les contrats des repositories).
- **Journal réseau** : route **résolue sans la chaîne de requête** (ni jeton, ni termes de recherche, ni autres valeurs), méthode, statut, durée, taille, type d'erreur ; fournisseur distinct du client HTTP, conservé pendant toute l'exécution de l'app (y compris à travers un changement de serveur, chaque ligne porte son serveur).

## 4. Écrans

- **Mon espace** : carte **Admin** (avec le serveur courant) quand le compte est admin.
- **Espace admin** : Serveur ; Compétition active (Forfaits et DQ, Ouvrir un espace, Contrôle des données) ; Diagnostic (Journal réseau, Maintenance).
- **Bandeau « RECETTE »** sur toutes les pages hors production.

## 5. Tests

`/me` admin (fixture pseudonymisée du compte admin), règle d'admin, drapeau local, changement de serveur (déconnexion, remise à zéro, conservation de l'autre serveur), journal (borne de 200, rien de sensible), contrôle des données sur les fixtures de 1416 (séries orphelines d'avril, statut 3…), maintenance (ce qui est effacé et ce qui ne l'est pas), rapport sans donnée sensible. Pas de test de widget.

## 6. Laissé au rédacteur du plan

Découpage, noms exacts ; branchement du journal dans `HttpClient` ; mécanisme de redémarrage de l'état après changement de serveur.
