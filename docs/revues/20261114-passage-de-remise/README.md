# KR, passage de remise : rapports versés (14/11/2026)

> Versé par la session principale (Q-54-10). Branche `claude/passage-de-remise`, PR brouillon #578, base `f8ff168`.

## Synthèse

### Étape 1 (i), #573 : lecture amont du motif `phrase_res2`
- `regulatory-573-amont.md` (`regulatory`, fiche de base, `medium`) : « La methode du risque de reserve no 2 reste ouverte (meme point). » excède l'art. 220 (écart de qualification, sans effet sur σ_USP ni sur les verdicts). **Recommandation : suppression pure** ; variante de réécriture citant l'art. 220(2) donnée en repli.
- `actuary-573-avis.md` (`actuary`, fiche de base) : confirme la **suppression pure**, écarte la variante citant l'art. 220(2) et propose une phrase de repli sans elle. Il complète le périmètre : test l. 4799, `.tex` l. 4398. Il vérifie l'absence de la chaîne dans les six références.
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

### Étape 3 : relevé du poste (`etape-3-releve-poste.md`, session Windows)
- **Critère de #548 accepté** sur le gel `a2f9c3a` : seules deux feuilles `stats_boot` de `premium_interieur` au-delà du seuil (réplication 483, `BP` et `BP79`), identiques au 11/11 ; volet `identical()` vert ; md5 égaux au gel. Relevé déposé sur #548.
- `test_controles_entree.R` avec `openxlsx` 4.2.9 : 443 / 444, sans ligne « [saute] » ; échec propre à Windows (octet 0x81) → #588.
- Contrôles manuels du poste (classeurs Excel, md5 du rapport figé, impressions GPU de #566 et #576) : restent au mainteneur.

### Étapes 7 et 8 : `docwriter`, `actuary-approfondi`, `regulatory`
- `docwriter` (`high`) : `06d6717` (#573), `ea9449e` (#559), `1350e13` (#548), `dcd43e2`, `e8a60d4` (#574, #575), `7fceed2` (E-L1-1), `f174f5d` (`\versiondoc` 3.8) ; README par la session : `e86e27c`, `d1a15df`, `a0fe3e2`.
- `actuary-etape-8-tex.md` (`actuary-approfondi`) : lots 1, 2 et 6 conformes ; lots 3, 4, 5 et README conformes avec réserves ; majeurs G1, A, B, C ; aucun bloquant.
- `regulatory-etape-8-aval.md` : passages 1 à 3 conformes ; borne E-L1-1 conforme avec réserves (R1 à R3, mineurs).
- Reprises : `929a5c4`, `fa2918d`, `79a2865`, `3a3bacf`.
- Fin de l'étape 8 : `actuary-etape-8-fin.md` (`actuary`, fiche de base) **visa avec réserves** (m-a, m-b mineurs ; m-c, renvoi l. 4779 facultatifs) ; `regulatory-etape-8-fin.md` **conforme** (C1, C2 mineurs ; P1 facultatif). Décision du mainteneur (14/11) : **mineurs seuls repris** (m-a, m-b, C1, C2), facultatifs écartés.

### Étape 9 : revue finale (règle 10)
- `audit-etape-9-revue-finale.md` (`audit` `high`) : **conforme avec réserves** ; M-1 (README « Reproductibilité et tests » périmé) et M-2 (cette synthèse) corrigés par la session ; m-1 (cases de la fiche KR) au point d'étape d'`architect` ; m-2 (`etape-2/mesure_575.sh`) décrit en tête du script ; m-3 (BOM du message de `244d67f`) noté, non réécrit (Q-43-13).
- `/code-review` (`high`) : aucun constat sur le code ; deux phrases périmées (README, repris ; `CONTEXT.md` l. 236, « environ trois fois la dérive », à joindre à #589 après la remise, décision du mainteneur).
- Batteries de la session sous `LC_ALL=C.UTF-8`, R 4.3.3 : sans `openxlsx` 3815 / 3815 ; avec `openxlsx` 4.2.5.2, `zip` 2.3.1, `shiny` 1.14.0, `plotly` 4.12.1 : **4019 / 4019**, aucune ligne « [saute] » ; `test_reproductibilite.R` : six cas conformes, écart maximal 0 ; concordance `--strict` : 0 écart.

### Issues créées pendant KR
#579 (M1 entrées-sorties, booléens), #580 (écrivain xlsx, m2 et m3), #581 (registre, commentaires périmés), #582 (M1 d'`app-review`, légende plotly), #583, #584 (mineurs d'`app-review`), #585, #586, #587 (`regulatory`, lots 1 à 3), #588 (constat Windows de l'étape 3), #589 (`.claude/rules/moteur.md`), #590 (message de `comparer_references.R`) ; m1 d'`audit` (ii) en commentaire de #574.

### Date de référence du calcul (R1 de `regulatory`, pièce de remise)
> Date de référence du calcul : [jj/mm/aaaa], antérieure au 30 janvier 2027, date d'application du règlement délégué (UE) 2026/269 (article 2) ; domaine de validité de l'outil : `sec:segments`, paragraphes « Limite de périmètre » et « Borne supérieure du domaine ».

*Date à compléter par le mainteneur à la production des rapports figés (décision du 14/11/2026).*

### Restant
Étape 10 (veille de #463 et #504, note de renvoi), étape 11 (PDF de fin de branche), étape 12 (gel vérifié, sortie du brouillon, fusion, fermetures, étiquette, rapports figés).
