# Audit léger de #540 (étape 5 de K2b)

> Versé par la session principale. Fiche `audit`, règle 10 (audit léger du diff). 13/11/2026. Diff non commité sur `4a8fada`.

**Conclusion : conforme.** Aucun constat bloquant, majeur ou mineur.

## Attendus
1. Condition d'émission (`mw_valider_triangle()`) : `I > J` (≡ `nrow > ncol`) ; I < J : MW-03 seul ; carré : aucun motif. Mesure directe concordante.
2. Texte de MW-04 : `identical()` au texte de la décision 2 et au bloc de l'annotation bis de l'ADR 0005 ; `%d` = `nrow(tri)`, `ncol(tri)` (comptes ; 9×8 → « 9 annees d'accident, 8 annees de developpement »).
3. En-tête de la section 10 conforme aux points 1 à 3 de l'annotation bis ; « méthode n° 1 reste ouverte » et « cas non couvert » absents du code.
4. Tests : texte complet remplacé ; cas I < J ajoutés (5×6 direct, 8×9 par `run_engine()`) ; anciens tests (6×5, 5×6, #520 8×7) justes.

## Dépendances
Aucune au texte ni à la double émission : `app.R` et `R/display_helpers.R` affichent `erreurs` tel quel ; `engine_lire_triangle()` relaie `v$erreurs` ; seuls les tests de `test_controles_entree.R` portent sur le texte. Commentaire de `R/engine.R:7749` exact.

## Remarques sans suite
- « I < J ne recoit que MW-03 » s'entend du seul motif de géométrie (un 4×6 reçoit aussi D(2)(b)) ; fidèle à l'ADR.
- Surface documentaire laissée à `docwriter` (l. 5041, encadré de `sec:mw`, ligne « Géométrie carrée » de `sec:controles`).
- Registre des tests non touché : aucune question pour `actuary`.

## Vérifications (`LC_ALL=C.UTF-8`)
| Commande | Résultat |
|---|---|
| `test_controles_entree.R` | 411 / 411 (4 sautées, `openxlsx` et `zip` absents) |
| `comparer_references.R --seuil 0` | CONFORME sur les six cas, écart maximal 0 |
| `concordance_doc_moteur.R --strict` | 0 écart |
| contrôle direct (`charger_moteur()`) | 8×8 : ok, 0 motif ; 6×8 : 1 motif D(2)(e) ; 8×6 : 1 motif MW-04 ; 5×4 : D(2)(c) puis MW-04 |
