# JS2, étape 2a (#617) : protocole court de la mesure « colonne J−1 dégénérée d'un trapèze : reste-t-elle dégénérée dans les réplications ? »

*Rédigé par l'agent `actuary-approfondi` (IA), le 25/11/2026. Versé intégralement par la session principale avant toute exécution (Q-54-10). La section 4 (règle de décision) ne se modifie plus après l'exécution ; un changement fait avant l'exécution est daté et motivé.*

> **État consulté.** Lecture seule sur `claude/jalon-js2`, tête `1ac9581` : c'est le commit `repo:` qui relève la version à 3.1.0, donc le SHA de la batterie ; le brief citait `1edb0a7`. `git diff --stat 1abac22 HEAD -- R/ tests/ app.R` est vide. md5 de `R/engine.R` : `723277ddfa5736d7411838d15d8dad00` ; md5 de `R/charger_moteur.R` : `5ed6226c768d5ad781ea03a7306ccc11`. R 4.3.3, `LC_ALL=C.UTF-8`, moteur chargé par `charger_moteur()`.
>
> **Pré-vol.** Il s'est limité aux préconditions des triangles et à la durée :
> - valeurs de σ̂², prédicat, ensembles figés ;
> - `run_engine()` accepté sur T1 à B = 99 ;
> - durée de `mw_bootstrap()` à B = 199 sur T2.
>
> **Aucune grandeur mesurée par ce protocole n'a été lue** (part des réplications, statistiques simulées, p-values). Rien n'a été écrit dans le dépôt.
>
> **Légende** : [V] vérifié (code relu à la ligne citée, ou commande exécutée) ; [H] hypothèse ; [NV] non vérifié.

## 1. Objet

La phrase en cause est dans `docs/latex/doc_tests_usp.tex`, fiche `mw:m1d`, paragraphe « Colonnes dégénérées », l. 17283-17296 :

> « la statistique observée et chaque statistique simulée (la colonne, tirée avec σ̂_j² nul ou négligeable, restant dégénérée, section boot-mw) sont multipliées par Σ' n_j / Σ n_j […]. La p-value de Monte-Carlo n'en est pas modifiée, à des égalités près de l'ordre de la tolérance ».

Elle porte deux affirmations :
- **(A1) prémisse** : une colonne dégénérée à l'observé est tirée avec σ̂_j² nul ou négligeable, et reste dégénérée dans chaque réplication ;
- **(A2) conséquence** : pour la famille α, qui garde ces colonnes, la p-value de Monte-Carlo n'est pas modifiée.

Trois questions :
- **Q1** : quelle part des réplications garde la colonne J−1 dégénérée, au sens de `.mw_colonne_degeneree()` ?
- **Q2** : l'ensemble figé écarte-t-il la colonne de chaque statistique, quelle que soit la réplication ?
- **Q3** : à laquelle des trois issues aboutit-on ?

## 2. Lecture du code (exacte ; `R/` identique à `1abac22`)

### 2.1 Simulation de la colonne J−1

- **Règle de minimum.** `mw_ajuster()`, l. 13485-13487 : σ̂²_{J−1} = min(σ̂²_{J−2}, σ̂²_{J−3}, σ̂⁴_{J−2}/σ̂²_{J−3}). L'estimateur direct, défini pour I > J, est aux l. 13510-13516. [V]
- **Choix du σ simulé.** `.mw_simulation_sigma_direct()`, l. 13861-13862, est vrai si et seulement si le triangle est un trapèze **et** sa colonne J−1 n'est pas dégénérée.
  - Colonne J−1 dégénérée : `aj_sim` vaut `aj` (l. 16416-16417).
  - `.mw_simuler_triangle_etat()` tire alors la colonne avec sg = √(règle), l. 16215-16219 : F*(i,J−1) = f̂_{J−1} + e_i·sg/√C*(i,J−1), les e_i étant tirés avec remise dans le vivier. [V]
