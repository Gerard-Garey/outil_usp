# KR, passage de remise : rapports versés (14/11/2026)

> Versé par la session principale (Q-54-10). Branche `claude/passage-de-remise`, PR brouillon #578, base `f8ff168`.

## Synthèse

### Étape 1 (i), #573 : lecture amont du motif `phrase_res2`
- `regulatory-573-amont.md` (`regulatory`, fiche de base, `medium`) : « La methode du risque de reserve no 2 reste ouverte (meme point). » excède l'art. 220 (écart de qualification, sans effet sur σ_USP ni sur les verdicts). **Recommandation : suppression pure** ; variante de réécriture citant l'art. 220(2) donnée en repli.
- `actuary-573-avis.md` (`actuary`, fiche de base) : confirme la **suppression pure**, écarte la variante citant l'art. 220(2) et propose une phrase de repli sans elle. Il complète le périmètre : test l. 4799, `.tex` l. 4398. Il vérifie l'absence de la chaîne dans les six références.
- **En attente** : visa du mainteneur sur le texte (m2), avant `coder-approfondi`.
- **Visa du mainteneur** (14/11) : suppression. Exécution : `c5a1953`, `1b8419f`, `05fbe78` ; `audit` léger (`audit-573-leger.md`) conforme, un mineur repris ; `regulatory` en aval (`regulatory-573-aval.md`) conforme.

### Étape 2 : balayage et mesure de #575 (`etape-2/`)
- Aucune citation du moteur périmée dans le `.tex` hors #573 ; renvois de lignes de `docs/suivi-documentation/` tous datés à un SHA, aucune renumérotation.
- #575 : segfault **aussi sous `openxlsx` 4.2.5.2** (version de la CI), direct et par `engine_lire_xlsx()` ; lecteur interne : NA, refus en aval. Noté sur #575.

### Batteries sur l'état gelé (`a2f9c3a`), session
- Unitaires sans `openxlsx` : 3815 / 3815 ; **avec** `openxlsx` 4.2.5.2, `zip` 2.3.1, `shiny` 1.8.0, `plotly` 4.10.4 : **4019 / 4019, aucune ligne « [saute] »** ; références identiques au seuil 0 ; reproductibilité OK ; concordance `--strict` à 0.

### Étape 4 : `audit` `high`
- (i) registre (`audit-high-i-registre.md`) : **conforme avec réserves** ; invariants des six références respectés ; deux mineurs (commentaires périmés sur l'argument `verdict` d'`add()`).
- (ii) entrées-sorties (`audit-high-ii-entrees-sorties.md`) : **conforme avec réserves** ; **majeur M1** : cellule booléenne lue 1 par le chemin `openxlsx` (`.en_numerique()`, antérieur à la branche, sans effet sur les six cas) ; mineurs m1 (référence de cellule dupliquée), m2, m3 (écrivain xlsx).

### Étape 5 : `app-review` intégral (`app-review-integral.md`)
- **Conforme** ; valeurs affichées égales au moteur ; impression de la surface 3D vérifiée avec et sans WebGL ; Version 2.1.0 et md5 (`R/engine.R` `818f276d8941e5780468382c640f8cfa`, `R/charger_moteur.R` `5ed6226c768d5ad781ea03a7306ccc11`) au rapport figé.
- **Majeur M1** : légende plotly ancrée au conteneur ignorée par plotly.js 2.11.1 (plotly 4.10.4), bas de l'histogramme bootstrap masqué ; quatre mineurs.

### Étape 6 : matrice complète de `regulatory` `high`
- Lot 1 (`regulatory-matrice-lot1.md`, art. 218-220, annexes II et XIV, crédibilité) : aucun écart majeur à la date de la remise ; **réserve E-L1-1** : règlement délégué (UE) 2026/269, applicable au 30/01/2027, conditionne le facteur NP de l'art. 117(3) (#504) ; **motif d'arrêt si la date de référence du dossier est postérieure ou égale au 30/01/2027**.
- Lot 2 (`regulatory-matrice-lot2.md`, annexe XVII A-C) : aucun écart majeur ; σ_USP recalculé par transcription indépendante (≤ 2e-8).
- Lot 3 (`regulatory-matrice-lot3.md`, annexe XVII D-G) : aucun écart majeur ; σ_USP MW recalculé, écart nul ; **ancrages de #559 tranchés** (texte exact pour `docwriter`) ; texte de la puce de `sec:mw` (#573) proposé.

### Restant (handoff à la session Windows, PR #578)
Étape 3 (poste), puis 7 à 12 ; décisions du mainteneur sur E-L1-1, les deux majeurs (issue ou dégel) et les issues proposées.
