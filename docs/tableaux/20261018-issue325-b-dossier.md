# Calcul du dossier à B = 4 999 : durée d'exécution et stabilité des verdicts sur les six cas (issue #325)

### T0 — Exécution

| Grandeur | Valeur |
|---|---|
| Date | 2026-10-18 00:20:12 UTC |
| Script | `tests/mesure_b_dossier_t8.R` |
| Commit | `0d75c9fab481d1e68d357e6ef82f9329df5dca94` |
| Empreintes du code | tests/mesure_b_dossier_t8.R a422c50937fcd841b4b9f67a71bde0f1 ; tests/outils_tests.R 7127605f20e8c261d41d3c372f4f2f1b |
| Moteur | `R/engine.R`, md5 `a7025ea04d2ff0821bdb61b611865363`, empreinte sans commentaires `ddc234c2b680ce6208d0e90e3adfc7fb` |
| R | R version 4.3.3 (2024-02-29), Ubuntu 24.04.5 LTS, Linux, x86_64 ; cœurs (`parallel::detectCores()`) : 4 |
| BLAS / LAPACK | /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.12.0 / /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.12.0 |
| Plan | six cas de `CAS` (`tests/outils_tests.R`) à B = 999 et 4 999, `reserve2` en plus à B = 9 999 ; appel du cas avec le seul argument B posé ; une exécution à la fois, dans un seul processus |
| Graines (`res$metadata`, au B minimal ; inchangées entre les B) | premium : seed 20260831, seed_loi_nulle_sw 20260901, seed_flux_regime 20800000, permutation_pente : enumeration, générateur Mersenne-Twister/Inversion/Rejection ; reserve1 : seed 20260831, seed_loi_nulle_sw 20260901, seed_flux_regime 20800000, permutation_pente : enumeration, générateur Mersenne-Twister/Inversion/Rejection ; reserve2 : seed 20260831, seed_loi_nulle_sw 20260901, générateur Mersenne-Twister/Inversion/Rejection ; premium_ii6 : seed 20260831, seed_loi_nulle_sw 20260901, seed_flux_regime 20800000, permutation_pente : enumeration, générateur Mersenne-Twister/Inversion/Rejection ; premium_net : seed 20260831, seed_loi_nulle_sw 20260901, seed_flux_regime 20800000, permutation_pente : enumeration, générateur Mersenne-Twister/Inversion/Rejection ; premium_interieur : seed 20260831, seed_loi_nulle_sw 20260901, seed_flux_regime 20800000, permutation_pente : enumeration, générateur Mersenne-Twister/Inversion/Rejection |
| Graines identiques entre les B d'un même cas | oui |
| α | 0.1 |
| Contrôle (a) : exécution à B = 999 contre sa référence (`comparer_objets()`, tolérance 1e-06) | premium : CONFORME : 23840 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00 (référence md5 e03a01e28c146eb4dd4ce90819f4b7bf) ; reserve1 : CONFORME : 23839 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00 (référence md5 b8e36cf8676ee71e2284685da22e8b1d) ; reserve2 : CONFORME : 4470 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00 (référence md5 95e5336026ba7a55081e30c96f9b2991) ; premium_ii6 : CONFORME : 23840 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00 (référence md5 a8d532fe716eceed1331b064ce7432f8) ; premium_net : CONFORME : 23840 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00 (référence md5 49a1a23999413c922a01ea7532016309) ; premium_interieur : CONFORME : 23840 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00 (référence md5 33c4e963bd3fe7b0c94290cbd3c15626) |
| Contrôle (c) : condition de #244 recalculée (écart au seuil, T3) = mention posée par le moteur, sur toutes les lignes | conforme |
| Charge moyenne sur 1 min (`/proc/loadavg`), min – max sur les exécutions | 5.35 – 7.81 |
| Durée totale du script | 735.1 s |

Statut des valeurs : une seule graine par cas ; p retenue, err_mc et verdict tels que les rend `run_engine()`.
Un verdict qui change d'un B à l'autre est un comportement observé sur cette graine : la p-value Monte-Carlo est une estimation
d'erreur Monte-Carlo err_mc (fonction de B), distincte de l'erreur d'approximation de la loi de la statistique à T = 8, que B ne réduit pas.
Temps écoulé et temps CPU : mesurés sous la charge restituée (colonne Charge), sans correction ; non mesurés sur machine non chargée.
Mention #244 : le `detail` de la ligne se termine par la phrase de sensibilité du verdict (p à moins de 2 err_mc d'un seuil atteignable).
err_mc n'est affichée que lorsque la p retenue est Monte-Carlo.
Imbrication des tirages (T1) : vérifiée sur `sigma_boot` seul ; le flux complémentaire de la p conditionnelle au régime (`premium_interieur`, graine `seed_flux_regime`) et les autres tirages ne sont pas contrôlés.

### T1 — Durée et σ_USP par cas et par B

| Cas | B | Temps écoulé (s) | Temps CPU (s) | Rapport CPU / CPU à B minimal | Charge avant → après | σ_USP | Premières valeurs de `sigma_boot` identiques à celles du B minimal | Triangles retirés (`cumuls_retires`) | Plafond atteint |
|---|---|---|---|---|---|---|---|---|---|
| `premium` | 999 | 10.3 | 9.8 | 1.00 | 6.44 → 6.37 | 0.1114524114 | — | — | — |
| `reserve1` | 999 | 11.6 | 10.1 | 1.00 | 6.37 → 6.47 | 0.1073524114 | — | — | — |
| `reserve2` | 999 | 21.1 | 19.3 | 1.00 | 6.47 → 6.38 | 0.0497764613 | — | 0 | non |
| `premium_ii6` | 999 | 11.3 | 9.9 | 1.00 | 6.38 → 6.40 | 0.1483524114 | — | — | — |
| `premium_net` | 999 | 13.0 | 10.2 | 1.00 | 6.40 → 6.54 | 0.1032524114 | — | — | — |
| `premium_interieur` | 999 | 24.7 | 19.2 | 1.00 | 6.54 → 6.70 | 0.0871308679 | — | — | — |
| `premium` | 4 999 | 62.9 | 49.8 | 5.07 | 6.70 → 6.89 | 0.1114524114 | oui | — | — |
| `reserve1` | 4 999 | 53.2 | 48.2 | 4.79 | 6.89 → 6.71 | 0.1073524114 | oui | — | — |
| `reserve2` | 4 999 | 96.6 | 89.9 | 4.65 | 6.71 → 5.94 | 0.0497764613 | oui | 0 | non |
| `premium_ii6` | 4 999 | 53.6 | 48.1 | 4.84 | 5.94 → 6.35 | 0.1483524114 | oui | — | — |
| `premium_net` | 4 999 | 50.2 | 48.2 | 4.73 | 6.35 → 5.90 | 0.1032524114 | oui | — | — |
| `premium_interieur` | 4 999 | 88.4 | 87.2 | 4.54 | 5.90 → 5.35 | 0.0871308679 | oui | — | — |
| `reserve2` | 9 999 | 213.3 | 179.9 | 9.31 | 5.35 → 7.81 | 0.0497764613 | oui | 0 | non |
| Total | | 710.1 | 629.8 | | | | | | |

Temps CPU : grandeur de référence de la durée, mesurée sur machine chargée (charge 5.35 à 7.81 sur 4 cœurs).

### T1 bis — Décomptes par cas et par B

