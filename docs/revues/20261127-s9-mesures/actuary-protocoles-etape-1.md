# S9, étape 1 : protocoles et critères de lecture des cinq mesures (#421, #420, #367, #379, #494)

> *Rédigé par l'agent actuary (IA), fiche `actuary-approfondi`, le 27/11/2026, sur `claude/mesures-t8` (tête `51d3fbc`, base `main` `cfa35b4`). md5 de `R/engine.R` : `c7b767f5d9116c35a0a9237ffdd2d79a` (vérifié). Aucun fichier écrit, aucune issue, aucun commentaire. Avis versé intégralement par la session principale (Q-54-10) ; décisions du mainteneur dans `synthese.md`.*

Chaque conclusion porte l'un de ces marqueurs :
- **[V]** vérifiée : source citée, ou commande exécutée et sortie relevée ;
- **[H]** hypothèse ;
- **[NV]** non vérifiée.

Les « exécutions exploratoires » citées sont des appels ponctuels du moteur faits pendant cette consultation (`charger_moteur()`, R 4.3.3, session cloud). Elles ne sont pas versionnées et ne remplacent aucune mesure de l'étape 6 : elles ont seulement servi à vérifier des prémisses et la faisabilité.

Elles posent deux réserves sur le principe « aucune exécution avant les protocoles » :
- elles ont produit des valeurs avant que les critères soient fixés, en particulier la puissance à T = 5, α = 0,05 près de la garde (§ 1.5) et la limite ρ → 1 à T = 8 (§ 1.3) ;
- les critères ci-dessous ont été écrits après avoir vu ces valeurs. Le mainteneur peut juger que cela affaiblit la règle de M42 pour #421.

---

## 1. #421 — Durbin-Watson au voisinage de ρ = ±1 hors T = 8, puissance limite

### 1.1 Quantités visées et nature

| Quantité | Nature |
|---|---|
| (a) Puissance `dw_puissance_ar1(T, ρ, α)` sur une grille de ρ jusqu'à la garde, pour les T de l'index | approximation numérique (Imhof, `uniroot()`) d'une quantité exacte |
| (b) Limite L₋(T, α) de cette puissance quand ρ → −1 | **résultat exact** (démonstration en 1.2) ; sa valeur pour un T donné dépend du signe de dw_p_exacte(v_T) − α, évalué par quadrature |
| (c) Limite L₊(T, α) quand ρ → 1 | loi limite exacte (1.3) ; valeur = approximation numérique (Imhof) d'une quantité exacte |
| (d) Vitesse : \|puissance − L\| / (1 − \|ρ\|)^½ | **constat numérique**, non démontré ; seul un argument heuristique le soutient (1.2, remarque) |
| (e) Recoupement par simulation | constat de simulation ; erreur binomiale fonction de N |

### 1.2 Démonstration de la limite ρ → −1 [V, démonstration élémentaire donnée ici, sans référence nécessaire]

Notations :
- v_T = ((−1)^t), t = 1..T ;
- Σ(ρ) = (ρ^|i−j|), et z_ρ = Σ(ρ)^½ e, avec e ~ N(0, I_T) ;
- d_bas et d_haut, les points critiques de la loi nulle, qui ne dépendent pas de ρ.

Étapes :
1. Quand ρ → −1, Σ(ρ) → v v′ terme à terme. La racine carrée est continue sur les matrices symétriques positives, et (v v′)^½ = v v′/√T. Donc, pour tout e, z_ρ → c·v avec c = v′e/√T ~ N(0, 1).
2. `stat_dw()` est invariante d'échelle et continue en tout point où z − z̄ ≠ 0. Or v_T n'est pas constant et c ≠ 0 presque sûrement. Donc DW(z_ρ) → d* = DW(v_T) presque sûrement.
3. Valeur de d* :
   - T pair : v̄ = 0, d'où d* = 4(T − 1)/T ;
   - T impair : Σ(v − v̄)² = T − 1/T, d'où d* = 4T/(T + 1) ;
   - soit 3, 10/3 et 3,5 à T = 4, 5 et 8.
4. Si d* ∉ {d_bas, d_haut}, l'indicatrice de rejet converge presque sûrement, et par convergence dominée la puissance tend vers L₋ = 1{d* ∉ [d_bas, d_haut]} = 1{dw_p_exacte(v_T) < α}. La dernière égalité est l'équivalence du commentaire de `dw_puissance_ar1()` : p < α si et seulement si d est hors de [d_bas, d_haut].
5. Si dw_p_exacte(v_T) = α exactement, la limite n'est pas déterminée par cet argument.

Prémisses relevées [V, exécution exploratoire] :

| T | DW(v_T) | dw_p_exacte(v_T) |
|---|---|---|
| 4 | 3 | 0,2200433 |
| 5 | 3,333333 | 0,05060422 |
| 6 | 3,333333 | 0,03803969 |
| 7 | 3,5 | 0,008615778 |
| 8 | 3,5 | 0,005693521 |
| 9 | 3,6 | 0,001208242 |
| 10 | 3,6 | 0,0007251354 |
| 12 | 3,666667 | 7,97e-05 |

