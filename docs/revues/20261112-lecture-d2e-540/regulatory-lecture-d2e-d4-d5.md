# Lecture réglementaire de l'annexe XVII, section D, points (2)(e), (4) et (5), confrontée au moteur et à la doc (issue #540)

> *Rédigé par l'agent regulatory (IA), effort `high`, hors branche, le 12/11/2026 (Q-59-7 (a), Q-60-8 (a)).* Arbre lu : `main` `7eca6e4`. Versé intégralement par la session principale sur la branche K3b (Refs #540). L'agent n'a rien écrit dans le dépôt : ni commit, ni issue, ni commentaire.

## 0. Résultat

- **Les formules de D(4) et D(5) sont transcrites correctement** dans le moteur et dans la doc pour un triangle carré (I = J). Chaque terme a été comparé au texte lu à l'image, sans écart.
- **Le refus MW-04 relève de deux lectures possibles.**
  - D(2)(e) admet expressément I ≥ J.
  - Mais les formules de D(4) et D(5) ne se calculent à la lettre **que si I = J**. Dès que I > J, plusieurs termes sont indéfinis : C(i,I−i) pour I−i > J, et Q̂_{I−i} pour I−i ≥ J. Ces termes ne portent que sur les années d'accident i ≤ I−J, c'est-à-dire celles qui ont atteint l'année de développement J.
  - Le texte ne dit pas comment les traiter. Le moteur retient la lecture stricte : un refus explicite, présenté comme une restriction d'implémentation.
- **Sur σ_USP :** aucun σ_USP existant ne changerait, puisque les six cas de référence sont carrés. Avec la lecture extensive, un triangle à plus d'années d'accident que de développement (« trapèze »), refusé aujourd'hui, recevrait un σ_USP. Son facteur de crédibilité c serait calculé sur I + 1 années d'accident (G(3)(c)).
- **Le choix entre les deux lectures revient au mainteneur**, après l'avis d'`actuary` (circuit 2). Aucune nouvelle issue n'est proposée : #540 couvre la question. Un commentaire pour #540 est proposé au § 5.

## 1. Sources et versions

- **Version consolidée du 14.11.2024** (référence de lecture), xhtml à la racine.
  - Texte courant de la section D extrait.
  - Les 15 images de formules de la section décodées et lues à l'image : σ_USP, Ĉ(i,j), f̂_j, MSEP, S_j, S′_j, Q̂_j, σ̂²_j, règle de minimum.
  - La section D ne porte aucun marqueur de modification.
- **JOUE L 12 du 17.1.2015** (`Règlement délégué.pdf`). Pages 276 à 278 rendues en image, avec des agrandissements à 300 et 400 ppp sur les formules de la p. 277 et sur σ̂²_j en p. 278.
  - p. 276 : D(1) à D(2)(h)(ii), dont **D(2)(e)**.
  - p. 277 : D(2)(h)(iii) à D(5)(b), dont D(3), D(4) et la formule de la MSEP.
  - p. 278 : D(5)(c) et (d).
- **Concordance entre les deux versions** :
  - D(2)(e), D(3)(a) à (d), D(4) et ses points (a) à (d), et D(5)(a) à (d) sont identiques mot pour mot et formule pour formule.
  - Seule la formule de la MSEP en tête de D(5) diffère. La version de 2015 n'a pas de crochet dans la première somme et a une double somme k = 1..I sans facteur 2 (ADR 0005). Cette différence n'affecte pas la question de la géométrie.
- **Qualité de l'image de σ̂²_j** : dégradée dans les deux sources. La borne supérieure de la somme se lit « I−j−1 », ce que corroborent le diviseur 1/(I−j−1) et la borne de f̂_j.
- **Textes connexes** (version consolidée seule) :
  - G(3)(c) : « pour la méthode du risque de réserve n° 2, au nombre d'années d'accident pour lesquelles des données sont disponibles ».
  - Art. 219(1)(a) et (b).
  - Art. 19(1)(b) : « aucune donnée pertinente n'est exclue de ce calcul sans justification ».

## 2. Matrice paragraphe par paragraphe

Abréviations : « eng. » = `R/engine.R` ; « tex » = `docs/latex/doc_tests_usp.tex` (lignes de `7eca6e4`).

