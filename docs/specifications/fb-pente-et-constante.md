# Spécification de Fb : pente (R4) et constante (TOST, seuil de rejet de la constante) — point d'arrêt D1-Fb (#230, #218, #298, #314)

> *Rédigé par l'agent actuary (IA)* (fiche `actuary-approfondi`, Opus, effort high ; pas de Fable, décision du mainteneur du 15/10/2026), le 15/10/2026, sur demande de la session principale. Étape 3 de la branche Fb (`claude/pente-et-constante`, PR #318, tête `db1e635`). Versionné par la session principale. Décisions déjà prises le 15/10 (E-15/10 (Fb)) :
> - Q-Fb-3, option (ii) sur la forme ; le fond est l'objet du présent document ;
> - Q-Fb-4, #298 restitué en diagnostic décidé dans `usp_tests()`, sous réserve de D1-Fb ;
> - Q-Fb-5, Δ = 10 % ȳ conservé.
>
> Contrainte C-Fb-1 : `add()` et `engine_registre_tests()` ne sont pas modifiés. La spécification la respecte (§ 3.3).

**Marques** : **[V]** vérifié (source citée, ou commande exécutée et sortie lue) ; **[H]** hypothèse ; **[NV]** non vérifié.

## 0. Objet, sources, mesures

**Objet.**
- **#218, #230** : sort de la règle R4 (classement de la ligne de la pente en test ou en diagnostic selon π̂_b ≥ 1/2).
- **#298** : restitution de la ligne TOST quand aucune constante estimée ne peut conduire à conclure l'équivalence.
- **#314** : seuil de rejet de la constante dans le `detail` de la ligne « Nullité de la constante ».
- **Décomptes « au moins un ECHEC »** du `.tex` : script et sort.

**Sources lues [V].**
- `docs/feuille-de-route.md` : fiche « Branche Fb » (l. 1623-1669 : tableau des étapes, constats 1 à 5, C-Fb-1 à C-Fb-6) ; ligne E-15/10 (Fb) (l. 1899) ; Q-Fb-3 à Q-Fb-5 (l. 2797-2799).
- Issues : #230 et son commentaire 6198669259 ; #218 et son commentaire 6198667904 ; #298, #314 ; #222 et son commentaire 6056113816.
- `docs/revues/20261015-pertinence-tests-graphiques.md` (l. 39, 67-68, 169-171, 317, 321, 348, 364) et son bloc 2 (§ 4.1, 4.2, 4.3, 4.10, 6, 8).
- ADR 0001 : texte, amendements des 22 et 23/09, notes des 27 et 30/09, annotation du 06/10.
- ADR 0002 : amendement du 06/10, points 1 à 5, dont le point 4 et ses annotations des 07 et 09/10.
- `CONTEXT.md` : « Test inopérant » (l. 51), « Test sans p-value retenue » (l. 55), « Indice d'identifiabilité de la pente » (l. 86), « P-value retenue » (l. 144).
- `R/engine.R` à `db1e635` : `SEUIL_ECHEC_SENS_REJETER` (l. 214) ; `usp_identifiabilite_pente()` et `SEUIL_PUISSANCE_PENTE` (l. 2716-2752) ; `SENS_PITMAN_PENTE`, `.pitman_unilateral()`, `engine_permutations()`, `usp_permutation_pente()` (l. 2790-2860) ; `usp_poids_gls()`, `.usp_lm_pondere()`, `test_tost_intercept()`, `test_intercept()` (l. 2991-3156) ; `add()` d'`engine_registre_tests()` (l. 3900-4233) ; lignes constante, TOST, pente et Fisher d'`usp_tests()` (l. 4870-5114).
- `R/display_helpers.R` : `type_ligne()` (l. 204-217), légende des natures (l. 2075-2087). `app.R` l. 383-386.
- Tests unitaires et scripts : `tests/unitaires/test_inoperance.R` (l. 453-505, 695-720, 1051-1175) ; `tests/patcher_reference.R` (en-tête) ; `tests/concordance_doc_moteur.R` (l. 933-975, 1252-1253) ; `tests/p_conditionnelle_regime_t8.R` (l. 747-751, 1265-1300, 2412) ; `tests/outils_tests.R` (`CAS`).
- `docs/latex/doc_tests_usp.tex` : l. 4573-4610 (règles R4 et R5) ; fiche `fiche:tost-constante` (l. 7375-7586, dont rubriques 5 et 6) ; l. 8676, 14800-14825, 14975-14990, 16706-16715.
- `docs/tableaux/20261008-issue220-pitman.md` (C6.a, C6.d) et `docs/tableaux/20261010-issue229-p-conditionnelle-regime.md` (agrégats, l. 2020-2035).