- **Conséquence exacte.** Quand la règle est non nulle, les facteurs simulés de J−1 ne sont égaux à 1e-12 près que si les e_i/√C*(i,J−1) coïncident à environ 1e-12·f̂/sg près ; aucun mécanisme du code ne l'impose. Dans ce cas, (A1) n'est donc pas une propriété du code. Elle l'est, à l'arrondi près, quand sg = 0 ; quand sg est seulement négligeable, elle ne vaut qu'en pratique [H, mesurée sur T0].
- **Carré.** La colonne J−1 n'a qu'un facteur, et F = f̂ par la même division. Elle est donc dégénérée dans toute réplication ; avec n = 1 < 3, elle n'entre pas dans Alpha (l. 13603-13617, 15879). [V] La phrase est exacte pour le carré, mais pas pour la raison qu'elle donne : la colonne y est tirée avec la valeur de la règle, et non avec un σ̂² nul.
- **Colonne j ≤ J−2 dégénérée.** Elle est tirée avec son propre σ̂²_j, nul ou de l'ordre de l'arrondi (l. 14556-14557). C'est le cas que visait la mesure d'origine (triangle de six années, colonne j = 0, fin de branche Fq ; *selon* `docs/suivi-documentation/III-M.md`, l. 255).

### 2.2 Ensemble figé (Q2)

`.run_engine_mw()` calcule une seule fois `figes <- .mw_ensembles_figes(aj)` (l. 17945-17946) et le passe à `mw_bootstrap()`, puis à `.mw_stats()` dans chaque réplication (l. 16446). `.mw_contexte_mc()` calcule `mw_residus(aj, figes$degeneres)` (l. 16559). [V]

| Clé de `MW_CATALOGUE_MC` | Reçoit l'ensemble figé | Exclusion de la colonne figée dans une réplication | Ligne |
|---|---|---|---|
| Calendrier | oui | étiquettes « * », retirées | 14696 |
| CorrDev | oui | paire (k−1, k) sautée | 14832 |
| BP, DW, Runs, PenteIntra | par `e$res` / `e$r` | résidus de la colonne absents (`mw_residus()`) | 14615 |
| MinP4 | oui | `!(inf$j %in% jd)` | 18241 |
| Origine, HomogF, Courbure | oui | `j %in% jd` testé **avant** le prédicat courant | 15469, 15533, 15812 |
| ExpVar, KruskalAcc | oui, et `e$res` | résidus de la colonne absents | 15960-15961, 16009-16010 |
| **Alpha** | **non** | aucune : toutes les colonnes de n_j ≥ 3 | 15872-15888, 16690 |

Le vivier est `.mw_pool_residus(aj, figes$degeneres)` (l. 16404) : il ne contient pas la colonne figée. [V]

**Réponse de lecture à Q2.**
- **Oui pour douze clés sur treize et pour le vivier, quelle que soit la réplication.**
- **Non pour Alpha, par une doctrine documentée** : `mw:m1d`, l. 17283 ; l. 15851-15853 ; `.MW_LIGNES_COLONNES_ECARTEES`.

Le contrôle D4 confirme cette lecture, réplication par réplication.

### 2.3 Conséquence exacte pour Alpha

