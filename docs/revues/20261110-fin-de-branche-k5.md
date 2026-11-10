# Revues de fond de fin de branche K5 (10/11/2026)

> *Rédigé par la session principale (IA). Rapports reproduits intégralement dans `20261110-fin-de-branche-k5/`.*

## Objet

Étapes 10 et 11 de la fiche K5 (PR #516) : validation de fond par `actuary` (règle 9), contrôle réglementaire de l'énoncé de H3 par `regulatory` (grille de `docs/latex/CONVENTIONS.md`, type 11), puis visa d'`actuary` sur les corrections. Les rapports de vérification (`audit`, `app-review`, `architect-approfondi`, `/code-review`) sont résumés dans la PR #516.

## Rapports

| Fichier | Agent (fiche) | Objet | Verdict |
|---|---|---|---|
| `actuary-validation-fin-de-branche.md` | `actuary` (base) | diff du `.tex` de la branche (`f6b4ac6`, `9459573`, `c6ee5b5`, `75c9c01`), textes de fond de #509, #498, #499, #524 | validé avec réserves : R1, R2 (majeures), R3, R4 (mineures) |
| `regulatory-enonce-h3.md` | `regulatory` | encadré d'énoncé de H3 et texte voisin (`75c9c01`) contre l'annexe XVII, B et C | conforme ; lecture « par année, sachant le volume » imposée par la cohérence du texte ; M1 à M3 mineurs |
| `actuary-visa-dda1215-b9775e0.md` | `actuary` (base) | corrections `dda1215` (#524) et `b9775e0` (#518) | visa ; RM-1 et RM-2 mineures |

## Suites

| Réserve | Traitement |
|---|---|
| R1, R2, R3 (`actuary`) ; M1, M2, M3 (`regulatory`) | `dda1215` (`docwriter`) |
| R4 (`actuary`), M2 (`audit`) | `CONTEXT.md`, `4baa3bc` |
| mesure périmée de `sec:controles` (M1 d'`audit`) | `b9775e0` |
| RM-1 (phrase des fichiers binaires) | `docwriter`, passage final |
| RM-2 (commentaires de `usp_noyau()`) | commit `moteur:` (Refs #524) |

Aucune réserve ne change σ_USP, une p-value ou un verdict.
