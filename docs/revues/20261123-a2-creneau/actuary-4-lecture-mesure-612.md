# A2, étape 4 (#612) : lecture de la mesure L-A et recommandation sur Q-2a-2

*Rédigé par l'agent `actuary-approfondi` (IA), le 25/11/2026. Consultation en lecture seule sur `claude/creneau-a2`, tête `43a8074`. md5 de `R/engine.R` : `5bffa72279b34a7ab12bd5b9f13abc15`, le même que pour la mesure. Je n'ai rien écrit dans le dépôt (`git status` vide à la fin). Les scripts de travail (`strat.R`, `s2.R`, `eff.R`, `cmp2.R` à `cmp5.R`, `car.R`) sont restés dans le dossier temporaire de la session, non versés. Tous ont tourné sous `LC_ALL=C.UTF-8`, moteur chargé par `tests/outils_tests.R` (donc `charger_moteur()`). La substitution a été posée dans `environment(run_engine)`, puis restaurée ; la restauration est vérifiée par `identical()`.*

*Versé intégralement par la session principale (Q-54-10). Seule retouche : le chemin absolu du dossier temporaire, remplacé par sa désignation.*

Légende : **[V]** vérifié (source relue ou commande exécutée) ; **[H]** hypothèse ; **[NV]** non vérifié.

---

## 1. Recommandation sur Q-2a-2 : **passer à V2** (cas B). La règle R-V2 est confirmée sur le fond, avec trois nuances.

### 1.1 Ce que la mesure établit, critère par critère

Toutes les mesures sont sous le plan : modèle de Mack ajusté à `reserve2`, T = 8, lois N et E, B = 999.

| Critère | Constat | Statut |
|---|---|---|
| K0 | Les 2 000 / 2 000 triangles de chaque (G, ℓ) sont invariants sur les 11 ou 12 clés. Aucun refus, aucune p absente. 20 contrôles d'intégrité OK. (r567) : 100 / 100 au bit. | [V] |
| K1 (confirmatoire, triangles neufs) | L'excès de V0 sur PenteIntra 8×7 à 0,05 se reproduit. Sous N : Δ̂ = +0,016 [0,0087 ; 0,0193], 18 paires contre 2, p Holm = 4·10⁻⁴. Sous E : +0,029 [0,0233 ; 0,0290], 29 contre 0, p Holm = 7·10⁻⁹. | [V] |
| K2 | **Tenu par K2b seulement.** V2 est aligné sur le carré dans les 4 cellules (Δ̂ de +0,0005 à +0,005). Il n'est **pas** aligné sur le témoin à 0,05 : +0,008 [0,003 ; 0,012] sous N, +0,0175 [0,012 ; 0,021] sous E. | [V] |
| K2′ | V2 rejette moins que V0 dans les 4 cellules (Δ̂ de −0,010 à −0,0115, p Holm ≤ 0,0025), et \|Δ̂_V2\| < \|Δ̂_V0\| partout. | [V] |
| K3 | Les 16 cellules sont tenues. Une seule l'est de justesse (§ 1.3, nuance 2). | [V] |
| K4 | Non-couverture de V2 − V0 comprise entre −0,002 et 0 ; bornes hautes ≤ 0,0016, très en deçà de +0,02. | [V] |

### 1.2 Lecture de fond : pourquoi R-V2 se confirme

**(a) Le mécanisme est identifié, et V2 le neutralise.** J'ai fait une lecture stratifiée sur les 4 000 triangles 8×7, N et E réunis. Elle est *a posteriori* et descriptive, hors des critères K. Elle compare les décisions PenteIntra de V0, de V2 et du carré 8×8 des mêmes triangles (même témoin, contrôle (o) 4 000 / 4 000). Les classes sont les quartiles de r = σ̂²_règle / σ̂²_dir.

