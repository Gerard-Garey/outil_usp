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

**Complément du 27/11 (audit léger de `4a2f6bf` et `4e0a829`).** Pour vérifier le commit 2, l'audit a fait une exécution complète de `mesure_dw_rho_negatif_t8.R`, sans `--ecrire`, sur une extraction hors dépôt. Lectures qu'il a vues avant l'exécution officielle :
- K421-1 : 26 couples décidés sur 26, avec L₋(4 ; 0,10) = 0 et L₋(5 ; 0,05) = 0 ;
- K421-2 : 0 comparaison signalée sur 130 ;
- K421-3 : 19 couples stables, 5 en régime non atteint, 2 sans objet (T = 100, ancienne garde) ; à T = 5, écarts relatifs 1,754 (α = 0,05) et 1,091e-3 (α = 0,10) ;
- K421-4 : rang T − 1 partout, écart maximal 1,154e-6 ;
- K421-5 : 31 lignes de T = 8 identiques au 31/10.

Le calcul est déterministe (quadrature, puis graines fixes) : l'exécution officielle de l'étape 6 rendra les mêmes nombres. Les corrections de la reprise (A1 et A2 d'actuary, mineurs 1, 2, 4, 5 et 6 de l'audit) ont été décidées avant cette exécution pour A1 et A2, et portent sur la forme des lectures et des gardes pour les autres ; aucun seuil n'est déplacé au vu de ces valeurs. Décision de la session sur le mineur 1 de l'audit : K421-5 (lignes de T = 8 différentes du 31/10) refuse `--ecrire`, conformément au critère d'acceptation de la fiche S9 ; K421-2 en désaccord reste une lecture qui déclenche PM-3.

## Étapes 2 (reprise), 3 et 4 — audits légers et questions de précision (27/11/2026)