Conséquences :
- L₋ = 0 à T = 4 pour les deux seuils, et à T = 5 pour α = 0,05 ;
- L₋ = 1 à T = 5 pour α = 0,10, et dès T = 6 pour les deux seuils, sur les T relevés ;
- les valeurs de l'issue (0,2200, 0,0506, 0,0057) sont retrouvées.

**Remarque sur la vitesse [H]** : quand |c| est petit devant (1 − |ρ|)^½, l'écart DW − d* est d'ordre (1 − |ρ|)^½/|c|. Cela suggère un écart à la limite en (1 − |ρ|)^½, de constante d'autant plus grande que d* est proche d'un point critique. C'est une heuristique, non une démonstration.

### 1.3 Limite ρ → 1 et sort des valeurs hors garde

**Argument** [V, élémentaire] :
- ρ^k = 1 − k(1 − ρ) + O((1 − ρ)²), donc M Σ(ρ) M = (1 − ρ) M K M + O((1 − ρ)²), avec K_ij = −|i − j| et M le projecteur de centrage ;
- DW est invariante d'échelle, donc DW(z_ρ) converge en loi vers DW(u), u ~ N(0, M K M) ;
- la loi limite est continue : un point a une probabilité nulle ;
- la puissance tend donc vers L₊ = P(DW(u) ∉ [d_bas, d_haut]), calculable par Imhof avec la racine de M K M, **sans franchir la garde**.

Le rang T − 1 de M K M est vérifié numériquement à T = 8 [V, exploratoire]. Pour les autres T, il est à contrôler dans le script : je n'invoque aucun théorème.

**Vérification exploratoire [V]** : L₊(8 ; 0,10) = 0,5899175, soit la valeur que le commentaire du moteur donne comme limite (l. 2949). `dw_puissance_ar1(8, 1 − 1e-10, 0,10)` = 0,5899180. L'écart, 5·10⁻⁷, est un constat de précision numérique à la garde, non un O(1 − ρ).

**Sort des trois valeurs hors garde** (0,5899253 à 1 − 1e-12, 0,5906 à 1 − 1e-13, 0,4755 à 1 − 1e-15) : **ne pas les reproduire**. Elles mesurent la défaillance d'un calcul abandonné (#170), celle qui a motivé la garde, et non une propriété du test. Une copie sans garde n'aurait aucune portée statistique. Le tableau de #421 les cite comme « valeurs historiques de #170, hors du domaine de la fonction actuelle, non reproduites ». La valeur limite 0,5899175 est, elle, versionnée par L₊. Q-78-3 maintient le commentaire du moteur tel quel ; sa reformulation relève de **Q-S9-3** (§ 6).

### 1.4 Plan

1. **Grille Imhof.**
   - ρ ∈ {−1 + 1e-6 ; −0,99999 ; −0,9999 ; −0,999 ; −0,99 ; −0,98 ; −0,95 ; −0,9 ; −0,8 ; −0,7 ; −0,5 ; −0,3 ; 0}, la grille du script de T = 8.
   - T ∈ {4 à 10, 12, 15, 20, 30, 50, 100}. **Recommandation** : les deux seuils pour tous ces T, et non les seuls couples de l'index. Le coût est négligeable [V, exploratoire : 0,11 s par appel à T = 100]. Les couples de l'index sont un sous-ensemble.
   - ρ = 0 sert de contrôle de niveau.
2. **Limites.**
   - Pour chaque (T, α) : L₋, la marge m = dw_p_exacte(v_T) − α, et DW(v_T) comparée à 4(T − 1)/T ou 4T/(T + 1).
   - L₊ par Imhof sous M K M, comparée à `dw_puissance_ar1(T, 1 − 1e-10, α)` et à `dw_puissance_ar1(T, 1 − 1e-6, α)`.
3. **Recoupement par simulation**, indépendant d'Imhof pour l'alternative.
   - ρ ∈ {0 ; −0,9 ; −0,99 ; −0,9999 ; −1 + 1e-6} pour chaque T. **Nouveau par rapport au script de T = 8** : la simulation à la garde est possible, car √(1 − ρ²) ≈ 1,4·10⁻³ reste représentable. C'est le seul contrôle de la quadrature là où le déficit est d'ordre 10⁻³ : erreur-type ≈ 5·10⁻⁵ à T = 8.
   - N = 4·10⁵ par ρ, innovations communes à tous les ρ d'un même T, graine **20261031** sous `engine_sous_graine()` (celle du script existant).
   - Une sous-graine par T est déterministe et documentée ; le flux de T = 8 doit rester celui du 31/10.
   - Tirage par blocs : à T = 100, une matrice 4·10⁵ × 100 occupe environ 320 Mo.
