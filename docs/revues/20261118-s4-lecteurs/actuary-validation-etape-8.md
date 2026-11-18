# Validation du diff du `.tex` de S4 et des textes livrés (étape 8)

> *Rédigé par l'agent `actuary-approfondi` (IA), 18/11/2026, branche `claude/lecteurs-messages-et-qualite` (tête `fdef4b9`, partie de `main` `3c6af48`). Rapport rendu sans écriture dans le dépôt, versé par la session principale (Q-54-10) ; mise en forme légère : quelques puces du § 5, du § 6 et du « Retour » resserrées, liste finale des sources web omise, décompte des constats rectifié (huit, dont C8 facultatif), sans changement de fond.*

## Verdict

**Visa avec réserves.** Il n'y a aucun constat bloquant ni majeur. Huit constats mineurs portent sur le texte du diff : C1 à C7 demandent une correction au mot près, C8 est facultatif. `docwriter` peut les faire en un seul commit `docs:`, sans effet sur aucun résultat. C1 est le seul constat qui touche un énoncé inexact sur le code.

Ce qui a été examiné :
- le diff `git diff 3c6af48...HEAD -- docs/latex/ docs/suivi-documentation/`, soit les six commits `docs:` ;
- le code de `R/engine.R` à la tête et le diff d'`app.R` ;
- les textes de l'étape 1 et le tableau des sondes visé ;
- l'issue #595 et la veille de #463.

Contrôles exécutés sous `LC_ALL=C.UTF-8` :
- `concordance_doc_moteur.R --strict` : **0 écart** ;
- `controle_doc_nd.R --bloquant` : **0 violation**.

## 1. Exactitude des affirmations nouvelles ou modifiées (point 1)

### Vérifié conforme au code

**#569, information de lecture des séries.**
- La condition d'émission est `any(o != seq_along(o))`. Le champ est vide pour un refus, pour un fichier déjà rangé et pour un fichier sans colonne t (`R/engine.R` l. 8647-8664).
- Le motif cité, « `Lignes du tableau rangees par annee t croissante pour le calcul` », est le début exact de la chaîne de la l. 8654.
- `app.R` transmet `r$avertissements_lecture` dans les deux branches, au démarrage et à l'import, que les données passent ou non `engine_valider_donnees()`.
- Remesure : lignes 1 et 2 permutées → information citant « 1, 2 », xt identique au fichier rangé ; fichier rangé, fichier sans t, fichier refusé → champ vide.

**#568, suite d'en-têtes en chiffres romains.**
- `.suite_entetes_romains()` (l. 8235-8256) : au moins deux en-têtes, casse uniforme, blancs de bord ignorés, formes de `as.roman()`, rang limité à 3 000. Configuration 2 refusée avant H1 (l. 8755), configuration 1 substituée au motif de `.motifs_colonne_i()` (l. 8773).
- Le motif cité est le début exact de la chaîne de la l. 8749.
- Remesure sur `triangle_mw.csv` :

| Configuration | Résultat |
|---|---|
| I…VIII sans colonne i | motif dédié |
| i, I…VIII | motif dédié |
| i…viii (minuscules) | motif dédié |
| blancs de bord | motif dédié |
| colonne I d'années + j0… | accepté |
| colonne I d'années + II…VIII | accepté |
| « i, II, III » | accepté |
| « I, ii, iii » | accepté |
| colonne I de montants 301…308 (« Limite ») | « Triangle non carre », sans motif dédié |

  La phrase « Limite » du `.tex` est donc **exacte (mesuré)**.

**#558, primitives communes.**
- `.cellules_nettoyees()`, `.cellules_vides()` et `.valeurs_non_entieres()` (l. 8275-8299) correspondent exactement à l'index, y compris leurs domaines d'emploi (t et i ; i et colonnes de développement).

