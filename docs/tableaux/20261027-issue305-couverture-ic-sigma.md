## Mesure #305 (Fn, étape 3) : couverture à T = 8 de l'intervalle bootstrap de σ, méthode lognormale (J1, J2)

### T0 — provenance

| Grandeur | Valeur |
| --- | --- |
| Spécification | docs/specifications/fn-incertitude-bootstrap.md, par. 2 (décisions Q-D1-Fn-4 à 6 du 27/10/2026) ; md5 c3d475168518d18c39b8dc0fdab59a89 |
| Mode | mesure |
| R par jeu ; B ; niveau | 1000 ; 999 ; L1 |
| Chemin | usp_simuler(fit0) sous engine_sous_graine(G_ext(r)) ; engine_valider_donnees() (premium, brutes, segment 1, annexe II) ; usp_ajuster() ; usp_valider_ajustement(fit, "premium") ; usp_bootstrap(fit, B, seed = G_int(r)) (option (a)) |
| J1 | tests/donnees/donnees_ln.csv ; δ̂ = 1 ; γ̂ = -1.93433 ; β̂ = 0.728685 ; σ0 = 0.10531 |
| J2 | tests/donnees/donnees_ln_interieur.csv ; δ̂ = 0.663991 ; γ̂ = -2.31999 ; β̂ = 0.701657 ; σ0 = 0.0689553 |
| Graines | J1 : G_ext(r) = 305 200 000 + r, G_int(r) = 305 300 000 + r ; J2 : G_ext(r) = 305 250 000 + r, G_int(r) = 305 350 000 + r ; flux complémentaire G_int(r) + 539 169 (usp_graine_flux_regime()) ; plages disjointes vérifiées au chargement |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Intervalles | quantiles de type 7 de σ* (perc_script()) ; I1 [q_α ; q_(1−α)] ; I2 [2σ̂ − q_(1−α) ; 2σ̂ − q_α] ; I3 percentile de σ*_r ; I4 [σ̂²/q_(1−α) ; σ̂²/q_α] ; A1 corr × I1, corr = √((T+1)/(T−1)) ; intervalle formé si plus de 20 valeurs bootstrap |
| SHA, git rev-parse HEAD (début ; fin) | 01ea076b79c3bedf5609fe870583a74357eedd0a ; 01ea076b79c3bedf5609fe870583a74357eedd0a |
| Commit (commit_depot(), au début) | 01ea076b79c3bedf5609fe870583a74357eedd0a |
| md5 R/engine.R (début ; fin) | f304b88eb6b1c1cf475df727ab993893 ; f304b88eb6b1c1cf475df727ab993893 |
| Empreinte sans commentaires de R/engine.R (#231) | 701c6c5042363b9a6597dc548a034e1b |
| Empreintes md5 du code exécuté | R/engine.R f304b88eb6b1c1cf475df727ab993893 ; tests/outils_tests.R chargé (dépôt) 63a27805557d75069137e726102e685c ; script exécuté (dépôt) 0df6f501692843cd802fa7111e164669 |
| Plateforme de calcul | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : libblas.so.3.12.0 ; LAPACK : liblapack.so.3.12.0 (version 3.12.0) |
| Tranches | 20 (taille 100) ; calculées par cette exécution : 2000 jeu(x) simulé(s) en 6631 s d'horloge à 3 processus ; reprises : 0 |
| Durée cumulée par jeu simulé (somme des processus) | 19560 s (9,78 s par jeu) |
| JOURNAL | 20261027-issue305-journal-mesure.md (lancement 2026-10-27T10:21:21Z) |
| Valeurs brutes | 20261027-issue305-couverture-ic-sigma-brut.tsv (une ligne par jeu simulé, %.17g) |
| Versionnable (--ecrire) | oui |
| Contrôles d'intégrité | OK |

### Aide à la lecture

Statut : **constat de simulation sous les modèles ajustés aux jeux J1 et J2**, pas un résultat général. Cible : σ0 = σ(δ0, γ0) du modèle simulé (par. 2.1) ; couverture conditionnelle à l'acceptation (statut ok). τ = part des jeux où σ0 est hors de l'intervalle ; IC de Clopper-Pearson à 95 % (qbeta), incertitude Monte-Carlo sur le taux (fonction de R). Classes et profils calculés mécaniquement, sur les valeurs non arrondies, **sans conclure** : la lecture revient à actuary, la décision (D2-Fn) au mainteneur.

**Critère de la spécification (par. 2.5), reporté sans modification :**

> ### 2.5 Critère, fixé avant toute exécution
> 
> Reporté sans modification dans le script et au T0. Taux de non-couverture τ de chaque (jeu, intervalle, niveau), comparé au nominal ρ = 0,10 (90 %) ou 0,05 (95 %). Classes de #166, #206 et Fk, avec une bande **fermée** [ρ/2 ; 3ρ/2] (couverture dans [0,85 ; 0,95] à 90 %, dans [0,925 ; 0,975] à 95 %) :
> 
> | Classe | Condition |
> |---|---|
> | compatible | ρ ∈ IC(τ) |
> | écart mineur | τ̂ dans la bande, sans être compatible |
> | non tranché | τ̂ hors de la bande, et IC qui la recoupe |
> | distorsion matérielle libérale (sous-couverture) | IC disjoint de la bande, au-dessus |
> | distorsion matérielle conservatrice | IC disjoint de la bande, au-dessous |
> 
> - **Règle de frontière** : classes calculées sur les valeurs non arrondies ; une estimation sur un bord de la bande est dans la bande ; **aucune extension de R après lecture des résultats** (pas d'arrêt optionnel) : R est fixé par le pré-vol et écrit au JOURNAL avant le lancement ; un « non tranché » reste non tranché.
> - **K-C1** (principal) : classe à 90 % de I1, I2 et I4 sur J1 et J2.
> - **K-C2** (descriptif) : classes à 95 % ; queues séparées, par rapport à ρ/2 ; I3, A1 et B1.
> - **K-C3** (intégrité ; un seul échec met INTEGRITE à ECHEC) : (1) md5 de `R/engine.R` et SHA consignés, identiques au début et à la fin ; (2) σ0 de J1 et J2 égal à `ajustement$sigma` de `premium` et `premium_interieur`, à `TOLERANCE` près ; (3) percentile du script, porté sur l'échelle de σ_USP par l'expression du moteur, `identical()` à `ic_bootstrap` des six références ; (4) sur le premier jeu de chaque tranche, bornes recalculées par une écriture indépendante (statistiques d'ordre et interpolation de type 7 en clair), égales à 1e-12 relatif près ; (5) sous l'option (b) seulement : σ\* et σ\*_r de la boucle allégée `identical()` à ceux d'`usp_bootstrap()` sur le premier jeu de chaque tranche.
> - **K-C4** (frontière, descriptif) : pour chaque classe, dire si l'IC touche un bord de la bande.

### T1 — K-C1 (principal) : classe à 90 % de I1, I2 et I4

| Jeu | Intervalle | n | couverture [IC 95 %] | τ̂ [IC CP 95 %] | classe | K-C4 : IC touche un bord |
| --- | --- | --- | --- | --- | --- | --- |
| J1 | I1 percentile | 1000 | 0,7100 [0,6808 ; 0,7380] | 0,2900 [0,2620 ; 0,3192] | distorsion matérielle libérale (sous-couverture) | non |
| J1 | I2 « basic » | 1000 | 0,8100 [0,7843 ; 0,8339] | 0,1900 [0,1661 ; 0,2157] | distorsion matérielle libérale (sous-couverture) | non |
| J1 | I4 « basic » log | 1000 | 0,8950 [0,8743 ; 0,9133] | 0,1050 [0,0867 ; 0,1257] | compatible | non |
| J2 | I1 percentile | 1000 | 0,6390 [0,6084 ; 0,6688] | 0,3610 [0,3312 ; 0,3916] | distorsion matérielle libérale (sous-couverture) | non |
| J2 | I2 « basic » | 1000 | 0,7520 [0,7240 ; 0,7785] | 0,2480 [0,2215 ; 0,2760] | distorsion matérielle libérale (sous-couverture) | non |
| J2 | I4 « basic » log | 1000 | 0,8860 [0,8647 ; 0,9050] | 0,1140 [0,0950 ; 0,1353] | compatible | non |

### T2 — couverture par jeu, intervalle et niveau (K-C1, K-C2, K-C4)

Queues séparées (K-C2) : part de σ0 sous la borne basse et au-dessus de la borne haute, classe contre ρ/2 (même règle, bande [ρ/4 ; 3ρ/4]). Largeurs divisées par σ0.

| Jeu | Intervalle | Niveau | n | couverture [IC 95 %] | τ̂ [IC] | classe (τ, ρ) | K-C4 | sous la borne basse [IC] ; classe (ρ/2) | au-dessus de la borne haute [IC] ; classe (ρ/2) | largeur médiane / σ0 | largeur moyenne / σ0 | bornes basses ≤ 0 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| J1 | I1 percentile | 90 % | 1000 | 0,7100 [0,6808 ; 0,7380] | 0,2900 [0,2620 ; 0,3192] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0037] ; distorsion matérielle conservatrice | 0,2900 [0,2620 ; 0,3192] ; distorsion matérielle libérale (sous-couverture) | 0,7300 | 0,7514 | 0 |
| J1 | I1 percentile | 95 % | 1000 | 0,7900 [0,7634 ; 0,8149] | 0,2100 [0,1851 ; 0,2366] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0037] ; distorsion matérielle conservatrice | 0,2100 [0,1851 ; 0,2366] ; distorsion matérielle libérale (sous-couverture) | 0,8657 | 0,8934 | 0 |
| J1 | I2 « basic » | 90 % | 1000 | 0,8100 [0,7843 ; 0,8339] | 0,1900 [0,1661 ; 0,2157] | distorsion matérielle libérale (sous-couverture) | non | 0,0080 [0,0035 ; 0,0157] ; distorsion matérielle conservatrice | 0,1820 [0,1585 ; 0,2073] ; distorsion matérielle libérale (sous-couverture) | 0,7300 | 0,7514 | 0 |
| J1 | I2 « basic » | 95 % | 1000 | 0,8390 [0,8147 ; 0,8613] | 0,1610 [0,1387 ; 0,1853] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0037] ; distorsion matérielle conservatrice | 0,1610 [0,1387 ; 0,1853] ; distorsion matérielle libérale (sous-couverture) | 0,8657 | 0,8934 | 0 |
| J1 | I3 restreint (percentile de σ*_r) | 90 % | 1000 | 0,7260 [0,6972 ; 0,7534] | 0,2740 [0,2466 ; 0,3028] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0037] ; distorsion matérielle conservatrice | 0,2740 [0,2466 ; 0,3028] ; distorsion matérielle libérale (sous-couverture) | 0,7354 | 0,7564 | 0 |
| J1 | I3 restreint (percentile de σ*_r) | 95 % | 1000 | 0,7950 [0,7686 ; 0,8196] | 0,2050 [0,1804 ; 0,2314] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0037] ; distorsion matérielle conservatrice | 0,2050 [0,1804 ; 0,2314] ; distorsion matérielle libérale (sous-couverture) | 0,8736 | 0,8989 | 0 |
| J1 | I4 « basic » log | 90 % | 1000 | 0,8950 [0,8743 ; 0,9133] | 0,1050 [0,0867 ; 0,1257] | compatible | non | 0,0450 [0,0330 ; 0,0598] ; compatible | 0,0600 [0,0461 ; 0,0766] ; compatible | 1,0672 | 1,1006 | 0 |
| J1 | I4 « basic » log | 95 % | 1000 | 0,9400 [0,9234 ; 0,9539] | 0,0600 [0,0461 ; 0,0766] | compatible | oui (3ρ/2) | 0,0170 [0,0099 ; 0,0271] ; compatible | 0,0430 [0,0313 ; 0,0575] ; non tranché | 1,3388 | 1,3805 | 0 |
| J1 | A1 percentile × corr | 90 % | 1000 | 0,8200 [0,7948 ; 0,8433] | 0,1800 [0,1567 ; 0,2052] | distorsion matérielle libérale (sous-couverture) | non | 0,0020 [0,0002 ; 0,0072] ; distorsion matérielle conservatrice | 0,1780 [0,1548 ; 0,2031] ; distorsion matérielle libérale (sous-couverture) | 0,8277 | 0,8520 | 0 |
| J1 | A1 percentile × corr | 95 % | 1000 | 0,8630 [0,8401 ; 0,8837] | 0,1370 [0,1163 ; 0,1599] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0037] ; distorsion matérielle conservatrice | 0,1370 [0,1163 ; 0,1599] ; distorsion matérielle libérale (sous-couverture) | 0,9816 | 1,0130 | 0 |
| J2 | I1 percentile | 90 % | 1000 | 0,6390 [0,6084 ; 0,6688] | 0,3610 [0,3312 ; 0,3916] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0037] ; distorsion matérielle conservatrice | 0,3610 [0,3312 ; 0,3916] ; distorsion matérielle libérale (sous-couverture) | 0,6926 | 0,7089 | 0 |
| J2 | I1 percentile | 95 % | 1000 | 0,7140 [0,6849 ; 0,7418] | 0,2860 [0,2582 ; 0,3151] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0037] ; distorsion matérielle conservatrice | 0,2860 [0,2582 ; 0,3151] ; distorsion matérielle libérale (sous-couverture) | 0,8165 | 0,8416 | 0 |
| J2 | I2 « basic » | 90 % | 1000 | 0,7520 [0,7240 ; 0,7785] | 0,2480 [0,2215 ; 0,2760] | distorsion matérielle libérale (sous-couverture) | non | 0,0260 [0,0171 ; 0,0379] ; écart mineur | 0,2220 [0,1966 ; 0,2491] ; distorsion matérielle libérale (sous-couverture) | 0,6926 | 0,7089 | 0 |
| J2 | I2 « basic » | 95 % | 1000 | 0,8200 [0,7948 ; 0,8433] | 0,1800 [0,1567 ; 0,2052] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0037] ; distorsion matérielle conservatrice | 0,1800 [0,1567 ; 0,2052] ; distorsion matérielle libérale (sous-couverture) | 0,8165 | 0,8416 | 0 |
| J2 | I3 restreint (percentile de σ*_r) | 90 % | 1000 | 0,6540 [0,6236 ; 0,6835] | 0,3460 [0,3165 ; 0,3764] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0037] ; distorsion matérielle conservatrice | 0,3460 [0,3165 ; 0,3764] ; distorsion matérielle libérale (sous-couverture) | 0,6912 | 0,7132 | 0 |
| J2 | I3 restreint (percentile de σ*_r) | 95 % | 1000 | 0,7280 [0,6993 ; 0,7554] | 0,2720 [0,2446 ; 0,3007] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0037] ; distorsion matérielle conservatrice | 0,2720 [0,2446 ; 0,3007] ; distorsion matérielle libérale (sous-couverture) | 0,8233 | 0,8457 | 0 |
| J2 | I4 « basic » log | 90 % | 1000 | 0,8860 [0,8647 ; 0,9050] | 0,1140 [0,0950 ; 0,1353] | compatible | non | 0,0550 [0,0417 ; 0,0710] ; compatible | 0,0590 [0,0452 ; 0,0754] ; compatible | 1,0630 | 1,1002 | 0 |
| J2 | I4 « basic » log | 95 % | 1000 | 0,9400 [0,9234 ; 0,9539] | 0,0600 [0,0461 ; 0,0766] | compatible | oui (3ρ/2) | 0,0290 [0,0195 ; 0,0414] ; compatible | 0,0310 [0,0212 ; 0,0437] ; compatible | 1,3373 | 1,3798 | 0 |
| J2 | A1 percentile × corr | 90 % | 1000 | 0,7700 [0,7426 ; 0,7958] | 0,2300 [0,2042 ; 0,2574] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0037] ; distorsion matérielle conservatrice | 0,2300 [0,2042 ; 0,2574] ; distorsion matérielle libérale (sous-couverture) | 0,7854 | 0,8038 | 0 |
| J2 | A1 percentile × corr | 95 % | 1000 | 0,8290 [0,8042 ; 0,8518] | 0,1710 [0,1482 ; 0,1958] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0037] ; distorsion matérielle conservatrice | 0,1710 [0,1482 ; 0,1958] ; distorsion matérielle libérale (sous-couverture) | 0,9258 | 0,9543 | 0 |

