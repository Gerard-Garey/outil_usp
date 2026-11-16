# Avis d'actuary sur les questions du lot D de #574 (S1, étape 5) : règle R9, structure de `xl/sharedStrings.xml`

> *Rédigé par l'agent actuary (IA), fiche `actuary`, le 15/11/2026, sur `claude/lecteurs-contrat-ferme` (`1c206a7` et diff non commité du lot D). L'agent n'a écrit aucun fichier dans le dépôt. Versé intégralement par la session principale (Q-54-10). Scripts de mesure de l'agent, à verser s'il y a lieu sous `sondes/` : `/tmp/claude-0/-home-user-outil-usp/72e7dbb2-03bc-5232-8636-a08b44746855/scratchpad/actuaryD/sonde_actuary.R` (sonde du lot D, à laquelle 16 cas ont été ajoutés), `/tmp/claude-0/-home-user-outil-usp/72e7dbb2-03bc-5232-8636-a08b44746855/scratchpad/actuaryD/entete.R`, `/tmp/claude-0/-home-user-outil-usp/72e7dbb2-03bc-5232-8636-a08b44746855/scratchpad/actuaryD/entete2.R` et `/tmp/claude-0/-home-user-outil-usp/72e7dbb2-03bc-5232-8636-a08b44746855/scratchpad/actuaryD/na.R`. Sorties : `/tmp/claude-0/-home-user-outil-usp/72e7dbb2-03bc-5232-8636-a08b44746855/scratchpad/actuaryD/{int,ox}_{avant,apres}.txt`.*

## Synthèse

**Verdict sur le lot : validé avec réserves.** R9 met en œuvre le § 1 de l'avis amont et la décision D-S1-1. La structure codée coïncide exactement avec le schéma de SpreadsheetML (vérifié, voir Q1). Sur toutes les formes mesurées, aucune valeur différente n'est plus acceptée par les deux chemins. Trois points sont soumis au mainteneur : le visa du tableau avant / après, Q7 et le renversement des témoins de #572 (Q8).

| Q | Réponse | Décision du mainteneur ? |
|---|---|---|
| Q1 | **Garder la liste fermée, comme règle définitive et non provisoire.** Les 15 éléments sont exactement ceux de `CT_RPrElt` dans `sml.xsd` (ISO/IEC 29500-4:2016, Transitional). Ce sont des éléments à attributs seuls, en `xsd:choice maxOccurs="unbounded"` : l'ordre libre et la répétition admis par le code sont donc conformes. Il faut corriger le commentaire « citee de memoire, non verifiee ». | Non |
| Q2 | **Garder la règle conditionnelle.** Elle reproduit le déclencheur d'openxlsx (`"<rPr>"` littéral dans toute la partie). Le code de ce déclencheur est identique en 4.2.5.2 et en 4.2.9 (vérifié par diff des sources). La règle « un seul `<rPh>` » refuserait en plus des classeurs japonais lus juste par les deux chemins. | Non pour la règle. La forme refusée, qu'Excel peut écrire, figure au visa |
| Q3 | **Confirmer** : c'est la lettre du § 1 retenue par D-S1-1. Le refus n'est pas exigé par la parité. Si le corpus de l'étape 10 montre une extension réelle, l'assouplissement est sans risque pour la parité. | Non. Visa (forme lue juste, refusée) |
| Q4 | **Valider les deux règles.** Ce sont des valeurs fausses (groupe A). La seconde est même exigée par le critère de l'étape : 15 en interne, 1 par openxlsx, deux valeurs acceptées différentes. | Non. Visa |
| Q5 | **Acceptable.** Les textes de Q-F, P2 et X1 et leur ordre sont inchangés. Seule la règle qui se déclenche change, sur des tables mal formées, toutes refusées avant comme après. Je l'ai rejoué sur trois graines nouvelles. Le commit doit le dire. | Non |
| Q6 | **Admettre, sans refus et sans limite nouvelle.** Les valeurs sont identiques après le nettoyage des blancs. Le seul écart est le nom d'une colonne sans en-tête (« V4 » ou « »), déjà dans les limites listées. | Non |
| Q7 | **Ni issue, ni simple consignation.** La question est dans le périmètre de #574. Ma mesure montre une variante plus grave que la forme posée : un en-tête `x&#116;` en double, pour lequel openxlsx rend σ_USP = 0,0762262056 alors que le chemin interne refuse le doublon. Cela vaut aussi pour la chaîne en ligne, limite déjà listée. Je recommande un refus ciblé des références numériques de caractère désignant un caractère ASCII imprimable ; repli : consignation avec un libellé corrigé. Critère ADR 0018 : E1, forme forgée, gravité mineure. | **Oui** |
| Q8 | **Toutes les formes relèvent du groupe B** (hors schéma, ou préfixées selon la règle décidée), donc de D-S1-1. Le visa du tableau avant / après reste requis. **Le refus de `<t>` dans `<x:r>` renverse un correctif du 14/11** (« refus X1 à tort », passé alors à « ok, 11,5 ») : à nommer explicitement au visa, comme D-S1-9. | **Oui** (visa) |

