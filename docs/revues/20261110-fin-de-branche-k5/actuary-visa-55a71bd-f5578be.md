<!-- Rapport d'`actuary` (fiche de base), visa des commits `55a71bd` (#518, RM-1) et `f5578be` (#499), 10/11/2026. Texte intégral rendu par l'agent. -->

## Visa de fond (règle 9) : `55a71bd` (RM-1, Refs #518) et `f5578be` (champ `validation$repere_profondeur`, Refs #499)

**Verdict : visa pour les deux commits.** Je n'ai aucune réserve et aucun texte de remplacement. J'ai une seule observation, mineure, qui ne bloque pas et ne demande aucune modification (point 3).

### 1. `55a71bd`, phrase RM-1 (sec:controles, l. 3938-3943)
Le texte ajouté reprend mot pour mot le texte de remplacement de ma réserve RM-1 (`docs/revues/20261110-fin-de-branche-k5/actuary-visa-dda1215-b9775e0.md`, § 4). Il commence à « passe par les mêmes contrôles du moteur que tout tableau (colonnes attendues, cellules numériques), sans détection propre aux fichiers binaires » et va jusqu'à « soit par ces contrôles du moteur. ». La phrase n'affirme plus de garantie universelle. RM-1 est levée. **Visa.**

### 2. `f5578be`, champ `repere_profondeur` (comparé au code de `1ddfba3`)
- **Index, `engine_valider_donnees()` (l. 730-732)** : la phrase « texte du repère de profondeur à T < 10, aussi parmi les avertissements ; vide à T ≥ 10 ou sur un refus » est exacte. Dans `R/engine.R` (l. 7973 et 8099-8108), `rep_prof` vaut `character(0)` au départ. Il n'est rempli que dans le bloc `if (!length(err))`, quand `length(xt) < 10`. C'est la même chaîne, construite une seule fois, qui va dans `avt` puis dans le champ. Tout refus passe par `err`, y compris celui de `.nature_erreurs()`, appelée en tête de la fonction : le champ est donc vide sur tout refus de la fonction. T < T_min est lui-même un refus, ce qui couvre ce cas.
- **Index, `mw_valider_triangle()` (l. 779-781)** : la phrase est exacte. Le champ vaut `character(0)` au départ (l. 8981). Il reste vide quand la fonction sort tôt sur une matrice non numérique (l. 8982-8984). Il n'est rempli que dans le dernier bloc `if (!length(err))` (l. 9166-9205), quand `nrow(tri) < 10`, c'est-à-dire I + 1 < 10. Aucune erreur n'est ajoutée dans ce bloc.
- **sec:controles, repère « lois asymptotiques peu fiables » (l. 4086-4088)** et **tableau Merz-Wüthrich, rangée « Crédibilité pleine » (l. 4582-4584)** :
  - « le même texte est rendu » : exact, c'est la même variable.
  - « que l'application lit pour l'afficher non replié en tête de l'onglet Tests, sous la règle des verdicts » : exact. `app.R` (l. 1543-1548) place `html_regle_verdicts()` puis `html_repere_profondeur()` en tête du `tagList`. `R/display_helpers.R` (l. 426-432) se contente de lire le champ, sans seuil ni reconnaissance du texte.
  - Le texte est cohérent avec l. 5916, où la règle des verdicts est affichée en tête du tableau des tests.
- **Statut non réglementaire** : le paragraphe le qualifie toujours de « convention de l'outil, sans source ». La qualification statistique n'a pas changé. Aucun résultat ne change : le commit de code est un patch non numérique, et aucun σ_USP, verdict ni p-value n'est modifié. Ce point est déclaré dans `1ddfba3` ; je n'ai pas relancé les références.

### 3. Observation mineure (non bloquante, aucune modification demandée)
« vide … sur un refus » vaut pour **la valeur rendue par les deux fonctions**, et c'est bien à elles que l'index rattache la phrase. En revanche, dans l'objet `run_engine()`, certains refus posés **après** la validation ajoutent des erreurs à `validation` sans vider ni `avertissements` ni `repere_profondeur` :
- nature « brutes » en `reserve2` (l. 13284-13287) ;
- refus de `mw_valider_ajustement()` (l. 13338-13339) ;
- refus de `usp_valider_ajustement()` (l. 13996-13997) ;
- erreur R interceptée (l. 13209-13210).

Dans ces cas, `res$validation$repere_profondeur` peut contenir le texte alors que `ok = FALSE`. Le champ se comporte alors comme `avertissements`, ce qui est cohérent. L'application n'affiche rien, puisque `html_repere_profondeur()` rend `NULL` si `!isTRUE(res$ok)`. Comme aucune phrase du `.tex` n'affirme que le champ est vide pour l'objet de `run_engine()`, le texte est exact tel qu'il est écrit. À l'inverse, une T demandée refusée vide bien le champ dans `engine_valider_serie_retenue()` (l. 8185), comme les avertissements. Il n'y a pas d'écart à corriger.

### Classement
| Objet | Verdict | Classement |
|---|---|---|
| `55a71bd`, phrase RM-1 | visa (texte de la réserve repris mot pour mot) | — |
| `f5578be`, index des deux fonctions | visa | — |
| `f5578be`, sec:controles et tableau MW | visa | — |
| Champ non vidé sur les refus de `run_engine()` postérieurs à la validation | observation, pas d'écart dans le `.tex` | mineur, sans suite requise |

## Retour
- **Statut** : `complet`.
- **Résultat** : visa pour `55a71bd` et `f5578be`, sans réserve. Une observation mineure, sans modification demandée.
- **Preuves** :
  - *Vérifié* :
    - diffs `git show HEAD~1 HEAD -- docs/latex/doc_tests_usp.tex` et `git show 1ddfba3 -- R/engine.R` ;
    - code `R/engine.R` l. 7966-8108, 8165-8188, 8976-9207, 13200-13220, 13278-13292, 13330-13345, 13990-14000 ;
    - `R/display_helpers.R` l. 415-432 et `app.R` l. 1540-1548 ;
    - texte RM-1 relu dans `docs/revues/20261110-fin-de-branche-k5/actuary-visa-dda1215-b9775e0.md` § 4 ;
    - `LC_ALL=C.UTF-8 Rscript tests/concordance_doc_moteur.R --strict` : « BILAN : 0 ecart(s) (mode strict) ».
  - *Hypothèse* : aucune.
  - *Non vérifié* :
    - je n'ai pas relancé la compilation LaTeX ; le commit annonce 0 erreur ;
    - je n'ai pas relancé les références ni les tests unitaires ; `1ddfba3` annonce 3661/3661 et 6 cas conformes ;
    - le rendu visuel de l'onglet Tests relève d'`app-review`.
- **Informations manquantes** : aucune.
- **Décisions non résolues** : aucune. La session peut choisir d'ouvrir une issue sur l'observation du point 3 si elle veut préciser, à l'index de `run_engine()`, le sort du champ sur les refus postérieurs. Je ne le recommande pas, car le comportement est déjà cohérent avec `avertissements`.
- **Critères déclenchés** : aucun. Il n'y a ni changement de résultat, ni désaccord, ni double lecture.
- **Prochaine action recommandée** : verser ce rapport dans `/home/user/outil_usp/docs/revues/20261110-fin-de-branche-k5/`, puis passer au commit du PDF et à la sortie du brouillon selon le circuit de fin de branche.
