# Tableau avant / après — référence `premium_interieur` (issue #302)

- Date : 2026-10-19
- Plateforme : R version 4.3.1 (2023-06-16), Linux
- Commande : `Rscript tests/regenerer_et_rendre_compte.R premium --attendu '^tests\[\[(19|[23][0-9]|4[0-7])\]\]' --attendu '^tests\[\[(4[89]|50)\]\]' --attendu '^bootstrap\$[A-Za-z_]+(\$(LB1|BP2)|\["(LB1|BP2)"\])$' premium_net --attendu '^tests\[\[(19|[23][0-9]|4[0-7])\]\]' --attendu '^tests\[\[(4[89]|50)\]\]' --attendu '^bootstrap\$[A-Za-z_]+(\$(LB1|BP2)|\["(LB1|BP2)"\])$' premium_ii6 --attendu '^tests\[\[(19|[23][0-9]|4[0-7])\]\]' --attendu '^tests\[\[(4[89]|50)\]\]' --attendu '^bootstrap\$[A-Za-z_]+(\$(LB… (875 car.)`
- Motifs attendus : `^tests\[\[(1[89]|[23][0-9]|4[0-7])\]\]`, `^tests\[\[(4[89]|50)\]\]`, `^bootstrap\$[A-Za-z_]+(\$(LB1|BP2)|\["(LB1|BP2)"\])$`
- Exécution à plusieurs cas (M33) : `premium`, `premium_net`, `premium_ii6`, `reserve1`, `premium_interieur`, chacun avec ses motifs ; tout ou rien ; batteries relancées une seule fois, après le dernier cas
- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil 0 pour lister, seuil 1e-06 pour juger ; `INSTABLES` non neutralisé

**Synthèse** : 23807 feuille(s) dans l'ancienne référence, 23715 dans le résultat recalculé ; 578 non strictement identique(s) (dont 578 en écart au seuil 1e-06, 0 ajoutée(s), 92 supprimée(s)), toutes désignées par les motifs attendus ; 23229 feuille(s) identique(s) au bit près ; écart numérique maximal 5.267e+00 (relatif, `tests[[26]]$estim`).

