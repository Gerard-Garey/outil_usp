---
status: accepted
date: 2026-09-21
---

# Un catalogue unique des statistiques Monte-Carlo, une seule fonction d'enregistrement des tests

## Contexte

Une p-value Monte-Carlo naît en trois endroits que rien ne relie sauf un nom écrit en dur : le calcul de la statistique dans `.stats_bootstrapables()` (ou `.mw_stats()`), le sens du rejet dans le vecteur `queue` de `usp_bootstrap()` (ou `mw_bootstrap()`), et l'association au test par `add(mc_nom = )` dans `usp_tests()` (ou `mw_tests()`). Les deux méthodes ont chacune leur copie de `add()`, du calcul de p_mc et de la règle de verdict, avec des écarts de libellé. Conséquences relevées par l'issue #4 : un `mc_nom` inconnu ne lève aucune erreur, `gp()` renvoie NA et la p-value asymptotique est retenue et affichée comme légitime ; des statistiques sont simulées sans être exploitées (`LB2r`, `BP2r`) ; la statistique affichée peut différer de la statistique simulée (« Centrage » affiche un t de Student, la p_mc porte sur `MeanZ` ; `"Intercept"` en Merz-Wüthrich mesure une pente intra-colonne) ; une statistique dégénérée (constante par construction, issue #3) produit une p-value qui compare du bruit d'arrondi, ce qui a imposé la liste `INSTABLES` dans les tests de non-régression. Ajouter un test Monte-Carlo demande aujourd'hui de toucher trois endroits cohérents par convention.

Contrainte : `R/engine.R` reste un fichier unique (`docs/exigences.md` § 4.1) ; le module est un groupe de fonctions à l'intérieur de ce fichier.

## Décision

1. **Un catalogue par méthode** (lognormale, Merz-Wüthrich) : une structure nommée où chaque entrée définit la statistique (fonction de calcul à partir des résidus et données), le sens du rejet (`haut`, `bas`, `deux`) et, le cas échéant, sa condition de dégénérescence. Le calcul observé, la simulation et le calcul de p_mc lisent ce seul catalogue.
2. **Une seule fonction d'enregistrement** des lignes de résultat, partagée par `usp_tests()` et `mw_tests()` ; le libellé de nature (« bootstrap paramétrique », « bootstrap de résidus ») et le seuil α sont des paramètres. Elle porte seule la hiérarchie exacte > Monte-Carlo > asymptotique (ADR 0002) et la règle de verdict.
3. **Refus explicite** : un `mc_nom` absent du catalogue lève une erreur. Le repli silencieux sur l'asymptotique est interdit.
4. **La statistique affichée est celle du catalogue** : quand une ligne porte une p_mc, `stat` et `stat_nom` sont ceux de la statistique simulée ; une grandeur descriptive différente va dans `estim`.
5. **Dégénérescence détectée par le moteur** : une statistique dont la loi simulée est dégénérée (dispersion nulle à la précision machine, ou condition du catalogue vérifiée) est restituée comme diagnostic INFO avec le motif, sans p-value retenue, et jamais par repli sur une autre p-value (ADR 0001). La liste `INSTABLES` de `tests/outils_tests.R` devient sans objet.
6. **Toute statistique du catalogue est exploitée** par une ligne de résultat ; un test unitaire l'impose (déjà écrit en échec attendu dans `tests/unitaires/test_defauts_connus.R`).

Le refactor (issue #4, piste 1) est réalisé **après** la PR qui retire `MeanZ`, `VarZ`, `LB2r`, `BP2r` et passe les deux tests dégénérés en diagnostics (issue #3), et **séparément** d'elle : son critère d'acceptation est que `tests/test_reproductibilite.R` reste vert sans régénération des références. Une PR qui mêlerait les deux perdrait cette protection.

## Considered Options

- **Garder trois listes et ajouter un test de cohérence des noms** : écarté ; le test existe déjà et ne corrige ni le repli silencieux ni l'écart entre statistique affichée et simulée.
- **Éclater le moteur en un fichier par méthode pour éviter la duplication** : écarté, contraire à `docs/exigences.md` § 4.1.
- **Détecter la dégénérescence dans les tests (liste `INSTABLES`)** : écarté comme solution durable ; c'est une mesure conservatoire qui masque un défaut du moteur au lieu de le restituer au relecteur.

## Conséquences

Ajouter un test Monte-Carlo se fait en un endroit. Le moteur ne peut plus afficher une p-value asymptotique à la place d'une p-value Monte-Carlo prévue. Les résultats sont inchangés par le refactor ; les seuls changements de résultats sont ceux de l'issue #3 (deux verdicts OK → INFO), portés par leur propre PR. `docs/latex/doc_tests_usp.tex` : index des fonctions à mettre à jour (noms des nouvelles fonctions), fiches inchangées. Voir `CONTEXT.md` (statistique Monte-Carlo). Issues : #3, #4 (piste 1), #5 (chantier 1) ; feuille de route, jalon J1.
