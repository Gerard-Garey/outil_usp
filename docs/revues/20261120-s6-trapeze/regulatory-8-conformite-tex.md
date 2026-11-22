# Contrôle de conformité en aval du diff `.tex` de S6 (#567, #610) : regulatory, étape 8

> *Rédigé par l'agent regulatory (IA) le 22/11/2026 ; versé intégralement par la session principale.* Objet : `git diff c8840d4...f4e8f2e -- docs/latex/doc_tests_usp.tex` (commits `ddb7b0f`, `6f200c4`, `f4e8f2e` de `docwriter`). Tri de la session : r1 et r2 retenus, corrigés par `docwriter` dans sa reprise après le correctif M-1 de la revue finale ; R-a à R-c sans suite.

Rien n'a été écrit dans le dépôt : ni commit, ni issue, ni commentaire. J'ai lu `git diff c8840d4...f4e8f2e -- docs/latex/doc_tests_usp.tex` (commits `ddb7b0f`, `6f200c4`, `f4e8f2e`) et le texte résultant à la tête `f4e8f2e`.

## 0. Résultat

- **Aucun constat bloquant ni majeur.** Les passages contrôlés reprennent fidèlement l'annexe XVII, section D, sous sa forme consolidée, et la convention (B) de l'ADR 0005 (annotation du 21/11/2026, points 2 à 7, décision 1 à 7, limites (i) à (iv)).
- **Deux constats mineurs, tous deux dans le périmètre de #567** : ni σ_USP, ni un verdict, ni une p-value ne sont touchés.
  - **r1.** L'encadré dit que deux termes sont indéfinis pour I > J ; il en manque un troisième, S_{I−i}.
  - **r2.** `sec:verif` décrit mal le rôle de la transcription indépendante dans la confrontation C1.
- **Trois remarques sans écart** (R-a à R-c).
- **Aucune issue proposée** : tout relève de #567 ; correction par `docwriter` sur la branche, ou rejet par la session.

## 1. Sources lues

- **Version consolidée du 14.11.2024** (`TEXTE consolidé_ 32015R0035 — FR — 14.11.2024.xhtml`), section D.
  - Texte courant extrait : D(1) à D(5), y compris la phrase « Aux fins du point d) ».
  - Les 15 images de la section D ont été décodées et **lues à l'image** : img00 (σ_USP), img02 (Ĉ), img04 (f̂_j), img05 (MSEP consolidée : double somme k = i+1..I, facteur 2, crochet dans la première somme), img07 et img08 (S_j, S′_j), img10 (Q̂_j = σ̂²_j/f̂²_j), img13 et img14 (les deux lignes de σ̂²_j). Les domaines « j = 0,…,(J – 2) » et « j = (J – 1) » sont dans le texte courant.
- **JOUE L 12 du 17.1.2015**, p. L 12/277, rendue en image (130 ppp). On y lit la MSEP de 2015 : Σ_{i=1}^{I} Ĉ²·Q̂_{I−i}/C(i,I−i) + Σ_{i=1}^{I} Σ_{k=1}^{I} Ĉ(i,J)Ĉ(k,J)·(Q̂_{I−i}/S_{I−i} + Σ_{j=I−i+1}^{J−1} …), sans facteur 2 et sans crochet dans la première somme. On y lit aussi D(3), D(4) avec Ĉ et f̂, et D(2)(h)(iii)-(iv).
- **Articles, en version consolidée (texte courant)** : G(3)(c) ; art. 19(1)(b) ; art. 219(1)(a) et (d) ; art. 220(1)(b) et (2).
- **Moteur à `f4e8f2e`** (`git show`), pour vérifier ce que le `.tex` décrit :
  - avertissement (t1), l. 13346-13364 ;
  - `FORMAT_MENTION_MW_SIGMA_DIRECT`, l. 13809 ;
  - `MW_USAGE_SIGMA`, l. 13820 ;
  - motif « Triangle totalement dégénéré » et sa variante trapèze, l. 14095-14160.
- **Script de la confrontation C1** : `tests/msep_trapeze_mw.R`, l. 258-300.

## 2. Matrice de conformité

Les numéros de ligne renvoient au `.tex` de la tête `f4e8f2e`.

