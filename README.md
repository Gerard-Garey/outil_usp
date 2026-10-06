# Paramètres propres à l'entreprise (USP) — Solvabilité II, annexe XVII

[![CI](https://github.com/Gerard-Garey/outil_usp/actions/workflows/ci.yml/badge.svg)](https://github.com/Gerard-Garey/outil_usp/actions/workflows/ci.yml)

Application R Shiny et moteur de calcul autonome pour le calibrage des USP
(règlement délégué (UE) 2015/35, articles 218 à 220 et annexe XVII).

> **Licence : [PolyForm Noncommercial 1.0.0](LICENSE).** Usage, modification et
> redistribution permis à des fins non commerciales ; tout usage commercial
> requiert l'accord écrit du titulaire (Gerard-Garey). Les textes réglementaires
> de l'Union versionnés à la racine sont hors licence (réutilisation libre avec
> mention de la source). Aucune donnée d'exploitation ne doit être publiée dans
> le dépôt (section « Confidentialité des données »).

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
    .claude/                    Claude Code : sous-agents, skills, workflows, hooks, outils
    AGENTS.md                   consignes de ChatGPT (Codex), contributeur épisodique
    .codex/                     Codex : fiches de rôle, procédures, script de setup (R, TeX Live)
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

La profondeur T est déduite du fichier des séries (méthodes lognormales) ; le triangle garde la dimension de son propre fichier, et seule « Réinitialiser les données » la change (triangle par défaut de T années, T étant plafonné à 40, #194).

## Usage sans Shiny (revue indépendante)

    source("R/engine.R")

    # méthode lognormale
    # nature_donnees obligatoire pour premium : "brutes" ou "nettes" (#55)
    res <- run_engine(xt = ..., yt = ..., methode = "premium",
                      segment = 1, annexe = "II", nature_donnees = "brutes",
                      T = 8, B = 999, seed = 20260831)

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
| Non-régression | comparaison valeur par valeur (`comparer_objets()`, tolérance 1e-6, relative ou absolue pour une référence quasi nulle) contre les références versionnées (`tests/reference/*.rds`), produites par la CI (workflow `references.yml`, `ubuntu-22.04`, R 4.3.1, BLAS et LAPACK de référence monothread ; ADR 0011 amendé M34) | à tolérance explicite ; ce n'est pas du bit près |

La seconde comparaison absorbe volontairement la dérive d'arrondi d'une
plateforme à l'autre (écart relatif maximal mesuré 3,5e-07 sur la branche
lognormale entre le poste Windows et la CI, alors sous OpenBLAS, ADR 0006 et
0011 ; depuis M34, la CI calcule sous BLAS et LAPACK de référence et deux
exécutions successives y sont identiques au bit près) :

    Rscript tests/test_reproductibilite.R

Les tests unitaires (`tests/unitaires/`) confrontent chaque fonction du moteur à
des références indépendantes ; les défauts connus y figurent en échecs attendus,
avec renvoi à l'issue :

    Rscript tests/test_unitaires.R

Lorsqu'une modification change volontairement les résultats, lister les écarts
(`Rscript tests/comparer_references.R`) et les expliquer. Les références ne sont
plus régénérées hors de la CI, poste compris
([ADR 0011](docs/adr/0011-plateforme-ci-production-des-references.md)) : le
workflow `.github/workflows/references.yml`, déclenché manuellement en mode
`regeneration` (un ou plusieurs cas existants en une seule exécution, motifs
attendus par cas, batteries relancées une fois après le dernier cas) ou
`creation` (un cas nouveau,
ajouté à `CAS` de `tests/outils_tests.R`, sans toucher aux références
existantes), produit les `.rds` et le tableau avant / après en artefact ;
après visa et vérification, ils sont commités avec le code qui les motive
(procédure de la skill `verifier-reproductibilite`). Si aucune valeur numérique ne change, les références peuvent
être patchées (`tests/patcher_reference.R`). La CI GitHub Actions lance les tests et compile la
documentation à chaque push sur `main` et à chaque pull request.

## Confidentialité des données

Le dépôt est public : tout ce qui y est poussé (commits, issues, pull requests,
artefacts de la CI) est lisible par tous et le reste dans l'historique.

- **Aucune donnée d'exploitation** (primes, sinistres, provisions, triangles
  d'une entité réelle) n'est versionnée, jointe à une issue ou à une pull
  request, ni collée dans un message de commit. Les fichiers d'échange de
  l'application (`usp_*.csv`, `usp_*.xlsx`) sont exclus par `.gitignore` ; ne
  pas forcer leur ajout (`git add -f`).
- Les jeux de `tests/donnees/` servent aux tests de non-régression ; un jeu
  nouveau est fictif ou public, et sa provenance est indiquée dans le commit
  qui l'ajoute.
- Aucun secret (jeton, mot de passe, clé) dans le dépôt ni dans les workflows ;
  un secret poussé par erreur est révoqué aussitôt, sa suppression de
  l'historique ne suffisant pas.

## Routage du modèle et de l'effort

`architect` et `actuary` tournent sur Opus par défaut : effort `medium` pour la routine et `high` pour le jugement, Fable réservé à une liste fermée de cas ou à l'accord du mainteneur, avec des plafonds d'escalade (`docs/agents/routage.md`, ADR 0013). Politique issue du dépôt modèle `Gerard-Garey/Modele_vibe_code`, adaptée à ce projet ; ses critères se réévaluent à mesure que le projet évolue (après les dix premières consultations, puis à chaque point d'étape d'`architect`).

- **Où** : critères (matrice, contrats partagés, seuil « macro », plafonds) dans `docs/agents/routage.md` ; effort et plafond de tours de routine dans le frontmatter des fiches de base ; rôles dédoublés, effort et plafond de jugement dans `.claude/outils/fiches_jumelles.sh` (`ROLES`, `EFFORT_APPROFONDI`, `TOURS_APPROFONDI`), puis `bash .claude/outils/fiches_jumelles.sh` pour régénérer les fiches `-approfondi`.
- **Articulation** : les règles de `CLAUDE.md` priment (visa, décisions réservées au mainteneur, deux lectures d'une source).
- **Vérification** : `bash .claude/outils/fiches_jumelles.sh --verifier` (la CI) ; dans une session neuve, une consultation de chaque fiche puis `bash .claude/outils/bilan_journal.sh` (modèle réellement servi, journal local des sous-agents terminés, hook `SubagentStop`) ; les escalades, relances ciblées et arrêts sont notés dans la PR (section « Escalades, relances et arrêts »).
- **Limites** : un plafond de tours n'est pas un plafond de tokens ; l'effort effectif n'est pas observable dans le journal ; la politique ne supprime pas les angles morts des modèles.

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
- Identité des commits : adresse `noreply` de GitHub pour les commits du
  mainteneur (réglage « Keep my email addresses private » du compte), et
  `Claude <noreply@anthropic.com>` pour ceux de Claude (CLAUDE.md).
- Les pull requests sont fusionnées par le mainteneur seul, manuellement, par
  commit de fusion, une fois la CI verte ; aucune fusion automatique.
- ChatGPT (Codex) peut intervenir épisodiquement, sur sa propre branche
  `main-GPT` ([AGENTS.md](AGENTS.md), ADR 0012) ; sa fusion dans `main` suit un
  audit de Claude lancé par le mainteneur.
