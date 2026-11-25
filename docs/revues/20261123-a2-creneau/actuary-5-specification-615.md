# Spécification courte de #615 : résidus d'une colonne qui devient dégénérée dans une réplication de Merz-Wüthrich

*Rédigé par l'agent `actuary` (IA), le 25/11/2026, sur `claude/creneau-a2`, tête `70fb6f4`. Aucun fichier écrit, rien posté ; seule une mesure en lecture a été lancée (§ 4). Versé intégralement par la session principale (Q-54-10). P1 retenue sur la décision du mainteneur E-25/11 (PA-2), Q-PA2-3 (a) (« spécification courte d'`actuary`, P1 recommandée »).*

Marques : [V] vérifiée (source citée, ou commande et sortie), [H] hypothèse, [NV] non vérifiée.

## 1. Choix : P1, motivé à T = 8

**Je recommande P1.** Dans chaque réplication, `mw_residus()` exclut l'ensemble `union(figées, dégénérées de la réplication)`. Le prédicat est le même partout : `.mw_colonne_degeneree()`.

Cinq motifs :

- **P1 corrige une règle qui existe déjà, il n'en crée pas une nouvelle.** [V]
  - Le code exclut déjà, dans une réplication, une colonne hors de l'ensemble figé quand son σ̂²_j simulé est ≤ 0 (`R/engine.R`, commentaire de `mw_residus()`, l. ~14594-14595, et test de la l. ~14623). La composition des résidus varie donc déjà d'une réplication à l'autre.
  - Or le moteur pose lui-même qu'un critère σ̂²_j = 0 est numériquement inopérant : « elle est testée sur les facteurs et non sur sigma2_j == 0, que l'arrondi rend en général strictement positif » (`R/engine.R` l. ~13581-13583). Le `.tex` dit de même, l. 15800-15805 : « simple bruit d'arrondi normé ».
  - P1 remplace donc, dans la réplication, le test brut σ̂²_j ≤ 0 par le prédicat unique (« UNE SEULE DEFINITION », `R/engine.R` l. ~13597). C'est la correction du défaut constaté, et non un changement de méthode.
- **P1 respecte le principe de #278.**
  - Le `.tex` (l. 16363-16367, `sec:mwm1`) justifie le gel ainsi : « Reproduire une règle de sélection dans le bootstrap ne vaut que si le modèle simulé peut produire ce qui la déclenche ». [V]
  - Pour une colonne de dispersion relative de 1e-12 à 1e-10, le modèle simulé produit ce déclencheur : 39,6 % des réplications à ρ = 2e-12 [V, sonde, `docs/tableaux/20261123-issue612-simulation-jm1-trapeze.md`, bloc S].
  - Sous P1, la statistique reste une fonction fixe du triangle, S(résidus hors de figées ∪ dég(triangle)), appliquée à l'identique à l'observé et aux réplications. À l'observé, dég(aj) ⊂ figées, car l'ensemble figé est calculé sur aj [V, `.mw_ensembles_figes()` et `mw_bootstrap()`]. C'est la « même fonction » de la règle (3). [H : c'est mon interprétation, pas une citation de #278.]
- **P2 est à écarter.** Les lignes M1 liraient l'ensemble figé : elles calculeraient alors des régressions et des t sur une colonne de bruit d'arrondi. Cela défait #56 et le second volet de #278 (`.tex` l. 16369-16371 : statistique `NA` quand une colonne retenue devient dégénérée). P2 aligne la règle sur le défaut au lieu de corriger le défaut. [V pour le comportement de M1, `mw_test_ordonnee_origine()`, `mw_test_courbure()` et `mw_test_homogeneite_f()` par `.mw_degeneree_courante()`.]
- **Troisième voie, que je signale sans la retenir : P3.** La statistique fondée sur les résidus deviendrait `NA` dans une réplication touchée, comme M1. P3 n'est pas mesurée. Elle ferait perdre jusqu'à 40 % de B effectif sur six clés à ρ = 2e-12, ce qui gonfle err_mc à T = 8. Elle conditionnerait aussi la p Monte-Carlo à la non-dégénérescence, un effet non quantifié. Elle contredit enfin la règle σ̂² ≤ 0 en vigueur. [H]
- **Portée pratique.** L'effet n'apparaît que pour une colonne observée de dispersion relative de l'ordre de 1e-12 à 3e-10 [V, sonde]. Les données réelles en sont loin : CV de 1e-2 à 1e-1 (commentaire du moteur) [H pour les données hors références]. Aucune p-value n'est exacte ici : toutes ces lignes ont une p Monte-Carlo. La correction ne touche que la loi simulée.

