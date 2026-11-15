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
