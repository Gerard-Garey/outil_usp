# Revue de pertinence actuarielle et statistique des tests et des graphiques (15/10/2026)

> *Rédigé par la session principale (IA) à partir des rapports des six consultations d'`actuary-approfondi` (modèle servi : Fable ; effort `xhigh` demandé à l'appel), reproduits intégralement dans `20261015-pertinence-tests-graphiques/bloc-1.md` à `bloc-6.md`, avec leurs scripts de mesure sous `20261015-pertinence-tests-graphiques/mesures/`. Dépôt lu à `c645926` ; les numéros de ligne du `.tex` sont donnés à ce commit.*

## 1. Mandat, organisation et statut des preuves

### 1.1 Mandat

Mission hors feuille de route, sur ordre du mainteneur du 15/10/2026 : faire vérifier par `actuary-approfondi`, appelé avec le modèle Fable et l'effort `xhigh`, la **pertinence actuarielle et statistique** de tous les tests statistiques et de tous les graphiques de l'outil, à T = 8. La revue porte sur la méthode, pas sur l'implémentation : elle lit d'abord la documentation (`docs/latex/doc_tests_usp.tex`), et le code seulement pour savoir ce qui est réellement calculé quand la documentation est ambiguë. Les 37 issues ouvertes sont examinées dans le même mouvement. Point de départ : la revue précédente du même type, l'issue #5 (21/09/2026, moteur au commit `f93847f`).

### 1.2 Décisions de cadrage du mainteneur (15/10/2026)

| Question | Décision |
|---|---|
| Livrable | Le présent rapport, versionné ; aucune modification du `.tex` ni du code sur cette branche ; les corrections suivront dans des branches ultérieures. |
| Consultations Fable | Six blocs en parallèle, soit six consultations `actuary-approfondi` / Fable / `xhigh`, au-delà du plafond ordinaire de trois par branche (`docs/agents/routage.md`, § 5.2), sur accord exprès ; une septième, de synthèse, seulement si deux blocs se contredisent (§ 4.1.2) ; au plus une relance ciblée par bloc. Consolidation par la session principale. |
| Issues ouvertes | Toutes reçoivent un verdict dans ce rapport ; les agents n'écrivent rien sur GitHub ; les commentaires d'issues et les issues nouvelles proposées ne sont publiés qu'après l'accord du mainteneur. |
| Périmètre | Tests (H1 à H4, stabilité, robustesse, M1 à M6), graphiques, sections transversales sur les p-values, vérification empirique (niveaux, puissances, calibrations), synthèse des verdicts. Hors périmètre : contrôles de qualité des données, architecture, reproductibilité, calibration de σ_USP (estimation, crédibilité, mélange, MSEP). |

### 1.3 Blocs et consultations

| Bloc | Objet | Sections du `.tex` | Statut rendu | Appels d'outils, durée | Motif d'un statut partiel |
|---|---|---|---|---|---|
| 1 | Transversal : bootstrap paramétrique, modèle auxiliaire MCO, nature des p-values, tableaux 1 et 2, vérification empirique lognormale, synthèse des verdicts | 3894-4093, 4333-7182, 14636-15211, 16388-16722 | `complet` (deux points en `revue requise`) | 58, 13 min | — |
| 2 | H1 et H2 | 7183-8876 | `complet` | 62, 16 min | — |
| 3 | H3 et H4 | 8877-10613 | `partiel` | 63, 14 min | références vérifiées en existence seulement (proxy) ; textes EIOPA et CEIOPS sur le sens de B(2)(g)(iv) non lus |
| 4 | Stabilité, robustesse, graphiques lognormaux | 10614-11950 | `partiel` | 56, 15 min | source primaire de Bollen et Jackman (seuil de Cook) introuvable ; couverture de l'IC bootstrap non mesurée |
| 5 | Merz-Wüthrich : cadre, bootstrap, M1, M2 | 4094-4332, 12178-13850 | `complet` | 58, 18 min | — |
| 6 | Merz-Wüthrich : M3 à M6, graphiques, calibration | 11951-12177, 13851-14635, 15212-15647 | `partiel` | 77, 35 min | PDF de Mack 1994 et 1997 inaccessibles ; mesures de puissance à R = 60 |

Le modèle servi est Fable (`claude-fable-5-1`) pour les six consultations (`bash .claude/outils/bilan_journal.sh`) ; l'effort n'est pas observable dans le journal (`docs/agents/routage.md`, § 7). Les trois statuts `partiel` tiennent à une **information manquante** (source inaccessible, mesure non faite), non à une exploration inachevée : selon `docs/agents/routage.md`, § 5.1, la suite est d'obtenir l'information, non une relance ; aucune relance n'a été faite.

### 1.4 Contrôles de la session principale

