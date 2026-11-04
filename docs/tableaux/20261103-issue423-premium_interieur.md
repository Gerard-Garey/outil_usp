# Tableau avant / après — référence `premium_interieur` (issue #423)

- Date : 2026-11-03
- Plateforme : R version 4.3.1 (2023-06-16), Linux
- Commande : `Rscript tests/regenerer_et_rendre_compte.R premium --attendu '^tests\[\[3\]\]\$detail$' --attendu '^tests\[\[([4-9]|[1-4][0-9]|5[0-3])\]\]' reserve1 --attendu '^tests\[\[3\]\]\$detail$' --attendu '^tests\[\[([4-9]|[1-4][0-9]|5[0-3])\]\]' premium_ii6 --attendu '^tests\[\[3\]\]\$detail$' --attendu '^tests\[\[([4-9]|[1-4][0-9]|5[0-3])\]\]' premium_net --attendu '^tests\[\[3\]\]\$detail$' --attendu '^tests\[\[([4-9]|[1-4][0-9]|5[0-3])\]\]' premium_interieur --attendu '^tests\[\[3\]\]\$detail$' --at… (567 car.)`
- Motifs attendus : `^tests\[\[3\]\]\$detail$`, `^tests\[\[([4-9]|[1-4][0-9]|5[0-3])\]\]`
- Exécution à plusieurs cas (M33) : `premium`, `reserve1`, `premium_ii6`, `premium_net`, `premium_interieur`, chacun avec ses motifs ; tout ou rien ; batteries relancées une seule fois, après le dernier cas
- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil 0 pour lister, seuil 1e-06 pour juger ; `INSTABLES` non neutralisé

**Synthèse** : 56937 feuille(s) dans l'ancienne référence, 56964 dans le résultat recalculé ; 737 non strictement identique(s) (dont 736 en écart au seuil 1e-06, 27 ajoutée(s), 0 supprimée(s)), toutes désignées par les motifs attendus ; 56227 feuille(s) identique(s) au bit près ; écart numérique maximal 4.103e+02 (relatif, `tests[[30]]$estim`).

