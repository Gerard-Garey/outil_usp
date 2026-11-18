# S3, règlement délégué (UE) 2026/269 — rapports versés (17-18/11/2026)

> Versé par la session principale (Q-54-10). Branche `claude/reglement-2026-269`, PR brouillon #599, base `edf7ff9`. Issues #504 et #598.

## Synthèse

### Étape 1 : lecture amont (`regulatory-lecture-amont.md`)
- `regulatory` en `high`, sur `d6a9ecc`, texte primaire (JO série L 2026/269, versé à la racine, `4be0a47`) lu en rendu graphique, consolidation `02015R0035-20270130` lue pour contrôle. Outil conforme dans le domaine déclaré ; borne du 30.1.2027 exacte ; aucune disposition transitoire.
- Interprétations renvoyées à l'étape 2 : R-1 (date d'appréciation), R-2 (« il existe une telle réassurance non proportionnelle »), R-3/R-4 (paramètre de réserve en présence d'une CDD qualifiante).

### Étapes 2 et 3 : avis d'`actuary` et décision D2 (`actuary-avis-etape-2.md`, `decisions-mainteneur.md`)
- `actuary-approfondi` : la modification est une règle déterministe sur le paramètre standard du mélange, non un test ; aucune p-value ni aucun verdict touchés (*vérifié*). Écart exact Δ = (1 − c)(1 − facteur) σ_annexe ; données nettes sans réassurance NP : σ_USP +0,0082 (II-1), +0,00304 (II-4), +0,01148 (II-5), côté prudent. Recommandation : étendue E-B.
- Décision D2 du mainteneur (17/11) : E-B, lectures R1-a, R2-b et R2-d, R-3 laissée ouverte avec refus motivé en présence d'une CDD qualifiante, date de référence obligatoire sans défaut, borne M6 contrôlée par la même date (D-S3-1 à D-S3-10). Plan de forme : ADR 0019 accepté, Q-S3-1 à Q-S3-7 (même fichier).

### Étape 5 : réalisation et tableau avant / après
- Commits (0) `0e388e5`, (a) `de83b19`, (b1) `73fd059` (patch non numérique, 24 feuilles), (b2) `d72b430`, (d) `98fab0a`, (b3) `4182f72`, (d2) `b7f40a7`, (c) `acac7d2`, (e) `2364560` ; ordre amendé deux fois par le mainteneur (E-17/11 (ordre b3/d) et (avant clic)).
- (c), seul commit qui change σ_USP : tableau `docs/tableaux/20261117-issue504-facteur-np-conditionnel.md`, produit par `scripts/tableau_c.R` ; **visa du mainteneur du 17/11**. Six cas de référence inchangés (seuil 0) à la date des tests (`"2026-12-31"`).

### Étape 6 : contrôle aval du code (`regulatory-controle-aval-etape-6.md`)
- `regulatory` en `high`, sur `2364560` : règle, tables, écarts du tableau et bornes de date **conformes** ; quatre mineurs de libellé, corrigés (`4a3a4ac`, `1feae61`) ; borne M6 relue à l'image sur le JO L 161. Lecture inclusive de « pour ce segment précis » écrite comme interprétation, décision du mainteneur E-17/11 (ce segment), `bf21a7a`.

### Étapes 8 à 10 : documentation, contrôle du `.tex`, validation
- `docwriter` `high` : `addb439` (#598, fiche `multi-demarrages`), `c8225c0` (#504, `\versiondoc` 4.0).
- `regulatory-controle-tex-etape-9.md` : diff du `.tex` **conforme**, citations exactes au caractère près, six mineurs, corrigés (`d4c8b9f`, `989e87a`) ; `regulatory-relecture-correctif-etape-9.md` : conforme.
- `actuary-validation-etape-10.md` : visa sous réserve M1 ; aucune p-value ni aucun verdict changés (structure et mesure sur 18 cas) ; un repère de lecture franchi (jackknife, II-1 sans NP, 0,1012 → 0,0938), diagnostic INFO. `actuary-relecture-correctif-etape-10.md` : **visa levé sans réserve** ; mineur r1 appliqué (`d775678`).

### Étape 11 : revue finale (`git diff main...HEAD`)
- `audit` en `high` : conforme avec réserves, deux mineurs du périmètre corrigés (`1f139b5`, `5a1e32a`) ; `app-review` en Opus : conforme, sept mineurs écartés ; audit léger du correctif : conforme. CI de `5a1e32a` verte.
- `/code-review` (`high`, 18/11, sur `main...5a1e32a`) : neuf constats, aucun bloquant ni majeur, tous écartés (ADR 0018 ; PR #599).

### Étape 12 : veille et PDF
- Veille du 18/11 : commentaires datés sur #463 (`6970838461`) et #504 (`6970840219`) ; aucun fait nouveau (AEAPP, Office des publications, 2015/498, R. 352-5, R. 356-19, actes modificatifs et consolidations de 2015/35 et de 2026/269, date d'application du 30.1.2027). Premiers rectificatifs relevés : 2026/269 R(01) à R(03), 2015/35 R(14), aucun en français ni sur les art. 117, 148, 218 à 220 ou les annexes II, XIV, XVII.
- PDF de fin de branche `32ea7cc` (`.tex` de `d775678`, pdfTeX-1.40.25, 461 pages, 0 référence indéfinie) ; `\datedoc` au 17 novembre 2026 (version 4.0, `c8225c0`), non modifié.

## Constats hors périmètre (ADR 0018)

- Aucune issue nouvelle.
- **Écartés (mineurs)** : voir la PR #599, « Constats mineurs écartés (ADR 0018) ».
