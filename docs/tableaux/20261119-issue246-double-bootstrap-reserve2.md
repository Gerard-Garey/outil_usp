# Double bootstrap Merz-Wüthrich : fréquence de la p de Monte-Carlo observée dans sa loi simulée (#246, loi E, 1000 triangles)

## Statut épistémique

La fréquence produite pour chaque clé vaut F̂\*(p_obs) = #{r admis : p\*_r ≤ p_obs} / R_admis. C'est un **constat de simulation**, obtenu sous trois conditions : le modèle de Mack ajusté au triangle donné (f̂, σ̂², première colonne fixée), la loi d'erreurs E, et T = 8. Elle estime la probabilité, dans ce modèle et sous cette loi, que la p de Monte-Carlo du moteur soit au plus égale à la p observée.

Ce qu'elle n'est pas :
- ce n'est pas une p exacte ;
- ce n'est pas une p retenue, et elle n'entre dans aucun verdict ;
- elle ne vaut pas au-delà de ce modèle et de cette loi.

Trois sources d'erreur sont à distinguer :
- (i) l'erreur Monte-Carlo de F̂\*, fonction de R, encadrée par l'intervalle de Clopper-Pearson ;
- (ii) l'erreur Monte-Carlo de p_obs, fonction de B ;
- (iii) l'erreur de substitution : θ̂ remplace θ, et E remplace la vraie loi. L'outil ne quantifie pas (iii).

Aucun résultat exact ni aucune référence relue ne dit que F̂\*(p_obs) est mieux calibrée que p_obs à T = 8. Les mesures de #206 et #297 montrent au contraire que le niveau dépend fortement de la loi des erreurs. Une fréquence élevée n'est pas une preuve d'adéquation : la puissance n'est pas étudiée.

## Provenance