- **Audits légers** (`audit`, `medium`), tous **conformes avec réserves** :
  - `6d7295e` (reprise de #421) : A1, A2, K421-5 bloquant et mineurs 1, 2, 4, 5, 6 de l'audit précédent vérifiés corrigés ; `--essai` vert ; `test_dw_limite_rho.R` et `test_outillage_mesure.R` verts (114 assertions) ; trois mineurs de forme (texte de la section 2 de la sortie, filtre PM-3 vacuement vrai car `TS_CITES_TEX` = `TS_COMPLET`, colonne `SIM$index` morte).
  - `b8e8672` (#420) : un **majeur**, script absent de `tests/unitaires/test_garde_ecrasement.R` (`SCRIPTS_ECRIRE`, `GARDES_ANTICIPEES`, `CAS_A`) ; deux mineurs (ET jackknife de taux marginaux fixés par construction ; NaN non gardé si un sous-échantillon n'a aucun rejet).
  - `b994b7d` (#367) : quatre mineurs (lecture sans le seuil α/2 de `add()` ; (g2) limité à g_obs ; contrôle de plage sur littéraux isolés, faux positif 66335758 ; `CAS_A` sans `--grubbs-interieur --ecrire`).
- **Avis** : `actuary-questions-420-367.md` (`actuary`), rendu **avant toute exécution complète** de #420 et #367.
  - #420 : Q1, cas résiduel du § 2.4 fermé a priori par deux branches (« dépendance forte, non quasi redondante » si P(CvM|AD) estimée < 0,75 sur un jeu ; sinon « quasi-redondance non établie à B = 9 999 »), PM-3 dans les deux cas ; Q2, critère sur min(P(CvM|AD), P(AD|CvM)), égales par construction sans ex aequo, contrôle d'égalité ; Q3, jackknife non pondéré accepté, incertitude de l'ET (≈ 16 %) à écrire sous T5 ; Q4, taux marginaux « par construction » sans ET ; Q5, `stop()` si jackknife dégénéré.
  - #367 : Q6, agrégat sous Clopper–Pearson légitime sous l'hypothèse d'usage déclarée d'indépendance des flux, χ² d'homogénéité des K_s/N_s ajouté comme constat (**retenu par la session**) ; Q7, **lecture sur l'agrégat des quatre graines secondaires**, graine du dossier rapportée à part (effet de sélection des tirages qui ont fait naître #367), agrégat à cinq imprimé sans lecture ; Q8, lecture à cinq issues avec α/2 tiré de `meta$alpha`, contrôle du `sens` de la ligne Grubbs ; Q9, (g2) étendu à δ̂, γ̂, σ̂ et σ_USP.
  - #421 : Q10, exemple du point 2 de `actuary-questions-421.md` corrigé par note (8,0e-4 et 1, valeurs bilatérales ; classement inchangé) ; deux non-rejets à Imhof tronqué donnent un désaccord, à lire « simulation ou quadrature ».
- **Trace M42** : les écarts au protocole écrit de l'étape 1 (Q1, Q2 de #420 ; Q7, Q8 de #367) sont décidés avant toute exécution complète de ces deux mesures, sur les seules sorties `--essai` à B = 299 et 199 (non représentatives) ; la session les trace ici, dans le périmètre de la réserve M42 acceptée à l'étape 1, et les signale au mainteneur au compte rendu.
- **Suite** : reprise unique de `coder-approfondi` (`high`) regroupant ces corrections, l'enregistrement de `mesure_correlation_cvm_ad_t8.R` dans `test_garde_ecrasement.R`, les mineurs des trois audits et les trois mineurs restants de l'audit de `ff7673f` (#494) ; audit léger du diff.

### Reprise unique (27/11/2026)

- Commits `db53649` (#420, et second cas `--grubbs-interieur --ecrire` de #367 dans `test_garde_ecrasement.R`), `c8e2eec` (#367), `945b21e` (#421), `9b730fb` (#494, trois mineurs de l'audit de `ff7673f`) ; `coder-approfondi` (`high`) ; seules des sorties `--essai` vues.
- Quatre questions du coder tranchées par `actuary` (annexe de `actuary-questions-420-367.md`) : IC contenant α/2 et α signalé ECHEC/ALERTE ; seuil OK `borne basse ≥ α` (écart de cohérence au § 3.4, ajouté à la trace M42 avec Q8) ; T3 de #420 inchangé ; p du χ² d'homogénéité qualifiée d'asymptotique (une ligne).
- Durées extrapolées des `--essai` : #421 environ 1 min ; #420 environ 6 min ; #367 17 à 21 min ; #494 `--familles` 3,3 à 3,7 h sans P2, 4,8 à 5,2 h avec P2 (PM-2).

## Étape 6 — pré-vol, PM-2 et exécutions officielles (27/11/2026)

- **Pré-vol** (machine au repos, quatre processus) : lognormale `--familles` 1,90 h ; Merz-Wüthrich `--familles` 2,75 h sans P2, 4,02 h avec P2 ; INTEGRITE OK dans les deux cas. Enveloppe de 10 h respectée avec P2 : aucun retrait de l'ordre Q-78-2 (a).
- **PM-2** (27/11, vers 14 h 50 UTC, questionnaire au mainteneur) : périmètre **P1 + P2**, campagne Merz-Wüthrich en **trois segments** (option recommandée) ; M42 (c) : **pas de branche de sauvegarde**, dossier de travail hors dépôt seul (option recommandée). Aucun commit sur la branche pendant chaque campagne (M42).
- **Exécutions** (`--ecrire`, arbre propre, tableaux versés tels que produits) :

| Mesure | Commit du calcul | Segments (`--arret-apres`) | Horloge | Bilan | Tableau |
| --- | --- | --- | --- | --- | --- |
| #421 | `6e0c7b6` | 1 | ≈ 1 min | OK | `ac88b46` |
| #420 | `ac88b46` | 1 | 261,8 s | OK | `c8829b7` |
| #367 | `c8829b7` | 1 | 838,4 s | OK | `caa38f1` |
| #379, lognormale | `caa38f1` | 2 (115 min) : 216 + 24 tranches | 6 828 + 741 s ≈ 2,1 h | OK, INTEGRITE OK | `2a2d636` |
| #494 et #379, Merz-Wüthrich (P1 + P2, 7 cellules) | `2a2d636` | 3 (110 min) : 49 + 55 + 20 tranches | 5 784 + 6 535 + 2 311 s ≈ 4,1 h | OK, INTEGRITE OK | `f566b9d` |

- **Constats mécaniques** (sans lecture : étape 7, `actuary-approfondi`, PM-3) :
  - #421 : K421-1 26 / 26 couples décidés, L₋ = 0 pour (4 ; 0,10), (4 ; 0,05) et (5 ; 0,05) ; K421-2 0 / 130 comparaisons signalées ; K421-3 19 stables, 3 en régime non atteint, 4 sans objet ; K421-4 écart maximal 1,154e-6 ; K421-5 31 lignes de T = 8 identiques.
  - #420 : ρ_S 0,9779 (J1) et 0,9763 (J2) ; P(CvM | AD) à 0,10 : 0,8999 et 0,8809 ; lecture mécanique « quasi-redondance sous H0 établie ».
  - #367 : agrégat des quatre graines secondaires 4 019 / 39 996, p̂ = 0,10049, IC de Clopper–Pearson à 99 % [0,09665 ; 0,10442], contenant α : **indécidable ALERTE / OK**, aucun signal au mainteneur ; graine du dossier 0,0975 (ALERTE), rapportée à part ; χ² d'homogénéité, p asymptotique 0,686.
  - #379, lognormale : un seul signal PM-3 évalué mécaniquement (J1, point A, famille D., α = 0,10 : π̂ 0,070 contre π̂(N) 0,110, McNemar unilatéral 0,0403).
  - #494 et #379, Merz-Wüthrich : aucun signal PM-3 ; recoupement avec le brut de #309 identique triangle par triangle (P1.H0, P2.H0 : 500 / 500, p_mc de CorrDev = p:CorrDev) ; F4, taux de CorrDev compatibles avec ρ dans les quatre cellules H0 ; second cas de PM-3 : n01 = n10 = 0, p = 1, résultat mécanique attendu (avis de l'étape 5 bis, Q3).
