# Revue finale de la branche K6 « Tests et outillage » (11/11/2026) : synthèse

> *Rédigé par la session de K6 (IA). Rapports reproduits dans ce dossier.*

## Objet

Étape 6 de la fiche « Branche K6 (parallèle) » : revue finale (règle 10 de `CLAUDE.md`) sur `git diff main...HEAD`, base `12872c3` (`main`, non avancé depuis l'ouverture), tête `ccb5771`. Puis audit des corrections postérieures. PR #539.

## Rapports

| Fichier | Agent (fiche, modèle) | Objet | Verdict |
|---|---|---|---|
| `audit-revue-finale.md` | `audit` (effort high) | diff complet des cinq commits | conforme avec réserves ; M1 (README), M2 (assertion #323 sans mordant sous Linux) |
| `app-review-revue-finale.md` | `app-review` (`model: "opus"`) | `fmt_p()`, exigences § 5 | conforme ; trois remarques |
| `code-review.md` | `/code-review` (effort medium) | diff complet | huit constats (voir « Suites ») |
| `actuary-libelle-502.md` | `actuary` (fiche de base) | constat 2 du `/code-review` sur le libellé de #502 | (b) : libellé à corriger, textes fixés |
| `audit-correctifs.md` | `audit` | diff des corrections `76490b1`, `ba93491`, `f6b33f5` | conforme ; quatre remarques |

Le `/code-review` a été lancé alors que la référence locale `main` de la session était périmée (`d783fe4`). Son diff couvrait donc aussi la PR #531, déjà fusionnée. Ses huit constats portent tous sur les fichiers de K6. `audit` et `app-review` ont pris `12872c3` pour base.

## Suites

| Constat | Traitement |
|---|---|
| `/code-review` 2, audit Q1 (libellé de #502 : « erreur contrôlée par le recoupement ») | avis d'`actuary`, `ba93491` |
| audit M2 (assertion #323 sans mordant sous Linux) | `f6b33f5` (`%g` de Windows émulé) |
| `/code-review` 4 et 5 (annotation absente du refus, appel (a) dupliqué) | `76490b1` |
| audit M1, `/code-review` 1, app-review R3 (README, § des échecs Windows) | hors périmètre C3-K6 : signalé dans la PR, décision au mainteneur après l'étape 7 |
| `/code-review` 3 (`CONVENTIONS.md` dans un commit `tests:`) | sans reprise : aucune réécriture de commit (Q-43-13) ; noté dans la PR |
| `/code-review` 6 (budget imprimé deux fois sur une ligne d'exception) | sans reprise : sortie déjà identique à `12872c3`, critère de #475 |
| `/code-review` 7 (`sub()` hors `.num_fr()`, `ifelse` final) | sans reprise : `.num_fr()` ne prend qu'un format `sprintf` ; l'`ifelse` garde noms et dimensions |
| `/code-review` 8 (restauration de `LC_ALL` triviale sous Windows) | sans reprise : `nd_avec_env()` est testée directement ; à l'étape 7 |
| audit-correctifs R2 (statut ancien dans `docs/tableaux/20261031-issue164-dw-rho-negatif.md`) | hors périmètre (aucun tableau daté réécrit) : signalé dans la PR |

Aucun constat ne change σ_USP, une p-value, un verdict ou une référence.