| § | Texte (citation exacte ; consolidé = JOUE) | Lecture(s) | Implémentation | Documentation | Verdict | Effet possible sur σ_USP |
|---|---|---|---|---|---|---|
| **D(2)(e)** (L 12/276) | « le nombre d'années d'accident consécutives pour lesquelles des données sont disponibles n'est pas inférieur au nombre d'années de développement consécutives de la première année d'accident pour laquelle des données sont disponibles » | Une seule : I + 1 ≥ J + 1. Le texte admet donc **expressément** I > J. | `mw_valider_triangle()`, eng. l. 9846-9847 : refus si `nrow(tri) < ncol(tri)` (MW-03) | `sec:controles` (l. 3821), ligne « Forme du triangle », tex l. 4721 | **Conforme** | aucun |
| D(2)(b), (c) | « cinq années d'accident consécutives au moins » ; « pour la première année d'accident, […] cinq années de développement consécutives au moins » | Une seule : I + 1 ≥ 5 et J + 1 ≥ 5, d'où J ≥ 4 et σ̂²_{J−3} existe. | eng. l. 9840-9845 | tex l. 4719-4720 | **Conforme** | aucun |
| D(3)(a) à (d) (L 12/277) | « commençant par 0 pour la première année d'accident » ; « I représente la dernière année d'accident » ; « J représente l'année de développement la plus récente de la première année d'accident » ; « C(i,j) représente les sinistres cumulés » | Règles de notation. I et J y sont définis **indépendamment** l'un de l'autre. | En-tête de section, eng. l. 9766-9771 : matrice (I+1)×(J+1), NA pour i + j > I | tex l. 14286-14288 | **Conforme** | aucun |
| **D(4)**, formule (L 12/277) | σ_(res,s,USP) = c·√MSEP / Σ_{i=0}^{I}(Ĉ(i,J) − C(i,I−i)) + (1 − c)·σ_(res,s) (lue à l'image) | Si I = J : tous les termes sont définis. Si I > J : C(i,I−i) est **indéfini pour i < I−J** (année de développement au-delà de J). | `mw_parametre()`, eng. l. 10804-10818 ; dénominateur = `reserve`, eng. l. 10130-10135 (i = 0..I) | `sec:mw`, « Paramètre propre », tex l. 14490-14495 | **Conforme** pour I = J. Refus de R̂ ≤ 0 : interprétation déjà tranchée (M4, #7), déclarée tex l. 14507-14555, non rouverte. Pour I > J, voir **§ 3** | voir § 3 |
| D(4)(a), (b), (d) | « c représente le facteur de crédibilité visé à la section G » ; « MSEP […] telle que définie au paragraphe 5 » ; « σ_(res,s) représente le paramètre standard » | Une seule. Durée = I + 1 (G(3)(c)). | `T_cred <- aj$I + 1L`, eng. l. 10805 ; `usp_credibilite()` | tex l. 14273-14275 | **Conforme** | aucun |
| **D(4)(c)**, f̂_j | f̂_j = Σ_{i=0}^{I−j−1} C(i,j+1) / Σ_{i=0}^{I−j−1} C(i,j) | Défini pour j = 0..J−1 si I ≥ J : toutes les cellules utilisées sont observées. Il exploite toutes les années d'accident du trapèze. | eng. l. 10060-10065 | tex l. 14317 | **Conforme** | aucun |
| **D(4)(c)**, Ĉ(i,j) | « pour toutes les années d'accident et de développement » : Ĉ(i,j) = C(i,I−i) f̂_{I−i} ⋯ f̂_{j−2} f̂_{j−1} | Si I = J : défini (projection pour j > I−i). Si I > J : pour i < I−J, C(i,I−i) et le produit f̂_{I−i}…f̂_{J−1}, à indices décroissants, n'ont **pas de sens** ; pour i = I−J, le produit est vide et Ĉ = C(i,J). | eng. l. 10113-10119 : cellule observée si j ≤ I−i, sinon `Ch[i,j-1]*f[j-1]` | tex l. 14318-14319 | **Conforme** pour I = J ; pour I > J, voir § 3 | voir § 3 |
| **D(5)**, MSEP (version consolidée) | Σ_{i=1}^{I} Ĉ²(i,J)·(Q̂_{I−i}/C(i,I−i) + Q̂_{I−i}/S_{I−i} + Σ_{j=I−i+1}^{J−1} C(I−j,j)/S′_j · Q̂_j/S_j) + 2·Σ_{i=1}^{I} Σ_{k=i+1}^{I} Ĉ(i,J)·Ĉ(k,J)·(Q̂_{I−i}/S_{I−i} + Σ_{j=I−i+1}^{J−1} C(I−j,j)/S′_j · Q̂_j/S_j) (lue à l'image) | Si I = J : défini, la somme part de i = 1 parce que l'année 0 est entièrement développée. Si I > J : pour 1 ≤ i ≤ I−J, **Q̂_{I−i} n'est pas défini** (I−i ≥ J ; Q̂ n'est défini que pour j ≤ J−1 par D(5)(d)(ii)), et C(i,I−i) ne l'est pas non plus pour i < I−J. | `mw_msep()`, eng. l. 10413-10448 : Δ_i l. 10422-10428, terme de processus l. 10431-10432, termes diagonaux et croisés ×2 l. 10435-10440 | tex l. 14445-14457, encadré l. 14470-14488 | **Conforme** pour I = J (forme imprimée, bornes, facteur 2, exposant 1, indice I−i) ; pour I > J, voir § 3 | voir § 3 |
| D(5)(a) | Ĉ(i,j) « telle que définie au paragraphe 4, point c) » | Renvoi. | `Cu <- Ch[, J+1]`, eng. l. 10416 | tex l. 14450 | **Conforme** | aucun |
| D(5)(b) (L 12/277) | S_j = Σ_{i=0}^{I−j−1} C(i,j) | Défini pour j ≤ J−1 si I ≥ J. Pour I > J, S_J est même défini, mais Q̂_J ne l'est pas. | eng. l. 10124-10126 | tex l. 14447 | **Conforme** | aucun |
| D(5)(c) (L 12/278) | S′_j = Σ_{i=0}^{I−j} C(i,j) | Défini. | eng. l. 10127 | tex l. 14447 | **Conforme** | aucun |
| D(5)(d), (d)(i) | Q̂_j = σ̂²_j / f̂²_j | Défini pour j = 0..J−1. | eng. l. 10122 | tex l. 14446 | **Conforme** | aucun |
| D(5)(d)(ii), première ligne | σ̂²_j = 1/(I−j−1) · Σ_{i=0}^{I−j−1} C(i,j)(C(i,j+1)/C(i,j) − f̂_j)², pour « j = 0,…,(J – 2) » | Défini si I ≥ J. | eng. l. 10067-10074 (le garde-fou `length(idx) >= 2` est toujours vrai pour j ≤ J−2 ≤ I−2) | tex l. 14322-14326 | **Conforme** | aucun |
| D(5)(d)(ii), seconde ligne | σ̂²_j = min(σ̂²_{J−2}, σ̂²_{J−3}, σ̂⁴_{J−2}/σ̂²_{J−3}), pour « j = (J – 1) » | Si I = J : nécessaire, car la première ligne divise par I−(J−1)−1 = 0. Si I > J : la première ligne serait calculable, mais **le texte prescrit la règle de minimum pour j = J−1 sans condition sur I**. | eng. l. 10103-10111 ; cas σ̂²_{J−3} = 0 : quotient remplacé par +∞, d'où 0 (lecture du #7) | tex l. 14327-14360 ; fiche `mw:m6sig` (l. 17574) | **Conforme** pour I = J. Pour I > J, la lettre impose encore la règle de minimum : à respecter en cas d'extension (§ 4, R-4) | aucun aujourd'hui |
| **Refus MW-04** | sans texte propre : convention de l'outil | Voir § 3 | eng. l. 9848-9851 ; motivation dans l'en-tête, eng. l. 9773-9779 | `sec:controles`, ligne « Géométrie carrée », tex l. 4722-4725 ; `sec:mw`, encadré « Restriction d'implémentation », tex l. 14607-14614 ; tex l. 4856 et l. 17578 (« seule géométrie admise ») | **Deux lectures** | voir § 3 |

