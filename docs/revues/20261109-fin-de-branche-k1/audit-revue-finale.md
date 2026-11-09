# Revue finale complète (règle 10) : PR #511, branche K1 `claude/entrees-et-validation`, tête `39111c0`

**Verdict : conforme avec réserves.** Je n'ai trouvé aucun constat bloquant ni majeur. Il reste cinq constats mineurs et un défaut hors périmètre, pour lequel je propose une issue. Les trois batteries passent, les résultats numériques sont identiques au bit près à ceux de `main`, et seuls les `detail` changent.

Je n'ai rien écrit dans le dépôt : `git status` est vide, la liste des stash aussi. Mes fichiers de travail sont dans `/tmp/audit_k1/` :
- scripts : `/tmp/audit_k1/adv/a1.R` à `/tmp/audit_k1/adv/a7.R`, `/tmp/audit_k1/adv/cmp_ref.R`, `/tmp/audit_k1/adv/cmp_ver.R`, `/tmp/audit_k1/adv/run_cas.R` ;
- journaux : `/tmp/audit_k1/unitaires.log`, `/tmp/audit_k1/repro.log`, `/tmp/audit_k1/conc.log`, `/tmp/audit_k1/a5.log`.

## Vérifications exécutées (R 4.3.3, `LC_ALL=C.UTF-8`, conteneur à 4 cœurs)

