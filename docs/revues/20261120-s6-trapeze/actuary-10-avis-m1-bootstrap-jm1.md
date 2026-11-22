# Avis d'`actuary` sur le constat M-1 de la revue finale (#567) : simulation de la colonne J−1 d'un trapèze quand la règle de minimum est nulle ou négligeable

> *Rédigé par l'agent actuary-approfondi (IA) le 22/11/2026 ; versé intégralement par la session principale.* Constats d'origine : revue finale d'`audit` (`high`, étape 10, tête `24450d4`), M-1 (majeur) et m-1 (mineur). **Décision du mainteneur, 22/11/2026 : M-1 en option (b), prédicat à trois conditions avec la clause numérique `MW_TOL_SIGMA_SIMULATION = 1e-10` (dérogation à Q-2a-2 dans ce seul cas, verdicts changés acceptés sur la classe d'entrées visée) ; m-1 : gabarits conditionnés (DEGENERE, SIMULATION) et `usage_sigma` par cas, dans le même commit.** Scripts d'essai hors dépôt (dossier temporaire de session) : `a1.R`, `inv.R`, `rho.R`, `niveau.R`, `ic.R`, `ref.R`, `s1b.R`.

## Avis d'actuary sur M-1 et m-1, branche `claude/merz-wuthrich-trapeze`, tête `24450d4`

Je n'ai rien écrit dans le dépôt : ni fichier, ni issue, ni commentaire. Mes essais sont dans le dossier temporaire de la session :
- `a1.R` : comparaison actuel / (a) / (b) à B = 999 ;
- `inv.R` : invariance d'échelle ;
- `rho.R` : seuil numérique ;
- `niveau.R`, `niveau_N.log`, `niveau_E.log`, `niveau_*.rds`, `ic.R` : étude de niveau ;
- `ref.R` : prédicat évalué sur les références ;
- `s1b.R` : reproduction de m-1.

### M-1 : je recommande l'option (b), avec un prédicat précisé

