# Support de démonstration

`livefss-demo.pptx` — 45 slides, 16:9, français. Généré par `build_deck.py`.

## Régénérer

```bash
python docs/demo/build_deck.py
```

Nécessite `python-pptx` et `Pillow` (`pip install python-pptx pillow`).

⚠️ **La génération écrase le fichier.** Une fois que tu commences à retoucher le
deck dans PowerPoint, ne relance plus le script — ou reporte tes modifications
dans `build_deck.py` d'abord.

`.cropped/` est un cache de captures rognées, régénéré automatiquement. Il peut
être supprimé sans conséquence.

## À compléter

Quatre endroits portent un bandeau jaune `[À COMPLÉTER]` :

| Slide | Ce qu'il manque |
| --- | --- |
| 1 · Titre | date et nom du présentateur |
| 2 · Pourquoi LiveFFSS | contexte, points de friction, objectif, public |
| 11 · Profil | capture d'écran (l'appareil de démo n'était pas connecté) |
| 44 · Prochaines étapes | roadmap, demandes à la FFSS, test terrain, moyens |

## Captures

Prises sur émulateur Pixel 8 (Android 15, 1080×2400), sur la compétition
**Oceanperf Challenge**, en session non connectée. Le script rogne la barre
d'état et la barre de geste.

Le programme, les structures, les sites, les horaires et le tirage visibles sur
les captures ont été créés pendant la session de capture — ils vivent dans le
stockage local de l'émulateur, pas sur le serveur FFSS.

| Fichier | Slide |
| --- | --- |
| `02-connexion.png` | Connexion |
| `03-accueil-tous.png` | Trouver une compétition |
| `04-accueil-recherche.png` | Recherche |
| `05-competition-epreuves.png` | Évènements |
| `06b-competition-programme-defini.png` | Programme (lecture) |
| `07-competition-clubs.png` | Clubs |
| `08-competition-points.png` | Points |
| `09-clubs-detail.png` | Clubs — le détail |
| `10-epreuve-engages.png` | Engagés |
| `10b-engages-presence.png` | Pointer les présents |
| `11-epreuve-series.png` | Séries |
| `12-epreuve-resume.png` | Résumé |
| `13-programme-structure-vide.png` | L'inventaire |
| `14-programme-structure.png` | Génération automatique |
| `15-structure-editor.png` | Éditeur de structure |
| `16-structure-bracket.png` | Vue bracket |
| `17-programme-horaires.png` | La grille horaire |
| `17b-programme-sites.png` | Les sites |
| `18-tirage-series.png` | Le tirage des séries |
| `19-series-apres-tirage.png` | Séries enregistrées |
| `20-course.png` | Une course |
| `21-rfid-writer.png` | Écrire les bracelets |
| `22-rfid-ecriture.png` | Le format du bracelet |
| `23-favoris.png` | Suivre ses compétitions |
| `24-langue.png` | Bilingue |

Non utilisées, gardées au cas où : `01-accueil-semaine.png` (vue « cette
semaine »), `06-competition-programme.png` et `11-epreuve-series-vide.png` et
`17a-programme-horaires-vide.png` (états vides, avant construction du programme).

## Note sur le NFC

L'émulateur n'a pas de puce NFC : la capture `22-rfid-ecriture.png` montre le
message d'erreur, avec la charge utile du bracelet visible. Pour une capture de
l'écriture réussie, refais-la sur un téléphone équipé.