| # | Passage du `.tex` | Disposition (citation) | Verdict |
|---|---|---|---|
| 1 | Encadré `sec:mw` (l. 15945), ouverture : « D(2)(e) admet I ≥ J » | D(2)(e) : le nombre d'années d'accident consécutives « n'est pas inférieur au nombre d'années de développement consécutives de la première année d'accident » (L 12/276) | **Conforme** |
| 2 | Encadré : C(i,I−i) n'est défini que si I−i ≤ J ; Q̂_{I−i} seulement si I−i ≤ J−1 (« ni f̂_j ni σ̂²_j au-delà de j = J−1 ») | D(3)(c) : J est l'année la plus récente de la première année d'accident ; f̂_j et S_j (img04, img07) lisent C(·,j+1) et C(·,j) ; σ̂²_j n'existe que pour j ≤ J−1 (img13, img14) | **Conforme** |
| 3 | Encadré : « Pour I > J, **deux termes** sont donc indéfinis, C(i,I−i) pour i < I−J et Q̂_{I−i} pour 1 ≤ i ≤ I−J » (phrase antérieure au diff, conservée) | S_j = Σ_{i=0}^{I−j−1} C(i,j), « pour toutes les années de développement » (D(5)(b), img07) ; S_{I−i} figure dans les deux crochets de la MSEP (img05) | **Écart mineur (r1)**, voir § 3 |
| 4 | Convention (B), premier élément : au paragraphe 4, Ĉ(i,J) = C(i,J), cumul observé (« comme pour i = I−J, où le produit de f̂ est vide »), et C(i,I−i) lu C(i,J) | D(4)(c), img02 : Ĉ(i,j) = C(i,I−i)·f̂_{I−i}⋯f̂_{j−2}·f̂_{j−1} ; pour i = I−J et j = J, le produit est vide | **Conforme**. Les deux éléments de la convention sont nommés, comme le demandait R-2 (ADR, point 2) |
| 5 | Convention (B), second élément : au paragraphe 5, Q̂_j = 0 pour j ≥ J ; réserve et contribution à la MSEP nulles ; f̂_j et σ̂²_j estimés sur toutes les lignes | D(5)(d), img10 ; ADR, point 2 | **Conforme** à l'ADR (voir r1 pour le quotient Q̂/S) |
| 6 | « Dans la forme consolidée de la MSEP, seule appliquée, la convention équivaut exactement à restreindre les sommes de R̂ et de la MSEP aux années I−J+1, …, I » | img05 : k = i+1..I, facteur 2 ; img00 : R̂ = Σ_{i=0}^{I} | **Conforme**. Équivalence vérifiée à l'étape 7 (écart relatif 0 sur cinq cas, transcription à sommes complètes) |
| 7 | « elle n'a pas cet effet sur la formule publiée en 2015 (double somme sur k = 1, …, I, sans facteur 2), où des termes Ĉ(i,J)Ĉ(k,J)Δ_i restent définis et non nuls pour i > I−J et 1 ≤ k ≤ I−J » | L 12/277, lue à l'image : Σ_{i=1}^{I} Σ_{k=1}^{I}, sans facteur 2, crochet indexé par i | **Conforme** (ADR, point 3) |
| 8 | Règle de minimum : « D(5)(d)(ii) prescrit pour j = J−1 quel que soit I » (encadré) ; fiche `mw:m6sig` (l. 19010-19020) : la règle s'applique « **par prescription** du texte, dont les deux formules sont indexées sur J seul (j ≤ J−2, puis j = J−1), et non faute de degré de liberté » ; la première ligne serait calculable avec I − J degrés de liberté | D(5)(d)(ii) : première ligne « j = 0,…,(J – 2) », diviseur I−j−1 (img13) ; seconde ligne « j = (J – 1) » (img14) | **Conforme**. Le passage « faute de degré de liberté » signalé à l'étape 7 est corrigé |
| 9 | Fiche `mw:m6sig`, mention sur un trapèze : la règle s'applique par prescription ; nombre de facteurs, estimateur direct et ses I−J degrés de liberté « pour information » ; `estim` = valeur de la règle | `FORMAT_MENTION_MW_SIGMA_DIRECT` (eng. 13809) | **Conforme** au code et au texte. L'estimateur direct n'est attribué à aucune disposition |
| 10 | Fiche `mw:m6sig`, rubrique de pertinence : Q̂_{J−1} entre dans la MSEP des années i = I−J+1..I ; pour i = I−J+1 par Q̂_{I−i}/C(i,I−i) et Q̂_{I−i}/S_{I−i} (I−i = J−1) ; pour i ≥ I−J+2 par le terme j = J−1 de la somme, et dans les termes croisés | img05 | **Conforme** (exact, non exhaustif : pour i = I−J+1, Q̂_{J−1}/S_{J−1} figure aussi dans les termes croisés, comme pour i = 1 sur le carré) |
| 11 | Facteurs par colonne : J−2 et J−3 en ont I−J+2 et I−J+3 ; degrés de liberté de σ̂²_{J−3} et σ̂²_{J−2} : I−J+2 et I−J+1 ; n_j = I − j, de I à I−J+1 (l. 8732 sq.) | img13, diviseur I−j−1 ; img04, i = 0..I−j−1 | **Conforme** (arithmétique vérifiée) |
| 12 | Durée de crédibilité : « la durée I + 1 de G(3)(c), nombre d'années d'accident » (encadré) ; tableau l. 15604-15606 | G(3)(c) : « pour la méthode du risque de réserve n° 2, au nombre d'années d'accident pour lesquelles des données sont disponibles » (L 12/282) ; D(3)(a)-(b) | **Conforme** |
| 13 | Refus de R̂ ≤ 0 : « (points (i) et (ii) ci-dessus), auquel les années i ≤ I−J contribuent zéro » | D(4), img00 : aucune condition de signe ; interprétation M4 (#7), l. 15840-15911 | **Conforme**. Les renvois (i) R̂ = 0 et (ii) R̂ < 0 sont exacts |
| 14 | « D(2)(c), J + 1 ≥ 5, seule autre condition de dimension » | D(2)(c) : « pour la première année d'accident, des données sont disponibles pour cinq années de développement consécutives au moins » | **Conforme**, avec la remarque R-a |
| 15 | « Une lecture stricte, qui refuserait un triangle I > J, reste admissible ; ce n'est pas celle de l'outil » ; convention « lecture retenue par l'outil et non prescrite par le texte » | ADR 0005, décision 1 | **Conforme (E4)** : rien n'est prêté au texte |
| 16 | Avertissement, encadré (2e alinéa) et ligne « Géométrie d'un trapèze » de `sec:controles` (l. 5896-5908) : l'hypothèse que le développement des années i = 0..I−J est achevé à l'année J est à justifier par l'entreprise, « ce que D(2)(d) n'exige que de la première année d'accident » | D(2)(d) : « pour la première année d'accident, le montant de paiements cumulé de la dernière année de développement pour laquelle des données sont disponibles inclut tous les paiements de l'année d'accident à quelque différence non significative près » | **Conforme** (remarque R-b). Le texte décrit correspond au gabarit du moteur (eng. 13355-13363) |
| 17 | Ligne « Géométrie d'un trapèze » de `sec:controles` : I > J, avertissement non bloquant ; formules des paragraphes 4 et 5 calculables à la lettre seulement si I = J ; convention (B), non exigée par le texte ; domaine de l'outil = celui de D(2)(e) ; I < J relève du seul contrôle de forme | D(2)(e) ; D(4), D(5) | **Conforme**. Plus aucune mention de MW-04, de « Restriction d'implémentation » ni de « I = J imposée » dans le `.tex` (grep) |
| 18 | Texte qui suit le tableau (l. 6202-6207) : « un triangle I > J, admis par D(2)(e), ne permet pas de les appliquer à la lettre : l'outil le calcule sous une convention et le signale par un avertissement. C'est pourquoi la plupart sont bloquants » | D(2)(e) | **Conforme** pour le texte. Liaison logique devenue maladroite (R-c, rédactionnelle) |
| 19 | Encadré : troncature et art. 219(1)(a) rendant applicable l'art. 19(1)(b) ; D(2)(d) à la nouvelle première année ; méthode n° 1 et art. 220(1)(b) ; choix par l'art. 220(2) | Art. 219(1)(a) : conditions de l'art. 19(1) à (3), « les références au calcul des provisions techniques s'entendant comme des références au calcul des paramètres propres » ; art. 19(1)(b) : « aucune donnée pertinente n'est exclue de ce calcul sans justification » ; art. 220(1)(b) et (2) | **Conforme** |
| 20 | Limites (i) à (iv) de l'encadré | ADR 0005, « Limites à dire dans le dossier » (i) à (iv) | **Conforme**. (i) ne répète pas que l'acte correcteur n'est pas identifié (E7), mais la phrase est déjà au l. 15630-15634 de la même section |
| 21 | Triangle totalement dégénéré : prédicat « chaque colonne j = 0..J−2 » (l. 4558, 5965, 15921) ; colonne J−1 hors du prédicat, « sa variance est écartée de la MSEP par la règle de minimum de D(5)(d)(ii), nulle ou négligeable dès que σ̂²_{J−2} ou σ̂²_{J−3} l'est » (l. 6046-6049) | D(5)(d)(ii), img14 : min(σ̂²_{J−2}, σ̂²_{J−3}, ·) vaut 0 si l'un des deux est nul | **Conforme** à l'arithmétique et au code (eng. 14122-14160). Le constat m1 de l'étape 7 est soldé |
| 22 | Variante trapèze du motif (l. 6068-6075) : aucun résidu sur j = 0..J−2 ; l'année J−1 (I−J+1 facteurs) seule a des résidus, et sa variance n'entre pas dans la MSEP ; renvois à D(2)(h)(iv) et D(2)(a) ; art. 219(1)(d) ; art. 220(1)(b) | D(2)(h)(iv) : « la variance … est proportionnelle au montant de sinistres cumulé de l'année de développement précédente » ; D(2)(a) ; art. 219(1)(d) : « toute autre exigence supplémentaire en matière de données nécessaire à l'utilisation de chaque méthode standard » | **Conforme** au code, caractère pour caractère quant au fond. « Ne suffit pas à éprouver D(2)(h)(iv) » est un jugement de l'outil présenté comme tel (fondement L1/L2, décision de l'outil, l. 6078 sq.), pas une exigence du texte |
| 23 | `sec:trapeze-niveau` : estimateur direct = « première ligne de D(5)(d)(ii) appliquée à j = J−1 (I − J degrés de liberté) » ; il n'entre ni dans f̂, Ĉ, Q̂, la MSEP ou la simulation | D(5)(d)(ii), img13 (domaine j ≤ J−2) | **Conforme** : aucune prescription n'est attribuée, et la fiche `mw:m6sig` dit que ce domaine est dépassé. Hors texte : simulation et résidus |
| 24 | `sec:segments` (l. 2455-2460) : sur un trapèze, l'égalité avec l'erreur à un an de Merz-Wüthrich n'est établie que par concordance numérique | ADR 0005, point 8 ; limite (ii) | **Conforme** |
| 25 | `sec:verif` (l. 20227-20239) : « La MSEP et la réserve d'un trapèze … sont confrontées à `CL_MSEPs` … et à une transcription de D(4)(c) et D(5)(d)(ii) écrite sans lire le moteur … : écart relatif de la MSEP au plus 4,2×10⁻¹⁶ » | D(4)(c) (f̂), D(5)(d)(ii) (σ̂²) ; `tests/msep_trapeze_mw.R`, `c1_triangle()` | **Écart mineur (r2)**, voir § 3 |
| 26 | `mw_cellules_observees()` (index) : `TRUE` si et seulement si i + j ≤ I, soit j ≤ min(I−i, J) ; `mw_ajuster()` : dernier cumul observé C(i, min(I−i, J)) | D(3)(a)-(d) | **Conforme** |
| 27 | Index (l. 1762-1766) et usage des σ (`MW_USAGE_SIGMA`) : « σ_(J−1) de la règle de minimum (D(5)(d)(ii)) : MSEP et simulation » | D(5)(d)(ii) | **Conforme** |
| 28 | Fiche `mw:m6sig` : « Sur un triangle 8×8 … deux degrés de liberté sur un carré à T = 8 » | img13 | **Conforme** |
| 29 | Ajouts de #610 (intervalles calibrés par bootstrap imbriqué, Chang et Hall 2015) | Aucune disposition ; hors texte | **Sans objet réglementaire** (fond : `actuary`) |
| 30 | Biblio Merz-Wüthrich (2008, p. 546), I = J « par simplicité » | Hors texte | **Sans objet réglementaire** (citation déjà dans l'ADR ; pas relue ici) |

## 3. Constats

### r1 (mineur) : l'encadré dit « deux termes » indéfinis ; il en manque un, S_{I−i}

- **Où.** Encadré « Géométrie I > J (trapèze) » de `sec:mw`, l. 15949-15951. La phrase date d'avant le diff et a été conservée. L'ADR 0005, point 2, a la même lacune.
- **Texte.** D(5)(b) définit S_j = Σ_{i=0}^{I−j−1} C(i,j) « pour toutes les années de développement » (img07). Ce terme figure, par Q̂_{I−i}/S_{I−i}, dans les deux crochets de la MSEP consolidée (img05). Pour 1 ≤ i ≤ I−J−1, on a I−i ≥ J+1, et S_{I−i} somme des C(·, I−i) au-delà de J : il est indéfini.
- **Conséquence.**
  - Le second élément de la convention (Q̂_j = 0 pour j ≥ J) ne donne pas à lui seul le quotient Q̂_{I−i}/S_{I−i}, qui vaut alors 0/indéfini.
  - Le cas se produit dès que I − J ≥ 2, ce qui est le cas du trapèze 8 × 6 de référence et du 8 × 5.
  - Le résultat reste déterminé : l'encadré pose aussitôt que « la contribution à la MSEP de ces années [est] nulle » et l'équivalence avec la restriction des sommes. Le moteur ne lit jamais ces termes (`ii <- (I − J + 1L):I`). Ma transcription de l'étape 7 posait explicitement 0/S := 0 et retrouvait un écart de 0.
- **Effet.** Aucun sur σ_USP, sur un verdict ni sur une p-value. C'est une description incomplète de ce que le texte laisse indéfini, pas une affirmation fausse sur le code.
- **Correction suggérée** (`docwriter`) : « trois termes sont indéfinis : C(i,I−i) pour i < I−J, Q̂_{I−i} pour 1 ≤ i ≤ I−J, et S_{I−i} pour 1 ≤ i ≤ I−J−1, qui n'entre que par le quotient Q̂_{I−i}/S_{I−i}, lu nul ». Le point 2 de l'ADR 0005 peut recevoir la même précision, par l'annotation qui convient (`architect`).
- **Critère ADR 0018 :** dans le périmètre (#567). S'il fallait en classer un : **aucun** (pas d'effet sur σ_USP ni sur un verdict, et rien de faux n'est prêté au texte).

### r2 (mineur) : `sec:verif` décrit mal le rôle de la transcription indépendante

- **Où.** `sec:verif`, paragraphe « Trapèze I > J », l. 20227-20239.
- **Ce qu'écrit le `.tex`.** « La MSEP et la réserve d'un trapèze … sont confrontées à `CL_MSEPs` … et à une transcription de D(4)(c) et D(5)(d)(ii) écrite sans lire le moteur … : écart relatif de la MSEP au plus 4,2×10⁻¹⁶ ».
- **Ce que fait le script** (`tests/msep_trapeze_mw.R`, `transcrire()` et `c1_triangle()`, l. 264-296) :
  - la transcription calcule f̂ (D(4)(c)), σ̂²_j, la règle de minimum et l'estimateur direct (D(5)(d)(ii)), puis les passe à `CL_MSEPs` ;
  - la MSEP et R̂ du moteur ne sont comparées qu'à `CL_MSEPs` (`e["msep"]`, `e["R"]`), et, sur les six trapèzes, au tableau du par. 1.3 de la spécification ;
  - f̂, σ̂² et l'estimateur direct du moteur sont comparés à la transcription.
  - Aucune transcription de la formule de la MSEP de D(5) n'intervient dans C1. Le tableau `docs/tableaux/20261120-issue567-msep-trapeze.md`, l. 5 et 15, le dit exactement.
- **Pourquoi c'est un constat.** La phrase laisse croire que la MSEP du trapèze a été confrontée à une transcription indépendante du texte. Ce n'est pas le cas de C1 : la seule transcription de la MSEP consolidée appliquée au trapèze est celle de `regulatory` à l'étape 7 (hors dépôt, écart 0, versée dans la matrice). Les dispositions citées sont exactes, mais leur rôle est mal décrit.
- **Effet.** Aucun sur σ_USP, sur un verdict ni sur une p-value. Le défaut porte sur la traçabilité de la vérification.
- **Correction suggérée** : « La MSEP et la réserve d'un trapèze … sont confrontées à `CL_MSEPs` …, alimentée par une transcription de D(4)(c) et D(5)(d)(ii) écrite sans lire le moteur, à laquelle sont comparés f̂_j, σ̂²_j et l'estimateur direct du moteur ». L'ADR 0005, point 8 (« égales à celles de `CL_MSEPs` et d'une transcription indépendante »), a la même ambiguïté.
- **Critère ADR 0018 :** dans le périmètre (#567). S'il fallait en classer un : **E5**, la documentation dit de la vérification une chose que le script ne fait pas. La preuve est dans le code cité ci-dessus.

### Remarques sans écart

- **R-a (ligne 14).** « D(2)(c) … seule autre condition de dimension » : D(2)(b) (I + 1 ≥ 5) s'applique aussi, mais il découle de D(2)(c) et de D(2)(e) (I ≥ J ≥ 4). La formulation de l'ADR, point 7, est la même. Critère : aucun.
- **R-b (ligne 16).** « achevé à l'année J » abrège D(2)(d), qui admet « quelque différence non significative près », précisée par la phrase « Aux fins du point d) ». L'abréviation est exacte quant à l'année visée. Critère : aucun.
- **R-c (ligne 18).** Après l'ajout du cas I > J, qui n'est plus bloquant, « C'est pourquoi la plupart sont bloquants » s'enchaîne mal. C'est rédactionnel, sans affirmation sur le texte ni sur le code. Critère : aucun.

## 4. Constats hors périmètre (ADR 0018)

**Aucun.** r1 et r2 relèvent de #567, comme R-a à R-c. Leurs critères sont donnés pour mémoire (r1 : aucun ; r2 : E5).

## 5. Issue proposée

**Aucune.** Les deux constats mineurs sont dans le périmètre de la branche (#567). Ils se corrigent par un commit `docs:` de `docwriter`, ou la session les consigne sous « Constats mineurs écartés (ADR 0018) » de la PR #611, selon son tri. La précision de l'ADR 0005, points 2 et 8, revient à `architect` s'il la retient.

## 6. Retour

- **Statut : complet.** Chaque passage demandé a un verdict : l'encadré `sec:mw`, avec la convention (B), ses deux éléments et l'équivalence propre à la forme consolidée ; les limites (i) à (iv) ; la ligne « Géométrie d'un trapèze » de `sec:controles` et le texte qui suit ; le motif du triangle dégénéré ; « par prescription » dans `mw:m6sig` ; la durée I + 1 ; le refus de R̂ ≤ 0 ; D(2)(c), (d) et (e) ; les autres passages du diff qui affirment ce que prescrit le texte.
- **Preuves.**
  - Formules lues à l'image : img00, 02, 04, 05, 07, 08, 10, 13 et 14 de la version consolidée ; L 12/277 du JOUE rendue à 130 ppp. *Vérifié.*
  - Texte courant : D(2), D(3), G(3) ; art. 19, 219 et 220. *Vérifié.*
  - Correspondance du `.tex` avec le moteur (`f4e8f2e`) pour (t1), la mention M6, `MW_USAGE_SIGMA` et le motif dégénéré. *Vérifié.*
  - r2 établi sur le code de `tests/msep_trapeze_mw.R`. *Vérifié.*
  - Aucun recalcul Rscript à cette étape : le diff ne change aucune formule, et les chiffres de l'étape 7 valent toujours.
- **Décision non résolue :** aucune. Prendre en compte ou écarter r1 et r2 relève du tri de la session.
- **Critères déclenchés :** aucun. Ni σ_USP ni verdict ne changent.
- **Fichiers concernés :** `docs/latex/doc_tests_usp.tex` (l. 2455-2460, 4558, 5896-5908, 5965, 6046-6080, 6202-6207, 8732-8740, 15945-15996, 16044-16092, 19010-19050, 20227-20239) ; `tests/msep_trapeze_mw.R` (l. 258-300) ; `docs/adr/0005-msep-reserve-2-formule-imprimee-d5.md` (annotation du 21/11/2026, points 2 et 8) ; `R/engine.R` à `f4e8f2e` (l. 13346-13364, 13809-13822, 14095-14160).
