# Tableau avant / après — référence `premium_interieur` (issue #303)

- Date : 2026-10-19
- Plateforme : R version 4.3.1 (2023-06-16), Linux
- Commande : `Rscript tests/regenerer_et_rendre_compte.R premium --attendu '^tests\[\[(4[0-9]|50)\]\]' --attendu '^tests\[\[51\]\]' --attendu '^bootstrap\$.*LB1r' premium_net --attendu '^tests\[\[(4[0-9]|50)\]\]' --attendu '^tests\[\[51\]\]' --attendu '^bootstrap\$.*LB1r' premium_ii6 --attendu '^tests\[\[(4[0-9]|50)\]\]' --attendu '^tests\[\[51\]\]' --attendu '^bootstrap\$.*LB1r' reserve1 --attendu '^tests\[\[(4[0-9]|50)\]\]' --attendu '^tests\[\[51\]\]' --attendu '^bootstrap\$.*LB1r' premium_interieur --att… (612 car.)`
- Motifs attendus : `^tests\[\[(4[0-9]|50)\]\]`, `^tests\[\[51\]\]`, `^bootstrap\$.*LB1r`
- Exécution à plusieurs cas (M33) : `premium`, `premium_net`, `premium_ii6`, `reserve1`, `premium_interieur`, chacun avec ses motifs ; tout ou rien ; batteries relancées une seule fois, après le dernier cas
- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil 0 pour lister, seuil 1e-06 pour juger ; `INSTABLES` non neutralisé

**Synthèse** : 23840 feuille(s) dans l'ancienne référence, 23807 dans le résultat recalculé ; 145 non strictement identique(s) (dont 145 en écart au seuil 1e-06, 0 ajoutée(s), 33 supprimée(s)), toutes désignées par les motifs attendus ; 23695 feuille(s) identique(s) au bit près ; écart numérique maximal 3.043e+00 (relatif, `tests[[44]]$stat`).

