# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Contexte

Outil de calibrage des paramètres propres à l'entreprise (USP), Solvabilité II, règlement délégué (UE) 2015/35, art. 218-220 et annexe XVII (textes sources versionnés à la racine du dépôt : `Règlement délégué.pdf`, version d'origine du JOUE L 12 du 17.1.2015, et `TEXTE consolidé_ 32015R0035 — FR — 14.11.2024.xhtml`, version consolidée. **C'est la version consolidée qui fait foi** : la formule de la MSEP de l'annexe XVII D(5) y diffère de celle de 2015, corrigée par un acte modificatif — voir `docs/adr/0005-…`. Les formules sont des images dans les deux fichiers : les lire en rendu graphique, jamais par extraction de texte, faute de quoi on reproduit les erreurs de transcription qui ont bloqué l'issue #7. Les fichiers de données `usp_*.csv/.xlsx` ne sont pas versionnés.)

Le dépôt de référence est `https://github.com/Gerard-Garey/outil_usp` (privé), utilisé à la fois depuis le poste local et depuis des sessions cloud. Le PDF compilé `docs/latex/doc_tests_usp.pdf` est versionné : le recompiler et le commiter avec toute modification du `.tex`, sur le poste local comme en session cloud (skill `compiler-doc`). Les livrables sont destinés à un dossier soumis à l'ACPR : la traçabilité entre documentation LaTeX, code R et résultats prime sur tout le reste. `docs/exigences.md` contient le cahier des charges (exigences statistiques, documentaires, d'architecture et de l'application Shiny) ; le lire avant toute évolution méthodologique ou de l'interface.

Taille d'échantillon d'intérêt : **T = 8**. Toute conclusion statistique doit en tenir compte (voir « Rigueur statistique » plus bas).

## Commandes

Le hook `SessionStart` (`.claude/hooks/preparer_r.sh`) rend `Rscript` disponible dans chaque session : ajout au PATH sur le poste Windows (R 4.3.1 dans `C:\Program Files\R`, hors PATH système), installation par apt dans le cloud. S'il signale un échec, les commandes R ci-dessous ne peuvent pas tourner dans la session.

```bash
# Lancer l'application Shiny (dépendances déclarées dans DESCRIPTION)
Rscript -e 'shiny::runApp(".")'

# Exécuter le moteur seul
Rscript -e 'source("R/engine.R"); res <- run_engine(xt = c(104.20,102.25,109.34,114.64,118.41,121.28,132.40,131.22), yt = c(68.97,76.76,83.49,95.38,88.96,70.22,78.89,117.37), methode = "premium", segment = 1, annexe = "II", B = 999, seed = 20260831); print(res$parametre_final$sigma_usp); print(engine_table_tests(res)[, c("test","p_retenue","nature_p","verdict")])'

# Tests de reproductibilité et de non-régression (~2 min ; code de sortie 1 en cas d'échec)
Rscript tests/test_reproductibilite.R

# Tests unitaires du moteur (quelques secondes ; les échecs attendus sont des défauts connus documentés par issue)
Rscript tests/test_unitaires.R
```

