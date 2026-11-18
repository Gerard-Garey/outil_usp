# Tableau avant / après — facteur NP conditionnel de l'art. 117, paragraphe 3, à partir du 30.1.2027 (issue #504, commit (c) de S3, ADR 0019, point 3)

| Grandeur | Valeur |
|---|---|
| Date | 2026-11-17 |
| Commande | `LC_ALL=C.UTF-8 Rscript docs/revues/20261117-s3-reglement-2026-269/scripts/tableau_c.R docs/tableaux/20261117-issue504-facteur-np-conditionnel.md engine_avant_s3.R engine_b7f40a7.R` (racine du dépôt ; moteurs de comparaison tirés par `git show edf7ff9:R/engine.R` et `git show b7f40a7:R/engine.R`) |
| Script | `tableau_c.R`, md5 `7f5687b9d55c23106a117ce9beb83460` |
| Moteur (après (c)) | `R/engine.R` de l'arbre de travail, md5 `13acfaee40586ab41b0c9c3bdc75ae88` |
| Outil d'avant S3 | `R/engine.R` de `de83b19^` (`main` avant S3), md5 `a73c2f2028d2005d64d1a6a215c14900` |
| Tête de la branche avant (c) | `R/engine.R` de `b7f40a7`, md5 `09cca606ae038859d599f6a964aa9ea5` |
| Commit de base | `b7f40a7c21271ce14e892f33df1992e8b1466432` (arbre de travail modifié : moteur identifié par son md5) |
| R, plateforme | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; BLAS : libblas.so.3.12.0 |
| Appels | `run_engine()` complet, B = 999, graine 20260831, alpha = 0,10 (défauts, ceux des références) ; **avant** : `date_reference = DATE_REFERENCE_TESTS` ("2026-12-31", texte `"2019/981"`) ; **après** : `date_reference = "2027-01-30"` (texte `"2026/269"`), mêmes autres arguments, déclaration comprise |
| Comparateur | `aplatir()` et `ecart_feuille()` de `tests/outils_tests.R` (tol = 0 : toute feuille non `identical()` est listée ; écart relatif si \|avant\| > 1e-6, absolu sinon) |

