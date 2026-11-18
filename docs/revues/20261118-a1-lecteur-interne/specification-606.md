*Rédigé par l'agent actuary (IA).*

> *Note de la session principale* : texte versé intégralement le 18/11/2026. Les scripts et sorties, d'abord hors dépôt, sont versés sous `specification-606/` ; les chemins de session y sont abrégés en `<scratchpad>`. Les §§ 2.4 et 4.6 de XML 1.0, dont le texte ci-dessous note l'absence (« *non vérifié* »), ont été versés depuis dans `relecture-xml-1.0.md`, cités mot pour mot. Ils confirment ce que l'agent avançait de mémoire. **Arrêt D décidé par le mainteneur le 18/11/2026 : D-1 (a), option (ii), et D-2 (a)** (E-18/11 (arrêt D)).

Fiche `actuary`, le 18/11/2026, en lecture seule, sur `claude/creneau-a1` à `f07e219`. Le moteur a été lu dans `git show f07e219:R/engine.R` (md5 `26220144141d922f4ea85d259004f093`) et non dans l'arbre de travail, que `coder-approfondi` modifie pour #604. Je n'ai écrit aucun fichier du dépôt. `git status` ne montre que `M R/engine.R`, qui vient du codeur.

# Spécification de #606 (A1, étape 1d) : texte d'une cellule `t="str"`

**Sources lues**
- L'issue #606.
- La fiche A1 (`docs/feuille-de-route.md`, § 3) : étapes 1d, 6b et 7, ordre des étapes, points d'arrêt.
- L'ADR 0020, points 2 et 3.
- `inventaire-ecarts.md` (§ 2, B13 ; § 3, C1), `sonde-inventaire.R` et `sortie-sonde-inventaire.txt`.
- `relecture-xml-1.0.md`, §§ 2.11 et 4.4.2.
- D-S1-18 et D-S1-21 à D-S1-25 (`docs/revues/20261115-s1-rejeu/decisions-mainteneur.md`).
- `specification-594-amendee.md`, §§ 0 à 4.
- Dans `R/engine.R` à `f07e219` :
  - `.xml_decoder()` (l. 9444-9469) et `.xml_textes()` (l. 9508-9519) ;
  - `.xlsx_cellules()` (l. 9663-9750) ;
  - `.xlsx_controler_contenus()` (l. 10616-10688) ;
  - `.xlsx_controler_references()` et ses constantes (l. 11002-11126) ;
  - `.xlsx_controler_ligne_entete()` (l. 11184-11240) et `.xlsx_blancs_entete()` ;
  - `.xlsx_admettre()` (l. 11276-11360) ;
  - l'en-tête et l'assemblage d'`engine_lire_xlsx()` (l. 11480-11722) ;
  - `.nettoyer_cellules()`, `.cellules_en_nombre()`, `.en_numerique()`, et l'étape des noms d'`engine_lire_donnees_csv()`.
- Le `.tex` à `f07e219`, l. 974-982, 1030-1037, 5380-5413 et 5470-5482.
- `tests/unitaires/test_controles_entree.R` à `f07e219`, l. 2591-2607, 3392-3404, 4217-4229 et 4444-4454.
- `tests/outils_tests.R`, l. 72-77.

**Mesure** (*vérifiée*)
- Conditions : Linux, R 4.3.3, `LC_ALL=C.UTF-8`, `openxlsx` absent (`requireNamespace` vaut `FALSE`). C'est donc le lecteur interne qui lit, comme après #604.
- Moteur : copie de `f07e219`, chargée par `charger_moteur(fichier = …)`.
- Prototypes en mémoire, posés dans `environment(run_engine)`. Ce n'est pas le code de l'étape 6b.
  - **(i)** : après `.xlsx_controler_contenus()`, appel de `.xlsx_controler_references()` sur le `<v>` des cellules `t="str"`. Partie citée en dur : `xl/worksheets/sheet1.xml`.
  - **(ii)** : (i), plus `.xml_decoder()` sur le `<v>` `t="str"`, à l'assemblage d'`engine_lire_xlsx()` et dans `.xlsx_controler_ligne_entete()` (`texte[st]`).
- Scripts et sorties, d'abord hors dépôt dans le dossier de travail de la session ; la session peut les verser sous `specification-606/` *(versés)* :

  | Fichier | md5 |
  |---|---|
  | `scripts/sonde606.R` | `e59fc90b559001208087c908be6f8b37` |
  | `sortie-sonde606.txt` | `99a5281ced2d551792ef0b28be03f717` |
  | `scripts/corpus606.R` | `7aed891385b193babfb67a77824a156a` |
  | `sortie-corpus606.txt` | `d4467501f2955dd2d6b1fab4647fa33a` |

