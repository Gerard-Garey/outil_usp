# K3b, revue finale : `/code-review` (niveau `high`)

> *Constats de la skill `/code-review` (IA), niveau `high`, sur `main...claude/registre-restes` (tête `48f90cf`), le 12/11/2026.* Versés par la session principale, traduits, avec le tri de la session (Refs #555).

| # | Fichier:ligne | Constat | Tri de la session |
|---|---|---|---|
| 1 | `R/engine.R:8175` | Un en-tête `I` est pris pour la colonne `i` : un triangle dont les années de développement seraient intitulées en chiffres romains (I, II, …) perd sa première colonne et reçoit un refus « Triangle non carre » ou « Colonne i non entiere », trompeur. | Conforme à la décision 7 (règle N), qui l'assume : le refus n'est pas silencieux. Cas des chiffres romains consigné au handoff, piste d'issue (message plus explicite). |
| 2 | `R/engine.R:8044` | Une colonne `T` vide ou étrangère, jusqu'ici ignorée, fait désormais échouer un fichier de séries. | Conforme à la décision 8 et à l'avis d'`actuary` (`actuary-textes-555-colonne-t.md`, interaction 2 : changement en sécurité). Consigné. |
| 3 | `R/engine.R:4707` | Le message de refus d'une p hors de [0, 1] (#537) passe par `format()`, qui suit `options(scipen)` : sous `scipen = 100`, `-1e-9` s'écrit « -0.000000001 ». | **Corrigé dans la branche** (commit `moteur:` de reprise, Refs #537). |
| 4 | `R/engine.R:7822` | Une colonne `i` entièrement vide fait échouer l'import (V1), alors qu'elle était ignorée. | Conforme à la décision 1 (« sans vide ») et au texte V1 (« la renseigner pour chaque ligne, ou la retirer ») ; même traitement que `T` vide (décision 8). Consigné au handoff. |
| 5 | `docs/latex/doc_tests_usp.tex:11431` | Les phrases ajoutées sur les deux refus de #534 séparent « Ce dénominateur » de l'expression qu'il désigne. | **Corrigé dans la branche** (commit `docs:` de reprise, Refs #534). |
| 6 | `R/engine.R:4883` | La garde R1 construit une chaîne pour n'en tester que la longueur. | Suggestion déjà jugée facultative par l'audit léger de #536 ; non retenue (une seule aide, Q-60-2 (a)). |
| 7 | `R/engine.R:8101` | `.liste_positions()` n'est pas employée partout (aide `pos()` de `xt`/`yt`, message des cellules non numériques du triangle) ; « Colonne t incomplete » liste toutes les positions sans plafond. | Qualité du code, en partie antérieure à la branche : piste d'issue au handoff. |
| 8 | `R/engine.R:7822` | `.motifs_colonne_i()` double les contrôles de la colonne `t`, avec une sémantique et des textes différents. | Différence voulue (`i` n'est pas triée, `t` l'est ; textes fixés par `actuary`) ; factorisation : piste d'issue au handoff. |
| 9 | `R/engine.R:2424` | `b2_non_defini` exige l'égalité exacte, alors que le moteur traite les ex aequo à `TOL_EX_AEQUO`. | Conforme à la décision 4 (avis d'`actuary`, § 5 : constance exacte) ; inatteignable à T = 8 (n < 20). Consigné au handoff pour `actuary`. |