**Mesures exécutées [V].**
- **(M1)** Lignes constante, TOST et pente des cinq références lognormales (`readRDS`, lecture seule).
- **(M2)** Sur J1 (`tests/donnees/donnees_ln.csv`) et J2 (`donnees_ln_interieur.csv`) : `usp_ajuster()`, `.usp_lm_pondere()`, `test_tost_intercept()`, `usp_identifiabilite_pente()` → se(â_w), Δ, ρ, p_plancher, seuil de rejet de la constante, λ̂, π̂_b.
- **(M3)** Simulation ad hoc sous le modèle ajusté. Statut : **constat de simulation, non versionné, à ne pas citer dans le dossier**. Paramètres : `usp_simuler()`, graine 20261015 ; 2 000 jeux pour J2, 1 000 pour J1 ; réajustement par `usp_ajuster()`, TOST aux poids réajustés, α = 0,10.

  | Jeu | p_plancher ≥ α | p_plancher ≥ 0,30 | Autres valeurs |
  |---|---|---|---|
  | J1 | 1 000 / 1 000 ; IC 95 % [0,9963 ; 1] | 998 / 1 000 | les 2 autres jeux sont des ECHEC non certains |
  | J2 | 189 / 2 000 = 9,45 % ; IC [8,2 ; 10,8] | 0 / 2 000 | parmi les 189 : 131 ALERTE, 58 ECHEC ; verdicts TOST d'ensemble OK 43,3 %, ALERTE 41,8 %, ECHEC 14,9 % |

  Les verdicts de J2 sont compatibles avec 43,6 / 41,0 / 15,3 % de #166. La valeur 9,45 % est compatible avec les 90,7 % de jeux remplissant la condition (constat C3 du `.tex`, fiche TOST). Le nombre de jeux sert à l'incertitude de Monte-Carlo, pas à l'erreur en T.

**Valeurs de base [V], (M1) et (M2).**

| | J1 (`premium`, `reserve1`, `premium_ii6`, `premium_net`) | J2 (`premium_interieur`) |
|---|---|---|
| δ̂ | 1 | 0,664 |
| ȳ | 85,005 | 91,614 |
| â_w ; se(â_w) | 3,587 ; 53,75 | −2,130 ; 5,688 |
| se(â_w)/Δ (Δ = 0,1 ȳ) | 6,324 | 0,621 |
| ρ = t₀,₉₀;₆ · se/Δ | 9,10 | 0,89 |
| p_plancher = 1 − F_t6(Δ/se) | 0,440 | 0,079 |
| TOST de référence | ECHEC, p = 0,4651 | ALERTE, p = 0,1313 |
| t₀,₉₅;₆ · se(â_w)/ȳ (α = 0,10) | 1,229 | 0,121 |
| idem à α = 0,05 (t₀,₉₇₅;₆) | 1,547 | 0,152 |
| constante, p retenue (Monte-Carlo) | 0,964 OK | 0,670 OK |
| t_b (MCO) ; λ̂ ; π̂_b unilatérale | 1,392 ; 1,783 ; 0,6461 | 14,83 ; 17,28 ; 1,000 |
| pente : p exacte, verdict | 4462/40320 = 0,1107 ALERTE | 1/40320 OK |

## 1. Doctrine commune (D1-Fb) : une ligne bascule sur l'atteignabilité, jamais sur une puissance estimée

Les trois issues de fond posent la même question : que dit une ligne de H1 quand les données ne peuvent pas trancher ?

L'outil a déjà une réponse, la règle R1. Sa forme actuelle :

> Une ligne de type test est restituée en diagnostic si **aucune valeur observée ne peut conduire au rejet de H0 au seuil α**.

Cette règle vaut **quel que soit le sens** [V] :
- `add()`, l. 4080 : `p_min >= alpha` → diagnostic, sans condition sur `sens` ;
- commentaire l. 4024-4025 : « en sens "rejeter", un OK exige p < alpha » ;
- précédent de la pente : y = (1, 1, 1, 1, 2), p_min = 0,2 → diagnostic (ADR 0001, annotation du 06/10).

Pour une ligne de sens « ne pas rejeter », R1 retire un OK acquis d'avance. Pour une ligne de sens « rejeter », elle retire une issue où la propriété à établir ne peut pas l'être.

**Principe proposé (à inscrire dans les annotations des ADR 0001 et 0002).** Le classement test / diagnostic d'une ligne repose sur une propriété **exacte, conditionnelle aux données** : l'inatteignabilité du rejet au seuil α, à quantités observées fixées. Il ne repose jamais sur une **puissance estimée au point ajusté**.

Deux raisons :
1. Une puissance estimée est une variable aléatoire. Un classement binaire sur elle est instable près de son seuil : c'est ce que mesure #218 (λ̂ = 1,783 à 4 % des seuils ; classement bootstrap identique à l'observé dans 93,5 % des tirages en unilatéral, 63,5 % en bilatéral — mesure de #218, constat de simulation).
2. Elle est calculée dans un modèle que les données peuvent contredire. C'est le cas à r < 0 (#230) : le réajustement impose β > 0, σ̂ est gonflé, π̂_b passe sous 1/2.

À l'inverse, R1 et #165 reposent sur des inégalités exactes : p ≥ p_min sous la loi de référence discrète, p_TOST ≥ p_plancher.

Conséquences :
- R4 classe sur une puissance estimée : elle quitte le classement (§ 2).
- Le TOST relève de l'inatteignabilité : il entre dans le classement (§ 3), par une règle sœur de R1 décidée dans `usp_tests()`.
- La constante (nullité) reste un test ; le `detail` dit seulement à partir de quelle taille elle peut être rejetée (§ 4).

**Hoenig et Heisey (2001), *The American Statistician* 55(1), 19-24.** Données bibliographiques confirmées [V], recherche du 15/10/2026 ; texte intégral non relu, accès refusé depuis la session [NV].
- Selon des sources secondaires seulement, l'article établit que la puissance « observée » est une transformation de la p-value.
- π̂_b n'est **pas** une fonction de la p de Pitman : elle est calculée sur β̂ et σ̂ de `usp_ajuster()`, non sur t_b (J1 : t_b = 1,39, λ̂ = 1,78) [V].
- L'argument de l'article ne s'applique donc pas à la lettre.
- La doctrine ci-dessus ne repose pas sur lui : elle repose sur la cohérence avec R1 et sur les mesures de #218 et #220. L'article ne peut être cité qu'au titre de « limite connue de la puissance a posteriori », avec ce statut.

