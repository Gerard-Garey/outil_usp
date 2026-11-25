# JS2, étape 2c (#617) : lecture de la mesure « colonne J−1 dégénérée d'un trapèze »

*Rédigé par l'agent `actuary-approfondi` (IA), le 25/11/2026. Versé intégralement par la session principale (Q-54-10).*

> **État consulté.** Lecture seule sur `claude/jalon-js2`, tête `4fa3de4`.
> - `git diff --stat 17367cc HEAD` ne contient que la sortie versée.
> - Les sommes md5 relues aujourd'hui sont celles du pied de la sortie : `R/engine.R` `723277ddfa5736d7411838d15d8dad00`, `R/charger_moteur.R` `5ed6226c768d5ad781ea03a7306ccc11`, `mesure_617.R` `724bfa8181f3b3b454acc07c1511d475`.
>
> **Lu** : le protocole (`actuary-1-protocole-617.md`), le script (518 lignes), la sortie et le README ; la fiche `mw:m1d` du `.tex` (l. 17200-17352) ; `sec:mwm1` (1)-(3) (l. 16387-16440) ; `sec:boot-mw` (l. 6545-6580) ; l'entrée `mw:m1d` de `docs/suivi-documentation/III-M.md` ; l'ADR 0018, § 2-4 ; `docs/latex/CONVENTIONS.md` (plafond de `mw:m1d`, règles 5 à 8 et 14, « Pas de vie du dépôt ») ; la règle des verdicts dans `add()` (`R/engine.R`, l. 5481-5485) ; `mw_famille_alpha()` (l. 15872-15889).
>
> **Exécuté** (R 4.3.3, `LC_ALL=C.UTF-8`, moteur chargé par `charger_moteur()`, aucun tirage) :
> - intervalles de Clopper–Pearson pour 1/999 et 13/999 ;
> - rapports de poids à l'observé ;
> - `.mw_ensembles_figes()` sur `triangle_mw_trapeze.csv`.
>
> **Légende** : [V] vérifié (code relu à la ligne citée, ou commande exécutée) ; [H] hypothèse ; [NV] non vérifié.

## 1. Issue au regard de la règle figée (§ 4) et prédictions (§ 7)

### 1.1 Validité de la mesure (§ 4.1, § 4.2)

- P1 à P6, I1 à I5 et D1 à D4 sont verts sur T1, T2 et T0 [V, sortie].
- D4 donne 999/999 « identique » sur les trois triangles, sans aucun cas « tolérance ». Il ne reste donc aucun point de tolérance à lire en 2c.
- D5 donne 999/999 sur les trois triangles : la ligne j = J−1, de poids n_{J−1}, figure bien dans `detail`.
- Le script exécuté est bien celui qui est versé (md5 identique). Le moteur est inchangé entre l'en-tête du protocole, l'exécution et la tête de branche.

### 1.2 Issue par triangle et issue globale

- **T1** : π̂_4 = 0/999 et Δp = 0,001 ≠ 0. **Issue 2b.**
- **T2** : π̂_3 = 0/999 et Δp = 0,013 ≠ 0. **Issue 2b.**
- **T0** : π̂_2 = π̂_4 = 999/999 et Δp = 0. **Issue 1.**
- **Issue globale : 2b, confirmée.** Elle est la plus haute des trois (ordre 3 > 2b > 2a > 1). Par la décision O1 (§ 4.4, lecture (a)), elle relève d'une phrase inexacte avec constat ADR 0018, et non du point d'arrêt PJ-1. JS2 ne touche pas au moteur.

### 1.3 Contrôle arithmétique de la propriété exacte du § 2.3

À l'observé, A_obs est égal à (Σ'n/Σn)·A^sans_obs avec les rapports suivants :

| Triangle | Rapport | Écart calculé [V] |
|---|---|---|
| T1 | 22/25 | 0 |
| T2 | 18/22 | 0 |
| T0 | 17/25 | −2,4·10⁻¹⁷ |

L'amplitude observée de la colonne figée est donc nulle en double précision (T1, T2) ou de l'ordre de l'arrondi (T0). Les trois triangles vérifient « p_moteur ≥ p_sans » (sortie, « propriété exacte : OK »). On n'observe aucune bascule dans le sens inverse (« compte sans seulement : 0 »).

### 1.4 Prédictions du § 7, toutes confirmées

