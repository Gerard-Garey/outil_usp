# Avis amont de la branche S1 (étape 2) : contrat fermé du lecteur de classeur et #579, #575, #574, #570, #588

> *Rédigé par l'agent actuary (IA), fiche `actuary-approfondi`, le 15/11/2026, sur `claude/lecteurs-contrat-ferme` (`3825b1a`, moteur identique à `abc6ff1`). Aucun fichier n'a été écrit par l'agent. Versé intégralement par la session principale (Q-54-10). Les décisions du mainteneur qui en découlent sont dans `decisions-mainteneur.md`. Scripts de mesure de l'agent versés sous `sondes/sonde_avis_amont.R` (m.R) et `sondes/sonde_avis_amont_2.R` (m2.R).*

## 0. Base de l'avis et mesures ajoutées

- **Lu** :
  - la fiche S1 de `docs/feuille-de-route.md` (l. 3892-3925 : « Forme », étapes 0 à 11) ;
  - `docs/revues/20261115-s1-rejeu/rejeu.md`, avec ses sondes et ses sorties ;
  - les issues #574, #575, #579, #570 et #588, avec leurs commentaires ;
  - dans `R/engine.R` : l. 990-1096, 7796-7808, 8013-8134, 8152-8229, 8255-8600, 8600-9106, 9227-9282 et 10260-10420 ;
  - `app.R` l. 270-290 ; `tests/unitaires/outils_unitaires.R` l. 60-120 ; `test_controles_entree.R` l. 5075-5094 ; le job `parite-lecteurs` de `.github/workflows/ci.yml` ; l'ADR 0018.
- **Mesures ajoutées** :
  - R 4.3.3, `LC_ALL=C.UTF-8` ; chemin interne puis `openxlsx` 4.2.5.2 (bibliothèque du rejeu) ; un sous-processus par cas ; forge de l'étape 1 (`sondes/forge.R`).
  - Scripts : `sondes/sonde_avis_amont.R` et `sondes/sonde_avis_amont_2.R`.
  - Toutes les mesures ont été faites sous `openxlsx` 4.2.5.2, aucune sous 4.2.9.

Résultats des mesures nouvelles (*vérifié*). Chaque forme est forgée en B2, dans la colonne `xt` d'une série ; le résultat est celui d'`engine_lire_donnees_csv()`.

