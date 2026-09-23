---
name: verifier-reproductibilite
description: Vérifier la reproductibilité et la non-régression du moteur après une modification, et documenter tout changement de résultats (tableau avant / après) avant de régénérer les références. À utiliser après toute modification de R/engine.R, avant un commit ou une PR, ou quand les tests échouent.
---

# Vérifier la reproductibilité

Toute différence de résultat doit être **identifiée, quantifiée et expliquée** (`docs/exigences.md`, § 4.5). Cette procédure produit cette traçabilité, dans le même format à chaque fois.

Commandes depuis la racine du dépôt. `Rscript` est dans le PATH grâce au hook de session ; à défaut, sous Windows : `"/c/Program Files/R/R-4.3.1/bin/Rscript.exe"`.

## Étapes

1. **Lancer les tests** : `Rscript tests/test_reproductibilite.R` (~2 min).
   - Code de sortie 0 → terminé : rapporte « reproductibilité et non-régression vérifiées » avec les σ_USP affichés.
   - Échec « deux appels à graine identique diffèrent » → **défaut bloquant** : une source d'aléa sans graine ou un état global a été introduit. Le trouver et le corriger ; ne jamais régénérer les références dans ce cas.
   - Échec « écart à la référence » → étape 2.

2. **Produire le tableau avant / après** : `Rscript tests/comparer_references.R [cas]`. Il applique le critère de non-régression (`comparer_objets()`, `tests/outils_tests.R` : 1e-6 par valeur, en relatif, ou en absolu pour une référence quasi nulle ; ADR 0006, second amendement). Il liste chaque grandeur **en écart au seuil**, avec sa valeur de référence, sa nouvelle valeur et l'écart, et affiche une ligne de synthèse par fichier (nombre de feuilles non strictement identiques, écart maximal et feuille qui l'atteint). La dérive de plateforme sous le seuil n'est pas listée ; `--seuil 0` liste toutes les feuilles non strictement identiques, par exemple pour documenter un changement plus fin que 1e-6.

3. **Expliquer chaque ligne** du tableau par la modification effectuée. Toutes les lignes doivent être expliquées :
   - écart attendu et expliqué → étape 4 ;
   - écart inattendu ou inexplicable → c'est une régression : corriger le code et reprendre à l'étape 1.

4. **Régénérer les références**, seulement quand chaque écart est expliqué : `Rscript tests/generer_references.R [cas]`, puis relancer l'étape 1 jusqu'au vert.

5. **Rendre compte** : le tableau avant / après, l'explication de chaque écart, et le résultat final des tests. Ce compte rendu va dans le message de commit ou la description de la PR ; les références régénérées sont commitées avec la modification qui les justifie.

## Grandeurs instables

`INSTABLES` (dans `tests/outils_tests.R`) exclut de la comparaison aux références quelques grandeurs connues pour dépendre de la plateforme, chacune liée à une issue. N'y ajoute une grandeur que si elle diffère **entre plateformes à code identique** (constat de la CI), jamais pour faire passer un test après une modification ; ouvre alors une issue et renvoie-y. `tests/comparer_references.R --tout` les inclut dans le tableau.
