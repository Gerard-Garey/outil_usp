# Revue de la reprise du `.tex` après la validation « avec réserves » (actuary, 16/11/2026)

> *Rédigé par l'agent actuary (IA).* Rapport versé intégralement par la session principale. Décision du mainteneur sur R-A : D-S1-34 (`decisions-mainteneur.md`).

## Verdict

**Visa avec réserves.**

La reprise `4988c7b` traite fidèlement M1, M2 (a), M2 (b) et les onze mineurs m1 à m11. Chaque formulation a été confrontée à `R/engine.R` (état de `d71d4b0`) et aux sorties versionnées. Les statuts épistémiques sont exacts et le `.tex` ne contient aucune vie du dépôt.

Il reste une réserve majeure (R-A). Elle vient de la question de fond posée par `docwriter`, que j'ai mesurée :

- deux écrivains Python très répandus écrivent `<is><t xml:space="preserve">` ;
- depuis le lot F (D-S1-31), le moteur refuse donc tout classeur qu'ils produisent dès qu'**une seule cellule de texte, même dans une colonne non lue,** commence ou finit par un blanc ;
- la liste M1 des « formes qu'un outil d'écriture de classeur produit » est incomplète ;
- D-S1-31 a été prise sans cette information : mon rapport précédent disait l'exposition « non vérifiée ».

Le libellé final de la correction dépend donc d'une décision du mainteneur. Elle doit précéder le commit du PDF.

Référence de comparaison : `origin/main` = `0d4af02`.

## Constats bloquants

Aucun.

## Constats majeurs

### R-A. Liste M1 incomplète : `<t xml:space="preserve">` est écrit par openpyxl et par XlsxWriter, et désormais refusé (l. 4720-4728 ; l. 4776-4787)

