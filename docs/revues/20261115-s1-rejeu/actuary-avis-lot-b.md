# Avis d'actuary sur les questions du lot B de #574 (S1, étape 5)

> *Rédigé par l'agent actuary (IA), fiche `actuary-approfondi`, le 15/11/2026, sur `claude/lecteurs-contrat-ferme` (`1818b4d` et diff non commité du lot B). Aucun fichier écrit par l'agent. Versé intégralement par la session principale (Q-54-10). Décisions du mainteneur qui en découlent : `decisions-mainteneur.md`, D-S1-9 à D-S1-11. Scripts de mesure de l'agent versés sous `sondes/sonde_avis_lot_b.R` (m.R) et `sondes/sonde_avis_lot_b_2.R` (m2.R), sortie de m.R sous `sorties/avis-lot-b.txt`.*

Je n'ai écrit aucun fichier dans le dépôt. J'ai relu `R/engine.R` (diff non commité, l. 8740-9606), l'avis amont, `decisions-mainteneur.md` (S1 et K2b), la sonde et les sorties du lot B, et la source d'openxlsx 4.2.5.2 (`scratchpad/src/ox/openxlsx/src/read_workbook.cpp`, `getCellInfo()` l. 146-420 et `read_workbook()` l. 490-580).

Mesures faites en sous-processus, sous `LC_ALL=C.UTF-8`, sur deux moteurs : celui de `1818b4d` (avant) et le diff (après). Chaque cas est lu par le chemin interne et par openxlsx 4.2.5.2.
- Scripts : `/tmp/claude-0/-home-user-outil-usp/616ce66a-eb09-487c-aacf-c23cc7c831fe/scratchpad/actuary_lotB/m.R` et `/tmp/claude-0/-home-user-outil-usp/616ce66a-eb09-487c-aacf-c23cc7c831fe/scratchpad/actuary_lotB/m2.R`.
- Sortie : `/tmp/claude-0/-home-user-outil-usp/616ce66a-eb09-487c-aacf-c23cc7c831fe/scratchpad/actuary_lotB/sortie.txt`.

## Q1. Segment de cellule lu par openxlsx (ajout à R3) : règle acceptée, texte à modifier

**Le mécanisme est vérifié dans la source.**
- `nextPos = xml.find("<c ", pos + 9)` découpe le fichier en segments. Le segment de la dernière cellule va jusqu'à la fin du fichier, au-delà de `</sheetData>`.
- Dans chaque segment, openxlsx prend la première suite `" t="`, sauf si un `"<f"` la précède. Il cherche aussi la première `"</v>"`, avec le `"<v"` qui la précède, puis la première `"</t></is>"`.
- La règle du codeur reproduit exactement ce comportement.

**Mesure nouvelle : un texte après le bloc des données peut arrêter R.** Un pied de page `<headerFooter><oddHeader>&amp;C t="s"</oddHeader>` placé après la dernière cellule nombre (C9) :
- arrête R par openxlsx avant correctif : « An irrecoverable exception occurred. R is aborting now ». C'est le critère G, comme #575 ;
- est lu juste par le chemin interne.

La règle est donc justifiée au-delà du seul attribut `t` de `<row>`.

