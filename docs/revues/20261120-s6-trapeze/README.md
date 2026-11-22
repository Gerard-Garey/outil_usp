# S6, Merz-Wüthrich sur un trapèze I > J : rapports versés (20-22/11/2026)

> Versé par la session principale (Q-54-10). Branche `claude/merz-wuthrich-trapeze`, PR #611, base `c8840d4` (fusion de S5, PR #609). Issues #567 et #610 ; `Refs` #540, #387, #305, #492, #206, #463, #612. Plan : soixante et onzième point de `docs/feuille-de-route.md`, fiche « Branche S6 — Merz-Wüthrich sur un trapèze I > J » ; décisions Q-71-1 à Q-71-7 du 20/11, toutes en (a).

## Contenu du dossier

| Fichier | Auteur, étape | Objet |
|---|---|---|
| `regulatory-1-lecture-trapeze.md`, `regulatory-1-trap.R` | `regulatory` (`high`), étape 1 | lecture ciblée de D(2)(c), D(4), D(5), G(3)(c) pour I > J ; lectures (A) et (B) |
| `actuary-2a-specification-567.md`, `actuary-2a-prototypes/` | `actuary-approfondi`, étape 2a | spécification D1 de #567, protocole de niveau P1 à P8 (annotée le 21/11 : M2, m1) |
| `actuary-2b-protocole-610.md`, `actuary-2b-reponses-script-610.md`, `actuary-2b-pilote/` | `actuary-approfondi`, étape 2b | protocole de #610, candidats C1 et C2 |
| `actuary-5b-avis-m1-graines-567.md` | `actuary`, étape 5 | graines de l'oracle (P3 amendé) |
| `actuary-5-lecture-610.md`, `actuary-5-lecture-610/` | `actuary-approfondi`, étape 5 | lecture de la couverture de #610, profil Θ3, préparation de D3 |
| `actuary-5b-lecture-567.md` | `actuary-approfondi`, étape 5 | lecture de l'étude de niveau de #567, constat PenteIntra sur 8×7, préparation de D2 |
| `actuary-qa1-deux-sigma-trapeze.md` | `actuary`, `app-review` | Q-A1 : deux σ de la colonne J−1, forme (ii) |
| `architect-6-forme-etape6-fable.md` | `architect-approfondi` (Fable 1 sur 3) | forme de l'étape 6, ADR 0005 |
| `t0-textes-etape6.md` | `actuary`, `regulatory` | textes (t1) à (t4) de l'étape 6 |
| `regulatory-7-conformite-aval.md` | `regulatory` (`high`), étape 7 | conformité en aval du code ; mineur m1 |
| `actuary-7-avis-m1-motif-degenere.md` | `actuary`, étape 7 | motif « Triangle totalement dégénéré » sur trapèze ; décision (i) |
| `regulatory-8-conformite-tex.md` | `regulatory`, étape 8 | conformité du diff du `.tex` ; mineurs r1, r2 |
| `actuary-10-avis-m1-bootstrap-jm1.md` | `actuary-approfondi`, étape 10 | constat M-1 de la revue finale, option (b) ; errata en tête |
| `actuary-9-validation-tex.md` | `actuary-approfondi`, étape 9 | validation du `.tex` (M-a, M-b, m-1 à m-6) ; erratum de l'avis actuary-10 (k = 1e4) |
| `actuary-11-erratum-clause-min.md` | `actuary`, étape 10 | clause numérique du prédicat M-1 sur le plus petit cumul ; erratum de l'avis actuary-10 |

## Synthèse

