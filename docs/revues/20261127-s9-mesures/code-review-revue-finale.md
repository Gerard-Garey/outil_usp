# `/code-review` de la branche `claude/mesures-t8` (S9), revue finale

> *Skill `/code-review`, niveau `high`, objet `main...HEAD` (`9f9efc2...f06c484`), le 28/11/2026 (règle 10 de `CLAUDE.md`, étape 10 de la fiche « Branche S9 »). Constats rendus par la skill, vérifiés et triés par la session. Versé par la session.*

## Constats

| # | Gravité | Fichier:ligne | Constat | Suite donnée |
|---|---|---|---|---|
| CR1 | **important** | `tests/puissance_t8.R:1445` | `controle_chaine()` (mode `--familles`, `c92b1bb`) compare `ch$lignes[[k]]$p_mc` à `l_re[[k]]$p_mc`, lignes issues d'`engine_table_tests()`, qui n'a pas de colonne `p_mc` (elle s'appelle `p_monte_carlo`) : NULL contre NULL, donc toujours « identique » ; les branches exclusion et échec ne peuvent pas s'exécuter. La l. 152 de `docs/tableaux/20261127-issue379-familles-ln.md` annonce « 240 identique(s) … OK » pour un contrôle qui n'a pas tourné. | **Vérifié par la session** (`data.frame(p_monte_carlo = 0.2)[1, , drop = FALSE]$p_mc` rend `NULL`). Défaut limité à cette ligne (le volet Merz-Wüthrich compare des listes brutes). Les chiffres de #379 viennent de `run_engine()` complet et ne sont pas touchés ; le `.tex` ne cite pas ce contrôle. **Décision du mainteneur (28/11)** : correction, garde contre une comparaison vide, vérification ciblée hors dépôt sur les 240 réplications contrôlées, tableau gardé tel que produit avec erratum (`synthese.md`). |
| CR2 | nit | `tests/mesure_lb1_dw_t8.R:177` | Q-78-4 (a) demandait un nouveau tableau de `mesure_lb1_dw_t8.R` ; aucun n'est versé. | Écarté : la réexécution a donné une sortie identique au tableau du 20/10 hors T0, et la session a suivi la recommandation d'`actuary` de ne pas verser de doublon (`synthese.md`, étape 2). Critère ADR 0018 : aucun. |
| CR3 | nit | `tests/unitaires/test_dw_limite_rho.R` | Absent de `tests/durees_unitaires.tsv` (ordonnancement des lots au défaut de 60 s). | Écarté pour cette branche : `calculer_durees_unitaires.R` demande `gh api` sur des exécutions de CI, impossible en session cloud ; à faire sur le poste. Critère : aucun. |
| CR4 | nit | `tests/outils_mesure_dw.R:33` | `empreintes_code()` hache les copies du dépôt, non les fichiers sourcés depuis `DOSSIER_SCRIPT`. | Repris dans la correction de CR1. |
| CR5 | nit | `tests/mesure_correlation_cvm_ad_t8.R:65` | Le commentaire confond tailles des groupes (499 ou 500) et des sous-échantillons jackknife. | Repris dans la correction de CR1. |
| CR6 | nit | historique | Six commits sans renvoi à une issue (`16881ac`, `6654a93`, `05f546f`, `51d3fbc`, `56670bf`, `7180bd5`). | Écarté : aucune réécriture d'historique (Q-43-13) ; commits de pilotage de branche. Critère : aucun. |
