<!-- Avis d'actuary (fiche de base) sur le tableau docs/tableaux/20261126-issue470-independance-tj.md, étape 6 de S8, versé tel quel le 26/11/2026. -->

## Avis actuary : S8 étape 6, tableau `docs/tableaux/20261126-issue470-independance-tj.md` (c988258), Refs #470

**Verdict : visa.** Deux remarques de forme, sans condition. Aucun résultat ne change, donc PS-2 n'est pas déclenché.

### 1. La synthèse est identique à l'ancienne
J'ai fait un `diff` complet des deux fichiers. Seules cinq lignes d'en-tête diffèrent :
- la date ;
- le plan, qui mentionne désormais « versée sous #470 » ;
- le commit : `08fceb7`, au lieu de « 2964d1f (script non suivi) » ;
- les md5 du script et du moteur ;
- la durée : 12,9 min au lieu de 22,6.

Tout le reste est identique au caractère près, pour les six couples (plan, ligne) :
- les taux ;
- D et p des KS (sur p et sur chaque t_j) ;
- les max |ρ| de Spearman, avec leur paire et leur seuil ;
- les admis (100 000, 0 écarté), la répartition de K (100 %) et m ;
- l'écart du contrôle des degrés de liberté (0,00e+00) ;
- les contrôles rejetés (0) et le critère (tenu ×6) ;
- les Limites.

L'identité est établie à la précision imprimée (4 à 5 décimales), pas au bit. Le tableau ne permet pas davantage, et cela suffit pour un constat de compatibilité.

### 2. Identité attendue malgré le changement de md5 du moteur
J'ai vérifié que `git show 2964d1f:R/engine.R | md5sum` donne bien e32a375a…, soit le moteur de l'ancienne exécution. Le script appelle six fonctions du moteur : `engine_sous_graine`, `mw_ajuster`, `mw_triangle_incomplet`, `mw_courbure_colonne`, `mw_test_ordonnee_origine` et `mw_test_courbure`. J'ai chargé les deux moteurs et comparé leur deparse, fermeture transitive comprise. Les différences sont les suivantes :
- **`mw_ajuster`** : le bloc `sigma2_Jm1_direct` ne s'exécute que si I > J (trapèze, #612/#620), et `min(I − i, J)` vaut I − i quand I = J. Sur le triangle carré 7×7 du plan, le résultat est inchangé.
- **`mw_test_ordonnee_origine` et `mw_test_courbure`** : le nouvel argument `degeneres_aj = NULL` renvoie, par défaut, à `.mw_colonne_degeneree(aj, j)`, comme avant.
- **`mw_test_ordonnee_origine`** : `lm(C1 ~ C0, weights = 1/C0)` + `summary` est remplacé par `.mw_coefs_origine()`, qui appelle `lm.wfit` avec la même matrice et les mêmes poids, puis `chol2inv` et `pt`. C'est le même calcul que `summary.lm`. Hypothèse non mesurée : ce remplacement explique le gain de durée.
- **Autres** : `.mw_exclues_vide` et `.mw_table_non_identifiables` emploient désormais la constante `.MW_DF_VIDE_J_N`, un data.frame vide identique.
- `engine_sous_graine`, le générateur aléatoire, `.fisher_combine`, `.mw_courbure_colonne` et les prédicats de dégénérescence sont identiques.

L'identité des résultats est donc attendue.

### 3. Limites et portée à T = 8 : correctement énoncées
Les quatre points demandés sont présents et exacts :
- compatibilité à N = 100 000, avec le rappel qu'un ρ nul n'établit pas l'indépendance ;
- seul modèle de Mack gaussien ajusté à `reserve2`, f et σ² fixés, plans P1 à P3 ;
- loi conditionnelle aux cumuls > 0 ;
- Bonferroni par ligne, sans correction entre les six couples.

Le statut en tête (« constat de simulation sous un plan… pas une démonstration ») est conforme aux exigences de rigueur. Le KS asymptotique est légitime ici, puisque l'échantillon de simulation compte 100 000 valeurs.

Remarque mineure, sans réserve : aucun triangle n'a été écarté dans aucun couple. Le conditionnement est donc vide en pratique, et la mention « effet de l'écart non mesuré séparément » est générique. On pourrait la préciser lors d'une future exécution, mais pas maintenant : toute modification du script impose de refaire l'exécution.

### 4. Paire de Spearman par `which.max(abs(rho))` : d'accord
Le seuil vaut `z_spearman(m) / sqrt(np − 1)` (l. 364 du script), où np est le nombre de triangles portant les deux colonnes. Ici K vaut le K prévu dans 100 % des triangles, donc np = 100 000 pour toutes les paires. Le seuil est alors constant, et l'argmax de |ρ| coïncide avec celui de |ρ|/seuil, y compris en cas d'égalité, `which.max` prenant la première occurrence. Le verdict n'en dépend pas : `n_rej` et `ok` restent calculés sur le rapport. Les paires imprimées sont d'ailleurs identiques à celles de l'ancien tableau.

### 5. Phrase de renvoi pour `docs/suivi-documentation/III-M.md` (§ `mw:m1a`, « Renvois », l. ~222), étape 7, `docwriter`
Remplacer le passage « #448, tableau `docs/tableaux/20261106-issue448-independance-tj.md`, script `tests/mesure_independance_tj_t8.R` » par :

> #448, tableau `docs/tableaux/20261126-issue470-independance-tj.md` (exécution du 26/11/2026 sur arbre propre, commit `08fceb7`, après la reprise de forme du script, #470 ; synthèse identique ligne à ligne à celle de `docs/tableaux/20261106-issue448-independance-tj.md`, exécuté sur script non suivi, qu'il remplace comme référence), script `tests/mesure_independance_tj_t8.R`

Le reste de l'entrée ne change pas. La phrase de la rubrique 4 du `.tex` est inchangée, puisque les résultats ne changent pas.

---

**Retour**
- **Statut** : complet.
- **Résultat** : visa.
- **Preuves vérifiées** :
  - `diff` complet des deux tableaux : seules cinq lignes d'en-tête et la durée diffèrent ;
  - md5 de `2964d1f:R/engine.R` = e32a375a… et md5 de `R/engine.R` = c7b767f5… ;
  - comparaison par deparse des six fonctions appelées et de leur fermeture transitive, sur les deux moteurs (Rscript, LC_ALL=C.UTF-8), avec les différences analysées au point 2 ;
  - code du choix de la paire de Spearman (l. 358-372 du script) ;
  - répartition de K à 100 % dans les six couples (l. 48 à 156 du tableau).
- **Hypothèses** : le gain de durée viendrait de `.mw_coefs_origine` (non mesuré). L'égalité au bit de `.mw_coefs_origine` et de `summary.lm` n'a pas été testée séparément ; elle n'est démontrée qu'à la précision imprimée.
- **Informations manquantes** : aucune.
- **Décisions non résolues** : aucune.
- **Critères déclenchés** : aucun. Pas de changement de résultat, pas de désaccord.
- **Constats hors périmètre** : la mention générique du conditionnement aux cumuls > 0 alors que 0 triangle est écarté. Critère ADR 0018 : aucun (mineur, de forme).
- **Prochaine action recommandée** : étape 7, `docwriter` remplace le renvoi dans `III-M.md` par la phrase du point 5.

Fichiers : /home/user/outil_usp/docs/tableaux/20261126-issue470-independance-tj.md, /home/user/outil_usp/docs/tableaux/20261106-issue448-independance-tj.md, /home/user/outil_usp/tests/mesure_independance_tj_t8.R, /home/user/outil_usp/docs/suivi-documentation/III-M.md