**Avertissement** : motif `^tests\[\[([4-9]|[1-4][0-9]|5[0-3])\]\]` : 736 feuilles désignées (seuil d'avertissement 50) ; vérifier qu'il n'est pas trop large.

Nœuds de structure modifiés (type ou attributs) : `tests[[10]]$stat`, `tests[[11]]$stat`, `tests[[34]]$estim`, `tests[[35]]$estim`, `tests[[41]]$estim`, `tests[[42]]$estim`, `tests[[53]]`, `tests[[53]]$famille`, `tests[[53]]$test`, `tests[[53]]$reference`, `tests[[53]]$type`, `tests[[53]]$base`, `tests[[53]]$variante`, `tests[[53]]$H0`, `tests[[53]]$H1`, `tests[[53]]$stat_nom`, `tests[[53]]$stat`, `tests[[53]]$loi`, `tests[[53]]$estim_nom`, `tests[[53]]$estim`, `tests[[53]]$p_exacte`, `tests[[53]]$p_asymptotique`, `tests[[53]]$p_mc`, `tests[[53]]$err_mc`, `tests[[53]]$p_retenue`, `tests[[53]]$nature_p`, `tests[[53]]$verdict`, `tests[[53]]$detail`, `tests[[53]]$sens`, `tests[[53]]$p_min`, `tests[[53]]$fonction`, `tests[[53]]$inoperant`, `tests[[53]]$p_min_mc`, `tests[[53]]$mc_nom`

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `tests[[53]]$famille` | (absente) | LC. Lecture conjointe de la batterie (toutes familles) |  | ajoutée (absente avant) |
| `tests[[53]]$test` | (absente) | p globale (minP, lecture conjointe de la batterie) |  | ajoutée (absente avant) |
| `tests[[53]]$reference` | (absente) | Westfall & Young (1993), minP en une etape ; Ge, Dudoit & S… (144 car.) |  | ajoutée (absente avant) |
| `tests[[53]]$type` | (absente) | diagnostic |  | ajoutée (absente avant) |
| `tests[[53]]$base` | (absente) | commun |  | ajoutée (absente avant) |
| `tests[[53]]$variante` | (absente) | principale |  | ajoutée (absente avant) |
| `tests[[53]]$H0` | (absente) | toutes les hypotheses nulles des tests de toutes les famill… (89 car.) |  | ajoutée (absente avant) |
| `tests[[53]]$H1` | (absente) | au moins une est fausse |  | ajoutée (absente avant) |
| `tests[[53]]$stat_nom` | (absente) | plus petite p Monte-Carlo de la batterie |  | ajoutée (absente avant) |
| `tests[[53]]$stat` | (absente) | 0.105 |  | ajoutée (absente avant) |
| `tests[[53]]$loi` | (absente) | minimum des p Monte-Carlo -> Monte-Carlo (memes replication… (83 car.) |  | ajoutée (absente avant) |
| `tests[[53]]$estim_nom` | (absente) | nombre de tests |  | ajoutée (absente avant) |
| `tests[[53]]$estim` | (absente) | 22 |  | ajoutée (absente avant) |
| `tests[[53]]$p_exacte` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[53]]$p_asymptotique` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[53]]$p_mc` | (absente) | 0.65 |  | ajoutée (absente avant) |
| `tests[[53]]$err_mc` | (absente) | 0.01509065034 |  | ajoutée (absente avant) |
| `tests[[53]]$p_retenue` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[53]]$nature_p` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[53]]$verdict` | (absente) | INFO |  | ajoutée (absente avant) |
| `tests[[53]]$detail` | (absente) | Lecture conjointe de la batterie (issue #297) : p minP en u… (696 car.) |  | ajoutée (absente avant) |
| `tests[[53]]$sens` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[53]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[53]]$fonction` | (absente) | engine_p_famille |  | ajoutée (absente avant) |
| `tests[[53]]$inoperant` | (absente) | FALSE |  | ajoutée (absente avant) |
| `tests[[53]]$p_min_mc` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[53]]$mc_nom` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[3]]$detail` | … unilaterale (t(T-2) exacte sous le modele auxiliaire MCO se… (806 car., 1re différence au car. 317) | … unilaterale (t(T-2), exacte sous le modele auxiliaire MCO s… (1131 car., 1re différence au car. 317) |  | non numerique |
| `tests[[4]]$test` | Test de Fisher (significativite globale) | Test de Student sur la pente (modele auxiliaire MCO) |  | non numerique |
| `tests[[4]]$reference` | Fisher (1922, 1925) | Student (1908), Biometrika 6 ; Fisher (1922), JRSS 85 |  | non numerique |
| `tests[[4]]$stat_nom` | F | t |  | non numerique |
| `tests[[4]]$stat` | 219.9781086 | 14.831659 | 9.326e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[4]]$loi` | F(1,6) exacte sous le modele auxiliaire MCO | t(6) exacte sous le modele auxiliaire MCO (erreurs i.i.d. n… (84 car.) |  | non numerique |
| `tests[[4]]$p_asymptotique` | 5.908495537e-06 | 5.908495537e-06 | 1.864e-15 | relatif, dérive ≤ 1e-06 |
| `tests[[4]]$detail` | Diagnostic, redondante avec le test de Pitman (F = t^2) : a… (166 car.) | Diagnostic, aucun verdict : la pente est testee par le seul… (375 car.) |  | non numerique |
| `tests[[5]]$test` | Coefficient de determination R2 | Test de Fisher (significativite globale) |  | non numerique |
| `tests[[5]]$reference` | lm(y ~ x) | Fisher (1922, 1925) |  | non numerique |
| `tests[[5]]$H0` | \<NA\> | b = 0 |  | non numerique |
| `tests[[5]]$H1` | \<NA\> | b != 0 |  | non numerique |
| `tests[[5]]$stat_nom` | \<NA\> | F |  | non numerique |
| `tests[[5]]$stat` | \<NA\> | 219.9781086 |  | non fini |
| `tests[[5]]$loi` | \<NA\> | F(1,6) exacte sous le modele auxiliaire MCO |  | non numerique |
| `tests[[5]]$estim_nom` | R2 | \<NA\> |  | non numerique |
| `tests[[5]]$estim` | 0.9734487556 | \<NA\> |  | non fini |
| `tests[[5]]$p_asymptotique` | \<NA\> | 5.908495537e-06 |  | non fini |
| `tests[[5]]$detail` | R2 ajuste = 0.9690 ; sous H0 (b=0) E[R2] = 1/(T-1) = 0.143 … (127 car.) | Diagnostic, redondante avec le test de Pitman (F = t^2) : a… (248 car.) |  | non numerique |
| `tests[[6]]$test` | RESET (forme fonctionnelle) | Coefficient de determination R2 |  | non numerique |
| `tests[[6]]$reference` | Ramsey (1969), JRSS B 31 | lm(y ~ x) |  | non numerique |
| `tests[[6]]$type` | test | diagnostic |  | non numerique |
| `tests[[6]]$H0` | gamma2 = gamma3 = 0 (forme lineaire correcte) | \<NA\> |  | non numerique |
| `tests[[6]]$H1` | forme fonctionnelle mal specifiee | \<NA\> |  | non numerique |
| `tests[[6]]$stat_nom` | F | \<NA\> |  | non numerique |
| `tests[[6]]$stat` | 0.5509005428 | \<NA\> |  | non fini |
| `tests[[6]]$loi` | F(2,5) approx. | \<NA\> |  | non numerique |
| `tests[[6]]$estim_nom` | \<NA\> | R2 |  | non numerique |
| `tests[[6]]$estim` | \<NA\> | 0.9734487556 |  | non fini |
| `tests[[6]]$p_asymptotique` | 0.6078268719 | \<NA\> |  | non fini |
| `tests[[6]]$p_mc` | 0.958 | \<NA\> |  | non fini |
| `tests[[6]]$err_mc` | 0.006346359293 | \<NA\> |  | non fini |
| `tests[[6]]$p_retenue` | 0.958 | \<NA\> |  | non fini |
| `tests[[6]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[6]]$verdict` | OK | INFO |  | non numerique |
| `tests[[6]]$detail` | La loi F(2,T-3) n'est pas exacte sous le modele de l'annexe… (559 car.) | R2 ajuste = 0.9690 ; sous H0 (b=0) E[R2] = 1/(T-1) = 0.143 … (127 car.) |  | non numerique |
| `tests[[6]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[6]]$fonction` | test_reset | test_lm_complet |  | non numerique |
| `tests[[6]]$mc_nom` | RESET | \<NA\> |  | non numerique |
| `tests[[7]]$test` | Independance ratio S/P vs volume | RESET (forme fonctionnelle) |  | non numerique |
| `tests[[7]]$reference` | Spearman (1904) ; exact : Best & Roberts (1975), AS 89 | Ramsey (1969), JRSS B 31 |  | non numerique |
| `tests[[7]]$H0` | independance (aucune association monotone) | gamma2 = gamma3 = 0 (forme lineaire correcte) |  | non numerique |
| `tests[[7]]$H1` | association monotone | forme fonctionnelle mal specifiee |  | non numerique |
| `tests[[7]]$stat_nom` | S | F |  | non numerique |
| `tests[[7]]$stat` | 70 | 0.5509005428 | 9.921e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[7]]$loi` | loi de permutation (T <= 9, sans ex aequo), exacte a pi_t c… (87 car.) | F(2,5) approx. |  | non numerique |
| `tests[[7]]$estim_nom` | rho_s | \<NA\> |  | non numerique |
| `tests[[7]]$estim` | 0.1666666667 | \<NA\> |  | non fini |
| `tests[[7]]$p_asymptotique` | 0.6932388117 | 0.6078268719 | 1.232e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[7]]$p_mc` | 0.69 | 0.958 | 3.884e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[7]]$err_mc` | 0.03007997348 | 0.006346359293 | 7.890e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[7]]$p_retenue` | 0.69 | 0.958 | 3.884e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[7]]$detail` | p exacte non attribuee : loi de reference exacte seulement … (197 car.) | La loi F(2,T-3) n'est pas exacte sous le modele de l'annexe… (559 car.) |  | non numerique |
| `tests[[7]]$p_min` | 4.96031746e-05 | \<NA\> |  | non fini |
| `tests[[7]]$fonction` | usp_tests | test_reset |  | non numerique |
| `tests[[7]]$p_min_mc` | 0.002 | \<NA\> |  | non fini |
| `tests[[7]]$mc_nom` | SpearVol | RESET |  | non numerique |
| `tests[[8]]$test` | Correlation ratio S/P vs temps | Independance ratio S/P vs volume |  | non numerique |
| `tests[[8]]$reference` | Spearman (1904) ; exact : Best & Roberts (1975) | Spearman (1904) ; exact : Best & Roberts (1975), AS 89 |  | non numerique |
| `tests[[8]]$type` | diagnostic | test |  | non numerique |
| `tests[[8]]$H0` | independance entre le ratio et le rang chronologique | independance (aucune association monotone) |  | non numerique |
| `tests[[8]]$H1` | association monotone avec le temps | association monotone |  | non numerique |
| `tests[[8]]$stat` | 72 | 70 | 2.778e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[8]]$estim` | 0.1428571429 | 0.1666666667 | 1.667e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[8]]$p_asymptotique` | 0.7357648599 | 0.6932388117 | 5.780e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[8]]$p_mc` | 0.866 | 0.69 | 2.032e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[8]]$err_mc` | 0.03135326182 | 0.03007997348 | 4.061e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[8]]$p_retenue` | \<NA\> | 0.69 |  | non fini |
| `tests[[8]]$nature_p` | \<NA\> | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) |  | non numerique |
| `tests[[8]]$verdict` | INFO | OK |  | non numerique |
| `tests[[8]]$detail` | …uement distribues). Restituee en diagnostic par decision (is… (338 car., 1re différence au car. 143) | …uement distribues). Une correlation signale un effet d'echel… (197 car., 1re différence au car. 143) |  | non numerique |
| `tests[[8]]$sens` | \<NA\> | ne pas rejeter |  | non numerique |
| `tests[[8]]$p_min_mc` | \<NA\> | 0.002 |  | non fini |
| `tests[[8]]$mc_nom` | SpearTps | SpearVol |  | non numerique |
| `tests[[9]]$test` | Tendance monotone du ratio S/P | Correlation ratio S/P vs temps |  | non numerique |
| `tests[[9]]$reference` | Mann (1945) ; loi exacte : Kendall & Gibbons (1990), ch. 4-5 | Spearman (1904) ; exact : Best & Roberts (1975) |  | non numerique |
| `tests[[9]]$type` | test | diagnostic |  | non numerique |
| `tests[[9]]$H0` | absence de tendance monotone (r_t i.i.d.) | independance entre le ratio et le rang chronologique |  | non numerique |
| `tests[[9]]$H1` | tendance monotone | association monotone avec le temps |  | non numerique |
| `tests[[9]]$stat_nom` | Z | S |  | non numerique |
| `tests[[9]]$stat` | 0.3711537445 | 72 | 1.930e+02 | relatif, au-delà du seuil 1e-06 |
| `tests[[9]]$loi` | loi de S (distribution mahonienne), exacte a pi_t constant … (79 car.) | loi de permutation (T <= 9, sans ex aequo), exacte a pi_t c… (87 car.) |  | non numerique |
| `tests[[9]]$estim_nom` | S de Kendall | rho_s |  | non numerique |
| `tests[[9]]$estim` | 4 | 0.1428571429 | 9.643e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[9]]$p_asymptotique` | 0.7105230229 | 0.7357648599 | 3.553e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[9]]$p_mc` | 0.83 | 0.866 | 4.337e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[9]]$err_mc` | 0.03117807037 | 0.03135326182 | 5.619e-03 | relatif, au-delà du seuil 1e-06 |
| `tests[[9]]$p_retenue` | 0.83 | \<NA\> |  | non fini |
| `tests[[9]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[9]]$verdict` | OK | INFO |  | non numerique |
| `tests[[9]]$detail` | …uement distribues). Une derive du S/P contredit la constance… (190 car., 1re différence au car. 143) | …uement distribues). Restituee en diagnostic par decision (is… (338 car., 1re différence au car. 143) |  | non numerique |
| `tests[[9]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[9]]$fonction` | test_mann_kendall | usp_tests |  | non numerique |
| `tests[[9]]$p_min_mc` | 0.002 | \<NA\> |  | non fini |
| `tests[[9]]$mc_nom` | MK | SpearTps |  | non numerique |
| `tests[[10]]$test` | Tendance par signes du ratio S/P | Tendance monotone du ratio S/P |  | non numerique |
| `tests[[10]]$reference` | Cox & Stuart (1955), Biometrika 42 | Mann (1945) ; loi exacte : Kendall & Gibbons (1990), ch. 4-5 |  | non numerique |
| `tests[[10]]$type` | diagnostic | test |  | non numerique |
| `tests[[10]]$H0` | P(D_t > 0) = 1/2 (absence de tendance) | absence de tendance monotone (r_t i.i.d.) |  | non numerique |
| `tests[[10]]$H1` | P(D_t > 0) != 1/2 | tendance monotone |  | non numerique |
| `tests[[10]]$stat_nom` | K | Z |  | non numerique |
| `tests[[10]]$stat` | 2 | 0.3711537445 |  | non numerique |
| `tests[[10]]$loi` | Binomiale(m, 1/2), m differences non nulles, exacte a pi_t … (136 car.) | loi de S (distribution mahonienne), exacte a pi_t constant … (79 car.) |  | non numerique |
| `tests[[10]]$estim_nom` | \<NA\> | S de Kendall |  | non numerique |
| `tests[[10]]$estim` | \<NA\> | 4 |  | non fini |
| `tests[[10]]$p_asymptotique` | \<NA\> | 0.7105230229 |  | non fini |
| `tests[[10]]$p_mc` | 1 | 0.83 | 1.700e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[10]]$err_mc` | 0 | 0.03117807037 | 3.118e-02 | absolu, au-delà du seuil 1e-06 |
| `tests[[10]]$p_retenue` | \<NA\> | 0.83 |  | non fini |
| `tests[[10]]$nature_p` | \<NA\> | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) |  | non numerique |
| `tests[[10]]$verdict` | INFO | OK |  | non numerique |
| `tests[[10]]$detail` | TEST INOPERANT au seuil alpha = 0.1 : plus petite p-value M… (325 car.) | p exacte non attribuee : loi de reference exacte seulement … (190 car.) |  | non numerique |
| `tests[[10]]$sens` | \<NA\> | ne pas rejeter |  | non numerique |
| `tests[[10]]$p_min` | 0.125 | 4.96031746e-05 | 9.996e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[10]]$fonction` | test_cox_stuart | test_mann_kendall |  | non numerique |
| `tests[[10]]$inoperant` | TRUE | FALSE |  | non numerique |
| `tests[[10]]$p_min_mc` | 0.149 | 0.002 | 9.866e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[10]]$mc_nom` | CoxStuart | MK |  | non numerique |
| `tests[[11]]$famille` | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i… (61 car.) |  | non numerique |
| `tests[[11]]$test` | Heteroscedasticite vs volume - Breusch-Pagan studentise (Ko… (65 car.) | Tendance par signes du ratio S/P |  | non numerique |
| `tests[[11]]$reference` | Breusch & Pagan (1979) ; studentisation de Koenker (1981) | Cox & Stuart (1955), Biometrika 42 |  | non numerique |
| `tests[[11]]$type` | test | diagnostic |  | non numerique |
| `tests[[11]]$H0` | c1 = 0 : la variance des residus standardises ne depend pas… (69 car.) | P(D_t > 0) = 1/2 (absence de tendance) |  | non numerique |
| `tests[[11]]$H1` | variance residuelle dependante du volume | P(D_t > 0) != 1/2 |  | non numerique |
| `tests[[11]]$stat_nom` | LM | K |  | non numerique |
| `tests[[11]]$stat` | 0.07499551527 | 2 |  | non numerique |
| `tests[[11]]$loi` | chi2(1) asymptotique | Binomiale(m, 1/2), m differences non nulles, exacte a pi_t … (136 car.) |  | non numerique |
| `tests[[11]]$p_asymptotique` | 0.7841975221 | \<NA\> |  | non fini |
| `tests[[11]]$p_mc` | 0.377 | 1 | 1.653e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[11]]$err_mc` | 0.01533317013 | 0 | 1.000e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[11]]$p_retenue` | 0.377 | \<NA\> |  | non fini |
| `tests[[11]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[11]]$verdict` | OK | INFO |  | non numerique |
| `tests[[11]]$detail` | Doit etre non significatif si la ponderation pi_t est corre… (361 car.) | TEST INOPERANT au seuil alpha = 0.1 : plus petite p-value M… (325 car.) |  | non numerique |
| `tests[[11]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[11]]$p_min` | \<NA\> | 0.125 |  | non fini |
| `tests[[11]]$fonction` | test_breusch_pagan | test_cox_stuart |  | non numerique |
| `tests[[11]]$inoperant` | FALSE | TRUE |  | non numerique |
| `tests[[11]]$p_min_mc` | \<NA\> | 0.149 |  | non fini |
| `tests[[11]]$mc_nom` | BP | CoxStuart |  | non numerique |
| `tests[[12]]$test` | Heteroscedasticite vs volume - Breusch-Pagan original (non … (67 car.) | Heteroscedasticite vs volume - Breusch-Pagan studentise (Ko… (65 car.) |  | non numerique |
| `tests[[12]]$reference` | Breusch & Pagan (1979), Econometrica 47 | Breusch & Pagan (1979) ; studentisation de Koenker (1981) |  | non numerique |
| `tests[[12]]$type` | diagnostic | test |  | non numerique |
| `tests[[12]]$variante` | secondaire | principale |  | non numerique |
| `tests[[12]]$H0` | c1 = 0 ET erreurs normales : variance residuelle independan… (71 car.) | c1 = 0 : la variance des residus standardises ne depend pas… (69 car.) |  | non numerique |
| `tests[[12]]$stat` | 0.05506918229 | 0.07499551527 | 3.618e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[12]]$loi` | chi2(1) asymptotique, SOUS NORMALITE | chi2(1) asymptotique |  | non numerique |
| `tests[[12]]$p_asymptotique` | 0.8144662412 | 0.7841975221 | 3.716e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[12]]$p_mc` | 0.271 | 0.377 | 3.911e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[12]]$err_mc` | 0.01406260135 | 0.01533317013 | 9.035e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[12]]$p_retenue` | \<NA\> | 0.377 |  | non fini |
| `tests[[12]]$nature_p` | \<NA\> | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) |  | non numerique |
| `tests[[12]]$verdict` | INFO | OK |  | non numerique |
| `tests[[12]]$detail` | Version publiee, avec le facteur 1/2 issu de Var(u^2) = 2 s… (333 car.) | Doit etre non significatif si la ponderation pi_t est corre… (361 car.) |  | non numerique |
| `tests[[12]]$sens` | \<NA\> | ne pas rejeter |  | non numerique |
| `tests[[12]]$fonction` | test_breusch_pagan_original | test_breusch_pagan |  | non numerique |
| `tests[[12]]$mc_nom` | BP79 | BP |  | non numerique |
| `tests[[13]]$test` | Heteroscedasticite (forme quadratique) | Heteroscedasticite vs volume - Breusch-Pagan original (non … (67 car.) |  | non numerique |
| `tests[[13]]$reference` | White (1980), Econometrica 48 | Breusch & Pagan (1979), Econometrica 47 |  | non numerique |
| `tests[[13]]$variante` | principale | secondaire |  | non numerique |
| `tests[[13]]$H0` | c1 = c2 = 0 | c1 = 0 ET erreurs normales : variance residuelle independan… (71 car.) |  | non numerique |
| `tests[[13]]$H1` | heteroscedasticite residuelle de forme quadratique | variance residuelle dependante du volume |  | non numerique |
| `tests[[13]]$stat` | 1.204995059 | 0.05506918229 | 9.543e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[13]]$loi` | chi2(2) asymptotique | chi2(1) asymptotique, SOUS NORMALITE |  | non numerique |
| `tests[[13]]$p_asymptotique` | 0.547442673 | 0.8144662412 | 4.878e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[13]]$p_mc` | 0.429 | 0.271 | 3.683e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[13]]$err_mc` | 0.01565899755 | 0.01406260135 | 1.019e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[13]]$detail` | Restituee en diagnostic par decision (issue #299) : aucun v… (203 car.) | Version publiee, avec le facteur 1/2 issu de Var(u^2) = 2 s… (333 car.) |  | non numerique |
| `tests[[13]]$fonction` | test_white | test_breusch_pagan_original |  | non numerique |
| `tests[[13]]$mc_nom` | White | BP79 |  | non numerique |
| `tests[[14]]$test` | Egalite des variances petits vs gros volumes | Heteroscedasticite (forme quadratique) |  | non numerique |
| `tests[[14]]$reference` | Goldfeld & Quandt (1965), JASA 60 | White (1980), Econometrica 48 |  | non numerique |
| `tests[[14]]$H0` | sigma1^2 = sigma2^2 | c1 = c2 = 0 |  | non numerique |
| `tests[[14]]$H1` | variances inegales entre les deux blocs | heteroscedasticite residuelle de forme quadratique |  | non numerique |
| `tests[[14]]$stat_nom` | F | LM |  | non numerique |
| `tests[[14]]$stat` | 2.285128767 | 1.204995059 | 4.727e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[14]]$loi` | F(4,4) approx. (residus issus d'un ajustement global) | chi2(2) asymptotique |  | non numerique |
| `tests[[14]]$p_asymptotique` | 0.4431393853 | 0.547442673 | 2.354e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[14]]$p_mc` | 0.018 | 0.429 | 2.283e+01 | relatif, au-delà du seuil 1e-06 |
| `tests[[14]]$err_mc` | 0.005975927686 | 0.01565899755 | 1.620e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[14]]$fonction` | test_goldfeld_quandt | test_white |  | non numerique |
| `tests[[14]]$mc_nom` | GQ | White |  | non numerique |
| `tests[[15]]$test` | Homogeneite des dispersions (mediane) | Egalite des variances petits vs gros volumes |  | non numerique |
| `tests[[15]]$reference` | Brown & Forsythe (1974), JASA 69 | Goldfeld & Quandt (1965), JASA 60 |  | non numerique |
| `tests[[15]]$H0` | egalite des dispersions entre les deux groupes | sigma1^2 = sigma2^2 |  | non numerique |
| `tests[[15]]$H1` | dispersions inegales | variances inegales entre les deux blocs |  | non numerique |
| `tests[[15]]$stat_nom` | W | F |  | non numerique |
| `tests[[15]]$stat` | 0.1938544668 | 2.285128767 | 1.079e+01 | relatif, au-delà du seuil 1e-06 |
| `tests[[15]]$loi` | F(1,6) approx. | F(4,4) approx. (residus issus d'un ajustement global) |  | non numerique |
| `tests[[15]]$p_asymptotique` | 0.6751461392 | 0.4431393853 | 3.436e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[15]]$p_mc` | 0.417 | 0.018 | 9.568e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[15]]$err_mc` | 0.01559981905 | 0.005975927686 | 6.169e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[15]]$fonction` | test_brown_forsythe | test_goldfeld_quandt |  | non numerique |
| `tests[[15]]$mc_nom` | BF | GQ |  | non numerique |
| `tests[[16]]$test` | Egalite des lois petits vs gros volumes (2 ech.) | Homogeneite des dispersions (mediane) |  | non numerique |
| `tests[[16]]$reference` | Smirnov (1939) | Brown & Forsythe (1974), JASA 69 |  | non numerique |
| `tests[[16]]$H0` | F1 = F2 (memes lois) | egalite des dispersions entre les deux groupes |  | non numerique |
| `tests[[16]]$H1` | lois differentes | dispersions inegales |  | non numerique |
| `tests[[16]]$stat_nom` | D | W |  | non numerique |
| `tests[[16]]$stat` | 0.25 | 0.1938544668 | 2.246e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[16]]$loi` | loi combinatoire (ks.test, sans ex aequo), exacte a pi_t co… (86 car.) | F(1,6) approx. |  | non numerique |
| `tests[[16]]$p_asymptotique` | \<NA\> | 0.6751461392 |  | non fini |
| `tests[[16]]$p_mc` | 1 | 0.417 | 5.830e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[16]]$err_mc` | 0 | 0.01559981905 | 1.560e-02 | absolu, au-delà du seuil 1e-06 |
| `tests[[16]]$detail` | p exacte non attribuee : loi de reference exacte seulement … (593 car.) | Restituee en diagnostic par decision (issue #299) : aucun v… (203 car.) |  | non numerique |
| `tests[[16]]$p_min` | 0.02857142857 | \<NA\> |  | non fini |
| `tests[[16]]$fonction` | usp_tests | test_brown_forsythe |  | non numerique |
| `tests[[16]]$mc_nom` | Smirnov | BF |  | non numerique |
| `tests[[17]]$test` | Position de delta dans [0,1] | Egalite des lois petits vs gros volumes (2 ech.) |  | non numerique |
| `tests[[17]]$reference` | Annexe XVII, section B, paragraphe 6 | Smirnov (1939) |  | non numerique |
| `tests[[17]]$H0` | \<NA\> | F1 = F2 (memes lois) |  | non numerique |
| `tests[[17]]$H1` | \<NA\> | lois differentes |  | non numerique |
| `tests[[17]]$stat_nom` | \<NA\> | D |  | non numerique |
| `tests[[17]]$stat` | \<NA\> | 0.25 |  | non fini |
| `tests[[17]]$loi` | \<NA\> | loi combinatoire (ks.test, sans ex aequo), exacte a pi_t co… (86 car.) |  | non numerique |
| `tests[[17]]$estim_nom` | delta | \<NA\> |  | non numerique |
| `tests[[17]]$estim` | 0.6639907421 | \<NA\> |  | non fini |
| `tests[[17]]$p_mc` | \<NA\> | 1 |  | non fini |
| `tests[[17]]$err_mc` | \<NA\> | 0 |  | non fini |
| `tests[[17]]$detail` | interieur du domaine : melange des deux composantes identif… (61 car.) | p exacte non attribuee : loi de reference exacte seulement … (593 car.) |  | non numerique |
| `tests[[17]]$p_min` | \<NA\> | 0.02857142857 |  | non fini |
| `tests[[17]]$fonction` | usp_ajuster | usp_tests |  | non numerique |
| `tests[[17]]$mc_nom` | \<NA\> | Smirnov |  | non numerique |
| `tests[[18]]$famille` | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | C. H2 - structure de variance (annexe XVII B(2)(g)(ii)) |  | non numerique |
| `tests[[18]]$test` | Shapiro-Wilk sur residus standardises | Position de delta dans [0,1] |  | non numerique |
| `tests[[18]]$reference` | Shapiro & Wilk (1965), Biometrika 52 | Annexe XVII, section B, paragraphe 6 |  | non numerique |
| `tests[[18]]$type` | test | diagnostic |  | non numerique |
| `tests[[18]]$H0` | les residus standardises suivent une loi normale | \<NA\> |  | non numerique |
| `tests[[18]]$H1` | loi non normale | \<NA\> |  | non numerique |
| `tests[[18]]$stat_nom` | W | \<NA\> |  | non numerique |
| `tests[[18]]$stat` | 0.9516450677 | \<NA\> |  | non fini |
| `tests[[18]]$loi` | aucune forme fermee ; normalisation de Royston (1992) | \<NA\> |  | non numerique |
| `tests[[18]]$estim_nom` | \<NA\> | delta |  | non numerique |
| `tests[[18]]$estim` | \<NA\> | 0.6639907421 |  | non fini |
| `tests[[18]]$p_asymptotique` | 0.7278028157 | \<NA\> |  | non fini |
| `tests[[18]]$p_mc` | 0.738 | \<NA\> |  | non fini |
| `tests[[18]]$err_mc` | 0.01391220865 | \<NA\> |  | non fini |
| `tests[[18]]$p_retenue` | 0.738 | \<NA\> |  | non fini |
| `tests[[18]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[18]]$verdict` | OK | INFO |  | non numerique |
| `tests[[18]]$detail` | p non simulee etablie pour un echantillon i.i.d. normal, qu… (151 car.) | interieur du domaine : melange des deux composantes identif… (61 car.) |  | non numerique |
| `tests[[18]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[18]]$fonction` | .shapiro_sur | usp_ajuster |  | non numerique |
| `tests[[18]]$mc_nom` | SW | \<NA\> |  | non numerique |
| `tests[[19]]$test` | Shapiro-Francia | Shapiro-Wilk sur residus standardises |  | non numerique |
| `tests[[19]]$reference` | Shapiro & Francia (1972), JASA 67 ; p-value : Royston (1993… (75 car.) | Shapiro & Wilk (1965), Biometrika 52 |  | non numerique |
| `tests[[19]]$stat_nom` | W' | W |  | non numerique |
| `tests[[19]]$stat` | 0.9512124759 | 0.9516450677 | 4.548e-04 | relatif, au-delà du seuil 1e-06 |
| `tests[[19]]$loi` | aucune forme fermee ; normalisation de Royston (1993) | aucune forme fermee ; normalisation de Royston (1992) |  | non numerique |
| `tests[[19]]$p_asymptotique` | 0.7162715023 | 0.7278028157 | 1.610e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[19]]$p_mc` | 0.65 | 0.738 | 1.354e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[19]]$err_mc` | 0.01509065034 | 0.01391220865 | 7.809e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[19]]$p_retenue` | 0.65 | 0.738 | 1.354e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[19]]$fonction` | test_shapiro_francia | .shapiro_sur |  | non numerique |
| `tests[[19]]$mc_nom` | SF | SW |  | non numerique |
| `tests[[20]]$test` | Anderson-Darling | Shapiro-Francia |  | non numerique |
| `tests[[20]]$reference` | Anderson & Darling (1954), JASA 49 | Shapiro & Francia (1972), JASA 67 ; p-value : Royston (1993… (75 car.) |  | non numerique |
| `tests[[20]]$stat_nom` | A2 | W' |  | non numerique |
| `tests[[20]]$stat` | 0.2545970281 | 0.9512124759 | 2.736e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[20]]$loi` | loi AD, cas parametres estimes ; p non simulee : ajustement… (176 car.) | aucune forme fermee ; normalisation de Royston (1993) |  | non numerique |
| `tests[[20]]$estim_nom` | A2 sur (z - zbar)/s_z | \<NA\> |  | non numerique |
| `tests[[20]]$estim` | 0.2348745239 | \<NA\> |  | non fini |
| `tests[[20]]$p_asymptotique` | 0.6941127037 | 0.7162715023 | 3.192e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[20]]$p_mc` | 0.795 | 0.65 | 1.824e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[20]]$err_mc` | 0.0127725541 | 0.01509065034 | 1.815e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[20]]$p_retenue` | 0.795 | 0.65 | 1.824e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[20]]$detail` | Sensible aux queues. p non simulee : ajustement empirique d… (277 car.) | p non simulee etablie pour un echantillon i.i.d. normal, qu… (151 car.) |  | non numerique |
| `tests[[20]]$fonction` | stat_ad | test_shapiro_francia |  | non numerique |
| `tests[[20]]$mc_nom` | AD | SF |  | non numerique |
| `tests[[21]]$test` | Cramer-von Mises | Anderson-Darling |  | non numerique |
| `tests[[21]]$reference` | Cramer (1928) / von Mises (1928) ; Stephens (1974) | Anderson & Darling (1954), JASA 49 |  | non numerique |
| `tests[[21]]$type` | diagnostic | test |  | non numerique |
| `tests[[21]]$stat_nom` | W2 | A2 |  | non numerique |
| `tests[[21]]$stat` | 0.03449000726 | 0.2545970281 | 6.382e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[21]]$loi` | loi CvM, cas parametres estimes ; p non simulee : ajustemen… (177 car.) | loi AD, cas parametres estimes ; p non simulee : ajustement… (176 car.) |  | non numerique |
| `tests[[21]]$estim_nom` | W2 sur (z - zbar)/s_z | A2 sur (z - zbar)/s_z |  | non numerique |
| `tests[[21]]$estim` | 0.03433215839 | 0.2348745239 | 5.841e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[21]]$p_asymptotique` | 0.7458521082 | 0.6941127037 | 6.937e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[21]]$p_mc` | 0.823 | 0.795 | 3.402e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[21]]$err_mc` | 0.01207546342 | 0.0127725541 | 5.773e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[21]]$p_retenue` | \<NA\> | 0.795 |  | non fini |
| `tests[[21]]$nature_p` | \<NA\> | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) |  | non numerique |
| `tests[[21]]$verdict` | INFO | OK |  | non numerique |
| `tests[[21]]$detail` | p non simulee etablie pour un echantillon i.i.d. normal, qu… (353 car.) | Sensible aux queues. p non simulee : ajustement empirique d… (277 car.) |  | non numerique |
| `tests[[21]]$sens` | \<NA\> | ne pas rejeter |  | non numerique |
| `tests[[21]]$fonction` | stat_cvm | stat_ad |  | non numerique |
| `tests[[21]]$mc_nom` | CvM | AD |  | non numerique |
| `tests[[22]]$test` | Kolmogorov-Smirnov contre N(0,1) | Cramer-von Mises |  | non numerique |
| `tests[[22]]$reference` | Kolmogorov (1933) ; Smirnov (1948) | Cramer (1928) / von Mises (1928) ; Stephens (1974) |  | non numerique |
| `tests[[22]]$variante` | secondaire | principale |  | non numerique |
| `tests[[22]]$stat_nom` | D | W2 |  | non numerique |
| `tests[[22]]$stat` | 0.1786862773 | 0.03449000726 | 8.070e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[22]]$loi` | loi de Kolmogorov (valable a parametres CONNUS) | loi CvM, cas parametres estimes ; p non simulee : ajustemen… (177 car.) |  | non numerique |
| `tests[[22]]$estim_nom` | \<NA\> | W2 sur (z - zbar)/s_z |  | non numerique |
| `tests[[22]]$estim` | \<NA\> | 0.03433215839 |  | non fini |
| `tests[[22]]$p_asymptotique` | 0.9603851023 | 0.7458521082 | 2.234e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[22]]$p_mc` | 0.695 | 0.823 | 1.842e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[22]]$err_mc` | 0.01456664639 | 0.01207546342 | 1.710e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[22]]$detail` | Les residus sont standardises par le MODELE, dont les param… (720 car.) | p non simulee etablie pour un echantillon i.i.d. normal, qu… (353 car.) |  | non numerique |
| `tests[[22]]$fonction` | stat_ks | stat_cvm |  | non numerique |
| `tests[[22]]$mc_nom` | KS | CvM |  | non numerique |
| `tests[[23]]$test` | Lilliefors (KS a parametres estimes) | Kolmogorov-Smirnov contre N(0,1) |  | non numerique |
| `tests[[23]]$reference` | Lilliefors (1967), JASA 62 ; p-value : Dallal & Wilkinson (… (64 car.) | Kolmogorov (1933) ; Smirnov (1948) |  | non numerique |
| `tests[[23]]$type` | test | diagnostic |  | non numerique |
| `tests[[23]]$variante` | principale | secondaire |  | non numerique |
| `tests[[23]]$stat` | 0.1786360997 | 0.1786862773 | 2.809e-04 | relatif, au-delà du seuil 1e-06 |
| `tests[[23]]$loi` | loi de Lilliefors (moyenne et ecart-type estimes) | loi de Kolmogorov (valable a parametres CONNUS) |  | non numerique |
| `tests[[23]]$p_asymptotique` | 0.6360477573 | 0.9603851023 | 5.099e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[23]]$p_mc` | 0.606 | 0.695 | 1.469e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[23]]$err_mc` | 0.01545972196 | 0.01456664639 | 5.777e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[23]]$p_retenue` | 0.606 | \<NA\> |  | non fini |
| `tests[[23]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[23]]$verdict` | OK | INFO |  | non numerique |
| `tests[[23]]$detail` | Distinct du KS contre N(0,1) : la loi de reference tient co… (329 car.) | Les residus sont standardises par le MODELE, dont les param… (720 car.) |  | non numerique |
| `tests[[23]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[23]]$fonction` | stat_lilliefors | stat_ks |  | non numerique |
| `tests[[23]]$mc_nom` | Lillie | KS |  | non numerique |
| `tests[[24]]$test` | Jarque-Bera | Lilliefors (KS a parametres estimes) |  | non numerique |
| `tests[[24]]$reference` | Jarque & Bera (1980, 1987) | Lilliefors (1967), JASA 62 ; p-value : Dallal & Wilkinson (… (64 car.) |  | non numerique |
| `tests[[24]]$H0` | asymetrie nulle ET aplatissement egal a 3 | les residus standardises suivent une loi normale |  | non numerique |
| `tests[[24]]$H1` | asymetrie ou aplatissement non normaux | loi non normale |  | non numerique |
| `tests[[24]]$stat_nom` | JB | D |  | non numerique |
| `tests[[24]]$stat` | 0.2975763686 | 0.1786360997 | 3.997e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[24]]$loi` | chi2(2) asymptotique | loi de Lilliefors (moyenne et ecart-type estimes) |  | non numerique |
| `tests[[24]]$p_asymptotique` | 0.8617516281 | 0.6360477573 | 2.619e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[24]]$p_mc` | 0.862 | 0.606 | 2.970e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[24]]$err_mc` | 0.01091215263 | 0.01545972196 | 4.167e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[24]]$p_retenue` | 0.862 | 0.606 | 2.970e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[24]]$detail` | asymetrie et aplatissement : estimations des lignes D'Agost… (281 car.) | Distinct du KS contre N(0,1) : la loi de reference tient co… (329 car.) |  | non numerique |
| `tests[[24]]$fonction` | test_jarque_bera | stat_lilliefors |  | non numerique |
| `tests[[24]]$mc_nom` | JB | Lillie |  | non numerique |
| `tests[[25]]$test` | Asymetrie (D'Agostino, T >= 8) | Jarque-Bera |  | non numerique |
| `tests[[25]]$reference` | D'Agostino (1970), Biometrika 57 | Jarque & Bera (1980, 1987) |  | non numerique |
| `tests[[25]]$H0` | coefficient d'asymetrie de la population nul | asymetrie nulle ET aplatissement egal a 3 |  | non numerique |
| `tests[[25]]$H1` | asymetrie non nulle | asymetrie ou aplatissement non normaux |  | non numerique |
| `tests[[25]]$stat_nom` | Z | JB |  | non numerique |
| `tests[[25]]$stat` | 0.6675390096 | 0.2975763686 | 5.542e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[25]]$loi` | N(0,1) approx. (transformation de Johnson SU) | chi2(2) asymptotique |  | non numerique |
| `tests[[25]]$estim_nom` | asymetrie | \<NA\> |  | non numerique |
| `tests[[25]]$estim` | 0.3970065247 | \<NA\> |  | non fini |
| `tests[[25]]$p_asymptotique` | 0.5044279008 | 0.8617516281 | 7.084e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[25]]$p_mc` | 0.334 | 0.862 | 1.581e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[25]]$err_mc` | 0.02360086865 | 0.01091215263 | 5.376e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[25]]$p_retenue` | 0.334 | 0.862 | 1.581e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[25]]$detail` | p non simulee etablie pour un echantillon i.i.d. normal, qu… (151 car.) | asymetrie et aplatissement : estimations des lignes D'Agost… (281 car.) |  | non numerique |
| `tests[[25]]$fonction` | test_dagostino_skew | test_jarque_bera |  | non numerique |
| `tests[[25]]$mc_nom` | DAgo | JB |  | non numerique |
| `tests[[26]]$test` | Aplatissement (Anscombe-Glynn, T >= 20) | Asymetrie (D'Agostino, T >= 8) |  | non numerique |
| `tests[[26]]$reference` | Anscombe & Glynn (1983), Biometrika 70 | D'Agostino (1970), Biometrika 57 |  | non numerique |
| `tests[[26]]$type` | non applicable | test |  | non numerique |
| `tests[[26]]$H0` | \<NA\> | coefficient d'asymetrie de la population nul |  | non numerique |
| `tests[[26]]$H1` | \<NA\> | asymetrie non nulle |  | non numerique |
| `tests[[26]]$stat_nom` | \<NA\> | Z |  | non numerique |
| `tests[[26]]$stat` | \<NA\> | 0.6675390096 |  | non fini |
| `tests[[26]]$loi` | \<NA\> | N(0,1) approx. (transformation de Johnson SU) |  | non numerique |
| `tests[[26]]$estim_nom` | aplatissement | asymetrie |  | non numerique |
| `tests[[26]]$estim` | 2.487874641 | 0.3970065247 | 8.404e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[26]]$p_asymptotique` | \<NA\> | 0.5044279008 |  | non fini |
| `tests[[26]]$p_mc` | \<NA\> | 0.334 |  | non fini |
| `tests[[26]]$err_mc` | \<NA\> | 0.02360086865 |  | non fini |
| `tests[[26]]$p_retenue` | \<NA\> | 0.334 |  | non fini |
| `tests[[26]]$nature_p` | \<NA\> | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) |  | non numerique |
| `tests[[26]]$verdict` | INFO | OK |  | non numerique |
| `tests[[26]]$detail` | T = 8 < 20 : test non defini | p non simulee etablie pour un echantillon i.i.d. normal, qu… (151 car.) |  | non numerique |
| `tests[[26]]$sens` | \<NA\> | ne pas rejeter |  | non numerique |
| `tests[[26]]$fonction` | test_anscombe_kurt | test_dagostino_skew |  | non numerique |
| `tests[[26]]$mc_nom` | \<NA\> | DAgo |  | non numerique |
| `tests[[27]]$famille` | E. H4 - independance et validite du MV (annexe XVII B(2)(g)… (64 car.) | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) |  | non numerique |
| `tests[[27]]$test` | Autocorrelation d'ordre 1 (Durbin-Watson) | Aplatissement (Anscombe-Glynn, T >= 20) |  | non numerique |
| `tests[[27]]$reference` | Durbin & Watson (1950, 1951) | Anscombe & Glynn (1983), Biometrika 70 |  | non numerique |
| `tests[[27]]$type` | test | non applicable |  | non numerique |
| `tests[[27]]$base` | z | commun |  | non numerique |
| `tests[[27]]$H0` | rho = 0 (absence d'autocorrelation d'ordre 1) | \<NA\> |  | non numerique |
| `tests[[27]]$H1` | rho != 0 | \<NA\> |  | non numerique |
| `tests[[27]]$stat_nom` | DW | \<NA\> |  | non numerique |
| `tests[[27]]$stat` | 2.428176394 | \<NA\> |  | non fini |
| `tests[[27]]$loi` | forme quadratique en normales ; loi par la methode d'Imhof … (110 car.) | \<NA\> |  | non numerique |
| `tests[[27]]$estim_nom` | \<NA\> | aplatissement |  | non numerique |
| `tests[[27]]$estim` | \<NA\> | 2.487874641 |  | non fini |
| `tests[[27]]$p_mc` | 0.39 | \<NA\> |  | non fini |
| `tests[[27]]$err_mc` | 0.02507047125 | \<NA\> |  | non fini |
| `tests[[27]]$p_retenue` | 0.39 | \<NA\> |  | non fini |
| `tests[[27]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[27]]$verdict` | OK | INFO |  | non numerique |
| `tests[[27]]$detail` | p exacte non attribuee : loi de reference exacte seulement … (319 car.) | T = 8 < 20 : test non defini |  | non numerique |
| `tests[[27]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[27]]$fonction` | stat_dw | test_anscombe_kurt |  | non numerique |
| `tests[[27]]$mc_nom` | DW | \<NA\> |  | non numerique |
| `tests[[28]]$test` | Ljung-Box (retard 2) | Autocorrelation d'ordre 1 (Durbin-Watson) |  | non numerique |
| `tests[[28]]$reference` | Ljung & Box (1978), Biometrika 65 | Durbin & Watson (1950, 1951) |  | non numerique |
| `tests[[28]]$base` | commun | z |  | non numerique |
| `tests[[28]]$H0` | rho_1 = rho_2 = 0 | rho = 0 (absence d'autocorrelation d'ordre 1) |  | non numerique |
| `tests[[28]]$H1` | autocorrelation jusqu'au retard 2 | rho != 0 |  | non numerique |
| `tests[[28]]$stat_nom` | Q | DW |  | non numerique |
| `tests[[28]]$stat` | 3.269508088 | 2.428176394 | 2.573e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[28]]$loi` | chi2(2) asymptotique | forme quadratique en normales ; loi par la methode d'Imhof … (110 car.) |  | non numerique |
| `tests[[28]]$p_asymptotique` | 0.1950003269 | \<NA\> |  | non fini |
| `tests[[28]]$p_mc` | 0.22 | 0.39 | 7.727e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[28]]$err_mc` | 0.01310617304 | 0.02507047125 | 9.129e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[28]]$p_retenue` | 0.22 | 0.39 | 7.727e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[28]]$detail` |  | p exacte non attribuee : loi de reference exacte seulement … (319 car.) |  | non numerique |
| `tests[[28]]$fonction` | usp_tests | stat_dw |  | non numerique |
| `tests[[28]]$mc_nom` | LB2 | DW |  | non numerique |
| `tests[[29]]$test` | Test des suites (aleatoire des signes) | Ljung-Box (retard 2) |  | non numerique |
| `tests[[29]]$reference` | Wald & Wolfowitz (1940) ; loi exacte : Swed & Eisenhart (19… (62 car.) | Ljung & Box (1978), Biometrika 65 |  | non numerique |
| `tests[[29]]$base` | z | commun |  | non numerique |
| `tests[[29]]$H0` | la suite des signes est un arrangement aleatoire | rho_1 = rho_2 = 0 |  | non numerique |
| `tests[[29]]$H1` | arrangement non aleatoire (regroupement ou alternance) | autocorrelation jusqu'au retard 2 |  | non numerique |
| `tests[[29]]$stat_nom` | Z | Q |  | non numerique |
| `tests[[29]]$stat` | 0 | 3.269508088 | 3.270e+00 | absolu, au-delà du seuil 1e-06 |
| `tests[[29]]$loi` | loi combinatoire de R, exacte a pi_t constant seulement (re… (66 car.) | chi2(2) asymptotique |  | non numerique |
| `tests[[29]]$estim_nom` | nb de suites R | \<NA\> |  | non numerique |
| `tests[[29]]$estim` | 5 | \<NA\> |  | non fini |
| `tests[[29]]$p_asymptotique` | 1 | 0.1950003269 | 8.050e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[29]]$p_mc` | 1 | 0.22 | 7.800e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[29]]$err_mc` | 0.03163859986 | 0.01310617304 | 5.858e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[29]]$p_retenue` | 1 | 0.22 | 7.800e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[29]]$detail` | p exacte non attribuee : loi de reference exacte seulement … (263 car.) |  |  | non numerique |
| `tests[[29]]$p_min` | 0.05714285714 | \<NA\> |  | non fini |
| `tests[[29]]$fonction` | test_runs | usp_tests |  | non numerique |
| `tests[[29]]$p_min_mc` | 0.058 | \<NA\> |  | non fini |
| `tests[[29]]$mc_nom` | Runs | LB2 |  | non numerique |
| `tests[[30]]$test` | Centrage des residus standardises | Test des suites (aleatoire des signes) |  | non numerique |
| `tests[[30]]$reference` | Diagnostic de centrage (ADR 0001) | Wald & Wolfowitz (1940) ; loi exacte : Swed & Eisenhart (19… (62 car.) |  | non numerique |
| `tests[[30]]$type` | diagnostic | test |  | non numerique |
| `tests[[30]]$base` | commun | z |  | non numerique |
| `tests[[30]]$H0` | \<NA\> | la suite des signes est un arrangement aleatoire |  | non numerique |
| `tests[[30]]$H1` | \<NA\> | arrangement non aleatoire (regroupement ou alternance) |  | non numerique |
| `tests[[30]]$stat_nom` | \<NA\> | Z |  | non numerique |
| `tests[[30]]$stat` | \<NA\> | 0 |  | non fini |
| `tests[[30]]$loi` | \<NA\> | loi combinatoire de R, exacte a pi_t constant seulement (re… (66 car.) |  | non numerique |
| `tests[[30]]$estim_nom` | moyenne(z) | nb de suites R |  | non numerique |
| `tests[[30]]$estim` | -0.01221722251 | 5 | 4.103e+02 | relatif, au-delà du seuil 1e-06 |
| `tests[[30]]$p_asymptotique` | \<NA\> | 1 |  | non fini |
| `tests[[30]]$p_mc` | \<NA\> | 1 |  | non fini |
| `tests[[30]]$err_mc` | \<NA\> | 0.03163859986 |  | non fini |
| `tests[[30]]$p_retenue` | \<NA\> | 1 |  | non fini |
| `tests[[30]]$nature_p` | \<NA\> | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) |  | non numerique |
| `tests[[30]]$verdict` | INFO | OK |  | non numerique |
| `tests[[30]]$detail` | Grandeur rivee par l'estimation : somme(sqrt(pi_t) z_t) = 0… (434 car.) | p exacte non attribuee : loi de reference exacte seulement … (263 car.) |  | non numerique |
| `tests[[30]]$sens` | \<NA\> | ne pas rejeter |  | non numerique |
| `tests[[30]]$p_min` | \<NA\> | 0.05714285714 |  | non fini |
| `tests[[30]]$fonction` | usp_tests | test_runs |  | non numerique |
| `tests[[30]]$p_min_mc` | \<NA\> | 0.058 |  | non fini |
| `tests[[30]]$mc_nom` | \<NA\> | Runs |  | non numerique |
| `tests[[31]]$test` | Variance unitaire des residus standardises | Centrage des residus standardises |  | non numerique |
| `tests[[31]]$reference` | Diagnostic d'echelle (ADR 0001) | Diagnostic de centrage (ADR 0001) |  | non numerique |
| `tests[[31]]$estim_nom` | var(z) | moyenne(z) |  | non numerique |
| `tests[[31]]$estim` | 1.138959 | -0.01221722251 | 1.011e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[31]]$detail` | Grandeur rivee par l'estimation : la condition du premier o… (819 car.) | Grandeur rivee par l'estimation : somme(sqrt(pi_t) z_t) = 0… (434 car.) |  | non numerique |
| `tests[[32]]$famille` | F. Stabilite, ruptures et points aberrants | E. H4 - independance et validite du MV (annexe XVII B(2)(g)… (64 car.) |  | non numerique |
| `tests[[32]]$test` | Rupture de niveau (sup-F) | Variance unitaire des residus standardises |  | non numerique |
| `tests[[32]]$reference` | Quandt (1960) / Chow (1960) ; Andrews (1993) | Diagnostic d'echelle (ADR 0001) |  | non numerique |
| `tests[[32]]$type` | test | diagnostic |  | non numerique |
| `tests[[32]]$base` | z | commun |  | non numerique |
| `tests[[32]]$H0` | E[z_t] constant (absence de rupture) | \<NA\> |  | non numerique |
| `tests[[32]]$H1` | rupture de niveau a une date inconnue | \<NA\> |  | non numerique |
| `tests[[32]]$stat_nom` | supF | \<NA\> |  | non numerique |
| `tests[[32]]$stat` | 0.5998246848 | \<NA\> |  | non fini |
| `tests[[32]]$loi` | supremum de processus (Andrews) -> Monte-Carlo | \<NA\> |  | non numerique |
| `tests[[32]]$estim_nom` | \<NA\> | var(z) |  | non numerique |
| `tests[[32]]$estim` | \<NA\> | 1.138959 |  | non fini |
| `tests[[32]]$p_mc` | 0.911 | \<NA\> |  | non fini |
| `tests[[32]]$err_mc` | 0.009008893393 | \<NA\> |  | non fini |
| `tests[[32]]$p_retenue` | 0.911 | \<NA\> |  | non fini |
| `tests[[32]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[32]]$verdict` | OK | INFO |  | non numerique |
| `tests[[32]]$detail` | La loi de Fisher est inapplicable : le point de rupture est… (66 car.) | Grandeur rivee par l'estimation : la condition du premier o… (819 car.) |  | non numerique |
| `tests[[32]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[32]]$fonction` | stat_supF | usp_tests |  | non numerique |
| `tests[[32]]$mc_nom` | supF | \<NA\> |  | non numerique |
| `tests[[33]]$test` | Stabilite cumulee (OLS-CUSUM) | Rupture de niveau (sup-F) |  | non numerique |
| `tests[[33]]$reference` | Brown, Durbin & Evans (1975), JRSS B 37 | Quandt (1960) / Chow (1960) ; Andrews (1993) |  | non numerique |
| `tests[[33]]$H0` | constance des parametres sur la periode | E[z_t] constant (absence de rupture) |  | non numerique |
| `tests[[33]]$H1` | niveau non constant (derive ou rupture) | rupture de niveau a une date inconnue |  | non numerique |
| `tests[[33]]$stat_nom` | CUSUM | supF |  | non numerique |
| `tests[[33]]$stat` | 0.4089644933 | 0.5998246848 | 4.667e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[33]]$loi` | sup \|pont brownien\| ; formule de Kolmogorov asymptotique | supremum de processus (Andrews) -> Monte-Carlo |  | non numerique |
| `tests[[33]]$p_asymptotique` | 0.9961636511 | \<NA\> |  | non fini |
| `tests[[33]]$p_mc` | 0.954 | 0.911 | 4.507e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[33]]$err_mc` | 0.006627814717 | 0.009008893393 | 3.593e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[33]]$p_retenue` | 0.954 | 0.911 | 4.507e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[33]]$detail` | La formule asymptotique n'a aucune validite a T = 8 ; p_mc … (135 car.) | La loi de Fisher est inapplicable : le point de rupture est… (66 car.) |  | non numerique |
| `tests[[33]]$fonction` | stat_cusum | stat_supF |  | non numerique |
| `tests[[33]]$mc_nom` | CUSUM | supF |  | non numerique |
| `tests[[34]]$test` | Valeur aberrante isolee (Grubbs) | Stabilite cumulee (OLS-CUSUM) |  | non numerique |
| `tests[[34]]$reference` | Grubbs (1950, 1969), Technometrics 11 | Brown, Durbin & Evans (1975), JRSS B 37 |  | non numerique |
| `tests[[34]]$H0` | aucune valeur aberrante (echantillon normal homogene) | constance des parametres sur la periode |  | non numerique |
| `tests[[34]]$H1` | exactement une valeur aberrante | niveau non constant (derive ou rupture) |  | non numerique |
| `tests[[34]]$stat_nom` | G | CUSUM |  | non numerique |
| `tests[[34]]$stat` | 1.793630721 | 0.4089644933 | 7.720e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[34]]$loi` | Student + borne de Bonferroni, calibree pour un echantillon… (167 car.) | sup \|pont brownien\| ; formule de Kolmogorov asymptotique |  | non numerique |
| `tests[[34]]$estim_nom` | rang de l'obs. extreme | \<NA\> |  | non numerique |
| `tests[[34]]$estim` | 3 | \<NA\> |  | non numerique |
| `tests[[34]]$p_asymptotique` | 0.3357596655 | 0.9961636511 | 1.967e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[34]]$p_mc` | 0.105 | 0.954 | 8.086e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[34]]$err_mc` | 0.009698921026 | 0.006627814717 | 3.166e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[34]]$p_retenue` | 0.105 | 0.954 | 8.086e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[34]]$detail` | G est borne par (T-1)/sqrt(T) = 2.475 ; verdict sensible a … (128 car.) | La formule asymptotique n'a aucune validite a T = 8 ; p_mc … (135 car.) |  | non numerique |
| `tests[[34]]$fonction` | test_grubbs | stat_cusum |  | non numerique |
| `tests[[34]]$mc_nom` | Grubbs | CUSUM |  | non numerique |
| `tests[[35]]$test` | Valeurs aberrantes multiples (ESD generalise) | Valeur aberrante isolee (Grubbs) |  | non numerique |
| `tests[[35]]$reference` | Rosner (1983), Technometrics 25 | Grubbs (1950, 1969), Technometrics 11 |  | non numerique |
| `tests[[35]]$type` | diagnostic | test |  | non numerique |
| `tests[[35]]$base` | commun | z |  | non numerique |
| `tests[[35]]$H0` | aucune valeur aberrante | aucune valeur aberrante (echantillon normal homogene) |  | non numerique |
| `tests[[35]]$H1` | il existe i <= k valeurs aberrantes | exactement une valeur aberrante |  | non numerique |
| `tests[[35]]$stat_nom` | \<NA\> | G |  | non numerique |
| `tests[[35]]$stat` | \<NA\> | 1.793630721 |  | non fini |
| `tests[[35]]$loi` | \<NA\> | Student + borne de Bonferroni, calibree pour un echantillon… (167 car.) |  | non numerique |
| `tests[[35]]$estim_nom` | nb de valeurs aberrantes | rang de l'obs. extreme |  | non numerique |
| `tests[[35]]$estim` | 0 | 3 |  | non numerique |
| `tests[[35]]$p_asymptotique` | \<NA\> | 0.3357596655 |  | non fini |
| `tests[[35]]$p_mc` | \<NA\> | 0.105 |  | non fini |
| `tests[[35]]$err_mc` | \<NA\> | 0.009698921026 |  | non fini |
| `tests[[35]]$p_retenue` | \<NA\> | 0.105 |  | non fini |
| `tests[[35]]$nature_p` | \<NA\> | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) |  | non numerique |
| `tests[[35]]$verdict` | INFO | OK |  | non numerique |
| `tests[[35]]$detail` | procedure ESD de Rosner (1983) a niveau nominal alpha = 0.1… (411 car.) | G est borne par (T-1)/sqrt(T) = 2.475 ; verdict sensible a … (128 car.) |  | non numerique |
| `tests[[35]]$sens` | \<NA\> | ne pas rejeter |  | non numerique |
| `tests[[35]]$fonction` | test_rosner | test_grubbs |  | non numerique |
| `tests[[35]]$mc_nom` | \<NA\> | Grubbs |  | non numerique |
| `tests[[36]]$test` | Points influents (distance de Cook) | Valeurs aberrantes multiples (ESD generalise) |  | non numerique |
| `tests[[36]]$reference` | Cook (1977), Technometrics 19 | Rosner (1983), Technometrics 25 |  | non numerique |
| `tests[[36]]$H0` | \<NA\> | aucune valeur aberrante |  | non numerique |
| `tests[[36]]$H1` | \<NA\> | il existe i <= k valeurs aberrantes |  | non numerique |
| `tests[[36]]$estim_nom` | max D_t | nb de valeurs aberrantes |  | non numerique |
| `tests[[36]]$estim` | 0.8532677231 | 0 | 1.000e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[36]]$detail` | repere conventionnel 4/T = 0.500 ; 1 observation(s) au-dess… (71 car.) | procedure ESD de Rosner (1983) a niveau nominal alpha = 0.1… (411 car.) |  | non numerique |
| `tests[[36]]$fonction` | usp_tests | test_rosner |  | non numerique |
| `tests[[37]]$famille` | E. H4 - independance et validite du MV (annexe XVII B(2)(g)… (64 car.) | F. Stabilite, ruptures et points aberrants |  | non numerique |
| `tests[[37]]$test` | Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | Points influents (distance de Cook) |  | non numerique |
| `tests[[37]]$reference` | Durbin & Watson (1950, 1951) | Cook (1977), Technometrics 19 |  | non numerique |
| `tests[[37]]$type` | test | diagnostic |  | non numerique |
| `tests[[37]]$base` | r | commun |  | non numerique |
| `tests[[37]]$H0` | absence d'autocorrelation d'ordre 1 du ratio S/P | \<NA\> |  | non numerique |
| `tests[[37]]$H1` | autocorrelation du ratio S/P | \<NA\> |  | non numerique |
| `tests[[37]]$stat_nom` | DW | \<NA\> |  | non numerique |
| `tests[[37]]$stat` | 2.3199754 | \<NA\> |  | non fini |
| `tests[[37]]$loi` | loi classique INDICATIVE (ratios heteroscedastiques) -> Mon… (67 car.) | \<NA\> |  | non numerique |
| `tests[[37]]$estim_nom` | \<NA\> | max D_t |  | non numerique |
| `tests[[37]]$estim` | \<NA\> | 0.8532677231 |  | non fini |
| `tests[[37]]$p_mc` | 0.392 | \<NA\> |  | non fini |
| `tests[[37]]$err_mc` | 0.02511905585 | \<NA\> |  | non fini |
| `tests[[37]]$p_retenue` | 0.392 | \<NA\> |  | non fini |
| `tests[[37]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[37]]$verdict` | OK | INFO |  | non numerique |
| `tests[[37]]$detail` |  | repere conventionnel 4/T = 0.500 ; 1 observation(s) au-dess… (71 car.) |  | non numerique |
| `tests[[37]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[37]]$fonction` | stat_dw | usp_tests |  | non numerique |
| `tests[[37]]$mc_nom` | DWr | \<NA\> |  | non numerique |
| `tests[[38]]$test` | Test des suites sur ratios bruts | Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts |  | non numerique |
| `tests[[38]]$reference` | Wald & Wolfowitz (1940) | Durbin & Watson (1950, 1951) |  | non numerique |
| `tests[[38]]$H0` | arrangement aleatoire des signes du ratio centre | absence d'autocorrelation d'ordre 1 du ratio S/P |  | non numerique |
| `tests[[38]]$H1` | arrangement non aleatoire | autocorrelation du ratio S/P |  | non numerique |
| `tests[[38]]$stat_nom` | Z | DW |  | non numerique |
| `tests[[38]]$stat` | 0 | 2.3199754 | 2.320e+00 | absolu, au-delà du seuil 1e-06 |
| `tests[[38]]$p_mc` | 1 | 0.392 | 6.080e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[38]]$err_mc` | 0.03163859986 | 0.02511905585 | 2.061e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[38]]$p_retenue` | 1 | 0.392 | 6.080e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[38]]$detail` | pi_t varie avec t : sous le modele ajuste, les r_t sont ind… (691 car.) |  |  | non numerique |
| `tests[[38]]$p_min` | 0.05714285714 | \<NA\> |  | non fini |
| `tests[[38]]$fonction` | test_runs | stat_dw |  | non numerique |
| `tests[[38]]$p_min_mc` | 0.062 | \<NA\> |  | non fini |
| `tests[[38]]$mc_nom` | Runsr | DWr |  | non numerique |
| `tests[[39]]$famille` | F. Stabilite, ruptures et points aberrants | E. H4 - independance et validite du MV (annexe XVII B(2)(g)… (64 car.) |  | non numerique |
| `tests[[39]]$test` | Rupture de niveau (sup-F) sur ratios bruts | Test des suites sur ratios bruts |  | non numerique |
| `tests[[39]]$reference` | Quandt (1960) / Chow (1960) ; Andrews (1993) | Wald & Wolfowitz (1940) |  | non numerique |
| `tests[[39]]$H0` | niveau du ratio S/P constant | arrangement aleatoire des signes du ratio centre |  | non numerique |
| `tests[[39]]$H1` | rupture de niveau du ratio S/P | arrangement non aleatoire |  | non numerique |
| `tests[[39]]$stat_nom` | supF | Z |  | non numerique |
| `tests[[39]]$stat` | 0.8358227123 | 0 | 1.000e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[39]]$loi` | supremum de processus -> Monte-Carlo | loi classique INDICATIVE (ratios heteroscedastiques) -> Mon… (67 car.) |  | non numerique |
| `tests[[39]]$p_mc` | 0.821 | 1 | 2.180e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[39]]$err_mc` | 0.01212873061 | 0.03163859986 | 1.609e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[39]]$p_retenue` | 0.821 | 1 | 2.180e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[39]]$detail` | Detecte un changement de regime du ratio, independamment du… (67 car.) | pi_t varie avec t : sous le modele ajuste, les r_t sont ind… (691 car.) |  | non numerique |
| `tests[[39]]$p_min` | \<NA\> | 0.05714285714 |  | non fini |
| `tests[[39]]$fonction` | stat_supF | test_runs |  | non numerique |
| `tests[[39]]$p_min_mc` | \<NA\> | 0.062 |  | non fini |
| `tests[[39]]$mc_nom` | supFr | Runsr |  | non numerique |
| `tests[[40]]$test` | Stabilite cumulee (OLS-CUSUM) sur ratios bruts | Rupture de niveau (sup-F) sur ratios bruts |  | non numerique |
| `tests[[40]]$reference` | Brown, Durbin & Evans (1975), JRSS B 37 | Quandt (1960) / Chow (1960) ; Andrews (1993) |  | non numerique |
| `tests[[40]]$H0` | constance du niveau du ratio S/P | niveau du ratio S/P constant |  | non numerique |
| `tests[[40]]$H1` | niveau du ratio S/P non constant (derive ou rupture) | rupture de niveau du ratio S/P |  | non numerique |
| `tests[[40]]$stat_nom` | CUSUM | supF |  | non numerique |
| `tests[[40]]$stat` | 0.4538884948 | 0.8358227123 | 8.415e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[40]]$loi` | sup \|pont brownien\| -> Monte-Carlo | supremum de processus -> Monte-Carlo |  | non numerique |
| `tests[[40]]$p_mc` | 0.924 | 0.821 | 1.115e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[40]]$err_mc` | 0.008384169267 | 0.01212873061 | 4.466e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[40]]$p_retenue` | 0.924 | 0.821 | 1.115e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[40]]$detail` |  | Detecte un changement de regime du ratio, independamment du… (67 car.) |  | non numerique |
| `tests[[40]]$fonction` | stat_cusum | stat_supF |  | non numerique |
| `tests[[40]]$mc_nom` | CUSUMr | supFr |  | non numerique |
| `tests[[41]]$test` | Valeur aberrante isolee (Grubbs) sur ratios bruts | Stabilite cumulee (OLS-CUSUM) sur ratios bruts |  | non numerique |
| `tests[[41]]$reference` | Grubbs (1950, 1969), Technometrics 11 | Brown, Durbin & Evans (1975), JRSS B 37 |  | non numerique |
| `tests[[41]]$H0` | aucun ratio S/P aberrant | constance du niveau du ratio S/P |  | non numerique |
| `tests[[41]]$H1` | exactement un ratio aberrant | niveau du ratio S/P non constant (derive ou rupture) |  | non numerique |
| `tests[[41]]$stat_nom` | G | CUSUM |  | non numerique |
| `tests[[41]]$stat` | 1.835018034 | 0.4538884948 | 7.527e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[41]]$loi` | loi classique INDICATIVE (ratios heteroscedastiques) -> Mon… (67 car.) | sup \|pont brownien\| -> Monte-Carlo |  | non numerique |
| `tests[[41]]$estim_nom` | rang du ratio extreme | \<NA\> |  | non numerique |
| `tests[[41]]$estim` | 3 | \<NA\> |  | non numerique |
| `tests[[41]]$p_mc` | 0.204 | 0.924 | 3.529e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[41]]$err_mc` | 0.01274937436 | 0.008384169267 | 3.424e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[41]]$p_retenue` | 0.204 | 0.924 | 3.529e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[41]]$detail` | Identifie l'annee au boni/mali le plus atypique, sans passe… (75 car.) |  |  | non numerique |
| `tests[[41]]$fonction` | test_grubbs | stat_cusum |  | non numerique |
| `tests[[41]]$mc_nom` | Grubbsr | CUSUMr |  | non numerique |
| `tests[[42]]$test` | Leviers (hat values) | Valeur aberrante isolee (Grubbs) sur ratios bruts |  | non numerique |
| `tests[[42]]$reference` | Hoaglin & Welsch (1978), Amer. Statist. 32 | Grubbs (1950, 1969), Technometrics 11 |  | non numerique |
| `tests[[42]]$type` | diagnostic | test |  | non numerique |
| `tests[[42]]$base` | commun | r |  | non numerique |
| `tests[[42]]$H0` | \<NA\> | aucun ratio S/P aberrant |  | non numerique |
| `tests[[42]]$H1` | \<NA\> | exactement un ratio aberrant |  | non numerique |
| `tests[[42]]$stat_nom` | \<NA\> | G |  | non numerique |
| `tests[[42]]$stat` | \<NA\> | 1.835018034 |  | non fini |
| `tests[[42]]$loi` | \<NA\> | loi classique INDICATIVE (ratios heteroscedastiques) -> Mon… (67 car.) |  | non numerique |
| `tests[[42]]$estim_nom` | max h_t | rang du ratio extreme |  | non numerique |
| `tests[[42]]$estim` | 0.48 | 3 |  | non numerique |
| `tests[[42]]$p_mc` | \<NA\> | 0.204 |  | non fini |
| `tests[[42]]$err_mc` | \<NA\> | 0.01274937436 |  | non fini |
| `tests[[42]]$p_retenue` | \<NA\> | 0.204 |  | non fini |
| `tests[[42]]$nature_p` | \<NA\> | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) |  | non numerique |
| `tests[[42]]$verdict` | INFO | OK |  | non numerique |
| `tests[[42]]$detail` | repere conventionnel 2k/T = 0.250 ; 1 observation(s) au-des… (62 car.) | Identifie l'annee au boni/mali le plus atypique, sans passe… (75 car.) |  | non numerique |
| `tests[[42]]$sens` | \<NA\> | ne pas rejeter |  | non numerique |
| `tests[[42]]$fonction` | usp_tests | test_grubbs |  | non numerique |
| `tests[[42]]$mc_nom` | \<NA\> | Grubbsr |  | non numerique |
| `tests[[43]]$famille` | G. Robustesse de l'estimation | F. Stabilite, ruptures et points aberrants |  | non numerique |
| `tests[[43]]$test` | Sensibilite au retrait d'une annee (jackknife) | Leviers (hat values) |  | non numerique |
| `tests[[43]]$reference` | Quenouille (1949) / Tukey (1958) | Hoaglin & Welsch (1978), Amer. Statist. 32 |  | non numerique |
| `tests[[43]]$estim_nom` | ecart relatif max | max h_t |  | non numerique |
| `tests[[43]]$estim` | 0.1662258524 | 0.48 | 1.888e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[43]]$detail` | Annee la plus influente : 3 (sigma_USP en baisse). | repere conventionnel 2k/T = 0.250 ; 1 observation(s) au-des… (62 car.) |  | non numerique |
| `tests[[43]]$fonction` | run_engine | usp_tests |  | non numerique |
| `tests[[44]]$test` | Largeur relative de l'IC bootstrap 90% | Sensibilite au retrait d'une annee (jackknife) |  | non numerique |
| `tests[[44]]$reference` | Efron (1979), Ann. Statist. 7 ; Davison et Hinkley (1997), … (78 car.) | Quenouille (1949) / Tukey (1958) |  | non numerique |
| `tests[[44]]$estim_nom` | largeur / sigma_USP | ecart relatif max |  | non numerique |
| `tests[[44]]$estim` | 0.4346439757 | 0.1662258524 | 6.176e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[44]]$detail` | Intervalle bootstrap de percentile du parametre retenu, niv… (302 car.) | Annee la plus influente : 3 (sigma_USP en baisse). |  | non numerique |
| `tests[[45]]$test` | Largeur relative de l'IC bootstrap 90% (delta fixe a delta … (66 car.) | Largeur relative de l'IC bootstrap 90% |  | non numerique |
| `tests[[45]]$reference` | Efron (1979), Ann. Statist. 7 ; Andrews (2000), Econometric… (63 car.) | Efron (1979), Ann. Statist. 7 ; Davison et Hinkley (1997), … (78 car.) |  | non numerique |
| `tests[[45]]$estim` | 0.4531181242 | 0.4346439757 | 4.077e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[45]]$detail` | Bootstrap parametrique a delta fixe a sa valeur estimee (se… (703 car.) | Intervalle bootstrap de percentile du parametre retenu, niv… (302 car.) |  | non numerique |
| `tests[[46]]$test` | Rapport de vraisemblance : delta = 0 (variance lineaire en … (66 car.) | Largeur relative de l'IC bootstrap 90% (delta fixe a delta … (66 car.) |  | non numerique |
| `tests[[46]]$reference` | Chernoff (1954) ; Self & Liang (1987), JASA 82 ; Davison & … (82 car.) | Efron (1979), Ann. Statist. 7 ; Andrews (2000), Econometric… (63 car.) |  | non numerique |
| `tests[[46]]$H0` | delta = 0 (variance proportionnelle au volume) | \<NA\> |  | non numerique |
| `tests[[46]]$H1` | delta > 0 | \<NA\> |  | non numerique |
| `tests[[46]]$stat_nom` | LR(0) | \<NA\> |  | non numerique |
| `tests[[46]]$stat` | 0.1649016946 | \<NA\> |  | non fini |
| `tests[[46]]$loi` | sous H0 : loi simulee par bootstrap parametrique restreint … (172 car.) | \<NA\> |  | non numerique |
| `tests[[46]]$estim_nom` | sigma(delta0, gamma~) | largeur / sigma_USP |  | non numerique |
| `tests[[46]]$estim` | 0.06676040344 | 0.4531181242 | 5.787e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[46]]$p_asymptotique` | 0.3423415808 | \<NA\> |  | non fini |
| `tests[[46]]$p_mc` | 0.289 | \<NA\> |  | non fini |
| `tests[[46]]$err_mc` | 0.01434171136 | \<NA\> |  | non fini |
| `tests[[46]]$detail` | Aucun verdict (ADR 0001) : le LR mesure si les donnees dist… (420 car.) | Bootstrap parametrique a delta fixe a sa valeur estimee (se… (703 car.) |  | non numerique |
| `tests[[46]]$fonction` | usp_lr_delta | run_engine |  | non numerique |
| `tests[[47]]$test` | Rapport de vraisemblance : delta = 1 (variance quadratique … (69 car.) | Rapport de vraisemblance : delta = 0 (variance lineaire en … (66 car.) |  | non numerique |
| `tests[[47]]$H0` | delta = 1 (variance proportionnelle au carre du volume) | delta = 0 (variance proportionnelle au volume) |  | non numerique |
| `tests[[47]]$H1` | delta < 1 | delta > 0 |  | non numerique |
| `tests[[47]]$stat_nom` | LR(1) | LR(0) |  | non numerique |
| `tests[[47]]$stat` | 0.141073731 | 0.1649016946 | 1.689e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[47]]$estim` | 0.07261597231 | 0.06676040344 | 8.064e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[47]]$p_asymptotique` | 0.3536079516 | 0.3423415808 | 3.186e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[47]]$p_mc` | 0.411 | 0.289 | 2.968e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[47]]$err_mc` | 0.01556667342 | 0.01434171136 | 7.869e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[48]]$famille` | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i… (61 car.) | G. Robustesse de l'estimation |  | non numerique |
| `tests[[48]]$test` | p de famille (minP, lecture conjointe) | Rapport de vraisemblance : delta = 1 (variance quadratique … (69 car.) |  | non numerique |
| `tests[[48]]$reference` | Westfall & Young (1993), minP en une etape ; Ge, Dudoit & S… (144 car.) | Chernoff (1954) ; Self & Liang (1987), JASA 82 ; Davison & … (82 car.) |  | non numerique |
| `tests[[48]]$H0` | toutes les hypotheses nulles des tests de la famille sont v… (80 car.) | delta = 1 (variance proportionnelle au carre du volume) |  | non numerique |
| `tests[[48]]$H1` | au moins une est fausse | delta < 1 |  | non numerique |
| `tests[[48]]$stat_nom` | plus petite p Monte-Carlo de la famille | LR(1) |  | non numerique |
| `tests[[48]]$stat` | 0.67 | 0.141073731 | 7.894e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[48]]$loi` | minimum des p Monte-Carlo -> Monte-Carlo (memes replication… (83 car.) | sous H0 : loi simulee par bootstrap parametrique restreint … (172 car.) |  | non numerique |
| `tests[[48]]$estim_nom` | nombre de tests de la famille | sigma(delta0, gamma~) |  | non numerique |
| `tests[[48]]$estim` | 4 | 0.07261597231 | 9.818e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[48]]$p_asymptotique` | \<NA\> | 0.3536079516 |  | non fini |
| `tests[[48]]$p_mc` | 0.955 | 0.411 | 5.696e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[48]]$err_mc` | 0.006558812241 | 0.01556667342 | 1.373e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[48]]$detail` | Lecture conjointe des tests de la famille (issue #297) : p … (1006 car.) | Aucun verdict (ADR 0001) : le LR mesure si les donnees dist… (420 car.) |  | non numerique |
| `tests[[48]]$fonction` | engine_p_famille | usp_lr_delta |  | non numerique |
| `tests[[49]]$famille` | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) | B. H1 - linearite / proportionnalite (annexe XVII B(2)(g)(i… (61 car.) |  | non numerique |
| `tests[[49]]$stat` | 0.334 | 0.67 | 1.006e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[49]]$estim` | 6 | 4 | 3.333e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[49]]$p_mc` | 0.579 | 0.955 | 6.494e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[49]]$err_mc` | 0.01562059548 | 0.006558812241 | 5.801e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[49]]$detail` | …n de restitution) : Shapiro-Wilk sur residus standardises [S… (1016 car., 1re différence au car. 464) | …n de restitution) : Nullite de la constante (proportionnalit… (1006 car., 1re différence au car. 464) |  | non numerique |
| `tests[[50]]$famille` | E. H4 - independance et validite du MV (annexe XVII B(2)(g)… (64 car.) | D. H3 - lognormalite (annexe XVII B(2)(g)(iii)) |  | non numerique |
| `tests[[50]]$stat` | 0.22 | 0.334 | 5.182e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[50]]$estim` | 5 | 6 | 2.000e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[50]]$p_mc` | 0.423 | 0.579 | 3.688e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[50]]$err_mc` | 0.01563058909 | 0.01562059548 | 6.394e-04 | relatif, au-delà du seuil 1e-06 |
| `tests[[50]]$detail` | …n de restitution) : Autocorrelation d'ordre 1 (Durbin-Watson… (1054 car., 1re différence au car. 464) | …n de restitution) : Shapiro-Wilk sur residus standardises [S… (1016 car., 1re différence au car. 464) |  | non numerique |
| `tests[[51]]$famille` | F. Stabilite, ruptures et points aberrants | E. H4 - independance et validite du MV (annexe XVII B(2)(g)… (64 car.) |  | non numerique |
| `tests[[51]]$stat` | 0.105 | 0.22 | 1.095e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[51]]$estim` | 6 | 5 | 1.667e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[51]]$p_mc` | 0.29 | 0.423 | 4.586e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[51]]$err_mc` | 0.014356396 | 0.01563058909 | 8.875e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[51]]$detail` | …n de restitution) : Rupture de niveau (sup-F) [supF], Stabil… (1109 car., 1re différence au car. 464) | …n de restitution) : Autocorrelation d'ordre 1 (Durbin-Watson… (1054 car., 1re différence au car. 464) |  | non numerique |
| `tests[[52]]$famille` | LC. Lecture conjointe de la batterie (toutes familles) | F. Stabilite, ruptures et points aberrants |  | non numerique |
| `tests[[52]]$test` | p globale (minP, lecture conjointe de la batterie) | p de famille (minP, lecture conjointe) |  | non numerique |
| `tests[[52]]$H0` | toutes les hypotheses nulles des tests de toutes les famill… (89 car.) | toutes les hypotheses nulles des tests de la famille sont v… (80 car.) |  | non numerique |
| `tests[[52]]$stat_nom` | plus petite p Monte-Carlo de la batterie | plus petite p Monte-Carlo de la famille |  | non numerique |
| `tests[[52]]$estim_nom` | nombre de tests | nombre de tests de la famille |  | non numerique |
| `tests[[52]]$estim` | 22 | 6 | 7.273e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[52]]$p_mc` | 0.65 | 0.29 | 5.538e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[52]]$err_mc` | 0.01509065034 | 0.014356396 | 4.866e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[52]]$detail` | Lecture conjointe de la batterie (issue #297) : p minP en u… (696 car.) | Lecture conjointe des tests de la famille (issue #297) : p … (1109 car.) |  | non numerique |

## Batteries

- `Rscript tests/test_reproductibilite.R` : code de sortie 0
  - `premium     sigma_USP = 0.1114524114  (21 s)`
  - `CONFORME : 56964 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve1    sigma_USP = 0.1073524114  (19 s)`
  - `CONFORME : 56963 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve2    sigma_USP = 0.0497764613  (41 s)`
  - `CONFORME : 18694 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_ii6 sigma_USP = 0.1483524114  (19 s)`
  - `CONFORME : 56964 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_net sigma_USP = 0.1032524114  (18 s)`
  - `CONFORME : 56964 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_interieur sigma_USP = 0.0871308679  (34 s)`
  - `CONFORME : 56964 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `OK : reproductibilite et non-regression verifiees pour 6 cas.`
- `Rscript tests/test_unitaires.R` : code de sortie 0
  - `TOTAL : 2823 assertions, 2823 ok, 0 echec(s), 0 echec(s) attendu(s) (defauts connus), 0 succes inattendu(s)`
  - `OK`
