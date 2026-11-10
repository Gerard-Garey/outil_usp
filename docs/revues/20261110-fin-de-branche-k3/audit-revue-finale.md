# Revue finale complète de K3 « Registre » (audit, effort high)

> *Rapport d'`audit` (Opus 5.5, effort `high`), 10/11/2026, reproduit par la session principale (Q-54-10). Objet : `git diff origin/main...186fd9f` (base `1caebbb`), état commité lu par `git show`, batteries dans un worktree détaché retiré à la fin. Les commits postérieurs à `186fd9f` (`e53ea4e`, `00ccd85` : `.tex` ; corrections de revue) sont revus sur leur diff.*

## Verdict : conforme avec réserves

Aucun constat bloquant ni majeur. Références identiques (écart 0). Trois mineurs et un point de calendrier documentaire.

## 1. Batteries (worktree à `186fd9f`, `LC_ALL=C.UTF-8`)

| Commande | Résultat |
|---|---|
| `Rscript tests/test_unitaires.R --parallele` | 3708 assertions, 3708 ok, 0 échec, 0 échec attendu, 0 succès inattendu ; code 0 |
| `Rscript tests/test_reproductibilite.R` | 6 cas CONFORME, 0 feuille non strictement identique, écart maximal 0 ; σ_USP inchangés (premium 0.1114524114, reserve1 0.1073524114, reserve2 0.0497764613, premium_ii6 0.1483524114, premium_net 0.1032524114, premium_interieur 0.0871308679) |
| `Rscript tests/concordance_doc_moteur.R --strict` | 0 écart (34 formulations vérifiées, 16 exemptées, 0 non classée) |
| `bash .claude/outils/fiches_jumelles.sh --verifier` | conformes |

## 2. Constats

- **m1 (mineur)** — `R/engine.R:6774`, dernier repli Anscombe-Glynn « T = %d < 20 : test non defini » : inatteignable à T ≥ 20 (lecture : b2 fini ⇒ `den` fini ; `den > 0` ⇒ Z fini), mais imprimerait un motif faux. Correction suggérée : `stop()` explicite.
- **m2 (mineur)** — `tests/unitaires/test_defauts_connus.R:596, 600` : titre et commentaire « avec ou sans verdict » devenus faux (argument `verdict` retiré) ; l'assertion reste valide.
- **m3 (mineur, commentaire)** — `R/engine.R:4859-4862` : le commentaire est exact ; la prémisse du « piège Pitman » de l'avis amont (section 1) est fausse (`test_lm_complet()` rend `na_lm()` dès `usp_volumes_constants(x)`, l. 3107). Aucun effet : contrôle conditionné à `porte_verdict`. Pour mémoire d'`actuary`.
- **Point documentaire** — les commits `.tex` précédaient `186fd9f` ; réserves m3 et m4 du visa d'`actuary` à appliquer, à revoir sur leur diff ; PDF de fin de branche à faire.

## 3. Vérifications par point

- **`add()` et appels** : plus aucun `verdict =` dans un appel d'`add()` ; deux `sens = "rejeter"` (TOST, Pitman) ; `nature_forcee` de TOST et Pitman passe (vérifié par `run_engine()` dans `test_registre_add.R`) ; contrôle de rang seulement si `porte_verdict && is.finite(p_ret)` ; `p_mc`, `p_min_mc`, `p_mc_ext` contrôlées au bon endroit ; producteurs de p bornés (`.p_borne()`, `engine_p_mc()`, `.imhof_p_sup0()`, `runs_p_min()`).
- **Invariants** : hiérarchie inchangée ; ligne sans verdict : INFO, sens, p retenue, nature à NA ; #469 : motif joint seulement sans p exacte, garde anti-doublon `fixed = TRUE`, préfixe « TEST INOPERANT » en tête.
- **Contrats partagés** : catalogue lit `test_runs()$stat` seul ; `test_anscombe_kurt()` hors catalogue ; NaN → NA sans effet sur un `is.nan` lié au bootstrap ; cause de Runsr calculée avec les arguments du catalogue ; `app.R`, `R/display_helpers.R`, `R/charger_moteur.R` intacts ; `GROUPES` inchangé ; aucun champ nouveau dans `usp_engine`.
- **#521** : équivalence algébrique dans la branche atteinte.
- **Concordance code ↔ `.tex`** : motifs identiques mot pour mot ; `\versiondoc` 3.3 ; chiffres de la fiche Anscombe recalculés.
- **Q-45-12** : aucun mot-clé de fermeture suivi d'un numéro ; 18 commits d'auteur `Claude <noreply@anthropic.com>`.
- **Architecture et tests** : ASCII ; rien de quantitatif hors du moteur ; tests non vacants ; `test_registre_add.R` découvert.
- **Plateforme** : aucun `detail` nouveau n'imprime un nombre issu de l'optimiseur, du bootstrap ou du jackknife.

## 4. Scénarios adverses

54 exécutions de `run_engine()` (B = 99) : lognormal T = 5 à 12, volumes constants, dans la bande, variables, ex aequo, n1 = n2 = 1 ; 12 triangles Merz-Wüthrich 5×5 à 9×9. Erreurs : 0 ; stat NaN : 0 ; violations (verdict hors test ; ligne non applicable portant une p ou une `p_min` ; p exacte finie non retenue ; `detail` commençant par « NA ») : 0.

## 5. Hors périmètre

Branche 2b de `detail_runsr` inatteignable ; libellé `loi` d'une ligne non applicable (déjà signalé).

## 6. Questions pour actuary

Aucune question de fond nouvelle ; les `detail`, H0 et H1 nouveaux reprennent l'avis amont et ses réponses, couverts par le visa `e7ef2f7`.
