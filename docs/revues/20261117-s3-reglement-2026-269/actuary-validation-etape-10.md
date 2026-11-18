# Validation de fond d'actuary, étape 10 de S3 (#504, #598)

> *Rédigé par l'agent actuary (IA) le 17/11/2026.* Branche `claude/reglement-2026-269` à `c8225c0`, arbre propre. Je n'ai rien écrit dans le dépôt. Mes contrôles ont tourné sous `LC_ALL=C.UTF-8`, moteur chargé par `charger_moteur()`. Script hors dépôt : `/tmp/claude-0/-home-user-outil-usp/7785da0b-f095-5cab-9c27-b986f3ac865f/scratchpad/actuary10/verif.R`.

**Ce que j'ai lu :**
- le diff entier `git diff 1feae61..c8225c0 -- docs/latex/doc_tests_usp.tex` (354 lignes), avec le contexte des passages touchés ;
- les messages des commits `addb439` et `c8225c0`, et l'issue #598 ;
- le tableau `docs/tableaux/20261117-issue504-facteur-np-conditionnel.md` en entier (496 lignes) ;
- mon avis de l'étape 2 (`docs/revues/20261117-s3-reglement-2026-269/actuary-avis-etape-2.md`) ;
- dans `R/engine.R` :
  - `usp_parametre_standard()` (l. 1016-1095) ;
  - `usp_ajuster()` (l. 2128-2166) ;
  - `usp_parametre()` (l. 2517-2531) ;
  - `usp_jackknife()` (l. 6055-6070) ;
  - les lignes de la famille G de `usp_tests()` (l. 7930-8005) ;
  - `usp_ic_basic_log()` (l. 12062-12073) ;
  - `engine_influence()` ;
  - le bloc de robustesse de `run_engine()` (l. 17480-17625) ;
  - la branche Merz-Wüthrich (l. 16715-16790) ;
- la définition de « Test » et de « Diagnostic » dans `CONTEXT.md` ;
- `docs/latex/CONVENTIONS.md` (règle « Pas de vie du dépôt »).

## Visa : accordé sous réserves

Le fond est juste, sauf sur un point. La phrase sur le sens de l'erreur d'une déclaration est fausse quand le σ standard est saisi (constat majeur M1). Une fois M1 corrigé par un commit `docs:` minimal, le visa vaut sans réserve. Les constats mineurs sont recommandés, sans être exigés.

Dans le tableau avant / après, tous les champs changés autres que σ_USP sont expliqués et validés. Je confirme qu'aucune p-value et aucun verdict ne changent : la preuve est à la fois structurelle et mesurée (§ 2).

---

## 1. Diff du `.tex` (lignes à `c8225c0`)

### 1.1 Argument de R1-a (l. 2412-2417) : juste, formulation imprécise (mineur m1)

Le passage est bien marqué « *Interprétation*, et non texte ». C'est exact : l'article 2 du règlement 2026/269 fixe une date d'application et ne dit pas quelle date d'un calcul la rend applicable. La convention est bien la même que celle de la borne M6 (l. 2319-2321). L'argument reprend celui de mon avis de l'étape 2 (§ 2, R-1), qui était une *hypothèse de raisonnement* sans source réglementaire.

La formulation « ses deux termes visent le paramètre standard de ce même calcul » est imprécise. Le terme estimé, c·√((T+1)/(T−1))·σ̂, ne vise pas le paramètre standard : il estime le paramètre propre qui le remplace. Il faut aussi voir que l'argument fait deux pas distincts :
1. il établit que le terme standard doit être celui du SCR où σ_USP est employé ;
2. il en déduit que le texte applicable est celui de la date de référence de ce SCR. Ce second pas est une convention (celle de M6), pas une conséquence de B(4).

Rédaction proposée : « …parce que le mélange de B(4), C(4) et D(4) n'a de sens que si son terme standard est le paramètre que σ_USP remplace dans ce même calcul, et suit ainsi la même convention… ».

