## Mesure #379 : puissance à T = 8 des p de famille et de la p globale, méthode lognormale

Statut : **constat de simulation sous plan** (alternatives du volet B sur le modèle ajusté aux jeux J1 et J2, hors modèle réglementaire), pour la procédure du moteur à B fini ; rien n'est transposé à d'autres jeux, géométries ou alternatives. Les p de famille restent plug-in et non exactes.

### T0 — provenance

| Grandeur | Valeur |
| --- | --- |
| Protocole | avis d'actuary docs/revues/20261127-s9-mesures/actuary-protocoles-etape-1.md, par. 5 ; décision Q-S9-1 (a) |
| Procédure par réplication | run_engine() complet : méthode premium, segment 1 de l'annexe II, données brutes, α = 0,10, theta_equiv = 0,10, B = 999 ; lignes de lecture conjointe de usp_tests() (engine_p_famille()) |
| Points | N (nulle) ; A (AR(1), ρ = 0,5) ; T (tendance, D = 2) ; R (rupture, t₀ = 4, Δ = 2) |
| Réplications par (jeu, point) | 300 (b = 1..300) ; tranches de 10 |
| Graines | matrice e du volet B : 20260931 (ligne b = 8 tirages consécutifs, commune aux points) ; bootstrap de la réplication b : 20260831 + 1000 b (commune aux points ; flux V3b du moteur + DECALAGE_GRAINE_FLUX_REGIME = 539169) ; aucune graine nouvelle |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Commit du calcul | caa38f1e96d8a1f2feb29401355a91fbdcd55631 |
| Arbre propre et code du dépôt | oui |
| Plateforme de calcul (R, système, machine, BLAS, LAPACK) | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.12.0 ; LAPACK : /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.12.0 (version 3.12.0) |
| Empreintes md5 du code exécuté | R/engine.R c7b767f5d9116c35a0a9237ffdd2d79a ; tests/outils_tests.R chargé (dépôt) cd6f78dd811f125f1755acc55e1fd228 ; script exécuté (dépôt) 249db40434aff7c2c3b0b719d3ca21b6 |
| Empreinte sans commentaires de R/engine.R (#231) | 15a74c3dbd831c56c259df106e9e4667 |
| J1 : modèle ajusté (usp_ajuster()) | J1 : tests/donnees/donnees_ln.csv (jeu des cas de référence) ; δ̂ = 1 ; γ̂ = -1.93433 ; β̂ = 0.728685 ; σ̂ = 0.10531 ; π̂ constant : TRUE |
| J2 : modèle ajusté (usp_ajuster()) | J2 : xi, yi de tests/unitaires/test_controles_numeriques.R (δ estimé intérieur) ; δ̂ = 0.663991 ; γ̂ = -2.31999 ; β̂ = 0.701657 ; σ̂ = 0.0689553 ; π̂ constant : FALSE |
| Dossier de travail | travail379ln (hors du dépôt) : 240 tranche(s), dont 24 calculée(s) par cette exécution |
| Durée | cette exécution : 741 s d'horloge, 4 processus ; somme des durées des réplications : 27089 s ; des contrôles de la chaîne : 993 s |
| Tableau brut | 2400 ligne(s) de données, md5 aded57c0107215abd79313123728ba4d |

### F1 — J1 : p de famille et p globale (ligne du moteur), U_f, comparaison au point N

| Point | Famille | α | n (ligne présente) | ligne L / T-3b / absente (hors n) | rejets p_f < α | π̂ | IC 95 % (C-P) | U_f = 1 | Û | IC 95 % (C-P) | π̂ − π̂(N) | Û − Û(N) | P(U_f = 1, p_f ≥ α) | paires (b, ligne présente en N et au point) | McNemar n01 / n10 | McNemar bilatéral (contre N) | McNemar unilatéral π < π(N) | classe (par. 4.5) | signal PM-3 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N (nulle) | B. | 0,10 | 300 | 300 / 0 / 0 | 37 | 0,123 | [0,088 ; 0,166] | 64 | 0,213 | [0,168 ; 0,264] | — | — | 0,090 | — | — | — | — | niveau (référence) | — |
| N (nulle) | B. | 0,05 | 300 | 300 / 0 / 0 | 17 | 0,057 | [0,033 ; 0,089] | 37 | 0,123 | [0,088 ; 0,166] | — | — | 0,067 | — | — | — | — | niveau (référence) | — |
| N (nulle) | D. | 0,10 | 300 | 300 / 0 / 0 | 33 | 0,110 | [0,077 ; 0,151] | 57 | 0,190 | [0,147 ; 0,239] | — | — | 0,080 | — | — | — | — | niveau (référence) | — |
| N (nulle) | D. | 0,05 | 300 | 300 / 0 / 0 | 12 | 0,040 | [0,021 ; 0,069] | 32 | 0,107 | [0,074 ; 0,147] | — | — | 0,067 | — | — | — | — | niveau (référence) | — |
| N (nulle) | E. | 0,10 | 300 | 300 / 0 / 0 | 34 | 0,113 | [0,080 ; 0,155] | 54 | 0,180 | [0,138 ; 0,228] | — | — | 0,067 | — | — | — | — | niveau (référence) | — |
| N (nulle) | E. | 0,05 | 300 | 300 / 0 / 0 | 17 | 0,057 | [0,033 ; 0,089] | 29 | 0,097 | [0,066 ; 0,136] | — | — | 0,040 | — | — | — | — | niveau (référence) | — |
| N (nulle) | F. | 0,10 | 300 | 300 / 0 / 0 | 38 | 0,127 | [0,091 ; 0,170] | 78 | 0,260 | [0,211 ; 0,314] | — | — | 0,133 | — | — | — | — | niveau (référence) | — |
| N (nulle) | F. | 0,05 | 300 | 300 / 0 / 0 | 18 | 0,060 | [0,036 ; 0,093] | 45 | 0,150 | [0,112 ; 0,196] | — | — | 0,090 | — | — | — | — | niveau (référence) | — |
| N (nulle) | LC (globale) | 0,10 | 300 | 300 / 0 / 0 | 34 | 0,113 | [0,080 ; 0,155] | 163 | 0,543 | [0,485 ; 0,601] | — | — | 0,430 | — | — | — | — | niveau (référence) | — |
| N (nulle) | LC (globale) | 0,05 | 300 | 300 / 0 / 0 | 18 | 0,060 | [0,036 ; 0,093] | 102 | 0,340 | [0,287 ; 0,397] | — | — | 0,280 | — | — | — | — | niveau (référence) | — |
| A (AR(1), ρ = 0,5) | B. | 0,10 | 300 | 300 / 0 / 0 | 101 | 0,337 | [0,283 ; 0,393] | 130 | 0,433 | [0,376 ; 0,491] | +0,213 | +0,220 | 0,097 | 300 | 68 / 4 | 4,62e-16 | 1 | faible | non |
| A (AR(1), ρ = 0,5) | B. | 0,05 | 300 | 300 / 0 / 0 | 60 | 0,200 | [0,156 ; 0,250] | 100 | 0,333 | [0,280 ; 0,390] | +0,143 | +0,210 | 0,133 | 300 | 45 / 2 | 1,6e-11 | 1 | faible | non |
| A (AR(1), ρ = 0,5) | D. | 0,10 | 300 | 300 / 0 / 0 | 21 | 0,070 | [0,044 ; 0,105] | 45 | 0,150 | [0,112 ; 0,196] | -0,040 | -0,040 | 0,080 | 300 | 14 / 26 | 0,0807 | 0,0403 | non distinguée | **oui** |
| A (AR(1), ρ = 0,5) | D. | 0,05 | 300 | 300 / 0 / 0 | 8 | 0,027 | [0,012 ; 0,052] | 20 | 0,067 | [0,041 ; 0,101] | -0,013 | -0,040 | 0,040 | 300 | 5 / 9 | 0,424 | 0,212 | non distinguée | non |
| A (AR(1), ρ = 0,5) | E. | 0,10 | 300 | 300 / 0 / 0 | 68 | 0,227 | [0,181 ; 0,278] | 112 | 0,373 | [0,318 ; 0,431] | +0,113 | +0,193 | 0,147 | 300 | 52 / 18 | 5,85e-05 | 1 | faible | non |
| A (AR(1), ρ = 0,5) | E. | 0,05 | 300 | 300 / 0 / 0 | 38 | 0,127 | [0,091 ; 0,170] | 58 | 0,193 | [0,150 ; 0,243] | +0,070 | +0,097 | 0,067 | 300 | 29 / 8 | 0,000753 | 1 | faible | non |
| A (AR(1), ρ = 0,5) | F. | 0,10 | 300 | 300 / 0 / 0 | 75 | 0,250 | [0,202 ; 0,303] | 126 | 0,420 | [0,364 ; 0,478] | +0,123 | +0,160 | 0,170 | 300 | 47 / 10 | 7,51e-07 | 1 | faible | non |
| A (AR(1), ρ = 0,5) | F. | 0,05 | 300 | 300 / 0 / 0 | 44 | 0,147 | [0,109 ; 0,192] | 83 | 0,277 | [0,227 ; 0,331] | +0,087 | +0,127 | 0,130 | 300 | 31 / 5 | 1,29e-05 | 1 | faible | non |
| A (AR(1), ρ = 0,5) | LC (globale) | 0,10 | 300 | 300 / 0 / 0 | 73 | 0,243 | [0,196 ; 0,296] | 207 | 0,690 | [0,634 ; 0,742] | +0,130 | +0,147 | 0,447 | 300 | 52 / 13 | 1,17e-06 | 1 | faible | non |
| A (AR(1), ρ = 0,5) | LC (globale) | 0,05 | 300 | 300 / 0 / 0 | 41 | 0,137 | [0,100 ; 0,181] | 140 | 0,467 | [0,409 ; 0,525] | +0,077 | +0,127 | 0,330 | 300 | 31 / 8 | 0,000294 | 1 | faible | non |
| T (tendance, D = 2) | B. | 0,10 | 300 | 300 / 0 / 0 | 113 | 0,377 | [0,322 ; 0,434] | 163 | 0,543 | [0,485 ; 0,601] | +0,253 | +0,330 | 0,167 | 300 | 90 / 14 | 9,24e-15 | 1 | faible | non |
| T (tendance, D = 2) | B. | 0,05 | 300 | 300 / 0 / 0 | 74 | 0,247 | [0,199 ; 0,299] | 110 | 0,367 | [0,312 ; 0,424] | +0,190 | +0,243 | 0,120 | 300 | 62 / 5 | 1,42e-13 | 1 | faible | non |
| T (tendance, D = 2) | D. | 0,10 | 300 | 300 / 0 / 0 | 29 | 0,097 | [0,066 ; 0,136] | 52 | 0,173 | [0,132 ; 0,221] | -0,013 | -0,017 | 0,077 | 300 | 21 / 25 | 0,659 | 0,329 | non distinguée | non |
| T (tendance, D = 2) | D. | 0,05 | 300 | 300 / 0 / 0 | 9 | 0,030 | [0,014 ; 0,056] | 24 | 0,080 | [0,052 ; 0,117] | -0,010 | -0,027 | 0,050 | 300 | 8 / 11 | 0,648 | 0,324 | non distinguée | non |
| T (tendance, D = 2) | E. | 0,10 | 300 | 300 / 0 / 0 | 59 | 0,197 | [0,153 ; 0,246] | 96 | 0,320 | [0,268 ; 0,376] | +0,083 | +0,140 | 0,123 | 300 | 48 / 23 | 0,00407 | 0,999 | faible | non |
| T (tendance, D = 2) | E. | 0,05 | 300 | 300 / 0 / 0 | 34 | 0,113 | [0,080 ; 0,155] | 57 | 0,190 | [0,147 ; 0,239] | +0,057 | +0,093 | 0,077 | 300 | 27 / 10 | 0,00763 | 0,999 | faible | non |
| T (tendance, D = 2) | F. | 0,10 | 300 | 300 / 0 / 0 | 84 | 0,280 | [0,230 ; 0,334] | 165 | 0,550 | [0,492 ; 0,607] | +0,153 | +0,290 | 0,270 | 300 | 66 / 20 | 6,67e-07 | 1 | faible | non |
| T (tendance, D = 2) | F. | 0,05 | 300 | 300 / 0 / 0 | 38 | 0,127 | [0,091 ; 0,170] | 106 | 0,353 | [0,299 ; 0,410] | +0,067 | +0,203 | 0,227 | 300 | 30 / 10 | 0,00222 | 1 | faible | non |
| T (tendance, D = 2) | LC (globale) | 0,10 | 300 | 300 / 0 / 0 | 67 | 0,223 | [0,177 ; 0,275] | 231 | 0,770 | [0,718 ; 0,816] | +0,110 | +0,227 | 0,547 | 300 | 54 / 21 | 0,000176 | 1 | faible | non |
| T (tendance, D = 2) | LC (globale) | 0,05 | 300 | 300 / 0 / 0 | 41 | 0,137 | [0,100 ; 0,181] | 161 | 0,537 | [0,478 ; 0,594] | +0,077 | +0,197 | 0,400 | 300 | 32 / 9 | 0,000431 | 1 | faible | non |
| R (rupture, t₀ = 4, Δ = 2) | B. | 0,10 | 300 | 300 / 0 / 0 | 151 | 0,503 | [0,445 ; 0,561] | 198 | 0,660 | [0,603 ; 0,713] | +0,380 | +0,447 | 0,157 | 300 | 128 / 14 | 3,22e-24 | 1 | intermédiaire | non |
| R (rupture, t₀ = 4, Δ = 2) | B. | 0,05 | 300 | 300 / 0 / 0 | 100 | 0,333 | [0,280 ; 0,390] | 148 | 0,493 | [0,435 ; 0,551] | +0,277 | +0,370 | 0,160 | 300 | 88 / 5 | 1,11e-20 | 1 | faible | non |
| R (rupture, t₀ = 4, Δ = 2) | D. | 0,10 | 300 | 300 / 0 / 0 | 22 | 0,073 | [0,047 ; 0,109] | 47 | 0,157 | [0,117 ; 0,203] | -0,037 | -0,033 | 0,083 | 300 | 18 / 29 | 0,144 | 0,0719 | non distinguée | non |
| R (rupture, t₀ = 4, Δ = 2) | D. | 0,05 | 300 | 300 / 0 / 0 | 9 | 0,030 | [0,014 ; 0,056] | 21 | 0,070 | [0,044 ; 0,105] | -0,010 | -0,037 | 0,040 | 300 | 7 / 10 | 0,629 | 0,315 | non distinguée | non |
| R (rupture, t₀ = 4, Δ = 2) | E. | 0,10 | 300 | 300 / 0 / 0 | 91 | 0,303 | [0,252 ; 0,359] | 169 | 0,563 | [0,505 ; 0,620] | +0,190 | +0,383 | 0,260 | 300 | 79 / 22 | 1,01e-08 | 1 | faible | non |
| R (rupture, t₀ = 4, Δ = 2) | E. | 0,05 | 300 | 300 / 0 / 0 | 60 | 0,200 | [0,156 ; 0,250] | 90 | 0,300 | [0,249 ; 0,355] | +0,143 | +0,203 | 0,100 | 300 | 54 / 11 | 6,03e-08 | 1 | faible | non |
| R (rupture, t₀ = 4, Δ = 2) | F. | 0,10 | 300 | 300 / 0 / 0 | 156 | 0,520 | [0,462 ; 0,578] | 234 | 0,780 | [0,729 ; 0,826] | +0,393 | +0,520 | 0,260 | 300 | 132 / 14 | 3,02e-25 | 1 | intermédiaire | non |
| R (rupture, t₀ = 4, Δ = 2) | F. | 0,05 | 300 | 300 / 0 / 0 | 97 | 0,323 | [0,271 ; 0,379] | 181 | 0,603 | [0,546 ; 0,659] | +0,263 | +0,453 | 0,280 | 300 | 86 / 7 | 2,08e-18 | 1 | faible | non |
| R (rupture, t₀ = 4, Δ = 2) | LC (globale) | 0,10 | 300 | 300 / 0 / 0 | 119 | 0,397 | [0,341 ; 0,454] | 252 | 0,840 | [0,794 ; 0,880] | +0,283 | +0,297 | 0,443 | 300 | 98 / 13 | 2,66e-17 | 1 | faible | non |
| R (rupture, t₀ = 4, Δ = 2) | LC (globale) | 0,05 | 300 | 300 / 0 / 0 | 78 | 0,260 | [0,211 ; 0,314] | 219 | 0,730 | [0,676 ; 0,779] | +0,200 | +0,390 | 0,470 | 300 | 68 / 8 | 5,63e-13 | 1 | faible | non |

n : réplications non écartées du point où la ligne est présente (k ≥ 2 ; convention de T-F1 de #297), une ligne absente (k ≤ 1) étant hors de n et comptée à part. p_f : p de la ligne de lecture conjointe telle que la rend le moteur (engine_p_famille(), champ p_mc) ; une ligne sans p (B effectif de famille < 50, texte T-3b) compte comme un non-rejet. U_f = 1 : au moins un membre de la ligne (mêmes membres, lus par fk_membres(), mêmes réplications) a une p Monte-Carlo < α. U_f n'est pas un test de niveau α : la comparaison se lit en excès sur le niveau (colonnes « − (N) »), comme le prix en puissance du contrôle de l'erreur, non comme un classement (par. 5.3 de l'avis). McNemar exact apparié contre N : les points d'une réplication b partagent la ligne e_b et la graine de bootstrap (nombres aléatoires communs) ; paires = réplications b où la ligne est présente en N et au point ; n01 : le point rejette et N non, n10 : l'inverse ; binomiale exacte de paramètre 1/2 sur n01 + n10 (avis d'actuary de l'étape 5, Q2). Classe (seuils 0,5 : convention déclarée) : non distinguée si McNemar bilatéral ≥ 0,05, sinon faible (borne haute < 0,5), substantielle (borne basse ≥ 0,5) ou intermédiaire. Signal PM-3 : McNemar unilatéral π(s) < π(N) < 0,05, évalué mécaniquement, sans conclure. IC : erreur d'échantillonnage du taux (fonction de R) ; l'erreur Monte-Carlo de chaque p (fonction de B) fait partie de la procédure mesurée.

Familles sans ligne sur ce jeu (k ≤ 1 sur toutes les réplications) : C., G.

### F2 — J1 : réplications, régimes, variante, contrôles

| Point | R | écartées (motifs) | δ̂* au bord 1 / au bord 0 / intérieur | variante V1 / V3b | chaîne : contrôlées / identiques / exclusion boucle / exclusion flux | k de la ligne globale (min – max) | T-3a : p_f < 0,10 et U_f = 0 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| N (nulle) | 300 | 0 | 142 / 146 / 12 | 288 / 12 | 30 / 30 / 0 / 0 | 17 – 23 | 0 |
| A (AR(1), ρ = 0,5) | 300 | 0 | 143 / 148 / 9 | 291 / 9 | 30 / 30 / 0 / 0 | 17 – 23 | 0 |
| T (tendance, D = 2) | 300 | 0 | 102 / 183 / 15 | 285 / 15 | 30 / 30 / 0 / 0 | 17 – 23 | 0 |
| R (rupture, t₀ = 4, Δ = 2) | 300 | 0 | 80 / 208 / 12 | 288 / 12 | 30 / 30 / 0 / 0 | 17 – 23 | 0 |

### F1 — J2 : p de famille et p globale (ligne du moteur), U_f, comparaison au point N

| Point | Famille | α | n (ligne présente) | ligne L / T-3b / absente (hors n) | rejets p_f < α | π̂ | IC 95 % (C-P) | U_f = 1 | Û | IC 95 % (C-P) | π̂ − π̂(N) | Û − Û(N) | P(U_f = 1, p_f ≥ α) | paires (b, ligne présente en N et au point) | McNemar n01 / n10 | McNemar bilatéral (contre N) | McNemar unilatéral π < π(N) | classe (par. 4.5) | signal PM-3 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N (nulle) | B. | 0,10 | 300 | 300 / 0 / 0 | 27 | 0,090 | [0,060 ; 0,128] | 72 | 0,240 | [0,193 ; 0,292] | — | — | 0,150 | — | — | — | — | niveau (référence) | — |
| N (nulle) | B. | 0,05 | 300 | 300 / 0 / 0 | 15 | 0,050 | [0,028 ; 0,081] | 39 | 0,130 | [0,094 ; 0,173] | — | — | 0,080 | — | — | — | — | niveau (référence) | — |
| N (nulle) | D. | 0,10 | 300 | 300 / 0 / 0 | 31 | 0,103 | [0,071 ; 0,143] | 68 | 0,227 | [0,181 ; 0,278] | — | — | 0,123 | — | — | — | — | niveau (référence) | — |
| N (nulle) | D. | 0,05 | 300 | 300 / 0 / 0 | 15 | 0,050 | [0,028 ; 0,081] | 33 | 0,110 | [0,077 ; 0,151] | — | — | 0,060 | — | — | — | — | niveau (référence) | — |
| N (nulle) | E. | 0,10 | 300 | 300 / 0 / 0 | 27 | 0,090 | [0,060 ; 0,128] | 63 | 0,210 | [0,165 ; 0,261] | — | — | 0,120 | — | — | — | — | niveau (référence) | — |
| N (nulle) | E. | 0,05 | 300 | 300 / 0 / 0 | 16 | 0,053 | [0,031 ; 0,085] | 26 | 0,087 | [0,057 ; 0,124] | — | — | 0,033 | — | — | — | — | niveau (référence) | — |
| N (nulle) | F. | 0,10 | 300 | 300 / 0 / 0 | 36 | 0,120 | [0,085 ; 0,162] | 77 | 0,257 | [0,208 ; 0,310] | — | — | 0,137 | — | — | — | — | niveau (référence) | — |
| N (nulle) | F. | 0,05 | 300 | 300 / 0 / 0 | 20 | 0,067 | [0,041 ; 0,101] | 42 | 0,140 | [0,103 ; 0,184] | — | — | 0,073 | — | — | — | — | niveau (référence) | — |
| N (nulle) | LC (globale) | 0,10 | 300 | 300 / 0 / 0 | 27 | 0,090 | [0,060 ; 0,128] | 183 | 0,610 | [0,552 ; 0,666] | — | — | 0,520 | — | — | — | — | niveau (référence) | — |
| N (nulle) | LC (globale) | 0,05 | 300 | 300 / 0 / 0 | 12 | 0,040 | [0,021 ; 0,069] | 102 | 0,340 | [0,287 ; 0,397] | — | — | 0,300 | — | — | — | — | niveau (référence) | — |
| A (AR(1), ρ = 0,5) | B. | 0,10 | 300 | 300 / 0 / 0 | 63 | 0,210 | [0,165 ; 0,261] | 142 | 0,473 | [0,416 ; 0,532] | +0,120 | +0,233 | 0,263 | 300 | 48 / 12 | 3,18e-06 | 1 | faible | non |
| A (AR(1), ρ = 0,5) | B. | 0,05 | 300 | 300 / 0 / 0 | 33 | 0,110 | [0,077 ; 0,151] | 78 | 0,260 | [0,211 ; 0,314] | +0,060 | +0,130 | 0,150 | 300 | 30 / 12 | 0,00792 | 0,999 | faible | non |
| A (AR(1), ρ = 0,5) | D. | 0,10 | 300 | 300 / 0 / 0 | 27 | 0,090 | [0,060 ; 0,128] | 50 | 0,167 | [0,126 ; 0,214] | -0,013 | -0,060 | 0,077 | 300 | 20 / 24 | 0,652 | 0,326 | non distinguée | non |
| A (AR(1), ρ = 0,5) | D. | 0,05 | 300 | 300 / 0 / 0 | 15 | 0,050 | [0,028 ; 0,081] | 28 | 0,093 | [0,063 ; 0,132] | +0,000 | -0,017 | 0,043 | 300 | 11 / 11 | 1 | 0,584 | non distinguée | non |
| A (AR(1), ρ = 0,5) | E. | 0,10 | 300 | 300 / 0 / 0 | 54 | 0,180 | [0,138 ; 0,228] | 117 | 0,390 | [0,334 ; 0,448] | +0,090 | +0,180 | 0,210 | 300 | 41 / 14 | 0,000355 | 1 | faible | non |
| A (AR(1), ρ = 0,5) | E. | 0,05 | 300 | 300 / 0 / 0 | 30 | 0,100 | [0,068 ; 0,140] | 52 | 0,173 | [0,132 ; 0,221] | +0,047 | +0,087 | 0,073 | 300 | 23 / 9 | 0,0201 | 0,996 | faible | non |
| A (AR(1), ρ = 0,5) | F. | 0,10 | 300 | 300 / 0 / 0 | 68 | 0,227 | [0,181 ; 0,278] | 132 | 0,440 | [0,383 ; 0,498] | +0,107 | +0,183 | 0,213 | 300 | 43 / 11 | 1,4e-05 | 1 | faible | non |
| A (AR(1), ρ = 0,5) | F. | 0,05 | 300 | 300 / 0 / 0 | 37 | 0,123 | [0,088 ; 0,166] | 89 | 0,297 | [0,246 ; 0,352] | +0,057 | +0,157 | 0,173 | 300 | 23 / 6 | 0,00232 | 1 | faible | non |
| A (AR(1), ρ = 0,5) | LC (globale) | 0,10 | 300 | 300 / 0 / 0 | 55 | 0,183 | [0,141 ; 0,232] | 223 | 0,743 | [0,690 ; 0,792] | +0,093 | +0,133 | 0,560 | 300 | 40 / 12 | 0,000128 | 1 | faible | non |
| A (AR(1), ρ = 0,5) | LC (globale) | 0,05 | 300 | 300 / 0 / 0 | 26 | 0,087 | [0,057 ; 0,124] | 152 | 0,507 | [0,449 ; 0,565] | +0,047 | +0,167 | 0,420 | 300 | 22 / 8 | 0,0161 | 0,997 | faible | non |
| T (tendance, D = 2) | B. | 0,10 | 300 | 300 / 0 / 0 | 53 | 0,177 | [0,135 ; 0,225] | 120 | 0,400 | [0,344 ; 0,458] | +0,087 | +0,160 | 0,223 | 300 | 42 / 16 | 0,000862 | 1 | faible | non |
| T (tendance, D = 2) | B. | 0,05 | 300 | 300 / 0 / 0 | 23 | 0,077 | [0,049 ; 0,113] | 71 | 0,237 | [0,190 ; 0,289] | +0,027 | +0,107 | 0,160 | 300 | 20 / 12 | 0,215 | 0,945 | non distinguée | non |
| T (tendance, D = 2) | D. | 0,10 | 300 | 300 / 0 / 0 | 30 | 0,100 | [0,068 ; 0,140] | 55 | 0,183 | [0,141 ; 0,232] | -0,003 | -0,043 | 0,083 | 300 | 22 / 23 | 1 | 0,5 | non distinguée | non |
| T (tendance, D = 2) | D. | 0,05 | 300 | 300 / 0 / 0 | 11 | 0,037 | [0,018 ; 0,065] | 32 | 0,107 | [0,074 ; 0,147] | -0,013 | -0,003 | 0,070 | 300 | 8 / 12 | 0,503 | 0,252 | non distinguée | non |
| T (tendance, D = 2) | E. | 0,10 | 300 | 300 / 0 / 0 | 54 | 0,180 | [0,138 ; 0,228] | 97 | 0,323 | [0,271 ; 0,379] | +0,090 | +0,113 | 0,143 | 300 | 43 / 16 | 0,000584 | 1 | faible | non |
| T (tendance, D = 2) | E. | 0,05 | 300 | 300 / 0 / 0 | 33 | 0,110 | [0,077 ; 0,151] | 53 | 0,177 | [0,135 ; 0,225] | +0,057 | +0,090 | 0,067 | 300 | 27 / 10 | 0,00763 | 0,999 | faible | non |
| T (tendance, D = 2) | F. | 0,10 | 300 | 300 / 0 / 0 | 77 | 0,257 | [0,208 ; 0,310] | 172 | 0,573 | [0,515 ; 0,630] | +0,137 | +0,317 | 0,317 | 300 | 62 / 21 | 7,51e-06 | 1 | faible | non |
| T (tendance, D = 2) | F. | 0,05 | 300 | 300 / 0 / 0 | 39 | 0,130 | [0,094 ; 0,173] | 111 | 0,370 | [0,315 ; 0,427] | +0,063 | +0,230 | 0,240 | 300 | 31 / 12 | 0,0054 | 0,999 | faible | non |
| T (tendance, D = 2) | LC (globale) | 0,10 | 300 | 300 / 0 / 0 | 39 | 0,130 | [0,094 ; 0,173] | 234 | 0,780 | [0,729 ; 0,826] | +0,040 | +0,170 | 0,650 | 300 | 32 / 20 | 0,126 | 0,965 | non distinguée | non |
| T (tendance, D = 2) | LC (globale) | 0,05 | 300 | 300 / 0 / 0 | 20 | 0,067 | [0,041 ; 0,101] | 156 | 0,520 | [0,462 ; 0,578] | +0,027 | +0,180 | 0,453 | 300 | 15 / 7 | 0,134 | 0,974 | non distinguée | non |
| R (rupture, t₀ = 4, Δ = 2) | B. | 0,10 | 300 | 300 / 0 / 0 | 63 | 0,210 | [0,165 ; 0,261] | 146 | 0,487 | [0,429 ; 0,545] | +0,120 | +0,247 | 0,277 | 300 | 56 / 20 | 4,37e-05 | 1 | faible | non |
| R (rupture, t₀ = 4, Δ = 2) | B. | 0,05 | 300 | 300 / 0 / 0 | 34 | 0,113 | [0,080 ; 0,155] | 89 | 0,297 | [0,246 ; 0,352] | +0,063 | +0,167 | 0,183 | 300 | 31 / 12 | 0,0054 | 0,999 | faible | non |
| R (rupture, t₀ = 4, Δ = 2) | D. | 0,10 | 300 | 300 / 0 / 0 | 33 | 0,110 | [0,077 ; 0,151] | 51 | 0,170 | [0,129 ; 0,217] | +0,007 | -0,057 | 0,060 | 300 | 28 / 26 | 0,892 | 0,658 | non distinguée | non |
| R (rupture, t₀ = 4, Δ = 2) | D. | 0,05 | 300 | 300 / 0 / 0 | 13 | 0,043 | [0,023 ; 0,073] | 33 | 0,110 | [0,077 ; 0,151] | -0,007 | +0,000 | 0,067 | 300 | 12 / 14 | 0,845 | 0,423 | non distinguée | non |
| R (rupture, t₀ = 4, Δ = 2) | E. | 0,10 | 300 | 300 / 0 / 0 | 100 | 0,333 | [0,280 ; 0,390] | 169 | 0,563 | [0,505 ; 0,620] | +0,243 | +0,353 | 0,230 | 300 | 90 / 17 | 3,51e-13 | 1 | faible | non |
| R (rupture, t₀ = 4, Δ = 2) | E. | 0,05 | 300 | 300 / 0 / 0 | 56 | 0,187 | [0,144 ; 0,235] | 95 | 0,317 | [0,264 ; 0,373] | +0,133 | +0,230 | 0,130 | 300 | 51 / 11 | 2,78e-07 | 1 | faible | non |
| R (rupture, t₀ = 4, Δ = 2) | F. | 0,10 | 300 | 300 / 0 / 0 | 150 | 0,500 | [0,442 ; 0,558] | 231 | 0,770 | [0,718 ; 0,816] | +0,380 | +0,513 | 0,270 | 300 | 127 / 13 | 1,14e-24 | 1 | intermédiaire | non |
| R (rupture, t₀ = 4, Δ = 2) | F. | 0,05 | 300 | 300 / 0 / 0 | 101 | 0,337 | [0,283 ; 0,393] | 179 | 0,597 | [0,539 ; 0,653] | +0,270 | +0,457 | 0,260 | 300 | 89 / 8 | 2e-18 | 1 | faible | non |
| R (rupture, t₀ = 4, Δ = 2) | LC (globale) | 0,10 | 300 | 300 / 0 / 0 | 92 | 0,307 | [0,255 ; 0,362] | 251 | 0,837 | [0,790 ; 0,877] | +0,217 | +0,227 | 0,530 | 300 | 81 / 16 | 1,24e-11 | 1 | faible | non |
| R (rupture, t₀ = 4, Δ = 2) | LC (globale) | 0,05 | 300 | 300 / 0 / 0 | 54 | 0,180 | [0,138 ; 0,228] | 206 | 0,687 | [0,631 ; 0,739] | +0,140 | +0,347 | 0,507 | 300 | 49 / 7 | 7,46e-09 | 1 | faible | non |

n : réplications non écartées du point où la ligne est présente (k ≥ 2 ; convention de T-F1 de #297), une ligne absente (k ≤ 1) étant hors de n et comptée à part. p_f : p de la ligne de lecture conjointe telle que la rend le moteur (engine_p_famille(), champ p_mc) ; une ligne sans p (B effectif de famille < 50, texte T-3b) compte comme un non-rejet. U_f = 1 : au moins un membre de la ligne (mêmes membres, lus par fk_membres(), mêmes réplications) a une p Monte-Carlo < α. U_f n'est pas un test de niveau α : la comparaison se lit en excès sur le niveau (colonnes « − (N) »), comme le prix en puissance du contrôle de l'erreur, non comme un classement (par. 5.3 de l'avis). McNemar exact apparié contre N : les points d'une réplication b partagent la ligne e_b et la graine de bootstrap (nombres aléatoires communs) ; paires = réplications b où la ligne est présente en N et au point ; n01 : le point rejette et N non, n10 : l'inverse ; binomiale exacte de paramètre 1/2 sur n01 + n10 (avis d'actuary de l'étape 5, Q2). Classe (seuils 0,5 : convention déclarée) : non distinguée si McNemar bilatéral ≥ 0,05, sinon faible (borne haute < 0,5), substantielle (borne basse ≥ 0,5) ou intermédiaire. Signal PM-3 : McNemar unilatéral π(s) < π(N) < 0,05, évalué mécaniquement, sans conclure. IC : erreur d'échantillonnage du taux (fonction de R) ; l'erreur Monte-Carlo de chaque p (fonction de B) fait partie de la procédure mesurée.

Familles sans ligne sur ce jeu (k ≤ 1 sur toutes les réplications) : C., G.

### F2 — J2 : réplications, régimes, variante, contrôles

| Point | R | écartées (motifs) | δ̂* au bord 1 / au bord 0 / intérieur | variante V1 / V3b | chaîne : contrôlées / identiques / exclusion boucle / exclusion flux | k de la ligne globale (min – max) | T-3a : p_f < 0,10 et U_f = 0 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| N (nulle) | 300 | 0 | 105 / 124 / 71 | 229 / 71 | 30 / 30 / 0 / 0 | 17 – 22 | 0 |
| A (AR(1), ρ = 0,5) | 300 | 0 | 83 / 156 / 61 | 239 / 61 | 30 / 30 / 0 / 0 | 17 – 22 | 0 |
| T (tendance, D = 2) | 300 | 0 | 53 / 177 / 70 | 230 / 70 | 30 / 30 / 0 / 0 | 17 – 23 | 0 |
| R (rupture, t₀ = 4, Δ = 2) | 300 | 0 | 91 / 127 / 82 | 218 / 82 | 30 / 30 / 0 / 0 | 17 – 23 | 0 |

### Contrôles d'intégrité

- Critère 6, dépôt intact (début) : git status de R/ et tests/reference/ vide : OK
- Familles, (copie fk) : fk_champ, fk_num, fk_membres, fk_etats, fk_etats_ok, fk_recalcul identiques (formals, corps) à celles de tests/calibration_mc_t8.R (md5 699e118235485568e304c2279de82e23) : OK
- Familles, J1 : point N identique à usp_simuler(FIT0) sous la graine de la matrice e (au bit près) : OK
- Familles, J2 : point N identique à usp_simuler(FIT0) sous la graine de la matrice e (au bit près) : OK
- Familles : statut ok ou écart sur les 2400 réplications (0 écartée(s), motif compté en F2) : OK
- Familles : états des lignes de lecture conjointe cohérents (fk_etats() ; aucune clé ni préfixe hors de B., C., D., E., F., G., LC) sur les 2400 réplications non écartées : OK
- Familles, K-F3 (#297) : p, m_obs, err_mc et k de chaque ligne de lecture conjointe recalculés par une écriture indépendante (fk_recalcul()) et identiques à ceux de la ligne, à chaque réplication non écartée (2400) : OK
- Familles, par. 5.2 de l'avis : p_f < α ⇒ U_f = 1 sur toute réplication hors texte T-3a (familles et ligne globale, α = 0,10 et 0,05) ; cas T-3a où p_f < α et U_f = 0 : 0 : OK
- Familles, chaîne réduite (par. 5.1 de l'avis) : p_mc des douze lignes de LIG_B égales à celles de run_engine() hors écarts d'exclusion, sur 240 réplication(s) (b multiple de 10) : 240 identique(s), 0 exclusion (boucle), 0 exclusion (flux V3b), 0 échec(s) ou contrôle(s) manquant(s) : OK
- Critère 6, dépôt intact (fin) : git status de R/ et tests/reference/ vide : OK
- Critère 6, dépôt intact (fin) : md5 de R/ et tests/reference/ inchangés depuis le début : OK

Bilan : OK

