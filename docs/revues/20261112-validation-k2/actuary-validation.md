# K2, étape 10 : validation unique d'`actuary`

> *Rédigé par l'agent actuary (IA), fiche approfondie, le 12/11/2026. Branche `claude/fichiers-et-point-decimal`, tête `54a3d1b`, arbre propre. Rien n'a été écrit dans le dépôt. Les mesures ont été faites sous `LC_ALL=C.UTF-8`, R du hook. `openxlsx` 4.2.9 et `zip` ont été installés dans une bibliothèque du scratchpad (`R_LIBS`), hors du dépôt. Les scripts sont dans `/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/m/`.*

## Verdict

**Validé avec réserves.**
- **Code et résultats** : validés sans réserve.
- **`.tex`** : validé sous réserve d'**un constat majeur** (C1, rattachement implicite du refus de la colonne 0 à l'annexe XVII) et de **trois constats mineurs** (C2 à C4), plus une précision facultative (C5).
- **README** : validé.

Corrections mot pour mot au § 2. Tant que C1 est corrigé comme proposé, `regulatory` n'est pas requis.

## 0. Base de la lecture

**Base du diff : `origin/main`, pas le `main` local.** Le `main` local est resté à `83198f5`, alors qu'`origin/main` est à `35042ca`.
- `git diff main...HEAD -- README.md` affiche donc à tort le paragraphe « Sous Windows… » (#546, R40, PR #551). Ce paragraphe est déjà sur `origin/main`.
- Sur `origin/main...HEAD`, le README de la branche se réduit à deux blocs : les prérequis `openxlsx`/`zip`, et le paragraphe `engine_ecrire_csv()` / `engine_ecrire_xlsx()` / `usp_refus_lecture`.
- Les six commits `docs:` de `124f70b` à `54a3d1b` sont les seuls à toucher le `.tex` et le README sur la branche.
- Le paragraphe Windows n'est pas validé ici : il relève de R40.

**Sources lues** :
- `R/engine.R` :
  - l. 515-535 (`.engine_point_decimal()`) ;
  - l. 1006-1040 (`.echapper_texte()`) ;
  - l. 7660-7840 (`.retirer_lignes_colonnes_vides()`, `engine_lire_donnees_csv()`) ;
  - l. 8130-8360 (écrivain CSV, `.refus_lecture()`, `.xml_decoder()`, contrôles XML, `.xlsx_blancs_entete()`) ;
  - l. 9770-9810 (noms d'année d'accident).
- `app.R` : l. 215-258 (`lire_tableau()`), 1170-1182 (import) et 1864-1892 (exports).
- Annexe XVII, sections A(1) et D, dans la version consolidée versionnée à la racine. Seul du texte (pas de formule) a été lu par extraction.
- `CONTEXT.md`, entrées « Contrôle de validité » et « Erreur d'usage ».
- Fiche « Branche K2 » de `docs/feuille-de-route.md`.
- Corps des commits `81250a0` et `1dae258`.

## 1. Diff du `.tex` et du README

### 1.1 Messages cités, comparés au moteur (*vérifié*)

Chaque texte a été comparé à la chaîne du moteur, et la plupart ont été obtenus par exécution :

| Texte cité dans le `.tex` | Source moteur | Résultat |
|---|---|---|
| « Classeur illisible : cellule sans reference de position (attribut r) dans la feuille lue ; l'outil ne deduit pas sa position. » + conduite | `engine.R:8293` | identique (préfixe) |
| « balise de cellule de forme non reconnue » | `engine.R:8290` | sous-chaîne exacte |
| « Ligne 1 du fichier sans aucune valeur : l'en-tete du tableau doit etre en ligne 1, sans ligne au-dessus ; » + conduite | `engine.R:8329` | identique (préfixe) |
| « Classeur illisible : aucune feuille trouvee. » | `engine.R:8243`, `8422` | identique |
| « … sans en-tete avant la premiere colonne renseignee du triangle » / « annee de developpement 0 manquante presumee » | `engine.R:7776-7778` ; exécuté | identique |
| « Nom de l'annee d'accident i = 2 manquant ou vide. » | exécuté (`mw_valider_triangle()`, nom `NA` en ligne 3) | identique |
| « … i = 4, i = 5 et i = 6 » (doublons « 2020 », « 2020 », « ␣2020  ») | exécuté : `Annee d'accident en double : "2020", " 2020 " (annees d'accident i = 4, i = 5 et i = 6).` | identique |
| « et 2 autre(s) » pour sept positions | `liste()`, `engine.R:7726-7727` | conforme |
| « Colonnes presentes : … (vide) » | exécuté : `… Colonnes presentes : a‰b, (vide), (vide).` | conforme |
| « Fichier <nom> (XLSX) refuse. » + texte | `app.R:1178` | conforme pour `.xlsx` (voir C4) |

### 1.2 Comportements décrits, mesurés ou relus (*vérifié*)

**#520, bord gauche du triangle**, cinq cas exécutés par `engine_lire_triangle()` sur `tests/donnees/triangle_mw.csv` :

| Cas | Résultat |
|---|---|
| Sans `i`, colonne 1 vide | refus « colonne(s) 1 » |
| `i` puis colonne vide | refus « colonne(s) 2 » (numérotation colonne `i` comprise) |
| Colonne vide puis `i` | `ok = TRUE`, retirée sans message |
| Colonne vide à en-tête après `i` | LE-06 inchangé |
| `i` après les données, colonne vide à gauche | refus |

Le `.tex` (l. 838-844 et 3850-3861) décrit exactement ces cinq cas.

**#522, ligne 1 de chaînes vides ou de blancs**, mesurée sur les deux chemins :
- **série** : non refusée par le contrôle de ligne 1, puis refus « Colonnes presentes : (vide), (vide), (vide). » ;
- **triangle** : refus « Cellule(s) non numerique(s) en (i = 0, j = 0)… » (voir C2).

**#488, avec `openxlsx` 4.2.9** :
- l'en-tête `a<b&c` et les chaînes `x&y`, `<z>` sont relus `a&lt;b&amp;c`, `x&amp;y`, `&lt;z&gt;` ;
- la colonne logique est relue `logi` ;
- la voie de repli relit les chaînes telles qu'écrites, et la colonne logique en caractères ;
- l'aller-retour xlsx de (1/3, `.Machine$double.xmax`, 1e-300, π, −2,5e10, 0,1+0,2) est `identical()` ;
- l'en-tête « ␣xt » est relu `xt` et accepté.

L'affirmation du `.tex` (l. 921-925) est exacte. Les exports de l'application ont des en-têtes fixes (`i`, `j0`…, ou `t`, `xt`, `yt`) et des cellules numériques (`app.R:1870-1880`) : « n'y sont pas exposés » est exact.

**`engine_ecrire_csv()`** :
- 1/3 est écrit `0.33333333333333331` et `.Machine$double.xmax` `1.7976931348623157e+308` ; les deux sont relus `identical()` ;
- `NaN` donne une cellule vide et ±Inf « Inf » / « -Inf » ;
- par `write.csv()`, 1/3 n'est pas relu à l'identique et `double.xmax` est relu `Inf`.

Les affirmations du `.tex` (l. 926-934) sont exactes.

**#439** :
- 16 appels `.engine_point_decimal()` en première instruction, liste conforme au `.tex` (l. 3729-3738) ;
- refus au niveau global (`engine.R:528-530`) ;
- `tests/unitaires/test_outdec.R` l. 222-268 vérifie l'inventaire tiré d'`app.R` et de `display_helpers.R` ainsi que la restauration sur erreur, comme le dit le `.tex` (l. 3763-3766).

**README** :
- `zip` est bien importé par `openxlsx` : l'installation l'a tiré comme dépendance ;
- les refus et la classe sont conformes au code.

**Concordance** : `LC_ALL=C.UTF-8 Rscript tests/concordance_doc_moteur.R --strict` donne « BILAN : 0 ecart(s) (mode strict) ».

### 1.3 Statut épistémique et vocabulaire

- Les mentions « mesuré » renvoient à des mesures retrouvées dans le code, dans les tests ou dans mes exécutions, sauf la parité des blancs hors `C.UTF-8` (C3).
- Aucune affirmation fabriquée relevée. Aucune référence bibliographique ni aucun résultat statistique n'est ajouté.
- **Vocabulaire** : « refus » pour une erreur R levée par un lecteur sur le contenu du fichier est conforme à `CONTEXT.md`, « Contrôle de validité », qui range déjà ainsi `usp_lire_vecteur()`. « Erreur d'usage » n'est pas employée à tort. `CONTEXT.md` ne nomme pas encore la classe `usp_refus_lecture` (observation O2, non bloquante).

### 1.4 Présomption « année de développement 0 manquante » (#520) et annexe XVII

**Lecture du texte** (consolidée, sections A et D de l'annexe XVII, *vérifié*) :
- **A(1)(b)** : l'année de développement est « la différence entre l'année de ce paiement et l'année de l'accident ». L'année 0 existe donc par définition.
- **D(1)** : les données sont des montants cumulés « indiqués séparément pour chaque année d'accident et chaque année de développement des paiements ».
- **D(2)(c)** : « pour la première année d'accident, des données sont disponibles pour cinq années de développement consécutives au moins ».
- **D(3)(c)-(d)** : notations de J et de C(i,j).

**Analyse** :
- Le `.tex` écrit (l. 3852) « est refusée **de même** comme année de développement 0 manquante présumée ». « De même » reprend le rattachement de la phrase précédente : « (D(1), D(2)(c) et D(3)(c) … ; la présomption est une lecture retenue par l'outil) ».
- **D(2)(c) ne fonde pas ce refus.** Un triangle privé de sa colonne 0 garde des années de développement consécutives (1 à 7) : la consécutivité n'est pas rompue, contrairement à une colonne intercalée.
- **D(1), lu avec A(1)(b), ne le fonde que dans l'une des deux lectures.** Si la colonne 0 manque, le montant de l'année de développement 0 n'est pas indiqué. Si le tableau est seulement décalé, aucune exigence de la section D n'est méconnue : un 7 × 7 complet satisfait D(1) et D(2).
- Le `.tex` dit lui-même, deux lignes plus loin, que « l'outil ne choisit pas entre les deux lectures ». Le refus est donc une **précaution d'identifiabilité** : l'outil ne peut pas déterminer l'année de développement de chaque colonne. Ce n'est pas une exigence réglementaire.
- Le motif du code n'a d'ailleurs aucun renvoi réglementaire, conformément à l'avis amont (§ 1.1).

**Conclusion** : le rattachement est **partiellement infondé** (D(2)(c)) et **conditionnel** (D(1)). Il faut l'éviter : constat C1.
- **Correction C1 appliquée** : le `.tex` ne cite plus l'annexe pour ce refus, et **`regulatory` n'est pas requis**, ce qui reste cohérent avec l'avis amont.
- **Si le mainteneur préfère garder un ancrage réglementaire** (D(1) lu avec A(1)(b)) : `regulatory` doit d'abord établir cette lecture (circuit 4, référence réglementaire touchée).

## 2. Constats

### C1 — majeur — `docs/latex/doc_tests_usp.tex:3850-3856`

**Problème** : rattachement implicite (« de même ») du refus de la colonne 0 à D(1), D(2)(c) et D(3)(c) ; voir § 1.4.

**Correction attendue, mot pour mot** :
- Remplacer « est refusée de même comme année de développement~0 manquante présumée » par :
  > est refusée comme année de développement~0 manquante présumée, par un motif sans renvoi réglementaire
- Puis, après « et l'outil ne choisit pas entre les deux lectures. », insérer :
  > Ce refus est une précaution de l'outil, qui ne peut pas déterminer l'année de développement de chaque colonne~; il ne découle pas à lui seul de la section~D, à laquelle le tableau décalé peut satisfaire.

### C2 — mineur — `docs/latex/doc_tests_usp.tex:4474-4475`

**Problème** : « ses colonnes sont citées (vide) par le refus des colonnes manquantes » n'est vrai que pour une série. Un triangle est refusé par le contrôle des cellules (mesuré sur les deux chemins).

**Correction attendue** : remplacer « une ligne~1 faite de chaînes vides ou de blancs n'est pas visée, et ses colonnes sont citées «~\code{(vide)}~» par le refus des colonnes manquantes. » par :
> une ligne~1 faite de chaînes vides ou de blancs n'est pas visée~: pour une série, ses colonnes sont citées «~\code{(vide)}~» par le refus des colonnes manquantes~; pour un triangle, la ligne d'en-tête suivante est lue comme une ligne de données et refusée comme cellule non numérique (mesuré sur le triangle de contrôle à en-têtes \code{i}, \code{j0}, \ldots{}, sur les deux chemins de lecture).

### C3 — mineur — `docs/latex/doc_tests_usp.tex:4478-4480`

**Problème** : « mis en forme de même par les deux chemins » est affirmé sans statut. Le jeu des blancs dépend de la locale, et la parité n'est mesurée que sous `C.UTF-8` (commentaire de `.xlsx_blancs_entete()`, `engine.R:8333-8344`). L'index des fonctions (l. 908-911) le dit, le récit non.

**Correction attendue** : après « (blancs de bord retirés, suite de blancs intérieurs ramenée à une espace) », insérer :
> , les blancs étant ceux de la classe \code{[[:space:]]} de la locale (parité mesurée sous la locale \code{C.UTF-8} avec \code{openxlsx}~4.2.9, non sous Windows)

### C4 — mineur — `docs/latex/doc_tests_usp.tex:4069-4070`

**Problème** : `app.R:1178` écrit `toupper(ext)`, soit « (XLSM) » pour un classeur `.xlsm`.

**Correction attendue** : remplacer « («~\code{Fichier <nom> (XLSX) refuse.}~» suivi de ce texte) » par :
> («~\code{Fichier <nom> (XLSX) refuse.}~», \code{(XLSM)} pour un classeur \code{.xlsm}, suivi de ce texte)

### C5 — mineur, facultatif — `docs/latex/doc_tests_usp.tex:832`

**Proposition** : après « chaque texte ramené d'abord en UTF-8 », ajouter :
> (octets 0x80 à 0x9F d'un texte déclaré Latin-1 lus selon Windows-1252, comme les cellules)

**Motif** : rendre visible la décision validée au § 3.1.

### Observations hors `.tex`, non bloquantes

- **O1 (`app.R:229`)** : le commentaire annonce « refuse : <texte> », alors que le code écrit « refuse. <texte> » (l. 1178). À signaler à `app-review` lors de la revue finale.
- **O2 (`CONTEXT.md`)** : l'entrée « Contrôle de validité » ne nomme pas la classe `usp_refus_lecture`. Mise à jour éventuelle par `architect`.
- **O3 (*hypothèse, non mesurée*)** : sous la décision du 12/11, une ligne 1 de blancs n'est pas refusée. Un cas forgé pourrait alors passer le triangle avec un simple avertissement de cellules sous la diagonale, au lieu d'un refus : triangle 7 × 8, en-tête numérique 1 à 8, ligne 1 de blancs. L'enchaînement est conjectural et peu plausible. Je ne recommande pas de rouvrir la décision ; `audit` peut le sonder en revue finale si le mainteneur le juge utile.

## 3. Textes de l'étape 2 tels qu'implémentés

### 3.1 Octets 0x80-0x9F déclarés Latin-1 (#522 § 2.3) : écart validé

- **Mesuré** :
  - 0x89 → « a‰b » ;
  - 0x80 → « a€b » ;
  - 0x81 → « a<81>b » ;
  - `\001` → `\001` ; `\t`, `\n`, `\033` échappés ;
  - U+00A0 → ` ` ;
  - barre oblique inverse doublée.
- **Validé pour 0x89 et 0x80.**
  - La déclaration Latin-1 est la présomption de l'outil pour des octets non UTF-8 (`.declarer_latin1()`).
  - R convertit ces octets selon Windows-1252.
  - Un fichier qui porte ces octets vient en pratique d'un poste Windows : « ‰ » et « € » sont ce que l'utilisateur voyait dans son tableur.
  - Le traitement est cohérent avec les cellules (#99).
  - Le caractère est imprimable et sans ambiguïté.
- Mon avis amont (« `\u0089` ») est **remplacé** par cette règle.
- **Validé avec une réserve documentée pour 0x81, 0x8D, 0x8F, 0x90, 0x9D**, cinq octets sans caractère en Windows-1252.
  - La forme « <81> » se confond avec un texte littéral « <81> » : c'est le défaut pour lequel j'avais écarté « <U+0001> ».
  - Le cas est borné à cinq octets, hérité du comportement de #99, et sans effet sur un nombre.
  - Je ne demande pas de correction du code. Le commentaire de `.echapper_texte()` (`engine.R:1014-1018`) le documente ; C5 le rend visible dans le `.tex`.

### 3.2 Décision du mainteneur du 12/11 sur #522 : conforme

- Les trois refus (ligne 1, cellule sans `r`, balise `<c`) sont de classe `usp_refus_lecture` (`engine.R:8181-8183`).
- `lire_tableau()` les rend tels quels (`app.R:256-257`), à l'import et au démarrage (`app.R:270`, `301`).
- L'archive illisible et la feuille introuvable restent des erreurs ordinaires.
- Une ligne 1 de blancs n'est pas refusée et reçoit « (vide) » pour une série (C2 pour le triangle).

### 3.3 Autres textes

- **#520, précision (B)** : appliquée et conforme (§ 1.2).
- **#550, O1 et O2** : appliqués mot pour mot. Les trois gabarits de `engine.R:9785-9808` sont identiques à l'avis § 4.2. LE-06 cite les en-têtes échappés par `liste()` (`engine.R:7784-7788`).
- **#488, divergence `openxlsx`** : mesurée et documentée avec exactitude (§ 1.2). Les exports de l'application ne sont pas exposés.

## 4. Résultats

**Reproductibilité** : `LC_ALL=C.UTF-8 Rscript tests/test_reproductibilite.R`, code de sortie 0, « OK : reproductibilite et non-regression verifiees pour 6 cas ».

| Cas | σ_USP | Feuilles | Écart maximal |
|---|---|---|---|
| premium | 0,1114524114 | 57 018 | 0,000e+00 |
| reserve1 | 0,1073524114 | 57 017 | 0,000e+00 |
| reserve2 | 0,0497764613 | 18 725 | 0,000e+00 |
| premium_ii6 | 0,1483524114 | 57 018 | 0,000e+00 |
| premium_net | 0,1032524114 | 57 018 | 0,000e+00 |
| premium_interieur | 0,0871308679 | 57 018 | 0,000e+00 |

**Conclusions** :
- Aucun σ_USP, aucune p-value ni aucun verdict des six cas ne change. Les p-values non touchées sont **validées**.
- **Aucun changement de σ_USP ni de verdict n'est à soumettre au mainteneur.**

**Comportements changés hors références**, tous couverts par des décisions déjà prises :

| Comportement | Avant | Après | Décision qui le couvre |
|---|---|---|---|
| Triangle 8 × 8 à colonne 0 vide sans en-tête, sans `i` (#520) | lu en 7 × 7, σ_USP calculé (0,05851230792 selon le corps de `1dae258`, *non remesuré* ; refus *vérifié*) | refus motivé | D1, Q-59-2 (a) |
| Classeur à ligne 1 sans valeur (#522) | accepté par `openxlsx` (tableau décalé), mal lu par la voie de repli | refus motivé | plan décidé (Q-59-1 (a), « refus motivés d'entrées fautives ») ; texte de l'avis § 2.1 |
| Cellule sans `r` ; balise `<c` + TAB/CR/LF (#487) | valeur perdue sans message par `openxlsx` | refus motivé | avis § 3.1 ; plan |
| En-tête « ␣xt » en xlsx, voie de repli (#487) | refusé | accepté, comme avec `openxlsx` | avis § 3.3 ; D3 pour le reste CSV |
| Première feuille, voie de repli (#487) | premier fichier par ordre alphabétique | première feuille du classeur, comme `openxlsx` | plan (« feuille lue identique ») |

Aucun de ces changements ne touche les six cas, qui chargent leurs données par `utils::read.csv()`.

## Retour

- **Statut** : `complet`.
- **Résultat** :
  - code et résultats : validés ;
  - `.tex` : **validé avec réserves**, sous condition de C1 (majeur) ; C2 à C4 (mineurs) sont à corriger dans le même passage ; C5 est facultatif ;
  - README : validé.
- **Preuves** :
  - ***Vérifié*** :
    - messages comparés au moteur, par exécution ou par lecture ligne à ligne (§ 1.1) ;
    - cinq cas de #520, ligne 1 de blancs, échappement 0x80/0x81/0x89, aller-retour des deux écrivains et divergence `openxlsx` 4.2.9, tous exécutés ;
    - 16 points d'entrée ;
    - concordance `--strict` : 0 écart ;
    - reproductibilité : 6 cas, écart 0 ;
    - annexe XVII A(1)(b), D(1), D(2)(c), D(3) lues dans la version consolidée.
  - ***Hypothèses*** : O3. Le caractère « Windows » des fichiers à octets 0x80-0x9F (§ 3.1).
  - ***Non vérifié*** :
    - parité des blancs sous Windows (c'est l'objet de C3) ;
    - σ_USP 0,0585 avant #520 (repris du corps de commit) ;
    - compilation du PDF (hors de mon rôle) ;
    - rapports d'`audit` de la branche (non fournis dans le brief).
- **Informations manquantes** : aucune bloquante.
- **Décisions non résolues** : une seule, pour le mainteneur. Garder un ancrage réglementaire du refus de la colonne 0 ? Ma recommandation est non (C1). S'il le veut, `regulatory` doit être appelé.
- **Critères déclenchés** (`routage.md`, § 4) :
  - **Résultats changés hors références** : déjà couverts par D1, D3 et le plan décidé ; aucun nouveau.
  - **Écart avec mon avis amont** (0x89) : résolu, je le valide.
  - **Désaccord avec `audit`** : aucun constaté ; je n'ai pas lu ses rapports. **Désaccord avec un ADR** : aucun.
  - **Deux lectures d'une source** : aucune. Le texte de l'annexe est clair ; c'est le rattachement du `.tex` qui est en cause.
- **Prochaine action recommandée** :
  1. `docwriter` applique C1 à C4 (et C5 s'il est retenu) dans un commit `docs:` minimal.
  2. Je valide ce seul diff ; une relance ciblée suffit.
  3. Revue finale (règle 10) : signaler O1 à `app-review`, et O3 à `audit` si le mainteneur le souhaite.
  4. Avant tout diff de contrôle, la session met à jour le `main` local (`git fetch`) ou lit contre `origin/main`.
