> *Rédigé par l'agent actuary (IA).*
>
> *Note de la session principale* : texte versé intégralement le 18/11/2026. Les scripts et sorties de la mesure, d'abord hors dépôt, sont versés sous `specification-594/` ; leurs md5 sont identiques à ceux que cite le texte (`gen.py` `8c96f9fc…`, `mesurer.R` `dd8c469b…`). Les précisions 10.1 et 10.2 sont portées dans `relecture-xml-1.0.md`, et le § 3.1 de XML 1.0 y est ajouté. Le texte est aussi publié en commentaire de #594.

## Spécification amendée de #594 (A1, étape 1b ; décision Q-68-4 (a) du 18/11/2026)

Fiche `actuary-approfondi`, lecture seule. Branche `claude/creneau-a1` : brief à `77c84ae`, tête à `9bba313` à la fin de la mesure (commits `7d91b73` et `9bba313`, 1c et 2a). `R/engine.R` est identique entre les deux SHA (`git diff --quiet`), donc la mesure vaut pour l'un comme pour l'autre. Aucun fichier du dépôt n'a été écrit (`git status` vide).

**Sources lues**
- Ma spécification du 18/11 (`issuecomment-6986469629`), #594 et ses trois commentaires.
- Mon avis Q-66-3, § 2 et § 5 ; l'ADR 0020 ; la fiche A1 (`docs/feuille-de-route.md`, étapes 1b, 5, 6 et 7).
- `mesure-594/README.md` et `md5.txt` (38 lignes, `md5sum -c` vérifié), triangle compris.
- La note 1c `docs/revues/20261118-a1-lecteur-interne/relecture-xml-1.0.md`.
- Dans `R/engine.R` : `.xlsx_controler_structure()` (règle `t_is`), `.xlsx_cellules()`, `.xml_textes()`, `.xlsx_blancs_entete()`, `.xlsx_controler_ligne_entete()`, `.xlsx_controler_contenus()`, `.xlsx_controler_references()`, `.xlsx_controler_partagees()` (grammaire du `<t>` de la table partagée), `.nettoyer_cellules()`, `.cellules_en_nombre()`, `.en_numerique()`, `.retirer_lignes_colonnes_vides()`, `engine_lire_donnees_csv()`, l'assemblage interne d'`engine_lire_xlsx()`, `TEXTE_REFUS_R3`.
- `tests/unitaires/test_controles_entree.R`, l. 2904, 3055-3075 et 4048-4080.
- L'appel d'`app.R` (l. 287).

**Mesure** (*vérifiée*)
- Conditions : Linux, R 4.3.3, `LC_ALL=C.UTF-8`. `openxlsx` est absent (`requireNamespace` vaut `FALSE`), donc c'est le lecteur interne qui lit, comme en production après #604. openpyxl 3.1.5 (lxml 6.1.3) et XlsxWriter 3.2.9.
- « Après » désigne un **prototype en mémoire** de la règle du § 1 : la seule ligne `t_is` de `.xlsx_controler_structure()`, remplacée dans l'environnement chargé par `charger_moteur()`. Ce n'est pas le code de l'étape 6.
- Scripts et sorties, d'abord hors dépôt (md5 des scripts : `gen.py` 8c96f9fc…, `mesurer.R` dd8c469b…) :
  - scripts : `gen.py`, `gen_tri.py`, `mesurer.R`, `mesurer_tri.R`, `mesurer_t.R` ;
  - sorties : `sortie.txt`, `sortie_tri.txt` et `sortie_t.txt`.
- La session peut les verser au dossier de 1a si elle le juge utile. *(Versés sous `specification-594/`.)*

---

### 0. Ce qui change par rapport à la spécification du 18/11

- **Abandonnés** :
  - la localisation (ligne 1, colonnes `t`, `xt`, `yt`, triangle) ;
  - l'argument `objet` d'`engine_lire_xlsx()` et la modification d'`app.R` ;
  - la règle placée après R9 et R10 ;
  - le motif nouveau ;
  - le refus des textes faits de seuls blancs ;
  - T6 et T8.
- Toutes ces bornes étaient motivées par la lecture fausse d'`openxlsx`. Elles tombent avec l'ADR 0020 (*vérifié*, lecture de mon avis Q-66-3, § 2 a et c).
- **Gardés** :
  - le refus des formes non exactes ;
  - le refus des références numériques (D-S1-18, D-S1-23) ;
  - toutes les autres règles de R3 (`<is>` sans attribut, un seul `<t>`, aucun texte autour, segment de cellule).

