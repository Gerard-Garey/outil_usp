# Compte rendu de `coder-approfondi` sur #572 (P2, X1, M1)

> Versé par la session principale (condensé fidèle). D'office (§ 10 de `routage.md`). 13/11/2026, sur `9a7257c`.

## Fichiers modifiés
- `R/engine.R` : constante `XML_ATTRIBUTS_BALISE` (motif `([ \t\r\n]([^>"']|"[^"]*"|'[^']*')*)?`) ; **M1** : ce motif remplace `([ \t\r\n][^>]*)?` dans les deux motifs `<rPh` de `.xml_textes()`, commentaire inexact réécrit ; dans `engine_lire_xlsx()`, refus **P2** (`<rPh`+motif+`/>`) puis **X1** (dans chaque `<si>`, après retrait des `<rPh…>…</rPh>`, `<r…/>`, `<r…>…</r>`, plus d'un `<t`+motif+`/?>`), textes exacts de l'avis, sur `xl/sharedStrings.xml`, ordre Q-F → P2 → X1, avant la ligne 1 et avant `openxlsx` ; commentaires d'en-tête mis à jour.
- `tests/unitaires/test_controles_entree.R` : retrait des deux assertions qui figeaient P2 accepté ; 9 assertions #572 sur les deux chemins (P2, M1, X1 en cinq formes, ordre, classe, absence de faux refus sur les 9 formes du § 4 de l'avis, chaînes `<is>`).

## Comportements de lecture (valeur « 1 » puis « 1.5 » ; `openxlsx` 4.2.9)
| Entrée (table partagée sauf mention) | Avant : interne / openxlsx | Après (deux chemins) |
|---|---|---|
| P2 `<rPh sb="0" eb="0"/>`, `<rPr>` présent | 11,5 / **1** (ok) | refus P2 |
| M1 `sb="0>"`, `sb='0>'`, saut de ligne, suivi d'un vrai `<rPh>` | **1 / 1** (ok) | refus P2 |
| M1 sans `<rPh>` qui suit | 11,5 / 1 | refus P2 |
| X1 `<t>1</t><t>1.5</t>` | 11,5 / **1** (ok) | refus X1 |
| X1 avec `<rPr>` ailleurs | 11,5 / 11,5 | refus X1 |
| X1 `<t/><t>11.5</t>` | 11,5 / non numérique, refusé en aval | refus X1 |
| `<t>1</t>` suivi de `<r><rPr>…<t>1.5</t></r>` | 11,5 / 11,5 | inchangé |
| formes normales du § 4 de l'avis | 11,5 / 11,5 | inchangé |
| `<x:rPh …/>` préfixé, ou `<x:rPh>…<x:t>` | 11,5 / 11,5 | inchangé, non visé |
| `<is>` de forme P2 ou X1 | 11,5 / NA, refusé en aval | inchangé (limite consignée) |

## Vérifications (`LC_ALL=C.UTF-8`)
- `test_controles_entree.R` : 433 / 433 avec `openxlsx` ; 418 / 418 sans.
- `test_unitaires.R --parallele` : 3992 / 3992 avec ; 3798 / 3798 sans.
- `comparer_references.R --seuil 0` : 6 CONFORME, écart maximal 0.
- `concordance_doc_moteur.R --strict` : 0 écart. `test_reproductibilite.R` : OK, 6 cas.

## Surface d'impact documentaire
Fiche du lecteur xlsx (l. 887-891, « ces trois refus » → **sept** : ligne 1 sans valeur, cellule sans `r`, balise `<c` non reconnue, référence de forme non attendue, Q-F, P2, X1) ; § contrôles l. 4592 (même correction) ; `.xml_textes()` (motif) ; limites `<is>` et `<x:rPh>` (et `<x:t>`) à consigner.

## Questions et suites (session)
1. X1 refusé même si la table porte un `<rPr>` (cas lu juste par `openxlsx`) : conforme à la condition de l'avis (indépendante de `<rPr>`), ratifiée telle quelle par le mainteneur ; pas de nouvelle question.
2. `<x:t>` préfixé, non lu par l'outil, non mesuré sous `openxlsx` : limite à consigner par `docwriter`.
3. `openxlsx` 4.2.5.2 (CI) : non mesuré ici ; le job de parité tranche.
