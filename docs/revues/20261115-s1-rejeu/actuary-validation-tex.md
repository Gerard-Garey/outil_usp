# Validation du diff du `.tex` de la branche S1 `claude/lecteurs-contrat-ferme` (actuary, 16/11/2026)

> *Rédigé par l'agent actuary (IA).* Rapport à verser intégralement dans `docs/revues/20261115-s1-rejeu/actuary-validation-tex.md`.

## Verdict

**Validé avec réserves.** Deux constats majeurs, tous deux d'ordre documentaire, sont à corriger par un commit `docs:` avant le commit du PDF, puis à revoir sur leur diff (règle 10) :

- M1 : l'hypothèse « aucun tableur n'écrit les formes refusées » est contredite par le document lui-même.
- M2 : la liste des écarts entre les deux chemins omet un écart mesuré, où un même classeur est accepté par un chemin et refusé par l'autre.

Ces corrections ne refusent aucune forme de plus et ne changent ni σ_USP ni verdict. Elles entrent donc dans la délégation D-S1-17 / D-S1-20. Les autres règles décrites en `sec:controles` sont exactes au regard de `R/engine.R`. Onze mineurs sont listés plus bas.

**Périmètre relu.** Les 543 lignes de diff de `git diff origin/main...HEAD -- docs/latex/doc_tests_usp.tex`, soit les cinq commits be613ff, 04b4428, 3033687, 2cfc21c et 17dff9a.

Attention : la référence locale `main` de ce clone est périmée (8205955 au lieu de 0d4af02 pour `origin/main`). La commande du brief, `git diff main...HEAD`, rend donc 709 lignes, dont des commits de branches déjà fusionnées (voir les constats hors périmètre, H3).

## Constats bloquants

Aucun.

## Constats majeurs

### M1. L'hypothèse « Aucun tableur n'est supposé écrire les formes refusées (hypothèse non vérifiée) » est contredite par le document (l. 4719-4720)

Le texte suivant contredit cette affirmation générale :