---

## 0. En bref

- **Recommandation : option (ii).** Le `<v>` d'une cellule `t="str"` est soumis au même refus des références que les chaînes en ligne, puis il est décodé par `.xml_decoder()`, comme les chaînes partagées et en ligne.
- **Ce que les deux options ont en commun.** Les refus sont les mêmes. Elles refusent les trois classeurs forgés de l'inventaire, dont celui qui rend aujourd'hui un σ_USP à tort.
- **Ce qui les sépare.** Seulement le texte lu dans les cellules admises qui portent une entité nommée ou une référence admise. Ce texte n'est jamais celui d'une valeur employée.
- **Ce qui ne change pas.** Aucun classeur aujourd'hui refusé ne devient lu, ni sous (i) ni sous (ii). Le corpus de 2a ne change pas (38 classeurs sur 38) ; les six références non plus.
- **Point d'arrêt D : déclenché**, parce que la recommandation est (ii). Les questions sont D-1 et D-2 (§ 6).

## 1. Choix entre (i) et (ii)

### 1.1 Ce que fait le code aujourd'hui (*vérifié*, lecture et mesure)

- **Le `<v>` d'une cellule `t="str"` est rendu tel quel**, sans décodage :
  - à l'assemblage : `val <- cc$v[a_val]`, l. 11673, et aucun décodage pour `typ == "str"` ;
  - au contrôle de la ligne 1 : `texte[st] <- brut[st]`, l. 11229-11230.
- **Le complément de R8 n'est appelé que sur les chaînes en ligne** (`ki <- which(cc$is)`, l. 11356). Le `<v>` `t="str"` est exclu expressément, et le motif écrit est la parité : « Le texte d'une cellule t="str" (<v>) n'est decode par aucun des deux chemins (parite, mesure) et n'est pas vise » (l. 11087-11089).
- **Le test témoin de D-S1-18 consigne ce défaut comme admis.** `test_controles_entree.R`, l. 4449-4454 : « seule colonne xt, la colonne D (sigma_USP 0.0762262056 sur les deux chemins, avant comme apres, sonde) ».
- **Le `<v>` `t="str"` est le seul texte de la feuille hors de tout contrôle des références.** Les autres `<v>` sont fermés par R8 : nombre selon `XML_MOTIF_NOMBRE`, `t="s"` en chiffres seuls, `t="b"` valant 0 ou 1. `t="e"` est refusé par R7, `t="d"` aussi.
- **Les entités nommées d'un `<v>` `t="str"` sont rendues littérales aujourd'hui** (mesure F7, F11) :

  | Écrit dans le `<v>` | Lu aujourd'hui |
  |---|---|
  | `R&amp;D` | « `R&amp;D` » |
  | `a&lt;b&gt;c` | « `a&lt;b&gt;c` » |
  | `&amp;amp;lt;` | « `&amp;lt;` » |

  Le refus des références ne les vise pas : il ne cherche que `&#`. Le même texte en chaîne en ligne est lu « `R&D` » (F12), et « `&lt;` » pour `&amp;lt;` en chaîne partagée (inventaire, A7).

### 1.2 Ce que dit la source

- **Références de caractère : *vérifié*** (`relecture-xml-1.0.md`, citation du § 4.4.2). « A character reference is included when the indicated character is processed in place of the reference itself. » Le tableau du § 4.4 rattache ce traitement à la référence dans le contenu d'un élément, ce qu'est le texte de `<v>`. Lire `x&#116;` « `x&#116;` » s'écarte donc de la source.
- **Entités prédéfinies (`&amp;`, `&lt;`, `&gt;`, `&quot;`, `&apos;`) : *non vérifié* à la source dans cette consultation.** `www.w3.org` ne se résout pas depuis cette session. Les §§ 2.4 et 4.6 de XML 1.0 ne figurent pas dans `relecture-xml-1.0.md`. De mémoire, le § 4.6 oblige tout processeur à reconnaître ces cinq entités, et le § 2.4 oblige à échapper `&` et `<` hors du balisage. Ce n'est pas une citation : je demande que la session ajoute ces deux passages à la relecture, mot pour mot, avant la décision D-1. *(Fait par la session : voir la note de tête.)*
- **Fins de ligne (§ 2.11, *vérifié*).** Elles se normalisent avant l'analyse, donc avant le décodage. Pour le `<v>` `t="str"`, l'ordre est sans objet en pratique : les références aux fins de ligne et à la tabulation (`&#9;` à `&#13;`, `&#xD;`) sont refusées (D-S1-23), donc jamais décodées. Seul un CR littéral est en jeu, et il relève de l'étape 3b (§ 2, point 5).

