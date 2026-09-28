## Constats de niveau et de puissance à T = 8 (issue #114)

Paramètres : R=20000 ; R_ks=3000 ; graine=20260927 ; partie=tout ; T=8

| Grandeur | Valeur |
| --- | --- |
| Plateforme | R version 4.3.3 (2024-02-29), Linux |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Commit | 0bf8f6f16d4d2629a4eac372cfac9ec47111388d |
| Script | tests/constats_puissance_t8.R (hors CI ; protocole dans l'en-tête) |

### C1 -- Puissance du test des suites et de Durbin-Watson exact, AR(1) gaussien, T = 8, α = 0,10

Statut : **constat de simulation, hors modèle réglementaire** (l'annexe XVII suppose des années indépendantes ; l'AR(1) est l'alternative choisie pour mesurer la puissance). Tests appliqués à la série par les fonctions du moteur runs_p_exacte() (loi de Swed & Eisenhart, doublement) et dw_p_exacte() (série centrée : résidus de la régression sur la constante ; loi exacte d'Imhof ; p bilatérale par doublement) ; rejet si p < α. Ligne ρ = 0 : niveau (suites : 4/70 = 0,0571 exactement ; DW : 0,10). Colonnes z et Compatible : écart normalisé de deux proportions indépendantes (reproduction, publication sur 20 000 tirages) ; compatible si |z| ≤ 1,96.

Réplications : 20000 par valeur de ρ (innovations communes à tous les ρ et aux deux variantes, graine 20260927).

**C1.a -- variante principale : AR(1) stationnaire** (u_1 = e_1 / √(1 − ρ²))

| ρ | Suites : taux | IC 95 % (C-P) | Publié | z | Compatible | DW exact : taux | IC 95 % (C-P) | Publié | z | Compatible |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0,0 | 0,057 | [0,053 ; 0,060] | — | — | — | 0,100 | [0,096 ; 0,104] | — | — | — |
| 0,3 | 0,081 | [0,077 ; 0,085] | 0,080 | +0,33 | oui | 0,159 | [0,154 ; 0,164] | 0,163 | -1,13 | oui |
| 0,5 | 0,120 | [0,115 ; 0,124] | 0,118 | +0,59 | oui | 0,261 | [0,255 ; 0,267] | 0,268 | -1,62 | oui |
| 0,7 | 0,175 | [0,170 ; 0,180] | 0,175 | -0,05 | oui | 0,396 | [0,389 ; 0,402] | 0,395 | +0,13 | oui |
| 0,9 | 0,246 | [0,240 ; 0,252] | 0,247 | -0,14 | oui | 0,528 | [0,521 ; 0,535] | 0,529 | -0,24 | oui |

**C1.b -- variante secondaire : départ nul** (u_1 = e_1)

| ρ | Suites : taux | IC 95 % (C-P) | Publié | z | Compatible | DW exact : taux | IC 95 % (C-P) | Publié | z | Compatible |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0,0 | 0,057 | [0,053 ; 0,060] | — | — | — | 0,100 | [0,096 ; 0,104] | — | — | — |
| 0,3 | 0,081 | [0,077 ; 0,085] | 0,080 | +0,26 | oui | 0,155 | [0,151 ; 0,161] | 0,163 | -2,05 | **non** |
| 0,5 | 0,115 | [0,111 ; 0,120] | 0,118 | -0,89 | oui | 0,246 | [0,240 ; 0,252] | 0,268 | -5,13 | **non** |
| 0,7 | 0,157 | [0,152 ; 0,162] | 0,175 | -4,96 | **non** | 0,356 | [0,350 ; 0,363] | 0,395 | -8,00 | **non** |
| 0,9 | 0,221 | [0,215 ; 0,226] | 0,247 | -6,25 | **non** | 0,492 | [0,485 ; 0,499] | 0,529 | -7,47 | **non** |

Durée de C1 : 72 s.

### C2 -- Niveau du Kolmogorov-Smirnov contre N(0,1) à 5 %, T = 8 (« 0 rejet sur 3 000 »)

Statut : constat de simulation du niveau. p-value : formule de Kolmogorov de la ligne de usp_tests() (transcription contrôlée) ; D = stat_ks() du moteur ; rejet si p < 0,05. Le protocole d'origine n'est pas écrit : quatre lectures sont mesurées. Colonne « Compatible » : test exact de Fisher bilatéral sur le tableau 2 × 2 (k, n − k ; 0, 3 000) de la reproduction et du constat publié ; compatible si p ≥ 0,05 (quatre comparaisons non corrigées pour la multiplicité).

| Lecture | Échantillons | Rejets / R | Taux | IC 95 % (C-P) | p Fisher contre 0 / 3 000 | Compatible |
| --- | --- | --- | --- | --- | --- | --- |
| K0 | N(0,1) i.i.d., paramètres CONNUS (référence) | 97 / 3000 | 0,0323 | [0,026 ; 0,039] | 0,0000 | **non** |
| K1 | résidus z de usp_ajuster() sur jeux simulés sous le modèle ajusté à J1 (usp_simuler()) ; π̂ constant dans 1472 / 3000 réajustements | 0 / 3000 | 0,0000 | [0,000 ; 0,001] | 1,0000 | oui |
| K2 | N(0,1) i.i.d. standardisés par moyenne et écart-type empiriques (s en T − 1) | 0 / 3000 | 0,0000 | [0,000 ; 0,001] | 1,0000 | oui |
| K3 | N(0,1) i.i.d. standardisés par moyenne et écart-type du MV (s en T) = z du moteur à π̂ constant | 0 / 3000 | 0,0000 | [0,000 ; 0,001] | 1,0000 | oui |

Réajustements K1 échoués ou non finis (écartés) : 0 / 3000. Graines : K0, K2, K3 20260928 ; K1 20260929.
Convergence des réajustements K1 gardés (inclus dans le taux) : code optim() de l'optimum retenu ≠ 0 dans 25 / 3000 (codes : 52 : 25), dont 0 rejet(s) à 5 % ; aucun démarrage à l'optimum de code 0 dans 0 / 3000 ; démarrages à l'optimum : minimum 24 sur 54.
Plus petite p-value observée : K0 0,0020 ; K1 0,1643 ; K2 0,0947 ; K3 0,0892.
Durée de C2 : 124 s.

### Contrôles d'intégrité

- C1, invariance affine des p exactes (dw_p_exacte(), runs_p_exacte()) : OK
- C1, aucune p-value manquante : OK
- C2, transcription de la p de Kolmogorov et de stat_ks(fit$z) (contre run_engine(), J1) : OK

Durée totale : 200 s.
