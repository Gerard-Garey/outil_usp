## Issue #43 -- réajustement bootstrap : usp_ajuster_rapide() (R) contre usp_ajuster() (C), candidat R3

### T0 -- en-tête

- Jeux : J1 : tests/donnees/donnees_ln.csv (jeu des cas de reference) ; J2 : xi, yi de tests/unitaires/test_controles_numeriques.R (delta estime interieur)
- B = 999, graine = 20260831 ; seconde passe : automatique (B = 4999, graine = 20260926)
- Générateur (engine_sous_graine()) : Mersenne-Twister, Inversion, Rejection
- R version 4.3.3 (2024-02-29) ; plateforme x86_64-pc-linux-gnu
- md5 de R/engine.R : a7025ea04d2ff0821bdb61b611865363 ; commit e7509f5 (R/engine.R conforme au commit)
- Seuils : TOL_OPTIMUM = 1e-06, TOL_DELTA_BORD = 1e-06 ; S1 0.01, S2 0.01, S3 0.001, S4 0.001

## J1 : tests/donnees/donnees_ln.csv (jeu des cas de reference)

Ajustement observé (C) : δ = 1, γ = -1.934329, σ = 0.1053105, O = -23.03208784.

Contrôle d'intégrité S5 (J1) : OK (identical() avec usp_bootstrap() et run_engine() des quatre cas ; aucun ΔO < −1e-6 ; aucun échec)

### T1 -- J1, B = 999, graine 20260831 : régimes, bornes, échecs, quantiles

| Ajusteur | δ*=0 | int | δ*=1 | γ* sur borne | échecs réajust. | échecs stat. |
| --- | --- | --- | --- | --- | --- | --- |
| R | 46.3 % | 4.6 % | 49.0 % | 0 | 0 | 0 |
| C | 46.3 % | 4.6 % | 49.0 % | 0 | 0 | 0 |
| R3 | 46.3 % | 4.6 % | 49.0 % | 0 | 0 | 0 |

| Ajusteur | Grandeur | q2.5 % | q5 % | q25 % | q50 % | q75 % | q95 % | q97.5 % |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| R | δ* | 0 | 0 | 0 | 0.7487606 | 1 | 1 | 1 |
| C | δ* | 0 | 0 | 0 | 0.7487595 | 1 | 1 | 1 |
| R3 | δ* | 0 | 0 | 0 | 0.7487606 | 1 | 1 | 1 |
| R | γ* | -2.764507 | -2.630804 | -2.265708 | -2.077307 | -1.897294 | -1.65464 | -1.599055 |
| C | γ* | -2.764507 | -2.630804 | -2.265708 | -2.077307 | -1.897294 | -1.65464 | -1.599055 |
| R3 | γ* | -2.764507 | -2.630804 | -2.265708 | -2.077307 | -1.897294 | -1.65464 | -1.599055 |
| R | σ* | 0.04514341 | 0.05115152 | 0.07458065 | 0.09207915 | 0.1098383 | 0.1434641 | 0.1503694 |
| C | σ* | 0.04514341 | 0.05115152 | 0.07458065 | 0.09207916 | 0.1098383 | 0.1434641 | 0.1503694 |
| R3 | σ* | 0.04514341 | 0.05115152 | 0.07458065 | 0.09207915 | 0.1098383 | 0.1434641 | 0.1503694 |

C : n_starts_optimum min / médiane / max = 33 / 54 / 54 ; kkt_au_moins_un FALSE : 0 réplication(s).

### T2 -- J1, B = 999, graine 20260831 : régimes croisés (lignes : ajusteur comparé ; colonnes : C)

| R / C | C : 0 | C : int | C : 1 |
| --- | --- | --- | --- |
| R : 0 | 463 | 0 | 0 |
| R : int | 0 | 46 | 0 |
| R : 1 | 0 | 0 | 490 |

| R3 / C | C : 0 | C : int | C : 1 |
| --- | --- | --- | --- |
| R3 : 0 | 463 | 0 | 0 |
| R3 : int | 0 | 46 | 0 |
| R3 : 1 | 0 | 0 | 490 |