4. **Test unitaire** (CI, sans tirage), pour T ∈ {4, 5, 8} :
   - DW(v_T) égale à sa valeur rationnelle à 1e-12 ;
   - dw_p_exacte(v_T) égale à 0,2200433, 0,0506042 et 0,0056935 à 1e-6 près ;
   - les six limites L₋ ;
   - |m| > 10⁻⁴ dans les six cas (garde-fou contre un cas limite) ;
   - en complément, `dw_puissance_ar1(4, −1 + 1e-6, 0,10)` < 0,01 et `dw_puissance_ar1(8, −1 + 1e-6, 0,10)` > 0,99 [V, exploratoire : 0,00056 et 0,99878] ;
   - **ne pas** inclure T = 5 à α = 0,05 dans ce complément (§ 1.5).
5. **Point 4 de l'issue** (S0 éprouvé à ρ ≠ 0 sur une série tirée indépendamment de `ar1_mat`, S1 sans recalcul, mise en commun selon Q-78-4) : j'y souscris sans réserve. La forme relève de `coder`.

### 1.5 Erreurs, critère de lecture, portée

**Erreurs** :
- l'erreur de quadrature est vérifiée, non bornée ;
- l'erreur de simulation est binomiale : ET = √(p(1 − p)/N), avec p la valeur d'Imhof ;
- il n'y a ni B ni R au sens des campagnes.

**Critère, écrit d'avance** :
- **K421-1 (limite)** :
  - « décidée » si |m| ≥ 10⁻⁶, sinon « indécidable à la précision de la quadrature », valeur rapportée ;
  - le `.tex` remplace « hypothèse non vérifiée » si L₋(4 ; 0,10) = 0 et L₋(5 ; 0,05) = 0 ;
  - toute autre issue déclenche **PM-3**.
- **K421-2 (précision)** :
  - simulé − Imhof est signalé au-delà de 3 ET ;
  - il y a désaccord au-delà de 4 ET, ou si plus de 2 comparaisons sur environ 170 sont signalées. À 3 ET, environ 0,5 fausse alerte est attendue sous indépendance, et les comparaisons sont corrélées par les innovations communes ;
  - un désaccord sur un T ou un ρ cité par le `.tex` déclenche PM-3.
- **K421-3 (vitesse, constat)** :
  - |puissance − L₋| / (1 − |ρ|)^½ entre 1 − |ρ| = 10⁻⁴ et 10⁻⁶ : stable si l'écart relatif est ≤ 10⁻³ ;
  - sinon « régime asymptotique non atteint dans le domaine gardé », ce qui n'est **pas** un échec.
  - **Prévu pour T = 5, α = 0,05** [V, exploratoire] : puissance 0,345 à −0,99, 0,384 à −0,9999, 0,106 à la garde. Elle n'est pas monotone et reste loin de 0 à la garde, ce qu'explique la marge faible (6·10⁻⁴). Le `.tex` (l. 1340) dit « tend vers 0 » : c'est exact comme limite. La phrase devra dire que la convergence n'est pas atteinte à la garde dans ce cas.
- **K421-4 (ρ → 1)** :
  - |dw_puissance_ar1(T, 1 − 1e-10, α) − L₊| signalé au-delà de 10⁻⁵, désaccord au-delà de 10⁻⁴ ;
  - le rang T − 1 de M K M est un contrôle bloquant.
- **K421-5 (non-régression)** : lignes de T = 8 identiques au tableau du 31/10 au chiffre imprimé. Des lignes peuvent être ajoutées, marquées comme telles.

**Ce que la mesure ne dit pas à T = 8** :
- elle porte sur l'outil de mesure `dw_puissance_ar1()` (z i.i.d. N(0, 1) sous H0, AR(1) stationnaire, sans réajustement) ;
- elle ne porte ni sur les z_t réajustés du moteur, ni sur la p retenue de la ligne DW ;
- ρ → ±1 est une alternative extrême, hors du plausible actuariel : elle borne le domaine numérique de l'outil, non la puissance utile du test ;
- la loi en (1 − |ρ|)^½ reste un constat.

**Durée [H]** : moins de 30 min. Le pré-vol fait foi.

---

## 2. #420 — Corrélation de W² et A² sous le modèle ajusté

**Point 1 déjà fait [V]** :
- `tests/unitaires/test_mk_spearman.R` vérifie 0,981980506061966 par énumération ;
- le `.tex` cite le résultat exact (l. 11380-11383).

Il ne reste que le point 2. Par ailleurs, l'adjectif « très corrélée » visé par le commentaire du 09/11 n'est plus dans `R/engine.R` [V, `grep` vide]. Seule reste la phrase du `.tex` (l. 12493-12501).

### 2.1 Quantité et nature

La quantité est la dépendance entre W² (`stat_cvm`) et A² (`stat_ad`) calculées sur les z* réajustés, **sous la loi qui définit leurs p de Monte-Carlo** :
- J1 = cas `premium` (δ̂ = 1, variante V1) ;
- J2 = cas `premium_interieur` (δ̂ = 0,664, V3b, loi conditionnelle au régime intérieur) ;
- le rapprochement J1/J2 avec ces cas est vérifié sur δ̂ et σ_USP de `docs/tableaux/20261026-issue297-calibration-famille-ln.md` [V].

