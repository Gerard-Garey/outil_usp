# Avis amont d'`actuary` sur les textes de fond de K3 (10/11/2026)

> *Rédigé par la session principale (IA). Avis reproduit dans `20261110-avis-amont-k3/`.*

## Objet

Étape 1 de la fiche « Branche K3 » (PR #530) : règles et textes fixés par `actuary` (fiche de base, Opus 5.5) avant le code de #484, #469, #485, #486 et #521.

## Rapports

| Fichier | Agent (fiche, effort) | Objet | Verdict |
|---|---|---|---|
| `actuary-avis-amont.md` | `actuary` (Opus, `medium`) | #484 (contrainte de rang sur `nature_forcee`, `sens`, p hors de [0, 1], retrait de `verdict`) ; #469 (motif sous R1 sans p exacte ; Kruskal à un résidu par année en diagnostic) ; #485 (QA1) ; #486 (deux motifs) ; #521 | complet, sauf QA1 (#485) porté au mainteneur (source non lue) |

## Décisions du mainteneur (10/11/2026)

| Question | Décision |
|---|---|
| #469, point 2 : ligne Kruskal à un résidu par année | **diagnostic d'office**, nom inchangé, H0 et H1 « sans objet » (accord du mainteneur) |
| QA1 (#485) | **en attente** : session « Accès complet » lancée sur instruction du mainteneur pour lire Anscombe et Glynn (1983) et trancher sur le texte |
