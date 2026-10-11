> *Rédigé par l'agent actuary (IA), 11/10/2026, branche `claude/p-mc-conditionnelle-regime` (PR #249, tête `2dd7322`). Spécification de l'issue #240, étape 1 de la fiche « Branche A4 ». Elle est soumise au point d'arrêt **C1** : aucun code avant l'approbation du mainteneur. Les décisions de C1 sont ajoutées en annotation datée, en fin de document.*

**Marques** : **[V]** vérifié (source citée, ou commande exécutée et sortie lue) ; **[H]** hypothèse ; **[NV]** non vérifié.

# Spécification de #240 : p-value Monte-Carlo lognormale conditionnelle au régime de δ̂ intérieur (V3h)

## 0. Objet, sources, statut statistique

**Objet.** Implémenter dans `usp_bootstrap()` la variante hybride **V3h**, décidée par l'ADR 0014 et mesurée par #229 :
- quand δ̂ observé est **intérieur**, la p-value Monte-Carlo de chacune des 34 statistiques d'`USP_CATALOGUE_MC` est celle de **V3b**. Elle est calculée sur les seuls tirages dont δ̂** est intérieur. Ces tirages sont pris dans les B tirages de V1, puis complétés sur un flux distinct ;
- quand δ̂ est **au bord**, c'est la p de **V1**, inchangée au bit près.

**Sources lues.**
- Issue #240 et décisions du mainteneur du 11/10/2026 (PR #249, commentaire `6107731201`) **[V]**.
- ADR 0014 et ADR 0003 (avec ses annotations des 24/09, 27/09, 02/10, 06/10 et 07/10) **[V]**.
- Fiche « Branche A4 » et § 5 de `docs/feuille-de-route.md` (Q-A4-4 à Q-A4-16, C-A4-1 à C-A4-6) **[V]**.
- `CONTEXT.md` : entrées « P-value Monte-Carlo », « Erreur de Monte-Carlo », « Granularité », « Calibration des p-values Monte-Carlo », « P-value retenue », « Statistique Monte-Carlo », « Graine locale » **[V]**.
- `docs/exigences.md`, § 2 et § 4.5 **[V]**.
- `docs/specifications/229-p-conditionnelle-regime.md`, § 5 **[V]**.
- Dans `R/engine.R`, à la tête `2dd7322` **[V]** :
  - `TOL_DELTA_BORD` (l. 164), `B_MIN_USAGE` (l. 216-227) ;
  - `usp_regime()` (l. 1831-1842), `engine_sous_graine()` (l. 1995-2013) ;
  - `.mc_evaluer()` et `.stats_bootstrapables()` (l. 3404-3418) ;
  - motifs et `B_MIN_DEGENERESCENCE` (l. 3489-3497), `engine_p_mc()` (l. 3511-3537), `.mc_p_values()` (l. 3554-3584) ;
  - `engine_registre_tests()` / `add()` (l. 3651-3894), `usp_bootstrap()` (l. 3896-3961), `usp_ajuster_rapide()` (l. 3976-3992) ;
  - la nature passée par `usp_tests()` (l. 4228-4229) ;
  - `.engine_verifier_usage()` (l. 8701-8714) ;
  - dans `run_engine()`, l'appel du bootstrap (l. 9290) et `metadata` (l. 9401-9453).
- `tests/p_conditionnelle_regime_t8.R` **[V]** : en-tête l. 56-73 ; constantes l. 581-589 ; `rejouer_v1()` l. 1776-1804 ; `completer_v3b()` l. 1809-1832 ; `traiter()` l. 1853-1869.
- Tableaux et valeurs brutes de #229 : `docs/tableaux/20261010-issue229-p-conditionnelle-regime.md` (T0, T3, jeux observés) et `-brut.tsv` **[V]**.
- Modèle de forme : `docs/specifications/206-calibration-mc-merz-wuthrich.md` **[V]**.
- `tests/concordance_doc_moteur.R` l. 822-834 et `R/display_helpers.R` l. 150 (le suffixe de la nature casse-t-il des lecteurs ?) **[V]**.

**Chemin lognormal inchangé depuis le commit mesuré par #229.** `git diff fee9968 HEAD -- R/engine.R` ne touche la région lognormale que dans un commentaire (l. 2415, `7dcbd01`, BP79). Tous les autres hunks portent sur Merz-Wüthrich (#239, #119) **[V]**. Les valeurs brutes de #229 servent donc d'oracle pour les tests du § 7.

