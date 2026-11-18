# Mesure de #594 sous `openxlsx` 4.2.5.2 (JS1, Q-67-4 (a))

*Mesure faite par la session principale (IA) le 18/11/2026, sur la branche `claude/jalon-js1`, au SHA de la batterie `c75a112`. Le code du moteur est identique à celui de `8bc49fb`.*

*Écart à Q-67-4 (a), consigné : la décision prévoyait une mesure hors branche, sur le corpus de l'étape 2 de JS1 (classeurs du poste Windows). La session l'a faite plus tôt, sur des classeurs synthétiques produits ici par les mêmes bibliothèques Python, et l'a versée sur la branche de JS1 (`docs/revues/` seulement ; le code n'est pas touché). Le corpus du poste, qui porte aussi Excel et LibreOffice, reste à mesurer. Le mainteneur a décidé de #594 au vu de cette mesure (E-18/11 (#594)).*

**Reproduction** (depuis la racine du dépôt, `LC_ALL=C.UTF-8`, openpyxl 3.1.5, pandas 3.0.5 et XlsxWriter 3.2.9 importables par `python3`) :
- `python3 <ce dossier>/generer.py tests/donnees/donnees_ln.csv <sortie>` ;
- `Rscript <ce dossier>/mesurer.R <dossier des classeurs>`, avec `R_LIBS=<bibliothèque contenant openxlsx 4.2.5.2>` pour le chemin openxlsx, et sans `openxlsx` pour le chemin de repli ;
- la sonde de l'en-tête (`entete/`) et le complément (`blancs/`) ont leurs propres scripts, cités plus bas ;
- intégrité : `md5sum -c md5.txt`, depuis ce dossier.

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

Sonde complémentaire (`entete/` : `generer_entete.py`, `mesurer_entete.R`, `sortie_entete_lu.txt`) : un en-tête **lu**, `xt ` écrit par openpyxl, est relu par `openxlsx` sous le nom `xml:space="preserve">xt`. Le moteur refuse ce classeur sur les deux chemins (sortie : une ligne `chemin :` par chemin).

## Constat

- L'hypothèse d'`actuary` est **vérifiée** pour les trois outils de l'issue, sur une colonne non lue. `openxlsx` lit faussement la colonne `note`, mais les colonnes `t`, `xt` et `yt` restent identiques au bit près.
- Une cellule **lue** bordée de blancs est altérée par `openxlsx`. Le refus doit donc être maintenu pour la ligne d'en-têtes, les colonnes `t`, `xt` et `yt` et les cellules du triangle.
- Non mesuré : les classeurs du poste Windows (étape 2). Le cas d'un triangle avec une colonne de texte non lue est **sans objet** : toute colonne d'un triangle autre que `i` est une colonne de développement convertie en nombre (`engine_lire_triangle()`), selon la spécification d'`actuary-approfondi`.
- La suite selon Q-67-4 (a) : spécification d'`actuary-approfondi`, postée en commentaire de #594 le 18/11 (`issuecomment-6986469629`). Les deux premières mesures qu'elle demande avant le codage sont faites ci-dessous.

## Complément : textes faits de seuls blancs (§ 3 de la spécification, points 1 et 2)

Dossier `blancs/`. Les classeurs sont produits par `generer_blancs.py` avec openpyxl 3.1.5, de deux façons :
- avec lxml 6.1.3, installé sur la machine (`classeurs/`) ;
- sans lxml, en posant `OPENPYXL_LXML=False` (`classeurs_sans_lxml/`, produit par `generer_sans_lxml.sh`). Ce script copie aussi, sous les noms `note_bordee_blancs` et `note_temoin`, les classeurs openpyxl `_blancs` et `_temoin` de `generer.py`, écrits sans lxml.

Mesure : `mesurer_blancs.R`, sur les deux chemins. Pour chaque classeur lu, ce script relève les lignes au-delà de la huitième et le retour d'`engine_lire_donnees_csv()`. Les sorties sont les fichiers `sortie_*.txt`, et les md5 sont dans `../md5.txt`.

**Attribut posé par openpyxl** (constaté dans `sheet1.xml`) :

| Texte de la note | avec lxml | sans lxml |
|---|---|---|
| bordé de blancs, non blanc (` debut blanc`) | `<t xml:space="preserve">` | `<t xml:space="preserve">` |
| fait de seuls blancs (` `, `   `, tabulation) | `<t xml:space="preserve">` | `<t>`, sans attribut |
| chaîne vide | aucune cellule écrite | aucune cellule écrite |