Réserves sur le lot :
- (a) corriger le commentaire de `XML_ENFANTS_RPR` (Q1) ;
- (b) `<phoneticPr fontId="1"></phoneticPr>`, valide au schéma et lu juste, est refusé alors que `<rPr></rPr>` et `<b></b>` sont admis : l'admettre (recommandé) ou le porter au visa ;
- (c) décision Q7 ;
- (d) visa, avec mention explicite des témoins de #572 ;
- (e) facultatif : le texte de R9 dit « balise » alors que la position peut citer « texte » ou « caractere < hors d'une balise ».

---

## 0. Base de l'avis

- **Lu** :
  - le diff de `R/engine.R` : `.xlsx_controler_partagees()`, `XML_ENFANTS_RPR`, `TEXTE_REFUS_R9`, la réécriture de X1, R10 et les en-têtes ;
  - le diff de `tests/unitaires/test_controles_entree.R` ;
  - la sonde `sondes/sonde_574_lot_d.R` et ses sorties `sorties/574-lot-d-{avant,apres}.txt` ;
  - l'avis amont (§ 1 R9 et R10, § 2, § 8), les avis des lots B et C, `decisions-mainteneur.md` ;
  - le script `x1eq.R` du codeur ;
  - l'ADR 0018 (critères).
- **Sources d'openxlsx** :
  - 4.2.5.2 : `read_workbook.cpp`, `get_shared_strings()`, l. 14-140 ; `load_workbook.cpp`, `getNodes()`, l. 757-791 (copie de la session du lot B) ;
  - 4.2.9 : archive CRAN `openxlsx_4.2.9.tar.gz`, téléchargée dans `/tmp/claude-0/-home-user-outil-usp/72e7dbb2-03bc-5232-8636-a08b44746855/scratchpad/actuaryD/ox429/`. `diff` des deux fonctions : **identiques**. Côté R (`helperFunctions.R`, l. 880-896, `getSharedStringsFromFile()`), le post-traitement est `replaceXMLEntities()` : cinq entités prédéfinies seulement, aucune référence numérique.
- **Schéma** : copie locale `/mnt/skills/public/xlsx/scripts/office/schemas/ISO-IEC29500-4_2016/sml.xsd`, intitulée ISO/IEC 29500-4:2016 (Transitional). Provenance : un paquet d'outils présent dans l'environnement de la session, et non un téléchargement officiel authentifié. Son contenu recoupe l'extrait de recherche de MS-OI29500 § 2.1.674, qui donne la même liste de 15 enfants de `rPr`.
- **Mesures** (R 4.3.3, `LC_ALL=C.UTF-8`, un sous-processus par cas, chemin interne puis openxlsx 4.2.5.2, moteurs `1c206a7` et diff) : 16 cas ajoutés à la sonde du lot D, plus 6 cas d'en-tête.

## Q1. `XML_ENFANTS_RPR` : liste vérifiée, à garder fermée