### T3 — couverture par régime de δ̂ du jeu simulé (descriptif)

| Jeu | Intervalle | Niveau | bord : n | bord : couverture [IC] | intérieur : n | intérieur : couverture [IC] |
| --- | --- | --- | --- | --- | --- | --- |
| J1 | I1 percentile | 90 % | 965 | 0,7088 [0,6790 ; 0,7373] | 35 | 0,7429 [0,5674 ; 0,8751] |
| J1 | I1 percentile | 95 % | 965 | 0,7896 [0,7625 ; 0,8150] | 35 | 0,8000 [0,6306 ; 0,9156] |
| J1 | I2 « basic » | 90 % | 965 | 0,8093 [0,7831 ; 0,8337] | 35 | 0,8286 [0,6635 ; 0,9344] |
| J1 | I2 « basic » | 95 % | 965 | 0,8394 [0,8147 ; 0,8620] | 35 | 0,8286 [0,6635 ; 0,9344] |
| J1 | I3 restreint (percentile de σ*_r) | 90 % | 965 | 0,7254 [0,6961 ; 0,7533] | 35 | 0,7429 [0,5674 ; 0,8751] |
| J1 | I3 restreint (percentile de σ*_r) | 95 % | 965 | 0,7948 [0,7679 ; 0,8199] | 35 | 0,8000 [0,6306 ; 0,9156] |
| J1 | I4 « basic » log | 90 % | 965 | 0,8953 [0,8743 ; 0,9139] | 35 | 0,8857 [0,7326 ; 0,9680] |
| J1 | I4 « basic » log | 95 % | 965 | 0,9409 [0,9241 ; 0,9550] | 35 | 0,9143 [0,7694 ; 0,9820] |
| J1 | A1 percentile × corr | 90 % | 965 | 0,8197 [0,7940 ; 0,8435] | 35 | 0,8286 [0,6635 ; 0,9344] |
| J1 | A1 percentile × corr | 95 % | 965 | 0,8632 [0,8399 ; 0,8843] | 35 | 0,8571 [0,6974 ; 0,9519] |
| J2 | I1 percentile | 90 % | 750 | 0,6320 [0,5964 ; 0,6666] | 250 | 0,6600 [0,5976 ; 0,7185] |
| J2 | I1 percentile | 95 % | 750 | 0,7120 [0,6781 ; 0,7442] | 250 | 0,7200 [0,6599 ; 0,7747] |
| J2 | I2 « basic » | 90 % | 750 | 0,7520 [0,7195 ; 0,7825] | 250 | 0,7520 [0,6937 ; 0,8043] |
| J2 | I2 « basic » | 95 % | 750 | 0,8213 [0,7920 ; 0,8481] | 250 | 0,8160 [0,7623 ; 0,8620] |
| J2 | I3 restreint (percentile de σ*_r) | 90 % | 750 | 0,6480 [0,6126 ; 0,6822] | 250 | 0,6720 [0,6100 ; 0,7298] |
| J2 | I3 restreint (percentile de σ*_r) | 95 % | 750 | 0,7267 [0,6933 ; 0,7583] | 250 | 0,7320 [0,6725 ; 0,7859] |
| J2 | I4 « basic » log | 90 % | 750 | 0,8907 [0,8661 ; 0,9121] | 250 | 0,8720 [0,8241 ; 0,9108] |
| J2 | I4 « basic » log | 95 % | 750 | 0,9373 [0,9175 ; 0,9536] | 250 | 0,9480 [0,9127 ; 0,9720] |
| J2 | A1 percentile × corr | 90 % | 750 | 0,7667 [0,7347 ; 0,7965] | 250 | 0,7800 [0,7235 ; 0,8298] |
| J2 | A1 percentile × corr | 95 % | 750 | 0,8253 [0,7962 ; 0,8519] | 250 | 0,8400 [0,7886 ; 0,8832] |