### T3 -- J1, B = 999, graine 20260831 : optimum non atteint (ΔO = O*_X − O*_C > 1e-06)

| Ajusteur | n appariées | k (ΔO > 1e-6) | q_opt | IC 95 % Clopper-Pearson | IC contient 1 % | k (ΔO < −1e-6) |
| --- | --- | --- | --- | --- | --- | --- |
| R | 999 | 0 | 0.0000 | [0.0000 ; 0.0037] | non | 0 |
| R3 | 999 | 0 | 0.0000 | [0.0000 ; 0.0037] | non | 0 |

Réplications concernées :

| Ajusteur X | b | δ*_X | δ*_C | ΔO | abs(Δσ*)/σ*_C | Nature |
| --- | --- | --- | --- | --- | --- | --- |
| aucune |  |  |  |  |  |  |

### T4 -- J1, B = 999, graine 20260831 : composante de tolérance (|ΔO| ≤ 1e-6)

| Ajusteur | n | Grandeur | q50 % | q90 % | max |
| --- | --- | --- | --- | --- | --- |
| R | 999 | abs(Δσ*)/σ*_C | 1.74e-11 | 1.55e-09 | 7.73e-07 |
| R | 999 | abs(Δγ*) | 1.72e-11 | 1.51e-09 | 7.73e-07 |
| R | 999 | abs(Δδ*) | 0 | 0 | 2.48e-05 |
| R3 | 999 | abs(Δσ*)/σ*_C | 1.74e-11 | 1.55e-09 | 7.73e-07 |
| R3 | 999 | abs(Δγ*) | 1.72e-11 | 1.51e-09 | 7.73e-07 |
| R3 | 999 | abs(Δδ*) | 0 | 0 | 2.48e-05 |

Nombre de réplications à abs(Δσ*)/σ*_C > 1e-6 (composante de tolérance) : R 0, R3 0.

### T5 -- J1 : p_mc des 34 statistiques du catalogue

