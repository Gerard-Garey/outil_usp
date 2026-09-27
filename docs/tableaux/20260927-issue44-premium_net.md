# Tableau avant / après — référence `premium_net` (issue #44)

- Date : 2026-09-27
- Plateforme : R version 4.3.1 (2023-06-16), Linux
- Commande : `Rscript tests/regenerer_et_rendre_compte.R premium --attendu '^tests\[\[(1|2|3|4|10|16|21|22|32|42)\]\]' --attendu '^tests\[\[[0-9]+\]\]($|\$p_min$)' --attendu '^bootstrap($|\$motif_mc)' reserve1 --attendu '^tests\[\[(1|2|3|4|10|16|21|22|32|42)\]\]' --attendu '^tests\[\[[0-9]+\]\]($|\$p_min$)' --attendu '^bootstrap($|\$motif_mc)' reserve2 --attendu '^tests\[\[[0-9]+\]\]($|\$p_min$)' --attendu '^bootstrap($|\$motif_mc)' premium_ii6 --attendu '^tests\[\[(1|2|3|4|10|16|21|22|32|42)\]\]' --attendu … (738 car.)`
- Motifs attendus : `^tests\[\[(1|2|3|4|10|16|21|22|32|42)\]\]`, `^tests\[\[[0-9]+\]\]($|\$p_min$)`, `^bootstrap($|\$motif_mc)`
- Exécution à plusieurs cas (M33) : `premium`, `reserve1`, `reserve2`, `premium_ii6`, `premium_net`, chacun avec ses motifs ; tout ou rien ; batteries relancées une seule fois, après le dernier cas
- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil 0 pour lister, seuil 1e-06 pour juger ; `INSTABLES` non neutralisé

**Synthèse** : 12420 feuille(s) dans l'ancienne référence, 12502 dans le résultat recalculé ; 122 non strictement identique(s) (dont 122 en écart au seuil 1e-06, 82 ajoutée(s), 0 supprimée(s)), toutes désignées par les motifs attendus ; 12380 feuille(s) identique(s) au bit près ; écart numérique maximal 2.247e-01 (relatif, `tests[[21]]$p_asymptotique`).

