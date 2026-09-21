# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Contexte

Outil de calibrage des paramètres propres à l'entreprise (USP), Solvabilité II, règlement délégué (UE) 2015/35, art. 218-220 et annexe XVII (texte source : `sources/Règlement_délégué.pdf`). Les livrables sont destinés à un dossier soumis à l'ACPR : la traçabilité entre documentation LaTeX, code R et résultats prime sur tout le reste. `ROLE.md` contient le cahier des charges complet (posture attendue, exigences statistiques, architecture, attendus Shiny) ; le lire avant toute évolution méthodologique.

Taille d'échantillon d'intérêt : **T = 8**. Toute conclusion statistique doit en tenir compte (voir « Rigueur statistique » plus bas).

## Commandes

R n'est pas dans le PATH : il est installé dans `C:\Program Files\R\R-4.3.1`.

```bash
# Lancer l'application Shiny (requiert shiny ; plotly facultatif, repli automatique sur base R)
"/c/Program Files/R/R-4.3.1/bin/Rscript.exe" -e 'shiny::runApp(".")'

# Exécuter le moteur seul (aucune dépendance hors R base + stats)
"/c/Program Files/R/R-4.3.1/bin/Rscript.exe" -e 'source("R/engine.R"); res <- run_engine(xt = c(104.20,102.25,109.34,114.64,118.41,121.28,132.40,131.22), yt = c(68.97,76.76,83.49,95.38,88.96,70.22,78.89,117.37), methode = "premium", segment = 1, annexe = "II", B = 999, seed = 20260831); print(res$parametre_final$sigma_usp); print(engine_table_tests(res)[, c("test","p_retenue","nature_p","verdict")])'

# Compiler la documentation (MiKTeX ; deux passes pour la table des matières et les renvois)
pdflatex -interaction=nonstopmode doc_tests_usp.tex && pdflatex -interaction=nonstopmode doc_tests_usp.tex
```

Il n'y a ni suite de tests automatisée, ni linter. La vérification se fait en appelant directement les fonctions du moteur (`run_engine()`, ou une fonction de test isolée comme `test_mann_kendall(v)`, `dw_p_exacte(z)`, etc.) après `source("R/engine.R")`. Pour la méthode Merz-Wüthrich : `run_engine(methode = "reserve2", triangle = tri, segment = 1, annexe = "II")`, où `tri` est une matrice carrée de cumulés avec `NA` sous la diagonale.

## Architecture (contrainte impérative)

Séparation stricte moteur / affichage, exigée par `ROLE.md` pour permettre la revue indépendante d'un fichier quantitatif unique :

- **`R/engine.R`** contient **toute** la logique quantitative : contrôles de validité métier, estimation, statistiques de test, p-values, bootstrap/Monte-Carlo, jackknife, profils, calibration, paramètre final, et les quantités numériques des graphiques (`engine_plots_data()`, `mw_plots_data()`). Il doit rester utilisable sans Shiny (aucun `input$`, `reactive()`, `render*()`…) et sans dépendance hors R base + stats (y compris la lecture/écriture xlsx, réimplémentée à la main). **Ne jamais éclater le moteur en plusieurs fichiers.**
- **`R/display_helpers.R`** : formatage, badges, tables HTML, tracés (plotly ou base R) à partir de `res$plots_data` uniquement. Aucun calcul.
- **`app.R`** : UI (zone principale à gauche, panneau de paramètres à droite), saisie/édition des données, appel de `run_engine()` **uniquement** sur clic du bouton « Relancer les calculs », stockage du résultat, affichage. Aucun calcul. Tout contrôle de saisie ayant un sens métier doit aussi exister dans le moteur (`engine_valider_donnees()`, `mw_valider_triangle()`).

Si un résultat peut être calculé indépendamment de l'interface, il va dans `engine.R`.

### Flux du moteur

`run_engine()` est le point d'entrée unique et retourne un objet de classe `usp_engine` (liste : `donnees`, `validation`, `controles`, `statistiques_descriptives`, `ajustement`, `tests`, `bootstrap`, `ic_bootstrap`, `jackknife`, `profil`, `calibration`, `candidats`, `parametre_final`, `plots_data`, `metadata`). En cas de données invalides il retourne `ok = FALSE` avec `validation` plutôt que de lever une erreur.