### 1.2 « aucune des deux lectures n'est uniformément prudente, ce facteur n'étant pas plafonné à 1 » (l. 2471-2472) : validé

- L'écart entre les deux lectures vaut σ_USP(R3-A) − σ_USP(R3-C) = (1 − c)(Adjust − 1) σ_annexe.
- Son signe ne dépend que d'Adjust, et non des données.
- La formule que j'ai lue sur l'image (étape 2, p. 25) est max(0 ; [V·3σ − ADC·C·Pr + Par] / [V·3σ]), sans plafond. Adjust prend donc toute valeur de [0 ; +∞) : il dépasse 1 dès que Par > ADC·C·Pr, et il est inférieur à 1 dans le cas ordinaire.
- L'énoncé est donc exact comme propriété de la formule.
- Je n'ai pas étudié si Adjust > 1 est plausible en pratique, et le `.tex` ne le prétend pas.

La transcription des conditions du troisième alinéa (l. 2459-2467) relève de `regulatory` : je ne l'ai pas relue sur l'image dans cette étape.

### 1.3 Constat R1-c (l. 2646-2660) : validé, avec une précision (mineur m2)

« Écart exact qui ne dépend pas des données (σ_USP est affine en σ_std, B(4)) » :
- **C'est exact au sens algébrique.** `usp_parametre()` (l. 2528) donne σ_USP = c·k·σ̂ + (1 − c)·σ_std. Ni σ̂, ni k, ni c ne dépendent de σ_std. Le tableau le confirme : bootstrap, profil et `lr_delta` sont `identical()` (§ 4). Il ne s'agit pas d'un résultat statistique ni d'une approximation. L'écart numérique mesuré est de 1,7e-18 à 1,9e-17 (tableau, § 1).
- « ne dépend pas des données » doit se lire « ne dépend pas des valeurs observées ». L'écart dépend de T (par c) et du segment (σ_brut, barème). La phrase le dit ensuite « à T = 8 », ce qui suffit à la rigueur, mais l'incise gagnerait à le dire.
- Les trois valeurs sont justes :
  - 0,41 × 0,2 × 0,10 = 0,0082 ;
  - 0,19 × 0,2 × 0,08 = 0,00304 ;
  - 0,41 × 0,2 × 0,14 = 0,01148.
  Elles sont égales aux Δ mesurés du tableau.
- **Le constat ne dépend pas de la lecture R-1.** Un SCR dont la date de référence est postérieure ou égale au 30.1.2027 est forcément établi après cette date. Le nouveau texte s'y applique donc sous R1-a comme sous R1-b. Aucune réserve d'interprétation n'est à ajouter.
- Même limite que M1 ci-dessous : « σ_USP augmente » ne vaut que pour le σ standard de la table. Avec une saisie, seul le jugement de conformité change. Ajouter « (σ standard de la table) » serait plus juste.
- « La nécessité d'une nouvelle approbation est hors de la portée de l'outil » : c'est conforme à mon avis de l'étape 2, qui laissait ce point *non vérifié*.

### 1.4 Sens de l'erreur d'une déclaration à tort (l. 2451-2453) : **majeur M1**

La phrase dit : « déclarée présente à tort, la réassurance abaisse σ_USP de (1−c) × 0,2 × σ_brut (sens non prudent) ; déclarée absente à tort, elle l'élève d'autant ». C'est exact sans σ standard saisi, et **faux avec une saisie**, alors que le même paragraphe exige la déclaration « σ standard saisi ou non » (l. 2435).

Dans le code, `usp_parametre_standard()` l. 1093 contient `sigma_standard = if (saisie) sigma_standard else sigma_regl` : la déclaration ne modifie alors que `sigma_reglementaire`, et donc le jugement de conformité de la dérogation.