- **Pas de contradiction entre blocs**, donc pas de septième consultation. Deux tensions apparentes sont levées : (a) la borne de Bonferroni de Grubbs est **exacte** pour p ≤ 0,24 sur les résidus z_t à δ̂ = 1 de la méthode lognormale (bloc 4, § 4.3) et un **majorant inutile** sur les résidus de Mack (bloc 6, C1) : deux bases différentes, que le tableau 1 doit distinguer (bloc 1, C4) ; (b) #5 est jugée fermable (bloc 1) alors que la table de puissance de Merz-Wüthrich reste ouverte (bloc 6) : les deux se concilient si l'issue proposée R-13 (§ 6) est créée avant la fermeture.
- **Désaccord avec la revue précédente** (#5), argumenté par mesure : le bloc 6 renverse les verdicts de #5 sur Kruskal-Wallis entre années de survenance (fragile → pertinent) et sur Grubbs et Rosner Merz-Wüthrich (pertinent / fragile → à remplacer).
- **Deux affirmations centrales recontrôlées** (`LC_ALL=C.UTF-8 Rscript`, lecture de `tests/reference/reserve2.rds` et de `docs/tableaux/20261008-issue166-brut-J1.tsv`) :
  - Σ_i r(i,j)² = n_j − 1 dans chaque colonne de `reserve2` (6, 5, 4, 3, 2, 1, exactement), d'où |r(i,j)| ≤ √(n_j − 1) ≤ 2,449 ; λ₁ de Rosner (N = 27, α = 0,10) = 2,698. **Nuance de la session principale** : la statistique de Rosner divise par l'écart-type du vivier, au plus √(21/26) ≈ 0,90, et peut donc atteindre environ 2,72 dans la configuration limite où une cellule de la colonne la plus longue porte toute la somme des carrés de sa colonne ; l'énoncé exact est « pratiquement inopérante », non « structurellement impossible », ce que les mesures confirment (0 déclaration sur 2 000 triangles sous H₀, #206 ; 0 sur 60 avec une cellule injectée, bloc 6).
  - TOST : p ≥ 0,30 (ECHEC) dans 2 000 jeux sur 2 000 simulés sous le modèle ajusté à J1 (#166) ; `premium` : ECHEC, p = 0,465.
- **Statut des chiffres nouveaux** : les mesures des agents sont des constats de simulation hors CI, sous un seul plan (J1, J2 ou `reserve2`), souvent à petit R ; elles donnent des ordres de grandeur. Leurs scripts sont versionnés sous `mesures/` ; aucun de ces chiffres n'entre dans le `.tex` avant d'avoir été repris par un script de `tests/` avec sortie datée sous `docs/tableaux/` (règle de #164).
- **Sources** : le proxy de la session a refusé la plupart des hôtes d'éditeurs (casact.org, cambridge.org, EIOPA, stata.com, rdrr.io…) ; la plupart des références sont vérifiées au niveau du résumé ou de la notice, ce que chaque bloc dit référence par référence (§ 7 de chaque rapport).

## 2. Synthèse

Le dispositif est **formellement rigoureux** : la hiérarchie exacte ≻ Monte-Carlo ≻ non simulée est fondée, la règle R1 est arithmétiquement juste, les erreurs Monte-Carlo et d'approximation sont séparées, les calibrations de niveau sont tracées par scripts et commits, et la documentation est honnête sur ses limites. Aucune p-value retenue n'est fausse au sens de sa définition. **Le risque pour le dossier ACPR n'est pas une p-value erronée mais une restitution qui suggère une preuve que les données ne peuvent pas apporter** : à T = 8 et sur des volumes peu dispersés, plusieurs hypothèses ne sont pas testables, et la table garde des verdicts OK, ALERTE ou ECHEC là où il n'y a ni puissance ni information ; à l'inverse, la multiplication de lignes corrélées produit des alertes attendues sous le modèle vrai sans règle pour les lire ensemble.

Constats principaux, par priorité :

1. **(H) Non-testabilité à faible dispersion des volumes, commune aux deux méthodes** (§ 3.1). Lognormale : rapport max/min des volumes de 1,30 sur J1, puissance des six lignes H2 ≤ 0,14 contre δ = 0 ; le TOST sort ECHEC dans 100 % des jeux conformes simulés à J1. Merz-Wüthrich : CV intra-colonne de C de 6 à 8 % sur `reserve2`, effet minimal détectable de l'ordonnée à l'origine de 16 à 67 % du niveau de la colonne, aucune puissance de M2 contre les exposants 0 et 2.
2. **(H) Multiplicité sans lecture conjointe** (§ 3.2) : sous le modèle ajusté, 63 à 66 % des jeux conformes portent au moins une ALERTE ou un ECHEC, 37 à 48 % au moins un ECHEC ; le document le mesure mais ne donne aucune règle pour lire k ECHEC sur 36 lignes.
3. **(H) M4 Merz-Wüthrich pratiquement aveugle** (§ 3.5) : les résidus de Mack sont bornés par colonne et une cellule aberrante gonfle son propre σ̂_j ; Rosner ne déclare rien, Grubbs compare à un vivier qui contient la cellule suspecte. Le bon outil existe déjà : le résidu studentisé externe de `mw_influence()`.
4. **(H) Breusch-Pagan sur résidus de Mack mal construit** (§ 3.4) : 98,6 % de la variance du régresseur est entre colonnes, où la moyenne de r² est fixée par construction ; d'où la cause, jusqu'ici « non établie », de son sous-rejet.
5. **(M) Redondances** (§ 3.3) : neuf tests de normalité corrélés de 0,94 à 0,98, Ljung-Box (1) ≈ Durbin-Watson, Box-Pierce dominé, Spearman-temps ≈ Mann-Kendall (0,982), Breusch-Pagan 1979 ≈ Koenker, six lignes « ratios bruts » doublons à π̂ constant qui comptent pourtant un OK, Durbin-Watson ≈ calendaire en Merz-Wüthrich.
6. **(M) Statuts à revoir** (§ 3.4) : Smirnov teste une position, pas une variance ; famille α en ECHEC (p = 0,005) pour un écart de 0,11 % sans enjeu ; ESD lognormale au niveau 15 % ; test des suites Merz-Wüthrich tournant de fait à 5 %.
7. **(M) Graphiques trompeurs** (§ 3.6) : courbe lissée du spread-plot (amplitude médiane 0,54 sous H₀ sur 8 points), QQ-plot Merz-Wüthrich contre la droite identité (pente attendue 0,88 par construction), histogramme bootstrap de σ sans σ̂, coloration à 10 % du jackknife franchie par 57 à 86 % des jeux conformes.
8. **(M) Incertitude d'estimation sous-documentée** (§ 3.7) : loi bootstrap de σ̂ biaisée de −11 à −14 %, couverture de l'intervalle de percentile non mesurée ; effet de l'extrapolation de σ²_{J−1} sur √MSEP de −16,5 % à +36 % sur `reserve2`, non restitué.
9. **(M) Puissance largement non mesurée et chiffres non tracés** (§ 3.8) : 28 lignes sur 53 « non étudiée » au tableau de traçabilité ; #164 toujours ouverte.
10. **(M) p Monte-Carlo conditionnelle V3h** (§ 3.9) : choix pragmatique sans fondement théorique ; le niveau conditionnel au bord (0,12 à 0,13 pour l'hétéroscédasticité) est à écrire dans le dossier.
11. **(B) Formulations de la documentation** (§ 3.10) : une trentaine de points mineurs (vitesses non sourcées, classements internes contradictoires, attributions à vérifier).

## 3. Constats transversaux

### 3.1 Identifiabilité à faible dispersion des volumes

Le même mécanisme traverse les deux méthodes : quand les volumes varient peu, ni la structure de variance ni l'écart à la proportionnalité stricte ne sont identifiables, et les tests correspondants n'ont pas de puissance. La documentation le dit pour δ (fiche de position, LR aux bornes) ; elle ne le tire pas pour les autres lignes, qui gardent leurs verdicts.

- **TOST** (bloc 2, § 4.2) : sur J1, p_plancher = 0,440 ≥ 0,30, « OK et ALERTE inatteignables » ; l'ECHEC est acquis avant l'observation de â, ce qui est l'analogue d'un test inopérant (R1). Proposition R-2 : diagnostic « équivalence non démontrable avec ces données ».
- **Nullité de la constante** (bloc 2, § 4.1) : un rejet à 10 % exige |â| > 1,23 ȳ sur J1 (0,12 ȳ sur J2). Proposition R-18 : constante minimale détectable dans le `detail`.
- **H2** (bloc 2, §§ 4.7, 4.10) : contraste maximal de variance entre δ = 0 et δ = 1 égal à max(x)/min(x) = 1,295 sur J1 ; puissance exacte d'un F(4,4) bilatéral à ce rapport : 0,106 ; simulation des six lignes sur J1 : ≤ 0,14 contre δ = 0, ≤ 0,38 contre un écart-type triplé ; au moins une ligne H2 ECHEC dans 16,9 % des jeux conformes. Proposition R-3 : règle de restitution « structure de variance non testable avec ces volumes » et une seule ligne à verdict (Breusch-Pagan Koenker), le LR sur δ portant l'argumentation H2 du dossier.
- **Merz-Wüthrich, M1 et M2** (bloc 5, §§ 4.3, 4.8) : effet minimal détectable de a_j à 80 % de puissance de 20, 16, 26, 36 et 67 % du niveau de la colonne (j = 0 à 4) ; sonde : M2 au niveau sous les exposants 0 et 2. Proposition R-12 : CV intra-colonne et se(â_j)/C̄_{j+1} restitués par colonne, sans verdict.

### 3.2 Multiplicité et lecture conjointe

Mesures concordantes des six blocs : sous le modèle ajusté, au moins une ALERTE ou un ECHEC dans 63 à 66 % des jeux lognormaux et 63,6 à 65,5 % des triangles conformes ; au moins un ECHEC dans 37,6 à 48,2 % des jeux lognormaux (`.tex` 14813-14816, 14983-14989) ; par famille : H3 seule 18,9 % (bloc 3), stabilité 26 % (bloc 4), H2 16,9 % d'ECHEC (bloc 2), M3 35 % (bloc 6). L'écart à l'indépendance (97 % attendus pour 34 lignes) mesure une forte dépendance positive. Le document renvoie à une « justification explicite » (l. 16410-16412) sans outil. Propositions : R-1, p-value ajustée par famille (minP de Westfall-Young) calculée sur les réplications déjà tirées, restituée en diagnostic ; règles de lecture conjointe par famille dans les fiches (R-6, R-16, R-19).

### 3.3 Redondances

| Famille | Lignes redondantes | Mesure | Proposition |
|---|---|---|---|
| H3 | Shapiro-Wilk à loi nulle simulée, Cramér-von Mises, KS contre N(0,1), Lilliefors | corrélations sous H₀ : SW-AD −0,97, AD-CvM 0,98, KS-Lilliefors 0,98, SW-SF 0,94 ; la batterie ajoute 12 points de puissance à SW seul sous t(3) (0,327 contre 0,203) | R-6 |
| H4 | Ljung-Box (1) et Durbin-Watson ; Box-Pierce (2) et Ljung-Box (2) | puissances identiques à 0,01 près (#229) ; Box-Pierce dominé selon la doc elle-même (l. 9593) | R-6 |
| H1 | Spearman ratio-temps et Mann-Kendall ; Cox-Stuart | corrélation 0,982 sur les 8! ordres, jamais de verdicts opposés ; Cox-Stuart inopérant | R-3 (H1) ou R-20 |
| H2 | Breusch-Pagan 1979 et Koenker ; White, Goldfeld-Quandt, Brown-Forsythe | même SCE ; trois paramètres ou deux blocs de quatre sur huit points | R-3 |
| H4 et stabilité | six lignes « ratios bruts » (DW, LB1, suites, sup-F, CUSUM, Grubbs) | doublons à π̂ constant (96 % des jeux de J1), commentaire « CONTROLE SANS OBJET ICI » mais verdict OK compté | R-7 |
| M1 | pente intra-colonne et famille α | même alternative, pondérations opposées | R-11 |
| M3 | Durbin-Watson sur résidus de Mack et test calendaire | l'ordre colonne par colonne enchaîne des diagonales consécutives ; sur `reserve2`, deux ECHEC pour un même signal | R-16 |

### 3.4 Statuts et rattachements à revoir

- **Smirnov** (bloc 2, § 4.9) : teste une différence de position entre groupes de volume (puissance 0,04 à 0,05 contre un écart-type doublé ou triplé), donc une alternative de H1, non de H2 (R-3).
- **Famille α** (bloc 5, § 4.6) : ECHEC à p = 0,005, la plus forte preuve de la table, pour f̂_j^(0,1,2) différant d'au plus 0,17 % ; la fiche la qualifie elle-même de « diagnostic de robustesse plus que test d'hypothèse » (R-11).
- **Pente intra-colonne** (bloc 5, § 4.2) : pilotée à 82 % par les colonnes j = 3 et 4 (7 cellules) ; en paramétrisation relative, `reserve2` passerait de OK (p = 0,778) à ALERTE (p = 0,090) (R-11).
- **Breusch-Pagan sur résidus de Mack** (bloc 5, § 4.7) : quantile 0,90 de la loi bootstrap de nR² = 0,657 contre 2,706 pour χ²(1) ; une régression à effets fixes de colonne rend une loi régulière (quantile 3,03 ; p = 0,214 sur `reserve2`, verdict inchangé) (R-5).
- **ESD lognormale** (bloc 4, § 4.4) : sous i.i.d. normal à T = 8, k = 2, α = 0,10, P(k̂ ≥ 1) = 0,152, P(k̂ = 2) = 0,062 ; ALERTE au niveau 15 % et ECHEC sans calibration (R-8, lié à #174).
- **Test des suites Merz-Wüthrich** (bloc 6, C3) : référence ρ ≈ 0,05 par discrétude, puissance ≤ 0,12 dans tous les scénarios : variante secondaire (R-16).
- **Kruskal-Wallis entre années de survenance** (bloc 6, C4) : seule ligne de M3 puissante (0,65 contre une année à cadence atypique) : **pertinent**, contrairement au verdict de #5.

### 3.5 Points aberrants du triangle (M4)

Bloc 6, C1. L'identité Σ_i r(i,j)² = n_j − 1 borne les résidus de Mack ; une cellule aberrante gonfle σ̂_j, estimé sur la même colonne, et se masque elle-même (incrément (2,2) × 4 : σ̂₁ passe de 0,844 à 24,9, résidu de Mack 2,05, résidu studentisé externe 60,3). Rosner : 0 déclaration sur 60 triangles à cellule injectée (§ 1.4 pour la nuance sur la borne) ; Grubbs : puissance 0,50 par la p Monte-Carlo, sur une loi de référence tirée d'un vivier qui contient la cellule suspecte, niveau 0,159 sous la loi asymétrique de #206. Proposition R-4 : statistique max |t(i,j)|, p Monte-Carlo par le bootstrap existant, borne de Bonferroni Student(n_j − 2) en complément ; Rosner retiré ou porté sur t.

### 3.6 Graphiques

| Graphique | Défaut | Mesure | Proposition |
|---|---|---|---|
| spread-plot lognormal (`plot_spread`) | lowess f = 2/3 sur 8 points, sans bande | amplitude médiane 0,54 (q90 0,84) sous H₀ ; écart des extrémités > 0,3 une fois sur deux | R-10 : bande lue dans `bootstrap$z_boot`, ou retrait de la courbe |
| QQ-plot Merz-Wüthrich (`plot_mw_qq`) | droite identité (plotly) ou par quartiles (base R) ; aucune enveloppe | var(r) = Σ(n_j − 1)/(N − 1) = 0,81 : pente attendue 0,88 [0,866 ; 0,896] ; `reserve2` 0,877 | R-15 |
| `plot_boot_sigma` (deux méthodes) | ni σ̂, ni σ_USP, ni quantiles | biais −11 à −14 % invisible | R-9 |
| influence σ lognormale (`plot_influence_sigma`) | années > 10 % colorées | repère franchi par 70 % (J1) et 57 % (J2) des jeux conformes | R-20 (étiqueter ou retirer la coloration) |
| nuages de résidus Merz-Wüthrich (`residus_acc`, `residus_cal`) | aucune statistique par groupe | sur `reserve2`, la dérive par diagonale (+0,11 ; −1,03 ; −1,35 ; −0,71 ; +0,50 ; +1,07 ; −0,07) ne se lit qu'en la calculant | R-16 |
| facteurs Merz-Wüthrich (`plot_mw_facteurs`) | σ̂_j calculé mais non tracé, alors qu'il est l'objet de M6 | — | R-14 |

Pertinents sans réserve : ajustement, ratio, résidus, surface et coupe, profil de δ avec ses repères, enveloppe du QQ-plot lognormal (constat de #5 réglé), petits multiples, ordonnées à l'origine, famille α, levier et DFBETAS Merz-Wüthrich, contributions, calibration.

### 3.7 Incertitude d'estimation

- **IC bootstrap lognormal** (bloc 4, § 4.8) : sur les cinq cas, moyenne(σ*) est 11,2 à 13,9 % sous σ̂ (σ̂ au 69e-73e centile de σ*) ; percentile 90 % de σ_USP sur `premium` [0,0752 ; 0,1370] contre un intervalle « basic » [0,0859 ; 0,1477] ; couverture à T = 8 non mesurée. Observation, au rang d'hypothèse : σ̂/moyenne(σ*) = 1,13 à 1,16 ≈ √((T+1)/(T−1)) = 1,134. Proposition R-9.
- **Extrapolation de σ²_{J−1}** (bloc 6, C6) : √MSEP de `reserve2` = 199,5 avec la règle du minimum, 226,4 (+13,5 %) avec σ²_{J−2}, 271,3 (+36 %) avec le quotient, 166,5 (−16,5 %) avec 0. Proposition R-14 : restituer ces valeurs déterministes. La règle elle-même est réglementaire (D(5)) et hors périmètre.

### 3.8 Puissance et chiffres non tracés

- Tableau de traçabilité de la rubrique 7 : 28 lignes sur 53 « Non étudiée », alors que `docs/tableaux/20261010-issue229-p-conditionnelle-puissance.md` porte déjà les taux des 34 statistiques sous six alternatives (bloc 1, C10 ; bloc 3, § 4.4 : AD, CvM, KS, Lilliefors y ont une puissance mesurée sous contamination et asymétrie que leurs fiches disent « non étudiée »).
- Chiffres sans script : « 3 000 échantillons de taille 200 », Grubbs 4,6 % à T = 20, D'Agostino 100 %, Anscombe-Glynn 92,5 %, seuils T ≥ 50 / 30 / 25 (bloc 1, C7) ; Lilliefors 10,6 % / 5,2 % (l. 9178) ; Durbin-Watson 10,1 % / 5,2 % (l. 9550) (bloc 3) ; tableau de niveaux de Breusch-Pagan 1979 (l. 8559-8579) et seuil « T ≥ 30 » (l. 16653) (bloc 2). Tous relèvent de #164, dont le bloc 1 propose la résolution valeur par valeur (§ 5).
- Puissances nouvelles mesurées par les agents, à versionner : sup-F, CUSUM, Grubbs lognormaux (bloc 4 : saut de 2 σ au milieu 0,62 / 0,70 ; une année à 4 σ, Grubbs 0,64) ; RESET (bloc 2 : 0,18 à 0,78) ; Bartels (bloc 3 : 0,22 à ρ = 0,5) ; M1-M2 (bloc 5, sonde) ; M3-M4 (bloc 6, R = 60). Propositions R-13, R-17 ; élargissement de #274.

### 3.9 p Monte-Carlo conditionnelle (V3h) et sélection par le régime

Bloc 1, C2 et C3. Le conditionnement sur le régime de δ̂ (ADR 0014) porte sur un événement non ancillaire ; aucun résultat ne le fonde, la validité est un constat sur trois jeux, l'extension à `reserve1` une hypothèse. Au bord 1 de J1 (le régime le plus fréquent), Breusch-Pagan, Breusch-Pagan 1979 et White rejettent dans 12,2 à 13,0 % des cas à α = 0,10 ; le document le dit (l. 14861) mais la phrase doit figurer dans le dossier. Même phénomène côté p exactes : « valides sans réserve » (l. 5325) est à renvoyer à l'effet de sélection mesuré l. 6849-6858 (Shapiro-Wilk 0,111 conditionnellement à δ̂ = 1). Le bloc 2 relève que l'ECHEC de Goldfeld-Quandt sur `premium_interieur` repose sur cette p conditionnelle. Aucune proposition nouvelle de méthode (le MMC de Dufour a été écarté par #217) ; documentation : R-19.

### 3.10 Documentation

Une trentaine de formulations à reprendre, toutes sans effet sur les résultats ; détail dans les rapports de bloc, regroupé en trois issues (R-19 transversal, R-20 lognormale, R-21 Merz-Wüthrich). Exemples : vitesses O(T^{-1/2}) non sourcées (tableau 2) ; D'Agostino classé « asymptotique » contre sa famille (ii) ; Smirnov « Asympt. ? Oui » au tableau 1 alors que le moteur n'en calcule pas ; seuil 0,30 du sens « rejeter » sans mention de convention ; encadré H3 « tous les tests conservateurs » faux pour W, W′, D_L à π̂ constant ; attribution du seuil de Cook (deux lectures, § 7) ; « le test le plus informatif du dispositif » (calendaire, l. 14002) non mesuré ; « valeurs critiques tabulées » de Rosner alors que le code les calcule ; « seconde exigence du texte » (homogénéité de f_j) à présenter comme interprétation ; cause du sous-rejet de Breusch-Pagan Merz-Wüthrich désormais établie ; références à ajouter (Venter 1998, Mack 1999) ou à vérifier (Davison et Hinkley 1997 pour le redressement par le levier ; Royston 1993 pour Shapiro-Francia).

### 3.11 Ce qui est sain

Hiérarchie des p-values et interdiction du repli ; règle R1 et p_min ; modèle auxiliaire MCO et sa classification ; calibrations de niveau (#166, #221, #175, #229, #206, #119) ; Durbin-Watson exact à π̂ constant ; Shapiro-Wilk, Anderson-Darling, Jarque-Bera, D'Agostino ; Mann-Kendall ; test de Pitman ; RESET (puissance modérée, non nulle) ; sup-F, OLS-CUSUM, Grubbs lognormaux ; LR sur δ et son bootstrap restreint ; centrage et variance unitaire en diagnostics ; Kruskal-Wallis et corrélation entre colonnes adjacentes ; ordonnée à l'origine par colonne ; M5 en diagnostic ; graphiques listés au § 3.6. Les constats de #5 sont réglés pour l'essentiel (§ 4).

## 4. Verdicts par élément

Verdicts : **pertinent**, **à compléter**, **fragile**, **à remplacer** (retrait ou remplacement). Priorité vis-à-vis du dossier : H, M, B. Colonne #5 : état du constat de la revue du 21/09/2026. Justification et preuves : rapport du bloc indiqué.

### 4.1 Transversal (bloc 1)

| Élément | Verdict | Prio | #5 | Constat |
|---|---|---|---|---|
| Hiérarchie exacte ≻ Monte-Carlo ≻ non simulée | pertinent | — | réglé | fondée (ADR 0002) |
| Interdiction du repli, grandeurs rivées (ADR 0001) | pertinent | — | réglé | — |
| p Monte-Carlo marginale V1 | à compléter | M | réglé | dire le niveau conditionnel au bord (0,12-0,13) |
| p Monte-Carlo conditionnelle V3h (ADR 0014) | à compléter | M | sans objet | régime non ancillaire, aucun théorème ; asymétrie à écrire |
| Règle R1, p_min | pertinent | — | réglé | arithmétique vérifiée |
| Plancher p_min_mc | pertinent | B | réglé | classement dépendant de la graine près de α, fréquence non mesurée |
| Phrase « verdict sensible » (#244) | pertinent | — | sans objet | — |
| Seuils OK / ALERTE / ECHEC | à compléter | B | aucun | 0,30 du sens « rejeter » sans source |
| Multiplicité, lecture conjointe | à compléter | H | aucun | § 3.2, R-1 |
| Base de résidus z_t / u_t | pertinent | B | réglé | doublons u_t à exclure du décompte conjoint |
| Modèle auxiliaire MCO | pertinent | — | réglé | — |
| Tableau 1 | à compléter | B | partiel | Smirnov, Grubbs, Shapiro-Wilk ; couverture inégale des diagnostics |
| Tableau 2 | à compléter | B | aucun | vitesses non sourcées |
| « Ce que l'on peut et ne peut pas affirmer à T = 8 » | à compléter | B | partiel | « sans réserve » ; D'Agostino |
| Calibration des p Monte-Carlo lognormales | pertinent | — | réglé | reproductibles au commit cité |
| « Taille effective et puissance » (l. 14684-14691) | à remplacer | M | partiel | chiffres à T = 200 et 20, non tracés |
| Tableau de traçabilité de la rubrique 7 | à compléter | M | partiel | 28 lignes « Non étudiée » |
| Synthèse et hiérarchie de lecture | à compléter | M | réglé | ordre de consultation, pas règle de décision |

### 4.2 Méthode lognormale : H1 et H2 (bloc 2)

| Élément | Verdict | Prio | #5 | Constat |
|---|---|---|---|---|
| Nullité de la constante | à compléter | M | réglé | rejet impossible sous 1,23 ȳ sur J1 |
| TOST | à compléter | H | partiel | ECHEC certain sur J1 (100 %) ; Δ = 10 % ȳ sans source |
| Pitman (pente) | pertinent | M | partiel | exact ; R4 fragile (#218, #230) |
| Fisher global (diagnostic) | pertinent | — | réglé | — |
| R² (diagnostic) | pertinent | — | réglé | — |
| RESET | fragile | B | ouvert | puissance 0,18 à 0,78 selon la courbure (J1) |
| Spearman ratio / volume | pertinent | — | réglé | — |
| Spearman ratio / temps | à compléter | B | réglé | redondant avec Mann-Kendall |
| Mann-Kendall | pertinent | — | réglé | taille exacte 0,061 à α = 0,10 |
| Cox-Stuart (diagnostic) | fragile | B | réglé | inopérant à T ≤ 9 |
| Breusch-Pagan Koenker | à compléter | H | ouvert | puissance nulle à volumes peu dispersés ; ECHEC sur `premium` non cité par la fiche |
| Breusch-Pagan 1979 | fragile | M | partiel | redondant ; règle de lecture caduque sous p Monte-Carlo |
| White | fragile | B | ouvert | — |
| Goldfeld-Quandt | fragile | M | ouvert | ECHEC de `premium_interieur` porté par V3h |
| Brown-Forsythe | fragile | B | ouvert | — |
| Smirnov | à remplacer | M | partiel | rattachement à H1 (position) |
| Position de δ̂ (diagnostic) | pertinent | — | réglé | — |

### 4.3 Méthode lognormale : H3 et H4 (bloc 3)

| Élément | Verdict | Prio | #5 | Constat |
|---|---|---|---|---|
| Shapiro-Wilk | pertinent | — | réglé | — |
| Shapiro-Wilk à loi nulle simulée | fragile | B | réglé | doublon de SW |
| Shapiro-Francia | pertinent | B | sans objet | redondant ; source et plage de la p non simulée à harmoniser |
| Anderson-Darling | pertinent | B | réglé | rubrique 7 à compléter (#229) |
| Cramér-von Mises | fragile | B | réglé | doublon d'AD |
| Kolmogorov-Smirnov contre N(0,1) | fragile | B | réglé | le moins puissant partout |
| Lilliefors | pertinent | B | réglé | redondant ; calibration citée non tracée |
| Jarque-Bera | pertinent | — | partiel | le plus puissant sous contamination |
| Asymétrie de D'Agostino | pertinent | — | partiel | — |
| Aplatissement d'Anscombe-Glynn (non applicable) | pertinent | B | sans objet | marquage correct |
| Durbin-Watson | pertinent | — | réglé | exact à π̂ constant ; légèrement conservateur sous t(3) |
| Ljung-Box (1) | fragile | B | réglé | doublon de DW |
| Ljung-Box (2) | fragile | B | réglé | puissance non mesurée |
| Box-Pierce (2) | à remplacer | B | partiel | retrait (dominé par LB2) |
| Test des suites | fragile | M | réglé | p_min 4/70, puissance moitié de DW |
| Centrage (diagnostic) | pertinent | B | réglé | — |
| Variance unitaire (diagnostic) | pertinent | B | réglé | incohérence interne de formulation (l. 10400) |
| Durbin-Watson sur ratios bruts | à compléter | M | partiel | diagnostic à π̂ constant (R-7) |
| Ljung-Box (1) sur ratios bruts | à remplacer | B | partiel | retrait |
| Suites sur ratios bruts | fragile | B | partiel | doublon exact à π̂ constant |
| Contrôle KKT (hors table) | pertinent | — | sans objet | — |

### 4.4 Méthode lognormale : stabilité et robustesse (bloc 4)

| Élément | Verdict | Prio | #5 | Constat |
|---|---|---|---|---|
| sup-F | pertinent | B | réglé | τ sans effet à T = 8 ; p de Hansen non calculée |
| OLS-CUSUM | pertinent | B | réglé | — |
| Grubbs | pertinent | B | réglé | borne de Bonferroni exacte pour p ≤ 0,24 |
| ESD généralisé | fragile | M | ouvert | niveau 15 % (R-8) |
| Distance de Cook (diagnostic) | pertinent | B | réglé | attribution du seuil 4/T à vérifier |
| Leviers (diagnostic) | pertinent | — | réglé | — |
| sup-F, CUSUM, Grubbs sur ratios bruts | pertinent | B | réglé | redondants au bord (R-7) |
| Jackknife | pertinent | B | réglé | repère 10 % fragile ; #224 |
| IC bootstrap 90 % (complet, restreint) | à compléter | M | partiel | biais −11 à −14 %, couverture non mesurée |
| LR δ = 0 et δ = 1 | pertinent | — | réglé | — |
| Multi-démarrages | pertinent | — | sans objet | — |

### 4.5 Méthode lognormale : graphiques (bloc 4)

| Graphique | Verdict | Prio | Constat |
|---|---|---|---|
| ajustement, ratio, résidus | pertinent | — | — |
| QQ-plot et enveloppe | pertinent | B | enveloppe marginale sur les régimes de δ̂* |
| QQ-plot à deux échantillons | fragile | B | quatre quantiles par groupe |
| spread-plot et lissage | fragile | M | R-10 |
| profil de δ et repères | pertinent | B | « 90 % » en dur (#190) |
| surface, coupe | pertinent | — | — |
| influence (levier, Cook) | pertinent | B | repère 4/T franchi 48-86 % sous H₀ |
| influence sur σ | pertinent | B | coloration 10 % fragile |
| `plot_boot_sigma` | à compléter | M | R-9 |
| `plot_calibration` | pertinent | — | — |

### 4.6 Merz-Wüthrich : cadre, M1, M2 (bloc 5)

| Élément | Verdict | Prio | #5 | Constat |
|---|---|---|---|---|
| Bootstrap semi-paramétrique | à compléter | M | réglé | H₀ = modèle de Mack complet, à écrire ; B ≥ 4 999 recommandé pour le dossier |
| Pente intra-colonne | à compléter | M | réglé | pilotée à 82 % par deux colonnes (R-11) |
| Ordonnée à l'origine | pertinent | M | réglé | puissance à restituer (R-12) |
| Homogénéité de f_j | pertinent | B | réglé | non spécifique ; lecture du texte à qualifier |
| Courbure | fragile | B | partiel | ECHEC porté par une colonne de 5 points |
| Famille α | à compléter | M | réglé | statut (R-11) |
| Breusch-Pagan sur résidus de Mack | à remplacer | H | ouvert | R-5 |
| Exposant de variance par colonne | à compléter | M | réglé | non informatif à CV faible |
| Variance unitaire des résidus (diagnostic) | pertinent | B | réglé | — |

### 4.7 Merz-Wüthrich : M3 à M6 (bloc 6)

| Élément | Verdict | Prio | #5 | Constat |
|---|---|---|---|---|
| Effets calendaires (Mack) | à compléter | M | aucun | au niveau contre une dérive de 5 %/an ; #276, #275 |
| Kruskal-Wallis entre années de survenance | pertinent | — | renversé | 0,65 contre une ligne atypique |
| Corrélation entre colonnes adjacentes | pertinent | — | réglé | puissance faible, déjà dite |
| Durbin-Watson sur résidus de Mack | fragile | B | partiel | tendance lissée le long des diagonales |
| Test des suites sur résidus de Mack | fragile | B | partiel | variante secondaire |
| Grubbs sur résidus de Mack | à remplacer | H | renversé | R-4 |
| Rosner sur résidus de Mack | à remplacer | H | renversé | R-4 |
| Shapiro-Wilk (M5, diagnostic) | pertinent | — | réglé | — |
| Lilliefors (M5, diagnostic) | pertinent | — | réglé | — |
| Extrapolation de σ²_{J−1} (M6) | à compléter | M | réglé | R-14 |
| Concentration de la réserve (M6) | pertinent | B | réglé | repère 40 % sans source, jamais coloré |

### 4.8 Merz-Wüthrich : graphiques (bloc 6)

| Graphique | Verdict | Prio | Constat |
|---|---|---|---|
| facteurs | à compléter | B | tracer σ̂_j |
| réserve par année | pertinent | — | — |
| résidus contre C, par développement | pertinent | B | nus |
| résidus par survenance | à compléter | B | médiane par ligne |
| résidus par année calendaire | à compléter | M | moyenne par diagonale, n_k |
| QQ-plot des résidus de Mack | à remplacer | M | R-15 |
| petits multiples | pertinent | — | — |
| ordonnées à l'origine | pertinent | — | — |
| famille α | pertinent | — | — |
| levier | pertinent | — | — |
| DFBETAS | pertinent | — | porte le bon test de M4 |
| contributions | pertinent | — | — |
| `plot_boot_sigma` | à compléter | B | R-9 |
| `plot_calibration` | pertinent | — | — |

### 4.9 Décompte

Sur 111 éléments (18 transversaux, 49 tests et diagnostics lognormaux, 10 graphiques lognormaux, 20 tests et diagnostics Merz-Wüthrich, 14 graphiques Merz-Wüthrich) : 58 pertinents, 26 à compléter, 19 fragiles, 8 à remplacer (décompte des tableaux 4.1 à 4.8). Sur les éléments qui portaient un constat de #5, l'essentiel est réglé ; trois verdicts de #5 sont renversés (Kruskal-Wallis, Grubbs et Rosner Merz-Wüthrich).

## 5. Verdicts sur les issues ouvertes

Libellé : état actuel → recommandation de la revue (aucun libellé n'a été modifié). « Technique » : sans enjeu actuariel.

| Issue | Objet | Bloc | Enjeu actuariel | Avis | Prio | Libellé |
|---|---|---|---|---|---|---|
| #4 | Revue d'architecture | 1 | aucun (pistes 1 à 3 faites) | à fermer, ou à requalifier par `architect` sur la seule piste 4 | B | — |
| #5 | Revue actuarielle du 21/09/2026 | 1 à 6 | épuisé | à fermer (`completed`) une fois les issues de suite créées ; restes : #48, #164, #274, R-1, R-13 ; verdicts renversés : Kruskal, Grubbs et Rosner MW | — | — |
| #48 | Test de Bartels et table de puissance | 3 | réel : seul test H4 sans hypothèse de forme opérant à α = 0,05 (puissance 0,22 à ρ = 0,5 contre 0,12 pour les suites) | à reformuler : Bartels seul ; la table de puissance réduite à une consolidation de l'existant | M | → `ready-for-agent` après spécification `actuary` |
| #49 | Renommer `terme_covariance` | 5 | aucun | technique | B | inchangé |
| #158 | Libellé « courbure non strictement positive » | 2 | aucun | fondée ; préférer un troisième état « courbure immesurable » | B | `needs-info` justifié |
| #159 | Borne d'écart des z_t, tolérance d'ex æquo | 2 | faible | à requalifier en documentaire (borne ≈ 1e-4 à π̂ constant ; sans enjeu à π̂ variable) | B | `needs-info` → `ready-for-agent` |
| #164 | Chiffres non tracés de la partie IV | 1 | réel | décisions valeur par valeur : retirer « T = 200 », Grubbs T = 20, D'Agostino 100 %, Anscombe-Glynn 92,5 % ; reformuler les seuils sans chiffre ; renvoyer ou retirer trois cellules du tableau 1 ; y ajouter les chiffres relevés par les blocs 2 et 3 (§ 3.8) | M | `needs-info` → `ready-for-agent` |
| #170 | Puissance de DW par Imhof dans le moteur | 3 | faible | fondée | B | inchangé |
| #174 | Niveau d'ESD à T = 8, versionné | 4 | réel | fondée ; mesure reproduite (0,152 / 0,062), à lier à R-8 | M | inchangé |
| #190 | Niveau des repères du profil de δ en dur | 4 | faible | fondée | B | inchangé |
| #200 | Fonction globale qui détourne le moteur | 1 | intégrité du calcul livré (σ_USP faux sans signal) | fondée, à traiter avant la remise | M | `needs-info` → `ready-for-agent` après avis `architect` |
| #209 | `seuil_levier` → `repere_levier` | 6 | aucun | technique | B | inchangé |
| #210 | Échecs liés à la locale Windows | 1 | aucun | technique | B | inchangé |
| #213 | Avertissement « volumes constants » | 2 | faible | fondée | B | inchangé |
| #218 | R4 : intervalle bootstrap de π̂_b | 2 | réel (classement instable) | à requalifier : traiter avec #230 en reconsidérant R4 (puissance a posteriori, Hoenig et Heisey 2001) plutôt qu'en l'instrumentant | M | `needs-triage` → `needs-info` (décision du mainteneur) |
| #222 | Simplifications d'E1f | 2 | aucun | technique | B | inchangé |
| #224 | Jackknife réajusté hors du domaine de γ | 4 | réel mais rare | fondée ; avis : écarter le réajustement du maximum et le dire dans le `detail` | M | `needs-info` → `ready-for-agent` |
| #227 | Refus dépendant du démarrage retenu | 4 | faible | avis : un démarrage à l'optimum sur une borne sans KKT ⇒ refus (conservateur) | B | `needs-info` (décision du mainteneur) |
| #230 | R4 et pente négative | 2 | réel | fondée ; option (a) : R4 non appliquée si r < 0, ligne en test | M | `needs-triage` → `ready-for-agent` après visa |
| #246 | Double bootstrap Merz-Wüthrich | 6 | faible à réel | fondée ; après #276 | B | inchangé |
| #255 | Progression du flux V3b | 4 | aucun | technique | B | inchangé |
| #268 | Nom de ligne NA du triangle | 5 | aucun | technique | B | inchangé |
| #274 | Remesure V3h du volet B de `puissance_t8.R` | 1 | réel | fondée, à élargir : fréquence des bascules R1 par p_min_mc ; tableau consolidé de puissance depuis #229 ; T2 de `p_conditionnelle_regime_t8.R` | M | inchangé |
| #275 | Restitution par diagonale du test calendaire | 6 | réel | fondée ; ajouter la moyenne par diagonale au graphique | M | `needs-info` → `ready-for-agent` |
| #276 | Forme unilatérale du test calendaire | 6 | réel (puissance environ ×2) | fondée ; spécification Fd approuvée | M | `needs-info` → `ready-for-agent` |
| #284 | `bilan_fichier()` au lieu de `fin_fichier()` | 1 | aucun | technique | B | `needs-triage` → `ready-for-agent` |
| #285 | Afficher la granularité effective | 4 | faible (restitution près de α) | option (i) | B | inchangé |
| #286 | Borne du champ T à l'import | 3 | aucun | technique | B | inchangé |
| #287 | Notification « Calcul non lancé » | 4 | aucun | technique | B | inchangé |
| #288 | README, virgule décimale | 3 | aucun | technique | B | inchangé |
| #289 | Contrôle versionné des niveaux de M1 sous #270 et #273 | 5 | faible | fondée | B | `needs-triage` → `ready-for-agent` |
| #290 | Ensembles figés factorisés | 5 | aucun | technique | B | `needs-triage` → `ready-for-agent` |
| #291 | Résidus recalculés dans `mw_tests()` | 6 | aucun | technique | B | inchangé |
| #292 | Phrase de `nature_p` en constante | 1 | aucun | technique | B | `needs-triage` → `ready-for-agent` |
| #293 | Cache global `.MW_COMBN_CACHE` | 6 | aucun | technique ; option (a) préférable (moteur sans état) | B | inchangé |
| #294 | Point décimal dans les textes du moteur | 1 | aucun | option (a) : laisser et documenter | B | `needs-triage` → `ready-for-human` |
| #295 | Option `usp.graphiques_base` ignorée | 4 | aucun | technique | B | inchangé |

## 6. Issues nouvelles proposées

Créées le 15/10/2026 sur décision du mainteneur, en `needs-triage` : R-n est l'issue #(296 + n), de #297 à #317. Regroupement des propositions des six blocs ; aucune n'est couverte par une issue ouverte ou fermée (vérifié par chaque bloc). Corps détaillés : rapports de bloc, section 6. « Verdicts » : la proposition change au moins un verdict des cas de référence, d'où le visa du mainteneur dans la branche qui la traitera ; aucune ne change σ_USP.

| N° | Titre proposé | Libellés | Source | Prio | Effet sur les résultats |
|---|---|---|---|---|---|
| R-1 (#297) | moteur : p-value ajustée par famille d'hypothèse (minP de Westfall-Young) sur les réplications existantes, en diagnostic | `enhancement` | bloc 1, N1 | H | lignes ajoutées, aucun verdict changé |
| R-2 (#298) | moteur : TOST, ECHEC certain (p_plancher ≥ 0,30) restitué en diagnostic « équivalence non démontrable » | `enhancement` | bloc 2, N1 | H | verdicts (quatre cas à δ̂ = 1) |
| R-3 (#299) | moteur : H2 non testable à faible dispersion des volumes (règle de restitution) ; une ligne H2 à verdict ; Smirnov rattaché à H1 ; Spearman-temps en variante | `enhancement` | bloc 2, N2 ; § 3.3 | H | verdicts |
| R-4 (#300) | moteur : M4, test de cellule aberrante sur les résidus studentisés externes ; Grubbs et Rosner sur résidus de Mack retirés ou portés sur t | `enhancement` | bloc 6, N1 | H | verdicts, régénération de `reserve2` |
| R-5 (#301) | moteur : M2, Breusch-Pagan à effets fixes de colonne | `enhancement` | bloc 5, N1 | H | p de la ligne ; verdict de `reserve2` inchangé |
| R-6 (#302) | moteur : H3 et H4, réduire la redondance (SW à loi nulle simulée, CvM, KS contre N(0,1), LB1, Box-Pierce) et fixer la lecture conjointe de H3 | `enhancement` | bloc 3, B | M | structure de la table |
| R-7 (#303) | moteur : les six lignes « ratios bruts » en diagnostic à π̂ constant ; LB1r retirée | `enhancement` | bloc 3, C ; bloc 4, § 4.6 | M | verdicts OK → INFO (quatre cas) |
| R-8 (#304) | moteur : ESD lognormale, requalifier en diagnostic ou calibrer par Monte-Carlo | `enhancement` | bloc 4, n° 2 | M | verdict de la ligne ; dépend de #174 |
| R-9 (#305) | tests et docs : couverture de l'IC bootstrap à T = 8, biais de la loi bootstrap de σ̂, intervalle « basic » en regard ; repères σ̂ et σ_USP sur `plot_boot_sigma` (deux méthodes) | `enhancement` | bloc 4, n° 4 ; bloc 6, § 3 | M | aucun (mesure, graphique) |
| R-10 (#306) | moteur et app : spread-plot, bande de simulation du lissage ou retrait de la courbe | `enhancement` | bloc 4, n° 3 | M | `plots_data` |
| R-11 (#307) | moteur : pente intra-colonne en paramétrisation relative et statut de la famille α | `enhancement` | bloc 5, N2 | M | verdicts (`reserve2` : OK → ALERTE) |
| R-12 (#308) | moteur : M1 et M2, diagnostic d'identifiabilité intra-colonne (CV de C, se(â_j)) | `enhancement` | bloc 5, N3 (1) et (3) | M | lignes ou `detail` |
| R-13 (#309) | mesure : puissance versionnée des lignes M1 à M4 de Merz-Wüthrich (scénarios constante, exposants 0 et 2, dérive, calendaire, ligne, cellule ; deux plans de CV) | `enhancement` | bloc 5, N3 (2) ; bloc 6, N5 | M | aucun |
| R-14 (#310) | moteur : M6, effet des arguments de l'extrapolation de σ²_{J−1} sur √MSEP ; σ̂_j sur le graphique des facteurs | `enhancement` | bloc 6, N2 ; § 3.6 | M | `detail` ou `estim` |
| R-15 (#311) | moteur et app : QQ-plot des résidus de Mack, droite de référence et enveloppe paramétrique | `enhancement` | bloc 6, N3 | M | `plots_data` |
| R-16 (#312) | docs et app : lecture conjointe de M3, suites en variante secondaire, statistiques par groupe sur les nuages de résidus | `enhancement` | bloc 6, N4 | M | variante d'une ligne |
| R-17 (#313) | tests : puissance de sup-F, OLS-CUSUM et Grubbs à T = 8 (rupture, dérive, contamination) dans `puissance_t8.R` | `enhancement` | bloc 4, n° 1 | M | aucun |
| R-18 (#314) | moteur : constante minimale détectable dans le `detail` de la nullité de la constante | `enhancement` | bloc 2, N3 | B | `detail` |
| R-19 (#315) | docs : transversal (tableaux 1 et 2, « ce que l'on peut affirmer », vitesses non sourcées, seuil 0,30, niveau conditionnel au bord de V3h, H₀ des p Monte-Carlo Merz-Wüthrich) | `documentation` | bloc 1, N2 ; § 3.9 | B | aucun |
| R-20 (#316) | docs : méthode lognormale (H1 à H4, stabilité, robustesse : formulations et puissances mesurées, seuil de Cook, coloration 10 %, Grubbs exact) | `documentation` | bloc 2, N4 ; bloc 3, A ; bloc 4, n° 5 | B | aucun |
| R-21 (#317) | docs : Merz-Wüthrich (M1 à M6 : références Venter 1998 et Mack 1999, interprétation de D(2)(h)(iii), cause du sous-rejet de BP, « le plus informatif », Rosner « tabulées », cause du sur-rejet des suites) | `documentation` | bloc 5, N4 ; bloc 6, C2-C4, C8 | B | aucun |

Libellé de triage commun : `needs-triage`. Chaque corps commence par `> *Rédigé par l'agent actuary (IA).*` et renvoie au présent rapport.

### 6.1 Lignes de la table des tests supprimées ou remplacées si les propositions sont retenues

Sur 51 lignes lognormales et 19 lignes Merz-Wüthrich. Rien n'est supprimé à ce jour : chaque point relève d'une décision du mainteneur dans la branche qui traitera l'issue.

| Ligne | Méthode, famille | Sort proposé | Issue |
|---|---|---|---|
| Box-Pierce (retard 2) | lognormale, H4 | retrait (dominé par Ljung-Box (2)) | #302 |
| Ljung-Box (retard 1) sur ratios bruts | lognormale, H4 | retrait (doublon de Durbin-Watson sur ratios bruts) | #303 |
| Shapiro-Wilk à loi nulle simulée | lognormale, H3 | fusion dans la fiche Shapiro-Wilk (option) | #302 |
| Kolmogorov-Smirnov contre N(0,1) | lognormale, H3 | variante sans verdict ou retrait (option) | #302 |
| Cramér-von Mises | lognormale, H3 | variante sans verdict ou retrait (option) | #302 |
| Ljung-Box (retard 1) | lognormale, H4 | variante sans verdict ou retrait (option) | #302 |
| Stabilité du facteur selon la pondération (famille α) | Merz-Wüthrich, M1 | diagnostic, test omnibus ou retrait (option c) | #307 |
| Cox-Stuart (diagnostic inopérant) | lognormale, H1 | conservé ou retiré, option évoquée par le bloc 2 et portée par aucune issue | — |
| Cellule aberrante (Grubbs) | Merz-Wüthrich, M4 | statistique remplacée par max \|t(i,j)\|, la ligne subsiste | #300 |
| Cellules aberrantes multiples (Rosner) | Merz-Wüthrich, M4 | retrait, ou portée sur t | #300 |
| Hétéroscédasticité résiduelle (Breusch-Pagan) | Merz-Wüthrich, M2 | statistique remplacée (effets fixes de colonne), la ligne subsiste | #301 |

Entre 2 et 8 lignes disparaîtraient (9 avec Cox-Stuart) ; deux statistiques sont remplacées sans suppression de ligne. Restent dans la table, mais perdent leur verdict ou passent en variante : le TOST quand son ECHEC est certain (#298) ; Breusch-Pagan 1979, White, Goldfeld-Quandt, Brown-Forsythe, et Smirnov rattaché à H1 (#299) ; Spearman ratio-temps (#299) et le test des suites Merz-Wüthrich (#312) en variantes secondaires ; les cinq autres lignes sur ratios bruts à π̂ constant (#303) ; ESD lognormale (#304). Côté graphiques, seule la courbe lissée du spread-plot pourrait être retirée, en alternative à une bande de simulation (#306).

## 7. Décisions demandées au mainteneur

*Suites décidées le 15/10/2026* : issues R-1 à R-21 créées (#297 à #317, `needs-triage`) ; avis de la revue publiés en commentaire sur #4, #5, #48, #159, #164, #200, #218, #224, #227, #230, #274, #275 et #276, sans changement de libellé ; #5 fermée (`completed`). Restent ouverts les points 4 à 7.

1. **Issues nouvelles** : créer R-1 à R-21, toutes ou une sélection.
2. **Issues existantes** : publier un commentaire de la revue sur les issues dont l'avis change quelque chose (#4, #5, #48, #159, #164, #200, #218, #224, #227, #230, #274, #275, #276) et appliquer, ou non, les changements de libellé du § 5.
3. **#5** : fermeture (`completed`) avec un commentaire qui liste ses restes et ses verdicts renversés, après la création des issues de suite.
4. **Deux lectures d'une source** : attribution du seuil de Cook (4/n à Bollen et Jackman 1990 selon une source secondaire, 4/(n − k − 1) selon le `.tex`) ; source primaire à fournir ou à trancher.
5. **Sources à fournir** : PDF de Mack 1994 et 1997 (déjà demandé, Q-Fd-9) ; Davison et Hinkley (1997), chap. 6 ; Royston (1993) pour Shapiro-Francia ; orientations EIOPA sur les USP pour le sens de B(2)(g)(iv).
6. **Paramètres du dossier** : B du calcul final (B ≥ 4 999 recommandé par le bloc 5 : trois lignes de `reserve2` sont à moins de deux erreurs Monte-Carlo du seuil) ; valeur et justification de la marge Δ du TOST.
7. **Ordonnancement** : rattacher les issues retenues aux branches suivantes au prochain point d'étape d'`architect`. La revue suggère de traiter d'abord la mesure (R-13, R-17, #274) et les règles de restitution (R-2, R-3, R-7), avant les remplacements de statistiques (R-4, R-5, R-11), dont la lecture dépend de l'identifiabilité.

## 8. Limites de la revue

- Revue de méthode, non d'implémentation : le code n'a été lu que pour trancher une ambiguïté ; ce n'est pas un audit.
- Lecture réglementaire non instruite par `regulatory` : les hypothèses de l'annexe XVII sont prises telles que la documentation les cite (le bloc 5 a relu D(2)(h) dans le texte consolidé, hors formules). Le sens de « l'estimation du maximum de vraisemblance est adéquate » (B(2)(g)(iv)) n'a pas pu être confronté aux orientations EIOPA.
- Mesures des agents : un plan par méthode, petits R pour les sondes (R = 20 à 250 ; R = 60 pour M3-M4), non versionnées dans `tests/` ; ordres de grandeur seulement.
- Références : vérifiées le plus souvent par résumé ou notice ; les rapports de bloc listent les références non vérifiées.

## 9. Annexes

- `20261015-pertinence-tests-graphiques/bloc-1.md` à `bloc-6.md` : rapports intégraux des six consultations.
- `20261015-pertinence-tests-graphiques/mesures/` : scripts de mesure et sorties conservées, avec leur `README.md`.
