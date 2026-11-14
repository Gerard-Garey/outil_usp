# Contrôle de `regulatory` sur la lecture réglementaire de #540 dans le `.tex` (étape 9 de K2b)

> Versé intégralement par la session principale (Q-54-10). Fiche de base. 14/11/2026. Arbre lu : tête `e3eb7e7` ; les trois passages de `2e49464` n'ont pas changé depuis ce commit. Lecture seule.

## Verdict global

**Les trois passages sont conformes.** La qualification de l'annotation bis de l'ADR 0005 (points 1 à 5) est reprise exactement. Aucun écart ; aucun σ_USP, p-value ou verdict n'est touché.

Deux points restent en dehors de ce verdict :
- une précision facultative sur D(2)(d) ;
- la question annexe : les deux phrases visées sont **inexactes**, de la même façon que la formule corrigée par l'annotation bis. Correction mot pour mot plus bas.

## Sources

**Version consolidée du 14.11.2024.** Texte courant (articles sans formule) extrait de l'art. 19(1)(b), de l'art. 219(1)(a), de l'art. 220(1)(b) et (2), et de l'annexe XVII D(2)(b) à (e), vérifié mot pour mot. Pages du JOUE : L 12/31, 143, 144 et 276.

**Formules de D(4) et D(5) (images).** Non relues à l'image dans ce contrôle ; reprise de la lecture à l'image du 12/11 (`docs/revues/20261112-lecture-d2e-540/regulatory-lecture-d2e-d4-d5.md`, § 2-3) :
- C(i,j) n'est défini que pour j ≤ J (D(3)(c)) ;
- Q̂_j n'est défini que pour j ≤ J−1 (D(5)(d)) ;
- les sommes de la MSEP partent de i = 1, celle de D(4) de i = 0.

**Merz et Wüthrich (2008).** Passage vérifié sur le PDF de la CAS : « For simplicity, we assume that I = J (note that all our results can be generalized to the case I > J) », **p. 546** (E-Forum, Fall 2008, p. 542-568). Entrée présente dans la bibliographie (l. 20400).

**Code.** `mw_valider_triangle()` (`R/engine.R` l. 10204 et suivantes) : MW-03 si `nrow < ncol` ; MW-04 si `I > J` seulement (R-1) ; texte de MW-04 conforme à la décision 2.

## Matrice

| # | Passage (`docs/latex/doc_tests_usp.tex`) | Texte réglementaire | Verdict | Correction proposée |
|---|---|---|---|---|
| 1 | Encadré « Restriction d'implémentation » de `sec:mw`, phrase « D(2)(e) autorise I ≥ J » | Annexe XVII D(2)(e) : « le nombre d'années d'accident consécutives […] n'est pas inférieur au nombre d'années de développement consécutives de la première année d'accident » (L 12/276), soit I+1 ≥ J+1 | Conforme | — |
| 2 | Même encadré : « ne se calculent à la lettre que si I = J ». Termes indéfinis : C(i,I−i) si I−i > J, donc i < I−J ; Q̂_{I−i} si I−i > J−1, donc 1 ≤ i ≤ I−J. Ces termes « ne concernent que les années d'accident ayant atteint l'année de développement J » | D(3)(c) ; D(4) et D(4)(c) ; D(5) et D(5)(d)(i)-(ii) (lecture à l'image du 12/11) | Conforme. Bornes exactes : la MSEP commence à i = 1. La formule remplace à bon droit « entièrement développées » (point mineur (vi)) | — |
| 3 | Même encadré : « refus = choix d'une lecture stricte retenue par l'outil, non une exigence du texte ; domaine plus étroit que D(2)(e) ; I < J ne relève que de D(2)(e) » | D(2)(e). Code : MW-04 si I > J, MW-03 si I < J | Conforme, cohérent avec R-1 et le code | — |
| 4 | Même encadré : exclusion d'années d'accident à justifier, « l'article 219, paragraphe 1, point a) rendant applicable l'article 19, paragraphe 1, point b), selon lequel aucune donnée pertinente n'est exclue sans justification » | Art. 219(1)(a) : « … les références au calcul des provisions techniques s'entendant comme des références au calcul des paramètres propres à l'entreprise » (L 12/143). Art. 19(1)(b) : « aucune donnée pertinente n'est exclue de ce calcul sans justification » (L 12/31) | Conforme. Paraphrase sans guillemets ; les deux articles sont cités ensemble | — |
| 5 | Même encadré : « après la troncature, D(2)(d) s'applique à la nouvelle première année d'accident » | D(2)(d) : « pour la première année d'accident, le montant de paiements cumulé de la dernière année de développement pour laquelle des données sont disponibles inclut tous les paiements de l'année d'accident à quelque différence non significative près » ; D(3)(a) : numérotation à partir de 0 pour la première année d'accident | Conforme. La phrase suppose implicitement que la troncature retire les années les plus anciennes, seul moyen d'obtenir un triangle | Facultatif : « après la troncature des années d'accident les plus anciennes, D(2)(d) s'applique à la nouvelle première année d'accident. » |
| 6 | Même encadré : « La méthode du risque de réserve n° 1 est l'autre méthode standard de l'article 220, paragraphe 1, point b), sous ses propres exigences de données (section C) ; le choix entre les deux méthodes relève de l'article 220, paragraphe 2. » | Art. 220(1)(b) : « la méthode du risque de réserve n° 1 ou la méthode du risque de réserve n° 2 … » ; art. 220(2) : la plus précise, à défaut la plus prudente (L 12/144) | Conforme. Reprend le point 4 corrigé de l'annotation bis | — |
| 7 | Même encadré : Merz et Wüthrich (2008, p. 546), « supposent aussi I = J, par simplicité, et notent que leurs résultats se généralisent au cas I > J, sans en imprimer la formule » | Hors du règlement. Citation vérifiée, p. 546 | Conforme | — |
| 8 | `sec:controles`, ligne « Forme du triangle » : I+1 ≥ J+1, D(2)(e), bloquant | D(2)(e) | Conforme. Correspond à MW-03 (`nrow < ncol`) | — |
| 9 | `sec:controles`, ligne « Géométrie carrée » : I = J (motif émis si I > J), termes indéfinis, points 1 et 2, I < J renvoyé au contrôle de forme, renvoi à l'encadré | D(2)(e) ; D(4)-D(5) | Conforme. Suit la répartition de l'annotation bis et le code (MW-04 si I > J) | — |
| 10 | Encadré « Différence de nature », trois cas : triangle incomplet (formules non applicables), I < J (exclu par D(2)(e)), I > J (admis par D(2)(e), formules non applicables « à la lettre ») | D(2)(e) ; D(4)-D(5) ; cellules i+j ≤ I nécessaires à f̂_j et S_j (D(4)(c), D(5)(b)) | Conforme. La séparation des trois cas lève l'écart relevé le 13/11 (l. 5041, « non carré » qui mêlait I < J et I > J) | — |

