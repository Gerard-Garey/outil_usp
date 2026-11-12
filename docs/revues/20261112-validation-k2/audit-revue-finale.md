# Revue finale complète de la branche K2 (`claude/fichiers-et-point-decimal`) : rapport d'`audit`

- **Profondeur** : revue finale complète, règle 10 de `CLAUDE.md`, effort high.
- **Tête revue** : `54a3d1b`. Base `origin/main` = `35042ca` = merge-base.
- **Diff** : `git diff origin/main...HEAD`, soit 36 fichiers, +2698 / −177.
- **Issues** : #487, #522, #520, #550, #488, #439.
- **Arbre de travail** : propre avant et après la revue (`git status --short` vide). Rien n'a été écrit dans le dépôt.
- **Essais** : dans `/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/revue_finale/`.

## Conclusion

**Conforme avec réserves.**

Aucun constat bloquant ni majeur. Quatre constats mineurs. Aucun n'a d'effet sur σ_USP, une p-value ou un verdict : les références sont identiques au seuil 0. Les écarts de comportement relevés sont tous dans le sens sûr : refus ou message imprécis, jamais une valeur fausse acceptée. Une question est renvoyée à `actuary`.

## Constats

### Bloquants
Aucun.

### Majeurs
Aucun.

### Mineurs

**m1. Le commentaire de `lire_tableau()` ne correspond pas au texte affiché à l'import.**
- **Emplacement** : `/home/user/outil_usp/app.R:229`, commentaire d'en-tête de `lire_tableau()`.
- **Écart** : le commentaire annonce la phrase `"Fichier ... (XLSX) refuse : <texte>"`. Le code (`app.R:1178`) écrit `"Fichier %s (%s) refuse. %s"`, avec un point.
- **Ce qui suit le code** :
  - le test `tests/unitaires/test_application.R:941` (« refuse. <texte du moteur> ») ;
  - le `.tex` (« `Fichier <nom> (XLSX) refuse.` suivi de ce texte ») ;
  - le message du commit `2393495` (« point plutôt que deux-points »).
- **Mesure** : `sed -n 224,229p app.R` puis `grep -n "refuse\. " tests/unitaires/test_application.R`.
- **Correction** : remplacer « refuse : <texte> » par « refuse. <texte> » dans le commentaire. Commit `app:`, `coder`.

**m2. CSV dont la ligne 1 ne contient que des séparateurs : le refus #522 ne s'applique pas, et le motif du triangle est trompeur.**
- **Emplacement** : `/home/user/outil_usp/R/engine.R:7906-7958` (`engine_lire_triangle()`), en amont de `lire_tableau()` (`app.R:236-258`).
- **Scénario** : le premier enregistrement est fait des seules virgules (`,,,,,`), ce que produit un tableur qui exporte une plage dont la première ligne est vide. Le reste est un triangle 5 × 5 avec colonne `i`, en-tête en ligne 2.
  - `count.fields` donne `6 6 6 6 6 6 6`, donc aucun refus par `lire_tableau()`.
  - `read.csv` lit des noms vides et prend la ligne `i,j0,…` pour la première année d'accident.
  - **Triangle** : refus « `Cellule(s) non numerique(s) en (i = 0, j = 0), (i = 0, j = 1), … et 1 autre(s)` ». Il désigne la ligne d'en-tête comme l'année d'accident 0.
  - **Triangle sans colonne `i`, en-têtes numériques** : refus « `Triangle non carre (6 annees d'accident, 5 annees de developpement)` ».
  - **Séries** : refus « `Colonnes presentes : (vide), (vide), (vide).` », acceptable.
  - Le même tableau en xlsx reçoit le motif explicite de #522 (« `Ligne 1 du fichier sans aucune valeur…` »).
- **Le message du commit `81250a0`** dit : « CSV non modifié (ligne 1 vide ou titre seul : refusés avant le moteur par lire_tableau()) ». C'est exact pour une ligne physiquement vide (erreur `read.csv`, `MESSAGE_ILLISIBLE`), pas pour une ligne de séparateurs seuls.
- **Mesure** :
  - scripts `tri_l1c.csv`, `ln_l1c.csv` et `tri_l1b.csv` du dossier d'essais ;
  - lecture comme l'application (`read.csv(colClasses = "character", blank.lines.skip = FALSE, check.names = FALSE, na.strings = character(0))`), puis `engine_lire_triangle()` et `engine_lire_donnees_csv()`.
