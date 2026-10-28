---
status: accepted
date: 2026-10-28
---

# Le moteur se charge par un chargeur unique, `charger_moteur()` (`R/charger_moteur.R`), dans un environnement dédié qui ne voit que le moteur, les exports de `stats` et `base` ; la limite C1 de l'ADR 0003 est levée

## Contexte

**Constat (#200).** Le constat C1 d'`audit` sur R9 (PR #197) a été accepté comme limite le 05/10/2026 : ADR 0003, annotation du 02/10/2026, « Limite C1 » ; `CONTEXT.md`, entrée « `fonction` ». `R/engine.R` est chargé par `source()` dans l'environnement global : `app.R:22`, `tests/outils_tests.R:52`, `tests/unitaires/outils_unitaires.R:24` et le README (« Usage sans Shiny »). L'environnement global **est** donc l'environnement du moteur. Tout nom que le moteur ne définit pas lui-même (`c`, `intersect`, `pi`…) est cherché d'abord dans cet environnement, avant `base` et `stats`. Le correctif de #179 (`do.call(base::c, vals)` dans `.mc_evaluer()`) ne protège qu'un appel, et seulement contre un objet non fonction.

**Mesures** (`Rscript`, R 4.3.3, `LC_ALL=C.UTF-8`, arbre de la tête `18dab4e` cloné hors dépôt ; scripts dans le scratchpad de la session ; *vérifiées*). Les valeurs de σ_USP portent sur `reserve1` (`tests/donnees/donnees_ln.csv`, segment 1, B = `B_MIN_USAGE`).

| Situation de la session | Chargement par `source()` global | Chargement dédié (décision ci-dessous) |
|---|---|---|
| aucun homonyme | 0,1073524114 | 0,1073524114 |
| fonction `c` de l'issue #200 dans l'environnement global | **0,1138150042**, sans aucun signal | 0,1073524114 |
| `intersect`, `setdiff` (comme les masque dplyr) et `pi <- 3` dans l'environnement global | **`ok = FALSE`**, σ_USP absent | 0,1073524114 |
| `usp_parametre()` redéfinie dans l'environnement global après le chargement | **`ok = FALSE`** | 0,1073524114 |
| `add(fonction = "ma_fonction_globale")`, fonction définie dans l'environnement global seulement | **acceptée** (limite C1) | refusée : « fonction inconnue du moteur » |

**Inventaire des noms** (parcours statique des corps de fonction, approximation : noms locaux repérés par `<-`, `=`, `for` et les arguments formels ; *vérifié* à cette approximation près) :
- 340 objets dans le moteur, dont 262 fonctions ;
- aucun homonyme d'un export de `base`, de `stats` ou de `utils` ;
- **aucun** nom, appelé ou lu, hors du moteur, de `base` et de `stats` ;
- les seules variables de `base` lues sont `.Machine`, `LETTERS`, `pi` (lue par `.imhof_p_sup0()`, donc masquable aujourd'hui) et `R.version.string` ;
- **aucun appel non qualifié** à une fonction de `stats` : 145 occurrences de `stats::` ;
- `utils::`, `tools::` et `openxlsx::` sont toujours qualifiés ;
- les 460 exports de `stats` n'ont aucun nom commun avec `base`.

**Décisions du mainteneur du 28/10/2026** (quarante-troisième point d'étape, fiche « Branche Fg » de `docs/feuille-de-route.md`) :
- Q-43-3 (A) : chargement dans un environnement dédié, prototype mesuré ; garde de détection écartée ;
- Q-43-15 (A) : le présent ADR est rédigé par `architect-approfondi`, Opus, effort `high`, sans Fable.

## Décision

1. **Un chargeur unique, `R/charger_moteur.R`, hors de la logique quantitative.** Il ne contient qu'une fonction :

   `charger_moteur(fichier = "R/engine.R", dans = parent.frame())`

   Il n'appelle que des fonctions de `base`, et son enclos est fixé à `baseenv()` (`environment(charger_moteur) <- baseenv()`) : un homonyme de l'environnement global ne détourne pas le chargeur lui-même. Le moteur reste un **fichier quantitatif unique** (`docs/exigences.md` § 4.1). Le chargeur ne calcule rien et n'est pas lu par le moteur : `R/engine.R` n'en dépend pas.

   Test de suppression : sans ce module, chaque appelant (application, deux outils de tests, une dizaine de scripts, README) devrait recopier la construction de la chaîne d'environnements. Or c'est précisément la propriété de sécurité, qui doit être en un seul endroit et testée une seule fois. Les « trois copies de quatre lignes » de Q-43-3 sont donc écartées.

2. **Forme de l'environnement.** `charger_moteur()` effectue, dans l'ordre :
   - il crée un environnement d'imports `new.env(parent = baseenv())`, nommé `"imports:usp_moteur"` (attribut `name`), et y importe les exports de `stats` (`importIntoEnv()` depuis `asNamespace("stats")`) ;
   - il crée l'environnement du moteur `new.env(parent = imports)`, nommé `"usp_moteur"` ;
   - il y évalue le fichier par `sys.source(fichier, envir = moteur, keep.source = FALSE)` ;
   - il rend cet environnement de façon invisible.

   La chaîne de résolution d'une fonction du moteur est donc : cadre d'appel → `usp_moteur` → `imports:usp_moteur` (`stats`) → `base` → environnement vide. Elle ne dépend **ni de l'environnement global, ni du chemin de recherche** : elle ne change ni avec les objets de l'utilisateur, ni avec les paquets attachés avant ou après le chargement. Les appels qualifiés (`utils::`, `tools::`, `openxlsx::`) passent par `::`, qui charge l'espace de noms à la demande, indépendamment de cette chaîne.

   `keep.source = FALSE` reproduit l'état des exécutions par `Rscript` (où `source()` ne garde pas non plus les sources), celles de la CI et des références.

3. **Parent de l'environnement d'imports : `baseenv()`, et non `globalenv()` ni `.BaseNamespaceEnv`.**
   - **`globalenv()`** (comme parent du moteur) est le défaut actuel sous une autre forme : la recherche passe par l'environnement global avant `base`. Le scénario de #200 n'est pas corrigé.
   - **`.BaseNamespaceEnv`** est la disposition d'un espace de noms de paquet, celle du prototype du 43e point (mesuré : `asNamespace("stats")` → `imports:stats` → base → `R_GlobalEnv`). Elle protège tous les noms que le moteur emploie aujourd'hui (mesures identiques ci-dessus, variante appelée `dedie` dans les essais). Mais le parent de `.BaseNamespaceEnv` est l'environnement global : un nom futur hors du moteur, de `stats` et de `base` (un `head()` non qualifié, par exemple) y retomberait en silence, de nouveau masquable, et dépendrait de nouveau des paquets attachés.
   - **`baseenv()`** ferme la chaîne par construction : un tel nom lève une erreur « impossible de trouver la fonction », visible dès le premier test qui l'exerce. La convention déjà suivie par tout le moteur (qualifier `utils::`, `stats::`) devient ainsi une règle tenue mécaniquement. L'invariant « R base + stats » de `CLAUDE.md` et de `docs/exigences.md` § 4 s'exprime alors en une phrase vérifiable : *le moteur ne résout un nom non qualifié que dans lui-même, dans les exports de `stats` et dans `base`*.
   - Les deux variantes ont donné les mêmes σ_USP et les mêmes refus sur les scénarios du tableau ci-dessus (*vérifié*). Les mêmes cinq échecs, tous dus aux adaptations de tests du point 7, sont apparus sur la part de la batterie unitaire exécutée : 12 et 14 fichiers sur 45 (*partiel*, batterie interrompue par la limite de la consultation).
   - L'import de `stats` n'est pas requis aujourd'hui (aucun appel non qualifié). Il est gardé pour que la chaîne corresponde exactement à la dépendance déclarée.

4. **Exposition, sans `attach()`.**
   - Si `dans` n'est pas `NULL`, le chargeur **copie** chaque liaison de l'environnement du moteur, noms à point compris (`ls(all.names = TRUE)`), dans `dans`. C'est l'équivalent de ce que `source()` déposait jusqu'ici.
   - Les fonctions copiées gardent pour enclos l'environnement du moteur : leurs appels internes ne voient jamais `dans`. `environment(run_engine)` désigne l'environnement du moteur.
   - `dans = NULL` charge sans rien exposer : c'est l'usage d'un script qui compare deux versions du moteur.
   - `dans` doit être `NULL` ou un environnement ; `fichier` doit exister. Sinon, `stop()` avec un message.

   `attach()` est écarté (mesuré) :
   - il copie lui aussi les liaisons, donc il n'apporte rien sur la copie ;
   - il laisse un effet de bord persistant sur le chemin de recherche : un rechargement donne deux entrées, et des messages de masquage pour 340 noms ;
   - il briserait le confinement voulu par `tests/outils_tests.R` quand ce fichier est évalué dans un environnement dédié (commentaire de `tests/outils_tests.R:44-51`).

5. **Rechargement.**
   - Chaque appel construit un environnement neuf : les caches repartent à froid, ce qui est sans effet sur les résultats (voir le point 9).
   - Les liaisons sont recopiées dans `dans` en écrasant les précédentes, comme avec `source()`.
   - Un nom retiré de `R/engine.R` entre deux chargements reste dans `dans`, comme avec `source()` (*vérifié*). Le chargeur ne le retire pas : un retrait supposerait de marquer les noms exposés, ce qui n'en vaut pas le coût pour un chargement par processus (application, `Rscript`).
   - Un ancien environnement de moteur n'est retenu que par une fermeture encore référencée. Les objets `usp_engine` des six cas ne contiennent ni fonction ni environnement (*vérifié*).

6. **`openxlsx`** reste une dépendance facultative, appelée par `requireNamespace()` puis `openxlsx::` (`R/engine.R:7229-7230`, `:7300-7301`), avec le repli interne. Il n'est ni importé ni attaché par le chargeur. Le chargement dédié n'en change pas le comportement : `::` ne dépend pas de la chaîne.

7. **Appelants et règle des substitutions dans les tests.**
   - Tout chargement du moteur **qui exécute un calcul** passe par `charger_moteur()`.
   - Un chargement qui ne fait que **lire le code** (formals, corps, graphe d'appels) peut rester un `sys.source()` dans un environnement jetable : il ne produit aucun résultat.
   - Une substitution de test (mock) se pose dans `environment(run_engine)`, jamais dans l'environnement global, qui ne détourne plus le moteur. Un appel *direct* à une fonction substituée passe par cet environnement (`get(nom, envir = environment(run_engine))(...)`) : la copie exposée n'est pas substituée.
   - Les tests qui posaient `c`, `cbind`, `rbind` dans l'environnement global (#179 ; `test_calibration.R:969-971`, `test_application.R:764`, `test_rapport_html.R:1285`) sont gardés comme garde de non-régression contre un retour au chargement global.

8. **`source("R/engine.R")` reste admis**, et `R/engine.R` doit rester chargeable ainsi, sans le chargeur (`docs/exigences.md` § 4.2, inchangé). Son emploi se limite à :
   - la vérification d'un point isolé dans une session **vierge** (`Rscript -e 'source("R/engine.R"); …'`, `R --vanilla`) ;
   - la lecture du code.

   Mise en garde à porter dans le README et dans `CLAUDE.md` : chargé par `source()`, le moteur reste exposé à tout homonyme de l'environnement global (#200). Tout chiffre destiné au dossier, à une référence, à un tableau de `docs/tableaux/` ou au `.tex` vient d'un chargement par `charger_moteur()`, ou d'une session `Rscript` vierge. L'usage recommandé du README devient :

   ```r
   source("R/charger_moteur.R")
   charger_moteur()                      # expose run_engine() et les fonctions du moteur
   res <- run_engine(...)
   ```

9. **Reproductibilité et invariants conservés.**
   - **Graine.** `engine_sous_graine()` lit et restaure `.Random.seed` dans `globalenv()`, nommé explicitement (`R/engine.R:2140-2152`). C'est là que R tient l'état du générateur, et cela ne dépend pas de l'environnement de chargement (restauration *vérifiée* sous le chargement dédié). Aucune source d'aléa nouvelle (ADR 0004).
   - **Caches.** Les caches (`.cache_sw` de `sw_loi_nulle()`, `.cache_permutations`, `.cache_mw_spearman`, `.MW_COMBN_CACHE`) sont des environnements créés au chargement dans l'environnement du moteur. Ils ont une sémantique de référence : la copie exposée et le moteur partagent le même objet (*vérifié* pour `.cache_sw` et `.MW_COMBN_CACHE`).
   - **Contrôle d'`add()`.** `exists(fonction, envir = environment(engine_registre_tests), mode = "function", inherits = FALSE)` (`R/engine.R:4284`) reste inchangé et devient exact : `environment(engine_registre_tests)` est l'environnement du moteur, qui ne contient que les objets de `R/engine.R`. La limite C1 est levée. `.shapiro_sur` reste admise, `cor.test` et `ANNEXE_II` restent refusées.
   - **#179.** La qualification `base::c` est gardée, en défense en profondeur, pour l'usage par `source()`.

10. **Inventaire des chargements** (`git grep`, tête `18dab4e`, *vérifié*). Il remplace le décompte « 28 fichiers, environ 10 actifs, 8 archives » du rapport du 43e point, qui n'avait pas été établi fichier par fichier.

    **À migrer à l'étape 1 de Fg (#200) — dix fichiers qui chargent le moteur pour calculer :**

    | Fichier | Appel actuel | Remplacement |
    |---|---|---|
    | `app.R:22` | `source("R/engine.R", local = FALSE)` | `source("R/charger_moteur.R", local = FALSE)` puis `charger_moteur("R/engine.R", dans = globalenv())` ; commentaire `:14` |
    | `tests/outils_tests.R:52` | `source(…, local = TRUE)` | `source(<charger_moteur.R>, local = TRUE)` puis `charger_moteur(file.path(RACINE, "R", "engine.R"), dans = environment())` : même confinement qu'aujourd'hui. Couvre les 27 scripts et tests qui chargent `outils_tests.R` (`test_reproductibilite.R`, `generer_references.R`, `comparer_references.R`, `patcher_reference.R`, `regenerer_et_rendre_compte.R`, les scripts de mesure hors CI, 13 tests unitaires) |
    | `tests/unitaires/outils_unitaires.R:24` | `source(…)` | chargeur, exposition dans l'environnement global (couvre la batterie unitaire) |
    | `tests/balayage_echelles.R:62` | `source(…)` | chargeur |
    | `tests/mesure_courbure_delta_158.R:129` | `source(…)` | chargeur |
    | `tests/concordance_doc_moteur.R:2032` | `sys.source(…, envir = env)`, `env` de parent global, puis `display_helpers.R` dans le même `env` | `charger_moteur(…, dans = env)`, puis `display_helpers.R` dans `env` comme aujourd'hui (étape bloquante de la CI : concordance `--strict` inchangée) |
    | `tests/unitaires/generer_valeurs_forme_close_m1.R:68` | `sys.source(…, envir = ENG)`, parent global | `ENG <- charger_moteur(…, dans = NULL)` (hors CI, Rmpfr) |
    | `tests/mesure_precision_residus_mw.R:200-201` | deux `sys.source()` (version d'un commit passé, version courante), parent global | `charger_moteur(FICHIER_AVANT, dans = NULL)` et `charger_moteur(FICHIER_APRES, dans = NULL)` ; d'où l'argument `fichier` (hors CI, Rmpfr) |
    | `tests/unitaires/test_merz_wuthrich.R:517-520`, `:833-838` | substitutions de `mw_residus` et de `.mw_p_min_ligne` par `assign(…, envir = globalenv())` | substitution dans `environment(mw_tests)` (point 7) ; sans quoi la substitution n'aurait plus d'effet (*non vérifié* à l'exécution : fichier non atteint par la batterie partielle) |
    | `tests/unitaires/test_controles_entree.R` (aide `avec_r12_168()` et assertion #168) | substitution dans `environment(run_engine)` suivie d'appels directs à `test_intercept()` et `test_lm_complet()` | appels par l'environnement du moteur (point 7) ; **échec mesuré** sur le prototype |

    **À adapter : arbres de dépôt copiés sans le chargeur.** Ces tests copient `R/engine.R` et `tests/outils_tests.R` dans un dossier temporaire, et doivent copier aussi `R/charger_moteur.R`. Échecs mesurés sur le prototype pour les deux premiers :
    - `test_comparer_references.R:214` (« référence absente ») ;
    - `test_concordance_doc_moteur.R:1182` (trois assertions de #160) ;
    - `test_application.R:576` ;
    - `test_garde_ecrasement.R:342` et `:618`.

    Les fichiers de la batterie unitaire non atteints par l'essai (31 sur 45) sont à exécuter à l'étape 1.

    **Laissés en l'état — chargements de lecture du code (point 7) :**
    - `tests/calibration_mc_mw_t8.R:2639` et `tests/puissance_mw_t8.R:1156` : `formals`/`body` comparés à `environment(mw_bootstrap)`, qui devient l'environnement du moteur ;
    - `tests/unitaires/test_concordance_doc_moteur.R:325` : graphe d'appels de `.fisher_combine`.

    **Laissés en l'état — archives et extraits historiques**, qui consignent ce qui a été exécuté à leur date :
    - quinze scripts de `docs/revues/20261015-pertinence-tests-graphiques/mesures/` (blocs 1 à 6) ;
    - les extraits de code de `docs/specifications/` (`fk-lecture-conjointe.md`, `fn-incertitude-bootstrap.md`) et de `docs/tableaux/` (`20261023-fm-mesures.md`, `20261024-fk-mesures.md`, `20261027-fn-pilote.md`).

    **Textes à aligner.** Ce ne sont pas des chargements :
    - le commentaire d'en-tête de `R/engine.R:15-17` (commentaire seul : empreinte sans commentaires inchangée, #231) ;
    - les commentaires de `tests/couverture_ic_sigma_t8.R:11` et `:207`, et de `tests/mesure_calendaire_t8.R:114` et `:177` ;
    - README « Usage sans Shiny » ;
    - `CLAUDE.md` (« vérifier un point isolé », section « Architecture ») ;
    - `CONTEXT.md` (entrée « `fonction` », limite) ;
    - ADR 0003 (limite C1) ;
    - `.tex` (l. 323, l. 20345, section architecture et index des fonctions) ;
    - fiches `coder.md:26` (et `coder-approfondi`, régénérée) et `docwriter.md:33`.

    `.codex/` n'est pas touché : il relève du périmètre GPT, et seul le mainteneur peut en ordonner la modification.

## Options écartées

- **Garde de détection dans `run_engine()`** (Q-43-3 (B)). Fondée sur les noms, elle donne des faux positifs : `all.names()` ramasse des variables locales (`C`, `D`, `df`, `sigma`) qu'un utilisateur a souvent dans son environnement global ; elle refuserait aussi tout calcul dès que dplyr masque `intersect` ou `setdiff`. Elle donne aussi des faux négatifs : un nom lu par une fonction que la garde n'inspecte pas.
- **Documentation seule** (Q-43-3 (C)). Le résultat faux reste silencieux. C'est incompatible avec l'enjeu relevé par `actuary` (#200, commentaire `6198666398`) : l'intégrité du calcul livré.
- **Trois copies de quatre lignes** dans `app.R`, `tests/outils_tests.R` et le README : voir le test de suppression du point 1.
- **`attach(NULL)` puis `sys.source()` dans l'environnement attaché** (exemple de `?sys.source`). Le parent du moteur est alors la suite du chemin de recherche : l'environnement global est évité, mais un paquet attaché **avant** le chargement entre dans la chaîne (`library(shiny)`, `library(plotly)` précèdent le chargement dans `app.R`). Mesuré avec un paquet factice qui exporte `intersect` : `ok = FALSE` sous cette option, σ_USP 0,1073524114 sous `charger_moteur()`.
- **Liaisons actives** dans `dans`, qui relisent l'environnement du moteur à chaque accès. En écriture, elles rouvriraient le canal de détournement que #200 ferme ; en lecture seule, elles rendraient une simple affectation de l'utilisateur fautive. Elles sont aussi opaques pour un relecteur.
- **Auto-confinement dans `R/engine.R`**, le fichier se relogeant lui-même après un `source()` global. Il mettrait de la plomberie dans le fichier quantitatif. Il serait fragile : les fermetures créées au chargement, comme celles des catalogues Monte-Carlo, garderaient un enclos global. Il exigerait aussi le chemin du fichier en cours.
- **Paquet R** (espace de noms réel). Il ajoute installation, `NAMESPACE` et verrouillage de l'espace de noms (les substitutions de tests ne pourraient plus `assign()`), pour une protection équivalente.
- **Parent `baseenv()` sans environnement d'imports** (piste du corps de #200). Elle suffirait aujourd'hui, faute d'appel non qualifié à `stats`, mais la chaîne ne correspondrait plus à la dépendance déclarée. Elle est écartée de peu ; voir le point 3.

## Conséquences

- **Résultats : aucun changement.**
  - Sur les six cas de `CAS`, les objets rendus sous `source()` global et sous chargement dédié sont `identical()` hors `metadata$horodatage` et `metadata$duree_sec`, que `nettoyer()` retire.
  - `tests/test_reproductibilite.R` passe sur le prototype : six cas, « 0 non strictement identique(s) », code 0.
  - `tests/comparer_references.R --seuil 0` sort avec le code 0, `premium_ii6` à « 0 grandeur(s) en écart au seuil 0 ».
  - Toutes ces mesures sont faites sur la variante `.BaseNamespaceEnv` (*vérifié*). La variante `baseenv()` retenue a été mesurée sur les scénarios du tableau et sur la part exécutée de la batterie unitaire seulement : volet `identical()` et `comparer_references --seuil 0` *non vérifiés* pour elle, à refaire à l'étape 1.
  - La CI produit les références par `tests/generer_references.R` → `tests/outils_tests.R` : elles seront désormais produites sous le chargeur (ADR 0011). C'est un changement de chemin de chargement, sans régénération.
- **Contrat partagé touché** : l'interface de chargement du moteur (`docs/agents/routage.md`, § 4.2). D'où `coder-approfondi` d'office à l'étape 1, `audit` léger en parallèle d'`app-review` (`app.R` change).
- **Changement de sémantique pour les tests et les scripts.** Une affectation dans l'environnement global ne modifie plus le moteur, et une substitution dans `environment(run_engine)` n'est pas vue par un appel direct à la copie exposée. Les tests qui reposaient sur l'ancienne sémantique sont listés au point 10.
- **Nouvelle mise en garde d'usage.** `source("R/engine.R")` reste possible mais n'est plus la voie recommandée. `docs/exigences.md` § 4.2 reste vrai tel quel : aucun amendement n'est nécessaire. Un complément citant le chargeur est facultatif et relève du mainteneur.
- **ADR 0003** : la limite C1 de l'annotation du 02/10/2026 est annotée « levée par l'ADR 0016 » **au commit de #200** (étape 1), comme l'ADR 0006 l'a été au commit de bascule de l'ADR 0011. Aucune annotation n'est faite tant que le présent ADR n'est que proposé.
- **`CONTEXT.md`** : l'entrée « `fonction` » perd sa phrase « Limite » au même commit. Une entrée « Chargement du moteur » (`charger_moteur()`, environnement `usp_moteur`) est à ajouter par `architect` à l'acceptation.

**Critères d'acceptation de #200** (fiche Fg, étape 1, complétés) :
1. Test unitaire : σ_USP de `reserve1` inchangé (0,1073524114 à B = `B_MIN_USAGE`) avec la fonction `c` de #200 dans l'environnement global.
2. Une fonction `intersect` (et `setdiff`) de l'environnement global est sans effet.
3. `add()` refuse un `fonction` qui ne désigne qu'une fonction de l'environnement global.
4. `environment(run_engine)` est nommé `usp_moteur` ; son parent est `imports:usp_moteur`, puis `baseenv()`.
5. Un chargement avec un paquet factice attaché avant le moteur n'est pas détourné.
6. Volet `identical()` vert ; `comparer_references.R --seuil 0` sans écart sur les six cas.
7. Batterie unitaire complète verte, tests du point 10 adaptés.
8. Concordance `--strict` à 0.
9. `--essai` des scripts touchés OK (M39) ; pour les deux scripts Rmpfr, analyse syntaxique et exécution si Rmpfr est disponible, sinon *non vérifié* déclaré.
10. Démarrage de l'application vérifié par `app-review`.

Issues : #200 (principale), #179 et #111 (limite C1), #231 (empreinte sans commentaires). Branche Fg, `claude/contrat-chargement-moteur`, PR #393.

## Acceptation

*28/10/2026* : accepté par le mainteneur (questions directes de la session principale, E-28/10 (Fg, ADR 0016)) : ADR accepté tel que proposé ; parent **`baseenv()`** retenu (point 3) ; alignement de `CLAUDE.md` et des fiches `coder` et `docwriter` par un commit `claude:` ordonné avec l'étape 1 ; complément de `docs/exigences.md` § 4.2 citant le chargeur, ordonné avec l'étape 1. Rédaction : `architect-approfondi`, Opus, effort `high`, sans Fable (Q-43-15 (A)), après une relance ciblée (limite de 80 tours atteinte sans rendu).
