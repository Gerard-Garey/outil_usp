## Mesure de Ljung-Box (retard 1) et de Durbin-Watson à T = 8 (Q-D1-Fh-9, #302, #303, #299)

Statut : approximations numériques d'Imhof de quantités exactes (z i.i.d. N(0,1) sous H0, AR(1) gaussien stationnaire sous les alternatives, sans réajustement, même cadre que `dw_puissance_ar1()`), et constats de simulation ; **hors modèle réglementaire** (l'annexe XVII suppose des années indépendantes). Le tableau porte sur les résidus standardisés z_t ; à π̂ variable, la mesure sur les ratios bruts u_t n'est pas chiffrée.

### 1. Moments exacts de ρ̂₁ sous H0

| Grandeur | Forme close (traces) | Quadrature d'Imhof | Simulation (R tirages) | Attendu |
| --- | --- | --- | --- | --- |
| E ρ̂₁ | -0,125000 | -0,125000 | -0,1250 ± 0,0006 | −0,125 (−1/T) |
| Écart-type de ρ̂₁ | 0,283473 | 0,283473 | 0,2841 ± 0,0004 | 0,2835 |

Formes closes : E ρ̂₁ = tr(B)/(T − 1), E ρ̂₁² = (2 tr(B²) + tr(B)²)/((T − 1)(T + 1)), valables parce que ρ̂₁ est indépendant de son dénominateur w'w sous H0. La quadrature recalcule les mêmes moments à partir de la loi de ρ̂₁ donnée par Imhof, sans cette hypothèse (écart forme close − quadrature : -5,6e-10 sur la moyenne, 1,4e-10 sur l'écart-type). Simulation : R = 200000, ± = une erreur Monte-Carlo.

### 2. LB1 calibré exactement : rejet si |ρ̂₁| > c

Q = T(T + 2)ρ̂₁²/(T − 1) ; c tel que P(ρ̂₁ > c) + P(ρ̂₁ < −c) = α sous H0, chaque probabilité par `.imhof_p_sup0()`.

| α | c | Q critique | P(ρ̂₁ > c) | P(ρ̂₁ < −c) | Part des rejets avec ρ̂₁ < 0 | Attendu | Part simulée | Niveau simulé (R tirages) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0,10 | 0,5103 | 2,976 | 0,01002 | 0,08998 | 0,900 | 0,900 | 0,902 | 0,1004 ± 0,0007 |
| 0,05 | 0,5898 | 3,975 | 0,00302 | 0,04698 | 0,940 | 0,940 | 0,938 | 0,0505 ± 0,0005 |

### 3. Puissances sous AR(1) : Durbin-Watson bilatéral exact et LB1 calibré

DW : `dw_puissance_ar1(8, ρ, α)` ; LB1 : Imhof sous N(0, Σ), Σ = (ρ^|i−j|), au seuil c de la section 2. Colonnes "Simulé" : fréquence de rejet sur R = 200000 séries AR(1), ± = une erreur Monte-Carlo binomiale ; colonnes "Attendu" : valeurs de la note d'actuary, données à α = 0,10 seulement (— : sans valeur attendue).

| α | ρ | DW (Imhof) | DW attendu | DW simulé | LB1 (Imhof) | LB1 attendu | LB1 simulé | LB1 − DW |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0,10 | -0,6 | 0,355 | 0,355 | 0,3550 ± 0,0011 | 0,513 | 0,513 | 0,5120 ± 0,0011 | 0,158 |
| 0,10 | -0,3 | 0,163 | 0,163 | 0,1629 ± 0,0008 | 0,242 | 0,242 | 0,2425 ± 0,0010 | 0,079 |
| 0,10 | 0,3 | 0,159 | 0,159 | 0,1607 ± 0,0008 | 0,073 | 0,073 | 0,0740 ± 0,0006 | -0,086 |
| 0,10 | 0,6 | 0,328 | 0,328 | 0,3278 ± 0,0010 | 0,135 | 0,135 | 0,1357 ± 0,0008 | -0,193 |
| 0,05 | -0,6 | 0,247 | — | 0,2472 ± 0,0010 | 0,385 | — | 0,3844 ± 0,0011 | 0,138 |
| 0,05 | -0,3 | 0,092 | — | 0,0928 ± 0,0006 | 0,147 | — | 0,1470 ± 0,0008 | 0,055 |
| 0,05 | 0,3 | 0,089 | — | 0,0901 ± 0,0006 | 0,030 | — | 0,0301 ± 0,0004 | -0,059 |
| 0,05 | 0,6 | 0,223 | — | 0,2231 ± 0,0009 | 0,061 | — | 0,0614 ± 0,0005 | -0,162 |

