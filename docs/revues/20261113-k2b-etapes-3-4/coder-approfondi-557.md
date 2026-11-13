## Compte rendu de `coder-approfondi` : K2b, étape 4, #557 (lecteur xlsx)

Le lecteur xlsx est corrigé et testé. Toutes les batteries sont vertes et les références ne changent pas (0 écart à `--seuil 0`). **Un constat nouveau doit être porté à `actuary` avant tout commit** : `openxlsx` lit une valeur fausse sans message dans le corps du tableau (question Q1 ci-dessous). Ce défaut existait déjà et mes modifications ne l'aggravent pas.

Rien n'est commité, poussé, régénéré ni patché, et aucune issue n'est créée. `docs/latex/` n'est pas touché. `git status --short` ne montre que deux fichiers : ` M R/engine.R` et ` M tests/unitaires/test_controles_entree.R`.

Toutes les mesures sont dans `<scratchpad>/coder557/`. On y trouve les scripts `mesure.R`, `mesure2.R`, `mesure3.R`, `mesure4.R`, `mesure_r.R` et les sorties `avant_*.txt`, `apres_*.txt`, `enrichie_*.txt`, `tu_*.txt`, `tce_*.txt`, `repro.txt`, `compref.txt`. Le « avant » est calculé sur `git show HEAD:R/engine.R`, chargé par `charger_moteur(<fichier>)`. Les deux versions d'`openxlsx` ont été mesurées : 4.2.9 (bibliothèque `lib`) et 4.2.5.2 (`lib_old` puis `lib`).

### Fichiers modifiés

**`/home/user/outil_usp/R/engine.R`** (code de deux fonctions, commentaires de quatre endroits)
- **`.xml_textes()`** : la fonction retire les balises `<rPh…>…</rPh>` avant de lire les `<t>` (`gsub("<rPh([ \t\r\n][^>]*)?>.*?</rPh>", "", x)`). Le commentaire du § 3b est repris mot pour mot. Il est complété par la mesure du corps : NA sur les deux versions d'`openxlsx`, puis refus en aval.
- **`.xlsx_controler_cellules()`** : un contrôle est ajouté après celui de la cellule sans `r`, dont le texte ne change pas.
  - Il lit `refs <- vapply(balises, .xlsx_attribut, "", nom = "r", local = FALSE)`, c'est-à-dire la même règle que `.xlsx_cellules()`.
  - Il refuse si `is.na(refs) | !grepl("^[A-Za-z]+[1-9][0-9]*$", refs)`.
  - Le texte du refus est celui du § 2, mot pour mot, dans la classe `usp_refus_lecture`.
- **En-tête d'`engine_lire_xlsx()`** :
  - texte du § 3 (chaîne en ligne enrichie) et texte du § 1 (`t="str"`), mot pour mot ;
  - un paragraphe sur `<rPh>` et la chaîne partagée enrichie (voir Q1) ;
  - le refus des références mal formées ;
  - les blancs d'en-tête sous Windows, consignés comme limite (décision 5).
- **Commentaires de `.refus_lecture()` et du paragraphe des refus** : le nouveau refus y est ajouté.

Les textes fixés ont été contrôlés par un script qui cherche chaque bloc de code de l'avis dans `engine.R` : les blocs 0 à 3 (#557) y sont tous, mot pour mot. Le bloc 4 est le texte de MW-04 (#540), hors de cette étape.

**`/home/user/outil_usp/tests/unitaires/test_controles_entree.R`** : 12 assertions ajoutées à la fin du bloc xlsx, avec les outils `classeur487`, `chemins483` et `tous487`. Dix tournent toujours et deux seulement quand `openxlsx` est installé.
- Références refusées sur chaque chemin, au texte fixe : `r=""`, `"1"`, `"A0"`, `"1A"`, `" A2 "`, `"A"`, `"A1:B2"`, puis `<c r="" s="1"/>` et un en-tête `<c r="">`.
- Une cellule sans `r` et un `r="1"` dans la même feuille donnent le refus « sans r » : l'ordre des contrôles est respecté.
- Le refus est bien de la classe `usp_refus_lecture`.
- Sont admis : `r="a2"`, `XFD1048576` et `<c x:r="Z9" r="A2">`. Est refusé : `<c x:r="A2" r="0">`.
- Fonction `.xml_textes()` seule : chaîne simple, chaîne enrichie, plusieurs `<rPh>`, et `"11"` suivi du phonétique `"7"`.
- Chaîne partagée avec `<rPh>`, en en-tête et dans le corps : lecture identique sur les deux chemins.
- Chaîne en ligne avec `<rPh>` sur le lecteur interne : `xt` et `abc`. Limite figée côté `openxlsx` : nom `X2` et cellule NA.
- Chaîne partagée enrichie avec `<rPh>` : `xt` sur le lecteur interne. Limite figée côté `openxlsx` : `x`.
- Cellules `t="str"` : lecture brute, entités non décodées, en en-tête et dans le corps. La parité est vérifiée par `identical(interne, openxlsx)`.

