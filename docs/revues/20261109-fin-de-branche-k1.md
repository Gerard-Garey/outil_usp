# Fin de branche K1 « Entrées et validation » : validation du `.tex` et revue finale de la règle 10 (09/11/2026)

> *Rédigé par la session principale (IA). Rapports des agents reproduits dans `20261109-fin-de-branche-k1/`.*

## Objet

Étapes 7 à 9 de la fiche K1 (PR #511) : passage unique de `docwriter` (`c80e641` à `39111c0`, `\versiondoc` 3.1), validation du diff du `.tex` par `actuary-approfondi`, revue finale complète de la règle 10 sur `git diff main...39111c0`, puis reprise des constats et revue de la reprise.

## Rapports

| Fichier | Agent (fiche, effort) | Objet | Verdict |
|---|---|---|---|
| `actuary-validation-tex.md` | `actuary-approfondi` (Opus, `high`) | diff du `.tex` de la branche | conforme avec réserves (C1, C2 majeurs ; C3 à C8 mineurs) |
| `audit-revue-finale.md` | `audit` (Opus, `high`) | `git diff main...39111c0` entier, batteries, scénarios adverses | conforme avec réserves (cinq mineurs) |
| `regulatory-revue-finale.md` | `regulatory` (Opus, `medium`) | B(2)(b), C(2)(b), D(2), #514 | conforme (un écart documentaire mineur, 5.3) |
| `app-review-revue-finale.md` | `app-review` (`model: "opus"`) | `app.R`, `R/display_helpers.R`, effets du moteur | conforme avec réserves (R1 majeur, défaut antérieur ; C1, C2 mineurs) |
| `code-review.md` | `/code-review` (high) + vérification de la session | diff `main...39111c0` | sept constats, dont trois repris dans K1 |
| `actuary-validation-reprise.md` | `actuary` (Opus, `medium`) | diff `2f35c76..85ca922` | conforme avec réserves mineures (R1, R2), non bloquantes |
| `regulatory-controle-o2-o3.md` | `regulatory` (Opus, `medium`) | fondements D(1)-D(3) et D(4)-D(5) ajoutés au `.tex` | conforme |

Audit léger de la reprise (code, références, CI) : conforme, un constat documentaire (citation ESD), corrigé par `01eee39`.

## Décisions du mainteneur (09/11/2026)

| Question | Décision |
|---|---|
| C2 (ligne G3, Andrews 2000, Q-D2-Fn-5 bis) | variante qui **garde** Andrews avec sa portée : « non convergent pour une moyenne contrainte […] sans transposition demontree a delta ni effet etabli sur sigma » |
| C1 à C5 (textes de `detail`) | corrigés **dans K1** |
| Taille de `CLAUDE.md` | revue d'architecture dans la branche qui suit K1, avant K2 : issue #515 |

Décision par défaut de la session : une cellule non numérique sous la diagonale d'un fichier reste refusée (constat 4 d'audit) ; le `.tex` le dit (`85ca922`).

## Reprise

| Commit | Contenu |
|---|---|
| `b9b55de` | `moteur:` C1 à C5 ; une seule `mc_dispo` ; `MENTION_PERMUTATIONS_ALEATOIRES` construite depuis `T_MAX_ENUM_PERMUTATION` ; références patchées sur les seuls `detail` (3 par cas lognormal, 2 pour `reserve2`) ; reproductibilité CONFORME, écart maximal 0 |
| `324d315` | `tests:` 17 avertissements `requireNamespace` supprimés ; commentaire « seuil 400 » |
| `c117451` | `repo:` agrégat « Tests du moteur » en échec si le job `changements` n'a pas réussi |
| `2f35c76` | `docs:` citations de `CONTEXT.md` mises au texte du moteur (`architect`) |
| `01eee39`, `7db51f1`, `85ca922` | `docs:` C3, C6, C7, C8, tableau des convergences, parenthèse de `sec:controles`, fondements D(1)-D(3) et D(4)-D(5), cellules sous la diagonale |

Aucun σ_USP, aucune p-value, aucun verdict changé sur la branche : `identical()` contre `main` sur les six cas, `detail` mis à part (`audit`) ; σ_USP du cas de l'audit 0,04977646 inchangé (`regulatory`).

## Restes, issues proposées non créées (création sur accord du mainteneur)

1. `detail` : ESD lognormal « en simulation sous i.i.d. normal » (R1) ; parenthèse « (n >= 25) » et alpha en `%.2f` de `PHRASE_MW_ROSNER_DIAGNOSTIC` ; typographie de `PHRASE_VERDICT_SENSIBLE_MC` (R2) — `actuary`, `audit`.
2. Cramér–von Mises « tres correlee a celle d'Anderson-Darling » sans mesure — `actuary`.
3. Repli des commentaires de la vue Détail à 400 caractères : coupe en milieu de phrase, phrases propres masquées — `app-review` C1 à C3.
4. Avertissements d'`engine_lire_triangle()` (dont #491) jamais affichés dans l'application ; séries et triangles lus sans `row.names = NULL` — `app-review` R1, C4 (complète deux issues déjà proposées au handoff).
5. Triangle sans colonne `i` à colonne de développement 0 vide, lu comme (I−1) × (I−1) sans message — `/code-review` 2.
6. `mention_r7()` recalcule les volumes constants au lieu de lire `usp_regime()` — `/code-review` 4.
