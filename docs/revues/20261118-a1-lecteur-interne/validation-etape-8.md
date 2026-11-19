# Validation du fond, fin de branche A1 (étape 8) : diff du `.tex` et tableaux avant / après

> *Rédigé par l'agent actuary (IA).* Fiche `actuary`, 19/11/2026, en lecture seule, sur `claude/creneau-a1`, tête `69283e0`. Étape 8 de la fiche « Créneau d'absorption A1 » (`docs/feuille-de-route.md`, l. 4200). Rapport versé intégralement par la session.

## Synthèse

- **Diff du `.tex` (six commits `docs:`, `b3b5dd7..69283e0`) : visa avec réserves.**
  - Aucun constat bloquant.
  - **Un constat majeur, à lever avant le PDF (étape 11).** `\datedoc` passe au 19/11 sans que soient refaites les consultations datées par « à la date d'établissement » (question e).
  - Neuf constats mineurs (m1 à m9).
  - Aucune phrase ne décrit plus deux lecteurs en production.
  - Le texte est exact contre le code sur tous les points vérifiés.
  - Toutes les citations de XML 1.0 se retrouvent dans `relecture-xml-1.0.md`.
- **Tableaux avant / après.**
  - **#604** (`46525b8`) : visa, avec une réserve mineure (m8) sur la formulation du message de commit. Le tableau « hors références » de la fiche (l. 4212-4224) est juste et complet.
  - **#602** (`17d84e6`, `c21920e`) : visa. Les lignes Windows restent « attendu, non mesuré » jusqu'au rejeu de l'étape 10b, comme les tableaux le disent eux-mêmes.
  - **#603** (`fbe5a5b`) : visa, même condition de l'étape 10b.
  - **#594** (`a072411`) et **#606** (`f8d2c96`), déjà visés par le mainteneur : ils concordent avec les spécifications, avec l'inventaire et avec ma remesure.
- **Liste fermée du témoin** (`ECARTS_TEMOIN_OPENXLSX`, deux entrées sous 4.2.5.2) et note `mise-en-oeuvre-594.md` : cohérentes avec l'ADR 0020 (point 3). La correction de mon énoncé T15 (spécification de #594, § 4) est juste.
- **Questions a à g** : réponses ci-dessous. Aucune ne demande de reprise du code.

## 1. Ce que j'ai vérifié, et comment

Mesures faites sous `LC_ALL=C.UTF-8`, R 4.3.3, moteur chargé par `charger_moteur()`. `openxlsx` n'est pas installé dans ma session. Script hors dépôt.

- **Corpus** (`tests/donnees/classeurs/`) :
  - `md5sum -c md5.txt` : 38 sur 38 OK ;
  - aucune cellule `t="str"` dans les 38 feuilles (`unzip -p` puis `grep`) ;
  - le lecteur interne lit les 38 classeurs, et la sortie aval est `identical()` à la source CSV, sans aucun écart (36 avec `ok = TRUE`, les 2 triangles à note refusés en aval comme leur source).
- **Classeurs forgés** (écrivain interne, feuille remplacée) :

  | Cas | Résultat |
  |---|---|
  | `<t />` | lu `""` |
  | `<t >1</t>` | refus R3 |
  | `<t xml:space="preserve" />` | refus R3 |
  | `<t xml:space="preserve"> 104.2 </t>` | lu `" 104.2 "` |
  | `&#13;` et `&#32;` en chaîne en ligne | refus des références numériques |
  | `a<CR><LF>b` et `a<CR>b` en chaîne en ligne | lus `"a\nb"` |
  | `t="str"` `R&amp;D` | lu `"R&D"` |
  | `t="str"` `caf&#233;` | lu `"café"` |
  | `t="str"` `a&#13;b` | refus des références numériques |
  | `t="str"` `a<CR><LF>b` | lu `"a\nb"` |
  | chaîne d'analyse `.xml_textes(.xml_fins_de_ligne(...))` sur `a&#13;b\r\nc` | `"a\rb\nc"` |

- **Contrôles de la documentation** :
  - `tests/controle_doc_nd.R --bloquant` : code 0, aucune violation ;
  - `tests/concordance_doc_moteur.R --strict` : 0 écart.