- **Pas d'atteinte au sens sûr** : le fichier est toujours refusé.
- **Correction possible** : dans `.retirer_lignes_colonnes_vides()` ou dans les deux lecteurs, refuser par le texte de #522 un tableau dont tous les noms sont absents au sens de `.entete_absent()` et dont la première ligne de données porte du texte. Sinon, ouvrir une issue.
- **À trancher par** : le mainteneur (extension de #522 dans K2, ou issue hors périmètre).

**m3. Un classeur valide dont le nom de la première feuille finit par « ` id=` » est refusé.**
- **Emplacement** : `/home/user/outil_usp/R/engine.R:8231-8235` (`.xlsx_attribut()`), appelé à `R/engine.R:8252` dans `.xlsx_fichier_feuille()`.
- **Scénario** : `<sheet name="x id=" sheetId="1" r:id="rId1"/>`. Le motif `[ \t\r\n:]id="[^"]*"` trouve d'abord ` id=" sheetId="` à l'intérieur de la valeur de `name`. L'identifiant lu est ` sheetId=`, aucune relation ne correspond, et le refus est « `Classeur illisible : aucune feuille trouvee.` » sur les deux chemins.
- **Mesure** : `e4_feuilles.R`, cas C : `ERREUR: simpleError Classeur illisible : aucune feuille trouvee.`, avec et sans openxlsx.
- **Portée** : cas très artificiel ; refus, jamais une mauvaise feuille lue.
- **Correction** : ancrer la recherche sur un attribut entier, par exemple découper la balise en paires `nom="valeur"` et comparer le nom exactement. Sinon, ajouter le cas à la liste des restes connus.
- **Décideur** : le mainteneur, pour le tri.

**m4. Deux points de déclaration et de documentation, à trier.**
- **(a) `zip` absent de `DESCRIPTION`.**
  - `/home/user/outil_usp/R/engine.R:8044` appelle `requireNamespace("zip")`.
  - `CLAUDE.md` (commit `e536270`) et `README.md:28-32` nomment le paquet `zip` comme dépendance facultative.
  - `/home/user/outil_usp/DESCRIPTION` ne le cite pas (`Suggests: plotly, openxlsx`). En pratique, `zip` arrive avec `openxlsx`, qui l'importe.
  - Mesure : `cat DESCRIPTION`.
  - Correction : ajouter `zip` à `Suggests`. Commit `repo:`, décision du mainteneur.
- **(b) Le `.tex` surestime le refus « `..` » d'une entrée d'archive.**
  - `/home/user/outil_usp/docs/latex/doc_tests_usp.tex:864` et `:4462` : « chemin absolu ou contenant `..` ».
  - Le code (`R/engine.R:8423`) ne refuse `..` que comme composant de chemin entier. Mesure `grepl` : `xl/a..b.xml` → FALSE ; `xl/..`, `../x`, `xl\..\x`, `/abs` → TRUE.
  - Correction : « dont un composant de chemin est `..` ». `docwriter`.

## Points de contrôle appliqués

### Correction

**Lecteur xlsx (`engine_lire_xlsx()` et ses fonctions d'aide)**
- Feuille résolue par `workbook.xml` et ses relations, identique sur les deux chemins :
  - première feuille pointant `sheet2.xml` ;
  - `sheetId` inversés ;
  - mesure `e4_feuilles.R`, cas A et B, `xt = 1` sur les deux chemins.
- Refus de la cellule sans `r` et de `<c` suivi de TAB, CR ou LF.
- Refus de la ligne 1 sans valeur ; sous `entete = FALSE`, pas de refus.
- Garde contre les entrées d'archive qui sortent du dossier (« zip slip »).
- Décodage XML en une passe.
- Parties XML vides :
  - `workbook.xml` vide : refus ordinaire ;
  - feuille vide : data.frame vide (`e7_vide.R`).
- Ligne 1 de chaînes partagées blanches : « `(vide)` » sur les deux chemins (`e5_blancs_partages.R`).
- La perte d'un en-tête `<t xml:space="preserve">` en chaîne en ligne par openxlsx est la divergence déjà documentée dans le commentaire du lecteur : non re-signalée.

**Écrivains (`engine_ecrire_xlsx()`, `engine_ecrire_csv()`)**
- Aller-retour au bit, mesuré (`e1_allerretour.R`) :
  - données : 207 doubles, dont 1/3, `double.xmax`, `double.xmin`, 5e-324, 0.1+0.2 et des puissances de 10 de −300 à 300 ;
  - écriture sous `OutDec = ","` ;
  - relecture par le chemin de l'application ;
  - résultat `identical()` TRUE en CSV et en xlsx, séries et triangle, avec et sans openxlsx et zip.
- `[Content_Types].xml` est la première entrée de l'archive dans les deux voies.
- L'option de l'appelant est rendue après l'appel.

**Règle du bord gauche (#520, `.retirer_lignes_colonnes_vides()`)** — onze configurations mesurées (`e6_triangle.R`), conformes à la décision D1 et à la précision (B) :

| Configuration | Résultat mesuré |
|---|---|
| `vide\|j` | refus, colonne 1 |
| `vide\|i\|j` | accepté |
| `i\|vide\|j` | refus, colonne 2 |
| `vide\|j\|i` | refus, colonne 1 |
| `vide\|vide\|i\|j` | accepté |
| `X1\|j` | refus |
| `i\|i\|vide\|j` | refus, colonne 3 |
| `vide\|i\|vide\|i\|j` | refus, colonne 3 |
| colonne `i` vide | hors règle |
| colonne vide à droite | retirée |
| tableau entièrement vide | « Fichier vide » |

**`mw_valider_triangle()` (#550)**
- Motifs « `i = N` » exacts.
- L'exemple du `.tex` (l. 4773-4780) est reproduit à l'octet : « `Annee d'accident en double : "2020", " 2020 " (annees d'accident i = 4, i = 5 et i = 6).` » et « `Nom de l'annee d'accident i = 2 manquant ou vide.` ».

**`.echapper_texte()`**
- Contrôles ASCII, ` `, U+200B et guillemets échappés.
- Liste LE-06 (colonnes vides portant un en-tête) avec « et 2 autre(s) » : conforme.
- Un en-tête déclaré `"bytes"` est cité avec une double barre oblique inverse (`ab\\xff`). Cette branche de défense n'est atteignable qu'en appel direct : simple remarque.

**`.engine_point_decimal()`**
- 16 appels, chacun en première instruction des 16 points d'entrée.
- Inventaire indépendant des fonctions du moteur réellement appelées, hors commentaires, par `app.R` et `R/display_helpers.R` : il donne exactement ces 16.
- Aucun `on.exit()` sans `add = TRUE` dans leur corps (parcours de l'AST).

**`.refus_lecture()` et `lire_tableau()`**
- Classe `usp_refus_lecture` distinguée.
- Le refus est journalisé, puis affiché tel quel à l'import et au démarrage.

### Architecture
- Aucun calcul ni formatage de nombre dans `app.R` : seuls des `sprintf()` de chaînes ont été ajoutés.
- Aucun caractère non ASCII ajouté dans le R : `grep -P '[^\x00-\x7F]'` vide sur les lignes ajoutées ; 38 occurrences dans `engine.R` avant comme après.
- `zip` reste facultatif. La phrase de `CLAUDE.md` correspond au code.
- Moteur en un seul fichier.

### Reproductibilité
- Aucune source d'aléa nouvelle : `tempfile()` et `zip::zipr()` ne touchent pas `.Random.seed` (test de `test_defauts_connus.R`).
- `tests/reference/` n'est pas touché par le diff.
- Fusion `4a866dd` sans conflit : diff combiné vide.

### Traçabilité
- Échantillon d'affirmations nouvelles du `.tex` et du README vérifiées sur le code :
  - les 16 points d'entrée nommés ;
  - le refus de la ligne 1 et ses exclusions ;
  - la numérotation de la colonne refusée « colonne `i` comprise » ;
  - `engine_ecrire_csv()` et `double.xmax` relu `Inf` par `write.csv()` ;
  - la feuille lue dans l'ordre du classeur ;
  - les exemples de motifs.
- Écart relevé : m4 (b).
- Aucun `detail` ni `reference` du registre des tests ajouté ou modifié par le diff (`grep` sur `add(`, `detail =`, `reference =` : vide).
- Les entrées de `CONTEXT.md` (#519, #527) et l'annotation de l'ADR 0003 correspondent au code (`PHRASE_VERDICT_SENSIBLE_MC`, `R/engine.R:4406` ; motif du défaut intercepté, `R/engine.R:13899`). Les commits cités sont dans `main`.

### Robustesse numérique
- Aucun optimiseur ni racine touché.
- `.xlsx_nombre()` compare `as.double(s) != x` sur un double fini : c'est le critère voulu (relecture exacte), sans tolérance.
- Aucune grandeur dépendante de la plateforme n'est imprimée par le diff.

### Défauts connus
- Aucune marque `echec_attendu()` dans les tests.
- 0 échec attendu et 0 succès inattendu dans les deux batteries.

### Mots-clés de fermeture
- `git log origin/main..HEAD --format=%B` : aucun Close, Fix ou Resolve, ni leurs formes, suivi d'un numéro.
- La seule occurrence proche est le français « Textes fixés pour #520, … » (commit `4edccf9`, avis amont). Ce n'est pas un mot-clé visé, et il n'est pas suivi immédiatement du numéro.

## Batteries et vérifications exécutées (sous `LC_ALL=C.UTF-8`, R 4.3.3)

| Vérification | Résultat |
|---|---|
| `Rscript tests/test_unitaires.R --parallele` **avec** `R_LIBS_USER=…/7394b728…/scratchpad/rlib` (openxlsx 4.2.9, zip 3.0.2, shiny 1.14.0) | **3885 / 3885 ok**, 0 échec, 0 échec attendu, 0 succès inattendu ; 691,6 s |
| — dont `test_controles_entree.R` / `test_application.R` / `test_outdec.R` / `test_defauts_connus.R` | 369 / 223 / 97 / 127 |
| Même commande **sans** bibliothèque (`R_LIBS_USER=`), lancée après la première | **3734 / 3734 ok**, 0 échec, 0 échec attendu, 0 succès inattendu ; 435 s |
| — dont `test_controles_entree.R` / `test_application.R` / `test_outdec.R` / `test_defauts_connus.R` | 360 / 82 / 96 / 127 |
| — tests sautés sans les paquets, comme annoncé | parité openxlsx, voie du paquet zip, processus Shiny |
| `Rscript tests/comparer_references.R --seuil 0` | 6 cas CONFORMES, 0 feuille non strictement identique, écart maximal 0.000e+00 |
| `Rscript tests/test_reproductibilite.R` | OK pour 6 cas, écart maximal 0.000e+00 |
| `Rscript tests/concordance_doc_moteur.R --strict` | 0 écart, code de retour 0 |
| `Rscript tests/controle_doc_nd.R --bloquant` | 0 violation, 0 débordement, code de retour 0 |
| Essais adverses `e1` à `e7` (dossier d'essais) | voir ci-dessus |

Pendant la première batterie, une autre session faisait tourner sur la machine un `shiny::runApp` et un `install.packages("openxlsx")` dans `…/9cb815f0…/scratchpad/lib`. Ce n'était pas cette revue. La charge a allongé les durées, sans effet sur les résultats.

## Question renvoyée à `actuary`

**Q1. Citation de l'octet 0x89 déclaré Latin-1.**
- **Écart** : `.echapper_texte()` (`R/engine.R`, fonction ajoutée vers la l. 1027) cite cet octet comme « ‰ » (U+2030), lecture Windows-1252 par `enc2utf8()`, comme `.nettoyer_cellules()` (#99). L'avis amont (`docs/revues/20261111-avis-amont-k2/actuary-avis-amont.md:94`) prévoyait `\u0089`.
- **État** : le commit `81250a0` renvoie cet écart à la validation d'`actuary` « à l'étape 10 ». Aucune trace de cette validation n'a été trouvée dans `docs/revues/20261111-avis-amont-k2/` ni dans la feuille de route.
- **Mesure** : test « Colonnes presentes (#522) : octet 0x89 déclaré Latin-1 lu comme Windows-1252 (U+2030, cité tel quel) », vert dans les deux batteries.
- **Effet** : aucun sur un résultat ; le texte du motif seul est en jeu.