**Lecture** :

| Classeur | `engine_lire_xlsx()`, deux chemins | `openxlsx::read.xlsx()` direct, colonne `note` |
|---|---|---|
| seuls blancs avec lxml (un blanc, trois blancs, tabulation) | refus (D-S1-31) | **fausse** : `xml:space="preserve"> `, une chaîne non vide |
| seuls blancs sans lxml | lu ; `t`, `xt` et `yt` identiques au CSV | juste (blancs conservés) |
| ligne finale qui ne porte qu'une note blanche, avec lxml | refus | 9 lignes, la neuvième note vaut `xml:space="preserve"> ` |
| ligne finale qui ne porte qu'une note blanche, sans lxml | lu, 9 lignes sur les deux chemins (la neuvième a `t`, `xt` et `yt` à `NA`) ; `engine_lire_donnees_csv()` rend `ok = TRUE` et `n = 8`, **sans avertissement** : la neuvième ligne est écartée sans rien dire | 9 lignes, la neuvième note vaut ` ` |
| bordé de blancs sans lxml | refus | fausse, comme avec lxml |
| chaîne vide | lu ; `t`, `xt` et `yt` identiques | `NA` |

**Constat** :
- La mécanique supposée par la spécification est **vérifiée** sous openxlsx 4.2.5.2 : un texte fait de seuls blancs sous `xml:space="preserve"` est lu par openxlsx comme une chaîne non vide préfixée. Ce texte doit donc rester refusé, comme le recommande la spécification.
- Ligne finale qui ne porte qu'une note blanche :
  - **avec lxml**, le moteur refuse le classeur sur les deux chemins. La divergence de verdict n'est donc pas observable aujourd'hui ; elle apparaîtrait si ce texte était admis ;
  - **sans lxml**, le texte n'a pas d'attribut. Les deux chemins lisent 9 lignes, et `engine_lire_donnees_csv()` écarte la neuvième sans avertissement (`n = 8`). Les deux chemins concordent et aucune valeur n'est fausse. C'est un comportement antérieur à JS1, constaté et non jugé ici ; il est à verser à la spécification d'A1.
- Le refus de #594 touche openpyxl avec ou sans lxml pour un texte bordé de blancs. Pour un texte fait de seuls blancs, il ne le touche qu'avec lxml.

## Complément : corpus du poste Windows (étape 2 (ii) de JS1, 18/11/2026)

Dossier `poste-windows/`, relevé complet : `../etape-2-ii-corpus.md`. Le corpus a été produit et mesuré par la session principale (IA), en session locale sur le poste du mainteneur, au SHA de la batterie `c75a112`.

Conditions :
- Windows 11, R 4.3.3 ucrt, `French_France.utf8` ;
- **`openxlsx` 4.2.9**, version du poste, et non 4.2.5.2 ;
- openpyxl 3.1.5, pandas 3.0.6 (moteurs openpyxl et xlsxwriter), XlsxWriter 3.3.1, lxml 6.1.3 ;
- quinze classeurs : séries témoin, séries à `note` bordée de blancs, et triangle témoin.

Reproduction, depuis la racine du dépôt :
- `python poste-windows/generer_corpus.py tests/donnees/donnees_ln.csv tests/donnees/triangle_mw.csv <sortie>` ;
- `Rscript poste-windows/mesurer_corpus.R <sortie>`, avec puis sans `openxlsx` ;
- md5 des classeurs dans `md5.txt`.

Constat :
- Le comportement mesuré ci-dessus sous `openxlsx` 4.2.5.2 se reproduit **à l'identique** sous 4.2.9 :
  - refus de D-S1-31 sur les deux chemins pour les trois classeurs à chaînes en ligne `xml:space` (openpyxl, pandas-openpyxl, XlsxWriter `constant_memory`) ;
  - lecture directe par `openxlsx` : colonne `note` fausse (préfixe `xml:space="preserve">`), mais `t`, `xt` et `yt` identiques au CSV au bit près ;
  - classeurs à chaînes partagées (XlsxWriter par défaut, pandas-xlsxwriter) lus justes.
- Les classeurs témoins, séries et triangle, sont lus sur les deux chemins, identiques au CSV.
- **Non couverts** : Excel et LibreOffice, absents du poste (décision du mainteneur du 18/11 : pas d'installation). Le relevé de ce qu'ils écrivent (§ 3 de la spécification) reste à faire avant le codage d'A1.