| Prédiction | Observé | Lecture |
|---|---|---|
| T1, T2 : π̂_{J−1} = 0 | 0/999 et 0/999 ; Clopper–Pearson [0 ; 0,0037] | Confirmée. L'écart relatif maximal de la colonne simulée vaut 10^−2,15 en médiane sur T1 (10^−1,72 sur T2) et au minimum 10^−4,19 (10^−3,03), soit au moins 6·10⁷ fois la tolérance. La colonne n'est jamais près du seuil. |
| T1, T2 : Δp ≥ 0, attendu > 0 | +0,001 et +0,013 | Confirmée (portée : § 1.5). |
| T1, T2 : D1 à D4 verts | verts | Confirmée. D1 : les 999 appels reçoivent la règle, aucun l'estimateur direct. |
| T0 : π̂_2 = π̂_4 = 1, écart de l'ordre de 10⁻¹⁶ | 999/999 et 999/999 ; écarts médians 10^−15,48 et 10^−15,69, maximaux 10^−15,30 et 10^−15,39 ; écarts nuls exacts dans au moins 1 % des réplications pour j = 4 | Confirmée. |
| T0 : Δp = 0 | 0 (N = 15 des deux côtés) | Confirmée. Rendre J−1 exactement dégénérée change Alpha au bit près dans 400 réplications sur 999, sans aucune bascule d'indicateur. q_b vaut au plus 5,8·10⁻¹³ : c'est la situation décrite par la phrase actuelle, « à des égalités près de l'ordre de la tolérance ». |

La part q_b de la colonne J−1 dans A* éclaire l'écart de grandeur entre T1 et T2 :
- T1 : médiane 4,2 %, quantile 0,99 à 27 %, maximum 40 % ;
- T2 : médiane 15 %, maximum 81 %.

Sur T2, la règle est plus forte (0,684 contre 0,142) et le poids plus élevé (n = 4 contre 3), d'où une contribution plus forte de la colonne. [Constat de simulation]

### 1.5 Portée de Δp = 0,001 sur T1, au regard de err_mc ≈ 0,003

1. **err_mc n'est pas l'étalon de Δp.**
   - err_mc ≈ √(p(1−p)/B) mesure l'erreur de chaque p-value contre sa valeur à B infini.
   - Δp est **apparié** : on compare les mêmes 999 réplications. Il vaut D/(B+1), où D est le nombre de réplications discordantes.
   - Comme les discordances ne vont que dans un sens (§ 2.3 du protocole, égalités à la tolérance près), D suit une loi binomiale (B ; δ). δ est la probabilité, sous la loi bootstrap, qu'une réplication dépasse avec la colonne et non sans.
   - L'erreur de Δp est donc d'environ √(δ(1−δ)/B), soit 0,001 sur T1, et non 0,003.
2. **Ce qui est exact.**
   - Le signe : Δp ≥ 0.
   - Δp = 0,001, valeur reproductible au bit près à cette graine. C'est le plus petit écart non nul qu'on puisse résoudre à B = 999.
   - **δ > 0 sur T1.** La loi bootstrap est à support fini (tirage avec remise dans un vivier de 22 résidus), et une réplication discordante a été réalisée : la discordance a donc une probabilité strictement positive. À B infini, la p-value du moteur dépasse donc strictement celle de la statistique sans la colonne, conditionnellement au triangle T1. Une seule réplication suffit ainsi à réfuter (A2), qui est une affirmation universelle (« n'est pas modifiée »).
3. **Ce qui est observé.** La grandeur : δ̂ = 1/999, Clopper–Pearson à 95 % [2,5·10⁻⁵ ; 0,0056]. Sur T1, l'effet est donc compatible avec une valeur presque nulle comme avec environ deux err_mc. Il est **sans portée matérielle** sur T1 au seuil par défaut, et T1 seul ne fonderait pas la matérialité.
4. **T2 fonde la matérialité.** On y compte 13 discordances, soit δ̂ = 0,013, Clopper–Pearson [0,0070 ; 0,0221]. À B infini, la p-value du moteur dépasse celle sans la colonne d'au moins 0,007 environ (confiance 95 %), soit un rapport des p-values mesurées d'environ 2,3.

## 2. Constats ADR 0018

### 2.1 E2 : seuils 0,05 et 0,10 du § 4.3, confirmé qu'aucun n'est franchi

| Triangle | p moteur | p sans | 0,10 | 0,05 |
|---|---|---|---|---|
| T1 | 0,008 | 0,007 | même côté | même côté |
| T2 | 0,023 | 0,010 | même côté | même côté |
| T0 | 0,016 | 0,016 | même côté | même côté |

La règle des verdicts [V, `R/engine.R` l. 5484] donne ECHEC si p < α/2, ALERTE si α/2 ≤ p < α, OK sinon. Au seuil α = 0,10 de l'application, les deux p-values donnent ECHEC sur chaque triangle. **E2 n'est pas déclenché au sens du § 4.3 figé.**

**Seconde lecture, à signaler.** α est une saisie de l'utilisateur (`app.R`, l. 972, défaut 0,10). L'ADR 0018, § 2, juge l'effet « sur toute entrée admissible ». Sur les p-values mesurées, le calcul est arithmétique :
- **T2** : les verdicts diffèrent pour α ∈ ]0,010 ; 0,046]. Pour α ∈ ]0,020 ; 0,023], c'est ECHEC sans la colonne contre OK avec ; pour α ∈ ]0,023 ; 0,046], ECHEC contre ALERTE ; pour α ∈ ]0,010 ; 0,020], ALERTE contre OK.
- **T1** : les verdicts diffèrent pour α ∈ ]0,007 ; 0,008] ∪ ]0,014 ; 0,016].

