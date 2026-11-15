# S1, étape 2 : décisions du mainteneur sur l'avis amont (15/11/2026)

> *Consignées par la session principale à partir des réponses du mainteneur aux questions posées le 15/11/2026, sur `actuary-avis-amont.md`.*

| N° | Question (renvoi à l'avis) | Décision |
|---|---|---|
| D-S1-1 | Refus nouveaux du § 8, groupes A (valeur fausse aujourd'hui, forme 2 de #574 comprise, qui renverse la limite consignée) et B (formes forgées lues juste) ; `t="d"` refusé | **A et B retenus** : contrat fermé complet R0 à R12 |
| D-S1-2 | `t="e"`, cellule en erreur de calcul (§ 8, C) | **(i) refus** de toute cellule en erreur, avec sa position |
| D-S1-3 | `.en_numerique()` (§ 4) | **Extension à tout vecteur non numérique** : logique, `Date`, `POSIXct`, complexe, brut, liste. Un σ_USP rendu aujourd'hui (colonne logique ou `Date`) devient un refus ; tableau avant / après soumis au visa |
| D-S1-4 | #570 (§ 6) | **Option (a)** : tout en-tête d'encodage « bytes » est refusé, quelle que soit sa place |
| D-S1-5 | Seuil de R11 (§ 1) | **10^6 cellules** |
| D-S1-6 | Option R1b (§ 1) | **Non retenue** : seuls les octets sont contrôlés (R1) |
| D-S1-7 | #588 (§ 7) | **Normalisation** dans `.echapper_texte()` par une table fixe (forme U+0081, celle vue sous Windows) ; attendu de l'assertion #522 révisé ; `app-review` léger sur le message restitué |
| D-S1-8 | Faux doublon Latin-1 / ASCII de `mw_valider_triangle()` (constat hors périmètre n° 1, critère E1 de l'ADR 0018) | **Absorbé dans S1** : `mw_valider_triangle()` emploie le helper de #588 ; pas d'issue nouvelle |

## Lot B de #574 (15/11/2026)

> *Sur `actuary-avis-lot-b.md` (avis d'`actuary-approfondi` sur les questions du codeur) ; réponses du mainteneur aux questions posées le 15/11/2026.*

| N° | Question (renvoi à l'avis) | Décision |
|---|---|---|
| D-S1-9 | Q6 : référence de cellule en minuscules (`r="b2"`), admise par Q-A du 13/11, mais erreur R brute par `openxlsx` 4.2.5.2 | **Refus** : forme de `r` restreinte à `^[A-Z]+[1-9][0-9]*$`, texte du refus de Q-A inchangé ; renverse Q-A sur ce point |
| D-S1-10 | Visa des changements de résultat hors références du lot B : (a) texte portant « t= » après une cellule (en-tête ou pied de page), σ_USP rendu → refus ; (b) chaîne en ligne indentée, σ_USP rendu en interne → refus ; (c) cellule sans valeur hors des limites (XFE10) → refus ; (d) `<v >` et `<v xml:space="preserve">`, refus en interne → σ_USP 0.1114524114, comme `openxlsx` | **Visa accordé**, (a) à (d) |
| D-S1-11 | Constat hors périmètre n° 1 du codeur (cellules hors de l'ordre de lecture : `xt` et `yt` permutés par `openxlsx`, σ_USP 0.1764544949 au lieu de 0.1114524114 ; erreur R brute si la ligne 1 est en fin de bloc ; critère E1 de l'ADR 0018) | **Règle R6b dans #574** (S1, lot B), texte d'`actuary` ; pas d'issue nouvelle |
