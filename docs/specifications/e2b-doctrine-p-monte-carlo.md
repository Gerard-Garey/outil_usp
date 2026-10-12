# Spécification commune d'E2b : contrat d'`add()` et doctrine des p-values Monte-Carlo (#120, #181, #182, #244, #204, #125)

> *Rédigé par l'agent actuary (IA), 12/10/2026, branche `claude/doctrine-p-monte-carlo` (PR #261, tête `59175a5`). Spécification commune des six issues de la branche E2b, étape 1 de la fiche « Branche E2b » de `docs/feuille-de-route.md`. Elle est soumise au point d'arrêt **D1** : aucun code avant l'approbation du mainteneur. Les décisions de D1 sont ajoutées en annotation datée, en fin de document.*

**Marques** : **[V]** vérifié (source citée, ou commande exécutée et sortie lue) ; **[H]** hypothèse ; **[NV]** non vérifié.

## 0. Objet, sources, mesures, décisions déjà prises

**Objet.** Six issues touchent la même chose : ce qu'une ligne de test dit de sa p-value Monte-Carlo, et ce qu'elle fait quand cette p-value manque. Ordre décidé (Q-E2b-3) : **#120 → #181 → #182 → #244 → #204 → #125**. Les patchs de référence passent d'abord ; une seule régénération par la CI des six cas, en dernier (#125).

**Sources lues** **[V]** :
- fiche « Branche E2b » (§ 3), lignes E-11/10 (E2c), E-12/10 et E-12/10 (E2b) du § 4 de `docs/feuille-de-route.md` ;
- corps et commentaires des issues :
  - #120 ;
  - #181 (commentaire `5949065774`) ;
  - #182 ;
  - #244 ;
  - #204 (décision `6120564480`, et handoff `6116606862` de la PR #252, § 3, D-1) ;
  - #125 (commentaire `6120563166`) ;
- `CONTEXT.md` : entrées « P-value Monte-Carlo », « … conditionnelle au régime de δ̂ », « Erreur de Monte-Carlo », « Granularité », « P-value retenue », « Statistique Monte-Carlo », « Statistique dégénérée », « P-value Monte-Carlo conditionnelle à la définition de la statistique », « Test inopérant », « Test sans p-value retenue », « Ligne non applicable » ;
- ADR 0001 (titre et renvois) ; ADR 0003, avec ses annotations des 24/09, 27/09, 02/10, 06/10, 07/10 et 11/10 ; ADR 0014 (contexte, résultats) ;
- `R/engine.R` à `59175a5` :
  - fonctions de base : `lillie_p()` (l. 1944), `test_runs()` (l. 2211), `runs_p_min()`, `.runs_effectifs()`, `cox_stuart_p_min()`, `smirnov_p_min()` (l. 2331-2360) ;
  - catalogue et calcul des p : `USP_CATALOGUE_MC` (l. 3328-3421), motifs (l. 3523-3556), `engine_p_mc()` (l. 3558), `.mc_p_values()` (l. 3601), `engine_registre_tests()` / `add()` (l. 3698-3941) ;
  - `usp_tests()` (l. 4358-5771), en particulier :
    - `p_ex_si_pi_constant()`, `detail_r7()`, `mc_dispo()` (l. 4460-4500) ;
    - RESET, Spearman, Mann-Kendall, Cox-Stuart (l. 4825-4922) ;
    - hétéroscédasticité (l. 4926-4978) ;
    - Smirnov (l. 4979-5022) ;
    - normalité (l. 5054-5187) ;
    - H4 (l. 5189-5240) ;
    - sup-F, CUSUM, Grubbs (l. 5402-5433) ;
    - ratios bruts (l. 5500-5650) ;
    - rapport de vraisemblance sur δ (l. 5692-5766) ;
  - côté Merz-Wüthrich :
    - `mw_test_annees_calendaires()` (l. 7620), `mw_stat_correlation_dev()` (l. 7682), `.fisher_combine()` (l. 7768), `.mw_spearman()` (l. 7810) ;
    - `mw_test_homogeneite_f()` (l. 8055), `mw_test_homogeneite_accident()` (l. 8210), fonctions de p_min (l. 8252-8350) ;
    - `mw_bootstrap()` (l. 8451), `MW_CATALOGUE_MC` (l. 8524), `mw_tests()` (l. 8574-8879) ;
  - `engine_table_tests()` ;
- `R/display_helpers.R` : `badge_nature()` (l. 135-152) ;
- `tests/outils_tests.R` (les six cas) ; `tests/unitaires/test_merz_wuthrich.R` (`ta`, `ta_deg`, `ta_pert()`, l. 586-958) ; `docs/specifications/240-p-mc-conditionnelle-regime.md` (modèle de forme).

**Mesures** **[V]** : `Rscript` sous `LC_ALL=C.UTF-8`, R 4.3.3, BLAS et LAPACK de référence 3.12.0, moteur de `59175a5`. Les scripts sont de session et ne sont pas versionnés. Méthode :
- (M1) lecture des `.rds` des six cas ;
- (M2) `run_engine()` des cas `premium`, `premium_interieur` et `reserve2`, avec capture de la matrice passée à `.mc_p_values()` (redéfinition enveloppante après `source()`), pour compter les réplications aux extrémités du support ;
- (M3) `usp_ajuster()` + `usp_bootstrap(B = 40)` + `usp_tests()` sur J1 (`donnees_ln.csv`) et J2 (`xi`, `yi` de `test_controles_numeriques.R`) ;
- (M4) `mw_bootstrap()` + `mw_tests()` sur `ta_pert(9e-13)` à B = 60 et 99 ;
- (M5) comparaison feuille à feuille de `reserve2` recalculé et de sa référence.

**Décisions déjà prises, non rouvertes** :
- Q-E2b-4 (A) : exception à la règle #76 bornée aux deux phrases de #204, posées par `mw_tests()` ; la règle reste entière dans `add()`.
- Q-E2b-5 : #244 par une phrase fixe posée par `add()`, sans nouveau champ.
- Q-E2b-6 : #120 garde la colonne `p_asymptotique` ; la nouvelle nature passe par un argument d'`add()` ; `badge_nature()` est complété.
- Q-E2b-3 : patchs d'abord, une seule régénération en dernier.
- #204 : libellé, cas A et cas B (décision du 12/10).
- Q-E2c-3 et confirmation du 12/10 : p_min de HomogF et ExpVar avec ex æquo, R1 « ECHEC possible ». #125 la remplace par la lecture de la loi bootstrap, comme le prévoyait le commentaire `6120563166`.

## 1. Vocabulaire commun

**P non simulée.** C'est toute p rangée dans la colonne `p_asymptotique` (nom conservé, Q-E2b-6). Quatre familles, reprises du commentaire `5949065774` de #181 :
- **(i) loi limite** quand T → ∞ : χ² des tests de type multiplicateur de Lagrange (BP, BP79, White, JB, LB1, LB2, BP2) ; Kolmogorov (KS contre N(0,1), à paramètres estimés) ; pont brownien (OLS-CUSUM) ; χ²(k−1) de Kruskal-Wallis ; BP de Merz-Wüthrich.
- **(ii) approximation de la loi à n fini sous échantillon i.i.d. normal**, ajustée sur tables simulées ou sur moments exacts : Royston (SW, SF), Stephens / D'Agostino-Stephens (AD, CvM), Dallal-Wilkinson prolongée par Stephens (Lilliefors, `lillie_p()` l. 1941-1943, même mise en œuvre que `nortest::lillie.test`), D'Agostino (1970) pour l'asymétrie, Anscombe-Glynn (1983) pour l'aplatissement.
- **(iii) loi exacte ou approchée sous un modèle auxiliaire gaussien**, non sous l'annexe XVII :
  - F de RESET (exacte sous M_0) ;
  - F de Goldfeld-Quandt et de Brown-Forsythe (approchées) ;
  - Student et combinaison de Fisher χ²(2K) des lignes de Merz-Wüthrich PenteIntra, Origine, Courbure, HomogF et ExpVar ;
  - Student + Bonferroni (Grubbs).
