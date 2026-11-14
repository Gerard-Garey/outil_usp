## Compte rendu : reprise unique de `coder-approfondi` sur #557 (lecteur xlsx), après l'audit léger non conforme

Les cinq points sont faits et toutes les batteries passent. Je n'ai fait ni commit ni push, et je n'ai touché ni au `.tex` ni à `tests/reference/`. `git status --short` ne montre que les deux fichiers attendus : `R/engine.R` et `tests/unitaires/test_controles_entree.R`. En tout, 263 lignes ajoutées et 22 retirées, diff d'origine compris. Une case du constat 1 (P2) reste fausse chez `openxlsx`, sur une forme hors schéma : je la laisse en l'état et la soumets comme question (Q1 ci-dessous).

Mes mesures sont dans `<scratchpad>/coder557b/` :
- `mesure.R` : 26 cas ;
- `mesure_x.R` : 6 cas ;
- les sorties `avant_{sans,429,4252}.txt` sur la tête (`coder557/engine_avant.R`, identique à `git show HEAD:R/engine.R` selon `cmp`) ;
- les sorties `apres_*.txt` et `apres_x_*.txt` sur la copie de travail ;
- les sorties des batteries (`tce_*`, `tu_*`, `repro.txt`, `compref.txt`).

`openxlsx` 4.2.9 et 4.2.5.2 donnent des sorties identiques (`diff` vide, avant comme après). La voie interne donne la même chose sans `openxlsx` que sous 4.2.9.

### Fichiers modifiés

**`R/engine.R`**

1. **`.xml_textes()` (constat 1).** Le retrait de `<rPh>` se fait maintenant en deux temps :
   ```r
   x <- gsub("<rPh([ \t\r\n][^>]*)?/>", "", x)
   x <- gsub("<rPh([ \t\r\n][^>]*)?>.*?</rPh>", "", x)
   ```
   - Je n'ai pas repris le `[^>/]*` proposé par l'audit. Une fois les balises auto-fermantes retirées, toute balise `<rPh` restante est ouvrante, et `[^>]*` traite aussi une valeur d'attribut qui contient `/`.
   - Mesure : `'<t>a</t><rPh/><t>b</t><rPh sb="a/b"><t>Z</t></rPh><t>c</t>'` donne `"abc"`. Avec `[^>/]*`, ce bloc ne serait pas retiré et `Z` serait concaténé au texte.
   - Le moteur d'expressions est TRE, `perl` n'est pas activé. Mesure : le `.` traverse les fins de ligne, `'<t>11</t><rPh sb="0" eb="1">\n<t>7</t>\r\n</rPh><t>2</t>'` donne `"112"`.
   - Le commentaire d'en-tête dit les deux temps.

2. **`.xlsx_controler_cellules()` (constat 2 et Q-A étendue).**
   - **Refus de balise.** Le test passe de `grepl("<c[\t\r\n]")` à `any(regmatches(xml, gregexpr("<c[[:space:]]", xml))[[1]] != "<c ")`. C'est la classe TRE de `.xlsx_cellules()`, qui couvre aussi FF, VT et U+2003. Le texte du refus est inchangé.
   - **Extraction des balises** : `<c([[:space:]][^>]*)?/?>`.
   - **Refus « sans r ».** Je garde `[ \t\r\n]r="` à dessein : passer à `[[:space:]]` aurait admis `<c s="1"\fr="A2">`, qui est refusé aujourd'hui. Le texte du refus est inchangé octet pour octet.
   - **Contrôle de référence, réécrit.** Les attributs sont découpés par la regex de `.xlsx_attribut()`. La balise doit porter exactement un attribut de nom entier `r`, et sa paire brute doit correspondre à `^r="[A-Za-z]+[1-9][0-9]*"$`.
     - Refusés : `<c r='Z9' r="A2">`, `<c r="A2" r='Z9'>`, `<c r="Z9" r="A2">`, `r="&#66;2"`.
     - Toujours admis : `x:r="Z9" r="A2"` et les minuscules.
     - Le texte du refus est celui du § 2 de l'avis amont, inchangé. Le commentaire d'en-tête est mis à jour.
   - **Coût** (`audit557/adv.R`, 10 000 cellules) : le contrôle prend 0,26 s, contre 0,59 s mesurés par l'audit sur la version précédente.

