# Spécification d'E2d : réplications perdues du bootstrap de Merz-Wüthrich (#257) et courbure et pente intra-colonne sur cellule dominante ou ligne de poids faible (#253)

> *Rédigé par l'agent actuary (IA), le 13/10/2026, sur la branche `claude/merz-wuthrich-replications-definitions` (PR #265, tête `c88b6e3`). C'est l'étape 1 de la fiche « Branche E2d » de `docs/feuille-de-route.md`. La spécification a été soumise au point d'arrêt **D1** : aucun code de #253 ni de #257 avant l'approbation du mainteneur. Les décisions de D1 sont reportées en annotation datée, en fin de document.*

**Marques** : **[V]** vérifié (source citée, ou commande exécutée et sortie lue) ; **[H]** hypothèse ; **[NV]** non vérifié.

## 0. Objet, sources, mesures, décisions déjà prises

**Objet.** Deux défauts du module Merz-Wüthrich, tous deux hors des six cas de référence :
- **#257** : le bootstrap perd des réplications quand une ligne a un poids faible. B effectif dépend alors du signe des tirages, et R émet des « NaNs produced ».
- **#253** : la courbure et la pente intra-colonne valent `NA` sur des triangles valides.

Ordre de la fiche (C-E2d-1) : #253 à l'étape 5, puis #257 à l'étape 6.

**Sources lues** **[V]** :
- fiche « Branche E2d » (§ 3) : constats 1 à 7, étapes 5 et 6, points C-E2d-1 à C-E2d-6 ;
- Q-E2d-4 et Q-E2d-11 (§ 5), décidées le 13/10 ;
- ligne E-11/10 (E2c) du § 4, décision Q-E2c-1 (A) : la colonne de la courbure à un degré de liberté résiduel est conservée ;
- issues #257 et #253 (corps ; aucun commentaire au 13/10) ;
- `R/engine.R` à `c88b6e3` :
  - simulation : `mw_simuler_triangle()` (l. 8728-8744), `.mw_pool_residus()` (l. 8778), `mw_bootstrap()` (l. 8791-8851, saut à la l. 8810) ;
  - catalogue : `.mw_contexte_mc()` (l. 8861), `MW_CATALOGUE_MC` (l. 8910-8960 ; PenteIntra l. 8941, Courbure l. 8949) ;
  - restitution : `.mw_phrase_b_effectif()` (l. 8985), `mw_tests()` (l. 9011 ; PenteIntra l. 9040, Courbure l. 9097) ;
  - régressions : `.mw_lm_intra()` (l. 8035-8056), `.mw_pente_intra()` (l. 8057), `mw_test_courbure()` (l. 8434-8463), `.mw_summary_lm()` (l. 8290) ;
  - combinaison : `.fisher_combine()` (l. 8090 ; règle « aucune exclusion silencieuse », l. 8082) ;
  - p Monte-Carlo : `engine_p_mc()` (l. 3657), motifs (l. 3604-3627), `.mc_p_values()` (l. 3720), `FACTEUR_B_MAX_REGIME` (l. 2009) ;
- ADR 0004 et ses annotations des 25/09, 07/10 et 11/10 ; ADR 0014, précédent du plafond 25 (B + 1) ;
- `CONTEXT.md` : « P-value Monte-Carlo conditionnelle à la définition de la statistique » et « Test sans p-value retenue » ;
- spécification d'E2b, § 6 (#204) ;
- tests :
  - `tests/outils_tests.R` (cas `reserve2`) ;
  - `tests/unitaires/test_merz_wuthrich.R` : sentinelle 5 × 5 (l. 2007-2030), et boucles qui reproduisent celle de `mw_bootstrap()` (l. 968-990, 1560-1570, 1690-1698, 2220-2230) ;
  - `tests/unitaires/test_tables_mw.R` (l. 474-495) ;
  - `tests/mesure_precision_residus_mw.R` (TA8, grille) ;
  - `tests/patcher_reference.R` (invariant : aucune valeur numérique posée) ;
- `.tex` à `c88b6e3` : l. 3895-3995, fiches `mw:m1` et `mw:m1c`.

**Mesures** **[V]** :
- `Rscript` sous `LC_ALL=C.UTF-8` ; R 4.3.3 ; BLAS et LAPACK de référence 3.12.0.
- Moteur `c88b6e3`, figé par `git archive` dans un dossier de session : l'arbre de travail portait au même moment une modification non commitée de #260.
- Référence exacte de #253 : arithmétique rationnelle exacte (module `fractions` de Python 3.13). Les entrées sont les flottants du moteur, convertis exactement par `float.fromhex`. t² est rationnel ; seule la racine finale est arrondie.
- Scripts de session, non versionnés ; leurs commandes figurent au compte rendu d'`actuary` (PR #265).
- Graine 20260831 ; B = 999 sauf mention contraire.

**Décisions déjà prises, non rouvertes** :
- Q-E2d-4 : (A) par défaut si les deux voies sont défendables à T = 8 ;
- Q-E2d-11 : aucune régénération tant que les écarts restent sous `TOLERANCE` ;
- Q-E2c-1 (A) ;
- #204 : phrases des cas A et B, décision du 12/10 ;
- Q-E2b-4 (A) : l'exception à la règle #76 est bornée aux deux phrases de #204.

## 1. #257 : constat et cause

