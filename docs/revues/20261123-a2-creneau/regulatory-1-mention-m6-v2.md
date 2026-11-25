# Relecture `regulatory` : mention M6 du cas « simulation » et ADR 0005 (annotation du 25/11)

*Rédigé par l'agent `regulatory` (IA), le 25/11/2026, en routine (créneau A2, étape 6), sur le diff non commité de la variante V2 de #612 (`claude/creneau-a2`, tête `e4ecb16`, `R/engine.R` md5 `405fd0e6…`). Versé intégralement par la session principale (Q-54-10).*

**Verdict : conforme sur les trois points ; reformulation proposée sur le point 2** (rédaction, sans effet sur σ_USP ni sur un verdict). Rien n'a été écrit dans le dépôt.

**Lecture.** Version consolidée au 14.11.2024 (`.xhtml` à la racine), annexe XVII, section D « Méthode du risque de réserve n° 2 », paragraphes (3) à (5). Formules lues en rendu graphique, images décodées du `.xhtml` et regardées une à une, sans extraction de texte (#7). Version JOUE L 12 de 2015 non relue (la version consolidée est la référence de lecture).

## Matrice

**Point 1. Le renvoi « annexe XVII, D(5)(d)(ii), seconde ligne » désigne-t-il la règle de minimum appliquée à σ²_{J−1} ? Conforme.**
- **Texte.** D(5)(d) définit Q̂_j = σ̂²_j / f̂²_j, « où : i. f̂_j […] ; ii. σ̂²_j représente le montant suivant ». Le point ii a deux lignes :
  - première ligne : σ̂²_j = 1/(I−j−1) · Σ_{i=0}^{I−j−1} C(i,j) · (C(i,j+1)/C(i,j) − f̂_j)², pour « j = 0,…,(J−2) » ;
  - seconde ligne : σ̂²_j = min(σ̂²_{J−2}, σ̂²_{J−3}, σ̂⁴_{J−2}/σ̂²_{J−3}), pour « j = (J−1) ».
- **Moteur.** `mw_ajuster()` et `mw_extrapolation_sigma2()` dans `R/engine.R`.
- **Lecture.** Le renvoi est exact. La seconde ligne vise « j = (J−1) » sans condition sur I. Dire que la règle s'applique « par prescription », « bien que la colonne J−1 porte %d facteurs », est fidèle au texte : sur un trapèze, la première ligne serait calculable en j = J−1, mais le texte ne la prévoit pas pour cet indice. C'est la lecture déjà actée au point 4 de l'ADR 0005.

**Point 2. Dire que la règle « fixe la MSEP, sigma(res,s,USP) ». Conforme sur le fond, rédaction à préciser.**
- **Texte.**
  - D(5) : la MSEP fait intervenir Q̂_{I−i} et Q̂_j pour j de I−i+1 à J−1. Q̂_{J−1} y entre donc, et par lui σ̂²_{J−1} (D(5)(d)).
  - D(4) : σ_(res,s,USP) = c · √MSEP / Σ_{i=0}^{I} (Ĉ(i,J) − C(i,I−i)) + (1−c) · σ_(res,s). Le point (4)(b) renvoie la MSEP au paragraphe 5.
- **Lecture.** La chaîne règle → Q̂_{J−1} → MSEP → σ_USP est exacte. Mais « fixe » est trop fort : la règle fixe une entrée de la MSEP (Q̂_{J−1}), qui dépend aussi des autres σ̂²_j, de f̂, de Ĉ, de S et de S′ ; σ_USP dépend en plus de c (section G) et de σ_(res,s).
- **Correction proposée** : remplacer « elle fixe la MSEP, sigma(res,s,USP) et l'estimation de cette ligne » par « elle entre, par Q_(J-1) (D(5)(d)), dans la MSEP de D(5) et, par elle, dans sigma(res,s,USP) de D(4), et fixe l'estimation de cette ligne ».
- **À noter.** La suite de la phrase (« appliquee a chaque triangle reajuste, le sigma de chaque replication du bootstrap ») décrit ce que fait l'outil, non une prescription ; elle reste juste (même règle appliquée par `mw_msep()` au triangle réajusté). La reformulation évite qu'on la lise comme couverte par la prescription.
- **Légende `MW_USAGE_SIGMA_SIMULATION`** : « σ_(J−1) de la règle de minimum (D(5)(d)(ii)) : MSEP, sigma_USP et sigma des réplications » est exacte (« : » y marque un usage, pas une détermination). Conforme.

**Point 3. « Par convention de l'outil, non réglementaire » : la simulation par l'estimateur direct. Conforme.**
- **Texte.** Ni la section D (paragraphes 1 à 5), ni l'annexe XVII, ni les articles 218 à 220 ne prescrivent de simulation, de bootstrap ni de test. « bootstrap » et « simulation » : aucune occurrence dans le `.xhtml` consolidé. La section D ne prescrit que les données et leurs exigences ((1), (2)(a) à (h)), la notation (3), σ_USP (4) et la MSEP (5). Les hypothèses de D(2)(h) i à iv sont des exigences sur les données, pas une procédure de test.
- **Lecture.** La loi de simulation du bootstrap ne relève d'aucune prescription : la qualification est exacte. L'estimateur direct est la première ligne de D(5)(d)(ii) appliquée à j = J−1, hors de son domaine prescrit (j de 0 à J−2) : quantité construite à partir du texte, non réglementaire.
- **ADR 0005**, annotation du 25/11/2026, Décision, point 1 : même qualification, conforme. « Ce qui ne change pas » (règle de minimum pour j = J−1 dans la MSEP et σ_USP) : conforme.
- **Commentaires du moteur** (bloc de `.mw_simulation_sigma_direct()`) : conformes.

**Hors des trois points.** Le gabarit `FORMAT_MENTION_MW_SIGMA_DIRECT_DEGENERE` porte le même renvoi (D(5)(d)(ii), seconde ligne, par prescription) : conforme.

## Suites

- Aucun écart sur le fond, pas d'issue proposée.
- La correction du point 2 est dans le périmètre de la branche ; si elle était classée comme constat : mineur (rédaction, sans effet sur σ_USP, un verdict, une p-value ni la conformité).

## Synthèse de la session

Le texte final du gabarit, appliqué à la reprise de `coder-approfondi`, combine la proposition d'`actuary` (`actuary-6-textes-v2.md`) et la précision de renvoi du point 2 ci-dessus.
