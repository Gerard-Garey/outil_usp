## Puissance du test de Durbin-Watson à T = 8 contre un AR(1) à ρ négatif (#164)

Statut : approximation numérique d'Imhof d'une quantité exacte, recoupée par simulation à ρ = −0,9 et −0,99 ; ρ = −0,999 non recoupé ; sous z i.i.d., hors modèle réglementaire (l'annexe XVII suppose des années indépendantes ; l'AR(1) est une alternative choisie). La grille d'Imhof est déterministe ; seul le recoupement tire, sous une graine consignée en T0.

Cadre : T = 8 ; z gaussien centré, i.i.d. N(0,1) sous H0, AR(1) stationnaire de matrice de covariance (ρ^|i−j|) sous l'alternative ; sans réajustement ; statistique calculée sur la série centrée. Test bilatéral exact de `dw_p_exacte()` (p = 2 min(P0(DW ≤ d), P0(DW ≥ d)), rejet si p < α), puissance par `dw_puissance_ar1(8, ρ, α)`. Variante à départ nul : non calculée (`dw_puissance_ar1()` ne porte que l'AR(1) stationnaire).

### 1. Puissance de DW par ρ

| ρ | 1 − \|ρ\| | Puissance (α = 0,10) | 1 − puissance | Puissance (α = 0,05) | 1 − puissance |
| --- | --- | --- | --- | --- | --- |
| -0,999 | 1,0e-03 | 0,9615 | 0,0385 | 0,9428 | 0,0572 |
| -0,990 | 1,0e-02 | 0,8803 | 0,1197 | 0,8253 | 0,1747 |
| -0,980 | 2,0e-02 | 0,8335 | 0,1665 | 0,7612 | 0,2388 |
| -0,950 | 5,0e-02 | 0,7472 | 0,2528 | 0,6515 | 0,3485 |
| -0,900 | 1,0e-01 | 0,6590 | 0,3410 | 0,5496 | 0,4504 |
| -0,800 | 2,0e-01 | 0,5391 | 0,4609 | 0,4229 | 0,5771 |
| -0,700 | 3,0e-01 | 0,4421 | 0,5579 | 0,3273 | 0,6727 |
| -0,500 | 5,0e-01 | 0,2778 | 0,7222 | 0,1806 | 0,8194 |
| -0,300 | 7,0e-01 | 0,1626 | 0,8374 | 0,0921 | 0,9079 |
| 0 (contrôle de niveau) | — | 0,1000 | 0,9000 | 0,0500 | 0,9500 |

« 1 − puissance » : déficit de puissance, la quantité qui tend vers 0 quand ρ → −1. Le moteur refuse ρ < −1 + 10^−6 (garde de `dw_puissance_ar1()`) ; le point le plus proche de −1 de la grille est à 1 − |ρ| = 10^−3.

### 2. Recoupement par simulation (indépendant d'Imhof pour l'alternative)

N = 400000 séries AR(1) stationnaires à T = 8 par ρ (z_1 = e_1, z_t = ρ z_{t−1} + √(1 − ρ²) e_t, mêmes innovations pour tous les ρ), graine 20261031 sous `engine_sous_graine()`, générateur Mersenne-Twister, Inversion, Rejection. Statistique DW sur la série centrée (formule matricielle, contrôle S0 contre `stat_dw()`) ; points critiques bilatéraux de la loi nulle exacte (copie déclarée du calcul de `dw_puissance_ar1()`, contrôle S1 contre `dw_p_exacte()`). Erreur-type = sqrt(p(1 − p)/N) avec p la valeur d'Imhof (au plus 7,9e-04 ici, soit ≤ 10^−3). ρ = 0 : niveau (valeur de référence α). ρ = −0,999 n'est pas recoupé.

| ρ | α | Imhof (grille) | Simulé ± erreur-type | Simulé − Imhof | Écart en erreurs-types |
| --- | --- | --- | --- | --- | --- |
| 0,00 | 0,10 | 0,10000 | 0,09951 ± 0,00047 | -0,00049 | -1,03 |
| 0,00 | 0,05 | 0,05000 | 0,04961 ± 0,00034 | -0,00039 | -1,12 |
| -0,90 | 0,10 | 0,65896 | 0,65767 ± 0,00075 | -0,00130 | -1,73 |
| -0,90 | 0,05 | 0,54957 | 0,54833 ± 0,00079 | -0,00124 | -1,58 |
| -0,99 | 0,10 | 0,88031 | 0,87980 ± 0,00051 | -0,00050 | -0,98 |
| -0,99 | 0,05 | 0,82533 | 0,82484 ± 0,00060 | -0,00049 | -0,81 |

### Contrôles

