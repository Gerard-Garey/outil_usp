# Rejeu de l'étape 1 de K2b (`claude/lecteur-xlsx-et-refus-import`, PR #571, tête `e3ebb84`)

> *Rapport de `coder` (étape 1 de K2b, rejeu en lecture et exécution seules, 13/11/2026), versé par la session principale (mise en forme seule ; chemins du scratchpad remplacés par `<scratchpad>`). Classeurs fabriqués, PDF d'impression et journaux non versés : `scripts-rejeu/fab.R` et `impression.js` les régénèrent.*

Lecture et exécution seules. `git status --short` vide avant et après (mesuré, dernier contrôle en fin de rejeu). Aucun commit. Scripts, classeurs fabriqués et sorties : `scripts-rejeu/`.

Légende : **[M]** mesuré (commande exécutée, sortie lue) ; **[L]** lu (code, journal, issue) ; **[H]** hypothèse (non mesurée).

## 0. Environnement de mesure

| Élément | Valeur | Statut |
|---|---|---|
| R | 4.3.3 (la CI : 4.3.1) | [M] `R.version.string` |
| Locale | `LC_ALL=C.UTF-8` (sauf mention) ; chargement par `source("R/charger_moteur.R"); charger_moteur()` | [M] |
| `openxlsx` | **4.2.9**, installé depuis CRAN dans `.../k2b-rejeu/lib` (compilation, 6 min) ; même version que les mesures citées dans le code | [M] `packageVersion` |
| `zip` (paquet) | 3.0.2 (même `lib`) ; la commande système `/usr/bin/zip` est présente | [M] |
| `shiny` / `plotly` | 1.14.0 / 4.12.1 (la CI : 1.8.0 / 4.10.4, figés) : **écart de versions** | [M] |
| Compilations | `fs` (`USE_BUNDLED_LIBUV=1`), `curl` et `openssl` (en-têtes `libcurl4-openssl-dev` et `libssl-dev` extraits de `.deb` d'`archive.ubuntu.com` dans le scratchpad, `INCLUDE_DIR` / `LIB_DIR`) : aucune modification du système | [M] |
| Navigateur | Chrome for Testing 153.0.8010.12 (`/opt/pw-browsers`), Playwright 1.63.0 | [M] |
| Dépôt | inchangé (`git status --short` vide) | [M] |

Les masquages d'`openxlsx` reprennent celui des tests : `requireNamespace` posé dans `environment(engine_lire_xlsx)` (équivalent de `environment(run_engine)`, même environnement du moteur).

---

## 1. #557 — lecteur xlsx (deux chemins)

Classeurs fabriqués par `fab.R` (XML de feuille écrit à la main, compression par la commande `zip`). Lecture par `engine_lire_xlsx()` : « interne » = `openxlsx` masqué ; « openxlsx » = `openxlsx::read.xlsx()` appelé par le moteur. Tous les cas : `sortie_557a.txt`, `sortie_557c_bis.txt`, `sortie_557d.txt`, `sortie_557e.txt` (la sortie `sortie_557b.txt` a été produite par une première version de l'enveloppe qui convertissait les avertissements en échec ; les cas `r` invalides y sont refaits dans `sortie_557c*.txt`).

### 1.1 Point 1 : `t="str"` — [M]

| Cas | Interne | openxlsx |
|---|---|---|
| en-tête `t="str"` (`<f>"xt"</f><v>xt</v>`) | lu `xt` | lu `xt` |
| en-tête `<v>a&amp;b</v>`, `x&lt;t`, `y&#233;` | nom `a&amp;b`, `x&lt;t`, `y&#233;` (**entités non décodées**) | identique |
| corps `<v>a&amp;b</v>` | `a&amp;b` (caractère) | identique |
| corps `<v>1.5</v>` et `<v>3</v>` (colonne entière en `t="str"`) | colonne **caractère** `"1.5"`, `"3"` | identique |
| corps `t="str"` avec `<v></v>` | chaîne vide, colonne caractère | identique |
| ligne 1 faite de `t="str"` blancs | refus `usp_refus_lecture` (texte de #522) | identique |

**Constat** : la cellule `t="str"` n'est **pas perdue** : sa valeur est lue, brute, à l'identique sur les deux chemins ; seul le **décodage des entités** manque (`&amp;`, `&lt;`, `&gt;`, `&#233;`…). [M] La fiche (étape 4) parle d'« une cellule `t="str"` aujourd'hui perdue et désormais décodée » : la mesure ne confirme pas « perdue ».

**Si une correction changerait un fichier accepté aujourd'hui** : oui, **valeur différente** (jamais accepté → refusé), et seulement pour une cellule `t="str"` dont le `<v>` contient une entité. Une cellule `t="str"` sans entité (cas courant : résultat de formule texte) est inchangée. Effet sur un calcul : aucun mesuré (un nom d'en-tête à `&` n'est pas un nom attendu ; une cellule texte à `&` dans une colonne de données est refusée en aval) [H pour l'absence d'effet sur un résultat, non mesuré de bout en bout].

**Contrainte** : décoder sur le seul chemin interne romprait la parité ; décoder sur `openxlsx` exige de retoucher sa sortie, ce que l'en-tête du lecteur écarte (« sortie d'openxlsx non retouchée », [L] `R/engine.R` l. 8778-8806). Choix à trancher (§ 6).

### 1.2 Point 2 : `<rPh>` — [M]

| Cas | Interne | openxlsx |
|---|---|---|
| chaîne **partagée** d'en-tête `<t>xt</t><rPh sb="0" eb="2"><t>ZZ</t></rPh>` | nom **`xtZZ`** (le texte phonétique est concaténé) | nom `xt` (correct) |
| chaîne partagée du corps `abc` + `rPh` `ZZ` | `abcZZ` | `abc` |
| chaîne **en ligne** d'en-tête `<is><t>xt</t><rPh>…</rPh></is>` | `xtZZ` | **en-tête perdu** : nom `X2` |
| chaîne partagée enrichie `<r><t>x</t></r><r><t>t</t></r>` + `rPh` | `xtZZ` | `x` (sortie brute ; cause non analysée : la même chaîne enrichie sans `rPh` est lue `xt`) |
| `<phoneticPr>` seul (sans `rPh`) | `xt` | `xt` |

Cause [L] : `.xml_textes()` concatène **tous** les `<t>` du fragment, `rPh` compris (`R/engine.R` l. 8511-8515).

**Fichier accepté changé ?** Le lecteur interne lit aujourd'hui l'en-tête `xt` + `rPh` comme `xtZZ` : colonne attendue absente, donc **refusé** en aval ; une correction (ignorer `rPh`) le rendrait **accepté**, avec le nom correct, identique à `openxlsx` pour une chaîne partagée. Pour une colonne **ignorée** (nom hors `t`, `xt`, `yt`, `i`, `j<k>`) ou une cellule texte du corps, le nom ou le texte lu change (valeur différente) sans effet sur le calcul. Aucun fichier accepté ne deviendrait refusé. Pour la chaîne **en ligne** + `rPh`, `openxlsx` perd l'en-tête (`X2`) : parité à définir (limite ou refus).

### 1.3 Point 3 : `r=""` — [M]

| Cas | Interne | openxlsx |
|---|---|---|
| `<c r="">` valeur dans le corps | **erreur R brute** `invalid 'nrow' value (too large or NA)` | **erreur R brute** `missing value where TRUE/FALSE needed` |
| `<c r="" t="s">` en-tête | idem | idem |
| `r=""` sur toutes les cellules | refus de la ligne 1 sans valeur (texte de #522) | idem |
| `<c r="" s="1"/>` (cellule vide de style, ligne 4) | erreur R brute | **lu normalement** (la cellule est ignorée) |
| `<row r="">` avec cellules `r` valides | lu | lu |
| (témoin) cellule sans attribut `r` | refus motivé existant (`usp_refus_lecture`) | identique |

Cause [L] : `.xlsx_controler_cellules()` teste `[ \t\r\n]r="` : `r=""` y satisfait. Aujourd'hui `r=""` donne une **erreur R brute** sur les deux chemins ; l'application la restitue par `MESSAGE_ILLISIBLE$xlsx` (non par un texte du moteur).

**Fichier accepté changé ?** Refuser `r=""` : **aucun** fichier lu aujourd'hui par l'interne ; **un cas** sur `openxlsx` (`<c r="" s=…/>` sans valeur, lu aujourd'hui, deviendrait refusé). Le motif change pour les autres (erreur brute → refus motivé).

**Cas voisins mesurés (hors liste de l'issue, constat nouveau)** : d'autres références invalides ne sont pas refusées non plus et **perdent ou déplacent silencieusement une valeur** sur un des chemins :

| `r=` | Interne | openxlsx |
|---|---|---|
| `"1"` | `xt = NA`, **`yt = 1.5`** (valeur déplacée), 2 avertissements R | `xt = NA` (valeur perdue), sans message |
| `"A0"` | idem (valeur déplacée) | `xt = NA`, **une ligne `NA` ajoutée** |
| `"1A"` | erreur R brute | `xt = NA` (valeur perdue) |
| `" A2 "` | erreur R brute | `xt = NA` (valeur perdue) |
| `"A"`, `"A1:B2"` | erreur R brute | erreur R brute |
| `"a2"` (minuscule) | lu `A2` | erreur R brute (connu, [L] en-tête du lecteur) |

Étendre le refus à toute référence hors `^[A-Za-z]+[1-9][0-9]*$` **changerait des fichiers acceptés** aujourd'hui (`"1"`, `"A0"`, `"1A"`, `" A2 "` : lus avec valeur perdue ou déplacée → refusés). Ce serait aller au-delà de « `r=""` » ; choix à trancher (§ 6).

Un **segfault** d'`openxlsx` a été observé une fois en traitant ces références malformées dans un processus partagé (`mesure_557c.R`, cas `r="a2"`) ; non reproduit à la seconde exécution du même script ni en processus isolé (`seg.R`) : [M] observé, non élucidé.

### 1.4 Point 4 : commentaire d'en-tête inexact — [M] + [L]

Le commentaire (`R/engine.R` l. 8778-8779) dit « une chaîne en ligne enrichie (`<is><r><t>..`) est lue entière ici, rendue **NA** par openxlsx ». Mesure :

| Cas | Interne | openxlsx 4.2.9 |
|---|---|---|
| **corps** `<is><r><t>a</t></r><r><t>bc</t></r></is>` | `abc` | **`NA`** (valeur perdue) |
| **en-tête** `<is><r><t>x</t></r><r><t>t</t></r></is>` | `xt` | nom **`X2`** (en-tête perdu, nom de colonne par défaut) |
| en-tête `<t xml:space="preserve">xt</t>` (chaîne en ligne) | `xt` | `xml:space="preserve">xt` (attribut dans le nom, déjà dit dans le commentaire) |

Le commentaire est exact pour une cellule du corps, inexact pour un en-tête (nom `X<col>`, non `NA`), conformément à la mesure de `docwriter` citée par l'issue. La chaîne **partagée** enrichie d'en-tête sans `rPh` (`<r><rPr/><t>x</t></r><r><t>t</t></r>`) est lue `xt` par les deux chemins. Aucun changement de comportement : correction de texte seule.

### 1.5 Point 5 : blancs d'en-tête sous Windows — non mesurable ici

Aucun poste Windows dans la session. Sous Linux, [M] (`mesure_557d.R`) : sept blancs (U+00A0, U+2003, U+0085, U+3000, U+2007, TAB, LF) en bord et à l'intérieur d'un en-tête, lus **identiquement** par les deux chemins sous `C.UTF-8` **et** sous `C` (parité sur ces sept caractères, dans chacune des deux locales). Mais le résultat **dépend de la locale** : `U+2003` devient une espace sous `C.UTF-8` et reste `U+2003` sous `C` ; `U+00A0` n'est un blanc dans aucune des deux. Le comportement sous Windows (page de codes native, locale R) reste **non mesuré** : à consigner comme limite, ou à faire mesurer sur le poste du mainteneur (critère de l'issue).

### 1.6 Liste des comportements qui changeraient hors références (critère du recours à `coder-approfondi`)

Aucun des six cas de référence ne passe par un lecteur (déjà établi, fiche ; `grep` « non carre » / « D(2)(e) » vide dans les six `.rds`, [M] pour #540).

| # | Comportement changé | Direction | Fichier aujourd'hui accepté ? | Chemin | Retenu ? |
|---|---|---|---|---|---|
| a | `t="str"` : entités décodées | valeur lue **différente** | oui (valeur brute) | interne seul, ou les deux (retouche `openxlsx`) | selon le choix (§ 6) ; **non** si « limite consignée » |
| b | `<rPh>` ignoré (chaîne partagée) | `xtZZ` → `xt` ; `abcZZ` → `abc` | en-tête attendu : **refusé → accepté** ; colonne ignorée / texte du corps : valeur différente | interne | selon le choix |
| c | `<rPh>` en chaîne en ligne | `xtZZ` → `xt` (interne) ; `X2` côté `openxlsx` non retouchable | idem (interne) | interne | selon le choix |
| d | `r=""` refusé (motif de classe `usp_refus_lecture`) | erreur brute → refus motivé ; **accepté → refusé** pour `<c r="" s=…/>` sans valeur côté `openxlsx` | **un cas rare** (`openxlsx`) | les deux | oui (cœur de l'issue) |
| e | refus étendu aux références `"1"`, `"A0"`, `"1A"`, `" A2 "` | **accepté → refusé** (valeur perdue ou déplacée aujourd'hui) | oui | les deux | hors liste de l'issue ; à trancher |
| f | commentaire d'en-tête corrigé | aucun | — | — | oui |
| g | blancs d'en-tête sous Windows | aucun (limite) | — | — | limite |

Effet attendu sur un calcul : aucun mesuré. Le critère « `coder-approfondi` d'office si un fichier aujourd'hui accepté change de valeur ou devient refusé » est **atteint à la lettre** par (a) si décodé, (b)/(c), (d) (`<c r="" s=…/>` sur `openxlsx`) et (e) ; il n'est **pas** atteint par la seule version « consigner `t="str"` comme limite + refuser `r=""` partout où une valeur est portée + commentaire + limite Windows ». À décider par la session et `actuary` (§ 6).

### 1.7 Parité sous une autre version d'`openxlsx` — [M]

Les cas `t="str"`, `rPh`, `r` invalide et chaîne enrichie donnent **des résultats identiques** sous `openxlsx` **4.2.5.2** (avec `zip` 2.3.1) et 4.2.9 (`diff` des sorties vide, `old_557*.R` / `sortie_old_557*.txt`). Voir § 5 pour la raison du choix de 4.2.5.2.

---

## 2. #540 — MW-03 et MW-04 — [M]

Commande : `LC_ALL=C.UTF-8 Rscript mesure_540.R` (`sortie_540.txt`) ; triangles de la forme `(100+i+j)·1,3^j`, `run_engine(methode = "reserve2", B = 99)`.

| Cas | Motifs de `mw_valider_triangle()` (et de `run_engine()` : `ok = FALSE`, `validation$erreurs`, identiques) |
|---|---|
| Carré 8 × 8 | aucun (`ok = TRUE`, I = J = 7) ; `run_engine()` : `ok = TRUE` |
| **Triangle 6 × 8** (6 lignes, 8 colonnes : I = 5 < J = 7) | **deux motifs** : (1) « D(2)(e) : le nombre d'annees d'accident ne peut etre inferieur au nombre d'annees de developpement. » (2) « Triangle non carre (6 annees d'accident, 8 annees de developpement) : cas non couvert par les formules des paragraphes 4 et 5 de la section D de l'annexe XVII. » |
| **Trapèze 8 × 6** (I = 7 > J = 5) | **un motif** : « Triangle non carre (8 annees d'accident, 6 annees de developpement) : cas non couvert par les formules des paragraphes 4 et 5 de la section D de l'annexe XVII. » |
| Trapèze 6 × 5 | même motif, « (6 annees d'accident, 5 annees de developpement) » |
| 5 × 6 | deux motifs (D(2)(e) + non carré), comme 6 × 8 |

R-1 (MW-04 seulement si I > J) est donc **confirmé nécessaire** : I < J reçoit aujourd'hui les deux motifs [M].

**Code** [L] : `R/engine.R` l. 10066-10071 (MW-03 `if (nrow(tri) < ncol(tri))`, MW-04 `if (I != J)`).

**Tests qui citent MW-04** [L, `tests/unitaires/test_controles_entree.R`] :
- l. 1612-1617 : trapèze 6 × 5, `contient(... "non carre")` et `"paragraphes 4 et 5"` ;
- l. 1618-1622 : 5 × 6 (I < J), ne teste que `D(2)(e)` (resterait vraie ; aucune assertion de l'absence de MW-04) ;
- l. 1664-1668 : `run_engine()` 8 × 6, **texte complet** du motif (identique au bit) ;
- l. 2135-2138 : `engine_lire_triangle()` 8 × 7, `startsWith(e, "Triangle non carre (8 annees d'accident, 7 annees de developpement)")` ;
- l. 2068 et 2121 (libellés), l. 8 (en-tête du fichier) : mentions seules.
Aucun autre fichier de tests, ni `app.R`, ne cite le texte (`grep -rn "paragraphes 4 et 5\|cas non couvert\|MW-04"` hors docs). [M]

**`.tex`** [L, `docs/latex/doc_tests_usp.tex`, `HEAD`] : l. 4781 (tableau « Géométrie carrée », « Restriction d'implémentation »), l. 14677 (encadré : « Le moteur impose donc $I = J$ (triangle carré) et refuse explicitement les autres géométries »), l. 17643 (fiche `mw:m6sig` : « sous la contrainte $I = J$ imposée par `mw_valider_triangle()` »). Autres passages qui supposent le carré, **non cités dans la fiche** : l. 1676 (« un triangle carré à première colonne complète, seul admis »), l. 5041 (« un triangle non carré ou incomplet ne permet pas d'appliquer les formules »), l. 7480 (« le triangle étant carré »).

**ADR 0005** [L] : l. 70 (puce « Géométrie I > J », annotée du 13/11/2026) et l. 150-158 (annotation du 13/11/2026, qui impose le texte de R-2 et « Le motif … n'est émis que si I > J »). Présentes dans `HEAD` (`e3ebb84`). Autre document qui cite l'ancien texte : `docs/specifications/fm-merz-wuthrich-restitution.md` l. 304 (« Triangle non carre (I = %d, J = %d) … ») : ancien libellé, non listé dans la fiche.

**Références** : « non carre » et « D(2)(e) » absents des six `.rds` de `tests/reference/` [M] (boucle `readRDS` + `grepl`) : aucune référence n'est touchée.

---

## 3. #556 — refus d'import et exports

### 3.1 Formes de refus d'import dans `app.R` — [L] + [M]

Mesure par `shiny::testServer` (`mesure_556b.R`, `sortie_556b.txt`) : pour chaque cas, `statut_import()$msg`, notifications relevées, données conservées (`identical(donnees(), avant)`, `identical(triangle(), avant)`).

| Forme | Où ([L] `app.R`) | Texte du statut | Notification | Dit « conservées » ? | Cas mesuré |
|---|---|---|---|---|---|
| A. fichier illisible | `lire_tableau()` l. 237-258, observateur l. 1268-1273 | « Fichier faux.xlsx (XLSX) illisible comme classeur Excel : verifier … » (`MESSAGE_ILLISIBLE`) | « Import refuse : fichier illisible. » | **non** | xlsx faux ; CSV à ligne plus longue que l'en-tête |
| B. refus motivé du lecteur (`usp_refus_lecture`) | l. 255-256, 1268-1273 | « Fichier ligne1.xlsx (XLSX) refuse. <texte du moteur> » | « Import refuse. » | **non** | ligne 1 vide ; cellule sans `r` |
| C. validation du moteur après lecture | l. 1276-1281 (triangle), 1313-1316 (séries) | `paste(erreurs, collapse = " ")` **sans nom de fichier ni préfixe** : « Colonne(s) manquante(s) : yt. … », « Triangle non carre (8 … 6 …) … », « Certaines valeurs … ne sont pas numeriques … » | « Import refuse. » | **non** | séries sans `yt` ; valeur non numérique ; trapèze 8 × 6 |
| D. refus de dimension | l. 1283-1295, 1317-1327 | « Fichier long60.csv (CSV) : <motif> Import refuse, **series courantes conservees**. » (ou « triangle courant conserve ») | « Import refuse. » | **oui** (seule forme) | 60 années ; triangle 41 × 41 |

Données courantes effectivement conservées dans les neuf cas : `donnees conservees : TRUE`, `triangle conserve : TRUE` [M]. Les formes se distinguent donc par le texte (nom de fichier présent en A, B, D, absent en C ; ponctuation « refuse. » / « : » ; majuscule) et par la mention de conservation (D seule), non par le comportement. Les deux notifications diffèrent (« Import refuse. » / « Import refuse : fichier illisible. »). Rendu : un seul `<div class="err">` (`statut_ui()`), identique pour les quatre. Une cinquième forme existe **au démarrage** (`charger_ln()` l. 263, `charger_mw()` l. 293) : « present mais refuse au demarrage : … » + `REFUS_DEMARRAGE` [L, non mesurée ici] ; elle n'est pas dans le constat de l'issue.

Non-refus voisins [L] : « Triangle importe, avec des avertissements : voir le statut d'import. » (l. 1307), « Donnees importees, mais non valides : … » (l. 1349).

### 3.2 Les cinq `downloadHandler` — [L] + [M]

[L] `app.R` : `dl_rapport` (l. 1940), `dl_tests` (1948), `dl_calib` (1952), `dl_donnees_xlsx` (1973), `dl_donnees` (1980) ; **aucun** ne contient `tryCatch` ni notification ; l'échec d'un `content` est celui de shiny (erreur R). [M] `grep -c "tryCatch" app.R` : 1, dans `lire_tableau()` (l. 237).

Causes d'échec prévues dans le code [L] : `engine_ecrire_xlsx()` sans paquet `zip` ni commande `zip` (`stop(... call. = FALSE)`, `R/engine.R` l. 8321-8325), échec de `zip::zipr()` **et** de `utils::zip()` (l. 8401-8409) ; `rapport_html()` (`stop()` l. 3147, 3151, 3253…). Les écritures CSV (`write.csv`, `engine_ecrire_csv`) n'ont pas de cause d'échec dédiée.

**Mesure sans `zip`** (`R_ZIPCMD=zip_inexistant`, paquet `zip` absent de la bibliothèque, application lancée par `shiny::runApp()`, requête `GET` sur le lien de téléchargement par Playwright, `sortie_556c.txt`) :
- `dl_donnees` (CSV) : HTTP **200**, `text/csv`, 133 octets ;
- `dl_donnees_xlsx` : HTTP **500**, `text/html`, 301 octets ; corps : page « An error has occurred! » contenant « Ecriture du fichier .xlsx impossible : ni le paquet R zip ni la commande zip du systeme ne sont disponibles (installer le paquet zip, ou openxlsx qui l'importe). » ; le clic réel enregistre un fichier **`dl_donnees_xlsx.html`** ; **aucune notification** dans l'application (seule une notification antérieure, étrangère, était présente) ; la cause figure dans la console R (« Warning: Error in : Ecriture… »).
- Seuls deux liens existent avant tout résultat (`dl_donnees`, `dl_donnees_xlsx`) ; les trois autres (`dl_rapport`, `dl_tests`, `dl_calib`) n'ont pas été cliqués : **non mesurés** (aucun échec prévu ; je n'ai pas forcé d'échec de `rapport_html()`).

Sans le moteur modifié, le texte de la cause est déjà **dans le moteur** (`stop()` à message fixe) : une notification n'exige pas de nouveau texte de moteur [L].

---

## 4. #566 — impression des graphiques plotly — [M]

**Rendu réel possible** : `shiny` 1.14.0 et `plotly` 4.12.1 installés dans le scratchpad (la CI : 1.8.0 / 4.10.4 : écart de versions), application lancée par `shiny::runApp()`, Chrome for Testing 153 via Playwright, `page.pdf({ format: 'A4', landscape, printBackground: true })` (même appel que R44 : « Chromium, `page.pdf()` A4 » [L, corps de la PR #564]).

Parcours : pour chacune des trois méthodes de calcul (`premium` avec nature « brutes », `reserve1`, `reserve2`), `B = 99`, clic sur « Relancer les calculs », puis chaque sous-onglet de « Graphiques » (6 par méthode) et l'onglet « Calibration » (`g_calib`) : **7 onglets × 3 méthodes × 2 orientations = 42 PDF** (`impression/*.pdf`).

**Ce qu'est « les trois méthodes »** : la PR #564 appelle « méthode » `premium`, `reserve1`, `reserve2` (tableau « Méthode / orientation »), mesurées **toutes en Chromium `page.pdf()`** ; son corps ne décrit pas trois méthodes d'impression distinctes (« seul Chromium a été mesuré »). L'issue #566 dit « les trois méthodes d'impression vérifiées pour R44 » : je l'ai lu comme les **trois méthodes de calcul**. Ambiguïté à lever (§ 6).

**Résultats** :
- Balayage des pixels (72 dpi, `rognage2.py`, `sortie_566_pdf.txt`) : **portrait : 21 / 21 PDF** ont du contenu **jusqu'au bord utile droit** (marge `@page` de 10 mm, 567 pt sur 596) ; **paysage : 11 / 21**. Un contenu au bord est une condition nécessaire du rognage, non suffisante.
- Lecture des rendus [M, images lues] : en portrait, « H3 - normalite » (graphique pleine largeur, 1 170 px à l'écran) : la bande d'enveloppe et l'axe s'arrêtent au bord de page, **dernière graduation absente** ; « H2 - variance » : le graphique pleine largeur « Résidus standardisés vs volume » est coupé à droite (dernier point au bord) ; en paysage, « Surface objectif » : le graphique « Coupe à gamma optimal » est coupé à droite, alors que « H3 - normalite » en paysage est entier. **Le défaut existe donc aussi en paysage** (onglets à deux colonnes ou à graphique large), ce que le critère de l'issue (« A4 portrait et paysage ») couvre.
- Mesure DOM, `emulateMedia('print')` à la taille de la page (794 × 1123 px, puis 1123 × 794), `dom_impression.js` / `sortie_566_dom.txt` : le bord droit du `<svg>` de plotly vaut **779 px pour une limite de 756 px** (page moins 2 × 38 px), en portrait comme en paysage (1 108 contre 1 085), soit **+23 px** ; 29 graphiques sur 43 dépassent dans chaque orientation. Cette mesure est **indicative** (la mise en page réelle de `page.pdf()` n'est pas celle d'une fenêtre de la taille de la page) ; les PDF font foi.
- Largeurs à l'écran, **référence avant correction**, `premium` (`ecran_ref_premium.json`) : à 960 px : 330 + 330 / 690 ; à 1 600 px : 570 + 570 / 1 170, « Surface objectif » 670 / 470 / 470. À comparer après P7.

**Non mesuré** : Firefox / WebKit ; impression par la boîte de dialogue du navigateur (non `page.pdf()`) ; versions `shiny` 1.8.0 / `plotly` 4.10.4 de la CI.

---

## 5. #565 — CI

### 5.1 `.github/workflows/ci.yml` — [L]

- `changements` (l. 30) ; trois lots `tests-unitaires` (l. 114-276, `matrix.lot: [1, 2, 3]`, `total: 3`) ; `reproductibilite` (l. 278) ; `ecarts-references` (l. 330) ; agrégat `tests-moteur` « Tests du moteur (unitaires, reproductibilité) » (l. 359, `needs: [changements, tests-unitaires, reproductibilite]`) ; `documentation` ; `fiches-agents`.
- `shiny` 1.8.0 et `plotly` 4.10.4 : étapes « Bibliothèque des paquets R de l'application », cache `actions/cache` (clé : OS, arch, R, `ppm`, versions), « Paquets R de l'application (shiny, plotly), versions épinglées » (`install.packages` depuis `https://packagemanager.posit.co/cran/__linux__/jammy/2024-02-15`), « Contrôle des paquets R de l'application » (bloquant, processus R neuf, `packageVersion` identique à `VERSION_SHINY` / `VERSION_PLOTLY`) ; **dans chaque lot** (l. 105-113 : le lot 1 « seul » contient les fichiers qui exigent `shiny` / `plotly`, mais l'installation est dans les trois).
- **Aucun** `openxlsx` ni `zip` dans `ci.yml` ([M] `grep -n "openxlsx\|zip" .github/workflows/ci.yml` : aucune occurrence).
- Le lanceur `tests/test_unitaires.R` n'accepte que `--parallele[=N]` et `--lot=k/n` ([L] l. 56-66) : **pas d'option de sélection de fichiers**. Un job dédié devrait soit lancer `Rscript tests/unitaires/<fichier>.R` fichier par fichier (mesuré possible : les trois fichiers ont tourné ainsi, `LC_ALL=C.UTF-8`, exit 0), soit ajouter une option au lanceur (hors périmètre de la fiche).
- L'agrégat `tests-moteur` (vérification requise des rulesets) n'attend que les lots et la reproductibilité : un job nouveau n'y est **pas requis** s'il n'y est pas ajouté ([L] l. 359-385).

### 5.2 Tests qui sautent sans `openxlsx` ou `zip` — [M]

Journaux de la CI sur `8205955` (exécution n° 43397172725, `gh api actions/jobs/<id>/logs`) et rejeu local sous `LC_ALL=C.UTF-8` sans les deux paquets (la commande `zip` présente) : **identiques**.

| Fichier (lot) | Lignes `[saute]` | Condition |
|---|---|---|
| `test_controles_entree.R` (lot 2) | 6 : lignes vides #483, chemin `openxlsx` ; colonne `i` et doublons #555, chemin `openxlsx` ; export xlsx #488, voie du paquet `zip` ; export xlsx #488, lecture par `openxlsx` ; divergence `&`, `<`, `>` et logique #488, chemin `openxlsx` ; repli de `zip::zipr()` #488 | `openxlsx` absent (4), `zip` absent (2) |
| `test_outdec.R` (lot 3) | 1 : « engine_lire_xlsx() par openxlsx : paquet absent » | `openxlsx` absent |
| `test_application.R` (lot 1), `test_defauts_connus.R` (lot 3) | **aucune** ligne de saut en CI (la commande `zip` suffit) | — |

Total : **7 lignes** en CI (lot 2 : 6 ; lot 3 : 1 ; lot 1 : 0), conforme à l'issue. Les assertions passent de 96 à **97** (`test_outdec.R`) et de 391 à **403** (`test_controles_entree.R`) quand les deux paquets sont présents, `test_defauts_connus.R` 127 / 127 : **+13 assertions** [M, `TOTAL` des journaux locaux].

**Branches exercées sans le dire** [L] : `test_application.R` l. 582-604 et 947-970 choisissent `zip::zipr()` si le paquet est présent, `utils::zip()` sinon, **sans ligne de saut** ; `test_outdec.R` l. 283 (`peut_ecrire439`) et `test_defauts_connus.R` l. 1642 testent « paquet ou commande ». « Aucune ligne `[saute] … openxlsx` dans le job dédié » ne prouve donc pas que la voie `zip::zipr()` de ces deux fichiers est exercée ; celle de `test_controles_entree.R` l. 4814 (« repli de `zip::zipr()` ») l'est.

### 5.3 Versions de l'instantané — [M] + [H]

`DATE_INSTANTANE = 2024-02-15`. D'après les dates de l'archive CRAN ([M], `curl` sur `cran.r-project.org/src/contrib/Archive/…`) : `openxlsx` 4.2.5.2 (06/02/2023) était la dernière version ce jour-là (4.2.6 : 23/07/2024), `zip` 2.3.1 (27/01/2024) (3.0.0 : 10/06/2026). **[H]** : un instantané Posit du 15/02/2024 contiendrait ces versions (Posit Package Manager inaccessible depuis la session, 403 : non vérifié). Or le code et ses tests citent des mesures « openxlsx 4.2.9 ». **Mesure de contrôle** : avec `openxlsx` 4.2.5.2 + `zip` 2.3.1 installés depuis l'archive CRAN dans le scratchpad, `test_outdec.R` : 97 / 97 et `test_controles_entree.R` : 403 / 403, 0 saut, exit 0 [M], et les cas de § 1 donnent des sorties identiques à 4.2.9. Les tests de parité passent donc aux deux versions ; le choix de l'instantané (ou d'un autre) reste à décider.

---

## 6. Tableau constat → état mesuré → reste à faire

| Issue | Constat (fiche / issue) | État mesuré | Reste à faire |
|---|---|---|---|
| #557 | `t="str"` non décodé par les deux chemins | **valeur lue brute** sur les deux chemins, **entités non décodées** ; non perdue [M] | décoder (changement de valeur hors références, parité à construire) **ou** consigner comme limite ; test de parité |
| #557 | `<rPh>` non traité | l'interne **concatène** le texte phonétique (`xtZZ`), `openxlsx` l'ignore (chaîne partagée) mais **perd l'en-tête** d'une chaîne en ligne (`X2`) [M] | ignorer `rPh` dans `.xml_textes()` (interne) ; décider du cas « chaîne en ligne » (limite ou refus) |
| #557 | `r=""` non refusé | **erreur R brute** sur les deux chemins (sauf cellule de style sans valeur lue par `openxlsx`) ; **références voisines** (`"1"`, `"A0"`, `"1A"`, `" A2 "`) lues avec **valeur perdue ou déplacée** [M] | refus motivé (classe `usp_refus_lecture`) de `r=""` ; décider de l'extension aux références voisines |
| #557 | commentaire d'en-tête inexact | exact pour le corps (`NA`), **inexact pour l'en-tête** (nom `X<col>`) [M] | corriger le commentaire (l. 8778-8779) |
| #557 | blancs d'en-tête sous Windows non mesurés | parité mesurée sous `C.UTF-8` et `C` sur 7 blancs ; Windows **non mesurable** ici | consigner comme limite, ou mesure sur le poste du mainteneur |
| #540 | MW-04 si I ≠ J ; R-1, R-2 | I < J : **deux motifs** ; I > J : un ; carré : aucun [M] | MW-04 si I > J seulement ; texte unifié ; 4 tests de `test_controles_entree.R` (l. 1612-1617, 1664-1668, 2135-2138 ; 1618-1622 à compléter) ; `.tex` l. 4781, 14677, 17643 (+ l. 1676, 5041, 7480) ; ADR 0005 déjà annoté |
| #556 | quatre formes de refus, conservation non dite | **quatre formes confirmées** (illisible ; refus du lecteur ; validation du moteur ; dimension), **seule la dernière dit « conservées »** ; données effectivement conservées dans les neuf cas [M] | forme unique incluant « données conservées » ; test `test_application.R` (l. 890-894, 934-937, 946-968, 1684-1694 citent les textes actuels) |
| #556 | échec d'export sans message | sans `zip` : HTTP **500**, page HTML « An error has occurred! » avec la cause, fichier téléchargé `dl_donnees_xlsx.html`, **aucune notification** ; aucun `downloadHandler` ne notifie [M, L] | notifier l'échec avec sa cause dans l'application (cause déjà fournie par le moteur) |
| #566 | graphiques plotly rognés à droite en portrait | **confirmé** (rendu réel, 42 PDF) ; **aussi en paysage** sur certains onglets [M] | règles `@media print` (largeur des conteneurs plotly), test des 42 PDF, écran à 960 et 1 600 px (référence relevée) |
| #565 | parités non exercées en CI | 7 lignes `[saute]` en CI (lot 2 : 6 ; lot 3 : 1) ; +13 assertions avec les paquets ; `test_application.R` et `test_defauts_connus.R` ne sautent pas [M] | job dédié ; branchement à `tests-moteur` ; choix de la version des paquets |

### Choix à trancher (non résolus par le rejeu)

1. **#557 `t="str"`** : limite consignée, décodage interne seul (rompt la parité), ou décodage des deux chemins par retouche de la sortie d'`openxlsx` (contraire à l'en-tête actuel).
2. **#557 `r`** : refuser `r=""` seul (périmètre de l'issue) ou toute référence hors `^[A-Za-z]+[1-9][0-9]*$` (change des fichiers acceptés avec valeur perdue ou déplacée ; plus sûr, plus large). Le segfault d'`openxlsx` observé une fois milite pour un refus en amont [H].
3. **#557 `<rPh>` en chaîne en ligne** : `openxlsx` perd l'en-tête (`X2`) : refuser, ou consigner comme limite.
4. **#557 recours à `coder-approfondi`** : dépend des choix 1 à 3 (§ 1.6).
5. **#540 R-2** : le texte proposé par `actuary` (quatre propositions, dont la citation de Merz et Wüthrich 2008, p. 546) est long pour un motif de refus à l'écran ; décider ce que porte le motif et ce que portent le `.tex` et l'ADR.
6. **#556** : forme unique : avec ou sans nom de fichier pour les erreurs de validation du moteur (forme C aujourd'hui sans nom) ; notification de l'échec d'export : texte de la cause tel quel (message du moteur) ou court ; traitement de la cinquième forme (démarrage).
7. **#566** : sens de « trois méthodes d'impression » ; versions `shiny` / `plotly` pour le rendu (écart avec la CI) ; Chromium seul.
8. **#565** : version de `openxlsx` et `zip` (instantané du 15/02/2024 ou autre) ; mode de lancement du job (fichier par fichier ou option du lanceur) ; ajout à l'agrégat `tests-moteur` ; `test_defauts_connus.R` et `test_application.R` dans le job.

---

## 7. Écarts avec la fiche

1. **`t="str"` « perdue »** (étape 4 : « une cellule `t="str"` aujourd'hui perdue et désormais décodée ») : la valeur est **lue brute**, seul le décodage des entités manque. Le texte de l'issue et le commentaire du code (« ne sont décodées par aucun des deux chemins ») sont exacts ; la formulation « perdue » de la fiche ne l'est pas.
2. **`r=""`** : la fiche et l'issue le traitent comme « non refusé » ; il est en réalité refusé… par une **erreur R brute** sur les deux chemins (sauf un cas rare côté `openxlsx`) ; et des références voisines non vides sont **acceptées avec perte ou déplacement de valeur**, constat absent de la fiche.
3. **`<rPh>`** : la fiche n'en mesure pas les effets ; mesuré : l'interne **ajoute** le texte phonétique au nom, `openxlsx` le perd (chaîne en ligne).
4. **Commentaire d'en-tête (#557)** : « rendue NA » n'est vrai que pour le corps ; l'en-tête devient `X<col>` [M].
5. **#556 « cinq exports sans `zip` »** (fiche, étape 1) : un seul des cinq peut échouer faute de `zip` (`dl_donnees_xlsx`) ; les quatre autres n'ont pas de cause d'échec dédiée dans le code (le rapport peut échouer par `stop()`, non exercé).
6. **#566 « trois méthodes d'impression »** : dans la PR #564, ce sont les trois méthodes de calcul, une seule méthode d'impression (Chromium `page.pdf()`).
7. **#566 « graphiques rognés en portrait »** : le rognage existe **aussi en paysage** sur certains onglets (« Surface objectif », onglets à deux colonnes).
8. **Numéros de lignes de la fiche** : `ci.yml` « l. 105-113, 160-241 » pour l'installation de `shiny` / `plotly` : le bloc va de l. 105 (commentaire) à 241, avec `env` à 144-146 ; non bloquant. MW-03 / MW-04 : l. **10066-10071** correct. `engine_lire_xlsx()` l. 8812 et `openxlsx` l. 8843 : corrects.
9. **#540, passages du `.tex`** : la fiche en cite trois (4781, 14677, 17643) ; trois autres supposent le carré (1676, 5041, 7480).
10. **#565** : « versions figées et contrôlées comme `shiny` et `plotly` » : l'instantané du 15/02/2024 donnerait `openxlsx` 4.2.5.2, non 4.2.9 (§ 5.3, [H] sur le contenu de l'instantané).

## 8. Points non mesurés

- Blancs d'en-tête sous Windows (aucun poste).
- Contenu réel de l'instantané Posit du 15/02/2024 (hôte inaccessible depuis la session).
- `shiny` 1.8.0 / `plotly` 4.10.4 (versions de la CI) : rendu et tests faits en 1.14.0 / 4.12.1.
- `test_application.R` en entier (non relancé) ; les trois autres `downloadHandler` (`dl_rapport`, `dl_tests`, `dl_calib`) non cliqués ; échec de `rapport_html()` non provoqué.
- Impression par Firefox / WebKit ; boîte de dialogue d'impression ; écran à 960 et 1 600 px **après** correction (référence avant relevée pour `premium` seulement).
- Effet bout en bout (jusqu'à `sigma_usp`) d'un changement de valeur lue par le lecteur : non mesuré ; les six cas ne passent pas par les lecteurs [L, fiche].
- Origine du segfault d'`openxlsx` (une occurrence sur deux exécutions de `mesure_557c.R`).
- `t="str"` dans la ligne 1 avec entité de blanc (`&#32;`) : le contrôle de la ligne 1 lit le texte brut des cellules `t="str"` (`R/engine.R` l. 8710 [L]) ; l'effet d'un décodage sur ce contrôle n'est pas mesuré [H].
