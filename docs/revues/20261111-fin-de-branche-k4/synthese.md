# Revues de fin de branche K4 (11/11/2026)

> *Rédigé par la session K4 (IA). Rapports reproduits dans ce dossier ; avis amont, inventaire et validations intermédiaires dans `../20261111-avis-amont-k4/`.*

## Objet

Étapes 10 et 11 de la fiche K4 (PR #538) : validation du diff du `.tex` par `actuary` (règle 9), revue finale (règle 10) sur `git diff main...HEAD` — reprise après l'intégration de `main` qui portait K6 (C7-K6) —, `/code-review`, `app-review` léger (tests de l'application changés, `app.R` et `R/display_helpers.R` non touchés), avis d'`actuary` sur deux textes relevés en revue finale.

## Rapports

| Fichier | Agent (fiche) | Objet | Verdict |
|---|---|---|---|
| `../20261111-avis-amont-k4/actuary-validation-tex.md` | `actuary-approfondi` | diff du `.tex` (six commits `docs:`) | validé avec réserves : C1 (rubrique 1 des fiches de normalité), C2 (tableau daté de `mw:m2var`) ; appliquées (`ba7ae06`) |
| `audit-revue-finale.md` | `audit` (`high`) | `git diff main...HEAD`, premier tour (`c90e65a`) puis reprise après intégration de `main` (`7897a4a`) | conforme ; mineurs de traçabilité (corps de PR, `CONTEXT.md:136`, trace d'`app-review`, « Effet attendu ») |
| `code-review.md` | `/code-review` (effort `medium`) | même diff (`c90e65a`) | un défaut de texte restitué (origine du défaut de calcul), suites ci-dessous |
| `app-review-leger.md` | `app-review` | tests de l'application et restitution des nouveaux textes | conforme, aucun écart |
| `actuary-revue-finale-q1-q2.md` | `actuary-approfondi` | Q1 (« a T = 8 » dans T-1 et T-2), Q2 (origine du défaut de calcul) | Q1 non voulu, texte corrigé ; Q2 : `origine` à NA hors fonction du moteur, motif neutre existant |

## Suites

| Constat | Traitement |
|---|---|
| C1, C2 (`actuary`, `.tex`) | `ba7ae06` (`docwriter`) ; numéro de rubrique du script de #503 : `c90e65a` |
| Q1 (`audit`) : « puissance non mesuree a T = 8 » imprimé pour tout T et pour `reserve2` | `9e1259f` (29 `detail` repatchés, non numériques) ; `.tex` : `7897a4a` |
| Q2 (`/code-review`) : motif « du moteur » sur une fonction de R | `0aaf10d` (défaut antérieur à K4 ; aucune référence) |
| corps de la PR, trace d'`app-review`, « Effet attendu » (mineurs d'`audit`) | PR #538 mise à jour ; `50b8ebf` |
| `CONTEXT.md:136` et `:198` (ancienne phrase de #244, ancien motif du défaut de calcul, `origine` à NA) | Q-E, à `architect` au point d'étape |
| `/code-review` : « ; Verdict » après point-virgule ; « xt et yt doivent etre numeriques » ; « (i=%d) » des noms d'année ; règle unique dans `add()` ; duplication du message d'alpha ; longueur écrite dans un commentaire ; `.engine_saisie()` dans `engine_motif_b_alpha()` | écartés ou consignés : jonction « ; » acceptée par `actuary` (avis amont § 3.3, jamais observée : 0 sur 73 lignes) ; garde d'appel direct hors inventaire ; O1 (restes de la fiche) ; forme ligne à ligne voulue par la spécification (Q-47-7 (a)) ; les trois derniers sans défaut actuel |

Aucune suite ne change σ_USP, une p-value ou un verdict. Références : 75 feuilles de texte différentes de `main`, aucune valeur numérique.
