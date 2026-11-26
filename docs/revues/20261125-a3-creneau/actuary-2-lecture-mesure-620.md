# A3, étape 5 : lecture de la mesure de #620 (`actuary-approfondi`, 26/11/2026)

*Rédigé par l'agent `actuary-approfondi` (IA). Rien n'a été écrit dans le dépôt par l'agent ; versé tel quel par la session principale.*

**En bref.** Je recommande la piste **(b)**. La mesure est valide (R0 vert), et (b) passe ses quatre contrôles d'admissibilité, Gb1 à Gb4. La règle (b) > (a) > (c), approuvée à PA-1, s'applique donc. Rien dans la sortie ne justifie de s'en écarter.

**Critère 4 : effet presque nul.**
- La p de famille M1 ne change ni sur T1 ni sur T2, avec les deux graines.
- La p globale change d'un seul compte sur T2 (0,022 → 0,023), avec la graine principale seulement. C'est bien en dessous de l'erreur de Monte-Carlo de cette p (environ 0,0046).

**Ce que (b) change.**
- La p d'Alpha : T1 0,008 → 0,007 ; T2 0,023 → 0,010.
- σ_boot et l'intervalle bootstrap, de 0,25 % relatif au plus.
- Les textes du cas « degenere ».
- σ_USP ne change pas, et aucun verdict ne change au seuil 0,10.

**État consulté.** Branche `claude/creneau-a3`, tête `2d0d351`. Sortie produite sur `e4d79fb` ; md5 de `R/engine.R` : `723277dd…`, I3 vert au début et à la fin.

**Lu :**
- la spécification (`actuary-1-specification-620.md`) ;
- `mesure_620.R`, l. 1-694 lues, la suite non relue ;
- `sortie_mesure_620.txt` en entier ;
- la fiche A3 de `docs/feuille-de-route.md` (l. 4638-4724) ;
- `mw:m1d` (l. 17212-17376) et `sec:boot-mw` (l. 6535-6600) ;
- les passages du `.tex` qui parlent de la colonne J−1 dégénérée (l. 1795-1803, 1874-1878, 15795-15802, 16158-16166, 19200-19222) ;
- dans `R/engine.R` : l. 13855-13940, `add()` l. 5477-5486, `engine_p_famille()` l. 5690-5700, l'intervalle bootstrap l. 17957-17959 ;
- l'ADR 0005 (annotation du 25/11, point 1) ;
- l'ADR 0018 (critères E1 à E6) ;
- `tests/controle_doc_nd.R` (méthode de décompte, l. 449).

**Exécuté** : le décompte des caractères de `mw:m1d` en Python, par la méthode du contrôleur (somme de nchar + 1 par ligne). Il redonne **12 799** pour l'état actuel.

**Légende** : [V] vérifié dans la sortie ou le code cité ; [H] hypothèse ; [NV] non vérifié. Nature de chaque conclusion : **exacte**, **approximation numérique**, **constat de simulation** (CS).

---

## 1. Piste recommandée : (b)

**R0 est vert** [V] (sortie l. 1443-1452) :
- I1 à I9 sont tous OK ;
- I5 : les références `reserve2` et `reserve2_trapeze` sont conformes, avec 0 écart.

**(b) est admissible** [V] (l. 1457-1460) :
- **Gb1** : p_Alpha(Vb) = p_sans sur T0, T1 et T2 (0,016 ; 0,007 ; 0,010), sans aucune réplication discordante.
- **Gb2** : les douze autres p, leurs verdicts et leurs colonnes de `stats_boot` sont `identical()` sur T0 à T3.
- **Gb3** : σ_USP est `identical()` sur les huit triangles. `res` est `identical()` pour R2, R2T, K1 et KA.
- **Gb4** : la colonne J−1 est dégénérée dans 999 réplications sur 999 pour T1, T2 et T3.

**(a) est aussi admissible** [V] (Ga1 à Ga4 OK, l. 1461-1464). Elle ne vient qu'en second dans l'ordre, ce qui n'enlève rien à sa validité.