### Étapes 0 à 5 et points d'arrêt D1', D2, D3 (20-21/11)
- Ouverture `c181bf1` ; lecture `804a45b` ; spécifications `25a1a64`, `59cab86` ; D1' `bb2db99` (généralisation sous la garde MW-04).
- Fonctions internes à I ≥ J sous MW-04 : `74e6819`, `ea80386`. Scripts et mesures hors CI (M42) : MSEP du trapèze confrontée à `CL_MSEPs` (≤ 4,2e-16, `f573ddc`) ; niveau L0 sur 8×5, 8×6, 8×7 (`5297cd8`) ; couverture de C1 et C2 pour #610 (`425c1c9`).
- **D3** (#610) : option (a), constat seul, sans restitution (`7010100`). **D2** (#567) : option (a′), extension ; Θ0 levé, réserves MinP4 conservateur, PenteIntra libéral sur 8×7 (#612), statut épistémique (`5521213`) ; ADR 0005 annotée, lecture (B) sous la forme consolidée seule (`c1f0279`).

### Étape 6 : levée de MW-04 (21/11)
- C1 `59ef487` (deux σ de J−1, mention M6, `mw_cellules_observees()`), référence `reserve2` régénérée par la CI (`b232cbe`, ajouts seuls) ; C2 `app:` `ac363b1` ; **C3 `f9eaff7`**, seul commit de l'étape qui change un résultat (trapèzes auparavant refusés), visé par le mainteneur, cas `reserve2_trapeze` créé par la CI (tableau `docs/tableaux/20261121-issue567-levee-mw04.md`) ; C4 `688ee12`.

### Étape 7 : conformité en aval (21/11)
- `regulatory` : aucun bloquant ni majeur ; R̂, MSEP, σ_USP égaux à une transcription littérale (écart 0) ; mineur m1 corrigé en `1c781be` (décision (i)). Reprise de l'application après revue sur rendu réel : `9ae0b83`.

### Étape 8 : documentation (22/11)
- `docwriter` (`high`) : `ddb7b0f` (#567), `6f200c4` (#610), `f4e8f2e` ; contrôle de `regulatory` : r1, r2 (corrigés en `7d107ab`), annotation de l'ADR 0005 (`3fff477`).

### Étape 10 : revue finale (22/11), avant l'étape 9 pour le code
- `audit` (`high`) : un **majeur M-1** (colonne J−1 d'un trapèze simulée sans variance quand la règle de minimum est nulle ou négligeable ; Origine sans p-value, PenteIntra libéral). Avis d'`actuary-approfondi`, **décision du mainteneur : option (b)** (simulation de J−1 sur l'estimateur direct dans ce seul cas, dérogation à Q-2a-2) ; correctif `dba7bfc`, **verdicts changés visés par le mainteneur** sur la classe d'entrées visée (tableau `docs/tableaux/20261122-issue567-m1-simulation-jm1.md`), références identiques au bit ; m-1 (mention M6 et `usage_sigma` par cas) et m-3 (`f26d84a`). Audit léger conforme ; `app-review` léger conforme.
- `app-review` (`opus`, rendu réel) : conforme.
- `/code-review` : un point « important », la clause numérique du prédicat lit `min` des cumuls de J−1 et non `max` (avis `actuary-11`, correctif `45f08cf`, audit léger conforme, `.tex` `7be7c5e`) ; la classe d'entrées concernée devient strictement plus petite, sans effet sur les références ni sur le tableau.

### Étape 9 : validation du `.tex` (22/11)
- `actuary-approfondi` : validé avec réserves (M-a, M-b, m-1 à m-6), corrigés en `aaa987a` ; relecture du diff : **visa définitif** ; m-7 corrigé en `7be7c5e`.

### Étape 11 : veille et PDF (22/11)
- Veille de #463 du 22/11 : aucun fait nouveau. PDF de fin de branche `947ace7` (`.tex` de `7be7c5e`, 475 pages).

## Constats mineurs écartés (ADR 0018, critère « aucun »)

- `app-review` (revue finale) : σ de J−1 presque superposés dans la figure plotly étroite ; l'aperçu remonté repousse la grille des méthodes lognormales ; motif de refus de dimension nommant l'axe des années d'accident pour J > I (inatteignable) ; largeur des cellules de la grille ; « n ≥ m » en Unicode.
- `app-review` (revue légère de `dba7bfc`) : marqueur à σ = 0 rogné par le bord de l'axe en plotly ; graduations en demi-années à 900 px.
- `audit` (revue finale) : `I − J` calculé dans `texte_formule()` (argument fixé par T0, arithmétique d'indice) ; `test_inoperance.R` sans `premium_interieur` (antérieur).
- `audit` (léger, `45f08cf`) : en-tête de section du moteur « ne sert qu'aux résidus… » lisible comme exhaustif (sens : « entre dans un calcul »).
- `/code-review` : mention M6 « simulation » même si aucune réplication n'aboutit (plafond des retirages) ; commentaire de section et lecteurs de `.mw_sigma2_residus()` (corrigés en `45f08cf`).
- `regulatory` (étape 8) : remarques R-a, R-b sans écart.
- `actuary` (hors périmètre) : `mw_residus()` dans les réplications pour une dispersion entre 1e-12 et 1e-10 ; régime σ_règle ≪ σ_dir non nul (E3, suivi par #612).