### 1. Règle d'admission

**Règle.** Dans le `<is>` d'une cellule, la balise `<t>` est admise si et seulement si elle s'écrit, à l'octet près, sous l'une de ces formes :
- **ouvrante** : `<t>` (inchangé) ou **`<t xml:space="preserve">`** (nouveau) ;
- **vide** : `<t/>`, avec des blancs admis avant `/>` (inchangé), ou exactement **`<t xml:space="preserve"/>`** (nouveau, sous réserve de A-2).

La règle est **uniforme** : elle ne dépend ni de la cellule, ni de la colonne, ni de l'objet lu (séries ou triangle), ni de l'argument `entete`.

**Restent refusées par R3**, motif inchangé à la réserve de A-3 près (*vérifié* par prototype, 13 formes forgées sur le classeur openpyxl) :
- blanc : `<t >`, `<t\t>`, `<t  xml:space="preserve">` (deux espaces), `<t xml:space="preserve" >` ;
- apostrophes : `<t xml:space='preserve'>` ;
- autre valeur : `xml:space="default"`, `xml:space="PRESERVE"` ;
- autre attribut : `space="preserve"`, `x:space="preserve"`, attribut supplémentaire (`<t xml:space="preserve" a="1">`) ;
- forme vide à blanc : `<t xml:space="preserve" />`.

**Restent refusées par le complément de R8** (D-S1-18, D-S1-23), appliqué au texte de la forme nouvelle : `&#32;` et `&#9;` (*vérifié*). Une référence hors de la liste refusée (`&#233;`) et l'entité `&amp;` sont admises et décodées (*vérifié* : « fén », « a&b »).

**Justification, sans recours à la parité**
1. **Le lecteur interne ne lit pas l'attribut.**
   - `.xml_textes()` extrait le contenu de `<t([ \t\r\n][^>]*)?>…</t>` tel quel, que l'attribut soit présent ou non (*vérifié*, lecture).
   - Le classeur openpyxl à note bordée de blancs, lu par le prototype, est `identical()` au même classeur dont la balise est réécrite `<t>`, forme déjà admise (*vérifié*).
   - L'attribut n'ajoute donc aucun risque de lecture. Le seul motif de D-S1-31, la lecture d'`openxlsx`, a disparu.
2. **Conforme à XML 1.0, § 2.10** (note 1c, citations *vérifiées* par la session) : le processeur transmet tous les caractères hors balisage, et `xml:space` ne fait que signaler une intention à l'application. Lire le texte tel quel respecte `preserve`. Les blancs ne sont interprétés qu'en aval, comme pour toute chaîne (§ 2).
3. **Uniforme avec la chaîne partagée.**
   - Une même fonction, `.xml_textes()`, lit `<si>` et `<is>`.
   - Mesure : lecture identique au bit près sur 14 situations et deux écrivains (§ 3).
4. **Pourquoi la seule forme exacte.**
   - C'est la forme qu'écrivent les écrivains connus : openpyxl avec et sans lxml, pandas par openpyxl, XlsxWriter `constant_memory` (*vérifié* : R-A, `mesure-594`, et ici).
   - Le contrat reste fermé : l'ADR 0020, point 2, interdit tout autre assouplissement, et le principe Q-68-4 vise la forme exacte.
   - Pour `default`, les apostrophes, `<t >` ou `x:space`, le refus ne repose **que** sur le contrat fermé : ces formes sont du XML légal, ou ne sont pas `xml:space` du tout (voir § 10).

### 2. Sémantique de lecture, par le seul lecteur interne

Tout est *vérifié* par mesure, sauf mention contraire.

**a. Nombre écrit en texte et bordé de blancs, dans une cellule lue** (` 104.2 ` en `xt`).
- Lecture :
  - la cellule est du texte, la colonne reste en caractères ;
  - `.en_numerique()` passe par `.nettoyer_cellules()`, qui retire les blancs ASCII de bord (espace, tabulation, CR, LF) ;
  - `.cellules_en_nombre()` lit ensuite 104,2.
