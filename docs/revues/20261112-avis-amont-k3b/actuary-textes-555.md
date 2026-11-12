# K3b, préparation de l'étape 8 (#555) : avis d'`actuary`

> *Avis de l'agent actuary (IA), fiche de base. K3b, préparation de l'étape 8 (#555), branche `claude/registre-restes`, tête `07624fe`, le 12/11/2026.* Versé intégralement par la session principale (Refs #555). L'agent n'a rien écrit dans le dépôt et n'a créé aucune issue.

Branche `claude/registre-restes`, tête `07624fe`. Je n'ai modifié aucun fichier et je n'ai créé aucune issue.

**Lu** :
- `docs/revues/20261112-avis-amont-k3b/` (les trois fichiers) et l'issue #555 ;
- `R/engine.R` : l. 7660-8040 (lecteurs, `.entete_absent()`, `.retirer_lignes_colonnes_vides()`, `engine_lire_donnees_csv()`, `engine_lire_triangle()`), l. 8550-8690 (`.xlsx_blancs_entete()`, lecteur interne, `make.unique`) ;
- `app.R` l. 240-252 (lecture CSV) ;
- `tests/unitaires/test_controles_entree.R` ;
- `.tex` l. 2279-2285, 3261-3264, 3872-3886, 4475-4490, 4962-4972, 5050-5056 ;
- annexe XVII, sections A à C, dans le consolidé `.xhtml` (texte courant, sans formule).

**Mesures** : `Rscript` sous `LC_ALL=C.UTF-8`, moteur chargé par `charger_moteur()`, script hors dépôt `/tmp/claude-0/-home-user-outil-usp/11470374-fa08-5db2-8048-a5adff065db9/scratchpad/m.R`. `openxlsx` n'est pas installé, donc seul le lecteur interne a été mesuré.

---

## 1. En-têtes `I` et ` i ` (décision 3)

### 1.1 Constats mesurés

| Cas | CSV (noms tels quels, `check.names = FALSE`) | Classeur (lecteur interne) |
|---|---|---|
| `i` | accepté | accepté |
| `I` | refusé : « D(2)(e) … » et « Triangle non carre (5 annees d'accident, 6 annees de developpement) … » | même refus |
| ` i ` | même refus | **déjà accepté** : `.xlsx_blancs_entete()` retire les blancs de bord, l'en-tête est lu `i` |
| `i` + `I` | même refus | même refus |
| `i` + `i` | même refus | lu `i, i.1` (`make.unique()` l. 8690), puis même refus |

Autres constats :
- **Colonnes de développement** : leur en-tête n'est jamais interprété. La sélection se fait par position (`df[, names(df) != "i"]`) ; seule la forme exacte `"i"` est comparée (l. 7845 env., 7979).
- **`.retirer_lignes_colonnes_vides()`** : la sélection de lignes garde les noms en double. C'est la sélection de colonnes `df[, !retirer]` qui renomme en `i.1` (mesuré).
- **Séries, colonne `t`** : `"t" %in% noms`, sans normalisation. Un en-tête `T` (deux chemins) ou ` t ` (CSV) est **ignoré sans message**. La série est alors lue dans l'ordre du fichier, sans tri ni contrôle de consécutivité (mesuré : `ok = TRUE`, xt = 2,1,3,…). σ_USP ne bouge pas, car la vraisemblance de B/C ne dépend pas de l'ordre. En revanche, les tests sensibles à l'ordre (H3) peuvent changer de verdict. C'est hors du périmètre de #555 : voir la décision 2.

### 1.2 Traitement fixé : reconnaître la colonne, puis appliquer la même règle

Motifs :
1. Pour ` i `, le classeur reconnaît déjà la colonne. Appliquer au CSV la même mise en forme, `.xlsx_blancs_entete()`, fait coïncider les deux chemins.
2. La colonne `i` n'est lue que pour être contrôlée. La reconnaître applique V1-V5, donc le contrôle qui protège d'une erreur silencieuse. Un refus dédié ne ferait que renvoyer l'utilisateur renommer la colonne.
3. `I` ne peut pas être l'en-tête d'une année de développement : celles-ci vont de 0 à J. Le risque de capter une vraie colonne de données est donc nul en pratique.

**Règle N** : un en-tête désigne la colonne `i` si, après retrait du BOM (`.nom_sans_bom()`, déjà fait), puis des blancs de bord de la classe `[[:space:]]` (`.xlsx_blancs_entete()`), il vaut `i` ou `I`.
- Un nom `NA` ou non UTF-8 ne désigne jamais `i`. Prévoir la garde `validUTF8()`, comme dans `.ligne1_sans_valeur()`.
- L'espace insécable U+00A0 n'est pas un blanc : il n'est pas retiré, comme ailleurs dans le moteur.

**Étape A**, sur les noms reçus : après `MOTIF_LIGNE1_VIDE`, avant `.retirer_lignes_colonnes_vides()`.
- Plus d'un en-tête désigne `i` : refus H1, retourné seul.
- Sinon, l'unique colonne désignée est renommée `"i"`, sa forme canonique. Le code en aval (`names(df) == "i"`, règle du bord gauche de #520, retrait de la colonne) reste ainsi inchangé.
- Interactions : `i` + `I`, `i` + ` i `, ` i ` + `I` → H1. Un seul `I` → accepté, puis V1-V5.

**Exigence de parité** (choix d'implémentation laissé à `coder` et `audit`) : H1 doit être détecté de la même façon sur les deux chemins du classeur.
- Aujourd'hui, le lecteur interne rend `i, i` (ou `i` + ` i `) sous la forme `i, i.1`, ce qui échappe à H1.
- `openxlsx::read.xlsx(check.names = FALSE)` ne déduplique pas dans son code R (source `readWorkbook.R` consultée). Son code C++ n'a pas été vérifié.
- Piste : retirer `make.unique()` du lecteur interne, puis vérifier l'effet sur les séries, où `df$xt` lit déjà la première occurrence.
- Critère : un classeur `i, i` lu par le lecteur interne reçoit le texte H1 ci-dessous, en-têtes cités tels que lus, sans `i.1`.

### 1.3 Texte H1 (remplace celui du tableau de l'avis amont)

Les deux `%s` sont remplis par `liste()` : d'abord les positions des colonnes dans le tableau reçu, puis `liste(.echapper_texte(noms bruts))`, comme pour #550.

`En-tete de la colonne i present plusieurs fois (colonnes %s, d'en-tetes %s) : la colonne i, facultative, porte l'annee d'accident de chaque ligne et ne peut figurer qu'une fois (en-tete i ou I, blancs de bord ignores) ; retirer ou renommer la colonne en trop.`

Les textes V1 à V4 de l'avis amont et V5 (décision 5) restent inchangés. Ils s'appliquent à la colonne reconnue, quelle que soit la forme de son en-tête.

**Option écartée (b)**, refus dédié, si le mainteneur la préfère. Texte : `En-tete %s non reconnu (colonne %s) : la colonne facultative de l'annee d'accident s'intitule i, en minuscule et sans blanc de bord ; corriger l'en-tete, ou retirer la colonne.` Pour ` i `, elle ne viserait que le CSV, le classeur l'acceptant déjà : la divergence entre les deux chemins resterait (même schéma que D3).

**Tests à prévoir** :
- `I` seul → accepté, triangle identique à celui obtenu avec `i` ;
- ` i ` en CSV → accepté, identique au classeur ;
- `i` + `I`, et `i` + `i` sur les deux chemins → H1 seul ;
- `I` à valeurs répétées → V3 ;
- nom `NA` → en-tête absent (décision 2).

---

## 2. Motifs qui citent « (2)(b) … exige des annees consecutives » (décision 6)

### 2.1 Ancrage

**Triangle**, comme V5 (décision 5) : D(1) « chaque année d'accident », D(3)(a) « nombres consécutifs, commençant par 0 », D(3)(b) « I ».

**Séries** (lu dans le consolidé) :
- B(3)(a) : « les années d'accident sont représentées par des nombres consécutifs, commençant par 1 pour la première année d'accident pour laquelle des données sont disponibles » ; B(3)(b) : « T représente la dernière année d'accident » ;
- C(3)(a) : « les exercices sont représentés par des nombres consécutifs, commençant par 1 » ; C(3)(b) : « T représente le dernier exercice ».
- B(1) dit « séparément pour chaque année d'accident », mais C(1) dit seulement « pour des exercices différents ». Je ne cite donc pas (1) pour les séries : le lecteur est commun à B et C, et « chaque » ne serait pas littéral pour C.
- B(2)(b) (« cinq années d'accident consécutives au moins ») et C(2)(b) (« cinq exercices consécutifs au moins ») ne sont pas cités pour un trou.
- La présomption est attribuée à l'outil par « presumee » (messages) ou « lecture retenue par l'outil » (commentaires, `.tex`).

### 2.2 Tableau site → texte actuel → texte fixé

**`R/engine.R`, messages.** Ces textes sont produits par `sprintf` ; le texte fixé est celui du message rendu, et `coder` adapte la variable `texte` (l. 7811-7812).

| Site | Texte actuel | Texte fixé |
|---|---|---|
| l. 7811 (`texte`, séries), rendu en ligne vide **en tête** | `Ligne(s) vide(s) en tete, sous l'en-tete (ligne(s) de donnees %s) : une ligne vide est refusee comme annee manquante presumee ; l'annexe XVII, B(2)(b) et C(2)(b), exige des annees consecutives. Renseigner l'annee manquante ou retirer la ligne vide.` | `Ligne(s) vide(s) en tete, sous l'en-tete (ligne(s) de donnees %s) : une ligne vide est refusee comme annee manquante presumee ; les annees d'accident (annexe XVII, section B) ou exercices (section C) sont numerotes par des nombres consecutifs de 1 a T (B(3)(a) et (b), C(3)(a) et (b)). Renseigner l'annee manquante ou retirer la ligne vide.` |
| idem, ligne vide **intercalée** | `Ligne(s) vide(s) intercalee(s) (ligne(s) de donnees %s) : une ligne vide est refusee comme annee manquante presumee ; l'annexe XVII, B(2)(b) et C(2)(b), exige des annees consecutives. Renseigner l'annee manquante ou retirer la ligne vide.` | `Ligne(s) vide(s) intercalee(s) (ligne(s) de donnees %s) : une ligne vide est refusee comme annee manquante presumee ; les annees d'accident (annexe XVII, section B) ou exercices (section C) sont numerotes par des nombres consecutifs de 1 a T (B(3)(a) et (b), C(3)(a) et (b)). Renseigner l'annee manquante ou retirer la ligne vide.` |
| l. 7812 (`texte`, triangle), ligne vide **en tête** | `Ligne(s) vide(s) en tete dans le triangle, sous l'en-tete (ligne(s) de donnees %s) : une ligne vide est refusee comme annee d'accident manquante presumee ; l'annexe XVII, D(2)(b), exige des annees d'accident consecutives. Renseigner l'annee d'accident manquante ou retirer la ligne vide.` | `Ligne(s) vide(s) en tete dans le triangle, sous l'en-tete (ligne(s) de donnees %s) : une ligne vide est refusee comme annee d'accident manquante presumee ; le triangle de l'annexe XVII, section D, porte les montants de chaque annee d'accident, numerotees par des nombres consecutifs de 0 a I (D(1), D(3)(a) et (b)). Renseigner l'annee d'accident manquante ou retirer la ligne vide.` |
| idem, ligne vide **intercalée** | `Ligne(s) vide(s) intercalee(s) dans le triangle (ligne(s) de donnees %s) : une ligne vide est refusee comme annee d'accident manquante presumee ; l'annexe XVII, D(2)(b), exige des annees d'accident consecutives. Renseigner l'annee d'accident manquante ou retirer la ligne vide.` | `Ligne(s) vide(s) intercalee(s) dans le triangle (ligne(s) de donnees %s) : une ligne vide est refusee comme annee d'accident manquante presumee ; le triangle de l'annexe XVII, section D, porte les montants de chaque annee d'accident, numerotees par des nombres consecutifs de 0 a I (D(1), D(3)(a) et (b)). Renseigner l'annee d'accident manquante ou retirer la ligne vide.` |
| l. 7967-7968 (colonne `t`) | `Colonne t : annees non consecutives (%s) ; l'annexe XVII, B(2)(b) et C(2)(b), exige des annees consecutives.` | `Colonne t : annees non consecutives (%s), annee manquante presumee ; les annees d'accident (annexe XVII, section B) ou exercices (section C) sont numerotes par des nombres consecutifs de 1 a T (B(3)(a) et (b), C(3)(a) et (b)).` |

**`R/engine.R`, commentaires** (sans accents).

| Site | Texte actuel | Texte fixé |
|---|---|---|
| l. 7676-7678 | `entiere, sans doublon et CONSECUTIVE (annexe XVII, B(2)(b) : "cinq` / `annees d'accident consecutives" ; C(2)(b) : "cinq exercices` / `consecutifs") ; elle est alors triee en croissant.` | `entiere, sans doublon et CONSECUTIVE (lecture de l'outil : annexe XVII,` / `B(3)(a)-(b) et C(3)(a)-(b), annees d'accident ou exercices numerotes par` / `des nombres consecutifs de 1 a T ; B(2)(b) et C(2)(b) n'exigent que "cinq` / `[...] consecutives au moins" (resp. "consecutifs"), controle de` / `profondeur distinct) ; elle est alors triee en croissant.` |
| l. 7696-7698 | `consecutives (series : annexe XVII, B(2)(b) et C(2)(b) ; triangle :` / `D(2)(b)). Positions citees ...` | `consecutives (lecture de l'outil ; series : annexe XVII, B(3)(a)-(b) et` / `C(3)(a)-(b) ; triangle : D(1) et D(3)(a)-(b)). Positions citees ...` |

**`R/engine.R`, sites fidèles, inchangés** (ils citent « au moins 5 » ou la profondeur) :
- l. 354 ;
- l. 1316-1317 (nom de test « Profondeur minimale (annexe XVII, B/C(2)(b)) », présent dans cinq `.rds`) ;
- l. 8885-8886, 9003, 9017-9018 ;
- l. 9871 (« D(2)(b) : au moins %d annees d'accident consecutives (%d fournies). ») ;
- l. 776, 911 et 1188-1190, qui parlent d'années à quatre chiffres consécutives (ligne d'en-têtes, H2), sans renvoi réglementaire.

**`app.R` et `R/display_helpers.R`** : aucune occurrence (grep).

**`tests/unitaires/test_controles_entree.R`**

| Site | Texte actuel | Texte fixé |
|---|---|---|
| l. 1800-1801 (commentaire) | `# Avis d'actuary du 24/09/2026 : annexe XVII, B(2)(b) et C(2)(b), annees` / `# consecutives ; doublon, trou, annee non entiere ou manquante : refus.` | `# Avis d'actuary du 24/09/2026 : annees consecutives (lecture de l'outil,` / `# annexe XVII, B(3)(a)-(b) et C(3)(a)-(b)) ; doublon, trou, annee non` / `# entiere ou manquante : refus.` |
| l. 1982 (libellé) | `"Lignes vides (#483) : ligne vide intercalee dans des series sans t refusee, motif citant B(2)(b) et C(2)(b)"` | `"Lignes vides (#483) : ligne vide intercalee dans des series sans t refusee, motif citant B(3)(a) et (b), C(3)(a) et (b)"` |
| l. 1986 | `contient(r$erreurs, "B(2)(b) et C(2)(b)")` | `contient(r$erreurs, "(B(3)(a) et (b), C(3)(a) et (b))") && !contient(r$erreurs, "(2)(b)")` |
| l. 2031 (libellé) | `"... triangle a ligne vide intercalee refuse (colonne i comprise), D(2)(b) cite, CSV texte compris"` | `"... triangle a ligne vide intercalee refuse (colonne i comprise), D(1) et D(3)(a)-(b) cites, CSV texte compris"` |
| l. 2037 | `contient(r$erreurs, "D(2)(b)")` | `contient(r$erreurs, "(D(1), D(3)(a) et (b))") && !contient(r$erreurs, "D(2)(b)")` |
| nouveau test | — | `identical()` du message de la colonne `t` à trou (cas `b` de la l. 1805) avec le texte fixé ci-dessus |

Les sites suivants sont fidèles ou indépendants du texte corrigé, et ne changent pas : l. 9, l. 30, l. 1251-1261 et 1278, l. 1607-1610 et 1862 (motif fidèle de la l. 9871), l. 1809, 2013 et 3582 (« non consecutives », toujours présent), l. 3911 et 3935 (H2).

**`docs/latex/doc_tests_usp.tex`** : texte à appliquer par `docwriter` en fin de branche (règle 9), avec les accents.

| Ligne | Texte actuel | Texte fixé |
|---|---|---|
| 3879 | `comme année d'accident manquante présumée (D(2)(b)), une colonne vide intercalée ou portant un` | `comme année d'accident manquante présumée (D(1), D(3)(a) et~(b)~: montants indiqués pour chaque année d'accident, années d'accident représentées par des nombres consécutifs de~0 à~$I$~; lecture retenue par l'outil), une colonne vide intercalée ou portant un` |
| 4480-4481 | `si la colonne $t$ est présente, exige des années entières, finies, sans doublon et consécutives` / `(annexe~XVII, B(2)(b) et C(2)(b)), puis range les lignes par $t$ croissant~;` | `si la colonne $t$ est présente, exige des années entières, finies, sans doublon et consécutives` / `(lecture retenue par l'outil~: annexe~XVII, B/C(3)(a) et~(b), années d'accident ou exercices représentés par des nombres consécutifs de~1 à~$T$), puis range les lignes par $t$ croissant~;` |
| 4485 | `est refusée, avec ou sans colonne~$t$, comme année manquante présumée (B(2)(b) et C(2)(b)), par` | `est refusée, avec ou sans colonne~$t$, comme année manquante présumée (B/C(3)(a) et~(b), même lecture), par` |
| 4967 | `La consécutivité des années de B/C(2)(b) n'est` | `La consécutivité des années (B/C(3)(a) et~(b), lecture retenue par l'outil~; B/C(2)(b) n'exige que cinq années consécutives au moins) n'est` |

Sites fidèles, inchangés : l. 2282-2283, 3263, 4141, 4719, 5054 (profondeur minimale ou convention de notation). La l. 4597 est un littéral de code (H2), sans rapport.

**Références** : vérifié avec `readRDS()` sur les six `.rds`. Le seul texte qui contient « (2)(b) » est le nom de test fidèle « Profondeur minimale (annexe XVII, B/C(2)(b)) » (cinq `.rds` sur six, aucun dans `reserve2.rds`). Les références restent donc identiques (`--seuil 0`) ; aucun σ_USP, aucune p-value, aucun verdict ne change.

---

## Décisions à soumettre au mainteneur

1. **En-têtes `I` et ` i ` : traitement (a), reconnaissance.** Je le fixe sur délégation (décision 3), mais un fichier jusqu'ici refusé (`I`, ou ` i ` en CSV) sera désormais calculé, sous V1-V5. Aucun fichier accepté aujourd'hui ne change. À signaler dans la PR. Si le mainteneur préfère conserver la règle des noms lus tels quels, l'option (b) est rédigée ci-dessus.
2. **Colonne `t` des séries, hors périmètre.** `T` (deux chemins) et ` t ` (CSV) sont ignorés sans message, alors que ` t ` est reconnu en classeur. Effet possible : verdicts H3 sur une série non triée et consécutivité non contrôlée ; σ_USP inchangé. **Recommandation** : rédiger une issue (candidate K2b), à créer sur accord, qui appliquerait la règle N à `t` ou poserait un refus dédié. Ne pas étendre K3b, dont le périmètre est fermé, sauf décision contraire.

---

## Retour

- **Statut** : `complet`, sous deux réserves : la parité avec `openxlsx` pour H1 n'a pas été mesurée (paquet absent), et la conformité des textes doit encore être contrôlée en aval par `regulatory` (décision 6).
- **Résultat** :
  - `I` et ` i ` : reconnus comme colonne `i` par la règle N (blancs de bord `[[:space:]]`, `i` ou `I`), puis renommés `"i"`, avec H1 avant `.retirer_lignes_colonnes_vides()` ; texte H1 révisé.
  - Les cinq messages, deux commentaires du moteur, cinq sites de test et quatre lignes du `.tex` sont réancrés sur B/C(3)(a)-(b) pour les séries et sur D(1), D(3)(a)-(b) pour le triangle ; la présomption est attribuée à l'outil.
  - Les sites fidèles sont listés et ne changent pas.
- **Preuves** :
  - *Vérifié par mesure* : comportement actuel des cinq cas d'en-tête sur les deux chemins (lecteur interne), renommage en `i.1` par sélection de colonnes et par `make.unique()`, `T` et ` t ` ignorés dans les séries, contenu des `.rds`.
  - *Vérifié par lecture* : textes de A(1), B(1)-(3) et C(1)-(3) du consolidé ; sites du grep ; code R de `openxlsx::read.xlsx` (déduplication par `make.names()` seulement si `check.names = TRUE`).
  - *Repris de `regulatory`, non relu* : identité du JOUE, p. L 12/276-277.
  - *Hypothèses* : aucun en-tête réel de colonne de développement ne vaut `I` ; `openxlsx` (`check.names = FALSE`) conserve les doublons au niveau C++.
- **Informations manquantes** : `openxlsx` absent, donc parité H1 non mesurée ; comportement sous Windows (jeu de blancs `[[:space:]]`) non mesuré.
- **Décisions non résolues** : 1 (confirmation de (a), ou choix de (b)) et 2 (issue sur `t`), au mainteneur ; choix d'implémentation de la parité H1 (`make.unique`), à `coder` et `audit`.
- **Critères déclenchés** : changement de comportement hors références (fichiers jusqu'ici refusés désormais acceptés) ; lecture de l'outil (présomption de consécutivité) qu'aucun texte ne pose expressément, déjà tranchée par les décisions 5 et 6. Aucun changement de σ_USP, de p-value ni de verdict.
- **Prochaine action recommandée** : soumettre les décisions 1 et 2 au mainteneur ; transmettre les textes à `coder-approfondi` pour l'étape 8, avec le critère de parité H1 ; faire contrôler par `regulatory` (`medium`) les textes du § 2 ; verser ces textes à `docwriter` pour le passage de fin de branche.
