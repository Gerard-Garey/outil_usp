# Matrice de conformité, KR étape 6, lot 3 sur 3 : annexe XVII, sections D à G

> Rapport de `regulatory` (effort `high`), versé intégralement par la session principale (Q-54-10). SHA du gel `a2f9c3a` ; `.tex` 3.7. La matrice vaut pour le PDF 3.8 sous réserve du contrôle aval, à l'étape 8, des passages réécrits à l'étape 7.

**Aucun écart de conformité majeur, donc pas de motif d'arrêt.** Le σ_USP de la méthode n° 2 est celui que prescrit le texte consolidé. Je l'ai recalculé par une transcription indépendante, faite d'après le rendu graphique des formules : l'écart avec le moteur est nul au bit près.

J'ai relevé 4 écarts mineurs, tous de rédaction, dont 3 dans le `.tex`. Aucun ne touche un chiffre, une p-value ou un verdict. Les deux interprétations du lot sont déjà tranchées ; je n'en rouvre aucune.

**Base de la revue**
- Code : SHA du gel `a2f9c3a`. Entre ce SHA et la tête `ca49fd4`, seul `docs/feuille-de-route.md` change.
- `.tex` : version actuelle.
- Texte consolidé : formules de la section D (15 images) lues en rendu graphique.
- JOUE L 12 du 17.1.2015 : p. 276-278 et 282 lues à l'image.
- Rien n'a été écrit dans le dépôt. Scripts de vérification hors dépôt (`verif_d.R`, `verif_v.R`, `verif_col.R`, scratchpad de la session).

## 0. Vérification numérique (`LC_ALL=C.UTF-8`, `charger_moteur()`)

Transcription autonome de D(4)-D(5), en indices du règlement, appliquée à `tests/donnees/triangle_mw.csv` (8 × 8, segment II-1, c = 0,59, σ(res,s) = 0,09).

| Grandeur | Moteur | Transcription indépendante |
|---|---|---|
| f̂_j, σ̂²_j | — | écart max 0 |
| R̂ | 9 140,8434379546 | identique |
| MSEP (formule consolidée) | 39 798,0296160152 | identique, écart relatif 0 |
| σ_USP | 0,0497764613 | identique (`mw_parametre()` et `run_engine()` aussi, durée 8) |
| MSEP selon la formule du JOUE 2015, p. 277 | — | 45 811,169, soit σ_USP = 0,0507150172 |

La valeur 2015 est la différence entre les deux versions du texte, déjà consignée par l'ADR 0005. Ce n'est pas un écart de l'outil.

Contrôles d'entrée :
- triangle 9 × 8 (I > J) : MW-04 seul, texte identique au mot près à l'ADR 0005, annotation du 13/11 (bis) ;
- triangle 8 × 9 : D(2)(e) seul ;
- triangle 4 × 4 : D(2)(b) et D(2)(c) ;
- triangle 5 × 5 : accepté, avec c = 34 % et la mention G(3)(c) ;
- R̂ < 0 : refus.

## 1. Matrice

### Section D, données (paragraphes 1 et 2)

