# Lecture amont de #573 par `regulatory` (fiche de base, `medium`), 14/11/2026

Base : `main` `f8ff168`. Avis seul.

## 1. Texte et portée
- Art. 220(1)(b) (version consolidée du 14.11.2024) : méthode du risque de réserve n° 1 ou n° 2 pour les paramètres de l'art. 218(1)(a)(iv) et (c)(iv).
- Art. 220(2) : choix de la méthode la plus précise lorsque l'entreprise est en mesure d'en utiliser plusieurs ; à défaut de démonstration, la plus prudente.
- Affirmable : le paramètre relève de 220(1)(b) ; ce point prévoit deux méthodes ; la n° 2 a ses exigences propres (annexe XVII, D(2), rendues obligatoires par l'art. 219(1)(d)) ; le choix relève de 220(2).
- Non affirmable : que la n° 2 « reste ouverte » (repli acquis, indépendant de D(2) et de R > 0 en D(4)).
- Verdict sur la chaîne actuelle : écart de qualification ; aucun effet sur σ_USP ni sur les verdicts.

## 2. Recommandation : suppression pure
1. `phrase_art220` cite déjà l'art. 220(1)(b), qui nomme la n° 2.
2. Une réécriture citant 220(2) au moment du refus pourrait se lire comme une invocation, en tension avec le `.tex` (l. ~4445-4450 : l'art. 220(2) « n'est pas invoqué »).
3. m2 : un motif de refus énonce cause et fondement, pas le régime de l'autre méthode.
4. Moindre surface.

Effets : `phrase_res2` et son usage disparaissent des deux formes du motif d'`usp_valider_ajustement()` (l. ~2021, ~2034) ; commentaire l. ~1958-1960 à aligner ; `tests/unitaires/test_controles_entree.R` l. ~868, ~873, ~4792 à aligner.

## 3. Libellé
Avant (forme 1, `reserve1`, borne basse) : « … ni l'adequation de l'estimation de la vraisemblance maximum (C(2)(e), iii et iv ; article 219, paragraphe 1, point d)). La methode du risque de reserve no 2 reste ouverte (meme point). Verifier que y_t est observe (C(1)(a)) et non deduit de x_t par un coefficient fixe. »

Après : « … article 219, paragraphe 1, point d)). Verifier que y_t est observe (C(1)(a)) et non deduit de x_t par un coefficient fixe. » ; de même pour la borne haute et la forme 2.

Variante de réécriture (si le mainteneur la préfère, à soumettre à `actuary`) :
`La methode du risque de reserve no 2, prevue au meme point, a ses propres exigences de donnees (annexe XVII, D(2)) ; le choix entre les deux methodes, quand l'entreprise est en mesure d'utiliser l'une et l'autre, releve de l'article 220, paragraphe 2.`

## 4. Autres occurrences
- `R/engine.R`, chaînes : aucune ; motifs de `mw_valider_ajustement()` conformes.
- Commentaire `R/engine.R` l. ~1958-1960 à aligner.
- `.tex` l. ~4444 (« ce point ouvrant aussi la méthode n° 2 ») : à examiner par `docwriter` avec la puce de `sec:mw` ; « prévoyant aussi » serait cohérent avec l'encadré I > J.