**Vérifié dans `sml.xsd`** :
- `CT_RPrElt` est un `xsd:choice maxOccurs="unbounded"` de `rFont`, `charset`, `family`, `b`, `i`, `strike`, `outline`, `shadow`, `condense`, `extend`, `color`, `sz`, `u`, `vertAlign`, `scheme`. C'est **la liste exacte de la constante**, sans omission ni ajout.
- Les huit types de ces éléments (`CT_FontName`, `CT_IntProperty`, `CT_BooleanProperty`, `CT_Color`, `CT_FontSize`, `CT_UnderlineProperty`, `CT_VerticalAlignFontProperty`, `CT_FontScheme`) ne déclarent **aucun élément enfant**, et aucun n'est `mixed`. La règle « sans enfant », complétée par la règle du texte hors de `<t>`, est donc exacte.
- Le choix non borné admet l'ordre libre et la répétition. Le code les admet. Mesures : `q1-ordre-libre` (`<sz/><b/><b/><rFont/>`) et `q1-b-ouvert` (`<b></b>`) sont lus 11,5 par les deux chemins, avant comme après.
- MS-OI29500 indiquerait qu'Excel exige un ordre propre (extrait de recherche ; `learn.microsoft.com` injoignable). Cela ne touche pas la lecture, puisque l'ordre n'est pas contrôlé.

**Motif de la liste fermée.** openxlsx concatène, dans une table qui porte `<rPr>`, le texte de toute balise qui commence par `<t` (`xml.find("<t")`). Aucun des 15 éléments ne commence par « t ». Un élément inconnu peut en revanche commencer par « t » (`<tz>` est lu « 91 »). La liste fermée est donc la garantie exacte. Mesure complémentaire : `<rPr><b>9</b></rPr>`, lu 1 par les deux chemins avant le lot, est refusé par la règle du texte (groupe B).

**À faire, sans décision** : remplacer dans le commentaire « liste citee de memoire, non verifiee sur le texte du schema ; a confirmer par le corpus de l'etape 10 » par la source : `CT_RPrElt`, ISO/IEC 29500-4:2016, `sml.xsd`. Le schéma Strict (ISO/IEC 29500-1) n'a pas été consulté.

## Q2. Second `<rPh>` dans une table à `<rPr>` : garder la règle conditionnelle

**Mécanisme** (source, identique en 4.2.5.2 et 4.2.9) :
- `get_shared_strings()` ne retire que le **premier** bloc `<rPh` de chaque `<si>`.
- Si la partie contient la suite littérale `"<rPr>"`, il concatène ensuite tous les `<t` restants ; sinon il ne lit que le premier.
- Le second `<rPh>` n'est donc lu, à tort, que dans le premier cas.
- La règle du codeur teste la même suite sur la même partie entière (`grepl("<rPr>", sx, fixed = TRUE)`). Mesure `q2-rpr-dans-extlst` : `<rPr></rPr>` placé dans un `<extLst>` bascule bien openxlsx (« 117 », σ_USP = 0,1170143382) et R9 refuse bien la table.

**Mesure nouvelle, forme d'Excel japonais** (`q2-japonais-rpr` : deux `<r>` avec `<rPr>`, deux `<rPh>`, `<phoneticPr/>`) :

| | Avant | Après |
|---|---|---|
| Interne | 11,5 ; σ_USP = 0,2005042338 | refus R9 « chaine no 0 : balise <rPh> » |
| openxlsx | **11,57 ; σ_USP = 0,2004928854** | même refus |

C'est une valeur fausse (groupe A), et la règle la ferme.

**Pourquoi la règle conditionnelle plutôt que « un seul `<rPh>` »** :
1. Elle refuse exactement l'écart.
2. La règle inconditionnelle refuserait `ok-rph-second-sans-rpr` (un `<t>` et deux `<rPh>`, sans `<rPr>` dans la table), lu 11,5 par les deux chemins : c'est la forme japonaise sans mise en forme riche.
3. La condition est peu sensible à une évolution d'openxlsx. Avec Q-F, toute table qui porte un `<r>` porte un `<rPr>` littéral, et `<rPr>` n'est admis que dans `<r>` (ou dans `<extLst>`). « Table à `<rPr>` » équivaut donc à « table à `<r>` », et un déclencheur légèrement différent dans une version future donnerait la même partition. Cette différence avec le lot B (Q1), où j'avais préféré la règle prudente, tient au coût : la règle prudente refuserait ici une forme lue juste qu'Excel écrit.