- **Code relu** (`R/engine.R` à `69283e0`) :
  - `.xlsx_defaut_chemin()` (l. 8946-8967) ;
  - `.engine_ecrire_octets()` (l. 9041) et les cinq parties écrites (l. 9201-9220) ;
  - `.xlsx_texte()` (l. 9462) et `.xml_fins_de_ligne()` (l. 9495) ;
  - `.xml_decoder()` (l. 9563) ;
  - règle `t_is` (l. 10512-10536) et `TEXTE_REFUS_R3` (l. 10358) ;
  - `.xml_codes_retires_entete()` (l. 11168) ;
  - `.xlsx_controler_ligne_entete()` (l. 11369-11380) ;
  - appel du complément de R8 sur `<is>` et `t="str"` (l. 11516-11519) ;
  - décodage du `<v>` `t="str"` à l'assemblage (l. 11866-11867).
- **Retrait de l'embranchement** : `grep openxlsx R/engine.R` hors commentaires ne rend que l. 9149 (message d'`engine_ecrire_xlsx()`). `app.R`, `R/display_helpers.R` et `R/charger_moteur.R` : 0 occurrence (condition 1 de l'ADR 0020).
- **CI** : au dernier commit de code (`b3b5dd7`), le contrôle « Témoin openxlsx et archive zip » est en `success` (`gh api .../check-runs`). Cela vaut mesure de la liste fermée sous 4.2.5.2. À la tête `69283e0`, qui ne porte que des commits `docs:`, le même job était encore en cours lors de ma lecture.
- **Recherche de deux lecteurs** : `grep` de « deux chemins », « voie de repli », « deux voies », « avec ou sans openxlsx » dans le `.tex`. Seules restent deux occurrences sans rapport (l. 15376, l. 15568). Les 59 mentions d'`openxlsx` relues une à une : chacune est un témoin de la batterie ou une mesure qui motive une règle. Le cadre est posé l. 5208-5210 : « ses lectures, citées ci-dessous, sont des mesures qui motivent une règle, non une lecture de l'outil ».

## 2. Diff du `.tex` : constats

### Majeur

**M1. `\datedoc` passé au 19/11/2026 sans nouvelle consultation des sources datées par lui.**
- **Où** : `docs/latex/doc_tests_usp.tex` l. 49. Mentions qui s'y ancrent : l. 10310, 21079, 21111, 21118, 21124, et **l. 21135**, une sixième que le brief ne liste pas (articles R. 352-5 et R. 356-19 du code des assurances, « Versions en vigueur à la date d'établissement »).
- **Constat** : la dernière vérification consignée de ces mentions est celle du 06/11/2026 (`docs/suivi-documentation/IV.md` l. 207, « Vérifications du 06/11/2026, date d'établissement du document »). La question 2580 a été relue le 16/11 (`IV.md` l. 213). Je n'ai trouvé aucune trace de consultation au 17/11, au 18/11 ni au 19/11 (*non vérifié* au-delà de `docs/suivi-documentation/`).
- **Conséquence** : sans nouvelle consultation, le dossier affirme un état des sources au 19/11 qui n'a pas été constaté. C'est vrai en particulier du statut d'application d'EIOPA-BoS-25/249 (l. 10310, 21111, 21118), qui décide quelles orientations s'appliquent.
- **Critère** : G (majeur). Le défaut existe depuis le passage à 3.10 (17/11) ; ce diff le reconduit.
- **Correction** : voir question e.

### Mineurs

- **m1, l. 5205-5207.** « formes que l'outil ne lit pas de façon sûre : formes qu'aucun écrivain connu ne produit, ou qu'un lecteur répandu lit fausses… ».
  - Une forme qu'aucun écrivain ne produit n'est pas, par là même, une forme que l'outil lit mal. Ces formes relèvent de la phrase suivante (« Parce que le contrat est fermé, il refuse aussi des formes que le lecteur interne et `openxlsx` liraient juste… »).
  - « aucun écrivain connu » n'y porte pas non plus de statut.
  - Proposé : retirer « formes qu'aucun écrivain connu ne produit, ou » de la première phrase, et compléter la seconde par « …liraient juste l'un et l'autre, et qu'aucun écrivain mesuré ne produit (hypothèse non vérifiée pour Excel et LibreOffice) ».
- **m2, l. 5364-5370.** Les formes admises comprennent `<t/>` « (des blancs étant admis avant « /> ») », donc `<t />`. Or la liste des refus commence par « blanc après le nom ou avant « > » ou « /> » ». Lue à la lettre, elle refuse `<t />`, que le code admet (l. 10536, `^<t[ \t\r\n]*/>$` ; mesuré : `<t />` lu `""`). Proposé : « blanc dans la balise, hors des blancs admis avant « /> » de la forme vide sans attribut ».
- **m3, l. 5374-5376.** « aucun écrivain connu ne les produisant (hypothèse non vérifiée sur Excel et LibreOffice) » mêle deux statuts. C'est *mesuré* pour openpyxl, pandas et XlsxWriter (spécification de #594, § 1, justification 4 ; corpus), *hypothèse* pour Excel et LibreOffice. Voir question b.
- **m4, l. 5572-5575.** « que bornent l'admission … et la relecture … » : ces deux garde-fous ne bornent pas l'hypothèse, ils en limitent la portée. Voir question a.
- **m5, l. 976 (index, `engine_lire_xlsx()`).** « normalisées … avant toute règle et tout décodage » : le contrôle d'encodage R1 précède la normalisation (`.xlsx_texte()`, l. 9465-9472), tout comme le contrôle d'emplacement de la table. `sec:controles` (l. 5248) dit juste : « ensuite … avant toute autre règle ». Proposé : « après le contrôle d'encodage, avant toute autre règle et tout décodage ».
- **m6, l. 5538-5541.** « sa lecture ne dépend que du code de `R/engine.R` et de R » est démenti par la phrase suivante (trois éléments du système hors de l'identité, dont la locale). Proposé : « sa lecture dépend du code de `R/engine.R` et de R, que … identifient ; restent hors de cette identité… ». Le texte de l'ADR 0020 (l. 106) est repris sans écart pour le reste.
- **m7, l. 5546.** « Le lecteur interne lit juste des balises `<sheet>` et `<Relationship>` préfixées ».
  - Mesuré sur des préfixes liés à l'espace de noms du classeur ; c'est la forme d'Open XML SDK (commentaire l. 9660-9661).
  - Le lecteur ne contrôle pas la liaison du préfixe (aucune lecture de `xmlns` dans le lecteur, `grep` *vérifié*).
  - La recommandation sur les espaces de noms n'a pas été relue à la source (inventaire, Conventions : jugement *hypothèse fondée*).
  - Proposé : « lit la feuille désignée sous des balises préfixées (mesuré, préfixe lié à l'espace de noms du classeur, liaison non contrôlée) ».
  - Ce constat ne touche aucune valeur d'un écrivain connu.
- **m8, message de `46525b8`** (tableau de #604). Deux défauts, sans effet sur le tableau de la fiche (l. 4212-4220), qui est complet :
  - la liste omet A12 (blancs après un `<t/>` vide en table) ;
  - la phrase « Aucune de ces lignes ne touche t, xt, yt ni le triangle ; aucun σ_USP… » est inexacte pour A1 à A4. Sur un poste muni d'`openxlsx`, une erreur R y devient un classeur lu, donc un σ_USP calculé là où il n'y en avait aucun (inventaire, Retour, « Critères déclenchés »). L'ADR 0020 l'a accepté.

  Pas de réécriture de commit : le tableau joint à la PR suffit, s'il reprend A1 à A14 et dit « aucun σ_USP des six cas ; sur poste muni d'`openxlsx`, A1 à A4 : erreur R → classeur lu ».
- **m9, l. 5558-5565.** « 38 classeurs écrits … à partir des fichiers CSV » et « identique à celle de leur source CSV » : pour les triangles à note, la source est `triangle_mw.csv` complété d'une colonne `note` construite par le test (`test_controles_entree.R` l. 2539). C'est une précision, sans effet.

### Critères du brief, point par point

- **Exactitude contre le code** : tenue. Points vérifiés :
  - les quatre formes du `<t>` ;
  - le décodage des trois sources ;
  - la normalisation (`\r\n` puis `\r`), qui laisse `&#13;` et `&#xD;` hors de son effet, ces références étant ensuite refusées ;
  - les cinq parties écrites en octets, et le CSV aussi ;
  - le refus `X:f.xlsx`, `c:f.xlsx`, `X:` sous `systeme = "windows"`, l'argument `systeme` et l'ordre des défauts ;
  - le motif R3 paraphrasé fidèlement ;
  - R12 sur texte décodé ;
  - le refus des références étendu à tout `<v>` `t="str"`.

  Seuls m2 et m5 sont des écarts de lettre.
- **Exactitude contre XML 1.0** : tenue.
  - § 2.11 cité mot pour mot (« on input, before parsing ») ;
  - § 2.10 (transmission des caractères, `xml:space` réduit à une intention, autre valeur traitée comme une erreur que l'application peut rejeter) ;
  - § 3.1 (balise vide) ; § 4.4.2 et § 4.6 (inclusion, entités prédéfinies) ; § 2.4 (`&` et `<` échappés).

  Tout figure dans `relecture-xml-1.0.md`. Le bornage du § 10.1 de la spécification de #594 est respecté (l. 5372-5375 ; question b).
- **Deux lecteurs en production** : aucune phrase (§ 1).
- **Mesuré, raisonnement, hypothèse** : tenu, à m1, m3, m4 et m7 près.
- **Motifs cités** : seule une paraphrase de `TEXTE_REFUS_R3` est nouvelle (l. 5337-5338), fidèle au code (l. 10358). Le motif de #603 est paraphrasé, non cité. Les citations anciennes sont inchangées.
- **`CONVENTIONS.md`** :
  - aucune vie du dépôt dans le `.tex` (contrôle à 0) ;
  - textes retirés consignés dans `docs/suivi-documentation/I.md`, sous les labels d'origine (index, `sec:graines`, `sec:controles`) ;
  - mesure de `docwriter` gardée pour chaque ajout ;
  - le fond retiré (mesures d'`openxlsx` de D-S1-31) est conservé dans `I.md`, entrée #594.

## 3. Tableaux avant / après

| Commit | Issue | Verdict | Motif |
|---|---|---|---|
| `46525b8` | #604 | **visa**, réserve m8 | Les entrées concordent avec l'inventaire, § 5 (A1 à A14, et la nuance de version et de système sur A14) et avec la fiche (l. 4212-4220). Preuve de non-changement sur 42 classeurs avec `openxlsx` 4.2.5.2 (condition 2), six cas à écart 0. Aucun σ_USP des six cas, aucune p-value, aucun verdict. |
| `17d84e6` | #602 (3a) | **visa** | Linux : md5 des cinq parties et du CSV identiques (mesuré). Windows : « attendu, non mesuré » ; preuve par construction (`writeBin()`) et test d'octets (l. 7457, 7549). Confirmation à l'étape 10b. |
| `c21920e` | #602 (3b) | **visa** | Conforme au § 2.11 et à l'ordre « normalisation puis décodage » (§ 4.4.2). Corpus : 0 classeur changé. Fuzz de l'audit : aucune admission ni aucun refus changé. Ma remesure le confirme (CR et CRLF lus `\n`, `&#13;` refusé). |
| `fbe5a5b` | #603 | **visa** | Refus prouvé sous Linux, système simulé. Formes `X:/`, `X:\` et UNC admises. Unix inchangé. Rejeu Windows à l'étape 10b. |
| `a072411` | #594 | concordant (visa du mainteneur) | 13 classeurs passent de « refus R3 » à « lu », égaux à `LUS_594_CORPUS` et au § 8 de la spécification. Mesuré : 38 lus, 0 écart à la source. |
| `f8d2c96` | #606 | concordant (visa du mainteneur) | F1 à F11 conformes au § 3.1 de la spécification. Corpus sans `t="str"` (*vérifié*). Aucun classeur ne passe de refusé à lu. |

**Cohérence avec l'inventaire de l'étape 1a.**
- Les 14 écarts admis sont repris au tableau « hors références ».
- Les formes de classe R n'y entrent pas, à juste titre.
- C1 est traité par #606, sous l'option (ii).
- La consigne de l'inventaire, § 2 (dire que certaines règles nées de la parité protègent aussi le lecteur interne) est tenue en substance dans le `.tex`. Plusieurs règles disent « par le lecteur interne comme par `openxlsx` » ou « ni l'un ni l'autre » (l. 5273, 5316, 5330, 5507), et la règle sur `r="1"` motive le refus sans recours à la parité (« la position n'est pas devinée », l. 5409). Je n'en fais pas un constat.

**Liste fermée du témoin.**
- Deux entrées (`blancs/ligne_finale_note_blanche.xlsx`, `entete/openpyxl_entete_lu_blanc.xlsx`), datées de 4.2.5.2 (`test_controles_entree.R` l. 2510-2516).
- La note `mise-en-oeuvre-594.md` a raison : le critère porte sur la sortie aval (ADR 0020, point 3, l. 78), et la boucle de l'emploi 1 n'appelle pas `engine_lire_xlsx()` (l. 2605-2610, *vérifié*).
- Mon énoncé T15 (« note préfixée pour les 12 séries ») confondait les deux niveaux de comparaison et était marqué *non vérifié*. La correction est fondée.
- Le décompte « 13 formes » de T5 était faux, la correction (11 formes au § 1) est exacte.

## 4. Questions a à g

**a. Limite Excel et LibreOffice (l. 5571-5575).**
- Sur le fond, la formulation convient.
  - Absence de classeur Excel ou LibreOffice au corpus : *vérifiée* (étape 10a sans objet, E-18/11 (Q-69)).
  - Absence de mesure du lecteur interne sur ces classeurs : *vérifiée*.
  - Absence de valeur fausse sur ces tableurs : marquée hypothèse non vérifiée.
- Défaut de forme : « que bornent » suggère une borne qui établirait l'hypothèse. Or l'admission ne couvre que les formes hors du contrat. Une forme admise qui serait mal lue n'est couverte que par la relecture de l'utilisateur.
- Texte proposé : « …est une hypothèse, non vérifiée ; l'admission refuse toute forme hors du contrat, et seule la relecture des données affichées avant tout calcul (ci-dessous) couvre une forme admise qui serait mal lue. »
- Conforme à l'ADR 0020, « Conséquences », l. 142.
- *Vérifiée* (sources citées) ; mineur m4.

**b. Formes du `<t>` refusées : fidélité au § 10.1.**
- Oui pour le partage du fondement. Seul le refus d'une valeur autre que `default` ou `preserve` repose sur le § 2.10 ; les autres reposent sur le seul contrat fermé (l. 5372-5375, à la lettre du § 10.1 et du point 3 de `relecture-xml-1.0.md`).
- La clause qui suit, « aucun écrivain connu ne les produisant (hypothèse non vérifiée sur Excel et LibreOffice) », va au-delà du § 10.1 sans le contredire. Elle mêle cependant un fait mesuré et une hypothèse (m3).
- Texte proposé : « …ne repose que sur le contrat fermé ; aucun des écrivains mesurés (openpyxl, pandas, XlsxWriter) ne les produit, ce qui n'est pas vérifié pour Excel et LibreOffice. »
- *Vérifiée*.

**c. Corpus `t="str"` : « forme qui ferait refuser le classeur ».**
- C'est juste.
  - Sous l'option (ii) décidée, une référence à un caractère ASCII ordinaire, ou à un blanc, dans un `<v>` `t="str"` est refusée avant toute lecture (l. 11516-11519 ; tests T1 à T7 de #606 ; ma mesure de `a&#13;b`). Elle n'est jamais lue fausse.
  - L'échec de l'hypothèse coûterait un refus à tort, non une valeur fausse.
  - Conforme au § 3.2 et au § 2 de la spécification de #606.
- Précision facultative : « référence numérique à un caractère ordinaire ou à un blanc », pour suivre le motif du refus.
- *Vérifiée*.

**d. XML 1.0 aux « Compléments bibliographiques » ?**
- La citation en ligne suffit.
  - `CONVENTIONS.md` réserve `\refl` à la référence fondatrice d'un test, et les compléments aux affirmations sur T = 8 et sur le bootstrap (l. 128). XML 1.0 n'est ni l'un ni l'autre.
  - Précédent : la norme ISO/IEC 29500-4 n'est citée qu'en ligne (l. 5499), et XML 1.0 l'était déjà ainsi (l. 1130).
  - L'édition (cinquième, 2008) et le paragraphe identifient la source sans ambiguïté.
- Amélioration facultative, non exigée : ajouter l'URL « This version », `https://www.w3.org/TR/2008/REC-xml-20081126/`, à la première occurrence (l. 1130).
- *Vérifiée* (conventions, précédent) ; aucun constat.

**e. `\datedoc` au 19/11 et mentions « à la date d'établissement ».**
- Le passage de la date sans nouvelle consultation rend ces mentions non étayées (M1).
- Traitement recommandé, à l'étape 11, le jour du PDF :
  1. refaire les consultations des six mentions (l. 10310, 21079, 21111, 21118, 21124, 21135) : CELLAR ou EUR-Lex pour 2015/498, page de l'AEAPP d'EIOPA-BoS-25/249, page de l'ACPR (déclaration de conformité), question 2580, Légifrance pour R. 352-5 et R. 356-19. La veille de #463 n'en couvre qu'une partie ;
  2. poser `\datedoc` à ce jour-là, en même temps que le PDF ;
  3. consigner les constats dans `docs/suivi-documentation/IV.md`, comme au 06/11 (l. 207) ;
  4. à défaut, ramener `\datedoc` à la dernière date où toutes les mentions ont été vérifiées. `CONVENTIONS.md` interdit d'écrire en clair une date de consultation postérieure au 31/12/2025, d'où l'ancrage sur `\datedoc`.
- La pratique de Q-55-7 (a) (date posée par le dernier commit `docs:`) présente ce défaut à chaque branche. C'est au mainteneur de trancher la règle : soit chaque déplacement de `\datedoc` impose les consultations, soit une seconde date est admise en exception E10.
- *Vérifiée* (trace du 06/11 lue) ; absence d'autre consultation : *non vérifiée* hors de `docs/suivi-documentation/`.

**f. Critère « `&#13;` lu `\r` » de l'étape 3b, reporté sur la chaîne d'analyse.**
- Acceptable.
  - La propriété exigée par XML 1.0, normalisation avant décodage (§ 2.11 puis § 4.4.2), est éprouvée sur la composition même qu'emploie la lecture complète : `.xlsx_texte()`, puis `.xml_textes()`, puis `.xml_decoder()` (test l. 4921 ; ma mesure donne `"a\rb\nc"`).
  - En lecture complète, `&#13;` est refusé par D-S1-23 (test l. 4928). Ce refus est plus strict que la source, et il est consigné au `.tex` (l. 5258-5260).
  - Aucune lecture fausse n'est possible.
- Le critère de la fiche avait été écrit sans tenir compte de D-S1-23. Il est à reformuler en ce sens dans la synthèse de sortie.
- *Vérifiée*.

**g. T14 de #606 : appel direct de `.xlsx_controler_ligne_entete()` sur `&#32;`.**
- Acceptable. C'est le seul point où le décodage dans R12 est observable, et le test le dit (commentaire l. 4816-4821).
- L'absence d'effet en lecture complète est *vérifiée* par construction :
  - D-S1-23 refuse toute référence que `.xlsx_blancs_entete()` réduit à rien, avec la même fonction et dans la même locale (`.xml_codes_retires_entete()`, l. 11168) ;
  - les entités prédéfinies se décodent en caractères non blancs ;
  - une référence hors du domaine des caractères reste telle quelle.

  Un texte admis est donc blanc après décodage si et seulement s'il l'était avant.
- Faut-il l'écrire au dossier ? Pas au `.tex`. La phrase de l'index (« au texte décodé comme dans le tableau rendu », l. 1037-1038) dit ce que l'utilisateur doit savoir, et la propriété d'équivalence relève du code et du test, où elle est déjà écrite. Si le mainteneur la veut au dossier, une ligne dans `docs/suivi-documentation/I.md` suffit, marquée « par construction ».
- *Vérifiée*.

## 5. Constats hors périmètre (ADR 0018)

- **H1. Pratique de `\datedoc`** (origine : passage à 3.10 du 17/11, reconduit à 4.1 puis à 4.2). Critère **G** (majeur) ; preuve : `IV.md` l. 207, seule vérification datée consignée. Traitement dans A1 à l'étape 11 (M1). Règle générale : décision du mainteneur. Issue rédigée ci-dessous, à créer seulement si le mainteneur sort la règle d'A1.
- **H2. Commentaire d'`engine_ecrire_xlsx()`** (`R/engine.R` l. 9048-9049) : « par l'ecrivain interne seul, avec ou sans openxlsx ». Juste, mais périmé dans sa forme. Critère : aucun.
- **H3. Normalisation des valeurs d'attribut** (XML 1.0, § 3.3.3) : non appliquée par le lecteur (commentaire l. 9111-9114), et non dite au `.tex`. Sans effet sur une valeur : `r` et `t` à blancs sont refusés, et une cible à tabulation donne une feuille introuvable, donc un refus (raisonnement, non mesuré). Critère : aucun.

**Issue rédigée (H1), à créer sur accord du mainteneur seulement :**

> *Rédigé par l'agent actuary (IA).*
> **Titre** : docs: `\datedoc` déplacé sans nouvelle consultation des sources datées « à la date d'établissement »
> **Libellés** : `bug`, `needs-triage`
> **Corps** : Six mentions du `.tex` (l. 10310, 21079, 21111, 21118, 21124, 21135) datent une consultation par `\datedoc`. La dernière vérification consignée est celle du 06/11/2026 (`docs/suivi-documentation/IV.md` l. 207), alors que `\datedoc` est passé au 17/11, puis au 19/11 (règle Q-55-7 (a)). Le dossier affirme donc un état des sources (dont l'application d'EIOPA-BoS-25/249) qui n'a pas été constaté à cette date. Critère ADR 0018 : G. Correction : refaire les six consultations à chaque déplacement de `\datedoc` et les consigner dans `IV.md`, ou admettre une date de consultation distincte (exception E10 de `CONVENTIONS.md`). Décision du mainteneur.

## Retour

- **Statut** : `complet` pour les critères du brief, à trois réserves près :
  - la liste fermée du témoin n'est pas remesurée par moi (`openxlsx` absent de ma session) ; je m'appuie sur le contrôle de CI en `success` à `b3b5dd7` ;
  - les lignes Windows de #602 et #603 attendent l'étape 10b ;
  - M1 attend l'étape 11.
- **Résultat** :
  - `.tex` : visa avec réserves (M1 majeur ; m1 à m7 et m9 mineurs).
  - Tableaux : #604 visa (réserve m8) ; #602 visa ; #603 visa ; #594 et #606 concordants.
  - Questions a à g : réponses au § 4.
- **Preuves** :
  - *vérifié* :
    - code relu (lignes au § 1) ;
    - corpus lu par le lecteur interne : 38 classeurs, 0 écart ; md5 conformes ; aucune cellule `t="str"` ;
    - douze cas forgés mesurés ;
    - `controle_doc_nd.R --bloquant` code 0 ; concordance `--strict` à 0 ;
    - CI à `b3b5dd7` : contrôle du témoin en `success` ;
    - citations de XML 1.0 retrouvées dans `relecture-xml-1.0.md` ;
    - ADR 0020 (l. 78, 106, 142) ; `CONVENTIONS.md` (l. 107-128) ; `IV.md` l. 207.
  - *hypothèse* : la portée du constat m7 (préfixe lié à un autre espace de noms) ; aucun écrivain connu ne produit une telle forme.
  - *non vérifié* :
    - liste fermée sous 4.2.5.2 (pas d'`openxlsx` ici) ;
    - comportement sous Windows ;
    - consultations éventuelles des sources après le 06/11 (hors question 2580 au 16/11) ailleurs que dans `docs/suivi-documentation/`.
- **Informations manquantes** : `openxlsx` 4.2.5.2 dans ma session ; trace d'une consultation des six sources au 19/11.
- **Décisions non résolues** :
  - règle de `\datedoc` (H1) : mainteneur ;
  - reprise de m1 à m9 par un commit `docs:` de `docwriter`, ou mise en « Constats mineurs écartés (ADR 0018) » : session, puis mainteneur.
- **Critères déclenchés** (`routage.md`, § 4) :
  - aucun désaccord avec `audit`, un autre expert ou un ADR ;
  - deux résultats changés hors références (#604, A1 à A4 : erreur R → classeur lu, sur un poste muni d'`openxlsx`), déjà acceptés par l'ADR 0020 ;
  - question d'organisation (H1) qu'aucune source ne tranche ;
  - validité à T = 8 : sans objet, aucun test statistique touché.
- **Constats hors périmètre** : H1 (G), H2 (aucun), H3 (aucun) ; détail au § 5.
- **Prochaine action recommandée** :
  1. faire reprendre par `docwriter` m2, m5 et m6 (exactitude), et de préférence m1, m3, m4 et m7 (statut épistémique), en un commit `docs:`, revu sur son diff ;
  2. à l'étape 11, faire les six consultations, poser `\datedoc` au jour du PDF et consigner dans `IV.md` ;
  3. joindre à la PR le tableau « hors références » complet de #604 (m8) ;
  4. rejouer l'étape 10b pour lever les lignes Windows de #602 et #603.
