# Audit léger de #573 (`c5a1953` `moteur:`, `1b8419f` `tests:`), 14/11/2026

`audit` (fiche de base), lecture seule, tête `98d8741`.

**Conclusion : conforme avec réserves** ; aucun bloquant ni majeur.

## Constat
- **Mineur** — `R/engine.R` l. 2012 : le commentaire « Forme 1 (#188, inchangee) » n'est plus exact en `reserve1` (phrase retirée). Correction proposée : « Forme 1 (#188 ; phrase de la reserve no 2 retiree par #573) ». **Repris** par la session (commentaire seul ; références identiques au seuil 0 après la reprise).

## Points vérifiés
- `phrase_res2` et ses deux usages supprimés ; plus aucune occurrence de la chaîne hors du commentaire et de l'assertion de #573 ; jointure « …point d)). Verifier… » à une espace.
- Ancien et nouveau moteur comparés sur 90 cas (γ ∈ {−12, −11,5, 0, 2,5, 3} × kkt ∈ {T, F, NA} × bord ∈ {T, F, NA} × {premium, reserve1}) : `ok` identique partout ; `premium` identique (`identical()`) ; `reserve1` = ancien motif moins la phrase.
- Nouvelle assertion (`test_controles_entree.R` l. 4810-4821) non triviale : échoue sur l'ancien moteur, passe sur le nouveau.
- Architecture et conventions respectées (commentaires sans accents, préfixes, `Refs #573`, aucun mot-clé de fermeture).
- `LC_ALL=C.UTF-8` : `test_controles_entree.R` 428 / 428 ; `comparer_references.R --seuil 0` conforme sur les six cas, écart maximal 0.
- `openxlsx` non installé dans la session (repli interne), sans effet sur ce changement.

## Traçabilité
`.tex` l. 4398 (« le rappel que la méthode n° 2 reste ouverte ») à aligner par `docwriter` avant la sortie du brouillon (surface d'impact du commit `c5a1953`).