### 1.3 Ce que (i) et (ii) ont en commun (*vérifié* par prototype)

- Le même ensemble de refus, au même endroit, avec le même texte. Mesuré sur F1 à F6 : messages identiques sous (i) et (ii).
- Le trou de D-S1-18 est fermé : après #606, chaque source de texte de la feuille et de la table passe par `.xlsx_controler_references()`.
- La prémisse de l'exclusion (« parité ») est tombée avec l'ADR 0020. Étendre le refus applique la règle de lecture de l'ADR 0020, point 3 (accord avec la source). Ce n'est pas un assouplissement au sens du point 2 : aucun classeur refusé ne devient lu.

### 1.4 Ce qui les sépare

Seul change le texte lu dans les cellules `t="str"` admises qui portent :
- une entité nommée ;
- une référence admise : non ASCII hors blancs, caractère de contrôle `&#1;` à `&#8;` ou `&#14;` à `&#31;`, `&#127;`, échappement `&#38;` `&#39;` `&#34;` `&#60;` `&#62;` ;
- une référence hors du domaine des caractères (`&#0;`, laissée telle quelle par `.xml_decoder()` dans les deux cas).

Sous (i), ces textes restent bruts ; sous (ii), ils sont décodés (F7, F8, F9, F11).

**Pourquoi ce texte ne touche aucune valeur employée** (*vérifié* par lecture à `f07e219` ; mesuré sur F7 à F11, non exhaustif) :
- Une référence admise désigne, par construction de D-S1-23 (`.xml_codes_retires_entete()`, liste adaptée à la locale), un caractère :
  - qui n'est pas un blanc que retirent `.xlsx_blancs_entete()`, `.nom_sans_bom()` ou `.entete_designe()` ;
  - qui n'est pas un blanc ASCII retiré par `.nettoyer_cellules()` (espace, tabulation, CR, LF : tous refusés) ;
  - qui n'est pas un chiffre, un signe, un point ni un `e` ASCII (refusés comme ASCII imprimables).
- Une entité nommée ne donne que `< > & " '`.
- Décodé ou non, un tel caractère ne peut donc ni compléter un en-tête attendu (`t`, `xt`, `yt`, `i`, `j<k>`), ni rendre lisible un nombre (`as.numeric()` sur une chaîne qui le porte vaut `NA`), ni rendre blanche une ligne 1 (R12).

D'où le constat : **aucun classeur aujourd'hui refusé ne devient lu sous (ii)**, et aucun σ_USP, verdict ni p-value ne diffère entre (i) et (ii).

### 1.5 Entités nommées

**Recommandation : ni refusées, ni laissées brutes. Décodées en une passe sous (ii)**, comme dans les deux autres sources de texte (`&amp;lt;` lu « `&lt;` », équivalent de l'inventaire A7).

**Pourquoi ne pas les refuser.** C'est la seule écriture de `&` et `<` dans un texte XML (§ 2.4, *non vérifié* ici, voir 1.2). Un résultat de formule texte qui porte `&` ou `<` est donc écrit `&amp;` ou `&lt;` par tout écrivain conforme (*hypothèse* sur les écrivains : aucun classeur d'Excel ni de LibreOffice au corpus, E-18/11 (corpus)). Refuser les entités nommées refuserait un classeur ordinaire.

**Pourquoi ne pas les laisser brutes (option (i)).** Ce serait garder un écart connu à la source sur une forme **réaliste** (« `R&D` » lu « `R&amp;D` »). Le seul motif qui le justifiait, la parité, a disparu (ADR 0020, point 3). Cet écart touche du texte, pas une valeur employée : il n'est pas marquant au sens de l'ADR 0018. Il devrait pourtant rester au `.tex` comme une limite que plus rien ne motive.

Les entités non prédéfinies (`&nbsp;`, XML mal formé) restent rendues telles quelles par `.xml_decoder()`, comme aujourd'hui dans les trois sources (constat hors périmètre, critère « aucun »).

### 1.6 Recommandation : (ii)

1. **Conformité.** Le texte de toute cellule est lu selon XML 1.0, § 4.4.2 (*vérifié*) et § 4.6 (*non vérifié* ici).
2. **Un seul modèle de texte.** Chaîne partagée, chaîne en ligne et résultat de formule sont lus de la même façon : refus des références ASCII et des blancs sur le texte brut, puis décodage en une passe. Mesure : sous (ii), un en-tête et une valeur `t="str"` sont `identical()` au même texte en chaîne en ligne (F7 et F8 contre F12 : `TRUE`, `TRUE`). Ce que l'aval fait d'un caractère décodé est donc déjà ce qu'il fait pour les deux autres sources, mesuré pour D-S1-22 et D-S1-23.
3. **Une limite de moins au dossier.** La phrase du `.tex` sur la lecture « telle quelle » sort, sans être remplacée par une autre limite.
4. **Coût marginal.** Deux lignes de code de plus que (i) et quelques tests.