## 2. Ligne de la pente : R4 (#218, #230)

### 2.1 Ce que teste la ligne ; validité à T = 8

- **Hypothèses.** H0 « Y₁…Y_T échangeables, indépendants de x » ; H1 « lien positif ». C'est une condition nécessaire de E[Y_t] = βx_t avec β > 0 (annexe XVII, B(2)(g)(i) ; β > 0 déduit du texte, ADR 0002).
- **Résidus.** Échelle brute (x, y), sans résidus du modèle.
- **p-value.** **Exacte** par énumération des 8! appariements, sous H0 seule (second fondement de l'ADR 0002). Sa validité à T = 8 ne dépend ni d'une loi limite ni d'une vitesse de convergence.
- **Réserve d'échangeabilité** (ADR 0002, point 5) : taille 0,096 à 0,268 sous des H0 faibles, 0,332 sous une marche aléatoire sur J1 (#220, constats de simulation).
- **Puissance unilatérale à α = 0,10**, sans R4, sous le modèle ajusté : 0,641 [0,634 ; 0,648] sur J1, 1,000 sur J2 (#220, R = 20 000, constats de simulation).
- **Verdict : pertinent.** La règle R4 qui l'accompagne est, elle, **à remplacer** (§ 2.3).

### 2.2 Ce que fait R4 ; défauts établis

R4 (l. 4987-5028) classe la ligne en diagnostic si π̂_b = P(t > t₁₋α,T−2 | ncp = λ̂) < 1/2. On a λ̂ = √(T−1) · CV(x) · β̂/σ̂, approximation au premier ordre sous le modèle auxiliaire MCO (`CONTEXT.md`). Trois défauts :

- **(D1) Instabilité près du seuil (#218).** Mesure de #218 citée au § 1.
- **(D2) Contresens à r < 0 (#230).** Sous la pente négative simulée, la ligne restituée sort, sur J1, diagnostic « PENTE NON IDENTIFIABLE » 77,5 % et ECHEC 21,3 % ; sur J2, diagnostic 99,93 % ; alors que le test rend ECHEC dans 98,8 % et 100 % des jeux (#220, C6.d, l. 80, 83, 86-87 [V]).
- **(D3) Effet faible quand le modèle est vrai.** Sur J1, les modalités de la ligne passent avec R4 de OK 64,1 % → 61,8 % ; ALERTE 25,0 % → 22,9 % ; ECHEC 10,9 % → 9,1 % ; diagnostic 0 % → 6,1 % (#220, C6.a [V]). Sur J2, aucun effet. R4 retire donc 1,8 point d'ECHEC sous le modèle, au prix de (D1) et (D2).

### 2.3 Options et avis

- **(i) R4 supprimée, π̂_b non restituée.** Fondée sur le fond : le classement disparaît, #230 est réglée (la ligne reste un test, ECHEC à r < 0). Elle prive cependant le lecteur de la seule indication, propre au jeu, de la puissance du test à son plan de volumes. Les tables de puissance de la fiche ne valent que pour J1 et J2.
- **(ii) R4 réduite à une phrase de contexte, sans classement ni repère.** **Recommandée**, avec les précisions du § 2.4. Elle a l'effet de (i) sur le type et le verdict, et garde l'information de plan d'expérience, comme la phrase de #165 pour le TOST.
- **(iii) R4 conservée, plus #230 option (a), plus intervalle bootstrap de #218.** **Écartée** : elle garde un classement sur une quantité estimée, ce que la doctrine du § 1 exclut ; elle ajoute une règle de restitution lue sur le bootstrap, dont le `detail` ne pourrait imprimer aucun quantile (règle #76), d'où une phrase fixe de plus, à côté de #204, #244 et #257 ; la complexité reste dans `usp_tests()`.

**Coût de (i) ou (ii) [V], #220 C6.a.** Sous le modèle ajusté à J1, la ligne rend ECHEC dans 10,9 % des jeux au lieu de 9,1 %. Ces ECHEC sont des non-rejets d'un test unilatéral de puissance 0,64 : une absence de preuve de lien positif, que le `detail` qualifie. Sur J2, aucun coût.

### 2.4 Forme recommandée (ii), précisée

1. **Classement.** `type_pente` vaut « non applicable » si la ligne ne l'est pas, « test » sinon. La bascule par R1 reste dans `add()`, inchangée. `SEUIL_PUISSANCE_PENTE` est **retirée** du moteur.
2. **Phrase de contexte** (remplace `txt_ident`), si π̂_b est finie **et** t_b > 0 (`lmc$t_pente > 0`, même signe que r) :

   > `Puissance approchee a posteriori du test unilateral sous le modele ajuste (au point estime ; approximation au premier ordre, loi de Student decentree) = %.2f, indice lambda = sqrt(T-1) CV(x) beta / sigma = %.2f : contexte de lecture, sans effet sur le type ni sur le verdict.`

   Cette phrase ne contient ni « identifiable », ni repère (« 0.5 », « >= », « < »).

   Si π̂_b est finie et t_b ≤ 0 :

   > `Lien observe nul ou negatif (r <= 0), de signe contraire au modele (beta > 0) : puissance approchee sous le modele ajuste non restituee (calculee sous beta > 0, sans objet ici).`

   Si π̂_b n'est pas finie : aucune phrase, comme aujourd'hui.
3. **Sens du test.** `txt_sens` est dérivé de `SENS_PITMAN_PENTE` (#222, point 5), non écrit en dur.
4. **Inchangés.** Le reste du `detail` (`txt_pitman`, `txt_plancher_perm`), les champs numériques, `usp_identifiabilite_pente()` (appelée pour la phrase seulement), la ligne Fisher.
5. **Garde.** `pente_reste_test` est réduite à la condition R1. La mention « Plancher 1/(B + 1) >= alpha : OK inatteignable » apparaît désormais aussi sur les lignes que R4 classait en diagnostic (cas T = 10, B = 9 de `test_inoperance.R` l. 702).
6. **Scripts hors CI qui lisent `SEUIL_PUISSANCE_PENTE`** : `tests/taux_franchissement_reperes.R` (l. 371-394), `tests/constats_puissance_t8.R` (l. 268-1783), `tests/p_conditionnelle_regime_t8.R` (l. 2412). Chacun définit une constante locale `SEUIL_PUISSANCE_PENTE_R4 <- 0.5`, commentée « règle R4 retirée par D1-Fb (#218, #230) ; reproduit la règle des mesures antérieures ». Leurs tableaux versionnés ne sont pas réécrits. Le test de `tests/unitaires/test_concordance_doc_moteur.R` (l. 953-957) n'emploie le nom que comme donnée de test : inchangé.

### 2.5 Effets (#230, #218)

- **Références** : `detail` de la pente sur les cinq cas, et lui seul. J1 : phrase 0.65 / 1.78 ; J2 : 1.00 / 17.28.
- **Patch chirurgical** : type, verdict et toutes les valeurs numériques inchangés (constat 1 de la fiche Fb).
- **Hors références** : à r ≤ 0, la ligne est un test, presque toujours ECHEC (borne exacte p_uni ≥ P(r* ≥ 0) à r_obs < 0) ; sur un plan à CV(x) faible, la ligne est un test au lieu d'un diagnostic.
- σ_USP inchangé.

### 2.6 Critères d'acceptation de l'étape 4

- **(a)** Sur un jeu à r < 0 construit (y positifs décroissants en x, `usp_ajuster()` convergé), la ligne est de type test, verdict ECHEC. Le `detail` contient « Lien observe nul ou negatif » et ne contient ni « IDENTIFIABLE » ni « Puissance approchee a posteriori ».
- **(b)** Jeu à CV(x) = 3 % (`t03` de `test_inoperance.R`) : type test (diagnostic avant), phrase présente avec π̂_b < 0,5 imprimée, aucun repère.
- **(c)** J1 : p exacte 4462/40320, verdict ALERTE, phrase « = 0.65 », « = 1.78 ».
- **(d)** `exists("SEUIL_PUISSANCE_PENTE", envir = environnement du moteur)` est FALSE. Aucune ligne de la pente n'est de type diagnostic sans `inoperant = TRUE`, sur les jeux unitaires existants.
- **(e)** Cas T = 10, B = 9 : `l4` est un test portant la mention du plancher ; `l1` (R1) est inchangé.
- **(f)** Tableau avant / après ; `comparer_references.R --seuil 0` ne montre que les chaînes `detail` de la pente.
- **(g)** Contrôle d'identité hors CI (§ 6.1).

## 3. TOST : restitution quand l'équivalence n'est pas démontrable (#298)

### 3.1 Ce que teste la ligne ; validité à T = 8

- **Hypothèses.** H0 |a| ≥ Δ, H1 |a| < Δ dans lm(y ~ x) pondérée (poids GLS estimés, #215), Δ = 0,10 ȳ (marge estimée). La ligne établit la proportionnalité pratique : sens « rejeter ».
- **p-value.** max(p_bas, p_haut) sous t(T − 2), **approchée** : poids estimés, marge estimée. Hors hiérarchie (ADR 0002, point 3, annotation du 07/10).
- **Niveau** à la frontière a = +Δ sur J2 : 13,3 % [12,8 ; 13,7] à 10 % (#219, un point des paramètres de nuisance). Le niveau sur l'hypothèse nulle composite n'est pas mesuré.
- **Puissance** au point a = 0 : 0,0 % sur J1 (structurel), 43,5 % sur J2 (C3).
- **Verdict : fragile** sur des volumes peu dispersés, **à compléter** en général (Δ sans source, renvoyé à Fl/#315 par Q-Fb-5).
- #298 ne règle pas la validité de la loi. Elle corrige une restitution qui affiche un ECHEC acquis d'avance.

### 3.2 Prédicat

L'inégalité p_TOST ≥ p_plancher = 1 − F_{t,T−2}(Δ / se(â_w)) est **exacte** à se(â_w) et Δ réalisés, quelle que soit la constante estimée [V] : p = max(P(T > (â + Δ)/se), P(T < (â − Δ)/se)) est minimal en â = 0 ; l'égalité vaut en â = 0 ; l'inégalité est vraie pour la p calculée, quelle que soit la validité de la loi t(T − 2) (fiche TOST, l. 7561-7566).

Deux seuils possibles :
- **(α) recommandé.** Diagnostic si **p_plancher ≥ α** (OK inatteignable ; équivaut à ρ = t₁₋α,T−2 · se/Δ ≥ 1 en arithmétique exacte).
  - C'est l'exact analogue de R1 : aucune constante estimée ne peut conduire au rejet de H0 au seuil α, ce qui est le critère que R1 applique déjà aux lignes de sens « rejeter ».
  - Ce prédicat est déjà la condition de branche de #165 (« condition nécessaire de conclusion non remplie »). Le type et le `detail` ne peuvent donc pas se contredire.
  - Borne incluse, comme R1 (décision du 26/09).
  - Le statut dépend de α : J2 est un test à α = 0,10 (p_plancher = 0,079) et un diagnostic à α = 0,05 [V].
- **(0,30) alternative.** Diagnostic si **p_plancher ≥ `SEUIL_ECHEC_SENS_REJETER`** (OK et ALERTE inatteignables, ECHEC certain). C'est le texte de #298 et de Q-Fb-4. Il laisse en test, avec ALERTE ou ECHEC possibles, des lignes où l'équivalence est impossible à conclure, ce que R1 refuse pour toute autre ligne. Mesure (M3) : 2 jeux sur 1 000 de J1 resteraient des ECHEC « test » alors que l'OK y est inatteignable, et aucun jeu de J2 ne basculerait.
- **Les cinq références sont identiques sous les deux seuils** [V] : p_plancher vaut 0,440 sur les quatre cas à δ̂ = 1, 0,079 sur `premium_interieur`.

**Calcul.** p_plancher est calculée **une fois** dans `usp_tests()`, sur la branche calculée du TOST (`tost$non_applicable` NA), et lue par le type et par le `detail`. Les branches non applicables (volumes constants, pertes constantes, marge, x écarté, statistique non définie) sont inchangées et gardent la priorité.

### 3.3 Restitution (C-Fb-1 respectée)

`usp_tests()` passe `type = "diagnostic"` à `add()` quand le prédicat est vrai. Sans modification d'`add()`, cela donne [V], lecture de l. 4195-4230 :
- `p_retenue = NA`, `nature_p = NA`, `sens = NA`, verdict INFO ;
- `p_asymptotique` = p du TOST, conservée (« la p-value toujours affichée », dans son champ) ;
- `stat`, `estim` (Δ), `loi` inchangés ;
- `p_min` reste NA : le plancher n'est pas celui d'une loi de référence discrète ;
- `inoperant = FALSE`. Le champ est réservé à la bascule R1 (#129) ; l'affichage (`type_ligne()`) montrera « diagnostic » sous le badge INFO.

**La voie R1 n'est pas utilisable** : passer `p_min = p_plancher` avec une p non simulée seule déclenche le `stop()` de l. 4052 [V]. La décision dans `usp_tests()` est donc la seule voie qui respecte C-Fb-1. **Aucun arrêt n'est requis.**

**Option écartée : garder la p retenue avec un verdict INFO forcé** (`type = "test"`, `verdict = "INFO"`, admis par `add()`). Elle créerait un état nouveau, « test à p retenue sans verdict », contraire à l'entrée « Verdict » (le verdict d'un test se lit sur sa p retenue). L'ADR 0001 (M7) interdit les verdicts forcés.

### 3.4 Phrase du `detail` (branche diagnostic)

Elle remplace la phrase de #165 de la branche « non remplie ». La branche « remplie » est inchangée, octet pour octet.

```
EQUIVALENCE NON DEMONTRABLE AVEC CES DONNEES au seuil alpha = %g : t(1-alpha, T-2) x se(a) / Delta = %.2f >= 1, soit p >= p_plancher = %.3f >= alpha quelle que soit la constante estimee : OK inatteignable%s ; aucun verdict (ADR 0001). Delta = %s (valeur : estimation "marge Delta") ; p_bas = %.4f, p_haut = %.4f ; p du TOST (champ p asymptotique : loi de Student sous le modele auxiliaire pondere, poids estimes) non retenue. L'equivalence ne peut pas etre conclue avec ces donnees (plan de volumes, dispersion residuelle) et cette marge : absence de preuve, non ecart a la proportionnalite.
```

Champs variables :
- `%s` après « OK inatteignable » : `", et meme p >= 0.3 : ALERTE inatteignable"` si p_plancher ≥ `SEUIL_ECHEC_SENS_REJETER`, chaîne vide sinon. Le nombre 0.3 est construit depuis la constante.
- `Delta = %s` : comme aujourd'hui (« marge fixee a priori » ou « 10 % de la moyenne de y »).
- Aucun nombre issu du bootstrap n'est imprimé (#76) : p_plancher et ρ sont des fonctions déterministes des données.
- Le préfixe n'est **pas** « TEST INOPERANT », réservé à R1 (#129).

Sur J1, le texte imprime ρ = 9.10, p_plancher = 0.440, « , et meme p >= 0.3 : ALERTE inatteignable », p_bas = 0.4148, p_haut = 0.4651.

### 3.5 Articulation

- **#165** : son prédicat devient celui du type. Sa phrase est reprise dans la branche diagnostic, et la sous-branche « OK inatteignable » est absorbée par elle (seuil α).
- **R1** : indépendante. Le TOST n'a pas de `p_min`, et la règle nouvelle ne passe pas par `add()`. Nom proposé : **règle R14 (équivalence non démontrable)**, sœur de R1 ; numéro libre [V] (R1 à R13 employés dans le `.tex`).
- **#181 et la hiérarchie** : sans objet, le TOST n'a pas de `mc_nom`.
- **#244 et la mention du plancher** : sans objet, elles ne valent que pour un type test.
- **ADR 0002, point 3** (« le TOST est la seule ligne dont la p retenue est hors hiérarchie ») : à lire « quand il est un test ».
- **Δ** : la règle vaut pour toute valeur de Δ et pour la marge a priori (`delta_equiv`). ρ varie comme 1/Δ (C-Fb-3).

### 3.6 Décomptes « au moins un ECHEC »

Un diagnostic sort INFO : la ligne quitte d'elle-même tout décompte d'ECHEC. **Constat** : la fiche Fb (constat 4) et le corps de #298 se trompent de ligne [V].
- Les chiffres de l'encadré final (`.tex` l. 16712-16714 : 37,55 %, 39,95 %, 42,7 %) **excluent déjà** le TOST et la pente : l. 14800-14815, « celles de sens "rejeter" — pente et TOST » mises à part ; l. 14984-14987, « TOST, pente et procédure ESD exclus ». Ils ne changent pas. Les deux premiers sont recalculés en R de base depuis les valeurs brutes de #166 ; le troisième depuis le fichier brut de la partie régime.
- Les chiffres **« TOST compris »** sont l. 8676 et l. 14987-14988 : J2, 48,35 % (V1) et 50,5 % (V3h) ; J3, 44,25 % et 50,05 %. Ils sont produits par **`tests/p_conditionnelle_regime_t8.R`** (agrégats « toutes les lignes », l. 1265-1300 du script ; fichier de résultats `docs/tableaux/20261010-issue229-p-conditionnelle-regime.md`, tableau d'agrégats l. ~2022, où J1 vaut 1,0000, « saturé » par le TOST).
- Sort : Q-D1-Fb-5.
- Les fichiers bruts ne contiennent pas se(â_w) [V] : une remesure exacte exige de réajuster les jeux de chaque réplication.

### 3.7 Effets (#298)

- **Références** : sur `premium`, `reserve1`, `premium_ii6` et `premium_net`, la ligne TOST change ainsi : type test → diagnostic ; verdict ECHEC → INFO ; `p_retenue` 0,4650739 → NA ; `nature_p` « sous le modele auxiliaire pondere : … marge estimee sur les donnees » → NA ; `sens` « rejeter » → NA ; `detail` : nouvelle phrase. `p_asymptotique`, `stat`, `estim` et `inoperant` sont inchangés. `premium_interieur` est inchangé.
- **Toutes les grandeurs modifiées sont des chaînes ou des NA** : **patch chirurgical**, sans régénération. `tests/patcher_reference.R` accepte « des chaînes, des booléens, des NA » et refuse tout nombre fini posé [V], d'après l'en-tête ; essai à blanc à faire par `coder` [H].
- **Visa du mainteneur** sur les quatre verdicts.
- **Décomptes de la concordance** (`grandeurs_moteur()`, l. 933-975) sur les quatre cas : « nature modele auxiliaire pondere » −1 ; « type test » −1 ; « type diagnostic » +1 ; « sans p-value retenue » +1. Écart de concordance à corriger aussitôt par un commit `docs:` minimal (M32).
- σ_USP inchangé.
- **Hors références** : J1, 100 % des jeux simulés en diagnostic ; J2, 9,45 % sous le seuil α et 0 % sous le seuil 0,30 (M3, constat non versionné).

### 3.8 Critères d'acceptation de l'étape 6

- **(a)** J1 : champs du § 3.3. `detail` commençant par « EQUIVALENCE NON DEMONTRABLE AVEC CES DONNEES au seuil alpha = 0.1 : », contenant « = 9.10 >= 1 », « p_plancher = 0.440 », « ALERTE inatteignable », et pas « TEST INOPERANT ». `p_asymptotique` est identique à `test_tost_intercept()$p`.
- **(b)** J2 : ligne identique à l'actuelle (`identical()` sur la ligne).
- **(c)** Frontière, sur le gabarit de `test_inoperance.R` l. 1112-1150 : `delta_equiv = se · t(q ; 6) · k`, k = 1,005 et 1/1,005. q = 0,90 : k = 1,005 → test ; k = 1/1,005 → diagnostic sans « ALERTE inatteignable ». q = 0,70 : k = 1/1,005 → diagnostic avec « ALERTE inatteignable ».
- **(d)** Dépendance à α : J2 à α = 0,05 → diagnostic.
- **(e)** Propriété sur les 30 séries de la graine 165 (l. 1159) : type diagnostic si et seulement si p_plancher ≥ α ; jamais un type test dont le `detail` dit « OK inatteignable ».
- **(f)** Les branches non applicables sont inchangées.
- **(g)** `git diff` vide sur `add()` et `engine_registre_tests()`.
- **(h)** Tableau avant / après des quatre cas ; patch ; visa.

## 4. Seuil de rejet de la constante (#314)

**Ligne.** Test de a = 0 dans la même régression pondérée (B(2)(g)(i)). p retenue **Monte-Carlo** sous le modèle ajusté (règle R5), calibrée : niveau 0,109 et 0,098 sur J1 et J2 (bloc 2, § 2). Puissance quasi nulle à faible CV(x). **Verdict : pertinent pour le niveau, à compléter pour l'information.**

**Quantité.** c_α = t₁₋α/₂,T−2 · se(â_w), rapportée à ȳ.
- C'est la plus petite valeur de |â_w| pour laquelle la **p de Student** du modèle auxiliaire pondéré passe sous α : le seuil de rejet en |â|.
- Ce n'est ni un résultat exact pour la p retenue, qui est de Monte-Carlo et n'a pas exactement ce seuil, ni une « constante détectable » au sens d'une puissance fixée.
- Une constante vraie de cette taille serait rejetée environ une fois sur deux sous la même approximation [H]. C'est l'ordre de grandeur que la documentation peut dire, pas le `detail`.
- se(â_w) est lu sur la régression pondérée partagée de #222 (point 1), non recalculé.

**Phrase** (insérée après « … voir le test d'equivalence ci-dessous. », branche calculée seulement, avant le renvoi posé par `.usp_poser_renvois()`) :

> `Seuil de rejet de la constante au seuil alpha = %g : |a| >= t(1-alpha/2, T-2) x se(a) = %.0f %% de la moyenne de y (loi de Student du modele auxiliaire pondere, approchee ; la p retenue, de Monte-Carlo, n'a pas exactement ce seuil).`

Valeurs : J1 « 123 % » ; J2 « 12 % » ; à α = 0,05 : 155 % et 15 %.

**Effets.** `detail` de la constante sur les cinq cas, et lui seul : patch chirurgical. Aucun champ, seuil, type ni verdict nouveau (ADR 0001).

**Critères.**
- **(a)** La valeur est recalculée par un test unitaire depuis un `lm(y ~ x, weights = usp_poids_gls(x, fit$pi))` indépendant : « 123 % » sur J1, « 12 % » sur J2, à α = 0,10.
- **(b)** Phrase absente sur les branches non applicables et à t non fini.
- **(c)** `comparer_references.R --seuil 0` : seules les chaînes visées changent.

## 5. Effets attendus par cas de référence (récapitulatif)

| Cas | Pente (#230, #218) | Constante (#314) | TOST (#298) | σ_USP | Mode |
|---|---|---|---|---|---|
| `premium`, `reserve1`, `premium_ii6`, `premium_net` | `detail` (0.65 ; 1.78), test, ALERTE inchangé | `detail` (+ « 123 % ») | test → diagnostic, ECHEC → INFO, `p_retenue` → NA, `nature_p` → NA, `sens` → NA, `detail` | inchangé | trois patchs, un par commit |
| `premium_interieur` | `detail` (1.00 ; 17.28), OK inchangé | `detail` (+ « 12 % ») | inchangé (ρ = 0,89) | inchangé | deux patchs |
| `reserve2` | — | — | — | — | aucun |

## 6. Mesures hors références

### 6.1 #230 : ligne C6 de #220

Sans R4, la ligne restituée **est** le test (protocole P1). Les modalités sous la pente négative sont donc celles déjà mesurées (C6.d, l. 80 et 83 [V]) : J1, OK 0,18 %, ALERTE 0,98 %, ECHEC 98,83 % ; J2, ECHEC 100 %.

Aucune simulation nouvelle n'est nécessaire. Contrôle d'identité demandé à `coder`, hors CI : les 200 premiers jeux de G4 (J1, graine 20260941, générateur de `tests/constats_puissance_t8.R`), passés dans `usp_tests()` avec `boot_fictif` ; attendu : ligne de type test dans 200/200, verdict égal à celui de la p de `usp_permutation_pente()` dans 200/200.

Le tableau `20261008-issue220-pitman.md` n'est pas réécrit : ses lignes « P2 avec R4 » décrivent l'état antérieur à Fb.

### 6.2 #298

Mesures (M3), non versionnées : elles éclairent Q-D1-Fb-2, elles ne se citent pas au dossier.

## 7. Tests unitaires attendus (récapitulatif)

- **`tests/unitaires/test_inoperance.R`** : réécrire l. 481-500 (R4 → § 2.6 (b), (c)) et l. 702-718 (§ 2.6 (e)) ; ajouter § 2.6 (a) et (d) ; TOST : l. 1065-1070 (quatre cas, texte nouveau), l. 1093-1104 (cas `delta_equiv = 50`, désormais diagnostic), l. 1131-1150 (frontières, § 3.8 (c)), l. 1159 (propriété, § 3.8 (e)) ; ajouter § 3.8 (a), (b), (d) et § 4 (a), (b).
- **`tests/unitaires/test_controles_entree.R`** (l. 2335, commentaire « Pente identifiable ») : vérifier les assertions associées.
- **À relire par `coder`** : `test_constante_ponderee.R`, `test_volumes_constants.R`, `test_defauts_connus.R` (mentions du TOST ; branches non applicables inchangées).

## 8. Surface documentaire (passage unique de `docwriter`, règle 9 ; exception M32 pour les écarts de concordance)

**`.tex`.**
- **R4** : l. 721, 2215 (index), 2860, 4397, 4500, 4555, 4576-4609 (règle R4 : retirée, remplacée par la phrase de contexte ; historique en une phrase), 4845, 5362, 5504 (`tab:nature`), 6468-6477, 6647 (`tab:tracabilite-puissance`), 7152-7155, 16083 ; fiche `fiche:student-pente` (l. 7588-7928 : 7657, 7740, 7771, 7786-7841, 7897-7920) ; fiche `fiche:fisher-global` (l. 7982-7985).
- **TOST** : fiche `fiche:tost-constante` (rubriques 5 et 6, l. 7540-7586 : règle R14, phrase, exemples J1 et J2) ; correction de « aucune p-value de Monte-Carlo n'est possible » (rubrique « p-value minimale », et l. ~7443, signalée par #298) : une simulation à la frontière a = ±Δ est possible (#219) ; elle n'est pas retenue, car elle dépend des paramètres de nuisance et ne garantit pas le niveau sur l'hypothèse nulle composite ; section « Nature des p-values » : règle R14 à côté de R1 ; `tab:nature`, `tab:conv` ; décomptes de lignes.
- **Constante** : fiche `fiche:student-constante` (l. 7223-7372), seuil de rejet et statut d'approximation.
- **Multiplicité** : l. 8676 et 14987-14988 selon Q-D1-Fb-5. L. 16712 inchangée.
- **Fichiers partagés avec Fd** (C-Fb-4) : `tab:nature`, `tab:conv`, `tab:pmin`, `tab:tracabilite-puissance`.

**ADR** (par `architect`).
- **ADR 0001** : annotation D1-Fb. Doctrine du § 1 ; R4 retirée comme règle de classement, sans repère ; R14 ajoutée : la phrase des Conséquences « le statut test / diagnostic peut changer avec les données et avec α » vaut désormais pour R1, R3 et R14 ; la note du 27/09 et l'annotation du 06/10 (« R4 conservée ») se lisent à l'état antérieur.
- **ADR 0002, point 4** : annotation. Puce « R4 conservée » → réduite à une phrase de contexte ; puce « un lien négatif donne ECHEC » (annotation du 09/10) : la ligne restituée est le test, la distinction test / ligne tombe ; point 3 : TOST hors hiérarchie « quand il est un test ».

**`CONTEXT.md`** (par `architect`).
- « Indice d'identifiabilité de la pente » : à renommer « Puissance approchée a posteriori de la pente (λ̂, π̂_b) », sans R4, avec historique.
- Entrée nouvelle « Équivalence non démontrable (règle R14) », sœur de « Test inopérant », plutôt qu'une modification de celle-ci, que Fd touche (paragraphe Merz-Wüthrich).
- « P-value retenue » et « Diagnostic » : mention du TOST diagnostic.

**Hors `.tex`.** Scripts hors CI (§ 2.4, point 6). Corps de #298 et constat 4 de la fiche Fb à corriger (§ 3.6). Étape 6 de la fiche : régénération → patch.

## 9. Circuit et ordre

- **Étape 4** (#230 + #218, un commit), **5** (#314), **6** (#298) : circuit 1, `coder` → `audit`, sans régénération. Trois patchs chirurgicaux, un commit par issue avec son tableau avant / après. Étapes 4 et 5 : `actuary` lit le tableau. Étape 6 : visa du mainteneur (verdicts). Commits `docs:` minimaux M32 à l'étape 4 (`SEUIL_PUISSANCE_PENTE` citée par le `.tex`) et à l'étape 6 (décomptes).
- **#314 et #298** supposent #222 point 1 fait (régression pondérée partagée, se(â_w) disponible).
- **`app-review`** : non requis, l'affichage ne change pas. La légende des natures (`app.R` l. 383, `display_helpers.R` l. 2081) reste vraie.

## 10. Hors périmètre

- Valeur et justification de Δ (Fl, #315).
- Niveau du TOST sur l'hypothèse nulle composite ; p Monte-Carlo à la frontière.
- `usp_identifiabilite_pente()` par défaut bilatérale.
- Le sens du test de Pitman.
- `add()`, `engine_registre_tests()`, Merz-Wüthrich, l'affichage, σ_USP.
- Les autres lignes H2 à H4 (Fh).

## 11. Références

- **Pitman (1937)** et **Schuirmann (1987)** : déjà citées par le moteur et le `.tex` ; non relues ici [NV].
- **Hoenig, J. M. et Heisey, D. M. (2001)**, « The abuse of power: the pervasive fallacy of power calculations for data analysis », *The American Statistician* 55(1), 19-24 : statut au § 1 (données bibliographiques vérifiées, texte non relu).
- Aucune autre référence : les résultats invoqués (p ≥ p_plancher, p_uni ≥ P(r* ≥ 0) à r_obs < 0, seuil de rejet du t) sont des inégalités élémentaires, établies dans le texte.

## 12. Questions au mainteneur (D1-Fb)

- **Q-D1-Fb-1 — R4.** Option (ii), précisée au § 2.4 : phrase « a posteriori » sans classement ni repère, remplacée à t_b ≤ 0 par « lien observé nul ou négatif », `SEUIL_PUISSANCE_PENTE` retirée. Alternatives : (i) aucune phrase ; (iii) R4 instrumentée. *Recommandation* : (ii) telle que précisée.
- **Q-D1-Fb-2 — Prédicat de #298.** (α) p_plancher ≥ α, règle R14 sœur de R1, ou (0,30) p_plancher ≥ 0,30, texte de l'issue et de Q-Fb-4. *Recommandation* : (α), par cohérence avec R1 en sens « rejeter ». Références identiques dans les deux cas.
- **Q-D1-Fb-3 — Forme de #298.** Type diagnostic, `p_retenue` NA, p conservée dans `p_asymptotique`, `inoperant` FALSE, d'où un patch au lieu d'une régénération. Alternative : verdict INFO forcé sur un type test. *Recommandation* : diagnostic.
- **Q-D1-Fb-4 — Vocabulaire.** Entrée nouvelle « Équivalence non démontrable (règle R14) » dans `CONTEXT.md`, préfixe « EQUIVALENCE NON DEMONTRABLE AVEC CES DONNEES ». Alternative : extension de « Test inopérant », qui imposerait `inoperant = TRUE`, donc une modification d'`add()` et un arrêt selon C-Fb-1. *Recommandation* : terme nouveau.
- **Q-D1-Fb-5 — Chiffres « TOST compris »** (l. 8676, 14987-14988). (a) les dater (« règle de restitution du TOST antérieure à #298 ») et renvoyer aux chiffres hors TOST déjà donnés ; (b) les remesurer par un script versionné qui réajuste les jeux. *Recommandation* : (a).
- **Q-D1-Fb-6 — #314.** Nom « seuil de rejet de la constante » plutôt que « constante minimale détectable », en % de ȳ arrondi à l'unité. *Recommandation* : oui.
- **Q-D1-Fb-7 — Scripts hors CI.** Copie locale de la constante 1/2 dans les trois scripts. *Recommandation* : oui.
