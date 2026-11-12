# K3b, étape 6 (#532) : visa d'`actuary` sur la garde de `detail_runsr`

> *Avis de l'agent actuary (IA), fiche de base, le 12/11/2026, sur le diff non commité de #532 (commité ensuite en `eb4399f`).* Versé intégralement par la session principale (Refs #532).

**Avis actuary, K3b, étape 6 (#532) : garde `!is.finite(boot$stats_obs$Runsr)` en tête de `detail_runsr` (`usp_tests()`, /home/user/outil_usp/R/engine.R, l. 7318-7322).**

**Verdict : visa.**

Mon avis amont (§ 4, option (ii)) ne traitait que le cas où Runsr observée est finie. La garde le complète sans toucher au fond.

1. **Aucun texte changé.** `detail_runsr` n'est lu qu'à un seul endroit, l. 7391-7392 : `detail = if (is.finite(boot$stats_obs$Runsr)) detail_diag("Runsr", detail_runsr, ...) else local({...})`. La garde reprend exactement ce prédicat (`!is.finite(boot$stats_obs$Runsr)`). Le `NA_character_` qu'elle produit ne peut donc jamais être lu. Quand Runsr n'est pas finie, le détail de la ligne « non applicable » vient toujours de la branche `local()`, qui donne la cause via `test_runs(u, ...)$cause`. Avant la modification, ce cas passait déjà dans les branches 2, 2b ou 3 (car `p_ex_r` vaut NA par construction, l. 7303-7304), et le texte calculé là était déjà jeté.
2. **Aucune p-value, aucun type, aucun verdict changé.** `p_ex_r`, `loi`, `type`, `p_min` et `effectifs` ne dépendent pas de `detail_runsr`. Le diff ne touche à aucun de ces champs.
3. **L'assertion reste limitée à l'objet incohérent.** Avec la garde, on n'atteint le `stop()` que si les quatre conditions sont réunies : Runsr finie, `p_ex_r` non finie, π_t constant, signes identiques entre u et z. Mon raisonnement amont dit que ce cas est impossible avec un bootstrap cohérent : Runsr finie implique n1, n2 ≥ 1 et (n1, n2) ≠ (1, 1), donc une p exacte finie. Sans la garde, le `stop()` aurait été levé à tort sur une ligne « non applicable » légitime, par exemple le jeu du test (ratios 0,8 × 7 et 1,4, un seul côté de la médiane). La garde est donc nécessaire à l'option (ii), pas seulement souhaitable.
4. **Le test couvre les deux faces.** Le nouveau bloc de /home/user/outil_usp/tests/unitaires/test_statistiques.R vérifie d'abord le cas Runsr non finie : type « non applicable » et détail inchangé au caractère près. Il vérifie ensuite le cas Runsr forcée à 1 sur le même jeu : erreur avec le message exact. Dans /home/user/outil_usp/tests/unitaires/test_detail_deux_phrases.R, le seul changement est la suppression de la mention « S22 Runsr branche 2b » dans un commentaire, ce qui est cohérent.

Remarque, non bloquante : le commentaire de la garde dit « la garde precede l'assertion ci-dessous ». C'est exact, mais il serait plus clair d'écrire que le prédicat est identique à celui de l'argument `detail` de `add()`. Le lien de non-lecture serait ainsi traçable. Optionnel.

**Retour**
- **Statut** : complet pour l'analyse statique demandée.
- **Résultat** : visa sur le fond de la garde. Aucun texte affiché, aucune p-value, aucun type ni aucun verdict n'est changé. L'assertion reste réservée à l'objet bootstrap incohérent.
- **Preuves** :
  - *Vérifié* (`git diff -- R/engine.R tests/` et lecture de `R/engine.R`, l. 7296-7400) :
    - prédicat de la garde identique à celui de la l. 7391 ;
    - `p_ex_r` vaut NA quand Runsr n'est pas finie (l. 7303-7304) ;
    - `detail_runsr` n'a pas d'autre usage (grep) ;
    - les champs `loi`, `type` et `p_min` ne sont pas touchés.
  - *Hypothèse* : la propriété « Runsr finie ⇒ p exacte finie à π_t constant et signes identiques » de mon avis amont, § 4, reprise sans nouvelle démonstration ici.
  - *Non vérifié* : je n'ai pas exécuté la batterie unitaire. Le lanceur n'a pas de filtre par fichier, et l'exécution revient à `audit` ou à la skill `verifier-reproductibilite`. Je n'ai pas non plus comparé les références : aucun changement n'est attendu, ce qui reste à confirmer par `comparer_references.R`.
- **Informations manquantes** : aucune.
- **Décisions non résolues** : aucune.
- **Critères déclenchés** : aucun. Aucun changement de résultat n'est attendu, et je ne suis en désaccord avec personne.
- **Prochaine action recommandée** : `audit` fait la revue légère du diff et exécute `test_statistiques.R` et `test_detail_deux_phrases.R` (ou le lot qui les contient) sous `LC_ALL=C.UTF-8`, puis la comparaison aux références pour confirmer qu'aucun écart n'apparaît. Ensuite, commit `moteur:` avec renvoi à #532.
