# Écarts de facteurs d'une colonne quasi dégénérée : précision en double (#615, 25/11/2026)

Mesure faite pour l'audit léger de `b50a5e0` (retour à la règle d'avant #615), citée dans le commentaire d'en-tête de `mw_residus()` (`R/engine.R`).

**Montage** : `tri615()` modifie la colonne `jstar + 1` de `tests/donnees/triangle_mw.csv` pour que les facteurs de la colonne `jstar` valent f̂ (1 + ρ u), u équiréparti sur [−1, 1] ; colonnes 2 (cinq facteurs) et 5 (deux facteurs), ρ = 5e-13, 1e-12 et 1e-11. `.mw_ecart_facteur_stable()` calcule les écarts F − f̂ en double ; `exact_colonnes.py` les compare à leur valeur exacte en rationnels (Python `fractions`, sur les doubles exacts lus en `%a`).

**Commandes** (depuis la racine du dépôt) :

```
LC_ALL=C.UTF-8 Rscript docs/revues/20261123-a2-creneau/mesure-ecarts-615/ecart_colonnes.R | grep '|' > ecarts_hex.txt
python3 -I docs/revues/20261123-a2-creneau/mesure-ecarts-615/exact_colonnes.py ecarts_hex.txt
```

**Résultat** (`sortie.txt`) : les rangs sont exacts partout. L'erreur relative atteint 2,0e-3 élément par élément, sur le facteur central de la colonne 2 à ρ = 5e-13, dont l'écart vaut à peine 2,45e-14 en relatif à f. Rapportée au plus grand écart de la colonne, elle reste sous 1e-4 (9,8e-5 au plus). À ρ = 1e-11, elle est au plus de 3,5e-5 élément par élément. *Comportement observé* sur ce montage, non une borne générale.