| Stat. | Queue | p_R | p_C | p_R3 | p_C − p_R | p_R3 − p_R | err_mc (R) | granularité (R) | S2 (C) | S2 (R3) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AD | haut | 0.566 | 0.566 | 0.566 | 0 | 0 | 0.0157 | 0.001 | négligeable | négligeable |
| CvM | haut | 0.476 | 0.476 | 0.476 | 0 | 0 | 0.0158 | 0.001 | négligeable | négligeable |
| KS | haut | 0.267 | 0.267 | 0.267 | 0 | 0 | 0.014 | 0.001 | négligeable | négligeable |
| SW | bas | 0.62 | 0.62 | 0.62 | 0 | 0 | 0.0154 | 0.001 | négligeable | négligeable |
| SF | bas | 0.686 | 0.686 | 0.686 | 0 | 0 | 0.0147 | 0.001 | négligeable | négligeable |
| JB | haut | 0.674 | 0.674 | 0.674 | 0 | 0 | 0.0148 | 0.001 | négligeable | négligeable |
| DW | deux | 0.558 | 0.558 | 0.558 | 0 | 0 | 0.0284 | 0.002 | négligeable | négligeable |
| LB1 | haut | 0.937 | 0.937 | 0.937 | 0 | 0 | 0.00769 | 0.001 | négligeable | négligeable |
| supF | haut | 0.84 | 0.84 | 0.84 | 0 | 0 | 0.0116 | 0.001 | négligeable | négligeable |
| CUSUM | haut | 0.817 | 0.817 | 0.817 | 0 | 0 | 0.0122 | 0.001 | négligeable | négligeable |
| Grubbs | haut | 0.861 | 0.861 | 0.861 | 0 | 0 | 0.0109 | 0.001 | négligeable | négligeable |
| Lillie | haut | 0.269 | 0.269 | 0.269 | 0 | 0 | 0.014 | 0.001 | négligeable | négligeable |
| Intercept | deux | 0.964 | 0.964 | 0.964 | 0 | 0 | 0.0316 | 0.002 | négligeable | négligeable |
| RESET | haut | 0.996 | 0.996 | 0.996 | 0 | 0 | 0.002 | 0.001 | négligeable | négligeable |
| BP | haut | 0.018 | 0.018 | 0.018 | 0 | 0 | 0.00421 | 0.001 | négligeable | négligeable |
| BP79 | haut | 0.09 | 0.09 | 0.09 | 0 | 0 | 0.00905 | 0.001 | négligeable | négligeable |
| White | haut | 0.067 | 0.067 | 0.067 | 0 | 0 | 0.00791 | 0.001 | négligeable | négligeable |
| GQ | deux | 0.19 | 0.19 | 0.19 | 0 | 0 | 0.0186 | 0.002 | négligeable | négligeable |
| BF | haut | 0.104 | 0.104 | 0.104 | 0 | 0 | 0.00966 | 0.001 | négligeable | négligeable |
| Smirnov | haut | 0.765 | 0.765 | 0.765 | 0 | 0 | 0.0134 | 0.001 | négligeable | négligeable |
| LB2 | haut | 0.188 | 0.188 | 0.188 | 0 | 0 | 0.0124 | 0.001 | négligeable | négligeable |
| BP2 | haut | 0.216 | 0.216 | 0.216 | 0 | 0 | 0.013 | 0.001 | négligeable | négligeable |
| Runs | deux | 0.762 | 0.762 | 0.762 | 0 | 0 | 0.0307 | 0.002 | négligeable | négligeable |
| MK | deux | 0.758 | 0.758 | 0.758 | 0 | 0 | 0.0307 | 0.002 | négligeable | négligeable |
| SpearVol | deux | 0.878 | 0.878 | 0.878 | 0 | 0 | 0.0314 | 0.002 | négligeable | négligeable |
| SpearTps | deux | 0.872 | 0.872 | 0.872 | 0 | 0 | 0.0314 | 0.002 | négligeable | négligeable |
| DAgo | deux | 0.708 | 0.708 | 0.708 | 0 | 0 | 0.0303 | 0.002 | négligeable | négligeable |
| CoxStuart | haut | 1 | 1 | 1 | 0 | 0 | 0 | 0.001 | négligeable | négligeable |
| DWr | deux | 0.566 | 0.566 | 0.566 | 0 | 0 | 0.0285 | 0.002 | négligeable | négligeable |
| LB1r | haut | 0.996 | 0.996 | 0.996 | 0 | 0 | 0.002 | 0.001 | négligeable | négligeable |
| Runsr | deux | 0.768 | 0.768 | 0.768 | 0 | 0 | 0.0308 | 0.002 | négligeable | négligeable |
| supFr | haut | 0.931 | 0.931 | 0.931 | 0 | 0 | 0.00802 | 0.001 | négligeable | négligeable |
| CUSUMr | haut | 0.756 | 0.756 | 0.756 | 0 | 0 | 0.0136 | 0.001 | négligeable | négligeable |
| Grubbsr | haut | 0.777 | 0.777 | 0.777 | 0 | 0 | 0.0132 | 0.001 | négligeable | négligeable |

max |p_C − p_R| = 0 (AD) ; max |p_R3 − p_R| = 0 ; B effectif R / C / R3 : 999-999 / 999-999 / 999-999.

### T6 -- J1 : lignes de la table des tests dont p_retenue, nature_p ou verdict change

premium, R → C : 0 ligne(s) modifiée(s) sur 51 ; verdicts modifiés : aucun.
premium, R → R3 : 0 ligne(s) modifiée(s) sur 51 ; verdicts modifiés : aucun.
reserve1, R → C : 0 ligne(s) modifiée(s) sur 51 ; verdicts modifiés : aucun.
reserve1, R → R3 : 0 ligne(s) modifiée(s) sur 51 ; verdicts modifiés : aucun.
premium_ii6, R → C : 0 ligne(s) modifiée(s) sur 51 ; verdicts modifiés : aucun.
premium_ii6, R → R3 : 0 ligne(s) modifiée(s) sur 51 ; verdicts modifiés : aucun.
premium_net, R → C : 0 ligne(s) modifiée(s) sur 51 ; verdicts modifiés : aucun.
premium_net, R → R3 : 0 ligne(s) modifiée(s) sur 51 ; verdicts modifiés : aucun.

