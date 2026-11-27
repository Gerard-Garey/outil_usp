# Corrélation de W² (Cramér–von Mises) et A² (Anderson–Darling) sous la loi de leurs p de Monte-Carlo, jeux J1 et J2, à T = 8 (issue #420, point 2)

### T0 — Exécution

| Grandeur | Valeur |
|---|---|
| Date | 2026-11-27 14:24:22 UTC |
| Script | `tests/mesure_correlation_cvm_ad_t8.R` |
| Commit | `ac88b46be6d141c8059e7eeb7086fc2484ecd95e` |
| Empreintes du code | tests/mesure_correlation_cvm_ad_t8.R 75062eff63abfe4564602c7a7d574253 ; tests/outils_tests.R cd6f78dd811f125f1755acc55e1fd228 |
| Moteur | `R/engine.R`, md5 `c7b767f5d9116c35a0a9237ffdd2d79a`, empreinte sans commentaires `15a74c3dbd831c56c259df106e9e4667` |
| R | R version 4.3.3 (2024-02-29), Ubuntu 24.04.5 LTS, Linux, x86_64 |
| BLAS / LAPACK | /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.12.0 / /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.12.0 |
| Plan | J1 = cas `premium`, J2 = cas `premium_interieur` (`CAS`, `tests/outils_tests.R`) ; `run_engine()` du cas, seuls B = 9 999 et seed = 20260831 posés ; aucune simulation hors de `usp_bootstrap()` |
| Graines (`res$metadata`) | J1 : seed 20260831, seed_flux_regime 20800000, générateur Mersenne-Twister/Inversion/Rejection ; J2 : seed 20260831, seed_flux_regime 20800000, générateur Mersenne-Twister/Inversion/Rejection |
| Erreur Monte-Carlo | jackknife par groupes, G = 20 groupes consécutifs de lignes retenues ; tailles : J1 499 à 500, J2 499 à 500 |
| α de la concordance des rejets | 0,10 ; 0,05 (rejet si p < α) |
| Contrôles | tous conformes (T4) |
| Durée totale du script | 261.8 s |

Statut des valeurs : approximation Monte-Carlo d'une fonctionnelle de la loi bootstrap, conditionnelle aux paramètres ajustés de chaque jeu ;
constat de simulation sur deux jeux, à T = 8. ET : erreur Monte-Carlo (fonction de B), par jackknife par groupes ; aucune erreur d'échantillonnage en R (un seul jeu de données par cas).
Loi : celle qui définit les p de Monte-Carlo de CvM et AD (`bootstrap$stats_boot`, variante V1 ou V3b de la p Monte-Carlo, ADR 0014), non une loi sous les alternatives.

### T1 — Jeux, lois et réplications

| Jeu | Cas | δ̂ | σ_USP | Variante de la p Monte-Carlo (attendue) | Régime de δ̂ | Tirages / retenus (V3b) | Lignes de `stats_boot` | Écartées : W² et A² non finies | Écartées : une seule non finie | n retenu | Ex aequo (W² ; A²) | Temps écoulé (s) | Temps CPU (s) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| J1 | `premium` | 1.000000 | 0.1114524114 | V1 (V1) | bord1 | — | 9999 | 0 | 0 | 9999 | 0 ; 0 | 96.9 | 96.2 |
| J2 | `premium_interieur` | 0.663991 | 0.0871308679 | V3b (V3b) | interieur | 44686 / 9999 (arrêt : cible) | 9999 | 0 | 0 | 9999 | 0 ; 0 | 163.7 | 162.0 |

### T2 — Valeurs observées et lignes de tests

