# Revue finale complète de l'application : PR #511 (K1), branche `claude/entrees-et-validation`, tête `39111c0`

> *Rédigé par l'agent app-review (IA, appelé avec `model: "opus"`), en lecture seule, le 09/11/2026.*

**Verdict : conforme avec réserves.** Les deux commits d'affichage (`e6fc413`, `d8e4a09`) n'ajoutent aucun calcul, et les tests passent. La réserve principale ne vient pas d'un défaut de la branche : c'est un défaut déjà connu, mais il annule dans l'application l'effet de #491. Deux constats mineurs portent sur le repli à 400 caractères.

## Mesures faites (sous `LC_ALL=C.UTF-8`)
- `Rscript tests/unitaires/test_application.R` : **170/170**, dont les 97 assertions du processus Shiny (140,8 s).
- `Rscript tests/unitaires/test_rapport_html.R` : **256/256**.
- Scénarios `shiny::testServer` sur l'import réel par `input$fichier_import`, sur le démarrage et sur le repli des commentaires à partir de `run_engine()` en B = 199, cas premium, reserve1 intérieur et reserve2.

## Points de contrôle

| Point | Résultat |
|---|---|
| Disposition | **Conforme.** `run_engine()` n'est appelé que par l'observateur de `input$go` (`app.R:1181`, `app.R:1217`). L'import ne lance aucun calcul. |
| Onglet Données | **Conforme avec réserve R1.** Le CSV est désormais lu en texte et le moteur seul l'interprète. Les cas mesurés sont tous restitués avec un motif clair : ligne vide intercalée, `0x10`, cellule « NA », ligne courte, `"1 000"`, séparateur `;`, en-tête seul, fichier vide (message fixe, erreur R envoyée au journal seulement), Inf. Les cas valides donnent les valeurs attendues : espaces de bord, guillemets, `1e2`, lignes vides en fin, BOM, virgule finale. Aucune ligne n'est plus retirée sans message. |
| Onglet Tests | **Conforme avec constats C1 et C2.** Aucun texte de `detail` n'est analysé par l'affichage. La phrase de #244 sort toujours du repli. Les nouveaux textes de #514 sont restitués tels quels. |
| Graphiques, Calibration | **Conforme**, non touchés par la branche. `table_robustesse()` affiche le commentaire entier, raccourci par #514. |
| Aucun calcul hors du moteur | **Conforme.** `lire_tableau()` (`app.R:201-210`) ne fait que de la lecture disque. Le seuil de repli (`R/display_helpers.R:403`) est un choix de mise en forme. |
| Messages | **Conforme.** Les refus du moteur arrivent dans `statut_import` (classe `err`). Une erreur de lecture de R est remplacée par `MESSAGE_ILLISIBLE`. |
| Changements du moteur | **Conforme pour #482, #489, #490, #483 et #514.** L'application ne passe jamais d'argument que #489 refuse ; le calcul reserve2 par `go` aboutit. **#491 : voir R1.** |

## Constats

**R1 — Majeur (pour l'objectif de #491), défaut connu précisé.** `app.R:1089-1111` (import) et `app.R:252-262` (démarrage) ignorent `v$avertissements` ; la grille ne crée des champs que pour i + j ≤ I (`app.R:942-946`), et `lire_triangle()` ne relit qu'eux (`app.R:973-981`). Mesure : un triangle 8 × 8 dont la ligne i = 7 porte sept cellules sous la diagonale ; `engine_lire_triangle()` pose bien l'avertissement de #491, mais l'import répond « Triangle 8 x 8 importe… » sans le montrer, ni au démarrage, ni au clic. L'avertissement de #491 n'atteint l'utilisateur nulle part dans l'application (§ 5.2, « sans jamais modifier silencieusement les données »). Recommandation : que l'issue déjà proposée (avertissements d'`engine_lire_triangle()` non affichés) le dise explicitement.

**C1 — Mineur, `R/display_helpers.R:403` et coupe des lignes 420-431, introduit par `d8e4a09`.** Avec un seuil à 400, la fenêtre de coupe est [400, 550]. Sur reserve1 intérieur : 4 commentaires repliés. « Autocorrelation d'ordre 1 (Durbin-Watson) » (551 caractères) est coupé en milieu de phrase ; « Tendance par signes du ratio S/P » (637 caractères) : le résumé ne contient que la phrase « TEST INOPERANT » et la phrase de régime, les deux phrases propres de #514 sont masquées. Décomptes des commentaires repliés, au seuil de 200 puis de 400 : premium 13 → 0, intérieur 18 → 4, reserve2 7 → 0.

**C2 — Mineur, existait déjà.** Sur « Test des suites » et « Test des suites sur ratios bruts » (630 et 649 caractères), la suite masquée est la phrase « ECHEC inatteignable : … », qui sert à lire le verdict.

**C3 — Info.** `tests/unitaires/test_rapport_html.R:1488` dit encore « seuil 200 … aujourd'hui » (les assertions lisent bien `formals()`). L'assertion de repli du processus Shiny (`test_application.R:1392-1396`) passe aussi quand rien n'est replié.

**C4 — Mineur, existait déjà.** `charger_ln()` (`app.R:221`) et l'import de séries (`app.R:1079`) lisent sans `row.names = NULL` : un CSV d'en-tête `xt,yt` dont les lignes portent un champ de plus est accepté dans l'ordre du fichier, la colonne d'années, prise comme noms de lignes, est ignorée sans message.

**Défauts connus confirmés :** import de triangle sans `row.names = NULL` (refus par le message générique, journal « duplicate 'row.names' are not allowed ») ; avertissements non affichés à l'import (R1).

**Observation hors branche (moteur, existait déjà) :** `engine_lire_donnees_csv()` accepte deux colonnes `xt` et lit la première sans message.

## Issues proposées (non créées)
1. Complément à l'issue proposée « avertissements d'`engine_lire_triangle()` non affichés à l'import ni au démarrage » : R1 et C4.
2. `app: repli des commentaires de la vue Détail à 400 caractères, coupe en milieu de phrase et phrases propres de #514 masquées derrière les phrases de tête` (`enhancement`, `needs-triage`) : C1, C2, C3.