Lecture : « sans NP » = réassurance non proportionnelle déclarée absente (`reassurance_np = FALSE`) ; « avec NP » = déclarée présente (`TRUE`). Sous le texte `"2019/981"` la déclaration est sans effet (facteur NP standard sans condition) : l'appel « avant » est donc le résultat de l'outil d'avant S3 (contrôle d'antériorité, § 5). II-4 et II-5 sont illustratifs : mêmes données réaffectées à un autre segment (seuls le σ standard et le barème changent ; avis d'`actuary`, § 3.2).

## 1. σ_USP et σ standard (visa du mainteneur)

| Cas | Groupe | σ standard avant | σ standard après | σ_USP avant | σ_USP après | Δσ_USP | Δ relatif | variation_relative avant | variation_relative après |
|---|---|---|---|---|---|---|---|---|---|
| donnees_ln II-1 nettes, réassurance NP déclarée absente (FALSE) | sans NP | 0,08 | 0,1 | 0,1032524114 | 0,1114524114 | +0,0082 | +7,94 % | 0,2906551428 | 0,1145241142 |
| donnees_ln II-1 nettes, réassurance NP déclarée présente (TRUE) | avec NP | 0,08 | 0,08 | 0,1032524114 | 0,1032524114 | 0 (identical) | 0 | 0,2906551428 | 0,2906551428 |
| donnees_ln II-4 nettes, réassurance NP déclarée absente (FALSE) | sans NP | 0,064 | 0,08 | 0,1088828021 | 0,1119228021 | +0,00304 | +2,79 % | 0,7012937832 | 0,3990350265 |
| donnees_ln II-4 nettes, réassurance NP déclarée présente (TRUE) | avec NP | 0,064 | 0,064 | 0,1088828021 | 0,1088828021 | 0 (identical) | 0 | 0,7012937832 | 0,7012937832 |
| donnees_ln II-5 nettes, réassurance NP déclarée absente (FALSE) | sans NP | 0,112 | 0,14 | 0,1163724114 | 0,1278524114 | +0,01148 | +9,86 % | 0,0390393877 | -0,08676848984 |
| donnees_ln II-5 nettes, réassurance NP déclarée présente (TRUE) | avec NP | 0,112 | 0,112 | 0,1163724114 | 0,1163724114 | 0 (identical) | 0 | 0,0390393877 | 0,0390393877 |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée absente (FALSE) | sans NP | 0,08 | 0,1 | 0,07893086786 | 0,08713086786 | +0,0082 | +10,39 % | -0,01336415178 | -0,1286913214 |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée présente (TRUE) | avec NP | 0,08 | 0,08 | 0,07893086786 | 0,07893086786 | 0 (identical) | 0 | -0,01336415178 | -0,01336415178 |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée absente (FALSE) | sans NP | 0,064 | 0,08 | 0,07549220841 | 0,07853220841 | +0,00304 | +4,03 % | 0,1795657565 | -0,01834739482 |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée présente (TRUE) | avec NP | 0,064 | 0,064 | 0,07549220841 | 0,07549220841 | 0 (identical) | 0 | 0,1795657565 | 0,1795657565 |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée absente (FALSE) | sans NP | 0,112 | 0,14 | 0,09205086786 | 0,1035308679 | +0,01148 | +12,47 % | -0,1781172513 | -0,260493801 |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée présente (TRUE) | avec NP | 0,112 | 0,112 | 0,09205086786 | 0,09205086786 | 0 (identical) | 0 | -0,1781172513 | -0,1781172513 |
| donnees_ln II-1 brutes, sans déclaration (témoin) | temoin | 0,1 | 0,1 | 0,1114524114 | 0,1114524114 | 0 (identical) | 0 | 0,1145241142 | 0,1145241142 |
| donnees_ln_interieur II-1 brutes, sans déclaration (témoin) | temoin | 0,1 | 0,1 | 0,08713086786 | 0,08713086786 | 0 (identical) | 0 | -0,1286913214 | -0,1286913214 |
| donnees_ln II-6 nettes, réassurance NP déclarée absente (FALSE) (témoin) | temoin | 0,19 | 0,19 | 0,1483524114 | 0,1483524114 | 0 (identical) | 0 | -0,2191978346 | -0,2191978346 |
| donnees_ln XIV-1 nettes, réassurance NP déclarée absente (FALSE) (témoin) | temoin | 0,05 | 0,05 | 0,1062228021 | 0,1062228021 | 0 (identical) | 0 | 1,124456042 | 1,124456042 |
| reserve1 (donnees_ln, II-1), CDD qualifiante déclarée absente (FALSE) (témoin) | temoin | 0,09 | 0,09 | 0,1073524114 | 0,1073524114 | 0 (identical) | 0 | 0,1928045714 | 0,1928045714 |
| reserve2 (triangle_mw, II-1), CDD qualifiante déclarée absente (FALSE) (témoin) | temoin | 0,09 | 0,09 | 0,04977646129 | 0,04977646129 | 0 (identical) | 0 | -0,4469282079 | -0,4469282079 |

Contrôle : pour chaque cas « sans NP », Δσ_USP comparé à (1 − c) × (σ brut − NP × σ brut) = (1 − c) × 0,2 × σ brut, c lu dans `parametre_final$credibilite` :

| Cas | c | σ brut | (1 − c) × 0,2 × σ brut | Δσ_USP mesuré | \|écart\| |
|---|---|---|---|---|---|
| donnees_ln II-1 nettes, réassurance NP déclarée absente (FALSE) | 0,59 | 0,1 | 0,0082 | 0,0082 | 1,73e-18 |
| donnees_ln II-4 nettes, réassurance NP déclarée absente (FALSE) | 0,81 | 0,08 | 0,00304 | 0,00304 | 1,21e-17 |
| donnees_ln II-5 nettes, réassurance NP déclarée absente (FALSE) | 0,59 | 0,14 | 0,01148 | 0,01148 | 1,91e-17 |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée absente (FALSE) | 0,59 | 0,1 | 0,0082 | 0,0082 | 1,56e-17 |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée absente (FALSE) | 0,81 | 0,08 | 0,00304 | 0,00304 | 1,21e-17 |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée absente (FALSE) | 0,59 | 0,14 | 0,01148 | 0,01148 | 5,2e-18 |

## 1 bis. `metadata` : σ standard et les quatre champs nouveaux (avant → après)

| Cas | `sigma_standard` | `date_reference` | `texte_applicable` | `reassurance_np` | `cdd_qualifiante` |
|---|---|---|---|---|---|
| donnees_ln II-1 nettes, réassurance NP déclarée absente (FALSE) | 0,08 → 0,1 | 2026-12-31 → 2027-01-30 | 2019/981 → 2026/269 | FALSE | NA |
| donnees_ln II-1 nettes, réassurance NP déclarée présente (TRUE) | 0,08 | 2026-12-31 → 2027-01-30 | 2019/981 → 2026/269 | TRUE | NA |
| donnees_ln II-4 nettes, réassurance NP déclarée absente (FALSE) | 0,064 → 0,08 | 2026-12-31 → 2027-01-30 | 2019/981 → 2026/269 | FALSE | NA |
| donnees_ln II-4 nettes, réassurance NP déclarée présente (TRUE) | 0,064 | 2026-12-31 → 2027-01-30 | 2019/981 → 2026/269 | TRUE | NA |
| donnees_ln II-5 nettes, réassurance NP déclarée absente (FALSE) | 0,112 → 0,14 | 2026-12-31 → 2027-01-30 | 2019/981 → 2026/269 | FALSE | NA |
| donnees_ln II-5 nettes, réassurance NP déclarée présente (TRUE) | 0,112 | 2026-12-31 → 2027-01-30 | 2019/981 → 2026/269 | TRUE | NA |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée absente (FALSE) | 0,08 → 0,1 | 2026-12-31 → 2027-01-30 | 2019/981 → 2026/269 | FALSE | NA |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée présente (TRUE) | 0,08 | 2026-12-31 → 2027-01-30 | 2019/981 → 2026/269 | TRUE | NA |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée absente (FALSE) | 0,064 → 0,08 | 2026-12-31 → 2027-01-30 | 2019/981 → 2026/269 | FALSE | NA |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée présente (TRUE) | 0,064 | 2026-12-31 → 2027-01-30 | 2019/981 → 2026/269 | TRUE | NA |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée absente (FALSE) | 0,112 → 0,14 | 2026-12-31 → 2027-01-30 | 2019/981 → 2026/269 | FALSE | NA |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée présente (TRUE) | 0,112 | 2026-12-31 → 2027-01-30 | 2019/981 → 2026/269 | TRUE | NA |
| donnees_ln II-1 brutes, sans déclaration (témoin) | 0,1 | 2026-12-31 → 2027-01-30 | 2019/981 → 2026/269 | NA | NA |
| donnees_ln_interieur II-1 brutes, sans déclaration (témoin) | 0,1 | 2026-12-31 → 2027-01-30 | 2019/981 → 2026/269 | NA | NA |
| donnees_ln II-6 nettes, réassurance NP déclarée absente (FALSE) (témoin) | 0,19 | 2026-12-31 → 2027-01-30 | 2019/981 → 2026/269 | FALSE | NA |
| donnees_ln XIV-1 nettes, réassurance NP déclarée absente (FALSE) (témoin) | 0,05 | 2026-12-31 → 2027-01-30 | 2019/981 → 2026/269 | FALSE | NA |
| reserve1 (donnees_ln, II-1), CDD qualifiante déclarée absente (FALSE) (témoin) | 0,09 | 2026-12-31 → 2027-01-30 | 2019/981 → 2026/269 | NA | FALSE |
| reserve2 (triangle_mw, II-1), CDD qualifiante déclarée absente (FALSE) (témoin) | 0,09 | 2026-12-31 → 2027-01-30 | 2019/981 → 2026/269 | NA | FALSE |

`NA` : déclaration non fournie (« non déclarée »). La déclaration est la même dans les deux appels : seuls la date, le texte et, sans NP, le σ standard changent.

Identité de la ligne (c) du plan, sur les deux jeux : à 2027-01-30, II-1 nettes sans NP `identical()` à II-1 brutes (témoin), hors `metadata$nature_donnees` et `metadata$reassurance_np` :

- donnees_ln : **identical**
- donnees_ln_interieur : **identical**

## 2. Synthèse par champ (feuilles non `identical()` entre avant et après)

Champs du § 3.1 de l'avis d'`actuary` ; « autres » = tous les autres champs de l'objet. Écart max : relatif (\|avant\| > 1e-6) ou absolu.

| Cas | Champ | Feuilles | Changées | Écart max | Feuille de l'écart max |
|---|---|---|---|---|---|
| donnees_ln II-1 nettes, réassurance NP déclarée absente (FALSE) | `parametre_final` | 7 | 3 | 0,606 | `variation_relative` |
| donnees_ln II-1 nettes, réassurance NP déclarée absente (FALSE) | `candidats` | 9 | 2 | 0,25 | `valeur[1]` |
| donnees_ln II-1 nettes, réassurance NP déclarée absente (FALSE) | `calibration` | 18 | 2 | 0,25 | `valeur[8]` |
| donnees_ln II-1 nettes, réassurance NP déclarée absente (FALSE) | `ic_bootstrap` | 5 | 5 | 0,1302 | `["2.5%"]` |
| donnees_ln II-1 nettes, réassurance NP déclarée absente (FALSE) | `ic_bootstrap_restreint` | 5 | 5 | 0,1296 | `["2.5%"]` |
| donnees_ln II-1 nettes, réassurance NP déclarée absente (FALSE) | `ic_bootstrap_basic_log` | 4 | 4 | 0,09983 | `["bas_95"]` |
| donnees_ln II-1 nettes, réassurance NP déclarée absente (FALSE) | `jackknife` | 40 | 8 | 0,08836 | `sigma_usp[8]` |
| donnees_ln II-1 nettes, réassurance NP déclarée absente (FALSE) | `ajustement` | 74 | 3 | 0,07357 | `largeur_ic_restreint` |
| donnees_ln II-1 nettes, réassurance NP déclarée absente (FALSE) | `plots_data` | 9894 | 1023 | 0,25 | `boot_reperes$sigma_standard` |
| donnees_ln II-1 nettes, réassurance NP déclarée absente (FALSE) | `metadata` | 27 | 3 | 0,25 | `sigma_standard` |
| donnees_ln II-1 nettes, réassurance NP déclarée absente (FALSE) | `tests` | 1431 | 3 | 0,07357 | `[[46]]$estim` |
| donnees_ln II-1 nettes, réassurance NP déclarée absente (FALSE) | `autres` | 45508 | 0 | — | — |
| donnees_ln II-1 nettes, réassurance NP déclarée présente (TRUE) | `metadata` | 27 | 2 | non numérique | `date_reference`, `texte_applicable` |
| donnees_ln II-4 nettes, réassurance NP déclarée absente (FALSE) | `parametre_final` | 7 | 3 | 0,431 | `variation_relative` |
| donnees_ln II-4 nettes, réassurance NP déclarée absente (FALSE) | `candidats` | 9 | 2 | 0,25 | `valeur[1]` |
| donnees_ln II-4 nettes, réassurance NP déclarée absente (FALSE) | `calibration` | 18 | 2 | 0,25 | `valeur[8]` |
| donnees_ln II-4 nettes, réassurance NP déclarée absente (FALSE) | `ic_bootstrap` | 5 | 5 | 0,05669 | `["2.5%"]` |
| donnees_ln II-4 nettes, réassurance NP déclarée absente (FALSE) | `ic_bootstrap_restreint` | 5 | 5 | 0,05633 | `["2.5%"]` |
| donnees_ln II-4 nettes, réassurance NP déclarée absente (FALSE) | `ic_bootstrap_basic_log` | 4 | 4 | 0,03805 | `["bas_95"]` |
| donnees_ln II-4 nettes, réassurance NP déclarée absente (FALSE) | `jackknife` | 40 | 8 | 0,03216 | `sigma_usp[8]` |
| donnees_ln II-4 nettes, réassurance NP déclarée absente (FALSE) | `ajustement` | 74 | 3 | 0,02716 | `ecart_jackknife` |
| donnees_ln II-4 nettes, réassurance NP déclarée absente (FALSE) | `plots_data` | 9894 | 1022 | 0,25 | `boot_reperes$sigma_standard` |
| donnees_ln II-4 nettes, réassurance NP déclarée absente (FALSE) | `metadata` | 27 | 3 | 0,25 | `sigma_standard` |
| donnees_ln II-4 nettes, réassurance NP déclarée absente (FALSE) | `tests` | 1431 | 3 | 0,02716 | `[[44]]$estim` |
| donnees_ln II-4 nettes, réassurance NP déclarée absente (FALSE) | `autres` | 45508 | 0 | — | — |
| donnees_ln II-4 nettes, réassurance NP déclarée présente (TRUE) | `metadata` | 27 | 2 | non numérique | `date_reference`, `texte_applicable` |
| donnees_ln II-5 nettes, réassurance NP déclarée absente (FALSE) | `parametre_final` | 7 | 3 | 3,223 | `variation_relative` |
| donnees_ln II-5 nettes, réassurance NP déclarée absente (FALSE) | `candidats` | 9 | 2 | 0,25 | `valeur[1]` |
| donnees_ln II-5 nettes, réassurance NP déclarée absente (FALSE) | `calibration` | 18 | 2 | 0,25 | `valeur[8]` |
| donnees_ln II-5 nettes, réassurance NP déclarée absente (FALSE) | `ic_bootstrap` | 5 | 5 | 0,1508 | `["2.5%"]` |
| donnees_ln II-5 nettes, réassurance NP déclarée absente (FALSE) | `ic_bootstrap_restreint` | 5 | 5 | 0,1503 | `["2.5%"]` |
| donnees_ln II-5 nettes, réassurance NP déclarée absente (FALSE) | `ic_bootstrap_basic_log` | 4 | 4 | 0,1205 | `["bas_95"]` |
| donnees_ln II-5 nettes, réassurance NP déclarée absente (FALSE) | `jackknife` | 40 | 8 | 0,1084 | `sigma_usp[8]` |
| donnees_ln II-5 nettes, réassurance NP déclarée absente (FALSE) | `ajustement` | 74 | 3 | 0,08979 | `largeur_ic_restreint` |
| donnees_ln II-5 nettes, réassurance NP déclarée absente (FALSE) | `plots_data` | 9894 | 1022 | 0,25 | `boot_reperes$sigma_standard` |
| donnees_ln II-5 nettes, réassurance NP déclarée absente (FALSE) | `metadata` | 27 | 3 | 0,25 | `sigma_standard` |
| donnees_ln II-5 nettes, réassurance NP déclarée absente (FALSE) | `tests` | 1431 | 3 | 0,08979 | `[[46]]$estim` |
| donnees_ln II-5 nettes, réassurance NP déclarée absente (FALSE) | `autres` | 45508 | 0 | — | — |
| donnees_ln II-5 nettes, réassurance NP déclarée présente (TRUE) | `metadata` | 27 | 2 | non numérique | `date_reference`, `texte_applicable` |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée absente (FALSE) | `parametre_final` | 7 | 3 | 8,63 | `variation_relative` |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée absente (FALSE) | `candidats` | 9 | 2 | 0,25 | `valeur[1]` |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée absente (FALSE) | `calibration` | 18 | 2 | 0,25 | `valeur[8]` |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée absente (FALSE) | `ic_bootstrap` | 5 | 5 | 0,1577 | `["2.5%"]` |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée absente (FALSE) | `ic_bootstrap_restreint` | 5 | 5 | 0,1545 | `["2.5%"]` |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée absente (FALSE) | `ic_bootstrap_basic_log` | 4 | 4 | 0,1246 | `["bas_95"]` |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée absente (FALSE) | `jackknife` | 40 | 8 | 0,1272 | `sigma_usp[3]` |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée absente (FALSE) | `ajustement` | 74 | 3 | 0,09411 | `largeur_ic` |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée absente (FALSE) | `plots_data` | 9894 | 1022 | 0,25 | `boot_reperes$sigma_standard` |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée absente (FALSE) | `metadata` | 27 | 3 | 0,25 | `sigma_standard` |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée absente (FALSE) | `tests` | 1431 | 3 | 0,09411 | `[[45]]$estim` |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée absente (FALSE) | `autres` | 45508 | 0 | — | — |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée présente (TRUE) | `metadata` | 27 | 2 | non numérique | `date_reference`, `texte_applicable` |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée absente (FALSE) | `parametre_final` | 7 | 3 | 1,102 | `variation_relative` |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée absente (FALSE) | `candidats` | 9 | 2 | 0,25 | `valeur[1]` |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée absente (FALSE) | `calibration` | 18 | 2 | 0,25 | `valeur[8]` |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée absente (FALSE) | `ic_bootstrap` | 5 | 5 | 0,07893 | `["2.5%"]` |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée absente (FALSE) | `ic_bootstrap_restreint` | 5 | 5 | 0,07601 | `["2.5%"]` |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée absente (FALSE) | `ic_bootstrap_basic_log` | 4 | 4 | 0,0529 | `["bas_95"]` |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée absente (FALSE) | `jackknife` | 40 | 8 | 0,05467 | `sigma_usp[3]` |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée absente (FALSE) | `ajustement` | 74 | 3 | 0,03871 | `ecart_jackknife` |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée absente (FALSE) | `plots_data` | 9894 | 1022 | 0,25 | `boot_reperes$sigma_standard` |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée absente (FALSE) | `metadata` | 27 | 3 | 0,25 | `sigma_standard` |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée absente (FALSE) | `tests` | 1431 | 3 | 0,03871 | `[[44]]$estim` |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée absente (FALSE) | `autres` | 45508 | 0 | — | — |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée présente (TRUE) | `metadata` | 27 | 2 | non numérique | `date_reference`, `texte_applicable` |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée absente (FALSE) | `parametre_final` | 7 | 3 | 0,4625 | `variation_relative` |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée absente (FALSE) | `candidats` | 9 | 2 | 0,25 | `valeur[1]` |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée absente (FALSE) | `calibration` | 18 | 2 | 0,25 | `valeur[8]` |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée absente (FALSE) | `ic_bootstrap` | 5 | 5 | 0,1763 | `["2.5%"]` |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée absente (FALSE) | `ic_bootstrap_restreint` | 5 | 5 | 0,1734 | `["2.5%"]` |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée absente (FALSE) | `ic_bootstrap_basic_log` | 4 | 4 | 0,1455 | `["bas_95"]` |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée absente (FALSE) | `jackknife` | 40 | 8 | 0,148 | `sigma_usp[3]` |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée absente (FALSE) | `ajustement` | 74 | 3 | 0,1109 | `largeur_ic_restreint` |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée absente (FALSE) | `plots_data` | 9894 | 1022 | 0,25 | `boot_reperes$sigma_standard` |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée absente (FALSE) | `metadata` | 27 | 3 | 0,25 | `sigma_standard` |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée absente (FALSE) | `tests` | 1431 | 3 | 0,1109 | `[[46]]$estim` |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée absente (FALSE) | `autres` | 45508 | 0 | — | — |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée présente (TRUE) | `metadata` | 27 | 2 | non numérique | `date_reference`, `texte_applicable` |
| donnees_ln II-1 brutes, sans déclaration (témoin) | `metadata` | 27 | 2 | non numérique | `date_reference`, `texte_applicable` |
| donnees_ln_interieur II-1 brutes, sans déclaration (témoin) | `metadata` | 27 | 2 | non numérique | `date_reference`, `texte_applicable` |
| donnees_ln II-6 nettes, réassurance NP déclarée absente (FALSE) (témoin) | `metadata` | 27 | 2 | non numérique | `date_reference`, `texte_applicable` |
| donnees_ln XIV-1 nettes, réassurance NP déclarée absente (FALSE) (témoin) | `metadata` | 27 | 2 | non numérique | `date_reference`, `texte_applicable` |
| reserve1 (donnees_ln, II-1), CDD qualifiante déclarée absente (FALSE) (témoin) | `metadata` | 26 | 2 | non numérique | `date_reference`, `texte_applicable` |
| reserve2 (triangle_mw, II-1), CDD qualifiante déclarée absente (FALSE) (témoin) | `metadata` | 23 | 2 | non numérique | `date_reference`, `texte_applicable` |

Cas « avec NP » et témoins : seules les lignes non vides sont listées, plus `metadata` ; tout autre champ a 0 feuille changée (contrôle : 0 feuille changée hors `metadata` sur ces 12 cas).

## 3. Détail feuille par feuille, cas « sans NP » (hors `plots_data`, résumé au § 2 et ci-dessous)

### donnees_ln II-1 nettes, réassurance NP déclarée absente (FALSE)

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `parametre_final$sigma_standard` | 0,08 | 0,1 | 0,25 | relatif |
| `parametre_final$sigma_usp` | 0,1032524114 | 0,1114524114 | 0,07942 | relatif |
| `parametre_final$variation_relative` | 0,2906551428 | 0,1145241142 | 0,606 | relatif |
| `candidats$valeur[1]` | 0,08 | 0,1 | 0,25 | relatif |
| `candidats$valeur[3]` | 0,1032524114 | 0,1114524114 | 0,07942 | relatif |
| `calibration$valeur[8]` | 0,08 | 0,1 | 0,25 | relatif |
| `calibration$valeur[9]` | 0,1032524114 | 0,1114524114 | 0,07942 | relatif |
| `ic_bootstrap["2.5%"]` | 0,0630008087 | 0,0712008087 | 0,1302 | relatif |
| `ic_bootstrap["5%"]` | 0,06702022109 | 0,07522022109 | 0,1224 | relatif |
| `ic_bootstrap["50%"]` | 0,09440068843 | 0,1026006884 | 0,08686 | relatif |
| `ic_bootstrap["95%"]` | 0,1287770802 | 0,1369770802 | 0,06368 | relatif |
| `ic_bootstrap["97.5%"]` | 0,1333966698 | 0,1415966698 | 0,06147 | relatif |
| `ic_bootstrap_restreint["2.5%"]` | 0,06325190976 | 0,07145190976 | 0,1296 | relatif |
| `ic_bootstrap_restreint["5%"]` | 0,06749400367 | 0,07569400367 | 0,1215 | relatif |
| `ic_bootstrap_restreint["50%"]` | 0,09469892005 | 0,10289892 | 0,08659 | relatif |
| `ic_bootstrap_restreint["95%"]` | 0,1294009876 | 0,1376009876 | 0,06337 | relatif |
| `ic_bootstrap_restreint["97.5%"]` | 0,1338537821 | 0,1420537821 | 0,06126 | relatif |
| `ic_bootstrap_basic_log["bas_95"]` | 0,0821410198 | 0,0903410198 | 0,09983 | relatif |
| `ic_bootstrap_basic_log["bas_90"]` | 0,08451591243 | 0,09271591243 | 0,09702 | relatif |
| `ic_bootstrap_basic_log["haut_90"]` | 0,1778470546 | 0,1860470546 | 0,04611 | relatif |
| `ic_bootstrap_basic_log["haut_95"]` | 0,1971513034 | 0,2053513034 | 0,04159 | relatif |
| `jackknife$sigma_usp[1]` | 0,1071788679 | 0,1153788679 | 0,07651 | relatif |
| `jackknife$sigma_usp[2]` | 0,1074195265 | 0,1156195265 | 0,07634 | relatif |
| `jackknife$sigma_usp[3]` | 0,1067922988 | 0,1149922988 | 0,07678 | relatif |
| `jackknife$sigma_usp[4]` | 0,1011683175 | 0,1093683175 | 0,08105 | relatif |
| `jackknife$sigma_usp[5]` | 0,1073944617 | 0,1155944617 | 0,07635 | relatif |
| `jackknife$sigma_usp[6]` | 0,09602189558 | 0,1042218956 | 0,0854 | relatif |
| `jackknife$sigma_usp[7]` | 0,09959356394 | 0,1077935639 | 0,08233 | relatif |
| `jackknife$sigma_usp[8]` | 0,09280219437 | 0,1010021944 | 0,08836 | relatif |
| `ajustement$ecart_jackknife` | 0,1012103921 | 0,09376393849 | 0,07357 | relatif |
| `ajustement$largeur_ic` | 0,598115417 | 0,5541096718 | 0,07357 | relatif |
| `ajustement$largeur_ic_restreint` | 0,5995693763 | 0,5554566574 | 0,07357 | relatif |
| `metadata$sigma_standard` | 0,08 | 0,1 | 0,25 | relatif |
| `metadata$date_reference` | 2026-12-31 | 2027-01-30 |  | non numerique |
| `metadata$texte_applicable` | 2019/981 | 2026/269 |  | non numerique |
| `tests[[44]]$estim` | 0,1012103921 | 0,09376393849 | 0,07357 | relatif |
| `tests[[45]]$estim` | 0,598115417 | 0,5541096718 | 0,07357 | relatif |
| `tests[[46]]$estim` | 0,5995693763 | 0,5554566574 | 0,07357 | relatif |

`plots_data` : 1023 feuille(s) changée(s) sur 9894, écart max 0,25 (relatif, `plots_data$boot_reperes$sigma_standard`) ; par élément : `boot_reperes` 7, `influence` 17, `sigma_usp_boot` 999.

### donnees_ln II-4 nettes, réassurance NP déclarée absente (FALSE)

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `parametre_final$sigma_standard` | 0,064 | 0,08 | 0,25 | relatif |
| `parametre_final$sigma_usp` | 0,1088828021 | 0,1119228021 | 0,02792 | relatif |
| `parametre_final$variation_relative` | 0,7012937832 | 0,3990350265 | 0,431 | relatif |
| `candidats$valeur[1]` | 0,064 | 0,08 | 0,25 | relatif |
| `candidats$valeur[3]` | 0,1088828021 | 0,1119228021 | 0,02792 | relatif |
| `calibration$valeur[8]` | 0,064 | 0,08 | 0,25 | relatif |
| `calibration$valeur[9]` | 0,1088828021 | 0,1119228021 | 0,02792 | relatif |
| `ic_bootstrap["2.5%"]` | 0,0536221272 | 0,0566621272 | 0,05669 | relatif |
| `ic_bootstrap["5%"]` | 0,05914030353 | 0,06218030353 | 0,0514 | relatif |
| `ic_bootstrap["50%"]` | 0,09673043666 | 0,09977043666 | 0,03143 | relatif |
| `ic_bootstrap["95%"]` | 0,143925144 | 0,146965144 | 0,02112 | relatif |
| `ic_bootstrap["97.5%"]` | 0,1502672924 | 0,1533072924 | 0,02023 | relatif |
| `ic_bootstrap_restreint["2.5%"]` | 0,05396685916 | 0,05700685916 | 0,05633 | relatif |
| `ic_bootstrap_restreint["5%"]` | 0,0597907508 | 0,0628307508 | 0,05084 | relatif |
| `ic_bootstrap_restreint["50%"]` | 0,09713987329 | 0,1001798733 | 0,0313 | relatif |
| `ic_bootstrap_restreint["95%"]` | 0,1447816948 | 0,1478216948 | 0,021 | relatif |
| `ic_bootstrap_restreint["97.5%"]` | 0,1508948535 | 0,1539348535 | 0,02015 | relatif |
| `ic_bootstrap_basic_log["bas_95"]` | 0,07989936617 | 0,08293936617 | 0,03805 | relatif |
| `ic_bootstrap_basic_log["bas_90"]` | 0,08315981198 | 0,08619981198 | 0,03656 | relatif |
| `ic_bootstrap_basic_log["haut_90"]` | 0,2112923969 | 0,2143323969 | 0,01439 | relatif |
| `ic_bootstrap_basic_log["haut_95"]` | 0,2377948403 | 0,2408348403 | 0,01278 | relatif |
| `jackknife$sigma_usp[1]` | 0,114273361 | 0,117313361 | 0,0266 | relatif |
| `jackknife$sigma_usp[2]` | 0,1146037567 | 0,1176437567 | 0,02653 | relatif |
| `jackknife$sigma_usp[3]` | 0,1137426475 | 0,1167826475 | 0,02673 | relatif |
| `jackknife$sigma_usp[4]` | 0,1060215885 | 0,1090615885 | 0,02867 | relatif |
| `jackknife$sigma_usp[5]` | 0,1145693457 | 0,1176093457 | 0,02653 | relatif |
| `jackknife$sigma_usp[6]` | 0,09895616172 | 0,1019961617 | 0,03072 | relatif |
| `jackknife$sigma_usp[7]` | 0,1038596386 | 0,1068996386 | 0,02927 | relatif |
| `jackknife$sigma_usp[8]` | 0,09453589397 | 0,09757589397 | 0,03216 | relatif |
| `ajustement$ecart_jackknife` | 0,1317646853 | 0,1281857484 | 0,02716 | relatif |
| `ajustement$largeur_ic` | 0,7786798175 | 0,7575296443 | 0,02716 | relatif |
| `ajustement$largeur_ic_restreint` | 0,7805727108 | 0,7593711237 | 0,02716 | relatif |
| `metadata$sigma_standard` | 0,064 | 0,08 | 0,25 | relatif |
| `metadata$date_reference` | 2026-12-31 | 2027-01-30 |  | non numerique |
| `metadata$texte_applicable` | 2019/981 | 2026/269 |  | non numerique |
| `tests[[44]]$estim` | 0,1317646853 | 0,1281857484 | 0,02716 | relatif |
| `tests[[45]]$estim` | 0,7786798175 | 0,7575296443 | 0,02716 | relatif |
| `tests[[46]]$estim` | 0,7805727108 | 0,7593711237 | 0,02716 | relatif |

`plots_data` : 1022 feuille(s) changée(s) sur 9894, écart max 0,25 (relatif, `plots_data$boot_reperes$sigma_standard`) ; par élément : `boot_reperes` 7, `influence` 16, `sigma_usp_boot` 999.

### donnees_ln II-5 nettes, réassurance NP déclarée absente (FALSE)

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `parametre_final$sigma_standard` | 0,112 | 0,14 | 0,25 | relatif |
| `parametre_final$sigma_usp` | 0,1163724114 | 0,1278524114 | 0,09865 | relatif |
| `parametre_final$variation_relative` | 0,0390393877 | -0,08676848984 | 3,223 | relatif |
| `candidats$valeur[1]` | 0,112 | 0,14 | 0,25 | relatif |
| `candidats$valeur[3]` | 0,1163724114 | 0,1278524114 | 0,09865 | relatif |
| `calibration$valeur[8]` | 0,112 | 0,14 | 0,25 | relatif |
| `calibration$valeur[9]` | 0,1163724114 | 0,1278524114 | 0,09865 | relatif |
| `ic_bootstrap["2.5%"]` | 0,0761208087 | 0,0876008087 | 0,1508 | relatif |
| `ic_bootstrap["5%"]` | 0,08014022109 | 0,09162022109 | 0,1432 | relatif |
| `ic_bootstrap["50%"]` | 0,1075206884 | 0,1190006884 | 0,1068 | relatif |
| `ic_bootstrap["95%"]` | 0,1418970802 | 0,1533770802 | 0,0809 | relatif |
| `ic_bootstrap["97.5%"]` | 0,1465166698 | 0,1579966698 | 0,07835 | relatif |
| `ic_bootstrap_restreint["2.5%"]` | 0,07637190976 | 0,08785190976 | 0,1503 | relatif |
| `ic_bootstrap_restreint["5%"]` | 0,08061400367 | 0,09209400367 | 0,1424 | relatif |
| `ic_bootstrap_restreint["50%"]` | 0,10781892 | 0,11929892 | 0,1065 | relatif |
| `ic_bootstrap_restreint["95%"]` | 0,1425209876 | 0,1540009876 | 0,08055 | relatif |
| `ic_bootstrap_restreint["97.5%"]` | 0,1469737821 | 0,1584537821 | 0,07811 | relatif |
| `ic_bootstrap_basic_log["bas_95"]` | 0,0952610198 | 0,1067410198 | 0,1205 | relatif |
| `ic_bootstrap_basic_log["bas_90"]` | 0,09763591243 | 0,1091159124 | 0,1176 | relatif |
| `ic_bootstrap_basic_log["haut_90"]` | 0,1909670546 | 0,2024470546 | 0,06012 | relatif |
| `ic_bootstrap_basic_log["haut_95"]` | 0,2102713034 | 0,2217513034 | 0,0546 | relatif |
| `jackknife$sigma_usp[1]` | 0,1202988679 | 0,1317788679 | 0,09543 | relatif |
| `jackknife$sigma_usp[2]` | 0,1205395265 | 0,1320195265 | 0,09524 | relatif |
| `jackknife$sigma_usp[3]` | 0,1199122988 | 0,1313922988 | 0,09574 | relatif |
| `jackknife$sigma_usp[4]` | 0,1142883175 | 0,1257683175 | 0,1004 | relatif |
| `jackknife$sigma_usp[5]` | 0,1205144617 | 0,1319944617 | 0,09526 | relatif |
| `jackknife$sigma_usp[6]` | 0,1091418956 | 0,1206218956 | 0,1052 | relatif |
| `jackknife$sigma_usp[7]` | 0,1127135639 | 0,1241935639 | 0,1019 | relatif |
| `jackknife$sigma_usp[8]` | 0,1059221944 | 0,1174021944 | 0,1084 | relatif |
| `ajustement$ecart_jackknife` | 0,0897997809 | 0,08173656588 | 0,08979 | relatif |
| `ajustement$largeur_ic` | 0,5306829889 | 0,4830324155 | 0,08979 | relatif |
| `ajustement$largeur_ic_restreint` | 0,5319730266 | 0,4842066194 | 0,08979 | relatif |
| `metadata$sigma_standard` | 0,112 | 0,14 | 0,25 | relatif |
| `metadata$date_reference` | 2026-12-31 | 2027-01-30 |  | non numerique |
| `metadata$texte_applicable` | 2019/981 | 2026/269 |  | non numerique |
| `tests[[44]]$estim` | 0,0897997809 | 0,08173656588 | 0,08979 | relatif |
| `tests[[45]]$estim` | 0,5306829889 | 0,4830324155 | 0,08979 | relatif |
| `tests[[46]]$estim` | 0,5319730266 | 0,4842066194 | 0,08979 | relatif |

`plots_data` : 1022 feuille(s) changée(s) sur 9894, écart max 0,25 (relatif, `plots_data$boot_reperes$sigma_standard`) ; par élément : `boot_reperes` 7, `influence` 16, `sigma_usp_boot` 999.

### donnees_ln_interieur II-1 nettes, réassurance NP déclarée absente (FALSE)

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `parametre_final$sigma_standard` | 0,08 | 0,1 | 0,25 | relatif |
| `parametre_final$sigma_usp` | 0,07893086786 | 0,08713086786 | 0,1039 | relatif |
| `parametre_final$variation_relative` | -0,01336415178 | -0,1286913214 | 8,63 | relatif |
| `candidats$valeur[1]` | 0,08 | 0,1 | 0,25 | relatif |
| `candidats$valeur[3]` | 0,07893086786 | 0,08713086786 | 0,1039 | relatif |
| `calibration$valeur[8]` | 0,08 | 0,1 | 0,25 | relatif |
| `calibration$valeur[9]` | 0,07893086786 | 0,08713086786 | 0,1039 | relatif |
| `ic_bootstrap["2.5%"]` | 0,0519974042 | 0,0601974042 | 0,1577 | relatif |
| `ic_bootstrap["5%"]` | 0,05507801359 | 0,06327801359 | 0,1489 | relatif |
| `ic_bootstrap["50%"]` | 0,07194006208 | 0,08014006208 | 0,114 | relatif |
| `ic_bootstrap["95%"]` | 0,0929489204 | 0,1011489204 | 0,08822 | relatif |
| `ic_bootstrap["97.5%"]` | 0,09728148939 | 0,1054814894 | 0,08429 | relatif |
| `ic_bootstrap_restreint["2.5%"]` | 0,05307471323 | 0,06127471323 | 0,1545 | relatif |
| `ic_bootstrap_restreint["5%"]` | 0,05596860706 | 0,06416860706 | 0,1465 | relatif |
| `ic_bootstrap_restreint["50%"]` | 0,07364045144 | 0,08184045144 | 0,1114 | relatif |
| `ic_bootstrap_restreint["95%"]` | 0,09544918246 | 0,1036491825 | 0,08591 | relatif |
| `ic_bootstrap_restreint["97.5%"]` | 0,09862354668 | 0,1068235467 | 0,08314 | relatif |
| `ic_bootstrap_basic_log["bas_95"]` | 0,0658026026 | 0,0740026026 | 0,1246 | relatif |
| `ic_bootstrap_basic_log["bas_90"]` | 0,06817980324 | 0,07637980324 | 0,1203 | relatif |
| `ic_bootstrap_basic_log["haut_90"]` | 0,1283227431 | 0,1365227431 | 0,0639 | relatif |
| `ic_bootstrap_basic_log["haut_95"]` | 0,1436512873 | 0,1518512873 | 0,05708 | relatif |
| `jackknife$sigma_usp[1]` | 0,07706326117 | 0,08526326117 | 0,1064 | relatif |
| `jackknife$sigma_usp[2]` | 0,07909041505 | 0,08729041505 | 0,1037 | relatif |
| `jackknife$sigma_usp[3]` | 0,06444746508 | 0,07264746508 | 0,1272 | relatif |
| `jackknife$sigma_usp[4]` | 0,07289126981 | 0,08109126981 | 0,1125 | relatif |
| `jackknife$sigma_usp[5]` | 0,08477271497 | 0,09297271497 | 0,09673 | relatif |
| `jackknife$sigma_usp[6]` | 0,08347671543 | 0,09167671543 | 0,09823 | relatif |
| `jackknife$sigma_usp[7]` | 0,07870898495 | 0,08690898495 | 0,1042 | relatif |
| `jackknife$sigma_usp[8]` | 0,07867711777 | 0,08687711777 | 0,1042 | relatif |
| `ajustement$ecart_jackknife` | 0,1834947869 | 0,1662258524 | 0,09411 | relatif |
| `ajustement$largeur_ic` | 0,4797984342 | 0,4346439757 | 0,09411 | relatif |
| `ajustement$largeur_ic_restreint` | 0,5001918321 | 0,4531181242 | 0,09411 | relatif |
| `metadata$sigma_standard` | 0,08 | 0,1 | 0,25 | relatif |
| `metadata$date_reference` | 2026-12-31 | 2027-01-30 |  | non numerique |
| `metadata$texte_applicable` | 2019/981 | 2026/269 |  | non numerique |
| `tests[[44]]$estim` | 0,1834947869 | 0,1662258524 | 0,09411 | relatif |
| `tests[[45]]$estim` | 0,4797984342 | 0,4346439757 | 0,09411 | relatif |
| `tests[[46]]$estim` | 0,5001918321 | 0,4531181242 | 0,09411 | relatif |

`plots_data` : 1022 feuille(s) changée(s) sur 9894, écart max 0,25 (relatif, `plots_data$boot_reperes$sigma_standard`) ; par élément : `boot_reperes` 7, `influence` 16, `sigma_usp_boot` 999.

### donnees_ln_interieur II-4 nettes, réassurance NP déclarée absente (FALSE)

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `parametre_final$sigma_standard` | 0,064 | 0,08 | 0,25 | relatif |
| `parametre_final$sigma_usp` | 0,07549220841 | 0,07853220841 | 0,04027 | relatif |
| `parametre_final$variation_relative` | 0,1795657565 | -0,01834739482 | 1,102 | relatif |
| `candidats$valeur[1]` | 0,064 | 0,08 | 0,25 | relatif |
| `candidats$valeur[3]` | 0,07549220841 | 0,07853220841 | 0,04027 | relatif |
| `calibration$valeur[8]` | 0,064 | 0,08 | 0,25 | relatif |
| `calibration$valeur[9]` | 0,07549220841 | 0,07853220841 | 0,04027 | relatif |
| `ic_bootstrap["2.5%"]` | 0,03851575831 | 0,04155575831 | 0,07893 | relatif |
| `ic_bootstrap["5%"]` | 0,04274506951 | 0,04578506951 | 0,07112 | relatif |
| `ic_bootstrap["50%"]` | 0,0658946615 | 0,0689346615 | 0,04613 | relatif |
| `ic_bootstrap["95%"]` | 0,0947373314 | 0,0977773314 | 0,03209 | relatif |
| `ic_bootstrap["97.5%"]` | 0,1006854346 | 0,1037254346 | 0,03019 | relatif |
| `ic_bootstrap_restreint["2.5%"]` | 0,03999477578 | 0,04303477578 | 0,07601 | relatif |
| `ic_bootstrap_restreint["5%"]` | 0,04396774867 | 0,04700774867 | 0,06914 | relatif |
| `ic_bootstrap_restreint["50%"]` | 0,06822909434 | 0,07126909434 | 0,04456 | relatif |
| `ic_bootstrap_restreint["95%"]` | 0,09816989456 | 0,1012098946 | 0,03097 | relatif |
| `ic_bootstrap_restreint["97.5%"]` | 0,10252792 | 0,10556792 | 0,02965 | relatif |
| `ic_bootstrap_basic_log["bas_95"]` | 0,0574686578 | 0,0605086578 | 0,0529 | relatif |
| `ic_bootstrap_basic_log["bas_90"]` | 0,06073227225 | 0,06377227225 | 0,05006 | relatif |
| `ic_bootstrap_basic_log["haut_90"]` | 0,1433013931 | 0,1463413931 | 0,02121 | relatif |
| `ic_bootstrap_basic_log["haut_95"]` | 0,1643456656 | 0,1673856656 | 0,0185 | relatif |
| `jackknife$sigma_usp[1]` | 0,07292820601 | 0,07596820601 | 0,04168 | relatif |
| `jackknife$sigma_usp[2]` | 0,07571124778 | 0,07875124778 | 0,04015 | relatif |
| `jackknife$sigma_usp[3]` | 0,05560821477 | 0,05864821477 | 0,05467 | relatif |
| `jackknife$sigma_usp[4]` | 0,06720055686 | 0,07024055686 | 0,04524 | relatif |
| `jackknife$sigma_usp[5]` | 0,0835123714 | 0,0865523714 | 0,0364 | relatif |
| `jackknife$sigma_usp[6]` | 0,08173311779 | 0,08477311779 | 0,03719 | relatif |
| `jackknife$sigma_usp[7]` | 0,0751875895 | 0,0782275895 | 0,04043 | relatif |
| `jackknife$sigma_usp[8]` | 0,07514383966 | 0,07818383966 | 0,04046 | relatif |
| `ajustement$ecart_jackknife` | 0,2633913361 | 0,2531953964 | 0,03871 | relatif |
| `ajustement$largeur_ic` | 0,6887103051 | 0,6620501695 | 0,03871 | relatif |
| `ajustement$largeur_ic_restreint` | 0,7179833128 | 0,6901900123 | 0,03871 | relatif |
| `metadata$sigma_standard` | 0,064 | 0,08 | 0,25 | relatif |
| `metadata$date_reference` | 2026-12-31 | 2027-01-30 |  | non numerique |
| `metadata$texte_applicable` | 2019/981 | 2026/269 |  | non numerique |
| `tests[[44]]$estim` | 0,2633913361 | 0,2531953964 | 0,03871 | relatif |
| `tests[[45]]$estim` | 0,6887103051 | 0,6620501695 | 0,03871 | relatif |
| `tests[[46]]$estim` | 0,7179833128 | 0,6901900123 | 0,03871 | relatif |

`plots_data` : 1022 feuille(s) changée(s) sur 9894, écart max 0,25 (relatif, `plots_data$boot_reperes$sigma_standard`) ; par élément : `boot_reperes` 7, `influence` 16, `sigma_usp_boot` 999.

### donnees_ln_interieur II-5 nettes, réassurance NP déclarée absente (FALSE)

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `parametre_final$sigma_standard` | 0,112 | 0,14 | 0,25 | relatif |
| `parametre_final$sigma_usp` | 0,09205086786 | 0,1035308679 | 0,1247 | relatif |
| `parametre_final$variation_relative` | -0,1781172513 | -0,260493801 | 0,4625 | relatif |
| `candidats$valeur[1]` | 0,112 | 0,14 | 0,25 | relatif |
| `candidats$valeur[3]` | 0,09205086786 | 0,1035308679 | 0,1247 | relatif |
| `calibration$valeur[8]` | 0,112 | 0,14 | 0,25 | relatif |
| `calibration$valeur[9]` | 0,09205086786 | 0,1035308679 | 0,1247 | relatif |
| `ic_bootstrap["2.5%"]` | 0,0651174042 | 0,0765974042 | 0,1763 | relatif |
| `ic_bootstrap["5%"]` | 0,06819801359 | 0,07967801359 | 0,1683 | relatif |
| `ic_bootstrap["50%"]` | 0,08506006208 | 0,09654006208 | 0,135 | relatif |
| `ic_bootstrap["95%"]` | 0,1060689204 | 0,1175489204 | 0,1082 | relatif |
| `ic_bootstrap["97.5%"]` | 0,1104014894 | 0,1218814894 | 0,104 | relatif |
| `ic_bootstrap_restreint["2.5%"]` | 0,06619471323 | 0,07767471323 | 0,1734 | relatif |
| `ic_bootstrap_restreint["5%"]` | 0,06908860706 | 0,08056860706 | 0,1662 | relatif |
| `ic_bootstrap_restreint["50%"]` | 0,08676045144 | 0,09824045144 | 0,1323 | relatif |
| `ic_bootstrap_restreint["95%"]` | 0,1085691825 | 0,1200491825 | 0,1057 | relatif |
| `ic_bootstrap_restreint["97.5%"]` | 0,1117435467 | 0,1232235467 | 0,1027 | relatif |
| `ic_bootstrap_basic_log["bas_95"]` | 0,0789226026 | 0,0904026026 | 0,1455 | relatif |
| `ic_bootstrap_basic_log["bas_90"]` | 0,08129980324 | 0,09277980324 | 0,1412 | relatif |
| `ic_bootstrap_basic_log["haut_90"]` | 0,1414427431 | 0,1529227431 | 0,08116 | relatif |
| `ic_bootstrap_basic_log["haut_95"]` | 0,1567712873 | 0,1682512873 | 0,07323 | relatif |
| `jackknife$sigma_usp[1]` | 0,09018326117 | 0,1016632612 | 0,1273 | relatif |
| `jackknife$sigma_usp[2]` | 0,09221041505 | 0,103690415 | 0,1245 | relatif |
| `jackknife$sigma_usp[3]` | 0,07756746508 | 0,08904746508 | 0,148 | relatif |
| `jackknife$sigma_usp[4]` | 0,08601126981 | 0,09749126981 | 0,1335 | relatif |
| `jackknife$sigma_usp[5]` | 0,09789271497 | 0,109372715 | 0,1173 | relatif |
| `jackknife$sigma_usp[6]` | 0,09659671543 | 0,1080767154 | 0,1188 | relatif |
| `jackknife$sigma_usp[7]` | 0,09182898495 | 0,1033089849 | 0,125 | relatif |
| `jackknife$sigma_usp[8]` | 0,09179711777 | 0,1032771178 | 0,1251 | relatif |
| `ajustement$ecart_jackknife` | 0,1573412952 | 0,1398945365 | 0,1109 | relatif |
| `ajustement$largeur_ic` | 0,4114128165 | 0,365793387 | 0,1109 | relatif |
| `ajustement$largeur_ic_restreint` | 0,4288995457 | 0,3813411036 | 0,1109 | relatif |
| `metadata$sigma_standard` | 0,112 | 0,14 | 0,25 | relatif |
| `metadata$date_reference` | 2026-12-31 | 2027-01-30 |  | non numerique |
| `metadata$texte_applicable` | 2019/981 | 2026/269 |  | non numerique |
| `tests[[44]]$estim` | 0,1573412952 | 0,1398945365 | 0,1109 | relatif |
| `tests[[45]]$estim` | 0,4114128165 | 0,365793387 | 0,1109 | relatif |
| `tests[[46]]$estim` | 0,4288995457 | 0,3813411036 | 0,1109 | relatif |

`plots_data` : 1022 feuille(s) changée(s) sur 9894, écart max 0,25 (relatif, `plots_data$boot_reperes$sigma_standard`) ; par élément : `boot_reperes` 7, `influence` 16, `sigma_usp_boot` 999.

## 4. Preuve de ce qui ne change pas (`identical()`)

| Cas | bootstrap | profil | lr_delta | controles | p-values et verdicts des 53 lignes de `tests` (p_exacte, p_asymptotique, p_mc, err_mc, p_retenue, p_min, p_min_mc, nature_p, verdict, inoperant) | lignes de `tests` changées | objet entier hors `metadata$date_reference` et `metadata$texte_applicable` |
|---|---|---|---|---|---|---|---|
| donnees_ln II-1 nettes, réassurance NP déclarée absente (FALSE) | identical | identical | identical | identical | identical | 44 (Sensibilite au retrait d'une annee (jackknife) ; INFO ; champs : estim) ; 45 (Largeur relative de l'IC bootstrap 90% ; INFO ; champs : estim) ; 46 (Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) ; INFO ; champs : estim) | non (champs du § 2) |
| donnees_ln II-1 nettes, réassurance NP déclarée présente (TRUE) | identical | identical | identical | identical | identical | aucune | identical |
| donnees_ln II-4 nettes, réassurance NP déclarée absente (FALSE) | identical | identical | identical | identical | identical | 44 (Sensibilite au retrait d'une annee (jackknife) ; INFO ; champs : estim) ; 45 (Largeur relative de l'IC bootstrap 90% ; INFO ; champs : estim) ; 46 (Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) ; INFO ; champs : estim) | non (champs du § 2) |
| donnees_ln II-4 nettes, réassurance NP déclarée présente (TRUE) | identical | identical | identical | identical | identical | aucune | identical |
| donnees_ln II-5 nettes, réassurance NP déclarée absente (FALSE) | identical | identical | identical | identical | identical | 44 (Sensibilite au retrait d'une annee (jackknife) ; INFO ; champs : estim) ; 45 (Largeur relative de l'IC bootstrap 90% ; INFO ; champs : estim) ; 46 (Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) ; INFO ; champs : estim) | non (champs du § 2) |
| donnees_ln II-5 nettes, réassurance NP déclarée présente (TRUE) | identical | identical | identical | identical | identical | aucune | identical |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée absente (FALSE) | identical | identical | identical | identical | identical | 44 (Sensibilite au retrait d'une annee (jackknife) ; INFO ; champs : estim) ; 45 (Largeur relative de l'IC bootstrap 90% ; INFO ; champs : estim) ; 46 (Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) ; INFO ; champs : estim) | non (champs du § 2) |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée présente (TRUE) | identical | identical | identical | identical | identical | aucune | identical |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée absente (FALSE) | identical | identical | identical | identical | identical | 44 (Sensibilite au retrait d'une annee (jackknife) ; INFO ; champs : estim) ; 45 (Largeur relative de l'IC bootstrap 90% ; INFO ; champs : estim) ; 46 (Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) ; INFO ; champs : estim) | non (champs du § 2) |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée présente (TRUE) | identical | identical | identical | identical | identical | aucune | identical |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée absente (FALSE) | identical | identical | identical | identical | identical | 44 (Sensibilite au retrait d'une annee (jackknife) ; INFO ; champs : estim) ; 45 (Largeur relative de l'IC bootstrap 90% ; INFO ; champs : estim) ; 46 (Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) ; INFO ; champs : estim) | non (champs du § 2) |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée présente (TRUE) | identical | identical | identical | identical | identical | aucune | identical |
| donnees_ln II-1 brutes, sans déclaration (témoin) | identical | identical | identical | identical | identical | aucune | identical |
| donnees_ln_interieur II-1 brutes, sans déclaration (témoin) | identical | identical | identical | identical | identical | aucune | identical |
| donnees_ln II-6 nettes, réassurance NP déclarée absente (FALSE) (témoin) | identical | identical | identical | identical | identical | aucune | identical |
| donnees_ln XIV-1 nettes, réassurance NP déclarée absente (FALSE) (témoin) | identical | identical | identical | identical | identical | aucune | identical |
| reserve1 (donnees_ln, II-1), CDD qualifiante déclarée absente (FALSE) (témoin) | identical | identical | identical | identical | identical | aucune | identical |
| reserve2 (triangle_mw, II-1), CDD qualifiante déclarée absente (FALSE) (témoin) | identical | identical | identical | identical | identical | aucune | identical |