**Avertissement** : motif `^tests\[\[(4[0-9]|50)\]\]` : 112 feuilles désignées (seuil d'avertissement 50) ; vérifier qu'il n'est pas trop large.

Nœuds de structure modifiés (type ou attributs) : `tests[[44]]$estim`, `tests[[45]]$estim`, `tests[[51]]`, `tests[[51]]$famille`, `tests[[51]]$test`, `tests[[51]]$reference`, `tests[[51]]$type`, `tests[[51]]$base`, `tests[[51]]$variante`, `tests[[51]]$H0`, `tests[[51]]$H1`, `tests[[51]]$stat_nom`, `tests[[51]]$stat`, `tests[[51]]$loi`, `tests[[51]]$estim_nom`, `tests[[51]]$estim`, `tests[[51]]$p_exacte`, `tests[[51]]$p_asymptotique`, `tests[[51]]$p_mc`, `tests[[51]]$err_mc`, `tests[[51]]$p_retenue`, `tests[[51]]$nature_p`, `tests[[51]]$verdict`, `tests[[51]]$detail`, `tests[[51]]$sens`, `tests[[51]]$p_min`, `tests[[51]]$fonction`, `tests[[51]]$inoperant`, `tests[[51]]$p_min_mc`, `bootstrap$stats_obs`, `bootstrap$stats_obs$LB1r`, `bootstrap$p_mc`, `bootstrap$err_mc`, `bootstrap$B_effectif`, `bootstrap$granularite_stat`, `bootstrap$motif_mc`, `bootstrap$p_min_mc`

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `tests[[51]]$famille` | G. Robustesse de l'estimation | (absente) |  | supprimée (absente après) |
| `tests[[51]]$test` | Rapport de vraisemblance : delta = 1 (variance quadratique … (69 car.) | (absente) |  | supprimée (absente après) |
| `tests[[51]]$reference` | Chernoff (1954) ; Self & Liang (1987), JASA 82 ; Davison & … (82 car.) | (absente) |  | supprimée (absente après) |
| `tests[[51]]$type` | diagnostic | (absente) |  | supprimée (absente après) |
| `tests[[51]]$base` | commun | (absente) |  | supprimée (absente après) |
| `tests[[51]]$variante` | principale | (absente) |  | supprimée (absente après) |
| `tests[[51]]$H0` | delta = 1 (variance proportionnelle au carre du volume) | (absente) |  | supprimée (absente après) |
| `tests[[51]]$H1` | delta < 1 | (absente) |  | supprimée (absente après) |
| `tests[[51]]$stat_nom` | LR(1) | (absente) |  | supprimée (absente après) |
| `tests[[51]]$stat` | 0.141073731 | (absente) |  | supprimée (absente après) |
| `tests[[51]]$loi` | sous H0 : loi simulee par bootstrap parametrique restreint … (172 car.) | (absente) |  | supprimée (absente après) |
| `tests[[51]]$estim_nom` | sigma(delta0, gamma~) | (absente) |  | supprimée (absente après) |
| `tests[[51]]$estim` | 0.07261597231 | (absente) |  | supprimée (absente après) |
| `tests[[51]]$p_exacte` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[51]]$p_asymptotique` | 0.3536079516 | (absente) |  | supprimée (absente après) |
| `tests[[51]]$p_mc` | 0.411 | (absente) |  | supprimée (absente après) |
| `tests[[51]]$err_mc` | 0.01556667342 | (absente) |  | supprimée (absente après) |
| `tests[[51]]$p_retenue` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[51]]$nature_p` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[51]]$verdict` | INFO | (absente) |  | supprimée (absente après) |
| `tests[[51]]$detail` | Aucun verdict (ADR 0001) : le LR mesure si les donnees dist… (420 car.) | (absente) |  | supprimée (absente après) |
| `tests[[51]]$sens` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[51]]$p_min` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[51]]$fonction` | usp_lr_delta | (absente) |  | supprimée (absente après) |
| `tests[[51]]$inoperant` | FALSE | (absente) |  | supprimée (absente après) |
| `tests[[51]]$p_min_mc` | \<NA\> | (absente) |  | supprimée (absente après) |
| `bootstrap$stats_obs$LB1r` | 0.9575036585 | (absente) |  | supprimée (absente après) |
| `bootstrap$p_mc["LB1r"]` | 0.328 | (absente) |  | supprimée (absente après) |
| `bootstrap$err_mc["LB1r"]` | 0.01485384249 | (absente) |  | supprimée (absente après) |
| `bootstrap$B_effectif["LB1r"]` | 999 | (absente) |  | supprimée (absente après) |
| `bootstrap$granularite_stat["LB1r"]` | 0.001 | (absente) |  | supprimée (absente après) |
| `bootstrap$motif_mc["LB1r"]` | \<NA\> | (absente) |  | supprimée (absente après) |
| `bootstrap$p_min_mc["LB1r"]` | \<NA\> | (absente) |  | supprimée (absente après) |
| `tests[[41]]$test` | Ljung-Box (retard 1) sur ratios bruts | Test des suites sur ratios bruts |  | non numerique |
| `tests[[41]]$reference` | Ljung & Box (1978), Biometrika 65 | Wald & Wolfowitz (1940) |  | non numerique |
| `tests[[41]]$H0` | rho_1 = 0 pour le ratio S/P | arrangement aleatoire des signes du ratio centre |  | non numerique |
| `tests[[41]]$H1` | autocorrelation au retard 1 | arrangement non aleatoire |  | non numerique |
| `tests[[41]]$stat_nom` | Q | Z |  | non numerique |
| `tests[[41]]$stat` | 0.9575036585 | 0 | 1.000e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[41]]$p_mc` | 0.328 | 1 | 2.049e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[41]]$err_mc` | 0.01485384249 | 0.03163859986 | 1.130e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[41]]$p_retenue` | 0.328 | 1 | 2.049e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[41]]$detail` |  | pi_t varie avec t : sous le modele ajuste, les r_t sont ind… (691 car.) |  | non numerique |
| `tests[[41]]$p_min` | \<NA\> | 0.05714285714 |  | non fini |
| `tests[[41]]$fonction` | usp_tests | test_runs |  | non numerique |
| `tests[[41]]$p_min_mc` | \<NA\> | 0.062 |  | non fini |
| `tests[[42]]$famille` | E. H4 - independance et validite du MV (annexe XVII B(2)(g)… (64 car.) | F. Stabilite, ruptures et points aberrants |  | non numerique |
| `tests[[42]]$test` | Test des suites sur ratios bruts | Rupture de niveau (sup-F) sur ratios bruts |  | non numerique |
| `tests[[42]]$reference` | Wald & Wolfowitz (1940) | Quandt (1960) / Chow (1960) ; Andrews (1993) |  | non numerique |
| `tests[[42]]$H0` | arrangement aleatoire des signes du ratio centre | niveau du ratio S/P constant |  | non numerique |
| `tests[[42]]$H1` | arrangement non aleatoire | rupture de niveau du ratio S/P |  | non numerique |
| `tests[[42]]$stat_nom` | Z | supF |  | non numerique |
| `tests[[42]]$stat` | 0 | 0.8358227123 | 8.358e-01 | absolu, au-delà du seuil 1e-06 |
| `tests[[42]]$loi` | loi classique INDICATIVE (ratios heteroscedastiques) -> Mon… (67 car.) | supremum de processus -> Monte-Carlo |  | non numerique |
| `tests[[42]]$p_mc` | 1 | 0.821 | 1.790e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[42]]$err_mc` | 0.03163859986 | 0.01212873061 | 6.166e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[42]]$p_retenue` | 1 | 0.821 | 1.790e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[42]]$detail` | pi_t varie avec t : sous le modele ajuste, les r_t sont ind… (691 car.) | Detecte un changement de regime du ratio, independamment du… (67 car.) |  | non numerique |
| `tests[[42]]$p_min` | 0.05714285714 | \<NA\> |  | non fini |
| `tests[[42]]$fonction` | test_runs | stat_supF |  | non numerique |
| `tests[[42]]$p_min_mc` | 0.062 | \<NA\> |  | non fini |
| `tests[[43]]$test` | Rupture de niveau (sup-F) sur ratios bruts | Stabilite cumulee (OLS-CUSUM) sur ratios bruts |  | non numerique |
| `tests[[43]]$reference` | Quandt (1960) / Chow (1960) ; Andrews (1993) | Brown, Durbin & Evans (1975), JRSS B 37 |  | non numerique |
| `tests[[43]]$H0` | niveau du ratio S/P constant | constance du niveau du ratio S/P |  | non numerique |
| `tests[[43]]$H1` | rupture de niveau du ratio S/P | derive graduelle |  | non numerique |
| `tests[[43]]$stat_nom` | supF | CUSUM |  | non numerique |
| `tests[[43]]$stat` | 0.8358227123 | 0.4538884948 | 4.570e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[43]]$loi` | supremum de processus -> Monte-Carlo | sup \|pont brownien\| -> Monte-Carlo |  | non numerique |
| `tests[[43]]$p_mc` | 0.821 | 0.924 | 1.255e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[43]]$err_mc` | 0.01212873061 | 0.008384169267 | 3.087e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[43]]$p_retenue` | 0.821 | 0.924 | 1.255e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[43]]$detail` | Detecte un changement de regime du ratio, independamment du… (67 car.) |  |  | non numerique |
| `tests[[43]]$fonction` | stat_supF | stat_cusum |  | non numerique |
| `tests[[44]]$test` | Stabilite cumulee (OLS-CUSUM) sur ratios bruts | Valeur aberrante isolee (Grubbs) sur ratios bruts |  | non numerique |
| `tests[[44]]$reference` | Brown, Durbin & Evans (1975), JRSS B 37 | Grubbs (1950, 1969), Technometrics 11 |  | non numerique |
| `tests[[44]]$H0` | constance du niveau du ratio S/P | aucun ratio S/P aberrant |  | non numerique |
| `tests[[44]]$H1` | derive graduelle | exactement un ratio aberrant |  | non numerique |
| `tests[[44]]$stat_nom` | CUSUM | G |  | non numerique |
| `tests[[44]]$stat` | 0.4538884948 | 1.835018034 | 3.043e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[44]]$loi` | sup \|pont brownien\| -> Monte-Carlo | loi classique INDICATIVE (ratios heteroscedastiques) -> Mon… (67 car.) |  | non numerique |
| `tests[[44]]$estim_nom` | \<NA\> | rang du ratio extreme |  | non numerique |
| `tests[[44]]$estim` | \<NA\> | 3 |  | non numerique |
| `tests[[44]]$p_mc` | 0.924 | 0.204 | 7.792e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[44]]$err_mc` | 0.008384169267 | 0.01274937436 | 5.206e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[44]]$p_retenue` | 0.924 | 0.204 | 7.792e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[44]]$detail` |  | Identifie l'annee au boni/mali le plus atypique, sans passe… (75 car.) |  | non numerique |
| `tests[[44]]$fonction` | stat_cusum | test_grubbs |  | non numerique |
| `tests[[45]]$test` | Valeur aberrante isolee (Grubbs) sur ratios bruts | Leviers (hat values) |  | non numerique |
| `tests[[45]]$reference` | Grubbs (1950, 1969), Technometrics 11 | Hoaglin & Welsch (1978), Amer. Statist. 32 |  | non numerique |
| `tests[[45]]$type` | test | diagnostic |  | non numerique |
| `tests[[45]]$base` | r | commun |  | non numerique |
| `tests[[45]]$H0` | aucun ratio S/P aberrant | \<NA\> |  | non numerique |
| `tests[[45]]$H1` | exactement un ratio aberrant | \<NA\> |  | non numerique |
| `tests[[45]]$stat_nom` | G | \<NA\> |  | non numerique |
| `tests[[45]]$stat` | 1.835018034 | \<NA\> |  | non fini |
| `tests[[45]]$loi` | loi classique INDICATIVE (ratios heteroscedastiques) -> Mon… (67 car.) | \<NA\> |  | non numerique |
| `tests[[45]]$estim_nom` | rang du ratio extreme | max h_t |  | non numerique |
| `tests[[45]]$estim` | 3 | 0.48 |  | non numerique |
| `tests[[45]]$p_mc` | 0.204 | \<NA\> |  | non fini |
| `tests[[45]]$err_mc` | 0.01274937436 | \<NA\> |  | non fini |
| `tests[[45]]$p_retenue` | 0.204 | \<NA\> |  | non fini |
| `tests[[45]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[45]]$verdict` | OK | INFO |  | non numerique |
| `tests[[45]]$detail` | Identifie l'annee au boni/mali le plus atypique, sans passe… (75 car.) | repere conventionnel 2k/T = 0.250 ; 1 observation(s) au-des… (62 car.) |  | non numerique |
| `tests[[45]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[45]]$fonction` | test_grubbs | usp_tests |  | non numerique |
| `tests[[46]]$famille` | F. Stabilite, ruptures et points aberrants | G. Robustesse de l'estimation |  | non numerique |
| `tests[[46]]$test` | Leviers (hat values) | Sensibilite au retrait d'une annee (jackknife) |  | non numerique |
| `tests[[46]]$reference` | Hoaglin & Welsch (1978), Amer. Statist. 32 | Quenouille (1949) / Tukey (1958) |  | non numerique |
| `tests[[46]]$estim_nom` | max h_t | ecart relatif max |  | non numerique |
| `tests[[46]]$estim` | 0.48 | 0.1662258524 | 6.537e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[46]]$detail` | repere conventionnel 2k/T = 0.250 ; 1 observation(s) au-des… (62 car.) | Annee la plus influente : 3 (sigma_USP en baisse). |  | non numerique |
| `tests[[46]]$fonction` | usp_tests | run_engine |  | non numerique |
| `tests[[47]]$test` | Sensibilite au retrait d'une annee (jackknife) | Largeur relative de l'IC bootstrap 90% |  | non numerique |
| `tests[[47]]$reference` | Quenouille (1949) / Tukey (1958) | Efron (1979), Ann. Statist. 7 |  | non numerique |
| `tests[[47]]$estim_nom` | ecart relatif max | largeur / sigma_USP |  | non numerique |
| `tests[[47]]$estim` | 0.1662258524 | 0.4346439757 | 1.615e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[47]]$detail` | Annee la plus influente : 3 (sigma_USP en baisse). | Intervalle bootstrap du parametre retenu : res$ic_bootstrap. |  | non numerique |
| `tests[[48]]$test` | Largeur relative de l'IC bootstrap 90% | Largeur relative de l'IC bootstrap 90% (delta fixe a delta … (66 car.) |  | non numerique |
| `tests[[48]]$reference` | Efron (1979), Ann. Statist. 7 | Efron (1979), Ann. Statist. 7 ; Andrews (2000), Econometric… (63 car.) |  | non numerique |
| `tests[[48]]$estim` | 0.4346439757 | 0.4531181242 | 4.250e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[48]]$detail` | Intervalle bootstrap du parametre retenu : res$ic_bootstrap. | Bootstrap parametrique a delta fixe a sa valeur estimee (se… (449 car.) |  | non numerique |
| `tests[[49]]$test` | Largeur relative de l'IC bootstrap 90% (delta fixe a delta … (66 car.) | Rapport de vraisemblance : delta = 0 (variance lineaire en … (66 car.) |  | non numerique |
| `tests[[49]]$reference` | Efron (1979), Ann. Statist. 7 ; Andrews (2000), Econometric… (63 car.) | Chernoff (1954) ; Self & Liang (1987), JASA 82 ; Davison & … (82 car.) |  | non numerique |
| `tests[[49]]$H0` | \<NA\> | delta = 0 (variance proportionnelle au volume) |  | non numerique |
| `tests[[49]]$H1` | \<NA\> | delta > 0 |  | non numerique |
| `tests[[49]]$stat_nom` | \<NA\> | LR(0) |  | non numerique |
| `tests[[49]]$stat` | \<NA\> | 0.1649016946 |  | non fini |
| `tests[[49]]$loi` | \<NA\> | sous H0 : loi simulee par bootstrap parametrique restreint … (172 car.) |  | non numerique |
| `tests[[49]]$estim_nom` | largeur / sigma_USP | sigma(delta0, gamma~) |  | non numerique |
| `tests[[49]]$estim` | 0.4531181242 | 0.06676040344 | 8.527e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[49]]$p_asymptotique` | \<NA\> | 0.3423415808 |  | non fini |
| `tests[[49]]$p_mc` | \<NA\> | 0.289 |  | non fini |
| `tests[[49]]$err_mc` | \<NA\> | 0.01434171136 |  | non fini |
| `tests[[49]]$detail` | Bootstrap parametrique a delta fixe a sa valeur estimee (se… (449 car.) | Aucun verdict (ADR 0001) : le LR mesure si les donnees dist… (420 car.) |  | non numerique |
| `tests[[49]]$fonction` | run_engine | usp_lr_delta |  | non numerique |
| `tests[[50]]$test` | Rapport de vraisemblance : delta = 0 (variance lineaire en … (66 car.) | Rapport de vraisemblance : delta = 1 (variance quadratique … (69 car.) |  | non numerique |
| `tests[[50]]$H0` | delta = 0 (variance proportionnelle au volume) | delta = 1 (variance proportionnelle au carre du volume) |  | non numerique |
| `tests[[50]]$H1` | delta > 0 | delta < 1 |  | non numerique |
| `tests[[50]]$stat_nom` | LR(0) | LR(1) |  | non numerique |
| `tests[[50]]$stat` | 0.1649016946 | 0.141073731 | 1.445e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[50]]$estim` | 0.06676040344 | 0.07261597231 | 8.771e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[50]]$p_asymptotique` | 0.3423415808 | 0.3536079516 | 3.291e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[50]]$p_mc` | 0.289 | 0.411 | 4.221e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[50]]$err_mc` | 0.01434171136 | 0.01556667342 | 8.541e-02 | relatif, au-delà du seuil 1e-06 |

## Batteries

- `Rscript tests/test_reproductibilite.R` : code de sortie 0
  - `premium     sigma_USP = 0.1114524114  (21 s)`
  - `CONFORME : 23807 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve1    sigma_USP = 0.1073524114  (17 s)`
  - `CONFORME : 23806 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve2    sigma_USP = 0.0497764613  (35 s)`
  - `CONFORME : 4470 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_ii6 sigma_USP = 0.1483524114  (17 s)`
  - `CONFORME : 23807 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_net sigma_USP = 0.1032524114  (17 s)`
  - `CONFORME : 23807 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_interieur sigma_USP = 0.0871308679  (31 s)`
  - `CONFORME : 23807 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `OK : reproductibilite et non-regression verifiees pour 6 cas.`
- `Rscript tests/test_unitaires.R` : code de sortie 0
  - `TOTAL : 2427 assertions, 2427 ok, 0 echec(s), 0 echec(s) attendu(s) (defauts connus), 0 succes inattendu(s)`
  - `OK`
