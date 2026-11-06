# Suivi de la documentation — Partie III, méthode Merz-Wüthrich et lecture conjointe

Plage : Partie III : `sec:mw` (Méthode Merz-Wüthrich, cadre et spécification), `sec:mwm1` à `sec:mwm6` (hypothèses M1 à M3, diagnostics M4 à M6), `sec:lecture-conjointe` (Lecture conjointe des tests, p-values de famille).

Entrées dans l'ordre du `.tex`, selon le gabarit et les règles de `README.md`. Lot L5 (#456) : `sec:mw` à `mw:m3runs`.

## Entrées transversales

### Correspondance SHA de la partie Merz–Wüthrich

Les fiches de `sec:mw` à `mw:m3runs` renvoient ici au lieu de citer un SHA ; les fichiers `docs/tableaux/` portent l'état du moteur en tête.

**Correspondance SHA.**
- `68360f4` = moteur antérieur à #253 (forme close de la pente absolue et de la courbure ; `lm()` écartait C ou le terme quadratique par son critère de rang numérique) ; moteur « avant » de la mesure du coût de la forme close. Aucun fichier `docs/tableaux/` (mesures sans script versionné, `mw:m1` et `mw:m1c`).
- `bbe3a2a` = moteur antérieur à #273 (colonne non identifiable de l'ordonnée à l'origine écartée sans trace). Aucun fichier (mesure sans script versionné, `mw:m1a`).
- `7ff4725` = remesure de #297 du niveau de la pente relative sous les mêmes graines, lois N et E : `docs/tableaux/20261026-issue297-calibration-famille-mw.md` (en-tête `7ff47251a769…`).
- `3a95e11` = mesure de #206 (calibration des p-values de Monte-Carlo Merz–Wüthrich, vivier redressé, colonne `pR:BP`) : `docs/tableaux/20261011-issue206-calibration-mw.md` et `-brut.tsv` (en-tête `3a95e11400f2…`).
- Commentaire 6238770854 de la PR #332 = transcription en rendu graphique de la p. D6.49 de Mack (1997), 17/10/2026 (voir `mw:m3caldiag`).

### Colonnes dégénérées et ensembles figés (règles communes de M1, `sec:mwm1`)

Les règles (1) à (5) de la tête de `sec:mwm1` reprennent, au présent et sans numéros, ce que portaient `mw:m1a` (rubriques 3 et 5) et `mw:m1c` (rubrique 3). La règle (6) reprend la rubrique 3 et la p-value minimale de `mw:m1b`, que citait `mw:m2b`.