| Quartile de r (à 0,05) | V0 − T | V2 − T | Carré − T | V2 − carré [IC 90 %] | V0 − carré [IC 90 %] |
|---|---|---|---|---|---|
| Q1 (r ≤ 0,029) | +0,062 | +0,024 | +0,011 | +0,013 [0,007 ; 0,015] (14 contre 1) | +0,051 [0,045 ; 0,051] |
| Q2 | +0,014 | −0,002 | +0,003 | −0,005 [−0,010 ; 0,002] | +0,011 [0,004 ; 0,015] |
| Q3 | +0,005 | +0,002 | +0,001 | +0,001 [−0,005 ; 0,006] | +0,004 [−0,002 ; 0,008] |
| Q4 (r > 1,41) | +0,013 | +0,027 | +0,025 | +0,002 [−0,005 ; 0,009] | **−0,012 [−0,019 ; −0,003]** |

À 0,10, V2 − carré reste entre −0,001 et +0,008 dans les quatre quartiles. V0 − carré y vaut +0,052, +0,015, −0,001 et **−0,018** [V, `strat.R`].

- **Lecture.** V0 s'écarte du carré **dans les deux sens** : libéral quand la règle est petite devant l'estimateur direct, conservateur quand elle est grande. Son excès global est le solde de deux biais. Dans Q4, V0 paraît plus proche du témoin que V2, mais seulement parce qu'il compense par accident l'excès propre du carré. V2 suit le carré dans chaque strate, à une exception près (Q1 à 0,05).
- **Conséquence.** V2 rétablit la relation structurelle « le trapèze est le carré privé de ses colonnes courtes ». C'est l'argument de fond de K2b. Statut : [V] pour les nombres, [H] pour le mécanisme. Le mécanisme est appuyé par le balayage du constat (2) : sur 8×7, la p médiane de PenteIntra passe de 0,97 à 0,60 quand k va de 1e-8 à 1.

**(b) La raison d'être de Q-2a-2 n'est pas perdue.** Q-2a-2 visait la cohérence avec la MSEP. Or σ* de chaque réplication reste √MSEP*/R̂* calculé par `mw_msep(ab)` sur le triangle réajusté, donc **avec la règle de minimum de la réplication** (`R/engine.R` l. 16453-16460) [V, lecture]. La simulation ne change que la dispersion de la colonne J−1 des triangles tirés. Elle n'atteint σ* que par f̂_{J−1} et R̂* [H, lecture], d'où l'écart de couverture quasi nul de K4 [V].

**(c) Les tests y gagnent en cohérence.** Les résidus observés de la colonne J−1 sont réduits par l'estimateur direct (Q-2a-1 (c)). Sous V2, les réplications sont tirées sous un modèle dont σ²_{J−1} est celui qui a réduit ces résidus. Sous V0, elles le sont sous une valeur prescrite pour la MSEP, qui n'estime pas la variance de la colonne : ADR 0005, annotation du 21/11, point 10, où la règle sous-estime σ²_{J−1} sur 8×7 et la surestime sur 8×5 et 8×6. Ce point est un raisonnement [H]. Je ne cite aucune source : je n'en ai pas relu qui traite ce cas.

**(d) Le moteur se simplifie.** V2 absorbe la dérogation M-1 (b) du 22/11 : le corps V2 coïncide avec V0 dans ce cas [V, protocole § 2 ; (dc) D 2 000 / 2 000]. `MW_TOL_SIGMA_SIMULATION` et le « régime de faible rapport » du constat (2) deviennent sans objet. Ce régime n'est pas marginal : r < 0,01 sur **16,5 %** des triangles 8×7 [V, `strat.R`].

### 1.3 Nuances à porter avec la recommandation

