# Mesure de #594 sous `openxlsx` 4.2.5.2 (JS1, Q-67-4 (a))

*Mesure faite par la session principale (IA) le 18/11/2026, sur la branche `claude/jalon-js1`, au SHA de la batterie `c75a112`. Le code du moteur est identique à celui de `8bc49fb`.*

## Objet

L'issue #594 pose une hypothèse d'`actuary` (option (b)) : un texte en ligne bordé de blancs dans une colonne **non lue** n'altère pas les colonnes lues. Seule la colonne non lue serait lue faussement par `openxlsx`. Si l'hypothèse tient, le refus de D-S1-31 peut se limiter aux cellules dont le texte est lu.

## Conditions

- Linux, R 4.3.3, `LC_ALL=C.UTF-8`.
- `openxlsx` 4.2.5.2, installé depuis l'archive CRAN dans une bibliothèque de session (`R_LIBS`).
- Chemin de repli : même commande, sans `openxlsx`.
- Classeurs synthétiques écrits par `generer.py` à partir de `tests/donnees/donnees_ln.csv` (colonnes `t`, `xt`, `yt`, plus une colonne `note`). Les classeurs et leurs md5 (`md5.txt`) sont versés ici.
- Versions des outils : openpyxl 3.1.5, pandas 3.0.5 (moteur openpyxl), XlsxWriter 3.2.9 en mode par défaut et en mode `constant_memory`.
- Chaque outil produit deux classeurs :
  - `_blancs` : la colonne `note` porte des textes bordés de blancs ;
  - `_temoin` : les mêmes textes, sans les blancs.
- Les classeurs écrits par Excel et LibreOffice relèvent du corpus du poste Windows (étape 2). Ils ne sont pas mesurés ici.

## Résultats

Commandes : `mesurer.R` (sorties `sortie_openxlsx.txt` et `sortie_repli.txt`). La comparaison porte sur `t`, `xt` et `yt` convertis en double et comparés au CSV par `identical()`.

| Classeur | `engine_lire_xlsx()`, deux chemins | `openxlsx::read.xlsx()` direct : `t`, `xt`, `yt` | `openxlsx::read.xlsx()` direct : `note` |
|---|---|---|---|
| openpyxl, pandas, XlsxWriter `constant_memory`, `_blancs` | refus `usp_refus_lecture` (D-S1-31) | identiques au CSV | **fausse** : préfixe `xml:space="preserve">` sur les cinq textes bordés de blancs |
| XlsxWriter par défaut, `_blancs` (chaînes partagées) | lu, identique au CSV | identiques | juste, blancs conservés |
| les quatre `_temoin` | lu, identique au CSV | identiques | juste |

Sonde complémentaire (`sortie_entete_lu.txt`) : un en-tête **lu**, `xt ` écrit par openpyxl, est relu par `openxlsx` sous le nom `xml:space="preserve">xt`. Le moteur refuse ce classeur sur les deux chemins.

## Constat

- L'hypothèse d'`actuary` est **vérifiée** pour les trois outils de l'issue, sur une colonne non lue. `openxlsx` lit faussement la colonne `note`, mais les colonnes `t`, `xt` et `yt` restent identiques au bit près.
- Une cellule **lue** bordée de blancs est altérée par `openxlsx`. Le refus doit donc être maintenu pour la ligne d'en-têtes, les colonnes `t`, `xt` et `yt` et les cellules du triangle.
- Non mesuré :
  - le triangle (colonnes `i`, `j0`…) avec une colonne de texte non lue ;
  - les classeurs du poste Windows (étape 2).
- La suite selon Q-67-4 (a) : spécification d'`actuary-approfondi` en commentaire de #594.