**Avertissement** : motif `^tests\[\[(1[89]|[23][0-9]|4[0-7])\]\]` : 486 feuilles désignées (seuil d'avertissement 50) ; vérifier qu'il n'est pas trop large.
**Avertissement** : motif `^tests\[\[(4[89]|50)\]\]` : 78 feuilles désignées (seuil d'avertissement 50) ; vérifier qu'il n'est pas trop large.

Nœuds de structure modifiés (type ou attributs) : `tests[[34]]$estim`, `tests[[37]]$estim`, `tests[[41]]$estim`, `tests[[44]]$estim`, `tests[[48]]`, `tests[[48]]$famille`, `tests[[48]]$test`, `tests[[48]]$reference`, `tests[[48]]$type`, `tests[[48]]$base`, `tests[[48]]$variante`, `tests[[48]]$H0`, `tests[[48]]$H1`, `tests[[48]]$stat_nom`, `tests[[48]]$stat`, `tests[[48]]$loi`, `tests[[48]]$estim_nom`, `tests[[48]]$estim`, `tests[[48]]$p_exacte`, `tests[[48]]$p_asymptotique`, `tests[[48]]$p_mc`, `tests[[48]]$err_mc`, `tests[[48]]$p_retenue`, `tests[[48]]$nature_p`, `tests[[48]]$verdict`, `tests[[48]]$detail`, `tests[[48]]$sens`, `tests[[48]]$p_min`, `tests[[48]]$fonction`, `tests[[48]]$inoperant`, `tests[[48]]$p_min_mc`, `tests[[49]]`, `tests[[49]]$famille`, `tests[[49]]$test`, `tests[[49]]$reference`, `tests[[49]]$type`, `tests[[49]]$base`, `tests[[49]]$variante`, `tests[[49]]$H0`, `tests[[49]]$H1`, `tests[[49]]$stat_nom`, `tests[[49]]$stat`, `tests[[49]]$loi`, `tests[[49]]$estim_nom`, `tests[[49]]$estim`, `tests[[49]]$p_exacte`, `tests[[49]]$p_asymptotique`, `tests[[49]]$p_mc`, `tests[[49]]$err_mc`, `tests[[49]]$p_retenue`, `tests[[49]]$nature_p`, `tests[[49]]$verdict`, `tests[[49]]$detail`, `tests[[49]]$sens`, `tests[[49]]$p_min`, `tests[[49]]$fonction`, `tests[[49]]$inoperant`, `tests[[49]]$p_min_mc`, `tests[[50]]`, `tests[[50]]$famille`, `tests[[50]]$test`, `tests[[50]]$reference`, `tests[[50]]$type`, `tests[[50]]$base`, `tests[[50]]$variante`, `tests[[50]]$H0`, `tests[[50]]$H1`, `tests[[50]]$stat_nom`, `tests[[50]]$stat`, `tests[[50]]$loi`, `tests[[50]]$estim_nom`, `tests[[50]]$estim`, `tests[[50]]$p_exacte`, `tests[[50]]$p_asymptotique`, `tests[[50]]$p_mc`, `tests[[50]]$err_mc`, `tests[[50]]$p_retenue`, `tests[[50]]$nature_p`, `tests[[50]]$verdict`, `tests[[50]]$detail`, `tests[[50]]$sens`, `tests[[50]]$p_min`, `tests[[50]]$fonction`, `tests[[50]]$inoperant`, `tests[[50]]$p_min_mc`, `bootstrap$stats_obs`, `bootstrap$stats_obs$LB1`, `bootstrap$stats_obs$BP2`, `bootstrap$p_mc`, `bootstrap$err_mc`, `bootstrap$B_effectif`, `bootstrap$granularite_stat`, `bootstrap$motif_mc`, `bootstrap$p_min_mc`

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `tests[[48]]$famille` | G. Robustesse de l'estimation | (absente) |  | supprimée (absente après) |
| `tests[[48]]$test` | Largeur relative de l'IC bootstrap 90% (delta fixe a delta … (66 car.) | (absente) |  | supprimée (absente après) |
| `tests[[48]]$reference` | Efron (1979), Ann. Statist. 7 ; Andrews (2000), Econometric… (63 car.) | (absente) |  | supprimée (absente après) |
| `tests[[48]]$type` | diagnostic | (absente) |  | supprimée (absente après) |
| `tests[[48]]$base` | commun | (absente) |  | supprimée (absente après) |
| `tests[[48]]$variante` | principale | (absente) |  | supprimée (absente après) |
| `tests[[48]]$H0` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[48]]$H1` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[48]]$stat_nom` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[48]]$stat` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[48]]$loi` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[48]]$estim_nom` | largeur / sigma_USP | (absente) |  | supprimée (absente après) |
| `tests[[48]]$estim` | 0.4531181242 | (absente) |  | supprimée (absente après) |
| `tests[[48]]$p_exacte` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[48]]$p_asymptotique` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[48]]$p_mc` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[48]]$err_mc` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[48]]$p_retenue` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[48]]$nature_p` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[48]]$verdict` | INFO | (absente) |  | supprimée (absente après) |
| `tests[[48]]$detail` | Bootstrap parametrique a delta fixe a sa valeur estimee (se… (449 car.) | (absente) |  | supprimée (absente après) |
| `tests[[48]]$sens` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[48]]$p_min` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[48]]$fonction` | run_engine | (absente) |  | supprimée (absente après) |
| `tests[[48]]$inoperant` | FALSE | (absente) |  | supprimée (absente après) |
| `tests[[48]]$p_min_mc` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[49]]$famille` | G. Robustesse de l'estimation | (absente) |  | supprimée (absente après) |
| `tests[[49]]$test` | Rapport de vraisemblance : delta = 0 (variance lineaire en … (66 car.) | (absente) |  | supprimée (absente après) |
| `tests[[49]]$reference` | Chernoff (1954) ; Self & Liang (1987), JASA 82 ; Davison & … (82 car.) | (absente) |  | supprimée (absente après) |
| `tests[[49]]$type` | diagnostic | (absente) |  | supprimée (absente après) |
| `tests[[49]]$base` | commun | (absente) |  | supprimée (absente après) |
| `tests[[49]]$variante` | principale | (absente) |  | supprimée (absente après) |
| `tests[[49]]$H0` | delta = 0 (variance proportionnelle au volume) | (absente) |  | supprimée (absente après) |
| `tests[[49]]$H1` | delta > 0 | (absente) |  | supprimée (absente après) |
| `tests[[49]]$stat_nom` | LR(0) | (absente) |  | supprimée (absente après) |
| `tests[[49]]$stat` | 0.1649016946 | (absente) |  | supprimée (absente après) |
| `tests[[49]]$loi` | sous H0 : loi simulee par bootstrap parametrique restreint … (172 car.) | (absente) |  | supprimée (absente après) |
| `tests[[49]]$estim_nom` | sigma(delta0, gamma~) | (absente) |  | supprimée (absente après) |
| `tests[[49]]$estim` | 0.06676040344 | (absente) |  | supprimée (absente après) |
| `tests[[49]]$p_exacte` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[49]]$p_asymptotique` | 0.3423415808 | (absente) |  | supprimée (absente après) |
| `tests[[49]]$p_mc` | 0.289 | (absente) |  | supprimée (absente après) |
| `tests[[49]]$err_mc` | 0.01434171136 | (absente) |  | supprimée (absente après) |
| `tests[[49]]$p_retenue` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[49]]$nature_p` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[49]]$verdict` | INFO | (absente) |  | supprimée (absente après) |
| `tests[[49]]$detail` | Aucun verdict (ADR 0001) : le LR mesure si les donnees dist… (420 car.) | (absente) |  | supprimée (absente après) |
| `tests[[49]]$sens` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[49]]$p_min` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[49]]$fonction` | usp_lr_delta | (absente) |  | supprimée (absente après) |
| `tests[[49]]$inoperant` | FALSE | (absente) |  | supprimée (absente après) |
| `tests[[49]]$p_min_mc` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[50]]$famille` | G. Robustesse de l'estimation | (absente) |  | supprimée (absente après) |
| `tests[[50]]$test` | Rapport de vraisemblance : delta = 1 (variance quadratique … (69 car.) | (absente) |  | supprimée (absente après) |
| `tests[[50]]$reference` | Chernoff (1954) ; Self & Liang (1987), JASA 82 ; Davison & … (82 car.) | (absente) |  | supprimée (absente après) |
| `tests[[50]]$type` | diagnostic | (absente) |  | supprimée (absente après) |
| `tests[[50]]$base` | commun | (absente) |  | supprimée (absente après) |
| `tests[[50]]$variante` | principale | (absente) |  | supprimée (absente après) |
| `tests[[50]]$H0` | delta = 1 (variance proportionnelle au carre du volume) | (absente) |  | supprimée (absente après) |
| `tests[[50]]$H1` | delta < 1 | (absente) |  | supprimée (absente après) |
| `tests[[50]]$stat_nom` | LR(1) | (absente) |  | supprimée (absente après) |
| `tests[[50]]$stat` | 0.141073731 | (absente) |  | supprimée (absente après) |
| `tests[[50]]$loi` | sous H0 : loi simulee par bootstrap parametrique restreint … (172 car.) | (absente) |  | supprimée (absente après) |
| `tests[[50]]$estim_nom` | sigma(delta0, gamma~) | (absente) |  | supprimée (absente après) |
| `tests[[50]]$estim` | 0.07261597231 | (absente) |  | supprimée (absente après) |
| `tests[[50]]$p_exacte` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[50]]$p_asymptotique` | 0.3536079516 | (absente) |  | supprimée (absente après) |
| `tests[[50]]$p_mc` | 0.411 | (absente) |  | supprimée (absente après) |
| `tests[[50]]$err_mc` | 0.01556667342 | (absente) |  | supprimée (absente après) |
| `tests[[50]]$p_retenue` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[50]]$nature_p` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[50]]$verdict` | INFO | (absente) |  | supprimée (absente après) |
| `tests[[50]]$detail` | Aucun verdict (ADR 0001) : le LR mesure si les donnees dist… (420 car.) | (absente) |  | supprimée (absente après) |
| `tests[[50]]$sens` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[50]]$p_min` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[50]]$fonction` | usp_lr_delta | (absente) |  | supprimée (absente après) |
| `tests[[50]]$inoperant` | FALSE | (absente) |  | supprimée (absente après) |
| `tests[[50]]$p_min_mc` | \<NA\> | (absente) |  | supprimée (absente après) |
| `bootstrap$stats_obs$LB1` | 1.154374408 | (absente) |  | supprimée (absente après) |
| `bootstrap$stats_obs$BP2` | 2.077142294 | (absente) |  | supprimée (absente après) |
| `bootstrap$p_mc["LB1"]` | 0.29 | (absente) |  | supprimée (absente après) |
| `bootstrap$p_mc["BP2"]` | 0.235 | (absente) |  | supprimée (absente après) |
| `bootstrap$err_mc["LB1"]` | 0.014356396 | (absente) |  | supprimée (absente après) |
| `bootstrap$err_mc["BP2"]` | 0.01341472903 | (absente) |  | supprimée (absente après) |
| `bootstrap$B_effectif["LB1"]` | 999 | (absente) |  | supprimée (absente après) |
| `bootstrap$B_effectif["BP2"]` | 999 | (absente) |  | supprimée (absente après) |
| `bootstrap$granularite_stat["LB1"]` | 0.001 | (absente) |  | supprimée (absente après) |
| `bootstrap$granularite_stat["BP2"]` | 0.001 | (absente) |  | supprimée (absente après) |
| `bootstrap$motif_mc["LB1"]` | \<NA\> | (absente) |  | supprimée (absente après) |
| `bootstrap$motif_mc["BP2"]` | \<NA\> | (absente) |  | supprimée (absente après) |
| `bootstrap$p_min_mc["LB1"]` | \<NA\> | (absente) |  | supprimée (absente après) |
| `bootstrap$p_min_mc["BP2"]` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[18]]$detail` |  | p non simulee etablie pour un echantillon i.i.d. normal, qu… (151 car.) |  | non numerique |
| `tests[[19]]$test` | Shapiro-Wilk (loi nulle simulee, sans normalisation de Roys… (63 car.) | Shapiro-Francia |  | non numerique |
| `tests[[19]]$reference` | Shapiro & Wilk (1965) ; loi nulle evaluee par simulation di… (64 car.) | Shapiro & Francia (1972), JASA 67 ; Royston (1993) |  | non numerique |
| `tests[[19]]$type` | non applicable | test |  | non numerique |
| `tests[[19]]$variante` | secondaire | principale |  | non numerique |
| `tests[[19]]$stat_nom` | W | W' |  | non numerique |
| `tests[[19]]$stat` | 0.9516450677 | 0.9512124759 | 4.546e-04 | relatif, au-delà du seuil 1e-06 |
| `tests[[19]]$loi` | loi exacte de W sous normalite, evaluee numeriquement (20 0… (70 car.) | aucune forme fermee ; normalisation de Royston (1993) |  | non numerique |
| `tests[[19]]$p_asymptotique` | \<NA\> | 0.7162715023 |  | non fini |
| `tests[[19]]$p_mc` | \<NA\> | 0.65 |  | non fini |
| `tests[[19]]$err_mc` | \<NA\> | 0.01509065034 |  | non fini |
| `tests[[19]]$p_retenue` | \<NA\> | 0.65 |  | non fini |
| `tests[[19]]$nature_p` | \<NA\> | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) |  | non numerique |
| `tests[[19]]$verdict` | INFO | OK |  | non numerique |
| `tests[[19]]$detail` | loi nulle i.i.d. sans objet a pi_t variable (W(P epsilon) n… (167 car.) | p non simulee etablie pour un echantillon i.i.d. normal, qu… (151 car.) |  | non numerique |
| `tests[[19]]$sens` | \<NA\> | ne pas rejeter |  | non numerique |
| `tests[[19]]$fonction` | .shapiro_sur | test_shapiro_francia |  | non numerique |
| `tests[[20]]$test` | Shapiro-Francia | Anderson-Darling |  | non numerique |
| `tests[[20]]$reference` | Shapiro & Francia (1972), JASA 67 ; Royston (1993) | Anderson & Darling (1954), JASA 49 |  | non numerique |
| `tests[[20]]$stat_nom` | W' | A2 |  | non numerique |
| `tests[[20]]$stat` | 0.9512124759 | 0.2545970281 | 7.323e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[20]]$loi` | aucune forme fermee ; normalisation de Royston (1993) | loi AD, cas parametres estimes ; p non simulee : ajustement… (176 car.) |  | non numerique |
| `tests[[20]]$estim_nom` | \<NA\> | A2 sur (z - zbar)/s_z |  | non numerique |
| `tests[[20]]$estim` | \<NA\> | 0.2348745239 |  | non fini |
| `tests[[20]]$p_asymptotique` | 0.7162715023 | 0.6941127037 | 3.094e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[20]]$p_mc` | 0.65 | 0.795 | 2.231e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[20]]$err_mc` | 0.01509065034 | 0.0127725541 | 1.536e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[20]]$p_retenue` | 0.65 | 0.795 | 2.231e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[20]]$detail` |  | Sensible aux queues. p non simulee : ajustement empirique d… (277 car.) |  | non numerique |
| `tests[[20]]$fonction` | test_shapiro_francia | stat_ad |  | non numerique |
| `tests[[21]]$test` | Anderson-Darling | Cramer-von Mises |  | non numerique |
| `tests[[21]]$reference` | Anderson & Darling (1954), JASA 49 | Cramer (1928) / von Mises (1928) ; Stephens (1974) |  | non numerique |
| `tests[[21]]$type` | test | diagnostic |  | non numerique |
| `tests[[21]]$stat_nom` | A2 | W2 |  | non numerique |
| `tests[[21]]$stat` | 0.2545970281 | 0.03449000726 | 8.645e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[21]]$loi` | loi AD, cas parametres estimes ; p non simulee : ajustement… (176 car.) | loi CvM, cas parametres estimes ; p non simulee : ajustemen… (177 car.) |  | non numerique |
| `tests[[21]]$estim_nom` | A2 sur (z - zbar)/s_z | W2 sur (z - zbar)/s_z |  | non numerique |
| `tests[[21]]$estim` | 0.2348745239 | 0.03433215839 | 8.538e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[21]]$p_asymptotique` | 0.6941127037 | 0.7458521082 | 7.454e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[21]]$p_mc` | 0.795 | 0.823 | 3.522e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[21]]$err_mc` | 0.0127725541 | 0.01207546342 | 5.458e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[21]]$p_retenue` | 0.795 | \<NA\> |  | non fini |
| `tests[[21]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[21]]$verdict` | OK | INFO |  | non numerique |
| `tests[[21]]$detail` | Sensible aux queues. p non simulee : ajustement empirique d… (125 car.) | p non simulee etablie pour un echantillon i.i.d. normal, qu… (353 car.) |  | non numerique |
| `tests[[21]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[21]]$fonction` | stat_ad | stat_cvm |  | non numerique |
| `tests[[22]]$test` | Cramer-von Mises | Kolmogorov-Smirnov contre N(0,1) |  | non numerique |
| `tests[[22]]$reference` | Cramer (1928) / von Mises (1928) ; Stephens (1974) | Kolmogorov (1933) ; Smirnov (1948) |  | non numerique |
| `tests[[22]]$type` | test | diagnostic |  | non numerique |
| `tests[[22]]$variante` | principale | secondaire |  | non numerique |
| `tests[[22]]$stat_nom` | W2 | D |  | non numerique |
| `tests[[22]]$stat` | 0.03449000726 | 0.1786862773 | 4.181e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[22]]$loi` | loi CvM, cas parametres estimes ; p non simulee : ajustemen… (177 car.) | loi de Kolmogorov (valable a parametres CONNUS) |  | non numerique |
| `tests[[22]]$estim_nom` | W2 sur (z - zbar)/s_z | \<NA\> |  | non numerique |
| `tests[[22]]$estim` | 0.03433215839 | \<NA\> |  | non fini |
| `tests[[22]]$p_asymptotique` | 0.7458521082 | 0.9603851023 | 2.876e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[22]]$p_mc` | 0.823 | 0.695 | 1.555e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[22]]$err_mc` | 0.01207546342 | 0.01456664639 | 2.063e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[22]]$p_retenue` | 0.823 | \<NA\> |  | non fini |
| `tests[[22]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[22]]$verdict` | OK | INFO |  | non numerique |
| `tests[[22]]$detail` |  | Les residus sont standardises par le MODELE, non par la moy… (550 car.) |  | non numerique |
| `tests[[22]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[22]]$fonction` | stat_cvm | stat_ks |  | non numerique |
| `tests[[23]]$test` | Kolmogorov-Smirnov contre N(0,1) | Lilliefors (KS a parametres estimes) |  | non numerique |
| `tests[[23]]$reference` | Kolmogorov (1933) ; Smirnov (1948) | Lilliefors (1967), JASA 62 ; p-value : Dallal & Wilkinson (… (64 car.) |  | non numerique |
| `tests[[23]]$variante` | secondaire | principale |  | non numerique |
| `tests[[23]]$stat` | 0.1786862773 | 0.1786360997 | 2.808e-04 | relatif, au-delà du seuil 1e-06 |
| `tests[[23]]$loi` | loi de Kolmogorov (valable a parametres CONNUS) | loi de Lilliefors (moyenne et ecart-type estimes) |  | non numerique |
| `tests[[23]]$p_asymptotique` | 0.9603851023 | 0.6360477573 | 3.377e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[23]]$p_mc` | 0.695 | 0.606 | 1.281e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[23]]$err_mc` | 0.01456664639 | 0.01545972196 | 6.131e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[23]]$p_retenue` | 0.695 | 0.606 | 1.281e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[23]]$detail` | Les residus sont standardises par le MODELE, non par la moy… (216 car.) | Distinct du KS contre N(0,1) : la loi de reference tient co… (329 car.) |  | non numerique |
| `tests[[23]]$fonction` | stat_ks | stat_lilliefors |  | non numerique |
| `tests[[24]]$test` | Lilliefors (KS a parametres estimes) | Jarque-Bera |  | non numerique |
| `tests[[24]]$reference` | Lilliefors (1967), JASA 62 ; p-value : Dallal & Wilkinson (… (64 car.) | Jarque & Bera (1980, 1987) |  | non numerique |
| `tests[[24]]$H0` | les residus standardises suivent une loi normale | asymetrie nulle ET aplatissement egal a 3 |  | non numerique |
| `tests[[24]]$H1` | loi non normale | asymetrie ou aplatissement non normaux |  | non numerique |
| `tests[[24]]$stat_nom` | D | JB |  | non numerique |
| `tests[[24]]$stat` | 0.1786360997 | 0.2975763686 | 6.658e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[24]]$loi` | loi de Lilliefors (moyenne et ecart-type estimes) | chi2(2) asymptotique |  | non numerique |
| `tests[[24]]$p_asymptotique` | 0.6360477573 | 0.8617516281 | 3.549e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[24]]$p_mc` | 0.606 | 0.862 | 4.224e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[24]]$err_mc` | 0.01545972196 | 0.01091215263 | 2.942e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[24]]$p_retenue` | 0.606 | 0.862 | 4.224e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[24]]$detail` | Distinct du KS contre N(0,1) : la loi de reference tient co… (177 car.) | asymetrie et aplatissement : estimations des lignes D'Agost… (281 car.) |  | non numerique |
| `tests[[24]]$fonction` | stat_lilliefors | test_jarque_bera |  | non numerique |
| `tests[[25]]$test` | Jarque-Bera | Asymetrie (D'Agostino, T >= 8) |  | non numerique |
| `tests[[25]]$reference` | Jarque & Bera (1980, 1987) | D'Agostino (1970), Biometrika 57 |  | non numerique |
| `tests[[25]]$H0` | asymetrie nulle ET aplatissement egal a 3 | coefficient d'asymetrie de la population nul |  | non numerique |
| `tests[[25]]$H1` | asymetrie ou aplatissement non normaux | asymetrie non nulle |  | non numerique |
| `tests[[25]]$stat_nom` | JB | Z |  | non numerique |
| `tests[[25]]$stat` | 0.2975763686 | 0.6675390096 | 1.243e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[25]]$loi` | chi2(2) asymptotique | N(0,1) approx. (transformation de Johnson SU) |  | non numerique |
| `tests[[25]]$estim_nom` | \<NA\> | asymetrie |  | non numerique |
| `tests[[25]]$estim` | \<NA\> | 0.3970065247 |  | non fini |
| `tests[[25]]$p_asymptotique` | 0.8617516281 | 0.5044279008 | 4.146e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[25]]$p_mc` | 0.862 | 0.334 | 6.125e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[25]]$err_mc` | 0.01091215263 | 0.02360086865 | 1.163e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[25]]$p_retenue` | 0.862 | 0.334 | 6.125e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[25]]$detail` | asymetrie et aplatissement : estimations des lignes D'Agost… (127 car.) | p non simulee etablie pour un echantillon i.i.d. normal, qu… (151 car.) |  | non numerique |
| `tests[[25]]$fonction` | test_jarque_bera | test_dagostino_skew |  | non numerique |
| `tests[[26]]$test` | Asymetrie (D'Agostino, T >= 8) | Aplatissement (Anscombe-Glynn, T >= 20) |  | non numerique |
| `tests[[26]]$reference` | D'Agostino (1970), Biometrika 57 | Anscombe & Glynn (1983), Biometrika 70 |  | non numerique |
| `tests[[26]]$type` | test | non applicable |  | non numerique |
| `tests[[26]]$H0` | coefficient d'asymetrie de la population nul | \<NA\> |  | non numerique |
| `tests[[26]]$H1` | asymetrie non nulle | \<NA\> |  | non numerique |
| `tests[[26]]$stat_nom` | Z | \<NA\> |  | non numerique |
| `tests[[26]]$stat` | 0.6675390096 | \<NA\> |  | non fini |
| `tests[[26]]$loi` | N(0,1) approx. (transformation de Johnson SU) | \<NA\> |  | non numerique |
| `tests[[26]]$estim_nom` | asymetrie | aplatissement |  | non numerique |
| `tests[[26]]$estim` | 0.3970065247 | 2.487874641 | 5.267e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[26]]$p_asymptotique` | 0.5044279008 | \<NA\> |  | non fini |
| `tests[[26]]$p_mc` | 0.334 | \<NA\> |  | non fini |
| `tests[[26]]$err_mc` | 0.02360086865 | \<NA\> |  | non fini |
| `tests[[26]]$p_retenue` | 0.334 | \<NA\> |  | non fini |
| `tests[[26]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[26]]$verdict` | OK | INFO |  | non numerique |
| `tests[[26]]$detail` |  | T = 8 < 20 : test non defini |  | non numerique |
| `tests[[26]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[26]]$fonction` | test_dagostino_skew | test_anscombe_kurt |  | non numerique |
| `tests[[27]]$famille` | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | E. H4 - independance et validite du MV (annexe XVII B(2)(g)… (64 car.) |  | non numerique |
| `tests[[27]]$test` | Aplatissement (Anscombe-Glynn, T >= 20) | Autocorrelation d'ordre 1 (Durbin-Watson) |  | non numerique |
| `tests[[27]]$reference` | Anscombe & Glynn (1983), Biometrika 70 | Durbin & Watson (1950, 1951) |  | non numerique |
| `tests[[27]]$type` | non applicable | test |  | non numerique |
| `tests[[27]]$base` | commun | z |  | non numerique |
| `tests[[27]]$H0` | \<NA\> | rho = 0 (absence d'autocorrelation d'ordre 1) |  | non numerique |
| `tests[[27]]$H1` | \<NA\> | rho != 0 |  | non numerique |
| `tests[[27]]$stat_nom` | \<NA\> | DW |  | non numerique |
| `tests[[27]]$stat` | \<NA\> | 2.428176394 |  | non fini |
| `tests[[27]]$loi` | \<NA\> | forme quadratique en normales ; loi par la methode d'Imhof … (110 car.) |  | non numerique |
| `tests[[27]]$estim_nom` | aplatissement | \<NA\> |  | non numerique |
| `tests[[27]]$estim` | 2.487874641 | \<NA\> |  | non fini |
| `tests[[27]]$p_mc` | \<NA\> | 0.39 |  | non fini |
| `tests[[27]]$err_mc` | \<NA\> | 0.02507047125 |  | non fini |
| `tests[[27]]$p_retenue` | \<NA\> | 0.39 |  | non fini |
| `tests[[27]]$nature_p` | \<NA\> | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) |  | non numerique |
| `tests[[27]]$verdict` | INFO | OK |  | non numerique |
| `tests[[27]]$detail` | T = 8 < 20 : test non defini | p exacte non attribuee : loi de reference exacte seulement … (319 car.) |  | non numerique |
| `tests[[27]]$sens` | \<NA\> | ne pas rejeter |  | non numerique |
| `tests[[27]]$fonction` | test_anscombe_kurt | stat_dw |  | non numerique |
| `tests[[28]]$test` | Autocorrelation d'ordre 1 (Durbin-Watson) | Ljung-Box (retard 2) |  | non numerique |
| `tests[[28]]$reference` | Durbin & Watson (1950, 1951) | Ljung & Box (1978), Biometrika 65 |  | non numerique |
| `tests[[28]]$base` | z | commun |  | non numerique |
| `tests[[28]]$H0` | rho = 0 (absence d'autocorrelation d'ordre 1) | rho_1 = rho_2 = 0 |  | non numerique |
| `tests[[28]]$H1` | rho != 0 | autocorrelation jusqu'au retard 2 |  | non numerique |
| `tests[[28]]$stat_nom` | DW | Q |  | non numerique |
| `tests[[28]]$stat` | 2.428176394 | 3.269508088 | 3.465e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[28]]$loi` | forme quadratique en normales ; loi par la methode d'Imhof … (110 car.) | chi2(2) asymptotique |  | non numerique |
| `tests[[28]]$p_asymptotique` | \<NA\> | 0.1950003269 |  | non fini |
| `tests[[28]]$p_mc` | 0.39 | 0.22 | 4.359e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[28]]$err_mc` | 0.02507047125 | 0.01310617304 | 4.772e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[28]]$p_retenue` | 0.39 | 0.22 | 4.359e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[28]]$detail` | p exacte non attribuee : loi de reference exacte seulement … (319 car.) |  |  | non numerique |
| `tests[[28]]$fonction` | stat_dw | usp_tests |  | non numerique |
| `tests[[29]]$test` | Ljung-Box (retard 1) | Test des suites (aleatoire des signes) |  | non numerique |
| `tests[[29]]$reference` | Ljung & Box (1978), Biometrika 65 | Wald & Wolfowitz (1940) ; loi exacte : Swed & Eisenhart (19… (62 car.) |  | non numerique |
| `tests[[29]]$H0` | rho_1 = 0 | la suite des signes est un arrangement aleatoire |  | non numerique |
| `tests[[29]]$H1` | autocorrelation au retard 1 | arrangement non aleatoire (regroupement ou alternance) |  | non numerique |
| `tests[[29]]$stat_nom` | Q | Z |  | non numerique |
| `tests[[29]]$stat` | 1.154374408 | 0 | 1.000e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[29]]$loi` | chi2(1) asymptotique | loi combinatoire de R, exacte a pi_t constant seulement (re… (66 car.) |  | non numerique |
| `tests[[29]]$estim_nom` | \<NA\> | nb de suites R |  | non numerique |
| `tests[[29]]$estim` | \<NA\> | 5 |  | non fini |
| `tests[[29]]$p_asymptotique` | 0.2826353016 | 1 | 2.538e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[29]]$p_mc` | 0.29 | 1 | 2.448e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[29]]$err_mc` | 0.014356396 | 0.03163859986 | 1.204e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[29]]$p_retenue` | 0.29 | 1 | 2.448e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[29]]$detail` |  | p exacte non attribuee : loi de reference exacte seulement … (263 car.) |  | non numerique |
| `tests[[29]]$p_min` | \<NA\> | 0.05714285714 |  | non fini |
| `tests[[29]]$fonction` | usp_tests | test_runs |  | non numerique |
| `tests[[29]]$p_min_mc` | \<NA\> | 0.058 |  | non fini |
| `tests[[30]]$test` | Ljung-Box (retard 2) | Centrage des residus standardises |  | non numerique |
| `tests[[30]]$reference` | Ljung & Box (1978), Biometrika 65 | Diagnostic de centrage (ADR 0001) |  | non numerique |
| `tests[[30]]$type` | test | diagnostic |  | non numerique |
| `tests[[30]]$H0` | rho_1 = rho_2 = 0 | \<NA\> |  | non numerique |
| `tests[[30]]$H1` | autocorrelation jusqu'au retard 2 | \<NA\> |  | non numerique |
| `tests[[30]]$stat_nom` | Q | \<NA\> |  | non numerique |
| `tests[[30]]$stat` | 3.269508088 | \<NA\> |  | non fini |
| `tests[[30]]$loi` | chi2(2) asymptotique | \<NA\> |  | non numerique |
| `tests[[30]]$estim_nom` | \<NA\> | moyenne(z) |  | non numerique |
| `tests[[30]]$estim` | \<NA\> | -0.01221722251 |  | non fini |
| `tests[[30]]$p_asymptotique` | 0.1950003269 | \<NA\> |  | non fini |
| `tests[[30]]$p_mc` | 0.22 | \<NA\> |  | non fini |
| `tests[[30]]$err_mc` | 0.01310617304 | \<NA\> |  | non fini |
| `tests[[30]]$p_retenue` | 0.22 | \<NA\> |  | non fini |
| `tests[[30]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[30]]$verdict` | OK | INFO |  | non numerique |
| `tests[[30]]$detail` |  | Grandeur rivee par l'estimation : somme(sqrt(pi_t) z_t) = 0… (434 car.) |  | non numerique |
| `tests[[30]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[31]]$test` | Box-Pierce (retard 2) | Variance unitaire des residus standardises |  | non numerique |
| `tests[[31]]$reference` | Box & Pierce (1970), JASA 65 | Diagnostic d'echelle (ADR 0001) |  | non numerique |
| `tests[[31]]$type` | test | diagnostic |  | non numerique |
| `tests[[31]]$variante` | secondaire | principale |  | non numerique |
| `tests[[31]]$H0` | rho_1 = rho_2 = 0 | \<NA\> |  | non numerique |
| `tests[[31]]$H1` | autocorrelation jusqu'au retard 2 | \<NA\> |  | non numerique |
| `tests[[31]]$stat_nom` | Q | \<NA\> |  | non numerique |
| `tests[[31]]$stat` | 2.077142294 | \<NA\> |  | non fini |
| `tests[[31]]$loi` | chi2(2) asymptotique | \<NA\> |  | non numerique |
| `tests[[31]]$estim_nom` | \<NA\> | var(z) |  | non numerique |
| `tests[[31]]$estim` | \<NA\> | 1.138959 |  | non fini |
| `tests[[31]]$p_asymptotique` | 0.3539600778 | \<NA\> |  | non fini |
| `tests[[31]]$p_mc` | 0.235 | \<NA\> |  | non fini |
| `tests[[31]]$err_mc` | 0.01341472903 | \<NA\> |  | non fini |
| `tests[[31]]$p_retenue` | 0.235 | \<NA\> |  | non fini |
| `tests[[31]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[31]]$verdict` | OK | INFO |  | non numerique |
| `tests[[31]]$detail` |  | Grandeur rivee par l'estimation : la condition du premier o… (819 car.) |  | non numerique |
| `tests[[31]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[32]]$famille` | E. H4 - independance et validite du MV (annexe XVII B(2)(g)… (64 car.) | F. Stabilite, ruptures et points aberrants |  | non numerique |
| `tests[[32]]$test` | Test des suites (aleatoire des signes) | Rupture de niveau (sup-F) |  | non numerique |
| `tests[[32]]$reference` | Wald & Wolfowitz (1940) ; loi exacte : Swed & Eisenhart (19… (62 car.) | Quandt (1960) / Chow (1960) ; Andrews (1993) |  | non numerique |
| `tests[[32]]$H0` | la suite des signes est un arrangement aleatoire | E[z_t] constant (absence de rupture) |  | non numerique |
| `tests[[32]]$H1` | arrangement non aleatoire (regroupement ou alternance) | rupture de niveau a une date inconnue |  | non numerique |
| `tests[[32]]$stat_nom` | Z | supF |  | non numerique |
| `tests[[32]]$stat` | 0 | 0.5998246848 | 5.998e-01 | absolu, au-delà du seuil 1e-06 |
| `tests[[32]]$loi` | loi combinatoire de R, exacte a pi_t constant seulement (re… (66 car.) | supremum de processus (Andrews) -> Monte-Carlo |  | non numerique |
| `tests[[32]]$estim_nom` | nb de suites R | \<NA\> |  | non numerique |
| `tests[[32]]$estim` | 5 | \<NA\> |  | non fini |
| `tests[[32]]$p_asymptotique` | 1 | \<NA\> |  | non fini |
| `tests[[32]]$p_mc` | 1 | 0.911 | 8.900e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[32]]$err_mc` | 0.03163859986 | 0.009008893393 | 7.153e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[32]]$p_retenue` | 1 | 0.911 | 8.900e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[32]]$detail` | p exacte non attribuee : loi de reference exacte seulement … (263 car.) | La loi de Fisher est inapplicable : le point de rupture est… (66 car.) |  | non numerique |
| `tests[[32]]$p_min` | 0.05714285714 | \<NA\> |  | non fini |
| `tests[[32]]$fonction` | test_runs | stat_supF |  | non numerique |
| `tests[[32]]$p_min_mc` | 0.058 | \<NA\> |  | non fini |
| `tests[[33]]$famille` | E. H4 - independance et validite du MV (annexe XVII B(2)(g)… (64 car.) | F. Stabilite, ruptures et points aberrants |  | non numerique |
| `tests[[33]]$test` | Centrage des residus standardises | Stabilite cumulee (OLS-CUSUM) |  | non numerique |
| `tests[[33]]$reference` | Diagnostic de centrage (ADR 0001) | Brown, Durbin & Evans (1975), JRSS B 37 |  | non numerique |
| `tests[[33]]$type` | diagnostic | test |  | non numerique |
| `tests[[33]]$base` | commun | z |  | non numerique |
| `tests[[33]]$H0` | \<NA\> | constance des parametres sur la periode |  | non numerique |
| `tests[[33]]$H1` | \<NA\> | derive graduelle |  | non numerique |
| `tests[[33]]$stat_nom` | \<NA\> | CUSUM |  | non numerique |
| `tests[[33]]$stat` | \<NA\> | 0.4089644933 |  | non fini |
| `tests[[33]]$loi` | \<NA\> | sup \|pont brownien\| ; formule de Kolmogorov asymptotique |  | non numerique |
| `tests[[33]]$estim_nom` | moyenne(z) | \<NA\> |  | non numerique |
| `tests[[33]]$estim` | -0.01221722251 | \<NA\> |  | non fini |
| `tests[[33]]$p_asymptotique` | \<NA\> | 0.9961636511 |  | non fini |
| `tests[[33]]$p_mc` | \<NA\> | 0.954 |  | non fini |
| `tests[[33]]$err_mc` | \<NA\> | 0.006627814717 |  | non fini |
| `tests[[33]]$p_retenue` | \<NA\> | 0.954 |  | non fini |
| `tests[[33]]$nature_p` | \<NA\> | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) |  | non numerique |
| `tests[[33]]$verdict` | INFO | OK |  | non numerique |
| `tests[[33]]$detail` | Grandeur rivee par l'estimation : somme(sqrt(pi_t) z_t) = 0… (434 car.) | La formule asymptotique n'a aucune validite a T = 8 ; p_mc … (135 car.) |  | non numerique |
| `tests[[33]]$sens` | \<NA\> | ne pas rejeter |  | non numerique |
| `tests[[33]]$fonction` | usp_tests | stat_cusum |  | non numerique |
| `tests[[34]]$famille` | E. H4 - independance et validite du MV (annexe XVII B(2)(g)… (64 car.) | F. Stabilite, ruptures et points aberrants |  | non numerique |
| `tests[[34]]$test` | Variance unitaire des residus standardises | Valeur aberrante isolee (Grubbs) |  | non numerique |
| `tests[[34]]$reference` | Diagnostic d'echelle (ADR 0001) | Grubbs (1950, 1969), Technometrics 11 |  | non numerique |
| `tests[[34]]$type` | diagnostic | test |  | non numerique |
| `tests[[34]]$base` | commun | z |  | non numerique |
| `tests[[34]]$H0` | \<NA\> | aucune valeur aberrante (echantillon normal homogene) |  | non numerique |
| `tests[[34]]$H1` | \<NA\> | exactement une valeur aberrante |  | non numerique |
| `tests[[34]]$stat_nom` | \<NA\> | G |  | non numerique |
| `tests[[34]]$stat` | \<NA\> | 1.793630721 |  | non fini |
| `tests[[34]]$loi` | \<NA\> | Student + borne de Bonferroni (conservatrice) |  | non numerique |
| `tests[[34]]$estim_nom` | var(z) | rang de l'obs. extreme |  | non numerique |
| `tests[[34]]$estim` | 1.138959 | 3 |  | non numerique |
| `tests[[34]]$p_asymptotique` | \<NA\> | 0.3357596655 |  | non fini |
| `tests[[34]]$p_mc` | \<NA\> | 0.105 |  | non fini |
| `tests[[34]]$err_mc` | \<NA\> | 0.009698921026 |  | non fini |
| `tests[[34]]$p_retenue` | \<NA\> | 0.105 |  | non fini |
| `tests[[34]]$nature_p` | \<NA\> | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) |  | non numerique |
| `tests[[34]]$verdict` | INFO | OK |  | non numerique |
| `tests[[34]]$detail` | Grandeur rivee par l'estimation : la condition du premier o… (819 car.) | G est borne par (T-1)/sqrt(T) = 2.475 ; verdict sensible a … (128 car.) |  | non numerique |
| `tests[[34]]$sens` | \<NA\> | ne pas rejeter |  | non numerique |
| `tests[[34]]$fonction` | usp_tests | test_grubbs |  | non numerique |
| `tests[[35]]$test` | Rupture de niveau (sup-F) | Valeurs aberrantes multiples (ESD generalise) |  | non numerique |
| `tests[[35]]$reference` | Quandt (1960) / Chow (1960) ; Andrews (1993) | Rosner (1983), Technometrics 25 |  | non numerique |
| `tests[[35]]$type` | test | procedure de decision |  | non numerique |
| `tests[[35]]$base` | z | commun |  | non numerique |
| `tests[[35]]$H0` | E[z_t] constant (absence de rupture) | aucune valeur aberrante |  | non numerique |
| `tests[[35]]$H1` | rupture de niveau a une date inconnue | il existe i <= k valeurs aberrantes |  | non numerique |
| `tests[[35]]$stat_nom` | supF | \<NA\> |  | non numerique |
| `tests[[35]]$stat` | 0.5998246848 | \<NA\> |  | non fini |
| `tests[[35]]$loi` | supremum de processus (Andrews) -> Monte-Carlo | \<NA\> |  | non numerique |
| `tests[[35]]$estim_nom` | \<NA\> | nb de valeurs aberrantes |  | non numerique |
| `tests[[35]]$estim` | \<NA\> | 0 |  | non fini |
| `tests[[35]]$p_mc` | 0.911 | \<NA\> |  | non fini |
| `tests[[35]]$err_mc` | 0.009008893393 | \<NA\> |  | non fini |
| `tests[[35]]$p_retenue` | 0.911 | \<NA\> |  | non fini |
| `tests[[35]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[35]]$detail` | La loi de Fisher est inapplicable : le point de rupture est… (66 car.) | procedure a niveau alpha = 0.10 (aucune p-value) |  | non numerique |
| `tests[[35]]$fonction` | stat_supF | test_rosner |  | non numerique |
| `tests[[36]]$test` | Stabilite cumulee (OLS-CUSUM) | Points influents (distance de Cook) |  | non numerique |
| `tests[[36]]$reference` | Brown, Durbin & Evans (1975), JRSS B 37 | Cook (1977), Technometrics 19 |  | non numerique |
| `tests[[36]]$type` | test | diagnostic |  | non numerique |
| `tests[[36]]$base` | z | commun |  | non numerique |
| `tests[[36]]$H0` | constance des parametres sur la periode | \<NA\> |  | non numerique |
| `tests[[36]]$H1` | derive graduelle | \<NA\> |  | non numerique |
| `tests[[36]]$stat_nom` | CUSUM | \<NA\> |  | non numerique |
| `tests[[36]]$stat` | 0.4089644933 | \<NA\> |  | non fini |
| `tests[[36]]$loi` | sup \|pont brownien\| ; formule de Kolmogorov asymptotique | \<NA\> |  | non numerique |
| `tests[[36]]$estim_nom` | \<NA\> | max D_t |  | non numerique |
| `tests[[36]]$estim` | \<NA\> | 0.8532677231 |  | non fini |
| `tests[[36]]$p_asymptotique` | 0.9961636511 | \<NA\> |  | non fini |
| `tests[[36]]$p_mc` | 0.954 | \<NA\> |  | non fini |
| `tests[[36]]$err_mc` | 0.006627814717 | \<NA\> |  | non fini |
| `tests[[36]]$p_retenue` | 0.954 | \<NA\> |  | non fini |
| `tests[[36]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[36]]$verdict` | OK | INFO |  | non numerique |
| `tests[[36]]$detail` | La formule asymptotique n'a aucune validite a T = 8 ; p_mc … (135 car.) | repere conventionnel 4/T = 0.500 ; 1 observation(s) au-dess… (71 car.) |  | non numerique |
| `tests[[36]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[36]]$fonction` | stat_cusum | usp_tests |  | non numerique |
| `tests[[37]]$famille` | F. Stabilite, ruptures et points aberrants | E. H4 - independance et validite du MV (annexe XVII B(2)(g)… (64 car.) |  | non numerique |
| `tests[[37]]$test` | Valeur aberrante isolee (Grubbs) | Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts |  | non numerique |
| `tests[[37]]$reference` | Grubbs (1950, 1969), Technometrics 11 | Durbin & Watson (1950, 1951) |  | non numerique |
| `tests[[37]]$base` | z | r |  | non numerique |
| `tests[[37]]$H0` | aucune valeur aberrante (echantillon normal homogene) | absence d'autocorrelation d'ordre 1 du ratio S/P |  | non numerique |
| `tests[[37]]$H1` | exactement une valeur aberrante | autocorrelation du ratio S/P |  | non numerique |
| `tests[[37]]$stat_nom` | G | DW |  | non numerique |
| `tests[[37]]$stat` | 1.793630721 | 2.3199754 | 2.935e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[37]]$loi` | Student + borne de Bonferroni (conservatrice) | loi classique INDICATIVE (ratios heteroscedastiques) -> Mon… (67 car.) |  | non numerique |
| `tests[[37]]$estim_nom` | rang de l'obs. extreme | \<NA\> |  | non numerique |
| `tests[[37]]$estim` | 3 | \<NA\> |  | non numerique |
| `tests[[37]]$p_asymptotique` | 0.3357596655 | \<NA\> |  | non fini |
| `tests[[37]]$p_mc` | 0.105 | 0.392 | 2.733e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[37]]$err_mc` | 0.009698921026 | 0.02511905585 | 1.590e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[37]]$p_retenue` | 0.105 | 0.392 | 2.733e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[37]]$detail` | G est borne par (T-1)/sqrt(T) = 2.475 ; verdict sensible a … (128 car.) |  |  | non numerique |
| `tests[[37]]$fonction` | test_grubbs | stat_dw |  | non numerique |
| `tests[[38]]$famille` | F. Stabilite, ruptures et points aberrants | E. H4 - independance et validite du MV (annexe XVII B(2)(g)… (64 car.) |  | non numerique |
| `tests[[38]]$test` | Valeurs aberrantes multiples (ESD generalise) | Test des suites sur ratios bruts |  | non numerique |
| `tests[[38]]$reference` | Rosner (1983), Technometrics 25 | Wald & Wolfowitz (1940) |  | non numerique |
| `tests[[38]]$type` | procedure de decision | test |  | non numerique |
| `tests[[38]]$base` | commun | r |  | non numerique |
| `tests[[38]]$H0` | aucune valeur aberrante | arrangement aleatoire des signes du ratio centre |  | non numerique |
| `tests[[38]]$H1` | il existe i <= k valeurs aberrantes | arrangement non aleatoire |  | non numerique |
| `tests[[38]]$stat_nom` | \<NA\> | Z |  | non numerique |
| `tests[[38]]$stat` | \<NA\> | 0 |  | non fini |
| `tests[[38]]$loi` | \<NA\> | loi classique INDICATIVE (ratios heteroscedastiques) -> Mon… (67 car.) |  | non numerique |
| `tests[[38]]$estim_nom` | nb de valeurs aberrantes | \<NA\> |  | non numerique |
| `tests[[38]]$estim` | 0 | \<NA\> |  | non fini |
| `tests[[38]]$p_mc` | \<NA\> | 1 |  | non fini |
| `tests[[38]]$err_mc` | \<NA\> | 0.03163859986 |  | non fini |
| `tests[[38]]$p_retenue` | \<NA\> | 1 |  | non fini |
| `tests[[38]]$nature_p` | \<NA\> | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) |  | non numerique |
| `tests[[38]]$detail` | procedure a niveau alpha = 0.10 (aucune p-value) | pi_t varie avec t : sous le modele ajuste, les r_t sont ind… (691 car.) |  | non numerique |
| `tests[[38]]$p_min` | \<NA\> | 0.05714285714 |  | non fini |
| `tests[[38]]$fonction` | test_rosner | test_runs |  | non numerique |
| `tests[[38]]$p_min_mc` | \<NA\> | 0.062 |  | non fini |
| `tests[[39]]$test` | Points influents (distance de Cook) | Rupture de niveau (sup-F) sur ratios bruts |  | non numerique |
| `tests[[39]]$reference` | Cook (1977), Technometrics 19 | Quandt (1960) / Chow (1960) ; Andrews (1993) |  | non numerique |
| `tests[[39]]$type` | diagnostic | test |  | non numerique |
| `tests[[39]]$base` | commun | r |  | non numerique |
| `tests[[39]]$H0` | \<NA\> | niveau du ratio S/P constant |  | non numerique |
| `tests[[39]]$H1` | \<NA\> | rupture de niveau du ratio S/P |  | non numerique |
| `tests[[39]]$stat_nom` | \<NA\> | supF |  | non numerique |
| `tests[[39]]$stat` | \<NA\> | 0.8358227123 |  | non fini |
| `tests[[39]]$loi` | \<NA\> | supremum de processus -> Monte-Carlo |  | non numerique |
| `tests[[39]]$estim_nom` | max D_t | \<NA\> |  | non numerique |
| `tests[[39]]$estim` | 0.8532677231 | \<NA\> |  | non fini |
| `tests[[39]]$p_mc` | \<NA\> | 0.821 |  | non fini |
| `tests[[39]]$err_mc` | \<NA\> | 0.01212873061 |  | non fini |
| `tests[[39]]$p_retenue` | \<NA\> | 0.821 |  | non fini |
| `tests[[39]]$nature_p` | \<NA\> | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) |  | non numerique |
| `tests[[39]]$verdict` | INFO | OK |  | non numerique |
| `tests[[39]]$detail` | repere conventionnel 4/T = 0.500 ; 1 observation(s) au-dess… (71 car.) | Detecte un changement de regime du ratio, independamment du… (67 car.) |  | non numerique |
| `tests[[39]]$sens` | \<NA\> | ne pas rejeter |  | non numerique |
| `tests[[39]]$fonction` | usp_tests | stat_supF |  | non numerique |
| `tests[[40]]$famille` | E. H4 - independance et validite du MV (annexe XVII B(2)(g)… (64 car.) | F. Stabilite, ruptures et points aberrants |  | non numerique |
| `tests[[40]]$test` | Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | Stabilite cumulee (OLS-CUSUM) sur ratios bruts |  | non numerique |
| `tests[[40]]$reference` | Durbin & Watson (1950, 1951) | Brown, Durbin & Evans (1975), JRSS B 37 |  | non numerique |
| `tests[[40]]$H0` | absence d'autocorrelation d'ordre 1 du ratio S/P | constance du niveau du ratio S/P |  | non numerique |
| `tests[[40]]$H1` | autocorrelation du ratio S/P | derive graduelle |  | non numerique |
| `tests[[40]]$stat_nom` | DW | CUSUM |  | non numerique |
| `tests[[40]]$stat` | 2.3199754 | 0.4538884948 | 8.044e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[40]]$loi` | loi classique INDICATIVE (ratios heteroscedastiques) -> Mon… (67 car.) | sup \|pont brownien\| -> Monte-Carlo |  | non numerique |
| `tests[[40]]$p_mc` | 0.392 | 0.924 | 1.357e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[40]]$err_mc` | 0.02511905585 | 0.008384169267 | 6.662e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[40]]$p_retenue` | 0.392 | 0.924 | 1.357e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[40]]$fonction` | stat_dw | stat_cusum |  | non numerique |
| `tests[[41]]$famille` | E. H4 - independance et validite du MV (annexe XVII B(2)(g)… (64 car.) | F. Stabilite, ruptures et points aberrants |  | non numerique |
| `tests[[41]]$test` | Test des suites sur ratios bruts | Valeur aberrante isolee (Grubbs) sur ratios bruts |  | non numerique |
| `tests[[41]]$reference` | Wald & Wolfowitz (1940) | Grubbs (1950, 1969), Technometrics 11 |  | non numerique |
| `tests[[41]]$H0` | arrangement aleatoire des signes du ratio centre | aucun ratio S/P aberrant |  | non numerique |
| `tests[[41]]$H1` | arrangement non aleatoire | exactement un ratio aberrant |  | non numerique |
| `tests[[41]]$stat_nom` | Z | G |  | non numerique |
| `tests[[41]]$stat` | 0 | 1.835018034 | 1.835e+00 | absolu, au-delà du seuil 1e-06 |
| `tests[[41]]$estim_nom` | \<NA\> | rang du ratio extreme |  | non numerique |
| `tests[[41]]$estim` | \<NA\> | 3 |  | non numerique |
| `tests[[41]]$p_mc` | 1 | 0.204 | 7.960e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[41]]$err_mc` | 0.03163859986 | 0.01274937436 | 5.970e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[41]]$p_retenue` | 1 | 0.204 | 7.960e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[41]]$detail` | pi_t varie avec t : sous le modele ajuste, les r_t sont ind… (691 car.) | Identifie l'annee au boni/mali le plus atypique, sans passe… (75 car.) |  | non numerique |
| `tests[[41]]$p_min` | 0.05714285714 | \<NA\> |  | non fini |
| `tests[[41]]$fonction` | test_runs | test_grubbs |  | non numerique |
| `tests[[41]]$p_min_mc` | 0.062 | \<NA\> |  | non fini |
| `tests[[42]]$test` | Rupture de niveau (sup-F) sur ratios bruts | Leviers (hat values) |  | non numerique |
| `tests[[42]]$reference` | Quandt (1960) / Chow (1960) ; Andrews (1993) | Hoaglin & Welsch (1978), Amer. Statist. 32 |  | non numerique |
| `tests[[42]]$type` | test | diagnostic |  | non numerique |
| `tests[[42]]$base` | r | commun |  | non numerique |
| `tests[[42]]$H0` | niveau du ratio S/P constant | \<NA\> |  | non numerique |
| `tests[[42]]$H1` | rupture de niveau du ratio S/P | \<NA\> |  | non numerique |
| `tests[[42]]$stat_nom` | supF | \<NA\> |  | non numerique |
| `tests[[42]]$stat` | 0.8358227123 | \<NA\> |  | non fini |
| `tests[[42]]$loi` | supremum de processus -> Monte-Carlo | \<NA\> |  | non numerique |
| `tests[[42]]$estim_nom` | \<NA\> | max h_t |  | non numerique |
| `tests[[42]]$estim` | \<NA\> | 0.48 |  | non fini |
| `tests[[42]]$p_mc` | 0.821 | \<NA\> |  | non fini |
| `tests[[42]]$err_mc` | 0.01212873061 | \<NA\> |  | non fini |
| `tests[[42]]$p_retenue` | 0.821 | \<NA\> |  | non fini |
| `tests[[42]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[42]]$verdict` | OK | INFO |  | non numerique |
| `tests[[42]]$detail` | Detecte un changement de regime du ratio, independamment du… (67 car.) | repere conventionnel 2k/T = 0.250 ; 1 observation(s) au-des… (62 car.) |  | non numerique |
| `tests[[42]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[42]]$fonction` | stat_supF | usp_tests |  | non numerique |
| `tests[[43]]$famille` | F. Stabilite, ruptures et points aberrants | G. Robustesse de l'estimation |  | non numerique |
| `tests[[43]]$test` | Stabilite cumulee (OLS-CUSUM) sur ratios bruts | Sensibilite au retrait d'une annee (jackknife) |  | non numerique |
| `tests[[43]]$reference` | Brown, Durbin & Evans (1975), JRSS B 37 | Quenouille (1949) / Tukey (1958) |  | non numerique |
| `tests[[43]]$type` | test | diagnostic |  | non numerique |
| `tests[[43]]$base` | r | commun |  | non numerique |
| `tests[[43]]$H0` | constance du niveau du ratio S/P | \<NA\> |  | non numerique |
| `tests[[43]]$H1` | derive graduelle | \<NA\> |  | non numerique |
| `tests[[43]]$stat_nom` | CUSUM | \<NA\> |  | non numerique |
| `tests[[43]]$stat` | 0.4538884948 | \<NA\> |  | non fini |
| `tests[[43]]$loi` | sup \|pont brownien\| -> Monte-Carlo | \<NA\> |  | non numerique |
| `tests[[43]]$estim_nom` | \<NA\> | ecart relatif max |  | non numerique |
| `tests[[43]]$estim` | \<NA\> | 0.1662258524 |  | non fini |
| `tests[[43]]$p_mc` | 0.924 | \<NA\> |  | non fini |
| `tests[[43]]$err_mc` | 0.008384169267 | \<NA\> |  | non fini |
| `tests[[43]]$p_retenue` | 0.924 | \<NA\> |  | non fini |
| `tests[[43]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[43]]$verdict` | OK | INFO |  | non numerique |
| `tests[[43]]$detail` |  | Annee la plus influente : 3 (sigma_USP en baisse). |  | non numerique |
| `tests[[43]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[43]]$fonction` | stat_cusum | run_engine |  | non numerique |
| `tests[[44]]$famille` | F. Stabilite, ruptures et points aberrants | G. Robustesse de l'estimation |  | non numerique |
| `tests[[44]]$test` | Valeur aberrante isolee (Grubbs) sur ratios bruts | Largeur relative de l'IC bootstrap 90% |  | non numerique |
| `tests[[44]]$reference` | Grubbs (1950, 1969), Technometrics 11 | Efron (1979), Ann. Statist. 7 |  | non numerique |
| `tests[[44]]$type` | test | diagnostic |  | non numerique |
| `tests[[44]]$base` | r | commun |  | non numerique |
| `tests[[44]]$H0` | aucun ratio S/P aberrant | \<NA\> |  | non numerique |
| `tests[[44]]$H1` | exactement un ratio aberrant | \<NA\> |  | non numerique |
| `tests[[44]]$stat_nom` | G | \<NA\> |  | non numerique |
| `tests[[44]]$stat` | 1.835018034 | \<NA\> |  | non fini |
| `tests[[44]]$loi` | loi classique INDICATIVE (ratios heteroscedastiques) -> Mon… (67 car.) | \<NA\> |  | non numerique |
| `tests[[44]]$estim_nom` | rang du ratio extreme | largeur / sigma_USP |  | non numerique |
| `tests[[44]]$estim` | 3 | 0.4346439757 |  | non numerique |
| `tests[[44]]$p_mc` | 0.204 | \<NA\> |  | non fini |
| `tests[[44]]$err_mc` | 0.01274937436 | \<NA\> |  | non fini |
| `tests[[44]]$p_retenue` | 0.204 | \<NA\> |  | non fini |
| `tests[[44]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[44]]$verdict` | OK | INFO |  | non numerique |
| `tests[[44]]$detail` | Identifie l'annee au boni/mali le plus atypique, sans passe… (75 car.) | Intervalle bootstrap du parametre retenu : res$ic_bootstrap. |  | non numerique |
| `tests[[44]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[44]]$fonction` | test_grubbs | run_engine |  | non numerique |
| `tests[[45]]$famille` | F. Stabilite, ruptures et points aberrants | G. Robustesse de l'estimation |  | non numerique |
| `tests[[45]]$test` | Leviers (hat values) | Largeur relative de l'IC bootstrap 90% (delta fixe a delta … (66 car.) |  | non numerique |
| `tests[[45]]$reference` | Hoaglin & Welsch (1978), Amer. Statist. 32 | Efron (1979), Ann. Statist. 7 ; Andrews (2000), Econometric… (63 car.) |  | non numerique |
| `tests[[45]]$estim_nom` | max h_t | largeur / sigma_USP |  | non numerique |
| `tests[[45]]$estim` | 0.48 | 0.4531181242 | 5.600e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[45]]$detail` | repere conventionnel 2k/T = 0.250 ; 1 observation(s) au-des… (62 car.) | Bootstrap parametrique a delta fixe a sa valeur estimee (se… (449 car.) |  | non numerique |
| `tests[[45]]$fonction` | usp_tests | run_engine |  | non numerique |
| `tests[[46]]$test` | Sensibilite au retrait d'une annee (jackknife) | Rapport de vraisemblance : delta = 0 (variance lineaire en … (66 car.) |  | non numerique |
| `tests[[46]]$reference` | Quenouille (1949) / Tukey (1958) | Chernoff (1954) ; Self & Liang (1987), JASA 82 ; Davison & … (82 car.) |  | non numerique |
| `tests[[46]]$H0` | \<NA\> | delta = 0 (variance proportionnelle au volume) |  | non numerique |
| `tests[[46]]$H1` | \<NA\> | delta > 0 |  | non numerique |
| `tests[[46]]$stat_nom` | \<NA\> | LR(0) |  | non numerique |
| `tests[[46]]$stat` | \<NA\> | 0.1649016946 |  | non fini |
| `tests[[46]]$loi` | \<NA\> | sous H0 : loi simulee par bootstrap parametrique restreint … (172 car.) |  | non numerique |
| `tests[[46]]$estim_nom` | ecart relatif max | sigma(delta0, gamma~) |  | non numerique |
| `tests[[46]]$estim` | 0.1662258524 | 0.06676040344 | 5.984e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[46]]$p_asymptotique` | \<NA\> | 0.3423415808 |  | non fini |
| `tests[[46]]$p_mc` | \<NA\> | 0.289 |  | non fini |
| `tests[[46]]$err_mc` | \<NA\> | 0.01434171136 |  | non fini |
| `tests[[46]]$detail` | Annee la plus influente : 3 (sigma_USP en baisse). | Aucun verdict (ADR 0001) : le LR mesure si les donnees dist… (420 car.) |  | non numerique |
| `tests[[46]]$fonction` | run_engine | usp_lr_delta |  | non numerique |
| `tests[[47]]$test` | Largeur relative de l'IC bootstrap 90% | Rapport de vraisemblance : delta = 1 (variance quadratique … (69 car.) |  | non numerique |
| `tests[[47]]$reference` | Efron (1979), Ann. Statist. 7 | Chernoff (1954) ; Self & Liang (1987), JASA 82 ; Davison & … (82 car.) |  | non numerique |
| `tests[[47]]$H0` | \<NA\> | delta = 1 (variance proportionnelle au carre du volume) |  | non numerique |
| `tests[[47]]$H1` | \<NA\> | delta < 1 |  | non numerique |
| `tests[[47]]$stat_nom` | \<NA\> | LR(1) |  | non numerique |
| `tests[[47]]$stat` | \<NA\> | 0.141073731 |  | non fini |
| `tests[[47]]$loi` | \<NA\> | sous H0 : loi simulee par bootstrap parametrique restreint … (172 car.) |  | non numerique |
| `tests[[47]]$estim_nom` | largeur / sigma_USP | sigma(delta0, gamma~) |  | non numerique |
| `tests[[47]]$estim` | 0.4346439757 | 0.07261597231 | 8.329e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[47]]$p_asymptotique` | \<NA\> | 0.3536079516 |  | non fini |
| `tests[[47]]$p_mc` | \<NA\> | 0.411 |  | non fini |
| `tests[[47]]$err_mc` | \<NA\> | 0.01556667342 |  | non fini |
| `tests[[47]]$detail` | Intervalle bootstrap du parametre retenu : res$ic_bootstrap. | Aucun verdict (ADR 0001) : le LR mesure si les donnees dist… (420 car.) |  | non numerique |
| `tests[[47]]$fonction` | run_engine | usp_lr_delta |  | non numerique |

## Batteries

- `Rscript tests/test_reproductibilite.R` : code de sortie 0
  - `premium     sigma_USP = 0.1114524114  (16 s)`
  - `CONFORME : 23715 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve1    sigma_USP = 0.1073524114  (14 s)`
  - `CONFORME : 23714 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve2    sigma_USP = 0.0497764613  (31 s)`
  - `CONFORME : 4470 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_ii6 sigma_USP = 0.1483524114  (14 s)`
  - `CONFORME : 23715 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_net sigma_USP = 0.1032524114  (14 s)`
  - `CONFORME : 23715 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_interieur sigma_USP = 0.0871308679  (26 s)`
  - `CONFORME : 23715 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `OK : reproductibilite et non-regression verifiees pour 6 cas.`
- `Rscript tests/test_unitaires.R` : code de sortie 0
  - `TOTAL : 2441 assertions, 2441 ok, 0 echec(s), 0 echec(s) attendu(s) (defauts connus), 0 succes inattendu(s)`
  - `OK`