Mesure (`verif.R`, date du 2027-01-30, II-1 nettes, saisie de 0,10) :
- σ_USP est `identical()` entre `reassurance_np = TRUE` et `FALSE` ;
- `engine_derogations()` donne une valeur réglementaire de 0,08, non conforme, pour TRUE ;
- elle donne 0,10, conforme, pour FALSE.

Une déclaration erronée cache donc, en saisie, une dérogation non conforme ou en signale une à tort. σ_USP n'en est pas touché.

Rédaction proposée : « …Aux segments 1, 4 et 5, sans σ standard saisi, déclarée présente à tort, la réassurance abaisse σ_USP de (1−c) × 0,2 × σ_brut (sens non prudent) ; déclarée absente à tort, elle l'élève d'autant (sens prudent). Avec un σ standard saisi, σ_USP n'en dépend pas ; seule change la valeur réglementaire à laquelle la saisie est comparée. »

Je le classe majeur pour deux raisons : c'est une affirmation de la documentation sur le code, fausse sur un chemin que le texte ouvre lui-même ; et elle porte sur le sens prudent ou non prudent, qui est la raison d'être de la phrase. La correction tient en une incise et ne touche aucun résultat.

### 1.5 Annexe de revue de code (l. 22423-22428) : validée, complément recommandé (mineur m5)