### Vérifications (toutes sous `LC_ALL=C.UTF-8`)

| Commande | Résultat |
|---|---|
| `source("R/charger_moteur.R"); charger_moteur()` | « charge ok » |
| `Rscript tests/test_unitaires.R --parallele` sans `openxlsx` | `TOTAL : 3781 assertions, 3781 ok, 0 echec(s)` (lignes « [saute] » `openxlsx`/`zip` attendues) |
| idem avec `R_LIBS=<lib>` (4.2.9) | `TOTAL : 3796 assertions, 3796 ok, 0 echec(s)`, aucune ligne « [saute] » |
| `tests/unitaires/test_controles_entree.R` seul | sans `openxlsx` : 401/401 ; avec 4.2.9 : 415/415 ; avec 4.2.5.2 : 415/415 (403 avant, plus 12) ; relancé avec 4.2.9 après les dernières retouches de commentaires : 415/415 |
| `Rscript tests/test_reproductibilite.R` | « OK : reproductibilite et non-regression verifiees pour 6 cas. » |
| `Rscript tests/comparer_references.R --seuil 0` | 6 cas « CONFORME … 0 non strictement identique(s) … ecart maximal 0.000e+00 » |
| `Rscript tests/concordance_doc_moteur.R --strict` | « BILAN : 0 ecart(s) (mode strict) », aussi après les retouches finales |

La batterie complète a tourné avant les dernières retouches, qui ne portent que sur des commentaires. Ont été relancés ensuite : le chargement, la concordance, `test_empreinte_moteur.R` (20/20) et `test_controles_entree.R` avec 4.2.9 (415/415).

### Tableau avant / après des comportements hors références

Données : feuille t / xt / yt, cellule mise à l'essai en B2 (valeur 1.5). Sorties `avant_r.txt` et `apres_r.txt`. Pour les références de cellule, 4.2.9 et 4.2.5.2 donnent la même chose.

**§ 1.3 du rejeu : références de cellule**

