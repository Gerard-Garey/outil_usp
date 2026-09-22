# Paramètres propres à l'entreprise (USP) — Solvabilité II, annexe XVII

[![CI](https://github.com/Gerard-Garey/outil_usp/actions/workflows/ci.yml/badge.svg)](https://github.com/Gerard-Garey/outil_usp/actions/workflows/ci.yml)

Application R Shiny et moteur de calcul autonome pour le calibrage des USP
(règlement délégué (UE) 2015/35, articles 218 à 220 et annexe XVII).

> **Confidentiel — usage interne.** Voir [LICENSE](LICENSE).

## Méthodes couvertes

| Méthode | Section | Entrée | Modèle |
|---|---|---|---|
| Risque de prime | B | vecteurs `xt`, `yt` | lognormal, variance quadratique |
| Risque de réserve n° 1 | C | vecteurs `xt`, `yt` | lognormal, variance quadratique |
| Risque de réserve n° 2 | D | triangle `C(i,j)` | chaîne d'échelle, MSEP à un an (Merz-Wüthrich) |

Périmètres : annexe II (non-vie, 12 segments) et annexe XIV (santé non-SLT, 4 segments).

## Prérequis

- **R ≥ 4.3** (développé et testé avec R 4.3.1).
- Moteur (`R/engine.R`) : R base + `stats` uniquement. `openxlsx` est utilisé
  s'il est installé pour lire et écrire les fichiers Excel, avec repli sur une
  implémentation interne ; les calculs n'en dépendent pas.
- Application : `shiny` ; `plotly` en option (repli automatique sur les
  graphiques de base R). Dépendances déclarées dans `DESCRIPTION` :
  `remotes::install_deps(dependencies = TRUE)` les installe.
- Documentation : une distribution LaTeX (MiKTeX, TeX Live).

## Structure

    app.R                       interface Shiny (aucun calcul quantitatif)
    R/engine.R                  MOTEUR : toute la logique statistique et actuarielle
    R/display_helpers.R         formatage et tracés (aucun calcul)
    tests/                      tests unitaires, de reproductibilité et de non-régression
    docs/exigences.md           cahier des charges
    docs/latex/                 documentation de l'outil (.tex et PDF compilé)
    docs/agents/                configuration des agents (issues, libellés, domaine)
    .claude/                    Claude Code : sous-agents, skills, hook de session
    .github/                    intégration continue, modèles d'issues et de PR
    DESCRIPTION                 version de R et dépendances

Non versionnés : `sources/` (textes réglementaires) et les fichiers de données
`usp_*.csv` / `usp_*.xlsx`, potentiellement confidentiels.

## Usage de l'application

    shiny::runApp(".")

Sous Windows, si R n'est pas dans le PATH :

    "C:\Program Files\R\R-4.3.1\bin\Rscript.exe" -e "shiny::runApp('.')"

Au démarrage, l'application charge les fichiers d'échange s'ils existent
(`.xlsx` prioritaire sur `.csv`) ; sinon, des données par défaut :

    usp_donnees_LN.csv        colonnes t, xt, yt          (méthodes lognormales)
    usp_donnees_MW.csv        colonnes i, j0, j1, ...     (triangle Merz-Wüthrich)

La profondeur T est déduite du fichier.

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

## Reproductibilité et tests

`tests/test_reproductibilite.R` vérifie, pour les trois méthodes, deux
propriétés distinctes :

| Propriété | Ce qui est vérifié | Statut |
|---|---|---|
| Reproductibilité à graine égale | `identical()` entre deux appels de `run_engine()` à données, paramètres et `seed` identiques, sur une même machine | au bit près, mesuré |
| Non-régression | `all.equal(tolerance = 1e-8)` contre les références versionnées (`tests/reference/*.rds`), produites sur la plateforme désignée par l'ADR 0006 | à tolérance explicite ; ce n'est pas du bit près |

La seconde comparaison absorbe volontairement la dérive d'arrondi d'une
plateforme à l'autre (écart relatif maximal mesuré 3,5e-07 sur la branche
lognormale, ADR 0006) :

    Rscript tests/test_reproductibilite.R

Les tests unitaires (`tests/unitaires/`) confrontent chaque fonction du moteur à
des références indépendantes ; les défauts connus y figurent en échecs attendus,
avec renvoi à l'issue :

    Rscript tests/test_unitaires.R

Lorsqu'une modification change volontairement les résultats, lister les écarts
(`Rscript tests/comparer_references.R`), les expliquer, puis régénérer les
références (`Rscript tests/generer_references.R`) dans le même commit, sur la
plateforme désignée par l'ADR 0006, ou les patcher (`tests/patcher_reference.R`)
si aucune valeur numérique ne change. La CI GitHub Actions lance les tests et compile la
documentation à chaque push sur `main` et à chaque pull request.

## Contribuer

- Les demandes passent par les **issues GitHub** (modèles « Anomalie » et
  « Évolution »), triées avec les libellés `needs-triage`, `needs-info`,
  `ready-for-agent`, `ready-for-human` et `wontfix`.
- Pas de push direct sur `main` : une seule branche de travail à la fois,
  fusionnée par pull request une fois la CI verte
  ([ADR 0007](docs/adr/0007-une-branche-de-travail-a-la-fois.md)). Messages de commit préfixés
  par domaine (`moteur:`, `app:`, `tests:`, `docs:`, `claude:`, `repo:`).
- Les évolutions passent par sept sous-agents Claude Code : pilotage
  (`architect`), fond (`actuary`, `regulatory`), réalisation (`coder`,
  `docwriter`) et vérification (`audit`, `app-review`). Le circuit dépend de ce
  que touche la modification ; les circuits types et les revues périodiques sont
  décrits dans [CLAUDE.md](CLAUDE.md).
- Toute modification de la documentation LaTeX respecte
  [`docs/latex/CONVENTIONS.md`](docs/latex/CONVENTIONS.md).
- Toute modification du code s'accompagne de la mise à jour de la documentation
  LaTeX et de la recompilation du PDF.