**Le défaut est confirmé** [V, `a1.R`, cas de l'audit, B = 999] :
- La colonne J−1 est simulée de façon déterministe, alors que la colonne observée est dispersée (σ̂²_dir = 0,0787).
- Sous ce modèle nul, les données observées ont une probabilité nulle : la loi de référence n'a pas le même support que la statistique observée.
- La ligne **Origine** perd en plus toutes ses réplications : `B_effectif = 0`, p_mc absente. Le prédicat de la réplication (`degeneres_aj`) déclare J−1 dégénérée, alors qu'elle n'est pas dans l'ensemble figé, d'où `na_stat()`. L'audit ne le signalait pas.

**Fait décisif : invariance trajectorielle** [V, `inv.R`]. Mêmes tirages, σ de simulation de J−1 multiplié par 1e-4, puis par 1e4 :
- Pour 11 clés sur 13, les statistiques répliquées sont identiques à ≤ 2,2e-9 près, et les p_mc sont identiques : Calendrier, CorrDev, BP, MinP4, DW, Runs, Origine, HomogF, Courbure, ExpVar, KruskalAcc.
- Seules **PenteIntra** (p = 0,002 / 0,078 / 0,096) et **Alpha** (0,025 / 0,030 / 0,859) dépendent de ce σ.
- Pour ces 11 clés, (b) est donc exactement la limite du comportement de Q-2a-2 quand σ_règle → 0⁺. La valeur 0 est la seule discontinuité.

**Niveau sous H0** [V, `niveau.R`]. Constat de simulation sous un seul plan, sans portée générale :
- plan : 8×6, f et σ² de `triangle_mw` 8×8, colonne J−3 déterministe (σ vrai nul), lois N et E ;
- 400 triangles par loi, B = 199, comparaison au α nominal et non à un oracle ρ.

| Clé, taux de rejet à 0,10 | actuel | (a) | (b) |
|---|---|---|---|
| PenteIntra, N | **0,172** [0,137 ; 0,213] | 0,090 | 0,102 |
| PenteIntra, E | **0,172** | 0,105 | 0,095 |
| CorrDev, N | **0,028** [0,014 ; 0,049] | 0,068 | 0,077 |
| Origine (p absente) | **400/400 absentes** | 0,112 | 0,100 |

- (a) et (b) rétablissent tous deux le niveau ; la mesure ne les départage pas.
- Point faible de (b), sous E à 0,05 : Alpha à 7/400, IC [0,007 ; 0,036], soit un peu conservateur.

**Pourquoi (b) plutôt que (a)**
1. **Continuité.** (b) prolonge par continuité le cas non dégénéré (point ci-dessus).
2. **Cohérence avec la spécification 2a** (§ 0, point 2, et Q-2a-1 (c)). Un trapèze y est traité comme le carré de même I privé de ses colonnes courtes, où cette colonne est simulée avec son propre σ direct.
3. **Rien n'est perdu à l'observé.** Les statistiques observées sont identiques au bit près (`identical(stats_obs)` TRUE). Les 2 à I−J+1 résidus de J−1 restent testés.
4. **(a) a quatre défauts.**
   - Il retire J−1 du vivier, donc il change toutes les p_mc et σ_boot.
   - `mw_famille_alpha()` ne lit pas l'ensemble figé : Alpha garde J−1 à l'observé, avec une amplitude nulle dans les réplications.
   - Les phrases d'exclusion diraient J−1 « à facteurs égaux à f_j », ce qui est faux (E5). Il faudrait donc créer une nouvelle catégorie d'exclusion.
   - (a) serait à défaire si #612 retient la simulation directe. (b) en est un cas particulier, compatible avec l'une ou l'autre issue de #612.
5. **(c) est écarté.** Le triangle est recevable et σ_USP est calculable. Un refus serait un refus à tort (E1).
6. **Cohérence avec M6 et Q-2a-2.**
   - La MSEP, σ_USP et l'`estim` de M6 ne changent pas.
   - (b) déroge à Q-2a-2 seulement dans ce cas. La raison de Q-2a-2 (simuler le modèle de la MSEP) tombe : ce modèle rend les données de J−1 impossibles.
   - Pour 11 clés sur 13, la dérogation ne change rien au-delà du passage de 0 à une valeur positive. Elle ne porte en réalité que sur PenteIntra, Alpha et σ_boot / l'intervalle.
   - σ_boot change à peine sur le cas de l'audit : quantiles 5/50/95 % de 0,01135 / 0,01511 / 0,01874 à 0,01138 / 0,01509 / 0,01875.

**Formulation pour `coder-approfondi`**
- Une fonction unique, par exemple `.mw_simulation_sigma_direct(aj)`, calculée sur `aj` seul. Elle rend TRUE si et seulement si les trois conditions suivantes sont réunies :
  1. `!is.null(aj[["sigma2_Jm1_direct"]])`, c'est-à-dire I > J ;
  2. `!.mw_colonne_degeneree(aj, aj$J - 1L)` : si J−1 est dégénérée, elle est figée et σ_dir vaut à peu près 0, donc rien ne change ;
  3. `isTRUE(mw_extrapolation_sigma2(aj)$degeneree)` **ou** `sqrt(aj$sigma2[J]) <= MW_TOL_SIGMA_SIMULATION * aj$f[J] * sqrt(max(aj$tri[seq_len(I - J + 1), J]))`, avec `MW_TOL_SIGMA_SIMULATION <- 1e-10`.
- **Pourquoi la clause numérique** [V, raisonnement et `rho.R`] :
  - Le quotient σ⁴_{J−2}/σ²_{J−3} rend σ_règle numériquement nul sans que `degeneree` soit vrai. Exemple : une colonne J−2 dont l'écart relatif vaut environ 1e-9, ce que donne un facteur fixe appliqué à des montants arrondis.
  - ρ est la plus petite dispersion relative simulée de F(i,J−1).
  - Réplications où J−1 sort dégénérée, sur 500 : 236 à ρ = 1e-12, 7 à ρ = 1e-11, 0 à ρ = 1e-10. D'où 1e-10 : la tolérance de l'outil, 1e-12, avec une marge de 1e-2 sur |e|.
  - C'est une convention numérique, pas un seuil statistique.
- **Dans `mw_bootstrap()`** : si le prédicat est vrai, les triangles sont tirés sur une copie `aj_sim` avec `aj_sim$sigma2[J] <- aj$sigma2_Jm1_direct`. Le reste lit `aj` : vivier, contexte observé, ensembles figés, `.mw_stats()`, MSEP des réplications.
  - `.mw_simuler_triangle_etat()` ne change pas.
  - Les tirages sont les mêmes : même consommation du générateur.
  - Aucun champ nouveau dans `aj` ni dans `boot` : la structure des références ne bouge pas.
- **Observé** : inchangé. **`mw_residus()`, `mw_influence()`** : inchangés, puisque J−1 répliquée n'est plus dégénérée. **MSEP, σ_USP, M6 `estim`** : inchangés.
- **Commentaires du moteur à corriger** (ils énoncent une règle, E5) : `mw_ajuster()` l. 13469-13480, `.mw_sigma2_residus()`, `.mw_simuler_triangle_etat()` l. 16076-16079.

**Tests attendus**
- (s2) complété, `mw_bootstrap(B = 99)` :
  - le prédicat est TRUE ;
  - `B_effectif = B` sur les 13 clés, p_mc d'Origine non NA ;
  - `stats_obs` sont `identical()` à ceux de la version actuelle ;
  - `identical()` entre le bootstrap et le bootstrap de `aj` dont `sigma2[J]` est remplacé par le direct (p_mc et `stats_boot`) ;
  - dans la boucle reproduite, aucune réplication où J−1 est dégénérée ni sans résidu.
- Variante J−2 dégénérée (`degeneree_Jm2`) : prédicat TRUE.
- Clause numérique : colonne J−2 à écart d'environ 1e-9, avec `degeneree` FALSE et prédicat TRUE.
- Témoins à FALSE : (s1), 8×5, 8×6 et 8×7 ordinaires, carrés.
- `run_engine()` sur (s2) : `ok`, Origine avec une p.
- Mentions (m-1) et `usage_sigma` par cas, M23 étendue (ou M24, M25), mesure #514 refaite.
- Sept références à `--seuil 0`, identiques.

**Références** : non touchées [V, `ref.R`]. Le prédicat est FALSE sur `reserve2` (carré) et sur `reserve2_trapeze` (ρ = 6,8e-3, `degeneree` FALSE). Les cinq références lognormales n'empruntent pas ce chemin.

**Changement de résultat** : seulement sur les entrées où le prédicat est vrai. Cas de l'audit, B = 999 :

| Clé | actuel | (b) |
|---|---|---|
| Origine | absente | 0,123 |
| DW | 0,054 | 0,028 |
| Calendrier | 0,024 | 0,014 |
| Runs | 0,560 | 0,494 |
| PenteIntra | 0,084 | 0,078 |
| Alpha | 0,025 | 0,030 |

Des verdicts changent sur une classe d'entrées : tableau avant / après à soumettre au mainteneur.

**Ce que le document doit dire** (passage de `docwriter`, section du bootstrap de Merz-Wüthrich et fiche M6) :
- J−1 est simulée avec la règle, sauf si la règle est nulle ou négligeable (prédicat ci-dessus) alors que J−1 n'est pas dégénérée. On simule alors avec σ̂_dir. C'est une convention de l'outil, non réglementaire.
- Motif : un modèle nul de support disjoint de l'observé.
- Propriété : 11 statistiques sur 13 sont invariantes trajectoriellement en σ > 0 ; PenteIntra et Alpha ne le sont pas.
- La MSEP et σ_USP sont inchangés ; σ_boot et l'intervalle en dépendent.
- Validité à T = 8 : p Monte-Carlo d'un bootstrap semi-paramétrique à paramètres estimés. Aucun théorème ; un niveau observé par simulation sous un plan seulement.

### m-1 : conditionner, ne pas reformuler

Conditionner laisse intact le texte de `reserve2_trapeze`. La phrase actuelle reste pour le cas général. Deux gabarits s'ajoutent, avec les mêmes trois arguments `sprintf` dans le même ordre. Le choix se fait ainsi : `.mw_colonne_degeneree(aj, J-1)` donne DEGENERE, sinon le prédicat de M-1 donne SIMULATION.

- **DEGENERE** : "Trapeze (I > J) : la regle de minimum s'applique a sigma2_(J-1) par prescription de l'annexe XVII, D(5)(d)(ii), seconde ligne, bien que la colonne J-1 porte %d facteurs, dont l'estimateur direct vaut %s a %d degre(s) de liberte ; cette colonne etant degeneree (voir l'avertissement sur les donnees), aucun de ses residus n'est retenu (tests, influence, vivier du bootstrap) et l'estimateur n'entre ni dans la MSEP ni dans la simulation : valeur donnee pour information."
  - L'avertissement nomme bien « j = 4 (3 facteurs) » [V, `s1b.R`].
- **SIMULATION** : "Trapeze (I > J) : la regle de minimum s'applique a sigma2_(J-1) par prescription de l'annexe XVII, D(5)(d)(ii), seconde ligne, bien que la colonne J-1 porte %d facteurs, dont l'estimateur direct, %s a %d degre(s) de liberte, reduit les residus de cette colonne (tests, influence, vivier du bootstrap) et remplace dans la simulation du bootstrap la valeur de la regle, ici nulle ou negligeable, sans entrer dans la MSEP : valeur donnee pour information."
- **`usage_sigma`** devient une fonction `.mw_usage_sigma(aj)` :
  - cas général : `MW_USAGE_SIGMA`, inchangé ;
  - SIMULATION : `sigma` = "sigma_(J-1) de la regle de minimum (D(5)(d)(ii)) : MSEP", `sigma_residus` = "sigma_(J-1) estime directement : residus, tests et simulation" ;
  - DEGENERE : `sigma` inchangé, `sigma_residus` = "sigma_(J-1) estime directement : colonne degeneree, sans residu".
  - Toutes ces légendes font au plus 62 caractères et se coupent au premier " : ". `regulatory` doit contrôler les renvois, `app-review` le rendu.

## Retour

- **Statut** : `revue requise`. L'option (b) déroge à Q-2a-2, une décision du mainteneur, et des verdicts changent sur une classe d'entrées.
- **Résultat** :
  - M-1 : option (b), prédicat à trois conditions avec la clause numérique 1e-10 ; observé, résidus, influence, MSEP et σ_USP inchangés ; aucune référence touchée.
  - m-1 : deux gabarits conditionnels et `usage_sigma` conditionnel.
- **Preuves**
  - *Vérifiées* (commandes exécutées sous `LC_ALL=C.UTF-8`) : `a1.R`, `inv.R`, `rho.R`, `niveau.R` (800 triangles), `ic.R`, `ref.R`, `s1b.R`. Code lu : `mw_ajuster`, `mw_extrapolation_sigma2`, `mw_residus`, `mw_influence`, `.mw_contexte_mc`, `MW_CATALOGUE_MC`, `mw_bootstrap`, `.mw_simuler_triangle_etat`, M6 de `mw_tests`, `plot_mw_facteurs` ; spécification 2a (§ 2, § 3, Q-2a-2, annotation M2), T0, #612.
  - *Hypothèses* :
    - la valeur 1e-10 tient hors du triangle mesuré, la marge reposant sur |e| ≥ 1e-2 ;
    - l'algèbre de l'invariance est démontrée par le raisonnement ; la mesure n'en a été faite que sur un seul triangle.
  - *Non vérifiés* :
    - niveau comparé à un oracle ρ (la comparaison porte sur α nominal) ;
    - autres géométries (8×5, 10×5) et autres plans.
- **Informations manquantes** : aucune.
- **Décisions non résolues** (mainteneur) : la dérogation à Q-2a-2 dans ce cas ; l'acceptation des verdicts changés ; la constante 1e-10 contre la simple clause `degeneree`. *(Tranchées le 22/11/2026, voir l'en-tête.)*
- **Critères déclenchés** :
  - changement de résultat (p_mc et verdicts sur une classe d'entrées, hors références) ;
  - écart à une décision du mainteneur (Q-2a-2) ;
  - validité à T = 8 établie par simulation sous un seul plan.
  - Aucun désaccord avec `audit`, dont j'ai repris les constats ; j'y ajoute Origine à `B_effectif = 0`.
- **Constats hors périmètre**
  1. Dans les réplications, `mw_residus()` n'écarte une colonne non figée que sur `s2 <= 0`, et non sur le prédicat de la réplication, contrairement aux lignes M1 (`.mw_degeneree_courante`). Après (b), ce cas ne reste atteignable que pour une colonne de dispersion relative comprise entre 1e-12 et environ 1e-10 (`rho.R`). Critère E3, gravité mineure ; preuve : `engine.R` l. 14483 contre l. 15344.
  2. Le régime σ_règle ≪ σ_dir non nul relève de #612 : à 1e-4 fois le direct, PenteIntra p = 0,002 (`inv.R`), et Alpha dépend de ce σ pour n_{J−1} ≥ 3. Critère E3, déjà suivi par #612 : il faut en élargir le périmètre (Alpha, régime de faible rapport), sans issue nouvelle.
  3. Alpha sous (b), loi E, à 0,05 : 7/400 (conservateur). Même périmètre (#612), critère E3.
  4. MinP4 rejette 0,158 à 0,10 sous E, identique dans les trois variantes : rien à voir avec M-1. Non comparé à #297. Critère : aucun établi.
- **Prochaine action recommandée** : porter au mainteneur la dérogation à Q-2a-2 et le choix de (b), avec le tableau avant / après sur le cas (s2). Sur son accord, lancer `coder-approfondi` avec la formulation et les tests ci-dessus, puis un audit du diff. Enfin, compléter #612 par un commentaire sur les points 2 et 3.
