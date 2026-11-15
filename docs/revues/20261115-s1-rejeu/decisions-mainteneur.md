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

## Lot C de #574 (15/11/2026)

> *Sur l'avis d'`actuary` (fiche de base) sur les questions du codeur du lot C : points 1 à 4 acceptés sans décision ; point 5, formes lues juste et désormais refusées, couvertes par D-S1-1, visa requis comme changement de résultat hors références.*

| N° | Question | Décision |
|---|---|---|
| D-S1-12 | Visa du tableau avant / après du lot C (R7, R8) : valeurs fausses corrigées (`t="d"`, `0x10`, `1&#48;4.2`, `1&lt;2`, `1e`, `104,2`, `t="b"` 2, `t="s"` sans `<v>` ou avec `<v/>`, `t="S"`) ; formes lues juste (σ_USP 0.1114524114) refusées : `t="N"`, `t="Str"`, indice de chaîne `" 1"`, `1.0`, `+1`, `1e0`, `<is>` sans `t="inlineStr"` ou avec `t="n"` ou `t="str"`, `inlineStr` avec `<v>`, `t="e"` hors du tableau | **Visa accordé** |
| D-S1-13 | Portée de D-S1-2 relevée par l'audit léger du lot C : `openxlsx::write.xlsx()` écrit `t="e"` pour un NA (`keepNA = TRUE`, « #N/A ») et, par défaut, pour Inf, -Inf, NaN (« #NUM! ») ; un tel classeur, lu avant si la cellule est hors des colonnes lues, est refusé | **D-S1-2 maintenue** dans toute sa portée : toute cellule en erreur refusée, quelle que soit sa place ; changement porté au tableau avant / après du lot C (visa D-S1-12) |

## Lot D de #574 et suite de la branche (15/11/2026)

> *Réponses du mainteneur aux questions posées le 15/11/2026 sur le compte rendu du codeur du lot D (règle R9), avant l'avis d'`actuary-approfondi` (`actuary-avis-lot-d.md`), le mainteneur ne pouvant plus répondre avant la session suivante.*

| N° | Question | Décision |
|---|---|---|
| D-S1-14 | Visa des formes lues juste (σ_USP 0.2005042338 sur les deux chemins) et désormais refusées par R9, non énumérées au § 8 : `<rPhX/>`, `<tab/>`, `<tabx/>`, `<x:tab/>`, `<t>` dans `<x:r>` (deux témoins de #572), texte hors de `<t>`, `<SI>`, `<t>` après `<rPh>` ; liste fermée des éléments de `<rPr>` (`XML_ENFANTS_RPR`, 15 éléments, à confronter au corpus Excel / LibreOffice de l'étape 10) | **Visa accordé** ; liste fermée gardée jusqu'au corpus |
| D-S1-15 | Second `<rPh>` dans une même `<si>` (lu « 117 » au lieu de « 11 » par `openxlsx` 4.2.5.2 si la table porte `<rPr>`) | **Règle conditionnelle** : refus seulement si la table porte `<rPr>` |
| D-S1-16 | Balises préfixées dans `<extLst>` de la table des chaînes partagées | **Refus** (lettre de l'avis amont : aucune balise préfixée dans toute la table), à revoir sur le corpus de l'étape 10 |
| D-S1-17 | Corrections demandées en l'absence du mainteneur par `actuary` ou l'audit, pour le lot D ou #570 | **Délégation** : réalisées et commitées sans le mainteneur si elles ne refusent aucune forme lue juste de plus et ne changent ni σ_USP ni verdict des références ; une reprise par constat ; hors de ces bornes, ou désaccord d'`actuary` avec D-S1-14 à D-S1-16 : arrêt, sauvegarde et handoff |

> *Note de la session sur `actuary-avis-lot-d.md`, rendu après D-S1-14 à D-S1-17. Pas de désaccord avec ces décisions : Q1 à Q6 confirment ou acceptent (Q2 conditionnelle = D-S1-15, Q3 refus = D-S1-16). Les témoins `<t>` dans `<x:r>` de #572, que l'avis demande de nommer au visa comme renversement du correctif du 14/11, l'étaient dans la question de D-S1-14. Réserves (a), commentaire de `XML_ENFANTS_RPR`, et (b), `<phoneticPr></phoneticPr>` admise, sont réalisées sous D-S1-17 (aucun refus nouveau). **Q7 reste ouverte** : le refus ciblé des références numériques de caractère désignant un caractère ASCII imprimable refuserait une forme lue juste par le chemin interne ; il sort des bornes de D-S1-17 et attend le mainteneur (handoff). La forme est antérieure au lot D et sans lien avec R9.*