**Mécanisme** **[V]** (lecture de `R/engine.R:8728-8744`).
- `mw_simuler_triangle()` tire colonne par colonne : C\*(i, j+1) = f̂_j C\*(i, j) + ε σ̂_j √C\*(i, j). Le résidu ε est tiré avec remise dans le vivier redressé et recentré.
- Les cumuls ≤ 0 ne sont remplacés par `NA` qu'**après** la boucle (l. 8742). Un cumul négatif tiré en colonne j entre donc dans `sqrt(Cij)` à la colonne j + 1 : c'est l'avertissement « NaNs produced ».
- On compte au plus un avertissement par triangle, car la racine d'un `NaN` n'en émet pas. Un cumul négatif tiré en dernière colonne n'en émet aucun.
- `mw_bootstrap()` écarte ensuite la réplication entière (l. 8810).

Le constat 2 de la fiche est **confirmé** :
- TA8, ligne 0 × 10^-15 : 961 avertissements pour 961 réplications perdues ;
- TA8, ligne 4 × 0,03 : 43 avertissements pour 48 pertes, les 5 autres cumuls ayant été tirés en dernière colonne.

**Commentaire des l. 8740-8741.** Il annonce « on borne par une valeur stricitement positive », alors que le code met `NA` et écarte la réplication : il contredit le code. Il est corrigé au § 3.

**Cause de fond.**
- L'écart-type du terme aléatoire, σ̂_j √C(i, j), domine l'espérance f̂_j C(i, j) dès que C(i, j) est petit devant σ̂_j²/f̂_j².
- Le schéma additif tire alors des cumuls négatifs, hors du support du modèle de Mack (variance proportionnelle à C).
- La cause n'est donc pas numérique : c'est la réserve D4 d'`actuary`, émise à la validation de #233.

**`reserve2` ne peut tirer aucun cumul non positif, quelle que soit la graine** **[V]**.
- Soit m le minimum du vivier (m < 0). Alors C\*(i, j+1) ≥ g(C\*(i, j)), avec g(C) = f̂_j C + σ̂_j m √C. La fonction g est croissante dès que √C > −σ̂_j m/(2 f̂_j).
- On itère la borne inférieure L(i, j+1) = g(L(i, j)), à partir de la première colonne observée. Si L reste dans la zone croissante et positive, aucun tirage ne peut produire un cumul ≤ 0, quels que soient la graine et B.
- Mesures :

  | Triangle | m | Marge minimale f̂_j √L / (σ̂_j \|m\|) | Borne positive |
  |---|---|---|---|
  | `reserve2` | −1,588 | 37,7 | oui |
  | sous-triangle 5 × 5 | −1,171 | 84,3 | oui |
  | TA8 | −1,424 | 2,91 | oui |

- La mesure le confirme : aucune réplication perdue sur `reserve2` (B = 999), ni sur la sentinelle (B = 99 et 999).
- L'hypothèse du constat 1 est donc **démontrée** pour ces trois triangles.
- **[NV]** Elle ne l'est pas pour les triangles simulés sous H0 de la mesure #206 (`tests/calibration_mc_mw_t8.R`).

## 2. #257 : options comparées

V0 désigne le moteur actuel.

| Option | Fondement | Loi de référence, niveau | B effectif | Phrases de #204 | `engine_sous_graine()`, ADR 0004 | `reserve2` |
|---|---|---|---|---|---|---|
| **A0** Réplication écartée (V0, sans NaN : arrêt au premier cumul invalide) | statu quo | loi du triangle simulé sachant tous ses cumuls > 0 ; niveau inchangé | inchangé, gouverné par le signe des tirages : 38 sur 999 (TA8 l0 × 1e-15) | cas A et B posées comme aujourd'hui ; « statistique non finie » couvre la perte entière, conformément à `CONTEXT.md` | flux changé seulement en présence d'un cumul invalide (tirage arrêté plus tôt) | identique **[V]** |
| **A1** Retirage du triangle entier, plafond de 25 (B + 1) triangles au total | rejet (acceptation-rejet) : les triangles acceptés sont i.i.d. selon la loi conditionnelle à l'événement accepté (argument élémentaire, sans référence) | **même loi que A0** ; niveau limite identique, erreur Monte-Carlo réduite | = B, hors statistique non finie et hors plafond | disparaissent hors plafond ; au plafond, voir D1-4 | nombre de tirages fonction des données, même graine, aucune source nouvelle ; annotation de l'ADR 0004 | identique **[V]** |
| **A2** Retirage cellule par cellule | noyau de transition tronqué ; termine p.s. (le vivier recentré non dégénéré contient un ε > 0, et tout ε ≥ 0 donne un cumul > 0) | **loi changée** sur les triangles concernés (noyau tronqué ≠ chemin conditionné) ; niveau **[NV]** | = B toujours | disparaissent | comme A1 | identique **[V]** |
| **Troncature** (plancher positif, ou valeur absolue) | aucun | facteurs F\* artificiels près de 0 ou réfléchis, résidus extrêmes sans lien avec le modèle | = B | disparaissent | comme A0 | identique |
| **B** Loi positive de mêmes deux premiers moments (gamma de forme f̂²C/σ̂², taux f̂/σ̂²) | bootstrap **paramétrique** : abandonne le rééchantillonnage des résidus | loi changée partout : régénération de `reserve2`, calibration #206 à refaire | = B en principe, mais voir ci-dessous | disparaissent | flux entièrement changé | **changé** |

**L'option B ne résout pas le problème en double précision** **[V]**.
- `rgamma(1e5, shape = 1e-10)` rend 100 % de zéros ; avec une forme de 1e-3, 47,8 %.
- Sur une ligne de poids faible, la forme f̂²C/σ̂² est de cet ordre ou inférieure : le cumul nul reparaît.
- B n'est pas défendable à T = 8 sans nouvelle calibration. Elle est écartée.