## Question annexe (avis) : « l'article 220, paragraphe 1, point b) laisse ouverte la méthode n° 1 »

**Constat : la formule est inexacte, du même type que celle corrigée par l'annotation bis**, quoique moins grave puisqu'elle ne dit pas « à défaut de quoi ».

- **(i) « Laisse ouverte » présente la méthode n° 1 comme un repli acquis.** L'art. 220(1)(b) la prévoit comme méthode standard au même titre que la n° 2. Mais elle n'est utilisable que sous ses propres exigences de données (annexe XVII, section C ; art. 219(1)(d)). Le refus de R̂ ≤ 0 ne garantit donc pas qu'un paramètre propre reste accessible.
- **(ii) Les deux formules conclusives disent plus que le texte.** « En garantit l'admissibilité » (l. 3979-3980) : aucune disposition des art. 218 à 220 ne fonde l'admissibilité d'un refus de l'outil. « Ne prive l'entreprise d'aucun droit » (l. 5060) est une affirmation juridique que le règlement ne porte pas.
- **(iii) Sur l'art. 220(2).** Le `.tex` dit lui-même (l. 4439-4444) qu'il n'est pas invoqué quand la méthode n° 2 ne fournit pas de paramètre. La correction doit rester cohérente avec ce passage : ne pas faire de l'art. 220(2) le fondement, seulement dire que le choix entre méthodes relève de lui.

**Correction proposée pour les l. 3978-3980.** Remplacer « l'article~220, paragraphe~1, point~b), qui laisse ouverte la méthode du risque de réserve n\textsuperscript{o}~1, en garantit l'admissibilité. » par :

> l'article~220, paragraphe~1, point~b) prévoit aussi la méthode du risque de réserve n\textsuperscript{o}~1, l'autre méthode standard, sous ses propres exigences de données (section~C)~; le choix entre les deux méthodes, quand l'entreprise est en mesure d'utiliser l'une et l'autre, relève de l'article~220, paragraphe~2.

**Correction proposée pour les l. 5059-5062.** Remplacer « Le refus ne prive l'entreprise d'aucun droit~: comme pour une réserve négative (§\ref{sec:mw}), l'article~220, paragraphe~1, point~b) laisse ouverte la méthode du risque de réserve n\textsuperscript{o}~1. » par :

> Comme pour une réserve négative (§\ref{sec:mw}), l'article~220, paragraphe~1, point~b) prévoit aussi la méthode du risque de réserve n\textsuperscript{o}~1, l'autre méthode standard, sous ses propres exigences de données (section~C)~; le choix entre les deux méthodes relève de l'article~220, paragraphe~2.

**Passages voisins de la même famille, signalés sans être rouverts :**
- **l. 4880-4881**, tableau « Applicabilité de D(4) » : « méthode n\textsuperscript{o}~1 ouverte par l'article~220, paragraphe~1, point~b) ». Proposé : « méthode n\textsuperscript{o}~1 prévue par l'article~220, paragraphe~1, point~b), sous ses propres exigences (section~C) ».
- **l. 14658-14663**, `sec:mw`, puce « Le refus ne prive l'entreprise d'aucun droit… conserve la première… condition de son admissibilité ». Même défaut, mais il appartient à l'interprétation tranchée par M4 et #7 ; non rouvert. « Conserve la première » omet les exigences de la section C ; au mainteneur de décider s'il l'aligne.
- **l. 4442-4444**, « le choix éventuel avec la méthode n° 2 relève de l'entreprise » : le choix relève de l'entreprise **selon l'art. 220(2)**. Précision facultative.

Ces corrections ne relèvent que de la rédaction (pas de σ_USP, de p-value ni de verdict) et entrent dans #540, dans le périmètre de K2b, selon `regulatory`. La rédaction revient à `docwriter`, sans nouvelle issue.

## Issue

Aucune : aucun écart dans le périmètre contrôlé.

## Suite donnée par la session

Désaccord avec `actuary-approfondi` sur le périmètre (hors K2b selon lui) ; le mainteneur a tranché le 14/11/2026 : correction dans K2b, `.tex` seul (l. 3979, 4885, 5064), puce de `sec:mw` et motif du moteur hors K2b. Appliqué par `docwriter` en `30bed39`.
