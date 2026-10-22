# Spécification de Fj : Merz-Wüthrich, M1 et M2, identifiabilité et pente relative ; restes de M4 — point d'arrêt D1-Fj (#291, #356, #352, #308, #307)

> **Décisions du mainteneur du 22/10/2026 (E-22/10 (D1-Fj)) : point d'arrêt D1-Fj franchi.**
>
> *Consignées par la session principale (IA)* ; source : réponses du mainteneur aux questions de la session principale. Le présent document reprend à la lettre la spécification D1-Fj d'`actuary-approfondi` du 22/10/2026 (lecture seule) ; les scripts de mesure de la consultation (`m1.R` à `m9.R`) sont restés hors dépôt.
>
> - **Q-D1-Fj-1 (#308)** : selon la recommandation, forme **F1** : une ligne de diagnostic dans M1, après la famille α, texte T-3.
> - **Q-D1-Fj-2 (#308)** : selon la recommandation : CV_j, R_j et e_a,j (σ̂_j de Mack) ; aucun effet minimal détectable dans le moteur ; multiplicateurs de la Student décentrée dans le `.tex`.
> - **Q-D1-Fj-3 (#307)** : selon la recommandation : **critère K-307 adopté**, déclaré formulé a posteriori ; il est tenu, et la pente relative remplace la pente absolue.
> - **Q-D1-Fj-4 (#307)** : selon la recommandation : clé **`PenteIntra`** conservée.
> - **Q-D1-Fj-5 (famille α)** : selon la recommandation, option **(b′)** : test de (iii) conservé, ECHEC inchangé sur `reserve2`, `detail` T-5.
> - **Q-D1-Fj-6** : selon la recommandation : tableau des comparaisons appariées versionné (`docs/tableaux/AAAAMMJJ-issue307-paires.md`, code R inclus, md5 du brut cité) en commit `docs:` préparatoire, avant le code de #307.
> - **Q-D1-Fj-7** : selon la recommandation : `.mw_lm_intra()` et `.mw_pente_intra()` retirées après #307 ; oracles `lm()` à la place des assertions de pente de `test_forme_close_m1.R` ; partie pente de `generer_valeurs_forme_close_m1.R` mise à jour sur un poste qui dispose de Rmpfr, ou retirée.
> - **Q-D1-Fj-8 (Mack 1999)** : **contre la recommandation** : la référence est à **vérifier par une session à accès complet à internet** (précédent de la décision 2 du 21/10 et de `af4710e`), puis consignée au relevé M38 (`docs/references/verifications-fj.md`). Son ajout à `mw:m1d` dépend du résultat de cette vérification.
> - **Q-D1-Fj-9 (#352)** : selon la recommandation : textes T-1 et T-2 tels quels ; ε = 1e-10 et 1e-6 sur la construction du § 2.3. *(Précisé le 22/10/2026 par le mainteneur, sur proposition d'`actuary` à la validation de l'étape 3 : T-2 retouché, « calculee sur » devient « dont la statistique est calculee sur », pour lever la lecture « M4 ne dépend pas des résidus de Mack » ; T-1 inchangé.)*
> - **Q-D1-Fj-10 (visa de #307)** : **visa de principe** du changement de verdict de la pente intra-colonne (OK → ALERTE sur `reserve2`, p_mc 0,778 → 0,090) avec la famille α en (b′) (ECHEC inchangé) ; σ_USP inchangé. Visa à confirmer au tableau avant / après réel.
>
> **Transmis à R21 (#350, #354)** : la cause probable de « invalid 'times' argument » (`NL_MAX <- 19L`, § 8, [H]), et le contrôle (b) de `tests/calibration_mc_mw_t8.R` rendu faux aussi pour `PenteIntra` par #307.

> *Rédigé par l'agent actuary (IA).* Consultation `actuary-approfondi` du 22/10/2026, en lecture seule, à la demande de la session principale. Elle porte sur la fiche Fj du trente-neuvième point d'étape, validée par le mainteneur le 22/10. Périmètre fermé, dans cet ordre : #291, #356, #352 (I-39-1), #308, #307. Branche `claude/merz-wuthrich-identifiabilite`, partie de `main` `510b03d`. **Point d'arrêt D1-Fj** : aucun code de #352, #308 ni #307 tant que le mainteneur n'a pas tranché Q-D1-Fj-1 à Q-D1-Fj-10. #291 et #356 peuvent commencer tout de suite (§ 1).

**Marques** : **[V]** vérifié (source citée, ou commande exécutée et sortie lue) ; **[H]** hypothèse ou raisonnement non mesuré ; **[NV]** non vérifié.

## 0. Sources, mesures, contraintes

**Lu [V]** :
- les issues #291, #356, #352, #308 (et son commentaire), #307, #312, #297 ;
- la partie 3 du trente-neuvième point ;
- `docs/specifications/fi-merz-wuthrich-puissance.md`, y compris les décisions D1-Fi et D2-Fi ;
- `docs/tableaux/20261021-issue309-puissance-mw.md` (T0, T1, T1 bis, T2, T5 à T7) et son `-brut.tsv` (md5 `f616a3bc2e9a0cb6ce255396b0130ba0`, conforme au T0, versionné à `1e3979c`) ;
- `tests/puissance_mw_t8.R` : en-tête, `stat_pente_rel()` l. 762, mode `--controle-i2prime` l. 2352 ;
- `docs/references/verifications-fi.md` ;
- `CONTEXT.md` (Test, Diagnostic, Verdict, Test sans p-value retenue) ;
- dans `R/engine.R` (tête `510b03d`) : `.mw_lm_intra()` (l. 8961), `mw_test_heteroscedasticite_intra()` (l. 9026), `mw_test_ordonnee_origine()` (l. 9448), `mw_famille_alpha()` (l. 9837), `mw_test_exposant_variance()` (l. 9862), `mw_test_homogeneite_accident()` (l. 9910), `.mw_pool_residus()` (l. 10210), `MW_CATALOGUE_MC` (l. 10409), `mw_tests()` (l. 10621-11071), `mw_influence()` (l. 11591), `mw_test_cellule_aberrante()` (l. 11715), l'avertissement des colonnes dégénérées (l. 8494-8513) ;
- dans `.tex` : les fiches `mw:m1`, `mw:m1d`, `mw:m2bp`, `mw:m2b`, la frontière numérique de `mw:m4gr` (l. 15913-15930), et les lignes MW de `tab:nature` et `tab:conv` ;
- le registre `DECOMPTES` de `tests/concordance_doc_moteur.R` ;
- les tests M4 de `tests/unitaires/test_merz_wuthrich.R` (l. 2840-2960).

**Mesures [V]** : `Rscript` R 4.3.3, `LC_ALL=C.UTF-8`, moteur `510b03d` chargé par `source()`.
- `reserve2` : `tests/reference/reserve2.rds` relu. Pente relative calculée par **injection** d'une entrée dans `MW_CATALOGUE_MC`, puis `mw_bootstrap(aj, B = 999, seed = 20260831)`. Contrôle : la `p_mc` de `PenteIntra` reste `identical()` à la référence.
- Paires McNemar exactes recalculées sur le brut versionné de #309 (colonnes `p:<clé>`).
- Frontière ε calculée sur le triangle `tri_nb300` paramétré.

**Sources externes** : Mack (1999) est **[NV]**. Le proxy refuse `casact.org`, `cambridge.org` et `ideas.repec.org` (CONNECT 403). Les autres références de cette spécification sont celles que `verifications-fi.md` a déjà vérifiées (§ 9).

**Contraintes de Fj (fiche)** : ni `app.R` ni `R/display_helpers.R` ; aucun préfixe nouveau dans `GROUPES` ; `add()`, `engine_registre_tests()`, `engine_p_mc()` et `.mc_p_values()` inchangés. Toutes les recommandations ci-dessous tiennent dans ce périmètre.

## 1. #291 et #356 : identiques au bit près, sans question de fond

**#291 [V, lecture]**. `mw_test_exposant_variance(aj, jd, res)` et `mw_test_homogeneite_accident(aj, jd, res)` exécutent `if (is.null(res)) res <- mw_residus(aj, j_degeneres)` avec le même `jd` que `mw_tests()` (l. 10628). Passer `res` donne donc les mêmes objets.
- Critère : `identical()` et `comparer_references.R --seuil 0`.

**#356 [V, lecture]**.
1. Boucle `1 - h`. Les deux expressions sont identiques : `.mw_sommes_autres(col)[res$i[sel] + 1] / sum(col)` (l. 9031-9035 et 10218-10222). Une fonction commune, même ordre d'opérations, rend le même vecteur au bit près.
   - Les commentaires « ALGÈBRE FIGÉE » de #301 restent vrais : (i2′) compare des valeurs, non du texte.
2. `mw_influence()` recalculée. À l'observé, elle est appelée par la statistique `MinP4`, par `non_definie` et par `mw_tests()`. Toute mise en cache est libre, à condition de calculer la même fonction sur le même `aj`.
   - Un champ ajouté au contexte de `.mw_contexte_mc()` est compatible avec les entrées injectées par les scripts de mesure, qui ne lisent que `aj`, `res`, `r` et `figes`.
   - Un argument facultatif `inf = NULL` de `mw_test_cellule_aberrante()` suit le précédent de `res` (#239).
3. `tv[nb] <- .Machine$double.xmax` (l. 11736) est sans effet. Pour une cellule non bornée, `p[nb] <- 0` écrase la p aussitôt, et `tv` ne sert qu'à `p` : le retour lit `tk`, pas `tv`. Le retrait laisse `p`, `M`, `t` et `cellules` identiques.
   - Le commentaire « ALGÈBRE FIGÉE (#300) » doit dire que cette affectation, nécessaire au script pour TMax, est absente du moteur.

Aucune question pour `actuary`. Tout écart à `--seuil 0` arrête l'étape. Rejouer (i2′) `--cle-moteur MinP4 --candidat MinP4` après #356 est facultatif ; je le recommande si le cache touche le contexte de réplication.

## 2. #352 : M4, `reference`, avertissement, frontière numérique (S-Fj-3)

### 2.1 `reference` de la ligne M4

`verifications-fi.md`, § 2.1 [V] :
- t_i et sa loi t(n − p′ − 1) sous normalité : Cook et Weisberg (1982), § 2.2.1, p. 20, éq. (2.2.9) ;
- pondération : annexe A.1, p. 209 ;
- borne de Bonferroni sur max |t_i| : p. 22 et 26 ;
- Belsley, Kuh et Welsch (1980) [P] : attesté pour le nom RSTUDENT seulement, par Atkinson (1983, p. 24).

Sont propres à l'outil : le minimum des p entre colonnes de degrés de liberté différents, la condition n_j ≥ 4 et la p de Monte-Carlo. Texte exact au § 5, **T-1**.

### 2.2 Avertissement des colonnes dégénérées

`mw_test_cellule_aberrante()` écarte les colonnes de `figes$degeneres` (l. 11724), et `mw_influence()` leur rend `dfbetas = NA` [V, lecture]. La ligne n'est pas dans `.MW_LIGNES_RESIDUS`, à juste titre : elle ne lit pas `mw_residus()`. L'avertissement doit pourtant la nommer comme ligne qui écarte aussi ces colonnes.
- Texte exact : **T-2** (§ 5).
- Je recommande une constante unique pour le nom de la ligne, lue par `add()` et par l'avertissement.
- Le décompte « N lignes de M1 à M5 fondées sur les résidus » (registre `DECOMPTES`) ne change pas.

`reserve2` n'émet pas cet avertissement [V : `ref$validation$avertissements` ne contient que deux messages, crédibilité et variance] : `reserve2.rds` n'en est pas affecté. Le test unitaire porte sur un triangle à colonne dégénérée, par exemple `td` de `test_merz_wuthrich.R` (l. 2919).

### 2.3 Frontière numérique : valeurs de ε

**Construction.** C'est celle de `mw:m4gr` (l. 15919-15921) : le triangle `tri_nb300` où les facteurs F(1,0) et F(3,0) sont multipliés par 1 + ε et 1 − ε, les colonnes suivantes étant reconstruites par les mêmes facteurs. Concrètement, `m[1:5, 2] <- m[1:5, 1] * c(1.5, 1.5 * (1 + eps), 1.8, 1.5 * (1 - eps), 1.5)`, le reste à l'identique de `tri_nb300`.

**Mesuré [V]** (`mw_test_cellule_aberrante()`, sans aléa) :

| ε | statistique | cellule non bornée | t(2,0) | `run_engine(B = 99)` |
|---|---|---|---|---|
| 0 | NA | (2,0) | NA | — |
| 1e-10 | NA | (2,0) | NA | type `test`, INFO, `p_retenue` NA |
| 2e-8 | NA | (2,0) | NA | — |
| 3e-8 | 7,64e-21 | aucune | 6,6e6 | — |
| 1e-6 | 2,83e-16 | aucune | 1,98e5 | type `test`, ECHEC, p_mc 0,01 (plancher) |

La frontière est entre 2e-8 et 3e-8. **ε = 1e-10** est à un facteur 200 en dessous et **ε = 1e-6** à un facteur 33 au-dessus, soit 4·10⁴ et 10³ en variance résiduelle : loin de la tolérance dans les deux sens. **Valeurs retenues : 1e-10 et 1e-6.**

**Assertions du test** :
- ε = 1e-10 : `stat` NA ; `non_borne` = `data.frame(i = 2L, j = 0L)` ; `mw_tests()` après `mw_bootstrap(a, B = 19)` rend une ligne `type = "test"`, verdict INFO, `p_retenue` NA, `inoperant` FALSE ;
- ε = 1e-6 : `stat` finie et > 0 ; `nrow(non_borne) == 0` ; `|t(2,0)| > 1e5`.
- Aucune assertion sur le verdict à ε = 1e-6 : il dépend de B.

## 3. #308 : identifiabilité intra-colonne (S-Fj-1)

### 3.1 Constat, revu sur les mesures de #309

**Reproduit [V]** : CV de C(i,j) = 0,0739 ; 0,0763 ; 0,0796 ; 0,0751 ; 0,0599 (j = 0 à 4). Les effets minimaux détectables de l'issue (20, 16, 26, 36 et 67 %) sont retrouvés avec l'erreur type **observée** de â_j, celle de `lm()` avec constante, et la Student décentrée à α = 0,10 bilatéral et puissance 0,80.

**Ces effets minimaux sont optimistes [V].**
- L'erreur type observée est elle-même une estimation à n_j − 2 degrés de liberté, très bruitée : en colonne 1, 0,054 C̄₂ contre 0,093 C̄₂ avec le σ̂_j de Mack.
- Le T7 (d) de #309 donne, sous P1, contre une ordonnée de 20 % (CST20), des taux de rejet par colonne de 0,695 ; 0,343 ; 0,211 ; 0,187 ; 0,157 au seuil 0,10. Or l'issue annonçait une puissance ≥ 0,80 dès 16 % en colonne 1.
- Avec le σ̂_j de Mack, les effets minimaux deviennent 23, 28, 32, 32 et 56 %, soit des puissances < 0,80 à 20 % dans toutes les colonnes. C'est cohérent avec T7 (d), en ordre de grandeur seulement : les triangles simulés ont un CV un peu plus faible (T7 (a), P1, j = 1 : 0,067) et CST modifie aussi C(i,1).

**M1 : la dispersion est déterminante [V, T7 (c)].** Contre CST20, au seuil 0,10 :

| Ligne | P1 (CV ≈ 0,06) | P2 (CV ≈ 0,23) |
|---|---|---|
| Origine | 0,683 | 1,000 |
| Pente absolue | 0,522 | 0,932 |
| Pente relative | 0,796 | 0,967 |

**M2 : le constat de l'issue ne tient pas dans la plage mesurée [V, T7 (c)].** L'issue propose d'écrire qu'un OK n'est une preuve qu'à CV élevé. Or, sous P2 aussi (CV ≈ 0,23 ; R = 476/204 = 2,33 sur la première colonne), M2 n'a pas de puissance mesurable :

| Ligne (P2) | exposant 0 | exposant 2 | niveau sous H0 |
|---|---|---|---|
| FWr | 0,124 | 0,112 | 0,094 |
| ExpVar | 0,080 | 0,091 | 0,089 |

La lecture « OK probant à dispersion élevée » vaut pour M1, pas pour M2. Statut : constat de simulation sous un plan.

### 3.2 Forme (a) : recommandation F1, une ligne de diagnostic dans M1

**F1 (recommandée)** : une ligne `type = "diagnostic"` dans la famille M1, placée **juste après** la ligne de la famille α (fin du bloc M1).
- Son `detail` restitue les grandeurs par colonne.
- Précédent : le diagnostic « Effets d'année calendaire par diagonale », qui restitue une valeur par diagonale.
- Elle sert M1 et M2 (texte T-3). Le préfixe « M1 » existe déjà dans `GROUPES`.
- Elle ne lit pas `mw_residus()` (seulement `aj$tri` et `aj$sigma2`) : `.MW_LIGNES_RESIDUS` est inchangé, et la mesure de `test_merz_wuthrich.R` qui perturbe `mw_residus()` reste valide [V, lecture].

**F2 (alternative)** : compléments de `detail` sur Origine (CV, e_a) et sur FWr et ExpVar (R).
- Avantage : aucune ligne nouvelle.
- Inconvénients : une même information éclatée sur trois lignes de test, et des nombres descriptifs mêlés aux textes de test.

**Risque de F1** : l'insertion décale les lignes suivantes (M2 à M6). Avant le run de régénération, un audit léger doit chercher les désignations positionnelles (leçon 7 du trente-neuvième point).

### 3.3 Grandeurs (b), toutes calculées sur l'observé (règle #76)

Fonction nommée **`mw_identifiabilite_intra(aj, j_degeneres = NULL)`**.

**Colonnes retenues** : j = 0..J−1, n_j = I − j ≥ 3, j ∉ `.mw_j_exclues(aj, j_degeneres)`. Ce sont les colonnes éligibles de l'ordonnée à l'origine. Pour chacune, avec C0 = C(0..I−j−1, j) et C1 = C(0..I−j−1, j+1) :

- **CV_j** = `sd(C0) / mean(C0)` (écart-type à n − 1, définition du T7 (a) de #309).
- **R_j** = `max(C0) / min(C0)`.
  - Lecture exacte à f_j et σ_j connus : sous Var(C(i,j+1) | C(i,j)) = σ² C(i,j)^k, le rapport des variances des résidus de Mack entre les deux cellules extrêmes vaut R_j^(k−1).
- **e_a,j** = σ̂_j √(S_j / D_j) / C̄_{j+1}, avec :
  - S_j = Σ C0 ; D_j = Σ_{a<b} ((C0_a − C0_b) / √C0_a / √C0_b)², forme stable sans débordement ;
  - σ̂_j = `sqrt(aj$sigma2[j + 1])` ; C̄_{j+1} = `mean(C1)` ; e_a,j = NA si D_j = 0.
  - Identités exactes [V, algèbre ; numérique sur `reserve2`] : D_j = S_j Σ 1/C0 − n_j², et Var(â_j | C(·,j)) = σ_j² S_j / D_j dans la régression pondérée C1 ~ a + b C0, poids 1/C0, à variance σ_j² C0.
  - Oracle de test : `summary(lm(C1 ~ C0, weights = 1/C0))$cov.unscaled[1, 1]` = S_j / D_j, à 1e-10 relatif.
  - Grandeur sans dimension et invariante d'échelle : couverte par le test de domaine #185.
- **estim** : moyenne des CV_j des colonnes retenues ; NA s'il n'y en a aucune.

Valeurs sur `reserve2` [V] (estim = 0,07295) :

| j | n_j | CV | R | e_a |
|---|---|---|---|---|
| 0 | 7 | 0,0739 | 1,229 | 0,0800 |
| 1 | 6 | 0,0763 | 1,211 | 0,0930 |
| 2 | 5 | 0,0796 | 1,206 | 0,0973 |
| 3 | 4 | 0,0751 | 1,182 | 0,0812 |
| 4 | 3 | 0,0599 | 1,126 | 0,0685 |

**Effet minimal détectable : non restitué par le moteur** (Q-D1-Fj-2). Il dépend d'α, de la puissance visée, du modèle auxiliaire gaussien et du σ branché. Sa version « σ observé » de l'issue est démentie par T7 (d).
- Le `.tex` donne les multiplicateurs de lecture : quantile de la Student décentrée à n_j − 2 degrés de liberté donnant une puissance 0,80 au seuil 0,10 bilatéral.
- Valeurs : 2,905 (n_j = 7) ; 3,040 (6) ; 3,299 (5) ; 3,979 (4) ; 8,192 (3) [V, calcul numérique par `stats::pt(ncp =)`].
- Statut : exact sous erreurs gaussiennes à paramètre de décentrement a_j / se(â_j) vrai ; avec e_a, une estimation.

### 3.4 Rubriques 7 (c) : contenu pour `docwriter`, § 6.

### 3.5 Décomptes prévisionnels (d), F1

- `reserve2` : 20 → 21 lignes ; diagnostics 7 → 8 ; INFO 7 → 8 ; famille M1 : 5 → 6 entrées.
- Registre `DECOMPTES` : « entrées par type » et « M1 (N entrées) » à mettre à jour (écart de concordance attendu ; commit `docs:` minimal M32 avant push).
- `tab:nature` : + 1 ligne dans le bloc M1, sur le modèle de « Variance unitaire des résidus de Mack ».
- `tab:conv` : + 1 ligne recommandée dans le bloc (C), sur le modèle de « Variance des résidus de Mack (diagnostic) » : « Aucune : grandeurs exactes sur l'observé ; e_a sous le modèle de Mack à σ_j estimé ».
- Nouvelle fiche de diagnostic (six rubriques, label proposé `mw:m1id`) ; index des fonctions.
- Avec F2 : aucune de ces lignes.

## 4. #307 : pente relative et famille α (S-Fj-2)

### 4.1 Définition (a), identique à `stat_pente_rel()`

Hypothèse visée : D(2)(h)(iii), proportionnalité sans constante, alternative « facteur relatif qui dépend du volume relatif ».

**Statistique.** t de la pente b dans la régression de y = F/f̂_j sur x = (C − C̄_j)/C̄_j, avec :
- C̄_j = `stats::ave(res$C, res$j)`, moyenne simple des cellules retenues de la colonne ;
- effets fixes de colonne, par partialisation (centrage pondéré `.mw_centrage_pondere()`) ;
- poids w = C f̂_j² / σ̂_j², ramenés à max w ∈ [1, 2[ ;
- ddl = N − G − 1.
- Variance de y : Var(F/f_j | C) = σ_j² / (C f_j²), d'où le poids des moindres carrés généralisés.

**Algèbre figée** : mêmes opérations, dans le même ordre, que `stat_pente_rel()` (`tests/puissance_mw_t8.R`, l. 762-783). Gardes identiques, rendant NA :
- `nrow(res) < 4` ;
- σ_j non fini ou ≤ 0 ;
- S_xx non fini ou ≤ 0 ;
- ddl < 1 ;
- se non fini ou ≤ 0.

**Fonction et ligne.** Fonction nommée proposée **`.mw_pente_relative(res)`**, qui rend b, se, t et la p de Student. La clé `PenteIntra` de `MW_CATALOGUE_MC` lit son t. La ligne restitue `estim` = b̂, élasticité du facteur au volume à colonne donnée. La p de Student est une p non simulée (`p_asymptotique`), jamais retenue (#181).

**Contrôle (i2′)** : `Rscript tests/puissance_mw_t8.R --controle-i2prime --cle-moteur PenteIntra --candidat PenteRel`. Il doit rendre `identical()` sur `reserve2` et sur les 420 triangles marqués. Le mode reste valide d'après l'en-tête du script ; coût d'environ 0,7 h.

**Valeurs sur `reserve2` [V]** :
- t = 1,732954 (égal au bit près à `stat_pente_rel()`), b̂ = 0,0592, se = 0,0341, ddl = 20 ;
- p de Student 0,0985 ; p_mc 0,090 ; err_mc 0,01312 ; B_eff 999.
- Parts d'information par colonne : 19,7 ; 15,2 ; 14,2 ; 20,3 ; 27,7 ; 2,9 %, contre 0,1 ; 2,4 ; 9,1 ; 28,5 ; 53,4 ; 6,6 % pour la pente absolue. Les chiffres de l'issue sont reproduits.

**Robustesse numérique [V]** (triangles extrêmes de #253 : ligne 0 × 1e15, × 1e-15, × 1e-14, « bornes » et « extrême ») :
- t est fini partout ;
- il égale à ≤ 2,6e-16 en relatif la variante x = C/C̄_j, sans soustraction, mathématiquement équivalente puisque la constante est absorbée par l'effet de colonne ;
- sur `reserve2`, il égale `lm()` à 2e-14.
- Aucune référence Rmpfr n'a été établie : Rmpfr est absent de la session (Q-D1-Fj-7).

**Mécanisme.** Une ordonnée à l'origine a_j donne dans la colonne j une pente relative ≈ −a_j / (f_j C̄_j), au premier ordre en C = C̄_j [V, algèbre]. Conséquence à dire dans la rubrique 7 : le scénario CST de #309 (a_j = δ f_j C̄_j) produit une pente relative **commune** −δ. C'est exactement l'alternative que vise la pente relative, et le gain mesuré contre CST est donc mesuré sous l'alternative la plus favorable à cette paramétrisation. Une ordonnée concentrée sur une seule colonne n'est **pas mesurée**.

### 4.2 Recevabilité du niveau (b) : critère K-307 formulé a posteriori

**Données [V]** (T1, T1 bis et brut ; ρ = 0,098 et 0,048).

Volet A (plan et graines de #206, donc « niveau sous le protocole de #206 » de l'issue) :

| Loi | seuil 0,10 | classe | seuil 0,05 | classe |
|---|---|---|---|---|
| N | 0,1115 [0,098 ; 0,126] | écart mineur | 0,061 [0,051 ; 0,072] | écart mineur |
| E | 0,1105 | compatible | 0,0545 | compatible |
| A | 0,118 [0,099 ; 0,140] | écart mineur | 0,059 | compatible |

Pour comparaison, la pente absolue en place (#206, `mw:m1`) : 0,114, 0,1205 et 0,130 à 0,10 ; 0,064, 0,053 et 0,073 à 0,05 ; écart non tranché sous A à 0,05.

Volet B, sous H0 de chaque plan, mêmes triangles et mêmes réplications (n01 : pente relative seule rejette ; n10 : pente absolue seule rejette) :

| Plan | seuil | pente relative | pente absolue | n01 / n10 | McNemar exact bilatéral |
|---|---|---|---|---|---|
| P1 | 0,10 | 0,118 | 0,122 | 56 / 60 | 0,78 |
| P1 | 0,05 | 0,059 | 0,067 | 27 / 35 | 0,37 |
| P2 | 0,10 | 0,112 | 0,116 | 50 / 54 | 0,77 |
| P2 | 0,05 | 0,059 | 0,056 | 30 / 27 | 0,79 |
| P3 | 0,10 | 0,137 | 0,129 | 39 / 31 | 0,40 |
| P3 | 0,05 | 0,075 [0,059 ; 0,093] | 0,066 | 27 / 18 | 0,23 |

Sous P3 à 0,05, la pente relative est en « écart non tranché du côté libéral ».

**Critère proposé, K-307.** Il est formulé le 22/10/2026, *après* publication des tableaux, et n'a donc aucune valeur de pré-enregistrement. C'est une règle de recevabilité explicite : un seul candidat, aucune sélection. La pente relative remplace la pente absolue si :
- **(i)** K-301 transposé : sous N et E, aux deux seuils, sa classe de #166 (volet A) est compatible, écart mineur ou distorsion conservatrice, et elle n'a aucune distorsion matérielle libérale sous A ;
- **(ii)** non-infériorité de niveau envers la statistique en place : sous H0 de P1, P2 et P3, aux deux seuils, le McNemar exact bilatéral apparié n'est pas significatif à 0,05.

**Évaluation : (i) tenu ; (ii) tenu** (p de 0,23 à 0,79).

**Limite** : (ii) est un critère de non-détection, pas d'équivalence. Avec 45 à 116 paires discordantes, un écart de niveau d'environ deux points n'est pas exclu.

**Verdict de pertinence** : *à compléter*.
- Ligne de test pertinente pour l'alternative « ordonnée proportionnelle au niveau ».
- Niveau légèrement libéral, comme la statistique en place, par simulation seulement : aucun théorème à T = 8.
- Puissance mesurée sous trois plans.

**Puissance [V]** (seuil 0,10, P1) :
- contre CST10, 0,434 contre 0,330 pour la pente absolue (McNemar p = 7e-7) ;
- contre CST20, 0,796 contre 0,522 (p = 1e-65) ;
- face au test par colonne (Origine), 0,434 et 0,796 contre 0,272 et 0,683 (p < 1e-8). Une part de cet avantage tient au niveau : 0,118 contre 0,096 sous H0 (p = 0,09).
- Sous P2, la pente relative fait moins bien qu'Origine : 0,944 et 0,967 contre 1,000.

### 4.3 Statut de la famille α (c) : recommandation (b′)

**Ce que teste la ligne [V].** Sous (iii), tout facteur individuel est sans biais pour f_j : Mack (1994), chap. 3, p. 111, relevé `verifications-fi.md` § 6.2. Les trois estimateurs α = 0, 1, 2 le sont donc **quelle que soit la variance**.
- Sous une violation de M2 seule, l'hypothèse nulle de la ligne est vraie. La lecture « test omnibus de M1 ∧ M2 » (option (b) de l'issue) et la phrase « soit que la pondération en C(i,j) est inadaptée (violation de M2) » de `mw:m1d` (Usage) sont inexactes.
- Mesuré : contre les exposants 0 et 2, la ligne rejette 0,116 et 0,081 sous P1, 0,146 [0,116 ; 0,180] et 0,091 sous P2, pour 0,102 et 0,095 sous H0. Le léger excès sous P2 à exposant 0 traduit la dépendance de la loi bootstrap à l'exposant 1 : c'est une distorsion de niveau, pas une puissance contre M2.

**Lien avec la pente [V, algèbre].** f^(α+1) − f^(α) = Cov_{w_α}(C, F) / E_{w_α}[C], avec w_α ∝ C^α. L'amplitude A agrège donc, colonne par colonne et sans compensation de signe, des covariances F–C non studentisées par σ_j : même famille d'alternatives que la pente, pondération différente.

**Redondance mesurée : faible [V, brut].**
- Sous H0 de P1, les deux lignes rejettent ensemble 0,019 des triangles au seuil 0,10 (0,102 et 0,118 séparément) ; corrélation de rang de leurs p : 0,13.
- Sous les alternatives, profils opposés, avec McNemar p < 0,003 partout :

| Scénario (P1, seuil 0,10) | famille α | pente relative |
|---|---|---|
| Dérive calendaire DCAL | 0,718 | 0,510 |
| Dérive de f_j DFI | 0,348 | 0,270 |
| Ordonnée CST20 | 0,466 | 0,796 |
| Cellule × 4 (CELx4) | 0,000 | 0,920 |
| Année atypique LIG | 0,074 | 0,526 |

- L'option (c), retrait parce que les deux lignes visent « la même alternative », n'est pas soutenue par la mesure.

**Matérialité.** Sur `reserve2`, A = 0,00111 et l'écart relatif maximal entre les trois estimateurs vaut 0,17 % (colonne 1) [V], pour une p_mc de 0,005 (ECHEC). Le rejet est statistiquement fondé : niveau compatible sous N, E et A d'après #206. Son enjeu matériel est faible.

**Recommandation (b′)** : la ligne reste un test de (iii) (M1), de verdict inchangé. Son `detail` dit ce qu'elle teste (pas M2) et restitue la matérialité observée (T-5).
- (a) diagnostic par décision : possible sans toucher `add()`, mais retire un test bien calibré et peu corrélé à la pente ; texte prêt (T-5a).
- (c) retrait : déconseillé. Il retirerait aussi la clé `Alpha` du catalogue (13 → 12 clés, décomptes « catalogue MW » à revoir).

### 4.4 Tableau prévisionnel (d) : § 7

### 4.5 Mack (1999) (e) : [NV], non recommandé

Notice fournie par le moteur de recherche seulement, non contrôlée sur Crossref : *ASTIN Bulletin* 29(2), 1999, p. 361-366, DOI 10.2143/AST.29.2.504622. Texte inaccessible (proxy 403 sur `casact.org`, `cambridge.org`, `ideas.repec.org`). Je n'ai donc pas pu vérifier qu'il traite de la famille α.

La famille est déjà fondée sur Mack (1994), chap. 5, p. 122-124, [V] dans le relevé : f_k0 pondéré par C², f_k2 moyenne simple. **Recommandation** : ne pas ajouter Mack (1999) à `mw:m1d` ; le consigner [NV] au relevé M38 (§ 9). Alternative : vérification par une session à accès complet, puis ajout.

## 5. Textes fixes (S-Fj-4), à la lettre

Chaînes du moteur en ASCII, sans accents. `%` littéral écrit `%%` dans `sprintf()`. Aucun nombre issu du bootstrap (#76).

**T-1 (#352, `reference` de M4)** — `sprintf()` avec `MW_NJ_MIN_CELLULE`, donnant sur `reserve2` :
> `Residu studentise externe de la regression ponderee C(.,j+1) ~ 0 + C(.,j), poids 1/C(.,j), et sa loi de Student a n_j - 2 degres de liberte sous erreurs gaussiennes : Cook & Weisberg (1982), par. 2.2.1, p. 20, et annexe A.1, p. 209 (nom RSTUDENT : Belsley, Kuh & Welsch 1980, chap. 2) ; borne de Bonferroni sur le plus grand residu : Cook & Weisberg (1982), p. 22 et 26 ; construction de l'outil : minimum des p de Student entre colonnes de degres de liberte differents, colonnes n_j >= 4, p-value Monte-Carlo sur le modele de Mack`

**T-2 (#352, avertissement)** — phrase insérée juste après « … fondees sur ces residus, soit %s. » et avant « Le pool de reechantillonnage … » :
> `La ligne M4 "Cellule aberrante du triangle (residus studentises externes)", calculee sur les residus studentises externes de chaque colonne et non sur ces residus, ecarte aussi ces colonnes. `

**T-3 (#308, ligne de diagnostic)**, champs :
- `test` : `Identifiabilite intra-colonne (dispersion des cumuls par colonne)` ;
- `fonction` : `mw_identifiabilite_intra` ; `type` : `diagnostic` ;
- `reference` : `Construction de l'outil : dispersion de C(i,j) a colonne donnee et erreur type de l'ordonnee a l'origine de la regression ponderee C(.,j+1) ~ a_j + b_j C(.,j), poids 1/C(.,j) (Mack 1994, CAS Forum, chap. 5, p. 121-123), sous H0, sigma_j de Mack (1993)` ;
- `estim_nom` : `CV moyen des colonnes retenues` ; pas de H0 ni de H1.
- `detail` = TETE, puis `" Valeurs : "`, puis les colonnes jointes par `" ; "`, puis `"."` ; sans colonne retenue : TETE puis `" Aucune colonne retenue (n_j >= 3)."`.
  - TETE :
  > `Diagnostic sans verdict (ADR 0001) : dispersion des cumuls a colonne donnee, dont depend la puissance des lignes M1 (ordonnee a l'origine, pente intra-colonne) et M2 (exposant de variance). Par colonne retenue (n_j >= 3, hors colonnes degenerees) : CV = ecart-type sur moyenne de C(i,j) ; R = max/min de C(i,j) (sous un exposant de variance k, a f_j et sigma_j connus, le rapport des variances des residus de Mack entre les deux cellules extremes vaut R^(k - 1)) ; e_a = erreur type de l'ordonnee a l'origine a_j sous H0, sigma_j de Mack, rapportee a la moyenne de C(i,j+1) (une ordonnee a l'origine de l'ordre de e_a est indiscernable de zero dans sa colonne).`
  - Une colonne : `sprintf("j = %d : n_j = %d, CV = %.4f, R = %.3f, e_a = %.4f", ...)`, ou, si e_a est NA, `sprintf("j = %d : n_j = %d, CV = %.4f, R = %.3f, e_a non definie (C(i,j) constant)", ...)`.
  - Fin attendue sur `reserve2` [V] :
  > `Valeurs : j = 0 : n_j = 7, CV = 0.0739, R = 1.229, e_a = 0.0800 ; j = 1 : n_j = 6, CV = 0.0763, R = 1.211, e_a = 0.0930 ; j = 2 : n_j = 5, CV = 0.0796, R = 1.206, e_a = 0.0973 ; j = 3 : n_j = 4, CV = 0.0751, R = 1.182, e_a = 0.0812 ; j = 4 : n_j = 3, CV = 0.0599, R = 1.126, e_a = 0.0685.`

**T-4 (#307, ligne M1 « Absence de tendance des facteurs avec le cumul, a colonne donnee »)** :
- nom, `stat_nom` (`t`) et H0 inchangés ; `mc_nom` `PenteIntra` ;
- `fonction` : `.mw_pente_relative` ;
- `reference` : `Mack (1993), ASTIN Bulletin 23(2), section 2, hyp. (1) ; section 3, hyp. (3) ; pente relative commune a effets fixes de colonne : construction de l'outil (partialisation de Frisch & Waugh 1933)` ;
- `H1` : `le facteur relatif F(i,j)/f_j varie avec le volume relatif C(i,j)/Cbar_j, selon une pente commune aux colonnes` ;
- `loi` : `Student(N - G - 1) approx. (pente relative, effets fixes de colonne) -> Monte-Carlo` ;
- `estim_nom` : `pente relative b` ; `estim` = b̂ ;
- `detail` :
> `Regression ponderee de F(i,j)/f_j sur (C(i,j) - Cbar_j)/Cbar_j (Cbar_j : moyenne simple des cumuls de la colonne j qui portent un facteur), poids C(i,j) f_j^2/sigma_j^2, avec effets fixes d'annee de developpement ; t de la pente commune b. En unites relatives, une ordonnee a l'origine a_j donne dans la colonne j une pente voisine de -a_j/(f_j Cbar_j), et chaque colonne pese selon la dispersion relative de ses cumuls et la precision de ses facteurs, non selon l'echelle de C(i,j). b se lit comme une elasticite du facteur au volume, a colonne donnee.`

  La phrase « Sans ce terme, la décroissance de f_j… » disparaît : en unités relatives, la moyenne pondérée de F/f̂_j vaut exactement 1 dans chaque colonne, et la relation mécanique de #119 n'existe plus sous cette forme. `add()` joindra la phrase de #244 sur `reserve2` (§ 7).

**T-5 (#307, famille α, option (b′))** :
- `reference` : `Mack (1994), CAS Forum (printemps), 101-182, chap. 3, p. 111, et chap. 5, p. 122-124` ;
- `H0` inchangée ;
- `H1` : `les trois estimateurs visent des valeurs differentes (esperance de C(i,j+1) non proportionnelle a C(i,j))` ;
- `detail` : `sprintf(..., 100 * max(al$detail$amplitude), al$detail$j[which.max(al$detail$amplitude)])`, avec repli sur la première phrase seule si la statistique est NA :
> `alpha = 0 : moyenne simple des facteurs ; alpha = 1 : chain-ladder du reglement ; alpha = 2 : ponderation par le carre du volume. Sous l'hypothese (iii), les trois estimateurs sont sans biais pour f_j quelle que soit la variance : la ligne porte sur la proportionnalite des cumules (M1), non sur l'exposant de variance (M2). f_j^(alpha+1) - f_j^(alpha) est la covariance entre F(i,j) et C(i,j), ponderee par C(i,j)^alpha, rapportee au cumul moyen de meme ponderation : la ligne vise, comme la pente intra-colonne, une association du facteur au volume, mais colonne par colonne et sans compensation de signe entre colonnes. Ecart relatif maximal entre les trois estimateurs : %.2f %% (colonne j = %d) ; seul f_j^(alpha = 1) entre dans sigma_USP.`

  Sur `reserve2` : « 0.17 % (colonne j = 1) ».

**T-5a (option (a), si elle est retenue)** : `type = "diagnostic"`, même `detail` précédé de :
> `Diagnostic sans verdict (ADR 0001), par decision du mainteneur (#307) : A mesure l'enjeu du choix de ponderation ; la p-value Monte-Carlo est restituee pour information. `

**Commentaires de code** (contenu, non à la lettre) :
- en tête de `.mw_pente_relative()` : « ALGÈBRE FIGÉE (#307, contrôle (i2′)) », sur le modèle de #301 et #300 ;
- en tête de `mw_identifiabilite_intra()` : les formules du § 3.3 et la forme stable de D_j.

## 6. Documentation (pour `docwriter`, fin de branche), contenu de fond

Le contenu ci-dessous est fixé ; la typographie suit `CONVENTIONS.md`. Seuils 0,10, puis 0,05 ; ρ = 0,098 et 0,048 ; constats de simulation sous un plan.

**`mw:m1`** (statistique, rubriques 3 à 7). Pente relative et définition du § 4.1, puis la rubrique 7 :
- niveau du volet A et de T1 bis (§ 4.2), avec la comparaison appariée à la pente absolue et K-307, selon Q-D1-Fj-6 ;
- puissance contre CST : P1 0,434 [0,390 ; 0,479] / 0,338 et 0,796 [0,770 ; 0,821] / 0,709 ; P2 0,944 et 0,967 ; P3 1,000 ;
- la remarque sur la nature de CST (§ 4.1) et « ordonnée concentrée sur une colonne : non mesurée » ;
- contre DFI : 0,270 / 0,270 / 0,108 (P1, P2, P3) ; P3 est au niveau (0,137) : la ligne ne voit cette dérive que par la colinéarité volume / année ;
- contre les exposants de variance : au niveau ;
- non-spécificité sous P1 : CELx4 0,920 ; LIG 0,526 ; CAL7 0,516 ; DCAL 0,510 ; CAL4 0,340 ; CEL6 0,200 ; CEL4 0,144 ;
- la rubrique Usage, réécrite : sous P1 la ligne rejette plus souvent que le test par colonne (en partie par son niveau), sous P2 moins souvent ;
- les niveaux de #206 cités pour l'ancienne statistique (0,114 ; 0,1205 ; 0,130) sont retirés de la rubrique 7 et gardés en historique.

**`mw:m1a`** (Origine), phrase à ajouter en rubrique 7 :
> Sous P1 (CV intra-colonne ≈ 0,06 à 0,07), la ligne rejette 0,683 des triangles contre une ordonnée de 20 % du cumul moyen suivant, et 1,000 sous P2 (CV ≈ 0,23 ; tableau T7 (c)). Un verdict OK de M1 n'est donc une preuve que si la dispersion intra-colonne est forte au regard de e_a (ligne « Identifiabilité intra-colonne ») ; un ECHEC reste atteignable dans les deux cas.

Ajouter aussi :
- les multiplicateurs 2,905 à 8,192 (§ 3.3) et e_a sur le triangle de contrôle (§ 3.3) ;
- le constat que les effets minimaux de l'issue, calculés avec l'erreur type observée, sont démentis par T7 (d) : colonne 1 annoncée à 16 %, mesurée à 0,343 de rejets contre 20 %.

**`mw:m1d`** (famille α) :
- Usage : remplacer « soit que la pondération en C(i,j) est inadaptée (violation de M2) […] doit donc être lu conjointement avec la fiche mw:m2b » par la lecture du § 4.3 : test de (iii) seul, d'après Mack 1994, p. 111 ; identité de covariance ; matérialité restituée.
- Rubrique 7 : exposants de variance (P1, P2) et lecture de l'excès sous P2 à exposant 0 ; profils contre la pente relative, selon Q-D1-Fj-6.

**`mw:m2bp` et `mw:m2b`** (phrase Q-D2-Fi-3 étendue), à ajouter après le constat existant :
> Sous P2 aussi (CV intra-colonne réalisé ≈ 0,23 ; R = 2,33 sur la première colonne), la famille M2 n'a pas de puissance mesurable contre les exposants 0 et 2 (FWr 0,124 et 0,112, ExpVar 0,080 et 0,091, pour des niveaux de 0,094 et 0,089) : à la différence de M1, une dispersion plus forte des cumuls ne rend pas, dans la plage mesurée, un verdict OK probant. Un ECHEC reste atteignable (plancher de la p-value de Monte-Carlo, non-spécificité).

  Ajouter le renvoi à R_j de la ligne de diagnostic et à la lecture R^(k−1).

**Nouvelle fiche** `mw:m1id` (diagnostic, six rubriques) : définitions et identités du § 3.3 ; valeurs sur le triangle de contrôle ; statut (CV et R exacts sur l'observé ; e_a = estimation de l'erreur type vraie sous le modèle de Mack, à σ_j estimé, conservatrice sous H1 parce que σ̂_j y est gonflé [H]).

**`mw:m4gr`** : T-1. **`sec:biblio`** : rien de nouveau si Q-D1-Fj-8 est suivie. **`tab:nature`**, **`tab:conv`**, index des fonctions, schéma « M1 (N entrées) » : § 3.5 et § 7.

## 7. Effets, tableaux avant / après prévisionnels, régénérations, ordre

σ_USP est inchangé dans toutes les étapes : 0,04977646 [V, référence ; lecture : `mw_parametre()` ne reçoit aucun test, et le flux de tirages ne dépend pas du catalogue (contrôle d'injection : `p_mc` de `PenteIntra` `identical()`)]. Aucun cas lognormal n'est touché.

| Étape | Effet sur `reserve2.rds` | Voie | Visa |
|---|---|---|---|
| #291 | aucun | `--seuil 0` | — |
| #356 | aucun | `--seuil 0` | — |
| #352 | ligne « Cellule aberrante » : `reference` (T-1) seule | patch chirurgical | `actuary` |
| #308 | ligne nouvelle (position 6, M1) : diagnostic, INFO, `estim` 0,07295, p NA ; 20 → 21 lignes ; INFO 7 → 8 | régénération `claude/regeneration-308` | `actuary` (aucun verdict) |
| #307 | voir ci-dessous | régénération `claude/regeneration-307` | **mainteneur** |

**#307, ligne « Absence de tendance… » [V]** :

| Champ | Avant | Après |
|---|---|---|
| stat | 0,26002 | 1,73295 |
| estim | NA | 0,05922 |
| p_as | 0,79751 | 0,09846 |
| p_mc | 0,778 | 0,090 |
| err_mc | 0,03085 | 0,01312 |
| verdict | **OK** | **ALERTE** |

- La phrase de #244 est ajoutée : |0,090 − 0,10| = 0,010 < 2 × 0,01312.
- `reference`, H1, `loi`, `estim_nom` et `detail` changent.
- Dans `bootstrap`, `stats_obs` et `p_mc` de `PenteIntra` changent ; les 12 autres clés sont inchangées [V, par injection].
- Famille α, option (b′) : stat 0,00111, p_mc 0,005, **ECHEC inchangé** ; `reference`, H1 et `detail` changent.

**Décomptes finaux sur `reserve2`** :

| Option α (avec F1) | Lignes | Tests | Diagnostics | OK | ALERTE | ECHEC | INFO |
|---|---|---|---|---|---|---|---|
| Départ (`510b03d`) | 20 | 13 | 7 | 7 | 2 | 4 | 7 |
| **(b′)** | 21 | 13 | 8 | 6 | 3 | 4 | 8 |
| (a) | 21 | 12 | 9 | 6 | 3 | 3 | 9 |
| (c) | 20 | 12 | 8 | 6 | 3 | 3 | 8 |

Avec F2 : une ligne, un diagnostic et un INFO de moins dans chaque cas. **Verdicts changés, soumis au visa** : PenteIntra OK → ALERTE ; avec (a) ou (c), la famille α ECHEC → INFO ou retrait.

**Ordre** :
1. #291 → #356 (circuit 3, identiques).
2. #352 (patch).
3. #308 (régénération).
4. #307 : code, puis (i2′) par `audit`, puis tableau avant / après, puis régénération, puis visa.
5. `docwriter`.

Une seule régénération à la fois. Avant chaque run `references.yml`, un audit léger recherche les désignations positionnelles des lignes de `reserve2`.

**Tests unitaires attendus** :
- #308 : oracle `cov.unscaled` ; colonne constante (e_a NA) ; colonne dégénérée exclue ; type, verdict, `fonction`, `estim` ; T-3 à la lettre sur `reserve2`.
- #307 :
  - t = 1,7330, b̂ = 0,0592 et p_as = 0,0985 sur `reserve2` ;
  - oracle `lm(y ~ factor(j) + x, weights = w)` à 1e-10 sur `reserve2` ;
  - triangles extrêmes de #253 : t fini et égal à la variante x = C/C̄_j à 1e-12 ;
  - statistique de la ligne = `stats_obs["PenteIntra"]` ;
  - T-4 et T-5 à la lettre ;
  - facultatif : `identical()` à `stat_pente_rel()` relue par `parse()` du script, garde unitaire de (i2′).
- #352 : § 2.3, et T-2 sur le triangle `td`.

## 8. Frontières (S-Fj-4)

- **Fm (#312, #311, #310, I-39-2)** : Fj ne touche ni les lignes M3, ni `res$plots_data`, ni l'affichage.
  - La lecture conjointe Durbin-Watson / calendaire (#312) est indépendante de Fj.
  - Un éventuel graphique des CV par colonne relèverait de Fm, pas de Fj.
  - La ligne de diagnostic s'affiche par le groupement existant (préfixe M1) ; `app-review` n'est pas déclenché.
- **Fk (#297)** :
  - les lignes de type test de M1 après Fj sont cinq en (b′) (quatre en (a) ou (c)) ; la ligne de diagnostic de #308 est hors du minP ;
  - le nom de la ligne de #308 ne doit pas entrer en collision avec la ligne « p ajustée de la famille » que propose #297 ;
  - donnée utile à Fk : faible dépendance sous H0 entre la pente relative et la famille α (§ 4.3).
- **R21 (#350, I-39-3)**, à transmettre :
  - dans `tests/calibration_mc_mw_t8.R`, `NL_MAX <- 19L` (l. 704) alors que `reserve2` a 20 lignes, et 21 après #308. `rep(NA_real_, NL_MAX - length(cR$pas))` (l. 1748) reçoit alors un `times` négatif. C'est très probablement la cause de « invalid 'times' argument » [H, lecture, non rejoué]. Le correctif de R21 ne doit pas figer 20.
  - #307 rend aussi faux, pour la clé `PenteIntra`, le contrôle (b) de ce script, comme #301 et #300 pour `BP` et `Grubbs`.

## 9. Relevé M38 (contenu proposé pour `docs/references/verifications-fj.md`)

- **Reprises de `verifications-fi.md`, sans relecture nouvelle** :
  - Mack (1993), p. 214 et 217 (§ 6.1) [V] ;
  - Mack (1994), p. 111 et 121-124 (§ 6.2) [V] ;
  - Cook et Weisberg (1982), p. 20, 21, 22, 26 et 209 (§ 2.1) [V] ;
  - Belsley, Kuh et Welsch (1980), chap. 2 (§ 2.2) [P] ;
  - Frisch et Waugh (1933) (§ 3.2) [V].
- **Mack (1999)** [NV] : texte inaccessible le 22/10/2026 (proxy 403). Notice issue du moteur de recherche seulement : *ASTIN Bulletin* 29(2), p. 361-366, DOI 10.2143/AST.29.2.504622, non contrôlée sur Crossref. Non citée.
- **Calculs sans référence externe** : quantiles de la Student décentrée (calcul numérique R) ; identités algébriques des § 3.3, 4.1 et 4.3, établies dans la spécification.

## Questions au mainteneur pour D1-Fj

- **Q-D1-Fj-1 — #308, forme.** *Recommandation* : F1, une ligne de diagnostic dans M1, après la famille α, texte T-3. *Alternative* : F2, compléments de `detail` sur Origine, FWr et ExpVar.
- **Q-D1-Fj-2 — #308, grandeurs.** *Recommandation* : CV_j, R_j et e_a,j (σ̂_j de Mack) ; pas d'effet minimal détectable dans le moteur ; multiplicateurs de la Student décentrée dans le `.tex`. *Alternatives* : effet minimal à σ̂_j de Mack restitué ; effet minimal de l'issue, à erreur type observée, **déconseillé** (démenti par T7 (d)).
- **Q-D1-Fj-3 — #307, recevabilité du niveau.** *Recommandation* : adopter K-307, (i) K-301 transposé et (ii) non-infériorité appariée, déclaré « formulé a posteriori » ; il est tenu, et la pente relative remplace la pente absolue. *Alternatives* : décision directe sur les tableaux, sans critère écrit ; ou refus (statu quo).
- **Q-D1-Fj-4 — #307, clé.** *Recommandation* : garder `PenteIntra` (précédent de #301 ; (i2′) selon la fiche ; moins de scripts touchés). *Alternative* : renommer en `PenteRel` (précédent de #300 avec MinP4).
- **Q-D1-Fj-5 — Famille α.** *Recommandation* : (b′), test de (iii) conservé, ECHEC inchangé sur `reserve2`, `detail` T-5. *Alternatives* : (a) diagnostic par décision (ECHEC → INFO, T-5a) ; (c) retrait, déconseillé (profils mesurés distincts ; clé `Alpha` retirée du catalogue).
- **Q-D1-Fj-6 — Pièce versionnée des comparaisons appariées** (McNemar pente relative / pente absolue / Origine / famille α ; rejets conjoints). Elles sont calculées sur le brut versionné, mais en session (même situation que Q-D2-Fi-4). *Recommandation* : un court tableau `docs/tableaux/AAAAMMJJ-issue307-paires.md` (code R inclus, md5 du brut cité), dans un commit `docs:` préparatoire, avant le code de #307, pour que K-307 (ii) et la rubrique 7 citent une pièce versionnée. *Alternative* : ne citer dans le `.tex` que T1, T1 bis et T2 ; K-307 (ii) reste alors au dossier de spécification.
- **Q-D1-Fj-7 — `.mw_lm_intra()` et les tests T253 de la pente.** *Recommandation* : retirer `.mw_lm_intra()` et `.mw_pente_intra()` (code mort après #307) ; remplacer les assertions de pente de `test_forme_close_m1.R` par les oracles du § 7 ; mettre à jour la partie pente de `generer_valeurs_forme_close_m1.R` (hors CI, Rmpfr) sur un poste qui dispose de Rmpfr, ou la retirer. *Alternative* : garder `.mw_lm_intra()` sans appelant, déconseillé.
- **Q-D1-Fj-8 — Mack (1999).** *Recommandation* : ne pas l'ajouter ([NV] ; Mack 1994, p. 122-124, [V], fonde déjà la famille α). *Alternative* : vérification par une session à accès complet, puis ajout.
- **Q-D1-Fj-9 — #352.** *Recommandation* : textes T-1 et T-2 tels quels ; ε = 1e-10 et 1e-6 sur la construction du § 2.3.
- **Q-D1-Fj-10 — Visa de #307.** Le verdict de la pente intra-colonne passe d'OK à ALERTE sur `reserve2` (p_mc 0,778 → 0,090), et la famille α suit l'option retenue. σ_USP est inchangé. Visa au tableau avant / après.

Recommandation annexe, sans question : `architect` consigne dans `CONTEXT.md` les termes « Pente relative (M1) » et « Identifiabilité intra-colonne » (étape 7 de la fiche).