**#595, contrôles du lecteur de classeur.**
- `.xlsx_controler_balises_relation()` (l. 9833-9850) : recherche sur le texte collé ; racine exceptée seulement si elle est la première occurrence et suivie de `s`.
- Contrôle Type dans `.xlsx_controler_relations()` (l. 9909-9913) : l'attribut absent est admis, le `.tex` ne dit rien de contraire.
- Contrôles a1, a2 et a3 (l. 10103-10131) : la cible d'`openxlsx` (`(?<=Target=").+xml(?=")`, gloutonne, sans décodage) et la cible de la voie de repli (premier attribut de nom local `Target`, décodé) sont décrites exactement.
- Ordre d'appel dans `.xlsx_fichier_feuille()` (l. 10180, 10187, 10203) conforme au texte.

**#580, écrivain xlsx.**
- `.xlsx_chemin_absolu()`, `.xlsx_chemin_sortie()`, `.xlsx_defaut_chemin()`, `.xlsx_defaut_encodage()`, `.xlsx_defaut_texte()` et `engine_ecrire_xlsx()` (l. 8859-9180) sont fidèlement décrits : ordre des défauts, `&quot;`, fichier rendu seulement s'il existe, erreur de classe `usp_refus_ecriture` sur archive absente. Seules exceptions : C1 et C6.

**Motifs cités.** Tous ceux qui sont cités en `\code{}` sont des débuts exacts des chaînes du moteur. Pour #595, le texte nomme les constantes (`TEXTE_REFUS_BALISE_RELATION`, `TEXTE_REFUS_RELATIONS`) sans les citer.

**Statut épistémique.** Il est juste : « mesuré » pour les sondes, « source lue » pour le fonctionnement interne d'`openxlsx`. Aucune référence n'est fabriquée. Les mesures sont rattachées à la version 4.2.5.2 par la règle générale du paragraphe « Contrat de forme ».

### Constats

**C1 (mineur, correction requise ; énoncé inexact sur le code) — index, ligne `engine_ecrire_xlsx()`.**
- Problème : « caractère de contrôle autre que la tabulation, le saut de ligne et le retour chariot » laisse croire que U+007F et U+0080 à U+009F sont refusés. Or le code ne refuse que les codes inférieurs à 32 (`.xlsx_defaut_texte()`, l. 8960), et XML 1.0 admet ces caractères.
- Mesure : `.xlsx_defaut_texte("a\u007fb")` et `.xlsx_defaut_texte("a\u0085b")` rendent `NULL` ; `engine_ecrire_xlsx()` écrit le fichier avec U+007F.
- Correction au mot près : remplacer « (caractère de contrôle autre que la tabulation, le saut de ligne et le retour chariot, U+FFFE, U+FFFF) » par :
  « (caractère de contrôle de U+0000 à U+001F autre que la tabulation, le saut de ligne et le retour chariot, U+FFFE, U+FFFF~; U+007F et U+0080 à U+009F, admis par XML~1.0, sont écrits) ».

**C2 (mineur) — règle « Désignation de la feuille lue », phrase « Ces formes font lire sans message une autre feuille […] ou arrêtent \code{openxlsx} sur une erreur de~R. »**
- Problème : la généralisation ne couvre pas la forme t10, un texte `Target="…"` dans la valeur même de l'attribut de cible. Sur les deux chemins, elle donne « Classeur illisible : aucune feuille trouvee. » : ni autre feuille, ni erreur propre à `openxlsx` (tableau des sondes, remesuré avant correctif).
- Correction : après « ou arrêtent \code{openxlsx} sur une erreur de~R », ajouter :
  « ~; un texte \code{Target="}\ldots\code{"} écrit dans la valeur même de l'attribut de cible ne fait trouver de feuille à aucun des deux chemins (mesuré) ».

**C3 (mineur) — même règle, « placée après une relation ordinaire, elle est passée sans message par \code{openxlsx}, et une relation qui n'est pas celle de la feuille lue […] (mesuré) ».**
- Problème 1 : le cas où la balise fautive est la relation de la feuille lue manque. Mesure faite avec le moteur avant correctif (`9440415`), `openxlsx` 4.2.5.2, classeur de deux feuilles dont la relation de la feuille lue est écrite `<Relationship<TAB>` après une relation ordinaire :
  - `openxlsx` : « Length of worksheet is 0 » ;
  - voie de repli : 104,2.
