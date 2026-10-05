# Spécifications de la branche E2 réduite (Merz-Wüthrich)

Ce fichier rassemble les spécifications d'`actuary` des issues de la branche de travail parallèle **E2 réduite** (`claude/merz-wuthrich-parallele`). Cette branche a été décidée par le mainteneur le 05/10/2026 : ADR 0007, annotation du 05/10/2026, et `docs/feuille-de-route.md`, § 3, fiche « Branche E2 réduite ». Les spécifications ont été demandées en préalable (condition C1, décision Q-E2p-4) et consignées par la session principale avant le lancement de la branche. Chacune est aussi publiée en commentaire de son issue.

- Ordre de la branche : #185, #192, #152, #60, #50, #115, #46, #90, #89.
- #185 était déjà spécifiée (commentaire du 02/10 sur l'issue) ; elle n'est pas reprise ici.
- **Lot A** : #152, #60, #50, #192.
- **Lot B** : #115, #46, #90, #89.

**Statut** : avis d'`actuary`, à trancher par le mainteneur. Chaque spécification se termine par ses questions numérotées Q-E2r-<issue>-n, et aucune n'est encore décidée. Les décisions seront consignées au § 4 de la feuille de route, sur la branche E2 réduite. Les mesures ont été faites hors plateforme CI (Linux, R 4.3.3, BLAS de référence, `main` `979ca62`), et les scripts de prototype sont restés hors dépôt : la CI doit confirmer les effets annoncés sur `reserve2`.

---

## Lot A — #152, #60, #50, #192

> *Rédigé par l'agent actuary (IA)*, `actuary-approfondi`, 05/10/2026.

**Ordre et dépendances au sein du lot.**
- **#192 précède #60.** Une fois #60 en place, un triangle totalement dégénéré n'a plus aucun résidu de Mack, et le bootstrap tomberait dans un « défaut de calcul intercepté ». Le refus de #192 rend ce cas inatteignable.
- **Le critère conjoint `ta_deg` ≡ `ta_bruit` ne tient qu'avec #152 et #60 réunis** (voir #60, critère 3).

### #152 — Ex æquo des statistiques de rang de Merz-Wüthrich

