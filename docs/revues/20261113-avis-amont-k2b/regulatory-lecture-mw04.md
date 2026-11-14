# Lecture réglementaire en amont de K2b, étape 2 : motifs MW-03 et MW-04, qualification de la restriction I = J (#540, R-1 et R-2)

> *Rédigé par l'agent regulatory (IA), effort `medium`, le 13/11/2026.* Arbre lu : `claude/lecteur-xlsx-et-refus-import`, tête `ea3d007`. Lecture seule : je n'ai fait ni commit, ni issue, ni commentaire.

## 0. Résultat

- **Q1 : MW-03 est conforme.** La règle appliquée (`nrow(tri) < ncol(tri)`, donc I + 1 < J + 1) est exactement celle de D(2)(e). Le libellé abrège le texte : il omet « consécutives » et « de la première année d'accident ». C'est une imprécision mineure, pas un écart. Je propose un complément facultatif au § 2.
- **Q2, pour MW-04 :**
  - **Exacts et nécessaires** : « D(2)(e) admet I > J » et « les formules de D(4) et D(5) ne se calculent à la lettre que si I = J ».
  - **Exact, utile, à citer en entier** : le renvoi à l'art. 19(1)(b). Pour les paramètres propres à l'entreprise, il ne s'applique que par l'**art. 219(1)(a)**, qu'il faut citer avec lui.
  - **À retirer du motif** : « à défaut de quoi la méthode n° 1 reste ouverte ». La formule est **inexacte** :
    - l'emploi de la méthode n° 1 n'est pas subordonné à l'absence de justification de l'exclusion ;
    - le choix entre les méthodes n° 1 et n° 2 est réglé par l'**art. 220(2)** (méthode la plus précise, à défaut la plus prudente) ;
    - la méthode n° 1 a ses propres exigences de données (annexe XVII, section C).
  - Le texte proposé pour le motif est au § 3.
- **Q3, passages du `.tex`** :
  - **Corrects** : l. 1676, l. 7480 et l. 17643 (fiche `mw:m6sig`). Pour cette dernière, une précision est facultative.
  - **À reformuler** : l. 4781, l. 5041 et l. 14677.
- **Q4 : l'annotation du 13/11 de l'ADR 0005 est exacte sauf sur un point de fond et deux points mineurs.**
  - Point de fond : sa troisième puce reprend la formule inexacte sur la méthode n° 1 et cite l'art. 19(1)(b) sans l'art. 219(1)(a). Comme cette puce fixe la qualification commune au motif, au `.tex` et à l'ADR, l'erreur se propagerait aux trois.
  - Points mineurs : l'expression « entièrement développées en J », et la liste des critères de la suite, incomplète sans être présentée comme non exhaustive.
- **Aucun σ_USP, aucune p-value, aucun verdict n'est concerné.** Les changements ne portent que sur des libellés. **Aucune nouvelle issue** : tout relève de #540, dans le périmètre de K2b. La suite (lecture B) est #567.

## 1. Sources

- **Version consolidée du 14.11.2024** (référence de lecture), texte courant extrait du xhtml. Ce sont des textes sans formule, donc l'extraction suffit.
  - Annexe XVII, section D, points (2)(a) à (h) et paragraphe 3.
  - Art. 19(1)(b), art. 219(1)(a) à (d), art. 220(1)(b) et (2).
- **JOUE L 12 du 17.1.2015** (`Règlement délégué.pdf`), texte courant, page relevée d'après les en-têtes « L 12/n ». Les libellés sont identiques à ceux de la version consolidée :
  - art. 19(1)(b), **L 12/31** ;
  - art. 219(1), **L 12/143** ;
  - art. 220(2), **L 12/144**.
  - Je n'ai pas relu ici à l'image D(2)(e), D(4) et D(5) (L 12/276-277). Leur concordance a été vérifiée à l'image le 12/11 (`docs/revues/20261112-lecture-d2e-540/regulatory-lecture-d2e-d4-d5.md`, § 1).
