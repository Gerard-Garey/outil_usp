# Tableau avant / après — référence `reserve2_trapeze` (issue #612)

- Date : 2026-11-25
- Plateforme : R version 4.3.1 (2023-06-16), Linux
- Commande : `Rscript tests/regenerer_et_rendre_compte.R reserve2_trapeze --attendu '^bootstrap\$sigma_boot' --attendu '^bootstrap\$stats_boot' --attendu '^ic_bootstrap' --attendu '^plots_data\$sigma_boot' --attendu '^plots_data\$sigma_usp_boot' --attendu '^plots_data\$boot_reperes' --attendu '^plots_data\$usage_sigma' --attendu '^tests\[\[20\]\]\$detail' --issue 612 --ecrire`
- Motifs attendus : `^bootstrap\$sigma_boot`, `^bootstrap\$stats_boot`, `^ic_bootstrap`, `^plots_data\$sigma_boot`, `^plots_data\$sigma_usp_boot`, `^plots_data\$boot_reperes`, `^plots_data\$usage_sigma`, `^tests\[\[20\]\]\$detail`
- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil 0 pour lister, seuil 1e-06 pour juger ; `INSTABLES` non neutralisé

**Synthèse** : 18573 feuille(s) dans l'ancienne référence, 18573 dans le résultat recalculé ; 7796 non strictement identique(s) (dont 5006 en écart au seuil 1e-06, 0 ajoutée(s), 0 supprimée(s)), toutes désignées par les motifs attendus ; 10777 feuille(s) identique(s) au bit près ; écart numérique maximal 1.120e+03 (relatif, `bootstrap$stats_boot[6927]`).

**Avertissement** : motif `^bootstrap\$sigma_boot` : 999 feuilles désignées (seuil d'avertissement 50) ; vérifier qu'il n'est pas trop large.
**Avertissement** : motif `^bootstrap\$stats_boot` : 4788 feuilles désignées (seuil d'avertissement 50) ; vérifier qu'il n'est pas trop large.
**Avertissement** : motif `^plots_data\$sigma_boot` : 999 feuilles désignées (seuil d'avertissement 50) ; vérifier qu'il n'est pas trop large.
**Avertissement** : motif `^plots_data\$sigma_usp_boot` : 999 feuilles désignées (seuil d'avertissement 50) ; vérifier qu'il n'est pas trop large.

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `tests[[20]]$detail` | …J-1 porte 3 facteurs, dont l'estimateur direct, 0.0973248 a … (670 car., 1re différence au car. 452) | …J-1 porte 3 facteurs. La valeur de sigma2_(J-1) donnee par l… (1296 car., 1re différence au car. 452) |  | non numerique |
| `bootstrap$sigma_boot[1]` | 0.01976386814 | 0.01971971754 | 2.234e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[2]` | 0.02149413021 | 0.02145172303 | 1.973e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[3]` | 0.02141847544 | 0.02143360702 | 7.065e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[4]` | 0.02200821704 | 0.02198986484 | 8.339e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[5]` | 0.01886809924 | 0.0188811076 | 6.894e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[6]` | 0.01898643657 | 0.01897040438 | 8.444e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[7]` | 0.01743678829 | 0.01743696676 | 1.024e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[8]` | 0.01522671176 | 0.01522444666 | 1.488e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[9]` | 0.01361064436 | 0.01360603145 | 3.389e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[10]` | 0.01865576876 | 0.01866908315 | 7.137e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[11]` | 0.01781565448 | 0.01781878674 | 1.758e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[12]` | 0.02026106509 | 0.02026715865 | 3.008e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[13]` | 0.01459518823 | 0.01459258908 | 1.781e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[14]` | 0.01900698885 | 0.01899999561 | 3.679e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[15]` | 0.0144360959 | 0.01442039915 | 1.087e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[16]` | 0.02148163295 | 0.02147450855 | 3.317e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[17]` | 0.01901963959 | 0.01903557685 | 8.379e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[18]` | 0.02103947985 | 0.02101995913 | 9.278e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[19]` | 0.0154611064 | 0.01544511267 | 1.034e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[20]` | 0.01821014007 | 0.01823890206 | 1.579e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[21]` | 0.02220648576 | 0.0221966846 | 4.414e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[22]` | 0.01862079044 | 0.01863667156 | 8.529e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[23]` | 0.01743129061 | 0.01745051636 | 1.103e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[24]` | 0.01483330225 | 0.0148281235 | 3.491e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[25]` | 0.01969633366 | 0.01968379749 | 6.365e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[26]` | 0.01748966989 | 0.01747174528 | 1.025e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[27]` | 0.01785726814 | 0.01788606153 | 1.612e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[28]` | 0.01903459585 | 0.01904097525 | 3.351e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[29]` | 0.01888083818 | 0.01885725585 | 1.249e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[30]` | 0.01630082923 | 0.01630144854 | 3.799e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[31]` | 0.02031783101 | 0.02033639512 | 9.137e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[32]` | 0.01698828524 | 0.01700236905 | 8.290e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[33]` | 0.01715732767 | 0.01715863473 | 7.618e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[34]` | 0.02082449049 | 0.02083360525 | 4.377e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[35]` | 0.0157592862 | 0.01576736184 | 5.124e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[36]` | 0.02437887565 | 0.02438319366 | 1.771e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[37]` | 0.01366660969 | 0.01366379516 | 2.059e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[38]` | 0.01804061445 | 0.01803519109 | 3.006e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[39]` | 0.01566887759 | 0.01569803531 | 1.861e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[40]` | 0.02111426133 | 0.02115197129 | 1.786e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[41]` | 0.02115968877 | 0.02116213844 | 1.158e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[42]` | 0.01614202876 | 0.01614734543 | 3.294e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[43]` | 0.01821934661 | 0.0182468494 | 1.510e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[44]` | 0.02240264995 | 0.02238986311 | 5.708e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[45]` | 0.01848892102 | 0.01850961444 | 1.119e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[46]` | 0.0203881874 | 0.02040101689 | 6.293e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[47]` | 0.02026330603 | 0.02027956654 | 8.025e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[48]` | 0.01397959121 | 0.01398858933 | 6.437e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[49]` | 0.01841979123 | 0.01844889841 | 1.580e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[50]` | 0.01849943497 | 0.01849388644 | 2.999e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[51]` | 0.0169619064 | 0.01697046861 | 5.048e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[52]` | 0.02131921993 | 0.0212931335 | 1.224e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[53]` | 0.01930759926 | 0.01928457784 | 1.192e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[54]` | 0.01391153621 | 0.01390649646 | 3.623e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[55]` | 0.02015046557 | 0.02012020838 | 1.502e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[56]` | 0.012770882 | 0.01278809559 | 1.348e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[57]` | 0.01676538573 | 0.0167945115 | 1.737e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[58]` | 0.0198324584 | 0.01982598154 | 3.266e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[59]` | 0.0190725279 | 0.01906405663 | 4.442e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[60]` | 0.01809360577 | 0.0181026108 | 4.977e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[61]` | 0.01863005481 | 0.01864581367 | 8.459e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[62]` | 0.0141192237 | 0.0141116607 | 5.357e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[63]` | 0.01181628151 | 0.01179171657 | 2.079e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[64]` | 0.02042527318 | 0.02045178395 | 1.298e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[65]` | 0.02347450027 | 0.02346959453 | 2.090e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[66]` | 0.01674686728 | 0.01675437929 | 4.486e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[67]` | 0.0224011018 | 0.02240841068 | 3.263e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[68]` | 0.01678325478 | 0.01673962653 | 2.600e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[69]` | 0.01971682313 | 0.01971097036 | 2.968e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[70]` | 0.02230619141 | 0.02233379065 | 1.237e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[71]` | 0.01714436618 | 0.01715131684 | 4.054e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[72]` | 0.02134037866 | 0.02132394473 | 7.701e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[73]` | 0.01393853644 | 0.0139102866 | 2.027e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[74]` | 0.01518153292 | 0.01516485964 | 1.098e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[75]` | 0.01755688368 | 0.01756656465 | 5.514e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[76]` | 0.01681911699 | 0.01682800023 | 5.282e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[77]` | 0.01614987553 | 0.01615832446 | 5.232e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[78]` | 0.01738450717 | 0.01738734938 | 1.635e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[79]` | 0.01637522909 | 0.01636173826 | 8.239e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[80]` | 0.02023943541 | 0.02021896036 | 1.012e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[81]` | 0.01607950317 | 0.01608540378 | 3.670e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[82]` | 0.02126224364 | 0.02124942928 | 6.027e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[83]` | 0.01832213693 | 0.01832916719 | 3.837e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[84]` | 0.01567031939 | 0.01567843104 | 5.176e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[85]` | 0.02132078042 | 0.02134314967 | 1.049e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[86]` | 0.02026497895 | 0.02025708587 | 3.895e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[87]` | 0.02384380773 | 0.02387963457 | 1.503e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[88]` | 0.0185282207 | 0.0185117053 | 8.914e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[89]` | 0.01711215815 | 0.01711388436 | 1.009e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[90]` | 0.01589077369 | 0.01589420949 | 2.162e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[91]` | 0.01091618918 | 0.01090217648 | 1.284e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[92]` | 0.02035454037 | 0.02035634653 | 8.873e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[93]` | 0.014990412 | 0.01497419711 | 1.082e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[94]` | 0.01614350451 | 0.01613731829 | 3.832e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[95]` | 0.01478682874 | 0.01478507576 | 1.185e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[96]` | 0.0185562584 | 0.01857661672 | 1.097e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[97]` | 0.01675508718 | 0.01677652726 | 1.280e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[98]` | 0.01502366545 | 0.01500000531 | 1.575e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[99]` | 0.01855383659 | 0.01856954529 | 8.467e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[100]` | 0.01590229411 | 0.0159124612 | 6.393e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[101]` | 0.01921364789 | 0.01924448279 | 1.605e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[102]` | 0.02273490874 | 0.02275716754 | 9.791e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[103]` | 0.01661741024 | 0.01662855658 | 6.708e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[104]` | 0.01990096553 | 0.01990810465 | 3.587e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[105]` | 0.01225103715 | 0.01226011712 | 7.412e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[106]` | 0.01876129427 | 0.01876864545 | 3.918e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[107]` | 0.01884655048 | 0.01885207869 | 2.933e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[108]` | 0.02018232011 | 0.02015501086 | 1.353e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[109]` | 0.01511723878 | 0.01513094228 | 9.065e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[110]` | 0.01419558878 | 0.01419128651 | 3.031e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[111]` | 0.01419955262 | 0.01419401692 | 3.899e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[112]` | 0.01909019678 | 0.01908923316 | 5.048e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[113]` | 0.01850333305 | 0.01852626964 | 1.240e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[114]` | 0.01593524207 | 0.01592385142 | 7.148e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[115]` | 0.0234599671 | 0.02342572394 | 1.460e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[116]` | 0.01682795566 | 0.01682709351 | 5.123e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[117]` | 0.01789294561 | 0.01792591383 | 1.843e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[118]` | 0.01415071366 | 0.01413412772 | 1.172e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[119]` | 0.01972438703 | 0.01973863591 | 7.224e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[120]` | 0.02244555076 | 0.02241774491 | 1.239e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[121]` | 0.01963933866 | 0.01967265399 | 1.696e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[122]` | 0.02172628502 | 0.02173372717 | 3.425e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[123]` | 0.01904880803 | 0.01903653169 | 6.445e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[124]` | 0.02137726915 | 0.02142219282 | 2.101e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[125]` | 0.01588685097 | 0.01587576328 | 6.979e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[126]` | 0.01473384663 | 0.01472730942 | 4.437e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[127]` | 0.02031487743 | 0.0203118286 | 1.501e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[128]` | 0.02161364824 | 0.0216174789 | 1.772e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[129]` | 0.01592649024 | 0.01589146763 | 2.199e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[130]` | 0.02151260387 | 0.02152471513 | 5.630e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[131]` | 0.01980881879 | 0.01980708809 | 8.737e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[132]` | 0.01940871144 | 0.01940425425 | 2.296e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[133]` | 0.01780591955 | 0.01780251181 | 1.914e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[134]` | 0.0209191601 | 0.02096322861 | 2.107e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[135]` | 0.01604427839 | 0.0160492731 | 3.113e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[136]` | 0.01854978295 | 0.01855473157 | 2.668e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[137]` | 0.01757148215 | 0.01756224011 | 5.260e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[138]` | 0.02128150662 | 0.02129499123 | 6.336e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[139]` | 0.01927108967 | 0.01926302344 | 4.186e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[140]` | 0.02136139567 | 0.02135084521 | 4.939e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[141]` | 0.02105554556 | 0.02102385182 | 1.505e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[142]` | 0.01238611245 | 0.01237232667 | 1.113e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[143]` | 0.01841256317 | 0.01837210806 | 2.197e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[144]` | 0.02275170516 | 0.02274844979 | 1.431e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[145]` | 0.01956322936 | 0.01955739309 | 2.983e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[146]` | 0.02226081007 | 0.02222455699 | 1.629e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[147]` | 0.01984834866 | 0.01986748865 | 9.643e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[148]` | 0.01675587535 | 0.01676457693 | 5.193e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[149]` | 0.01586517357 | 0.01585896015 | 3.916e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[150]` | 0.02273040166 | 0.02274825306 | 7.854e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[151]` | 0.0243906344 | 0.02438171999 | 3.655e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[152]` | 0.02006477871 | 0.02006960515 | 2.405e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[153]` | 0.01794341466 | 0.01795182011 | 4.684e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[154]` | 0.01720372404 | 0.01719530309 | 4.895e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[155]` | 0.01579618069 | 0.01580037411 | 2.655e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[156]` | 0.01727599694 | 0.01730450447 | 1.650e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[157]` | 0.01531919564 | 0.01532519268 | 3.915e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[158]` | 0.02246683599 | 0.02245890786 | 3.529e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[159]` | 0.01739390266 | 0.01737474653 | 1.101e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[160]` | 0.01946234867 | 0.01946431198 | 1.009e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[161]` | 0.02101915194 | 0.02101255695 | 3.138e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[162]` | 0.01815220483 | 0.01814894794 | 1.794e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[163]` | 0.01648501361 | 0.01650173989 | 1.015e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[164]` | 0.01915828723 | 0.01918444938 | 1.366e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[165]` | 0.01533683385 | 0.01533793132 | 7.156e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[166]` | 0.02271236953 | 0.02269653067 | 6.974e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[167]` | 0.01568886886 | 0.01567117169 | 1.128e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[168]` | 0.01769044107 | 0.01769871341 | 4.676e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[169]` | 0.01889407026 | 0.01888842118 | 2.990e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[170]` | 0.01620200909 | 0.01618628764 | 9.703e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[171]` | 0.01735789788 | 0.01736494095 | 4.058e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[172]` | 0.01810257333 | 0.01810230456 | 1.485e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[173]` | 0.01836841046 | 0.01838411164 | 8.548e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[174]` | 0.01703558705 | 0.01703735682 | 1.039e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[175]` | 0.01578530238 | 0.01576994197 | 9.731e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[176]` | 0.01904131962 | 0.0190092739 | 1.683e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[177]` | 0.01723523065 | 0.01722997132 | 3.052e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[178]` | 0.02338657866 | 0.02337537737 | 4.790e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[179]` | 0.01351681149 | 0.01349652119 | 1.501e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[180]` | 0.01649752403 | 0.0164959344 | 9.636e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[181]` | 0.02378919394 | 0.02380074343 | 4.855e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[182]` | 0.02107450037 | 0.0210614895 | 6.174e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[183]` | 0.02031850566 | 0.0203401972 | 1.068e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[184]` | 0.01521575388 | 0.01522317039 | 4.874e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[185]` | 0.01825351188 | 0.01823098452 | 1.234e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[186]` | 0.0152058133 | 0.01519897162 | 4.499e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[187]` | 0.02079609166 | 0.02080162416 | 2.660e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[188]` | 0.01384464511 | 0.01384146496 | 2.297e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[189]` | 0.01907498519 | 0.01907748672 | 1.311e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[190]` | 0.02136659077 | 0.02140737601 | 1.909e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[191]` | 0.01973419093 | 0.01973148304 | 1.372e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[192]` | 0.01549684634 | 0.01549751699 | 4.328e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[193]` | 0.01626882346 | 0.01627401411 | 3.191e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[194]` | 0.01713876342 | 0.01711029976 | 1.661e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[195]` | 0.01635300042 | 0.01638249373 | 1.804e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[196]` | 0.01871147938 | 0.0186771041 | 1.837e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[197]` | 0.02328891134 | 0.023272899 | 6.876e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[198]` | 0.02128101662 | 0.02130995253 | 1.360e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[199]` | 0.01500244963 | 0.01502199462 | 1.303e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[200]` | 0.01241788936 | 0.01241536301 | 2.034e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[201]` | 0.0232616408 | 0.02324729212 | 6.168e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[202]` | 0.01863548946 | 0.01864862712 | 7.050e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[203]` | 0.01649911352 | 0.01652773833 | 1.735e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[204]` | 0.02254631888 | 0.02257286402 | 1.177e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[205]` | 0.01547748125 | 0.01545605788 | 1.384e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[206]` | 0.01847627617 | 0.01848342405 | 3.869e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[207]` | 0.01854994086 | 0.01854886466 | 5.802e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[208]` | 0.02295130923 | 0.02296246741 | 4.862e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[209]` | 0.01470033457 | 0.01469158335 | 5.953e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[210]` | 0.01972627207 | 0.01971071945 | 7.884e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[211]` | 0.01905031711 | 0.01908250309 | 1.690e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[212]` | 0.01917652055 | 0.01917240251 | 2.147e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[213]` | 0.01374475181 | 0.01373250373 | 8.911e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[214]` | 0.01973812485 | 0.01972135593 | 8.496e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[215]` | 0.01870690811 | 0.01869309675 | 7.383e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[216]` | 0.01511196471 | 0.01512151563 | 6.320e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[217]` | 0.0164137864 | 0.01642292501 | 5.568e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[218]` | 0.0200542817 | 0.02000859018 | 2.278e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[219]` | 0.01653892128 | 0.01650861071 | 1.833e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[220]` | 0.02327164834 | 0.02325694846 | 6.317e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[221]` | 0.01843577735 | 0.01843034637 | 2.946e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[222]` | 0.01746963482 | 0.017443896 | 1.473e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[223]` | 0.02042203307 | 0.02037855847 | 2.129e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[224]` | 0.01916694325 | 0.01918795454 | 1.096e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[225]` | 0.01464862748 | 0.01465202016 | 2.316e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[226]` | 0.01391431772 | 0.01391363413 | 4.913e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[227]` | 0.01210213146 | 0.01212263533 | 1.694e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[228]` | 0.01411678576 | 0.01413587228 | 1.352e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[229]` | 0.0144838722 | 0.01448057615 | 2.276e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[230]` | 0.01626107877 | 0.01625471579 | 3.913e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[231]` | 0.01802257144 | 0.01799433271 | 1.567e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[232]` | 0.02086644922 | 0.02085666216 | 4.690e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[233]` | 0.01782103009 | 0.01784655941 | 1.433e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[234]` | 0.01926240364 | 0.01928684771 | 1.269e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[235]` | 0.02286188324 | 0.0228960487 | 1.494e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[236]` | 0.01614213476 | 0.01611234414 | 1.846e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[237]` | 0.02191731679 | 0.02195718603 | 1.819e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[238]` | 0.01651431073 | 0.01653669504 | 1.355e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[239]` | 0.01234339969 | 0.01233948115 | 3.175e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[240]` | 0.01734492436 | 0.01733814122 | 3.911e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[241]` | 0.018313663 | 0.01831772261 | 2.217e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[242]` | 0.01065341084 | 0.01066015492 | 6.330e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[243]` | 0.02088063414 | 0.02087495907 | 2.718e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[244]` | 0.01268316953 | 0.01269505178 | 9.369e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[245]` | 0.01514132276 | 0.01514186978 | 3.613e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[246]` | 0.01701063006 | 0.01703061158 | 1.175e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[247]` | 0.01969551207 | 0.01969532023 | 9.740e-06 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[248]` | 0.0185066446 | 0.01850960063 | 1.597e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[249]` | 0.01573313698 | 0.01572977413 | 2.137e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[250]` | 0.01814044252 | 0.01813974076 | 3.869e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[251]` | 0.01318707977 | 0.01317415097 | 9.804e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[252]` | 0.01778769857 | 0.01776930251 | 1.034e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[253]` | 0.01840378743 | 0.0184039522 | 8.953e-06 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[254]` | 0.02040285111 | 0.02039951397 | 1.636e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[255]` | 0.01482895292 | 0.0148328228 | 2.610e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[256]` | 0.01927793512 | 0.0192704446 | 3.886e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[257]` | 0.01780310256 | 0.01780536311 | 1.270e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[258]` | 0.01709449333 | 0.01708760116 | 4.032e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[259]` | 0.02319848969 | 0.0231867705 | 5.052e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[260]` | 0.0180302638 | 0.0180478281 | 9.742e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[261]` | 0.01589941626 | 0.01588061467 | 1.183e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[262]` | 0.02055479197 | 0.02054219078 | 6.131e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[263]` | 0.01888009676 | 0.01888789663 | 4.131e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[264]` | 0.02127132196 | 0.02128916259 | 8.387e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[265]` | 0.01845774197 | 0.01843185594 | 1.402e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[266]` | 0.02168983018 | 0.02168858961 | 5.720e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[267]` | 0.0191937958 | 0.01918828674 | 2.870e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[268]` | 0.01819360534 | 0.0182127761 | 1.054e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[269]` | 0.02053524832 | 0.02050813491 | 1.320e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[270]` | 0.01920713449 | 0.01917933941 | 1.447e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[271]` | 0.01388414988 | 0.01387739508 | 4.865e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[272]` | 0.02078378654 | 0.02077198965 | 5.676e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[273]` | 0.01555325576 | 0.01556968249 | 1.056e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[274]` | 0.0199845083 | 0.0199812663 | 1.622e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[275]` | 0.01298668646 | 0.01298932295 | 2.030e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[276]` | 0.02378504921 | 0.02376451057 | 8.635e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[277]` | 0.0202680397 | 0.02026244975 | 2.758e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[278]` | 0.01735013896 | 0.01733999758 | 5.845e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[279]` | 0.01683083645 | 0.01684504104 | 8.440e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[280]` | 0.01868458512 | 0.01869282371 | 4.409e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[281]` | 0.01894280174 | 0.01895496668 | 6.422e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[282]` | 0.01877547782 | 0.01875267007 | 1.215e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[283]` | 0.01804448033 | 0.01804244904 | 1.126e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[284]` | 0.01694664541 | 0.01696798799 | 1.259e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[285]` | 0.01796652198 | 0.01795104384 | 8.615e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[286]` | 0.01871965877 | 0.01875553076 | 1.916e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[287]` | 0.01727317907 | 0.01726344136 | 5.637e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[288]` | 0.02022994984 | 0.02022926583 | 3.381e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[289]` | 0.01447255256 | 0.01447816913 | 3.881e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[290]` | 0.02080329059 | 0.02080398158 | 3.322e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[291]` | 0.01999979571 | 0.02002612861 | 1.317e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[292]` | 0.01397995076 | 0.01397121072 | 6.252e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[293]` | 0.02082549745 | 0.02083635363 | 5.213e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[294]` | 0.01996876559 | 0.01998362597 | 7.442e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[295]` | 0.01906723494 | 0.01909322188 | 1.363e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[296]` | 0.01706998129 | 0.01706401783 | 3.494e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[297]` | 0.01919525048 | 0.01918568574 | 4.983e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[298]` | 0.01788223515 | 0.01790341838 | 1.185e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[299]` | 0.0173291195 | 0.01731293879 | 9.337e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[300]` | 0.01929996518 | 0.01927328884 | 1.382e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[301]` | 0.01878353746 | 0.01878153093 | 1.068e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[302]` | 0.01560230465 | 0.01561123482 | 5.724e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[303]` | 0.01845658456 | 0.01846132098 | 2.566e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[304]` | 0.02110794046 | 0.02108151814 | 1.252e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[305]` | 0.0179040233 | 0.01789370119 | 5.765e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[306]` | 0.01746308155 | 0.01746702658 | 2.259e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[307]` | 0.01297322337 | 0.01298883464 | 1.203e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[308]` | 0.01611484406 | 0.01612851096 | 8.481e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[309]` | 0.01144906513 | 0.01145202455 | 2.585e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[310]` | 0.01710861532 | 0.01713252768 | 1.398e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[311]` | 0.01809185356 | 0.01807466596 | 9.500e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[312]` | 0.01875712096 | 0.01873642945 | 1.103e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[313]` | 0.01846967599 | 0.0184412152 | 1.541e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[314]` | 0.01810454806 | 0.0181202156 | 8.654e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[315]` | 0.01799548597 | 0.01799716259 | 9.317e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[316]` | 0.01652460088 | 0.01652096989 | 2.197e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[317]` | 0.01869818778 | 0.01868163438 | 8.853e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[318]` | 0.01445483546 | 0.01442794364 | 1.860e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[319]` | 0.01987272687 | 0.01987710753 | 2.204e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[320]` | 0.01778014726 | 0.01776594478 | 7.988e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[321]` | 0.01869036269 | 0.01868049902 | 5.277e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[322]` | 0.01651938509 | 0.01652778827 | 5.087e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[323]` | 0.01739154227 | 0.01739605251 | 2.593e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[324]` | 0.01469529844 | 0.01470300839 | 5.247e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[325]` | 0.01728338602 | 0.01731162322 | 1.634e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[326]` | 0.0201731121 | 0.02016595186 | 3.549e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[327]` | 0.01429909575 | 0.01430238028 | 2.297e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[328]` | 0.01416078015 | 0.01416488581 | 2.899e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[329]` | 0.01224716143 | 0.01223310303 | 1.148e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[330]` | 0.02100544398 | 0.0210053005 | 6.831e-06 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[331]` | 0.01828565826 | 0.01826732893 | 1.002e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[332]` | 0.01282338785 | 0.01283335489 | 7.773e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[333]` | 0.01696525925 | 0.01696322736 | 1.198e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[334]` | 0.02225929347 | 0.0222982553 | 1.750e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[335]` | 0.01529862073 | 0.01530325168 | 3.027e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[336]` | 0.01385440326 | 0.01386411982 | 7.013e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[337]` | 0.01762054563 | 0.0176261702 | 3.192e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[338]` | 0.01488026547 | 0.01486780853 | 8.371e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[339]` | 0.0213982826 | 0.02139903142 | 3.499e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[340]` | 0.01961819171 | 0.0195771471 | 2.092e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[341]` | 0.01105989282 | 0.01105318032 | 6.069e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[342]` | 0.0181489554 | 0.01815706855 | 4.470e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[343]` | 0.01096277114 | 0.01097529772 | 1.143e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[344]` | 0.02163978435 | 0.0216737419 | 1.569e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[345]` | 0.02093047314 | 0.02092568735 | 2.287e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[346]` | 0.02140894192 | 0.0214170671 | 3.795e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[347]` | 0.02013231861 | 0.02015447266 | 1.100e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[348]` | 0.01963956454 | 0.01961567439 | 1.216e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[349]` | 0.01994811569 | 0.01992982067 | 9.171e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[350]` | 0.0192223789 | 0.01923402854 | 6.060e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[351]` | 0.0170610129 | 0.01705648443 | 2.654e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[352]` | 0.01490608847 | 0.01493185639 | 1.729e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[353]` | 0.02453768058 | 0.02453452875 | 1.284e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[354]` | 0.02279698271 | 0.02280996064 | 5.693e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[355]` | 0.01571311304 | 0.01571934492 | 3.966e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[356]` | 0.01455128694 | 0.01453798787 | 9.139e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[357]` | 0.02093919712 | 0.0209102304 | 1.383e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[358]` | 0.01330534442 | 0.01330448237 | 6.479e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[359]` | 0.01531567792 | 0.01531429962 | 8.999e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[360]` | 0.01774249237 | 0.01773995989 | 1.427e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[361]` | 0.01737579673 | 0.01738735647 | 6.653e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[362]` | 0.01867479501 | 0.01868912806 | 7.675e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[363]` | 0.01560010552 | 0.01559059827 | 6.094e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[364]` | 0.01543240255 | 0.01542334608 | 5.868e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[365]` | 0.01291108393 | 0.01290608149 | 3.875e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[366]` | 0.02069149837 | 0.0206629094 | 1.382e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[367]` | 0.01588857801 | 0.0158760897 | 7.860e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[368]` | 0.02121464029 | 0.02117535615 | 1.852e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[369]` | 0.01843718355 | 0.01842890766 | 4.489e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[370]` | 0.0157891595 | 0.01579337577 | 2.670e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[371]` | 0.01569977923 | 0.01569651197 | 2.081e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[372]` | 0.01801026504 | 0.01799167453 | 1.032e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[373]` | 0.02106273705 | 0.02106249657 | 1.142e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[374]` | 0.01853591895 | 0.01853926505 | 1.805e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[375]` | 0.01786638367 | 0.01783625884 | 1.686e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[376]` | 0.01706676677 | 0.01707236357 | 3.279e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[377]` | 0.0166101427 | 0.01660821581 | 1.160e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[378]` | 0.0160314375 | 0.01604317521 | 7.322e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[379]` | 0.01751266919 | 0.01752975275 | 9.755e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[380]` | 0.01731782524 | 0.01731898393 | 6.691e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[381]` | 0.01768425444 | 0.01769735047 | 7.405e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[382]` | 0.01316303395 | 0.01317471607 | 8.875e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[383]` | 0.01580603 | 0.01579977439 | 3.958e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[384]` | 0.01112541732 | 0.01113842795 | 1.169e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[385]` | 0.01648089587 | 0.01646889022 | 7.285e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[386]` | 0.01597915998 | 0.0159760447 | 1.950e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[387]` | 0.01707882536 | 0.01708270423 | 2.271e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[388]` | 0.01836351295 | 0.01837658037 | 7.116e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[389]` | 0.02042092219 | 0.02039853282 | 1.096e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[390]` | 0.01704320256 | 0.01704286421 | 1.985e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[391]` | 0.02295805089 | 0.02292140268 | 1.596e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[392]` | 0.01514129144 | 0.01515307337 | 7.781e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[393]` | 0.02143255137 | 0.02146788719 | 1.649e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[394]` | 0.02041054584 | 0.02039700969 | 6.632e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[395]` | 0.0191730526 | 0.01919387291 | 1.086e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[396]` | 0.01698565656 | 0.01698980231 | 2.441e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[397]` | 0.01717776806 | 0.0171617843 | 9.305e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[398]` | 0.01524556868 | 0.01522372131 | 1.433e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[399]` | 0.01360979783 | 0.01360601877 | 2.777e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[400]` | 0.01641327901 | 0.01643965444 | 1.607e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[401]` | 0.01898818012 | 0.01896282476 | 1.335e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[402]` | 0.01552357503 | 0.01552112614 | 1.578e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[403]` | 0.02260094298 | 0.02263662924 | 1.579e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[404]` | 0.02048132382 | 0.02048996211 | 4.218e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[405]` | 0.01310337007 | 0.01309401518 | 7.139e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[406]` | 0.02290117314 | 0.02286351238 | 1.644e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[407]` | 0.01800590853 | 0.01801294145 | 3.906e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[408]` | 0.01921793846 | 0.01923560594 | 9.193e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[409]` | 0.01411733046 | 0.01411546966 | 1.318e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[410]` | 0.01904911834 | 0.01904693022 | 1.149e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[411]` | 0.01969264821 | 0.01967196775 | 1.050e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[412]` | 0.01817051864 | 0.0181831889 | 6.973e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[413]` | 0.01737164973 | 0.01738475198 | 7.542e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[414]` | 0.01930978108 | 0.01931262968 | 1.475e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[415]` | 0.01716422509 | 0.0171473948 | 9.805e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[416]` | 0.01699836265 | 0.01699450346 | 2.270e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[417]` | 0.01809820819 | 0.01809747716 | 4.039e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[418]` | 0.01940161406 | 0.01941890007 | 8.910e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[419]` | 0.01933768414 | 0.01935646728 | 9.713e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[420]` | 0.01458113406 | 0.01459819239 | 1.170e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[421]` | 0.02119573568 | 0.0212153789 | 9.268e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[422]` | 0.0190397265 | 0.01904590921 | 3.247e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[423]` | 0.01529108496 | 0.01529866409 | 4.957e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[424]` | 0.02397073967 | 0.02395565285 | 6.294e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[425]` | 0.02031831155 | 0.02032383998 | 2.721e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[426]` | 0.02288061985 | 0.02290221413 | 9.438e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[427]` | 0.01320117327 | 0.01320903213 | 5.953e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[428]` | 0.01442456247 | 0.01443708149 | 8.679e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[429]` | 0.01998456081 | 0.01999123591 | 3.340e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[430]` | 0.01762718557 | 0.01764018374 | 7.374e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[431]` | 0.02313105241 | 0.02313529784 | 1.835e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[432]` | 0.02186845362 | 0.0219113834 | 1.963e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[433]` | 0.02318760008 | 0.02316305229 | 1.059e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[434]` | 0.0211886352 | 0.02119679996 | 3.853e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[435]` | 0.02022297022 | 0.02023383175 | 5.371e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[436]` | 0.01688461154 | 0.01688334731 | 7.487e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[437]` | 0.01692038517 | 0.01692555294 | 3.054e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[438]` | 0.02332617517 | 0.02328033446 | 1.965e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[439]` | 0.01270687958 | 0.01268755804 | 1.521e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[440]` | 0.01825265166 | 0.01823340287 | 1.055e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[441]` | 0.01502584837 | 0.01502070663 | 3.422e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[442]` | 0.01208338558 | 0.01209640262 | 1.077e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[443]` | 0.01692009857 | 0.01691937777 | 4.260e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[444]` | 0.01943398921 | 0.01942738843 | 3.397e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[445]` | 0.01870017891 | 0.01870509149 | 2.627e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[446]` | 0.01770999177 | 0.01770280962 | 4.055e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[447]` | 0.01732928535 | 0.01734592957 | 9.605e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[448]` | 0.01135620812 | 0.01135659937 | 3.445e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[449]` | 0.01390418907 | 0.01387764042 | 1.909e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[450]` | 0.01729548723 | 0.01727670306 | 1.086e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[451]` | 0.01889493452 | 0.01889118403 | 1.985e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[452]` | 0.01689870058 | 0.01686399769 | 2.054e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[453]` | 0.02088854419 | 0.02085644043 | 1.537e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[454]` | 0.01931864957 | 0.01931261222 | 3.125e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[455]` | 0.01641563865 | 0.01642443323 | 5.357e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[456]` | 0.01456681127 | 0.01458334862 | 1.135e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[457]` | 0.01406823933 | 0.01404779475 | 1.453e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[458]` | 0.02175620063 | 0.02175380115 | 1.103e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[459]` | 0.01707085913 | 0.01708518464 | 8.392e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[460]` | 0.01854113433 | 0.01855025505 | 4.919e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[461]` | 0.01723701025 | 0.01725991396 | 1.329e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[462]` | 0.02014986655 | 0.02015092689 | 5.262e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[463]` | 0.01698446989 | 0.01698077308 | 2.177e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[464]` | 0.01184275064 | 0.0118328098 | 8.394e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[465]` | 0.02096381333 | 0.02096104137 | 1.322e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[466]` | 0.0213280717 | 0.02130924333 | 8.828e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[467]` | 0.01803866112 | 0.01804416071 | 3.049e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[468]` | 0.01805995157 | 0.01805934738 | 3.345e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[469]` | 0.01785893798 | 0.01787378778 | 8.315e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[470]` | 0.01632432107 | 0.01631459194 | 5.960e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[471]` | 0.02232228621 | 0.02231546369 | 3.056e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[472]` | 0.01882855656 | 0.01880849192 | 1.066e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[473]` | 0.02146157476 | 0.02147329232 | 5.460e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[474]` | 0.01709159912 | 0.0170885086 | 1.808e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[475]` | 0.01961905085 | 0.01963313373 | 7.178e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[476]` | 0.01817692169 | 0.01817680377 | 6.487e-06 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[477]` | 0.01779966362 | 0.0177820881 | 9.874e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[478]` | 0.01964041605 | 0.01963401951 | 3.257e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[479]` | 0.02145788557 | 0.02144696275 | 5.090e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[480]` | 0.02094750374 | 0.02096842529 | 9.988e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[481]` | 0.01495080622 | 0.01494991858 | 5.937e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[482]` | 0.02096477565 | 0.02093032498 | 1.643e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[483]` | 0.01638778658 | 0.01639239536 | 2.812e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[484]` | 0.02090019157 | 0.02088551243 | 7.023e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[485]` | 0.01769332885 | 0.01768570368 | 4.310e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[486]` | 0.01632077647 | 0.01630603098 | 9.035e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[487]` | 0.01669176624 | 0.01668476524 | 4.194e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[488]` | 0.02094059988 | 0.02095400048 | 6.399e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[489]` | 0.02171795376 | 0.02173570722 | 8.175e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[490]` | 0.02208268921 | 0.02208902708 | 2.870e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[491]` | 0.0177250806 | 0.01772129816 | 2.134e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[492]` | 0.01853127317 | 0.01855118024 | 1.074e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[493]` | 0.01361900327 | 0.01362782194 | 6.475e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[494]` | 0.01796237286 | 0.0179707575 | 4.668e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[495]` | 0.01658622634 | 0.01659600979 | 5.899e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[496]` | 0.01686112889 | 0.01685161987 | 5.640e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[497]` | 0.01584527742 | 0.01583859151 | 4.219e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[498]` | 0.01694326317 | 0.01692652821 | 9.877e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[499]` | 0.01454799229 | 0.01453392219 | 9.672e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[500]` | 0.0241721119 | 0.02416055225 | 4.782e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[501]` | 0.02143040698 | 0.02146014789 | 1.388e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[502]` | 0.01884098026 | 0.0188320676 | 4.730e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[503]` | 0.01904610752 | 0.01904849831 | 1.255e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[504]` | 0.01394117505 | 0.0139419964 | 5.892e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[505]` | 0.01670965385 | 0.01671902038 | 5.605e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[506]` | 0.0144719365 | 0.01445634042 | 1.078e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[507]` | 0.02011955031 | 0.02013382892 | 7.097e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[508]` | 0.01733080975 | 0.01732063081 | 5.873e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[509]` | 0.01897273574 | 0.01896937747 | 1.770e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[510]` | 0.01925893578 | 0.01924586402 | 6.787e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[511]` | 0.01716087396 | 0.01719011687 | 1.704e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[512]` | 0.01321698898 | 0.01323142508 | 1.092e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[513]` | 0.0214425934 | 0.02144745 | 2.265e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[514]` | 0.01859240787 | 0.01858424059 | 4.393e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[515]` | 0.0160065744 | 0.0159977121 | 5.537e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[516]` | 0.02027572185 | 0.02030567804 | 1.477e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[517]` | 0.01635973949 | 0.01632811814 | 1.933e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[518]` | 0.0134875458 | 0.01349067747 | 2.322e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[519]` | 0.01573240658 | 0.01574739555 | 9.527e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[520]` | 0.01886316425 | 0.01886875403 | 2.963e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[521]` | 0.01907481827 | 0.01907690585 | 1.094e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[522]` | 0.01915798214 | 0.01915166232 | 3.299e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[523]` | 0.01535220181 | 0.01534673791 | 3.559e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[524]` | 0.01862183384 | 0.01863740226 | 8.360e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[525]` | 0.01718009032 | 0.01719338678 | 7.739e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[526]` | 0.01966031343 | 0.01963944537 | 1.061e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[527]` | 0.01795607221 | 0.01793048774 | 1.425e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[528]` | 0.01697540759 | 0.01699294799 | 1.033e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[529]` | 0.01974493202 | 0.01972024328 | 1.250e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[530]` | 0.01952155298 | 0.01952285387 | 6.664e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[531]` | 0.01975210653 | 0.0197365736 | 7.864e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[532]` | 0.01985013137 | 0.01984122841 | 4.485e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[533]` | 0.01708562811 | 0.01710020728 | 8.533e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[534]` | 0.02089049939 | 0.02088060299 | 4.737e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[535]` | 0.01583521582 | 0.01586147634 | 1.658e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[536]` | 0.01856347227 | 0.01854954554 | 7.502e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[537]` | 0.01851606345 | 0.0185016713 | 7.773e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[538]` | 0.01699416375 | 0.01701564759 | 1.264e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[539]` | 0.0182950642 | 0.01831399739 | 1.035e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[540]` | 0.01696772166 | 0.01697882127 | 6.542e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[541]` | 0.01971639685 | 0.01968392958 | 1.647e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[542]` | 0.01927869613 | 0.01928582337 | 3.697e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[543]` | 0.017589308 | 0.01759606458 | 3.841e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[544]` | 0.0134688415 | 0.01347517993 | 4.706e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[545]` | 0.01617807713 | 0.01616772424 | 6.399e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[546]` | 0.01987053187 | 0.01988869346 | 9.140e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[547]` | 0.01851235992 | 0.0185399834 | 1.492e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[548]` | 0.01400274674 | 0.01401632914 | 9.700e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[549]` | 0.01627491321 | 0.01627690034 | 1.221e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[550]` | 0.01565080406 | 0.01563000218 | 1.329e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[551]` | 0.01442341923 | 0.01440953077 | 9.629e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[552]` | 0.01626891212 | 0.01625927373 | 5.924e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[553]` | 0.01849529922 | 0.01851410637 | 1.017e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[554]` | 0.02218889863 | 0.0222195981 | 1.384e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[555]` | 0.02012514589 | 0.02012051288 | 2.302e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[556]` | 0.01297479736 | 0.01298919368 | 1.110e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[557]` | 0.01623212921 | 0.01625379841 | 1.335e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[558]` | 0.02175224264 | 0.02174149542 | 4.941e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[559]` | 0.02024303502 | 0.02027436728 | 1.548e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[560]` | 0.01891654153 | 0.01890166701 | 7.863e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[561]` | 0.01519069077 | 0.01517975594 | 7.198e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[562]` | 0.02365533986 | 0.02363277986 | 9.537e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[563]` | 0.02015710801 | 0.02017963303 | 1.117e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[564]` | 0.01916562197 | 0.01916864063 | 1.575e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[565]` | 0.01856070025 | 0.01855021853 | 5.647e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[566]` | 0.02015754822 | 0.02013072777 | 1.331e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[567]` | 0.01597855479 | 0.01596562765 | 8.090e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[568]` | 0.01791404439 | 0.01791376812 | 1.542e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[569]` | 0.01520357533 | 0.01519028753 | 8.740e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[570]` | 0.01557203192 | 0.01556367732 | 5.365e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[571]` | 0.02062877965 | 0.02062687791 | 9.219e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[572]` | 0.02012359037 | 0.02009855142 | 1.244e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[573]` | 0.01139390446 | 0.01139557865 | 1.469e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[574]` | 0.02032667813 | 0.02036256121 | 1.765e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[575]` | 0.01843161888 | 0.01843375214 | 1.157e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[576]` | 0.01265684225 | 0.0126545079 | 1.844e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[577]` | 0.0174493645 | 0.01746811694 | 1.075e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[578]` | 0.01533611342 | 0.01535937718 | 1.517e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[579]` | 0.01484266173 | 0.01484527713 | 1.762e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[580]` | 0.01687301798 | 0.01686396272 | 5.367e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[581]` | 0.01706208612 | 0.01704767775 | 8.445e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[582]` | 0.01790034726 | 0.01792515539 | 1.386e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[583]` | 0.02266730322 | 0.02269446261 | 1.198e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[584]` | 0.0128472757 | 0.01285693095 | 7.515e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[585]` | 0.01581230568 | 0.01581936053 | 4.462e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[586]` | 0.01785506989 | 0.01786496398 | 5.541e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[587]` | 0.02105976635 | 0.02104443613 | 7.279e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[588]` | 0.01583176223 | 0.01583566092 | 2.463e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[589]` | 0.02247124877 | 0.02245813338 | 5.837e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[590]` | 0.01349624471 | 0.01351317024 | 1.254e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[591]` | 0.01733325233 | 0.01733263601 | 3.556e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[592]` | 0.01962478782 | 0.01961146676 | 6.788e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[593]` | 0.01776044779 | 0.01776624457 | 3.264e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[594]` | 0.01993764586 | 0.01989956998 | 1.910e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[595]` | 0.01613914992 | 0.01614012149 | 6.020e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[596]` | 0.01339161009 | 0.0133936131 | 1.496e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[597]` | 0.01913046548 | 0.01912362235 | 3.577e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[598]` | 0.01354969399 | 0.01353177972 | 1.322e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[599]` | 0.02281395596 | 0.02279093282 | 1.009e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[600]` | 0.01904718899 | 0.01907332871 | 1.372e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[601]` | 0.01809143356 | 0.01809158742 | 8.505e-06 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[602]` | 0.01573890456 | 0.01573980523 | 5.723e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[603]` | 0.02038347904 | 0.02035271345 | 1.509e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[604]` | 0.01754562657 | 0.0175336084 | 6.850e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[605]` | 0.01621637924 | 0.0162016291 | 9.096e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[606]` | 0.02157816568 | 0.02154244847 | 1.655e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[607]` | 0.01462358256 | 0.01462024611 | 2.282e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[608]` | 0.02143284679 | 0.02145398619 | 9.863e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[609]` | 0.01550478261 | 0.01550680672 | 1.305e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[610]` | 0.01773170483 | 0.01776458349 | 1.854e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[611]` | 0.01720514025 | 0.01721214497 | 4.071e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[612]` | 0.02186454691 | 0.02189406371 | 1.350e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[613]` | 0.01514640986 | 0.01514315114 | 2.151e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[614]` | 0.01788653507 | 0.01791055201 | 1.343e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[615]` | 0.01564445251 | 0.01560742399 | 2.367e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[616]` | 0.02067064076 | 0.02067613044 | 2.656e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[617]` | 0.02055811299 | 0.02052113135 | 1.799e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[618]` | 0.0216961256 | 0.02170552335 | 4.332e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[619]` | 0.01868421 | 0.01868123557 | 1.592e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[620]` | 0.02051976651 | 0.02054252427 | 1.109e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[621]` | 0.02269883105 | 0.02270799172 | 4.036e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[622]` | 0.01911031203 | 0.01912704613 | 8.757e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[623]` | 0.01732095181 | 0.01732622369 | 3.044e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[624]` | 0.01819816952 | 0.01818465535 | 7.426e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[625]` | 0.0182904126 | 0.01828713171 | 1.794e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[626]` | 0.01432209227 | 0.01432995482 | 5.490e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[627]` | 0.0141905027 | 0.01418868349 | 1.282e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[628]` | 0.02021405055 | 0.02018262018 | 1.555e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[629]` | 0.01315805229 | 0.01315245184 | 4.256e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[630]` | 0.0184559266 | 0.01848692467 | 1.680e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[631]` | 0.0158158345 | 0.01580849722 | 4.639e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[632]` | 0.02430003189 | 0.02429703634 | 1.233e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[633]` | 0.01571948458 | 0.0157195791 | 6.013e-06 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[634]` | 0.01312710267 | 0.01312979364 | 2.050e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[635]` | 0.01589634209 | 0.01587060734 | 1.619e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[636]` | 0.01622105591 | 0.01623430642 | 8.169e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[637]` | 0.02526507136 | 0.02520388993 | 2.422e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[638]` | 0.01960483296 | 0.01957953013 | 1.291e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[639]` | 0.01628089385 | 0.01629138242 | 6.442e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[640]` | 0.01712400467 | 0.01711427258 | 5.683e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[641]` | 0.02016113654 | 0.02015623099 | 2.433e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[642]` | 0.02195600332 | 0.02199380509 | 1.722e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[643]` | 0.02032696525 | 0.02034103358 | 6.921e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[644]` | 0.01548923185 | 0.01547578736 | 8.680e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[645]` | 0.01622745679 | 0.01623585884 | 5.178e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[646]` | 0.01935886586 | 0.01939427544 | 1.829e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[647]` | 0.01527295106 | 0.01529449917 | 1.411e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[648]` | 0.01712348567 | 0.01709012127 | 1.948e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[649]` | 0.0203606539 | 0.02035938992 | 6.208e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[650]` | 0.01852130416 | 0.01852302562 | 9.294e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[651]` | 0.02315432079 | 0.02319463987 | 1.741e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[652]` | 0.01935954853 | 0.01935396357 | 2.885e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[653]` | 0.0151051435 | 0.01510490996 | 1.546e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[654]` | 0.01645976084 | 0.01646753377 | 4.722e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[655]` | 0.0222909347 | 0.02230012962 | 4.125e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[656]` | 0.01810743905 | 0.01812158246 | 7.811e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[657]` | 0.01450381639 | 0.01449310726 | 7.384e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[658]` | 0.01807401157 | 0.01807445931 | 2.477e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[659]` | 0.01780564468 | 0.01782471915 | 1.071e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[660]` | 0.01787472363 | 0.01786771959 | 3.918e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[661]` | 0.01243621208 | 0.01243231727 | 3.132e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[662]` | 0.01814072349 | 0.01815347988 | 7.032e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[663]` | 0.01714490021 | 0.017152096 | 4.197e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[664]` | 0.01603895292 | 0.01604104638 | 1.305e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[665]` | 0.01722655107 | 0.01721396645 | 7.305e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[666]` | 0.01766747217 | 0.01765428983 | 7.461e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[667]` | 0.01712598366 | 0.01713413258 | 4.758e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[668]` | 0.01778155323 | 0.01778312817 | 8.857e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[669]` | 0.01427624623 | 0.01427810761 | 1.304e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[670]` | 0.01605858125 | 0.01603709912 | 1.338e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[671]` | 0.02298807823 | 0.02301747422 | 1.279e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[672]` | 0.01628874205 | 0.01625060198 | 2.341e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[673]` | 0.01780992187 | 0.01777960294 | 1.702e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[674]` | 0.01749357032 | 0.01751124872 | 1.011e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[675]` | 0.02179628137 | 0.02176938785 | 1.234e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[676]` | 0.01659003136 | 0.01655775223 | 1.946e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[677]` | 0.02139430443 | 0.02140915329 | 6.941e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[678]` | 0.02000120991 | 0.02000060218 | 3.038e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[679]` | 0.02281244601 | 0.02275624162 | 2.464e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[680]` | 0.02107670751 | 0.02108336477 | 3.159e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[681]` | 0.01715186219 | 0.01717882722 | 1.572e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[682]` | 0.02256564116 | 0.02257961463 | 6.192e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[683]` | 0.01469956909 | 0.01467932546 | 1.377e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[684]` | 0.02031494259 | 0.02031509196 | 7.352e-06 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[685]` | 0.01780882467 | 0.01780118034 | 4.292e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[686]` | 0.01635971137 | 0.01635757796 | 1.304e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[687]` | 0.01492141926 | 0.01492893681 | 5.038e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[688]` | 0.01639603437 | 0.01641051032 | 8.829e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[689]` | 0.01670907542 | 0.01671624067 | 4.288e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[690]` | 0.01766452261 | 0.01765767172 | 3.878e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[691]` | 0.01794669361 | 0.01794992589 | 1.801e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[692]` | 0.01972090193 | 0.01970057005 | 1.031e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[693]` | 0.01773062194 | 0.01774209603 | 6.471e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[694]` | 0.01572610084 | 0.01573246909 | 4.049e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[695]` | 0.01979910758 | 0.01981657193 | 8.821e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[696]` | 0.02002340376 | 0.02003278513 | 4.685e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[697]` | 0.01803409132 | 0.01803978741 | 3.159e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[698]` | 0.01469555869 | 0.01471178735 | 1.104e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[699]` | 0.01598793846 | 0.01598121011 | 4.208e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[700]` | 0.01268528775 | 0.0126834726 | 1.431e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[701]` | 0.02252022454 | 0.02253006908 | 4.371e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[702]` | 0.02037265151 | 0.02036597066 | 3.279e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[703]` | 0.01344081063 | 0.01344696449 | 4.578e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[704]` | 0.01848149855 | 0.01846744023 | 7.607e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[705]` | 0.01877282289 | 0.01878463065 | 6.290e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[706]` | 0.01888608044 | 0.01888429766 | 9.440e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[707]` | 0.02104556868 | 0.02102630671 | 9.153e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[708]` | 0.01856604657 | 0.01859983099 | 1.820e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[709]` | 0.01828085801 | 0.01829221312 | 6.211e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[710]` | 0.01923935138 | 0.01922475661 | 7.586e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[711]` | 0.01757514645 | 0.01755292135 | 1.265e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[712]` | 0.02180181066 | 0.02181212574 | 4.731e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[713]` | 0.01371685103 | 0.01372936947 | 9.126e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[714]` | 0.01817317399 | 0.01819218276 | 1.046e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[715]` | 0.015624264 | 0.01563654685 | 7.861e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[716]` | 0.00986185807 | 0.009865292968 | 3.483e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[717]` | 0.02149289975 | 0.02150436085 | 5.333e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[718]` | 0.01805583289 | 0.01804732134 | 4.714e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[719]` | 0.01804282871 | 0.01804683866 | 2.222e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[720]` | 0.01616920617 | 0.01618036284 | 6.900e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[721]` | 0.01839932394 | 0.01837380022 | 1.387e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[722]` | 0.0153971952 | 0.01539485103 | 1.522e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[723]` | 0.01752763208 | 0.01751425255 | 7.633e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[724]` | 0.01820455804 | 0.01823052974 | 1.427e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[725]` | 0.01329072946 | 0.0133018337 | 8.355e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[726]` | 0.01861874073 | 0.01859441633 | 1.306e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[727]` | 0.01487144513 | 0.01485854184 | 8.677e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[728]` | 0.01684182956 | 0.01684797224 | 3.647e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[729]` | 0.01625996884 | 0.01625923873 | 4.490e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[730]` | 0.01718703632 | 0.01717904437 | 4.650e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[731]` | 0.01755174798 | 0.01754348184 | 4.710e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[732]` | 0.01975544853 | 0.01972614651 | 1.483e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[733]` | 0.01554524133 | 0.01554228857 | 1.899e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[734]` | 0.01557166838 | 0.01556032506 | 7.285e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[735]` | 0.01847852897 | 0.01845947957 | 1.031e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[736]` | 0.02129094736 | 0.02128543275 | 2.590e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[737]` | 0.01624241691 | 0.01621246689 | 1.844e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[738]` | 0.01332314127 | 0.01332898494 | 4.386e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[739]` | 0.01997057305 | 0.01995600084 | 7.297e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[740]` | 0.0227043905 | 0.022693593 | 4.756e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[741]` | 0.02016653694 | 0.02015742928 | 4.516e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[742]` | 0.02433231916 | 0.02435026778 | 7.376e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[743]` | 0.0177056813 | 0.01769457616 | 6.272e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[744]` | 0.01600055835 | 0.01600338022 | 1.764e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[745]` | 0.01934718679 | 0.01932086231 | 1.361e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[746]` | 0.01623822879 | 0.01624405406 | 3.587e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[747]` | 0.01816871174 | 0.01816501973 | 2.032e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[748]` | 0.02130358971 | 0.02129946982 | 1.934e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[749]` | 0.02263992328 | 0.02264178861 | 8.239e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[750]` | 0.0154389976 | 0.01544943498 | 6.760e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[751]` | 0.02150919312 | 0.02152421313 | 6.983e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[752]` | 0.02364200966 | 0.02364896288 | 2.941e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[753]` | 0.01786305373 | 0.01786263232 | 2.359e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[754]` | 0.01691712207 | 0.01689012713 | 1.596e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[755]` | 0.01834453346 | 0.01833232533 | 6.655e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[756]` | 0.01601439074 | 0.0160131898 | 7.499e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[757]` | 0.02292557012 | 0.02295549251 | 1.305e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[758]` | 0.01897010825 | 0.0189696973 | 2.166e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[759]` | 0.01729254292 | 0.01727874175 | 7.981e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[760]` | 0.01673496783 | 0.01672270426 | 7.328e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[761]` | 0.02239918424 | 0.02239228434 | 3.080e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[762]` | 0.02209365023 | 0.02206714808 | 1.200e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[763]` | 0.02096968621 | 0.02095501464 | 6.997e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[764]` | 0.02471958775 | 0.0246817076 | 1.532e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[765]` | 0.01524374127 | 0.01525161312 | 5.164e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[766]` | 0.01970940934 | 0.01973740386 | 1.420e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[767]` | 0.02082958777 | 0.02085722817 | 1.327e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[768]` | 0.01624123 | 0.01623068549 | 6.492e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[769]` | 0.01922776539 | 0.01920951776 | 9.490e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[770]` | 0.01754138681 | 0.01755850964 | 9.761e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[771]` | 0.02174546422 | 0.02178401368 | 1.773e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[772]` | 0.02097313283 | 0.02096677531 | 3.031e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[773]` | 0.01510387609 | 0.01508956747 | 9.473e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[774]` | 0.01588142104 | 0.01586288397 | 1.167e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[775]` | 0.02096082703 | 0.02093256593 | 1.348e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[776]` | 0.0157873415 | 0.01577012998 | 1.090e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[777]` | 0.01842589027 | 0.01844705723 | 1.149e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[778]` | 0.01958091248 | 0.01958400966 | 1.582e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[779]` | 0.01326227781 | 0.01327571283 | 1.013e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[780]` | 0.01951233157 | 0.01949457599 | 9.100e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[781]` | 0.02059225476 | 0.02056207245 | 1.466e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[782]` | 0.0164133966 | 0.0164181557 | 2.900e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[783]` | 0.01551736005 | 0.01553265076 | 9.854e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[784]` | 0.0184844829 | 0.01849323888 | 4.737e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[785]` | 0.02063205122 | 0.02062358387 | 4.104e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[786]` | 0.0119546914 | 0.01194590852 | 7.347e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[787]` | 0.02173095992 | 0.02173736011 | 2.945e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[788]` | 0.01594019927 | 0.01594569329 | 3.447e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[789]` | 0.01949166867 | 0.01951579852 | 1.238e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[790]` | 0.01950853264 | 0.01949411661 | 7.390e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[791]` | 0.01530945331 | 0.0153169646 | 4.906e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[792]` | 0.01566607007 | 0.0156912086 | 1.605e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[793]` | 0.02098478698 | 0.02094415818 | 1.936e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[794]` | 0.01908057202 | 0.01908101607 | 2.327e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[795]` | 0.02146089448 | 0.0214706738 | 4.557e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[796]` | 0.01659949294 | 0.01660882105 | 5.620e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[797]` | 0.01419316442 | 0.01419404209 | 6.184e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[798]` | 0.01666188301 | 0.01666294723 | 6.387e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[799]` | 0.01882019048 | 0.01882932443 | 4.853e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[800]` | 0.01586972349 | 0.0158650512 | 2.944e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[801]` | 0.01686568684 | 0.01687503942 | 5.545e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[802]` | 0.0172012508 | 0.01717198107 | 1.702e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[803]` | 0.01725085667 | 0.01723883157 | 6.971e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[804]` | 0.0157993153 | 0.01581636248 | 1.079e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[805]` | 0.01408735431 | 0.01409387547 | 4.629e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[806]` | 0.02209522195 | 0.02207763109 | 7.961e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[807]` | 0.01929186402 | 0.01931452967 | 1.175e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[808]` | 0.0179492072 | 0.01795281856 | 2.012e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[809]` | 0.01440798628 | 0.01440977725 | 1.243e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[810]` | 0.02227358673 | 0.02231934077 | 2.054e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[811]` | 0.01419426349 | 0.01419662479 | 1.664e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[812]` | 0.01278683463 | 0.01280661881 | 1.547e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[813]` | 0.01833398408 | 0.01833635833 | 1.295e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[814]` | 0.02053636514 | 0.02053428634 | 1.012e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[815]` | 0.01861154568 | 0.01862049006 | 4.806e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[816]` | 0.01374488526 | 0.01374838862 | 2.549e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[817]` | 0.01740237152 | 0.0174229556 | 1.183e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[818]` | 0.02338150218 | 0.02334086258 | 1.738e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[819]` | 0.01986659623 | 0.01988195548 | 7.731e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[820]` | 0.02674748515 | 0.02676254404 | 5.630e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[821]` | 0.01316086627 | 0.01316632262 | 4.146e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[822]` | 0.01951811171 | 0.019498541 | 1.003e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[823]` | 0.01885044287 | 0.01885689831 | 3.425e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[824]` | 0.01849047857 | 0.01848215481 | 4.502e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[825]` | 0.01724079689 | 0.01723595681 | 2.807e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[826]` | 0.01862434354 | 0.01865325602 | 1.552e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[827]` | 0.01670618022 | 0.01670016694 | 3.599e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[828]` | 0.01649342654 | 0.01648677444 | 4.033e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[829]` | 0.01466801229 | 0.01466581482 | 1.498e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[830]` | 0.02362690551 | 0.02360098347 | 1.097e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[831]` | 0.01708936478 | 0.01709700825 | 4.473e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[832]` | 0.02038914194 | 0.02037732295 | 5.797e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[833]` | 0.02111404754 | 0.02108971533 | 1.152e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[834]` | 0.02288545281 | 0.02286464344 | 9.093e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[835]` | 0.01785275604 | 0.01786345035 | 5.990e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[836]` | 0.01510679327 | 0.01510749747 | 4.661e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[837]` | 0.01831192859 | 0.01831512898 | 1.748e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[838]` | 0.01523759876 | 0.01524145694 | 2.532e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[839]` | 0.01828173489 | 0.01824878239 | 1.802e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[840]` | 0.01342248097 | 0.01342839603 | 4.407e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[841]` | 0.0180384403 | 0.01805216814 | 7.610e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[842]` | 0.02162405671 | 0.02162799289 | 1.820e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[843]` | 0.01485948636 | 0.01487799972 | 1.246e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[844]` | 0.02171378664 | 0.02171466136 | 4.028e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[845]` | 0.01661131249 | 0.0165964267 | 8.961e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[846]` | 0.01552903961 | 0.01553554445 | 4.189e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[847]` | 0.017756368 | 0.01777404811 | 9.957e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[848]` | 0.01935461351 | 0.01937837673 | 1.228e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[849]` | 0.01554204221 | 0.01552089625 | 1.361e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[850]` | 0.01502371161 | 0.0150219968 | 1.141e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[851]` | 0.01701185822 | 0.01700402682 | 4.603e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[852]` | 0.01509502243 | 0.01510289139 | 5.213e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[853]` | 0.02183170564 | 0.02183718995 | 2.512e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[854]` | 0.01579035552 | 0.01577991285 | 6.613e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[855]` | 0.0165993286 | 0.01661234088 | 7.839e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[856]` | 0.02279883001 | 0.02277262509 | 1.149e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[857]` | 0.02098769193 | 0.02100922887 | 1.026e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[858]` | 0.01707678571 | 0.01708268155 | 3.453e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[859]` | 0.02033338008 | 0.02033430038 | 4.526e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[860]` | 0.01179541483 | 0.01178149553 | 1.180e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[861]` | 0.01205443405 | 0.01206067138 | 5.174e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[862]` | 0.01715299112 | 0.01716457154 | 6.751e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[863]` | 0.01942605523 | 0.01944018038 | 7.271e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[864]` | 0.01801888004 | 0.01799896118 | 1.105e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[865]` | 0.0184845873 | 0.01848481923 | 1.255e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[866]` | 0.01670795004 | 0.01667424238 | 2.017e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[867]` | 0.01816136324 | 0.01818361742 | 1.225e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[868]` | 0.01661731862 | 0.01663340511 | 9.681e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[869]` | 0.01372762726 | 0.01372455688 | 2.237e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[870]` | 0.02283355222 | 0.0228331658 | 1.692e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[871]` | 0.01794493622 | 0.01792466863 | 1.129e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[872]` | 0.01815300741 | 0.01816589819 | 7.101e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[873]` | 0.01585401625 | 0.01585911118 | 3.214e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[874]` | 0.01658355836 | 0.01659347961 | 5.983e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[875]` | 0.02036840343 | 0.02039031273 | 1.076e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[876]` | 0.01461757271 | 0.01462545141 | 5.390e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[877]` | 0.01676653408 | 0.01678680415 | 1.209e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[878]` | 0.01621639802 | 0.01621791083 | 9.329e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[879]` | 0.01972377954 | 0.01970714865 | 8.432e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[880]` | 0.01745888879 | 0.01748965143 | 1.762e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[881]` | 0.02037108573 | 0.02038957972 | 9.079e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[882]` | 0.01463959811 | 0.01463160365 | 5.461e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[883]` | 0.01349031138 | 0.01349265187 | 1.735e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[884]` | 0.02323564144 | 0.02320811588 | 1.185e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[885]` | 0.01557188932 | 0.0155499908 | 1.406e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[886]` | 0.0154271357 | 0.01542591707 | 7.899e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[887]` | 0.02072033685 | 0.02074944959 | 1.405e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[888]` | 0.01795843774 | 0.0179662344 | 4.342e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[889]` | 0.01730116967 | 0.01732291732 | 1.257e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[890]` | 0.02156361665 | 0.02151701378 | 2.161e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[891]` | 0.01780130338 | 0.01779890763 | 1.346e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[892]` | 0.02134324946 | 0.02132738857 | 7.431e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[893]` | 0.01838763177 | 0.01835378401 | 1.841e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[894]` | 0.01802168551 | 0.01802137377 | 1.730e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[895]` | 0.02125257958 | 0.0212728202 | 9.524e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[896]` | 0.01865607676 | 0.0186848665 | 1.543e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[897]` | 0.01450250656 | 0.01451280578 | 7.102e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[898]` | 0.01646326672 | 0.01646889111 | 3.416e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[899]` | 0.01626023044 | 0.01627784088 | 1.083e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[900]` | 0.01413709676 | 0.01412721797 | 6.988e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[901]` | 0.01870601577 | 0.01870480467 | 6.474e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[902]` | 0.0180773422 | 0.01808152338 | 2.313e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[903]` | 0.02071271083 | 0.02072672242 | 6.765e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[904]` | 0.01810974076 | 0.01811906124 | 5.147e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[905]` | 0.01745112659 | 0.0174229212 | 1.616e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[906]` | 0.01685287419 | 0.01683074283 | 1.313e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[907]` | 0.01964811105 | 0.01964594922 | 1.100e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[908]` | 0.01658078659 | 0.01659999924 | 1.159e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[909]` | 0.01870418378 | 0.01873032357 | 1.398e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[910]` | 0.01773846072 | 0.01772241432 | 9.046e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[911]` | 0.0244709365 | 0.02447566666 | 1.933e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[912]` | 0.02206952334 | 0.0220226685 | 2.123e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[913]` | 0.02093350569 | 0.02094128909 | 3.718e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[914]` | 0.01796194009 | 0.01798619318 | 1.350e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[915]` | 0.01852170484 | 0.01849469416 | 1.458e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[916]` | 0.02205207964 | 0.02206315135 | 5.021e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[917]` | 0.01891022609 | 0.01887503939 | 1.861e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[918]` | 0.0167463095 | 0.01673294271 | 7.982e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[919]` | 0.01575715821 | 0.01576982673 | 8.040e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[920]` | 0.0135108308 | 0.0135046376 | 4.584e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[921]` | 0.02312378026 | 0.02317619796 | 2.267e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[922]` | 0.02220584804 | 0.02216611875 | 1.789e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[923]` | 0.0207797961 | 0.02079576451 | 7.685e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[924]` | 0.01766570681 | 0.01767508438 | 5.308e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[925]` | 0.01916975233 | 0.01915340373 | 8.528e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[926]` | 0.01870948238 | 0.01872080418 | 6.051e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[927]` | 0.01556190409 | 0.0155764579 | 9.352e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[928]` | 0.02095837852 | 0.02097553352 | 8.185e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[929]` | 0.01930061108 | 0.01931151326 | 5.649e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[930]` | 0.01334846367 | 0.01333955688 | 6.673e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[931]` | 0.02054550001 | 0.02052142539 | 1.172e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[932]` | 0.02208045255 | 0.02210132447 | 9.453e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[933]` | 0.02040035956 | 0.0204120646 | 5.738e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[934]` | 0.0149171837 | 0.01493561911 | 1.236e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[935]` | 0.01592661973 | 0.01594173687 | 9.492e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[936]` | 0.01766068256 | 0.01764264155 | 1.022e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[937]` | 0.0206963664 | 0.02073330686 | 1.785e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[938]` | 0.01652899289 | 0.01651053611 | 1.117e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[939]` | 0.01611803968 | 0.01612360657 | 3.454e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[940]` | 0.01922466587 | 0.01921373229 | 5.687e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[941]` | 0.01765568737 | 0.01761110649 | 2.525e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[942]` | 0.0151253412 | 0.01510564678 | 1.302e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[943]` | 0.02099607648 | 0.02102274506 | 1.270e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[944]` | 0.02076130515 | 0.02074596791 | 7.387e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[945]` | 0.01882571839 | 0.01878968867 | 1.914e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[946]` | 0.02033432411 | 0.02035885299 | 1.206e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[947]` | 0.02303589674 | 0.02303976739 | 1.680e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[948]` | 0.01608732869 | 0.0161139844 | 1.657e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[949]` | 0.01900427448 | 0.0190060748 | 9.473e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[950]` | 0.01903639607 | 0.01901044326 | 1.363e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[951]` | 0.01586649253 | 0.01586791793 | 8.984e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[952]` | 0.02179783037 | 0.02180498612 | 3.283e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[953]` | 0.01428411361 | 0.01427799917 | 4.281e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[954]` | 0.01995024518 | 0.01994735577 | 1.448e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[955]` | 0.01776182018 | 0.01776749963 | 3.198e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[956]` | 0.02162520042 | 0.02161621696 | 4.154e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[957]` | 0.01542926513 | 0.01542672825 | 1.644e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[958]` | 0.01667736233 | 0.01666377572 | 8.147e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[959]` | 0.01846420657 | 0.01845544727 | 4.744e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[960]` | 0.0167879646 | 0.01679574048 | 4.632e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[961]` | 0.020701496 | 0.02067984504 | 1.046e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[962]` | 0.01443336738 | 0.01444075751 | 5.120e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[963]` | 0.01768933664 | 0.01768991768 | 3.285e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[964]` | 0.01186036748 | 0.01186707608 | 5.656e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[965]` | 0.02026420349 | 0.02023228736 | 1.575e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[966]` | 0.01587387043 | 0.01587057733 | 2.075e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[967]` | 0.0205963317 | 0.0205781617 | 8.822e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[968]` | 0.01419016653 | 0.01416011482 | 2.118e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[969]` | 0.01320280792 | 0.01319867106 | 3.133e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[970]` | 0.02049417685 | 0.02048706639 | 3.470e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[971]` | 0.01612441167 | 0.01614177408 | 1.077e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[972]` | 0.01685433151 | 0.01685603286 | 1.009e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[973]` | 0.01934826167 | 0.01935614833 | 4.076e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[974]` | 0.01905352779 | 0.01903039652 | 1.214e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[975]` | 0.01789020166 | 0.01787880438 | 6.371e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[976]` | 0.02350584636 | 0.02348529237 | 8.744e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[977]` | 0.01936334496 | 0.01934556138 | 9.184e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[978]` | 0.01946562452 | 0.01948503266 | 9.970e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[979]` | 0.01541863544 | 0.01541667158 | 1.274e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[980]` | 0.01718949261 | 0.01719237564 | 1.677e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[981]` | 0.01616839667 | 0.01615473943 | 8.447e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[982]` | 0.01557662068 | 0.01559386115 | 1.107e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[983]` | 0.01852358047 | 0.01854981995 | 1.417e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[984]` | 0.01777897453 | 0.01778384462 | 2.739e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[985]` | 0.01764993235 | 0.0176626578 | 7.210e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[986]` | 0.01696308966 | 0.01696802115 | 2.907e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[987]` | 0.01623264846 | 0.01624794415 | 9.423e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[988]` | 0.01937959935 | 0.01937325631 | 3.273e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[989]` | 0.01893457259 | 0.01894254615 | 4.211e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[990]` | 0.01392731348 | 0.01393208842 | 3.428e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[991]` | 0.0223550525 | 0.02232384525 | 1.396e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[992]` | 0.01689938252 | 0.0168886438 | 6.355e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[993]` | 0.02079353574 | 0.02078988286 | 1.757e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[994]` | 0.02143600476 | 0.02142922642 | 3.162e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[995]` | 0.02082834752 | 0.02085126638 | 1.100e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[996]` | 0.01999793694 | 0.01999973099 | 8.971e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[997]` | 0.01641560746 | 0.01642431849 | 5.307e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[998]` | 0.01525481971 | 0.01524946137 | 3.513e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$sigma_boot[999]` | 0.01553369426 | 0.01555227553 | 1.196e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[1999]` | 2.637578363 | 2.637578363 | 1.953e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2000]` | 1.926058653 | 1.926058653 | 1.948e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2001]` | 1.448118659 | 1.448118659 | 5.367e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2002]` | 0.0561403315 | 0.0561403315 | 8.528e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2003]` | 0.165148893 | 0.165148893 | 3.529e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2004]` | 5.453608967 | 5.453608967 | 3.094e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2005]` | 1.383231908 | 1.383231908 | 1.445e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2007]` | 0.4558266981 | 0.4558266981 | 4.019e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2008]` | 1.738772223 | 1.738772223 | 8.684e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2009]` | 0.9449997269 | 0.9449997269 | 3.360e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2010]` | 0.5575531097 | 0.5575531097 | 3.803e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2011]` | 0.5711013625 | 0.5711013625 | 4.471e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2012]` | 0.2459982529 | 0.2459982529 | 2.078e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2013]` | 0.05315797569 | 0.05315797569 | 4.073e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2014]` | 0.3829324155 | 0.3829324155 | 1.000e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2015]` | 3.447523212 | 3.447523212 | 2.447e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2016]` | 1.012882501 | 1.012882501 | 1.315e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2017]` | 3.085566729 | 3.085566729 | 4.203e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2018]` | 0.01621385719 | 0.01621385719 | 1.650e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2019]` | 0.3375966553 | 0.3375966553 | 3.124e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2020]` | 4.998879207 | 4.998879207 | 2.576e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2021]` | 0.08187909467 | 0.08187909467 | 2.220e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2022]` | 2.109481953 | 2.109481953 | 1.116e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2023]` | 0.1578660845 | 0.1578660845 | 1.315e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2024]` | 0.003998806292 | 0.003998806292 | 2.516e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2025]` | 0.5630486553 | 0.5630486553 | 7.493e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2026]` | 0.06128419644 | 0.06128419644 | 8.118e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2027]` | 3.283301786 | 3.283301786 | 3.381e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2028]` | 4.902910604 | 4.902910604 | 2.536e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2029]` | 0.273194696 | 0.273194696 | 2.479e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2030]` | 3.396404562 | 3.396404562 | 1.739e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2031]` | 0.1145430336 | 0.1145430336 | 1.042e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2032]` | 5.658547137 | 5.658547137 | 8.476e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2033]` | 1.414673519 | 1.414673519 | 2.982e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2034]` | 0.463239378 | 0.463239378 | 3.235e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2035]` | 0.09261422334 | 0.09261422334 | 1.498e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2036]` | 0.01529318393 | 0.01529318393 | 1.713e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2037]` | 1.928987594 | 1.928987594 | 6.400e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2038]` | 0.003624625394 | 0.003624625394 | 5.262e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2039]` | 0.0001721470292 | 0.0001721470292 | 1.698e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2040]` | 1.774606666 | 1.774606666 | 2.265e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2041]` | 3.019973489 | 3.019973489 | 4.338e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2042]` | 0.09508623732 | 0.09508623732 | 2.437e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2043]` | 0.01741312508 | 0.01741312508 | 1.395e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2044]` | 0.2405023769 | 0.2405023769 | 1.916e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2045]` | 0.04046637133 | 0.04046637133 | 3.772e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2046]` | 0.197578826 | 0.197578826 | 3.470e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2047]` | 1.131165343 | 1.131165343 | 7.950e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2048]` | 0.006517835495 | 0.006517835495 | 2.729e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2049]` | 0.1904224004 | 0.1904224004 | 1.953e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2050]` | 2.532124087 | 2.532124087 | 1.087e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2051]` | 0.0696349599 | 0.0696349599 | 3.209e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2052]` | 0.8083050781 | 0.8083050781 | 4.807e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2053]` | 0.06436935404 | 0.06436935404 | 2.128e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2054]` | 1.036615606 | 1.036615606 | 3.813e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2055]` | 1.242826316 | 1.242826316 | 3.555e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2056]` | 3.729522948 | 3.729522948 | 9.526e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2057]` | 1.720962043 | 1.720962043 | 6.193e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2058]` | 1.87222346 | 1.87222346 | 1.649e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2059]` | 0.03409954675 | 0.03409954675 | 1.616e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2060]` | 0.04786309636 | 0.04786309636 | 5.074e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2061]` | 0.08171512172 | 0.08171512172 | 5.350e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2062]` | 0.0005316267814 | 0.0005316267814 | 8.068e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2063]` | 0.2860038586 | 0.2860038586 | 9.200e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2064]` | 1.079605832 | 1.079605832 | 1.851e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2065]` | 0.2767238317 | 0.2767238317 | 3.892e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2066]` | 0.374107582 | 0.374107582 | 4.214e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2067]` | 1.283090072 | 1.283090072 | 5.365e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2068]` | 0.5000350377 | 0.5000350377 | 4.441e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2069]` | 9.154178484 | 9.154178484 | 4.851e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2070]` | 0.1844400151 | 0.1844400151 | 4.003e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2071]` | 1.03911298 | 1.03911298 | 3.846e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2072]` | 0.03834386523 | 0.03834386523 | 4.350e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2073]` | 1.57580457 | 1.57580457 | 1.113e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2074]` | 1.112745427 | 1.112745427 | 8.780e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2075]` | 4.359149756 | 4.359149756 | 2.038e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2076]` | 0.2790528273 | 0.2790528273 | 3.183e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2077]` | 0.009183796809 | 0.009183796809 | 7.367e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2078]` | 0.006397790488 | 0.006397790488 | 5.329e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2079]` | 1.184067084 | 1.184067084 | 1.238e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2080]` | 0.7217134267 | 0.7217134267 | 1.384e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2081]` | 0.1129462722 | 0.1129462722 | 1.106e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2082]` | 0.002675840926 | 0.002675840926 | 6.483e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2083]` | 0.04827312976 | 0.04827312976 | 1.368e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2084]` | 5.948694804 | 5.948694804 | 6.420e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2085]` | 0.5138377308 | 0.5138377308 | 5.661e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2086]` | 1.118783288 | 1.118783288 | 5.756e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2087]` | 0.08192413554 | 0.08192413554 | 2.964e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2088]` | 5.503883977 | 5.503883977 | 1.130e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2089]` | 1.341357545 | 1.341357545 | 4.039e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2090]` | 0.8567594084 | 0.8567594084 | 5.443e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2091]` | 3.329207943 | 3.329207943 | 3.602e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2092]` | 0.004359978192 | 0.004359978192 | 2.075e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2093]` | 0.0434765979 | 0.0434765979 | 1.030e-11 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2094]` | 0.227614229 | 0.227614229 | 5.621e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2095]` | 0.06177006808 | 0.06177006808 | 5.235e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2096]` | 1.65556675 | 1.65556675 | 4.560e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2097]` | 2.200581919 | 2.200581919 | 4.642e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2098]` | 0.0160813491 | 0.0160813491 | 7.983e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2099]` | 2.915297106 | 2.915297106 | 5.149e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2100]` | 2.934310764 | 2.934310764 | 7.567e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2101]` | 0.1380262644 | 0.1380262644 | 3.258e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2102]` | 0.5362401652 | 0.5362401652 | 1.284e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2103]` | 0.7682378861 | 0.7682378861 | 2.095e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2104]` | 1.922101568 | 1.922101568 | 4.621e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2105]` | 0.3164604239 | 0.3164604239 | 2.087e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2106]` | 0.5610769861 | 0.5610769861 | 1.761e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2107]` | 0.4537595871 | 0.4537595871 | 4.306e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2108]` | 0.1460644564 | 0.1460644564 | 3.990e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2109]` | 0.03179423356 | 0.03179423356 | 3.361e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2110]` | 1.832603247 | 1.832603247 | 2.666e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2111]` | 1.135156334 | 1.135156334 | 3.482e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2112]` | 2.544224301 | 2.544224301 | 1.588e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2113]` | 1.610943455 | 1.610943455 | 1.351e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2114]` | 2.879421083 | 2.879421083 | 3.455e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2115]` | 0.1347599225 | 0.1347599225 | 4.057e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2116]` | 0.01043765358 | 0.01043765358 | 2.980e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2117]` | 0.1637392615 | 0.1637392615 | 4.717e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2118]` | 0.000171430748 | 0.000171430748 | 1.606e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2119]` | 0.001085308249 | 0.001085308249 | 1.538e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2120]` | 0.1234172369 | 0.1234172369 | 4.130e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2121]` | 5.470945131 | 5.470945131 | 1.623e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2122]` | 4.080167556 | 4.080167556 | 5.442e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2123]` | 1.765605693 | 1.765605693 | 5.030e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2125]` | 0.5049216453 | 0.5049216453 | 1.517e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2126]` | 0.9440021356 | 0.9440021356 | 2.117e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2127]` | 2.682877382 | 2.682877382 | 7.449e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2128]` | 0.05675034438 | 0.05675034438 | 1.770e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2129]` | 0.7159205621 | 0.7159205621 | 2.993e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2130]` | 1.607437082 | 1.607437082 | 5.525e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2131]` | 8.822408035 | 8.822408035 | 5.235e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2132]` | 1.830879503 | 1.830879503 | 7.188e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2133]` | 0.1937779458 | 0.1937779458 | 6.589e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2134]` | 0.5409991603 | 0.5409991603 | 2.093e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2135]` | 0.06653318967 | 0.06653318967 | 4.485e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2136]` | 0.3707241633 | 0.3707241633 | 5.241e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2137]` | 0.5432604215 | 0.5432604215 | 7.091e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2138]` | 0.5040679277 | 0.5040679277 | 3.854e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2139]` | 0.01803008205 | 0.01803008205 | 1.951e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2140]` | 0.4246460057 | 0.4246460057 | 1.948e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2141]` | 1.450309096 | 1.450309096 | 9.799e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2142]` | 1.123112953 | 1.123112953 | 4.290e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2143]` | 1.551096993 | 1.551096993 | 1.789e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2144]` | 2.370195804 | 2.370195804 | 2.192e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2145]` | 11.12270402 | 11.12270402 | 2.236e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2146]` | 0.05781497774 | 0.05781497774 | 4.081e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2147]` | 1.094869844 | 1.094869844 | 1.237e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2148]` | 0.4848005931 | 0.4848005931 | 5.267e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2149]` | 0.4356754618 | 0.4356754618 | 1.529e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2150]` | 0.3295996875 | 0.3295996875 | 3.200e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2151]` | 6.114992319 | 6.114992319 | 4.503e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2152]` | 0.1842151476 | 0.1842151476 | 8.889e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2153]` | 0.2692639202 | 0.2692639202 | 7.216e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2154]` | 3.49229694 | 3.49229694 | 3.344e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2155]` | 0.2845808996 | 0.2845808996 | 3.101e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2156]` | 1.253438996 | 1.253438996 | 2.480e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2157]` | 2.127394811 | 2.127394811 | 1.315e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2158]` | 0.9330601076 | 0.9330601076 | 4.284e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2159]` | 2.795064103 | 2.795064103 | 1.589e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2160]` | 0.02187402445 | 0.02187402445 | 1.618e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2161]` | 3.016605384 | 3.016605384 | 1.722e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2162]` | 0.1815363476 | 0.1815363476 | 2.599e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2163]` | 0.761136255 | 0.761136255 | 4.128e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2164]` | 0.2984826497 | 0.2984826497 | 2.566e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2165]` | 1.329416912 | 1.329416912 | 1.587e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2166]` | 0.9386889249 | 0.9386889249 | 4.731e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2167]` | 0.05317604446 | 0.05317604446 | 7.777e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2168]` | 0.06707383947 | 0.06707383947 | 3.952e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2169]` | 1.518743726 | 1.518743726 | 4.532e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2170]` | 7.693677996 | 7.693677996 | 2.309e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2171]` | 0.3696114513 | 0.3696114513 | 3.965e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2172]` | 0.01272039166 | 0.01272039166 | 1.008e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2173]` | 0.2961072962 | 0.2961072962 | 2.006e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2174]` | 0.03501891338 | 0.03501891338 | 1.411e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2175]` | 1.536881346 | 1.536881346 | 6.935e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2176]` | 0.003785160639 | 0.003785160639 | 4.056e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2178]` | 1.269630004 | 1.269630004 | 1.574e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2179]` | 3.811191543 | 3.811191543 | 2.563e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2180]` | 2.027977675 | 2.027977675 | 4.380e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2181]` | 2.571191141 | 2.571191141 | 3.575e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2182]` | 1.860998624 | 1.860998624 | 3.579e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2183]` | 0.004066931726 | 0.004066931726 | 3.344e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2184]` | 0.7447343916 | 0.7447343916 | 2.087e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2185]` | 1.833421253 | 1.833421253 | 2.119e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2186]` | 0.01720633644 | 0.01720633644 | 1.317e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2187]` | 1.525593306 | 1.525593306 | 1.455e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2188]` | 0.9477543731 | 0.9477543731 | 6.935e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2189]` | 6.932520723 | 6.932520723 | 7.175e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2190]` | 0.7712132467 | 0.7712132467 | 1.324e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2191]` | 0.3178709456 | 0.3178709456 | 1.921e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2192]` | 5.394758442 | 5.394758442 | 4.774e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2193]` | 0.3470443094 | 0.3470443094 | 6.414e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2194]` | 3.571091541 | 3.571091541 | 4.962e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2195]` | 0.4814012209 | 0.4814012209 | 7.357e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2196]` | 0.5603042344 | 0.5603042344 | 2.675e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2197]` | 0.2633341356 | 0.2633341356 | 6.809e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2198]` | 0.005470314649 | 0.005470314649 | 2.112e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2200]` | 0.2162593893 | 0.2162593893 | 1.368e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2201]` | 0.127886056 | 0.127886056 | 1.092e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2202]` | 0.0009934132729 | 0.0009934132729 | 3.324e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2203]` | 4.264630228 | 4.264630228 | 2.874e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2204]` | 1.023439237 | 1.023439237 | 4.339e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2205]` | 0.0829905289 | 0.0829905289 | 1.579e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2206]` | 0.01285470561 | 0.01285470561 | 9.042e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2207]` | 0.0005341054128 | 0.0005341054128 | 8.810e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2208]` | 0.007232818724 | 0.007232818724 | 4.470e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2209]` | 0.005341056961 | 0.005341056961 | 4.388e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2210]` | 0.02926333132 | 0.02926333132 | 4.624e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2211]` | 2.707039942 | 2.707039942 | 1.362e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2212]` | 1.337766214 | 1.337766214 | 4.133e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2213]` | 3.753696341 | 3.753696341 | 1.017e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2214]` | 0.2150111535 | 0.2150111535 | 1.317e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2215]` | 0.3517270473 | 0.3517270473 | 2.920e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2216]` | 2.112641217 | 2.112641217 | 6.306e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2217]` | 4.412835609 | 4.412835609 | 5.173e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2218]` | 1.27041273 | 1.27041273 | 3.496e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2219]` | 1.54179315 | 1.54179315 | 1.440e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2220]` | 0.07309342859 | 0.07309342859 | 3.247e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2221]` | 1.990557491 | 1.990557491 | 1.450e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2222]` | 0.504802654 | 0.504802654 | 4.245e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2223]` | 0.1783343375 | 0.1783343375 | 7.782e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2224]` | 1.08856991 | 1.08856991 | 6.935e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2225]` | 2.014245795 | 2.014245795 | 4.872e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2226]` | 0.01798378792 | 0.01798378792 | 2.180e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2227]` | 0.1498017781 | 0.1498017781 | 4.632e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2228]` | 0.2645992599 | 0.2645992599 | 3.566e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2229]` | 1.307900712 | 1.307900712 | 1.070e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2230]` | 2.417531731 | 2.417531731 | 8.634e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2231]` | 0.7061133054 | 0.7061133054 | 4.654e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2232]` | 0.07150960622 | 0.07150960622 | 4.483e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2233]` | 0.8983595385 | 0.8983595385 | 1.570e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2234]` | 1.948410233 | 1.948410233 | 2.678e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2235]` | 0.3823355742 | 0.3823355742 | 5.143e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2236]` | 1.567539447 | 1.567539447 | 5.241e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2237]` | 2.22737931 | 2.22737931 | 9.969e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2238]` | 0.1109087262 | 0.1109087262 | 1.714e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2239]` | 0.2707085242 | 0.2707085242 | 1.107e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2240]` | 0.07210897077 | 0.07210897077 | 4.619e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2241]` | 2.564637302 | 2.564637302 | 4.329e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2242]` | 1.305132532 | 1.305132532 | 4.594e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2243]` | 1.820153699 | 1.820153699 | 2.110e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2244]` | 0.6666982733 | 0.6666982733 | 2.431e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2245]` | 2.734813792 | 2.734813792 | 1.104e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2246]` | 0.5957499867 | 0.5957499867 | 1.323e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2247]` | 3.550930016 | 3.550930016 | 2.101e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2248]` | 1.183545575 | 1.183545575 | 2.702e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2249]` | 0.5488098534 | 0.5488098534 | 1.821e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2250]` | 1.223466936 | 1.223466936 | 4.174e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2251]` | 0.09932250758 | 0.09932250758 | 1.481e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2252]` | 3.243691445 | 3.243691445 | 2.026e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2253]` | 0.4847071471 | 0.4847071471 | 2.279e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2254]` | 1.312879596 | 1.312879596 | 4.397e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2255]` | 0.3471196557 | 0.3471196557 | 6.237e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2256]` | 0.2558950521 | 0.2558950521 | 2.430e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2257]` | 4.141550866 | 4.141550866 | 9.650e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2258]` | 0.0001709181313 | 0.0001709181313 | 3.158e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2259]` | 0.731631049 | 0.731631049 | 8.285e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2260]` | 7.508635635 | 7.508635635 | 1.502e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2261]` | 0.6841012029 | 0.6841012029 | 6.865e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2262]` | 0.04327203615 | 0.04327203615 | 1.193e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2263]` | 2.675795571 | 2.675795571 | 3.801e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2264]` | 0.07882719983 | 0.07882719983 | 6.091e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2265]` | 0.2183207413 | 0.2183207413 | 2.060e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2266]` | 9.769528173 | 9.769528173 | 1.273e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2267]` | 0.8038558251 | 0.8038558251 | 2.526e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2268]` | 1.228193678 | 1.228193678 | 7.412e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2269]` | 2.837079513 | 2.837079513 | 1.409e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2270]` | 0.2470840795 | 0.2470840795 | 1.251e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2271]` | 4.03765214 | 4.03765214 | 2.376e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2272]` | 1.294046116 | 1.294046116 | 1.459e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2273]` | 0.9867699709 | 0.9867699709 | 6.751e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2274]` | 0.0341314931 | 0.0341314931 | 2.779e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2275]` | 2.095726834 | 2.095726834 | 3.179e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2276]` | 0.3205371074 | 0.3205371074 | 6.061e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2277]` | 1.56867978 | 1.56867978 | 4.530e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2278]` | 0.01992964273 | 0.01992964273 | 8.373e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2279]` | 0.05141052646 | 0.05141052646 | 5.844e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2280]` | 1.778135281 | 1.778135281 | 2.123e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2281]` | 0.4864224445 | 0.4864224445 | 2.282e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2282]` | 0.006293433192 | 0.006293433192 | 9.583e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2283]` | 2.927246085 | 2.927246085 | 4.096e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2284]` | 0.05801583832 | 0.05801583832 | 1.038e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2285]` | 9.366464724 | 9.366464724 | 1.138e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2286]` | 0.6091690785 | 0.6091690785 | 5.468e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2287]` | 0.2251417656 | 0.2251417656 | 5.671e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2288]` | 0.5096700207 | 0.5096700207 | 8.713e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2289]` | 0.003378677979 | 0.003378677979 | 4.775e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2290]` | 0.9869478227 | 0.9869478227 | 5.400e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2291]` | 0.8867551765 | 0.8867551765 | 4.132e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2292]` | 0.01954593977 | 0.01954593977 | 1.065e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2293]` | 0.06567294696 | 0.06567294696 | 5.515e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2294]` | 0.000951930349 | 0.000951930349 | 6.210e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2295]` | 0.08240615106 | 0.08240615106 | 6.231e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2296]` | 0.1021989798 | 0.1021989798 | 3.069e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2297]` | 0.4544743876 | 0.4544743876 | 2.443e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2298]` | 0.1029913536 | 0.1029913536 | 7.991e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2299]` | 1.111871476 | 1.111871476 | 1.697e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2300]` | 0.226567803 | 0.226567803 | 4.680e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2301]` | 1.861118667 | 1.861118667 | 4.271e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2302]` | 0.1874547539 | 0.1874547539 | 1.925e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2303]` | 2.851834488 | 2.851834488 | 9.499e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2304]` | 1.608388752 | 1.608388752 | 2.333e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2305]` | 0.02231745009 | 0.02231745009 | 5.363e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2306]` | 0.2395430763 | 0.2395430763 | 1.240e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2307]` | 1.137534774 | 1.137534774 | 8.003e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2308]` | 3.740385738e-07 | 3.740385738e-07 | 1.550e-17 | absolu, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2309]` | 0.2628696676 | 0.2628696676 | 1.183e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2310]` | 1.785295532 | 1.785295532 | 5.846e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2311]` | 0.3373422336 | 0.3373422336 | 1.103e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2312]` | 3.556954386 | 3.556954386 | 1.373e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2313]` | 0.1019590848 | 0.1019590848 | 1.987e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2314]` | 0.5265107129 | 0.5265107129 | 5.103e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2315]` | 1.065278402 | 1.065278402 | 2.668e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2316]` | 0.2771620918 | 0.2771620918 | 2.017e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2317]` | 0.2406589241 | 0.2406589241 | 1.326e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2318]` | 1.352196367 | 1.352196367 | 8.867e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2319]` | 0.1431968589 | 0.1431968589 | 6.590e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2320]` | 1.407448545 | 1.407448545 | 7.415e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2321]` | 3.033269191 | 3.033269191 | 1.903e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2322]` | 1.197160056 | 1.197160056 | 1.280e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2323]` | 0.7565854287 | 0.7565854287 | 1.661e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2324]` | 0.8963779892 | 0.8963779892 | 1.858e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2325]` | 3.962976365 | 3.962976365 | 2.914e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2326]` | 0.03603353775 | 0.03603353775 | 9.917e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2327]` | 1.116678691 | 1.116678691 | 6.960e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2328]` | 1.722752044 | 1.722752044 | 6.135e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2329]` | 1.253615653 | 1.253615653 | 4.251e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2330]` | 2.179252481 | 2.179252481 | 1.243e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2331]` | 0.8061827935 | 0.8061827935 | 9.640e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2332]` | 0.2985067075 | 0.2985067075 | 2.771e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2333]` | 2.44146776 | 2.44146776 | 6.912e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2334]` | 0.3003116213 | 0.3003116213 | 5.028e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2335]` | 0.9461752662 | 0.9461752662 | 7.510e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2336]` | 0.0550862708 | 0.0550862708 | 1.134e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2337]` | 0.005572769533 | 0.005572769533 | 2.252e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2338]` | 0.2243583933 | 0.2243583933 | 6.804e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2339]` | 0.5204350299 | 0.5204350299 | 1.493e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2340]` | 1.51358397 | 1.51358397 | 3.521e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2341]` | 0.06848698874 | 0.06848698874 | 3.850e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2342]` | 0.9653385262 | 0.9653385262 | 2.461e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2343]` | 0.1142999086 | 0.1142999086 | 2.210e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2345]` | 1.72440728 | 1.72440728 | 1.674e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2346]` | 0.7671048251 | 0.7671048251 | 1.896e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2347]` | 1.352458978 | 1.352458978 | 6.403e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2348]` | 0.01862994219 | 0.01862994219 | 9.777e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2349]` | 2.171212468 | 2.171212468 | 3.273e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2350]` | 0.2508125455 | 0.2508125455 | 8.300e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2351]` | 0.01791542477 | 0.01791542477 | 2.000e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2352]` | 0.317985221 | 0.317985221 | 1.566e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2353]` | 0.06666743096 | 0.06666743096 | 8.327e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2355]` | 0.2701699088 | 0.2701699088 | 1.644e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2356]` | 2.488065609 | 2.488065609 | 9.638e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2357]` | 0.9612766037 | 0.9612766037 | 6.814e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2358]` | 1.017941769 | 1.017941769 | 2.225e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2359]` | 1.776776606 | 1.776776606 | 6.249e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2360]` | 0.1226329307 | 0.1226329307 | 5.217e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2361]` | 0.1639044932 | 0.1639044932 | 2.422e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2362]` | 0.5010160246 | 0.5010160246 | 5.274e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2363]` | 0.7005103134 | 0.7005103134 | 7.607e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2364]` | 0.0761309176 | 0.0761309176 | 4.739e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2365]` | 4.600665625 | 4.600665625 | 8.687e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2366]` | 0.4787613784 | 0.4787613784 | 1.449e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2367]` | 0.4583853348 | 0.4583853348 | 6.903e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2369]` | 0.02001910179 | 0.02001910179 | 3.761e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2370]` | 0.4209432157 | 0.4209432157 | 4.352e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2371]` | 0.04730654595 | 0.04730654595 | 3.960e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2372]` | 0.7565140504 | 0.7565140504 | 7.044e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2373]` | 3.60739034 | 3.60739034 | 4.218e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2374]` | 1.20051802 | 1.20051802 | 3.958e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2375]` | 1.74971639 | 1.74971639 | 1.091e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2376]` | 0.4403860893 | 0.4403860893 | 6.731e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2377]` | 2.956699931 | 2.956699931 | 2.794e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2378]` | 0.4046033209 | 0.4046033209 | 1.509e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2379]` | 0.2833279258 | 0.2833279258 | 7.445e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2380]` | 2.005309268 | 2.005309268 | 1.019e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2381]` | 1.040921327e-05 | 1.040921327e-05 | 5.489e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2382]` | 0.003831041733 | 0.003831041733 | 9.407e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2383]` | 1.280279289 | 1.280279289 | 2.081e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2384]` | 2.607435019 | 2.607435019 | 1.192e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2385]` | 0.1262709283 | 0.1262709283 | 7.913e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2386]` | 1.577118686 | 1.577118686 | 9.180e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2387]` | 0.5039249102 | 0.5039249102 | 7.050e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2388]` | 0.07674610483 | 0.07674610483 | 2.750e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2389]` | 0.008779698248 | 0.008779698248 | 3.853e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2390]` | 0.6045828875 | 0.6045828875 | 3.416e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2391]` | 0.2515158329 | 0.2515158329 | 6.621e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2392]` | 0.06069489516 | 0.06069489516 | 1.143e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2393]` | 7.942267354 | 7.942267354 | 5.591e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2394]` | 0.1272335595 | 0.1272335595 | 2.160e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2395]` | 0.1704299124 | 0.1704299124 | 4.071e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2396]` | 1.243157805 | 1.243157805 | 3.304e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2398]` | 0.712590268 | 0.712590268 | 7.011e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2399]` | 0.3612287937 | 0.3612287937 | 3.381e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2400]` | 1.305903167 | 1.305903167 | 1.700e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2401]` | 0.4070228891 | 0.4070228891 | 9.138e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2402]` | 0.4420124482 | 0.4420124482 | 4.345e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2403]` | 1.013243755 | 1.013243755 | 1.337e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2404]` | 0.40013999 | 0.40013999 | 4.023e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2405]` | 0.01576629636 | 0.01576629636 | 4.621e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2406]` | 3.014385113 | 3.014385113 | 2.210e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2407]` | 2.117688686 | 2.117688686 | 7.340e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2408]` | 0.2936650814 | 0.2936650814 | 7.391e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2409]` | 0.00641274822 | 0.00641274822 | 1.380e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2410]` | 0.01330075055 | 0.01330075055 | 1.188e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2411]` | 1.022399173 | 1.022399173 | 3.822e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2412]` | 0.04771142404 | 0.04771142404 | 7.635e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2413]` | 7.090957663 | 7.090957663 | 1.754e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2414]` | 0.3752471825 | 0.3752471825 | 1.953e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2415]` | 2.250672538 | 2.250672538 | 2.565e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2416]` | 1.034455603 | 1.034455603 | 6.010e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2417]` | 0.5092683432 | 0.5092683432 | 3.924e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2418]` | 2.251497284 | 2.251497284 | 8.284e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2419]` | 0.3057823562 | 0.3057823562 | 3.504e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2420]` | 0.1006497284 | 0.1006497284 | 3.902e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2421]` | 1.023616774 | 1.023616774 | 8.243e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2422]` | 3.219384883 | 3.219384883 | 4.966e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2423]` | 0.07061040943 | 0.07061040943 | 2.579e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2424]` | 0.01492000372 | 0.01492000372 | 3.401e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2425]` | 0.5873532619 | 0.5873532619 | 2.155e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2426]` | 0.2285208353 | 0.2285208353 | 9.109e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2427]` | 0.0163573124 | 0.0163573124 | 3.022e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2428]` | 1.903769388 | 1.903769388 | 3.499e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2429]` | 0.07205212821 | 0.07205212821 | 4.565e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2430]` | 3.80306098 | 3.80306098 | 2.335e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2431]` | 0.05875636618 | 0.05875636618 | 1.771e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2432]` | 1.886883377e-06 | 1.886883377e-06 | 5.877e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2433]` | 0.02922973073 | 0.02922973073 | 2.938e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2434]` | 1.287211889 | 1.287211889 | 2.329e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2436]` | 0.03436440146 | 0.03436440146 | 3.574e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2437]` | 8.388821646 | 8.388821646 | 3.600e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2438]` | 0.04510904577 | 0.04510904577 | 1.615e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2439]` | 0.06895724843 | 0.06895724843 | 1.183e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2440]` | 7.82877383 | 7.82877383 | 1.566e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2441]` | 2.941534466 | 2.941534466 | 8.002e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2442]` | 0.6164344312 | 0.6164344312 | 1.063e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2443]` | 0.03135325064 | 0.03135325064 | 1.047e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2444]` | 0.6033801786 | 0.6033801786 | 9.752e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2445]` | 0.476149932 | 0.476149932 | 6.529e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2446]` | 3.357929905 | 3.357929905 | 5.422e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2447]` | 3.084103628 | 3.084103628 | 3.038e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2448]` | 0.001511634478 | 0.001511634478 | 1.003e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2449]` | 0.6187149249 | 0.6187149249 | 1.830e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2450]` | 1.266645708 | 1.266645708 | 6.381e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2451]` | 1.064577436 | 1.064577436 | 2.920e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2452]` | 0.07996652777 | 0.07996652777 | 2.950e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2453]` | 0.4455769388 | 0.4455769388 | 9.207e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2454]` | 0.7853223492 | 0.7853223492 | 9.896e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2455]` | 3.488632666 | 3.488632666 | 7.638e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2456]` | 5.324649352 | 5.324649352 | 1.485e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2457]` | 0.3832171805 | 0.3832171805 | 1.006e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2458]` | 1.292274684 | 1.292274684 | 1.718e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2459]` | 0.3199331127 | 0.3199331127 | 1.256e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2460]` | 2.249720826 | 2.249720826 | 1.777e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2461]` | 0.1590021609 | 0.1590021609 | 4.713e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2462]` | 0.00582454734 | 0.00582454734 | 7.446e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2463]` | 0.007219881258 | 0.007219881258 | 1.079e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2464]` | 0.570094227 | 0.570094227 | 1.363e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2465]` | 1.86735094 | 1.86735094 | 2.735e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2466]` | 0.163683719 | 0.163683719 | 3.731e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2467]` | 0.04976866016 | 0.04976866016 | 7.947e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2468]` | 0.004301400685 | 0.004301400685 | 2.303e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2469]` | 0.2801406299 | 0.2801406299 | 1.565e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2470]` | 0.04022180256 | 0.04022180256 | 4.234e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2471]` | 2.074331307 | 2.074331307 | 2.291e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2472]` | 0.03669204819 | 0.03669204819 | 1.456e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2473]` | 6.408814954 | 6.408814954 | 8.592e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2474]` | 1.984391734 | 1.984391734 | 1.981e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2475]` | 0.5245296251 | 0.5245296251 | 1.672e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2476]` | 0.4122133947 | 0.4122133947 | 2.693e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2479]` | 0.3801686279 | 0.3801686279 | 1.314e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2480]` | 1.223831572 | 1.223831572 | 6.169e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2481]` | 0.07001237443 | 0.07001237443 | 1.017e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2482]` | 0.006421826322 | 0.006421826322 | 2.566e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2483]` | 0.0004708508597 | 0.0004708508597 | 1.808e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2484]` | 1.900408325 | 1.900408325 | 1.227e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2485]` | 3.333147572 | 3.333147572 | 3.997e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2486]` | 0.006242305962 | 0.006242305962 | 1.032e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2487]` | 0.8271464309 | 0.8271464309 | 2.953e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2488]` | 2.138382956 | 2.138382956 | 3.946e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2489]` | 1.084574801 | 1.084574801 | 6.551e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2490]` | 1.591528223 | 1.591528223 | 1.215e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2491]` | 0.009680840094 | 0.009680840094 | 7.419e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2492]` | 1.113796939 | 1.113796939 | 1.196e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2493]` | 0.02360443805 | 0.02360443805 | 7.349e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2494]` | 1.402005467 | 1.402005467 | 4.498e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2495]` | 1.231637978 | 1.231637978 | 7.211e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2496]` | 0.1705125935 | 0.1705125935 | 1.270e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2497]` | 0.1484283114 | 0.1484283114 | 1.760e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2498]` | 0.06254982595 | 0.06254982595 | 3.860e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2499]` | 1.371186671 | 1.371186671 | 2.024e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2500]` | 0.3553798636 | 0.3553798636 | 4.686e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2501]` | 0.0002446382905 | 0.0002446382905 | 6.515e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2502]` | 0.586723781 | 0.586723781 | 5.298e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2503]` | 0.01396240017 | 0.01396240017 | 1.030e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2504]` | 0.1592446407 | 0.1592446407 | 9.970e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2505]` | 0.002713707124 | 0.002713707124 | 1.370e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2506]` | 8.609788495 | 8.609788495 | 1.032e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2507]` | 1.780180517 | 1.780180517 | 1.260e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2508]` | 1.148501825 | 1.148501825 | 2.726e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2509]` | 2.911487539 | 2.911487539 | 9.762e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2510]` | 3.117818274 | 3.117818274 | 3.703e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2511]` | 0.3452402621 | 0.3452402621 | 2.444e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2512]` | 2.155645483 | 2.155645483 | 8.859e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2513]` | 0.6127463497 | 0.6127463497 | 3.732e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2514]` | 2.235665579 | 2.235665579 | 1.192e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2515]` | 0.5395143906 | 0.5395143906 | 8.355e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2516]` | 6.697516875e-05 | 6.697516875e-05 | 1.838e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2517]` | 0.1783113294 | 0.1783113294 | 2.958e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2518]` | 0.1186095433 | 0.1186095433 | 2.605e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2519]` | 0.04635296925 | 0.04635296925 | 3.443e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2520]` | 2.123615467 | 2.123615467 | 1.673e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2521]` | 0.5688882618 | 0.5688882618 | 2.342e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2522]` | 0.0229464149 | 0.0229464149 | 8.316e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2523]` | 0.0124227414 | 0.0124227414 | 1.181e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2524]` | 0.03998077959 | 0.03998077959 | 1.196e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2525]` | 6.611788563 | 6.611788563 | 8.597e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2526]` | 0.4239153231 | 0.4239153231 | 2.200e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2527]` | 1.273702128 | 1.273702128 | 1.918e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2528]` | 0.1857344657 | 0.1857344657 | 2.122e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2529]` | 0.9267372747 | 0.9267372747 | 3.115e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2530]` | 0.0005183405416 | 0.0005183405416 | 8.158e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2531]` | 5.375814742 | 5.375814742 | 4.791e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2532]` | 0.3179947817 | 0.3179947817 | 1.337e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2533]` | 0.4327271143 | 0.4327271143 | 2.950e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2534]` | 0.1652066641 | 0.1652066641 | 3.864e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2535]` | 1.126519771 | 1.126519771 | 4.514e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2536]` | 0.1469901564 | 0.1469901564 | 9.139e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2537]` | 2.72632712 | 2.72632712 | 9.936e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2538]` | 0.0006404638165 | 0.0006404638165 | 5.107e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2539]` | 2.509842102 | 2.509842102 | 6.016e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2540]` | 4.287883133 | 4.287883133 | 1.554e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2541]` | 0.08344537367 | 0.08344537367 | 6.303e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2542]` | 1.210138865 | 1.210138865 | 7.890e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2543]` | 0.1718352728 | 0.1718352728 | 1.938e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2544]` | 0.07811207943 | 0.07811207943 | 1.295e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2545]` | 0.6738744377 | 0.6738744377 | 4.943e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2546]` | 0.4004532885 | 0.4004532885 | 1.316e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2548]` | 0.6017223152 | 0.6017223152 | 5.351e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2549]` | 1.197070648 | 1.197070648 | 9.831e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2550]` | 0.2879759666 | 0.2879759666 | 1.735e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2551]` | 2.744340499 | 2.744340499 | 4.758e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2552]` | 2.019036692 | 2.019036692 | 3.805e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2553]` | 0.3986676161 | 0.3986676161 | 1.281e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2554]` | 6.954274429 | 6.954274429 | 3.193e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2555]` | 2.332972372 | 2.332972372 | 1.904e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2556]` | 0.02021230028 | 0.02021230028 | 2.266e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2557]` | 0.6465939076 | 0.6465939076 | 7.641e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2558]` | 0.08771652162 | 0.08771652162 | 6.645e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2559]` | 0.7287229845 | 0.7287229845 | 2.895e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2560]` | 1.123019498 | 1.123019498 | 1.384e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2561]` | 1.55661935 | 1.55661935 | 1.284e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2562]` | 0.4478781106 | 0.4478781106 | 2.355e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2563]` | 0.2832354767 | 0.2832354767 | 1.052e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2564]` | 6.387943319 | 6.387943319 | 2.503e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2565]` | 7.871821165 | 7.871821165 | 1.388e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2566]` | 0.2341073151 | 0.2341073151 | 3.415e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2567]` | 2.194521152 | 2.194521152 | 2.327e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2568]` | 0.812627724 | 0.812627724 | 5.465e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2569]` | 1.173960453 | 1.173960453 | 3.405e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2570]` | 0.02895919784 | 0.02895919784 | 1.194e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2571]` | 0.1941088522 | 0.1941088522 | 1.401e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2572]` | 1.297702013 | 1.297702013 | 5.646e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2573]` | 0.04853651157 | 0.04853651157 | 1.658e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2574]` | 2.905872113 | 2.905872113 | 4.432e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2575]` | 0.06480462559 | 0.06480462559 | 1.484e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2576]` | 0.3475041106 | 0.3475041106 | 8.434e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2577]` | 0.004481466231 | 0.004481466231 | 1.599e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2578]` | 0.1610127426 | 0.1610127426 | 2.065e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2579]` | 2.257120822 | 2.257120822 | 3.935e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2580]` | 2.115533406 | 2.115533406 | 1.260e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2581]` | 0.04736899926 | 0.04736899926 | 2.930e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2582]` | 0.6323756562 | 0.6323756562 | 2.633e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2583]` | 1.814365879 | 1.814365879 | 5.997e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2584]` | 0.07841110671 | 0.07841110671 | 3.030e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2585]` | 0.2555616321 | 0.2555616321 | 1.673e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2586]` | 0.01843308958 | 0.01843308958 | 2.714e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2587]` | 0.09237253553 | 0.09237253553 | 9.856e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2588]` | 4.035713375 | 4.035713375 | 2.179e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2589]` | 0.5181031201 | 0.5181031201 | 1.179e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2590]` | 2.710578066 | 2.710578066 | 1.475e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2591]` | 0.1810941522 | 0.1810941522 | 1.809e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2592]` | 0.4277116165 | 0.4277116165 | 1.168e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2593]` | 0.06185833112 | 0.06185833112 | 4.341e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2595]` | 0.02261198091 | 0.02261198091 | 2.608e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2596]` | 1.44394622 | 1.44394622 | 2.706e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2597]` | 0.03091195251 | 0.03091195251 | 1.080e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2598]` | 0.03951986106 | 0.03951986106 | 1.159e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2599]` | 0.5689825777 | 0.5689825777 | 9.366e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2600]` | 0.06997605383 | 0.06997605383 | 3.471e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2601]` | 0.08364147073 | 0.08364147073 | 7.682e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2602]` | 3.497724663 | 3.497724663 | 4.825e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2603]` | 1.586992252 | 1.586992252 | 3.120e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2604]` | 0.8898767064 | 0.8898767064 | 5.465e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2605]` | 0.5881083112 | 0.5881083112 | 2.077e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2606]` | 0.410549782 | 0.410549782 | 2.637e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2607]` | 0.06708866289 | 0.06708866289 | 1.427e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2608]` | 0.305269541 | 0.305269541 | 9.092e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2609]` | 0.1383628632 | 0.1383628632 | 9.107e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2610]` | 0.005565572805 | 0.005565572805 | 2.314e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2611]` | 0.8027576641 | 0.8027576641 | 1.231e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2612]` | 0.0006195680361 | 0.0006195680361 | 3.962e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2613]` | 8.917221224 | 8.917221224 | 8.167e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2614]` | 1.540736004 | 1.540736004 | 8.647e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2615]` | 0.3766411913 | 0.3766411913 | 2.417e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2616]` | 0.1417091086 | 0.1417091086 | 8.422e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2617]` | 0.02468565371 | 0.02468565371 | 2.108e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2618]` | 1.084327237 | 1.084327237 | 1.206e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2619]` | 2.054949966 | 2.054949966 | 2.982e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2620]` | 1.392863499 | 1.392863499 | 1.435e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2621]` | 0.8952944542 | 0.8952944542 | 2.183e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2622]` | 0.1751502245 | 0.1751502245 | 1.204e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2623]` | 0.004664828968 | 0.004664828968 | 5.026e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2624]` | 0.3155198892 | 0.3155198892 | 3.484e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2625]` | 1.551797705 | 1.551797705 | 4.835e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2626]` | 0.5865149823 | 0.5865149823 | 1.760e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2627]` | 0.5970524693 | 0.5970524693 | 1.860e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2628]` | 0.08517614079 | 0.08517614079 | 5.377e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2629]` | 4.110549074 | 4.110549074 | 3.803e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2630]` | 0.0153548466 | 0.0153548466 | 6.180e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2631]` | 0.1770334607 | 0.1770334607 | 8.827e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2632]` | 1.365324171 | 1.365324171 | 1.138e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2633]` | 0.6072465845 | 0.6072465845 | 5.851e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2634]` | 1.149214263 | 1.149214263 | 1.101e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2635]` | 0.528766174 | 0.528766174 | 2.373e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2636]` | 1.358629114 | 1.358629114 | 7.518e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2637]` | 0.3590477204 | 0.3590477204 | 2.690e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2638]` | 0.1902527757 | 0.1902527757 | 1.751e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2640]` | 0.1140926272 | 0.1140926272 | 7.736e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2641]` | 0.3490726419 | 0.3490726419 | 1.479e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2642]` | 6.423928508 | 6.423928508 | 6.360e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2643]` | 1.047501449 | 1.047501449 | 3.180e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2644]` | 0.1423710481 | 0.1423710481 | 3.899e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2645]` | 0.008114977939 | 0.008114977939 | 1.165e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2646]` | 0.02798502827 | 0.02798502827 | 1.059e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2647]` | 0.04133717794 | 0.04133717794 | 5.741e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2648]` | 0.07772940386 | 0.07772940386 | 5.410e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2649]` | 3.887347617 | 3.887347617 | 4.227e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2650]` | 0.2088210046 | 0.2088210046 | 2.113e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2651]` | 2.260820603 | 2.260820603 | 1.179e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2652]` | 0.5805285157 | 0.5805285157 | 1.683e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2653]` | 0.03428116264 | 0.03428116264 | 1.235e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2654]` | 1.328714758 | 1.328714758 | 1.588e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2655]` | 0.008014785557 | 0.008014785557 | 2.576e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2656]` | 2.559386686 | 2.559386686 | 6.941e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2657]` | 0.2622542133 | 0.2622542133 | 3.366e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2658]` | 7.975657353 | 7.975657353 | 3.675e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2659]` | 0.2799470432 | 0.2799470432 | 3.946e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2660]` | 0.9700750527 | 0.9700750527 | 1.582e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2661]` | 1.104649361 | 1.104649361 | 2.814e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2662]` | 0.0150792576 | 0.0150792576 | 4.049e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2663]` | 2.560188855 | 2.560188855 | 3.469e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2664]` | 0.300590325 | 0.300590325 | 3.934e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2665]` | 1.61903173 | 1.61903173 | 2.469e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2666]` | 4.816760771 | 4.816760771 | 6.638e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2667]` | 0.06755461266 | 0.06755461266 | 8.299e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2668]` | 1.156747222 | 1.156747222 | 3.647e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2669]` | 0.1902373368 | 0.1902373368 | 2.349e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2670]` | 1.795498331 | 1.795498331 | 2.031e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2671]` | 4.705607268 | 4.705607268 | 3.586e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2672]` | 0.05716822802 | 0.05716822802 | 4.612e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2673]` | 0.1329503898 | 0.1329503898 | 3.257e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2674]` | 2.205019736 | 2.205019736 | 1.263e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2675]` | 0.9110241162 | 0.9110241162 | 6.764e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2676]` | 0.00925711208 | 0.00925711208 | 9.182e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2677]` | 0.07526255985 | 0.07526255985 | 3.120e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2678]` | 5.47057726 | 5.47057726 | 6.494e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2679]` | 0.9922028113 | 0.9922028113 | 1.499e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2680]` | 0.6040723258 | 0.6040723258 | 2.371e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2681]` | 0.3491396634 | 0.3491396634 | 6.487e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2682]` | 0.7427351372 | 0.7427351372 | 1.389e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2683]` | 0.569850085 | 0.569850085 | 7.209e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2684]` | 0.3830033607 | 0.3830033607 | 1.015e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2685]` | 2.876630795 | 2.876630795 | 1.853e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2686]` | 0.4804511502 | 0.4804511502 | 5.065e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2687]` | 1.902300787 | 1.902300787 | 3.268e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2688]` | 0.3608939896 | 0.3608939896 | 1.169e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2689]` | 0.4273605362 | 0.4273605362 | 3.325e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2690]` | 0.2286023173 | 0.2286023173 | 1.008e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2691]` | 0.4778286411 | 0.4778286411 | 5.228e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2692]` | 0.7810996316 | 0.7810996316 | 3.198e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2693]` | 0.14708776 | 0.14708776 | 1.736e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2694]` | 0.0005616476896 | 0.0005616476896 | 2.195e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2695]` | 4.517483639 | 4.517483639 | 7.864e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2696]` | 0.02210638171 | 0.02210638171 | 1.292e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2697]` | 0.0485021068 | 0.0485021068 | 2.003e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2698]` | 0.4262445865 | 0.4262445865 | 1.289e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2699]` | 3.047924709 | 3.047924709 | 1.064e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2700]` | 0.2076744496 | 0.2076744496 | 5.346e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2701]` | 6.612078457 | 6.612078457 | 9.806e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2702]` | 1.474954745 | 1.474954745 | 3.011e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2703]` | 0.3739055445 | 0.3739055445 | 2.123e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2704]` | 0.9084874606 | 0.9084874606 | 5.866e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2705]` | 0.7489355706 | 0.7489355706 | 4.284e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2706]` | 0.1396679786 | 0.1396679786 | 6.240e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2707]` | 3.184848214 | 3.184848214 | 8.366e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2708]` | 1.957362025 | 1.957362025 | 7.487e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2709]` | 4.414560317 | 4.414560317 | 6.237e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2710]` | 1.108867797 | 1.108867797 | 3.044e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2711]` | 0.4342372364 | 0.4342372364 | 3.273e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2712]` | 1.527106255 | 1.527106255 | 1.352e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2713]` | 9.107838391 | 9.107838391 | 2.340e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2714]` | 0.9831368709 | 0.9831368709 | 2.191e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2715]` | 4.002352859 | 4.002352859 | 2.086e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2716]` | 0.4308383229 | 0.4308383229 | 1.495e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2717]` | 1.54614246 | 1.54614246 | 2.585e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2718]` | 0.003614267749 | 0.003614267749 | 9.033e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2719]` | 3.821978025 | 3.821978025 | 3.486e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2720]` | 0.01137986603 | 0.01137986603 | 2.755e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2721]` | 0.3450813202 | 0.3450813202 | 1.400e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2722]` | 0.003751682435 | 0.003751682435 | 3.026e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2723]` | 0.002813747676 | 0.002813747676 | 7.861e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2724]` | 1.392284861 | 1.392284861 | 1.069e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2725]` | 0.04968140493 | 0.04968140493 | 7.207e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2726]` | 0.1918652838 | 0.1918652838 | 2.040e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2727]` | 0.265612999 | 0.265612999 | 1.484e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2728]` | 4.96511709 | 4.96511709 | 2.683e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2729]` | 0.003195798298 | 0.003195798298 | 1.797e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2730]` | 0.005346532241 | 0.005346532241 | 6.504e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2731]` | 2.670611462 | 2.670611462 | 1.014e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2732]` | 2.879865972 | 2.879865972 | 1.542e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2733]` | 2.229809532 | 2.229809532 | 4.780e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2734]` | 1.012169944 | 1.012169944 | 1.316e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2735]` | 0.9682943006 | 0.9682943006 | 1.502e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2736]` | 0.7065098189 | 0.7065098189 | 3.426e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2737]` | 2.12406756 | 2.12406756 | 4.181e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2738]` | 4.49317237 | 4.49317237 | 1.977e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2739]` | 0.03756735536 | 0.03756735536 | 3.325e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2740]` | 0.03665797904 | 0.03665797904 | 9.351e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2741]` | 0.1002579343 | 0.1002579343 | 3.282e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2742]` | 1.233238749 | 1.233238749 | 1.260e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2743]` | 0.2986260244 | 0.2986260244 | 4.238e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2744]` | 1.700610442 | 1.700610442 | 6.528e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2745]` | 0.004275636832 | 0.004275636832 | 1.844e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2746]` | 3.701336539 | 3.701336539 | 4.931e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2747]` | 0.01071222727 | 0.01071222727 | 9.635e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2748]` | 0.0006753751061 | 0.0006753751061 | 5.442e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2749]` | 3.110251871 | 3.110251871 | 5.854e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2750]` | 5.29371425 | 5.29371425 | 1.946e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2751]` | 4.902043605 | 4.902043605 | 5.617e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2752]` | 2.884697966 | 2.884697966 | 1.539e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2753]` | 0.7997258586 | 0.7997258586 | 3.845e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2754]` | 0.5265599507 | 0.5265599507 | 7.801e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2755]` | 2.218917801 | 2.218917801 | 6.004e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2756]` | 0.003556052882 | 0.003556052882 | 1.138e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2757]` | 0.3646345541 | 0.3646345541 | 1.011e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2758]` | 0.2990245874 | 0.2990245874 | 1.795e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2759]` | 0.2793171495 | 0.2793171495 | 5.962e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2760]` | 1.41233535 | 1.41233535 | 1.981e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2761]` | 2.647385125 | 2.647385125 | 1.342e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2762]` | 1.47472377 | 1.47472377 | 2.198e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2763]` | 0.3092707169 | 0.3092707169 | 7.898e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2764]` | 0.008746421189 | 0.008746421189 | 1.361e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2765]` | 0.0594509376 | 0.0594509376 | 5.252e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2766]` | 0.4656540567 | 0.4656540567 | 7.272e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2767]` | 0.2788040937 | 0.2788040937 | 3.982e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2768]` | 3.400307886 | 3.400307886 | 1.084e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2769]` | 6.168276 | 6.168276 | 3.557e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2770]` | 1.444586076 | 1.444586076 | 5.272e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2771]` | 0.009215472764 | 0.009215472764 | 6.287e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2772]` | 0.4180961427 | 0.4180961427 | 4.381e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2773]` | 0.01032713871 | 0.01032713871 | 2.219e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2774]` | 0.2423076975 | 0.2423076975 | 5.956e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2775]` | 1.694300543 | 1.694300543 | 5.675e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2776]` | 4.053928158 | 4.053928158 | 2.191e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2777]` | 0.9564532164 | 0.9564532164 | 3.842e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2778]` | 0.8523656477 | 0.8523656477 | 2.188e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2779]` | 0.3394281837 | 0.3394281837 | 5.888e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2780]` | 0.9391932755 | 0.9391932755 | 2.577e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2781]` | 3.335384471 | 3.335384471 | 1.691e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2782]` | 0.1508879608 | 0.1508879608 | 1.692e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2783]` | 0.04492223663 | 0.04492223663 | 2.626e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2784]` | 0.02294762464 | 0.02294762464 | 2.422e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2785]` | 0.237220165 | 0.237220165 | 5.733e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2786]` | 1.042957027 | 1.042957027 | 1.299e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2787]` | 0.04797520903 | 0.04797520903 | 4.245e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2788]` | 0.4644350715 | 0.4644350715 | 2.761e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2789]` | 0.8078389268 | 0.8078389268 | 6.184e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2790]` | 1.143071221 | 1.143071221 | 1.088e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2791]` | 0.9196703247 | 0.9196703247 | 9.175e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2792]` | 0.1926672362 | 0.1926672362 | 4.235e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2793]` | 0.9213479344 | 0.9213479344 | 3.253e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2794]` | 0.5785882372 | 0.5785882372 | 2.788e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2795]` | 0.0342742996 | 0.0342742996 | 1.466e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2796]` | 0.2641595156 | 0.2641595156 | 3.068e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2797]` | 0.005135575935 | 0.005135575935 | 5.236e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2798]` | 0.5086783789 | 0.5086783789 | 2.183e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2799]` | 0.09292039732 | 0.09292039732 | 6.721e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2800]` | 0.008921668148 | 0.008921668148 | 7.066e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2801]` | 0.2103828663 | 0.2103828663 | 1.596e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2802]` | 2.777394126 | 2.777394126 | 1.759e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2803]` | 0.6244960853 | 0.6244960853 | 3.698e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2804]` | 2.610002447 | 2.610002447 | 1.923e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2805]` | 0.7413760685 | 0.7413760685 | 8.925e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2806]` | 4.08678824 | 4.08678824 | 2.173e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2807]` | 1.730793907 | 1.730793907 | 2.117e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2808]` | 0.002381587268 | 0.002381587268 | 1.666e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2809]` | 1.297683905 | 1.297683905 | 3.422e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2810]` | 0.00304386348 | 0.00304386348 | 7.209e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2811]` | 0.01981208157 | 0.01981208157 | 4.203e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2812]` | 0.213608965 | 0.213608965 | 2.053e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2813]` | 0.02805808033 | 0.02805808033 | 4.291e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2814]` | 2.891387084 | 2.891387084 | 6.144e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2815]` | 0.2719181805 | 0.2719181805 | 1.498e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2816]` | 2.501541504 | 2.501541504 | 7.101e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2817]` | 5.260884793 | 5.260884793 | 8.441e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2818]` | 3.763006559 | 3.763006559 | 6.255e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2819]` | 0.1944459664 | 0.1944459664 | 4.782e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2821]` | 5.102140436 | 5.102140436 | 3.133e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2822]` | 0.07686969322 | 0.07686969322 | 1.419e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2823]` | 0.3066863121 | 0.3066863121 | 4.688e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2824]` | 1.530488342 | 1.530488342 | 1.668e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2825]` | 0.03887948811 | 0.03887948811 | 7.799e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2826]` | 0.4279659454 | 0.4279659454 | 3.450e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2827]` | 1.693606598 | 1.693606598 | 5.507e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2828]` | 1.203595419 | 1.203595419 | 2.952e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2829]` | 0.2729031803 | 0.2729031803 | 1.281e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2830]` | 2.48811602 | 2.48811602 | 1.160e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2831]` | 2.840672829 | 2.840672829 | 5.941e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2832]` | 0.1225811657 | 0.1225811657 | 4.868e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2833]` | 1.089059272 | 1.089059272 | 4.812e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2834]` | 0.1601079916 | 0.1601079916 | 5.374e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2835]` | 0.6427182802 | 0.6427182802 | 8.810e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2836]` | 0.01004605968 | 0.01004605968 | 2.708e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2837]` | 0.25187883 | 0.25187883 | 7.868e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2838]` | 0.002491260998 | 0.002491260998 | 3.100e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2839]` | 0.1520822453 | 0.1520822453 | 1.624e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2840]` | 0.9874162396 | 0.9874162396 | 5.003e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2841]` | 0.05392163137 | 0.05392163137 | 4.223e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2842]` | 0.6162159856 | 0.6162159856 | 1.261e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2843]` | 3.749671897 | 3.749671897 | 4.856e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2844]` | 6.361347372 | 6.361347372 | 6.981e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2845]` | 4.528522186 | 4.528522186 | 2.746e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2846]` | 0.3033716754 | 0.3033716754 | 1.078e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2847]` | 0.0006400969661 | 0.0006400969661 | 7.961e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2848]` | 3.586325289 | 3.586325289 | 3.220e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2849]` | 0.9227012018 | 0.9227012018 | 1.203e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2850]` | 0.8334444093 | 0.8334444093 | 3.557e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2851]` | 0.5947210646 | 0.5947210646 | 1.064e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2852]` | 0.3994736889 | 0.3994736889 | 2.515e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2853]` | 2.254419405 | 2.254419405 | 1.753e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2854]` | 0.7089379835 | 0.7089379835 | 9.396e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2855]` | 0.4714413634 | 0.4714413634 | 1.213e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2856]` | 0.119930927 | 0.119930927 | 6.978e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2857]` | 1.024532169 | 1.024532169 | 2.774e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2858]` | 0.9643260604 | 0.9643260604 | 1.877e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2859]` | 0.2867124589 | 0.2867124589 | 1.255e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2860]` | 0.2747045951 | 0.2747045951 | 3.233e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2861]` | 7.022803396 | 7.022803396 | 2.529e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2862]` | 5.909018971 | 5.909018971 | 3.758e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2863]` | 0.02799300679 | 0.02799300679 | 2.346e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2864]` | 0.1695436184 | 0.1695436184 | 1.637e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2865]` | 0.009493723333 | 0.009493723333 | 5.299e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2866]` | 5.719967838 | 5.719967838 | 4.503e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2867]` | 1.560033195 | 1.560033195 | 9.821e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2868]` | 0.4763221403 | 0.4763221403 | 8.158e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2869]` | 0.1002975764 | 0.1002975764 | 5.756e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2870]` | 0.003951728601 | 0.003951728601 | 2.250e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2871]` | 0.03952330214 | 0.03952330214 | 2.124e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2872]` | 0.001086818694 | 0.001086818694 | 1.949e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2873]` | 0.4754769729 | 0.4754769729 | 6.900e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2874]` | 0.2898523588 | 0.2898523588 | 1.724e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2875]` | 0.1826521048 | 0.1826521048 | 7.294e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2876]` | 0.06510185581 | 0.06510185581 | 3.748e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2877]` | 1.828314054 | 1.828314054 | 6.315e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2878]` | 0.4702838828 | 0.4702838828 | 7.873e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2879]` | 0.03426368362 | 0.03426368362 | 1.190e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2880]` | 0.8051748772 | 0.8051748772 | 3.047e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2881]` | 1.796743939 | 1.796743939 | 4.820e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2882]` | 0.02911746554 | 0.02911746554 | 2.741e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2883]` | 1.437962984 | 1.437962984 | 1.421e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2884]` | 2.129474239 | 2.129474239 | 1.919e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2885]` | 0.5231604763 | 0.5231604763 | 2.483e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2886]` | 0.1658283145 | 0.1658283145 | 5.557e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2887]` | 5.906058426 | 5.906058426 | 1.684e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2888]` | 0.01901451601 | 0.01901451601 | 8.634e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2889]` | 0.2820574933 | 0.2820574933 | 7.872e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2890]` | 2.497557703 | 2.497557703 | 1.120e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2891]` | 0.9658527081 | 0.9658527081 | 7.265e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2892]` | 3.633501755 | 3.633501755 | 2.444e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2893]` | 0.101072518 | 0.101072518 | 1.315e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2894]` | 0.06337752051 | 0.06337752051 | 2.374e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2895]` | 2.421811112 | 2.421811112 | 1.834e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2896]` | 0.1108173624 | 0.1108173624 | 1.966e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2897]` | 3.266478962 | 3.266478962 | 2.692e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2898]` | 0.4019572656 | 0.4019572656 | 2.334e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2899]` | 5.647168978 | 5.647168978 | 4.089e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2900]` | 0.06997642373 | 0.06997642373 | 5.553e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2901]` | 0.1213967165 | 0.1213967165 | 3.635e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2902]` | 0.1449193519 | 0.1449193519 | 4.865e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2903]` | 0.05409169308 | 0.05409169308 | 2.168e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2904]` | 2.465491367 | 2.465491367 | 1.801e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2905]` | 1.637558957 | 1.637558957 | 2.237e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2906]` | 2.012864035 | 2.012864035 | 5.052e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2907]` | 0.4035736885 | 0.4035736885 | 1.761e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2908]` | 0.02597390539 | 0.02597390539 | 3.950e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2909]` | 0.2697761259 | 0.2697761259 | 1.379e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2910]` | 2.809667052 | 2.809667052 | 6.322e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2911]` | 3.378275441 | 3.378275441 | 4.075e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2912]` | 0.5603755301 | 0.5603755301 | 1.743e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2913]` | 5.139069009 | 5.139069009 | 2.437e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2914]` | 4.071710626 | 4.071710626 | 4.166e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2915]` | 0.1933765015 | 0.1933765015 | 2.153e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2916]` | 0.7000938694 | 0.7000938694 | 4.757e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2917]` | 3.11145175 | 3.11145175 | 3.996e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2918]` | 0.1889834872 | 0.1889834872 | 8.812e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2919]` | 0.0425351974 | 0.0425351974 | 2.121e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2920]` | 2.340667542 | 2.340667542 | 3.795e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2921]` | 0.2277555845 | 0.2277555845 | 1.645e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2922]` | 3.622041427 | 3.622041427 | 3.690e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2923]` | 5.979066048 | 5.979066048 | 8.913e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2924]` | 7.365661429 | 7.365661429 | 2.412e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2925]` | 2.259071768 | 2.259071768 | 6.684e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2926]` | 0.1782889207 | 0.1782889207 | 7.192e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2927]` | 0.05100330778 | 0.05100330778 | 1.755e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2928]` | 0.1765130328 | 0.1765130328 | 5.504e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2929]` | 0.5591365708 | 0.5591365708 | 3.475e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2930]` | 2.789783653 | 2.789783653 | 1.273e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2931]` | 0.000652691453 | 0.000652691453 | 7.075e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2932]` | 0.6824399602 | 0.6824399602 | 4.897e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2933]` | 3.000903956 | 3.000903956 | 1.613e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2934]` | 1.557322301 | 1.557322301 | 1.839e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2935]` | 0.4725518551 | 0.4725518551 | 3.172e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2936]` | 2.631372957 | 2.631372957 | 6.413e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2937]` | 2.537385592 | 2.537385592 | 7.001e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2938]` | 1.603796139 | 1.603796139 | 3.600e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2939]` | 0.3148481804 | 0.3148481804 | 2.207e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2940]` | 4.601611699 | 4.601611699 | 3.860e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2941]` | 6.246905785 | 6.246905785 | 5.403e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2942]` | 0.9166210031 | 0.9166210031 | 3.149e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2943]` | 1.140639512 | 1.140639512 | 1.012e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2944]` | 0.1763270328 | 0.1763270328 | 6.737e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2945]` | 0.4946172771 | 0.4946172771 | 6.173e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2946]` | 0.328281703 | 0.328281703 | 1.623e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2947]` | 0.5184870338 | 0.5184870338 | 3.512e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2948]` | 0.002990136856 | 0.002990136856 | 8.659e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2949]` | 0.7320515554 | 0.7320515554 | 7.128e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2951]` | 1.662612686 | 1.662612686 | 8.414e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2952]` | 0.07131396682 | 0.07131396682 | 2.938e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2953]` | 0.1462806732 | 0.1462806732 | 4.554e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2954]` | 0.007899256138 | 0.007899256138 | 2.084e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2955]` | 0.1503822909 | 0.1503822909 | 4.208e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2956]` | 1.129110569 | 1.129110569 | 2.208e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2957]` | 0.001674015826 | 0.001674015826 | 2.127e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2958]` | 2.317392647 | 2.317392647 | 4.408e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2959]` | 1.599334782 | 1.599334782 | 4.165e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2960]` | 4.869882051 | 4.869882051 | 3.283e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2961]` | 0.4140575448 | 0.4140575448 | 1.408e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2962]` | 0.006260470849 | 0.006260470849 | 3.428e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2963]` | 5.656809693 | 5.656809693 | 4.710e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2964]` | 0.01309938017 | 0.01309938017 | 1.552e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2965]` | 0.1065675194 | 0.1065675194 | 4.662e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2966]` | 0.5787572419 | 0.5787572419 | 3.069e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2967]` | 0.04308113102 | 0.04308113102 | 1.691e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2968]` | 6.424549089 | 6.424549089 | 8.295e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2969]` | 1.732133335 | 1.732133335 | 8.076e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2970]` | 0.959310989 | 0.959310989 | 3.125e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2971]` | 1.091400177 | 1.091400177 | 2.604e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2972]` | 6.327194331 | 6.327194331 | 1.123e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2973]` | 0.0003397496643 | 0.0003397496643 | 2.394e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2974]` | 0.05029840721 | 0.05029840721 | 1.931e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2975]` | 0.6351281052 | 0.6351281052 | 5.244e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2976]` | 0.09266556783 | 0.09266556783 | 5.736e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2977]` | 2.95183704 | 2.95183704 | 2.166e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2978]` | 0.01396651593 | 0.01396651593 | 8.210e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2979]` | 0.05348864944 | 0.05348864944 | 2.617e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2980]` | 1.104382894 | 1.104382894 | 6.655e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2981]` | 0.3905993127 | 0.3905993127 | 6.964e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2982]` | 1.418850035 | 1.418850035 | 9.233e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2983]` | 0.0005952443764 | 0.0005952443764 | 4.590e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2984]` | 1.764339171 | 1.764339171 | 3.184e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2986]` | 0.046678951 | 0.046678951 | 4.608e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2987]` | 2.352683922 | 2.352683922 | 8.117e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2988]` | 0.2773318378 | 0.2773318378 | 2.402e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2989]` | 2.154888625 | 2.154888625 | 1.381e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2990]` | 0.5338426775 | 0.5338426775 | 1.111e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2991]` | 0.3869594812 | 0.3869594812 | 1.721e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2992]` | 2.040786611 | 2.040786611 | 1.871e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2993]` | 0.2367384684 | 0.2367384684 | 5.546e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2994]` | 1.116716354 | 1.116716354 | 1.571e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2995]` | 0.3465419064 | 0.3465419064 | 4.037e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2996]` | 3.646897781 | 3.646897781 | 1.583e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[2997]` | 0.4331524444 | 0.4331524444 | 1.217e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[3997]` | 2.488651023 | 2.488651023 | 3.569e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[3998]` | 2.512180986 | 2.512180986 | 1.061e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[3999]` | 2.18975736 | 2.18975736 | 4.056e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4001]` | 2.740338756 | 2.740338756 | 1.621e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4002]` | 2.068997071 | 2.068997071 | 4.293e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4004]` | 2.065068955 | 2.065068955 | 2.150e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4005]` | 2.633309319 | 2.633309319 | 1.686e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4006]` | 2.30215458 | 2.30215458 | 2.508e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4007]` | 2.646684241 | 2.646684241 | 1.678e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4008]` | 1.930692447 | 1.930692447 | 1.035e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4009]` | 1.969191714 | 1.969191714 | 3.383e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4010]` | 1.80105094 | 1.80105094 | 7.397e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4012]` | 1.733448981 | 1.733448981 | 3.074e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4013]` | 2.020887213 | 2.020887213 | 6.592e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4014]` | 2.089295998 | 2.089295998 | 2.126e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4015]` | 2.489441353 | 2.489441353 | 2.854e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4016]` | 2.686955482 | 2.686955482 | 8.264e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4017]` | 2.173364357 | 2.173364357 | 1.226e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4018]` | 2.794623025 | 2.794623025 | 1.589e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4019]` | 2.47919233 | 2.47919233 | 3.583e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4020]` | 2.028151833 | 2.028151833 | 4.379e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4021]` | 1.792587727 | 1.792587727 | 1.363e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4022]` | 2.4459124 | 2.4459124 | 1.816e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4023]` | 1.917051988 | 1.917051988 | 1.274e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4024]` | 2.402009173 | 2.402009173 | 3.698e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4025]` | 2.20327777 | 2.20327777 | 2.217e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4026]` | 1.959713688 | 1.959713688 | 2.266e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4027]` | 3.059902387 | 3.059902387 | 2.903e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4028]` | 1.957898786 | 1.957898786 | 1.815e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4029]` | 1.97102895 | 1.97102895 | 3.380e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4030]` | 2.372178567 | 2.372178567 | 1.872e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4031]` | 1.986345004 | 1.986345004 | 3.354e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4033]` | 2.552353683 | 2.552353683 | 1.740e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4034]` | 2.158459312 | 2.158459312 | 2.057e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4035]` | 3.109009521 | 3.109009521 | 2.714e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4036]` | 2.291031205 | 2.291031205 | 1.745e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4037]` | 2.377378885 | 2.377378885 | 7.472e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4038]` | 2.837175885 | 2.837175885 | 6.261e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4039]` | 2.446917815 | 2.446917815 | 3.630e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4040]` | 2.766234361 | 2.766234361 | 1.605e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4041]` | 2.00913544 | 2.00913544 | 6.631e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4042]` | 2.978572859 | 2.978572859 | 2.982e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4043]` | 2.404528308 | 2.404528308 | 1.847e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4044]` | 2.487385589 | 2.487385589 | 1.071e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4045]` | 2.602353663 | 2.602353663 | 6.826e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4046]` | 2.388781016 | 2.388781016 | 1.859e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4047]` | 1.870733353 | 1.870733353 | 8.309e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4049]` | 1.850504656 | 1.850504656 | 4.800e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4050]` | 2.148957705 | 2.148957705 | 2.067e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4051]` | 2.361983718 | 2.361983718 | 3.760e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4052]` | 2.785118797 | 2.785118797 | 7.973e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4053]` | 1.322520935 | 1.322520935 | 2.015e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4055]` | 2.669914152 | 2.669914152 | 4.990e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4056]` | 2.331225493 | 2.331225493 | 1.905e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4057]` | 2.717352561 | 2.717352561 | 1.634e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4058]` | 2.623562628 | 2.623562628 | 1.693e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4059]` | 2.721351564 | 2.721351564 | 1.305e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4061]` | 2.236867052 | 2.236867052 | 1.390e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4062]` | 2.260679814 | 2.260679814 | 5.893e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4063]` | 2.187694185 | 2.187694185 | 1.015e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4064]` | 2.626597069 | 2.626597069 | 1.184e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4065]` | 1.532993237 | 1.532993237 | 4.345e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4067]` | 1.944211174 | 1.944211174 | 1.142e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4068]` | 2.958730365 | 2.958730365 | 6.004e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4069]` | 2.022346379 | 2.022346379 | 2.635e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4070]` | 2.199955156 | 2.199955156 | 6.056e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4071]` | 2.019748108 | 2.019748108 | 2.199e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4072]` | 2.627306695 | 2.627306695 | 3.381e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4073]` | 1.68081246 | 1.68081246 | 1.321e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4074]` | 2.34844823 | 2.34844823 | 3.782e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4075]` | 2.23492189 | 2.23492189 | 3.974e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4076]` | 2.722136289 | 2.722136289 | 8.157e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4077]` | 2.097485278 | 2.097485278 | 6.352e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4078]` | 2.380753279 | 2.380753279 | 1.865e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4079]` | 2.098686551 | 2.098686551 | 4.232e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4082]` | 2.714446446 | 2.714446446 | 4.908e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4083]` | 2.492124366 | 2.492124366 | 2.673e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4084]` | 2.738000713 | 2.738000713 | 3.244e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4085]` | 2.754554378 | 2.754554378 | 1.612e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4086]` | 2.258466642 | 2.258466642 | 5.899e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4087]` | 2.64099142 | 2.64099142 | 3.363e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4088]` | 1.800669594 | 1.800669594 | 2.466e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4089]` | 2.284917668 | 2.284917668 | 7.774e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4091]` | 1.827070037 | 1.827070037 | 1.666e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4092]` | 2.266069722 | 2.266069722 | 3.919e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4093]` | 2.515023487 | 2.515023487 | 1.766e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4094]` | 2.208619455 | 2.208619455 | 1.810e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4095]` | 2.88481051 | 2.88481051 | 6.158e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4096]` | 3.032113505 | 3.032113505 | 1.465e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4097]` | 2.30338205 | 2.30338205 | 1.735e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4098]` | 2.338700079 | 2.338700079 | 5.697e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4099]` | 2.160088275 | 2.160088275 | 1.028e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4100]` | 1.679647441 | 1.679647441 | 1.322e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4101]` | 2.135362827 | 2.135362827 | 6.239e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4102]` | 1.877211989 | 1.877211989 | 2.366e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4103]` | 2.534016396 | 2.534016396 | 8.763e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4105]` | 2.070850333 | 2.070850333 | 1.501e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4106]` | 2.247610578 | 2.247610578 | 3.952e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4107]` | 2.033243409 | 2.033243409 | 1.747e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4109]` | 2.07117392 | 2.07117392 | 8.577e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4110]` | 2.533636048 | 2.533636048 | 3.506e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4111]` | 1.893632577 | 1.893632577 | 3.518e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4112]` | 1.608559154 | 1.608559154 | 4.141e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4113]` | 2.144861114 | 2.144861114 | 1.863e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4115]` | 2.180848263 | 2.180848263 | 4.887e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4116]` | 2.189816424 | 2.189816424 | 1.420e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4117]` | 2.239710948 | 2.239710948 | 1.785e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4118]` | 2.682557666 | 2.682557666 | 2.152e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4119]` | 2.397634067 | 2.397634067 | 1.852e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4120]` | 1.846075496 | 1.846075496 | 9.983e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4123]` | 2.375293848 | 2.375293848 | 9.348e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4124]` | 2.382242208 | 2.382242208 | 1.864e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4125]` | 1.967521049 | 1.967521049 | 2.257e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4126]` | 1.661977452 | 1.661977452 | 1.737e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4127]` | 2.23765654 | 2.23765654 | 9.923e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4129]` | 2.225702592 | 2.225702592 | 5.986e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4130]` | 3.006958632 | 3.006958632 | 2.511e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4131]` | 2.185224476 | 2.185224476 | 4.064e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4132]` | 2.47431104 | 2.47431104 | 3.590e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4134]` | 3.036838107 | 3.036838107 | 2.925e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4135]` | 2.583497451 | 2.583497451 | 1.203e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4136]` | 2.789279251 | 2.789279251 | 4.776e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4138]` | 2.683231008 | 2.683231008 | 9.930e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4139]` | 2.404375288 | 2.404375288 | 1.847e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4140]` | 2.401867058 | 2.401867058 | 7.396e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4141]` | 1.813338063 | 1.813338063 | 1.225e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4142]` | 2.525147572 | 2.525147572 | 2.286e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4143]` | 2.212237711 | 2.212237711 | 2.007e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4144]` | 2.541116017 | 2.541116017 | 1.748e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4147]` | 2.192438515 | 2.192438515 | 4.051e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4149]` | 2.12029436 | 2.12029436 | 8.378e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4150]` | 1.715680411 | 1.715680411 | 1.424e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4152]` | 2.493842997 | 2.493842997 | 1.959e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4153]` | 2.170592763 | 2.170592763 | 1.023e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4156]` | 1.872890166 | 1.872890166 | 8.299e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4158]` | 2.30744375 | 2.30744375 | 3.849e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4159]` | 2.481699386 | 2.481699386 | 1.074e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4161]` | 2.140616694 | 2.140616694 | 6.224e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4162]` | 2.519563621 | 2.519563621 | 1.763e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4163]` | 2.333718285 | 2.333718285 | 5.709e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4164]` | 2.211367796 | 2.211367796 | 2.008e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4165]` | 1.923585272 | 1.923585272 | 9.235e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4166]` | 2.496665491 | 2.496665491 | 1.779e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4167]` | 2.534899415 | 2.534899415 | 1.752e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4168]` | 2.182858801 | 2.182858801 | 6.103e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4169]` | 1.625892428 | 1.625892428 | 6.828e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4170]` | 2.676475071 | 2.676475071 | 3.816e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4171]` | 2.331871261 | 2.331871261 | 1.904e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4172]` | 2.151357202 | 2.151357202 | 8.257e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4177]` | 2.1540413 | 2.1540413 | 1.855e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4178]` | 2.572346829 | 2.572346829 | 6.906e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4179]` | 2.552187326 | 2.552187326 | 2.088e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4180]` | 1.775792946 | 1.775792946 | 8.753e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4181]` | 2.05051963 | 2.05051963 | 2.599e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4183]` | 1.983153318 | 1.983153318 | 1.568e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4184]` | 2.140459184 | 2.140459184 | 4.149e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4185]` | 2.304039755 | 2.304039755 | 5.782e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4186]` | 2.36694375 | 2.36694375 | 1.313e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4188]` | 2.039988307 | 2.039988307 | 1.742e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4189]` | 2.285924004 | 2.285924004 | 1.943e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4190]` | 2.437845929 | 2.437845929 | 9.108e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4191]` | 2.399573574 | 2.399573574 | 1.851e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4192]` | 1.838286925 | 1.838286925 | 1.087e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4193]` | 2.337796857 | 2.337796857 | 1.520e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4194]` | 1.845080049 | 1.845080049 | 1.203e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4195]` | 2.513197831 | 2.513197831 | 5.301e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4196]` | 1.998346927 | 1.998346927 | 1.333e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4198]` | 1.943998277 | 1.943998277 | 6.168e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4199]` | 2.166361374 | 2.166361374 | 8.815e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4200]` | 2.171189802 | 2.171189802 | 2.045e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4201]` | 2.220419183 | 2.220419183 | 1.000e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4202]` | 2.100742663 | 2.100742663 | 1.268e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4203]` | 2.224956649 | 2.224956649 | 5.988e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4204]` | 2.303024767 | 2.303024767 | 1.928e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4205]` | 1.72855571 | 1.72855571 | 1.285e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4206]` | 2.781428734 | 2.781428734 | 1.134e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4207]` | 2.72191104 | 2.72191104 | 6.526e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4208]` | 1.551347586 | 1.551347586 | 5.725e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4209]` | 2.820339201 | 2.820339201 | 3.149e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4210]` | 1.790006634 | 1.790006634 | 5.458e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4211]` | 1.93971545 | 1.93971545 | 8.013e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4212]` | 2.27129035 | 2.27129035 | 5.866e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4213]` | 3.02134025 | 3.02134025 | 4.410e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4214]` | 2.712949247 | 2.712949247 | 9.822e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4215]` | 2.222003298 | 2.222003298 | 4.397e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4216]` | 2.438774684 | 2.438774684 | 1.821e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4218]` | 2.335321681 | 2.335321681 | 5.705e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4220]` | 2.187912012 | 2.187912012 | 1.015e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4223]` | 2.338341175 | 2.338341175 | 1.709e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4224]` | 2.469552869 | 2.469552869 | 8.991e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4225]` | 2.006039801 | 2.006039801 | 1.107e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4226]` | 2.560729125 | 2.560729125 | 1.734e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4227]` | 2.697649603 | 2.697649603 | 6.585e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4228]` | 2.173258476 | 2.173258476 | 2.043e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4230]` | 2.604042902 | 2.604042902 | 5.116e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4231]` | 2.313920463 | 2.313920463 | 1.727e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4232]` | 1.964693755 | 1.964693755 | 3.730e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4233]` | 2.295639357 | 2.295639357 | 1.741e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4234]` | 2.399161572 | 2.399161572 | 1.296e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4235]` | 1.980669783 | 1.980669783 | 4.484e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4236]` | 2.324080398 | 2.324080398 | 1.529e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4238]` | 2.043342708 | 2.043342708 | 2.173e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4239]` | 2.443283502 | 2.443283502 | 1.818e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4240]` | 2.179385438 | 2.179385438 | 2.038e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4241]` | 2.438298965 | 2.438298965 | 1.821e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4242]` | 2.575572042 | 2.575572042 | 5.173e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4243]` | 2.14625156 | 2.14625156 | 8.277e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4244]` | 2.755127755 | 2.755127755 | 1.612e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4245]` | 3.104648729 | 3.104648729 | 7.152e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4246]` | 2.733195004 | 2.733195004 | 1.950e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4248]` | 2.144803109 | 2.144803109 | 2.071e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4249]` | 2.240965121 | 2.240965121 | 1.982e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4250]` | 1.57842582 | 1.57842582 | 8.440e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4251]` | 2.138554424 | 2.138554424 | 6.230e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4253]` | 2.178261665 | 2.178261665 | 2.039e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4254]` | 2.332203832 | 2.332203832 | 1.904e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4255]` | 2.694170345 | 2.694170345 | 4.945e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4256]` | 2.057700126 | 2.057700126 | 1.727e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4257]` | 1.790950724 | 1.790950724 | 2.232e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4258]` | 2.02533009 | 2.02533009 | 7.236e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4259]` | 1.925791564 | 1.925791564 | 9.224e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4260]` | 2.333725228 | 2.333725228 | 5.709e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4261]` | 2.634691916 | 2.634691916 | 3.371e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4262]` | 2.670978663 | 2.670978663 | 3.325e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4264]` | 2.487445773 | 2.487445773 | 1.785e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4265]` | 2.284917918 | 2.284917918 | 1.944e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4266]` | 2.040968115 | 2.040968115 | 2.176e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4267]` | 1.727012116 | 1.727012116 | 1.800e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4268]` | 2.293290561 | 2.293290561 | 1.743e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4269]` | 2.908294046 | 2.908294046 | 9.162e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4270]` | 2.631825803 | 2.631825803 | 1.687e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4272]` | 2.350405143 | 2.350405143 | 1.889e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4273]` | 2.104651374 | 2.104651374 | 4.220e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4274]` | 2.572636016 | 2.572636016 | 1.726e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4275]` | 2.344905277 | 2.344905277 | 1.894e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4276]` | 2.498469036 | 2.498469036 | 8.887e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4277]` | 1.833860612 | 1.833860612 | 2.422e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4280]` | 2.773771147 | 2.773771147 | 8.005e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4281]` | 1.866252263 | 1.866252263 | 3.569e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4282]` | 2.719581885 | 2.719581885 | 2.286e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4283]` | 1.798891533 | 1.798891533 | 4.937e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4286]` | 2.321087026 | 2.321087026 | 1.913e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4287]` | 2.547007856 | 2.547007856 | 1.744e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4288]` | 2.483731225 | 2.483731225 | 1.788e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4289]` | 2.045470883 | 2.045470883 | 6.513e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4291]` | 1.944863956 | 1.944863956 | 1.142e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4292]` | 2.111606451 | 2.111606451 | 2.734e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4295]` | 2.158402093 | 2.158402093 | 2.057e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4296]` | 2.029734376 | 2.029734376 | 1.094e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4297]` | 2.602430373 | 2.602430373 | 3.413e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4298]` | 2.099112355 | 2.099112355 | 4.231e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4299]` | 2.131577784 | 2.131577784 | 6.250e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4300]` | 2.106408362 | 2.106408362 | 6.325e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4303]` | 2.459386505 | 2.459386505 | 1.806e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4305]` | 2.54595479 | 2.54595479 | 5.233e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4306]` | 2.049088995 | 2.049088995 | 4.335e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4307]` | 2.534633637 | 2.534633637 | 3.504e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4310]` | 2.626570127 | 2.626570127 | 3.382e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4311]` | 2.634706133 | 2.634706133 | 6.742e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4312]` | 2.278770669 | 2.278770669 | 1.364e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4313]` | 2.402452909 | 2.402452909 | 2.218e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4314]` | 2.022192456 | 2.022192456 | 2.855e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4315]` | 2.607448358 | 2.607448358 | 1.703e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4316]` | 2.749309386 | 2.749309386 | 4.846e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4317]` | 1.582186793 | 1.582186793 | 1.403e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4318]` | 2.63290244 | 2.63290244 | 1.687e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4319]` | 2.645858207 | 2.645858207 | 1.678e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4320]` | 2.453302992 | 2.453302992 | 1.810e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4321]` | 1.966998 | 1.966998 | 3.387e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4323]` | 2.68699372 | 2.68699372 | 8.264e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4324]` | 1.909969234 | 1.909969234 | 9.300e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4325]` | 2.129596542 | 2.129596542 | 1.668e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4326]` | 2.140598561 | 2.140598561 | 2.697e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4327]` | 2.105879963 | 2.105879963 | 8.435e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4328]` | 2.114608911 | 2.114608911 | 1.470e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4329]` | 2.181873391 | 2.181873391 | 2.035e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4331]` | 2.132082061 | 2.132082061 | 4.166e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4332]` | 2.57506322 | 2.57506322 | 1.725e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4334]` | 2.561799533 | 2.561799533 | 1.734e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4335]` | 2.089498185 | 2.089498185 | 2.125e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4336]` | 1.922272449 | 1.922272449 | 9.241e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4337]` | 1.973038712 | 1.973038712 | 2.251e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4338]` | 2.899296384 | 2.899296384 | 7.659e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4339]` | 2.954230578 | 2.954230578 | 3.006e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4340]` | 1.612429276 | 1.612429276 | 2.754e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4341]` | 2.762331123 | 2.762331123 | 1.608e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4342]` | 2.690456085 | 2.690456085 | 9.904e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4343]` | 2.486403312 | 2.486403312 | 1.072e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4344]` | 2.275260312 | 2.275260312 | 5.855e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4346]` | 2.87332296 | 2.87332296 | 1.546e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4347]` | 2.433420773 | 2.433420773 | 1.825e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4348]` | 2.493659115 | 2.493659115 | 8.904e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4349]` | 2.911602973 | 2.911602973 | 6.101e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4350]` | 2.715823525 | 2.715823525 | 8.176e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4353]` | 1.3171198 | 1.3171198 | 2.023e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4355]` | 2.524540717 | 2.524540717 | 1.759e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4356]` | 2.083922299 | 2.083922299 | 2.131e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4357]` | 2.31589947 | 2.31589947 | 1.918e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4358]` | 2.081274227 | 2.081274227 | 1.280e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4360]` | 2.496505539 | 2.496505539 | 5.337e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4361]` | 1.614759605 | 1.614759605 | 5.500e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4362]` | 2.441056097 | 2.441056097 | 1.819e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4363]` | 1.98940516 | 1.98940516 | 1.339e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4366]` | 2.173687256 | 2.173687256 | 6.129e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4367]` | 2.145221416 | 2.145221416 | 4.140e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4368]` | 1.739212467 | 1.739212467 | 5.107e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4370]` | 2.505817559 | 2.505817559 | 7.089e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4371]` | 2.307816359 | 2.307816359 | 7.312e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4372]` | 1.741363023 | 1.741363023 | 7.651e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4373]` | 2.449995044 | 2.449995044 | 1.813e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4374]` | 2.488516485 | 2.488516485 | 3.569e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4375]` | 2.937168194 | 2.937168194 | 1.210e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4376]` | 2.138442156 | 2.138442156 | 1.246e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4378]` | 1.949013085 | 1.949013085 | 4.215e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4379]` | 2.170365383 | 2.170365383 | 4.092e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4380]` | 2.107852237 | 2.107852237 | 1.264e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4382]` | 2.477433873 | 2.477433873 | 1.793e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4383]` | 2.588729505 | 2.588729505 | 1.029e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4384]` | 1.849646006 | 1.849646006 | 1.681e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4385]` | 2.122272785 | 2.122272785 | 2.093e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4386]` | 2.735229331 | 2.735229331 | 4.708e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4387]` | 2.707893931 | 2.707893931 | 1.312e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4388]` | 2.820612055 | 2.820612055 | 3.149e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4391]` | 2.307404563 | 2.307404563 | 1.925e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4393]` | 2.859374384 | 2.859374384 | 1.553e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4394]` | 2.417415292 | 2.417415292 | 5.511e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4396]` | 2.157383186 | 2.157383186 | 4.117e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4397]` | 2.838849741 | 2.838849741 | 1.564e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4399]` | 2.348913293 | 2.348913293 | 1.891e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4400]` | 1.75770284 | 1.75770284 | 7.832e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4401]` | 1.907387376 | 1.907387376 | 1.164e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4402]` | 1.874950065 | 1.874950065 | 2.369e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4403]` | 2.101048263 | 2.101048263 | 6.341e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4404]` | 2.613520834 | 2.613520834 | 5.098e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4406]` | 2.427332876 | 2.427332876 | 9.148e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4408]` | 2.236272925 | 2.236272925 | 2.383e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4410]` | 1.948154423 | 1.948154423 | 3.419e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4412]` | 2.229050901 | 2.229050901 | 1.992e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4414]` | 2.277695736 | 2.277695736 | 3.899e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4415]` | 2.061950231 | 2.061950231 | 2.154e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4416]` | 1.952760671 | 1.952760671 | 9.097e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4417]` | 2.551302567 | 2.551302567 | 6.963e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4418]` | 2.652271589 | 2.652271589 | 3.349e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4419]` | 2.429262522 | 2.429262522 | 9.140e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4420]` | 2.026364326 | 2.026364326 | 1.972e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4421]` | 2.550563935 | 2.550563935 | 5.223e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4422]` | 2.042971148 | 2.042971148 | 2.608e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4423]` | 2.571755607 | 2.571755607 | 6.907e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4424]` | 2.262450032 | 2.262450032 | 1.963e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4425]` | 2.716503699 | 2.716503699 | 2.452e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4427]` | 2.26412636 | 2.26412636 | 3.923e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4428]` | 1.780720341 | 1.780720341 | 1.372e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4429]` | 2.280737243 | 2.280737243 | 1.947e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4430]` | 2.151610094 | 2.151610094 | 2.064e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4431]` | 1.558616882 | 1.558616882 | 5.699e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4432]` | 1.814339871 | 1.814339871 | 9.791e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4434]` | 2.464541776 | 2.464541776 | 3.604e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4435]` | 2.658563589 | 2.658563589 | 3.341e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4436]` | 2.492069674 | 2.492069674 | 1.782e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4437]` | 2.500085524 | 2.500085524 | 7.105e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4438]` | 2.27978229 | 2.27978229 | 9.740e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4439]` | 1.987474976 | 1.987474976 | 1.005e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4440]` | 2.291284618 | 2.291284618 | 1.357e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4441]` | 2.36927641 | 2.36927641 | 5.623e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4442]` | 2.666903008 | 2.666903008 | 1.665e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4443]` | 1.848289866 | 1.848289866 | 7.208e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4444]` | 2.396470448 | 2.396470448 | 3.706e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4446]` | 2.813990314 | 2.813990314 | 3.156e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4447]` | 2.618362496 | 2.618362496 | 5.088e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4448]` | 2.48001146 | 2.48001146 | 3.581e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4449]` | 2.591497695 | 2.591497695 | 1.714e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4450]` | 2.094600843 | 2.094600843 | 2.120e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4452]` | 2.643964678 | 2.643964678 | 5.039e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4453]` | 2.628819085 | 2.628819085 | 1.689e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4454]` | 2.571218439 | 2.571218439 | 1.727e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4455]` | 2.091953029 | 2.091953029 | 8.491e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4456]` | 1.983922015 | 1.983922015 | 4.477e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4457]` | 2.516261076 | 2.516261076 | 3.000e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4459]` | 2.574346883 | 2.574346883 | 1.725e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4461]` | 2.765363805 | 2.765363805 | 1.606e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4463]` | 2.696814461 | 2.696814461 | 1.647e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4464]` | 2.16900152 | 2.16900152 | 1.843e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4465]` | 2.565933051 | 2.565933051 | 3.461e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4466]` | 2.563608565 | 2.563608565 | 1.732e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4467]` | 2.301770189 | 2.301770189 | 1.929e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4468]` | 2.844204565 | 2.844204565 | 1.093e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4469]` | 2.279501063 | 2.279501063 | 1.559e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4470]` | 2.686330124 | 2.686330124 | 1.653e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4471]` | 2.206382128 | 2.206382128 | 4.025e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4472]` | 2.316979649 | 2.316979649 | 1.533e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4473]` | 2.28397482 | 2.28397482 | 5.833e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4474]` | 2.157306047 | 2.157306047 | 2.059e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4477]` | 2.188939984 | 2.188939984 | 4.058e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4480]` | 2.892016435 | 2.892016435 | 1.536e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4482]` | 1.944446422 | 1.944446422 | 1.142e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4483]` | 1.688305117 | 1.688305117 | 1.315e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4484]` | 1.92608738 | 1.92608738 | 2.306e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4485]` | 2.157828604 | 2.157828604 | 1.029e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4487]` | 2.378401817 | 2.378401817 | 1.680e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4488]` | 2.235968182 | 2.235968182 | 1.192e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4489]` | 2.838964602 | 2.838964602 | 3.129e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4492]` | 1.91941321 | 1.91941321 | 3.471e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4493]` | 3.088533563 | 3.088533563 | 2.876e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4494]` | 2.143970532 | 2.143970532 | 4.764e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4495]` | 2.836437072 | 2.836437072 | 1.409e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4497]` | 2.659918657 | 2.659918657 | 1.670e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4498]` | 2.236514441 | 2.236514441 | 7.943e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4500]` | 2.095414156 | 2.095414156 | 2.119e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4501]` | 1.281389906 | 1.281389906 | 5.199e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4502]` | 2.356267934 | 2.356267934 | 1.885e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4503]` | 2.270754573 | 2.270754573 | 7.823e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4505]` | 2.148912444 | 2.148912444 | 2.067e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4506]` | 2.687770746 | 2.687770746 | 8.261e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4507]` | 2.162587772 | 2.162587772 | 1.027e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4508]` | 2.368015175 | 2.368015175 | 3.751e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4509]` | 2.761033051 | 2.761033051 | 8.042e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4510]` | 2.033988894 | 2.033988894 | 2.183e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4511]` | 2.418832504 | 2.418832504 | 1.836e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4512]` | 2.828031888 | 2.828031888 | 6.281e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4513]` | 2.490063326 | 2.490063326 | 2.140e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4514]` | 2.381576704 | 2.381576704 | 7.459e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4516]` | 2.130239676 | 2.130239676 | 1.668e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4517]` | 2.96486035 | 2.96486035 | 1.498e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4518]` | 2.379449747 | 2.379449747 | 1.866e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4520]` | 2.013286521 | 2.013286521 | 2.206e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4521]` | 2.596270008 | 2.596270008 | 1.710e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4522]` | 2.566911575 | 2.566911575 | 1.730e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4523]` | 2.169630899 | 2.169630899 | 4.094e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4524]` | 2.393757531 | 2.393757531 | 9.276e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4525]` | 2.041511825 | 2.041511825 | 4.351e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4526]` | 2.223480125 | 2.223480125 | 1.997e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4528]` | 2.636593435 | 2.636593435 | 8.422e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4529]` | 1.954475988 | 1.954475988 | 2.272e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4530]` | 2.450076917 | 2.450076917 | 2.538e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4531]` | 1.673020578 | 1.673020578 | 1.991e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4532]` | 2.06496624 | 2.06496624 | 1.290e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4533]` | 1.846791527 | 1.846791527 | 2.284e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4534]` | 2.22570085 | 2.22570085 | 1.995e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4535]` | 2.290724399 | 2.290724399 | 7.755e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4536]` | 2.316254631 | 2.316254631 | 2.109e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4537]` | 2.429225927 | 2.429225927 | 7.312e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4538]` | 2.546535144 | 2.546535144 | 1.744e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4539]` | 2.205721889 | 2.205721889 | 4.027e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4540]` | 2.777365043 | 2.777365043 | 1.599e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4541]` | 2.225001214 | 2.225001214 | 3.992e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4542]` | 2.722907653 | 2.722907653 | 6.524e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4543]` | 2.339779492 | 2.339779492 | 3.986e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4544]` | 2.604481097 | 2.604481097 | 5.115e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4547]` | 2.729745893 | 2.729745893 | 1.627e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4548]` | 2.385333399 | 2.385333399 | 5.585e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4549]` | 2.700302059 | 2.700302059 | 1.480e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4550]` | 2.432324582 | 2.432324582 | 9.129e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4552]` | 2.385239064 | 2.385239064 | 1.862e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4553]` | 2.814126872 | 2.814126872 | 5.918e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4555]` | 2.029337014 | 2.029337014 | 2.188e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4556]` | 2.14552548 | 2.14552548 | 2.070e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4557]` | 1.979441257 | 1.979441257 | 1.795e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4558]` | 2.744337899 | 2.744337899 | 3.236e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4559]` | 2.410689267 | 2.410689267 | 1.842e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4561]` | 2.182764853 | 2.182764853 | 6.104e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4563]` | 2.055848003 | 2.055848003 | 5.184e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4567]` | 2.491777514 | 2.491777514 | 1.782e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4568]` | 2.568961355 | 2.568961355 | 1.729e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4569]` | 2.21622462 | 2.21622462 | 4.008e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4571]` | 2.101337487 | 2.101337487 | 1.268e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4572]` | 2.538578382 | 2.538578382 | 1.749e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4573]` | 2.216858748 | 2.216858748 | 3.406e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4574]` | 2.054772653 | 2.054772653 | 1.081e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4575]` | 2.502633992 | 2.502633992 | 1.774e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4576]` | 2.331446374 | 2.331446374 | 1.333e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4577]` | 2.501043856 | 2.501043856 | 1.776e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4578]` | 2.348747334 | 2.348747334 | 3.781e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4579]` | 2.077907742 | 2.077907742 | 1.496e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4580]` | 2.177703825 | 2.177703825 | 1.224e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4581]` | 2.499407138 | 2.499407138 | 5.330e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4582]` | 2.213703709 | 2.213703709 | 6.018e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4584]` | 2.296737084 | 2.296737084 | 2.514e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4585]` | 1.977830506 | 1.977830506 | 1.235e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4586]` | 2.305717746 | 2.305717746 | 1.791e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4588]` | 2.338899774 | 2.338899774 | 5.696e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4589]` | 2.452588074 | 2.452588074 | 5.432e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4591]` | 1.934462019 | 1.934462019 | 5.739e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4593]` | 2.057450175 | 2.057450175 | 2.158e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4594]` | 2.46279698 | 2.46279698 | 3.606e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4596]` | 2.207002781 | 2.207002781 | 2.012e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4597]` | 2.315841262 | 2.315841262 | 1.918e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4599]` | 2.413825762 | 2.413825762 | 5.519e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4600]` | 2.540727988 | 2.540727988 | 1.748e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4601]` | 2.603948228 | 2.603948228 | 1.364e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4602]` | 2.455045502 | 2.455045502 | 2.171e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4603]` | 1.934059198 | 1.934059198 | 6.888e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4604]` | 3.019218296 | 3.019218296 | 1.471e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4605]` | 2.563637499 | 2.563637499 | 6.929e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4606]` | 2.823909618 | 2.823909618 | 1.573e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4609]` | 3.089396296 | 3.089396296 | 2.875e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4611]` | 2.677740017 | 2.677740017 | 3.317e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4613]` | 2.077344626 | 2.077344626 | 3.207e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4616]` | 2.227770425 | 2.227770425 | 7.974e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4617]` | 2.484761314 | 2.484761314 | 1.787e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4618]` | 2.312384973 | 2.312384973 | 5.761e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4619]` | 2.334698794 | 2.334698794 | 9.511e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4620]` | 2.487749548 | 2.487749548 | 1.785e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4621]` | 2.081144553 | 2.081144553 | 2.134e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4622]` | 2.456161025 | 2.456161025 | 1.266e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4623]` | 1.64842608 | 1.64842608 | 2.209e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4624]` | 2.148584098 | 2.148584098 | 1.240e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4626]` | 2.535297845 | 2.535297845 | 5.255e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4627]` | 2.27388289 | 2.27388289 | 4.101e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4628]` | 1.451837049 | 1.451837049 | 1.224e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4629]` | 2.164237135 | 2.164237135 | 1.231e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4630]` | 2.269151349 | 2.269151349 | 1.174e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4632]` | 2.237646694 | 2.237646694 | 3.969e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4633]` | 3.061520262 | 3.061520262 | 1.451e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4635]` | 2.14663913 | 2.14663913 | 6.206e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4636]` | 2.155647806 | 2.155647806 | 6.180e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4637]` | 1.811996931 | 1.811996931 | 7.352e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4638]` | 2.585048725 | 2.585048725 | 8.590e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4639]` | 2.344829356 | 2.344829356 | 3.788e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4640]` | 2.328516011 | 2.328516011 | 1.144e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4641]` | 1.718422749 | 1.718422749 | 1.551e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4642]` | 2.215936112 | 2.215936112 | 2.204e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4643]` | 2.207531934 | 2.207531934 | 6.035e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4644]` | 2.477405047 | 2.477405047 | 3.585e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4645]` | 2.231641179 | 2.231641179 | 3.980e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4646]` | 2.288800275 | 2.288800275 | 1.940e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4647]` | 3.047605361 | 3.047605361 | 1.457e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4648]` | 2.325148468 | 2.325148468 | 3.820e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4649]` | 2.467411324 | 2.467411324 | 1.800e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4650]` | 2.559897727 | 2.559897727 | 6.939e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4652]` | 1.805348375 | 1.805348375 | 9.839e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4653]` | 2.573911404 | 2.573911404 | 3.451e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4654]` | 2.063204385 | 2.063204385 | 6.457e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4655]` | 2.346497987 | 2.346497987 | 3.785e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4656]` | 2.274956042 | 2.274956042 | 1.952e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4657]` | 2.370886879 | 2.370886879 | 7.492e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4658]` | 2.284042738 | 2.284042738 | 4.666e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4659]` | 2.689752045 | 2.689752045 | 1.651e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4660]` | 1.94883228 | 1.94883228 | 3.418e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4661]` | 1.89404694 | 1.89404694 | 1.290e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4664]` | 2.710478391 | 2.710478391 | 8.192e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4665]` | 2.368215685 | 2.368215685 | 3.750e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4666]` | 2.00355447 | 2.00355447 | 2.217e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4667]` | 2.12342567 | 2.12342567 | 2.091e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4668]` | 2.771840461 | 2.771840461 | 7.851e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4669]` | 2.406524383 | 2.406524383 | 1.845e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4670]` | 2.452712421 | 2.452712421 | 1.811e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4671]` | 2.106627492 | 2.106627492 | 1.054e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4672]` | 1.936783656 | 1.936783656 | 5.044e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4673]` | 1.888960394 | 1.888960394 | 1.881e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4675]` | 2.60280083 | 2.60280083 | 1.024e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4676]` | 3.222436705 | 3.222436705 | 6.891e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4677]` | 2.544246349 | 2.544246349 | 1.222e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4678]` | 1.781170924 | 1.781170924 | 1.621e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4679]` | 2.335180709 | 2.335180709 | 5.705e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4680]` | 2.432047837 | 2.432047837 | 2.191e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4681]` | 1.766823454 | 1.766823454 | 4.399e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4684]` | 2.057479272 | 2.057479272 | 5.051e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4685]` | 2.070067401 | 2.070067401 | 2.145e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4686]` | 2.018099675 | 2.018099675 | 1.100e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4687]` | 3.000742292 | 3.000742292 | 1.776e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4688]` | 3.044754003 | 3.044754003 | 1.021e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4690]` | 2.688619702 | 2.688619702 | 6.607e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4691]` | 1.870334449 | 1.870334449 | 3.562e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4692]` | 2.033391817 | 2.033391817 | 2.184e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4694]` | 1.667465489 | 1.667465489 | 5.460e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4696]` | 2.221646763 | 2.221646763 | 3.998e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4697]` | 2.327972089 | 2.327972089 | 3.815e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4699]` | 1.974566253 | 1.974566253 | 3.374e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4701]` | 2.720382173 | 2.720382173 | 6.530e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4702]` | 2.484121159 | 2.484121159 | 7.151e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4703]` | 1.952382727 | 1.952382727 | 1.820e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4704]` | 2.227062041 | 2.227062041 | 5.982e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4707]` | 2.332384056 | 2.332384056 | 1.142e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4708]` | 2.674691472 | 2.674691472 | 3.321e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4709]` | 2.824923843 | 2.824923843 | 1.258e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4710]` | 2.20385956 | 2.20385956 | 4.030e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4711]` | 2.52817338 | 2.52817338 | 1.757e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4712]` | 2.590536944 | 2.590536944 | 1.714e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4713]` | 2.772017416 | 2.772017416 | 6.408e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4715]` | 2.31426122 | 2.31426122 | 7.676e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4716]` | 2.242172535 | 2.242172535 | 5.942e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4718]` | 2.588949491 | 2.588949491 | 1.887e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4719]` | 2.134632257 | 2.134632257 | 4.161e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4720]` | 2.076168334 | 2.076168334 | 6.417e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4722]` | 2.309408695 | 2.309408695 | 1.923e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4724]` | 2.787414797 | 2.787414797 | 1.593e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4725]` | 2.871841246 | 2.871841246 | 3.093e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4727]` | 1.948205586 | 1.948205586 | 9.118e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4728]` | 2.67865301 | 2.67865301 | 1.161e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4729]` | 1.968226173 | 1.968226173 | 9.025e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4730]` | 2.457564824 | 2.457564824 | 5.421e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4732]` | 2.71626525 | 2.71626525 | 4.905e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4733]` | 2.189555734 | 2.189555734 | 1.420e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4734]` | 2.559611175 | 2.559611175 | 1.735e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4737]` | 2.445641374 | 2.445641374 | 1.816e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4738]` | 2.265851197 | 2.265851197 | 7.840e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4739]` | 2.151000154 | 2.151000154 | 4.542e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4740]` | 2.142930982 | 2.142930982 | 2.072e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4741]` | 2.360477387 | 2.360477387 | 1.881e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4743]` | 2.352658947 | 2.352658947 | 5.663e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4744]` | 2.656284371 | 2.656284371 | 1.672e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4746]` | 2.050974498 | 2.050974498 | 2.165e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4747]` | 2.878390661 | 2.878390661 | 1.543e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4748]` | 2.529460432 | 2.529460432 | 7.023e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4749]` | 2.555248304 | 2.555248304 | 5.214e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4750]` | 1.95629945 | 1.95629945 | 3.065e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4751]` | 2.547058194 | 2.547058194 | 3.487e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4752]` | 2.381039534 | 2.381039534 | 5.595e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4753]` | 1.756011306 | 1.756011306 | 1.264e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4754]` | 2.374719651 | 2.374719651 | 7.480e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4755]` | 2.370379234 | 2.370379234 | 7.494e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4756]` | 2.126852746 | 2.126852746 | 1.670e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4757]` | 2.11896832 | 2.11896832 | 2.096e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4758]` | 3.062342729 | 3.062342729 | 8.701e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4759]` | 1.617577623 | 1.617577623 | 2.745e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4760]` | 2.854367266 | 2.854367266 | 6.223e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4762]` | 2.340509993 | 2.340509993 | 1.897e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4763]` | 2.334700243 | 2.334700243 | 1.331e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4764]` | 2.872092881 | 2.872092881 | 4.639e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4766]` | 2.740224209 | 2.740224209 | 2.107e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4767]` | 2.956391384 | 2.956391384 | 1.051e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4768]` | 1.949623617 | 1.949623617 | 1.481e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4769]` | 1.734054347 | 1.734054347 | 2.177e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4770]` | 1.848482236 | 1.848482236 | 2.402e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4771]` | 2.335239082 | 2.335239082 | 3.803e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4772]` | 2.601056784 | 2.601056784 | 6.829e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4773]` | 2.007325842 | 2.007325842 | 1.991e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4774]` | 1.408596515 | 1.408596515 | 1.576e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4775]` | 2.439306379 | 2.439306379 | 1.092e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4776]` | 2.814416539 | 2.814416539 | 7.890e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4778]` | 2.313184659 | 2.313184659 | 1.344e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4779]` | 2.552007634 | 2.552007634 | 3.480e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4780]` | 2.123777367 | 2.123777367 | 1.464e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4781]` | 2.470975592 | 2.470975592 | 3.594e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4782]` | 2.830354991 | 2.830354991 | 6.276e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4784]` | 2.782597097 | 2.782597097 | 1.596e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4785]` | 2.41990254 | 2.41990254 | 4.771e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4786]` | 2.337291377 | 2.337291377 | 1.710e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4787]` | 2.673243487 | 2.673243487 | 6.645e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4788]` | 2.022840441 | 2.022840441 | 1.756e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4790]` | 2.886799743 | 2.886799743 | 3.077e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4791]` | 2.628132036 | 2.628132036 | 3.380e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4792]` | 2.983327145 | 2.983327145 | 6.996e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4793]` | 2.72002838 | 2.72002838 | 4.898e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4796]` | 2.089989803 | 2.089989803 | 4.250e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4797]` | 2.394126806 | 2.394126806 | 3.710e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4798]` | 1.705406152 | 1.705406152 | 4.036e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4800]` | 2.931182589 | 2.931182589 | 1.515e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4801]` | 2.768439096 | 2.768439096 | 1.444e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4802]` | 2.220092777 | 2.220092777 | 1.400e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4803]` | 2.255539428 | 2.255539428 | 1.969e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4805]` | 2.898154617 | 2.898154617 | 6.129e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4806]` | 2.209541212 | 2.209541212 | 3.417e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4807]` | 2.46514153 | 2.46514153 | 1.801e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4808]` | 2.231954128 | 2.231954128 | 5.969e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4809]` | 2.569140574 | 2.569140574 | 1.729e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4810]` | 2.564985337 | 2.564985337 | 6.925e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4813]` | 1.964259922 | 1.964259922 | 1.696e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4814]` | 2.027029221 | 2.027029221 | 1.534e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4815]` | 2.493847089 | 2.493847089 | 1.247e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4816]` | 1.800065356 | 1.800065356 | 4.934e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4817]` | 2.242287436 | 2.242287436 | 1.981e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4819]` | 1.726751002 | 1.726751002 | 4.244e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4820]` | 2.476974114 | 2.476974114 | 1.255e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4821]` | 2.250939234 | 2.250939234 | 5.919e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4822]` | 2.012760117 | 2.012760117 | 1.986e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4823]` | 2.816469172 | 2.816469172 | 9.461e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4824]` | 2.236592883 | 2.236592883 | 5.957e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4825]` | 2.366547427 | 2.366547427 | 5.630e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4826]` | 2.865637251 | 2.865637251 | 1.550e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4827]` | 1.821372289 | 1.821372289 | 3.657e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4828]` | 2.574210721 | 2.574210721 | 1.725e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4831]` | 1.854170047 | 1.854170047 | 2.515e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4832]` | 2.196435594 | 2.196435594 | 8.087e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4833]` | 2.653554775 | 2.653554775 | 6.694e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4834]` | 2.74965485 | 2.74965485 | 6.460e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4835]` | 2.488241661 | 2.488241661 | 7.139e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4836]` | 2.725371715 | 2.725371715 | 6.518e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4837]` | 2.441349821 | 2.441349821 | 5.457e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4838]` | 2.0912022 | 2.0912022 | 1.274e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4839]` | 2.339593201 | 2.339593201 | 7.593e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4841]` | 2.411612466 | 2.411612466 | 1.841e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4842]` | 2.363364646 | 2.363364646 | 1.879e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4843]` | 2.216831205 | 2.216831205 | 2.805e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4844]` | 2.698444331 | 2.698444331 | 6.583e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4845]` | 2.471664362 | 2.471664362 | 5.390e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4846]` | 2.37657618 | 2.37657618 | 5.606e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4848]` | 2.387442852 | 2.387442852 | 1.488e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4849]` | 2.76320944 | 2.76320944 | 4.821e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4850]` | 2.159440894 | 2.159440894 | 1.028e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4851]` | 2.775166062 | 2.775166062 | 1.600e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4853]` | 2.308855228 | 2.308855228 | 5.770e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4854]` | 2.61924346 | 2.61924346 | 1.865e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4855]` | 2.050693235 | 2.050693235 | 4.331e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4857]` | 2.23441593 | 2.23441593 | 9.937e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4859]` | 2.303797246 | 2.303797246 | 1.928e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4860]` | 1.939710494 | 1.939710494 | 1.030e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4861]` | 2.330357874 | 2.330357874 | 1.906e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4862]` | 2.483997813 | 2.483997813 | 1.073e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4863]` | 1.843235111 | 1.843235111 | 3.614e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4864]` | 2.296739979 | 2.296739979 | 3.867e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4865]` | 2.508367501 | 2.508367501 | 1.770e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4866]` | 2.396161989 | 2.396161989 | 3.707e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4867]` | 1.788450006 | 1.788450006 | 3.228e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4868]` | 2.5651089 | 2.5651089 | 8.656e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4869]` | 1.934366664 | 1.934366664 | 5.166e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4870]` | 2.521638522 | 2.521638522 | 3.522e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4871]` | 2.180651562 | 2.180651562 | 2.036e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4872]` | 2.118379718 | 2.118379718 | 2.096e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4873]` | 2.324171422 | 2.324171422 | 1.911e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4874]` | 2.104028559 | 2.104028559 | 6.965e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4875]` | 2.162282913 | 2.162282913 | 4.108e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4876]` | 2.158561285 | 2.158561285 | 2.675e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4877]` | 2.792181433 | 2.792181433 | 5.408e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4878]` | 2.148299787 | 2.148299787 | 4.134e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4879]` | 1.775586182 | 1.775586182 | 1.251e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4881]` | 2.373631252 | 2.373631252 | 1.871e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4882]` | 2.113504359 | 2.113504359 | 6.304e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4883]` | 2.451267951 | 2.451267951 | 5.435e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4884]` | 2.09415892 | 2.09415892 | 2.969e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4886]` | 1.612029562 | 1.612029562 | 5.647e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4887]` | 2.850865398 | 2.850865398 | 1.558e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4888]` | 2.96141445 | 2.96141445 | 4.499e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4889]` | 1.898171597 | 1.898171597 | 3.392e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4890]` | 2.1603885 | 2.1603885 | 2.056e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4891]` | 2.544029205 | 2.544029205 | 6.982e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4892]` | 2.24428594 | 2.24428594 | 1.583e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4893]` | 2.19171945 | 2.19171945 | 8.105e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4894]` | 3.056286949 | 3.056286949 | 2.906e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4895]` | 2.122481371 | 2.122481371 | 1.046e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4896]` | 2.099260012 | 2.099260012 | 2.115e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4897]` | 1.554720736 | 1.554720736 | 4.285e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4898]` | 1.918301636 | 1.918301636 | 3.473e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4899]` | 2.630470102 | 2.630470102 | 8.441e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4900]` | 1.918544415 | 1.918544415 | 6.944e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4901]` | 2.014134335 | 2.014134335 | 4.410e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4902]` | 2.278995511 | 2.278995511 | 3.897e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4903]` | 2.034842556 | 2.034842556 | 4.365e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4904]` | 2.355985168 | 2.355985168 | 1.696e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4905]` | 2.256414383 | 2.256414383 | 1.968e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4906]` | 2.551207897 | 2.551207897 | 8.704e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4907]` | 2.61951668 | 2.61951668 | 1.695e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4908]` | 1.993527549 | 1.993527549 | 1.114e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4910]` | 2.40209746 | 2.40209746 | 4.067e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4911]` | 2.289317375 | 2.289317375 | 1.746e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4912]` | 2.512708837 | 2.512708837 | 1.944e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4913]` | 2.891070161 | 2.891070161 | 1.536e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4914]` | 1.796959737 | 1.796959737 | 1.236e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4915]` | 2.356246035 | 2.356246035 | 5.654e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4916]` | 2.194246862 | 2.194246862 | 2.631e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4917]` | 1.921064418 | 1.921064418 | 5.201e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4918]` | 2.880782719 | 2.880782719 | 4.625e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4919]` | 1.886733638 | 1.886733638 | 3.531e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4920]` | 2.193584869 | 2.193584869 | 6.073e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4922]` | 2.103522289 | 2.103522289 | 2.111e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4923]` | 1.927956788 | 1.927956788 | 4.607e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4924]` | 2.294078585 | 2.294078585 | 9.679e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4925]` | 2.259873903 | 2.259873903 | 1.965e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4927]` | 1.795660885 | 1.795660885 | 1.237e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4928]` | 2.368853727 | 2.368853727 | 1.875e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4929]` | 2.311495786 | 2.311495786 | 7.685e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4930]` | 2.595498777 | 2.595498777 | 1.540e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4931]` | 2.774943541 | 2.774943541 | 1.280e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4932]` | 1.711737165 | 1.711737165 | 1.816e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4933]` | 1.979598969 | 1.979598969 | 1.795e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4934]` | 2.08535061 | 2.08535061 | 1.917e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4935]` | 2.258432126 | 2.258432126 | 1.966e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4937]` | 2.063002708 | 2.063002708 | 1.959e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4938]` | 2.497947323 | 2.497947323 | 1.956e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4939]` | 1.877000597 | 1.877000597 | 1.774e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4940]` | 2.113785625 | 2.113785625 | 2.101e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4941]` | 2.532274101 | 2.532274101 | 1.228e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4942]` | 2.508756635 | 2.508756635 | 1.062e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4943]` | 1.664548998 | 1.664548998 | 1.467e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4944]` | 2.557724731 | 2.557724731 | 1.736e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4945]` | 2.313872205 | 2.313872205 | 5.758e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4946]` | 2.38539697 | 2.38539697 | 1.862e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4947]` | 2.332324619 | 2.332324619 | 7.616e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4948]` | 2.025232951 | 2.025232951 | 2.193e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4949]` | 2.654033419 | 2.654033419 | 3.347e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4951]` | 2.70051639 | 2.70051639 | 1.644e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4952]` | 3.092352681 | 3.092352681 | 1.436e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4953]` | 2.872460995 | 2.872460995 | 7.730e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4954]` | 2.701266846 | 2.701266846 | 9.700e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4956]` | 2.406359922 | 2.406359922 | 1.107e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4957]` | 2.242219627 | 2.242219627 | 1.386e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4958]` | 2.431938703 | 2.431938703 | 2.009e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4959]` | 2.771213752 | 2.771213752 | 3.205e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4960]` | 2.258870648 | 2.258870648 | 3.932e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4961]` | 2.302079497 | 2.302079497 | 3.858e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4962]` | 2.212416161 | 2.212416161 | 4.015e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4963]` | 2.250258122 | 2.250258122 | 3.947e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4964]` | 1.466311734 | 1.466311734 | 3.029e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4967]` | 1.977892924 | 1.977892924 | 1.796e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4969]` | 2.674188022 | 2.674188022 | 8.303e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4970]` | 2.147991174 | 2.147991174 | 1.240e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4971]` | 2.654386971 | 2.654386971 | 1.673e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4972]` | 2.810412827 | 2.810412827 | 3.160e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4973]` | 1.819338632 | 1.819338632 | 1.220e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4974]` | 2.102874756 | 2.102874756 | 1.056e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4975]` | 2.293760044 | 2.293760044 | 1.162e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4976]` | 2.278941429 | 2.278941429 | 3.897e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4977]` | 2.49111967 | 2.49111967 | 3.031e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4978]` | 2.32837843 | 2.32837843 | 5.340e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4979]` | 2.672488561 | 2.672488561 | 3.323e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4981]` | 2.60846296 | 2.60846296 | 1.702e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4982]` | 2.535294107 | 2.535294107 | 1.927e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4984]` | 2.60022575 | 2.60022575 | 3.416e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4985]` | 2.722070454 | 2.722070454 | 4.894e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4987]` | 2.550014114 | 2.550014114 | 1.045e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4988]` | 2.472475321 | 2.472475321 | 5.388e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4990]` | 2.876879471 | 2.876879471 | 2.007e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4991]` | 1.849481166 | 1.849481166 | 1.561e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4992]` | 1.72738135 | 1.72738135 | 3.856e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4993]` | 1.883780686 | 1.883780686 | 5.894e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[4994]` | 2.347115255 | 2.347115255 | 1.892e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[5995]` | 1.536292712 | 1.529978269 | 4.110e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[5996]` | 0.6458812319 | 0.6181364302 | 4.296e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[5997]` | 0.2032022637 | 0.05463356292 | 7.311e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[5998]` | -0.4148224011 | -0.5122388224 | 2.348e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[5999]` | -1.657583172 | -1.67945835 | 1.320e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6000]` | -1.822703644 | -1.761947005 | 3.333e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6001]` | 1.94221151 | 1.67983831 | 1.351e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6002]` | -0.7846276533 | -0.8557400788 | 9.063e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6003]` | -0.8741155636 | -0.7794503368 | 1.083e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6004]` | -0.1510989611 | -0.1659966974 | 9.860e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6005]` | -0.0833085923 | -0.209765525 | 1.518e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6006]` | 0.1135165385 | 0.1275725476 | 1.238e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6007]` | 0.1791743097 | 0.1663064108 | 7.182e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6008]` | -2.25868483 | -2.136001472 | 5.432e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6009]` | 0.5725486292 | 0.6272564784 | 9.555e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6010]` | -1.740898985 | -1.752188289 | 6.485e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6011]` | -0.5142920604 | -0.6054141518 | 1.772e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6012]` | -1.155371253 | -1.077130621 | 6.772e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6013]` | 0.8435448197 | 0.7854317791 | 6.889e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6014]` | -1.186276699 | -1.210218777 | 2.018e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6015]` | -1.007494944 | -1.074654022 | 6.666e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6016]` | 1.545490871 | 1.617192696 | 4.639e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6017]` | 1.658438267 | 1.6937653 | 2.130e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6018]` | 0.1544736337 | 0.1476289725 | 4.431e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6019]` | -2.761183451 | -2.695691481 | 2.372e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6020]` | 0.3720308011 | 0.434568399 | 1.681e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6021]` | -0.3354161052 | -0.338514912 | 9.239e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6022]` | 1.955343159 | 2.013569027 | 2.978e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6023]` | 0.2956211415 | 0.398033792 | 3.464e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6024]` | -0.2379206245 | -0.3356199272 | 4.106e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6025]` | 1.671406487 | 1.653803468 | 1.053e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6026]` | -0.04944158992 | -0.1424108558 | 1.880e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6027]` | -1.123260271 | -1.167649919 | 3.952e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6028]` | 0.1979070561 | 0.3036964764 | 5.345e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6029]` | -1.00546556 | -0.9844821965 | 2.087e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6030]` | -0.6614476153 | -0.7265848841 | 9.848e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6031]` | -0.9293804803 | -0.9095728704 | 2.131e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6032]` | 0.06207553594 | 0.0953591501 | 5.362e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6033]` | 0.157759068 | 0.1356027643 | 1.404e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6034]` | 2.032608366 | 1.949828182 | 4.073e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6035]` | -0.2562999239 | -0.3896322392 | 5.202e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6036]` | -1.627273763 | -1.634224518 | 4.271e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6037]` | 0.697507873 | 0.7487732861 | 7.350e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6038]` | -1.080508266 | -0.9668514691 | 1.052e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6039]` | 1.405800248 | 1.454251339 | 3.447e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6040]` | 0.8337051603 | 0.8462612609 | 1.506e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6041]` | 0.2902940692 | 0.408046953 | 4.056e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6042]` | -0.7249589636 | -0.7300211647 | 6.983e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6043]` | -0.106905803 | -0.1348006651 | 2.609e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6044]` | -0.4767157791 | -0.5874436932 | 2.323e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6045]` | -0.8159680345 | -0.8558965608 | 4.893e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6046]` | 0.5130029848 | 0.5749350301 | 1.207e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6047]` | 0.3940105773 | 0.3141392778 | 2.027e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6048]` | 0.1317218543 | 0.1648443603 | 2.515e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6049]` | 1.264777469 | 1.322472518 | 4.562e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6050]` | 0.367286505 | 0.4900114257 | 3.341e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6051]` | -0.3056956799 | -0.3675600239 | 2.024e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6052]` | -0.2722288674 | -0.2111023273 | 2.245e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6053]` | -0.8571461987 | -0.9037370944 | 5.436e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6054]` | 0.9777957575 | 1.073318647 | 9.769e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6055]` | -1.146090301 | -1.208293506 | 5.427e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6056]` | 0.03413297204 | 0.1049412764 | 2.074e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6057]` | -2.567175541 | -2.486428673 | 3.145e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6058]` | -0.4530388225 | -0.3669097261 | 1.901e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6059]` | 1.023070217 | 1.030180349 | 6.950e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6060]` | -1.048087832 | -1.046449459 | 1.563e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6061]` | -1.236113351 | -1.307973295 | 5.813e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6062]` | 0.2357866627 | 0.1838053516 | 2.205e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6063]` | 1.724784175 | 1.598138233 | 7.343e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6064]` | -0.6695805267 | -0.7506653228 | 1.211e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6065]` | -1.303498079 | -1.364709722 | 4.696e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6066]` | -0.863914846 | -0.8235764943 | 4.669e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6067]` | 0.635574918 | 0.6930110113 | 9.037e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6068]` | 0.3461819197 | 0.3964033416 | 1.451e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6069]` | -0.8146462541 | -0.7350426836 | 9.772e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6070]` | 1.329306832 | 1.394428943 | 4.899e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6071]` | 0.09620798678 | 0.1698698952 | 7.657e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6072]` | -0.5701207099 | -0.612456325 | 7.426e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6073]` | -0.1425876963 | -0.06420064726 | 5.497e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6074]` | -1.741634298 | -1.777949687 | 2.085e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6075]` | 0.5979712625 | 0.6791209862 | 1.357e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6076]` | 1.001650547 | 1.047375745 | 4.565e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6077]` | 0.6536328714 | 0.5370166472 | 1.784e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6078]` | -1.031818966 | -1.060663557 | 2.796e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6079]` | 0.921516353 | 0.8664033552 | 5.981e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6080]` | 0.01133797262 | -0.002600086667 | 1.229e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6081]` | 0.9928805683 | 1.044556198 | 5.205e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6082]` | 0.5779045239 | 0.6253548049 | 8.211e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6083]` | 1.45908396 | 1.517860641 | 4.028e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6084]` | 0.3879774973 | 0.4182061351 | 7.791e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6085]` | 1.875206759 | 1.910377214 | 1.876e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6086]` | -0.6700510968 | -0.576120152 | 1.402e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6087]` | 1.788708839 | 1.856000572 | 3.762e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6088]` | -0.4821930081 | -0.5888732553 | 2.212e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6089]` | 1.340979156 | 1.337710877 | 2.437e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6090]` | 0.3796816432 | 0.4416160742 | 1.631e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6091]` | 0.3765896336 | 0.4781082035 | 2.696e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6092]` | -1.114166938 | -0.9697499548 | 1.296e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6093]` | 0.3021638426 | 0.2178852849 | 2.789e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6094]` | -0.9497776725 | -0.9948985403 | 4.751e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6095]` | 0.9006092791 | 0.9718265658 | 7.908e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6096]` | -2.016570309 | -2.063324129 | 2.318e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6097]` | -0.1204392505 | -0.2463524538 | 1.045e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6098]` | 1.959310585 | 1.947647298 | 5.953e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6099]` | 0.9575740021 | 0.8999042439 | 6.022e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6100]` | -2.320880061 | -2.286268378 | 1.491e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6101]` | -0.1854039874 | -0.2784762383 | 5.020e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6102]` | -0.004433327182 | -0.08231523462 | 1.757e+01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6103]` | 0.7740651543 | 0.7720891994 | 2.553e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6104]` | -0.8703944699 | -0.8708616613 | 5.368e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6105]` | -0.06015769935 | -0.08073412089 | 3.420e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6106]` | 0.8140353869 | 0.7260517711 | 1.081e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6107]` | -0.4432590449 | -0.4546429199 | 2.568e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6108]` | -0.1138286061 | -0.09994546802 | 1.220e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6109]` | 1.644726681 | 1.607948784 | 2.236e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6110]` | -0.2940442724 | -0.3713164268 | 2.628e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6111]` | 0.1893644271 | 0.01879188277 | 9.008e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6112]` | 2.474448364 | 2.501960578 | 1.112e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6113]` | -0.05955229874 | -0.08176948705 | 3.731e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6114]` | 1.654407174 | 1.694801653 | 2.442e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6115]` | -0.7385393147 | -0.6778072215 | 8.223e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6116]` | 0.4410166959 | 0.4430801406 | 4.679e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6117]` | -0.1239786796 | -0.02147608396 | 8.268e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6118]` | -2.206995938 | -2.208801248 | 8.180e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6119]` | 2.239466174 | 2.210373824 | 1.299e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6120]` | -1.192841035 | -1.207421436 | 1.222e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6121]` | -0.2172910202 | -0.2436814057 | 1.215e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6122]` | -0.07516945655 | -0.004720572293 | 9.372e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6123]` | -0.5543621579 | -0.4629309444 | 1.649e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6124]` | -3.363264631 | -3.311018528 | 1.553e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6125]` | -0.06739462453 | -0.1167951665 | 7.330e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6126]` | 0.9841909881 | 0.8897142476 | 9.599e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6127]` | 2.192385718 | 2.218037753 | 1.170e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6128]` | -1.406349592 | -1.414421582 | 5.740e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6129]` | -0.9151380134 | -0.9369609606 | 2.385e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6130]` | -1.103878089 | -1.164488343 | 5.491e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6131]` | 1.316219133 | 1.201249215 | 8.735e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6132]` | 0.3227255862 | 0.419293222 | 2.992e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6133]` | -0.1235956895 | -0.07801111145 | 3.688e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6134]` | -0.9124915223 | -0.9833125798 | 7.761e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6135]` | 0.2415105716 | 0.2520405007 | 4.360e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6136]` | 0.4258294476 | 0.3710091211 | 1.287e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6137]` | 1.053761526 | 1.029980965 | 2.257e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6138]` | 0.3039242001 | 0.333680948 | 9.791e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6139]` | 1.7341911 | 1.788162716 | 3.112e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6140]` | -0.340355492 | -0.4642361561 | 3.640e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6141]` | 2.464798192 | 2.403347954 | 2.493e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6142]` | -0.2973550125 | -0.3163096301 | 6.374e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6143]` | 1.037886815 | 0.9790750506 | 5.666e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6144]` | -1.340711682 | -1.407783943 | 5.003e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6145]` | 0.6623640444 | 0.672429125 | 1.520e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6146]` | -0.3312892038 | -0.3326939177 | 4.240e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6147]` | -1.541214891 | -1.388732206 | 9.894e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6148]` | 0.3143283099 | 0.3657383565 | 1.636e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6149]` | -2.093625192 | -2.055004932 | 1.845e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6150]` | -0.9122057852 | -0.8355806586 | 8.400e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6151]` | 0.5315908467 | 0.5647201979 | 6.232e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6152]` | -0.9682611427 | -1.049266867 | 8.366e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6153]` | 0.5455251413 | 0.5619848231 | 3.017e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6154]` | -1.184037488 | -1.191397003 | 6.216e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6155]` | -0.1635553391 | -0.2340103439 | 4.308e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6156]` | -0.1519475469 | -0.1789042004 | 1.774e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6157]` | 0.6988766691 | 0.6004120793 | 1.409e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6158]` | -0.2567404536 | -0.1278062861 | 5.022e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6159]` | -1.519422442 | -1.582757827 | 4.168e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6160]` | -1.303877777 | -1.348296322 | 3.407e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6161]` | -0.3667513861 | -0.3283691594 | 1.047e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6162]` | -0.6555974148 | -0.7083781089 | 8.051e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6163]` | -0.8117316744 | -0.8478259404 | 4.447e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6164]` | -0.4237005313 | -0.3420513256 | 1.927e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6165]` | 0.6524067322 | 0.5257142572 | 1.942e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6166]` | 0.9463950202 | 0.9324026602 | 1.478e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6167]` | 0.1614113679 | 0.09675803578 | 4.006e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6168]` | 1.018055664 | 1.004264848 | 1.355e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6169]` | 0.5309189645 | 0.5781415251 | 8.894e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6170]` | -1.04704531 | -1.105062699 | 5.541e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6171]` | -1.808825284 | -1.858647446 | 2.754e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6172]` | -0.8252542456 | -0.8896501628 | 7.803e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6173]` | 0.3073101792 | 0.3708555501 | 2.068e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6174]` | 1.306933379 | 1.379985091 | 5.590e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6175]` | 0.851062755 | 0.9292452706 | 9.186e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6176]` | 1.185584912 | 1.26161735 | 6.413e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6177]` | -0.330487332 | -0.1933331103 | 4.150e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6178]` | -0.7206316498 | -0.7849152214 | 8.920e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6179]` | -1.010329155 | -1.083086225 | 7.201e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6180]` | 0.5716003657 | 0.652636015 | 1.418e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6181]` | -1.858345377 | -1.80682445 | 2.772e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6182]` | -1.651564516 | -1.593080117 | 3.541e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6183]` | 0.7298623815 | 0.7386631199 | 1.206e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6184]` | -0.4134823653 | -0.502510271 | 2.153e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6185]` | -0.4180315312 | -0.3907637745 | 6.523e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6186]` | -0.05125950101 | -0.1342289829 | 1.619e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6187]` | -0.9786414535 | -0.9226886807 | 5.717e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6188]` | 2.153206495 | 2.196896235 | 2.029e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6189]` | 0.5419922701 | 0.4524480555 | 1.652e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6190]` | 1.655074776 | 1.654664049 | 2.482e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6191]` | -0.2238519391 | -0.06183868877 | 7.238e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6192]` | 0.09630919266 | 0.2075814844 | 1.155e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6193]` | 1.007388403 | 0.9605614465 | 4.648e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6194]` | -0.6359144638 | -0.7573609783 | 1.910e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6195]` | -2.323286002 | -2.334438797 | 4.800e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6196]` | 0.157226458 | 0.2099345847 | 3.352e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6197]` | 0.6003132993 | 0.5866449193 | 2.277e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6198]` | -0.4648971775 | -0.4629144448 | 4.265e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6199]` | -1.617612549 | -1.439399699 | 1.102e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6200]` | -0.8833328728 | -0.8807102192 | 2.969e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6201]` | 0.8003099945 | 0.7245450305 | 9.467e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6202]` | -0.3772163681 | -0.3980992575 | 5.536e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6203]` | 0.3148611023 | 0.3859034071 | 2.256e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6204]` | 0.8560093778 | 0.8616346868 | 6.572e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6205]` | -0.5045230454 | -0.5992489644 | 1.878e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6206]` | -1.763531756 | -1.802117816 | 2.188e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6207]` | -1.51359777 | -1.564838404 | 3.385e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6208]` | -0.5436561065 | -0.3902155558 | 2.822e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6209]` | -0.3025967645 | -0.3428228933 | 1.329e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6210]` | 0.2647382806 | 0.2772942871 | 4.743e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6211]` | -0.9073674276 | -0.9159258859 | 9.432e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6212]` | -1.199148657 | -1.280654743 | 6.797e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6213]` | 1.550638285 | 1.536841829 | 8.897e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6214]` | 1.045911406 | 1.036998972 | 8.521e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6215]` | -0.5717084895 | -0.5564814578 | 2.663e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6216]` | 0.558463159 | 0.5726045431 | 2.532e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6217]` | -1.509765945 | -1.516629371 | 4.546e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6218]` | 1.195308953 | 1.094307306 | 8.450e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6219]` | 0.9002234471 | 0.9309661807 | 3.415e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6220]` | -0.06480774375 | -0.04851084291 | 2.515e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6221]` | -1.133001058 | -1.178854516 | 4.047e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6222]` | 0.1262323329 | 0.2746486605 | 1.176e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6223]` | 0.02094734678 | 0.09389759098 | 3.483e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6224]` | -0.3063275151 | -0.2920876825 | 4.649e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6225]` | -0.5148656731 | -0.5462799754 | 6.101e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6226]` | 2.156211369 | 2.193714967 | 1.739e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6227]` | -0.02010651284 | 0.067707033 | 4.367e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6228]` | 0.3621547055 | 0.4235409993 | 1.695e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6229]` | -0.4424474913 | -0.4114213376 | 7.012e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6230]` | -1.525517932 | -1.344996387 | 1.183e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6231]` | 0.269050276 | 0.3203592232 | 1.907e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6232]` | 0.1772668724 | 0.1041610625 | 4.124e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6233]` | 1.932503667 | 1.948043095 | 8.041e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6234]` | 0.9687325395 | 0.9926683187 | 2.471e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6235]` | 0.09674343866 | 0.02900925049 | 7.001e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6236]` | -0.8992233991 | -0.8633694285 | 3.987e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6237]` | 0.2348379073 | 0.1786744476 | 2.392e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6238]` | -0.1606453064 | -0.1508535967 | 6.095e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6239]` | 0.4501304972 | 0.5109950902 | 1.352e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6240]` | 0.3032506962 | 0.3243443838 | 6.956e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6241]` | 0.2276531668 | 0.2860268237 | 2.564e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6242]` | -0.206680993 | -0.2883839142 | 3.953e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6243]` | 0.7402039137 | 0.8187687742 | 1.061e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6244]` | -0.8714579836 | -0.9277785634 | 6.463e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6245]` | -0.7700297266 | -0.8812584305 | 1.444e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6246]` | -0.4272383823 | -0.5394481824 | 2.626e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6247]` | -0.08998259201 | -0.07064078541 | 2.150e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6248]` | -1.65160672 | -1.568863855 | 5.010e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6249]` | -0.1090816862 | -0.08896311626 | 1.844e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6250]` | 0.3202931355 | 0.371783653 | 1.608e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6251]` | -0.8512348925 | -0.9440116888 | 1.090e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6252]` | 1.42899253 | 1.212758762 | 1.513e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6253]` | 2.226296712 | 2.241043056 | 6.624e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6254]` | 0.3636126613 | 0.403158606 | 1.088e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6255]` | -1.804536008 | -1.837284952 | 1.815e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6256]` | -1.824842818 | -1.796762145 | 1.539e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6257]` | 0.9939686333 | 0.8477432774 | 1.471e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6258]` | 0.08490083717 | 0.2284193769 | 1.690e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6259]` | -0.3097500526 | -0.236874028 | 2.353e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6260]` | -1.311556514 | -1.257149369 | 4.148e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6261]` | 0.4829237637 | 0.5668362916 | 1.738e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6262]` | 2.437248583 | 2.352472892 | 3.478e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6263]` | -0.349316294 | -0.4421000804 | 2.656e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6264]` | -0.08601787801 | -0.05710093902 | 3.362e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6265]` | -0.9021490056 | -0.8627946644 | 4.362e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6266]` | -0.06701451595 | 0.01229656741 | 1.183e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6267]` | 0.8671372111 | 0.8206293923 | 5.363e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6268]` | 0.6347473626 | 0.6061053586 | 4.512e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6269]` | 0.06021537183 | 0.06842925104 | 1.364e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6270]` | -0.2021457877 | -0.2070744002 | 2.438e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6271]` | 1.943848392 | 1.99758503 | 2.764e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6272]` | 0.2205671952 | 0.2488677641 | 1.283e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6273]` | 0.8613741595 | 0.7653651215 | 1.115e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6274]` | -0.3099258862 | -0.3290920398 | 6.184e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6275]` | -0.4412615914 | -0.5329629161 | 2.078e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6276]` | -0.5264232997 | -0.6048297541 | 1.489e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6277]` | 0.9848882022 | 0.7214049217 | 2.675e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6278]` | -0.7822433359 | -0.719181637 | 8.062e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6279]` | -3.616481563 | -3.653393815 | 1.021e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6280]` | 0.3955608368 | 0.4751968353 | 2.013e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6281]` | -2.345543823 | -2.285792968 | 2.547e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6282]` | -0.2295022134 | -0.2843210615 | 2.389e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6283]` | 0.1817705691 | 0.05273434354 | 7.099e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6284]` | -1.196466658 | -1.203155939 | 5.591e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6285]` | -0.7566316559 | -0.8210046248 | 8.508e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6286]` | 0.0751820717 | 0.09243954736 | 2.295e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6287]` | -0.06162693589 | -0.07423427817 | 2.046e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6288]` | 0.0216581419 | 0.0223497962 | 3.194e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6289]` | 1.926148715 | 1.819590571 | 5.532e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6290]` | -0.03845206042 | -0.05408054981 | 4.064e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6291]` | 0.1039489993 | 0.2016532076 | 9.399e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6292]` | -0.6431985065 | -0.6345779215 | 1.340e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6293]` | -1.025752334 | -1.055043438 | 2.856e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6294]` | 0.2834285963 | 0.3157479562 | 1.140e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6295]` | -1.591406421 | -1.492942351 | 6.187e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6296]` | -0.09811531413 | -0.1368917134 | 3.952e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6297]` | 0.2001024349 | 0.005704507781 | 9.715e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6298]` | 0.7688359423 | 0.865869709 | 1.262e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6299]` | 1.248385467 | 1.136814881 | 8.937e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6300]` | -0.03442669244 | -0.09204820242 | 1.674e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6301]` | -1.690083927 | -1.437820766 | 1.493e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6302]` | -0.05096497673 | -0.1185122398 | 1.325e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6303]` | -0.146940242 | -0.1666704876 | 1.343e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6304]` | 0.6624188877 | 0.6445803521 | 2.693e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6305]` | -0.5332095113 | -0.617882545 | 1.588e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6306]` | 0.7111758313 | 0.6129432657 | 1.381e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6307]` | 1.39744469 | 1.351999314 | 3.252e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6308]` | 0.855909651 | 0.8224657243 | 3.907e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6309]` | 0.3678040774 | 0.416889736 | 1.335e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6310]` | 0.7723194562 | 0.8040043734 | 4.103e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6311]` | -0.4271911779 | -0.282567761 | 3.385e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6312]` | 0.971157724 | 1.01461786 | 4.475e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6313]` | 2.258839902 | 2.120014775 | 6.146e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6314]` | 0.425527441 | 0.4952578624 | 1.639e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6315]` | -1.955519365 | -1.931792184 | 1.213e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6316]` | 0.8605434356 | 0.899091596 | 4.480e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6317]` | 1.36468107 | 1.407035772 | 3.104e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6318]` | 0.3590131139 | 0.4004414543 | 1.154e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6319]` | -1.705256281 | -1.686311596 | 1.111e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6320]` | 0.3685924977 | 0.43945548 | 1.923e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6321]` | 0.4148853833 | 0.5454185818 | 3.146e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6322]` | 2.22887176 | 2.188045318 | 1.832e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6323]` | -0.4210234708 | -0.3181147051 | 2.444e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6324]` | 0.6431262555 | 0.6230024063 | 3.129e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6325]` | -2.027177848 | -2.019570678 | 3.753e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6326]` | -0.631242056 | -0.6875709791 | 8.924e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6327]` | -2.087780426 | -2.039296342 | 2.322e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6328]` | -0.769022561 | -0.8048861399 | 4.664e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6329]` | -2.005789249 | -2.005368578 | 2.097e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6330]` | 0.4706597601 | 0.3703430993 | 2.131e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6331]` | 1.226728611 | 1.228468267 | 1.418e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6332]` | 1.08713623 | 1.140872193 | 4.943e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6333]` | 0.214057778 | 0.2169987715 | 1.374e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6334]` | 0.4386838916 | 0.4783928407 | 9.052e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6335]` | 0.5232469137 | 0.5561570751 | 6.290e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6336]` | -0.7924997962 | -0.7589247223 | 4.237e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6337]` | -0.8926579958 | -0.947948625 | 6.194e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6338]` | -0.3205325848 | -0.346868209 | 8.216e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6339]` | 0.6705346387 | 0.5772711772 | 1.391e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6340]` | 0.08135680747 | 0.1224251887 | 5.048e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6341]` | 0.1919448005 | 0.2713098918 | 4.135e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6342]` | -0.3444851967 | -0.2230260469 | 3.526e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6343]` | -1.279944342 | -1.345056317 | 5.087e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6344]` | 0.4476308954 | 0.5331670973 | 1.911e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6345]` | 2.750328127 | 2.808615872 | 2.119e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6346]` | -1.2090117 | -1.20752601 | 1.229e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6347]` | 0.5738861648 | 0.4730842318 | 1.756e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6348]` | 0.7466637028 | 0.6948157411 | 6.944e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6349]` | -1.659081808 | -1.562873923 | 5.799e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6350]` | 0.1360943297 | 0.2575525578 | 8.925e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6351]` | 1.549657924 | 1.378886487 | 1.102e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6352]` | -1.015426474 | -1.05969228 | 4.359e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6353]` | -0.1672759079 | -0.1892133175 | 1.311e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6354]` | -2.482933894 | -2.531476696 | 1.955e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6355]` | -0.5386714049 | -0.5349375672 | 6.932e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6356]` | -0.5625934963 | -0.6728129132 | 1.959e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6357]` | 0.2198151751 | 0.1512294977 | 3.120e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6358]` | 0.4509265084 | 0.5202709213 | 1.538e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6359]` | 0.06382205458 | 0.006895546627 | 8.920e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6360]` | 0.03483853867 | 0.1841752321 | 4.287e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6361]` | -1.09310864 | -1.079797353 | 1.218e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6362]` | 0.4236425196 | 0.4732201087 | 1.170e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6363]` | 1.729856362 | 1.733144442 | 1.901e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6364]` | 0.3824900169 | 0.4116202395 | 7.616e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6365]` | -0.1268597118 | -0.2242673698 | 7.678e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6366]` | 0.8963030218 | 0.8595873132 | 4.096e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6367]` | -0.5404363092 | -0.5219201142 | 3.426e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6368]` | -1.025956283 | -1.082882384 | 5.549e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6369]` | 1.066700063 | 1.098033258 | 2.937e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6370]` | -0.258050108 | -0.1325818361 | 4.862e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6371]` | 0.575281086 | 0.4873817414 | 1.528e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6372]` | 0.04050024066 | 0.1201948385 | 1.968e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6373]` | 1.490420156 | 1.469313536 | 1.416e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6374]` | -1.235221993 | -1.266997652 | 2.572e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6375]` | -0.08640661835 | -0.1299296148 | 5.037e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6376]` | -0.05907145287 | -0.08148847959 | 3.795e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6377]` | -1.195499743 | -1.24395859 | 4.053e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6378]` | 2.369067745 | 2.39894259 | 1.261e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6379]` | -0.3537890221 | -0.204722503 | 4.213e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6380]` | 1.20382006 | 1.246900686 | 3.579e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6381]` | 0.02679457756 | -0.03606078196 | 2.346e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6382]` | 1.714465359 | 1.685208803 | 1.706e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6383]` | -1.692974501 | -1.708329377 | 9.070e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6384]` | -1.243549956 | -1.216326273 | 2.189e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6385]` | -0.6094113219 | -0.6959052146 | 1.419e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6386]` | 0.6028609643 | 0.6755731239 | 1.206e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6387]` | -2.926215813 | -2.844917473 | 2.778e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6388]` | 1.142504655 | 1.137186053 | 4.655e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6389]` | -2.234758432 | -2.278968231 | 1.978e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6390]` | 0.3627410998 | 0.3768887496 | 3.900e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6391]` | -0.3622397845 | -0.3578884984 | 1.201e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6392]` | -0.7485431625 | -0.7163294854 | 4.304e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6393]` | -0.9663852806 | -0.9053408737 | 6.317e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6394]` | -0.4529999118 | -0.5872761763 | 2.964e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6395]` | 0.04383142391 | 0.09855661413 | 1.249e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6396]` | 0.1970225998 | 0.2492416888 | 2.650e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6397]` | 0.8337197216 | 0.7864236527 | 5.673e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6398]` | -0.107154388 | 0.01356167961 | 1.127e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6399]` | 1.597111788 | 1.509312049 | 5.497e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6400]` | 0.246578211 | 0.2951292961 | 1.969e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6401]` | -0.09604946709 | -0.07463490758 | 2.230e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6402]` | -1.531717235 | -1.478069304 | 3.502e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6403]` | 1.448635668 | 1.498516692 | 3.443e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6404]` | -0.2240361391 | -0.1546470993 | 3.097e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6405]` | -0.5673051231 | -0.6151334286 | 8.431e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6406]` | -0.3720096159 | -0.3528322084 | 5.155e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6407]` | -0.7939931648 | -0.7910868372 | 3.660e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6408]` | -0.2846042302 | -0.2245716231 | 2.109e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6409]` | 0.7762914989 | 0.7563867579 | 2.564e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6410]` | -0.9158246634 | -0.9507715182 | 3.816e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6411]` | -0.122598831 | -0.1454526609 | 1.864e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6412]` | -1.02241286 | -0.909622731 | 1.103e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6413]` | -0.3130867194 | -0.3370940195 | 7.668e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6414]` | -1.423281927 | -1.432506245 | 6.481e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6415]` | 0.1124487947 | 0.02930509178 | 7.394e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6416]` | -0.07096442522 | -0.05376089431 | 2.424e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6417]` | -1.133782564 | -1.158609024 | 2.190e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6418]` | -0.6213105211 | -0.6162276062 | 8.181e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6419]` | -0.4747153377 | -0.5428888464 | 1.436e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6420]` | -0.450630962 | -0.4142152065 | 8.081e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6421]` | 0.6259252844 | 0.5920982051 | 5.404e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6422]` | -0.6652022388 | -0.5437913556 | 1.825e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6423]` | 1.14810579 | 0.9778560166 | 1.483e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6424]` | -0.9262486972 | -1.004777414 | 8.478e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6425]` | -0.04575788416 | 0.05731302819 | 2.253e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6426]` | -1.616588041 | -1.668496582 | 3.211e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6427]` | 1.197904394 | 1.201045893 | 2.622e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6428]` | -0.5416156542 | -0.6030172808 | 1.134e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6429]` | -0.5737560718 | -0.7020801846 | 2.237e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6430]` | 2.272089 | 2.268936909 | 1.387e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6431]` | 1.223291568 | 1.132016419 | 7.461e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6432]` | 0.3658356521 | 0.3691960987 | 9.186e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6433]` | 0.1405789115 | 0.05433697102 | 6.135e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6434]` | 0.8288387954 | 0.8261613249 | 3.230e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6435]` | 0.3136229259 | 0.3191447355 | 1.761e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6436]` | -0.3076319945 | -0.2812933867 | 8.562e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6437]` | -0.853727217 | -0.7958657815 | 6.778e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6438]` | -1.457587185 | -1.479545323 | 1.506e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6439]` | -0.2200222636 | -0.2104369591 | 4.357e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6440]` | -0.4228665262 | -0.4758412643 | 1.253e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6441]` | -0.7569442121 | -0.8085505061 | 6.818e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6442]` | 2.346536661 | 2.355981201 | 4.025e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6443]` | -1.228464182 | -1.252271176 | 1.938e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6444]` | 0.4621634066 | 0.4356323155 | 5.741e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6445]` | 0.2007630497 | 0.1833038153 | 8.696e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6446]` | 1.302821436 | 1.245865247 | 4.372e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6447]` | -1.836286422 | -1.818880104 | 9.479e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6448]` | -0.8213573786 | -0.8252329522 | 4.718e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6449]` | -0.5239293222 | -0.466367854 | 1.099e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6450]` | 0.531968737 | 0.6378544948 | 1.990e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6451]` | -0.4262797609 | -0.4492308326 | 5.384e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6452]` | 0.5417827689 | 0.5267316145 | 2.778e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6453]` | 0.7140189802 | 0.7083936046 | 7.878e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6454]` | 0.612206688 | 0.6595141551 | 7.727e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6455]` | 0.3379729603 | 0.3693725632 | 9.291e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6456]` | 0.03556528611 | -0.01464926589 | 1.412e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6457]` | -1.008430392 | -1.06174958 | 5.287e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6458]` | 0.9934619969 | 1.076237941 | 8.332e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6459]` | 0.1650770758 | 0.1914213384 | 1.596e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6460]` | -0.4819479509 | -0.5024453807 | 4.253e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6461]` | -1.036427521 | -1.095817532 | 5.730e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6462]` | -0.3207550689 | -0.3862297213 | 2.041e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6463]` | -0.5175450591 | -0.520950949 | 6.581e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6464]` | 0.5877990596 | 0.5538036956 | 5.784e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6465]` | 0.005603633894 | -0.1545453538 | 2.858e+01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6466]` | 0.4075149463 | 0.4268184639 | 4.737e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6467]` | -1.840179641 | -1.865286701 | 1.364e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6468]` | 0.9087868029 | 0.9832385138 | 8.192e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6469]` | -0.1181914418 | -0.0247880463 | 7.903e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6470]` | 0.670987739 | 0.7285437444 | 8.578e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6471]` | 1.665042262 | 1.541085532 | 7.445e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6472]` | -2.037447648 | -2.055675197 | 8.946e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6473]` | -0.2927169881 | -0.2054135782 | 2.983e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6474]` | -1.241097537 | -1.205083102 | 2.902e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6475]` | 0.8892169223 | 0.7841362285 | 1.182e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6476]` | 0.6307949079 | 0.5849547405 | 7.267e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6477]` | -0.524369862 | -0.5394836507 | 2.882e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6478]` | 1.099364637 | 1.152340584 | 4.819e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6479]` | -0.9181061348 | -0.8101382633 | 1.176e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6480]` | 1.338704034 | 1.394803119 | 4.191e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6481]` | 0.6067468179 | 0.6536562585 | 7.731e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6482]` | 0.08720293179 | -0.04232838242 | 1.485e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6483]` | -1.259102399 | -1.233075077 | 2.067e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6484]` | -0.3340531073 | -0.4245973795 | 2.710e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6485]` | 0.3713446284 | 0.4535735342 | 2.214e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6486]` | 1.482847669 | 1.505411984 | 1.522e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6487]` | -0.8855269805 | -0.8325597176 | 5.981e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6488]` | -0.5014301447 | -0.4773123448 | 4.810e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6489]` | 1.084954056 | 1.124850125 | 3.677e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6490]` | -1.382106688 | -1.389928213 | 5.659e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6491]` | -0.1804503169 | -0.1376388483 | 2.372e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6492]` | 0.02175373441 | 0.05612708208 | 1.580e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6493]` | 0.3895058285 | 0.3619430169 | 7.076e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6494]` | 0.9961574677 | 1.089672017 | 9.388e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6495]` | -0.9118195185 | -0.8989124506 | 1.416e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6496]` | -0.8276225721 | -0.8200857191 | 9.107e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6497]` | -0.597594076 | -0.5428663486 | 9.158e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6498]` | -1.167448357 | -1.19057706 | 1.981e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6499]` | -0.588645771 | -0.5354659312 | 9.034e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6500]` | -0.02050694671 | -0.1119524141 | 4.459e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6501]` | 1.4591448 | 1.43540818 | 1.627e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6502]` | 2.797309338 | 2.854314803 | 2.038e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6503]` | 0.2797745825 | 0.3870563405 | 3.835e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6504]` | -0.3718560923 | -0.4502378258 | 2.108e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6505]` | 0.4843829779 | 0.5159551016 | 6.518e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6506]` | -4.266672538 | -4.151264875 | 2.705e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6507]` | 0.6253556405 | 0.6692406662 | 7.018e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6508]` | -0.5544402303 | -0.5659517822 | 2.076e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6509]` | -0.7981729367 | -0.8043806696 | 7.777e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6510]` | -0.06471377081 | -0.05901103478 | 8.812e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6511]` | 0.9676499555 | 1.042142475 | 7.698e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6512]` | -1.625855215 | -1.640790664 | 9.186e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6513]` | -1.312150191 | -1.372462426 | 4.596e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6514]` | 2.262589454 | 2.16590714 | 4.273e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6515]` | 0.8452244904 | 0.8301942951 | 1.778e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6516]` | -0.5471142535 | -0.4579527311 | 1.630e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6517]` | 1.174338523 | 1.182115595 | 6.623e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6518]` | 1.964787901 | 2.011186183 | 2.361e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6519]` | -0.4000415919 | -0.46191455 | 1.547e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6520]` | -0.3622250157 | -0.2612961182 | 2.786e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6521]` | -0.1416928017 | -0.1625977996 | 1.475e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6522]` | -1.076612 | -1.106079421 | 2.737e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6523]` | -0.06678431281 | -0.05073021005 | 2.404e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6524]` | 1.333891502 | 1.314987174 | 1.417e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6525]` | 0.805666699 | 0.8882182353 | 1.025e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6526]` | -0.176315998 | -0.2387590894 | 3.542e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6527]` | 1.616672034 | 1.663162645 | 2.876e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6528]` | -1.008048768 | -0.9617423006 | 4.594e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6529]` | 0.3291933957 | 0.3562110482 | 8.207e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6530]` | -0.6923113447 | -0.7637491575 | 1.032e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6531]` | 2.023699293 | 1.741499084 | 1.394e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6532]` | -0.08770545737 | -0.2749108397 | 2.134e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6533]` | -0.9011460781 | -0.8230084979 | 8.671e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6534]` | 0.2280315645 | 0.330100359 | 4.476e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6535]` | 1.216520084 | 1.150094975 | 5.460e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6536]` | 0.5238203491 | 0.6402464846 | 2.223e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6537]` | 0.3034459643 | 0.1936403773 | 3.619e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6538]` | -0.3897467798 | -0.4113266104 | 5.537e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6539]` | -0.8531953946 | -0.85958906 | 7.494e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6540]` | 0.8677271142 | 0.8646918322 | 3.498e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6541]` | -0.1561468685 | -0.2299811699 | 4.729e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6542]` | -0.7879029624 | -0.8982365508 | 1.400e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6543]` | -0.007221784784 | -0.1261144603 | 1.646e+01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6544]` | 0.4528091058 | 0.5355707741 | 1.828e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6545]` | -1.089764733 | -1.109049572 | 1.770e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6546]` | 0.3349167155 | 0.4547130016 | 3.577e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6547]` | -0.8378119307 | -0.821422143 | 1.956e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6548]` | -0.02283952807 | 0.06999560098 | 4.065e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6549]` | -0.3492150916 | -0.3353402302 | 3.973e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6550]` | -0.2783336731 | -0.3010802609 | 8.172e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6551]` | -0.009074539077 | -0.006713966542 | 2.601e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6552]` | -1.354590266 | -1.387878621 | 2.457e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6553]` | 0.9874235744 | 0.931866434 | 5.626e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6554]` | 1.080836293 | 1.018711954 | 5.748e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6555]` | -1.039180042 | -1.129226953 | 8.665e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6556]` | 1.250784162 | 1.264513351 | 1.098e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6557]` | 0.5369487389 | 0.5990479379 | 1.157e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6558]` | 0.2611800216 | 0.2173695489 | 1.677e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6559]` | 0.001766748354 | -0.06715059766 | 3.901e+01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6560]` | 0.8720362042 | 0.9210747057 | 5.623e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6561]` | -1.420417825 | -1.412599272 | 5.504e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6562]` | -0.8987982905 | -1.001724036 | 1.145e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6563]` | 0.4703193647 | 0.5514175676 | 1.724e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6564]` | -1.215596696 | -1.231535927 | 1.311e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6565]` | -0.7268144871 | -0.6808159315 | 6.329e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6566]` | 1.249120805 | 1.126526762 | 9.814e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6567]` | -0.8556117429 | -0.7958745908 | 6.982e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6568]` | 0.1193351478 | 0.1746790504 | 4.638e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6569]` | 0.9369009448 | 0.8453368263 | 9.773e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6570]` | 0.4294761611 | 0.448494403 | 4.428e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6571]` | -0.1464464993 | -0.1968519829 | 3.442e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6572]` | -0.5323350241 | -0.6178002406 | 1.605e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6573]` | 1.752473861 | 1.777200387 | 1.411e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6574]` | 1.128733439 | 1.201151259 | 6.416e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6575]` | -1.414123483 | -1.486074547 | 5.088e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6576]` | 1.931882458 | 1.785094888 | 7.598e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6577]` | -2.592482752 | -2.593440674 | 3.695e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6578]` | 1.625709565 | 1.561693925 | 3.938e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6579]` | -0.5390223575 | -0.5563785613 | 3.220e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6580]` | 0.610291726 | 0.6476283006 | 6.118e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6581]` | 0.5092041456 | 0.6018505541 | 1.819e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6582]` | -0.2765913573 | -0.3715429456 | 3.433e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6583]` | 2.039909308 | 1.997635915 | 2.072e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6584]` | -1.180101191 | -1.197568505 | 1.480e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6585]` | 1.432190128 | 1.453017761 | 1.454e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6586]` | -0.7204552572 | -0.7771142216 | 7.864e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6587]` | -0.8160136984 | -0.7753921156 | 4.978e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6588]` | 1.220535766 | 1.301749419 | 6.654e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6589]` | 1.265490043 | 1.304352435 | 3.071e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6590]` | -0.8652250904 | -0.8690665971 | 4.440e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6591]` | 0.4941783702 | 0.5004437804 | 1.268e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6592]` | 0.3951075137 | 0.4018983039 | 1.719e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6593]` | -0.4537144196 | -0.4457754067 | 1.750e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6594]` | 0.1992791748 | 0.1757553881 | 1.180e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6595]` | 0.9838746149 | 1.019133448 | 3.584e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6596]` | 0.1874113562 | 0.1627377012 | 1.317e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6597]` | 0.61523351 | 0.6368527557 | 3.514e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6598]` | 1.056382992 | 0.9590144865 | 9.217e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6599]` | 0.2187731342 | 0.2366509103 | 8.172e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6600]` | -0.1916918401 | -0.2564308482 | 3.377e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6601]` | 1.063298708 | 1.082172447 | 1.775e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6602]` | 0.1596570009 | 0.06117890201 | 6.168e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6603]` | -0.1863471951 | -0.2279116268 | 2.230e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6604]` | -0.8386215552 | -0.8480133817 | 1.120e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6605]` | 0.1210960563 | 0.05566008765 | 5.404e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6606]` | 1.84309387 | 1.828189233 | 8.087e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6607]` | -0.1012369362 | -0.05127560308 | 4.935e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6608]` | -2.255951357 | -2.210479932 | 2.016e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6609]` | 1.179375425 | 1.238833316 | 5.041e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6610]` | -1.335287542 | -1.241864989 | 6.996e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6611]` | 2.673776621 | 2.692437499 | 6.979e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6612]` | 0.498965198 | 0.400636162 | 1.971e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6613]` | 1.159855652 | 1.09859175 | 5.282e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6614]` | 1.445999743 | 1.417364482 | 1.980e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6615]` | -1.299515507 | -1.367025062 | 5.195e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6616]` | -0.3428021121 | -0.3992497534 | 1.647e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6617]` | -0.1251301627 | -0.1867439131 | 4.924e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6618]` | 0.8211098192 | 0.7457203298 | 9.181e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6619]` | 0.3247420793 | 0.4536074978 | 3.968e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6620]` | 0.1447538447 | 0.09578288749 | 3.383e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6621]` | 0.712357156 | 0.7143124326 | 2.745e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6622]` | -1.320565511 | -1.325148874 | 3.471e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6623]` | -1.464660913 | -1.517765959 | 3.626e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6624]` | -1.864020734 | -1.878883068 | 7.973e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6625]` | 0.6358179775 | 0.418299681 | 3.421e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6626]` | -0.8862175138 | -0.8861514214 | 7.458e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6627]` | 1.169791604 | 1.232658256 | 5.374e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6628]` | -0.1908672671 | -0.265480822 | 3.909e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6629]` | 0.5033473502 | 0.5735564358 | 1.395e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6630]` | -1.594626099 | -1.557438483 | 2.332e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6631]` | 0.4099829973 | 0.4606082585 | 1.235e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6632]` | -0.1535439214 | -0.2236212086 | 4.564e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6633]` | -1.252751025 | -1.136390714 | 9.288e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6634]` | 1.036771844 | 1.108373471 | 6.906e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6635]` | -0.1915520156 | -0.1831416517 | 4.391e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6636]` | 0.5034385636 | 0.5932794296 | 1.785e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6637]` | -0.2673305449 | -0.164663917 | 3.840e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6638]` | 1.209713308 | 1.199549347 | 8.402e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6639]` | 0.7478530261 | 0.7405478399 | 9.768e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6640]` | -0.02530408193 | -0.1822206545 | 6.201e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6641]` | -1.25016859 | -1.314209207 | 5.123e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6642]` | 0.05800989838 | 0.04742934156 | 1.824e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6643]` | -0.2154270973 | -0.1566464864 | 2.729e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6644]` | -0.8652975798 | -0.7385112261 | 1.465e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6645]` | -0.6740629557 | -0.6997585118 | 3.812e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6646]` | -0.4663384903 | -0.4509772256 | 3.294e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6647]` | 2.035703852 | 1.973388534 | 3.061e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6648]` | 0.5256066929 | 0.4027924522 | 2.337e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6649]` | 0.2271363355 | 0.3362083492 | 4.802e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6650]` | 1.630450816 | 1.648273464 | 1.093e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6651]` | 0.1043150763 | 0.1465312967 | 4.047e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6652]` | 0.4138534537 | 0.3518047638 | 1.499e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6653]` | -0.5144407646 | -0.6461012621 | 2.559e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6654]` | 0.4244661201 | 0.3130713956 | 2.624e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6655]` | 0.946392635 | 0.9852759223 | 4.109e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6656]` | 0.8429471566 | 0.8285457028 | 1.708e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6657]` | -1.958734477 | -1.953551046 | 2.646e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6658]` | -0.8262906722 | -0.8693999025 | 5.217e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6659]` | -0.2336432686 | -0.1958793486 | 1.616e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6660]` | -1.152861076 | -1.204016605 | 4.437e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6661]` | -0.503572485 | -0.4820538097 | 4.273e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6662]` | -0.2895034184 | -0.3432050185 | 1.855e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6663]` | -0.7195064437 | -0.7628583291 | 6.025e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6664]` | 1.895395006 | 1.921740168 | 1.390e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6665]` | -0.6537914189 | -0.7344230231 | 1.233e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6666]` | 1.009542544 | 0.9939232012 | 1.547e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6667]` | -0.7155732176 | -0.8193223536 | 1.450e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6668]` | 1.10927078 | 1.191786085 | 7.439e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6669]` | 0.628705179 | 0.6927833204 | 1.019e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6670]` | -2.121558867 | -2.028955473 | 4.365e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6671]` | -0.3779945952 | -0.4704285655 | 2.445e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6672]` | 1.253403473 | 1.088292885 | 1.317e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6673]` | -1.676841261 | -1.560790647 | 6.921e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6674]` | 0.1864458967 | 0.1536212607 | 1.761e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6675]` | -0.5566716504 | -0.6990031998 | 2.557e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6676]` | -1.234984601 | -1.174611909 | 4.889e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6677]` | 0.2659509055 | 0.1650405786 | 3.794e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6678]` | 1.060179933 | 1.135870375 | 7.139e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6679]` | 1.599785147 | 1.606154648 | 3.981e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6680]` | -1.275980975 | -1.330154274 | 4.246e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6681]` | 0.08182864368 | 0.2069606141 | 1.529e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6682]` | -1.516844832 | -1.500252325 | 1.094e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6683]` | 0.4842470897 | 0.5559968106 | 1.482e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6684]` | 1.387748213 | 1.194534198 | 1.392e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6685]` | -0.1130902767 | -0.09304843039 | 1.772e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6686]` | -1.141047081 | -1.119524244 | 1.886e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6687]` | 0.1027122318 | 0.1462918182 | 4.243e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6688]` | 0.1228525387 | 0.2194499784 | 7.863e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6689]` | -0.4493348317 | -0.5483261389 | 2.203e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6690]` | 0.7497643974 | 0.6549423942 | 1.265e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6691]` | -0.8845077198 | -0.8918389588 | 8.288e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6692]` | -1.299577047 | -1.241203266 | 4.492e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6693]` | -1.475208145 | -1.521571135 | 3.143e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6694]` | -3.710189949 | -3.758203544 | 1.294e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6695]` | -0.09090177136 | -0.0812094864 | 1.066e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6696]` | 0.3165962587 | 0.2272451256 | 2.822e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6697]` | 1.742358839 | 1.673833831 | 3.933e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6698]` | 0.6336688736 | 0.6241769017 | 1.498e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6699]` | 0.3930334128 | 0.4745643845 | 2.074e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6700]` | 0.2966443349 | 0.2063183676 | 3.045e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6701]` | 0.4905998693 | 0.5319402441 | 8.426e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6702]` | -0.9047561718 | -1.00659588 | 1.126e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6703]` | 0.5928202013 | 0.6451476887 | 8.827e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6704]` | 0.4193825444 | 0.5577163111 | 3.299e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6705]` | 1.304158817 | 1.319535793 | 1.179e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6706]` | -0.5070722742 | -0.5566801373 | 9.783e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6707]` | 0.643168231 | 0.6957133302 | 8.170e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6708]` | -0.2922220065 | -0.298407584 | 2.117e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6709]` | -0.3389075053 | -0.3910690327 | 1.539e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6710]` | 0.9625517031 | 0.9405580492 | 2.285e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6711]` | -0.7466552864 | -0.7347867995 | 1.590e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6712]` | -1.501796841 | -1.53525295 | 2.228e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6713]` | -0.4422986651 | -0.5155246761 | 1.656e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6714]` | -0.8263865309 | -0.8877288308 | 7.423e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6715]` | 0.0320642812 | -0.02936663566 | 1.916e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6716]` | -1.435193214 | -1.472247117 | 2.582e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6717]` | -0.5883341574 | -0.6010764531 | 2.166e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6718]` | 0.5515430055 | 0.5794997068 | 5.069e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6719]` | -0.03152315493 | -0.06577436966 | 1.087e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6720]` | 0.483659042 | 0.4573598813 | 5.438e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6721]` | 1.08100948 | 1.154338983 | 6.783e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6722]` | -0.1509844329 | -0.116976035 | 2.252e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6723]` | 0.5793424942 | 0.5004043845 | 1.363e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6724]` | -0.6767651936 | -0.7514698684 | 1.104e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6725]` | -1.127864009 | -1.13132897 | 3.072e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6726]` | 0.4472836785 | 0.3756945595 | 1.601e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6727]` | 0.7211564121 | 0.7796425178 | 8.110e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6728]` | 0.6004981421 | 0.5814226388 | 3.177e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6729]` | 0.9180039463 | 1.015597722 | 1.063e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6730]` | 1.022716056 | 1.084742089 | 6.065e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6731]` | 0.6147683401 | 0.7251669264 | 1.796e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6732]` | -0.03323193234 | -0.1583271906 | 3.764e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6733]` | 2.244562899 | 2.231069809 | 6.011e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6734]` | -0.4202261038 | -0.4390144296 | 4.471e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6735]` | -0.07434646222 | -0.08542286027 | 1.490e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6736]` | -0.1188302453 | -0.2819562835 | 1.373e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6737]` | -0.6055592279 | -0.71279679 | 1.771e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6738]` | -0.3107353461 | -0.2897171694 | 6.764e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6739]` | 1.254903153 | 1.14228223 | 8.974e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6740]` | -1.287250532 | -1.311862278 | 1.912e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6741]` | -0.8201975173 | -0.7487620206 | 8.710e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6742]` | 2.597480429 | 2.488143657 | 4.209e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6743]` | -0.7889880311 | -0.7986339405 | 1.223e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6744]` | -0.3246014801 | -0.3209994598 | 1.110e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6745]` | 1.192150104 | 1.261975743 | 5.857e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6746]` | -1.950296075 | -1.996317862 | 2.360e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6747]` | -0.1416481355 | -0.1506016775 | 6.321e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6748]` | -1.418679723 | -1.426081534 | 5.217e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6749]` | -1.187520121 | -1.270454638 | 6.984e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6750]` | -1.117806803 | -1.071578069 | 4.136e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6751]` | 0.5748969407 | 0.6125695702 | 6.553e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6752]` | -1.12975279 | -1.160134337 | 2.689e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6753]` | 1.344231309 | 1.313032911 | 2.321e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6754]` | -0.2775049108 | -0.3260950476 | 1.751e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6755]` | -0.07984937648 | -0.1145431948 | 4.345e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6756]` | 0.7150906792 | 0.7780539153 | 8.805e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6757]` | 0.1432642059 | 0.1640910209 | 1.454e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6758]` | 1.692456049 | 1.759034152 | 3.934e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6759]` | -1.398497867 | -1.424945259 | 1.891e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6760]` | -0.3209482794 | -0.4018870597 | 2.522e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6761]` | -0.3786557565 | -0.3942541134 | 4.119e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6762]` | 1.018813079 | 0.8975176841 | 1.191e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6763]` | 1.258606991 | 1.247571717 | 8.768e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6764]` | -1.137828995 | -1.108221579 | 2.602e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6765]` | 0.8488903488 | 0.7853803006 | 7.482e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6766]` | -1.173755713 | -1.089884819 | 7.146e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6767]` | -2.364134197 | -2.328571044 | 1.504e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6768]` | 0.3412191747 | 0.3630835108 | 6.408e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6769]` | -0.4583885461 | -0.5582102318 | 2.178e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6770]` | 1.102066345 | 0.986179567 | 1.052e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6771]` | 0.7191329511 | 0.8059622387 | 1.207e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6772]` | 3.27415453 | 3.261865547 | 3.753e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6773]` | 0.9462897252 | 0.9689316242 | 2.393e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6774]` | 0.4347407681 | 0.493625956 | 1.354e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6775]` | -1.418354896 | -1.419334624 | 6.907e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6776]` | 0.5674478235 | 0.6213631953 | 9.501e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6777]` | -2.63049972 | -2.678886466 | 1.839e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6778]` | 1.359041893 | 1.383544224 | 1.803e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6779]` | -0.2474903866 | -0.3015918978 | 2.186e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6780]` | 0.1678130158 | 0.1447609509 | 1.374e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6781]` | 0.795940761 | 0.6579523607 | 1.734e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6782]` | -0.1615554439 | -0.1965803834 | 2.168e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6783]` | -0.9948439679 | -0.9676904739 | 2.729e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6784]` | 0.1684808473 | 0.1312448295 | 2.210e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6785]` | -0.8412654916 | -0.7942955275 | 5.583e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6786]` | -0.4918987523 | -0.4987639263 | 1.396e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6787]` | -1.632795797 | -1.586318897 | 2.846e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6788]` | -1.595097075 | -1.639239785 | 2.767e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6789]` | 0.01863728905 | 0.03513254764 | 8.851e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6790]` | 1.062078629 | 1.070321564 | 7.761e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6791]` | -0.3022190751 | -0.3159107835 | 4.530e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6792]` | -0.2730602074 | -0.3502864838 | 2.828e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6793]` | 0.64860396 | 0.6278718695 | 3.196e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6794]` | 1.623345605 | 1.606174134 | 1.058e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6795]` | -0.1429823221 | -0.06204245704 | 5.661e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6796]` | 0.4783211003 | 0.4650244613 | 2.780e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6797]` | -0.1006809969 | 0.03062763033 | 1.304e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6798]` | -1.005578996 | -1.07268458 | 6.673e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6799]` | -0.07522803642 | -0.02058339796 | 7.264e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6800]` | -0.4153585867 | -0.3481859279 | 1.617e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6801]` | -0.9511660314 | -0.8886044366 | 6.577e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6802]` | -1.34737742 | -1.392148731 | 3.323e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6803]` | -0.1570200244 | -0.01093801771 | 9.303e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6804]` | 1.020878774 | 1.041341709 | 2.004e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6805]` | 1.747804737 | 1.687562163 | 3.447e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6806]` | 0.6167716815 | 0.5452466639 | 1.160e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6807]` | -1.124725766 | -1.194720468 | 6.223e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6808]` | 0.8443829688 | 0.8787398904 | 4.069e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6809]` | -0.521512133 | -0.6680010419 | 2.809e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6810]` | -0.3191222649 | -0.3160146695 | 9.738e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6811]` | 1.866308169 | 1.879443132 | 7.038e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6812]` | 2.675379192 | 2.697442282 | 8.247e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6813]` | 0.3998752732 | 0.3729233909 | 6.740e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6814]` | -1.374740669 | -1.381989453 | 5.273e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6815]` | 0.8219642523 | 0.8245184719 | 3.107e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6816]` | -2.571380652 | -2.613953528 | 1.656e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6817]` | -0.9023219244 | -0.9019865771 | 3.716e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6818]` | -0.8950720678 | -0.9216120664 | 2.965e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6819]` | 0.6379958149 | 0.6395506473 | 2.437e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6820]` | -2.156613064 | -2.17997309 | 1.083e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6821]` | 0.8621730052 | 0.8638013309 | 1.889e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6822]` | 0.1438860674 | 0.05375254338 | 6.264e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6823]` | 0.370232695 | 0.3269372103 | 1.169e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6824]` | -0.947131773 | -0.9571079189 | 1.053e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6825]` | -0.4796608898 | -0.5941417497 | 2.387e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6826]` | 1.478110917 | 1.54829668 | 4.748e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6827]` | -0.1392070403 | -0.1998938828 | 4.359e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6828]` | 0.8437487447 | 0.8598080067 | 1.903e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6829]` | 0.01163400687 | -0.08920536723 | 8.668e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6830]` | -1.265964573 | -1.323131024 | 4.516e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6831]` | 1.216803778 | 1.216043396 | 6.249e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6832]` | -0.243195192 | -0.3534544596 | 4.534e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6833]` | 1.023880057 | 1.08991819 | 6.450e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6834]` | 0.5106020687 | 0.5553763924 | 8.769e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6835]` | -1.233746586 | -1.315640852 | 6.638e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6836]` | -0.1870152721 | -0.1952671388 | 4.412e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6837]` | 1.981098789 | 1.944999281 | 1.822e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6838]` | -0.8933079665 | -0.8311927462 | 6.953e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6839]` | -0.1470756749 | -0.2118266521 | 4.403e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6840]` | 0.3645537921 | 0.4190011954 | 1.494e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6841]` | -0.9044459586 | -0.9956591054 | 1.008e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6842]` | -1.119893442 | -1.129525347 | 8.601e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6843]` | 0.5204588337 | 0.5419310368 | 4.126e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6844]` | -0.2555124051 | -0.2739096064 | 7.200e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6845]` | -0.3106372447 | -0.256023771 | 1.758e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6846]` | -1.819781441 | -1.758581523 | 3.363e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6847]` | -0.4526647875 | -0.4315559906 | 4.663e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6848]` | 1.765127451 | 1.829672472 | 3.657e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6849]` | 0.09967179656 | 0.2168372491 | 1.176e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6850]` | -0.5852799162 | -0.5103528908 | 1.280e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6851]` | 1.871043927 | 1.909802143 | 2.071e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6852]` | -0.6826971349 | -0.7373060152 | 7.999e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6853]` | 0.7497896911 | 0.800040149 | 6.702e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6854]` | -0.4477351233 | -0.4526700887 | 1.102e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6855]` | 0.271647272 | 0.269249142 | 8.828e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6856]` | 0.08558317392 | 0.1482054943 | 7.317e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6857]` | -0.2841293443 | -0.4045004583 | 4.236e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6858]` | 0.05178086283 | 0.001910918171 | 9.631e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6859]` | -0.2882149073 | -0.3804958169 | 3.202e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6860]` | 0.7982408181 | 0.8840235365 | 1.075e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6861]` | 2.303721889 | 2.189833647 | 4.944e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6862]` | 0.6685205865 | 0.7181705351 | 7.427e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6863]` | -1.920524626 | -1.802601933 | 6.140e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6864]` | -0.133266472 | -0.2156527749 | 6.182e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6865]` | -1.465288969 | -1.220901722 | 1.668e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6866]` | -0.4007636172 | -0.518095571 | 2.928e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6867]` | -2.618065563 | -2.489169034 | 4.923e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6868]` | -0.5274902605 | -0.6294065605 | 1.932e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6869]` | 0.6016065638 | 0.509261911 | 1.535e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6870]` | -0.2075206541 | -0.1623726942 | 2.176e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6871]` | -1.741815728 | -1.792836143 | 2.929e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6872]` | 0.5958662128 | 0.6310459935 | 5.904e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6873]` | -0.07707138558 | -0.06504784597 | 1.560e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6874]` | 1.104750934 | 1.100841887 | 3.538e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6875]` | -0.9940313715 | -1.000858541 | 6.868e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6876]` | -0.8237087972 | -0.7051934704 | 1.439e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6877]` | -1.688341258 | -1.617250995 | 4.211e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6878]` | -0.5107476109 | -0.5834307939 | 1.423e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6879]` | -0.5114872426 | -0.4279067046 | 1.634e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6880]` | 0.571981424 | 0.6341856988 | 1.088e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6881]` | 0.4017657707 | 0.4550486213 | 1.326e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6882]` | -1.962860817 | -1.937956298 | 1.269e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6883]` | 0.8118067669 | 0.7826845574 | 3.587e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6884]` | 1.152497328 | 1.187881465 | 3.070e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6885]` | 2.004445961 | 2.019068311 | 7.295e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6886]` | -1.613819969 | -1.60477178 | 5.607e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6887]` | -0.5451620228 | -0.625622929 | 1.476e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6888]` | -0.75242557 | -0.7463422553 | 8.085e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6889]` | 0.1861289433 | 0.1818671343 | 2.290e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6890]` | 0.3869598436 | 0.5046096419 | 3.040e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6891]` | 1.50668886 | 1.541473381 | 2.309e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6892]` | -1.05360294 | -1.019252133 | 3.260e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6893]` | 1.483614221 | 1.435273414 | 3.258e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6894]` | 1.000704004 | 0.9644240876 | 3.625e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6895]` | -0.8451180168 | -0.8836768476 | 4.563e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6896]` | -2.041464923 | -2.094443437 | 2.595e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6897]` | -0.1312546752 | -0.1406156667 | 7.132e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6898]` | -0.2290379141 | -0.3387708158 | 4.791e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6899]` | 0.1504580868 | 0.07312724898 | 5.140e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6900]` | -0.8324765433 | -0.7046019574 | 1.536e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6901]` | 1.436214694 | 1.486501989 | 3.501e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6902]` | 0.305990772 | 0.4194952189 | 3.709e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6903]` | 0.7443103376 | 0.8394137807 | 1.278e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6904]` | 1.540233889 | 1.58240136 | 2.738e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6905]` | 0.475399439 | 0.4914333717 | 3.373e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6906]` | 1.40927321 | 1.447570202 | 2.717e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6907]` | 0.164740041 | 0.1676714793 | 1.779e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6908]` | 0.7294475069 | 0.5837358518 | 1.998e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6909]` | -0.8924180998 | -0.7724649502 | 1.344e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6910]` | 0.002581324394 | 0.05647290159 | 2.088e+01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6911]` | -0.7489112358 | -0.7492678398 | 4.762e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6912]` | -0.6340423805 | -0.4900385772 | 2.271e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6913]` | -0.5200233751 | -0.4645888865 | 1.066e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6914]` | 0.001888020355 | 0.03825467465 | 1.926e+01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6915]` | 1.329831701 | 1.311844237 | 1.353e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6916]` | -0.09437632075 | -0.05131203875 | 4.563e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6917]` | 1.139477382 | 1.180777119 | 3.624e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6918]` | -1.941956493 | -1.969295123 | 1.408e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6919]` | -0.3321029577 | -0.239629713 | 2.784e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6920]` | 1.265714182 | 1.215257144 | 3.986e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6921]` | -1.565330669 | -1.604944736 | 2.531e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6922]` | 2.162745819 | 2.152083626 | 4.930e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6923]` | -0.8016988611 | -0.709312317 | 1.152e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6924]` | -0.6941963121 | -0.6979018052 | 5.338e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6925]` | 1.345118047 | 1.306994418 | 2.834e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6926]` | 0.007104076513 | -0.06284801076 | 9.847e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6927]` | -7.525971754e-05 | 0.08419806401 | 1.120e+03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6928]` | -1.701809426 | -1.709954095 | 4.786e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6929]` | -0.4982478682 | -0.4313180283 | 1.343e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6930]` | -0.3342481707 | -0.4221718522 | 2.630e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6931]` | 1.329279675 | 1.324171301 | 3.843e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6932]` | 0.5642083055 | 0.6466359945 | 1.461e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6933]` | 1.527805325 | 1.566931055 | 2.561e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6934]` | 0.7582231763 | 0.8033533032 | 5.952e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6935]` | 0.07856995178 | 0.07314206612 | 6.908e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6936]` | -1.240902945 | -1.272683015 | 2.561e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6937]` | 0.1799458283 | -0.0007786730669 | 1.004e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6938]` | 0.3238004311 | 0.3673467174 | 1.345e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6939]` | 1.036236459 | 1.124142191 | 8.483e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6940]` | 0.09104622429 | 0.1116969248 | 2.268e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6941]` | 1.055526416 | 1.081362304 | 2.448e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6942]` | 0.003102321691 | 0.1323827907 | 4.167e+01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6943]` | -0.06964595821 | -0.01047557417 | 8.496e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6944]` | -0.1635144247 | -0.1748937656 | 6.959e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6945]` | -0.2305878557 | -0.1951609986 | 1.536e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6946]` | -1.075958833 | -1.111204373 | 3.276e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6947]` | -2.617921531 | -2.647753108 | 1.140e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6948]` | 0.6238760394 | 0.5292014167 | 1.518e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6949]` | 0.04284016205 | -0.02908540895 | 1.679e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6950]` | 0.8390920732 | 0.8041390087 | 4.166e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6951]` | -0.3510918189 | -0.3809673428 | 8.509e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6952]` | 0.9985836167 | 1.079068778 | 8.060e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6953]` | -0.3681573057 | -0.4510042982 | 2.250e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6954]` | -0.2202746123 | -0.1311169301 | 4.048e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6955]` | 0.5028363008 | 0.5399134815 | 7.374e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6956]` | -0.105810203 | -0.1862002466 | 7.598e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6957]` | 0.9207742663 | 0.9105584995 | 1.109e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6958]` | -0.4480676375 | -0.4417257402 | 1.415e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6959]` | -0.1266158615 | -0.1799208379 | 4.210e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6960]` | 0.209167742 | 0.2952491712 | 4.115e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6961]` | -1.087562391 | -1.100657278 | 1.204e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6962]` | -1.143497257 | -1.176840648 | 2.916e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6963]` | 0.8723329394 | 0.9498446375 | 8.886e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6964]` | -2.214139427 | -2.275270676 | 2.761e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6965]` | -0.8324092712 | -0.9281422876 | 1.150e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6966]` | -0.6202789555 | -0.58050925 | 6.412e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6967]` | 0.9961034497 | 1.074997109 | 7.920e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6968]` | -0.5769136081 | -0.6523516194 | 1.308e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6969]` | 1.068078071 | 1.046843313 | 1.988e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6970]` | 0.426519641 | 0.4520976868 | 5.997e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6971]` | 0.6114065383 | 0.5920203503 | 3.171e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6972]` | -0.3346641969 | -0.3788297833 | 1.320e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6973]` | -1.279778195 | -1.229541547 | 3.925e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6974]` | -0.3928820642 | -0.4993688073 | 2.710e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6975]` | 0.9966903703 | 0.9114491271 | 8.552e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6976]` | -0.3327583725 | -0.1331532921 | 5.998e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6977]` | 1.924772224 | 1.982431611 | 2.996e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6978]` | -0.4885533208 | -0.5242544831 | 7.308e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6979]` | 0.2678895535 | 0.3227213447 | 2.047e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6980]` | 0.1048184004 | 0.1134518132 | 8.237e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6981]` | 0.8934431264 | 0.8848652898 | 9.601e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6982]` | 1.822448615 | 1.886456371 | 3.512e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6983]` | -0.6920328816 | -0.7254651986 | 4.831e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6984]` | -0.7488027636 | -0.7843187362 | 4.743e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6985]` | 1.008575426 | 0.8434175304 | 1.638e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6986]` | 1.027690335 | 0.9834609367 | 4.304e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6987]` | 1.523407292 | 1.581661421 | 3.824e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6988]` | -0.09123381536 | -0.02642563185 | 7.104e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6989]` | -0.4039434369 | -0.4692843443 | 1.618e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6990]` | -0.1529388612 | -0.09779202439 | 3.606e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6991]` | 1.071930971 | 0.8104479815 | 2.439e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6992]` | -1.357487908 | -1.403610803 | 3.398e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6993]` | -0.5045186421 | -0.5278990936 | 4.634e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[6994]` | 7.208914384 | 7.208914384 | 1.494e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[6995]` | 11.72303691 | 11.72303691 | 2.576e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[6996]` | 11.96942653 | 11.96942653 | 1.287e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[6997]` | 9.547174493 | 9.547174493 | 3.721e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[6998]` | 6.583071335 | 6.583071335 | 2.968e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[6999]` | 8.425328543 | 8.425328543 | 2.741e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7000]` | 16.91332507 | 16.91332507 | 5.041e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7001]` | 19.18837993 | 19.18837993 | 2.037e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7003]` | 5.683426031 | 5.683426031 | 6.564e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7004]` | 4.827238767 | 4.827238767 | 5.336e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7005]` | 10.666551 | 10.666551 | 1.166e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7006]` | 10.22099502 | 10.22099502 | 1.043e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7007]` | 8.821058124 | 8.821058124 | 4.269e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7008]` | 14.50126051 | 14.50126051 | 1.997e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7009]` | 15.2134402 | 15.2134402 | 1.892e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7010]` | 8.266557078 | 8.266557078 | 4.298e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7011]` | 17.41197083 | 17.41197083 | 2.061e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7012]` | 6.347525875 | 6.347525875 | 1.301e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7013]` | 4.068381222 | 4.068381222 | 2.183e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7014]` | 8.412946233 | 8.412946233 | 2.808e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7015]` | 10.93564113 | 10.93564113 | 1.192e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7016]` | 6.041299463 | 6.041299463 | 2.646e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7017]` | 2.11340364 | 2.11340364 | 1.051e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7018]` | 18.50172124 | 18.50172124 | 6.145e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7019]` | 6.51907365 | 6.51907365 | 2.725e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7020]` | 4.670124359 | 4.670124359 | 7.798e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7021]` | 10.23909461 | 10.23909461 | 2.949e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7022]` | 7.471376223 | 7.471376223 | 1.534e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7023]` | 12.64160687 | 12.64160687 | 2.290e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7024]` | 5.687367677 | 5.687367677 | 1.827e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7025]` | 8.837082948 | 8.837082948 | 6.030e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7026]` | 11.21155253 | 11.21155253 | 7.922e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7027]` | 6.222487808 | 6.222487808 | 8.764e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7028]` | 8.668255226 | 8.668255226 | 3.894e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7029]` | 9.660385808 | 9.660385808 | 3.126e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7030]` | 6.547404681 | 6.547404681 | 4.070e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7031]` | 4.200832798 | 4.200832798 | 7.189e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7032]` | 7.52004641 | 7.52004641 | 5.587e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7033]` | 14.21081086 | 14.21081086 | 5.450e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7034]` | 13.38024628 | 13.38024628 | 8.762e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7035]` | 9.990197024 | 9.990197024 | 3.378e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7036]` | 12.19896952 | 12.19896952 | 8.737e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7037]` | 8.808374036 | 8.808374036 | 7.865e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7038]` | 17.9371939 | 17.9371939 | 2.139e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7039]` | 6.63934619 | 6.63934619 | 1.472e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7040]` | 10.98238709 | 10.98238709 | 1.504e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7041]` | 6.759776183 | 6.759776183 | 2.365e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7042]` | 0.8255643929 | 0.8255643929 | 1.268e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7043]` | 9.064800274 | 9.064800274 | 1.274e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7044]` | 15.09832926 | 15.09832926 | 1.200e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7045]` | 9.069116605 | 9.069116605 | 4.505e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7046]` | 10.06020838 | 10.06020838 | 1.236e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7047]` | 8.956278816 | 8.956278816 | 7.933e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7048]` | 11.02570446 | 11.02570446 | 2.196e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7049]` | 8.507439419 | 8.507439419 | 2.902e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7050]` | 25.99924899 | 25.99924899 | 8.609e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7051]` | 7.696012521 | 7.696012521 | 7.732e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7052]` | 10.54364441 | 10.54364441 | 4.970e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7053]` | 12.11698694 | 12.11698694 | 1.091e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7054]` | 7.401247723 | 7.401247723 | 1.116e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7055]` | 8.754157504 | 8.754157504 | 1.420e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7056]` | 18.07761653 | 18.07761653 | 2.221e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7057]` | 10.29012048 | 10.29012048 | 1.726e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7058]` | 8.416662476 | 8.416662476 | 2.533e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7059]` | 3.120428396 | 3.120428396 | 2.846e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7060]` | 10.94274951 | 10.94274951 | 6.980e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7061]` | 5.875977941 | 5.875977941 | 4.383e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7062]` | 14.31760809 | 14.31760809 | 3.350e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7063]` | 12.23045195 | 12.23045195 | 7.407e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7064]` | 13.40663131 | 13.40663131 | 9.010e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7065]` | 4.977741249 | 4.977741249 | 8.922e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7066]` | 16.17941434 | 16.17941434 | 6.148e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7067]` | 6.000588761 | 6.000588761 | 1.673e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7068]` | 6.43976643 | 6.43976643 | 6.344e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7069]` | 8.955759785 | 8.955759785 | 7.141e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7070]` | 10.81706955 | 10.81706955 | 1.642e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7071]` | 6.430645243 | 6.430645243 | 4.143e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7072]` | 10.2784438 | 10.2784438 | 1.866e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7073]` | 8.712868402 | 8.712868402 | 4.281e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7074]` | 7.486135296 | 7.486135296 | 1.542e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7075]` | 13.23956267 | 13.23956267 | 8.050e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7076]` | 16.11507761 | 16.11507761 | 3.307e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7077]` | 10.6963212 | 10.6963212 | 5.314e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7078]` | 13.52620824 | 13.52620824 | 4.990e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7079]` | 5.256025141 | 5.256025141 | 2.028e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7080]` | 5.437221153 | 5.437221153 | 5.587e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7081]` | 2.721318622 | 2.721318622 | 2.774e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7082]` | 12.64331901 | 12.64331901 | 2.388e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7083]` | 9.829827411 | 9.829827411 | 9.036e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7084]` | 6.774300494 | 6.774300494 | 2.242e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7085]` | 18.31505379 | 18.31505379 | 3.686e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7086]` | 23.32450469 | 23.32450469 | 7.159e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7087]` | 7.364018481 | 7.364018481 | 1.882e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7088]` | 17.47203587 | 17.47203587 | 7.469e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7089]` | 9.165878889 | 9.165878889 | 1.202e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7090]` | 4.630103718 | 4.630103718 | 7.424e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7091]` | 6.988386038 | 6.988386038 | 2.288e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7092]` | 8.176318257 | 8.176318257 | 4.780e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7093]` | 6.427904778 | 6.427904778 | 1.520e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7094]` | 7.529642488 | 7.529642488 | 6.724e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7095]` | 10.34648771 | 10.34648771 | 1.614e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7096]` | 6.073584747 | 6.073584747 | 2.120e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7097]` | 9.739026102 | 9.739026102 | 5.472e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7098]` | 13.08904437 | 13.08904437 | 2.239e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7099]` | 11.20343141 | 11.20343141 | 7.928e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7100]` | 6.644296387 | 6.644296387 | 6.817e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7101]` | 3.861539723 | 3.861539723 | 1.438e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7102]` | 10.3605113 | 10.3605113 | 3.943e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7103]` | 8.06031483 | 8.06031483 | 2.204e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7104]` | 3.16828553 | 3.16828553 | 1.402e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7105]` | 11.88772569 | 11.88772569 | 7.770e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7106]` | 10.97713107 | 10.97713107 | 6.149e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7107]` | 5.739218 | 5.739218 | 1.548e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7108]` | 10.41649939 | 10.41649939 | 5.457e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7109]` | 11.22880164 | 11.22880164 | 9.808e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7110]` | 8.105545946 | 8.105545946 | 2.805e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7111]` | 10.80513745 | 10.80513745 | 1.151e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7112]` | 8.090758584 | 8.090758584 | 1.932e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7113]` | 11.78607363 | 11.78607363 | 5.124e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7114]` | 8.96415438 | 8.96415438 | 8.917e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7115]` | 5.014573814 | 5.014573814 | 1.860e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7116]` | 7.513364551 | 7.513364551 | 2.837e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7117]` | 15.0550887 | 15.0550887 | 2.997e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7119]` | 11.40795344 | 11.40795344 | 3.737e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7120]` | 11.88383567 | 11.88383567 | 1.196e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7121]` | 7.227742518 | 7.227742518 | 6.144e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7122]` | 12.64623299 | 12.64623299 | 9.833e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7123]` | 22.22542505 | 22.22542505 | 1.598e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7124]` | 12.04298715 | 12.04298715 | 7.375e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7125]` | 8.65367608 | 8.65367608 | 6.158e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7126]` | 10.23191042 | 10.23191042 | 1.042e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7127]` | 12.53082675 | 12.53082675 | 4.791e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7128]` | 6.709899237 | 6.709899237 | 1.284e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7129]` | 10.41385994 | 10.41385994 | 1.041e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7130]` | 15.41546289 | 15.41546289 | 1.613e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7131]` | 5.214819507 | 5.214819507 | 3.406e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7132]` | 5.554917486 | 5.554917486 | 1.183e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7133]` | 13.84671016 | 13.84671016 | 4.221e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7134]` | 6.356631055 | 6.356631055 | 1.677e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7135]` | 5.246661504 | 5.246661504 | 2.709e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7136]` | 7.447486127 | 7.447486127 | 3.196e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7137]` | 12.9093708 | 12.9093708 | 1.514e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7138]` | 14.71016315 | 14.71016315 | 6.400e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7139]` | 8.370873719 | 8.370873719 | 1.273e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7140]` | 15.57752518 | 15.57752518 | 2.281e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7141]` | 1.829264969 | 1.829264969 | 3.884e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7142]` | 8.699993779 | 8.699993779 | 2.654e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7143]` | 30.67194532 | 30.67194532 | 8.738e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7144]` | 9.190274947 | 9.190274947 | 1.933e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7145]` | 6.67460421 | 6.67460421 | 4.657e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7146]` | 15.01079127 | 15.01079127 | 3.668e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7147]` | 12.812598 | 12.812598 | 2.218e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7148]` | 14.18337393 | 14.18337393 | 1.252e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7149]` | 8.606969435 | 8.606969435 | 6.811e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7150]` | 12.66893902 | 12.66893902 | 1.402e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7151]` | 10.48035448 | 10.48035448 | 7.797e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7152]` | 11.17568308 | 11.17568308 | 4.768e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7153]` | 10.99592313 | 10.99592313 | 1.292e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7154]` | 10.69532721 | 10.69532721 | 2.940e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7155]` | 7.823482357 | 7.823482357 | 2.725e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7156]` | 10.47471728 | 10.47471728 | 4.070e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7157]` | 6.585075082 | 6.585075082 | 1.484e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7158]` | 10.06505518 | 10.06505518 | 1.006e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7159]` | 9.939696978 | 9.939696978 | 6.612e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7160]` | 7.204149179 | 7.204149179 | 3.452e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7161]` | 15.56468944 | 15.56468944 | 2.739e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7162]` | 4.60543996 | 4.60543996 | 1.350e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7163]` | 6.567855783 | 6.567855783 | 2.569e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7164]` | 13.83419703 | 13.83419703 | 1.926e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7165]` | 6.946533457 | 6.946533457 | 5.114e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7166]` | 8.862798268 | 8.862798268 | 8.218e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7167]` | 4.283804661 | 4.283804661 | 4.167e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7168]` | 8.34795683 | 8.34795683 | 4.256e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7169]` | 10.08548546 | 10.08548546 | 1.726e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7170]` | 11.36421277 | 11.36421277 | 9.379e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7171]` | 7.306840874 | 7.306840874 | 7.293e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7172]` | 17.06496972 | 17.06496972 | 3.287e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7173]` | 15.23393972 | 15.23393972 | 9.678e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7174]` | 7.504156424 | 7.504156424 | 7.575e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7175]` | 8.512160996 | 8.512160996 | 1.002e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7176]` | 7.457870179 | 7.457870179 | 3.692e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7177]` | 10.53419598 | 10.53419598 | 4.890e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7178]` | 11.34762678 | 11.34762678 | 8.766e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7179]` | 12.18242585 | 12.18242585 | 5.541e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7180]` | 10.15112974 | 10.15112974 | 4.725e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7181]` | 8.909021959 | 8.909021959 | 2.592e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7182]` | 6.657256594 | 6.657256594 | 1.868e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7183]` | 8.520105379 | 8.520105379 | 6.255e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7184]` | 8.085139757 | 8.085139757 | 2.417e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7185]` | 10.70510873 | 10.70510873 | 6.637e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7186]` | 6.831950507 | 6.831950507 | 1.040e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7187]` | 10.68071087 | 10.68071087 | 2.877e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7188]` | 4.92681761 | 4.92681761 | 1.550e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7189]` | 18.91001901 | 18.91001901 | 5.260e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7190]` | 13.07888508 | 13.07888508 | 2.716e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7191]` | 12.91320316 | 12.91320316 | 2.201e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7192]` | 3.379451188 | 3.379451188 | 5.020e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7193]` | 10.23558987 | 10.23558987 | 1.718e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7194]` | 16.09106037 | 16.09106037 | 4.416e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7195]` | 9.937891076 | 9.937891076 | 1.251e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7196]` | 18.71730494 | 18.71730494 | 1.006e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7197]` | 3.297696067 | 3.297696067 | 9.427e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7198]` | 11.77923906 | 11.77923906 | 3.318e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7199]` | 8.696775501 | 8.696775501 | 2.043e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7200]` | 7.786925203 | 7.786925203 | 6.045e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7201]` | 4.998884586 | 4.998884586 | 6.219e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7202]` | 24.7677636 | 24.7677636 | 2.438e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7203]` | 6.209256443 | 6.209256443 | 2.289e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7204]` | 7.630001373 | 7.630001373 | 1.048e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7205]` | 11.33766078 | 11.33766078 | 1.880e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7206]` | 8.725857029 | 8.725857029 | 9.568e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7207]` | 11.47274689 | 11.47274689 | 2.787e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7208]` | 2.321634701 | 2.321634701 | 9.373e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7209]` | 4.06371926 | 4.06371926 | 8.743e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7210]` | 4.98584393 | 4.98584393 | 2.316e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7211]` | 12.37870672 | 12.37870672 | 2.052e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7212]` | 15.74129319 | 15.74129319 | 4.988e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7213]` | 8.66683837 | 8.66683837 | 3.074e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7214]` | 7.314659476 | 7.314659476 | 1.579e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7215]` | 12.45740191 | 12.45740191 | 3.280e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7216]` | 8.057355083 | 8.057355083 | 4.652e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7217]` | 6.368290731 | 6.368290731 | 8.368e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7218]` | 9.873860784 | 9.873860784 | 2.339e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7219]` | 12.30810533 | 12.30810533 | 2.886e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7220]` | 10.0922467 | 10.0922467 | 1.003e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7221]` | 8.558332928 | 8.558332928 | 1.453e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7222]` | 19.94671203 | 19.94671203 | 4.275e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7223]` | 14.30053849 | 14.30053849 | 2.484e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7224]` | 5.5101043 | 5.5101043 | 6.448e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7225]` | 11.03080721 | 11.03080721 | 3.221e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7226]` | 5.586926781 | 5.586926781 | 1.669e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7227]` | 3.097431968 | 3.097431968 | 4.301e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7228]` | 10.56130733 | 10.56130733 | 2.355e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7229]` | 10.72264468 | 10.72264468 | 3.148e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7230]` | 11.17824966 | 11.17824966 | 5.721e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7231]` | 8.651444341 | 8.651444341 | 1.766e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7232]` | 14.9556739 | 14.9556739 | 2.851e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7233]` | 4.918259287 | 4.918259287 | 3.251e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7234]` | 12.7650113 | 12.7650113 | 5.705e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7235]` | 5.99008424 | 5.99008424 | 5.190e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7236]` | 13.38509387 | 13.38509387 | 1.383e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7237]` | 4.603641986 | 4.603641986 | 2.990e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7238]` | 6.910112181 | 6.910112181 | 8.997e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7239]` | 13.87222167 | 13.87222167 | 1.281e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7240]` | 8.91537292 | 8.91537292 | 3.586e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7241]` | 10.48604736 | 10.48604736 | 7.284e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7242]` | 7.737421154 | 7.737421154 | 2.881e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7243]` | 5.922314045 | 5.922314045 | 1.035e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7244]` | 10.06287182 | 10.06287182 | 1.165e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7245]` | 16.54943542 | 16.54943542 | 1.052e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7246]` | 4.092472867 | 4.092472867 | 2.604e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7247]` | 20.18701072 | 20.18701072 | 8.800e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7248]` | 6.957539557 | 6.957539557 | 2.170e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7249]` | 8.005268906 | 8.005268906 | 3.107e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7250]` | 10.58269734 | 10.58269734 | 8.393e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7251]` | 18.00250985 | 18.00250985 | 8.486e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7252]` | 9.071343407 | 9.071343407 | 1.116e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7253]` | 5.823987851 | 5.823987851 | 5.338e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7254]` | 18.88618486 | 18.88618486 | 1.430e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7255]` | 14.91443223 | 14.91443223 | 1.346e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7256]` | 19.80202999 | 19.80202999 | 7.176e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7257]` | 8.6562869 | 8.6562869 | 1.211e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7258]` | 12.08874651 | 12.08874651 | 4.849e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7259]` | 11.27924536 | 11.27924536 | 1.417e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7260]` | 9.002674994 | 9.002674994 | 5.130e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7261]` | 14.99049254 | 14.99049254 | 6.873e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7262]` | 6.827440349 | 6.827440349 | 1.353e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7263]` | 14.86292409 | 14.86292409 | 3.705e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7264]` | 9.666765893 | 9.666765893 | 7.350e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7265]` | 11.04247755 | 11.04247755 | 3.217e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7266]` | 7.059134871 | 7.059134871 | 3.775e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7267]` | 6.506862869 | 6.506862869 | 2.866e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7268]` | 14.35789997 | 14.35789997 | 7.794e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7269]` | 2.536336038 | 2.536336038 | 9.980e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7270]` | 10.14840815 | 10.14840815 | 2.976e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7271]` | 5.837919503 | 5.837919503 | 4.412e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7272]` | 5.771424432 | 5.771424432 | 1.385e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7273]` | 10.28725329 | 10.28725329 | 3.799e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7274]` | 15.64041669 | 15.64041669 | 3.521e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7275]` | 9.152244235 | 9.152244235 | 6.599e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7276]` | 29.46096302 | 29.46096302 | 6.520e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7277]` | 4.970540883 | 4.970540883 | 1.787e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7278]` | 16.17046635 | 16.17046635 | 4.394e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7279]` | 11.54088807 | 11.54088807 | 1.816e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7280]` | 18.96404448 | 18.96404448 | 1.873e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7281]` | 11.13386541 | 11.13386541 | 2.026e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7282]` | 12.26573217 | 12.26573217 | 1.535e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7283]` | 9.037118492 | 9.037118492 | 9.828e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7284]` | 8.397551642 | 8.397551642 | 1.713e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7285]` | 5.029081617 | 5.029081617 | 5.828e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7286]` | 3.975416538 | 3.975416538 | 5.585e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7287]` | 4.474889975 | 4.474889975 | 5.954e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7288]` | 13.94547137 | 13.94547137 | 2.165e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7289]` | 5.244706755 | 5.244706755 | 2.540e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7290]` | 7.997164946 | 7.997164946 | 1.277e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7291]` | 3.674085527 | 3.674085527 | 1.463e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7292]` | 7.190577393 | 7.190577393 | 2.717e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7293]` | 11.24130541 | 11.24130541 | 9.481e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7294]` | 10.86568183 | 10.86568183 | 9.809e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7295]` | 8.912331889 | 8.912331889 | 1.993e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7296]` | 11.87916096 | 11.87916096 | 5.966e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7297]` | 10.68412424 | 10.68412424 | 3.824e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7298]` | 15.45882019 | 15.45882019 | 5.516e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7299]` | 19.59477908 | 19.59477908 | 1.813e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7300]` | 19.32624705 | 19.32624705 | 5.000e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7301]` | 14.81502977 | 14.81502977 | 7.194e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7302]` | 5.562405933 | 5.562405933 | 5.748e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7303]` | 10.49936079 | 10.49936079 | 2.707e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7304]` | 8.542158625 | 8.542158625 | 1.372e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7305]` | 11.30145025 | 11.30145025 | 8.331e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7306]` | 10.6130477 | 10.6130477 | 1.172e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7307]` | 6.530058618 | 6.530058618 | 4.339e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7308]` | 10.49702039 | 10.49702039 | 1.015e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7309]` | 9.191652045 | 9.191652045 | 1.739e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7310]` | 9.086949074 | 9.086949074 | 1.583e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7311]` | 12.64684142 | 12.64684142 | 4.551e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7312]` | 9.493425991 | 9.493425991 | 4.117e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7313]` | 5.058643126 | 5.058643126 | 4.214e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7314]` | 8.847036043 | 8.847036043 | 4.016e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7315]` | 4.137827466 | 4.137827466 | 2.683e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7316]` | 5.438776241 | 5.438776241 | 1.192e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7317]` | 6.729261329 | 6.729261329 | 7.259e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7318]` | 12.32177926 | 12.32177926 | 4.238e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7319]` | 9.952063059 | 9.952063059 | 2.088e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7320]` | 10.85810172 | 10.85810172 | 3.599e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7321]` | 19.01757485 | 19.01757485 | 5.604e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7322]` | 10.47181976 | 10.47181976 | 4.241e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7323]` | 3.241144029 | 3.241144029 | 2.590e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7325]` | 14.56347621 | 14.56347621 | 6.952e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7326]` | 11.74039957 | 11.74039957 | 3.934e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7327]` | 16.67651433 | 16.67651433 | 5.539e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7328]` | 13.68622808 | 13.68622808 | 1.298e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7329]` | 7.341143701 | 7.341143701 | 2.178e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7330]` | 6.362731783 | 6.362731783 | 1.535e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7331]` | 7.895477392 | 7.895477392 | 6.187e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7332]` | 5.613583439 | 5.613583439 | 7.911e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7333]` | 12.85101279 | 12.85101279 | 1.673e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7334]` | 4.823962605 | 4.823962605 | 1.988e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7335]` | 6.136163491 | 6.136163491 | 2.461e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7336]` | 7.994208961 | 7.994208961 | 5.111e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7337]` | 13.65049313 | 13.65049313 | 2.603e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7338]` | 7.625852682 | 7.625852682 | 1.025e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7339]` | 2.081997956 | 2.081997956 | 2.133e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7340]` | 7.193738586 | 7.193738586 | 1.543e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7341]` | 8.12678642 | 8.12678642 | 7.213e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7342]` | 11.36126342 | 11.36126342 | 2.986e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7343]` | 4.268454279 | 4.268454279 | 2.164e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7344]` | 15.96685049 | 15.96685049 | 2.136e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7345]` | 7.131419124 | 7.131419124 | 1.245e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7346]` | 12.55009375 | 12.55009375 | 7.785e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7347]` | 4.481126738 | 4.481126738 | 8.523e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7348]` | 9.303466267 | 9.303466267 | 4.773e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7349]` | 10.54974025 | 10.54974025 | 7.745e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7350]` | 17.87200797 | 17.87200797 | 5.964e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7351]` | 4.867263455 | 4.867263455 | 8.759e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7352]` | 4.478438002 | 4.478438002 | 1.587e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7353]` | 16.53323112 | 16.53323112 | 4.298e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7354]` | 5.920081599 | 5.920081599 | 3.151e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7355]` | 8.114629407 | 8.114629407 | 2.408e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7356]` | 7.385249316 | 7.385249316 | 1.395e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7357]` | 6.001497647 | 6.001497647 | 1.806e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7358]` | 12.74022476 | 12.74022476 | 4.741e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7359]` | 10.69936738 | 10.69936738 | 8.965e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7360]` | 7.594358725 | 7.594358725 | 3.041e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7361]` | 2.154229816 | 2.154229816 | 8.246e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7362]` | 8.451172899 | 8.451172899 | 8.618e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7363]` | 4.454063387 | 4.454063387 | 3.230e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7364]` | 9.034181694 | 9.034181694 | 1.573e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7365]` | 13.21986861 | 13.21986861 | 1.612e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7366]` | 9.067103977 | 9.067103977 | 7.836e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7367]` | 5.723216673 | 5.723216673 | 9.156e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7368]` | 10.22630403 | 10.22630403 | 3.266e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7369]` | 22.28557545 | 22.28557545 | 4.783e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7370]` | 6.705016275 | 6.705016275 | 7.948e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7371]` | 5.306826006 | 5.306826006 | 1.674e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7372]` | 11.09955891 | 11.09955891 | 3.793e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7373]` | 6.775419923 | 6.775419923 | 6.817e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7374]` | 17.43495975 | 17.43495975 | 4.075e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7375]` | 11.64096643 | 11.64096643 | 3.815e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7376]` | 5.948745677 | 5.948745677 | 2.538e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7377]` | 12.34695526 | 12.34695526 | 2.877e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7378]` | 11.26173292 | 11.26173292 | 2.098e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7379]` | 12.66299999 | 12.66299999 | 3.549e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7380]` | 3.763768762 | 3.763768762 | 1.888e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7381]` | 14.19805546 | 14.19805546 | 1.276e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7382]` | 10.91738311 | 10.91738311 | 1.953e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7383]` | 6.199530433 | 6.199530433 | 5.444e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7384]` | 11.33528534 | 11.33528534 | 9.403e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7385]` | 4.271654095 | 4.271654095 | 8.109e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7386]` | 16.32288021 | 16.32288021 | 1.567e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7387]` | 4.569745001 | 4.569745001 | 2.527e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7388]` | 17.51960705 | 17.51960705 | 2.839e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7389]` | 5.715352766 | 5.715352766 | 3.108e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7390]` | 2.709980124 | 2.709980124 | 1.639e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7391]` | 5.01361845 | 5.01361845 | 5.315e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7392]` | 13.57819095 | 13.57819095 | 1.308e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7393]` | 20.19748744 | 20.19748744 | 1.266e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7394]` | 9.027839089 | 9.027839089 | 8.461e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7395]` | 8.698782515 | 8.698782515 | 5.514e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7396]` | 4.241361689 | 4.241361689 | 2.513e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7397]` | 18.23665136 | 18.23665136 | 8.767e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7398]` | 15.49362838 | 15.49362838 | 2.408e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7399]` | 6.997995409 | 6.997995409 | 1.523e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7400]` | 6.692200374 | 6.692200374 | 1.911e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7401]` | 10.25743645 | 10.25743645 | 8.659e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7402]` | 7.199264626 | 7.199264626 | 8.019e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7403]` | 8.280289131 | 8.280289131 | 3.089e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7404]` | 6.934371718 | 6.934371718 | 2.049e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7405]` | 7.282129993 | 7.282129993 | 1.146e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7406]` | 4.069157542 | 4.069157542 | 1.572e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7407]` | 5.989462738 | 5.989462738 | 8.897e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7408]` | 11.3440541 | 11.3440541 | 9.395e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7409]` | 6.014114267 | 6.014114267 | 4.283e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7410]` | 6.805681339 | 6.805681339 | 2.088e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7411]` | 9.055805977 | 9.055805977 | 6.081e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7412]` | 16.79684572 | 16.79684572 | 8.460e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7413]` | 8.364922755 | 8.364922755 | 3.185e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7414]` | 6.809057362 | 6.809057362 | 6.652e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7415]` | 5.958338187 | 5.958338187 | 2.236e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7416]` | 4.966000446 | 4.966000446 | 4.936e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7417]` | 12.24632641 | 12.24632641 | 2.756e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7418]` | 6.295515584 | 6.295515584 | 1.368e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7419]` | 7.424767007 | 7.424767007 | 8.852e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7420]` | 13.19207655 | 13.19207655 | 1.077e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7421]` | 11.07196003 | 11.07196003 | 7.220e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7422]` | 14.95958199 | 14.95958199 | 1.900e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7423]` | 11.56987802 | 11.56987802 | 8.905e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7424]` | 12.0581327 | 12.0581327 | 1.208e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7425]` | 18.107007 | 18.107007 | 2.374e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7426]` | 6.790967948 | 6.790967948 | 1.308e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7427]` | 7.92384907 | 7.92384907 | 1.906e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7428]` | 12.12142679 | 12.12142679 | 1.700e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7429]` | 15.35164312 | 15.35164312 | 6.943e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7430]` | 10.0320138 | 10.0320138 | 1.594e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7431]` | 2.365413749 | 2.365413749 | 1.014e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7432]` | 7.849132715 | 7.849132715 | 1.279e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7433]` | 7.961198389 | 7.961198389 | 3.235e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7434]` | 4.796644415 | 4.796644415 | 3.148e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7435]` | 9.616191298 | 9.616191298 | 7.204e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7436]` | 7.58370513 | 7.58370513 | 9.369e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7437]` | 12.64978116 | 12.64978116 | 1.123e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7438]` | 5.815871302 | 5.815871302 | 1.680e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7439]` | 16.66825544 | 16.66825544 | 8.078e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7440]` | 7.57591248 | 7.57591248 | 6.565e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7441]` | 19.25476856 | 19.25476856 | 4.982e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7442]` | 9.328057745 | 9.328057745 | 2.114e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7443]` | 7.751793699 | 7.751793699 | 6.416e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7444]` | 6.020147452 | 6.020147452 | 5.016e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7445]` | 9.0616192 | 9.0616192 | 9.802e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7446]` | 8.679890985 | 8.679890985 | 1.289e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7447]` | 3.420062282 | 3.420062282 | 6.233e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7448]` | 7.232841038 | 7.232841038 | 4.052e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7449]` | 6.838012696 | 6.838012696 | 1.234e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7450]` | 6.063399483 | 6.063399483 | 2.344e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7451]` | 3.667264852 | 3.667264852 | 8.598e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7452]` | 7.624784237 | 7.624784237 | 8.387e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7453]` | 4.511759479 | 4.511759479 | 5.709e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7454]` | 2.43433205 | 2.43433205 | 3.284e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7455]` | 8.611620754 | 8.611620754 | 1.155e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7456]` | 11.51264429 | 11.51264429 | 1.805e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7457]` | 9.951655713 | 9.951655713 | 7.140e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7458]` | 13.52441891 | 13.52441891 | 1.313e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7459]` | 5.576997497 | 5.576997497 | 4.778e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7460]` | 6.1901732 | 6.1901732 | 2.726e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7461]` | 8.820708731 | 8.820708731 | 2.819e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7462]` | 3.862127417 | 3.862127417 | 1.265e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7463]` | 2.971614334 | 2.971614334 | 5.081e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7464]` | 16.34091807 | 16.34091807 | 6.522e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7465]` | 3.772716349 | 3.772716349 | 5.497e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7466]` | 10.95350357 | 10.95350357 | 1.135e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7467]` | 12.88891823 | 12.88891823 | 4.314e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7468]` | 8.948646905 | 8.948646905 | 1.012e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7469]` | 9.208500323 | 9.208500323 | 2.122e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7470]` | 15.3087546 | 15.3087546 | 1.276e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7471]` | 15.7210328 | 15.7210328 | 1.469e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7472]` | 13.5232994 | 13.5232994 | 5.648e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7473]` | 17.53075551 | 17.53075551 | 1.642e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7474]` | 9.343684234 | 9.343684234 | 2.471e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7475]` | 14.16639887 | 14.16639887 | 1.755e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7476]` | 6.552670709 | 6.552670709 | 1.220e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7477]` | 4.67838646 | 4.67838646 | 1.538e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7478]` | 9.894798638 | 9.894798638 | 1.131e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7479]` | 10.46625205 | 10.46625205 | 2.054e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7480]` | 14.95579125 | 14.95579125 | 8.314e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7481]` | 9.463210546 | 9.463210546 | 6.551e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7482]` | 13.63475981 | 13.63475981 | 2.736e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7483]` | 5.107440611 | 5.107440611 | 3.478e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7484]` | 18.41809193 | 18.41809193 | 4.437e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7485]` | 9.524242266 | 9.524242266 | 5.782e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7486]` | 7.974698627 | 7.974698627 | 4.009e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7487]` | 6.895494576 | 6.895494576 | 3.478e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7488]` | 20.93020665 | 20.93020665 | 2.037e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7489]` | 14.14898362 | 14.14898362 | 5.147e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7490]` | 11.03231198 | 11.03231198 | 9.967e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7491]` | 5.919348708 | 5.919348708 | 1.605e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7492]` | 2.005830928 | 2.005830928 | 7.085e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7493]` | 6.291267038 | 6.291267038 | 5.548e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7494]` | 9.122561719 | 9.122561719 | 2.337e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7495]` | 5.64178683 | 5.64178683 | 1.889e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7496]` | 9.669211422 | 9.669211422 | 2.388e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7497]` | 11.85302975 | 11.85302975 | 1.349e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7498]` | 27.30103963 | 27.30103963 | 2.212e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7499]` | 13.58588323 | 13.58588323 | 5.753e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7500]` | 6.199906767 | 6.199906767 | 1.576e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7501]` | 23.22840394 | 23.22840394 | 2.294e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7502]` | 8.510815933 | 8.510815933 | 2.964e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7503]` | 5.177463766 | 5.177463766 | 2.728e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7504]` | 2.217925563 | 2.217925563 | 1.342e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7505]` | 18.67613555 | 18.67613555 | 3.995e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7506]` | 12.63219375 | 12.63219375 | 1.969e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7507]` | 17.06772714 | 17.06772714 | 1.041e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7508]` | 5.423588214 | 5.423588214 | 1.638e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7509]` | 9.95992405 | 9.95992405 | 2.854e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7510]` | 4.337630647 | 4.337630647 | 5.201e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7511]` | 7.826633969 | 7.826633969 | 6.809e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7512]` | 10.43814504 | 10.43814504 | 8.849e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7513]` | 8.827634851 | 8.827634851 | 3.421e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7514]` | 3.550599066 | 3.550599066 | 2.627e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7515]` | 9.770322452 | 9.770322452 | 5.454e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7516]` | 11.13435756 | 11.13435756 | 2.074e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7517]` | 15.24975422 | 15.24975422 | 5.824e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7518]` | 2.981746797 | 2.981746797 | 8.043e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7519]` | 5.486559348 | 5.486559348 | 7.770e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7520]` | 5.57184171 | 5.57184171 | 9.883e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7521]` | 13.67060042 | 13.67060042 | 5.068e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7522]` | 10.56739811 | 10.56739811 | 4.371e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7523]` | 11.46994138 | 11.46994138 | 4.646e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7524]` | 9.409738715 | 9.409738715 | 5.852e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7525]` | 5.636900195 | 5.636900195 | 8.981e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7526]` | 10.28136275 | 10.28136275 | 1.486e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7527]` | 9.279397197 | 9.279397197 | 9.572e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7528]` | 10.90551509 | 10.90551509 | 2.443e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7529]` | 10.16038285 | 10.16038285 | 1.136e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7530]` | 22.82411075 | 22.82411075 | 4.047e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7531]` | 17.13279612 | 17.13279612 | 2.634e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7532]` | 11.9801207 | 11.9801207 | 2.817e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7533]` | 10.63291478 | 10.63291478 | 1.403e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7534]` | 7.098788598 | 7.098788598 | 3.503e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7535]` | 7.792153505 | 7.792153505 | 2.257e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7536]` | 14.6804823 | 14.6804823 | 1.004e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7537]` | 12.73546849 | 12.73546849 | 2.371e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7538]` | 15.89186247 | 15.89186247 | 4.918e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7539]` | 3.048126277 | 3.048126277 | 7.139e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7540]` | 6.307898716 | 6.307898716 | 3.844e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7541]` | 14.92879365 | 14.92879365 | 5.842e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7542]` | 8.520537821 | 8.520537821 | 3.815e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7543]` | 7.285744025 | 7.285744025 | 7.314e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7544]` | 4.495881762 | 4.495881762 | 2.568e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7545]` | 5.803076154 | 5.803076154 | 1.653e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7546]` | 7.100469633 | 7.100469633 | 4.503e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7547]` | 6.383730702 | 6.383730702 | 3.200e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7548]` | 10.23336529 | 10.23336529 | 3.992e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7549]` | 10.64543627 | 10.64543627 | 6.675e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7550]` | 7.129308063 | 7.129308063 | 1.101e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7551]` | 5.023713339 | 5.023713339 | 4.597e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7552]` | 6.218598207 | 6.218598207 | 5.999e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7553]` | 22.82401797 | 22.82401797 | 1.868e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7554]` | 16.44781333 | 16.44781333 | 1.045e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7555]` | 5.898879531 | 5.898879531 | 2.424e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7556]` | 11.00075732 | 11.00075732 | 4.844e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7557]` | 2.569870394 | 2.569870394 | 8.122e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7558]` | 5.954360204 | 5.954360204 | 1.014e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7559]` | 11.15942106 | 11.15942106 | 3.024e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7560]` | 11.32725126 | 11.32725126 | 1.976e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7561]` | 10.01858101 | 10.01858101 | 1.720e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7562]` | 4.503219356 | 4.503219356 | 2.130e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7563]` | 11.38758584 | 11.38758584 | 8.891e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7564]` | 2.560159047 | 2.560159047 | 7.632e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7565]` | 6.966356636 | 6.966356636 | 1.912e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7566]` | 13.65939797 | 13.65939797 | 5.982e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7567]` | 9.782725833 | 9.782725833 | 7.990e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7568]` | 9.266330481 | 9.266330481 | 1.534e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7569]` | 5.299033405 | 5.299033405 | 2.011e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7570]` | 16.52824589 | 16.52824589 | 2.171e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7571]` | 5.538124288 | 5.538124288 | 1.764e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7572]` | 11.23648547 | 11.23648547 | 8.695e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7573]` | 10.04928323 | 10.04928323 | 4.242e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7574]` | 6.03670792 | 6.03670792 | 2.751e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7575]` | 11.69620628 | 11.69620628 | 3.341e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7576]` | 12.57590054 | 12.57590054 | 1.413e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7577]` | 10.09599472 | 10.09599472 | 5.982e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7578]` | 10.86831687 | 10.86831687 | 5.394e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7579]` | 9.112834525 | 9.112834525 | 4.678e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7580]` | 10.12140902 | 10.12140902 | 3.335e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7581]` | 8.912699683 | 8.912699683 | 1.515e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7582]` | 12.76289421 | 12.76289421 | 1.559e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7583]` | 6.488658426 | 6.488658426 | 4.982e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7584]` | 5.916597833 | 5.916597833 | 3.753e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7585]` | 14.38829544 | 14.38829544 | 1.210e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7586]` | 6.822504121 | 6.822504121 | 2.604e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7587]` | 18.99879268 | 18.99879268 | 6.837e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7588]` | 8.813408837 | 8.813408837 | 8.868e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7589]` | 6.068835106 | 6.068835106 | 1.464e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7590]` | 1.645074342 | 1.645074342 | 4.724e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7591]` | 7.238240469 | 7.238240469 | 6.258e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7592]` | 2.513611306 | 2.513611306 | 4.063e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7593]` | 6.258703195 | 6.258703195 | 2.838e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7594]` | 8.457005489 | 8.457005489 | 2.311e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7595]` | 2.366771403 | 2.366771403 | 1.876e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7597]` | 6.176284884 | 6.176284884 | 3.020e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7598]` | 6.273379041 | 6.273379041 | 5.663e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7599]` | 8.572992704 | 8.572992704 | 8.081e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7600]` | 8.815957649 | 8.815957649 | 1.007e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7601]` | 4.901517819 | 4.901517819 | 9.241e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7602]` | 3.637210699 | 3.637210699 | 2.686e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7603]` | 8.495802358 | 8.495802358 | 9.409e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7604]` | 8.945999993 | 8.945999993 | 2.184e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7605]` | 11.0947312 | 11.0947312 | 6.404e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7606]` | 7.356606267 | 7.356606267 | 1.570e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7607]` | 16.71357317 | 16.71357317 | 2.126e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7608]` | 9.382415641 | 9.382415641 | 2.028e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7609]` | 5.345247398 | 5.345247398 | 7.643e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7610]` | 11.15565338 | 11.15565338 | 1.799e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7611]` | 13.52977029 | 13.52977029 | 1.444e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7612]` | 4.916263981 | 4.916263981 | 2.349e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7613]` | 5.868982564 | 5.868982564 | 1.059e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7614]` | 9.303928032 | 9.303928032 | 2.482e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7615]` | 9.697333475 | 9.697333475 | 6.594e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7616]` | 8.275468078 | 8.275468078 | 5.152e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7617]` | 10.32115227 | 10.32115227 | 4.131e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7618]` | 8.655243051 | 8.655243051 | 5.336e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7619]` | 11.9052499 | 11.9052499 | 3.104e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7620]` | 12.12708024 | 12.12708024 | 5.402e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7621]` | 8.085367688 | 8.085367688 | 4.789e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7622]` | 13.59790065 | 13.59790065 | 2.743e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7623]` | 12.59688589 | 12.59688589 | 4.795e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7624]` | 14.27368498 | 14.27368498 | 5.376e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7626]` | 6.782258038 | 6.782258038 | 6.417e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7627]` | 10.34380447 | 10.34380447 | 4.808e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7628]` | 3.09107026 | 3.09107026 | 7.183e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7629]` | 10.53233118 | 10.53233118 | 1.653e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7630]` | 5.023776075 | 5.023776075 | 3.359e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7631]` | 3.879140464 | 3.879140464 | 7.556e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7632]` | 13.92057783 | 13.92057783 | 6.380e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7633]` | 11.12842328 | 11.12842328 | 3.033e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7634]` | 9.624341874 | 9.624341874 | 1.846e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7635]` | 5.509702756 | 5.509702756 | 8.060e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7636]` | 4.894210297 | 4.894210297 | 5.444e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7637]` | 12.79016809 | 12.79016809 | 2.778e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7638]` | 13.62339448 | 13.62339448 | 5.450e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7639]` | 11.16349024 | 11.16349024 | 5.569e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7640]` | 11.13925763 | 11.13925763 | 1.324e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7641]` | 8.569750881 | 8.569750881 | 1.036e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7642]` | 16.31839904 | 16.31839904 | 6.314e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7643]` | 13.10920069 | 13.10920069 | 2.439e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7644]` | 7.694545375 | 7.694545375 | 1.073e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7645]` | 5.117848629 | 5.117848629 | 6.074e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7646]` | 14.15784469 | 14.15784469 | 1.255e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7647]` | 11.54128998 | 11.54128998 | 3.386e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7648]` | 7.806105111 | 7.806105111 | 2.549e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7649]` | 6.729790656 | 6.729790656 | 1.320e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7650]` | 11.39512555 | 11.39512555 | 4.053e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7651]` | 15.97334784 | 15.97334784 | 1.406e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7652]` | 14.92379375 | 14.92379375 | 5.475e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7653]` | 8.316653382 | 8.316653382 | 2.136e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7654]` | 8.086573268 | 8.086573268 | 1.098e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7655]` | 5.955208727 | 5.955208727 | 5.817e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7656]` | 9.756465906 | 9.756465906 | 1.457e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7657]` | 16.24903524 | 16.24903524 | 7.434e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7658]` | 12.59948694 | 12.59948694 | 2.115e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7659]` | 12.51498733 | 12.51498733 | 8.374e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7660]` | 13.60717341 | 13.60717341 | 2.611e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7661]` | 8.469572843 | 8.469572843 | 8.809e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7662]` | 5.478309094 | 5.478309094 | 7.458e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7663]` | 13.88850701 | 13.88850701 | 5.244e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7664]` | 12.02242355 | 12.02242355 | 7.388e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7665]` | 3.584763185 | 3.584763185 | 4.831e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7666]` | 8.775290885 | 8.775290885 | 1.619e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7667]` | 12.47444149 | 12.47444149 | 1.851e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7668]` | 8.193978316 | 8.193978316 | 2.601e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7669]` | 18.10603874 | 18.10603874 | 5.906e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7670]` | 8.243977709 | 8.243977709 | 7.973e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7671]` | 12.2896251 | 12.2896251 | 6.360e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7672]` | 7.953978116 | 7.953978116 | 2.401e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7673]` | 1.753880699 | 1.753880699 | 1.367e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7674]` | 15.03386402 | 15.03386402 | 5.601e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7675]` | 20.76894095 | 20.76894095 | 8.553e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7676]` | 8.065258887 | 8.065258887 | 1.366e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7677]` | 14.67839018 | 14.67839018 | 1.489e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7678]` | 18.96125558 | 18.96125558 | 1.956e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7679]` | 4.601952071 | 4.601952071 | 1.081e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7680]` | 7.658266938 | 7.658266938 | 3.027e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7681]` | 16.59452678 | 16.59452678 | 3.597e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7682]` | 12.29960289 | 12.29960289 | 5.777e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7683]` | 13.37020029 | 13.37020029 | 1.993e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7684]` | 6.617889035 | 6.617889035 | 4.429e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7685]` | 11.72946265 | 11.72946265 | 3.786e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7686]` | 5.353529179 | 5.353529179 | 2.057e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7687]` | 9.505606688 | 9.505606688 | 4.859e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7688]` | 10.40168627 | 10.40168627 | 3.757e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7689]` | 9.682405638 | 9.682405638 | 7.338e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7690]` | 8.042279354 | 8.042279354 | 1.546e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7691]` | 12.57204623 | 12.57204623 | 1.144e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7692]` | 20.30973441 | 20.30973441 | 1.732e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7693]` | 22.18422281 | 22.18422281 | 8.007e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7694]` | 4.634884111 | 4.634884111 | 5.557e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7695]` | 14.59293737 | 14.59293737 | 1.582e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7696]` | 15.91958896 | 15.91958896 | 1.116e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7697]` | 3.985388572 | 3.985388572 | 1.560e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7698]` | 11.02121281 | 11.02121281 | 7.608e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7699]` | 5.794640655 | 5.794640655 | 2.299e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7700]` | 7.633544036 | 7.633544036 | 1.047e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7701]` | 12.35871365 | 12.35871365 | 6.770e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7702]` | 16.33214894 | 16.33214894 | 2.828e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7703]` | 13.79088128 | 13.79088128 | 2.576e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7704]` | 12.64301207 | 12.64301207 | 2.670e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7705]` | 6.287298494 | 6.287298494 | 1.709e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7706]` | 6.07296005 | 6.07296005 | 3.949e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7707]` | 3.456189679 | 3.456189679 | 3.084e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7708]` | 8.842200725 | 8.842200725 | 2.210e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7709]` | 7.842840418 | 7.842840418 | 4.530e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7710]` | 2.875228503 | 2.875228503 | 1.529e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7711]` | 7.99586257 | 7.99586257 | 5.554e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7712]` | 10.42445829 | 10.42445829 | 3.749e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7713]` | 7.439507891 | 7.439507891 | 1.194e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7714]` | 5.680142416 | 5.680142416 | 7.818e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7715]` | 5.515555118 | 5.515555118 | 1.836e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7716]` | 7.681437367 | 7.681437367 | 4.047e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7717]` | 5.044216712 | 5.044216712 | 1.937e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7718]` | 4.283123238 | 4.283123238 | 3.525e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7719]` | 4.323924296 | 4.323924296 | 8.216e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7720]` | 14.58459752 | 14.58459752 | 1.949e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7721]` | 9.950462602 | 9.950462602 | 4.820e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7722]` | 8.246637301 | 8.246637301 | 1.077e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7723]` | 6.351629196 | 6.351629196 | 1.217e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7724]` | 13.95179757 | 13.95179757 | 6.366e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7725]` | 2.937837372 | 2.937837372 | 4.081e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7726]` | 12.11543093 | 12.11543093 | 1.100e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7727]` | 4.415480297 | 4.415480297 | 5.632e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7728]` | 16.1037853 | 16.1037853 | 4.081e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7729]` | 9.935132912 | 9.935132912 | 6.258e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7730]` | 16.35182705 | 16.35182705 | 7.604e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7731]` | 6.110748504 | 6.110748504 | 8.721e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7732]` | 13.393804 | 13.393804 | 5.570e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7733]` | 7.480591354 | 7.480591354 | 5.580e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7734]` | 5.770191432 | 5.770191432 | 2.925e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7735]` | 15.2692192 | 15.2692192 | 7.096e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7736]` | 10.70461222 | 10.70461222 | 1.543e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7737]` | 11.80143844 | 11.80143844 | 2.258e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7738]` | 16.64087075 | 16.64087075 | 1.921e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7739]` | 6.073490178 | 6.073490178 | 3.656e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7740]` | 7.209657902 | 7.209657902 | 1.207e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7741]` | 13.5311942 | 13.5311942 | 1.182e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7742]` | 9.267313047 | 9.267313047 | 3.642e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7743]` | 13.15932666 | 13.15932666 | 2.700e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7744]` | 9.791516523 | 9.791516523 | 1.379e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7745]` | 10.29072007 | 10.29072007 | 4.143e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7746]` | 8.313254022 | 8.313254022 | 6.410e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7747]` | 28.36670574 | 28.36670574 | 1.793e-12 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7748]` | 7.275504733 | 7.275504733 | 5.017e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7749]` | 5.804341177 | 5.804341177 | 2.907e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7750]` | 13.37605299 | 13.37605299 | 9.030e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7751]` | 6.218595651 | 6.218595651 | 4.142e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7752]` | 7.19017159 | 7.19017159 | 6.176e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7753]` | 7.525308861 | 7.525308861 | 4.131e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7754]` | 2.209876301 | 2.209876301 | 6.833e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7755]` | 4.632779769 | 4.632779769 | 2.301e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7756]` | 15.23885123 | 15.23885123 | 8.043e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7757]` | 13.67355492 | 13.67355492 | 1.481e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7758]` | 8.874123824 | 8.874123824 | 4.604e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7760]` | 5.8198577 | 5.8198577 | 8.851e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7761]` | 5.693257317 | 5.693257317 | 4.056e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7762]` | 6.324462105 | 6.324462105 | 3.370e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7763]` | 5.905742678 | 5.905742678 | 1.143e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7764]` | 6.36593969 | 6.36593969 | 1.010e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7765]` | 8.869653512 | 8.869653512 | 6.008e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7766]` | 16.39880615 | 16.39880615 | 1.300e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7767]` | 25.30909185 | 25.30909185 | 1.544e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7768]` | 6.232894457 | 6.232894457 | 1.624e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7769]` | 13.18878782 | 13.18878782 | 3.502e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7770]` | 9.424300326 | 9.424300326 | 1.206e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7771]` | 19.3211373 | 19.3211373 | 7.355e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7772]` | 6.01758756 | 6.01758756 | 1.033e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7773]` | 7.695609357 | 7.695609357 | 2.147e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7774]` | 5.382030773 | 5.382030773 | 5.611e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7775]` | 11.03712717 | 11.03712717 | 9.013e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7776]` | 10.83010363 | 10.83010363 | 1.558e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7777]` | 7.514354266 | 7.514354266 | 3.782e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7778]` | 15.94316097 | 15.94316097 | 1.226e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7779]` | 4.24095906 | 4.24095906 | 1.466e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7780]` | 9.222463052 | 9.222463052 | 2.504e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7781]` | 11.63399335 | 11.63399335 | 1.527e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7782]` | 6.107230465 | 6.107230465 | 2.196e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7783]` | 3.7191031 | 3.7191031 | 4.896e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7784]` | 6.395562123 | 6.395562123 | 1.389e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7785]` | 12.74964559 | 12.74964559 | 9.196e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7786]` | 7.710763439 | 7.710763439 | 2.388e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7787]` | 10.31919609 | 10.31919609 | 5.853e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7788]` | 4.527513837 | 4.527513837 | 1.589e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7789]` | 6.957202799 | 6.957202799 | 1.417e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7790]` | 7.248966859 | 7.248966859 | 4.166e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7791]` | 8.028713507 | 8.028713507 | 4.868e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7792]` | 4.873247863 | 4.873247863 | 1.276e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7793]` | 8.541135606 | 8.541135606 | 8.319e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7794]` | 8.280548538 | 8.280548538 | 1.287e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7795]` | 8.087572501 | 8.087572501 | 4.063e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7796]` | 12.68030566 | 12.68030566 | 9.946e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7797]` | 4.99284286 | 4.99284286 | 4.981e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7798]` | 7.619843987 | 7.619843987 | 1.014e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7799]` | 14.31634873 | 14.31634873 | 8.065e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7800]` | 7.764127211 | 7.764127211 | 2.059e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7801]` | 8.754349302 | 8.754349302 | 1.177e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7802]` | 6.551567652 | 6.551567652 | 1.857e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7803]` | 5.322472949 | 5.322472949 | 2.169e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7804]` | 8.486444487 | 8.486444487 | 5.024e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7805]` | 6.670571565 | 6.670571565 | 7.323e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7806]` | 9.00819197 | 9.00819197 | 2.958e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7807]` | 10.37600253 | 10.37600253 | 8.560e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7808]` | 14.57015791 | 14.57015791 | 2.902e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7809]` | 2.879123171 | 2.879123171 | 5.244e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7810]` | 11.42313606 | 11.42313606 | 1.866e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7811]` | 15.75234517 | 15.75234517 | 1.917e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7812]` | 1.993494941 | 1.993494941 | 2.328e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7813]` | 5.434899998 | 5.434899998 | 1.634e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7814]` | 8.847230934 | 8.847230934 | 3.212e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7815]` | 11.55314082 | 11.55314082 | 2.153e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7816]` | 14.8621472 | 14.8621472 | 1.793e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7817]` | 3.326374172 | 3.326374172 | 4.272e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7818]` | 12.67976386 | 12.67976386 | 2.522e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7819]` | 18.39365588 | 18.39365588 | 3.090e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7820]` | 6.294041263 | 6.294041263 | 1.411e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7821]` | 9.07083201 | 9.07083201 | 6.071e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7822]` | 12.91411994 | 12.91411994 | 1.376e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7823]` | 8.8321169 | 8.8321169 | 8.045e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7824]` | 13.59300015 | 13.59300015 | 6.207e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7825]` | 10.56890586 | 10.56890586 | 1.345e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7826]` | 8.538836466 | 8.538836466 | 3.537e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7827]` | 10.96251336 | 10.96251336 | 3.241e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7828]` | 13.53358219 | 13.53358219 | 6.825e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7829]` | 6.427532909 | 6.427532909 | 9.535e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7830]` | 7.023306068 | 7.023306068 | 1.138e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7831]` | 7.104094458 | 7.104094458 | 3.501e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7832]` | 4.722982512 | 4.722982512 | 4.889e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7833]` | 4.342002964 | 4.342002964 | 1.841e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7834]` | 11.44778142 | 11.44778142 | 7.727e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7835]` | 13.12046815 | 13.12046815 | 1.083e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7836]` | 6.842105794 | 6.842105794 | 3.777e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7837]` | 4.741228885 | 4.741228885 | 4.121e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7838]` | 8.208743981 | 8.208743981 | 1.190e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7839]` | 18.01902668 | 18.01902668 | 9.267e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7840]` | 10.11735465 | 10.11735465 | 2.634e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7841]` | 7.49942206 | 7.49942206 | 8.409e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7842]` | 12.17812126 | 12.17812126 | 3.122e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7843]` | 11.8519628 | 11.8519628 | 1.049e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7844]` | 14.71957535 | 14.71957535 | 1.207e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7845]` | 7.62940215 | 7.62940215 | 1.513e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7846]` | 3.853883044 | 3.853883044 | 5.185e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7847]` | 13.57348785 | 13.57348785 | 6.151e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7848]` | 14.49192144 | 14.49192144 | 3.800e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7849]` | 6.220166013 | 6.220166013 | 3.427e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7850]` | 13.02512427 | 13.02512427 | 2.318e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7851]` | 6.281440533 | 6.281440533 | 4.242e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7852]` | 4.403853736 | 4.403853736 | 8.672e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7853]` | 2.722228253 | 2.722228253 | 1.794e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7854]` | 7.45668982 | 7.45668982 | 1.537e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7855]` | 5.989485025 | 5.989485025 | 4.745e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7856]` | 27.29992646 | 27.29992646 | 4.555e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7857]` | 25.35546604 | 25.35546604 | 1.583e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7858]` | 6.225364276 | 6.225364276 | 1.812e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7859]` | 14.11029361 | 14.11029361 | 7.428e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7860]` | 13.53230469 | 13.53230469 | 3.019e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7861]` | 13.9057668 | 13.9057668 | 8.048e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7862]` | 17.42874599 | 17.42874599 | 1.773e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7863]` | 4.170101734 | 4.170101734 | 8.519e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7864]` | 17.19839671 | 17.19839671 | 7.643e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7865]` | 6.550069728 | 6.550069728 | 8.271e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7866]` | 22.47462361 | 22.47462361 | 6.734e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7867]` | 9.453237079 | 9.453237079 | 3.927e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7868]` | 8.772887453 | 8.772887453 | 1.296e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7869]` | 12.95878147 | 12.95878147 | 1.371e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7870]` | 10.66574785 | 10.66574785 | 1.049e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7871]` | 7.482574859 | 7.482574859 | 4.107e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7872]` | 5.30011047 | 5.30011047 | 5.027e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7873]` | 11.12286139 | 11.12286139 | 7.027e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7874]` | 11.25148289 | 11.25148289 | 1.042e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7875]` | 9.263847763 | 9.263847763 | 1.553e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7876]` | 13.8289571 | 13.8289571 | 4.881e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7877]` | 10.71364247 | 10.71364247 | 8.953e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7878]` | 6.017884629 | 6.017884629 | 1.255e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7879]` | 12.44091059 | 12.44091059 | 9.995e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7880]` | 11.07099065 | 11.07099065 | 2.567e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7881]` | 8.860245333 | 8.860245333 | 2.606e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7882]` | 5.382033225 | 5.382033225 | 5.314e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7883]` | 10.16301028 | 10.16301028 | 3.234e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7884]` | 7.516021294 | 7.516021294 | 8.863e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7885]` | 5.671828295 | 5.671828295 | 1.096e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7886]` | 13.09519564 | 13.09519564 | 5.927e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7887]` | 11.46401516 | 11.46401516 | 2.014e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7888]` | 2.708213558 | 2.708213558 | 6.231e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7889]` | 8.684854796 | 8.684854796 | 1.166e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7890]` | 8.883925864 | 8.883925864 | 2.999e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7891]` | 4.4706901 | 4.4706901 | 2.781e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7892]` | 14.90645101 | 14.90645101 | 3.098e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7893]` | 4.359796926 | 4.359796926 | 2.159e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7894]` | 9.914352851 | 9.914352851 | 4.121e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7895]` | 17.59660114 | 17.59660114 | 1.009e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7896]` | 5.057618233 | 5.057618233 | 1.229e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7897]` | 16.4086034 | 16.4086034 | 1.083e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7898]` | 13.93277056 | 13.93277056 | 5.100e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7899]` | 21.0696825 | 21.0696825 | 1.973e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7900]` | 13.34668325 | 13.34668325 | 1.331e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7901]` | 18.20131645 | 18.20131645 | 4.372e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7902]` | 9.839419566 | 9.839419566 | 1.083e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7903]` | 6.376364049 | 6.376364049 | 6.825e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7904]` | 8.877060197 | 8.877060197 | 2.601e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7905]` | 9.515867717 | 9.515867717 | 2.763e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7906]` | 5.917893258 | 5.917893258 | 4.052e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7908]` | 7.494298271 | 7.494298271 | 2.050e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7909]` | 4.307712306 | 4.307712306 | 9.897e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7910]` | 3.550162395 | 3.550162395 | 3.377e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7911]` | 20.15909613 | 20.15909613 | 5.287e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7912]` | 7.936344246 | 7.936344246 | 1.679e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7913]` | 4.758654509 | 4.758654509 | 2.986e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7914]` | 16.88066421 | 16.88066421 | 1.010e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7915]` | 7.241707282 | 7.241707282 | 8.831e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7916]` | 8.468663124 | 8.468663124 | 1.468e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7917]` | 11.53244979 | 11.53244979 | 3.543e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7918]` | 7.110530947 | 7.110530947 | 8.619e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7919]` | 7.893425869 | 7.893425869 | 5.063e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7920]` | 18.53913773 | 18.53913773 | 2.319e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7921]` | 7.911234257 | 7.911234257 | 2.919e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7922]` | 6.723367202 | 6.723367202 | 3.303e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7923]` | 4.198822876 | 4.198822876 | 8.461e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7924]` | 10.47283729 | 10.47283729 | 2.035e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7925]` | 11.30211569 | 11.30211569 | 5.029e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7926]` | 7.277505915 | 7.277505915 | 2.197e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7927]` | 7.265305891 | 7.265305891 | 2.200e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7928]` | 4.249479028 | 4.249479028 | 2.048e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7929]` | 22.20971662 | 22.20971662 | 5.919e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7930]` | 9.859438098 | 9.859438098 | 2.216e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7931]` | 11.16018938 | 11.16018938 | 1.051e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7932]` | 7.682722894 | 7.682722894 | 7.861e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7933]` | 16.18855205 | 16.18855205 | 3.072e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7934]` | 15.25000866 | 15.25000866 | 1.444e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7935]` | 10.72294847 | 10.72294847 | 1.557e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7936]` | 26.64388989 | 26.64388989 | 8.000e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7937]` | 7.19377658 | 7.19377658 | 2.580e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7938]` | 5.377751697 | 5.377751697 | 7.663e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7939]` | 9.47710064 | 9.47710064 | 1.406e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7940]` | 20.44827466 | 20.44827466 | 6.428e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7941]` | 6.344997568 | 6.344997568 | 2.940e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7942]` | 4.519230558 | 4.519230558 | 1.592e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7943]` | 6.647938573 | 6.647938573 | 1.336e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7944]` | 5.395535304 | 5.395535304 | 1.202e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7945]` | 15.97051813 | 15.97051813 | 1.223e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7946]` | 10.03035291 | 10.03035291 | 4.959e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7947]` | 10.66680586 | 10.66680586 | 2.331e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7948]` | 3.502777061 | 3.502777061 | 3.677e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7949]` | 3.676653317 | 3.676653317 | 7.247e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7950]` | 5.282622498 | 5.282622498 | 3.363e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7951]` | 9.962654019 | 9.962654019 | 2.040e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7952]` | 14.56979498 | 14.56979498 | 6.096e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7953]` | 10.90399723 | 10.90399723 | 9.612e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7954]` | 2.896674864 | 2.896674864 | 1.594e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7955]` | 4.985249301 | 4.985249301 | 2.245e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7956]` | 3.934811696 | 3.934811696 | 1.817e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7957]` | 6.388224076 | 6.388224076 | 8.342e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7958]` | 10.09993533 | 10.09993533 | 6.156e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7959]` | 8.167499677 | 8.167499677 | 3.915e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7960]` | 9.928524038 | 9.928524038 | 1.073e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7961]` | 18.58340628 | 18.58340628 | 1.185e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7962]` | 19.8490447 | 19.8490447 | 2.506e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7963]` | 17.89808124 | 17.89808124 | 2.005e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7964]` | 9.053789596 | 9.053789596 | 2.590e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7965]` | 16.48307556 | 16.48307556 | 6.466e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7966]` | 10.90379151 | 10.90379151 | 5.148e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7967]` | 9.027876675 | 9.027876675 | 9.051e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7968]` | 5.909542921 | 5.909542921 | 9.018e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7969]` | 11.50663074 | 11.50663074 | 1.698e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7970]` | 5.963456523 | 5.963456523 | 1.340e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7971]` | 9.144909776 | 9.144909776 | 1.748e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7972]` | 7.25127988 | 7.25127988 | 7.104e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7973]` | 10.01639052 | 10.01639052 | 5.781e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7974]` | 7.100890226 | 7.100890226 | 9.256e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7975]` | 10.03244322 | 10.03244322 | 1.257e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7976]` | 17.37955021 | 17.37955021 | 1.145e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7977]` | 4.688069903 | 4.688069903 | 1.023e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7978]` | 6.74054367 | 6.74054367 | 4.348e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7979]` | 1.227358391 | 1.227358391 | 2.077e-13 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7980]` | 8.520688789 | 8.520688789 | 4.378e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7981]` | 15.36863209 | 15.36863209 | 2.381e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7982]` | 8.637693028 | 8.637693028 | 5.347e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7983]` | 4.946655187 | 4.946655187 | 9.516e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7984]` | 14.49227695 | 14.49227695 | 2.280e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7985]` | 9.498770391 | 9.498770391 | 1.029e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7986]` | 14.20140701 | 14.20140701 | 2.001e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7987]` | 11.34967391 | 11.34967391 | 3.193e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7988]` | 2.885911716 | 2.885911716 | 5.047e-14 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7989]` | 10.41580868 | 10.41580868 | 1.705e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7990]` | 17.80567988 | 17.80567988 | 7.183e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7991]` | 9.605118184 | 9.605118184 | 7.398e-16 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[7992]` | 16.83016342 | 16.83016342 | 1.267e-15 | relatif, dérive ≤ 1e-06 |
| `bootstrap$stats_boot[9991]` | 0.0002674732389 | 0.0002660226419 | 5.423e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[9992]` | 0.0005769215695 | 0.0005762299646 | 1.199e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[9993]` | 0.0004551502898 | 0.000445608408 | 2.096e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[9994]` | 0.0005878197273 | 0.0005709872321 | 2.864e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[9995]` | 0.0003815899257 | 0.0003789136103 | 7.014e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[9996]` | 0.0005778618806 | 0.0005775895724 | 4.712e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[9997]` | 0.0008388089544 | 0.0008305429656 | 9.854e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[9998]` | 0.0005792270943 | 0.0005659381944 | 2.294e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[9999]` | 0.0004134640998 | 0.0004003688707 | 3.167e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10000]` | 0.0004977425808 | 0.0004968802675 | 1.732e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10001]` | 0.0003290988807 | 0.0003238257657 | 1.602e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10002]` | 0.0008837560546 | 0.0008835247858 | 2.617e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10003]` | 0.0005728908041 | 0.0005703031164 | 4.517e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10004]` | 0.0003824259892 | 0.0003815100734 | 2.395e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10005]` | 0.0004661415956 | 0.0004542271179 | 2.556e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10006]` | 0.0008777054452 | 0.0008710480693 | 7.585e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10007]` | 0.0006404406289 | 0.0006332218956 | 1.127e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10008]` | 0.0007656593796 | 0.0007633635617 | 2.998e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10009]` | 0.0005109924908 | 0.0005061784375 | 9.421e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10010]` | 0.000325554792 | 0.0003245035779 | 3.229e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10011]` | 0.0002649208726 | 0.0002629233204 | 7.540e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10012]` | 0.0003216298409 | 0.0003176979574 | 1.222e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10013]` | 0.0005219846638 | 0.0005137962826 | 1.569e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10014]` | 7.362869929e-05 | 7.256150192e-05 | 1.449e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10015]` | 0.0008714970871 | 0.0008659579487 | 6.356e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10016]` | 0.0004657315854 | 0.0004636905262 | 4.382e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10017]` | 0.0004085824543 | 0.0004084872811 | 2.329e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10018]` | 0.000353107452 | 0.0003365694648 | 4.684e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10019]` | 0.0004539351419 | 0.0004480362485 | 1.300e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10020]` | 0.0002961539152 | 0.0002879515095 | 2.770e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10021]` | 0.0004106914244 | 0.0004004473752 | 2.494e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10022]` | 0.0005278091107 | 0.0005231026767 | 8.917e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10023]` | 0.0007011490082 | 0.0006856659554 | 2.208e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10024]` | 0.0002570196852 | 0.0002542968942 | 1.059e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10025]` | 0.0005844081491 | 0.0005811095135 | 5.644e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10026]` | 0.0003621425391 | 0.0003575822363 | 1.259e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10027]` | 0.0004161487121 | 0.000415250785 | 2.158e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10028]` | 0.0002229603916 | 0.0002187906972 | 1.870e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10029]` | 0.0005921821169 | 0.0005921691064 | 2.197e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10030]` | 0.0007539222117 | 0.0007509410338 | 3.954e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10031]` | 0.0005636982653 | 0.0005513069092 | 2.198e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10032]` | 0.0003920653893 | 0.0003864341197 | 1.436e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10033]` | 0.000445102876 | 0.0004433860602 | 3.857e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10034]` | 0.0005154957253 | 0.0005123984741 | 6.008e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10035]` | 0.0006375928105 | 0.0006331498189 | 6.968e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10036]` | 0.0005217047228 | 0.0005173090398 | 8.426e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10037]` | 0.0004856414904 | 0.000482128152 | 7.234e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10038]` | 0.0004357748463 | 0.0004346000338 | 2.696e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10039]` | 7.086759837e-05 | 6.976670446e-05 | 1.553e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10040]` | 0.0004615372292 | 0.0004455640367 | 3.461e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10041]` | 0.0005266862049 | 0.0005218325244 | 9.216e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10042]` | 0.0005173312404 | 0.0005124584503 | 9.419e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10043]` | 0.0004736569483 | 0.0004672601004 | 1.351e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10044]` | 0.0005630705297 | 0.0005553239466 | 1.376e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10045]` | 0.0003979725668 | 0.0003888342685 | 2.296e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10046]` | 0.0002383411811 | 0.0002328631818 | 2.298e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10047]` | 0.0008978133688 | 0.0008966029513 | 1.348e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10048]` | 0.0003214082836 | 0.0003159533926 | 1.697e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10049]` | 0.0003489790697 | 0.0003410030684 | 2.286e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10050]` | 0.0003506323425 | 0.0003412980133 | 2.662e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10051]` | 0.0004270944733 | 0.0004238774888 | 7.532e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10052]` | 0.0004324886001 | 0.0004219551169 | 2.436e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10053]` | 0.0005305873021 | 0.0005283510363 | 4.215e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10054]` | 0.0003858127152 | 0.0003837566263 | 5.329e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10055]` | 0.0005994853887 | 0.0005974008791 | 3.477e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10056]` | 0.0001811831825 | 0.0001810696867 | 6.264e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10057]` | 0.0007220709837 | 0.0007101833425 | 1.646e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10058]` | 0.0004870393479 | 0.0004869530398 | 1.772e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10059]` | 0.001086230586 | 0.001085293566 | 8.626e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10060]` | 0.0005458322305 | 0.0005389469878 | 1.261e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10061]` | 0.0005825711128 | 0.000575724783 | 1.175e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10062]` | 0.0004266714009 | 0.0004259110722 | 1.782e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10063]` | 0.0007323054065 | 0.0007300221529 | 3.118e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10064]` | 0.0002574301445 | 0.0002559031962 | 5.932e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10065]` | 0.000477801118 | 0.0004746035542 | 6.692e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10066]` | 0.0004870138375 | 0.0004750777185 | 2.451e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10067]` | 0.0008037505099 | 0.0007900369121 | 1.706e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10068]` | 0.0004300190966 | 0.0004231648396 | 1.594e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10069]` | 0.000516306778 | 0.0005063854994 | 1.922e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10070]` | 0.0004034050832 | 0.0003986240307 | 1.185e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10071]` | 0.0004138845803 | 0.0003987937445 | 3.646e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10072]` | 0.0007454616341 | 0.0007375811891 | 1.057e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10073]` | 0.0005823479981 | 0.0005633778517 | 3.258e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10074]` | 0.0005355342425 | 0.0005276000024 | 1.482e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10075]` | 0.0008012130199 | 0.0008007398579 | 5.906e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10076]` | 0.0004465915521 | 0.0004453898989 | 2.691e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10077]` | 0.0003167228142 | 0.000315894408 | 2.616e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10078]` | 0.000207734349 | 0.0002036658663 | 1.959e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10079]` | 0.000711072625 | 0.0007023104807 | 1.232e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10080]` | 0.0005848729963 | 0.0005738848172 | 1.879e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10081]` | 0.0003387143444 | 0.0003348851478 | 1.131e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10082]` | 0.0005926287785 | 0.0005847240767 | 1.334e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10083]` | 0.0004187719788 | 0.0004046719629 | 3.367e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10084]` | 0.0003625675479 | 0.0003542857054 | 2.284e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10085]` | 0.000680730879 | 0.0006806668359 | 9.408e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10086]` | 0.0007712595753 | 0.0007680918774 | 4.107e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10087]` | 0.0002362783141 | 0.0002357985403 | 2.031e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10088]` | 0.0002903001476 | 0.0002869936917 | 1.139e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10089]` | 0.0003876569483 | 0.0003853132442 | 6.046e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10090]` | 0.0001656105337 | 0.0001589116838 | 4.045e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10091]` | 0.0004810271452 | 0.0004791323113 | 3.939e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10092]` | 0.0005475941466 | 0.0005416908728 | 1.078e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10093]` | 0.0003273751592 | 0.0003229221234 | 1.360e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10094]` | 0.0006166583466 | 0.0006149622348 | 2.750e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10095]` | 0.0007012934041 | 0.0007005321919 | 1.085e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10096]` | 0.0005223957893 | 0.0005220284571 | 7.032e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10097]` | 0.0006240453405 | 0.0006145190802 | 1.527e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10098]` | 0.0003513462034 | 0.0003484847097 | 8.144e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10099]` | 0.0006350503703 | 0.0006339528751 | 1.728e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10100]` | 0.0004942960536 | 0.0004938120805 | 9.791e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10101]` | 0.0002628543879 | 0.0002609730452 | 7.157e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10102]` | 0.0005028713125 | 0.0004950403382 | 1.557e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10103]` | 0.0008059367186 | 0.0008051803619 | 9.385e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10104]` | 0.0003550160046 | 0.0003526149733 | 6.763e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10105]` | 0.0007710922957 | 0.000767349474 | 4.854e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10106]` | 0.0002727692013 | 0.0002651098328 | 2.808e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10107]` | 0.0004631213701 | 0.0004585526833 | 9.865e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10108]` | 0.0003734487068 | 0.0003636505439 | 2.624e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10109]` | 0.000574745069 | 0.0005745915583 | 2.671e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10110]` | 0.0008069595176 | 0.0008026345195 | 5.360e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10111]` | 0.0005259244572 | 0.0005257931098 | 2.497e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10112]` | 0.0005115072159 | 0.0005103543322 | 2.254e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10113]` | 0.000557317979 | 0.0005517813154 | 9.934e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10114]` | 0.0006133068076 | 0.0006132866353 | 3.289e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10115]` | 0.0005689314356 | 0.000558508136 | 1.832e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10116]` | 0.000468947175 | 0.0004659533738 | 6.384e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10117]` | 0.0004660669199 | 0.0004621219155 | 8.464e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10118]` | 0.0005413369934 | 0.0005327032 | 1.595e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10119]` | 0.0006377735511 | 0.0006375998728 | 2.723e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10120]` | 0.001108381457 | 0.00110476337 | 3.264e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10121]` | 0.0008336833663 | 0.0008271002803 | 7.896e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10122]` | 0.0006415256135 | 0.0006373214701 | 6.553e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10123]` | 0.000611590725 | 0.0005996779875 | 1.948e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10124]` | 0.0002436943658 | 0.0002433096561 | 1.579e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10125]` | 0.0002645936979 | 0.0002623683353 | 8.410e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10126]` | 0.0005873243127 | 0.0005833048427 | 6.844e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10127]` | 0.0009309198775 | 0.0009168973401 | 1.506e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10128]` | 0.0003540035344 | 0.0003480998999 | 1.668e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10129]` | 0.0003483060437 | 0.0003442563506 | 1.163e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10130]` | 0.0003616093429 | 0.0003514891374 | 2.799e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10131]` | 0.0004031958303 | 0.0004017842326 | 3.501e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10132]` | 0.0002551752298 | 0.0002485440193 | 2.599e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10133]` | 0.0004098776768 | 0.0004080373154 | 4.490e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10134]` | 0.000969990162 | 0.000963972462 | 6.204e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10135]` | 0.000778283065 | 0.0007681495421 | 1.302e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10136]` | 0.0004044866556 | 0.0004017621196 | 6.736e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10137]` | 0.0007013403018 | 0.0006860973068 | 2.173e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10138]` | 0.0001163897397 | 0.0001109141768 | 4.705e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10139]` | 0.0005299441253 | 0.0005255343197 | 8.321e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10140]` | 0.001105896673 | 0.001098616374 | 6.583e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10141]` | 0.0006394206885 | 0.0006378923737 | 2.390e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10142]` | 0.0004135067308 | 0.0004121172561 | 3.360e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10143]` | 0.0005767803696 | 0.000574714671 | 3.581e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10144]` | 0.0005029440794 | 0.0004985094316 | 8.817e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10145]` | 0.0003815102595 | 0.000381320008 | 4.987e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10146]` | 0.0005185610624 | 0.0005185168422 | 8.527e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10147]` | 0.0007897916089 | 0.0007834479916 | 8.032e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10148]` | 0.0008218609403 | 0.0008033357893 | 2.254e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10149]` | 0.0006928519859 | 0.00068886742 | 5.751e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10150]` | 0.0007398660388 | 0.0007334008719 | 8.738e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10151]` | 0.0005722158437 | 0.0005665225075 | 9.950e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10152]` | 0.0003829187576 | 0.000380572772 | 6.127e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10153]` | 0.0007140788282 | 0.0007068279191 | 1.015e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10154]` | 0.0004957489939 | 0.0004930014672 | 5.542e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10155]` | 0.0004537595207 | 0.0004435037422 | 2.260e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10156]` | 0.0005984671188 | 0.0005905128114 | 1.329e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10157]` | 0.0004254348459 | 0.0004212680705 | 9.794e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10158]` | 0.0007396869704 | 0.0007327456982 | 9.384e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10159]` | 0.0003801148252 | 0.0003761042331 | 1.055e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10160]` | 0.0005203366014 | 0.0005074079697 | 2.485e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10161]` | 0.0006058547097 | 0.0005973021166 | 1.412e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10162]` | 0.0006207089439 | 0.0006199318364 | 1.252e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10163]` | 0.0008144506453 | 0.0008118196548 | 3.230e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10164]` | 0.0002741537547 | 0.0002733289842 | 3.008e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10165]` | 0.0004506082333 | 0.0004457116599 | 1.087e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10166]` | 0.0002372290154 | 0.0002331673937 | 1.712e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10167]` | 0.0003615021186 | 0.0003547723117 | 1.862e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10168]` | 0.0004528853249 | 0.0004403449837 | 2.769e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10169]` | 0.0002661592957 | 0.0002548816326 | 4.237e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10170]` | 0.0007608729532 | 0.0007458259957 | 1.978e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10171]` | 0.0006189041673 | 0.0006104041264 | 1.373e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10172]` | 0.0007188867744 | 0.0006951855395 | 3.297e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10173]` | 0.0005241348859 | 0.0005221290337 | 3.827e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10174]` | 0.0005070225879 | 0.0004938307517 | 2.602e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10175]` | 0.0007588634513 | 0.000754485293 | 5.769e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10176]` | 0.0006615038295 | 0.0006538710321 | 1.154e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10177]` | 0.0005778111331 | 0.0005737078124 | 7.101e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10178]` | 0.0004569463075 | 0.0004533289432 | 7.916e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10179]` | 0.0003531263972 | 0.0003515238414 | 4.538e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10180]` | 0.0006073372563 | 0.0006049154145 | 3.988e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10181]` | 0.0005749912635 | 0.0005731656022 | 3.175e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10182]` | 0.0006340704376 | 0.0006179343026 | 2.545e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10183]` | 0.0003114957466 | 0.0003032676858 | 2.641e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10184]` | 0.0007520466147 | 0.0007450372063 | 9.320e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10185]` | 0.0003103618851 | 0.0003096271513 | 2.367e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10186]` | 0.0007945814368 | 0.0007871599185 | 9.340e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10187]` | 0.000693504956 | 0.0006864592818 | 1.016e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10188]` | 0.001001989819 | 0.0009966360101 | 5.343e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10189]` | 0.0001767434781 | 0.0001756293857 | 6.303e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10190]` | 0.0004925591563 | 0.0004889125336 | 7.403e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10191]` | 0.0007415803892 | 0.0007404589226 | 1.512e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10192]` | 0.0005678776727 | 0.0005629954656 | 8.597e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10193]` | 0.0009347335033 | 0.0009344405403 | 3.134e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10194]` | 0.0003538051609 | 0.0003518575776 | 5.505e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10195]` | 0.0005763380997 | 0.0005731712278 | 5.495e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10196]` | 0.0002905726695 | 0.0002899256884 | 2.227e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10197]` | 0.0006798891736 | 0.0006746546798 | 7.699e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10198]` | 0.000395368912 | 0.0003912359351 | 1.045e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10199]` | 0.000995145167 | 0.0009885759128 | 6.601e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10200]` | 0.0003004395816 | 0.0002995989755 | 2.798e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10201]` | 0.000314427556 | 0.0003105245235 | 1.241e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10202]` | 0.0006353445685 | 0.0006258211429 | 1.499e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10203]` | 0.0004252519492 | 0.000416939393 | 1.955e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10204]` | 0.0006369881404 | 0.0006337236851 | 5.125e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10205]` | 0.0002578129043 | 0.0002528544364 | 1.923e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10206]` | 0.0002978869649 | 0.0002966823883 | 4.044e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10207]` | 0.0003894574664 | 0.0003867488733 | 6.955e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10208]` | 0.0005217472838 | 0.000516281015 | 1.048e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10209]` | 0.0007513433423 | 0.0007501818581 | 1.546e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10210]` | 0.0009080750952 | 0.0009032870398 | 5.273e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10211]` | 0.000270946574 | 0.0002696003606 | 4.969e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10212]` | 0.0007765079832 | 0.0007751958863 | 1.690e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10213]` | 0.0001786995224 | 0.0001769445534 | 9.821e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10214]` | 0.0004288077336 | 0.0004285757889 | 5.409e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10215]` | 0.0007128104805 | 0.0007048667446 | 1.114e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10216]` | 0.0006854233162 | 0.0006830492435 | 3.464e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10217]` | 0.0003395646899 | 0.0003368410526 | 8.021e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10218]` | 0.0002064654361 | 0.0002046535528 | 8.776e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10219]` | 0.000772892782 | 0.0007692562992 | 4.705e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10220]` | 0.0008104414404 | 0.0008088196571 | 2.001e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10221]` | 0.0004523376609 | 0.0004497821444 | 5.650e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10222]` | 0.0006375534493 | 0.0006304291304 | 1.117e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10223]` | 0.0004802986324 | 0.0004777342928 | 5.339e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10224]` | 0.000212801076 | 0.0002053602006 | 3.497e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10225]` | 0.0005192085087 | 0.0005182508996 | 1.844e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10226]` | 0.0005763457501 | 0.000573701422 | 4.588e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10227]` | 0.0007852866924 | 0.0007847713071 | 6.563e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10228]` | 0.0001727704237 | 0.0001688497523 | 2.269e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10229]` | 0.0002768468018 | 0.000275558439 | 4.654e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10230]` | 0.0003614033347 | 0.0003569828353 | 1.223e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10231]` | 0.0007902927781 | 0.0007879981701 | 2.903e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10232]` | 0.0001596969646 | 0.0001529894185 | 4.200e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10233]` | 0.0004676953665 | 0.0004625837172 | 1.093e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10234]` | 0.000137012507 | 0.0001366925086 | 2.336e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10235]` | 0.0003848256852 | 0.0003760716881 | 2.275e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10236]` | 0.0003804052046 | 0.0003775198722 | 7.585e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10237]` | 0.0005920584764 | 0.0005861478946 | 9.983e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10238]` | 0.0007677163191 | 0.000758989428 | 1.137e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10239]` | 0.0002477135004 | 0.000243929917 | 1.527e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10240]` | 0.0003455898032 | 0.0003408725425 | 1.365e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10241]` | 0.0003897320377 | 0.0003859404679 | 9.729e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10242]` | 0.0006463220161 | 0.000637761346 | 1.325e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10243]` | 0.0002824523262 | 0.0002793117218 | 1.112e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10244]` | 0.0006169651292 | 0.0006110293177 | 9.621e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10245]` | 0.0005594740731 | 0.0005573833529 | 3.737e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10246]` | 0.0004516704695 | 0.000443654488 | 1.775e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10247]` | 0.0007078130068 | 0.000694325864 | 1.905e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10248]` | 0.0008279072177 | 0.0008124116235 | 1.872e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10249]` | 0.0006872740387 | 0.000671525353 | 2.291e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10250]` | 0.000397621496 | 0.0003948728018 | 6.913e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10251]` | 0.0006878365936 | 0.0006858066379 | 2.951e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10252]` | 0.0005114078848 | 0.0005094904202 | 3.749e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10253]` | 0.0008741733527 | 0.0008681162144 | 6.929e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10254]` | 0.0004528883402 | 0.0004512743137 | 3.564e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10255]` | 0.0008145593085 | 0.0008139893968 | 6.997e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10256]` | 0.0003990510732 | 0.0003969659421 | 5.225e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10257]` | 0.0006880969507 | 0.0006840231619 | 5.920e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10258]` | 0.0006793646544 | 0.0006703154017 | 1.332e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10259]` | 0.0005553062712 | 0.0005518861319 | 6.159e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10260]` | 0.0004072455897 | 0.0004037476383 | 8.589e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10261]` | 0.0004971249177 | 0.0004930228937 | 8.251e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10262]` | 0.0007664165936 | 0.00076135937 | 6.599e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10263]` | 0.0002129766142 | 0.0002097866651 | 1.498e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10264]` | 0.0005691458821 | 0.0005684312946 | 1.256e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10265]` | 0.0005047127765 | 0.0005033972247 | 2.607e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10266]` | 0.0003248844908 | 0.00032325507 | 5.015e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10267]` | 0.0006381329135 | 0.000624082262 | 2.202e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10268]` | 0.0004585455782 | 0.000455860249 | 5.856e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10269]` | 0.0004090876097 | 0.0004087320063 | 8.693e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10270]` | 0.0005053843801 | 0.0005025477796 | 5.613e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10271]` | 0.0008077828248 | 0.00080049155 | 9.026e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10272]` | 0.0006147912145 | 0.0006089627827 | 9.480e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10273]` | 0.001217623017 | 0.00120994928 | 6.302e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10274]` | 0.0004324077392 | 0.0004322093959 | 4.587e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10275]` | 0.000758128031 | 0.0007541471954 | 5.251e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10276]` | 0.0004016460404 | 0.0004003221897 | 3.296e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10277]` | 0.0005416950693 | 0.0005364992564 | 9.592e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10278]` | 0.000444023397 | 0.0004411204749 | 6.538e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10279]` | 0.0004021407306 | 0.0003977075951 | 1.102e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10280]` | 0.0005831504285 | 0.0005817640572 | 2.377e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10281]` | 0.0003851478531 | 0.0003833585395 | 4.646e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10282]` | 0.0003637660186 | 0.0003599947627 | 1.037e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10283]` | 0.000332085821 | 0.0003300310304 | 6.188e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10284]` | 0.0005168767049 | 0.0005166497961 | 4.390e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10285]` | 0.0009139109908 | 0.0009101815888 | 4.081e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10286]` | 0.0004799247019 | 0.0004790463813 | 1.830e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10287]` | 0.0005406386288 | 0.0005224516502 | 3.364e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10288]` | 0.0003597267082 | 0.0003587440951 | 2.732e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10289]` | 0.000584024943 | 0.0005794881191 | 7.768e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10290]` | 0.0007838492149 | 0.0007800838797 | 4.804e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10291]` | 0.0006180155517 | 0.0006112086404 | 1.101e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10292]` | 0.0005865382614 | 0.0005764052388 | 1.728e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10293]` | 0.0005708219374 | 0.0005683029957 | 4.413e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10294]` | 0.0006171957804 | 0.0006007370423 | 2.667e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10295]` | 0.0006483970933 | 0.000643294275 | 7.870e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10296]` | 0.0006865914301 | 0.0006769060341 | 1.411e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10297]` | 0.000621421701 | 0.0006188254442 | 4.178e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10298]` | 0.0005958370038 | 0.0005900825218 | 9.658e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10299]` | 0.0002554749643 | 0.0002516621494 | 1.492e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10300]` | 0.000525669938 | 0.0005234943235 | 4.139e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10301]` | 0.0003643242018 | 0.0003462816391 | 4.952e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10302]` | 0.0007549161077 | 0.0007548219437 | 1.247e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10303]` | 0.0004399528108 | 0.0004353597804 | 1.044e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10304]` | 0.0005535537968 | 0.0005535041924 | 8.961e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10305]` | 0.0007788272952 | 0.0007724929548 | 8.133e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10306]` | 0.0006806349676 | 0.0006730342675 | 1.117e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10307]` | 0.0003190205682 | 0.0003141265604 | 1.534e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10308]` | 0.0006805410188 | 0.0006797181748 | 1.209e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10309]` | 0.0005846735316 | 0.0005807440156 | 6.721e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10310]` | 0.0003406390415 | 0.0003379570941 | 7.873e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10311]` | 0.0005226429255 | 0.0005210040377 | 3.136e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10312]` | 0.0003719596888 | 0.0003642367796 | 2.076e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10313]` | 0.0002192697703 | 0.000213544781 | 2.611e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10314]` | 0.0005216035237 | 0.0005138279097 | 1.491e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10315]` | 0.0005447249992 | 0.0005400980295 | 8.494e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10316]` | 0.0003773215692 | 0.0003707773399 | 1.734e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10317]` | 0.0005870438703 | 0.0005844446439 | 4.428e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10318]` | 0.000898494233 | 0.0008981009033 | 4.378e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10319]` | 0.0003450420835 | 0.0003402911442 | 1.377e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10320]` | 0.0002151321873 | 0.0002140233919 | 5.154e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10321]` | 0.00059696926 | 0.0005963890621 | 9.719e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10322]` | 0.0005547527581 | 0.0005500394276 | 8.496e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10323]` | 0.0005545982427 | 0.0005514698578 | 5.641e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10324]` | 0.0006132216422 | 0.0006118816087 | 2.185e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10325]` | 0.0005586297864 | 0.0005573878445 | 2.223e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10326]` | 0.0005172704976 | 0.0005066566864 | 2.052e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10327]` | 0.0005344120365 | 0.0005287736814 | 1.055e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10328]` | 0.0002511930779 | 0.0002462293187 | 1.976e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10329]` | 0.0005804119316 | 0.0005789616645 | 2.499e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10330]` | 0.0004226831748 | 0.0004216162356 | 2.524e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10331]` | 0.0002363310629 | 0.0002268949692 | 3.993e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10332]` | 0.0004237859912 | 0.0004214331392 | 5.552e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10333]` | 0.0002807632049 | 0.0002788362921 | 6.863e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10334]` | 0.0008762434324 | 0.0008743980188 | 2.106e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10335]` | 0.000688080371 | 0.0006867964207 | 1.866e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10336]` | 0.0002053241643 | 0.000201417712 | 1.903e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10337]` | 0.0003856457054 | 0.0003829100095 | 7.094e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10338]` | 0.0003683238139 | 0.000363399409 | 1.337e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10339]` | 0.0006345507102 | 0.0006300131377 | 7.151e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10340]` | 0.0002652129152 | 0.0002622797058 | 1.106e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10341]` | 0.0007724981702 | 0.0007603123762 | 1.577e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10342]` | 0.0002708499114 | 0.0002693091868 | 5.688e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10343]` | 0.0005594522383 | 0.0005475331675 | 2.130e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10344]` | 0.0004438704097 | 0.0004425060918 | 3.074e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10345]` | 0.0003568969864 | 0.00035409251 | 7.858e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10346]` | 0.0004880561818 | 0.0004789646581 | 1.863e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10347]` | 0.001131455953 | 0.001122630311 | 7.800e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10348]` | 0.0002651672831 | 0.0002564958015 | 3.270e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10349]` | 0.0003012103459 | 0.0002979483417 | 1.083e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10350]` | 0.0006091204229 | 0.0005989540757 | 1.669e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10351]` | 0.0005337424864 | 0.0005336706715 | 1.345e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10352]` | 0.0007141317451 | 0.0007045767072 | 1.338e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10353]` | 0.0003783657428 | 0.0003759798458 | 6.306e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10354]` | 0.0003662002112 | 0.0003518900574 | 3.908e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10355]` | 0.0007703192956 | 0.00076495404 | 6.965e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10356]` | 0.000569134797 | 0.0005663127682 | 4.958e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10357]` | 0.0003905876008 | 0.000390138663 | 1.149e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10358]` | 0.0001946277744 | 0.0001889509175 | 2.917e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10359]` | 0.0005102476465 | 0.0004953348931 | 2.923e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10360]` | 0.000278716417 | 0.0002764392535 | 8.170e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10361]` | 0.0005239491483 | 0.0005166788733 | 1.388e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10362]` | 0.0007157299657 | 0.0007157121224 | 2.493e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10363]` | 0.0005283462894 | 0.0005282955669 | 9.600e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10364]` | 0.0002931382543 | 0.0002864181747 | 2.292e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10365]` | 0.0006498997586 | 0.0006488847048 | 1.562e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10366]` | 0.0009645357326 | 0.0009517595616 | 1.325e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10367]` | 0.0004842834337 | 0.0004837540208 | 1.093e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10368]` | 0.0002812260241 | 0.0002793169711 | 6.788e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10369]` | 0.0005021441841 | 0.0004985415884 | 7.174e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10370]` | 0.0005061701327 | 0.0005053206041 | 1.678e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10371]` | 0.0008427689656 | 0.0008385263641 | 5.034e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10372]` | 0.0004101351092 | 0.0004091898162 | 2.305e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10373]` | 0.0003173564501 | 0.0003066702243 | 3.367e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10374]` | 0.0006501164217 | 0.0006473557894 | 4.246e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10375]` | 0.0005997126625 | 0.0005945172488 | 8.663e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10376]` | 0.0004318036244 | 0.0004254139305 | 1.480e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10377]` | 0.0002465037564 | 0.0002395794359 | 2.809e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10378]` | 0.0007561345194 | 0.0007549181429 | 1.609e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10379]` | 0.0007020542646 | 0.0006946998474 | 1.048e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10380]` | 0.0003147573745 | 0.0003141613983 | 1.893e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10381]` | 0.0007704146898 | 0.0007685953419 | 2.362e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10382]` | 0.0002495091613 | 0.000242654029 | 2.747e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10383]` | 0.0007707150305 | 0.000768514812 | 2.855e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10384]` | 0.0002917191026 | 0.000291087549 | 2.165e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10385]` | 0.0007468232345 | 0.0007384126985 | 1.126e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10386]` | 0.0002848006694 | 0.0002797991208 | 1.756e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10387]` | 0.0001848889652 | 0.000184535147 | 1.914e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10388]` | 0.000304721852 | 0.0003044331268 | 9.475e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10389]` | 0.0003980184132 | 0.0003906103672 | 1.861e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10390]` | 0.0008001007055 | 0.0007945983227 | 6.877e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10391]` | 0.0005530728204 | 0.0005469195514 | 1.113e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10392]` | 0.000670020422 | 0.0006638537474 | 9.204e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10393]` | 0.0003207535327 | 0.0003193788815 | 4.286e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10394]` | 0.0006341415222 | 0.0006334216554 | 1.135e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10395]` | 0.0007802827252 | 0.0007724541795 | 1.003e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10396]` | 0.0005167961125 | 0.0005142225646 | 4.980e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10397]` | 0.0003243902442 | 0.0003223478647 | 6.296e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10398]` | 0.0005103876913 | 0.0005050970199 | 1.037e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10399]` | 0.0003741787527 | 0.0003685702329 | 1.499e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10400]` | 0.0002711864173 | 0.0002647398491 | 2.377e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10401]` | 0.0003876637589 | 0.0003837555435 | 1.008e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10402]` | 0.0004571103075 | 0.0004569119539 | 4.339e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10403]` | 0.0002416749219 | 0.0002403861191 | 5.333e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10404]` | 0.0003405598831 | 0.0003369544452 | 1.059e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10405]` | 0.0007090727828 | 0.0007062311172 | 4.008e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10406]` | 0.0004160152122 | 0.0004122420852 | 9.070e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10407]` | 0.0005577195754 | 0.0005545199005 | 5.737e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10408]` | 0.0004215362163 | 0.0004195680042 | 4.669e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10409]` | 0.0009270069036 | 0.0009249240384 | 2.247e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10410]` | 0.00023662474 | 0.0002357813619 | 3.564e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10411]` | 0.0005420793753 | 0.0005391189329 | 5.461e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10412]` | 0.0005042476695 | 0.0005030337964 | 2.407e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10413]` | 0.0003059233241 | 0.0003043721929 | 5.070e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10414]` | 0.0005923358752 | 0.000592220474 | 1.948e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10415]` | 0.0004376983378 | 0.0004276534533 | 2.295e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10416]` | 0.0007694560061 | 0.0007694041612 | 6.738e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10417]` | 0.0007465241759 | 0.000737358124 | 1.228e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10418]` | 0.0002287137184 | 0.0002176990951 | 4.816e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10419]` | 0.000532261953 | 0.0005301756704 | 3.920e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10420]` | 0.0008299513359 | 0.0008216940597 | 9.949e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10421]` | 0.0006760907316 | 0.0006636416218 | 1.841e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10422]` | 0.0007855381935 | 0.0007827340545 | 3.570e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10423]` | 0.0005733441135 | 0.0005706062657 | 4.775e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10424]` | 0.0004067860428 | 0.0003979987497 | 2.160e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10425]` | 0.000565670308 | 0.0005494466184 | 2.868e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10426]` | 0.0007572226696 | 0.0007525476937 | 6.174e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10427]` | 0.0006418043953 | 0.0006347233356 | 1.103e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10428]` | 0.0001842640299 | 0.0001827311444 | 8.319e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10429]` | 0.0003729864641 | 0.000370390106 | 6.961e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10430]` | 0.0005875249429 | 0.0005850188576 | 4.265e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10431]` | 0.0004021191444 | 0.0003999947455 | 5.283e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10432]` | 0.0004731146751 | 0.0004726134761 | 1.059e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10433]` | 0.0005361398269 | 0.0005306894489 | 1.017e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10434]` | 0.000384692839 | 0.000382175451 | 6.544e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10435]` | 0.0005287349288 | 0.0005286007904 | 2.537e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10436]` | 0.0005654953231 | 0.0005571231336 | 1.481e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10437]` | 0.0002749811348 | 0.0002704989725 | 1.630e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10438]` | 0.00050541576 | 0.0005005956875 | 9.537e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10439]` | 0.0005374491736 | 0.000536319264 | 2.102e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10440]` | 0.000324417346 | 0.0003239068927 | 1.573e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10441]` | 0.0002652516438 | 0.0002625410602 | 1.022e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10442]` | 0.0007359233342 | 0.0007338692829 | 2.791e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10443]` | 0.000670357013 | 0.0006635729143 | 1.012e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10444]` | 0.000252285896 | 0.0002518232797 | 1.834e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10445]` | 0.0003435041793 | 0.0003410162931 | 7.243e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10446]` | 0.0002212599486 | 0.0002197814493 | 6.682e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10447]` | 0.0004493998223 | 0.0004468323821 | 5.713e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10448]` | 0.0002733690239 | 0.0002729565466 | 1.509e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10449]` | 0.00052313623 | 0.0005224989955 | 1.218e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10450]` | 0.0002634365098 | 0.0002607722184 | 1.011e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10451]` | 0.0001347842851 | 0.000133522765 | 9.360e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10452]` | 0.0005199019249 | 0.0005142740435 | 1.082e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10453]` | 0.0004059928439 | 0.0003998664509 | 1.509e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10454]` | 0.0004156462514 | 0.0004110502449 | 1.106e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10455]` | 0.0006065227989 | 0.0006023853955 | 6.822e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10456]` | 0.0003762612812 | 0.0003729521268 | 8.795e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10457]` | 0.0003630387622 | 0.0003567616632 | 1.729e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10458]` | 0.0004794656182 | 0.0004765005267 | 6.184e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10459]` | 0.0004004375522 | 0.0003973656976 | 7.671e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10460]` | 0.0002791726797 | 0.0002778732188 | 4.655e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10461]` | 0.0009063126695 | 0.000893506374 | 1.413e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10462]` | 0.0002346223396 | 0.0002342902091 | 1.416e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10463]` | 0.0006162046413 | 0.0006136018452 | 4.224e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10464]` | 0.0005273463464 | 0.0005141795094 | 2.497e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10465]` | 0.0006205026872 | 0.0006141048857 | 1.031e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10466]` | 0.0005199688451 | 0.0005147057084 | 1.012e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10467]` | 0.0007750328799 | 0.0007610140944 | 1.809e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10468]` | 0.0008659005028 | 0.0008599080763 | 6.920e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10469]` | 0.0006122693423 | 0.0006041117895 | 1.332e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10470]` | 0.0005417165783 | 0.0005398292977 | 3.484e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10471]` | 0.0003576123719 | 0.0003433498041 | 3.988e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10472]` | 0.0009304996762 | 0.000930189395 | 3.335e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10473]` | 0.0004699031661 | 0.0004669187851 | 6.351e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10474]` | 0.0002926491491 | 0.0002821186923 | 3.598e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10475]` | 0.0005591479174 | 0.0005572910902 | 3.321e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10476]` | 0.0005385232959 | 0.0005322019952 | 1.174e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10477]` | 0.0004997310951 | 0.0004942888395 | 1.089e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10478]` | 0.0003915015445 | 0.0003872993498 | 1.073e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10479]` | 0.0005367288739 | 0.0005358044265 | 1.722e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10480]` | 0.0004150402975 | 0.0004004529142 | 3.515e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10481]` | 0.0005977000786 | 0.0005923503314 | 8.951e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10482]` | 0.0005063190704 | 0.0005011417704 | 1.023e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10483]` | 0.0005309618224 | 0.0005175582618 | 2.524e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10484]` | 0.0005081838762 | 0.0005076149583 | 1.120e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10485]` | 0.0008624085312 | 0.0008536348378 | 1.017e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10486]` | 0.0008877366106 | 0.0008826545351 | 5.725e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10487]` | 0.0003126172144 | 0.0003059758966 | 2.124e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10488]` | 0.0001937944398 | 0.0001928543703 | 4.851e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10489]` | 0.000164379043 | 0.000162710924 | 1.015e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10490]` | 0.0002249478868 | 0.0002213675661 | 1.592e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10491]` | 0.0005012476327 | 0.0005010469781 | 4.003e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10492]` | 0.0004176849435 | 0.0004169267206 | 1.815e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10493]` | 0.0006272215507 | 0.0006232156905 | 6.387e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10494]` | 0.0004131382574 | 0.0004077578105 | 1.302e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10495]` | 0.0008022941013 | 0.0007962319975 | 7.556e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10496]` | 0.0007484433906 | 0.0007442860613 | 5.555e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10497]` | 0.0006115843506 | 0.0006088985515 | 4.392e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10498]` | 0.0007841128188 | 0.0007784885382 | 7.173e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10499]` | 0.0004945277182 | 0.0004810226632 | 2.731e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10500]` | 0.0002957043004 | 0.0002931942789 | 8.488e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10501]` | 0.0001184784239 | 0.0001175029196 | 8.234e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10502]` | 0.0006081723744 | 0.0006062474502 | 3.165e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10503]` | 0.0007636668912 | 0.0007565243904 | 9.353e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10504]` | 0.0007655634971 | 0.0007632559471 | 3.014e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10505]` | 0.0004408415345 | 0.0004357284917 | 1.160e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10506]` | 0.0005585043191 | 0.0005584726835 | 5.664e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10507]` | 0.0001618563336 | 0.0001581075447 | 2.316e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10508]` | 0.0004033326399 | 0.0003997259224 | 8.942e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10509]` | 0.0005763859845 | 0.0005701869009 | 1.076e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10510]` | 0.0006786824644 | 0.0006697442139 | 1.317e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10511]` | 0.0002337244928 | 0.0002319461825 | 7.609e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10512]` | 0.0005693520331 | 0.000564084081 | 9.253e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10513]` | 0.0005622235171 | 0.0005596231423 | 4.625e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10514]` | 0.0007774553844 | 0.000766877948 | 1.361e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10515]` | 0.0002024038768 | 0.0001957164708 | 3.304e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10516]` | 0.0003706002754 | 0.000364566731 | 1.628e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10517]` | 0.0005094047961 | 0.0005071528951 | 4.421e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10518]` | 0.0008167920854 | 0.0008132095332 | 4.386e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10519]` | 0.0009044477912 | 0.0009032716466 | 1.300e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10520]` | 0.000732397721 | 0.0007314027714 | 1.358e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10521]` | 0.0005074910383 | 0.000500632984 | 1.351e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10522]` | 0.0003547184213 | 0.0003487618708 | 1.679e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10523]` | 0.0006100960542 | 0.0005965553059 | 2.219e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10524]` | 0.0005518590475 | 0.000550668992 | 2.156e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10525]` | 0.0004545875404 | 0.000453794678 | 1.744e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10526]` | 0.000421928245 | 0.0004165659502 | 1.271e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10527]` | 0.001354182036 | 0.001348911216 | 3.892e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10528]` | 0.0007435419193 | 0.0007391848413 | 5.860e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10529]` | 0.0007672796305 | 0.0007634642399 | 4.973e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10530]` | 0.0005497983239 | 0.0005438598742 | 1.080e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10531]` | 0.0004305071287 | 0.0004291991428 | 3.038e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10532]` | 0.0003347987304 | 0.0003256659083 | 2.728e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10533]` | 0.0004717267032 | 0.0004591520372 | 2.666e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10534]` | 0.0006286464803 | 0.0006269204234 | 2.746e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10535]` | 0.0004414427567 | 0.0004396161286 | 4.138e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10536]` | 0.0002816304189 | 0.0002768982408 | 1.680e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10537]` | 0.0004402111338 | 0.0004383383921 | 4.254e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10538]` | 0.0004873517806 | 0.0004844836239 | 5.885e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10539]` | 0.000336877457 | 0.0003249963143 | 3.527e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10540]` | 0.0003749693107 | 0.0003695846621 | 1.436e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10541]` | 0.0002909304036 | 0.0002877695251 | 1.086e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10542]` | 0.0003701154068 | 0.0003605343436 | 2.589e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10543]` | 0.0005759534754 | 0.0005747868215 | 2.026e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10544]` | 0.0005124586439 | 0.0005078970339 | 8.901e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10545]` | 0.0006617190865 | 0.0006616420378 | 1.164e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10546]` | 0.0004932059672 | 0.0004891518889 | 8.220e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10547]` | 0.000503406757 | 0.0005034055772 | 2.344e-06 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10548]` | 0.000437461156 | 0.0004278639754 | 2.194e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10549]` | 0.0003504123273 | 0.0003502838035 | 3.668e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10550]` | 0.001109962597 | 0.001108630263 | 1.200e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10551]` | 0.0003087254477 | 0.0003015787893 | 2.315e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10552]` | 0.0004871894455 | 0.0004815811823 | 1.151e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10553]` | 0.0006579659799 | 0.0006533988457 | 6.941e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10554]` | 0.0002135202162 | 0.0002019771139 | 5.406e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10555]` | 0.0004172125386 | 0.0004010461073 | 3.875e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10556]` | 0.0007682740056 | 0.0007647308074 | 4.612e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10557]` | 0.0006076569161 | 0.0006069575889 | 1.151e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10558]` | 0.0003932761451 | 0.0003880222526 | 1.336e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10559]` | 0.000312459726 | 0.0003021093068 | 3.313e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10560]` | 0.000227663751 | 0.000226241893 | 6.245e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10561]` | 0.000310877809 | 0.0003107970682 | 2.597e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10562]` | 0.0005583977957 | 0.0005575681295 | 1.486e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10563]` | 0.0003248231772 | 0.0003200650812 | 1.465e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10564]` | 0.0003908640293 | 0.0003901293815 | 1.880e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10565]` | 0.0007663206088 | 0.0007554682277 | 1.416e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10566]` | 0.0001321185924 | 0.0001292071161 | 2.204e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10567]` | 0.001173010284 | 0.001172568873 | 3.763e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10568]` | 0.0003267156897 | 0.0003246504412 | 6.321e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10569]` | 0.0007269071645 | 0.000719250481 | 1.053e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10570]` | 0.0006341419788 | 0.000620801354 | 2.104e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10571]` | 0.0001970176441 | 0.0001921293224 | 2.481e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10572]` | 0.0005035452333 | 0.000503335111 | 4.173e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10573]` | 0.0005467535881 | 0.0005467240497 | 5.403e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10574]` | 0.0003434215528 | 0.0003402938302 | 9.108e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10575]` | 0.0003175347903 | 0.0003149385088 | 8.176e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10576]` | 0.0007097608913 | 0.0007069365873 | 3.979e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10577]` | 0.0006608560243 | 0.0006416984401 | 2.899e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10578]` | 0.0004020990893 | 0.0003890954814 | 3.234e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10579]` | 0.0006856340577 | 0.0006765760193 | 1.321e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10580]` | 0.000269307213 | 0.0002680231166 | 4.768e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10581]` | 0.000327391826 | 0.0003241094464 | 1.003e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10582]` | 0.0007528972217 | 0.0007487260118 | 5.540e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10583]` | 0.0004962899237 | 0.0004918860665 | 8.874e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10584]` | 0.00063509329 | 0.0006338712962 | 1.924e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10585]` | 0.0005863694893 | 0.0005733011659 | 2.229e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10586]` | 0.0001724527565 | 0.0001718683844 | 3.389e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10587]` | 0.0001039005778 | 0.00010225029 | 1.588e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10588]` | 0.0003981150371 | 0.0003969330117 | 2.969e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10589]` | 0.0003243689416 | 0.0003230725296 | 3.997e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10590]` | 0.0004821839867 | 0.0004821541559 | 6.187e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10591]` | 0.0006760709862 | 0.0006673672096 | 1.287e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10592]` | 0.0001879908628 | 0.0001849740099 | 1.605e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10593]` | 0.0002574201829 | 0.0002555385991 | 7.309e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10594]` | 0.0005036585005 | 0.0004950562031 | 1.708e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10595]` | 0.0005371987712 | 0.0005357797229 | 2.642e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10596]` | 0.0003255856425 | 0.0003224898011 | 9.509e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10597]` | 0.0003898465056 | 0.0003852911563 | 1.168e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10598]` | 0.0004033861965 | 0.0003957551044 | 1.892e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10599]` | 0.0003015531611 | 0.0002947261474 | 2.264e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10600]` | 0.0004589441472 | 0.0004579656138 | 2.132e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10601]` | 0.0007331161419 | 0.0007220590886 | 1.508e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10602]` | 0.0005553648422 | 0.0005499372798 | 9.773e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10603]` | 0.0005100344649 | 0.0005071242195 | 5.706e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10604]` | 0.0007698794373 | 0.0007690085422 | 1.131e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10605]` | 0.0003657910637 | 0.000364881689 | 2.486e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10606]` | 0.0004206379858 | 0.0004203813752 | 6.101e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10607]` | 0.0006769603392 | 0.0006762185617 | 1.096e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10608]` | 0.0006835852136 | 0.0006679760609 | 2.283e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10609]` | 0.000453386037 | 0.000448188391 | 1.146e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10610]` | 0.0002463559119 | 0.0002431477595 | 1.302e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10611]` | 0.0007540968145 | 0.0007415156081 | 1.668e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10612]` | 0.0006027015818 | 0.0006003465204 | 3.908e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10613]` | 0.0004665960555 | 0.0004555988615 | 2.357e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10614]` | 0.0006844982683 | 0.0006804865328 | 5.861e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10615]` | 0.0005707905863 | 0.0005666191605 | 7.308e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10616]` | 0.0002313431221 | 0.0002275807544 | 1.626e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10617]` | 0.0003804316465 | 0.0003803949383 | 9.649e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10618]` | 0.0004911617147 | 0.0004891022992 | 4.193e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10619]` | 0.0005135025728 | 0.0005007127943 | 2.491e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10620]` | 0.0004533722776 | 0.0004517440548 | 3.591e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10621]` | 0.0006031032084 | 0.0006000269671 | 5.101e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10622]` | 0.0007107045703 | 0.0007059776517 | 6.651e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10623]` | 0.0004954371375 | 0.0004915307246 | 7.885e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10624]` | 0.0003279822147 | 0.0003208103179 | 2.187e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10625]` | 0.0001982401049 | 0.0001923893188 | 2.951e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10626]` | 0.0003997821911 | 0.000398815157 | 2.419e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10627]` | 0.0005025572499 | 0.0005018963076 | 1.315e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10628]` | 0.0001490547364 | 0.0001439332684 | 3.436e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10629]` | 0.0006709087677 | 0.0006656554805 | 7.830e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10630]` | 0.0006213125644 | 0.0006135376951 | 1.251e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10631]` | 0.0005941657377 | 0.0005935111666 | 1.102e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10632]` | 0.0004651087038 | 0.0004620100859 | 6.662e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10633]` | 0.0002681663413 | 0.0002556236883 | 4.677e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10634]` | 0.0002796045024 | 0.0002790863009 | 1.853e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10635]` | 0.0004656501038 | 0.0004652956741 | 7.612e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10636]` | 0.000505415751 | 0.0005028183378 | 5.139e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10637]` | 0.000401574598 | 0.0003997690129 | 4.496e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10638]` | 0.0005266077394 | 0.0005260695942 | 1.022e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10639]` | 0.000928888763 | 0.0009219608895 | 7.458e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10640]` | 0.0007167196343 | 0.0007166302084 | 1.248e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10641]` | 0.0006465030644 | 0.0006461424238 | 5.578e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10642]` | 0.0004762623335 | 0.0004754126196 | 1.784e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10643]` | 0.0005561039345 | 0.0005549413142 | 2.091e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10644]` | 0.0006465628962 | 0.0006317759097 | 2.287e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10645]` | 0.0002687737705 | 0.000260660506 | 3.019e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10646]` | 0.0004314083204 | 0.0004268569236 | 1.055e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10647]` | 0.0004043879674 | 0.0004011823213 | 7.927e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10648]` | 0.000407715702 | 0.0004026650805 | 1.239e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10649]` | 0.0005974074874 | 0.0005915250821 | 9.847e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10650]` | 0.0004634849238 | 0.0004561136732 | 1.590e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10651]` | 0.0003915891956 | 0.0003869522424 | 1.184e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10652]` | 0.0002821445857 | 0.0002814717278 | 2.385e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10653]` | 0.0004201986402 | 0.0004184717102 | 4.110e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10654]` | 0.0004903290188 | 0.0004891187212 | 2.468e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10655]` | 0.0004914583718 | 0.0004843208945 | 1.452e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10656]` | 0.0004782399221 | 0.0004755229177 | 5.681e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10657]` | 0.0004306905141 | 0.0004295363366 | 2.680e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10658]` | 0.0005374317614 | 0.0005313978265 | 1.123e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10659]` | 0.0002117571215 | 0.0002077050026 | 1.914e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10660]` | 0.0008190470465 | 0.0008131139181 | 7.244e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10661]` | 0.0007722881546 | 0.0007674406893 | 6.277e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10662]` | 0.0002621315972 | 0.0002614128832 | 2.742e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10663]` | 0.0002460125921 | 0.0002424678885 | 1.441e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10664]` | 0.0006471768708 | 0.0006347173839 | 1.925e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10665]` | 0.0005489470686 | 0.0005465389732 | 4.387e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10666]` | 0.0006289515583 | 0.0006282312844 | 1.145e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10667]` | 0.0006569069247 | 0.0006475325882 | 1.427e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10668]` | 0.0008691539926 | 0.0008496829141 | 2.240e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10669]` | 0.0004341233913 | 0.0004335114894 | 1.410e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10670]` | 0.000196628915 | 0.0001937907737 | 1.443e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10671]` | 0.0007907996846 | 0.0007879827484 | 3.562e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10672]` | 0.000896261022 | 0.0008934616725 | 3.123e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10673]` | 0.0004103802641 | 0.0004084869437 | 4.614e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10674]` | 0.0007031987255 | 0.0006993458838 | 5.479e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10675]` | 0.0008669189601 | 0.0008622705338 | 5.362e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10676]` | 0.0003324759308 | 0.0003235632254 | 2.681e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10677]` | 0.0003730233762 | 0.0003629094258 | 2.711e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10678]` | 0.0007156379888 | 0.0007155293347 | 1.518e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10679]` | 0.0006529116137 | 0.0006474453521 | 8.372e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10680]` | 0.0009123992331 | 0.0009051497603 | 7.946e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10681]` | 0.0004222435331 | 0.0004188736753 | 7.981e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10682]` | 0.0005628539935 | 0.0005620585376 | 1.413e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10683]` | 0.0001437060185 | 0.0001397301346 | 2.767e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10684]` | 0.0002212000253 | 0.0002087302044 | 5.637e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10685]` | 0.0008075523768 | 0.0007842014911 | 2.892e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10686]` | 0.001013205018 | 0.001003053545 | 1.002e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10687]` | 0.0004877278472 | 0.0004840572461 | 7.526e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10688]` | 0.0006642437175 | 0.0006635982779 | 9.717e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10689]` | 0.0007354280669 | 0.00073313849 | 3.113e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10690]` | 0.0005739840218 | 0.0005665101031 | 1.302e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10691]` | 0.000523344539 | 0.0005230397797 | 5.823e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10692]` | 0.0008861321991 | 0.000881303772 | 5.449e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10693]` | 0.0007178022184 | 0.0007127111628 | 7.093e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10694]` | 0.0004639518843 | 0.000463470387 | 1.038e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10695]` | 0.000562365974 | 0.0005515647705 | 1.921e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10696]` | 0.0003911029312 | 0.0003810256243 | 2.577e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10697]` | 0.0007499768261 | 0.0007433315143 | 8.861e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10698]` | 0.0004648668994 | 0.0004602880171 | 9.850e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10699]` | 0.0009294239196 | 0.0009245194613 | 5.277e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10700]` | 0.0007303821602 | 0.0007228756262 | 1.028e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10701]` | 0.0005765318203 | 0.0005719873237 | 7.882e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10702]` | 0.000619633021 | 0.0006166341981 | 4.840e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10703]` | 0.0003036087823 | 0.0003004245097 | 1.049e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10704]` | 0.0002746590637 | 0.0002745568983 | 3.720e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10705]` | 0.0002499826328 | 0.0002466804968 | 1.321e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10706]` | 0.0003786494878 | 0.0003719999226 | 1.756e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10707]` | 0.0002593763935 | 0.0002583938668 | 3.788e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10708]` | 0.0003681574323 | 0.0003667061423 | 3.942e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10709]` | 0.0005236064936 | 0.0005192355476 | 8.348e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10710]` | 0.0005154138302 | 0.0005076688635 | 1.503e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10711]` | 0.0004024655255 | 0.0003964745616 | 1.489e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10712]` | 0.0002201430259 | 0.0002130476724 | 3.223e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10713]` | 0.0005467182669 | 0.0005457430306 | 1.784e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10714]` | 0.0004278355854 | 0.0004253236833 | 5.871e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10715]` | 0.0002674539495 | 0.0002637356926 | 1.390e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10716]` | 0.0004444714728 | 0.0004441667331 | 6.856e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10717]` | 0.0006074120784 | 0.0006025324124 | 8.034e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10718]` | 0.0004580704723 | 0.0004561843219 | 4.118e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10719]` | 0.0003795814638 | 0.0003703301121 | 2.437e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10720]` | 0.0003198374622 | 0.0003073037371 | 3.919e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10721]` | 0.0008115970516 | 0.0008112617038 | 4.132e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10722]` | 0.0002813508327 | 0.0002810846754 | 9.460e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10723]` | 0.0006490572872 | 0.0006442370995 | 7.426e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10724]` | 0.0001860064733 | 0.0001813761588 | 2.489e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10725]` | 0.0004658962599 | 0.0004601276062 | 1.238e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10726]` | 0.0006629412986 | 0.0006516767864 | 1.699e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10727]` | 0.0008420982209 | 0.0008406479978 | 1.722e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10728]` | 0.0002705583048 | 0.0002677935288 | 1.022e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10729]` | 0.0005239748206 | 0.0005136583924 | 1.969e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10730]` | 0.0003390967429 | 0.0003377342781 | 4.018e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10731]` | 0.000431725223 | 0.0004302026626 | 3.527e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10732]` | 0.00102185666 | 0.001019865479 | 1.949e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10733]` | 0.0005701594988 | 0.00056715609 | 5.268e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10734]` | 0.0003978313154 | 0.0003960129632 | 4.571e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10735]` | 0.0008268108625 | 0.0008249776053 | 2.217e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10736]` | 0.0004088499338 | 0.0004060552753 | 6.835e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10737]` | 0.000469044647 | 0.0004683560109 | 1.468e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10738]` | 0.0008310964706 | 0.000825251625 | 7.033e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10739]` | 0.0007884710011 | 0.00078324183 | 6.632e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10740]` | 0.0006161250607 | 0.0006154972849 | 1.019e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10741]` | 0.0003720642033 | 0.0003691577049 | 7.812e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10742]` | 0.0005546838666 | 0.000552440821 | 4.044e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10743]` | 0.000626533764 | 0.0006252736228 | 2.011e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10744]` | 0.0008988984257 | 0.0008986762297 | 2.472e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10745]` | 0.0003434383812 | 0.0003316910081 | 3.421e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10746]` | 0.0003488868645 | 0.000344860639 | 1.154e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10747]` | 0.0005972351239 | 0.0005965822769 | 1.093e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10748]` | 0.0003206762801 | 0.0003176944496 | 9.299e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10749]` | 0.0003507262454 | 0.0003500953349 | 1.799e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10750]` | 0.0007042791114 | 0.0007018316421 | 3.475e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10751]` | 0.0002771763922 | 0.000273467092 | 1.338e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10752]` | 0.000224266616 | 0.0002186426202 | 2.508e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10753]` | 0.0008366148722 | 0.0008343023252 | 2.764e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10754]` | 0.0007328664303 | 0.0007271210905 | 7.840e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10755]` | 0.0003692080133 | 0.0003675995471 | 4.357e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10756]` | 0.0006984838305 | 0.0006936077281 | 6.981e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10757]` | 0.0005135871864 | 0.0005128249852 | 1.484e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10758]` | 0.0003565391502 | 0.0003548784991 | 4.658e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10759]` | 0.0004819570341 | 0.0004801380521 | 3.774e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10760]` | 0.0002230859773 | 0.0002224744951 | 2.741e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10761]` | 0.0006938259494 | 0.0006932731447 | 7.967e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10762]` | 0.0006167219266 | 0.0006136559804 | 4.971e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10763]` | 0.0007259112927 | 0.0007233235571 | 3.565e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10764]` | 0.0009522205927 | 0.0009497515508 | 2.593e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10765]` | 0.0005380926058 | 0.0005339881191 | 7.628e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10766]` | 0.0005206784535 | 0.0005139530762 | 1.292e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10767]` | 0.0006234363404 | 0.0006184794359 | 7.951e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10768]` | 0.001020853178 | 0.00102013328 | 7.052e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10769]` | 0.0004378837871 | 0.0004367191056 | 2.660e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10770]` | 0.0003179101424 | 0.0003130959948 | 1.514e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10771]` | 0.0004076767048 | 0.0004057856672 | 4.639e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10772]` | 0.0004629459337 | 0.0004602202785 | 5.888e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10773]` | 0.0004042004589 | 0.0003988939846 | 1.313e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10774]` | 0.0005455451068 | 0.0005418658621 | 6.744e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10775]` | 0.001005498332 | 0.001001362526 | 4.113e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10776]` | 0.0003254791262 | 0.000322618195 | 8.790e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10777]` | 0.0007012028344 | 0.0006932760778 | 1.130e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10778]` | 0.0004886916668 | 0.0004843775753 | 8.828e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10779]` | 0.0005606904876 | 0.0005590683741 | 2.893e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10780]` | 0.0002324265855 | 0.0002312012942 | 5.272e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10781]` | 0.0004814914427 | 0.0004771860318 | 8.942e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10782]` | 0.0005398841381 | 0.0005392341015 | 1.204e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10783]` | 0.0004507828567 | 0.0004502656529 | 1.147e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10784]` | 0.000693481739 | 0.0006903306145 | 4.544e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10785]` | 0.0004851204765 | 0.0004846165186 | 1.039e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10786]` | 0.0004896391804 | 0.0004878739908 | 3.605e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10787]` | 0.0005620848632 | 0.0005607434832 | 2.386e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10788]` | 0.0004959667379 | 0.0004876519523 | 1.676e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10789]` | 0.0002587009246 | 0.0002577755345 | 3.577e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10790]` | 0.0005414271429 | 0.0005394900692 | 3.578e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10791]` | 0.000432922591 | 0.0004247661885 | 1.884e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10792]` | 0.0005951638842 | 0.0005951136382 | 8.442e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10793]` | 0.0005247238515 | 0.0005215151993 | 6.115e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10794]` | 0.0002668539656 | 0.0002623136397 | 1.701e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10795]` | 0.0004445330287 | 0.0004394299818 | 1.148e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10796]` | 0.0005388641528 | 0.000538600845 | 4.886e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10797]` | 0.0003757353788 | 0.0003756457282 | 2.386e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10798]` | 0.0004716615077 | 0.0004627045591 | 1.899e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10799]` | 0.0003941648301 | 0.0003907560956 | 8.648e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10800]` | 0.0003272867968 | 0.0003255031704 | 5.450e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10801]` | 0.0002997344233 | 0.0002909659387 | 2.925e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10802]` | 0.0003414335438 | 0.0003404412471 | 2.906e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10803]` | 0.0003703517539 | 0.0003635802767 | 1.828e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10804]` | 0.0005197622224 | 0.000514763894 | 9.617e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10805]` | 0.0006532067299 | 0.0006478537748 | 8.195e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10806]` | 0.0001582869297 | 0.0001579453037 | 2.158e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10807]` | 0.0007769107164 | 0.0007726129505 | 5.532e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10808]` | 0.001005990461 | 0.001005021734 | 9.630e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10809]` | 0.0001724018948 | 0.000172068593 | 1.933e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10810]` | 0.0005285424415 | 0.0005241838081 | 8.247e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10811]` | 0.0005709375312 | 0.000569594125 | 2.353e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10812]` | 0.0006807352031 | 0.0006742638997 | 9.506e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10813]` | 0.0007738970194 | 0.0007738202437 | 9.921e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10814]` | 0.0002522067784 | 0.0002492636039 | 1.167e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10815]` | 0.0003132737693 | 0.0003095101854 | 1.201e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10816]` | 0.0006405211351 | 0.000640007034 | 8.026e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10817]` | 0.0003671627863 | 0.0003638162217 | 9.115e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10818]` | 0.000693896251 | 0.0006871923803 | 9.661e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10819]` | 0.0007506547968 | 0.0007457276391 | 6.564e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10820]` | 0.0007473906917 | 0.0007452978938 | 2.800e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10821]` | 0.0004238256371 | 0.000411432845 | 2.924e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10822]` | 0.0005931191507 | 0.000579195818 | 2.347e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10823]` | 0.0006382065599 | 0.0006323119863 | 9.236e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10824]` | 0.0006049424572 | 0.0006016950586 | 5.368e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10825]` | 0.0005405259286 | 0.0005327948044 | 1.430e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10826]` | 0.0003586698246 | 0.0003497952842 | 2.474e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10827]` | 0.0005123801027 | 0.0005095838994 | 5.457e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10828]` | 0.0003990263421 | 0.000381339176 | 4.433e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10829]` | 0.0002668208232 | 0.0002594136888 | 2.776e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10830]` | 0.0003168520482 | 0.000314786399 | 6.519e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10831]` | 0.0003633016662 | 0.0003542668278 | 2.487e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10832]` | 0.0005921177053 | 0.0005902024722 | 3.235e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10833]` | 0.0004279123375 | 0.0004231799222 | 1.106e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10834]` | 0.0003717956436 | 0.0003690259609 | 7.449e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10835]` | 0.0006202838592 | 0.0006158058656 | 7.219e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10836]` | 0.0005824322581 | 0.0005746993266 | 1.328e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10837]` | 0.0005337208052 | 0.0005292284372 | 8.417e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10838]` | 0.0004508093981 | 0.0004493848426 | 3.160e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10839]` | 0.0003860722104 | 0.0003835520142 | 6.528e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10840]` | 0.0005186167552 | 0.0005156173894 | 5.783e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10841]` | 0.0007183694369 | 0.0007153078893 | 4.262e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10842]` | 0.0005187628651 | 0.00051805976 | 1.355e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10843]` | 0.000286673206 | 0.0002845971251 | 7.242e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10844]` | 0.0007034109167 | 0.0006800553584 | 3.320e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10845]` | 0.0005774362622 | 0.0005700383705 | 1.281e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10846]` | 0.000405025981 | 0.000401290775 | 9.222e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10847]` | 0.0007973038204 | 0.0007843923421 | 1.619e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10848]` | 0.0003387159594 | 0.0003373872112 | 3.923e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10849]` | 0.0002697178576 | 0.0002622245332 | 2.778e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10850]` | 0.0001534329407 | 0.0001528027122 | 4.108e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10851]` | 0.0006132683767 | 0.0006131780909 | 1.472e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10852]` | 0.0003496361861 | 0.0003410298297 | 2.462e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10853]` | 0.0009676607084 | 0.0009506814865 | 1.755e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10854]` | 0.001076557422 | 0.001072855982 | 3.438e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10855]` | 0.0003605334867 | 0.0003553426969 | 1.440e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10856]` | 0.0004952412126 | 0.0004911302025 | 8.301e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10857]` | 0.0007282603181 | 0.0007239741356 | 5.886e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10858]` | 0.0006768285646 | 0.0006738289846 | 4.432e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10859]` | 0.0005221214424 | 0.0005117031325 | 1.995e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10860]` | 0.0004462250146 | 0.0004339661299 | 2.747e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10861]` | 0.000659025718 | 0.000657471983 | 2.358e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10862]` | 0.0003843869712 | 0.0003792642694 | 1.333e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10863]` | 0.0006921096509 | 0.000690431916 | 2.424e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10864]` | 0.0004753572496 | 0.0004685552187 | 1.431e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10865]` | 0.0006722430314 | 0.0006718691855 | 5.561e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10866]` | 0.0002819843794 | 0.0002772561098 | 1.677e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10867]` | 0.0003845778907 | 0.0003824283841 | 5.589e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10868]` | 0.0004995910056 | 0.000498023629 | 3.137e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10869]` | 0.000428564936 | 0.0004270678871 | 3.493e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10870]` | 0.0006050337557 | 0.0006016354049 | 5.617e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10871]` | 0.000533359196 | 0.0005326120716 | 1.401e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10872]` | 0.0005058395306 | 0.0004945774109 | 2.226e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10873]` | 0.0005857452278 | 0.0005802166561 | 9.439e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10874]` | 0.0005872778073 | 0.0005817204628 | 9.463e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10875]` | 0.0004667598032 | 0.0004611941787 | 1.192e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10876]` | 0.0005743668959 | 0.0005653386633 | 1.572e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10877]` | 0.0008557525863 | 0.0008507485943 | 5.847e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10878]` | 0.000514711765 | 0.0005131562019 | 3.022e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10879]` | 0.0003177005466 | 0.000317159235 | 1.704e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10880]` | 0.0005851643191 | 0.0005837340886 | 2.444e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10881]` | 0.0006179243707 | 0.0006043478526 | 2.197e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10882]` | 0.0005019872632 | 0.0004976520317 | 8.636e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10883]` | 0.000229131822 | 0.0002290258331 | 4.626e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10884]` | 0.0007963690541 | 0.0007961719208 | 2.475e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10885]` | 0.0003221254288 | 0.000321569024 | 1.727e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10886]` | 0.0004493824742 | 0.0004467950525 | 5.758e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10887]` | 0.0005340965528 | 0.0005273644585 | 1.260e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10888]` | 0.0002507379482 | 0.0002497468219 | 3.953e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10889]` | 0.0007983534818 | 0.0007969894181 | 1.709e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10890]` | 0.0002063476312 | 0.0002017100016 | 2.247e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10891]` | 0.0006385749241 | 0.00062674712 | 1.852e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10892]` | 0.0008498108777 | 0.0008419221237 | 9.283e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10893]` | 0.0004356940925 | 0.0004341307408 | 3.588e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10894]` | 0.0009328031767 | 0.000920121803 | 1.359e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10895]` | 0.000823580887 | 0.0008215173392 | 2.506e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10896]` | 0.000686570667 | 0.0006756064167 | 1.597e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10897]` | 0.000763585031 | 0.0007572956779 | 8.237e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10898]` | 0.0006219628454 | 0.0006169188709 | 8.110e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10899]` | 0.0005631809452 | 0.0005582792335 | 8.704e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10900]` | 0.0003987374604 | 0.0003903831418 | 2.095e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10901]` | 0.0006911875784 | 0.0006865257735 | 6.745e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10902]` | 0.0006481416803 | 0.0006431554967 | 7.693e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10903]` | 0.0003646530785 | 0.0003639343612 | 1.971e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10904]` | 0.0005963647863 | 0.000594138948 | 3.732e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10905]` | 0.0004399112565 | 0.0004391394688 | 1.754e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10906]` | 0.0003949638867 | 0.0003928836187 | 5.267e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10907]` | 0.0002603213878 | 0.0002580260822 | 8.817e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10908]` | 0.0007318292081 | 0.0007208463523 | 1.501e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10909]` | 0.0005224817812 | 0.0005145679182 | 1.515e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10910]` | 0.0002172245843 | 0.00021528302 | 8.938e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10911]` | 0.0009584929235 | 0.0009579742935 | 5.411e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10912]` | 0.0001489663021 | 0.0001470955727 | 1.256e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10913]` | 0.0003522493435 | 0.000349069716 | 9.027e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10914]` | 0.0006987839831 | 0.0006937348791 | 7.226e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10915]` | 0.0004181090981 | 0.0004152668063 | 6.798e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10916]` | 0.0004905514115 | 0.0004842803529 | 1.278e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10917]` | 0.0009842837109 | 0.0009791438554 | 5.222e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10918]` | 0.0005970143569 | 0.0005897813396 | 1.212e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10919]` | 0.0004360760431 | 0.0004347422025 | 3.059e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10920]` | 0.0003443351812 | 0.0003425742599 | 5.114e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10921]` | 0.0009679287062 | 0.0009661794483 | 1.807e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10922]` | 0.001093698634 | 0.001090575738 | 2.855e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10923]` | 0.0004445602302 | 0.0004392387673 | 1.197e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10924]` | 0.0003377170961 | 0.0003357998725 | 5.677e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10925]` | 0.0003800842156 | 0.0003794060548 | 1.784e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10926]` | 0.0008835275933 | 0.0008751385741 | 9.495e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10927]` | 0.0006406020453 | 0.0006405810122 | 3.283e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10928]` | 0.0004841513367 | 0.0004829373156 | 2.508e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10929]` | 0.0005356356321 | 0.0005302438869 | 1.007e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10930]` | 0.000485702283 | 0.0004814652381 | 8.724e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10931]` | 0.0007831924618 | 0.0007831826699 | 1.250e-05 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10932]` | 0.0003944814918 | 0.0003916885112 | 7.080e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10933]` | 0.001563199858 | 0.00155848344 | 3.017e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10934]` | 0.0003247663825 | 0.0003214776974 | 1.013e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10935]` | 0.0001904238215 | 0.0001861736336 | 2.232e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10936]` | 0.0007448718865 | 0.0007446217566 | 3.358e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10937]` | 0.001014038908 | 0.001011669413 | 2.337e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10938]` | 0.0003442368544 | 0.0003422166522 | 5.869e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10939]` | 0.0002408741487 | 0.0002336431786 | 3.002e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10940]` | 0.0005278473435 | 0.0005263480737 | 2.840e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10941]` | 0.0003402379592 | 0.0003391567841 | 3.178e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10942]` | 0.0008862592461 | 0.0008829813188 | 3.699e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10943]` | 0.0004368755539 | 0.0004329266058 | 9.039e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10944]` | 0.0005860083178 | 0.0005789444462 | 1.205e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10945]` | 0.0003060502557 | 0.0002926780075 | 4.369e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10946]` | 0.0003603675836 | 0.0003592517852 | 3.096e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10947]` | 0.0002669964934 | 0.0002606212621 | 2.388e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10948]` | 0.0003570628162 | 0.0003564344216 | 1.760e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10949]` | 0.0006914783569 | 0.0006780478666 | 1.942e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10950]` | 0.0006218746468 | 0.0006202320021 | 2.641e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10951]` | 0.0002136917563 | 0.0002122278049 | 6.851e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10952]` | 0.0004072350207 | 0.0003988893172 | 2.049e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10953]` | 0.0003278915972 | 0.0003259519879 | 5.915e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10954]` | 0.0003562675873 | 0.0003541768123 | 5.869e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10955]` | 0.0004718800043 | 0.0004660214686 | 1.242e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10956]` | 0.0003192620083 | 0.0003027009552 | 5.187e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10957]` | 0.0003934584206 | 0.0003914618072 | 5.075e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10958]` | 0.0007034433472 | 0.0007028094193 | 9.012e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10959]` | 0.0004410108684 | 0.0004245012926 | 3.744e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10960]` | 0.0005739486595 | 0.0005654158849 | 1.487e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10961]` | 0.000203352106 | 0.000200490619 | 1.407e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10962]` | 0.0006959219769 | 0.0006904726274 | 7.830e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10963]` | 0.0004193935604 | 0.0004147635826 | 1.104e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10964]` | 0.0005850080099 | 0.0005746828795 | 1.765e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10965]` | 0.0005044516547 | 0.000502256699 | 4.351e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10966]` | 0.000394115093 | 0.0003895549276 | 1.157e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10967]` | 0.0004849409027 | 0.0004845838771 | 7.362e-04 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10968]` | 0.0004620111714 | 0.0004613717749 | 1.384e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10969]` | 0.0004086419566 | 0.0004073109396 | 3.257e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10970]` | 0.0004468919626 | 0.0004336776677 | 2.957e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10971]` | 0.0004621591117 | 0.0004610100718 | 2.486e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10972]` | 0.0003970905737 | 0.0003963569171 | 1.848e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10973]` | 0.0005166487651 | 0.000510318519 | 1.225e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10974]` | 0.000307196971 | 0.0003062371551 | 3.124e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10975]` | 0.000379808264 | 0.0003754107795 | 1.158e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10976]` | 0.0001350086252 | 0.0001344502604 | 4.136e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10977]` | 0.0004684043001 | 0.0004672781611 | 2.404e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10978]` | 0.0004638479194 | 0.0004528677369 | 2.367e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10979]` | 0.0005616606553 | 0.0005562609947 | 9.614e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10980]` | 0.0001828989913 | 0.0001756277026 | 3.976e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10981]` | 0.0005308153297 | 0.0005193206942 | 2.165e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10982]` | 0.0003673880236 | 0.0003644590084 | 7.973e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10983]` | 0.0009557795591 | 0.0009464596198 | 9.751e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10984]` | 0.0004888448729 | 0.0004861909482 | 5.429e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10985]` | 0.0001035485893 | 0.0001028656659 | 6.595e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10986]` | 0.0005461702342 | 0.0005415339368 | 8.489e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10987]` | 0.001005097354 | 0.0009954428296 | 9.606e-03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10988]` | 0.000385727064 | 0.0003816463694 | 1.058e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_boot[10989]` | 0.0006953899695 | 0.0006920558688 | 4.795e-03 | relatif, au-delà du seuil 1e-06 |
| `ic_bootstrap["2.5%"]` | 0.04438425729 | 0.04438553872 | 2.887e-05 | relatif, au-delà du seuil 1e-06 |
| `ic_bootstrap["5%"]` | 0.04481744239 | 0.04482070147 | 7.272e-05 | relatif, au-delà du seuil 1e-06 |
| `ic_bootstrap["50%"]` | 0.04753331715 | 0.04753261053 | 1.487e-05 | relatif, au-delà du seuil 1e-06 |
| `ic_bootstrap["95%"]` | 0.05029606116 | 0.0502916293 | 8.812e-05 | relatif, au-delà du seuil 1e-06 |
| `ic_bootstrap["97.5%"]` | 0.05062466329 | 0.05061618721 | 1.674e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[1]` | 0.01976386814 | 0.01971971754 | 2.234e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[2]` | 0.02149413021 | 0.02145172303 | 1.973e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[3]` | 0.02141847544 | 0.02143360702 | 7.065e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[4]` | 0.02200821704 | 0.02198986484 | 8.339e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[5]` | 0.01886809924 | 0.0188811076 | 6.894e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[6]` | 0.01898643657 | 0.01897040438 | 8.444e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[7]` | 0.01743678829 | 0.01743696676 | 1.024e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[8]` | 0.01522671176 | 0.01522444666 | 1.488e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[9]` | 0.01361064436 | 0.01360603145 | 3.389e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[10]` | 0.01865576876 | 0.01866908315 | 7.137e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[11]` | 0.01781565448 | 0.01781878674 | 1.758e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[12]` | 0.02026106509 | 0.02026715865 | 3.008e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[13]` | 0.01459518823 | 0.01459258908 | 1.781e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[14]` | 0.01900698885 | 0.01899999561 | 3.679e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[15]` | 0.0144360959 | 0.01442039915 | 1.087e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[16]` | 0.02148163295 | 0.02147450855 | 3.317e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[17]` | 0.01901963959 | 0.01903557685 | 8.379e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[18]` | 0.02103947985 | 0.02101995913 | 9.278e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[19]` | 0.0154611064 | 0.01544511267 | 1.034e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[20]` | 0.01821014007 | 0.01823890206 | 1.579e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[21]` | 0.02220648576 | 0.0221966846 | 4.414e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[22]` | 0.01862079044 | 0.01863667156 | 8.529e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[23]` | 0.01743129061 | 0.01745051636 | 1.103e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[24]` | 0.01483330225 | 0.0148281235 | 3.491e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[25]` | 0.01969633366 | 0.01968379749 | 6.365e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[26]` | 0.01748966989 | 0.01747174528 | 1.025e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[27]` | 0.01785726814 | 0.01788606153 | 1.612e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[28]` | 0.01903459585 | 0.01904097525 | 3.351e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[29]` | 0.01888083818 | 0.01885725585 | 1.249e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[30]` | 0.01630082923 | 0.01630144854 | 3.799e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[31]` | 0.02031783101 | 0.02033639512 | 9.137e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[32]` | 0.01698828524 | 0.01700236905 | 8.290e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[33]` | 0.01715732767 | 0.01715863473 | 7.618e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[34]` | 0.02082449049 | 0.02083360525 | 4.377e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[35]` | 0.0157592862 | 0.01576736184 | 5.124e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[36]` | 0.02437887565 | 0.02438319366 | 1.771e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[37]` | 0.01366660969 | 0.01366379516 | 2.059e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[38]` | 0.01804061445 | 0.01803519109 | 3.006e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[39]` | 0.01566887759 | 0.01569803531 | 1.861e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[40]` | 0.02111426133 | 0.02115197129 | 1.786e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[41]` | 0.02115968877 | 0.02116213844 | 1.158e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[42]` | 0.01614202876 | 0.01614734543 | 3.294e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[43]` | 0.01821934661 | 0.0182468494 | 1.510e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[44]` | 0.02240264995 | 0.02238986311 | 5.708e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[45]` | 0.01848892102 | 0.01850961444 | 1.119e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[46]` | 0.0203881874 | 0.02040101689 | 6.293e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[47]` | 0.02026330603 | 0.02027956654 | 8.025e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[48]` | 0.01397959121 | 0.01398858933 | 6.437e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[49]` | 0.01841979123 | 0.01844889841 | 1.580e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[50]` | 0.01849943497 | 0.01849388644 | 2.999e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[51]` | 0.0169619064 | 0.01697046861 | 5.048e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[52]` | 0.02131921993 | 0.0212931335 | 1.224e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[53]` | 0.01930759926 | 0.01928457784 | 1.192e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[54]` | 0.01391153621 | 0.01390649646 | 3.623e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[55]` | 0.02015046557 | 0.02012020838 | 1.502e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[56]` | 0.012770882 | 0.01278809559 | 1.348e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[57]` | 0.01676538573 | 0.0167945115 | 1.737e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[58]` | 0.0198324584 | 0.01982598154 | 3.266e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[59]` | 0.0190725279 | 0.01906405663 | 4.442e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[60]` | 0.01809360577 | 0.0181026108 | 4.977e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[61]` | 0.01863005481 | 0.01864581367 | 8.459e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[62]` | 0.0141192237 | 0.0141116607 | 5.357e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[63]` | 0.01181628151 | 0.01179171657 | 2.079e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[64]` | 0.02042527318 | 0.02045178395 | 1.298e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[65]` | 0.02347450027 | 0.02346959453 | 2.090e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[66]` | 0.01674686728 | 0.01675437929 | 4.486e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[67]` | 0.0224011018 | 0.02240841068 | 3.263e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[68]` | 0.01678325478 | 0.01673962653 | 2.600e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[69]` | 0.01971682313 | 0.01971097036 | 2.968e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[70]` | 0.02230619141 | 0.02233379065 | 1.237e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[71]` | 0.01714436618 | 0.01715131684 | 4.054e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[72]` | 0.02134037866 | 0.02132394473 | 7.701e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[73]` | 0.01393853644 | 0.0139102866 | 2.027e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[74]` | 0.01518153292 | 0.01516485964 | 1.098e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[75]` | 0.01755688368 | 0.01756656465 | 5.514e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[76]` | 0.01681911699 | 0.01682800023 | 5.282e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[77]` | 0.01614987553 | 0.01615832446 | 5.232e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[78]` | 0.01738450717 | 0.01738734938 | 1.635e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[79]` | 0.01637522909 | 0.01636173826 | 8.239e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[80]` | 0.02023943541 | 0.02021896036 | 1.012e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[81]` | 0.01607950317 | 0.01608540378 | 3.670e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[82]` | 0.02126224364 | 0.02124942928 | 6.027e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[83]` | 0.01832213693 | 0.01832916719 | 3.837e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[84]` | 0.01567031939 | 0.01567843104 | 5.176e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[85]` | 0.02132078042 | 0.02134314967 | 1.049e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[86]` | 0.02026497895 | 0.02025708587 | 3.895e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[87]` | 0.02384380773 | 0.02387963457 | 1.503e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[88]` | 0.0185282207 | 0.0185117053 | 8.914e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[89]` | 0.01711215815 | 0.01711388436 | 1.009e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[90]` | 0.01589077369 | 0.01589420949 | 2.162e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[91]` | 0.01091618918 | 0.01090217648 | 1.284e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[92]` | 0.02035454037 | 0.02035634653 | 8.873e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[93]` | 0.014990412 | 0.01497419711 | 1.082e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[94]` | 0.01614350451 | 0.01613731829 | 3.832e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[95]` | 0.01478682874 | 0.01478507576 | 1.185e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[96]` | 0.0185562584 | 0.01857661672 | 1.097e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[97]` | 0.01675508718 | 0.01677652726 | 1.280e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[98]` | 0.01502366545 | 0.01500000531 | 1.575e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[99]` | 0.01855383659 | 0.01856954529 | 8.467e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[100]` | 0.01590229411 | 0.0159124612 | 6.393e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[101]` | 0.01921364789 | 0.01924448279 | 1.605e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[102]` | 0.02273490874 | 0.02275716754 | 9.791e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[103]` | 0.01661741024 | 0.01662855658 | 6.708e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[104]` | 0.01990096553 | 0.01990810465 | 3.587e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[105]` | 0.01225103715 | 0.01226011712 | 7.412e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[106]` | 0.01876129427 | 0.01876864545 | 3.918e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[107]` | 0.01884655048 | 0.01885207869 | 2.933e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[108]` | 0.02018232011 | 0.02015501086 | 1.353e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[109]` | 0.01511723878 | 0.01513094228 | 9.065e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[110]` | 0.01419558878 | 0.01419128651 | 3.031e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[111]` | 0.01419955262 | 0.01419401692 | 3.899e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[112]` | 0.01909019678 | 0.01908923316 | 5.048e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[113]` | 0.01850333305 | 0.01852626964 | 1.240e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[114]` | 0.01593524207 | 0.01592385142 | 7.148e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[115]` | 0.0234599671 | 0.02342572394 | 1.460e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[116]` | 0.01682795566 | 0.01682709351 | 5.123e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[117]` | 0.01789294561 | 0.01792591383 | 1.843e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[118]` | 0.01415071366 | 0.01413412772 | 1.172e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[119]` | 0.01972438703 | 0.01973863591 | 7.224e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[120]` | 0.02244555076 | 0.02241774491 | 1.239e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[121]` | 0.01963933866 | 0.01967265399 | 1.696e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[122]` | 0.02172628502 | 0.02173372717 | 3.425e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[123]` | 0.01904880803 | 0.01903653169 | 6.445e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[124]` | 0.02137726915 | 0.02142219282 | 2.101e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[125]` | 0.01588685097 | 0.01587576328 | 6.979e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[126]` | 0.01473384663 | 0.01472730942 | 4.437e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[127]` | 0.02031487743 | 0.0203118286 | 1.501e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[128]` | 0.02161364824 | 0.0216174789 | 1.772e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[129]` | 0.01592649024 | 0.01589146763 | 2.199e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[130]` | 0.02151260387 | 0.02152471513 | 5.630e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[131]` | 0.01980881879 | 0.01980708809 | 8.737e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[132]` | 0.01940871144 | 0.01940425425 | 2.296e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[133]` | 0.01780591955 | 0.01780251181 | 1.914e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[134]` | 0.0209191601 | 0.02096322861 | 2.107e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[135]` | 0.01604427839 | 0.0160492731 | 3.113e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[136]` | 0.01854978295 | 0.01855473157 | 2.668e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[137]` | 0.01757148215 | 0.01756224011 | 5.260e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[138]` | 0.02128150662 | 0.02129499123 | 6.336e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[139]` | 0.01927108967 | 0.01926302344 | 4.186e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[140]` | 0.02136139567 | 0.02135084521 | 4.939e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[141]` | 0.02105554556 | 0.02102385182 | 1.505e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[142]` | 0.01238611245 | 0.01237232667 | 1.113e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[143]` | 0.01841256317 | 0.01837210806 | 2.197e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[144]` | 0.02275170516 | 0.02274844979 | 1.431e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[145]` | 0.01956322936 | 0.01955739309 | 2.983e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[146]` | 0.02226081007 | 0.02222455699 | 1.629e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[147]` | 0.01984834866 | 0.01986748865 | 9.643e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[148]` | 0.01675587535 | 0.01676457693 | 5.193e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[149]` | 0.01586517357 | 0.01585896015 | 3.916e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[150]` | 0.02273040166 | 0.02274825306 | 7.854e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[151]` | 0.0243906344 | 0.02438171999 | 3.655e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[152]` | 0.02006477871 | 0.02006960515 | 2.405e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[153]` | 0.01794341466 | 0.01795182011 | 4.684e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[154]` | 0.01720372404 | 0.01719530309 | 4.895e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[155]` | 0.01579618069 | 0.01580037411 | 2.655e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[156]` | 0.01727599694 | 0.01730450447 | 1.650e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[157]` | 0.01531919564 | 0.01532519268 | 3.915e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[158]` | 0.02246683599 | 0.02245890786 | 3.529e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[159]` | 0.01739390266 | 0.01737474653 | 1.101e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[160]` | 0.01946234867 | 0.01946431198 | 1.009e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[161]` | 0.02101915194 | 0.02101255695 | 3.138e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[162]` | 0.01815220483 | 0.01814894794 | 1.794e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[163]` | 0.01648501361 | 0.01650173989 | 1.015e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[164]` | 0.01915828723 | 0.01918444938 | 1.366e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[165]` | 0.01533683385 | 0.01533793132 | 7.156e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[166]` | 0.02271236953 | 0.02269653067 | 6.974e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[167]` | 0.01568886886 | 0.01567117169 | 1.128e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[168]` | 0.01769044107 | 0.01769871341 | 4.676e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[169]` | 0.01889407026 | 0.01888842118 | 2.990e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[170]` | 0.01620200909 | 0.01618628764 | 9.703e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[171]` | 0.01735789788 | 0.01736494095 | 4.058e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[172]` | 0.01810257333 | 0.01810230456 | 1.485e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[173]` | 0.01836841046 | 0.01838411164 | 8.548e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[174]` | 0.01703558705 | 0.01703735682 | 1.039e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[175]` | 0.01578530238 | 0.01576994197 | 9.731e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[176]` | 0.01904131962 | 0.0190092739 | 1.683e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[177]` | 0.01723523065 | 0.01722997132 | 3.052e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[178]` | 0.02338657866 | 0.02337537737 | 4.790e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[179]` | 0.01351681149 | 0.01349652119 | 1.501e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[180]` | 0.01649752403 | 0.0164959344 | 9.636e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[181]` | 0.02378919394 | 0.02380074343 | 4.855e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[182]` | 0.02107450037 | 0.0210614895 | 6.174e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[183]` | 0.02031850566 | 0.0203401972 | 1.068e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[184]` | 0.01521575388 | 0.01522317039 | 4.874e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[185]` | 0.01825351188 | 0.01823098452 | 1.234e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[186]` | 0.0152058133 | 0.01519897162 | 4.499e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[187]` | 0.02079609166 | 0.02080162416 | 2.660e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[188]` | 0.01384464511 | 0.01384146496 | 2.297e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[189]` | 0.01907498519 | 0.01907748672 | 1.311e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[190]` | 0.02136659077 | 0.02140737601 | 1.909e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[191]` | 0.01973419093 | 0.01973148304 | 1.372e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[192]` | 0.01549684634 | 0.01549751699 | 4.328e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[193]` | 0.01626882346 | 0.01627401411 | 3.191e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[194]` | 0.01713876342 | 0.01711029976 | 1.661e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[195]` | 0.01635300042 | 0.01638249373 | 1.804e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[196]` | 0.01871147938 | 0.0186771041 | 1.837e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[197]` | 0.02328891134 | 0.023272899 | 6.876e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[198]` | 0.02128101662 | 0.02130995253 | 1.360e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[199]` | 0.01500244963 | 0.01502199462 | 1.303e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[200]` | 0.01241788936 | 0.01241536301 | 2.034e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[201]` | 0.0232616408 | 0.02324729212 | 6.168e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[202]` | 0.01863548946 | 0.01864862712 | 7.050e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[203]` | 0.01649911352 | 0.01652773833 | 1.735e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[204]` | 0.02254631888 | 0.02257286402 | 1.177e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[205]` | 0.01547748125 | 0.01545605788 | 1.384e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[206]` | 0.01847627617 | 0.01848342405 | 3.869e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[207]` | 0.01854994086 | 0.01854886466 | 5.802e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[208]` | 0.02295130923 | 0.02296246741 | 4.862e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[209]` | 0.01470033457 | 0.01469158335 | 5.953e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[210]` | 0.01972627207 | 0.01971071945 | 7.884e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[211]` | 0.01905031711 | 0.01908250309 | 1.690e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[212]` | 0.01917652055 | 0.01917240251 | 2.147e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[213]` | 0.01374475181 | 0.01373250373 | 8.911e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[214]` | 0.01973812485 | 0.01972135593 | 8.496e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[215]` | 0.01870690811 | 0.01869309675 | 7.383e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[216]` | 0.01511196471 | 0.01512151563 | 6.320e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[217]` | 0.0164137864 | 0.01642292501 | 5.568e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[218]` | 0.0200542817 | 0.02000859018 | 2.278e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[219]` | 0.01653892128 | 0.01650861071 | 1.833e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[220]` | 0.02327164834 | 0.02325694846 | 6.317e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[221]` | 0.01843577735 | 0.01843034637 | 2.946e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[222]` | 0.01746963482 | 0.017443896 | 1.473e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[223]` | 0.02042203307 | 0.02037855847 | 2.129e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[224]` | 0.01916694325 | 0.01918795454 | 1.096e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[225]` | 0.01464862748 | 0.01465202016 | 2.316e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[226]` | 0.01391431772 | 0.01391363413 | 4.913e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[227]` | 0.01210213146 | 0.01212263533 | 1.694e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[228]` | 0.01411678576 | 0.01413587228 | 1.352e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[229]` | 0.0144838722 | 0.01448057615 | 2.276e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[230]` | 0.01626107877 | 0.01625471579 | 3.913e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[231]` | 0.01802257144 | 0.01799433271 | 1.567e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[232]` | 0.02086644922 | 0.02085666216 | 4.690e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[233]` | 0.01782103009 | 0.01784655941 | 1.433e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[234]` | 0.01926240364 | 0.01928684771 | 1.269e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[235]` | 0.02286188324 | 0.0228960487 | 1.494e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[236]` | 0.01614213476 | 0.01611234414 | 1.846e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[237]` | 0.02191731679 | 0.02195718603 | 1.819e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[238]` | 0.01651431073 | 0.01653669504 | 1.355e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[239]` | 0.01234339969 | 0.01233948115 | 3.175e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[240]` | 0.01734492436 | 0.01733814122 | 3.911e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[241]` | 0.018313663 | 0.01831772261 | 2.217e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[242]` | 0.01065341084 | 0.01066015492 | 6.330e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[243]` | 0.02088063414 | 0.02087495907 | 2.718e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[244]` | 0.01268316953 | 0.01269505178 | 9.369e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[245]` | 0.01514132276 | 0.01514186978 | 3.613e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[246]` | 0.01701063006 | 0.01703061158 | 1.175e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[247]` | 0.01969551207 | 0.01969532023 | 9.740e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[248]` | 0.0185066446 | 0.01850960063 | 1.597e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[249]` | 0.01573313698 | 0.01572977413 | 2.137e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[250]` | 0.01814044252 | 0.01813974076 | 3.869e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[251]` | 0.01318707977 | 0.01317415097 | 9.804e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[252]` | 0.01778769857 | 0.01776930251 | 1.034e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[253]` | 0.01840378743 | 0.0184039522 | 8.953e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[254]` | 0.02040285111 | 0.02039951397 | 1.636e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[255]` | 0.01482895292 | 0.0148328228 | 2.610e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[256]` | 0.01927793512 | 0.0192704446 | 3.886e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[257]` | 0.01780310256 | 0.01780536311 | 1.270e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[258]` | 0.01709449333 | 0.01708760116 | 4.032e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[259]` | 0.02319848969 | 0.0231867705 | 5.052e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[260]` | 0.0180302638 | 0.0180478281 | 9.742e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[261]` | 0.01589941626 | 0.01588061467 | 1.183e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[262]` | 0.02055479197 | 0.02054219078 | 6.131e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[263]` | 0.01888009676 | 0.01888789663 | 4.131e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[264]` | 0.02127132196 | 0.02128916259 | 8.387e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[265]` | 0.01845774197 | 0.01843185594 | 1.402e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[266]` | 0.02168983018 | 0.02168858961 | 5.720e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[267]` | 0.0191937958 | 0.01918828674 | 2.870e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[268]` | 0.01819360534 | 0.0182127761 | 1.054e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[269]` | 0.02053524832 | 0.02050813491 | 1.320e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[270]` | 0.01920713449 | 0.01917933941 | 1.447e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[271]` | 0.01388414988 | 0.01387739508 | 4.865e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[272]` | 0.02078378654 | 0.02077198965 | 5.676e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[273]` | 0.01555325576 | 0.01556968249 | 1.056e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[274]` | 0.0199845083 | 0.0199812663 | 1.622e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[275]` | 0.01298668646 | 0.01298932295 | 2.030e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[276]` | 0.02378504921 | 0.02376451057 | 8.635e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[277]` | 0.0202680397 | 0.02026244975 | 2.758e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[278]` | 0.01735013896 | 0.01733999758 | 5.845e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[279]` | 0.01683083645 | 0.01684504104 | 8.440e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[280]` | 0.01868458512 | 0.01869282371 | 4.409e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[281]` | 0.01894280174 | 0.01895496668 | 6.422e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[282]` | 0.01877547782 | 0.01875267007 | 1.215e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[283]` | 0.01804448033 | 0.01804244904 | 1.126e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[284]` | 0.01694664541 | 0.01696798799 | 1.259e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[285]` | 0.01796652198 | 0.01795104384 | 8.615e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[286]` | 0.01871965877 | 0.01875553076 | 1.916e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[287]` | 0.01727317907 | 0.01726344136 | 5.637e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[288]` | 0.02022994984 | 0.02022926583 | 3.381e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[289]` | 0.01447255256 | 0.01447816913 | 3.881e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[290]` | 0.02080329059 | 0.02080398158 | 3.322e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[291]` | 0.01999979571 | 0.02002612861 | 1.317e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[292]` | 0.01397995076 | 0.01397121072 | 6.252e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[293]` | 0.02082549745 | 0.02083635363 | 5.213e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[294]` | 0.01996876559 | 0.01998362597 | 7.442e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[295]` | 0.01906723494 | 0.01909322188 | 1.363e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[296]` | 0.01706998129 | 0.01706401783 | 3.494e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[297]` | 0.01919525048 | 0.01918568574 | 4.983e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[298]` | 0.01788223515 | 0.01790341838 | 1.185e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[299]` | 0.0173291195 | 0.01731293879 | 9.337e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[300]` | 0.01929996518 | 0.01927328884 | 1.382e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[301]` | 0.01878353746 | 0.01878153093 | 1.068e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[302]` | 0.01560230465 | 0.01561123482 | 5.724e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[303]` | 0.01845658456 | 0.01846132098 | 2.566e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[304]` | 0.02110794046 | 0.02108151814 | 1.252e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[305]` | 0.0179040233 | 0.01789370119 | 5.765e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[306]` | 0.01746308155 | 0.01746702658 | 2.259e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[307]` | 0.01297322337 | 0.01298883464 | 1.203e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[308]` | 0.01611484406 | 0.01612851096 | 8.481e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[309]` | 0.01144906513 | 0.01145202455 | 2.585e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[310]` | 0.01710861532 | 0.01713252768 | 1.398e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[311]` | 0.01809185356 | 0.01807466596 | 9.500e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[312]` | 0.01875712096 | 0.01873642945 | 1.103e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[313]` | 0.01846967599 | 0.0184412152 | 1.541e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[314]` | 0.01810454806 | 0.0181202156 | 8.654e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[315]` | 0.01799548597 | 0.01799716259 | 9.317e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[316]` | 0.01652460088 | 0.01652096989 | 2.197e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[317]` | 0.01869818778 | 0.01868163438 | 8.853e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[318]` | 0.01445483546 | 0.01442794364 | 1.860e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[319]` | 0.01987272687 | 0.01987710753 | 2.204e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[320]` | 0.01778014726 | 0.01776594478 | 7.988e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[321]` | 0.01869036269 | 0.01868049902 | 5.277e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[322]` | 0.01651938509 | 0.01652778827 | 5.087e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[323]` | 0.01739154227 | 0.01739605251 | 2.593e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[324]` | 0.01469529844 | 0.01470300839 | 5.247e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[325]` | 0.01728338602 | 0.01731162322 | 1.634e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[326]` | 0.0201731121 | 0.02016595186 | 3.549e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[327]` | 0.01429909575 | 0.01430238028 | 2.297e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[328]` | 0.01416078015 | 0.01416488581 | 2.899e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[329]` | 0.01224716143 | 0.01223310303 | 1.148e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[330]` | 0.02100544398 | 0.0210053005 | 6.831e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[331]` | 0.01828565826 | 0.01826732893 | 1.002e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[332]` | 0.01282338785 | 0.01283335489 | 7.773e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[333]` | 0.01696525925 | 0.01696322736 | 1.198e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[334]` | 0.02225929347 | 0.0222982553 | 1.750e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[335]` | 0.01529862073 | 0.01530325168 | 3.027e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[336]` | 0.01385440326 | 0.01386411982 | 7.013e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[337]` | 0.01762054563 | 0.0176261702 | 3.192e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[338]` | 0.01488026547 | 0.01486780853 | 8.371e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[339]` | 0.0213982826 | 0.02139903142 | 3.499e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[340]` | 0.01961819171 | 0.0195771471 | 2.092e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[341]` | 0.01105989282 | 0.01105318032 | 6.069e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[342]` | 0.0181489554 | 0.01815706855 | 4.470e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[343]` | 0.01096277114 | 0.01097529772 | 1.143e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[344]` | 0.02163978435 | 0.0216737419 | 1.569e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[345]` | 0.02093047314 | 0.02092568735 | 2.287e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[346]` | 0.02140894192 | 0.0214170671 | 3.795e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[347]` | 0.02013231861 | 0.02015447266 | 1.100e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[348]` | 0.01963956454 | 0.01961567439 | 1.216e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[349]` | 0.01994811569 | 0.01992982067 | 9.171e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[350]` | 0.0192223789 | 0.01923402854 | 6.060e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[351]` | 0.0170610129 | 0.01705648443 | 2.654e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[352]` | 0.01490608847 | 0.01493185639 | 1.729e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[353]` | 0.02453768058 | 0.02453452875 | 1.284e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[354]` | 0.02279698271 | 0.02280996064 | 5.693e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[355]` | 0.01571311304 | 0.01571934492 | 3.966e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[356]` | 0.01455128694 | 0.01453798787 | 9.139e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[357]` | 0.02093919712 | 0.0209102304 | 1.383e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[358]` | 0.01330534442 | 0.01330448237 | 6.479e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[359]` | 0.01531567792 | 0.01531429962 | 8.999e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[360]` | 0.01774249237 | 0.01773995989 | 1.427e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[361]` | 0.01737579673 | 0.01738735647 | 6.653e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[362]` | 0.01867479501 | 0.01868912806 | 7.675e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[363]` | 0.01560010552 | 0.01559059827 | 6.094e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[364]` | 0.01543240255 | 0.01542334608 | 5.868e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[365]` | 0.01291108393 | 0.01290608149 | 3.875e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[366]` | 0.02069149837 | 0.0206629094 | 1.382e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[367]` | 0.01588857801 | 0.0158760897 | 7.860e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[368]` | 0.02121464029 | 0.02117535615 | 1.852e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[369]` | 0.01843718355 | 0.01842890766 | 4.489e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[370]` | 0.0157891595 | 0.01579337577 | 2.670e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[371]` | 0.01569977923 | 0.01569651197 | 2.081e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[372]` | 0.01801026504 | 0.01799167453 | 1.032e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[373]` | 0.02106273705 | 0.02106249657 | 1.142e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[374]` | 0.01853591895 | 0.01853926505 | 1.805e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[375]` | 0.01786638367 | 0.01783625884 | 1.686e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[376]` | 0.01706676677 | 0.01707236357 | 3.279e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[377]` | 0.0166101427 | 0.01660821581 | 1.160e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[378]` | 0.0160314375 | 0.01604317521 | 7.322e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[379]` | 0.01751266919 | 0.01752975275 | 9.755e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[380]` | 0.01731782524 | 0.01731898393 | 6.691e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[381]` | 0.01768425444 | 0.01769735047 | 7.405e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[382]` | 0.01316303395 | 0.01317471607 | 8.875e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[383]` | 0.01580603 | 0.01579977439 | 3.958e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[384]` | 0.01112541732 | 0.01113842795 | 1.169e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[385]` | 0.01648089587 | 0.01646889022 | 7.285e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[386]` | 0.01597915998 | 0.0159760447 | 1.950e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[387]` | 0.01707882536 | 0.01708270423 | 2.271e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[388]` | 0.01836351295 | 0.01837658037 | 7.116e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[389]` | 0.02042092219 | 0.02039853282 | 1.096e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[390]` | 0.01704320256 | 0.01704286421 | 1.985e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[391]` | 0.02295805089 | 0.02292140268 | 1.596e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[392]` | 0.01514129144 | 0.01515307337 | 7.781e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[393]` | 0.02143255137 | 0.02146788719 | 1.649e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[394]` | 0.02041054584 | 0.02039700969 | 6.632e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[395]` | 0.0191730526 | 0.01919387291 | 1.086e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[396]` | 0.01698565656 | 0.01698980231 | 2.441e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[397]` | 0.01717776806 | 0.0171617843 | 9.305e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[398]` | 0.01524556868 | 0.01522372131 | 1.433e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[399]` | 0.01360979783 | 0.01360601877 | 2.777e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[400]` | 0.01641327901 | 0.01643965444 | 1.607e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[401]` | 0.01898818012 | 0.01896282476 | 1.335e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[402]` | 0.01552357503 | 0.01552112614 | 1.578e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[403]` | 0.02260094298 | 0.02263662924 | 1.579e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[404]` | 0.02048132382 | 0.02048996211 | 4.218e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[405]` | 0.01310337007 | 0.01309401518 | 7.139e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[406]` | 0.02290117314 | 0.02286351238 | 1.644e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[407]` | 0.01800590853 | 0.01801294145 | 3.906e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[408]` | 0.01921793846 | 0.01923560594 | 9.193e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[409]` | 0.01411733046 | 0.01411546966 | 1.318e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[410]` | 0.01904911834 | 0.01904693022 | 1.149e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[411]` | 0.01969264821 | 0.01967196775 | 1.050e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[412]` | 0.01817051864 | 0.0181831889 | 6.973e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[413]` | 0.01737164973 | 0.01738475198 | 7.542e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[414]` | 0.01930978108 | 0.01931262968 | 1.475e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[415]` | 0.01716422509 | 0.0171473948 | 9.805e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[416]` | 0.01699836265 | 0.01699450346 | 2.270e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[417]` | 0.01809820819 | 0.01809747716 | 4.039e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[418]` | 0.01940161406 | 0.01941890007 | 8.910e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[419]` | 0.01933768414 | 0.01935646728 | 9.713e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[420]` | 0.01458113406 | 0.01459819239 | 1.170e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[421]` | 0.02119573568 | 0.0212153789 | 9.268e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[422]` | 0.0190397265 | 0.01904590921 | 3.247e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[423]` | 0.01529108496 | 0.01529866409 | 4.957e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[424]` | 0.02397073967 | 0.02395565285 | 6.294e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[425]` | 0.02031831155 | 0.02032383998 | 2.721e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[426]` | 0.02288061985 | 0.02290221413 | 9.438e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[427]` | 0.01320117327 | 0.01320903213 | 5.953e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[428]` | 0.01442456247 | 0.01443708149 | 8.679e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[429]` | 0.01998456081 | 0.01999123591 | 3.340e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[430]` | 0.01762718557 | 0.01764018374 | 7.374e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[431]` | 0.02313105241 | 0.02313529784 | 1.835e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[432]` | 0.02186845362 | 0.0219113834 | 1.963e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[433]` | 0.02318760008 | 0.02316305229 | 1.059e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[434]` | 0.0211886352 | 0.02119679996 | 3.853e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[435]` | 0.02022297022 | 0.02023383175 | 5.371e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[436]` | 0.01688461154 | 0.01688334731 | 7.487e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[437]` | 0.01692038517 | 0.01692555294 | 3.054e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[438]` | 0.02332617517 | 0.02328033446 | 1.965e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[439]` | 0.01270687958 | 0.01268755804 | 1.521e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[440]` | 0.01825265166 | 0.01823340287 | 1.055e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[441]` | 0.01502584837 | 0.01502070663 | 3.422e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[442]` | 0.01208338558 | 0.01209640262 | 1.077e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[443]` | 0.01692009857 | 0.01691937777 | 4.260e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[444]` | 0.01943398921 | 0.01942738843 | 3.397e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[445]` | 0.01870017891 | 0.01870509149 | 2.627e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[446]` | 0.01770999177 | 0.01770280962 | 4.055e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[447]` | 0.01732928535 | 0.01734592957 | 9.605e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[448]` | 0.01135620812 | 0.01135659937 | 3.445e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[449]` | 0.01390418907 | 0.01387764042 | 1.909e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[450]` | 0.01729548723 | 0.01727670306 | 1.086e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[451]` | 0.01889493452 | 0.01889118403 | 1.985e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[452]` | 0.01689870058 | 0.01686399769 | 2.054e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[453]` | 0.02088854419 | 0.02085644043 | 1.537e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[454]` | 0.01931864957 | 0.01931261222 | 3.125e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[455]` | 0.01641563865 | 0.01642443323 | 5.357e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[456]` | 0.01456681127 | 0.01458334862 | 1.135e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[457]` | 0.01406823933 | 0.01404779475 | 1.453e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[458]` | 0.02175620063 | 0.02175380115 | 1.103e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[459]` | 0.01707085913 | 0.01708518464 | 8.392e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[460]` | 0.01854113433 | 0.01855025505 | 4.919e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[461]` | 0.01723701025 | 0.01725991396 | 1.329e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[462]` | 0.02014986655 | 0.02015092689 | 5.262e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[463]` | 0.01698446989 | 0.01698077308 | 2.177e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[464]` | 0.01184275064 | 0.0118328098 | 8.394e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[465]` | 0.02096381333 | 0.02096104137 | 1.322e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[466]` | 0.0213280717 | 0.02130924333 | 8.828e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[467]` | 0.01803866112 | 0.01804416071 | 3.049e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[468]` | 0.01805995157 | 0.01805934738 | 3.345e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[469]` | 0.01785893798 | 0.01787378778 | 8.315e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[470]` | 0.01632432107 | 0.01631459194 | 5.960e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[471]` | 0.02232228621 | 0.02231546369 | 3.056e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[472]` | 0.01882855656 | 0.01880849192 | 1.066e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[473]` | 0.02146157476 | 0.02147329232 | 5.460e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[474]` | 0.01709159912 | 0.0170885086 | 1.808e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[475]` | 0.01961905085 | 0.01963313373 | 7.178e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[476]` | 0.01817692169 | 0.01817680377 | 6.487e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[477]` | 0.01779966362 | 0.0177820881 | 9.874e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[478]` | 0.01964041605 | 0.01963401951 | 3.257e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[479]` | 0.02145788557 | 0.02144696275 | 5.090e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[480]` | 0.02094750374 | 0.02096842529 | 9.988e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[481]` | 0.01495080622 | 0.01494991858 | 5.937e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[482]` | 0.02096477565 | 0.02093032498 | 1.643e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[483]` | 0.01638778658 | 0.01639239536 | 2.812e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[484]` | 0.02090019157 | 0.02088551243 | 7.023e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[485]` | 0.01769332885 | 0.01768570368 | 4.310e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[486]` | 0.01632077647 | 0.01630603098 | 9.035e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[487]` | 0.01669176624 | 0.01668476524 | 4.194e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[488]` | 0.02094059988 | 0.02095400048 | 6.399e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[489]` | 0.02171795376 | 0.02173570722 | 8.175e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[490]` | 0.02208268921 | 0.02208902708 | 2.870e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[491]` | 0.0177250806 | 0.01772129816 | 2.134e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[492]` | 0.01853127317 | 0.01855118024 | 1.074e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[493]` | 0.01361900327 | 0.01362782194 | 6.475e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[494]` | 0.01796237286 | 0.0179707575 | 4.668e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[495]` | 0.01658622634 | 0.01659600979 | 5.899e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[496]` | 0.01686112889 | 0.01685161987 | 5.640e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[497]` | 0.01584527742 | 0.01583859151 | 4.219e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[498]` | 0.01694326317 | 0.01692652821 | 9.877e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[499]` | 0.01454799229 | 0.01453392219 | 9.672e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[500]` | 0.0241721119 | 0.02416055225 | 4.782e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[501]` | 0.02143040698 | 0.02146014789 | 1.388e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[502]` | 0.01884098026 | 0.0188320676 | 4.730e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[503]` | 0.01904610752 | 0.01904849831 | 1.255e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[504]` | 0.01394117505 | 0.0139419964 | 5.892e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[505]` | 0.01670965385 | 0.01671902038 | 5.605e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[506]` | 0.0144719365 | 0.01445634042 | 1.078e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[507]` | 0.02011955031 | 0.02013382892 | 7.097e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[508]` | 0.01733080975 | 0.01732063081 | 5.873e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[509]` | 0.01897273574 | 0.01896937747 | 1.770e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[510]` | 0.01925893578 | 0.01924586402 | 6.787e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[511]` | 0.01716087396 | 0.01719011687 | 1.704e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[512]` | 0.01321698898 | 0.01323142508 | 1.092e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[513]` | 0.0214425934 | 0.02144745 | 2.265e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[514]` | 0.01859240787 | 0.01858424059 | 4.393e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[515]` | 0.0160065744 | 0.0159977121 | 5.537e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[516]` | 0.02027572185 | 0.02030567804 | 1.477e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[517]` | 0.01635973949 | 0.01632811814 | 1.933e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[518]` | 0.0134875458 | 0.01349067747 | 2.322e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[519]` | 0.01573240658 | 0.01574739555 | 9.527e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[520]` | 0.01886316425 | 0.01886875403 | 2.963e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[521]` | 0.01907481827 | 0.01907690585 | 1.094e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[522]` | 0.01915798214 | 0.01915166232 | 3.299e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[523]` | 0.01535220181 | 0.01534673791 | 3.559e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[524]` | 0.01862183384 | 0.01863740226 | 8.360e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[525]` | 0.01718009032 | 0.01719338678 | 7.739e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[526]` | 0.01966031343 | 0.01963944537 | 1.061e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[527]` | 0.01795607221 | 0.01793048774 | 1.425e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[528]` | 0.01697540759 | 0.01699294799 | 1.033e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[529]` | 0.01974493202 | 0.01972024328 | 1.250e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[530]` | 0.01952155298 | 0.01952285387 | 6.664e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[531]` | 0.01975210653 | 0.0197365736 | 7.864e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[532]` | 0.01985013137 | 0.01984122841 | 4.485e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[533]` | 0.01708562811 | 0.01710020728 | 8.533e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[534]` | 0.02089049939 | 0.02088060299 | 4.737e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[535]` | 0.01583521582 | 0.01586147634 | 1.658e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[536]` | 0.01856347227 | 0.01854954554 | 7.502e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[537]` | 0.01851606345 | 0.0185016713 | 7.773e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[538]` | 0.01699416375 | 0.01701564759 | 1.264e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[539]` | 0.0182950642 | 0.01831399739 | 1.035e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[540]` | 0.01696772166 | 0.01697882127 | 6.542e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[541]` | 0.01971639685 | 0.01968392958 | 1.647e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[542]` | 0.01927869613 | 0.01928582337 | 3.697e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[543]` | 0.017589308 | 0.01759606458 | 3.841e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[544]` | 0.0134688415 | 0.01347517993 | 4.706e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[545]` | 0.01617807713 | 0.01616772424 | 6.399e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[546]` | 0.01987053187 | 0.01988869346 | 9.140e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[547]` | 0.01851235992 | 0.0185399834 | 1.492e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[548]` | 0.01400274674 | 0.01401632914 | 9.700e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[549]` | 0.01627491321 | 0.01627690034 | 1.221e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[550]` | 0.01565080406 | 0.01563000218 | 1.329e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[551]` | 0.01442341923 | 0.01440953077 | 9.629e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[552]` | 0.01626891212 | 0.01625927373 | 5.924e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[553]` | 0.01849529922 | 0.01851410637 | 1.017e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[554]` | 0.02218889863 | 0.0222195981 | 1.384e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[555]` | 0.02012514589 | 0.02012051288 | 2.302e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[556]` | 0.01297479736 | 0.01298919368 | 1.110e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[557]` | 0.01623212921 | 0.01625379841 | 1.335e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[558]` | 0.02175224264 | 0.02174149542 | 4.941e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[559]` | 0.02024303502 | 0.02027436728 | 1.548e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[560]` | 0.01891654153 | 0.01890166701 | 7.863e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[561]` | 0.01519069077 | 0.01517975594 | 7.198e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[562]` | 0.02365533986 | 0.02363277986 | 9.537e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[563]` | 0.02015710801 | 0.02017963303 | 1.117e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[564]` | 0.01916562197 | 0.01916864063 | 1.575e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[565]` | 0.01856070025 | 0.01855021853 | 5.647e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[566]` | 0.02015754822 | 0.02013072777 | 1.331e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[567]` | 0.01597855479 | 0.01596562765 | 8.090e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[568]` | 0.01791404439 | 0.01791376812 | 1.542e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[569]` | 0.01520357533 | 0.01519028753 | 8.740e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[570]` | 0.01557203192 | 0.01556367732 | 5.365e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[571]` | 0.02062877965 | 0.02062687791 | 9.219e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[572]` | 0.02012359037 | 0.02009855142 | 1.244e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[573]` | 0.01139390446 | 0.01139557865 | 1.469e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[574]` | 0.02032667813 | 0.02036256121 | 1.765e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[575]` | 0.01843161888 | 0.01843375214 | 1.157e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[576]` | 0.01265684225 | 0.0126545079 | 1.844e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[577]` | 0.0174493645 | 0.01746811694 | 1.075e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[578]` | 0.01533611342 | 0.01535937718 | 1.517e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[579]` | 0.01484266173 | 0.01484527713 | 1.762e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[580]` | 0.01687301798 | 0.01686396272 | 5.367e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[581]` | 0.01706208612 | 0.01704767775 | 8.445e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[582]` | 0.01790034726 | 0.01792515539 | 1.386e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[583]` | 0.02266730322 | 0.02269446261 | 1.198e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[584]` | 0.0128472757 | 0.01285693095 | 7.515e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[585]` | 0.01581230568 | 0.01581936053 | 4.462e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[586]` | 0.01785506989 | 0.01786496398 | 5.541e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[587]` | 0.02105976635 | 0.02104443613 | 7.279e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[588]` | 0.01583176223 | 0.01583566092 | 2.463e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[589]` | 0.02247124877 | 0.02245813338 | 5.837e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[590]` | 0.01349624471 | 0.01351317024 | 1.254e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[591]` | 0.01733325233 | 0.01733263601 | 3.556e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[592]` | 0.01962478782 | 0.01961146676 | 6.788e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[593]` | 0.01776044779 | 0.01776624457 | 3.264e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[594]` | 0.01993764586 | 0.01989956998 | 1.910e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[595]` | 0.01613914992 | 0.01614012149 | 6.020e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[596]` | 0.01339161009 | 0.0133936131 | 1.496e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[597]` | 0.01913046548 | 0.01912362235 | 3.577e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[598]` | 0.01354969399 | 0.01353177972 | 1.322e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[599]` | 0.02281395596 | 0.02279093282 | 1.009e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[600]` | 0.01904718899 | 0.01907332871 | 1.372e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[601]` | 0.01809143356 | 0.01809158742 | 8.505e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[602]` | 0.01573890456 | 0.01573980523 | 5.723e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[603]` | 0.02038347904 | 0.02035271345 | 1.509e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[604]` | 0.01754562657 | 0.0175336084 | 6.850e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[605]` | 0.01621637924 | 0.0162016291 | 9.096e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[606]` | 0.02157816568 | 0.02154244847 | 1.655e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[607]` | 0.01462358256 | 0.01462024611 | 2.282e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[608]` | 0.02143284679 | 0.02145398619 | 9.863e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[609]` | 0.01550478261 | 0.01550680672 | 1.305e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[610]` | 0.01773170483 | 0.01776458349 | 1.854e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[611]` | 0.01720514025 | 0.01721214497 | 4.071e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[612]` | 0.02186454691 | 0.02189406371 | 1.350e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[613]` | 0.01514640986 | 0.01514315114 | 2.151e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[614]` | 0.01788653507 | 0.01791055201 | 1.343e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[615]` | 0.01564445251 | 0.01560742399 | 2.367e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[616]` | 0.02067064076 | 0.02067613044 | 2.656e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[617]` | 0.02055811299 | 0.02052113135 | 1.799e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[618]` | 0.0216961256 | 0.02170552335 | 4.332e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[619]` | 0.01868421 | 0.01868123557 | 1.592e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[620]` | 0.02051976651 | 0.02054252427 | 1.109e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[621]` | 0.02269883105 | 0.02270799172 | 4.036e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[622]` | 0.01911031203 | 0.01912704613 | 8.757e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[623]` | 0.01732095181 | 0.01732622369 | 3.044e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[624]` | 0.01819816952 | 0.01818465535 | 7.426e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[625]` | 0.0182904126 | 0.01828713171 | 1.794e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[626]` | 0.01432209227 | 0.01432995482 | 5.490e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[627]` | 0.0141905027 | 0.01418868349 | 1.282e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[628]` | 0.02021405055 | 0.02018262018 | 1.555e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[629]` | 0.01315805229 | 0.01315245184 | 4.256e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[630]` | 0.0184559266 | 0.01848692467 | 1.680e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[631]` | 0.0158158345 | 0.01580849722 | 4.639e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[632]` | 0.02430003189 | 0.02429703634 | 1.233e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[633]` | 0.01571948458 | 0.0157195791 | 6.013e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[634]` | 0.01312710267 | 0.01312979364 | 2.050e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[635]` | 0.01589634209 | 0.01587060734 | 1.619e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[636]` | 0.01622105591 | 0.01623430642 | 8.169e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[637]` | 0.02526507136 | 0.02520388993 | 2.422e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[638]` | 0.01960483296 | 0.01957953013 | 1.291e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[639]` | 0.01628089385 | 0.01629138242 | 6.442e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[640]` | 0.01712400467 | 0.01711427258 | 5.683e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[641]` | 0.02016113654 | 0.02015623099 | 2.433e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[642]` | 0.02195600332 | 0.02199380509 | 1.722e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[643]` | 0.02032696525 | 0.02034103358 | 6.921e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[644]` | 0.01548923185 | 0.01547578736 | 8.680e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[645]` | 0.01622745679 | 0.01623585884 | 5.178e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[646]` | 0.01935886586 | 0.01939427544 | 1.829e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[647]` | 0.01527295106 | 0.01529449917 | 1.411e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[648]` | 0.01712348567 | 0.01709012127 | 1.948e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[649]` | 0.0203606539 | 0.02035938992 | 6.208e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[650]` | 0.01852130416 | 0.01852302562 | 9.294e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[651]` | 0.02315432079 | 0.02319463987 | 1.741e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[652]` | 0.01935954853 | 0.01935396357 | 2.885e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[653]` | 0.0151051435 | 0.01510490996 | 1.546e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[654]` | 0.01645976084 | 0.01646753377 | 4.722e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[655]` | 0.0222909347 | 0.02230012962 | 4.125e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[656]` | 0.01810743905 | 0.01812158246 | 7.811e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[657]` | 0.01450381639 | 0.01449310726 | 7.384e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[658]` | 0.01807401157 | 0.01807445931 | 2.477e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[659]` | 0.01780564468 | 0.01782471915 | 1.071e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[660]` | 0.01787472363 | 0.01786771959 | 3.918e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[661]` | 0.01243621208 | 0.01243231727 | 3.132e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[662]` | 0.01814072349 | 0.01815347988 | 7.032e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[663]` | 0.01714490021 | 0.017152096 | 4.197e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[664]` | 0.01603895292 | 0.01604104638 | 1.305e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[665]` | 0.01722655107 | 0.01721396645 | 7.305e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[666]` | 0.01766747217 | 0.01765428983 | 7.461e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[667]` | 0.01712598366 | 0.01713413258 | 4.758e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[668]` | 0.01778155323 | 0.01778312817 | 8.857e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[669]` | 0.01427624623 | 0.01427810761 | 1.304e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[670]` | 0.01605858125 | 0.01603709912 | 1.338e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[671]` | 0.02298807823 | 0.02301747422 | 1.279e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[672]` | 0.01628874205 | 0.01625060198 | 2.341e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[673]` | 0.01780992187 | 0.01777960294 | 1.702e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[674]` | 0.01749357032 | 0.01751124872 | 1.011e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[675]` | 0.02179628137 | 0.02176938785 | 1.234e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[676]` | 0.01659003136 | 0.01655775223 | 1.946e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[677]` | 0.02139430443 | 0.02140915329 | 6.941e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[678]` | 0.02000120991 | 0.02000060218 | 3.038e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[679]` | 0.02281244601 | 0.02275624162 | 2.464e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[680]` | 0.02107670751 | 0.02108336477 | 3.159e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[681]` | 0.01715186219 | 0.01717882722 | 1.572e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[682]` | 0.02256564116 | 0.02257961463 | 6.192e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[683]` | 0.01469956909 | 0.01467932546 | 1.377e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[684]` | 0.02031494259 | 0.02031509196 | 7.352e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[685]` | 0.01780882467 | 0.01780118034 | 4.292e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[686]` | 0.01635971137 | 0.01635757796 | 1.304e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[687]` | 0.01492141926 | 0.01492893681 | 5.038e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[688]` | 0.01639603437 | 0.01641051032 | 8.829e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[689]` | 0.01670907542 | 0.01671624067 | 4.288e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[690]` | 0.01766452261 | 0.01765767172 | 3.878e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[691]` | 0.01794669361 | 0.01794992589 | 1.801e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[692]` | 0.01972090193 | 0.01970057005 | 1.031e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[693]` | 0.01773062194 | 0.01774209603 | 6.471e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[694]` | 0.01572610084 | 0.01573246909 | 4.049e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[695]` | 0.01979910758 | 0.01981657193 | 8.821e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[696]` | 0.02002340376 | 0.02003278513 | 4.685e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[697]` | 0.01803409132 | 0.01803978741 | 3.159e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[698]` | 0.01469555869 | 0.01471178735 | 1.104e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[699]` | 0.01598793846 | 0.01598121011 | 4.208e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[700]` | 0.01268528775 | 0.0126834726 | 1.431e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[701]` | 0.02252022454 | 0.02253006908 | 4.371e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[702]` | 0.02037265151 | 0.02036597066 | 3.279e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[703]` | 0.01344081063 | 0.01344696449 | 4.578e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[704]` | 0.01848149855 | 0.01846744023 | 7.607e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[705]` | 0.01877282289 | 0.01878463065 | 6.290e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[706]` | 0.01888608044 | 0.01888429766 | 9.440e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[707]` | 0.02104556868 | 0.02102630671 | 9.153e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[708]` | 0.01856604657 | 0.01859983099 | 1.820e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[709]` | 0.01828085801 | 0.01829221312 | 6.211e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[710]` | 0.01923935138 | 0.01922475661 | 7.586e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[711]` | 0.01757514645 | 0.01755292135 | 1.265e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[712]` | 0.02180181066 | 0.02181212574 | 4.731e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[713]` | 0.01371685103 | 0.01372936947 | 9.126e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[714]` | 0.01817317399 | 0.01819218276 | 1.046e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[715]` | 0.015624264 | 0.01563654685 | 7.861e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[716]` | 0.00986185807 | 0.009865292968 | 3.483e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[717]` | 0.02149289975 | 0.02150436085 | 5.333e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[718]` | 0.01805583289 | 0.01804732134 | 4.714e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[719]` | 0.01804282871 | 0.01804683866 | 2.222e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[720]` | 0.01616920617 | 0.01618036284 | 6.900e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[721]` | 0.01839932394 | 0.01837380022 | 1.387e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[722]` | 0.0153971952 | 0.01539485103 | 1.522e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[723]` | 0.01752763208 | 0.01751425255 | 7.633e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[724]` | 0.01820455804 | 0.01823052974 | 1.427e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[725]` | 0.01329072946 | 0.0133018337 | 8.355e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[726]` | 0.01861874073 | 0.01859441633 | 1.306e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[727]` | 0.01487144513 | 0.01485854184 | 8.677e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[728]` | 0.01684182956 | 0.01684797224 | 3.647e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[729]` | 0.01625996884 | 0.01625923873 | 4.490e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[730]` | 0.01718703632 | 0.01717904437 | 4.650e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[731]` | 0.01755174798 | 0.01754348184 | 4.710e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[732]` | 0.01975544853 | 0.01972614651 | 1.483e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[733]` | 0.01554524133 | 0.01554228857 | 1.899e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[734]` | 0.01557166838 | 0.01556032506 | 7.285e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[735]` | 0.01847852897 | 0.01845947957 | 1.031e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[736]` | 0.02129094736 | 0.02128543275 | 2.590e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[737]` | 0.01624241691 | 0.01621246689 | 1.844e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[738]` | 0.01332314127 | 0.01332898494 | 4.386e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[739]` | 0.01997057305 | 0.01995600084 | 7.297e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[740]` | 0.0227043905 | 0.022693593 | 4.756e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[741]` | 0.02016653694 | 0.02015742928 | 4.516e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[742]` | 0.02433231916 | 0.02435026778 | 7.376e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[743]` | 0.0177056813 | 0.01769457616 | 6.272e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[744]` | 0.01600055835 | 0.01600338022 | 1.764e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[745]` | 0.01934718679 | 0.01932086231 | 1.361e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[746]` | 0.01623822879 | 0.01624405406 | 3.587e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[747]` | 0.01816871174 | 0.01816501973 | 2.032e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[748]` | 0.02130358971 | 0.02129946982 | 1.934e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[749]` | 0.02263992328 | 0.02264178861 | 8.239e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[750]` | 0.0154389976 | 0.01544943498 | 6.760e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[751]` | 0.02150919312 | 0.02152421313 | 6.983e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[752]` | 0.02364200966 | 0.02364896288 | 2.941e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[753]` | 0.01786305373 | 0.01786263232 | 2.359e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[754]` | 0.01691712207 | 0.01689012713 | 1.596e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[755]` | 0.01834453346 | 0.01833232533 | 6.655e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[756]` | 0.01601439074 | 0.0160131898 | 7.499e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[757]` | 0.02292557012 | 0.02295549251 | 1.305e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[758]` | 0.01897010825 | 0.0189696973 | 2.166e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[759]` | 0.01729254292 | 0.01727874175 | 7.981e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[760]` | 0.01673496783 | 0.01672270426 | 7.328e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[761]` | 0.02239918424 | 0.02239228434 | 3.080e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[762]` | 0.02209365023 | 0.02206714808 | 1.200e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[763]` | 0.02096968621 | 0.02095501464 | 6.997e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[764]` | 0.02471958775 | 0.0246817076 | 1.532e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[765]` | 0.01524374127 | 0.01525161312 | 5.164e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[766]` | 0.01970940934 | 0.01973740386 | 1.420e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[767]` | 0.02082958777 | 0.02085722817 | 1.327e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[768]` | 0.01624123 | 0.01623068549 | 6.492e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[769]` | 0.01922776539 | 0.01920951776 | 9.490e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[770]` | 0.01754138681 | 0.01755850964 | 9.761e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[771]` | 0.02174546422 | 0.02178401368 | 1.773e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[772]` | 0.02097313283 | 0.02096677531 | 3.031e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[773]` | 0.01510387609 | 0.01508956747 | 9.473e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[774]` | 0.01588142104 | 0.01586288397 | 1.167e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[775]` | 0.02096082703 | 0.02093256593 | 1.348e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[776]` | 0.0157873415 | 0.01577012998 | 1.090e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[777]` | 0.01842589027 | 0.01844705723 | 1.149e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[778]` | 0.01958091248 | 0.01958400966 | 1.582e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[779]` | 0.01326227781 | 0.01327571283 | 1.013e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[780]` | 0.01951233157 | 0.01949457599 | 9.100e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[781]` | 0.02059225476 | 0.02056207245 | 1.466e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[782]` | 0.0164133966 | 0.0164181557 | 2.900e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[783]` | 0.01551736005 | 0.01553265076 | 9.854e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[784]` | 0.0184844829 | 0.01849323888 | 4.737e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[785]` | 0.02063205122 | 0.02062358387 | 4.104e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[786]` | 0.0119546914 | 0.01194590852 | 7.347e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[787]` | 0.02173095992 | 0.02173736011 | 2.945e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[788]` | 0.01594019927 | 0.01594569329 | 3.447e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[789]` | 0.01949166867 | 0.01951579852 | 1.238e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[790]` | 0.01950853264 | 0.01949411661 | 7.390e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[791]` | 0.01530945331 | 0.0153169646 | 4.906e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[792]` | 0.01566607007 | 0.0156912086 | 1.605e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[793]` | 0.02098478698 | 0.02094415818 | 1.936e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[794]` | 0.01908057202 | 0.01908101607 | 2.327e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[795]` | 0.02146089448 | 0.0214706738 | 4.557e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[796]` | 0.01659949294 | 0.01660882105 | 5.620e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[797]` | 0.01419316442 | 0.01419404209 | 6.184e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[798]` | 0.01666188301 | 0.01666294723 | 6.387e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[799]` | 0.01882019048 | 0.01882932443 | 4.853e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[800]` | 0.01586972349 | 0.0158650512 | 2.944e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[801]` | 0.01686568684 | 0.01687503942 | 5.545e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[802]` | 0.0172012508 | 0.01717198107 | 1.702e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[803]` | 0.01725085667 | 0.01723883157 | 6.971e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[804]` | 0.0157993153 | 0.01581636248 | 1.079e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[805]` | 0.01408735431 | 0.01409387547 | 4.629e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[806]` | 0.02209522195 | 0.02207763109 | 7.961e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[807]` | 0.01929186402 | 0.01931452967 | 1.175e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[808]` | 0.0179492072 | 0.01795281856 | 2.012e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[809]` | 0.01440798628 | 0.01440977725 | 1.243e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[810]` | 0.02227358673 | 0.02231934077 | 2.054e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[811]` | 0.01419426349 | 0.01419662479 | 1.664e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[812]` | 0.01278683463 | 0.01280661881 | 1.547e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[813]` | 0.01833398408 | 0.01833635833 | 1.295e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[814]` | 0.02053636514 | 0.02053428634 | 1.012e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[815]` | 0.01861154568 | 0.01862049006 | 4.806e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[816]` | 0.01374488526 | 0.01374838862 | 2.549e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[817]` | 0.01740237152 | 0.0174229556 | 1.183e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[818]` | 0.02338150218 | 0.02334086258 | 1.738e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[819]` | 0.01986659623 | 0.01988195548 | 7.731e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[820]` | 0.02674748515 | 0.02676254404 | 5.630e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[821]` | 0.01316086627 | 0.01316632262 | 4.146e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[822]` | 0.01951811171 | 0.019498541 | 1.003e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[823]` | 0.01885044287 | 0.01885689831 | 3.425e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[824]` | 0.01849047857 | 0.01848215481 | 4.502e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[825]` | 0.01724079689 | 0.01723595681 | 2.807e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[826]` | 0.01862434354 | 0.01865325602 | 1.552e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[827]` | 0.01670618022 | 0.01670016694 | 3.599e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[828]` | 0.01649342654 | 0.01648677444 | 4.033e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[829]` | 0.01466801229 | 0.01466581482 | 1.498e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[830]` | 0.02362690551 | 0.02360098347 | 1.097e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[831]` | 0.01708936478 | 0.01709700825 | 4.473e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[832]` | 0.02038914194 | 0.02037732295 | 5.797e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[833]` | 0.02111404754 | 0.02108971533 | 1.152e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[834]` | 0.02288545281 | 0.02286464344 | 9.093e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[835]` | 0.01785275604 | 0.01786345035 | 5.990e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[836]` | 0.01510679327 | 0.01510749747 | 4.661e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[837]` | 0.01831192859 | 0.01831512898 | 1.748e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[838]` | 0.01523759876 | 0.01524145694 | 2.532e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[839]` | 0.01828173489 | 0.01824878239 | 1.802e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[840]` | 0.01342248097 | 0.01342839603 | 4.407e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[841]` | 0.0180384403 | 0.01805216814 | 7.610e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[842]` | 0.02162405671 | 0.02162799289 | 1.820e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[843]` | 0.01485948636 | 0.01487799972 | 1.246e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[844]` | 0.02171378664 | 0.02171466136 | 4.028e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[845]` | 0.01661131249 | 0.0165964267 | 8.961e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[846]` | 0.01552903961 | 0.01553554445 | 4.189e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[847]` | 0.017756368 | 0.01777404811 | 9.957e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[848]` | 0.01935461351 | 0.01937837673 | 1.228e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[849]` | 0.01554204221 | 0.01552089625 | 1.361e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[850]` | 0.01502371161 | 0.0150219968 | 1.141e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[851]` | 0.01701185822 | 0.01700402682 | 4.603e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[852]` | 0.01509502243 | 0.01510289139 | 5.213e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[853]` | 0.02183170564 | 0.02183718995 | 2.512e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[854]` | 0.01579035552 | 0.01577991285 | 6.613e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[855]` | 0.0165993286 | 0.01661234088 | 7.839e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[856]` | 0.02279883001 | 0.02277262509 | 1.149e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[857]` | 0.02098769193 | 0.02100922887 | 1.026e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[858]` | 0.01707678571 | 0.01708268155 | 3.453e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[859]` | 0.02033338008 | 0.02033430038 | 4.526e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[860]` | 0.01179541483 | 0.01178149553 | 1.180e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[861]` | 0.01205443405 | 0.01206067138 | 5.174e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[862]` | 0.01715299112 | 0.01716457154 | 6.751e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[863]` | 0.01942605523 | 0.01944018038 | 7.271e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[864]` | 0.01801888004 | 0.01799896118 | 1.105e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[865]` | 0.0184845873 | 0.01848481923 | 1.255e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[866]` | 0.01670795004 | 0.01667424238 | 2.017e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[867]` | 0.01816136324 | 0.01818361742 | 1.225e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[868]` | 0.01661731862 | 0.01663340511 | 9.681e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[869]` | 0.01372762726 | 0.01372455688 | 2.237e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[870]` | 0.02283355222 | 0.0228331658 | 1.692e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[871]` | 0.01794493622 | 0.01792466863 | 1.129e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[872]` | 0.01815300741 | 0.01816589819 | 7.101e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[873]` | 0.01585401625 | 0.01585911118 | 3.214e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[874]` | 0.01658355836 | 0.01659347961 | 5.983e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[875]` | 0.02036840343 | 0.02039031273 | 1.076e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[876]` | 0.01461757271 | 0.01462545141 | 5.390e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[877]` | 0.01676653408 | 0.01678680415 | 1.209e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[878]` | 0.01621639802 | 0.01621791083 | 9.329e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[879]` | 0.01972377954 | 0.01970714865 | 8.432e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[880]` | 0.01745888879 | 0.01748965143 | 1.762e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[881]` | 0.02037108573 | 0.02038957972 | 9.079e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[882]` | 0.01463959811 | 0.01463160365 | 5.461e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[883]` | 0.01349031138 | 0.01349265187 | 1.735e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[884]` | 0.02323564144 | 0.02320811588 | 1.185e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[885]` | 0.01557188932 | 0.0155499908 | 1.406e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[886]` | 0.0154271357 | 0.01542591707 | 7.899e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[887]` | 0.02072033685 | 0.02074944959 | 1.405e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[888]` | 0.01795843774 | 0.0179662344 | 4.342e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[889]` | 0.01730116967 | 0.01732291732 | 1.257e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[890]` | 0.02156361665 | 0.02151701378 | 2.161e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[891]` | 0.01780130338 | 0.01779890763 | 1.346e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[892]` | 0.02134324946 | 0.02132738857 | 7.431e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[893]` | 0.01838763177 | 0.01835378401 | 1.841e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[894]` | 0.01802168551 | 0.01802137377 | 1.730e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[895]` | 0.02125257958 | 0.0212728202 | 9.524e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[896]` | 0.01865607676 | 0.0186848665 | 1.543e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[897]` | 0.01450250656 | 0.01451280578 | 7.102e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[898]` | 0.01646326672 | 0.01646889111 | 3.416e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[899]` | 0.01626023044 | 0.01627784088 | 1.083e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[900]` | 0.01413709676 | 0.01412721797 | 6.988e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[901]` | 0.01870601577 | 0.01870480467 | 6.474e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[902]` | 0.0180773422 | 0.01808152338 | 2.313e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[903]` | 0.02071271083 | 0.02072672242 | 6.765e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[904]` | 0.01810974076 | 0.01811906124 | 5.147e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[905]` | 0.01745112659 | 0.0174229212 | 1.616e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[906]` | 0.01685287419 | 0.01683074283 | 1.313e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[907]` | 0.01964811105 | 0.01964594922 | 1.100e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[908]` | 0.01658078659 | 0.01659999924 | 1.159e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[909]` | 0.01870418378 | 0.01873032357 | 1.398e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[910]` | 0.01773846072 | 0.01772241432 | 9.046e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[911]` | 0.0244709365 | 0.02447566666 | 1.933e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[912]` | 0.02206952334 | 0.0220226685 | 2.123e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[913]` | 0.02093350569 | 0.02094128909 | 3.718e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[914]` | 0.01796194009 | 0.01798619318 | 1.350e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[915]` | 0.01852170484 | 0.01849469416 | 1.458e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[916]` | 0.02205207964 | 0.02206315135 | 5.021e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[917]` | 0.01891022609 | 0.01887503939 | 1.861e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[918]` | 0.0167463095 | 0.01673294271 | 7.982e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[919]` | 0.01575715821 | 0.01576982673 | 8.040e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[920]` | 0.0135108308 | 0.0135046376 | 4.584e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[921]` | 0.02312378026 | 0.02317619796 | 2.267e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[922]` | 0.02220584804 | 0.02216611875 | 1.789e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[923]` | 0.0207797961 | 0.02079576451 | 7.685e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[924]` | 0.01766570681 | 0.01767508438 | 5.308e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[925]` | 0.01916975233 | 0.01915340373 | 8.528e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[926]` | 0.01870948238 | 0.01872080418 | 6.051e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[927]` | 0.01556190409 | 0.0155764579 | 9.352e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[928]` | 0.02095837852 | 0.02097553352 | 8.185e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[929]` | 0.01930061108 | 0.01931151326 | 5.649e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[930]` | 0.01334846367 | 0.01333955688 | 6.673e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[931]` | 0.02054550001 | 0.02052142539 | 1.172e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[932]` | 0.02208045255 | 0.02210132447 | 9.453e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[933]` | 0.02040035956 | 0.0204120646 | 5.738e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[934]` | 0.0149171837 | 0.01493561911 | 1.236e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[935]` | 0.01592661973 | 0.01594173687 | 9.492e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[936]` | 0.01766068256 | 0.01764264155 | 1.022e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[937]` | 0.0206963664 | 0.02073330686 | 1.785e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[938]` | 0.01652899289 | 0.01651053611 | 1.117e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[939]` | 0.01611803968 | 0.01612360657 | 3.454e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[940]` | 0.01922466587 | 0.01921373229 | 5.687e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[941]` | 0.01765568737 | 0.01761110649 | 2.525e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[942]` | 0.0151253412 | 0.01510564678 | 1.302e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[943]` | 0.02099607648 | 0.02102274506 | 1.270e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[944]` | 0.02076130515 | 0.02074596791 | 7.387e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[945]` | 0.01882571839 | 0.01878968867 | 1.914e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[946]` | 0.02033432411 | 0.02035885299 | 1.206e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[947]` | 0.02303589674 | 0.02303976739 | 1.680e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[948]` | 0.01608732869 | 0.0161139844 | 1.657e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[949]` | 0.01900427448 | 0.0190060748 | 9.473e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[950]` | 0.01903639607 | 0.01901044326 | 1.363e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[951]` | 0.01586649253 | 0.01586791793 | 8.984e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[952]` | 0.02179783037 | 0.02180498612 | 3.283e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[953]` | 0.01428411361 | 0.01427799917 | 4.281e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[954]` | 0.01995024518 | 0.01994735577 | 1.448e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[955]` | 0.01776182018 | 0.01776749963 | 3.198e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[956]` | 0.02162520042 | 0.02161621696 | 4.154e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[957]` | 0.01542926513 | 0.01542672825 | 1.644e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[958]` | 0.01667736233 | 0.01666377572 | 8.147e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[959]` | 0.01846420657 | 0.01845544727 | 4.744e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[960]` | 0.0167879646 | 0.01679574048 | 4.632e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[961]` | 0.020701496 | 0.02067984504 | 1.046e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[962]` | 0.01443336738 | 0.01444075751 | 5.120e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[963]` | 0.01768933664 | 0.01768991768 | 3.285e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[964]` | 0.01186036748 | 0.01186707608 | 5.656e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[965]` | 0.02026420349 | 0.02023228736 | 1.575e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[966]` | 0.01587387043 | 0.01587057733 | 2.075e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[967]` | 0.0205963317 | 0.0205781617 | 8.822e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[968]` | 0.01419016653 | 0.01416011482 | 2.118e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[969]` | 0.01320280792 | 0.01319867106 | 3.133e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[970]` | 0.02049417685 | 0.02048706639 | 3.470e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[971]` | 0.01612441167 | 0.01614177408 | 1.077e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[972]` | 0.01685433151 | 0.01685603286 | 1.009e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[973]` | 0.01934826167 | 0.01935614833 | 4.076e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[974]` | 0.01905352779 | 0.01903039652 | 1.214e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[975]` | 0.01789020166 | 0.01787880438 | 6.371e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[976]` | 0.02350584636 | 0.02348529237 | 8.744e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[977]` | 0.01936334496 | 0.01934556138 | 9.184e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[978]` | 0.01946562452 | 0.01948503266 | 9.970e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[979]` | 0.01541863544 | 0.01541667158 | 1.274e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[980]` | 0.01718949261 | 0.01719237564 | 1.677e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[981]` | 0.01616839667 | 0.01615473943 | 8.447e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[982]` | 0.01557662068 | 0.01559386115 | 1.107e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[983]` | 0.01852358047 | 0.01854981995 | 1.417e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[984]` | 0.01777897453 | 0.01778384462 | 2.739e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[985]` | 0.01764993235 | 0.0176626578 | 7.210e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[986]` | 0.01696308966 | 0.01696802115 | 2.907e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[987]` | 0.01623264846 | 0.01624794415 | 9.423e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[988]` | 0.01937959935 | 0.01937325631 | 3.273e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[989]` | 0.01893457259 | 0.01894254615 | 4.211e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[990]` | 0.01392731348 | 0.01393208842 | 3.428e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[991]` | 0.0223550525 | 0.02232384525 | 1.396e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[992]` | 0.01689938252 | 0.0168886438 | 6.355e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[993]` | 0.02079353574 | 0.02078988286 | 1.757e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[994]` | 0.02143600476 | 0.02142922642 | 3.162e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[995]` | 0.02082834752 | 0.02085126638 | 1.100e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[996]` | 0.01999793694 | 0.01999973099 | 8.971e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[997]` | 0.01641560746 | 0.01642431849 | 5.307e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[998]` | 0.01525481971 | 0.01524946137 | 3.513e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_boot[999]` | 0.01553369426 | 0.01555227553 | 1.196e-03 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[1]` | 0.0485606822 | 0.04853463335 | 5.364e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[2]` | 0.04958153682 | 0.04955651659 | 5.046e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[3]` | 0.04953690051 | 0.04954582814 | 1.802e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[4]` | 0.04988484806 | 0.04987402026 | 2.171e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[5]` | 0.04803217855 | 0.04803985348 | 1.598e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[6]` | 0.04810199758 | 0.04809253859 | 1.966e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[7]` | 0.04718770509 | 0.04718781039 | 2.231e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[8]` | 0.04588375994 | 0.04588242353 | 2.913e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[9]` | 0.04493028017 | 0.04492755856 | 6.057e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[10]` | 0.04790690357 | 0.04791475906 | 1.640e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[11]` | 0.04741123614 | 0.04741308417 | 3.898e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[12]` | 0.0488540284 | 0.0488576236 | 7.359e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[13]` | 0.04551116106 | 0.04550962755 | 3.370e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[14]` | 0.04811412342 | 0.04810999741 | 8.575e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[15]` | 0.04541729658 | 0.0454080355 | 2.039e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[16]` | 0.04957416344 | 0.04956996005 | 8.479e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[17]` | 0.04812158736 | 0.04813099034 | 1.954e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[18]` | 0.04931329311 | 0.04930177588 | 2.336e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[19]` | 0.04602205278 | 0.04601261647 | 2.050e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[20]` | 0.04764398264 | 0.04766095221 | 3.562e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[21]` | 0.0500018266 | 0.04999604392 | 1.156e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[22]` | 0.04788626636 | 0.04789563622 | 1.957e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[23]` | 0.04718446146 | 0.04719580465 | 2.404e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[24]` | 0.04565164833 | 0.04564859286 | 6.693e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[25]` | 0.04852083686 | 0.04851344052 | 1.524e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[26]` | 0.04721890523 | 0.04720832972 | 2.240e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[27]` | 0.0474357882 | 0.0474527763 | 3.581e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[28]` | 0.04813041155 | 0.0481341754 | 7.820e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[29]` | 0.04803969452 | 0.04802578095 | 2.896e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[30]` | 0.04651748924 | 0.04651785464 | 7.855e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[31]` | 0.0488875203 | 0.04889847312 | 2.240e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[32]` | 0.04692308829 | 0.04693139774 | 1.771e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[33]` | 0.04702282332 | 0.04702359449 | 1.640e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[34]` | 0.04918644939 | 0.0491918271 | 1.093e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[35]` | 0.04619797886 | 0.04620274348 | 1.031e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[36]` | 0.05128353664 | 0.05128608426 | 4.968e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[37]` | 0.04496329972 | 0.04496163915 | 3.693e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[38]` | 0.04754396253 | 0.04754076274 | 6.730e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[39]` | 0.04614463778 | 0.04616184083 | 3.728e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[40]` | 0.04935741418 | 0.04937966306 | 4.508e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[41]` | 0.04938421638 | 0.04938566168 | 2.927e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[42]` | 0.04642379697 | 0.04642693381 | 6.757e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[43]` | 0.0476494145 | 0.04766564115 | 3.405e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[44]` | 0.05011756347 | 0.05011001923 | 1.505e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[45]` | 0.0478084634 | 0.04782067252 | 2.554e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[46]` | 0.04892903057 | 0.04893659996 | 1.547e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[47]` | 0.04885535056 | 0.04886494426 | 1.964e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[48]` | 0.04514795881 | 0.04515326771 | 1.176e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[49]` | 0.04776767683 | 0.04778485006 | 3.595e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[50]` | 0.04781466663 | 0.047811393 | 6.847e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[51]` | 0.04690752478 | 0.04691257648 | 1.077e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[52]` | 0.04947833976 | 0.04946294877 | 3.111e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[53]` | 0.04829148356 | 0.04827790093 | 2.813e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[54]` | 0.04510780636 | 0.04510483291 | 6.592e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[55]` | 0.04878877468 | 0.04877092294 | 3.659e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[56]` | 0.04443482038 | 0.0444449764 | 2.286e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[57]` | 0.04679157758 | 0.04680876179 | 3.672e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[58]` | 0.04860115046 | 0.04859732911 | 7.863e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[59]` | 0.04815279146 | 0.04814779341 | 1.038e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[60]` | 0.04757522741 | 0.04758054037 | 1.117e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[61]` | 0.04789173234 | 0.04790103006 | 1.941e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[62]` | 0.04523034199 | 0.04522587981 | 9.865e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[63]` | 0.04387160609 | 0.04385711278 | 3.304e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[64]` | 0.04895091118 | 0.04896655253 | 3.195e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[65]` | 0.05074995516 | 0.05074706077 | 5.703e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[66]` | 0.04678065169 | 0.04678508378 | 9.474e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[67]` | 0.05011665006 | 0.0501209623 | 8.604e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[68]` | 0.04680212032 | 0.04677637965 | 5.500e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[69]` | 0.04853292565 | 0.04852947251 | 7.115e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[70]` | 0.05006065293 | 0.05007693649 | 3.253e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[71]` | 0.04701517604 | 0.04701927694 | 8.722e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[72]` | 0.04949082341 | 0.04948112739 | 1.959e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[73]` | 0.0451237365 | 0.04510706909 | 3.694e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[74]` | 0.04585710442 | 0.04584726719 | 2.145e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[75]` | 0.04725856137 | 0.04726427314 | 1.209e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[76]` | 0.04682327902 | 0.04682852013 | 1.119e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[77]` | 0.04642842656 | 0.04643341143 | 1.074e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[78]` | 0.04715685923 | 0.04715853613 | 3.556e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[79]` | 0.04656138516 | 0.04655342557 | 1.709e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[80]` | 0.04884126689 | 0.04882918661 | 2.473e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[81]` | 0.04638690687 | 0.04639038823 | 7.505e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[82]` | 0.04944472375 | 0.04943716327 | 1.529e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[83]` | 0.04771006079 | 0.04771420864 | 8.694e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[84]` | 0.04614548844 | 0.04615027431 | 1.037e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[85]` | 0.04947926045 | 0.0494924583 | 2.667e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[86]` | 0.04885633758 | 0.04885168066 | 9.532e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[87]` | 0.05096784656 | 0.0509889844 | 4.147e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[88]` | 0.04783165021 | 0.04782190612 | 2.037e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[89]` | 0.04699617331 | 0.04699719177 | 2.167e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[90]` | 0.04627555648 | 0.0462775836 | 4.381e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[91]` | 0.04334055162 | 0.04333228412 | 1.908e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[92]` | 0.04890917882 | 0.04891024445 | 2.179e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[93]` | 0.04574434308 | 0.04573477629 | 2.091e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[94]` | 0.04642466766 | 0.04642101779 | 7.862e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[95]` | 0.04562422895 | 0.0456231947 | 2.267e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[96]` | 0.04784819245 | 0.04786020386 | 2.510e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[97]` | 0.04678550144 | 0.04679815109 | 2.704e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[98]` | 0.04576396261 | 0.04575000313 | 3.050e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[99]` | 0.04784676359 | 0.04785603172 | 1.937e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[100]` | 0.04628235352 | 0.04628835211 | 1.296e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[101]` | 0.04823605226 | 0.04825424484 | 3.772e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[102]` | 0.05031359616 | 0.05032672885 | 2.610e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[103]` | 0.04670427204 | 0.04671084838 | 1.408e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[104]` | 0.04864156966 | 0.04864578175 | 8.659e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[105]` | 0.04412811192 | 0.0441334691 | 1.214e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[106]` | 0.04796916362 | 0.04797350082 | 9.042e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[107]` | 0.04801946479 | 0.04802272643 | 6.792e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[108]` | 0.04880756887 | 0.04879145641 | 3.301e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[109]` | 0.04581917088 | 0.04582725594 | 1.765e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[110]` | 0.04527539738 | 0.04527285904 | 5.606e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[111]` | 0.04527773605 | 0.04527446998 | 7.213e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[112]` | 0.0481632161 | 0.04816264757 | 1.180e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[113]` | 0.0478169665 | 0.04783049909 | 2.830e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[114]` | 0.04630179282 | 0.04629507234 | 1.451e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[115]` | 0.05074138059 | 0.05072117713 | 3.982e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[116]` | 0.04682849384 | 0.04682798517 | 1.086e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[117]` | 0.04745683791 | 0.04747628916 | 4.099e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[118]` | 0.04524892106 | 0.04523913535 | 2.163e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[119]` | 0.04853738835 | 0.04854579519 | 1.732e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[120]` | 0.05014287495 | 0.0501264695 | 3.272e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[121]` | 0.04848720981 | 0.04850686586 | 4.054e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[122]` | 0.04971850816 | 0.04972289903 | 8.831e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[123]` | 0.04813879674 | 0.0481315537 | 1.505e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[124]` | 0.0495125888 | 0.04953909376 | 5.353e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[125]` | 0.04627324207 | 0.04626670033 | 1.414e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[126]` | 0.04559296951 | 0.04558911256 | 8.460e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[127]` | 0.04888577768 | 0.04888397888 | 3.680e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[128]` | 0.04965205246 | 0.04965431255 | 4.552e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[129]` | 0.04629662924 | 0.0462759659 | 4.463e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[130]` | 0.04959243629 | 0.04959958193 | 1.441e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[131]` | 0.04858720308 | 0.04858618197 | 2.102e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[132]` | 0.04835113975 | 0.04834851001 | 5.439e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[133]` | 0.04740549254 | 0.04740348197 | 4.241e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[134]` | 0.04924230446 | 0.04926830488 | 5.280e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[135]` | 0.04636612425 | 0.04636907113 | 6.356e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[136]` | 0.04784437194 | 0.04784729162 | 6.102e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[137]` | 0.04726717447 | 0.04726172167 | 1.154e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[138]` | 0.04945608891 | 0.04946404483 | 1.609e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[139]` | 0.0482699429 | 0.04826518383 | 9.859e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[140]` | 0.04950322344 | 0.04949699868 | 1.257e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[141]` | 0.04932277188 | 0.04930407257 | 3.791e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[142]` | 0.04420780635 | 0.04419967274 | 1.840e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[143]` | 0.04776341227 | 0.04773954375 | 4.997e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[144]` | 0.05032350604 | 0.05032158538 | 3.817e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[145]` | 0.04844230532 | 0.04843886192 | 7.108e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[146]` | 0.05003387794 | 0.05001248862 | 4.275e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[147]` | 0.04861052571 | 0.0486218183 | 2.323e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[148]` | 0.04678596646 | 0.04679110039 | 1.097e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[149]` | 0.04626045241 | 0.04625678649 | 7.925e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[150]` | 0.05031093698 | 0.0503214693 | 2.093e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[151]` | 0.0512904743 | 0.05128521479 | 1.025e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[152]` | 0.04873821944 | 0.04874106704 | 5.843e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[153]` | 0.04748661465 | 0.04749157387 | 1.044e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[154]` | 0.04705019718 | 0.04704522882 | 1.056e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[155]` | 0.0462197466 | 0.04622222073 | 5.353e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[156]` | 0.0470928382 | 0.04710965764 | 3.572e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[157]` | 0.04593832543 | 0.04594186368 | 7.702e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[158]` | 0.05015543324 | 0.05015075564 | 9.326e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[159]` | 0.04716240257 | 0.04715110045 | 2.396e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[160]` | 0.04838278572 | 0.04838394407 | 2.394e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[161]` | 0.04930129965 | 0.0492974086 | 7.892e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[162]` | 0.04760980085 | 0.04760787929 | 4.036e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[163]` | 0.04662615803 | 0.04663602654 | 2.117e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[164]` | 0.04820338946 | 0.04821882514 | 3.202e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[165]` | 0.04594873197 | 0.04594937948 | 1.409e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[166]` | 0.05030029802 | 0.05029095309 | 1.858e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[167]` | 0.04615643263 | 0.0461459913 | 2.262e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[168]` | 0.04733736023 | 0.04734224091 | 1.031e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[169]` | 0.04804750146 | 0.04804416849 | 6.937e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[170]` | 0.04645918536 | 0.04644990971 | 1.997e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[171]` | 0.04714115975 | 0.04714531516 | 8.815e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[172]` | 0.04758051826 | 0.04758035969 | 3.333e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[173]` | 0.04773736217 | 0.04774662587 | 1.941e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[174]` | 0.04695099636 | 0.04695204053 | 2.224e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[175]` | 0.04621332841 | 0.04620426576 | 1.961e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[176]` | 0.04813437858 | 0.0481154716 | 3.928e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[177]` | 0.04706878608 | 0.04706568308 | 6.592e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[178]` | 0.05069808141 | 0.05069147265 | 1.304e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[179]` | 0.04487491878 | 0.0448629475 | 2.668e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[180]` | 0.04663353918 | 0.0466326013 | 2.011e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[181]` | 0.05093562443 | 0.05094243862 | 1.338e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[182]` | 0.04933395522 | 0.0493262788 | 1.556e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[183]` | 0.04888791834 | 0.04890071635 | 2.618e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[184]` | 0.04587729479 | 0.04588167053 | 9.538e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[185]` | 0.04766957201 | 0.04765628087 | 2.788e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[186]` | 0.04587142985 | 0.04586739326 | 8.800e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[187]` | 0.04916969408 | 0.04917295826 | 6.639e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[188]` | 0.04506834062 | 0.04506646433 | 4.163e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[189]` | 0.04815424126 | 0.04815571716 | 3.065e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[190]` | 0.04950628855 | 0.04953035185 | 4.861e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[191]` | 0.04854317265 | 0.04854157499 | 3.291e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[192]` | 0.04604313934 | 0.04604353503 | 8.594e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[193]` | 0.04649860584 | 0.04650166833 | 6.586e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[194]` | 0.04701187042 | 0.04699507686 | 3.572e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[195]` | 0.04654827025 | 0.0465656713 | 3.738e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[196]` | 0.04793977283 | 0.04791949142 | 4.231e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[197]` | 0.05064045769 | 0.05063101041 | 1.866e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[198]` | 0.0494557998 | 0.04947287199 | 3.452e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[199]` | 0.04575144528 | 0.04576297682 | 2.520e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[200]` | 0.04422655472 | 0.04422506418 | 3.370e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[201]` | 0.05062436807 | 0.05061590235 | 1.672e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[202]` | 0.04789493878 | 0.04790269 | 1.618e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[203]` | 0.04663447698 | 0.04665136561 | 3.621e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[204]` | 0.05020232814 | 0.05021798977 | 3.120e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[205]` | 0.04603171393 | 0.04601907415 | 2.746e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[206]` | 0.04780100294 | 0.04780522019 | 8.823e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[207]` | 0.04784446511 | 0.04784383015 | 1.327e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[208]` | 0.05044127244 | 0.05044785577 | 1.305e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[209]` | 0.04557319739 | 0.04556803418 | 1.133e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[210]` | 0.04853850052 | 0.04852932448 | 1.890e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[211]` | 0.04813968709 | 0.04815867682 | 3.945e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[212]` | 0.04821414712 | 0.04821171748 | 5.039e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[213]` | 0.04500940357 | 0.0450021772 | 1.606e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[214]` | 0.04854549366 | 0.0485356 | 2.038e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[215]` | 0.04793707579 | 0.04792892709 | 1.700e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[216]` | 0.04581605918 | 0.04582169422 | 1.230e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[217]` | 0.04658413398 | 0.04658952575 | 1.157e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[218]` | 0.0487320262 | 0.04870506821 | 5.532e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[219]` | 0.04665796355 | 0.04664008032 | 3.833e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[220]` | 0.05063027252 | 0.05062159959 | 1.713e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[221]` | 0.04777710864 | 0.04777390436 | 6.707e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[222]` | 0.04720708454 | 0.04719189864 | 3.217e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[223]` | 0.04894899951 | 0.0489233495 | 5.240e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[224]` | 0.04820849652 | 0.04822089318 | 2.571e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[225]` | 0.04554269021 | 0.04554469189 | 4.395e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[226]` | 0.04510944746 | 0.04510904414 | 8.941e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[227]` | 0.04404025756 | 0.04405235484 | 2.747e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[228]` | 0.0452289036 | 0.04524016464 | 2.490e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[229]` | 0.0454454846 | 0.04544353993 | 4.279e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[230]` | 0.04649403648 | 0.04649028232 | 8.074e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[231]` | 0.04753331715 | 0.0475166563 | 3.505e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[232]` | 0.04921120504 | 0.04920543067 | 1.173e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[233]` | 0.04741440776 | 0.04742947005 | 3.177e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[234]` | 0.04826481815 | 0.04827924015 | 2.988e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[235]` | 0.05038851111 | 0.05040866873 | 4.000e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[236]` | 0.04642385951 | 0.04640628304 | 3.786e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[237]` | 0.04983121691 | 0.04985473976 | 4.721e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[238]` | 0.04664344333 | 0.04665665007 | 2.831e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[239]` | 0.04418260582 | 0.04418029388 | 5.233e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[240]` | 0.04713350538 | 0.04712950332 | 8.491e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[241]` | 0.04770506117 | 0.04770745634 | 5.021e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[242]` | 0.0431855124 | 0.0431894914 | 9.214e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[243]` | 0.04921957414 | 0.04921622585 | 6.803e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[244]` | 0.04438307003 | 0.04439008055 | 1.580e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[245]` | 0.04583338043 | 0.04583370317 | 7.042e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[246]` | 0.04693627173 | 0.04694806083 | 2.512e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[247]` | 0.04852035212 | 0.04852023894 | 2.333e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[248]` | 0.04781892031 | 0.04782066437 | 3.647e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[249]` | 0.04618255082 | 0.04618056673 | 4.296e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[250]` | 0.04760286109 | 0.04760244705 | 8.698e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[251]` | 0.04468037707 | 0.04467274907 | 1.707e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[252]` | 0.04739474216 | 0.04738388848 | 2.290e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[253]` | 0.04775823458 | 0.0477583318 | 2.036e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[254]` | 0.04893768215 | 0.04893571324 | 4.023e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[255]` | 0.04564908222 | 0.04565136545 | 5.002e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[256]` | 0.04827398172 | 0.04826956231 | 9.155e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[257]` | 0.04740383051 | 0.04740516423 | 2.814e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[258]` | 0.04698575106 | 0.04698168468 | 8.654e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[259]` | 0.05058710892 | 0.05058019459 | 1.367e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[260]` | 0.04753785564 | 0.04754821858 | 2.180e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[261]` | 0.04628065559 | 0.04626956266 | 2.397e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[262]` | 0.04902732726 | 0.04901989256 | 1.516e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[263]` | 0.04803925709 | 0.04804385901 | 9.580e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[264]` | 0.04945007995 | 0.04946060593 | 2.129e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[265]` | 0.04779006777 | 0.047774795 | 3.196e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[266]` | 0.04969699981 | 0.04969626787 | 1.473e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[267]` | 0.04822433952 | 0.04822108918 | 6.740e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[268]` | 0.04763422715 | 0.0476455379 | 2.374e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[269]` | 0.04901579651 | 0.0489997996 | 3.264e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[270]` | 0.04823220935 | 0.04821581025 | 3.400e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[271]` | 0.04509164843 | 0.0450876631 | 8.838e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[272]` | 0.04916243406 | 0.04915547389 | 1.416e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[273]` | 0.0460764209 | 0.04608611267 | 2.103e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[274]` | 0.0486908599 | 0.04868894712 | 3.928e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[275]` | 0.04456214501 | 0.04456370054 | 3.491e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[276]` | 0.05093317903 | 0.05092106124 | 2.379e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[277]` | 0.04885814342 | 0.04885484535 | 6.750e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[278]` | 0.04713658198 | 0.04713059857 | 1.269e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[279]` | 0.0468301935 | 0.04683857422 | 1.790e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[280]` | 0.04792390522 | 0.04792876599 | 1.014e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[281]` | 0.04807625303 | 0.04808343034 | 1.493e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[282]` | 0.04797753191 | 0.04796407534 | 2.805e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[283]` | 0.0475462434 | 0.04754504493 | 2.521e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[284]` | 0.04689852079 | 0.04691111291 | 2.685e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[285]` | 0.04750024797 | 0.04749111587 | 1.923e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[286]` | 0.04794459868 | 0.04796576315 | 4.414e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[287]` | 0.04709117565 | 0.0470854304 | 1.220e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[288]` | 0.0488356704 | 0.04883526684 | 8.264e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[289]` | 0.04543880601 | 0.04544211979 | 7.293e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[290]` | 0.04917394145 | 0.04917434913 | 8.291e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[291]` | 0.04869987947 | 0.04871541588 | 3.190e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[292]` | 0.04514817095 | 0.04514301433 | 1.142e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[293]` | 0.0491870435 | 0.04919344864 | 1.302e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[294]` | 0.0486815717 | 0.04869033932 | 1.801e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[295]` | 0.04814966861 | 0.04816500091 | 3.184e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[296]` | 0.04697128896 | 0.04696777052 | 7.491e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[297]` | 0.04822519778 | 0.04821955459 | 1.170e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[298]` | 0.04745051874 | 0.04746301684 | 2.634e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[299]` | 0.0471241805 | 0.04711463389 | 2.026e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[300]` | 0.04828697945 | 0.04827124042 | 3.259e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[301]` | 0.0479822871 | 0.04798110325 | 2.467e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[302]` | 0.04610535974 | 0.04611062855 | 1.143e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[303]` | 0.04778938489 | 0.04779217938 | 5.848e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[304]` | 0.04935368487 | 0.0493380957 | 3.159e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[305]` | 0.04746337375 | 0.0474572837 | 1.283e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[306]` | 0.04720321811 | 0.04720554568 | 4.931e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[307]` | 0.04455420179 | 0.04456341244 | 2.067e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[308]` | 0.046407758 | 0.04641582147 | 1.738e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[309]` | 0.04365494843 | 0.04365669449 | 4.000e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[310]` | 0.04699408304 | 0.04700819133 | 3.002e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[311]` | 0.0475741936 | 0.04756405292 | 2.132e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[312]` | 0.04796670137 | 0.04795449338 | 2.545e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[313]` | 0.04779710883 | 0.04778031697 | 3.513e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[314]` | 0.04758168335 | 0.0475909272 | 1.943e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[315]` | 0.04751733672 | 0.04751832593 | 2.082e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[316]` | 0.04664951452 | 0.04664737223 | 4.592e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[317]` | 0.04793193079 | 0.04792216429 | 2.038e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[318]` | 0.04542835292 | 0.04541248675 | 3.493e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[319]` | 0.04862490885 | 0.04862749345 | 5.315e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[320]` | 0.04739028688 | 0.04738190742 | 1.768e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[321]` | 0.04792731399 | 0.04792149442 | 1.214e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[322]` | 0.0466464372 | 0.04665139508 | 1.063e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[323]` | 0.04716100994 | 0.04716367098 | 5.642e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[324]` | 0.04557022608 | 0.04557477495 | 9.982e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[325]` | 0.04709719775 | 0.0471138577 | 3.537e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[326]` | 0.04880213614 | 0.0487979116 | 8.656e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[327]` | 0.04533646649 | 0.04533840437 | 4.274e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[328]` | 0.04525486029 | 0.04525728263 | 5.353e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[329]` | 0.04412582524 | 0.04411753079 | 1.880e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[330]` | 0.04929321195 | 0.04929312729 | 1.717e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[331]` | 0.04768853837 | 0.04767772407 | 2.268e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[332]` | 0.04446579883 | 0.04447167938 | 1.322e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[333]` | 0.04690950296 | 0.04690830414 | 2.556e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[334]` | 0.05003298315 | 0.05005597063 | 4.594e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[335]` | 0.04592618623 | 0.04592891849 | 5.949e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[336]` | 0.04507409792 | 0.0450798307 | 1.272e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[337]` | 0.04729612192 | 0.04729944042 | 7.016e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[338]` | 0.04567935663 | 0.04567200703 | 1.609e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[339]` | 0.04952498673 | 0.04952542854 | 8.921e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[340]` | 0.04847473311 | 0.04845051679 | 4.996e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[341]` | 0.04342533676 | 0.04342137639 | 9.120e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[342]` | 0.04760788369 | 0.04761267045 | 1.005e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[343]` | 0.04336803497 | 0.04337542566 | 1.704e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[344]` | 0.04966747277 | 0.04968750772 | 4.034e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[345]` | 0.04924897915 | 0.04924615554 | 5.733e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[346]` | 0.04953127573 | 0.04953606959 | 9.678e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[347]` | 0.04877806798 | 0.04879113887 | 2.680e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[348]` | 0.04848734308 | 0.04847324789 | 2.907e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[349]` | 0.04866938826 | 0.04865859419 | 2.218e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[350]` | 0.04824120355 | 0.04824807684 | 1.425e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[351]` | 0.04696599761 | 0.04696332582 | 5.689e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[352]` | 0.0456945922 | 0.04570979527 | 3.327e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[353]` | 0.05137723154 | 0.05137537196 | 3.619e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[354]` | 0.0503502198 | 0.05035787678 | 1.521e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[355]` | 0.04617073669 | 0.0461744135 | 7.964e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[356]` | 0.0454852593 | 0.04547741284 | 1.725e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[357]` | 0.0492541263 | 0.04923703594 | 3.470e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[358]` | 0.0447501532 | 0.0447496446 | 1.137e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[359]` | 0.04593624997 | 0.04593543678 | 1.770e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[360]` | 0.0473680705 | 0.04736657634 | 3.154e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[361]` | 0.04715172007 | 0.04715854031 | 1.446e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[362]` | 0.04791812905 | 0.04792658555 | 1.765e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[363]` | 0.04610406226 | 0.04609845298 | 1.217e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[364]` | 0.0460051175 | 0.04599977418 | 1.161e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[365]` | 0.04451753952 | 0.04451458808 | 6.630e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[366]` | 0.04910798404 | 0.04909111655 | 3.435e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[367]` | 0.04627426103 | 0.04626689293 | 1.592e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[368]` | 0.04941663777 | 0.04939346013 | 4.690e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[369]` | 0.04777793829 | 0.04777305552 | 1.022e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[370]` | 0.0462156041 | 0.0462180917 | 5.383e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[371]` | 0.04616286974 | 0.04616094206 | 4.176e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[372]` | 0.04752605637 | 0.04751508797 | 2.308e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[373]` | 0.04932701486 | 0.04932687298 | 2.876e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[374]` | 0.04783619218 | 0.04783816638 | 4.127e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[375]` | 0.04744116637 | 0.04742339272 | 3.746e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[376]` | 0.04696939239 | 0.0469726945 | 7.030e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[377]` | 0.04669998419 | 0.04669884733 | 2.434e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[378]` | 0.04635854812 | 0.04636547338 | 1.494e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[379]` | 0.04723247482 | 0.04724255412 | 2.134e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[380]` | 0.04711751689 | 0.04711820052 | 1.451e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[381]` | 0.04733371012 | 0.04734143678 | 1.632e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[382]` | 0.04466619003 | 0.04467308248 | 1.543e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[383]` | 0.0462255577 | 0.04622186689 | 7.984e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[384]` | 0.04346399622 | 0.04347167249 | 1.766e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[385]` | 0.04662372856 | 0.04661664523 | 1.519e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[386]` | 0.04632770439 | 0.04632586637 | 3.967e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[387]` | 0.04697650696 | 0.04697879549 | 4.872e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[388]` | 0.04773447264 | 0.04774218242 | 1.615e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[389]` | 0.04894834409 | 0.04893513436 | 2.699e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[390]` | 0.04695548951 | 0.04695528988 | 4.251e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[391]` | 0.05044525002 | 0.05042362758 | 4.286e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[392]` | 0.04583336195 | 0.04584031329 | 1.517e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[393]` | 0.04954520531 | 0.04956605344 | 4.208e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[394]` | 0.04894222204 | 0.04893423572 | 1.632e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[395]` | 0.04821210103 | 0.04822438501 | 2.548e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[396]` | 0.04692153737 | 0.04692398336 | 5.213e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[397]` | 0.04703488315 | 0.04702545274 | 2.005e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[398]` | 0.04589488552 | 0.04588199557 | 2.809e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[399]` | 0.04492978072 | 0.04492755107 | 4.963e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[400]` | 0.04658383461 | 0.04659939612 | 3.341e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[401]` | 0.04810302627 | 0.04808806661 | 3.110e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[402]` | 0.04605890927 | 0.04605746442 | 3.137e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[403]` | 0.05023455636 | 0.05025561125 | 4.191e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[404]` | 0.04898398105 | 0.04898907764 | 1.040e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[405]` | 0.04463098834 | 0.04462546896 | 1.237e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[406]` | 0.05041169215 | 0.0503894723 | 4.408e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[407]` | 0.04752348603 | 0.04752763546 | 8.731e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[408]` | 0.04823858369 | 0.0482490075 | 2.161e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[409]` | 0.04522922497 | 0.0452281271 | 2.427e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[410]` | 0.04813897982 | 0.04813768883 | 2.682e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[411]` | 0.04851866245 | 0.04850646097 | 2.515e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[412]` | 0.047620606 | 0.04762808145 | 1.570e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[413]` | 0.04714927334 | 0.04715700367 | 1.640e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[414]` | 0.04829277084 | 0.04829445151 | 3.480e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[415]` | 0.04702689281 | 0.04701696293 | 2.112e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[416]` | 0.04692903396 | 0.04692675704 | 4.852e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[417]` | 0.04757794283 | 0.04757751152 | 9.065e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[418]` | 0.04834695229 | 0.04835715104 | 2.109e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[419]` | 0.04830923364 | 0.04832031569 | 2.294e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[420]` | 0.0455028691 | 0.04551293351 | 2.212e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[421]` | 0.04940548405 | 0.04941707355 | 2.346e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[422]` | 0.04813343863 | 0.04813708643 | 7.579e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[423]` | 0.04592174012 | 0.04592621181 | 9.738e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[424]` | 0.05104273641 | 0.05103383518 | 1.744e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[425]` | 0.04888780381 | 0.04889106559 | 6.672e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[426]` | 0.05039956571 | 0.05041230634 | 2.528e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[427]` | 0.04468869223 | 0.04469332896 | 1.038e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[428]` | 0.04541049186 | 0.04541787808 | 1.627e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[429]` | 0.04869089088 | 0.04869482919 | 8.088e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[430]` | 0.04730003949 | 0.04730770841 | 1.621e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[431]` | 0.05054732092 | 0.05054982573 | 4.955e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[432]` | 0.04980238764 | 0.04982771621 | 5.086e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[433]` | 0.05058068405 | 0.05056620085 | 2.863e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[434]` | 0.04940129477 | 0.04940611198 | 9.751e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[435]` | 0.04883155243 | 0.04883796073 | 1.312e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[436]` | 0.04686192081 | 0.04686117492 | 1.592e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[437]` | 0.04688302725 | 0.04688607623 | 6.503e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[438]` | 0.05066244335 | 0.05063539733 | 5.338e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[439]` | 0.04439705895 | 0.04438565924 | 2.568e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[440]` | 0.04766906448 | 0.04765770769 | 2.382e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[441]` | 0.04576525054 | 0.04576221691 | 6.629e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[442]` | 0.04402919749 | 0.04403687755 | 1.744e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[443]` | 0.04688285815 | 0.04688243288 | 9.071e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[444]` | 0.04836605363 | 0.04836215917 | 8.052e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[445]` | 0.04793310556 | 0.04793600398 | 6.047e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[446]` | 0.04734889514 | 0.04734465768 | 8.949e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[447]` | 0.04712427836 | 0.04713409845 | 2.084e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[448]` | 0.04360016279 | 0.04360039363 | 5.294e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[449]` | 0.04510347155 | 0.04508780785 | 3.473e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[450]` | 0.04710433747 | 0.0470932548 | 2.353e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[451]` | 0.04804801137 | 0.04804579858 | 4.605e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[452]` | 0.04687023334 | 0.04684975864 | 4.368e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[453]` | 0.04922424107 | 0.04920529986 | 3.848e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[454]` | 0.04829800325 | 0.04829444121 | 7.375e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[455]` | 0.0465852268 | 0.0465904156 | 1.114e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[456]` | 0.04549441865 | 0.04550417569 | 2.145e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[457]` | 0.04520026121 | 0.0451881989 | 2.669e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[458]` | 0.04973615837 | 0.04973474268 | 2.846e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[459]` | 0.04697180689 | 0.04698025894 | 1.799e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[460]` | 0.04783926925 | 0.04784465048 | 1.125e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[461]` | 0.04706983604 | 0.04708334924 | 2.871e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[462]` | 0.04878842126 | 0.04878904687 | 1.282e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[463]` | 0.04692083724 | 0.04691865612 | 4.649e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[464]` | 0.04388722288 | 0.04388135778 | 1.336e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[465]` | 0.04926864986 | 0.04926701441 | 3.319e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[466]` | 0.04948356231 | 0.04947245356 | 2.245e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[467]` | 0.04754281006 | 0.04754605482 | 6.825e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[468]` | 0.04755537143 | 0.04755501496 | 7.496e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[469]` | 0.04743677341 | 0.04744553479 | 1.847e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[470]` | 0.04653134943 | 0.04652560924 | 1.234e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[471]` | 0.05007014886 | 0.05006612358 | 8.039e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[472]` | 0.04800884837 | 0.04799701023 | 2.466e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[473]` | 0.04956232911 | 0.04956924247 | 1.395e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[474]` | 0.04698404348 | 0.04698222008 | 3.881e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[475]` | 0.04847524 | 0.0484835489 | 1.714e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[476]` | 0.04762438379 | 0.04762431423 | 1.461e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[477]` | 0.04740180153 | 0.04739143198 | 2.188e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[478]` | 0.04848784547 | 0.04848407151 | 7.783e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[479]` | 0.04956015248 | 0.04955370802 | 1.300e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[480]` | 0.04925902721 | 0.04927137092 | 2.506e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[481]` | 0.04572097567 | 0.04572045196 | 1.145e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[482]` | 0.04926921763 | 0.04924889174 | 4.125e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[483]` | 0.04656879409 | 0.04657151326 | 5.839e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[484]` | 0.04923111303 | 0.04922245233 | 1.759e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[485]` | 0.04733906402 | 0.04733456517 | 9.503e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[486]` | 0.04652925811 | 0.04652055828 | 1.870e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[487]` | 0.04674814208 | 0.04674401149 | 8.836e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[488]` | 0.04925495393 | 0.04926286028 | 1.605e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[489]` | 0.04971359272 | 0.04972406726 | 2.107e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[490]` | 0.04992878664 | 0.04993252598 | 7.489e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[491]` | 0.04735779756 | 0.04735556591 | 4.712e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[492]` | 0.04783345117 | 0.04784519634 | 2.455e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[493]` | 0.04493521193 | 0.04494041494 | 1.158e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[494]` | 0.04749779999 | 0.04750274693 | 1.042e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[495]` | 0.04668587354 | 0.04669164577 | 1.236e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[496]` | 0.04684806604 | 0.04684245572 | 1.198e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[497]` | 0.04624871368 | 0.04624476899 | 8.529e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[498]` | 0.04689652527 | 0.04688665164 | 2.105e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[499]` | 0.04548331545 | 0.04547501409 | 1.825e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[500]` | 0.05116154602 | 0.05115472583 | 1.333e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[501]` | 0.04954394012 | 0.04956148726 | 3.542e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[502]` | 0.04801617835 | 0.04801091988 | 1.095e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[503]` | 0.04813720344 | 0.048138614 | 2.930e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[504]` | 0.04512529328 | 0.04512577787 | 1.074e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[505]` | 0.04675869577 | 0.04676422203 | 1.182e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[506]` | 0.04543844253 | 0.04542924085 | 2.025e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[507]` | 0.04877053469 | 0.04877895906 | 1.727e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[508]` | 0.04712517775 | 0.04711917218 | 1.274e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[509]` | 0.04809391408 | 0.04809193271 | 4.120e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[510]` | 0.04826277211 | 0.04825505977 | 1.598e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[511]` | 0.04702491564 | 0.04704216895 | 3.669e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[512]` | 0.0446980235 | 0.0447065408 | 1.906e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[513]` | 0.0495511301 | 0.0495539955 | 5.783e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[514]` | 0.04786952064 | 0.04786470195 | 1.007e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[515]` | 0.0463438789 | 0.04633865014 | 1.128e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[516]` | 0.04886267589 | 0.04888035004 | 3.617e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[517]` | 0.0465522463 | 0.0465335897 | 4.008e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[518]` | 0.04485765202 | 0.04485949971 | 4.119e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[519]` | 0.04618211988 | 0.04619096337 | 1.915e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[520]` | 0.04802926691 | 0.04803256488 | 6.867e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[521]` | 0.04815414278 | 0.04815537445 | 2.558e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[522]` | 0.04820320946 | 0.04819948077 | 7.735e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[523]` | 0.04595779907 | 0.04595457537 | 7.014e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[524]` | 0.04788688196 | 0.04789606733 | 1.918e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[525]` | 0.04703625329 | 0.0470440982 | 1.668e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[526]` | 0.04849958493 | 0.04848727277 | 2.539e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[527]` | 0.0474940826 | 0.04747898776 | 3.178e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[528]` | 0.04691549048 | 0.04692583932 | 2.206e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[529]` | 0.04854950989 | 0.04853494353 | 3.000e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[530]` | 0.04841771626 | 0.04841848379 | 1.585e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[531]` | 0.04855374286 | 0.04854457843 | 1.887e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[532]` | 0.04861157751 | 0.04860632476 | 1.081e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[533]` | 0.04698052058 | 0.04698912229 | 1.831e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[534]` | 0.04922539464 | 0.04921955577 | 1.186e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[535]` | 0.04624277734 | 0.04625827104 | 3.351e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[536]` | 0.04785244864 | 0.04784423187 | 1.717e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[537]` | 0.04782447743 | 0.04781598606 | 1.776e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[538]` | 0.04692655661 | 0.04693923208 | 2.701e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[539]` | 0.04769408788 | 0.04770525846 | 2.342e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[540]` | 0.04691095578 | 0.04691750455 | 1.396e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[541]` | 0.04853267414 | 0.04851351845 | 3.947e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[542]` | 0.04827443072 | 0.04827863579 | 8.711e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[543]` | 0.04727769172 | 0.0472816781 | 8.432e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[544]` | 0.04484661648 | 0.04485035616 | 8.339e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[545]` | 0.0464450655 | 0.0464389573 | 1.315e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[546]` | 0.0486236138 | 0.04863432914 | 2.204e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[547]` | 0.04782229235 | 0.04783859021 | 3.408e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[548]` | 0.04516162058 | 0.04516963419 | 1.774e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[549]` | 0.0465021988 | 0.0465033712 | 2.521e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[550]` | 0.0461339744 | 0.04612170129 | 2.660e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[551]` | 0.04540981734 | 0.04540162315 | 1.804e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[552]` | 0.04649865815 | 0.0464929715 | 1.223e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[553]` | 0.04781222654 | 0.04782332276 | 2.321e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[554]` | 0.04999145019 | 0.05000956288 | 3.623e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[555]` | 0.04877383608 | 0.0487711026 | 5.604e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[556]` | 0.04455513044 | 0.04456362427 | 1.906e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[557]` | 0.04647695624 | 0.04648974106 | 2.751e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[558]` | 0.04973382316 | 0.0497274823 | 1.275e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[559]` | 0.04884339066 | 0.0488618767 | 3.785e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[560]` | 0.0480607595 | 0.04805198354 | 1.826e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[561]` | 0.04586250756 | 0.04585605601 | 1.407e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[562]` | 0.05085665052 | 0.05084334012 | 2.617e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[563]` | 0.04879269373 | 0.04880598349 | 2.724e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[564]` | 0.04820771696 | 0.04820949797 | 3.694e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[565]` | 0.04785081315 | 0.04784462893 | 1.292e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[566]` | 0.04879295345 | 0.04877712939 | 3.243e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[567]` | 0.04632734733 | 0.04631972031 | 1.646e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[568]` | 0.04746928619 | 0.04746912319 | 3.434e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[569]` | 0.04587010944 | 0.04586226964 | 1.709e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[570]` | 0.04608749883 | 0.04608256962 | 1.070e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[571]` | 0.04907098 | 0.04906985797 | 2.287e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[572]` | 0.04877291832 | 0.04875814534 | 3.029e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[573]` | 0.04362240363 | 0.0436233914 | 2.264e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[574]` | 0.0488927401 | 0.04891391112 | 4.330e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[575]` | 0.04777465514 | 0.04777591376 | 2.634e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[576]` | 0.04436753693 | 0.04436615966 | 3.104e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[577]` | 0.04719512506 | 0.047206189 | 2.344e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[578]` | 0.04594830692 | 0.04596203254 | 2.987e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[579]` | 0.04565717042 | 0.0456587135 | 3.380e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[580]` | 0.04685508061 | 0.04684973801 | 1.140e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[581]` | 0.04696663081 | 0.04695812987 | 1.810e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[582]` | 0.04746120488 | 0.04747584168 | 3.084e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[583]` | 0.0502737089 | 0.05028973294 | 3.187e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[584]` | 0.04447989266 | 0.04448558926 | 1.281e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[585]` | 0.04622926035 | 0.04623342271 | 9.004e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[586]` | 0.04743449123 | 0.04744032875 | 1.231e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[587]` | 0.04932526214 | 0.04931621732 | 1.834e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[588]` | 0.04624073972 | 0.04624303994 | 4.974e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[589]` | 0.05015803678 | 0.05015029869 | 1.543e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[590]` | 0.04486278438 | 0.04487277044 | 2.226e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[591]` | 0.04712661887 | 0.04712625524 | 7.716e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[592]` | 0.04847862481 | 0.04847076539 | 1.621e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[593]` | 0.0473786642 | 0.0473820843 | 7.219e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[594]` | 0.04866321106 | 0.04864074629 | 4.616e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[595]` | 0.04642209846 | 0.04642267168 | 1.235e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[596]` | 0.04480104995 | 0.04480223173 | 2.638e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[597]` | 0.04818697463 | 0.04818293718 | 8.379e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[598]` | 0.04489431946 | 0.04488375003 | 2.354e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[599]` | 0.05036023401 | 0.05034665036 | 2.697e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[600]` | 0.0481378415 | 0.04815326394 | 3.204e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[601]` | 0.0475739458 | 0.04757403658 | 1.908e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[602]` | 0.04618595369 | 0.04618648508 | 1.151e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[603]` | 0.04892625264 | 0.04890810094 | 3.710e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[604]` | 0.04725191968 | 0.04724482896 | 1.501e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[605]` | 0.04646766375 | 0.04645896117 | 1.873e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[606]` | 0.04963111775 | 0.0496100446 | 4.246e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[607]` | 0.04552791371 | 0.04552594521 | 4.324e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[608]` | 0.0495453796 | 0.04955785185 | 2.517e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[609]` | 0.04604782174 | 0.04604901596 | 2.593e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[610]` | 0.04736170585 | 0.04738110426 | 4.096e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[611]` | 0.04705103275 | 0.04705516553 | 8.784e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[612]` | 0.04980008268 | 0.04981749759 | 3.497e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[613]` | 0.04583638182 | 0.04583445917 | 4.195e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[614]` | 0.04745305569 | 0.04746722569 | 2.986e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[615]` | 0.04613022698 | 0.04610838015 | 4.736e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[616]` | 0.04909567805 | 0.04909891696 | 6.597e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[617]` | 0.04902928667 | 0.04900746749 | 4.450e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[618]` | 0.04970071411 | 0.04970625878 | 1.116e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[619]` | 0.0479236839 | 0.04792192899 | 3.662e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[620]` | 0.04900666224 | 0.04902008932 | 2.740e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[621]` | 0.05029231032 | 0.05029771512 | 1.075e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[622]` | 0.0481750841 | 0.04818495721 | 2.049e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[623]` | 0.04711936157 | 0.04712247198 | 6.601e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[624]` | 0.04763692002 | 0.04762894666 | 1.674e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[625]` | 0.04769134343 | 0.04768940771 | 4.059e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[626]` | 0.04535003444 | 0.04535467335 | 1.023e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[627]` | 0.04527239659 | 0.04527132326 | 2.371e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[628]` | 0.04882628983 | 0.0488077459 | 3.798e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[629]` | 0.04466325085 | 0.04465994658 | 7.398e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[630]` | 0.0477889967 | 0.04780728556 | 3.827e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[631]` | 0.04623134236 | 0.04622701336 | 9.364e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[632]` | 0.05123701881 | 0.05123525144 | 3.449e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[633]` | 0.0461744959 | 0.04617455167 | 1.208e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[634]` | 0.04464499058 | 0.04464657825 | 3.556e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[635]` | 0.04627884183 | 0.04626365833 | 3.281e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[636]` | 0.04647042299 | 0.04647824079 | 1.682e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[637]` | 0.0518063921 | 0.05177029506 | 6.968e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[638]` | 0.04846685145 | 0.04845192278 | 3.080e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[639]` | 0.04650572737 | 0.04651191563 | 1.331e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[640]` | 0.04700316275 | 0.04699742082 | 1.222e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[641]` | 0.04879507056 | 0.04879217628 | 5.931e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[642]` | 0.04985404196 | 0.049876345 | 4.474e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[643]` | 0.0488929095 | 0.04890120981 | 1.698e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[644]` | 0.04603864679 | 0.04603071454 | 1.723e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[645]` | 0.0464741995 | 0.04647915672 | 1.067e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[646]` | 0.04832173086 | 0.04834262251 | 4.323e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[647]` | 0.04591104113 | 0.04592375451 | 2.769e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[648]` | 0.04700285654 | 0.04698317155 | 4.188e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[649]` | 0.0489127858 | 0.04891204005 | 1.525e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[650]` | 0.04782756946 | 0.04782858511 | 2.124e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[651]` | 0.05056104926 | 0.05058483752 | 4.705e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[652]` | 0.04832213363 | 0.04831883851 | 6.819e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[653]` | 0.04581203466 | 0.04581189688 | 3.008e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[654]` | 0.0466112589 | 0.04661584493 | 9.839e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[655]` | 0.05005165147 | 0.05005707648 | 1.084e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[656]` | 0.04758338904 | 0.04759173365 | 1.754e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[657]` | 0.04545725167 | 0.04545093328 | 1.390e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[658]` | 0.04756366683 | 0.04756393099 | 5.554e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[659]` | 0.04740533036 | 0.0474165843 | 2.374e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[660]` | 0.04744608694 | 0.04744195456 | 8.710e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[661]` | 0.04423736512 | 0.04423506719 | 5.195e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[662]` | 0.04760302686 | 0.04761055313 | 1.581e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[663]` | 0.04701549113 | 0.04701973664 | 9.030e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[664]` | 0.04636298222 | 0.04636421736 | 2.664e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[665]` | 0.04706366513 | 0.0470562402 | 1.578e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[666]` | 0.04732380858 | 0.047316031 | 1.643e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[667]` | 0.04700433036 | 0.04700913822 | 1.023e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[668]` | 0.0473911164 | 0.04739204562 | 1.961e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[669]` | 0.04532298527 | 0.04532408349 | 2.423e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[670]` | 0.04637456294 | 0.04636188848 | 2.733e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[671]` | 0.05046296616 | 0.05048030979 | 3.437e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[672]` | 0.04651035781 | 0.04648785517 | 4.838e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[673]` | 0.0474078539 | 0.04738996573 | 3.773e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[674]` | 0.04722120649 | 0.04723163675 | 2.209e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[675]` | 0.04975980601 | 0.04974393883 | 3.189e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[676]` | 0.0466881185 | 0.04666907381 | 4.079e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[677]` | 0.04952263961 | 0.04953140044 | 1.769e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[678]` | 0.04870071385 | 0.04870035528 | 7.363e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[679]` | 0.05035934315 | 0.05032618256 | 6.585e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[680]` | 0.04933525743 | 0.04933918521 | 7.961e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[681]` | 0.04701959869 | 0.04703550806 | 3.384e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[682]` | 0.05021372828 | 0.05022197263 | 1.642e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[683]` | 0.04557274576 | 0.04556080202 | 2.621e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[684]` | 0.04888581613 | 0.04888590425 | 1.803e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[685]` | 0.04740720656 | 0.0474026964 | 9.514e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[686]` | 0.04655222971 | 0.046550971 | 2.704e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[687]` | 0.04570363736 | 0.04570807272 | 9.705e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[688]` | 0.04657366028 | 0.04658220109 | 1.834e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[689]` | 0.0467583545 | 0.046762582 | 9.041e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[690]` | 0.04732206834 | 0.04731802631 | 8.542e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[691]` | 0.04748854923 | 0.04749045627 | 4.016e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[692]` | 0.04853533214 | 0.04852333633 | 2.472e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[693]` | 0.04736106694 | 0.04736783666 | 1.429e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[694]` | 0.04617839949 | 0.04618215676 | 8.136e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[695]` | 0.04858147347 | 0.04859177744 | 2.121e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[696]` | 0.04871380822 | 0.04871934323 | 1.136e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[697]` | 0.04754011388 | 0.04754347457 | 7.069e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[698]` | 0.04557037963 | 0.04557995454 | 2.101e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[699]` | 0.04633288369 | 0.04632891397 | 8.568e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[700]` | 0.04438431977 | 0.04438324883 | 2.413e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[701]` | 0.05018693248 | 0.05019274076 | 1.157e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[702]` | 0.04891986439 | 0.04891592269 | 8.057e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[703]` | 0.04483007827 | 0.04483370905 | 8.099e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[704]` | 0.04780408415 | 0.04779578974 | 1.735e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[705]` | 0.04797596551 | 0.04798293209 | 1.452e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[706]` | 0.04804278746 | 0.04804173562 | 2.189e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[707]` | 0.04931688552 | 0.04930552096 | 2.304e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[708]` | 0.04785396748 | 0.04787390028 | 4.165e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[709]` | 0.04768570623 | 0.04769240574 | 1.405e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[710]` | 0.04825121732 | 0.0482426064 | 1.785e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[711]` | 0.0472693364 | 0.0472562236 | 2.774e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[712]` | 0.04976306829 | 0.04976915419 | 1.223e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[713]` | 0.0449929421 | 0.04500032799 | 1.642e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[714]` | 0.04762217266 | 0.04763338783 | 2.355e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[715]` | 0.04611831576 | 0.04612556264 | 1.571e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[716]` | 0.04271849626 | 0.04272052285 | 4.744e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[717]` | 0.04958081085 | 0.0495875729 | 1.364e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[718]` | 0.0475529414 | 0.04754791959 | 1.056e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[719]` | 0.04754526894 | 0.04754763481 | 4.976e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[720]` | 0.04643983164 | 0.04644641407 | 1.417e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[721]` | 0.04775560113 | 0.04774054213 | 3.153e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[722]` | 0.04598434517 | 0.04598296211 | 3.008e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[723]` | 0.04724130293 | 0.047233409 | 1.671e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[724]` | 0.04764068924 | 0.04765601254 | 3.216e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[725]` | 0.04474153038 | 0.04474808188 | 1.464e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[726]` | 0.04788505703 | 0.04787070564 | 2.997e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[727]` | 0.04567415263 | 0.04566653969 | 1.667e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[728]` | 0.04683667944 | 0.04684030362 | 7.738e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[729]` | 0.04649338161 | 0.04649295085 | 9.265e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[730]` | 0.04704035143 | 0.04703563618 | 1.002e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[731]` | 0.04725553131 | 0.04725065429 | 1.032e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[732]` | 0.04855571463 | 0.04853842644 | 3.560e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[733]` | 0.04607169238 | 0.04606995026 | 3.781e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[734]` | 0.04608728434 | 0.04608059178 | 1.452e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[735]` | 0.04780233209 | 0.04779109295 | 2.351e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[736]` | 0.04946165895 | 0.04945840532 | 6.578e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[737]` | 0.04648302598 | 0.04646535547 | 3.801e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[738]` | 0.04476065335 | 0.04476410111 | 7.703e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[739]` | 0.0486826381 | 0.04867404049 | 1.766e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[740]` | 0.05029559039 | 0.05028921987 | 1.267e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[741]` | 0.0487982568 | 0.04879288328 | 1.101e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[742]` | 0.0512560683 | 0.05126665799 | 2.066e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[743]` | 0.04734635197 | 0.04733979993 | 1.384e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[744]` | 0.04634032943 | 0.04634199433 | 3.593e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[745]` | 0.0483148402 | 0.04829930877 | 3.215e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[746]` | 0.04648055499 | 0.0464839919 | 7.394e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[747]` | 0.04761953993 | 0.04761736164 | 4.574e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[748]` | 0.04946911793 | 0.04946668719 | 4.914e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[749]` | 0.05025755473 | 0.05025865528 | 2.190e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[750]` | 0.04600900858 | 0.04601516664 | 1.338e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[751]` | 0.04959042394 | 0.04959928575 | 1.787e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[752]` | 0.0508487857 | 0.0508528881 | 8.068e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[753]` | 0.0474392017 | 0.04743895307 | 5.241e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[754]` | 0.04688110202 | 0.04686517501 | 3.397e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[755]` | 0.04772327474 | 0.04771607194 | 1.509e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[756]` | 0.04634849054 | 0.04634778198 | 1.529e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[757]` | 0.05042608637 | 0.05044374058 | 3.501e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[758]` | 0.04809236387 | 0.04809212141 | 5.042e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[759]` | 0.04710260032 | 0.04709445763 | 1.729e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[760]` | 0.04677363102 | 0.04676639551 | 1.547e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[761]` | 0.0501155187 | 0.05011144776 | 8.123e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[762]` | 0.04993525364 | 0.04991961737 | 3.131e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[763]` | 0.04927211487 | 0.04926345864 | 1.757e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[764]` | 0.05148455677 | 0.05146220748 | 4.341e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[765]` | 0.04589380735 | 0.04589845174 | 1.012e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[766]` | 0.04852855151 | 0.04854506828 | 3.404e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[767]` | 0.04918945679 | 0.04920576462 | 3.315e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[768]` | 0.0464823257 | 0.04647610444 | 1.338e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[769]` | 0.04824438158 | 0.04823361548 | 2.232e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[770]` | 0.04724941822 | 0.04725952069 | 2.138e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[771]` | 0.04972982389 | 0.04975256807 | 4.574e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[772]` | 0.04927414837 | 0.04927039743 | 7.612e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[773]` | 0.04581128689 | 0.04580284481 | 1.843e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[774]` | 0.04627003841 | 0.04625910154 | 2.364e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[775]` | 0.04926688795 | 0.0492502139 | 3.384e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[776]` | 0.04621453149 | 0.04620437669 | 2.197e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[777]` | 0.04777127526 | 0.04778376376 | 2.614e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[778]` | 0.04845273837 | 0.0484545657 | 3.771e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[779]` | 0.04472474391 | 0.04473267057 | 1.772e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[780]` | 0.04841227562 | 0.04840179984 | 2.164e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[781]` | 0.04904943031 | 0.04903162274 | 3.631e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[782]` | 0.04658390399 | 0.04658671186 | 6.028e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[783]` | 0.04605524243 | 0.04606426395 | 1.959e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[784]` | 0.04780584491 | 0.04781101094 | 1.081e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[785]` | 0.04907291022 | 0.04906791448 | 1.018e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[786]` | 0.04395326792 | 0.04394808603 | 1.179e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[787]` | 0.04972126635 | 0.04972504246 | 7.595e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[788]` | 0.04630471757 | 0.04630795904 | 7.000e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[789]` | 0.04840008451 | 0.04841432113 | 2.941e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[790]` | 0.04841003425 | 0.0484015288 | 1.757e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[791]` | 0.04593257745 | 0.04593700911 | 9.648e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[792]` | 0.04614298134 | 0.04615781307 | 3.214e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[793]` | 0.04928102432 | 0.04925705333 | 4.864e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[794]` | 0.04815753749 | 0.04815779948 | 5.440e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[795]` | 0.04956192775 | 0.04956769754 | 1.164e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[796]` | 0.04669370084 | 0.04669920442 | 1.179e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[797]` | 0.04527396701 | 0.04527448483 | 1.144e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[798]` | 0.04673051098 | 0.04673113887 | 1.344e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[799]` | 0.04800391238 | 0.04800930141 | 1.123e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[800]` | 0.04626313686 | 0.04626038021 | 5.959e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[801]` | 0.04685075523 | 0.04685627326 | 1.178e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[802]` | 0.04704873797 | 0.04703146883 | 3.670e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[803]` | 0.04707800544 | 0.04707091063 | 1.507e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[804]` | 0.04622159603 | 0.04623165386 | 2.176e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[805]` | 0.04521153904 | 0.04521538653 | 8.510e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[806]` | 0.04993618095 | 0.04992580234 | 2.078e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[807]` | 0.04828219977 | 0.04829557251 | 2.770e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[808]` | 0.04749003225 | 0.04749216295 | 4.487e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[809]` | 0.04540071191 | 0.04540176858 | 2.327e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[810]` | 0.05004141617 | 0.05006841105 | 5.395e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[811]` | 0.04527461546 | 0.04527600862 | 3.077e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[812]` | 0.04444423243 | 0.0444559051 | 2.626e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[813]` | 0.04771705061 | 0.04771845142 | 2.936e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[814]` | 0.04901645543 | 0.04901522894 | 2.502e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[815]` | 0.04788081195 | 0.04788608914 | 1.102e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[816]` | 0.04500948231 | 0.04501154929 | 4.592e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[817]` | 0.0471673992 | 0.0471795438 | 2.575e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[818]` | 0.05069508628 | 0.05067110892 | 4.730e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[819]` | 0.04862129178 | 0.04863035374 | 1.864e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[820]` | 0.05268101624 | 0.05268990099 | 1.687e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[821]` | 0.0446649111 | 0.04466813035 | 7.208e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[822]` | 0.04841568591 | 0.04840413919 | 2.385e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[823]` | 0.04802176129 | 0.04802557001 | 7.931e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[824]` | 0.04780938236 | 0.04780447134 | 1.027e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[825]` | 0.04707207016 | 0.04706921452 | 6.067e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[826]` | 0.04788836269 | 0.04790542105 | 3.562e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[827]` | 0.04675664633 | 0.0467530985 | 7.588e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[828]` | 0.04663112166 | 0.04662719692 | 8.417e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[829]` | 0.04555412725 | 0.04555283074 | 2.846e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[830]` | 0.05083987425 | 0.05082458025 | 3.008e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[831]` | 0.04698272522 | 0.04698723487 | 9.599e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[832]` | 0.04892959375 | 0.04892262054 | 1.425e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[833]` | 0.04935728805 | 0.04934293204 | 2.909e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[834]` | 0.05040241716 | 0.05039013963 | 2.436e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[835]` | 0.04743312606 | 0.04743943571 | 1.330e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[836]` | 0.04581300803 | 0.04581342351 | 9.069e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[837]` | 0.04770403787 | 0.0477059261 | 3.958e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[838]` | 0.04589018327 | 0.0458924596 | 4.960e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[839]` | 0.04768622358 | 0.04766678161 | 4.077e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[840]` | 0.04481926377 | 0.04482275366 | 7.787e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[841]` | 0.04754267978 | 0.0475507792 | 1.704e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[842]` | 0.04965819346 | 0.0496605158 | 4.677e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[843]` | 0.04566709695 | 0.04567801983 | 2.392e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[844]` | 0.04971113412 | 0.0497116502 | 1.038e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[845]` | 0.04670067437 | 0.04669189175 | 1.881e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[846]` | 0.04606213337 | 0.04606597123 | 8.332e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[847]` | 0.04737625712 | 0.04738668839 | 2.202e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[848]` | 0.04831922197 | 0.04833324227 | 2.902e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[849]` | 0.0460698049 | 0.04605732879 | 2.708e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[850]` | 0.04576398985 | 0.04576297811 | 2.211e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[851]` | 0.04693699635 | 0.04693237583 | 9.844e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[852]` | 0.04580606323 | 0.04581070592 | 1.014e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[853]` | 0.04978070633 | 0.04978394207 | 6.500e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[854]` | 0.04621630975 | 0.04621014858 | 1.333e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[855]` | 0.04669360387 | 0.04670128112 | 1.644e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[856]` | 0.05035130971 | 0.0503358488 | 3.071e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[857]` | 0.04928273824 | 0.04929544503 | 2.578e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[858]` | 0.04697530357 | 0.04697878212 | 7.405e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[859]` | 0.04889669425 | 0.04889723723 | 1.110e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[860]` | 0.04385929475 | 0.04385108236 | 1.872e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[861]` | 0.04401211609 | 0.04401579611 | 8.361e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[862]` | 0.04702026476 | 0.04702709721 | 1.453e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[863]` | 0.04836137259 | 0.04836970643 | 1.723e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[864]` | 0.04753113923 | 0.0475193871 | 2.473e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[865]` | 0.04780590651 | 0.04780604334 | 2.862e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[866]` | 0.04675769052 | 0.046737803 | 4.253e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[867]` | 0.04761520431 | 0.04762833428 | 2.758e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[868]` | 0.04670421799 | 0.04671370902 | 2.032e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[869]` | 0.04499930008 | 0.04499748856 | 4.026e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[870]` | 0.05037179581 | 0.05037156782 | 4.526e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[871]` | 0.04748751237 | 0.04747555449 | 2.518e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[872]` | 0.04761027437 | 0.04761787993 | 1.597e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[873]` | 0.04625386959 | 0.0462568756 | 6.499e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[874]` | 0.04668429943 | 0.04669015297 | 1.254e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[875]` | 0.04891735802 | 0.04893028451 | 2.643e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[876]` | 0.0455243679 | 0.04552901633 | 1.021e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[877]` | 0.04679225511 | 0.04680421445 | 2.556e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[878]` | 0.04646767483 | 0.04646856739 | 1.921e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[879]` | 0.04853702993 | 0.0485272177 | 2.022e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[880]` | 0.04720074439 | 0.04721889434 | 3.845e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[881]` | 0.04891894058 | 0.04892985203 | 2.231e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[882]` | 0.04553736288 | 0.04553264615 | 1.036e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[883]` | 0.04485928371 | 0.0448606646 | 3.078e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[884]` | 0.05060902845 | 0.05059278837 | 3.209e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[885]` | 0.0460874147 | 0.04607449457 | 2.803e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[886]` | 0.04600201006 | 0.04600129107 | 1.563e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[887]` | 0.04912499874 | 0.04914217526 | 3.496e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[888]` | 0.04749547827 | 0.0475000783 | 9.685e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[889]` | 0.0471076901 | 0.04712052122 | 2.724e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[890]` | 0.04962253383 | 0.04959503813 | 5.541e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[891]` | 0.047402769 | 0.0474013555 | 2.982e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[892]` | 0.04949251718 | 0.04948315926 | 1.891e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[893]` | 0.04774870275 | 0.04772873257 | 4.182e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[894]` | 0.04753279445 | 0.04753261053 | 3.869e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[895]` | 0.04943902195 | 0.04945096392 | 2.415e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[896]` | 0.04790708529 | 0.04792407124 | 3.546e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[897]` | 0.04545647887 | 0.04546255541 | 1.337e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[898]` | 0.04661332737 | 0.04661664575 | 7.119e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[899]` | 0.04649353596 | 0.04650392612 | 2.235e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[900]` | 0.04524088709 | 0.04523505861 | 1.288e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[901]` | 0.0479365493 | 0.04793583475 | 1.491e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[902]` | 0.0475656319 | 0.04756809879 | 5.186e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[903]` | 0.04912049939 | 0.04912876623 | 1.683e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[904]` | 0.04758474705 | 0.04759024613 | 1.156e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[905]` | 0.04719616469 | 0.04717952351 | 3.526e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[906]` | 0.04684319577 | 0.04683013827 | 2.787e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[907]` | 0.04849238552 | 0.04849111004 | 2.630e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[908]` | 0.04668266409 | 0.04669399955 | 2.428e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[909]` | 0.04793546843 | 0.04795089091 | 3.217e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[910]` | 0.04736569182 | 0.04735622445 | 1.999e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[911]` | 0.05133785253 | 0.05134064333 | 5.436e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[912]` | 0.04992101877 | 0.04989337441 | 5.538e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[913]` | 0.04925076836 | 0.04925536056 | 9.324e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[914]` | 0.04749754465 | 0.04751185398 | 3.013e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[915]` | 0.04782780585 | 0.04781186955 | 3.332e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[916]` | 0.04991072699 | 0.0499172593 | 1.309e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[917]` | 0.0480570334 | 0.04803627324 | 4.320e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[918]` | 0.0467803226 | 0.0467724362 | 1.686e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[919]` | 0.04619672335 | 0.04620419777 | 1.618e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[920]` | 0.04487139017 | 0.04486773618 | 8.143e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[921]` | 0.05054303035 | 0.0505739568 | 6.119e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[922]` | 0.05000145034 | 0.04997801006 | 4.688e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[923]` | 0.0491600797 | 0.04916950106 | 1.916e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[924]` | 0.04732276702 | 0.04732829978 | 1.169e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[925]` | 0.04821015387 | 0.0482005082 | 2.001e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[926]` | 0.0479385946 | 0.04794527447 | 1.393e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[927]` | 0.04608152341 | 0.04609011016 | 1.863e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[928]` | 0.04926544333 | 0.04927556478 | 2.054e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[929]` | 0.04828736054 | 0.04829379282 | 1.332e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[930]` | 0.04477559356 | 0.04477033856 | 1.174e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[931]` | 0.04902184501 | 0.04900764098 | 2.897e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[932]` | 0.049927467 | 0.04993978144 | 2.466e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[933]` | 0.04893621214 | 0.04894311811 | 1.411e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[934]` | 0.04570113838 | 0.04571201527 | 2.380e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[935]` | 0.04629670564 | 0.04630562476 | 1.927e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[936]` | 0.04731980271 | 0.04730915851 | 2.249e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[937]` | 0.04911085618 | 0.04913265105 | 4.438e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[938]` | 0.0466521058 | 0.04664121631 | 2.334e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[939]` | 0.04640964341 | 0.04641292788 | 7.077e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[940]` | 0.04824255287 | 0.04823610205 | 1.337e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[941]` | 0.04731685555 | 0.04729055283 | 5.559e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[942]` | 0.04582395131 | 0.0458123316 | 2.536e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[943]` | 0.04928768512 | 0.04930341959 | 3.192e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[944]` | 0.04914917004 | 0.04914012107 | 1.841e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[945]` | 0.04800717385 | 0.04798591631 | 4.428e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[946]` | 0.04889725122 | 0.04891172326 | 2.960e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[947]` | 0.05049117908 | 0.05049346276 | 4.523e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[948]` | 0.04639152393 | 0.0464072508 | 3.390e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[949]` | 0.04811252194 | 0.04811358413 | 2.208e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[950]` | 0.04813147368 | 0.04811616153 | 3.181e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[951]` | 0.04626123059 | 0.04626207158 | 1.818e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[952]` | 0.04976071992 | 0.04976494181 | 8.484e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[953]` | 0.04532762703 | 0.04532401951 | 7.959e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[954]` | 0.04867064466 | 0.04866893991 | 3.503e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[955]` | 0.04737947391 | 0.04738282478 | 7.072e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[956]` | 0.04965886825 | 0.04965356801 | 1.067e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[957]` | 0.04600326642 | 0.04600176967 | 3.254e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[958]` | 0.04673964378 | 0.04673162768 | 1.715e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[959]` | 0.04779388188 | 0.04778871389 | 1.081e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[960]` | 0.04680489911 | 0.04680948688 | 9.802e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[961]` | 0.04911388264 | 0.04910110857 | 2.601e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[962]` | 0.04541568675 | 0.04542004693 | 9.601e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[963]` | 0.04733670862 | 0.04733705143 | 7.242e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[964]` | 0.04389761681 | 0.04390157489 | 9.017e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[965]` | 0.04885588006 | 0.04883704954 | 3.854e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[966]` | 0.04626558355 | 0.04626364062 | 4.200e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[967]` | 0.0490518357 | 0.0490411154 | 2.186e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[968]` | 0.04527219825 | 0.04525446774 | 3.916e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[969]` | 0.04468965667 | 0.04468721592 | 5.462e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[970]` | 0.04899156434 | 0.04898736917 | 8.563e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[971]` | 0.04641340288 | 0.04642364671 | 2.207e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[972]` | 0.04684405559 | 0.04684505939 | 2.143e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[973]` | 0.04831547439 | 0.04832012751 | 9.631e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[974]` | 0.04814158139 | 0.04812793395 | 2.835e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[975]` | 0.04745521898 | 0.04744849458 | 1.417e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[976]` | 0.05076844935 | 0.0507563225 | 2.389e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[977]` | 0.04832437353 | 0.04831388121 | 2.171e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[978]` | 0.04838471847 | 0.04839616927 | 2.367e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[979]` | 0.04599699491 | 0.04599583623 | 2.519e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[980]` | 0.04704180064 | 0.04704350163 | 3.616e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[981]` | 0.04643935403 | 0.04643129627 | 1.735e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[982]` | 0.0460902062 | 0.04610037808 | 2.207e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[983]` | 0.04782891248 | 0.04784439377 | 3.237e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[984]` | 0.04738959497 | 0.04739246833 | 6.063e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[985]` | 0.04731346009 | 0.0473209681 | 1.587e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[986]` | 0.0469082229 | 0.04691113248 | 6.203e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[987]` | 0.04647726259 | 0.04648628705 | 1.942e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[988]` | 0.04833396361 | 0.04833022123 | 7.743e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[989]` | 0.04807139783 | 0.04807610223 | 9.786e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[990]` | 0.04511711495 | 0.04511993217 | 6.244e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[991]` | 0.05008948098 | 0.0500710687 | 3.676e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[992]` | 0.04687063569 | 0.04686429984 | 1.352e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[993]` | 0.04916818609 | 0.04916603088 | 4.383e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[994]` | 0.04954724281 | 0.04954324359 | 8.072e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[995]` | 0.04918872504 | 0.04920224716 | 2.749e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[996]` | 0.0486987828 | 0.04869984128 | 2.174e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[997]` | 0.0465852084 | 0.04659034791 | 1.103e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[998]` | 0.04590034363 | 0.04589718221 | 6.888e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$sigma_usp_boot[999]` | 0.04606487961 | 0.04607584256 | 2.380e-04 | relatif, au-delà du seuil 1e-06 |
| `plots_data$boot_reperes$ic_bas` | 0.04481744239 | 0.04482070147 | 7.272e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$boot_reperes$ic_haut` | 0.05029606116 | 0.0502916293 | 8.812e-05 | relatif, au-delà du seuil 1e-06 |
| `plots_data$boot_reperes$moyenne` | 0.04753661106 | 0.04753647561 | 2.849e-06 | relatif, au-delà du seuil 1e-06 |
| `plots_data$usage_sigma["sigma"]` | sigma_(J-1) de la regle de minimum (D(5)(d)(ii)) : MSEP et … (69 car.) | sigma_(J-1) regle de minimum : MSEP, sigma_USP, replications |  | non numerique |
| `plots_data$usage_sigma["sigma_residus"]` | sigma_(J-1) estime directement : residus de Mack et tests | sigma_(J-1) direct : residus, tests, simulation (convention) |  | non numerique |

## Batteries

- `Rscript tests/test_reproductibilite.R` : code de sortie 0
  - `premium     sigma_USP = 0.1114524114  (15 s)`
  - `CONFORME : 57022 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve1    sigma_USP = 0.1073524114  (13 s)`
  - `CONFORME : 57021 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve2    sigma_USP = 0.0497764613  (22 s)`
  - `CONFORME : 18746 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_ii6 sigma_USP = 0.1483524114  (13 s)`
  - `CONFORME : 57022 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_net sigma_USP = 0.1032524114  (13 s)`
  - `CONFORME : 57022 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_interieur sigma_USP = 0.0871308679  (23 s)`
  - `CONFORME : 57022 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve2_trapeze sigma_USP = 0.0475797067  (20 s)`
  - `CONFORME : 18573 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `OK : reproductibilite et non-regression verifiees pour 7 cas.`
- `Rscript tests/test_unitaires.R` : code de sortie 0
  - `TOTAL : 4333 assertions, 4333 ok, 0 echec(s), 0 echec(s) attendu(s) (defauts connus), 0 succes inattendu(s)`
  - `OK`
