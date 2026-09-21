# Paramètres propres à l'entreprise (USP) — Solvabilité II, annexe XVII

Application R Shiny et moteur de calcul autonome pour le calibrage des USP.

## Méthodes couvertes

| Méthode | Section | Entrée | Modèle |
|---|---|---|---|
| Risque de prime | B | vecteurs `xt`, `yt` | lognormal, variance quadratique |
| Risque de réserve n° 1 | C | vecteurs `xt`, `yt` | lognormal, variance quadratique |
| Risque de réserve n° 2 | D | triangle `C(i,j)` | chaîne d'échelle, MSEP à un an (Merz-Wüthrich) |

Périmètres : annexe II (non-vie, 12 segments) et annexe XIV (santé non-SLT, 4 segments).

## Structure

    app.R                     interface Shiny (aucun calcul quantitatif)
    R/engine.R                MOTEUR : toute la logique statistique et actuarielle
    R/display_helpers.R       formatage et tracés (aucun calcul)
    doc_tests_usp.tex/.pdf    documentation de l'outil

## Fichiers d'échange

    usp_donnees_LN.csv        colonnes t, xt, yt          (méthodes lognormales)
    usp_donnees_MW.csv        colonnes i, j0, j1, ...     (triangle Merz-Wüthrich)

Chargés automatiquement au démarrage s'ils existent ; la profondeur T en est déduite.

## Usage sans Shiny (revue indépendante)

    source("R/engine.R")

    # méthode lognormale
    res <- run_engine(xt = ..., yt = ..., methode = "premium",
                      segment = 1, annexe = "II", T = 8, B = 999, seed = 20260831)

    # méthode Merz-Wüthrich
    res <- run_engine(methode = "reserve2", triangle = tri,
                      segment = 1, annexe = "II", B = 999, seed = 20260831)

    res$parametre_final$sigma_usp
    engine_table_tests(res)

## Usage Shiny

    shiny::runApp(".")

Requiert `shiny` ; `plotly` est utilisé s'il est présent, avec repli automatique
sur les graphiques de base R. Le moteur n'a aucune dépendance hors R base + stats.

## Reproductibilité

À données, paramètres et `seed` identiques, `run_engine()` produit des objets
identiques. La branche lognormale reproduit exactement le script d'origine.
