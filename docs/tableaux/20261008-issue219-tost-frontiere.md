## Constats de niveau et de puissance à T = 8 (issue #219)

Paramètres : R=20000 ; graine=20260927 ; partie=tost-frontiere ; T=8

| Grandeur | Valeur |
| --- | --- |
| Plateforme de calcul (R, système, machine, BLAS, LAPACK) | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.12.0 ; LAPACK : /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.12.0 (version 3.12.0) |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Commit | fce81c18a498da3f8535f2ff516696b27b4066f2 |
| Script | tests/constats_puissance_t8.R --partie tost-frontiere (hors CI ; protocole dans l'en-tête) |

### C5 -- TOST de la constante : niveau à la frontière a = ±Δ, T = 8 (issue #219)

Statut : **constat de simulation** du taux de conclusion **à tort** à l'équivalence quand la constante vraie vaut ±Δ, Δ = θ E[Ȳ], θ = 0,10. Générateur : Y*_t = a + L*_t, L* = usp_simuler(FIT0), FIT0 = usp_ajuster() sur le jeu observé (x fixe) : E[Y_t] = a + βx_t et variance réglementaire exacte. a₊ = θβx̄/(1 − θ) et a₋ = −θβx̄/(1 + θ) placent a sur ±θ E[Ȳ]. Chaque y* est réajusté par usp_ajuster() ; refus de #188 (usp_valider_ajustement()), erreurs et y* ≤ 0 écartés et comptés ; le taux porte sur les réplications retenues communes aux six cellules ; dans chaque cellule, cas non applicables et erreurs du test retirés du dénominateur et comptés. p = test_tost_intercept(x, y*, π, θ = 0,10[, delta_abs]) : poids W1 (outil, fit*$pi), W2 (oracle, FIT0$pi), W0 (poids constants : TOST MCO d'avant #215) ; marge estimée Δ* = θȳ* (celle de l'outil) ou fixée a priori, delta_abs = θ E[Ȳ] = θ(a + βx̄). Conclusion si p < α. Lecture (spécification d'actuary, #175, commentaire 6058041254) : tenu si la borne basse de l'IC ≤ α ; dépassement mineur si l'IC est au-dessus de α et l'estimation ≤ 1,5α ; distorsion matérielle si la borne basse > 1,5α ; dépassement non tranché (classe ajoutée par le mainteneur, PR #228, commentaire 6062485163) si la borne basse est dans ]α ; 1,5α] et l'estimation > 1,5α : dépassement significatif, matérialité non établie à R donné. Suites : tenu et dépassement mineur, aucune ; distorsion matérielle et dépassement non tranché, décision du mainteneur, renvoi à #216 et #217. Colonne a = 0 : probabilité de conclure (puissance), non un niveau.

Règle de lecture du dénominateur (même commentaire) : le taux est conditionnel au rendu d'un résultat par l'outil (dénominateur commun = réplications retenues ; comparaisons W0/W1/W2 appariées). Pour un couple (jeu, a) avec e > 0 réplications écartées (y* ≤ 0, erreurs, refus de #188 ; C5.b), la colonne « Classe avec le majorant » vérifie que la classe reste la même avec le taux majorant (k + e)/(n + e) : « classe stable », ou « change avec le majorant » et la classe obtenue ; « e = 0 » sans réplication écartée.

Réplications : 20000 par jeu et par valeur de a (L* communs aux trois valeurs). Graines : flux de C3, J1 20260930 ; J2 20260931.

**C5.a -- Taux de conclusion d'équivalence (p < α), par jeu, valeur de a, poids et marge**

| Jeu | a | Valeur de a | Poids | Marge | Conclusions (α = 0,10) | Taux | IC 95 % (C-P) | Lecture | Classe avec le majorant | Conclusions (α = 0,05) | Taux | IC 95 % (C-P) | Lecture | Classe avec le majorant | Non applicables | Erreurs du test |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| J1 | a₋ = −θβx̄/(1+θ) | -7,7318 | W1 | Δ* = θ · ȳ* | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 | 0 |
| J1 | a₋ = −θβx̄/(1+θ) | -7,7318 | W1 | delta_abs = θ · E[Ȳ] | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 | 0 |
| J1 | a₋ = −θβx̄/(1+θ) | -7,7318 | W2 | Δ* = θ · ȳ* | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 | 0 |
| J1 | a₋ = −θβx̄/(1+θ) | -7,7318 | W2 | delta_abs = θ · E[Ȳ] | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 | 0 |
| J1 | a₋ = −θβx̄/(1+θ) | -7,7318 | W0 | Δ* = θ · ȳ* | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 | 0 |
| J1 | a₋ = −θβx̄/(1+θ) | -7,7318 | W0 | delta_abs = θ · E[Ȳ] | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 | 0 |
| J1 | a₊ = θβx̄/(1−θ) | 9,4500 | W1 | Δ* = θ · ȳ* | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 | 0 |
| J1 | a₊ = θβx̄/(1−θ) | 9,4500 | W1 | delta_abs = θ · E[Ȳ] | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 | 0 |
| J1 | a₊ = θβx̄/(1−θ) | 9,4500 | W2 | Δ* = θ · ȳ* | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 | 0 |
| J1 | a₊ = θβx̄/(1−θ) | 9,4500 | W2 | delta_abs = θ · E[Ȳ] | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 | 0 |
| J1 | a₊ = θβx̄/(1−θ) | 9,4500 | W0 | Δ* = θ · ȳ* | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 | 0 |
| J1 | a₊ = θβx̄/(1−θ) | 9,4500 | W0 | delta_abs = θ · E[Ȳ] | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | tenu | e = 0 | 0 | 0 |
| J1 | a = 0 | 0,0000 | W1 | Δ* = θ · ȳ* | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | puissance (a = 0) | — | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | puissance (a = 0) | — | 0 | 0 |
| J1 | a = 0 | 0,0000 | W1 | delta_abs = θ · E[Ȳ] | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | puissance (a = 0) | — | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | puissance (a = 0) | — | 0 | 0 |
| J1 | a = 0 | 0,0000 | W2 | Δ* = θ · ȳ* | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | puissance (a = 0) | — | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | puissance (a = 0) | — | 0 | 0 |
| J1 | a = 0 | 0,0000 | W2 | delta_abs = θ · E[Ȳ] | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | puissance (a = 0) | — | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | puissance (a = 0) | — | 0 | 0 |
| J1 | a = 0 | 0,0000 | W0 | Δ* = θ · ȳ* | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | puissance (a = 0) | — | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | puissance (a = 0) | — | 0 | 0 |
| J1 | a = 0 | 0,0000 | W0 | delta_abs = θ · E[Ȳ] | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | puissance (a = 0) | — | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | puissance (a = 0) | — | 0 | 0 |
| J2 | a₋ = −θβx̄/(1+θ) | -8,3720 | W1 | Δ* = θ · ȳ* | 1757 / 20000 | 0,0878 | [0,0840 ; 0,0919] | tenu | e = 0 | 656 / 20000 | 0,0328 | [0,0304 ; 0,0354] | tenu | e = 0 | 0 | 0 |
| J2 | a₋ = −θβx̄/(1+θ) | -8,3720 | W1 | delta_abs = θ · E[Ȳ] | 1894 / 20000 | 0,0947 | [0,0907 ; 0,0988] | tenu | e = 0 | 740 / 20000 | 0,0370 | [0,0344 ; 0,0397] | tenu | e = 0 | 0 | 0 |
| J2 | a₋ = −θβx̄/(1+θ) | -8,3720 | W2 | Δ* = θ · ȳ* | 1399 / 20000 | 0,0699 | [0,0665 ; 0,0736] | tenu | e = 0 | 485 / 20000 | 0,0243 | [0,0222 ; 0,0265] | tenu | e = 0 | 0 | 0 |
| J2 | a₋ = −θβx̄/(1+θ) | -8,3720 | W2 | delta_abs = θ · E[Ȳ] | 1500 / 20000 | 0,0750 | [0,0714 ; 0,0787] | tenu | e = 0 | 570 / 20000 | 0,0285 | [0,0262 ; 0,0309] | tenu | e = 0 | 0 | 0 |
| J2 | a₋ = −θβx̄/(1+θ) | -8,3720 | W0 | Δ* = θ · ȳ* | 1171 / 20000 | 0,0585 | [0,0553 ; 0,0619] | tenu | e = 0 | 352 / 20000 | 0,0176 | [0,0158 ; 0,0195] | tenu | e = 0 | 0 | 0 |
| J2 | a₋ = −θβx̄/(1+θ) | -8,3720 | W0 | delta_abs = θ · E[Ȳ] | 1260 / 20000 | 0,0630 | [0,0597 ; 0,0665] | tenu | e = 0 | 393 / 20000 | 0,0197 | [0,0178 ; 0,0217] | tenu | e = 0 | 0 | 0 |
| J2 | a₊ = θβx̄/(1−θ) | 10,2325 | W1 | Δ* = θ · ȳ* | 2652 / 20000 | 0,1326 | [0,1279 ; 0,1374] | dépassement mineur | e = 0 | 1290 / 20000 | 0,0645 | [0,0611 ; 0,0680] | dépassement mineur | e = 0 | 0 | 0 |
| J2 | a₊ = θβx̄/(1−θ) | 10,2325 | W1 | delta_abs = θ · E[Ȳ] | 2542 / 20000 | 0,1271 | [0,1225 ; 0,1318] | dépassement mineur | e = 0 | 1214 / 20000 | 0,0607 | [0,0574 ; 0,0641] | dépassement mineur | e = 0 | 0 | 0 |
| J2 | a₊ = θβx̄/(1−θ) | 10,2325 | W2 | Δ* = θ · ȳ* | 2105 / 20000 | 0,1052 | [0,1010 ; 0,1096] | dépassement mineur | e = 0 | 980 / 20000 | 0,0490 | [0,0460 ; 0,0521] | tenu | e = 0 | 0 | 0 |
| J2 | a₊ = θβx̄/(1−θ) | 10,2325 | W2 | delta_abs = θ · E[Ȳ] | 2001 / 20000 | 0,1001 | [0,0959 ; 0,1043] | tenu | e = 0 | 928 / 20000 | 0,0464 | [0,0435 ; 0,0494] | tenu | e = 0 | 0 | 0 |
| J2 | a₊ = θβx̄/(1−θ) | 10,2325 | W0 | Δ* = θ · ȳ* | 1831 / 20000 | 0,0916 | [0,0876 ; 0,0956] | tenu | e = 0 | 715 / 20000 | 0,0357 | [0,0332 ; 0,0384] | tenu | e = 0 | 0 | 0 |
| J2 | a₊ = θβx̄/(1−θ) | 10,2325 | W0 | delta_abs = θ · E[Ȳ] | 1743 / 20000 | 0,0872 | [0,0833 ; 0,0911] | tenu | e = 0 | 679 / 20000 | 0,0340 | [0,0315 ; 0,0366] | tenu | e = 0 | 0 | 0 |
| J2 | a = 0 | 0,0000 | W1 | Δ* = θ · ȳ* | 8708 / 20000 | 0,4354 | [0,4285 ; 0,4423] | puissance (a = 0) | — | 4098 / 20000 | 0,2049 | [0,1993 ; 0,2106] | puissance (a = 0) | — | 0 | 0 |
| J2 | a = 0 | 0,0000 | W1 | delta_abs = θ · E[Ȳ] | 8755 / 20000 | 0,4377 | [0,4309 ; 0,4447] | puissance (a = 0) | — | 4175 / 20000 | 0,2087 | [0,2031 ; 0,2144] | puissance (a = 0) | — | 0 | 0 |
| J2 | a = 0 | 0,0000 | W2 | Δ* = θ · ȳ* | 7514 / 20000 | 0,3757 | [0,3690 ; 0,3825] | puissance (a = 0) | — | 3299 / 20000 | 0,1650 | [0,1598 ; 0,1702] | puissance (a = 0) | — | 0 | 0 |
| J2 | a = 0 | 0,0000 | W2 | delta_abs = θ · E[Ȳ] | 7591 / 20000 | 0,3795 | [0,3728 ; 0,3863] | puissance (a = 0) | — | 3380 / 20000 | 0,1690 | [0,1638 ; 0,1743] | puissance (a = 0) | — | 0 | 0 |
| J2 | a = 0 | 0,0000 | W0 | Δ* = θ · ȳ* | 4229 / 20000 | 0,2114 | [0,2058 ; 0,2172] | puissance (a = 0) | — | 1826 / 20000 | 0,0913 | [0,0873 ; 0,0954] | puissance (a = 0) | — | 0 | 0 |
| J2 | a = 0 | 0,0000 | W0 | delta_abs = θ · E[Ȳ] | 4285 / 20000 | 0,2142 | [0,2086 ; 0,2200] | puissance (a = 0) | — | 1882 / 20000 | 0,0941 | [0,0901 ; 0,0982] | puissance (a = 0) | — | 0 | 0 |

**C5.b -- Réplications écartées, par jeu et valeur de a**

| Jeu | a | Valeur de a | Marge a priori θ E[Ȳ] | R | y* ≤ 0 | Erreurs de réajustement | Refus de #188 | Retenues |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| J1 | a₋ = −θβx̄/(1+θ) | -7,7318 | 7,7318 | 20000 | 0 | 0 | 0 | 20000 |
| J1 | a₊ = θβx̄/(1−θ) | 9,4500 | 9,4500 | 20000 | 0 | 0 | 0 | 20000 |
| J1 | a = 0 | 0,0000 | 8,5050 | 20000 | 0 | 0 | 0 | 20000 |
| J2 | a₋ = −θβx̄/(1+θ) | -8,3720 | 8,3720 | 20000 | 0 | 0 | 0 | 20000 |
| J2 | a₊ = θβx̄/(1−θ) | 10,2325 | 10,2325 | 20000 | 0 | 0 | 0 | 20000 |
| J2 | a = 0 | 0,0000 | 9,2092 | 20000 | 0 | 0 | 0 | 20000 |

**C5.c -- a = 0, W1, marge estimée, à la manière de C3** (réajustements réussis, refus de #188 compris ; même flux et même calcul que C3 : égal au tableau C3.a de --partie tost à R et graine égaux)

| Jeu | α | Conclusions / réajustements réussis | Taux | IC 95 % (C-P) | p minimale | Échecs de réajustement ou y* ≤ 0 |
| --- | --- | --- | --- | --- | --- | --- |
| J1 | 0,10 | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | 0,2653 | 0 |
| J1 | 0,05 | 0 / 20000 | 0,0000 | [0,0000 ; 0,0002] | 0,2653 | 0 |
| J2 | 0,10 | 8708 / 20000 | 0,4354 | [0,4285 ; 0,4423] | 5,72e-05 | 0 |
| J2 | 0,05 | 4098 / 20000 | 0,2049 | [0,1993 ; 0,2106] | 5,72e-05 | 0 |

Rapprochement de C5.c avec le tableau C3.a de docs/tableaux/20261007-issue215-tost.md (commit a7724d4 ; J1 0 / 20000 à α = 0,10 et 0,05 ; J2 8708 / 20000 à 0,10 et 4098 / 20000 à 0,05 ; non bloquant) : identique.

Jeux : J1 : tests/donnees/donnees_ln.csv (jeu des cas de référence) ; βx̄ = 85,0503 ; J2 : xi, yi de tests/unitaires/test_controles_numeriques.R ; βx̄ = 92,0925.
Durée de C5 : 7669 s de simulation (0,0639 s par réplication, par jeu et par valeur de a) et 49 s de contrôles (dont run_engine()).

### Contrôles d'intégrité

- C5 J1, W0 : poids usp_poids_gls(x, pi0) constants, max|w/w₁ − 1| < 1e-12 (mesuré : 2.22e-16) : OK
- C5 J1, premier L* du flux identique à un tirage isolé sous la même graine (flux de C3) : OK
- C5 J1, a₋, première p de chaque cellule (réplication 1) = p_asymptotique de la ligne TOST de run_engine() (W1, deux marges) ou TOST transcrit par lm() (W0, W2) : OK
- C5 J1, a₋, conclusion (p < α) équivalente à Δ − |â| > t(1 − α, T − 2) se(â), réplication par réplication : OK
- C5 J1, a₋, marge fixée a priori = θ(a + βx̄) = |a| : OK
- C5 J1, a = 0, première p de chaque cellule (réplication 1) = p_asymptotique de la ligne TOST de run_engine() (W1, deux marges) ou TOST transcrit par lm() (W0, W2) : OK
- C5 J1, a = 0, conclusion (p < α) équivalente à Δ − |â| > t(1 − α, T − 2) se(â), réplication par réplication : OK
- C5 J1, a = 0, marge fixée a priori = θ(a + βx̄) : OK
- C5 J1, a₊, première p de chaque cellule (réplication 1) = p_asymptotique de la ligne TOST de run_engine() (W1, deux marges) ou TOST transcrit par lm() (W0, W2) : OK
- C5 J1, a₊, conclusion (p < α) équivalente à Δ − |â| > t(1 − α, T − 2) se(â), réplication par réplication : OK
- C5 J1, a₊, marge fixée a priori = θ(a + βx̄) = |a| : OK
- C5 J2, W0 : poids usp_poids_gls(x, pi0) constants, max|w/w₁ − 1| < 1e-12 (mesuré : 6.66e-16) : OK
- C5 J2, premier L* du flux identique à un tirage isolé sous la même graine (flux de C3) : OK
- C5 J2, a₋, première p de chaque cellule (réplication 1) = p_asymptotique de la ligne TOST de run_engine() (W1, deux marges) ou TOST transcrit par lm() (W0, W2) : OK
- C5 J2, a₋, conclusion (p < α) équivalente à Δ − |â| > t(1 − α, T − 2) se(â), réplication par réplication : OK
- C5 J2, a₋, marge fixée a priori = θ(a + βx̄) = |a| : OK
- C5 J2, a = 0, première p de chaque cellule (réplication 1) = p_asymptotique de la ligne TOST de run_engine() (W1, deux marges) ou TOST transcrit par lm() (W0, W2) : OK
- C5 J2, a = 0, conclusion (p < α) équivalente à Δ − |â| > t(1 − α, T − 2) se(â), réplication par réplication : OK
- C5 J2, a = 0, marge fixée a priori = θ(a + βx̄) : OK
- C5 J2, a₊, première p de chaque cellule (réplication 1) = p_asymptotique de la ligne TOST de run_engine() (W1, deux marges) ou TOST transcrit par lm() (W0, W2) : OK
- C5 J2, a₊, conclusion (p < α) équivalente à Δ − |â| > t(1 − α, T − 2) se(â), réplication par réplication : OK
- C5 J2, a₊, marge fixée a priori = θ(a + βx̄) = |a| : OK
- C5, RNGkind() et .Random.seed de l'appelant restaurés après les tirages et les contrôles (run_engine() compris) : OK

