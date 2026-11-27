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

## Étape 5 — questions de précision du mode `--familles` (27/11/2026)

- **Avis** : `actuary-questions-etape-5.md` (`actuary-approfondi`), sur le commit `c92b1bb` (#379). Il est rendu **avant toute campagne** : aucun taux de l'étape 6 n'a été vu.
- **Corrections de l'avis de l'étape 1** (choix des tests seulement ; périmètre, graines, R et enveloppe inchangés) :
  - § 5.6, lognormal : le **McNemar exact apparié** contre le point N fonde la classe, à la place de Fisher, car les points partagent la matrice e et les graines de bootstrap ;
  - § 5.6, P1.CST20 et P1.DCAL : le **Fisher exact** contre P1.H0 fonde la classe, car leurs graines (#309) sont indépendantes de celles de P1.H0. Les graines de #309 sont gardées ;
  - § 4.5, second cas de PM-3 (#494) : le niveau de CorrDev sous P1.H0 se compare à #309 par un **McNemar apparié** sur b = 1..500, contre le TSV brut de #309 (avec contrôle `obs:CorrDev` identique), et non par Fisher, car les graines sont communes.
- **Confirmé sans changement** : graine de la matrice e 20260931 (Q1) ; dénominateur n = lignes présentes, comme T-F1 de #297 (Q4) ; comparaison du niveau à #297 laissée à l'étape 7, sous trois conditions (Q5 : m de Bonferroni fixé par méthode, commande versionnée, DGP de P1 à confirmer).
- **Suite** : reprise de `coder-approfondi` pour Q2 et Q3, regroupée avec les constats de l'audit léger de `c92b1bb` (commit `07098e7`).

## Étape 5 bis — questions de précision sur #494 (27/11/2026)

- **Avis** : `actuary-questions-494.md` (`actuary`), sur le commit `ff7673f`.
- **Q1** : rejet lu sur `p_mc` pour CorrDev et DW, confirmé (même grandeur que la p retenue, par construction de `add()`). La colonne « p retenue ≠ p_mc » de F3 doit rester à 0 ; un écart revient à actuary avant toute lecture.
- **Q2** : statut d'admission différent de #309 compté en INTEGRITE ECHEC, accepté. Un tel échec revient à actuary pour en établir la cause, puis au mainteneur.
- **Q3** : classe du niveau de CorrDev sous H0 jugée contre la taille ρ de #309, acceptée. Elle ne vaut qu'à B = 999.
- **Q4 (#494)** : « ligne présente = p_mc finie » accepté sous condition : si n < admis pour CorrDev ou DW dans une cellule, la lecture du § 4.5 se fait sur le dénominateur des admis, p absente comptée comme non-rejet, et le fait est signalé. Précision de la note de F3 recommandée (texte seul).

## Étape 2 — questions de précision sur #421 (27/11/2026)

- **Avis** : `actuary-questions-421.md` (`actuary`), sur les commits `4a2f6bf` et `4e0a829`.
- **Validés tels quels** : schéma de graines (20261031 à T = 8, flux du 31/10 identique au bit ; 421 000 000 + T ailleurs, plage nouvelle sans collision) ; contrôles M, B et C bloquants à T = 8 seul (à T = 4, les paires non croissantes découlent de la limite L₋ = 0 démontrée) ; seuil de K421-3 maintenu à 1e-3.
- **Corrections du code demandées** (écarts au protocole écrit, dans le périmètre de la réserve M42) :
  - K421-3 : lecture « sans objet » dès que le **minimum** des deux déficits est inférieur à **1e-6** (fondé a priori sur la tolérance de `integrate()`, et non sur les valeurs vues) ;
  - K421-2 : p bilatérale **binomiale exacte**, p bornée à [1e-9, 1 − 1e-9], seuils 2,700e-3 (signalé) et 6,334e-5 (désaccord), traduction exacte de 3 et 4 ET ; dénombrement corrigé à **130** comparaisons.
- **Nom du tableau de `mesure_lb1_dw_t8.R`** : la session suit la recommandation d'actuary. Aucun tableau n'est versé à l'étape 6, puisque la sortie est identique au tableau du 20/10 hors T0 (Q-78-4 (a) satisfaite par la réexécution du commit `4a2f6bf`). Nom daté gardé, `CAS_A` inchangé.

### Trace M42 (réserve acceptée par le mainteneur à l'étape 1)

Avant l'exécution officielle de #421, les essais du coder et un contrôle ciblé du flux de T = 8 ont affiché les valeurs suivantes :
- T = 8, fréquences des lignes ajoutées : 0,9877625 et 0,981855 à ρ = −0,9999 ; 0,9988 et 0,998165 à la garde ;
- T = 5, α = 0,10 : écart relatif de K421-3 égal à 1,09e-3, juste au-dessus du seuil de 1e-3 ;
- T = 5, α = 0,05 : marge m = 6,042e-4, donc L₋ = 0 décidée.

Les deux corrections du 27/11 (K421-3 et K421-2) visent la lisibilité des lectures. Elles sont fondées a priori (tolérance de quadrature, loi exacte) et ne déplacent aucun verdict à T = 4, 5 ou 8. Le seuil de 1e-3 de K421-3 n'est pas modifié au vu de la valeur 1,09e-3 : la lecture « régime non atteint, écart relatif 1,09e-3 » paraîtra avec sa valeur.