Contrôle global (bootstrap, profil, lr_delta, controles, p-values et verdicts identical() partout ; lignes de `tests` changées toutes de la famille G au verdict INFO ; cas « avec NP » et témoins identical() hors date et texte) : **OK**.

## 5. Contrôle d'antériorité : l'appel « avant » est le résultat de l'outil d'avant S3

| Cas | avant (c) = tête `b7f40a7`, même appel (`identical()`, hors champs d'exécution) | avant (c) = outil d'avant S3 sans date ni déclaration (`identical()`, hors les quatre champs nouveaux de `metadata`) |
|---|---|---|
| donnees_ln II-1 nettes, réassurance NP déclarée absente (FALSE) | identical | identical |
| donnees_ln II-1 nettes, réassurance NP déclarée présente (TRUE) | identical | identical |
| donnees_ln II-4 nettes, réassurance NP déclarée absente (FALSE) | identical | identical |
| donnees_ln II-4 nettes, réassurance NP déclarée présente (TRUE) | identical | identical |
| donnees_ln II-5 nettes, réassurance NP déclarée absente (FALSE) | identical | identical |
| donnees_ln II-5 nettes, réassurance NP déclarée présente (TRUE) | identical | identical |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée absente (FALSE) | identical | identical |
| donnees_ln_interieur II-1 nettes, réassurance NP déclarée présente (TRUE) | identical | identical |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée absente (FALSE) | identical | identical |
| donnees_ln_interieur II-4 nettes, réassurance NP déclarée présente (TRUE) | identical | identical |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée absente (FALSE) | identical | identical |
| donnees_ln_interieur II-5 nettes, réassurance NP déclarée présente (TRUE) | identical | identical |
| donnees_ln II-1 brutes, sans déclaration (témoin) | identical | identical |
| donnees_ln_interieur II-1 brutes, sans déclaration (témoin) | identical | identical |
| donnees_ln II-6 nettes, réassurance NP déclarée absente (FALSE) (témoin) | identical | identical |
| donnees_ln XIV-1 nettes, réassurance NP déclarée absente (FALSE) (témoin) | identical | identical |
| reserve1 (donnees_ln, II-1), CDD qualifiante déclarée absente (FALSE) (témoin) | identical | identical |
| reserve2 (triangle_mw, II-1), CDD qualifiante déclarée absente (FALSE) (témoin) | identical | identical |

Contrôle d'antériorité : **OK**. Durée : 618 s (3 processus).