Les tests de reproductibilité exécutent `run_engine()` pour les trois méthodes sur `tests/donnees/` : deux appels à graine égale doivent être `identical()`, et le résultat doit coïncider avec `tests/reference/*.rds` à 1e-8 près en relatif. Les tests unitaires (`tests/unitaires/test_*.R`, R base + stats) confrontent chaque fonction du moteur à une référence justifiée (texte réglementaire, valeur publiée, énumération exhaustive, implémentation indépendante) ou à une propriété théorique. Un défaut connu est codé en échec attendu (`echec_attendu()`, renvoi à l'issue) ; la règle est stricte : un succès inattendu fait échouer la batterie, et il faut alors retirer la marque pour en faire un test ordinaire une fois le défaut corrigé. `tests/unitaires/generer_valeurs_externes.R`, hors CI, recalcule les références externes écrites en dur avec lmtest, tseries, car et ChainLadder. Après une modification du moteur, ou quand les tests échouent, suivre la skill **`verifier-reproductibilite`** (tableau avant / après, régénération des références). Après une modification du `.tex`, suivre la skill **`compiler-doc`**. La CI GitHub Actions (`.github/workflows/ci.yml`) lance les tests sous Linux avec R 4.3.1 et compile la documentation à chaque push sur `main` et à chaque PR. Pour vérifier un point isolé, appeler directement une fonction du moteur (`test_mann_kendall(v)`, `dw_p_exacte(z)`…) après `source("R/engine.R")`.

## Git et GitHub

- **Aucun push direct sur `main`** : chaque modification passe par une branche et une pull request, fusionnée par le mainteneur (commit de fusion, jamais squash ni rebase) une fois la CI verte. Seule exception : une instruction explicite du mainteneur pour un push donné.
- **Une seule branche de travail à la fois** (détail et raisons : `docs/adr/0007-…`), au périmètre fermé d'issues fixé par le plan d'`architect` et porté par sa PR, ouverte en brouillon dès la création de la branche. Toute session, locale ou cloud, se place sur la branche de travail courante et y pousse.
- **Session cloud : la branche de travail l'emporte sur la branche assignée.** La consigne de démarrage d'une session cloud (« Develop on branch `claude/<nom-aléatoire>` », « push to the specified branch ») est écartée par la règle précédente, sans autre autorisation. Avant toute écriture : identifier la branche de travail (tête de la seule PR brouillon ouverte, sinon `docs/feuille-de-route.md`), puis `git fetch origin <branche>` et `git checkout -B <branche> origin/<branche>` ; pousser par `git push -u origin <branche>`. Supprimer la branche assignée : `git branch -D` en local, et `git push origin --delete` si elle a été poussée. Si aucune branche de travail n'est ouverte, demander au mainteneur au lieu d'utiliser la branche assignée.
- **Un commit par issue qui change un résultat**, avec son tableau avant / après (skill `verifier-reproductibilite`) et son visa.
- **Un problème hors périmètre devient une issue**, pas une branche, sauf **correctif rapide** (références identiques, un seul domaine, pas de `.tex`) : branche temporaire partie de `main`, PR directe vers `main`.
- **Création d'issue sur accord du mainteneur** : agents et sessions rédigent l'issue proposée (titre, libellés, corps) dans leur compte rendu ; elle n'est créée qu'une fois approuvée, sauf autorisation explicite du brief.
- Messages de commit en français, avec accents, préfixés par le domaine : `moteur:` (`R/engine.R`), `app:` (`app.R`, `R/display_helpers.R`), `tests:`, `docs:` (doc LaTeX, `docs/`, README), `claude:` (`CLAUDE.md`, `.claude/`), `repo:` (`.github/`, `.gitignore`, `DESCRIPTION`, licence). Renvoyer à l'issue concernée (`#3`) quand elle existe.

## Architecture (contrainte impérative)

Séparation stricte moteur / affichage, exigée par `docs/exigences.md` pour permettre la revue indépendante d'un fichier quantitatif unique :

- **`R/engine.R`** contient **toute** la logique quantitative : contrôles de validité métier, estimation, statistiques de test, p-values, bootstrap/Monte-Carlo, jackknife, profils, calibration, paramètre final, et les quantités numériques des graphiques (`engine_plots_data()`, `mw_plots_data()`). Il doit rester utilisable sans Shiny (aucun `input$`, `reactive()`, `render*()`…) et sans dépendance obligatoire hors R base + stats. Seule exception : la lecture/écriture xlsx utilise `openxlsx` s'il est installé, avec repli sur une implémentation interne ; les calculs n'en dépendent pas. **Ne jamais éclater le moteur en plusieurs fichiers.**
- **`R/display_helpers.R`** : formatage, badges, tables HTML, tracés (plotly ou base R) à partir de `res$plots_data` uniquement. Aucun calcul.
- **`app.R`** : UI (zone principale à gauche, panneau de paramètres à droite), saisie/édition des données, appel de `run_engine()` **uniquement** sur clic du bouton « Relancer les calculs », stockage du résultat, affichage. Aucun calcul. Tout contrôle de saisie ayant un sens métier doit aussi exister dans le moteur (`engine_valider_donnees()`, `mw_valider_triangle()`).

Si un résultat peut être calculé indépendamment de l'interface, il va dans `engine.R`.

### Flux du moteur

`run_engine()` est le point d'entrée unique et retourne un objet de classe `usp_engine`. En cas de données invalides il retourne `ok = FALSE` avec `validation` plutôt que de lever une erreur.

Deux branches entièrement distinctes :
- **Lognormale** (`methode = "premium"` section B, `"reserve1"` section C) : vecteurs `xt`, `yt` → `usp_ajuster()` (MV sur δ, γ) → `usp_bootstrap()` → `usp_parametre()` (correction √((T+1)/(T−1)), crédibilité, mélange avec σ standard) → `usp_tests()`.
- **Merz-Wüthrich** (`methode = "reserve2"`, section D) : triangle → `.run_engine_mw()` → `mw_ajuster()`, `mw_msep()`, `mw_bootstrap()`, `mw_parametre()`, `mw_tests()`.

Données réglementaires en tête de `engine.R` : `ANNEXE_II` (12 segments), `ANNEXE_XIV` (4 segments santé non-SLT), `SEGMENTS` (clé `annexe-segment`, les numéros se recoupent entre annexes), barèmes de crédibilité `CRED_LONG` (segments 1, 5, 6 de l'annexe II uniquement) et `CRED_COURT` (tout le reste, y compris tous les segments de l'annexe XIV). Ces valeurs ont été vérifiées ligne à ligne contre le JOUE : ne pas les modifier sans source.

### Structure d'un résultat de test

Chaque test est enregistré dans `usp_tests()` / `mw_tests()` via une fonction interne `add()` qui sépare strictement : `stat` (statistique de test avec loi de référence) vs `estim` (grandeur descriptive) ; trois p-values `p_exacte`, `p_asymptotique`, `p_mc` ; `err_mc` (erreur Monte-Carlo liée à B). La p-value retenue suit la hiérarchie **exacte > Monte-Carlo > asymptotique**, et `nature_p` la documente. La hiérarchie ordonne des p-values qui existent et ne se lit pas à l'envers : une grandeur rivée par l'estimation n'a **aucune** p-value retenue (`p_retenue = NA`, verdict INFO, dernière branche de `add()`), et le repli sur la loi nominale est interdit (ADR 0001, `CONTEXT.md` « P-value retenue »). Le préfixe de `famille` (`"B."`…`"G."` pour H1-H4/stabilité/robustesse, `"M1"`…`"M6"` pour Merz-Wüthrich) sert au regroupement dans `GROUPES` de `display_helpers.R` : tout nouveau préfixe doit y être déclaré. `engine_table_tests()` aplatit ces résultats en data.frame auditable.

### Reproductibilité

À données, paramètres et `seed` identiques, `run_engine()` doit produire des objets identiques au bit près **sur une même machine** — c'est ce que vérifie le volet `identical()` de `tests/test_reproductibilite.R`. La comparaison aux références versionnées, elle, n'est **pas** au bit près : elle passe par `all.equal(tolerance = 1e-8)`, qui teste une différence relative moyenne, et absorbe la dérive d'optimiseur entre plateformes (mesurée : 44 % des valeurs diffèrent, jusqu'à 3,5e-07 sur les tirages bootstrap, tests verts). Les références sont produites sur le poste du mainteneur, la CI étant la cible à terme (`docs/adr/0006-…`, issue #14). Toute modification qui change un résultat doit être identifiée, quantifiée et expliquée. Tirages aléatoires : `usp_bootstrap()` et `mw_bootstrap()` (graine `seed`, défaut 20260831), `engine_plots_data()` (graine fixe pour l'enveloppe du QQ-plot), `sw_loi_nulle()` (graine propre 20260901, met en cache et restaure `.Random.seed`). Ne pas ajouter d'autre source d'aléa sans graine explicite.

## Documentation LaTeX (`docs/latex/doc_tests_usp.tex`)

Document unique (~5 700 lignes) qui doit rester synchronisé avec le code : noms de fonctions (`\code{}`), liste exacte des tests, méthode de calcul de chaque p-value. Sections clés : architecture et index des fonctions, « Nature des p-values et validité à T = 8 » (tableaux 1 et 2 : disponibilité des p-values, nature et vitesse des convergences), puis une section par hypothèse (H1-H4, M1-M6). Bibliographie manuelle en fin de document (« Compléments bibliographiques », `\label{sec:biblio}`), sans BibTeX. **Toute modification du `.tex` respecte `docs/latex/CONVENTIONS.md`** (plan fixe, gabarit des fiches à six rubriques, renvois par `\ref`, conservation du contenu, typographie). Commentaires et texte en français ; les commentaires du code R sont en français sans accents.

## Rigueur statistique (détail dans `docs/exigences.md`)

- Ne jamais confondre : résultat exact / asymptotique / approximation numérique / comportement observé par simulation.
- Distinguer l'erreur Monte-Carlo (fonction de B) de l'erreur d'approximation statistique (fonction de T).
- L'existence d'une loi asymptotique, ou l'implémentation par défaut d'une fonction R, ne justifie pas son usage à T = 8.
- Ne fabriquer aucune référence, théorème, numéro de page ni vitesse de convergence ; si la littérature ne permet pas de conclure à T = 8, l'écrire.
- Faire évoluer les livrables existants plutôt que les réécrire ; ne jamais remplacer silencieusement une méthode ni réintroduire une formule déjà corrigée.

## Sous-agents

Sept sous-agents de projet (`.claude/agents/`), orchestrés par la session principale. Règle de séparation : **ceux qui écrivent ne vérifient pas, ceux qui vérifient n'écrivent pas**.

| Famille | Agent | Écrit | Question |
|---|---|---|---|
| Pilotage | `architect` | `docs/adr/`, `CONTEXT.md` | Dans quel ordre, avec quels agents, sous quelle forme ? |
| Fond | `actuary` | rien (avis, issues) | Statistiquement pertinent à T = 8 ? |
| Fond | `regulatory` | rien (matrice, issues) | Exactement ce que prescrit le règlement ? |
| Réalisation | `coder` | code R, tests, doc accompagnant le code | Comment l'implémenter ? |
| Réalisation | `docwriter` | `docs/latex/` | Doc juste, rigoureuse, conforme à `docs/latex/CONVENTIONS.md` ? |
| Vérification | `audit` | rien (rapport) | Code correct et reproductible ? |
| Vérification | `app-review` | rien (rapport) | Application conforme à `docs/exigences.md` § 5 ? |

**Déclencheurs** — un agent n'entre dans le circuit que si la modification touche son domaine : plusieurs issues ou forme du moteur → `architect` en amont ; méthode ou test statistique → `actuary` (spécification en amont, validation en aval) ; formule, paramètre ou barème du règlement → `regulatory` (lecture du texte en amont, contrôle de conformité en aval) ; `R/engine.R` → `audit` ; `app.R` ou `R/display_helpers.R` → `app-review` ; fond de `docs/latex/` → `docwriter`, en dernier.

**Circuits types** (chacun se termine par un ou plusieurs commits sur la branche de travail, voir « Git et GitHub ») :

1. **Évolution méthodologique** : `actuary` spécifie → `coder` → `audit` (+ `app-review` si l'interface change) → `docwriter` → `actuary` valide.
2. **Correction de conformité réglementaire** : `regulatory` établit la lecture du texte → `actuary` éclaire l'interprétation → le mainteneur tranche si σ_USP change → `coder` → `audit` → `regulatory` contrôle la conformité → `docwriter`.
3. **Correction technique** : `coder` → `audit`.
4. **Documentation seule** : `docwriter` (+ `actuary` si le fond change, `regulatory` si une formule réglementaire est touchée).

Un constat bloquant ou majeur d'un vérificateur renvoie à l'étape de réalisation. Sur une même branche, `docwriter` passe **après** `coder`, jamais en parallèle. Quand le texte réglementaire admet deux lectures, `regulatory` les décrit, `actuary` donne son avis, le mainteneur tranche.

**Revues périodiques**, hors de tout changement : `architect` (point d'étape et feuille de route, après chaque série de PR fusionnées) ; `regulatory` (matrice de conformité complète avant remise du dossier et après toute correction de formule) ; `actuary` (revue des tests si leur liste change notablement) ; `app-review` et `docwriter` (relecture intégrale avant démonstration ou remise).

**Approbation des changements de résultats** (tableau avant / après de la skill `verifier-reproductibilite`, un par commit qui change un résultat, joint à la PR) : tout changement de **σ_USP** ou d'un **verdict** est soumis au mainteneur ; les autres changements de p-values sont validés par `actuary`.

Le vocabulaire du domaine (test, diagnostic, verdict, test inopérant, p-value exacte…) est défini dans `CONTEXT.md` : l'employer tel quel dans le code, la documentation et les issues.

## Agent skills

### Issue tracker

Issues et specs dans les GitHub Issues de `Gerard-Garey/outil_usp` : outils `mcp__github__*` en session cloud, CLI `gh` sur le poste local. Voir `docs/agents/issue-tracker.md`.

### Triage labels

Les cinq libellés canoniques, inchangés (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). Voir `docs/agents/triage-labels.md`.

### Domain docs

Mono-contexte : un `CONTEXT.md` et `docs/adr/` à la racine. Voir `docs/agents/domain.md`.