**L'option (i) reste acceptable** si le mainteneur préfère ne pas rouvrir de décision. Elle ferme le défaut marquant (E1, E5). En contrepartie, la lecture brute du texte admis devient une limite consignée, avec un motif à réécrire sans la parité : « aucune valeur employée ne peut porter ces caractères ».

## 2. Règle : formes visées, refusées, décodées ; motif

1. **Formes visées.** Le texte entre `<v …>` et `</v>` de toute cellule `t="str"` de la feuille lue (`cc$v`, non `NA`), où qu'elle soit (en-tête ou corps, colonne lue ou annexe, séries ou triangle, `entete = TRUE` ou `FALSE`). R3 garantit que ce `<v>` ne porte aucune balise (en-tête de `.xlsx_cellules()`) ; R8 refuse déjà `t="str"` avec `<is>`.
2. **Refusées : la liste exacte de D-S1-18 et D-S1-23**, sans ajout ni retrait.
   - Toute référence `&#NNN;` ou `&#xHH;` (zéros de tête admis, `x` en minuscule ou en majuscule ; `&#X74;` est refusé, F5) qui désigne :
     - un caractère ASCII imprimable U+0020 à U+007E autre que `"`, `&`, `'`, `<`, `>` (`XML_CODES_REFERENCE_ADMIS`) ;
     - ou un caractère que retire la mise en forme des en-têtes (`.xml_codes_retires_entete()` : `XML_CODES_REFERENCE_BLANCS`, complété par les blancs de la locale, et U+FEFF).
   - **Portée : tout le classeur**, comme D-S1-25 (voir D-2). Une note annexe `&#65;` fait refuser le classeur (F6).
3. **Décodées** (option (ii)), par `.xml_decoder()` sur le texte brut, une fois le contrôle passé :
   - les cinq entités prédéfinies ;
   - les références admises, comme dans `.xml_decoder()` aujourd'hui : non ASCII hors blancs, contrôles `&#1;` à `&#8;` et `&#14;` à `&#31;`, `&#127;`, les cinq échappements.

   Les références hors du domaine (`&#0;`, substituts, au-delà de U+10FFFF) et les entités non prédéfinies restent telles quelles. Le décodage vaut à l'assemblage d'`engine_lire_xlsx()` et pour `texte[st]` de `.xlsx_controler_ligne_entete()`, afin que R12 lise le même texte que le tableau rendu.
4. **Motif : la constante existante `TEXTE_REFUS_REFERENCE_NUMERIQUE`, sans motif nouveau.**
   - Premier `%s` : « la partie `xl/worksheets/sheetN.xml` du classeur » (`feuille$partie`). Positions « `B1 : &#116;` », cinq au plus, dans l'ordre du document.
   - Justification : même forme, même risque (en-tête ou valeur mal lus), même texte de décision (D-S1-24). Le libellé ne nomme pas le type de cellule et n'a pas à le faire.
   - **Forme de l'appel** : un seul appel à `.xlsx_controler_references()`, à la place actuelle (après `.xlsx_controler_contenus()`, avant R9), sur les cellules prises dans l'ordre du document. Le texte est le contenu de `<is>` sans balises si la cellule porte `<is>`, le `<v>` si elle est `t="str"`. Pour un classeur sans cellule `t="str"`, l'entrée de l'appel est identique à celle d'aujourd'hui, donc le message aussi.
   - Variante admise : deux appels, en ligne puis `t="str"`. Elle cite les positions dans un ordre moins naturel ; c'est un choix de forme de `coder-approfondi`, sans effet sur l'admission.
5. **Ordre avec #602 (étape 3b).** Le `<v>` `t="str"` reçoit la normalisation des fins de ligne littérales que 3b aura posée pour les autres textes, avant le décodage (XML 1.0, § 2.11 puis § 4.4.2).
   - Si 3b normalise la partie entière avant l'analyse, rien n'est à ajouter.
   - Sinon, `t="str"` doit suivre le même chemin que `<is>` et `<si>`.

   #606 n'ajoute aucune règle de fin de ligne.
6. **Inchangé.** `.xml_decoder()`, `.xlsx_controler_references()`, les constantes, R8 (`t="str"` : `<v>` facultatif, `<v></v>` lu `""`), la signature d'`engine_lire_xlsx()` et `app.R`.

## 3. Tableau avant / après attendu

### 3.1 Classeurs forgés

