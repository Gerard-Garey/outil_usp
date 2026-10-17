## Puissance à T = 8 de sup-F, OLS-CUSUM et Grubbs (z et ratios bruts), volet A : p Monte-Carlo à π̂ constant, jeu J1 (issue #313)

Paramètres : R=20000 ; R0 (loi nulle)=100000 ; B de contrôle=9999 ; graine=20260930 ; graine-ic=20260831 ; α=0,10 (principal) et 0,05 ; T=8

Statut : **constat de simulation sous des alternatives choisies, hors modèle réglementaire**. Statistiques calculées par les entrées supF, CUSUM, Grubbs, supFr, CUSUMr, Grubbsr du catalogue USP_CATALOGUE_MC (stat_supF(), stat_cusum(), test_grubbs()) sur l* = ln r* − moyenne (à la place de z, image affine croissante de z à π̂ constant ; statistiques invariantes) et u* = r* − moyenne, sans réajustement. p Monte-Carlo = (1 + #{S0 ≥ s}) / (R0 + 1), formule de engine_p_mc() en queue haute, sur une loi nulle S0 de R0 séries usp_simuler(FIT0) sans réajustement : puissance du test à δ = 1 imposé et loi nulle simulée sans réajustement, B infini à l'erreur de S0 près : référence idéalisée de la ligne du moteur, non la puissance de la p-value retenue par le moteur ; séries alternatives non réajustées (part des cas où δ̂* serait intérieur, où le moteur retient la p conditionnelle V3h, #240, non mesurée). Effet de B seul (B = 999, hors réajustement) : tableau S7. La loi Monte-Carlo du moteur réajuste chaque réplication : écart mesuré au tableau S5. Rejet si p < α. Les lignes sur ratios bruts ne sont pas invariantes : leur puissance dépend du sens de l'écart et de l'écart-type de ln r_t, √(1/π̂) = 0,1438 sur J1 (fonction croissante de σ̂/β̂ = 0,1445), et non de σ̂ seul. Sur les lignes z, C− et C ont la même loi (statistiques paires, symétrie de la loi normale). Alternatives et nombres aléatoires communs : ceux du volet A de l'issue #116 (en-tête de tests/puissance_t8.R), plus la tendance D = 1,75 et les contaminations C et C−, vingt-deux points en tout. IC : incertitude Monte-Carlo (fonction de R), pas l'erreur d'approximation en T.

### T0 -- contexte

| Grandeur | Valeur |
| --- | --- |
| Jeu | J1 : tests/donnees/donnees_ln.csv (jeu des cas de référence) |
| Modèle ajusté (usp_ajuster()) | δ̂ = 1 ; γ̂ = -1.93433 ; β̂ = 0.728685 ; σ̂ = 0.10531 ; π̂ constant : TRUE |
| Loi nulle S0 | R0 = 100000 séries usp_simuler(FIT0), graine 20260932 ; 23.0 s |
| J1 observé : p sur S0 / p_mc de run_engine() (B = 999) | supF 0,8525 / 0,8400 ; CUSUM 0,8310 / 0,8170 ; Grubbs 0,8815 / 0,8610 ; supFr 0,9332 / 0,9310 ; CUSUMr 0,7616 / 0,7560 ; Grubbsr 0,7840 / 0,7770 |
| Année contaminée (scénarios C et C−) | t_c(b) = 1 + (b − 1) mod 8 |
| Plateforme de calcul (R, système, machine, BLAS, LAPACK) | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.12.0 ; LAPACK : /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.12.0 (version 3.12.0) |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Graines | matrice e 20260930 ; S0 20260932 ; boucle de contrôle S5 20260831 |
| Commit | 26941e5011175747aa90e9307468160a3178bd2f |
| Réplications par point | 20000 |
| Durée (s) | loi nulle S0 23.0 ; réplications du volet A (toutes lignes) 1183.8 ; boucle S5 13.8 ; volet A total 1235.6 |

### S1 -- taux de rejet, α = 0,10

| Point | sup-F (z) : taux | IC 95 % (C-P) | OLS-CUSUM (z) : taux | IC 95 % (C-P) | Grubbs (z) : taux | IC 95 % (C-P) | sup-F (ratios bruts) : taux | IC 95 % (C-P) | OLS-CUSUM (ratios bruts) : taux | IC 95 % (C-P) | Grubbs (ratios bruts) : taux | IC 95 % (C-P) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N (nulle) | 0,102 | [0,098 ; 0,106] | 0,102 | [0,097 ; 0,106] | 0,100 | [0,096 ; 0,104] | 0,101 | [0,097 ; 0,105] | 0,103 | [0,099 ; 0,107] | 0,099 | [0,095 ; 0,103] |
| A (AR(1), ρ = -0,5) | 0,019 | [0,018 ; 0,022] | 0,019 | [0,017 ; 0,021] | 0,074 | [0,070 ; 0,078] | 0,020 | [0,018 ; 0,022] | 0,019 | [0,017 ; 0,021] | 0,074 | [0,070 ; 0,077] |
| A (AR(1), ρ = 0,3) | 0,212 | [0,207 ; 0,218] | 0,210 | [0,204 ; 0,215] | 0,096 | [0,092 ; 0,100] | 0,212 | [0,206 ; 0,218] | 0,209 | [0,203 ; 0,215] | 0,089 | [0,085 ; 0,093] |
| A (AR(1), ρ = 0,5) | 0,315 | [0,309 ; 0,322] | 0,306 | [0,300 ; 0,312] | 0,088 | [0,084 ; 0,092] | 0,315 | [0,309 ; 0,322] | 0,308 | [0,302 ; 0,315] | 0,082 | [0,078 ; 0,086] |
| A (AR(1), ρ = 0,7) | 0,429 | [0,422 ; 0,436] | 0,413 | [0,407 ; 0,420] | 0,078 | [0,075 ; 0,082] | 0,427 | [0,420 ; 0,434] | 0,414 | [0,407 ; 0,421] | 0,073 | [0,069 ; 0,076] |
| A (AR(1), ρ = 0,9) | 0,539 | [0,532 ; 0,546] | 0,524 | [0,518 ; 0,531] | 0,074 | [0,070 ; 0,078] | 0,539 | [0,533 ; 0,546] | 0,525 | [0,518 ; 0,532] | 0,066 | [0,063 ; 0,069] |
| T (tendance, D = 1) | 0,193 | [0,187 ; 0,198] | 0,192 | [0,186 ; 0,197] | 0,098 | [0,094 ; 0,102] | 0,191 | [0,186 ; 0,196] | 0,194 | [0,188 ; 0,199] | 0,098 | [0,094 ; 0,102] |
| T (tendance, D = 2) | 0,407 | [0,400 ; 0,413] | 0,411 | [0,404 ; 0,418] | 0,094 | [0,090 ; 0,098] | 0,401 | [0,394 ; 0,408] | 0,410 | [0,403 ; 0,417] | 0,097 | [0,092 ; 0,101] |
| T (tendance, D = 3) | 0,639 | [0,632 ; 0,645] | 0,645 | [0,639 ; 0,652] | 0,073 | [0,069 ; 0,076] | 0,635 | [0,628 ; 0,641] | 0,641 | [0,634 ; 0,648] | 0,088 | [0,084 ; 0,092] |
| T (tendance, D = 1,75 : 0,25 σ par an) | 0,349 | [0,342 ; 0,356] | 0,351 | [0,344 ; 0,357] | 0,097 | [0,093 ; 0,101] | 0,346 | [0,339 ; 0,352] | 0,348 | [0,341 ; 0,355] | 0,099 | [0,094 ; 0,103] |
| R (rupture, t₀ = 4, Δ = 1) | 0,264 | [0,258 ; 0,270] | 0,299 | [0,293 ; 0,306] | 0,094 | [0,090 ; 0,098] | 0,262 | [0,255 ; 0,268] | 0,299 | [0,293 ; 0,306] | 0,096 | [0,092 ; 0,100] |
| R (rupture, t₀ = 4, Δ = 2) | 0,623 | [0,616 ; 0,630] | 0,699 | [0,693 ; 0,706] | 0,048 | [0,045 ; 0,051] | 0,614 | [0,607 ; 0,620] | 0,691 | [0,685 ; 0,698] | 0,061 | [0,057 ; 0,064] |
| R (rupture, t₀ = 4, Δ = 3) | 0,899 | [0,895 ; 0,903] | 0,946 | [0,942 ; 0,949] | 0,011 | [0,010 ; 0,013] | 0,888 | [0,883 ; 0,892] | 0,939 | [0,936 ; 0,943] | 0,025 | [0,022 ; 0,027] |
| R (rupture, t₀ = 6, Δ = 2) | 0,470 | [0,464 ; 0,477] | 0,370 | [0,364 ; 0,377] | 0,097 | [0,093 ; 0,101] | 0,522 | [0,515 ; 0,529] | 0,416 | [0,409 ; 0,423] | 0,151 | [0,146 ; 0,156] |
| V (volume, κ = 2) | 0,130 | [0,125 ; 0,134] | 0,126 | [0,121 ; 0,130] | 0,171 | [0,165 ; 0,176] | 0,127 | [0,122 ; 0,132] | 0,124 | [0,120 ; 0,129] | 0,184 | [0,179 ; 0,190] |
| V (volume, κ = 3) | 0,158 | [0,153 ; 0,163] | 0,151 | [0,146 ; 0,156] | 0,243 | [0,237 ; 0,249] | 0,155 | [0,150 ; 0,160] | 0,148 | [0,143 ; 0,153] | 0,285 | [0,278 ; 0,291] |
| C (contamination, λ = 3) | 0,080 | [0,076 ; 0,084] | 0,072 | [0,069 ; 0,076] | 0,362 | [0,355 ; 0,369] | 0,075 | [0,072 ; 0,079] | 0,063 | [0,060 ; 0,067] | 0,503 | [0,496 ; 0,510] |
| C (contamination, λ = 4) | 0,064 | [0,061 ; 0,068] | 0,050 | [0,047 ; 0,053] | 0,613 | [0,606 ; 0,620] | 0,056 | [0,053 ; 0,060] | 0,037 | [0,035 ; 0,040] | 0,779 | [0,773 ; 0,785] |
| C (contamination, λ = 5) | 0,052 | [0,049 ; 0,056] | 0,032 | [0,029 ; 0,034] | 0,828 | [0,823 ; 0,833] | 0,040 | [0,037 ; 0,043] | 0,019 | [0,017 ; 0,021] | 0,936 | [0,932 ; 0,939] |
| C− (contamination vers le bas, λ = 3) | 0,080 | [0,076 ; 0,084] | 0,072 | [0,069 ; 0,076] | 0,353 | [0,347 ; 0,360] | 0,085 | [0,081 ; 0,089] | 0,080 | [0,076 ; 0,084] | 0,175 | [0,170 ; 0,181] |
| C− (contamination vers le bas, λ = 4) | 0,065 | [0,061 ; 0,068] | 0,052 | [0,049 ; 0,055] | 0,607 | [0,600 ; 0,613] | 0,072 | [0,069 ; 0,076] | 0,065 | [0,062 ; 0,068] | 0,299 | [0,293 ; 0,306] |
| C− (contamination vers le bas, λ = 5) | 0,052 | [0,049 ; 0,055] | 0,031 | [0,029 ; 0,034] | 0,821 | [0,815 ; 0,826] | 0,061 | [0,058 ; 0,064] | 0,051 | [0,048 ; 0,055] | 0,457 | [0,450 ; 0,463] |

### S2 -- taux de rejet, α = 0,05 (complément)

| Point | sup-F (z) : taux | IC 95 % (C-P) | OLS-CUSUM (z) : taux | IC 95 % (C-P) | Grubbs (z) : taux | IC 95 % (C-P) | sup-F (ratios bruts) : taux | IC 95 % (C-P) | OLS-CUSUM (ratios bruts) : taux | IC 95 % (C-P) | Grubbs (ratios bruts) : taux | IC 95 % (C-P) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N (nulle) | 0,052 | [0,049 ; 0,056] | 0,051 | [0,048 ; 0,054] | 0,050 | [0,047 ; 0,053] | 0,052 | [0,049 ; 0,056] | 0,051 | [0,048 ; 0,054] | 0,049 | [0,046 ; 0,052] |
| A (AR(1), ρ = -0,5) | 0,007 | [0,006 ; 0,009] | 0,008 | [0,007 ; 0,009] | 0,035 | [0,032 ; 0,038] | 0,008 | [0,007 ; 0,009] | 0,008 | [0,007 ; 0,010] | 0,035 | [0,033 ; 0,038] |
| A (AR(1), ρ = 0,3) | 0,125 | [0,120 ; 0,130] | 0,124 | [0,120 ; 0,129] | 0,047 | [0,044 ; 0,050] | 0,123 | [0,119 ; 0,128] | 0,123 | [0,118 ; 0,128] | 0,045 | [0,043 ; 0,048] |
| A (AR(1), ρ = 0,5) | 0,201 | [0,196 ; 0,207] | 0,200 | [0,195 ; 0,206] | 0,043 | [0,040 ; 0,046] | 0,200 | [0,195 ; 0,206] | 0,199 | [0,194 ; 0,205] | 0,040 | [0,037 ; 0,042] |
| A (AR(1), ρ = 0,7) | 0,305 | [0,298 ; 0,311] | 0,297 | [0,290 ; 0,303] | 0,038 | [0,036 ; 0,041] | 0,300 | [0,294 ; 0,306] | 0,296 | [0,290 ; 0,302] | 0,034 | [0,032 ; 0,037] |
| A (AR(1), ρ = 0,9) | 0,416 | [0,409 ; 0,423] | 0,401 | [0,395 ; 0,408] | 0,036 | [0,033 ; 0,039] | 0,412 | [0,405 ; 0,419] | 0,401 | [0,394 ; 0,408] | 0,031 | [0,029 ; 0,034] |
| T (tendance, D = 1) | 0,109 | [0,104 ; 0,113] | 0,108 | [0,104 ; 0,113] | 0,050 | [0,047 ; 0,053] | 0,106 | [0,102 ; 0,111] | 0,107 | [0,103 ; 0,112] | 0,050 | [0,047 ; 0,053] |
| T (tendance, D = 2) | 0,256 | [0,250 ; 0,262] | 0,263 | [0,257 ; 0,269] | 0,045 | [0,042 ; 0,048] | 0,255 | [0,249 ; 0,261] | 0,260 | [0,254 ; 0,266] | 0,048 | [0,045 ; 0,051] |
| T (tendance, D = 3) | 0,439 | [0,433 ; 0,446] | 0,457 | [0,450 ; 0,464] | 0,035 | [0,032 ; 0,037] | 0,433 | [0,426 ; 0,440] | 0,450 | [0,443 ; 0,457] | 0,042 | [0,039 ; 0,045] |
| T (tendance, D = 1,75 : 0,25 σ par an) | 0,213 | [0,207 ; 0,219] | 0,219 | [0,213 ; 0,225] | 0,048 | [0,045 ; 0,051] | 0,210 | [0,205 ; 0,216] | 0,219 | [0,213 ; 0,225] | 0,050 | [0,047 ; 0,053] |
| R (rupture, t₀ = 4, Δ = 1) | 0,157 | [0,152 ; 0,162] | 0,188 | [0,182 ; 0,193] | 0,047 | [0,044 ; 0,050] | 0,154 | [0,149 ; 0,159] | 0,183 | [0,178 ; 0,189] | 0,047 | [0,044 ; 0,050] |
| R (rupture, t₀ = 4, Δ = 2) | 0,446 | [0,439 ; 0,453] | 0,551 | [0,544 ; 0,557] | 0,020 | [0,018 ; 0,022] | 0,434 | [0,427 ; 0,441] | 0,539 | [0,532 ; 0,546] | 0,027 | [0,025 ; 0,029] |
| R (rupture, t₀ = 4, Δ = 3) | 0,769 | [0,763 ; 0,775] | 0,871 | [0,866 ; 0,876] | 0,003 | [0,003 ; 0,004] | 0,746 | [0,740 ; 0,752] | 0,854 | [0,849 ; 0,858] | 0,009 | [0,008 ; 0,010] |
| R (rupture, t₀ = 6, Δ = 2) | 0,308 | [0,301 ; 0,314] | 0,188 | [0,183 ; 0,194] | 0,047 | [0,044 ; 0,050] | 0,363 | [0,356 ; 0,370] | 0,223 | [0,217 ; 0,229] | 0,084 | [0,081 ; 0,088] |
| V (volume, κ = 2) | 0,072 | [0,069 ; 0,076] | 0,068 | [0,064 ; 0,071] | 0,100 | [0,096 ; 0,105] | 0,070 | [0,067 ; 0,074] | 0,068 | [0,064 ; 0,071] | 0,113 | [0,109 ; 0,118] |
| V (volume, κ = 3) | 0,096 | [0,092 ; 0,101] | 0,087 | [0,083 ; 0,091] | 0,151 | [0,146 ; 0,156] | 0,091 | [0,087 ; 0,095] | 0,086 | [0,082 ; 0,090] | 0,197 | [0,191 ; 0,202] |
| C (contamination, λ = 3) | 0,036 | [0,033 ; 0,039] | 0,030 | [0,028 ; 0,032] | 0,237 | [0,231 ; 0,243] | 0,035 | [0,032 ; 0,037] | 0,027 | [0,025 ; 0,029] | 0,378 | [0,371 ; 0,384] |
| C (contamination, λ = 4) | 0,025 | [0,023 ; 0,028] | 0,018 | [0,016 ; 0,019] | 0,458 | [0,451 ; 0,465] | 0,022 | [0,020 ; 0,025] | 0,013 | [0,011 ; 0,014] | 0,664 | [0,658 ; 0,671] |
| C (contamination, λ = 5) | 0,017 | [0,015 ; 0,019] | 0,008 | [0,007 ; 0,009] | 0,692 | [0,686 ; 0,699] | 0,012 | [0,011 ; 0,014] | 0,004 | [0,003 ; 0,005] | 0,879 | [0,875 ; 0,884] |
| C− (contamination vers le bas, λ = 3) | 0,038 | [0,035 ; 0,040] | 0,030 | [0,028 ; 0,033] | 0,234 | [0,228 ; 0,240] | 0,039 | [0,036 ; 0,041] | 0,034 | [0,032 ; 0,037] | 0,089 | [0,085 ; 0,093] |
| C− (contamination vers le bas, λ = 4) | 0,027 | [0,025 ; 0,029] | 0,016 | [0,015 ; 0,018] | 0,453 | [0,446 ; 0,460] | 0,029 | [0,027 ; 0,031] | 0,024 | [0,022 ; 0,026] | 0,168 | [0,163 ; 0,173] |
| C− (contamination vers le bas, λ = 5) | 0,018 | [0,016 ; 0,020] | 0,008 | [0,007 ; 0,010] | 0,686 | [0,680 ; 0,692] | 0,022 | [0,020 ; 0,024] | 0,015 | [0,014 ; 0,017] | 0,275 | [0,268 ; 0,281] |

### S3 -- niveau : ligne N contre la taille du test à loi nulle S0 (non bloquant)

| Ligne | α | Taille | Rejets / n | Taux | IC 95 % (C-P) | IC 99,9 % (C-P) | Taille dans l'IC à 99,9 % |
| --- | --- | --- | --- | --- | --- | --- | --- |
| sup-F (z) | 0,10 | 0,10000 | 2041 / 20000 | 0,1021 | [0,098 ; 0,106] | [0,095 ; 0,109] | oui |
| sup-F (z) | 0,05 | 0,05000 | 1049 / 20000 | 0,0524 | [0,049 ; 0,056] | [0,047 ; 0,058] | oui |
| OLS-CUSUM (z) | 0,10 | 0,10000 | 2032 / 20000 | 0,1016 | [0,097 ; 0,106] | [0,095 ; 0,109] | oui |
| OLS-CUSUM (z) | 0,05 | 0,05000 | 1020 / 20000 | 0,0510 | [0,048 ; 0,054] | [0,046 ; 0,056] | oui |
| Grubbs (z) | 0,10 | 0,10000 | 1995 / 20000 | 0,0998 | [0,096 ; 0,104] | [0,093 ; 0,107] | oui |
| Grubbs (z) | 0,05 | 0,05000 | 993 / 20000 | 0,0496 | [0,047 ; 0,053] | [0,045 ; 0,055] | oui |
| sup-F (ratios bruts) | 0,10 | 0,10000 | 2023 / 20000 | 0,1012 | [0,097 ; 0,105] | [0,094 ; 0,108] | oui |
| sup-F (ratios bruts) | 0,05 | 0,05000 | 1048 / 20000 | 0,0524 | [0,049 ; 0,056] | [0,047 ; 0,058] | oui |
| OLS-CUSUM (ratios bruts) | 0,10 | 0,10000 | 2059 / 20000 | 0,1029 | [0,099 ; 0,107] | [0,096 ; 0,110] | oui |
| OLS-CUSUM (ratios bruts) | 0,05 | 0,05000 | 1012 / 20000 | 0,0506 | [0,048 ; 0,054] | [0,046 ; 0,056] | oui |
| Grubbs (ratios bruts) | 0,10 | 0,10000 | 1985 / 20000 | 0,0993 | [0,095 ; 0,103] | [0,092 ; 0,106] | oui |
| Grubbs (ratios bruts) | 0,05 | 0,05000 | 980 / 20000 | 0,0490 | [0,046 ; 0,052] | [0,044 ; 0,054] | oui |

Taille : (⌈α (R0 + 1)⌉ − 1) / (R0 + 1), marginalement sur S0 (statistique continue). Les réplications de la ligne N partagent S0 : l'IC binomial ignore la variabilité de S0 (écart-type de l'ordre de √(α(1 − α)/R0)), d'où un contrôle rapporté, hors code de sortie.

