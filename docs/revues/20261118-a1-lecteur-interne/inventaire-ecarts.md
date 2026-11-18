> *Rédigé par l'agent actuary (IA).* Fiche `actuary-approfondi`, 18/11/2026, lecture seule, sur `claude/creneau-a1` à `77c84ae`. Étape 1a d'A1 (#604), condition 10 de l'ADR 0020, décision Q-68-6 (a). Versé intégralement par la session principale.
>
> *Notes de la session* :
> - la sonde de l'agent est versée sous `sonde-inventaire.R`, avec un dossier de travail passé en argument ; la session l'a relancée le 18/11 sous `openxlsx` 4.2.5.2 (`sortie-sonde-inventaire.txt`), et C1 se reproduit à l'identique ;
> - XML 1.0 a été relu à la source après la rédaction de cet inventaire (étape 1c, `relecture-xml-1.0.md`). Le § 2.11 y confirme le jugement porté sur A14. Les références de caractère du contenu (C1) relèvent du § 4.1, que cette relecture ne cite pas.

# Inventaire des écarts consignés entre le lecteur interne et `openxlsx::read.xlsx()`

## Point d'arrêt B : à signaler en tête

**1. Aucun écart consigné entre les deux chemins ne donne tort au lecteur interne, hors #602.**
- Il y a 14 écarts sur des classeurs admis (§ 1). Dans tous, sauf A14 (#602), le lecteur interne est juste ou l'écart est sans effet. Le tableau du § 1 en donne le détail.
- L'hypothèse de mon avis précédent (§ 5) et du « Contexte » de l'ADR 0020 est donc confirmée pour les écarts *entre* chemins.

**2. Candidat au point B, hors de la définition stricte : C1, défaut commun aux deux chemins.**
- **Forme.** Une cellule `t="str"` (texte d'un résultat de formule) dont le `<v>` porte une référence de caractère, par exemple l'en-tête B1 `x&#116;` alors que D1 vaut `xt`.
- **Ce que font les deux chemins.** Ils lisent tous deux B1 « `x&#116;` », sans le décoder. Ils retiennent alors **en silence** la colonne D pour `xt`, et le classeur passe l'aval (`ok = TRUE`).
- **Ce que donnerait une lecture fidèle à la source.** B1 vaut « `xt` », il y a donc un doublon, et la règle des en-têtes en double refuse le classeur. C'est exactement le scénario que D-S1-18 a jugé être une lecture fausse, avec un σ_USP rendu à tort (sonde du lot E). Mais la règle des références numériques ne couvre pas `t="str"`, puisque les deux chemins y lisaient la même chose.
- *Vérifié* par mesure (§ 3), sur les deux chemins, avec `openxlsx` 4.2.5.2.
- **Pourquoi c'est un candidat.** Ce n'est pas un écart entre chemins : les deux lectures sont identiques. Mais c'est un écart du lecteur interne à la source, ce que la règle de lecture de l'ADR 0020 (point 3) rend désormais bloquant.
- **Critères ADR 0018 invoqués.**
  - E1 : σ_USP rendu à tort, sur un classeur forgé.
  - E5 : le `.tex`, l. 5475-5478, affirme « ne peut donner de valeur fausse (raisonnement, non mesuré) ».
- **Limite.** Aucun écrivain connu n'écrit une lettre ASCII en référence numérique dans un `<v>`. C'est la même hypothèse que celle de D-S1-18.
- **Décision.** À la session et au mainteneur : point B (place libre d'A1) ou ligne écartée.

**3. Nuance sur #602 (mesurée).**
- Avec `openxlsx` 4.2.5.2 sous Linux, un retour chariot littéral dans une chaîne en ligne est lu `"a\r\nb"` et `"c\rd"` **par les deux chemins**.
- `openxlsx` n'est donc « juste » que dans la configuration de l'issue : version 4.2.9 sous Windows.
- Le mécanisme supposé, une lecture en mode texte, est une *hypothèse*.

## Conventions

- **Valeurs employées** : `t`, `xt`, `yt` et le triangle, après `engine_lire_donnees_csv()` ou `engine_lire_triangle()`.
- **Classes** (consigne du brief) :
  - **I** : lecteur interne juste, et l'écart change ce qui est lu ou s'il y a lecture ;
  - **O** : `openxlsx` juste ;
  - **S** : sans effet sur les valeurs employées (la colonne « qui a raison » est remplie quand même) ;
  - **R** : refusé par l'admission sur les deux chemins.
- **Statut de chaque ligne** :
  - *vérifié* : ce que lit chaque chemin est cité d'une source lue (ligne du `.tex`, du code ou du test), ou remesuré ici ;
  - *hypothèse* : jugement non établi par une source lue ;
  - *non vérifié* : ni source lue ni mesure.
- **Le jugement « juste »** repose sur la sémantique de XML 1.0 et des espaces de noms : décodage des références, normalisation des fins de ligne, éléments et attributs préfixés. Ces textes n'ont **pas été relus à la source** dans cette session (étape 1c, `www.w3.org` injoignable). Ce jugement est donc une *hypothèse fondée*. Seule la description des lectures est *vérifiée*.
- **Version d'`openxlsx`.** Sauf mention contraire, les lectures citées sont celles de la version 4.2.5.2, celle de la CI. Une assertion du job de parité, vert sans ligne « [saute] », vaut mesure sous 4.2.5.2.

## 1. Écarts sur des classeurs admis (14)

| # | Forme du classeur | Lecteur interne | `openxlsx` | Classe | Motif et source | Effet du retrait sur un poste muni d'`openxlsx` | Statut |
|---|---|---|---|---|---|---|---|
| A1 | Balises `<sheet>` et `<Relationship>` préfixées (`<x:sheet>`, `<p:Relationship>`), y compris `<x:Relationship<TAB>` | lit la feuille désignée (`xt` = 1, 3) | erreur R (« Workbook has no worksheets » ou « Length of worksheet is 0 »), affichée par le message fixe de l'application | **I** | L'élément préfixé lié au bon espace de noms est le même élément. Sources : `.tex` l. 5482-5490 et l. 968-976 ; `R/engine.R` l. 11572-11577 et l. 9829-9832 ; test l. 2856 et l. 3957 (exécutés en CI sous 4.2.5.2) | classeur lu au lieu d'une erreur R | *vérifié* (lectures) ; jugement : *hypothèse fondée* |
| A2 | Attributs `r:id`, `Id` ou `Target` entre apostrophes ou à blancs autour de `=`, sur la feuille lue (classeur d'une feuille, ou feuille lue sans autre désignation possible) | lit juste | erreur R (« Length of worksheet is 0 ») | **I** | Les apostrophes et les blancs autour de `=` sont du XML bien formé. Sources : `.tex` l. 5482-5490 et l. 5286-5302 ; `R/engine.R` l. 9957-9968 et l. 9998-10001 ; test l. 2856, l. 3839 et l. 3957 | lu au lieu d'une erreur R | *vérifié* ; jugement : *hypothèse fondée* |
| A3 | Cible de feuille `./worksheets/sheet1.xml` | lit juste (`xt` = 11, 13, remesuré) | erreur « Length of worksheet is 0 » (**remesuré ici sous 4.2.5.2**) | **I** | Le segment `.` est un chemin relatif équivalent. Sources : `.tex` l. 5485-5490 ; `R/engine.R` l. 11567-11570, qui date la mesure de 4.2.9 alors que le `.tex` dit « 4.2.5.2 seulement » (écart de version, constat m1) | lu au lieu d'une erreur R | *vérifié* (mesure § 3) |
| A4 | Seconde entrée de l'archive de même nom que `xl/workbook.xml`, que ses relations ou que la feuille lue, dans un autre dossier | lit juste | erreur R (4.2.5.2) | **I** | La partie est désignée par son chemin complet. Sources : `.tex` l. 5492-5495 ; #595, « Pistes » | lu au lieu d'une erreur R | *vérifié* (`.tex`) ; non remesuré |
| A5 | Colonne dont toutes les cellules à valeur sont booléennes (`t="b"`) ou des textes « TRUE » / « FALSE » ; en particulier la colonne logique écrite par l'écrivain interne | caractères « TRUE » / « FALSE » | logique | **S** | Même refus en aval, aux mêmes positions et avec le même motif, par `.en_numerique()` depuis #579. Ignorée hors de `t`, `xt`, `yt` et du triangle. Pour des cellules texte, la conversion en logique d'`openxlsx` s'écarte de la source ; pour `t="b"`, les deux représentations sont fidèles. Sources : `.tex` l. 5510-5516, l. 984-985 et l. 1141-1145 ; `R/engine.R` l. 11677-11683 et l. 9003-9006 ; test l. 2638, l. 2641, l. 2645 et l. 6833 ; #579 | colonne rendue en caractères au lieu de logique ; même refus en aval | *vérifié* (remesuré pour l'écrivain, § 3) |
| A6 | Texte « true » ou « False » en chaîne partagée | « true » | « TRUE » | **S** | Le texte de la source est « true ». Ce n'est un nombre sur aucun des deux chemins. Sources : `.tex` l. 5478-5481 ; `R/engine.R` l. 10823 | « true » gardé | *vérifié* (remesuré § 3) |
| A7 | « `&amp;lt;1` » en chaîne partagée | « `&lt;1` » (un seul décodage) | « `<1` » (double décodage) | **S** | La source vaut « &lt;1 ». Pas un nombre. Sources : `.tex` l. 5478-5481 ; `R/engine.R` l. 10822 et l. 11491-11492 | « `&lt;1` » au lieu de « `<1` » | *vérifié* (remesuré) |
| A8 | Entités nommées d'une **chaîne en ligne** : en-tête « `l&amp;b` », texte « `a&lt;b&amp;c` », écrits ainsi par l'écrivain interne | « `l&b` », « `a<b&c` » | laissées telles quelles | **S** | Les exports de l'application ont des en-têtes fixes et des cellules numériques. `t`, `xt`, `yt` et un nombre ne s'écrivent pas avec une entité. Sources : `.tex` l. 1141-1145 ; `R/engine.R` l. 8999-9006 et l. 11511-11519 ; `test_controles_entree.R` l. 6818-6838 | textes décodés | *vérifié* (remesuré sous 4.2.5.2 ; le `.tex` cite 4.2.9) |
| A9 | Références numériques **admises** (`&#1;` à `&#8;`, `&#14;` à `&#31;`, `&#127;`, U+0085, U+00A0, U+2007, U+200B, U+202F, autres caractères non ASCII, les cinq caractères d'échappement) | décodées (`104.2&#160;` lu « 104.2 » suivi de l'espace insécable ; `&#233;` lu « é ») | gardées littérales | **S** | Même colonne retenue, même refus en aval d'une valeur non numérique. Sources : `.tex` l. 5408-5413 ; `R/engine.R` l. 11061-11072 | textes décodés | *vérifié* (remesuré pour `&#160;` et `&#233;`) |
| A10 | Lignes vides à l'intérieur d'un texte (`1\n\n2`), en table partagée ou en chaîne en ligne | « `1\n\n2` » | « `1\n2` » | **S** | Le texte de la source est gardé par le lecteur interne. Source : `R/engine.R` l. 10823-10827. **Non consigné au `.tex`.** | texte gardé tel qu'écrit | *vérifié* (remesuré, chaîne en ligne) |
| A11 | `<t/>` d'une chaîne en ligne ; `<si></si>` ou `<si><t/></si>` en table | « » (chaîne vide) | `NA` | **S** | Les deux sont « sans valeur » en aval (même verdict). Sources : `R/engine.R` l. 10396-10399 et l. 10828-10830. Non consigné au `.tex` | chaîne vide au lieu de `NA` | *vérifié* (remesuré pour `<t/>`) |
| A12 | `<t xml:space="preserve"/>` (ou `<t />`) suivi de blancs, en table | « » | les blancs | **S** | Le blanc qui suit un `<t>` vide est hors du contenu de `<t>`. Les deux sont sans valeur en aval. Source : `R/engine.R` l. 10827-10828. Non consigné au `.tex` | chaîne vide au lieu de blancs | *vérifié* (code) ; non remesuré |
| A13 | Colonne sans en-tête ; en-tête fait de seuls blancs | `V<k>` | `X<k>` ; « » | **S** | C'est une convention : les deux formes sont « en-tête absent » pour `.entete_absent()`. Sources : `.tex` l. 5168-5172 et l. 897-898 ; `R/engine.R` l. 11481-11482 ; test l. 2975-2977 | nom `V<k>` | *vérifié* |
| A14 | Fin de ligne **littérale** `\r\n` ou `\r` dans un texte (#602) : classeur écrit par l'outil sous Windows, ou classeur tiers | « `a\r\nb` » | « `a\nb` » avec 4.2.9 sous Windows ; **« `a\r\nb` » avec 4.2.5.2 sous Linux** (mesuré ici) | **O** (4.2.9 sous Windows seulement) | XML 1.0, § 2.11, normalisation des fins de ligne, à relire à la source (étape 1c). Textes seuls. Sources : #602 ; `test_controles_entree.R` l. 7064 | sous Windows avec 4.2.9 : `"a\nb"` relu `"a\r\nb"` jusqu'à l'étape 3a ; sous Linux avec 4.2.5.2 : inchangé | lectures *vérifiées* ; jugement : *hypothèse fondée* |

## 2. Formes refusées par l'admission sur les deux chemins (classe R, 19 groupes)

Ces formes ne sont pas des écarts de production : la règle d'admission précède l'embranchement. Le retrait n'a donc **aucun effet** sur elles, et aucune n'entre dans le tableau « hors références ».

La colonne « qui lisait juste avant la règle » vaut :
- **interne** ou **openxlsx** : ce chemin lisait la valeur de la source ;
- **aucun** : les deux chemins étaient faux ;
- **sans objet** : forme mal formée ou ambiguë.

| # | Règle et forme | Qui lisait juste avant la règle | Source |
|---|---|---|---|
| B1 | R0 : table partagée hors de `xl/` (`xl/strings/sharedStrings.xml`) | **aucun** : `openxlsx` lit 1 (troncature), le lecteur interne lit vide (il ne suit pas la relation) | `R/engine.R` l. 11302-11312 ; test l. 3315 |
| B2 | R0 : deux tables partagées | sans objet (`openxlsx` : erreur R) | l. 11309 ; test l. 3318 |
| B3 | R1 : partie en UTF-8 invalide | sans objet (`openxlsx` : erreur R ; le lecteur interne contournait des contrôles) | l. 9369-9380 ; test l. 3556 |
| B4 | R2 : commentaire dans un `<t>` ; relation commentée ; section CDATA | commentaire : **interne** (11,5 contre 11) ; relation commentée : **aucun** (999 sur les deux chemins) ; CDATA : **aucun** (texte non numérique sur les deux chemins) | l. 9400-9405 et l. 10168-10176 ; `.tex` l. 5236-5241 ; test l. 3714 |
| B5 | Balise `<Relationship<TAB>`, `<LF>`, `<CR>` ou `<RelationshipX` (D-S1-39) | **interne** (104,2 ; `openxlsx` boucle sans fin) | l. 9795-9832 ; test l. 4008 |
| B6a | D-S1-37 : texte `Id="…"` ou `r:id="` hors de l'attribut (`Foo=`, `RelId=`, nom de feuille) | **interne** (104,2 contre 999) | l. 9941-9947 et l. 9961-9964 ; sorties du lot H |
| B6b | D-S1-37 : `id="rId2" r:id="rId1"` | **openxlsx** (104,2 ; le lecteur interne lit 999) | l. 9882 |
| B6c | D-S1-37 : `Type` préfixé ou répété (#595) | **aucun** (999 sur les deux chemins) | l. 9866-9874 |
| B6d | D-S1-37 : `Id` répété ou préfixé ; deux relations `rId1` ; `r:id=""` | sans objet (forme ambiguë ou invalide) | l. 9878-9883 ; sorties du lot H |
| B6e | D-S1-37 : `r:id` entre apostrophes, à blancs, à tabulation ou non alphanumérique dans une feuille qui précède ; `<x:sheet>` suivie de `<sheet>` | **interne** | l. 9948-9956 ; test l. 3863 |
| B6f | `<sheet>` coupée par `>` dans un nom (`name="a>b"`) | **aucun** (le lecteur interne lisait la feuille suivante, `openxlsx` : erreur R) | l. 9884-9888 |
| B6g | Cible : `x:Target` puis `Target='…'` ; `x:Target` puis `Target="…"` ; `Target` puis `x:Target` ; `Foo='Target=…'` ; `sheet&#49;.xml` | selon la forme : **aucun** (999 sur les deux chemins), **openxlsx** contre un lecteur interne faux (999 en interne, erreur R d'`openxlsx`), ou **interne** | l. 9985-10001 ; #595 ; test l. 3925, l. 3932 et l. 3945 |
| B7 | R3 : structure du bloc (`<c<TAB>`, `</sheetData>` en surnombre, `<sheetData >`, cellule hors du bloc, `</v >`, `<is> <t>`) | `</v >` : **aucun** (le lecteur interne décalait les valeurs) ; cellule hors du bloc : **aucun** ; autres formes : **interne** ou sans objet | l. 10250-10281 et l. 10720-10735 ; test l. 3770 |
| B8 | R3 : `<t>` à attribut ou à blanc d'une chaîne en ligne (D-S1-31 ; #594 doit l'assouplir) | **interne** (`xt` et 104,2 ; `openxlsx` garde l'attribut dans le texte) | l. 10393-10400 ; `.tex` l. 5325-5333 ; test l. 4058 |
| B9 | R3, segment : `<row t="s">` ; `<v>` dans un `<extLst>` ; « ` t=` » en pied de page | `<row t="s">` : **interne** ; `<extLst>` : **aucun** (valeur de l'`<extLst>` lue par les deux chemins) ; pied de page : **interne** (`openxlsx` arrête le processus) | l. 10282-10301 ; test l. 4081 et l. 3602 |
| B10 | R4 : `r="1"`, `r="A0"`, `r="a2"`, `x:r=`, `s="xr=_D2"`, `t='s'` | `r="1"` et `r="A0"` : **aucun** (le lecteur interne déplaçait les valeurs) ; autres formes : **interne** | l. 10705-10723 et l. 10472-10481 ; test l. 3595 et l. 3763 |
| B11 | R5 à R6b : limites, doublon `B2`, ordre de lecture | doublon : sans objet (999 sur les deux chemins) ; ordre : **interne** (σ_USP 0,1114524114 contre 0,1764544949) ; limites : sans objet | l. 10506-10560 ; test l. 4094 |
| B12 | R7 et R8 : `t="d"`, `t="x"`, `t="e"`, `0x10`, `104,2`, `t="s"` sans `<v>`, `t="b"` `<v>2</v>`, `<v></v>` | `t="x"` et `t="b"` `2` : **aucun** ou le lecteur interne faux ; `0x10`, `104,2`, `t="s"` sans `<v>`, `t="d"` : **interne** (`openxlsx` lisait 16, 104, la chaîne 0, 2020) | l. 10594-10600 et l. 10655-10661 |
| B13 | R8 et R9 : références numériques ASCII et blancs (D-S1-18, D-S1-23) ; table partagée (segments sans `<rPr>`, `<rPh/>`, plusieurs `<t>`, `<x:si>`, `<si/>`, `<x:t>`, trois formes du schéma, `<tz>`) ; R10 à R12 | références : **interne** (`openxlsx` prenait la colonne D en silence) ; `<x:si>`, `<si/>`, `<x:t>` : **aucun** ; plusieurs `<t>` : sans objet ; trois formes et `<tz>` : **interne** ; R10 et R11 : sans objet (arrêt ou allocation d'`openxlsx`) ; R12 : sans objet (choix du contrat) | l. 11048-11086, l. 10785-10836, l. 11140-11160 et l. 11184-11196 ; test l. 4296-4436 |

**Constat important (sans arrêt B, puisque ces formes sont refusées).** Dans plusieurs formes, le lecteur interne était lui-même faux avant la règle : B1, B4, B6b, B6c, B6f, B6g, B7, B9, B10, B12, B13. Une partie des règles « nées de la parité » protège donc **aussi le lecteur interne**.
- C'est un argument de plus pour les garder à l'identique (ADR 0020, point 2).
- Leur motif réécrit doit le dire.
- Tout assouplissement futur, #594 compris, doit s'instruire contre la source et sur le lecteur interne, et non contre la seule parité.

## 3. Défaut commun aux deux chemins (hors écarts) et mesures faites

**C1, `t="str"` sans décodage.** Le `.tex` (l. 5475-5478) et le code (l. 11504-11510) consignent que le texte d'une cellule `t="str"` est lu « tel quel, sans décodage des entités », identiquement par les deux chemins. Selon XML 1.0, le contenu textuel est décodé : le lecteur interne s'écarte donc de la source (jugement *hypothèse fondée*). Mesures (sonde de session, `LC_ALL=C.UTF-8`, moteur à `77c84ae` ; chemin interne forcé par substitution de `requireNamespace` dans `environment(run_engine)`, chemin `openxlsx` 4.2.5.2) :

| Classeur forgé (écrivain interne, feuille remplacée) | Lecteur interne | `openxlsx` 4.2.5.2 | Lecture fidèle attendue |
|---|---|---|---|
| B1 `t="str"` `x&#116;`, D1 `xt` | colonne D retenue, `ok = TRUE`, `xt` = 99 98 | identique | doublon `xt`, refus |
| B1 `t="str"` `x&#116;` seul | « colonne manquante : xt » | identique | B lue comme `xt` (refus à tort, sans valeur fausse) |
| B2 `t="str"` `1&#48;4.2` | non numérique, refus en aval | identique | 104,2 (refus à tort) |

Autres mesures du même passage, toutes reportées au § 1 :
- A3 : `./worksheets/…`, erreur d'`openxlsx` 4.2.5.2 ;
- A6, A7 : « true », « `&amp;lt;1` » ;
- A8 : écrivain interne, « `a<b&c` » et colonne logique ;
- A9 : `&#160;`, `&#233;` ;
- A10 : `1\n\n2` ;
- A11 : `<t/>` ;
- A14 : `\r\n` et `\r`.

Sonde : versée par la session sous `sonde-inventaire.R` (à l'origine, `<scratchpad>/inv/sonde.R`, hors dépôt).

**Historique, pour mémoire.** La comparaison des deux chemins a déjà décelé et fait corriger des défauts du lecteur interne qui ne sont plus des écarts aujourd'hui :
- `<v >` lu `NA` (l. 11153-11155) ;
- `<x:rPh>` lu « 117 » (l. 9494-9496) ;
- `<rPh sb="0>"…/>` qui faisait perdre du texte (#572, M1).

#602 n'est donc pas le seul défaut que le témoin ait aidé à trouver. C'est le seul qui soit encore ouvert.

## 4. Décomptes

- **Écarts sur classeurs admis : 14.**
  - I (lecteur interne juste, lu au lieu d'une erreur R) : **4** (A1 à A4) ;
  - O (`openxlsx` juste) : **1** (A14, #602, avec 4.2.9 sous Windows seulement) ;
  - S (sans effet sur les valeurs employées) : **9** (A5 à A13). Dans chacun, le lecteur interne est juste ou l'écart est neutre (A5 pour `t="b"`, A13).
- **R (refusé par l'admission sur les deux chemins) : 19 groupes** (B1 à B13, avec B6 en 7 sous-groupes), sans objet après le retrait.
- **Hors classes : 1 défaut commun** (C1).

## 5. Entrées du tableau « hors références » (poste muni d'`openxlsx`)

| Écart | Ce qui change au retrait | Déjà dans l'ADR ? |
|---|---|---|
| A1 à A4 | classeur lu au lieu d'une erreur R | oui (« formes admises du Contexte ») |
| A5 | colonne booléenne rendue en caractères ; même refus en aval | oui |
| A6, A7 | « true » gardé ; « `&lt;1` » au lieu de « `<1` » | oui |
| A8 | entités d'une chaîne en ligne décodées (en-tête « `l&b` », « `a<b&c` ») | **non, à ajouter** |
| A9 | références numériques admises décodées (`&#233;` lu « é ») | **non, à ajouter** |
| A10 | lignes vides internes d'un texte gardées | **non, à ajouter** |
| A11 | `<t/>`, `<si></si>` : chaîne vide au lieu de `NA` | **non, à ajouter** |
| A12 | blancs qui suivent un `<t …/>` vide : chaîne vide au lieu de blancs | **non, à ajouter** |
| A13 | noms de colonne `V<k>` au lieu de `X<k>` ou de « » | **non, à ajouter** |
| A14 | sous Windows avec 4.2.9, `"a\nb"` relu `"a\r\nb"` jusqu'à l'étape 3a ; sous Linux avec 4.2.5.2, inchangé | oui, à préciser par version et par système |

Aucune de ces entrées ne touche `t`, `xt`, `yt` ni le triangle. Le corpus de 42 classeurs le *vérifie* (mesure de Q-66-3) ; au-delà, c'est une *hypothèse*. Les cas B et C ne changent pas au retrait.

## Constats mineurs (proposés pour « Constats mineurs écartés (ADR 0018) »)

- m1 : version de la mesure d'A3 divergente entre `R/engine.R` l. 11567-11570 (4.2.9) et le `.tex` l. 5488-5490 (4.2.5.2 seulement). Sous 4.2.5.2, l'erreur est remesurée. Sans objet après le retrait. Critère : aucun.
- m2 : A10 à A12 sont consignés dans le code, pas au `.tex`. Sans objet après le retrait (à intégrer par `docwriter` à la description du lecteur unique s'il le juge utile). Critère : aucun.

---

## Retour

- **Statut** : `revue requise`. C1 est un candidat au point B que la définition stricte (« écart entre les deux chemins ») ne couvre pas, mais que la règle de lecture de l'ADR 0020 (accord avec la source) couvre. Le classement est à trancher.
- **Résultat** :
  - inventaire complet : 14 écarts admis (I 4, O 1, S 9), 19 groupes refusés, 1 défaut commun ;
  - aucun écart entre chemins ne donne tort au lecteur interne hors #602 ;
  - tableau « hors références » à compléter de six lignes (A8 à A13) ;
  - nuance de version et de système sur #602.
- **Preuves** :
  - *vérifié* : sources lues et citées ligne par ligne (`.tex` l. 850-1150, l. 5165-5560, l. 2950-2960 ; `R/engine.R`, en-têtes et commentaires de règles l. 8815-11725 ; tests l. 2482-7290 et `test_outdec.R` ; #572, #579, #595, #602 ; sorties versées des lots G et H) ;
  - *vérifié* : mesures faites ici, sur le lecteur interne et `openxlsx` 4.2.5.2, `LC_ALL=C.UTF-8` (A3, A6 à A11, A14, C1) ;
  - *hypothèse fondée* : tout jugement « juste » qui repose sur XML 1.0 et les espaces de noms (non relus à la source) ;
  - *hypothèse* : le mécanisme de #602 sous Windows ;
  - *non vérifié* : le comportement d'`openxlsx` 4.2.9, non installé ici ; les mesures 4.2.9 sont reprises du `.tex`, du code et de #602.
- **Informations manquantes** :
  - XML 1.0 (§ 2.11, références de caractère) et la recommandation sur les espaces de noms, non relus à la source (étape 1c) ;
  - fil de #594 et commentaires de #574 non relus en entier : leurs écarts sont repris du code, du `.tex` et des sorties versées des lots G et H ;
  - aucune mesure sous Windows ni sous 4.2.9.
- **Décisions non résolues** :
  - C1 : point B ou ligne écartée (mainteneur, sur proposition de la session) ;
  - ajout d'A8 à A13 au tableau « hors références » de la PR (session ; `actuary` à l'étape 8).
- **Critères déclenchés** (`routage.md`, § 4.2) :
  - **un résultat final ou un verdict change**, hors références : A1 à A4 font passer, sur un poste muni d'`openxlsx`, d'une erreur R à un classeur lu, donc à un σ_USP calculé. C'est déjà consigné par l'ADR ;
  - si C1 est corrigé, un classeur forgé aujourd'hui accepté serait refusé ;
  - **ADR 0020 nuancé**, non contredit : le « seul défaut connu » tient pour les écarts entre chemins ; C1 est un défaut commun que le critère de la source rend visible ; #602 n'est « lu juste par `openxlsx` » qu'avec 4.2.9 sous Windows ;
  - validité à T = 8 : sans objet.
- **Constats hors périmètre** :
  - C1 : critères E1 (σ_USP rendu à tort, classeur forgé) et E5 (`.tex` l. 5475-5478, « ne peut donner de valeur fausse ») ; preuve au § 3 ;
  - m1, m2 : critère « aucun ».
- **Prochaine action recommandée** :
  - verser l'inventaire ;
  - soumettre C1 au mainteneur (point B). S'il est gardé, issue rédigée pour la place libre d'A1 : décodage des références dans `t="str"`, ou extension du refus de D-S1-18 au `<v>` des cellules `t="str"`, à spécifier contre XML 1.0 après l'étape 1c ;
  - compléter le tableau « hors références » de l'étape 2b avec A8 à A13 et la nuance de version sur A14 ;
  - transmettre à l'étape 2b la consigne de garder, dans les motifs réécrits, que certaines règles protègent aussi le lecteur interne (§ 2).
