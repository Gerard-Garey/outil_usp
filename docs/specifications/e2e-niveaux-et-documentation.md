# Spécification d'E2e : niveaux et documentation (#245, #243, #269, #270, #256)

> *Rédigé par l'agent actuary (IA), le 13/10/2026, sur la branche `claude/niveaux-et-documentation` (PR #272, tête `e2099fb`). C'est l'étape 1 de la fiche « Branche E2e » de `docs/feuille-de-route.md`. La spécification est soumise au point d'arrêt **D1** : aucun code de #269, #270 ni #245 avant l'approbation du mainteneur. #232 (étape 2) est hors de cette spécification. Les décisions de D1 seront reportées en annotation datée, en fin de document.*

**Marques** : **[V]** vérifié (source citée, ou commande exécutée et sortie lue) ; **[H]** hypothèse ; **[NV]** non vérifié.

## 0. Objet, sources, mesures, décisions déjà prises

**Objet.** Cinq numéros, dont quatre traités ici :
- **#245** : les deux lignes M5 (normalité des résidus de Mack) deviennent des diagnostics. On tranche aussi l'étiquette « exacte » de Shapiro-Wilk.
- **#269 et #270** : la courbure de M1 écarte une colonne à moins de trois valeurs distinctes de C(i,j). Il faut restituer cette exclusion (#269) et la figer dans les réplications (#270).
- **#243** : documentation seule, option (a).
- **#256** : niveaux V3h dans les rubriques 7 lognormales, et réponses aux trois questions du commentaire `6141086273`.

**Sources lues** **[V]** :
- `docs/feuille-de-route.md` : fiche « Branche E2e » (§ 3, constats 1 à 8, étapes 0 à 8, C-E2e-1 à C-E2e-6) ; Q-E2e-1 à Q-E2e-11 (§ 5), décidées le 13/10.
- Issues #245, #243 (avec le commentaire `6106731061`), #269, #270, #256 (avec `6141086273`) et #267. #245, #269 et #270 n'ont aucun commentaire.
- `R/engine.R` à `e2099fb` :
  - `add()` dans `engine_registre_tests()` (l. 3876-4200 ; branche « sans verdict », l. 4176-4186) ;
  - `NATURE_APPROX_N_FINI` (l. 3775), `engine_p_mc()` (l. 3657), `sw_loi_nulle()` et `sw_p_loi_nulle()` (l. 2066-2083), `.shapiro_sur()` (l. 1872) ;
  - `mw_residus()` (l. 7887), `.MW_LIGNES_RESIDUS` (l. 7538) ;
  - `.mw_exclure()`, `.mw_phrase_exclusion()`, `.mw_stat_non_definie()` (l. 8348-8383) ;
  - `mw_test_ordonnee_origine()` (l. 8394-8425), `.mw_courbure_colonne()` (l. 8543-8588), `mw_test_courbure()` (l. 8593-8626) ;
  - `mw_simuler_triangle()`, `.mw_tirer_triangle_valide()` (l. 8891-8950), `mw_bootstrap()` (l. 9009-9081) ;
  - `.mw_contexte_mc()` (l. 9091), `MW_CATALOGUE_MC` (l. 9140-9190 ; Courbure l. 9179), `.mw_stats()` (l. 9195) ;
  - `mw_tests()` (l. 9271 ; jonction des phrases l. 9290-9299 ; courbure l. 9360-9375 ; M5 l. 9547-9570) ;
  - `mw_parametre()` (l. 7746 : ne reçoit aucun test) ;
  - `usp_bootstrap()`, partie V3b (l. 4286-4395), `usp_graine_flux_regime()` (l. 2018).
- `CONTEXT.md` : « Test », « Diagnostic », « P-value exacte », « P non simulée », « Approximation à n fini sous i.i.d. normal », « P-value Monte-Carlo conditionnelle à la définition de la statistique », « Colonne dégénérée ».
- ADR 0001 (titre et portée) ; ADR 0002 avec l'amendement du 06/10/2026.
- `docs/latex/CONVENTIONS.md`, l. 24 : les diagnostics gardent six rubriques et ne portent jamais `\Pertinence`.
- `.tex` à `e2099fb` :
  - fiches `mw:m5sw` et `mw:m5li` (l. 13805-13883) et rubrique 7 de `mw:m2bp` (l. 13151-13215) ;
  - `tab:nature` (l. 5245 et suivantes), `tab:tracabilite-puissance` (l. 6183-6520) ;
  - la clé « non étudiée comme cible » (l. 6360-6382).
- Tableaux :
  - `docs/tableaux/20261011-issue119-mw.md` (T6, T7) ;
  - `20261011-issue206-calibration-mw.md` (T1) et son `-brut.tsv` ;
  - `20261010-issue229-p-conditionnelle-regime.md` (T1, l. 231-645) ;
  - `20261010-issue229-p-conditionnelle-puissance.md` (P1).
- Tests et scripts :
  - `tests/concordance_doc_moteur.R` (registre `REGISTRE_RUBRIQUE7`, l. 76-100, 1139-1222) ;
  - `tests/unitaires/test_nature_p_non_simulee.R` (U120-1), `test_forme_close_m1.R` (T253-6), `test_tables_mw.R` (copie oracle, l. 214 et 311), `test_merz_wuthrich.R` (l. 984) ;
  - `tests/calibration_mc_mw_t8.R` (l. 573, 1615, 1693) ;
  - `tests/p_conditionnelle_regime_t8.R` (en-tête des contrôles l. 110-175 ; constantes l. 640-645 ; `completer_v3b()` l. 1988 ; `traiter()` l. 2040-2095) ;
  - `tests/outils_tests.R` (`CAS`, `rejeu_p_mc_v3h()` l. 771-810) ;
  - en-tête de `tests/comparer_ajusteurs_bootstrap.R`.
- Modèle de forme : `docs/specifications/e2d-merz-wuthrich-replications-definitions.md`.