Écrivain interne, feuille remplacée, lecteur interne, `C.UTF-8`. Mesure de `sortie-sonde606.txt`. « Refus R8c » désigne le refus `TEXTE_REFUS_REFERENCE_NUMERIQUE` (classe `usp_refus_lecture`) à la position citée.

| Cas | Classeur | Avant (`f07e219`) | Après (i) | Après (ii) |
|---|---|---|---|---|
| F1 (C1, inventaire) | B1 `t="str"` `x&#116;`, D1 `xt` | lu, en-têtes `t`, `x&#116;`, `yt`, `xt` ; aval `ok`, **`xt` = colonne D** (99 98) ; σ_USP 0,0762262056 sur la fixture du test l. 4449-4454 (*vérifié* par lecture du commentaire, non remesuré ici) | **refus R8c « B1 : &#116; »** | idem |
| F2 (C1) | B1 `t="str"` `x&#116;` seul | refus aval « Colonne(s) manquante(s) : xt » | refus R8c « B1 : &#116; » (refusé → refusé, motif changé) | idem |
| F3 (C1) | B2 `t="str"` `1&#48;4.2` | refus aval « non numériques (colonne xt : ligne(s) de données 1) » | refus R8c « B2 : &#48; » (refusé → refusé, motif changé ; **non lu 104,2**) | idem |
| F4 | B1 `t="str"` `xt&#9;`, D1 `xt` (D-S1-23) | lu, aval `ok`, `xt` = colonne D | refus R8c « B1 : &#9; » | idem |
| F5 | B1 `t="str"` `x&#X74;` | refus aval « colonne manquante » | refus R8c « B1 : &#X74; » | idem |
| F6 | D2 `t="str"` `&#65;` (note annexe) | lu, aval `ok`, `xt` = 11 13 | **refus R8c « D2 : &#65; »** (lu → refusé sans valeur fausse, D-S1-25) | idem |
| F7 | D1 `t="str"` `R&amp;D`, D2 `a&lt;b&gt;c` | lu ; en-tête « `R&amp;D` », note « `a&lt;b&gt;c` » ; aval `ok` | inchangé (`identical()`) | en-tête « `R&D` », note « `a<b>c` » ; aval `ok`, `xt` inchangé |
| F8 | D2 `caf&#233;`, D3 `&#38;&#0;` | « `caf&#233;` », « `&#38;&#0;` » | inchangé | « `café` », « `&&#0;` » |
| F9 | B2 `t="str"` `104.2&#160;` | refus aval « non numériques » | inchangé | texte « 104.2 » suivi de U+00A0 ; **même refus aval, même message** |
| F10 (témoin) | B1 `t="str"` `xt`, B2 `t="str"` `104.2` | lu, `xt` = 104,2 13 | inchangé | inchangé |
| F11 | D1 `t="str"` `&amp;amp;lt;` | en-tête « `&amp;lt;` » | inchangé | en-tête « `&lt;` » (un seul décodage) |

**Bilan**
- Lu → refusé : F1 (σ_USP rendu à tort), F4 (même scénario), F6 (note annexe, sans valeur fausse).
- Refusé → refusé, motif changé : F2, F3, F5.
- Refusé → lu : **aucun**, sous (i) comme sous (ii).
- Texte seul changé, sans effet sur `xt`, `yt` ni sur l'issue, sous (ii) seulement : F7, F8, F9, F11.

### 3.2 Corpus de `tests/donnees/classeurs/` (*vérifié*)

- 38 classeurs, `md5sum -c md5.txt` sans écart.
- Parcours `unzip -p` et `grep` des feuilles et de la table partagée : **0** cellule `t="str"`, **0** balise `<f>`, **0** référence `&#`, **0** entité nommée, dans les 38.
- Mesure (`sortie-corpus606.txt`) : pour chaque classeur, retour d'`engine_lire_xlsx()` (`data.frame` ou message de refus) et sortie aval (`engine_lire_donnees_csv()`, ou `engine_lire_triangle()` pour les triangles) `identical()` entre avant, (i) et (ii) : **38 sur 38** (23 lus, 15 refusés, refus déjà présents, sans rapport avec #606).
- **Limite** : le corpus n'exerce pas du tout `t="str"`. Les écrivains qui écrivent la valeur en cache d'une formule texte (Excel, LibreOffice ; *hypothèse*) n'y figurent pas. L'absence de références ASCII dans un `<v>` naturel reste l'hypothèse de D-S1-18, non éprouvée.

### 3.3 Six références (*vérifié* par lecture)

