# Corpus de classeurs du témoin `openxlsx` (A1, #604)

Ces 38 classeurs sont des copies au bit près de ceux versés sous `docs/revues/20261118-js1-poste-windows/mesure-594/`, sous-dossiers compris (étape 2a d'A1 ; ADR 0020, points 3 et 5 ; Q-68-9 (a)). Leurs md5 sont dans `md5.txt`, au format de `mesure-594/md5.txt`. Pour les contrôler, lancer `md5sum -c md5.txt` depuis ce dossier. Chaque md5 est égal à celui de la source.

- **Aucune donnée réelle** : les classeurs sont synthétiques. Ils sont écrits à partir des jeux de test versionnés `tests/donnees/donnees_ln.csv` et `tests/donnees/triangle_mw.csv`, augmentés au besoin d'une colonne `note`.
- **Aucun test ne les lit encore.** Le témoin qui les lira est prévu à l'étape 2c d'A1.
- Les scripts générateurs et les relevés restent dans `mesure-594/`. Ils ne sont pas copiés ici.

## Arborescence

Il y a un sous-dossier par origine, et les noms de fichiers sont ceux de la source. Deux raisons à ce choix :
- les dossiers `blancs/classeurs/` et `blancs/classeurs_sans_lxml/` de la source ont cinq noms en commun ; le sous-dossier évite ces collisions sans renommer de fichier ;
- chaque nom reste celui que citent les relevés et les sorties versées (`sortie_*.txt`).

Correspondance avec la source (chemins relatifs à `mesure-594/`) :

| Ici | Source | Nombre |
|---|---|---|
| `synthetiques/` | `classeurs/` | 8 |
| `blancs/` | `blancs/classeurs/` | 5 |
| `blancs-sans-lxml/` | `blancs/classeurs_sans_lxml/` | 7 |
| `entete/` | `entete/` | 1 |
| `poste-windows/` | `poste-windows/classeurs/` | 15 |
| `triangle/` | `triangle/classeurs/` | 2 |

## Origine par groupe

Les versions sont celles que citent les relevés. Quand un relevé ne cite pas une version, la note le dit.

### `synthetiques/` : corpus synthétique cloud

- Écrivains : openpyxl 3.1.5 ; pandas 3.0.5 (moteur openpyxl) ; XlsxWriter 3.2.9, en mode par défaut et en mode `constant_memory`. Le relevé ne dit pas si lxml était chargé pour ces classeurs. Le complément `blancs/` du même README indique que lxml 6.1.3 était installé sur la machine.
- CSV source : `tests/donnees/donnees_ln.csv`, plus une colonne `note`. Variante `_blancs` : la note est bordée de blancs. Variante `_temoin` : les mêmes textes, sans les blancs.
- Script : `mesure-594/generer.py`.
- Relevé : `mesure-594/README.md`, sections « Conditions » et « Résultats ».

### `blancs/` : notes faites de seuls blancs, avec lxml

- Écrivain : openpyxl 3.1.5, avec lxml 6.1.3.
- CSV source : `tests/donnees/donnees_ln.csv`, plus une colonne `note`. Cas couverts : un blanc, trois blancs, une tabulation, une chaîne vide, et une ligne finale qui ne porte qu'une note blanche.
- Script : `mesure-594/blancs/generer_blancs.py`.
- Relevé : `mesure-594/README.md`, « Complément : textes faits de seuls blancs ».

### `blancs-sans-lxml/` : les mêmes cas, sans lxml

- Écrivain : openpyxl 3.1.5 sans lxml (`OPENPYXL_LXML=False`).
- CSV source : `tests/donnees/donnees_ln.csv`.
- Script : `mesure-594/blancs/generer_sans_lxml.sh`, qui appelle `generer_blancs.py`. Le même script écrit aussi `note_bordee_blancs.xlsx` et `note_temoin.xlsx` : ce sont les classeurs openpyxl `_blancs` et `_temoin` de `generer.py`, écrits sans lxml.
- Relevé : `mesure-594/README.md`, « Complément : textes faits de seuls blancs ».

### `entete/` : en-tête lu bordé d'un blanc

- Écrivain : openpyxl 3.1.5, selon l'en-tête du script. Le relevé ne dit pas si lxml était chargé.
- CSV source : `tests/donnees/donnees_ln.csv` ; l'en-tête `xt` y est écrit `xt ` (blanc final).
- Script : `mesure-594/entete/generer_entete.py`.
- Relevé : `mesure-594/README.md`, sonde complémentaire de la section « Résultats ».

### `poste-windows/` : corpus du poste Windows (étape 2 (ii) de JS1)

- Écrivains : openpyxl 3.1.5 ; pandas 3.0.6, avec le moteur openpyxl et avec le moteur xlsxwriter ; XlsxWriter 3.3.1, en mode par défaut et en mode `constant_memory` ; lxml 6.1.3 ; Python 3.14.7. Ces versions sont celles du relevé et de `poste-windows/sortie_generer.txt`. Le poste tourne sous Windows 11.
- CSV sources : `tests/donnees/donnees_ln.csv` pour les séries (`_series_temoin`, `_series_blancs`) et `tests/donnees/triangle_mw.csv` pour le triangle (`_triangle_temoin`).
- Script : `mesure-594/poste-windows/generer_corpus.py`.
- Relevés : `docs/revues/20261118-js1-poste-windows/etape-2-ii-corpus.md` et `mesure-594/README.md`, « Complément : corpus du poste Windows ».
- Les classeurs `pandas-xlsxwriter_*` et `xlsxwriter-defaut_*` ont deux à deux le même md5, comme le relève `etape-2-ii-corpus.md`.

### `triangle/` : triangle à colonne `note`

- Écrivain : openpyxl 3.1.5, avec lxml 6.1.3.
- CSV source : `tests/donnees/triangle_mw.csv`, plus une colonne `note`. Variante `_temoin` : la note est sans blancs. Variante `_blancs` : la note est bordée de blancs.
- Script : `mesure-594/triangle/generer_triangle.py`.
- Relevé : `mesure-594/README.md`, « Complément : triangle à colonne `note` ».

## Non couverts

Ce corpus ne contient aucun classeur écrit par Excel ou par LibreOffice : ni l'un ni l'autre n'était installé sur le poste (`etape-2-ii-corpus.md`, « Reste ouvert »).
