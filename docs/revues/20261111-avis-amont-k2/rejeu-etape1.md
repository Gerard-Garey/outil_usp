# K2, étape 1 : rejeu des constats

> *Rapport de `coder` (fiche de base, effort `high`), reproduit par la session principale (mise en forme seule).* Branche `claude/fichiers-et-point-decimal`, tête `e53b4bb` (code identique à `main` `83198f5`), 11/11/2026. Aucun fichier du dépôt n'a été modifié pendant le rejeu, et aucun commit n'a été fait. Les scripts et leurs sorties sont versés dans `scripts-rejeu/`. Ils chargent le harnais `outils.R` par un chemin du scratchpad de la session : pour les rejouer, adapter ce chemin. Ils ont été lancés par `LC_ALL=C.UTF-8 R_LIBS_USER=<bibliothèque> Rscript <script>.R`, depuis la racine du dépôt.

- **Installation** : `openxlsx` 4.2.9, et aussi 4.2.5.2 et 4.2.7 pour le contournement de #488.
- **Base de départ avec `openxlsx`** : `test_outdec.R` 30/30 et `test_controles_entree.R` 301/301 (`baseline_tests.out`). Aucune ligne « [saute] » : les tests de parité ont tourné.
- **Statut** : tout est *vérifié* (mesuré), sauf mention « hypothèse ».

## #488 : export xlsx exact par `openxlsx`

**Établi techniquement, mais seulement par un contournement non documenté.** `coder` le déconseille comme base d'un invariant.

- **Cause des 15 chiffres.** `openxlsx` 4.2.9 (`R/workbook_write_data.R` l. 145-150) écrit `class(df[[i]]) <- "character"`, ce qui passe par `as.character()` d'un double. Ainsi `as.character(1/3)` donne `"0.333333333333333"` (15 chiffres), même sous `options(digits = 22)`. Les options `digits` et `openxlsx.numFmt`, la classe `"scientific"` et `writeData` n'y changent rien (`c488b.out`).
- **Contournement.** On passe une colonne de chaînes écrites selon la règle de `.xlsx_nombre()`, avec `attr(col, "class") <- "numeric"`. `openxlsx` écrit alors `<v>0.33333333333333331</v>` avec `t="n"`. La relecture est `identical()` sur la grille (0.1, 1/3, 2001, 1e-300, 1.7976931348623157e308, 0.1+0.2, 5e-324, NA), avec `openxlsx` 4.2.5.2, 4.2.7 et 4.2.9 (`c488e.out`). Ce moyen repose sur un détail d'implémentation. Les autres versions et ±Inf n'ont pas été mesurés.
- **Seul l'écrivain interne (`.xlsx_nombre()`) est exact par construction.** Il se relit `identical()` par les deux lecteurs.
- **Autre défaut.** 1.7976931348623157e308 devient `1.79769313486232e+308`, que la relecture lit `Inf`. L'export `openxlsx` et `write.csv` sont tous deux touchés (`c488a.out`, `c488f.out`).

| Jeu | xlsx par `openxlsx` | xlsx par l'écrivain interne | CSV `write.csv` (`app.R`) |
|---|---|---|---|
| Six cas de référence | identique | identique | identique |
| Grille | non identique (1/3 ; 1.797e308 → `Inf`) | identique | non identique |
| 8 réels aléatoires à 17 chiffres | non identique, 3,58e-15 | identique | non identique, 3,58e-15 |
| Triangle `.tri × π/3` | non identique | identique | non identique |
| Témoin : CSV selon la règle de `.xlsx_nombre()` | — | — | identique sur tous les jeux |

Effet sur σ_USP (`c488d.out`). Le jeu est `.ln` perturbé à 17 chiffres (premium, segment 1, B = 99). σ_USP vaut 0.11143899623237227 sur la donnée d'origine, et 0.11143899626950285 après un export par `openxlsx` ou par CSV, soit un écart relatif de 3,33e-10. L'empreinte « données » diffère dans ce cas ; elle est égale après l'écrivain interne.

## #487 : lecteur interne

| Constat de la fiche | État mesuré | Reste à faire |
|---|---|---|
| Feuille = premier fichier par ordre alphabétique | Confirmé : avec les données en `sheet2.xml`, première du classeur, le lecteur interne lit 101 et `openxlsx` 201 (`c487.out`). Cas `sheet2.xml` première et `sheet10.xml` deuxième : même écart. Avec onze feuilles en ordre inverse : 1001 contre 11001 (`c487c.out`). | Résoudre par `workbook.xml` + `workbook.xml.rels` ; fixtures 1j et 1k. |
| Entités XML non décodées | Écart plus large que dans la fiche. Le lecteur interne ne décode rien. `openxlsx` décode les entités nommées dans `sharedStrings` seulement, ni dans `inlineStr` ni les entités numériques (`c487.out`, `c487b.out`). | Décoder les deux formes ; question de parité (ci-dessous). |
| Chaîne enrichie en ligne : premier segment seul | Confirmé pour le lecteur interne. `openxlsx` ne lit pas `<is><r>…` du tout (il rend `NA`). En `sharedStrings`, les deux chemins concatènent les segments. | Lire les segments entiers ; divergence à nommer. |
| Cellule sans `r` (hypothèse) | Mesuré : sans `r` mais avec d'autres attributs, les deux chemins lèvent une erreur R brute. Sans aucun attribut (`<c><v>5</v></c>`), la valeur est **perdue sans message** dans les deux chemins (nouveau constat). | Refus explicite. |
| (nouveau) Espaces dans les en-têtes | `openxlsx` rend « deux mots » en « deux.mots » ; le lecteur interne garde l'espace. | Divergence à nommer ou à supprimer. |

