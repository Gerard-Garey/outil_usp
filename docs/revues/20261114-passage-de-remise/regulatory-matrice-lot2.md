# Matrice de conformité, KR étape 6, lot 2 sur 3 : annexe XVII, sections A, B et C

> Rapport de `regulatory` (effort `high`), versé intégralement par la session principale (Q-54-10). SHA du gel `a2f9c3a` ; `.tex` 3.7. La matrice vaut pour le PDF 3.8 sous réserve du contrôle aval, à l'étape 8, des passages réécrits à l'étape 7.

Aucun écart de conformité majeur sur le lot 2 (annexe XVII, sections A, B et C) : pas de motif d'arrêt. Le moteur, figé à `a2f9c3a`, calcule exactement ce que prescrivent B(4)-(6) et C(4)-(6). Les écarts relevés sont tous mineurs et portent sur la documentation : la formule de B(4)/C(4) n'est écrite nulle part dans le `.tex`, il manque une précision de définition à y_t, et le `.tex` décrit encore une phrase que #573 a retirée du code.

## Sources et méthode

- **Texte.** Version consolidée du 14.11.2024 (référence de lecture) et JOUE L 12 du 17.1.2015, annexe XVII p. 272-276. Les formules ont été lues en image, dans les deux versions.
  - Images du consolidé : celles de B(5), B(6), x̄ et des symboles δ̂, γ̂, σ̂ sont octet pour octet les mêmes en B et en C.
  - B(4) et C(4) ne diffèrent que par l'indice prem / res.
  - π_t : deux fichiers distincts, mais la même formule à l'écran.
  - Les formules du JOUE 2015 sont les mêmes que celles du consolidé.
- **Écarts de texte entre les deux versions** :
  - B(2)(c) et B(2)(d) : renvois inversés par M1, le règlement délégué (UE) 2016/467.
  - C(2)(e)(ii) : rectificatif ►C4, JO L 2 du 6.1.2022, p. 8 (référence vérifiée dans la liste des rectificatifs du consolidé).
- **Contrôle chiffré.** Transcription littérale et indépendante de B(4)-(6), minimisée par sa propre méthode (grille en δ au pas 5e-4 avec les bornes, `optimize` en γ, puis affinage), confrontée à `run_engine()` sous `LC_ALL=C.UTF-8` (segment II-1, B = 199). Script hors dépôt (`reg_lot2/verif.R`, scratchpad de la session).

| Jeu | Méthode | σ_USP moteur | σ_USP transcription | Écart relatif |
|---|---|---|---|---|
| `donnees_ln.csv` (δ̂ = 1) | premium | 0,1114524114 | 0,1114524095 | −1,7e-8 |
| idem | reserve1 | 0,1073524114 | 0,1073524095 | −1,8e-8 |
| `donnees_ln_interieur.csv` (δ̂ = 0,664) | premium | 0,0871308679 | 0,0871308690 | +1,3e-8 |
| idem | reserve1 | 0,0830308679 | 0,0830308690 | +1,4e-8 |

- Le critère est le même à 1e-12 au point retenu par le moteur. Les écarts de ~1e-8 viennent de la précision de l'optimiseur de la transcription.
- Sur 200 points tirés au hasard par jeu, π_t, σ̂ et le critère d'`usp_noyau()` égalent la transcription littérale à 2,3e-11 près en relatif.

## Matrice de conformité

Lignes de `R/engine.R` au gel `a2f9c3a` ; lignes de `docs/latex/doc_tests_usp.tex` à l'état actuel.