Ces intervalles sont admissibles à B = 999. Le moteur refuse un α hors de ]0 ; 0,30[ (l. 17583), et l'application avertit si B + 1 ≤ 4/α (`app.R`, l. 966), soit α ≤ 0,004 à B = 999.

Un E2 au sens de l'ADR 0018 est donc établi pour des α autres que celui par défaut. Ce n'est pas un problème de documentation disponible : c'est la règle du protocole (deux seuils fixes) qui est plus étroite que celle de l'ADR. Le constat est gardé de toute façon par E3, mais un changement de verdict relève du mainteneur. Qu'il tranche la lecture.

### 2.2 E3 : texte de l'issue à créer sur accord du mainteneur, pour la branche suivante

**Titre** : « Famille α (`mw:m1d`) : la colonne J−1 dégénérée d'un trapèze entre dans les statistiques simulées, p-value de Monte-Carlo majorée »

**Libellés proposés** : `bug`, `needs-triage`. Requalification en `enhancement` possible : la décision O1 a classé le cas hors du point d'arrêt PJ-1, comme doctrine documentée.

**Corps** :

> *Rédigé par l'agent actuary (IA).*
>
> **Origine.** Constat ADR 0018 de la mesure de #617 (JS2, étapes 2b et 2c). JS2 ne touche pas au moteur : décision O1 du mainteneur du 25/11/2026, issue 2b et non point d'arrêt PJ-1. Pièces : `docs/revues/20261125-js2-jalon/actuary-1-protocole-617.md`, `docs/revues/20261125-js2-jalon/mesure-617/` (script, sortie) et la lecture 2c d'`actuary-approfondi`.
>
> **Constat.**
> - Cas visé : un trapèze (I > J) dont la colonne J−1 est dégénérée à l'observé, au sens de `.mw_colonne_degeneree()`, par exemple une dernière colonne clôturée par un facteur fixe.
> - `mw_bootstrap()` tire cette colonne avec la valeur de la règle de minimum : `.mw_simulation_sigma_direct()` est faux, et `aj_sim` vaut `aj`.
> - Quand cette valeur n'est pas négligeable, la colonne simulée n'est plus dégénérée.
> - Les douze autres clés de `MW_CATALOGUE_MC` et le vivier l'écartent par l'ensemble figé. `mw_famille_alpha()` ne reçoit pas cet ensemble et garde la colonne dès que n_{J−1} = I − J + 1 ≥ 3.
> - L'amplitude de la colonne est donc nulle dans A observée et positive dans chaque A simulée. La p-value de Monte-Carlo compare la statistique observée à la loi d'une autre statistique, ce que l'ensemble figé sert précisément à éviter (`sec:mwm1`, (2)). Elle est au moins égale à celle de la statistique sans la colonne : la propriété est exacte, l'écart est dans le sens conservateur.
>
> **Preuve** (`sortie_mesure_617.txt`, B = 999, graine 20260831, moteur `723277dd…`, exécution sur `17367cc`, I1 à I5 et D1 à D4 verts) :
>
> | Triangle construit | Règle de minimum | n_{J−1} | Colonne dégénérée dans les réplications | p MC d'Alpha | p sans la colonne | Discordances |
> |---|---|---|---|---|---|---|
> | T1 (trapèze de référence 8 × 6, C(i,5) := C(i,4)·f̂_4, i = 0..2) | 0,142 | 3 | 0/999 | 0,008 | 0,007 | 1 |
> | T2 (colonnes 0 à 4 du triangle de contrôle, C(i,4) := C(i,3)·f̂_3, i = 0..3) | 0,684 | 4 | 0/999 | 0,023 | 0,010 | 13 [IC 95 % de δ : 0,0070 ; 0,0221] |
> | T0 (témoin, règle 7,8·10⁻²⁹) | ≈ 0 | 3 | 999/999 | 0,016 | 0,016 | 0 |
>
> **Critères ADR 0018.**
> - **E3**, montré : tableau ci-dessus.
> - **E2** : aucun changement au seuil α = 0,10 par défaut, ECHEC des deux côtés. Sur les mêmes p-values, le verdict diffère pour α ∈ ]0,010 ; 0,046] (T2) et pour α ∈ ]0,007 ; 0,008] ∪ ]0,014 ; 0,016] (T1). Lecture d'« entrée admissible » à trancher par le mainteneur.
> - **E5** : la phrase du `.tex` est corrigée dans JS2 (#617).
> - **Non mesuré** : l'effet sur la p de famille M1 et sur la p globale LC, dont Alpha est membre (diagnostics, sans verdict). E3 y est plausible ; à mesurer.
>
> **Domaine d'effet.**
> - Concernés : I ≥ J + 2, colonne J−1 dégénérée à l'observé, règle de minimum non négligeable.
> - Non concernés :
>   - le carré et le cas I = J + 1 : la colonne J−1 a moins de trois facteurs et n'entre pas dans A (exact, `mw_famille_alpha()`) ;
>   - une colonne j ≤ J−2 dégénérée : elle est tirée avec son propre σ̂², et son amplitude simulée reste négligeable (constat de simulation sur deux triangles) ;
>   - la lognormale.
> - Les sept cas de référence n'ont pas de colonne J−1 dégénérée d'au moins trois facteurs : `reserve2` est un carré ; sur `reserve2_trapeze`, l'ensemble des colonnes dégénérées est vide (vérifié).
>
> **Pistes, non tranchées.**
> - **(a) Passer l'ensemble figé à `mw_famille_alpha()`.** Les colonnes de `figes$degeneres` sont exclues à l'observé et dans chaque réplication, comme pour les douze autres clés.
>   - Δp est nul par construction.
>   - La valeur restituée de A n'est plus diluée par une colonne dégénérée, j ≤ J−2 compris.
>   - Cette piste revient sur la doctrine écrite de `mw:m1d` (colonnes gardées) et touche `.MW_LIGNES_COLONNES_ECARTEES` et l'avertissement des colonnes dégénérées.
>   - À régler : A quand aucune colonne ne reste.
> - **(b) Simuler la colonne J−1 dégénérée avec l'estimateur direct (nul).**
>   - La colonne reste dégénérée, et Δp est nul aux égalités de tolérance près.
>   - Cette piste revient sur la décision V2 du 25/11/2026.
>   - Elle change la loi de simulation, donc aussi `sigma_boot` (intervalle de σ_USP).
>   - Les douze autres clés ne lisent pas la colonne : D4 donne 999/999 identiques. Elles resteraient donc probablement inchangées [H].
>   - Elle est cohérente avec le fondement écrit en `sec:boot-mw` : simuler J−1 avec la variance qui en réduit les résidus observés donne ici une variance nulle.
> - **(c) Statu quo documenté** (texte de JS2 : écart dans le sens conservateur). L'issue est alors fermée `not planned`, avec son motif.
>
> **Critères d'acceptation** (pistes a et b).
> 1. Le script de #617, adapté et versé, donne Δp = 0 sur T1, T2 et T0, aux égalités de tolérance près, avec ses contrôles d'intégrité verts.
> 2. `tests/test_reproductibilite.R` est vert sur les sept cas, sans aucun écart ; à défaut, un tableau avant / après est expliqué.
> 3. Pour (b) : l'effet sur `sigma_boot` et sur les treize p-values de T1 et T2 est mesuré et rapporté.
> 4. L'effet, avant et après, sur la p de famille M1 et la p globale LC de T1 et T2 est consigné.
> 5. La fiche `mw:m1d` (et `sec:boot-mw` pour (b)) est alignée, et `concordance_doc_moteur.R --strict` est vert.
>
> **Hors périmètre** :
> - la simulation de la colonne J−1 non dégénérée (estimateur direct, V2) ;
> - la lognormale ;
> - une mesure de niveau sous un plan à colonne J−1 dégénérée : aucun modèle générateur à σ > 0 ne produit une telle colonne sous H0.
>
> **Impact attendu** :
> - aucun sur les références [H, à vérifier par la batterie] ;
> - sur les entrées du domaine d'effet, p MC d'Alpha abaissée jusqu'à la valeur sans la colonne (T2 : 0,023 → 0,010) ;
> - pour (b), `sigma_boot` change aussi ;
> - tout verdict changé est soumis au mainteneur.

## 3. Texte final proposé à `docwriter` (fiche `mw:m1d`)

### 3.1 Rubrique 6 : remplacer le paragraphe « Colonnes dégénérées » (l. 17283-17296)

```latex
\emph{Colonnes dégénérées.} \code{mw\_famille\_alpha()} ne reçoit pas l'ensemble figé des colonnes
dégénérées (règle commune, section~\ref{sec:mwm1})~: elle garde ces colonnes dans $A$, avec leur
poids $n_j$, et l'avertissement des colonnes dégénérées ne nomme pas la ligne parmi celles qui les
écartent (§\ref{sec:controles}). L'amplitude observée d'une telle colonne est nulle ou de l'ordre
de la tolérance $10^{-12}$ du prédicat, mais son poids reste au dénominateur. Tirée avec un
$\hat\sigma_j^2$ nul ou négligeable (colonne $j \le J-2$, ou $J-1$ quand la règle de minimum l'est,
section~\ref{sec:boot-mw}), la colonne garde une amplitude négligeable dans les réplications
(dégénérée dans chaque réplication mesurée, rubrique~7)~: $A$ observée et simulées sont
multipliées par $\sum' n_j/\sum_j n_j$ ($\sum'$ sur les colonnes non dégénérées)~; la p-value de
Monte-Carlo n'en est pas modifiée, à des égalités près de l'ordre de la tolérance, et seule la
valeur restituée de $A$, diminuée, ne se lit plus comme l'amplitude moyenne des colonnes non
dégénérées. La colonne $J-1$ d'un trapèze, tirée avec la valeur de la règle de minimum, n'est en
général plus dégénérée quand cette valeur n'est pas négligeable~; avec au moins trois facteurs,
son amplitude, nulle à l'observé, entre alors dans chaque $A$ simulée, et la p-value de
Monte-Carlo est au moins égale à celle de $A$ calculée sans la colonne (propriété exacte, les
amplitudes étant positives ou nulles)~: écart dans le sens conservateur, de grandeur non
transposable, d'effet sur le niveau et la puissance non mesuré. Avec moins de trois facteurs,
carré compris, la colonne $J-1$ n'entre pas dans $A$.
```

### 3.2 Rubrique 7, alinéa « Statut des valeurs » : insérer avant « Identité de covariance~: exacte. »

```latex
Colonnes dégénérées (rubrique~6~; $B = 999$, graine 20260831, triangles construits)~: constats de
simulation, non transposables. Colonnes tirées avec un $\hat\sigma_j^2$ nul ou négligeable
(triangle de six années, $j = 0$~; trapèze de référence modifié, $j = 2$ et $J-1$, $\hat\sigma_j^2$
voisin de $10^{-28}$)~: dégénérées dans chaque réplication, p-value inchangée sans la colonne.
Colonne $J-1$ tirée avec une règle de minimum de $0{,}14$ (trapèze de référence modifié,
$8\times6$, trois facteurs) ou de $0{,}68$ (triangle de contrôle réduit et modifié, $8\times5$,
quatre)~: dégénérée dans aucune réplication~; p-value $0{,}008$ et $0{,}023$, contre $0{,}007$ et
$0{,}010$ sans la colonne.
```

### 3.3 Statuts, tels que le texte les nomme

- **Exact (lecture du code)** :
  - la simulation de J−1 par la règle ;
  - l'absence d'ensemble figé pour Alpha ;
  - p ≥ p_sans ;
  - le multiplicateur Σ'n/Σn ;
  - l'exclusion de A d'une colonne J−1 de moins de trois facteurs (n = 1 pour le carré, n = 2 pour I = J + 1).
- **Structurel, non démontré** : « n'est en général plus dégénérée » (aucun mécanisme n'égalise les facteurs simulés), et « garde une amplitude négligeable » pour une colonne de σ̂² négligeable. C'est un argument d'ordre de grandeur : le σ simulé est celui des écarts observés. Une colonne dégénérée au voisinage de la tolérance pourrait sortir du prédicat dans une réplication, avec une amplitude restant de l'ordre de 10⁻¹² ; ce cas n'est pas mesuré (O4). Le texte écrit donc « garde une amplitude négligeable » et non « reste dégénérée », et réserve « dégénérée » aux réplications mesurées.
- **Observé par simulation** : π̂, les p-values avec et sans la colonne, « p-value inchangée ».
- **Non transposable** : la grandeur de l'écart, le niveau et la puissance dans ce cas.
- **Respect de `CONVENTIONS.md`** : ni SHA, ni numéro d'issue, ni date, ni chemin `docs/revues/` (chemin non admis, il va au suivi) ; virgule `{,}` ; espaces insécables avant `:` et `;`.