| Forme forgée | Interne | openxlsx 4.2.5.2 |
|---|---|---|
| `t="d"`, `<v>2020-01-01T00:00:00</v>` | refus « non numeriques » | **2020, `ok = TRUE`** (valeur fausse) |
| `<v>0x10</v>` (sans `t`) | refus | **16, `ok = TRUE`** (valeur fausse) |
| `<v>&#49;5</v>` (sans `t`) | refus | **0, `ok = TRUE`** (valeur fausse) |
| `t="b"`, `<v>2</v>` | **2, `ok = TRUE`** (valeur fausse) | lu `"FALSE"`, refus |
| `t="e"`, `<v>#N/A</v>` | texte « #N/A », refus | **NA** (cellule devenue vide), refus |
| `t="x"`, `<v>5</v>` | 5 | 5 |
| `t="str"`, `<v>12.5</v>` | 12.5 | 12.5 |
| `<is>` sans `t="inlineStr"` | 11.5 | 11.5 |
| `t="s"` portant `<is>` | NA, refus en aval | **erreur R brute** ; Rcpp signale « subscript out of bounds (index 11 >= vector size 1) » (lecture hors bornes, même classe que #575) |
| table entièrement préfixée `<x:si>` | NA, refus en aval | **erreur R brute** ; « index 0 >= vector size 0 » |
| `<si><t>11.5</t><x:rPh ..><t>7</t></x:rPh></si>` | 11.5 | 11.5 |
| `<r>..</r><r>..</r><rPh><t>7</t></rPh>` (non préfixé) | 11.5 | 11.5 |
| `<c r="XFD1048576" s="1"/>` sans valeur | **erreur R « cannot allocate 128.0 Gb »** | lu juste (8 × 3), `ok = TRUE` |
| cellule sans valeur en J100000 / CV100000 | 99999 × 10 / 99999 × 100 ; 0,19 s / 1,70 s ; `ok = TRUE` | 8 × 3, 0,07 s, `ok = TRUE` |
| valeur en J100000 (10^6 cellules) | 0,19 s ; refus « lignes vides intercalees » | 0,07 s ; même refus |
| valeur en CV100000 (10^7 cellules) | 1,64 s, mémoire maximale 502 Mo ; même refus | 0,35 s, 320 Mo ; même refus |
| `<row r="20">` autour des cellules A2:C2 ; `<row>` sans `r` | lu juste (les deux chemins suivent le `r` de la cellule) | lu juste |
| `<c r="B2"><f>1+1</f></c>` sans `<v>` | NA | NA |

En appel direct (*vérifié*) :
- `engine_valider_donnees(rep(TRUE, 8), yt)` et `run_engine(xt = logique)` refusent déjà (« xt et yt doivent etre numeriques. ») ;
- `mw_valider_triangle()` et `run_engine(methode = "reserve2")` refusent déjà une matrice logique (« Le triangle doit etre une matrice numerique. ») ;
- une **colonne `Date`** passée en appel direct à `engine_lire_donnees_csv()` est acceptée (`ok = TRUE`, `xt = 18262 ...`, en jours), puis `run_engine` rend σ_USP = 0,0415125890. C'est le même mécanisme que #579 : `as.numeric()` appliqué à un vecteur non numérique.

---

## 1. Formes admises par le contrat fermé

**Principe.** Un contrôle unique d'admission précède les deux adaptateurs. Il lit une seule fois les parties nécessaires et refuse toute forme absente de la liste. Il rend une analyse des cellules admises : référence, type, valeur brute, texte. Le lecteur interne et le contrôle de la ligne 1 consomment cette analyse ; `openxlsx` relit le fichier admis.

L'objectif est triple : **aucune valeur fausse acceptée, aucune erreur R brute, aucun arrêt du processus**. Les règles s'évaluent dans l'ordre ci-dessous et seule la première qui échoue lève son refus. Comme aujourd'hui, c'est une erreur `usp_refus_lecture`, qui cite au plus cinq positions (`.liste_positions()`).

**Règles, dans l'ordre d'évaluation :**

- **R0, archive** (inchangée) : refus des entrées qui sortent du dossier, et d'une table des chaînes partagées placée ailleurs qu'en `xl/sharedStrings.xml` ou présente en plusieurs exemplaires.
- **R1, UTF-8 valide.** Elle porte sur `xl/workbook.xml`, `xl/_rels/workbook.xml.rels`, la feuille lue et `xl/sharedStrings.xml`.
  - Chaque partie est lue en octets (`readBin`) ; elle ne doit contenir aucun octet nul, et `validUTF8()` doit être vrai.
  - Le contrôle passe avant toute expression régulière. Il ferme la forme 5 de #574 et le « stack imbalance ».
  - *Option R1b, à décider* : la déclaration XML est absente ou annonce l'encodage `UTF-8` (casse indifférente).
- **R2, sections de balisage.** Dans la feuille et dans la table des chaînes partagées, sont refusés : les commentaires `<!--`, les sections `<![CDATA[`, `<!DOCTYPE`, et toute instruction de traitement `<?…?>` autre que la déclaration XML initiale.
- **R3, structure du bloc des données.**
  - Un seul `<sheetData>` (ou `<sheetData/>`), non préfixé, et aucune balise `<c>` hors de lui.
  - Dans `<sheetData>`, seulement des `<row>`. Dans `<row>`, seulement `<c>` et `<extLst>`.
  - Dans `<c>` : `<f>`, `<v>`, `<is>` et `<extLst>`, chacun au plus une fois. Dans `<is>` : **un seul `<t>`**.
  - Le contenu de `<v>` et de `<f>` est du texte, sans balise. Toute balise ouverte est fermée, dans l'ordre.
  - Toute balise préfixée (`<x:row>`, `<x:c>`, `<x:t>`…) est refusée dans `<sheetData>`.
  - Le contenu d'`<extLst>` n'est ni examiné ni lu.
  - Le refus existant d'une balise `<c` suivie d'un blanc autre que l'espace est conservé, avec son texte.
  - Coût **linéaire** : découpage en balises par un seul `gregexpr`, puis contrôle d'imbrication.
- **R4, attributs de `<c>`.**
  - Les deux refus existants restent, avec leurs textes : `r` absent, et `r` de forme non attendue.
  - Liste fermée d'attributs non préfixés, chacun présent au plus une fois : `r`, `s`, `t`, `cm`, `vm`, `ph`.
  - Les attributs de `<row>` ne sont pas lus (mesure : aucun des deux chemins ne lit `<row r>`). Ils restent libres, y compris `x14ac:dyDescent`, qu'Excel écrit.
- **R5, référence dans les limites d'une feuille** : colonnes A à XFD (16 384), lignes 1 à 1 048 576. La règle vaut pour toute cellule, avec ou sans valeur.
- **R6, référence unique dans la feuille**, sans tenir compte de la casse (`a2` et `A2` désignent la même cellule).
- **R7, type admis** : `t` absent, `n`, `s`, `str`, `inlineStr` ou `b`.
  - `t="e"` est refusé (**décision**, voir § 8).
  - `t="d"` est refusé, avec un texte propre.
  - Toute autre valeur est refusée.
- **R8, contenu conforme au type.**
  - `t` absent ou `n` : pas d'`<is>`. `<v>` est facultatif ; s'il est présent, il a la forme décimale `^[ \t\r\n]*[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)([eE][+-]?[0-9]+)?[ \t\r\n]*$`, ce qui exclut l'hexadécimal, les entités, `INF` et `NaN`.
  - `b` : `<v>` vaut `0` ou `1`.
  - `s` : `<v>` n'est fait que de chiffres (`^[0-9]+$`), et la cellule ne porte pas d'`<is>`.
  - `str` : `<v>` est du texte, sans `<is>`.
  - `inlineStr` : la cellule porte `<is>`, sans `<v>`.
  - Une cellule sans `<v>` ni `<is>` (cellule mise en forme, formule sans valeur) est admise.
- **R9, structure de la table des chaînes partagées.**
  - D'abord les trois refus existants, dans le même ordre et avec leurs textes inchangés : Q-F, P2, X1.
  - Puis la règle générale :
    - racine `<sst>`, avec pour enfants `<si>` (et `<extLst>`) ;
    - dans `<si>`, la suite `<t>`?, `<r>`*, `<rPh>`*, `<phoneticPr>`? ;
    - dans `<r>`, `<rPr>`? puis `<t>` ;
    - dans `<rPh>`, un `<t>`.
  - **Aucune balise préfixée dans toute la table.**
  - Le nombre de chaînes est le nombre de `<si>` de la table.
- **R10, indice de chaîne partagée dans les bornes** (#575, première règle à livrer).
  - Pour toute cellule `t="s"` portant `<v>`, l'indice doit être strictement inférieur au nombre de `<si>` (0 s'il n'y a pas de table).
  - La comparaison se fait en double, ou sur la longueur de la chaîne, jamais par un `as.integer()` qui rendrait NA.
- **R11, étendue** : la dernière ligne × la dernière colonne **des cellules à valeur** (`<v>…</v>` ou `<is>`) ne dépasse pas **10^6**.
- **R12, ligne 1 sans valeur** (inchangée, `MOTIF_LIGNE1_VIDE`).
- **Adaptateur interne.** Il dimensionne sa matrice sur les seules cellules à valeur. Une cellule sans valeur ne porte que NA, et `openxlsx` l'ignore déjà (mesure `vide_xfd`). La règle supprime donc l'allocation de 128 Go sans refuser ce qu'`openxlsx` lit aujourd'hui.

**Justification des bornes.**

- **R5.** Ce sont les limites d'une feuille Excel : 1 048 576 lignes sur 16 384 colonnes. Source : la page de Microsoft « Excel specifications and limits », connue par l'extrait du moteur de recherche ; la page n'était pas joignable depuis la session (*vérifié partiellement*). LibreOffice Calc admet 16 384 colonnes depuis la version 7.4 (extraits de presse ; réglage par défaut *non vérifié*). Aucun tableur n'écrit au-delà : une référence hors de ces limites est forgée.
- **R11.** Les deux adaptateurs allouent un tableau dense du rectangle qui va de A1 à la dernière cellule à valeur. Mesures (*vérifié*) :
  - à 10^6 cellules, la lecture prend 0,07 à 0,19 s ;
  - à 10^7 cellules : 1,64 s et 502 Mo au plus en interne, 0,35 s et 320 Mo par `openxlsx` ;
  - XFD1048576 avec valeur (1,7 × 10^10 cellules) : erreur d'allocation sur les deux chemins.

  Un tableau USP (une série de T ≤ quelques dizaines d'années, ou un triangle d'au plus une centaine de lignes) reste sous 10^4 cellules. Le seuil de 10^6 laisse donc deux ordres de grandeur de marge, pour une mémoire d'environ 50 Mo.

  Toute valeur placée sous le tableau crée des lignes vides intercalées, déjà refusées en aval sur les deux chemins (mesures `val_1e6`, `val_1e7`). Un seul cas qu'un tableur ordinaire peut écrire, et qui est lu aujourd'hui, serait refusé par R11 ; il est décrit au § 8. Seuil de repli : 10^7.

**Ce que le contrat change pour les classeurs d'Excel et de LibreOffice** (*hypothèse*, à confirmer par le corpus de l'étape 10).

- Ces tableurs écrivent :
  - de l'UTF-8, sans commentaire ni DTD ;
  - des éléments non préfixés dans `<sheetData>` et dans la table ;
  - les attributs `r`, `s` et `t`, plus `cm` et `vm` pour Excel 365 ;
  - les types `n`, `s`, `str`, `b` et `e` ;
  - des nombres décimaux ;
  - des chaînes riches avec `<rPr>` et des chaînes phonétiques (`<rPh>`, `<phoneticPr>`) ;
  - des cellules mises en forme sans valeur.
- Sous cette hypothèse, **aucun classeur ordinaire n'est refusé, sauf** dans trois cas :
  - (a) une cellule en erreur de calcul (`t="e"` : `#N/A`, `#DIV/0!`, mais aussi l'image dans une cellule et les types de données liés d'Excel 365, écrits `t="e"` avec `vm`), si R7 refuse `t="e"` ;
  - (b) un classeur au format « Strict Open XML », ou produit par un outil tiers, qui écrit `t="d"` (selon un extrait de SheetJS, `t="d"` n'est pas permis en Transitional : *non vérifié*) ;
  - (c) le cas limite de R11.
- La liste des attributs de `CT_Cell` (`r`, `s`, `t`, `cm`, `vm`, `ph`) et le contenu de `CT_Rst` viennent de ma mémoire d'ECMA-376 Part 1 (§ 18.3.1.4 et § 18.4). Ils ne sont *pas vérifiés sur le texte* : l'hôte du schéma n'était pas joignable.
- **Corpus d'acceptation recommandé pour l'étape 10**, à écrire avec l'Excel du poste et avec LibreOffice :
  - des nombres, des textes, des booléens et une date ;
  - une formule de chaque type de résultat, dont une en erreur ;
  - une formule matricielle dynamique (`cm`) ;
  - une chaîne riche et une chaîne avec phonétique ;
  - une cellule mise en forme loin du tableau (XFD1, ligne 1048576) ;
  - un enregistrement au format « Strict Open XML » depuis Excel.

**Parité.**

- Sur tout classeur admis, aucun des deux chemins ne doit rendre de valeur fausse ni d'erreur R brute. Les mesures de l'étape 1 et celles ci-dessus le montrent forme par forme ; l'audit le vérifiera sur le corpus forgé.
- Trois divergences, sans valeur fausse, restent consignées comme limites :
  - les entités d'une chaîne en ligne ou d'une cellule `t="str"` ;
  - `<t xml:space="preserve">` dans une chaîne en ligne : `openxlsx` le lit avec son attribut, ce qui fait refuser la valeur en aval sur ce chemin, alors que l'interne la lit juste ;
  - le nom d'une colonne sans en-tête (`X<k>` / `V<k>`).
- Formulation proposée pour le critère de parité de l'étape 5 : « jamais deux valeurs différentes acceptées ; un refus sur un chemin et une lecture juste sur l'autre n'est admis que pour les limites listées ».

## 2. Textes des refus

Les textes sont sans accent et chaque refus est levé par `.refus_lecture()`. `%s` désigne les positions : au plus cinq, puis « et k autre(s) ». Un texte cité (valeur, attribut) passe par `.echapper_texte()` et est tronqué à 20 caractères suivis de « ... ».

- **R1** : `Classeur illisible : la partie %s du classeur n'est pas du texte UTF-8 valide (premier octet fautif : octet %d) ; l'outil ne lit pas cette forme de facon sure (une valeur pourrait etre mal lue). Enregistrer de nouveau le classeur depuis un tableur.`
- **R1b** (option) : `Classeur illisible : la partie %s du classeur declare un encodage autre que UTF-8 (%s) ; l'outil ne lit pas cette forme de facon sure (une valeur pourrait etre mal lue). Enregistrer de nouveau le classeur depuis un tableur.`
- **R2** : `Classeur illisible : la partie %s du classeur contient un commentaire, une section CDATA, une instruction de traitement ou une declaration de type de document ; l'outil ne lit pas cette forme de facon sure (une valeur pourrait etre mal lue). Enregistrer de nouveau le classeur depuis un tableur.`
- **R3** : `Classeur illisible : le bloc des donnees de la feuille lue (<sheetData>) contient une balise non prevue, mal imbriquee ou a prefixe d'espace de noms (%s) ; l'outil ne lit pas cette forme de facon sure (une valeur pourrait etre mal lue). Enregistrer de nouveau le classeur depuis un tableur.` Position : « balise <x:c>, apres la cellule B2 » ou « balise <r>, dans la chaine en ligne de la cellule B2 ».
- **R4** : `Classeur illisible : cellule portant un attribut que l'outil ne lit pas (%s) dans la feuille lue ; l'outil ne lit pas cette forme de facon sure (une valeur pourrait etre mal placee). Enregistrer de nouveau le classeur depuis un tableur.` Position : « B2 : x:r ».
- **R5** : `Classeur illisible : cellule de reference hors des limites d'une feuille de calcul (%s ; colonnes A a XFD, lignes 1 a 1048576) dans la feuille lue ; l'outil ne lit pas cette forme de facon sure. Enregistrer de nouveau le classeur depuis un tableur.`
- **R6** : `Classeur illisible : reference de cellule presente plusieurs fois dans la feuille lue (%s) ; l'outil ne choisit pas entre deux valeurs donnees pour la meme cellule. Enregistrer de nouveau le classeur depuis un tableur.`
- **R7, type inconnu** : `Classeur illisible : cellule de type non prevu par le format (%s) dans la feuille lue ; l'outil ne lit pas cette forme de facon sure (une valeur pourrait etre mal lue). Enregistrer de nouveau le classeur depuis un tableur.` Position : « B2 : t="x" ».
- **R7, `t="d"`** : `Classeur illisible : cellule date au format ISO 8601 (attribut t="d") dans la feuille lue (%s) ; l'outil ne lit pas cette forme de facon sure (une date pourrait etre lue comme un nombre). Enregistrer de nouveau le classeur depuis un tableur.`
- **R7, `t="e"`** (si la décision est (i)) : `Cellule(s) en erreur de calcul dans la feuille lue (%s) : une cellule en erreur ne porte pas de donnee. Corriger ou effacer ces cellules, puis enregistrer de nouveau le classeur.` Position : « B7 : #N/A ».
- **R8, nombre** : `Classeur illisible : cellule nombre dont la valeur n'est pas ecrite comme un nombre decimal (%s) dans la feuille lue ; l'outil ne lit pas cette forme de facon sure (une valeur pourrait etre mal lue). Enregistrer de nouveau le classeur depuis un tableur.` Position : « B2 : 0x10 ».
- **R8, booléen** : `Classeur illisible : cellule booleenne de valeur autre que 0 ou 1 (%s) dans la feuille lue ; l'outil ne lit pas cette forme de facon sure (une valeur pourrait etre mal lue). Enregistrer de nouveau le classeur depuis un tableur.`
- **R8, contenu et type** : `Classeur illisible : cellule dont le contenu ne correspond pas a son type (%s) dans la feuille lue ; l'outil ne lit pas cette forme de facon sure (une valeur pourrait etre mal lue). Enregistrer de nouveau le classeur depuis un tableur.` Position : « B2 : t="s" avec <is> » ou « B2 : indice de chaine non entier ».
- **R9, règle générale** : `Classeur illisible : la table des chaines partagees (xl/sharedStrings.xml) contient une balise non prevue, mal imbriquee ou a prefixe d'espace de noms (%s) ; l'outil ne lit pas cette forme de facon sure (une valeur pourrait etre mal lue). Enregistrer de nouveau le classeur depuis un tableur.` Position : « balise <x:si>, avant la chaine no 0 » ou « chaine no 3 : balise <x:rPh> ». Les chaînes sont numérotées à partir de 0, comme l'indice écrit dans `<v>`.
- **R10, #575** : `Classeur illisible : cellule renvoyant a une chaine partagee absente de la table (%s ; la table xl/sharedStrings.xml en compte %d) dans la feuille lue ; l'outil ne lit pas cette forme de facon sure (la lecture pourrait arreter l'application). Enregistrer de nouveau le classeur depuis un tableur.` Position : « A2 : indice 5 ».
- **R11** : `Classeur illisible : la feuille lue porte des valeurs jusqu'a la ligne %d et jusqu'a la colonne %s (cellules %s), soit un tableau de plus de 1000000 de cellules ; l'outil lit un tableau de donnees, non une feuille de cette etendue. Retirer les valeurs eloignees du tableau, ou copier le tableau seul dans un nouveau classeur.`
- **Refus existants** (absence de `r`, forme de `r`, blanc après `<c`, Q-F, P2, X1, chaînes partagées hors de `xl/`, ligne 1) : textes **inchangés**. Ils ont été validés par décision du mainteneur et sont testés. Y ajouter une position serait un changement de texte à part, que je ne recommande pas dans S1.
- **#570** (motif ajouté à `erreurs`, et non erreur levée) : `En-tete de la colonne %d declare d'encodage "bytes" : ses caracteres ne sont pas determines ; fournir le nom en UTF-8 ou en Latin-1 declare.` Un motif par colonne, sur le modèle des l. 10415-10417.
- **#579** : aucun texte nouveau. Le motif reste celui des cellules non numériques, avec leur position.

## 3. Forme 2 de #574 (`<r>` suivis de `<x:rPh>`)

**Avis : refus**, par R9 (balise préfixée dans la table), donc avant les deux adaptateurs.

- **Faits** (*vérifié*) : `openxlsx` 4.2.5.2 lit 11.57, sans message, avec `ok = TRUE` (rejeu) ; l'issue mesure le même résultat sous 4.2.9. La même table sans préfixe est lue 11.5 par les deux chemins (mesure).
- **Imposer une lecture juste est impossible.** Il faudrait retoucher la sortie d'`openxlsx`, ce que le moteur s'interdit, ou contourner `openxlsx`, ce qui contredit l'invariant de `CLAUDE.md` et la décision Q-C.
- **Consigner une limite contredirait** le critère de l'étape 5 (« aucune valeur fausse acceptée ») et le critère E1 de l'ADR 0018 (valeur fausse acceptée sans message sur une entrée admissible).
- Le refus renverse la limite consignée par décision du mainteneur : il demande sa décision (§ 8).
- Forme forgée : *hypothèse* qu'aucun tableur n'écrit un `<x:rPh>` dans un `<si>` non préfixé.

## 4. #579

- **Comportement cible de `.en_numerique()`.**
  - Un vecteur caractère ou facteur est traité comme aujourd'hui.
  - Tout autre vecteur **qui n'est pas numérique** (`!is.numeric(v)` : logique, `Date`, `POSIXct`, complexe, brut, liste) rend `rep(NA_real_, length(v))`.
  - La feuille de route ne visait que le logique. L'extension aux autres types est **recommandée** et demande une décision (§ 8) : aujourd'hui, une colonne `Date` passée en appel direct rend σ_USP = 0,0415125890 (*vérifié*).
  - Une cellule TRUE ou FALSE devient « non vide et non numérique » : elle est refusée, avec sa position. Une colonne entièrement NA reste vide.
  - Mesures du correctif simulé (*vérifié*, substitution dans `environment(run_engine)`) :
    - data.frame logique : « Certaines valeurs des colonnes xt ou yt ne sont pas numeriques (colonne xt : ligne(s) de donnees 1, 2, 3, 4, 5 et 3 autre(s)). » ;
    - triangle avec C(0,4) logique : « Cellule(s) non numerique(s) en (i = 0, j = 4) ... » ;
    - colonne logique entièrement NA : même refus qu'aujourd'hui (colonne vide portant un en-tête) ;
    - colonne logique supplémentaire, hors `t`, `xt` et `yt` : ignorée, `ok = TRUE` comme aujourd'hui.
- **Cellule ou colonne booléenne (`t="b"`), et colonne de textes « TRUE » / « FALSE ».**
  - Par le chemin `openxlsx`, la colonne est rendue logique (sortie non retouchée : l'assertion des l. 5089-5094 reste vraie), puis refusée en aval avec sa position.
  - Par le chemin interne, elle est rendue en texte « TRUE », puis refusée en aval avec la même position et le même texte.
  - Le motif est identique sur les deux chemins : les mêmes cellules sont NA.
  - `t="b"` reste admis par le contrat : une colonne de drapeaux non utilisée est légitime.
- **Appel direct d'`engine_valider_donnees()`.** Cette fonction prend des vecteurs, non un data.frame, et refuse déjà un vecteur logique (« xt et yt doivent etre numeriques. », *vérifié*) ; `run_engine()` aussi. Aucun changement n'est requis. Le « data.frame logique en appel direct » du rejeu passe par `engine_lire_donnees_csv()`, que le correctif couvre.
- **`mw_valider_triangle()` : aucun changement.** Elle refuse déjà une matrice logique (« Le triangle doit etre une matrice numerique. », *vérifié*). `engine_lire_triangle()` refusera désormais la cellule plus tôt, avec sa position. Aujourd'hui, la cellule est lue 1, puis le triangle est refusé plus loin pour un motif trompeur.
- **Commentaires à corriger** :
  - l. 9068-9069 ;
  - l. 8887-8889 et 8304-8305 : la colonne logique relue en logique par `openxlsx` est ensuite refusée en aval.
  - Surface d'impact documentaire : `.tex` l. 834, 915-920, 4650-4732, à lister par `coder`.
- **Sonde versionnée pour le tableau avant / après.**
  - Sonde : `docs/revues/20261115-s1-rejeu/sondes/sonde.R`, versionnée depuis `3825b1a`, cas `579-b`, `579-txt`, `579-tri`, `579-df`.
  - Commande : `bash docs/revues/20261115-s1-rejeu/sondes/rejouer.sh "$PWD" <bibliotheque openxlsx 4.2.5.2> 579-b 579-txt 579-tri 579-df`, sous `LC_ALL=C.UTF-8`.
  - Avant : `sorties/579.txt`. Après : la même commande sur le commit du correctif, sortie versée sous `sorties/579-apres.txt`.
  - Avant : σ_USP = 9.4077602303 par `openxlsx` (cas b et txt) et par les deux chemins (cas df) ; triangle `ok = TRUE`, C(0,4) = 1. Après : refus avec position.
  - Le cas `579-df` se rejoue sans `openxlsx`.
  - La valeur 0,20176 de l'issue ne se refait pas, faute de versionnement des données `yt` de `p4.R` ; le commit le dira.
- **Effet attendu** : aucune des six références n'est touchée (*hypothèse*, conforme à la feuille de route, non rejouée ici).

## 5. #575

- **Comportement cible** : R10, posée avant tout appel à `openxlsx` et, pour la première livraison, avant même le reste du contrat. Le nombre de chaînes est compté comme le lecteur interne les extrait ; le décompte définitif sera celui de R9.
- **Test en sous-processus**, dans `test_controles_entree.R`, et donc exécuté par le job « Parité des lecteurs de classeur ».
  - **Classeur forgé** : une seule `<si>` (`annee`) ; A1 `t="s"` d'indice 0 ; A2 `t="s"`, `<v>5</v>`.
  - **Script fils**, écrit dans un fichier temporaire. Il charge le moteur par `charger_moteur(<chemin absolu>)`, appelle `engine_lire_xlsx(f)` dans un `tryCatch` qui rend la condition, puis imprime `CLASSE=<class(r)[1]>` et `MESSAGE=<conditionMessage(r)>`.
  - **Deux lancements** : chemin `openxlsx` tel qu'installé ; chemin interne en substituant `requireNamespace` dans `environment(run_engine)`, sur le modèle de `sans488`. Sans `openxlsx`, le premier lancement écrit `[saute]`, comme les tests existants.
  - **Commande** : `out <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"), shQuote(c(script, f)), stdout = TRUE, stderr = TRUE, timeout = 120))` ; `st <- attr(out, "status")`, qui vaut `0L` si l'attribut est absent.
  - **Succès** si et seulement si :
    - `identical(st, 0L)` ;
    - une ligne `CLASSE=usp_refus_lecture` est présente ;
    - la ligne `MESSAGE=` commence par le texte de R10, avec « A2 : indice 5 » ;
    - le message est le même sur les deux chemins.
  - **Avant la correction**, le test échoue sans arrêter la batterie, quelle que soit l'issue : code 139 (ou code d'exception sous Windows), erreur R (`CLASSE=simpleError`), chemin interne qui rend un data.frame (`CLASSE=data.frame`), ou délai dépassé (code 124). S'il est posé avant le correctif, il prend `echec_attendu()`.
  - Les deux formes qui lisent aussi hors bornes dans `openxlsx` (`t="s"` portant `<is>`, table entièrement en `<x:si>` ; voir § 0) sont testées de la même façon, en sous-processus.

## 6. #570

- **Mécanisme établi** (rejeu et mesure).
  - L'erreur vient de l'accès `df$xt` et `df$yt` (l. 8094-8095), quand un nom d'encodage « bytes » **précède** la colonne visée.
  - Placé après `yt`, le nom ne cause rien.
  - `engine_lire_triangle()` ne lève rien, même avec un nom « bytes » en colonne 1 (*vérifié*).
  - Le défaut est donc propre à `engine_lire_donnees_csv()`.
- **Comportement cible recommandé (a).**
  - Dans `engine_lire_donnees_csv()`, juste après le retrait du BOM et avant `.declarer_latin1()`, **tout** en-tête d'encodage `"bytes"` est refusé, quelle que soit sa place, par un retour `ok = FALSE`.
  - Un motif par colonne, dans l'ordre des colonnes, avec le texte du § 2, sans citer le nom.
  - Retour immédiat, comme le modèle de la l. 10354, qui refuse déjà tout nom « bytes ».
  - `engine_lire_triangle()` n'est pas touché.
  - **Motif** : une règle qui dépendrait de la place de la colonne serait arbitraire pour l'utilisateur. Un nom « bytes » ne peut valoir `t`, `xt` ni `yt`, puisque R ne marque « bytes » que des chaînes non ASCII.
  - L'option (a) refuse le jeu `t, xt, yt, <bytes>`, lu aujourd'hui (`ok = TRUE`) : **décision** (§ 8).
  - Aucun chemin de l'application ne produit un nom « bytes » (*hypothèse* fondée sur `app.R` l. 280 et sur la lecture des classeurs en UTF-8).
- **Repli (b)**, sans refus nouveau : ne refuser qu'un nom « bytes » placé avant `xt` ou `yt`.
- **Test unitaire** : les trois placements du rejeu, plus (a) ou (b) selon la décision ; seuil 0.

## 7. #588

**Recommandation : normaliser dans `.echapper_texte()`, vers la forme vue sous Windows.**

Une chaîne déclarée Latin-1 est convertie par une table fixe, propre au moteur et indépendante de la plateforme :

- octets 0x00-0x7F : ASCII ;
- octets 0x80-0x9F : Windows-1252 pour les 27 positions définies ; **U+0081, U+008D, U+008F, U+0090, U+009D** pour les cinq positions sans caractère ;
- octets 0xA0-0xFF : U+00A0-U+00FF.

`.echapper_texte()` écrit alors « a\u0081b » (barre oblique inverse, u, 0081), sous Linux comme sous Windows.

**Motifs.**

1. **Contrat de la fonction.** Son en-tête promet un échappement « independant de la locale ». Un attendu propre à chaque plateforme entérinerait un message de refus qui dépend de la machine, contre la règle de reproductibilité du dossier.
2. **La forme « <81> » de Linux est ambiguë, avec un effet mesuré.** Sous Linux, un nom Latin-1 « a\x81b » et un nom ASCII « a<81>b » sont cités de la même façon. `mw_valider_triangle()` les juge **en double** : « Annee d'accident en double : "a<81>b" (annees d'accident i = 0 et i = 1). » (*vérifié*). La forme U+0081 reste distincte, car la barre oblique inverse d'un nom ASCII est doublée.
3. **La forme vue sous Windows est mesurée** (#588). Elle coïncide, *de mémoire*, avec la table « windows-1252 » de l'Encoding Standard du WHATWG (`index-windows-1252.txt` : 0x81 vers U+0081). L'hôte n'était pas joignable : *non vérifié*.

**Réalisation.**

- La table est construite une seule fois.
- Les 27 positions définies sont relevées sous Linux par `utf8ToInt(enc2utf8(octet déclaré latin1))`, sous `C.UTF-8` ; c'est la mesure déjà consignée aux l. 1050-1053.
- Les cinq autres positions sont posées explicitement. Un test énumère les 32 valeurs et fige la table.
- Non-régression sous Linux : sur les 256 octets, la sortie ne change que pour les cinq positions.
- L'**attendu de l'assertion #522 change** : « a\\u00a0b, a\\u0081b, aéb » au lieu de « a\\u00a0b, a<81>b, aéb ».
  - Le critère de l'étape 7, « assertion de #522 vraie sur les deux plateformes », devient « assertion de #522, attendu révisé, vraie sur les deux plateformes ». À confirmer par le mainteneur.
  - Le commentaire d'en-tête (l. 1014-1018) et celui de `.nettoyer_cellules()` (l. 1050-1053) sont à corriger.
- **Repli**, si le mainteneur refuse de changer le message sous Linux : un attendu propre à chaque plateforme. Je le déconseille, pour les motifs 1 et 2.
- **Extension possible, hors du périmètre strict de #588, sur décision** : employer le même helper dans `mw_valider_triangle()` (recodage `noms_u`), pour supprimer le faux doublon du motif 2 (voir « Constats hors périmètre »).

## 8. Refus nouveaux d'une forme lue aujourd'hui sans erreur (décision du mainteneur)

**A. Valeur fausse aujourd'hui, sur au moins un chemin.** Le refus corrige le défaut ; je le recommande.

| Forme | Aujourd'hui | Règle | Statut |
|---|---|---|---|
| #574 (1) : `<x:si>` mêlée à des `<si>` | 11.5 au lieu de 9, sur les deux chemins | R9 | vérifié (rejeu) |
| #574 (2) : `<r>` puis `<x:rPh>` | 11.57 par `openxlsx` | R9 | vérifié ; renverse une limite consignée |
| #574 m1 : référence en double | 999, sur les deux chemins | R6 | vérifié |
| `t="d"` | 2020 par `openxlsx` | R7 | vérifié (mesure) |
| `<v>0x10</v>` | 16 par `openxlsx` | R8 | vérifié (mesure) |
| `<v>&#49;5</v>` | 0 par `openxlsx` | R8 | vérifié (mesure) |
| `t="b"`, `<v>2</v>` | 2 en interne | R8 | vérifié (mesure) |
| `<c x:r="Z9" r="A2">` | valeur placée en Z9 par `openxlsx` | R4 | consigné (mesure de #557, sous 4.2.9) ; non remesuré |
| #579 : colonne booléenne ou « TRUE » | σ_USP rendu | `.en_numerique()` | vérifié |
| colonne `Date` en appel direct | σ_USP rendu (0,0415125890) | `.en_numerique()` étendu | vérifié (mesure) |

**B. Formes forgées, lues juste aujourd'hui et refusées par le contrat** (*hypothèse* : aucun tableur ne les écrit).

- #574 (4) : des milliers de `<x:rPh>` non fermés, lus 11, lentement (R9, et R3 pour la variante en ligne).
- `<x:rPh>` après `<t>`, ou `<x:rPh .../>` auto-fermante : lu 11.5 par les deux chemins (R9).
- `t="x"` : lu 5 (R7).
- `<is>` sans `t="inlineStr"` : lu 11.5 (R8).
- Chaîne en ligne riche ou phonétique (`<is><r>`, `<is><rPh>`) : lue en interne ; par `openxlsx`, lue NA puis refusée, limite consignée de #557 (R3).
- `<v>INF</v>` : lu Inf, puis refusé par `engine_valider_donnees()` (R8).
- Attribut de `<c>` hors de la liste (R4).
- Cellule hors de `<sheetData>`, ou plusieurs `<sheetData>` (R3).
- Commentaire, section CDATA ou instruction de traitement (R2).

Je recommande ces refus : ils ferment le contrat sans coût pour un classeur réel.

**C. Formes qu'un tableur ou un outil réel peut écrire : risque de refus à tort.**

- **`t="e"`, cellule en erreur.** Excel l'écrit : formule en erreur, image dans la cellule, type de données lié.
  - Dans une colonne non utilisée, la lecture réussit aujourd'hui.
  - Dans le corps du tableau, l'interne lit « #N/A » et refuse, alors qu'`openxlsx` lit NA. Un triangle en erreur sous la diagonale est donc accepté par un chemin et refusé par l'autre (*vérifié* pour la série ; triangle *déduit*, non mesuré).
  - **(i) Refuser toute cellule en erreur : recommandé**, pour obtenir la parité par construction, et parce qu'une feuille de données en erreur appelle une correction.
  - **(ii) Admettre la cellule**, et consigner la divergence.
- **`t="d"`** (format Strict, outils tiers) : refus recommandé, à cause de la valeur fausse que rend `openxlsx`. Un classeur portant une date dans une colonne non utilisée, lu aujourd'hui en interne, sera refusé.
- **R11** refuse une série de T ≥ 61 années qui porte une valeur isolée au-delà de la colonne 10^6/(T+1), forme lue aujourd'hui. Repli : 10^7, pour 502 Mo mesurés au plus en interne.
- **#570, option (a)** : le jeu `t, xt, yt, <bytes>` est refusé (aujourd'hui `ok = TRUE`).
- **R1b** (option) : une partie qui déclare un encodage autre qu'UTF-8 est refusée, alors qu'elle est lue aujourd'hui si elle est en ASCII.
- **#588** : le texte cité change sous Linux (« <81> » devient « \u0081 »). Ce n'est pas un refus, mais un message restitué qui change (`app-review` léger).

**D. Erreur R brute ou arrêt aujourd'hui, refus motivé demain : pas de décision requise.**

- #574 (3) : XFD1048576 avec valeur, A99999999999 (R5, R11).
- #574 (5) : UTF-8 invalide (R1).
- #575 : R10.
- `t="s"` portant `<is>`, et table entièrement en `<x:si>` (R8, R9).
- #570 : nom « bytes » placé avant `xt` ou `yt`.
- Cas inverse : une cellule sans valeur en XFD1048576 cause aujourd'hui une erreur d'allocation en interne ; elle sera **lue** demain, l'adaptateur étant dimensionné sur les seules cellules à valeur.

---

## Retour

- **Statut** : `revue requise`.
  - Des décisions du mainteneur sont nécessaires : plusieurs refus nouveaux (§ 8, A à C), le choix sur `t="e"`, l'option de #570, le seuil de R11 et l'attendu révisé de #588.
  - Trois sources externes ne sont que partiellement prouvées : la page de Microsoft, le schéma ECMA-376 et l'index du WHATWG, dont aucun n'était joignable depuis la session.
- **Résultat** :
  - contrat fermé R0 à R12 (§ 1) et textes de refus (§ 2) ;
  - forme 2 de #574 refusée (§ 3) ;
  - cible de #579 étendue aux vecteurs non numériques (§ 4) ;
  - test de #575 en sous-processus (§ 5) ;
  - #570 selon l'option (a) (§ 6) ;
  - #588 normalisé dans `.echapper_texte()` vers U+0081 (§ 7) ;
  - liste des refus nouveaux (§ 8).
- **Preuves.**
  - *Vérifié* : le code lu aux lignes citées ; le rejeu de l'étape 1 ; les mesures du § 0 (scripts `sondes/sonde_avis_amont.R` et `sonde_avis_amont_2.R`, `openxlsx` 4.2.5.2, R 4.3.3, `C.UTF-8`) ; le faux doublon Latin-1 / ASCII de `mw_valider_triangle()` ; le σ_USP rendu sur une colonne `Date`.
  - *Partiellement vérifié* (extraits de recherche, pages non consultées) : la limite de 1 048 576 × 16 384 d'Excel ; les 16 384 colonnes de LibreOffice depuis la version 7.4 ; l'existence de `t="d"` dans `ST_CellType`.
  - *Hypothèses* :
    - ce qu'écrivent Excel et LibreOffice (§ 1) ;
    - les attributs de `CT_Cell` et le contenu de `CT_Rst`, donnés de mémoire ;
    - aucune des six références n'est touchée ;
    - le comportement d'`openxlsx` 4.2.9 sur les formes nouvelles, toutes les mesures ayant été faites sous 4.2.5.2.
  - *Non vérifié* : la table du WHATWG ; l'interdiction de `t="d"` en Transitional ; un triangle portant `t="e"` sous la diagonale.
- **Informations manquantes** :
  - les hôtes `support.microsoft.com`, `webapp.docx4java.org` et `encoding.spec.whatwg.org` n'étaient pas résolus dans la session ;
  - mesures sous `openxlsx` 4.2.9 et sous Windows (poste du mainteneur) ;
  - corpus réel d'Excel et de LibreOffice (étape 10).
- **Décisions non résolues** (mainteneur) :
  - les refus du § 8, A, B et C, dont la forme 2, qui renverse une limite consignée ;
  - `t="e"` : (i) ou (ii) ;
  - l'extension de `.en_numerique()` aux vecteurs non numériques ;
  - #570 : (a) ou (b) ;
  - le seuil de R11 : 10^6 ou 10^7 ;
  - R1b ;
  - l'attendu révisé de #522, et l'extension du helper de #588 à `mw_valider_triangle()`.
- **Critères déclenchés** :
  - **changement de résultat** hors références : pour #579 et la colonne `Date`, un σ_USP rendu devient un refus (visa du mainteneur) ; des messages restitués changent (#588 sous Linux, textes nouveaux) ;
  - **question qu'aucune source ni aucun test ne tranche** : ce qu'écrivent réellement les tableurs, que seul le corpus de l'étape 10 tranchera ;
  - **sources indisponibles** : un problème de documentation disponible, non de lecture ;
  - **écart à la feuille de route**, non à un ADR : l'étape 3 visait le seul vecteur logique, et l'étape 7 un attendu de #522 inchangé.
- **Constats hors périmètre** (ADR 0018) :
  1. **`R/engine.R` l. 10370-10450**, `mw_valider_triangle()` (recodage `noms_u` par `enc2utf8()`). Sous Linux, un nom Latin-1 « a\x81b » et un nom ASCII « a<81>b » sont jugés en double, et le triangle est refusé à tort.
     - Gravité mineure ; critère **E1** (σ_USP refusé à tort sur une entrée admissible, forgée).
     - Preuve : la mesure ci-dessus (`Rscript`, `C.UTF-8`). Sous Windows, l'issue est probablement différente (non mesuré).
     - Peut être absorbé par l'extension du helper de #588, sur décision.
  2. **Formes nouvelles qui rendent une valeur fausse** : `t="d"`, `0x10` et `&#49;5` par `openxlsx` ; `t="b"` de valeur 2 en interne ; colonne `Date` en appel direct.
     - Critère **E1**, preuves au § 0.
     - Elles sont **dans le périmètre** si le mainteneur retient le contrat fermé et l'extension de `.en_numerique()` ; sinon, une issue par forme.
     - Commentaire de rattachement recommandé sur #574 et #579.
  3. **Lectures hors bornes signalées par Rcpp dans `openxlsx`** (« subscript out of bounds ») pour `t="s"` portant `<is>` et pour une table entièrement préfixée : même classe que #575.
     - Critère **G**, par analogie avec #575 : arrêt possible du processus ; ici, une erreur R seulement, sans arrêt observé.
     - Dans le périmètre du contrat (R8, R9).
  - Aucun autre constat.
- **Prochaine action recommandée** :
  1. La session soumet au mainteneur les décisions ci-dessus, en commençant par le § 8.
  2. Elle verse cet avis et les deux scripts de mesure dans `docs/revues/20261115-s1-rejeu/`.
  3. Elle lance `coder-approfondi` sur #579, avec le § 4 et la sonde du rejeu pour le tableau avant / après ; puis sur #575 (§ 5, R10 seule) ; puis sur #574 (R1 à R12, un commit par forme dont le résultat change).

### Sources consultées (extraits de recherche ; pages non ouvertes depuis la session)

- [Microsoft, Excel specifications and limits](https://support.microsoft.com/en-us/office/excel-specifications-and-limits-1672b34d-7043-467e-8e27-269d656771c3)
- [DevExpress, Excel export specifications and limits](https://docs.devexpress.com/OfficeFileAPI/114747/excel-export-library/overview/excel-export-specifications-and-limits)
- [Annonce de LibreOffice 7.4.1 (TDF)](https://listarchives.tdf.io/i/Hx-olzMAYF3v1iLiYeaurFyk) ; [Phoronix, LibreOffice 7.4](https://mail.phoronix.com/news/LibreOffice-7.4-Released)
- [ECMA-376, ST_CellType (docx4java)](https://webapp.docx4java.org/OnlineDemo/ecma376/SpreadsheetML/ST_CellType.html) ; [SheetJS, types de données](https://git.sheetjs.com/sheetjs/sheetjs/raw/tag/v0.11.1/docbits/52_datatype.md) ; [LibreOffice, bogue 100822](https://bugs.libreoffice.org/show_bug.cgi?id=100822)