- Les cas de référence lisent des CSV par `utils::read.csv()` (`tests/outils_tests.R`, l. 72-77). `tests/generer_references.R`, `tests/comparer_references.R` et `tests/regenerer_et_rendre_compte.R` ne contiennent aucune occurrence de « xlsx ». Le lecteur est hors du chemin des références.
- Attendu à 6b : `comparer_references.R --seuil 0` sans écart, et volet `identical()` vert.

## 4. Tests

Dans `test_controles_entree.R`, sur le seul lecteur interne (ADR 0020, point 3), avec des valeurs attendues explicites. Le texte attendu d'un refus est construit depuis `TEXTE_REFUS_REFERENCE_NUMERIQUE` du moteur chargé : `sprintf(TEXTE_REFUS_REFERENCE_NUMERIQUE, "la partie xl/worksheets/sheet1.xml du classeur", "<positions>")`. Classe vérifiée : `usp_refus_lecture`.

| Test | Classeur | Attendu |
|---|---|---|
| T1 | F1, fixture du test l. 4449-4454 | refus, positions « B1 : &#116; » ; **renverse** ce test témoin, commentaire σ_USP retiré |
| T2 | F2 | refus « B1 : &#116; » (et non « colonne manquante ») |
| T3 | F3 | refus « B2 : &#48; » |
| T4 | B1 `t="str"` portant `xt&#9;`, `&#xD;xt`, `xt&#12288;`, `&#65279;t` (A1) | refus, position et référence citées telles qu'écrites |
| T5 | F5 | refus « B1 : &#X74; » |
| T6 | F6 | refus « D2 : &#65; » (portée D-S1-25) |
| T7 | B1 en ligne `x&#116;` et D2 `t="str"` `&#65;` | un refus, positions « B1 : &#116; » puis « D2 : &#65; » (ordre du document, forme d'un seul appel) |
| T8 (ii) | F7 | `names(d)[4]` vaut `"R&D"` ; `d[[4]]` vaut `c("a<b>c", "a")` ; aval `ok`, `xt` vaut `c(11, 13)` |
| T9 (ii) | F8, F11 | « `café` », « `&&#0;` » ; en-tête « `&lt;` » |
| T10 (ii) | F7 et F8, puis les mêmes textes en chaîne en ligne | `data.frame` `identical()` |
| T11 | F9 | texte `"104.2 "` sous (ii), `"104.2&#160;"` sous (i) ; refus aval « non numériques (colonne xt : ligne(s) de données 1) », message identique avant et après |
| T12 (témoin) | F10, et les témoins existants l. 4217-4229 et l. 2591-2607 | inchangés (`t="str"` `11.5`, `0x10`, `<v/>`, `<v></v>`) |
| T13 (ii) | test l. 3392-3404 (#557, « limite consignée ») | **renversé** : en-têtes `c("t", "xt", "a&b", "yé")`, `d$xt` vaut `c("1.5", "3")`, `d[["a&b"]]` vaut `c("a&b", "x<y")` ; sous (i), inchangé, libellé réécrit sans la parité |
| T14 (ii) | ligne 1 dont la seule cellule hors `t`, `xt`, `yt` est `t="str"` `&amp;` | pas de `MOTIF_LIGNE1_VIDE` (R12 lit le texte décodé « & », non blanc) |
| T15 | tests existants de D-S1-18 et D-S1-23 en chaîne en ligne et partagée | inchangés (non-régression du message) |

Facultatif : un triangle dont l'en-tête `j1` est écrit `t="str"` `j&#49;` est refusé « … : &#49; ».

## 5. Surface documentaire

Les numéros de ligne sont ceux de `f07e219`. Ils bougeront avec #604 et #594 : `coder-approfondi` repère les passages par leur contenu.

**`R/engine.R`, commentaires (6b)**
- l. 11087-11089 (`.xlsx_controler_references()`) : « n'est decode par aucun des deux chemins (parite, mesure) et n'est pas vise » sort ; le `<v>` `t="str"` est visé (#606).
- l. 11283-11285 (en-tête d'`.xlsx_admettre()`) et l. 11352-11355 (commentaire de l'appel) : « d'une chaine en ligne » devient « d'une chaine en ligne ou du <v> d'une cellule t="str" ».
- l. 10646 (R8) : « str : <v> facultatif, texte quelconque » ; ajouter le renvoi au complément de R8 et, sous (ii), au décodage.
- l. 11198 (`.xlsx_controler_ligne_entete()`) : « chaine de formule (t="str", texte de <v> tel quel) » devient, sous (ii), « texte de <v> décodé (.xml_decoder()) ».
- l. 11504-11510 (en-tête d'`engine_lire_xlsx()`) : le paragraphe « lu tel quel, sans décodage … romprait la parité … ne s'écrit pas avec une entité » sort. Sous (ii) : texte des trois sources décodé après le contrôle des références. Sous (i) : limite réécrite sans la parité.
- `.xml_decoder()`, l. 9444-9449 : rien à changer, sauf à citer les trois appelants.

**`.tex` (`docwriter`, étape 7)**
- l. 5475-5478 : la phrase « lu tel quel, sans décodage … ne peut donner de valeur fausse (raisonnement, non mesuré) » **sort**. Elle est fausse au sens du critère E5 : F1, mesuré, retient une colonne fausse.
- l. 5411-5412 (règle des références de `sec:controles`) : « Le texte d'une cellule `t="str"` n'est pas visé (ci-dessous) » devient « le texte de toute chaîne en ligne, de toute chaîne de la table **et le `<v>` de toute cellule `t="str"`** ».
- l. 979 (vue d'ensemble) : « texte d'une cellule `t="str"` lu tel quel, sans décodage des entités, sur les deux chemins » sort ou est réécrit selon D-1.
- l. 1034 (R12, « chaîne de formule ») : préciser, sous (ii), que le texte est décodé.
- Sous (ii), le passage sur le décodage (l. 976-977) couvre les trois sources.

**Vie du dépôt.** `docs/suivi-documentation/`, sous le `\label` d'origine : D-S1-18 étendue et motif de l'ancienne exclusion.

## 6. Point d'arrêt D : **déclenché**

**Motif du déclenchement.** La recommandation est (ii), ce qui est le critère de la fiche. L'autre critère n'est pas rempli : aucun classeur aujourd'hui refusé ne devient lu (§ 3.1, mesure, et § 1.4, lecture).

**D-1. Texte d'une cellule `t="str"` admise : décodé ou lu tel quel ?**
- **(a) recommandé : option (ii).**
  - Refus des références ASCII et des blancs (D-S1-18, D-S1-23) étendu au `<v>` `t="str"`, puis décodage par `.xml_decoder()` des entités prédéfinies et des références admises, à l'assemblage comme en R12.
  - Fondement : XML 1.0, § 4.4.2 (*vérifié*) et § 4.6 (*à verser* à la relecture avant la décision) ; un seul modèle de texte pour les trois sources (mesure F7, F8 contre F12) ; une limite de moins au dossier.
  - Effet en plus de (b) : texte seul de cellules non employées (F7, F8, F9, F11) ; aucun σ_USP, verdict ni p-value.
- **(b) écartée en second : option (i).** Refus étendu, texte admis lu tel quel. Elle ferme E1 et E5 et n'est qu'une extension de D-S1-18. Elle garde un écart à la source sur une forme réaliste (« `R&D` » lu « `R&amp;D` »), à consigner comme limite avec un motif réécrit sans la parité.
- **(c) écartée : décoder sans étendre le refus.** `1&#48;4.2` serait lu 104,2 et `x&#116;` lu `xt`. Un classeur aujourd'hui refusé deviendrait lu (F3), et une forme qu'aucun écrivain connu ne produit serait admise. C'est contraire au contrat fermé (ADR 0020, point 2) et à D-S1-18.
- **(d) écartée : refuser aussi les entités nommées du `<v>` `t="str"`.** Ce serait refuser l'écriture obligatoire de `&` et `<` (XML 1.0, § 2.4, *non vérifié* ici), donc des classeurs ordinaires.

**D-2. Portée du refus dans le `<v>` `t="str"`.**
- **(a) recommandé : tout le classeur, comme D-S1-25** (en-tête ou corps, colonne lue ou annexe). Une note annexe `&#65;` fait refuser le classeur (F6, lu aujourd'hui sans valeur fausse). C'est la cohérence avec les chaînes partagées et en ligne, et elle ne demande aucune notion de « cellule lue » dans l'admission.
- **(b) écartée : seulement les cellules de la ligne 1 et des colonnes `t`, `xt`, `yt` ou du triangle.** L'admission ne sait pas quelles colonnes l'aval emploiera (argument abandonné pour #594, spécification amendée, § 0), et la portée de D-S1-25 deviendrait inégale entre sources.

**Visa du tableau du § 3** (étape 6b, mainteneur) : F1 et F4 (σ_USP rendu → refus), F6 (lu → refusé).

## 7. Fonctions touchées (hypothèse d'`architect` confirmée en partie)

- **`.xlsx_admettre()`** : l'appel du complément de R8 couvre les cellules `t="str"`. C'est ici, et non dans `.xlsx_controler_contenus()`, que se fait le changement de code.
- **`.xlsx_controler_references()`** : **inchangée** (réemployée telle quelle ; commentaire seul).
- **`.xlsx_controler_contenus()`** : **code inchangé** (commentaire R8 seul).
- **`.xlsx_controler_ligne_entete()`** : sous (ii), `texte[st] <- .xml_decoder(brut[st])`.
- **Assemblage d'`engine_lire_xlsx()`** : sous (ii), décodage de `val` pour `typ == "str"`, avant la résolution des `t="s"`.

Ni argument nouveau, ni modification d'`app.R`, ni contrat de retour nouveau (forme du `data.frame` inchangée).

---

## Retour

- **Statut** : `revue requise`. Le point d'arrêt D est déclenché (D-1, D-2) et c'est au mainteneur de le trancher. Le reste de la spécification est complet, à une réserve près : les §§ 2.4 et 4.6 de XML 1.0 n'ont pas été relus à la source.
- **Résultat** :
  - option (ii) recommandée, (i) acceptable en second ;
  - refus identique à D-S1-18 et D-S1-23, motif existant `TEXTE_REFUS_REFERENCE_NUMERIQUE`, portée de D-S1-25 ;
  - tableau avant / après (11 classeurs forgés, corpus 38 sur 38 inchangé, six références hors du chemin) ;
  - 15 tests à valeur attendue explicite ;
  - surface documentaire listée ;
  - D-1 et D-2.
- **Preuves** :
  - *vérifié* (lecture citée) : code à `f07e219` (lignes citées), `.tex`, tests l. 3392-3404 et 4449-4454, D-S1-18 à D-S1-25, ADR 0020, XML 1.0 § 4.4.2 et § 2.11 par `relecture-xml-1.0.md`, chemin des références (`tests/outils_tests.R`) ;
  - *vérifié* (mesure) : `sonde606.R` et `corpus606.R`, sorties citées par leur md5, `C.UTF-8`, R 4.3.3, lecteur interne ;
  - *vérifié* par lecture, non mesuré exhaustivement : « aucun classeur refusé ne devient lu sous (ii) » ;
  - *hypothèses* : Excel et LibreOffice écrivent `t="str"` avec `&amp;` et `&lt;` ; aucun écrivain n'écrit une lettre ASCII en référence dans un `<v>` (hypothèse de D-S1-18) ; σ_USP 0,0762262056 de F1, repris du commentaire du test et non remesuré ;
  - *non vérifié* : XML 1.0, §§ 2.4 et 4.6, à la source ; comportement sous une locale Windows (même limite que D-S1-23).
- **Informations manquantes** :
  - `www.w3.org` injoignable depuis cette consultation (`getaddrinfo ENOTFOUND`) : il faut l'autoriser dans les réglages réseau de la session, ou que la session verse elle-même les §§ 2.4 et 4.6 dans `relecture-xml-1.0.md` avant la décision D-1 ;
  - le corpus ne contient aucune cellule `t="str"`.
- **Décisions non résolues** : D-1 et D-2 (mainteneur, avant 6b) ; visa du tableau (mainteneur, à 6b) ; forme d'un seul appel ou de deux (`coder-approfondi`).
- **Critères déclenchés** (`docs/agents/routage.md`, § 4.2) :
  - **un résultat final change**, hors références : F1 et F4 passent d'un σ_USP rendu à un refus (classeurs forgés) ; F6 passe de lu à refusé ;
  - ADR 0020 appliqué, non contredit ; décision D-S1-18 étendue (et D-S1-25 pour la portée) ;
  - contrat partagé : non déclenché au sens strict (signature et forme du retour d'`engine_lire_xlsx()` inchangées). Sous (ii), le texte rendu change pour des cellules `t="str"` porteuses d'entités : je le signale ;
  - au § 4 : aucun désaccord avec `audit` ni avec un ADR. La source à relire (§§ 2.4 et 4.6) est un problème de documentation disponible, non de double lecture. Validité à T = 8 : sans objet.
- **Constats hors périmètre** :
  - entités non prédéfinies (`&nbsp;`) rendues telles quelles par `.xml_decoder()` dans les trois sources de texte : critère « aucun » (ni valeur employée, ni affirmation de la documentation) ;
  - aucune cellule `t="str"` au corpus du témoin : critère « aucun » (limite à consigner avec E-18/11 (corpus)) ;
  - le test l. 4449-4454 consigne comme témoin un σ_USP rendu à tort : il relève de #606 (renversé par T1), il n'est donc pas hors périmètre.
- **Prochaine action recommandée** : la session verse ce texte et les scripts. Elle complète `relecture-xml-1.0.md` des §§ 2.4 et 4.6, puis pose D-1 et D-2 au mainteneur. Après la décision, et après #594 (étape 6), elle passe à `coder-approfondi` à l'étape 6b selon les §§ 2, 4 et 5.
