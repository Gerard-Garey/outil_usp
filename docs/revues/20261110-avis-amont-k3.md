# Avis amont d'`actuary` sur les textes de fond de K3 (10/11/2026)

> *Rédigé par la session principale (IA). Avis reproduit dans `20261110-avis-amont-k3/`.*

## Objet

Étape 1 de la fiche « Branche K3 » (PR #530) : règles et textes fixés par `actuary` (fiche de base, Opus 5.5) avant le code de #484, #469, #485, #486 et #521.

## Rapports

| Fichier | Agent (fiche, effort) | Objet | Verdict |
|---|---|---|---|
| `actuary-avis-amont.md` | `actuary` (Opus, `medium`) | #484 (contrainte de rang sur `nature_forcee`, `sens`, p hors de [0, 1], retrait de `verdict`) ; #469 (motif sous R1 sans p exacte ; Kruskal à un résidu par année en diagnostic) ; #485 (QA1) ; #486 (deux motifs) ; #521 | complet, sauf QA1 (#485) porté au mainteneur (source non lue) |
| `qa1-recherche-acces-complet.md` | session cloud « Accès complet » (Opus 5.5), lecture seule | QA1 : recherche du texte d'Anscombe et Glynn (1983) et de D'Agostino et al. (1990) | textes **non lus** (articles fermés, accès refusés) ; racine signée écartée (inversion du sens) ; recommandation (a) |

## Décisions du mainteneur (10/11/2026)

| Question | Décision |
|---|---|
| #469, point 2 : ligne Kruskal à un résidu par année | **diagnostic d'office**, nom inchangé, H0 et H1 « sans objet » (accord du mainteneur) |
| QA1 (#485) | **(a) statistique non définie** (`stat = NA`, motif propre, ligne non applicable, aucun verdict changé), après la recherche de la session « Accès complet » qui n'a pu lire ni Anscombe et Glynn (1983) ni D'Agostino et al. (1990) ; texte de l'article à noter non lu |
