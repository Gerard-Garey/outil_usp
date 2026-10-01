## Objet

<!-- Ce que change cette PR, et l'issue concernée (Closes #...). -->

## Résultats modifiés

<!-- « Aucun », ou un tableau : grandeur / avant / après / explication. -->

## Escalades, relances et arrêts

<!-- « Aucune », ou une ligne par escalade, relance ciblée ou arrêt (docs/agents/routage.md, § 7) : fiche / modèle / critère déclenché / statut obtenu / suite. -->

## Contrôles

- [ ] Les tests passent : `Rscript tests/test_reproductibilite.R`
- [ ] Les tests unitaires passent : `Rscript tests/test_unitaires.R`
- [ ] Si des résultats changent volontairement : références régénérées (`Rscript tests/generer_references.R`) et écarts expliqués ci-dessus
- [ ] Aucun calcul quantitatif hors de `R/engine.R`
- [ ] Documentation LaTeX mise à jour selon `docs/latex/CONVENTIONS.md` et PDF recompilé (`docs/latex/`)
- [ ] Circuit d'agents suivi (voir « Sous-agents » dans `CLAUDE.md`) : vérificateurs concernés conformes (`audit`, `app-review`, `regulatory`), validation `actuary` pour toute évolution méthodologique
- [ ] Changement de σ_USP ou d'un verdict : approuvé par le mainteneur
