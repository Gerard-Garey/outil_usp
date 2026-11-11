# QA1 (#485) : recherche du texte d'Anscombe et Glynn (1983)

> *Rapport d'une session cloud « Accès complet » (Opus 5.5), lancée le 10/11/2026 par la session principale sur instruction du mainteneur, en lecture seule ; reçu par message entre sessions et reproduit intégralement (Q-54-10).*

Rapport QA1 (#485), `test_anscombe_kurt()`. Recherche en lecture seule : aucune écriture dans le dépôt, aucun acte sur GitHub.

## 1. Anscombe et Glynn (1983), Biometrika 70(1), 227-234 : texte non lu

- `academic.oup.com` et `doi.org` répondent 403.
- JSTOR (stable/2335960) renvoie une page de challenge anti-robot, pas l'article.
- Unpaywall et Semantic Scholar classent l'article fermé (`openAccessPdf` CLOSED), et la recherche web n'a trouvé aucune copie légitime.
- Aucune phrase, page ni numéro d'équation de l'article n'est donc cité. Le rapport ne peut pas dire ce que l'article prescrit pour un dénominateur ≤ 0 : il faudrait un accès institutionnel (JSTOR/OUP).
- Seul repère indirect, non vérifié contre le texte : SciPy annote son code « [1]_ Eq. 1 » (var b2), « Eq. 2 » (√β1), « Eq. 3 » (A), « Eq. 4 » (x) et « Eq. 5 » (Z). Ces numéros sont ceux de SciPy, pas une lecture de l'article.

## 2. D'Agostino, Belanger et D'Agostino Jr (1990), Am. Stat. 44(4), 316-321 : non lu

Article fermé (Semantic Scholar CLOSED), aucune copie trouvée.

## 3. Indices logiciels (ce ne sont pas des sources)

- `scipy.stats.kurtosistest` (`_stats_py.py`, branche main lue le 10/11/2026) calcule `term2 = sign(denom) * ((1-2/A)/|denom|)^(1/3)` : racine cubique réelle **signée** (1 − 2/A > 0). Seul `denom == 0` donne NaN, avec l'avertissement « Test statistic not defined in some cases due to division by zero ».
- Une page de documentation SciPy ancienne (vers 0.17-1.7) dirait « The Z-score is set to 0 for bad entries » : vue en extrait de recherche seulement, non vérifiée.
- `moments::anscombe.test` (archive CRAN 0.14, source lue) emploie `^(1/3)` brut, donc NaN ; l'appel plante ensuite sur `if (pval > 1)`.
- Fil r-help d'octobre 2020 (B. Dunlap, stat.ethz.ch/pipermail/r-help/2020-October/469072.html) : propose `cube_root <- function(x) sign(x)*abs(x)^(1/3)`, en écrivant « I haven't checked the formulas carefully… I think the intent was for the cube root to be a negative real ». Conjecture, pas une lecture de l'article.
- Ticket SciPy n° 1950 (même symptôme), cité par ce fil : non lu (GitHub 403).

## 4. Éléments mathématiques (analyse de la session, pas une citation)

- Z est la transformation de Wilson-Hilferty d'une variable de type khi-deux (A degrés de liberté), ajustée pour que b2 standardisé ait la moyenne, la variance et l'asymétrie exactes sous H0.
- La loi ajustée a une borne inférieure : 1 + x·√(2/(A−4)) > 0, soit x > −√((A−4)/2). À T = 40 : A = 19,358, b2 critique = 1,0686.
- Sous ce dénominateur, b2 sort du support de la loi approchante. La racine signée fait passer Z de −∞ (dénominateur → 0+) à +∞ (dénominateur → 0−) : Z n'est plus monotone en b2 (d'où Z = +35,9 pour b2 = 1, mesuré par `actuary`).
- La racine signée est incohérente avec le sens du test, bien qu'elle soit celle de SciPy. (c), Z = −∞ et p = 0, prolonge Z par monotonie (limite à droite). (a) refuse d'extrapoler l'approximation hors de son domaine.

## Conclusion QA1

- Le texte ne tranche pas, faute d'avoir pu être lu ; aucune des trois options n'est fondée sur l'article.
- Racine signée à écarter sur un argument mathématique (inversion du sens) ; son emploi par SciPy et la suggestion r-help ne la justifient pas.
- Entre (a) et (c), choix de méthode : (c) limite monotone ; (a) plus prudent, conforme à la règle « ne pas extrapoler une approximation hors de son domaine ».
- Cas hors de T = 8 (le test exige n ≥ 20).
- Recommandation : (a), sauf prescription contraire trouvée dans l'article par le mainteneur.