Les motifs de doctrine de l'ordre (b) puis (a) sont ceux de la spécification, § 2. La mesure les confirme sans les trancher :
- (b) corrige la loi de simulation, qui était incohérente avec la colonne observée ;
- elle supprime l'exception héritée de V2 ;
- elle supprime la tension C5 de `sec:boot-mw` ;
- elle rend vraie la prémisse « reste dégénérée » de `mw:m1d` ;
- le commentaire C2 de `R/engine.R` (l. 14142) devient vrai sans retouche.

**Nature des résultats :**
- **Exacte.** Sous V0, p_moteur ≥ p_sans, parce que les amplitudes sont positives ou nulles. Sous (a), Δp = 0 par construction.
- **Approximation numérique**, bornée. Sous (b), la colonne simulée garde une amplitude de l'ordre de la tolérance (10⁻¹² en relatif) multipliée par max|e|, alors que A vaut environ 10⁻³. Un rang ne peut donc changer que pour une réplication située à cette distance relative de A_obs. Aucune n'a été observée (CS, 0 discordance sur T0 à T2).
- Sur les entrées mesurées, (a) et (b) donnent la même p d'Alpha, la même p de famille M1 et la même p globale [V, H3 ci-dessous].

## 2. Critère 4 chiffré (T1 et T2, avant et après)

| | T1 avant (V0) | T1 après (a) = (b) | T2 avant (V0) | T2 après (a) = (b) |
|---|---|---|---|---|
| p de famille M1 | 0,015 | 0,015 | 0,019 | 0,019 |
| p globale LC | 0,027 | 0,027 | 0,022 | **0,023** |
| Membre qui atteint le minimum (M1 / LC) | PenteIntra / Calendrier | idem | PenteIntra / Calendrier | idem |

Avec la graine secondaire 20261125 (M-h, l. 1493-1498), tout est inchangé :
- T1 : M1 0,010 et LC 0,021 avant comme après ;
- T2 : M1 0,009 et LC 0,008 avant comme après.

**Lecture (CS, non transposable) :**
- Sur T1 et T2, Alpha n'est jamais le membre qui atteint le minimum.
- L'effet sur les deux p de lecture conjointe vaut 0 ou 1/(B+1). Il est très inférieur à leur erreur de Monte-Carlo √(p(1−p)/B) : environ 0,0038 pour M1 sur T1, environ 0,0046 pour LC sur T2.
- **Le sens n'est pas garanti.** Sur T2, la correction **relève** la p globale. C'est conforme à H3, qui ne prédisait pas le sens.
- Aucune propriété exacte ne borne cet effet, puisque minP travaille sur les rangs de tous les membres.

## 3. Tableau prévisionnel des effets

Ce sont des constats de simulation sur prototypes (B = 999, graine 20260831). L'implémentation réelle doit les reproduire à l'étape 6.

| Triangle | Grandeur | V0 | (b) | (a) |
|---|---|---|---|---|
| T0 | p Alpha / M1 / LC | 0,016 / 0,056 / 0,111 | identiques | identiques |
| | A restitué | 0,000780 | 0,000780 | 0,001147 (×25/17) |
| | σ_boot / intervalle | — | non `identical`, écart nul à 6 chiffres / `identical` | `identical` |
| T1 | p Alpha | 0,008 | 0,007 | 0,007 |
| | M1 / LC | 0,015 / 0,027 | identiques | identiques |
| | verdict à 0,10 | ECHEC | ECHEC | ECHEC |
| | α où le verdict d'Alpha diffère | — | ]0,007 ; 0,008] ∪ ]0,014 ; 0,016] | idem |
| | A restitué | 0,001080 | 0,001080 | 0,001227 (×25/22) |
| | σ_boot, écart relatif (moyenne ; q05 ; q50 ; q95) | — | −0,019 % ; −0,016 % ; −0,159 % ; +0,131 % | 0 |
| | intervalle, écart relatif (2,5 ; 5 ; 50 ; 95 ; 97,5 %) | — | +0,038 ; −0,003 ; −0,035 ; +0,034 ; −0,085 % | 0 |
| T2 | p Alpha | 0,023 | 0,010 | 0,010 |
| | M1 / LC | 0,019 / 0,022 | 0,019 / 0,023 | 0,019 / 0,023 |
| | verdict à 0,10 | ECHEC | ECHEC | ECHEC |
| | α où le verdict d'Alpha diffère | — | ]0,010 ; 0,046] | idem |
| | A restitué | 0,001141 | 0,001141 | 0,001395 (×22/18) |
| | σ_boot, écart relatif | — | −0,005 % ; +0,028 % ; −0,021 % ; +0,048 % | 0 |
| | intervalle, écart relatif | — | −0,069 ; +0,005 ; −0,005 ; +0,014 ; −0,244 % | 0 |
| T3 (I = J+1) | p Alpha / M1 / LC | 0,004 / 0,017 / 0,042 | identiques | `res` `identical` |
| | σ_boot, écart relatif | — | −0,0003 % ; +0,117 % ; −0,039 % ; −0,078 % | 0 |
| | intervalle, écart relatif | — | −0,010 ; +0,020 ; −0,008 ; −0,019 ; +0,020 % | 0 |
| K1 (carré, j = 2) | p Alpha / M1 / LC | 0,024 / 0,098 / 0,051 | `res` `identical` | identiques |
| | A restitué | 0,000802 | 0,000802 | 0,001003 (×25/20) |
| KA (carré, tout figé) | ligne Alpha | diagnostic, « loi simulée de dispersion nulle », A = 5,5·10⁻¹⁷, p = NA | `res` `identical` | non applicable, A = NA (a-i) |
| R2, R2T | tout | — | `identical` | `identical` |