| § | Code (`R/engine.R`) | `.tex` | Verdict |
|---|---|---|---|
| D(1) paiements cumulés par année d'accident × année de développement | `.retirer_lignes_colonnes_vides()` 7920-8000 ; `mw_valider_triangle()` 10294-10309 (partie observée complète) | `sec:controles` 3912-3963, 4881-4883 | conforme |
| D(2)(a) représentativité | non vérifiable ; citée comme fondement du refus dégénéré 11097-11101 | 5103-5114 | conforme (déclaratif) |
| D(2)(b) ≥ 5 années d'accident | 10271-10273 | 4869, 5211 | conforme |
| Ligne vide : ancrage | 7931-7958 et `.motifs_colonne_i()` 7857-7865 : D(1), D(3)(a)-(b) | 3917-3918, 3962 | conforme (la moitié D(2)(b) de #559 a été corrigée en K3b, `21561e0`) |
| D(2)(c) ≥ 5 années de développement pour la première année d'accident | 10274-10276 (le motif omet « consécutives » ; paraphrase admissible, les colonnes sont lues comme consécutives) | 4870 | conforme |
| Colonne vide : ancrage | 7988-7997 (motifs sans renvoi réglementaire) | 3918-3922 : « D(1), D(2)(c) et D(3)(c) » | **écart mineur E-1** et **E-2** (§ 2) |
| D(2)(d) première année entièrement développée | non vérifiable ; aucun facteur de queue | 5114-5122 (citation fidèle, dernier alinéa de D(2) compris) | conforme |
| D(2)(e) I + 1 ≥ J + 1 | 10277-10278 | 4871 | conforme |
| MW-04 (I > J) | 10279-10288 et en-tête 10198-10210 | 4872-4880 ; encadré 14770-14793 | conforme à l'ADR 0005 (13/11 et 13/11 bis) : les points 1 à 5 sont présents, l'art. 19(1)(b) est cité exactement et les termes indéfinis sont justes (i < I−J et 1 ≤ i ≤ I−J) |
| D(2)(f) données nettes | `.nature_erreurs()` 630-664 ; `.run_engine_mw()` 14558-14564 | 4867-4868, 5114 | conforme |
| D(2)(g) dépenses de gestion incluses | non vérifiable | 5114-5115 | conforme (déclaratif) |
| D(2)(h)(i)-(iv) hypothèses stochastiques | M1-M3 (`mw_tests()` 13586 et suivantes) | 14797-14826 ; citations mot pour mot en tête de `sec:mwm1`, `sec:mwm2`, `sec:mwm3` | conforme ; formalisations déclarées comme interprétations (fond statistique : `actuary`) |
| Positivité C(i,j) > 0 | 10307-10309 | 4897-4898 | conforme : restriction nécessaire (une cellule nulle rend indéfinis le ratio de D(5)(d)(ii) et Q̂/C(i,I−i) ; une cellule négative est incompatible avec D(2)(h)(iv)). Observation : la justification du `.tex` ne cite pas ces deux appuis. |
| Cellules sous la diagonale, domaine numérique, noms de ligne | 10226-10244, 10313-10339, 10352-10440 | 4884-4908 | conforme (conventions déclarées, hors des formules) |

### Section D, méthode (paragraphes 3 à 5)

| § | Code (`R/engine.R`) | `.tex` | Verdict |
|---|---|---|---|
| D(3)(a)-(d) notation | matrice (I+1) × (J+1), commentaire 10191-10196 | 14449-14451 | conforme |
| D(4) formule de σ_USP | `mw_parametre()` 11241-11255 | `sec:mw` 14653-14658 | conforme, bit près |
| D(4)(a) c de la section G, durée G(3)(c) = I + 1 | 11242-11243 | 14438, 4958 | conforme |
| D(4)(c) f̂_j et Ĉ(i,j) | `mw_ajuster()` 10497-10502, 10550-10556 | 14478-14483 | conforme, bit près |
| D(4)(d) σ(res,s) | 14583-14586 (valeurs : lot 1) ; une saisie libre est une dérogation tracée (#55) | — | conforme |
| D(4) : pas de correction de taille | `correction_taille = 1` (14681) | 14435 | conforme |
| D(4) : refus de R̂ ≤ 0 | `mw_valider_ajustement()` 11047-11058 | 14660-14768, 4915-4921 | interprétation déjà tranchée (M4) ; le `.tex` la déclare bien comme interprétation. Puce 14698-14703 : **écart mineur E-3** (#573, § 3) |
| D(5) formule de la MSEP | `mw_msep()` 10850-10885 | 14608-14651 | conforme au consolidé terme à terme : crochet deux fois, facteur 2, k = i+1..I, exposant 1 |
| D(5) : distinction des versions 2015 et consolidée, pagination | 10186-10189, 10819-10823 | 14455-14476 | conforme. Le commentaire 10186-10187 dit « VERSION CONSOLIDEE en vigueur » sans la qualification de l'ADR 0005 (annotation du 08/11, suite) : **écart mineur E-4** (code gelé, donc issue, § 4) |
| D(5)(a)-(c) Ĉ, S_j, S′_j | 10560-10565 | 14609-14610 | conforme |
| D(5)(d) et (d)(i) Q̂_j | 10559 | 14609 | conforme |
| D(5)(d)(ii) σ̂²_j pour j = 0..J−2 | 10504-10511 | 14485-14489 | conforme, bit près |
| D(5)(d)(ii) règle de minimum (σ⁴ lu (σ²)²) | 10540-10548 | 14490-14494 | conforme |
| Cas σ̂²_(J−3) = 0 | 10540-10541 (minimum littéral = 0) ; avertissement 11105-11163 | 14496-14606 (citation de l'annexe XVIII, D(2)(d), vérifiée) | conforme (lecture littérale, tranchée par #7 et #21) |
| Triangle totalement dégénéré | 11084-11104 | 14748-14755, 4922-4927 | interprétation déjà tranchée (#192) ; ancrage exact : art. 219(1)(d), D(2)(h), D(2)(a) |
| MSEP non finie ou négative | 11063-11067 | 14741-14746 | conforme (garde défensive déclarée) |
| Citations de l'art. 116(6), de l'art. 147(6) et de l'art. 220(2) dans `sec:mw` | — | 14704-14729 | conformes au consolidé |

### Sections E, F et G

| § | Code (`R/engine.R`) | `.tex` | Verdict |
|---|---|---|---|
| Section E (risque de révision) | non implémentée (méthodes premium, reserve1 et reserve2 seulement) | — | sans objet |
| Section F (réassurance non proportionnelle) | non implémentée ; `np_standard` est le facteur standard de l'art. 117(3), pas une méthode F | — | sans objet |
| G(1) barème long | `CRED_LONG` 144-146 ; `usp_bareme_segment()` 391-398 (segments II-1, II-5, II-6) | 2250-2259 | conforme (JOUE p. 282 et consolidé identiques) |
| G(2) barème court | `CRED_COURT` 149-150 ; toute l'annexe XIV en barème court | 2250-2259 | conforme |
| Durée < 5 ans ; durée au-delà du barème | `usp_credibilite()` 351-356 : refus ; plafond 15 ou 10 | 4540 | conforme |
| G(3)(a)-(b) durée = T retenu | `.engine_credibilite_appliquee()` 423-459 | 2289-2333 | conforme (lecture (A) de #104, tranchée) |
| G(3)(c) durée = I + 1 | 11242 ; avertissement 10469-10475 | 14438, 2325-2327, 4958 | conforme |
| G(3)(d)-(e) | — | — | sans objet |
| Barème saisi | dérogation tracée (#93) | 2262-2287 | conforme (dérogation déclarée) |

## 2. Décision proposée sur les ancrages de #559

**Ligne vide.** Rien à modifier. Le moteur (7931-7939, 7859-7863) et le `.tex` (3918, 3962) ancrent déjà la ligne vide sur D(1) et D(3)(a)-(b), depuis K3b. D(2)(b) n'apparaît plus qu'au contrôle de profondeur (10272, 4869), où il est juste.

**Colonne vide (E-1 et E-2).**
- **E-1, ancrage.** D(2)(c) n'exige que cinq années de développement consécutives au moins pour la première année d'accident ; une colonne intercalée ne l'enfreint pas en soi. D(3)(c) ne fait que définir J. Les appuis justes sont :
  - D(1) : montants « pour chaque année d'accident et chaque année de développement des paiements » ;
  - A(1)(b) : l'année de développement est une différence d'années ;
  - D(4)(c) : Ĉ(i,j) enchaîne f̂_(I−i) … f̂_(j−1), et chaque facteur relie l'année j à j + 1.
- **E-2, description du motif.** Le `.tex` place la colonne vide « portant un en-tête » sous « année de développement manquante présumée ». Or le moteur émet pour elle un motif distinct, « annee de developpement sans valeur », mesuré par `verif_col.R` : en-tête `jx` en colonne 2, en-tête `j8` en colonne 10. Une colonne à en-tête qui est intercalée reçoit le motif de la colonne intercalée.

Le moteur n'est pas modifié : ses motifs de colonne ne citent aucun texte, ce qui est conforme.

**Texte exact pour `docwriter`** (`.tex` l. 3918-3922). Remplacer le passage « une colonne vide intercalée ou portant un en-tête comme année de développement manquante présumée (D(1), D(2)(c) et D(3)(c)~: … ~; la présomption est une lecture retenue par l'outil) » par :

```latex
une colonne vide intercalée comme année de développement manquante présumée (D(1) et D(4)(c),
lus avec A(1)(b)~: montants indiqués pour chaque année de développement des paiements, l'année
de développement étant la différence entre l'année du paiement et celle de l'accident~;
l'estimation $\hat C(i,j)$ de D(4)(c) enchaîne les facteurs $\hat f_{I-i}, \dots, \hat f_{j-1}$,
dont chacun relie une année de développement à la suivante~; la présomption est une lecture
retenue par l'outil), une colonne vide portant un en-tête, placée en bord de tableau, comme année
de développement sans valeur (motif distinct~; précaution de l'outil, sans ancrage dans le texte)
```

La suite (« , selon la règle commune décrite au paragraphe… ») est inchangée. D(2)(c) reste l'ancrage du seul contrôle de profondeur (4870), et D(3)(c) celui de la seule définition de J. Le passage 3937-3938 (« D(2)(c) n'est pas en cause… ») est exact et reste tel quel.

## 3. Puce de `sec:mw` (#573, l. 14698-14703) : E-3

**Constat.** « l'entreprise à qui l'outil refuse la seconde conserve la première » fait de la méthode n° 1 un repli acquis. Cette qualification a été écartée par l'ADR 0005 (13/11 bis, point 4) : la méthode n° 1 est l'autre méthode standard de l'art. 220(1)(b), sous ses propres exigences de données, et le choix entre les deux relève de l'art. 220(2). Le vrai appui de « aucun droit perdu » est le caractère facultatif du remplacement : l'art. 218(1) parle de paramètres standard « pouvant être remplacés ».

**Texte proposé pour `docwriter`** (étape 7) :

```latex
\item \textbf{Le refus ne prive l'entreprise d'aucun droit.} Le remplacement est une faculté~:
  l'article~218, paragraphe~1, énumère les paramètres standard «~pouvant être remplacés~» par des
  paramètres propres, et, à défaut de paramètre propre, $\sigma_{(\text{res},s)}$ s'applique. Pour
  ce paramètre, l'article~220, paragraphe~1, point~b), prévoit aussi la méthode du risque de
  réserve n\textsuperscript{o}~1 (section~C), sous ses propres exigences de données~; le choix
  entre les deux méthodes, quand l'entreprise est en mesure d'utiliser l'une et l'autre, relève de
  l'article~220, paragraphe~2. Le refus ne crée donc aucune impasse réglementaire, ce qui est la
  condition de son admissibilité.
```

## 4. Issue proposée (E-4 ; code gelé, à créer seulement avec l'accord du mainteneur)

**Titre** : moteur: commentaires de la section D, « VERSION CONSOLIDEE en vigueur » sans la qualification de l'ADR 0005

**Libellés** : `bug`, `needs-triage`

**Corps** :

> *Rédigé par l'agent regulatory (IA).*
>
> ## Constat
> L'ADR 0005 (annotation du 08/11/2026, suite) demande de lire « version consolidée en vigueur » comme « version consolidée retenue par l'outil comme référence de lecture ». Le texte consolidé n'a pas d'effet juridique propre ; font foi les versions publiées au JOUE. Le `.tex` a été aligné en JF ; deux commentaires ne l'ont pas été :
> - `R/engine.R` l. 10186-10187 (en-tête de la section 10) : « transcription de la VERSION CONSOLIDEE en vigueur (EUR-Lex, CELEX 32015R0035, consolidee au 14.11.2024) » ;
> - `tests/unitaires/test_merz_wuthrich.R` l. 6 : « Par. 5 : VERSION CONSOLIDEE en vigueur (ADR 0005) ».
>
> La forme conforme figure déjà dans `R/engine.R` l. 45-49 : « retenue par l'outil comme reference de lecture, sans effet juridique propre ».
>
> ## Effet
> Aucun : commentaires seulement. Pas de changement de σ_USP, de p-value ni de verdict ; références identiques. Le code est gelé en KR (SHA `a2f9c3a`) : correction après la remise, ou sur décision de dégel.
>
> ## Critères d'acceptation
> - Les deux commentaires portent la qualification de l'ADR 0005.
> - `grep -n "CONSOLIDEE en vigueur"` sur `R/` et `tests/` ne renvoie plus rien.
>
> Refs #26, #559 (matrice de KR, lot 3)

Pas de doublon parmi les 32 issues ouvertes relues (#492 porte sur le bootstrap).

## 5. Synthèse

- **Écart majeur** : aucun, donc pas de motif d'arrêt. La MSEP et σ_USP sont conformes au consolidé ; l'écart avec la formule du JOUE 2015 est connu et documenté par l'ADR 0005.
- **Écarts mineurs** :
  - E-1 et E-2 : ancrage et description de la colonne vide, l. 3918-3922 ; à traiter par `docwriter` sous #559 ;
  - E-3 : puce de `sec:mw` ; à traiter sous #573 ;
  - E-4 : commentaires du code ; issue proposée au § 4.
- **Interprétations déjà tranchées, non rouvertes** : refus de R̂ ≤ 0 (M4), triangle dégénéré (#192), σ̂²_(J−3) = 0 (#7, #21), refus I > J (lecture A, #540), barème et σ saisis comme dérogations (#93, #55).
- **Observation sans écart** : la justification de la positivité (l. 4897-4898) pourrait citer D(5)(d)(ii) et D(2)(h)(iv).
- **Couverture** : chaque paragraphe de D(1) à D(5), les sections E et F (sans objet) et G(1) à G(3) a un verdict.
- **Réserve** : la matrice vaut pour le PDF 3.8 sous réserve du contrôle aval, à l'étape 8, des passages réécrits à l'étape 7 (l. 3918-3922, puce l. 14698 et suivantes).
