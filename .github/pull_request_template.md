## Objet

<!-- Ce que change cette PR, et l'issue concernée (Closes #...). -->

## Résultats modifiés

<!-- « Aucun », ou un tableau : grandeur / avant / après / explication. -->

## Escalades, relances et arrêts

<!-- « Aucune », ou une ligne par escalade, relance ciblée ou arrêt (docs/agents/routage.md, § 7), et par emploi de coder-approfondi hors des cas d'office ou passage à l'effort high sur accord du mainteneur, et par appel de regulatory en effort high (§ 10) : fiche / modèle / critère déclenché / statut obtenu / suite. -->

## Contrôles

- [ ] Les tests passent : `Rscript tests/test_reproductibilite.R`
- [ ] Les tests unitaires passent : `Rscript tests/test_unitaires.R`
- [ ] Si des résultats changent volontairement : tableau avant / après (skill `verifier-reproductibilite`), références régénérées par la CI (`references.yml`, mode `regeneration`) ou patch chirurgical (`tests/patcher_reference.R`), écarts expliqués ci-dessus
- [ ] Aucun calcul quantitatif hors de `R/engine.R`
- [ ] Documentation LaTeX mise à jour selon `docs/latex/CONVENTIONS.md` ; si le `.tex` est modifié, commit de PDF de fin de branche fait après le dernier commit du `.tex` (ADR 0008 amendé)
- [ ] Circuit d'agents suivi (voir « Sous-agents » dans `CLAUDE.md`) : vérificateurs concernés conformes (`audit`, `app-review`, `regulatory`), validation `actuary` pour toute évolution méthodologique
- [ ] Changement de σ_USP ou d'un verdict : approuvé par le mainteneur
