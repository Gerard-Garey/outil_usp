# KR, étape 2 : balayage des chaînes du moteur et mesure de #575 (14/11/2026)

> Versé par la session principale. Branche `claude/passage-de-remise`, SHA du gel `a2f9c3a`.

## (i) Balayage (ajustement A) et renumérotation (ajustement H)

**Méthode** (`balayage_chaines.py`, sortie brute dans `balayage-sortie.txt`) :
- extraction des littéraux de chaîne d'au moins 25 caractères de `R/engine.R` à `9f7290f` (base de l'ajustement G) et à `a2f9c3a` ;
- 543 littéraux disparus ou modifiés ;
- recherche de chacun, normalisé (accents, commandes LaTeX, casse et espaces retirés), dans `docs/latex/doc_tests_usp.tex` et `docs/suivi-documentation/` ;
- filtre : on ne garde que les fragments cités par le `.tex` et absents du moteur gelé, même recomposés (concaténation des littéraux).

Usage : `git show 9f7290f:R/engine.R > <dir>/old.R ; git show a2f9c3a:R/engine.R > <dir>/new.R ; python3 balayage_chaines.py <dir>`.

**Résultat** :
- 12 fragments du filtre ; 10 sont de la prose du `.tex` qui ne cite pas le moteur (énoncés de méthode) ;
- les 2 citations textuelles (`\code{}`) sont **conformes au moteur gelé** :
  - l. 12495 : « un seul cote de la mediane represente : loi de R non definie, test non applicable », composé par `usp_tests()` (`R/engine.R` l. 7027, `paste0(ru$cause, ", test non applicable")`) ;
  - l. 17209 : « Un seul cote de la mediane represente : loi de R non definie. », composé par `mw_tests()` (l. 14001, majuscule et point).
- Hors filtre : le `.tex` l. 4398 paraphrase la phrase retirée par #573 (« le rappel que la méthode n° 2 reste ouverte ») ; c'est déjà dans le brief de `docwriter`. Les occurrences dans `docs/suivi-documentation/` sont historiques par nature.

**Renumérotation** : les cinq renvois de lignes de `R/engine.R` dans `docs/suivi-documentation/` (`III-H.md` l. 52, `III-M.md` l. 72, `IV.md` l. 42 et 227, `annexe.md` l. 14) sont tous **datés à un SHA** (« à la tête `a0ad35f` », « à `cefa3b8` », « à la tête `55ea997` », « à la tête `1a8f4f2` », « à `55ea997` ») : ils restent exacts et **aucune renumérotation n'est requise**.

**Brief de `docwriter`** : rien à ajouter au titre du balayage, hors #573 (l. 4398, l. 4444, puce de `sec:mw`).

## (ii) Mesure de #575 sous `openxlsx` 4.2.5.2 (M4 (ii))

**Environnement** : session cloud, R 4.3.3, `LC_ALL=C.UTF-8` ; bibliothèque temporaire hors dépôt (`openxlsx` 4.2.5.2, `zip` 2.3.1, `shiny` 1.8.0, `plotly` 4.10.4, depuis l'archive CRAN) ; dépôt non touché ; moteur au SHA du gel `a2f9c3a`. Script : `mesure_575.sh <bibliotheque> <depot>`, chaque lecture dans un sous-processus R.

**Classeur forgé** (md5 `f9b8e9215f6785b6aa16ec6ffaa56bc2`, non versé) : une feuille `Donnees`, `xl/sharedStrings.xml` à une seule `<si>` (`<si><t>annee</t></si>`), `xl/worksheets/sheet1.xml` :
`<row r="1"><c r="A1" t="s"><v>0</v></c></row><row r="2"><c r="A2" t="s"><v>5</v></c></row>` (indice 5 hors bornes).

| Chemin | Résultat |
|---|---|
| `openxlsx::read.xlsx()` direct, 4.2.5.2 | **segfault** (« caught segfault », `getCellInfo()`), processus R tué, code de sortie 139 |
| `engine_lire_xlsx()` avec `openxlsx` 4.2.5.2 installé | **segfault** au même endroit (appel `openxlsx::read.xlsx()` du moteur), code 139 : le `tryCatch()` de l'appelant ne l'intercepte pas |
| `engine_lire_xlsx()` sans `openxlsx` (lecteur interne) | `data.frame` d'une colonne `annee`, valeur `NA` (refus en aval), code 0 |

**Conclusion** : le défaut de #575 **n'est pas propre à 4.2.9** ; il existe aussi sous **4.2.5.2**, la version de la CI. Sur un poste muni d'`openxlsx`, l'ouverture d'un tel classeur arrête le processus R, donc l'application. Aucun tableur connu n'écrit cette forme (*hypothèse non vérifiée*, handoff `6878784223`). Limite à consigner (Q-C, M4) au README et dans le `.tex` avec les versions mesurées : 4.2.5.2 (cette mesure) et 4.2.9 (#575) ; la version du poste sera relevée à l'étape 3.