### T7 -- J1 : IC bootstrap de σ_USP par cas (quantiles 2,5 / 5 / 50 / 95 / 97,5 %)

| Cas | Quantile | R | C | R3 | (C − R)/R | (R3 − R)/R |
| --- | --- | --- | --- | --- | --- | --- |
| premium | 2.5% | 0.07120081 | 0.07120081 | 0.07120081 | -1.07e-12 | 0 |
| premium | 5% | 0.07522022 | 0.07522022 | 0.07522022 | -1.65e-09 | 0 |
| premium | 50% | 0.1026007 | 0.1026007 | 0.1026007 | 4.55e-08 | 0 |
| premium | 95% | 0.1369771 | 0.1369771 | 0.1369771 | 1.93e-11 | 0 |
| premium | 97.5% | 0.1415967 | 0.1415967 | 0.1415967 | 1.93e-10 | 0 |
| reserve1 | 2.5% | 0.06710081 | 0.06710081 | 0.06710081 | -1.14e-12 | 0 |
| reserve1 | 5% | 0.07112022 | 0.07112022 | 0.07112022 | -1.75e-09 | 0 |
| reserve1 | 50% | 0.09850069 | 0.09850069 | 0.09850069 | 4.74e-08 | 0 |
| reserve1 | 95% | 0.1328771 | 0.1328771 | 0.1328771 | 1.99e-11 | 0 |
| reserve1 | 97.5% | 0.1374967 | 0.1374967 | 0.1374967 | 1.99e-10 | 0 |
| premium_ii6 | 2.5% | 0.1081008 | 0.1081008 | 0.1081008 | -7.07e-13 | 0 |
| premium_ii6 | 5% | 0.1121202 | 0.1121202 | 0.1121202 | -1.11e-09 | 0 |
| premium_ii6 | 50% | 0.1395007 | 0.1395007 | 0.1395007 | 3.35e-08 | 0 |
| premium_ii6 | 95% | 0.1738771 | 0.1738771 | 0.1738771 | 1.52e-11 | 0 |
| premium_ii6 | 97.5% | 0.1784967 | 0.1784967 | 0.1784967 | 1.53e-10 | 0 |
| premium_net | 2.5% | 0.06300081 | 0.06300081 | 0.06300081 | -1.21e-12 | 0 |
| premium_net | 5% | 0.06702022 | 0.06702022 | 0.06702022 | -1.85e-09 | 0 |
| premium_net | 50% | 0.09440069 | 0.09440069 | 0.09440069 | 4.95e-08 | 0 |
| premium_net | 95% | 0.1287771 | 0.1287771 | 0.1287771 | 2.05e-11 | 0 |
| premium_net | 97.5% | 0.1333967 | 0.1333967 | 0.1333967 | 2.05e-10 | 0 |

| Cas | largeur_ic R | largeur_ic C | largeur_ic R3 | max abs((C − R)/R) | max abs((R3 − R)/R) | S3 (C) | S3 (R3) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| premium | 0.55411 | 0.55411 | 0.55411 | 4.55e-08 | 0 | aucun | aucun |
| reserve1 | 0.575272 | 0.575272 | 0.575272 | 4.74e-08 | 0 | aucun | aucun |
| premium_ii6 | 0.416285 | 0.416285 | 0.416285 | 3.35e-08 | 0 | aucun | aucun |
| premium_net | 0.598115 | 0.598115 | 0.598115 | 4.95e-08 | 0 | aucun | aucun |

## J2 : xi, yi de tests/unitaires/test_controles_numeriques.R (delta estime interieur)

Ajustement observé (C) : δ = 0.6639907, γ = -2.319987, σ = 0.06895526, O = -28.42362159.

Contrôle d'intégrité S5 (J2) : OK (identical() avec usp_bootstrap() ; aucun ΔO < −1e-6 ; aucun échec)

