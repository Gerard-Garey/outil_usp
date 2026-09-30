## Constats de niveau et de puissance à T = 8 (issue #118)

Paramètres : R=20000 ; graine=20260927 ; partie=normalite ; T=8 et 20

| Grandeur | Valeur |
| --- | --- |
| Plateforme | R version 4.3.3 (2024-02-29), Linux |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Commit | 9576bf67a6c973a5368bf9201b3f1763f3dabca6 |
| Script | tests/constats_puissance_t8.R --partie normalite (hors CI ; protocole dans l'en-tête) |

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

Durée de C4 : 28 s.

### Contrôles d'intégrité

- C4, invariance affine croissante de W, Z et de leurs p (premier échantillon de chaque loi, T = 8) : OK
- C4, transcription contre run_engine() sur J1 (W, p de Royston, p par loi nulle, Z et p de D'Agostino ; π̂ constant ; W et Z des résidus z égaux à ceux des log-ratios) : OK
- C4, aucune statistique ni p-value manquante (T = 8 et T = 20) : OK