1. **V2 n'élimine pas l'excès de PenteIntra sur 8×7 ; il le ramène à celui du carré.**
   - K2a échoue à 0,05 dans les deux lois. Sous E, V2 contre carré vaut encore +0,005 [0,0002 ; 0,009] : la différence est dans la marge, mais l'intervalle exclut 0.
   - Dans Q1, V2 dépasse le carré à 0,05 : +0,013, 14 contre 1, p = 0,001. Ce résultat est *a posteriori*, mais il reste significatif après une correction de Bonferroni sur 8 comparaisons. Il disparaît à 0,10.
   - Hypothèse [H] : la colonne J−1 du 8×7 n'a que I − J = 1 degré de liberté, et son σ̂ direct est très bruité.
   - **La réserve PenteIntra reste donc écrite**, mais reformulée : excès résiduel de l'ordre de celui du carré (déjà documenté pour le carré, `doc_tests_usp.tex` l. 20707-20714), plus un reste à faible r.
2. **Alpha sur 8×6, loi E, à 0,10 devient légèrement libéral sous V2.**
   - Δ̂ = +0,0135 [0,0043 ; 0,0221] (τ_V2 = 0,1075 pour un témoin à 0,094), contre +0,0045 sous V0.
   - La cellule passe K3 par la seconde branche, avec une marge de 0,001 (0,0135 ≤ 0,0045 + 0,010). Sa classe contre ρ est « compatible ».
   - En contrepartie, V2 aplatit la dépendance d'Alpha à r. Sur 8×5 : Q1 passe de +0,033 à +0,009 et Q4 de −0,037 à −0,017 [V, tableau de la mesure l. 621-628].
   - Le bilan sur Alpha est neutre à légèrement favorable. Une phrase de réserve suffit.