### 4. Union sous H0 : P(DW rejette ou LB1 rejette)

Simulation, R = 200000 séries z i.i.d. N(0,1), graine 20261020 ; chaque test calibré à son niveau nominal (sections 2 et 3). Erreur Monte-Carlo = sqrt(p(1 − p)/R).

| α | P(DW rejette) | P(LB1 rejette) | P(les deux) | P(union) | Erreur Monte-Carlo | Attendu |
| --- | --- | --- | --- | --- | --- | --- |
| 0,10 | 0,1003 | 0,1004 | 0,0600 | 0,1407 | 0,0008 | 0,141 environ (erreur 0,0008) |
| 0,05 | 0,0503 | 0,0505 | 0,0285 | 0,0723 | 0,0006 | — |

### 5. Contrôles Monte-Carlo de π_env (#299, `usp_puissance_enveloppe_h2()`)

Test invariant le plus puissant entre δ = 1 (Σ0 = I) et δ = 0 (Σ1 = diag(x̄/x_t)), limite des faibles coefficients de variation, simulé directement : rapport SCE MCG(Σ_n)/SCE MCG(Σ_a), seuil k estimé sur R tirages sous H0, puissance sur R autres tirages sous H1 (graine 20261020, deux matrices indépendantes). **R = 2000000 pour cette section** (R = 200000 pour les sections 1 à 4). Sens 1 : H0 : δ = 1 ; sens 2 : H0 : δ = 0. ± = une erreur Monte-Carlo (binomiale, plus seuil k estimé propagé par la pente locale de la puissance en α).

**Trois précisions.** (i) Le maximum des deux sens est biaisé vers le haut, d'au plus 0,56 erreur Monte-Carlo (1/√π pour deux sens indépendants, moins sous corrélation positive), négligeable à R = 2000000. (ii) L'erreur affichée en face de "Simulé max" est celle du sens retenu (le plus grand des deux), non celle du maximum. (iii) Portée : la simulation reproduit le modèle limite du moteur (c → 0, Σ1 = diag(x̄/x_t)) ; elle contrôle donc le calcul d'Imhof de `usp_puissance_enveloppe_h2()`, sans valider l'approximation des faibles coefficients de variation.

| Jeu | α | π_env (moteur) | π_env (commit 484d29a) | Imhof sens 1 | Simulé sens 1 | Imhof sens 2 | Simulé sens 2 | Simulé max | Simulé − moteur |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| J1 | 0,10 | 0,1267 | 0,1267 | 0,1260 | 0,1261 ± 0,0003 | 0,1267 | 0,1266 ± 0,0003 | 0,1266 ± 0,0003 | -0,0001 |
| J1 | 0,05 | 0,0658 | 0,0658 | 0,0652 | 0,0653 ± 0,0003 | 0,0658 | 0,0656 ± 0,0003 | 0,0656 ± 0,0003 | -0,0002 |
| J2 | 0,10 | 0,3433 | 0,3433 | 0,3242 | 0,3239 ± 0,0006 | 0,3433 | 0,3434 ± 0,0005 | 0,3434 ± 0,0005 | 0,0001 |
| J2 | 0,05 | 0,2227 | 0,2227 | 0,2016 | 0,2012 ± 0,0005 | 0,2227 | 0,2224 ± 0,0005 | 0,2224 ± 0,0005 | -0,0003 |

**Décroissance de π_env en c : non chiffrée (aucun argument c).** `usp_puissance_enveloppe_h2(x, alpha)` n'expose que la limite c → 0 : calculer la puissance à c fini demanderait de réécrire le modèle (traitement du terme de moyenne −1/2 ln(1 + c a_t), qui sort du groupe d'invariance), ce que ce script n'invente pas.

