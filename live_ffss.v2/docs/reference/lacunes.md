# Lacunes connues

> Extrait de `CLAUDE.md` le 2026-11-24. Référence à tenir à jour avec le code : une décision qui change ici change aussi dans le code et ses tests.

- `requestToken` avec un corps de formulaire n'est pas encore vérifié sur une vraie connexion (les tests ne parlent pas au serveur).
- Les lignes de `serie/:id` portent-elles `Statut`, `complement` et `Temps` ? Non vérifié sur la recette : `getHeatResults` et les chronos en dépendent.
- Le `complement` ne s'efface pas côté site : l'app ne l'affiche que sur une DQ.
- Entre la relecture d'un résultat et son écriture, le juge peut changer le `statut` (ou le `complement`) : l'écriture, qui doit renvoyer le `statut` sous peine de le voir retomber à 3, écrase alors le sien. Cette fenêtre ne peut pas être évitée avec cette API (pas d'écriture conditionnelle ni de champ omis conservé pour `statut`).
- Les minuteries (30 s, 60 s pour le Live) ne s'arrêtent pas quand leur écran est caché : l'`IndexedStack` du `StatefulShellRoute` garde les branches montées, donc le programme d'un onglet quitté continue d'être relu, et un détail de créneau resté ouvert sous un autre onglet continue de relire ses places ; le Live caché relit de même le programme et ses places. La carte en direct n'ajoute pas d'appel : `nowRunningProvider` se tire de `programmeProvider`.
- `reunion` ne porte qu'une série par course (celle d'une catégorie) : le lot 5 rattache les autres par `serie?epreuve=`, mais le programme n'en montre toujours qu'une.
- Les routes de classement de l'API ne sont pas lues : l'app calcule les siens (voir Résultats).
- Les relais de 1416 sont hors du programme (aucune course ne les porte) : leurs séries ne sont pas rattachées et n'entrent pas aux classements.
- Une épreuve sans `Specialite` est cachée : si FFSS omet le champ, les résultats sont vides.
- L'ordinal anglais de l'ancienne clé `heatPlace` est faux (« 21th »).
- Les points sont comptés aussi sur les séries non validées ; V3 ne compte que les validées. L'écran dit « provisoire ».
- Le paramètre `saison` n'est pas envoyé (la doc le dit désactivé). À vérifier au journal réseau si la liste de l'accueil semble incomplète.
- Le forfait n'est lisible que sur les places (aucun champ `forfait` sur l'engagement) : un engagement sans place reste « état inconnu » et une lecture coûte une requête par place, 6 au plus en vol.
- Le remplacement d'un relayeur est impossible avant la course : les routes de remplacement d'une place (`place/:id/remplacant/submit|delete`) répondent 404 comme une route inexistante, et celle d'un résultat exige un résultat, qui n'existe qu'après publication. Demande envoyée au développeur de l'API le 2026-10-19.
- iPhone n'est pas pris en charge : les rappels n'existent que sur Android (`NoReminderScheduler` ailleurs) et rien n'est configuré pour iOS.
- Les rappels sont inexacts : Android peut les retarder de quelques minutes, surtout en économie d'énergie.
- Une permission de notifications accordée dans les réglages du téléphone n'est prise en compte qu'au prochain lancement ou geste de l'utilisateur.
- `followedRacesProvider` n'est pas gardé pour le côtier (lecture légère : programme et épreuves).
- Le tri des clubs (`competitionClubs`) est sensible aux accents (`toLowerCase`, pas `foldForSearch`).
- Une saisie en cours d'envoi qui ne répond pas dans les 20 s bloque le changement de serveur et le rechargement forcé : l'officiel doit réessayer (rien n'est remonté sans sa réponse).
- La liste des DQ et forfaits ne connaît le club d'une ligne que par son libellé : l'id du club, pour ouvrir ses forfaits déclarés, se tire des participants engagés sur ses lignes (`clubIdOf`), et à défaut d'un libellé porté par un seul club.