3. **`engine_lire_xlsx()` (Q-F).**
   - **Condition de refus**, dès la lecture de `sharedStrings.xml` : `grepl("<([A-Za-z_][A-Za-z0-9_.-]*:)?r[[:space:]/>]", sx) && !grepl("<rPr>", sx, fixed = TRUE)`. Le refus est de classe `usp_refus_lecture` et son texte est la phrase exacte du brief.
   - **Pourquoi `<rPr>` littéral.** J'ai mesuré qu'`openxlsx` tronque encore la valeur quand la table ne porte que `<rPr/>`, `<rPr >` ou `<rPr a="1">` (cas F4, F5, X6).
   - **Segments `<r>` couverts.** `<r >` et `<x:r>` font aussi tronquer `openxlsx` (F6, X5). Le motif les couvre, de même que `<r>`.
   - **Place dans la séquence.** Le refus vient :
     - après `.xlsx_controler_cellules()` : la structure de la feuille est contrôlée d'abord, comme avant, et l'ordre des refus existants ne change pas ;
     - avant `.xlsx_controler_ligne_entete()`, qui lit ces chaînes, et donc avant `openxlsx`.
   - **Commentaires mis à jour** :
     - en-tête d'`engine_lire_xlsx()` : la limite « chaîne partagée enrichie tronquée » devient un refus, avec l'hypothèse « un tableur n'écrit pas cette forme » ;
     - `.refus_lecture()` et la liste des refus de classe `usp_refus_lecture` ;
     - blancs FF, VT et U+2003 ;
     - `r` répété ou écrit avec une entité.

**`tests/unitaires/test_controles_entree.R`**

- **Bloc `rphE557` réécrit.** Il figeait l'ancienne lecture `"x"` par `openxlsx`. Il vérifie maintenant :
  - une table sans `<rPr>` : refus Q-F sur chaque chemin ;
  - un témoin avec `<rPr>` : `"xt"` sur chaque chemin.
- **Q-F, cas de bout en bout 11,5.**
  - Quatre variantes refusées sur chaque chemin : sans `<rPr>`, avec `<rPr/>`, avec `<rPr a=..>`, avec `<r >`.
  - Témoin avec `<rPr>` : séries acceptées et `xt = c(10, 11.5, 12, 13, 14)` sur chaque chemin.
  - Le refus est de classe `usp_refus_lecture`.
- **Q-A étendue** : quatre formes de `r` répété ou écrit avec une entité, refusées au texte `REF557` sur chaque chemin.
- **Constat 2** : FF, VT et U+2003, avec une référence valide ou `"1"`, refusés au texte `BALISE_C` sur chaque chemin.
- **Constat 1**
  - `.xml_textes()` : `<rPh sb="0" eb="0"/>` suivi d'un vrai `<rPh>` donne `"xt"` ; avec des sauts de ligne, `"112"` ; avec `sb="a/b"`, `"abc"`.
  - Voie interne de bout en bout : 11,5 lu.
- **Constat 4**, sous `if (avec_openxlsx483)` : une chaîne en ligne avec `<rPh>` dans le corps des séries est refusée en aval avec le motif exact « Certaines valeurs des colonnes xt ou yt ne sont pas numeriques (colonne xt : ligne(s) de donnees 2). ». La voie interne lit 11.
- **Limite P2 figée**, sous `if (avec_openxlsx483)` : `openxlsx` lit 1 (voir Q1).

### Vérifications (toutes sous `LC_ALL=C.UTF-8`)

