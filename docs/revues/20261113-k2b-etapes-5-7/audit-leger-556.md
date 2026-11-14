# Audit léger de #556 (étape 6 de K2b)

> Versé par la session principale (condensé fidèle). Règle 10, diff non commité sur `f7d4665`. 13/11/2026.

**Conclusion : conforme avec réserves** (deux mineurs de commentaire ou de libellé ; code et assertions justes).

## Points
- Textes du moteur : moteurs de `HEAD` et de l'arbre comparés en provoquant chaque erreur ; `identical(msg)` et `identical(charToRaw(msg))` `TRUE TRUE` ; classe `simpleError` → `usp_refus_ecriture` ; `conditionCall` `NULL` avant et après ; aucun fichier laissé.
- Aucun autre changement de logique du moteur (`engine_ecrire_csv()` non touchée) ; références identiques au bit.
- `proteger_export` : erreur d'origine relevée (classe gardée) ; journal avant notification ; garde `shiny.silent.error` testée ; pas de fichier temporaire propre à l'enveloppe ; cinq `downloadHandler` enveloppés (assertion par lecture du source).
- Aucun calcul dans `app.R` ; textes conformes mot pour mot à l'avis § 7.
- Tests pertinents (classe, texte octet pour octet, quatre branches de refus, exports en échec, garde silencieuse, succès).

## Constats
1. Mineur : commentaire de `lire_tableau()` (`app.R:255-258`) périmé (même réserve qu'`actuary` et `app-review`).
2. Mineur : libellés de `verifier` de `test_controles_entree.R:5013` et `:5059` (« erreur R ordinaire ») faux depuis la classe `usp_refus_ecriture` ; assertions vraies.

## Vérifications (`LC_ALL=C.UTF-8`)
| Commande | Résultat |
|---|---|
| comparaison `HEAD` / arbre des deux erreurs | identiques au bit |
| `test_controles_entree.R` avec / sans `R_LIBS` | 435 / 435 ; 419 / 419 |
| `test_application.R` (shiny 1.14.0) | 236 / 236 |
| `comparer_references.R --seuil 0` | 0 écart sur 57 018 valeurs |
| `concordance_doc_moteur.R --strict` | 0 écart |
| `test_empreinte_moteur.R`, `test_chargement_moteur.R` | 20 / 20, 9 / 9 |