La phrase dit : « une anomalie y atteindrait σ_USP des deux méthodes et, pour les méthodes lognormales, les diagnostics de robustesse qui en dérivent (famille G), mais aucune p-value ni aucun verdict, les tests ne lisant pas le paramètre standard ». Je l'ai vérifiée sur le code :
- `usp_tests()` ne reçoit σ_std que par `fit$ecart_jackknife`, `fit$largeur_ic` et `fit$largeur_ic_restreint`, et `robustesse$jack_annees` sert au seul `detail`. Ces grandeurs alimentent trois lignes de `type = "diagnostic"`, au verdict INFO par construction (`add()`, l. 7955-7995).
- `mw_tests(aj, boot, alpha, figes)` (l. 16719) ne reçoit pas σ_std. Merz-Wüthrich n'a aucune ligne qui en dépende.
- Avec le vocabulaire de `CONTEXT.md` (un test a un verdict, un diagnostic n'en a pas), l'expression « les tests ne lisant pas le paramètre standard » est exacte.

La liste des effets est incomplète sur deux points :
- une anomalie de `engine_valider_declarations()` atteindrait aussi le **refus ou l'acceptation du calcul** (`ok`, domaine) ;
- elle atteindrait les intervalles bootstrap de σ_USP et `plots_data` des deux méthodes, y compris l'IC Merz-Wüthrich (l. 16729-16731).

Ce sont des précisions, pas des erreurs.

### 1.6 Fiche jackknife, rubrique 3 (l. 14076-14078) : validée ; une phrase restée à l'ancien état (mineur m3)

« La part standard, (1−c)σ_std, ne dépend que du paramètre standard retenu et du barème, non des données » : c'est exact. Le « paramètre standard retenu » couvre la table, la nature des données, le facteur NP selon la date et la déclaration, et la saisie (`usp_jackknife()` l. 6066 reçoit le `sigma_standard` final).

La même fiche, en rubrique 6 (l. 14151-14152), écrit encore « le transposer le multiplierait par un rapport qui dépend de la table de l'annexe ». C'est désormais incomplet : il faut « du paramètre standard retenu ».

### 1.7 #598, fiche multi-démarrages (l. 14376) : validée

« atteignant le plus petit objectif obtenu parmi les démarrages » décrit fidèlement `a_optimum <- abs(vals - best$value) < TOL_OPTIMUM` (l. 2163), sans prêter au code une garantie d'optimum global.

J'ai vérifié la nuance relevée. Avec la règle `fit$value < best$value - 1e-10` (l. 2152), on a pour tout i, au passage i, vals[i] ≥ best_i − 1e-10 ≥ best_final − 1e-10. Donc 0 ≤ best$value − min(vals) ≤ 1e-10 *(démonstration exacte)*. L'ensemble compté ne peut différer de celui que définit la formule de κ̂ (l. 14384, écrite avec min) que pour un démarrage dont l'écart au minimum tombe à 1e-10 près de la frontière de 1e-6. C'est négligeable : aucune correction n'est nécessaire.

Reste (mineur m4) : l. 14394, « au moins deux démarrages atteignent le minimum (n* ≥ 2) » garde le mot « minimum ». Il n'est plus qualifié de « global » et se lit correctement, mais « sont à l'optimum » serait cohérent avec la rubrique 3.

### 1.8 Autres passages du diff

- **« articles 117 et 148 dans leur version d'origine » (l. 2404).** J'ai cherché par extraction du texte (prose seule, pas les formules) dans la version consolidée : aucun marqueur ►/▼ M dans les articles 117 et 148, dont le paragraphe 3 se lit comme dans le `.tex` (l. 2420-2428). *Vérifié pour la prose.*
- **Conformité de la saisie selon la date (l. 2693-2697).** C'est cohérent avec ma mesure : 0,10 saisi, NP absente au 2027-01-30, donne conforme.
- **Domaine, refus de la couverture qualifiante, déclaration exigée là où elle agit.** C'est conforme aux options E-B et aux questions 4 à 7 du § 5 de mon avis de l'étape 2.
- **Rigueur.** Aucune p-value et aucune vitesse de convergence n'est introduite par le diff. Les seuls énoncés quantitatifs sont algébriques (Δ, affinité) ou mesurés par `run_engine()` (tableau cité). Le diff ne cite aucune référence nouvelle, hors le règlement 2026/269 en bibliographie, et aucun texte n'est attribué à une source qui ne le dit pas.

---

## 2. Tableau avant / après (`acac7d2`) : champs autres que σ_USP validés

La structure est la même que celle prévue au § 3.1 de mon avis : changent `parametre_final`, `candidats`, `calibration`, les trois IC, `jackknife$sigma_usp`, `ajustement`, `plots_data`, `metadata` et les lignes 44 à 46 de `tests`. Je l'ai vérifiée par l'arithmétique et par une contre-mesure.

| Champ | Explication | Contrôle |
|---|---|---|
| `candidats$valeur[1]` et `[3]`, `calibration$valeur[8]` et `[9]` | σ_std et σ_USP (l. 17583-17600) ; `[2]` (σ estimé) inchangé | valeurs du § 1 du tableau |
| `variation_relative` | σ_USP/σ_std − 1 | 0,1114524/0,10 − 1 = 0,114524 ; 0,1032524/0,08 − 1 = 0,290655 |
| `ic_bootstrap`, `ic_bootstrap_restreint` | quantiles de type 7 de l'image affine croissante de σ̂* (l. 17489-17504) : chaque borne est translatée exactement de Δ | 0,0630008 → 0,0712008 (+0,0082), de même pour les 5 bornes et les 6 cas |
| `ic_bootstrap_basic_log` | le log porte sur σ, puis l'intervalle est reporté par la même application affine (`usp_ic_basic_log()`, l. 12062) : translation exacte de Δ | 0,0821410 → 0,0903410 |
| `jackknife$sigma_usp` | l. 6066 : translation de Δ année par année | les 8 années, les 6 cas |
| `ajustement` (`ecart_jackknife`, `largeur_ic`, `largeur_ic_restreint`) | numérateurs invariants, dénominateur σ_USP : multiplication par σ_USP,avant/σ_USP,après | 1 − 0,1032524/0,1114524 = 0,07357, écart relatif commun aux trois champs (II-1) ; de même 0,02716, 0,08979… |
| `tests[[44-46]]$estim` | les mêmes trois grandeurs ; type diagnostic, verdict INFO, `detail` inchangé | `identical()` du `detail`, des verdicts et de `p_retenue` (contre-mesure II-1) |
| `plots_data` | `sigma_usp_boot` (999), `boot_reperes` (7 : σ_USP, deux bornes à 90 %, moyenne, σ_std, deux bornes basic log), `influence` | voir ci-dessous |
| `metadata` | `sigma_standard`, `date_reference`, `texte_applicable` | conforme |

**Écart inexpliqué du tableau, expliqué ici (mineur t1).** Pour `donnees_ln` II-1 sans NP, `influence` compte 17 feuilles changées, contre 16 ailleurs. J'ai mesuré la cause (`verif.R`) :
- 16 feuilles = 8 `sigma_usp_sans_t` + 8 `ecart_sigma` ;
- la 17e est `fort_ecart_sigma` de l'année 8, qui passe de TRUE à FALSE (écart −10,12 % → −9,38 %, de part et d'autre de `REPERE_INFLUENCE_SIGMA` = 10 %) ;
- `plus_influente` est inchangé.