- Problème 2 : « passée sans message » relève de la lecture du code source, non de la mesure.
- Problème 3 : la boucle « suivie d'une autre balise de cette forme » est désormais mesurée. Avec une relation ordinaire suivie de deux balises à tabulation, `openxlsx` est arrêté par `timeout 20`, code 124.
- Correction 1 : remplacer « placée après une relation ordinaire, elle est passée sans message par \code{openxlsx}, et une relation qui n'est pas celle de la feuille lue, écrite ainsi, est lue juste par les deux chemins et refusée parce que le contrat est fermé (mesuré). » par :
  « placée après une relation ordinaire, elle est passée sans message par \code{openxlsx} (source lue)~: une relation qui n'est pas celle de la feuille lue, écrite ainsi, est lue juste par les deux chemins et refusée parce que le contrat est fermé, et la relation de la feuille lue, écrite ainsi, fait arrêter \code{openxlsx} sur une erreur de~R (mesuré). »
- Correction 2 : remplacer « (source lue, version~4.2.5.2) » par « (source lue et mesuré, version~4.2.5.2) ».

**C4 (mineur) — « arrêté sans réponse au bout de 20~s, et de 90~s pour une tabulation ».**
- Problème : la mesure de 90 s (lot H, `docs/suivi-documentation/I.md` l. 154) porte sur `<Relationship<TAB>Id` **et** `<Relationship<LF>Id`.
- Correction : « et de 90~s pour une tabulation ou une fin de ligne ».