## #522 : en-tête hors ligne 1, caractères de contrôle

| Constat | État mesuré | Reste à faire |
|---|---|---|
| Lignes au-dessus de l'en-tête | Confirmé pour les séries et pour le triangle 8 × 8 (`c522.out`, `c522b.out`). `openxlsx` accepte le fichier (`ok = TRUE`) ; le lecteur interne le refuse avec un motif trompeur. | Refus commun aux deux chemins, qui nomme la ligne 1 attendue. |
| Titre en A1, en-tête en ligne 2 ou 3 | Les deux chemins refusent, mais avec des textes différents. | Question pour `actuary`. |
| Forme « règle commune sur le data.frame » | **Impossible** : `openxlsx` perd les lignes de tête vides même avec `skipEmptyRows = FALSE` (`c522d.out`). Une sonde `read.xlsx(rows = 1, colNames = FALSE, skipEmptyRows = FALSE)` détecte une ligne 1 vide (`c522e.out`). | Appliquer le repli de la fiche : correction dans chaque chemin, règle commune sur le résultat de la sonde, test de parité. |
| Caractères de contrôle dans « Colonnes présentes » | Confirmé : les octets 01, 09, 0A et 1B passent bruts (`c522c.out`). | Échappement dans `engine_lire_donnees_csv()`. |

## #520 : colonne de développement 0 vide sans en-tête

| Cas | Résultat actuel (`c520.out`, `c520b.out`) |
|---|---|
| Sans colonne `i` (CSV, ou xlsx par les deux chemins) | **Lu en 7 × 7 sans message.** σ_USP vaut 0.05851230792, contre 0.04977646129 pour le vrai 8 × 8 (B = 199). |
| Avec colonne `i` | Déjà refusé, mais par le motif « Triangle non carre (8 annees d'accident, 7 annees de developpement) ». Le refus est accidentel et ne nomme pas la colonne 0. |
| Colonne 0 vide avec en-tête | Refus LE-06 correct. |

Écart avec la fiche : avec `i`, la colonne est déjà refusée, mais sous le mauvais motif. Le défaut de silence ne concerne que le cas sans `i`.

## #550

| Constat | État mesuré | Reste à faire |
|---|---|---|
| O2 | Confirmé : avec six colonnes, le message dit « et 1 autre(s) » pour les numéros, mais ne donne que cinq en-têtes et passe le sixième sous silence (`c550.out`). | Appliquer la même coupe à la liste des en-têtes. |
| O1 | Confirmé, l. 9365 et 9368. | Aligner la notation (texte fixé à l'étape 2). |
| (nouveau) Troisième occurrence | l. 9405, doublon d'année d'accident : « (lignes 2 et 5, i=1 et i=4) ». | Question pour `actuary`. |
| Atteignabilité | Ces messages ne sont atteignables qu'avec un triangle à noms de lignes, donc par appel direct. `app.R` ne pose aucun nom de ligne. | Fixtures à triangle nommé. |

## #439 : points d'entrée et point décimal

- **Inventaire** (`c439a.out`) :
  - dans `app.R`, douze fonctions du moteur sont appelées (`run_engine`, les trois lecteurs, `engine_ecrire_xlsx`, quatre validateurs, `engine_motif_b_alpha`, `engine_table_tests`) ;
  - dans `R/display_helpers.R`, sept (`run_engine`, `engine_table_tests`, `engine_empreinte`, `engine_derogations`, `engine_parametre_standard`, `engine_regle_verdicts`).
  - La fiche n'en annonçait que quatre hors `run_engine()`.
  - Ne sont pas couverts par `test_outdec.R` : les trois lecteurs, `engine_ecrire_xlsx` (chemin `openxlsx`), `engine_empreinte`, `engine_regle_verdicts`, `engine_parametre_standard`.
- **Sous `options(OutDec = ",")`** (`c439b.out`, `c439c.out`) :
  - les vingt appels comparés entre `"."` et `","` sont tous `identical()` ;
  - les XML écrits sont identiques, à l'horodatage près.
- **Conséquence** : aucun défaut actuel n'est mesuré. #439 est une garde structurelle. Le nouveau test doit en plus vérifier la restauration de l'option de l'appelant.

## Écarts avec la fiche

1. #520 : avec `i`, le refus existe déjà, sous un motif trompeur.
2. #487 : la divergence d'entités est plus large que prévu, et une cellule sans aucun attribut perd sa valeur sans message.
3. #522 : une règle commune sur le data.frame est impossible ; la sonde `rows = 1` en tient lieu.
4. #550 : la notation « i=… » a une troisième occurrence, l. 9405.
5. #439 : l'inventaire de la fiche est incomplet (12 + 7 fonctions au lieu de 4).
6. #488 : l'écart sur σ_USP se retrouve ; 1.797e308 passe à `Inf`.
7. L'en-tête d'`engine_lire_xlsx()` ne nomme pas la divergence des espaces d'en-tête.

## Questions ouvertes à la fin du rejeu

1. #488 : contournement protégé par un aller-retour interne (i), ou écrivain interne seul (ii) ? L'invariant de `CLAUDE.md` est en jeu : décision du mainteneur.
2. #487 : faut-il décoder aussi les entités numériques ? Le contrat « même data.frame » porte-t-il sur les `sharedStrings` seulement ?
3. #522 : texte du refus d'une ligne 1 vide ; faut-il un motif propre au titre en A1 ?
4. #520 : avec `i`, faut-il le même texte que sans `i`, à la place du motif « Triangle non carre » ?
5. #550 : faut-il aligner aussi l'occurrence de la l. 9405 ?
6. Cellule sans `r` ou sans attribut : texte du refus.
7. Espaces d'en-tête : nommer la divergence ou la supprimer ?