**Garde-fou** : le témoin « second `<rPh>`, table sans `<rPr>` : lu sur chaque chemin » est dans la batterie. Le job de parité épingle 4.2.5.2, si bien qu'une version future ne sera détectée que par la batterie lancée sur le poste du mainteneur. À dire dans le commentaire.

**Visa** : refuser une forme qu'Excel peut écrire (chaîne japonaise riche à plusieurs groupes phonétiques) relève du groupe A (valeur fausse par openxlsx), donc de D-S1-1. Je recommande de la nommer dans le tableau avant / après. Qu'un classeur d'assureur français porte une telle chaîne dans **toute** la table partagée (toutes feuilles confondues) est une *hypothèse* de rareté.

## Q3. Préfixes interdits jusque dans `<extLst>` : confirmer

- **Schéma** (vérifié) : `CT_Sst` = `si*`, `extLst?`. `CT_Extension` = `xsd:any processContents="lax"`, avec l'attribut `uri`. Le contenu d'une extension est donc par construction d'un autre espace de noms, en pratique préfixé. Interdire les préfixes dans `<extLst>` revient à refuser toute extension non vide, sauf celle qui redéclare l'espace par défaut (mesure : `<a xmlns="urn:x14"><b/></a>` est admis). C'est une distinction de forme, sans portée sémantique.
- **Parité** (source) : openxlsx ne voit d'une extension que trois choses :
  - les `<si>` exacts (`getNodes`) : refusés dans `<extLst>` indépendamment des préfixes ;
  - la suite `<rPr>` : reproduite par la règle de Q2 ;
  - rien d'autre, car `<t` n'est cherché qu'à l'intérieur de chaque `<si>`.
- Le refus n'est donc **pas exigé par la parité**. C'est la lettre de mon § 1 (« Aucune balise préfixée dans toute la table »), retenue par D-S1-1.
- **Recommandation** : confirmer et porter `prefixe-dans-extlst` au visa (lu 11,5, σ_USP = 0,2005042338, puis refus). Je ne connais aucune extension de `sst` écrite par Excel : *hypothèse non vérifiée*, MS-XLSX n'ayant pas été consulté. Si le corpus de l'étape 10 en montre une, ne plus examiner le contenu d'`<extLst>` au-delà de la bonne formation et de l'absence de `<si>` est sans risque pour la parité, au vu de la source.

## Q4. Règles ajoutées hors lettre du § 1 : validées

| Forme | Avant (interne / openxlsx) | Classement |
|---|---|---|
| `<rPh>` dans une `<si>` sans `<t>` ni `<r>`, deux `<rPh>` (`rph-sans-t`) | « » refusé en aval / **« 7 », σ_USP = 0,1984143656** | Groupe A |
| `<t/>` dans une chaîne à `<r>` (`t-vide-dans-r`) | **15, σ_USP = 0,1989114678** / **1, σ_USP = 0,1700579153** | **Deux valeurs acceptées différentes** : la règle est exigée par le critère de l'étape |

- Les deux formes sont valides au schéma (`CT_Rst` est tout facultatif ; le `t` de `CT_RElt` est un `ST_Xstring`, éventuellement vide). Ce n'est donc pas la lettre du § 1 qui les ferme, mais l'objectif du contrat : un amendement de mon texte, que j'accepte.
- La première règle refuse aussi le cas à un seul `<rPh>` sans `<t>`, lu « » (vide) par les deux chemins : refus sans coût, aucun σ_USP n'étant possible sur une cellule vide.
- La seconde vise `<t/>` et `<t />` (genre « vide »). `<t></t>` reste admis : openxlsx ne s'arrête qu'au `/` placé en `pos+2`, et la parité est mesurée.
- `<t/>` en tête de chaîne suivi de `<r>` est couvert (`pn == "si"`). openxlsx y rend NA, l'interne le texte des `<r>`.

## Q5. X1 en expressions linéaires : acceptable

- Le texte des trois refus existants et leur ordre (Q-F, P2, X1, puis la règle générale) sont **inchangés**. C'est ce que demandait le § 2 de l'avis amont.
- **Équivalence** sur une table bien formée sans bloc imbriqué :
  - le contenu d'un bloc `<rPh>` ou `<r>` ne contient pas d'autre ouvrante du même élément, si bien que `(?:(?!<e…).)*?` coïncide avec `.*?` ;
  - une valeur d'attribut ne contient pas `<` (interdit en XML), si bien que l'automate des attributs coïncide.
  - L'argument est exact.
