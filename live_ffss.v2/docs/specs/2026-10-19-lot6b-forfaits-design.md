# LiveFFSS v2 — Lot 6b : forfaits du club

> Spec issue du brainstorming du 2026-10-19. Suite du lot 6a (Mon espace). Le **remplacement d'un relayeur est retiré** du lot : l'API ne le permet pas avant la course (voir § 2), demande envoyée au développeur de l'API.

## 1. Intention

Le **référent sportif d'un club** (ou un **admin**) déclare ou annule, depuis la vue club (onglet Forfaits), le **forfait** d'un athlète de son club dans une épreuve **individuelle ou relais**.

- **Tout de suite** (décision du 2026-10-19) : pas d'étape de confirmation ; l'interrupteur agit dès qu'on le touche.
- **Jusqu'à 10 minutes avant la course** (décision du 2026-10-19 : « couru » = 10 min avant le départ prévu) ; ensuite l'interrupteur est verrouillé et montre l'état.
- Annulable tant que ce délai n'est pas passé.

### Ce que le lot 6b n'est pas

- **Pas de remplacement de relayeur** : les routes `place/:id/remplacant/submit|delete` répondent comme une route inexistante, et `resultat/:id/remplacant/submit` exige un résultat, qui n'existe qu'une fois la course publiée (vérifié le 2026-10-19). Repris quand l'API le permettra ; le remplacement ne vaut que pour les relais (décision du 2026-10-19).
- **Pas de file d'envoi** pour les forfaits (choix du rédacteur, accepté le 2026-10-19) : envoi direct ; en cas d'échec, l'interrupteur revient à son état et un message le dit.

## 2. API (vérifié le 2026-10-19 sur la recette 1416, compte référent du club 15)

- **Écriture** : `POST competition/engagement/:id/submit?forfait=1` (ou `0`) avec le jeton, **paramètres dans l'adresse** (comme `resultat/submit`) → `{"success":true,"message":"Engagement modifié"}`. Essai sur l'engagement 565147, annulé ensuite.
- **Lecture de l'état** : **seule la place** le donne (`course/place/:id` → `engagement.isForfait`). Ni `engagement/:id`, ni `engagement?epreuve=`, ni `participants` ne portent le forfait.
- **Droits** : jeton d'un compte référent sportif du club (rôle `referent_sportif` avec l'id du club) ou admin. Un jeton mort répond 403 « Invalid token » (lot 4 : session expirée).

## 3. Décisions

| Sujet | Décision |
|---|---|
| Qui | `clubRole` (lot 6a) = référent de ce club ou admin. Les autres voient l'onglet Forfaits en lecture. |
| Liste | Les engagements des athlètes du club (`Participant.entries`), un par engagement : un relais n'apparaît qu'une fois (ses relayeurs en sous-titre). Épreuves eau plate seulement (garde côtier du lot 6a). |
| État | Lu sur les **places** des séries **non terminées** du tour séries de chaque épreuve du club (programme), 6 lectures au plus en vol, à l'ouverture de l'onglet et au rafraîchissement manuel ; une place trouvée donne `isForfait`, le numéro de couloir et la série. Engagement sans place trouvée : « pas encore placé », interrupteur actif (le forfait vaut pour l'engagement). |
| Échéance | `départ prévu de la série de l'engagement − 10 min` (série trouvée), sinon départ prévu de la **première** série non terminée du tour ; passé ce moment (horloge `clockProvider`) : verrouillé. |
| Envoi | Direct, sans file. Pendant l'envoi l'interrupteur est désactivé ; succès → nouvel état gardé ; échec (`AppException`) → état précédent + message (réseau, droits, session expirée). |
| Relecture | Après un envoi réussi, la place concernée est relue pour confirmer. |

## 4. Écran

Vue club → onglet **Forfaits** :

- en tête, pour le référent / admin : « Déclarer ou annuler un forfait jusqu'à 10 min avant la course » ;
- une ligne par engagement : athlète (ou relais : club + relayeurs), épreuve, série et couloir si connus, interrupteur (actif, en cours d'envoi, verrouillé) ;
- les forfaits déjà publiés dans les résultats (lot 6a) restent affichés pour les autres.

## 5. Tests

Repository (paramètres dans l'adresse, réponse, erreurs), fonctions pures (échéance, verrouillage, regroupement des relais), fournisseur (lecture des places plafonnée à 6, état, bascule optimiste puis retour en cas d'échec, relecture après succès, droits). Pas de test de widget.