**Mesures.** `mw_bootstrap()` a été reproduit hors du moteur ; ses `p_mc` et ses `B_effectif` sont contrôlés `identical()` à ceux du moteur dans les dix cas.

| Triangle | B | V0 : réplications perdues (cumul) / avertissements / B_eff | A1 : triangles tirés / retirés / B_eff | A2 : cellules retirées / B_eff |
|---|---|---|---|---|
| `reserve2` | 999 | 0 / 0 / 999 | 999 / 0 / 999 | 0 / 999 |
| 5 × 5 | 99, 999 | 0 / 0 / 99, 999 (a) | identique à V0 | identique à V0 |
| TA8 | 999 | 0 / 0 / 999 | identique à V0 | identique à V0 |
| TA8, ligne 0 × 1e-15 | 999 | 961 / 961 / 38 | 24 212 / 23 213 / 999 | 4 700 / 999 |
| TA8, ligne 0 × 1e-17 | 999 | 966 / 966 / 33 | **25 000 (plafond)** / 24 161 / **839** | 5 335 / 999 |
| TA8, ligne 4 × 0,03 | 199 | 48 / 43 / 151 | 254 / 55 / 199 | 70 / 199 |
| TA8, ligne 4 × 0,01 | 199 | 78 / 67 / 121 | 329 / 130 / 199 | 120 / 199 |
| TA8, ligne 4 × 0,003 | 199 | 115 / 89 / 84 | 437 / 238 / 199 | 227 / 199 |
| triangle de contrôle (`reserve2`), ligne 0 × 1e-17 | 999 | 921 / 921 / 78 | 12 351 / 11 352 / 999 | 3 084 / 999 |

(a) Sur le 5 × 5, HomogF, Courbure et ExpVar ont un B_eff nul : leur statistique observée n'est pas finie, comme aujourd'hui.

Les valeurs V0 reproduisent celles de l'issue (38, 33, 78, 151, 121, 84) **[V]**. Sur `reserve2`, TA8 et la sentinelle, les matrices simulées de A1 et A2 sont `identical()` à celles de V0 **[V]**.

**A1 et A2 sur TA8, ligne 0 × 1e-15** (B = 999) **[V]** :

| Ligne | p sous A1 | p sous A2 |
|---|---|---|
| Calendrier | 0,132 | 0,174 |
| DW | 0,242 | 0,292 |
| Runs | 0,586 | 0,650 |
| CorrDev | 0,068 | 0,078 |

Ces écarts valent de 1,8 à 2,9 écarts-types Monte-Carlo de la différence (les deux flux ne sont pas indépendants). C'est une indication, pas une preuve, de la différence de loi qu'implique la construction de A2.