| Jeu | Statistique | Valeur observée | p Monte-Carlo | err_mc | Test | Type | p retenue | Verdict |
|---|---|---|---|---|---|---|---|---|
| J1 | W² (CvM) | 0.05492236403 | 0.4628 | 0.0050 | Cramer-von Mises | diagnostic | — | INFO |
| J1 | A² (AD) | 0.3257904403 | 0.5467 | 0.0050 | Anderson-Darling | test | 0.5467 | OK |
| J2 | W² (CvM) | 0.03449000726 | 0.8395 | 0.0037 | Cramer-von Mises | diagnostic | — | INFO |
| J2 | A² (AD) | 0.2545970281 | 0.8020 | 0.0040 | Anderson-Darling | test | 0.8020 | OK |

### T3 — Dépendance de W² et A² sous la loi bootstrap : estimation ± ET (jackknife, G = 20)

| Grandeur | J1 | J2 | Repère |
|---|---|---|---|
| ρ de Spearman (grandeur principale) | 0.9779 ± 0.00061 | 0.9763 ± 0.00044 | 1 si dépendance parfaite, 0 si indépendance |
| r de Pearson (grandeur secondaire) | 0.9843 ± 0.00049 | 0.9803 ± 0.00043 | 1 si dépendance parfaite, 0 si indépendance |
| P(rejet CvM), α = 0,10 | 0.0999 = (⌈nα⌉ − 1)/n — par construction | 0.0999 = (⌈nα⌉ − 1)/n — par construction | ≈ 0,10 par construction (p laisser-un-de-côté) |
| P(rejet AD), α = 0,10 | 0.0999 = (⌈nα⌉ − 1)/n — par construction | 0.0999 = (⌈nα⌉ − 1)/n — par construction | ≈ 0,10 par construction (p laisser-un-de-côté) |
| P(rejet CvM et rejet AD), α = 0,10 | 0.0899 ± 0.00071 | 0.0880 ± 0.00091 | 0,10 si comonotonie, ≈ 0,10² si indépendance |
| P(rejet CvM \| rejet AD) = P(rejet AD \| rejet CvM), α = 0,10 (égales par construction, aucun ex aequo en T1) | 0.8999 ± 0.00716 | 0.8809 ± 0.00912 | 1 si comonotonie, ≈ 0,10 si indépendance |
| P(rejet CvM), α = 0,05 | 0.0499 = (⌈nα⌉ − 1)/n — par construction | 0.0499 = (⌈nα⌉ − 1)/n — par construction | ≈ 0,05 par construction (p laisser-un-de-côté) |
| P(rejet AD), α = 0,05 | 0.0499 = (⌈nα⌉ − 1)/n — par construction | 0.0499 = (⌈nα⌉ − 1)/n — par construction | ≈ 0,05 par construction (p laisser-un-de-côté) |
| P(rejet CvM et rejet AD), α = 0,05 | 0.0436 ± 0.00085 | 0.0434 ± 0.00065 | 0,05 si comonotonie, ≈ 0,05² si indépendance |
| P(rejet CvM \| rejet AD) = P(rejet AD \| rejet CvM), α = 0,05 (égales par construction, aucun ex aequo en T1) | 0.8737 ± 0.01711 | 0.8697 ± 0.01309 | 1 si comonotonie, ≈ 0,05 si indépendance |