| Cas | B | Lignes | OK | ALERTE | ECHEC | INFO | Autres verdicts | p retenue Monte-Carlo | Mentions #244 | Lignes inopérantes |
|---|---|---|---|---|---|---|---|---|---|---|
| `premium` | 999 | 51 | 32 | 3 | 1 | 15 | 0 | 26 | 2 | 1 |
| `reserve1` | 999 | 51 | 32 | 3 | 1 | 15 | 0 | 26 | 2 | 1 |
| `reserve2` | 999 | 20 | 8 | 2 | 4 | 6 | 0 | 13 | 2 | 0 |
| `premium_ii6` | 999 | 51 | 32 | 3 | 1 | 15 | 0 | 26 | 2 | 1 |
| `premium_net` | 999 | 51 | 32 | 3 | 1 | 15 | 0 | 26 | 2 | 1 |
| `premium_interieur` | 999 | 51 | 34 | 1 | 1 | 15 | 0 | 33 | 1 | 1 |
| `premium` | 4 999 | 51 | 31 | 4 | 1 | 15 | 0 | 26 | 1 | 1 |
| `reserve1` | 4 999 | 51 | 31 | 4 | 1 | 15 | 0 | 26 | 1 | 1 |
| `reserve2` | 4 999 | 20 | 8 | 2 | 4 | 6 | 0 | 13 | 1 | 0 |
| `premium_ii6` | 4 999 | 51 | 31 | 4 | 1 | 15 | 0 | 26 | 1 | 1 |
| `premium_net` | 4 999 | 51 | 31 | 4 | 1 | 15 | 0 | 26 | 1 | 1 |
| `premium_interieur` | 4 999 | 51 | 33 | 2 | 1 | 15 | 0 | 33 | 1 | 1 |
| `reserve2` | 9 999 | 20 | 7 | 3 | 4 | 6 | 0 | 13 | 1 | 0 |

### T2 — Lignes de tests, par cas

p : p retenue ; err_mc : erreur Monte-Carlo de la ligne ; nature de la p retenue lue au B minimal (changements en T4).

#### Cas `premium` (graine 20260831)