- A = Σ n_j a_j / Σ n_j, où a_j = (max_α f_j^(α) − min_α f_j^(α)) / f_j^(1) ≥ 0, sur les colonnes de n_j ≥ 3.
- A^sans est la même statistique calculée sans les colonnes de `figes$degeneres`.
- Comme a* ≥ 0, A*_b ≥ (Σ'n / Σn)·A^sans*_b dans chaque réplication, avec égalité à l'observé à a_{J−1,obs} ≈ 0 près.
- D'où **p_moteur ≥ p_sans** (queue haute), à des égalités de l'ordre de la tolérance près. La propriété est exacte ; sa grandeur n'est connue que par la mesure.
- Si n_{J−1} = 2 (I = J + 1), la colonne n'entre pas dans A, et (A2) tient quoi qu'il en soit de (A1). Exact.

## 3. Triangles (construits, déterministes, hors références)

| Nom | Construction | I, J, n_{J−1} | figes$degeneres | Règle σ̂²_{J−1} | Rôle |
|---|---|---|---|---|---|
| T1 | `triangle_mw_trapeze.csv` (= `reserve2_trapeze`) ; C(i,5) := C(i,4)·f̂_4 pour i = 0..2 (f̂_4 de l'original) | 7, 5, 3 | {4} | 0,141928 (σ̂²_3 = 0,3148 ; σ̂²_2 = 0,6981) | cas principal : règle non nulle, colonne dans Alpha |
| T2 | colonnes j0 à j4 de `triangle_mw.csv` ; C(i,4) := C(i,3)·f̂_3 pour i = 0..3 | 7, 4, 4 | {3} | 0,684464 | n_{J−1} = 4 : la colonne tombe dans le domaine de MinP4, HomogF et Courbure (n ≥ 4), ce qui donne à D4 de l'objet pour ces clés |
| T0 | T1, puis colonne 2 rendue dégénérée : pour i = 0..4, C(i, 3..5) × f̂_2·C(i,2)/C(i,3) (f̂_2 de T1 ; facteurs des colonnes 3 et 4 inchangés) | 7, 5, 3 | {2, 4} | 7,83e-29 | témoin du cas visé par la phrase (σ̂² négligeable), pour j = 2 ≤ J−2 et pour j = J−1 |

**Préconditions** [V, pré-vol] : prédicat vrai ; cas `"degenere"` ; estimateur direct à 0 (T1, T2) ou 1,2e-28 (T0) ; ensembles non identifiables vides (T1, T2) ; `run_engine()` accepte T1.

**Pourquoi construire ces triangles.** Aucun jeu de `tests/donnees/` n'a de colonne J−1 dégénérée : sur `reserve2_trapeze`, σ̂²_dir = 0,0973. Modifier la seule dernière colonne :
- ne touche que les facteurs de J−1 ;
- ne touche ni σ̂²_{J−2} ni σ̂²_{J−3}, donc pas la règle ;
- laisse tout le reste identique au cas de référence.

**Paramètres.** B = 999 et graine 20260831, défauts de `run_engine()`. La graine est posée par `engine_sous_graine()` dans `mw_bootstrap()` ; le script ne tire rien lui-même.

## 4. Règle de décision (figée avant l'exécution)

**Notations.**
- R : réplications pour lesquelles `.mw_stats()` a rendu un résultat (journal du crochet).
- π̂_j : part de R où `.mw_colonne_degeneree(ab, j)` est vrai, pour chaque j de `figes$degeneres`.
- p_moteur = `res$bootstrap$p_mc[["Alpha"]]`.
- p_sans = `engine_p_mc(A^sans*, A^sans_obs, "haut")$p_mc`.
- Δp = p_moteur − p_sans.

### 4.1 Validité de la mesure

Si l'un de ces points échoue, la mesure ne permet aucune conclusion : le script est repris, puis repasse l'audit léger.

- **P1 à P6** :
  - P1 : `ok = TRUE` ;
  - P2 : I > J ;
  - P3 : J−1 ∈ `figes$degeneres` ;
  - P4 : cas `"degenere"` ;
  - P5 : règle > 1e-6 pour T1 et T2, ≤ 1e-20 pour T0 ;
  - P6 : n_{J−1} ≥ 3.
- **I1** : `identical()` entre les deux exécutions, avec et sans crochets, sur `res$bootstrap` et sur `engine_table_tests(res)`.
- **I2** : les 13 statistiques du journal sont `identical()`, dans l'ordre, aux lignes de `stats_boot` qui ne sont pas entièrement NA, et |R| est égal au nombre de ces lignes.
- **I3** : sur les 50 premières réplications, `.mw_stats(ab, figes, replique = TRUE, combn = <environnement neuf>)` redonne le journal à l'identique.
- **I4** : les crochets sont retirés : `identical(get(".mw_stats", env), orig)`, et de même pour `.mw_tirer_triangle_valide`.
- **I5** : le md5 de `R/engine.R` est celui de l'en-tête, et `git status --porcelain -- R/ tests/ app.R` est vide.

### 4.2 Contrôles de doctrine

Un seul échec, sur un seul triangle, donne l'issue 3.

- **D1** : à chaque appel de `.mw_tirer_triangle_valide()`, `aj$sigma2[J]` vaut la règle de l'observé, et non l'estimateur direct.
- **D2** : l'objet `figes` reçu par `.mw_stats()` dans chaque réplication est `identical()` à `.mw_ensembles_figes(aj)` de l'observé.
- **D3** : la longueur du vivier reçu est égale à `nrow(mw_residus(aj, figes$degeneres))`, et cette table n'a aucune ligne j ∈ `figes$degeneres`.
- **D4** : dans chaque réplication de R, on forme tb_deg, le triangle de la réplication avec C*(i,J) := C*(i,J−1)·f̂*_{J−1} pour i = 0..I−J. Seules ces cellules changent : la colonne J−1 seule, ce qui est sans effet sur les autres colonnes.
  - Les 12 clés autres qu'Alpha doivent être `identical()` entre le journal et `.mw_stats(mw_ajuster(tb_deg), figes, TRUE, <environnement neuf>)`.
  - Tolérance : si les valeurs ne sont pas identiques mais que chaque écart est ≤ 1e-12 × max(1, |x|), sans passage NA ↔ valeur et sans bascule d'indicateur de dépassement par rapport à l'observé (selon la queue du catalogue ; pour « deux », les deux indicateurs), on ne conclut pas à l'issue 3 et on rapporte le point à la lecture 2c. Sinon, c'est l'issue 3.
- **D5** (lecture, et non contrôle de doctrine) : la ligne j = J−1, de poids n_{J−1}, figure dans `mw_famille_alpha(ab)$detail` de chaque réplication. Un échec est rapporté et lu en 2c.

### 4.3 Les trois issues

Ordre de priorité : 3, puis 2b, puis 2a, puis 1. L'issue globale est la plus haute observée sur les trois triangles.

- **Issue 1 — phrase exacte.** P, I et D sont verts ; π̂_{J−1} = 1 sur T1 et T2 ; Δp = 0 sur T1, T2 et T0. Le `.tex` ne change pas, et une note de constat va dans `docs/suivi-documentation/`.
- **Issue 2 — phrase inexacte.** P, I et D sont verts, et l'on observe π̂_{J−1} < 1 sur T1 ou T2, ou Δp ≠ 0 sur l'un des triangles. Un texte est proposé à `docwriter` (§ 8) et finalisé en 2c.
  - **2a** : Δp = 0 partout. Seule (A1) est fausse pour J−1 ; (A2) tient sur ces triangles (constat de simulation), et pour toute entrée quand n_{J−1} = 2 (exact).
  - **2b** : Δp ≠ 0 sur T1 ou T2. (A1) et (A2) sont fausses dans ce cas. S'y ajoute un constat ADR 0018 :
    - E3 ;
    - E2 aussi si p_moteur et p_sans tombent de part et d'autre de 0,10 ou de 0,05 sur un triangle.

    L'issue est rédigée au compte rendu de 2c, créée sur accord et placée dans la branche suivante. JS2 ne touche pas au moteur.
  - Sur T0 : si π̂_2 ou π̂_4 < 1, la phrase doit aussi nuancer « négligeable » ; si Δp ≠ 0, on traite comme en 2b.
- **Issue 3 — défaut du moteur (PJ-1).** Échec de D1, D2, D3 ou D4, au sens du § 4.2. On s'arrête, selon la fiche JS2, point d'arrêt PJ-1.

### 4.4 Lecture de l'exemple de PJ-1 (à confirmer avant l'exécution)

Je ne classe pas 2b en PJ-1. Trois raisons :
- Alpha ne reçoit pas l'ensemble figé, par une doctrine documentée ;
- la simulation de J−1 dégénérée par la règle est une décision (V2, 25/11) ;
- ce qui est en défaut, c'est la propriété que le `.tex` attribue à cette doctrine, et non le moteur.

Prise à la lettre, la phrase d'exemple de PJ-1 (« une colonne dégénérée à l'observé entre dans une statistique d'une réplication ») couvrirait pourtant Alpha. Si le mainteneur retient cette lecture, 2b devient PJ-1. Cette lecture se décide avant l'exécution.

> **Décision du mainteneur, 25/11/2026, avant l'exécution (O1)** : lecture (a) retenue. L'effet sur Alpha est classé en issue 2b (phrase inexacte, constat ADR 0018), et non en PJ-1 ; le § 4.3 s'applique tel qu'écrit. *Ajout de la session principale.*

## 5. Spécification du script (pour `coder`, fiche de base)

**Fichiers.**
- `docs/revues/20261125-js2-jalon/mesure-617/mesure_617.R` ;
- `sortie_mesure_617.txt` ;
- `README.md` court : commande, montage, renvoi à ce protocole.

Aucun fichier de `R/`, `tests/` ni `app.R` n'est modifié. La sortie est en texte ASCII sans accents.

**Commande**, depuis la racine :

```
LC_ALL=C.UTF-8 Rscript docs/revues/20261125-js2-jalon/mesure-617/mesure_617.R > docs/revues/20261125-js2-jalon/mesure-617/sortie_mesure_617.txt 2>&1
```

Options, avec leurs défauts : `--B=999`, `--graine=20260831`, `--triangles=T1,T2,T0`. Avec B < 999, l'en-tête porte « ESSAI, NON VERSABLE ».

**Chargement.**
- Contrôler la racine (`file.exists("R/engine.R")`).
- `source("R/charger_moteur.R"); charger_moteur()`, puis `env <- environment(run_engine)` (ADR 0016).
- Lire les CSV comme `tests/outils_tests.R`, l. 76-91 (`read.csv`, colonnes hors « i », mode `double`, `unname`) : code recopié, et non fichier sourcé.
- Construire les triangles exactement selon le § 3, avec les f̂ de `mw_ajuster()`.

**Étapes, pour chaque triangle.**

1. **En-tête** : triangle imprimé en `format(x, digits = 17)`, σ̂², estimateur direct, `figes`, n_j.
2. **Préconditions** P1 à P6.
3. **Exécution sans crochets** : `res0 <- run_engine(methode = "reserve2", triangle = tri, segment = 1, annexe = "II", date_reference = "2026-12-31", B = B, seed = graine)`.
4. **Crochets posés dans `env`**, sans aucun tirage, retirés par `on.exit` ou `tryCatch(finally = )` :
   - `.mw_stats(aj, figes = NULL, replique = FALSE, combn = NULL)` : appelle l'original ; si `isTRUE(replique)`, ajoute `list(tri = aj$tri, figes = figes, stats = <résultat>)` au journal ; rend le résultat inchangé.
   - `.mw_tirer_triangle_valide(aj, pool, reste)` : enregistre `aj$sigma2[aj$J]`, `length(pool)` et le vivier une fois ; rend le résultat de l'original inchangé.
5. **Même appel avec crochets** (`res1`), puis retrait des crochets. Contrôles I1 et I4.
6. **Contrôles** I2, D1, D2, D3.
7. **Par réplication** : `ab <- mw_ajuster(tri)`. Pour chaque j ∈ `figes$degeneres` : le prédicat, le volet qui l'établit (écart ≤ 1e-12, ou aplatissement) et `.mw_ecart_facteurs(ab, j)$ecart`. Relever aussi `mw_famille_alpha(ab)$detail`.
8. **I3** sur les 50 premières réplications ; **D4** sur toutes ; **D5**.
9. **M1**. Pour chaque j figé :
   - π̂_j = k/|R| ;
   - intervalle de Clopper–Pearson à 95 % (`stats::binom.test(k, n)$conf.int`) ;
   - décompte par volet ;
   - quantiles 0, 0,01, 0,5, 0,99 et 1 de log10(écart), en écrivant « 0 » pour un écart nul.
10. **M2**.
    - A^sans_obs et A^sans* sont calculés sur `detail`, privé des lignes j ∈ `figes$degeneres` : Σ'n·a / Σ'n.
    - p_sans par `engine_p_mc(·, ·, "haut")`.
    - Imprimer p_moteur, `err_mc`, Δp, N_moteur = #(A* ≥ A_obs), N_sans et le nombre de bascules.
    - Imprimer les quantiles de q_b = n_{J−1}·a*_{J−1} / Σ n_j a*_j.
    - Vérifier que `res0$bootstrap$stats_obs$Alpha` est identique à `mw_famille_alpha(aj)$stat`.
    - Le verdict de la ligne Alpha dans `engine_table_tests(res0)` est imprimé à titre d'information.
11. **Issue mécanique selon le § 4.3**, imprimée avec la valeur de chaque critère : 1, 2a, 2b, 3, ou « sans conclusion ». Puis l'issue globale.

**Pied de sortie** : durée, `R.version.string`, `RNGkind()`, `git rev-parse HEAD`, md5 de `R/engine.R`, de `R/charger_moteur.R` et du script.

**Durée visée** : 3 à 5 minutes [H]. Au pré-vol, `mw_bootstrap()` à B = 199 a pris 2,8 s sur T2, et `run_engine()` à B = 99 a pris 4,4 s sur T1. Le script fait deux `run_engine()` par triangle et environ 2 × |R| appels à `.mw_stats()`.

**Points de l'audit léger** :
- I1 à I5 sont effectivement codés ;
- les crochets ne tirent rien et sont retirés même en cas d'erreur ;
- D4 ne modifie que les cellules (i, J), i ≤ I−J ;
- A^sans exclut exactement `figes$degeneres` ;
- p_sans passe par `engine_p_mc()`.

## 6. Ce qui est exact, ce qui est observé, ce qui ne se transpose pas

- **Exact** (lecture du code, § 2) :
  - la simulation de J−1 dégénérée par la règle ;
  - l'exclusion par l'ensemble figé dans douze clés et dans le vivier, quelle que soit la réplication ;
  - l'absence d'ensemble figé pour Alpha ;
  - p_moteur ≥ p_sans ;
  - la phrase exacte pour le carré (n = 1) ;
  - l'absence d'effet sur Alpha quand n_{J−1} = 2.
- **Observé par simulation** (fonction de B, de la graine et des trois triangles construits) :
  - π̂_j, avec un intervalle de Clopper–Pearson qui ne couvre que l'erreur de Monte-Carlo (0/999 donne une borne supérieure d'environ 0,0037) ;
  - Δp, N_moteur − N_sans et q_b. Δp est apparié sur les mêmes réplications : la comparaison ne porte pas d'aléa entre deux tirages, mais sa grandeur dépend de B et de la graine (p_moteur et p_sans ont chacune une erreur d'environ √(p(1−p)/B)).