**Verdicts.**
- Au seuil 0,10, aucun verdict ne change, ni celui d'Alpha ni celui d'une autre ligne [V, M-d].
- À α saisi, les intervalles ci-dessus suivent la règle d'`add()` (l. 5485) : ECHEC si p < α/2, ALERTE si α/2 ≤ p < α, OK sinon. Ils sont tous au-dessus du repère 4/(B+1) = 0,004 et vont dans le sens plus sévère : OK devient ALERTE, ALERTE devient ECHEC.
- Le plancher de la règle R1, 1/(B_eff + 1), ne change pas : B_eff = 999 dans les trois variantes.
- Les p de famille et la p globale sont de type diagnostic, avec un verdict INFO à tout α (`engine_p_famille()`, l. 5697). Elles n'ont donc aucun intervalle de verdict.

**σ_USP** ne change dans aucune piste : propriété **exacte**, parce que `mw_parametre()` ne reçoit pas le bootstrap. Il est aussi mesuré `identical()` sur les huit triangles.

**L'intervalle bootstrap** est fait des quantiles de cred·σ_boot + (1 − cred)·σ_std (l. 17957-17959). Ses écarts relatifs sont donc atténués par le mélange de crédibilité.

**Textes restitués sous (b).** La mention M6 et `usage_sigma` changent sur tout trapèze à colonne J−1 dégénérée (T0 à T3). Textes proposés au § 4.3.

**Références.** Je prévois les sept cas identiques sous (b) :
- mesuré sur le prototype pour R2 et R2T (Gb3) ;
- les cinq cas lognormaux ne sont pas touchés par le code.

La preuve vient à l'étape 6, au seuil 0.

**Erreur de Monte-Carlo et erreur d'approximation, séparées.**
- **Effet de B (Monte-Carlo).** Les écarts sur Alpha sont appariés : mêmes réplications sous (a), mêmes tirages e sous (b) d'après Gb2. Leur **sens est exact** ; leur **grandeur** dépend de la graine :
  - T2 : D = 13/1000 avec la graine principale, 17/1000 avec la graine secondaire (0,023 → 0,006) ;
  - T1 : D = 1 puis 3.
- Les écarts de σ_boot sont eux aussi appariés. Leur erreur de Monte-Carlo n'est pas estimée : une seule graine, M-h n'ayant pas relevé σ_boot.
- **Effet de T (approximation).** Aucun théorème ne couvre à T = 8 la p de Monte-Carlo de ce bootstrap semi-paramétrique. Le niveau dans le cas dégénéré n'est pas mesuré (correction de ma spécification, § 6, m4).

## 4. Textes proposés

### 4.1 `mw:m1d` sous (b) : compte **12 479 / 12 800**, marge 321 [V, décompte]

