# Revue de la dernière reprise du `.tex` (R-A, r1 à r4, lot G) (actuary, 16/11/2026)

> *Rédigé par l'agent actuary (IA).* Rapport versé intégralement par la session principale. Revue, sur son diff, de la dernière reprise du `.tex` par docwriter (S1, PR #591, Refs #574) : `git diff a791d4a..c3273eb -- docs/latex/doc_tests_usp.tex docs/suivi-documentation/I.md` (commits `6691bf9`, `c3273eb`), comparée au code `2d60995` / `c3273eb` et aux sorties `sorties/574-lot-g-avant.txt` / `574-lot-g-apres.txt` et `574-lot-f-avant.txt`.

## Verdict : visa avec une réserve mineure

Rien de bloquant ni de majeur. Le diff applique R-A et r1 à r4, conformément à D-S1-34. Il décrit exactement le lot G (D-S1-35, D-S1-36), avec une seule réserve mineure. Le `.tex` ne contient aucune vie du dépôt (pas de numéro d'issue, de décision ni de SHA). Celle-ci est dans `I.md`, sous le label d'origine.

## Points soumis par docwriter

1. **pandas limité à son moteur openpyxl : accepté.** Ma formule « par ces deux moteurs » (revue précédente, l. 99) était inexacte. Par défaut, pandas `to_excel(engine="xlsxwriter")` n'active pas `constant_memory`. Il écrit donc le texte dans la table des chaînes partagées, qui est admise. La mesure de docwriter (consignée dans `I.md`) corrige ma revue, et le `.tex` est juste. Point non vérifié, à ne pas ajouter : pandas avec `engine_kwargs={"options": {"constant_memory": True}}` écrirait sans doute la chaîne en ligne refusée.
2. **Niveau de détail de la règle des positions citées pour `<sheetData>` : acceptable dans `sec:controles`, qui décrit le contrat jusqu'au motif.** Mais l'énoncé est inexact sur un cas (voir m1).
3. **r1 « lue vide par les deux chemins » au lieu de « vide ou NA » : accepté.** Le guide définit « vide » au l. 4702 : « Une cellule est vide si elle vaut `NA` ou est une chaîne vide ». La mesure (`574-lot-f-avant.txt`, cas `vide-preserve-note` : "" en interne, `NA` par openxlsx 4.2.5.2, ok = TRUE sur les deux chemins) correspond donc à « vide » au sens du document.

## Item « Balisage » comparé à `R/engine.R` : exact

- **Les quatre parties** sont celles de l'item « Encodage » (l. 4757-4759 : `xl/workbook.xml`, ses relations, la feuille lue, la table), sur lesquelles le code appelle `.xlsx_controler_balisage()`.
- **Ordre**
  - `.xlsx_fichier_feuille()` exécute `lire()`, soit `.xlsx_texte()` (R1), sur `xl/workbook.xml`, puis sur ses relations.
  - Elle applique ensuite `.xlsx_controler_balisage()` aux deux parties, avant `.xlsx_balises(wb, "sheet")` et avant le refus « aucune feuille trouvee ».
  - Enfin, `.xlsx_admettre()` fait R1 sur la feuille et la table, puis R2 sur les deux, puis appelle `.xlsx_controler_structure()`.
  - Les deux conséquences écrites en découlent : un commentaire refusé même si la feuille n'est pas de l'UTF-8 valide, et un commentaire qui masque la seule `<sheet>` refusé au balisage.
- **`_rels/.rels` non lue ni contrôlée** : c'est ce que dit le commentaire du code. Le témoin `temoin-dot-rels-commentaire` est admis avec 104,2 sur les deux chemins (avant et après).
- **Motif mesuré 999 au lieu de 104,2** : `574-lot-g-avant.txt`, cas `rels-commentaire-sheet2`. Les deux chemins (interne et openxlsx 4.2.5.2) lisent xt = 999,00, ok = TRUE, σ_USP 0,5064392336. Après le lot G, le cas est refusé en nommant `xl/_rels/workbook.xml.rels`.
- **Entrée de l'index (l. 976-981)** : exacte.

## Constats

**Bloquant** : aucun. **Majeur** : aucun.

**m1 (mineur), l. 4789-4794 du `.tex` à `c3273eb`.**
- **Énoncé du `.tex`** : « le motif cite chaque fermante en surnombre, […] et, sauf si le bloc compte une seule ouvrante et aucune balise vide, les ouvrantes et les balises vides ».
- **Code (`.xlsx_controler_structure()`)** : la restriction aux seules fermantes en surnombre ne s'applique que si `length(sur) > 0`. Un `<sheetData>` seul, jamais fermé, n'a aucune fermante en surnombre. Le `.tex` lui fait citer une liste vide, alors que le code cite l'ouvrante.
- **Mesure** (`charger_moteur()`, `LC_ALL=C.UTF-8`, HEAD `c3273eb`) : `<sheetData><row r="1"><c r="A1"><v>1</v></c></row>` sans fermante donne « (balise <sheetData>, avant la premiere cellule) ».
- **Correction** : « sauf si le bloc compte une seule ouvrante, aucune balise vide et au moins une fermante en surnombre ». Autre possibilité : déplacer la règle des positions dans `I.md` et garder dans le `.tex` « le motif cite les balises `<sheetData>` en cause ».
- **Remarque, sans constat** : `<sheetData><sheetData>…</sheetData>` cite une seule fois « balise <sheetData>, avant la premiere cellule », alors que les deux ouvrantes sont à l'index (mesuré). Les deux citations sont identiques et paraissent fusionnées. « les ouvrantes » reste vrai au sens du texte cité.

**Les autres points sont vérifiés exacts** :
- r2 : `<t>…</t>` ou `<t/>` ;
- r3 : cible `./worksheets/…` sous 4.2.5.2 seulement ;
- r4 : `keepNA = TRUE` ;
- R-A : « y compris dans une colonne que l'outil ne lit pas » ;
- deux `</sheetData>` sans ouvrante : lus par la voie de repli, feuille vide sous openxlsx (`574-lot-g-avant.txt`).

## Retour

- **Statut** : `complet`.
- **Résultat** : visa avec une réserve mineure (m1). Les trois points de docwriter sont acceptés.
- **Preuves**
  - **Vérifiées**
    - Diff `a791d4a..c3273eb`.
    - Code de `.xlsx_fichier_feuille()` (l. 9085-9106), `.xlsx_admettre()` (l. 10195-10236) et `.xlsx_controler_structure()` (branche `sur`, diff `261c45e..2d60995`).
    - Sorties `574-lot-g-avant.txt` / `-apres.txt` (cas `rels-commentaire-sheet2`, `temoin-dot-rels-commentaire`, `sheetdata-*`) et `574-lot-f-avant.txt` (`vide-preserve-note`).
    - Définition de « vide » au l. 4702.
    - Exécution de `.xlsx_controler_structure()` sur deux XML (sortie citée en m1).
  - **Hypothèse** : la fusion des citations identiques (remarque de m1). Je ne l'ai pas tracée dans le code de `refus()`.
  - **Non vérifié** : les mesures openpyxl / XlsxWriter / pandas de docwriter, reprises telles quelles de `I.md`, et le cas pandas avec `constant_memory` explicite.
- **Informations manquantes** : aucune.
- **Décisions non résolues** : la forme de la correction de m1 (corriger l'énoncé ou le déplacer dans `I.md`) revient à la session ou à docwriter.
- **Critères déclenchés** : aucun. Le diff ne change aucun résultat ; il documente un changement déjà tracé (D-S1-35, D-S1-36).
- **Constats hors périmètre** : aucun.
- **Prochaine action recommandée** : un commit `docs:` minimal de docwriter pour m1, revu sur son diff, puis le PDF de branche.
