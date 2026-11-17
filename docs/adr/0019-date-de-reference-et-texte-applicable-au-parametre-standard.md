---
status: proposed
date: 2026-11-17
---

# La date de référence du calcul entre dans `run_engine()` et fixe, dans le moteur seul, le texte applicable au paramètre standard ; les déclarations de réassurance non proportionnelle et de couverture pour développements défavorables l'accompagnent ; une seule fonction porte la règle

> *Rédigé par l'agent architect (IA), fiche `architect-approfondi`, Fable d'office pour un ADR d'architecture (`docs/agents/routage.md`, § 3 et § 4.1.3 ; compteur de S3 : 1 sur 3), le 17/11/2026, sur la branche `claude/reglement-2026-269` à `b88d861` (PR brouillon #599), étape 4 de la fiche S3 de `docs/feuille-de-route.md`. **Statut : proposé.** Les lectures du règlement et l'étendue sont **décidées** par le mainteneur (D-S3-1 à D-S3-10, `docs/revues/20261117-s3-reglement-2026-269/decisions-mainteneur.md`) et ne sont pas rediscutées ici ; **la forme ci-dessous attend sa décision** (rubrique « Acceptation »). Les numéros de ligne de `R/engine.R` sont ceux de `b88d861`.*

## Contexte

**Le règlement.** Le règlement délégué (UE) 2026/269 s'applique à partir du 30 janvier 2027 (article 2), sans disposition transitoire. Il conditionne le facteur d'ajustement pour la réassurance non proportionnelle de l'article 117, paragraphe 3 (80 % pour les segments 1, 4 et 5 de l'annexe II) à l'existence d'une telle réassurance « pour ce segment précis », et redéfinit l'écart-type du risque de réserve (articles 117, paragraphes 2, point b), 4 et 5, et 148) en présence d'une couverture pour développements défavorables. Lecture de `regulatory` : `docs/revues/20261117-s3-reglement-2026-269/regulatory-lecture-amont.md` ; avis d'`actuary` : `actuary-avis-etape-2.md` du même dossier.

**Ce qui est décidé (D2, 17/11/2026).** Étendue E-B (D-S3-1) ; la date qui fixe le texte applicable est la date de référence du SCR dans lequel σ_USP est employé (D-S3-2) ; libellé de la déclaration de réassurance non proportionnelle (D-S3-3) ; question R-3 laissée ouverte, donc refus motivé en présence d'une couverture pour développements défavorables qualifiante à date ≥ 30.1.2027 (D-S3-4), y compris pour un σ standard saisi (D-S3-7) ; date obligatoire, sans valeur par défaut, au format ISO `%Y-%m-%d`, `Sys.Date()` exclu, règle date → texte dans le moteur seul (D-S3-5) ; déclaration de réassurance non proportionnelle obligatoire là où elle agit (D-S3-6) ; borne M6 contrôlée par la même date (D-S3-9) ; date dans l'en-tête du rapport figé (D-S3-10).

**Constats sur le code** (*vérifiés*, `grep` et `sed` sur `b88d861`, `Rscript` en lecture seule) :

