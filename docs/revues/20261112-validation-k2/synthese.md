# K2 : validation et revue finale, synthèse (12/11/2026)

> *Synthèse de la session principale.* Branche `claude/fichiers-et-point-decimal`, tête revue `54a3d1b` ; `origin/main` = `35042ca` (déjà intégrée). Les rapports des agents sont versés tels quels dans ce dossier (Q-54-10) ; seule la mise en fichier est de la session.

## Pièces

| Fichier | Agent, fiche | Objet | Conclusion |
|---|---|---|---|
| `actuary-validation.md` | `actuary-approfondi` | étape 10 : validation unique du diff `.tex` et README, textes de l'étape 2, résultats | validé avec réserves : code et résultats sans réserve ; `.tex` sous réserve de C1 (majeur) et C2 à C4 (mineurs), C5 facultatif |
| `regulatory-lecture-annexe-xvii.md` | `regulatory` | circuit 4 : lecture d'A(1)(b) et D(1) à D(5) de l'annexe XVII pour le refus de la colonne 0 vide (#520) | refus conforme ; documentation en écart (« de même ») ; texte de remplacement proposé, ancrage « se rattache à D(1) lu avec A(1)(b) » sous condition |
| `audit-revue-finale.md` | `audit`, `high` | règle 10, `git diff origin/main...HEAD` | conforme avec réserves : 0 bloquant, 0 majeur, 4 mineurs ; batteries 3885 / 3885 (avec `openxlsx`, `zip`, `shiny`) et 3734 / 3734 (sans) ; références identiques au seuil 0 |
| `app-review-revue-finale.md` | `app-review`, Opus | règle 10, application | 0 bloquant, 0 majeur, 3 mineurs ; rendu réel vérifié (Playwright) |
| — | `/code-review`, `high` | règle 10 | 9 constats (ci-dessous), sans trace écrite propre hors de cette synthèse |

## Résultats

Aucun σ_USP, aucune p-value ni aucun verdict des six cas ne change (`comparer_references.R --seuil 0` : 0 écart ; `test_reproductibilite.R` : 6 cas, écart 0). Les comportements changés hors références sont couverts par des décisions déjà prises (tableau du § 4 du rapport d'`actuary`).

## Décisions du mainteneur du 12/11/2026 sur la revue finale

- **Extension de #522 aux CSV** (`audit` m2) : un CSV dont la ligne 1 ne contient que des séparateurs reçoit le refus de #522, dans K2.
- **`zip` déclaré dans `Suggests`** (`audit` m4 (a), `/code-review` n° 5) : commit `repo:` `3653a8d`.
- **Refus de la colonne 0 vide (#520) : ancrage réglementaire D(1) lu avec A(1)(b)**, contre la recommandation d'`actuary` (C1, aucun ancrage) ; `regulatory` a établi la lecture et le texte (« se rattache à », avec la condition des deux lectures ; D(2)(c) et D(3)(c) écartés). L'appui facultatif D(3)(d) et D(4) (D2 de `regulatory`) n'est pas retenu.
- **Ligne 1 faite de blancs : option (b)**, sur l'avis d'`actuary` : refusée au texte de #522 sur les deux chemins xlsx comme en CSV (la parité des deux chemins xlsx, rompue par l'extension aux CSV, est rétablie) ; la description de ce cas validée le matin par `actuary` (C2) est caduque.
- Plus tôt dans la journée : refus motivés d'`engine_lire_xlsx()` de classe `usp_refus_lecture`, affichés tels quels par l'application (#522).

## Sort des constats

| Constat | Sort |
|---|---|
| `actuary` C1 | corrigé par `docwriter` selon le texte de `regulatory` (décision ci-dessus) |
| `actuary` C2 | remplacé par le texte d'`actuary` pour l'option (b), reporté par `docwriter` |
| `actuary` C3, C4, C5 | corrigés par `docwriter` |
| `actuary` § 3.1, octet 0x89 Latin-1 cité « ‰ » | écart à l'avis amont validé ; règle de l'avis remplacée |
| `actuary` O1, `audit` m1, `app-review` M2 : commentaire de `lire_tableau()` | corrigé, `0eb57cf` |
| `actuary` O2 : classe `usp_refus_lecture` absente de `CONTEXT.md` | reste, à trier |
| `actuary` O3 : ligne 1 de blancs et triangle 7 × 8 (hypothèse) | reste, non sondé |
| `audit` m2 : CSV à ligne 1 de séparateurs | corrigé (extension de #522, option (b)), `0eb57cf` |
| `audit` m3 : `.xlsx_attribut()` capté par `name="x id="` | corrigé (attributs lus entiers), `a8426b4` |
| `audit` m4 (a) : `zip` hors `DESCRIPTION` | corrigé, `3653a8d` |
| `audit` m4 (b) : « contenant `..` » surestimé dans le `.tex` | corrigé par `docwriter` |
| `app-review` M1 : gardes « openxlsx ou commande zip » et scénario #522 sans `else` | corrigé, `514b052` (mesuré : 140 assertions Shiny sans commande `zip`) |
| `app-review` M3 : formes des refus d'import non homogènes | reste, à trier |
| `/code-review` n° 1 : ligne 1 de `<v></v>` non refusée | accepté (même motif « (vide) » sur les deux chemins) |
| `/code-review` n° 2 : `r` et `t` lus par une regex gloutonne sur tout l'élément | corrigé, `a8426b4` |
| `/code-review` n° 3 : références en minuscules | lues par le lecteur interne, `a8426b4` ; openxlsx 4.2.9 ne les lit pas (divergence nommée) |
| `/code-review` n° 4 : balises préfixées et apostrophes dans `workbook.xml` | lues par le lecteur interne, `a8426b4` ; openxlsx 4.2.9 ne les lit pas (erreur R, message fixe, comme avant) |
| `/code-review` n° 5 : pas de repli sur `utils::zip()` quand `zip::zipr()` échoue | corrigé, `514b052` |
| `/code-review` n° 6 : archive décompressée deux fois | reste, à trier |
| `/code-review` n° 7 : règles de chemin et de cellule dupliquées | corrigé, `a8426b4` (`.xlsx_chemin_sort()`, `.xlsx_cellules()`) ; le `/` initial d'une cible (nom de partie absolu, écrit par openpyxl) reste admis, `//…` est refusé |
| `/code-review` n° 8 : `engine_ecrire_csv()` réécrit `write.csv` | reste, à trier |
| `/code-review` n° 9 : feuille de graphique en premier onglet | corrigé, `a8426b4` (première feuille de calcul, openxlsx appelé par son rang) |

| audits des corrections : attribut de cellule préfixé (`x:r`) pris pour `r` | corrigé, `a8426b4` |
| audits des corrections : indice de chaîne partagée négatif (fichier forgé) | corrigé, `c098207` |

Les corrections sont revues sur leur diff (règle 10) avant la sortie du brouillon ; les commits et les restes triés sont listés dans la PR.