| # | Famille | Test | Variante | Type | Nature de la p retenue | p (B = 999) | err_mc (B = 999) | Verdict (B = 999) | #244 (B = 999) | p (B = 4 999) | err_mc (B = 4 999) | Verdict (B = 4 999) | #244 (B = 4 999) | Verdict change |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Nullite de la constante (proportionnalite stricte) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9640 | 0.0316 | OK |  | 0.9672 | 0.0141 | OK |  |  |
| 2 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Equivalence de la constante a zero (TOST) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 3 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Test de Pitman sur la pente (lien positif pertes / volume) | principale | test | exacte par permutation (H0 : y independant de x, hors modele reglementaire) | 0.1107 | — | ALERTE |  | 0.1107 | — | ALERTE |  |  |
| 4 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Test de Fisher (significativite globale) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 5 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Coefficient de determination R2 | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 6 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | RESET (forme fonctionnelle) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9960 | 0.0020 | OK |  | 0.9956 | 0.0009 | OK |  |  |
| 7 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Independance ratio S/P vs volume | principale | test | exacte | 0.8820 | — | OK |  | 0.8820 | — | OK |  |  |
| 8 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Correlation ratio S/P vs temps | principale | test | exacte | 0.8401 | — | OK |  | 0.8401 | — | OK |  |  |
| 9 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Tendance monotone du ratio S/P | principale | test | exacte | 0.7195 | — | OK |  | 0.7195 | — | OK |  |  |
| 10 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Tendance par signes du ratio S/P | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 11 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.0180 | 0.0042 | ECHEC |  | 0.0126 | 0.0016 | ECHEC |  |  |
| 12 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | secondaire | test | Monte-Carlo (bootstrap parametrique) | 0.0900 | 0.0091 | ALERTE | oui | 0.0832 | 0.0039 | ALERTE |  |  |
| 13 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Heteroscedasticite (forme quadratique) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.0670 | 0.0079 | ALERTE |  | 0.0610 | 0.0034 | ALERTE |  |  |
| 14 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Egalite des variances petits vs gros volumes | principale | test | Monte-Carlo (bootstrap parametrique) | 0.1900 | 0.0186 | OK |  | 0.1836 | 0.0082 | OK |  |  |
| 15 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Homogeneite des dispersions (mediane) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.1040 | 0.0097 | OK | oui | 0.0964 | 0.0042 | ALERTE | oui | **oui** |
| 16 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Egalite des lois petits vs gros volumes (2 ech.) | principale | test | exacte | 0.7714 | — | OK |  | 0.7714 | — | OK |  |  |
| 17 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Position de delta dans [0,1] | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 18 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Shapiro-Wilk sur residus standardises | principale | test | Monte-Carlo (bootstrap parametrique) | 0.6200 | 0.0154 | OK |  | 0.6006 | 0.0069 | OK |  |  |
| 19 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston) | secondaire | test | exacte | 0.5964 | — | OK |  | 0.5964 | — | OK |  |  |
| 20 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Shapiro-Francia | principale | test | Monte-Carlo (bootstrap parametrique) | 0.6860 | 0.0147 | OK |  | 0.6740 | 0.0066 | OK |  |  |
| 21 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Anderson-Darling | principale | test | Monte-Carlo (bootstrap parametrique) | 0.5660 | 0.0157 | OK |  | 0.5468 | 0.0070 | OK |  |  |
| 22 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Cramer-von Mises | principale | test | Monte-Carlo (bootstrap parametrique) | 0.4760 | 0.0158 | OK |  | 0.4620 | 0.0071 | OK |  |  |
| 23 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Kolmogorov-Smirnov contre N(0,1) | secondaire | test | Monte-Carlo (bootstrap parametrique) | 0.2670 | 0.0140 | OK |  | 0.2408 | 0.0060 | OK |  |  |
| 24 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Lilliefors (KS a parametres estimes) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.2690 | 0.0140 | OK |  | 0.2496 | 0.0061 | OK |  |  |
| 25 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Jarque-Bera | principale | test | Monte-Carlo (bootstrap parametrique) | 0.6740 | 0.0148 | OK |  | 0.6598 | 0.0067 | OK |  |  |
| 26 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Asymetrie (D'Agostino, T >= 8) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.7080 | 0.0303 | OK |  | 0.7108 | 0.0135 | OK |  |  |
| 27 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Aplatissement (Anscombe-Glynn, T >= 20) | principale | non applicable | — | — | — | INFO |  | — | — | INFO |  |  |
| 28 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Autocorrelation d'ordre 1 (Durbin-Watson) | principale | test | exacte | 0.5649 | — | OK |  | 0.5649 | — | OK |  |  |
| 29 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Ljung-Box (retard 1) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9370 | 0.0077 | OK |  | 0.9320 | 0.0036 | OK |  |  |
| 30 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Ljung-Box (retard 2) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.1880 | 0.0124 | OK |  | 0.1944 | 0.0056 | OK |  |  |
| 31 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Box-Pierce (retard 2) | secondaire | test | Monte-Carlo (bootstrap parametrique) | 0.2160 | 0.0130 | OK |  | 0.2272 | 0.0059 | OK |  |  |
| 32 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Test des suites (aleatoire des signes) | principale | test | exacte | 0.7429 | — | OK |  | 0.7429 | — | OK |  |  |
| 33 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Centrage des residus standardises | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 34 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Variance unitaire des residus standardises | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 35 | F. Stabilite, ruptures et points aberrants | Rupture de niveau (sup-F) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.8400 | 0.0116 | OK |  | 0.8534 | 0.0050 | OK |  |  |
| 36 | F. Stabilite, ruptures et points aberrants | Stabilite cumulee (OLS-CUSUM) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.8170 | 0.0122 | OK |  | 0.8240 | 0.0054 | OK |  |  |
| 37 | F. Stabilite, ruptures et points aberrants | Valeur aberrante isolee (Grubbs) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.8610 | 0.0109 | OK |  | 0.8578 | 0.0049 | OK |  |  |
| 38 | F. Stabilite, ruptures et points aberrants | Valeurs aberrantes multiples (ESD generalise) | principale | procedure de decision | — | — | — | OK |  | — | — | OK |  |  |
| 39 | F. Stabilite, ruptures et points aberrants | Points influents (distance de Cook) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 40 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.5660 | 0.0285 | OK |  | 0.5904 | 0.0129 | OK |  |  |
| 41 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Ljung-Box (retard 1) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9960 | 0.0020 | OK |  | 0.9932 | 0.0012 | OK |  |  |
| 42 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Test des suites sur ratios bruts | principale | test | exacte | 0.7429 | — | OK |  | 0.7429 | — | OK |  |  |
| 43 | F. Stabilite, ruptures et points aberrants | Rupture de niveau (sup-F) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9310 | 0.0080 | OK |  | 0.9344 | 0.0035 | OK |  |  |
| 44 | F. Stabilite, ruptures et points aberrants | Stabilite cumulee (OLS-CUSUM) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.7560 | 0.0136 | OK |  | 0.7642 | 0.0060 | OK |  |  |
| 45 | F. Stabilite, ruptures et points aberrants | Valeur aberrante isolee (Grubbs) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.7770 | 0.0132 | OK |  | 0.7696 | 0.0060 | OK |  |  |
| 46 | F. Stabilite, ruptures et points aberrants | Leviers (hat values) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 47 | G. Robustesse de l'estimation | Sensibilite au retrait d'une annee (jackknife) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 48 | G. Robustesse de l'estimation | Largeur relative de l'IC bootstrap 90% | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 49 | G. Robustesse de l'estimation | Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 50 | G. Robustesse de l'estimation | Rapport de vraisemblance : delta = 0 (variance lineaire en volume) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 51 | G. Robustesse de l'estimation | Rapport de vraisemblance : delta = 1 (variance quadratique en volume) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |

#### Cas `reserve1` (graine 20260831)

| # | Famille | Test | Variante | Type | Nature de la p retenue | p (B = 999) | err_mc (B = 999) | Verdict (B = 999) | #244 (B = 999) | p (B = 4 999) | err_mc (B = 4 999) | Verdict (B = 4 999) | #244 (B = 4 999) | Verdict change |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | B. H1 - linearite / proportionnalite (annexe XVII C(2)(e)(i)) | Nullite de la constante (proportionnalite stricte) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9640 | 0.0316 | OK |  | 0.9672 | 0.0141 | OK |  |  |
| 2 | B. H1 - linearite / proportionnalite (annexe XVII C(2)(e)(i)) | Equivalence de la constante a zero (TOST) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 3 | B. H1 - linearite / proportionnalite (annexe XVII C(2)(e)(i)) | Test de Pitman sur la pente (lien positif pertes / volume) | principale | test | exacte par permutation (H0 : y independant de x, hors modele reglementaire) | 0.1107 | — | ALERTE |  | 0.1107 | — | ALERTE |  |  |
| 4 | B. H1 - linearite / proportionnalite (annexe XVII C(2)(e)(i)) | Test de Fisher (significativite globale) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 5 | B. H1 - linearite / proportionnalite (annexe XVII C(2)(e)(i)) | Coefficient de determination R2 | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 6 | B. H1 - linearite / proportionnalite (annexe XVII C(2)(e)(i)) | RESET (forme fonctionnelle) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9960 | 0.0020 | OK |  | 0.9956 | 0.0009 | OK |  |  |
| 7 | B. H1 - linearite / proportionnalite (annexe XVII C(2)(e)(i)) | Independance ratio S/P vs volume | principale | test | exacte | 0.8820 | — | OK |  | 0.8820 | — | OK |  |  |
| 8 | B. H1 - linearite / proportionnalite (annexe XVII C(2)(e)(i)) | Correlation ratio S/P vs temps | principale | test | exacte | 0.8401 | — | OK |  | 0.8401 | — | OK |  |  |
| 9 | B. H1 - linearite / proportionnalite (annexe XVII C(2)(e)(i)) | Tendance monotone du ratio S/P | principale | test | exacte | 0.7195 | — | OK |  | 0.7195 | — | OK |  |  |
| 10 | B. H1 - linearite / proportionnalite (annexe XVII C(2)(e)(i)) | Tendance par signes du ratio S/P | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 11 | C. H2 - structure de variance (annexe XVII C(2)(e)(ii)) | Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.0180 | 0.0042 | ECHEC |  | 0.0126 | 0.0016 | ECHEC |  |  |
| 12 | C. H2 - structure de variance (annexe XVII C(2)(e)(ii)) | Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | secondaire | test | Monte-Carlo (bootstrap parametrique) | 0.0900 | 0.0091 | ALERTE | oui | 0.0832 | 0.0039 | ALERTE |  |  |
| 13 | C. H2 - structure de variance (annexe XVII C(2)(e)(ii)) | Heteroscedasticite (forme quadratique) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.0670 | 0.0079 | ALERTE |  | 0.0610 | 0.0034 | ALERTE |  |  |
| 14 | C. H2 - structure de variance (annexe XVII C(2)(e)(ii)) | Egalite des variances petits vs gros volumes | principale | test | Monte-Carlo (bootstrap parametrique) | 0.1900 | 0.0186 | OK |  | 0.1836 | 0.0082 | OK |  |  |
| 15 | C. H2 - structure de variance (annexe XVII C(2)(e)(ii)) | Homogeneite des dispersions (mediane) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.1040 | 0.0097 | OK | oui | 0.0964 | 0.0042 | ALERTE | oui | **oui** |
| 16 | C. H2 - structure de variance (annexe XVII C(2)(e)(ii)) | Egalite des lois petits vs gros volumes (2 ech.) | principale | test | exacte | 0.7714 | — | OK |  | 0.7714 | — | OK |  |  |
| 17 | C. H2 - structure de variance (annexe XVII C(2)(e)(ii)) | Position de delta dans [0,1] | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 18 | D. H3 - lognormalite (annexe XVII C(2)(e)(iii)) | Shapiro-Wilk sur residus standardises | principale | test | Monte-Carlo (bootstrap parametrique) | 0.6200 | 0.0154 | OK |  | 0.6006 | 0.0069 | OK |  |  |
| 19 | D. H3 - lognormalite (annexe XVII C(2)(e)(iii)) | Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston) | secondaire | test | exacte | 0.5964 | — | OK |  | 0.5964 | — | OK |  |  |
| 20 | D. H3 - lognormalite (annexe XVII C(2)(e)(iii)) | Shapiro-Francia | principale | test | Monte-Carlo (bootstrap parametrique) | 0.6860 | 0.0147 | OK |  | 0.6740 | 0.0066 | OK |  |  |
| 21 | D. H3 - lognormalite (annexe XVII C(2)(e)(iii)) | Anderson-Darling | principale | test | Monte-Carlo (bootstrap parametrique) | 0.5660 | 0.0157 | OK |  | 0.5468 | 0.0070 | OK |  |  |
| 22 | D. H3 - lognormalite (annexe XVII C(2)(e)(iii)) | Cramer-von Mises | principale | test | Monte-Carlo (bootstrap parametrique) | 0.4760 | 0.0158 | OK |  | 0.4620 | 0.0071 | OK |  |  |
| 23 | D. H3 - lognormalite (annexe XVII C(2)(e)(iii)) | Kolmogorov-Smirnov contre N(0,1) | secondaire | test | Monte-Carlo (bootstrap parametrique) | 0.2670 | 0.0140 | OK |  | 0.2408 | 0.0060 | OK |  |  |
| 24 | D. H3 - lognormalite (annexe XVII C(2)(e)(iii)) | Lilliefors (KS a parametres estimes) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.2690 | 0.0140 | OK |  | 0.2496 | 0.0061 | OK |  |  |
| 25 | D. H3 - lognormalite (annexe XVII C(2)(e)(iii)) | Jarque-Bera | principale | test | Monte-Carlo (bootstrap parametrique) | 0.6740 | 0.0148 | OK |  | 0.6598 | 0.0067 | OK |  |  |
| 26 | D. H3 - lognormalite (annexe XVII C(2)(e)(iii)) | Asymetrie (D'Agostino, T >= 8) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.7080 | 0.0303 | OK |  | 0.7108 | 0.0135 | OK |  |  |
| 27 | D. H3 - lognormalite (annexe XVII C(2)(e)(iii)) | Aplatissement (Anscombe-Glynn, T >= 20) | principale | non applicable | — | — | — | INFO |  | — | — | INFO |  |  |
| 28 | E. H4 - independance et validite du MV (annexe XVII C(2)(e)(iv)) | Autocorrelation d'ordre 1 (Durbin-Watson) | principale | test | exacte | 0.5649 | — | OK |  | 0.5649 | — | OK |  |  |
| 29 | E. H4 - independance et validite du MV (annexe XVII C(2)(e)(iv)) | Ljung-Box (retard 1) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9370 | 0.0077 | OK |  | 0.9320 | 0.0036 | OK |  |  |
| 30 | E. H4 - independance et validite du MV (annexe XVII C(2)(e)(iv)) | Ljung-Box (retard 2) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.1880 | 0.0124 | OK |  | 0.1944 | 0.0056 | OK |  |  |
| 31 | E. H4 - independance et validite du MV (annexe XVII C(2)(e)(iv)) | Box-Pierce (retard 2) | secondaire | test | Monte-Carlo (bootstrap parametrique) | 0.2160 | 0.0130 | OK |  | 0.2272 | 0.0059 | OK |  |  |
| 32 | E. H4 - independance et validite du MV (annexe XVII C(2)(e)(iv)) | Test des suites (aleatoire des signes) | principale | test | exacte | 0.7429 | — | OK |  | 0.7429 | — | OK |  |  |
| 33 | E. H4 - independance et validite du MV (annexe XVII C(2)(e)(iv)) | Centrage des residus standardises | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 34 | E. H4 - independance et validite du MV (annexe XVII C(2)(e)(iv)) | Variance unitaire des residus standardises | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 35 | F. Stabilite, ruptures et points aberrants | Rupture de niveau (sup-F) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.8400 | 0.0116 | OK |  | 0.8534 | 0.0050 | OK |  |  |
| 36 | F. Stabilite, ruptures et points aberrants | Stabilite cumulee (OLS-CUSUM) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.8170 | 0.0122 | OK |  | 0.8240 | 0.0054 | OK |  |  |
| 37 | F. Stabilite, ruptures et points aberrants | Valeur aberrante isolee (Grubbs) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.8610 | 0.0109 | OK |  | 0.8578 | 0.0049 | OK |  |  |
| 38 | F. Stabilite, ruptures et points aberrants | Valeurs aberrantes multiples (ESD generalise) | principale | procedure de decision | — | — | — | OK |  | — | — | OK |  |  |
| 39 | F. Stabilite, ruptures et points aberrants | Points influents (distance de Cook) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 40 | E. H4 - independance et validite du MV (annexe XVII C(2)(e)(iv)) | Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.5660 | 0.0285 | OK |  | 0.5904 | 0.0129 | OK |  |  |
| 41 | E. H4 - independance et validite du MV (annexe XVII C(2)(e)(iv)) | Ljung-Box (retard 1) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9960 | 0.0020 | OK |  | 0.9932 | 0.0012 | OK |  |  |
| 42 | E. H4 - independance et validite du MV (annexe XVII C(2)(e)(iv)) | Test des suites sur ratios bruts | principale | test | exacte | 0.7429 | — | OK |  | 0.7429 | — | OK |  |  |
| 43 | F. Stabilite, ruptures et points aberrants | Rupture de niveau (sup-F) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9310 | 0.0080 | OK |  | 0.9344 | 0.0035 | OK |  |  |
| 44 | F. Stabilite, ruptures et points aberrants | Stabilite cumulee (OLS-CUSUM) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.7560 | 0.0136 | OK |  | 0.7642 | 0.0060 | OK |  |  |
| 45 | F. Stabilite, ruptures et points aberrants | Valeur aberrante isolee (Grubbs) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.7770 | 0.0132 | OK |  | 0.7696 | 0.0060 | OK |  |  |
| 46 | F. Stabilite, ruptures et points aberrants | Leviers (hat values) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 47 | G. Robustesse de l'estimation | Sensibilite au retrait d'une annee (jackknife) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 48 | G. Robustesse de l'estimation | Largeur relative de l'IC bootstrap 90% | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 49 | G. Robustesse de l'estimation | Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 50 | G. Robustesse de l'estimation | Rapport de vraisemblance : delta = 0 (variance lineaire en volume) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 51 | G. Robustesse de l'estimation | Rapport de vraisemblance : delta = 1 (variance quadratique en volume) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |

#### Cas `reserve2` (graine 20260831)

| # | Famille | Test | Variante | Type | Nature de la p retenue | p (B = 999) | err_mc (B = 999) | Verdict (B = 999) | #244 (B = 999) | p (B = 4 999) | err_mc (B = 4 999) | Verdict (B = 4 999) | #244 (B = 4 999) | p (B = 9 999) | err_mc (B = 9 999) | Verdict (B = 9 999) | #244 (B = 9 999) | Verdict change |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | M1. proportionnalite des cumules (annexe XVII D(2)(h)(iii)) | Absence de tendance des facteurs avec le cumul, a colonne donnee | principale | test | Monte-Carlo (bootstrap de residus) | 0.7780 | 0.0308 | OK |  | 0.7708 | 0.0138 | OK |  | 0.7870 | 0.0098 | OK |  |  |
| 2 | M1. proportionnalite des cumules (annexe XVII D(2)(h)(iii)) | Nullite de l'ordonnee a l'origine, colonne par colonne | principale | test | Monte-Carlo (bootstrap de residus) | 0.0850 | 0.0088 | ALERTE | oui | 0.0914 | 0.0041 | ALERTE |  | 0.0907 | 0.0029 | ALERTE |  |  |
| 3 | M1. proportionnalite des cumules (annexe XVII D(2)(h)(iii)) | Homogeneite de f_j entre annees de survenance | principale | test | Monte-Carlo (bootstrap de residus) | 0.0800 | 0.0086 | ALERTE |  | 0.0758 | 0.0037 | ALERTE |  | 0.0728 | 0.0026 | ALERTE |  |  |
| 4 | M1. proportionnalite des cumules (annexe XVII D(2)(h)(iii)) | Absence de courbure de la regression | principale | test | Monte-Carlo (bootstrap de residus) | 0.0300 | 0.0054 | ECHEC |  | 0.0256 | 0.0022 | ECHEC |  | 0.0275 | 0.0016 | ECHEC |  |  |
| 5 | M1. proportionnalite des cumules (annexe XVII D(2)(h)(iii)) | Stabilite du facteur selon la ponderation (famille alpha) | principale | test | Monte-Carlo (bootstrap de residus) | 0.0050 | 0.0022 | ECHEC |  | 0.0060 | 0.0011 | ECHEC |  | 0.0054 | 0.0007 | ECHEC |  |  |
| 6 | M2. variance proportionnelle au cumul (annexe XVII D(2)(h)(iv)) | Heteroscedasticite residuelle vs cumul | principale | test | Monte-Carlo (bootstrap de residus) | 0.1030 | 0.0096 | OK | oui | 0.1004 | 0.0043 | OK | oui | 0.0995 | 0.0030 | ALERTE | oui | **oui** |
| 7 | M2. variance proportionnelle au cumul (annexe XVII D(2)(h)(iv)) | Adequation de l'exposant de variance, colonne par colonne | principale | test | Monte-Carlo (bootstrap de residus) | 0.4280 | 0.0157 | OK |  | 0.4246 | 0.0070 | OK |  | 0.4215 | 0.0049 | OK |  |  |
| 8 | M2. variance proportionnelle au cumul (annexe XVII D(2)(h)(iv)) | Variance unitaire des residus de Mack | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  | — | — | INFO |  |  |
| 9 | M3. independance (annexe XVII D(2)(h)(i) et (ii)) | Effets d'annee calendaire (test de Mack) | principale | test | Monte-Carlo (bootstrap de residus) | 0.0020 | 0.0014 | ECHEC |  | 0.0010 | 0.0004 | ECHEC |  | 0.0005 | 0.0002 | ECHEC |  |  |
| 10 | M3. independance (annexe XVII D(2)(h)(i) et (ii)) | Effets d'annee calendaire par diagonale (repere de Mack 1997) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  | — | — | INFO |  |  |
| 11 | M3. independance (annexe XVII D(2)(h)(i) et (ii)) | Homogeneite des residus entre annees de survenance | principale | test | Monte-Carlo (bootstrap de residus) | 0.3000 | 0.0145 | OK |  | 0.2998 | 0.0065 | OK |  | 0.3056 | 0.0046 | OK |  |  |
| 12 | M3. independance (annexe XVII D(2)(h)(i) et (ii)) | Correlation entre annees de developpement adjacentes | principale | test | Monte-Carlo (bootstrap de residus) | 0.1700 | 0.0176 | OK |  | 0.1820 | 0.0081 | OK |  | 0.1882 | 0.0058 | OK |  |  |
| 13 | M3. independance (annexe XVII D(2)(h)(i) et (ii)) | Autocorrelation des residus (Durbin-Watson) | principale | test | Monte-Carlo (bootstrap de residus) | 0.0320 | 0.0079 | ECHEC |  | 0.0328 | 0.0036 | ECHEC |  | 0.0288 | 0.0024 | ECHEC |  |  |
| 14 | M3. independance (annexe XVII D(2)(h)(i) et (ii)) | Test des suites sur les residus de Mack | principale | test | Monte-Carlo (bootstrap de residus) | 0.3740 | 0.0247 | OK |  | 0.3192 | 0.0104 | OK |  | 0.3078 | 0.0072 | OK |  |  |
| 15 | M4. points aberrants et stabilite | Cellule aberrante du triangle (Grubbs) | principale | test | Monte-Carlo (bootstrap de residus) | 0.8920 | 0.0098 | OK |  | 0.9136 | 0.0040 | OK |  | 0.9111 | 0.0028 | OK |  |  |
| 16 | M4. points aberrants et stabilite | Cellules aberrantes multiples (ESD generalise) | principale | procedure de decision | — | — | — | OK |  | — | — | OK |  | — | — | OK |  |  |
| 17 | M5. normalite des residus (diagnostic, NON exige par le modele) | Shapiro-Wilk sur les residus de Mack | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  | — | — | INFO |  |  |
| 18 | M5. normalite des residus (diagnostic, NON exige par le modele) | Lilliefors sur les residus de Mack | secondaire | diagnostic | — | — | — | INFO |  | — | — | INFO |  | — | — | INFO |  |  |
| 19 | M6. robustesse de l'estimation | Extrapolation de sigma pour la derniere annee de developpement | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  | — | — | INFO |  |  |
| 20 | M6. robustesse de l'estimation | Part de la reserve portee par la derniere annee d'accident | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  | — | — | INFO |  |  |

#### Cas `premium_ii6` (graine 20260831)

| # | Famille | Test | Variante | Type | Nature de la p retenue | p (B = 999) | err_mc (B = 999) | Verdict (B = 999) | #244 (B = 999) | p (B = 4 999) | err_mc (B = 4 999) | Verdict (B = 4 999) | #244 (B = 4 999) | Verdict change |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Nullite de la constante (proportionnalite stricte) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9640 | 0.0316 | OK |  | 0.9672 | 0.0141 | OK |  |  |
| 2 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Equivalence de la constante a zero (TOST) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 3 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Test de Pitman sur la pente (lien positif pertes / volume) | principale | test | exacte par permutation (H0 : y independant de x, hors modele reglementaire) | 0.1107 | — | ALERTE |  | 0.1107 | — | ALERTE |  |  |
| 4 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Test de Fisher (significativite globale) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 5 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Coefficient de determination R2 | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 6 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | RESET (forme fonctionnelle) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9960 | 0.0020 | OK |  | 0.9956 | 0.0009 | OK |  |  |
| 7 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Independance ratio S/P vs volume | principale | test | exacte | 0.8820 | — | OK |  | 0.8820 | — | OK |  |  |
| 8 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Correlation ratio S/P vs temps | principale | test | exacte | 0.8401 | — | OK |  | 0.8401 | — | OK |  |  |
| 9 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Tendance monotone du ratio S/P | principale | test | exacte | 0.7195 | — | OK |  | 0.7195 | — | OK |  |  |
| 10 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Tendance par signes du ratio S/P | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 11 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.0180 | 0.0042 | ECHEC |  | 0.0126 | 0.0016 | ECHEC |  |  |
| 12 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | secondaire | test | Monte-Carlo (bootstrap parametrique) | 0.0900 | 0.0091 | ALERTE | oui | 0.0832 | 0.0039 | ALERTE |  |  |
| 13 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Heteroscedasticite (forme quadratique) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.0670 | 0.0079 | ALERTE |  | 0.0610 | 0.0034 | ALERTE |  |  |
| 14 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Egalite des variances petits vs gros volumes | principale | test | Monte-Carlo (bootstrap parametrique) | 0.1900 | 0.0186 | OK |  | 0.1836 | 0.0082 | OK |  |  |
| 15 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Homogeneite des dispersions (mediane) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.1040 | 0.0097 | OK | oui | 0.0964 | 0.0042 | ALERTE | oui | **oui** |
| 16 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Egalite des lois petits vs gros volumes (2 ech.) | principale | test | exacte | 0.7714 | — | OK |  | 0.7714 | — | OK |  |  |
| 17 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Position de delta dans [0,1] | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 18 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Shapiro-Wilk sur residus standardises | principale | test | Monte-Carlo (bootstrap parametrique) | 0.6200 | 0.0154 | OK |  | 0.6006 | 0.0069 | OK |  |  |
| 19 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston) | secondaire | test | exacte | 0.5964 | — | OK |  | 0.5964 | — | OK |  |  |
| 20 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Shapiro-Francia | principale | test | Monte-Carlo (bootstrap parametrique) | 0.6860 | 0.0147 | OK |  | 0.6740 | 0.0066 | OK |  |  |
| 21 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Anderson-Darling | principale | test | Monte-Carlo (bootstrap parametrique) | 0.5660 | 0.0157 | OK |  | 0.5468 | 0.0070 | OK |  |  |
| 22 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Cramer-von Mises | principale | test | Monte-Carlo (bootstrap parametrique) | 0.4760 | 0.0158 | OK |  | 0.4620 | 0.0071 | OK |  |  |
| 23 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Kolmogorov-Smirnov contre N(0,1) | secondaire | test | Monte-Carlo (bootstrap parametrique) | 0.2670 | 0.0140 | OK |  | 0.2408 | 0.0060 | OK |  |  |
| 24 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Lilliefors (KS a parametres estimes) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.2690 | 0.0140 | OK |  | 0.2496 | 0.0061 | OK |  |  |
| 25 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Jarque-Bera | principale | test | Monte-Carlo (bootstrap parametrique) | 0.6740 | 0.0148 | OK |  | 0.6598 | 0.0067 | OK |  |  |
| 26 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Asymetrie (D'Agostino, T >= 8) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.7080 | 0.0303 | OK |  | 0.7108 | 0.0135 | OK |  |  |
| 27 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Aplatissement (Anscombe-Glynn, T >= 20) | principale | non applicable | — | — | — | INFO |  | — | — | INFO |  |  |
| 28 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Autocorrelation d'ordre 1 (Durbin-Watson) | principale | test | exacte | 0.5649 | — | OK |  | 0.5649 | — | OK |  |  |
| 29 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Ljung-Box (retard 1) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9370 | 0.0077 | OK |  | 0.9320 | 0.0036 | OK |  |  |
| 30 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Ljung-Box (retard 2) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.1880 | 0.0124 | OK |  | 0.1944 | 0.0056 | OK |  |  |
| 31 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Box-Pierce (retard 2) | secondaire | test | Monte-Carlo (bootstrap parametrique) | 0.2160 | 0.0130 | OK |  | 0.2272 | 0.0059 | OK |  |  |
| 32 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Test des suites (aleatoire des signes) | principale | test | exacte | 0.7429 | — | OK |  | 0.7429 | — | OK |  |  |
| 33 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Centrage des residus standardises | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 34 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Variance unitaire des residus standardises | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 35 | F. Stabilite, ruptures et points aberrants | Rupture de niveau (sup-F) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.8400 | 0.0116 | OK |  | 0.8534 | 0.0050 | OK |  |  |
| 36 | F. Stabilite, ruptures et points aberrants | Stabilite cumulee (OLS-CUSUM) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.8170 | 0.0122 | OK |  | 0.8240 | 0.0054 | OK |  |  |
| 37 | F. Stabilite, ruptures et points aberrants | Valeur aberrante isolee (Grubbs) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.8610 | 0.0109 | OK |  | 0.8578 | 0.0049 | OK |  |  |
| 38 | F. Stabilite, ruptures et points aberrants | Valeurs aberrantes multiples (ESD generalise) | principale | procedure de decision | — | — | — | OK |  | — | — | OK |  |  |
| 39 | F. Stabilite, ruptures et points aberrants | Points influents (distance de Cook) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 40 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.5660 | 0.0285 | OK |  | 0.5904 | 0.0129 | OK |  |  |
| 41 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Ljung-Box (retard 1) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9960 | 0.0020 | OK |  | 0.9932 | 0.0012 | OK |  |  |
| 42 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Test des suites sur ratios bruts | principale | test | exacte | 0.7429 | — | OK |  | 0.7429 | — | OK |  |  |
| 43 | F. Stabilite, ruptures et points aberrants | Rupture de niveau (sup-F) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9310 | 0.0080 | OK |  | 0.9344 | 0.0035 | OK |  |  |
| 44 | F. Stabilite, ruptures et points aberrants | Stabilite cumulee (OLS-CUSUM) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.7560 | 0.0136 | OK |  | 0.7642 | 0.0060 | OK |  |  |
| 45 | F. Stabilite, ruptures et points aberrants | Valeur aberrante isolee (Grubbs) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.7770 | 0.0132 | OK |  | 0.7696 | 0.0060 | OK |  |  |
| 46 | F. Stabilite, ruptures et points aberrants | Leviers (hat values) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 47 | G. Robustesse de l'estimation | Sensibilite au retrait d'une annee (jackknife) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 48 | G. Robustesse de l'estimation | Largeur relative de l'IC bootstrap 90% | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 49 | G. Robustesse de l'estimation | Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 50 | G. Robustesse de l'estimation | Rapport de vraisemblance : delta = 0 (variance lineaire en volume) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 51 | G. Robustesse de l'estimation | Rapport de vraisemblance : delta = 1 (variance quadratique en volume) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |

#### Cas `premium_net` (graine 20260831)

| # | Famille | Test | Variante | Type | Nature de la p retenue | p (B = 999) | err_mc (B = 999) | Verdict (B = 999) | #244 (B = 999) | p (B = 4 999) | err_mc (B = 4 999) | Verdict (B = 4 999) | #244 (B = 4 999) | Verdict change |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Nullite de la constante (proportionnalite stricte) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9640 | 0.0316 | OK |  | 0.9672 | 0.0141 | OK |  |  |
| 2 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Equivalence de la constante a zero (TOST) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 3 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Test de Pitman sur la pente (lien positif pertes / volume) | principale | test | exacte par permutation (H0 : y independant de x, hors modele reglementaire) | 0.1107 | — | ALERTE |  | 0.1107 | — | ALERTE |  |  |
| 4 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Test de Fisher (significativite globale) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 5 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Coefficient de determination R2 | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 6 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | RESET (forme fonctionnelle) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9960 | 0.0020 | OK |  | 0.9956 | 0.0009 | OK |  |  |
| 7 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Independance ratio S/P vs volume | principale | test | exacte | 0.8820 | — | OK |  | 0.8820 | — | OK |  |  |
| 8 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Correlation ratio S/P vs temps | principale | test | exacte | 0.8401 | — | OK |  | 0.8401 | — | OK |  |  |
| 9 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Tendance monotone du ratio S/P | principale | test | exacte | 0.7195 | — | OK |  | 0.7195 | — | OK |  |  |
| 10 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Tendance par signes du ratio S/P | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 11 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.0180 | 0.0042 | ECHEC |  | 0.0126 | 0.0016 | ECHEC |  |  |
| 12 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | secondaire | test | Monte-Carlo (bootstrap parametrique) | 0.0900 | 0.0091 | ALERTE | oui | 0.0832 | 0.0039 | ALERTE |  |  |
| 13 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Heteroscedasticite (forme quadratique) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.0670 | 0.0079 | ALERTE |  | 0.0610 | 0.0034 | ALERTE |  |  |
| 14 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Egalite des variances petits vs gros volumes | principale | test | Monte-Carlo (bootstrap parametrique) | 0.1900 | 0.0186 | OK |  | 0.1836 | 0.0082 | OK |  |  |
| 15 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Homogeneite des dispersions (mediane) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.1040 | 0.0097 | OK | oui | 0.0964 | 0.0042 | ALERTE | oui | **oui** |
| 16 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Egalite des lois petits vs gros volumes (2 ech.) | principale | test | exacte | 0.7714 | — | OK |  | 0.7714 | — | OK |  |  |
| 17 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Position de delta dans [0,1] | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 18 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Shapiro-Wilk sur residus standardises | principale | test | Monte-Carlo (bootstrap parametrique) | 0.6200 | 0.0154 | OK |  | 0.6006 | 0.0069 | OK |  |  |
| 19 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston) | secondaire | test | exacte | 0.5964 | — | OK |  | 0.5964 | — | OK |  |  |
| 20 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Shapiro-Francia | principale | test | Monte-Carlo (bootstrap parametrique) | 0.6860 | 0.0147 | OK |  | 0.6740 | 0.0066 | OK |  |  |
| 21 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Anderson-Darling | principale | test | Monte-Carlo (bootstrap parametrique) | 0.5660 | 0.0157 | OK |  | 0.5468 | 0.0070 | OK |  |  |
| 22 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Cramer-von Mises | principale | test | Monte-Carlo (bootstrap parametrique) | 0.4760 | 0.0158 | OK |  | 0.4620 | 0.0071 | OK |  |  |
| 23 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Kolmogorov-Smirnov contre N(0,1) | secondaire | test | Monte-Carlo (bootstrap parametrique) | 0.2670 | 0.0140 | OK |  | 0.2408 | 0.0060 | OK |  |  |
| 24 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Lilliefors (KS a parametres estimes) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.2690 | 0.0140 | OK |  | 0.2496 | 0.0061 | OK |  |  |
| 25 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Jarque-Bera | principale | test | Monte-Carlo (bootstrap parametrique) | 0.6740 | 0.0148 | OK |  | 0.6598 | 0.0067 | OK |  |  |
| 26 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Asymetrie (D'Agostino, T >= 8) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.7080 | 0.0303 | OK |  | 0.7108 | 0.0135 | OK |  |  |
| 27 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Aplatissement (Anscombe-Glynn, T >= 20) | principale | non applicable | — | — | — | INFO |  | — | — | INFO |  |  |
| 28 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Autocorrelation d'ordre 1 (Durbin-Watson) | principale | test | exacte | 0.5649 | — | OK |  | 0.5649 | — | OK |  |  |
| 29 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Ljung-Box (retard 1) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9370 | 0.0077 | OK |  | 0.9320 | 0.0036 | OK |  |  |
| 30 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Ljung-Box (retard 2) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.1880 | 0.0124 | OK |  | 0.1944 | 0.0056 | OK |  |  |
| 31 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Box-Pierce (retard 2) | secondaire | test | Monte-Carlo (bootstrap parametrique) | 0.2160 | 0.0130 | OK |  | 0.2272 | 0.0059 | OK |  |  |
| 32 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Test des suites (aleatoire des signes) | principale | test | exacte | 0.7429 | — | OK |  | 0.7429 | — | OK |  |  |
| 33 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Centrage des residus standardises | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 34 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Variance unitaire des residus standardises | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 35 | F. Stabilite, ruptures et points aberrants | Rupture de niveau (sup-F) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.8400 | 0.0116 | OK |  | 0.8534 | 0.0050 | OK |  |  |
| 36 | F. Stabilite, ruptures et points aberrants | Stabilite cumulee (OLS-CUSUM) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.8170 | 0.0122 | OK |  | 0.8240 | 0.0054 | OK |  |  |
| 37 | F. Stabilite, ruptures et points aberrants | Valeur aberrante isolee (Grubbs) | principale | test | Monte-Carlo (bootstrap parametrique) | 0.8610 | 0.0109 | OK |  | 0.8578 | 0.0049 | OK |  |  |
| 38 | F. Stabilite, ruptures et points aberrants | Valeurs aberrantes multiples (ESD generalise) | principale | procedure de decision | — | — | — | OK |  | — | — | OK |  |  |
| 39 | F. Stabilite, ruptures et points aberrants | Points influents (distance de Cook) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 40 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.5660 | 0.0285 | OK |  | 0.5904 | 0.0129 | OK |  |  |
| 41 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Ljung-Box (retard 1) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9960 | 0.0020 | OK |  | 0.9932 | 0.0012 | OK |  |  |
| 42 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Test des suites sur ratios bruts | principale | test | exacte | 0.7429 | — | OK |  | 0.7429 | — | OK |  |  |
| 43 | F. Stabilite, ruptures et points aberrants | Rupture de niveau (sup-F) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.9310 | 0.0080 | OK |  | 0.9344 | 0.0035 | OK |  |  |
| 44 | F. Stabilite, ruptures et points aberrants | Stabilite cumulee (OLS-CUSUM) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.7560 | 0.0136 | OK |  | 0.7642 | 0.0060 | OK |  |  |
| 45 | F. Stabilite, ruptures et points aberrants | Valeur aberrante isolee (Grubbs) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique) | 0.7770 | 0.0132 | OK |  | 0.7696 | 0.0060 | OK |  |  |
| 46 | F. Stabilite, ruptures et points aberrants | Leviers (hat values) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 47 | G. Robustesse de l'estimation | Sensibilite au retrait d'une annee (jackknife) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 48 | G. Robustesse de l'estimation | Largeur relative de l'IC bootstrap 90% | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 49 | G. Robustesse de l'estimation | Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 50 | G. Robustesse de l'estimation | Rapport de vraisemblance : delta = 0 (variance lineaire en volume) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 51 | G. Robustesse de l'estimation | Rapport de vraisemblance : delta = 1 (variance quadratique en volume) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |

#### Cas `premium_interieur` (graine 20260831)

| # | Famille | Test | Variante | Type | Nature de la p retenue | p (B = 999) | err_mc (B = 999) | Verdict (B = 999) | #244 (B = 999) | p (B = 4 999) | err_mc (B = 4 999) | Verdict (B = 4 999) | #244 (B = 4 999) | Verdict change |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Nullite de la constante (proportionnalite stricte) | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.6700 | 0.0299 | OK |  | 0.7172 | 0.0136 | OK |  |  |
| 2 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Equivalence de la constante a zero (TOST) | principale | test | sous le modele auxiliaire pondere : loi de Student (poids estimes), marge estimee sur les donnees | 0.1313 | — | ALERTE |  | 0.1313 | — | ALERTE |  |  |
| 3 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Test de Pitman sur la pente (lien positif pertes / volume) | principale | test | exacte par permutation (H0 : y independant de x, hors modele reglementaire) | 0.0000 | — | OK |  | 0.0000 | — | OK |  |  |
| 4 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Test de Fisher (significativite globale) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 5 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Coefficient de determination R2 | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 6 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | RESET (forme fonctionnelle) | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.9580 | 0.0063 | OK |  | 0.9456 | 0.0032 | OK |  |  |
| 7 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Independance ratio S/P vs volume | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.6900 | 0.0301 | OK |  | 0.7320 | 0.0136 | OK |  |  |
| 8 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Correlation ratio S/P vs temps | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.8660 | 0.0314 | OK |  | 0.8188 | 0.0139 | OK |  |  |
| 9 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Tendance monotone du ratio S/P | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.8300 | 0.0312 | OK |  | 0.8068 | 0.0139 | OK |  |  |
| 10 | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i)) | Tendance par signes du ratio S/P | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 11 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.3770 | 0.0153 | OK |  | 0.3836 | 0.0069 | OK |  |  |
| 12 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | secondaire | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.2710 | 0.0141 | OK |  | 0.2792 | 0.0063 | OK |  |  |
| 13 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Heteroscedasticite (forme quadratique) | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.4290 | 0.0157 | OK |  | 0.4072 | 0.0069 | OK |  |  |
| 14 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Egalite des variances petits vs gros volumes | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.0180 | 0.0060 | ECHEC |  | 0.0248 | 0.0031 | ECHEC |  |  |
| 15 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Homogeneite des dispersions (mediane) | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.4170 | 0.0156 | OK |  | 0.4298 | 0.0070 | OK |  |  |
| 16 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Egalite des lois petits vs gros volumes (2 ech.) | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 1.0000 | 0.0000 | OK |  | 1.0000 | 0.0000 | OK |  |  |
| 17 | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | Position de delta dans [0,1] | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 18 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Shapiro-Wilk sur residus standardises | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.7380 | 0.0139 | OK |  | 0.7352 | 0.0062 | OK |  |  |
| 19 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston) | secondaire | non applicable | — | — | — | INFO |  | — | — | INFO |  |  |
| 20 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Shapiro-Francia | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.6500 | 0.0151 | OK |  | 0.6376 | 0.0068 | OK |  |  |
| 21 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Anderson-Darling | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.7950 | 0.0128 | OK |  | 0.7998 | 0.0057 | OK |  |  |
| 22 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Cramer-von Mises | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.8230 | 0.0121 | OK |  | 0.8346 | 0.0053 | OK |  |  |
| 23 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Kolmogorov-Smirnov contre N(0,1) | secondaire | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.6950 | 0.0146 | OK |  | 0.7124 | 0.0064 | OK |  |  |
| 24 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Lilliefors (KS a parametres estimes) | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.6060 | 0.0155 | OK |  | 0.6180 | 0.0069 | OK |  |  |
| 25 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Jarque-Bera | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.8620 | 0.0109 | OK |  | 0.8686 | 0.0048 | OK |  |  |
| 26 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Asymetrie (D'Agostino, T >= 8) | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.3340 | 0.0236 | OK |  | 0.3236 | 0.0104 | OK |  |  |
| 27 | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | Aplatissement (Anscombe-Glynn, T >= 20) | principale | non applicable | — | — | — | INFO |  | — | — | INFO |  |  |
| 28 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Autocorrelation d'ordre 1 (Durbin-Watson) | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.3900 | 0.0251 | OK |  | 0.4328 | 0.0116 | OK |  |  |
| 29 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Ljung-Box (retard 1) | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.2900 | 0.0144 | OK |  | 0.3004 | 0.0065 | OK |  |  |
| 30 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Ljung-Box (retard 2) | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.2200 | 0.0131 | OK |  | 0.2364 | 0.0060 | OK |  |  |
| 31 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Box-Pierce (retard 2) | secondaire | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.2350 | 0.0134 | OK |  | 0.2454 | 0.0061 | OK |  |  |
| 32 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Test des suites (aleatoire des signes) | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 1.0000 | 0.0316 | OK |  | 1.0000 | 0.0141 | OK |  |  |
| 33 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Centrage des residus standardises | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 34 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Variance unitaire des residus standardises | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 35 | F. Stabilite, ruptures et points aberrants | Rupture de niveau (sup-F) | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.9110 | 0.0090 | OK |  | 0.9064 | 0.0041 | OK |  |  |
| 36 | F. Stabilite, ruptures et points aberrants | Stabilite cumulee (OLS-CUSUM) | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.9540 | 0.0066 | OK |  | 0.9482 | 0.0031 | OK |  |  |
| 37 | F. Stabilite, ruptures et points aberrants | Valeur aberrante isolee (Grubbs) | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.1050 | 0.0097 | OK | oui | 0.0926 | 0.0041 | ALERTE | oui | **oui** |
| 38 | F. Stabilite, ruptures et points aberrants | Valeurs aberrantes multiples (ESD generalise) | principale | procedure de decision | — | — | — | OK |  | — | — | OK |  |  |
| 39 | F. Stabilite, ruptures et points aberrants | Points influents (distance de Cook) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 40 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.3920 | 0.0251 | OK |  | 0.4112 | 0.0114 | OK |  |  |
| 41 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Ljung-Box (retard 1) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.3280 | 0.0149 | OK |  | 0.3226 | 0.0066 | OK |  |  |
| 42 | E. H4 - independance et validite du MV (annexe XVII B(2)(g)(iv)) | Test des suites sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 1.0000 | 0.0316 | OK |  | 1.0000 | 0.0141 | OK |  |  |
| 43 | F. Stabilite, ruptures et points aberrants | Rupture de niveau (sup-F) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.8210 | 0.0121 | OK |  | 0.8186 | 0.0055 | OK |  |  |
| 44 | F. Stabilite, ruptures et points aberrants | Stabilite cumulee (OLS-CUSUM) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.9240 | 0.0084 | OK |  | 0.9282 | 0.0037 | OK |  |  |
| 45 | F. Stabilite, ruptures et points aberrants | Valeur aberrante isolee (Grubbs) sur ratios bruts | principale | test | Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) | 0.2040 | 0.0127 | OK |  | 0.1736 | 0.0054 | OK |  |  |
| 46 | F. Stabilite, ruptures et points aberrants | Leviers (hat values) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 47 | G. Robustesse de l'estimation | Sensibilite au retrait d'une annee (jackknife) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 48 | G. Robustesse de l'estimation | Largeur relative de l'IC bootstrap 90% | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 49 | G. Robustesse de l'estimation | Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 50 | G. Robustesse de l'estimation | Rapport de vraisemblance : delta = 0 (variance lineaire en volume) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |
| 51 | G. Robustesse de l'estimation | Rapport de vraisemblance : delta = 1 (variance quadratique en volume) | principale | diagnostic | — | — | — | INFO |  | — | — | INFO |  |  |