### Contrôles

| Id | Contrôle | Obtenu | Attendu | Écart | Tolérance | Statut |
| --- | --- | --- | --- | --- | --- | --- |
| I1 | Q = T(T+2) rho_1^2/(T-1) contre stats::Box.test(lag = 1, Ljung-Box), 100 séries (écart max) | 1,3e-15 | 0,00000 | 1,3e-15 | 1,0e-10 | OK |
| I2 | DW matriciel contre stat_dw() du moteur, 100 séries (écart max) | 0,00000 | 0,00000 | 0,00000 | 1,0e-12 | OK |
| I3 | Région critique de DW [d_bas, d_haut] contre dw_p_exacte() < alpha, 300 séries × 2 seuils (nombre de désaccords) | 0,00000 | 0,00000 | 0,00000 | 0,00000 | OK |
| M1a | E ρ̂₁ (forme close) contre -1/T | -0,12500 | -0,12500 | 0,00000 | 1,0e-12 | OK |
| M1b | écart-type de ρ̂₁ (forme close) contre la valeur attendue 0,2835 | 0,28347 | 0,28350 | -2,7e-05 | 5,0e-05 | OK |
| M1c | E ρ̂₁ : forme close contre quadrature d'Imhof (indépendance de ρ̂₁ et de son dénominateur, vérifiée numériquement) | -0,12500 | -0,12500 | -5,6e-10 | 1,0e-06 | OK |
| M1d | écart-type de ρ̂₁ : forme close contre quadrature d'Imhof | 0,28347 | 0,28347 | 1,4e-10 | 1,0e-06 | OK |
| M1e | E ρ̂₁ simulée contre -1/T (3 erreurs Monte-Carlo) | -0,12504 | -0,12500 | -3,9e-05 | 0,00191 | OK |
| M1f | écart-type simulé de ρ̂₁ contre la forme close (3 erreurs Monte-Carlo) | 0,28410 | 0,28347 | 6,2e-04 | 0,00117 | OK |
| M2-a0,10-niveau | niveau de LB1 calibré simulé contre alpha = 0,10 (3 erreurs Monte-Carlo) | 0,10043 | 0,10000 | 4,2e-04 | 0,00201 | OK |
| M2-a0,10-part | part des rejets de LB1 avec ρ̂₁ < 0 à alpha = 0,10 | 0,89984 | 0,90000 | -1,6e-04 | 5,0e-04 | OK |
| M2-a0,05-niveau | niveau de LB1 calibré simulé contre alpha = 0,05 (3 erreurs Monte-Carlo) | 0,05051 | 0,05000 | 5,1e-04 | 0,00146 | OK |
| M2-a0,05-part | part des rejets de LB1 avec ρ̂₁ < 0 à alpha = 0,05 | 0,93959 | 0,94000 | -4,1e-04 | 5,0e-04 | OK |
| M3-a0,10-r-0,6-LB1sim | puissance de LB1 simulée contre Imhof (rho = -0,6, alpha = 0,10 ; 3 erreurs Monte-Carlo) | 0,51197 | 0,51259 | -6,2e-04 | 0,00335 | OK |
| M3-a0,10-r-0,6-DWsim | puissance de DW simulée contre dw_puissance_ar1() (rho = -0,6, alpha = 0,10 ; 3 erreurs Monte-Carlo) | 0,35505 | 0,35503 | 1,9e-05 | 0,00321 | OK |
| M3-a0,10-r-0,6-DW | puissance de DW, dw_puissance_ar1(8, -0,6, 0,10), contre la valeur attendue | 0,35503 | 0,35500 | 3,1e-05 | 5,0e-04 | OK |
| M3-a0,10-r-0,6-LB1 | puissance de LB1 par Imhof (rho = -0,6, alpha = 0,10) contre la valeur attendue | 0,51259 | 0,51300 | -4,1e-04 | 5,0e-04 | OK |
| M3-a0,10-r-0,3-LB1sim | puissance de LB1 simulée contre Imhof (rho = -0,3, alpha = 0,10 ; 3 erreurs Monte-Carlo) | 0,24247 | 0,24155 | 9,2e-04 | 0,00287 | OK |
| M3-a0,10-r-0,3-DWsim | puissance de DW simulée contre dw_puissance_ar1() (rho = -0,3, alpha = 0,10 ; 3 erreurs Monte-Carlo) | 0,16289 | 0,16258 | 3,1e-04 | 0,00248 | OK |
| M3-a0,10-r-0,3-DW | puissance de DW, dw_puissance_ar1(8, -0,3, 0,10), contre la valeur attendue | 0,16258 | 0,16300 | -4,2e-04 | 5,0e-04 | OK |
| M3-a0,10-r-0,3-LB1 | puissance de LB1 par Imhof (rho = -0,3, alpha = 0,10) contre la valeur attendue | 0,24155 | 0,24200 | -4,5e-04 | 5,0e-04 | OK |
| M3-a0,10-r0,3-LB1sim | puissance de LB1 simulée contre Imhof (rho = 0,3, alpha = 0,10 ; 3 erreurs Monte-Carlo) | 0,07397 | 0,07301 | 9,6e-04 | 0,00175 | OK |
| M3-a0,10-r0,3-DWsim | puissance de DW simulée contre dw_puissance_ar1() (rho = 0,3, alpha = 0,10 ; 3 erreurs Monte-Carlo) | 0,16070 | 0,15927 | 0,00143 | 0,00245 | OK |
| M3-a0,10-r0,3-DW | puissance de DW, dw_puissance_ar1(8, 0,3, 0,10), contre la valeur attendue | 0,15927 | 0,15900 | 2,7e-04 | 5,0e-04 | OK |
| M3-a0,10-r0,3-LB1 | puissance de LB1 par Imhof (rho = 0,3, alpha = 0,10) contre la valeur attendue | 0,07301 | 0,07300 | 1,4e-05 | 5,0e-04 | OK |
| M3-a0,10-r0,6-LB1sim | puissance de LB1 simulée contre Imhof (rho = 0,6, alpha = 0,10 ; 3 erreurs Monte-Carlo) | 0,13570 | 0,13524 | 4,7e-04 | 0,00229 | OK |
| M3-a0,10-r0,6-DWsim | puissance de DW simulée contre dw_puissance_ar1() (rho = 0,6, alpha = 0,10 ; 3 erreurs Monte-Carlo) | 0,32776 | 0,32806 | -3,0e-04 | 0,00315 | OK |
| M3-a0,10-r0,6-DW | puissance de DW, dw_puissance_ar1(8, 0,6, 0,10), contre la valeur attendue | 0,32806 | 0,32800 | 6,2e-05 | 5,0e-04 | OK |
| M3-a0,10-r0,6-LB1 | puissance de LB1 par Imhof (rho = 0,6, alpha = 0,10) contre la valeur attendue | 0,13524 | 0,13500 | 2,4e-04 | 5,0e-04 | OK |
| M3-a0,05-r-0,6-LB1sim | puissance de LB1 simulée contre Imhof (rho = -0,6, alpha = 0,05 ; 3 erreurs Monte-Carlo) | 0,38440 | 0,38516 | -7,6e-04 | 0,00326 | OK |
| M3-a0,05-r-0,6-DWsim | puissance de DW simulée contre dw_puissance_ar1() (rho = -0,6, alpha = 0,05 ; 3 erreurs Monte-Carlo) | 0,24720 | 0,24691 | 2,9e-04 | 0,00289 | OK |
| M3-a0,05-r-0,3-LB1sim | puissance de LB1 simulée contre Imhof (rho = -0,3, alpha = 0,05 ; 3 erreurs Monte-Carlo) | 0,14698 | 0,14719 | -2,1e-04 | 0,00238 | OK |
| M3-a0,05-r-0,3-DWsim | puissance de DW simulée contre dw_puissance_ar1() (rho = -0,3, alpha = 0,05 ; 3 erreurs Monte-Carlo) | 0,09283 | 0,09206 | 7,6e-04 | 0,00194 | OK |
| M3-a0,05-r0,3-LB1sim | puissance de LB1 simulée contre Imhof (rho = 0,3, alpha = 0,05 ; 3 erreurs Monte-Carlo) | 0,03010 | 0,02997 | 1,3e-04 | 0,00114 | OK |
| M3-a0,05-r0,3-DWsim | puissance de DW simulée contre dw_puissance_ar1() (rho = 0,3, alpha = 0,05 ; 3 erreurs Monte-Carlo) | 0,09006 | 0,08944 | 6,2e-04 | 0,00191 | OK |
| M3-a0,05-r0,6-LB1sim | puissance de LB1 simulée contre Imhof (rho = 0,6, alpha = 0,05 ; 3 erreurs Monte-Carlo) | 0,06137 | 0,06058 | 7,9e-04 | 0,00160 | OK |
| M3-a0,05-r0,6-DWsim | puissance de DW simulée contre dw_puissance_ar1() (rho = 0,6, alpha = 0,05 ; 3 erreurs Monte-Carlo) | 0,22311 | 0,22267 | 4,4e-04 | 0,00279 | OK |
| M4-a0,10-DW | niveau de DW simulé contre alpha = 0,10 (3 erreurs Monte-Carlo) | 0,10027 | 0,10000 | 2,7e-04 | 0,00201 | OK |
| M4-a0,10-union | P(DW rejette ou LB1 rejette) à alpha = 0,10 contre 0,141 (3 erreurs Monte-Carlo + 5e-4 d'arrondi de la valeur attendue) | 0,14069 | 0,14100 | -3,0e-04 | 0,00283 | OK |
| M4-a0,05-DW | niveau de DW simulé contre alpha = 0,05 (3 erreurs Monte-Carlo) | 0,05031 | 0,05000 | 3,0e-04 | 0,00146 | OK |
| E0 | J2 (xi de test_controles_numeriques.R) = xt de donnees_ln_interieur.csv (all.equal, nombre de désaccords) | 0,00000 | 0,00000 | 0,00000 | 0,00000 | OK |
| P5-J1-a0,10-copie | π_env, J1, alpha = 0,10 : maximum des deux sens d'Imhof (copie de sens()) contre le moteur | 0,12672 | 0,12672 | 0,00000 | 1,0e-09 | OK |
| P5-J1-a0,10-mc1 | π_env, J1, alpha = 0,10 : sens 1 (H0 : delta = 1) simulé contre Imhof (3 erreurs Monte-Carlo) | 0,12606 | 0,12598 | 8,5e-05 | 0,00103 | OK |
| P5-J1-a0,10-mc2 | π_env, J1, alpha = 0,10 : sens 2 (H0 : delta = 0) simulé contre Imhof (3 erreurs Monte-Carlo) | 0,12659 | 0,12672 | -1,3e-04 | 0,00104 | OK |
| P5-J1-a0,10-val | π_env, J1, alpha = 0,10 : π_env du moteur contre la valeur du message du commit 484d29a | 0,12672 | 0,12670 | 2,1e-05 | 5,0e-05 | OK |
| P5-J1-a0,10-mc | π_env, J1, alpha = 0,10 : π_env du moteur contre la simulation directe (max des deux sens ; 3 erreurs Monte-Carlo) | 0,12659 | 0,12672 | -1,3e-04 | 0,00104 | OK |
| P5-J1-a0,05-copie | π_env, J1, alpha = 0,05 : maximum des deux sens d'Imhof (copie de sens()) contre le moteur | 0,06580 | 0,06580 | 0,00000 | 1,0e-09 | OK |
| P5-J1-a0,05-mc1 | π_env, J1, alpha = 0,05 : sens 1 (H0 : delta = 1) simulé contre Imhof (3 erreurs Monte-Carlo) | 0,06531 | 0,06525 | 6,2e-05 | 7,8e-04 | OK |
| P5-J1-a0,05-mc2 | π_env, J1, alpha = 0,05 : sens 2 (H0 : delta = 0) simulé contre Imhof (3 erreurs Monte-Carlo) | 0,06557 | 0,06580 | -2,3e-04 | 7,8e-04 | OK |
| P5-J1-a0,05-val | π_env, J1, alpha = 0,05 : π_env du moteur contre la valeur du message du commit 484d29a | 0,06580 | 0,06580 | 4,4e-06 | 5,0e-05 | OK |
| P5-J1-a0,05-mc | π_env, J1, alpha = 0,05 : π_env du moteur contre la simulation directe (max des deux sens ; 3 erreurs Monte-Carlo) | 0,06557 | 0,06580 | -2,3e-04 | 7,8e-04 | OK |
| P5-J2-a0,10-copie | π_env, J2, alpha = 0,10 : maximum des deux sens d'Imhof (copie de sens()) contre le moteur | 0,34328 | 0,34328 | 0,00000 | 1,0e-09 | OK |
| P5-J2-a0,10-mc1 | π_env, J2, alpha = 0,10 : sens 1 (H0 : delta = 1) simulé contre Imhof (3 erreurs Monte-Carlo) | 0,32394 | 0,32424 | -3,0e-04 | 0,00167 | OK |
| P5-J2-a0,10-mc2 | π_env, J2, alpha = 0,10 : sens 2 (H0 : delta = 0) simulé contre Imhof (3 erreurs Monte-Carlo) | 0,34337 | 0,34328 | 9,3e-05 | 0,00165 | OK |
| P5-J2-a0,10-val | π_env, J2, alpha = 0,10 : π_env du moteur contre la valeur du message du commit 484d29a | 0,34328 | 0,34330 | -2,4e-05 | 5,0e-05 | OK |
| P5-J2-a0,10-mc | π_env, J2, alpha = 0,10 : π_env du moteur contre la simulation directe (max des deux sens ; 3 erreurs Monte-Carlo) | 0,34337 | 0,34328 | 9,3e-05 | 0,00165 | OK |
| P5-J2-a0,05-copie | π_env, J2, alpha = 0,05 : maximum des deux sens d'Imhof (copie de sens()) contre le moteur | 0,22268 | 0,22268 | 0,00000 | 1,0e-09 | OK |
| P5-J2-a0,05-mc1 | π_env, J2, alpha = 0,05 : sens 1 (H0 : delta = 1) simulé contre Imhof (3 erreurs Monte-Carlo) | 0,20123 | 0,20155 | -3,2e-04 | 0,00158 | OK |
| P5-J2-a0,05-mc2 | π_env, J2, alpha = 0,05 : sens 2 (H0 : delta = 0) simulé contre Imhof (3 erreurs Monte-Carlo) | 0,22238 | 0,22268 | -3,0e-04 | 0,00160 | OK |
| P5-J2-a0,05-val | π_env, J2, alpha = 0,05 : π_env du moteur contre la valeur du message du commit 484d29a | 0,22268 | 0,22270 | -1,7e-05 | 5,0e-05 | OK |
| P5-J2-a0,05-mc | π_env, J2, alpha = 0,05 : π_env du moteur contre la simulation directe (max des deux sens ; 3 erreurs Monte-Carlo) | 0,22238 | 0,22268 | -3,0e-04 | 0,00160 | OK |

61 contrôles, 0 en échec.

### T0

| Grandeur | Valeur |
| --- | --- |
| Plateforme de calcul (R, système, machine, BLAS, LAPACK) | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.12.0 ; LAPACK : /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.12.0 (version 3.12.0) |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Graine (engine_sous_graine()) | 20261020 |
| R, sections 1 à 4 (séries simulées) | 200000 |
| R, section 5 (tirages par matrice, deux matrices) | 2000000 |
| Commit (HEAD) | 84b14c5cc6b012058e58ef0b2ebae8d53d431a7b |
| md5 de R/engine.R | 25f32b4fcc11f918821bef11d72be1e9 |
| Empreintes du code (script exécuté, outils chargés) | tests/mesure_lb1_dw_t8.R 5c51056199dbdb4651e7ffff1505b869 ; tests/outils_tests.R 7127605f20e8c261d41d3c372f4f2f1b |
| Script | tests/mesure_lb1_dw_t8.R --ecrire (hors CI ; protocole dans l'en-tête) |