| Texte | Code (`R/engine.R`) | `.tex` (\label / lignes) | Verdict |
|---|---|---|---|
| **A(1)(a)-(d)** définitions (année d'accident, de développement, de déclaration, exercice) | aucun calcul ; libellés « années » / « exercices » | `sec:notations` l. 3305-3315 ; A(1)(b) cité l. 3931-3933 | **Conforme**. Remarque de forme : le `.tex` dit « année de survenance » (94 fois) sans écrire que c'est l'« année d'accident » de A(1)(a) |
| **A(2)** segment s de l'annexe II ou XIV | `ANNEXE_II` 69-100, `ANNEXE_XIV` 109-125, `SEGMENTS` 130-140, `.annexe_verifiee()` 370, `.segment_verifie()` 565, `usp_segment_infos()` 590 | `sec:segments` 2148-2259, 2271-2273 | **Conforme**. Le σ saisi sans segment est une dérogation déclarée (interprétation déjà tranchée, #93). Valeurs des annexes II et XIV : hors lot |
| **B(1)(a)-(b)** et dernier alinéa | `xt`, `yt` par année, `run_engine()` 15220 ; positivité 9247-9250 | `sec:notations` 3309-3312 | Code : **conforme** (contenu non vérifiable par l'outil). `.tex` : **écart mineur** (E2) : y_t est dit « pertes agrégées » sans la précision de B(1)(a), « paiements effectués et meilleures estimations de la provision pour sinistres à payer […] après la première année de développement », que les notations ne reprennent pas |
| **B(2)(a)** représentativité | non vérifiable ; cité dans les motifs 2006-2008, 2026 | `sec:controles` 5104-5108 | **Conforme** (exigence déclarative, documentée) |
| **B(2)(b)** cinq années consécutives au moins | `engine_valider_donnees()` 9279-9282 ; `engine_valider_profondeur()` 9393-9417 | 4206-4216 ; 4544-4563 ; 5122-5125 | **Conforme** sur le nombre. La consécutivité n'est contrôlée qu'avec une colonne t ou une ligne d'années : limite écrite |
| **B(2)(c)** ▼M1, données brutes → art. 218(1) a) ii) / c) ii) | `NATURES_DONNEES` 610, `.nature_erreurs()` 630-639, `usp_parametre_standard()` 701-721 | `sec:segments` 2360-2386 ; 4217-4219 | **Conforme** au consolidé ; l'inversion de 2015 est documentée (2378-2379) |
| **B(2)(d)** chapeau ►M1◄, données nettes → a) i) / c) i) | idem ; σ standard = NP × σ brut, 705 | 2372-2393 | **Conforme**. NP standard plutôt que NP propre : interprétation déjà tranchée (M13), présentée comme telle (2387-2393) |
| **B(2)(e)** catastrophes, **B(2)(f)** frais de gestion | non vérifiables | 5110-5113 | **Conforme** (documenté) |
| **B(2)(g)(i)-(iii)** hypothèses | `usp_tests()`, lignes H1-H3 | `sec:h1` 9358-9381, `sec:h2` 10347-10367, `sec:h3` 10915-10945 ; 5126-5127 | **Conforme**. Citations exactes, pages du JOUE exactes ; la lecture en modèle est déclarée comme lecture de l'outil ; les tests « éprouvent », ils n'« établissent » pas |
| **B(2)(g)(iv)** adéquation du maximum de vraisemblance | `usp_valider_ajustement()` 1963-2029 ; `usp_controles_numeriques()` 1835 | `sec:h4` 11580-11654 ; `sec:controles` 4359-4476 | **Interprétation déjà tranchée** : lecture (a) (#188, #227). Pour des ratios exactement égaux, le refus suit la lettre de B(6), puisqu'aucun minimiseur n'existe ; sinon c'est une décision de l'outil, présentée comme telle |
| **B(3)(a)-(b)** années numérotées de 1 à T | T = `length(xt)` après troncature, 15300 ; les T années les plus récentes, 9444-9446 | `sec:segments` 2289-2333 | **Interprétation déjà tranchée** (lecture (A), #104). La troncature est restituée par la ligne « profondeur » |
| **B(3)(c)-(d)** y_t, x_t | `usp_noyau()` 1389 | 3309-3313 | **Conforme** |
| **B(4)** σ_USP = c·σ̂·√((T+1)/(T−1)) + (1−c)·σ(prem,s) | `usp_parametre()` 2113-2127 ; T = `fit$T` 1794 ; σ standard 15312 ; c relève de la section G (lot 3) | aucune transcription ; formule seulement implicite (13290, 13408, 14435) | Code : **conforme** (chiffré ci-dessus). `.tex` : **écart mineur** (E1) |
| **B(4)(e)** σ(prem,s) | `usp_parametre_standard()` 701-722 | 2360-2393 | **Conforme**, sous M13 |
| **B(5)** σ̂(δ̂,γ̂) = exp(γ̂ + (T/2 + Σπ_t ln(y_t/x_t)) / Σπ_t) | `usp_noyau()` 1393 (ln β), 1401 (σ) | 3333-3341, forme équivalente σ̂ = β̂·e^γ̂ | **Conforme** (2,3e-11). `.tex` fidèle, mais pas sous la forme imprimée (E1) |
| **B(5)(d)** π_t = 1 / ln(1 + ((1−δ)·x̄/x_t + δ)·e^{2γ}) | `usp_pi()` 1381-1383 (`log1p`) | 3338 ; 11625 | **Conforme** |
| **B(5)(d)(ii)** x̄ = (1/T)·Σx_t | `xbar <- mean(x)` 1726, sur la série retenue | 3314 | **Conforme** |
| **B(6)** critère Σπ_t(ln(y_t/x_t) + 1/(2π_t) + γ̂ − ln σ̂)² − Σ ln π_t | `usp_noyau()` 1394, 1402 ; `usp_objectif()` 1410-1415 | 11589-11594, 11622-11626 (forme profilée, avec γ − ln σ̂ = −ln β̂) | **Conforme** (identité exacte ; écart numérique 2,3e-11) |
| **B(6)** valeurs qui minimisent | `usp_ajuster()` 1724-1819 : L-BFGS-B, 54 démarrages, minimum global retenu 1748 | 11589-11640 ; 4418-4476 | **Conforme** (concordance 1e-8). Les bornes de γ, [−12 ; 3], sont une décision de l'outil (déjà tranchée, #188). Point de vigilance V1 ci-dessous |
| **B(6)**, dernier alinéa : δ ∈ [0,1] | bornes 1739 ; pénalité 1412 | 11590-11591, 11961-11962 | **Conforme** |
| **C(1)(a)-(b)** | comme B(1) | 3310-3312 ; 10923-10926 (définition complète) | **Conforme** |
| **C(2)(a)**, **C(2)(d)** | non vérifiables | 5113-5114 | **Conforme** (documenté) |
| **C(2)(b)** cinq exercices consécutifs | comme B(2)(b) ; le motif dit « années » | comme B | **Conforme** (un exercice est une année) |
| **C(2)(c)** données nettes | « brutes » refusé, 646-658 ; σ(res,s) sans NP, 723-736 | 2394-2398 ; 4217-4219 | **Conforme** |
| **C(2)(e)(i)-(iv)** | comme B(2)(g) ; motif « C(2)(e) » 1985 | `sec:h1`-`sec:h4` ; rectificatif ►C4 documenté avec sa référence exacte 10357-10362 | **Conforme** ; (iv) : interprétation déjà tranchée, comme en B |
| **C(3)** | comme B(3) | 2289-2333 | **Interprétation déjà tranchée** (#104) |
| **C(4)** σ(res,s,USP) | `usp_parametre()` ; `sigma_reserve` 724 | aucune transcription (E1) | Code **conforme** (chiffré ci-dessus) ; `.tex` : écart mineur E1 |
| **C(4)(e)** : le texte écrit « σ(prem,s) » | le code suit la formule, σ(res,s) | anomalie relevée en 2432-2437 | **Interprétation évidente, tranchée et documentée**. L'anomalie est dans le JOUE (p. 275) comme dans le consolidé ; la formule imprimée et l'art. 220(1)(b) désignent σ(res,s) |
| **C(5)**, **C(5)(d)**, **C(6)** | mêmes fonctions qu'en B | comme B | **Conforme** (images identiques à B) |
| Motif de refus en réserve n° 1, après #573 | `phrase_res2` retirée, 1979-2027 (`c5a1953`, `05fbe78`) | 4397-4398 **et** 4409-4410 annoncent encore « le rappel que la méthode n° 2 reste ouverte » | **Écart mineur de documentation, déjà connu** (#573, étape 7). La fiche KR ne cite que la l. 4398 : il faut y ajouter la l. 4409-4410. La l. 4444 (« ce point ouvrant aussi la méthode n° 2 ») est exacte au regard de l'art. 220(1)(b) |

Les numéros de page du JOUE cités par le `.tex` sont exacts. Pour l'annexe XVII : B(2)(g) p. 273, B(6) p. 274, C(2)(e)(i)-(ii) p. 274, (iii)-(iv) p. 275, C(6) p. 276. Pour les articles : 117 à partir de la p. 74 (paragraphe 3, cité p. 75 ; seul le début d'article a été repéré), 148 p. 94, 219(1)(d) p. 143, 220 p. 144.

## Synthèse

- **Écart majeur : aucun.**
- **Écarts mineurs, documentation seulement (σ_USP et verdicts inchangés)** :
  - **E1.** Le `.tex` transcrit la section D sous sa forme imprimée (l. 14446), mais pas B(4)-(6) ni C(4)-(6). La formule du paramètre B(4)/C(4), avec σ(prem,s) et σ(res,s), n'est écrite nulle part ; B(5) et B(6) n'y figurent que sous des formes équivalentes, exactes. C'est un défaut de traçabilité pour le dossier, pas de justesse.
  - **E2.** Les notations (l. 3311) ne reprennent pas la définition de B(1)(a) (évaluation après la première année de développement). L'équivalence « année de survenance » = « année d'accident » (A(1)(a)) n'est écrite nulle part.
  - **E3.** Les l. 4397-4398 et 4409-4410 sont dans le périmètre de #573 : à couvrir à l'étape 7, puis contrôle aval à l'étape 8. Pas d'issue nouvelle.
- **Interprétations déjà tranchées et documentées** : bornes de γ et refus de #188 / #227 ; lecture (A) de la profondeur (#104) ; NP standard sur données nettes (M13) ; σ(res,s) en C(4)(e) ; indépendance des années lue dans la forme additive de B(6).
- **Point de vigilance V1, sans écart démontré** (à porter à `actuary`, pas au mainteneur). Si le démarrage retenu a γ̂ sur une borne alors qu'un autre démarrage à moins de 1e-6 de l'objectif minimal satisfait la condition de Kuhn et Tucker, le calcul est accepté (fiche `fiche:foc`, l. 11932-11934 ; l. 4471-4472), et σ̂ est pris au démarrage retenu, sur la borne.
  - Ce point n'est un minimiseur au sens de B(6) que si le minimum ne se trouve pas au-delà de la borne.
  - Non mesuré si ce cas est atteignable : le `.tex` ne rapporte aucun ensemble de ce genre sur les 101 jeux mesurés (constat sur les ensembles mixtes).
- **Hors lot, renvois** : valeurs des annexes II et XIV et section G (barèmes) ; #504 (règlement 2026/269, art. 117 et 148).

## Issue proposée (à créer sur accord du mainteneur ; non créée)

**Titre** : docs: transcription imprimée de l'annexe XVII, B(4)-(6) et C(4)-(6), et définition de y_t selon B(1)(a)

**Libellés** : `bug`, `needs-triage`

**Corps** :

> *Rédigé par l'agent regulatory (IA).*
>
> ## Constat (matrice de conformité de KR, lot 2, code au gel `a2f9c3a`)
> - Le moteur est conforme à l'annexe XVII, B(4)-(6) et C(4)-(6). Un contrôle par transcription littérale indépendante donne σ_USP à 2e-8 près en relatif et π_t, σ̂ et le critère à 2,3e-11 près, sur `donnees_ln.csv` et `donnees_ln_interieur.csv`, méthodes premium et reserve1.
> - En revanche, `docs/latex/doc_tests_usp.tex` ne transcrit nulle part ces paragraphes sous leur forme imprimée, comme il le fait pour la section D (l. 14446, « Spécification réglementaire »).
>   - La formule B(4) / C(4), σ_(prem,s,USP) = c·σ̂(δ̂,γ̂)·√((T+1)/(T−1)) + (1−c)·σ_(prem,s), avec σ_(res,s) en C, n'apparaît pas comme telle. On ne la trouve qu'implicitement (l. 13290, 13408, 14435).
>   - B(5) est donnée sous la forme σ̂ = β̂·e^γ̂ (l. 3333-3341). B(6) est donnée sous la forme profilée, avec ln β̂ à la place de ln σ̂ − γ̂ (l. 11622-11626). Ces formes sont exactes, mais ce ne sont pas celles du texte.
> - Les notations (l. 3309-3312) disent y_t « pertes agrégées » sans la définition de B(1)(a) : paiements effectués et meilleures estimations de la provision pour sinistres à payer, après la première année de développement suivant l'année d'accident.
> - L'équivalence « année de survenance » (terme du document) = « année d'accident » (A(1)(a)) n'est pas écrite.
>
> ## Attendu
> - Dans `sec:notations` (ou une sous-section « Spécification réglementaire » des méthodes lognormales) : transcription imprimée de B(4)(a)-(e), B(5) et (d)(i)-(ii), B(6) et (a)-(d), dernier alinéa compris, avec les pages du JOUE (L 12 du 17.1.2015, p. 273-274 pour B, p. 275-276 pour C). Puis la démonstration d'équivalence avec les formes du moteur (`usp_pi()`, `usp_noyau()`, `usp_parametre()`) et le renvoi à l'anomalie de C(4)(e) (l. 2432-2437).
> - Ajouter aux notations la définition de B(1)(a) et l'équivalence de terminologie avec A(1)(a).
> - Aucun changement du moteur, aucun résultat changé.
>
> ## Circuit
> Circuit 4 (documentation seule) : `docwriter`, puis `regulatory` (formule réglementaire touchée). Après la remise, sauf décision contraire du mainteneur.
>
> ## Renvois
> - Matrice de conformité de KR, lot 2 (`docs/revues/20261114-passage-de-remise/regulatory-matrice-lot2.md`).
> - Refs #573 (l. 4397-4398 et 4409-4410, autre objet, traité à l'étape 7 de KR).
