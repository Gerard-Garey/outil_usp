# Avis amont d'`actuary` sur les textes de fond de K5 (10/11/2026)

> *Rédigé par la session principale (IA). Avis reproduit dans `20261110-avis-amont-k5/`.*

## Objet

Étapes 2 à 4 de la fiche K5 (PR #516) : textes de fond fixés par `actuary` (fiche de base, Opus 5.5) avant le code de #509, #498 et #499, et complément sur le périmètre de la règle des verdicts.

## Rapports

| Fichier | Agent (fiche, effort) | Objet | Verdict |
|---|---|---|---|
| `actuary-avis-amont.md` | `actuary` (Opus, `medium`) | #509 (`ref` de F. et M4), #498 (quatre phrases de la règle des verdicts), #499 (phrase de non-rejet des deux repères de profondeur) ; complément du 10/11 sur la phrase 4 | textes fixés ; règle placée au seul tableau des tests |

Les rapports d'origine (session du poste local) n'ont pas survécu au conteneur ; les textes fixés sont repris mot pour mot du handoff `6752459057` de la PR #516.

## Décisions du mainteneur (10/11/2026)

| Question | Décision |
|---|---|
| #499 : phrase de non-rejet | ajoutée aux **deux** repères (lognormal T < 10, Merz-Wüthrich I + 1 < 10) |
| #498 : colonne Sens | ajoutée à la vue Synthèse (champ existant) |

## Mise en œuvre

| Commit | Contenu |
|---|---|
| `c5f54a1` | #509 |
| `4f11194`, `26878fb` | #498 (`moteur:` puis `app:`) |
| `1b2f412` | #499 (code et patch non numérique des six références) |