- **Citations exactes utilisées** (version consolidée = JOUE) :
  - **D(2)(e)** : « le nombre d'années d'accident consécutives pour lesquelles des données sont disponibles n'est pas inférieur au nombre d'années de développement consécutives de la première année d'accident pour laquelle des données sont disponibles ».
  - **Art. 19(1)(b)** : « des données sont disponibles pour chacun des groupes de risques homogènes utilisés dans le calcul des provisions techniques, et aucune donnée pertinente n'est exclue de ce calcul sans justification ».
  - **Art. 219(1)(a)** : « les données répondent aux conditions énoncées à l'article 19, paragraphes 1, 2 et 3, […] les références au calcul des provisions techniques s'entendant comme des références au calcul des paramètres propres à l'entreprise ».
  - **Art. 220(1)(b)** : « la méthode du risque de réserve n° 1 ou la méthode du risque de réserve n° 2 pour les paramètres propres à l'entreprise remplaçant les paramètres standard visés à l'article 218, paragraphe 1, points a) iv) et c) iv) ».
  - **Art. 220(2)** : « Lorsque l'entreprise est en mesure d'utiliser plusieurs méthodes standard, elle utilise celle qui fournit les résultats les plus précis […]. Toutefois, lorsqu'une entreprise n'est pas en mesure de démontrer la plus grande exactitude des résultats d'une méthode standard par rapport aux autres […], elle utilise la méthode fournissant le résultat le plus prudent. »
- **Code lu** : `R/engine.R` l. 10061-10071 (`mw_valider_triangle()`).
- **Documents lus** :
  - le § 2 de `docs/revues/20261113-avis-amont-k2b/coder-rejeu-k2b.md` (mesures de MW-03 et MW-04, reprises sans les refaire) ;
  - la matrice du 12/11 et l'avis d'`actuary` (§ 1 et 4) ;
  - l'ADR 0005, l. 70 et 146-166 ;
  - l'issue #567 (ouverte, `enhancement`).

## 2. Question 1 : MW-03

| Élément | Texte | Code | Verdict |
|---|---|---|---|
| Règle | D(2)(e) : nombre d'années d'accident consécutives ≥ nombre d'années de développement consécutives de la première année d'accident, soit I + 1 ≥ J + 1 | `if (nrow(tri) < ncol(tri))` → refus (l. 10066-10067). `ncol(tri)` = J + 1 est le nombre d'années de développement de la ligne 0. La consécutivité tient à la structure matricielle. La complétude de la ligne 0 est contrôlée ensuite, par les cellules observées (i + j ≤ I). | **Conforme** |
| Libellé | « D(2)(e) : le nombre d'annees d'accident ne peut etre inferieur au nombre d'annees de developpement. » | — | **Conforme**, mais abrégé : sans « consécutives » ni « de la première année d'accident ». « Nombre d'années de développement » est ambigu, puisque chaque année d'accident a le sien. La forme « ne peut être » au lieu de « n'est pas » est neutre. |

Complément facultatif, sans écart à corriger : « D(2)(e) : le nombre d'annees d'accident consecutives ne peut etre inferieur au nombre d'annees de developpement de la premiere annee d'accident. »

## 3. Question 2 : éléments du futur MW-04 (émis si I > J seulement)