### T4 — biais (B1, descriptif) : moyenne ± 1,96 sd/√n sur les n jeux acceptés

| Jeu | n | E[σ̂]/σ0 | E[corr·σ̂]/σ0 | moyenne de σ̂/moyenne(σ*) | médiane du rang de σ̂ dans σ* (#{σ* < σ̂}/B_eff) | part de δ̂ intérieur [IC] |
| --- | --- | --- | --- | --- | --- | --- |
| J1 | 1000 | 0,9016 ± 0,0159 | 1,0223 ± 0,0180 | 1,1144 ± 0,0006 | 0,6757 | 0,0350 [0,0245 ; 0,0483] |
| J2 | 1000 | 0,8709 ± 0,0157 | 0,9875 ± 0,0178 | 1,1451 ± 0,0021 | 0,7087 | 0,2500 [0,2234 ; 0,2781] |

### T5 — refus, échecs et variantes des bootstraps

| Jeu | R | statut ok | statut refus_donnees | statut refus_ajustement | statut echec_ajustement | statut echec_bootstrap | statut echec_beff | statut echec_autre | refus et échecs / R | V1 | V3b | tirages V3b (moyenne) | B_eff min | B_eff restreint min | échecs du restreint (somme) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| J1 | 1000 | 1000 | 0 | 0 | 0 | 0 | 0 | 0 | 0,0000 | 965 | 35 | 24691 | 999 | 999 | 0 |
| J2 | 1000 | 1000 | 0 | 0 | 0 | 0 | 0 | 0 | 0,0000 | 750 | 250 | 4644 | 999 | 999 | 0 |

### Contrôles d'intégrité (K-C3 ; (5) sans objet, option (b) non utilisée)

| Contrôle | Résultat | Détail |
| --- | --- | --- |
| K-C3 (2) J1 | OK | σ0 = 0.1053104858 ; premium.rds : ajustement$sigma = 0.1053104858 ; écart relatif 0.000e+00 (TOLERANCE 1e-06) |
| K-C3 (2) J2 | OK | σ0 = 0.06895525656 ; premium_interieur.rds : ajustement$sigma = 0.06895525656 ; écart relatif 0.000e+00 (TOLERANCE 1e-06) |
| K-C3 (3) | OK | premium identical ; reserve1 identical ; reserve2 identical ; premium_ii6 identical ; premium_net identical ; premium_interieur identical |
| K-C3 (4) | OK | J1-r000001-000100.tsv (r = 1) : 2.37e-16 ; J1-r000101-000200.tsv (r = 101) : 4.89e-16 ; J1-r000201-000300.tsv (r = 201) : 2.84e-16 ; J1-r000301-000400.tsv (r = 301) : 2.41e-16 ; J1-r000401-000500.tsv (r = 401) : 3.53e-16 ; J1-r000501-000600.tsv (r = 501) : 6.24e-16 ; J1-r000601-000700.tsv (r = 601) : 5.18e-16 ; J1-r000701-000800.tsv (r = 701) : 3.15e-16 ; J1-r000801-000900.tsv (r = 801) : 2.70e-16 ; J1-r000901-001000.tsv (r = 901) : 1.89e-16 ; J2-r000001-000100.tsv (r = 1) : 3.76e-16 ; J2-r000101-000200.tsv (r = 101) : 4.83e-16 ; J2-r000201-000300.tsv (r = 201) : 4.42e-16 ; J2-r000301-000400.tsv (r = 301) : 3.22e-16 ; J2-r000401-000500.tsv (r = 401) : 5.22e-16 ; J2-r000501-000600.tsv (r = 501) : 3.68e-16 ; J2-r000601-000700.tsv (r = 601) : 3.22e-16 ; J2-r000701-000800.tsv (r = 701) : 3.36e-16 ; J2-r000801-000900.tsv (r = 801) : 4.14e-16 ; J2-r000901-001000.tsv (r = 901) : 1.69e-16 |
| (t305) contrôle de forme, hors K-C3 | OK | par. 2.5 présent à l'identique ; par. 2.6 présent à l'identique dans docs/specifications/fn-incertitude-bootstrap.md (vérifié avant la boucle de calcul) |
| K-C3 (1) | OK | md5 R/engine.R début f304b88eb6b1c1cf475df727ab993893, fin f304b88eb6b1c1cf475df727ab993893, JOURNAL f304b88eb6b1c1cf475df727ab993893 ; SHA début 01ea076b79c3bedf5609fe870583a74357eedd0a, fin 01ea076b79c3bedf5609fe870583a74357eedd0a, JOURNAL 01ea076b79c3bedf5609fe870583a74357eedd0a ; contexte (B, SHA, md5 du moteur et du script, plateforme) identique dans les 20 tranche(s) : oui |
| K-C3 (4), étendu (descriptif) | — | écart relatif maximal des bornes indépendantes sur les 2000 jeux acceptés : 7.85e-16 |

### Profils de lecture pour D2-Fn (par. 2.6), évalués mécaniquement au niveau 90 % (K-C1), sans décision

> ### 2.6 Profils de lecture pour D2-Fn
> 
> `actuary` propose, le mainteneur tranche. Ordre d'évaluation : Ψ0, puis Ψ4, puis Ψ1 à Ψ3.
> 
> | Profil | Condition | Lecture proposée |
> |---|---|---|
> | Ψ0 | K-C3 en défaut, ou refus et échecs au-delà de 2 % de R sur un jeu sans explication | lecture suspendue ; mesure à reprendre |
> | Ψ4 | I1 en distorsion de côtés opposés entre J1 et J2 | décision du mainteneur ; aucune correction calibrée sur un seul plan |
> | Ψ1 | I1 compatible ou en écart mineur sur J1 et J2 | percentile conservé ; couverture écrite dans la fiche ; « basic » non restitué par défaut (le mainteneur peut le restituer en regard) |
> | Ψ2 | I1 ni compatible ni en écart mineur sur au moins un jeu, et au moins un des intervalles I2 ou I4 compatible ou en écart mineur sur les deux | **décision du mainteneur** : restituer en regard le ou les intervalles « basic » qui satisfont la condition ; libellé du percentile requalifié (« niveau nominal 90 % ; couverture mesurée … ») |
> | Ψ3 | I1 dans ce même cas, et aucun des intervalles I2 ou I4 compatible ou en écart mineur sur les deux jeux | **décision du mainteneur** : aucun « basic » restitué ; libellé du percentile requalifié ; issue proposée pour un autre intervalle |
> 
> D2-Fn est **toujours tenu** : la décision sur le « basic » revient au mainteneur (Q-42-10). σ_USP n'est jamais touché.

| Élément | Valeur |
| --- | --- |
| K-C3 | rempli |
| refus et échecs au-delà de 2 % de R | non (J1 0,0000 ; J2 0,0000) |
| classe de I1 à 90 % | J1 distorsion matérielle libérale (sous-couverture) ; J2 distorsion matérielle libérale (sous-couverture) |
| I1 en distorsion de côtés opposés (Ψ4) | non |
| I2 compatible ou en écart mineur sur J1 et J2 | non |
| I4 compatible ou en écart mineur sur J1 et J2 | oui |
| **Profil (lecture proposée)** | **Ψ2** |

Le profil est une lecture proposée : D2-Fn est toujours tenu, la décision revient au mainteneur.

Bilan : OK

