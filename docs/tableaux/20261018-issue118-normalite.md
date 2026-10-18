## Constats de niveau et de puissance à T = 8 (issue #118)

Paramètres : R=20000 ; graine=20260927 ; partie=normalite ; T=5, 8, 10 et 20

| Grandeur | Valeur |
| --- | --- |
| Plateforme de calcul (R, système, machine, BLAS, LAPACK) | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.12.0 ; LAPACK : /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.12.0 (version 3.12.0) |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Commit | 74b799d139686022762a4939fbd2e2322ddf4cf6 |
| Script | tests/constats_puissance_t8.R --partie normalite (hors CI ; protocole dans l'en-tête) |
| Fichier remplacé (--remplacer) | docs/tableaux/20261018-issue118-normalite.md, md5 d'avant 12f314e86f8ded72e760a7c489bd735d |

### C4 -- Taux de rejet de Shapiro-Wilk et de l'asymétrie de D'Agostino, échantillons i.i.d., T = 8 (et D'Agostino à T = 20)

Statut : **constat de simulation, hors modèle réglementaire**, sous des alternatives choisies (échantillons i.i.d. de chaque loi ; ligne N(0,1) : niveau). Nombres aléatoires communs : une même matrice d'uniformes, transformée par la fonction quantile de chaque loi. W par .shapiro_sur() ; p par sw_p_loi_nulle(W, 8) (loi nulle simulée du moteur) et par la normalisation de Royston (shapiro.test()) ; Z et p de test_dagostino_skew() ; rejet si p < α.

Portée : W et Z sont invariants par transformation affine croissante, et, à π̂ constant, les résidus z du moteur sont une telle transformation des log-ratios. La mesure vaut donc **exactement** pour les p ci-dessus (p exacte de la ligne secondaire Shapiro-Wilk, p_asymptotique des lignes principales Shapiro-Wilk et D'Agostino) quand les log-ratios sont i.i.d. de la loi indiquée et π̂ constant ; pour les **p Monte-Carlo retenues** par le moteur sur les lignes principales (bootstrap paramétrique), elle n'est qu'**approchée**. À π̂ variable, elle ne s'applique pas.

Réplications : 20000 par loi et par T. Graines : T = 8 20260932 ; T = 20 20260933 ; loi nulle de W : 20000 tirages (SEED_LOI_NULLE_SW = 20260901).

**C4.a -- T = 8 : taux de rejet de Shapiro-Wilk et de D'Agostino**

| Loi | Test | Rejets / R (α = 0,10) | Taux | IC 95 % (C-P) | Rejets / R (α = 0,05) | Taux | IC 95 % (C-P) | p minimale |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N(0,1) (niveau) | Shapiro-Wilk, p par loi nulle simulée (sw_p_loi_nulle()) | 2069 / 20000 | 0,1035 | [0,0993 ; 0,1078] | 1016 / 20000 | 0,0508 | [0,0478 ; 0,0539] | 5,00e-05 |
| N(0,1) (niveau) | Shapiro-Wilk, p de Royston (shapiro.test()) | 2042 / 20000 | 0,1021 | [0,0979 ; 0,1064] | 1008 / 20000 | 0,0504 | [0,0474 ; 0,0535] | 1,53e-05 |
| N(0,1) (niveau) | D'Agostino (asymétrie), p N(0,1) approchée | 2117 / 20000 | 0,1058 | [0,1016 ; 0,1102] | 1110 / 20000 | 0,0555 | [0,0524 ; 0,0588] | 4,80e-04 |
| t de Student, 5 ddl | Shapiro-Wilk, p par loi nulle simulée (sw_p_loi_nulle()) | 3163 / 20000 | 0,1582 | [0,1531 ; 0,1633] | 1936 / 20000 | 0,0968 | [0,0927 ; 0,1010] | 5,00e-05 |
| t de Student, 5 ddl | Shapiro-Wilk, p de Royston (shapiro.test()) | 3133 / 20000 | 0,1567 | [0,1516 ; 0,1618] | 1920 / 20000 | 0,0960 | [0,0920 ; 0,1002] | 1,02e-05 |
| t de Student, 5 ddl | D'Agostino (asymétrie), p N(0,1) approchée | 3705 / 20000 | 0,1852 | [0,1799 ; 0,1907] | 2398 / 20000 | 0,1199 | [0,1154 ; 0,1245] | 4,28e-04 |
| t de Student, 3 ddl | Shapiro-Wilk, p par loi nulle simulée (sw_p_loi_nulle()) | 4368 / 20000 | 0,2184 | [0,2127 ; 0,2242] | 3112 / 20000 | 0,1556 | [0,1506 ; 0,1607] | 5,00e-05 |
| t de Student, 3 ddl | Shapiro-Wilk, p de Royston (shapiro.test()) | 4343 / 20000 | 0,2172 | [0,2115 ; 0,2229] | 3095 / 20000 | 0,1547 | [0,1498 ; 0,1598] | 1,95e-06 |
| t de Student, 3 ddl | D'Agostino (asymétrie), p N(0,1) approchée | 5141 / 20000 | 0,2571 | [0,2510 ; 0,2632] | 3665 / 20000 | 0,1832 | [0,1779 ; 0,1887] | 3,60e-04 |
| exponentielle exp(1) | Shapiro-Wilk, p par loi nulle simulée (sw_p_loi_nulle()) | 9159 / 20000 | 0,4580 | [0,4510 ; 0,4649] | 6766 / 20000 | 0,3383 | [0,3317 ; 0,3449] | 5,00e-05 |
| exponentielle exp(1) | Shapiro-Wilk, p de Royston (shapiro.test()) | 9093 / 20000 | 0,4546 | [0,4477 ; 0,4616] | 6744 / 20000 | 0,3372 | [0,3306 ; 0,3438] | 5,05e-06 |
| exponentielle exp(1) | D'Agostino (asymétrie), p N(0,1) approchée | 7905 / 20000 | 0,3952 | [0,3885 ; 0,4021] | 5722 / 20000 | 0,2861 | [0,2798 ; 0,2924] | 3,83e-04 |
| lognormale (0 ; 0,5) | Shapiro-Wilk, p par loi nulle simulée (sw_p_loi_nulle()) | 5574 / 20000 | 0,2787 | [0,2725 ; 0,2850] | 3738 / 20000 | 0,1869 | [0,1815 ; 0,1924] | 5,00e-05 |
| lognormale (0 ; 0,5) | Shapiro-Wilk, p de Royston (shapiro.test()) | 5545 / 20000 | 0,2772 | [0,2711 ; 0,2835] | 3725 / 20000 | 0,1862 | [0,1809 ; 0,1917] | 8,77e-06 |
| lognormale (0 ; 0,5) | D'Agostino (asymétrie), p N(0,1) approchée | 5583 / 20000 | 0,2792 | [0,2729 ; 0,2854] | 3831 / 20000 | 0,1915 | [0,1861 ; 0,1971] | 4,08e-04 |

**C4.b -- T = 20 : taux de rejet de D'Agostino (asymétrie), p N(0,1) approchée**

| Loi | Rejets / R (α = 0,10) | Taux | IC 95 % (C-P) | Rejets / R (α = 0,05) | Taux | IC 95 % (C-P) | p minimale |
| --- | --- | --- | --- | --- | --- | --- | --- |
| N(0,1) (niveau) | 1948 / 20000 | 0,0974 | [0,0933 ; 0,1016] | 986 / 20000 | 0,0493 | [0,0463 ; 0,0524] | 2,50e-05 |
| t de Student, 5 ddl | 5604 / 20000 | 0,2802 | [0,2740 ; 0,2865] | 4083 / 20000 | 0,2041 | [0,1986 ; 0,2098] | 1,02e-07 |
| t de Student, 3 ddl | 8486 / 20000 | 0,4243 | [0,4174 ; 0,4312] | 6839 / 20000 | 0,3419 | [0,3354 ; 0,3486] | 5,55e-08 |
| exponentielle exp(1) | 16164 / 20000 | 0,8082 | [0,8027 ; 0,8136] | 14050 / 20000 | 0,7025 | [0,6961 ; 0,7088] | 1,09e-07 |
| lognormale (0 ; 0,5) | 12270 / 20000 | 0,6135 | [0,6067 ; 0,6203] | 9971 / 20000 | 0,4985 | [0,4916 ; 0,5055] | 1,41e-07 |

Lecture : t5 et t3 sont symétriques ; contre elles, le taux de rejet de D'Agostino (asymétrie) n'est pas une puissance contre l'asymétrie mais une distorsion de niveau sous queues lourdes. Sur la ligne D'Agostino du moteur, la p retenue est Monte-Carlo (bootstrap paramétrique, mc_nom "DAgo") ; la p N(0,1) mesurée ici n'y est que p_asymptotique.

Niveaux (ligne N(0,1)), **informatifs** : aucun code de sortie n'en dépend.
- Shapiro-Wilk, p par loi nulle simulée : +0,34 points à α = 0,10 (IC contenant α) ; +0,08 points à α = 0,05 (IC contenant α). La loi nulle est figée (SEED_LOI_NULLE_SW, N = 20000 tirages) : l'écart de la vraie probabilité de rejet au niveau nominal est une erreur de quantile d'ordre √(α(1 − α)/N) (0,0021 à α = 0,10 ; 0,0015 à α = 0,05), qu'aucun R ne réduit ; la transcription de sw_p_loi_nulle() est contrôlée contre run_engine() (contrôles d'intégrité).
- Shapiro-Wilk, p de Royston (approchée), mesuré sans contrôle : +0,21 points à α = 0,10 (IC contenant α) ; +0,04 points à α = 0,05 (IC contenant α).
- D'Agostino, p N(0,1) approchée, mesuré sans contrôle : T = 8 : +0,58 points à α = 0,10 (libéral, IC excluant α) ; +0,55 points à α = 0,05 (libéral, IC excluant α) ; T = 20 : -0,26 points à α = 0,10 (IC contenant α) ; -0,07 points à α = 0,05 (IC contenant α).
Mise en garde : 8 IC à 95 % (4 lignes × 2 valeurs de α), sans correction de multiplicité ; sous des niveaux exacts, 0,4 IC excluant α sont attendus en moyenne par hasard (probabilité d'au moins un : 34 %). Le qualificatif « libéral » ou « conservateur » n'est un constat qu'à R = 20 000 (fichiers de docs/tableaux/), avec une demi-largeur d'IC d'environ ±0,42 point à α = 0,10 ; ±0,30 point à α = 0,05 ; au R de cette exécution (R = 20000) : ±0,42 point à α = 0,10 ; ±0,30 point à α = 0,05. À R faible, il ne vaut pas conclusion.

**C4.c -- Shapiro-Francia, p de Royston (test_shapiro_francia()) : niveau sous N(0,1) à T = 5, 8, 10 et 20, puissance à T = 8**

Statut : **constat de simulation** pour toute la sous-table C4.c (niveau, puissance, rapprochement), échantillons i.i.d., hors modèle réglementaire. W' et sa p par test_shapiro_francia() du moteur (aucune copie de formule) ; rejet si p < α. La p de Royston est une approximation à n fini dont aucun niveau exact n'est connu (constantes attribuées à Royston (1993), Statistics in Medicine 12, 181-184, d'après des sources secondaires, article non relu). Sur la ligne Shapiro-Francia du moteur, la p retenue est la p Monte-Carlo (bootstrap paramétrique, mc_nom "SF") ; la p de Royston mesurée ici n'y est que p_asymptotique.

Échantillons : aucun tirage supplémentaire (T = 8 et T = 20 : matrices d'uniformes de C4.a et C4.b ; T = 5 : colonnes 1 à 5 de la matrice T = 8 ; T = 10 : colonnes 1 à 10 de la matrice T = 20). Ces échantillons sont emboîtés : les taux de T = 5 et de T = 8, comme ceux de T = 10 et de T = 20, sont corrélés, et les IC de deux T d'une même matrice ne se comparent pas comme des IC indépendants ; T = 8 et T = 10 viennent de matrices distinctes. T = 5, 10 et 20 ne sont mesurés que pour le niveau, au regard du désaccord des sources sur la borne basse du domaine de validité de la transformation (5 contre 10) ; la puissance n'est mesurée qu'à T = 8.

Portée : W' est invariant par transformation affine croissante (contrôle), et, à π̂ constant, les résidus z du moteur sont une telle transformation des log-ratios. La mesure coïncide donc, échantillon par échantillon, avec la p_asymptotique de la ligne Shapiro-Francia du moteur quand π̂ est constant et les log-ratios i.i.d. de la loi indiquée. Elle n'est pas la fréquence conditionnelle à l'événement "π̂ constant", qui dépend des données. À π̂ variable, rien ne justifie de l'appliquer.

Niveau sous N(0,1), **informatif** : aucun code de sortie n'en dépend.

| T | Échantillons | α | Rejets / R | Taux | IC 95 % (C-P) | Écart au nominal (points) | Position de α | p minimale |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 5 | colonnes 1 à 5 de la matrice T = 8 | 0,10 | 2289 / 20000 | 0,1144 | [0,1101 ; 0,1189] | +1,445 | libéral, IC excluant α | 0,0017 |
| 5 | colonnes 1 à 5 de la matrice T = 8 | 0,05 | 1127 / 20000 | 0,0563 | [0,0532 ; 0,0596] | +0,635 | libéral, IC excluant α | 0,0017 |
| 5 | colonnes 1 à 5 de la matrice T = 8 | 0,01 | 199 / 20000 | 0,0100 | [0,0086 ; 0,0114] | -0,005 | IC contenant α | 0,0017 |
| 8 | matrice T = 8 (celle de C4.a) | 0,10 | 2220 / 20000 | 0,1110 | [0,1067 ; 0,1154] | +1,100 | libéral, IC excluant α | 2,25e-04 |
| 8 | matrice T = 8 (celle de C4.a) | 0,05 | 1142 / 20000 | 0,0571 | [0,0539 ; 0,0604] | +0,710 | libéral, IC excluant α | 2,25e-04 |
| 8 | matrice T = 8 (celle de C4.a) | 0,01 | 196 / 20000 | 0,0098 | [0,0085 ; 0,0113] | -0,020 | IC contenant α | 2,25e-04 |
| 10 | colonnes 1 à 10 de la matrice T = 20 | 0,10 | 2159 / 20000 | 0,1080 | [0,1037 ; 0,1123] | +0,795 | libéral, IC excluant α | 2,60e-04 |
| 10 | colonnes 1 à 10 de la matrice T = 20 | 0,05 | 1066 / 20000 | 0,0533 | [0,0502 ; 0,0565] | +0,330 | libéral, IC excluant α | 2,60e-04 |
| 10 | colonnes 1 à 10 de la matrice T = 20 | 0,01 | 190 / 20000 | 0,0095 | [0,0082 ; 0,0109] | -0,050 | IC contenant α | 2,60e-04 |
| 20 | matrice T = 20 (celle de C4.b) | 0,10 | 2065 / 20000 | 0,1032 | [0,0991 ; 0,1075] | +0,325 | IC contenant α | 6,80e-05 |
| 20 | matrice T = 20 (celle de C4.b) | 0,05 | 1053 / 20000 | 0,0527 | [0,0496 ; 0,0558] | +0,265 | IC contenant α | 6,80e-05 |
| 20 | matrice T = 20 (celle de C4.b) | 0,01 | 208 / 20000 | 0,0104 | [0,0090 ; 0,0119] | +0,040 | IC contenant α | 6,80e-05 |

Puissance à T = 8 (matrice de C4.a) :

| Loi | Rejets / R (α = 0,10) | Taux | IC 95 % (C-P) | Rejets / R (α = 0,05) | Taux | IC 95 % (C-P) | Rejets / R (α = 0,01) | Taux | IC 95 % (C-P) | p minimale |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| t de Student, 5 ddl | 3638 / 20000 | 0,1819 | [0,1766 ; 0,1873] | 2269 / 20000 | 0,1134 | [0,1091 ; 0,1179] | 695 / 20000 | 0,0348 | [0,0323 ; 0,0374] | 1,87e-04 |
| t de Student, 3 ddl | 5046 / 20000 | 0,2523 | [0,2463 ; 0,2584] | 3569 / 20000 | 0,1784 | [0,1732 ; 0,1838] | 1512 / 20000 | 0,0756 | [0,0720 ; 0,0794] | 9,06e-05 |
| exponentielle exp(1) | 9062 / 20000 | 0,4531 | [0,4462 ; 0,4600] | 6660 / 20000 | 0,3330 | [0,3265 ; 0,3396] | 2906 / 20000 | 0,1453 | [0,1404 ; 0,1503] | 1,35e-04 |
| lognormale (0 ; 0,5) | 5738 / 20000 | 0,2869 | [0,2806 ; 0,2932] | 3952 / 20000 | 0,1976 | [0,1921 ; 0,2032] | 1538 / 20000 | 0,0769 | [0,0732 ; 0,0807] | 1,72e-04 |

Mise en garde propre à C4.c : 12 IC de niveau à 95 % (4 valeurs de T × 3 valeurs de α), sans correction de multiplicité ; les lignes de puissance n'y entrent pas. Sous des niveaux exacts, 0,6 IC excluant α sont attendus en moyenne par hasard (probabilité d'au moins un : 46 %, calculée comme si les 12 IC étaient indépendants, ce que les échantillons et les α emboîtés ne réalisent pas). Le qualificatif « libéral » ou « conservateur » n'est un constat qu'à R = 20 000, avec une demi-largeur d'IC d'environ ±0,42 point à α = 0,10 ; ±0,30 point à α = 0,05 ; ±0,14 point à α = 0,01 ; au R de cette exécution (R = 20000) : ±0,42 point à α = 0,10 ; ±0,30 point à α = 0,05 ; ±0,14 point à α = 0,01.

Rapprochement, **non bloquant**, avec la mesure d'actuary du 17/10/2026 (hors dépôt, R = 200 000 échantillons i.i.d. N(0,1) de taille 8) ; son protocole n'est pas versionné (graine non publiée) :

| α | Mesure d'actuary, taux [IC 95 %] | C4.c, T = 8 (R = 20000), taux [IC 95 % C-P] | Valeur d'actuary dans l'IC de C4.c |
| --- | --- | --- | --- |
| 0,10 | 0,1096 [0,1083 ; 0,1110] | 0,1110 [0,1067 ; 0,1154] | oui |
| 0,05 | 0,0559 [0,0549 ; 0,0570] | 0,0571 [0,0539 ; 0,0604] | oui |
| 0,01 | 0,0099 [0,0095 ; 0,0103] | 0,0098 [0,0085 ; 0,0113] | oui |

Durée de C4.c : 11,9 s (W' et p de Royston ; aucun tirage).

Durée de C4 : 25 s.

### Contrôles d'intégrité

- C4, invariance affine croissante de W, Z et de leurs p (premier échantillon de chaque loi, T = 8) : OK
- C4, transcription contre run_engine() sur J1 (W, p de Royston, p par loi nulle, Z et p de D'Agostino ; π̂ constant ; W et Z des résidus z égaux à ceux des log-ratios) : OK
- C4, aucune statistique ni p-value manquante (T = 8 et T = 20) : OK
- C4.c, invariance affine croissante de W' et de sa p de Royston (premier échantillon de chaque loi, T = 5, 8, 10 et 20) : OK
- C4.c, transcription contre run_engine() sur J1 (statistique et p_asymptotique de la ligne Shapiro-Francia = test_shapiro_francia(z) à 1e-10 ; π̂ constant ; W' des résidus z égal à celui des log-ratios) : OK
- C4.c, aucune statistique W' ni p de Royston manquante (niveau à T = 5, 8, 10 et 20 ; puissance à T = 8) : OK
- C4.c sans effet sur C4 : lignes des tableaux C4.a (17) et C4.b (7), en-têtes compris, identiques au caractère près à celles de docs/tableaux/20260930-issue118-normalite.md : OK