| Élément | Exact ? | Nécessaire dans le motif ? | Fondement |
|---|---|---|---|
| « D(2)(e) admet I > J » | **Oui** : « n'est pas inférieur » équivaut à I + 1 ≥ J + 1 | **Oui**. Sans lui, le motif laisse croire que les données méconnaissent le règlement, alors que seul le domaine de l'outil est plus étroit (R-2). | D(2)(e) |
| « D(4) et D(5) ne se calculent à la lettre que si I = J » | **Oui**. Pour I > J, C(i,I−i) est indéfini pour i < I−J : il intervient dans la formule de D(4), dans Ĉ de D(4)(c) et dans la MSEP de D(5). Q̂_{I−i} est indéfini pour 1 ≤ i ≤ I−J, puisque D(5)(d) ne le définit que jusqu'à j = J−1 (matrice du 12/11, § 3, vérifiée à l'image). | **Oui** : c'est le motif du refus. « À la lettre » est plus juste que l'actuel « cas non couvert par les formules ». Le texte ne pose pas de condition I = J : il laisse indéfinis deux termes. | Annexe XVII, section D, paragraphes 4 et 5 ; points (4)(c) et (5)(d) |
| « Se ramener à un carré exclut des données et doit être justifié (art. 19(1)(b)) » | **Exact quant au fond, citation incomplète**. L'art. 19 vise les provisions techniques. Il ne s'applique aux paramètres propres à l'entreprise que par l'art. 219(1)(a). Citer « art. 219(1)(a) et 19(1)(b) ». Le motif doit dire que l'exclusion « est à justifier », sans affirmer que les années retirées sont « pertinentes » : c'est à l'entreprise d'en juger. | **Utile.** C'est le seul élément qui dit à l'entreprise la conséquence réglementaire de son contournement. Il peut tenir en une proposition. | Art. 219(1)(a), art. 19(1)(b) |
| « À défaut, la méthode n° 1 reste ouverte » | **Non, sous cette forme.** (i) La méthode n° 1 n'est pas un repli conditionné à l'absence de justification. (ii) L'art. 220(1)(b) offre les deux méthodes, mais l'art. 220(2) en règle le choix (la plus précise, à défaut la plus prudente). Le refus par l'outil ne rend pas la méthode n° 2 inapplicable au regard du règlement, puisque D(2)(e) admet le trapèze. (iii) La méthode n° 1 a ses propres exigences de données (section C). | **Non** : à retirer du motif. Dans le `.tex`, s'il est gardé, il doit citer l'art. 220(2) et les exigences de la section C. | Art. 220(1)(b) et (2) |
| Merz et Wüthrich (2008, p. 546) | Hors texte réglementaire. Citation vérifiée par `actuary` (« For simplicity, we assume that I = J […] »). Je ne la contrôle pas. | **Non** pour un motif de refus. Elle a sa place dans le `.tex` et dans l'ADR. | — |

**Texte de motif proposé** (ASCII, sans accents ; `%d` = `nrow(tri)`, `ncol(tri)` ; le préfixe suit la notation « D(2)(e) » de MW-03) :