### T1 -- J2, B = 999, graine 20260831 : régimes, bornes, échecs, quantiles

| Ajusteur | δ*=0 | int | δ*=1 | γ* sur borne | échecs réajust. | échecs stat. |
| --- | --- | --- | --- | --- | --- | --- |
| R | 41.9 % | 20.3 % | 37.7 % | 0 | 0 | 0 |
| C | 41.9 % | 20.3 % | 37.7 % | 0 | 0 | 0 |
| R3 | 41.9 % | 20.3 % | 37.7 % | 0 | 0 | 0 |

| Ajusteur | Grandeur | q2.5 % | q5 % | q25 % | q50 % | q75 % | q95 % | q97.5 % |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| R | δ* | 0 | 0 | 0 | 0.4311889 | 1 | 1 | 1 |
| C | δ* | 0 | 0 | 0 | 0.4311889 | 1 | 1 | 1 |
| R3 | δ* | 0 | 0 | 0 | 0.4311889 | 1 | 1 | 1 |
| R | γ* | -3.179856 | -3.03433 | -2.685299 | -2.482333 | -2.308743 | -2.070889 | -2.00472 |
| C | γ* | -3.179856 | -3.03433 | -2.685299 | -2.482333 | -2.308743 | -2.070889 | -2.00472 |
| R3 | γ* | -3.179856 | -3.03433 | -2.685299 | -2.482333 | -2.308743 | -2.070889 | -2.00472 |
| R | σ* | 0.0286958 | 0.03330061 | 0.04762525 | 0.05850558 | 0.07026811 | 0.08990909 | 0.0963853 |
| C | σ* | 0.0286958 | 0.03330061 | 0.04762525 | 0.05850558 | 0.07026811 | 0.08990909 | 0.0963853 |
| R3 | σ* | 0.0286958 | 0.03330061 | 0.04762525 | 0.05850558 | 0.07026811 | 0.08990909 | 0.0963853 |

C : n_starts_optimum min / médiane / max = 9 / 54 / 54 ; kkt_au_moins_un FALSE : 0 réplication(s).

### T2 -- J2, B = 999, graine 20260831 : régimes croisés (lignes : ajusteur comparé ; colonnes : C)

| R / C | C : 0 | C : int | C : 1 |
| --- | --- | --- | --- |
| R : 0 | 419 | 0 | 0 |
| R : int | 0 | 203 | 0 |
| R : 1 | 0 | 0 | 377 |

| R3 / C | C : 0 | C : int | C : 1 |
| --- | --- | --- | --- |
| R3 : 0 | 419 | 0 | 0 |
| R3 : int | 0 | 203 | 0 |
| R3 : 1 | 0 | 0 | 377 |

### T3 -- J2, B = 999, graine 20260831 : optimum non atteint (ΔO = O*_X − O*_C > 1e-06)

| Ajusteur | n appariées | k (ΔO > 1e-6) | q_opt | IC 95 % Clopper-Pearson | IC contient 1 % | k (ΔO < −1e-6) |
| --- | --- | --- | --- | --- | --- | --- |
| R | 999 | 0 | 0.0000 | [0.0000 ; 0.0037] | non | 0 |
| R3 | 999 | 0 | 0.0000 | [0.0000 ; 0.0037] | non | 0 |

Réplications concernées :

| Ajusteur X | b | δ*_X | δ*_C | ΔO | abs(Δσ*)/σ*_C | Nature |
| --- | --- | --- | --- | --- | --- | --- |
| aucune |  |  |  |  |  |  |

### T4 -- J2, B = 999, graine 20260831 : composante de tolérance (|ΔO| ≤ 1e-6)

