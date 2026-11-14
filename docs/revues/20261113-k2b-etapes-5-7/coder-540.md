# Compte rendu de `coder` sur #540 (étape 5 de K2b)

> Versé par la session principale. Fiche de base (Sonnet `high`), circuit 3. 13/11/2026. Rapport condensé fidèlement.

## Diff
- `R/engine.R`, `mw_valider_triangle()` : `if (I != J)` devient `if (I > J)` (R-1) ; texte de MW-04 de la décision 2, mot pour mot ; commentaire sur les `%d`.
- Commentaire d'en-tête de la section 10 (« RESTRICTION D'IMPLEMENTATION ») réécrit selon l'ADR 0005, annotations du 13/11 et du 13/11 (bis) : formules des paragraphes 4 et 5 calculables à la lettre si I = J seulement ; domaine de l'outil plus étroit que D(2)(e) ; refus I > J = choix de la lecture stricte (A), non une exigence du texte ; exclusion d'années d'accident à justifier (art. 219(1)(a) et 19(1)(b)) ; I < J : motif D(2)(e) seul. Disparus : « trapeze dont le texte ne precise pas le traitement », « convention implicite ».
- `tests/unitaires/test_controles_entree.R` : texte complet de MW-04 (8 × 6) remplacé ; cas I < J ajoutés (`mw_valider_triangle(cbind(triangle(5), NA))` et `run_engine()` 8 × 9 via `refus_mw_527()`) : un seul motif, « D(2)(e) », sans « non carre » ; tests « 6 x 5 » et 8 × 7 (#520) gardés, toujours justes.

## Valeurs des `%d`
`I <- nrow(tri) - 1L`, `J <- ncol(tri) - 1L` (indices) ; le `sprintf` reçoit `nrow(tri), ncol(tri)` (comptes). 8 × 6 → « (8 annees d'accident, 6 annees de developpement) ».

## Autres occurrences de « non carre »
`R/engine.R` ~l. 7750 et ~7889 (motif de colonne 0 vide, #520), justes pour I > J ; en-têtes et tests #520/#522 génériques ; aucune dans `app.R` ni `R/display_helpers.R`.

## Vérifications (`LC_ALL=C.UTF-8`)
- `test_controles_entree.R` : 411 / 411 (cas `openxlsx` et `zip` sautés, paquets absents).
- `comparer_references.R --seuil 0` : toutes `CONFORME`, écart maximal 0.
- `concordance_doc_moteur.R --strict` : 0 écart.

## Tableau avant / après (aucun σ_USP, p-value ni verdict changé)
| Objet | Avant | Après |
|---|---|---|
| Texte de MW-04 | « … cas non couvert par les formules des paragraphes 4 et 5 de la section D de l'annexe XVII. » | texte de la décision 2 |
| Triangle I < J (5 × 6, 8 × 9) | MW-03 et MW-04 | MW-03 seul |
| Triangle I > J | MW-04 | MW-04 (nouveau texte) |

## Surface d'impact documentaire
`doc_tests_usp.tex` l. ~4781 (tableau de `sec:controles`, « Géométrie carrée »), ~5041, ~14677 (encadré « Restriction d'implémentation » de `sec:mw`, qui parle encore de « trapèze dont le texte ne précise pas le traitement » et de « convention implicite »). Aucun décompte, tableau 1 ou 2, fiche ni nom de fonction.