**Réserve à documenter** : pour ExpVar (combinaison de Fisher sur K colonnes), P1 fait varier K dans une réplication touchée. La garde d'aplatissement le fait déjà aujourd'hui [V, `mw_test_exposant_variance()`]. L'écart à la doctrine « K identique » de M1 est donc préexistant ; il faut l'écrire, pas le corriger ici.

## 2. Règle exacte à implémenter

**`mw_residus(aj, j_degeneres = NULL, degeneres_aj = NULL)`** : un argument optionnel est ajouté, sur le modèle des fonctions M1 (#445).

- Ensemble exclu : `jd <- union(.mw_j_exclues(aj, j_degeneres), D)`.
  - `D` vaut `degeneres_aj` s'il est fourni, sinon `.mw_colonnes_degenerees(aj)`.
  - Quand `j_degeneres` est `NULL`, l'union ne change rien ; éviter alors le double calcul.
- La boucle et la condition `!is.finite(s2) || s2 <= 0 || j %in% jd` restent inchangées. Le test `length(idx) < 2` reste en premier : la colonne J−1 d'un carré n'est toujours pas comptée comme exclue.
- L'attribut `colonnes_exclues` consigne la colonne dans la réplication. À l'observé, il ne change pas.

**`.mw_contexte_mc()`** : calculer `degeneres_aj` avant les résidus, puis appeler `mw_residus(aj, figes$degeneres, degeneres_aj)`. Le résultat doit être identique au bit près au prototype `orig(aj, union(jd, deg))` de `tests/simulation_jm1_trapeze_t8.R` l. 550.

**Seuil** : celui de `.mw_colonne_degeneree()` (tol = 1e-12, avec ses deux volets). Aucune constante nouvelle : le prédicat est unique (#56, #60).

**Fonctions inchangées** :
- elles bénéficient de la règle sans modification : `mw_test_exposant_variance()` et `mw_test_homogeneite_accident()` (repli `res = NULL`), `.mw_pool_residus()`, `mw_tests()` l. ~16844 ;
- elles restent hors règle : M1, MinP4 / `mw_influence()` (qui lisent déjà le prédicat de la réplication), Calendrier, CorrDev et Alpha.

**Précondition** à écrire dans l'en-tête : les ensembles figés sont ceux de l'aj observé. S'ils sont imposés autrement, l'observé peut changer.

**Lignes et résultats concernés** :
- les p Monte-Carlo, les `p_min_mc` (Runs, ExpVar, KruskalAcc) et les `stats_boot` des six clés PenteIntra (M1, tendance), BP et ExpVar (M2), KruskalAcc, DW et Runs (M3) ;
- donc, au plus, les verdicts de ces lignes, sur triangle quasi dégénéré seulement.

**Résultats non concernés** : les statistiques observées, les p exactes et asymptotiques, les lignes de `.MW_LIGNES_RESIDUS` calculées sur l'observé seul (Variance unitaire, ESD, Shapiro-Wilk…), σ_USP, `sigma_boot` et l'IC, ainsi que les cinq cas lognormaux. [V par lecture de `mw_bootstrap()` : `sig[b]` vient de `mw_msep(ab)`.]

**Quand il ne reste pas assez de résidus**, aucun repli nouveau et aucun motif nouveau ne sont créés :
- chaque statistique garde sa garde actuelle : PenteIntra si `nrow < 4`, BP si n < 3, ExpVar sans colonne nd ≥ 4, KruskalAcc à moins de 3 niveaux ou moins de 6 résidus, DW (0/0 → NaN), Runs (rend `NA`) [V : `test_runs(numeric(0))$stat` = NA et `stat_dw(numeric(0))` = NaN, sans erreur] ;
- la valeur non finie sort de B effectif pour cette clé seule (`engine_p_mc()`), avec la phrase de #204 si B_eff < B, et le motif `MOTIF_MC_REPLIC_INSUFFISANTES` si B_eff < `B_MIN_DEGENERESCENCE` ;
- les autres clés de la réplication restent calculées.

## 3. Tests unitaires attendus

Fichier conseillé : `tests/unitaires/test_merz_wuthrich_suite.R` ou équivalent.

**Construction.** Triangle `T_obs` = `.tri` (reserve2), colonne j* = 5 réécrite à ρ = 2e-12, selon la recette `SONDE_CFG` du script de sonde. `fg <- .mw_ensembles_figes(mw_ajuster(T_obs))`. Vérifier d'abord `!(5 %in% fg$degeneres)`.

**(a) Le cas déclenche.**
- `T_rep` : même triangle, colonne 5 à ρ = 5e-13, donc dégénérée au premier volet, avec σ̂²_5 > 0 fini.
- Assertions :
  - `.mw_colonne_degeneree(a_rep, 5)` est vrai et `.mw_sigma2_residus(a_rep)[6] > 0`, ce qui prouve que l'ancienne règle gardait la colonne ;
  - `mw_residus(a_rep, fg$degeneres)` n'a aucune ligne `j == 5` ;
  - `5 %in% attr(., "colonnes_exclues")$j` ;
  - `.mw_contexte_mc(a_rep, fg)$res` est `identical()` à `mw_residus(a_rep, union(fg$degeneres, 5L))`.
- Au niveau du bootstrap, sur `T_obs` avec B = 99 :
  - au moins une réplication est touchée (assertion qui contrôle le test lui-même) ;
  - `stats_boot` est `identical()` à la boucle reproduite avec l'exclusion par union, sur le patron de `test_merz_wuthrich_trapeze.R` l. ~505-525 ;
  - `B_effectif == B` sur les six clés.

**(b) Le cas ne déclenche pas.**
- Colonne 5 à ρ = 1e-10 dans la « réplication » : ses résidus sont présents et la sortie est `identical()` à `mw_residus(a, fg$degeneres)` sans union.
- À l'observé : `mw_residus(a_obs, fg$degeneres)` est `identical()` à `mw_residus(a_obs)`. Les statistiques observées de `mw_bootstrap()` restent inchangées.
- La colonne J−1 d'un carré n'apparaît pas dans `colonnes_exclues`.

**(c) Il ne reste plus de résidu.**
- Réplication où toutes les colonnes hors de l'ensemble figé sont dégénérées.
- Attendu : `mw_residus()` rend 0 ligne sans erreur, et `.mw_stats(.., replique = TRUE)` rend `NA` sur les six clés sans erreur.

**Oracle de `tests/unitaires/test_tables_mw.R`.** Sa réécriture de `.mw_contexte_mc()` (l. ~371) appelle `mw_residus(aj, jd)` : elle doit adopter l'union si un de ses triangles déclenche. Tout échec d'un test existant doit être expliqué, pas aligné en aveugle. [NV : aucun échec constaté, rien n'a été lancé.]

## 4. Critères d'acceptation

1. **Seuil 0 sur les sept cas** (r567) : `comparer_objets()` à 1e-6, aucune valeur changée.
   - Justification [V, mesure sur ce poste, `LC_ALL=C.UTF-8` ; enveloppe de `.mw_contexte_mc()` posée dans `environment(run_engine)`, B = 999, graine par défaut] :
     - `reserve2` : 0 réplication touchée sur 999 ; écart relatif maximal minimal 5,849e-3 à l'observé et 2,03e-6 sur les réplications ;
     - `reserve2_trapeze` : 0 sur 999 ; 6,105e-3 à l'observé et 6,31e-5 sur les réplications.
   - La dégénérescence exige un écart d'au plus (n−1)·1e-12 ≤ 7e-12, soit six ordres de grandeur sous le minimum mesuré.
   - L'observé ne change pas par construction, car dég(aj) ⊂ figées.
   - Les cinq cas lognormaux n'appellent pas le code de Merz-Wüthrich. [H forte : c'est l'aiguillage de `run_engine()` par `methode` ; r567 le confirmera.]
   - [H] La marge est valable aussi sur la plateforme de la CI.
2. **Bloc S de la sonde relancé** sur le nouveau moteur (`--niveau L-A --bloc S`, sans `--ecrire`) :
   - dans chaque ligne, les p du mode « courant » sont égales aux p « P1 » de `docs/tableaux/20261123-issue612-simulation-jm1-trapeze-sonde.tsv` ;
   - |Δp| max = 0 partout.
   - [H] Les contrôles d'intégrité du script ne bloquent pas un moteur modifié hors `--ecrire`. À défaut, se limiter à la ligne J−2 du carré à ρ = 2e-12.
3. **Batteries** : la batterie unitaire et la reproductibilité passent sous `LC_ALL=C.UTF-8` ; la concordance `--strict` aussi.
4. **Seuil 0 non tenu** :
   - arrêt ; ne pas régénérer, et en tout cas jamais hors de la CI ;
   - tableau avant / après des valeurs touchées : clé, p_mc, err_mc, nombre de réplications touchées ;
   - un changement à l'observé ou sur un cas lognormal signale un écart à P1 et renvoie à `coder` ;
   - un changement de p_mc avec des réplications touchées réelles est soumis à `actuary` ; si un verdict change, au mainteneur ;
   - commit `moteur:` distinct de V2, avec son visa.

## 5. Surface d'impact documentaire (`docwriter`, en fin de branche)

- **`.tex` l. 15809-15811 (`sec:mw`), à corriger** : « le nombre de résidus est ainsi le même à l'observé et dans les réplications ». C'est déjà faux aujourd'hui (règle σ̂² ≤ 0) et ce sera plus faux après la correction. Écrire : ensemble figé ∪ colonnes dégénérées de la réplication, avec la justification du § 1.
- **l. 16346-16352 (`sec:mwm1`, règle (1))** : « Le même ensemble figé est transmis aux résidus de Mack de chaque réplication » devient « ensemble figé, réuni avec les colonnes dégénérées de la réplication ». Préciser le contraste avec le second volet de M1 (`NA`) et sa raison.
- **l. 1938-1940 (index, `mw_residus()`)** : nouvel argument `degeneres_aj` et nouvelle règle d'exclusion.
- **l. 1505-1511 (index, `.mw_contexte_mc()`)** : `degeneres_aj` est passé aussi à `mw_residus()`.
- **l. 6542-6543 (`sec:boot-mw`)** : le vivier reste celui de l'observé. Seule une précision est à ajouter.
- **Fiches ExpVar (l. 17642), KruskalAcc, DW, Runs, PenteIntra et BP** : leurs mentions « selon l'ensemble figé » ; pour ExpVar, la réserve sur K du § 1.
- **Commentaires du moteur** : en-têtes de `mw_residus()` et de `.mw_contexte_mc()`, et celui de `mw_bootstrap()` (« Aucun tirage n'est ajouté ni retiré », qui reste vrai).
- **Constat (1) de #612** : la mention dans `sec:trapeze-niveau`, si elle existe, n'est plus une réserve ouverte.

## Retour

- **Statut** : `complet` pour la spécification. Le seuil 0 est mesuré sur ce poste ; sa confirmation sur la CI viendra de r567.
- **Résultat** : P1 retenue ; P2 et P3 écartées ; règle portée par `mw_residus()` et `.mw_contexte_mc()`, avec le prédicat unique à 1e-12 ; six clés Monte-Carlo concernées ; aucun repli nouveau.
- **Preuves vérifiées** : le code lu (`mw_residus`, `.mw_contexte_mc`, `.mw_ensembles_figes`, `mw_bootstrap`, `engine_p_mc`, gardes des statistiques) et le prototype de la sonde (l. 519-552) ; le `.tex` l. 15797-15811 et 16340-16371 ; la mesure de 0 réplication touchée sur les deux cas de Merz-Wüthrich ; le comportement de DW et de Runs sur un vecteur vide.
- **Hypothèses** : la lecture de P1 comme « même fonction » au sens de #278 ; les effets de P3 ; la marge sur la CI ; la non-exécution du code de Merz-Wüthrich par les cas lognormaux ; le lancement du bloc S sur un moteur modifié.
- **Non vérifiés** : la présence de réplications touchées dans les cellules M de la mesure de #612, déjà notée dans #615 ; l'effet sur l'oracle de `test_tables_mw.R`.
- **Informations manquantes** : le texte de #278 n'a pas été relu, seulement sa transcription dans le `.tex` et le code.
- **Critères déclenchés** (§ 4) : deux lectures du principe de #278 (composition identique, ou fonction identique) ; changement de résultat possible hors références, sur des triangles quasi dégénérés (p_mc, verdict éventuel).
- **Constats hors périmètre** (ADR 0018) :
  - **(i) Calendrier et CorrDev** (`R/engine.R` l. ~14687 et ~14834) : ils ne lisent que l'ensemble figé. Une colonne dégénérée dans une réplication n'est écartée que par l'aplatissement (second volet du prédicat) ; une colonne dégénérée au premier volet sans fusion garde ses étiquettes ou entre dans la corrélation. Critère E3 potentiel, non mesuré : le P1 de la sonde laissait ces deux clés intactes.
  - **(ii) `.tex` l. 15809-15811**, déjà faux sur le code actuel. Critère E5, couvert par la surface documentaire du § 5.