### 3.4 Passages retirés du `.tex` (à signaler au compte rendu et à verser au suivi)

1. « au plus $\big(\max_i F(i,j) - \min_i F(i,j)\big)/\hat f_j^{(1)}$ » et « (au plus $2\cdot 10^{-12}$ par le premier volet du prédicat, environ $(n_j-1)\cdot 10^{-12}$ par le second) ». C'est une condensation (règle 5) : les deux volets sont décrits en `sec:mwm1` (1). Ce retrait est facultatif si le plafond est relevé.
2. « triangle de six années des tests unitaires dont la colonne $j = 0$ est dégénérée, $B = 999$, graine 20260831~: rapport $7/12$ à l'observé comme dans chaque réplication, p-value de Monte-Carlo $0{,}514$ avec ou sans la colonne ». Il est condensé en rubrique 7 (règle 6).

### 3.5 Plafond de la fiche (point de décision)

- La source de `mw:m1d` mesure aujourd'hui 11 787 caractères, pour un plafond de 12 000 [V].
- La proposition ajoute environ 1 016 caractères (rubrique 6 : 1 663 contre 1 342 ; rubrique 7 : 695), soit environ 12 800.
- Deux voies :
  - `docwriter` condense ailleurs dans la fiche environ 800 caractères, sans rien retirer du fond ;
  - le mainteneur relève le plafond de `mw:m1d` dans `CONVENTIONS.md`. La justification « traitement des colonnes dégénérées » y figure déjà. Je propose 12 800 caractères, toujours sur 3 pages.
