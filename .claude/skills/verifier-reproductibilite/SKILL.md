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

4. **Faire produire les références par la CI**, seulement quand chaque écart est expliqué. **Aucune régénération hors de la CI**, poste du mainteneur compris (`docs/adr/0011-…`, point 10) : `Rscript tests/generer_references.R` en local n'a plus d'usage légitime que l'expérimentation sur un arbre non commité. Deux voies :
   - **Changement purement non numérique** (chaînes, booléens, `NA`, suppression d'une entrée) : patch chirurgical, `Rscript tests/patcher_reference.R` (premier amendement de l'ADR 0006), possible depuis toute session ; puis relancer l'étape 1 jusqu'au vert.
   - **Toute autre régénération** : mode `regeneration` du workflow `.github/workflows/references.yml` (un cas ; `tests/regenerer_et_rendre_compte.R <cas> --attendu <motifs> --issue NN --ecrire`, qui refuse toute feuille modifiée hors des motifs attendus). L'essai à blanc local, sans `--ecrire`, n'écrit rien et aide à fixer les motifs. La procédure est celle de l'en-tête du workflow et du point 3 de l'ADR 0011 (rôles M29) :
     1. **déclencher** (session principale, **sur ordre explicite du mainteneur**) par l'API GitHub (`workflow_dispatch`), sur la branche de travail, jamais sur `main`, avec `mode = regeneration`, le cas, les motifs attendus séparés par « ; » et l'issue ; noter l'identifiant de l'exécution et le commit de tête ;
     2. **lire le tableau** avant / après de l'exécution (résumé du job) ; en cas de refus, rien à commiter : corriger à la source, **jamais** en relevant `TOLERANCE` ni en ajoutant une feuille à `INSTABLES` ;
     3. **visa** : le mainteneur vise le tableau réel de cette exécution (tout changement de σ_USP ou de verdict) ou `actuary` valide les p-values sans verdict (règle de `CLAUDE.md`) ; sans visa, rien n'est commité ;
     4. **télécharger** l'artefact « references-… » de cette exécution (en session cloud, le domaine `*.blob.core.windows.net` doit être autorisé ; à défaut le mainteneur dépose l'artefact, ADR 0011 point 9) ;
     5. **vérifier** : (a) le commit calculé (`plateforme.txt`) est la tête actuelle de la branche de travail, sinon redéclencher ; (b) les md5 des `.rds` copiés dans `tests/reference/` sont ceux de `md5.txt` ; (c) `Rscript tests/comparer_references.R --deux-parts` sur les `.rds` copiés (part non numérique vide, seule la dérive entre la machine de la session et la CI apparaît), puis `Rscript tests/test_reproductibilite.R` ;
     6. **commiter** les seuls `.rds` en un commit `tests:` dont le message reprend la plateforme (ImageOS, ImageVersion, R, BLAS), l'écart maximal par fichier, le lien de l'exécution, les md5 et le visa ; pousser sur ordre du mainteneur, puis vérifier que la CI est verte.

5. **Rendre compte** : le tableau avant / après, l'explication de chaque écart, et le résultat final des tests. Ce compte rendu va dans le message de commit ou la description de la PR ; les références produites par la CI sont commitées à part, dans le commit `tests:` de l'étape 4, qui renvoie à la modification qui les justifie.

## Grandeurs instables

`INSTABLES` (dans `tests/outils_tests.R`) exclut de la comparaison aux références les grandeurs connues pour dépendre de la plateforme, chacune liée à une issue ; la liste est vide depuis la bascule sur la CI et doit le rester (ADR 0011, point 5). N'y ajoute une grandeur que si elle diffère **entre plateformes à code identique** (constat de la CI), jamais pour faire passer un test après une modification ; ouvre alors une issue et renvoie-y. `tests/comparer_references.R --tout` les inclut dans le tableau.