| Forme | Interne avant | `openxlsx` avant | Interne après | `openxlsx` après |
|---|---|---|---|---|
| `r=""` (corps) | erreur R `invalid 'nrow' value` | erreur R `missing value where TRUE/FALSE needed` | refus #557 | refus #557 |
| `<c r="" t="s">` (en-tête) | erreur R | erreur R | refus #557 | refus #557 |
| `r=""` sur toutes les cellules | refus « ligne 1 » (#522) | refus « ligne 1 » | refus #557 (contrôle placé avant) | refus #557 |
| `<c r="" s="1"/>` (ligne 4) | erreur R | **lu** | refus #557 | **refus #557** (accepté devient refusé) |
| `r="1"` | lu, xt = (NA, 2), avertissements R (valeurs déplacées) | lu, xt = (NA, 3) (valeur perdue) | refus #557 | refus #557 |
| `r="A0"` | lu, xt = (NA, 2), avertissements | lu, xt = (NA, 3, NA) (ligne NA ajoutée) | refus #557 | refus #557 |
| `r="1A"`, `r=" A2 "` | erreur R | lu, xt = (NA, 3) (valeur perdue) | refus #557 | refus #557 |
| `r="A"`, `r="A1:B2"` | erreur R | erreur R | refus #557 | refus #557 |
| `r="a2"` (minuscules) | lu | erreur R | inchangé | inchangé |
| `<row r="">` avec cellules valides | lu | lu | inchangé | inchangé |
| cellule sans `r` (témoin) ; `r='B2'` | refus « sans r » | refus « sans r » | inchangé, octet pour octet | inchangé |
| `<c x:r="Z9" r="B2">` | lu en B2 | valeur en Z9 | inchangé | inchangé |
| `r="&#66;2"` (voir Q3) | lu en B2 | erreur R | inchangé | inchangé |

**§ 1.2 du rejeu : `<rPh>`** (4.2.9 et 4.2.5.2 identiques ; sorties `avant_rph*.txt` et `apres_rph*.txt`)

| Cas | Interne avant | Interne après | `openxlsx` (inchangé) |
|---|---|---|---|
| chaîne partagée en en-tête `xt` + `rPh` « ZZ » | nom `xtZZ` (refusé en aval) | `xt` (accepté) | `xt` |
| chaîne partagée dans le corps `abc` + `rPh` | `abcZZ` | `abc` | `abc` |
| chaîne partagée dans le corps, nombre `11` + `rPh` « 7 » (série) | **`117`, accepté (valeur fausse)** | `11` | `11` |
| chaîne en ligne en en-tête `xt` + `rPh` | `xtZZ` | `xt` | nom `X2` (limite) |
| chaîne en ligne dans le corps `abc` + `rPh` | `abcZZ` | `abc` | `NA` (limite) |
| chaîne en ligne dans le corps, nombre `11` + `rPh` « 7 » (série) | **`117`, accepté** | `11`, accepté | `NA`, refus aval « Certaines valeurs des colonnes xt ou yt ne sont pas numeriques (colonne xt : ligne(s) de donnees 2). » |
| idem dans un triangle (i = 1, j = 3) | `170`+`7` | `170`, accepté | `NA`, refus aval « Cellule observee manquante : annee d'accident i = 1, annee de developpement j = 3. » |
| chaîne partagée enrichie `x`,`t` + `rPh` (en-tête) | `xtZZ` | `xt` | `x` (limite propre à `openxlsx`, figée) |
| `<phoneticPr>` seul | `xt` | `xt` | `xt` |

**§ 1.1 du rejeu : `t="str"`.** Aucun comportement ne change. Le test de parité fige la lecture brute sur les deux chemins : en-tête `a&amp;b`, `y&#233;`, corps `"1.5"`, `"3"` et `x&lt;y`, avec `identical(interne, openxlsx)` vrai sous 4.2.9 comme sous 4.2.5.2.

**Condition du § 3b d'`actuary`** : mesurée et non déclenchée. Dans le corps, une chaîne en ligne avec `rPh` est rendue `NA` par `openxlsx`. Ce n'est pas un nombre différent de la cellule, et la cellule est refusée en aval, en série comme en triangle. La chaîne en ligne avec `rPh` est donc consignée comme limite.

### Questions pour `actuary` (à porter avant tout commit)

- **Q1, de fond.** La cause de « chaîne partagée enrichie avec `rPh` rendue `x` » n'est pas `rPh`. `openxlsx` (4.2.9 et 4.2.5.2) ne lit que le premier segment `<r>` d'une chaîne partagée enrichie **quand aucune chaîne de la table ne porte `<rPr>`**, avec ou sans `rPh`.
  - Mesure (`mesure3.R`, `mesure4.R`) : `<r><t>1</t></r><r><t>1.5</t></r>` est lu `"1"` dans le corps. Si une autre `<si>` de la table porte `<rPr>`, il est lu `"11.5"`.
  - De bout en bout (`mesure2.R`) : série avec cette cellule en xt de l'année 2. `openxlsx` donne `ok = TRUE ; xt = c(10, 1, 12, 13, 14)` et le lecteur interne `xt = c(10, 11.5, …)`. **C'est une valeur fausse acceptée sans message sur le chemin `openxlsx`.**
  - Le motif du § 3a (« un nom tronqué ne devient pas un nom attendu ») ne couvre donc pas le corps. Un en-tête pourrait d'ailleurs devenir un nom attendu, par exemple `xt` + `2` lu `xt` : ce cas n'a pas été mesuré.
  - J'ai implémenté la consigne (limite figée en en-tête) et écrit la mesure du corps dans le commentaire. Je n'ai pas fait de refus, qui n'est pas décidé.
  - Un tableur n'écrit probablement pas de segments sans aucun `<rPr>` [H, non mesuré].
  - À trancher : limite consignée, ou refus motivé d'une table de chaînes partagées qui contient des `<r>` sans aucun `<rPr>`. Le refus ferait de nouveaux refus de fichiers aujourd'hui acceptés, donc il faut une décision du mainteneur.
- **Q2.** L'interne lisait auparavant `"11"` + phonétique `"7"` comme **117**, valeur fausse acceptée (chaîne partagée comme chaîne en ligne). Le correctif 3a la supprime. C'est donc un changement de valeur lue, dans le bon sens, plus fort que ne le disait l'avis (« sans effet sur un calcul [H] »).
- **Q3.** `.xlsx_attribut()` décode les entités et admet les apostrophes. Conséquences :
  - `r="&#66;2"` est admis par le contrôle et lu en B2 par l'interne, alors qu'`openxlsx` lève une erreur R brute. Cette divergence existait déjà et ne produit pas de valeur fausse.
  - `<c r='Z9' r="A2">` (doublon) : le contrôle et l'interne retiennent Z9.
  - J'ai suivi « même règle que le lecteur ». Si `actuary` veut une règle plus stricte (valeur brute sans `&`, guillemets doubles seuls), c'est une ligne à changer.
- **Écarts avec les textes fixés** : aucun pour les textes eux-mêmes. Deux ajouts de ma part sont adossés à mes mesures : la phrase sur le corps sous le commentaire `rPh`, et le paragraphe sur la chaîne partagée enrichie. Je n'ai pas écrit le texte de la limite Windows « en sept blancs sous C » : c'est une mesure du rejeu que je n'ai pas refaite.

### Surface d'impact documentaire (`docs/latex/doc_tests_usp.tex`, pour `docwriter`)

- **l. 887-891** : liste des refus faits avant `openxlsx`. Ajouter la référence de forme non attendue, et « ces trois refus » devient quatre.
- **l. 897-902** (tableau des lecteurs) : divergences. Ajouter `<rPh>` non lu, `t="str"` lu brut sur les deux chemins, la chaîne en ligne enrichie (corps NA, en-tête `X<col>`) et la chaîne partagée enrichie sans `<rPr>` tronquée par `openxlsx`.
- **l. 920-921** (description de `.xml_textes()`) : « texte de tous les segments `<t>` » devient « hors texte phonétique `<rPh>` ».
- **l. 935-936** (description de `.xlsx_controler_cellules()`) : ajouter le refus d'une référence hors `^[A-Za-z]+[1-9][0-9]*$`.
- **l. 4154-4156** : liste des refus motivés restitués par l'application ; ajouter le nouveau.
- **l. 4562-4568** : refus du classeur ; ajouter le nouveau motif, par son texte.
- **l. 4592-4594** : « Les trois refus du classeur » devient quatre.
- **l. 4598-4600** : « non sous Windows » devient une limite consignée (décision 5).

Fonctions citées : aucune ajoutée ni renommée. La concordance `--strict` donne 0 écart.

### Projet de message de commit

```
moteur: lecteur xlsx, références de cellule refusées, texte phonétique ignoré, limites consignées (Refs #557)

- .xlsx_controler_cellules() : refus (usp_refus_lecture) de toute
  référence de cellule hors ^[A-Za-z]+[1-9][0-9]*$, cellules vides de style
  comprises, avant openxlsx (décision 3 du 13/11/2026) ; référence lue par
  la règle du lecteur (.xlsx_attribut()) ; minuscules admises ; refus de la
  cellule sans r inchangé et placé avant.
- .xml_textes() : texte phonétique <rPh> non lu (décision 4).
- Limites consignées en commentaire : t="str" lu brut sur les deux chemins ;
  chaîne en ligne avec <rPh> (openxlsx : en-tête X<col>, corps NA, refusés
  en aval) ; chaîne partagée enrichie sans <rPr> tronquée par openxlsx ;
  blancs d'en-tête sous Windows non mesurés (décision 5). Commentaire de la
  chaîne en ligne enrichie corrigé (en-tête perdu, corps NA).
- Tests : 12 assertions dans test_controles_entree.R (parité sur les deux
  chemins si openxlsx est installé, limites figées).

Avant / après hors références (openxlsx 4.2.9 et 4.2.5.2) :
- r="", "1A", " A2 ", "A", "A1:B2" : erreur R brute ou valeur perdue -> refus motivé ;
- r="1", "A0" : valeurs déplacées ou perdues sans refus -> refus motivé ;
- <c r="" s="1"/> : lu par openxlsx -> refusé ;
- <rPh>, lecteur interne : "xtZZ" -> "xt", "117" -> "11" (chaîne partagée et
  chaîne en ligne) ; openxlsx inchangé.
Références : comparer_references.R --seuil 0, 0 écart sur les 6 cas ;
aucun σ_USP, aucune p-value ni aucun verdict changé.

Surface d'impact documentaire : doc_tests_usp.tex l. 887-891, 897-902,
920-921, 935-936, 4154-4156, 4562-4568, 4592-4594 (« trois refus » -> quatre),
4598-4600 (Windows) ; aucune fonction ajoutée ni renommée ; concordance
--strict à 0.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_014w4Cra1JGAyptyhUpSL4kt
```