- L'étendue réelle en pages est à mesurer par `tests/controle_doc_nd.R`.

### 3.6 Suivi : `docs/suivi-documentation/III-M.md`, sous `mw:m1d`

**Historique**, ajouter :

- Créneau JS2, #617, 25/11/2026 (passage de fin de branche de `docwriter`) : paragraphe « Colonnes dégénérées » de la rubrique 6 réécrit, chiffres portés en rubrique 7. Texte remplacé : « la statistique observée et chaque statistique simulée (la colonne, tirée avec σ̂_j² nul ou négligeable, restant dégénérée, section boot-mw) sont multipliées par Σ' n_j/Σ n_j […]. La p-value de Monte-Carlo n'en est pas modifiée, à des égalités près de l'ordre de la tolérance ». Il était inexact pour la colonne J−1 d'un trapèze tirée avec une règle de minimum non négligeable : mesure de #617, issue 2b. Retirés du `.tex` : rapport 7/12 et p MC 0,514 avec ou sans la colonne, sur le triangle de six années à colonne j = 0 dégénérée (mesure d'`actuary`, fin de branche Fq) ; [si le retrait 1 est retenu] bornes « au plus (max F − min F)/f̂ », « au plus 2·10⁻¹² par le premier volet du prédicat, environ (n_j − 1)·10⁻¹² par le second ».