### S4 -- rapprochement avec la revue R-17 (α = 0,10 ; non bloquant)

| Point | Ligne | Revue (R = 20 000) | Volet A : taux | IC 95 % (C-P) | Compatible |
| --- | --- | --- | --- | --- | --- |
| R (rupture, t₀ = 4, Δ = 1) | sup-F (z) | 0,26 | 0,264 | [0,258 ; 0,270] | oui |
| R (rupture, t₀ = 4, Δ = 1) | OLS-CUSUM (z) | 0,29 | 0,299 | [0,293 ; 0,306] | oui |
| R (rupture, t₀ = 4, Δ = 2) | sup-F (z) | 0,62 | 0,623 | [0,616 ; 0,630] | oui |
| R (rupture, t₀ = 4, Δ = 2) | OLS-CUSUM (z) | 0,70 | 0,699 | [0,693 ; 0,706] | oui |
| R (rupture, t₀ = 6, Δ = 2) | sup-F (z) | 0,47 | 0,470 | [0,464 ; 0,477] | oui |
| R (rupture, t₀ = 6, Δ = 2) | OLS-CUSUM (z) | 0,37 | 0,370 | [0,364 ; 0,377] | oui |
| T (tendance, D = 1,75 : 0,25 σ par an) | sup-F (z) | 0,33 | 0,349 | [0,342 ; 0,356] | **non** |
| T (tendance, D = 1,75 : 0,25 σ par an) | OLS-CUSUM (z) | 0,34 | 0,351 | [0,344 ; 0,357] | oui |
| C (contamination, λ = 3) | Grubbs (z) | 0,38 | 0,362 | [0,355 ; 0,369] | sans objet : scénario différent (note) |
| C (contamination, λ = 4) | Grubbs (z) | 0,64 | 0,613 | [0,606 ; 0,620] | sans objet : scénario différent (note) |
| C (contamination, λ = 5) | Grubbs (z) | 0,84 | 0,828 | [0,823 ; 0,833] | sans objet : scénario différent (note) |
| C (contamination, λ = 3) | sup-F (z) | ≤ 0,08 | 0,080 | [0,076 ; 0,084] | oui |
| C (contamination, λ = 4) | sup-F (z) | ≤ 0,08 | 0,064 | [0,061 ; 0,068] | oui |
| C (contamination, λ = 5) | sup-F (z) | ≤ 0,08 | 0,052 | [0,049 ; 0,056] | oui |
| C (contamination, λ = 3) | OLS-CUSUM (z) | ≤ 0,08 | 0,072 | [0,069 ; 0,076] | oui |
| C (contamination, λ = 4) | OLS-CUSUM (z) | ≤ 0,08 | 0,050 | [0,047 ; 0,053] | oui |
| C (contamination, λ = 5) | OLS-CUSUM (z) | ≤ 0,08 | 0,032 | [0,029 ; 0,034] | oui |