- Mesuré :
  - ` 104.2 ` et `104.2\n` en `xt`, ` 1 ` en `t` : `ok = TRUE`, `xt` identique au CSV ;
  - le résultat est identique à celui de la chaîne partagée (XlsxWriter par défaut, déjà admise), à celui d'un CSV dont `xt` vaut ` 104.2 `, et à celui de `<t> 104.2 </t>` sans attribut, déjà admis.
- L'espace insécable n'est pas un blanc pour cette règle : ` 104.2` est refusé en aval (« valeurs … non numériques »), comme en chaîne partagée.
- **Justification actuarielle** : un blanc de bord ne porte aucune information numérique. La règle est celle, existante, du CSV et des chaînes partagées (#99) ; elle n'est pas créée ici.

**b. En-tête bordé de blancs** (`xt `).
- `.xlsx_blancs_entete()` retire les blancs `[[:space:]]` de la locale : `xt `, ` t ` et `yt\t` sont lus `xt`, `t`, `yt`, avec `ok = TRUE`, comme en chaîne partagée.
- La divergence avec le CSV, qui refuse `xt `, est inchangée (décision D3, documentée).

**c. Texte fait de seuls blancs** (` `, tabulation, trois blancs). Le texte est lu tel quel, puis :
- **dans une colonne non lue**, la cellule est vide pour `.retirer_lignes_colonnes_vides()` ;
- **en `xt`**, il vaut `NA` et le classeur est refusé « Certaines valeurs … ne sont pas numériques (colonne xt : ligne(s) de données 1) » ;
- **en en-tête**, il ne porte pas de valeur : la colonne est nommée `V<k>` ; une ligne 1 faite seulement de blancs reçoit `MOTIF_LIGNE1_VIDE` (R12, comme le test l. 3063 pour la chaîne partagée).

Dans les trois cas, le résultat est identique à la chaîne partagée. Il est aussi aligné sur openpyxl sans lxml, qui écrit `<t> </t>`, déjà lu : sur le corpus, les classeurs `blancs/classeurs/` (avec lxml), lus par le prototype, donnent la même sortie aval (`ok`, `n = 8`, `xt` et `yt` égaux au CSV) que `blancs/classeurs_sans_lxml/`, lus aujourd'hui.

**Conséquence.** Une ligne finale qui ne porte qu'une note blanche est écartée comme vide, sans avertissement (`n = 8`).
- C'est le comportement actuel sans lxml et en chaîne partagée.
- Il est conforme à la règle des lignes vides de fin (`.retirer_lignes_colonnes_vides()`, décisions 5 et 6 du 12/11), et aucune valeur n'est perdue. Voir A-4.

**d. Forme vide `<t xml:space="preserve"/>`.**
- Lue `""`, `identical()` à `<t/>` lu aujourd'hui et à `<t xml:space="preserve"></t>`, que la règle du § 1 admet de toute façon puisque l'ouvrante est exacte.
- Cette lecture repose sur le fait que `is_contenu` est borné à la cellule et ne contient qu'un `<t>` (R3) : la recherche de `</t>` ne déborde pas (*vérifié* par lecture et par mesure).

**e. Triangle.** Même règle, sans distinction d'objet.
- ` 962.71 ` en chaîne en ligne est lu 962,71 ; le triangle est `identical()` à celui de XlsxWriter par défaut et à celui du CSV.
- Le triangle openpyxl à colonne `note` bordée de blancs n'est plus refusé en R3. Il est lu, puis refusé en aval « Cellule(s) non numérique(s) en (i = 0, j = 8)… », avec une sortie d'`engine_lire_triangle()` `identical()` à celle de son témoin sans blancs.

**f. Fins de ligne.**
- Aujourd'hui, `\r\n` littéral est lu `\r\n` sous l'attribut comme sans lui (*vérifié*, forme forgée).
- La normalisation de #602 (étape 3b, avant l'étape 6) s'applique uniformément. #594 n'ajoute aucune règle, mais ses tests ne doivent pas supposer `\r\n` conservé.

### 3. Critère d'acceptation tiré de l'hypothèse de Q-66-3, § 2 c : **mesuré, tenu**

**C1.** Pour chaque situation, la chaîne en ligne `<t xml:space="preserve">` lue par la règle amendée (openpyxl, XlsxWriter `constant_memory`) donne :
- un `data.frame` rendu par `engine_lire_xlsx()`,
- et une sortie complète d'`engine_lire_donnees_csv()`,

`identical()` à ceux de la chaîne partagée `<si><t xml:space="preserve">` (XlsxWriter par défaut) lue par le moteur actuel.

**Mesure : 28 sur 28 TRUE**, sur 14 situations × 2 écrivains :
- note bordée ;
- en-têtes `xt `, ` t `, `yt\t`, en-tête de note blanc ;
- `xt` : ` 104.2 `, `104.2\n`, `104.2` sans blanc, insécable, ` ` ;
- `t` : ` 1 ` ;
- note ` ` ;
- ligne finale à note blanche, puis à note non blanche.

**C2.** Même critère pour le triangle (`engine_lire_triangle()`) : tenu (§ 2 e).

**C3.** La forme à attribut est lue comme la forme sans attribut : tenu (§ 1, justification 1).

L'*hypothèse* de mon avis Q-66-3 devient **vérifiée** sur ces situations, sous `C.UTF-8`. Sous la locale Windows, les blancs d'en-tête dépendent de `[[:space:]]` : c'est la limite déjà consignée, *non vérifiée* ici, et elle vaut à l'identique pour la chaîne partagée.

### 4. Tests

Le témoin `openxlsx` est hors de ces tests (ADR 0020, point 3), sauf T15.

| Test | Sort | Contenu et motif |
|---|---|---|
| T1 Formes openpyxl acceptées | **repris, modifié** | Lu dans tous les modes (`entete = TRUE` / `FALSE`, séries et triangle). Sans argument `objet`, qui disparaît. `t`, `xt` et `yt` égaux à la source CSV ; sortie `identical()` à la variante en chaîne partagée. |
| T2 En-tête bordé refusé | **renversé** | `<t xml:space="preserve">xt </t>` en B1 est lu `xt`, `identical()` à `<si><t xml:space="preserve">xt </t></si>`. Motif : § 2 b. |
| T3 Colonnes lues refusées | **renversé** | ` 104.2 ` en `xt` lu 104,2, ` 1 ` en `t` lu 1. ` 104.2` est refusé en aval, comme en chaîne partagée. Motif : § 2 a. |
| T4 Textes vides ou blancs refusés | **modifié** | `" "`, `"\t"`, `""` et `<t xml:space="preserve"/>` sont admis. Dans une note : ligne vide. En `xt` : refus « non numériques », identique à la chaîne partagée. En en-tête : `V<k>` ; ligne 1 toute blanche : `MOTIF_LIGNE1_VIDE`. Motif : § 2 c et d. |
| T5 Formes non exactes | **repris** | La liste du § 1 (13 formes), refus R3, position « balise <t>, dans la chaine en ligne de la cellule … », en valeur et en en-tête. Un seul chemin. Texte du motif selon A-3. |
| T6 Limite consignée (openxlsx) | **retiré** | Sans objet en production (ADR 0020). Remplacé par une valeur attendue explicite : la note est lue avec ses blancs (T11, T12). |
| T7 Ligne finale | **modifié** | Un seul chemin. Note non blanche (S8b) : refus en aval « non numériques … ligne 9 » et « Colonne t … », identique à la chaîne partagée. Note blanche (S8) : `n = 8`, sans avertissement, identique à la chaîne partagée. |
| T8 Application | **retiré** | `app.R` n'est pas touché, aucun argument (§ 9). Remplacé par l'assertion « `formals(engine_lire_xlsx)` inchangé » de T9. |
| T9 Non-régression | **repris, modifié** | Test l. 4058 : `<t xml:space="preserve">11.5</t>` et `<t xml:space="preserve"/>` passent aux témoins admis de l. 4067 ; les autres formes restent refusées. Test l. 4063 : `<t xml:space="preserve">xt</t>` passe aux témoins admis ; `<t >xt</t>` reste refusé. Les tests de la table partagée (l. 2972, 3063-3070, 3286-3291, 4365-4388) restent inchangés. `formals(engine_lire_xlsx)` reste `(chemin, entete = TRUE)`. |
| T10 Reproductibilité | **repris** | Six cas au seuil 0, volet `identical()`, `concordance_doc_moteur.R --strict` à 0. Références inchangées attendues : le lecteur est hors du chemin des références. |
| **T11 Corpus** (nouveau) | | Les 13 classeurs du § 8, depuis `tests/donnees/classeurs/` (copie de l'étape 2a, md5 identiques) : valeurs attendues explicites tirées du CSV source. Accord avec la source **bloquant**. Les 25 autres restent lus avec les mêmes valeurs. |
| **T12 Uniformité** (nouveau) | | C1 sur XML forgé, par paires en ligne / partagée : en-tête `xt `, valeur ` 104.2 `, note bordée, seuls blancs, forme vide. `identical()` sur le retour d'`engine_lire_xlsx()` et sur celui d'`engine_lire_donnees_csv()`. |
| **T13 Références sous la forme nouvelle** (nouveau) | | `&#32;` et `&#9;` refusés (`TEXTE_REFUS_REFERENCE_NUMERIQUE`) ; `&#233;` et `&amp;` admis et décodés. |
| **T14 Triangle** (nouveau) | | ` 962.71 ` en chaîne en ligne : triangle `identical()` à celui de la chaîne partagée et du CSV. La colonne `note` bordée donne la même sortie d'`engine_lire_triangle()` que son témoin. |
| **T15 Témoin** (nouveau, étape 6 de la fiche) | | Liste fermée des écarts attendus du témoin, mise à jour pour les 13 classeurs. L'écart attendu sous 4.2.5.2 est *non vérifié* ici, `openxlsx` étant absent : note préfixée pour les 12 séries, en-tête mal lu pour `openpyxl_entete_lu_blanc`, neuvième ligne préfixée pour `ligne_finale`. À mesurer par `coder-approfondi` dans une bibliothèque de session (précédent S4). |

### 5. Motifs de refus restants

- **R3** (`TEXTE_REFUS_R3`) : les formes non exactes du § 1, avec une position inchangée.
- **Complément de R8** (`TEXTE_REFUS_REFERENCE_NUMERIQUE`) : les références numériques dans le texte de la forme nouvelle.
- **Segment de cellule** (`TEXTE_REFUS_SEGMENT`) : inchangé. La suite `<is><t` reconnaît la forme nouvelle, et toutes les formes admises de la mesure passent ce contrôle (*vérifié*).
- **En aval** : « non numériques », « Colonne(s) manquante(s) », `MOTIF_LIGNE1_VIDE`, « Cellule(s) non numérique(s) » du triangle, exactement comme pour la chaîne partagée.
- **Aucun motif nouveau.**

### 6. Avis sur la reprise de `TEXTE_REFUS_R3` (Q-68-2 (a)) : **reprise recommandée**

**Motif**
- Après l'amendement, les refus de `<t>` par R3 sont *exactement* les formes non exactes : blanc, apostrophes, autre valeur, attribut en plus. Aucune n'est « non prévue », « mal imbriquée » ou « à préfixe d'espace de noms » au sens strict (constat H1 de S1, relevé deux fois).
- Le défaut cesse d'être marginal : il touche désormais la totalité des refus de `<t>`.
- Le même libellé sert aussi pour `<is a="1">` et pour les balises mal formées (`forme_o`, `forme_f`), qu'il ne décrit pas non plus (*vérifié*, lecture de la règle).

**Texte proposé** (seul changement : la quatrième qualification) :

> `Classeur illisible : le bloc des donnees de la feuille lue (<sheetData>) contient une balise non prevue, mal imbriquee, a prefixe d'espace de noms ou ecrite sous une forme que l'outil n'admet pas (%s) ; l'outil ne lit pas cette forme de facon sure (une valeur pourrait etre mal lue). Enregistrer de nouveau le classeur depuis un tableur.`

**Surface**
- La constante (l. 10241).
- Le gabarit `texte574r3` de `test_controles_entree.R` (l. 2904, une définition, 23 emplois).
- Le `.tex` ne cite que le nom de la constante (l. 1075 et 5304 ; *vérifié*, `grep`) : `docwriter` contrôle qu'aucune paraphrase ne subsiste.
- C'est un changement de texte de refus, hors références, à porter au tableau avant / après de l'étape 6.

### 7. Surface documentaire

**`.tex`**, au passage unique de `docwriter` (étape 7), fondu dans la réécriture de #604 :
- `sec:controles`, l. 5188-5197 : retirer la chaîne en ligne bordée de blancs de la liste des formes produites par un outil et refusées ; dire qu'elle est admise.
- l. 5319-5333 : la règle R3 du `<t>` devient les deux formes exactes et leurs formes vides. Elle se fonde sur XML 1.0, § 2.10 (citation de la note 1c) et sur le contrat fermé. La justification par la lecture d'`openxlsx` en sort et part dans `docs/suivi-documentation/I.md`, comme motif daté.
- Une phrase de sémantique : valeurs (`.nettoyer_cellules()`, blancs ASCII), en-têtes (`.xlsx_blancs_entete()`), seuls blancs, forme vide, identiques à la chaîne partagée.
- La limite d'uniformité (A-5).
- Le motif R3, selon A-3.
- La vie du dépôt dans `docs/suivi-documentation/I.md` : D-S1-31 levée, E-18/11 (#594) rouverte, Q-68-4.
- Index : aucune fonction nouvelle, aucun argument.

**README** : aucune modification attendue pour #594 (`grep` : 0 occurrence de `xml:space` ni d'`openpyxl`).

**Commentaires d'`engine.R`** :
- en-tête de R3 (l. 10267-10271) et commentaire de `t_is` (l. 10393-10401) ;
- en-tête d'`engine_lire_xlsx()` (l. 11500-11503) ;
- l'en-tête d'`.xlsx_admettre()`, s'il cite D-S1-31.

**Commentaires des tests** : l. 3060-3061 et 4051-4056.

### 8. Tableau avant / après attendu sur le corpus du témoin (38 classeurs de `mesure-594/`)

Prototype, *vérifié*. Les chemins sont relatifs à `mesure-594/` ; la copie de 2a est dans `tests/donnees/classeurs/`.

**13 classeurs changent** (refus R3 → lus) :

| Classeur | Après : `engine_lire_xlsx()` | `t`, `xt`, `yt` (contre `donnees_ln.csv`) | Remarque |
|---|---|---|---|
| `blancs/classeurs_sans_lxml/note_bordee_blancs.xlsx` | lu, 8 lignes | identiques ; `ok = TRUE`, `n = 8`, sans avertissement | note lue avec ses blancs |
| `blancs/classeurs/ligne_finale_note_blanche.xlsx` | lu, 9 lignes | identiques sur les lignes 1 à 8 ; `ok = TRUE`, `n = 8`, sans avertissement | 9e ligne (note ` `) écartée comme vide |
| `blancs/classeurs/note_tab.xlsx` | lu | identiques ; `ok = TRUE` | note `"\t"` |
| `blancs/classeurs/note_trois_blancs.xlsx` | lu | identiques ; `ok = TRUE` | note `"   "` |
| `blancs/classeurs/note_un_blanc.xlsx` | lu | identiques ; `ok = TRUE` | note `" "` |
| `classeurs/openpyxl_blancs.xlsx` | lu | identiques ; `ok = TRUE` | note lue avec ses blancs |
| `classeurs/pandas_blancs.xlsx` | lu | identiques ; `ok = TRUE` | idem |
| `classeurs/xlsxwriter_constant_memory_blancs.xlsx` | lu | identiques ; `ok = TRUE` | idem |
| `entete/openpyxl_entete_lu_blanc.xlsx` | lu | identiques ; `ok = TRUE` | en-tête `xt ` lu `xt` |
| `poste-windows/classeurs/openpyxl_series_blancs.xlsx` | lu | identiques ; `ok = TRUE` | note lue avec ses blancs |
| `poste-windows/classeurs/pandas-openpyxl_series_blancs.xlsx` | lu | identiques ; `ok = TRUE` | idem |
| `poste-windows/classeurs/xlsxwriter-constant_memory_series_blancs.xlsx` | lu | identiques ; `ok = TRUE` | idem |
| `triangle/classeurs/openpyxl_triangle_note_blancs.xlsx` | lu | sans objet | `engine_lire_triangle()` : `ok = FALSE`, « Cellule(s) non numerique(s) en (i = 0, j = 8)… et 3 autre(s) », sortie `identical()` à celle du témoin `_note_temoin` |

**Les 25 autres** sont inchangés : `data.frame` `identical()` avant et après, verdicts aval inchangés.

**Effet**
- Aucun σ_USP, aucun verdict ni aucune p-value des six cas.
- Pour un classeur jusque-là refusé, le calcul devient possible, sur des `xt` et `yt` identiques au bit près à ceux du CSV source.
- Le triangle change de motif de refus (R3 → aval), sans changer de verdict de lecture.
- Changement de résultat hors références : visa du mainteneur (ADR 0020, point 2).

### 9. Argument nouveau ou modification d'`app.R` : **non**

- Le prototype ne change que la ligne `t_is`. Toutes les lectures passent par `engine_lire_xlsx(f)` avec ses défauts.
- `app.R` appelle `engine_lire_xlsx(chemin)` (l. 287) (*vérifié*).
- `app-review` ne revient donc pas au circuit.

### 10. Lecture d'`actuary` de la note XML 1.0 (étape 1c)

Points 1, 2 et 4, et point 3 en ses deux premières puces : **d'accord**. Trois précisions, sans contester les citations :

1. **Point 3, dernière puce : à borner.**
   - La clause du § 2.10 sur les valeurs erronées ne vise que les valeurs autres que `default` et `preserve`. Elle fonde le refus de `xml:space="PRESERVE"` ou d'une autre valeur.
   - Elle ne fonde pas le refus de `xml:space="default"` (valeur légale), des apostrophes (même attribut, même valeur), de `<t >` (aucun attribut), ni de `space=` ou `x:space=`, qui ne sont pas `xml:space`.
   - Ces refus reposent sur le **contrat fermé** (ADR 0020, point 2 ; Q-68-4), non sur XML 1.0. La note doit le dire, sous peine d'une affirmation trop large dans le dossier.
2. **Point 1, dernière puce.** La conclusion (`&#xD;` reste #xD) est juste. Mais la citation du § 3.3.3 porte sur les valeurs d'attribut. Pour le contenu d'un `<t>`, la conclusion découle du § 2.11 (« on input, before parsing »). À préciser avant toute citation dans le `.tex`.
3. **Non relu ici.** Le § 3.1 (balise vide équivalente à une ouvrante suivie d'une fermante) n'est pas dans la note, et `www.w3.org` est injoignable depuis ma session (`WebFetch` : `ENOTFOUND` ; le domaine doit être autorisé). L'argument de A-2 ne repose pas sur lui (mesure du § 2 d). Si `docwriter` veut invoquer cette équivalence, il faut l'ajouter à la note.

---

### Questions de l'arrêt A

**A-1 — Règle d'admission.**
- **(a) recommandé** : retenir la spécification amendée, soit l'admission uniforme des seules formes exactes `<t xml:space="preserve">` (et de sa forme vide, A-2) en chaîne en ligne, sans argument ni modification d'`app.R`.
- Écartées :
  - **(b)** l'option bornée du 18/11 : ses bornes ne se justifiaient que par la parité, et elle crée un contrat partagé ;
  - **(c)** le maintien de D-S1-31 entière, avec fermeture `not planned` : sa prémisse est tombée, et elle refuse 13 classeurs du corpus lus juste ;
  - **(d)** l'admission de toute forme bien formée de `<t>`, comme dans la table partagée (`default`, apostrophes, `<t >`) : la lecture serait identique, mais c'est au-delà du principe Q-68-4 et sans écrivain connu.

**A-2 — Forme vide `<t xml:space="preserve"/>`.**
- **(a) recommandé** : l'admettre exactement. Elle est lue `""`, comme `<t/>` et comme `<t xml:space="preserve"></t>`, que la règle admet de toute façon. La refuser serait incohérent.
- Écartées :
  - **(b)** la refuser : forme jugée sur son seul aspect, alors que son équivalent en ouvrante et fermante passe ;
  - **(c)** l'admettre aussi avec des blancs avant `/>` : au-delà de la forme exacte, sans écrivain connu.

**A-3 — `TEXTE_REFUS_R3`.**
- **(a) recommandé** : reprise dans le commit `moteur:` de #594, avec le texte du § 6.
- Écartées :
  - **(b)** maintenu écarté : l'amendement fait de ce libellé le motif de *tous* les refus de `<t>`, qu'il ne décrit pas ;
  - **(c)** un motif dédié aux formes de `<t>` : constante de plus, sans gain pour l'utilisateur ;
  - **(d)** aligner aussi `TEXTE_REFUS_R9`, qui a le même libellé : hors de Q-68-2, mineur (constats hors périmètre).

**A-4 — Ligne finale qui ne porte qu'un texte fait de blancs.**
- **(a) recommandé** : aucun changement dans #594. Le comportement est consigné : ligne écartée comme vide, sans avertissement. Il est identique aujourd'hui sans lxml et en chaîne partagée, aligné sur le CSV, et aucune valeur n'est perdue.
- Écartées :
  - **(b)** un avertissement de lecture : changement de `.retirer_lignes_colonnes_vides()` hors du périmètre de #594 ;
  - **(c)** un refus : contraire aux décisions 5 et 6 du 12/11.

**A-5 — Limite d'uniformité avec la table partagée.**
- **(a) recommandé** : consigner au `.tex` que la table partagée admet toute forme bien formée de `<t>` (grammaire `XML_GRAMMAIRE_OUVRANTE`), alors que la chaîne en ligne n'en admet que deux exactes. Les deux sont lues de même, texte tel quel.
- Écartée :
  - **(b)** restreindre la table partagée : ce serait refuser des classeurs lus aujourd'hui ; changement de résultat hors du périmètre d'A1.

---

### Retour

- **Statut** : `complet`. Spécification rendue. Critère C1 mesuré (28 sur 28) et tableau avant / après mesuré sur les 38 classeurs, par le lecteur interne et un prototype en mémoire.
- **Résultat** : spécification amendée (§ 0 à 10) ; reprise de `TEXTE_REFUS_R3` recommandée ; aucun argument nouveau ni modification d'`app.R` ; questions A-1 à A-5.
- **Preuves**
  - *Vérifiées* :
    - lecture du code (lignes citées) ;
    - mesures des sorties `sortie.txt`, `sortie_tri.txt` et `sortie_t.txt` ;
    - intégrité du corpus (`md5sum -c`) ;
    - `R/engine.R` identique entre `77c84ae` et `9bba313` ;
    - citations XML 1.0 reprises de la note 1c (relues par la session, non par moi).
  - *Hypothèse* : le prototype en mémoire (une ligne) représente la règle à coder ; `coder-approfondi` doit retrouver le même tableau.
  - *Non vérifiés* : écarts du témoin `openxlsx` 4.2.5.2 sur les 13 classeurs (T15, étape 6) ; blancs d'en-tête sous la locale Windows (limite existante) ; XML 1.0, § 3.1 ; écriture d'Excel et de LibreOffice (étape 10a).
- **Informations manquantes** : `www.w3.org` injoignable depuis ma session (`WebFetch` : `ENOTFOUND`) ; `openxlsx` absent (voulu).
- **Décisions non résolues** : A-1 à A-5, par le mainteneur à l'arrêt A ; visa du tableau à l'étape 6.
- **Critères déclenchés** (`docs/agents/routage.md`, § 4.2 et § 4.4) :
  - **résultat changé** hors références : 13 classeurs refusés deviennent lus, et le motif R3 change si A-3 est retenue ; aucun σ_USP ni verdict des six cas ;
  - **décision du mainteneur remplacée** (D-S1-31, E-18/11 (#594)), par changement de prémisse ;
  - pas de contrat partagé modifié : signature d'`engine_lire_xlsx()` inchangée, `app.R` non touché ;
  - § 4.4, précision sur la portée d'une source : la note 1c, point 3, étend la clause des valeurs erronées au-delà de son texte (§ 10.1). Ce n'est pas une double lecture de XML 1.0, mais une phrase de la note à borner.
- **Constats hors périmètre** (ADR 0018) :
  1. Asymétrie table partagée / chaîne en ligne (A-5) : critère **aucun**. Lecture identique, texte tel quel (*vérifié*, lecture de `.xml_textes()` et de la grammaire de R9).
  2. `TEXTE_REFUS_R9`, même libellé imprécis : **aucun**, mineur.
  3. Ligne finale blanche écartée sans avertissement (A-4) : **aucun**. Comportement antérieur, aucune valeur perdue (*vérifié*).
  4. Nombre écrit en texte lu comme nombre (un tableur le garderait en texte : *non vérifié*) : **aucun**. Règle existante du CSV et des chaînes partagées, inchangée par #594.
- **Prochaine action recommandée** : publication en commentaire de #594 et versement dans `docs/revues/20261118-a1-lecteur-interne/` par la session ; correction de la note 1c sur les points 10.1 et 10.2 avant toute citation au `.tex` ; arrêt A (A-1 à A-5) ; puis étape 6 (`coder-approfondi`, `high`), avec les tests T1 à T15 et le tableau du § 8.
