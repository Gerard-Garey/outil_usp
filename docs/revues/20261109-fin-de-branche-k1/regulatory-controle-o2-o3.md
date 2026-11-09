> *Rédigé par l'agent regulatory (IA).*

# Contrôle ciblé O2 / O3 : `doc_tests_usp.tex` après `7db51f1` et `85ca922` (branche `claude/entrees-et-validation`, tête `85ca922`)

Contrôle en lecture seule.

**Sources lues en rendu graphique, sans extraction de texte pour les formules :**
- JOUE L 12 du 17.1.2015, `Règlement délégué.pdf`, pages L 12/276 à L 12/278 : D(1) et D(2)(a)-(h) en p. L 12/276 ; D(3), D(4) et D(5), formule MSEP et S_j, en p. L 12/277 ; S′_j, Q̂_j et σ̂²_j de D(5)(c)-(d) en p. L 12/278.
- Version consolidée du 14.11.2024 (xhtml) : texte de D(1) à D(3) et images des formules de D(4)(c) et D(5). Le texte de D(1) à D(3) est identique à celui de 2015. La MSEP consolidée diffère de celle de 2015 (ADR 0005), mais les deux ne font intervenir que les mêmes cellules.

## Point 1 (O2) : colonne vide intercalée, `7db51f1`

**Texte :** D(1) : montants « indiqués séparément pour chaque année d'accident et chaque année de développement des paiements » ; D(2)(c) : « pour la première année d'accident, des données sont disponibles pour cinq années de développement consécutives au moins » ; D(3)(c) : « J représente l'année de développement la plus récente de la première année d'accident pour laquelle des données sont disponibles ».

**Analyse :** chacun des trois membres de la parenthèse correspond à la disposition qu'il cite. Le texte ne prescrit pas explicitement de numéroter les années de développement de façon consécutive (D(3)(a) ne le fait que pour les années d'accident) ; la consécutivité découle de D(2)(c) et de D(2)(e), et elle est sous-entendue par f̂_j de D(4)(c). Dire qu'une colonne vide est une année manquante reste une présomption, que la doc présente bien comme « une lecture retenue par l'outil ».

**Verdict : conforme.** Précision facultative : ajouter D(2)(e).

## Point 2 (O3) : cellules sous la diagonale, `85ca922`

**Texte (identique sur ce point en 2015 et dans la version consolidée) :** D(4)(c) : Ĉ(i,j) = C(i,I−i) · f̂_{I−i} ⋯ f̂_{j−1} ; f̂_j = Σ_{i=0}^{I−j−1} C(i,j+1) / Σ_{i=0}^{I−j−1} C(i,j). D(5) : S_j = Σ_{i=0}^{I−j−1} C(i,j) ; S′_j = Σ_{i=0}^{I−j} C(i,j) ; σ̂²_j sur i ≤ I − j − 1 ; la MSEP lit C(i,I−i) et C(I−j,j), cellules de la diagonale.

**Analyse :** aucune formule de D(4) ni de D(5) ne lit une cellule i + j > I. La parenthèse « sommes sur i ≤ I − j − 1 ou i ≤ I − j » couvre les deux types de sommes. docwriter avait raison d'écarter la formulation de la revue finale (« qui ne somment que sur i ≤ I − j − 1 »), inexacte pour S′_j ; elle est retirée. « seul l'avertissement est une convention de l'outil » est juste.

**Verdict : conforme.** Précision facultative : citer « D(4) et D(5) » au lieu de « D(4)(c) et D(5) » (le dénominateur de σ_USP, au paragraphe D(4), ne lit lui aussi que la diagonale).

## Conclusion

Les deux textes sont conformes à l'annexe XVII, section D, dans la version de 2015 comme dans la version consolidée. Aucun écart, aucune issue proposée. Les deux précisions sont facultatives.