**Niveau à T = 8.**
- Sur le plan de `reserve2` (#206), A0, A1 et A2 laissent les p inchangées, puisqu'aucun rejet n'y est possible (§ 1) **[V]**.
- Sur un triangle à ligne de poids faible, le niveau des p Monte-Carlo n'est mesuré sous aucune option **[NV]**.
- Les triangles construits de l'issue contredisent M2 : les facteurs de la ligne multipliée gardent la dispersion d'une ligne lourde. Ils éprouvent le logiciel ; ils ne calibrent pas un niveau.

**Choix : A1** (D1-1). C'est la seule option qui réunit les quatre propriétés suivantes :
- (i) elle ne change pas la loi de référence du moteur actuel, donc ne crée aucun risque de niveau nouveau ;
- (ii) elle rend B effectif = B, hors plafond ;
- (iii) elle laisse `reserve2` et la sentinelle identiques, quelle que soit la graine ;
- (iv) elle supprime les NaN.

## 3. #257 : spécification retenue (A1)

1. **`mw_simuler_triangle(aj, res_pool)`** : même signature et même type de retour (matrice).
   - À chaque colonne, après le calcul des nouveaux cumuls, si l'un d'eux est non fini ou ≤ 0 : ces cellules reçoivent `NA`, et la fonction rend aussitôt la matrice, les colonnes suivantes restant à `NA`.
   - Aucune racine d'un cumul négatif n'est calculée, donc aucun avertissement n'est émis.
   - Tant qu'aucun cumul invalide n'est tiré, la consommation d'aléa est identique : un `sample()` par colonne, dans le même ordre.
   - Commentaire de remplacement des l. 8740-8741 (ASCII, sans accents) :

     ```
     # Cumul simule non strictement positif ou non fini (ligne de poids faible :
     # sigma_j sqrt(C_ij) >> f_j C_ij) : le modele de Mack n'est defini que pour
     # des cumules strictement positifs (variance proportionnelle a C_ij). Le
     # triangle est rendu des le premier tel cumul, cellule a NA et colonnes
     # suivantes non tirees, sans racine carree d'un cumul negatif (#257) ;
     # mw_bootstrap() en tire un autre. Loi de reference : celle du triangle
     # simule sachant tous ses cumuls strictement positifs (la meme qu'avant
     # #257, ou la replication etait ecartee).
     ```

2. **`mw_bootstrap()`**, par une fonction nommée partagée (par exemple `.mw_tirer_triangle_valide(aj, pool, reste)`) :
   - Pour chaque b, retirer tant que le triangle a un `NA` dans sa partie supérieure (même test qu'à la l. 8810) et que le total des triangles tirés reste sous `FACTEUR_B_MAX_MW` (B + 1), avec `FACTEUR_B_MAX_MW = 25` (D1-2).
   - Plafond atteint : les réplications restantes valent `NA`.
   - Les pertes par échec de `mw_ajuster()` ou de `.mw_stats()` ne sont **pas** retirées. Elles restent des statistiques non finies, comptées dans B effectif comme aujourd'hui.
   - Le reste est inchangé (`sigma_boot` calculé sur les triangles acceptés, `.mc_p_values()`).
   - Les boucles des tests unitaires qui reproduisent celle de `mw_bootstrap()`, sauts compris, passent par la même fonction partagée.

3. **Traçabilité** (D1-3 (a)).
   - Deux champs logiques dans `bootstrap` :
     - `cumuls_retires` : au moins un triangle a été retiré ;
     - `plafond_cumuls` : le plafond a été atteint.
   - Sur `reserve2`, les deux valent `FALSE`. Ils y sont posés par un patch chirurgical de `tests/reference/reserve2.rds` (booléens seulement, invariant du patcher), sans toucher aucune valeur numérique.
   - Deux phrases fixes, **sans nombre** issu du bootstrap : la règle #76 reste entière, et « 25 (B + 1) » est une formule.
     - si `cumuls_retires` : « Triangles simules a cumul non strictement positif ecartes et remplaces par un nouveau tirage : p-value Monte-Carlo conditionnelle a la positivite des cumuls simules. »
     - si `plafond_cumuls` : « Plafond de 25 (B + 1) triangles simules atteint : des replications manquent faute de triangle simule a cumuls strictement positifs. »
   - `mw_tests()` les joint sur ses 13 lignes Monte-Carlo, **avant** la phrase de #204 ; celle de #244 reste la dernière.
   - Le nombre de triangles retirés n'est pas restitué (D1-3).

4. **Phrases de #204** : leur texte ne change pas.
   - Hors plafond, elles ne paraissent plus que pour des statistiques non finies : la parenthèse « statistique non finie » devient exacte.
   - Au plafond : voir D1-4.
   - Au plafond avec B_eff < 50 : motif générique `MOTIF_MC_REPLIC_INSUFFISANTES`, aucun motif nouveau ; la règle de #181 s'applique.

5. **ADR 0004** (étape 7, `architect`).
   - Le nombre de tirages consommés par `mw_bootstrap()` devient fonction des données, comme dans V3b, mais dans le même flux et sous la même graine.
   - Aucune source d'aléa nouvelle ; les points 2 et 3 de l'ADR tiennent.
   - Les étapes 7 et 8 mettent à jour `CONTEXT.md` (« conditionnelle à la définition » : une réplication n'est plus perdue entière par un cumul ≤ 0 qu'au plafond) et le `.tex`.

**Tests attendus.** Ils procèdent par relations, sans compte de tirages codé en dur, comme `5541cc8`.

| Test | Triangle et paramètres | Attendu |
|---|---|---|
| T257-1 | `reserve2`, `run_engine()` | `comparer_references.R --seuil 0` : 0 écart numérique ; deux feuilles logiques ajoutées, à `FALSE` |
| T257-2 | `reserve2` | borne de positivité du § 1 positive (documente l'identité) |
| T257-3 | TA8, ligne 0 × 1e-15, B = 999 | aucun avertissement ; B_eff = 999 sur les 13 statistiques (après #253) ; `cumuls_retires` vrai, `plafond_cumuls` faux ; aucune phrase « B effectif = » ; phrase de retirage sur les 13 lignes Monte-Carlo |
| T257-4 | TA8, ligne 0 × 1e-17, B = 999 | plafond atteint ; B_eff < B et égal entre statistiques définies ; phrase du plafond |
| T257-5 | TA8, ligne 4 × 0,03, × 0,01 et × 0,003, B = 199 | B_eff = 199 partout ; aucun avertissement |
| T257-6 | TA8, ligne 0 × 1e-15 | `.Random.seed` et `RNGkind()` de l'appelant inchangés ; deux appels `identical()` |
| T257-7 | sentinelle 5 × 5 | test des l. 2007-2030 inchangé et vert |
| T257-8 | `mw_simuler_triangle()` avec un vivier forcé (`-1e6`) | `NA` dans la première colonne tirée, aucun avertissement |

## 4. #253 : constat, élargi par la mesure

**Constat.**
- `mw_test_courbure()` appelle `lm(C1 ~ C0 + I(C0^2), weights = 1/C0)`. Quand `lm()` écarte le terme quadratique, la colonne est **écartée en silence** (`next`, l. 8453).
- `.mw_lm_intra()` rend `NULL` quand `lm()` écarte C.

**Grille de mesure.** `reserve2` et TA8, avec la ligne 0 ou la ligne 3 multipliée par 10^e, e ∈ {5, 8, 10, …, 17, 20, 25, 30, −10, −15, −17, −20, −30}, plus les deux bases : 74 triangles, 296 régressions de colonne. La référence est rationnelle exacte.

**Moteur actuel** **[V]** :
- **Courbure, NA sur toutes les colonnes** : dès e = 13 pour `reserve2` (lignes 0 et 3), dès e = 14 pour TA8 (lignes 0 et 3).
- **Courbure, exclusion silencieuse partielle avant le NA** :
  - `reserve2`, ligne 3, e = 12 : 1 colonne sur 4 ;
  - TA8, ligne 0, e = 12 : 1 sur 4 ; e = 13 : 3 sur 4 ;
  - TA8, ligne 3, e = 13 : 3 sur 4.
- **PenteIntra, NA** : dès e = 15 (quatre cas), et aussi pour une **ligne 0 de poids faible** (e ≤ −15, `reserve2` et TA8), mais pas pour la ligne 3. Ce dernier point n'est pas dans l'issue.
- **Précision avant le NA** : erreur relative jusqu'à 5,2·10^-8, pour la courbure comme pour la pente. Sur `reserve2` non modifié, elle vaut 1,8·10^-13 et 1,2·10^-13.
- **Dans le bootstrap** :
  - `reserve2`, ligne 0 × 10^12, B = 199 : la courbure rend p_mc = 0,0337 (ECHEC) avec B_eff = 177, alors que le calcul exact donne 0,085 (ALERTE) avec B_eff = 199 ;
  - ligne 3 × 10^12 : la statistique observée vaut 11,617 (K = 3, une colonne écartée en silence) au lieu de 14,034 (K = 4).
  - Les exclusions silencieuses changent donc la définition de la statistique d'une réplication à l'autre.

**Candidats mesurés** (erreur relative maximale contre la référence exacte) **[V]** :

| Candidat | Courbure | PenteIntra |
|---|---|---|
| `lm()` actuel | NA dès e = 13 ; 5,2·10^-8 avant | NA dès e = 15 et e ≤ −15 (ligne 0) |
| `lm(…, tol = 1e-300)` | défini, mais erreur 6,3 à e = 30 (`reserve2`, ligne 0) | défini, erreur 0,53 à e = 30 |
| **régresseur centré-réduit** (proposé par l'issue) | **NA dès e = 8**, et aussi à e ≤ −15 | NA aux mêmes points que `lm()` |
| QR Householder à pivotage de colonnes, lignes triées | erreur jusqu'à 6,8 ; `Inf` (TA8, ligne 0, e = 30) | non retenu |
| **forme close (§ 6)** | **1,05·10^-13** sur les 296 régressions | **3,8·10^-15** sur les 74 triangles |

Le centrage-réduction est **écarté** : il rapproche les régresseurs des petites lignes à 10^-e près, et perd donc l'information plus tôt.

## 5. #253 : options

- **(R) Calcul en forme close de la même statistique** (recommandé, D1-5) :
  - la définition ne change pas : t de Student de la régression pondérée, degrés de liberté, p de Student, combinaison de Fisher ;
  - les statistiques sont définies sur tout le domaine mesuré ;
  - plus aucune exclusion silencieuse par rang numérique ;
  - `reserve2` : verdicts et p_mc identiques **[V]**.
- **(M) Motif explicite** :
  - toute colonne dont `lm()` écarte le terme rend la statistique `NA` pour le triangle, ce qui met fin à l'exclusion silencieuse ;
  - le motif passe par le champ `non_definie` du catalogue, par exemple « terme non estimable en double precision (rang numerique de lm()) » ;
  - la ligne devient « non applicable », verdict INFO, `p_retenue = NA` ;
  - option simple, mais le seuil (tolérance 1e-7 de `lm()`) n'a aucun sens statistique, la précision avant le seuil reste de 10^-8, et les réplications proches du seuil deviennent `NA` (B effectif < B).

## 6. #253 : spécification retenue (R)

### Courbure

Le calcul se fait par colonne retenue. Les gardes actuelles ne changent pas : n_j ≥ 4, colonne figée ou dégénérée, `sd(C0) == 0`.

Données de la colonne :
- x_i = C(i, j) ;
- e_i = C(i, j)·(F(i, j) − f̂_j), écart stable de `.mw_ecart_facteur_stable()` (#233) ;
- w_i = 1/x_i.

Le t du terme quadratique ne change pas quand on remplace C(i, j+1) par e (opération sur les colonnes [1, x, y]).

Notations :
- pour une partie S, w_S = ∏_{i∈S} w_i ;
- pour S = {k < l < m} : V(S) = (x_l − x_k)(x_m − x_k)(x_m − x_l) et D(S) = (x_l − x_k)(e_m − e_k) − (x_m − x_k)(e_l − e_k) ;
- pour Q à quatre éléments : V₄(Q) = ∏_{a<b} (x_b − x_a), et la différence divisée e[Q] = Σ_{a∈Q} e_a / ∏_{b≠a} (x_a − x_b).

Formules :
- A = Σ_S w_S V(S)² ;
- ĉ = Σ_S w_S V(S) D(S) / A (règle de Cramer et formule de Cauchy-Binet) ;
- A₀ = Σ_{k<l} w_k w_l (x_l − x_k)² ;
- SCR = Σ_Q w_Q (V₄(Q) e[Q])² / A (déterminant de Gram de [X, e] divisé par celui de X) ;
- t_j = ĉ / √( SCR/(n_j − 3) · A₀/A ) ;
- p_j = 2·Pr(T_{n_j−3} > |t_j|).

Ce sont des identités exactes de la régression pondérée : en arithmétique exacte, ce t est celui de `lm()`. Aucune référence n'est citée pour la formule de Cauchy-Binet, classique mais non relue dans un ouvrage. La preuve tient en trois lignes, et la référence rationnelle contrôle l'identité.

Précisions :
- **Mise à l'échelle.** x peut être ramené à x/max(x), puisque t est invariant.
- **Domaine.** Les produits doivent rester finis sur le domaine [1e-50 ; 1e50] de #185, par exemple grâce à un calcul en logarithme avec signe.
  - Le triangle « bornes » (ligne 0 portée à 1e50, ligne 3 à 1e-50) est mesuré fini, exact à 1,2·10^-13 **[V]**.
  - Un triangle à plusieurs lignes à 1e-48 et une ligne à 1e48 reste à tester ; la version mesurée y déborderait **[H]**.
- **Colonne à un degré de liberté.** La colonne n_j = 4 est **conservée** (Q-E2c-1 (A)) ; SCR y vient d'une seule partie Q. Mesure : t₃ = −3,462887950378827 sur `reserve2` **[V]**.
- **Non-identifiabilité exacte** (moins de trois valeurs distinctes de C(i, j), soit A = 0 exactement). La colonne est écartée, comme aujourd'hui sous la garde `sd() == 0` et selon la doctrine de #90 (D1-7). Ce cas ne dépend pas des réplications : la colonne 0 est figée et les cumuls simulés sont continus.

### PenteIntra

Calcul dans `.mw_lm_intra()` ; les gardes ne changent pas.
- Poids : w_i = C_i/σ̂_j².
- Dans chaque colonne, C̃_i = Σ_k w_k (C_i − C_k)/Σ_k w_k, et F̃_i de même : centrage pondéré par différences deux à deux, sans annulation.
- β̂ = Σ w C̃ F̃ / Σ w C̃².
- u = F̃ − β̂ C̃.
- ddl = N − G − 1, où G est le nombre de colonnes.
- se = √(Σ w u² / ddl / Σ w C̃²).
- La fonction rend `c(Estimate, Std. Error, t value, Pr(>|t|))`, sur le modèle de la ligne `co["C", ]`.

Fondement : théorème de Frisch et Waugh (1933), appliqué à la régression pondérée, c'est-à-dire aux moindres carrés ordinaires sur les lignes multipliées par √w. Retirer les indicatrices de colonne revient à centrer en moyenne pondérée dans chaque colonne. Si Σ w C̃² = 0 exactement, la fonction rend `NULL`, comme aujourd'hui.

### Invariance d'échelle attendue

- **Échelle globale.** Les deux t sont invariants quand on multiplie le triangle entier par λ > 0. C'est exact en arithmétique : σ̂_j² est homogène de degré 1, et le poids w de la pente est invariant.
  - Mesure pour λ = 10^k, k ∈ {−45, −40, −20, −10, 10, 20, 40, 43} : écart ≤ 2,3·10^-13 avec le moteur actuel, ≤ 7,9·10^-14 avec la forme close **[V]**.
- **Échelle d'une seule ligne.** Ce n'est pas une invariance, puisque le triangle change. La statistique tend vers une limite quand e → ±∞. La référence exacte est stable à six chiffres pour e ≥ 8, et pour e ≤ −15 sur la pente **[V]**.

### Catalogue, effet sur `reserve2`, verdicts nouveaux

**`MW_CATALOGUE_MC`** : entrées inchangées (mêmes fonctions nommées). Le contrat partagé n'est pas touché (C-E2d-3).

**Effet sur `reserve2`** **[V]** :
- 6 feuilles numériques diffèrent, d'au plus 1,39·10^-13 en relatif (`tests[[4]]$p_asymptotique`) : statistiques et p asymptotiques des deux lignes, et `stats_obs` ;
- p_mc, p retenues, types et verdicts identiques ;
- sentinelle 5 × 5, B = 99 et 999 : verdicts, types et p retenues identiques ;
- écarts sous `TOLERANCE` : aucune régénération (Q-E2d-11).

**Lignes `NA` qui reçoivent un verdict** (`run_engine()`, B = 199, `reserve2`) **[V]**. Ces lignes sont aujourd'hui « non applicable », verdict INFO, motif « statistique observee non finie ».

| Cas | Courbure après #253 | PenteIntra après #253 |
|---|---|---|
| ligne 0, e = 13, 15, 20, 30 | ALERTE, p = 0,085 | OK, p = 1,000 (dès e = 15) |
| ligne 3, mêmes e | ALERTE, p = 0,080 | OK, p = 0,710 |
| e = 12, ligne 0 | ECHEC 0,0337 → ALERTE 0,085 | — |
| e = 12, ligne 3 | p 0,085 → 0,080 | — |

Lignes de poids faible (e = −15, −20, −30) :
- **après #253 seul** : la pente de la ligne 0 devient définie (−1,121), mais la ligne reste un diagnostic, avec un B_eff de 14 à 17 dont la cause est #257 ;
- **après #253 et #257 (A1)**, ligne 0 : courbure OK (p de 0,10 à 0,115), pente ECHEC (p de 0,01 à 0,02) ;
- **après #253 et #257 (A1)**, ligne 3 : courbure OK, sauf à e = −30, en ALERTE (p = 0,075) ; pente OK.

Tous ces cas sont hors des références.

### Tests attendus

Les valeurs sont écrites en dur et recalculables par un script hors CI (Rmpfr, Q-E2c-5). Contrôle croisé : la référence rationnelle de la présente mesure.

| Test | Contenu | Attendu |
|---|---|---|
| T253-1 | `reserve2` | courbure t = 0,93422764996969232 ; −1,9823633206000404 ; −9,1618120029068368 ; −3,462887950378827 (n = 7, 6, 5, 4) ; PenteIntra t = 0,2600197442537881, à 1e-12 |
| T253-2 | `reserve2`, ligne 0 × 1e30 | courbure t = −3,2321868753333782 ; −2,6230673521146479 ; −1,2246845553777297 ; 0,27555322316525688 ; pente −0,64792170590960629 |
| T253-2 | `reserve2`, ligne 3 × 1e30 | courbure t = −1,7637144365936694 ; −3,1751739033668485 ; −1,0848619801581147 ; −1,9731120214984617 ; pente 0,58992812949620965 |
| T253-2 | `reserve2`, ligne 0 × 1e-30 | courbure t = 3,1467379665547841 ; 2,1589835486730493 ; 0,79635768376122973 ; −0,58330789698280028 ; pente −1,120997177810577 |
| T253-2 | tolérance des trois lignes précédentes | 1e-10 |
| T253-3 | lignes 0 et 3 × 10^e, e ∈ {12, …, 17, 20, 25, 30} | deux statistiques finies, K = 4 partout |
| T253-4 | échelle globale, λ = 10^±20 et 10^±40 | écart ≤ 1e-12 |
| T253-5 | triangle « bornes » | courbure t = 0,081519213694489751 ; −2,013620676168856 ; −4,5274309238335313 ; −6,6723491946328828 ; pente −0,65007141204537222, à 1e-10 |
| T253-5 | triangle à deux échelles extrêmes | résultat fini |
| T253-6 | colonne à deux valeurs distinctes de C | colonne écartée (K réduit) ; pente à C constant par colonne : `NA` |
| T253-7 | `reserve2` | verdicts, types et p retenues identiques ; dérive `--seuil 0` consignée dans le message du commit |

**Durée** de `run_engine(reserve2)` : 55,2 s avant, 42,6 s après, sur une machine chargée par d'autres sessions. Chiffres indicatifs, à remesurer.

## 7. Effet attendu

- **σ_USP** : inchangé (constat 3 de la fiche).
- **#253** : `reserve2` change sous `TOLERANCE` (≤ 1,4·10^-13) ; p_mc, p retenues, verdicts et sentinelle identiques.
- **#257 (A1, D1-3 (a))** : `reserve2` identique au bit près sur toutes ses valeurs numériques, plus deux feuilles logiques posées par patch chirurgical ; sentinelle identique.
- **Hors références** :
  - B effectif et p_mc changent sur les triangles à ligne de poids faible (§ 2) ;
  - les lignes de courbure et de pente deviennent définies (§ 6), et plusieurs verdicts changent ; tous sont listés plus haut.

## 8. Visas

- Aucun verdict de référence ne change : pas de visa sur les références.
- Les changements de p hors références sont validés par `actuary`.
- Les verdicts nouveaux sur triangles construits sont couverts par D1 (fiche, « Effet attendu ») : le mainteneur les approuve à D1.

## 9. Surface documentaire (passage unique de `docwriter`)

- `.tex`, l. ~3982-3995 : citer #257, décrire A1 et la loi conditionnelle.
- `.tex`, l. ~1465 : description de `mw_simuler_triangle()`.
- `.tex`, l. ~3726-3767 : sens de B effectif.
- Fiche `mw:m1` : calcul par centrage intra-colonne ; l. ~12575 : ses avertissements ne viennent plus de `lm()`.
- Fiche `mw:m1c` : formule close. La phrase « summary() est appelé par .mw_summary_lm() » y devient fausse pour la courbure.
- `.tex`, l. ~968-975 (table de #203) : à revoir.
- Index des fonctions, si une fonction est ajoutée.
- `CONTEXT.md` : étape 7.

## 10. Hors périmètre

- Niveau des p Monte-Carlo sur un plan à ligne de poids faible (mesure proposée, non faite).
- Ordonnée à l'origine : `lm()` inchangé ; son comportement sur la même grille n'a pas été mesuré **[NV]**.
- #245 et M5.
- Branche lognormale.

## Questions au mainteneur pour D1

- **D1-1** — traitement des cumuls non positifs (#257). *Recommandation* : **A1**. *Alternative* : A0 (l'écartement actuel, sans les NaN).
- **D1-2** — plafond : 25 (B + 1) triangles au total, sous une constante distincte `FACTEUR_B_MAX_MW = 25`. *Alternative* : réutiliser `FACTEUR_B_MAX_REGIME`.
- **D1-3** — traçabilité. *Recommandation* : (a) deux champs logiques et deux phrases fixes sans nombre, avec un patch non numérique de `reserve2`. *Alternative* : (b) un champ numérique de comptage, qui impose une régénération.
- **D1-4** — texte au plafond. *Recommandation* : le texte de #204 reste inchangé et la phrase du plafond le précède. *Alternative* : modifier la parenthèse du cas A.
- **D1-5** — voie pour #253. *Recommandation* : **(R)**, forme close. *Alternative* : (M), motif explicite.
- **D1-6** — périmètre de #253. *Recommandation* : y inclure la pente sur ligne de poids faible et les exclusions silencieuses partielles de la courbure. *Alternative* : une issue séparée.
- **D1-7** — non-identifiabilité exacte. *Recommandation* : la colonne est écartée, selon la doctrine de #90. *Alternative* : `NA` avec un motif `non_definie`.

## Sources en ligne consultées

- Frisch, R. et Waugh, F. V. (1933), « Partial time regressions as compared with individual trends », *Econometrica* 1(4), 387-401. Consultées le 13/10/2026 : notice de l'Econometric Society et copie de l'université d'Oslo. Texte intégral non relu.

---

## Annotation du 13/10/2026 : décisions du mainteneur à D1

Le mainteneur a tranché les sept questions selon les recommandations, en session :
- **D1-1** : A1, retirage du triangle entier ;
- **D1-2** : plafond de 25 (B + 1), constante distincte `FACTEUR_B_MAX_MW` ;
- **D1-3** : (a) deux booléens, `bootstrap$cumuls_retires` et `bootstrap$plafond_cumuls`, et deux phrases fixes sans nombre ; patch chirurgical de `reserve2` ;
- **D1-4** : texte de #204 inchangé, la phrase du plafond le précède ;
- **D1-5** : (R), calcul en forme close ;
- **D1-6** : périmètre de #253 élargi à la pente sur ligne de poids faible et aux exclusions silencieuses partielles de la courbure ;
- **D1-7** : colonne exactement non identifiable écartée, selon la doctrine de #90.

Il approuve aussi les verdicts nouveaux sur triangles construits listés aux § 6 et 7, tous hors des références. #257 et #253 passent en `ready-for-agent`, et les étapes 5 (#253) et 6 (#257) de la fiche E2d peuvent commencer.

## Annotation du 13/10/2026 : mise en œuvre de #253 (étape 5) et avis d'`actuary`

Cette annotation vient d'`actuary`, consulté sur le diff de l'étape 5. Elle ne remplace pas le texte ci-dessus : elle le précise.

- **§ 6, courbure : développement du déterminant.**
  - Le code forme SCR = Σ_Q w_Q det_Q² / A, avec det_Q = Σ_r (−1)^r e_{a_r} V(Q∖a_r) : c'est le développement de Laplace selon la colonne e.
  - Quand les x sont distincts, det_Q vaut ±V₄(Q) e[Q], même quantité que l'écriture du § 6. Le développement reste en outre défini en présence d'ex æquo de C(i, j), pourvu qu'il y ait au moins trois valeurs distinctes. L'écriture V₄(Q) e[Q] y donnerait NaN (V₄ = 0, e[Q] = ±Inf).
  - Mesure contre une référence rationnelle indépendante (équations normales complètes) : erreur ≤ 1,2·10^-14 sur des colonnes à ex æquo et quasi-ex æquo **[V]**.
  - Les produits et les sommes sont formés à exposant séparé (`.mw_me()`, `.mw_somme_me()`). C'est ainsi qu'est mis en œuvre le « par exemple » du § 6 sur le domaine [1e-50 ; 1e50].
  - L'hypothèse **[H]** du triangle à deux échelles extrêmes (ligne 0 à 1e48, lignes 1 à 3 à 1e-48) est **confirmée** : statistiques finies, erreur 3,4·10^-14 contre la référence exacte **[V]**.
- **§ 4, précision de l'ancien moteur hors grille.**
  - Sur `reserve2`, ligne 0 × 10^-14, `lm()` (moteur de `68360f4`) rend une pente intra-colonne t = −2,5664165744012393, au lieu de −1,12099717781044. L'erreur relative vaut 1,29, sans NA ni avertissement **[V]**.
  - L'erreur maximale de 5,2·10^-8 annoncée au § 4 ne vaut donc que sur les points de la grille.
  - Ce cas renforce l'abandon de la voie (M) : un motif fondé sur le rang de `lm()` ne l'aurait pas intercepté.
  - Effet : la statistique affichée passe de −2,566 à −1,121. Le verdict reste INFO tant que #257 n'est pas traité (B effectif < `B_MIN_DEGENERESCENCE`). Il sera calculé sur la valeur juste après l'étape 6. Ce triangle construit n'est pas dans la liste approuvée à D1 : le mainteneur en est informé.
  - Un test unitaire fige la valeur juste. Une phrase de la fiche `mw:m1` du `.tex` citera ce constat au passage de `docwriter`.
- **§ 10, hors périmètre, ajout.**
  - Une colonne exactement affine construite donne un t non significatif numériquement : rapport de bruits d'arrondi, comme sous `lm()`, qui ne s'en distinguait que par un avertissement.
  - L'ajustement parfait exact (G = 0) donne t = ±Inf, puis p = 0 relevée au plancher de `.fisher_combine()`. Si N = 0 aussi, t = NaN et la statistique vaut NA (règle de #90). C'est un événement de probabilité nulle sous le modèle de Mack.
  - Aucune garde à seuil n'est ajoutée : elle réintroduirait un seuil numérique sans sens statistique (motif de rejet de (M)).
- **Traçabilité des valeurs écrites en dur** (§ 6, « Tests attendus »). Elles sont recalculées par un script R hors CI versionné, `tests/unitaires/generer_valeurs_forme_close_m1.R`.
  - Il utilise Rmpfr (Q-E2c-5), à 4 096 bits puis 8 192 bits, avec un contrôle de stabilité des 17 chiffres.
  - Sa méthode est indépendante de la forme close : équations normales complètes, élimination de Gauss.

## Annotation du 14/10/2026 : prémisse de D1-7 corrigée (E2e, #269, #270)

Annotation d'`architect`, étape 6 de la fiche « Branche E2e ». Elle ne remplace pas le texte ci-dessus : elle le corrige.

- **§ 6, « Non-identifiabilité exacte »** : la phrase « Ce cas ne dépend pas des réplications : la colonne 0 est figée et les cumuls simulés sont continus » est **fausse pour j ≥ 1** (spécification d'E2e, `docs/specifications/e2e-niveaux-et-documentation.md`, § 4).
  - La colonne était écartée à l'observé. Pour j ≥ 1, elle était **combinée** dans les réplications, faute d'ex æquo dans les cumuls simulés : K = 3 à l'observé contre 4 dans 999 réplications sur 999 (triangles construits T1, T2 et T4).
  - Seule j = 0, figée par `mw_simuler_triangle()`, se reproduisait.
- **Correction** : #270 (`4f69677`, option (a), D1-5 et D1-6 d'E2e). L'ensemble des colonnes non identifiables est figé à l'observé (`.mw_colonnes_courbure_non_identifiables()`, argument `j_non_identifiables`). Une colonne retenue mais non identifiable dans une réplication rend la statistique `NA`. L'exclusion est restituée dans le `detail` par #269 (`ec3c7dc`). Voir `CONTEXT.md`, « Colonne non identifiable (courbure) ».
- **D1-7 n'est pas rouvert** : la colonne exactement non identifiable reste écartée à l'observé. Seule sa prémisse, et donc le traitement des réplications, change.
