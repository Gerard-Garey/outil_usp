# Contrôle de conformité aval de `regulatory` sur #540 (étape 5 de K2b)

> Versé par la session principale (Q-54-10). Fiche de base, effort `medium`. 13/11/2026. Diff non commité de `R/engine.R` (l. 10085-10098 et 10164-10176).

## Textes vérifiés
Version consolidée du 14.11.2024 (passages sans formule, extraction suffisante) : annexe XVII, D(2)(e) ; art. 19(1)(b) ; art. 219(1)(a). Libellé identique à la lecture du 13/11. JOUE : art. 19(1)(b) L 12/31, art. 219(1) L 12/143, art. 220(2) L 12/144. D(4) et D(5) repris de la matrice du 12/11, vérifiée à l'image (non relus à l'image ici).

## Mesures (`LC_ALL=C.UTF-8`, `charger_moteur()` puis `mw_valider_triangle()`)
- 8 × 6 : `ok = FALSE`, un seul motif, MW-04, `identical()` au bloc de l'ADR 0005 (bis) et à la décision 2 après `sprintf(…, 8L, 6L)`.
- 6 × 8 : `ok = FALSE`, un seul motif, MW-03 (« D(2)(e) : … »), sans « Triangle non carre ».
- 8 × 8 : `ok = TRUE`, aucun motif.

## Matrice
| Point | Texte du règlement | Code | Verdict |
|---|---|---|---|
| 1a. Condition d'émission de MW-04 | D(2)(e) : nombre d'années d'accident « n'est pas inférieur » au nombre d'années de développement ; I > J admis | `if (I > J)` remplace `I != J` | Conforme (R-1) |
| 1b. « admis par l'annexe XVII, section D, point (2)(e) » | D(2)(e) | texte du motif | Conforme |
| 1c. « ne se calculant a la lettre que pour un triangle carre » | D(4), D(4)(c), D(5) : pour I > J, C(i, I−i) indéfini pour i < I−J, Q̂_{I−i} pour 1 ≤ i ≤ I−J (D(5)(d) jusqu'à j = J−1) | texte du motif | Conforme ; « à la lettre » ne prête au texte aucune condition I = J |
| 1d. « exclusion a justifier (art. 219(1)(a) et 19(1)(b)) » | art. 219(1)(a) : l'art. 19 s'applique ; art. 19(1)(b) : aucune donnée pertinente exclue sans justification | texte du motif | Conforme ; formule inexacte « méthode n° 1 reste ouverte » absente |
| 1e. Arguments `%d` | — | `nrow(tri)`, `ncol(tri)` : I+1 et J+1 | Conforme |
| 1f. Fidélité à la décision 2 | — | égalité au caractère près | Conforme |
| 2a. En-tête : termes indéfinis | comme 1c | « C(i, I-i) … definie que si I - i <= J » ; « Q_(I-i) … que si I - i <= J - 1 » | Conforme |
| 2b. En-tête : qualification | ADR 0005 (bis), points 1 à 3 | « a la lettre que si I = J » ; domaine « plus etroit » ; choix (A), non exigence du texte ; exclusion à justifier ; I < J au motif D(2)(e) | Conforme |
| 2c. En-tête : omissions | (bis), répartition : points 4 et 5 à l'ADR et au `.tex` | points 4 et 5 absents | Conforme (le commentaire n'est pas l'un des trois supports) |
| 2d. En-tête : première phrase | — | « on impose I = J » ; « 2(e) autorise I >= J » | Conforme |
| 3. I < J : MW-03 seul | D(2)(e) | mesure 6 × 8 ; tests 5 × 6 et 8 × 9 (`run_engine`) | Conforme |
| 4. Corrections (vi) de la lecture du 13/11 | — | reprises par l'ADR 0005 (bis), « Corrections mineures » | Tenues |

Remarque sans écart : dans l'annotation du 13/11 de l'ADR 0005, seule la puce 3 renvoie à (bis) ; « entièrement développées en J » et la parenthèse de « Suite » n'ont pas de renvoi en ligne. Un renvoi par `architect` est facultatif.

## Statut global
**Conforme, aucun écart.** Aucun σ_USP, p-value ni verdict concerné. Reste, côté `.tex` (l. 4781, 5041, 14677) : `docwriter` (règle 9).