**Décisions**, ajouter :
- Effet sur Alpha classé en issue 2b (phrase inexacte, constat ADR 0018) et non en point d'arrêt PJ-1 : décision O1 du mainteneur, 25/11/2026, avant l'exécution.
- Issue 2b confirmée par la lecture 2c d'`actuary-approfondi`, 25/11/2026.
- Constat E3 : issue #[N] (créée sur accord), branche suivante.
- Lecture d'E2 pour un α autre que celui par défaut : [décision du mainteneur].

**Mesures retirées du guide**, ajouter :

- Mesure de #617. Pièces : protocole `docs/revues/20261125-js2-jalon/actuary-1-protocole-617.md` (règle de décision figée avant l'exécution) ; script `docs/revues/20261125-js2-jalon/mesure-617/mesure_617.R` (md5 `724bfa81…`) ; sortie `…/sortie_mesure_617.txt`. Exécution : `17367cc`, moteur md5 `723277dd…`, R 4.3.3, `LC_ALL=C.UTF-8`, B = 999, graine 20260831, 95,9 s.
- Triangles construits :
  - T1 : `triangle_mw_trapeze.csv`, avec C(i,5) := C(i,4)·f̂_4 pour i = 0..2 ;
  - T2 : colonnes 0 à 4 de `triangle_mw.csv`, avec C(i,4) := C(i,3)·f̂_3 pour i = 0..3 ;
  - T0 : T1, puis C(i,3..5) multipliés par f̂_2·C(i,2)/C(i,3) pour i = 0..4.