**Mesuré le 16/11** (scratchpad, voir les fichiers en fin de rapport ; Python 3.13, openpyxl 3.1.5 avec lxml, XlsxWriter 3.2.9, pandas 3.0.5 ; moteur chargé par `charger_moteur()`, `LC_ALL=C.UTF-8`, voie de repli seule car `openxlsx` n'est pas installé dans cette session) :

| Écrivain | Écriture produite pour un texte à blanc de tête ou de queue | Moteur `d71d4b0` | Moteur `3f4720e` (avant le lot F) |
|---|---|---|---|
| openpyxl 3.1.5, `Workbook.save()` : **toute** chaîne en ligne (`t="inlineStr"`), sans table partagée | `<c r="D2" t="inlineStr"><is><t xml:space="preserve">commentaire </t></is></c>` | refus R3 « balise <t>, dans la chaine en ligne de la cellule D2 » | lu, `engine_lire_donnees_csv` ok = TRUE |
| openpyxl 3.1.5, en-tête saisi `"xt "` | `<is><t xml:space="preserve">xt </t></is>` en B1 | refus R3 (B1) | lu, noms `t xt yt`, ok = TRUE |
| pandas 3.0.5, `to_excel(engine="openpyxl")` | même forme en D2 | refus R3 (D2) | lu, ok = TRUE |
| XlsxWriter 3.2.9, `constant_memory=True` | même forme en D2 | refus R3 (D2) | lu, ok = TRUE |
| XlsxWriter 3.2.9, mode par défaut | table partagée `<si><t xml:space="preserve">commentaire </t></si>` | lu, ok = TRUE | lu, ok = TRUE |

**Code source lu** (vérifié, et non inféré) :

- `openpyxl/cell/_writer.py`, `_set_attributes()` : `attrs['t'] = "inlineStr"` pour toute chaîne.
- `lxml_write_cell()` ajoute `xml:space="preserve"` si `value != value.strip()`. Le chemin `etree_write_cell()` ajoute l'attribut par `whitespace()`, sauf pour un texte fait de seuls blancs.
- `xlsxwriter/xmlwriter.py`, `_xml_inline_string()`, appelé par `worksheet.py` (l. ~6800) en `constant_memory` seulement, avec `preserve = _preserve_whitespace(string)`.
- `pandas/io/excel/_util.py`, `get_default_engine()` : XlsxWriter s'il est installé, sinon openpyxl.

**Portée.**

- La règle de structure porte sur tout `<sheetData>`. Une seule cellule de commentaire, hors des colonnes lues, terminée par une espace (saisie banale), fait refuser un classeur que la voie de repli lisait juste avant le lot F (mesuré).
- Pour `openxlsx`, je n'ai pas mesuré le cas de la colonne non lue (paquet absent ici). Par le mécanisme mesuré au lot F (texte lu `xml:space="preserve">…`), la colonne `note` serait lue faussement sans être employée, et le classeur accepté : c'est une *hypothèse*, à confirmer sous 4.2.5.2.
- Le refus porte donc aussi sur une forme que les deux chemins lisaient juste pour les données employées.
- Il n'y a aucune valeur fausse, et un contournement existe : le motif invite à réenregistrer depuis un tableur.
- C'est toutefois un refus d'un classeur produit par un outil courant, alors que le texte laisse croire que seuls `t="e"`, le « t= » de pied de page et l'étendue relèvent de ce cas.

**Ce que la littérature et les sources ne tranchent pas** (non vérifié, corpus de l'étape 10) :

- si Excel ou LibreOffice écrivent jamais des chaînes en ligne ; à ma connaissance ils écrivent une table partagée, mais je ne l'ai pas vérifié ;
- writexl (libxlsxwriter), openxlsx2, rust_xlsxwriter, et les exports de logiciels métiers.

**Correction à décider par le mainteneur** (critère « changement de résultat » et décision antérieure prise sans l'information) :

- **(a) Maintenir D-S1-31.** Le `.tex` ajoute à l'énumération de la l. 4720 :
  > « une chaîne en ligne dont le texte commence ou finit par un blanc, qu'openpyxl (qui écrit tout texte en chaîne en ligne) et XlsxWriter en mode \code{constant\_memory} écrivent \code{<t xml:space="preserve">}, y compris dans une colonne que l'outil ne lit pas (mesuré, openpyxl~3.1.5 et XlsxWriter~3.2.9) »

  La phrase « Hors de ces cas, aucun tableur… » reste inchangée.
- **(b) Borner le refus.** Le refus de `<t>` à attribut est limité aux cellules dont le texte est lu : ligne d'en-têtes, et colonnes `t`, `xt`, `yt` ou cellules du triangle. Pour une colonne non lue, la lecture fausse d'`openxlsx` est sans effet sur σ_USP. Il faut une nouvelle passe `coder-approfondi` → `audit`, et une mesure sous `openxlsx` pour confirmer que la colonne non lue n'altère rien.
- **(c) Admettre exactement `<t xml:space="preserve">`** et retirer l'attribut avant `openxlsx`. Cette voie est exclue en l'état : le moteur ne réécrit pas le classeur passé à `openxlsx`, et elle changerait l'architecture du lecteur.

Mon avis : (a) au minimum, immédiatement, car c'est la seule voie compatible avec le PDF de la branche. (b) mérite une issue : le refus d'un export openpyxl ou pandas pour une espace de queue dans un commentaire est un coût d'usage réel, sans gain de sûreté sur les valeurs employées. La décision revient au mainteneur.

## Constats mineurs

| n° | Ligne | Constat | Correction proposée |
|---|---|---|---|
| r1 | 4781-4785 | « d'un `<t>` à attribut ou à blanc, openxlsx garde dans le texte lu ce qui suit « <t » et un caractère » vaut pour un `<t>` ouvrant suivi d'un texte. `<t xml:space="preserve"/>`, vide, est lu vide ou NA de même par les deux chemins, et il est pourtant refusé (`t_is`, branche `g != "o"` ; `574-lot-f-avant.txt`, cas `vide-preserve-note`, ok = TRUE sous 4.2.5.2). La motivation, telle qu'écrite, couvre une forme qu'elle ne motive pas. | « d'un `<t>` ouvrant à attribut ou à blanc… » ; ajouter « la forme vide `<t xml:space="preserve"/>`, lue de même par les deux chemins, est refusée aussi, la règle étant fermée » |
| r2 | 4776-4777 | « (`<t>`, ou `<t/>` s'il est vide…) » peut se lire comme imposant `<t/>` à une chaîne vide, alors que `<t></t>` est admis (seule la balise ouvrante est comparée à `"<t>"`). | « (`<t>`…`</t>`, ou `<t/>`, des blancs étant admis avant « /> ») » |
| r3 | 4938-4940 | « mesuré avec la version 4.2.9, et avec la version 4.2.5.2 pour la cible `./worksheets/…` » se lit comme si la cible était mesurée sous les deux versions. Le suivi (`I.md`) et mon rapport ne la mesurent que sous 4.2.5.2. | « …(mesuré avec la version 4.2.9 ; la cible `./worksheets/…`, avec la version 4.2.5.2 seulement, erreur « Length of worksheet is 0 ») » |
| r4 | 4721-4722 | « qu'openxlsx::write.xlsx() écrit pour une valeur manquante ou infinie » omet la condition `keepNA = TRUE`, énoncée à la l. 4831. Le renvoi « ci-dessous » la rend retrouvable. | facultatif : « pour une valeur manquante (`keepNA = TRUE`) ou infinie » |

## Vérifié et trouvé exact

| Point | Ligne | Vérification |
|---|---|---|
| M1 | 4720-4728 | Énumération conforme à ma correction. Statuts « mesuré » (`t="e"` par `write.xlsx()`, l. 4828-4832) et « non vérifié » (tableur) exacts. L'ajout « résultent d'une saisie qu'un tableur admet (raisonnement, non vérifié) » est correctement qualifié. |
| m10 | 4726-4729 | Troncature à 20 caractères par `.xlsx_citer()`. Nom de partie cité en entier dans `.xlsx_texte()`. Le `identity` de `.xlsx_controler_structure()` (l. 9221) ne sert qu'à la clé de dédoublonnage, non à la citation. |
| M2 (a) | 4776-4787 | Traité en refus, conforme au code (`t_is`, l. ~9268 : `tk != "<t>"` pour l'ouvrante, `^<t[ \t\r\n]*/>$` pour la vide). Lectures citées conformes à `574-lot-f-avant.txt` : en-tête lu `xml:space="preserve">xt`, valeur refusée en aval comme non numérique. Table partagée admise et lue de même (cas `temoin-si-preserve-*`, mesuré). Avec le refus, l'écart n'est plus un écart entre chemins : le retirer de la liste des écarts est juste. |
| m1 | 4790-4795 | Conforme à `f_v` et `f_i` (l. 9316-9317). |
| M2 (b) | 4936-4941 | Contenu exact, sous réserve de r3. |
| m2 à m9, m11 | — | Conformes à mes corrections et à la décision D-S1-33 (titre complet en ligne, sans entrée en `sec:biblio`). |

**Vie du dépôt.** Les lignes ajoutées au `.tex` ne contiennent ni `#N`, ni `D-S1`, ni date de 2026, ni nom d'agent, ni `R0`-`R12`. La vie du dépôt est versée dans `docs/suivi-documentation/I.md`, sous `sec:controles`.

## Réponse à la question de fond de `docwriter`

**Oui.** Un écrivain réel écrit `<is><t xml:space="preserve">` (mesuré, et confirmé par le code source) :

- **openpyxl 3.1.5**, toujours : tout texte y est une chaîne en ligne, et l'attribut est posé dès qu'un blanc borde le texte ;
- **XlsxWriter 3.2.9**, en mode `constant_memory` ;
- **pandas**, par ces deux moteurs.

La liste M1 est donc incomplète au regard de D-S1-31 (R-A).

Relèvent du corpus de l'étape 10 :

- Excel, LibreOffice, Google Sheets (exports) ;
- writexl / libxlsxwriter, openxlsx2, rust_xlsxwriter ;
- la lecture sous `openxlsx` 4.2.5.2 d'un classeur openpyxl à colonne non lue bordée de blancs, avant le lot F.

Je n'avance aucune mesure sur ces outils.

## Constats hors périmètre (ADR 0018)

| n° | Emplacement | Gravité | Critère | Preuve |
|---|---|---|---|---|
| H1 | `TEXTE_REFUS_R3`, motif restitué pour un `<t xml:space="preserve">` | mineur | E5 possible | Le motif dit « balise non prevue, mal imbriquee ou a prefixe d'espace de noms ». Pour `<t >`, aucune des trois qualifications ne s'applique au sens strict. Pour `xml:space`, le préfixe porte sur l'attribut, non sur la balise. Sortie : refus mesuré ci-dessus. |
| H2 | Clone local : la référence `main` est périmée | mineur | aucun | Déjà signalé (H3 du rapport précédent). Revue faite contre `origin/main` = `0d4af02`. |

## Retour

- **Statut** : `revue requise`. La reprise est vérifiée complètement, mais R-A demande une décision du mainteneur sur D-S1-31 avant le libellé final et le PDF.
- **Résultat** : visa avec réserves. Une réserve majeure (R-A), quatre mineurs (r1 à r4).
- **Preuves** :
  - *Vérifiées* :
    - `git show 4988c7b` et `d71d4b0` ;
    - `R/engine.R`, l. 9210-9325 (`t_is`, `f_v`, `f_i`, `refus`), `.xlsx_citer()`, `.xlsx_cinq()`, `.xlsx_texte()` ;
    - sorties `574-lot-f-avant.txt` et `574-lot-f-apres.txt` ;
    - code source d'openpyxl 3.1.5, XlsxWriter 3.2.9 et pandas 3.0.5 installés ;
    - classeurs écrits par ces outils et lus par le moteur `d71d4b0` (refus R3) et par `3f4720e` (ok = TRUE), voie de repli, `LC_ALL=C.UTF-8`.
  - *Hypothèse* : sous `openxlsx`, avant le lot F, le classeur openpyxl à colonne `note` non lue était accepté avec un σ_USP juste.
  - *Non vérifié* :
    - Excel, LibreOffice, writexl, openxlsx2, rust_xlsxwriter ;
    - chemin `openxlsx` des classeurs openpyxl et XlsxWriter : paquet absent de la session.
- **Informations manquantes** : mesure sous `openxlsx` 4.2.5.2 des classeurs du tableau de R-A.
- **Décisions non résolues** :
  - maintenir D-S1-31 tel quel (a) ou borner le refus aux cellules lues (b) : **mainteneur** ;
  - libellé de R-A selon ce choix : `docwriter`.
- **Critères déclenchés** (`routage.md`, § 4) :
  - changement de résultat : classeurs openpyxl, pandas ou XlsxWriter (`constant_memory`) acceptés avant le lot F, refusés depuis (mesuré) ;
  - décision antérieure prise sans l'information, à soumettre de nouveau ;
  - question que seul le corpus de l'étape 10 tranche (autres écrivains) ;
  - aucun désaccord avec `audit` ni avec un ADR.
- **Constats hors périmètre** : H1 (E5 possible, mineur), H2 (aucun).
- **Prochaine action recommandée** :
  1. La session soumet R-A au mainteneur (choix (a) ou (b)).
  2. Si (a) : un commit `docs:` de `docwriter` (R-A, r1 à r4), puis revue de ce diff par `actuary`.
  3. Si (b) : issue ou lot G de #574, `coder-approfondi` → `audit`, puis `docwriter`.
  4. Dans les deux cas, ajouter openpyxl, XlsxWriter `constant_memory` et pandas au corpus de l'étape 10.

**Fichiers de mesure** (scratchpad de session, non versionnés) : `ecrivains/ecrire.py`, `openpyxl_note.xlsx`, `openpyxl_entete.xlsx`, `pandas_openpyxl.xlsx`, `xw_cm_note.xlsx`, `xw_defaut_note.xlsx`, `engine_avant.R` (moteur `3f4720e`).