- **Ne se transpose pas** :
  - la grandeur de Δp, qui dépend de la règle rapportée aux amplitudes des autres colonnes, de n_{J−1}, des cumuls et du vivier ;
  - toute conclusion de niveau ou de puissance de la ligne Alpha : aucun plan sous H0 ;
  - la lognormale.

  En revanche, « la colonne J−1 n'est en général plus dégénérée » est structurel (§ 2.1) : la mesure l'illustre, elle ne le fonde pas.

## 7. Prédictions écrites avant l'exécution [H]

- **T1 et T2** : π̂_{J−1} = 0 sur |R| ; Δp ≥ 0, attendu strictement positif ; D1 à D4 verts. Issue attendue : **2b**, sous la lecture du § 4.4.
- **T0** : π̂_2 = π̂_4 = 1 (σ_sim ≈ 9e-15, écart attendu de l'ordre de 1e-16) ; Δp = 0.

Une prédiction démentie n'est pas en soi un défaut : elle est lue en 2c.

## 8. Texte proposé à `docwriter` (issue 2 ; finalisé en 2c avec les chiffres)

Forme indicative, en remplacement de la parenthèse et de la phrase suivante, l. 17289-17296 :

« … mais son poids reste au dénominateur. Une colonne $j \le J-2$, tirée avec son propre $\hat\sigma_j^2$, nul ou négligeable, reste dégénérée dans les réplications [T0 : …] : la statistique observée et chaque statistique simulée sont multipliées par $\sum' n_j/\sum_j n_j$, et la p-value de Monte-Carlo n'en est pas modifiée, à des égalités près de l'ordre de la tolérance ; seule la valeur restituée de $A$ est diminuée (triangle de six années …, inchangé). La colonne $J-1$ d'un trapèze, dégénérée à l'observé, est tirée avec la valeur de la règle de minimum (section~\ref{sec:boot-mw}) ; quand celle-ci n'est pas négligeable, la colonne simulée n'est en général plus dégénérée [constat : … sur … réplications, $8\times6$ construit]. Si elle compte au moins trois facteurs, son amplitude, nulle à l'observé, entre dans chaque statistique simulée : la p-value de Monte-Carlo est au moins égale à celle de la statistique calculée sans la colonne (propriété exacte, l'amplitude étant positive ou nulle), dans le sens conservateur [constat : … contre …, $B = 999$, graine 20260831] ; ni le niveau ni la puissance ne sont mesurés dans ce cas. La colonne $J-1$ d'un carré, qui n'a qu'un facteur, est dégénérée dans toute réplication et n'entre pas dans $A$. »

**Contraintes pour `docwriter`.**
- Respecter `CONVENTIONS.md` : ni SHA ni numéro d'issue dans le `.tex`.
- L'historique va dans `docs/suivi-documentation/III-M.md`, sous `mw:m1d`.
- « restant dégénérée » n'apparaît qu'à la l. 17291 [V, grep].
- Les l. 1889-1890, 6551 et 6574, 15851-15853 et 16421-16427 sont cohérentes avec le code [V, lecture] : pas de changement, sauf si la lecture 2c en décide autrement.

## 9. Points ouverts

- **O1** : la lecture de PJ-1 retenue au § 4.4 est à confirmer par le mainteneur avant l'exécution. *Confirmée le 25/11 (§ 4.4).*
- **O2** : la tête est `1ac9581`, et non `1edb0a7` ; `R/` est identique, sans effet sur la mesure.
- **O3** : en cas d'issue 2b, l'issue de la branche suivante pourra comparer deux voies :
  - passer l'ensemble figé à Alpha ;
  - simuler J−1 dégénérée avec l'estimateur direct, ce qui reviendrait sur V2.

  Hors de JS2.
- **O4** : T0 ne couvre qu'une seule grandeur de σ̂² négligeable (7,8e-29). Dans le texte, « négligeable » reste un constat, et non une borne.