Nœuds de structure modifiés (type ou attributs) : `tests[[1]]`, `tests[[2]]`, `tests[[3]]`, `tests[[4]]`, `tests[[4]]$p_asymptotique`, `tests[[4]]$p_retenue`, `tests[[5]]`, `tests[[6]]`, `tests[[7]]`, `tests[[8]]`, `tests[[9]]`, `tests[[10]]`, `tests[[11]]`, `tests[[12]]`, `tests[[13]]`, `tests[[14]]`, `tests[[15]]`, `tests[[16]]`, `tests[[17]]`, `tests[[18]]`, `tests[[19]]`, `tests[[20]]`, `tests[[21]]`, `tests[[22]]`, `tests[[23]]`, `tests[[24]]`, `tests[[25]]`, `tests[[26]]`, `tests[[27]]`, `tests[[28]]`, `tests[[29]]`, `tests[[30]]`, `tests[[31]]`, `tests[[32]]`, `tests[[33]]`, `tests[[34]]`, `tests[[35]]`, `tests[[36]]`, `tests[[37]]`, `tests[[38]]`, `tests[[39]]`, `tests[[40]]`, `tests[[41]]`, `tests[[42]]`, `tests[[43]]`, `tests[[44]]`, `tests[[45]]`, `tests[[46]]`, `tests[[47]]`, `tests[[48]]`, `bootstrap`, `tests[[1]]$p_min`, `tests[[2]]$p_min`, `tests[[3]]$p_min`, `tests[[4]]$p_min`, `tests[[5]]$p_min`, `tests[[6]]$p_min`, `tests[[7]]$p_min`, `tests[[8]]$p_min`, `tests[[9]]$p_min`, `tests[[10]]$p_min`, `tests[[11]]$p_min`, `tests[[12]]$p_min`, `tests[[13]]$p_min`, `tests[[14]]$p_min`, `tests[[15]]$p_min`, `tests[[16]]$p_min`, `tests[[17]]$p_min`, `tests[[18]]$p_min`, `tests[[19]]$p_min`, `tests[[20]]$p_min`, `tests[[21]]$p_min`, `tests[[22]]$p_min`, `tests[[23]]$p_min`, `tests[[24]]$p_min`, `tests[[25]]$p_min`, `tests[[26]]$p_min`, `tests[[27]]$p_min`, `tests[[28]]$p_min`, `tests[[29]]$p_min`, `tests[[30]]$p_min`, `tests[[31]]$p_min`, `tests[[32]]$p_min`, `tests[[33]]$p_min`, `tests[[34]]$p_min`, `tests[[35]]$p_min`, `tests[[36]]$p_min`, `tests[[37]]$p_min`, `tests[[38]]$p_min`, `tests[[39]]$p_min`, `tests[[40]]$p_min`, `tests[[41]]$p_min`, `tests[[42]]$p_min`, `tests[[43]]$p_min`, `tests[[44]]$p_min`, `tests[[45]]$p_min`, `tests[[46]]$p_min`, `tests[[47]]$p_min`, `tests[[48]]$p_min`, `bootstrap$motif_mc`

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `tests[[1]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[2]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[3]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[4]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[5]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[6]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[7]]$p_min` | (absente) | 4.96031746e-05 |  | ajoutée (absente avant) |
| `tests[[8]]$p_min` | (absente) | 4.96031746e-05 |  | ajoutée (absente avant) |
| `tests[[9]]$p_min` | (absente) | 4.96031746e-05 |  | ajoutée (absente avant) |
| `tests[[10]]$p_min` | (absente) | 0.125 |  | ajoutée (absente avant) |
| `tests[[11]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[12]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[13]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[14]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[15]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[16]]$p_min` | (absente) | 0.02857142857 |  | ajoutée (absente avant) |
| `tests[[17]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[18]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[19]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[20]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[21]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[22]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[23]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[24]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[25]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[26]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[27]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[28]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[29]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[30]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[31]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[32]]$p_min` | (absente) | 0.05714285714 |  | ajoutée (absente avant) |
| `tests[[33]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[34]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[35]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[36]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[37]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[38]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[39]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[40]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[41]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[42]]$p_min` | (absente) | 0.05714285714 |  | ajoutée (absente avant) |
| `tests[[43]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[44]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[45]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[46]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[47]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[48]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["AD"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["CvM"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["KS"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["SW"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["SF"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["JB"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["DW"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["LB1"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["supF"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["CUSUM"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["Grubbs"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["Lillie"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["Intercept"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["RESET"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["BP"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["BP79"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["White"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["GQ"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["BF"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["Smirnov"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["LB2"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["BP2"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["Runs"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["MK"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["SpearVol"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["SpearTps"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["DAgo"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["CoxStuart"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["DWr"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["LB1r"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["Runsr"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["supFr"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["CUSUMr"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["Grubbsr"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[1]]$loi` | t(6) EXACTE sous normalite des erreurs | t(6) exacte sous le modele auxiliaire MCO seulement (erreur… (134 car.) |  | non numerique |
| `tests[[1]]$p_exacte` | 0.9377844203 | \<NA\> |  | non fini |
| `tests[[1]]$p_asymptotique` | \<NA\> | 0.9377844203 |  | non fini |
| `tests[[1]]$p_retenue` | 0.9377844203 | 0.944 | 6.628e-03 | relatif, au-delà du seuil 1e-06 |
| `tests[[1]]$nature_p` | exacte | Monte-Carlo (bootstrap parametrique) |  | non numerique |
| `tests[[2]]$loi` | t(6) ; marge estimee sur les donnees -> exactitude approchee | t(6) sous le modele auxiliaire MCO ; marge estimee sur les … (90 car.) |  | non numerique |
| `tests[[2]]$nature_p` | quasi-exacte (loi de Student ; marge estimee sur les donnee… (61 car.) | sous le modele auxiliaire MCO : loi de Student, marge estim… (77 car.) |  | non numerique |
| `tests[[3]]$type` | test | diagnostic |  | non numerique |
| `tests[[3]]$loi` | t(6) | t(6) exacte sous le modele auxiliaire MCO (erreurs i.i.d. n… (84 car.) |  | non numerique |
| `tests[[3]]$p_retenue` | 0.2133906175 | \<NA\> |  | non fini |
| `tests[[3]]$nature_p` | asymptotique (H0 non simulable : le modele ajuste appartien… (66 car.) | \<NA\> |  | non numerique |
| `tests[[3]]$verdict` | ALERTE | INFO |  | non numerique |
| `tests[[3]]$detail` | Loi EXACTE sous normalite des erreurs. Ici on souhaite REJE… (65 car.) | Ici on souhaite REJETER H0. PENTE NON IDENTIFIABLE PAR LES … (277 car.) |  | non numerique |
| `tests[[3]]$sens` | rejeter | \<NA\> |  | non numerique |
| `tests[[4]]$type` | test | diagnostic |  | non numerique |
| `tests[[4]]$loi` | F(1,6) | F(1,6) exacte sous le modele auxiliaire MCO |  | non numerique |
| `tests[[4]]$p_asymptotique` | 0.2133906175 | 0.2133906175 |  | non numerique |
| `tests[[4]]$p_retenue` | 0.2133906175 | \<NA\> |  | non numerique |
| `tests[[4]]$nature_p` | asymptotique (H0 non simulable : le modele ajuste appartien… (66 car.) | \<NA\> |  | non numerique |
| `tests[[4]]$verdict` | ALERTE | INFO |  | non numerique |
| `tests[[4]]$detail` | Loi EXACTE sous normalite. Equivaut a t^2 en regression sim… (62 car.) | Equivaut a t^2 en regression simple. PENTE NON IDENTIFIABLE… (286 car.) |  | non numerique |
| `tests[[4]]$sens` | rejeter | \<NA\> |  | non numerique |
| `tests[[10]]$type` | test | diagnostic |  | non numerique |
| `tests[[10]]$p_retenue` | 1 | \<NA\> |  | non fini |
| `tests[[10]]$nature_p` | exacte | \<NA\> |  | non numerique |
| `tests[[10]]$verdict` | OK | INFO |  | non numerique |
| `tests[[10]]$detail` | m = 4 paires ; p bilaterale minimale atteignable = 0.1250 | TEST INOPERANT au seuil alpha = 0.1 : p-value minimale atte… (147 car.) |  | non numerique |
| `tests[[10]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[16]]$detail` | Voir aussi le QQ-plot a deux echantillons | Voir aussi le QQ-plot a deux echantillons ; p-value minimal… (146 car.) |  | non numerique |
| `tests[[21]]$loi` | loi AD, cas parametres estimes ; approximation de Stephens | loi AD, cas parametres estimes ; p non simulee : ajustement… (176 car.) |  | non numerique |
| `tests[[21]]$estim_nom` | \<NA\> | A2 sur (z - zbar)/s_z |  | non numerique |
| `tests[[21]]$estim` | \<NA\> | 0.2858759703 |  | non fini |
| `tests[[21]]$p_asymptotique` | 0.4305348121 | 0.5272932844 | 2.247e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[21]]$detail` | Sensible aux queues. p non simulee disponible : ajustement … (101 car.) | Sensible aux queues. p non simulee : ajustement empirique d… (125 car.) |  | non numerique |
| `tests[[22]]$loi` | loi CvM, cas parametres estimes ; approximation de Stephens | loi CvM, cas parametres estimes ; p non simulee : ajustemen… (177 car.) |  | non numerique |
| `tests[[22]]$estim_nom` | \<NA\> | W2 sur (z - zbar)/s_z |  | non numerique |
| `tests[[22]]$estim` | \<NA\> | 0.04910009994 |  | non fini |
| `tests[[22]]$p_asymptotique` | 0.3976922995 | 0.4800226104 | 2.070e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[32]]$detail` |  | ECHEC inatteignable : p_min = 0.0571 >= alpha/2 = 0.05 (n1 … (71 car.) |  | non numerique |
| `tests[[42]]$detail` | …ur Monte-Carlo pres. (770 car., 1re différence au car. 771) | …ur Monte-Carlo pres. ECHEC inatteignable : p_min = 0.0571 >=… (842 car., 1re différence au car. 771) |  | non numerique |

## Batteries

- `Rscript tests/test_reproductibilite.R` : code de sortie 0
  - `premium     sigma_USP = 0.1114524359  (25 s)`
  - `CONFORME : 12502 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve1    sigma_USP = 0.1073524359  (21 s)`
  - `CONFORME : 12501 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve2    sigma_USP = 0.0497764613  (76 s)`
  - `CONFORME : 4289 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_ii6 sigma_USP = 0.1483524359  (21 s)`
  - `CONFORME : 12502 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_net sigma_USP = 0.1032524359  (21 s)`
  - `CONFORME : 12502 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `OK : reproductibilite et non-regression verifiees pour 5 cas.`
- `Rscript tests/test_unitaires.R` : code de sortie 0
  - `TOTAL : 918 assertions, 918 ok, 0 echec(s), 0 echec(s) attendu(s) (defauts connus), 0 succes inattendu(s)`
  - `OK`