p laisser-un-de-côté de la réplication i : (1 + #{j ≠ i : s_j ≥ s_i}) / n, n lignes retenues ; rejet si p < α (règle des verdicts, sens « ne pas rejeter »).
Sans ex aequo sur une statistique (T1), ses p laisser-un-de-côté sont une permutation de {1/n, ..., n/n} : elle compte exactement ⌈nα⌉ − 1 rejets, et son taux marginal (⌈nα⌉ − 1)/n est fixé par construction, sans ET (l'ET jackknife n'y refléterait que les tailles des sous-échantillons). Sans ex aequo sur W² et A², P(rejet CvM | rejet AD) et P(rejet AD | rejet CvM) sont égales par construction (contrôle (c5)) ; sinon, le critère porte sur la plus petite des deux. L'ET du taux conjoint est une erreur Monte-Carlo réelle.
ET : écart-type jackknife par groupes consécutifs, erreur Monte-Carlo seule (fonction de B) ; la dépendance aux paramètres ajustés n'est pas une erreur mais une conditionnalité.

### T4 — Contrôles

| Contrôle | Résultat | Détail |
|---|---|---|
| (c1) | conforme | sens de rejet au catalogue : CvM haut, AD haut |
| (c2) J1 | conforme | CvM : p recalculée 0.46279999999999999 sur 9999 valeurs finies ; AD : p recalculée 0.54669999999999996 sur 9999 valeurs finies |
| (c3) J1 | conforme | p laisser-un-de-côté par les rangs = comptage direct, 200 premières lignes retenues, W² et A² |
| (c4) J1 | conforme | seed 20260831, B 9999, graine du flux 20800000 (attendue 20800000) |
| (c5) J1 | conforme | sans ex aequo : rejets marginaux = #{k : k/n < α} (999 à α = 0.1, 499 à α = 0.05) et conditionnelles identiques, échantillon entier et 20 sous-échantillons |
| (c2) J2 | conforme | CvM : p recalculée 0.83950000000000002 sur 9999 valeurs finies ; AD : p recalculée 0.80200000000000005 sur 9999 valeurs finies |
| (c3) J2 | conforme | p laisser-un-de-côté par les rangs = comptage direct, 200 premières lignes retenues, W² et A² |
| (c4) J2 | conforme | seed 20260831, B 9999, graine du flux 20800000 (attendue 20800000) |
| (c5) J2 | conforme | sans ex aequo : rejets marginaux = #{k : k/n < α} (999 à α = 0.1, 499 à α = 0.05) et conditionnelles identiques, échantillon entier et 20 sous-échantillons |

(c1) sens de rejet au catalogue `USP_CATALOGUE_MC` ; (c2) p_mc recalculée depuis `stats_boot` identique à `bootstrap$p_mc`, à `engine_p_mc()` et à la ligne de `engine_table_tests()`, B effectif identique, sans motif ;
(c3) p laisser-un-de-côté par les rangs identiques au comptage direct ; (c4) graine, B et graine du flux V3b conformes au plan ;
(c5) sans ex aequo : rejets marginaux égaux à ⌈nα⌉ − 1 et conditionnelles identiques (`identical()`), échantillon entier et sous-échantillons jackknife.

### T5 — Lecture du critère (avis d'actuary, par. 2.4, complété par ses réponses Q1 et Q2)

**Quasi-redondance sous H0 établie** : sur J1 et J2, ρ_S − 2 ET ≥ 0,90 et min(P(rejet CvM | rejet AD), P(rejet AD | rejet CvM)) − 2 ET ≥ 0,75 à α = 0,10.

ρ_S : J1 0.9779, J2 0.9763 ; ρ_S − 2 ET : J1 0.9766, J2 0.9754 ; min(P(rejet CvM | rejet AD), P(rejet AD | rejet CvM)) à α = 0,10 : J1 0.8999, J2 0.8809 ; moins 2 ET : J1 0.8856, J2 0.8626.
Critère de concordance sur min(P(rejet CvM | rejet AD), P(rejet AD | rejet CvM)) : égales par construction en l'absence d'ex aequo (T1) ; sinon, critère sur la plus petite des deux.
Seuils 0,90, 0,75 et 0,70 : conventions déclarées par l'avis, sans fondement théorique.
ET jackknife à G = 20 groupes : environ 19 degrés de liberté, incertitude relative de l'ET d'environ 1/√38 ≈ 16 % (approximation du χ²) ; la borne « − 2 ET » est donc une convention à ± 0,3 ET près.
Portée : rien sous les alternatives, où la pondération des queues de A² les distingue ; la mesure ne dit pas qu'un seul verdict suffit en puissance ; conditionnelle à J1 et J2, à T = 8.