- **Rejoué** (`x1eq.R` du codeur, graines 101, 202, 303, 5 000 tables chacune) :
  - 174, 174 et 172 verdicts X1 différents, soit environ 3,5 % ;
  - 2, 1 et 1 « refus X1 perdus » ;
  - **toutes les tables concernées sont refusées par R9**.
  - Les exemples affichés sont des tables grossièrement mal formées (`<rPh a=">`, blocs non fermés, `<` isolés).
- **Effet** : sur ces tables forgées, le texte restitué passe de X1 à R9, ou inversement. Le fait d'accepter ou de refuser ne change pas, et aucun σ_USP ni verdict n'est touché. À écrire dans le commit et dans le tableau avant / après, sans décision.

## Q6. `<t />`, `<t\n/>` : admettre, rien à consigner de nouveau

Mesures, interne puis openxlsx, identiques avant et après :

| Cas | Valeur lue | Issue |
|---|---|---|
| `q6-t-espace` | « » / « » | refus en aval sur les deux chemins, même motif |
| `q6-t-espace-nl` | « » / « \n » | idem |
| `q6-t-espace-rpr` | « » / « ␣␣ » | idem |
| `q6-si-blancs-rpr` (`<si>␣␣\n␣</si>`, forme du contrat) | « » / « ␣␣\n␣ » | idem |
| En-tête de la colonne D (non utilisée) | noms `V4` / « » | σ_USP = 0,1114524114 sur les deux chemins |
| En-tête de la colonne B | — | même refus sur les deux chemins (« Colonnes presentes : t, (vide), yt ») |

- `.nettoyer_cellules()` retire les blancs de tête et de fin : les deux lectures donnent la même valeur pour le moteur.
- Le seul écart est le nom d'une colonne sans en-tête, déjà dans les limites listées (« le nom d'une colonne sans en-tête »).
- Ce n'est ni deux valeurs acceptées, ni un refus d'un seul côté. Aucun refus ni aucune limite nouvelle n'est requis. La même divergence existe déjà sur `<si>` à blancs, que le contrat admet.

## Q7. Références numériques de caractère dans `<t>` : refus ciblé recommandé, décision du mainteneur

**Mécanisme** : openxlsx ne décode que les cinq entités prédéfinies, après `get_shared_strings()` (`replaceXMLEntities()`, 4.2.9, vérifié dans la source). Le chemin interne décode aussi `&#NNN;` et `&#xHH;` (`.xml_decoder()`), ce qui est la lecture juste au sens de XML.

**Mesures** (interne / openxlsx, identiques avant et après le lot) :

| Cas | Interne | openxlsx |
|---|---|---|
| `<t>1&#48;4.2</t>`, `1&#x30;4.2`, `104&#46;2` en B2 | 104,2 ; σ_USP = 0,1114524114 | texte littéral, refus en aval |
| En-tête B1 `x&#116;` (chaîne partagée) | `xt`, σ_USP = 0,1114524114 | « Colonne(s) manquante(s) : xt », refus |
| **En-tête B1 `x&#116;` et D1 `xt`** (partagée) | **refus « En-tete xt present plusieurs fois (colonnes 2, 4) »** | **σ_USP = 0,0762262056**, colonne D prise en silence |
| Même cas, B1 en chaîne en ligne | refus doublon | **σ_USP = 0,0762262056** |
| Même cas, B1 en `t="str"` | `x&#116;` littéral, σ_USP = 0,0762262056 | idem (parité : aucun des deux ne décode) |

- Les trois premières lignes relèvent bien de la catégorie « refus d'un côté, lecture juste de l'autre ». Le mécanisme est celui de la limite déjà listée pour la chaîne en ligne.
- **La ligne du doublon n'en relève pas.** openxlsx rend un σ_USP en choisissant en silence entre deux colonnes `xt`, sur une lecture fausse de l'en-tête. C'est ce que R6 refuse au niveau de la cellule (« l'outil ne choisit pas entre deux valeurs »). Le cas vaut aussi pour la chaîne en ligne : **la limite des entités que j'ai listée au § 1 de l'avis amont n'est donc pas « sans valeur fausse »**. C'est une correction de mon avis.

