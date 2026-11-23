# Q-A1 : restitution des deux σ de la colonne J−1 d'un trapèze (#567)

Avis d'`actuary` (fiche de routine) et revue légère consultative d'`app-review`, 20/11/2026, sur la tête `7010100` de `claude/merz-wuthrich-trapeze`. Rapports versés intégralement par la session (Q-54-10). Question posée à la fin de l'étape 5, avant l'étape 6 (handoff du 20/11, point 6) : pour un trapèze, `plots_data$facteurs$sigma` porte le σ de la règle pour J−1 et `residus$sigma_j` l'estimateur direct ; restituer les deux, ou les deux avec leur usage ?

## Synthèse de la session

- `actuary` recommande la forme (ii) : les deux σ avec leur usage, fournis par le moteur (colonne `sigma_residus` en fin de `plots_data$facteurs`, `sigma` inchangée). Aucune incohérence d'usage dans le code ; égalité au bit sur un carré. Un constat majeur, effectif à la levée de MW-04 seulement (σ̂ direct non restitué avec un libellé). Termine avec questions : validation de la forme (ii) par le mainteneur.
- `app-review` confirme le besoin d'un champ du moteur (l'affichage ne doit rien déduire de `residus$sigma_j`, absent si la colonne J−1 est exclue des résidus) et relève, pour la levée de MW-04, un bloquant (grille de saisie et `lire_triangle()` de `app.R` codés pour un carré), un majeur (légende `.LEGENDE_SIGMA_REGLE` fausse pour un trapèze) et des mineurs. Aucun n'est un écart sur la branche aujourd'hui, MW-04 refusant le trapèze.
- Les deux avis convergent : colonne(s) ajoutée(s) par le moteur, libellé d'usage lu dans `res`, à traiter à l'étape 6 si D2 étend. Décision du mainteneur à prendre avec D2.

## Avis d'`actuary`