- La rubrique 6 remplace le paragraphe « Colonnes dégénérées » des l. 17295-17312 (1 662 caractères). Nouveau texte : 1 243 caractères, celui de la spécification, inchangé :

```latex
\emph{Colonnes dégénérées.} \code{mw\_famille\_alpha()} ne reçoit pas l'ensemble figé des colonnes
dégénérées (règle commune, section~\ref{sec:mwm1})~: elle garde ces colonnes dans $A$, avec leur
poids $n_j$, et l'avertissement des colonnes dégénérées ne nomme pas la ligne parmi celles qui les
écartent (§\ref{sec:controles}). L'amplitude observée d'une telle colonne est nulle ou de l'ordre
de la tolérance $10^{-12}$ du prédicat, mais son poids reste au dénominateur. Tirée avec un
$\hat\sigma_j^2$ nul ou négligeable (le sien pour $j \le J-2$, l'estimateur direct pour la colonne
$J-1$ d'un trapèze, section~\ref{sec:boot-mw}), la colonne garde une amplitude négligeable dans les
réplications (dégénérée dans chaque réplication mesurée, rubrique~7)~: $A$ observée et simulées
sont multipliées par $\sum' n_j/\sum_j n_j$ ($\sum'$ sur les colonnes non dégénérées)~; la p-value
de Monte-Carlo, comme la p de famille de M1 et la p globale, n'en est pas modifiée, à des égalités
près de l'ordre de la tolérance, et seule la valeur restituée de $A$, diminuée, ne se lit plus
comme l'amplitude moyenne des colonnes non dégénérées. La colonne $J-1$ d'un carré, qui n'a qu'un
facteur, ou d'un trapèze à moins de trois facteurs n'entre pas dans $A$.
```