- Résultats par triangle :
  - T1 : règle 0,14193, estimateur direct 0, n_{J−1} = 3. π̂_4 = 0/999 [0 ; 0,0037]. Écart relatif de la colonne simulée : de 10^−4,19 à 10^−1,85. A_obs = 0,00108017 (= 22/25 · A^sans_obs). p MC 0,008 (err 0,0028) contre 0,007 ; N = 7 contre 6 ; une discordance, δ̂ IC 95 % [2,5·10⁻⁵ ; 0,0056]. q_b : médiane 0,042, maximum 0,40.
  - T2 : règle 0,68446, n = 4. π̂_3 = 0/999. A_obs = 18/22 · A^sans_obs. p 0,023 (err 0,0047) contre 0,010 ; N = 22 contre 9 ; 13 discordances [0,0070 ; 0,0221]. q_b : médiane 0,15, maximum 0,81.
  - T0 : règle 7,8·10⁻²⁹, colonnes figées {2, 4}. π̂ = 999/999 pour les deux colonnes. Écart maximal 5·10⁻¹⁶. p 0,016 des deux côtés. Alpha change au bit près dans 400 réplications sur 999 si J−1 est rendue exactement dégénérée, sans bascule.
- Douze clés hors Alpha identiques dans les 999 réplications des trois triangles (contrôle D4).
- Au seuil α = 0,10, aucun verdict ne change. Intervalles d'α où le verdict changerait : § 2.1 de la lecture 2c.

**Correspondance SHA**, ajouter : `17367cc` → exécution de la mesure de #617 (sortie versée par `4fa3de4`) → `mw:m1d`.

## 4. Sort des mineurs m1 à m5 de l'audit léger

Aucun n'est atteint par l'exécution : la conclusion n'en dépend pas. Aucun ne remplit G, ni E1 à E6 : ils portent sur un script de mesure hors CI, dont la forme est mineure au sens de l'ADR 0018, § 2. **Tous écartés.**

### Constats mineurs écartés (ADR 0018)

- `mesure_617.R:449-455` — un T0 à π < 1 et Δp = 0 serait classé 2a. Le § 4.3 ne range ce cas dans aucune issue et demande seulement de nuancer « négligeable » : c'est une ambiguïté du protocole, non atteinte (π = 1) — actuary-approfondi, 25/11/2026 — aucun critère.
- `mesure_617.R:441` — un Δp `NA` donnerait 2b, et non « sans conclusion » (`isTRUE(dp == 0)`). Non atteint : p finies — actuary-approfondi, 25/11/2026 — aucun critère.
- `mesure_617.R:308-312` — une erreur R dans D4 serait comptée en échec de doctrine (issue 3), et non « sans conclusion ». C'est l'arrêt du côté prudent ; non atteint : 0 échec — actuary-approfondi, 25/11/2026 — aucun critère.
- `mesure_617.R:113` — « 0 » dans les quantiles de log10(écart) désigne un écart nul. Un écart de 1 s'écrirait « 0.000 » (`%.3f`) : les deux restent distinguables, l'ambiguïté n'est que de lecture. Dans cette sortie, les « 0 » de T0 sont des écarts nuls exacts — actuary-approfondi, 25/11/2026 — aucun critère.
- `mesure_617.R:45` — B < 99 est accepté. L'en-tête « ESSAI, NON VERSABLE » couvre B < 999 ; non atteint : B = 999 — actuary-approfondi, 25/11/2026 — aucun critère.

## 5. Retour

**Statut** : `revue requise`.
- Les quatre éléments demandés sont traités avec leurs preuves.
- Deux points relèvent du mainteneur : la lecture d'E2 pour un α autre que celui par défaut, et le plafond de la fiche.