### T3 — Lignes dont le verdict change entre deux B

| Cas | # | Test | Variante | Verdicts | p retenue ± err_mc | Écart au seuil atteignable le plus proche, en err_mc, par B |
|---|---|---|---|---|---|---|
| `premium` | 15 | Homogeneite des dispersions (mediane) | principale | OK (B = 999) → ALERTE (B = 4 999) | 0.1040 ± 0.0097 → 0.0964 ± 0.0042 | 0.41 (s = 0.1) → 0.86 (s = 0.1) |
| `reserve1` | 15 | Homogeneite des dispersions (mediane) | principale | OK (B = 999) → ALERTE (B = 4 999) | 0.1040 ± 0.0097 → 0.0964 ± 0.0042 | 0.41 (s = 0.1) → 0.86 (s = 0.1) |
| `reserve2` | 6 | Heteroscedasticite residuelle vs cumul | principale | OK (B = 999) → OK (B = 4 999) → ALERTE (B = 9 999) | 0.1030 ± 0.0096 → 0.1004 ± 0.0043 → 0.0995 ± 0.0030 | 0.31 (s = 0.1) → 0.09 (s = 0.1) → 0.17 (s = 0.1) |
| `premium_ii6` | 15 | Homogeneite des dispersions (mediane) | principale | OK (B = 999) → ALERTE (B = 4 999) | 0.1040 ± 0.0097 → 0.0964 ± 0.0042 | 0.41 (s = 0.1) → 0.86 (s = 0.1) |
| `premium_net` | 15 | Homogeneite des dispersions (mediane) | principale | OK (B = 999) → ALERTE (B = 4 999) | 0.1040 ± 0.0097 → 0.0964 ± 0.0042 | 0.41 (s = 0.1) → 0.86 (s = 0.1) |
| `premium_interieur` | 37 | Valeur aberrante isolee (Grubbs) | principale | OK (B = 999) → ALERTE (B = 4 999) | 0.1050 ± 0.0097 → 0.0926 ± 0.0041 | 0.52 (s = 0.1) → 1.80 (s = 0.1) |