- `run_engine()` (l. 16945-16959) n'a aucune entrée de date ni de déclaration de réassurance. `R/engine.R` n'appelle jamais `Sys.Date()`.
- Le paramètre standard est obtenu ou relu en **trois endroits** : `run_engine()` appelle `usp_parametre_standard()` (l. 17037) ; `.run_engine_mw()` lit `infos$sigma_reserve` directement (l. 16310), sans passer par elle ; `.engine_trace_sigma()` (l. 17317-17325) le recalcule depuis `res$metadata` et lève une erreur s'il diffère. `engine_parametre_standard()` (l. 17384) et `engine_derogations()` (l. 17469) passent toutes deux par `.engine_trace_sigma()`.
- Pour les seize segments et les deux méthodes de réserve, `usp_parametre_standard()` rend le même double que `usp_segment_infos()$sigma_reserve`, σ saisi compris (`identical()`, *vérifié*) : faire passer `.run_engine_mw()` par elle ne change aucun résultat.
- La date d'application de M6 n'est écrite nulle part dans le code (l'en-tête « LIMITE DE PERIMETRE », l. 57-68, dit « la date d'application du règlement délégué (UE) 2019/981 »). Elle se lit dans le `.tex` (l. 2275-2276 et 2281-2282) et dans l'ADR 0005 (l. 138, « relu à l'image ») : **1er janvier 2020** (règlement délégué (UE) 2019/981, article 2, JO L 161 du 18.6.2019, p. 40, pour les points 66) et 74) de l'article 1er). *Non relue à l'image dans cette consultation.*
- Les contrôles qui refusent sans erreur R vivent dans `engine_valider_donnees()`, `engine_valider_serie_retenue()`, `mw_valider_triangle()` et, pour la nature des données de la réserve n° 2, dans `.run_engine_mw()` (l. 16285). Le contrôle de la nature déclarée est porté par `.nature_erreurs()` (l. 636), partagée par trois appelants (précédent M13, #55).
- Appels existants (jetons d'appel relevés par l'analyseur de R, `getParseData()`, sur les 89 fichiers `.R` de `tests/` ; un appel construit autrement, par exemple une fonction passée à `lapply()`, n'y est pas compté) : **246** appels de `run_engine()` et 22 `do.call(run_engine, …)`, dans 40 fichiers ; 27 appels directs d'`usp_parametre_standard()`, dans 4 fichiers ; 153 appels directs d'`engine_valider_donnees()` (86), d'`engine_valider_serie_retenue()` (14) ou de `mw_valider_triangle()` (53) ; 2 appels de `run_engine()` dans `app.R` (l. 1606 et 1642) ; 2 dans le README (« Usage sans Shiny »).
- `tests/patcher_reference.R` ne pose que des chaînes, des booléens et des `NA` ; il refuse tout nombre et tout objet à attribut autre que `names`, donc une valeur de classe `Date` (en-tête du script ; ADR 0006, premier amendement). Une feuille numérique ajoutée impose une régénération par la CI (ADR 0011, annotation du 29/09/2026, point 2).
- `as.Date(x, format = "%Y-%m-%d")` est indulgente : elle lit `"2027-1-30"`, `"2027-01-30 "` et `"2027-01-30T00:00:00"` comme le 30 janvier 2027, et rend `NA` pour `"2027-02-30"` (*vérifié*, R 4.3.3). Un contrôle de forme strict doit donc la précéder.
- L'affichage lit en trois endroits la première ligne de la table d'`engine_parametre_standard()` par sa position (`table_parametre_standard(res)$Valeur[1]` : `app.R` l. 2094, `R/display_helpers.R` l. 3265 et 3383), et un test lit ses trois dernières lignes (`tests/unitaires/test_calibration.R` l. 761).

**Le problème de forme.** Une entrée qui agit sur le paramètre standard touche aujourd'hui trois lecteurs du paramètre, deux constructions de `res$metadata` et, si elle doit être refusée sans erreur R, jusqu'à quatre contrôles. Sans siège unique, la règle « date → texte → facteur » serait écrite dans `usp_parametre_standard()`, recopiée dans les contrôles pour savoir quand une déclaration est obligatoire, et tentée dans l'application pour savoir quand afficher la question.

## Décision

### 1. Trois entrées nouvelles de `run_engine()`, ajoutées en fin de signature

| Argument | Type reçu | Absence | Sens |
|---|---|---|---|
| `date_reference` | chaîne de caractères scalaire, sans attribut, de forme exacte `AAAA-MM-JJ`, désignant une date qui existe | `NULL` : **refus** (obligatoire, aucune valeur par défaut) | date de référence du calcul (`CONTEXT.md`) |
| `reassurance_np` | logique scalaire non `NA`, sans attribut | `NULL` : non déclarée ; **refus** là où la déclaration agit | réassurance non proportionnelle en place (`CONTEXT.md`) |
| `cdd_qualifiante` | logique scalaire non `NA`, sans attribut | `NULL` : non déclarée ; **refus** là où la déclaration agit | couverture pour développements défavorables qualifiante (`CONTEXT.md`) |

- `NULL` signifie « non déclaré », jamais une valeur : la signature écrit `= NULL` comme pour `nature_donnees`, et l'absence est refusée par le contrôle, non remplacée.
- **Un seul type par entrée.** Une valeur de classe `Date`, un nombre (`20270130`), `"30/01/2027"`, `"2027-1-30"`, une chaîne entourée de blancs, `NA`, un vecteur sont refusés, sans conversion, comme le sont déjà un segment en texte ou une graine non entière. Le message dit la forme attendue ; pour une `Date`, il indique `format(d, "%Y-%m-%d")`.
- La date reçue est contrôlée par une expression régulière stricte, puis par `as.Date(x, format = "%Y-%m-%d")` et un aller-retour `identical(format(d, "%Y-%m-%d"), x)`. Les dates se comparent sur leurs valeurs de `Date`, **jamais comme des chaînes** (l'ordre des chaînes dépend de la locale). Le moteur ne lit pas l'horloge pour décider du texte (`docs/exigences.md` § 4.5).
- Les trois arguments sont acceptés pour les trois méthodes. Là où une déclaration n'agit pas, elle est consignée sans effet (D-S3-6) ; elle n'est pas une erreur d'usage au sens de #489, parce qu'elle n'est pas ignorée en silence : `res$metadata` la porte et la table du paramètre standard dit « sans effet » (point soumis au mainteneur, Q-S3-4).

### 2. Les dates d'application sont des données réglementaires, en tête de `R/engine.R`

Une table `TEXTES_APPLICABLES`, à côté d'`ANNEXE_II` et d'`ANNEXE_XIV`, une ligne par état du texte qui change le paramètre standard, avec sa source en commentaire :

| `texte` | `applicable_du` | Source |
|---|---|---|
| `"2019/981"` | `"2020-01-01"` | règlement délégué (UE) 2019/981, article 2 (JO L 161 du 18.6.2019, p. 40) : annexes II et XIV remplacées (M6) ; article 117, paragraphe 3, d'origine |
| `"2026/269"` | `"2027-01-30"` | règlement délégué (UE) 2026/269, article 2 (JO série L, 2026/269 du 18.2.2026, p. 94) : articles 117 et 148 modifiés |

Le texte applicable est celui de la dernière ligne dont la date est antérieure ou égale à la date de référence ; aucune ligne : hors du domaine (borne M6, #19, D-S3-9). Il n'y a **pas de borne supérieure** : le moteur ne connaît pas un acte postérieur, et c'est la veille datée (#463) qui porte ce risque. Un acte futur ajoute une ligne et sa règle. `ANNEXE_II`, `ANNEXE_XIV` et la colonne `np_standard` gardent leurs valeurs : c'est la **condition d'emploi** de `np_standard` qui change, non sa valeur.

### 3. Une seule fonction porte la règle : `engine_valider_declarations()`

`engine_valider_declarations(methode, segment, annexe, nature_donnees, date_reference, reassurance_np, cdd_qualifiante)`, publique, ne lève aucune erreur pour une déclaration absente, mal formée ou hors du domaine. Elle rend une liste :

- `ok`, `erreurs` (motifs de refus, vecteur vide si tout est recevable) ;
- `date_reference` (la chaîne reçue), `texte_applicable` ;
- `reassurance_np` et `cdd_qualifiante` (valeur déclarée, `NA` si non déclarée) ;
- `np_requise` et `cdd_requise` (la déclaration est-elle exigée pour ce calcul ?) ;
- `facteur_np` (facteur à appliquer à σ brut sur données nettes, `NA` s'il est sans objet).

Elle est seule à lire `TEXTES_APPLICABLES` et seule à savoir quand une déclaration agit. « La déclaration de réassurance non proportionnelle agit » se lit sur la table, `np_standard` différent de 1 pour le segment, et non sur une liste de numéros de segments écrite en dur.

| Texte applicable | Méthode, données | Règle |
|---|---|---|
| `"2019/981"` | toutes | règle actuelle, inchangée : sur données nettes, `np_standard` × σ brut sans condition ; les deux déclarations sont consignées sans effet et ne sont pas exigées |
| `"2026/269"` | primes, données brutes | σ brut ; déclarations consignées sans effet (`cdd_qualifiante` l'est toujours pour la méthode de primes) |
| `"2026/269"` | primes, données nettes, segment à `np_standard` ≠ 1 (II-1, II-4, II-5) | `reassurance_np` **exigée**, σ standard saisi ou non ; `TRUE` : `np_standard` × σ brut ; `FALSE` : 100 % × σ brut |
| `"2026/269"` | primes, données nettes, autre segment (annexe XIV comprise) | 100 % dans tous les cas ; déclaration consignée sans effet |
| `"2026/269"` | primes, aucun segment désigné (σ standard saisi seul) | aucune valeur réglementaire à calculer ; déclarations consignées sans effet |
| `"2026/269"` | réserve n° 1 et n° 2 | `cdd_qualifiante` **exigée**, σ standard saisi ou non (D-S3-7) ; `TRUE` : **refus**, hors du domaine (R-3 ouverte, D-S3-4) ; `FALSE` : σ(res,s) de l'annexe |

`usp_parametre_standard()` reste le **seul point d'obtention** du paramètre standard et de sa trace. Elle reçoit les trois arguments (en fin de signature), appelle `engine_valider_declarations()`, arrête par `stop()` si celle-ci refuse (appel direct, comme aujourd'hui pour la nature des données) et applique `facteur_np`. Elle ne porte pas la règle du texte applicable ; elle garde ce qui dépend de la méthode et de la nature des données (point de l'article 218 remplacé, colonne de l'annexe, exigence relative aux données). Sa valeur gagne `date_reference`, `texte_applicable`, `reassurance_np`, `cdd_qualifiante`, `np_requise`, `cdd_requise` et `facteur_np` ; `np_standard` y reste la valeur de la table.

Test de suppression. Sans `engine_valider_declarations()`, la règle s'écrit dans `usp_parametre_standard()` (le facteur), dans chaque contrôle (l'obligation et les refus) et dans l'application (quand poser la question) : trois copies d'une règle réglementaire qui changera encore. Elle mérite d'être un module. Sa profondeur : sept arguments simples en entrée, toute la lecture de 2026/269 retenue par D2 derrière.

L'avis provisoire de la fiche S3 (« `usp_parametre_standard()` seul module qui décide ») est donc précisé, non contredit : vu de `run_engine()`, de `.run_engine_mw()` et de `.engine_trace_sigma()`, il n'y a toujours qu'elle ; la règle qu'elle applique a un siège qui peut aussi répondre sans lever d'erreur.

### 4. Les refus sont des refus de domaine : `ok = FALSE`, motifs dans `validation`, sans erreur R

- `run_engine()` appelle `engine_valider_declarations()` **une fois**, après `.engine_verifier_usage()` et avant le choix de la branche. Ses motifs sont placés en tête de `validation$erreurs` de la branche suivie, avec ceux des données : l'utilisateur voit tous les motifs d'un coup, comme pour la nature des données.
- Sont refusés : date absente ; date mal formée ou inexistante ; date antérieure au 1er janvier 2020 ; déclaration mal formée ; déclaration absente là où elle est exigée ; couverture pour développements défavorables qualifiante déclarée sous le texte de 2026/269.
- Les signatures d'`engine_valider_donnees()`, d'`engine_valider_serie_retenue()` et de `mw_valider_triangle()` **ne changent pas** : le contrôle des déclarations ne dépend pas des données. Les 153 appels directs de ces fonctions dans les tests restent valides.
- `.engine_verifier_usage()` ne change pas : une déclaration irrecevable n'est pas une erreur d'usage, par parallélisme avec `nature_donnees` (M13).
- Un résultat refusé garde la forme actuelle : `metadata = list(horodatage, methode)`.

### 5. `res$metadata` gagne quatre champs, tous non numériques

| Champ | Type | Valeurs |
|---|---|---|
| `date_reference` | caractère | la chaîne reçue, `"AAAA-MM-JJ"` |
| `texte_applicable` | caractère | `"2019/981"` ou `"2026/269"` |
| `reassurance_np` | logique | `TRUE`, `FALSE`, ou `NA` (non déclarée, admise là où elle n'agit pas) |
| `cdd_qualifiante` | logique | `FALSE`, `NA` (non déclarée, admise là où elle n'agit pas), ou `TRUE` (là où elle est sans effet seulement : texte `"2019/981"`, ou méthode de primes) |

- Dans les deux branches, pour les trois méthodes, placés après les champs existants et avant les champs d'exécution (`horodatage`, `duree_sec`, `version_R`) : après `seed_flux_regime` (lognormale), après `n_fournies` (Merz-Wüthrich).
- **Aucun champ numérique n'est ajouté à l'objet.** Le facteur appliqué n'est pas stocké : il est recalculé par la trace. La date est une chaîne, non une `Date` (un double à attribut de classe, que le patcheur refuse et que le comparateur jugerait à une tolérance). Aucune ligne n'est ajoutée à `calibration` ni à `candidats`. C'est ce qui rend le changement de structure patchable (point 8).
- `texte_applicable` se déduit de la date ; il est stocké quand même, comme `bareme` l'est à côté de `segment` : le résultat dit selon quel texte il a été calculé, et la trace vérifie que le moteur qui le relit en déduit le même.
- `.engine_trace_sigma()` relit les quatre champs, rappelle `usp_parametre_standard()` avec eux (`NA` relu comme « non déclarée ») et lève une erreur si le σ standard **ou le texte applicable** recalculés diffèrent de ceux du résultat. Un objet qui ne porte pas ces champs (produit avant ce changement) est **refusé plutôt que deviné**, comme l'est déjà un objet sans `sigma_standard_saisi` (#55) ou sans `bareme_saisi` (#93). La conformité d'un σ standard saisi (`engine_derogations()`, colonne `conforme`) est ainsi jugée selon le texte applicable, sans autre changement.
- `engine_parametre_standard()` gagne des lignes (date de référence, texte applicable, déclaration et son effet, facteur appliqué). Elles sont insérées **après la première ligne et avant les trois dernières**, que l'affichage et un test lisent par position.

### 6. `.run_engine_mw()` passe par `usp_parametre_standard()`

La lecture directe d'`infos$sigma_reserve` (l. 16310) disparaît : la branche Merz-Wüthrich obtient σ(res,s) par `usp_parametre_standard("reserve2", …)`, comme la branche lognormale. Commit préparatoire, sans changement de résultat (même double, *vérifié*). Après lui, les trois lecteurs du paramètre standard passent par une seule fonction, et la règle de 2026/269 se pose en un endroit.

### 7. L'application collecte et transmet ; elle ne connaît pas la règle

- Panneau de droite : un champ de **texte** pour la date (`AAAA-MM-JJ`), vide au départ ; deux choix sans présélection (réassurance non proportionnelle pour la méthode de primes, couverture pour développements défavorables pour les méthodes de réserve), au libellé de D-S3-3 pour le premier. L'affichage conditionnel ne dépend que de la **méthode**, comme celui de la nature des données ; jamais de la date ni du segment.
- **Pas de `dateInput`** : sans valeur, ce composant de Shiny présente la date du jour du poste client (*d'après la documentation de Shiny, à confirmer à l'étape 5 (d)*), ce qui reviendrait au défaut `Sys.Date()` que D-S3-5 exclut.
- Les motifs affichés avant le clic sont ceux d'`engine_valider_declarations()`, appelée telle quelle ; c'est le moteur qui dit si une déclaration est exigée. L'application ne compare aucune date.
- Onglet Calibration et section 4 du rapport figé : les lignes nouvelles d'`engine_parametre_standard()` s'affichent sans code d'affichage nouveau (`table_parametre_standard()` rend la table ligne à ligne). En-tête du rapport figé et bloc « État » : date de référence et texte applicable, lus dans `res$metadata` (`docs/exigences.md` § 5.6, à modifier : D-S3-10).

### 8. Compatibilité des appels existants

- **Aucune compatibilité ascendante n'est offerte par le moteur**, et c'est voulu (D-S3-5) : un appel sans date rend `ok = FALSE` avec un motif qui nomme l'argument. Une valeur par défaut, où qu'elle soit logée, rendrait silencieuse la borne que S3 rend visible.
- **Tests.** Chaque appel reçoit la date explicitement, par une constante de l'outillage de tests, `DATE_REFERENCE_TESTS <- "2026-12-31"`, définie une seule fois et lue par les deux outillages (`tests/outils_tests.R`, `tests/unitaires/outils_unitaires.R`). Convention : les jeux de `tests/donnees/` sont réputés calculés pour l'arrêté du 31.12.2026, sous le texte antérieur à 2026/269, comme ils sont réputés bruts depuis M13. Les six cas de référence gardent ainsi leurs valeurs.
- **Ordre qui garde chaque commit vert** (fiche S3, étape 5) : les entrées sont d'abord accueillies, contrôlées et consignées, l'absence de date étant encore tolérée ; les appels des tests sont migrés ; puis l'absence devient un refus. Le dernier de ces trois commits prouve que la migration est complète : un appel oublié y échoue.
- **README**, « Usage sans Shiny » : les deux exemples reçoivent la date, avec une ligne sur les déclarations. **`app.R`** : les deux appels transmettent les trois entrées.
- **Objets relus** (résultat enregistré avant ce changement) : les fonctions de trace les refusent (point 5) ; l'en-tête du rapport figé garde son tiret pour un champ absent (#263).
- **Références** : les six fichiers gagnent 24 feuilles non numériques (quatre champs par cas) et aucune valeur numérique ne change. Recommandation : **patch non numérique** par `tests/patcher_reference.R` (ADR 0006, premier amendement), dans le commit qui pose les champs ; une régénération par la CI réécrirait environ 12 400 valeurs par fichier pour n'en ajouter aucune (Q-S3-2).

## Options écartées

- **Une valeur par défaut de la date** (régime actuel, ou date du jour). Écartée par D-S3-5 : un défaut « avant 2027 » est non prudent après cette date ; `Sys.Date()` rend le résultat dépendant du jour du calcul, contre `docs/exigences.md` § 4.5. Une option globale de R lue par le moteur aurait le même défaut, en plus caché.
- **Un « texte applicable » déclaré à la place de la date.** L'utilisateur porterait la règle date → texte, que D-S3-5 réserve au moteur ; la borne M6 demanderait quand même une date.
- **Accepter aussi la classe `Date`.** Deux types pour une entrée ; `res$metadata` porterait soit un double à attribut (non patchable, comparé à une tolérance), soit une conversion silencieuse, contraire à l'usage du moteur.
- **Faire porter les déclarations par les contrôles de données** (trois arguments de plus à `engine_valider_donnees()`, `engine_valider_serie_retenue()`, `mw_valider_triangle()` et `.run_engine_mw()`, sur le modèle de `.nature_erreurs()`). Quatre signatures de plus, 153 appels de tests concernés, et un contrôle qui ne dépend pas des données mêlé à ceux qui en dépendent. Le précédent M13 est conservé pour la nature des données, non étendu.
- **Loger la règle dans l'application** (afficher la question selon la date et le segment). Règle métier hors du moteur, contre `docs/exigences.md` § 4.4, et seconde copie à tenir à jour.
- **Stocker le facteur appliqué dans `res$metadata`.** Feuille numérique : régénération des six références par la CI, et une redondance de plus à garder cohérente. La trace le recalcule.
- **Une erreur d'usage (`stop()`) pour une date absente ou hors du domaine.** D2 demande un refus motivé `ok = FALSE` ; l'application le restitue comme un refus de données, avec tous les motifs.
- **Un adaptateur de tests qui fournirait la date à la place des appels** (fonction homonyme de `run_engine()` dans l'outillage). Les tests n'exerceraient plus l'interface publique, et un lecteur verrait réussir un appel sans date que la documentation dit refusé ; c'est la forme d'homonyme que l'ADR 0016 a fermée.
- **Dupliquer les tables d'annexes par texte, ou ajouter une colonne de facteur par texte.** Les valeurs ne changent pas ; seule la condition d'emploi change, et elle tient dans la règle.
- **Une septième référence sous le texte de 2026/269.** Ses valeurs seraient celles de `premium`, à l'identique ; des tests d'identité dans la batterie unitaire le prouvent sans création par la CI (Q-S3-5).
- **Un argument unique regroupant les trois déclarations** (liste « cadre »). Un type de plus dans l'interface publique, alors que tous les arguments de `run_engine()` sont des valeurs simples.

## Conséquences

- **Contrats partagés modifiés** (`docs/agents/routage.md`, § 4.2) : interface de `run_engine()` (trois arguments) et d'`usp_parametre_standard()` ; objet `usp_engine` (`res$metadata`, quatre champs) ; données réglementaires en tête d'`engine.R` (table `TEXTES_APPLICABLES` ; condition d'emploi de `np_standard`).
- **Résultats.** Les six cas de référence sont inchangés en valeur à chaque commit. Pour une date de référence ≥ 30.1.2027, données nettes, segments II-1, II-4 et II-5, sans réassurance non proportionnelle, σ_USP augmente de (1 − c) × 0,2 × σ brut : +0,0082, +0,00304 et +0,01148 à T = 8 (avis d'`actuary`, § 3.2), avec les champs qui en dépendent (§ 3.1 du même avis) ; aucune p-value ni aucun verdict ne changent. Visa du mainteneur sur le tableau avant / après.
- **Le moteur refuse désormais** tout appel sans date, toute date antérieure au 1er janvier 2020 et, sous le texte de 2026/269, une méthode de réserve avec couverture pour développements défavorables qualifiante. La borne du 30.1.2027, documentée mais non contrôlée, cesse d'être une borne ; le constat écarté de S2 (absence de garde de date) est levé.
- **Environ 300 appels de tests** reçoivent la date (246 appels de `run_engine()`, 22 `do.call(run_engine, …)`, 27 appels d'`usp_parametre_standard()`, scripts de mesure hors CI compris).
- **Limite connue.** Le moteur ne vérifie aucune des trois déclarations : ce sont des exigences de données non vérifiables, à présenter comme telles dans le `.tex`, avec le libellé d'interprétation de D-S3-2 et D-S3-3.
- **Limite connue.** Aucune borne supérieure de date : un acte postérieur à 2026/269 ne se voit que par la veille (#463).
- **Documents à aligner** : `docs/exigences.md` § 5.6 (D-S3-10) ; `.tex` (étape 8 : `sec:segments`, paragraphe « Paramètre remplacé par la méthode du risque de primes », exemple d'appel, description de `res$metadata`, index des fonctions) ; README ; en-tête « LIMITE DE PERIMETRE » d'`engine.R` ; sur instruction du mainteneur, `CLAUDE.md` (« Flux du moteur ») et `.claude/rules/moteur.md` (« Données réglementaires »), qui disent encore la borne M6 documentée et non contrôlée.
- **ADR antérieurs.** Aucun n'est contredit. ADR 0005 : la version consolidée du 14.11.2024 reste la référence de lecture pour le texte `"2019/981"`. ADR 0006 et 0011 : appliqués (patch non numérique). ADR 0016 : la substitution de test reste posée dans `environment(run_engine)`.

## Renvois

- Issue #504 ; PR #599 ; fiche « Branche S3 » de `docs/feuille-de-route.md` (« Plan de forme (étape 4) », questions Q-S3-1 à Q-S3-7).
- `docs/revues/20261117-s3-reglement-2026-269/` : `regulatory-lecture-amont.md`, `actuary-avis-etape-2.md`, `decisions-mainteneur.md`.
- `CONTEXT.md` : « Date de référence du calcul », « Texte applicable », « Réassurance non proportionnelle en place », « Couverture pour développements défavorables qualifiante ».
- #19 (borne M6), #55 (M13, nature des données), #489 (arguments sans effet), #463 (veille).

## Acceptation

*À compléter par la décision du mainteneur (Q-S3-1).*