| Commande | Résultat |
|---|---|
| `charger_moteur()` | « ok » |
| `Rscript tests/unitaires/test_controles_entree.R`, sans openxlsx | 409/409 ok (précédente reprise : 401) |
| La même avec openxlsx 4.2.9 (`R_LIBS=…/k2b-rejeu/lib`) | 424/424 ok, rc 0 |
| La même avec openxlsx 4.2.5.2 (`lib_old:lib`) | 424/424 ok, rc 0 |
| `Rscript tests/test_unitaires.R --parallele`, sans openxlsx | 3789/3789 ok, rc 0 |
| La même avec openxlsx 4.2.9 | 3805/3805 ok, rc 0 |
| `tests/test_reproductibilite.R` | « OK : reproductibilite et non-regression verifiees pour 6 cas. » (57 018 feuilles CONFORME, écart 0), rc 0 |
| `tests/comparer_references.R --seuil 0` | « CONFORME : 57018 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 0 ; ecart maximal 0.000e+00 », rc 0 |
| `tests/concordance_doc_moteur.R --strict` | « BILAN : 0 ecart(s) (mode strict) », rc 0 |
| `git diff --check` | propre |
| `audit557/adv.R` | `<rPh>` auto-fermant donne `"xt"`. Refusés : `&#65;2`, `"A2 "`, `<c\fr="1">`, `<c r="1">`, `r='A2' r="A2"`. Admis : `A2`, `a2`, `XFD1048576`. |
| `audit557/adv2.R` (openxlsx 4.2.9) | Les trois cas sont refusés sur chaque chemin : cas 1 par Q-F (table sans `<rPr>`), cas 2 `&#65;2` par REF557, cas 3 U+2003 par BALISE_C |

Aucune référence n'a changé : aucun σ_USP, aucune p-value ni aucun verdict ne bouge.

### Tableau avant / après (lecture de fichiers ; σ_USP des six cas inchangés)

Les valeurs « avant » sont mesurées sur la tête `b048d5a`. Les sorties sont identiques sous 4.2.9 et 4.2.5.2.