**C5 (mineur ; conservation du fond) — même règle.**
- Problème : la qualification « (XML valide) » de l'ancien texte a disparu. Elle dit au lecteur que le contrat refuse ici une forme bien formée, ce qui borne la portée du refus.
- Correction : remplacer « (tabulation, fin de ligne suivie directement d'un attribut, nom prolongé tel que \code{<RelationshipX}) » par :
  « (tabulation ou fin de ligne suivie directement d'un attribut, formes de XML bien formé, ou nom prolongé tel que \code{<RelationshipX}) ».
- Pourquoi « bien formé » plutôt que « valide » : au sens de XML, « valide » suppose un schéma ; la grammaire `STag` admet tout blanc après le nom de l'élément.

**C6 (mineur) — index, `engine_ecrire_xlsx()` : « […] dont le nom ne finit pas par \code{.xlsx} (casse indifférente), ou qui désigne un dossier existant (\code{.xlsx\_defaut\_chemin()}) ».**
- Problème : le refus du dossier existant n'est pas fait par `.xlsx_defaut_chemin()`. Il est fait par `engine_ecrire_xlsx()`, sur la cible résolue (`dir.exists(cible)`, l. 9083). La ligne d'index des aides le dit d'ailleurs juste.
- Correction : remplacer ce passage par :
  « […] dont le nom ne finit pas par \code{.xlsx} (casse indifférente) (\code{.xlsx\_defaut\_chemin()}), ou dont la cible résolue désigne un dossier existant ».

**C7 (mineur) — index, `.liste_positions()` : énumération « commune aux motifs des lignes et colonnes vides, […] et des lignes déplacées par le rangement par~$t$ ».**
- Problème : la phrase, réécrite par la branche, se lit comme exhaustive. Elle omet les emplois du contrat de forme du classeur : `.xlsx_cinq()` (l. 9762), `TEXTE_REFUS_RELATIONS` (l. 9893), désignation (l. 10050, 10079, 10124). Elle omet aussi le motif nouveau de la balise de relation (l. 9847, #595).
- Correction : après « des lignes déplacées par le rangement par~$t$ », ajouter :
  « , ainsi que des motifs du contrat de forme du classeur (\code{.xlsx\_cinq()}, relations, désignation de la feuille, balises de relation) ».

**C8 (mineur, facultatif) — `sec:controles`, #569 : « rappelle que l'ordre de la colonne~$t$ détermine les p-values et les verdicts ».**
- Problème : le motif dit « notamment ». L'avis de l'étape 1 a laissé la liste ouverte, faute d'inventaire de tout ce qui dépend de l'ordre.
- Correction proposée : « détermine notamment les p-values et les verdicts ».

### Textes des motifs et de l'information tels que livrés

- **#569 et #568** : identiques au mot près aux textes de l'étape 1.
- **#595 (a)** : a1 conforme. a2 est livré sous deux formes, « dans la valeur de l'attribut X » et « ailleurs qu'au debut de l'attribut Target (par exemple …) ». a3 (« cible differente pour un autre lecteur de classeur … ») et Type sont ajoutés à l'étape 3, à valeur fausse mesurée, sous le visa du mainteneur. Chaque texte dit le constat, la cause et l'action, sous le libellé commun « designe la feuille lue de facon ambigue », qui convient aussi à Type puisque Type décide quelle relation est une feuille de calcul.
- **#595 (b)** : le texte livré diffère de celui de l'étape 1, à juste titre :
  - « une fin de ligne suivie directement d'un attribut » remplace « une fin de ligne », car la forme fin de ligne + espace est admise ;
  - le risque devient « selon la place de la balise, la lecture pourrait ignorer cette relation, ou ne jamais se terminer », ce qui est exact au vu de b1 et b4 et de la mesure de C3.
  - Remarque sans suite : pour `<RelationshipX`, « apres le nom de la balise » est approximatif ; ce n'est pas faux sur le code.

## 2. Passages retirés pour #595 (point 2)

Les quatre passages retirés, consignés mot pour mot dans `docs/suivi-documentation/I.md` (entrée `sec:controles`), **étaient devenus faux**. La remesure le confirme : t1, t10 et y1 sont refusés sur les deux chemins au même texte ; b1 et b4 sont refusés ; b7 est admis et lu 104,2 sur les deux chemins.
- (1) « La cible de la relation n'est pas soumise à cette règle » : faux depuis a1 à a3.
- (2) « une seule forme connue donne une valeur fausse sur un classeur admis » : ces formes sont refusées.
- (3) Description des cibles forgées « sur un classeur admis » : idem.
- (4) Description du blocage « limite consignée », avec « sans effet » après une relation ordinaire : la balise est refusée.

Rien de juste n'a été perdu, sauf ce que C3 à C5 rétablissent :
- la lecture de la cible par chaque chemin est reprise dans la règle a3 ;
- la mesure 999 au lieu de 104,2 est reprise ;
- l'hypothèse « aucun tableur n'est supposé écrire ces formes (hypothèse non vérifiée) » est couverte par la règle générale du « Contrat de forme » (l. 5197-5198) ;
- le détail par chemin des formes qui trompaient `openxlsx` ou la voie de repli est versé au suivi, comme `CONVENTIONS.md` l'exige.

## 3. Remesure des affirmations sur `openxlsx` (point 3)

Conditions : `openxlsx` 4.2.5.2 (bibliothèque de session), R 4.3.3, `LC_ALL=C.UTF-8`. La sonde versée `sonde_595.R` est rejouée sans modification, chaque chemin dans un sous-processus limité par `timeout 20`. Moteurs : avant correctif `9440415` (md5 2a241a77…) ; tête de branche (md5 e156d600…).

| Cas | Avant, voie de repli | Avant, `openxlsx` | Après, les deux chemins |
|---|---|---|---|
| t1 (`x:Target="…2"` puis `Target='…1'`) | 999, σ 0,5064392336, ok TRUE | 999, σ 0,5064392336, ok TRUE | refus a1, même texte |
| y1 (`x:Type` chart puis `Type` worksheet) | 999 | 999 | refus Type, même texte |
| b1 (`<Relationship<TAB>`, en première relation) | 104,2 | **code 124 (blocage)** | refus (b), « balise(s) <Relationship> 1 » |
| b4 (balise à tabulation en seconde relation) | 104,2 | 104,2 | refus (b), « balise(s) <Relationship> 2 » |
| t10 (`Target=` dans sa propre valeur) | « aucune feuille trouvee » | idem | refus a2 |
| t11 (`Target='…'` seul, deux feuilles) | 104,2 | « Length of worksheet is 0 » | inchangé : admis, erreur R d'`openxlsx` |
| h1 (`a/workbook.xml`) | 104,2 | « invalid 'description' argument » | inchangé |
| h4 (`xl/xworksheets/sheet1.xml`) | 104,2 | « Expecting a single string value … » | inchangé |
| b7 (`<Relationship<CR><LF> Id`) | — | — | admis, 104,2 sur les deux chemins |

Toutes les valeurs coïncident avec `tableau_final.txt`.

Deux sondes complémentaires, faites avec le moteur avant correctif :
- relation de la feuille lue à tabulation, après une relation ordinaire : erreur R d'`openxlsx` (voir C3) ;
- relation ordinaire suivie de deux balises à tabulation : blocage (voir C3).

Après correctif, la sonde de la feuille lue est refusée au motif (b) sur les deux chemins, comme celle du blocage avec deux balises à tabulation (« balise(s) <Relationship> 1, 2 »).

Les affirmations du `.tex` sur la valeur 999, le blocage, les erreurs R et les entrées homonymes h1 à h4 sont **confirmées par échantillon**.

## 4. Référence W3C (point 4)

- **Citation** : « recommandation du W3C *Extensible Markup Language (XML) 1.0*, cinquième édition, 2008, § 2.2, 2.11 et 3.3.3 ». La cinquième édition est la Recommandation du 26 novembre 2008, et les titres de sections sont ceux de la spécification : 2.11 *End-of-Line Handling*, 3.3.3 *Attribute-Value Normalization*. Ces deux points sont **vérifiés par la recherche** (sommaire et pages qui citent la Recommandation).
- **Contenu, non relu dans cette session** : `www.w3.org` n'est pas joignable depuis la session. D'après le texte de la spécification tel que je le connais (*hypothèse*) :
  - § 2.2, production `Char` : `#x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]` ;
  - § 2.11 : CR LF et tout CR isolé sont traduits en LF avant l'analyse ;
  - § 3.3.3 : chaque blanc (#x20, #xD, #xA, #x9) d'une valeur d'attribut devient #x20, un caractère référencé étant gardé.
- **Usage** : il est juste. § 2.11 fonde le refus du retour chariot en cellule et en en-tête ; § 3.3.3 fonde le refus de la tabulation et du saut de ligne dans le nom de feuille ; § 2.2 fonde l'ensemble exclu. Deux réserves de forme, facultatives :
  - § 2.2 soutient « caractère exclu de XML 1.0 », non la phrase sur l'analyseur à laquelle il est accolé ; il gagnerait à suivre la parenthèse corrigée par C1 ;
  - « relit le retour chariot d'un texte en saut de ligne » est exact pour un CR isolé ; dans une paire CR LF, le CR disparaît. La conclusion « ne se conservent pas » reste vraie.
- **Forme** : la citation en ligne, sans entrée de bibliographie, suit le précédent de l'ISO/IEC 29500-4:2016.
- **Avis** : référence juste et bien employée. La relecture du texte à la source reste à faire le jour où `www.w3.org` sera joignable.

## 5. `\datedoc` (point 5)

**Avis : porter `\datedoc` au `18~novembre 2026` avec la version 4.1.**
- Le préambule fixe la règle : « Date d'établissement du document, figée au jour où la version est établie ». La version 4.1 est établie le 18/11/2026 (`fdef4b9`).
- Les précédents l'appliquent : 3.9 au 16/11 (`17dff9a`) et 3.10 au 17/11 (`a075363`) ont changé la date avec la version ; 4.0 a gardé le 17/11 parce qu'elle était établie le même jour que 3.10 (`c8225c0`).
- La veille du 18/11 (#463) couvre la plupart des mentions ancrées : page de l'AEAPP et traductions, tableau de conformité de 2015 et ligne France, règlement d'exécution 2015/498, art. R. 352-5 et R. 356-19.
- **Condition** : la mention « question 2580 […] consultée à la date d'établissement du présent document » ne figure dans aucun relevé daté de #463. Il faut la relire avant de déplacer la date : statut « Final », réponse au point 1 inchangée. Il en va de même des rectificatifs de 2026/269.

## 6. Double décompression (point 6)

**Le document n'en a pas besoin.**
- Aucun résultat, aucun refus ni aucune valeur lue n'en dépend. La durée mesurée (`c8e3512`) est de l'ordre de la milliseconde.
- Le seul point de fond est que les parties lues par `openxlsx` sont celles que l'admission a contrôlées. C'est vérifié : `openxlsx:::read.xlsx.default` appelle `unzip(xlsxFile, exdir = xmlDir)`, résolu dans l'espace de noms d'`openxlsx` 4.2.5.2 en `utils::unzip` ; `.xlsx_admettre()` appelle `utils::unzip(chemin, exdir = d)` ; le même extracteur sur le même fichier donne le même contenu.
- Phrase facultative possible, au paragraphe « Contrat de forme du classeur » : « \code{openxlsx} décompresse de nouveau le classeur, par la même fonction \code{utils::unzip()} que le contrôle d'admission~: les parties qu'il lit sont celles que le contrat a contrôlées (source lue, version~4.2.5.2). »

## Résumé des deux avis antérieurs de S4 (rendus en compte rendu seulement)

Les deux avis sont **reconstitués** à partir des messages de commit et des commentaires du code ; le texte des avis n'a pas été versé.

- **Relecture des textes de #595, règle (b)** (message de `5752c81` ; commentaire de `.xlsx_controler_balises_relation()`).
  - À l'étape 1, la recommandation était de tester le texte brut **et** le texte collé.
  - La relecture a limité la règle (b) au **seul texte collé**, celui que lit `openxlsx` après `readLines()` puis `paste(collapse = "")`. Ce texte attrape aussi les balises que le collage forme (`<Relation<LF>ship<TAB>`).
  - Sur le texte brut, la forme « un attribut par ligne » (`<Relationship<LF> Id=`, bien formée et lue juste par les deux chemins, témoins b12 et b13) aurait été refusée à tort.
  - Une fin de ligne suivie directement d'un attribut reste refusée, parce que le collage la rend `<RelationshipId`.
- **Règle de l'étape B de #568** (message de `8d2fe56`).
  - En configuration 1, le flux continue et le motif dédié ne remplace que celui de `.motifs_colonne_i()` quand celle-ci en émet un. Restent donc lus : une colonne I d'années suivie de II…IX ; i…ix ; « i, II, … » et « I, ii, … » ; les lignes vides de fin.
  - La casse est uniforme sur toute la suite.
  - Résidu admis : une colonne I de montants entiers consécutifs est refusée en aval au motif générique.
  - L'audit l'a vérifiée sur 20 000 en-têtes aléatoires (0 passage d'accepté à refusé) ; la remesure de l'étape 8 confirme la règle (§ 1).

## Retour

- **Statut** : `partiel` (tout est établi, sauf la relecture à la source du texte des § 2.2, 2.11 et 3.3.3 de XML 1.0).
- **Résultat** : visa avec réserves ; C1 à C7 au mot près, C8 facultatif ; citation W3C juste ; date portée au 18/11 sous condition ; mention de la double décompression non nécessaire.
- **Critères déclenchés** : aucun.
- **Constat hors périmètre** : la question 2580 de l'AEAPP est dite « consultée à la date d'établissement » sans figurer dans aucun relevé daté de #463. Critère ADR 0018 : aucun. Mineur, à écarter, avec la recommandation de l'ajouter à la liste de veille.