Dans le même cas, Δ_max (ligne 44) franchit le **repère** de lecture de 10 % du jackknife (0,1012 → 0,0938). Ce n'est pas un verdict (diagnostic INFO). Aucun autre repère n'est franchi :
- IC à 50 % et 80 % : aucun franchissement dans les 6 cas ;
- jackknife à 10 % et 20 % : les autres cas restent du même côté.

Je recommande d'en porter une ligne dans la PR. Le tableau dit « tout résultat changé est identifié, quantifié, expliqué », et cette feuille ne l'est pas.

**Lecture actuarielle de ces changements, à T = 8.**
- Les grandeurs relatives de la famille G baissent mécaniquement quand σ_std monte : le dénominateur σ_USP grossit, l'incertitude absolue reste la même. Cette baisse n'apporte **aucune** information nouvelle sur la robustesse de l'estimation. La fiche jackknife le dit déjà : le facteur de gauche « dépend de σ_std » (l. 14084-14085).
- Les largeurs absolues des IC sont invariantes. La couverture d'un IC de σ_USP est aussi invariante par une translation commune de l'intervalle et de la cible, (1 − c)·σ_std étant connu. Les constats de couverture déjà mesurés à T = 8 restent donc valables tels quels. C'est un *raisonnement exact* sur l'image affine, sans simulation nouvelle.

**P-values et verdicts : confirmé.**
- *Structure* : `usp_tests()` et `mw_tests()` ne lisent σ_std que par les trois diagnostics G, de type diagnostic et au verdict INFO par construction.
- *Mesure* : tableau § 4, 18 cas, `identical()` des 10 champs de p-value et de verdict des 53 lignes, plus bootstrap, profil, `lr_delta` et `controles`.
- *Contre-mesure indépendante* (II-1 `donnees_ln`, au 2026-12-31 puis au 2027-01-30, NP absente) : `detail`, `verdict` et `p_retenue` `identical()` ; σ_USP 0,103252411422 → 0,111452411422.

Les cas « avec NP » et les témoins (brutes, II-6, XIV-1, `reserve1`, `reserve2`) sont `identical()` hors date et texte. C'est le comportement attendu sous E-B. Le contrôle d'antériorité (§ 5) établit que l'appel « avant » est bien le résultat de l'outil d'avant S3.

---

## 3. Constats classés