| Cas | Avant, interne | Avant, openxlsx | Après, interne | Après, openxlsx | Explication |
|---|---|---|---|---|---|
| **Q-F** F1 : xt = 11,5 écrit `<r>1</r><r>1.5</r>`, aucun `<rPr>` | lu juste (11,5), `ok = TRUE` | **valeur tronquée acceptée (1 au lieu de 11,5)**, `ok = TRUE` | refus Q-F | refus Q-F | décision Q-F ; refus des deux côtés pour garder la parité |
| F4 / F5 / X6 : `<rPr/>`, `<rPr >` ou `<rPr a="1">` seuls | 11,5 | 1 (tronqué) | refus Q-F | refus Q-F | ces formes ne font pas sortir `openxlsx` de la troncature (mesuré) |
| F6 `<r >`, X5 `<x:r>`, aucun `<rPr>` | 11,5 | 1 | refus Q-F | refus Q-F | idem |
| F7 : un seul segment `<r>11.5</r>`, aucun `<rPr>` | 11,5 | 11,5 | refus Q-F | refus Q-F | décision « au moins un segment `<r>` » ; fichier juste désormais refusé |
| F8 : en-tête `xt` en deux segments, aucun `<rPr>` | lu `xt` | refusé en aval (colonne `x`) | refus Q-F | refus Q-F | motif propre au lieu d'une colonne manquante |
| F2 / F3 : segments `<r>` avec `<rPr>` dans la table (témoin) | 11,5 | 11,5 | 11,5 | 11,5 | inchangé |
| **Q2** P3 : `<t>11</t>` + `<rPh>` dont le texte est 7 | **117 (valeur fausse acceptée)** | 11 | 11 | 11 | valeur fausse corrigée, identique à `openxlsx` (Q-B) |
| P4 : même cas, bloc `<rPh>` sur plusieurs lignes | 117 | 11 | 11 | 11 | idem |
| Q-B : en-tête `xt` + `<rPh>ZZ</rPh>` (chaîne partagée ou en ligne) | `xtZZ`, refusé en aval | partagée : `xt` ; en ligne : `X2` | `xt` | inchangé | décision Q-B (mesure de la reprise précédente) |
| **Constat 1** P1 : `<r>1</r><rPh sb eb/><r>1.5</r><rPh>Z</rPh>`, sans `<rPr>` | `11.5Z`, refusé en aval | 1, `ok = TRUE` | refus Q-F | refus Q-F | — |
| P2 : même chaîne, `<rPr>` ailleurs dans la table | `11.5Z`, refusé en aval | **1, `ok = TRUE`** | **11,5 (juste)** | **1, `ok = TRUE`** (inchangé) | limite propre à `openxlsx`, voir Q1 ; avec le motif d'un seul temps de l'audit, l'interne lisait 1 |
| **Q-A étendue** `<c r='Z9' r="B3">` | Z9 lu, refusé en aval (lignes vides) | erreur R brute | REF557 | REF557 | mesure demandée : `openxlsx` levait « missing value where TRUE/FALSE needed » |
| `<c r="B3" r='Z9'>` | B3, accepté | B3, accepté | REF557 | REF557 | attribut répété |
| `<c r="Z9" r="B3">` | Z9, refusé en aval | Z9, refusé en aval | REF557 | REF557 | motif propre |
| `r="&#66;3"` | B3, accepté | erreur R brute | REF557 | REF557 | constat 3 de l'audit |
| `<c x:r="Z9" r="B3">` | B3, accepté | Z9, refusé en aval | inchangé | inchangé | admis (attribut préfixé) ; divergence déjà consignée |
| `r=""`, `"1"`, `"A0"`, `"1A"`, `" A2 "`, `"A"`, `"A1:B2"`, `<c r="" s="1"/>` | erreur R brute, ou valeur déplacée avec avertissements | erreur R brute ou valeur perdue | REF557 | REF557 | Q-A, tableau de la reprise précédente (`coder557/avant_r.txt`) |
| **Constat 2** `<c\fr="1">` et `<c U+2003 r="1">` | valeurs déplacées, 2 avertissements R, refusé en aval | NA, refusé en aval | BALISE_C | BALISE_C | alignement sur la classe du lecteur |
| `<c\fr="B3">`, `<c\vr="B3">`, `<c U+2003 r="B3">` | 11, accepté | NA, refusé en aval | BALISE_C | BALISE_C | parité rétablie |
| Constat 4 : chaîne en ligne `11` + `<rPh>` dans le corps | 117 | NA, refusé en aval (motif exact) | 11 | inchangé | limite consignée, désormais figée par un test |

### Surface d'impact documentaire (`docs/latex/doc_tests_usp.tex`, non modifié)

- **l. 887-893**, index des fonctions, entrée `engine_lire_xlsx()`. La liste des refus faits avant `openxlsx` gagne la référence de forme non attendue (unique, en valeur brute) et la table de chaînes partagées en segments `<r>` sans `<rPr>`. Le blanc après `<c` couvre maintenant FF, VT et U+2003. Le décompte « ces trois refus » (l. 890) devient cinq.
- **l. 897-902**, voie de repli : la chaîne enrichie lue entière ; ajouter le texte phonétique `<rPh>` non lu.
- **l. 918-921**, description de `.xml_textes()` : « texte de tous les segments `<t>` » devient « hors texte phonétique `<rPh>` ».
- **l. 934-936**, description de `.xlsx_controler_cellules()` : ajouter le refus d'une référence de forme non attendue (exactement un `r`, en valeur brute).
- **l. 4154-4156**, liste des refus motivés affichés à l'import : ajouter la référence mal formée et la table de chaînes partagées.
- **l. 4559-4567** (« Lecture des fichiers ») : ajouter les deux refus avec leur texte, et le refus Q-F avec la limite d'`openxlsx` qu'il évite.
- **l. 4592-4594** : « Les trois refus du classeur » devient cinq ; liste à compléter.
- Fonctions citées : les noms sont inchangés et aucune fonction n'est ajoutée ; la concordance stricte donne 0 écart.

### Message de commit proposé