| Grandeur | Valeur |
| --- | --- |
| Commit | 75e144e44351f155a8d964eaa74abff03e6270ff |
| Empreinte sans commentaires de R/engine.R (#231) | 17ce964a3e7d6b464851480162f75426 (md5 du fichier entier d94de7dcd2e188b70acc8571e0d4415d) |
| Code exécuté (md5) | R/engine.R d94de7dcd2e188b70acc8571e0d4415d ; tests/outils_tests.R chargé (dépôt) cdf8f7da242e2c6281fadcb4108aab63 ; script exécuté (dépôt) 0ed6a4839a45144a7c6740595de8bf5b |
| Triangle | tests/donnees/triangle_mw.csv (md5 3e9a584da42443f3816fb63deeffa95b) ; 8 × 8 ; segment 1, annexe II, date de référence 2026-12-31 |
| Mode | écriture dans docs/tableaux/ (--ecrire) |
| Arguments (hors --coeurs) | --ecrire |
| Graine du calcul observé | 20260831 |
| Plan de graines (P7, toutes sous engine_sous_graine()) | triangle r : 20850000 + r ; bootstrap interne r : 20880000 + r ; r = 1 .. R ; plages de #206 pour la loi E |
| Mesure | R = 1000 triangles simulés, dont 1000 admis et 0 refusés ; mw_bootstrap() à B = 999 (donnée du test calibré) puis mw_tests() à α = 0,10 ; B_MIN_DEGENERESCENCE = 50 |
| Refus (P6) | aucun |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| R, plateforme | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : libblas.so.3.12.0 ; LAPACK : liblapack.so.3.12.0 (version 3.12.0) |
| Locale (LC_CTYPE) | C.UTF-8 → C.UTF-8 |
| Débit du pré-vol | pré-vol du 2026-11-19, commit 75e144e : c_b = 10,78 s, run_engine() = 13,3 s, P_k = 1,000 / 1,881 / 2,848 / 3,818 ; durée prévue à 4 processus : 0,80 h (R = 1 000), 1,59 h (R = 2 000) |

## Contrôles d'intégrité

- (cat) les 13 clés de $bootstrap du point observé sont celles de MW_CATALOGUE_MC, dans le même ordre (noms et sens lus au catalogue) : OK
- (i1) point observé : p_obs lue dans run_engine() identique à celle de mw_bootstrap() + mw_tests() (mêmes ensembles figés, graine 20260831), identical() sur p_obs, $bootstrap, $tests et l'ajustement : OK
- (g) gen_triangle_h0() (ε tirés par sample(pool)) = mw_simuler_triangle() sous la même graine, identical(), sur 100 / 100 graines (triangles r = 1..100) ; sous pool dilaté 30 fois (#271) : 100 / 100, dont 47 triangle(s) à cumul simulé non fini ou ≤ 0 (au moins un exigé) ; mw_simuler_triangle, .mw_simuler_triangle_etat, .mw_tirer_triangle_valide, .mw_triangle_incomplet, .mw_pool_residus, mw_bootstrap de l'environnement identiques (formals, body) à celles de R/engine.R relu : oui : OK
- (m) aucune occurrence de « double_bootstrap_mw » dans R/, app.R et .github/ (18 fichiers lus) ; fichier(s) en défaut : aucun : OK
- (erreur) aucune ligne en erreur : 0 ligne(s) en erreur : OK
- (noms) les champs $p_mc, $err_mc, $B_effectif et $motif_mc de chaque ligne portent les clés du catalogue dans l'ordre : OK
- (i2) 7 ligne(s) (r = 1, 168, 334, 500, 667, 834, 1000) : run_engine(triangle = tri_r, seed = graine du bootstrap de r) donne $tests et $bootstrap identical() au chemin du script : OK
- (rep) les mêmes 7 ligne(s), recalculées dans une seconde passe (tâches distinctes de la boucle principale), redonnent la ligne calculée dans la boucle, hors durée (identical()) ; deux exécutions et --coeurs 1 contre --coeurs 4 : comparer les sorties hors section « Exécution » : OK
- (r2) r <= 1000 : statuts d'admission, vecteurs de p* et comptes #{p* ≤ p_obs} identiques au brut de #297 (20261026-issue297-calibration-famille-mw-brut.tsv, lignes rep, loi E, colonnes pR:<clé>) pour les 13 clés : 13 / 13 clés identiques : OK
- (r2) r <= 1000 : idem au brut de #206 (20261011-issue206-calibration-mw-brut.tsv) pour les 9 clés dont la statistique est inchangée depuis #206 (CorrDev, DW, Runs, Origine, HomogF, Courbure, Alpha, ExpVar, KruskalAcc) : 9 / 9 identiques : OK
- (r2) oracle du par. 5 du protocole : sans objet (valable à R = 2000 et graine 20260831 ; ici R = 1000, graine 20260831)

### Critère de reserve2 retrouvé (r2)

| Clé | #297 : comptes (ce calcul / brut) | #297 : vecteur de p* identique | #206 : comptes (ce calcul / brut) | #206 : vecteur de p* identique |
| --- | --- | --- | --- | --- |
| Calendrier | 4 / 4 | oui | sans objet (statistique ou sens changé depuis #206) | — |
| CorrDev | 159 / 159 | oui | 159 / 159 | oui |
| BP | 309 / 309 | oui | sans objet (statistique ou sens changé depuis #206) | — |
| MinP4 | 894 / 894 | oui | sans objet (statistique ou sens changé depuis #206) | — |
| DW | 35 / 35 | oui | 35 / 35 | oui |
| Runs | 270 / 270 | oui | 270 / 270 | oui |
| PenteIntra | 108 / 108 | oui | sans objet (statistique ou sens changé depuis #206) | — |
| Origine | 90 / 90 | oui | 90 / 90 | oui |
| HomogF | 61 / 61 | oui | 61 / 61 | oui |
| Courbure | 27 / 27 | oui | 27 / 27 | oui |
| Alpha | 3 / 3 | oui | 3 / 3 | oui |
| ExpVar | 434 / 434 | oui | 434 / 434 | oui |
| KruskalAcc | 323 / 323 | oui | 323 / 323 | oui |

Ce contrôle prouve que l'outil réalise le plan de #206 et #297 ; ce n'est pas une validation indépendante de la méthode.

## Pool et loi E

Modèle : Mack ajusté au triangle (mw_ajuster()), écart-type de population du pool **0,99879** ; colonnes dégénérées : 6 ; première colonne fixée.

| n | moyenne | sd_pop | asymétrie | excès de kurtosis | min | max |
| --- | --- | --- | --- | --- | --- | --- |
| 27 | -2,52e-17 | 0,99879 | -0,159 | -1,393 | -1,588 | 1,452 |

Pool = `.mw_pool_residus(aj, colonnes dégénérées)` ; loi E : tirage uniforme avec remise dans pool / sd_pop. `mw_bootstrap()` tire dans le pool non réduit : E n'en diffère que par le facteur d'échelle sd_pop.

## Fréquence de la p observée dans sa loi simulée, par clé

F̂\*(p_obs) = #{r admis : p\*_r ≤ p_obs} / R_admis, R_admis = 1000, comparaison exacte de doubles sans tolérance (p_obs et p\*_r sortent de `mw_bootstrap()`, donc de `engine_p_mc()`, sur une grille de pas k/(B_eff + 1), k = 1 pour une queue, 2 pour deux queues). L'écart entre k = #{p\* ≤ p_obs} et #{p\* < p_obs} est la masse de l'atome situé en p_obs ; aucun mid-p n'est retenu. La bande F̂\*(p_obs ∓ 2 err_mc) est descriptive de l'erreur Monte-Carlo de p_obs (source (ii)) ; ce n'est pas un intervalle de confiance. Pas d'ajustement de multiplicité sur les 13 fréquences. Une ligne « descriptive seulement » est un test inopérant ou un diagnostic : sa p_mc n'est pas retenue, sa fréquence n'est que descriptive.

| Clé | queue | p_obs | err_mc | p retenue observée | portée | k = #{p\* ≤ p_obs} | F̂\*(p_obs) | IC 95 % (Clopper-Pearson) | #{p\* < p_obs} | p\* absentes | F̂\* sur p définies | bande F̂\*(p_obs ∓ 2 err_mc), descriptive |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Calendrier | bas | 0,002 | 0,0014 | p_mc retenue (ECHEC) | constat | 4 / 1000 | 0,0040 | [0,0011 ; 0,0102] | 1 | 0 | 0,0040 | [0,0000 ; 0,0040] |
| CorrDev | deux | 0,170 | 0,0176 | p_mc retenue (OK) | constat | 159 / 1000 | 0,1590 | [0,1369 ; 0,1832] | 155 | 0 | 0,1590 | [0,1340 ; 0,1980] |
| BP | haut | 0,285 | 0,0143 | p_mc retenue (OK) | constat | 309 / 1000 | 0,3090 | [0,2805 ; 0,3387] | 307 | 0 | 0,3090 | [0,2680 ; 0,3380] |
| MinP4 | bas | 0,898 | 0,0096 | p_mc retenue (OK) | constat | 894 / 1000 | 0,8940 | [0,8732 ; 0,9124] | 893 | 0 | 0,8940 | [0,8660 ; 0,9160] |
| DW | deux | 0,032 | 0,0079 | p_mc retenue (ECHEC) | constat | 35 / 1000 | 0,0350 | [0,0245 ; 0,0483] | 35 | 0 | 0,0350 | [0,0220 ; 0,0500] |
| Runs | deux | 0,374 | 0,0247 | diagnostic : p_mc non retenue | descriptive seulement | 270 / 1000 | 0,2700 | [0,2427 ; 0,2987] | 269 | 0 | 0,2700 | [0,2350 ; 0,2890] |
| PenteIntra | deux | 0,090 | 0,0131 | p_mc retenue (ALERTE) | constat | 108 / 1000 | 0,1080 | [0,0894 ; 0,1289] | 105 | 0 | 0,1080 | [0,0810 ; 0,1330] |
| Origine | haut | 0,085 | 0,0088 | p_mc retenue (ALERTE) | constat | 90 / 1000 | 0,0900 | [0,0730 ; 0,1095] | 90 | 0 | 0,0900 | [0,0710 ; 0,1030] |
| HomogF | haut | 0,080 | 0,0086 | p_mc retenue (ALERTE) | constat | 61 / 1000 | 0,0610 | [0,0470 ; 0,0777] | 61 | 0 | 0,0610 | [0,0450 ; 0,0780] |
| Courbure | haut | 0,030 | 0,0054 | p_mc retenue (ECHEC) | constat | 27 / 1000 | 0,0270 | [0,0179 ; 0,0390] | 27 | 0 | 0,0270 | [0,0190 ; 0,0320] |
| Alpha | haut | 0,005 | 0,0022 | p_mc retenue (ECHEC) | constat | 3 / 1000 | 0,0030 | [0,0006 ; 0,0087] | 1 | 0 | 0,0030 | [0,0000 ; 0,0050] |
| ExpVar | haut | 0,428 | 0,0157 | p_mc retenue (OK) | constat | 434 / 1000 | 0,4340 | [0,4030 ; 0,4654] | 433 | 0 | 0,4340 | [0,4030 ; 0,4630] |
| KruskalAcc | haut | 0,300 | 0,0145 | p_mc retenue (OK) | constat | 323 / 1000 | 0,3230 | [0,2941 ; 0,3530] | 322 | 0 | 0,3230 | [0,2960 ; 0,3460] |

## Niveau du test bootstrap sous le modèle ajusté de ce triangle (produit du même calcul)

Fréquences de p\* < α/2 et de p\* < α sur les 1000 triangles admis (p\* absente : non-rejet), avec intervalle de Clopper-Pearson à 95 %. Règle ECHEC/ALERTE de `add()` pour un test « ne pas rejeter » ; constat de simulation sous ce modèle et cette loi, T = 8, source (iii) non quantifiée.

| Clé | α = 0,10 : p\* < 0,050 (ECHEC) | α = 0,10 : p\* < 0,100 (ALERTE ou pire) | α = 0,05 : p\* < 0,025 (ECHEC) | α = 0,05 : p\* < 0,050 (ALERTE ou pire) |
| --- | --- | --- | --- | --- |
| Calendrier | 0,0370 [0,0262 ; 0,0506] | 0,0960 [0,0785 ; 0,1160] | 0,0180 [0,0107 ; 0,0283] | 0,0370 [0,0262 ; 0,0506] |
| CorrDev | 0,0570 [0,0435 ; 0,0732] | 0,1010 [0,0830 ; 0,1214] | 0,0320 [0,0220 ; 0,0449] | 0,0570 [0,0435 ; 0,0732] |
| BP | 0,0510 [0,0382 ; 0,0665] | 0,0920 [0,0748 ; 0,1116] | 0,0180 [0,0107 ; 0,0283] | 0,0510 [0,0382 ; 0,0665] |
| MinP4 | 0,0410 [0,0296 ; 0,0552] | 0,0810 [0,0648 ; 0,0997] | 0,0180 [0,0107 ; 0,0283] | 0,0410 [0,0296 ; 0,0552] |
| DW | 0,0540 [0,0408 ; 0,0699] | 0,0950 [0,0775 ; 0,1149] | 0,0320 [0,0220 ; 0,0449] | 0,0540 [0,0408 ; 0,0699] |
| Runs | 0,0220 [0,0138 ; 0,0331] | 0,0570 [0,0435 ; 0,0732] | 0,0110 [0,0055 ; 0,0196] | 0,0220 [0,0138 ; 0,0331] |
| PenteIntra | 0,0610 [0,0470 ; 0,0777] | 0,1150 [0,0959 ; 0,1364] | 0,0280 [0,0187 ; 0,0402] | 0,0610 [0,0470 ; 0,0777] |
| Origine | 0,0530 [0,0399 ; 0,0688] | 0,0990 [0,0812 ; 0,1192] | 0,0280 [0,0187 ; 0,0402] | 0,0530 [0,0399 ; 0,0688] |
| HomogF | 0,0330 [0,0228 ; 0,0460] | 0,0830 [0,0666 ; 0,1019] | 0,0180 [0,0107 ; 0,0283] | 0,0330 [0,0228 ; 0,0460] |
| Courbure | 0,0410 [0,0296 ; 0,0552] | 0,0840 [0,0676 ; 0,1029] | 0,0220 [0,0138 ; 0,0331] | 0,0410 [0,0296 ; 0,0552] |
| Alpha | 0,0430 [0,0313 ; 0,0575] | 0,0970 [0,0794 ; 0,1170] | 0,0220 [0,0138 ; 0,0331] | 0,0430 [0,0313 ; 0,0575] |
| ExpVar | 0,0550 [0,0417 ; 0,0710] | 0,1050 [0,0867 ; 0,1257] | 0,0260 [0,0171 ; 0,0379] | 0,0550 [0,0417 ; 0,0710] |
| KruskalAcc | 0,0630 [0,0487 ; 0,0799] | 0,1190 [0,0996 ; 0,1407] | 0,0330 [0,0228 ; 0,0460] | 0,0630 [0,0487 ; 0,0799] |

## Exécution (varie d'une exécution à l'autre ; non comparée par (rep))

- Date (UTC) : début 2026-11-19T22:45:37, fin 2026-11-19T23:33:26
- Processus (mclapply) : 4
- Durée : calcul des 1000 lignes 2799,8 s ; total 2869,3 s
- run_engine() sur le triangle (point observé) : 13,2 s ; durée moyenne d'une ligne admise (un processus de travail) : 11,18 s ; débit agrégé : 1286 lignes par heure d'horloge

INTEGRITE OK
