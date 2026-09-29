# Procédure : reproductibilité et changement de résultats (GPT)

Toute différence de résultat doit être **identifiée, quantifiée et expliquée** (`docs/exigences.md` § 4.5). Les références de `tests/reference/` sont produites **par la CI seule** (ADR 0011) : ni Codex Cloud, ni Codex local, ni le poste du mainteneur ne les régénèrent. Pendant une période GPT, **le mainteneur déclenche le workflow** (ADR 0012, annotation du 28/09/2026 au soir, point 1).

Commandes depuis la racine du dépôt, sous `LC_ALL=C.UTF-8`.

## 1. Lancer les tests

`Rscript tests/test_reproductibilite.R`, qui dure environ 2 minutes.

- **Code 0** : « reproductibilité et non-régression vérifiées », avec les σ_USP affichés. Terminé.
- **« deux appels à graine identique diffèrent »** : **défaut bloquant**. Une source d'aléa sans graine ou un état global a été introduit : le trouver et le corriger. Ne jamais régénérer dans ce cas.
- **« écart à la référence »** : passer à l'étape 2.

## 2. Tableau avant / après

`Rscript tests/comparer_references.R [cas]` liste chaque grandeur en écart au seuil (1e-6 par valeur, en relatif, ou en absolu pour une référence quasi nulle), avec sa référence, sa nouvelle valeur et l'écart, plus une synthèse par fichier. `--seuil 0` liste toutes les feuilles non strictement identiques.

## 3. Expliquer chaque ligne

Chaque ligne du tableau est expliquée par la modification. Un écart inattendu est une régression : corriger le code et reprendre à l'étape 1. **Jamais** en relevant `TOLERANCE` ni en ajoutant une grandeur à `INSTABLES`, liste qui doit rester vide.

Visa, sans lequel rien n'est commité :
- tout changement de **σ_USP** ou d'un **verdict** : le mainteneur ;
- les autres changements de p-values : `actuary`.

## 4. Produire les références

- **Changement purement non numérique** (chaînes, booléens, `NA`, suppression d'une entrée) : patch chirurgical `Rscript tests/patcher_reference.R`, dans le même commit que le code, puis retour à l'étape 1 jusqu'au vert.
- **Toute autre régénération**, dans un seul commit final code + `.rds` :
  1. **`coder` prépare** le commit de code de l'issue (`R/`, `tests/` hors `tests/reference/`), depuis la tête de la branche de travail notée `<tête W>`. Il rédige les **motifs attendus par cas**, dans le format des entrées de `references.yml` :
     - `cas` : noms séparés par « , » ;
     - `attendu` : un jeu de motifs par cas, jeux séparés par « ;; », motifs d'un jeu séparés par « ; ».

     Tous les cas dont la référence change sont régénérés dans une seule exécution. Un essai à blanc local (`tests/regenerer_et_rendre_compte.R <cas> --attendu <motif> … --issue NN`, sans `--ecrire`) aide à fixer les motifs, mais le tableau de la CI fait seul foi.
  2. **Le mainteneur publie** ce commit sur la branche éphémère `gpt/regeneration-<issue>`, sans PR et jamais fusionnée : depuis son poste, ou depuis Codex en local. Il n'est jamais publié sur la branche de travail.
  3. **Le mainteneur déclenche** `references.yml` : `ref = gpt/regeneration-<issue>`, `mode = regeneration` (ou `creation` pour un cas nouveau), avec les cas, les motifs et l'issue. Il lit le tableau du résumé et donne le visa.
     - En cas de refus, la correction devient un commit supplémentaire sur la branche éphémère, suivi d'une nouvelle exécution.
     - Le mode `bascule` est hors de portée de GPT.
  4. **Fermeture, sur le poste local (Codex en local)**, puisque Codex Cloud ne peut ni recevoir l'artefact ni pousser :
     - **(a′)** Le commit calculé, lu dans `plateforme.txt`, est la tête de la branche éphémère. Sur la branche de travail : `git cherry-pick -n <tête W>..<commit calculé>`. Copier les `.rds` de l'artefact dans `tests/reference/` et les indexer. `git diff --cached --quiet <commit calculé> -- R tests ':(exclude)tests/reference'` doit rendre 0, puis `git diff --quiet -- R tests` doit rendre 0. Si la branche de travail a reçu entre-temps un commit touchant `R/` ou `tests/`, recréer la branche éphémère et relancer ; l'exécution abandonnée est citée comme **non retenue**.
     - **(b)** Les md5 des `.rds` copiés sont ceux de `md5.txt` du même artefact. On ne compare jamais le md5 d'un `.rds` écrit sur un poste.
     - **(c)** `Rscript tests/comparer_references.R --deux-parts`, avec une part non numérique vide, puis `Rscript tests/test_reproductibilite.R`.
  5. **Un seul commit nouveau** sur la branche de travail : pas d'amend ni de fixup. Son message contient :
     - le tableau avant / après ;
     - la plateforme (ImageOS, ImageVersion, R, BLAS) ;
     - l'écart maximal par fichier ;
     - le lien de la dernière exécution et le SHA calculé ;
     - les exécutions refusées ou non retenues ;
     - l'empreinte `git rev-parse <commit calculé>:R` ;
     - les md5 et le visa ;
     - la ligne `Réalisé-par: Codex (rôle coder)`.

     La branche éphémère est ensuite supprimée (par le mainteneur si l'environnement ne le permet pas).

## 5. Rendre compte

Le livrable de `coder` reprend le tableau, l'explication de chaque écart et le résultat final des tests. Chaque tableau d'une période GPT est relu par Claude à l'audit. Un commit à résultats sans tableau ni visa est un constat bloquant.
