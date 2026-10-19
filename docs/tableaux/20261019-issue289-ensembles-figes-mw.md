## Contrôle #289 : ensembles figés de M1 (courbure, ordonnée à l'origine) à T = 8, Merz-Wüthrich

### T0 — provenance

| Grandeur | Valeur |
| --- | --- |
| Mode | --controle-289 (#289, spécification de Fi, par. 5) |
| DGP sous H0 (par. 2 de #206) | modèle de Mack ajusté à reserve2 (mw_ajuster(), tests/donnees/triangle_mw.csv), I = J = 7 ; f̂ = (3,20372 ; 1,65175 ; 1,32525 ; 1,15042 ; 1,09469 ; 1,06455 ; 1,02841) ; σ̂² = (0,72404 ; 0,71209 ; 0,69814 ; 0,31478 ; 0,097325 ; 0,18967 ; 0,097325), dont σ̂²_6 extrapolé ; première colonne fixée (300,0000 ; 311,4286 ; 322,8571 ; 334,2857 ; 345,7143 ; 357,1429 ; 368,5714 ; 380,0000) ; colonnes dégénérées de reserve2 : 6 ; conformes aux valeurs arrondies du par. 2 : oui ; lois : N (stats::rnorm), E (loi uniforme sur les 27 valeurs de .mw_pool_residus(aj0, jd0) divisées par leur écart-type de population 0,9988 ; pool : asymétrie -0,159, excès de kurtosis -1,393, bornes [-1,588 ; 1,452], bornes après division [-1,590 ; 1,454]), A ((G − 2)/√2, G ~ Gamma(2) par stats::qgamma(stats::runif(n), 2)) ; générateur gen_triangle_h0() |
| Configuration | méthode reserve2, segment 1 de l'annexe II ; B = 999 (donnée du test calibré) ; α des verdicts = 0,10 ; seuils mesurés 0,10 et 0,05 ; chemin mesuré mw_bootstrap() + mw_tests() (identité à run_engine() : contrôle (i2)) ; B_MIN_DEGENERESCENCE = 50 |
| Plan | volet 1 (observé) : N 2000 (b = 1..2000), E 2000 (b = 1..2000), A 1000 (b = 1..1000) ; volet 2 (réplications) : b = 1..50 de chaque loi, 150 triangles, B = 999, catalogue réduit {Sonde, Origine, Courbure} injecté dans MW_CATALOGUE_MC |
| Graines (par. 7 de #206) | triangle b, loi ℓ : 20840000 + 10000 (ℓ − 1) + b ; bootstrap b, loi ℓ (les deux pools) : 20870000 + 10000 (ℓ − 1) + b ; oracle k, loi ℓ : 20900000 + 20000 (ℓ − 1) + k ; ℓ = 1 (N), 2 (E), 3 (A) ; contrôles sur reserve2 : 20260831 |
| Graines : recherche des collisions | plages triangles 20840001-20862000, bootstrap 20870001-20892000, oracle 20900001-20960000 (disjointes : oui) ; 31 littéraux de graine dans 67 fichiers (R/engine.R, tests/*.R, tests/unitaires/*.R), de 20260831 à 23700237 ; littéraux L dont [L ; L + 20000] touche une plage : 20840001, 20960000 ; littéraux au-dessus des plages (sans collision ; annotation du 10/10/2026 de la spécification, point 1) : 21000000, 21100000, 21200000, 23700237 ; littéraux en écriture scientifique non recherchés ; SEED_LOI_NULLE_SW 20260901, graine de reserve2 20260831 et réseau 20260831 + 1000 k ≤ 20760831 de tests/puissance_t8.R hors des plages : oui |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Commit | 42323cff55fd5d0683594c858154c4018135cb42 |
| Plateforme de calcul (R, système, machine, BLAS, LAPACK) | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : libblas.so.3.12.0 ; LAPACK : liblapack.so.3.12.0 (version 3.12.0) |
| Processus (mclapply) | 4 |
| Empreintes md5 du code exécuté | R/engine.R a6250d419ea27cb2e87bf4ed70dac453 ; tests/outils_tests.R chargé (dépôt) 7127605f20e8c261d41d3c372f4f2f1b ; script exécuté (dépôt) d35b0f92d648732dbb570cb00c7fca07 ; docs/specifications/206-calibration-mc-merz-wuthrich.md 0bef6cde9d64fd6ab053ef2a015dc405 |
| Empreinte sans commentaires de R/engine.R (#231) et md5 du fichier entier | 6ce112eecc6a7e9b6500ab639e757891 (md5 du fichier entier a6250d419ea27cb2e87bf4ed70dac453) |
| Contrôle (a) : reserve2 contre tests/reference/reserve2.rds | conforme ; 4470 feuille(s), 0 non strictement identique(s), écart maximal 0.000e+00 |
| Brut de #206 (comparaison descriptive) | docs/tableaux/20261011-issue206-calibration-mw-brut.tsv (md5 c4c7ac003ff1f501034a2d96e17ae196), commit de #206 3a95e11400f2e770c6d7242c88a9e67fd394ca28, md5 de R/engine.R de #206 25bff84c7828b632fe2b260b64663c9f |
| Locale LC_CTYPE (origine → travail) | C.UTF-8 → C.UTF-8 |
| Durée (s) | contrôles généraux et identité de l'injection 128 ; volet 1 18 ; volet 2 1234 ; total 1384 |
| Contrôles d'intégrité | OK (1 signalement sans effet, voir (graines)) |

### T1 — volet 1 : ensembles figés et K à l'observé (triangles du plan de #206)

Ensembles de `.mw_ensembles_figes(aj)` et K des deux vérifications, calculés comme `mw_bootstrap()` les fige (défaut du moteur, sur le triangle admis). La colonne `degeneres` liste les valeurs distinctes observées de l'ensemble avec leur effectif ; `∅` : ensemble vide.

| Loi | triangles | admis | refusés | en erreur | `degeneres` (valeurs : effectif) | `non_identifiables` non vide (courbure) | `origine_non_identifiables` non vide | K ordonnée (valeur : effectif) | K courbure (valeur : effectif) | statistique observée NA (O ; C) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | 2000 | 2000 | 0 | 0 | 6 : 2000 | 0 | 0 | 5 : 2000 | 4 : 2000 | 0 ; 0 |
| E | 2000 | 2000 | 0 | 0 | 6 : 2000 | 0 | 0 | 5 : 2000 | 4 : 2000 | 0 ; 0 |
| A | 1000 | 1000 | 0 | 0 | 6 : 1000 | 0 | 0 | 5 : 1000 | 4 : 1000 | 0 ; 0 |

Motifs de refus : N : aucun ; E : aucun ; A : aucun.

Constat : sur 5000 triangles admis, ensemble des colonnes non identifiables de la courbure non vide dans 0 triangle(s), ensemble de l'ordonnée à l'origine non vide dans 0 ; ensemble `degeneres` : 6 (colonne j = 6, un seul facteur, n_j = 1, dégénérée au sens de `.mw_colonne_degeneree()`) ; K ordonnée : 5 ; K courbure : 4. Les deux ensembles de #270 et #273 sont vides sur tous les triangles admis.
Spécification (par. 5, point 1) : K = 5 pour l'ordonnée, K = 4 pour la courbure ; K constant sur tous les triangles admis (observé : 5 et 4).

### T2 — volet 2 : colonnes retenues que la réplication rend non identifiables

Colonnes retenues = colonnes de n_j au moins 3 (O) ou 4 (C) hors des colonnes figées à l'observé. Une colonne retenue est comptée **dégénérée** (prédicat de #56, sur la réplication), **à moins de 2 (O) ou 3 (C) valeurs distinctes** (prédicat de #290 appelé sur la réplication ; les colonnes dégénérées en sont écartées, les deux comptes sont donc disjoints), ou **écartée** par la régression pondérée `lm()` (O) ou par la forme close de #253 (C, sans `lm()`) ; « écartée hors <k valeurs » = écartée sans être à moins de k valeurs distinctes (rang numérique). Réplications évaluées par le moteur : 149850 (sur 150 triangles admis).

| Loi | vérification | triangles | réplications | colonnes retenues | colonnes < k valeurs distinctes (réplications) | colonnes dégénérées (réplications) | colonnes écartées (réplications) | dont hors < k valeurs (réplications) | observé : < k / dég. / écart. / NA |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | ordonnée (n_j ≥ 3, < 2 valeurs distinctes) | 50 | 49950 | 249750 | 0 (0) | 0 (0) | 0 (0) | 0 (0) | 0 / 0 / 0 / 0 |
| N | courbure (n_j ≥ 4, < 3 valeurs distinctes) | 50 | 49950 | 199800 | 0 (0) | 0 (0) | 0 (0) | 0 (0) | 0 / 0 / 0 / 0 |
| E | ordonnée (n_j ≥ 3, < 2 valeurs distinctes) | 50 | 49950 | 249750 | 0 (0) | 0 (0) | 0 (0) | 0 (0) | 0 / 0 / 0 / 0 |
| E | courbure (n_j ≥ 4, < 3 valeurs distinctes) | 50 | 49950 | 199800 | 0 (0) | 0 (0) | 0 (0) | 0 (0) | 0 / 0 / 0 / 0 |
| A | ordonnée (n_j ≥ 3, < 2 valeurs distinctes) | 50 | 49950 | 249750 | 0 (0) | 0 (0) | 0 (0) | 0 (0) | 0 / 0 / 0 / 0 |
| A | courbure (n_j ≥ 4, < 3 valeurs distinctes) | 50 | 49950 | 199800 | 0 (0) | 0 (0) | 0 (0) | 0 (0) | 0 / 0 / 0 / 0 |

### T3 — volet 2 : statistiques NA par cause

Cause = premier cas rencontré en j croissant parmi les colonnes retenues (ordre de la boucle de la vérification) : colonne dégénérée, colonne écartée par `lm()` ou la forme close ; « autre » : statistique NA sans colonne fautive (par exemple aucune colonne retenue) ; « erreur » : erreur du test. Incohérences : la sonde prédit une cause alors que la statistique du moteur est finie (attendu 0).

| Loi | vérification | réplications | statistiques NA | colonne dégénérée | colonne écartée (lm() / forme close) | autre | erreur du test | incohérences |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | ordonnée (n_j ≥ 3, < 2 valeurs distinctes) | 49950 | 0 | 0 | 0 | 0 | 0 | 0 |
| N | courbure (n_j ≥ 4, < 3 valeurs distinctes) | 49950 | 0 | 0 | 0 | 0 | 0 | 0 |
| E | ordonnée (n_j ≥ 3, < 2 valeurs distinctes) | 49950 | 0 | 0 | 0 | 0 | 0 | 0 |
| E | courbure (n_j ≥ 4, < 3 valeurs distinctes) | 49950 | 0 | 0 | 0 | 0 | 0 | 0 |
| A | ordonnée (n_j ≥ 3, < 2 valeurs distinctes) | 49950 | 0 | 0 | 0 | 0 | 0 | 0 |
| A | courbure (n_j ≥ 4, < 3 valeurs distinctes) | 49950 | 0 | 0 | 0 | 0 | 0 | 0 |

### T4 — B effectif et retirage (clés Origine et Courbure)

| Loi | clé | triangles | B effectif minimal | B effectif moyen | triangles avec B effectif < 999 | triangles avec motif d'absence de p | plafond de retirage atteint (#257) | triangles avec triangle simulé retiré (#257) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | Origine | 50 | 999 | 999,000 | 0 | 0 | 0 | 0 |
| N | Courbure | 50 | 999 | 999,000 | 0 | 0 | 0 | 0 |
| E | Origine | 50 | 999 | 999,000 | 0 | 0 | 0 | 0 |
| E | Courbure | 50 | 999 | 999,000 | 0 | 0 | 0 | 0 |
| A | Origine | 50 | 999 | 999,000 | 0 | 0 | 0 | 0 |
| A | Courbure | 50 | 999 | 999,000 | 0 | 0 | 0 | 0 |

### T5 — lecture

**Recensement à l'observé (volet 1)** : 5000 triangles admis du plan de #206 (aucun échantillonnage) ; ensembles de #270 et #273 non vides dans 0 + 0 d'entre eux.

**Échantillon de réplications (volet 2)**, sous l'hypothèse d'indépendance des réplications (que le tirage par triangle ne vérifie pas : les réplications d'un triangle partagent son vivier de résidus) :

Ordonnée à l'origine : 149850 réplication(s) évaluée(s) ; réplications avec au moins une colonne à moins de 2 valeurs distinctes : 0 (taux observé 0,0e+00, borne supérieure unilatérale exacte à 95 % 2,0e-05 ; règle de trois 3/n = 2,0e-05) ; avec une colonne dégénérée : 0 ; avec une colonne écartée : 0 ; statistiques NA : 0 (borne supérieure 2,0e-05).

Courbure : 149850 réplication(s) évaluée(s) ; réplications avec au moins une colonne à moins de 3 valeurs distinctes : 0 (taux observé 0,0e+00, borne supérieure unilatérale exacte à 95 % 2,0e-05 ; règle de trois 3/n = 2,0e-05) ; avec une colonne dégénérée : 0 ; avec une colonne écartée : 0 ; statistiques NA : 0 (borne supérieure 2,0e-05).

Total des deux vérifications : 149850 réplications évaluées chacune ; 0 (réplication, vérification) avec colonne à trop peu de valeurs distinctes, 0 avec colonne dégénérée, 0 avec colonne écartée, 0 statistiques NA.

**Borne par triangle, sans hypothèse d'indépendance des réplications** : triangles touchés par au moins un événement : 0 sur 150, borne supérieure unilatérale exacte à 95 % 2,0e-02 ; par loi : N 0 sur 50 (borne 5,8e-02) ; E 0 sur 50 (borne 5,8e-02) ; A 0 sur 50 (borne 5,8e-02).

**Contrôle nul sur les deux volets.**

Statut : constat de simulation sous le plan de #206 (modèle de Mack ajusté à reserve2, géométrie 8 × 8) ; volet 1 : les 5000 triangles du plan de #206 ; volet 2 : 150 d'entre eux (b = 1 à 50 par loi). Zéro événement ne prouve pas l'absence d'événement, il en borne le taux. La borne unilatérale exacte à 95 % est q_{0,95} de la loi bêta(k + 1, n − k) ; la règle de trois (3/n) en est l'approximation pour k = 0. Le zéro du volet 2 est attendu par construction [H] : première colonne fixée à huit valeurs distinctes, colonnes suivantes simulées à partir d'erreurs continues (N, A) ou d'un vivier de 27 valeurs (E), sans coïncidence exacte attendue ; hypothèse non démontrée, et les bornes ci-dessus ne disent rien d'un plan où cette construction ne tiendrait pas. Cette mesure ne porte ni sur le niveau des p_mc ni sur les autres statistiques.

### T6 — comparaison descriptive aux colonnes `pR:` du brut de #206

Comparaison descriptive, **pas un critère** : #206 a été mesuré sur un autre commit du moteur (voir T0), et des modifications postérieures (par exemple #253, forme close de la courbure) ont pu changer des bits. Une ligne est « égale » si |p_new − p_ref| ≤ 1e-12 et si les B effectifs coïncident.

| Loi | clé | triangles comparés | égaux | différents | écart absolu maximal |
| --- | --- | --- | --- | --- | --- |
| N | Origine | 50 | 50 | 0 | 0,0e+00 |
| N | Courbure | 50 | 50 | 0 | 0,0e+00 |
| E | Origine | 50 | 50 | 0 | 0,0e+00 |
| E | Courbure | 50 | 50 | 0 | 0,0e+00 |
| A | Origine | 50 | 50 | 0 | 0,0e+00 |
| A | Courbure | 50 | 50 | 0 | 0,0e+00 |

Aucune différence : les p_mc d'Origine et de Courbure des triangles comparés sont identiques à celles de #206 (|écart| ≤ 1e-12, B effectifs égaux).

### Contrôles d'intégrité

- (b289) Origine et Courbure lues dans MW_CATALOGUE_MC (13 clés au total), queue haute, entrées sans degenere, non_definie ni extremes : OK
- (a) reserve2, run_engine(seed = 20260831), conforme à tests/reference/reserve2.rds (comparer_objets(), tolérance 1e-06) : conforme ; 4470 feuille(s), 0 non strictement identique(s), écart maximal 0.000e+00 : OK
- (g) gen_triangle_h0() (ε tirés par sample(pool)) = mw_simuler_triangle() sous la même graine, identical(), sur 100 / 100 graines (graines des triangles N, b = 1..100) ; sous pool dilaté 30 fois (#271) : 100 / 100, dont 48 triangle(s) à cumul simulé non fini ou ≤ 0 (au moins un exigé) ; mw_simuler_triangle, .mw_simuler_triangle_etat, .mw_tirer_triangle_valide, .mw_triangle_incomplet, .mw_pool_residus, mw_bootstrap de l'environnement identiques (formals, body) à celles de R/engine.R relu : oui : OK
- (graines) signalement sans effet : les littéraux 20840001 et 20960000 sont les bornes déclarées de la plage de #206 (PLAGE_206, tests/mesure_calendaire_t8.R, l. 304), non des graines tirées ; aucune source d'aléa ajoutée : plages triangles 20840001-20862000, bootstrap 20870001-20892000, oracle 20900001-20960000 (disjointes : oui) ; 31 littéraux de graine dans 67 fichiers (R/engine.R, tests/*.R, tests/unitaires/*.R), de 20260831 à 23700237 ; littéraux L dont [L ; L + 20000] touche une plage : 20840001, 20960000 ; littéraux au-dessus des plages (sans collision ; annotation du 10/10/2026 de la spécification, point 1) : 21000000, 21100000, 21200000, 23700237 ; littéraux en écriture scientifique non recherchés ; SEED_LOI_NULLE_SW 20260901, graine de reserve2 20260831 et réseau 20260831 + 1000 k ≤ 20760831 de tests/puissance_t8.R hors des plages : oui
- (i3) empreinte sans commentaires de R/engine.R 6ce112eecc6a7e9b6500ab639e757891 ; md5 de R/engine.R a6250d419ea27cb2e87bf4ed70dac453, de tests/calibration_mc_mw_t8.R d35b0f92d648732dbb570cb00c7fca07, de tests/outils_tests.R 7127605f20e8c261d41d3c372f4f2f1b : OK
- (sonde+289) contrôle positif de la sonde sur quatre triangles construits (colonne j = 1 constante ; à deux valeurs ; à dispersion relative 1e-9 ; colonne j = 2 dégénérée, facteurs tous égaux à 1,5) : champs attendus (n_peu, n_deg, n_ecart, n_ecart_hors, na, cause, incoh de O et C) : tous conformes : OK
- (sonde+289, moteur) mw_bootstrap() sur reserve2, B = 20, catalogue réduit et vivier de résidus nul injectés : toutes les colonnes retenues des 20 réplications sont dégénérées (cause 1) pour O et C, statistiques NA partout et B effectif d'Origine et de Courbure nul (accord avec la sonde), rien à l'observé, vivier et catalogue restaurés (identical()) : oui : OK
- (i2-289) injection du catalogue réduit {Sonde, Origine, Courbure} : sur reserve2 (graine 20260831) et sur le triangle N, b = 1 (graine 20870001), p_mc, err_mc, B_effectif, motif_mc, granularite_stat, p_min_mc et stats_obs des clés Origine et Courbure, sigma_boot, B, granularite, cumuls_retires et plafond_cumuls identiques (identical()) à ceux de mw_bootstrap() sans injection (reserve2 : oui ; triangle : oui) ; MW_CATALOGUE_MC restauré (identical()) : oui ; sonde appelée 1000 et 1000 fois (B + 1 = 1000 attendu), 0 et 0 erreur(s) de la sonde : OK
- (coh289) cohérence de la sonde avec le moteur sur reserve2 et le triangle N, b = 1 (2000 appels) : 0 incohérence(s) (cause prédite par la sonde avec statistique finie du moteur) ; rapprochement B effectif du moteur = réplications évaluées − statistiques NA de la sonde, pour Origine et Courbure : oui : OK
- (v1) volet 1 : 0 triangle(s) en erreur de calcul sur 5000 : OK
- (v2) volet 2 : 0 triangle(s) en erreur de calcul sur 150 ; MW_CATALOGUE_MC identique à l'original (identical()) après chaque triangle et à la fin ; 0 triangle(s) dont le registre de la sonde ne s'accorde pas avec le moteur (aucune erreur de la sonde, B + 1 appels sauf plafond de retirage, B effectif d'Origine et de Courbure = réplications évaluées − NA de la sonde) : OK
- (coh289-v2) cohérence de la sonde avec le moteur sur les 149850 réplications du volet 2 : 0 incohérence(s), 0 erreur(s) de la sonde ou du test : OK

Bilan : OK (1 signalement sans effet, voir (graines))