Nature : approximation Monte-Carlo d'une fonctionnelle de la loi bootstrap, **conditionnelle à θ̂**. C'est un constat de simulation sur deux jeux.

### 2.2 Voie retenue : `stats_boot` [V, lecture de `usp_bootstrap()`]

`stats_boot` contient exactement les réplications passées à `.mc_p_values()`, y compris le flux V3b. Une simulation séparée reproduirait le même générateur (`usp_simuler()` puis `usp_ajuster_rapide()`) sans rien apporter.

Plan :
- `run_engine()` par le cas de `CAS`, **B = 9 999**, graine du dossier **20260831** (flux V3b : 20 800 000), dans les plages existantes ;
- colonnes `CvM` et `AD` de `bootstrap$stats_boot`, lignes non finies écartées et comptées.

Grandeurs :
1. ρ de **Spearman**, en grandeur principale : les décisions p_mc ne dépendent que des rangs ;
2. r de **Pearson**, en grandeur secondaire, sensible à la queue de A² ;
3. **concordance des rejets sous H0**, la grandeur la plus proche de « deux fois la même information » :
   - p de chaque réplication par rang « laisser-un-de-côté » parmi les B − 1 autres, sous échangeabilité ;
   - P(rejet CvM | rejet AD) et P(rejet AD | rejet CvM) à α = 0,10 et 0,05 ;
   - repères : 1 si dépendance parfaite, α si indépendance.

Contrôles :
- p_mc recalculées depuis `stats_boot` égales aux p_mc rendues par `engine_p_mc()` ;
- valeurs observées W² et A² rapportées.

### 2.3 Erreurs

- **Erreur Monte-Carlo** (fonction de B) : jackknife par groupes, G = 20 groupes consécutifs. Il est déterministe et ne demande aucune graine nouvelle ; les réplications retenues sont i.i.d. conditionnellement aux données, y compris sous V3b (acceptation-rejet).
- **Erreur d'échantillonnage en R** : sans objet, car il n'y a pas de jeux répétés. La variation avec θ̂ n'est pas une erreur mais une conditionnalité, documentée par deux jeux seulement.

### 2.4 Critère de lecture (conventions déclarées, sans fondement théorique)

- **Quasi-redondance sous H0 établie** si, sur J1 **et** J2 :
  - ρ_S − 2 ET ≥ 0,90 ;
  - et P(rejet CvM | rejet AD) − 2 ET ≥ 0,75 à α = 0,10.
  - La phrase « presque deux fois la même information » est alors gardée, chiffrée.
- **Dépendance forte, non quasi redondante**, si 0,70 ≤ ρ_S < 0,90 sur un jeu au moins. La phrase est à nuancer : **PM-3**.
- **Contredite** si ρ_S < 0,70 sur un jeu : PM-3.

### 2.5 Portée et durée

La mesure ne dit rien du comportement **sous alternatives**, là où la pondération des queues de A² les distingue. Elle ne dit pas qu'un seul verdict suffit en puissance. Elle reste conditionnelle à J1 et J2, à T = 8.