**(a) Constat, re-mesuré.**
- **Quatre sites sont à égalité flottante stricte** (les quatre de l'issue et de son commentaire) :
  - `mw_stat_correlation_dev()` : `rank()` sur F ;
  - `mw_test_homogeneite_f()` : `cor.test(F, idx, spearman)` ;
  - `mw_test_exposant_variance()` : `cor.test(|r|, C, spearman)` ;
  - `mw_test_annees_calendaires()` : classement L / S / « * » par la médiane de F.
- **Un cinquième site manque à la liste** : `mw_test_homogeneite_accident()` (`kruskal.test` sur les résidus de Mack, `R/engine.R` l. 6830).
- **Le défaut est réel sur F.** Des facteurs égaux en décimal sont souvent distincts en flottant. Un tirage de paires (a → b, k·a → k·b) au centime en produit 5 sur 13 essais, par exemple 872,78 → 1 228,87 contre 5 236,68 → 7 373,22, avec un écart relatif de 1,6e-16. Sur un triangle construit avec cette paire en colonne 0, trois statistiques changent après aplatissement :

  | Statistique | Avant | Après |
  |---|---|---|
  | Calendrier | −0,948 | −0,655 |
  | CorrDev | −0,331 | −0,310 |
  | HomogF | 5,95 | 6,31 |

  Le rang flottant (4, 3) devient le rang moyen (3,5 ; 3,5).
- **Sur C et |r|, l'enjeu pratique est nul.** Un ex æquo n'y naît que de cumuls calculés en amont.
- **Écarts minimaux sur `reserve2`** :

  | Grandeur | Écart minimal |
  |---|---|
  | F | 4,1e-3 |
  | C, par colonne (relatif) | 1,5e-2 |
  | \|r\|, par colonne | 1,1e-2 |
  | r, global | 2,1e-3 |

**(b) Spécification.** Aplatir par `engine_aplatir_ex_aequo()`, appelée **sans être modifiée**, avant tout `rank`, `cor.test`, `kruskal.test`, médiane ou `sd() == 0`. Les planchers diffèrent selon la grandeur.

| Grandeur | Sites | Plancher | Motif |
|---|---|---|---|
| **F** | `mw_stat_correlation_dev()` (Fk et Fk1 séparément, garde `sd()` sur les valeurs aplaties), `mw_test_homogeneite_f()`, `mw_test_annees_calendaires()` (médiane sur F aplati ; une valeur égale à la médiane reçoit « * ») | **0**, recommandé | F est un rapport strictement positif, et la justification de `TOL_EX_AEQUO` est relative ; même sens que #187 pour r_t. Les deux planchers donnent `reserve2` identique (mesuré). |
| **C** | `mw_test_exposant_variance()` | **0** | Montant saisi, tolérance relative, invariance d'unité. Avec le plancher 1, des montants < 1 recevraient une tolérance absolue : c'est le défaut de #187. |
| **\|r\|** et **r** | `mw_test_exposant_variance()`, `mw_test_homogeneite_accident()` | **1** | Comme les résidus de Mack de #112. |

Pour le plancher 1 de r, aucune borne n'est établie. Le bruit de r croît comme ε·F/|F − f| : sur `reserve2`, une perturbation de 4 ulps d'un C produit 6,6e-14, soit une marge de 15 seulement sous 1e-12.

Nature des p-values : inchangée. Ces lignes n'ont que des p-values Monte-Carlo, calculées avec la même règle à l'observé et dans les réplications. Aucune p exacte ni p_min n'est en jeu à T = 8.

**(c) Critères d'acceptation.**
1. Les cinq sites aplatissent avec le régime de (b), avant `rank`, `cor.test`, `kruskal.test`, `median` et `sd() == 0`.
2. **Triangle construit** :
   - C(·,0) = (5 236,68 ; 872,78 ; 800 ; 1 500 ; 2 200 ; 950 ; 1 800 ; 1 200), avec C(0,1) = 7 373,22 et C(1,1) = 1 228,87 ;
   - autres facteurs de la colonne 0 : 1,20, 1,30, 1,50, 1,55, 1,60 ;
   - colonnes suivantes arrondies au centime ;
   - un `stopifnot()` garde F(0,0) ≠ F(1,0) en flottant.

   Attendus :
   - rangs (3,5 ; 3,5) ;
   - étiquettes « * » pour les deux facteurs ;
   - statistiques égales à une recomputation indépendante sur `signif(F, 12)` ;
   - statistiques du catalogue identiques à celles de `mw_tests()`.
3. **Invariance.** Sur `triangle_mw.csv` avec C(4,1) = C(3,1) et C(4,2) = C(3,2), multiplier C(4,1) par (1 + 4ε) laisse les cinq statistiques `identical()`.
4. Sur un triangle de contrôle sans ex æquo, les statistiques sont identiques.
5. `tests/test_reproductibilite.R` : les cinq références sont identiques.

**(d) Effet sur `reserve2`.** Identique, mesuré à B = 999 avec les deux planchers pour F : `comparer_objets()` conforme, 0 feuille différente. Aucun visa.

**(e) Circuit.** Circuit 1 : `actuary` → `coder` → `audit` → `docwriter` (en fin de branche) → `actuary` valide.

**(f) Surface documentaire.**
- `.tex` :
  - section des ex æquo (l. ~2023-2050) ;
  - fiches M2, M3 et M1b ;
  - tableau l. ~1823-1849.
- `CONTEXT.md` : entrée « Ex æquo ».
- En-tête de `TOL_EX_AEQUO`.

**(g) Questions au mainteneur.**
- **Q-E2r-152-1.** L'en-tête de `TOL_EX_AEQUO` est hors des fonctions `mw_*` (périmètre C3), et #187 (E1f) le modifie aussi. Deux options :
  - (a) autoriser E2 réduite à modifier les seules lignes « Périmètre » et « Restent à égalité EXACTE », comme commentaire pur, la branche fusionnée en second résolvant le conflit (*recommandé*) ;
  - (b) reporter cette mise à jour à un correctif rapide après les deux fusions.
- **Q-E2r-152-2.** Inclure le cinquième site, Kruskal-Wallis ? *Recommandation : oui.*
- **Q-E2r-152-3.** Plancher 0 pour F, aligné sur #187 (*recommandé*), ou plancher 1 comme le propose l'issue ?
- **Q-E2r-152-4.** Le périmètre C3 couvre-t-il le passage de `docwriter` sur le `.tex` et `CONTEXT.md` ?

### #60 — Exclusion des résidus de Mack d'une colonne dégénérée

**(a) Constat, re-mesuré.**
- `mw_residus()` exclut une colonne sur σ̂²_j ≤ 0 **exact**, alors que le prédicat unique `.mw_colonne_degeneree()` de #56 détecte à 1e-12 en relatif. Sur `ta_bruit`, dont la colonne 4 est constante à 1e-14, 44 résidus sont gardés au lieu de 39 pour `ta_deg`, et l'avertissement de #33 n'est pas émis.
- **Constat nouveau : le défaut touche aussi les colonnes exactement dégénérées, dans les réplications.**
  - La colonne est exclue à l'observé.
  - Dans chaque réplication, sa valeur simulée vaut C·f/C ≠ f au bit près, avec un σ̂²* de bruit > 0. Ses résidus de bruit entrent donc dans les statistiques simulées.
  - Le nombre de résidus N diffère alors entre l'observé et le simulé.
  - Mesuré à B = 999 sur `ta_deg` : la statistique observée est inchangée, mais les p_mc changent (DW 0,880 → 0,984 ; Runs 0,960 → 1,000 ; ExpVar 0,562 → 0,461). Même effet sur `tri_sym`.
- **Question M1 de l'audit.** L'ordonnée à l'origine est déjà réglée par #56. Pour la famille α, la statistique est définie sur une colonne dégénérée : l'amplitude vaut 0, ce n'est pas 0/0. La loi simulée est cohérente avec l'observé, et après #60, Alpha est identique entre `ta_deg` et `ta_bruit`. **Avis : ni exclusion ni signalement propre pour α.**

**(b) Spécification.**
- **Exclusion.** Dans `mw_residus()`, une colonne j ayant au moins 2 facteurs est exclue si σ̂²_j n'est pas fini ou est ≤ 0, **ou** si `.mw_colonne_degeneree(aj, j)` est vrai.
  - Le test `length(idx) < 2` reste placé **avant** : la colonne J−1 est toujours « dégénérée » au sens du prédicat, et ne doit pas être comptée comme exclue.
  - L'attribut `colonnes_exclues` garde sa forme.
- **Gel à l'observé, deux variantes.**
  - **(a) Prédicat seul.** Entièrement dans le périmètre C3.
  - **(b) Ensemble gelé à l'observé, comme M1 (#56).** `mw_residus(aj, j_degeneres = NULL)` ; `.mw_contexte_mc()`, `mw_test_exposant_variance()` et `mw_test_homogeneite_accident()` reçoivent l'ensemble `jd` gelé par `mw_bootstrap()`. Il faut aussi modifier deux entrées de `MW_CATALOGUE_MC` (`ExpVar` et `KruskalAcc` passent `e$j_degeneres`).
  - Comparaison mesurée :
    - les deux variantes sont identiques sur `ta_deg`, `ta_bruit`, `tri_sym` et `t5` (B = 999) ;
    - dans la bande où l'écart observé vaut 4,5e-13, 10 réplications sur 999 rendent la colonne non dégénérée sous (a) ;
    - l'écart entre (a) et (b) reste |Δp| ≤ 0,006, sous l'erreur Monte-Carlo, sans verdict changé ;
    - (b) reproduit exactement `ta_deg` et suit la doctrine de #56.
- **Avertissement de `mw_valider_ajustement()`.**
  - Reformuler en « à facteurs individuels tous égaux à f_j à 1e-12 près en relatif (sigma2_j nul ou numériquement nul) ».
  - Question Q1 de l'audit : ajouter une phrase disant que le pool du bootstrap ne contient que les résidus retenus. Ce pool sert aux p-values Monte-Carlo de M1 à M4 et à l'IC bootstrap de σ.
- **Nature des p-values** : Monte-Carlo, inchangée.

**(c) Critères d'acceptation.**
1. `ta_bruit` : colonne 4 exclue (39 résidus) et avertissement émis.
2. Le test existant « Colonne détectée avec σ² > 0 » (`t5`, `test_merz_wuthrich.R` l. ~361-372) est **inversé** : `sum(mw_residus(a)$j == 3) == 0`, avertissement présent. La chaîne `av_exclues()` (l. ~398) suit la nouvelle formulation.
3. **Critère conjoint, après #152** (mesuré à B = 999) :
   - verdicts de `run_engine(ta_deg)` et de `run_engine(ta_bruit)` identiques ;
   - p retenues égales à `TOLERANCE` près sur toutes les lignes ;
   - pour comparaison, avec #60 seul, Calendrier (0,168 / 0,290) et CorrDev (0,116 / 0,664) diffèrent ; sans #60 ni #152, 15 lignes diffèrent.
4. Si la variante (b) est retenue : sur `ta_deg` perturbé à 4e-13, les p-values sont égales à celles de `ta_deg`.
5. Aucun avertissement R (test existant l. ~744-758).
6. `mw_residus()` est non vide pour tout triangle accepté, ce que garantit #192.
7. `reserve2` identique.

**(d) Effet sur `reserve2` et visa.**
- `reserve2` est identique, **mesuré pour la variante (a)**. Pour la variante (b), l'identité est attendue mais **non mesurée**.
- Des verdicts changent sur des triangles d'essai, avec la variante (a) :
  - `ta_bruit` : Lilliefors ECHEC → ALERTE (p 0,0105 → 0,0976) ;
  - `t5` : famille α ALERTE → OK (p 0,076 → 0,100), suites ALERTE → OK, Shapiro-Wilk ALERTE → OK.
- Le visa M3 est à décider (Q-E2r-60-3). Il n'a pas été vérifié si `ta_deg` ou `t5` sont cités dans le `.tex`.

**(e) Circuit.** `actuary` → mainteneur (Q-E2r-60-1 à 3) → `coder` → `audit` → `docwriter` → `actuary` valide les p-values.

**(f) Surface documentaire.**
- `.tex` :
  - fiche « colonnes dégénérées » / M1 ;
  - section du bootstrap Merz-Wüthrich (pool) ;
  - toute mention « σ̂²_j = 0 exact ».
- `CONTEXT.md` :
  - « Colonne dégénérée (Merz-Wüthrich) » : retirer la divergence transitoire « à aligner par #60 » ;
  - « Contrôle de validité ».
- Commentaires de `mw_residus()` et de `.mw_colonne_degeneree()`.

**(g) Questions au mainteneur.**
- **Q-E2r-60-1.** Variante (b), avec gel et deux entrées de `MW_CATALOGUE_MC` modifiées, ce qui étend C3 à cette constante propre à Merz-Wüthrich (*recommandé*) ? Ou variante (a), dans le périmètre, avec un écart résiduel mesuré ≤ 0,006 dans la bande (≈3e-13 ; 1e-12] ?
- **Q-E2r-60-2.** Ajouter à l'avertissement la phrase sur le pool du bootstrap ? *Recommandation : oui.*
- **Q-E2r-60-3.** Les changements de verdict sur `ta_bruit` et `t5` appellent-ils un visa M3 ?

### #50 — Vérification indépendante de la MSEP par matrice de coefficients

**(a) Constat.** `msep_reglement()` décalque `mw_msep()`. La seule ancre externe est `ChainLadder::CDR` sur Taylor & Ashe : 1 778 967,66335758, valeur générée hors CI par `tests/unitaires/generer_valeurs_externes.R`.

**(b) Spécification (tests seuls).**
- **Fonction `msep_matrice(tri)`**, définie dans `test_merz_wuthrich.R` et calculée à partir du **triangle brut**, sans aucun appel au moteur. Elle recalcule f̂_j, σ̂²_j (extrapolation de D(5)(d)(ii) réécrite), Q_j = σ̂²_j/f̂_j², S_j, S'_j, C(I−j, j) et les ultimes Ĉ(i,J).
- **Forme matricielle, sans les Δ_i du moteur.**
  - Matrice A de taille I × J, pour i = 1..I et j = 0..J−1 :
    - a_ij = 1 si j = I − i ;
    - a_ij = C(I−j, j)/S'_j si j > I − i ;
    - a_ij = 0 sinon.
  - D_j = Q_j·(1/C(I−j, j) + 1/S_j) et u = (Ĉ(i,J)).
  - **MSEP = Σ_j D_j·(Aᵀu)_j².**
- **Fondement : dérivation élémentaire**, déjà établie dans l'avis d'`actuary` sur #7 (commentaire 5773233284, § 1.1).
  - a_ij est la dérivée de ln Ĉ^{I+1}(i,J) par rapport à ln F(I−j, j), au point F = f̂.
  - Ce n'est pas une citation de Merz et Wüthrich (2008), que l'agent n'a pas ouvert.
- **Contrôle optionnel : A par différentiation numérique.** On obtient A par différences centrées sur un chain-ladder élémentaire. Ce contrôle ne suppose pas la forme fermée des coefficients.
- **Statut.**
  - Ce sont des vérifications **numériques** d'une même définition, la MSEP du texte consolidé.
  - Ce n'est **pas** une validation statistique de la MSEP à T = 8 : c'est une approximation linéaire dont la qualité à T = 8 n'est établie par aucun résultat identifié.

**(c) Critères d'acceptation**, mesurés sur prototype.
1. `msep_matrice()` = `mw_msep()$msep` à 1e-12 près en relatif, sur trois triangles :
   - Taylor & Ashe (écart mesuré 1,5e-16) ;
   - `triangle_mw.csv` (écart 0) ;
   - `tri_deg` (écart 0).
2. √`msep_matrice(ta)` = 1 778 967,66335758 à 1e-12 près (écart mesuré 2,5e-15).
3. Aucun appel à `mw_*` ni à `aj$…` dans `msep_matrice()`, à vérifier en revue.
4. Sensibilité : `msep_matrice()` diffère d'au moins 1e-3 en relatif de la formule fautive historique, recalculée localement.
5. Si le contrôle optionnel est retenu, avec h = 1e-4 : écart ≤ 1e-8 à `mw_msep()` (mesuré 3,0e-10 / 2,6e-10 / 1,1e-10), avec une convergence en h².

**(d) Effet sur `reserve2`.** Aucun : ce sont des tests seuls. Aucun visa.

**(e) Circuit.** `actuary` → `coder` → `audit` → `docwriter` (pour la seule mention dans l'encadré de validation).

**(f) Surface documentaire.** `.tex`, section `sec:verif` :
- tableau l. ~11115-11140 ;
- encadré « Sur quoi repose la validation de la MSEP à un an » (l. ~11150-11165) : passer de deux voies à trois ;
- point 4 des limites (l. ~11770), à garder.

**(g) Questions au mainteneur.**
- **Q-E2r-50-1.** Ajouter un deuxième triangle publié (MW2008 de `ChainLadder`), avec sa valeur `CDR` générée par `generer_valeurs_externes.R` sur un poste où `ChainLadder` est installé ? Ni le jeu ni sa valeur n'ont pu être vérifiés ici (proxy) : aucune valeur n'est proposée.
- **Q-E2r-50-2.** Inclure le contrôle par différentiation numérique ? *Recommandation : oui.*

### #192 — Triangle totalement dégénéré restitué avec ok = TRUE

**(a) Constat, re-mesuré** (B = 99, segment II-1).
- **`total_exact`** (F(i,j) = f_j de `reserve2`) :
  - `ok = TRUE` ;
  - MSEP = 3,8e-23, σ estimé = 6,82e-16 ;
  - σ_USP = 0,0369 = (1 − 0,59)·0,09 ;
  - 16 résidus de Mack de pur bruit.
- **Constat nouveau : `total_f_binaire`** (facteurs exactement représentables, σ̂²_j = 0 exact) :
  - le pool de résidus est vide ;
  - une erreur R survient dans `engine_aplatir_ex_aequo()` via `test_runs` ;
  - `ok = FALSE` par défaut de calcul intercepté.
- Le même objet sort donc sous **deux régimes de sortie différents**, selon l'arrondi. Après #60, le premier cas basculerait aussi en défaut intercepté.
- **Résultat exact (élémentaire, à partir de la forme de #50).**
  - On a v_j > 0, d'où : MSEP = 0 ⇔ σ̂²_j = 0 pour j = 0..J−2 ⇔ facteurs identiques dans chaque colonne ayant au moins 2 facteurs. D(4) donne alors littéralement σ_USP = (1 − c)·σ(res,s).
  - La valeur n'est pas numériquement fausse. Le défaut est ailleurs :
    - aucune information n'est tirée des données ;
    - aucune hypothèse de D(2)(h) n'est vérifiable ;
    - la batterie tourne sur du bruit ;
    - le régime de sortie dépend de l'arithmétique.
  - Différence avec #188 : ici, l'estimateur de Mack est atteint.

**(b) Spécification : option A, refus `ok = FALSE` motivé (recommandée).**
- **Prédicat** `.mw_triangle_totalement_degenere(aj)` = `all(seq.int(0L, aj$J - 2L) %in% .mw_colonnes_degenerees(aj))`.
  - Il réutilise le prédicat de #56, sans constante nouvelle, et vaut `FALSE` pour un objet d'ajustement réduit.
  - **Robustesse** : ni `lm()` ni BLAS. Les cas réels sont à ≥ 1e-3, les cas déterministes à ~1e-16 ; la seule zone sensible, [1e-13 ; 1e-11], ne s'atteint qu'avec des données construites.
- **Emplacement** : `mw_valider_ajustement()`, avant le paramètre et le bootstrap.
- **Motif unique.** Il cite D(4) et D(5)(d)(ii). Il énonce le constat : MSEP nulle en arithmétique exacte, σ_USP réduit à (1 − c)·σ(res,s), aucun résidu de Mack défini. Il donne la cause et ce qu'il faut vérifier, sans valeur de bruit d'arrondi.
- Les avertissements de colonnes ne sont **pas** émis (Q-E2r-192-4).
- **Hors périmètre** :
  - la classe quasi dégénérée, par exemple `total_arrondi` (`ok = TRUE`, σ_USP = 0,036901), faute de seuil fondé ;
  - les triangles partiellement dégénérés, qui restent sous la doctrine « avertissement ».
- **Fondement réglementaire, à établir par `regulatory`.** D(2)(h) se lit de deux façons :
  - une constante de proportionnalité nulle est formellement admise ;
  - une variance nulle partout contredit la « nature stochastique ».

**(c) Critères d'acceptation**, mesurés sur prototype.
1. Refusés avec `ok = FALSE`, sans `validation$erreur_r` ni erreur R : `total_exact`, `total_f_binaire`, `col0_1e13`.
2. Restent à `ok = TRUE` :
   - `col0_1e11` ;
   - `sauf_une`, σ_USP = 0,03778838, inchangé ;
   - `total_arrondi`, inchangé.
3. La fonction est testée sur des ajustements fictifs, et le motif est conforme à (b). Les triangles `tri_deg`, `tri_sym`, `tri_2`, `tri_ach` et `ta_deg` sont inchangés.
4. Avec #60 : `mw_residus()` est non vide pour tout triangle accepté (`sauf_une` : 7 résidus).
5. **Point ouvert.** Le passage combiné #192 + #60 a émis deux avertissements R `mean.default(z) : argument is not numeric`, de source non identifiée. Le test « aucun avertissement R » doit rester vert : c'est à instruire par `coder` et `audit`.

**(d) Effet sur `reserve2`.**
- Identique, **mesuré pour #192 seul**.
- **Non relu** pour le passage combiné avec #60.
- σ_USP n'est jamais modifié sur un triangle accepté. En revanche, un triangle aujourd'hui accepté devient refusé : c'est au mainteneur d'en décider.

**(e) Circuit.** Circuit 2 : `regulatory` (D(2)(h), D(4), D(5)) → `actuary` → mainteneur (Q-E2r-192-1 à 4) → `coder` → `audit` → `regulatory` contrôle → `docwriter` → `actuary` valide.

**(f) Surface documentaire.**
- `.tex` :
  - liste des contrôles de validité Merz-Wüthrich ;
  - ligne « Triangle déterministe ⇒ MSEP = 0 » du tableau de vérification (l. ~11132) ;
  - section `sec:mw`, cas dégénérés.
- `CONTEXT.md` : « Contrôle de validité », « Colonne dégénérée », « Défaut de calcul intercepté ».

**(g) Questions au mainteneur.**
- **Q-E2r-192-1.** Option A, refus `ok = FALSE` (*recommandé*), avertissement renforcé, ou statu quo ?
- **Q-E2r-192-2.** Faire passer `regulatory` avant `coder` ? *Recommandation : oui.*
- **Q-E2r-192-3.** Laisser la classe quasi dégénérée au statu quo ? *Recommandation : oui.*
- **Q-E2r-192-4.** Supprimer les avertissements de colonnes en cas de refus ? *Recommandation : oui.*

**Non vérifié (lot A)** :
- plateforme CI (R 4.3.1) ;
- jeu MW2008 et valeurs de Merz et Wüthrich (2008) ;
- mention de `ta_deg` et `t5` dans le `.tex` ;
- `reserve2` sous #192 + #60 combinés ;
- source des avertissements R du passage combiné.

---

## Lot B — #115, #46, #90, #89

> *Rédigé par l'agent actuary (IA)*, `actuary-approfondi`, 05/10/2026.

Mesures sur `main` `979ca62`, avec B = 999 et la graine 20260831 sauf mention contraire. Les résultats sont lus sur les sorties console des scripts : aucun journal n'a été conservé.

**Périmètre.** La fiche « Branche E2 réduite » (condition C3) range `.fisher_combine()` dans le périmètre. Le brief de l'agent ne la citait pas. La spécification suit la feuille de route (Q-E2r-90-2).

### #115 — p_min des lignes Merz-Wüthrich à loi discrète

**(a) Constat (re-mesuré).**
- `mw_tests()` ne passe `p_min` à aucune ligne : les 19 lignes de `reserve2` ont `p_min = NA`.
- L'`add()` d'`engine_registre_tests()` accepte déjà `p_min` et `effectifs` (`R/engine.R:3166`) et applique R1 sans distinguer la méthode. **La spécification tient donc dans `mw_tests()` et dans de nouvelles fonctions `.mw_*`, sans toucher à `add()`.**
- **Six lignes** ont une statistique discrète sous une loi combinatoire, et non cinq comme on le croyait. La sixième est « Adéquation de l'exposant de variance » (clé `ExpVar`, M2), construite comme HomogF (un Spearman par colonne, combiné par Fisher).
- **Aucune de ces lois de référence n'est exacte pour le modèle de Mack**, pour trois raisons :
  - les résidus ne sont pas échangeables : Var(√C_ij (F_ij − f̂_j)) = σ²_j (1 − h_ij), avec h_ij = C_ij/S_j ; chaque colonne porte la contrainte Σ_i √C_ij r_ij = 0, et Σ_i r²_ij = n_j − 1 est mesuré ;
  - les F(i,j) d'une colonne n'ont pas tous la même variance ;
  - les colonnes adjacentes sont dépendantes.

  Aucun régime analogue à π̂ constant n'existe donc : la p_min « sous la loi de référence échangeable » ne borne jamais la p Monte-Carlo retenue.

p_min mesurées (« ref k » : sous-triangle k × k de `triangle_mw.csv` ; « TA » : triangle de Taylor-Ashe) :

| triangle | Suites | Calendaire | CorrDev | HomogF / ExpVar (après #90) | KruskalAcc |
|---|---|---|---|---|---|
| ref5 | 0,0571 (4/4) | **0,125** (n_k = 3,3) | **0,333** (3) | non applicable (K < 2) | 4,76e-3 (3,3,2,1) |
| ref6 | 1,17e-3 | 1,56e-2 | 1,39e-2 | 1,39e-3 | 9,51e-6 |
| ref7 | 2,17e-5 | 4,88e-4 | 1,16e-4 | 3,86e-6 | 1,23e-9 |
| **ref8 = reserve2** | 3,85e-7 (13/13) | 7,63e-6 (2,3,4,4,6,5) | 1,61e-7 (6,5,4,3) | 1,53e-9 (7,6,5,4) | 8,29e-15 |
| TA8 | 3,85e-7 | 1,53e-5 | 1,61e-7 | 1,53e-9 | 8,29e-15 |
| TA10 | 1,90e-12 | 9,31e-10 | 7,91e-16 | 4,19e-19 | 2,78e-29 |

**(b) Spécification.** p_min est la plus petite p-value atteignable sous la loi de référence discrète, aux effectifs observés, dans le sens du catalogue et avec la convention du doublement pour les lignes bilatérales (M8). Elle est exacte sous la loi de référence, qui n'est pas le modèle réglementaire (ADR 0002).

1. **Suites** (bilatéral) : `runs_p_min(n1, n2)` sur `.runs_effectifs(r)`, appelée sans modification.
2. **Calendaire** (bilatéral) : sur chaque diagonale retenue (n_k ≥ 2), L_k suit une Binomiale(n_k, 1/2) ; les diagonales sont indépendantes, et Z = Σ min(L_k, n_k − L_k). C'est la loi qu'utilisent déjà les moments exacts de `.mack_moments_Z()`.
   - La loi de Z s'obtient exactement par convolution, et p_min = min_z 2·min(P(Z ≤ z), P(Z ≥ z)), bornée à 1.
   - Les n_k sont lus dans `detail[, "n"]`.
   - Nouvelle fonction `.mw_calendrier_p_min(n_k)`.
3. **CorrDev** (bilatéral) : p_min = min(1, 2·Π_k 1/n_k!), avec n_k = `poids + 1`. Nouvelle fonction `.mw_corr_p_min(n_k)`.
4. **HomogF et ExpVar** (queue haute) : p_min = Π_j 2/n_j! sur les K colonnes retenues.
   - La formule exige que p_j soit strictement décroissante en |ρ_j| et finie en |ρ_j| = 1. **C'est faux avant #90 : dépendance dure.**
   - Nouvelle fonction `.mw_fisher_rangs_p_min(n_j)`.
5. **KruskalAcc** (queue haute) : p_min = M / (N!/Π n_i!), où M est le nombre d'affectations qui atteignent H_max.
   - H_max est atteint par des blocs de rangs contigus (argument d'échange).
   - M se calcule par programmation dynamique sur les sous-ensembles d'années.
   - Nouvelle fonction `.mw_kruskal_p_min(tailles)`.
6. **Ex æquo** : les vecteurs aplatis par #152 font référence.
   - Pour les lignes de rangs, un ex æquo selon `engine_ex_aequo()` donne `p_min = NA`, avec le motif dans `effectifs`, comme `eff_rangs` en lognormale (#70, 5a).
   - Suites et Calendaire traitent déjà les ex æquo.
7. La règle R1 reste inchangée et est appliquée par `add()`.

**Comment #115 évite de préjuger de #125.**
- #115 remplit le champ existant `p_min` avec sa définition actuelle (`CONTEXT.md`, « Test inopérant » : loi échangeable). Elle laisse `add()` appliquer la doctrine en vigueur.
- Elle n'ajoute ni champ nouveau, ni p_min bootstrap, ni règle propre à Merz-Wüthrich.
- Si E2b change R1 pour les lignes à p Monte-Carlo, le changement passera par `add()` et s'appliquera tel quel. #115 laisse seulement en commentaire la liste des clés discrètes : `Runs`, `Calendrier`, `CorrDev`, `HomogF`, `ExpVar`, `KruskalAcc`.
- Mesure de concordance (une graine, B = 999) : fréquence bootstrap des valeurs extrêmes, comparée à la loi échangeable.

| | Calendaire Z* = 0 | CorrDev \|T*\| = 1 | Suites R* extrême |
|---|---|---|---|
| ref5 | 0,114 (loi échangeable : 0,0625) | 0,348 (1/3) | 0,067 (0,057) |
| TA5 | 0,123 | 0,362 | 0,058 |
| ref6 | 0,021 | 0,014 (0,0139) | 0,002 (0,00117) |
| TA6 | 0,023 | 0,023 | 0,006 |

À α = 0,10, les décisions R1 coïncident sur ces quatre triangles. **Une divergence est possible pour le calendaire en 5 × 5**, pour α compris entre environ 0,125 et 0,23 : c'est l'objet de #125.

**(c) Critères d'acceptation.**
1. Sur `reserve2` (tolérance 1e-6 relative) :
   - Suites : `runs_p_min(13, 13)` = 3,845932e-7 ;
   - Calendaire : 2^-17 = 7,629395e-6 ;
   - CorrDev : 2/12 441 600 = 1,6075e-7 ;
   - HomogF et ExpVar : 16/(7!·6!·5!·4!) = 1,531e-9 ;
   - KruskalAcc : 8,29e-15.

   Les 13 autres lignes restent à `NA`, et aucune autre feuille ne change.
2. Valeurs de contrôle, vérifiées par énumération :
   - Kruskal-Wallis : (3,3,2,1) → 24/5040 ; (4,3,2,1) → 1,905e-3 ;
   - calendaire : (3,3) → 0,125 ; (2,3,2,4) → 0,015625 ;
   - CorrDev : (4,3) → 0,013889.
3. Sous-triangle 5 × 5 à α = 0,10 :
   - Calendaire et CorrDev passent `inoperant = TRUE`, avec le préfixe « TEST INOPERANT … sous la loi de reference echangeable » ;
   - Suites reste un test, avec « … ECHEC possible ».
4. Triangle avec ex æquo : `p_min = NA`, motif dans `detail`.
5. `add()`, le catalogue et les fonctions `usp_*` sont intacts. Concordance `--strict` : un écart attendu, corrigé selon M32.

**(d) Effet et visa.**
- `reserve2` : `p_min` passe de `NA` à une valeur sur 6 lignes (4 si #90 n'est pas encore passée). Aucun verdict, aucune p-value, aucun σ_USP ne change.
- Une **régénération par la CI** est nécessaire (le patcher refuse une valeur numérique sur un chemin à `NA`), avec visa `actuary`. Pas de M3 pour `reserve2`.
- Hors références : sur tout triangle 5 × 5, Calendaire et CorrDev passent de OK à INFO (Q-E2r-115-3).

**(e) Circuit.** Circuit 1 : `actuary` → `coder` → `audit` → `docwriter` → `actuary` valide.

**(f) Surface documentaire.**
- Rubrique 7 de `mw:m3runs`, `mw:m3cal`, `mw:m3cor`, `mw:m3acc`, `mw:m1b` et `mw:m2b`.
- `tab:pmin`, ou une table compagne.
- Règle R1 de la section « Nature des p-values ».
- Index des fonctions.
- `CONTEXT.md`, entrée « Test inopérant ».

**(g) Questions au mainteneur.**
- **Q-E2r-115-1 (ordre).** Placer #90 avant #115 ? *Recommandé.*
- **Q-E2r-115-2.** Étendre #115 à ExpVar ? *Recommandation : oui.*
- **Q-E2r-115-3 (doctrine).** Accepter, en attendant #125, la bascule R1 sur la loi échangeable pour les lignes Merz-Wüthrich ? Calendaire et CorrDev deviennent alors inopérants sur les triangles 5 × 5 à α = 0,10.
- **Q-E2r-115-4.** Calculer aussi la p_min de KruskalAcc ? *Recommandation : oui*, par uniformité.

### #46 — Redressement des résidus de Mack dans `mw_bootstrap()`

**(a) Constat (re-mesuré).** Le pool vaut r − moyenne(r), et sa moyenne des carrés est de **0,7775** sur `reserve2` (Σ_i r²_ij = n_j − 1 exactement). Cause exacte : Var(r_ij) = 1 − h_ij, avec h_ij = C_ij/S_j, le levier déjà calculé par `mw_influence()`.

**(b) Spécification.** Seul le pool est redressé, puis recentré. Restent inchangés `mw_residus()`, `stats_obs`, les statistiques répliquées et `mw_simuler_triangle()`. Nouvelle fonction `.mw_pool_residus(aj)` ; `.mc_evaluer()` est appelée sans modification.

Trois variantes ont été mesurées :
- **A** (texte de l'issue) : r·√(n_j/(n_j−1)).
- **B (recommandée)** : r/√(1 − h_ij).
  - Chaque résidu a une variance exactement 1 sous le modèle de Mack à σ_j connu, et ±1 pour n_j = 2.
  - Σ r̃² par colonne : 7,005 ; 5,987 ; 4,961 ; 3,950 ; 3,036 ; 2,000.
  - Référence possible : Davison et Hinkley (1997, §6.2.3), **non vérifiée dans le texte**.
- **C** : correction globale √(N/(N−k)), transposition d'England (2002), *IME* 31(3), 461–466. Le contenu n'a **pas été vérifié** dans le texte, et cette variante ne corrige pas l'hétérogénéité entre colonnes.

Dans tous les cas, c'est une interprétation, pas une formule du règlement. Aucun théorème ne couvre ce test bootstrap, et **aucune calibration Merz-Wüthrich à T = 8 n'existe**.

**(c) Critères d'acceptation.**
1. `.mw_pool_residus(reserve2)` vaut `r/sqrt(1 − C/S) − moyenne` à 1e-15 près ; |r̃| = 1 pour n_j = 2, avant recentrage ; aucune valeur NaN sur `ta_deg` et `tri_deg`.
2. `stats_obs`, `residus` et `plots_data$residus` sont `identical()` à leur état d'avant.
3. Seuls changent les p_mc, `err_mc`, `p_retenue` et verdicts des lignes Monte-Carlo, ainsi que `sigma_boot` et `ic_bootstrap`. σ_USP est identique.
4. Volet `identical()` de la reproductibilité respecté.

**(d) Effet mesuré** (graine 20260831).

| p_mc | avant | A | **B** | C |
|---|---|---|---|---|
| Breusch-Pagan | 0,086 ALERTE | 0,103 OK | **0,103 OK** | 0,089 ALERTE |
| Alpha | 0,002 ECHEC | 0,005 | 0,005 | 0,007 |
| Calendaire | 0,002 | 0,004 | 0,004 | 0,002 |
| Origine | 0,095 | 0,087 | 0,085 | 0,092 |
| HomogF | 0,075 | 0,070 | 0,069 | 0,076 |
| Courbure | 0,036 | 0,030 | 0,030 | 0,030 |

- Les autres lignes bougent de 0,01 au plus.
- Médiane de σ_boot : 0,01636 → 0,01845 (+12,8 %). IC bootstrap : [0,04353 ; 0,05208] → [0,04435 ; 0,05398]. **σ_USP inchangé : 0,04978.**
- **Un verdict change : Breusch-Pagan passe d'ALERTE à OK, d'où un visa M3.** L'écart de +0,017 vaut environ deux fois l'erreur Monte-Carlo. **Sa stabilité sur d'autres graines n'a pas été mesurée.**

**(e) Circuit.** Circuit 1, plus le mainteneur (M3).

**(f) Surface documentaire.**
- `sec:boot-mw` : dérivation, choix de la variante, statut d'interprétation.
- `mw:m2var`, rubrique Pval des lignes Monte-Carlo, fiche de l'IC bootstrap.
- Tableau 2.
- Index des fonctions.
- Case « chantier 5 » de #5.

**(g) Questions au mainteneur.**
- **Q-E2r-46-1.** Quelle variante : B (recommandée), A ou C ?
- **Q-E2r-46-2.** Visa M3 du passage de Breusch-Pagan d'ALERTE à OK sur `reserve2`, à confirmer par la régénération de la CI, et après mesure sur plusieurs graines.
- **Q-E2r-46-3.** Ouvrir une issue de calibration des p-values Monte-Carlo Merz-Wüthrich à T = 8, hors E2 réduite ?

### #90 — Homogénéité de f_j : p-values de Spearman nulles écartées, K variable

**(a) Constat (re-mesuré).**
- `cor.test(exact = FALSE)` donne p = 0 à |ρ| = 1, et `.fisher_combine()` écarte alors la colonne.
- `ta_deg` : la colonne j = 5 (n = 4, ρ = −1) est écartée, d'où K = 4 au lieu de 5.
- `tri_deg` (B = 99) : `B_effectif` vaut 91 pour HomogF et 93 pour ExpVar.
- **ExpVar a le même défaut.**
- Sur `reserve2`, les p exactes diffèrent sensiblement des p asymptotiques : 0,139 contre 0,119 ; 0,103 contre 0,072 ; 0,233 contre 0,188 ; 0,75 contre 0,60.

**(b) Spécification.** `.mw_spearman_p(a, b, plancher_b)` donne la p bilatérale par colonne :
- n ≤ 9 sans ex æquo : `cor.test(exact = TRUE)` ;
- sinon : `exact = FALSE`, avec un plancher à **2/n!** (valeur exacte de P(|ρ| = 1) sans ex æquo, simple plancher numérique avec ex æquo) ;
- le résultat est toujours dans [2/n!, 1].

Ces p_j ne sont **pas** des p exactes au sens de l'ADR 0002 : la p retenue reste Monte-Carlo. La règle s'applique à HomogF et à ExpVar.

Correction de `.fisher_combine()` :
- plus aucune exclusion silencieuse ;
- p = 0 est relevée au plancher `.Machine$double.xmin` ;
- une p non finie donne une statistique `NA`, pour garder K constant.

**(c) Critères d'acceptation.**
- `ta_deg` : K = 5 et p_5 = 0,08333.
- `tri_deg` : `B_effectif` = 99 pour HomogF et pour ExpVar.
- `.mw_spearman_p(1:4, 4:1)` = 1/12 ; `.mw_spearman_p(1:10, 10:1)` = 2/10! ; égalité avec `cor.test(exact = TRUE)` pour n ≤ 9 ; jamais 0.
- `reserve2` (mesuré sur `main`) :

| ligne | statistique | p asymptotique | p_mc | verdict |
|---|---|---|---|---|
| HomogF | 13,865 → 11,984 | 0,085 → 0,152 | 0,075 → 0,081 | ALERTE, inchangé |
| ExpVar | 8,486 → 6,930 | 0,387 → 0,544 | 0,347 → 0,425 | OK, inchangé |

**(d) Effet.** Sur `reserve2`, HomogF et ExpVar changent (statistique, p asymptotique, p_mc, `err_mc`). Aucun verdict ne change à la graine de référence ; la mesure est à refaire après #46. Visa `actuary`, et M3 si la régénération de la CI montre un changement de verdict.

**(e) Circuit.** Circuit 1.

**(f) Surface documentaire.**
- `mw:m1b` et `mw:m2b` (Stat, Loi, Pval) ;
- passage de `mw:m1a` sur K ;
- tableau des natures ;
- index des fonctions.

**(g) Questions au mainteneur.**
- **Q-E2r-90-1.** Étendre #90 à ExpVar ? *Recommandation : oui.*
- **Q-E2r-90-2.** Confirmer que `.fisher_combine()` est dans le périmètre C3.

### #89 — Influence Merz-Wüthrich : DFBETAS à la place du repère 2 % sans source

**(a) Constat (re-mesuré).**
- Sur `reserve2`, aucune des 27 cellules ne franchit le repère de 2 % : le maximum de |variation relative| est de 0,585 %.
- Sous le modèle ajusté (2 000 triangles 8 × 8), le taux de franchissement est de 0 % : la coloration ne sert à rien.
- L'échelle n'est pas homogène d'une colonne à l'autre.

**(b) Spécification recommandée.**
- **DFBETAS (`stats::dfbetas()`)** sur la régression pondérée C_{.,j+1} ~ 0 + C_{.,j}, de poids 1/C_{.,j}.
- Forme close, vérifiée contre `stats::dfbetas()` (écart ≤ 9,4e-14) :
  - e_i = C_{i,j+1} − f̂ C_ij ;
  - s²_(i) = [(n−1)σ̂²_j − e_i²/(C_ij(1−h_i))]/(n−2) ;
  - DFBETAS_i = e_i √S_j / (S_j (1−h_i) s_(i)).
- Pour n_j = 2, la valeur est `NA`, et la cellule n'est pas colorée.
- **Repère : 2/√n_j** (Belsley, Kuh et Welsch 1980, ch. 2, cité par le `.tex` ; non revérifié). Taux de franchissement mesurés sous le modèle :

| n_j | 7 | 6 | 5 | 4 | 3 | global |
|---|---|---|---|---|---|---|
| repère 2/√n_j | 12,3 % | 14,0 % | 17,2 % | 22,3 % | 35,2 % | 18,0 % |
| repère absolu 2 | 0,4 % | 1,1 % | 2,8 % | 8,0 % | 21,8 % | 4,8 % |

- Sur `reserve2`, trois cellules seraient colorées : (0, 2) à −1,10, (0, 3) à −1,50 et (1, 4) à +1,53.
- Contrat de `plots_data$influence` :
  - colonnes existantes conservées ;
  - ajout de `dfbetas` et `repere_dfbetas` ;
  - `fort_dfbeta` remplacé par `fort_dfbetas` ;
  - `REPERE_DFBETAS_MW = 2` remplace `REPERE_DFBETA_MW`.
- Affichage : y = DFBETAS, repères ±2/√n_j, variation relative dans l'infobulle.

**(c) Critères d'acceptation.**
- `dfbetas` égal à `stats::dfbetas()` à 1e-10 près pour n_j ≥ 3 ; `NA` pour n_j = 2.
- `fort_dfbetas == (|dfbetas| > 2/√n_j)`, avec `NA` traité comme FALSE.
- Colonnes existantes `identical()` ; trois cellules colorées sur `reserve2`.
- Tracés sans erreur ; aucun verdict ni σ_USP modifié.

**(d) Effet.** Régénération structurelle de `reserve2` par la CI, sans M3.

**(e) Circuit.** Circuit 1, plus `app-review` (après l'intégration de R7) et `architect` (contrat partagé `plots_data`).

**(f) Surface documentaire.**
- `mw:influence` et `sec:graph-mw` ;
- `CONTEXT.md`, entrée « Diagnostic » ;
- index des fonctions.

**(g) Questions au mainteneur.**
- **Q-E2r-89-1 — POINT D'ARRÊT.** #89 ne tient pas dans C3. Elle impose de toucher :
  - la constante `REPERE_DFBETA_MW` (`R/engine.R:5526`) ;
  - `tests/unitaires/test_defauts_connus.R:1021-1035` ;
  - `note_influence_mw()` (`R/display_helpers.R`) ;
  - `CONTEXT.md`.

  Il faut soit étendre le périmètre, soit renvoyer #89 en F.
- **Q-E2r-89-2.** Quel repère : 2/√n_j (recommandé), 2, ou aucune coloration ?
- **Q-E2r-89-3.** Renommer `fort_dfbeta` en `fort_dfbetas` ? *Recommandation : oui.*

**Non vérifié (lot B)** :
- texte d'England (2002), de Davison et Hinkley §6.2.3 et de Belsley, Kuh et Welsch (repère 2/√n) ;
- stabilité, sur plusieurs graines, du verdict de Breusch-Pagan sous #46 ;
- plateforme CI.