**Recommandation tranchée** : un refus ciblé, dans le texte d'un `<t>` de la table partagée (R9) et d'une chaîne en ligne (R3). Il porte sur toute référence numérique de caractère désignant un caractère ASCII imprimable (U+0020 à U+007E) **autre que** `"`, `&`, `'`, `<` et `>`.
- Il ferme la valeur et le doublon par construction.
- Il épargne les échappements qu'un sérialiseur produit réellement :
  - les cinq caractères XML, parfois écrits `&#38;`, `&#39;` ou `&#x27;` ;
  - les fins de ligne (`&#10;`, `&#xD;`) ;
  - les caractères non ASCII (`&#233;`).
  - Qu'aucun sérialiseur n'écrive en référence numérique une lettre ou un chiffre ASCII est une *hypothèse*, que le corpus de l'étape 10 éprouvera.
- Texte proposé, dans le gabarit commun : `Classeur illisible : %s porte un caractere ordinaire ecrit sous forme de reference numerique (%s) ; l'outil ne lit pas cette forme de facon sure (une valeur ou un en-tete pourrait etre mal lu). Enregistrer de nouveau le classeur depuis un tableur.` Position : « chaine no 3 : &#48; » ou « B1 : &#116; ».
- **Repli** : consigner dans les limites listées (a) la forme valeur dans une chaîne partagée et (b) le cas du doublon, partagé et en ligne, en corrigeant le libellé de la limite (« un en-tete ecrit par reference numerique peut faire prendre une autre colonne du meme nom par openxlsx »).
- **Décision du mainteneur** : le refus vise une forme lue juste par le chemin interne. Effet : 0,1114524114 devient un refus en interne, 0,0762262056 devient un refus par openxlsx. Au visa.
- **ADR 0018** : critère **E1** (σ_USP refusé à tort par openxlsx pour la valeur ; rendu à tort pour le doublon), gravité mineure, forme forgée. **Dans le périmètre de #574** (critère de parité de l'étape 5, limite listée au § 1) : pas d'issue nouvelle.

## Q8. Formes lues juste et désormais refusées : groupe B, visa requis

Les sorties avant montrent 11,5 et σ_USP = 0,2005042338 sur les deux chemins pour `rphx`, `tab`, `x-tab`, `x-r-t`, `texte-hors-t`, `prefixe-dans-extlst`, `SI-majuscules` et `t-apres-rph`. Les sorties après montrent le refus R9 sur les deux chemins.

