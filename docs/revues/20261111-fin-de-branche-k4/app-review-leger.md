# `app-review` léger, branche K4 (tête `c90e65a`)

> *Rapport d'`app-review` reproduit par la session K4 (mise en forme seule).*

**Verdict : aucun écart.** Rien n'est écrit dans le dépôt, aucune issue créée.

1. **Diff de `tests/unitaires/test_application.R`** : 4 hunks, 8 lignes ; chaque hunk remplace le texte attendu par le nouveau texte du moteur (l. 450, 457, 1110, 1500), avec `identical()` ou `grepl(fixed = TRUE)` et les conditions autour inchangées ; aucune assertion supprimée ni affaiblie. `test_application.R` : 215 / 215 ; `test_rapport_html.R` : 296 / 296.
2. **Restitution** : aucun traitement du texte des motifs dans `app.R` (bandeau par `refuser()`, `statut_import$msg`, `validation_live` en `tags$li`, `statut_ui` pour `avertissements_lecture`) ; notifications à texte fixe, sauf « Erreur d'usage : » (inchangé) ; jonction `paste(erreurs, collapse = " ")` lisible (motifs terminés par un point). Colonne « Loi sous H0 » : « – » pour `NA` (11 lignes sur `reserve1`). Pied de #244 reconnu par `endsWith()`, affiché seul dans un `<span>`. Repli des phrases : texte reconstitué identique à l'original pour tous les H0, H1 et commentaires (`reserve1` : 139 textes ; `reserve2` : 67).
3. **Aucun calcul hors du moteur** : `git diff origin/main...HEAD -- app.R R/display_helpers.R` vide.