Écart au seuil : |p − s| / err_mc, s seuil atteignable le plus proche de la règle de #244 (α/2 ou α en sens « ne pas rejeter » ; α ou 0,30 en sens « rejeter »).
Cas aux lignes de tests identiques à chaque B (`identical()` sur test, variante, p, err_mc, verdict, mention #244 ; la famille, qui cite la section B ou C de l'annexe XVII, est exclue) : `premium`, `reserve1`, `premium_ii6`, `premium_net`.
`premium`, `reserve1`, `premium_ii6` et `premium_net` partagent les mêmes données (`.ln$xt`, `.ln$yt`, `CAS` de `tests/outils_tests.R`).
Changements de verdict distincts (même test, variante, suite de verdicts et suite de p) : 3 sur 6 lignes de T3.

Écart avec la revue du 15/10 (PR #296, bloc 5), qui comptait trois lignes de `reserve2` à moins de deux err_mc d'un seuil à B = 999 : cette mesure en compte 2 à B = 999 (mention #244). La troisième, HomogF (ligne 3, p = 0.0800 ± 0.0086), est à 2.33 err_mc de 0.1 et 3.50 err_mc de 0.05 : elle ne remplit pas le critère strict |p − s| < 2 err_mc de #244 (`add()`, `R/engine.R`). La revue du 15/10 comptait cette ligne parmi les lignes à moins de deux erreurs Monte-Carlo du seuil ; le critère strict de #244 posé par le moteur l'exclut (distances ci-dessus). L'origine du compte de la revue n'est pas établie.

### T4 — Autres changements d'état entre deux B (type, inopérant, mention #244, nature de la p)

| Cas | # | Test | Variante | États |
|---|---|---|---|---|
| `premium` | 12 | Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | secondaire | test, #244, Monte-Carlo (bootstrap parametrique) (B = 999) → test, Monte-Carlo (bootstrap parametrique) (B = 4 999) |
| `reserve1` | 12 | Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | secondaire | test, #244, Monte-Carlo (bootstrap parametrique) (B = 999) → test, Monte-Carlo (bootstrap parametrique) (B = 4 999) |
| `reserve2` | 2 | Nullite de l'ordonnee a l'origine, colonne par colonne | principale | test, #244, Monte-Carlo (bootstrap de residus) (B = 999) → test, Monte-Carlo (bootstrap de residus) (B = 4 999) → test, Monte-Carlo (bootstrap de residus) (B = 9 999) |
| `premium_ii6` | 12 | Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | secondaire | test, #244, Monte-Carlo (bootstrap parametrique) (B = 999) → test, Monte-Carlo (bootstrap parametrique) (B = 4 999) |
| `premium_net` | 12 | Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | secondaire | test, #244, Monte-Carlo (bootstrap parametrique) (B = 999) → test, Monte-Carlo (bootstrap parametrique) (B = 4 999) |
