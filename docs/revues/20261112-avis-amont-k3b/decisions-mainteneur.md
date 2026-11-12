# Décisions du mainteneur sur l'avis amont de K3b (12/11/2026)

> *Rédigé par la session principale (IA).* Réponses du mainteneur, par questionnaire à la session principale, aux décisions 1 à 4 de `actuary-avis-amont.md`.

1. **#555, portée : règle unique retenue** (recommandation d'`actuary`). Si la colonne `i` est présente, elle porte, ligne après ligne, des entiers croissants de pas 1, sans vide ; départ libre (0, 1, année civile, valeur négative comprise). Motifs H1, V1 à V5 du tableau de l'avis ; le motif V5 (« non consecutive », qui cite l'annexe XVII, D(2)(b)) reste sous réserve de la lecture de D(2)(b) par `regulatory` (`medium`).
2. **#555, nom de colonne `NA` : traité comme un en-tête absent**, sans refus (recommandation d'`actuary`), comme `""` et comme le fait déjà `.entete_absent()`. Écart assumé à la lettre « refus motivé » de l'issue ; le critère « jamais d'erreur R brute » est tenu.
3. **#555, en-têtes `I` (majuscule) ou ` i ` (avec blancs) : traités dans #555**, contre la recommandation d'`actuary` (hors périmètre, issue). Le traitement et le texte sont à fixer avant l'étape 8 (`actuary`).
4. **#534, b2 non calculable sur des résidus finis et non constants : assertion `stop()`** (recommandation d'`actuary`) ; résidus non finis : `stop()` ; résidus exactement constants (`all(z == z[1])`) : motif actuel inchangé. Interface de `test_anscombe_kurt()` inchangée.

Pour information, sans décision du mainteneur (validation d'`actuary` suffisante, aucun σ_USP ni verdict touché) : #537, plus courte écriture qui se relit à l'identique (15 à 17 chiffres, point décimal) ; #532, option (ii), branche 2b retirée et assertion `stop()`. Critère Q-A2 corrigé : `tests/unitaires/test_non_applicable.R` (dont l. 158-171) vert à chaque commit d'`add()`.