| Ajusteur | n | Grandeur | q50 % | q90 % | max |
| --- | --- | --- | --- | --- | --- |
| R | 999 | abs(Δσ*)/σ*_C | 4.75e-11 | 5.67e-09 | 1.65e-06 |
| R | 999 | abs(Δγ*) | 4.7e-11 | 5.72e-09 | 1.64e-06 |
| R | 999 | abs(Δδ*) | 0 | 1.16e-08 | 5.75e-06 |
| R3 | 999 | abs(Δσ*)/σ*_C | 4.75e-11 | 5.67e-09 | 1.65e-06 |
| R3 | 999 | abs(Δγ*) | 4.7e-11 | 5.72e-09 | 1.64e-06 |
| R3 | 999 | abs(Δδ*) | 0 | 1.16e-08 | 5.75e-06 |

Nombre de réplications à abs(Δσ*)/σ*_C > 1e-6 (composante de tolérance) : R 1, R3 1.

### T5 -- J2 : p_mc des 34 statistiques du catalogue

| Stat. | Queue | p_R | p_C | p_R3 | p_C − p_R | p_R3 − p_R | err_mc (R) | granularité (R) | S2 (C) | S2 (R3) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AD | haut | 0.795 | 0.795 | 0.795 | 0 | 0 | 0.0128 | 0.001 | négligeable | négligeable |
| CvM | haut | 0.823 | 0.823 | 0.823 | 0 | 0 | 0.0121 | 0.001 | négligeable | négligeable |
| KS | haut | 0.695 | 0.695 | 0.695 | 0 | 0 | 0.0146 | 0.001 | négligeable | négligeable |
| SW | bas | 0.738 | 0.738 | 0.738 | 0 | 0 | 0.0139 | 0.001 | négligeable | négligeable |
| SF | bas | 0.65 | 0.65 | 0.65 | 0 | 0 | 0.0151 | 0.001 | négligeable | négligeable |
| JB | haut | 0.862 | 0.862 | 0.862 | 0 | 0 | 0.0109 | 0.001 | négligeable | négligeable |
| DW | deux | 0.39 | 0.39 | 0.39 | 0 | 0 | 0.0251 | 0.002 | négligeable | négligeable |
| LB1 | haut | 0.29 | 0.29 | 0.29 | 0 | 0 | 0.0144 | 0.001 | négligeable | négligeable |
| supF | haut | 0.911 | 0.911 | 0.911 | 0 | 0 | 0.00901 | 0.001 | négligeable | négligeable |
| CUSUM | haut | 0.954 | 0.954 | 0.954 | 0 | 0 | 0.00663 | 0.001 | négligeable | négligeable |
| Grubbs | haut | 0.105 | 0.105 | 0.105 | 0 | 0 | 0.0097 | 0.001 | négligeable | négligeable |
| Lillie | haut | 0.606 | 0.606 | 0.606 | 0 | 0 | 0.0155 | 0.001 | négligeable | négligeable |
| Intercept | deux | 0.67 | 0.67 | 0.67 | 0 | 0 | 0.0299 | 0.002 | négligeable | négligeable |
| RESET | haut | 0.958 | 0.958 | 0.958 | 0 | 0 | 0.00635 | 0.001 | négligeable | négligeable |
| BP | haut | 0.377 | 0.377 | 0.377 | 0 | 0 | 0.0153 | 0.001 | négligeable | négligeable |
| BP79 | haut | 0.271 | 0.271 | 0.271 | 0 | 0 | 0.0141 | 0.001 | négligeable | négligeable |
| White | haut | 0.429 | 0.429 | 0.429 | 0 | 0 | 0.0157 | 0.001 | négligeable | négligeable |
| GQ | deux | 0.018 | 0.018 | 0.018 | 0 | 0 | 0.00598 | 0.002 | négligeable | négligeable |
| BF | haut | 0.417 | 0.417 | 0.417 | 0 | 0 | 0.0156 | 0.001 | négligeable | négligeable |
| Smirnov | haut | 1 | 1 | 1 | 0 | 0 | 0 | 0.001 | négligeable | négligeable |
| LB2 | haut | 0.22 | 0.22 | 0.22 | 0 | 0 | 0.0131 | 0.001 | négligeable | négligeable |
| BP2 | haut | 0.235 | 0.235 | 0.235 | 0 | 0 | 0.0134 | 0.001 | négligeable | négligeable |
| Runs | deux | 1 | 1 | 1 | 0 | 0 | 0.0316 | 0.002 | négligeable | négligeable |
| MK | deux | 0.83 | 0.83 | 0.83 | 0 | 0 | 0.0312 | 0.002 | négligeable | négligeable |
| SpearVol | deux | 0.69 | 0.69 | 0.69 | 0 | 0 | 0.0301 | 0.002 | négligeable | négligeable |
| SpearTps | deux | 0.866 | 0.866 | 0.866 | 0 | 0 | 0.0314 | 0.002 | négligeable | négligeable |
| DAgo | deux | 0.334 | 0.334 | 0.334 | 0 | 0 | 0.0236 | 0.002 | négligeable | négligeable |
| CoxStuart | haut | 1 | 1 | 1 | 0 | 0 | 0 | 0.001 | négligeable | négligeable |
| DWr | deux | 0.392 | 0.392 | 0.392 | 0 | 0 | 0.0251 | 0.002 | négligeable | négligeable |
| LB1r | haut | 0.328 | 0.328 | 0.328 | 0 | 0 | 0.0149 | 0.001 | négligeable | négligeable |
| Runsr | deux | 1 | 1 | 1 | 0 | 0 | 0.0316 | 0.002 | négligeable | négligeable |
| supFr | haut | 0.821 | 0.821 | 0.821 | 0 | 0 | 0.0121 | 0.001 | négligeable | négligeable |
| CUSUMr | haut | 0.924 | 0.924 | 0.924 | 0 | 0 | 0.00838 | 0.001 | négligeable | négligeable |
| Grubbsr | haut | 0.204 | 0.204 | 0.204 | 0 | 0 | 0.0127 | 0.001 | négligeable | négligeable |