- **Cellules en erreur de calcul (`t="e"`).** Le contrat les refuse « où qu'elle[s] soi[en]t ». Le même document mesure qu'`openxlsx::write.xlsx()` en écrit (l. 4808-4812).
  - Excel écrit `t="e"` pour une formule en erreur. Mon avis amont classait cette forme dans le groupe C (formes qu'un outil réel écrit, refus à tort possible), et D-S1-2 / D-S1-13 l'ont refusée en connaissance de cause.
  - Mesure du 16/11 (`m1.R`) : un classeur dont E9 vaut `<c r="E9" t="e"><f>1/0</f><v>#DIV/0!</v></c>`, hors du tableau, est refusé sur les deux chemins (« Cellule(s) en erreur de calcul dans la feuille lue (E9 : #DIV/0!) »).
- **Texte « t= » après la dernière cellule.** Un tel texte en en-tête ou pied de page est refusé (l. 4778-4779). C'est un texte saisi par l'utilisateur dans un tableur (D-S1-10 a).
- **Étendue.** Le cas limite de l'étendue (une valeur isolée qui porte le tableau au-delà de 10^6 cellules) relève aussi du groupe C de l'avis amont.

Le lecteur du dossier est donc induit à croire que seuls des fichiers forgés sont refusés.

**Correction proposée.** Remplacer la phrase par :

> « Il refuse aussi des formes qu'un outil d'écriture de classeur produit : une cellule en erreur de calcul (\code{t="e"}), qu'\code{openxlsx::write.xlsx()} écrit pour une valeur manquante ou infinie (mesuré) et qu'un tableur écrit pour une formule en erreur (non vérifié sur un classeur de tableur) ; un texte qui porte «~\code{ t=}~» après la dernière cellule (en-tête ou pied de page) ; une feuille dont les cellules à valeur s'étendent sur plus de $10^6$ cellules. Hors de ces cas, aucun tableur n'est supposé écrire les formes refusées (hypothèse non vérifiée). »

### M2. La liste des « Écarts qui subsistent entre les deux chemins » est incomplète (l. 4901-4916)

Le paragraphe dit que, « sur un classeur admis, les deux chemins peuvent encore différer, sans valeur fausse connue », puis énumère les écarts. Il en omet deux, mesurés le 16/11 sous `LC_ALL=C.UTF-8`, voie de repli puis `openxlsx` 4.2.5.2.

**(a) Attribut sur la balise `<t>` d'une chaîne en ligne (`<is><t xml:space="preserve">…</t></is>`).** La structure du bloc des données admet cette forme (`is t` permis, attribut admis par `XML_GRAMMAIRE_OUVRANTE`).

- En B2, la valeur 104.2 est lue juste par la voie de repli, et le classeur est accepté. `openxlsx` rend la cellule non numérique, et le classeur est refusé en aval (« colonne xt : ligne(s) de donnees 1 »).
- Pour l'en-tête `xt`, la voie de repli lit `xt`. Sous `openxlsx`, le classeur est refusé : « Colonne(s) manquante(s) : xt … Colonnes presentes : t, xml:space="preserve">xt, yt ».
- Le même fichier est donc accepté par un chemin et refusé par l'autre. Mon avis amont (§ 1, « Parité ») demandait de consigner cette divergence. Elle n'apparaît nulle part dans le `.tex`, ni avant ni après la branche (`grep xml:space` vide).

**(b) Cible de feuille `./worksheets/sheet1.xml`.** La voie de repli la lit (`ok = TRUE`). `openxlsx` 4.2.5.2 s'arrête sur l'erreur R « Length of worksheet is 0 ».

**Correction proposée.** Ajouter, après la phrase des cellules `t="str"` :

> « Une chaîne en ligne dont la balise \code{<t>} porte un attribut (\code{<t xml:space="preserve">}) est lue juste par la voie de repli, alors qu'\code{openxlsx} garde l'attribut dans le texte lu : la valeur est refusée en aval comme cellule non numérique, et l'en-tête ainsi écrit n'est pas reconnu ; un même classeur est donc accepté par la voie de repli et refusé par \code{openxlsx}, sans valeur fausse (mesuré, \code{openxlsx}~4.2.5.2). »

Ajouter aussi la cible `./worksheets/` à la phrase des balises `<sheet>` préfixées (« … ainsi qu'une cible de feuille écrite \code{./worksheets/…} ; \code{openxlsx} ne lit pas ces classeurs… »), en précisant que la cible `./` a été mesurée sous 4.2.5.2.

## Constats mineurs

| n° | Ligne | Constat | Correction proposée |
|---|---|---|---|
| m1 | 4774-4775 | « ni d'autres suites `<v`, `</v>`, `<is><t` ou `</t></is>` que celles de la cellule » : pour une cellule sans `<v>` (ou sans `<is>`), le code (`f_v`, `f_i` de `.xlsx_controler_structure()`) ne cherche que `</v>` (ou `</t></is>`). | « ni, pour une cellule sans valeur, de suite `</v>` (sans chaîne en ligne, de suite `</t></is>`), ni, pour une cellule qui en porte, d'autres premières suites `<v`, `</v>`, `<is><t`, `</t></is>` que les siennes » |
| m2 | 4827 | La référence `&#X30;` (x majuscule), lue de la même façon par les deux chemins, est aussi refusée (`[xX]` dans `.xlsx_controler_references()` ; mesuré le 16/11, refus sur les deux chemins). Le texte ne cite que `&#NNN;` et `&#xHH;`. | ajouter « (x écrit en minuscule ou en majuscule ; la forme en majuscule, décodée par aucun des deux chemins, est refusée de même) » |
| m3 | 4837-4839 | « Restent admises … U+0085, U+00A0, U+2007, U+200B et U+202F » ne vaut que si ces caractères ne sont pas des blancs de `[[:space:]]` dans la locale de la session : `.xml_codes_retires_entete()` lit cette locale, et le commentaire du code dit « sous C.UTF-8 ». | ajouter « (sous la locale \code{C.UTF-8} ; un caractère que la locale de la session tient pour un blanc est refusé) » |
| m4 | 4883-4886 | Pour `openxlsx` 4.2.5.2, le rejeu a observé soit l'arrêt du processus (code 139), soit l'erreur R « Value of SET_STRING_ELT() must be a 'CHARSXP' not a 'raw' », selon l'état de la mémoire (`rejeu.md`, l. 47 ; `575-repetitions.txt`). Le texte ne dit que l'arrêt. | « arrêterait sinon le processus R par une violation d'accès mémoire ou, selon l'état de la mémoire, lèverait une erreur de R (version 4.2.5.2) » |
| m5 | 4796 | « A99999999999 mène openxlsx à une erreur de R » n'est vrai que pour une cellule qui porte une valeur. Mesuré le 16/11 sous 4.2.5.2 : `<c r="A99999999999"/>` est lu avec un simple avertissement, `<c r="A99999999999"><v>1</v></c>` mène à « missing value where TRUE/FALSE needed ». | « A99999999999 portant une valeur » |
| m6 | 1055-1056 | Le refus en aval d'une colonne logique est mesuré sous `openxlsx` 4.2.5.2 (`579-apres.txt`). La parenthèse « (mesuré, openxlsx 4.2.9) » qui précède porte sur la relecture, non sur ce refus. | ajouter « (mesuré, \code{openxlsx}~4.2.5.2) » après « sur les deux chemins » |
| m7 | 848-849 | « et sous toute plateforme par construction de la table » est un raisonnement, non une mesure ; le rejeu Windows de l'étape 10 doit le confirmer (D-S1-29). | « … par construction de la table (raisonnement, non mesuré sous Windows) » |
| m8 | 4857-4860 | La règle « `<sst>` ne contient que `<si>` et `<extLst>` » (`permis` de `.xlsx_controler_partagees()`) n'est pas énoncée. | « sous une racine `<sst>` unique, qui ne contient que des `<si>` et des `<extLst>` » |
| m9 | 4915-4916 | « Le contrat ne couvre que les formes qu'il énumère » se lit mal à côté de « liste fermée » : le contrat refuse tout ce qu'il n'énumère pas. | « Le contrat juge la forme du classeur, non les valeurs qu'il porte » |
| m10 | 4721-4722 | « un texte cité étant tronqué à 20 caractères » : le nom de partie cité par les refus d'encodage et de balisage n'est pas tronqué (exception voulue, commentaire de `.xlsx_texte()`). | « un texte issu d'une cellule ou d'une chaîne étant tronqué… » |
| m11 | 4864 | Citation de la norme incomplète (point soumis n° 1). | voir l'avis ci-dessous |

## Ce qui a été vérifié et trouvé exact

Chaque règle décrite en `sec:controles` a été confrontée à `.xlsx_admettre()` (l. 10140-10289) et aux fonctions qu'elle appelle :

- **Ordre des règles.** Archive, encodage, balisage, bloc des données et segment, référence et attributs, limites, unicité, ordre, type, contenu, références numériques des chaînes en ligne, table (trois refus de forme, structure, puis références de ses chaînes), indice, étendue, ligne 1. C'est l'ordre du code. « Seul le premier refus rencontré est restitué » est exact.
- **Encodage.** Quatre parties lues en octets, UTF-8 valide sans octet nul, position du premier octet fautif. Les autres parties ne sont pas contrôlées (limite consignée).
- **Balisage.** Seule la déclaration XML conforme à sa grammaire est admise.
- **Bloc des données.** Exact sur `<sheetData>` unique, les enfants permis, `<is>` sans attribut avec un seul `<t>`, le texte limité à des blancs et l'`<extLst>` non lu.
- **Attributs.** Liste fermée `r`, `s`, `t`, `cm`, `vm`, `ph`, valeurs contrôlées.
- **Limites, unicité, ordre.** Limites XFD et 1 048 576 ; ordre de lecture strict, cellules sans valeur comprises.
- **Types.** Types admis `n`, `s`, `str`, `inlineStr`, `b`.
- **Contenus.** Exact, y compris `<v/>` lu comme absence de `<v>`.
- **Table des chaînes partagées.** Exact sur Q-F, P2, X1, la structure, les trois formes du schéma et la règle conditionnelle du second `<rPh>` (D-S1-15).
- **Indice de chaîne.** Comparé en double, zéro chaîne sans table.
- **Étendue.** Produit dernière ligne × dernière colonne des cellules à valeur, 10^6 au plus.
- **Classe des erreurs.** Erreurs de classe `usp_refus_lecture`, sauf trois erreurs ordinaires : chemin qui sort du dossier de lecture, archive illisible, feuille introuvable.
- **`XML_ENFANTS_RPR`.** Revue sur la copie locale de `sml.xsd` (provenance non authentifiée, voir H4) : `CT_RPrElt` y est un `xsd:choice maxOccurs="unbounded"` de 15 éléments, identiques à `XML_ENFANTS_RPR`.

**Mesures refaites le 16/11.** R 4.3.3, `LC_ALL=C.UTF-8`, voie de repli puis `openxlsx` 4.2.5.2 ; classeurs forgés par `sondes/forge.R`. Elles confirment les lectures d'`openxlsx` citées au texte :

- `<c` suivi d'une tabulation : valeur NA ;
- `r="b2"` : « missing value where TRUE/FALSE needed » ;
- `x:r="Z9"` : 26 colonnes ;
- `t="x"` lu 5 ; `t="d"` lu 2020 ; `0x10` lu 16 ; `104,2` lu 104 ;
- `<is>` indentée lue comme un morceau de balise ;
- commentaire dans `<t>` lu 11 ; `<si/>` suivie de `9` : chaîne 0 lue 9 ;
- indice 3·10^9 refusé ;
- en-tête `xt&#160;` : même colonne manquante sur les deux chemins, textes différents.

Six références admises (U+0085, U+00A0, U+202F, U+200B, `&#1;`, U+2007), en tête ou en fin d'une valeur, sont refusées en aval sur les deux chemins : la parité est tenue sur les valeurs.

**Colonnes non numériques.** Mesuré sous `C.UTF-8` et `C` : `.en_numerique()` rend NA pour un vecteur logique, `Date`, `difftime`, complexe, brut ou liste, et convertit un facteur par ses valeurs. Une colonne `xt` en `Date` est refusée avec ses positions. `.motifs_colonne_i()` passe par `.en_numerique()`. `579-apres.txt` montre les mêmes positions et le même motif sur les deux chemins. La mention « mesuré, openxlsx 4.2.5.2 » est exacte.

**En-têtes « bytes ».** Refus d'une colonne 4 non lue (mesuré). L'ordre BOM, puis refus « bytes », puis `.declarer_latin1()`, puis ligne 1 est conforme au code des deux lecteurs. La marque est gardée par `.nom_sans_bom()`, et un reste ASCII n'est pas marqué (D-S1-19, D-S1-26).

**Table Windows-1252.** `.vers_utf8()` diffère d'`enc2utf8()` exactement pour 0x81, 0x8D, 0x8F, 0x90, 0x9D, sous `C` comme sous `C.UTF-8` (mesuré). Les citations sont les suivantes :

| Chaîne | Sous `C.UTF-8` | Sous `C` |
|---|---|---|
| Latin-1 déclarée | `a\u0081b` | `a\u0081b` |
| non déclarée | `a\x81b` | `a<81>b` |

Le second cas est la limite consignée par D-S1-29. Dans `mw_valider_triangle()`, un nom Latin-1 0x81 et le même texte en UTF-8 sont en double ; un nom Latin-1 0x81 et le nom ASCII « a<81>b » ne le sont pas (mesuré sous les deux locales ; D-S1-30).

**Contrôles de forme.** `concordance_doc_moteur.R --strict` : 0 écart. `controle_doc_nd.R` : 0 occurrence, 0 violation. Le texte ajouté ne porte ni numéro d'issue, ni décision, ni R0-R12, ni date de 2026 hors `\datedoc` (exception E10).

**Choix de désigner les règles par leur objet.** Il est justifié : le document emploie déjà R1-R15 en partie II. La correspondance avec R0-R12 est dans `docs/suivi-documentation/I.md`.

## Avis sur les deux points soumis par docwriter

### (1) ISO/IEC 29500-4:2016 sans entrée en `sec:biblio`

**Une entrée n'est pas exigée.** `CONVENTIONS.md` (§ 2, « Références ») place en `sec:biblio` les références sur la qualité d'approximation à T = 8 et sur le bootstrap. La section porte aussi une sous-section des textes réglementaires. Une norme technique qui fonde une constante du code ne relève ni de l'une ni de l'autre, et l'introduction de `sec:biblio` en borne la portée.

Il faut en revanche que la citation en ligne soit complète et localisable : « ISO/IEC 29500-4:2016, *Information technology — Document description and processing languages — Office Open XML File Formats — Part 4: Transitional Migration Features*, schéma `sml.xsd`, type `CT_RPrElt` ».

- Titre vérifié sur les notices de la norme ([IEC Webstore](https://webstore.iec.ch/publication/26138), [technickenormy.cz](https://www.technickenormy.cz/en/iso-iec-29500-4-2016-information-technology-document-description-and-processing-languages-office-open-xml-file-formats-part-4-transitional-migration-features)).
- La mention « version transitionnelle » est redondante avec « Part 4 » mais exacte ; elle peut rester.

Si le mainteneur veut une entrée bibliographique, une sous-section « Normes techniques » de `sec:biblio` serait le lieu le moins intrusif : c'est une sous-section, non une partie, et le plan fixe n'est pas touché. Cela reste un choix de forme, à lui de trancher.

### (2) `\datedoc` passé au 16/11 sans revérification des cinq ancrages

Les cinq ancrages et leur exposition à un changement :

| Ligne | Objet | Exposition |
|---|---|---|
| 9629-9633, 20421-20422 | État de la page de l'AEAPP pour EIOPA-BoS-25/249 (traductions non datées, date d'application non établie) et absence de déclaration de conformité de l'ACPR | **La plus élevée** : la parution d'une date de publication des traductions rend la phrase fausse et peut rendre les orientations de 2025 applicables |
| 20415 | Même page, « consultée à la date d'établissement » | Liée à la précédente |
| 20383 | Règlement d'exécution (UE) 2015/498, ni version consolidée ni acte modificatif | Faible |
| 20429 | Code des assurances, versions en vigueur des art. R. 352-5 et R. 356-19 | Faible |

Sur deux jours, une modification est peu probable (*hypothèse*). Mais la formule « à la date d'établissement » affirme une vérification à cette date, et aucune vérification n'a été faite le 16/11 : c'est un défaut de traçabilité, non un risque de fond.

**Qui revérifie.** La règle est déjà décidée (Q-53-6 (a), feuille de route, l. 3862 et 6046) :

- La **session principale** pose `\datedoc` à la date du commit du PDF. Si ce commit a lieu après le 16/11, `\datedoc` doit encore changer.
- Le **même jour**, elle relit la page de l'AEAPP (#463) et l'état de #504 sur EUR-Lex, avec un commentaire daté sur chaque issue.
- Si une date d'application des orientations EIOPA-BoS-25/249 est parue, retour à **`regulatory`** avant le PDF.

Les deux autres ancrages (2015/498 et Code des assurances, l. 20383 et 20429) ne sont pas couverts par cette veille. Je recommande d'y ajouter la même relecture datée : requête CELLAR / EUR-Lex pour 2015/498, Légifrance pour les deux articles. Elle revient à `regulatory` ou à la session ; c'est au mainteneur de trancher. À défaut, il faut décider explicitement que ces deux mentions restent ancrées sans revérification.

## Constats hors périmètre (ADR 0018)

| n° | Emplacement | Gravité | Critère | Preuve |
|---|---|---|---|---|
| H1 | `R/engine.R`, `.xlsx_controler_structure()` (l. 9254-9258, `is t` admis avec attributs) | majeur | **E1** (σ_USP rendu par la voie de repli, classeur refusé par `openxlsx` sur un même fichier) | Mesure `m1.R` du 16/11 : `<is><t xml:space="preserve">104.2</t></is>` en B2, `ok` sur la voie de repli, refus en aval sous 4.2.5.2 ; même divergence sur l'en-tête. Côté code, deux voies : refus par la structure du bloc (refus nouveau, hors des bornes de D-S1-17, décision du mainteneur), ou limite consignée (M2). L'exposition réelle (quel écrivain met `xml:space` sur une chaîne en ligne de nombre ou d'en-tête) est *non vérifiée* et relève du corpus de l'étape 10. |
| H2 | `.xlsx_fichier_feuille()` (cible `./worksheets/`) | mineur | **E1** (même nature, erreur R côté `openxlsx`, message fixe de l'application) | Mesure `m6.R` : voie de repli `ok = TRUE`, `xt1 = 104.2` ; `openxlsx` 4.2.5.2 « Length of worksheet is 0 ». Limite connue du commentaire du code ; documentaire en M2. |
| H3 | Clone de la session : référence locale `main` à 8205955, `origin/main` à 0d4af02 | mineur | aucun | `git rev-parse main origin/main`. La commande du brief rend 709 lignes, dont des commits de KR et JF ; toute revue par diff (règle 10, contrôle Q-45-12) doit employer `origin/main` ou mettre à jour `main` d'abord. |
| H4 | `R/engine.R` l. 9616-9622 (commentaire de `XML_ENFANTS_RPR`) et `.tex` l. 4864 | mineur | aucun | La liste a été vérifiée sur une copie locale de `sml.xsd` dont la provenance n'est pas authentifiée (avis du lot D). Le contenu est conforme à ce qu'on sait de la norme, mais une relecture sur une copie officielle (ISO, ou ECMA-376 Part 4) n'a pas été faite. |
| H5 | `docs/suivi-documentation/I.md`, rubrique `sec:controles` | mineur | aucun | Les mesures propres à `docwriter` sont dites « sans script versionné ». La plupart sont couvertes par les sondes versionnées des lots A à E. Celles qui ne le sont pas (cible `./`, `<sheet>` préfixée, `[Content_Types].xml`) gagneraient à entrer dans `sondes/`. |

## Retour

- **Statut** : `complet`. Chaque règle de `sec:controles` a reçu un verdict, appuyé sur le code et sur une mesure. Les deux points soumis ont un avis.
- **Résultat** : validé avec réserves ; M1 et M2 sont à corriger par un commit `docs:` avant le PDF, revu sur son diff ; onze mineurs.
- **Preuves** :
  - *Vérifié* :
    - lecture de `.xlsx_admettre()` et de ses quinze fonctions de contrôle, de `.vers_utf8()`, `.echapper_texte()`, `.en_numerique()`, `.motifs_colonne_i()`, des têtes d'`engine_lire_donnees_csv()` et `engine_lire_triangle()` ;
    - mesures des scripts `m1.R` à `m6.R` sous `C.UTF-8` (et `C` pour `m2.R` et `m3.R`), voie de repli et `openxlsx` 4.2.5.2 ;
    - sorties versionnées `575-repetitions.txt`, `579-apres.txt`, `588-apres.txt` ;
    - `concordance_doc_moteur.R --strict` et `controle_doc_nd.R` : 0 écart ;
    - `CT_RPrElt` dans la copie locale de `sml.xsd` ;
    - titre de la norme (notices IEC et technickenormy.cz).
  - *Hypothèses* :
    - un tableur écrit `t="e"` pour une formule en erreur (non mesuré sur un classeur de tableur) ;
    - risque faible d'un changement des ancrages datés en deux jours.
  - *Non vérifié* :
    - comportement sous Windows (table fixe « par construction ») ;
    - copie officielle de la norme ;
    - page de l'AEAPP, EUR-Lex et Légifrance au 16/11 ;
    - « Chaque règle est vérifiée sur les deux chemins » n'a été recontrôlé que par échantillon (sept règles), le reste sur les sorties des lots.
- **Informations manquantes** : copie authentifiée d'ISO/IEC 29500-4:2016 ; état au 16/11 des sources ancrées à `\datedoc`.
- **Décisions non résolues** :
  - H1, refus de `<t>` à attribut dans une chaîne en ligne ou limite consignée : le mainteneur (refus nouveau, hors D-S1-17) ;
  - extension de la veille Q-53-6 à 2015/498 et au Code des assurances : le mainteneur ;
  - entrée de la norme en `sec:biblio` : facultative, au choix du mainteneur.
- **Critères déclenchés** (`routage.md`, § 4) :
  - changement de résultat potentiel si H1 est traité par un refus (classeur aujourd'hui accepté par la voie de repli) ;
  - question qu'aucune source ne tranche : ce qu'écrivent réellement les tableurs (corpus de l'étape 10) ;
  - aucun désaccord avec `audit`, un ADR ou les décisions D-S1-1 à D-S1-30.
- **Constats hors périmètre** : H1 à H5 ci-dessus, critères donnés, rien n'est filtré.
- **Prochaine action recommandée** :
  1. `docwriter` corrige M1, M2 et, à son choix, les mineurs, dans un commit `docs:` ; revue de ce diff par `actuary`.
  2. La session applique Q-53-6 (a) le jour du PDF (`\datedoc` à la date du commit du PDF, relecture datée de #463 et #504, et des deux autres ancrages si le mainteneur l'étend), puis commit du PDF.
  3. H1 est soumis au mainteneur.

**Fichiers utiles** :
- Texte relu : `/home/user/outil_usp/docs/latex/doc_tests_usp.tex`
- Code : `/home/user/outil_usp/R/engine.R`
- Suivi : `/home/user/outil_usp/docs/suivi-documentation/I.md`
- Décisions : `/home/user/outil_usp/docs/revues/20261115-s1-rejeu/decisions-mainteneur.md`
- Scripts de mesure (scratchpad, non versionnés) : `/tmp/claude-0/-home-user-outil-usp/72e7dbb2-03bc-5232-8636-a08b44746855/scratchpad/valtex/m1.R` à `/tmp/claude-0/-home-user-outil-usp/72e7dbb2-03bc-5232-8636-a08b44746855/scratchpad/valtex/m6.R`
- Diff relu : `/tmp/claude-0/-home-user-outil-usp/72e7dbb2-03bc-5232-8636-a08b44746855/scratchpad/valtex/diff_tex.txt`

Sources :
- [ISO/IEC 29500-4:2016, IEC Webstore](https://webstore.iec.ch/publication/26138)
- [ISO/IEC 29500-4:2016, technickenormy.cz](https://www.technickenormy.cz/en/iso-iec-29500-4-2016-information-technology-document-description-and-processing-languages-office-open-xml-file-formats-part-4-transitional-migration-features)
