# `/code-review` (effort high) de K3 « Registre »

> *Résultat de la skill `/code-review` (effort `high`) sur `origin/main...HEAD` (tête `e53ea4e`), 10/11/2026, reproduit et trié par la session principale (Q-54-10).*

| # | Emplacement | Constat | Suite |
|---|---|---|---|
| 1 | `R/engine.R:2631` | La garde n1 = n2 = 1 (#486) est au point d'appel ; `runs_p_exacte()`, `runs_p_min()`, `usp_runsr_p_exacte()` rendent toujours p = 1 sur la loi ponctuelle R = 2 ; des scripts d'étude (`tests/puissance_t8.R`, `tests/constats_puissance_t8.R`) les appellent directement. | **Écarté** : la loi exacte de R à n1 = n2 = 1 existe et vaut 1 (avis d'`actuary`) ; la règle « aucune p sur une ligne non applicable » est une convention de restitution, posée au point d'appel ; les fonctions sont appelées directement par des tests unitaires. |
| 2 | `R/engine.R:7214` | Motifs non applicables des suites construits par `paste0(cause, …)` sans garde si `cause` est NA (Runsr : branche choisie sur `boot$stats_obs$Runsr`, cause recalculée par `test_runs(u, plancher_u)`). | **Corrigé** (commit de corrections de revue). |
| 3 | `R/engine.R:4572` | `verifier_p()` refuse toute p finie hors de [0, 1] sans tolérance : un artefact d'un ulp ferait lever une erreur à `run_engine()`. | **Corrigé** : tolérance nommée, valeur non modifiée. |
| 4 | `R/engine.R:6774` | Repli « T = %d < 20 » d'Anscombe-Glynn imprimé à T ≥ 20 si aucune cause n'est levée. | **Corrigé** : `stop()` explicite à T ≥ 20 (cas inatteignable, mesuré par `audit`). |
| 5 | `R/engine.R:2329` | `b2_non_defini` vrai pour tout b2 non fini, y compris résidus `NA` ou dépassement de m4 : le motif « résidus constants » serait faux. | **Écarté** : `z` vient d'un ajustement sur données validées ; inatteignable par `run_engine()` (audit léger de #485). Issue proposée au mainteneur dans le handoff. |
| 6 | `tests/unitaires/test_defauts_connus.R:607` | Titre « avec ou sans verdict » devenu faux. | **Corrigé** (titre). Le refus de l'argument `verdict` est couvert par C3 de `test_registre_add.R`. |
| 7 | `R/engine.R:4865` | Le contrôle de rang de `nature_forcee` recalcule la hiérarchie au lieu de lire le rang choisi. | **Écarté** (forme ; sortie identique) ; issue proposée dans le handoff. |
| 8 | `R/engine.R:4744` | Deux formes du motif Monte-Carlo (« m. » sous R1, « m, » dans `aucune_p`). | **Écarté** (forme ; les deux commencent par « Monte-Carlo indisponible : ») ; issue proposée dans le handoff. |
| 9 | `R/engine.R:5746` | `mention_r7()` code « volumes exactement constants » par une double négation. | **Écarté** (choix du plan : aucun champ nouveau d'`usp_regime()`). |
