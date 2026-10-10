> *Rédigé par l'agent actuary (IA), 09/10/2026, branche `claude/mesure-p-conditionnelle` (tête `1c244f7`). Spécification de la mesure #229, étape 3, soumise au point d'arrêt A1 : aucune exécution, grille comprise, avant l'approbation du mainteneur. Versionnée par la session principale ; les décisions du mainteneur à A1 seront consignées en annotation datée à la fin du document.*

**Marques utilisées** : **[V]** vérifié (source citée, ou commande exécutée et sortie lue) ; **[H]** hypothèse ; **[NV]** non vérifié (affirmation reprise d'une consultation dont les scripts n'ont pas été versionnés, ou chiffre non remesuré).

# Spécification révisée de la mesure #229 : p-value Monte-Carlo conditionnelle au régime de δ̂ (T = 8)

## 0. Objet et sources

- **Objet.** Mesurer, sans modifier le moteur, le comportement de la p_mc actuelle (V1, calibrée sur la loi marginale) et de la p_mc conditionnelle au régime de δ̂ (V3a, V3b), sans choisir la cible d'avance. Le mainteneur tranche la cible à A3 ; l'ADR 0014 consigne sa décision.
- **Sources lues.**
  - #229 : le corps et les commentaires 6081723226 et 6082311976.
  - `docs/feuille-de-route.md` : fiche « Branche #229 » du § 3, § 5 (Q-229-1 à Q-229-9), § 7.
  - Les issues #237 et #231.
  - `tests/conservatisme_interieur_t8.R` (en-tête).
  - Les tableaux `docs/tableaux/20261008-issue166-calibration-J{1,2}.md` (#221), `20261008-issue166-brut-J{1,2}.tsv`, `20261009-issue175-*`, `20261008-issue221-J{1,2}.md` et `20261008-issue220-pitman.md`.
  - Dans `R/engine.R` : `usp_bootstrap()`, `engine_p_mc()`, `.mc_p_values()`, `usp_ajuster_rapide()`, `usp_ajuster_contraint()`, `usp_regime()`, `usp_noyau()`, `usp_simuler()`, `usp_tests()` (signature), `engine_registre_tests()` (règle R3).
  - La bibliographie du `.tex` (`sec:biblio`).
- **Cadre inchangé.** Ni `R/engine.R` ni `tests/reference/` ne sont modifiés par #229. P2 (#237) entre dans le moteur à l'étape 1, et #231 à l'étape 2, avant toute exécution.

## 1. Définitions

**Régime.** r(d) vaut bord 0 si d ≤ `TOL_DELTA_BORD` (1e-6), bord 1 si d ≥ 1 − `TOL_DELTA_BORD`, intérieur sinon, comme dans #175 et `usp_regime()` **[V]**.

**Variantes**, toutes calculées sur les mêmes y** et dans la même réplication b :

| Variante | Définition |
|---|---|
| **V1** (moteur) | Rejeu de `usp_bootstrap(fit*_b, B = 999, seed = 20260831 + b)`. p par `.mc_p_values()`, avec le contexte observé (conditions `degenere` et `non_definie` du catalogue). |
| **V3a** (B fixe) | Parmi les 999 tirages de V1, les réplications retenues dont r(δ̂**) = r(δ̂*_b). Même calcul de p. C'est la p3 de #175. |
| **V3b** (B adaptatif) | V3a complétée par des tirages sur un flux distinct jusqu'à B_cible = 999 retenues dans le régime, ou jusqu'à B_max = 25 000 tirages au total (999 de V1 compris). Détail au § 5. |
| **V3h** (hybride, *option*, Q-A1-4) | V3b si δ̂*_b est intérieur, V1 sinon. Calculée sans aucun tirage supplémentaire, à partir des colonnes de V1 et de V3b. |

**Familles de statistiques.** Les 34 noms d'`USP_CATALOGUE_MC` (**[V]**, T1 de #221) se partagent en trois groupes.

- **F_T, 12 témoins**, dont le niveau est indépendant du régime selon la consultation « théorie » : AD, CvM, KS, SW, Lillie, Intercept, CUSUM, LB1, Runs, Runsr, Smirnov, CoxStuart. Cette indépendance est un constat de simulation **[NV]**, et T1 bis de #221 la nuance déjà : LB1 au bord 1 à 0,134, Smirnov à l'intérieur à 0,013 **[V]**.
- **F_R, 22 statistiques dépendantes du régime** : les 34 moins F_T.
- **F_8 ⊂ F_R**, les huit de #175 : BP, BP79, GQ, BF, Grubbs, Grubbsr, DAgo, JB **[V]**.

Le script déclare F_T et F_8 en constantes, avec leur source, et vérifie que F_T et F_R forment une partition des 34 noms du catalogue.

## 2. Critère réécrit, fixé avant toute exécution

Ce texte est reporté sans modification dans le script et dans le T0 des tableaux.

### 2.1 Grandeurs

- **Décision.** Pour un jeu j, un seuil α ∈ {0,10 ; 0,05}, une statistique s et une variante v : D_v(b) = 1 si p_v(b) < α. **Une p absente compte comme un non-rejet** dans T1, T1 bis et P.
- **Population du critère.**
  - J2 et J3 : les R réplications.
  - **J1 : les seules réplications dont δ̂* est au bord** (bord 0 ∪ bord 1 ; 1 925 sur 2 000 dans #221 **[V]**).
  - Les 75 réplications intérieures de J1 sont calculées pour les trois variantes et rapportées à titre **descriptif**, hors critère. C'est la lecture proposée de « J1 aux bords seulement » : Q-A1-2.
- **Taux marginal** τ_v = k / n, avec l'IC de Clopper-Pearson à 95 % et les classes de #166 : compatible ; écart mineur ; écart non tranché ; distorsion matérielle (IC disjoint de la bande de Bradley [α/2 ; 3α/2]), avec son côté.
  - Lois discrètes (†) : référence lissée de #166 à B = 999 pour V1 et V3b.
  - Pour V3a, les références discrètes sont **descriptives**, son B effectif étant variable.
- **Taux par régime** τ_v^r : même définition sur les réplications dont r(δ̂*) = r. Une cellule est évaluable si n^r ≥ 100 ; sinon elle est « non évaluable ».
- **Comparaison appariée** de v à V1 sur les mêmes réplications :
  - n01 : v rejette, V1 non ; n10 : V1 rejette, v non ;
  - **test de McNemar exact** : test binomial bilatéral de paramètre 1/2 sur les n01 + n10 paires discordantes, comme pour #221 (`.tex`, § `sec:calibration-mc`) **[V]** ;
  - **multiplicité** : correction de Holm (1979) au niveau 0,05, à l'intérieur de chaque famille de tests désignée ci-dessous (Q-A1-5).

### 2.2 Conditions

Chaque condition est évaluée mécaniquement pour **V3b, V3a et V3h si retenue**, et pour V1 quand elle a un sens absolu.

**C1, calibration marginale (en apparié).** Sur J1 (bords), J2 et J3, aux deux seuils :
- **(C1a), absolu, sur les 34 statistiques** : la variante n'a pas de distorsion matérielle marginale, sauf si V1 en a une du même côté, et alors sans l'aggraver (règle (b) de #175 : pas de disjonction du côté opposé, pas de taux au-delà de l'IC de V1 du côté de la distorsion).
- **(C1b), aggravation libérale, sur F_R** (Holm par famille (jeu, α), 22 tests) : on ne doit pas avoir à la fois un McNemar significatif après Holm, n01 > n10, et une borne basse de l'IC de τ_v supérieure à α.
- **(C1c), descriptif** : aggravation conservatrice (McNemar significatif, n10 > n01, borne haute de l'IC de τ_v inférieure à α). Elle n'est pas éliminatoire, son coût relevant de C4 ; c'est l'asymétrie de la condition 1 d'origine.

**C2, calibration conditionnelle** (cellules évaluables) :
- **(C2a), correction, au sens de #175, à α = 0,10.**
  - Au régime intérieur de J2 : au moins 5 des 8 statistiques de F_8 ont un IC de V1 disjoint de la bande et un IC de la variante non disjoint.
  - Au régime intérieur de J3 : même règle, avec un seuil de min(5, m₃), où m₃ est le nombre de statistiques de F_8 dont l'IC de V1 y est disjoint.
- **(C2b), aucune distorsion créée, inversée ni aggravée**, sur toutes les cellules (J1 bord 0 et bord 1 ; J2 et J3, trois régimes) × F_R × deux seuils. Règles (a) et (b) de #175 : si l'IC de V1 n'est pas disjoint, celui de la variante ne l'est pas non plus ; s'il l'est, la variante n'est pas disjointe du côté opposé et son taux ne dépasse pas l'IC de V1 du côté de la distorsion.
- Le McNemar par régime est rapporté (Holm par famille (jeu, régime, α)), sans entrer dans C2.

**C3, p absentes.** Par jeu (J1 sur ses bords), la part des réplications où la p de la variante manque pour au moins une statistique de F_R, **alors que celle de V1 existe**, est au plus 1 %. Les motifs communs à V1 (statistique dégénérée, observée non finie) sont exclus.

**C4, puissance (partie P, § 6).**
- **(C4a), non-infériorité.** Pour chaque scénario et chaque seuil, aucune statistique de F_R n'a de McNemar significatif après Holm (famille (scénario, α), 22 tests) avec n10 > n01. On compte toutes les réplications du scénario.
- **(C4b), gain.** Pour au moins une famille d'alternatives, au moins une statistique de son ensemble cible (§ 6) a, **sur les réplications à δ̂* intérieur**, un McNemar significatif après Holm (famille (scénario, α = 0,10, ensemble cible)) avec n01 > n10.
- **(C4c), descriptif** : puissance par régime, bords compris, et taux bruts rapportés avec le niveau mesuré de chaque variante (T1 du même jeu).

**C5, témoins (validité de la mesure, et non condition sur une variante).** Pour chaque jeu et chaque seuil, McNemar V3b contre V1 sur les 12 statistiques de F_T, avec Holm sur la famille. Un témoin significatif est un **point d'examen avant la lecture d'A3** : soit défaut de la mesure, soit l'indépendance au régime ne tient pas pour ce témoin.

### 2.3 Ce qui départage la cible à A3

`actuary` propose et le mainteneur tranche (ADR 0014).

| Profil | Résultat de V3b (ou de V3h) | Lecture proposée |
|---|---|---|
| **D1** | C1, C2, C3, C4 remplies | La variante **domine** V1 quelle que soit la cible : proposer le changement (issue nouvelle, A4). |
| **D2** | C2, C3, C4 remplies ; C1 en défaut | **Arbitrage de cible.** Cible conditionnelle : la variante. Cible marginale : V1 conservée et documentée. Pièces : distorsion marginale créée (taux, IC, McNemar), distorsion conditionnelle de V1 à l'intérieur, effets T2. |
| **D3** | C1, C2, C3 remplies ; C4 en défaut (perte de puissance, attendue aux bords) | **Arbitrage entre calibration conditionnelle et puissance.** Si V3h est en D1, la proposer. |
| **D4** | C2 en défaut | La variante n'atteint pas la cible qui la motive : conserver V1 et documenter. |
| **D5** | C3 en défaut | Variante non implémentable telle quelle : conserver V1 et documenter, ou proposer une issue sur B_max. |

Compléments :
- Si **V3a** a le même profil que V3b, elle devient la candidate moins coûteuse : aucun allongement de `run_engine()`.
- Un témoin de C5 en défaut et non expliqué suspend la lecture.
- T2 (verdicts, multiplicité) est rapporté sans critère.

### 2.4 Hors critère et descriptif

- J1 intérieur, T1 bis à n^r < 100, taux sur les seules p définies, T2, V3a sur les références discrètes.
- Le niveau de V1 par régime à l'intérieur est le constat de départ (#175) : il n'est pas rejugé.

## 3. Jeux, R et graines

### 3.1 J1 et J2

J1 et J2 sont inchangés : modèle ajusté FIT0 = `usp_ajuster()` sur le jeu observé ; jeux simulés par l'expression YSIM de #72, sous 20260927 ; bootstrap de la réplication b sous 20260831 + b ; **R = 2 000** **[V]**, T0 de #221.

### 3.2 J3, plan synthétique en deux grappes

**Définition proposée** (Q-A1-3) :
- volumes x₃ = (10 ; 10,5 ; 95 ; 92 ; 11 ; 11,5 ; 98 ; 90) ;
- δ₀ = 0,60 ;
- β₀ = 0,70 ;
- γ₀ = ln(0,10 / 0,70) = −1,945910, soit σ₀ = β₀ e^{γ₀} = 0,10, l'écart-type standard du segment 1 **[V]** (T0 de #221 : « σ standard = 0.1 ») ;
- FIT0_J3 = (β₀, x₃, π = `usp_pi(δ₀, γ₀, x₃, x̄₃)`, T = 8, δ₀, γ₀), passé tel quel à `usp_simuler()`. **Aucun jeu observé.**

**Justification.**
1. Amplitude max/min = 9,8 < 10, deux grappes de quatre années, comme décidé le 09/10.
2. δ₀ est au centre de [0,5 ; 0,7]. P(intérieur) y est quasi plate. Mesure courte faite pendant la rédaction **[V]** (R = 500, `usp_ajuster()`, IC à 95 % ≈ ±0,044) :

   | δ₀ | γ | P(intérieur) | P(bord 0) | P(bord 1) |
   |---|---|---|---|---|
   | 0,5 | −2,32 | 0,526 | 0,322 | 0,152 |
   | 0,6 | −2,32 | 0,518 | 0,280 | 0,202 |
   | 0,7 | −2,32 | 0,538 | 0,226 | 0,236 |

3. Effet de σ et des variantes du plan, à δ₀ = 0,6 :
   - σ a peu d'effet : 0,522 à σ₀ = 0,10 et 0,528 à σ₀ = 0,20, conformément à l'approximation à petit σ de la consultation **[V]** pour ces points ;
   - variantes du plan : grappes exactes (10 ; 95), 0,544 ; partage 2/6, 0,508 ; amplitude 4,9, 0,394 ; partage 6/2, 0,310. Le partage 4/4 à amplitude maximale est le meilleur des plans essayés.
4. **Le régime intérieur est le plus fréquent** (≈ 0,52, contre ≈ 0,27 et 0,20) **[V]**, mesure courte à confirmer par la grille.
5. Volumes **alternés par paires** (P P G G P P G G) :
   - la coupure de GQ (petits contre gros volumes) est orthogonale aux moitiés temporelles ;
   - SpearVol et SpearTps, supF et CUSUM ne sont pas confondus avec le volume ;
   - l'ordre ne change pas δ̂, invariant par permutation des couples (x, y).
6. β est un paramètre de position exact, et sa valeur est sans effet **[NV]** (consultation, « vérifié à 1e-16 »).

**Écart à signaler.** La consultation annonçait 0,43 à 0,46 pour « deux grappes d'amplitude 9,5 », la mesure courte donne 0,51 à 0,54. Le plan de la consultation n'est pas connu, faute de script versionné ; la grille tranche avec 2 000 jeux.

**Graines de J3 :** celles de J1 et J2 (jeux sous 20260927, bootstrap sous 20260831 + b), soit des nombres aléatoires communs avec J1 et J2.

**R = 2 000**, soit ≈ 1 040 réplications intérieures attendues **[H]** : demi-largeur de l'IC ≈ 0,018 à 0,10.

### 3.3 Graines nouvelles de #229

Toutes sont au-dessus de chaque graine et de chaque plage trouvées dans `R/engine.R`, `tests/*.R` et `tests/unitaires/*.R` à `1c244f7`. Le maximum rencontré est 20760831 : réseau 20260831 + 1000 k, k ≤ 500, de `tests/puissance_t8.R` **[V]**, par recherche des graines littérales et des décalages ; la recherche n'est pas exhaustive pour les graines calculées, et le T0 refait le contrôle.

| Flux | Graine |
|---|---|
| Flux V3b de la réplication b | **20800000 + b** (b ≤ 2 000) |
| Jeux des scénarios P | **20810000 + s** (s = 1 à 6 ; 7 à 9 pour l'option J3) |
| Couche de référence de la grille | **20820000 + 100 p + i** (profil p ∈ {1, 2, 3}, nœud i ∈ 1..12) |

- Collisions héritées, déclarées en T0 : la réplication 96 a pour graine de bootstrap 20260927 (celle des jeux), et la réplication 70 a 20260901 (`SEED_LOI_NULLE_SW`) **[V]**, T0 de #221.
- Aucune autre collision à l'intérieur de #229 **[V]** pour les plages ci-dessus.
- Le T0 liste toutes les graines du script et refuse une collision non déclarée.

## 4. Étape 4 : grille semi-analytique, et règle A2

### 4.1 Définition

Le calcul se fait sans bootstrap emboîté. Il repose sur l'approximation de la consultation : à petit σ, la nuisance effective est δ seul **[NV]** (distance de Kolmogorov ≤ 0,045).

- **Couche de référence**, par profil de volumes (x de J1, de J2, de J3) :
  - γ_ref = γ̂ du jeu (J1 : −1,93433 ; J2 : −2,31999 **[V]**, T0 de #221 ; J3 : γ₀) ;
  - **12 nœuds** δ ∈ {0 ; 0,05 ; 0,15 ; … ; 0,95 ; 1}, soit pas de 0,1 et les deux bords exacts ;
  - **M = 3 000 jeux par nœud** (1 500 dans la consultation ; le doublement coûte quelques minutes, **[H]**) ;
  - pour chaque jeu : simulation sous (β, γ_ref, δ), réajustement par `usp_ajuster_rapide(x, y, δ, γ_ref)` (celui du bootstrap), régime, 34 statistiques ;
  - on en tire, par nœud, la loi marginale F_δ, les lois par régime F_{δ|r} et q_δ(r) = P(r | δ).
- **Couche « vérité »**, par jeu : les **2 000 premières lignes de l'YSIM de la mesure elle-même** (mêmes jeux que l'étape 6).
  - Ajustement par `usp_ajuster()`, comme `run_engine()`, puis δ̂*_b, r_b et S_obs,b.
  - p̃1 = 1 − F_{δ̂*_b}(S_obs) et p̃3 = 1 − F_{δ̂*_b | r_b}(S_obs). Les queues `bas` et `deux` sont lues au catalogue ; interpolation linéaire en δ entre les deux nœuds encadrants ; nœud exact aux bords.
  - Cette couche donne des prédictions **appariées réplication par réplication** à #221 et à la mesure.
- **Couche des alternatives** : les jeux des scénarios de P (§ 6, mêmes graines), avec les p̃ lues dans la couche de référence du profil.
- **Coûts prédits** : q̂_b = q_{δ̂*_b}(r_b), d'où le nombre de tirages de V3b, ≈ min(999 / q̂_b, 25 000), et les p absentes prédites (25 000 · q̂_b < 50).

### 4.2 Validation de la grille, avant toute prédiction

| Contrôle | Contenu |
|---|---|
| (g1) | Écarts aux **102 cellules de T1 bis de #221 par jeu et par seuil** (J1, J2), aux 68 cellules de T1 par jeu, et aux cellules V1 et V3a de #175 (J2 : 13 cellules ; J1 : bord 0, plus l'intérieur à titre descriptif), aux deux seuils. La consultation annonçait un écart moyen de 0,012 et maximal de 0,041 sur J2, J1 moins bien prédit **[NV]**. |
| (g2) | Concordance appariée des décisions p̃1 contre p_mc de #221 (J1, J2) et p̃3 contre p3 de #175. |
| (g3) | Marge e*_{j,α} = écart absolu maximal de (g1) pour le jeu et le seuil (J3 reprend celle de J2). Elle inclut le bruit des taux mesurés, donc elle est prudente. |
| (g4) | Régimes de J3 sur la couche « vérité » (2 000 jeux), avec l'IC de Clopper-Pearson. |
| (g5) | Empreinte sans commentaires (#231) du moteur citée ; elle doit être celle de l'étape 6. |

### 4.3 Sorties de la grille

`docs/tableaux/<AAAAMMJJ>-issue229-grille.md` et `-grille-brut.tsv`, écrits directement : exécution courte, `garde_ecrasement()`, commit propre cité, `git worktree`. Contenu :
- probabilités des régimes par nœud et par profil ;
- validation (g1) à (g4) ;
- T1 et T1 bis prédits pour V1 et V3 (B infini), par jeu et par seuil ;
- conditions C1 à C4 prédites, avec la marge, pour chaque scénario de P et par régime ;
- coûts et p absentes prédits.

Durée : ≲ 1 h CPU **[H]** (§ 9).

### 4.4 Règle d'arrêt A2

**Échec prédit franc** : la grandeur prédite franchit le seuil de la condition de plus de e*. Par exemple, taux prédit < α/2 − e* ou > 3α/2 + e*, ou différence de puissance prédite V1 − V3 > e*. Tout échec franc est un **point de décision du mainteneur** (arrêt ou réduction) ; recommandation par cas :

| Prédiction | Recommandation d'`actuary` |
|---|---|
| (g1) hors tolérance : e* > 0,05 sur J2 | La grille ne prédit pas : A2 se lit sans elle, mesure complète. |
| C2 en échec franc (J2 ou J3 intérieur) | **Arrêt** de la mesure emboîtée : V3 n'atteint pas sa cible. Conclure « conserver et documenter » sur #175 et la grille. |
| C3 en échec franc sur un jeu | **Réduction** : jeu en cause en descriptif, ou B_max revu (décision). |
| C1 seule en échec franc | **Poursuite complète** : c'est l'arbitrage de cible (D2) que la mesure doit chiffrer. |
| C4 en échec franc (perte de puissance aux bords) | **Poursuite** ; V3h retenue (si Q-A1-4 l'a écartée, la rouvrir) ; P étendue à J3 si C4b n'est pas prédite décelable sur J2. |
| Aucun échec franc, C4 remplie avec une marge > 2 e* | **Réduction possible de P** : un scénario par famille. |
| Puissance prédite de V1 hors de [0,2 ; 0,8] pour toute la cible d'une famille | Intensité de la famille ajustée avant l'étape 6, la décision du mainteneur à A2 fixant les nouvelles valeurs. |

## 5. V3b : réalisation

Pour la réplication b (fit*_b, r_b) :

1. **V1** : rejeu du bootstrap du moteur (999 tirages). L'ensemble A comprend les tirages retenus (réajustement abouti, statistiques sans erreur) dont r(δ̂**) = r_b. V3a se calcule sur A.
2. **Tirages ajoutés** sous `engine_sous_graine(20800000 + b, …)`, tant que |A| < 999 et que le total est ≤ 25 000 :
   - y = `usp_simuler(fit*_b)` ;
   - f = `usp_ajuster_rapide(x, y, δ̂*_b, γ̂*_b)` ; un échec ou un régime différent fait passer au tirage suivant (**P1** : aucune statistique calculée dans ce cas) ;
   - sinon, `.stats_bootstrapables()` ; une erreur fait passer au suivant, sinon le tirage est ajouté à A.
3. p par `.mc_p_values(S[A, ], stats_obs, USP_CATALOGUE_MC, e_obs)`. **p absente avec son motif si B effectif < `B_MIN_DEGENERESCENCE` (50)** (`engine_p_mc()` **[V]**).
4. Rapportés :
   - le total des tirages, |A| et le motif d'arrêt (cible ou B_max) ;
   - par statistique : B effectif, p_min = 1/(B_eff + 1) (2/(B_eff + 1) en bilatéral), err_mc sur B_eff.

**Validité de l'arrêt.** Les couples (indicatrice de sélection I_j, statistique S_j) sont i.i.d. La sous-suite des S retenus est i.i.d. de loi S | I = 1, et indépendante des positions de sélection. L'arrêt ne dépend que de ces positions. Donc, conditionnellement au B effectif N, les N statistiques retenues sont i.i.d. sous la loi conditionnelle. L'arrêt adaptatif n'ajoute ainsi aucun biais à un test de Monte-Carlo à B = N fixé.

Argument élémentaire rédigé ici, sans référence **[V]** pour la logique. Il ne rend pas la p exacte : la loi nulle est simulée à paramètres estimés (`.tex`, citant Dwass, 1957 ; Hope, 1968).

**Aucune statistique ne consomme d'aléa du flux appelant** : la loi nulle de SW passe par `engine_sous_graine()`, qui restaure l'état **[V]** (`CLAUDE.md`, « Reproductibilité »). P1 ne change donc aucun résultat ; le contrôle (s1) le vérifie.

## 6. Partie P : puissance

**Base** : volumes et modèle ajusté de **J2**. Le dessin est réel ; 77 % de bords, où une perte de V3 est prédite ; 23 % d'intérieur.
- R = 1 000 par scénario.
- Bootstrap sous 20260831 + b, flux V3b sous 20800000 + b, jeux sous 20810000 + s.
- Variantes V1, V3a, V3b (et V3h).
- **6 scénarios**, deux par famille (Q-A1-6) :

| s | Famille, ensemble cible | Modèle (ln Y_t = μ_t + s_t ε_t) | Intensités |
|---|---|---|---|
| 1, 2 | **H**, hétéroscédasticité hors famille réglementaire (Var(Y) ∝ x^k) ; cible : BP, BP79, White, GQ, BF | CV_t = c₀ (x_t / x̄)^{(k−2)/2}, c₀ = e^{γ̂_J2}, s_t² = ln(1 + CV_t²), μ_t = ln(β̂ x_t) − s_t²/2, ε ~ N(0, 1). La famille réglementaire correspond à k ∈ [1, 2] (k = 1 pour δ = 0, k = 2 pour δ = 1, à petit σ) **[V]** (dérivé de `usp_pi()` et `usp_noyau()`). | k = 0 ; k = 3 (deux côtés de la famille ; rapport des écarts-types √6 sur l'étendue de J2) |
| 3, 4 | **C**, contamination ; cible : Grubbs, Grubbsr, DAgo, JB, SF | Modèle ajusté de J2 ; une année t* tirée uniformément ; ln Y_{t*} augmenté de λ / √π_{t*} | λ = 3 ; λ = 4 |
| 5, 6 | **A**, asymétrie ; cible : DAgo, JB, SF, Grubbs, Grubbsr | Modèle ajusté de J2, ε = (χ²_ν − ν) / √(2ν) (asymétrie √(8/ν)) | ν = 8 (asymétrie 1) ; ν = 2 (asymétrie 2) |

- **Option P-J3** : trois scénarios de plus, l'intensité la plus faible de chaque famille sur FIT0_J3 (graines 20810007 à 20810009). Ils sont décidés à A2 si C4b n'est pas prédite décelable sur J2.
- **Paramètres proposés [H]** : la grille prédit leur puissance, et A2 peut les ajuster.
- Ordre des tirages dans chaque flux (matrice ε par lignes, puis t*) fixé dans l'en-tête du script.
- Le niveau de référence de chaque variante est lu dans T1 du même jeu.

## 7. Leviers et contrôles

**Leviers.**
- **P2** est dans le moteur (#237, étape 1).
- **P1** : comme au § 5.
- **P3** : `usp_ajuster_contraint()` est omis du rejeu ; il ne consomme pas d'aléa **[V]** (`usp_bootstrap()`, commentaire et code). Il est rétabli sur l'échantillon de (i2). `sigma_boot_restreint` est hors périmètre (#45).
- **P4** : avant l'étape 6, mesure du débit à 2, 3 et 4 tranches concurrentes (≈ 10 min, 3 réplications de J2 intérieur chacune). On retient le nombre de tranches au plus grand débit agrégé, consigné dans le JOURNAL et le T0. On réévalue si la durée par réplication d'une tranche dérive de plus de 25 %.

**Contrôles.** Un échec met la ligne INTEGRITE à ECHEC, et `--combiner` refuse.

| Contrôle | Contenu |
|---|---|
| (a) | J1 observé par `run_engine(seed = 20260831)` conforme à `tests/reference/premium.rds` **régénéré par P2**, par `comparer_objets()`. |
| (b) | Noms et sens de rejet lus dans `USP_CATALOGUE_MC`. F_T et F_R forment une partition des 34. |
| (c) | YSIM identique à l'expression de #72, lue par `parse()`. J1 et J2 : régimes de δ̂*_b identiques à ceux des valeurs brutes de #221. J3 : régimes identiques à ceux de la couche « vérité » de la grille (c-J3). |
| **(i1)**, lecture après P2 (réponse proposée à **Q-229-4**) | Pour J1 et J2 : p V1 = p_mc de #221 (`%.17g`) **au bit près**, pour chaque (b, s). Une discordance n'est admise que si elle est **expliquée et listée** (b, s, p de #221, p de V1, cause) : (1) par (h2), quasi-égalité d'une statistique de P2 ; (2) par un changement de rétention d'un tirage (appel des statistiques en erreur avant ou après P2), recalculé par la contre-implémentation. Toute discordance non expliquée est un **échec bloquant**. Les taux de T1 sont ceux du moteur mesuré, jamais remplacés par ceux de #221. Attendu : 0 discordance **[H]**. Fondement : depuis `26e7496` (commit de #221), les blocs modifiés hors des fonctions `mw_*` ne touchent que des constantes et un appel Merz-Wüthrich ; aucun calcul lognormal n'est changé avant P2 **[V]** (`git diff 26e7496 HEAD -- R/engine.R`). Le chemin lognormal ne change donc qu'à l'arrondi de P2 (≤ 2,7e-14 relatif **[NV]** ; 1,6e-15 sur White, mesuré par `architect`). |
| (i1) pour J3 | Remplacé par (i2) et (h1) (décision du 09/10). |
| (i2) | `identical()` avec `usp_bootstrap()` (champs de #175 : `stats_obs`, `p_mc`, `err_mc`, `B_effectif`, `granularite_stat`, `motif_mc`, `sigma_boot`, `delta_boot`, `gamma_boot`, `sigma_boot_restreint`, `n_echec_restreint`, `z_boot`) sur l'échantillon : jeu observé, première réplication et première réplication intérieure de chaque tranche. |
| (i3) | **Empreinte sans commentaires de #231** égale dans toutes les tranches, la combinaison, la grille et le JOURNAL ; md5 du fichier entier cité. Le md5 du T0 de #221 est cité **pour mémoire**, le lien à #221 passant par (i1) et (c), non par l'empreinte : la comparer à celle de #221 échouerait par construction après P2. |
| (s1) | Sur l'échantillon de (i2) : rejeu complet des tirages ajoutés **sans P1** (34 statistiques à chaque tirage). p de V3b, total des tirages et B effectifs identiques. |
| (h1) | Sur tous les tirages de la première réplication de chaque tranche (V1 et ajouts) : les six statistiques de P2 égales à leur contre-implémentation `lm()` / `anova()` à 1e-12 relatif près, motifs et NA identiques. |
| (h2) | Pour chaque réplication et chacune des six statistiques : nombre de tirages tels que \|S_sim − S_obs\| ≤ 1e-9 · max(1, \|S_obs\|), listé en T3. Pour toute discordance de (i1) ou de (v3a) : recalcul par la contre-implémentation et recomptage, qui doit redonner la p de #221 ou de #175. |
| (v3a) | V3a = p3 de #175 (`20261009-issue175-brut.tsv`) sur les couples (b, s) communs, avec B3 égal. Discordance admise si elle est expliquée par (h2) ou par l'angle mort du sous-catalogue de #175, et listée. |
| (t2) | J1 et J2 : p retenue des lignes de T2 recalculées avec V1 = `p_retenue` de #221, sur les 48 lignes du périmètre, au bit près, avec les mêmes explications. Ce contrôle valide le chemin de T2 (§ 8). |
| (d) | Invariants : \|A\| ≤ 999, B effectifs ≤ retenues, total ≤ 25 000, arrêt « cible » si et seulement si \|A\| = 999. |

**Dépendance pratique (Q-A1-8).** (h1) et (h2) exigent la contre-implémentation `lm()` / `anova()` de P2 dans un fichier qu'on peut charger par `source()`. Recommandation : la placer dans `tests/outils_tests.R` dès l'étape 1 (#237), plutôt que la copier dans le script.

**T2 sans toucher au moteur.** Le script appelle `usp_tests(fit*_b, boot_v, alpha = 0,10, theta_equiv = 0,10, methode = "premium", lr_delta = NULL, permutation_pente = usp_permutation_pente(x, y*_b, seed = 20260831 + b), …)`.
- boot_v est la liste de V1 dont `p_mc`, `err_mc`, `B_effectif`, `granularite_stat` et `motif_mc` sont remplacés par ceux de la variante.
- La règle R3 joue : une p de V3b absente peut y laisser place au repli asymptotique nommé, compté à part. Dans T1, une p absente reste un non-rejet.
- Les lignes du rapport de vraisemblance sur δ et la largeur de l'IC à δ fixé sont hors périmètre (#45), comme dans #221.
- La règle R4 en vigueur au commit mesuré est citée (C-229-5).

## 8. Tranches, sorties, journal

**Scripts.**
- `tests/grille_regime_t8.R` (étape 4).
- `tests/p_conditionnelle_regime_t8.R` (étapes 5 et 6), avec la mécanique de `tests/conservatisme_interieur_t8.R` : `--tranche i/K`, `--combiner`, `--ecrire`, `--remplacer`, `--brut`, `garde_ecrasement()`, `commit_depot()`, `motifs_non_versionnable()`.
- R de base + stats, hors CI.

**Modes.** `--jeu J1|J2|J3 --tranche i/K` (T1 à T3) ; `--scenario H0|H3|C3|C4|A8|A2[|…J3] --tranche i/K` (P).

**Tranches indépendantes et reprenables.**
- La tranche i/K couvre b ∈ [(i−1)R/K + 1 ; iR/K].
- Toute réplication ne dépend que de (jeu ou scénario, b) : ligne b de l'YSIM, graine 20260831 + b, flux 20800000 + b. Une tranche relancée sur la même plateforme est donc **la même tranche**.
- `--combiner` refuse : une couverture de 1..R qui n'est pas exactement une fois ; des PARAMETRES, CONTEXTE, STATS ou REPCOLS différents ; un commit, une plateforme, une empreinte (#231) ou un générateur différents ; une tranche sans INTEGRITE OK ou sans FIN.
- Avec `--journal FICHIER`, `--combiner` refuse aussi un md5 de tranche différent de celui du JOURNAL.

**Découpage proposé.** K = 8 par jeu (250 réplications, ≈ 1 à 1,6 h d'horloge par tranche, **[H]**) ; K = 4 par scénario. Ordre : J2 → J3 → J1, combinaison et commit (Q-229-5) ; puis P, combinaison et commit.

**Lignes machine.** Comme #175 (PARAMETRES, TRANCHE, CONTEXTE, STATS, REPCOLS, OBS, DUREE, INTEGRITE, NREP, REP, FIN). Une ligne REP contient :
- b, δ̂*_b, r_b ;
- les comptes de δ̂** par régime sur les 999 tirages, le total des tirages de V3b et le motif d'arrêt ;
- B effectifs, p1, p3a, p3b en `%.17g` et codes de motif, par statistique ;
- codes de verdict de T2 (V1, V3a, V3b), quasi-égalités (h2) et durée.

**Nommage dans la sauvegarde.** `sauvegarde/issue229/<jeu|scénario>-<ii>de<KK>.txt` et `.err`, plus `JOURNAL.md`, avec le contenu fixé par la règle de la branche de sauvegarde : commande, début et fin UTC, commit mesuré, md5 et empreinte de #231, débit de P4, incidents, md5 de chaque fichier.

**Sorties définitives**, nouvelles et jamais patchées :
- `docs/tableaux/<AAAAMMJJ>-issue229-p-conditionnelle-regime.md` et `-p-conditionnelle-regime-brut.tsv` (T0 à T3, J1 à J3) ;
- `docs/tableaux/<AAAAMMJJ>-issue229-p-conditionnelle-puissance.md` et `-p-conditionnelle-puissance-brut.tsv` (P).

**Contenu des tableaux.**
- **T0** : provenance, texte du critère, graines et collisions, débit, liste de (i1), de (v3a) et de (t2).
- **T1** : marginal par jeu, seuil, statistique et variante, avec McNemar et Holm.
- **T1 bis** : par régime.
- **Évaluation mécanique** de C1 à C5 et profil D1 à D5 par variante, **sans conclure**.
- **T2** : verdicts des 51 lignes, agrégats « au moins un ALERTE ou ECHEC » et « au moins un ECHEC », par régime.
- **T3** : B effectifs, tirages, p absentes, (h2) et durées par régime ; jeux observés J1 et J2.
- **P** : puissance, McNemar, par régime, C4.

**Taille du brut** estimée à 10 à 15 Mo pour T0 à T3 et 3 à 5 Mo pour P **[H]**, contre 2,5 Mo par jeu pour #221 **[V]** (Q-A1-9). Les matrices de statistiques simulées ne sont pas conservées.

## 9. Coût réestimé

**Mesures de coût par appel.**
- Conteneur de session (09/10, J2, 400 appels, avant P2) **[V]** : `usp_ajuster_rapide()` 2,12 ms ; `usp_ajuster_contraint()` 0,49 ms ; 34 statistiques 21,1 ms ; `usp_ajuster()` 54,8 ms ; `usp_permutation_pente()` 106 ms.
- Consultation **[NV]** : 0,8 ; 0,11 ; 11,5 ms. Ce conteneur est donc ≈ 2 fois plus lent.
- Après P2, les 34 statistiques sont estimées à 30 à 36 % de leur coût, d'après la consultation **[H]** : 4,4 ms (profil A, consultation) ou 7,0 ms (profil B, ce conteneur).

**Tirages de V3b, calculés sur les comptes de δ̂** du brut de #175** **[V]** :

| Jeu, régime | q médian | Tirages moyens | Statistiques ajoutées (moyenne) | B_max atteint |
|---|---|---|---|---|
| J2 intérieur | 0,216 | 4 641 | 783 | 0 % |
| J2 bord 0 | 0,609 | 1 642 | — | — |
| J2 bord 1 | 0,498 | 2 000 | — | — |
| J1 bord 0 | 0,518 | 1 935 | — | — |
| J1 intérieur | 0,040 | 23 381 | — | 48 % (B_eff ≥ 625) |

- **Aucune p absente prédite** sur J1 et J2 (q minimal 0,025, donc B_eff ≥ 625) **[V]** sur ces comptes. C3 ne paraît pas menacée.
- J1 au bord 1 n'a pas été rejoué par #175 ; on prend q ≈ 0,5 (observé 490/999) **[H]**. Pour J3, q est pris comme les bords de J2 **[H]**, à confirmer par la grille.

**Coûts par étape** (horloge sur 4 vCPU au débit de 2,2 à 3 fois un cœur) :

| Étape | CPU, profil A | CPU, profil B | Horloge, A | Horloge, B |
|---|---|---|---|---|
| 4, grille | ≈ 0,3 h | ≈ 0,8 h | < 15 min | < 25 min |
| 5, essais et calibration P4 | ≈ 0,5 h | ≈ 1 h | ≈ 30 min | ≈ 45 min |
| 6, J2 | 5,1 h | 9,1 h | | |
| 6, J1 (intérieur descriptif compris : 0,5 h / 1,1 h) | 5,2 h | 9,4 h | | |
| 6, J3 **[H]** | ≈ 5 h | ≈ 9 h | | |
| 6, T2 (0,3 à 1 s par réplication) **[H]** | + 0,5 à 1,7 h | idem | | |
| 6, contrôles par tranche, 24 tranches **[H]** | + 1,2 à 2,4 h | idem | | |
| **6, T0 à T3** | **≈ 17 h** | **≈ 32 h** | **5,7 à 7,7 h** | **10,7 à 14,5 h** |
| **6, P (6 scénarios)** | **≈ 15 h** | **≈ 27 h** | **5 à 7 h** | **9 à 12 h** |
| Option P-J3 (3 scénarios) | + 7 h | + 13 h | + 2,4 à 3,3 h | + 4,4 à 6 h |
| **Total de base** | **≈ 33 h** | **≈ 60 h** | **≈ 11 à 15 h** | **≈ 21 à 27 h** |

- Le profil de la machine d'exécution est mesuré à l'étape 5 (P4), et la durée est annoncée au mainteneur avant le lancement, comme le prévoit la fiche.
- Sous les alternatives, le régime se déplace vers les bords **[H]**, ce qui allège P.

## 10. Références

| Référence | Usage ici | Statut |
|---|---|---|
| Q. McNemar, « Note on the sampling error of the difference between correlated proportions or percentages », *Psychometrika* 12(2), 1947, p. 153-157 | Test apparié de deux proportions corrélées | **[V]**, notice bibliographique. La version exacte (binomiale conditionnelle sur les paires discordantes) est la forme déjà employée par #221 (`.tex`) ; elle ne lui est pas attribuée ici en propre. |
| S. Holm, « A simple sequentially rejective multiple test procedure », *Scandinavian Journal of Statistics* 6(2), 1979, p. 65-70 | Contrôle du risque global par famille | **[V]**, notice bibliographique. |
| Clopper et Pearson (1934) ; Bradley (1978) ; Dwass (1957) et Hope (1968) ; Jöckel (1986) et Marriott (1979) | IC ; bande ; test de Monte-Carlo à B fini ; perte de puissance à B fini | **[V]**, présence et portée consignées dans `sec:biblio` du `.tex`. Articles non relus. |
| Cox (1958), Buehler (1959), Andrews (2000) | Contexte de la consultation « théorie » | Non cités comme fondement **[NV]** pour Cox et Buehler, que la consultation qualifie elle-même de lecture de seconde main pour une partie. |

**Aucune référence ne fonde V3 à T = 8** (#175, consultation) : la mesure est l'unique preuve visée.

## Questions au mainteneur pour A1

1. **Q-A1-1, critère.** Approuver C1 à C5 et les profils D1 à D5 (§ 2), fixés avant toute exécution, grille comprise.
2. **Q-A1-2, J1 « aux bords seulement ».** Lecture proposée : le critère porte sur les 1 925 réplications à δ̂* au bord, et les 75 réplications intérieures sont calculées, V3b compris (≈ 0,5 à 1,1 h CPU), à titre descriptif. Alternative : ne pas calculer V3b à l'intérieur de J1.
3. **Q-A1-3, J3.** x₃ = (10 ; 10,5 ; 95 ; 92 ; 11 ; 11,5 ; 98 ; 90), δ₀ = 0,60, β₀ = 0,70, σ₀ = 0,10, plan synthétique **sans jeu observé** ; R = 2 000 ; P(intérieur) ≈ 0,52, à confirmer par la grille.
4. **Q-A1-4, variante hybride V3h** (V3b à l'intérieur, V1 aux bords). Calculée sans coût et soumise au même critère : la retenir dès maintenant ? Recommandation : oui, car C4 aux bords est la condition la plus menacée.
5. **Q-A1-5, multiplicité.** McNemar exact à 0,05 avec Holm par famille (jeu, seuil) pour C1b et C5, (scénario, seuil) pour C4a, (scénario, ensemble cible) pour C4b.
6. **Q-A1-6, partie P.** Six scénarios sur J2 : H (k = 0, k = 3), C (λ = 3, λ = 4), A (ν = 8, ν = 2), R = 1 000. L'option de trois scénarios sur J3 est décidée à A2 ; les intensités sont ajustables à A2 d'après la grille.
7. **Q-229-4, lecture de (i1) après P2.** Égalité au bit près exigée ; toute discordance expliquée par (h2), ou par un changement de rétention recalculé, et listée ; sinon échec bloquant. Même règle pour V3a = p3 de #175 et pour (t2). (i3) passe sur l'empreinte de #231, cohérente de la grille à la combinaison.
8. **Q-A1-8, contre-implémentation de P2.** La placer dans `tests/outils_tests.R` dès #237, pour (h1) et (h2) sans copie.
9. **Q-A1-9, taille du brut** versionné (≈ 10 à 15 Mo, plus 3 à 5 Mo) : l'accepter, ou réduire les colonnes (p1 de J1 et J2 omise si égale à #221).
10. **Q-A1-10, règle A2** (§ 4.4) : l'approuver, en particulier la poursuite complète si seule C1 est prédite en échec (arbitrage de cible à chiffrer).
11. **Q-A1-11, coût et ordre.** Total de 33 à 60 h CPU, soit 11 à 27 h d'horloge selon la machine (profil mesuré à P4 avant le lancement) ; ordre J2 → J3 → J1, puis P ; graines 20800000 + b, 20810000 + s, 20820000 + 100 p + i.

---

## Annotation du 9 octobre 2026 : décisions du mainteneur au point d'arrêt A1

Consignées par la session principale.

- **Q-A1-1, Q-A1-5, Q-A1-10** : critère C1 à C5, profils D1 à D5, Holm par famille et règle A2 **approuvés tels quels**.
- **Q-A1-2, Q-A1-3** : J1 aux bords, ses 75 réplications intérieures calculées à titre descriptif, V3b compris ; J3 tel que défini au § 3.2. **Approuvés.**
- **Q-A1-4, Q-A1-6** : V3h **retenue**, soumise au même critère ; partie P à six scénarios sur J2, option P-J3 à décider à A2. **Approuvés.**
- **Q-229-4, Q-A1-8, Q-A1-9, Q-A1-11** : lecture de (i1) après P2, contre-implémentation dans `tests/outils_tests.R`, brut complet (≈ 15 à 20 Mo), coût et ordre J2 → J3 → J1 puis P. **Approuvés.** La durée exacte est mesurée en P4 et annoncée avant le lancement.

Prochain point d'arrêt : **A2**, après la grille (étape 4), qui tourne sur le moteur issu de #237 et #231.

---

## Annotation du 9 octobre 2026 : lecture des points ouverts de la grille

Rédigée par l'agent actuary (IA) sur délégation du mainteneur (« les ambiguïtés de la spécification sont tranchées par `actuary` et consignées en annotation datée »), à la lecture de `tests/grille_regime_t8.R` (étape 4, avant toute exécution complète). Elle fixe la lecture des points que les § 2 et 4 laissent ouverts. Elle ne modifie ni le texte du critère (§ 2.1, 2.2), ni la règle A2 (§ 4.4), ni leurs seuils. Elle vaut pour la grille et, quand elle le dit, pour l'étape 6.

**L0, lecture d'une condition prédite.**
- *Au point* : le texte du § 2.2 appliqué aux taux prédits, intervalles compris (comptes prédits k = arrondi(n τ̂), IC de Clopper-Pearson sur (k, n)).
- *Échec franc* (§ 4.4) : la condition est en défaut au point, et le reste quand chaque grandeur prédite est déplacée de e* dans le sens favorable à la variante, sans IC, comme l'exemple du § 4.4.
- Une grandeur est un taux prédit, ou une différence de taux appariés (perte V1 − V3, gain, aggravation par rapport à V1). Une différence est une seule grandeur, déplacée de e*, comme dans l'exemple « différence de puissance prédite V1 − V3 > e* ».
- Un état de V1 (sans distorsion, conservateur, libéral) est plausible si son taux prédit, déplacé d'au plus e*, y conduit. L'échec est franc s'il l'est pour tout état plausible de V1.

**L1, échec franc par condition.**
- C1a, C2b : selon L0, règles (a) et (b) de #175 ; l'aggravation est franche si l'écart à V1 du côté de la distorsion dépasse e*.
- C1b : au point, McNemar significatif après Holm, n01 > n10 et borne basse de l'IC de τ_v > α. Franc si, de plus, τ_v − α > e*, τ_v − τ_V1 > e*, et si le McNemar est significatif sous les deux lectures de L10.
- C2a, J2 : franc si moins de 5 statistiques de F_8 ont à la fois V1 peut-être hors bande (τ_V1 < réf/2 + e* ou > 3 réf/2 − e*) et la variante peut-être dans la bande (à moins de e* de la bande).
- C2a, J3 : notons R les statistiques de F_8 dont V1 est hors bande de plus de e*, P celles dont V1 est peut-être hors bande, V celles dont la variante est peut-être dans la bande. Franc si |P ∩ V| < min(5, |R ∪ (P ∩ V)|), choix de m₃ le plus favorable à la variante. Si R ∪ (P ∩ V) est vide, la condition est vide et ne peut être en échec franc.
- C3 : franc si la part prédite dépasse 1 % + e*, e* étant le plus grand des deux seuils du jeu (convention, C3 ne dépendant pas de α).
- C4a : franc si le McNemar est significatif sous les deux lectures de L10, avec n10 > n01 et une perte V1 − V3 > e*.
- C4b : franc si le gain prédit V3 − V1 est inférieur à −e* pour toutes les statistiques cibles de tous les scénarios.

**L2, « C4 remplie avec une marge > 2 e* ».** Lecture littérale :
- C4a et C4b remplies au point, et C4b décelable sous L10 ;
- perte prédite V1 − V3 < −2 e* pour toute statistique de F_R, tout scénario et tout seuil ;
- gain prédit > 2 e* à l'intérieur pour au moins une cible.

Cette ligne ne se déclenchera presque jamais : la partie P reste à six scénarios, comme approuvé à A1. La grille rapporte la perte maximale et le gain maximal prédits.

**L3, « C2 en échec franc (J2 ou J3 intérieur) ».**
- La ligne porte sur C2a, ou C2b aux cellules intérieures de J2 et de J3.
- Elle recommande l'arrêt si elle est déclenchée pour V3b, et donc pour V3h, qui lui est égale à l'intérieur.
- Déclenchée pour V3a seule : profil D4 prédit pour V3a, la mesure se poursuit.
- Un échec franc de C2b aux bords (J1, J2, J3) est rapporté comme « profil D4 prédit pour V3a ou V3b ; V3h non concernée » (V3h vaut V1 aux bords). Il ne déclenche pas la ligne d'arrêt.

**L4, valeur de B des prédictions.** Les p̃ restent à B infini (§ 4.1), et T1 et T1 bis à B infini sont tabulés (§ 4.3). La grandeur prédite du critère est τ_v de la procédure, à son B. Toute comparaison à une mesure ou à une référence ((g1), (g3), C1 à C4, ligne des intensités de A2) porte donc sur la probabilité de rejet prédite π = P(p_mc < α | queues hi, lo) :
- K suit une loi Binomiale(B, queue) ;
- B vaut 999 pour V1, arrondi(999 q̂) pour V3a, min(999, arrondi(25 000 q̂)) pour V3b ; V3h comme V3b à l'intérieur, comme V1 aux bords ;
- sens « haut » : π = P(K_hi ≤ k₁) ; sens « bas » : π = P(K_lo ≤ k₁) ; sens « deux » : π = P(K_hi ≤ k₂) + P(K_lo ≤ k₂), exact puisque K_hi + K_lo ≥ B > 2 k₂ ;
- k₁ et k₂ sont les plus grands k tels que (1 + k)/(B + 1) < α et 2(1 + k)/(B + 1) < α, évalués comme dans `engine_p_mc()`.

C'est la formule des tailles lissées du T0 de #221. Sous la loi mahonienne exacte (T = 8), elle redonne 0,07107 et 0,03355 à B = 999, et 0,06101 et 0,03115 à B infini **[V]**. L'effet de B sort ainsi de e*.

**L5, e*.** Pour A2, e*_{j,α} est l'écart absolu maximal de (g1) sur les cellules évaluables (n ≥ 100). Les cellules de T1 bis à n < 100 sont descriptives (§ 2.4), comme l'intérieur de J1 dans les cellules de #175 (§ 4.2). Le maximum sur les 102 cellules est rapporté. Sur J2, les deux définitions coïncident (toutes les cellules ont n ≥ 464).

**L6, bande non applicable.** La règle de #166 (bande non applicable si la référence est inférieure à 2/n : lecture binaire, compatible ou écart à examiner, sans distorsion matérielle) fait partie des « classes de #166 » du § 2.1. Elle s'applique à C1a et C2b, dans la grille et à l'étape 6. Les cellules concernées sont listées.

**L7, interpolation.** p̃3 est la queue de la loi conditionnelle de l'interpolée linéaire en δ de la loi jointe de (S, r) : H̃_r = Σ_k w_k q_k(r) H_{k|r} / Σ_k w_k q_k(r). Ainsi p̃1 = Σ_r q̂(r) p̃3,r exactement. Si le dénominateur est nul, p̃3 est absente.

**L8, scénarios de P.** Sous `engine_sous_graine(20810000 + s)` :
- d'abord la matrice ε de R_P × 8, en un appel (`rnorm` pour H et C, `rchisq(·, ν)` pour A), remplie par lignes (la réplication b reçoit les tirages 8(b − 1) + 1 à 8b) ;
- puis, pour C seulement, `sample.int(8, R_P, replace = TRUE)`.

Les matrices sont toujours tirées à R_P = 1 000 complet, et une tranche y prend ses lignes. Base : l'ajustement de J2, avec μ_t = ln(β̂ x_t) − 1/(2 π̂_t) et s_t = π̂_t^(−1/2) pour C et A ; pour H, s_t² = ln(1 + CV_t²) et μ_t = ln(β̂ x_t) − s_t²/2. La grille cite le md5 des matrices et des t*, et l'étape 5 vérifie qu'elle les retrouve à l'identique.

**L9, C1b.** Le seuil est α à la lettre, y compris pour les lois discrètes.

**L10, McNemar prédit.**
- Au point : décisions à B infini.
- Lecture robuste : comptes attendus sous indépendance des erreurs Monte-Carlo de V1 et de la variante, n01 = arrondi Σ π_v(1 − π_V1) et n10 = arrondi Σ π_V1(1 − π_v). La dépendance réelle est positive, les tirages étant partagés **[H]** ; l'indépendance donne donc la lecture la moins significative.
- Un McNemar qui fait échouer une condition (C1b, C4a) ou réussir C4b (« prédite décelable » dans les lignes de A2) ne compte que s'il est significatif sous les deux lectures.

**L11, contrôle (a).** Il relève des étapes 5 et 6 (§ 7), non de la grille.

**L12, brut de la grille.** L'approbation d'A1 sur le volume porte sur les bruts du § 8. Le brut de la grille (≈ 9,8 Mo) attend l'accord du mainteneur avant d'être versionné sur la branche de travail. D'ici là, il est conservé dans `sauvegarde/issue229/` (branche de sauvegarde), et son md5 est cité dans le T0 du tableau.

**L13, V3a et lois discrètes.** Pour V3a, les statistiques à loi discrète sont descriptives dans C1a et C2b (§ 2.1).

**L14, application de A2 sous délégation.**
- La ligne (g1) hors tolérance prime : la grille ne prédit plus.
- Viennent ensuite la ligne d'arrêt (L3), puis les autres lignes, qui se cumulent.
- « C1 seule » s'entend sans autre échec franc pour la même variante.
- La ligne des intensités se lit par scénario, à α = 0,10, sur toutes les réplications, avec π de V1 (L4).
- Une recommandation d'arrêt est consignée comme décision provisoire, révisable par le mainteneur.

---

## Annotation du 10 octobre 2026 : décision au point d'arrêt A2 (sous délégation)

Consignée par la session principale, sur la lecture de la grille par `actuary` (tableau `docs/tableaux/20261009-issue229-grille.md`, `ba630a0` ; brut sur `claude/sauvegarde-229`, md5 `160d4591…`), en application de la délégation du mainteneur (PR #238, commentaires 6088971428 et 6088991201). Détail et chiffres : commentaire « Point d'arrêt A2 » de #229.

- **Validation de la grille** : e* (cellules n ≥ 100) J1 0,0136 / 0,0182, J2 0,0169 / 0,0172 ; la ligne (g1) n'est pas déclenchée, la grille prédit.
- **Lignes de la table** : arrêt (C2 franc) non ; C3 non ; C1 seule non ; **C4 en échec franc pour V3b et V3a** (perte maximale 0,083), non pour V3h (0,007), C4b décelable sur J2 ; marge > 2 e* non ; **intensités : oui pour A8** (π de V1 entre 0,13 et 0,17 sur toute la cible).
- **Décision** : poursuite complète ; V3h retenue (déjà décidé à A1) ; **option P-J3 : non** (C4b décelable sur J2) ; B_max et jeux inchangés.
- **Scénario A8 remplacé par A4** (ν = 4, rang s = 5, graine 20810005 inchangée). Critère fixé avant lecture : le plus grand ν de {6, 5, 4, 3} tel qu'au moins 3 cibles sur 5 aient π de V1 dans [0,2 ; 0,8] et au moins une π ≥ 0,2 + e*. π prédits de V1 à α = 0,10 pour ν = 4 : DAgo 0,217, JB 0,220, SF 0,232, Grubbs 0,189, Grubbsr 0,235 (ν = 5 rejeté, maximum 0,213). md5 (méthode L8) : ε `24b220ddef224d38e19eb4bb2a947b18`, Y `04c46e144ac2e23ea5959a28ad0d761d`. Le tableau du § 6 se lit avec A4 à la place de A8 ; la grille est relancée vers un nouveau tableau daté, sans remplacer celui du 09/10, qui est la pièce de A2.
- **L15, lecture de C5 (ambiguïté tranchée par `actuary`, délégation)** : la grille prédit que des témoins de F_T dépendent du régime sur J3 (Intercept, AD, KS). Un témoin de C5 significatif compte comme « expliqué » si sa différence V3b − V1 mesurée a le signe prédit par la grille et reste à moins de e* de la prédiction ; sinon il suspend la lecture (§ 2.3).
- **Pour A3** (relevé, non tranché) : la combinaison « C1 et C4 toutes deux en défaut » n'a pas de profil dans la table D1 à D5 ; si elle se présente, elle est décrite telle quelle et soumise au mainteneur.

---

## Annotation du 10 octobre 2026 : points ouverts du script de mesure

Rédigée par l'agent actuary (IA) sur délégation du mainteneur, à la lecture de `tests/p_conditionnelle_regime_t8.R`, avant toute exécution de l'étape 6. Elle ne modifie ni le critère (§ 2), ni L15, ni leurs seuils.

- **L16, portée et grandeur de L15.** L15 s'applique à C5 pour chaque jeu, J1 (population des bords), J2 et J3, et pour chaque seuil. La différence prédite est π(V3b) − π(V1) à B fini (L4), lue dans le T1 prédit du tableau de la grille sur la même population. Elle compte comme une seule grandeur (L0). e* est celui du jeu et du seuil (cellules évaluables, L5) ; J3 reprend celui de J2 (g3). Une différence prédite absente ou nulle ne prédit aucun signe : un témoin significatif y est « non expliqué ».
- **L17, (h1) et V3b.** Les « ajouts » de (h1) sont les tirages ajoutés de la région de régime r_b (§ 5, point 2). Sous P1, les tirages hors régime ne calculent aucune statistique et n'entrent dans aucune p ; la couverture des trois régimes est assurée par les tirages de V1, tous confrontés.
- **L18, profil hors table.** La combinaison « C1 et C4 en défaut, C2 et C3 remplies » est signalée par le script comme hors de la table du § 2.3, sans profil ni conclusion, conformément au relevé de l'annotation du 10/10 (A2) ; elle est soumise au mainteneur à A3.
- **L19, C3 et motifs propres au régime.** La p de la variante compte comme absente pour C3 dès que celle de V1 existe, quel que soit son motif : B effectif nul ou inférieur à `B_MIN_DEGENERESCENCE`, dispersion nulle, atome hors de l'observée. Les motifs nommés au § 2.2 (statistique dégénérée au sens de la condition du catalogue, observée non finie) se lisent sur les données observées : ils frappent V1 dans la même réplication, et la clause « alors que celle de V1 existe » les écarte déjà (`engine_p_mc()`, `.mc_p_values()`) **[V]**. Une loi conditionnelle ponctuelle ferait passer la ligne en INFO là où V1 rend un verdict : c'est un défaut de la variante **[H]**. Le détail de C3 ventile les absences par motif. Seules les absences liées au B effectif relèvent de l'issue sur B_max (D5) ; la dispersion nulle et l'atome mettent en cause la loi conditionnelle elle-même.
- **L20, C2a sur J3 sans distorsion de V1.** Si m₃ = 0, le seuil min(5, m₃) est nul : C2a sur J3 est « remplie (condition vide) » et compte comme remplie dans C2 et dans les profils D1 à D3 **[V]** (lettre du § 2.2). Elle n'est pas « non évaluable » : ce terme est réservé au manque d'effectif (n^r < 100, § 2.1), et un m₃ nul constate que V1 n'a rien à corriger sur J3. Même lecture que L1 pour la grille : une condition vide n'est pas en défaut. C2 garde un contenu probant, puisque C2a sur J2 (au moins 5 corrections sur F_8) et C2b sur J3 intérieur restent requises. Le tableau des profils signale ce cas : « C2a sur J3 vide (m₃ = 0) : correction établie sur J2 seul ». La grille du 10/10 prédit m₃ = 4 **[V]**.
- **Tableau de la grille de référence de l'étape 6** (décision de la session, technique) : `docs/tableaux/20261010-issue229-grille.md` (grille relancée avec A4) ; celui du 09/10 reste la pièce de A2.
