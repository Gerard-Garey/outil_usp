## Mesures #379 et #494 : puissance à T = 8 des p de famille et de la p globale (#379) et de CorrDev sous persistance AR(1) (#494), Merz-Wüthrich

Statut : **constat de simulation sous plan** (modèle de Mack ajusté à reserve2, géométrie 8 × 8, plan(s) P1 et P2 de #309), pour la procédure du moteur à B = 999 ; rien n'est transposé à d'autres triangles, plans ou alternatives. Les p de famille restent plug-in et non exactes.

### T0 — provenance

| Grandeur | Valeur |
| --- | --- |
| Protocole | avis d'actuary docs/revues/20261127-s9-mesures/actuary-protocoles-etape-1.md, par. 4 et 5 ; décisions Q-S9-1 (a) et Q-S9-2 (a) ; corrections de l'avis à l'étape 5 (actuary-questions-etape-5.md : Q3 et section #494) ; campagne Merz-Wüthrich unique de #379 et #494 |
| Procédure par triangle | admission (admettre()), mw_bootstrap(aj, B = 999, graine de bootstrap) du catalogue du moteur sans injection, mw_tests(aj, boot, α = 0,10) ; lignes de lecture conjointe (engine_p_famille()) ; identité à run_engine() contrôlée (i2) |
| Cellules et R | P1.H0 : R = 500 (b = 1..500), graines de rang 1 du plan de #309 ; P1.CST20 : R = 300 (b = 1..300), graines de rang 2 du plan de #309 ; P1.DCAL : R = 300 (b = 1..300), graines de rang 11 du plan de #309 ; P1.AR03 : R = 500 (b = 1..500), graines de rang 1 du plan de #309 (celles de P1.H0, nombres aléatoires communs), AR(1) ρ = 0,3 ; P1.AR05 : R = 500 (b = 1..500), graines de rang 1 du plan de #309 (celles de P1.H0, nombres aléatoires communs), AR(1) ρ = 0,5 ; P2.H0 : R = 500 (b = 1..500), graines de rang 14 du plan de #309 ; P2.AR05 : R = 500 (b = 1..500), graines de rang 14 du plan de #309 (celles de P2.H0, nombres aléatoires communs), AR(1) ρ = 0,5 |
| DGP | modèle de Mack ajusté à reserve2 (mw_ajuster(), tests/donnees/triangle_mw.csv), I = J = 7 ; f̂ = (3,20372 ; 1,65175 ; 1,32525 ; 1,15042 ; 1,09469 ; 1,06455 ; 1,02841) ; σ̂² = (0,72404 ; 0,71209 ; 0,69814 ; 0,31478 ; 0,097325 ; 0,18967 ; 0,097325), non réestimés sous P2 et P3 ; plans de la première colonne fixée (lignes 0..7) : P1 = (300,0000 ; 311,4286 ; 322,8571 ; 334,2857 ; 345,7143 ; 357,1429 ; 368,5714 ; 380,0000), P2 = C̄₀ + 3,4 (C₀ − C̄₀) = (204,0000 ; 242,8571 ; 281,7143 ; 320,5714 ; 359,4286 ; 398,2857 ; 437,1429 ; 476,0000), P3 = P2[c(2, 8, 6, 4, 3, 5, 7, 1)] (π = (1, 7, 5, 3, 2, 4, 6, 0)) = (242,8571 ; 476,0000 ; 398,2857 ; 320,5714 ; 281,7143 ; 359,4286 ; 437,1429 ; 204,0000) ; colonnes dégénérées de reserve2 : 6 ; loi N (stats::rnorm) sous le volet B ; volet A : N, E (loi uniforme sur les 27 valeurs de .mw_pool_residus(aj0, jd0) divisées par leur écart-type de population 0,9988), A ((G − 2)/√2, G ~ Gamma(2) par inversion) ; générateurs gen_triangle_h0() (H0 de #206) et gen_triangle_scen() (CST, EXP, DFI) ; scénarios d'incréments recumulés CAL7, CAL4 (θ = 0,1), DCAL (1,05^max(0, t − 3)), LIG (× 1,5 pour j ≥ 2, ligne 2), CEL4 et CEL6 (λ = 4 et 6), CELx4 ; CST10, CST20 (δ = 0,1 ; 0,2), EXP0, EXP2 (κ = 0 ; 2), DFI (γ = 0,2) ; cellule visée (i, j) = (2, 1) |
| Scénario AR(1) (#494) | gen_triangle_ar1() : gen_triangle_h0() du plan, erreur standardisée de la transition j → j + 1 de l'année i ε(i, 0) = η(i, 0), ε(i, j) = ρ ε(i, j − 1) + √(1 − ρ²) η(i, j), η ~ N(0, 1) (stats::rnorm), variance marginale 1, même ordre de consommation de l'aléa que H0 ; à ρ = 0 : triangles de H0 au bit près (contrôle (ar0)) |
| Recoupement PM-3 (#494) | docs/tableaux/20261021-issue309-puissance-mw-brut.tsv (md5 f616a3bc2e9a0cb6ce255396b0130ba0), cellules P1.H0, P2.H0 |
| Graines | volet A (graines de #206) : triangle b, loi ℓ : 20840000 + 10000 (ℓ − 1) + b ; bootstrap : 20870000 + 10000 (ℓ − 1) + b ; oracle k : 20900000 + 20000 (ℓ − 1) + k ; ℓ = 1 (N), 2 (E), 3 (A) ; volet B, P1 et P2, cellule de rang c (P1 : 1 à 13, P2 : 14 à 19, dans l'ordre de CELLULES) : triangle 32000000 + 20000 (c − 1) + b, bootstrap 32500000 + 20000 (c − 1) + b, oracle de P2 : 33000000 + k ; P3, c3 = 1 (H0), 2 (CST20), 3 (DFI) : triangle 34000000 + 20000 (c3 − 1) + b, bootstrap 34200000 + 20000 (c3 − 1) + b, oracle 34400000 + k ; contrôles sur reserve2 : 20260831 ; tous les tirages sous engine_sous_graine() |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Commit du calcul | 2a2d636dcc63ae9b48315a0799d03de687947041 |
| Arbre propre et code du dépôt | oui |
| Plateforme de calcul (R, système, machine, BLAS, LAPACK) | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : libblas.so.3.12.0 ; LAPACK : liblapack.so.3.12.0 (version 3.12.0) |
| Empreintes md5 du code exécuté | R/engine.R c7b767f5d9116c35a0a9237ffdd2d79a ; tests/outils_tests.R chargé (dépôt) cd6f78dd811f125f1755acc55e1fd228 ; script exécuté (dépôt) 9f6dd0a5e087b0ee90b926a649dd72b1 ; docs/specifications/fi-merz-wuthrich-puissance.md b042f37a354a5a0d8c28c5d0d1fa94b6 |
| Empreinte sans commentaires de R/engine.R (#231) | 15a74c3dbd831c56c259df106e9e4667 |
| Dossier de travail | travail494mw (hors du dépôt) : 124 tranche(s), dont 20 calculée(s) par cette exécution |
| Durée | cette exécution : 2311 s d'horloge, 4 processus ; somme des durées des triangles : 56426 s ; des contrôles (i2) : 948 s |
| Tableau brut | 3100 ligne(s) de données, md5 3617ee754234561c38bc94c191b236d9 |

### F1 — p de famille et p globale (ligne de mw_tests()), U_f, comparaison à la cellule H0 du plan

| Cellule | Famille | α | n (admis, ligne présente) | ligne L / T-3b / absente (hors n) | rejets p_f < α | π̂ | IC 95 % (C-P) | U_f = 1 | Û | IC 95 % (C-P) | π̂ − π̂(H0) | Û − Û(H0) | P(U_f = 1, p_f ≥ α) | paires (b communs, ligne présente des deux côtés) | McNemar n01 / n10 | McNemar bilatéral | McNemar unilatéral π < π(H0) | Fisher bilatéral | Fisher unilatéral π < π(H0) | classe (par. 4.5) | signal PM-3 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P1.H0 | M1 | 0,10 | 500 | 500 / 0 / 0 | 45 | 0,090 | [0,066 ; 0,119] | 164 | 0,328 | [0,287 ; 0,371] | — | — | 0,238 | — | — | — | — | — | — | niveau (référence) | — |
| P1.H0 | M1 | 0,05 | 500 | 500 / 0 / 0 | 20 | 0,040 | [0,025 ; 0,061] | 88 | 0,176 | [0,144 ; 0,212] | — | — | 0,136 | — | — | — | — | — | — | niveau (référence) | — |
| P1.H0 | M2 | 0,10 | 500 | 500 / 0 / 0 | 43 | 0,086 | [0,063 ; 0,114] | 83 | 0,166 | [0,134 ; 0,202] | — | — | 0,080 | — | — | — | — | — | — | niveau (référence) | — |
| P1.H0 | M2 | 0,05 | 500 | 500 / 0 / 0 | 17 | 0,034 | [0,020 ; 0,054] | 39 | 0,078 | [0,056 ; 0,105] | — | — | 0,044 | — | — | — | — | — | — | niveau (référence) | — |
| P1.H0 | M3 | 0,10 | 500 | 500 / 0 / 0 | 42 | 0,084 | [0,061 ; 0,112] | 167 | 0,334 | [0,293 ; 0,377] | — | — | 0,250 | — | — | — | — | — | — | niveau (référence) | — |
| P1.H0 | M3 | 0,05 | 500 | 500 / 0 / 0 | 18 | 0,036 | [0,021 ; 0,056] | 85 | 0,170 | [0,138 ; 0,206] | — | — | 0,134 | — | — | — | — | — | — | niveau (référence) | — |
| P1.H0 | LC (globale) | 0,10 | 500 | 500 / 0 / 0 | 37 | 0,074 | [0,053 ; 0,101] | 317 | 0,634 | [0,590 ; 0,676] | — | — | 0,560 | — | — | — | — | — | — | niveau (référence) | — |
| P1.H0 | LC (globale) | 0,05 | 500 | 500 / 0 / 0 | 14 | 0,028 | [0,015 ; 0,047] | 186 | 0,372 | [0,330 ; 0,416] | — | — | 0,344 | — | — | — | — | — | — | niveau (référence) | — |
| P1.CST20 | M1 | 0,10 | 300 | 300 / 0 / 0 | 227 | 0,757 | [0,704 ; 0,804] | 288 | 0,960 | [0,931 ; 0,979] | +0,667 | +0,632 | 0,203 | — | — | — | — | 2,17e-86 | 1 | substantielle | non |
| P1.CST20 | M1 | 0,05 | 300 | 300 / 0 / 0 | 182 | 0,607 | [0,549 ; 0,662] | 267 | 0,890 | [0,849 ; 0,923] | +0,567 | +0,714 | 0,283 | — | — | — | — | 3,96e-74 | 1 | substantielle | non |
| P1.CST20 | M2 | 0,10 | 300 | 300 / 0 / 0 | 18 | 0,060 | [0,036 ; 0,093] | 31 | 0,103 | [0,071 ; 0,143] | -0,026 | -0,063 | 0,043 | — | — | — | — | 0,216 | 0,113 | non distinguée | non |
| P1.CST20 | M2 | 0,05 | 300 | 300 / 0 / 0 | 11 | 0,037 | [0,018 ; 0,065] | 16 | 0,053 | [0,031 ; 0,085] | +0,003 | -0,025 | 0,017 | — | — | — | — | 0,845 | 0,659 | non distinguée | non |
| P1.CST20 | M3 | 0,10 | 300 | 300 / 0 / 0 | 35 | 0,117 | [0,083 ; 0,159] | 127 | 0,423 | [0,367 ; 0,481] | +0,033 | +0,089 | 0,307 | — | — | — | — | 0,138 | 0,948 | non distinguée | non |
| P1.CST20 | M3 | 0,05 | 300 | 300 / 0 / 0 | 18 | 0,060 | [0,036 ; 0,093] | 64 | 0,213 | [0,168 ; 0,264] | +0,024 | +0,043 | 0,153 | — | — | — | — | 0,117 | 0,959 | non distinguée | non |
| P1.CST20 | LC (globale) | 0,10 | 300 | 300 / 0 / 0 | 175 | 0,583 | [0,525 ; 0,640] | 294 | 0,980 | [0,957 ; 0,993] | +0,509 | +0,346 | 0,397 | — | — | — | — | 8,24e-57 | 1 | substantielle | non |
| P1.CST20 | LC (globale) | 0,05 | 300 | 300 / 0 / 0 | 121 | 0,403 | [0,347 ; 0,461] | 277 | 0,923 | [0,887 ; 0,951] | +0,375 | +0,551 | 0,520 | — | — | — | — | 1,09e-43 | 1 | faible | non |
| P1.DCAL | M1 | 0,10 | 300 | 300 / 0 / 0 | 168 | 0,560 | [0,502 ; 0,617] | 260 | 0,867 | [0,823 ; 0,903] | +0,470 | +0,539 | 0,307 | — | — | — | — | 5,4e-48 | 1 | substantielle | non |
| P1.DCAL | M1 | 0,05 | 300 | 300 / 0 / 0 | 126 | 0,420 | [0,364 ; 0,478] | 219 | 0,730 | [0,676 ; 0,779] | +0,380 | +0,554 | 0,310 | — | — | — | — | 1,27e-41 | 1 | faible | non |
| P1.DCAL | M2 | 0,10 | 300 | 300 / 0 / 0 | 18 | 0,060 | [0,036 ; 0,093] | 31 | 0,103 | [0,071 ; 0,143] | -0,026 | -0,063 | 0,043 | — | — | — | — | 0,216 | 0,113 | non distinguée | non |
| P1.DCAL | M2 | 0,05 | 300 | 300 / 0 / 0 | 8 | 0,027 | [0,012 ; 0,052] | 15 | 0,050 | [0,028 ; 0,081] | -0,007 | -0,028 | 0,023 | — | — | — | — | 0,677 | 0,363 | non distinguée | non |
| P1.DCAL | M3 | 0,10 | 300 | 300 / 0 / 0 | 80 | 0,267 | [0,217 ; 0,321] | 191 | 0,637 | [0,579 ; 0,691] | +0,183 | +0,303 | 0,370 | — | — | — | — | 1,23e-11 | 1 | faible | non |
| P1.DCAL | M3 | 0,05 | 300 | 300 / 0 / 0 | 44 | 0,147 | [0,109 ; 0,192] | 131 | 0,437 | [0,380 ; 0,495] | +0,111 | +0,267 | 0,290 | — | — | — | — | 3,32e-08 | 1 | faible | non |
| P1.DCAL | LC (globale) | 0,10 | 300 | 300 / 0 / 0 | 127 | 0,423 | [0,367 ; 0,481] | 277 | 0,923 | [0,887 ; 0,951] | +0,349 | +0,289 | 0,500 | — | — | — | — | 9,72e-32 | 1 | faible | non |
| P1.DCAL | LC (globale) | 0,05 | 300 | 300 / 0 / 0 | 87 | 0,290 | [0,239 ; 0,345] | 236 | 0,787 | [0,736 ; 0,832] | +0,262 | +0,415 | 0,497 | — | — | — | — | 3,81e-27 | 1 | faible | non |
| P1.AR03 | M1 | 0,10 | 500 | 500 / 0 / 0 | 61 | 0,122 | [0,095 ; 0,154] | 198 | 0,396 | [0,353 ; 0,440] | +0,032 | +0,068 | 0,274 | 500 (graines communes) | 31 / 15 | 0,0259 | 0,994 | — | — | faible | non |
| P1.AR03 | M1 | 0,05 | 500 | 500 / 0 / 0 | 42 | 0,084 | [0,061 ; 0,112] | 107 | 0,214 | [0,179 ; 0,253] | +0,044 | +0,038 | 0,130 | 500 (graines communes) | 25 / 3 | 2,74e-05 | 1 | — | — | faible | non |
| P1.AR03 | M2 | 0,10 | 500 | 500 / 0 / 0 | 37 | 0,074 | [0,053 ; 0,101] | 81 | 0,162 | [0,131 ; 0,197] | -0,012 | -0,004 | 0,088 | 500 (graines communes) | 20 / 26 | 0,461 | 0,231 | — | — | non distinguée | non |
| P1.AR03 | M2 | 0,05 | 500 | 500 / 0 / 0 | 22 | 0,044 | [0,028 ; 0,066] | 36 | 0,072 | [0,051 ; 0,098] | +0,010 | -0,006 | 0,028 | 500 (graines communes) | 15 / 10 | 0,424 | 0,885 | — | — | non distinguée | non |
| P1.AR03 | M3 | 0,10 | 500 | 500 / 0 / 0 | 100 | 0,200 | [0,166 ; 0,238] | 253 | 0,506 | [0,461 ; 0,551] | +0,116 | +0,172 | 0,306 | 500 (graines communes) | 69 / 11 | 2,05e-11 | 1 | — | — | faible | non |
| P1.AR03 | M3 | 0,05 | 500 | 500 / 0 / 0 | 63 | 0,126 | [0,098 ; 0,158] | 153 | 0,306 | [0,266 ; 0,348] | +0,090 | +0,136 | 0,180 | 500 (graines communes) | 52 / 7 | 1,36e-09 | 1 | — | — | faible | non |
| P1.AR03 | LC (globale) | 0,10 | 500 | 500 / 0 / 0 | 82 | 0,164 | [0,133 ; 0,199] | 361 | 0,722 | [0,680 ; 0,761] | +0,090 | +0,088 | 0,558 | 500 (graines communes) | 56 / 11 | 2,15e-08 | 1 | — | — | faible | non |
| P1.AR03 | LC (globale) | 0,05 | 500 | 500 / 0 / 0 | 44 | 0,088 | [0,065 ; 0,116] | 244 | 0,488 | [0,443 ; 0,533] | +0,060 | +0,116 | 0,400 | 500 (graines communes) | 35 / 5 | 1,38e-06 | 1 | — | — | faible | non |
| P1.AR05 | M1 | 0,10 | 500 | 500 / 0 / 0 | 78 | 0,156 | [0,125 ; 0,191] | 220 | 0,440 | [0,396 ; 0,485] | +0,066 | +0,112 | 0,284 | 500 (graines communes) | 52 / 19 | 0,000112 | 1 | — | — | faible | non |
| P1.AR05 | M1 | 0,05 | 500 | 500 / 0 / 0 | 48 | 0,096 | [0,072 ; 0,125] | 141 | 0,282 | [0,243 ; 0,324] | +0,056 | +0,106 | 0,186 | 500 (graines communes) | 33 / 5 | 4,26e-06 | 1 | — | — | faible | non |
| P1.AR05 | M2 | 0,10 | 500 | 500 / 0 / 0 | 45 | 0,090 | [0,066 ; 0,119] | 91 | 0,182 | [0,149 ; 0,219] | +0,004 | +0,016 | 0,092 | 500 (graines communes) | 30 / 28 | 0,896 | 0,653 | — | — | non distinguée | non |
| P1.AR05 | M2 | 0,05 | 500 | 500 / 0 / 0 | 24 | 0,048 | [0,031 ; 0,071] | 41 | 0,082 | [0,059 ; 0,110] | +0,014 | +0,004 | 0,034 | 500 (graines communes) | 17 / 10 | 0,248 | 0,939 | — | — | non distinguée | non |
| P1.AR05 | M3 | 0,10 | 500 | 500 / 0 / 0 | 216 | 0,432 | [0,388 ; 0,477] | 349 | 0,698 | [0,656 ; 0,738] | +0,348 | +0,364 | 0,266 | 500 (graines communes) | 187 / 13 | 1,18e-40 | 1 | — | — | faible | non |
| P1.AR05 | M3 | 0,05 | 500 | 500 / 0 / 0 | 144 | 0,288 | [0,249 ; 0,330] | 274 | 0,548 | [0,503 ; 0,592] | +0,252 | +0,378 | 0,260 | 500 (graines communes) | 134 / 8 | 1,28e-30 | 1 | — | — | faible | non |
| P1.AR05 | LC (globale) | 0,10 | 500 | 500 / 0 / 0 | 146 | 0,292 | [0,252 ; 0,334] | 422 | 0,844 | [0,809 ; 0,875] | +0,218 | +0,210 | 0,552 | 500 (graines communes) | 122 / 13 | 2,24e-23 | 1 | — | — | faible | non |
| P1.AR05 | LC (globale) | 0,05 | 500 | 500 / 0 / 0 | 97 | 0,194 | [0,160 ; 0,231] | 344 | 0,688 | [0,645 ; 0,728] | +0,166 | +0,316 | 0,494 | 500 (graines communes) | 90 / 7 | 1,75e-19 | 1 | — | — | faible | non |
| P2.H0 | M1 | 0,10 | 500 | 500 / 0 / 0 | 59 | 0,118 | [0,091 ; 0,150] | 167 | 0,334 | [0,293 ; 0,377] | — | — | 0,216 | — | — | — | — | — | — | niveau (référence) | — |
| P2.H0 | M1 | 0,05 | 500 | 500 / 0 / 0 | 25 | 0,050 | [0,033 ; 0,073] | 97 | 0,194 | [0,160 ; 0,231] | — | — | 0,144 | — | — | — | — | — | — | niveau (référence) | — |
| P2.H0 | M2 | 0,10 | 500 | 500 / 0 / 0 | 44 | 0,088 | [0,065 ; 0,116] | 80 | 0,160 | [0,129 ; 0,195] | — | — | 0,072 | — | — | — | — | — | — | niveau (référence) | — |
| P2.H0 | M2 | 0,05 | 500 | 500 / 0 / 0 | 21 | 0,042 | [0,026 ; 0,063] | 39 | 0,078 | [0,056 ; 0,105] | — | — | 0,036 | — | — | — | — | — | — | niveau (référence) | — |
| P2.H0 | M3 | 0,10 | 500 | 500 / 0 / 0 | 57 | 0,114 | [0,087 ; 0,145] | 171 | 0,342 | [0,300 ; 0,385] | — | — | 0,228 | — | — | — | — | — | — | niveau (référence) | — |
| P2.H0 | M3 | 0,05 | 500 | 500 / 0 / 0 | 25 | 0,050 | [0,033 ; 0,073] | 82 | 0,164 | [0,133 ; 0,199] | — | — | 0,114 | — | — | — | — | — | — | niveau (référence) | — |
| P2.H0 | LC (globale) | 0,10 | 500 | 500 / 0 / 0 | 48 | 0,096 | [0,072 ; 0,125] | 313 | 0,626 | [0,582 ; 0,669] | — | — | 0,530 | — | — | — | — | — | — | niveau (référence) | — |
| P2.H0 | LC (globale) | 0,05 | 500 | 500 / 0 / 0 | 23 | 0,046 | [0,029 ; 0,068] | 184 | 0,368 | [0,326 ; 0,412] | — | — | 0,322 | — | — | — | — | — | — | niveau (référence) | — |
| P2.AR05 | M1 | 0,10 | 500 | 500 / 0 / 0 | 75 | 0,150 | [0,120 ; 0,184] | 190 | 0,380 | [0,337 ; 0,424] | +0,032 | +0,046 | 0,230 | 500 (graines communes) | 39 / 23 | 0,0559 | 0,985 | — | — | non distinguée | non |
| P2.AR05 | M1 | 0,05 | 500 | 500 / 0 / 0 | 49 | 0,098 | [0,073 ; 0,127] | 131 | 0,262 | [0,224 ; 0,303] | +0,048 | +0,068 | 0,164 | 500 (graines communes) | 35 / 11 | 0,000536 | 1 | — | — | faible | non |
| P2.AR05 | M2 | 0,10 | 500 | 500 / 0 / 0 | 62 | 0,124 | [0,096 ; 0,156] | 91 | 0,182 | [0,149 ; 0,219] | +0,036 | +0,022 | 0,058 | 500 (graines communes) | 45 / 27 | 0,0444 | 0,988 | — | — | faible | non |
| P2.AR05 | M2 | 0,05 | 500 | 500 / 0 / 0 | 33 | 0,066 | [0,046 ; 0,091] | 61 | 0,122 | [0,095 ; 0,154] | +0,024 | +0,044 | 0,056 | 500 (graines communes) | 27 / 15 | 0,0884 | 0,978 | — | — | non distinguée | non |
| P2.AR05 | M3 | 0,10 | 500 | 500 / 0 / 0 | 209 | 0,418 | [0,374 ; 0,463] | 346 | 0,692 | [0,649 ; 0,732] | +0,304 | +0,350 | 0,274 | 500 (graines communes) | 173 / 21 | 6,38e-31 | 1 | — | — | faible | non |
| P2.AR05 | M3 | 0,05 | 500 | 500 / 0 / 0 | 148 | 0,296 | [0,256 ; 0,338] | 266 | 0,532 | [0,487 ; 0,576] | +0,246 | +0,368 | 0,236 | 500 (graines communes) | 132 / 9 | 3,6e-29 | 1 | — | — | faible | non |
| P2.AR05 | LC (globale) | 0,10 | 500 | 500 / 0 / 0 | 170 | 0,340 | [0,299 ; 0,383] | 425 | 0,850 | [0,816 ; 0,880] | +0,244 | +0,224 | 0,510 | 500 (graines communes) | 140 / 18 | 1,35e-24 | 1 | — | — | faible | non |
| P2.AR05 | LC (globale) | 0,05 | 500 | 500 / 0 / 0 | 112 | 0,224 | [0,188 ; 0,263] | 346 | 0,692 | [0,649 ; 0,732] | +0,178 | +0,324 | 0,468 | 500 (graines communes) | 100 / 11 | 4,09e-19 | 1 | — | — | faible | non |

n : triangles admis de la cellule où la ligne est présente (k ≥ 2 ; convention de T-F1 de #297), une ligne absente (k ≤ 1) étant hors de n et comptée à part. p_f : p de la ligne de lecture conjointe telle que la rend mw_tests() (engine_p_famille(), champ p_mc) ; une ligne sans p (B effectif de famille < 50, texte T-3b) compte comme un non-rejet. U_f = 1 : au moins un membre de la ligne (mêmes membres, lus par fk_membres(), mêmes triangles) a une p Monte-Carlo < α ; U_f n'est pas un test de niveau α : lecture en excès sur le niveau (par. 5.3 de l'avis). Test contre la cellule H0 du même plan (avis d'actuary de l'étape 5, Q3) : pour une cellule qui reprend ses graines (cellules AR de #494), McNemar exact apparié par b sur les b admis dans les deux cellules, ligne présente des deux côtés (n01 : la cellule rejette et H0 non) ; pour une cellule à graines distinctes (CST20, DCAL : graines de #309, échantillons indépendants), test exact de Fisher sur les triangles admis, ligne présente, des deux cellules (cellule en première ligne), colonnes McNemar sans objet. Bilatéral pour la classe, unilatéral π(s) < π(H0) < 0,05 pour le signal PM-3. Classe (seuils 0,5 : convention déclarée) : non distinguée si p ≥ 0,05, sinon faible (borne haute < 0,5), substantielle (borne basse ≥ 0,5) ou intermédiaire ; évaluée mécaniquement, sans conclure. IC : erreur d'échantillonnage (fonction de R) ; l'erreur Monte-Carlo de chaque p (fonction de B) fait partie de la procédure.

Familles sans ligne (k ≤ 1 sur tous les triangles) : M4

### F2 — triangles, admission, retirage, contrôles

| Cellule | R | admis | refusés (motifs) | cumuls retirés / plafond atteint (#257) | (i2) contrôlés / OK | k de la ligne globale (min – max) | T-3a : p_f < 0,10 et U_f = 0 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| P1.H0 | 500 | 500 | 0 | 0 / 0 | 10 / 10 | 12 – 12 | 0 |
| P1.CST20 | 300 | 300 | 0 | 0 / 0 | 6 / 6 | 12 – 12 | 0 |
| P1.DCAL | 300 | 300 | 0 | 0 / 0 | 6 / 6 | 12 – 12 | 0 |
| P1.AR03 | 500 | 500 | 0 | 0 / 0 | 10 / 10 | 12 – 12 | 0 |
| P1.AR05 | 500 | 500 | 0 | 0 / 0 | 10 / 10 | 12 – 12 | 0 |
| P2.H0 | 500 | 500 | 0 | 0 / 0 | 10 / 10 | 12 – 12 | 0 |
| P2.AR05 | 500 | 500 | 0 | 0 / 0 | 10 / 10 | 12 – 12 | 0 |

### F3 — #494 : CorrDev, DW sur résidus de Mack, famille M3 et ligne globale sous persistance AR(1) dans l'année d'accident

| Cellule | ρ | admis / refusés | Ligne | α | n (admis, ligne présente) | rejets p < α | π̂ | IC 95 % (C-P) | π̂(H0) du plan | paires (b admis des deux côtés, ligne présente) | McNemar n01 / n10 | McNemar bilatéral | classe (par. 4.5) | p retenue ≠ p_mc (admis) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P1.H0 | 0 (H0) | 500 / 0 | CorrDev | 0,10 | 500 | 44 | 0,088 | [0,065 ; 0,116] | — | — | — | — | niveau (référence) | 0 |
| P1.H0 | 0 (H0) | 500 / 0 | CorrDev | 0,05 | 500 | 25 | 0,050 | [0,033 ; 0,073] | — | — | — | — | niveau (référence) | 0 |
| P1.H0 | 0 (H0) | 500 / 0 | DW | 0,10 | 500 | 57 | 0,114 | [0,087 ; 0,145] | — | — | — | — | niveau (référence) | 0 |
| P1.H0 | 0 (H0) | 500 / 0 | DW | 0,05 | 500 | 24 | 0,048 | [0,031 ; 0,071] | — | — | — | — | niveau (référence) | 0 |
| P1.H0 | 0 (H0) | 500 / 0 | famille M3 | 0,10 | 500 | 42 | 0,084 | [0,061 ; 0,112] | — | — | — | — | niveau (référence) | — |
| P1.H0 | 0 (H0) | 500 / 0 | famille M3 | 0,05 | 500 | 18 | 0,036 | [0,021 ; 0,056] | — | — | — | — | niveau (référence) | — |
| P1.H0 | 0 (H0) | 500 / 0 | famille LC (globale) | 0,10 | 500 | 37 | 0,074 | [0,053 ; 0,101] | — | — | — | — | niveau (référence) | — |
| P1.H0 | 0 (H0) | 500 / 0 | famille LC (globale) | 0,05 | 500 | 14 | 0,028 | [0,015 ; 0,047] | — | — | — | — | niveau (référence) | — |
| P1.AR03 | 0,3 | 500 / 0 | CorrDev | 0,10 | 500 | 119 | 0,238 | [0,201 ; 0,278] | 0,088 | 500 | 96 / 21 | 1,2e-12 | faible | 0 |
| P1.AR03 | 0,3 | 500 / 0 | CorrDev | 0,05 | 500 | 73 | 0,146 | [0,116 ; 0,180] | 0,050 | 500 | 57 / 9 | 1,18e-09 | faible | 0 |
| P1.AR03 | 0,3 | 500 / 0 | DW | 0,10 | 500 | 59 | 0,118 | [0,091 ; 0,150] | 0,114 | 500 | 16 / 14 | 0,856 | non distinguée | 0 |
| P1.AR03 | 0,3 | 500 / 0 | DW | 0,05 | 500 | 35 | 0,070 | [0,049 ; 0,096] | 0,048 | 500 | 18 / 7 | 0,0433 | faible | 0 |
| P1.AR03 | 0,3 | 500 / 0 | famille M3 | 0,10 | 500 | 100 | 0,200 | [0,166 ; 0,238] | 0,084 | 500 | 69 / 11 | 2,05e-11 | faible | — |
| P1.AR03 | 0,3 | 500 / 0 | famille M3 | 0,05 | 500 | 63 | 0,126 | [0,098 ; 0,158] | 0,036 | 500 | 52 / 7 | 1,36e-09 | faible | — |
| P1.AR03 | 0,3 | 500 / 0 | famille LC (globale) | 0,10 | 500 | 82 | 0,164 | [0,133 ; 0,199] | 0,074 | 500 | 56 / 11 | 2,15e-08 | faible | — |
| P1.AR03 | 0,3 | 500 / 0 | famille LC (globale) | 0,05 | 500 | 44 | 0,088 | [0,065 ; 0,116] | 0,028 | 500 | 35 / 5 | 1,38e-06 | faible | — |
| P1.AR05 | 0,5 | 500 / 0 | CorrDev | 0,10 | 500 | 237 | 0,474 | [0,429 ; 0,519] | 0,088 | 500 | 214 / 21 | 1,94e-41 | intermédiaire | 0 |
| P1.AR05 | 0,5 | 500 / 0 | CorrDev | 0,05 | 500 | 167 | 0,334 | [0,293 ; 0,377] | 0,050 | 500 | 152 / 10 | 9,45e-34 | faible | 0 |
| P1.AR05 | 0,5 | 500 / 0 | DW | 0,10 | 500 | 63 | 0,126 | [0,098 ; 0,158] | 0,114 | 500 | 32 / 26 | 0,512 | non distinguée | 0 |
| P1.AR05 | 0,5 | 500 / 0 | DW | 0,05 | 500 | 32 | 0,064 | [0,044 ; 0,089] | 0,048 | 500 | 20 / 12 | 0,215 | non distinguée | 0 |
| P1.AR05 | 0,5 | 500 / 0 | famille M3 | 0,10 | 500 | 216 | 0,432 | [0,388 ; 0,477] | 0,084 | 500 | 187 / 13 | 1,18e-40 | faible | — |
| P1.AR05 | 0,5 | 500 / 0 | famille M3 | 0,05 | 500 | 144 | 0,288 | [0,249 ; 0,330] | 0,036 | 500 | 134 / 8 | 1,28e-30 | faible | — |
| P1.AR05 | 0,5 | 500 / 0 | famille LC (globale) | 0,10 | 500 | 146 | 0,292 | [0,252 ; 0,334] | 0,074 | 500 | 122 / 13 | 2,24e-23 | faible | — |
| P1.AR05 | 0,5 | 500 / 0 | famille LC (globale) | 0,05 | 500 | 97 | 0,194 | [0,160 ; 0,231] | 0,028 | 500 | 90 / 7 | 1,75e-19 | faible | — |
| P2.H0 | 0 (H0) | 500 / 0 | CorrDev | 0,10 | 500 | 57 | 0,114 | [0,087 ; 0,145] | — | — | — | — | niveau (référence) | 0 |
| P2.H0 | 0 (H0) | 500 / 0 | CorrDev | 0,05 | 500 | 22 | 0,044 | [0,028 ; 0,066] | — | — | — | — | niveau (référence) | 0 |
| P2.H0 | 0 (H0) | 500 / 0 | DW | 0,10 | 500 | 44 | 0,088 | [0,065 ; 0,116] | — | — | — | — | niveau (référence) | 0 |
| P2.H0 | 0 (H0) | 500 / 0 | DW | 0,05 | 500 | 23 | 0,046 | [0,029 ; 0,068] | — | — | — | — | niveau (référence) | 0 |
| P2.H0 | 0 (H0) | 500 / 0 | famille M3 | 0,10 | 500 | 57 | 0,114 | [0,087 ; 0,145] | — | — | — | — | niveau (référence) | — |
| P2.H0 | 0 (H0) | 500 / 0 | famille M3 | 0,05 | 500 | 25 | 0,050 | [0,033 ; 0,073] | — | — | — | — | niveau (référence) | — |
| P2.H0 | 0 (H0) | 500 / 0 | famille LC (globale) | 0,10 | 500 | 48 | 0,096 | [0,072 ; 0,125] | — | — | — | — | niveau (référence) | — |
| P2.H0 | 0 (H0) | 500 / 0 | famille LC (globale) | 0,05 | 500 | 23 | 0,046 | [0,029 ; 0,068] | — | — | — | — | niveau (référence) | — |
| P2.AR05 | 0,5 | 500 / 0 | CorrDev | 0,10 | 500 | 216 | 0,432 | [0,388 ; 0,477] | 0,114 | 500 | 192 / 33 | 1,83e-28 | faible | 0 |
| P2.AR05 | 0,5 | 500 / 0 | CorrDev | 0,05 | 500 | 173 | 0,346 | [0,304 ; 0,390] | 0,044 | 500 | 162 / 11 | 1,35e-35 | faible | 0 |
| P2.AR05 | 0,5 | 500 / 0 | DW | 0,10 | 500 | 44 | 0,088 | [0,065 ; 0,116] | 0,088 | 500 | 26 / 26 | 1 | non distinguée | 0 |
| P2.AR05 | 0,5 | 500 / 0 | DW | 0,05 | 500 | 25 | 0,050 | [0,033 ; 0,073] | 0,046 | 500 | 15 / 13 | 0,851 | non distinguée | 0 |
| P2.AR05 | 0,5 | 500 / 0 | famille M3 | 0,10 | 500 | 209 | 0,418 | [0,374 ; 0,463] | 0,114 | 500 | 173 / 21 | 6,38e-31 | faible | — |
| P2.AR05 | 0,5 | 500 / 0 | famille M3 | 0,05 | 500 | 148 | 0,296 | [0,256 ; 0,338] | 0,050 | 500 | 132 / 9 | 3,6e-29 | faible | — |
| P2.AR05 | 0,5 | 500 / 0 | famille LC (globale) | 0,10 | 500 | 170 | 0,340 | [0,299 ; 0,383] | 0,096 | 500 | 140 / 18 | 1,35e-24 | faible | — |
| P2.AR05 | 0,5 | 500 / 0 | famille LC (globale) | 0,05 | 500 | 112 | 0,224 | [0,188 ; 0,263] | 0,046 | 500 | 100 / 11 | 4,09e-19 | faible | — |

Constat de simulation sous plan (DGP du plan, scénario AR(1) de gen_triangle_ar1(), mêmes graines que la cellule H0 du plan : nombres aléatoires communs). Rejet : p Monte-Carlo de la ligne (p_mc, champ du moteur, B = 999 ; même grandeur que p: de #309) < α ; pour M3 et la ligne globale, p de la ligne de lecture conjointe (comme F1). Refus d'admission : par cellule (motifs en F2) ; une paire exige le triangle admis dans les deux cellules et la ligne présente des deux côtés. McNemar exact apparié bilatéral (n01 : la cellule AR rejette et H0 non). Classe (par. 4.5 de l'avis ; seuils 0,5 : convention déclarée) : non distinguée du niveau si p ≥ 0,05, sinon faible (borne haute < 0,5), substantielle (borne basse ≥ 0,5) ou intermédiaire ; évaluée mécaniquement, sans conclure. IC : erreur d'échantillonnage (fonction de R) ; l'erreur Monte-Carlo (fonction de B) fait partie de la procédure mesurée. Dernière colonne : triangles admis où la p retenue de la ligne diffère de sa p_mc (chaînes %.17g).

### F4 — #494, PM-3 : niveau de CorrDev des cellules H0 et recoupement avec #309

Premier cas : taux de rejet de CorrDev (p_mc < α, triangles admis, p non finie comptée comme non-rejet) classé sur l'échelle de #206/#309 contre la taille de référence ρ de l'oracle de #309 (relue, contrôle (rho 309)) ; signal si distorsion matérielle.

| Cellule | α | n (admis) | p non finies | ρ (#309) | rejets | taux [IC 95 %] | classe (#206/#309) | signal PM-3 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P1.H0 | 0,10 | 500 | 0 | 0,09751 | 44 | 0,08800 [0,06467 ; 0,11634] | compatible | non |
| P1.H0 | 0,05 | 500 | 0 | 0,04761 | 25 | 0,05000 [0,03262 ; 0,07293] | compatible | non |
| P2.H0 | 0,10 | 500 | 0 | 0,09751 | 57 | 0,11400 [0,08749 ; 0,14517] | compatible | non |
| P2.H0 | 0,05 | 500 | 0 | 0,04759 | 22 | 0,04400 [0,02778 ; 0,06586] | compatible | non |

Second cas : McNemar exact apparié bilatéral, sur les b de 1 à R admis ici et dans #309 (mêmes graines, triangles identiques : contrôle de recoupement), entre le rejet par p_mc de CorrDev ici et le rejet par p:CorrDev du brut de #309 (n01 : rejet ici et non dans #309) ; signal si p < 0,05.

| Cellule | α | paires (b admis des deux côtés) | obs:CorrDev identique | p identique | taux S9 | taux #309 (mêmes b) | McNemar n01 / n10 | McNemar bilatéral | signal PM-3 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P1.H0 | 0,10 | 500 | 500 / 500 | 500 / 500 | 0,088 | 0,088 | 0 / 0 | 1 | non |
| P1.H0 | 0,05 | 500 | 500 / 500 | 500 / 500 | 0,050 | 0,050 | 0 / 0 | 1 | non |
| P2.H0 | 0,10 | 500 | 500 / 500 | 500 / 500 | 0,114 | 0,114 | 0 / 0 | 1 | non |
| P2.H0 | 0,05 | 500 | 500 / 500 | 500 / 500 | 0,044 | 0,044 | 0 / 0 | 1 | non |

Signaux évalués mécaniquement, sans conclure : la lecture d'un signal revient à actuary puis au mainteneur (PM-3).

### Contrôles d'intégrité

- Familles : catalogue MW_CATALOGUE_MC du moteur non injecté (mw_bootstrap() et mw_tests() du moteur tel que chargé) : OK
- Familles, (copie fk) : fk_champ, fk_num, fk_membres, fk_etats, fk_etats_ok, fk_recalcul identiques (formals, corps) à celles de tests/calibration_mc_mw_t8.R (md5 facde7a8800b1e8e002df23cfdae438a) : OK
- Familles, (graines) de la mesure #309 : plages du volet A (celles de #206) triangles 20840001-20862000, bootstrap 20870001-20892000, oracle 20900001-20960000 ; plages du volet B triangles 32000001-32380000, bootstrap 32500001-32880000, oracle P2 33000001-33020000 ; plages de P3 triangles 34000001-34060000, bootstrap 34200001-34260000, oracle 34400001-34420000 ; les neuf plages sont disjointes deux à deux : oui ; graines réelles des cellules dans les plages déclarées : oui ; 73 littéraux de graine de huit chiffres dans 109 fichiers (R/engine.R, tests/*.R hors ce script, tests/unitaires/*.R), de 10000000 à 99999809 ; littéraux L dont [L ; L + 20000] touche une plage du volet B ou de P3 : aucun ; SEED_LOI_NULLE_SW 20260901, graine de reserve2 20260831 et réseau 20260831 + 1000 k ≤ 20760831 de tests/puissance_t8.R hors des plages : oui : OK
- Familles, graines des cellules dans les plages déclarées de #309 (PLAGES_B) ; cellules AR : graines de la cellule H0 du plan par construction (rang lu sur la même ligne de CELLULES), aucune graine nouvelle ; cellules à graines distinctes : disjointes de celles de la cellule H0 du plan : P1.H0 : triangle 32000001..32000500, bootstrap 32500001..32500500 (rang 1 de P1, b <= 1000 ; cellule H0) ; P1.CST20 : triangle 32020001..32020300, bootstrap 32520001..32520300 (rang 2 de P1, b <= 1000 ; disjointes de la cellule H0 du plan) ; P1.DCAL : triangle 32200001..32200300, bootstrap 32700001..32700300 (rang 11 de P1, b <= 500 ; disjointes de la cellule H0 du plan) ; P1.AR03 : triangle 32000001..32000500, bootstrap 32500001..32500500 (rang 1 de P1, b <= 1000 ; graines de la cellule H0 du plan) ; P1.AR05 : triangle 32000001..32000500, bootstrap 32500001..32500500 (rang 1 de P1, b <= 1000 ; graines de la cellule H0 du plan) ; P2.H0 : triangle 32260001..32260500, bootstrap 32760001..32760500 (rang 14 de P2, b <= 1000 ; cellule H0) ; P2.AR05 : triangle 32260001..32260500, bootstrap 32760001..32760500 (rang 14 de P2, b <= 1000 ; graines de la cellule H0 du plan) : OK
- Familles, (ar0) : gen_triangle_ar1() à ρ = 0 = triangle de H0 du plan sous la même graine (identical()) : P1 : 100 / 100 identiques (graines 32000001..32000100 ; 0 triangle(s) H0 incomplet(s) parmi eux) ; P2 : 100 / 100 identiques (graines 32260001..32260100 ; 0 triangle(s) H0 incomplet(s) parmi eux) : OK
- Familles, (ar1) : η reconstruits des triangles AR(1) (ε = (C(i, j + 1) − f_j C(i, j)) / (σ_j √C(i, j)), η = (ε_j − ρ ε_(j−1)) / √(1 − ρ²)) = flux stats::rnorm() de la graine à 1e-8 près, 20 graines par cellule : P1.AR03 (ρ = 0,3) : écart maximal 1.78e-14 sur 560 valeurs, triangles différents de H0 : 20 / 20 ; P1.AR05 (ρ = 0,5) : écart maximal 2.02e-14 sur 560 valeurs, triangles différents de H0 : 20 / 20 ; P2.AR05 (ρ = 0,5) : écart maximal 1.98e-14 sur 560 valeurs, triangles différents de H0 : 20 / 20 : OK
- Familles, (rho 309) : taille de référence de CorrDev (ρ 0,10 ; ρ 0,05) relue au tableau de #309 (docs/tableaux/20261021-issue309-puissance-mw.md, md5 0bc63866eba9bada0b9d46b14b327bc7) : P1 (ORA-A-N) 0,09751 ; 0,04761 : identique ; P2 (ORA-B-P2) 0,09751 ; 0,04759 : identique : OK
- Familles : statut admis ou refusé sur les 3100 triangles (0 refusé(s), motif compté en F2) : OK
- Familles : états des lignes de lecture conjointe cohérents (fk_etats() ; aucune clé ni préfixe hors de M1, M2, M3, M4, LC) sur les 3100 triangles admis : OK
- Familles, K-F3 (#297) : p, m_obs, err_mc et k de chaque ligne de lecture conjointe recalculés par une écriture indépendante (fk_recalcul()) et identiques à ceux de la ligne, à chaque triangle admis (3100) : OK
- Familles, par. 5.2 de l'avis : p_f < α ⇒ U_f = 1 sur tout triangle hors texte T-3a (familles et ligne globale, α = 0,10 et 0,05) ; cas T-3a où p_f < α et U_f = 0 : 0 : OK
- Familles, (i2) : tests et bootstrap identiques à ceux de run_engine() (identical()) sur 62 triangle(s) admis (b multiple de 50) : 62 OK : OK
- Familles, recoupement avec le brut de #309 (docs/tableaux/20261021-issue309-puissance-mw-brut.tsv, md5 f616a3bc2e9a0cb6ce255396b0130ba0 ; PM-3 de #494) : statut et obs:CorrDev identiques triangle par triangle : P1.H0 : 500 triangle(s) (b = 1..500), 500 trouvé(s) parmi 1000 lignes B-P1.H0 de #309, statut identique 500, admis des deux côtés 500, obs:CorrDev identique 500 / 500, p_mc de CorrDev identique à p:CorrDev 500 / 500 ; P2.H0 : 500 triangle(s) (b = 1..500), 500 trouvé(s) parmi 1000 lignes B-P2.H0 de #309, statut identique 500, admis des deux côtés 500, obs:CorrDev identique 500 / 500, p_mc de CorrDev identique à p:CorrDev 500 / 500 : OK
- Familles : catalogue MW_CATALOGUE_MC du moteur intact en fin de calcul : OK

Bilan : OK