**Mesures** **[V]** :
- `Rscript` sous `LC_ALL=C.UTF-8`, moteur à `e2099fb` (arbre propre), graine 20260831, B = 999 sauf mention contraire.
- Scripts de session, non versionnés (scratchpad de la session) :
  - `lire_ref.R` (lignes de `reserve2.rds`) ;
  - `mesure270.R` (courbure, K et p_mc avant et après le prototype (a)) ;
  - `origine.R` (ordonnée à l'origine, `detail` actuel) ;
  - `freq.R` (fréquences recalculées sur le brut de #206) ;
  - `resid.R` (contraintes des résidus de Mack).

**Décisions déjà prises, non rouvertes** :
- Q-E2e-3 : ordre #232 → #269 → #270 → #245, une seule régénération, en dernier.
- Q-E2e-5 : #245 en (a) par défaut, #243 en (a), #269 et #270 spécifiées ensemble.
- Q-E2e-6 : régénération de `reserve2` par la CI admise sur le principe, visa sur le tableau avant / après.
- Q-E2e-8 : rien n'est réexécuté dans E2e.
- D1-7 d'E2d : colonne exactement non identifiable écartée de la courbure.
- Règle #76 et son exception bornée (Q-E2b-4 (A)).

## 1. #245 : constat remesuré

**Lignes de `reserve2`** (`tests/reference/reserve2.rds`) **[V]**, lignes 16 et 17 de `res$tests` :

| Ligne | type | verdict | p_exacte | p_asymptotique | p_retenue | nature_p | sens |
|---|---|---|---|---|---|---|---|
| Shapiro-Wilk sur les residus de Mack | test | ALERTE | 0,07139643 | NA | 0,07139643 | exacte | ne pas rejeter |
| Lilliefors sur les residus de Mack | test | OK | NA | 0,4569697 | 0,4569697 | approximation a n fini sous i.i.d. normal | ne pas rejeter |

Verdicts de `reserve2` : 3 ALERTE, 4 ECHEC, 3 INFO, 9 OK **[V]**. Le champ du sens s'appelle `sens` (et non `sens_du_test`).

**Niveaux sous erreurs gaussiennes**, plan `reserve2`, 2 000 triangles (`20261011-issue119-mw.md`, T6, l. 33-34) **[V]** :
- Shapiro-Wilk : 0,221 [0,203 ; 0,240] au seuil 0,10, et 0,109 à 0,05 ;
- Lilliefors : 0,1875 [0,171 ; 0,205] au seuil 0,10, et 0,1025 à 0,05.

**Fréquence sous H0 du plan d'une p au moins aussi petite que celle de `reserve2`**, recalculée sur `20261011-issue206-calibration-mw-brut.tsv` (colonne `pex:16`, lignes `type = rep`) **[V]** :

| Loi des erreurs | Fréquence de p(SW) ≤ 0,0714 |
|---|---|
| N | 313/2000 = 0,1565 |
| E | 0,503 |
| A | 0,434 |

Sous E et A, la normalité est fausse par construction : ces taux ne sont pas des niveaux.

**L'étiquette « exacte » de Shapiro-Wilk ne satisfait pas l'ADR 0002 : elle est retirée dans tous les cas** **[V]**.
- La H0 de la ligne, « résidus normaux », contient le modèle de Mack à erreurs gaussiennes, qui appartient à la famille. Seul le premier fondement de l'ADR 0002 vaut donc : la p n'est exacte que si la loi de W sous ce modèle est exacte.
- `sw_p_loi_nulle()` donne la loi de W pour un échantillon **i.i.d.** N(0, 1) de taille n.
- Les résidus de Mack, eux, satisfont deux contraintes exactes par colonne. Sur `reserve2`, mesuré par `resid.R` :
  - Σ_i √C(i,j)·r(i,j) = 0 à 1e-14 près ;
  - Σ_i r(i,j)² = n_j − 1 exactement, colonnes j = 0 à 5 (n_j = 7, 6, 5, 4, 3, 2).
- La seconde identité vient de ce que σ̂²_j est estimé sur les mêmes facteurs. Les 27 résidus portent donc 12 contraintes. Ils ne sont pas un échantillon i.i.d., même sous erreurs gaussiennes, et W n'a pas la loi simulée.
- La mesure le confirme : 0,221 au lieu de 0,10.
- C'est l'évaluation que l'ADR 0002 demande à `actuary` (« Shapiro-Wilk par loi nulle simulée »). La conclusion vaut quelle que soit l'option : même si une ligne M5 restait un test, sa p ne pourrait pas être « exacte ».

**Pertinence.** La normalité n'est pas une hypothèse de l'annexe XVII. Le code (l. 9059-9061) et le `.tex` (`sec:mwm5`) disent que D(2)(h) ne spécifie que les deux premiers moments. Cette lecture n'a pas été relue ici dans le texte consolidé **[NV]**.
- σ_USP n'utilise ni quantile ni normalité : `mw_parametre(aj, msep, sigma_standard, bareme)` **[V]**.
- Les deux lignes ne vérifient donc aucune exigence du modèle.
- Leur p est anti-conservatrice d'un facteur d'environ 2 au seuil 0,10, même quand la normalité est vraie.
- Elles relèvent du « Diagnostic » de `CONTEXT.md` : elles éclairent la lecture, sans verdict.

## 2. #245 : décision proposée, option (a)

1. **Les deux appels d'`add()` de `mw_tests()`, l. 9550-9570** (et non `add()` elle-même) :
   - `type = "diagnostic"` sur les deux lignes.
   - `add()` pose alors seule (l. 4184-4188) : `sens = NA`, `p_retenue = NA`, `nature_p = NA`, verdict INFO. `inoperant` reste `FALSE` et `p_min_mc` reste `NA`.
   - `add()`, `engine_registre_tests()` et `MW_CATALOGUE_MC` ne changent pas.
2. **Shapiro-Wilk : la p passe de `p_ex` à `p_as`** (D1-2, option (A)).
   - Même valeur, même fonction `sw_p_loi_nulle(sw$stat, n)`, même graine `SEED_LOI_NULLE_SW`.
   - C'est une p sous un **modèle auxiliaire** (échantillon i.i.d. normal), non sous l'annexe XVII : famille (iii) de « P non simulée » (`CONTEXT.md`), comme la p de Fisher de la ligne diagnostic lognormale (ADR 0002, amendement, point 4).
   - Elle n'est retenue nulle part, puisque la ligne n'a pas de verdict.
   - `loi` devient : `"loi de W sous echantillon i.i.d. normal (simulation directe), non sous le modele de Mack"`.
3. **Lilliefors.**
   - `p_as = lillie_p(...)` inchangée.
   - L'argument `nature_as = NATURE_APPROX_N_FINI` est retiré : il n'a plus d'effet sur un diagnostic.
   - `loi` devient : `"loi de Lilliefors sous echantillon i.i.d. normal (parametres estimes), non sous le modele de Mack"`.
4. **`detail`**, phrases fixes, ASCII, sans aucun nombre (règle #76 entière) :
   - Shapiro-Wilk : « Diagnostic sans verdict (ADR 0001) : la normalite n'est pas une hypothese du modele (l'annexe XVII, D(2)(h), ne specifie que les deux premiers moments). La loi nulle de W est celle d'un echantillon i.i.d. normal, que les residus de Mack ne sont pas (f_j et sigma_j estimes sur les memes facteurs) : sous erreurs gaussiennes, elle rejette plus souvent que le seuil nominal (constat de simulation sous un plan). La p-value est restituee pour information ; elle n'est pertinente que si l'on souhaite exploiter la MSEP pour un quantile. »
   - Lilliefors : « Diagnostic sans verdict (ADR 0001) : approximation de Dallal et Wilkinson de la loi de D a n fini sous echantillon i.i.d. normal, que les residus de Mack ne sont pas ; sous erreurs gaussiennes, elle rejette plus souvent que le seuil nominal (constat de simulation sous un plan). La p-value est restituee pour information. »
5. **Inchangés** : `famille` (préfixe `M5`, `GROUPES`), noms des lignes (`.MW_LIGNES_RESIDUS`, concordance), `fonction`, `reference`, `variante = "secondaire"` de Lilliefors.
6. **Commentaires du moteur à mettre à jour** :
   - l. 9048-9062 (`mw_bootstrap()`) : « niveau ... reste a etablir (issue #245) » devient le constat et la décision ;
   - l. 3766-3775 (`NATURE_APPROX_N_FINI`) : portée réduite à Anscombe-Glynn, T ≥ 20.
7. **Concordance, contrat à ajuster dans le même commit** (C-E2e-2).
   - `REGISTRE_RUBRIQUE7` exige que chaque fiche du registre ait une ligne de type test (en-tête, point 5 a). Les entrées `mw:m5sw` et `mw:m5li` (l. 1220-1221) sont donc retirées par le commit de `coder`.
   - Le `.tex` doit suivre sans délai, sous la règle M32. Un commit `docs:` minimal, poussé avec le commit code + `.rds` :
     - retire `\Pertinence` des deux fiches et en reporte le contenu **tel quel** en rubrique 6 (conservation du contenu, CONVENTIONS) ;
     - retire leurs deux rangées de `tab:tracabilite-puissance` (point 5 c).
   - Sinon la concordance `--strict` de la CI échoue.
8. **Hors (a)** :
   - (b), bootstrap paramétrique gaussien : non recommandé. La normalité n'est pas une hypothèse du modèle, et la remesure exigerait le protocole de #206, donc R14 puis une branche de mesure.
   - (c), documentation seule : écartée. Elle laisserait un verdict ALERTE sur une p anti-conservatrice et hors modèle.

**Critères d'acceptation**
- Sur `reserve2`, seules les lignes 16 et 17 changent (champs ci-dessous), plus les six feuilles de #253 absorbées par la régénération (ci-dessous). `comparer_references.R reserve2 --seuil 0` le montre.
- `test_application.R` vert ; concordance `--strict` à 0 écart après les deux commits.
- Les cinq cas lognormaux sont identiques.

**Tests attendus**

| Test | Contenu | Attendu |
|---|---|---|
| T245-1 | `reserve2`, lignes M5 | `type` = « diagnostic », verdict INFO, `sens`, `p_retenue`, `nature_p` à NA ; `inoperant` FALSE |
| T245-2 | Shapiro-Wilk | `p_exacte` NA ; `p_asymptotique` = `sw_p_loi_nulle(W, n)` (identical) = 0,07139643 |
| T245-3 | Lilliefors | `p_asymptotique` = `lillie_p(D, n)` = 0,4569697 |
| T245-4 | `detail` des deux lignes | phrases du point 4 exactement ; aucun chiffre (`!grepl("[0-9]", ...)`, hors « D(2)(h) ») |
| T245-5 | U120-1 de `test_nature_p_non_simulee.R`, réécrit | la ligne Lilliefors n'a plus de `nature_p` ; la constante reste portée par Anscombe-Glynn à T ≥ 20 (cas synthétique existant) |
| T245-6 | `.MW_LIGNES_RESIDUS` | la mesure de `test_merz_wuthrich.R` voit toujours les deux lignes M5 (la p a changé de colonne, elle reste détectée) |
| T245-7 | registre de concordance | sans `mw:m5sw` ni `mw:m5li` ; concordance `--strict` à 0 écart |

**Effet attendu sur les références** (régénération de `reserve2` par la CI, branche éphémère `claude/regeneration-245`, commit unique code + `.rds`) :
- **Ligne 16, Shapiro-Wilk** : `type` test → diagnostic ; verdict **ALERTE → INFO** ; `p_exacte` 0,0714 → NA ; `p_asymptotique` NA → 0,0714 ; `p_retenue` 0,0714 → NA ; `nature_p` « exacte » → NA ; `sens` → NA ; `loi` et `detail` changés.
- **Ligne 17, Lilliefors** : `type` test → diagnostic ; verdict **OK → INFO** ; `p_retenue` 0,457 → NA ; `nature_p` → NA ; `sens` → NA ; `loi` et `detail` changés ; `p_asymptotique` inchangée.
- **Décomptes de `reserve2`** : ALERTE 3 → 2, ECHEC 4 → 4, INFO 3 → 5, OK 9 → 8.
- **Six feuilles numériques de #253**, au plus 1,390e-13 (fiche E2e, § 5) : absorbées par cette régénération. Le tableau avant / après les attribue à #253, non à #245.
- **σ_USP inchangé** : `mw_parametre()` ne reçoit aucun test **[V]**. Les cinq autres cas sont identiques **[H]** (la branche lognormale n'appelle pas `mw_tests()`), à confirmer par la CI.
- **Visa du mainteneur** sur les deux verdicts.

**Surface documentaire** (`docwriter`, étape 7, un commit `docs:` pour #245) :
- fiches `mw:m5sw` et `mw:m5li` en gabarit diagnostic à six rubriques :
  - la rubrique 6 dit pourquoi la ligne n'a pas de verdict ;
  - y figurent les deux contraintes de colonne ci-dessus, avec leur mesure, et le niveau de T6 ;
  - la rubrique 5 de `mw:m5sw` ne dit plus « exacte » ;
- `tab:nature` : les deux lignes quittent les décomptes « exacte » et « approximation à n fini » ; l. ~74-75, Lilliefors n'est plus une p retenue ;
- décomptes de verdicts de `reserve2`, partout dans le `.tex` ;
- `sec:mwm5`, encadré.
- Étape 6 (`architect`) :
  - `CONTEXT.md` : dans « Diagnostic », les deux lignes M5 ; dans « Approximation à n fini », la portée ;
  - **annotation de l'ADR 0002** (plutôt que de l'ADR 0001) : Shapiro-Wilk à loi nulle simulée sur résidus de Mack, non exacte (évaluation d'`actuary`, E2e). Aucune règle générale n'est créée : BP, mal calibré, reste un test (§ 3).

## 3. #243 : option (a), documentation

**Constat remesuré** **[V]** :
- p_mc de BP sur `reserve2` : 0,103, verdict OK.
- Sous H0 du plan, fréquence d'une p_mc ≤ 0,103, recalculée sur le brut de #206 (colonne `pR:BP`, pool redressé) :

| Loi des erreurs | Fréquence |
|---|---|
| N | 36/2000 = 0,018 |
| E | 149/2000 = 0,0745 |
| A | 6/1000 = 0,006 |

  Ces fréquences sont celles du corps de l'issue.
- Niveaux de T1 et p asymptotique χ²(1) qui ne rejette jamais (T6 de #119) : déjà dans la rubrique 7 (l. 13212 environ).

**Décision.**
- Compléter la rubrique 7 de `mw:m2bp`, en conservant le texte existant :
  - les trois fréquences ci-dessus, chacune avec sa source (« recalcul sur `docs/tableaux/20261011-issue206-calibration-mw-brut.tsv`, colonne `pR:BP`, lignes `type = rep` ») et son statut (constat de simulation sous un plan) ;
  - la phrase « le verdict OK n'y est pas une preuve d'adéquation : la p-value de Monte-Carlo est conservatrice sous N et A, et la puissance n'est pas étudiée à $T = 8$ » ;
  - le constat R3 de #46 (pool brut contre pool redressé sous E).
- **Aucun code, aucune référence changée.**
- **Suite (b).** Pas d'issue maintenant (D1-4). #246, rangée en F, porte l'outil. Une fois l'outil fait, `actuary` dira si le double bootstrap s'applique à BP.
  - Le niveau de BP dépend fortement de la loi des erreurs : un rapport d'environ 17 entre E et A à 0,10. Une correction fixe est donc exclue, comme le dit l'issue.
  - Aucune référence n'a été vérifiée ici sur la validité d'un double bootstrap à T = 8 **[NV]**.

**Critères d'acceptation** : chaque valeur citée se retrouve dans T1 de #206, dans T6 de #119, ou par la commande de recalcul sur le brut ; concordance `--strict` à 0 écart ; PDF recompilé.

## 4. #269 et #270 : constat remesuré

**Mécanisme** **[V]** (`R/engine.R:8600-8619`).
- Une colonne éligible (n_j ≥ 4), ni figée ni dégénérée, mais à `sd(C0) == 0` ou à moins de trois valeurs distinctes de C(i,j), sort par `next`. Elle n'est enregistrée ni dans `exclues` ni dans le `detail`, alors qu'elle est comptée dans `eligibles`.
- Le comptage est fait sur le triangle de la réplication.
- Pour j = 0, la colonne est figée par `mw_simuler_triangle()` (l. 8894) : l'exclusion se reproduit.
- Pour j ≥ 1, les cumuls simulés sont continus : elle ne se reproduit pas.
- La prémisse de D1-7 d'E2d (« ce cas ne dépend pas des réplications ») est donc fausse pour j ≥ 1.

**Triangles construits** à partir de `reserve2`, B = 999, graine 20260831. Le prototype (a) est rejoué sur les **mêmes** triangles simulés que `mw_bootstrap()`. Les p_mc « avant » sont `identical()` à celles du moteur **[V]** :

| Triangle | Non identifiable à l'observé | K observé | K des réplications, avant | K des réplications, (a) | p_mc avant | p_mc (a) | Verdict avant → (a) |
|---|---|---|---|---|---|---|---|
| `reserve2` | aucune | 4 | 4 (999/999) | 4 | 0,030 | 0,030 | ECHEC → ECHEC |
| T1 : C(0..2,1) = 1000, C(3..5,1) = 1100 | j = 1 | 3 | **4** (999/999) | 3 | 0,081 | 0,031 | **ALERTE → ECHEC** |
| T2 : C(0..2,2) = 1600, C(3..4,2) = 1800 | j = 2 | 3 | **4** (999/999) | 3 | 0,634 | 0,394 | OK → OK |
| T3 : C(·,0) = 320, 350 en alternance (colonne figée) | j = 0 | 3 | 3 | 3 | 0,017 | 0,017 | ECHEC → ECHEC |
| T4 : C(0..5,1) = 1050 (constante) | j = 1 | 3 | **4** (999/999) | 3 | 0,043 | 0,016 | ECHEC → ECHEC |

Les verdicts sont déduits de la règle d'`add()` (sens « ne pas rejeter », α = 0,10). La courbure n'a pas d'extrêmes au catalogue, donc ni R1 Monte-Carlo ni `p_min_mc` ne s'appliquent.

**Lecture.**
- Sur T1, X observé vaut 13,9956 avec K = 3. Sa queue χ²(6) vaut 0,0297, et sa queue χ²(8) 0,0819 **[V]**.
- La p_mc actuelle (0,081) reproduit la queue à 8 ddl, et celle de (a) (0,031) la queue à 6 ddl : la statistique observée est comparée à une autre statistique.
- Distorsion sous l'approximation nominale (colonnes indépendantes, χ² par colonne ; calcul, non mesure à T = 8) **[V]** : la règle actuelle rejette avec probabilité P(χ²₆ ≥ q₀,₉₀(χ²₈)) = **0,038** au seuil 0,10, et 0,017 au seuil 0,05. Elle est donc **conservatrice d'un facteur de 2,7 à 3**.
- **[NV]** Le niveau sous (a) n'est pas mesuré sur un plan à ex æquo. Sur le plan `reserve2` (sans ex æquo), la courbure est compatible : 0,093 [0,081 ; 0,107] sous N à 0,10 (#206, T1, l. 183).

**Restitution actuelle** **[V]** (T1, `run_engine()`, B = 199) : verdict OK, `estim` = 3, et un `detail` sans aucune mention de l'exclusion (« Une courbure invalide la linearite ... ; verdict sensible a l'alea de simulation ... »).

**Même défaut sur l'ordonnée à l'origine** (hors du numéro) **[V]**.
- Sur T4, `mw_test_ordonnee_origine()` écarte en silence la colonne j = 1, où C est constant : `lm()` rend une ligne de coefficients au lieu de deux, d'où le `next` de la l. 8412.
- Résultat : K = 4 à l'observé, contre K = 5 dans 50 réplications sur 50. Voir D1-9.

## 5. #270 : décision proposée, option (a), ensemble figé à l'observé

**Pourquoi (a), et non (b).**
- (b) compare la statistique observée à la loi d'une statistique à une colonne de plus, sous un modèle de simulation où la configuration observée (ex æquo exacts de C(i,j), j ≥ 1) a une probabilité nulle. Reproduire la règle de sélection dans le bootstrap ne vaut que si le modèle simulé peut produire ce qui la déclenche, ce qui n'est pas le cas ici.
- (a) compare la même fonction du triangle, T_S à S fixé, à l'observé et dans chaque réplication. C'est la doctrine de #56 (colonnes dégénérées) et celle de `CONTEXT.md` (« P-value Monte-Carlo conditionnelle à la définition de la statistique »).
- C'est un argument élémentaire, sans référence citée.

**Spécification.**
1. **Nouvelle fonction nommée** `.mw_colonnes_courbure_non_identifiables(aj, j_degeneres = NULL)`. Elle rend, en entiers, les j tels que :
   - n_j = I − j ≥ 4 ;
   - j ∉ `.mw_j_exclues(aj, j_degeneres)` et `!.mw_colonne_degeneree(aj, j)` ;
   - `length(unique(C(0..I−j−1, j))) < 3` (égalité exacte, comme en E2d ; la garde `sd(C0) == 0` y est incluse).
2. **`mw_test_courbure(aj, j_degeneres = NULL, j_non_identifiables = NULL)`** :
   - si `j_non_identifiables` vaut `NULL`, l'ensemble est calculé sur `aj` (appel observé) ;
   - boucle : n_j < 4 → `next` ; j ∈ jd → `.mw_exclure()` ; `eligibles` + 1 ; colonne dégénérée → `.mw_stat_non_definie()` ; **j ∈ ensemble figé → enregistrée dans `non_identifiables`** (§ 6), `next` ;
   - sinon `.mw_courbure_colonne()`. **Si elle rend `NULL`** (colonne retenue à l'observé mais non identifiable dans la réplication : second volet de #56), la statistique vaut `NA`, avec K = NA, et sort de B effectif. Plus aucun `next` silencieux.
   - La garde `sd(C0) == 0` est retirée : le prédicat la couvre. En flottant, une colonne constante peut avoir un `sd()` non nul ; `unique()` la détecte.
3. **Transmission.**
   - `.mw_contexte_mc(aj, j_degeneres = NULL, j_non_identifiables = NULL)` ajoute le champ `j_non_identifiables` (calculé sur `aj` s'il vaut `NULL`).
   - `.mw_stats(aj, j_degeneres = NULL, j_non_identifiables = NULL)`.
   - Dans `mw_bootstrap()`, `jni <- .mw_colonnes_courbure_non_identifiables(aj, jd)` est calculé une fois, après `jd`. Puis `e_obs <- .mw_contexte_mc(aj, jd, jni)` et `.mw_stats(ab, jd, jni)`.
4. **`MW_CATALOGUE_MC`, entrée Courbure** : la fermeture devient `mw_test_courbure(e$aj, e$j_degeneres, e$j_non_identifiables)$stat`. Nom, queue « haut » et absence d'extrêmes restent inchangés (D1-6).
5. **Flux aléatoire inchangé.** Aucun tirage n'est ajouté ni retiré : seule la statistique des réplications change. `engine_sous_graine()` et la restauration de l'état de l'appelant ne sont pas touchées.
6. **Hors module** : `tests/calibration_mc_mw_t8.R` (l. 1615, 1693), que R14 touche en parallèle (C-E2e-5), **n'est pas modifié dans E2e**.
   - Son appel `.mw_stats(a, jd)` calcule l'ensemble sur chaque triangle simulé.
   - Sur le plan `reserve2`, la colonne 0 figée n'a que des valeurs distinctes et les colonnes j ≥ 1 simulées sont continues, d'où un ensemble vide et des contrôles (i1) et (s) inchangés **[H]**.
   - Une ligne de suivi est à porter dans F (transmettre `jni` pour la fidélité).

**Critères d'acceptation**
- K est égal entre l'observé et chaque réplication finie, sur T1, T2 et T4.
- Les p_mc de courbure du tableau du § 4 sont reproduites par `mw_bootstrap()` : mêmes tirages, même statistique ; `identical()` au prototype attendu **[H]**.
- `identical()` sur les six cas de référence.
- État du générateur de l'appelant restauré.

**Tests attendus**

| Test | Contenu | Attendu |
|---|---|---|
| T270-1 | T1, `mw_bootstrap()`, B = 999 | K = 3 dans toutes les réplications (boucle de `test_merz_wuthrich.R` l. 984, adaptée) ; p_mc Courbure 0,031 |
| T270-2 | T2, T4 | K = 3 partout ; p_mc 0,394 et 0,016 |
| T270-3 | T3 (colonne 0) | p_mc 0,017, inchangée |
| T270-4 | invariance | `mw_test_courbure(aj)` `identical()` à `mw_test_courbure(aj, jd, .mw_colonnes_courbure_non_identifiables(aj, jd))` sur `reserve2` et T1 à T4 |
| T270-5 | second volet | triangle à colonne j = 1 à deux valeurs, avec `j_non_identifiables = integer(0)` : `stat` NA, K NA |
| T270-6 | `reserve2` | `comparer_references.R reserve2 --seuil 0` : 0 écart ; ensemble figé vide |
| T270-7 | oracle de `test_tables_mw.R` (l. 214, 311) | mis à jour en réécriture indépendante, puis confronté au moteur |
| T270-8 | T1, appelant à `RNGkind()` différent | `.Random.seed` et `RNGkind()` restaurés |

**Effet sur les références** : **aucun**. `reserve2` n'a aucune colonne non identifiable (mesuré), et les cinq cas lognormaux n'exécutent pas ce code ; `identical()` à confirmer par `audit` **[H]**. Hors références, les changements de p_mc et de verdict du tableau du § 4 (T1 : ALERTE → ECHEC) sont soumis à D1-8.

## 6. #269 : décision proposée, restitution

1. **Nouvel élément de résultat de `mw_test_courbure()`** : `non_identifiables`, un `data.frame(j = integer, n_facteurs = integer)`, vide en l'absence de telle colonne.
   - Il est porté aussi par les retours `NA` : l'assistant `.mw_stat_non_definie()` reçoit l'élément, ou bien `mw_test_courbure()` l'ajoute.
   - `exclues` garde son sens (colonnes dégénérées), et `.mw_phrase_exclusion()` est inchangée.
   - L'élément n'est stocké nulle part dans `res` : seuls `mw_tests()` et la fermeture `$stat` le lisent **[V]**.
2. **Phrase fixe**, par une fonction nommée, par exemple `.mw_phrase_non_identifiable(r)` : `""` si aucune telle colonne. Le texte est sans nombre issu du bootstrap : j, n_j, K et `eligibles` sont ceux de l'observé.
   - Une colonne : « Colonne a moins de trois valeurs distinctes de C(i,j) : j = 1 (6 facteurs) ; terme quadratique non identifiable, colonne hors de la combinaison de Fisher ; K = 3 colonne(s) testee(s) sur 4 eligible(s). L'exclusion ne vaut pas preuve de linearite. »
   - Plusieurs : « Colonnes a moins de trois valeurs distinctes de C(i,j) : j = 1 (6 facteurs), j = 2 (5 facteurs) ; terme quadratique non identifiable, colonnes hors de la combinaison de Fisher ; K = ... »
3. **Place dans le `detail`.**
   - `mw_tests()` (l. 9370-9375) l'ajoute au `detail` de base par `.mw_avec_exclusion()`, **après** la phrase des colonnes dégénérées s'il y en a une.
   - Chaque phrase garde sa clause « K = ... sur ... éligible(s) », la même dans les deux.
   - Les phrases de #257 et #204 (wrapper l. 9290-9299) et celle de #244 (`add()`) viennent ensuite **[V]** par construction. #264 (F) devra reprendre cette phrase.
4. **Texte identique avant et après #270**, ce qui épargne une seconde modification à l'étape 4.

**Tests attendus**

| Test | Contenu | Attendu |
|---|---|---|
| T269-1 | T1 | `detail` contient la phrase « j = 1 (6 facteurs) ... K = 3 colonne(s) testee(s) sur 4 eligible(s) » ; `estim` = 3 |
| T269-2 | T3 | « j = 0 (7 facteurs) » |
| T269-3 | colonne dégénérée et colonne non identifiable | deux phrases, celle des colonnes dégénérées d'abord |
| T269-4 | `reserve2` | `detail` `identical()` à la référence |
| T269-5 | T1, B = 199 et 999, deux graines | phrase identique (aucun nombre issu du bootstrap) ; phrase de #244, si posée, en dernier |
| T269-6 | T253-6 de `test_forme_close_m1.R` | inchangé, plus `nrow(non_identifiables) == 1` |

**Effet sur les références** : aucun (`reserve2` n'a pas de telle colonne ; les champs du résultat ne sont pas stockés).

**Surface documentaire de #269 et #270** (`docwriter`, étape 7) :
- fiche `mw:m1c` : prédicat, ensemble figé, phrase, distorsion nominale de la règle d'avant (0,038 à 0,10), tableau du § 4 en constat sur triangles construits ;
- spécification d'E2d, D1-7 : prémisse corrigée, par annotation ;
- index des fonctions : la fonction nouvelle ;
- `CONTEXT.md` (étape 6) : terme « Colonne non identifiable (courbure) », et l'entrée « Colonne dégénérée » doit dire que l'ensemble figé de la courbure en est distinct.

## 7. #256 : niveaux V3h dans les rubriques 7 lognormales

**Constat** **[V]**. T1 de `20261010-issue229-p-conditionnelle-regime.md` donne V1, V3a, V3b et V3h pour 34 statistiques, sur J1 (bords), J2 et J3.
- Sur J1, V3h = V1 ligne par ligne (même k ; McNemar 0/0). Exemple : BP 191/1925.
- Sur J2, BP vaut 0,0850 sous V1 (écart mineur) et 0,1095 [0,0961 ; 0,1240] sous V3h (compatible).
- Sur J3, BP vaut 0,0450 sous V1 et 0,1125 sous V3h.
- Le fichier de puissance (P1) a aussi des rangées V3h.

**Décision.**
1. Pour chaque fiche lognormale qui cite en rubrique 7, ou dans `tab:tracabilite-puissance`, un niveau V1 (#166 ou #229) :
   - ajouter à côté le niveau V3h de T1 : même jeu, même statistique, mêmes seuils, IC et classe de #166 ;
   - sur J1, écrire « identique à V1 (δ̂ au bord) » ;
   - nommer V3h « p-value retenue du moteur depuis l'issue #240 ».
   - Le niveau V1 n'est pas retouché.
2. **Clé « non étudiée comme cible »** (l. 6375-6377) : retirée. Elle redéfinissait un terme fixé par `CONVENTIONS.md` (« puissance non étudiée à $T = 8$ »).
   - Dans chaque fiche concernée dont la statistique figure dans P1 sous des alternatives d'une autre famille, écrire : « Puissance non étudiée à $T = 8$ contre les écarts que vise la ligne ; des taux de rejet sous des alternatives d'une autre famille figurent au fichier de puissance de l'issue~\#229, sans être repris ici. »
   - Ailleurs, la formule de `CONVENTIONS.md` reste telle quelle.
3. **Sous D1-10** : quand une fiche cite une puissance V1 de P1 sous δ̂* intérieur, citer à côté la puissance V3h de la même rangée de P1.
4. **Statut**, déjà au `.tex` (l. 6378-6382), à garder : constat de simulation au commit `fee9968`, V3h reconstruite par le script, antérieure à son implémentation.

**Critères d'acceptation** : chaque valeur citée se retrouve dans T1 (ou P1) ; aucune régénération, aucun résultat changé ; concordance `--strict` à 0 écart ; PDF recompilé ; validation d'`actuary-approfondi` sur le diff du `.tex`.

## 8. #256 : réponses aux trois questions du commentaire `6141086273`

### 8.1 Remesure des tableaux de J1 et J2 sous V3h et `p_min_mc` (Q-E2e-8)

**Réponse : oui, une remesure est nécessaire avant la remise du dossier, mais pas dans E2e.** Une issue de mesure est à créer sur accord (D1-11), avec sa branche décidée à la clôture d'E2e, après R14.
- **J2, volet B de `tests/puissance_t8.R`** : nécessaire.
  - À δ̂ intérieur, la p retenue des 34 statistiques n'est plus V1 mais V3h.
  - Les tableaux décrivent donc une variante que le moteur ne retient plus.
  - P1 de #229 ne couvre que six alternatives et pas la chaîne des verdicts.
- **J1** : le niveau des statistiques est inchangé (δ̂ au bord, V3h = V1, T1). Seule change la restitution des lignes : la branche Monte-Carlo de R1 (#125) bascule « Suites » en test inopérant dans quelques réplications. L'effet est de second ordre, mais il est à faire dans le même passage, pour un coût marginal.
- La mesure de 79 lignes de `coder` (R = 20, B = 99) n'est pas versionnée **[NV]** et ne peut pas être citée.
- **Hors remesure, à décider dans l'issue** :
  - T2 de `p_conditionnelle_regime_t8.R` reste la trace de la décision de l'ADR 0014, au commit `fee9968`. Il n'est à refaire que si le `.tex` le cite comme comportement actuel **[NV]**.
  - `comparer_ajusteurs_bootstrap.R` est déjà en V3h depuis #262 ; son nouveau passage est peu coûteux (≈ 340 s selon son en-tête).
  - Pour `taux_franchissement_reperes.R`, la dépendance de ses tableaux à `p_mc` n'a pas été vérifiée **[NV]**.
- **Préalable** : R14 (#271 et #267), qui rend les instruments justes.

### 8.2 QA1 : protocole de `comparer_ajusteurs_bootstrap.R`

**Réponse : la sélection propre à chaque ajusteur est la bonne quantité.**
- La question de #43 (J0) est : « remplacer le réajusteur change-t-il la p retenue ? »
- Sous V3h, le réajusteur intervient deux fois : par les statistiques calculées sur (z, π) réajustés, et par le classement de δ** dans le régime intérieur.
- Le second effet est précisément ce que J0 surveille (fabrication de δ* au bord).
- Une sélection commune isolerait le premier effet seul. C'est une décomposition possible, non requise.
- Sur J2 à B = 999, l'écart est nul (max |Δp| = 0, constat rapporté par la session, **[NV]** par `actuary`). **Aucune action.**

### 8.3 QA2 : reformulation du contrôle (i2) de `p_conditionnelle_regime_t8.R`

**Réponse : oui, sous conditions.**
- **L'objet de (i2)** dans #229 est de garantir que les quantités mesurées par le script sont celles du moteur, à simulations identiques. Avant #240, le moteur rendait V1 partout.
- **Graines identiques** **[V]** :
  - la graine du flux du moteur vaut `usp_graine_flux_regime(GRAINE_BOOT + b)` = 20260831 + 539169 + b = 20800000 + b ;
  - c'est exactement `GRAINE_V3B + b` du script (l. 643) ;
  - les plafonds sont égaux : `B_CIBLE` = 999 = B et `B_MAX` = 25000 = 25 (B + 1).
- **Conditions** :
  1. **À δ̂ intérieur**, comparer `usp_bootstrap()` à `mc3b`, la V3b du script (`completer_v3b()`), et non seulement à `rejeu_p_mc_v3h()`.
     - C'est ce qui établit que la V3b mesurée dans T1 **est** la V3h du moteur.
     - `rejeu_p_mc_v3h()` (#262) est une seconde transcription, utile en plus, non à la place.
     - Champs comparés : `p_mc`, `err_mc`, `B_effectif`, `granularite_stat`, `motif_mc`, `p_min_mc`, et, de `p_mc_regime`, `retenus_v1` (`nA0`), `retenus` (`nA`), `tirages` (`tir`) et `arret`.
  2. **Garder sans changement** la comparaison des champs que V3h ne touche pas : `stats_obs`, `sigma_boot`, `delta_boot`, `gamma_boot`, `sigma_boot_restreint`, `n_echec_restreint`, `z_boot`, ainsi que P3 (rejeu complet contre rejeu allégé).
  3. **Au bord**, comparaison à V1 inchangée.
  4. **Lacune résiduelle, à écrire dans l'en-tête du script.** À δ̂ intérieur, le moteur n'expose plus V1.
     - Les statistiques des tirages de V1 dont δ** est au bord ne sont plus confrontées au moteur.
     - Sur J1 et J2, (i1) couvre V1 au bit près contre les valeurs brutes de #221.
     - Sur J3, rien ne la couvre.
  5. **Écarts de code** entre `completer_v3b()` et le moteur. Le script ne teste pas `is.finite(f$delta)`, et il classe le régime par `code_regime()` plutôt que par `usp_regime()`. Un δ** non fini ferait échouer `if` dans le script **[H]**, qui ne divergerait donc pas en silence. Le contrôle reformulé le détecterait. À relever dans #267.
     - *[Annoté le 15/10/2026 (F), par `docwriter` : écarts résorbés par #280, commit `cf4be73` (points 2 et 3 de l'issue). `completer_v3b()` compte un δ** non fini en « rapide », comme le moteur, et lit le régime du tirage par `regime_tirage()` (`tests/outils_tests.R`), fondée sur `usp_regime()` ; vérifié dans `tests/p_conditionnelle_regime_t8.R` à la tête `94cb960`.]*
- `#267` peut passer en `ready-for-agent` avec ces critères.

## 9. Effet attendu (récapitulatif)

- **σ_USP** : inchangé partout **[V]** (signature de `mw_parametre()`).
- **Références** : seule `reserve2` change, à l'étape 5 (#245, § 2). Les étapes 3 et 4 laissent les six cas identiques **[H]**, à confirmer par `identical()`.
- **Hors références** :
  - la courbure sur triangles à ex æquo de C(i,j) en colonne j ≥ 1 : K aligné, p_mc et un verdict changés (§ 4) ;
  - la phrase d'exclusion (#269).
- **Durées** : aucune nouvelle ; la courbure perd une colonne dans les réplications concernées.

## 10. Hors périmètre

- L'ordonnée à l'origine (même défaut, § 4) : D1-9.
- Le niveau de la courbure sous (a) sur un plan à ex æquo (non mesuré).
- #245 (b) et #243 (b).
- La remesure du § 8.1.
- La mise à jour de `calibration_mc_mw_t8.R` (§ 5, point 6).
- #232 (étape 2) et #201.

## Questions au mainteneur pour D1

- **D1-1 — #245, traitement des lignes M5.** *Recommandation* : **(a)**, les deux lignes deviennent des diagnostics. Effet : sur `reserve2`, Shapiro-Wilk passe d'ALERTE à INFO et Lilliefors d'OK à INFO ; σ_USP est inchangé ; une régénération par la CI ; visa sur le tableau avant / après. *Alternatives* : (b) bootstrap paramétrique gaussien, avec remesure par branche de mesure ; (c) documentation seule.
- **D1-2 — #245, colonne de la p de Shapiro-Wilk.** *Recommandation* : **(A)**, déplacer la p de `p_exacte` vers `p_asymptotique`, même valeur, avec un champ `loi` qui nomme le modèle auxiliaire i.i.d. normal. L'étiquette « exacte » est retirée dans tous les cas : les résidus de Mack ont deux contraintes exactes par colonne et ne sont pas i.i.d. (ADR 0002 non satisfait). *Alternatives* : laisser la valeur dans `p_exacte`, au prix d'une colonne qui contredit l'ADR 0002 ; ou remplacer par la p de Royston (`shapiro.test`), ce qui change la méthode.
- **D1-3 — #245, suite (b).** *Recommandation* : **aucune issue** (la normalité n'est pas une hypothèse du modèle ; σ_USP n'utilise pas de quantile). *Alternative* : une issue en F.
- **D1-4 — #243.** *Recommandation* : **(a)** dans E2e, avec les trois fréquences recalculées et vérifiées (0,018 ; 0,0745 ; 0,006). Pas d'issue (b) maintenant : la question est rouverte quand #246 est faite. *Alternative* : créer dès maintenant une issue (b) bloquée par #246.
- **D1-5 — #270.** *Recommandation* : **(a)**, ensemble des colonnes non identifiables figé à l'observé (même K à l'observé et dans les réplications). L'ancienne règle rejette environ 3 fois moins que le seuil sous l'approximation nominale. *Alternative* : (b), doctrine actuelle documentée.
- **D1-6 — #270, forme.** *Recommandation* : argument dédié `j_non_identifiables` et champ de contexte du même nom ; la fermeture de l'entrée Courbure de `MW_CATALOGUE_MC` reçoit un argument de plus, son nom et sa queue sont inchangés. Contrat partagé touché de façon minimale. *Alternative* : aucune défendable (fusionner dans `j_degeneres` exclurait la colonne des autres tests).
- **D1-7 — #269, restitution.** *Recommandation* : élément `non_identifiables` et phrase fixe du § 6, placée après la phrase des colonnes dégénérées et avant celles de #257, #204 et #244. *Alternative* : une colonne `motif` dans `exclues`, qui change la structure partagée par trois tests.
- **D1-8 — Verdicts nouveaux sur triangles construits** (hors références), tableau du § 4 : T1 passe d'ALERTE à ECHEC (p 0,081 → 0,031) ; T2 reste OK (0,634 → 0,394) ; T4 reste ECHEC (0,043 → 0,016). *Recommandation* : approuver.
- **D1-9 — Ordonnée à l'origine, même défaut** (mesuré : K = 4 à l'observé contre 5 dans les réplications, colonne à C constant). *Recommandation* : une **issue séparée, en F**, à créer sur accord. Titre : « M1, ordonnée à l'origine : colonne à C(i,j) constant écartée en silence par lm() à l'observé, pas dans les réplications ». Libellés `bug`, `needs-triage`. Spécification : celle des § 5 et 6 transposée, prédicat « moins de deux valeurs distinctes de C(i,j) », nombre de coefficients de `lm()` inférieur à 2 pour une colonne retenue donnant `NA`. *Alternative* : l'inclure dans #270 à l'étape 4, références identiques, au-delà du périmètre fixé par Q-E2e-2.
- **D1-10 — #256, puissance.** *Recommandation* : citer aussi la puissance V3h de P1 à côté de chaque puissance V1 de #229 déjà citée (même fichier, même passage de `docwriter`), et remplacer la clé « non étudiée comme cible » par la phrase du § 7. *Alternative* : niveaux seuls, comme le dit le corps de #256.
- **D1-11 — Remesure des tableaux de J1 et J2 (Q-E2e-8).** *Recommandation* : **oui**, une issue à créer sur accord. Titre : « mesure: remesurer sous le moteur courant (V3h, p_min_mc) le volet B de puissance_t8.R (J1, J2) ». Libellés `enhancement`, `needs-triage`. J2 est nécessaire et J1 se fait dans le même passage ; après R14 ; branche décidée à la clôture d'E2e. *Alternative* : documenter seulement les tableaux comme datés (V1, avant #125), ce qui n'est pas suffisant pour le dossier.
- **D1-12 — QA1.** *Recommandation* : aucune action ; la sélection propre à chaque ajusteur est la bonne quantité.
- **D1-13 — QA2 (#267).** *Recommandation* : la reformulation préserve l'objet du contrôle, à condition de comparer à `mc3b` (graine du flux égale par construction) et de garder les champs non touchés par V3h, la lacune de J3 étant écrite ; #267 passe en `ready-for-agent`, et R14 peut s'ouvrir.

---

## Annotation du 13/10/2026 : décisions du mainteneur au point d'arrêt D1

Toutes les décisions suivent les recommandations ci-dessus.
- **D1-1 à D1-3 (#245)** : option (a) et colonne (A) ; aucune issue (b).
- **D1-4 (#243)** : option (a).
- **D1-5 à D1-8 (#269, #270)** : ensemble figé à l'observé, argument `j_non_identifiables`, élément `non_identifiables` et phrase fixe. Verdicts sur triangles construits approuvés (T1 ALERTE → ECHEC).
- **D1-9** : issue séparée en F, **#273**.
- **D1-10 (#256)** : puissance V3h citée à côté de V1, clé « non étudiée comme cible » remplacée.
- **D1-11** : issue de remesure **#274**, après R14, branche décidée à la clôture d'E2e.
- **D1-12** : aucune action.
- **D1-13** : (i2) reformulé selon le § 8.3 ; #267 en `ready-for-agent` ; R14 peut s'ouvrir.

Libellés posés le 13/10 : #245, #243, #269, #270 et #267 en `ready-for-agent`.
