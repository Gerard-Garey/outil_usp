# Suivi de la documentation — Partie IV

Plage : Partie IV, « Validation, références et synthèse » : `sec:verif` (Vérification empirique de l'implémentation), `sec:biblio` (Compléments bibliographiques), `sec:synthese` (Synthèse et lecture des verdicts).

Entrées dans l'ordre du `.tex`, selon le gabarit et les règles de `README.md`.

## Entrées transversales

Aucune entrée.

## `sec:verif` — Vérification empirique de l'implémentation (partie IV, § Vérification empirique de l'implémentation)

Entrée qui couvre aussi les sous-sections sans `\label` « Recalcul indépendant des statistiques », « Taille effective et puissance » et « Vérification de l'implémentation Merz–Wüthrich ».

**Historique.**
- Recalcul indépendant : la p-value de Student restituée sur la ligne de la pente est unilatérale depuis #169 (la p-value de Fisher en est le double quand t_b > 0).
- Invariance par changement d'échelle : vérification demandée par #153 ; le second jeu du script (`tests/balayage_echelles.R`, objet `x153`, volumes de 100 à 700) est le jeu de #153.
- Taille effective et puissance : les niveaux autrefois cités pour des échantillons normaux de taille 200 (D'Agostino, Anscombe–Glynn, Jarque–Bera, Wald–Wolfowitz) et pour la borne de Bonferroni de Grubbs à T = 20, ainsi que deux puissances sans taille d'échantillon consignée (D'Agostino contre une loi exponentielle, Anscombe–Glynn contre une loi de Student), ont été retirés par #164, faute de script qui les reproduise.
- Vérification Merz–Wüthrich : contre-implémentation `msep_matrice` introduite par #50 ; refus de `run_engine()` sur le triangle totalement dégénéré depuis #192 ; `mw_calendrier_diagonales()` : #275 ; contrôle de la statistique d'hétéroscédasticité à effets fixes de colonne : #301 ; du résidu studentisé externe de la cellule aberrante : #300 ; de la pente relative en forme close : #307 (mesure de la session cloud, R 4.3.3) ; de S_j/D_j de l'identifiabilité intra-colonne : #308. La dérivation des coefficients a_ij par linéarisation a été établie dans l'avis d'actuary sur #7. Les écarts de −27, −44 et −22 % étaient dits « de l'ancienne formule du moteur » ; le `.tex` nomme la transcription fautive (termes diagonaux Ĉ(i,J)² Δ_i et facteur 2 omis).
- Encadré retiré, « Ce que les versions antérieures de ce document affirmaient à tort » : jusqu'à la correction de la transcription de D(5) (section `sec:mw`), la validation de la MSEP à un an était présentée comme reposant sur une « double implémentation indépendante » ; elle ne l'était pas : les deux implémentations reprenaient la même transcription fautive de D(5) (termes diagonaux Ĉ(i,J)² Δ_i et facteur 2 omis) et ne pouvaient rien détecter. La MSEP en était sous-estimée (√MSEP de 1 519 876 au lieu de 1 778 968 sur le triangle de Taylor & Ashe), dans le sens favorable à l'entreprise. La transcription de `sec:mw` et les deux voies de vérification (comparaison externe à `ChainLadder::CDR`, contre-implémentation `msep_matrice`) ont corrigé ce défaut. Correction : #7.

**Mesures retirées du guide.**
- Balayage des échelles (`tests/balayage_echelles.R`, R 4.3.3, BLAS et LAPACK de référence, x86_64, Ubuntu 24.04) : durée d'exécution 476 s, sans script versionné de sortie (les résultats chiffrés restent dans le `.tex`, constat sans sortie versionnée).

**Renvois.** ADR 0005 (formule de la MSEP, version consolidée) ; #7, #50, #153, #164, #169, #192, #275, #300, #301, #307, #308.

## `sec:calibration-mc` — Calibration des p-values de Monte-Carlo (partie IV, § Vérification empirique de l'implémentation)

**Historique.**
- Ouverture : les cinq lignes de lecture conjointe ont été ajoutées par #297 ; le TOST est un diagnostic depuis #298 (règle R14). Les mesures de la sous-section (#166, #221, #175 et #229) ont toutes été faites avant #240, quand le moteur calculait la p-value marginale V1 dans tous les régimes ; « p-value du moteur » y désigne V1.
- Mesure du niveau : le script `tests/calibration_mc_t8.R` a été créé par #166 (d'où le nom des fichiers) ; la mesure citée est celle de #221, sur le moteur postérieur à #169 et #215, script dans sa version du commit `26e7496`, sans modification propre à #221, dix tranches de 200 réplications exécutées et combinées à ce commit. Une première mesure, du 30/09/2026 (huit tranches de 250 réplications exécutées au commit `51ae1ab` et combinées au commit `808b448` ; `docs/tableaux/20260930-issue166-calibration-J1.md`, `-J2.md` et `.tsv` de même date), portait sur les mêmes jeux simulés et les mêmes graines : les p-values de Monte-Carlo des 33 statistiques autres que la constante y sont identiques au bit près, réplication par réplication ; seules changent les lignes que #169 et #215 ont modifiées (constante, pente, Fisher, TOST). Ces fichiers restent cités par le paragraphe « Constante pondérée ».
- Catalogue : 34 statistiques au moteur des mesures ; 31 depuis #303 et #302, qui ont retiré Ljung–Box au retard 1 sur u_t et sur z_t et Box–Pierce.
- Lecture en quatre états : la distorsion matérielle « appelle une décision du mainteneur » dans la rédaction d'origine (règle du protocole de #166).
- Règle R4 : en vigueur au moteur de la mesure, retirée par D1-Fb (voir `II.md`, entrée « Règle R4 »). Ligne de Fisher : diagnostic depuis #169.
- Test de Pitman : fréquence de rejet mesurée de nouveau au commit `7ff4725` par #297, la ligne étant un test dans tous les jeux depuis le retrait de R4.
- Mesure sur les lignes de lecture conjointe : #297, branche Fk, moteur du commit `7ff4725`, postérieur à #299, #302 et #303 ; mêmes graines que #166. Entre les deux états du moteur, lignes passées en diagnostic par décision (#299, #303, #304) et lignes retirées (#302).
- Mesure diagnostique du régime intérieur : #175, douze tranches combinées au commit `139031d` ; contrôles au bit près contre les valeurs brutes de #221.
- p-value conditionnelle au régime : #229 ; grille semi-analytique de #229 ; empreinte du moteur sans commentaires de #231 ; 48 tranches au commit `fee9968`. Le mécanisme du point (i) était présenté comme « lecture d'actuary, non démontrée ». La variante V3a est la variante conditionnelle de #175.
- Multiplicité (point d) : population hors les deux lignes du rapport de vraisemblance sur δ et la largeur de l'intervalle à δ fixé, lignes ajoutées par #45 ; tableau T2 bis produit par #274 ; parts inchangées entre les commits `fee9968` et `836b55d` (moteur de #274, antérieur à #299, #302 et #303, qui ont restitué en diagnostic, sans verdict, treize des lignes de la population, dont cinq par la règle R15 à π̂_t constant seulement) ; multiplicité sur toutes les lignes de type test mesurée de nouveau au commit `7ff4725` par #297. Avant #298 (TOST toujours de type test), les parts sur les 48 lignes valaient 0,4835 (V1) et 0,5050 (V3h) sur J2, et 1 (saturation) sur J1 ; sur J3, inchangées.
- Règle retenue : décision du 10/10/2026 ; implémentée par une issue distincte, #240, chaque changement de verdict étant soumis au mainteneur. « Jusqu'à #240, le moteur calculait V1. » L'argument de l'arrêt adaptatif sans biais était dit « argument élémentaire de la spécification ».
- Mise en œuvre : #240 ; spécification approuvée par le mainteneur le 11/10/2026. Le `.tex` citait « 67 assertions satisfaites » pour `tests/unitaires/test_p_mc_regime.R` (exécution de la session de rédaction) ; recompté au lot L7 (#458) : 75 assertions, 75 satisfaites (R 4.3.3, Ubuntu 24.04.5, BLAS et LAPACK de référence 3.12.0, 06/11/2026).
- Effet de #240 sur les résultats (tableau avant / après de #240 ; mesures de la session de rédaction, `run_engine()` avant et après l'issue) : sur les quatre cas de référence lognormaux à δ̂ = 1 et sur `reserve2`, toutes les valeurs préexistantes identiques au bit près (références avant et après comparées par `identical()`, champs ajoutés retirés) ; sur `premium_interieur`, σ_USP, intervalle bootstrap et réplications `sigma_boot`, `delta_boot`, `z_boot`, `sigma_boot_restreint` identiques, 30 des 34 p-values de Monte-Carlo changées (Goldfeld–Quandt 0,268 → 0,018 ; Breusch–Pagan studentisé 0,694 → 0,377 ; Grubbs 0,273 → 0,105 ; inchangées : Smirnov, suites sur z_t et sur ratios bruts, Cox–Stuart), un seul verdict changé, Goldfeld–Quandt, de OK à ECHEC, changement approuvé par le mainteneur. La ligne de Goldfeld–Quandt est depuis un diagnostic par décision (fiche `fiche:goldfeld-quandt`) : vérifié au lot L7 sur `premium_interieur` (p de Monte-Carlo 0,018, p retenue `NA`, verdict INFO ; σ_USP 0,0871308679 ; Grubbs 0,105, OK).
- Réserves : point (d) mesuré de nouveau au commit `836b55d` par #274 ; multiplicité au commit `7ff4725` par #297.
- Encadré « Réserve » : écart corrigé « depuis #240 » par la p-value conditionnelle au régime de #229.
- Paragraphe retiré, « Historique » : une mesure antérieure à #166, sur 400 jeux simulés à T = 10 et à T = 20 avec le moteur d'avant #63, #109 et #112 (réajustement des réplications à un seul démarrage), avait trouvé les onze statistiques alors bootstrapées compatibles avec le niveau de 0,10 à ± 0,029 près ; faute de script, de graine et de jeux versionnés, elle n'est pas reproductible et ne portait pas sur T = 8 ; son tableau a été retiré du document (décision du mainteneur du 30/09/2026) et remplacé par la mesure de #166 / #221.
- Constante pondérée : mesure de #221 ; statistique pondérée depuis #215 ; statistique non pondérée mesurée le 30/09/2026.
- Réajustement rapide : états successifs de `usp_ajuster_rapide()` : #43, un seul démarrage depuis (δ̂, γ̂), `factr = 1e7`, `maxit = 200` ; #63, gradient analytique et `factr = 1e4` ; #109, trois démarrages (décision du mainteneur du 28/09/2026). Contrôle S5 de `tests/comparer_ajusteurs_bootstrap.R` en échec à partir de #45 (argument `lr_delta` non passé à `usp_tests()`), jusqu'à une correction de #45 ; de #240 à #262 (correctif R13), contrôles des p-values de Monte-Carlo d'`usp_bootstrap()` en échec sur J2, rétablis par #262.

**Décisions.** Critère de lecture de #175 fixé avant l'exécution par décision du mainteneur (PR #228). Protocole de #229 : spécification d'actuary et décisions du mainteneur des 9 et 10/10/2026. Règle V3h : décision du mainteneur du 10/10/2026 (ADR 0014). Mise en œuvre (#240) : spécification approuvée par le mainteneur le 11/10/2026, ADR 0014 et 0003 annotés le même jour. Retrait de la mesure à 400 jeux : décision du mainteneur du 30/09/2026. Trois démarrages : décision du mainteneur du 28/09/2026 (#109).

**Règle retirée (réajustement à un seul démarrage).** `usp_ajuster_rapide()` à un seul démarrage depuis (δ̂, γ̂) (#43). Motif du retrait : il restait dans le bassin du bord de départ et manquait l'optimum de l'ajusteur complet dans une petite part des réplications (mesures ci-dessous), d'où les trois démarrages de #109. La part q mesurée (0,36 % sur J1, 0,68 % sur J2, 4 999 réplications) reste dans le `.tex`.

**Mesures retirées du guide.**
- Avant #298, parts des réplications avec au moins un ECHEC sur les 48 lignes, TOST compris : J2 0,4835 (V1) et 0,5050 (V3h), J1 1 (saturation) : `docs/tableaux/20261018-issue229-p-conditionnelle-regime.md`, tableau T2 bis, comparaison appariée avec les valeurs brutes `docs/tableaux/20261010-issue229-p-conditionnelle-regime-brut.tsv` (colonne « taux comparaison », lignes « toutes (48 lignes) »).
- Constante pondérée contre non pondérée (recalcul en R de base sur les fichiers de valeurs brutes `docs/tableaux/20261008-issue166-brut-J1.tsv`, `-J2.tsv` et `20260930-issue166-brut-J1.tsv`, `-J2.tsv` ; sans script versionné) : rejets à 0,10 et à 0,05, J1, 217 et 115 (pondérée) contre 212 et 118 (non pondérée), 29 et 13 décisions discordantes ; J2, 195 et 107 contre 200 et 119, 143 et 76 décisions discordantes.
- Réajustement à un seul démarrage (`tests/comparer_ajusteurs_bootstrap.R`, état antérieur à #109 ; sans sortie versionnée) : q = 4 sur 999 (J1) et 7 sur 999 (J2) en première passe (B = 999, graine 20260831), puis 18 et 34 sur 4 999 (seconde passe, graine 20260926) ; effet sur le jeu de contrôle, recalculé exactement sur les 999 tirages des références : une seule p-value de Monte-Carlo change, Shapiro–Wilk (0,621 contre 0,620, un pas de granularité), aucun verdict ne change, écart relatif maximal des quantiles de l'intervalle bootstrap de σ_USP 1,7·10⁻⁴ sur les quatre cas de référence lognormaux ; critère non atteint, réajustement rapide conservé ; régimes de δ̂* des deux ajusteurs concordants sur 996 des 999 réplications de J1 et 992 des 999 de J2 (première passe) : « le taux de δ̂* au bord n'est pas un artefact du réajustement rapide, seul le bord choisi l'est, sur les réplications où l'optimum n'est pas atteint ».
- Première mesure à trois démarrages, avant #274 (même script, mêmes réplications, B = 999, graine 20260831 ; sans sortie versionnée) : q = 0 sur J1 et J2 (0 sur 999, [0 ; 0,37 %]), régimes concordants sur les 999 réplications de J1 (463 au bord 0, 46 intérieures, 490 au bord 1), aucune p-value de Monte-Carlo différente.
- Effet de l'adoption des trois démarrages, avec le gradient analytique et le `factr` de #63, sur la méthode prime du jeu de contrôle (calcul du moteur avant et après ces issues ; sans sortie versionnée) : σ_USP de 0,1114524359 à 0,1114524114 (−2,2·10⁻⁷ en relatif, effet de #63) ; quantile à 95 % de l'intervalle bootstrap +1,6·10⁻⁴ en relatif, les autres de moins de 6·10⁻⁷ ; seule la p-value retenue de Shapiro–Wilk change (0,621 → 0,620) ; aucun verdict ne change.

**Implémentation.**
- Scripts hors CI : la partie régime de #229, dont le script recalcule lui-même les variantes, a été rejouée à l'identique au commit `836b55d` par #274. Le contrôle (i2) de `tests/p_conditionnelle_regime_t8.R` (et celui de `tests/conservatisme_interieur_t8.R`) est faux depuis #240 sur tout jeu à δ̂ intérieur : #267 (ouverte). Deux autres contrôles, S5 de `tests/comparer_ajusteurs_bootstrap.R` sur J2 et le critère 3 de `tests/puissance_t8.R`, ont été faux de #240 à #262 (correctif R13, PR #266), qui les a rétablis par `rejeu_p_mc_v3h()` ; sur J2 observé, les p-values passent, de V1 à V3h, de 0,496 à 0,390 (Durbin–Watson) et de 0,784 à 0,830 (Mann–Kendall). Le rétablissement n'a réexécuté aucun tableau versionné ; la question de leur remesure est portée par #256. Les tableaux de `tests/calibration_mc_t8.R` ne se reproduisent qu'au commit `26e7496`.
- Le commentaire d'`usp_ajuster_rapide()` (`R/engine.R`) cite « 0,37 % (J1) » pour la part q du réajustement à un seul démarrage ; le `.tex` cite 0,36 % (18 sur 4 999). Écart signalé au lot L7, hors du périmètre du `.tex`.

**Correspondance SHA.**
- `26e7496` = #221, script et combinaison de la mesure du niveau (`docs/tableaux/20261008-issue166-calibration-J1.md`, `-J2.md`, `-brut-J1.tsv`, `-brut-J2.tsv`).
- `51ae1ab` (exécution) et `808b448` (combinaison) = mesure du 30/09/2026 (`docs/tableaux/20260930-issue166-calibration-J1.md`, `-J2.md` et `.tsv`).
- `7ff4725` = #297, mesure sur les lignes de lecture conjointe (`docs/tableaux/20261026-issue297-calibration-famille-ln.md`).
- `139031d` = #175 (`docs/tableaux/20261009-issue175-conservatisme-interieur.md`, `-brut.tsv`).
- `fee9968` = #229 (`docs/tableaux/20261010-issue229-p-conditionnelle-regime.md`, `-puissance.md`).
- `836b55d` = #274, rejeu de la partie régime de #229 et tableau T2 bis (`docs/tableaux/20261018-issue229-p-conditionnelle-regime.md`), antérieur à #299, #302 et #303.
- `e7509f5` = #274, comparaison des ajusteurs (`docs/tableaux/20261018-issue274-comparer-ajusteurs.md`), antérieur à #299, #302 et #303.

**Renvois.** ADR 0003, ADR 0014 ; `II.md`, entrée « Règle R4 » (D1-Fb) ; PR #228, PR #266 ; #43, #45, #63, #109, #112, #166, #169, #175, #215, #221, #229, #231, #240, #256, #262, #267, #274, #297, #298, #299, #302, #303, #304.

## `sec:calib-asympt-mw` — Calibration des p-values non simulées (Merz–Wüthrich) (partie IV, § Vérification empirique de l'implémentation)

**Historique.**
- Shapiro–Wilk et Lilliefors (M5) sont des diagnostics sans p-value retenue depuis #245 ; la p-value de Lilliefors était retenue de #120 à #245, faute de p-value exacte et de p-value de Monte-Carlo.
- Mesure des p-values non simulées : #119, sur les triangles de la mesure de #206 (tableau T6 de `docs/tableaux/20261011-issue119-mw.md`).
- Lignes du tableau dont la statistique a été remplacée : tendance avec le cumulé (statistique antérieure à #307, pente absolue) ; Breusch–Pagan χ² (antérieure à #301 ; cause du sous-rejet mesurée par #309) ; effets calendaires (forme bilatérale, antérieure à #276) ; Grubbs, borne de Bonferroni (antérieure à #300) ; Shapiro–Wilk, ligne en diagnostic par #245.
- Lecture : les interprétations du tableau étaient « celles des versions antérieures, conservées lorsque la mesure en confirme le sens ». Les p-values de colonne des combinaisons de Fisher suivent la loi de permutation depuis #90. La pente absolue était la statistique de `mw:m1` jusqu'à #307.
- Lignes d'hétéroscédasticité (#301), de la cellule aberrante (#300) et calendaire en queue basse (#276) : mesures de #309 (tableau T6 de `docs/tableaux/20261021-issue309-puissance-mw.md`) et de #276 ; la p asymptotique bilatérale était restituée jusqu'à #276 ; aucune p non simulée n'est retenue à la place d'une p Monte-Carlo manquante (#181).
- Paragraphe retiré, « Historique » : les versions antérieures citaient des fréquences de rejet sur 600 triangles 10×10 « simulés exactement sous H0 » au seuil de 10 % (ordonnée à l'origine 0,092, homogénéité de f_j 0,125, courbure 0,112, exposant de variance 0,097, Kruskal–Wallis 0,135, effets calendaires 0,123, suites 0,153, Grubbs 0,000, Breusch–Pagan 0,005), dont celles de l'homogénéité de f_j et de l'exposant de variance antérieures à #90 ; aucun script ni protocole n'en a été retrouvé (sans script versionné) ; retirées et remplacées par la mesure de #119 (décision du mainteneur sur #119).
- Encadré « Conséquence pratique » : statistiques de Grubbs et de Breusch–Pagan du tableau antérieures à #300 et #301 ; test des suites diagnostic par décision depuis #312.

**Correspondance SHA.** `3a95e11` = #206 et #119, même combinaison (`docs/tableaux/20261011-issue206-calibration-mw.md` ; `docs/tableaux/20261011-issue119-mw.md` renvoie à sa provenance).

**Renvois.** #90, #119, #120, #181, #206, #245, #276, #300, #301, #307, #309, #312.

## `sec:calib-mc-mw` — Calibration des p-values de Monte-Carlo (Merz–Wüthrich) (partie IV, § Vérification empirique de l'implémentation)

**Historique.**
- Objet : la p-value des suites n'est plus retenue depuis #312 ; plan unique fixé par #206.
- Protocole : vivier d'avant #46 (non redressé) appliqué aux 1 000 premiers triangles sous N et sous E ; ρ des effets calendaires en queue basse tiré de la mesure de #276.
- Exécution : mesure antérieure à #257 et indépendante de lui (sous le moteur de la mesure, un triangle simulé à cumul non strictement positif faisait perdre la réplication sur les treize statistiques) ; `mw_bootstrap()` consomme, depuis #257, le même flux quand aucun cumul invalide n'est tiré. Mesure antérieure à #270 (ensemble figé des colonnes non identifiables de la courbure) et #273 (ordonnée à l'origine), non reprise sous le moteur postérieur ; effet contrôlé sans remesure des niveaux par #289 (mode `--controle-289`, moteur postérieur aux deux issues).
- Tableaux T1 : les lignes `PenteIntra`, `BP` et `Grubbs` portaient « avant #307 », « avant #301 », « avant #300 » ; elles portent « stat. remplacée », avec une légende sous chaque tableau. Bilan : statistiques remplacées par #301 (`BP`), #300 (`Grubbs` → `MinP4`) et #307 (pente relative) ; « Constat documenté seul ».
- Niveau des statistiques courantes : mesuré par #309 (mesure de puissance) ; `PenteIntra` mesurée comme candidat de #309.
- Effet du redressement du vivier : #46 ; le constat sur Breusch–Pagan sous E était rattaché à #243, sans rouvrir la variante retenue par #46.
- Verdicts sous H0 : mesure antérieure à #276, #301 et #300 (trois statistiques changées) et à #312 (verdict retiré à la ligne des suites) ; lignes M5 à verdict lors de la mesure, diagnostics depuis #245 ; procédure ESD : procédure de décision lors de la mesure, diagnostic sans verdict depuis #300 ; fréquences mesurées de nouveau au commit `7ff4725` par #297. Voisinage du seuil : phrase de #244 (`PHRASE_VERDICT_SENSIBLE_MC`).
- Mesure sur les lignes de lecture conjointe : #297, branche Fk, commit `7ff4725`, mêmes graines que #206 ; ligne `Calendrier` en queue basse depuis #276 ; statistiques de #301, #300 et #307 ; taux de ces trois clés tirés de la mesure de #309 ; clés inchangées identiques à la mesure du 11/10/2026 ; ligne des suites diagnostic depuis #312.
- Effets calendaires en queue basse : mesure propre de #276, sous des graines disjointes de celles de #206.
- Puissance des lignes M1 à M4 : #309 ; candidats retenus par #301 et #300 ; contrôles contre la mesure de #206 et la mesure de #276.
- Paragraphe retiré, « Historique » : les versions antérieures citaient des fréquences de rejet mesurées sur 160 triangles 10×10 simulés sous le modèle de Mack, pour sept statistiques, toutes jugées « compatibles avec les niveaux nominaux » ; mesure antérieure à #46, #60 et #90, ne portant pas sur T = 8, sans script ni protocole retrouvé ; retirée et remplacée par la mesure de #206 (décision du mainteneur sur #206).

**Décisions.**
- Le critère de recevabilité de la pente relative (fiche `mw:m1`, rubrique 7) était nommé « critère de remplacement K-307 » dans ce paragraphe jusqu'au lot L5 de ND (#456) ; renommé par décision du mainteneur du 06/11/2026 (voir `III-M.md`, `mw:m1`). Le reste de la sous-section a été condensé au lot L7 (#458) : rubriques de la présente entrée.
- Protocole de #206 : spécification `docs/specifications/206-calibration-mc-merz-wuthrich.md`, approuvée avant toute exécution, et ses annotations des 10 et 11/10/2026 ; annotation du 24/10/2026 (campagne de #297, critères K1 à K5 inchangés).
- Breusch–Pagan : constat documenté, moteur alors inchangé (décision du mainteneur du 11/10/2026) ; #243 traitée par la documentation seule (décision D1-4 du 13/10/2026) ; statistique remplacée par #301.
- Témoins oracle : lecture non suspendue et règle du témoin corrigée pour les statistiques à atomes (annotation du 11/10/2026 de la spécification, décision du mainteneur). Le script n'applique pas cette règle corrigée et pose donc mécaniquement le profil Φ0 sur la mesure de #297 ; profil levé par décision du mainteneur du 26/10/2026 (#378). Profil de la mesure de #297 par clé : Π1.
- Effets calendaires en queue basse (#276) : spécification `docs/specifications/fd-test-calendaire.md`, § 2.3, approuvée avant toute exécution.
- Puissance des lignes M1 à M4 (#309) : spécification `docs/specifications/fi-merz-wuthrich-puissance.md`, § 2, et ses compléments du 19/10/2026.

**Implémentation.** Avant toute relance de `tests/calibration_mc_mw_t8.R`, le générateur `gen_triangle_h0()` et le contrôle (s) du script, qui reproduisent la simulation antérieure à #257 (`NaN` au premier cumul invalide, sans retirage), sont à aligner sur le moteur : #271.

**Correspondance SHA.**
- `3a95e11` = #206, mesure du niveau (`docs/tableaux/20261011-issue206-calibration-mw.md`, `-brut.tsv`, journaux de même préfixe) et p-values non simulées de #119 (`docs/tableaux/20261011-issue119-mw.md`).
- `42323cf` = #289, contrôle des ensembles figés (`docs/tableaux/20261019-issue289-ensembles-figes-mw.md`).
- `6af2005` = #276, mesure propre des effets calendaires (`docs/tableaux/20261016-issue276-calendaire.md`).
- `754dd0a` = #309, puissance des lignes M1 à M4 (`docs/tableaux/20261021-issue309-puissance-mw.md`).
- `7ff4725` = #297, mesure sur les lignes de lecture conjointe (`docs/tableaux/20261026-issue297-calibration-famille-mw.md`).

**Renvois.** #46, #60, #90, #206, #243, #244, #245, #257, #270, #271, #273, #276, #289, #297, #300, #301, #307, #309, #312, #378.