**Historique.**
- Prédicat unique `.mw_colonne_degeneree()` : #56 (premier volet) ; second volet (facteurs rendus égaux par l'aplatissement) ajouté par #60. Jusqu'à #60, l'exclusion des résidus de Mack ne retenait que σ̂²_j = 0 exact.
- Ensemble figé des colonnes dégénérées transmis aux résidus de Mack de chaque réplication : #60 ; étendu au test calendaire et à la corrélation entre années adjacentes par décision du 06/10/2026. Élément `degeneres` de l'objet unique des ensembles figés depuis #278 ; avant #278, l'ensemble non identifiable de la courbure était calculé dans `mw_bootstrap()`, transmis par un argument `j_non_identifiables` de `.mw_contexte_mc()` et de `.mw_stats()`, et recalculé sur le triangle pour l'appel observé.
- Ensemble figé des colonnes non identifiables de la courbure : #270 (avant #270, le prédicat était évalué sur chaque triangle simulé ; 999 réplications sur 999 à K = 4 sur les trois triangles concernés, l'observé étant à K = 3) ; de l'ordonnée à l'origine : #273 (option (A)). Garde sd = 0 de la courbure retirée par #270, le prédicat la couvrant ; jusqu'à #273, `lm()` en échec écartait la colonne de l'ordonnée à l'origine.
- Combinaison de Fisher sans exclusion : #90 ; auparavant, une p-value nulle faisait écarter sa colonne sans trace, et K pouvait différer entre la statistique observée et ses réplications.
- Interception de l'avertissement « essentially perfect fit » par `.mw_summary_lm()` : #203 ; la courbure y passait de #203 à #253 (forme close depuis #253) ; la pente absolue était calculée sans `lm()` depuis #253, la ligne d'hétéroscédasticité depuis #301. Alternative non retenue : recalcul sans `summary.lm()` (par `lm.fit()` ou `qr()`), dont l'égalité des valeurs n'aurait été établie que par mesure.
- Clause « K = … colonne(s) testee(s) sur … eligible(s) » omise quand K vaut NA : #273.
- Corrélations de rang par colonne (règle (6)) : p_j par la loi de permutation depuis #90 (avant, approximation de Student, nulle à |ρ̂| = 1 pour n_j = 4, colonne alors écartée sans trace) ; loi conditionnelle aux rangs moyens avec ex æquo : #207 ; un seul appel de `.mw_spearman()` : #239 ; aucun appel à `cor.test()` sur le chemin énuméré avec ex æquo : #260 ; énumération de comparaison : #259 ; `.mw_fisher_rangs_p_min()` : #115.
- Règle R1 sur ces lignes : voir l'entrée transversale « Règle R1 sur le plancher Monte-Carlo ».
**Décisions.** Prédicat et exclusion des résidus : décisions du mainteneur du 05/10/2026 (#56, #60). Extension de l'ensemble figé au test calendaire et à la corrélation : 06/10/2026 (#60). Combinaison sans exclusion : décisions du 06/10/2026 (#90). Asymétrie avec M3 conservée sans alignement : statu quo du 09/10/2026. Ensemble figé de la courbure : D1-5, D1-6 et D1-8 du 13/10/2026 (#270) ; colonne figée écartée avant le contrôle de dégénérescence : décision du 14/10/2026. Ordonnée à l'origine : option (A) du 14/10/2026 (#273). Réserve sur l'effectif conditionnel au voisinage du seuil : réserve d'`actuary` à la validation de #60. Loi conditionnelle aux rangs moyens : Q-E2c-3 et Q-E2c-4 du 11/10/2026 (#207).
**Mesures retirées du guide.**
- Avertissements « essentially perfect fit » avec le moteur antérieur à #203 (`run_engine()`, B = 999, graine 20260831) : aucun sur le triangle de contrôle, 93 sur ce triangle multiplié par 10²⁰, 9 014 multiplié par 10⁴⁶, 1 287 sur le triangle de Taylor & Ashe à colonne j = 4 perturbée de ±9·10⁻¹³ (écart relatif 1,02·10⁻¹²) ; aucun avec le moteur actuel sur ces quatre triangles (sans script versionné).
- Pente relative et ligne d'hétéroscédasticité sans avertissement R (`run_engine()`, B = 199) sur le triangle de contrôle multiplié par 10^k, k = −52, −30, −10, 10, 30, 46 ; mesure faite avec le moteur de #307, dont la pente relative vaut t = 1,7330 aux six échelles ; même mesure, sans avertissement, avec le moteur antérieur à #301, dont la régression de Breusch–Pagan passait par `lm()` (sans script versionné).
- Critère d'ajustement parfait de `lm()` encore déclenché jusqu'à un écart relatif de l'ordre de 10⁻¹¹ sur le triangle mesuré, comme avant #56 (constat, sans script versionné).
- Énumération Spearman (règle (6)) : minimum des écarts p_j ≥ 5/6 atteint à n = 6 (6/7 à n = 7, aucun écart à n = 4 et 5) : fichier `docs/tableaux/20261013-issue259-spearman-ex-aequo.md`.
**Implémentation.**
- Restitution de l'ensemble figé : `.run_engine_mw()` construit l'objet (`.mw_ensembles_figes()`), le passe à `mw_bootstrap()`, qui le transmet au contexte de `.mw_contexte_mc()` et à `.mw_stats()`, où la fermeture le lit, et à `mw_tests()`, qui le passe à l'appel observé.
- Épreuve de non-régression de #203 : objets de `run_engine()` identiques au sens d'`identical()` avant et après sur les cinq cas de référence (tombe, R-d).
- Comptes exacts de la loi de Spearman : `.mw_spearman_comptes()` (programmation dynamique), à côté de `.mw_spearman_loi_rangs()`.
**Renvois.** ADR 0001 (diagnostic, test inopérant), ADR 0002 (p-value exacte au sens de l'outil, `sec:nature`).

### Phrases de B effectif et du retirage (`sec:boot-mw`)

Les gabarits des phrases de `mw_tests()` (cas A, cas A au plafond, cas B ; `PHRASE_MW_CUMULS_RETIRES`, `PHRASE_MW_PLAFOND_CUMULS`), l'ordre de jonction, l'argument de la méthode de rejet et les deux mesures quittent `mw:m1a` pour `sec:boot-mw` (partie II), lieu de leur définition (décision du mainteneur du 06/11/2026, T-E du tri de L5).

**Historique.**
- Phrases de B effectif : #204. Phrases du retirage : #257. De #257 à #279, le texte du cas A restait inchangé (décision D1-4) et imputait toutes les réplications manquantes à une statistique non finie, alors que le plafond en explique au moins une ; depuis #279, la phrase du cas A au plafond nomme les deux causes. Avant #279, sur le sous-triangle 8×8 de Taylor & Ashe dont la ligne 0 est multipliée par 10⁻¹⁷, la parenthèse était « (160 replication(s) ecartee(s), statistique non finie) ».
- Avant #257, un triangle simulé à cumul non strictement positif faisait perdre une réplication (cas A pour une autre cause que la statistique non finie).
- Fonction de jonction `.engine_joindre()` partagée avec `add()` : #264. Cas B et diagnostic quand la p-value de Monte-Carlo manque : #181.
**Décisions.** #204 : décision du mainteneur du 12/10/2026 ; ADR 0003 annoté le 12/10/2026, point 4 (exception bornée à la règle « aucun nombre issu du bootstrap »). #257 : décisions D1-3 et D1-4 du 13/10/2026. #279 : texte approuvé par le mainteneur le 14/10/2026.
**Implémentation.** Épreuve « aucune p-value, aucun verdict ne change » de #279 (tombe, R-d).
**Renvois.** ADR 0003 (annotations du 12/10/2026, point 4, et du 15/10/2026).

### Règle R1 sur le plancher Monte-Carlo (lignes de rang et de comptage de M1 à M3)

**Historique.** Jusqu'à #125, la règle R1 lisait p_min. Conséquences antérieures, portées par les fiches jusqu'à L5 :
- `mw:m1b` (et `mw:m2b`) : avec des ex æquo lourds (#207), si α/2 ≤ p_min < α, la ligne restait un test dont le commentaire disait « `ECHEC possible` » ; si p_min ≥ α, elle basculait en test inopérant, ce qui exigeait m_j ≥ α dans chaque colonne combinée. Dans l'exemple de la règle (6), p_min = 0,0667 < α = 0,10 < 0,142 : la ligne restait en test avec « ECHEC possible ».
- `mw:m3cal` : sur le sous-triangle 5×5, jusqu'à #125 la règle lisait p_min et la ligne était inopérante (décision du mainteneur du 06/10/2026) ; sous la forme bilatérale (avant #276, p_min = 0,125), le plancher Monte-Carlo valait 0,096 à B = 999 (test, ALERTE, ECHEC dit inatteignable, phrase de #244) et 0,10 à B = 99 (test inopérant).
- `mw:m3cor` : la lecture de p_min rendait la ligne inopérante sur tout triangle complet 5×5 (décision du 06/10/2026).
**Décisions.** D1-8 du 12/10/2026, qui remplace la lecture de p_min confirmée le même jour au matin ; verdict du 5×5 calendaire dépendant des réplications tirées, sans marge (D1-8). `.mw_kruskal_p_min()` et les p_min de rang : décision du mainteneur du 06/10/2026 (#115).

## `sec:mw` — Méthode Merz–Wüthrich, cadre et spécification (partie III, § Méthode Merz–Wüthrich)

**Historique.**
- Version du texte : comparaison en rendu graphique des formules de la section D (versions d'origine et consolidée) et vérification à l'image de la pagination au JO L 12 faites le 22/09/2026.
- Cas σ̂²_{J−3} = 0 : jusqu'à la correction, le moteur posait silencieusement σ̂²_{J−1} = σ̂²_{J−2} (repli non prescrit, supérieur à la borne 0 du texte). Pour σ̂²_{J−3} > 0, l'expression littérale est arithmétiquement identique à celle qui la précédait (mêmes opérations, dans le même ordre), y compris dans chaque réplication (épreuve de non-régression, tombe).
- Avertissement des colonnes dégénérées : le fait que des facteurs n'aient pas de résidu de Mack n'y est plus dit depuis #33 (avertissement général unique) ; prédicat unique depuis #60 (σ̂²_j exactement nul auparavant). Phrase des autres lignes qui écartent ces colonnes : #352, remplacée par le texte de #363 (la ligne M4 de la cellule aberrante y était déjà nommée seule).
- Refus du triangle totalement dégénéré : #192. Écart au facteur sous forme stable : #233.
- Tableau de réemploi : le test de Grubbs, réemployé sur les résidus de Mack, a été remplacé par la cellule aberrante (résidus studentisés externes) à #300 ; Breusch–Pagan studentisé sur toutes les cellules jusqu'à #301 ; pente absolue (régression sur C(i,j)) jusqu'à #307 ; test des suites en test jusqu'à #312.
- Synthèse de couverture : lignes de lecture conjointe ajoutées par #297 ; normalité (M5) comptée parmi les diagnostics depuis #245 ; identifiabilité intra-colonne : #308 ; suites en diagnostic par décision : #312 ; règle R1 sur le plancher Monte-Carlo : #125 ; effet calendaire en queue basse depuis #276, inopérant à B = 99 sous la forme bilatérale antérieure sur le sous-triangle 5×5.
**Décisions.** Exclusion des résidus des colonnes dégénérées : décision du mainteneur du 05/10/2026 (#60). Texte de l'avertissement (autres lignes qui écartent ces colonnes) : texte d'`actuary` retenu par décision du mainteneur du 30/10/2026 (#363) ; lignes de lecture conjointe hors de `.MW_LIGNES_COLONNES_ECARTEES` : même décision.
**Mesures retirées du guide.**
- Cas σ̂²_{J−3} = 0, triangle dégénéré construit pour le contrôle (B = 999) : le passage du repli à la règle littérale fait passer σ_(res,s,USP) de 0,0837988 à 0,0779835 (−6,94 %), sans changer aucun verdict ni aucune p-value de Monte-Carlo ; mesure sur un jeu de données, non un ordre de grandeur ; aucune valeur de référence modifiée (sans script versionné).
- Discontinuité du repli : sur un contrôle à 400 réplications bootstrap, 307 réplications empruntaient le repli dans un cas et 93 dans l'autre selon le dernier bit des cumulés (sans script versionné).
- Critère exact σ̂²_j = 0 contre prédicat : sur le triangle de Taylor & Ashe dont la colonne j = 4 est rendue constante puis perturbée de ±10⁻¹⁴ en relatif, 44 résidus et aucun avertissement avec le critère exact, 39 résidus et l'avertissement avec le prédicat, comme pour la même colonne exactement constante (sans script versionné).
**Implémentation.** Ordre des phrases de l'avertissement de `mw_valider_ajustement()` (`run_engine()`, B = 99, triangle de six années des tests unitaires dont la colonne j = 0 est dégénérée) : la phrase des autres lignes suit la liste des lignes fondées sur les résidus et précède celle du vivier du bootstrap.

## `mw:m1` — Absence de tendance des facteurs avec le cumulé (partie III, § Hypothèse M1)

**Historique.**
- Statistique antérieure, la pente absolue (#119, #253, en place jusqu'à #307) : F(i,j) = μ_j + b C(i,j) + ε, poids C(i,j)/σ̂²_j, même effet fixe de colonne. Clé `PenteIntra` conservée par #307 ; elle s'appelait `Intercept` jusqu'à #41.
- Forme close de la pente absolue (#253) : même centrage, appliqué à C et à F ; fonction retirée par #307. Avant #253, `lm()` écartait C par son critère de rang numérique (tolérance 10⁻⁷) et la ligne valait NA (triangle de contrôle, ligne 0 × 10¹⁵ ou 10⁻¹⁵, moteur `68360f4`) ; valeur figée par `tests/unitaires/test_forme_close_m1.R` jusqu'à #307, dont la partie pente du script `generer_valeurs_forme_close_m1.R` a été retirée.
- Affirmations retirées des versions antérieures : une fréquence de rejet de 0,068 (simulation sans plan ni script retrouvés) ; la régression pondérée par C(i,j) seul « ne rejette jamais sous l'alternative comme sous l'hypothèse nulle » (elle est conservatrice) ; « 100 % de rejets au seuil de 10 % » sous une alternative où le facteur dépend linéairement du volume (simulation sans script versionné et d'intensité inconnue).
- Sur le triangle de contrôle dont la ligne 0 est multipliée par 10⁻¹⁴, la pente absolue était en ECHEC au plancher de sa p-value de Monte-Carlo, à B = 199 comme à B = 999 (rejet non spécifique ; loi bootstrap de t concentrée près de ±1 ; cause non établie) ; voir aussi `II.md`, `sec:boot-mw`.
- Le nom « critère K-307 » désignait, jusqu'au lot L5 de ND, le critère de recevabilité de la pente relative.
**Décisions.** Pente relative en unités relatives : décision Q-D1-Fj-3 du mainteneur du 22/10/2026 (#307), qui fixe aussi le critère de recevabilité (formulé le 22/10/2026, après publication des tableaux). Clé `PenteIntra` conservée : Q-D1-Fj-4. Aucune référence de précision étendue pour la pente relative, fonction de la pente absolue retirée : Q-D1-Fj-7. Forme close de la pente absolue : D1-5 et D1-6 du 13/10/2026 (#253). Changement de verdict OK → ALERTE sur le triangle de contrôle (pente absolue 0,778 → pente relative 0,090) : visa du mainteneur du 23/10/2026. Approximation au premier ordre −a_j/(f_j C̄_j) : avis d'`actuary` du 23/10/2026. Critère (ii) non-détection, non équivalence : avis d'`actuary`, spécification Fj, § 4.2.
**Mesures retirées du guide.**
- Constats de construction de la pente absolue (sans script versionné) : avec l'effet fixe, la p de Student rejetait sous H0 dans 7,6 % à 8,3 % des cas au seuil 0,10 (2,6 % à 4,0 % à 0,05) ; pondérée par C(i,j) seul, 4,75 % à 6,0 % (2,25 % à 3,3 % à 0,05) ; les taux sans effet de colonne (96,8 % à 98,8 %) et ceux de la pondération par C seul (6,0 %, 4,75 %, 5,8 %) restent en `sec:calib-asympt-mw`.
- Pente absolue sur le triangle de contrôle : t = 0,2600, p de Student 0,7975, p MC 0,778, erreur 0,0308, OK (`docs/tableaux/20261022-issue307-reserve2.md`).
- Forme close de la pente absolue (moteur `68360f4`) : ligne 0 × 10⁻¹⁴, `lm()` rendait t = −2,566 au lieu de −1,121 (erreur relative 1,29), sans NA ni avertissement ; la forme close rendait −1,1210, à 9,7·10⁻¹⁷ en relatif de la référence Rmpfr (équations normales complètes, 4 096 bits, contrôle à 8 192 bits) ; sur le triangle de contrôle, t changeait de 1,2·10⁻¹³ en relatif, sans effet sur la p-value ni le verdict (sans script versionné).
- Robustesse numérique de la pente relative (moteur de #307) : t = −1,1379 et −0,8571 sur la ligne 0 × 10¹⁵ et × 10⁻¹⁵ ; écart de la p de Student à `summary(lm())` 5·10⁻¹⁴ en relatif (session cloud, R 4.3.3 ; oracle des tests unitaires, tolérance 10⁻¹⁰) (sans script versionné).
- Parts de Σ w x̃² par colonne pour la pente absolue : 0,1, 2,4, 9,1, 28,5, 53,4 et 6,6 % (j = 0 à 5) (sans script versionné).
- Pente relative sur le triangle de contrôle, ligne 0 × 10⁻¹⁴ (`run_engine()`, graine 20260831, moteur de #307) : OK, p-value de Monte-Carlo 0,786 à B = 999 et 0,820 à B = 199 (portées par `sec:boot-mw`).
- Taux de la pente relative (fichier `20261021-issue309-puissance-mw.md`, T1, T1 bis, T2 ; et `20261022-issue307-paires.md`) : intervalles de Clopper–Pearson des niveaux, taux au seuil 0,05 sous P1 (0,338 à δ = 0,10 ; 0,709 à δ = 0,20), intervalles sous P2 et P3, non-spécificité contre un choc sur t = 4 (0,340), sur t = 7 (0,516) et une cellule déplacée de six et quatre écarts-types (0,200 et 0,144) : le fichier les porte.
- Pente absolue, mêmes mesures (niveau 0,114 / 0,1205 / 0,130 à 0,10, 0,064 / 0,053 / 0,073 à 0,05 ; sous H0 de P1 à P3 0,122 / 0,116 / 0,129 ; puissance 0,330 / 0,226, 0,522 / 0,419, P2 0,862 / 0,932, P3 1,000 ; dérive de f_j 0,178 / 0,198 / 0,124) : fichiers `20261021-issue309-puissance-mw.md` et `20261011-issue206-calibration-mw.md`, et lignes « avant #307 » des tableaux de `sec:calib-mc-mw` (partie IV).
**Correspondance SHA.** `68360f4`, `7ff4725` : entrée transversale.
**Renvois.** Spécification Fj, § 4.2 ; ADR 0003 (clé du catalogue).

## `mw:m1a` — Nullité de l'ordonnée à l'origine, colonne par colonne (partie III, § Hypothèse M1)

**Historique.**
- Colonnes non identifiables (#273) : avant #273, une telle colonne était écartée sans trace, à l'observé comme dans une réplication, et K pouvait différer entre la statistique observée et ses réplications. Quand la colonne était écartée à l'observé seulement, la règle antérieure était conservatrice, en sens exact : à triangles simulés identiques et à B effectif égal, chaque statistique simulée était la statistique actuelle augmentée du terme −2 ln p_j ≥ 0 de la colonne écartée à l'observé. Sous l'approximation nominale (colonnes indépendantes), K = 4 à l'observé contre 5 dans les réplications donnait un rejet de probabilité P(χ²(8) ≥ q₀,₉₀(χ²(10))) = 0,043 au seuil 0,10 et 0,019 au seuil 0,05 (calcul exact sous cette approximation, `pchisq(qchisq(1 - a, 10), 8, lower.tail = FALSE)`, non mesure à T = 8). Aucune des 999 réplications du triangle T4 ne comptait de colonne écartée dans une réplication seulement.
- Graphique : avant #273, quand `lm()` rendait la statistique observée non définie, il représentait les autres colonnes (quatre sur le triangle à C(i,1) = 1 050 (1 + 10⁻⁸ i)).
- Calibration citée par les versions antérieures, « vérifiée par simulation sous H0 » sur 1 500 triangles 10×10 (10,7 % de rejets au seuil de 10 %, 4,7 % à 5 %) : antérieure au redressement du vivier (#46), sans script versionné ni protocole retrouvé, hors T = 8 ; retirée au profit de la mesure de #206.
- Phrase `PHRASE_VERDICT_SENSIBLE_MC` sur la ligne : #244.
- Règles communes (colonnes dégénérées, ensembles figés, combinaison, interception) et phrases de B effectif : voir les entrées transversales.
**Décisions.** Colonnes non identifiables : option (A) retenue par le mainteneur le 14/10/2026 (#273). Loi χ²(2K) exacte sous erreurs gaussiennes : raisonnement d'`actuary` (#424), aucune publication retrouvée.
**Mesures retirées du guide.**
- Moteur `bbe3a2a` (avant #273), `run_engine()`, `reserve2`, B = 999, graine 20260831, triangle de contrôle dont C(i,1) vaut 1 050 pour i = 0 à 5 : avant, K = 4 à l'observé et K = 5 dans les 999 réplications, p MC 0,289 ; après, K = 4 partout, p MC 0,162, OK inchangé. Sur C(i,1) = 1 050 (1 + 10⁻⁸ i) (six valeurs distinctes, colonne que `lm()` écarte) : avant, même p MC 0,289, colonne écartée sans trace ; après, ligne non applicable. Variante C(i,2) = 1 600 (1 + 10⁻⁸ i) pour i = 0 à 4 : phrase arrêtée à « hors de la combinaison de Fisher. » (sans script versionné).
- Triangle de contrôle lui-même : aucune colonne non identifiable, p-value inchangée (0,085) (épreuve, tombe).
- p-value de Monte-Carlo sur le triangle de contrôle avant le redressement du vivier (#46) : 0,095 (`docs/tableaux/20261006-issue46-reserve2.md`) ; ALERTE sur 16 des vingt graines 20260831 à 20260850 avant #46 (sans script versionné).
- B effectif de `Origine`, `Courbure` et `HomogF` sur le triangle de Taylor & Ashe à colonne j = 4 perturbée de ±9·10⁻¹³ (écart observé 1,02·10⁻¹²) : 749 avec le moteur antérieur à #60, 537 avec le moteur de #60 (sans script versionné) ; 649 reste dans la fiche.
- Puissance au seuil 0,05 (0,166 à δ = 0,10 ; 0,504 à δ = 0,20) et intervalles à 0,05 : fichier `20261021-issue309-puissance-mw.md`, T2.
**Correspondance SHA.** `bbe3a2a` : entrée transversale.
**Renvois.** ADR 0003, point 4 (phrases de B effectif).

## `mw:m1b` — Homogénéité de f_j entre années de survenance (partie III, § Hypothèse M1)

**Historique.** Avant #90, p_j était l'approximation de Student, qui vaut 0 à |ρ̂| = 1 pour n_j = 4, et la colonne était écartée de la combinaison sans trace. Règle (6) de la tête de `sec:mwm1` : voir l'entrée transversale.
**Décisions.** p_j par la loi de permutation : décisions du mainteneur du 06/10/2026 (#90). Loi conditionnelle aux rangs moyens : Q-E2c-3 et Q-E2c-4 du 11/10/2026 (#207). Explication du taux nul sous P3 (permutation fixe de la première colonne) : avis d'`actuary` sur les valeurs brutes de #309, non démontrée.
**Mesures retirées du guide.**
- Taylor & Ashe à colonne j = 4 dégénérée : avant #90, la colonne j = 5 (n_j = 4, ρ̂ = −1) était écartée et K valait 4 (sans script versionné).
- Triangle `tri_deg` des tests unitaires (B = 99) : `B_effectif` passait de 91 à 99 (de 93 à 99 pour l'exposant de variance) à #90 (sans script versionné).
- p-value χ²(2K) sur le triangle de contrôle avec les p-values de Student, avant #90 : 0,085 (sans script versionné).
- Effet de #207 (B = 999, graine 20260831, moteur antérieur puis postérieur) : triangle de contrôle arrondi à la dizaine, X de 13,424 à 13,165, p MC de 0,041 à 0,047, ECHEC inchangé ; arrondi à la centaine, p MC de 0,354 à 0,378, et de 0,921 à 0,860 pour l'exposant de variance, verdicts inchangés (sans script versionné). Triangle de contrôle : objets identiques avant et après (épreuve, tombe).
- ALERTE sur les vingt graines « avant comme après le redressement du vivier » (#46) : la mention « avant » tombe.
- Puissance au seuil 0,05 (0,124, 0,098, 0,114 sous P1 à P3) et intervalles sous P2, P3 : fichier `20261021-issue309-puissance-mw.md`, T2.

## `mw:m1c` — Absence de courbure de la régression (partie III, § Hypothèse M1)

**Historique.**
- De #203 à #253, `summary()` était appelé par `.mw_summary_lm()`, qui interceptait le seul avertissement d'ajustement parfait, sans changer aucune valeur.
- Forme close (#253) : avant #253, `lm()` écartait le terme quadratique par son critère de rang numérique et la colonne sortait de la combinaison sans trace (statistique NA sur le triangle de contrôle dont la ligne 0 est multipliée par 10¹³ ou 10¹⁵, moteur `68360f4`). Deux comportements antérieurs à #253 relevés : l'exclusion n'était pas restituée (corrigé par #269) ; pour j ≥ 1, elle pouvait écarter une colonne à l'observé sans l'écarter dans les réplications, la p-value étant alors majorée (sens conservateur), corrigé par #270. Garde sd = 0 retirée par #270. Domaine [10⁻⁵⁰ ; 10⁵⁰] à exposant séparé : #185 (`.mw_me()`, `.mw_somme_me()`).
- Jusqu'à #307, `test_forme_close_m1.R` figeait aussi le t de la pente intra-colonne, alors absolue, sur les sept triangles (35 valeurs d'alors).
- Restitution des colonnes non identifiables : #269 ; l'ordonnée à l'origine a son propre ensemble figé depuis #273. Pourquoi figer (règle (2) de `sec:mwm1`) : calcul sous l'approximation nominale de la règle antérieure (K = 3 à l'observé contre 4 dans les réplications, triangles T1, T2 et T4) : P(χ²(6) ≥ q₀,₉₀(χ²(8))) = 0,038 au seuil 0,10 et 0,017 au seuil 0,05, soit un conservatisme d'un facteur 2,7 à 3 (calcul exact sous cette approximation, `pchisq(qchisq(1 - a, 8), 6, lower.tail = FALSE)`).
**Décisions.** Forme close : D1-5 à D1-7 du 13/10/2026 (#253) ; exclusion par non-identifiabilité selon la règle de #90 (D1-7). Ensemble figé : D1-5, D1-6, D1-8 du 13/10/2026 (#270) ; changement de verdict de T1 approuvé (D1-8). Convention « toutes les colonnes éligibles non identifiables » (K = 0) : décision du 14/10/2026. Coût de la forme close : constat C3 de l'audit de #253, accepté le 13/10/2026. Colonne à un degré de liberté conservée : Q-E2c-1 du 11/10/2026 (#234). Loi χ²(2K) exacte sous erreurs gaussiennes : raisonnement d'`actuary` (#424).
**Mesures retirées du guide.**
- Constat sur triangles construits (B = 999, graine 20260831, `mw_bootstrap()` et `mw_tests()`, moteur de #269 avant, moteur postérieur à #270 après ; K des réplications par rejeu de la boucle réduite à la courbure, p MC identique à celle du moteur) (sans script versionné) :

  | Triangle | non identifiable | K observé | K réplications avant / après | p MC avant / après | verdict avant / après |
  |---|---|---|---|---|---|
  | contrôle | aucune | 4 | 4 / 4 | 0,030 / 0,030 | ECHEC / ECHEC |
  | T1 : C(i,1) = 1 000 (i ≤ 2), 1 100 (3 ≤ i ≤ 5) | j = 1 | 3 | 4 / 3 | 0,081 / 0,031 | ALERTE / ECHEC |
  | T2 : C(i,2) = 1 600 (i ≤ 2), 1 800 (i = 3, 4) | j = 2 | 3 | 4 / 3 | 0,634 / 0,394 | OK / OK |
  | T3 : C(i,0) = 320, 350 en alternance | j = 0 | 3 | 3 / 3 | 0,017 / 0,017 | ECHEC / ECHEC |
  | T4 : C(i,1) = 1 050 (i ≤ 5) | j = 1 | 3 | 4 / 3 | 0,043 / 0,016 | ECHEC / ECHEC |

  Dans chaque cas, les 999 réplications ont le K indiqué, B effectif 999. Sur T1, X = 13,9956 à K = 3 ; queue χ²(6) 0,0297, queue χ²(8) 0,0819.
- Triangles des cas limites de la restitution (`run_engine()`, `reserve2`, B = 999, graine 20260831) : C(i,1) = 1 000 pour i = 0, 1, 2 et 1 100 pour i = 3, 4, 5 (phrase identique à B = 199 sous la graine 1) ; colonne j = 2 rendue dégénérée par C(i,3) = 1,3 C(i,2) pour i = 0 à 4 (« K = 2 colonne(s) testee(s) sur 4 eligible(s) ») ; toutes les colonnes non identifiables : C(i,j), j = 0 à 3, alternant entre minimum et maximum de leur colonne (B = 199) (sans script versionné).
- Ensemble figé, triangle de contrôle dont la colonne j = 1 est rendue dégénérée par C(i,2) = 1,3 C(i,1) pour i = 0 à 5 (`mw_test_courbure()`, colonnes dégénérées vides, `j_non_identifiables` = 1) (sans script versionné) ; la fiche garde le résultat.
- Écart maximal du moteur à la référence Rmpfr sur les 35 valeurs de la pente absolue : 1,1·10⁻¹³ en relatif (maximum non recalculé depuis le retrait de la partie pente du script ; Rmpfr absent de la session de #307) (sans script versionné). Sur le triangle de contrôle, X changeait de 2,2·10⁻¹⁴ en relatif et sa p χ²(2K) de 1,4·10⁻¹³ à #253, sans effet (épreuve, tombe).
- Coût de la forme close (session de rédaction, moteurs de `68360f4` et de la tête de branche, R 4.3.3, machine partagée, ordre de grandeur) : quelques secondes au plus à I = 10 et 12 (bruit de la mesure) ; à I = 30 et 40 : 9 et 46 min à la rédaction, 13 et 43 min à la validation (durée d'un appel multipliée par 1 000 ; script non versionné).
**Implémentation.** Élément `non_identifiables` : table à deux colonnes (`j`, `n_facteurs`, nombre n_j de facteurs individuels), une ligne par colonne en j croissant ; aux retours `NA`, `exclues` et le nombre de colonnes éligibles restent ceux des colonnes parcourues avant l'arrêt. Phrase au pluriel : « `Colonnes a moins de trois` … » et « `colonnes hors de la combinaison` », colonnes énumérées par des virgules. Formes à exposant séparé `.mw_me()`, `.mw_somme_me()` (#185).
**Correspondance SHA.** `68360f4` : entrée transversale.

## `mw:m1d` — Stabilité du facteur selon la pondération, famille α (partie III, § Hypothèse M1)

**Décisions.** Conservée comme test : décision du mainteneur du 22/10/2026 (#307, Q-D1-Fj-5, option (b′)), ni passage en diagnostic ni retrait. Classement des alternatives visées : avis d'`actuary` sur les tableaux de #309. Excès sous P2 à exposant 0 imputé à la loi bootstrap : lecture d'`actuary`, spécification Fj, § 4.3. Mesure sur le triangle de six années à colonne j = 0 dégénérée : mesure d'`actuary`, fin de branche Fq. Avertissement des colonnes dégénérées sans la ligne : #363.
**Mesures retirées du guide.** Puissance au seuil 0,05 à δ = 0,20 (0,110 [0,091 ; 0,131]) et intervalles des exposants 2 sous P1 et P2 ; profils comparés à la pente relative contre la dérive calendaire (0,718 contre 0,510) et la dérive de f_j (0,348 contre 0,270) ; corrélation des p-values sous P2 (0,157) et P3 (0,086) : fichiers `20261021-issue309-puissance-mw.md` (T2) et `20261022-issue307-paires.md` (T1, T2). Taux du vivier non redressé (0,207 sous N, 0,180 sous E) : `20261011-issue206-calibration-mw.md` (cité dans la fiche et en `sec:boot-mw`).
**Renvois.** Spécification Fj, § 4.3.

## `mw:m1id` — Identifiabilité intra-colonne (partie III, § Hypothèse M1)

**Historique.** Ligne ajoutée par #308. Écriture de R_j et de e_a (#364) : l'écriture fixe seule, en vigueur jusqu'à #364, rendait illisible un rapport R_j géant et écrivait nul un e_a très petit (ligne i = 0 du triangle de contrôle multipliée par 10⁻¹⁴, colonne j = 0 : « `R = 122857142857143.000, e_a = 0.0000` »). Variante à erreur type observée (20, 16, 26, 36 et 67 %) avancée par #308, démentie par #309 (T7 (d)).
**Décisions.** Forme de la ligne et place après la famille α : Q-D1-Fj-1 du 22/10/2026 ; grandeurs restituées et effet minimal détectable non restitué : Q-D1-Fj-2. Écriture de R_j et de e_a : Q-44-4 du 30/10/2026 (#364). Propriétés de e_a établies par l'algèbre : avis d'`actuary` (#308).
**Mesures retirées du guide.** CV₁ moyen des triangles simulés sous P1 : 0,067 (tableau T7 (a) de `20261021-issue309-puissance-mw.md`) ; pente relative sous P2 et P1 (0,967 contre 0,796, T7 (c)) : même fichier.
**Implémentation.**
- Plage d'écriture jugée sur l'écriture fixe relue, non sur la valeur : à quatre décimales, 0,00099995 s'écrit `0.0010`, mais le double le plus proche de 0,00095, que l'écriture fixe arrondit à `0.0009`, s'écrit `9.500e-04` ; valeurs non finies écrites `Inf`, `-Inf`, `NaN` ou `NA`.
- Tests unitaires, texte à la lettre : ligne i = 0 × 10⁻¹⁴, colonne j = 0, « `R = 1.229e+14, e_a = 1.577e-09` » ; ligne i = 0 × 10¹⁵, « `R = 9.633e+14, e_a = 4.685e-17` ». Commentaire du triangle de contrôle inchangé par #364 (épreuve, tombe).

## `mw:m2bp` — Hétéroscédasticité résiduelle contre le cumulé (partie III, § Hypothèse M2)

**Historique.**
- Statistique antérieure à #301 : n R² de r² sur C(i,j), 27 cellules, sans effet de colonne (Breusch–Pagan studentisé). Sur le triangle de contrôle : 0,6502, p χ²(1) 0,4200, p MC 0,103, erreur 0,0096, OK (`docs/tableaux/20261021-issue301-reserve2.md`) ; aucun verdict ni σ_USP n'a changé à #301. Les versions antérieures attribuaient le sous-rejet de sa p χ²(1) à la seule dispersion réduite des résidus standardisés (R² auxiliaire trop faible) ; la statistique nR² ne dépend pas de l'échelle des résidus et la cause, longtemps non établie, a été mesurée par #309 (T5).
- Ligne à la frontière du seuil (statistique antérieure) : depuis le redressement du vivier (#46), p MC 0,103 (B = 999, graine 20260831), erreur 0,0096, OK ; 0,086 (ALERTE) avant #46. La marge au seuil, 0,003, était inférieure à l'erreur de Monte-Carlo : le passage d'ALERTE à OK était l'effet, au voisinage du seuil, du changement de loi de référence et de l'aléa, non un constat sur les données. Sa p-value de Monte-Carlo était conservatrice (#206) ; un OK n'y établissait pas l'absence d'hétéroscédasticité (#243, documentation seule). Une correction de niveau fixe était exclue (niveau dépendant fortement de la loi des erreurs) ; #301 a changé la statistique plutôt que d'en corriger le niveau.
**Décisions.** Variante retenue : décision Q-D2-Fi-1 du mainteneur du 21/10/2026 (#301), au vu des mesures de #309. Absence de puissance mesurable de la ligne : décision Q-D2-Fi-3 du 21/10/2026, constat transmis à #308. Présentation de l'ancienne ligne au dossier comme à la frontière : visa du mainteneur du 06/10/2026.
**Mesures retirées du guide.**
- Ancienne statistique sous H0, plan du triangle de contrôle (`20261021-issue309-puissance-mw.md`, T5 ; loi N, 2 000 triangles, moyenne (écart-type)) : covariance entre colonnes −1 858 (44), intra-colonnes −7 (305) ; statistique 0,316 (0,133) ; forme nR² sur la seule covariance entre colonnes 0,307 (0,088), intra-colonne 0,008 (0,012) ; maximum 1,133 (`-brut.tsv`, colonne `obs:BP`) ; aucun rejet de sa p χ²(1) aux seuils 0,10 et 0,05 sur 2 000 triangles sous N et sous E, ni sur les 1 000 sous A (`sec:calib-asympt-mw`).
- Vingt graines 20260831 à 20260850 (B = 999, moteur avant et après #46) : p MC moyenne 0,094 avant, 0,108 après (de 0,094 à 0,129) ; ALERTE sur 14 graines avant, 3 après, 11 bascules ALERTE → OK, aucune OK → ALERTE (sans script versionné).
- Fréquence, sous H0 du plan, d'une p MC ≤ 0,103 : 36/2 000 = 0,018 (N), 149/2 000 = 0,0745 (E), 6/1 000 = 0,006 (A) ; rapport d'environ 17 entre E et A au seuil 0,10 (recalcul sur `docs/tableaux/20261011-issue206-calibration-mw-brut.tsv`, colonne `pR:BP`, vivier redressé, lignes `type = rep` ; moteur `3a95e11`).
- Effet du redressement du vivier (constat R3, tableau T2 de `20261011-issue206-calibration-mw.md`) : sous E au seuil 0,10, sur les 1 000 mêmes triangles, le vivier non redressé rejetait sur 18 triangles où le vivier redressé ne rejetait pas, l'inverse n'arrivant jamais (p de Holm 9,2·10⁻⁵) ; taux 0,081 → 0,063.
- Intervalles des puissances sous P2 et des niveaux à 0,05, intervalles de la non-spécificité, rapport 476/204 = 2,33 sur les huit cellules de la première colonne sous P2 : fichier `20261021-issue309-puissance-mw.md` (T1, T2, T7, paramètres du plan).
**Correspondance SHA.** `3a95e11` : entrée transversale.

## `mw:m2b` — Adéquation de l'exposant de variance, colonne par colonne (partie III, § Hypothèse M2)

**Historique.** Garde sd = 0 sur les valeurs absolues des résidus : #60 (sans elle, `cor.test()` rendait une corrélation NA sans trace). Commentaire de la ligne réécrit par #431 ; il finissait jusque-là par « `les residus standardises sont d'echelle constante a l'interieur de chaque colonne.` », ce que dément l'effet de levier. Non-spécificité mesurée : #436.
**Décisions.** Règle p_j de `mw:m1b` (#90) et p_min de rang (#115) étendues à cette ligne par décision du mainteneur du 06/10/2026 ; loi conditionnelle aux rangs moyens : #207.
**Mesures retirées du guide.** p χ²(2K) sur le triangle de contrôle avant #90 : 0,387 (sans script versionné). Intervalles des puissances sous P2 : fichier `20261021-issue309-puissance-mw.md`, T2.
**Implémentation.** Texte du commentaire rédigé par `mw_tests()` pour la ligne (cité mot pour mot jusqu'au lot L5, désigné depuis par ses mots-clés ; vérifié identique à la référence `reserve2`) : « `Si la variance est proportionnelle a C(i,j), avec un facteur f_j et une constante sigma_j^2 communs aux annees (interpretation de l'outil, D(4)(c) et D(5)(d)(ii)), les residus de Mack r(i,j), non redresses, ont a sigma_j connu une variance 1 - h dans chaque colonne (h = C(i,j)/S_j, levier de la cellule, S_j somme des cumuls de la colonne) : leur echelle decroit avec C(i,j) par le seul effet de levier, et |r(i,j)| n'est pas echangeable a l'interieur d'une colonne sous H0. La p-value de Monte-Carlo (cle ExpVar) reproduit cet effet, les residus de chaque replication etant recalcules sur le triangle simule reajuste ; la p chi2(2K) et la plus petite p-value atteignable, fondees sur une loi echangeable, l'ignorent.` »

## `mw:m2var` — Variance unitaire des résidus de Mack (partie III, § Hypothèse M2)

**Règle retirée (verdict ALERTE).** La ligne portait un verdict ALERTE dès que |Var(r) − 1| dépassait 0,5. Motif du retrait : ce seuil n'était ni un niveau de test ni une règle de l'annexe XVII, et il était armé sur une valeur de référence fausse (la référence est (N − k)/(N − 1), non 1) : il ne pouvait pas détecter ce qu'il annonçait détecter. Diagnostic sans verdict : ADR 0001. Mention « et NON 1 » omise à k = 1 : #60.
**Mesures retirées du guide.** Rejeu hors moteur du bootstrap du triangle de contrôle avant #46 (vivier non redressé) : Var(r) entre 0,80741 et 0,80769, étendue 2,8·10⁻⁴ (sans script versionné).

## `sec:mwm3` — Hypothèse M3, indépendance (tête de section)

La tête reçoit, hors plafond, trois blocs communs à plusieurs fiches de M3, qui quittent `mw:m3cal` (lot L5) : la version de 1997 de l'annexe H (commune à `mw:m3cal` et `mw:m3caldiag`), la lecture conjointe du test calendaire et de Durbin–Watson (commune à `mw:m3cal`, `mw:m3dw`, `mw:m3runs`) et le sens d'un effet calendaire sur Z (fondement de la queue basse de `mw:m3cal` et `mw:m3caldiag`).

**Historique.** Lecture conjointe : #312. Version de 1997 : lecture consignée à #201 ; affirmation sur les p. D6.15–D6.23 non relue sur le texte intégral au 18/10/2026, ces pages ne figurant pas dans la transcription du 17/10/2026 ; p. D6.15–D6.23 non relues au 23/10/2026. Sens d'un effet calendaire : #276.
**Décisions.** Version de 1997 non retenue pour le test : décision Q-201-1 du mainteneur du 13/10/2026, sur avis d'`actuary`.
**Mesures retirées du guide.** Lecture conjointe (`docs/tableaux/20261023-fm-mesures.md`, scripts `m_fm_a.R` à `m_fm_c.R`) : moyennes des résidus de Mack par diagonale k = 0 à 6 : 0,108, −1,032, −1,354, −0,707, 0,498, 1,065, −0,074 (effectifs 1 à 6 et 6) ; par année de survenance i = 0 à 6 : −0,505, −0,366, −0,224, 0,317, 0,785, 0,901, 0,511 (effectifs 6, 6, 5, 4, 3, 2, 1) ; profils contre un choc sur l'exercice médian (0,344 et 0,122) ; rejet conjoint contre la dérive de 5 % (0,042, produit des marges 0,044) ; verdicts OK (0,300) et ALERTE (0,080) des lignes d'homogénéité (dans leurs fiches).

## `mw:m3cal` — Effets d'année calendaire, test de Mack (partie III, § Hypothèse M3)

**Historique.** Forme bilatérale (p-value de Monte-Carlo et p-value asymptotique 2(1 − Φ(|Z*|))) jusqu'à #276. Propriété de la forme bilatérale : p_min = min_z 2 min(P(Z ≤ z), P(Z ≥ z)) = 2⁻¹⁷ sur le triangle de contrôle ; pour tout n_k ≥ 2, P(Z_k = 0) = 2^(1−n_k) ≤ P(Z_k = ⌊n_k/2⌋), de sorte que l'atome bas de Z n'est jamais plus lourd que l'atome haut et que la valeur en queue basse est exactement la moitié de la valeur bilatérale ; plancher 2/(B + 1) (0,002 sur `reserve2`). Diagnostic par diagonale : #275. `.mw_calendrier_p_min()` : #115. Ex æquo à la médiane : #152.
**Décisions.** Queue basse : Q-Fd-1 et Q-Fd-3 du mainteneur du 14/10/2026 (#276). Gel des colonnes dégénérées : extension du 06/10/2026 (#60). Verdict du 5×5 dépendant des réplications tirées : D1-8.
**Mesures retirées du guide.**
- Forme bilatérale sur le triangle de contrôle (B = 999, graine 20260831) : p asymptotique 4,0·10⁻⁴, p MC 0,004, ECHEC (sans script versionné).
- Triangle construit à diagonales équilibrées (B = 99) : forme bilatérale 0,02 et ECHEC (sans script versionné).
- Niveaux de la forme bilatérale (#206) : 0,086 (N), 0,081 (E), 0,084 (A) à 0,10, ρ = 0,086 ; 0,0455, 0,041, 0,040 à 0,05 : `20261011-issue206-calibration-mw.md`.
- Taux bilatéraux des autres scénarios (exercice médian 0,113 / 0,185 ; dérive 0,084 / 0,104 ; à 0,05, 0,046 à 0,140) : `20261016-issue276-calendaire.md`, T2.
- Seconde mesure (`20261021-issue309-puissance-mw.md`, T2) : intervalle 0,344 [0,302 ; 0,387] sur l'exercice médian, 0,216 [0,181 ; 0,255] et 0,100 au seuil 0,05 contre la dérive ; contrôle fixé avant exécution : le fichier les porte.
- Cas absent des triangles d'essai mesurés : à l'observé, le gel peut retirer une colonne d'écart relatif à f̂_j au plus 10⁻¹² que l'aplatissement ne rend pas constante.
- Effet du gel mesuré en `mw:m3cor` : voir cette entrée.
- Discrétude de la statistique sous la loi oracle (83 à 86 valeurs distinctes selon la loi, atome le plus lourd de masse 0,098 à 0,103) : `20261016-issue276-calendaire.md`, tableau de la loi oracle.
- Mesure du triangle construit à diagonales équilibrées et de la seconde mesure de puissance : conservées en abrégé dans la fiche.

## `mw:m3caldiag` — Effets d'année calendaire par diagonale (partie III, § Hypothèse M3)

**Historique.** Égalité avec la table de la p. D6.49 vérifiée sur une transcription en rendu graphique, sans reconnaissance de caractères, faite le 17/10/2026 par une session en accès complet et consignée au commentaire 6238770854 de la PR #332.
**Décisions.** Ligne de diagnostic : #275, décisions Q-Fd-4 à Q-Fd-6 du mainteneur du 14/10/2026 ; repère fixe indépendant de α : Q-Fd-5 ; repondération de 1997 écartée : Q-201-1.
**Renvois.** #201 (lecture du repère de 10 %, p. D6.49).

## `mw:m3acc` — Homogénéité des résidus entre années de survenance (partie III, § Hypothèse M3)

**Historique.** Commentaire de la ligne réécrit par #419 ; il se terminait jusque-là par « `Traduction testable de l'independance des annees de survenance, D(2)(h)(i)` ». Non-spécificité mesurée : #419.
**Décisions.** `.mw_kruskal_p_min()` : #115, décision du mainteneur du 06/10/2026.

## `mw:m3cor` — Corrélation entre années de développement adjacentes (partie III, § Hypothèse M3)

**Historique.** Avant l'extension de l'ensemble figé (#60, décision du 06/10/2026), une paire n'était exclue que si l'aplatissement rendait la colonne constante dans le triangle courant. Critère d'acceptation de l'extension : égalité des statistiques répliquées, non des p-values, une réplication modifiée ne déplaçant la p-value que si elle franchit la statistique observée du côté de la queue retenue (avis d'`actuary`).
**Mesures retirées du guide.** Rejeu de la boucle de `mw_bootstrap()` (B = 999, graine 20260831) sur le triangle de Taylor & Ashe dont la colonne j = 4 est rendue constante et sur sa perturbation de ±4·10⁻¹³ en relatif (écart observé 4,5·10⁻¹³, colonne dégénérée dans les deux cas) : avant l'extension, les statistiques répliquées des deux triangles différaient dans 8 réplications pour le test calendaire et 30 pour la corrélation ; depuis, dans aucune ; p-values de Monte-Carlo déjà égales avant (sans script versionné).
**Implémentation.** Phrase retirée parce qu'erronée : « C'est, avec la corrélation, le seul test du dispositif pour lequel aucune p-value non simulée n'existe. » (la famille α et Durbin–Watson n'en ont pas non plus ; cas B de `sec:boot-mw`).

## `mw:m3runs` — Test des suites sur les résidus de Mack (partie III, § Hypothèse M3)

**Historique.** Test jusqu'à #312, p-value de Monte-Carlo retenue jusque-là ; diagnostic par décision, variante secondaire, depuis #312. Motif Monte-Carlo en tête du commentaire posé par `mw_tests()` jusqu'à #358, par `add()` depuis. Plancher d'ex æquo : #112. Motif d'absence de p_min joint par `mw_tests()`, comme sur les lignes de #299. Champ `p_min` : #115.
**Décisions.** Diagnostic par décision : Q-D1-Fm-1 du mainteneur du 23/10/2026, option (B) ; ADR 0001.
**Mesures retirées du guide.** Cellules (iii) non reprises (choc sur l'exercice médian 0,122 contre 0,046 ; année atypique 0,050 contre 0,020 ; cellule × 4 0,026 contre 0,004 ; dernier exercice 0,046 contre 0,068 ; P3 sans rejet) et intervalles des taux sous les alternatives : `20261021-issue309-puissance-mw.md`, T2.