Deux branches entièrement distinctes :
- **Lognormale** (`methode = "premium"` section B, `"reserve1"` section C) : vecteurs `xt`, `yt` → `usp_ajuster()` (MV sur δ, γ) → `usp_bootstrap()` → `usp_parametre()` (correction √((T+1)/(T−1)), crédibilité, mélange avec σ standard) → `usp_tests()`.
- **Merz-Wüthrich** (`methode = "reserve2"`, section D) : triangle → `.run_engine_mw()` → `mw_ajuster()`, `mw_msep()`, `mw_bootstrap()`, `mw_parametre()`, `mw_tests()`.

Données réglementaires en tête de `engine.R` : `ANNEXE_II` (12 segments), `ANNEXE_XIV` (4 segments santé non-SLT), `SEGMENTS` (clé `annexe-segment`, les numéros se recoupent entre annexes), barèmes de crédibilité `CRED_LONG` (segments 1, 5, 6 de l'annexe II uniquement) et `CRED_COURT` (tout le reste, y compris tous les segments de l'annexe XIV). Ces valeurs ont été vérifiées ligne à ligne contre le JOUE : ne pas les modifier sans source.

### Structure d'un résultat de test

Chaque test est enregistré dans `usp_tests()` / `mw_tests()` via une fonction interne `add()` qui sépare strictement : `stat` (statistique de test avec loi de référence) vs `estim` (grandeur descriptive) ; trois p-values `p_exacte`, `p_asymptotique`, `p_mc` ; `err_mc` (erreur Monte-Carlo liée à B). La p-value retenue suit la hiérarchie **exacte > Monte-Carlo > asymptotique**, et `nature_p` la documente. Le préfixe de `famille` (`"B."`…`"G."` pour H1-H4/stabilité/robustesse, `"M1"`…`"M6"` pour Merz-Wüthrich) sert au regroupement dans `GROUPES` de `display_helpers.R` : tout nouveau préfixe doit y être déclaré. `engine_table_tests()` aplatit ces résultats en data.frame auditable.

### Reproductibilité

À données, paramètres et `seed` identiques, `run_engine()` doit produire des objets identiques au bit près, et la branche lognormale doit reproduire exactement le script d'origine `usp_solva2.R`. Toute modification qui change un résultat doit être identifiée, quantifiée et expliquée. Tirages aléatoires : `usp_bootstrap()` et `mw_bootstrap()` (graine `seed`, défaut 20260831), `engine_plots_data()` (graine fixe pour l'enveloppe du QQ-plot), `sw_loi_nulle()` (graine propre 20260901, met en cache et restaure `.Random.seed`). Ne pas ajouter d'autre source d'aléa sans graine explicite.

### Fichiers d'échange

`usp_donnees_LN.csv` (colonnes `t, xt, yt`) et `usp_donnees_MW.csv` (colonnes `i, j0, j1, …`), ou leurs équivalents `.xlsx` (prioritaires), sont chargés au démarrage de l'app s'ils existent ; T en est déduit. Sinon, données par défaut définies dans `app.R`.

## Documentation LaTeX (`doc_tests_usp.tex`)

Document unique (~5 700 lignes) qui doit rester synchronisé avec le code : noms de fonctions (`\code{}`), liste exacte des tests, méthode de calcul de chaque p-value. Sections clés : architecture et index des fonctions, « Nature des p-values et validité à T = 8 » (tableaux 1 et 2 : disponibilité des p-values, nature et vitesse des convergences), puis une section par hypothèse (H1-H4, M1-M6). Bibliographie manuelle en fin de document (« Compléments bibliographiques », `\label{sec:biblio}`), sans BibTeX. Macros maison : `\code`, `\refl`, `\reglement`, environnement `encadre`. Commentaires et texte en français ; les commentaires du code R sont en français sans accents.

## Rigueur statistique (exigences de `ROLE.md`)

- Ne jamais confondre : résultat exact / asymptotique / approximation numérique / comportement observé par simulation.
- Distinguer l'erreur Monte-Carlo (fonction de B) de l'erreur d'approximation statistique (fonction de T).
- L'existence d'une loi asymptotique, ou l'implémentation par défaut d'une fonction R, ne justifie pas son usage à T = 8.
- Ne fabriquer aucune référence, théorème, numéro de page ni vitesse de convergence ; si la littérature ne permet pas de conclure à T = 8, l'écrire.
- Faire évoluer les livrables existants plutôt que les réécrire ; ne jamais remplacer silencieusement une méthode ni réintroduire une formule déjà corrigée.