- La rubrique 7 remplace le passage « Colonnes dégénérées (rubrique~6~; … sans la colonne. » des l. 17367-17375 (690 caractères). Nouveau texte : 789 caractères, chiffres remplis ; la phrase de M1 est condensée puisque M1 ne change pas :

```latex
Colonnes dégénérées (rubrique~6~; $B = 999$, graine 20260831, triangles construits)~: constats de
simulation, non transposables. Colonnes tirées avec $\hat\sigma_j^2$ nul ou négligeable (triangle de
six années, $j = 0$~; trapèze de référence modifié, $j = 2$ et $J-1$~; colonne $J-1$ de deux
trapèzes construits, $8\times6$ et $8\times5$, estimateur direct nul)~: dégénérées dans chaque
réplication, p-value inchangée sans la colonne. Tirée avec la règle de minimum ($0{,}14$ et
$0{,}68$), la colonne $J-1$ de ces deux trapèzes ne serait dégénérée dans aucune réplication~:
p-value $0{,}008$ et $0{,}023$ au lieu de $0{,}007$ et $0{,}010$~; p de famille de M1 inchangée
($0{,}015$ et $0{,}019$)~; p globale $0{,}027$ et $0{,}022$ au lieu de $0{,}027$ et $0{,}023$,
écart sans sens garanti.
```

- **Comptes des autres pistes**, chiffres remplis, mêmes textes que la spécification : (a) **12 094** (marge 706) ; (c) **12 897** (dépassement de 97).

### 4.2 Passages du `.tex` à modifier sous (b), hors budget de `mw:m1d`

Sans ces changements, chaque passage deviendrait une affirmation fausse sur le code (critère E5). Ils font partie du périmètre de l'étape 7. `regulatory` les revoit en routine : les passages (i) et (iii) et la mention M6 citent D(4), D(5) et D(5)(d)(ii).

**`sec:boot-mw` :**
1. (i) l. 6550-6552 : « où $\hat\sigma_{J-1}$ est la valeur de la règle de minimum sur un carré et, sur un trapèze, l'estimateur direct (§\ref{sec:trapeze-niveau}, et ci-dessous) ».
2. (ii) l. 6567-6568 : « Sur un trapèze $I > J$, \code{mw\_bootstrap()} tire les triangles avec l'estimateur direct de $\sigma^2_{J-1}$, celui qui réduit les résidus observés de cette colonne quand elle n'est pas dégénérée (§…), et non avec … ».
3. (iii) l. 6573-6575, à remplacer par : « Triangle carré, qui n'a pas d'estimateur direct~: simulation avec la valeur de la règle. Colonne $J-1$ dégénérée d'un trapèze (\code{.mw\_colonne\_degeneree()})~: son estimateur direct la garde d'amplitude négligeable dans les réplications, comme une colonne $j \le J-2$ dégénérée tirée avec son propre $\hat\sigma_j^2$~; tirée avec la règle, elle ne le serait plus, et le triangle observé serait de probabilité pratiquement nulle sous la loi de référence. »

**Index des fonctions :**
4. l. 1795-1798, `.mw_simulation_sigma_direct()` : « vrai si et seulement si `aj` est un trapèze (champ `sigma2_Jm1_direct` présent), colonne J−1 dégénérée comprise ».
5. l. 1801-1803, `.mw_cas_sigma_direct()` : « "degenere" (trapèze dont la colonne J−1 est dégénérée, lu par `.mw_colonne_degeneree()`), "simulation" sinon ».

**Ailleurs :**
6. l. 15800-15801 : retirer « si elle n'est pas dégénérée, ».
7. l. 16162-16163 : retirer « si la colonne $J-1$ n'est pas dégénérée, ».
8. l. 19221-19222 : « aucun résidu retenu ; l'estimateur sert à simuler la colonne, par convention de l'outil (section~\ref{sec:boot-mw}) ».

**Commentaires R** (pour `coder`) : l. 13855-13857 et 13904-13906.

### 4.3 Textes restitués sous (b) (textes d'`actuary`, pour `coder`)

`FORMAT_MENTION_MW_SIGMA_DIRECT_DEGENERE` garde les trois arguments `%d`, `%s`, `%d`, dans le même ordre :

> "Trapeze (I > J) : la regle de minimum s'applique a sigma2_(J-1) par prescription de l'annexe XVII, D(5)(d)(ii), seconde ligne, bien que la colonne J-1 porte %d facteurs, dont l'estimateur direct vaut %s a %d degre(s) de liberte ; cette colonne etant degeneree (voir l'avertissement sur les donnees), aucun de ses residus n'est retenu (tests, influence, vivier du bootstrap). Par convention de l'outil, non reglementaire, l'estimateur direct sert a simuler la colonne J-1 des triangles tires par le bootstrap ; il n'entre ni dans la MSEP ni dans sigma(res,s,USP) : valeur donnee pour information."

`MW_USAGE_SIGMA_DEGENERE` :
- `sigma` = `MW_USAGE_SIGMA_SIMULATION[["sigma"]]` (« … : MSEP, sigma_USP, replications ») ;
- `sigma_residus` = "sigma_(J-1) direct : colonne degeneree, sans residu ; simulation (convention)".

**Conséquences pour le code et les tests :**
- Le test de `test_merz_wuthrich_trapeze.R` l. 619 (`MW_USAGE_SIGMA_DEGENERE[["sigma"]]` identique à `MW_USAGE_SIGMA[["sigma"]]`) devient faux et doit être revu, ainsi que l. 579-632 et `outils_unitaires.R` l. 276 (gabarit `M23_degenere`).
- Point obligatoire : `.mw_cas_sigma_direct()` doit lire `.mw_colonne_degeneree()` directement. C'est l'artefact attendu du prototype Vb : les textes de T0 à T3 y basculaient en « simulation ».

## 5. Lecture de H1 à H6

| | Prédiction | Constat | Lecture |
|---|---|---|---|
| H1 | Sous Va, p_Alpha = p_sans au bit près ; Δp = 0 sur K1 ; A multiplié par Σn/Σ'n | 0,016 / 0,007 / 0,010, `identical` ; K1 0,024 = 0,024 ; écart relatif du rapport ≤ 3,1·10⁻¹⁴ | **confirmée** (exacte, et vérifiée) |
| H2 | Sous Vb, p = p_sans ; les douze autres `identical` ; σ_boot et l'intervalle changent sur T1 à T3, de façon négligeable sur T0 | tout est vérifié ; T0 : σ_boot non `identical` mais écart nul à 6 chiffres, intervalle `identical` | **confirmée** (CS) |
| H3 | Va = Vb sur M1 et LC (T0 à T2) ; sens de l'écart à V0 non prédit | Va = Vb partout ; écart à V0 : M1 nul, LC nul sauf +0,001 sur T2 | **confirmée** (CS) |
| H4 | R2 et R2T `identical` sous Va et Vb ; T3 sous Va ; K1 et KA sous Vb | Ga3 et Gb3 OK | **confirmée** |
| H5 | V0 sur KA : dispersion nulle, diagnostic, `inoperant` = TRUE ; Va : non applicable | dispersion nulle, diagnostic, **`inoperant` = FALSE**, p = NA ; Va : non applicable | **en partie fausse**, sur `inoperant`. C'est une erreur de ma spécification, pas un défaut du code : `inoperant` vaut TRUE seulement par la règle R1 (constat du rang 3, `add()`). **Pas de constat E3** : aucune p finie n'est calculée sur le bruit d'arrondi. |
| H6 | Aucun verdict d'Alpha ne change à 0,10 sur T1 et T2 | ECHEC dans les trois variantes | **confirmée** |

## 6. Constats triés selon l'ADR 0018

**Aucun constat marquant. Aucune issue proposée.**

**Constats mineurs écartés (ADR 0018)**
- **m1** — H5 : ma spécification (§ 3.6) prédisait `inoperant` = TRUE sur une ligne en dispersion nulle. Le code est conforme à `.claude/rules/moteur.md` (TRUE seulement par R1). À consigner comme erreur de prédiction — critère : aucun.
- **m2** — KA sous V0 (sortie l. 1001-1009) : le diagnostic Alpha restitue A = 5,5·10⁻¹⁷ (bruit d'arrondi) et « écart relatif maximal 0.00 % », avec p = NA et verdict INFO. Il n'y a ni p ni verdict, et le texte de `mw:m1d` (« nulle ou de l'ordre de la tolérance ») reste vrai. Ce point demeure sous (b), qui ne touche pas les carrés ; (a) le supprimerait — critère : aucun.
- **m3** — KA (l. 977-989) : onze clés à B_eff = 0, et DW à p = NA avec B_eff = 999. La cause n'a pas été recherchée [NV]. Rien n'indique une p fausse ; triangle construit extrême (vivier de 2 résidus) — critère : aucun.
- **m4** — Ma spécification, § 3.7 : « le niveau n'est pas mesurable dans ce cas » est imprécis. Sous un modèle de Mack au bord de H0, avec σ_{J−1} = 0, la colonne observée est toujours dégénérée. La loi de (b) y est la loi génératrice de cette colonne, celle de V0 non. Un niveau serait donc mesurable sous ce plan ; mesure non faite, et non requise puisque E2 est retenu. Aucun texte proposé ne prétend le contraire — critère : aucun.
- **m5** — Le constat C1 de la spécification disparaît : la méthode du contrôleur (somme de nchar + 1 par ligne) redonne exactement 12 799 en Python. L'écart d'un caractère venait de ma méthode du rang 2 — critère : aucun.
- C2 et C5 de la spécification disparaissent sous (b).

## 7. Questions PA-2 au mainteneur

1. **Piste.** *Recommandation* : **(b)**, par application de la règle PA-1-2 ; (b) et (a) sont toutes deux admissibles.
   - *(a)* : propriété exacte, indépendante de la simulation, et fin de la dilution de A. Mais un contrat partagé, l'avertissement modifié sur tout triangle à colonne dégénérée, et C5 demeure.
   - *(c)* : aucun code ; la p reste majorée ; texte à 12 897.
2. **Budget de `mw:m1d`.** *Recommandation* : garder **12 800** ; (b) tient en 12 479. Aucun commit `tests:` sur `controle_doc_nd.R` ni retouche de `CONVENTIONS.md`.
   - *Options* : relèvement inutile en (a) et (b) ; en (c), condensation d'environ 100 caractères, ou relèvement à 12 900.
3. **Étiquette.** *Recommandation* : **jalon court 3.1.1** après la fusion d'A3. (b) change dans le moteur des p sur des entrées admissibles (Alpha ; p globale sur T2) et des verdicts à α saisi : la règle de Q-75-5 joue. Le md5 de `R/engine.R` change, d'où la batterie sous Windows.
   - *Option* : aucun jalon, seulement en (c).
4. **Annotation de l'ADR 0005 avant le code (si (b)).** *Recommandation* : oui, par `architect`, avant l'étape 6 :
   - au point 1 de l'annotation du 25/11, remplacer « Colonne J−1 dégénérée : simulation inchangée (règle) » par « Colonne J−1 dégénérée d'un trapèze : simulée avec son estimateur direct, qui la garde d'amplitude négligeable (#620, A3) » ;
   - au point 2, réduire le prédicat à « trapèze », les cas du texte restant carré / dégénéré / simulation ;
   - aligner `CONTEXT.md` « σ des résidus ».
   - *Option* : sans objet en (a) ou (c).
5. **Forme de A sans colonne restante (si (a)).** *Recommandation* : (a-i), A = `NA` et ligne non applicable, mesurée par Ga4. Sans objet en (b).
6. **Closes devient Refs (si (c)).** *Recommandation* : sans objet en (b). En (c), passer la ligne en `Refs #620` et fermer à la main en `not planned`.
7. **Textes restitués (si (b))** : approuver les textes du § 4.3. *Recommandation* : approuver ; passage de `regulatory` en routine, puis `app-review` léger sur le rendu réel.

---

## Retour

- **Statut** : `revue requise`. La lecture est complète, avec ses preuves ; PA-2 est une décision du mainteneur.
- **Résultat** :
  - piste (b) recommandée ;
  - critère 4 chiffré : effet nul ou d'un compte, sens non garanti ;
  - tableau des effets ;
  - textes de `mw:m1d` comptés : (b) 12 479, (a) 12 094, (c) 12 897 ;
  - passages du `.tex` et textes restitués listés pour (b) ;
  - H1 à H4 et H6 confirmées ; H5 en partie fausse, sans constat E3.
- **Preuves**
  - *Vérifiées* : sortie l. 1443-1464 (R0 et G*) ; l. 1503-1512 (synthèse) ; M-c, M-d, M-e, M-f par triangle ; M-h l. 1493-1498 ; règle d'`add()` l. 5481-5486 ; p de famille de type diagnostic l. 5697 ; intervalle bootstrap l. 17957-17959 ; seams et textes l. 13855-13940 ; décompte des caractères (12 799 reproduit).
  - *Hypothèses* : références identiques sous l'implémentation réelle de (b), à prouver à l'étape 6 ; borne de tolérance pour une colonne dégénérée dont l'estimateur direct est non nul mais minuscule (raisonnement d'échelle, non mesuré hors de T0).
  - *Non vérifiées* : `mesure_620.R` au-delà de la l. 694 (audité au rang 3) ; cause des NA sur KA (m3) ; erreur de Monte-Carlo de l'effet sur σ_boot (une seule graine).
- **Informations manquantes** : aucune pour la décision.
- **Décisions non résolues** : PA-2, points 1 à 7 (mainteneur) ; annotation de l'ADR 0005 et `CONTEXT.md` (`architect`).
- **Critères déclenchés** :
  - changement de résultat : p d'Alpha, p globale (T2), verdicts à α saisi, σ_boot et intervalle, textes M6 et `usage_sigma` ;
  - ADR accepté modifié : ADR 0005 ;
  - choix entre (a) et (b) qu'aucune mesure ne tranche, réglé par la règle approuvée PA-1-2 ;
  - validité à T = 8 non tranchée : niveau dans le cas dégénéré non mesuré.
  - Aucun désaccord avec `audit`.
- **Constats hors périmètre** : § 6, m1 à m5, tous mineurs, critère « aucun ».
- **Prochaine action recommandée** :
  1. La session verse ce rapport.
  2. PA-2.
  3. Si (b) : annotation de l'ADR 0005 par `architect`, puis étape 6 par `coder-approfondi` (`high`), avec le point obligatoire sur `.mw_cas_sigma_direct()` et les textes du § 4.3, en un commit `moteur:` puis un commit `tests:`.
  4. Le script de mesure est rejoué sur le code.