**Elle a un coût, mesuré.** Un en-tête de page `&amp;CMontant t=1` est lu juste par les deux chemins à `1818b4d` (σ_USP = 0.1114524114). Il est refusé après le correctif. Je recommande malgré tout la règle prudente, plutôt qu'une règle calquée sur la valeur de type qu'openxlsx extrairait :
- elle ne dépend pas du détail interne d'une version d'openxlsx (4.2.9 n'a pas été mesuré) ;
- le cas refusé à tort exige qu'un texte saisi contienne littéralement « t= », précédé d'une espace, après la dernière cellule et sans `<formula>` avant lui. Le coût est probablement faible (*hypothèse*, à vérifier sur le corpus de l'étape 10).

Ce refus vise une forme qu'un tableur peut écrire (groupe C) : à soumettre au mainteneur (D2, point a).

**Correction de mon avis amont.** « Attributs de `<row>` libres » était faux pour openxlsx. Ma mesure `<row r="20">` ne couvrait pas un `t=`. La règle du segment remplace cette phrase.

**Le texte doit changer.** Le texte de R3 (« le bloc des donnees … contient une balise non prevue ») est inexact ici : l'attribut d'un `<row>` n'est pas une balise non prévue, et le texte d'un pied de page n'est pas dans le bloc. Je propose un texte propre :

`Classeur illisible : la feuille lue porte, apres une cellule, un texte qu'un lecteur de classeur peut prendre pour le type ou la valeur de cette cellule (%s) ; l'outil ne lit pas cette forme de facon sure (une valeur pourrait etre mal lue). Enregistrer de nouveau le classeur depuis un tableur.`

Forme des positions : `cellule C2 : suite " t=", dans le bloc des donnees`, `cellule C9 : suite " t=", apres le bloc des donnees`, `cellule B12 : balise </v>, apres le bloc des donnees`, `cellule B2 : balise <v>, dans le bloc des donnees` (cas `r3-extlst-v`). La zone se juge par rapport à la fin de `</sheetData>`.

## Q2. Contraintes de R4 sur les valeurs d'attribut : contraintes acceptées, texte à modifier

**Mesures** (tableau ci-dessous).

| Forme | Interne, avant | openxlsx, avant | Après correctif |
|---|---|---|---|
| `t='s'` (apostrophes, `<v>0</v>`) | 11.5, σ_USP = 0.2005042338 | 0 | refus R4 sur les deux chemins |
| `s="xr=_D2"` | valeur en B2 | valeur placée en D2 | refus R4 |

Le cas `t='s'` est une valeur fausse sur un chemin (groupe A), déjà couvert par D-S1-1. La source le confirme : `cell.substr(pos_t + 4, …)` suppose un guillemet double et `cell.find("r=")` prend la première suite `r=` du segment. Les contraintes de valeur (`s`, `cm`, `vm` en chiffres ; `ph` booléen ; guillemets doubles sans blanc autour de `=` ; `t` précédé d'une espace) sont donc justifiées. Excel ne s'en écarte pas (*hypothèse*).

**Le texte ne couvre pas ces cas.** « Attribut que l'outil ne lit pas » est faux pour `t='s'` ou `s="xr=_D2"`, que l'outil lit. Texte proposé :

`Classeur illisible : cellule portant un attribut non prevu, repete, ou ecrit sous une forme que l'outil ne lit pas (%s) dans la feuille lue ; l'outil ne lit pas cette forme de facon sure (une valeur pourrait etre mal lue ou mal placee). Enregistrer de nouveau le classeur depuis un tableur.`

La position reste « B2 : t » (le nom seul). C'est un amendement de mon propre texte : à porter à la connaissance du mainteneur, sans décision.

## Q3. Ajouts structurels à R3 : acceptés

- **`<sheetData>` exact.** openxlsx cherche `"<sheetData>"` (l. 171) et rend NULL sur `<sheetData >`.
- **Fermantes sans blanc.** Avant, `</v >` était lu NA par openxlsx et décalait les valeurs en interne.
- **`>` dans une valeur d'attribut et texte non blanc hors de `<v>`, `<f>`, `<t>`.** Ce sont des formes hors schéma ou forgées, qui servent la fermeture du contrat.
- **XML indenté.** Mesure du cas `indente-is` (`<is>` indenté) :
  - avant : interne 104.2 et σ_USP = 0.1114524114 ; openxlsx refuse en aval, la cellule étant lue non numérique (pas de `</t></is>` contigu) ;
  - après : refus R3 sur les deux chemins ;
  - aucune valeur fausse avant, parité obtenue par construction.

  Le cas `indente-v` (`<c>` puis `<v>` indentés) reste lu juste sur les deux chemins.

  Le risque est faible : Excel n'écrit pas de chaîne en ligne, et l'écrivain du moteur, le mode à mémoire constante de libxlsxwriter, LibreOffice et openpyxl écrivent un XML compact (*hypothèse*, à inclure dans le corpus de l'étape 10).

  Le refus fait passer le chemin interne d'un σ_USP rendu à un refus : la ligne va dans le tableau avant / après soumis au visa (D2).

## Q4. « Un seul `<t>` dans `<is>` » lu « exactement un » : confirmé

- `<is/>` est valide au schéma, mais ne porte aucun texte.
- Avant, il était déjà refusé en aval sur les deux chemins (« non numeriques », mesure `is-vide`). Après, il est refusé par R3.
- `<is><t/></is>` et `<is><t></t></is>` restent admis, puis refusés en aval sur les deux chemins, avant comme après.
- Aucune valeur ne change. Une forme unique de chaîne en ligne simplifie le contrat.

## Q5 (lot C, R8). `t="s"` et `t="b"` sans `<v>` : refus accepté, amendement de R8

**La source le confirme.** `atoi(NA)` vaut 0, ce qui donne `sharedStrings[0]` ; un `v` différent de `"1"` donne `"FALSE"`.

**Mesures.**

| Forme | Interne | openxlsx 4.2.5.2 |
|---|---|---|
| `t="s"` sans `<v>`, avec ou sans `<f>` | refus en aval (avant comme après) | 11.5, `ok = TRUE`, σ_USP = 0.2005042338 : valeur fausse acceptée, encore présente après le lot B |
| XFD1048576, `t="s"` ou `t="b"` sans `<v>` | lu 8 × 3 | « cannot allocate vector of size 128.0 Gb » |
| XFD1048576, `t="str"` (avec ou sans `<f>`), `t="inlineStr"` sans `<is>`, `<f>` seul, `t="e"` | lu | lu 8 × 3, sans allocation |

Les formes de la dernière ligne ne posent donc pas de problème ; seuls `s` et `b` inventent une valeur.

**Amendement de R8.** « Une cellule sans `<v>` ni `<is>` est admise, sauf `t="s"` et `t="b"` (refus) ». Le texte est celui de R8 « contenu et type », position « B2 : t="s" sans <v> ».

Il s'agit d'une valeur fausse sur un chemin et d'une erreur R brute (groupes A et D), couvertes par D-S1-1. Excel n'écrit ni `t="s"` ni `t="b"` sans `<v>` (*hypothèse*). Aucune décision nouvelle n'est requise ; le changement de σ_USP sur le chemin openxlsx va dans le tableau du lot C.

## Q6. Références en minuscules (`r="b2"`) : refus recommandé, décision du mainteneur requise

**Mesure.**
- Avant comme après : interne σ_USP = 0.1114524114 ; openxlsx « missing value where TRUE/FALSE needed », erreur R brute.
- Avec openxlsx installé (chemin par défaut de l'application), l'utilisateur reçoit aujourd'hui le message fixe de l'application, sans motif.

**Avis.** L'objectif « aucune erreur R brute » du contrat retenu (D-S1-1) contredit le maintien de la décision 3 du 13/11 (Q-A, motif `[A-Za-z]`), qui reposait sur mon avis K2b. Je recommande de restreindre la forme à `^[A-Z]+[1-9][0-9]*$`.
- Texte : celui, **inchangé**, de Q-A (« reference de position (attribut r) n'a pas la forme attendue … (par exemple A2) »), qui convient.
- R6, insensible à la casse, devient sans objet, mais peut rester.
- Effet : le chemin interne passe de la lecture au refus ; le chemin openxlsx passe d'une erreur brute à un refus motivé.

C'est un renversement d'une décision du mainteneur : il doit trancher (D1).

## Q7. R5 appliquée à une cellule sans valeur (XFE10) : acceptée

C'était déjà écrit dans mon avis (« La règle vaut pour toute cellule, avec ou sans valeur »), et D-S1-1 l'a retenu.

| | Interne | openxlsx |
|---|---|---|
| Avant (sortie avant du codeur) | 9 × 16385 en 6,21 s, `ok = TRUE` | 8 × 3 |
| Après | refus R5 | refus R5 |

Aucun tableur n'écrit au-delà de XFD : la forme est forgée. La ligne va dans le tableau avant / après, sans décision nouvelle.

## Q8. `<v >` et `<v xml:space="preserve">` lus par le chemin interne : visa du mainteneur requis

**Mesure** (`v-space`).
- Avant : refus en aval par le chemin interne ; openxlsx 104.2, σ_USP = 0.1114524114.
- Après : les deux chemins lisent 104.2, avec le même σ_USP.

**Avis favorable** : c'est une parité sans valeur nouvelle.

Mais `CLAUDE.md` soumet au mainteneur tout changement de σ_USP, et un σ_USP rendu là où il y avait un refus en est un, symétrique de D-S1-3 : visa requis (D2).

Réserve : le témoin de la sonde est présenté comme une « forme Excel ». Je ne connais pas d'Excel qui écrive `xml:space` sur `<v>` (Excel le met sur `<t>`, *hypothèse non vérifiée*). Le commit et la sonde doivent dire « forme XML légale », sauf preuve.

## Constat hors périmètre n° 1 du codeur : ordre des cellules (majeur, E1)

**Vérifié par mesure et par la source.**
- Ligne 1 écrite A1 `t`, C1 `yt`, B1 `xt` :
  - interne : σ_USP = 0.1114524114 ;
  - openxlsx : noms `t yt xt`, `xt` et `yt` permutés, `ok = TRUE`, σ_USP = 0.1764544949.
- Ligne 1 placée en fin de bloc : « attempt to set index -2/24 in SET_STRING_ELT ».
- Cause, dans `read_workbook.cpp` : `row_1 = rows[0]` ; `col_names[i] = v[pos]`, où `pos` suit l'ordre du document alors que `i` suit l'ordre des colonnes ; et `rows = rows - rows[0]` quand `skipEmptyRows` est FALSE.
- Ce n'est vrai qu'en tête. Lignes de données permutées (`ordre-rows`) et cellules d'une ligne de données dans le désordre (`ordre-l2`) : lues juste sur les deux chemins.
- Le défaut `rows - rows[0]` vaut aussi avec `colNames = FALSE` : la règle doit porter sur toute la feuille, pas sur le seul en-tête.

**Périmètre : dans #574**, comme règle R6b, plutôt qu'en issue nouvelle. L'objectif du contrat (« aucune valeur fausse acceptée, aucune erreur R brute ») et la fonction voisine (R6) sont les mêmes. Mais R6b n'est pas dans la liste R0-R12 que D-S1-1 a retenue, et refuse une forme lue juste en interne : rattachement et règle à confirmer par le mainteneur (D3, rattachement par `architect`).

**Règle proposée.**
- Dans l'ordre du document, les références de toutes les cellules (avec ou sans valeur) croissent strictement en lecture : ligne, puis colonne.
- R6b est évaluée après R6, pour qu'un doublon garde son propre message.
- L'ordre des lignes en découle pour toute ligne qui porte une cellule.
- **Aucune règle sur `<row r>`** ni sur l'ordre des `<row>` vides : aucun des deux chemins ne lit `<row r>` (mesure de l'avis amont ; `read.xlsx` est appelé sans `startRow` ni `rows`, `R/engine.R` l. 9757).

**Texte proposé** :

`Classeur illisible : cellules de la feuille lue placees hors de l'ordre de lecture (%s ; cellules attendues ligne par ligne, de haut en bas, puis de gauche a droite dans chaque ligne) ; l'outil ne lit pas cette forme de facon sure (une colonne pourrait etre mal nommee ou la lecture interrompue). Enregistrer de nouveau le classeur depuis un tableur.`

Position « B1 apres C1 », cinq au plus.

**Ce qu'écrivent les tableurs.** Excel répare un fichier aux cellules désordonnées, avec perte de données selon le rapport de bogue Apache POI 66687 (extrait de recherche, page non ouverte). MS-OI29500 indique, pour la seule section 18.14.13 (données de feuille externe), que les lignes doivent être croissantes pour Office (extrait de recherche ; `learn.microsoft.com` est injoignable depuis la session). Pour la feuille de calcul elle-même : *non vérifié*.

---

## Retour

- **Statut** : `revue requise`. Trois décisions du mainteneur (D1 à D3) et le visa des changements de résultat sont nécessaires.
- **Résultat** :

| Point | Avis |
|---|---|
| Q1 | règle acceptée, texte propre proposé |
| Q2 | règle acceptée, texte de R4 amendé |
| Q3 | accepté |
| Q4 | confirmé |
| Q5 | accepté, amendement de R8 |
| Q6 | refus recommandé, décision du mainteneur |
| Q7 | accepté |
| Q8 | avis favorable, visa du mainteneur |
| Constat 1 | R6b dans #574, règle et texte proposés |

- **Preuves.**
  - *Vérifié* :
    - source openxlsx 4.2.5.2, `getCellInfo()` (l. 158-410) et `read_workbook()` (l. 508-575) ;
    - 19 cas de `m.R` sur deux moteurs et deux chemins (`sortie.txt`) ;
    - 7 cas XFD de `m2.R`, résultats repris en Q5. La sortie de `m2.R` n'a pas été conservée : relancer la commande pour la reproduire ;
    - la sortie avant du codeur pour XFE10.
  - *Hypothèses* :
    - ce qu'écrivent Excel et LibreOffice : ordre des cellules, absence de `t="s"` ou `t="b"` sans `<v>`, de minuscules, de XML indenté, de `xml:space` sur `<v>` ;
    - rareté de « t= » dans un texte saisi après la dernière cellule.
  - *Non vérifié* :
    - openxlsx 4.2.9 ;
    - Windows ;
    - le texte normatif ECMA-376 sur l'ordre des cellules.
- **Informations manquantes** :
  - `learn.microsoft.com` doit être autorisé dans les réglages réseau de la session pour vérifier MS-OI29500 ;
  - le corpus réel de l'étape 10.
- **Décisions non résolues** (mainteneur) :
  - **D1** : refus des références en minuscules (renverse Q-A, décision 3 du 13/11/2026).
  - **D2** : visa du tableau avant / après du lot B, avec :
    - (a) en-tête ou pied de page portant « t= » : σ_USP rendu par les deux chemins, puis refus (groupe C) ;
    - (b) chaîne en ligne indentée : σ_USP rendu en interne, puis refus ;
    - (c) XFE10 sans valeur : σ_USP rendu par les deux chemins, puis refus ;
    - (d) `<v >` et `<v xml:space>` : refus en interne, puis σ_USP = 0.1114524114.
  - **D3** : rattachement de R6b à #574 et texte de R6b.
  - Pour information, sans décision : textes amendés de R3 (segment) et de R4 ; amendement de R8 pour le lot C.
- **Critères déclenchés** :
  - changement de résultat hors références (D2, et le lot C pour Q5) ;
  - écart à une décision antérieure du mainteneur (Q-A) ;
  - question qu'aucune source ne tranche : ce qu'écrivent réellement les tableurs ;
  - source injoignable : un problème de documentation disponible, non de lecture ;
  - aucun désaccord avec `audit` ni avec un ADR.
- **Constats hors périmètre** :
  1. Constat n° 1 du codeur (ordre des cellules) : critère **E1**, majeur (valeur fausse acceptée sans message, σ_USP 0.1765 au lieu de 0.1115), plus une erreur R brute. Je recommande de le traiter dans #574 (D3).
  2. Arrêt du processus R par openxlsx sur un pied de page portant ` t="s"` après la dernière cellule nombre, à `1818b4d` : critère **G**, mesuré. Le correctif de Q1 le ferme : dans le périmètre de #574.
  3. Mon avis amont affirmait à tort « attributs de `<row>` libres » : critère « aucun » (correction de l'avis, sans effet sur le code livré, que Q1 couvre).
  - Aucun autre constat.
- **Prochaine action recommandée** :
  1. La session soumet D1 à D3 au mainteneur.
  2. `coder-approfondi` applique ensuite les textes de Q1 et Q2, puis R6b et le refus des minuscules selon les décisions, et ajoute à la sonde `sonde_574_lot_b.R` les cas `entete-t`, `entete-t-s`, `indente-is`, `ordre-l1`, `ordre-row1-fin`, `minuscule` et `v-space` pour le tableau avant / après.
  3. Puis audit léger du diff.

Sources (extraits de recherche, pages non ouvertes) :
- [Apache POI, bogue 66687](https://bz.apache.org/bugzilla/show_bug.cgi?id=66687)
- [MS-OI29500, 2.1.846, section 18.14.13 sheetData](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oi29500/ea6eca83-ef44-428c-8d91-968009edc496) (hôte injoignable, extrait seul)