- **(iv) approximation normale d'une loi de rangs discrète** : Spearman (`cor.test(exact = FALSE)`), Mann-Kendall, suites, effet calendaire.

**Natures d'une p retenue après E2b** :
- « exacte » ;
- « exacte par permutation (…) » ;
- les natures Monte-Carlo existantes ;
- « asymptotique » ;
- **« approximation a n fini sous i.i.d. normal »** (#120) ;
- « sous le modele auxiliaire pondere : … » ;
- `NA`.

La nature « asymptotique (Monte-Carlo indisponible : <motif>) » disparaît si D1-1 retient (B) (§ 3).

**Plancher Monte-Carlo d'une statistique discrète, p_min_mc** (#125). C'est la plus petite valeur que la p Monte-Carlo **calculée sur les réplications effectivement retenues** peut prendre quand la statistique observée parcourt son support, à la configuration observée (effectifs, ex æquo).
- Soit [x_bas ; x_haut] les extrémités de ce support ; N_haut = #{s ≥ x_haut − τ} et N_bas = #{s ≤ x_bas + τ} sur les B_eff réplications finies, avec τ = `TOL_DISPERSION_MC` · max(1, |x|). Alors :
  - p_min_mc = (1 + N_haut)/(B_eff + 1) en queue haute ;
  - p_min_mc = (1 + N_bas)/(B_eff + 1) en queue basse ;
  - p_min_mc = min(1, 2 (1 + min(N_haut, N_bas))/(B_eff + 1)) en bilatéral.
- C'est le minimum exact, sur le support, de la formule d'`engine_p_mc()` (fonction décroissante en x pour p⁺, croissante pour p⁻) : pour les réplications tirées, p_mc ≥ p_min_mc **sans approximation**. L'erreur Monte-Carlo ne porte que sur l'écart à la quantité idéale (B → ∞).
- Elle vaut toujours au moins `granularite_stat`.
- Elle ne se confond pas avec `p_min` (loi de référence échangeable), qui reste restituée.

## 2. #120 : nature d'une p non simulée qui n'est pas asymptotique

**Ce que dit le moteur aujourd'hui** **[V]**. Une p retenue depuis `p_asymptotique` reçoit la nature « asymptotique ». Mesure M1 : seule la ligne M5 « Lilliefors sur les residus de Mack » de `reserve2` en retient une, nature « asymptotique ». Sa p est `lillie_p()`, approximation de Dallal et Wilkinson (1986) prolongée au-delà de 0,10 par les polynômes de Stephens (1974). C'est une approximation de la loi **à n fini**, non une loi limite.

**Décision proposée.**
- Nouvelle constante `NATURE_APPROX_N_FINI <- "approximation a n fini sous i.i.d. normal"`. Rendu dans le `.tex` : « approximation à n fini sous i.i.d. normal ».
- Nouvel argument d'`add()` : `nature_as = "asymptotique"`, avec deux valeurs admises, `"asymptotique"` et `NATURE_APPROX_N_FINI`. Toute autre valeur est refusée par `stop("add() : nature_as inconnue : …")`.
- La branche asymptotique de la hiérarchie pose `nature <- nature_as` au lieu du littéral. Le rang est inchangé : la hiérarchie reste exacte > Monte-Carlo > p non simulée.
- Portée, si D1-1 = (B) : l'argument n'est passé que sur les lignes **sans `mc_nom`** dont la p est de la famille (ii), les seules où elle peut être retenue :
  - « Lilliefors sur les residus de Mack » (`mw_tests()`) ;
  - « Aplatissement (Anscombe-Glynn, T >= 20) » (`usp_tests()`, T ≥ 20 seulement).

  Si D1-1 = (A), il est aussi passé sur SW, SF, AD, CvM, Lilliefors et DAgo d'`usp_tests()`. Le repli s'écrirait alors `paste0(nature_as, " (", motif, ")")`.
- `badge_nature()` : branche nouvelle avant la valeur par défaut, `grepl("^approximation a n fini", n)` → badge « approx. n fini ». Couleur distincte des cinq existantes, choisie par `app-review`.

**Justification à T = 8.**
- Le libellé dit ce qu'est la p : l'approximation d'une loi à n fini sous une hypothèse (observations i.i.d. normales). Ce n'est ni une loi limite ni une loi exacte.
- Bibliographie vérifiée :
  - Dallal et Wilkinson (1986), *The American Statistician* 40(4), 294-296 : « analytic approximation » de la loi de la statistique de Lilliefors ; `nortest` signale qu'elle n'est fiable que pour p < 0,1, d'où le prolongement de Stephens **[V]** ;
  - Royston (1992), *Statistics and Computing* 2, 117-119 : transformation normalisante de W pour n > 3 **[V]**. Le plan de simulation qui la fonde n'est pas relu **[NV]**.
- **Ce que le libellé ne dit pas** : les résidus de Mack ne sont pas i.i.d. normaux (variances inégales, dépendance par la standardisation). La p n'est donc la p d'aucun test sous le modèle de Merz-Wüthrich. La littérature ne donne pas la qualité de cette approximation sur des résidus de Mack ; la question du niveau est à #245 (C-E2b-2).

**Fonctions touchées** : `add()`, `mw_tests()` (une ligne), `usp_tests()` (Anscombe-Glynn), `badge_nature()`.

**Tests** (`tests/unitaires/`, nouveau fichier ou ajout à `test_inoperance.R`) :
- U120-1 — `reserve2` : `nature_p` de « Lilliefors sur les residus de Mack » `identical()` à `NATURE_APPROX_N_FINI` ; `p_retenue` et `verdict` identiques à la référence.
- U120-2 — `add()` construit : `p_as = 0.3`, sans `mc_nom` → nature « asymptotique » par défaut, `NATURE_APPROX_N_FINI` sous l'argument.
- U120-3 — `nature_as = "approchee"` → erreur.
- U120-4 — avec `p_ex` fini ou `p_mc` fini, la nature reste « exacte » ou Monte-Carlo, quel que soit `nature_as`.
- U120-5 — Anscombe-Glynn à T = 20 (jeu synthétique, `run_engine(B = 99)`) : nature `NATURE_APPROX_N_FINI` si la ligne retient sa p.
- U120-6 — le badge de `NATURE_APPROX_N_FINI` diffère de celui de « asymptotique » et de « asymptotique (Monte-Carlo indisponible : … ) ».
- U120-7 — aucune valeur numérique ne change sur les six cas.

**Références** : **patch chirurgical de `reserve2`** (une chaîne `nature_p`) ; lognormales identiques. **Visa** : aucun (ni p, ni verdict, ni σ_USP).

## 3. #181 : sort de la p non simulée quand la p Monte-Carlo manque

**Situation** **[V]**. `add()` retient aujourd'hui la p non simulée, sous la nature « asymptotique (Monte-Carlo indisponible : <motif>) », dès que trois conditions se réunissent :
- `p_mc` manque pour un motif non dégénéré : `MOTIF_MC_AUCUNE_REPLIC`, `MOTIF_MC_REPLIC_INSUFFISANTES`, `MOTIF_MC_REGIME_RARE` (A4), ou un motif de `non_definie` ;
- aucune p exacte n'existe ;
- une p non simulée existe.

Seule la constante y échappe (`repli_asymptotique = FALSE`, diagnostic). Mesures :

| Jeu | Lignes en repli | Verdicts sous le repli | Lignes sans aucune p |
|---|---|---|---|
| M3, J1 (δ̂ = 1, V1, B = 40) | 19 | 16 OK, 2 ALERTE (White, BF), 1 ECHEC (BP Koenker) | 6 tests sans p-value retenue |
| M3, J2 (δ̂ = 0,664, V3b, B = 40) | 23 | toutes OK | 9 |
| M4, `ta_pert(9e-13)`, B = 60 (B_eff = 42 sur Origine, HomogF, Courbure) | 3 | Origine ECHEC (χ²(2K), p = 0,0058), HomogF OK, Courbure OK | — |

**Écarts entre p non simulée et p Monte-Carlo à B = 999 sur les mêmes données** **[V]** :

| Jeu | Ligne | p Monte-Carlo (B = 999) | p non simulée | Effet sur le verdict |
|---|---|---|---|---|
| J1 | BP79 | 0,090 | 0,144 (χ²) | ALERTE → OK |
| J1 | BF | 0,104 | 0,091 (F) | OK → ALERTE |
| J1 | KS | 0,267 | 0,770 | — |
| J2 | GQ | 0,018 (conditionnelle, V3b) | 0,443 (F approchée) | ECHEC → OK |

**Avis ligne par ligne, résumé par famille** :

| Famille | Lignes (`usp_tests()` ; `mw_tests()`) | Validité à T = 8 sous le modèle réglementaire | Avis |
|---|---|---|---|
| (i) | BP, BP79, White, KS, JB, LB1, LB2, BP2, CUSUM ; MW BP, KruskalAcc | aucune. La loi limite ignore l'estimation (KS : « tres conservatrice », `detail` de la ligne) ; à T = 8, aucune vitesse de convergence n'est établie ; le `detail` de CUSUM dit lui-même « aucune validite a T = 8 » | pas de repli |
| (ii) | SW, SF, AD, CvM, Lilliefors, DAgo | supposent des observations i.i.d. normales ; z_t = Pε ne l'est pas à π̂_t variable. **AD et CvM** : la p non simulée porte sur la statistique re-standardisée (`estim`, règle R6), **pas sur `stat`**, statistique de la p Monte-Carlo. Le repli retiendrait la p d'une autre statistique | pas de repli |
| (iii) | RESET, GQ, BF, Grubbs ; MW PenteIntra, Origine, Courbure, HomogF, ExpVar, Grubbs | loi d'un modèle auxiliaire gaussien homoscédastique ou à colonnes indépendantes, contredit par H2-H3 (`CONTEXT.md`, « Modèle auxiliaire MCO ») ou par la dépendance des colonnes de Mack. #119 mesure la p de Student de PenteIntra conservatrice sous H0 (4,8 à 6,0 % à 0,10 ; commentaire de `.mw_lm_intra()`, constat de simulation) | pas de repli |
| (iv) | SpearVol, SpearTps, MK, Runs ; MW Calendrier, Runs | à π̂_t constant, ces lignes ont une p exacte (R7), retenue, et le repli n'a pas lieu. Il n'a lieu qu'à π̂_t variable, où la loi échangeable elle-même est fausse : son approximation normale l'est a fortiori | pas de repli |

**Décision recommandée : (B) généralisée.**
- Pour toute ligne de type test dont `p_mc` manque pour un motif non dégénéré, sans p exacte finie, et qui a une p non simulée finie :
  - `type = "diagnostic"` ;
  - `detail` préfixé de « Monte-Carlo indisponible : <motif> ; <libelle_p_as> non retenue (ADR 0001). » ;
  - p non simulée conservée dans sa colonne ;
  - `p_retenue = NA`, `nature_p = NA`, verdict INFO, `inoperant = FALSE`.

  C'est la branche que suit aujourd'hui la seule constante, étendue à toutes les lignes.
- Sans p non simulée : rien ne change, la ligne reste un test sans p-value retenue.
- Avec p exacte finie : rien ne change, la p exacte reste retenue.

**Justification.**
1. Aucune des quatre familles n'a de validité établie sous le modèle réglementaire à T = 8, ni sous le modèle de Mack aux tailles de triangle considérées. La littérature ne permet pas de conclure à T = 8, et l'écart mesuré change des verdicts dans les deux sens (tableau ci-dessus).
2. C'est la logique déjà retenue par l'ADR 0001 (repli sur la loi nominale interdit), par la règle R5 (constante) et par l'ADR 0002 amendé, point 4 (aucun repli sur la Student de la pente).
3. L'ADR 0014, point 2, a écarté le repli de V3h sur la p **Monte-Carlo marginale** quand le régime intérieur est rare. Se replier alors sur une p non simulée, plus éloignée encore de la loi de référence, serait incohérent. (B) règle donc aussi `MOTIF_MC_REGIME_RARE` (C-A4-1).
4. Le cas se produit quand plus de la moitié des réplications sont perdues (`run_engine()` refuse B < 99). Il n'arrive que sur des jeux pathologiques. Une p de remplacement donnerait alors une assurance qu'aucun résultat ne fonde.

**Alternatives.**
- **(A)** statu quo : écartée pour les raisons 1 à 3.
- **(B′)** repli conservé pour la famille (ii) à π̂_t constant seulement. C'est l'objection la plus forte. À π̂_t constant, ces p approchent la loi exacte i.i.d. que la règle R7 admet ailleurs (Shapiro-Wilk à loi nulle simulée). Gain marginal : la ligne Shapiro-Wilk à loi nulle simulée garde déjà sa p exacte, et AD et CvM portent sur une autre statistique. Écartée par simplicité.
- **(C)** refus du calcul : écartée.
  - B_eff < 50 peut ne toucher qu'une statistique (Origine, HomogF et Courbure sur `ta_pert`, les dix autres à B_eff = B).
  - σ_USP ne dépend pas du bootstrap.
  - Le cas n'entre dans aucun des trois régimes de sortie de #88.
- **Diagnostic ou test sans p-value retenue ?** Diagnostic recommandé. Par les définitions de `CONTEXT.md`, le diagnostic est la ligne « dont les p-values existent mais ne fondent aucun verdict », et c'est le précédent de la constante. Il en résulte une asymétrie dite : la même cause (Monte-Carlo indisponible) donne un diagnostic si une p non simulée existe, un test sans p-value retenue sinon.

**Textes.**
- Libellé par défaut de `libelle_p_as` : **`"p non simulee (loi du champ loi)"`**. Il est vrai pour les quatre familles, renvoie au champ `loi` qui décrit chaque p, et évite d'appeler « asymptotique » une p qui ne l'est pas (#120).
- La constante garde son libellé explicite.

**Simplifications du code** :
- retirer l'argument `repli_asymptotique` (son seul appelant est la constante), la variable `motif_non_mc` et la composition « asymptotique (…) » ;
- retirer les branches de R1 que la décision rend inatteignables (texte « la p-value asymptotique retenue, calculee hors de cette loi … »), après vérification par `grep` qu'aucun appel d'`add()` ne passe `p_min` avec une p non simulée retenable. Constat à faire par `coder`, à confirmer par `audit`.

**Fonctions touchées** : `add()`, `usp_tests()` (appel de la constante). `mw_tests()` n'est pas touchée.

**Tests** :
- U181-1 — `add()` construit : `mc_nom`, `p_mc` NA, motif `MOTIF_MC_REPLIC_INSUFFISANTES`, `p_as = 0.03` → diagnostic, INFO, `p_retenue` et `nature_p` NA, `p_asymptotique = 0.03`, `inoperant` FALSE. `detail` commence par « Monte-Carlo indisponible : replications finies insuffisantes (B_effectif < B_MIN_DEGENERESCENCE = 50) ; p non simulee (loi du champ loi) non retenue (ADR 0001). ».
- U181-2 — idem avec `MOTIF_MC_AUCUNE_REPLIC`, `MOTIF_MC_REGIME_RARE` et « statistique observee non definie : ex aequo ».
- U181-3 — `p_ex` fini → p exacte retenue, ligne de type test.
- U181-4 — `p_as` NA → test sans p-value retenue, `detail` inchangé.
- U181-5 — motifs dégénérés : comportement de R3 inchangé.
- U181-6 — J1 et J2 à `usp_bootstrap(B = 40)` : les 19 et 23 lignes ci-dessus sont des diagnostics ; aucune `nature_p` ne commence par « asymptotique (Monte-Carlo indisponible » ; les lignes sans p sont inchangées ; la constante est inchangée.
- U181-7 — `ta_pert(9e-13)`, B = 60 : Origine, HomogF, Courbure en diagnostic ; les dix autres lignes sont inchangées.
- U181-8 — `grep` : plus de `repli_asymptotique` dans `R/engine.R`.
- U181-9 — six références identiques (`comparer_objets()`).

**Tests à réécrire, et non à marquer en échec attendu** :
- `test_inoperance.R` : vers l. 235-240, 340-352, 744-775 et 940-945 ;
- `test_p_mc_regime.R` : U5 (vers l. 330) et U12 (l. 621-626) de la spécification de #240, point (i) ;
- `test_regimes_p_exactes.R` : l. 201, à vérifier.

**Références** : **identiques** sur les six cas, B_eff = B partout (M1, toutes les lignes) **[V]**. Tableau avant / après sur jeux pathologiques (J1 et J2 à B = 40, `ta_pert` à B = 60) joint au commit.

**Visas.** La décision (B) change des verdicts **hors des références** (J1 : 3 ALERTE ou ECHEC → INFO ; 16 + 23 + 2 OK → INFO ; `ta_pert` : 1 ECHEC → INFO). C'est le choix D1-1 du mainteneur. Aucun verdict des références ne change.

## 4. #182 : textes inconditionnels

Principe (#128, point c) : un texte ne nomme une p que si elle existe, et ne qualifie une loi d'exacte que dans le régime où elle l'est.

| # | Texte | Régime qui le rend faux | Texte exact proposé |
|---|---|---|---|
| 1 | `detail` de « Shapiro-Wilk (loi nulle simulee, …) » à π̂_t variable | p_mc de `SW` absente | si `mc_dispo("SW")` : inchangé. Sinon : `"loi nulle i.i.d. sans objet a pi_t variable (W(P epsilon) n'a pas la loi de W sous i.i.d. normal) ; voir la ligne Shapiro-Wilk sur residus standardises (p Monte-Carlo indisponible sur ces donnees)"` |
| 2 | `txt_lr` des deux lignes du rapport de vraisemblance sur δ | `b$p_mc` absente | si `is.finite(b$p_mc)` : inchangé. Sinon : `"Aucun verdict (ADR 0001) : le LR mesure si les donnees distinguent cette borne de l'optimum, non l'adequation du modele. Lecture : LR = 0, borne atteinte par l'estimation. La p asymptotique (melange de Chernoff) est rapportee pour memoire et non retenue : ecart a la loi simulee mesure a T = 8 (fiche du .tex)."` |
| 3 | `loi` de Cox-Stuart | π̂_t variable ; ex æquo | π̂_t constant sans ex æquo : inchangé. π̂_t constant avec ex æquo : `"Binomiale(m, 1/2) EXACTE, m differences non nulles ; p_mc non calculee (ex aequo)"`. π̂_t variable sans ex æquo : `"Binomiale(m, 1/2), m differences non nulles, exacte a pi_t constant seulement (regle R7) ; p_mc par |K - n_p/2|, n_p paires, queue haute"`. π̂_t variable avec ex æquo : `"Binomiale(m, 1/2), m differences non nulles, exacte a pi_t constant seulement (regle R7) ; p_mc non calculee (ex aequo)"`. L'ex æquo se lit `cx$m < cx$n_p` |
| 4 | `loi_stephens()` (AD, CvM) | T < 8 ; p_mc absente | `loi_stephens(st, hors_plage, mc)` : `"loi %s, cas parametres estimes ; "` + (`!hors_plage` : `"p non simulee : ajustement de Stephens (cas 3) sur estim (statistique re-standardisee), non sur stat"` ; sinon `"p non simulee non calculee (T < 8, hors de la plage de l'implementation de reference)"`) + (`mc` : `" ; p_mc sur stat (statistique du catalogue)"` ; sinon `""`). À T = 8, avec p_mc, la chaîne est identique à l'actuelle **[V]** |
| 5 (D1-4) | `loi` des six autres lignes de la règle R7 à π̂_t variable | π̂_t variable | DW : `"forme quadratique en normales ; loi d'Imhof (1961), exacte a pi_t constant seulement (regle R7)"`. Suites sur z : `"loi combinatoire de R, exacte a pi_t constant seulement (regle R7)"`. Mann-Kendall : `"loi de S (distribution mahonienne), exacte a pi_t constant seulement (regle R7)"`. Smirnov : `"combinatoire (ks.test, sans ex aequo), exacte a pi_t constant seulement (regle R7)"`. SpearVol et SpearTps : `"permutation (T <= 9, sans ex aequo), exacte a pi_t constant seulement (regle R7)"`. À π̂_t constant, inchangés |
| 6 (D1-4) | `detail` de Smirnov à π̂_t variable (« p-value minimale atteignable = 0.0286 ») | π̂_t variable : la p retenue est Monte-Carlo, et 0,0286 ne la borne pas (p_min_mc mesurée 0,007 sur `premium_interieur`) | `"Voir aussi le QQ-plot a deux echantillons ; p-value minimale atteignable sous la loi de reference echangeable = %.4f, atteinte seulement pour D = 1 (deux groupes totalement separes)"` à π̂_t variable ; inchangé à π̂_t constant |

Les points 5 et 6 étendent #182 au-delà de son corps : même défaut, même champ, même régime, même patch (question D1-4).

**Fonctions touchées** : `usp_tests()` seule (la fermeture `loi_stephens` reçoit deux arguments de plus).

**Tests** (critère (a) de #182, deux branches par texte) :
- U182-1 — texte 1 : `boot$p_mc["SW"] <- NA` (motif posé), π̂_t variable (J2) → texte alternatif ; avec p_mc → inchangé.
- U182-2 — texte 2 : `lr_delta` construit, `b$p_mc` NA → texte sans guide ; fini → inchangé.
- U182-3 — texte 3 : les quatre régimes ; J1 et J2, plus une variante à différence nulle dans une paire.
- U182-4 — texte 4 : T = 8 avec Monte-Carlo (inchangé) ; T = 7 (`run_engine(T = 7)`) ; Monte-Carlo absent.
- U182-5 — textes 5 et 6 (si D1-4) : π̂_t constant inchangé, π̂_t variable nouveau.
- U182-6 — `premium_interieur` : l'écart à la référence se limite aux champs listés ; les cinq autres cas sont identiques.
- U182-7 — aucune p ni aucun verdict modifié.

**Références** : **patch chirurgical de `premium_interieur`** : `loi` de Cox-Stuart, constat 1 d'`architect` **[V]** (`p_exacte` NA, `loi` « … EXACTE … ») ; et, si D1-4, `loi` de DW, Runs, MK, Smirnov, SpearVol, SpearTps et `detail` de Smirnov. Autres cas identiques (π̂_t constant, p_mc présentes, T = 8, Cox-Stuart sans ex æquo, m = n_p = 4 **[V]**). **Visa** : aucun.

## 5. #244 : verdict Monte-Carlo proche d'un seuil

**Décision** (Q-E2b-5, phrase fixe d'`add()`). Constante `PHRASE_VERDICT_SENSIBLE_MC <- "verdict sensible a l'alea de simulation (p a moins de 2 erreurs de Monte-Carlo du seuil)"`, texte de l'issue.

**Condition.** La phrase est ajoutée en fin de `detail` si :
- la ligne est de type test, sans verdict fourni ;
- la p retenue est la p Monte-Carlo (pas de p exacte finie, `p_mc` finie, bootstrap ou `p_mc_ext`) ;
- `err_mc` est finie et > 0 ;
- et |p − s| < 2·`err_mc` (inégalité **stricte**) pour l'un des **seuils de la règle des verdicts de la ligne** :
  - sens « ne pas rejeter » : s ∈ {α/2, α} ;
  - sens « rejeter » : s ∈ {α, `SEUIL_ECHEC_SENS_REJETER`} (question D1-5).

`err_mc` vaut déjà √(p(k − p)/B_eff) selon le sens : le bilatéral est traité sans cas particulier.

**Placement** : dernier élément du `detail`, après la mention du plancher (#128, point d), avec la règle de jonction d'`add()` (« " " » après un point final, « " ; " » sinon).

**Exclusions** : diagnostic (dont test inopérant), non applicable, verdict fourni, p exacte retenue.

**Justification.** Près d'un seuil, le verdict dépend de la graine (#206, T4 ; vingt graines de #46 sur `reserve2`). La phrase ne change ni p ni verdict. Elle ne contient aucun nombre issu du bootstrap (règle #76) : « 2 » est une constante de la règle. Sa présence dépend des comptes de p_mc, qui sont aussi sensibles à la plateforme que le verdict lui-même **[H]**.

**Mesure sur les six cas** (M1) **[V]**. 11 lignes marquées, toutes au seuil α, aucune à α/2 :

| Cas | Ligne | p | err_mc | verdict |
|---|---|---|---|---|
| `premium`, `premium_ii6`, `premium_net`, `reserve1` (chacun) | Breusch-Pagan original | 0,090 | 0,0091 | ALERTE |
| idem | Homogénéité des dispersions (médiane) | 0,104 | 0,0097 | OK |
| `premium_interieur` | Grubbs | 0,105 | 0,0097 | OK |
| `reserve2` | Origine | 0,085 | 0,0088 | ALERTE |
| `reserve2` | Breusch-Pagan | 0,103 | 0,0096 | OK |

HomogF de `reserve2` (0,080, err 0,0086) n'est pas marquée. Le constat 2 d'`architect` est confirmé et étendu : les trois cas qu'il laissait à mesurer portent chacun deux lignes.

**Fonctions touchées** : `add()` seule.

**Tests** :
- U244-1 — unilatéral à α : p = 0,090 avec err 0,0091 → phrase présente ; p = 0,120 → phrase absente.
- U244-2 — à α/2 : p = 0,045 avec err 0,0066 → présente ; p = 0,035 → absente.
- U244-3 — bilatéral : p = 0,11, err = √(0,11 · 1,89/999) → présente.
- U244-4 — sens « rejeter » : p voisine de α et de 0,30 → présente.
- U244-5 — absente si p exacte retenue, diagnostic, inopérant, verdict fourni ou `err_mc = 0`.
- U244-6 — égalité |p − s| = 2 err → absente.
- U244-7 — six cas : exactement les 11 lignes ci-dessus ; p et verdicts identiques.
- U244-8 — la phrase est `identical()` à la constante.

**Références** : **patch chirurgical des six cas** (`detail` des 11 lignes). **Visa** : aucun. `app-review` seulement si l'affichage traite la phrase.

## 6. #204 : B effectif < B en Merz-Wüthrich

**Décision** (12/10, reprise telle quelle).
- Les 13 lignes Monte-Carlo de `mw_tests()`.
- **Cas A** : `p_mc` finie et B_eff < B. On ajoute :

  `sprintf("B effectif = %d sur B = %d (%d replication(s) ecartee(s), statistique non finie) : p-value Monte-Carlo conditionnelle a la definition de la statistique, comptee sur les seules replications ou elle est finie ; l'absence de biais de cette selection n'est pas demontree.", B_eff, B, B - B_eff)`.
- **Cas B** : motif `MOTIF_MC_REPLIC_INSUFFISANTES`. On ajoute `sprintf("B effectif = %d sur B = %d.", B_eff, B)`.
- Les nombres sont lus dans `boot$B_effectif[[mc_nom]]` et `boot$B`.
- Exception à la règle #76 **bornée à ces deux phrases**, posées par `mw_tests()` (Q-E2b-4 (A)). `add()` n'est pas touchée.

**Cohérence avec #181.** Sous (B), une ligne du cas B est un diagnostic : « Monte-Carlo indisponible : <motif> ; p non simulee (loi du champ loi) non retenue (ADR 0001). <detail de la ligne> B effectif = 42 sur B = 60. ». Les deux textes se complètent sans contradiction. Sous (A), la ligne reste en repli nommé, et la phrase du cas B s'ajoute de même.

**Hors de la décision** : `MOTIF_MC_AUCUNE_REPLIC` (le motif dit déjà B_effectif = 0), motifs dégénérés, lignes lognormales (C-E2b-3 : le même fait dans V3h relève de #254).

**Mise en œuvre.** Assistant nommé `.mw_phrase_b_effectif(boot, mc_nom)`, qui rend la phrase ou `""`. Il est joint en fin du `detail` passé à `add()`, avec la règle de jonction d'`add()`.

**Justification à T = 8.** La loi de référence devient celle de la statistique **sachant qu'elle est définie**. Aucun résultat ne garantit l'absence de biais de cette sélection. La mesure du corps de #204 montre un effet non négligeable devant l'erreur Monte-Carlo (HomogF 0,791 → 0,846, contre une erreur d'environ 0,016). La phrase le dit, sans corriger.

**Tests.** Le texte original de T1 à T5 n'est pas versionné : il est **re-spécifié ici** (question D1-6).
- T1 (cas A) — `ta_pert(9e-13)`, `mw_bootstrap(B = 99)` : Origine, HomogF et Courbure finissent par la phrase A avec **67, 99, 32** **[V]** (M4 : B_eff 67) ; les dix autres lignes ne contiennent pas « B effectif = ».
- T2 (cas B) — même triangle, B = 60 : les trois lignes contiennent « B effectif = 42 sur B = 60. » **[V]**, sans « conditionnelle a la definition » ; type selon D1-1.
- T3 — `reserve2` (`run_engine`) : aucune ligne ne contient « B effectif = », comme dans les références.
- T4 — `boot` construit avec `MOTIF_MC_AUCUNE_REPLIC`, puis avec chaque motif dégénéré : aucune phrase.
- T5 — lognormale :
  - aucune ligne d'`usp_tests()` ne contient « B effectif = » (J1 à B = 40 ; `premium_interieur`, V3b) ;
  - les tests existants de la mention du plancher sans nombre (#128, point d) passent inchangés ;
  - le test anti-bruit (`473ba49`) est relancé par `audit`.

**Références** : **identiques** (B_eff = B sur les 13 statistiques de `reserve2` **[V]**). **Visa** : aucun.

## 7. #125 : règle R1 lue sur la loi bootstrap

**Constat** **[V]**. À π̂_t variable, et en Merz-Wüthrich partout, la p retenue est Monte-Carlo. La règle R1 lit pourtant `p_min`, tirée de la loi échangeable, qui ne borne pas cette p. Mesures M2 du plancher p_min_mc (§ 1), comparé à p_min :

| Cas | Statistique | p_min (loi échangeable) | p_min_mc (N_haut ; N_bas ; B_eff) | err de p_min_mc |
|---|---|---|---|---|
| `premium_interieur` (V3b, matrice retenue) | Cox-Stuart | 0,125 | **0,149** (148 ; — ; 999) | 0,011 |
| | Suites sur z | 0,0571 | **0,058** (28 ; 38) | 0,011 |
| | Suites sur ratios bruts | 0,0571 | **0,062** (30 ; 36) | 0,011 |
| | Smirnov | 0,0286 | **0,007** (6) | 0,003 |
| | MK, SpearTps, SpearVol | 5,0e-5 | 0,002 (0 ; 0) | — |
| `premium` (V1 ; p exacte retenue, R1 inchangée) | Cox-Stuart ; suites z ; suites r ; Smirnov | 0,125 ; 0,0571 ; 0,0571 ; 0,0286 | 0,132 ; 0,058 ; 0,056 ; 0,029 | — |
| `reserve2` | Runs, Calendrier, CorrDev | de 3,8e-7 à 7,6e-6 | 0,002 | — |
| | HomogF, ExpVar, KruskalAcc | de 8,3e-15 à 1,5e-9 | 0,001 | — |

Sur Calendrier, le maximum simulé (2,557) dépasse l'extrémité du support observé (2,388) : les n_k des réplications diffèrent. Il faut donc les **extrémités du support à la configuration observée**, et non le maximum simulé. Le cas avec ex æquo de HomogF et ExpVar (commentaire `6120563166`) est le même mécanisme.

**Décision proposée (D1-7 à D1-10).**
1. **Champ du catalogue.** `.mc_entree(calc, queue, degenere = NULL, non_definie = NULL, extremes = NULL)`.
   - `extremes` vaut `NULL` ou `function(e)`, évaluée **une fois sur l'observé**. Elle rend `c(bas, haut)`, numérique de longueur 2 ; `NA` permis du côté inutile ; `NA` des deux côtés quand la p_min de la ligne n'est pas attribuée.
   - Refus par `stop()` à la construction (non-fonction) et à l'évaluation (forme).
2. **Calcul.** `engine_p_mc(sim, obs, queue, extremes = NULL)` rend en plus `p_min_mc` (formule du § 1). Il vaut `NA` si `extremes` est `NULL` ou `NA` du côté requis, ou si `p_mc` est `NA` (quel que soit le motif, `MOTIF_MC_REGIME_RARE` compris).
   - `.mc_p_values()` le rend en dernier élément. `usp_bootstrap()` et `mw_bootstrap()` l'exposent en **dernier élément** de leur liste (`bootstrap$p_min_mc`, vecteur nommé, `NA` pour les statistiques continues).
   - Sous V3b, il est calculé sur la **matrice retenue**, donc sous la loi conditionnelle au régime (C-A4-2) : M2 constate un seul appel de `.mc_p_values()`, sur 999 lignes **[V]**.
3. **Extrémités** (13 statistiques, définies exactement là où `p_min` l'est, ce qui laisse le domaine de R1 inchangé) :

| Clé | Sens | Extrémités à la configuration observée | Définie si |
|---|---|---|---|
| `CoxStuart` | haut | c(0, n_p/2) | m = n_p |
| `Runs` (z, plancher 1) ; `Runsr` (u, plancher `.usp_plancher_u(r)`) ; MW `Runs` (r) | deux | Z(R = 2) et Z(R_max), R_max = 2 min(n₁, n₂) + 1{n₁ ≠ n₂}, (n₁, n₂) de `.runs_effectifs()`. Z est calculé par un assistant partagé avec `test_runs()`, au bit près | n₁, n₂ ≥ 1 |
| `MK` | deux | Z(S = ∓T(T−1)/2), par le code de `test_mann_kendall()` | r sans ex æquo |
| `SpearTps`, `SpearVol` | deux | c(0, (T³ − T)/3) | sans ex æquo (r ; r et x) ; volumes non constants |
| `Smirnov` | haut | c(0, 1) | ligne calculable, z sans ex æquo |
| `Calendrier` | deux | ((0 − E)/√V, (Σ⌊n_k/2⌋ − E)/√V), sur les diagonales retenues de l'observé | statistique finie |
| `CorrDev` | deux | c(−1, 1) | sans ex æquo |
| `HomogF`, `ExpVar` | haut | X_max = `.fisher_combine(p_j,min)$stat`, avec p_j,min la plus petite p atteignable de la colonne j à sa structure d'ex æquo observée : 2/n_j! sans ex æquo, minimum du support de la loi conditionnelle aux rangs moyens sinon (à exposer par `.mw_spearman_loi_rangs()`) | n_j ≤ 9 pour tout j |
| `KruskalAcc` | haut | H de `kruskal.test()` sur l'affectation en blocs de rangs contigus aux tailles observées | sans ex æquo, et pas un résidu par année |

4. **Règle R1 dans `add()`.** `add()` lit `boot$p_min_mc[[mc_nom]]`, sans argument nouveau. Une branche Monte-Carlo s'applique si la ligne est de type test, `p_min` finie, sans p exacte finie, `p_mc` retenue (`mc_nom`, hors `p_mc_ext`) et p_min_mc finie :
   - p_min_mc ≥ α → diagnostic, `inoperant = TRUE`, `detail` préfixé : `sprintf("TEST INOPERANT au seuil alpha = %g : plus petite p-value Monte-Carlo atteignable sur ces replications >= alpha%s ; aucun verdict (ADR 0001).", alpha, eff)`, avec `eff` au format actuel « (effectifs) » ;
   - α/2 ≤ p_min_mc < α, sens « ne pas rejeter », au moins une p → suffixe `sprintf("ECHEC inatteignable : plus petite p-value Monte-Carlo atteignable sur ces replications >= alpha/2 = %g%s", alpha / 2, eff)` ;
   - p_min_mc < α/2 → aucun texte de R1. Le texte « ECHEC possible » disparaît, puisque le plancher réel est connu ;
   - dans cette branche, la mention du plancher de #128, point d, est omise (p_min_mc ≥ `granularite_stat`).

   Hors de cette branche (p exacte retenue, p_mc absente, p_min_mc `NA`), R1 garde son comportement actuel sur `p_min`. p_min_mc n'est **jamais imprimée** (règle #76) : elle se lit dans les champs.
5. **Champs.** Nouveau champ de ligne `p_min_mc`, posé par `add()` **après `inoperant`**. Il vaut la valeur lue par la branche Monte-Carlo de R1, `NA` sinon (en particulier quand la p exacte est retenue). Colonne `p_min_mc` d'`engine_table_tests()`, après `p_min` (`NULL` → `NA`). `CLAUDE.md`, « Structure d'un résultat de test » : quatre champs ferment la ligne (commit `claude:`, sur accord).

**Justification à T = 8.**
- **Exactitude.** La règle R1 doit dire si la p **retenue** peut atteindre le seuil. Pour les réplications tirées, p_min_mc est une borne **exacte** de cette p, alors que la p_min échangeable s'en écarte d'un facteur 2 dans les deux sens (corps de #125) ou la sous-estime avec ex æquo (0,0667 contre ≈ 0,142, commentaire `6120563166`).
- **Granularité et plancher.** Le changement de type reste fondé sur une propriété de la **loi** (un atome de masse ≥ α à l'extrémité, qui subsiste quand B → ∞) et non sur B. Cela le distingue de la granularité, que la décision du 01/10 laisse en mention seule.
- **Pas de marge** (D1-8). Une marge laisserait un « test » incapable de rejeter avec les réplications tirées, ce que R1 doit justement signaler. Le classement dépend de la graine, comme un verdict. Il est reproductible à graine fixée, et « sur ces replications » le dit.
- **Calendrier.** La question Q1 de l'audit de #115 (loi binomiale indépendante ou loi de permutation intra-colonne), renvoyée à #125 (commentaire de `.mw_calendrier_p_min()`), devient sans objet pour R1, qui lit la loi simulée. La p_min binomiale reste restituée.
- **Non-exactitude de la p.** p_min_mc ne rend pas la p Monte-Carlo exacte (ADR 0002). Elle ne borne pas l'erreur d'approximation à T = 8, qu'aucune théorie ne borne.

**Effet hors des références** **[H]**. Changements de type possibles dans les deux sens, donc des verdicts :
- Cox-Stuart à π̂_t variable de INFO vers un test (environ 1 ‰ des jeux, corps de #125 ; mesure d'`actuary` hors dépôt **[NV]**) ;
- suites sur ratios bruts vers INFO si les deux extrêmes sont fréquents ;
- HomogF et ExpVar avec ex æquo vers INFO (exemple à 0,142).

Fréquences non mesurées.

**Fonctions touchées** : `.mc_entree()`, `USP_CATALOGUE_MC`, `MW_CATALOGUE_MC`, `engine_p_mc()`, `.mc_p_values()`, `usp_bootstrap()` et `mw_bootstrap()` (champ en fin de liste), `add()`, `engine_table_tests()`, `test_runs()` et `test_mann_kendall()` (assistants partagés, à bits identiques, vérifiés par la comparaison aux références), `.mw_spearman_loi_rangs()` (exposition du minimum). Hors module : σ_USP, la sélection V3h.

**Tests** :
- U125-1 — `engine_p_mc()` sur vecteurs construits : trois sens, tolérance, `NA` si `p_mc` est `NA`.
- U125-2 — invariants sur les six cas et sur J1 et J2 à B = 99 : `granularite_stat ≤ p_min_mc ≤ p_mc` pour toute statistique où les deux sont finies.
- U125-3 — extrémités par énumération à T = 8 : les 70 arrangements de signes (suites), les C(8,4) partitions (Smirnov), les 8! permutations (MK, Spearman), les 16 signes (Cox-Stuart). Le minimum et le maximum énumérés égalent `extremes()`. En Merz-Wüthrich, par construction sur petits triangles, sans valeur énumérée au-delà.
- U125-4 — branche Monte-Carlo d'`add()` sur `boot` construit :
  - p_min_mc ≥ α → diagnostic, inopérant, préfixe exact ;
  - p_min_mc ∈ [α/2, α) → suffixe exact, sans « ECHEC possible » ;
  - p_min_mc < α/2 avec `p_min` = 0,0571 → test sans texte de R1 ;
  - p exacte finie → comportement actuel, octet pour octet (`detail` de Cox-Stuart de `premium` identique à la référence).
- U125-5 — HomogF et ExpVar avec ex æquo (triangle d'essai à facteurs répétés, choisi par `coder`) : X_max issu de la loi conditionnelle ; p_min_mc ≥ `p_min` ; bascule si p_min_mc ≥ α.
- U125-6 — oracle `premium_interieur` : p_min_mc = 0,149, 0,058, 0,062, 0,007, 0,002 ×3 (comptes 148 ; 28 ; 30 ; 6) ; Cox-Stuart inopérant ; suites z et r : « ECHEC inatteignable … » ; Smirnov, MK, Spearman : aucun texte de R1.
- U125-7 — `reserve2` : 0,002 (sens bilatéral) et 0,001 (queue haute) pour les six statistiques discrètes ; aucun texte de R1.
- U125-8 — champ de ligne après `inoperant` ; `NA` quand la p exacte est retenue (`premium`) ; colonne de la table.
- U125-9 — `bootstrap$p_min_mc` : dernier élément, noms du catalogue, `NA` sur les statistiques continues.
- U125-10 — refus de `extremes` mal formé.

Les tests existants qui lisent « ECHEC possible » ou « loi de reference echangeable » sont à revoir : 9 occurrences, `test_inoperance.R` et `test_merz_wuthrich.R`.

**Références** : **régénération des six cas par la CI** (`references.yml`, branche éphémère `claude/regeneration-125`, M30).

**Changements attendus** :
- nouveaux champs (`bootstrap$p_min_mc` et `tests[[k]]$p_min_mc`) sur les six cas ;
- `premium_interieur`, `detail` de trois lignes :
  - Cox-Stuart : texte d'inopérance Monte-Carlo, type inchangé ;
  - suites sur z et suites sur ratios bruts : « ECHEC possible » remplacé par « ECHEC inatteignable … sur ces replications » ;
- aucun type, aucun verdict, aucune p, aucun σ_USP changé **[V par M2, sous réserve de la CI]** ;
- `reserve2` : les écarts de #233 sont absorbés et **isolés** dans le tableau avant / après. Mesure M5 **[V]** : 2 275 valeurs numériques sur 3 953 diffèrent de la référence, écart maximal 4,653717e-13, aucune différence non numérique. Ils sont imputés à #233 en comparant la référence à `reserve2` recalculé **avant** le commit de #125 ; le reste est imputé à #125.

**Visas** : arrêt si σ_USP change. Le mainteneur tranche la règle à D1, puisqu'elle peut changer des verdicts hors des références. Tout verdict de référence changé à la CI renvoie à son visa (M3) ; `actuary` valide les textes.

## 8. Effet attendu sur les références

| Étape | `premium`, `premium_ii6`, `premium_net`, `reserve1` | `premium_interieur` | `reserve2` |
|---|---|---|---|
| 3 (#120) | identiques | identique | **patch** : `nature_p` de M5 Lilliefors |
| 4 (#181) | identiques | identique | identique |
| 5 (#182) | identiques | **patch** : `loi` de Cox-Stuart (+ six `loi` et le `detail` de Smirnov si D1-4) | identique |
| 6 (#244) | **patch** : `detail` de BP79 et BF | **patch** : `detail` de Grubbs | **patch** : `detail` d'Origine et de BP |
| 7 (#204) | identiques | identique | identique |
| 8 (#125) | **régénération** : champs seuls | **régénération** : champs + `detail` de Cox-Stuart et des deux lignes de suites | **régénération** : champs + écarts de #233 isolés |

σ_USP : inchangé partout. Verdicts des références : inchangés partout.

## 9. Visas

- **Mainteneur** :
  - D1 entière ;
  - #181, option et état de la ligne (verdicts hors références) ;
  - #125, règle (verdicts hors références) ;
  - tout verdict de référence qui changerait à la CI de #125 ;
  - arrêt si σ_USP change.
- **`actuary`** : textes de #182, #244 et #204 ; `detail` de #125 ; validation du `.tex` en fin de branche.
- **`app-review`** : `badge_nature()` (#120) ; affichage de la phrase de #244 et de la colonne `p_min_mc`, s'il change.

## 10. Surface documentaire (passage unique de `docwriter`, règle 9)

1. **`sec:nature`** (vers l. 4312) :
   - nouvelle nature « approximation à n fini sous i.i.d. normal » et les quatre familles de p non simulées ;
   - (ii) de « Monte-Carlo indisponible » (vers l. 4454-4525) réécrit selon D1-1 : fin du repli nommé, libellé « p non simulée (loi du champ loi) » ;
   - règle R1 (vers l. 4405) : branche Monte-Carlo, p_min_mc, « sur ces réplications », sans marge ;
   - mention du plancher (vers l. 4537) : omise sous la branche Monte-Carlo.
2. **`tab:nature`** (vers l. 4759) et **tableau 1** : la ligne M5 Lilliefors change de nature ; colonne `p_min_mc`.
3. **`tab:conv`** (vers l. 5148) : la famille (ii) n'est pas une convergence en T ; p_min_mc est exacte pour les réplications tirées, son erreur Monte-Carlo vient de B.
4. **Tableau des p_min** (vers l. 5457) : la note (v) est réécrite (R1 lue sur la loi bootstrap) ; Calendrier Q1 sans objet pour R1.
5. **Rubriques « P-value retenue »** des fiches des 34 et 13 statistiques Monte-Carlo : paragraphe commun avec renvoi, admis par `CONVENTIONS.md`, pour (B), la phrase de #244 et la phrase de #204 (fiches Merz-Wüthrich).
6. **Fiches à `p_min`** (Cox-Stuart, suites z et r, Smirnov, MK, Spearman ; HomogF, ExpVar, Calendrier, CorrDev, KruskalAcc, Runs de Merz-Wüthrich) : règle R1 et effet sur `premium_interieur`.
7. **Fiches AD, CvM, SW à loi nulle simulée, LR sur δ, Cox-Stuart** et, si D1-4, les six lignes de la règle R7 : textes de #182.
8. **Fiche « Colonnes dégénérées dans le bootstrap »** : phrases de #204 et exception à la règle #76.
9. **Index** des fonctions et constantes : `NATURE_APPROX_N_FINI`, `PHRASE_VERDICT_SENSIBLE_MC`, `.mw_phrase_b_effectif()`, `extremes` de `.mc_entree()`, assistants de Z, `engine_p_mc()` et `add()` (arguments).
10. **Reproductibilité** : nouveaux champs ; écarts de #233 absorbés.

## 11. Hors périmètre

- #245 (niveau de M5, C-E2b-2) ; #254, #255, #243, #253, #257, #259, #260, #258.
- Toute mesure de fréquence sous `run_engine()` des changements de type de #125.
- La nature « exacte » de la loi nulle simulée de Shapiro-Wilk (ADR 0002, non rouverte).
- σ_USP.

## Questions au mainteneur pour D1

- **Q-E2b-D1-1 (#181)** — Option : (A) statu quo ; **(B) généralisée** ; (B′) repli de la famille (ii) à π̂_t constant seulement ; (C) refus du calcul. *Recommandation : (B)* (§ 3 : aucune famille n'est valide à T = 8 ; ADR 0014, point 2 ; écarts mesurés). Verdicts changés hors références seulement.
- **Q-E2b-D1-2 (#181)** — État de la ligne sous (B) : **diagnostic** (précédent de la constante, définitions de `CONTEXT.md`) ou test sans p-value retenue. *Recommandation : diagnostic.* Le libellé par défaut est « p non simulee (loi du champ loi) ».
- **Q-E2b-D1-3 (#120)** — Libellé « approximation a n fini sous i.i.d. normal », badge « approx. n fini ». Portée : M5 Lilliefors et Anscombe-Glynn sous (B) ; plus les six lignes de la famille (ii) d'`usp_tests()` sous (A). *Recommandation : oui.*
- **Q-E2b-D1-4 (#182)** — Extension aux `loi` des six autres lignes de la règle R7 (DW, suites sur z, MK, Smirnov, SpearVol, SpearTps) et au `detail` de Smirnov à π̂_t variable. *Recommandation : oui*, dans le même commit et le même patch de `premium_interieur`. Alternative : une issue nouvelle.
- **Q-E2b-D1-5 (#244)** — Seuils de la règle des verdicts de la ligne : {α/2, α} en sens « ne pas rejeter », {α, 0,30} en sens « rejeter ». *Recommandation : oui* (« du seuil » s'entend des seuils du verdict).
- **Q-E2b-D1-6 (#204)** — Tests T1 à T5 re-spécifiés au § 6, le texte du 11/10 n'étant pas versionné ; `MOTIF_MC_AUCUNE_REPLIC` hors de la phrase. *Recommandation : approuver.*
- **Q-E2b-D1-7 (#125)** — Portée : les 13 statistiques discrètes, par le champ `extremes` du catalogue, ce qui laisse le domaine de R1 inchangé. Alternative : Cox-Stuart, suites, Smirnov, HomogF et ExpVar seulement. *Recommandation : les 13* (règle uniforme, coût faible).
- **Q-E2b-D1-8 (#125)** — Règle : R1 lit p_min_mc **seule, sans marge**, quand la p Monte-Carlo est retenue. Alternatives : max(p_min, p_min_mc − 2 err), qui mêle deux lois (écartée) ; marge p_min_mc − 2 err ≥ α. *Recommandation : sans marge.* Cela remplace, pour HomogF et ExpVar avec ex æquo, la lecture de `p_min` confirmée le 12/10, comme le commentaire `6120563166` le prévoyait.
- **Q-E2b-D1-9 (#125)** — Pas de phrase de sensibilité (style #244) pour p_min_mc proche de α. *Recommandation : non*, le classement étant exact pour les réplications tirées.
- **Q-E2b-D1-10 (#125)** — Champs : `p_min_mc` de ligne après `inoperant` (avec la mise à jour de `CLAUDE.md`), `bootstrap$p_min_mc` en fin de liste, colonne de la table après `p_min`. *Recommandation : oui.*

## Sources en ligne consultées

- [rdrr.io — nortest::lillie.test (Dallal-Wilkinson, fiabilité pour p < 0,1)](https://rdrr.io/cran/nortest/man/lillie.test.html)
- [statsmodels — source de lilliefors (référence Dallal et Wilkinson 1986, Am. Statist. 40(4), 294-296)](https://statsmodels.org/0.6.1/_modules/statsmodels/stats/lilliefors.html)
- [IMSL — Lilliefors normality test (approximation analytique de Dallal et Wilkinson)](https://help.imsl.com/python/current/docs/stat/fit/lillieforsNormalityTest.html)
- [Springer — Royston (1992), Statistics and Computing 2, 117-119](https://link.springer.com/article/10.1007/BF01891203)

## Annotation du 12/10/2026 : décisions du mainteneur au point D1

*Décisions rendues en session par le mainteneur, toutes selon les recommandations d'`actuary`. Le code peut commencer.*

| Question | Décision |
|---|---|
| Q-E2b-D1-1 (#181) | **(B) généralisée** : plus aucun repli sur une p non simulée quand la p Monte-Carlo manque pour un motif non dégénéré |
| Q-E2b-D1-2 (#181) | la ligne devient un **diagnostic** (verdict INFO, p non simulée conservée dans sa colonne, non retenue) ; libellé par défaut « p non simulee (loi du champ loi) » |
| Q-E2b-D1-3 (#120) | nature « approximation a n fini sous i.i.d. normal », badge « approx. n fini » |
| Q-E2b-D1-4 (#182) | extension aux `loi` des six autres lignes de la règle R7 et au `detail` de Smirnov, dans le même commit et le même patch de `premium_interieur` |
| Q-E2b-D1-5 (#244) | seuils du verdict : {α/2, α} en sens « ne pas rejeter », {α, 0,30} en sens « rejeter » ; patch des six références |
| Q-E2b-D1-6 (#204) | tests T1 à T5 du § 6 approuvés ; `MOTIF_MC_AUCUNE_REPLIC` hors de la phrase |
| Q-E2b-D1-7 (#125) | portée : les 13 statistiques discrètes, par le champ `extremes` du catalogue |
| Q-E2b-D1-8 (#125) | R1 lit p_min_mc **seule, sans marge**, quand la p Monte-Carlo est retenue ; pour HomogF et ExpVar avec ex æquo, cela remplace la lecture de `p_min` confirmée le 12/10 au matin |
| Q-E2b-D1-9 (#125) | pas de phrase de sensibilité pour p_min_mc |
| Q-E2b-D1-10 (#125) | champ `p_min_mc` de ligne après `inoperant` (mise à jour de `CLAUDE.md`), `bootstrap$p_min_mc` en fin de liste, colonne de la table après `p_min` |

**Verdicts hors références** changés par #181 et #125 : approuvés par ces décisions. Tout verdict **de référence** qui changerait à la régénération de #125, et tout changement de σ_USP, restent soumis au mainteneur.
