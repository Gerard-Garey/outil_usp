# S2, textes : conformité et qualifications — rapports versés (16-17/11/2026)

> Versé par la session principale (Q-54-10). Branche `claude/textes-conformite-et-qualifications`, PR brouillon #596, base `940f941`.

## Synthèse

### Étape 1 : lecture amont (`regulatory-lecture-amont.md`, `actuary-avis-i1-i2.md`, `decisions-mainteneur.md`)
- `regulatory` en `high` : motif de #585, transcription imprimée de B(4)-(6) et C(4)-(6), pages du JOUE, équivalence avec le moteur (≤ 7,4e-14) ; deux questions d'interprétation (I-1, B(1)(a) ; I-2, art. 219(1)(b)).
- `actuary` : lecture (ii) de B(1)(a) ; texte du point b) de l'art. 219.
- Décisions du mainteneur D-S2-1 à D-S2-4 (lecture (ii), citation de la Q&R AEAPP 2580, contrôle de forme seulement pour 219(1)(b), `mw_boot` à 420 px).

### Étape 7 : contrôle aval (`regulatory-controle-aval.md`)
- `regulatory` en `high`, sur `36ae5db` : **aucun bloquant ni majeur**. Motif de #585 conforme octet pour octet ; formules et pages conformes sur l'image dans les deux versions ; équivalence recalculée (écart ≤ 2,2e-16) ; p. 75 (art. 117(2)(a)) confirmée ; lecture de B(3)(c) jugée fidèle.
- Mineurs M-1, M-1 bis, M-2, M-3, M-4 et une remarque de forme : appliqués (`e5b12c3`, `f420184`).
- Relance ciblée (17/11) sur C(1)(a) et D(1) ajoutés en revue finale : **conformes**, sans remplacement.

### Étape 8 : validation du `.tex` (`actuary-validation-tex.md`)
- `actuary-approfondi` sur `f420184` : visa sous réserve de m-1 (refus hors de `BORNES_GAMMA`, absence de garantie d'optimum global). m-1 à m-4 appliqués (`49d02df`, `7346685`, `f797776`) ; **visa définitif**, étendu jusqu'à `0ca4e1b` après les corrections de la revue finale.

### Étape 9 : revue finale (`git diff origin/main...HEAD`)
- `audit` en `high` sur `f797776` : **conforme avec réserves**, aucun bloquant ni majeur. Moteur identique hors de la chaîne du motif (objets chargés comparés par `identical()`). Batteries sous `LC_ALL=C.UTF-8` : unitaires 3931/3931 (`--parallele`), reproductibilité 6 cas à écart 0, `comparer_references.R --seuil 0` 0 écart, concordance `--strict` 0, `controle_doc_nd.R --bloquant` 0. Trois mineurs corrigés (`5f814ef`, `27b04ee`, `79bfa01`).
- `/code-review` (`high`) : cinq constats ; corrigés : commentaire de `.retirer_lignes_colonnes_vides()` (`a3b6872`), ancre de `sec:spec-lognormale` et asymétrie C(1)(a)/D(1) (`a9968fb`), ancres de trois labels déplacées par la branche (`0ca4e1b`), présente synthèse ; écarté : garde de date dans le code (déjà suivi par #504, S3).
- Audit léger des corrections postérieures (`f797776..0ca4e1b`) : **conforme**.

### Étape 10 : veille et PDF
- Veille du 17/11 : commentaires datés sur #463 et #504 ; aucun fait nouveau (AEAPP, Office des publications, 2015/498, R. 352-5, R. 356-19).
- PDF de fin de branche `dc326de` (`.tex` de `0ca4e1b`, pdfTeX-1.40.25, 457 pages, 0 référence indéfinie).

## Constats hors périmètre (ADR 0018)

- **Proposé au mainteneur comme issue (E5)** : `.tex` l. ~14175, fiche `multi-demarrages`, « démarrages atteignant le minimum global » ; le code compte les démarrages à `TOL_OPTIMUM` du meilleur objectif parmi les démarrages (`actuary-approfondi`, 17/11).
- **Écartés (mineurs)** : voir la PR #596, « Constats mineurs écartés (ADR 0018) ».
