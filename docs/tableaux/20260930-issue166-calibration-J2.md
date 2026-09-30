## Calibration des p-values Monte-Carlo à T = 8, jeu J2 -- combinaison de 8 tranche(s) (issue #166)

Paramètres : jeu=J2;R=2000;graine_jeux=20260927;graine_boot=20260831;B=999;methode=premium;segment=1;annexe=II;nature=brutes;alpha=0.1;theta_equiv=0.1

### T0 -- contexte (identique dans toutes les tranches, vérifié)

| Grandeur | Valeur |
| --- | --- |
| Jeu | J2 : xi, yi de tests/unitaires/test_controles_numeriques.R (δ estimé intérieur) |
| Modèle ajusté (usp_ajuster()) | δ̂ = 0.663991 ; γ̂ = -2.31999 ; β̂ = 0.701657 ; σ̂ = 0.0689553 ; π̂ constant : FALSE |
| Configuration de run_engine() | méthode premium, segment 1 de l'annexe II, données brutes, α = 0.1, theta_equiv = 0.1, σ standard = 0.1, barème long, B = 999 |
| σ_USP observé (usp_parametre() sur le modèle ajusté) | 0.0871309 |
| Graines | jeux simulés : un flux sous 20260927 (chemin de #72) ; bootstrap et rapport de vraisemblance de la réplication b : 20260831 + b ; J1 observé (a) : 20260831 |
| Graines en collision (déclarées, non bloquantes) | réplication 96 : graine du bootstrap 20260927 = graine des jeux simulés (effet borné : réplication 96, \|Δp_mc\| ≤ 1/(B+1) = 0,001 en queue simple et 2/(B+1) = 0,002 en bilatéral, sur ses seules p_mc (au plus 1/R sur un taux), ses 998 autres réplications internes restant indépendantes de y_96) ; réplication 70 : graine du bootstrap 20260901 = SEED_LOI_NULLE_SW (loi nulle de Shapiro-Wilk) (réplication 70, lois marginales de p_mc et p_exacte inchangées (seule leur loi jointe est touchée, non mesurée)) |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Commit | 51ae1ab3f1d8157782b9017b749c974e1f943089 |
| Plateforme de calcul (R, système, machine, BLAS, LAPACK) | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.4 LTS ; Linux, x86_64 ; BLAS : /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.12.0 ; LAPACK : /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.12.0 (version 3.12.0) |
| Empreintes md5 du code exécuté | R/engine.R 37798c2725debf37548f56ce055fb714 ; tests/outils_tests.R chargé (dépôt) d6d30b0cfe7189e96c5c07559a2f69f0 ; script exécuté (dépôt) 24b212c671db4898372e3c5412d0fe2d ; tests/taux_franchissement_reperes.R a6d499027467dc6d895a4265bba7384b |
| Contrôle (a) : J1 observé contre tests/reference/premium.rds | conforme ; 23634 feuille(s), 0 non strictement identique(s), écart maximal 0.000e+00 |
| Tailles des lois discrètes, P(p < 0,10) et P(p < 0,05) (T = 8, sans ex aequo) | suites (Swed-Eisenhart, 4 et 4) : atteignable 0,05714 et 0,00000, lissée 0,05713 et 0,00968 ; Mann-Kendall (loi mahonienne) : atteignable 0,06101 et 0,03115, lissée 0,07107 et 0,03355 ; Smirnov (4 et 4) : atteignable 0,02857 et 0,02857, lissée 0,02857 et 0,02856 ; Spearman (loi de permutation) : atteignable 0,09618 et 0,04583, lissée 0,09038 et 0,04295 ; Cox-Stuart (Binomiale(4, 1/2)) : atteignable 0,00000 et 0,00000, lissée 0,00059 et 0,00000 |
| Réplications | 2000 (8 tranche(s) : 1-250, 251-500, 501-750, 751-1000, 1001-1250, 1251-1500, 1501-1750, 1751-2000) |
| Durée cumulée des tranches (s) | contrôles 145 ; réplications 30131 (15.1 s par réplication) |
| Commit de la combinaison | 808b448a18bca66df1cf00c62a0299f89a073600 |
| Empreintes md5 du combinateur | R/engine.R 37798c2725debf37548f56ce055fb714 ; tests/outils_tests.R chargé (dépôt) d6d30b0cfe7189e96c5c07559a2f69f0 ; script exécuté (dépôt) 12a716c1b095333a3c25a2da7ccaa4a8 ; tests/taux_franchissement_reperes.R 64064208f6024a65680a246417de31b9 |
| Versionnable (--ecrire) | oui |
| Contrôles d'intégrité | OK dans les 8 tranche(s), invariants du corps vérifiés ; (e3) : OK : δ̂* au bord 0 : 814 (tableau de #72 : 814 sur 2000) ; au bord 1 : 722 (tableau de #72 : 722 sur 2000) ; usp_ajuster() en erreur : 0 ; docs/tableaux/20260930-issue122-J2.md ; (e4) : OK : largeur relative de l'IC bootstrap 90 % au-dessus de 0,50 : 85 sur 2000 (tableau de #72 : 85 sur 2000) ; au-dessus de 0,80 : 0 (tableau de #72 : 0 sur 2000) ; docs/tableaux/20260930-issue122-J2.md |

### Aide à la lecture (sans conclusion)

Statut : **constat de simulation sous le modèle ajusté au jeu** (usp_simuler(FIT0)), pas un résultat général. Chaque réplication est traitée par run_engine() complet (B = 999) : la mesure porte sur la procédure du dossier (réajustement, bootstrap paramétrique, engine_p_mc(), verdict de add()). Protocole d'actuary (#122, commentaire 5905003573 ; décisions du mainteneur, commentaire 5905011303 ; issue #166).

IC : Clopper-Pearson à 95 %, incertitude Monte-Carlo sur le taux (fonction de R), pas l'erreur d'approximation en T ; l'erreur liée à B fait partie de la procédure mesurée. « oui » dans « réf. dans l'IC » se lit « compatible » au sens de « aucune distorsion détectée à la précision Monte-Carlo », jamais « exact ».

Bande de Bradley (1978), critère libéral [réf/2 ; 3réf/2] : **convention, pas théorème** (J. V. Bradley, « Robustness? », *British Journal of Mathematical and Statistical Psychology* 31(2), 1978, p. 144-152). Le rapport 0,5-1,5 au niveau nominal est la règle de Bradley elle-même à tout seuil : [0,05 ; 0,15] à 0,10, [0,025 ; 0,075] à 0,05. Pour une référence discrète (†), la bande est la transposition en rapport du critère de Bradley à la taille de référence (convention du script). Colonne « bande », écrite seulement si la référence est hors de l'IC : « dans » : estimation dans la bande ; « estimation hors » : estimation hors de la bande, IC la recoupant ; « IC entièrement hors » : IC disjoint de la bande ; « non applicable (réf. < 2/n) » : voir ci-dessous ; « — » : référence dans l'IC, ou pas de référence.

Lecture, par actuary, à partir des colonnes « réf. dans l'IC » et « bande » : (1) l'IC contient la référence : **compatible** (la bande n'est pas écrite) ; (2) sinon, estimation dans la bande : **écart mineur**, consigné en rubrique 7 ; (3) IC disjoint de la bande : **distorsion matérielle**, point de décision du mainteneur ; (4) sinon (estimation hors de la bande, IC la recoupant) : **écart non tranché**, distorsion possible non établie à la précision Monte-Carlo, consigné en rubrique 7 avec l'IC, à éclairer par T1 bis et les valeurs brutes, sans décision déclenchée. Bande non applicable quand la référence est inférieure à 2/n (sa demi-largeur ref/2 est sous la résolution 1/n du taux ; Cox-Stuart) : lecture binaire, compatible ou **écart à examiner** (k et IC cités), sans échelle mineur / matériel ni décision déclenchée ; une référence nulle n'est pas ramenée à une bande {0}.

### T1 -- calibration de p_mc : les 34 statistiques de USP_CATALOGUE_MC (p_mc retenue ou non)

| Statistique | Ligne de usp_tests() | Queue | n | < 0,10 : k | taux | IC 95 % | réf. | réf. dans l'IC | bande [réf/2 ; 3réf/2] | < 0,05 : k | taux | IC 95 % | réf. | réf. dans l'IC | bande [réf/2 ; 3réf/2] | p_mc absente |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AD | Anderson-Darling | haut | 2000 | 204 | 0,1020 | [0,0891 ; 0,1161] | 0,1000 | oui | — | 90 | 0,0450 | [0,0363 ; 0,0550] | 0,0500 | oui | — | 0 |
| CvM | Cramer-von Mises | haut | 2000 | 194 | 0,0970 | [0,0844 ; 0,1108] | 0,1000 | oui | — | 93 | 0,0465 | [0,0377 ; 0,0567] | 0,0500 | oui | — | 0 |
| KS | Kolmogorov-Smirnov contre N(0,1) | haut | 2000 | 180 | 0,0900 | [0,0778 ; 0,1034] | 0,1000 | oui | — | 92 | 0,0460 | [0,0372 ; 0,0561] | 0,0500 | oui | — | 0 |
| SW | Shapiro-Wilk sur residus standardises | bas | 2000 | 189 | 0,0945 | [0,0820 ; 0,1082] | 0,1000 | oui | — | 89 | 0,0445 | [0,0359 ; 0,0545] | 0,0500 | oui | — | 0 |
| SF | Shapiro-Francia | bas | 2000 | 170 | 0,0850 | [0,0731 ; 0,0981] | 0,1000 | **non** | dans | 92 | 0,0460 | [0,0372 ; 0,0561] | 0,0500 | oui | — | 0 |
| JB | Jarque-Bera | haut | 2000 | 170 | 0,0850 | [0,0731 ; 0,0981] | 0,1000 | **non** | dans | 81 | 0,0405 | [0,0323 ; 0,0501] | 0,0500 | oui | — | 0 |
| DW | Autocorrelation d'ordre 1 (Durbin-Watson) | deux | 2000 | 205 | 0,1025 | [0,0895 ; 0,1166] | 0,1000 | oui | — | 96 | 0,0480 | [0,0391 ; 0,0583] | 0,0500 | oui | — | 0 |
| LB1 | Ljung-Box (retard 1) | haut | 2000 | 218 | 0,1090 | [0,0957 ; 0,1235] | 0,1000 | oui | — | 106 | 0,0530 | [0,0436 ; 0,0637] | 0,0500 | oui | — | 0 |
| supF | Rupture de niveau (sup-F) | haut | 2000 | 187 | 0,0935 | [0,0811 ; 0,1071] | 0,1000 | oui | — | 103 | 0,0515 | [0,0422 ; 0,0621] | 0,0500 | oui | — | 0 |
| CUSUM | Stabilite cumulee (OLS-CUSUM) | haut | 2000 | 198 | 0,0990 | [0,0863 ; 0,1129] | 0,1000 | oui | — | 96 | 0,0480 | [0,0391 ; 0,0583] | 0,0500 | oui | — | 0 |
| Grubbs | Valeur aberrante isolee (Grubbs) | haut | 2000 | 167 | 0,0835 | [0,0717 ; 0,0965] | 0,1000 | **non** | dans | 83 | 0,0415 | [0,0332 ; 0,0512] | 0,0500 | oui | — | 0 |
| Lillie | Lilliefors (KS a parametres estimes) | haut | 2000 | 176 | 0,0880 | [0,0759 ; 0,1013] | 0,1000 | oui | — | 96 | 0,0480 | [0,0391 ; 0,0583] | 0,0500 | oui | — | 0 |
| Intercept | Nullite de la constante (proportionnalite stricte) | deux | 2000 | 200 | 0,1000 | [0,0872 ; 0,1140] | 0,1000 | oui | — | 119 | 0,0595 | [0,0495 ; 0,0708] | 0,0500 | oui | — | 0 |
| RESET | RESET (forme fonctionnelle) | haut | 2000 | 166 | 0,0830 | [0,0713 ; 0,0960] | 0,1000 | **non** | dans | 65 | 0,0325 | [0,0252 ; 0,0412] | 0,0500 | **non** | dans | 0 |
| BP | Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | haut | 2000 | 170 | 0,0850 | [0,0731 ; 0,0981] | 0,1000 | **non** | dans | 74 | 0,0370 | [0,0292 ; 0,0462] | 0,0500 | **non** | dans | 0 |
| BP79 | Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | haut | 2000 | 151 | 0,0755 | [0,0643 ; 0,0880] | 0,1000 | **non** | dans | 73 | 0,0365 | [0,0287 ; 0,0457] | 0,0500 | **non** | dans | 0 |
| White | Heteroscedasticite (forme quadratique) | haut | 2000 | 176 | 0,0880 | [0,0759 ; 0,1013] | 0,1000 | oui | — | 80 | 0,0400 | [0,0318 ; 0,0495] | 0,0500 | **non** | dans | 0 |
| GQ | Egalite des variances petits vs gros volumes | deux | 2000 | 109 | 0,0545 | [0,0450 ; 0,0654] | 0,1000 | **non** | dans | 58 | 0,0290 | [0,0221 ; 0,0373] | 0,0500 | **non** | dans | 0 |
| BF | Homogeneite des dispersions (mediane) | haut | 2000 | 172 | 0,0860 | [0,0741 ; 0,0992] | 0,1000 | **non** | dans | 91 | 0,0455 | [0,0368 ; 0,0556] | 0,0500 | oui | — | 0 |
| Smirnov | Egalite des lois petits vs gros volumes (2 ech.) | haut | 2000 | 55 | 0,0275 | [0,0208 ; 0,0356] | 0,0286 † | oui | — | 55 | 0,0275 | [0,0208 ; 0,0356] | 0,0286 † | oui | — | 0 |
| LB2 | Ljung-Box (retard 2) | haut | 2000 | 213 | 0,1065 | [0,0933 ; 0,1209] | 0,1000 | oui | — | 106 | 0,0530 | [0,0436 ; 0,0637] | 0,0500 | oui | — | 0 |
| BP2 | Box-Pierce (retard 2) | haut | 2000 | 208 | 0,1040 | [0,0910 ; 0,1182] | 0,1000 | oui | — | 106 | 0,0530 | [0,0436 ; 0,0637] | 0,0500 | oui | — | 0 |
| Runs | Test des suites (aleatoire des signes) | deux | 2000 | 127 | 0,0635 | [0,0532 ; 0,0751] | 0,0571 † | oui | — | 15 | 0,0075 | [0,0042 ; 0,0123] | 0,0097 † | oui | — | 0 |
| MK | Tendance monotone du ratio S/P | deux | 2000 | 130 | 0,0650 | [0,0546 ; 0,0767] | 0,0711 † | oui | — | 58 | 0,0290 | [0,0221 ; 0,0373] | 0,0336 † | oui | — | 0 |
| SpearVol | Independance ratio S/P vs volume | deux | 2000 | 193 | 0,0965 | [0,0839 ; 0,1103] | 0,0904 † | oui | — | 101 | 0,0505 | [0,0413 ; 0,0610] | 0,0429 † | oui | — | 0 |
| SpearTps | Correlation ratio S/P vs temps | deux | 2000 | 177 | 0,0885 | [0,0764 ; 0,1018] | 0,0904 † | oui | — | 78 | 0,0390 | [0,0309 ; 0,0484] | 0,0429 † | oui | — | 0 |
| DAgo | Asymetrie (D'Agostino, T >= 8) | deux | 2000 | 163 | 0,0815 | [0,0699 ; 0,0944] | 0,1000 | **non** | dans | 80 | 0,0400 | [0,0318 ; 0,0495] | 0,0500 | **non** | dans | 0 |
| CoxStuart | Tendance par signes du ratio S/P | haut | 2000 | 0 | 0,0000 | [0,0000 ; 0,0018] | 0,0006 † | oui | non applicable (réf. < 2/n) | 0 | 0,0000 | [0,0000 ; 0,0018] | 0,0000 † | oui | non applicable (réf. < 2/n) | 0 |
| DWr | Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | deux | 2000 | 184 | 0,0920 | [0,0797 ; 0,1055] | 0,1000 | oui | — | 91 | 0,0455 | [0,0368 ; 0,0556] | 0,0500 | oui | — | 0 |
| LB1r | Ljung-Box (retard 1) sur ratios bruts | haut | 2000 | 207 | 0,1035 | [0,0905 ; 0,1177] | 0,1000 | oui | — | 105 | 0,0525 | [0,0431 ; 0,0632] | 0,0500 | oui | — | 0 |
| Runsr | Test des suites sur ratios bruts | deux | 2000 | 122 | 0,0610 | [0,0509 ; 0,0724] | 0,0571 † | oui | — | 21 | 0,0105 | [0,0065 ; 0,0160] | 0,0097 † | oui | — | 0 |
| supFr | Rupture de niveau (sup-F) sur ratios bruts | haut | 2000 | 202 | 0,1010 | [0,0881 ; 0,1150] | 0,1000 | oui | — | 98 | 0,0490 | [0,0400 ; 0,0594] | 0,0500 | oui | — | 0 |
| CUSUMr | Stabilite cumulee (OLS-CUSUM) sur ratios bruts | haut | 2000 | 199 | 0,0995 | [0,0867 ; 0,1135] | 0,1000 | oui | — | 101 | 0,0505 | [0,0413 ; 0,0610] | 0,0500 | oui | — | 0 |
| Grubbsr | Valeur aberrante isolee (Grubbs) sur ratios bruts | haut | 2000 | 169 | 0,0845 | [0,0727 ; 0,0976] | 0,1000 | **non** | dans | 78 | 0,0390 | [0,0309 ; 0,0484] | 0,0500 | **non** | dans | 0 |

n : réplications traitées (2000) où la p_mc est calculée ; p_mc absente : réplications traitées sans p_mc (motif en T3). Statistique continue : référence = seuil ; sous échangeabilité, P(p_mc < seuil) vaut en fait 0,099 et 0,049 en queue simple, 0,098 et 0,048 en bilatéral (B = 999), écart négligeable devant l'IC. † Loi de référence discrète : référence = taille lissée P(p_mc < seuil) sous la loi échangeable à T = 8 sans ex aequo et B = 999 (T0), qui tient compte du bruit Monte-Carlo de la p_mc autour des atomes de la loi.

Multiplicité : T1 compte 68 intervalles (34 statistiques × 2 seuils) ; ici 17 excluent la référence. Sur J1 et J2 réunis, 136 intervalles : environ 7 exclusions (5 % de 136) sont attendues par hasard même si toutes les références sont justes (intervalles corrélés entre eux ; ordre de grandeur, pas un test). T1 bis et T2 ajoutent leurs propres intervalles.

### T1 bis -- calibration de p_mc par régime de δ̂* du réajustement (références de T1)

| Statistique | Régime | n | < 0,10 : k | taux | IC 95 % | réf. dans l'IC | bande [réf/2 ; 3réf/2] | < 0,05 : k | taux | IC 95 % | réf. dans l'IC | bande [réf/2 ; 3réf/2] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AD | δ̂* = 1 (π̂* constant) | 722 | 61 | 0,0845 | [0,0652 ; 0,1072] | oui | — | 27 | 0,0374 | [0,0248 ; 0,0539] | oui | — |
| AD | δ̂* = 0 (π̂* variable) | 814 | 91 | 0,1118 | [0,0910 ; 0,1355] | oui | — | 45 | 0,0553 | [0,0406 ; 0,0733] | oui | — |
| AD | δ̂* intérieur (π̂* variable) | 464 | 52 | 0,1121 | [0,0848 ; 0,1444] | oui | — | 18 | 0,0388 | [0,0232 ; 0,0606] | oui | — |
| CvM | δ̂* = 1 (π̂* constant) | 722 | 60 | 0,0831 | [0,0640 ; 0,1057] | oui | — | 26 | 0,0360 | [0,0237 ; 0,0523] | oui | — |
| CvM | δ̂* = 0 (π̂* variable) | 814 | 77 | 0,0946 | [0,0754 ; 0,1168] | oui | — | 44 | 0,0541 | [0,0395 ; 0,0719] | oui | — |
| CvM | δ̂* intérieur (π̂* variable) | 464 | 57 | 0,1228 | [0,0944 ; 0,1562] | oui | — | 23 | 0,0496 | [0,0317 ; 0,0735] | oui | — |
| KS | δ̂* = 1 (π̂* constant) | 722 | 55 | 0,0762 | [0,0579 ; 0,0980] | **non** | dans | 29 | 0,0402 | [0,0271 ; 0,0572] | oui | — |
| KS | δ̂* = 0 (π̂* variable) | 814 | 77 | 0,0946 | [0,0754 ; 0,1168] | oui | — | 34 | 0,0418 | [0,0291 ; 0,0579] | oui | — |
| KS | δ̂* intérieur (π̂* variable) | 464 | 48 | 0,1034 | [0,0773 ; 0,1348] | oui | — | 29 | 0,0625 | [0,0423 ; 0,0885] | oui | — |
| SW | δ̂* = 1 (π̂* constant) | 722 | 62 | 0,0859 | [0,0665 ; 0,1087] | oui | — | 27 | 0,0374 | [0,0248 ; 0,0539] | oui | — |
| SW | δ̂* = 0 (π̂* variable) | 814 | 84 | 0,1032 | [0,0831 ; 0,1262] | oui | — | 43 | 0,0528 | [0,0385 ; 0,0705] | oui | — |
| SW | δ̂* intérieur (π̂* variable) | 464 | 43 | 0,0927 | [0,0679 ; 0,1228] | oui | — | 19 | 0,0409 | [0,0248 ; 0,0632] | oui | — |
| SF | δ̂* = 1 (π̂* constant) | 722 | 59 | 0,0817 | [0,0628 ; 0,1041] | oui | — | 34 | 0,0471 | [0,0328 ; 0,0652] | oui | — |
| SF | δ̂* = 0 (π̂* variable) | 814 | 86 | 0,1057 | [0,0854 ; 0,1288] | oui | — | 45 | 0,0553 | [0,0406 ; 0,0733] | oui | — |
| SF | δ̂* intérieur (π̂* variable) | 464 | 25 | 0,0539 | [0,0352 ; 0,0785] | **non** | dans | 13 | 0,0280 | [0,0150 ; 0,0474] | **non** | dans |
| JB | δ̂* = 1 (π̂* constant) | 722 | 68 | 0,0942 | [0,0739 ; 0,1179] | oui | — | 36 | 0,0499 | [0,0352 ; 0,0684] | oui | — |
| JB | δ̂* = 0 (π̂* variable) | 814 | 89 | 0,1093 | [0,0887 ; 0,1328] | oui | — | 41 | 0,0504 | [0,0364 ; 0,0677] | oui | — |
| JB | δ̂* intérieur (π̂* variable) | 464 | 13 | 0,0280 | [0,0150 ; 0,0474] | **non** | IC entièrement hors | 4 | 0,0086 | [0,0024 ; 0,0219] | **non** | IC entièrement hors |
| DW | δ̂* = 1 (π̂* constant) | 722 | 88 | 0,1219 | [0,0989 ; 0,1480] | oui | — | 45 | 0,0623 | [0,0458 ; 0,0825] | oui | — |
| DW | δ̂* = 0 (π̂* variable) | 814 | 87 | 0,1069 | [0,0865 ; 0,1302] | oui | — | 37 | 0,0455 | [0,0322 ; 0,0621] | oui | — |
| DW | δ̂* intérieur (π̂* variable) | 464 | 30 | 0,0647 | [0,0440 ; 0,0910] | **non** | dans | 14 | 0,0302 | [0,0166 ; 0,0501] | oui | — |
| LB1 | δ̂* = 1 (π̂* constant) | 722 | 97 | 0,1343 | [0,1103 ; 0,1614] | **non** | dans | 49 | 0,0679 | [0,0506 ; 0,0887] | **non** | dans |
| LB1 | δ̂* = 0 (π̂* variable) | 814 | 79 | 0,0971 | [0,0776 ; 0,1195] | oui | — | 32 | 0,0393 | [0,0270 ; 0,0550] | oui | — |
| LB1 | δ̂* intérieur (π̂* variable) | 464 | 42 | 0,0905 | [0,0660 ; 0,1204] | oui | — | 25 | 0,0539 | [0,0352 ; 0,0785] | oui | — |
| supF | δ̂* = 1 (π̂* constant) | 722 | 65 | 0,0900 | [0,0702 ; 0,1133] | oui | — | 36 | 0,0499 | [0,0352 ; 0,0684] | oui | — |
| supF | δ̂* = 0 (π̂* variable) | 814 | 92 | 0,1130 | [0,0921 ; 0,1368] | oui | — | 50 | 0,0614 | [0,0459 ; 0,0802] | oui | — |
| supF | δ̂* intérieur (π̂* variable) | 464 | 30 | 0,0647 | [0,0440 ; 0,0910] | **non** | dans | 17 | 0,0366 | [0,0215 ; 0,0580] | oui | — |
| CUSUM | δ̂* = 1 (π̂* constant) | 722 | 74 | 0,1025 | [0,0813 ; 0,1270] | oui | — | 37 | 0,0512 | [0,0363 ; 0,0699] | oui | — |
| CUSUM | δ̂* = 0 (π̂* variable) | 814 | 87 | 0,1069 | [0,0865 ; 0,1302] | oui | — | 40 | 0,0491 | [0,0353 ; 0,0663] | oui | — |
| CUSUM | δ̂* intérieur (π̂* variable) | 464 | 37 | 0,0797 | [0,0568 ; 0,1082] | oui | — | 19 | 0,0409 | [0,0248 ; 0,0632] | oui | — |
| Grubbs | δ̂* = 1 (π̂* constant) | 722 | 70 | 0,0970 | [0,0764 ; 0,1209] | oui | — | 36 | 0,0499 | [0,0352 ; 0,0684] | oui | — |
| Grubbs | δ̂* = 0 (π̂* variable) | 814 | 87 | 0,1069 | [0,0865 ; 0,1302] | oui | — | 44 | 0,0541 | [0,0395 ; 0,0719] | oui | — |
| Grubbs | δ̂* intérieur (π̂* variable) | 464 | 10 | 0,0216 | [0,0104 ; 0,0393] | **non** | IC entièrement hors | 3 | 0,0065 | [0,0013 ; 0,0188] | **non** | IC entièrement hors |
| Lillie | δ̂* = 1 (π̂* constant) | 722 | 62 | 0,0859 | [0,0665 ; 0,1087] | oui | — | 32 | 0,0443 | [0,0305 ; 0,0620] | oui | — |
| Lillie | δ̂* = 0 (π̂* variable) | 814 | 83 | 0,1020 | [0,0820 ; 0,1248] | oui | — | 48 | 0,0590 | [0,0438 ; 0,0774] | oui | — |
| Lillie | δ̂* intérieur (π̂* variable) | 464 | 31 | 0,0668 | [0,0458 ; 0,0935] | **non** | dans | 16 | 0,0345 | [0,0198 ; 0,0554] | oui | — |
| Intercept | δ̂* = 1 (π̂* constant) | 722 | 83 | 0,1150 | [0,0926 ; 0,1405] | oui | — | 55 | 0,0762 | [0,0579 ; 0,0980] | **non** | estimation hors |
| Intercept | δ̂* = 0 (π̂* variable) | 814 | 62 | 0,0762 | [0,0589 ; 0,0966] | **non** | dans | 34 | 0,0418 | [0,0291 ; 0,0579] | oui | — |
| Intercept | δ̂* intérieur (π̂* variable) | 464 | 55 | 0,1185 | [0,0906 ; 0,1515] | oui | — | 30 | 0,0647 | [0,0440 ; 0,0910] | oui | — |
| RESET | δ̂* = 1 (π̂* constant) | 722 | 90 | 0,1247 | [0,1014 ; 0,1510] | **non** | dans | 43 | 0,0596 | [0,0434 ; 0,0794] | oui | — |
| RESET | δ̂* = 0 (π̂* variable) | 814 | 23 | 0,0283 | [0,0180 ; 0,0421] | **non** | IC entièrement hors | 9 | 0,0111 | [0,0051 ; 0,0209] | **non** | IC entièrement hors |
| RESET | δ̂* intérieur (π̂* variable) | 464 | 53 | 0,1142 | [0,0867 ; 0,1467] | oui | — | 13 | 0,0280 | [0,0150 ; 0,0474] | **non** | dans |
| BP | δ̂* = 1 (π̂* constant) | 722 | 87 | 0,1205 | [0,0976 ; 0,1465] | oui | — | 37 | 0,0512 | [0,0363 ; 0,0699] | oui | — |
| BP | δ̂* = 0 (π̂* variable) | 814 | 83 | 0,1020 | [0,0820 ; 0,1248] | oui | — | 37 | 0,0455 | [0,0322 ; 0,0621] | oui | — |
| BP | δ̂* intérieur (π̂* variable) | 464 | 0 | 0,0000 | [0,0000 ; 0,0079] | **non** | IC entièrement hors | 0 | 0,0000 | [0,0000 ; 0,0079] | **non** | IC entièrement hors |
| BP79 | δ̂* = 1 (π̂* constant) | 722 | 83 | 0,1150 | [0,0926 ; 0,1405] | oui | — | 44 | 0,0609 | [0,0446 ; 0,0810] | oui | — |
| BP79 | δ̂* = 0 (π̂* variable) | 814 | 68 | 0,0835 | [0,0655 ; 0,1047] | oui | — | 29 | 0,0356 | [0,0240 ; 0,0508] | oui | — |
| BP79 | δ̂* intérieur (π̂* variable) | 464 | 0 | 0,0000 | [0,0000 ; 0,0079] | **non** | IC entièrement hors | 0 | 0,0000 | [0,0000 ; 0,0079] | **non** | IC entièrement hors |
| White | δ̂* = 1 (π̂* constant) | 722 | 85 | 0,1177 | [0,0951 ; 0,1435] | oui | — | 46 | 0,0637 | [0,0470 ; 0,0841] | oui | — |
| White | δ̂* = 0 (π̂* variable) | 814 | 42 | 0,0516 | [0,0374 ; 0,0691] | **non** | dans | 16 | 0,0197 | [0,0113 ; 0,0317] | **non** | estimation hors |
| White | δ̂* intérieur (π̂* variable) | 464 | 49 | 0,1056 | [0,0792 ; 0,1372] | oui | — | 18 | 0,0388 | [0,0232 ; 0,0606] | oui | — |
| GQ | δ̂* = 1 (π̂* constant) | 722 | 52 | 0,0720 | [0,0543 ; 0,0934] | **non** | dans | 29 | 0,0402 | [0,0271 ; 0,0572] | oui | — |
| GQ | δ̂* = 0 (π̂* variable) | 814 | 56 | 0,0688 | [0,0524 ; 0,0884] | **non** | dans | 29 | 0,0356 | [0,0240 ; 0,0508] | oui | — |
| GQ | δ̂* intérieur (π̂* variable) | 464 | 1 | 0,0022 | [0,0001 ; 0,0119] | **non** | IC entièrement hors | 0 | 0,0000 | [0,0000 ; 0,0079] | **non** | IC entièrement hors |
| BF | δ̂* = 1 (π̂* constant) | 722 | 79 | 0,1094 | [0,0876 ; 0,1345] | oui | — | 38 | 0,0526 | [0,0375 ; 0,0715] | oui | — |
| BF | δ̂* = 0 (π̂* variable) | 814 | 85 | 0,1044 | [0,0843 ; 0,1275] | oui | — | 48 | 0,0590 | [0,0438 ; 0,0774] | oui | — |
| BF | δ̂* intérieur (π̂* variable) | 464 | 8 | 0,0172 | [0,0075 ; 0,0337] | **non** | IC entièrement hors | 5 | 0,0108 | [0,0035 ; 0,0250] | **non** | IC entièrement hors |
| Smirnov | δ̂* = 1 (π̂* constant) | 722 | 18 | 0,0249 | [0,0148 ; 0,0391] | oui | — | 18 | 0,0249 | [0,0148 ; 0,0391] | oui | — |
| Smirnov | δ̂* = 0 (π̂* variable) | 814 | 31 | 0,0381 | [0,0260 ; 0,0536] | oui | — | 31 | 0,0381 | [0,0260 ; 0,0536] | oui | — |
| Smirnov | δ̂* intérieur (π̂* variable) | 464 | 6 | 0,0129 | [0,0048 ; 0,0279] | **non** | estimation hors | 6 | 0,0129 | [0,0048 ; 0,0279] | **non** | estimation hors |
| LB2 | δ̂* = 1 (π̂* constant) | 722 | 90 | 0,1247 | [0,1014 ; 0,1510] | **non** | dans | 47 | 0,0651 | [0,0482 ; 0,0856] | oui | — |
| LB2 | δ̂* = 0 (π̂* variable) | 814 | 66 | 0,0811 | [0,0633 ; 0,1020] | oui | — | 28 | 0,0344 | [0,0230 ; 0,0493] | **non** | dans |
| LB2 | δ̂* intérieur (π̂* variable) | 464 | 57 | 0,1228 | [0,0944 ; 0,1562] | oui | — | 31 | 0,0668 | [0,0458 ; 0,0935] | oui | — |
| BP2 | δ̂* = 1 (π̂* constant) | 722 | 88 | 0,1219 | [0,0989 ; 0,1480] | oui | — | 47 | 0,0651 | [0,0482 ; 0,0856] | oui | — |
| BP2 | δ̂* = 0 (π̂* variable) | 814 | 65 | 0,0799 | [0,0622 ; 0,1006] | oui | — | 30 | 0,0369 | [0,0250 ; 0,0522] | oui | — |
| BP2 | δ̂* intérieur (π̂* variable) | 464 | 55 | 0,1185 | [0,0906 ; 0,1515] | oui | — | 29 | 0,0625 | [0,0423 ; 0,0885] | oui | — |
| Runs | δ̂* = 1 (π̂* constant) | 722 | 43 | 0,0596 | [0,0434 ; 0,0794] | oui | — | 4 | 0,0055 | [0,0015 ; 0,0141] | oui | — |
| Runs | δ̂* = 0 (π̂* variable) | 814 | 57 | 0,0700 | [0,0535 ; 0,0898] | oui | — | 7 | 0,0086 | [0,0035 ; 0,0176] | oui | — |
| Runs | δ̂* intérieur (π̂* variable) | 464 | 27 | 0,0582 | [0,0387 ; 0,0835] | oui | — | 4 | 0,0086 | [0,0024 ; 0,0219] | oui | — |
| MK | δ̂* = 1 (π̂* constant) | 722 | 22 | 0,0305 | [0,0192 ; 0,0458] | **non** | estimation hors | 4 | 0,0055 | [0,0015 ; 0,0141] | **non** | IC entièrement hors |
| MK | δ̂* = 0 (π̂* variable) | 814 | 78 | 0,0958 | [0,0765 ; 0,1181] | **non** | dans | 42 | 0,0516 | [0,0374 ; 0,0691] | **non** | estimation hors |
| MK | δ̂* intérieur (π̂* variable) | 464 | 30 | 0,0647 | [0,0440 ; 0,0910] | oui | — | 12 | 0,0259 | [0,0134 ; 0,0447] | oui | — |
| SpearVol | δ̂* = 1 (π̂* constant) | 722 | 67 | 0,0928 | [0,0726 ; 0,1164] | oui | — | 36 | 0,0499 | [0,0352 ; 0,0684] | oui | — |
| SpearVol | δ̂* = 0 (π̂* variable) | 814 | 77 | 0,0946 | [0,0754 ; 0,1168] | oui | — | 36 | 0,0442 | [0,0312 ; 0,0607] | oui | — |
| SpearVol | δ̂* intérieur (π̂* variable) | 464 | 49 | 0,1056 | [0,0792 ; 0,1372] | oui | — | 29 | 0,0625 | [0,0423 ; 0,0885] | oui | — |
| SpearTps | δ̂* = 1 (π̂* constant) | 722 | 44 | 0,0609 | [0,0446 ; 0,0810] | **non** | dans | 16 | 0,0222 | [0,0127 ; 0,0357] | **non** | dans |
| SpearTps | δ̂* = 0 (π̂* variable) | 814 | 95 | 0,1167 | [0,0955 ; 0,1408] | **non** | dans | 51 | 0,0627 | [0,0470 ; 0,0816] | **non** | dans |
| SpearTps | δ̂* intérieur (π̂* variable) | 464 | 38 | 0,0819 | [0,0586 ; 0,1107] | oui | — | 11 | 0,0237 | [0,0119 ; 0,0420] | **non** | dans |
| DAgo | δ̂* = 1 (π̂* constant) | 722 | 67 | 0,0928 | [0,0726 ; 0,1164] | oui | — | 36 | 0,0499 | [0,0352 ; 0,0684] | oui | — |
| DAgo | δ̂* = 0 (π̂* variable) | 814 | 87 | 0,1069 | [0,0865 ; 0,1302] | oui | — | 42 | 0,0516 | [0,0374 ; 0,0691] | oui | — |
| DAgo | δ̂* intérieur (π̂* variable) | 464 | 9 | 0,0194 | [0,0089 ; 0,0365] | **non** | IC entièrement hors | 2 | 0,0043 | [0,0005 ; 0,0155] | **non** | IC entièrement hors |
| CoxStuart | δ̂* = 1 (π̂* constant) | 722 | 0 | 0,0000 | [0,0000 ; 0,0051] | oui | non applicable (réf. < 2/n) | 0 | 0,0000 | [0,0000 ; 0,0051] | oui | non applicable (réf. < 2/n) |
| CoxStuart | δ̂* = 0 (π̂* variable) | 814 | 0 | 0,0000 | [0,0000 ; 0,0045] | oui | non applicable (réf. < 2/n) | 0 | 0,0000 | [0,0000 ; 0,0045] | oui | non applicable (réf. < 2/n) |
| CoxStuart | δ̂* intérieur (π̂* variable) | 464 | 0 | 0,0000 | [0,0000 ; 0,0079] | oui | non applicable (réf. < 2/n) | 0 | 0,0000 | [0,0000 ; 0,0079] | oui | non applicable (réf. < 2/n) |
| DWr | δ̂* = 1 (π̂* constant) | 722 | 83 | 0,1150 | [0,0926 ; 0,1405] | oui | — | 41 | 0,0568 | [0,0411 ; 0,0763] | oui | — |
| DWr | δ̂* = 0 (π̂* variable) | 814 | 75 | 0,0921 | [0,0732 ; 0,1141] | oui | — | 39 | 0,0479 | [0,0343 ; 0,0649] | oui | — |
| DWr | δ̂* intérieur (π̂* variable) | 464 | 26 | 0,0560 | [0,0369 ; 0,0810] | **non** | dans | 11 | 0,0237 | [0,0119 ; 0,0420] | **non** | estimation hors |
| LB1r | δ̂* = 1 (π̂* constant) | 722 | 102 | 0,1413 | [0,1167 ; 0,1688] | **non** | dans | 52 | 0,0720 | [0,0543 ; 0,0934] | **non** | dans |
| LB1r | δ̂* = 0 (π̂* variable) | 814 | 69 | 0,0848 | [0,0666 ; 0,1061] | oui | — | 32 | 0,0393 | [0,0270 ; 0,0550] | oui | — |
| LB1r | δ̂* intérieur (π̂* variable) | 464 | 36 | 0,0776 | [0,0549 ; 0,1058] | oui | — | 21 | 0,0453 | [0,0282 ; 0,0684] | oui | — |
| Runsr | δ̂* = 1 (π̂* constant) | 722 | 43 | 0,0596 | [0,0434 ; 0,0794] | oui | — | 5 | 0,0069 | [0,0023 ; 0,0161] | oui | — |
| Runsr | δ̂* = 0 (π̂* variable) | 814 | 51 | 0,0627 | [0,0470 ; 0,0816] | oui | — | 11 | 0,0135 | [0,0068 ; 0,0241] | oui | — |
| Runsr | δ̂* intérieur (π̂* variable) | 464 | 28 | 0,0603 | [0,0405 ; 0,0860] | oui | — | 5 | 0,0108 | [0,0035 ; 0,0250] | oui | — |
| supFr | δ̂* = 1 (π̂* constant) | 722 | 60 | 0,0831 | [0,0640 ; 0,1057] | oui | — | 31 | 0,0429 | [0,0294 ; 0,0604] | oui | — |
| supFr | δ̂* = 0 (π̂* variable) | 814 | 107 | 0,1314 | [0,1090 ; 0,1566] | **non** | dans | 53 | 0,0651 | [0,0491 ; 0,0843] | oui | — |
| supFr | δ̂* intérieur (π̂* variable) | 464 | 35 | 0,0754 | [0,0531 ; 0,1033] | oui | — | 14 | 0,0302 | [0,0166 ; 0,0501] | oui | — |
| CUSUMr | δ̂* = 1 (π̂* constant) | 722 | 72 | 0,0997 | [0,0788 ; 0,1239] | oui | — | 37 | 0,0512 | [0,0363 ; 0,0699] | oui | — |
| CUSUMr | δ̂* = 0 (π̂* variable) | 814 | 85 | 0,1044 | [0,0843 ; 0,1275] | oui | — | 43 | 0,0528 | [0,0385 ; 0,0705] | oui | — |
| CUSUMr | δ̂* intérieur (π̂* variable) | 464 | 42 | 0,0905 | [0,0660 ; 0,1204] | oui | — | 21 | 0,0453 | [0,0282 ; 0,0684] | oui | — |
| Grubbsr | δ̂* = 1 (π̂* constant) | 722 | 64 | 0,0886 | [0,0689 ; 0,1118] | oui | — | 25 | 0,0346 | [0,0225 ; 0,0507] | oui | — |
| Grubbsr | δ̂* = 0 (π̂* variable) | 814 | 90 | 0,1106 | [0,0898 ; 0,1341] | oui | — | 50 | 0,0614 | [0,0459 ; 0,0802] | oui | — |
| Grubbsr | δ̂* intérieur (π̂* variable) | 464 | 15 | 0,0323 | [0,0182 ; 0,0528] | **non** | estimation hors | 3 | 0,0065 | [0,0013 ; 0,0188] | **non** | IC entièrement hors |

Régime du réajustement de run_engine() sur le jeu simulé (seuils TOL_DELTA_BORD de #72) ; effectifs en T3. Volumes non constants (contrôlé) : π̂* constant si et seulement si δ̂* au bord 1. Règle R7 : à π̂* constant, les lignes à loi exacte retiennent la p exacte ; ailleurs, la p_mc. Les taux par régime sont conditionnels à un événement fonction des données et n'ont pas de référence exacte même pour une p_mc parfaitement calibrée : T1 bis localise un écart, il ne teste pas la calibration par régime.

### T2 -- niveau des verdicts des 51 lignes : fréquence de p retenue < α et < α/2 parmi les p retenues (règles R1, R3, R4, R7, R13 comprises)

| Ligne | n | p retenue | < 0,10 : k | taux | IC 95 % | réf. | réf. dans l'IC | bande [réf/2 ; 3réf/2] | < 0,05 : k | taux | IC 95 % | réf. | réf. dans l'IC | bande [réf/2 ; 3réf/2] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Nullite de la constante (proportionnalite stricte) | 2000 | 2000 | 200 | 0,1000 | [0,0872 ; 0,1140] | 0,1000 | oui | — | 119 | 0,0595 | [0,0495 ; 0,0708] | 0,0500 | oui | — |
| Equivalence de la constante a zero (TOST) | 2000 | 2000 | 432 | 0,2160 | [0,1981 ; 0,2347] | sans objet (H0 \|a\| ≥ Δ fausse sous le modèle ajusté, a = 0 ; sens « rejeter ») | — | — | 199 | 0,0995 | [0,0867 ; 0,1135] | sans objet (H0 \|a\| ≥ Δ fausse sous le modèle ajusté, a = 0 ; sens « rejeter ») | — | — |
| Test de Student sur la pente (lm(y~x)) | 2000 | 2000 | 2000 | 1,0000 | [0,9982 ; 1,0000] | sans objet (H0 β = 0 fausse ; sens « rejeter ») | — | — | 2000 | 1,0000 | [0,9982 ; 1,0000] | sans objet (H0 β = 0 fausse ; sens « rejeter ») | — | — |
| Test de Fisher (significativite globale) | 2000 | 2000 | 2000 | 1,0000 | [0,9982 ; 1,0000] | sans objet (H0 β = 0 fausse ; sens « rejeter ») | — | — | 2000 | 1,0000 | [0,9982 ; 1,0000] | sans objet (H0 β = 0 fausse ; sens « rejeter ») | — | — |
| Coefficient de determination R2 | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| RESET (forme fonctionnelle) | 2000 | 2000 | 166 | 0,0830 | [0,0713 ; 0,0960] | 0,1000 | **non** | dans | 65 | 0,0325 | [0,0252 ; 0,0412] | 0,0500 | **non** | dans |
| Independance ratio S/P vs volume | 2000 | 2000 | 200 | 0,1000 | [0,0872 ; 0,1140] | 0,0925 † | oui | — | 99 | 0,0495 | [0,0404 ; 0,0599] | 0,0440 † | oui | — |
| Correlation ratio S/P vs temps | 2000 | 2000 | 179 | 0,0895 | [0,0773 ; 0,1029] | 0,0925 † | oui | — | 78 | 0,0390 | [0,0309 ; 0,0484] | 0,0440 † | oui | — |
| Tendance monotone du ratio S/P | 2000 | 2000 | 124 | 0,0620 | [0,0518 ; 0,0735] | 0,0674 † | oui | — | 58 | 0,0290 | [0,0221 ; 0,0373] | 0,0327 † | oui | — |
| Tendance par signes du ratio S/P | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | 2000 | 2000 | 170 | 0,0850 | [0,0731 ; 0,0981] | 0,1000 | **non** | dans | 74 | 0,0370 | [0,0292 ; 0,0462] | 0,0500 | **non** | dans |
| Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | 2000 | 2000 | 151 | 0,0755 | [0,0643 ; 0,0880] | 0,1000 | **non** | dans | 73 | 0,0365 | [0,0287 ; 0,0457] | 0,0500 | **non** | dans |
| Heteroscedasticite (forme quadratique) | 2000 | 2000 | 176 | 0,0880 | [0,0759 ; 0,1013] | 0,1000 | oui | — | 80 | 0,0400 | [0,0318 ; 0,0495] | 0,0500 | **non** | dans |
| Egalite des variances petits vs gros volumes | 2000 | 2000 | 109 | 0,0545 | [0,0450 ; 0,0654] | 0,1000 | **non** | dans | 58 | 0,0290 | [0,0221 ; 0,0373] | 0,0500 | **non** | dans |
| Homogeneite des dispersions (mediane) | 2000 | 2000 | 172 | 0,0860 | [0,0741 ; 0,0992] | 0,1000 | **non** | dans | 91 | 0,0455 | [0,0368 ; 0,0556] | 0,0500 | oui | — |
| Egalite des lois petits vs gros volumes (2 ech.) | 2000 | 2000 | 55 | 0,0275 | [0,0208 ; 0,0356] | 0,0286 † | oui | — | 55 | 0,0275 | [0,0208 ; 0,0356] | 0,0286 † | oui | — |
| Position de delta dans [0,1] | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Shapiro-Wilk sur residus standardises | 2000 | 2000 | 189 | 0,0945 | [0,0820 ; 0,1082] | 0,1000 | oui | — | 89 | 0,0445 | [0,0359 ; 0,0545] | 0,0500 | oui | — |
| Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston) | 2000 | 722 | 66 | 0,0914 | [0,0714 ; 0,1148] | 0,1000 | oui | — | 30 | 0,0416 | [0,0282 ; 0,0588] | 0,0500 | oui | — |
| Shapiro-Francia | 2000 | 2000 | 170 | 0,0850 | [0,0731 ; 0,0981] | 0,1000 | **non** | dans | 92 | 0,0460 | [0,0372 ; 0,0561] | 0,0500 | oui | — |
| Anderson-Darling | 2000 | 2000 | 204 | 0,1020 | [0,0891 ; 0,1161] | 0,1000 | oui | — | 90 | 0,0450 | [0,0363 ; 0,0550] | 0,0500 | oui | — |
| Cramer-von Mises | 2000 | 2000 | 194 | 0,0970 | [0,0844 ; 0,1108] | 0,1000 | oui | — | 93 | 0,0465 | [0,0377 ; 0,0567] | 0,0500 | oui | — |
| Kolmogorov-Smirnov contre N(0,1) | 2000 | 2000 | 180 | 0,0900 | [0,0778 ; 0,1034] | 0,1000 | oui | — | 92 | 0,0460 | [0,0372 ; 0,0561] | 0,0500 | oui | — |
| Lilliefors (KS a parametres estimes) | 2000 | 2000 | 176 | 0,0880 | [0,0759 ; 0,1013] | 0,1000 | oui | — | 96 | 0,0480 | [0,0391 ; 0,0583] | 0,0500 | oui | — |
| Jarque-Bera | 2000 | 2000 | 170 | 0,0850 | [0,0731 ; 0,0981] | 0,1000 | **non** | dans | 81 | 0,0405 | [0,0323 ; 0,0501] | 0,0500 | oui | — |
| Asymetrie (D'Agostino, T >= 8) | 2000 | 2000 | 163 | 0,0815 | [0,0699 ; 0,0944] | 0,1000 | **non** | dans | 80 | 0,0400 | [0,0318 ; 0,0495] | 0,0500 | **non** | dans |
| Aplatissement (Anscombe-Glynn, T >= 20) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Autocorrelation d'ordre 1 (Durbin-Watson) | 2000 | 2000 | 211 | 0,1055 | [0,0924 ; 0,1198] | 0,1000 | oui | — | 98 | 0,0490 | [0,0400 ; 0,0594] | 0,0500 | oui | — |
| Ljung-Box (retard 1) | 2000 | 2000 | 218 | 0,1090 | [0,0957 ; 0,1235] | 0,1000 | oui | — | 106 | 0,0530 | [0,0436 ; 0,0637] | 0,0500 | oui | — |
| Ljung-Box (retard 2) | 2000 | 2000 | 213 | 0,1065 | [0,0933 ; 0,1209] | 0,1000 | oui | — | 106 | 0,0530 | [0,0436 ; 0,0637] | 0,0500 | oui | — |
| Box-Pierce (retard 2) | 2000 | 2000 | 208 | 0,1040 | [0,0910 ; 0,1182] | 0,1000 | oui | — | 106 | 0,0530 | [0,0436 ; 0,0637] | 0,0500 | oui | — |
| Test des suites (aleatoire des signes) | 2000 | 2000 | 127 | 0,0635 | [0,0532 ; 0,0751] | 0,0571 † | oui | — | 11 | 0,0055 | [0,0027 ; 0,0098] | 0,0062 † | oui | — |
| Centrage des residus standardises | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Variance unitaire des residus standardises | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Rupture de niveau (sup-F) | 2000 | 2000 | 187 | 0,0935 | [0,0811 ; 0,1071] | 0,1000 | oui | — | 103 | 0,0515 | [0,0422 ; 0,0621] | 0,0500 | oui | — |
| Stabilite cumulee (OLS-CUSUM) | 2000 | 2000 | 198 | 0,0990 | [0,0863 ; 0,1129] | 0,1000 | oui | — | 96 | 0,0480 | [0,0391 ; 0,0583] | 0,0500 | oui | — |
| Valeur aberrante isolee (Grubbs) | 2000 | 2000 | 167 | 0,0835 | [0,0717 ; 0,0965] | 0,1000 | **non** | dans | 83 | 0,0415 | [0,0332 ; 0,0512] | 0,0500 | oui | — |
| Valeurs aberrantes multiples (ESD generalise) | 2000 | — (procédure sans p-value) | 222 | 0,1110 | [0,0976 ; 0,1256] | 0,1000 ‡ | oui | — | 99 | 0,0495 | [0,0404 ; 0,0599] | — | — | — |
| Points influents (distance de Cook) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | 2000 | 2000 | 184 | 0,0920 | [0,0797 ; 0,1055] | 0,1000 | oui | — | 91 | 0,0455 | [0,0368 ; 0,0556] | 0,0500 | oui | — |
| Ljung-Box (retard 1) sur ratios bruts | 2000 | 2000 | 207 | 0,1035 | [0,0905 ; 0,1177] | 0,1000 | oui | — | 105 | 0,0525 | [0,0431 ; 0,0632] | 0,0500 | oui | — |
| Test des suites sur ratios bruts | 2000 | 2000 | 122 | 0,0610 | [0,0509 ; 0,0724] | 0,0571 † | oui | — | 16 | 0,0080 | [0,0046 ; 0,0130] | 0,0062 † | oui | — |
| Rupture de niveau (sup-F) sur ratios bruts | 2000 | 2000 | 202 | 0,1010 | [0,0881 ; 0,1150] | 0,1000 | oui | — | 98 | 0,0490 | [0,0400 ; 0,0594] | 0,0500 | oui | — |
| Stabilite cumulee (OLS-CUSUM) sur ratios bruts | 2000 | 2000 | 199 | 0,0995 | [0,0867 ; 0,1135] | 0,1000 | oui | — | 101 | 0,0505 | [0,0413 ; 0,0610] | 0,0500 | oui | — |
| Valeur aberrante isolee (Grubbs) sur ratios bruts | 2000 | 2000 | 169 | 0,0845 | [0,0727 ; 0,0976] | 0,1000 | **non** | dans | 78 | 0,0390 | [0,0309 ; 0,0484] | 0,0500 | **non** | dans |
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
| Nullite de la constante (proportionnalite stricte) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1800 | 81 | 119 | 0 |
| Equivalence de la constante a zero (TOST) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 432 | 776 | 792 | 0 |
| Test de Student sur la pente (lm(y~x)) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 2000 | 0 | 0 | 0 |
| Test de Fisher (significativite globale) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 2000 | 0 | 0 | 0 |
| Coefficient de determination R2 | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| RESET (forme fonctionnelle) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1834 | 101 | 65 | 0 |
| Independance ratio S/P vs volume | 2000 | 2000 | 0 | 0 | 0 | 0 | 722 | 1278 | 0 | 0 | 0 | 1800 | 101 | 99 | 0 |
| Correlation ratio S/P vs temps | 2000 | 2000 | 0 | 0 | 0 | 0 | 722 | 1278 | 0 | 0 | 0 | 1821 | 101 | 78 | 0 |
| Tendance monotone du ratio S/P | 2000 | 2000 | 0 | 0 | 0 | 0 | 722 | 1278 | 0 | 0 | 0 | 1876 | 66 | 58 | 0 |
| Tendance par signes du ratio S/P | 2000 | 0 | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1830 | 96 | 74 | 0 |
| Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1849 | 78 | 73 | 0 |
| Heteroscedasticite (forme quadratique) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1824 | 96 | 80 | 0 |
| Egalite des variances petits vs gros volumes | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1891 | 51 | 58 | 0 |
| Homogeneite des dispersions (mediane) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1828 | 81 | 91 | 0 |
| Egalite des lois petits vs gros volumes (2 ech.) | 2000 | 2000 | 0 | 0 | 0 | 0 | 722 | 1278 | 0 | 0 | 0 | 1945 | 0 | 55 | 0 |
| Position de delta dans [0,1] | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Shapiro-Wilk sur residus standardises | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1811 | 100 | 89 | 0 |
| Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston) | 2000 | 722 | 0 | 0 | 1278 | 0 | 722 | 0 | 0 | 0 | 1278 | 656 | 36 | 30 | 1278 |
| Shapiro-Francia | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1830 | 78 | 92 | 0 |
| Anderson-Darling | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1796 | 114 | 90 | 0 |
| Cramer-von Mises | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1806 | 101 | 93 | 0 |
| Kolmogorov-Smirnov contre N(0,1) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1820 | 88 | 92 | 0 |
| Lilliefors (KS a parametres estimes) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1824 | 80 | 96 | 0 |
| Jarque-Bera | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1830 | 89 | 81 | 0 |
| Asymetrie (D'Agostino, T >= 8) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1837 | 83 | 80 | 0 |
| Aplatissement (Anscombe-Glynn, T >= 20) | 2000 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Autocorrelation d'ordre 1 (Durbin-Watson) | 2000 | 2000 | 0 | 0 | 0 | 0 | 722 | 1278 | 0 | 0 | 0 | 1789 | 113 | 98 | 0 |
| Ljung-Box (retard 1) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1782 | 112 | 106 | 0 |
| Ljung-Box (retard 2) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1787 | 107 | 106 | 0 |
| Box-Pierce (retard 2) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1792 | 102 | 106 | 0 |
| Test des suites (aleatoire des signes) | 2000 | 2000 | 0 | 0 | 0 | 0 | 722 | 1278 | 0 | 0 | 0 | 1873 | 116 | 11 | 0 |
| Centrage des residus standardises | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Variance unitaire des residus standardises | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Rupture de niveau (sup-F) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1813 | 84 | 103 | 0 |
| Stabilite cumulee (OLS-CUSUM) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1802 | 102 | 96 | 0 |
| Valeur aberrante isolee (Grubbs) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1833 | 84 | 83 | 0 |
| Valeurs aberrantes multiples (ESD generalise) | 2000 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 0 | 2000 | 1778 | 123 | 99 | 0 |
| Points influents (distance de Cook) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1816 | 93 | 91 | 0 |
| Ljung-Box (retard 1) sur ratios bruts | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1793 | 102 | 105 | 0 |
| Test des suites sur ratios bruts | 2000 | 2000 | 0 | 0 | 0 | 0 | 722 | 1278 | 0 | 0 | 0 | 1878 | 106 | 16 | 0 |
| Rupture de niveau (sup-F) sur ratios bruts | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1798 | 104 | 98 | 0 |
| Stabilite cumulee (OLS-CUSUM) sur ratios bruts | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1801 | 98 | 101 | 0 |
| Valeur aberrante isolee (Grubbs) sur ratios bruts | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1831 | 91 | 78 | 0 |
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
| δ̂* = 1 (π̂* constant) | 722 | 722 |
| δ̂* = 0 (π̂* variable) | 814 | 814 |
| δ̂* intérieur (π̂* variable) | 464 | 464 |
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
| Rapport de vraisemblance : δ = 0 | δ̂* = 1 (π̂* constant) | 722 | 420 | 0,5817 | [0,5448 ; 0,6180] | 248 | 0,3435 | [0,3089 ; 0,3794] |
| Rapport de vraisemblance : δ = 0 | δ̂* = 0 (π̂* variable) | 814 | 0 | 0,0000 | [0,0000 ; 0,0045] | 0 | 0,0000 | [0,0000 ; 0,0045] |
| Rapport de vraisemblance : δ = 0 | δ̂* intérieur (π̂* variable) | 464 | 24 | 0,0517 | [0,0334 ; 0,0760] | 4 | 0,0086 | [0,0024 ; 0,0219] |
| Rapport de vraisemblance : δ = 0 | tous | 2000 | 444 | 0,2220 | [0,2040 ; 0,2409] | 252 | 0,1260 | [0,1118 ; 0,1413] |
| Rapport de vraisemblance : δ = 1 | δ̂* = 1 (π̂* constant) | 722 | 0 | 0,0000 | [0,0000 ; 0,0051] | 0 | 0,0000 | [0,0000 ; 0,0051] |
| Rapport de vraisemblance : δ = 1 | δ̂* = 0 (π̂* variable) | 814 | 338 | 0,4152 | [0,3811 ; 0,4500] | 193 | 0,2371 | [0,2083 ; 0,2679] |
| Rapport de vraisemblance : δ = 1 | δ̂* intérieur (π̂* variable) | 464 | 4 | 0,0086 | [0,0024 ; 0,0219] | 0 | 0,0000 | [0,0000 ; 0,0079] |
| Rapport de vraisemblance : δ = 1 | tous | 2000 | 342 | 0,1710 | [0,1547 ; 0,1882] | 193 | 0,0965 | [0,0839 ; 0,1103] |

Motifs d'absence de p_mc du rapport de vraisemblance : aucun.

Largeur relative de l'IC bootstrap 90 % (contrôle (e4)) : au-dessus de 0,50 dans 85 réplication(s), au-dessus de 0,80 dans 0, sur 2000 où elle est finie.

Bootstrap interne : 0 réplication(s) écartée(s) par usp_bootstrap() sur 1998000 (B = 999 par réplication traitée), dans 0 réplication(s) ; bootstrap restreint (#45) : 0 échec(s) du réajustement contraint ; rapport de vraisemblance : 0 (δ = 0) et 0 (δ = 1) réplication(s) écartée(s).

### Contrôles d'intégrité

- (a) à (d), (e1), (e2), (f) et contrôles de cohérence : OK dans les 8 tranche(s) (ligne INTEGRITE)
- Invariants du corps des tranches (comptes et lignes REP) : OK dans les 8 tranche(s) ; somme des rep = R = 2000
- (e3) effectifs des régimes contre le tableau de #72 : OK : δ̂* au bord 0 : 814 (tableau de #72 : 814 sur 2000) ; au bord 1 : 722 (tableau de #72 : 722 sur 2000) ; usp_ajuster() en erreur : 0 ; docs/tableaux/20260930-issue122-J2.md
- (e4) largeur de l'IC bootstrap contre le tableau de #72 : OK : largeur relative de l'IC bootstrap 90 % au-dessus de 0,50 : 85 sur 2000 (tableau de #72 : 85 sur 2000) ; au-dessus de 0,80 : 0 (tableau de #72 : 0 sur 2000) ; docs/tableaux/20260930-issue122-J2.md