**Avis Q-A1 (S6, #567) : restitution des deux σ de la colonne J−1 d'un trapèze**

**Réponse recommandée : (ii), les deux valeurs avec leur usage, calculées dans le moteur.** La forme (i) seule ne suffit pas. Deux « σ_j » qui diffèrent en J−1 sans libellé seraient lus comme une incohérence par un relecteur de l'ACPR. Or σ̂_dir entre dans toutes les p-values fondées sur les résidus : le dossier doit donc dire qu'il existe et à quoi il sert.

Forme proposée :
- Ajouter dans `mw_plots_data()$facteurs` une colonne `sigma_residus = sqrt(.mw_sigma2_residus(aj))`, en fin de table (même convention que #310), à côté de `sigma` qui reste inchangée. Les deux colonnes sont égales partout sauf en j = J−1 d'un trapèze. C'est au moteur de le faire, pas à l'affichage (exigences § 4 et § 5.4).
- Libellés suggérés :
  - « σ_j retenu : MSEP, simulation du bootstrap, σ_USP (règle de minimum D(5)(d)(ii) en J−1) » ;
  - « σ_j des résidus : estimateur direct, résidus de Mack, influence, tests et vivier du bootstrap ».
- Graphique `plot_mw_facteurs()` : en J−1 d'un trapèze, montrer σ̂_dir par un point distinct (creux), à côté du point ambre de la règle.
- Onglet Calibration (§ 5.5, « estimations intermédiaires ») : afficher σ̂_dir comme estimation intermédiaire non retenue pour la MSEP.
- `.tex` : une phrase dans la fiche M6 « Extrapolation de sigma pour la dernière année de développement » (`sec:boot-mw` en renvoi). Pour un trapèze, σ̂²_{J−1} direct réduit les résidus, la règle de minimum alimente la MSEP et la simulation.

**Vérifié dans le code (`R/engine.R`, branche `claude/merz-wuthrich-trapeze`, tête 7010100)**
- `mw_ajuster()` (l. 13425-13474) : `sigma2_Jm1_direct` n'existe que si I > J. Il n'entre ni dans f, ni dans Ĉ, ni dans Q, donc ni dans la MSEP.
- `.mw_sigma2_residus()` (l. 13488) : rend `aj$sigma2` en remplaçant J−1 par l'estimateur direct. Trois fonctions la lisent : `mw_residus()` (l. 14370, d'où `residus$sigma_j` et `residu`), `mw_identifiabilite_intra()` (l. 15692) et `mw_influence()` (l. 17830). Par conséquent `mw_residus_redresses()`, le qqnorm et le vivier `.mw_pool_residus()` utilisent tous σ̂_dir.
- `.mw_simuler_triangle_etat()` (l. 15980) simule avec `aj$sigma2`, c'est-à-dire la règle (décision Q-2a-2). La MSEP (`mw_msep()`), le diagnostic M6 (l. 17172, `estim = aj$sigma2[aj$J]`) et `plots_data$facteurs$sigma` (l. 18142) prennent aussi la règle.
- **Aucune incohérence d'usage.** Chaque résidu standardisé est réduit par le σ estimé sur sa propre colonne, ce qui donne Σ r² = n_{J−1} − 1. La MSEP et la simulation prennent la règle prescrite. Le vivier est réduit par σ̂_dir puis remis à l'échelle de la règle : c'est l'option (c) voulue, et non un mélange fortuit.
- **Carré (I = J) : les deux coïncident au bit.** Le champ est absent, `.mw_sigma2_residus()` rend `aj$sigma2` tel quel, et la colonne J−1 n'a qu'un facteur, donc aucun résidu.

**À T = 8.** Avec I − J + 1 facteurs (2 pour 8×7), σ̂_dir a 1 degré de liberté. Il est très instable, et l'écart avec la règle peut être grand. C'est une raison de plus pour l'afficher avec son usage : sinon on donnerait à cette valeur une portée qu'elle n'a pas.

**Constats (ADR 0018)**
- **Majeur, effectif à la levée de MW-04 seulement** : σ̂_dir n'est restitué que ligne par ligne dans `residus$sigma_j`. Il n'apparaît ni dans `facteurs`, ni dans le registre des tests, ni dans le graphique. Le même nom « sigma » porte deux valeurs différentes en J−1, sans libellé. Cela touche la traçabilité d'une quantité qui entre dans les p-values. Aucun effet tant que MW-04 bloque le trapèze ; à traiter avant la levée (étape 6).
- **Mineur (non vérifié)** : je n'ai pas vérifié si l'export xlsx et le rapport figé restituent `residus$sigma_j`. Si ce n'est pas le cas, σ̂_dir n'y est nulle part. Il faut contrôler ce point avec le constat majeur.
- **Bloquant** : aucun.

**Retour**
- **Statut** : complet pour l'usage des deux σ, établi par lecture du code. Partiel pour l'export et le rapport, non vérifiés.
- **Critères déclenchés** : aucun changement de résultat (la proposition ajoute une colonne et ne touche aucune valeur).
- **Constats hors périmètre** : aucun.
- **Prochaine action recommandée** : le mainteneur valide la forme (ii). Ensuite, une tâche `coder` (colonne `sigma_residus` dans `facteurs`), une tâche `app-review` (graphique et onglet Calibration), puis `docwriter` (phrase M6). Le tout est rattaché à l'étape 6.

Termine avec questions : le mainteneur valide-t-il la forme (ii) et la colonne `sigma_residus` dans `facteurs` ?

## Revue légère d'`app-review`

Revue légère de Q-A1 (consultative, rien écrit). Base : HEAD 7010100. Je n'ai exécuté que `engine_lire_triangle()` sur une matrice 10 x 8, pour confirmer que le lecteur refuse aujourd'hui par MW-04.

**1. Où l'application affiche aujourd'hui un σ de développement**

- Un seul endroit : `plot_mw_facteurs()` (`R/display_helpers.R:1919-1995`). Il lit `pd$facteurs$sigma`, donc le σ de la règle de minimum pour j = J−1.
- La marque du point J−1 vient de `sigma_regle_minimum` (ligne 1922), avec la légende constante `.LEGENDE_SIGMA_REGLE` (ligne 1912) : « fixe par la règle de minimum, non estimé ». Le graphique est appelé par `app.R:2078` et par le rapport figé (`display_helpers.R:3059`).
- `residus$sigma_j` n'est lu nulle part : ni dans `app.R`, ni dans `display_helpers.R` (`plot_mw_residus_*`, `plot_mw_qq`, lignes 1731-1830, ne tracent que `residu`, `i`, `j`, `C`). Le tableau `residus` n'est affiché ni exporté.
- L'export xlsx et csv (`app.R:2340-2345`, `tableau_export()`) ne contient que le triangle saisi, aucun σ.
- Aucune table de σ n'existe dans l'interface.

**2. Restituer les deux σ avec leur usage**

Le moteur doit fournir de quoi l'afficher, car l'affichage ne peut pas déduire un usage.

- Après la levée de MW-04, la légende de la ligne 1912 devient inexacte pour un trapèze : σ_(J−1) y est « non estimé », alors que `mw_ajuster()` calcule `sigma2_Jm1_direct` (`R/engine.R:13425-13442`), utilisé pour les résidus (`.mw_sigma2_residus()`).
- Le drapeau `sigma_regle_minimum` (`engine.R:18143`) vaut aussi TRUE sur un trapèze.
- Le moteur doit donc ajouter à `plots_data$facteurs` des colonnes en fin de table, par exemple :
  - `sigma_direct` : l'estimateur direct, NA sauf à j = J−1 d'un trapèze ;
  - `sigma_residus` : le σ qui réduit les résidus de la colonne ;
  - éventuellement un libellé d'usage, ou un drapeau `trapeze`, lu dans `res`.
- Lire `pd$residus$sigma_j` pour j = J−1 serait une déduction fragile : la colonne J−1 peut être exclue des résidus (`colonnes_exclues`), et la valeur serait alors absente.
- Côté affichage, `plot_mw_facteurs()` doit tracer le second point, avec une légende lue dans le moteur (règle de minimum : MSEP et bootstrap ; estimateur direct : résidus). Il doit aussi inclure ce point dans `ylim_sigma` (ligne 1931, qui ne regarde que `d$sigma`). Les valeurs de `sigma` pour j < J−1 sont inchangées.
- Si le moteur renvoie le libellé d'usage, l'affichage n'a rien à décider. Si l'application doit aussi montrer J−1 comme ligne de table, ce serait une nouvelle exigence de § 5 à écrire.

**3. Hypothèses « carré » codées en dur dans l'application**

À la levée de MW-04, l'import d'un fichier trapèze cesse d'être refusé et la grille plante. Aujourd'hui le lecteur refuse (« Triangle non carré (10 années d'accident, 8 années de développement)… »), donc rien ne casse. Tout T × T ci-dessous suppose I = J :

- `app.R:1401` : `T <- nrow(tri)` pilote lignes et colonnes de la grille.
  - Lignes 1411-1428 : `0:(T-1)` pour les colonnes et `i - 1 + j <= T - 1` pour les cellules saisissables.
  - Conséquence : `tri[i, j + 1]` (ligne 1423) sort de la matrice (« subscript out of bounds ») sur un 10 x 8. Une erreur R brute atteint l'utilisateur, contre le point de contrôle « Messages ».
  - La cellule observée d'un trapèze est j ≤ min(J, I − i).
- `app.R:1457-1465`, `lire_triangle()` : construit une matrice T × T et lit `c_i_j` pour `i + j <= T - 1`. Elle renverrait un carré tronqué ou complété de NA, sans avertissement : modification silencieuse des données, contraire à § 4.4.
- `app.R:1489-1494` : la recopie au changement de méthode a la même boucle.
- `app.R:174`, `triangle_defaut()` et `app.R:247`, `triangle_vide()` : seulement des carrés. C'est acceptable, car la réinitialisation ne produit que du carré (`app.R:1590`, plafond T à 40), mais à signaler.
- `app.R:396-398`, `refus_dimension_triangle()` : le libellé « Triangle n x n » est faux pour un trapèze (appelé en 361 et 1631).
- `app.R:2342-2343`, `tableau_export()` : `data.frame(i = 0:(nrow(m) - 1), m)` et `j0..j(ncol-1)` sont corrects en forme. Mais l'export hérite de `lire_triangle()`, donc du carré tronqué.
- `app.R:1330`, `aide_donnees` : « i = 0..I, j = 0..J, i + j ≤ I » reste vrai pour un carré, mais devient faux pour un trapèze, où la cellule observée est j ≤ min(J, I − i).
- `app.R:1854` et `display_helpers.R:2491-2500, 3301` : `m$T` est présenté comme profondeur / I + 1. À contrôler au retour du moteur : si `T = I + 1`, le libellé est correct.
- Graphiques et rapport : aucun codage carré trouvé dans `display_helpers.R`.

**Classement ADR 0018, en lien avec `docs/exigences.md` § 5**

- **Bloquant à la levée de MW-04** : les points de la grille et de `lire_triangle()` (lignes 1401-1428, 1457-1465, 1489-1494). Ils sont à corriger dans le commit `app:` avant le commit `moteur:`. Ce n'est pas un écart sur la branche aujourd'hui.
- **Majeur** : la légende `.LEGENDE_SIGMA_REGLE` (ligne 1912) devient fausse pour un trapèze, et l'application ne montre pas l'usage du second σ. Il faut ajouter des champs au moteur, comme décrit au point 2.
- **Mineur** : le libellé `refus_dimension_triangle()`, l'aide de saisie (ligne 1330) et `triangle_defaut()` / `triangle_vide()`.
- **Critère de tri ADR 0018** : aucun mineur ne devient une issue ; ils se rangent sous « Constats mineurs écartés ». Le majeur et le bloquant relèvent du périmètre de #567, donc pas d'issue séparée.