**Durée [H]** : J1 environ 3 min. J2 environ 4 à 5 min, par extrapolation de `premium_interieur` à 4 999 (121,8 s, tableau de #325, [V]). Moins de 10 min au total.

---

## 3. #367 — Grubbs sur `premium_interieur`

### 3.1 Prémisse : aucun choix du mainteneur n'est requis

Les deux lectures sont exactes [V, `docs/tableaux/20261022-issue325-b-dossier.md` l. 344 et 363] :
- B = 999 (dossier, `.tex` l. 8024-8025) : p = 0,1050 ± 0,0097, OK, mention #244 ;
- B = 4 999 (#325) : p = 0,0926 ± 0,0041, **ALERTE**, mention #244 ;
- le verdict bascule déjà entre 999 et 4 999 sur la même graine.

La quantité visée ne dépend pas de la prémisse : c'est **p_∞**, la p bootstrap à B infini sur ces données, sous le modèle ajusté et conditionnelle au régime intérieur. C'est une quantité exacte, définie par les données, que la mesure approche par Monte-Carlo. Les deux runs existants sont rapportés comme contexte.

### 3.2 Plan

- Option de `tests/mesure_b_dossier_t8.R`, sortie par défaut inchangée ;
- `premium_interieur` à **B = 9 999** :
  - graine du dossier 20260831 : prolonge le tirage principal ; le flux V3b n'est pas strictement emboîté ;
  - **plus 4 graines secondaires indépendantes**, soit N_tot ≈ 50 000 tirages retenus ;
- les graines secondaires et leurs graines de flux (graine + 539 169) sont prises dans une plage nouvelle déclarée et contrôlée contre les littéraux du dépôt. Indication : 36 100 001-36 100 004 [H : libre, à établir par le contrôle de collision de `coder` ; je n'ai pas lu les plages de #305, #387, #567 et #610].

### 3.3 Erreurs

- L'erreur est **purement Monte-Carlo** et, ici, binomiale : K_tot = #{G* ≥ g_obs} sur N_tot tirages i.i.d.
- Intervalle de Clopper–Pearson à 99 % sur K_tot/N_tot.
- Il n'y a pas de R : un seul jeu.

### 3.4 Critère de lecture

Sur l'intervalle de Clopper–Pearson à 99 % de p_∞ :
- ⊂ ]0 ; 0,10[ : verdict à B infini **ALERTE**. Le OK du dossier à B = 999 est un effet de l'erreur Monte-Carlo sur cette ligne ; la phrase #244 du `.tex` est justifiée et se chiffre. Ce n'est pas PM-3, car aucune phrase n'est contredite, mais la session le **signale au mainteneur**, en lien avec Q-Ff-5 (B du dossier). C'est une décision hors S9.
- ⊂ ]0,10 ; 1[ : OK confirmé.
- ∋ 0,10 : indécidable à N_tot près (ET ≈ 0,0013).

Le verdict et la mention #244 de chaque graine à 9 999 sont rapportés.

**Pronostic [H]** : p_∞ ≈ 0,09 à 0,095, d'après le run à 4 999.

### 3.5 Portée et durée

La mesure réduit l'erreur Monte-Carlo, non l'erreur de l'approximation bootstrap (plug-in θ̂, T = 8). Elle ne dit pas si Grubbs est juste à T = 8, ni si B = 999 suffit ailleurs.

**Durée [H]** : environ 245 s par run, par extrapolation linéaire de 24,4 s → 121,8 s ; 5 runs, environ 20 min en un processus.

---

## 4. #494 — Puissance de CorrDev (M3) contre une persistance AR(1) dans l'année d'accident

### 4.1 Quantité et nature

Taux de rejet à α = 0,10 et 0,05 de la ligne « Corrélation entre années de développement » :
- `mw_stat_correlation_dev()`, Spearman pondéré des facteurs adjacents, sens « deux » [V, lecture du code] ;
- procédure du dossier : `mw_bootstrap()` à **B = 999**.

C'est un **constat de simulation sous plan**.

### 4.2 Scénario

Dans `gen_triangle_h0()` (tirage colonne par colonne [V]) :
- ε_{i,0} = η_{i,0}, puis ε_{i,j} = ρ ε_{i,j−1} + √(1 − ρ²) η_{i,j} ;
- variance marginale unité ;
- même ordre de consommation de l'aléa ;
- à ρ = 0, les triangles sont identiques au bit près à ceux de H0 (contrôle `identical()`, critère de l'étape 5).

### 4.3 Plan recommandé (Q-S9-2)

- **Graines** : nombres aléatoires communs. Les cellules AR(ρ) d'un plan reprennent les graines de triangle et de bootstrap de la cellule H0 de ce plan dans `puissance_mw_t8.R` [V : P1.H0 rang 1, P2.H0 rang 14]. Aucune graine nouvelle ; comparaisons appariées.
- **Niveau 1, obligatoire** :
  - P1.H0, la cellule ρ = 0 de niveau, R = 500 (b = 1..500). Elle sert aussi de H0 à #379 : le niveau doit être mesuré sur le moteur courant (md5 différent de celui de #309) ;
  - P1.AR(0,3) et P1.AR(0,5), R = 500 chacune.
- **Niveau 2, dans l'enveloppe si le pré-vol le permet** : P2.H0 et P2.AR(0,5), R = 500. La cellule de niveau de P2 est indispensable : en #309, CorrDev y était en **écart mineur libéral**, 0,119 [0,0996 ; 0,1407] à 0,10 [V].
- **Non retenus** : P2.AR(0,3) et tout P3. P3 sépare volume et année pour l'hétéroscédasticité ; son apport pour CorrDev est secondaire [H]. Le `.tex` dira « non mesuré sous P3 ».
- **Relevé** : toutes les lignes du catalogue sont relevées. La lecture porte sur CorrDev, DW sur résidus de Mack (le `detail` de CorrDev renvoie à DW), p de la famille M3 et p globale (pour #379).

### 4.4 Erreurs

- **Échantillonnage** : Clopper–Pearson à 95 % sur R ; demi-largeur ≤ 0,045 à R = 500.
- **Monte-Carlo** : l'erreur liée à B = 999 fait partie de la procédure mesurée. Elle n'entre pas dans l'intervalle. La puissance à B infini n'est pas mesurée.

### 4.5 Critère (seuils 0,5 : convention déclarée)

Pour chaque cellule AR :
- **non distinguée du niveau** : McNemar exact apparié contre ρ = 0, p ≥ 0,05 ;
- **faible** : distinguée, borne haute de l'intervalle < 0,5 ;
- **intermédiaire** : ni faible ni substantielle ;
- **substantielle** : borne basse ≥ 0,5.

Le `.tex` remplace « puissance non étudiée » (l. 10528, fiche `mw:m3cor`) par les taux, leurs intervalles, le plan et la nature.

**PM-3** dans deux cas :
- le taux de CorrDev à ρ = 0 sur le moteur courant tombe en distorsion matérielle (classes de #206/#309) ;
- il diffère du taux de #309 (P1.H0 : 0,087) au-delà d'un test exact de Fisher à 0,05.

Je ne retiens aucun pronostic chiffré de puissance.

### 4.6 Portée

- Un seul DGP : Mack gaussien ajusté à `reserve2`, géométrie 8 × 8, première colonne fixée.
- Une seule forme de dépendance : AR(1) sur les erreurs standardisées.
- Aucune transposition à d'autres triangles.
- Le lien à D(2)(h)(ii) est repris de l'issue [NV ici].

---

## 5. #379 — Puissance des p de famille et de la p globale

### 5.1 Quantité et nature

Pour chaque famille f et pour la p globale :
- π_f(s) = P(p_f < α) sous le scénario s, telle que la rend la ligne du moteur (`engine_p_famille()`). La **composition se fixe à chaque réplication** : les membres sont déterminés sur la réplication, règle R1 comprise [V, lecture du code] ;
- U_f(s) = P(au moins un membre de p_mc < α), **mêmes membres, mêmes réplications**.

C'est un constat de simulation sous plan.

**Conséquence de méthode [V, lecture du code]** : la p de famille exige les lignes de `usp_tests()`/`mw_tests()` sur chaque réplication. La chaîne réduite à douze statistiques du volet B de `puissance_t8.R` ne suffit pas.
- Coût : environ 11,5 s par réplication en `run_engine()` complet (#297, [V]), contre 2,4 à 3,8 s pour la chaîne réduite (en-tête du script, [V]).
- Contrôle utile : les p_mc des douze lignes doivent égaler celles de la chaîne réduite hors écarts d'exclusion, car les graines de bootstrap sont les mêmes.

### 5.2 Contrôle déterministe

**p_f < α ⇒ U_f = 1** sur toute réplication, hors texte T-3a. En effet, p_f ≥ m_obs : les lignes où m ≤ m_obs comprennent au moins num_{j*} lignes [V, raisonnement sur `.engine_minp_rangs()`]. Une violation déclenche une alerte d'intégrité.

### 5.3 Pourquoi comparer à U_f est délicat

U_f n'est pas un test de niveau α. Sous H0, U_f vaut :
- 0,17 à 0,25 par famille lognormale et 0,55 à 0,61 en global (J1, J2) ;
- 0,07 à 0,32 par famille Merz-Wüthrich et 0,62 à 0,64 en global ;
- source : #297, T-F3 [V].

La p minP est la forme calibrée en niveau de U_f. La comparaison mesure donc le **prix en puissance du contrôle de l'erreur**. Elle ne dit pas qu'un des deux « est meilleur ». Elle se lit en excès sur le niveau : π_f(s) − π_f(H0) contre U_f(s) − U_f(H0).

### 5.4 Plan recommandé (Q-S9-1)

Il s'inscrit dans l'enveloppe de 10 h avec #494, sans graine hors des plages déclarées.

**Lognormal** : volet B de `puissance_t8.R`, J1 et J2 ; matrice e sous 20260930, bootstrap sous 20260831 + 1 000 b [V] ; R = 300 (b = 1..300).

| Cellule | Famille visée | Niveau |
|---|---|---|
| N | contrôle (H0) | 1 |
| A(0,5) | E. (H4) | 1 |
| T(2) | B. (H1) | 1 |
| R(4,2) | F. (stabilité) | 2 |

A(0,9) n'est pas retenu.

**Merz-Wüthrich** : campagne unique avec #494, P1, graines de #309 [V].

| Cellule | Famille visée | R |
|---|---|---|
| P1.H0 | contrôle (H0) | 500 |
| P1.AR(0,3) et P1.AR(0,5) | M3 (cellules de #494) | 500 chacune |
| P1.CST20 | M1 | 300 |
| P1.DCAL | M3 (calendaire) | 300 |

**Familles non couvertes**, à dire au `.tex` :
- D. (H3, normalité) : aucun scénario non normal au volet B ;
- M2 : puissance quasi nulle attendue sous P1 contre EXP selon la spécification de Fi ; il faudrait P2.EXP2, hors enveloppe ;
- C. et M4 : un seul membre, pas de ligne.

### 5.5 Erreurs

Clopper–Pearson à 95 % sur R : demi-largeur ≤ 0,057 à R = 300. L'erreur liée à B = 999 fait partie de la procédure (comme en 4.4).

### 5.6 Critère

Pour chaque (famille, scénario, α), contre la cellule H0 de la même campagne (test exact de Fisher pour le lognormal à e communs, McNemar pour les cellules Merz-Wüthrich à nombres communs) :
- mêmes classes qu'en 4.5 : non distinguée / faible / intermédiaire / substantielle (seuils 0,5 : convention) ;
- U_f, l'excès sur le niveau et P(U_f = 1, p_f ≥ α) rapportés à titre descriptif.

Le `.tex` remplace « puissance non mesurée » (l. 8288-8292, 8799, 19622, 19698, 22440-22444) par les taux mesurés pour les familles et scénarios couverts. La phrase « une p élevée n'atteste pas l'adéquation » est **gardée** et chiffrée là où π_f < 0,5.

**PM-3** dans deux cas :
- π_f(s) significativement **inférieur** à π_f(H0) (Fisher ou McNemar unilatéral à 0,05) : test biaisé contre le scénario visé ;
- un niveau sous H0 du moteur courant qui diffère de #297 au-delà d'un test exact de Fisher à 0,05 corrigé de Bonferroni sur le nombre de comparaisons. Le `.tex` cite #297.

### 5.7 Portée

Les mesures valent sous ces plans et alternatives seulement. Les p de famille restent plug-in et non exactes. La mesure ne transpose rien à d'autres jeux ou géométries, ni à des alternatives mixtes.

---

## 6. Enveloppe de calcul et questions au mainteneur (PM-1)

### 6.1 Durées [H : à remplacer par le pré-vol]

Hypothèses de coût par unité :
- Merz-Wüthrich P1 : environ 25 s par triangle, DCAL environ 37 s ;
- Merz-Wüthrich P2 : environ 42 s ;
- source : #309, T8, catalogue avec candidats, [V] pour ces valeurs ; le moteur a changé depuis ;
- lognormal : 12 à 19 s par réplication.

| Bloc | Cellules × R | CPU | Horloge (4 processus) |
|---|---|---|---|
| Merz-Wüthrich P1, niveau 1 (#494 et #379) | H0, AR 0,3, AR 0,5 × 500 ; CST20, DCAL × 300 | environ 15,6 h | environ 3,9 h |
| Merz-Wüthrich P2, niveau 2 (#494) | H0, AR 0,5 × 500 | environ 11,7 h | environ 2,9 h |
| Lognormal (#379) | 2 jeux × 4 points × 300 | 8 à 12,7 h | 2,0 à 3,2 h |
| **Total** | | 35 à 40 h | **8,8 à 10,0 h** |

**Écart avec l'architecte** : son estimation de #494 (environ 4 h pour six cellules à 19 s) sous-estime le coût par triangle constaté en #309 (21 à 42 s). Le plan complet P1 à P3 × 2 ρ, plus trois cellules de niveau, atteindrait à lui seul environ 9 à 10 h d'horloge.

**Ordre de retrait si le pré-vol dépasse 10 h** :
1. P2 (−2,9 h) ;
2. puis R(4,2) lognormal ;
3. puis CST20 et DCAL ramenés à R = 200.

Les questions ci-dessous ne bloquent pas l'étape 5 (capacité des scripts). Elles fixent le périmètre d'exécution de l'étape 6.

### 6.2 Questions

**Q-S9-1 — #379, sous-ensemble des scénarios.** *Recommandation* (a).
- (a) Le sous-ensemble de 5.4 (lognormal N, A(0,5), T(2), R(4,2) sur J1 et J2 à R = 300 ; Merz-Wüthrich P1 H0, AR(0,3), AR(0,5), CST20, DCAL), avec D., M2, C. et M4 déclarés non mesurés.
- (b) Tous les points du volet B à R = 500 et davantage de cellules P1 (EXP2, DFI, LIG, CEL4) : au-delà de l'enveloppe.
- (c) Une seule méthode, lognormale ou Merz-Wüthrich.
- (d) Sortie de #379 du plan.

**Q-S9-2 — #494, plans et cellule de niveau.** *Recommandation* (a).
- (a) P1 à ρ ∈ {0,3 ; 0,5} plus P1.H0, puis P2 (H0 et ρ = 0,5) si le pré-vol le permet, P3 non mesuré ; cellules de niveau mesurées, en nombres communs.
- (b) Le plan de l'issue, P1 à P3 × 2 ρ, avec trois cellules de niveau : environ 10 h à lui seul, ce qui évince #379.
- (c) P1 seul.

**Q-S9-3 — #421, commentaire de `dw_puissance_ar1()` (l. 2948-2952 et 2982-2993).**
- *Constat* : après S9, ce commentaire citera encore une « mesure non versionnée » et une « hypothèse non vérifiée » que S9 aura soldées. Les trois valeurs hors garde y resteront sans mesure.
- *Recommandation* (a) : rattacher sa reformulation à **S10**, avec le renvoi de la l. 3805. Elle renverra au tableau de #421 et qualifiera les trois valeurs d'historiques. #421 se ferme avec S9 pour sa part mesure et `.tex`.
- (b) Laisser le commentaire tel quel sans échéance.

**#367 et #420** : aucun choix du mainteneur n'est requis (3.1 et 2.2).

---

## Retour

- **Statut** : `revue requise`. Les cinq protocoles sont complets. Trois choix de périmètre reviennent au mainteneur (Q-S9-1, Q-S9-2, Q-S9-3) ; les durées des campagnes restent des hypothèses jusqu'au pré-vol.
- **Résultat** :
  - #421 : protocole fixé. Limite ρ → −1 démontrée, limite ρ → 1 caractérisée, valeurs hors garde non reproduites. Recoupement par simulation étendu jusqu'à la garde.
  - #420 : voie `stats_boot` à B = 9 999 ; Spearman en grandeur principale, Pearson et concordance des rejets.
  - #367 : la prémisse n'a pas à être tranchée ; la mesure vise p_∞ (graine du dossier plus 4 graines, B = 9 999).
  - #494 et #379 : une campagne Merz-Wüthrich unique en nombres communs, et une campagne lognormale sur le volet B. Critères en classes, avec McNemar ou Fisher contre une cellule H0 de la même campagne.
- **Preuves** :
  - *Vérifiées* :
    - lectures du code (`dw_puissance_ar1()`, `stat_dw()`, `usp_bootstrap()`, `engine_p_famille()`, `mw_stat_correlation_dev()`, `gen_triangle_h0()`, graines et cellules de `puissance_mw_t8.R` et `puissance_t8.R`) ;
    - tableaux de #164, #309, #297 et #325 ;
    - `test_mk_spearman.R` et le `.tex` l. 11380 ;
    - exécutions exploratoires : dw_p_exacte(v_T), coût par appel, L₊(8 ; 0,10) = 0,5899175, puissances près de −1 à T = 4, 5, 6 et 8 ;
    - démonstrations 1.2 et 1.3, élémentaires ;
    - implication p_f < α ⇒ U_f = 1.
  - *Hypothèses* : durées des campagnes ; pronostic de p_∞ ; vitesse en (1 − |ρ|)^½ ; plage libre des graines secondaires ; faible apport de P3 pour CorrDev.
  - *Non vérifiés* : le lien de CorrDev à D(2)(h)(ii) ; les plages de graines de #305, #387, #567 et #610 ; le rang de M K M pour T ≠ 8.
- **Informations manquantes** : pré-vol des campagnes sur le moteur courant ; plages de graines des scripts postérieurs à #309.
- **Décisions non résolues** : Q-S9-1, Q-S9-2 et Q-S9-3, pour le mainteneur. Au § 3.4, si p_∞ < 0,10 est établi, ce qui en découle pour Q-Ff-5 revient au mainteneur, hors S9.
- **Critères déclenchés** (§ 4) :
  - désaccord avec le plan de l'architecte : durée de #494, et réduction du périmètre P1 à P3 de l'issue ;
  - un changement de verdict possible à B infini sur `premium_interieur` (#367), sans changement du verdict du dossier ;
  - aucune question de validité à T = 8 que la mesure ne trancherait pas ;
  - une réserve de méthode : les exécutions exploratoires faites avant que les critères soient fixés (encadré de tête).
- **Constats hors périmètre** :
  1. **Graines communes à deux études** : les graines de flux V3b de J2 au volet B lognormal (20 260 831 + 1 000 b + 539 169 = 20 800 000 + 1 000 b) tombent dans les plages de #206. Par exemple, b = 41 donne 20 841 000, graine de triangle « N », b′ = 1 000 [V, arithmétique sur les formules lues]. L'effet est sans conséquence statistique, car ces objets ne sont jamais combinés ; le contrôle de collision devrait inclure les graines de flux. Critère ADR 0018 : **aucun** (mineur).
  2. Le commentaire du moteur sur `dw_puissance_ar1()` deviendra périmé après S9 : déjà couvert par Q-78-3, voir Q-S9-3. Critère : aucun (il s'agit d'un commentaire, non de la documentation).
  3. **Dans le périmètre** de #421, non hors périmètre : à T = 5, α = 0,05, la puissance n'est ni monotone ni proche de sa limite à la garde. C'est à porter à la phrase de la l. 1340 du `.tex`.
- **Prochaine action recommandée** : la session soumet Q-S9-1 à Q-S9-3 au mainteneur. Pendant ce temps, l'étape 5 (capacité des deux scripts de puissance, scénario AR(1) avec contrôle `identical()` à ρ = 0, relevé des p de famille sur la ligne du moteur) peut commencer. Le pré-vol de l'étape 6 tranchera l'inclusion de P2.

Fichiers relus : `docs/feuille-de-route.md` (l. 4911-4996), `R/engine.R` (l. 2860-3016, 4407-4420, 5617-5926, 14848-14875, 17235-17262), `tests/mesure_dw_rho_negatif_t8.R`, `tests/puissance_mw_t8.R`, `tests/puissance_t8.R`, `tests/calibration_mc_t8.R`, `docs/tableaux/20261031-issue164-dw-rho-negatif.md`, `docs/tableaux/20261021-issue309-puissance-mw.md`, `docs/tableaux/20261026-issue297-calibration-famille-ln.md`, `docs/tableaux/20261026-issue297-calibration-famille-mw.md`, `docs/tableaux/20261022-issue325-b-dossier.md`, `docs/latex/doc_tests_usp.tex` (l. 1322-1344, 8018-8028, 8284-8294, 8796-8801, 10524-10530, 12485-12505, 19618-19625, 19694-19700, 22436-22446).
