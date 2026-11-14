# K2b, étapes 9 et 10 : validation du `.tex` et revue finale (14/11/2026)

> Versé par la session principale (Q-54-10). Branche `claude/lecteur-xlsx-et-refus-import`, PR brouillon #571.

## Synthèse

| Étape | Agent (fiche / modèle) | Objet | Verdict | Suite |
|---|---|---|---|---|
| CI | session | échec du job « Compilation de la documentation LaTeX » sur `2159f93` (exécution 43529857660) : deux `Overfull \vbox` (84,2 pt et 6,4 pt) sous TeX Live 2026, absents sous TeX Live 2023 (session) | — | `e3eb7e7` : lignes d'`engine_lire_xlsx()` et des auxiliaires `.xlsx_*()` de la longtable « Inventaire des fonctions » scindées, texte inchangé ; CI verte sur `8d4ced3` |
| 9 | `regulatory` (base) | lecture réglementaire de #540 dans le `.tex` (règle 11) | conforme, 10 passages ; question annexe : « laisse ouverte la méthode n° 1 » inexacte | [`regulatory-540-tex.md`](regulatory-540-tex.md) |
| 9 | `actuary-approfondi` | validation du diff du `.tex` (règle 9) | conforme avec réserves (m1 à m4) ; question annexe hors périmètre selon lui | [`actuary-validation-tex.md`](actuary-validation-tex.md) |
| 9 | mainteneur | désaccord sur le périmètre de la question annexe | correction dans K2b, `.tex` seul, au titre de #540 ; puce de `sec:mw` et motif du moteur l. 1986 hors K2b | `30bed39` (docwriter) |
| 9 | `actuary` (base) | revue du diff `30bed39` (règle 10) | conforme ; signalement S1 (puce de `sec:mw`) | [`actuary-revue-30bed39.md`](actuary-revue-30bed39.md) |
| — | `coder` (base) | deux commentaires de code relevés par docwriter | — | `16c6b14`, `8d4ced3` |
| 10 | `app-review` (`model: "opus"`) | revue finale complète, rendu réel | conforme, aucun constat | [`app-review-final.md`](app-review-final.md) |
| 10 | `audit` (effort high) | revue finale complète | conforme avec réserves : M-1 (majeur), m-1, m-2, m-3 | [`audit-final.md`](audit-final.md) |
| 10 | mainteneur | M-1 | refus dans K2b | — |
| 10 | `actuary` (base) | texte du refus M-1 | texte unique ; X1 inchangé | [`actuary-texte-refus-m1.md`](actuary-texte-refus-m1.md) |
| 10 | `coder-approfondi` (d'office, § 10) | reprise unique M-1, m-1, m-2, m-3 | — | `c848562`, `585a40d`, `20f7d50` ; [`coder-approfondi-reprise-m1.md`](coder-approfondi-reprise-m1.md) |
| 10 | `audit` (base) | audit léger de la reprise | conforme avec réserves (documentation ; UTF-8 invalide, antérieur) | [`audit-leger-reprise-m1.md`](audit-leger-reprise-m1.md) |

## Résultats

Références : 0 écart au seuil 0 à chaque commit de code (6 cas). Aucun σ_USP, aucune p-value ni aucun verdict changé. Les changements de lecture des classeurs (refus M-1, X1 préfixé) sont tabulés dans `coder-approfondi-reprise-m1.md` et dans le corps de la PR.

## Points ouverts (issues à rédiger, création sur accord du mainteneur)

- Suite de #540 : puce de `sec:mw` (« Le refus ne prive l'entreprise d'aucun droit », « alternatives », « condition de son admissibilité ») et motif `R/engine.R` l. 1986 (« reste ouverte »).
- Lecteur xlsx : chaîne `<x:si>` préfixée mêlée à des `<si>` (indice décalé, valeur fausse possible sur les deux chemins, préexistant).
- openxlsx 4.2.9 : *segfault* sur un indice de chaîne partagée hors bornes (préexistant ; contrôle de bornes possible avant l'appel).
- Lecteur xlsx : table des chaînes partagées en UTF-8 invalide, refus Q-F, P2 et X1 sautés (aucune valeur fausse acceptée ; préexistant).
- Impression : surface 3D WebGL vide dans le PDF (rédigée par `app-review` à l'étape 7, `../20261113-k2b-etapes-5-7/app-review-leger-566.md`).