max |p_C − p_R| = 0 (AD) ; max |p_R3 − p_R| = 0 ; B effectif R / C / R3 : 999-999 / 999-999 / 999-999.

### T8 -- bilan S1 à S5 (repères du protocole ; la conclusion revient à actuary)

| Jeu | Ajusteur | S1 (q_opt, IC 95 %) | S1 seconde passe | S2 (p_mc) | S2 verdicts modifiés | S3 (IC σ_USP) | S4 (tolérance, max abs(Δσ*)/σ*) | S5 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| J1 | R (moteur) contre C | aucun (0/999 ; [0.0000 ; 0.0037]) | — | négligeable (max 0) | 0 | aucun | conforme (7.73e-07) | OK |
| J1 | R3 contre C | aucun (0/999 ; [0.0000 ; 0.0037]) | — | négligeable (max 0) | 0 | aucun | conforme (7.73e-07) | OK |
| J2 | R (moteur) contre C | aucun (0/999 ; [0.0000 ; 0.0037]) | — | négligeable (max 0) | — (J2 : pas de cas) | — | conforme (1.65e-06) | OK |
| J2 | R3 contre C | aucun (0/999 ; [0.0000 ; 0.0037]) | — | négligeable (max 0) | — (J2 : pas de cas) | — | conforme (1.65e-06) | OK |

Colonnes S2 et S3 : écart de la p_mc ou du quantile obtenu avec C (ligne R) ou avec R3 (ligne R3), rapporté à l'ajusteur actuel R.

### Temps d'exécution

| Étape | secondes |
| --- | --- |
| J1 : rejeu B = 999 (R, C, R3) | 69.5 |
| J1 : usp_bootstrap() du moteur | 8.3 |
| J1 : p Monte-Carlo, ajusteur R | 0.1 |
| J1 : p Monte-Carlo, ajusteur C | 0.0 |
| J1 : p Monte-Carlo, ajusteur R3 | 0.0 |
| J1 : run_engine() des quatre cas | 49.7 |
| J2 : rejeu B = 999 (R, C, R3) | 59.4 |
| J2 : usp_bootstrap() du moteur | 15.1 |
| J2 : p Monte-Carlo, ajusteur R | 8.3 |
| J2 : p Monte-Carlo, ajusteur C | 111.6 |
| J2 : p Monte-Carlo, ajusteur R3 | 14.8 |
| total | 338.3 |

