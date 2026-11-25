# Avis d'`actuary` : textes de la variante V2 de #612 (créneau A2, Q-PA2-2 (a))

*Rédigé par l'agent `actuary` (IA), le 25/11/2026, sur le diff non commité de V2 (`claude/creneau-a2`, tête `e4ecb16`), confronté à l'annotation du 25/11/2026 de `docs/adr/0005-msep-reserve-2-formule-imprimee-d5.md` (Décision points 1 et 2, « Ce qui est établi » point 5) et au rendu de `plot_mw_facteurs()` (`R/display_helpers.R`, l. 2025-2160). Versé intégralement par la session principale (Q-54-10).*

Les deux légendes et le gabarit du cas « dégénéré » sont validés. Le gabarit du cas « simulation » est à réécrire : trois réserves et un texte de remplacement.

## 1. `FORMAT_MENTION_MW_SIGMA_DIRECT_SIMULATION` : proposition de texte

Juste sur le fond : la règle de minimum s'applique à la MSEP, à σ_USP et à l'`estim` de M6, ainsi qu'au σ* de chaque réplication (`mw_msep()` sur le triangle réajusté, ADR, point 5) ; l'estimateur direct sert aux résidus et à la simulation de la colonne J−1, par convention de l'outil, non réglementaire.

Réserves :
- **« elle fixe la MSEP, sigma(res,s,USP) »** : trop fort. La valeur de la règle **entre dans** la MSEP, qui dépend aussi de f, Ĉ et des autres σ_j ; σ(res,s,USP) en dépend par la MSEP. Seule l'estimation de la ligne est la valeur de la règle elle-même.
- **« L'estimateur direct, … donne ici pour information, … simule la colonne J-1 »** : ambigu. « Pour information » y qualifie l'estimateur, qui sert pourtant à la simulation. L'ADR (point 4 maintenu, Q-2a-4) dit que c'est la **valeur restituée** à la ligne M6 qui l'est, sans σ ni √MSEP alternatifs. La mention doit le dire en fin de phrase, comme le gabarit « dégénéré ».
- **Syntaxe** : « L'estimateur direct, %s a … » manque d'un verbe ; reprendre « vaut », comme le gabarit « dégénéré ».

Texte proposé (mêmes arguments %d, %s, %d, même ordre ; aucun nombre issu du bootstrap, règle #76) :

```r
FORMAT_MENTION_MW_SIGMA_DIRECT_SIMULATION <- paste(
  "Trapeze (I > J) : la regle de minimum s'applique a sigma2_(J-1) par prescription",
  "de l'annexe XVII, D(5)(d)(ii), seconde ligne, bien que la colonne J-1 porte %d",
  "facteurs ; sa valeur entre dans la MSEP et dans sigma(res,s,USP) et donne",
  "l'estimation de cette ligne ; appliquee a chaque triangle reajuste, elle entre",
  "aussi dans le sigma de chaque replication du bootstrap. L'estimateur direct vaut",
  "%s a %d degre(s) de liberte ; il reduit les residus de cette colonne (tests,",
  "influence, vivier du bootstrap) et, par convention de l'outil, non reglementaire,",
  "sert a simuler la colonne J-1 des triangles tires par le bootstrap, sans entrer",
  "dans la MSEP ni dans sigma(res,s,USP) : valeur restituee pour information, sans",
  "sigma ni racine(MSEP) alternatifs.")
```

## 2. `FORMAT_MENTION_MW_SIGMA_DIRECT_DEGENERE` (inchangé) : validé

Sous V2, le cas dégénéré est exactement celui où le prédicat est faux (trapèze dont la colonne J−1 est dégénérée) ; `mw_bootstrap()` y garde alors `aj` (ADR, point 1 : « Colonne J−1 dégénérée : simulation inchangée »). « Aucun de ses résidus n'est retenu » et « n'entre ni dans la MSEP ni dans la simulation » restent exacts ; « valeur donnee pour information » se lit sans ambiguïté, l'estimateur n'étant utilisé nulle part.

## 3. Légendes `MW_USAGE_SIGMA_SIMULATION` : validées

- `sigma` (91 caractères) : « MSEP, sigma_USP et sigma des replications » est exact ; la règle n'est plus annoncée pour la simulation, ce qui est juste sous V2.
- `sigma_residus` (87 caractères) : « residus, tests et simulation (convention de l'outil) » est exact.
- Sous plotly, la légende est coupée au premier « : » ; secondes lignes de 41 et 52 caractères, sans problème.
- En base R, largeur mesurée dans un périphérique png à cex = 0,7 (`strwidth`) : 359 px et 312 px, contre 299 px pour la légende T−5 actuelle. À 395 px de large, avec le symbole et le décalage de 1 %, il reste environ 5 à 10 px : serré mais logé. Rendu réel à confirmer par le passage léger d'`app-review` prévu à PA-2.

`MW_USAGE_SIGMA` (carré) et `MW_USAGE_SIGMA_DEGENERE` ne changent pas et restent exacts.

## Retour

- **Statut** : complet. (1) proposition de texte ; (2) validé ; (3) validées, réserve sur le rendu base R à 395 px.
- **Vérifié** : le diff `git diff R/engine.R` ; l'ADR 0005, annotation du 25/11, points 1, 2 et 5, et point 4 du 21/11 maintenu ; le rendu par `plot_mw_facteurs()` ; `strwidth` (359 / 312 / 299 px).
- **Non vérifié** : rendu réel sous Chromium et plotly ; effet du nouveau texte sur les tests qui comparent le `detail` de M6 (à aligner par `coder`).
- **Critères déclenchés** : aucun (texte non numérique ; aucun σ_USP, p-value ni verdict changé).
- **Constat hors périmètre** : la fiche `mw:m6sig` du `.tex` cite peut-être l'ancienne mention (E5) ; couvert par `docwriter` en fin de branche.

## Synthèse de la session

Texte final retenu : celui du § 1, avec la précision de renvoi de `regulatory` (`regulatory-1-mention-m6-v2.md`, point 2) : « sa valeur entre, par Q_(J-1) (D(5)(d)), dans la MSEP de D(5) et, par elle, dans sigma(res,s,USP) de D(4), et donne l'estimation de cette ligne ».