Revue : docs/revues/20261015-pertinence-tests-graphiques/bloc-4.md (issue #313), i.i.d. normal, rejet si la statistique dépasse le quantile à 90 % d'une loi nulle simulée de 100 000 séries ; valeurs à deux décimales, compatibles si l'intervalle d'arrondi ± 0,005 rencontre l'IC à 95 % ; « ≤ 0,08 » : borne de la revue, compatible si le taux ne la dépasse pas de plus de 0,005. Contamination : la revue remplace l'année i par v_j + λ, i et j tirés au hasard indépendamment (v[sample(T, 1)] <- v[sample(T, 1)] + L dans son script sim.R), et non par v_i + λ ; ici e_t + λ pour l'année t_c(b), déterministe : les deux scénarios diffèrent ; mesuré hors dépôt (#313, R = 20 000), le générateur de la revue donne pour Grubbs 0,381 / 0,647 / 0,837 et la contamination d'une année 0,358 / 0,614 / 0,822 (λ = 3 / 4 / 5) : comparaison sans objet. Dérive, sup-F : même scénario, écart d'environ 2,5 écarts-types Monte-Carlo combinés ; un rejeu hors dépôt (3 × 50 000 séries) donne environ 0,342, entre les deux valeurs.

### S5 -- loi Monte-Carlo du moteur (réajustement) contre la loi nulle S0 (sans réajustement), J1 observé (non bloquant)

Boucle de usp_bootstrap() réduite aux six statistiques, B = 9999 (9999 retenues) ; régime de δ** : bord 1 0,499, bord 0 0,461, intérieur 0,040.

| Ligne | Taille (α = 0,10) | Taux p < 0,10 | IC 95 % (C-P) | Taille (α = 0,05) | Taux p < 0,05 | IC 95 % (C-P) | α = 0,10, δ̂* = 1 (π̂* constant) | α = 0,10, δ̂* = 0 | α = 0,10, δ̂* intérieur (taux conditionnel descriptif) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| sup-F (z) | 0,1000 | 0,099 | [0,093 ; 0,105] | 0,0500 | 0,048 | [0,044 ; 0,053] | 0,100 (500 / 4991) | 0,104 (478 / 4613) | 0,028 (11 / 395) |
| OLS-CUSUM (z) | 0,1000 | 0,101 | [0,095 ; 0,107] | 0,0500 | 0,052 | [0,048 ; 0,057] | 0,099 (495 / 4991) | 0,109 (503 / 4613) | 0,038 (15 / 395) |
| Grubbs (z) | 0,1000 | 0,099 | [0,093 ; 0,105] | 0,0500 | 0,050 | [0,045 ; 0,054] | 0,100 (498 / 4991) | 0,106 (487 / 4613) | 0,015 (6 / 395) |
| sup-F (ratios bruts) | 0,1000 | 0,105 | [0,099 ; 0,111] | 0,0500 | 0,050 | [0,046 ; 0,054] | 0,103 (513 / 4991) | 0,114 (524 / 4613) | 0,033 (13 / 395) |
| OLS-CUSUM (ratios bruts) | 0,1000 | 0,104 | [0,098 ; 0,110] | 0,0500 | 0,053 | [0,048 ; 0,057] | 0,100 (500 / 4991) | 0,113 (521 / 4613) | 0,043 (17 / 395) |
| Grubbs (ratios bruts) | 0,1000 | 0,102 | [0,096 ; 0,108] | 0,0500 | 0,054 | [0,049 ; 0,058] | 0,097 (484 / 4991) | 0,115 (529 / 4613) | 0,018 (7 / 395) |

Taux, sur les réplications de la boucle bootstrap du moteur, d'une p < α calculée sur S0 : égal à la taille (à l'erreur Monte-Carlo près) si la loi bootstrap du moteur, qui réajuste δ et γ dans chaque réplication, est celle de S0. Un écart mesure la différence entre le test du volet A et celui que retient le moteur sur J1 (V1, toutes réplications). Colonne δ̂* intérieur : ce n'est pas le niveau d'un test du moteur : à δ̂ intérieur, le moteur retient la p conditionnelle au régime (V3h, #240).

### S6 -- désaccords de rejet z / ratios bruts (α = 0,10 ; part des réplications, nombre)

| Point | sup-F | OLS-CUSUM | Grubbs |
| --- | --- | --- | --- |
| N (nulle) | 0,0172 (344) | 0,0144 (289) | 0,0580 (1160) |
| A (AR(1), ρ = -0,5) | 0,0043 (85) | 0,0028 (56) | 0,0469 (938) |
| A (AR(1), ρ = 0,3) | 0,0258 (516) | 0,0219 (437) | 0,0513 (1026) |
| A (AR(1), ρ = 0,5) | 0,0329 (658) | 0,0227 (454) | 0,0421 (843) |
| A (AR(1), ρ = 0,7) | 0,0262 (524) | 0,0208 (416) | 0,0316 (633) |
| A (AR(1), ρ = 0,9) | 0,0138 (276) | 0,0121 (243) | 0,0183 (366) |
| T (tendance, D = 1) | 0,0311 (622) | 0,0223 (446) | 0,0590 (1180) |
| T (tendance, D = 2) | 0,0527 (1053) | 0,0428 (856) | 0,0693 (1386) |
| T (tendance, D = 3) | 0,0696 (1392) | 0,0573 (1147) | 0,0713 (1427) |
| T (tendance, D = 1,75 : 0,25 σ par an) | 0,0473 (945) | 0,0374 (749) | 0,0655 (1310) |
| R (rupture, t₀ = 4, Δ = 1) | 0,0368 (736) | 0,0292 (584) | 0,0626 (1253) |
| R (rupture, t₀ = 4, Δ = 2) | 0,0524 (1047) | 0,0358 (717) | 0,0506 (1012) |
| R (rupture, t₀ = 4, Δ = 3) | 0,0354 (708) | 0,0189 (378) | 0,0228 (457) |
| R (rupture, t₀ = 6, Δ = 2) | 0,0691 (1382) | 0,0669 (1339) | 0,0780 (1559) |
| V (volume, κ = 2) | 0,0282 (564) | 0,0254 (507) | 0,1311 (2623) |
| V (volume, κ = 3) | 0,0435 (871) | 0,0384 (767) | 0,2240 (4480) |
| C (contamination, λ = 3) | 0,0184 (367) | 0,0192 (384) | 0,1507 (3013) |
| C (contamination, λ = 4) | 0,0173 (346) | 0,0170 (341) | 0,1682 (3364) |
| C (contamination, λ = 5) | 0,0181 (363) | 0,0150 (301) | 0,1080 (2159) |
| C− (contamination vers le bas, λ = 3) | 0,0232 (463) | 0,0184 (368) | 0,2016 (4032) |
| C− (contamination vers le bas, λ = 4) | 0,0240 (481) | 0,0204 (407) | 0,3189 (6377) |
| C− (contamination vers le bas, λ = 5) | 0,0209 (418) | 0,0238 (475) | 0,3685 (7371) |

### S7 -- effet de B : taux de rejet exact à B = 999, conditionnel à S0, et écart Δ au taux de S1 (α = 0,10)

| Point | sup-F (z) : taux_B | Δ | OLS-CUSUM (z) : taux_B | Δ | Grubbs (z) : taux_B | Δ | sup-F (ratios bruts) : taux_B | Δ | OLS-CUSUM (ratios bruts) : taux_B | Δ | Grubbs (ratios bruts) : taux_B | Δ |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N (nulle) | 0,1008 | -0,0012 | 0,1008 | -0,0008 | 0,0981 | -0,0017 | 0,1007 | -0,0005 | 0,1012 | -0,0017 | 0,0988 | -0,0005 |
| A (AR(1), ρ = -0,5) | 0,0192 | -0,0003 | 0,0183 | -0,0006 | 0,0729 | -0,0011 | 0,0193 | -0,0002 | 0,0183 | -0,0002 | 0,0726 | -0,0011 |
| A (AR(1), ρ = 0,3) | 0,2098 | -0,0025 | 0,2082 | -0,0015 | 0,0946 | -0,0009 | 0,2097 | -0,0021 | 0,2076 | -0,0014 | 0,0884 | -0,0006 |
| A (AR(1), ρ = 0,5) | 0,3122 | -0,0029 | 0,3051 | -0,0009 | 0,0861 | -0,0014 | 0,3120 | -0,0033 | 0,3059 | -0,0025 | 0,0809 | -0,0012 |
| A (AR(1), ρ = 0,7) | 0,4257 | -0,0035 | 0,4116 | -0,0018 | 0,0777 | -0,0007 | 0,4244 | -0,0028 | 0,4120 | -0,0019 | 0,0719 | -0,0009 |
| A (AR(1), ρ = 0,9) | 0,5362 | -0,0028 | 0,5224 | -0,0021 | 0,0731 | -0,0008 | 0,5371 | -0,0024 | 0,5233 | -0,0020 | 0,0646 | -0,0013 |
| T (tendance, D = 1) | 0,1906 | -0,0020 | 0,1911 | -0,0007 | 0,0968 | -0,0013 | 0,1891 | -0,0019 | 0,1912 | -0,0025 | 0,0970 | -0,0012 |
| T (tendance, D = 2) | 0,4027 | -0,0040 | 0,4083 | -0,0028 | 0,0927 | -0,0012 | 0,3989 | -0,0021 | 0,4066 | -0,0032 | 0,0960 | -0,0005 |
| T (tendance, D = 3) | 0,6341 | -0,0046 | 0,6427 | -0,0027 | 0,0715 | -0,0010 | 0,6303 | -0,0045 | 0,6368 | -0,0042 | 0,0866 | -0,0015 |
| T (tendance, D = 1,75 : 0,25 σ par an) | 0,3451 | -0,0039 | 0,3492 | -0,0016 | 0,0947 | -0,0021 | 0,3429 | -0,0027 | 0,3462 | -0,0019 | 0,0972 | -0,0013 |
| R (rupture, t₀ = 4, Δ = 1) | 0,2618 | -0,0024 | 0,2980 | -0,0014 | 0,0928 | -0,0014 | 0,2596 | -0,0020 | 0,2966 | -0,0027 | 0,0947 | -0,0012 |
| R (rupture, t₀ = 4, Δ = 2) | 0,6177 | -0,0054 | 0,6969 | -0,0023 | 0,0472 | -0,0007 | 0,6087 | -0,0050 | 0,6884 | -0,0030 | 0,0602 | -0,0005 |
| R (rupture, t₀ = 4, Δ = 3) | 0,8957 | -0,0035 | 0,9444 | -0,0013 | 0,0106 | -0,0004 | 0,8835 | -0,0041 | 0,9377 | -0,0017 | 0,0242 | -0,0004 |
| R (rupture, t₀ = 6, Δ = 2) | 0,4656 | -0,0048 | 0,3672 | -0,0033 | 0,0957 | -0,0012 | 0,5186 | -0,0035 | 0,4126 | -0,0035 | 0,1491 | -0,0016 |
| V (volume, κ = 2) | 0,1280 | -0,0015 | 0,1250 | -0,0007 | 0,1683 | -0,0022 | 0,1261 | -0,0010 | 0,1235 | -0,0006 | 0,1825 | -0,0018 |
| V (volume, κ = 3) | 0,1561 | -0,0016 | 0,1500 | -0,0011 | 0,2405 | -0,0022 | 0,1532 | -0,0014 | 0,1465 | -0,0017 | 0,2827 | -0,0020 |
| C (contamination, λ = 3) | 0,0790 | -0,0012 | 0,0720 | -0,0003 | 0,3583 | -0,0037 | 0,0744 | -0,0011 | 0,0630 | -0,0003 | 0,4990 | -0,0036 |
| C (contamination, λ = 4) | 0,0633 | -0,0007 | 0,0496 | -0,0005 | 0,6086 | -0,0043 | 0,0556 | -0,0008 | 0,0375 | +0,0001 | 0,7760 | -0,0031 |
| C (contamination, λ = 5) | 0,0514 | -0,0011 | 0,0312 | -0,0005 | 0,8248 | -0,0032 | 0,0390 | -0,0008 | 0,0182 | -0,0004 | 0,9346 | -0,0012 |
| C− (contamination vers le bas, λ = 3) | 0,0789 | -0,0009 | 0,0719 | -0,0002 | 0,3500 | -0,0032 | 0,0835 | -0,0011 | 0,0793 | -0,0007 | 0,1736 | -0,0018 |
| C− (contamination vers le bas, λ = 4) | 0,0637 | -0,0008 | 0,0509 | -0,0013 | 0,6024 | -0,0041 | 0,0714 | -0,0008 | 0,0646 | -0,0003 | 0,2952 | -0,0043 |
| C− (contamination vers le bas, λ = 5) | 0,0509 | -0,0010 | 0,0310 | -0,0005 | 0,8173 | -0,0035 | 0,0605 | -0,0004 | 0,0507 | -0,0008 | 0,4520 | -0,0045 |

### S8 -- effet de B, α = 0,05 (complément)

| Point | sup-F (z) : taux_B | Δ | OLS-CUSUM (z) : taux_B | Δ | Grubbs (z) : taux_B | Δ | sup-F (ratios bruts) : taux_B | Δ | OLS-CUSUM (ratios bruts) : taux_B | Δ | Grubbs (ratios bruts) : taux_B | Δ |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N (nulle) | 0,0516 | -0,0008 | 0,0503 | -0,0007 | 0,0492 | -0,0005 | 0,0515 | -0,0009 | 0,0501 | -0,0005 | 0,0482 | -0,0008 |
| A (AR(1), ρ = -0,5) | 0,0073 | -0,0002 | 0,0078 | -0,0002 | 0,0342 | -0,0007 | 0,0075 | -0,0004 | 0,0080 | -0,0002 | 0,0348 | -0,0003 |
| A (AR(1), ρ = 0,3) | 0,1230 | -0,0020 | 0,1217 | -0,0027 | 0,0463 | -0,0010 | 0,1207 | -0,0026 | 0,1211 | -0,0018 | 0,0449 | -0,0006 |
| A (AR(1), ρ = 0,5) | 0,1983 | -0,0030 | 0,1969 | -0,0031 | 0,0428 | -0,0005 | 0,1965 | -0,0038 | 0,1963 | -0,0030 | 0,0387 | -0,0008 |
| A (AR(1), ρ = 0,7) | 0,3004 | -0,0044 | 0,2927 | -0,0039 | 0,0380 | -0,0004 | 0,2960 | -0,0039 | 0,2923 | -0,0038 | 0,0336 | -0,0007 |
| A (AR(1), ρ = 0,9) | 0,4113 | -0,0045 | 0,3974 | -0,0040 | 0,0356 | -0,0003 | 0,4074 | -0,0043 | 0,3967 | -0,0044 | 0,0302 | -0,0008 |
| T (tendance, D = 1) | 0,1057 | -0,0029 | 0,1067 | -0,0015 | 0,0492 | -0,0007 | 0,1046 | -0,0018 | 0,1053 | -0,0020 | 0,0493 | -0,0011 |
| T (tendance, D = 2) | 0,2518 | -0,0044 | 0,2592 | -0,0035 | 0,0443 | -0,0008 | 0,2493 | -0,0057 | 0,2568 | -0,0032 | 0,0471 | -0,0008 |
| T (tendance, D = 3) | 0,4320 | -0,0074 | 0,4501 | -0,0070 | 0,0338 | -0,0007 | 0,4240 | -0,0090 | 0,4437 | -0,0066 | 0,0411 | -0,0010 |
| T (tendance, D = 1,75 : 0,25 σ par an) | 0,2094 | -0,0037 | 0,2155 | -0,0036 | 0,0465 | -0,0011 | 0,2057 | -0,0046 | 0,2150 | -0,0039 | 0,0486 | -0,0014 |
| R (rupture, t₀ = 4, Δ = 1) | 0,1540 | -0,0033 | 0,1847 | -0,0031 | 0,0466 | -0,0006 | 0,1504 | -0,0036 | 0,1808 | -0,0026 | 0,0467 | -0,0007 |
| R (rupture, t₀ = 4, Δ = 2) | 0,4397 | -0,0062 | 0,5441 | -0,0064 | 0,0196 | -0,0002 | 0,4273 | -0,0069 | 0,5327 | -0,0066 | 0,0263 | -0,0006 |
| R (rupture, t₀ = 4, Δ = 3) | 0,7632 | -0,0060 | 0,8662 | -0,0048 | 0,0033 | -0,0001 | 0,7373 | -0,0089 | 0,8482 | -0,0053 | 0,0087 | -0,0002 |
| R (rupture, t₀ = 6, Δ = 2) | 0,3020 | -0,0057 | 0,1848 | -0,0036 | 0,0461 | -0,0008 | 0,3573 | -0,0056 | 0,2176 | -0,0057 | 0,0823 | -0,0020 |
| V (volume, κ = 2) | 0,0709 | -0,0014 | 0,0663 | -0,0013 | 0,0981 | -0,0022 | 0,0690 | -0,0015 | 0,0660 | -0,0017 | 0,1113 | -0,0020 |
| V (volume, κ = 3) | 0,0941 | -0,0023 | 0,0852 | -0,0014 | 0,1493 | -0,0021 | 0,0894 | -0,0016 | 0,0845 | -0,0015 | 0,1934 | -0,0031 |
| C (contamination, λ = 3) | 0,0352 | -0,0008 | 0,0293 | -0,0007 | 0,2330 | -0,0042 | 0,0339 | -0,0008 | 0,0261 | -0,0006 | 0,3737 | -0,0039 |
| C (contamination, λ = 4) | 0,0251 | -0,0004 | 0,0171 | -0,0005 | 0,4526 | -0,0056 | 0,0216 | -0,0009 | 0,0123 | -0,0004 | 0,6583 | -0,0058 |
| C (contamination, λ = 5) | 0,0169 | -0,0000 | 0,0079 | -0,0003 | 0,6862 | -0,0061 | 0,0120 | -0,0000 | 0,0041 | +0,0000 | 0,8758 | -0,0033 |
| C− (contamination vers le bas, λ = 3) | 0,0363 | -0,0012 | 0,0294 | -0,0008 | 0,2310 | -0,0031 | 0,0374 | -0,0011 | 0,0336 | -0,0007 | 0,0869 | -0,0024 |
| C− (contamination vers le bas, λ = 4) | 0,0263 | -0,0007 | 0,0163 | -0,0001 | 0,4466 | -0,0067 | 0,0282 | -0,0007 | 0,0235 | -0,0003 | 0,1655 | -0,0023 |
| C− (contamination vers le bas, λ = 5) | 0,0177 | -0,0001 | 0,0078 | -0,0004 | 0,6797 | -0,0064 | 0,0218 | -0,0006 | 0,0149 | -0,0003 | 0,2699 | -0,0047 |

taux_B : moyenne sur les réplications de pbinom(k, B, u_i), k = ⌈α (B + 1)⌉ − 2, B = 999, u_i = ((R0 + 1) p_i − 1) / R0 (p_i : p sur S0) ; la p du moteur (1 + K) / (B + 1) rejette si K ≤ k, K ~ Binomiale(B, u_i). Calcul exact conditionnel à la loi S0, sans aléa nouveau ; effet de B seul, hors réajustement. Ligne N attendue : (⌈α (B + 1)⌉ − 1) / (B + 1) = 0,0990 (α = 0,10), 0,0490 (α = 0,05) ; contrôle non bloquant.

### Contrôles d'intégrité et critères bloquants (toute l'exécution)

- Critère 6, dépôt intact (début) : git status de R/ et tests/reference/ vide : OK
- Volet A, prérequis : π̂ constant sur J1 (usp_regime()) : OK
- Volet A, tailles exactes énumérées égales à celles de la spécification (à 5e-6) : OK
- Critère 3, volet A : p exactes sur l, u, r de J1 observé = p_exacte de run_engine() (DW à 1e-10) : OK
- Volet A, lignes de stabilité : loi nulle S0 entièrement finie (0 valeur(s) non finie(s)) : OK
- Critère 3, volet A (#313) : statistiques de stabilité de J1 observé (catalogue sur l* et u) = stats_obs de run_engine() (u identiques ; l* à 1e-10) : OK
- Critère 3, volet A : ligne N identique à usp_simuler(FIT0) (même graine, au bit près) : OK
- Critère 3, volet A (#313) : p des lignes de stabilité par findInterval() identiques à engine_p_mc() (ligne N, 200 réplications) : OK
- Critère 2, identité Runs / Runsr réplication par réplication (0 différence(s) sur 440000) : OK
- Critère 5, volet A : aucune p exacte manquante (0 manquante(s)) : OK
- Critère 5, volet A (#313) : aucune p Monte-Carlo manquante sur les lignes de stabilité (0 manquante(s)) : OK
- Critère 1, niveau du volet A : Suites (z), α = 0,10, taille exacte 0,05714 dans l'IC à 99,9 % [0,053 ; 0,064] : OK
- Volet A, suites à α = 0,05 (inopérant, R1) : taux exactement 0 (0 / 20000) : OK
- Critère 1, niveau du volet A : Durbin-Watson (z), α = 0,10, taille exacte 0,10000 dans l'IC à 99,9 % [0,095 ; 0,109] : OK
- Critère 1, niveau du volet A : Durbin-Watson (z), α = 0,05, taille exacte 0,05000 dans l'IC à 99,9 % [0,047 ; 0,057] : OK
- Critère 1, niveau du volet A : Mann-Kendall, α = 0,10, taille exacte 0,06101 dans l'IC à 99,9 % [0,055 ; 0,066] : OK
- Critère 1, niveau du volet A : Mann-Kendall, α = 0,05, taille exacte 0,03115 dans l'IC à 99,9 % [0,026 ; 0,034] : OK
- Critère 1, niveau du volet A : Smirnov, α = 0,10, taille exacte 0,02857 dans l'IC à 99,9 % [0,025 ; 0,032] : OK
- Volet A, Imhof : dw_puissance_ar1() sans erreur : OK
- Volet A, Imhof : puissances calculées (6 / 6 finies) : OK
- Volet A, puissance de DW par Imhof à ρ = 0 égale à α (0,100000) : OK
- Volet A (#313), niveau de la ligne N : sup-F (z), α = 0,10, taille 0,10000 dans l'IC à 99,9 % [0,095 ; 0,109] : OK
- Volet A (#313), niveau de la ligne N : sup-F (z), α = 0,05, taille 0,05000 dans l'IC à 99,9 % [0,047 ; 0,058] : OK
- Volet A (#313), niveau de la ligne N : OLS-CUSUM (z), α = 0,10, taille 0,10000 dans l'IC à 99,9 % [0,095 ; 0,109] : OK
- Volet A (#313), niveau de la ligne N : OLS-CUSUM (z), α = 0,05, taille 0,05000 dans l'IC à 99,9 % [0,046 ; 0,056] : OK
- Volet A (#313), niveau de la ligne N : Grubbs (z), α = 0,10, taille 0,10000 dans l'IC à 99,9 % [0,093 ; 0,107] : OK
- Volet A (#313), niveau de la ligne N : Grubbs (z), α = 0,05, taille 0,05000 dans l'IC à 99,9 % [0,045 ; 0,055] : OK
- Volet A (#313), niveau de la ligne N : sup-F (ratios bruts), α = 0,10, taille 0,10000 dans l'IC à 99,9 % [0,094 ; 0,108] : OK
- Volet A (#313), niveau de la ligne N : sup-F (ratios bruts), α = 0,05, taille 0,05000 dans l'IC à 99,9 % [0,047 ; 0,058] : OK
- Volet A (#313), niveau de la ligne N : OLS-CUSUM (ratios bruts), α = 0,10, taille 0,10000 dans l'IC à 99,9 % [0,096 ; 0,110] : OK
- Volet A (#313), niveau de la ligne N : OLS-CUSUM (ratios bruts), α = 0,05, taille 0,05000 dans l'IC à 99,9 % [0,046 ; 0,056] : OK
- Volet A (#313), niveau de la ligne N : Grubbs (ratios bruts), α = 0,10, taille 0,10000 dans l'IC à 99,9 % [0,092 ; 0,106] : OK
- Volet A (#313), niveau de la ligne N : Grubbs (ratios bruts), α = 0,05, taille 0,05000 dans l'IC à 99,9 % [0,044 ; 0,054] : OK
- Volet A (#313), S7 ligne N : sup-F (z), α = 0,10, taux_B 0,1008, taille à B = 999 (0,0990) dans l'IC à 99,9 % [0,094 ; 0,108] : OK
- Volet A (#313), S7 ligne N : sup-F (z), α = 0,05, taux_B 0,0516, taille à B = 999 (0,0490) dans l'IC à 99,9 % [0,047 ; 0,057] : OK
- Volet A (#313), S7 ligne N : OLS-CUSUM (z), α = 0,10, taux_B 0,1008, taille à B = 999 (0,0990) dans l'IC à 99,9 % [0,094 ; 0,108] : OK
- Volet A (#313), S7 ligne N : OLS-CUSUM (z), α = 0,05, taux_B 0,0503, taille à B = 999 (0,0490) dans l'IC à 99,9 % [0,045 ; 0,056] : OK
- Volet A (#313), S7 ligne N : Grubbs (z), α = 0,10, taux_B 0,0981, taille à B = 999 (0,0990) dans l'IC à 99,9 % [0,091 ; 0,105] : OK
- Volet A (#313), S7 ligne N : Grubbs (z), α = 0,05, taux_B 0,0492, taille à B = 999 (0,0490) dans l'IC à 99,9 % [0,044 ; 0,054] : OK
- Volet A (#313), S7 ligne N : sup-F (ratios bruts), α = 0,10, taux_B 0,1007, taille à B = 999 (0,0990) dans l'IC à 99,9 % [0,094 ; 0,108] : OK
- Volet A (#313), S7 ligne N : sup-F (ratios bruts), α = 0,05, taux_B 0,0515, taille à B = 999 (0,0490) dans l'IC à 99,9 % [0,047 ; 0,057] : OK
- Volet A (#313), S7 ligne N : OLS-CUSUM (ratios bruts), α = 0,10, taux_B 0,1012, taille à B = 999 (0,0990) dans l'IC à 99,9 % [0,094 ; 0,108] : OK
- Volet A (#313), S7 ligne N : OLS-CUSUM (ratios bruts), α = 0,05, taux_B 0,0501, taille à B = 999 (0,0490) dans l'IC à 99,9 % [0,045 ; 0,055] : OK
- Volet A (#313), S7 ligne N : Grubbs (ratios bruts), α = 0,10, taux_B 0,0988, taille à B = 999 (0,0990) dans l'IC à 99,9 % [0,092 ; 0,106] : OK
- Volet A (#313), S7 ligne N : Grubbs (ratios bruts), α = 0,05, taux_B 0,0482, taille à B = 999 (0,0490) dans l'IC à 99,9 % [0,043 ; 0,053] : OK
- Volet A (#313), symétrie C− / C, sup-F (z), λ = 3 (α = 0,10) : IC à 99,9 % [0,074 ; 0,087] et [0,074 ; 0,086] se recouvrent : OK
- Volet A (#313), symétrie C− / C, OLS-CUSUM (z), λ = 3 (α = 0,10) : IC à 99,9 % [0,066 ; 0,078] et [0,066 ; 0,078] se recouvrent : OK
- Volet A (#313), symétrie C− / C, Grubbs (z), λ = 3 (α = 0,10) : IC à 99,9 % [0,351 ; 0,373] et [0,342 ; 0,364] se recouvrent : OK
- Volet A (#313), symétrie C− / C, sup-F (z), λ = 4 (α = 0,10) : IC à 99,9 % [0,058 ; 0,070] et [0,059 ; 0,070] se recouvrent : OK
- Volet A (#313), symétrie C− / C, OLS-CUSUM (z), λ = 4 (α = 0,10) : IC à 99,9 % [0,045 ; 0,055] et [0,047 ; 0,058] se recouvrent : OK
- Volet A (#313), symétrie C− / C, Grubbs (z), λ = 4 (α = 0,10) : IC à 99,9 % [0,602 ; 0,624] et [0,595 ; 0,618] se recouvrent : OK
- Volet A (#313), symétrie C− / C, sup-F (z), λ = 5 (α = 0,10) : IC à 99,9 % [0,047 ; 0,058] et [0,047 ; 0,057] se recouvrent : OK
- Volet A (#313), symétrie C− / C, OLS-CUSUM (z), λ = 5 (α = 0,10) : IC à 99,9 % [0,028 ; 0,036] et [0,028 ; 0,036] se recouvrent : OK
- Volet A (#313), symétrie C− / C, Grubbs (z), λ = 5 (α = 0,10) : IC à 99,9 % [0,819 ; 0,837] et [0,812 ; 0,830] se recouvrent : OK
- Critère 3, volet A (#313) : z_boot des 999 premières réplications de la boucle de contrôle (B = 9999, graine 20260831) identiques à ceux de usp_bootstrap() sur J1 : OK
- Critère 6, dépôt intact (fin) : git status de R/ et tests/reference/ vide : OK
- Critère 6, dépôt intact (fin) : md5 de R/ et tests/reference/ inchangés depuis le début : OK

Durée totale : 1237 s, dont contrôles de transcription (run_engine() et chaîne sur les jeux observés, ligne N) 37 s et hors contrôles 1199 s. Bilan : OK

