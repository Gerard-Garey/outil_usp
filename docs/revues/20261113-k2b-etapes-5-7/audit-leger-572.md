# Audit léger de #572 (refus P2 et X1, correction M1)

> Versé par la session principale (condensé fidèle). Fiche `audit`, règle 10. 13/11/2026, diff non commité sur `9a7257c`.

**Conclusion : conforme.** Aucun constat.

## Points contrôlés
- Textes : P2 (315 caractères) et X1 (308) identiques au caractère près à l'avis, dans le moteur et dans le test ; classe `usp_refus_lecture` (assertion sur les deux chemins).
- Placement : Q-F, P2, X1, avant `.xlsx_controler_ligne_entete()` et avant `requireNamespace("openxlsx")` ; ordre figé par une assertion.
- M1 : `XML_ATTRIBUTS_BALISE` = motif de l'avis, employé dans `.xml_textes()` et dans la détection de P2 (parité).
- Faux positifs : aucun sur 20 cas adverses (`<rPhX/>`, `<phoneticPr/>`, `<rPh>` ouvrant avec `sb="0/>"` ou `sb='x"/>'`, `<rPh></rPh>`, `<tab/>`, `<t2>`, `<si><t/></si>`, plusieurs `<r>` avec `<rPr>`, `<r a="x>y">`, `<T>`…). Faux négatifs : aucun (sauts de ligne, `" />"`, `sb="0>/"`, `<t xml:space="pre>s"/>`…).
- Performance (TRE, sans retour arrière) : table réaliste de 10,7 Mo : P2 0,09 s, X1 0,89 s ; cas pathologiques de 2 à 4 Mo : ≤ 2,2 s ; `.xml_textes()` +20 % environ (7,2 s → 8,7 s sur 100 000 chaînes), sorties identiques.
- Retrait des deux assertions qui figeaient P2 accepté : justifié par la décision ratifiée ; remplacées par les refus P2 et M1 ; les neuf formes normales ont chacune une assertion ; limite `<is>` figée.
- Commentaires exacts au regard des mesures ; logique dans `engine.R` seul, sans dépendance ni aléa.

## Vérifications (`LC_ALL=C.UTF-8`)
| Commande | Résultat |
|---|---|
| `test_controles_entree.R` (openxlsx 4.2.9) | 433 / 433 |
| `test_controles_entree.R` (sans openxlsx) | 418 / 418 |
| `comparer_references.R --seuil 0` | CONFORME, écart maximal 0 |
| `concordance_doc_moteur.R --strict` | 0 écart |

## Question pour `actuary` (sans reprise)
Le commentaire du moteur sur X1 présente comme un fait l'ordre de CT_Rst (un `<t>`, puis des `<r>`, puis des `<rPh>`), que l'avis dit non revérifié dans `sml.xsd`. → *Session* : porté à `docwriter` (ne pas l'affirmer comme vérifié dans le `.tex`) et à la validation d'`actuary-approfondi` (étape 9).

## Hors périmètre
`openxlsx` 4.2.5.2 non mesuré (job de parité) ; limite `<x:t>` à consigner par `docwriter`.