**Résultat** :
- issue globale **2b confirmée** (T1 2b, T2 2b, T0 1) ; prédictions du § 7 toutes confirmées ;
- E2 non déclenché aux seuils 0,05 et 0,10 ;
- issue E3 rédigée (§ 2.2) ;
- texte final de `mw:m1d` et du suivi rédigé (§ 3) ;
- m1 à m5 écartés.

**Preuves**

- **Vérifiées** :
  - sortie, script et protocole relus ;
  - md5 du moteur, du chargeur et du script identiques au pied de la sortie ; `git diff 17367cc HEAD` limité à la sortie ;
  - Clopper–Pearson 1/999 = [2,53·10⁻⁵ ; 5,56·10⁻³] et 13/999 = [0,00695 ; 0,0221] (`binom.test`) ;
  - rapports 22/25, 18/22 et 17/25 à l'observé (écarts 0, 0 et −2,4·10⁻¹⁷) ;
  - règle des verdicts, `R/engine.R` l. 5484 ;
  - `mw_famille_alpha()` exclut n < 3 (l. 15879) ;
  - `.mw_ensembles_figes()` vide sur `reserve2_trapeze` ;
  - taille de la source de la fiche, 11 787 caractères ;
  - tailles des textes proposés, 1 663 et 695 caractères.
- **Hypothèses** : références inchangées sous les pistes (a) et (b) ; douze clés inchangées sous (b) (D4 le suggère, sans le démontrer pour la loi de (b)) ; argument d'ordre de grandeur pour une colonne j ≤ J−2 au voisinage de la tolérance.
- **Non vérifiées** : effet sur la p de famille M1 et sur la p globale LC ; mesure du triangle de six années, reprise du `.tex` et du suivi sans réexécution.

**Informations manquantes** : σ̂²_0 du triangle de six années. Le texte proposé écrit donc « nul ou négligeable », sans magnitude.

**Décisions non résolues** (mainteneur) :
1. Lecture d'E2 au sens de l'ADR 0018 (« toute entrée admissible », α saisi) contre la règle à deux seuils du protocole.
2. Plafond de `mw:m1d` (relèvement à environ 12 800 caractères, ou condensation par `docwriter`).
3. Création de l'issue E3 et de l'issue E5 ci-dessous, et rattachement par `architect`.

**Critères déclenchés** (`routage.md`, § 4) :
- deux lectures d'une règle (E2 : protocole contre ADR 0018). Ce n'est pas un problème de documentation disponible ;
- changement de résultat : aucun dans JS2. Changement de p-value, et de verdict selon α, attendu dans la branche suivante.

**Constats hors périmètre**

1. **Phrase fausse sur le trapèze (E5).** `docs/latex/doc_tests_usp.tex:16405-16406` (`sec:mwm1`, (1)) écrit : « La dernière colonne, qui n'a qu'un facteur individuel, appartient trivialement à l'ensemble, sans effet puisqu'elle n'est jamais éligible ». C'est faux sur un trapèze :
   - la dernière colonne y a I − J + 1 facteurs ;
   - elle n'est dans l'ensemble que si elle est dégénérée : `.mw_ensembles_figes(mw_ajuster(trapèze de référence))$degeneres` est vide [V] ;
   - elle peut être éligible.

   Gravité : mineure ; critère E5, donc gardée. Proposition, à absorber dans le passage de `docwriter` de #617 sur accord du mainteneur : « La dernière colonne d'un carré, qui n'a qu'un facteur individuel, appartient trivialement à l'ensemble, sans effet puisqu'elle n'est jamais éligible~; celle d'un trapèze n'y entre que si elle est dégénérée. » Sinon, issue distincte.
2. **Effet sur la p de famille M1 et la p globale LC (E3 plausible, non montré).** Il faut d'abord la mesure (§ 4.4). Elle est incluse dans l'issue E3 (critère d'acceptation 4).
3. **Colonne j ≤ J−2 dégénérée au voisinage de la tolérance** : elle peut sortir du prédicat dans une réplication [H]. Effet sur la p-value attendu nul (amplitude de l'ordre de 10⁻¹²). Critère : aucun, et l'effet n'est pas montré. Le texte proposé le couvre en écrivant « amplitude négligeable ».

**Prochaine action recommandée** :
1. La session verse ce rapport.
2. Le mainteneur tranche les points 1 à 3.
3. L'issue E3 (et E5 si elle est retenue) est créée sur accord.
4. `docwriter` passe en fin de JS2 avec les textes du § 3 et la décision sur le plafond.
5. `actuary-approfondi` valide une fois `git diff main...HEAD -- docs/latex/`.