| Forme | Fondement, vérifié dans `sml.xsd` sauf mention | Avis |
|---|---|---|
| `<rPhX/>`, `<tab/>`, `<tabx/>` | Absents de `CT_Rst`. openxlsx les prend pour `<rPh` ou `<t` (préfixe de chaîne) | B. Le risque d'écart est réel dans d'autres agencements |
| `<x:tab/>`, préfixe dans `<extLst>` | Règle « aucune balise préfixée » (D-S1-1) | B, voir Q3 |
| Texte hors de `<t>` | `CT_Rst` n'a que des éléments (pas `mixed`) | B |
| `<SI>` | XML est sensible à la casse : élément inconnu | B |
| `<t>` après `<rPh>` | `CT_Rst` est une séquence : `t`, puis `r`, puis `rPh` | B |
| **`<t>` dans `<x:r>`** (deux témoins de #572) | Règle « aucune balise préfixée » | B, mais **renverse un correctif du 14/11** (`docs/revues/20261114-k2b-etapes-9-10/coder-approfondi-reprise-m1.md`, l. 41 : « refus X1 à tort » passé à « ok, 11,5 ») : à nommer au visa, comme D-S1-9 pour Q-A |

- Aucune n'est écrite par un tableur, à ma connaissance : *hypothèse*. Un écrivain qui préfixe (Open XML SDK) préfixe toute la table, que openxlsx ne lisait déjà pas (erreur R brute, avis amont § 0) ; la refuser est un gain.
- Comme pour le lot C (point 5), aucune décision nouvelle de fond n'est requise : le § 1 énumère la structure. Chaque forme fait passer d'un σ_USP rendu à un refus, et va au tableau avant / après soumis au visa.

**À ajouter au tableau, groupe A (valeur fausse avant le lot)** :

| Forme | Avant |
|---|---|
| #574 (1) | 11,5 au lieu de 9, sur les deux chemins |
| #574 (2) | 11,57 par openxlsx |
| `<si/>` | 9 au lieu de la chaîne vide, sur les deux chemins |
| `<si >` | 9 au lieu de 11,5, sur les deux chemins |
| `<si>` dans `<extLst>` | 7, sur les deux chemins |
| `rph-second-table-rpr` | 117 |
| `rph-sans-t` | 7 |
| `t-vide-dans-r` | 15 en interne, 1 par openxlsx |
| `rpr-element-tz` | 91 |
| `q2-japonais-rpr` | 11,57 |

**À ajouter, groupe B** : `<b>9</b>` dans `<rPr>` (lu 1 sur les deux chemins, σ_USP = 0,1700579153).

**Réserve (b)** : `<phoneticPr fontId="1"></phoneticPr>` est refusé (mesure directe, « balise <phoneticPr> »).
- La forme est valide au schéma (`CT_PhoneticPr`, à attributs seuls) et aucun chemin ne la lit mal : `<phoneticPr` n'est ni `<rPh` ni `<t`.
- Le code admet pourtant `<rPr></rPr>` et `<b></b>`.
- Je recommande de l'admettre (élément sans enfant ni texte, comme les enfants de `<rPr>`) ; à défaut, de la porter au visa.

---

## Retour

- **Statut** : `revue requise`. L'avis est complet. Le visa du tableau avant / après, la décision Q7 et le renversement des témoins de #572 reviennent au mainteneur.
- **Résultat** :
  - lot D **validé avec réserves**, (a) à (e) de la synthèse ;
  - Q1 : garder la liste, vérifiée ;
  - Q2 : garder la règle conditionnelle ;
  - Q3 : confirmer ;
  - Q4 : valider ;
  - Q5 : acceptable ;
  - Q6 : admettre ;
  - Q7 : refus ciblé recommandé (repli : consignation corrigée) ;
  - Q8 : groupe B, visa requis.
- **Preuves**
  - *Vérifié* :
    - `CT_Sst`, `CT_Rst`, `CT_RElt`, `CT_RPrElt` (les 15 éléments, choix non borné), `CT_PhoneticRun` (`sb`, `eb` requis), `CT_PhoneticPr` et les huit types des enfants de `rPr` (aucun enfant), dans `/mnt/skills/public/xlsx/scripts/office/schemas/ISO-IEC29500-4_2016/sml.xsd`. Copie locale, provenance non authentifiée, recoupée par l'extrait MS-OI29500 § 2.1.674 ;
    - source d'openxlsx : `get_shared_strings()` et `getNodes()` identiques en 4.2.5.2 et 4.2.9 (`diff`, archive CRAN) ; `replaceXMLEntities()` limité aux cinq entités ;
    - mesures de la sonde étendue (16 cas × 2 moteurs × 2 chemins, 64 sous-processus, code de sortie 0) et des 6 cas d'en-tête, valeurs citées ci-dessus ;
    - `x1eq.R` rejoué sur trois graines nouvelles ;
    - sorties avant / après du codeur, relues cas par cas ;
    - la parité de « NA » et « true » en chaîne partagée est déjà assurée : même refus sur les deux chemins (mesure `na.R`).
  - *Relevé, non rejoué* : la batterie du codeur (3881 assertions, 0 échec) et la comparaison des six références à l'écart 0 (`lotD/tu2.txt`, `lotD/cmp2.txt`).
  - *Hypothèses* :
    - aucun tableur n'écrit les formes du groupe B, ni une lettre ou un chiffre ASCII en référence numérique ;
    - aucune extension de `sst` n'est écrite par Excel ;
    - les chaînes japonaises à plusieurs groupes phonétiques sont rares dans un classeur d'assureur français.
  - *Non vérifiés* :
    - schéma Strict (ISO/IEC 29500-1) ;
    - MS-XLSX (extensions de `sst`) ;
    - comportement réel d'openxlsx 4.2.9 (source identique, non exécutée) ;
    - Windows ;
    - effet du retrait des lignes vides par `getline` dans openxlsx (déduit de la source, non mesuré).
- **Informations manquantes** :
  - `learn.microsoft.com`, `raw.githubusercontent.com` et `hackage.haskell.org` sont injoignables : il faudrait les autoriser dans les réglages réseau de la session pour citer MS-OI29500 et MS-XLSX ;
  - corpus réel de l'étape 10.
- **Décisions non résolues** (mainteneur) :
  1. Q7 : refus ciblé des références numériques désignant un caractère ASCII imprimable, ou consignation au libellé corrigé ;
  2. visa du tableau avant / après du lot D (groupes A et B ci-dessus, Q3, Q4, forme japonaise de Q2), avec mention explicite du renversement des témoins `<x:r><t>` de #572 (14/11) ;
  3. pour information : réserve (b) sur `<phoneticPr></phoneticPr>`, et amendement facultatif du texte de R9 (« une balise ou un texte non prevus »), qui est mon propre texte.
- **Critères déclenchés** :
  - changement de résultat hors références : σ_USP rendu, puis refus ;
  - écart à une décision ou à un correctif antérieur : témoins de #572 du 14/11 ;
  - correction de mon avis amont : la limite des entités n'est pas « sans valeur fausse » ;
  - sources injoignables : un problème de documentation disponible, non de lecture ;
  - aucun désaccord avec `audit` ni avec un ADR.
- **Constats hors périmètre** (ADR 0018) :
  1. `sml.xsd` (Transitional) confirme les attributs de `CT_Cell` (`r`, `s`, `t`, `cm`, `vm`, `ph`), donnés de mémoire dans l'avis amont, et montre que `ST_CellType` ne contient pas `d` (seulement `b`, `n`, `e`, `s`, `str`, `inlineStr`). Les points « non vérifiés » de l'avis amont sont levés. Critère « aucun » (confirmation, sans effet sur le code).
  2. openxlsx lit `sharedStrings.xml` par `getline` en sautant les lignes vides (`read_workbook.cpp`, l. 27-31) : un `<t xml:space="preserve">` qui contient une ligne vide perd celle-ci sur ce chemin. Le texte n'est pas numérique, et la valeur est la même après le nettoyage des blancs. Critère « aucun » ; déduit de la source, non mesuré.
  3. Dans le lot (pour mémoire, non hors périmètre) : `<sst>` admet `<extLst>` avant les `<si>` et plusieurs `<extLst>` (mesure). C'est contraire à l'ordre de `CT_Sst`, mais sans effet sur aucune lecture. Critère « aucun ».
  - Aucun autre constat.
- **Prochaine action recommandée** :
  1. La session soumet au mainteneur la décision Q7 et le visa du lot D (point 2 ci-dessus).
  2. `coder-approfondi` corrige le commentaire de `XML_ENFANTS_RPR`, traite la réserve (b), applique Q7 selon la décision, et complète la sonde et le tableau avant / après avec les cas `q2-japonais-rpr`, `q2-rpr-dans-extlst`, `q1-texte-dans-b`, `q3-ext-x14` et ceux de Q7, dont le doublon.
  3. Puis `audit` léger du diff.

### Sources

- Copie locale du schéma : `/mnt/skills/public/xlsx/scripts/office/schemas/ISO-IEC29500-4_2016/sml.xsd` (`CT_Sst`, `CT_Rst`, `CT_RElt`, `CT_RPrElt`, `CT_PhoneticRun`, `CT_PhoneticPr`, `CT_Cell`, `ST_CellType`, `CT_Extension`).
- openxlsx 4.2.9, archive CRAN (`cloud.r-project.org`), `src/read_workbook.cpp`, `src/load_workbook.cpp`, `R/helperFunctions.R` ; openxlsx 4.2.5.2, copie de la session du lot B.
- [MS-OI29500, 2.1.674, Part 1 Section 18.4.7, rPr (Run Properties)](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oi29500/29f6b809-5f1a-4b2b-b65a-0286a0758460) : extrait de recherche seul, hôte injoignable.
