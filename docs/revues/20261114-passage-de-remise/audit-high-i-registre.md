# Revue du registre (KR, étape 4, consultation (i)) : **conforme avec réserves** (deux mineurs, sur des commentaires uniquement)

> Rapport d'`audit` (effort `high`), versé intégralement par la session principale (Q-54-10). Scripts et sorties hors dépôt (scratchpad de la session).

Assiette : `git diff 9f7290f...a2f9c3a` sur `R/engine.R`, branche `claude/passage-de-remise`, gel `a2f9c3a`. Lus en entier : `engine_registre_tests()`/`add()` (l. 4627-5053), `usp_tests()` (5742-7677) et `mw_tests()` (13551-14173). Lues aussi les fonctions dont le corps croise le diff et qui alimentent le registre : `.motif_mc_indisponible()`, `.prefixe_motif_mc()`, `engine_p_famille()`, `test_runs()`, `test_anscombe_kurt()`, `.usp_ligne_cook()`, `mw_test_ordonnee_origine()`/`.mw_coefs_origine()`, `.mw_p_min_ligne()`, `.mw_detail_extrapolation()`, `engine_regle_verdicts()` et `engine_table_tests()`.

**Aucun motif d'arrêt.** Aucun σ_USP ni aucun verdict ne change : les six cas sont identiques au bit près aux références. Aucun défaut de code, seulement deux commentaires périmés.

## Constats

- **mineur 1 — `R/engine.R:4423`** (commentaire de `PHRASE_VERDICT_SENSIBLE_MC`)
  - Le commentaire dit « ligne de type test, sans verdict fourni ». Or #484 (commit `93e663c`) a retiré l'argument `verdict` d'`add()`.
  - Mesure : `grep -n "verdict fourni" R/*.R` ne trouve que cette ligne. Un appel `add(..., verdict = "OK")` lève bien « unused argument ».
  - Aucun effet sur un résultat. Correction : retirer « sans verdict fourni, ».

- **mineur 2 — `tests/calibration_mc_mw_t8.R:1087-1092`** (fichier hors diff, script hors CI)
  - Le commentaire « Écart documenté à add() : la condition "aucun verdict fourni par l'appelant"… » décrit une condition qui n'existe plus depuis #484.
  - Correction : remplacer ce paragraphe par « le verdict suit de la p retenue seule depuis #484 ».

**Issue proposée** (gel, Q-48-9 (a)), à créer sur accord du mainteneur :
- Titre : « Commentaires périmés sur l'argument verdict d'add(), retiré par #484 ».
- Corps : les deux emplacements ci-dessus, aucun effet numérique, correctif rapide `moteur:` + `tests:`.

## Vérifications exécutées (toutes sous `LC_ALL=C.UTF-8`)

1. **`Rscript tests/comparer_references.R --seuil 0`** : les 6 cas sont CONFORMES, 0 grandeur non strictement identique, écart maximal 0. EXIT 0.
2. **`Rscript tests/test_reproductibilite.R`** : « OK : reproductibilite et non-regression verifiees pour 6 cas ». EXIT 0. σ_USP : premium 0.1114524114, reserve1 0.1073524114, reserve2 0.0497764613, premium_ii6 0.1483524114, premium_net 0.1032524114, premium_interieur 0.0871308679.
3. **`Rscript tests/concordance_doc_moteur.R --strict`** : « BILAN : 0 ecart(s) (mode strict) ». EXIT 0. La phrase « reste ouverte » est toujours en l. 4398 du `.tex` ; elle relève de `docwriter`.
4. **`Rscript tests/test_unitaires.R --parallele=4`** : 3815 assertions, 0 échec, 55 fichiers. EXIT 0.
5. **Scénarios adverses sur `add()`** (registre construit sur un faux objet bootstrap) — tous conformes à `.claude/rules/moteur.md` :
   - Refus par `stop()` : argument `verdict` fourni ; `nature_forcee` d'un autre rang que la p retenue (exacte contre Monte-Carlo, p non simulée contre exacte) ; `nature_forcee` vide ; p = 1 + 1e-9 ; p fournie en chaîne ou en `TRUE` ; `sens` inconnu ; `p_min` sur une p non simulée seule.
   - Comportements admis : p = 1 + 1e-13 et p = -1e-13 gardées telles quelles (`TOL_P_BORNE`) ; motif non dégénéré avec p_as finie : diagnostic, « Monte-Carlo indisponible : <motif>, p … non retenue. » ; sans aucune p et p_min ≥ α : ligne inopérante (`inoperant = TRUE`), motif après « TEST INOPERANT » ; motif dégénéré avec p exacte finie : diagnostic sans p retenue ; `MOTIF_MC_OBS_NON_FINIE` : non applicable, `loi = NA` ; branche Monte-Carlo de R1 : `p_min_mc` posé, phrase de #244 en dernier.
6. **Invariants sur les 6 références** (53/53/25/53/53/53 lignes) — aucune violation : cinq champs finaux dans l'ordre ; type parmi les trois valeurs admises ; verdict ≠ INFO si et seulement si test avec p retenue finie ; lignes non-tests sans sens, p retenue ni nature ; hiérarchie exacte > Monte-Carlo > p non simulée respectée, aucune p non simulée retenue sur une ligne qui a un `mc_nom` ; `inoperant` TRUE si et seulement si diagnostic préfixé « TEST INOPERANT » ; p-values dans [0, 1] ; `loi` NA sur les non applicables ; `mc_nom` dans son catalogue ; préfixes de `famille` déclarés dans `GROUPES` ; `fonction` du moteur. Une alerte sur Cox-Stuart (premium_interieur) est un faux positif du script : ligne inopérante par la branche Monte-Carlo de R1, où `p_min_mc` est conservé à dessein.
7. **Règle #76** (aucun nombre du bootstrap dans `detail`) : chaque cas lancé avec la graine 20260831 puis 12345 (premium, premium_interieur, reserve2, volumes constants x = 100 × 8). Phrase fixe de #244 retirée, aucun `detail` ne diffère (0 sur 4). Seule différence : le Grubbs de premium_interieur passe de OK (p_mc = 0.105) à ALERTE (0.098), écart sous 2 err_mc, phrase de #244 posée comme attendu. Toutes les graines passent par `engine_sous_graine()` : aucune source d'aléa nouvelle.
8. **Cohérence avec le `.tex`** : l. 1297-1345 et 3754-3757 (`add()`, refus de #484, `TOL_P_BORNE`, `nature_forcee`, `.motif_mc_indisponible()` et son séparateur) conformes au code ; aucune mention de l'argument `verdict` ; l'affichage ne lit pas le préfixe « TEST INOPERANT » (`grep` vide dans `R/display_helpers.R` et `app.R`).

## Questions pour `actuary`

Aucune.

Le dépôt n'a pas été modifié.
