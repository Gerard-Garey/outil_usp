# Décisions du mainteneur sur l'avis amont de K3b (12/11/2026)

> *Rédigé par la session principale (IA).* Réponses du mainteneur, par questionnaire à la session principale, aux décisions 1 à 4 de `actuary-avis-amont.md`.

1. **#555, portée : règle unique retenue** (recommandation d'`actuary`). Si la colonne `i` est présente, elle porte, ligne après ligne, des entiers croissants de pas 1, sans vide ; départ libre (0, 1, année civile, valeur négative comprise). Motifs H1, V1 à V5 du tableau de l'avis ; le motif V5 (« non consecutive », qui cite l'annexe XVII, D(2)(b)) reste sous réserve de la lecture de D(2)(b) par `regulatory` (`medium`).
2. **#555, nom de colonne `NA` : traité comme un en-tête absent**, sans refus (recommandation d'`actuary`), comme `""` et comme le fait déjà `.entete_absent()`. Écart assumé à la lettre « refus motivé » de l'issue ; le critère « jamais d'erreur R brute » est tenu.
3. **#555, en-têtes `I` (majuscule) ou ` i ` (avec blancs) : traités dans #555**, contre la recommandation d'`actuary` (hors périmètre, issue). Le traitement et le texte sont à fixer avant l'étape 8 (`actuary`).
4. **#534, b2 non calculable sur des résidus finis et non constants : assertion `stop()`** (recommandation d'`actuary`) ; résidus non finis : `stop()` ; résidus exactement constants (`all(z == z[1])`) : motif actuel inchangé. Interface de `test_anscombe_kurt()` inchangée.

Pour information, sans décision du mainteneur (validation d'`actuary` suffisante, aucun σ_USP ni verdict touché) : #537, plus courte écriture qui se relit à l'identique (15 à 17 chiffres, point décimal) ; #532, option (ii), branche 2b retirée et assertion `stop()`. Critère Q-A2 corrigé : `tests/unitaires/test_non_applicable.R` (dont l. 158-171) vert à chaque commit d'`add()`.

## Décisions complémentaires du 12/11/2026, après la lecture de `regulatory` (`regulatory-lecture-d2b-v5.md`)

5. **Motif V5 : ancré sur D(1) et D(3)(a)-(b)** (recommandation de `regulatory`) : `Colonne i non consecutive (entre les lignes de donnees %s) : annee d'accident manquante presumee ; le triangle de l'annexe XVII, section D, porte les montants de chaque annee d'accident, numerotees par des nombres consecutifs de 0 a I (D(1), D(3)(a) et (b)). Renseigner l'annee d'accident manquante, ou corriger la colonne i.` D(2)(b) n'y est pas cité.
6. **Motifs existants qui citent « (2)(b) … exige des annees consecutives »** (lignes vides du triangle et des séries, colonne `t`, commentaires, `.tex` l. 3879) : **corrigés dans K3b, avec #555**, au lieu d'une issue séparée. Textes à fixer par `actuary` avant l'étape 8, sur la lecture de `regulatory` (structure de la méthode, B/C/D(3)(a)-(b) et D(1) ; présomption qualifiée de lecture de l'outil) ; `regulatory` contrôle la conformité des textes en aval. Le motif « D(2)(b) : au moins %d annees d'accident consecutives (%d fournies) », fidèle, ne change pas.

## Décisions complémentaires du 12/11/2026, après l'avis d'`actuary` sur les textes restants (`actuary-textes-555.md`)

7. **En-têtes `I` et ` i ` : traitement (a), reconnaissance** (recommandation d'`actuary`) : un en-tête désigne la colonne `i` si, après retrait du BOM et des blancs de bord (`[[:space:]]`), il vaut `i` ou `I` ; la colonne est renommée `"i"`, puis soumise à V1-V5 ; plusieurs en-têtes de ce type : refus H1 (texte révisé de l'avis). Un fichier jusqu'ici refusé (`I`, ou ` i ` en CSV) sera calculé ; aucun fichier accepté aujourd'hui ne change.
8. **Colonne `t` des séries : K3b étendue**, contre la recommandation d'`actuary` (issue candidate pour K2b) : la même règle de reconnaissance s'applique à l'en-tête `t` (`t` ou `T`, blancs de bord ignorés), sur les deux chemins ; textes fixés par `actuary` avant l'étape 8.
9. **Doublons d'en-tête `xt` ou `yt` des séries : refus inclus dans K3b** (recommandation d'`actuary`, `actuary-textes-555-colonne-t.md`), comparaison exacte, texte « En-tete %s present plusieurs fois (colonnes %s) : la colonne %s ne peut figurer qu'une fois ; retirer ou renommer la colonne en trop. ».