**Ce que la variante teste, et ce qu'elle vaut à T = 8.**
- **Hypothèse visée.** Elle est inchangée pour chaque ligne : celle de sa fiche (H1 à H4 de l'annexe XVII, B(2)(g) ou C(2)(e)), sur la base de résidus de la ligne. Seule change la **loi de référence** de la statistique. C'était sa loi sous le modèle ajusté, régimes de δ̂** mêlés (marginale). C'est désormais sa loi sous le modèle ajusté **sachant δ̂** intérieur** (conditionnelle), quand δ̂ observé est intérieur.
- **Nature de la p-value.** C'est une p-value **Monte-Carlo** de bootstrap paramétrique à paramètres estimés (plug-in θ̂). Elle n'est **pas exacte** : les résultats de Dwass (1957) et de Hope (1968) supposent une loi nulle simulable exactement, ce qui n'est pas le cas ici (ADR 0002 ; `.tex`, `sec:biblio`). L'arrêt adaptatif n'introduit pas de biais par rapport à un test de Monte-Carlo à B effectif fixé : conditionnellement à B_eff, les statistiques retenues sont i.i.d. sous la loi conditionnelle. C'est un argument élémentaire, sans référence (spécification 229, § 5) **[V]** pour la logique.
- **Deux erreurs à ne pas confondre.**
  - L'**erreur Monte-Carlo** dépend de B_eff, nombre de tirages retenus : `err_mc` = √(p(k − p)/B_eff), avec k = 1 ou 2 selon le sens (ADR 0014, « Statut de V3h »).
  - L'**erreur d'approximation** dépend de T et du plug-in. Aucune théorie ne la borne à T = 8 : aucun théorème de validité du bootstrap conditionnel au régime d'un estimateur au bord n'est connu ni invoqué. Le régime n'est pas ancillaire (ADR 0014). Cox (1958) et Buehler (1959), cités par `sec:biblio`, fondent seulement le **principe** du conditionnement. Pour Buehler, la référence bibliographique (Ann. Math. Statist. 30(4), 845-863) est vérifiée, mais le contenu n'a pas été relu **[NV]**.
  - Que V3h soit calibrée conditionnellement à T = 8 est un **constat de simulation** sur J1, J2 et J3 (#229), non un résultat.
- **Puissance plausible.** Les données sont celles de #229, partie P (ADR 0014, constats de simulation) :
  - à l'intérieur, V1 ne rejette presque jamais sur F_8 (J2 : BP 0 sur 464) ; V3h y rétablit le niveau ;
  - gains intérieurs significatifs dans 5 scénarios sur 6, par exemple Grubbs de 0,194 à 0,537 sous contamination λ = 4 ;
  - aucune perte significative (C4a remplie).
- **Statut.** La décision est prise (ADR 0014). Cette spécification ne la rouvre pas. Elle fixe la mise en œuvre telle que mesurée et ses garde-fous.

## 1. Décisions appliquées (mainteneur, 11/10/2026)

| Question | Décision | Où elle s'applique ici |
|---|---|---|
| Q-A4-5 | #240 seule ; #181, #125 et #244 en E2b | § 11 |
| Q-A4-6 (A) | les champs existants de `bootstrap` portent V3h ; sélection dans `usp_bootstrap()` seule ; `.mc_p_values()`, `engine_p_mc()` et `p_min` inchangées ; champs de V1 inchangés ; sous-liste `p_mc_regime` en fin de liste ; graine dans `metadata` | § 2, § 3 |
| Q-A4-7 (A) | graine du flux = `seed` + 539 169 (20 800 000 par défaut), avec repli aux bornes, jamais `seed` | § 5 |
| Q-A4-8 (A) | B_cible = B ; B_max = 25 (B + 1) | § 2.4 |
| Q-A4-9 (A) | motif nouveau, non dégénéré, règle actuelle | § 4.1 |
| Q-A4-10 (B) | `nature_p` suffixée ; texte exact par `actuary` | § 4.2 |
| Q-A4-11 | sixième cas `premium_interieur` (J2), créé par la CI | § 8 |
| Q-A4-12 (B) | ligne d'en-tête du rapport figé et du résumé de l'application, `app-review` | § 3.4 (contrat lu), étape 4 |

## 2. Algorithme

### 2.1 Critère « intérieur » (seule définition)

- **δ̂ observé** : `reg <- usp_regime(fit$delta, fit$x)` ; intérieur si et seulement si `!reg$delta_au_bord`, soit `TOL_DELTA_BORD < δ̂ < 1 − TOL_DELTA_BORD`.
- **δ̂\*\*** d'un tirage : intérieur si et seulement si `is.finite(f$delta) && !usp_regime(f$delta, fit$x)$delta_au_bord`.
- **Aucune autre expression du seuil** dans le code. `TOL_DELTA_BORD` n'a qu'une source : `usp_ajuster()` et `usp_regime()` (commentaire l. 162-163) **[V]**.
- Ce critère est celui de `code_regime()` du script de #229 (l. 502-503) : bord 1 si δ ≥ 1 − tol, bord 0 si δ ≤ tol, intérieur sinon **[V]**.
- **Code du régime observé** (champ `regime_obs`) : `"interieur"` si `!reg$delta_au_bord`. Sinon `"bord1"` si `fit$delta >= 0.5`, `"bord0"` sinon. Le seuil 0,5 ne fait que séparer deux bords déjà établis par `usp_regime()` ; il ne réécrit pas la tolérance.

### 2.2 Choix de la variante

`v3b <- !reg$delta_au_bord && !reg$volumes_constants && isTRUE(refit)`.

- Si `v3b` est faux, la variante est **V1**. Le calcul est exactement celui d'aujourd'hui : `.mc_p_values(sim, stats_obs, USP_CATALOGUE_MC, e_obs)` sur la matrice complète des B tirages. Aucun flux n'est posé.
- `motif_v1` prend, dans cet ordre de priorité :
  1. `"delta estime au bord"` si `reg$delta_au_bord` ;
  2. sinon `"volumes constants : regime de delta non identifie"` si `reg$volumes_constants` ;
  3. sinon `"refit = FALSE : delta** non reestime"`.
- Motifs (Q-240-1, recommandation) :
  - à volumes constants, π_t ne dépend pas de δ. Le régime de δ̂ y est un artefact de l'optimiseur, et conditionner dessus n'a pas d'objet statistique ;
  - sous `refit = FALSE` (appel direct seulement ; `run_engine()` réajuste toujours, l. 9290 **[V]**), δ̂** n'existe pas.

### 2.3 Tirages de V1 : inchangés

- La boucle des B tirages sous `engine_sous_graine(seed, …)` est **inchangée**, ainsi que ses appels, leur ordre et la consommation d'aléa :
  - `usp_simuler()`, `usp_ajuster_rapide()` ;
  - `.stats_bootstrapables()` ;
  - `usp_ajuster_contraint()` (bootstrap restreint de #45).
- Seul ajout : un indicateur `retenu_v1[b] <- TRUE`, posé à l'endroit exact où `sim[b, ] <- sb[noms]`, c'est-à-dire réajustement abouti et statistiques sans erreur.
- Sous `v3b`, les tirages de V1 retenus dans le régime sont `int_v1 <- retenu_v1 & is.finite(del) & <δ̂** intérieur>`.

### 2.4 Complément sur le flux distinct (V3b)

Sous `v3b` seulement, **après** la sortie du bloc `engine_sous_graine(seed, …)` de V1, sans imbrication :

```r
B_cible <- as.numeric(B)
B_max   <- FACTEUR_B_MAX_REGIME * (as.numeric(B) + 1)   # 25 (B + 1)
S <- matrix(NA_real_, B_cible, length(noms), dimnames = list(NULL, noms))
a <- sum(int_v1); if (a > 0) S[seq_len(a), ] <- sim[int_v1, , drop = FALSE]   # ordre croissant de b
n <- a; tir <- as.numeric(B)
rej <- c(reajustement = 0, hors_regime = 0, statistiques = 0)
if (n < B_cible) engine_sous_graine(graine_flux, {
  while (n < B_cible && tir < B_max) {
    tir <- tir + 1
    yb <- usp_simuler(fit)
    f  <- try(usp_ajuster_rapide(fit$x, yb, fit$delta, fit$gamma), silent = TRUE)
    if (inherits(f, "try-error") || !is.finite(f$delta)) { rej[["reajustement"]] <- rej[["reajustement"]] + 1; next }
    if (usp_regime(f$delta, fit$x)$delta_au_bord)        { rej[["hors_regime"]]  <- rej[["hors_regime"]]  + 1; next }   # P1 : aucune statistique
    sb <- try(.stats_bootstrapables(fit$x, yb, f$z, f$pi), silent = TRUE)
    if (inherits(sb, "try-error"))                        { rej[["statistiques"]] <- rej[["statistiques"]] + 1; next }
    n <- n + 1; S[n, ] <- sb[noms]
  }
})
mc <- .mc_p_values(S[seq_len(n), , drop = FALSE], stats_obs, USP_CATALOGUE_MC, e_obs)
arret <- if (n == B_cible) "cible" else "B_max"
```

**Règles impératives :**
- **Ordre des lignes retenues.** D'abord les tirages de V1 retenus dans le régime, par b croissant, puis les tirages du flux dans leur ordre de tirage. La p ne dépend pas de l'ordre, mais l'ordre est fixé pour l'identité avec `completer_v3b()` (l. 1813, 1826-1827) **[V]**.
- **Comptage.** `tirages` compte tous les appels de `usp_simuler()` : les B de V1, échecs compris, puis ceux du flux. Arrêt dès que `n = B_cible`, ou dès que `tirages = B_max` (999 de V1 compris à B = 999). C'est la boucle de `completer_v3b()`, compteur initialisé à B (l. 1814-1817) **[V]**.
- **Levier P1.** Un tirage du flux dont le réajustement échoue, ou dont δ̂** n'est pas intérieur, ne donne lieu à **aucun** appel de `.stats_bootstrapables()`.
- **Le flux ne calcule que les statistiques du catalogue.** Il ne fait ni `usp_ajuster_contraint()`, ni σ*, ni z*. `sigma_boot`, `delta_boot`, `gamma_boot`, `z_boot`, `sigma_boot_restreint` et `n_echec_restreint` restent ceux des B tirages de V1.
- **Pas de flux inutile.** Si `a = B_cible` (tous les tirages de V1 retenus et intérieurs), le flux n'est pas posé et `arret = "cible"`.
- La garde `!is.finite(f$delta)` est absente du script de #229 ; elle n'y a jamais servi. Elle ne change aucune identité.
- `progres` : le flux n'imprime rien.

### 2.5 Calcul des p

- `.mc_p_values()` et `engine_p_mc()` sont appelées **telles quelles** sur la matrice retenue (sous V3b) ou complète (sous V1). Le calcul de la p, de `err_mc`, de `B_effectif`, de `granularite_stat` et du motif ne change pas.
- Le seul post-traitement est celui du § 4.1, fait dans `usp_bootstrap()`.

## 3. Contrat des champs

### 3.1 Champs existants de `bootstrap` : forme, ordre et noms inchangés

| Champ | Type | δ̂ intérieur, V3b | V1 (bord, volumes constants, `refit = FALSE`) |
|---|---|---|---|
| `stats_obs` | liste nommée (34) | inchangé | inchangé |
| `p_mc` | double nommé (34) | p sur les `retenus` tirages | **identique au calcul actuel** |
| `err_mc` | double nommé | √(p(k − p)/B_eff), k lu au catalogue | identique |
| `B_effectif` | double nommé | statistiques finies parmi les retenus (≤ `retenus` ≤ B) | identique |
| `granularite` | double | 1/(B + 1), nominale, **inchangée** | identique |
| `sigma_boot`, `delta_boot`, `gamma_boot`, `B` | — | V1, inchangés | identiques |
| `granularite_stat` | double nommé | k/(B_eff + 1) | identique |
| `motif_mc` | character nommé | motifs de `.mc_p_values()`, sauf la substitution du § 4.1 | identique |
| `sigma_boot_restreint`, `n_echec_restreint`, `z_boot` | — | V1, inchangés | identiques |

`p_min` (champ de ligne, ADR 0003, annotation du 27/09) n'est pas touché.

### 3.2 Champ nouveau `bootstrap$p_mc_regime`, après `z_boot`, onze éléments dans cet ordre

| # | Élément | Type | V3b | V1 |
|---|---|---|---|---|
| 1 | `regime_obs` | character(1) | `"interieur"` | `"bord0"`, `"interieur"` ou `"bord1"` (§ 2.1) |
| 2 | `variante` | character(1) | `"V3b"` | `"V1"` |
| 3 | `motif_v1` | character(1) | `NA_character_` | un des trois textes du § 2.2 |
| 4 | `graine_flux` | double | `usp_graine_flux_regime(seed)` | idem, **toujours renseignée** (Q-240-5) |
| 5 | `B_cible` | double | B | `NA_real_` |
| 6 | `B_max` | double | 25 (B + 1) | `NA_real_` |
| 7 | `tirages` | double | B + tirages du flux | B |
| 8 | `retenus_v1` | double | `sum(int_v1)` | `NA_real_` |
| 9 | `retenus` | double | n | `NA_real_` |
| 10 | `rejets_flux` | double nommé (3) : `reajustement`, `hors_regime`, `statistiques` | comptes du flux | trois `NA_real_` |
| 11 | `arret` | character(1) | `"cible"` ou `"B_max"` | `NA_character_` |

**Invariants sous V3b** (vérifiés par les tests, § 7) :
- (I1) `tirages − B = sum(rejets_flux) + retenus − retenus_v1` ;
- (I2) `retenus ≤ B_cible` et `tirages ≤ B_max` ;
- (I3) `arret == "cible"` ⇔ `retenus == B_cible` ;
- (I4) `arret == "B_max"` ⇒ `tirages == B_max` ;
- (I5) `B_effectif[s] ≤ retenus` pour toute statistique s ;
- (I6) `retenus_v1` = nombre d'éléments intérieurs de `delta_boot` (même critère `usp_regime()`) ;
- (I7) `retenus_v1 == B_cible` ⇒ `tirages == B` (flux non posé).

Cette forme étend celle proposée par la fiche A4 (point 4) de trois éléments, `motif_v1`, `retenus_v1` et `rejets_flux`. Ils sont nécessaires aux invariants I1 et I6 et à la lecture des cas V1 hors du bord. `architect` les reporte à l'étape 2.

### 3.3 `res$metadata`

- `seed_flux_regime` (double) = `bootstrap$p_mc_regime$graine_flux`, pour `premium` et `reserve1`.
- Placé **après `permutation_pente`** et avant les champs d'exécution (`horodatage`, `duree_sec`, `version_R`).
- Absent pour `reserve2` : `.run_engine_mw()` n'est pas touché.

### 3.4 Lecteurs

- `add()` lit `p_mc`, `err_mc`, `motif_mc` et `granularite_stat`. `usp_tests()` lit `p_mc`, `motif_mc` et `stats_obs`. Aucun des deux ne change de lecture (fiche A4, point 1) **[V]**.
- `engine_plots_data()` et l'IC bootstrap lisent `sigma_boot`, `delta_boot` et `z_boot` (l. 6445, 9192, 9299) **[V]**, inchangés.
- L'en-tête de l'étape 4 (Q-A4-12) lit `p_mc_regime` seul, sans calcul.
- Libellés suggérés, à trancher par `app-review` :
  - « P-values Monte-Carlo : conditionnelles au régime intérieur de δ̂ — N tirages, M retenus, arrêt à la cible | à B_max » ;
  - « P-values Monte-Carlo : marginales (δ̂ au bord | volumes constants) ».

## 4. Motif et nature

### 4.1 Motif « régime intérieur rare » (Q-A4-9 (A))

Nouvelle constante, placée après `MOTIF_MC_ATOME_HORS_OBS`. Texte exact, ASCII, sans aucun nombre issu du bootstrap (règle #76) :

```r
MOTIF_MC_REGIME_RARE <- sprintf(paste(
  "regime interieur de delta estime rare : B_max = %d (B + 1) tirages atteints",
  "avec moins de B_MIN_DEGENERESCENCE = %d tirages retenus"),
  FACTEUR_B_MAX_REGIME, B_MIN_DEGENERESCENCE)
```

**Règle de substitution.** Elle est appliquée dans `usp_bootstrap()`, après `.mc_p_values()`, sous V3b seulement :
- **condition** : `arret == "B_max"` et `retenus < B_MIN_DEGENERESCENCE` ;
- **effet** : pour chaque statistique dont `motif_mc` vaut `MOTIF_MC_REPLIC_INSUFFISANTES` ou `MOTIF_MC_AUCUNE_REPLIC`, ce motif est remplacé par `MOTIF_MC_REGIME_RARE`. `p_mc`, `err_mc`, `B_effectif` et `granularite_stat` restent tels que rendus.
- **Motifs non remplacés.** `MOTIF_MC_OBS_NON_FINIE`, le motif de `non_definie` et `MOTIF_MC_CONDITION` gardent la priorité : ils portent sur les données observées, non sur le nombre de tirages.
- **B_max atteint avec `retenus ≥ 50`.** Aucune substitution : la p est calculée sur B_eff < B. Une statistique finie dans moins de 50 tirages garde le motif générique, sa cause étant la non-finitude et non le régime.
- **`arret = "cible"` avec `retenus < 50`.** Possible seulement en appel direct avec B < 50. Motif générique.

**Classement.** Le motif n'entre pas dans `motifs_degeneres` d'`add()` (l. 3654-3655) **[V]**. La dernière branche de R3 s'applique donc **sans modifier `add()`** (l. 3712-3723) **[V]** :
- sans p exacte, avec p asymptotique : repli nommé `"asymptotique (Monte-Carlo indisponible : <motif>)"` ;
- sous `repli_asymptotique = FALSE` : diagnostic ;
- sans aucune p : test sans p-value retenue ;
- une p exacte finie reste retenue.

L'ADR 0003 est annoté par `architect` (étape 2). La politique de repli reste à #181 (C-A4-1).

### 4.2 `nature_p` à δ̂ intérieur (Q-A4-10 (B)) — texte exact

```
Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime)
```

- **Mise en œuvre.** `usp_tests()` passe à `engine_registre_tests()` ce libellé quand `identical(boot$p_mc_regime$variante, "V3b")`. Sinon, il passe le libellé actuel `"Monte-Carlo (bootstrap parametrique)"`, y compris pour une liste `boot` sans `p_mc_regime` (scripts hors CI, rétrocompatibilité).
- **Constante.** Une constante nommée pour le nouveau libellé est admise. Le littéral actuel n'est pas refactoré dans ce commit.
- **Portée.** Le libellé ne touche que les lignes dont la p retenue vient de `bootstrap$p_mc` (`mc_nom`). Les lignes à `p_mc_ext` gardent leur nature : la pente porte `nature_forcee`, et les lignes du rapport de vraisemblance sur δ sont diagnostiques, de nature `NA` (l. 4600-4622, 5600) **[V]**.
- **« estimé ».** Le conditionnement porte sur le régime de l'**estimateur** (δ̂**, comme δ̂), non sur δ. Le texte de la décision, « conditionnel au régime intérieur de δ », est donc précisé par « estimé » (Q-240-2).
- **Effet sur les lecteurs.** Le préfixe « Monte-Carlo » est conservé. Le badge (`grepl("^Monte-Carlo")`, `display_helpers.R:150`) et les décomptes de concordance (`grepl("^Monte-Carlo", nat)`, `concordance_doc_moteur.R:834`) ne changent pas **[V]**. Le rang dans la hiérarchie est inchangé.
- **Rendu dans le `.tex`** : « Monte-Carlo (bootstrap paramétrique, conditionnel au régime intérieur de δ̂) ».

## 5. Graine du flux (Q-A4-7 (A))

**Constantes** : `DECALAGE_GRAINE_FLUX_REGIME <- 539169` et `FACTEUR_B_MAX_REGIME <- 25`.

**Fonction nommée** `usp_graine_flux_regime(seed)`. Elle est appelée par `usp_bootstrap()` et par les tests.
- Elle refuse, par `stop()`, une graine non scalaire, non finie, non entière, ou telle que |seed| > `.Machine$integer.max` (même domaine que `.engine_verifier_usage()`, l. 8711) **[V]**.
- Sinon, avec M = `.Machine$integer.max` et D = 539 169 :
  - g = seed + D si seed + D ≤ M ;
  - sinon g = seed + D − (2M + 1).
- Le résultat est rendu en double.

**Propriétés** (arithmétique ; à vérifier par les tests U1) :
- g ∈ [−M, M] pour tout seed admis. Pour seed ∈ [M − D + 1, M], g ∈ [−M, −M + D − 1] ; la valeur −2^31, qui n'est pas un entier R valide, n'est jamais atteinte.
- g ≠ seed toujours (D ≢ 0 modulo 2M + 1). L'application est bijective.
- À la graine par défaut, 20 260 831 + 539 169 = **20 800 000** : c'est la graine de V3b du jeu observé dans #229. Pour seed = 20 260 831 + b, g = 20 800 000 + b, la graine de la réplication b de #229 (l. 584, 1861) **[V]**. L'identité avec #229 vient donc par construction.
- Que `set.seed()` refuse une valeur hors de [−M, M] est le comportement connu de R **[NV dans cette consultation]**. U1 le vérifie sur les deux bornes.

**Interdit.** Poser le flux sous `seed`. Il rejouerait les premiers y* de V1, compterait deux fois des tirages identiques et rendrait les statistiques retenues dépendantes.

**Non-recouvrement des flux.** Deux graines distinctes de Mersenne-Twister donnent des états initiaux distincts. Que les deux suites ne se recouvrent pas sur 25 (B + 1) tirages est **supposé** **[H]**. La même convention vaut pour toutes les graines du moteur, et #229 l'a employée.

**Collisions déclarées** (Q-240-6) :
- seed = 19 721 732 donne g = `SEED_LOI_NULLE_SW` (20 260 901) ;
- dans une étude de sensibilité, deux graines espacées de 539 169 rendent le flux de l'une égal aux tirages de V1 de l'autre.

## 6. Modules

**Touchés**
- `R/engine.R` :
  - constantes `DECALAGE_GRAINE_FLUX_REGIME`, `FACTEUR_B_MAX_REGIME` et `MOTIF_MC_REGIME_RARE` ; constante de nature si `coder` en crée une ;
  - `usp_graine_flux_regime()` ;
  - `usp_bootstrap()` : § 2, § 3.1, § 3.2, § 4.1. Un assistant nommé pour la boucle du flux est admis, son nom étant porté en surface documentaire ;
  - `usp_tests()` : la seule nature passée (§ 4.2) ;
  - `run_engine()` : `metadata`, § 3.3.
- `tests/outils_tests.R` : cas `premium_interieur`, soit `run_engine(xt, yt, methode = "premium", segment = 1, annexe = "II", nature_donnees = "brutes")` sur `tests/donnees/donnees_ln_interieur.csv`. Les colonnes sont celles de `donnees_ln.csv` ; les valeurs sont `xi`, `yi` de `tests/unitaires/test_controles_numeriques.R:38-39` **[V]**, et ce fichier de test n'est pas modifié (U14 garde l'égalité). C'est la configuration de #229 (T0 : méthode premium, segment 1 de l'annexe II, données brutes) **[V]**.
- `tests/unitaires/test_p_mc_regime.R` (nouveau).

**Hors module.** `.mc_p_values()`, `engine_p_mc()`, `USP_CATALOGUE_MC`, `.mc_entree()`, `add()` / `engine_registre_tests()`, `usp_parametre()`, `usp_lr_delta()`, `usp_permutation_pente()`, `engine_table_tests()`, toute fonction `mw_*`.

## 7. Tests unitaires (`tests/unitaires/test_p_mc_regime.R`)

Données des réplications de #229 :
- `y*_b` recopiés en dur au format `%.17g`, extraits une fois par le générateur de #229, `engine_sous_graine(20260927, t(vapply(seq_len(R), function(b) usp_simuler(FIT0), numeric(8))))`, ligne b (`p_conditionnelle_regime_t8.R:2004-2006`) **[V]** ;
- la commande d'extraction est citée en commentaire ;
- **garde** : `usp_ajuster(x, y_b)$delta` égale la colonne `delta` du TSV à 1e-9 près en relatif.

Oracle : `docs/tableaux/20261010-issue229-p-conditionnelle-regime-brut.tsv`, valeurs `%.17g`, motif « - » = `NA`. Les tests lisent le TSV, ou recopient les 34 valeurs par cas.

| Id | Objet | Jeu, B | Attendu |
|---|---|---|---|
| U1 | graine | `usp_graine_flux_regime()` sur 20260831, 0, −1, −M, M − D, M − D + 1, M ; refus de 2^31, 1,5, `NA`, `Inf` | 20800000 ; D ; D − 1 ; −M + D ; M ; −M ; D − M − 1 = −2 146 944 479. Pour chaque valeur : g ≠ seed, \|g\| ≤ M, entier, `engine_sous_graine(g, stats::runif(1))` sans erreur. Puis `usp_bootstrap()` sur J2 observé à seed = M et B = 99, sans erreur |
| U2 | identité avec V3b de #229, intérieur, arrêt cible | J2 b = 0 (observé, seed 20260831), J2 b = 6, J3 b = 3 (x = `X3`) ; B = 999, seed = 20260831 + b | `p_mc`, `B_effectif` et `motif_mc` `identical()` à `p_V3b:*`, `B_V3b:*` et `m_V3b:*`. `err_mc` et `granularite_stat` égaux à leur formule sur ces valeurs. `p_mc_regime` : `tirages` = `tir_v3b` (4490 ; 4348 ; 2091), `retenus_v1` = `a_v1` (203 ; 233 ; 480), `retenus` = 999, `rejets_flux` = (`ech_rapide_v3b`, `hors_v3b`, `ech_stats_v3b`) soit (0, 2695, 0), (0, 2583, 0), (0, 573, 0), `arret` = `"cible"`, `graine_flux` = 20800000 + b. Sur b = 0, `p_mc["GQ"]` = 0,017999999999999999. Invariants I1 à I7 |
| U3 | identité, B_max atteint, retenus ≥ 50 | J1 b = 1455 (δ̂ = 0,2344, intérieur), B = 999 | comme U2 : `tirages` = 25000, `retenus_v1` = 34, `retenus` = 930, `rejets_flux` = (0, 23105, 0), `arret` = `"B_max"` ; p calculées, motifs `NA` |
| U4 | identité avec V1 au bord | J2 b = 4 (bord 0), J3 b = 1 (bord 1), B = 999 ; J1 observé (`donnees_ln`), B = 99 | `p_mc`, `B_effectif` et `motif_mc` `identical()` à `p_V1:*`, `B_V1:*` et `m_V1:*`. `p_mc_regime` au contrat V1 (§ 3.2). `usp_ajuster_rapide()` appelée exactement B fois (enveloppe de comptage) |
| U5 | B_max atteint, retenus < 50 : motif nouveau | J2 observé, B = 99 (B_max = 2500), enveloppe de `usp_ajuster_rapide()` : appel k → δ := 0,5 si k %% 60 == 0, sinon 1 | `tirages` = 2500 ; `retenus_v1` = 1 ; `retenus` = 41 ; `rejets_flux` = (0, 2361, 0) ; `arret` = `"B_max"` ; les 34 `motif_mc` = `MOTIF_MC_REGIME_RARE` (aucune statistique observée non finie sur J2, TSV) ; `p_mc` et `err_mc` `NA`. Puis `usp_tests(fit, boot, 0.10, methode = "premium")` : (i) lignes `mc_nom` sans p exacte avec p asymptotique, nature = `"asymptotique (Monte-Carlo indisponible : <MOTIF_MC_REGIME_RARE>)"`, type `"test"`, `inoperant` FALSE ; (ii) « Nullité de la constante » en diagnostic ; (iii) les lignes à p exacte la gardent. Au moins une ligne de chaque sorte (non-vacuité) |
| U6 | B_max atteint, retenus ≥ 50 | idem U5 avec k %% 40 | `retenus_v1` = 2 ; `retenus` = 62 ; `arret` = `"B_max"` ; `tirages` = 2500 ; `motif_mc` `NA` pour les statistiques finies ; `granularite_stat` = 1/(B_eff + 1) ou 2/(B_eff + 1) ; nature conditionnelle sur les lignes Monte-Carlo retenues |
| U7 | B ≠ 999, contre-implémentation | J2 observé à B = 199 ; J3 b = 3 à B = 99 | `identical()` entre `usp_bootstrap()` et une copie déclarée de `rejouer_v1(complet = TRUE)` + `completer_v3b()` paramétrée par B (B_cible = B, B_max = 25 (B + 1), graine `usp_graine_flux_regime(seed)`), sur `p_mc`, `err_mc`, `B_effectif`, `granularite_stat`, `motif_mc` et `p_mc_regime`, **et** sur les champs de V1 (`stats_obs`, `sigma_boot`, `delta_boot`, `gamma_boot`, `z_boot`, `sigma_boot_restreint`, `n_echec_restreint`, `B`, `granularite` = 1/200) |
| U8 | levier P1 et périmètre du flux | J2 observé, B = 99, journal d'appels (enveloppes de `usp_ajuster_rapide()`, qui consigne δ̂**, de `.stats_bootstrapables()` et d'`usp_ajuster_contraint()`) | pour tout appel d'`usp_ajuster_rapide()` de rang > B, `.stats_bootstrapables()` est appelée juste après **si et seulement si** δ̂** est intérieur. Aucun appel d'`usp_ajuster_contraint()` après le rang B. Appels de statistiques dans le flux = `retenus − retenus_v1 + rejets_flux[["statistiques"]]` |
| U9 | V1 hors du bord | (a) J2 observé, `refit = FALSE`, B = 99 ; (b) jeu à volumes constants, `fit$delta` posé à 0,5 (sans effet sur π_t ni sur la vraisemblance) | `variante` = `"V1"`, `motif_v1` = texte du § 2.2, `regime_obs` = `"interieur"`, `usp_ajuster_rapide()` appelée au plus B fois, nature non suffixée |
| U10 | nature | `boot` de U2 (J2 b = 0) ; `boot` de J1 ; `boot` de J2 sans `p_mc_regime` | J2 : toute ligne `nature_p` Monte-Carlo vaut exactement le texte du § 4.2 (au moins une). J1 et la liste sans `p_mc_regime` : `"Monte-Carlo (bootstrap parametrique)"` |
| U11 | reproductibilité, générateur | J2 observé, B = 99, deux appels ; générateur de l'appelant modifié avant l'appel | `identical()` des deux objets ; `.Random.seed` et `RNGkind()` de l'appelant restaurés |
| U12 | classement d'`add()` | `boot` construit : `p_mc["GQ"] = NA`, `motif_mc["GQ"] = MOTIF_MC_REGIME_RARE` | repli nommé (p asymptotique fournie) ; diagnostic sous `repli_asymptotique = FALSE` ; p exacte retenue si fournie. `add()` n'est pas modifiée |
| U13 | `metadata` | `run_engine()` sur J1 (`premium`) et `reserve2` | `seed_flux_regime` = 20800000 après `permutation_pente` ; absent pour `reserve2` |
| U14 | données | `tests/donnees/donnees_ln_interieur.csv` | égal à `xi`, `yi` de `test_controles_numeriques.R` |

**Règle sur l'identité avec #229.** Les comparaisons de U2 à U4 sont des égalités exactes : une p est un rapport de comptes, et un écart d'un compte vaut 0,001. Un échec, y compris sur la CI seule, **n'est pas corrigé par une tolérance**. Il arrête l'étape et revient à `actuary` avec le tirage et la statistique en cause (quasi-égalité ou régime basculé).
- Élément favorable **[V]** : le contrôle (a) de #229 a trouvé J1 observé conforme à `premium.rds` (CI), avec 0 feuille non strictement identique.
- Le risque résiduel tient à la plateforme **[H]**.

**Coût.**
- J1 b = 1455 : environ 31 s par réplication dans #229 (T3) **[V]**.
- U2 : 10 à 13 s par cas **[V]**.
- Total ajouté à la batterie : environ 100 s **[H]** (Q-240-3).

## 8. Tableau avant / après attendu (skill `verifier-reproductibilite`)

| Cas | Attendu | Arrêt si |
|---|---|---|
| `premium`, `premium_ii6`, `premium_net`, `reserve1` (δ̂ = 1, *vérifié* au vingt-neuvième point) | **toutes les feuilles préexistantes identiques**. Feuilles ajoutées : `bootstrap$p_mc_regime` au contrat V1 (`"bord1"`, `"V1"`, `"delta estime au bord"`, 20800000, `NA`, `NA`, 999, `NA`, `NA`, trois `NA`, `NA`) et `metadata$seed_flux_regime` = 20800000. Régénération structurelle par la CI | une feuille préexistante change ; σ_USP change |
| `reserve2` | identique, aucune feuille ajoutée | toute différence |
| `premium_interieur` (créé ; « avant » = même appel sur `main` `67cd281`) | σ_USP, `parametre_final`, `ic_bootstrap`, `ic_bootstrap_restreint`, `lr_delta`, `plots_data`, `jackknife`, `profil` et les champs V1 de `bootstrap` **identiques**. `p_mc` des 34 statistiques = `p_V3b` de J2 b = 0 (GQ 0,268 → 0,018 ; BP 0,694 → 0,377 ; Grubbs 0,273 → 0,105 ; table T3 de #229). `p_mc_regime` comme en U2. `nature_p` suffixée sur les lignes à p Monte-Carlo retenue. **Verdict changé attendu : GQ, OK → ECHEC** (p < α/2 = 0,05), sous visa du mainteneur | σ_USP ou un champ V1 change |

**Prévision des verdicts** **[H]**. Elle se lit sur les p de la table T3 de #229, au dixième de millième. Aucune autre p ne franchit 0,05 ni 0,10, mais **Grubbs passe à 0,105**, soit à 0,5 `err_mc` (≈ 0,0097) de α : il reste OK.
- Tout autre changement de verdict n'arrête pas l'étape : il est porté au visa, au cas par cas (Q-A3-5 (b)).
- Les changements de p sans changement de verdict sont validés par `actuary`.

## 9. Durée de `run_engine()`

**Mesure.**
- Même machine. « Avant » : copie de travail de `main` `67cd281` (`git worktree`). « Après » : la branche.
- Trois exécutions par configuration, médiane de `system.time()[["elapsed"]]`, avec `nproc`, la version de R et le BLAS (`sessionInfo()`).
- Configurations :
  1. `run_engine()` sur J1 (`premium`, bord) ;
  2. `run_engine()` sur J2 (`premium_interieur`) ;
  3. `usp_bootstrap()` seul sur les deux ;
  4. « après » seulement : `usp_bootstrap()` sur J1 b = 1455, cas B_max.
- Les résultats vont dans le message du commit.

**Attendu** **[H]** :
- J1 : sans changement ;
- J2 : de 11,8 s à environ 18-25 s. Les 3 491 tirages du flux font surtout des réajustements, dont 796 avec statistiques ; référence : écart de T3 entre J2 intérieur (13,0 s) et bord 0 (8,0 s) ;
- cas B_max : de l'ordre de 30-60 s.

Aucun seuil d'acceptation. Un dépassement de trois fois ces estimations est signalé, sans bloquer.

## 10. Surface documentaire pour `docwriter` (passage unique, règle 9)

1. **`sec:calibration-mc`.** V3h passe de « évolution décidée, non encore implémentée » (`.tex` vers l. 13060) à « implémentée (#240) ». Le statut reste un **constat de simulation à T = 8 sur J1, J2, J3, jamais une calibration établie**. À restituer :
   - **marge de C1, à une réponse près** : sur J3, BP à α = 0,05 donne 120 rejets sur 2 000, soit 0,0600 ; IC de Clopper-Pearson [0,0500 ; 0,0713] ; borne basse 0,049993 < α ; à 121 rejets, 0,050452 ; McNemar contre V1 69 / 0 ; marges d'une réponse pour V3a et de trois pour V3b ;
   - **hausse de multiplicité de T2** sous H0 : 0,4835 → 0,5050 sur J2 et 0,4425 → 0,5005 sur J3. C'est le prix d'un niveau rétabli à l'intérieur ;
   - **partition F_T / F_R non tenue sur J3** : AD 27/7, Intercept 58/18, Smirnov 13/0 à α = 0,10 après Holm, tous « expliqués » au sens de L15. Nulle part le document ne doit présenter F_T comme indépendante du régime sans cette réserve.
2. **`tab:nature` et tableau 1.** Ajouter la nouvelle nature. Méthode : V1 au bord, à volumes constants et sous `refit = FALSE` ; V3b à l'intérieur. B_eff ≤ B ; jusqu'à 25 (B + 1) tirages.
3. **Tableau 2 (`tab:conv`).** L'erreur Monte-Carlo est en 1/√B_eff, conditionnellement à B_eff. L'erreur d'approximation à T = 8 n'est bornée par aucune théorie.
4. **Plancher.** La garantie de #127 (B minimal fonction de α) porte sur le B nominal. Quand B_max est atteint avec B_eff < B, la mention de plancher existante (#128, point d) peut apparaître aux petits α (Q-240-4).
5. **Reproductibilité et graines.**
   - Le flux du complément est une **sixième source de tirage** : `usp_graine_flux_regime()`, `seed` + 539 169 avec repli, jamais `seed`.
   - Il n'est posé qu'à l'intérieur.
   - La graine est consignée dans `metadata$seed_flux_regime` et `bootstrap$p_mc_regime$graine_flux`.
   - Collisions déclarées (§ 5).
6. **Motifs Monte-Carlo.** Ajouter `MOTIF_MC_REGIME_RARE`, non dégénéré, soumis à la règle actuelle, avec le renvoi à #181.
7. **Index des fonctions et constantes.** `usp_graine_flux_regime()`, l'assistant éventuel, `usp_bootstrap()` (description), `DECALAGE_GRAINE_FLUX_REGIME`, `FACTEUR_B_MAX_REGIME`, `MOTIF_MC_REGIME_RARE`.
8. **Rubriques 6 et 7 des fiches des statistiques du catalogue**, au moins F_8 (BP, BP79, GQ, BF, Grubbs, Grubbsr, DAgo, JB) : p conditionnelle à l'intérieur ; niveau intérieur rétabli et gains de puissance, en constats. Un paragraphe commun avec renvoi est admis (`CONVENTIONS.md`).
9. **`reserve1`.** L'extension est une **hypothèse** (ADR 0014, point 4).
10. **Vérification empirique de l'implémentation.** Identité avec V3b de #229 (U2, U3, U7).
11. **Scripts hors CI** (C-A4-4). Le contrôle (i2) de `p_conditionnelle_regime_t8.R` compare `usp_bootstrap()` à V1. À partir de ce commit, il devient faux sur un jeu à δ̂ intérieur. Les tableaux restent reproductibles à leur commit cité.
12. **Application et rapport figé.** Ligne d'en-tête de l'étape 4, si le `.tex` décrit l'en-tête.

## 11. Hors périmètre

- #181, #125, #244, #182, #120, #214 (E2b).
- Toute variante autre que V3h telle que mesurée, hors la règle de Q-A4-8.
- Merz-Wüthrich.
- La régénération des tableaux de #166, #175 et #229.
- Le refactor du littéral de nature existant.
- Un repli sur V1 quand le régime intérieur est rare : écarté par l'ADR 0014, point 2.

## Questions au mainteneur pour C1

- **Q-240-1** — À δ̂ intérieur, V1 à **volumes constants** (δ non identifié) et sous **`refit = FALSE`** (δ̂** absent), avec `motif_v1` nommé. *Recommandation : oui* ; l'alternative, V3b quand même, conditionnerait sur un artefact de l'optimiseur.
- **Q-240-2** — Texte de la nature : « …, conditionnel au regime interieur de delta **estime** ». *Recommandation : avec « estime »* ; le conditionnement porte sur δ̂, non sur δ. Alternative : le libellé littéral de la décision.
- **Q-240-3** — Coût de la batterie unitaire, environ 100 s ajoutées, dont J1 b = 1455 (25 000 tirages, environ 30 s). *Recommandation : tout dans la batterie* ; c'est le seul cas naturel de B_max atteint protégé par la CI. Alternative : U3 hors CI, exécuté une fois par `coder` puis `audit`, sortie citée.
- **Q-240-4** — Quand B_max est atteint avec 50 ≤ B_eff < B, la garantie de #127 ne s'étend pas à B_eff. *Recommandation : l'accepter et la documenter* ; la mention de plancher existante suffit, et toute règle nouvelle relève de #181 (E2b).
- **Q-240-5** — La graine du flux est consignée **même au bord**, où le flux n'est pas posé (valeur dérivée de `seed` ; `tirages` = B indique qu'il n'a pas servi). *Recommandation : oui.* Alternative : `NA` au bord.
- **Q-240-6** — Collisions de graines (§ 5) : documentées seulement. *Recommandation : oui.*

---

> **Annotation du 11/10/2026 : point d'arrêt C1 franchi.** Le mainteneur approuve la spécification telle quelle (commit `50b0bd5`). Toutes les questions sont tranchées selon les recommandations :
> - **Q-240-1** : V1 à volumes constants et sous `refit = FALSE`, avec `motif_v1` nommé ;
> - **Q-240-2** : nature « Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) » ;
> - **Q-240-3** : les quatorze tests restent dans la batterie, U3 compris ;
> - **Q-240-4** : la limite de la garantie de #127 à B_eff < B est acceptée et documentée ; toute règle nouvelle relève de #181 ;
> - **Q-240-5** : la graine du flux est toujours consignée, au bord compris ;
> - **Q-240-6** : les collisions de graines sont documentées seulement.