| Id | Contrôle | Obtenu | Attendu | Écart | Tolérance | Statut |
| --- | --- | --- | --- | --- | --- | --- |
| D1 | déterminisme : second appel de dw_puissance_ar1(8, -0,99, 0,10) contre la valeur de la grille (écart) | 0,000000 | 0,000000 | 0,000000 | 0,000000 | OK |
| N-a0,10 | niveau : puissance à ρ = 0 contre α = 0,10 | 0,100000 | 0,100000 | -2,2e-14 | 1,0e-08 | OK |
| M-a0,10 | constat sur la grille à T = 8 (non garanti en général) : paires voisines (\|ρ\| croissant, ρ = 0 compris) où la puissance ne croît pas, α = 0,10 | 0,000000 | 0,000000 | 0,000000 | 0,000000 | OK |
| B-a0,10 | constat sur la grille à T = 8 (non garanti en général) : points ρ < 0 où la puissance ne dépasse pas α = 0,10 | 0,000000 | 0,000000 | 0,000000 | 0,000000 | OK |
| N-a0,05 | niveau : puissance à ρ = 0 contre α = 0,05 | 0,050000 | 0,050000 | -7,7e-14 | 1,0e-08 | OK |
| M-a0,05 | constat sur la grille à T = 8 (non garanti en général) : paires voisines (\|ρ\| croissant, ρ = 0 compris) où la puissance ne croît pas, α = 0,05 | 0,000000 | 0,000000 | 0,000000 | 0,000000 | OK |
| B-a0,05 | constat sur la grille à T = 8 (non garanti en général) : points ρ < 0 où la puissance ne dépasse pas α = 0,05 | 0,000000 | 0,000000 | 0,000000 | 0,000000 | OK |
| L-0,5 | dw_puissance_ar1(8, -0,5, 0,10) contre 0,277840 (test_lois_exactes.R, fiche DW, #116) | 0,277840 | 0,277840 | -2,4e-07 | 1,0e-06 | OK |
| L-0,3 | dw_puissance_ar1(8, -0,3, 0,10) contre 0,163 (mesure_lb1_dw_t8.R, 20261020-mesure-lb1-dw-t8.md) | 0,162575 | 0,163000 | -4,2e-04 | 5,0e-04 | OK |
| L-0,6 | dw_puissance_ar1(8, -0,6, 0,10) contre 0,355 (mesure_lb1_dw_t8.R, 20261020-mesure-lb1-dw-t8.md) | 0,355031 | 0,355000 | 3,1e-05 | 5,0e-04 | OK |
| S0 | statistique DW matricielle contre stat_dw() du moteur, 100 séries simulées (écart max) | 0,000000 | 0,000000 | 0,000000 | 1,0e-12 | OK |
| S1-a0,10 | région critique de DW contre dw_p_exacte() < α = 0,10, 100 séries × 3 ρ (désaccords) | 0,000000 | 0,000000 | 0,000000 | 0,000000 | OK |
| S1-a0,05 | région critique de DW contre dw_p_exacte() < α = 0,05, 100 séries × 3 ρ (désaccords) | 0,000000 | 0,000000 | 0,000000 | 0,000000 | OK |
| S-r0,00-a0,10 | puissance simulée (N = 400000) contre Imhof, ρ = 0,00, α = 0,10 (3 erreurs-types) | 0,099510 | 0,100000 | -4,9e-04 | 0,001423 | OK |
| S-r0,00-a0,05 | puissance simulée (N = 400000) contre Imhof, ρ = 0,00, α = 0,05 (3 erreurs-types) | 0,049612 | 0,050000 | -3,9e-04 | 0,001034 | OK |
| S-r-0,90-a0,10 | puissance simulée (N = 400000) contre Imhof, ρ = -0,90, α = 0,10 (3 erreurs-types) | 0,657665 | 0,658962 | -0,001297 | 0,002249 | OK |
| S-r-0,90-a0,05 | puissance simulée (N = 400000) contre Imhof, ρ = -0,90, α = 0,05 (3 erreurs-types) | 0,548333 | 0,549572 | -0,001240 | 0,002360 | OK |
| S-r-0,99-a0,10 | puissance simulée (N = 400000) contre Imhof, ρ = -0,99, α = 0,10 (3 erreurs-types) | 0,879805 | 0,880306 | -5,0e-04 | 0,001540 | OK |
| S-r-0,99-a0,05 | puissance simulée (N = 400000) contre Imhof, ρ = -0,99, α = 0,05 (3 erreurs-types) | 0,824843 | 0,825331 | -4,9e-04 | 0,001801 | OK |

19 contrôles, 0 en échec.

### T0

| Grandeur | Valeur |
| --- | --- |
| Plateforme de calcul (R, système, machine, BLAS, LAPACK) | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.12.0 ; LAPACK : /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.12.0 (version 3.12.0) |
| Aléa | recoupement simulé seul : engine_sous_graine(20261031), générateur Mersenne-Twister, Inversion, Rejection ; grille d'Imhof sans aléa |
| N (séries simulées par ρ) | 400000 |
| Commit (HEAD) | f3c1c940d95f6786e9ca9787e8f63b35d1ae7ee1 |
| md5 de R/engine.R | 602ab3d1af5e88318321970a4442fc0d |
| Empreintes du code (script exécuté, outils chargés) | tests/mesure_dw_rho_negatif_t8.R 19553700a5e1513959b58904b2d88f44 ; tests/outils_tests.R c4058f4187cba4b08ac553cd159c3616 |
| Appels de dw_puissance_ar1() | 24 (grille : 20 ; contrôles : 4) |
| Script | tests/mesure_dw_rho_negatif_t8.R --ecrire --issue 164 (hors CI ; protocole dans l'en-tête) |