### Mesures faites avec Rscript

Moteur chargé par `charger_moteur()`, triangle `tests/donnees/triangle_mw.csv` (8 × 8), sous-matrices extraites, lecture seule :
- **8 × 7 (I = 7, J = 6)** : le seul refus est MW-04, « Triangle non carre (8 annees d'accident, 7 annees de developpement) : cas non couvert par les formules des paragraphes 4 et 5 de la section D de l'annexe XVII. ». D(2)(e) est rempli.
- **6 × 8 (I < J)** : deux refus, MW-03 (D(2)(e)) **et** MW-04.
- **`mw_ajuster()` sur le 8 × 7** : erreur R « subscript out of bounds », à `tri[i + 1, I - i + 1]` (eng. l. 10130, i = 0, colonne 8 sur 7). Si l'on levait le refus sans adapter le code, le moteur échouerait : MW-04 est aujourd'hui aussi une garde technique.

## 3. Géométrie I > J : les deux lectures

**Constat de texte (vérifié à l'image).** Quand I > J, les années d'accident 0 à I−J ont atteint l'année de développement J. Pour elles, D(4) et D(5) appellent des grandeurs que le texte ne définit pas :
- C(i,I−i) pour i < I−J, au dénominateur de D(4), dans Ĉ(i,J) et dans Q̂_{I−i}/C(i,I−i) ;
- Q̂_{I−i} pour 1 ≤ i ≤ I−J, dans les deux sommes de la MSEP.

Tout le reste est défini et emploie toutes les années d'accident : f̂_j, S_j, S′_j, σ̂²_j (j ≤ J−2), et les années I−J+1..I. Les formules ne se calculent donc à la lettre que si I = J. Or D(2)(e) admet I > J, et D(3)(b)-(c) définit I et J séparément. Le texte est incomplet sur ce point : il admet des données qu'il ne dit pas comment traiter.

**Lecture A, stricte, retenue par le moteur.** D(2)(e) est une condition de recevabilité, pas une promesse que les formules couvrent toute géométrie recevable. Les formules n'étant définies que pour I = J, le moteur refuse I > J, refus « explicite plutôt que traité par convention implicite » (eng. l. 9773-9779 ; tex l. 14607-14614).
- Pour : aucune valeur n'est fabriquée.
- Contre :
  - le domaine de l'outil est plus étroit que celui que D(2)(e) déclare recevable ;
  - l'entreprise qui veut se ramener à un carré doit retirer ses années d'accident anciennes. Or l'art. 19(1)(b), rendu applicable par l'art. 219(1)(a), exige qu'« aucune donnée pertinente n'[en soit] exclue […] sans justification ». Le contournement suppose donc une justification documentée. Il lui reste la méthode n° 1 (art. 220(1)(b)).

**Lecture B, extensive.** Le texte prévoit expressément I > J (D(2)(e), D(3)). Les sommes de f̂_j, S_j, S′_j et σ̂²_j sont écrites sous une forme valable pour I ≥ J. Les termes indéfinis ne concernent que des années entièrement développées en J, l'année de développement terminale des formules (Ĉ(i,J) pris pour charge ultime, ce que suppose D(2)(d) ; tex l. 4966). Elles reçoivent alors la valeur naturelle :
- Ĉ(i,J) = C(i,J) et réserve nulle ;
- contribution nulle à la MSEP (Q̂_j := 0 pour j ≥ J), ce qui revient à faire partir les sommes de i = I−J+1.

Le refus serait alors un **écart** : une restriction que le texte ne pose pas.
- Contre : cette lecture repose sur une convention que le texte n'écrit pas. Elle n'est pas « la lettre ». De plus, D(2)(d) ne vise que la première année d'accident, pas les années 1..I−J.
- Point à faire confirmer par `actuary`, sans référence citée par `regulatory` : la formule à un an restreinte aux années I−J+1..I est-elle l'erreur de Merz-Wüthrich sur un trapèze ?

**Ce que fait le code.** Lecture A. Elle est cohérente entre le code (eng. l. 9773-9779, 9848-9851) et la doc (tex l. 4722-4725, 14607-14614). La doc décrit fidèlement les deux termes indéfinis et la qualifie de « restriction d'implémentation ».

**Conséquence possible sur σ_USP**, sans calcul hors moteur :
- Lecture A : aucun changement.
- Lecture B : aucun σ_USP des références ne change (tous les triangles sont carrés). Un trapèze, refusé aujourd'hui (`ok = FALSE`), recevrait un σ_USP, avec c calculé sur I + 1 années d'accident (G(3)(c)), donc un c au moins égal à celui d'un carré tronqué. L'extension concernerait aussi `mw_bootstrap()` et les lignes M1 à M6 (fond statistique, `actuary`). Ce serait un circuit 2, avec visa du mainteneur sur σ_USP.

**Verdict : deux lectures.** Choix renvoyé à `actuary` (avis), puis au mainteneur.

## 4. Remarques, sans écart au texte

- **R-1, MW-04 redondant quand I < J** (mesuré sur le 6 × 8). Le triangle reçoit MW-03 (D(2)(e)) et MW-04. Le second attribue aux formules un refus dont le fondement est D(2)(e). Piste : n'émettre MW-04 que si D(2)(e) est rempli (I > J). À traiter avec la suite de #540.
- **R-2, trois qualifications pour la même restriction.**
  - Le motif MW-04 dit « cas non couvert par les formules des paragraphes 4 et 5 ».
  - La doc dit « restriction d'implémentation » (tex l. 4722, 14607).
  - L'ADR 0005 (l. 70) dit « convention non prescrite ».

  Sous la lecture A, une formulation juste dirait les deux choses : les formules de D(4)-D(5) ne se calculent à la lettre que si I = J, **et** l'outil refuse I > J, que D(2)(e) admet. Il serait utile que le motif et la doc disent que le domaine de l'outil est plus étroit que celui de D(2)(e), et rappellent la contrainte de l'art. 19(1)(b) sur l'exclusion de données.
- **R-3, fiche `mw:m6sig`** (tex l. 17576-17580). La phrase « ne peut être estimée, faute de degré de liberté : sous la contrainte I = J » est exacte sous la lecture A. Sous la lecture B, elle devrait dire que la règle de minimum s'applique **par prescription du texte**, même quand la première ligne serait calculable.
- **R-4, en cas d'extension.**
  - Garder la règle de minimum pour j = J−1. Calculer σ̂²_{J−1} par la première ligne serait un écart à la lettre.
  - Garder la durée G(3)(c) = I + 1.
  - Garder le refus de R̂ ≤ 0 (M4).
  - Les années 0..I−J doivent sortir des sommes de la MSEP et du dénominateur sans erreur R (garde de eng. l. 10130).

## 5. Issue

**Aucune nouvelle issue.** #540 couvre la question, et R-1 à R-4 relèvent de sa suite. Commentaire proposé pour #540, à déposer par la session sur accord du mainteneur :

> > *Rédigé par l'agent regulatory (IA).*
> Lecture faite le 12/11/2026 (version consolidée du 14.11.2024, formules lues à l'image ; JOUE L 12/276-278 lu à l'image : D(2)(e), D(3), D(4), D(5)(a)-(d) identiques, seule la MSEP diffère, ADR 0005). Les formules de D(4) et D(5) ne se calculent à la lettre que pour I = J. Pour I > J, C(i,I−i) (i < I−J) et Q̂_{I−i} (1 ≤ i ≤ I−J) sont indéfinis. Ces termes ne concernent que les années d'accident entièrement développées en J. D(2)(e) admet pourtant I > J. **Deux lectures** : (A) refus, retenu par le moteur ; (B) extension par la convention « réserve et contribution à la MSEP nulles pour i ≤ I−J », la règle de minimum restant prescrite pour j = J−1 et la durée G(3)(c) valant I + 1. Aucun σ_USP des références n'est touché dans les deux cas ; sous (B), un trapèze recevrait un σ_USP. Remarques : MW-04 redondant avec MW-03 quand I < J ; qualification de la restriction à unifier entre le motif, la doc et l'ADR 0005 ; art. 19(1)(b) sur l'exclusion de données. Choix à faire : avis d'`actuary`, puis décision du mainteneur (circuit 2). Matrice complète dans `docs/revues/20261112-lecture-d2e-540/`. Refs #527.

Libellés : `needs-info` peut être levé après la décision. Le type (`bug` ou `enhancement`) dépend de la lecture retenue et revient au mainteneur.

## Retour

- **Statut :** `complet`.
- **Preuves :**
  - Texte consolidé et JOUE lus à l'image pour D(2)(e), D(3), D(4) et D(5) : *vérifié*.
  - Correspondance terme à terme du code et du `.tex` avec le texte : *vérifié*.
  - Refus du 8 × 7 par MW-04 seul, double motif sur le 6 × 8, erreur de `mw_ajuster()` sur un trapèze : *vérifié* (Rscript, lecture seule).
  - Validité de Merz-Wüthrich sur un trapèze sous la lecture B : *non vérifié*, renvoyé à `actuary`.
  - Art. 19 et 219 : version consolidée seule, *non comparés* au JOUE.
- **Informations manquantes :** aucune pour la lecture.
- **Décision non résolue :** lecture A (refus maintenu, motif et doc précisés à KR) ou lecture B (extension, circuit 2 après la remise sauf décision contraire).
- **Critères déclenchés :** lecture à deux sens, donc circuit 2 (`docs/agents/routage.md` § 9 : `actuary` éclaire, le mainteneur tranche ; Fable non requis). Changement possible de σ_USP seulement sous la lecture B, et seulement pour des triangles aujourd'hui refusés.
- **Prochaine action recommandée :** consulter `actuary` sur la lecture B, puis décision au soixante et unième point d'étape.