3. **Portée.** Il s'agit d'un constat de simulation sous un seul plan. L'erreur de substitution n'est pas quantifiée. Que V2 ait le même avantage sur un autre profil de σ est une [H], appuyée par le caractère structurel du mécanisme (§ 1.2 (a)), non par une mesure. Aucune littérature retrouvée ne tranche le niveau de ces tests bootstrap à T = 8 [NV ; constat repris d'`actuary-5b` § 6 et du protocole § 7, sans nouvelle recherche].

### 1.4 V1 et V0 écartés

- **V1 est sans objet.** R-V1 exige K4 en défaut ; K4 est tenu, avec un écart ≤ 0,002 [V]. V1 ajouterait un second flux sous graine, donc un contrat partagé, sans aucun gain mesuré.
- **V0 (cas A).** Il reste défendable seulement si l'on tient Q-2a-2 pour un principe indépendant de la mesure. Mais la mesure montre que V0 introduit dans la loi de référence de PenteIntra un biais à deux sens, que le carré n'a pas. Les critères fixés avant la mesure désignent V2.

### 1.5 Séparation des erreurs

| Source | Grandeur | Traitement |
|---|---|---|
| Monte-Carlo de B (B = 999) | err_mc ≈ 0,0069 pour p ≈ 0,05 | Elle fait partie de la procédure du moteur. Les nombres aléatoires communs entre V0 et V2 la retirent en grande partie de la différence. Sur `reserve2_trapeze`, les 13 p_mc sont identiques sous les deux variantes. [V] |
| Monte-Carlo du nombre de triangles | Intervalles de McNemar conditionnels de largeur ±0,004 à ±0,006 (n = 2 000) ; Clopper-Pearson de la couverture ±0,02 | Lue dans les intervalles. [V] |
| Oracle (N0 = 20 000) | ≈ 0,0015 à 0,05 | Commune à V0, V2 et C. [V, calcul du protocole] |
| **Approximation à T = 8** (objet mesuré) | PenteIntra 8×7 à 0,05, en τ − τ_T : V0 +0,0195 / +0,0275 ; V2 +0,008 / +0,0175 ; carré +0,0075 / +0,0125 (N / E) | [V] sous le plan |
| Substitution (plan, lois) | Non quantifiée | [NV] |

---

## 2. Sort des constats (1) à (4)

### (1) Résidus d'une colonne qui devient dégénérée dans une réplication : **correction**, portée par #615

- La règle se déclenche : J−2 du carré à ρ = 2e-12, part touchée 0,396, |Δp| = 0,094, soit 3,19 err_mc (PenteIntra) [V, tableau l. 512-518].
- **Lien avec V2.** Sur la colonne J−1 du 8×6, V2 *crée* une exposition que V0 n'a pas : à 2e-12, 187 réplications sur 999 sont touchées sous V2, aucune sous V0 [V, l. 535-546]. L'effet reste sous la règle (|Δp| ≤ 0,55 err_mc). V2 recopie la quasi-dégénérescence observée dans la simulation. C'est une raison de plus de corriger (1) **avant** le commit de V2.
- **Rattachement recommandé : au créneau A2**, troisième place libre, même module (ADR 0018, § 5.2, sur décision du mainteneur). Commit `moteur:` distinct, avant celui de la simulation. Seuil 0 attendu sur les sept cas : [H forte], car la plus petite dispersion relative des cas de référence est 5,85e-3 et les cinq cas lognormaux n'empruntent pas ce code. Cela reste à prouver.
- **Point de spécification à trancher par une spécification courte d'`actuary`** (circuit 1, comme l'écrit #615). La sonde n'a testé que le prototype P1 : exclure des résidus de la réplication `union(figées, dégénérées de la réplication)`. Or P1 s'écarte du principe des ensembles figés (#278 : chaque réplication combine les mêmes colonnes que l'observée). Une variante P2 est l'inverse : les lignes M1 liraient l'ensemble figé, et non le prédicat de la réplication. Les deux rétablissent la cohérence ; seule P1 est mesurée. **Recommandation : P1**, car un résidu de colonne quasi dégénérée réduit par un σ̂ de l'ordre de l'arrondi n'a pas de sens numérique. Statut [H], à acter par la spécification.

### (2) Balayage σ_règle / σ_dir : descriptif, **sans objet sous V2**

- Sous V2, la simulation est toujours directe : le régime de faible rapport disparaît, et `MW_TOL_SIGMA_SIMULATION` aussi.
- La documentation garde la courbe en appui du mécanisme. Le mot « hypothèse » de `doc_tests_usp.tex` l. 16172 devient : mécanisme *appuyé par une mesure appariée sous le plan*.

### (3) Alpha sous E : **clos**

Dans le bloc D (cas M-1 (b), 2 000 / 2 000), Alpha est « compatible » contre ρ aux deux seuils et sous les deux lois. Le Δ apparié sous E à 0,05 vaut −0,020 [−0,030 ; −0,008], côté conservateur mais sans distorsion classée [V, l. 636-639]. Aucune réserve nouvelle n'est nécessaire.

### (4) MinP4 : **clos, réserve « conservateur » confirmée et étendue**

- Le 0,158 d'`actuary-10` ne se reproduit pas contre l'oracle : 0,058 sous E à 0,10 dans D. Il s'expliquait par la référence nominale et B = 199.
- MinP4 est conservateur partout. Distorsion matérielle conservatrice dans D sous N à 0,05 : 0,014 [0,008 ; 0,023]. Écart non tranché ou mineur sur 8×5 à 8×8.
- Aucune différence significative avec #297 (Fisher, Holm, 16 cellules). MinP4 est invariant à V0 / V2 [V].

### Ce que la documentation doit dire (étape 7, `docwriter`)

1. **Réserve PenteIntra (`sec:trapeze-niveau`, fiche M1).**
   - Sous V2 : excès résiduel sur 8×7 à 0,05 de +0,008 (N) et +0,0175 (E) contre le témoin apparié, du même ordre que celui du carré sur les mêmes triangles (+0,0075 ; +0,0125). V0 aurait donné +0,0195 et +0,0275.
   - Le mécanisme est appuyé par la mesure appariée et la lecture stratifiée.
   - « Une ALERTE ou un ECHEC peut surestimer la preuve » reste vrai, avec une ampleur moindre.
2. **Réserve MinP4.** Conservateur sur les trois trapèzes, le carré et le cas à règle nulle ; un OK est une preuve faible. Chiffres de la mesure L-A.
3. **Alpha.** Une phrase pour 8×6, loi E, à 0,10 sous V2 (+0,0135, classe compatible).
4. **Couverture (limite (iv) de `doc_tests_usp.tex` l. 16078-16080 et de l'ADR 0005).** Elle devient fausse dans les deux cas, A comme B : elle dit « non mesurée » et « dépend du même choix de simulation ». La remplacer par :
   - *mesurée* sous le plan ; non-couverture à 90 % contre σ_A^règle (IC de Clopper-Pearson à 95 %, mon calcul [V]) :

     | Trapèze | Loi N | Loi E |
     |---|---|---|
     | 8×5 | 0,355 [0,334 ; 0,376] | 0,265 [0,245 ; 0,284] |
     | 8×6 | 0,192 [0,175 ; 0,210] | 0,109 [0,096 ; 0,124] |
     | 8×7 | 0,163 [0,147 ; 0,179] | 0,094 [0,082 ; 0,108] |

   - sous-couverture presque entièrement par la queue haute, du même sens que sur le carré (#387 : 0,427) ;
   - **insensible** au choix de simulation de J−1 (K4).
5. **Mention M6 et légendes `usage_sigma`.** Elles sont réécrites à l'étape 6. `regulatory` relit en routine, car le gabarit M6 cite D(5)(d)(ii).
6. Statut épistémique repris tel quel (protocole § 4).

---

## 3. Effets sur le cas de référence `reserve2_trapeze`

Calcul **mesuré** par `run_engine()` complet (B = 999, graine 20260831), moteur `5bffa722…`, V2 par substitution du seam. V0 est conforme à `tests/reference/reserve2_trapeze.rds` : 0 feuille sur 18 573 à 1e-6, et V0 est reproductible au bit [V, `eff.R`, `cmp.R`].

| Grandeur | V0 (actuel) | V2 (mesuré) | V1 (estimé) |
|---|---|---|---|
| 13 p_mc | — | **identiques au bit** à V0 [V] | identiques (tests de V2) [H] |
| p retenues, verdicts, `inoperant` (25 lignes) | — | **identiques** [V]. PenteIntra 0,058 ALERTE ; Alpha 0,006 ECHEC ; Courbure 0,022 ECHEC ; Calendrier 0,001 ECHEC ; DW 0,012 ECHEC ; Origine 0,083 et HomogF 0,065 ALERTE | identiques [H] |
| **σ_USP** | 0,047579706708939767 | **identique** au bit, de même que `parametre_final`, `msep`, `ajustement`, `calibration`, `candidats` [V] | identique (`mw_parametre()` ne reçoit pas le bootstrap) [V, lecture] |
| σ_boot | moyenne 0,01802815, écart-type 0,00276898 | moyenne 0,01802792, écart-type 0,00276855 ; 999 / 999 valeurs changées, écart relatif maximal 2,6e-3 [V] | = V0 si la boucle σ rejoue les tirages de V0 sous la même graine [H] ; sinon variation de l'ordre de l'erreur Monte-Carlo [NV] |
| `ic_bootstrap` (2,5 / 5 / 50 / 95 / 97,5 %) | 0,04438426 / 0,04481744 / 0,04753332 / 0,05029606 / 0,05062466 | 0,04438554 / 0,04482070 / 0,04753261 / 0,05029163 / 0,05061619 ; écarts relatifs de −1,7e-4 à +7,3e-5 [V] | = V0 [H] |
| `stats_boot` | — | PenteIntra et Alpha : 999 / 999 changées (PenteIntra jusqu'à 0,28). BP, DW, Origine changent au niveau de l'arrondi (≤ 2,7e-10), sous la tolérance [V] | comme V2 [H] |
| B effectif, `n_sans_sigma`, retirage | 999, 0, non | inchangés [V] | — |

**Feuilles au-delà de 1e-6 entre V0 et V2 : 5 006 sur 18 573** [V, `comparer_objets()`] :
- `bootstrap$sigma_boot` : 999 ;
- `stats_boot` : 1 998 (PenteIntra, Alpha) ;
- `ic_bootstrap` : 5 ;
- `plots_data$sigma_boot` et `plots_data$sigma_usp_boot` : 999 chacun ;
- `boot_reperes` : 3 (`ic_bas`, `ic_haut`, `moyenne`) ;
- `usage_sigma` : 2 ;
- `tests[[20]]$detail` : 1.

**Avertissement sur les deux dernières lignes.** Avec le seam substitué seul, `.mw_cas_sigma_direct()` classe le trapèze en « simulation ». Le détail M6 dit alors « remplace … la valeur de la règle, **ici nulle ou négligeable** » : c'est **faux** pour `reserve2_trapeze` (r = 1,458). Les légendes `MW_USAGE_SIGMA_SIMULATION`, elles, sont justes sous V2. Ces textes doivent être réécrits à l'étape 6 (E5 du protocole, § 10). Le tableau avant / après de la CI portera ces textes réécrits, et non ceux du seam.

**`reserve2` (carré) : `identical()` sous V2** [V, `car.R`]. Les cinq cas lognormaux n'appellent pas le seam : ses seuls appelants sont `mw_bootstrap()` l. 16426 et `.mw_cas_sigma_direct()` l. 13901 [V, `grep`].

**Bilan prévisionnel en (B)** :
- un seul cas à régénérer par la CI ;
- aucun σ_USP ni aucun verdict changé sur les sept cas ;
- p-values inchangées ;
- σ_boot, l'intervalle et les textes M6 / `usage_sigma` changent.

**Hors cas de référence** : sur d'autres trapèzes, les p de PenteIntra et d'Alpha et leurs verdicts changeront, par construction.

---

## 4. Erratum du protocole, à consigner

Au § 1 d'`actuary-1-protocole-612.md`, les valeurs 0,684464 / 0,141928 / 0,030091 (règle) et 0,314779 / 0,0973248 / 0,189674 (vrai) sont des **σ²_{J−1}**, et non des σ_A. Les vraies cibles sont σ_A^règle = 0,021331 / 0,018101 / 0,016621 et σ_A^vrai = 0,018859 / 0,017675 / 0,019065 [V, contrôle (c) l. 69 et tableau l. 85-89 de la mesure]. La définition « √MSEP/R̂ du générateur » était juste, et le script l'a appliquée.

**Effet sur la lecture : aucun.**
- K4 a été calculé sur les vraies cibles σ_A.
- K0 à K3 ne dépendent pas de ces valeurs.
- Les phrases qui les emploient comme σ² restent exactes : ADR 0005 point 10, et le « la règle sous-estime σ²_{J−1} sur 8×7 » de la documentation.

L'erratum se consigne à côté du protocole, sans modifier ce fichier, dont le md5 a été approuvé à PA-1.

---

## 5. Constats hors périmètre (ADR 0018)

**Marquants : aucun.** Les points qui touchent la documentation ou l'ADR (limite (iv) sur la couverture, mécanisme qualifié d'« hypothèse », textes M6 / `usage_sigma`, commentaires du moteur l. 13113, 13508, 13564, 16221, tests de `test_merz_wuthrich_trapeze.R` l. 412-490 et 531-564 sur le prédicat à trois conditions) sont **dans le périmètre** de #612, aux étapes 6 et 7.

**Mineurs, à écarter** (une ligne chacun) :

| # | Constat | Critère | Preuve |
|---|---|---|---|
| m1 | Écarts d'arrondi de V0 / V2 sur `stats_boot` de BP, DW et Origine | aucun (≤ 2,7e-10, sous 1e-6, aucune p touchée) | [V, `cmp3.R`] |
| m2 | Sur 8×7, non-couverture à 90 % contre σ_A^vrai de 0,36 / 0,34, contre 0,16 / 0,09 contre σ_A^règle | aucun : conséquence de la formule prescrite, déjà écrite à l'ADR 0005 point 10 ; la cible σ_A^règle a été décidée (Q-1b-1 (A)) | [V, l. 228-231] |
| m3 | Incohérence 840 / 1 200 bootstraps du balayage au § 9 du protocole | aucun (déjà relevé par `actuary-2`, écart 3) | [V] |

---

## 6. Critères de routage (§ 4.2) à signaler pour PA-2 (je les signale sans en décider l'escalade)

- **ADR 0005 modifié : oui en (B).**
  - Décision, point 4 : « ni dans la simulation du bootstrap (Q-2a-2) ».
  - Point 7.
  - Dérogation M-1 (b) de l'annotation du 22/11, absorbée.
  - Limite (iv).
  - En (A), la limite (iv) appelle quand même une annotation de fait (couverture mesurée, insensible au choix).
- **Verdict changé : aucun sur les sept cas de référence** [V]. Un changement de résultat existe (σ_boot, intervalle, textes) : tableau avant / après, visa d'`actuary`. Verdicts et p changent sur d'autres trapèzes, par construction.
- **Contrat partagé.**
  - V2 : aucun. Pas de nouveau flux sous graine, pas de nouveau champ de `usp_engine`. Le *contenu* de `plots_data$usage_sigma` et du détail M6 change, pas leur structure [V, lecture de `display_helpers.R` l. 2032-2058 : textes lus tels quels].
  - V1 : oui (second flux sous `engine_sous_graine()`).
- **Seuil « macro » : non atteint sous V2, à mon avis** [H ; l'évaluation revient à `architect`]. Seul le moteur change ; le rendu change par des textes du moteur, sans code d'affichage. `app-review` léger sur le rendu réel reste requis (plan, étape 6).
- **Validité à T = 8** : aucun résultat exact ; seule la mesure, sous un plan, tranche.
- **Désaccords** : aucun avec `audit`, avec un autre expert ni avec un ADR. La recommandation **change** une décision du mainteneur (Q-2a-2), comme le prévoit la règle R-V2 approuvée à PA-1.

---

## 7. Questions au mainteneur pour PA-2

- **Q-PA2-1 — Q-2a-2.**
  - **(a) recommandée : V2.** La colonne J−1 d'un trapèze non dégénérée est simulée avec l'estimateur direct, pour toute la simulation. La MSEP, σ_USP, σ* des réplications (règle de la réplication) et tout le calcul observé gardent la règle.
  - (b) V0 : Q-2a-2 confirmée, réserves mises à jour avec les chiffres de V0.
  - (c) V1 : sans motif mesuré, et contrat partagé.
- **Q-PA2-2 — Forme de V2.**
  - **(a) recommandée.** Le prédicat se réduit à « trapèze et colonne J−1 non dégénérée ». La dérogation M-1 (b) est absorbée. `MW_TOL_SIGMA_SIMULATION`, son commentaire et ses tests unitaires sont retirés. Les cas de `.mw_cas_sigma_direct()` se réduisent à carré / dégénéré / simulation. Les gabarits M6 et les légendes sont réécrits : textes par `actuary`, renvoi à D(5)(d)(ii) contrôlé par `regulatory` en routine, puis `app-review` léger sur le rendu.
  - (b) Garder le cas « general » et la constante comme code mort : déconseillé.
- **Q-PA2-3 — #615 (constat (1)).**
  - **(a) recommandée.** Rattacher #615 à A2 (troisième place libre). Spécification courte d'`actuary` (P1 recommandée), puis `coder-approfondi`, puis `audit`. Commit `moteur:` distinct **avant** celui de V2. Seuil 0 attendu sur les sept cas [H forte], à prouver, sinon tableau propre.
  - (b) Reporter #615 après JS2. Déconseillé : JS2 étiquette le premier état qui calcule un trapèze, et V2 accroît l'exposition de la colonne J−1.
- **Q-PA2-4 — Constats (2), (3), (4).**
  - **(a) recommandée.** (2) sans objet sous V2, gardé en appui du mécanisme. (3) clos. (4) clos, réserve MinP4 confirmée et étendue (§ 2).
- **Q-PA2-5 — Documentation et ADR.**
  - **(a) recommandée.** Annotation de l'ADR 0005 par `architect` avant l'étape 6 : point 4, point 7, dérogation M-1 (b), limite (iv) remplacée par la couverture mesurée. À l'étape 7, les quatre réserves du § 2 (PenteIntra reformulée, MinP4, Alpha 8×6 E, couverture), avec le statut épistémique du protocole et l'erratum du § 4 consigné dans `docs/revues/20261123-a2-creneau/`.
- **Q-PA2-6 — Visa.**
  - **(a) recommandée.** Tableau avant / après de `reserve2_trapeze` joint à la PR. Aucun σ_USP ni verdict changé, donc visa d'`actuary` (étape 8, `actuary-approfondi`). Mention explicite au mainteneur du changement des textes M6 / `usage_sigma`.

---

## Retour

- **Statut** : `revue requise`. La lecture est complète. La décision Q-2a-2 et le rattachement de #615 reviennent au mainteneur (PA-2).
- **Résultat** :
  - R-V2 est confirmée sur le fond : V2 recommandée, V1 et V0 écartées.
  - Trois nuances : excès résiduel de PenteIntra égal à celui du carré, plus un reste à faible r ; Alpha 8×6 E à 0,10 ; portée limitée au plan.
  - (1) : correction par #615, rattachée à A2, avant V2. (2) : sans objet sous V2. (3) et (4) : clos.
  - Effets sur `reserve2_trapeze` mesurés : σ_USP, p et verdicts identiques ; σ_boot, intervalle et textes changent.
- **Preuves**
  - *Vérifiées* :
    - tableau de la mesure (K0 à K4, 13 clés, sonde, balayage, constats (3) et (4)) et brut, relu par `strat.R` (stratification par quartile de r, V2 contre carré, McNemar exact) ;
    - `run_engine()` de `reserve2_trapeze` et `reserve2` sous V0 et V2, comparaison à la référence et entre variantes (`eff.R`, `cmp*.R`, `car.R`) ;
    - lecture de `mw_bootstrap()` l. 16393-16462, du seam l. 13882-13963 et de ses appelants (`grep`) ;
    - ADR 0005 (annotation du 21/11, décision) ; décisions E-23/11 à E-25/11 ; issue #615 ; `doc_tests_usp.tex` l. 16070-16080, 16150-16175, 20705-20714 ; tableau de #387 (carré : 0,427).
  - *Hypothèses* : mécanisme de PenteIntra (non-invariance d'échelle) et de Q1 (1 degré de liberté) ; transposition hors du plan ; σ_boot de V1 ; seuil 0 de #615 ; préférence P1 contre P2 ; seuil « macro ».
  - *Non vérifiées* : absence de littérature à T = 8 (reprise des avis antérieurs) ; σ_boot de V1 avec un flux distinct.
- **Informations manquantes** :
  - P2 (variante de correction de (1)) n'est pas mesurée.
  - La lecture stratifiée est *a posteriori* et n'entre pas dans les critères.
- **Décisions non résolues** : Q-PA2-1 à Q-PA2-6 (mainteneur) ; seuil « macro » et annotation de l'ADR 0005 (`architect`).
- **Critères déclenchés** : ADR accepté modifié en (B) ; changement de résultat (σ_boot, intervalle, textes ; pas σ_USP ni verdict sur les cas de référence) ; validité à T = 8 tranchée par simulation seule ; contrat partagé seulement sous V1. Aucune double lecture d'une source ; aucun désaccord.
- **Constats hors périmètre** : aucun marquant ; trois mineurs (m1 à m3, § 5), critère « aucun ».
- **Prochaine action recommandée** : porter Q-PA2-1 à Q-PA2-6 au mainteneur. En (a) : annotation de l'ADR 0005 par `architect`, spécification de #615 par `actuary`, puis l'étape 6 dans l'ordre suivant :
  1. commit `moteur:` de #615 au seuil 0 ;
  2. commit `moteur:` de V2 avec les textes réécrits ;
  3. régénération CI de `reserve2_trapeze`.
