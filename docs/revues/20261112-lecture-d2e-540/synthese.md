# Synthèse : lecture de D(2)(e), D(4) et D(5) par `regulatory` (#540, 12/11/2026)

> *Rédigé par la session principale (IA).* Décision Q-60-8 (a) du 12/11/2026 : lecture par `regulatory` en effort `high`, hors branche, pendant K3b ; matière versée dans K3b ; suite au soixante et unième point. Rapport intégral : `regulatory-lecture-d2e-d4-d5.md`.

- **Formules conformes** pour un triangle carré (I = J) : D(4) et D(5) transcrites terme à terme dans `mw_parametre()`, `mw_ajuster()`, `mw_msep()` et dans `sec:mw`, sans écart. Textes consolidé et JOUE identiques sur ces points, hors MSEP (ADR 0005).
- **Deux lectures** pour un trapèze (I > J), admis par D(2)(e) mais pour lequel D(4) et D(5) appellent des termes indéfinis :
  - **A, stricte** (moteur actuel) : refus MW-04, aucune valeur fabriquée ; domaine de l'outil plus étroit que celui de D(2)(e) ;
  - **B, extensive** : réserve et contribution à la MSEP nulles pour les années entièrement développées, règle de minimum maintenue pour j = J−1, durée G(3)(c) = I + 1 ; changerait le domaine (un trapèze recevrait un σ_USP), circuit 2.
- **Aucun σ_USP des références n'est touché** sous l'une ou l'autre lecture (six cas carrés).
- **Remarques R-1 à R-4** : MW-04 redondant avec MW-03 quand I < J ; trois qualifications de la même restriction (motif, `.tex`, ADR 0005) ; fiche `mw:m6sig` sous la lecture B ; garde-fous d'une éventuelle extension.
- **Suite** : avis d'`actuary` sur la lecture B (validité de Merz-Wüthrich restreinte sur un trapèze), puis décision du mainteneur au soixante et unième point. Commentaire proposé pour #540 (§ 5 du rapport), à déposer sur accord du mainteneur.
