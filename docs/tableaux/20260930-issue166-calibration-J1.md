## Calibration des p-values Monte-Carlo à T = 8, jeu J1 -- combinaison de 8 tranche(s) (issue #166)

Paramètres : jeu=J1;R=2000;graine_jeux=20260927;graine_boot=20260831;B=999;methode=premium;segment=1;annexe=II;nature=brutes;alpha=0.1;theta_equiv=0.1

### T0 -- contexte (identique dans toutes les tranches, vérifié)

| Grandeur | Valeur |
| --- | --- |
| Jeu | J1 : tests/donnees/donnees_ln.csv (jeu des cas de référence) |
| Modèle ajusté (usp_ajuster()) | δ̂ = 1 ; γ̂ = -1.93433 ; β̂ = 0.728685 ; σ̂ = 0.10531 ; π̂ constant : TRUE |
| Configuration de run_engine() | méthode premium, segment 1 de l'annexe II, données brutes, α = 0.1, theta_equiv = 0.1, σ standard = 0.1, barème long, B = 999 |
| σ_USP observé (usp_parametre() sur le modèle ajusté) | 0.111452 |
| Graines | jeux simulés : un flux sous 20260927 (chemin de #72) ; bootstrap et rapport de vraisemblance de la réplication b : 20260831 + b ; J1 observé (a) : 20260831 |
| Graines en collision (déclarées, non bloquantes) | réplication 96 : graine du bootstrap 20260927 = graine des jeux simulés (effet borné : réplication 96, \|Δp_mc\| ≤ 1/(B+1) = 0,001 en queue simple et 2/(B+1) = 0,002 en bilatéral, sur ses seules p_mc (au plus 1/R sur un taux), ses 998 autres réplications internes restant indépendantes de y_96) ; réplication 70 : graine du bootstrap 20260901 = SEED_LOI_NULLE_SW (loi nulle de Shapiro-Wilk) (réplication 70, lois marginales de p_mc et p_exacte inchangées (seule leur loi jointe est touchée, non mesurée)) |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Commit | 51ae1ab3f1d8157782b9017b749c974e1f943089 |
| Plateforme de calcul (R, système, machine, BLAS, LAPACK) | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.4 LTS ; Linux, x86_64 ; BLAS : /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.12.0 ; LAPACK : /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.12.0 (version 3.12.0) |
| Empreintes md5 du code exécuté | R/engine.R 37798c2725debf37548f56ce055fb714 ; tests/outils_tests.R chargé (dépôt) d6d30b0cfe7189e96c5c07559a2f69f0 ; script exécuté (dépôt) 24b212c671db4898372e3c5412d0fe2d ; tests/taux_franchissement_reperes.R a6d499027467dc6d895a4265bba7384b |
| Contrôle (a) : J1 observé contre tests/reference/premium.rds | conforme ; 23634 feuille(s), 0 non strictement identique(s), écart maximal 0.000e+00 |
| Tailles des lois discrètes, P(p < 0,10) et P(p < 0,05) (T = 8, sans ex aequo) | suites (Swed-Eisenhart, 4 et 4) : atteignable 0,05714 et 0,00000, lissée 0,05713 et 0,00968 ; Mann-Kendall (loi mahonienne) : atteignable 0,06101 et 0,03115, lissée 0,07107 et 0,03355 ; Smirnov (4 et 4) : atteignable 0,02857 et 0,02857, lissée 0,02857 et 0,02856 ; Spearman (loi de permutation) : atteignable 0,09618 et 0,04583, lissée 0,09038 et 0,04295 ; Cox-Stuart (Binomiale(4, 1/2)) : atteignable 0,00000 et 0,00000, lissée 0,00059 et 0,00000 |
| Réplications | 2000 (8 tranche(s) : 1-250, 251-500, 501-750, 751-1000, 1001-1250, 1251-1500, 1501-1750, 1751-2000) |
| Durée cumulée des tranches (s) | contrôles 156 ; réplications 32567 (16.3 s par réplication) |
| Commit de la combinaison | 808b448a18bca66df1cf00c62a0299f89a073600 |
| Empreintes md5 du combinateur | R/engine.R 37798c2725debf37548f56ce055fb714 ; tests/outils_tests.R chargé (dépôt) d6d30b0cfe7189e96c5c07559a2f69f0 ; script exécuté (dépôt) 12a716c1b095333a3c25a2da7ccaa4a8 ; tests/taux_franchissement_reperes.R 64064208f6024a65680a246417de31b9 |
| Versionnable (--ecrire) | oui |
| Contrôles d'intégrité | OK dans les 8 tranche(s), invariants du corps vérifiés ; (e3) : OK : δ̂* au bord 0 : 930 (tableau de #72 : 930 sur 2000) ; au bord 1 : 995 (tableau de #72 : 995 sur 2000) ; usp_ajuster() en erreur : 0 ; docs/tableaux/20260930-issue122-J1.md ; (e4) : OK : largeur relative de l'IC bootstrap 90 % au-dessus de 0,50 : 981 sur 2000 (tableau de #72 : 981 sur 2000) ; au-dessus de 0,80 : 0 (tableau de #72 : 0 sur 2000) ; docs/tableaux/20260930-issue122-J1.md |

### Aide à la lecture (sans conclusion)

Statut : **constat de simulation sous le modèle ajusté au jeu** (usp_simuler(FIT0)), pas un résultat général. Chaque réplication est traitée par run_engine() complet (B = 999) : la mesure porte sur la procédure du dossier (réajustement, bootstrap paramétrique, engine_p_mc(), verdict de add()). Protocole d'actuary (#122, commentaire 5905003573 ; décisions du mainteneur, commentaire 5905011303 ; issue #166).

IC : Clopper-Pearson à 95 %, incertitude Monte-Carlo sur le taux (fonction de R), pas l'erreur d'approximation en T ; l'erreur liée à B fait partie de la procédure mesurée. « oui » dans « réf. dans l'IC » se lit « compatible » au sens de « aucune distorsion détectée à la précision Monte-Carlo », jamais « exact ».

Bande de Bradley (1978), critère libéral [réf/2 ; 3réf/2] : **convention, pas théorème** (J. V. Bradley, « Robustness? », *British Journal of Mathematical and Statistical Psychology* 31(2), 1978, p. 144-152). Le rapport 0,5-1,5 au niveau nominal est la règle de Bradley elle-même à tout seuil : [0,05 ; 0,15] à 0,10, [0,025 ; 0,075] à 0,05. Pour une référence discrète (†), la bande est la transposition en rapport du critère de Bradley à la taille de référence (convention du script). Colonne « bande », écrite seulement si la référence est hors de l'IC : « dans » : estimation dans la bande ; « estimation hors » : estimation hors de la bande, IC la recoupant ; « IC entièrement hors » : IC disjoint de la bande ; « non applicable (réf. < 2/n) » : voir ci-dessous ; « — » : référence dans l'IC, ou pas de référence.

Lecture, par actuary, à partir des colonnes « réf. dans l'IC » et « bande » : (1) l'IC contient la référence : **compatible** (la bande n'est pas écrite) ; (2) sinon, estimation dans la bande : **écart mineur**, consigné en rubrique 7 ; (3) IC disjoint de la bande : **distorsion matérielle**, point de décision du mainteneur ; (4) sinon (estimation hors de la bande, IC la recoupant) : **écart non tranché**, distorsion possible non établie à la précision Monte-Carlo, consigné en rubrique 7 avec l'IC, à éclairer par T1 bis et les valeurs brutes, sans décision déclenchée. Bande non applicable quand la référence est inférieure à 2/n (sa demi-largeur ref/2 est sous la résolution 1/n du taux ; Cox-Stuart) : lecture binaire, compatible ou **écart à examiner** (k et IC cités), sans échelle mineur / matériel ni décision déclenchée ; une référence nulle n'est pas ramenée à une bande {0}.

### T1 -- calibration de p_mc : les 34 statistiques de USP_CATALOGUE_MC (p_mc retenue ou non)

| Statistique | Ligne de usp_tests() | Queue | n | < 0,10 : k | taux | IC 95 % | réf. | réf. dans l'IC | bande [réf/2 ; 3réf/2] | < 0,05 : k | taux | IC 95 % | réf. | réf. dans l'IC | bande [réf/2 ; 3réf/2] | p_mc absente |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AD | Anderson-Darling | haut | 2000 | 185 | 0,0925 | [0,0802 ; 0,1061] | 0,1000 | oui | — | 89 | 0,0445 | [0,0359 ; 0,0545] | 0,0500 | oui | — | 0 |
| CvM | Cramer-von Mises | haut | 2000 | 191 | 0,0955 | [0,0830 ; 0,1092] | 0,1000 | oui | — | 89 | 0,0445 | [0,0359 ; 0,0545] | 0,0500 | oui | — | 0 |
| KS | Kolmogorov-Smirnov contre N(0,1) | haut | 2000 | 168 | 0,0840 | [0,0722 ; 0,0970] | 0,1000 | **non** | dans | 91 | 0,0455 | [0,0368 ; 0,0556] | 0,0500 | oui | — | 0 |
| SW | Shapiro-Wilk sur residus standardises | bas | 2000 | 183 | 0,0915 | [0,0792 ; 0,1050] | 0,1000 | oui | — | 88 | 0,0440 | [0,0354 ; 0,0539] | 0,0500 | oui | — | 0 |
| SF | Shapiro-Francia | bas | 2000 | 178 | 0,0890 | [0,0769 ; 0,1023] | 0,1000 | oui | — | 94 | 0,0470 | [0,0381 ; 0,0572] | 0,0500 | oui | — | 0 |
| JB | Jarque-Bera | haut | 2000 | 180 | 0,0900 | [0,0778 ; 0,1034] | 0,1000 | oui | — | 93 | 0,0465 | [0,0377 ; 0,0567] | 0,0500 | oui | — | 0 |
| DW | Autocorrelation d'ordre 1 (Durbin-Watson) | deux | 2000 | 222 | 0,1110 | [0,0976 ; 0,1256] | 0,1000 | oui | — | 99 | 0,0495 | [0,0404 ; 0,0599] | 0,0500 | oui | — | 0 |
| LB1 | Ljung-Box (retard 1) | haut | 2000 | 214 | 0,1070 | [0,0938 ; 0,1214] | 0,1000 | oui | — | 100 | 0,0500 | [0,0409 ; 0,0605] | 0,0500 | oui | — | 0 |
| supF | Rupture de niveau (sup-F) | haut | 2000 | 209 | 0,1045 | [0,0914 ; 0,1187] | 0,1000 | oui | — | 100 | 0,0500 | [0,0409 ; 0,0605] | 0,0500 | oui | — | 0 |
| CUSUM | Stabilite cumulee (OLS-CUSUM) | haut | 2000 | 208 | 0,1040 | [0,0910 ; 0,1182] | 0,1000 | oui | — | 98 | 0,0490 | [0,0400 ; 0,0594] | 0,0500 | oui | — | 0 |
| Grubbs | Valeur aberrante isolee (Grubbs) | haut | 2000 | 199 | 0,0995 | [0,0867 ; 0,1135] | 0,1000 | oui | — | 94 | 0,0470 | [0,0381 ; 0,0572] | 0,0500 | oui | — | 0 |
| Lillie | Lilliefors (KS a parametres estimes) | haut | 2000 | 173 | 0,0865 | [0,0745 ; 0,0997] | 0,1000 | **non** | dans | 96 | 0,0480 | [0,0391 ; 0,0583] | 0,0500 | oui | — | 0 |
| Intercept | Nullite de la constante (proportionnalite stricte) | deux | 2000 | 212 | 0,1060 | [0,0928 ; 0,1203] | 0,1000 | oui | — | 118 | 0,0590 | [0,0491 ; 0,0702] | 0,0500 | oui | — | 0 |
| RESET | RESET (forme fonctionnelle) | haut | 2000 | 222 | 0,1110 | [0,0976 ; 0,1256] | 0,1000 | oui | — | 112 | 0,0560 | [0,0463 ; 0,0670] | 0,0500 | oui | — | 0 |
| BP | Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | haut | 2000 | 191 | 0,0955 | [0,0830 ; 0,1092] | 0,1000 | oui | — | 95 | 0,0475 | [0,0386 ; 0,0578] | 0,0500 | oui | — | 0 |
| BP79 | Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | haut | 2000 | 184 | 0,0920 | [0,0797 ; 0,1055] | 0,1000 | oui | — | 94 | 0,0470 | [0,0381 ; 0,0572] | 0,0500 | oui | — | 0 |
| White | Heteroscedasticite (forme quadratique) | haut | 2000 | 204 | 0,1020 | [0,0891 ; 0,1161] | 0,1000 | oui | — | 93 | 0,0465 | [0,0377 ; 0,0567] | 0,0500 | oui | — | 0 |
| GQ | Egalite des variances petits vs gros volumes | deux | 2000 | 174 | 0,0870 | [0,0750 ; 0,1002] | 0,1000 | oui | — | 70 | 0,0350 | [0,0274 ; 0,0440] | 0,0500 | **non** | dans | 0 |
| BF | Homogeneite des dispersions (mediane) | haut | 2000 | 193 | 0,0965 | [0,0839 ; 0,1103] | 0,1000 | oui | — | 99 | 0,0495 | [0,0404 ; 0,0599] | 0,0500 | oui | — | 0 |
| Smirnov | Egalite des lois petits vs gros volumes (2 ech.) | haut | 2000 | 63 | 0,0315 | [0,0243 ; 0,0401] | 0,0286 † | oui | — | 63 | 0,0315 | [0,0243 ; 0,0401] | 0,0286 † | oui | — | 0 |
| LB2 | Ljung-Box (retard 2) | haut | 2000 | 201 | 0,1005 | [0,0877 ; 0,1145] | 0,1000 | oui | — | 94 | 0,0470 | [0,0381 ; 0,0572] | 0,0500 | oui | — | 0 |
| BP2 | Box-Pierce (retard 2) | haut | 2000 | 199 | 0,0995 | [0,0867 ; 0,1135] | 0,1000 | oui | — | 97 | 0,0485 | [0,0395 ; 0,0588] | 0,0500 | oui | — | 0 |
| Runs | Test des suites (aleatoire des signes) | deux | 2000 | 125 | 0,0625 | [0,0523 ; 0,0740] | 0,0571 † | oui | — | 18 | 0,0090 | [0,0053 ; 0,0142] | 0,0097 † | oui | — | 0 |
| MK | Tendance monotone du ratio S/P | deux | 2000 | 148 | 0,0740 | [0,0629 ; 0,0864] | 0,0711 † | oui | — | 80 | 0,0400 | [0,0318 ; 0,0495] | 0,0336 † | oui | — | 0 |
| SpearVol | Independance ratio S/P vs volume | deux | 2000 | 180 | 0,0900 | [0,0778 ; 0,1034] | 0,0904 † | oui | — | 101 | 0,0505 | [0,0413 ; 0,0610] | 0,0429 † | oui | — | 0 |
| SpearTps | Correlation ratio S/P vs temps | deux | 2000 | 187 | 0,0935 | [0,0811 ; 0,1071] | 0,0904 † | oui | — | 97 | 0,0485 | [0,0395 ; 0,0588] | 0,0429 † | oui | — | 0 |
| DAgo | Asymetrie (D'Agostino, T >= 8) | deux | 2000 | 179 | 0,0895 | [0,0773 ; 0,1029] | 0,1000 | oui | — | 87 | 0,0435 | [0,0350 ; 0,0534] | 0,0500 | oui | — | 0 |
| CoxStuart | Tendance par signes du ratio S/P | haut | 2000 | 0 | 0,0000 | [0,0000 ; 0,0018] | 0,0006 † | oui | non applicable (réf. < 2/n) | 0 | 0,0000 | [0,0000 ; 0,0018] | 0,0000 † | oui | non applicable (réf. < 2/n) | 0 |
| DWr | Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | deux | 2000 | 214 | 0,1070 | [0,0938 ; 0,1214] | 0,1000 | oui | — | 99 | 0,0495 | [0,0404 ; 0,0599] | 0,0500 | oui | — | 0 |
| LB1r | Ljung-Box (retard 1) sur ratios bruts | haut | 2000 | 208 | 0,1040 | [0,0910 ; 0,1182] | 0,1000 | oui | — | 99 | 0,0495 | [0,0404 ; 0,0599] | 0,0500 | oui | — | 0 |
| Runsr | Test des suites sur ratios bruts | deux | 2000 | 124 | 0,0620 | [0,0518 ; 0,0735] | 0,0571 † | oui | — | 18 | 0,0090 | [0,0053 ; 0,0142] | 0,0097 † | oui | — | 0 |
| supFr | Rupture de niveau (sup-F) sur ratios bruts | haut | 2000 | 202 | 0,1010 | [0,0881 ; 0,1150] | 0,1000 | oui | — | 105 | 0,0525 | [0,0431 ; 0,0632] | 0,0500 | oui | — | 0 |
| CUSUMr | Stabilite cumulee (OLS-CUSUM) sur ratios bruts | haut | 2000 | 209 | 0,1045 | [0,0914 ; 0,1187] | 0,1000 | oui | — | 101 | 0,0505 | [0,0413 ; 0,0610] | 0,0500 | oui | — | 0 |
| Grubbsr | Valeur aberrante isolee (Grubbs) sur ratios bruts | haut | 2000 | 201 | 0,1005 | [0,0877 ; 0,1145] | 0,1000 | oui | — | 98 | 0,0490 | [0,0400 ; 0,0594] | 0,0500 | oui | — | 0 |

n : réplications traitées (2000) où la p_mc est calculée ; p_mc absente : réplications traitées sans p_mc (motif en T3). Statistique continue : référence = seuil ; sous échangeabilité, P(p_mc < seuil) vaut en fait 0,099 et 0,049 en queue simple, 0,098 et 0,048 en bilatéral (B = 999), écart négligeable devant l'IC. † Loi de référence discrète : référence = taille lissée P(p_mc < seuil) sous la loi échangeable à T = 8 sans ex aequo et B = 999 (T0), qui tient compte du bruit Monte-Carlo de la p_mc autour des atomes de la loi.

Multiplicité : T1 compte 68 intervalles (34 statistiques × 2 seuils) ; ici 3 excluent la référence. Sur J1 et J2 réunis, 136 intervalles : environ 7 exclusions (5 % de 136) sont attendues par hasard même si toutes les références sont justes (intervalles corrélés entre eux ; ordre de grandeur, pas un test). T1 bis et T2 ajoutent leurs propres intervalles.

### T1 bis -- calibration de p_mc par régime de δ̂* du réajustement (références de T1)

| Statistique | Régime | n | < 0,10 : k | taux | IC 95 % | réf. dans l'IC | bande [réf/2 ; 3réf/2] | < 0,05 : k | taux | IC 95 % | réf. dans l'IC | bande [réf/2 ; 3réf/2] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AD | δ̂* = 1 (π̂* constant) | 995 | 96 | 0,0965 | [0,0788 ; 0,1165] | oui | — | 42 | 0,0422 | [0,0306 ; 0,0566] | oui | — |
| AD | δ̂* = 0 (π̂* variable) | 930 | 86 | 0,0925 | [0,0746 ; 0,1129] | oui | — | 46 | 0,0495 | [0,0364 ; 0,0654] | oui | — |
| AD | δ̂* intérieur (π̂* variable) | 75 | 3 | 0,0400 | [0,0083 ; 0,1125] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| CvM | δ̂* = 1 (π̂* constant) | 995 | 95 | 0,0955 | [0,0779 ; 0,1155] | oui | — | 44 | 0,0442 | [0,0323 ; 0,0589] | oui | — |
| CvM | δ̂* = 0 (π̂* variable) | 930 | 92 | 0,0989 | [0,0805 ; 0,1199] | oui | — | 44 | 0,0473 | [0,0346 ; 0,0630] | oui | — |
| CvM | δ̂* intérieur (π̂* variable) | 75 | 4 | 0,0533 | [0,0147 ; 0,1310] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| KS | δ̂* = 1 (π̂* constant) | 995 | 79 | 0,0794 | [0,0634 ; 0,0980] | **non** | dans | 45 | 0,0452 | [0,0332 ; 0,0601] | oui | — |
| KS | δ̂* = 0 (π̂* variable) | 930 | 85 | 0,0914 | [0,0737 ; 0,1118] | oui | — | 45 | 0,0484 | [0,0355 ; 0,0642] | oui | — |
| KS | δ̂* intérieur (π̂* variable) | 75 | 4 | 0,0533 | [0,0147 ; 0,1310] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| SW | δ̂* = 1 (π̂* constant) | 995 | 91 | 0,0915 | [0,0743 ; 0,1111] | oui | — | 40 | 0,0402 | [0,0289 ; 0,0543] | oui | — |
| SW | δ̂* = 0 (π̂* variable) | 930 | 89 | 0,0957 | [0,0776 ; 0,1164] | oui | — | 47 | 0,0505 | [0,0374 ; 0,0666] | oui | — |
| SW | δ̂* intérieur (π̂* variable) | 75 | 3 | 0,0400 | [0,0083 ; 0,1125] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| SF | δ̂* = 1 (π̂* constant) | 995 | 89 | 0,0894 | [0,0724 ; 0,1089] | oui | — | 46 | 0,0462 | [0,0340 ; 0,0612] | oui | — |
| SF | δ̂* = 0 (π̂* variable) | 930 | 87 | 0,0935 | [0,0756 ; 0,1141] | oui | — | 47 | 0,0505 | [0,0374 ; 0,0666] | oui | — |
| SF | δ̂* intérieur (π̂* variable) | 75 | 2 | 0,0267 | [0,0032 ; 0,0930] | **non** | estimation hors | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| JB | δ̂* = 1 (π̂* constant) | 995 | 91 | 0,0915 | [0,0743 ; 0,1111] | oui | — | 49 | 0,0492 | [0,0367 ; 0,0646] | oui | — |
| JB | δ̂* = 0 (π̂* variable) | 930 | 89 | 0,0957 | [0,0776 ; 0,1164] | oui | — | 44 | 0,0473 | [0,0346 ; 0,0630] | oui | — |
| JB | δ̂* intérieur (π̂* variable) | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors |
| DW | δ̂* = 1 (π̂* constant) | 995 | 121 | 0,1216 | [0,1019 ; 0,1435] | **non** | dans | 51 | 0,0513 | [0,0384 ; 0,0668] | oui | — |
| DW | δ̂* = 0 (π̂* variable) | 930 | 100 | 0,1075 | [0,0883 ; 0,1292] | oui | — | 47 | 0,0505 | [0,0374 ; 0,0666] | oui | — |
| DW | δ̂* intérieur (π̂* variable) | 75 | 1 | 0,0133 | [0,0003 ; 0,0721] | **non** | estimation hors | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| LB1 | δ̂* = 1 (π̂* constant) | 995 | 105 | 0,1055 | [0,0871 ; 0,1263] | oui | — | 56 | 0,0563 | [0,0428 ; 0,0725] | oui | — |
| LB1 | δ̂* = 0 (π̂* variable) | 930 | 101 | 0,1086 | [0,0893 ; 0,1304] | oui | — | 44 | 0,0473 | [0,0346 ; 0,0630] | oui | — |
| LB1 | δ̂* intérieur (π̂* variable) | 75 | 8 | 0,1067 | [0,0472 ; 0,1994] | oui | — | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors |
| supF | δ̂* = 1 (π̂* constant) | 995 | 104 | 0,1045 | [0,0862 ; 0,1252] | oui | — | 54 | 0,0543 | [0,0410 ; 0,0702] | oui | — |
| supF | δ̂* = 0 (π̂* variable) | 930 | 104 | 0,1118 | [0,0923 ; 0,1339] | oui | — | 45 | 0,0484 | [0,0355 ; 0,0642] | oui | — |
| supF | δ̂* intérieur (π̂* variable) | 75 | 1 | 0,0133 | [0,0003 ; 0,0721] | **non** | estimation hors | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| CUSUM | δ̂* = 1 (π̂* constant) | 995 | 109 | 0,1095 | [0,0908 ; 0,1306] | oui | — | 52 | 0,0523 | [0,0393 ; 0,0680] | oui | — |
| CUSUM | δ̂* = 0 (π̂* variable) | 930 | 98 | 0,1054 | [0,0864 ; 0,1269] | oui | — | 45 | 0,0484 | [0,0355 ; 0,0642] | oui | — |
| CUSUM | δ̂* intérieur (π̂* variable) | 75 | 1 | 0,0133 | [0,0003 ; 0,0721] | **non** | estimation hors | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| Grubbs | δ̂* = 1 (π̂* constant) | 995 | 106 | 0,1065 | [0,0880 ; 0,1274] | oui | — | 51 | 0,0513 | [0,0384 ; 0,0668] | oui | — |
| Grubbs | δ̂* = 0 (π̂* variable) | 930 | 93 | 0,1000 | [0,0815 ; 0,1211] | oui | — | 43 | 0,0462 | [0,0337 ; 0,0618] | oui | — |
| Grubbs | δ̂* intérieur (π̂* variable) | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors |
| Lillie | δ̂* = 1 (π̂* constant) | 995 | 80 | 0,0804 | [0,0643 ; 0,0991] | **non** | dans | 47 | 0,0472 | [0,0349 ; 0,0623] | oui | — |
| Lillie | δ̂* = 0 (π̂* variable) | 930 | 90 | 0,0968 | [0,0785 ; 0,1176] | oui | — | 48 | 0,0516 | [0,0383 ; 0,0679] | oui | — |
| Lillie | δ̂* intérieur (π̂* variable) | 75 | 3 | 0,0400 | [0,0083 ; 0,1125] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| Intercept | δ̂* = 1 (π̂* constant) | 995 | 114 | 0,1146 | [0,0954 ; 0,1360] | oui | — | 58 | 0,0583 | [0,0446 ; 0,0747] | oui | — |
| Intercept | δ̂* = 0 (π̂* variable) | 930 | 92 | 0,0989 | [0,0805 ; 0,1199] | oui | — | 57 | 0,0613 | [0,0467 ; 0,0787] | oui | — |
| Intercept | δ̂* intérieur (π̂* variable) | 75 | 6 | 0,0800 | [0,0299 ; 0,1660] | oui | — | 3 | 0,0400 | [0,0083 ; 0,1125] | oui | — |
| RESET | δ̂* = 1 (π̂* constant) | 995 | 119 | 0,1196 | [0,1001 ; 0,1414] | **non** | dans | 60 | 0,0603 | [0,0463 ; 0,0769] | oui | — |
| RESET | δ̂* = 0 (π̂* variable) | 930 | 99 | 0,1065 | [0,0874 ; 0,1281] | oui | — | 51 | 0,0548 | [0,0411 ; 0,0715] | oui | — |
| RESET | δ̂* intérieur (π̂* variable) | 75 | 4 | 0,0533 | [0,0147 ; 0,1310] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| BP | δ̂* = 1 (π̂* constant) | 995 | 127 | 0,1276 | [0,1075 ; 0,1500] | **non** | dans | 70 | 0,0704 | [0,0552 ; 0,0881] | **non** | dans |
| BP | δ̂* = 0 (π̂* variable) | 930 | 64 | 0,0688 | [0,0534 ; 0,0870] | **non** | dans | 25 | 0,0269 | [0,0175 ; 0,0394] | **non** | dans |
| BP | δ̂* intérieur (π̂* variable) | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors |
| BP79 | δ̂* = 1 (π̂* constant) | 995 | 121 | 0,1216 | [0,1019 ; 0,1435] | **non** | dans | 64 | 0,0643 | [0,0499 ; 0,0814] | oui | — |
| BP79 | δ̂* = 0 (π̂* variable) | 930 | 63 | 0,0677 | [0,0524 ; 0,0858] | **non** | dans | 30 | 0,0323 | [0,0219 ; 0,0457] | **non** | dans |
| BP79 | δ̂* intérieur (π̂* variable) | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors |
| White | δ̂* = 1 (π̂* constant) | 995 | 129 | 0,1296 | [0,1094 ; 0,1521] | **non** | dans | 61 | 0,0613 | [0,0472 ; 0,0781] | oui | — |
| White | δ̂* = 0 (π̂* variable) | 930 | 72 | 0,0774 | [0,0611 ; 0,0965] | **non** | dans | 32 | 0,0344 | [0,0237 ; 0,0482] | **non** | dans |
| White | δ̂* intérieur (π̂* variable) | 75 | 3 | 0,0400 | [0,0083 ; 0,1125] | oui | — | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors |
| GQ | δ̂* = 1 (π̂* constant) | 995 | 103 | 0,1035 | [0,0853 ; 0,1241] | oui | — | 36 | 0,0362 | [0,0255 ; 0,0497] | **non** | dans |
| GQ | δ̂* = 0 (π̂* variable) | 930 | 71 | 0,0763 | [0,0601 ; 0,0953] | **non** | dans | 34 | 0,0366 | [0,0254 ; 0,0507] | oui | — |
| GQ | δ̂* intérieur (π̂* variable) | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors |
| BF | δ̂* = 1 (π̂* constant) | 995 | 116 | 0,1166 | [0,0973 ; 0,1382] | oui | — | 64 | 0,0643 | [0,0499 ; 0,0814] | oui | — |
| BF | δ̂* = 0 (π̂* variable) | 930 | 77 | 0,0828 | [0,0659 ; 0,1024] | oui | — | 35 | 0,0376 | [0,0264 ; 0,0520] | oui | — |
| BF | δ̂* intérieur (π̂* variable) | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors |
| Smirnov | δ̂* = 1 (π̂* constant) | 995 | 31 | 0,0312 | [0,0213 ; 0,0439] | oui | — | 31 | 0,0312 | [0,0213 ; 0,0439] | oui | — |
| Smirnov | δ̂* = 0 (π̂* variable) | 930 | 32 | 0,0344 | [0,0237 ; 0,0482] | oui | — | 32 | 0,0344 | [0,0237 ; 0,0482] | oui | — |
| Smirnov | δ̂* intérieur (π̂* variable) | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | oui | — | 0 | 0,0000 | [0,0000 ; 0,0480] | oui | — |
| LB2 | δ̂* = 1 (π̂* constant) | 995 | 101 | 0,1015 | [0,0834 ; 0,1220] | oui | — | 43 | 0,0432 | [0,0314 ; 0,0578] | oui | — |
| LB2 | δ̂* = 0 (π̂* variable) | 930 | 96 | 0,1032 | [0,0844 ; 0,1246] | oui | — | 50 | 0,0538 | [0,0402 ; 0,0703] | oui | — |
| LB2 | δ̂* intérieur (π̂* variable) | 75 | 4 | 0,0533 | [0,0147 ; 0,1310] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| BP2 | δ̂* = 1 (π̂* constant) | 995 | 99 | 0,0995 | [0,0816 ; 0,1198] | oui | — | 48 | 0,0482 | [0,0358 ; 0,0635] | oui | — |
| BP2 | δ̂* = 0 (π̂* variable) | 930 | 96 | 0,1032 | [0,0844 ; 0,1246] | oui | — | 49 | 0,0527 | [0,0392 ; 0,0691] | oui | — |
| BP2 | δ̂* intérieur (π̂* variable) | 75 | 4 | 0,0533 | [0,0147 ; 0,1310] | oui | — | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors |
| Runs | δ̂* = 1 (π̂* constant) | 995 | 58 | 0,0583 | [0,0446 ; 0,0747] | oui | — | 11 | 0,0111 | [0,0055 ; 0,0197] | oui | — |
| Runs | δ̂* = 0 (π̂* variable) | 930 | 65 | 0,0699 | [0,0544 ; 0,0882] | oui | — | 7 | 0,0075 | [0,0030 ; 0,0154] | oui | — |
| Runs | δ̂* intérieur (π̂* variable) | 75 | 2 | 0,0267 | [0,0032 ; 0,0930] | oui | — | 0 | 0,0000 | [0,0000 ; 0,0480] | oui | non applicable (réf. < 2/n) |
| MK | δ̂* = 1 (π̂* constant) | 995 | 77 | 0,0774 | [0,0616 ; 0,0958] | oui | — | 38 | 0,0382 | [0,0272 ; 0,0520] | oui | — |
| MK | δ̂* = 0 (π̂* variable) | 930 | 66 | 0,0710 | [0,0553 ; 0,0894] | oui | — | 40 | 0,0430 | [0,0309 ; 0,0581] | oui | — |
| MK | δ̂* intérieur (π̂* variable) | 75 | 5 | 0,0667 | [0,0220 ; 0,1488] | oui | — | 2 | 0,0267 | [0,0032 ; 0,0930] | oui | — |
| SpearVol | δ̂* = 1 (π̂* constant) | 995 | 85 | 0,0854 | [0,0688 ; 0,1045] | oui | — | 44 | 0,0442 | [0,0323 ; 0,0589] | oui | — |
| SpearVol | δ̂* = 0 (π̂* variable) | 930 | 91 | 0,0978 | [0,0795 ; 0,1188] | oui | — | 56 | 0,0602 | [0,0458 ; 0,0775] | **non** | dans |
| SpearVol | δ̂* intérieur (π̂* variable) | 75 | 4 | 0,0533 | [0,0147 ; 0,1310] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| SpearTps | δ̂* = 1 (π̂* constant) | 995 | 92 | 0,0925 | [0,0752 ; 0,1122] | oui | — | 48 | 0,0482 | [0,0358 ; 0,0635] | oui | — |
| SpearTps | δ̂* = 0 (π̂* variable) | 930 | 92 | 0,0989 | [0,0805 ; 0,1199] | oui | — | 47 | 0,0505 | [0,0374 ; 0,0666] | oui | — |
| SpearTps | δ̂* intérieur (π̂* variable) | 75 | 3 | 0,0400 | [0,0083 ; 0,1125] | oui | — | 2 | 0,0267 | [0,0032 ; 0,0930] | oui | — |
| DAgo | δ̂* = 1 (π̂* constant) | 995 | 89 | 0,0894 | [0,0724 ; 0,1089] | oui | — | 45 | 0,0452 | [0,0332 ; 0,0601] | oui | — |
| DAgo | δ̂* = 0 (π̂* variable) | 930 | 90 | 0,0968 | [0,0785 ; 0,1176] | oui | — | 42 | 0,0452 | [0,0327 ; 0,0606] | oui | — |
| DAgo | δ̂* intérieur (π̂* variable) | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors |
| CoxStuart | δ̂* = 1 (π̂* constant) | 995 | 0 | 0,0000 | [0,0000 ; 0,0037] | oui | non applicable (réf. < 2/n) | 0 | 0,0000 | [0,0000 ; 0,0037] | oui | non applicable (réf. < 2/n) |
| CoxStuart | δ̂* = 0 (π̂* variable) | 930 | 0 | 0,0000 | [0,0000 ; 0,0040] | oui | non applicable (réf. < 2/n) | 0 | 0,0000 | [0,0000 ; 0,0040] | oui | non applicable (réf. < 2/n) |
| CoxStuart | δ̂* intérieur (π̂* variable) | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | oui | non applicable (réf. < 2/n) | 0 | 0,0000 | [0,0000 ; 0,0480] | oui | non applicable (réf. < 2/n) |
| DWr | δ̂* = 1 (π̂* constant) | 995 | 119 | 0,1196 | [0,1001 ; 0,1414] | **non** | dans | 50 | 0,0503 | [0,0375 ; 0,0657] | oui | — |
| DWr | δ̂* = 0 (π̂* variable) | 930 | 94 | 0,1011 | [0,0825 ; 0,1223] | oui | — | 48 | 0,0516 | [0,0383 ; 0,0679] | oui | — |
| DWr | δ̂* intérieur (π̂* variable) | 75 | 1 | 0,0133 | [0,0003 ; 0,0721] | **non** | estimation hors | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| LB1r | δ̂* = 1 (π̂* constant) | 995 | 104 | 0,1045 | [0,0862 ; 0,1252] | oui | — | 54 | 0,0543 | [0,0410 ; 0,0702] | oui | — |
| LB1r | δ̂* = 0 (π̂* variable) | 930 | 98 | 0,1054 | [0,0864 ; 0,1269] | oui | — | 45 | 0,0484 | [0,0355 ; 0,0642] | oui | — |
| LB1r | δ̂* intérieur (π̂* variable) | 75 | 6 | 0,0800 | [0,0299 ; 0,1660] | oui | — | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors |
| Runsr | δ̂* = 1 (π̂* constant) | 995 | 58 | 0,0583 | [0,0446 ; 0,0747] | oui | — | 11 | 0,0111 | [0,0055 ; 0,0197] | oui | — |
| Runsr | δ̂* = 0 (π̂* variable) | 930 | 64 | 0,0688 | [0,0534 ; 0,0870] | oui | — | 7 | 0,0075 | [0,0030 ; 0,0154] | oui | — |
| Runsr | δ̂* intérieur (π̂* variable) | 75 | 2 | 0,0267 | [0,0032 ; 0,0930] | oui | — | 0 | 0,0000 | [0,0000 ; 0,0480] | oui | non applicable (réf. < 2/n) |
| supFr | δ̂* = 1 (π̂* constant) | 995 | 100 | 0,1005 | [0,0825 ; 0,1209] | oui | — | 55 | 0,0553 | [0,0419 ; 0,0713] | oui | — |
| supFr | δ̂* = 0 (π̂* variable) | 930 | 100 | 0,1075 | [0,0883 ; 0,1292] | oui | — | 49 | 0,0527 | [0,0392 ; 0,0691] | oui | — |
| supFr | δ̂* intérieur (π̂* variable) | 75 | 2 | 0,0267 | [0,0032 ; 0,0930] | **non** | estimation hors | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| CUSUMr | δ̂* = 1 (π̂* constant) | 995 | 107 | 0,1075 | [0,0890 ; 0,1285] | oui | — | 54 | 0,0543 | [0,0410 ; 0,0702] | oui | — |
| CUSUMr | δ̂* = 0 (π̂* variable) | 930 | 101 | 0,1086 | [0,0893 ; 0,1304] | oui | — | 46 | 0,0495 | [0,0364 ; 0,0654] | oui | — |
| CUSUMr | δ̂* intérieur (π̂* variable) | 75 | 1 | 0,0133 | [0,0003 ; 0,0721] | **non** | estimation hors | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| Grubbsr | δ̂* = 1 (π̂* constant) | 995 | 102 | 0,1025 | [0,0844 ; 0,1231] | oui | — | 51 | 0,0513 | [0,0384 ; 0,0668] | oui | — |
| Grubbsr | δ̂* = 0 (π̂* variable) | 930 | 99 | 0,1065 | [0,0874 ; 0,1281] | oui | — | 47 | 0,0505 | [0,0374 ; 0,0666] | oui | — |
| Grubbsr | δ̂* intérieur (π̂* variable) | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors |

Régime du réajustement de run_engine() sur le jeu simulé (seuils TOL_DELTA_BORD de #72) ; effectifs en T3. Volumes non constants (contrôlé) : π̂* constant si et seulement si δ̂* au bord 1. Règle R7 : à π̂* constant, les lignes à loi exacte retiennent la p exacte ; ailleurs, la p_mc. Les taux par régime sont conditionnels à un événement fonction des données et n'ont pas de référence exacte même pour une p_mc parfaitement calibrée : T1 bis localise un écart, il ne teste pas la calibration par régime.

### T2 -- niveau des verdicts des 51 lignes : fréquence de p retenue < α et < α/2 parmi les p retenues (règles R1, R3, R4, R7, R13 comprises)

| Ligne | n | p retenue | < 0,10 : k | taux | IC 95 % | réf. | réf. dans l'IC | bande [réf/2 ; 3réf/2] | < 0,05 : k | taux | IC 95 % | réf. | réf. dans l'IC | bande [réf/2 ; 3réf/2] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Nullite de la constante (proportionnalite stricte) | 2000 | 2000 | 212 | 0,1060 | [0,0928 ; 0,1203] | 0,1000 | oui | — | 118 | 0,0590 | [0,0491 ; 0,0702] | 0,0500 | oui | — |
| Equivalence de la constante a zero (TOST) | 2000 | 2000 | 0 | 0,0000 | [0,0000 ; 0,0018] | sans objet (H0 \|a\| ≥ Δ fausse sous le modèle ajusté, a = 0 ; sens « rejeter ») | — | — | 0 | 0,0000 | [0,0000 ; 0,0018] | sans objet (H0 \|a\| ≥ Δ fausse sous le modèle ajusté, a = 0 ; sens « rejeter ») | — | — |
| Test de Student sur la pente (lm(y~x)) | 2000 | 1241 | 705 | 0,5681 | [0,5400 ; 0,5959] | sans objet (H0 β = 0 fausse ; sens « rejeter ») | — | — | 487 | 0,3924 | [0,3651 ; 0,4202] | sans objet (H0 β = 0 fausse ; sens « rejeter ») | — | — |
| Test de Fisher (significativite globale) | 2000 | 1241 | 705 | 0,5681 | [0,5400 ; 0,5959] | sans objet (H0 β = 0 fausse ; sens « rejeter ») | — | — | 487 | 0,3924 | [0,3651 ; 0,4202] | sans objet (H0 β = 0 fausse ; sens « rejeter ») | — | — |
| Coefficient de determination R2 | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| RESET (forme fonctionnelle) | 2000 | 2000 | 222 | 0,1110 | [0,0976 ; 0,1256] | 0,1000 | oui | — | 112 | 0,0560 | [0,0463 ; 0,0670] | 0,0500 | oui | — |
| Independance ratio S/P vs volume | 2000 | 2000 | 186 | 0,0930 | [0,0806 ; 0,1066] | 0,0933 † | oui | — | 105 | 0,0525 | [0,0431 ; 0,0632] | 0,0444 † | oui | — |
| Correlation ratio S/P vs temps | 2000 | 2000 | 186 | 0,0930 | [0,0806 ; 0,1066] | 0,0933 † | oui | — | 97 | 0,0485 | [0,0395 ; 0,0588] | 0,0444 † | oui | — |
| Tendance monotone du ratio S/P | 2000 | 2000 | 139 | 0,0695 | [0,0587 ; 0,0815] | 0,0661 † | oui | — | 75 | 0,0375 | [0,0296 ; 0,0468] | 0,0324 † | oui | — |
| Tendance par signes du ratio S/P | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | 2000 | 2000 | 191 | 0,0955 | [0,0830 ; 0,1092] | 0,1000 | oui | — | 95 | 0,0475 | [0,0386 ; 0,0578] | 0,0500 | oui | — |
| Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | 2000 | 2000 | 184 | 0,0920 | [0,0797 ; 0,1055] | 0,1000 | oui | — | 94 | 0,0470 | [0,0381 ; 0,0572] | 0,0500 | oui | — |
| Heteroscedasticite (forme quadratique) | 2000 | 2000 | 204 | 0,1020 | [0,0891 ; 0,1161] | 0,1000 | oui | — | 93 | 0,0465 | [0,0377 ; 0,0567] | 0,0500 | oui | — |
| Egalite des variances petits vs gros volumes | 2000 | 2000 | 174 | 0,0870 | [0,0750 ; 0,1002] | 0,1000 | oui | — | 70 | 0,0350 | [0,0274 ; 0,0440] | 0,0500 | **non** | dans |
| Homogeneite des dispersions (mediane) | 2000 | 2000 | 193 | 0,0965 | [0,0839 ; 0,1103] | 0,1000 | oui | — | 99 | 0,0495 | [0,0404 ; 0,0599] | 0,0500 | oui | — |
| Egalite des lois petits vs gros volumes (2 ech.) | 2000 | 2000 | 63 | 0,0315 | [0,0243 ; 0,0401] | 0,0286 † | oui | — | 63 | 0,0315 | [0,0243 ; 0,0401] | 0,0286 † | oui | — |
| Position de delta dans [0,1] | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Shapiro-Wilk sur residus standardises | 2000 | 2000 | 183 | 0,0915 | [0,0792 ; 0,1050] | 0,1000 | oui | — | 88 | 0,0440 | [0,0354 ; 0,0539] | 0,0500 | oui | — |
| Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston) | 2000 | 995 | 94 | 0,0945 | [0,0770 ; 0,1144] | 0,1000 | oui | — | 43 | 0,0432 | [0,0314 ; 0,0578] | 0,0500 | oui | — |
| Shapiro-Francia | 2000 | 2000 | 178 | 0,0890 | [0,0769 ; 0,1023] | 0,1000 | oui | — | 94 | 0,0470 | [0,0381 ; 0,0572] | 0,0500 | oui | — |
| Anderson-Darling | 2000 | 2000 | 185 | 0,0925 | [0,0802 ; 0,1061] | 0,1000 | oui | — | 89 | 0,0445 | [0,0359 ; 0,0545] | 0,0500 | oui | — |
| Cramer-von Mises | 2000 | 2000 | 191 | 0,0955 | [0,0830 ; 0,1092] | 0,1000 | oui | — | 89 | 0,0445 | [0,0359 ; 0,0545] | 0,0500 | oui | — |
| Kolmogorov-Smirnov contre N(0,1) | 2000 | 2000 | 168 | 0,0840 | [0,0722 ; 0,0970] | 0,1000 | **non** | dans | 91 | 0,0455 | [0,0368 ; 0,0556] | 0,0500 | oui | — |
| Lilliefors (KS a parametres estimes) | 2000 | 2000 | 173 | 0,0865 | [0,0745 ; 0,0997] | 0,1000 | **non** | dans | 96 | 0,0480 | [0,0391 ; 0,0583] | 0,0500 | oui | — |
| Jarque-Bera | 2000 | 2000 | 180 | 0,0900 | [0,0778 ; 0,1034] | 0,1000 | oui | — | 93 | 0,0465 | [0,0377 ; 0,0567] | 0,0500 | oui | — |
| Asymetrie (D'Agostino, T >= 8) | 2000 | 2000 | 179 | 0,0895 | [0,0773 ; 0,1029] | 0,1000 | oui | — | 87 | 0,0435 | [0,0350 ; 0,0534] | 0,0500 | oui | — |
| Aplatissement (Anscombe-Glynn, T >= 20) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Autocorrelation d'ordre 1 (Durbin-Watson) | 2000 | 2000 | 218 | 0,1090 | [0,0957 ; 0,1235] | 0,1000 | oui | — | 95 | 0,0475 | [0,0386 ; 0,0578] | 0,0500 | oui | — |
| Ljung-Box (retard 1) | 2000 | 2000 | 214 | 0,1070 | [0,0938 ; 0,1214] | 0,1000 | oui | — | 100 | 0,0500 | [0,0409 ; 0,0605] | 0,0500 | oui | — |
| Ljung-Box (retard 2) | 2000 | 2000 | 201 | 0,1005 | [0,0877 ; 0,1145] | 0,1000 | oui | — | 94 | 0,0470 | [0,0381 ; 0,0572] | 0,0500 | oui | — |
| Box-Pierce (retard 2) | 2000 | 2000 | 199 | 0,0995 | [0,0867 ; 0,1135] | 0,1000 | oui | — | 97 | 0,0485 | [0,0395 ; 0,0588] | 0,0500 | oui | — |
| Test des suites (aleatoire des signes) | 2000 | 2000 | 125 | 0,0625 | [0,0523 ; 0,0740] | 0,0571 † | oui | — | 7 | 0,0035 | [0,0014 ; 0,0072] | 0,0049 † | oui | — |
| Centrage des residus standardises | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Variance unitaire des residus standardises | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Rupture de niveau (sup-F) | 2000 | 2000 | 209 | 0,1045 | [0,0914 ; 0,1187] | 0,1000 | oui | — | 100 | 0,0500 | [0,0409 ; 0,0605] | 0,0500 | oui | — |
| Stabilite cumulee (OLS-CUSUM) | 2000 | 2000 | 208 | 0,1040 | [0,0910 ; 0,1182] | 0,1000 | oui | — | 98 | 0,0490 | [0,0400 ; 0,0594] | 0,0500 | oui | — |
| Valeur aberrante isolee (Grubbs) | 2000 | 2000 | 199 | 0,0995 | [0,0867 ; 0,1135] | 0,1000 | oui | — | 94 | 0,0470 | [0,0381 ; 0,0572] | 0,0500 | oui | — |
| Valeurs aberrantes multiples (ESD generalise) | 2000 | — (procédure sans p-value) | 279 | 0,1395 | [0,1246 ; 0,1555] | 0,1000 ‡ | **non** | dans | 107 | 0,0535 | [0,0440 ; 0,0643] | — | — | — |
| Points influents (distance de Cook) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | 2000 | 2000 | 214 | 0,1070 | [0,0938 ; 0,1214] | 0,1000 | oui | — | 99 | 0,0495 | [0,0404 ; 0,0599] | 0,0500 | oui | — |
| Ljung-Box (retard 1) sur ratios bruts | 2000 | 2000 | 208 | 0,1040 | [0,0910 ; 0,1182] | 0,1000 | oui | — | 99 | 0,0495 | [0,0404 ; 0,0599] | 0,0500 | oui | — |
| Test des suites sur ratios bruts | 2000 | 2000 | 124 | 0,0620 | [0,0518 ; 0,0735] | 0,0571 † | oui | — | 7 | 0,0035 | [0,0014 ; 0,0072] | 0,0049 † | oui | — |
| Rupture de niveau (sup-F) sur ratios bruts | 2000 | 2000 | 202 | 0,1010 | [0,0881 ; 0,1150] | 0,1000 | oui | — | 105 | 0,0525 | [0,0431 ; 0,0632] | 0,0500 | oui | — |
| Stabilite cumulee (OLS-CUSUM) sur ratios bruts | 2000 | 2000 | 209 | 0,1045 | [0,0914 ; 0,1187] | 0,1000 | oui | — | 101 | 0,0505 | [0,0413 ; 0,0610] | 0,0500 | oui | — |
| Valeur aberrante isolee (Grubbs) sur ratios bruts | 2000 | 2000 | 201 | 0,1005 | [0,0877 ; 0,1145] | 0,1000 | oui | — | 98 | 0,0490 | [0,0400 ; 0,0594] | 0,0500 | oui | — |
| Leviers (hat values) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Sensibilite au retrait d'une annee (jackknife) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Largeur relative de l'IC bootstrap 90% | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Rapport de vraisemblance : delta = 0 (variance lineaire en volume) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Rapport de vraisemblance : delta = 1 (variance quadratique en volume) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |

n : réplications traitées ; p retenue : réplications où la ligne a une p retenue. Taux = rejets / p retenues (niveau conditionnel à l'existence d'une p retenue) ; la fréquence inconditionnelle du verdict, rejets / n, se lit dans T2 (suite), colonnes ALERTE et ECHEC. Sens « ne pas rejeter » : p < α donne ALERTE ou ECHEC, p < α/2 ECHEC. Pour les trois lignes en sens « rejeter » (pente, Fisher, TOST), p < α est un OK : les colonnes donnent une puissance conditionnelle, sans référence.

† Loi de référence discrète : référence = (n_exacte × taille atteignable + n_MC × taille lissée) / (n_exacte + n_MC), sur les natures de la p retenue comptées en T2 (suite) ; référence **approchée** : elle suppose l'échangeabilité et ignore la sélection par le régime (à π̂* variable, la p retenue de ces lignes est la p_mc, règle R7, dont le niveau n'est qu'approché par la taille lissée). Une p retenue d'une autre nature (repli asymptotique nommé, règle R3 ; attendu 0 à T = 8 sans ex æquo) compte dans np et dans les rejets, non dans la référence, alors suivie de « (n hors réf. = k) ».

‡ Ligne ESD (procédure de décision, sans p-value) : première colonne, ALERTE ou ECHEC, mesure P(k̂ ≥ 1), sur les réplications traitées, contre 0,10, niveau nominal de la procédure de Rosner, valeurs critiques à 1 − α/(2 n_i) ; exactitude non établie à T = 8 ni sur z = Pε. Seconde colonne : ECHEC, mesure P(k̂ = 2), sans niveau nominal.

### T2 (suite) -- composition des lignes : types, nature de la p retenue, verdicts

| Ligne | n | test | diagnostic | dont inopérant (R1) | non applicable | procédure de décision | p exacte | p Monte-Carlo | p asymptotique | autre p | aucune p | OK | ALERTE | ECHEC | INFO |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Nullite de la constante (proportionnalite stricte) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1788 | 94 | 118 | 0 |
| Equivalence de la constante a zero (TOST) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 | 0 |
| Test de Student sur la pente (lm(y~x)) | 2000 | 1241 | 759 | 0 | 0 | 0 | 0 | 0 | 0 | 1241 | 759 | 705 | 323 | 213 | 759 |
| Test de Fisher (significativite globale) | 2000 | 1241 | 759 | 0 | 0 | 0 | 0 | 0 | 0 | 1241 | 759 | 705 | 323 | 213 | 759 |
| Coefficient de determination R2 | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| RESET (forme fonctionnelle) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1778 | 110 | 112 | 0 |
| Independance ratio S/P vs volume | 2000 | 2000 | 0 | 0 | 0 | 0 | 995 | 1005 | 0 | 0 | 0 | 1814 | 81 | 105 | 0 |
| Correlation ratio S/P vs temps | 2000 | 2000 | 0 | 0 | 0 | 0 | 995 | 1005 | 0 | 0 | 0 | 1814 | 89 | 97 | 0 |
| Tendance monotone du ratio S/P | 2000 | 2000 | 0 | 0 | 0 | 0 | 995 | 1005 | 0 | 0 | 0 | 1861 | 64 | 75 | 0 |
| Tendance par signes du ratio S/P | 2000 | 0 | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1809 | 96 | 95 | 0 |
| Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1816 | 90 | 94 | 0 |
| Heteroscedasticite (forme quadratique) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1796 | 111 | 93 | 0 |
| Egalite des variances petits vs gros volumes | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1826 | 104 | 70 | 0 |
| Homogeneite des dispersions (mediane) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1807 | 94 | 99 | 0 |
| Egalite des lois petits vs gros volumes (2 ech.) | 2000 | 2000 | 0 | 0 | 0 | 0 | 995 | 1005 | 0 | 0 | 0 | 1937 | 0 | 63 | 0 |
| Position de delta dans [0,1] | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Shapiro-Wilk sur residus standardises | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1817 | 95 | 88 | 0 |
| Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston) | 2000 | 995 | 0 | 0 | 1005 | 0 | 995 | 0 | 0 | 0 | 1005 | 901 | 51 | 43 | 1005 |
| Shapiro-Francia | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1822 | 84 | 94 | 0 |
| Anderson-Darling | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1815 | 96 | 89 | 0 |
| Cramer-von Mises | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1809 | 102 | 89 | 0 |
| Kolmogorov-Smirnov contre N(0,1) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1832 | 77 | 91 | 0 |
| Lilliefors (KS a parametres estimes) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1827 | 77 | 96 | 0 |
| Jarque-Bera | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1820 | 87 | 93 | 0 |
| Asymetrie (D'Agostino, T >= 8) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1821 | 92 | 87 | 0 |
| Aplatissement (Anscombe-Glynn, T >= 20) | 2000 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Autocorrelation d'ordre 1 (Durbin-Watson) | 2000 | 2000 | 0 | 0 | 0 | 0 | 995 | 1005 | 0 | 0 | 0 | 1782 | 123 | 95 | 0 |
| Ljung-Box (retard 1) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1786 | 114 | 100 | 0 |
| Ljung-Box (retard 2) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1799 | 107 | 94 | 0 |
| Box-Pierce (retard 2) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1801 | 102 | 97 | 0 |
| Test des suites (aleatoire des signes) | 2000 | 2000 | 0 | 0 | 0 | 0 | 995 | 1005 | 0 | 0 | 0 | 1875 | 118 | 7 | 0 |
| Centrage des residus standardises | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Variance unitaire des residus standardises | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Rupture de niveau (sup-F) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1791 | 109 | 100 | 0 |
| Stabilite cumulee (OLS-CUSUM) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1792 | 110 | 98 | 0 |
| Valeur aberrante isolee (Grubbs) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1801 | 105 | 94 | 0 |
| Valeurs aberrantes multiples (ESD generalise) | 2000 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 0 | 2000 | 1721 | 172 | 107 | 0 |
| Points influents (distance de Cook) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1786 | 115 | 99 | 0 |
| Ljung-Box (retard 1) sur ratios bruts | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1792 | 109 | 99 | 0 |
| Test des suites sur ratios bruts | 2000 | 2000 | 0 | 0 | 0 | 0 | 995 | 1005 | 0 | 0 | 0 | 1876 | 117 | 7 | 0 |
| Rupture de niveau (sup-F) sur ratios bruts | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1798 | 97 | 105 | 0 |
| Stabilite cumulee (OLS-CUSUM) sur ratios bruts | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1791 | 108 | 101 | 0 |
| Valeur aberrante isolee (Grubbs) sur ratios bruts | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1799 | 103 | 98 | 0 |
| Leviers (hat values) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Sensibilite au retrait d'une annee (jackknife) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Largeur relative de l'IC bootstrap 90% | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Rapport de vraisemblance : delta = 0 (variance lineaire en volume) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Rapport de vraisemblance : delta = 1 (variance quadratique en volume) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |

Nature : champ nature_p de la ligne (exacte ; Monte-Carlo ; asymptotique, repli nommé compris ; autre : p sous le modèle auxiliaire MCO, TOST, Student sur la pente et Fisher). Inopérant : détail préfixé « TEST INOPERANT » (règle R1), compté aussi en diagnostic.

### T3 -- régimes, réplications écartées, motifs, contrôles de la famille H, rapport de vraisemblance, IC bootstrap

Régimes de δ̂* :

| Régime | run_engine() (réplications traitées) | code de #72 : usp_ajuster(x, y*) (toutes) |
| --- | --- | --- |
| δ̂* = 1 (π̂* constant) | 995 | 995 |
| δ̂* = 0 (π̂* variable) | 930 | 930 |
| δ̂* intérieur (π̂* variable) | 75 | 75 |
| usp_ajuster() en erreur | 0 | 0 |
| Total | 2000 | 2000 |

Réplications écartées (erreur de run_engine() ou ok = FALSE) : 0 sur 2000.

Motifs d'absence de p_mc (motif_mc, réplications traitées) :

aucun.

Contrôles numériques de la famille H (res$controles, verdicts) :

| Contrôle | OK | ALERTE | ECHEC | autre |
| --- | --- | --- | --- | --- |
| Condition du premier ordre (gradient projete, KKT) | 2000 | 0 | 0 | 0 |
| Convergence multi-demarrages | 2000 | 0 | 0 | 0 |

p_mc des deux lignes du rapport de vraisemblance (#45 ; hors objet de T1 et T2, sans référence) :

| Ligne | Régime de δ̂* | n | < 0,10 : k | taux | IC 95 % | < 0,05 : k | taux | IC 95 % |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Rapport de vraisemblance : δ = 0 | δ̂* = 1 (π̂* constant) | 995 | 268 | 0,2693 | [0,2420 ; 0,2981] | 127 | 0,1276 | [0,1075 ; 0,1500] |
| Rapport de vraisemblance : δ = 0 | δ̂* = 0 (π̂* variable) | 930 | 0 | 0,0000 | [0,0000 ; 0,0040] | 0 | 0,0000 | [0,0000 ; 0,0040] |
| Rapport de vraisemblance : δ = 0 | δ̂* intérieur (π̂* variable) | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0 | 0,0000 | [0,0000 ; 0,0480] |
| Rapport de vraisemblance : δ = 0 | tous | 2000 | 268 | 0,1340 | [0,1194 ; 0,1497] | 127 | 0,0635 | [0,0532 ; 0,0751] |
| Rapport de vraisemblance : δ = 1 | δ̂* = 1 (π̂* constant) | 995 | 0 | 0,0000 | [0,0000 ; 0,0037] | 0 | 0,0000 | [0,0000 ; 0,0037] |
| Rapport de vraisemblance : δ = 1 | δ̂* = 0 (π̂* variable) | 930 | 180 | 0,1935 | [0,1686 ; 0,2204] | 79 | 0,0849 | [0,0678 ; 0,1047] |
| Rapport de vraisemblance : δ = 1 | δ̂* intérieur (π̂* variable) | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0 | 0,0000 | [0,0000 ; 0,0480] |
| Rapport de vraisemblance : δ = 1 | tous | 2000 | 180 | 0,0900 | [0,0778 ; 0,1034] | 79 | 0,0395 | [0,0314 ; 0,0490] |

Motifs d'absence de p_mc du rapport de vraisemblance : aucun.

Largeur relative de l'IC bootstrap 90 % (contrôle (e4)) : au-dessus de 0,50 dans 981 réplication(s), au-dessus de 0,80 dans 0, sur 2000 où elle est finie.

Bootstrap interne : 0 réplication(s) écartée(s) par usp_bootstrap() sur 1998000 (B = 999 par réplication traitée), dans 0 réplication(s) ; bootstrap restreint (#45) : 0 échec(s) du réajustement contraint ; rapport de vraisemblance : 0 (δ = 0) et 0 (δ = 1) réplication(s) écartée(s).

### Contrôles d'intégrité

- (a) à (d), (e1), (e2), (f) et contrôles de cohérence : OK dans les 8 tranche(s) (ligne INTEGRITE)
- Invariants du corps des tranches (comptes et lignes REP) : OK dans les 8 tranche(s) ; somme des rep = R = 2000
- (e3) effectifs des régimes contre le tableau de #72 : OK : δ̂* au bord 0 : 930 (tableau de #72 : 930 sur 2000) ; au bord 1 : 995 (tableau de #72 : 995 sur 2000) ; usp_ajuster() en erreur : 0 ; docs/tableaux/20260930-issue122-J1.md
- (e4) largeur de l'IC bootstrap contre le tableau de #72 : OK : largeur relative de l'IC bootstrap 90 % au-dessus de 0,50 : 981 sur 2000 (tableau de #72 : 981 sur 2000) ; au-dessus de 0,80 : 0 (tableau de #72 : 0 sur 2000) ; docs/tableaux/20260930-issue122-J1.md