| Vérification | Résultat |
|---|---|
| `tests/test_unitaires.R --parallele` (shiny et plotly présents, openxlsx absent) | 53 fichiers, **3530 assertions, toutes OK**, code de sortie 0. Un seul bloc sauté : le chemin openxlsx de #483 (couvert à part, ligne ci-dessous) |
| `tests/test_reproductibilite.R` | 6 cas **CONFORME**, écart maximal 0, code de sortie 0 |
| `tests/concordance_doc_moteur.R --strict` | **0 écart**, code de sortie 0 |
| Références de `main` contre celles de HEAD (`/tmp/audit_k1/adv/cmp_ref.R`, comparaison feuille par feuille) | Seuls les `$tests[[*]]$detail` diffèrent : 52 lignes par cas lognormal, 25 pour reserve2. **0 feuille non textuelle modifiée** : le patch `23c6441` ne touche aucun nombre |
| `identical()` entre le moteur de `main` et celui de HEAD, six cas, même machine, `detail` mis à part | **TRUE pour les 6 cas** |
| `identical()` entre `ea2c947^` et `ea2c947` (#513), six cas complets | **TRUE pour les 6 cas**, ce qui confirme l'annonce de #513 |
| Chemin openxlsx : paquet 4.2.5.2 extrait d'un `.deb` dans une bibliothèque temporaire (`R_LIBS`), comparé au lecteur interne sur 13 classeurs (lignes vides en tête, au milieu, en fin mise en forme ; tableau décalé ; booléen ; « NA » texte ; hexadécimal ; triangles) | Mêmes verdicts et mêmes motifs sur les deux chemins. `test_controles_entree.R` passe avec openxlsx : 265/265 |
| Compilation du `.tex` (copie hors dépôt, `pdflatex`) | 3 passes, 0 renvoi indéfini |
| Messages de commit (`git log main..HEAD`) | Aucun mot-clé de fermeture ; auteur `Claude <noreply@anthropic.com>` sur les 38 commits |

**Scénarios adverses** (tous conformes à ce qui est annoncé) :

- **Lecture CSV comme l'application** (`/tmp/audit_k1/adv/a1.R`, `/tmp/audit_k1/adv/a6.R`), environ 30 cas :
  - Les lignes vides intercalées ou en tête sont refusées, avec ou sans colonne t, CRLF et lignes de blancs compris. Les lignes vides de fin sont retirées.
  - Sont refusés avec leur position : la cellule « NA » (avec la phrase fixe), « 0x82 », « 130e », TRUE, l'espace insécable.
  - « 1.3e2 » est accepté. Un en-tête Latin-1 est cité en UTF-8 valide. Une ligne d'en-tête seule donne « Fichier vide ».
- **Triangles** : une ligne ou une colonne vide intercalée est refusée, une colonne vide sans en-tête en bord est retirée, une colonne vide qui porte un en-tête est refusée.
- **`usp_lire_vecteur()` avec `dec = ","`** : « 1.500 » est refusé, y compris en position d'en-tête (aucune année perdue en silence).
- **#489** (`/tmp/audit_k1/adv/a2.R`) :
  - refus de « p », « X », NULL, NA, d'un vecteur de longueur 2 et d'un facteur ;
  - en reserve2, refus de T, xt, `theta_equiv` et `plus_recent_en_dernier = TRUE` ; `xt = NULL` est accepté ;
  - en premium, refus de `triangle` ;
  - `plus_recent_en_dernier` : NA, 1, `c(T, T)` et NULL refusés.
- **#482** (`/tmp/audit_k1/adv/a3.R`) : séries 9/8 et 8/9 refusées avec T = 6, 8, 9, 10 et sans T, sans troncature.
- **#491** (`/tmp/audit_k1/adv/a4.R`) : triangle de référence rempli sous la diagonale avec -5, NaN et Inf.
  - Le résultat est `identical()` à celui du triangle observé, `validation` et horodatage mis à part.
  - `res$triangle` est NA sous la diagonale, avec un seul avertissement.
- **`detail`** (`/tmp/audit_k1/adv/a5.R`) : 10 jeux, chacun lancé 3 fois (graines 20260831 et 12345, B = 199 et 499) :
  - jeux : δ̂ au bord, δ̂ intérieur, volumes constants, pertes constantes, T = 5, T = 10, T = 12 (Pitman par permutations aléatoires, mention Edgeworth), ex æquo, reserve2 8×8 et 5×5 ;
  - aucun texte propre à plus de 2 phrases ou 400 caractères ; aucun texte vide ; aucun écart entre le champ `inoperant` et le préfixe ;
  - entre graines ou entre B, les seules différences sont la présence des phrases fixes M11 (#244) et M6_mc. **Aucun nombre issu du bootstrap** dans un `detail` (règle #76).
- **Grandeurs dépendantes de la plateforme dans un `detail`** :
  - aucune nouvelle ;
  - rho, p_bas et p_haut du TOST et la p bilatérale de Pitman sont retirés, ce qui réduit le risque ;
  - restent, comme avant la branche : la puissance de Pitman (%.2f), p_plancher (%.3f), le seuil de la constante, `ecart_tol` de M18.
- **Architecture** : aucun calcul ajouté dans `app.R` ni dans `display_helpers.R`. L'application lit désormais le CSV en texte et toute l'interprétation est faite par le moteur. Les tirages restent sous `engine_sous_graine()`, sans source d'aléa nouvelle. La mémoïsation de #513 est déterministe et sa sortie est identique au bit près.

## Constats (tous mineurs)

**1. Mineur : parenthèse déplacée dans le `.tex`.**
- **Emplacement** : `docs/latex/doc_tests_usp.tex:4407-4408`, introduit par `f2d4f33`.
- **Défaut** : la phrase sur les en-têtes, « sont déclarés de même (\code{.declarer\_latin1()}) », a été insérée entre « sans appel à \code{as.numeric()} » et sa parenthèse « (\code{.cellules\_en\_nombre()}~; le prédicat commun … ». On lit maintenant deux parenthèses de suite, et la seconde semble porter sur les en-têtes.
- **Mesure** : `git show main:docs/latex/doc_tests_usp.tex | grep -n "sans appel à"` donne la ligne 4291, où la parenthèse suit directement `as.numeric()`. `git log -S'sont déclarés de même'` désigne `f2d4f33`.
- **Correction** : remettre la parenthèse après « as.numeric() » et placer la phrase sur les en-têtes après elle. C'est à `docwriter` de corriger.

**2. Mineur : citations littérales périmées dans `CONTEXT.md`.**
- **Emplacement** : `CONTEXT.md:33, 55, 59, 168, 184`.
- **Défaut** : le glossaire cite mot pour mot des textes que #514 a changés : « … ; aucun verdict », « Monte-Carlo indisponible : <motif> ; … », « Restituee en diagnostic (regle R15) : … ». Le moteur écrit maintenant « …, aucun verdict », « Monte-Carlo indisponible : <motif>, … », « Diagnostic (regle R15), sans verdict ni p-value retenue : … ».
- **Mesure** : `grep -on "Monte-Carlo indisponible : <motif> ; \|; aucun verdict\|Restituee en diagnostic" CONTEXT.md` trouve ces lignes, contre `R/engine.R:4552, 4639, 4651, 4684`.
- **Correction** : mettre à jour les citations. C'est à `architect` de le faire, puisque `CONTEXT.md` est dans son domaine. Les ADR, historiques, restent tels quels.

**3. Mineur : seuil écrit en dur dans une mention de régime.**
- **Emplacement** : `R/engine.R:4340-4342`, constante `MENTION_PERMUTATIONS_ALEATOIRES`.
- **Défaut** : le texte écrit « T > 9 », alors que la branche qui le pose teste `T > T_MAX_ENUM_PERMUTATION` (= 9, `R/engine.R:3175`). Aucun test ne lie les deux. Si la constante change, la mention dira faux.
- **Mesure** : `grep -rn T_MAX_ENUM_PERMUTATION tests/unitaires/*.R` ne trouve aucune occurrence. `MENTION_EDGEWORTH` (« T > 9 ») vient en revanche de `n_small = 9` dans prho.c, une borne externe : là, le chiffre en dur est légitime.
- **Correction** : construire la phrase par `sprintf` à partir de `T_MAX_ENUM_PERMUTATION`, ou ajouter une assertion d'égalité.

**4. Mineur : cellule non numérique sous la diagonale refusée, alors que #491 annonce qu'elle est ignorée.**
- **Emplacement** : `R/engine.R:7587`, fonction `engine_lire_triangle()`.
- **Défaut** : une cellule texte ou « NA » dans la partie i + j > I d'un fichier est refusée comme non numérique. Or #491 et le tableau du `.tex` (`doc_tests_usp.tex:4449`) annoncent que ces cellules sont signalées et ignorées « quelle que soit sa valeur ».
- **Mesure** (`/tmp/audit_k1/adv/a1.R`) :
  - avec « abc » en (5,5), on obtient `ok = FALSE` et « Cellule(s) non numerique(s) en (i=5, j=5) » ;
  - avec « NA », même refus, accompagné du conseil de laisser la cellule vide ;
  - avec -5 au même endroit, la cellule est acceptée avec un avertissement.
- Ce n'est pas une régression : `main` refusait déjà ces cellules.
- **À trancher par le mainteneur** :
  - soit garder le refus et le dire dans le `.tex` (« valeur numérique ») ;
  - soit exclure i + j > I du contrôle de lisibilité et laisser l'avertissement de #491 s'appliquer.

**5. Mineur : avertissements parasites dans les tests.**
- **Emplacement** : `tests/unitaires/test_controles_entree.R:1861-1863` et `1899`.
- **Défaut** : chaque exécution émet 17 avertissements « object 'requireNamespace' not found ». Cause : le promesse `f` de `chemins483()` n'est évaluée qu'à l'intérieur de `sans_openxlsx483()` ; elle rappelle alors `xlsx483()`, qui fait une substitution imbriquée, et le `rm` extérieur échoue.
- **Effet** : aucun sur les assertions, car le chemin interne est choisi avant que la promesse ne soit évaluée.
- **Mesure** : `Rscript -e 'options(warn=1); source("tests/unitaires/test_controles_entree.R")'` affiche « Warning in rm("requireNamespace", envir = env483) ».
- **Correction** : `force(f)` en tête de `chemins483()`, ou un `rm` conditionnel.

**Hors périmètre, issue proposée (à créer seulement si le mainteneur l'approuve)** :
- **Titre** : « moteur: alpha du détail Rosner (M4) imprimé à %.2f, 0.025 lu 0.03 ».
- **Libellé** : `needs-triage`.
- **Corps** :
  - **Défaut** : `PHRASE_MW_ROSNER_DIAGNOSTIC` (`R/engine.R:12180`, appel en `12722`) imprime alpha en `%.2f`, alors qu'alpha = 0,025 est admis. Le texte dit donc « alpha = 0.03 ».
  - **Mesure** : `sprintf("%.2f", 0.025)` rend « 0.03 ».
  - **Antériorité** : le défaut existait déjà sur `main`, ligne 12484.
  - **Correction** : `%g`, comme dans les autres `detail`.

## Questions pour `actuary` (affirmations de fond nouvelles ou modifiées dans les `detail`, sans reprise de code)

Aucun champ `reference` n'est modifié par le diff (`REFERENCE_P_FAMILLE` est inchangé). Ces questions sont à porter à `actuary` pour sa validation de fin de branche :

1. **Mentions de régime M17 à M22** (`R/engine.R:4282-4343`) : `MENTION_DELTA_BORNE_1`, `MENTION_VOLUMES_CONSTANTS`, `MENTION_H3_PI_VARIABLE`, `MENTION_PI_VARIABLE_*`. `FORMAT_MENTION_BANDE` dit maintenant « un ecart de cet ordre », là où l'ancien texte disait « d'ordre (1 - delta), ou de l'etendue relative des volumes » : est-ce assez précis ?
2. **`DETAIL_P_FAMILLE` et `DETAIL_P_GLOBALE`** : la mention du contrôle du taux d'erreur « au sens faible » est retirée. La phrase « une p de famille faible signale qu'au moins une hypothèse … est mise en cause sous le modèle ajusté » est-elle exacte pour un minP plug-in ?
3. **TOST sous R14** : « aucune constante estimée ne donnerait p < alpha (p_plancher = …) ». Pour la ligne constante : « la preuve positive est un OK de "Equivalence de la constante a zero (TOST)" ».
4. **Pitman** : « un OK établit un lien positif pertes / volume, qui peut aussi venir d'une dispersion liée au volume ou d'une tendance commune ». Breusch-Pagan Koenker : « Seul test de H2 à verdict ».
5. **`PHRASE_MW_ROSNER_DIAGNOSTIC`** : « son cadre i.i.d. normal (n >= 25) ne couvre pas les résidus de Mack ».
6. **Retraits d'information du `detail`**, décidés en Q-3 et Q-5 : rangs de Cook, rangs et positions de Rosner, cellule du minimum (i, j), sensibilité de √MSEP à σ²(J−1) (`mw_sensibilite_sigma2_dernier()` n'est plus appelée par `run_engine()`). Faut-il confirmer que chacune reste disponible ailleurs pour le dossier ? Seuls `plots_data$influence` et `metadata$permutation_pente$p_bilateral` ont été vérifiés.
7. **Typographie de M11**, gardée « telle quelle » par la spécification : derrière un texte propre qui finit maintenant par un point, la phrase fixe de #244 commence par une minuscule et n'a pas de point final (exemple : « … (H3, lognormalite). verdict sensible a l'alea … »). Est-ce acceptable ?

## Points à surveiller avant la sortie du brouillon (hors constats)

- `app.R` et `R/display_helpers.R` sont touchés : la revue d'`app-review` est requise. Le seuil de repli passe à 400 et s'applique aussi à H0/H1 (`display_helpers.R:492-493`). Le CSV est maintenant lu en texte.
- Le commit `docs:` du PDF de fin de branche n'est pas encore fait (le `.tex` est modifié, pas le PDF).
- Le chemin openxlsx n'est exercé ni en CI ni dans le conteneur. Je l'ai mesuré ici avec openxlsx 4.2.5.2 ; le poste du mainteneur a 4.2.9.
- Toute correction des constats 1 à 5 est à revoir à son tour, sur son diff.