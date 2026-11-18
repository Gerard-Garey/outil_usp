# JS1, étape 2 (ii) : corpus d'acceptation sur le poste Windows (18/11/2026)

> Relevé de la session principale (IA), session locale de Claude Code sur le poste du mainteneur. Critère de la fiche JS1 : aucune valeur fausse, et aucun classeur ordinaire refusé à tort, hors du refus documenté de #594 (texte en ligne bordé de blancs).

## Écart au plan, décidé par le mainteneur

- Ni **Excel** ni **LibreOffice** ne sont installés sur le poste. Le 18/11, le mainteneur a choisi d'installer openpyxl, XlsxWriter et lxml seulement (`pip --user`), sans LibreOffice.
- Les classeurs Excel et LibreOffice du plan ne sont donc **pas couverts** sur ce poste. Cela vaut aussi pour la colonne `note` bordée de blancs que demande le § 3 de la spécification d'`actuary-approfondi` (#594). Voir « Reste ouvert ».

## Conditions

- `git rev-parse HEAD` : `c75a112214d757ad778b89aaf2e680ba719d6c0f`, détaché, arbre propre (hors `?? prompt-poste-local.md`).
- Windows 11 x64 (build 26300), `R version 4.3.3 (2024-02-29 ucrt)`, locale `French_France.utf8` (`LC_NUMERIC=C`).
- Chemin openxlsx : `openxlsx` 4.2.9, de la bibliothèque du poste.
- Chemin de repli : même commande, avec `R_LIBS_USER` pointé sur un dossier vide. Ce dossier masque `openxlsx`, et aussi `zip`, sans effet sur la lecture.
- Python 3.14.7 ; openpyxl 3.1.5, pandas 3.0.6, XlsxWriter 3.3.1, lxml 6.1.3.
- Moteur chargé par `charger_moteur()` (ADR 0016).

## Corpus et reproduction

Tout est versé dans `mesure-594/poste-windows/`.

Commandes, depuis la racine du dépôt :
1. `python docs/revues/20261118-js1-poste-windows/mesure-594/poste-windows/generer_corpus.py tests/donnees/donnees_ln.csv tests/donnees/triangle_mw.csv <sortie>` ;
2. `Rscript docs/revues/20261118-js1-poste-windows/mesure-594/poste-windows/mesurer_corpus.R <sortie>`, avec `openxlsx`, puis avec `R_LIBS_USER` vide ;
3. intégrité : `mesure-594/md5.txt`, depuis `mesure-594/`.

Quinze classeurs synthétiques :
- **outils** : openpyxl ; pandas avec le moteur openpyxl ; pandas avec le moteur xlsxwriter ; XlsxWriter en mode par défaut ; XlsxWriter en mode `constant_memory` ;
- **trois classeurs par outil** :
  - `series_temoin` : `t`, `xt`, `yt`, et une colonne non lue `note`, sans blancs ;
  - `series_blancs` : la même colonne `note`, bordée de blancs (cas de #594) ;
  - `triangle_temoin` : `i`, `j0` à `j7`.

Sorties : `sortie_openxlsx.txt` et `sortie_repli.txt`. Sur le chemin openxlsx, chaque classeur de séries est aussi lu directement par `openxlsx::read.xlsx()`, y compris ceux que le moteur refuse.

Historique des sorties :
- Premières exécutions au SHA `c75a112`. La lecture directe des classeurs refusés y était faite par une commande à part.
- Après le `/code-review` de l'étape 6, elle a été intégrée à `mesurer_corpus.R`, et les deux sorties ont été régénérées à la tête `8022501`, dont le code est identique à `c75a112`.
- `sortie_repli.txt` est identique à la première exécution, hors ligne `HEAD`.

Comparaison :
- **séries** : `t`, `xt` et `yt`, convertis en double, comparés au CSV par `identical()`, puis passés à `engine_lire_donnees_csv()` ;
- **triangle** : `engine_lire_triangle()` sur le classeur lu, triangle comparé par `identical()` à celui du CSV.

## Résultats (identiques sur les deux chemins)

| Classeur | Forme XML des textes | `engine_lire_xlsx()` | Comparaison |
|---|---|---|---|
| 5 `series_temoin` | en ligne (openpyxl, pandas-openpyxl, `constant_memory`) ou chaînes partagées (XlsxWriter par défaut, pandas-xlsxwriter) | lu | `t`, `xt`, `yt` identiques au CSV ; `ok = TRUE`, `n = 8`, aucun avertissement |
| 5 `triangle_temoin` | idem | lu | triangle identique ; `ok = TRUE` |
| `series_blancs`, XlsxWriter par défaut et pandas-xlsxwriter | chaînes partagées ; `xml:space` dans `sharedStrings.xml` | lu | identiques ; `ok = TRUE`, `n = 8` |
| `series_blancs`, openpyxl, pandas-openpyxl, XlsxWriter `constant_memory` | chaîne en ligne `<t xml:space="preserve">` | **refus** `usp_refus_lecture` (D-S1-31), qui cite les cellules D2, D3, D4, D7 et D8 | refus documenté de #594 |

Lecture directe par `openxlsx::read.xlsx()` 4.2.9 des cinq `series_blancs` :
- `t`, `xt` et `yt` sont identiques au CSV dans les cinq classeurs ;
- la colonne `note` est **fausse** dans les trois classeurs à chaînes en ligne : préfixe `xml:space="preserve">` sur les cinq textes bordés de blancs ;
- elle est juste dans les deux classeurs à chaînes partagées.

## Constat

- **Critère tenu** pour les outils couverts :
  - aucune valeur fausse ;
  - aucun classeur ordinaire refusé à tort ;
  - seul refus : celui, documenté, de #594 ;
  - les deux chemins concordent sur les quinze classeurs.
- **#594 sous `openxlsx` 4.2.9** : le comportement mesuré en cloud sous 4.2.5.2 se reproduit à l'identique. L'hypothèse d'`actuary`, qui fonde l'option (b) bornée, tient donc aussi sous la version du poste : la colonne non lue est altérée, et les colonnes lues sont identiques au bit près.
- Les md5 de `pandas-xlsxwriter_*` et de `xlsxwriter-defaut_*` sont égaux deux à deux : pandas délègue alors l'écriture à XlsxWriter, avec le même contenu.

## Reste ouvert

- **Classeurs à produire** sur un poste qui porte **Excel** et **LibreOffice**, avant le codage d'A1 (§ 3 de la spécification de #594) : séries, triangle et colonne `note` bordée de blancs.
- **Relevé à faire** pour chaque outil :
  - ce qu'il écrit : `xml:space`, chaînes partagées ou en ligne ;
  - ce qu'en lit `openxlsx`.