```
moteur: lecteur xlsx, références de cellule, texte phonétique et chaînes partagées en segments (Refs #557)

- .xml_textes() : texte phonétique <rPh> non lu, retrait en deux temps
  (balise auto-fermante puis bloc) ; « 11 » suivi du phonétique « 7 »
  n'est plus lu 117 (décision Q-B du mainteneur, 13/11/2026).
- .xlsx_controler_cellules() : refus d'une cellule dont l'attribut r
  n'est pas unique ou n'a pas, en valeur brute, la forme
  r="[A-Za-z]+[1-9][0-9]*" (r="", "1", "A0", "&#66;2", r répété...),
  avant openxlsx et sur les deux chemins (décision Q-A et son extension) ;
  balise <c suivie de tout blanc autre que l'espace (FF, VT, U+2003
  compris) refusée, classe du lecteur interne.
- engine_lire_xlsx() : refus d'une table de chaînes partagées qui porte
  des segments <r> sans aucune balise <rPr> (openxlsx 4.2.9 et 4.2.5.2
  n'en lisent que le premier segment : 11,5 lu 1 sans message), avant
  openxlsx et sur les deux chemins (décision Q-F).
- Tests : formes refusées sur chaque chemin, cas de bout en bout 11,5,
  témoin avec <rPr>, limites d'openxlsx figées.

Références identiques (comparer_references.R --seuil 0 : 0 écart) ;
aucun σ_USP, aucune p-value ni aucun verdict modifié.

Surface d'impact documentaire (doc_tests_usp.tex) : index des fonctions,
entrée engine_lire_xlsx() (l. 887-893, décompte « ces trois refus »),
voie de repli (l. 897-902), .xml_textes() (l. 918-921),
.xlsx_controler_cellules() (l. 934-936), refus motivés à l'import
(l. 4154-4156), « Lecture des fichiers » (l. 4559-4567) et « Les trois
refus du classeur » (l. 4592-4594). Aucun tableau 1 ou 2, aucune fiche.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_014w4Cra1JGAyptyhUpSL4kt
```

### Questions pour `actuary` et le mainteneur

1. **P2 : `openxlsx` accepte encore une valeur fausse, et la correction de l'interne crée une divergence.**
   - Cas : chaîne partagée `<r><rPr>…</rPr><t>1</t></r><rPh sb="0" eb="0"/><r><t>1.5</t></r><rPh …><t>Z</t></rPh>`, avec `<rPr>` présent dans la table.
   - `openxlsx` lit 1 avec `ok = TRUE`, avant comme après : il a le même défaut que le motif d'un seul temps.
   - L'interne lit maintenant 11,5, valeur juste ; avant, il refusait en aval.
   - La forme est hors schéma, car `<rPh>` exige un `<t>`.
   - Proposition, non implémentée : refuser toute balise `<rPh …/>` auto-fermante, sur les deux chemins et avant `openxlsx`. Cela demande une décision et un texte.
2. **X1 : deux `<t>` directs dans une `<si>`, sans `<r>` ni `<rPr>`.**
   - Cas : `<si><t>1</t><t>1.5</t></si>`. `openxlsx` lit 1, l'interne 11,5, et les deux donnent `ok = TRUE`. Le défaut existait déjà et la forme est hors schéma.
   - Q-F, tel qu'il est décidé (« balises `<r>` »), ne le couvre pas.
   - À trancher : étendre la condition à « plus d'un `<t>` hors `<rPh>` dans une `<si>` », ou consigner la limite.
3. **Hypothèse Q-F, non vérifiée** : un tableur n'écrit pas de segments `<r>` sans aucun `<rPr>` littéral. Je n'ai pas de classeur enrichi produit par Excel ou LibreOffice pour la contrôler.
   - Conséquence : un `<r>` unique sans `<rPr>` (F7), lu juste par les deux chemins, est désormais refusé.
4. **Information, déjà connu.** `r="b3"` en minuscules, admis par décision, fait toujours lever à `openxlsx` 4.2.9 une erreur R brute (« missing value where TRUE/FALSE needed », A6), comme à la tête. Je n'ai rien changé à ce point.