> Triangle non carre (%d annees d'accident, %d annees de developpement) : admis par l'annexe XVII, section D, point (2)(e), mais refuse par l'outil, les formules des paragraphes 4 et 5 de cette section ne se calculant a la lettre que si I = J. Se ramener a un carre exclut des annees d'accident : exclusion a justifier (art. 219(1)(a) et 19(1)(b)).

Variante plus courte, également exacte : « Triangle non carre (%d annees d'accident, %d annees de developpement) : admis par D(2)(e) de l'annexe XVII, hors du domaine de l'outil, les formules de D(4) et D(5) ne se calculant a la lettre que si I = J ; exclure des annees d'accident pour s'y ramener est a justifier (art. 219(1)(a) et 19(1)(b)). »

Points de conformité pour `coder` :
- la condition d'émission est `I > J`, à la place de `I != J` ;
- le texte et l'ordre de MW-03 sont inchangés ;
- les tests unitaires qui citent le texte complet (`test_controles_entree.R` l. 1664-1668 et 2135-2138, selon le rejeu de `coder`) suivent le nouveau libellé ;
- l'ancien libellé de `docs/specifications/fm-merz-wuthrich-restitution.md` l. 304 est relevé par `coder` : c'est une spécification historique, à laisser ou à annoter, au choix de la session.

Remarque pour la doc, pas pour le motif : une fois le triangle tronqué au carré, l'ancienne année d'accident I−J devient la première. Elle doit alors satisfaire **D(2)(d)** (paiements de sa dernière année de développement disponible incluant tous les paiements, à une différence non significative près). D(2)(c) reste satisfait (J + 1 ≥ 5).

## 4. Question 3 : les six passages du `.tex`

| Ligne | Passage | Verdict | Motif |
|---|---|---|---|
| **4781** | Tableau `sec:controles`, ligne « Géométrie carrée », critère I = J, « Restriction d'implémentation » et termes indéfinis | **À reformuler** | Les termes indéfinis sont décrits exactement (C(i,I−i) si I−i > J ; Q̂_{I−i} si I−i > J−1). Mais (i) le passage ne dit pas que D(2)(e) admet I > J, ni que le domaine de l'outil est plus étroit, ni ce qu'implique l'art. 219(1)(a) / 19(1)(b) (R-2) ; (ii) après R-1, le contrôle porte sur I > J seulement, et I < J relève de la ligne D(2)(e) qui précède. Le critère « I = J » reste juste en combinaison avec cette ligne, mais la condition d'émission doit être lisible. |
| **14677** | Encadré `sec:mw`, « Restriction d'implémentation » | **À reformuler** | « D(2)(e) autorise I ≥ J » et la description des termes sont exacts. En revanche : (i) « Le moteur impose **donc** I = J » présente le refus comme une conséquence nécessaire du texte, alors qu'il s'agit du choix de la lecture (A) parmi deux lectures possibles. Il faut dire que les formules ne se calculent qu'« à la lettre » pour I = J et que l'outil retient la lecture stricte. (ii) « refuse explicitement **les autres géométries** » englobe I < J, qui relève de D(2)(e) depuis R-1. (iii) La conséquence réglementaire (art. 219(1)(a) et 19(1)(b)) manque. |
| **17643** | Fiche `mw:m6sig` : « sous la contrainte I = J imposée par `mw_valider_triangle()` », 0 degré de liberté, valeur fixée par la règle de minimum de D(5)(d)(ii), seconde ligne | **Correct** | Exact sous la lecture (A), et la contrainte y est attribuée à l'outil, ce qui est cohérent avec R-2. Précision facultative : D(5)(d)(ii) prescrit la règle de minimum pour j = J−1 sans condition sur I. Elle s'applique donc par prescription, pas seulement faute de degré de liberté (R-3 du 12/11, déterminante seulement sous (B)). |
| **1676** | « un triangle carré à première colonne complète, seul admis par `mw_valider_triangle()` » | **Correct** | Constat exact sur l'outil. Il ne qualifie pas le texte. |
| **5041** | « [la] géométrie du triangle, dont dépend la simple définition des estimateurs : un triangle non carré ou incomplet ne permet pas d'appliquer les formules des paragraphes 4 et 5 » | **À reformuler** | Trop absolu pour I > J : f̂_j, S_j, S′_j et σ̂²_j (j ≤ J−2) restent définis. Seuls deux termes de D(4) et D(5) ne le sont pas, et seulement « à la lettre ». « Non carré » mêle I < J (exclu par D(2)(e)) et I > J (admis par D(2)(e), refusé par l'outil). Le passage contredit la qualification R-2. |
| **7480** | n_j = I − j, de I (colonne 0) à 1 (colonne J−1, « le triangle étant carré ») ; σ̂²_{J−3} et σ̂²_{J−2} sur 2 et 1 degrés de liberté ; σ̂²_{J−1} fixée par la règle de minimum | **Correct** | Les décomptes sont exacts pour I = J (n_{J−1} = I−J+1 = 1 ; degrés de liberté I−j−1). La condition de carré est explicite. |

La rédaction revient à `docwriter` (règle 9).

## 5. Question 4 : annotation du 13/11 de l'ADR 0005 (l. 146-166)

| Passage | Verdict | Commentaire |
|---|---|---|
| Origine (Q-61-1 (a), E-13/11, versement des revues) | **Exact** | Concorde avec `docs/feuille-de-route.md` l. 139 et 3686. |
| « D(2)(e) admet […] I > J » ; termes indéfinis C(i,I−i) (i < I−J) et Q̂_{I−i} (1 ≤ i ≤ I−J) ; textes consolidé et JOUE identiques hors formule de la MSEP | **Exact** | Conforme à la matrice du 12/11. |
| « ils ne concernent que les années d'accident entièrement développées en J » | **Imprécision mineure** | Le texte ne dit pas que ces années sont « entièrement développées ». D(2)(d) ne vise que la première année d'accident. Plus exact : « qui ont atteint l'année de développement J ». Ma matrice du 12/11 emploie aussi les deux formulations (§ 0 et § 3) : c'est la première qui est la bonne. |
| Lectures (A) et (B), statut de (B) (raisonnement, niveau non mesuré), aucun σ_USP de référence touché | **Exact** | — |
| Décision, puces 1 et 2 | **Exactes** | — |
| Décision, puce 3 : « se ramener à un carré exclut des données et doit être justifié (art. 19(1)(b)), à défaut de quoi la méthode n° 1 reste ouverte » | **À corriger** | (i) Citation incomplète : « art. 219(1)(a) et 19(1)(b) ». (ii) « À défaut de quoi la méthode n° 1 reste ouverte » est inexact (§ 3 : art. 220(2), exigences de la section C, et pas de subordination à l'absence de justification). Comme la décision impose « la même [qualification] dans le motif du moteur, dans la documentation LaTeX et ici », une nouvelle annotation datée doit la corriger avant que `coder` et `docwriter` ne la reprennent. Formulation exacte possible : « la méthode n° 1 est l'autre méthode standard de l'art. 220(1)(b), sous ses propres exigences de données (section C) ; le choix entre les deux méthodes relève de l'art. 220(2) ». |
| Décision, puce 4 (Merz et Wüthrich 2008, p. 546) | Hors de mon contrôle | Citation vérifiée par `actuary` (avis du 12/11, § 1 : « For simplicity, we assume that I = J […] »), ce qui fonde « par simplicité ». |
| « Le motif […] n'est émis que si I > J ; […] I < J relève du seul motif D(2)(e) » | **Exact** | Conforme à D(2)(e) et à R-1. |
| Ce qui ne change pas | **Exact** | — |
| Suite : critères entre parenthèses | **Incomplet, mineur** | La parenthèse omet deux critères du § 4 d'`actuary` et de #567 : l'identité au bit des six références, et **la règle de minimum gardée pour j = J−1**. Ce dernier est une exigence de la lettre de D(5)(d)(ii) (R-4 du 12/11). Il figure plus haut dans l'annotation, au titre de la lecture (B). Ajouter « notamment » ou compléter. |
| Renvois #540, #567 | **Exacts** | #567 est ouverte et porte la lecture (B) avec les sept critères. |

## 6. Issue

**Aucune nouvelle issue.** Les écarts de qualification (puce 3 de l'ADR, l. 4781, 5041 et 14677 du `.tex`, libellé de MW-04) relèvent de #540 (R-2), qui est dans le périmètre de K2b. La lecture (B) relève de #567.

## Retour

- **Statut : complet.**
- **Preuves :**
  - Textes de D(2)(e), de l'art. 19(1)(b), de l'art. 219(1)(a), de l'art. 220(1)(b) et de l'art. 220(2) dans la version consolidée : *vérifié*.
  - Art. 19(1)(b), 219(1) et 220(2) dans le JOUE (L 12/31, 143, 144) : *vérifié*, identiques.
  - D(4) et D(5) à l'image : *repris* de la matrice du 12/11, non relus.
  - Comportement de MW-03 et MW-04 : *repris* du rejeu de `coder`, non remesuré.
  - Citation de Merz et Wüthrich : *non vérifiée par moi*, vérifiée par `actuary`.
- **Décisions non résolues** : correction de la puce 3 de l'annotation du 13/11 de l'ADR 0005 (méthode n° 1, citation de l'art. 219(1)(a)), à faire avant que `coder` et `docwriter` ne reprennent la qualification ; choix entre les deux textes de motif du § 3, avec l'avis de forme d'`actuary`.
- **Critères déclenchés** : aucun. Il n'y a ni deux lectures nouvelles, ni changement de σ_USP ou de verdict, et Fable n'est pas requis.
- **Fichiers concernés** :
  - `/home/user/outil_usp/R/engine.R` (l. 10066-10071)
  - `/home/user/outil_usp/docs/adr/0005-msep-reserve-2-formule-imprimee-d5.md` (l. 146-166)
  - `/home/user/outil_usp/docs/latex/doc_tests_usp.tex` (l. 4781, 5041, 14677)
  - `/home/user/outil_usp/tests/unitaires/test_controles_entree.R`
