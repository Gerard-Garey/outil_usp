> *Rédigé par l'agent actuary (IA), 10/10/2026, branche `claude/calibration-mc-merz-wuthrich` (tête `da30df0`). Spécification de la mesure #206 (+ #119), étape 3. Elle est soumise au point d'arrêt **B1** : aucune exécution, essai compris, avant l'approbation du mainteneur. Les décisions de B1 sont ajoutées en annotation datée, en fin de document.*

**Marques** : **[V]** vérifié (source citée, ou commande exécutée et sortie lue) ; **[H]** hypothèse ; **[NV]** non vérifié.

# Spécification de la mesure #206 : niveau réel à T = 8 des p-values Monte-Carlo de Merz-Wüthrich

## 0. Objet, sources, cadre

**Objet.** Mesurer sous H0 le taux de rejet réel des 13 lignes Merz-Wüthrich dont la p retenue est une p_mc du bootstrap de résidus de `mw_bootstrap()`. La mesure se fait sur le pool redressé (#46, celui du moteur) et sur le pool brut d'avant #46, aux seuils α ∈ {0,10 ; 0,05}. Avec α = 0,10 par défaut, ce sont les deux seuils du verdict : ECHEC si p < α/2, ALERTE si p < α (`R/engine.R`, `add()`, branche « rejeter » **[V]**). La mesure couvre aussi #119 à coût marginal (§ 9).

**Ce que la mesure établit.** Un constat de simulation sous **un** plan, le modèle de Mack ajusté à `reserve2`. Ce n'est pas un résultat général : il ne se transpose ni à une autre géométrie de triangle ni à un autre paramétrage.

**Ce que la littérature dit à T = 8.**
- Aucun théorème ne couvre ce test bootstrap (`docs/specifications/e2-reduite.md:406` **[V]**).
- Les résultats de validité des tests de Monte-Carlo (Dwass 1957, Hope 1968, présents dans `sec:biblio` **[V]**) supposent que la statistique observée et les statistiques simulées sont échangeables. Ce n'est pas le cas ici : les triangles du bootstrap sont tirés avec f̂, σ̂² et le pool estimés. Ces résultats ne fondent donc que le témoin « oracle » du § 4, pas le test du moteur.
- Aucune asymptotique ne s'applique à triangle fixe (I = 7).
- **La mesure est la seule preuve visée.**

**Sources lues.**
- Issues : #206 (corps, et commentaire 6015442145) ; #119 (corps, et commentaire 5905012025) ; #46 ; #242.
- `docs/feuille-de-route.md` : fiche « Branche #206 » (C-206-1 à 6, L-229-1 à 7, coût) et Q-206-1 à 9.
- La spécification 229 (§ 2, 3, 7, 8, 9) et `docs/tableaux/20261008-issue166-calibration-J2.md` (T0, T1, classes).
- Dans `R/engine.R` à `da30df0` : `mw_simuler_triangle()`, `.mw_pool_residus()`, `mw_bootstrap()`, `.mw_contexte_mc()`, `MW_CATALOGUE_MC`, `.mw_stats()`, `mw_tests()` (appels de `add()`), `.mw_lm_intra()`, `engine_p_mc()`, `.mc_p_values()`, `.run_engine_mw()`.
- `b827726^:R/engine.R` (pool d'avant #46).
- `tests/taux_franchissement_reperes.R:514-557` (générateur gaussien de #89).
- Le `.tex` : fiche M1 « tendance », et les tableaux datés de `sec:calib-asympt-mw` et de la calibration Monte-Carlo de Merz-Wüthrich.

**Cadre.** Ni `R/engine.R` ni `tests/reference/` ne sont modifiés par la mesure. Effet attendu : **Ø** sur σ_USP, les p retenues et les verdicts. La mesure se fait sur le moteur de l'étape 2 (#239, objets `identical()`).

## 1. Lignes concernées

Les 13 clés de `MW_CATALOGUE_MC`. Sur `reserve2`, chacune a une p retenue Monte-Carlo (nature « Monte-Carlo (bootstrap de residus) »), avec B_effectif = 999 pour toutes (`tests/reference/reserve2.rds`, `engine_table_tests()` **[V]**) :

| Clé | Ligne de `mw_tests()` | Famille | Queue | p_mc `reserve2` | Verdict |
|---|---|---|---|---|---|
| PenteIntra | Absence de tendance des facteurs avec le cumul | M1 | deux | 0,778 | OK |
| Origine | Nullité de l'ordonnée à l'origine | M1 | haut | 0,085 | ALERTE |
| HomogF | Homogénéité de f_j | M1 | haut | 0,080 | ALERTE |
| Courbure | Absence de courbure | M1 | haut | 0,030 | ECHEC |
| Alpha | Famille alpha | M1 | haut | 0,005 | ECHEC |
| BP | Hétéroscédasticité résiduelle vs cumul | M2 | haut | 0,103 | OK |
| ExpVar | Exposant de variance | M2 | haut | 0,428 | OK |
| Calendrier | Effets d'année calendaire | M3 | deux | 0,004 | ECHEC |
| KruskalAcc | Homogénéité entre années de survenance | M3 | haut | 0,300 | OK |
| CorrDev | Corrélation entre années de développement | M3 | deux | 0,170 | OK |
| DW | Durbin-Watson | M3 | deux | 0,032 | ECHEC |
| Runs | Test des suites | M3 | deux | 0,374 | OK |
| Grubbs | Grubbs | M4 | haut | 0,892 | OK |

**Hors critère** (fiche : « lignes exactes et asymptotiques hors champ ») : ESD (M4), les lignes M5 (Shapiro-Wilk, p exacte ; Lilliefors, p asymptotique) et les lignes INFO de M2 et M6. Leurs p sont enregistrées sans coût et rapportées à titre descriptif (T6).

**Correspondance ligne ↔ clé.** Elle est établie mécaniquement et vérifiée sur `reserve2` par l'égalité p_monte_carlo = `boot$p_mc[clé]`. Les 13 valeurs y sont distinctes **[V]**.

## 2. Processus générateur sous H0 (DGP)

**Plan.** Le modèle de Mack, avec pour paramètres vrais ceux de `mw_ajuster(reserve2)` :
- I = J = 7, triangle 8 × 8, 28 cellules simulées ;
- f̂ = (3,20372 ; 1,65175 ; 1,32525 ; 1,15042 ; 1,09469 ; 1,06455 ; 1,02841) ;
- σ̂² = (0,72404 ; 0,71209 ; 0,69814 ; 0,31478 ; 0,097325 ; 0,18967 ; 0,097325), dont σ̂²₆ extrapolé ;
- première colonne de `reserve2` **fixée** (conditionnement de Mack, comme `mw_simuler_triangle()`) ;
- C_{i,j+1} = f_j C_ij + σ_j √C_ij ε_ij, avec ε_ij i.i.d. de loi L, de moyenne 0 et de variance 1.

Valeurs lues sur `reserve2` **[V]**, par une commande exécutée à `da30df0`.

**Générateur du script.**
- Nommé `gen_triangle_h0()`, **jamais** `mw_simuler_triangle`. Le script de #89 définit une fonction de ce nom (`tests/taux_franchissement_reperes.R:520` **[V]**) : dans l'environnement du moteur, elle masquerait celle qu'appelle `mw_bootstrap()`.
- Même récursion, colonne par colonne, même expression `Cij * f + e * sg * sqrt(Cij)`, et même ordre de consommation des ε que `mw_simuler_triangle()`.
- Contrôle (g), § 6 : avec ε tirés par `sample(pool)`, il reproduit `identical()` `mw_simuler_triangle()` sous la même graine.

**Lois des erreurs** :
- **N** : gaussienne, `stats::rnorm`.
- **E** : loi uniforme sur les 27 valeurs de `.mw_pool_residus(aj0, jd0)`, divisées par leur écart-type de population. Ce pool est redressé et recentré ; jd0 = {6}. Ses moments : écart-type 0,9988, asymétrie −0,159, excès de kurtosis −1,393, bornes [−1,588 ; 1,452] **[V]**. C'est donc une loi **platykurtique**.
- **A** (asymétrique, dernière à réduire dans l'échelle du § 8) : (G − 2)/√2, avec G ~ Gamma(forme 2), tiré par inversion `stats::qgamma(stats::runif(n), 2)`. Asymétrie √2, excès de kurtosis 3, borne basse −√2.
  - Rôle : couvrir le côté asymétrique et à queue lourde, que ni N ni E ne couvrent.
  - Aucun fondement empirique propre à un portefeuille **[H]**.
  - L'indication du 06/10 montre que la loi compte : sur Breusch-Pagan, 3,3 % sous N contre 8,3 % sous E (B = 199, M = 400). Ce n'est pas une calibration **[V]**, commentaire 6015442145.

**Cumuls non positifs, et conditionnement induit.**
- Une cellule devient ≤ 0 si ε < −f_j √C_ij / σ_j. Le minimum de ce seuil sur les cellules de `reserve2` vaut **60,7** **[V]**, et le coefficient de variation maximal d'un facteur 1,6 % **[V]**.
- Sous E et A, dont les supports sont bornés à −1,59 et −1,41, une cellule négative est donc impossible. Sous N, la probabilité est de l'ordre de Φ(−60) **[H, quasi certain]**.
- Tout triangle refusé, par une cellule ≤ 0, par `mw_valider_triangle()` ou par `mw_valider_ajustement()` (appelées par le script comme par `.run_engine_mw()`), est compté avec son motif, sans retirage, et exclu de n. Attendu : 0 **[H]**.
- Au-delà de 1 % de refus pour une loi, le point est signalé au T0 : le conditionnement déforme alors la population.

**Ex æquo (C-206-1).** Sous E, ε est discret, mais F_ij = f_j + σ_j ε_ij / √C_ij varie avec C_ij : les ex æquo de facteurs restent de probabilité nulle. L'effet de #207 sur ces taux est attendu négligeable **[H, argument]**.

## 3. Procédure mesurée, et pools

**Par triangle simulé (ℓ, b).**
1. `aj_b <- mw_ajuster(tri_b)`, avec les validations ci-dessus.
2. `boot <- mw_bootstrap(aj_b, B = 999, seed = S(ℓ,b))`.
3. `mw_tests(aj_b, boot, alpha = 0.10)`.

C'est le chemin de `.run_engine_mw()` sans `mw_parametre()` ni les sorties graphiques. L'identité avec `run_engine()` complet est prouvée sur un échantillon : contrôle (i2).

**B = 999** est une donnée du test calibré, non un levier.

**Pool brut** (C-206-4) :
- Reconstitué par injection, dans l'environnement où le moteur est chargé, d'une `.mw_pool_residus` qui rend `r - mean(r)`, avec `r = mw_residus(aj, jd)$residu`. C'est l'expression d'avant #46 (`b827726^:R/engine.R`, `mw_bootstrap()` **[V]**).
- Restauration par `finally`, technique de `e88b6e6`. Aucun paramètre n'est ajouté au moteur.

**Appariement.**
- Pour b ≤ R_brut, les deux pools tournent sur le **même** triangle avec la **même** graine S(ℓ,b).
- Les deux pools ont la même longueur, `mw_residus(aj, jd)`. `sample(x, n, TRUE)` vaut `x[sample.int(length(x), n, TRUE)]` en R. Les indices tirés sont donc identiques ; seules les valeurs diffèrent.
- La lecture est appariée par McNemar exact, comme pour #221.

## 4. Référence lissée et témoin « oracle »

**Loi oracle.** Pour chaque loi ℓ, N0 = 20 000 triangles sont tirés du DGP. Sur chacun, on calcule les 13 statistiques par `.mw_stats(aj_k, jd_k)`, avec `jd_k = .mw_colonnes_degenerees(aj_k)`, comme pour une statistique observée. On obtient ainsi la loi F0 de chaque statistique sous le vrai modèle, sans bootstrap.

**Référence ρ(s, α, ℓ).** C'est la taille, à B = 999, du test de Monte-Carlo idéal, qui tirerait ses 999 répliques dans F0 avec la règle « ≥ » d'`engine_p_mc()`.
- Queue haute : ρ = moyenne sur F0 de P(Bin(999, q⁺(s)) ≤ ⌈1000 α⌉ − 2), avec q⁺(s) = P0(S ≥ s). La queue basse est symétrique.
- Bilatérale : somme des deux termes à 500 α. Les deux événements sont disjoints, puisque K⁺ + K⁻ ≥ 999.
- Une règle unique pour les statistiques continues (ρ ≈ 0,099 et 0,049 en queue simple, 0,098 et 0,048 en bilatéral, comme la note de T1 de #166) et discrètes (Calendrier, Runs, rangs) : **aucune classification a priori**. Le nombre de valeurs distinctes et la masse du plus gros atome de F0 sont rapportés.
- Erreur de ρ due à N0 : de l'ordre de 0,002 à α = 0,10 **[H]**. Elle est déclarée, et distincte de l'IC sur τ, fonction de R, et de l'erreur `err_mc` de chaque p, fonction de B.

**Témoin (K3).** La p oracle de chaque triangle mesuré est p_or = `engine_p_mc(S0, s_obs, queue)` contre l'échantillon oracle. Ce test est exact, ou conservateur aux atomes, par construction : les triangles mesurés et les triangles oracle sont i.i.d. du même DGP (Dwass, Hope).
- Un taux de rejet du témoin incompatible avec sa taille signale un défaut de la mesure : générateur, jd, ou chemin des statistiques.
- Le témoin coûte zéro bootstrap, et l'oracle 20 000 ajustements par loi (§ 10).
- L'échantillon oracle n'est pas versionné. Il est régénérable par ses graines ; son md5 figure au T0 et au JOURNAL.

## 5. Critère, fixé avant toute exécution

Ce texte est reporté sans modification dans le script et au T0.

**Grandeurs.**
- Décision D = 1 si p_mc < α.
- **Une p absente compte comme un non-rejet.** Elle est comptée à part dans chaque cellule (#242), avec le taux sur les seules p définies en colonne descriptive.
- Population : les triangles admis, b ∈ 1..R_(ℓ,pool).
- τ = k/n, avec IC de Clopper-Pearson à 95 %.
- **Classes de #166, avec ρ pour référence** :
  - *compatible* : ρ ∈ IC ;
  - *écart mineur* : estimation dans la bande de Bradley [ρ/2 ; 3ρ/2] ;
  - *écart non tranché* : estimation hors de la bande, IC la recoupant ;
  - *distorsion matérielle* : IC disjoint de la bande, avec son côté, libéral ou conservateur.
- Classes calculées sur les valeurs **non arrondies** (#242, D-e).

**Conditions** (évaluées mécaniquement, **sans conclusion** dans le tableau) :
- **K1, niveau, pool redressé** (critère principal) : classe de chaque (ℓ, s, α), pour ℓ ∈ {N, E}, et A si exécutée.
- **K2, brut contre redressé** : pour b ≤ R_brut et pour chaque (ℓ, α), McNemar exact bilatéral (binomiale de paramètre 1/2 sur n01 + n10) et Holm (1979) à 0,05 sur la famille des 13 clés. On rapporte les classes du pool brut et les écarts |τ − ρ| des deux pools sur les mêmes triangles.
- **K3, témoins** : pour chaque (ℓ, α), test binomial exact de τ_or contre sa taille, Holm sur 13. **Un témoin significatif suspend la lecture** jusqu'à explication.
- **K4, p absentes** : part des triangles où au moins une des 13 p_mc manque. Au plus 1 % par (ℓ, pool) ; au-delà, point de décision.
- **K5, B effectif** (descriptif) : distribution, minimum, part < 999, motifs (`motif_mc`).

**Profils de lecture proposés pour B3** (actuary propose, le mainteneur tranche) :

| Profil | Condition | Lecture proposée |
|---|---|---|
| Π0 | K3 ou K4 en défaut, non expliqué | Lecture suspendue ; mesure à reprendre |
| Π1 | Sous N et E, les 13 lignes sont compatibles ou en écart mineur aux deux seuils | Constat documenté seul (rubrique 7, `sec:calibration-mc` volet MW) ; aucune évolution du moteur |
| Π2 | Pas de distorsion matérielle, mais des écarts non tranchés | Constat documenté avec ses IC ; aucune évolution |
| Π3 | Distorsion matérielle **conservatrice** sur une ligne (IC sous ρ/2) | Les OK de la ligne sont une preuve faible (puissance), et une p de `reserve2` proche du seuil est probablement trop grande. Documenter ; issue B4 éventuelle (correction de niveau), sans engagement de méthode |
| Π4 | Distorsion matérielle **libérale** sur une ligne, pour une loi | Les ALERTE et ECHEC de la ligne surestiment la preuve, en particulier les ECHEC de `reserve2` (Courbure, Alpha, Calendrier, DW). Issue B4 proposée (correction de niveau ou passage en diagnostic) ; décision du mainteneur |
| Π5 | Classes de sens opposés entre lois pour une ligne | Niveau non robuste à la loi des erreurs, qu'aucune correction calibrée sur une seule loi ne règle : documenter |

**Effet de #46 (K2).**
- R1 : aucun McNemar significatif après Holm. Le redressement est sans effet mesurable sur le niveau.
- R2 : effet significatif, qui rapproche τ de ρ. #46 est confortée.
- R3 : effet qui éloigne τ de ρ. Point du mainteneur : la variante B de #46 est à revoir par une issue B4, pas dans cette branche.

**Lignes « à la frontière » de `reserve2`** (BP 0,103 ; Origine 0,085 ; HomogF 0,080) : elles sont lues avec leur τ.
- Compatible : le verdict est celui d'un test calibré, au bruit Monte-Carlo près, et c'est l'objet de Q-206-9, tranchée en B3.
- Conservateur : la p de `reserve2` surestime l'absence de preuve.
- Libéral : l'inverse.
- T4 donne, sous H0, la fréquence des cas |p_mc − α| < 2 err_mc par ligne, c'est-à-dire la fréquence à laquelle le signalement proposé se déclencherait.

**Multiplicité sous H0** (T4, descriptif) : part des triangles à au moins une ALERTE ou un ECHEC, et à au moins un ECHEC, sur les 13 lignes MC et sur toutes les lignes à verdict. Le repère 1 − (1 − α)^13 est un ordre de grandeur, pas une référence.

## 6. Contrôles d'intégrité

Un échec met INTEGRITE à ECHEC, et `--combiner` refuse.

| Contrôle | Contenu |
|---|---|
| (a) | `run_engine()` du cas `reserve2` (graine 20260831) conforme à `tests/reference/reserve2.rds` par `comparer_objets()` |
| (b) | Les 13 noms et sens lus dans `MW_CATALOGUE_MC` ; correspondance ligne ↔ clé vérifiée sur `reserve2` (§ 1) |
| (g) | `gen_triangle_h0()` avec ε tirés par `sample(pool)` = `mw_simuler_triangle()` sous la même graine, `identical()`, sur 100 graines ; `mw_simuler_triangle` et `.mw_pool_residus` de l'environnement identiques à celles du fichier hors injection |
| (i1) | Sur l'échantillon (premier b de chaque tranche, et `reserve2`) : `boot$stats_obs` `identical()` à `.mw_stats(aj_b, jd_b)` recalculé, et au chemin oracle appliqué au même triangle |
| (i2) | Sur le même échantillon : `$tests` et `$bootstrap` de `run_engine(methode = "reserve2", triangle = tri_b, segment = 1, annexe = "II", seed = S(ℓ,b))` `identical()` au chemin du script, pour le pool redressé et pour le pool brut (injection active) |
| (i3) | Empreinte sans commentaires de #231 (`empreinte_sans_commentaires()`, `tests/outils_tests.R` **[V]**) égale dans toutes les tranches, l'oracle, la combinaison et le JOURNAL ; md5 de `R/engine.R`, du script et de `tests/outils_tests.R` cités |
| (i4) | Pool brut : corps injecté conforme à l'expression de `b827726^` ; restauration vérifiée (`identical()`) après chaque appel ; longueurs des deux pools égales |
| (s) | Sous-mesure N (§ 9) : sur son premier b, la régénération des 999 triangles bootstrap, par `mw_simuler_triangle()` sous S(ℓ,b), redonne par `.mw_stats()` les `p_mc` de `mw_bootstrap()` `identical()`. Seul `sample()` consomme de l'aléa dans le bloc Merz-Wüthrich **[V]**, grep de `R/engine.R` |
| (d) | Invariants : B_eff ≤ 999 ; p sur la grille k/(B_eff + 1) (×2 en bilatéral, plafonnée à 1) ; n + refusés = R |

## 7. Graines

Toutes passent par `engine_sous_graine()`. Indice de loi ℓ : 1 = N, 2 = E, 3 = A.

| Flux | Graine | Plage |
|---|---|---|
| Triangle b, loi ℓ | 20840000 + 10000(ℓ − 1) + b | 20840001-20862000 |
| Bootstrap b, loi ℓ (les deux pools) | 20870000 + 10000(ℓ − 1) + b | 20870001-20892000 |
| Oracle k, loi ℓ | 20900000 + 20000(ℓ − 1) + k | 20900001-20960000 |

Les plages sont disjointes entre elles. Elles sont au-dessus de toute graine littérale de `R/engine.R`, `tests/*.R` et `tests/unitaires/*.R` (la plus haute est 20820000 + …, #229 **[V]**, grep), et du réseau 20260831 + 1000 k ≤ 20760831 de `tests/puissance_t8.R` (**[NV]** ici, **[V]** dans la spécification 229). Le T0 refait la recherche, graines calculées comprises.

## 8. Configurations, R, et échelle de réduction pour B2

**Plan de base L0** (en bootstraps de B = 999) :
- pool redressé, lois N et E : R = 2 000 chacune (IC ≈ ±0,013 à 0,10), comme #166 ;
- pool brut, lois N et E : R = 1 000, apparié sur b ≤ 1 000 ;
- pool redressé, loi A : R = 1 000.
- **Total 7 000.**

**Échelle**, appliquée à B2 de façon mécanique : on retient le premier niveau dont la durée planifiée tient en **20 h d'horloge**, ce qui laisse 4 h de marge sur 24 h pour les redémarrages, les contrôles et la combinaison.

| Niveau | Changement | Bootstraps |
|---|---|---|
| L0 | — | 7 000 |
| L1 | A à R = 500 | 6 500 |
| L2 | brut à R = 500 par loi | 5 500 |
| L3 | A retirée (et son oracle) | 5 000 |
| L4 | redressé N et E à R = 1 500 | 4 000 |
| L5 (minimum) | redressé N et E à R = 1 000 (IC ≈ ±0,019) | 3 000 |

**Règle.** N_max = (20 h × P × 3 600 − F) / c_b, où :
- P est le débit agrégé **mesuré** par `--prevol` à 1, 2, 3 et 4 processus ;
- c_b est la durée mesurée d'un bootstrap, `mw_tests()` compris ;
- F est le coût fixe (oracle, sous-mesure N, contrôles).

En dessous de L5, B2 n'est pas délégable : retour au mainteneur, avec l'option (C) de Q-206-2 (issue « P2-MW ») ou un budget prolongé.

## 9. #119 à coût marginal : oui, avec une réserve

| Élément de #119 | Traitement | Coût |
|---|---|---|
| « 100 % de rejets sous H0 » de la régression agrégée sans effet de colonne (rubrique 6 de M1, et commentaire de `PenteIntra`, C-206-5) | Sur chaque triangle mesuré : t de `lm(F ~ C, weights = C/σ̂²_j)` sans `factor(j)`, p de Student bilatérale. Avec le bootstrap, la relation mécanique serait reproduite dans les répliques : l'affirmation ne peut porter que sur la p nominale **[H, argument]** | ≈ 1 ms par triangle |
| « 0,068 à 0,10 avec effet fixe » | `p_asymptotique` de la ligne PenteIntra (Student), déjà calculée par `mw_tests()` | 0 |
| « Pondérer par C seul : aucun rejet sous H0 » (rubrique 6, commentaire de `.mw_lm_intra()`) | Même régression à effet de colonne, poids C seul, p de Student | ≈ 1 ms |
| Tableau daté des p asymptotiques (600 triangles 10 × 10) | Remplacé par T6 : taux de `p_asymptotique` des lignes qui en ont une, et des lignes M5, à 8 × 8 | 0 |
| Tableau daté des p Monte-Carlo (160 triangles 10 × 10) | Remplacé par T1, l'objet même de #206 | 0 |
| « Fréquence de rejet nulle au lieu de 5 % » (commentaire de `mw_bootstrap()`, C-206-5) | Sous-mesure N : loi N, pool redressé, b ≤ 500. Les 999 triangles bootstrap sont régénérés (contrôle (s)) et réajustés ; on calcule W de Shapiro-Wilk et la statistique de Lilliefors (fonctions des lignes M5), avec p_mc en queues basse et haute, et les taux à 0,05 et 0,10 | ≈ 0,4 à 1,2 h CPU |
| « 100 % de rejets » de **puissance** sous une alternative linéaire en volume | **Non reproductible** : aucun script dans l'historique (affirmation présente dès les premiers commits, `git log -S` **[V]**) et intensité de l'alternative inconnue. **Recommandation : retirer la valeur** (rubrique 6 de M1, tableau 1) au profit de « puissance non étudiée à T = 8 », comme le dit déjà la rubrique 7 | 0 |

Les valeurs 10 × 10 sont **retirées et remplacées**, pas reproduites : le protocole d'origine est introuvable. Coût total de #119 ≤ 2 % du budget **[H]**. **Conclusion : #119 est couverte à coût marginal**, à condition d'accepter le retrait de la valeur de puissance (Q-206-B1-6).

## 10. Coût estimé

Mesures à `da30df0`, conteneur à 4 cœurs, possiblement chargé par `coder` en parallèle **[V]**, 20 appels chacune :
- `.mw_stats()` : 108 ms par appel (`architect` : 71 ms) ;
- `mw_ajuster()` : 0,25 ms ;
- `mw_residus()` : 7,8 ms ;
- `mw_tests()` : 1,0 s par triangle ;
- `shapiro.test()` : 0,08 ms.

On pose c_b ≈ 999 t + 1,5 s, où t est le coût d'une réplication après #239 (inconnu, mesuré au pré-vol). Le débit est supposé linéaire à 4 processus **[H]**, comme P4 de #229.

| t (ms) | c_b (s) | Niveau retenu | h CPU (F compris) | Horloge |
|---|---|---|---|---|
| 36 (#239 divise par 2, **[H]**) | 37,5 | L0 | ≈ 74 | ≈ 18,6 h |
| 50 | 51,5 | L3 | ≈ 73 | ≈ 18,3 h |
| 62 (gain de 18 %) | 63,4 | L4 | ≈ 72 | ≈ 18,0 h |
| 76 (sans gain) | 77,4 | L5 | ≈ 66 | ≈ 16,6 h |
| > 92 | — | sous L5 | — | retour au mainteneur |

F ≈ 1,5 à 1,8 h CPU : oracle de 20 000 × (t + 0,4 ms) par loi, sous-mesure N, deux bootstraps de contrôle par tranche, et (a). Le pré-vol (≈ 10 min) et la tranche d'essai de l'étape 4 sont hors budget d'exécution.

## 11. Tranches, sorties, journal

**Script.** `tests/calibration_mc_mw_t8.R`, R base + stats, hors CI, sur la mécanique de `tests/p_conditionnelle_regime_t8.R`.

**Modes :**
- `--oracle --loi ℓ` ;
- `--loi ℓ --b b1:b2 --pools redresse[,brut]` ;
- `--sous-mesure-N --b b1:b2` ;
- `--prevol` ; `--essai` (sorties non versionnables) ;
- `--reprendre`, `--combiner`, `--ecrire`, `--journal FICHIER` ;
- avec `garde_ecrasement()`, `commit_depot()`, `motifs_non_versionnable()` et l'empreinte de #231.

**Outillage** (Q-206-5) : lanceur idempotent, synchroniseur et contrôle des md5 sous `tests/`, sans logique de mesure. Jamais sur la branche de sauvegarde (L-229-1).

**Reprenabilité** (L-229-4) :
- une ligne REP par (ℓ, b), écrite au fil de l'eau, qui porte les deux pools si b ≤ R_brut ;
- une réplication ne dépend que de (ℓ, b) et de ses graines.

**Tranches.** Environ 250 bootstraps par tranche (125 triangles appariés, ou 250 non appariés), soit 2,6 à 5,4 h CPU **[H]**.

**Ordre de priorité** : oracles → tranches appariées N et E, alternées → redressé seul N et E → A → sous-mesure N. Le plan des tranches du niveau retenu est écrit au JOURNAL à B2.

**`--combiner` refuse :**
- une couverture de 1..R_(ℓ,pool) qui n'est pas exactement une fois ;
- des PARAMETRES, un commit, une plateforme, une empreinte ou un générateur différents ;
- une tranche sans INTEGRITE OK ou sans FIN ;
- un md5 différent de celui du JOURNAL.

**Critères génériques de #242** (critères d'acceptation) :
- aucun chemin `/tmp` ni absolu au T0 (D-a) ;
- tout libellé non ASCII du script en échappements `\u` (sortie correcte sous `LC_ALL=C`, #113) ;
- p absentes comptées et affichées dans chaque cellule ;
- IC non arrondis à 4 décimales (au moins 5, valeurs exactes dans le brut ; D-e) ;
- JOURNAL de la combinaison conservé et versionné (D-g).

**Sorties définitives**, nouvelles et jamais patchées :
- `docs/tableaux/<AAAAMMJJ>-issue206-calibration-mw.md` et `-brut.tsv` (taille ≈ 5 à 10 Mo **[H]**) ;
- `<AAAAMMJJ>-issue119-mw.md` (T6, T7) ;
- `<AAAAMMJJ>-issue206-journal-mesure.md` et `-journal-combinaison.md`.

**Contenu des tableaux :**
- **T0** : provenance, DGP, critère reproduit, graines et collisions, niveau de l'échelle et débit, contrôles, table des ρ et diagnostics d'atomes ;
- **T1** : niveau du pool redressé par (ℓ, s, α) ;
- **T1 bis** : pool brut ;
- **T2** : McNemar brut contre redressé, Holm ;
- **T3** : témoins oracle ;
- **T4** : verdicts, multiplicité, fréquence de |p_mc − α| < 2 err_mc ;
- **T5** : B effectif, p absentes, motifs, triangles refusés, durées ;
- **T6** (#119) : p asymptotiques, M5 et régressions agrégées ;
- **T7** (#119) : sous-mesure N ;
- **évaluation mécanique** de K1 à K5, et profils Π et R, **sans conclusion**.

## 12. Hors périmètre

- Toute modification du moteur, des p_mc et des verdicts (B4).
- Une seconde géométrie de triangle.
- La puissance des lignes Merz-Wüthrich.
- Un B autre que 999.
- #207, #204, #233, #234 (C-206-2 : les tableaux restent valides à leur commit cité).

## Questions au mainteneur pour B1

- **Q-206-B1-1. Critère.** Approuver K1 à K5, et les profils Π0 à Π5 et R1 à R3, fixés avant toute exécution. *Recommandation : oui.*
- **Q-206-B1-2. DGP.** Plan `reserve2` (première colonne fixée, f̂ et σ̂² vrais) ; lois N, E (pool redressé standardisé, platykurtique) et A (Gamma(2) standardisée). *Recommandation : oui ; A est la seule loi du côté asymétrique et à queue lourde.*
- **Q-206-B1-3. Ordre de l'échelle.** A est réduite avant le pool brut, mais retirée seulement après sa réduction (L1 → L2 → L3). L'alternative est de retirer A en premier, puisque #206 exige « au minimum » la comparaison brut contre redressé. *Recommandation : l'ordre proposé.*
- **Q-206-B1-4. R.** Redressé N et E à R = 2 000 ; brut apparié à R = 1 000 ; A à R = 1 000 (niveau L0). *Recommandation : oui.*
- **Q-206-B1-5. Oracle.** N0 = 20 000 par loi, comme référence ρ et témoin K3 ; échantillon non versionné, régénérable, md5 au JOURNAL. *Recommandation : oui.*
- **Q-206-B1-6. #119.** Elle est jointe (troisième `Closes`), car couverte à coût marginal. Les tableaux datés 10 × 10 sont retirés au profit de mesures tracées à 8 × 8, et la valeur de puissance « 100 % » de M1 est **retirée**, non reproduite. *Recommandation : oui.*
- **Q-206-B1-7. Chemin mesuré.** `mw_bootstrap()` + `mw_tests()`, avec validations appelées par le script et identité (i2) avec `run_engine()` sur échantillon, plutôt que `run_engine()` complet. *Recommandation : oui (gain ≈ 5 %, **[H]**).*
- **Q-206-B1-8. Graines.** Les plages du § 7. *Recommandation : oui.*
- **Q-206-B1-9. B2.** Délégable si le niveau retenu par la règle du § 8 est ≥ L5 en 20 h planifiées et que la spécification n'est pas modifiée ; sinon, retour au mainteneur. *Recommandation : oui, conforme à Q-206-7.*

---

## Annotation du 10/10/2026 : point d'arrêt B1 franchi

Le mainteneur approuve la spécification **telle quelle**, avec toutes les recommandations : Q-206-B1-1 à Q-206-B1-9. En particulier :
- **Q-206-B1-6** : #119 est jointe à la branche, ce qui ajoute un troisième `Closes` à la PR #241. Les tableaux 10 × 10 sont retirés au profit de mesures tracées à 8 × 8, et la valeur de puissance « 100 % » de M1 est retirée.
- **Q-206-B1-9** : B2 est délégable aux conditions du § 8.

Aucune exécution n'a eu lieu avant cette approbation.

---

## Annotation du 10/10/2026 : points d'interprétation de la mise en œuvre (actuary, par délégation)

> *Rédigé par l'agent actuary (IA), versionné par la session principale.*

`coder` a relevé quatre ambiguïtés en écrivant `tests/calibration_mc_mw_t8.R`. Elles sont tranchées ci-dessous, avant toute exécution de mesure. Le critère du § 5 reste celui approuvé en B1, précisé sur les points qui suivent.

1. **§ 7, graines.** Une phrase est corrigée. Il est faux que les plages soient « au-dessus de toute graine littérale » : 23700237 (`tests/unitaires/test_regressions_qr.R:134`, #237) est au-dessus. Cette graine est utilisée seule, sans décalage, et n'entre en collision avec aucune plage **[V]**, grep.
   - Le critère « plus grand littéral + marge » est remplacé par le contrôle suivant : pour chaque littéral de graine L de `R/engine.R`, `tests/*.R` et `tests/unitaires/*.R`, suffixe `L` compris, l'intervalle [L ; L + 20 000] est disjoint des trois plages.
   - La marge de 20 000 couvre les graines calculées par décalage (b ≤ 2 000, réseaux de #229). Le réseau 20260831 + 1000 k ≤ 20760831 de `tests/puissance_t8.R`, `SEED_LOI_NULLE_SW` et la graine de `reserve2` sont contrôlés à part.
   - Le T0 liste les littéraux situés au-dessus des plages. Il déclare que les littéraux en écriture scientifique ne sont pas recherchés.
2. **ρ et témoin K3.**
   - (a) Une statistique oracle non finie compte comme un non-rejet dans ρ, comme une p absente dans le critère. q⁺ et q⁻ sont lues sur les seules valeurs finies, comme le B effectif d'`engine_p_mc()`. Le dénominateur est le nombre de triangles oracle admis. Au-delà de 1 % de valeurs non finies pour une clé, ρ de cette clé est signalé au T0 comme approché, car il suppose B = 999.
   - (b) « Sa taille » (K3) est la taille lissée du test de Monte-Carlo à B = N0, par la même règle que ρ appliquée à l'échantillon oracle. Le dénominateur est le même que pour ρ : les triangles oracle admis, une statistique non finie comptant comme un non-rejet. La taille nominale continue est rapportée à côté. Le test reste le binomial exact bilatéral, avec Holm sur 13.
   - Limite déclarée en T3. Un seul échantillon oracle sert à tous les triangles mesurés. La variance de τ_or vaut donc environ α(1 − α)(1/n + 1/N0), et non α(1 − α)/n. À n = 2 000 et N0 = 20 000, son écart-type est multiplié par environ 1,05, et un binomial nominal à 5 % rejette environ 6 % du temps quand la mesure est correcte **[calcul d'ordre de grandeur, non simulé]**. Ce léger excès de signalement n'est pas corrigé ; il entre dans le jugement « non expliqué » de Π0.
3. **Π5.** Le profil Π5 se lit au sens **strict** : pour une même clé et un même seuil, il faut des distorsions matérielles de côtés opposés (libéral et conservateur) entre deux lois.
   - Raisons : seule la distorsion matérielle porte un côté dans les classes du § 5, et la lecture de Π5, qui porte sur une correction calibrée, n'a d'objet que là où Π3 ou Π4 ouvrirait une issue B4.
   - La lecture large (classes non compatibles de part et d'autre de ρ) est rapportée comme indication descriptive, hors profil.
4. **Sous-mesure N (T7, #119).** W de Shapiro-Wilk et D de Lilliefors sont calculés comme suit :
   - sur le triangle observé, par le chemin des lignes M5 de `mw_tests()` ;
   - sur les 999 répliques, avec l'ensemble des colonnes dégénérées figé à l'observé.

   Cette convention est celle du contexte de `mw_bootstrap()` (#56), donc celle que suivrait la p de Monte-Carlo hypothétique visée par le commentaire de `mw_bootstrap()`. Le script compte et rapporte en T7 les répliques dont l'ensemble recalculé diffère de l'ensemble figé (attendu : 0 **[H]**). Un compte non nul est un point de décision.
