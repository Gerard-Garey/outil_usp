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
     1. **déclencher** (session principale, **sur ordre explicite du mainteneur**) sur une **branche éphémère** (M30), jamais sur `main` ni sur la branche de travail : faire le commit de code en local sur la branche de travail **sans le pousser sur celle-ci** (son parent est la tête distante de la branche de travail), le pousser seul par `git push origin HEAD:refs/heads/claude/regeneration-<issue>`, puis déclencher par l'API GitHub (`workflow_dispatch`) avec `ref = claude/regeneration-<issue>`, `mode = regeneration`, le cas, les motifs attendus séparés par « ; » et l'issue ; noter l'identifiant de l'exécution et le commit calculé (en tête du résumé du job) ;
     2. **lire le tableau** avant / après de l'exécution (résumé du job) ; en cas de refus, rien à commiter : corriger à la source (nouveau commit calculé, nouvelle exécution sur la branche éphémère), **jamais** en relevant `TOLERANCE` ni en ajoutant une feuille à `INSTABLES` ;
     3. **visa** : le mainteneur vise le tableau réel de cette exécution (tout changement de σ_USP ou de verdict) ou `actuary` valide les p-values sans verdict (règle de `CLAUDE.md`) ; sans visa, rien n'est commité ;
     4. **télécharger** l'artefact « references-… » de cette exécution (en session cloud, le domaine `*.blob.core.windows.net` doit être autorisé ; à défaut le mainteneur dépose l'artefact, ADR 0011 point 9) ;
     5. **vérifier** : (a) le commit calculé (`plateforme.txt`) est le commit de code poussé sur la branche éphémère, et son parent est la tête distante actuelle de la branche de travail, sinon rebaser et redéclencher ; (b) les md5 des `.rds` copiés dans `tests/reference/` sont ceux de `md5.txt` ; (c) `Rscript tests/comparer_references.R --deux-parts` sur les `.rds` copiés (part non numérique vide, seule la dérive entre la machine de la session et la CI apparaît), puis `Rscript tests/test_reproductibilite.R` ;
     6. **commiter** code et `.rds` en **un seul commit** sur la branche de travail : `git add tests/reference/<cas>.rds` puis `git commit --amend` du commit calculé (préfixe du commit de code), dont le message reprend le tableau avant / après, la plateforme (ImageOS, ImageVersion, R, BLAS), l'écart maximal par fichier, le commit calculé, le lien de l'exécution, les md5 et le visa ; **avant de pousser**, vérifier que l'arbre ne diffère de celui du commit calculé que par le `.rds` : `git diff --quiet <calculé> HEAD -- . ':!tests/reference'` (code de sortie 0) et `git diff --name-only <calculé> HEAD` (seul `tests/reference/<cas>.rds`) ; pousser sur la branche de travail sur ordre du mainteneur, vérifier que la CI est verte, puis supprimer la branche éphémère : `git push origin --delete claude/regeneration-<issue>`.

   La **bascule** (une seule fois, trois cas) garde sa procédure propre : déclenchée sur la branche de travail, `.rds` seuls dans un commit `tests:` (en-tête de `references.yml`).

5. **Rendre compte** : le tableau avant / après, l'explication de chaque écart, et le résultat final des tests. Ce compte rendu va dans le message de commit ou la description de la PR ; les références d'une régénération produites par la CI entrent dans le même commit que le code qui les justifie (étape 4, M30).

## Grandeurs instables

`INSTABLES` (dans `tests/outils_tests.R`) exclut de la comparaison aux références les grandeurs connues pour dépendre de la plateforme, chacune liée à une issue ; la liste est vide depuis la bascule sur la CI et doit le rester (ADR 0011, point 5). N'y ajoute une grandeur que si elle diffère **entre plateformes à code identique** (constat de la CI), jamais pour faire passer un test après une modification ; ouvre alors une issue et renvoie-y. `tests/comparer_references.R --tout` les inclut dans le tableau.