| N° | Gravité | Lieu | Constat | Correction |
|---|---|---|---|---|
| M1 | **majeur** | `.tex` l. 2451-2453 | Le sens de l'erreur d'une déclaration NP est faux avec un σ standard saisi : σ_USP n'en dépend pas, seule la conformité change (mesuré) | une incise (§ 1.4) |
| m1 | mineur | l. 2414-2415 | « ses deux termes visent le paramètre standard » est imprécis | « son terme standard est le paramètre que σ_USP remplace » |
| m2 | mineur | l. 2651-2652 | « ne dépend pas des données » : préciser « des valeurs observées » (dépend de T par c, et du segment) et « σ standard de la table » | incise |
| m3 | mineur | l. 14151-14152 | « rapport qui dépend de la table de l'annexe » reste à l'ancien état, alors que la rubrique 3 a été corrigée | « du paramètre standard retenu » |
| m4 | mineur | l. 14394 | « atteignent le minimum » | « sont à l'optimum » (facultatif) |
| m5 | mineur | l. 22424-22428 | les effets d'une anomalie omettent le refus ou l'acceptation (`ok`) et les IC et `plots_data` des deux méthodes | complément facultatif |
| t1 | mineur | tableau, § 2-3 | la 17e feuille `influence` (`fort_ecart_sigma`, année 8) et le franchissement du repère jackknife de 10 % ne sont pas expliqués | une ligne dans la PR (explication au § 2 ci-dessus) |

Aucun constat bloquant.

---

## Retour

- **Statut** : `complet`. Chaque point soumis a reçu un verdict, appuyé sur le code cité, sur l'arithmétique ou sur une mesure exécutée.
- **Résultat** : **visa accordé sous réserves** (M1). Champs non σ du tableau validés. Aucune p-value ni aucun verdict ne change : confirmé.
- **Preuves** :
  - *Vérifié* :
    - formules de `usp_parametre()` l. 2528, `usp_jackknife()` l. 6066, `run_engine()` l. 17489-17520 et `usp_ic_basic_log()` l. 12062 ;
    - borne 0 ≤ best − min ≤ 1e-10 (démonstration sur l. 2152) ;
    - `usp_parametre_standard()` l. 1093 (la saisie prime) ;
    - `verif.R` : `fort_ecart_sigma` de l'année 8 passe de TRUE à FALSE, seule feuille de plus ; `detail`, `verdict` et `p_retenue` `identical()` ; avec saisie de 0,10, σ_USP `identical()` entre NP TRUE et FALSE, conformité FALSE puis TRUE ;
    - arithmétique des ratios d'`ajustement` et des translations d'IC sur les valeurs du tableau ;
    - absence de marqueur modificatif dans les articles 117 et 148 consolidés (prose extraite).
  - *Hypothèses* :
    - la justification de R1-a (raisonnement, sans source) ;
    - le passage de « SCR où σ_USP est employé » à « date de référence de ce SCR », qui est une convention (celle de M6).
  - *Non vérifié* :
    - transcription des conditions du troisième alinéa de 117(4) et de l'anomalie de 148(4) (l. 2459-2467, 2716-2720) : relève de `regulatory` ;
    - plausibilité économique d'Adjust > 1 ;
    - conformité de la forme du `.tex` à `CONVENTIONS.md` : le message de `c8225c0` annonce `controle_doc_nd.R` sans violation, je ne l'ai pas relancé.
- **Informations manquantes** : aucune.
- **Décisions non résolues** : aucune pour le mainteneur. M1 est une correction documentaire, et la session doit faire passer `docwriter` pour un commit `docs:` minimal.
- **Critères déclenchés** :
  - changement de résultat : déjà visé par le mainteneur pour σ_USP ; les autres champs sont validés ici ;
  - aucun désaccord avec `audit`, avec un expert ou avec un ADR ;
  - aucune question de validité d'une p-value à T = 8 (aucun test touché).
- **Constats hors périmètre** : aucun. Tous les constats portent sur le diff ou sur le tableau de la branche.
- **Prochaine action recommandée** : `docwriter` corrige M1, et à sa discrétion m1 à m5, par un commit `docs:` ; la session ajoute t1 dans la PR ; je relis ce diff seul (règle 10) pour lever la réserve ; puis `regulatory` fait le contrôle de conformité prévu (étape 9) sur les l. 2420-2480 et 2716-2720.
