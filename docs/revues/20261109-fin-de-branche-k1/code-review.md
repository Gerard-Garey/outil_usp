# `/code-review` (niveau high) du diff `main...HEAD` : PR #511 (K1), tête `39111c0`

> *Rédigé par la session principale (IA) : constats de la skill `/code-review`, avec la vérification de la session (09/11/2026).*

| # | Emplacement | Constat | Vérification de la session | Suite |
|---|---|---|---|---|
| 1 | `R/engine.R:5628`, `5654` | La `mc_dispo(mc)` gardée (NA, clé absente de `boot$p_mc`) est masquée par une seconde définition non gardée plus bas dans `usp_tests()` ; la garde de Q-A1 ne s'exécute jamais. | Confirmé. Tous les appels avec `diag = FALSE` passent une clé valide (MK, CoxStuart, DW, Runs, SpearVol, Runsr) : pas de plantage atteignable, garde morte. Mineur. | Reprise K1 : une seule définition. |
| 2 | `R/engine.R:7442`, `.retirer_lignes_colonnes_vides()` | Triangle sans colonne `i` dont la colonne de développement 0 est vide et sans en-tête : la colonne est retirée comme colonne de bord, la dernière ligne devient vide et est retirée ; le fichier est lu comme un triangle (I−1) × (I−1), sans message. | Confirmé (8 × 8 lu 7 × 7, `ok = TRUE`). Le contenu restant est un triangle bien formé : lecture ambiguë plutôt que fausse ; avec colonne `i`, refus. | Issue proposée. |
| 3 | `R/engine.R:4340` | `MENTION_PERMUTATIONS_ALEATOIRES` écrit « T > 9 » en dur alors que la branche teste `T > T_MAX_ENUM_PERMUTATION`. | Confirmé (aussi constat 3 d'`audit`). `MENTION_EDGEWORTH` vient d'une borne externe (prho.c) : légitime. | Reprise K1 : `sprintf`. |
| 4 | `R/engine.R:5637` | `mention_r7()` recalcule `diff(range(x)) == 0` au lieu de lire `usp_regime()`. | Duplication réelle, sans écart constaté. | Hors K1 (note). |
| 5 | `R/engine.R:9571` | `mw_sensibilite_sigma2_dernier()` et `.mw_summary_lm()` n'ont plus d'appelant dans le moteur. | Question déjà posée au mainteneur (handoff du 09/11). | Question au mainteneur. |
| 6 | `R/engine.R:10873` | `.mw_coefs_origine()` reproduit les internes de `summary.lm()` ; identité au bit près mesurée sous R 4.3 seulement. | Le test `test_ordonnee_wls.R` compare à `summary(lm())` sur la R courante : une dérive serait détectée par la batterie. | Aucune action. |
| 7 | `.github/workflows/ci.yml:356` | Si le job `changements` échoue, l'agrégat « Tests du moteur » est sauté, donc passant. | Confirmé à la lecture ; défaut déjà présent sur l'ancien job unique, mais le commentaire « si et seulement si » de #512 est faux. | Reprise K1 (#512). |
