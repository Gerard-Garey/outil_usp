# S9 : revues versées — synthèse

> *Tenue par la session principale (IA), branche `claude/mesures-t8` (PR #629). Versement intégral des rapports de fond (Q-54-10).*

## Étape 1 — protocoles et critères (27/11/2026)

- **Avis** : `actuary-protocoles-etape-1.md` (`actuary-approfondi`, jugement : spécification, matrice du § 3 de `docs/agents/routage.md`), rendu sur `51d3fbc`.
- **Statut de l'avis** : revue requise. Cinq protocoles complets ; trois choix de périmètre soumis au mainteneur (PM-1).

### Décisions du mainteneur (27/11/2026, questionnaire de la session)

| Question | Décision | Effet |
|---|---|---|
| Q-S9-1 (#379, scénarios) | **(a)** | Lognormal : N, A(0,5), T(2), R(4,2) sur J1 et J2, R = 300 ; Merz-Wüthrich P1 : H0, AR(0,3), AR(0,5), CST20, DCAL. D., M2, C. et M4 déclarés non mesurés. |
| Q-S9-2 (#494, plans) | **(a)** | P1 à ρ ∈ {0,3 ; 0,5} et P1.H0, R = 500 ; P2 (H0 et ρ = 0,5) si le pré-vol le permet ; P3 non mesuré. Nombres aléatoires communs. |
| Q-S9-3 (#421, commentaire de `dw_puissance_ar1()`) | **(a)** | Reformulation rattachée à S10, avec le renvoi de la l. 3805 de `R/engine.R`. #421 se ferme avec S9 pour la mesure et le `.tex`. |
| Réserve de méthode M42 (#421) | **acceptée avec trace** | Les critères K421 sont gardés malgré les quadratures exploratoires faites avant leur rédaction (déterministes, sans tirage, non versionnées). L'étape 6 refait toutes les valeurs par le script versionné. |

### Points à retenir pour la suite

- **Enveloppe** : 8,8 à 10,0 h d'horloge sur quatre processus (hypothèse, à remplacer par le pré-vol de l'étape 6). Ordre de retrait au-delà de 10 h : P2, puis R(4,2), puis CST20 et DCAL à R = 200 (Q-78-2 (a)).
- **Écart avec le plan de l'architecte** : coût de #494 réévalué (environ 25 s par triangle en P1, et non 19 s).
- **#420** : le point 1 est déjà soldé (`tests/unitaires/test_mk_spearman.R`) ; seul le point 2 est mesuré.
- **#367** : la prémisse n'a pas à être tranchée. La quantité visée est p_∞ (B = 9 999, graine du dossier et quatre graines secondaires). Si p_∞ < 0,10 est établi, la session le signale au mainteneur, en lien avec Q-Ff-5, hors S9.
- **Constat mineur écarté (ADR 0018)** : les graines de flux V3b de J2 au volet B lognormal recoupent des graines de triangle de #206. Sans conséquence statistique, car les objets ne sont jamais combinés. Aucun critère.
