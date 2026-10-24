# Spécification de Fm : Merz-Wüthrich, restitution hors M1 et M2 (M3, M5, M6, graphiques, affichage de M, bloc (C) de `tab:conv`) — point d'arrêt D1-Fm (#353, #310, #312, #311, #362)

> **Décisions du mainteneur du 23/10/2026 (E-23/10 (D1-Fm)) : point d'arrêt D1-Fm franchi.**
>
> *Consignées par la session principale (IA)* ; source : réponses du mainteneur aux questions de la session principale. Le présent document reprend à la lettre la spécification D1-Fm d'`actuary-approfondi` du 23/10/2026 (lecture seule), qui intègre la lecture de D(5)(d)(ii) par `regulatory` (aucun écart). Les scripts de mesure de la consultation (`m_fm_a.R` à `m_fm_d.R`) sont versionnés avec le tableau de mesures (Q-D1-Fm-3).
>
> **Toutes les décisions suivent les recommandations d'`actuary-approfondi`** :
>
> - **Q-D1-Fm-1 (#312)** : **(B)**, variante secondaire **et** diagnostic par décision (phrase T-1, forme de Fh). Le verdict de la ligne « Test des suites » de `reserve2` passe d'OK à INFO : **visa de principe**, à confirmer sur le tableau avant / après réel de la régénération. Décomptes de `reserve2` : 12 tests, 9 diagnostics (écart de concordance attendu, commit `docs:` minimal M32). Écart à la prévision du plan (A), qui conservait le verdict OK.
> - **Q-D1-Fm-2 (#312)** : moyenne et n_k, dans deux tables `residus_acc_groupes` et `residus_cal_groupes` en fin de `plots_data`, sans bande ni recopie des L/S.
> - **Q-D1-Fm-3 (#312)** : texte de lecture conjointe du § 1.3 adopté (il corrige le constat « un seul signal » de l'issue) ; mesures versionnées en commit `docs:` préparatoire (`docs/tableaux/20261023-fm-mesures.md`, avec les scripts).
> - **Q-D1-Fm-4 et Q-D1-Fm-5 (#311)** : **(c)**, pas d'enveloppe ; résidus redressés r/√(1 − h), droite identité posée par le moteur, légende T-3 ; la droite par quartiles est écartée ; les lignes M5 restent sur les résidus bruts ; pas de colonne `n_j`. Aucune source d'aléa nouvelle ; ADR 0004 inchangé.
> - **Q-D1-Fm-6 (#310)** : le contrefactuel σ²_{J−1} = 0 est gardé, dans une phrase séparée nommée « contrefactuel qui n'est pas un argument du minimum » (T-4).
> - **Q-D1-Fm-7 (#310)** : σ_estimé n'est pas affiché.
> - **Q-D1-Fm-8 (#310)** : R1 dans le `detail` (T-4, même patch) ; R1 à R3 dans `mw:m6sig` par `docwriter` ; R2 conditionné à I = J, la question « la règle s'applique-t-elle telle quelle quand I > J ? » étant posée à `regulatory`.
> - **Q-D1-Fm-9 (#310)** : colonne logique `sigma_regle_minimum` en fin de `plots_data$facteurs` (patch) ; σ̂_j tracé sur `plot_mw_facteurs()` avec le point J − 1 marqué (T-5) ; forme laissée à `app-review`.
> - **Q-D1-Fm-10 (#353)** : constante d'affichage `STAT_NOMS_PROBABILITE`, confrontée par un test au `nom_statistique` du moteur ; aucun champ nouveau.
> - **Q-D1-Fm-11 (#362)** : quatre lignes nouvelles dans le bloc (C) de `tab:conv` (Kruskal-Wallis, ESD, extrapolation de σ̂²_{J−1}, concentration) et correction de la ligne « Durbin-Watson et suites ».
>
> Recommandations annexes retenues : `architect` annote #317 (point 11 couvert par #311, point 9 à Fl) ; `CONTEXT.md` « Enveloppe » gagne l'_Avoid_ « enveloppe du QQ-plot Merz-Wüthrich (aucune, #311) ».

> *Rédigé par l'agent actuary (IA).* Consultation `actuary-approfondi` du 23/10/2026, en lecture seule, demandée par la session principale. Elle porte sur la fiche « Branche Fm » du quarantième point d'étape (E-23/10 (40e point)), sur la branche `claude/merz-wuthrich-restitution` (tête `c63d609`, PR brouillon #370). Le périmètre est fermé, dans l'ordre des commits : #353, #310, #312, #311, #362. La spécification suit l'ordre des questions S-Fm-1 à S-Fm-5. **Point d'arrêt D1-Fm** : aucun code de #310, #312 ni #311 tant que le mainteneur n'a pas tranché les questions Q-D1-Fm. #353 et #362 n'en dépendent pas, sauf Q-D1-Fm-10 et Q-D1-Fm-11.

**Marques** : **[V]** vérifié (source citée, ou commande exécutée et sortie lue) ; **[P]** vérification partielle (notice ou source secondaire) ; **[H]** hypothèse ou raisonnement non mesuré ; **[NV]** non vérifié.

## 0. Sources, mesures, contraintes

**Lu [V]** :
- les issues #353, #310, #312, #311 et #362, sans commentaire ; #317, #297 et #333 (pour les frontières) ;
- la fiche « Branche Fm » de `docs/feuille-de-route.md` (l. 2184-2261) ;
- `docs/specifications/fj-merz-wuthrich-identifiabilite.md`, comme modèle ;
- dans `CONTEXT.md` : « Test », « Diagnostic », « Enveloppe du QQ-plot », « Graine locale » ;
- `docs/exigences.md` § 3.2, § 3.3, § 4 et § 5 ; l'ADR 0004 et ses trois annotations ;
- `docs/references/verifications-fi.md` § 6.1 à 6.3 ;
- dans `R/engine.R` (tête `c63d609`, md5 `be37ca83667e896d22d2ab123e905c9c`) :
  - `mw_ajuster()` (l. 7913) et `mw_extrapolation_sigma2()` (l. 8116) ;
  - `.mw_detail_extrapolation()` (l. 8174) et `mw_msep()` (l. 8275) ;
  - `mw_residus()` (l. 8706), `.mw_un_moins_h()` (l. 10254) et `.mw_pool_residus()` ;
  - `mw_tests()` (l. 10701-11230 : en-tête, M3, M4, M5, M6) ;
  - `engine_enveloppe_qq()` (l. 7526), `engine_plots_data()` (QQ, l. 7563-7600) et `mw_plots_data()` (l. 11937) ;
- dans `R/display_helpers.R` (md5 `9ff355df8c6c903d941725898baa88f5`) :
  - `fmt_nb()`, `fmt_p()` (l. 56-67) et `table_synthese_groupe()` (l. 257-268) ;
  - `selection_defaut()` (l. 152) ; `plot_qqnorm()` et les fonctions `.qq_*` (l. 475-575) ;
  - `.nuage()`, les fonctions `plot_mw_residus_*()`, `plot_mw_qq()` (l. 967-983) et `plot_mw_facteurs()` (l. 985) ;
- dans le `.tex` :
  - `tab:conv`, bloc (C) (l. 6582-6686) ; `sec:variantes` (l. 7813-7845) ; la synthèse de couverture M1-M6 (l. 14036-14062) ;
  - le recensement des graphiques MW (l. 13020-13055) ; la section `sec:boot-mw` sur le redressement (l. 4374-4425) ;
  - les fiches `mw:m3cal` (l. 15701-15790), `mw:m3acc`, `mw:m3dw`, `mw:m3runs`, `mw:m4ros`, `mw:m6sig` et `mw:m6conc` ;
  - la notice d'Atkinson (1981) (l. 18286-18300) ;
- `tests/concordance_doc_moteur.R` (registre `DECOMPTES`, entrées MW et « variante secondaire ») ;
- `docs/tableaux/20261021-issue309-puissance-mw.md` (T0, T1, T2) et son brut `-brut.tsv` (md5 `f616a3bc2e9a0cb6ce255396b0130ba0`, recalculé, conforme au T0) ;
- la lecture de D(5)(d)(ii) par `regulatory`, transmise par la session le 23/10/2026, avec son script `…/scratchpad/m310.R`.

**Mesures [V]** : `Rscript` R 4.3.3, `LC_ALL=C.UTF-8`, moteur `c63d609` chargé par `source()`, référence `tests/reference/reserve2.rds` relue. Scripts et sorties dans `/tmp/claude-0/-home-user-outil-usp/cc202d02-9d01-5fef-a7cd-447e0cf4cf16/scratchpad/fm/`, lancés depuis la racine du dépôt par `LC_ALL=C.UTF-8 Rscript <chemin>` :

| Script (md5) | Objet | Sortie (md5) |
|---|---|---|
| `m_fm_a.R` (`555604552b9c0d883c8322772fd4d9ff`) | résidus de `reserve2` : moyennes par groupe, DW centrés, pentes du QQ | `m_fm_a.txt` (`11f082b229297315316bced2323f5b0b`) |
| `m_fm_b.R` (`5d933df7b282a29a52ef0ad145ba90db`) | lecture conjointe DW / calendaire / suites sur le brut de #309 | `m_fm_b.txt` (`cb90a607ac2d3f3f7b2e0725d2bcd37c`) |
| `m_fm_c.R` (`a51d83a274c564d97203c3b15fdda63f`) | simulation sous le modèle de Mack ajusté à `reserve2` : pentes, statistiques d'ordre, enveloppe, puissance | `m_fm_c.txt` (`272529671ee73ddacd467dbc9b2b09aa`) |
| `m_fm_d.R` (`2357d6bac59a73934d80fd8fb95de864`) | sensibilité de √MSEP (#310), prototype hors moteur de T-4, leviers | `m_fm_d.txt` (`eb5b993037179c1c487bedc99718d994`) |

`m_fm_c.R` tire sous `set.seed(20261023)` (Mersenne-Twister, Inversion, Rejection), dans le script et hors du moteur. Contrôles internes [V] : les résidus recalculés égalent `mw_residus()` à 9,8e-15 près, et les résidus redressés égalent `r/√(.mw_un_moins_h())` à 1,2e-14 près. Les chiffres cités ci-dessous sont collés depuis ces sorties.

**Correction d'une donnée du brief [V]** : `reserve2` porte **N = 27** résidus de Mack, et non 28. Ils se répartissent en colonnes de n_j = 7, 6, 5, 4, 3 et 2 ; la colonne j = 6 n'a qu'un facteur. On a Σ(n_j − 1) = 21 et var(r) = 21/26 = 0,8077.

**Sources externes** :
- Mack (1997), p. D6.15-D6.23 : **non lu**. Statut [P] du relevé `verifications-fi.md` § 6.3 ; relevé M38 à venir (Q-40-5).
- Davison et Hinkley (1997) : **non obtenu**.
- Atkinson (1981), *Biometrika* 68(1), p. 13-20 : **[P]**. Une notice et un résumé ont été trouvés par recherche web : « half normal plots with envelopes derived from simulation ». La construction « simuler sous le modèle ajusté, réajuster, trier » n'est attestée que par une documentation de paquet R (`unitquantreg::hnp`), source secondaire.
- Aucune autre référence nouvelle n'est proposée.

**Contraintes de la fiche** :
- aucune ligne nouvelle et aucun préfixe nouveau dans `GROUPES` ;
- `add()`, `engine_registre_tests()` et `engine_p_mc()` inchangés ;
- contrats partagés touchés : `res$plots_data` (#310, #312, #311) et le `type` ou la `variante` d'une ligne (#312). Si l'option (a) de #311 était retenue, s'y ajouteraient les graines et `metadata`.

---

## 1. S-Fm-1 (#312) : test des suites, statistiques par groupe, lecture conjointe

### 1.1 (a) Statut de la ligne « Test des suites sur les residus de Mack »

**Ce que teste la ligne.** Elle vise l'indépendance, D(2)(h)(i) et (ii). Elle porte sur la suite des signes des résidus de Mack, dans l'ordre colonne par colonne, i croissant, le même ordre que Durbin-Watson. La p-value retenue est de Monte-Carlo (clé `Runs`, bilatérale), avec un plancher de 0,002. Sur `reserve2` [V] : Z = −0,400, p_mc = 0,374, verdict OK, p_min = 3,85e-7, p_min_mc = 0,002.

**Niveau et puissance à T = 8 [V]**, d'après les T1 et T2 de #309, plans P1 à P3, B = 999 ; ce sont des constats de simulation sous un plan :
- **Référence de niveau.** ρ = 0,050 à 0,053 au seuil 0,10, par discrétude (oracle à 20 000 triangles par loi). Taux sous H0 : 0,047 (P1), 0,047 (P2) et 0,042 (P3). La ligne fonctionne donc de fait à 5 %.
- **Puissance au seuil 0,10.** Elle reste au plus de 0,159 dans les quatorze scénarios mesurés :
  - P1 : CST20 0,061 ; EXP2 0,064 ; CEL4 0,042 ; CEL6 0,038 ; CST10 0,064 ; EXP0 0,054 ; DFI 0,050 ; CAL7 0,046 ; CAL4 0,046 ; **DCAL 0,126** ; LIG 0,050 ; CELx4 0,026 ;
  - P2 : CST20 0,159 ; CST10 0,086.
- **Comparaison à Durbin-Watson, mêmes triangles.** DW rejette au moins autant dans tous les scénarios où l'une des deux lignes dépasse son niveau : DCAL 0,204 contre 0,126 ; P2.CST20 0,432 contre 0,159 ; CAL4 0,122 contre 0,046. Les seuls scénarios où les suites rejettent plus souvent que DW sont LIG (0,050 contre 0,020) et CELx4 (0,026 contre 0,004), où les deux lignes restent au niveau ou en dessous.
- **Redondance avec DW sous H0** (`m_fm_b.txt`) :
  - corrélation de Spearman des deux p-values : 0,398 (P1), 0,391 (P2) et 0,372 (P3) ;
  - sous P1, la part de triangles où les suites rejettent et DW ne rejette pas vaut 0,019.

**Verdict de pertinence : à remplacer comme test.** La ligne n'apporte pas de preuve propre à T = 8. Son OK sur `reserve2` vient d'un test sans puissance mesurable, au niveau effectif de 5 %.

**Options** (Q-D1-Fm-1) :
- **(A) `variante = "secondaire"`, type test conservé.** C'est la forme de l'issue et de la prévision du plan. Le verdict OK est inchangé et les décomptes par type aussi. Mais cette ligne deviendrait **le seul test à verdict masqué par défaut** de tout l'outil. Depuis #299 et #302, les formes secondaires lognormales (Breusch-Pagan original, KS) sont des diagnostics, et Lilliefors MW est un diagnostic. Avec (A), un ALERTE ou un ECHEC des suites (environ 5 % des triangles sous H0) sortirait de la synthèse par défaut et n'apparaîtrait qu'en annexe « tests exclus » (`display_helpers.R:2209-2214`).
- **(B) `variante = "secondaire"` et diagnostic par décision** (recommandé). C'est la forme de Fh (#299, #302) et du principe consigné dans `CONTEXT.md` (« Diagnostic », paragraphe Fh) : une ligne de type test sans preuve propre à T = 8, quand une ligne conservée vise la même alternative sur la même base, n'est pas gardée comme test.
  - Effets :
    - `type = "diagnostic"` est passé à `add()` ; la p_mc et la p non simulée restent dans leurs colonnes ; `nature_p`, `sens` et `p_retenue` valent NA ;
    - `inoperant` vaut FALSE ;
    - le `detail` est la phrase fixe T-1.
  - **Le verdict passe d'OK à INFO sur `reserve2` : il faut le visa du mainteneur.** σ_USP est inchangé.
  - Effets à mesurer par `coder` : `p_min` et `p_min_mc` de la ligne. Le précédent de KS sous #302 devrait donner `p_min_mc` = NA hors de la branche Monte-Carlo retenue.
- **(C) Retrait** (règle de Fh au sens strict, précédent de Ljung-Box (1), Q-D1-Fh-9). Il retirerait la clé `Runs` du catalogue (13 → 12 clés) et toucherait les scripts de #206 et #309. **Déconseillé** en Fm : le périmètre fixé par Q-40-1 ne prévoit pas de changement de catalogue.

**Décomptes** : § 7.

### 1.2 (b) Statistiques par groupe sur les nuages

**Recommandation (Q-D1-Fm-2).**
- **Statistique** : la **moyenne** des résidus de Mack par groupe, avec l'effectif n_k. Pas la médiane, pour trois raisons :
  - sous le modèle de Mack, E[r(i,j) | C] = 0 cellule par cellule à σ_j connu, sous la seule hypothèse (iii). L'espérance de la moyenne d'un groupe est donc nulle [V, algèbre : E[F(i,j) − f̂_j | C] = 0] ;
  - les écarts visés, années d'accident ou diagonales décalées, sont des déplacements de moyenne ;
  - pour les groupes de un ou deux résidus, nombreux, médiane et moyenne coïncident. La robustesse aux cellules aberrantes relève de M4.
- **Forme** : deux tables nouvelles **ajoutées en fin de liste** de `mw_plots_data()`. Aucune feuille existante n'est déplacée, et `residus_acc` et `residus_cal` restent à une ligne par résidu :
  - `residus_acc_groupes` = `data.frame(i, n, moyenne)` ;
  - `residus_cal_groupes` = `data.frame(calendrier, n, moyenne)`.
  - Elles sont calculées par une fonction nommée, par exemple `.mw_residus_par_groupe(res, cle)`, sur le `res` qui alimente les nuages.
- **Sans doublon avec `mw_calendrier_diagonales()` (#275).** Les étiquettes L/S et les P(Z_k ≤ z_k) restent dans le `detail` de la ligne de diagnostic par diagonale ; elles ne sont pas recopiées dans `plots_data`. L'indexation k = i + j est la même dans les deux objets [V, `m_fm_a.txt`], ce qui permet un renvoi en légende sans calcul.
- **Pas de bande ni de repère** autour des moyennes. Un repère du type ±2/√n_k n'aurait ni source ni loi établie, car les résidus d'une colonne sont liés. Il créerait un quasi-test sans calibration (ADR 0001). L'effectif n_k est restitué pour la lecture.

**Valeurs attendues sur `reserve2` [V, `m_fm_a.txt`]** (moyennes à 1e-5 près, valeurs exactes données par la régénération) :

| diagonale k | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| n | 1 | 2 | 3 | 4 | 5 | 6 | 6 |
| moyenne | 0,10811 | −1,03213 | −1,35373 | −0,70681 | 0,49849 | 1,06507 | −0,07445 |

| année i | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| n | 6 | 6 | 5 | 4 | 3 | 2 | 1 |
| moyenne | −0,5047 | −0,3665 | −0,2242 | 0,3175 | 0,7853 | 0,9015 | 0,5111 |

Les moyennes par diagonale de l'issue sont reproduites [V].

### 1.3 (c) Lecture conjointe Durbin-Watson / calendaire : le constat de l'issue est à corriger

**Constat de l'issue** : sur `reserve2`, « l'ECHEC de DW et celui du test calendaire sont un seul signal ».

**La mesure ne le soutient pas comme propriété générale, ni sur `reserve2` [V].**

1. **Sous H0, les deux lignes sont pratiquement indépendantes.** Corrélation de Spearman des p-values : −0,002 (P1), 0,019 (P2), 0,004 (P3). Rejet conjoint au seuil 0,10 : 0,013, 0,010 et 0,008, contre 0,011, 0,008 et 0,007 pour le produit des marges (`m_fm_b.txt`, 1 000 triangles par plan).
2. **Sous les alternatives mesurées, leurs profils diffèrent** (taux au seuil 0,10) :

   | Scénario | Calendaire | DW | Rejet conjoint (produit des marges) |
   |---|---|---|---|
   | CAL7, choc sur une diagonale | 0,380 | 0,068 | — |
   | CAL4 | 0,344 | 0,122 | — |
   | DCAL, dérive calendaire | 0,216 | 0,204 | 0,042 (0,044) |
   | P2.CST20 | 0,879 | 0,432 | — |

   DW ne voit presque pas un choc localisé sur une diagonale. Il réagit à des structures lisses.
3. **Sur `reserve2`** (`m_fm_a.txt`, `m_fm_c.txt` ; DW centrés : grandeurs de la spécification, hors moteur) :
   - DW = 1,620 ; sous H0 gaussien (999 triangles), P(DW ≤ 1,620) = 0,016 et la moyenne de DW vaut 2,351 (l'issue écrivait 2,30) ;
   - DW recalculé sur les résidus **centrés par diagonale** : 1,307 (P sous H0 : 0 sur 999). Le signal ne disparaît pas, il s'accentue ;
   - DW recalculé sur les résidus **centrés par année de survenance** : 1,857 (P sous H0 : 0,085) ;
   - les moyennes par année de survenance croissent de façon monotone de −0,50 (i = 0) à +0,90 (i = 5).
   - **[H] Lecture** : dans l'ordre de parcours, deux voisins (i, j) et (i + 1, j) appartiennent à deux années de survenance consécutives. Sur `reserve2`, le signal de DW tient davantage à la tendance entre lignes qu'aux moyennes de diagonale. Les deux ECHEC portent donc sur deux traits distincts du même triangle. La ligne « Homogénéité des résidus entre années de survenance » rend OK (p_mc 0,300), et « Homogénéité de f_j » ALERTE (0,080).

**Texte de fond pour `mw:m3cal` et `mw:m3dw`** (pour `docwriter` ; contenu fixé, typographie de `CONVENTIONS.md`) :
- *Lecture conjointe.* Sous le modèle de Mack ajusté au triangle de contrôle, les p-values de Durbin-Watson et du test calendaire sont pratiquement indépendantes (Spearman ≈ 0 sous P1 à P3). Deux ECHEC simultanés ne sont donc ni deux constats d'un même effet, ni un constat renforcé par redondance : ce sont deux signaux distincts.
- Durbin-Watson ne localise rien. Dans l'ordre colonne par colonne, il réagit à toute structure qui rapproche les résidus d'années de survenance consécutives : tendance de ligne, tendance calendaire lisse, dérive de f_j. Il voit peu un choc sur une seule diagonale (CAL7 : 0,068).
- La localisation se lit sur les lignes qui la portent : effets d'année calendaire et leur diagnostic par diagonale ; homogénéité des résidus entre années de survenance ; homogénéité de f_j (M1). Elle se lit aussi sur les moyennes par groupe des nuages (#312).
- Sur le triangle de contrôle, citer les moyennes des deux tableaux du § 1.2 et les trois DW du point 3, en précisant que les DW centrés sont des mesures de la spécification, hors moteur.
- Taux de rejet de DW et des suites sous DCAL, CAL7, CAL4 et P2.CST20 (T2 de #309). Ils remplacent dans `mw:m3dw` et `mw:m3runs` la phrase « dont aucun scénario ne vise la dépendance que teste la ligne », qui est inexacte pour DCAL.
- *Statut* : constats de simulation sous un plan ; intervalles de Clopper-Pearson fonction du nombre de triangles.

**Frontières.**
- **#317 (Fl)** :
  - Fm écrit la lecture conjointe (point 3 de #312) ;
  - le point 9 de #317 (cause du sur-rejet du test des suites) reste à Fl ; la fiche `mw:m3runs`, réécrite en Fm sous (B), doit garder la phrase « cause proposée, non mesurée » telle quelle ;
  - le point 11 (conséquence graphique de var(r) ≈ 0,81) est traité par #311 en Fm, et `architect` devrait l'annoter comme couvert.
- **#297 (Fk)** :
  - le minP par famille exclut les variantes secondaires et les diagnostics : sous (A) comme sous (B), le test des suites sort de la famille M3, qui garde quatre tests ;
  - donnée utile à Fk : la quasi-indépendance de DW et du test calendaire sous H0, et la corrélation de 0,4 entre les suites et DW.

### 1.4 (d) Mack (1997), p. D6.15-D6.23

**Ce qui s'affirme sans la source.**
- Le test calendaire suit Mack (1994), annexe H, p. 162-168 [V, `verifications-fi.md` § 6.2].
- Les graphiques de résidus pondérés figurent dans Mack (1994), chap. 5, p. 124-125 [V, même relevé].
- La lecture conjointe du § 1.3 repose **uniquement** sur des mesures : le brut de #309, versionné, et les simulations de cette spécification. **Aucun texte T-n ni aucun contenu de fond de cette spécification ne dépend de Mack (1997), p. D6.15-D6.23.**

**Ce qui en dépend.**
- La phrase du `.tex`, l. 15750-15751 (« le corps du texte (p. D6.15-D6.23) ne motive pas autrement le changement »), déjà datée du 18 octobre 2026.
- Toute attribution future à Mack (1997) d'une recommandation de lecture des effets calendaires par les graphiques de résidus, ou d'un lien avec la corrélation des facteurs adjacents. Je ne présume pas qu'elle y figure.

**Phrase datée proposée** (Q-Fc-10), à n'employer que si `docwriter` passe avant le relevé M38 :

> « Mack (1997), p. D6.15-D6.23, non relues sur le texte intégral au 23 octobre 2026 : la lecture conjointe ci-dessus ne s'appuie sur aucune de ces pages. »

**Condition** : la dépendance de Fm envers cette source passe de « démarrage » à « passage de `docwriter` » ; le code ne la lit pas (fiche, étape 0).

---

## 2. S-Fm-2 (#311) : QQ-plot des résidus de Mack

### 2.1 (a) Référence : résidus redressés et droite identité ; la droite par quartiles est écartée

**Algèbre [V]** (déjà au `.tex`, `sec:boot-mw`, l. 4374-4390). À σ_j connu, sous les deux premiers moments du modèle de Mack seulement, Var(r(i,j) | C) = 1 − h_ij, avec h_ij = C(i,j)/S_j. Les résidus redressés r̃ = r/√(1 − h) sont donc de variance exactement 1, sans hypothèse de loi.

**Borne exacte, pour toute loi [V, algèbre ; numérique sur `reserve2`].** r̃(i,j)² ≤ Σ_i r(i,j)² = n_j − 1.
- C'est la propriété des moindres carrés : la somme des carrés résiduels sans la cellule, RSS − e²/(1 − h), reste ≥ 0. L'égalité Σ r² = n_j − 1 découle de la définition de σ̂_j².
- Conséquences : |r̃| = 1 exactement pour n_j = 2, et |r̃| ≤ √2, √3, 2, √5 et √6 pour n_j = 3 à 7.
- Mesuré sur `reserve2` : max |r̃|/√(n_j − 1) = 1,000000, borne atteinte en n_j = 2 (`m_fm_d.txt`).
- Le quantile N(0,1) du rang extrême, sur 27 points, vaut 2,085.

**Mesures sous H0** (modèle de Mack ajusté à `reserve2`, erreurs gaussiennes, première colonne fixée, 999 triangles ; `m_fm_c.txt`). Les intervalles sont les quantiles 5 % et 95 % de la distribution sur les triangles, non des intervalles de confiance :

| Grandeur | r brut | r̃ redressé |
|---|---|---|
| moyenne des variances empiriques | 0,8077 | 1,0384 (= N/(N − 1) à 1e-4 près) |
| pente des moindres carrés des statistiques d'ordre sur les quantiles N(0,1) | 0,884 [0,867 ; 0,896] | **1,000 [0,981 ; 1,014]** |
| pente par quartiles (forme de `qqline`) | 1,030 [0,855 ; 1,185] | 1,231 [0,992 ; 1,419] |
| E[statistique d'ordre] − quantile N(0,1), rangs 1 / 7 / 14 / 21 / 27 | +0,499 / −0,032 / −0,002 / +0,033 / −0,491 | +0,342 / −0,189 / −0,003 / +0,194 / −0,333 |

Sur `reserve2` :
- pente des moindres carrés : 0,877 (brut) et 0,989 (redressé) ; la valeur de l'issue est reproduite ;
- pente par quartiles : 1,159 (brut) et 1,416 (redressé) ;
- l'intervalle « 0,88 [0,866 ; 0,896] » de l'issue est un intervalle de distribution à 90 %, et non un intervalle de confiance.

**Conclusions.**
- **Droite par quartiles : écartée.** Sa pente attendue sous H0 n'est pas 1 : 1,03 en brut, 1,23 en redressé. Les marges des petites colonnes sont bornées, donc plus aplaties que la normale. La droite actuelle de la branche base R (`qqline`, 1,159 sur `reserve2`) n'est pas une référence.
- **Droite identité sur les résidus redressés : retenue.**
  - Sa pente attendue sous H0 vaut 1,000 ; l'artefact de 0,88 disparaît.
  - Les résidus redressés sont ceux du vivier de `mw_bootstrap()`, avant recentrage : le graphique montre la loi que le bootstrap rééchantillonne.
- **Limite à dire.** Même sous H0 gaussien, la courbe attendue n'est pas droite :
  - les points extrêmes sont attendus en deçà de la droite d'environ 0,33 en valeur absolue, effet de la borne √(n_j − 1) ;
  - les rangs 7 et 21 sont attendus au-delà d'environ 0,19 ;
  - la légende (T-3) et la fiche M5 le disent. Une forme en S modérée n'est donc pas, à elle seule, un indice de queues légères.

**Forme dans `plots_data`** :
- `qqnorm` reste `data.frame(theorique, empirique)` ; `empirique` porte r̃ et `theorique` est recalculé sur les rangs de r̃. Sur `reserve2`, 10 rangs changent [V] : les 27 valeurs de `empirique` et dix de `theorique` changent ;
- feuille nouvelle `qqline = c(ordonnee = 0, pente = 1)`, posée par le moteur, comme `qqline` du module lognormal. Le choix de la référence est méthodologique.
- Fonction nommée recommandée : `mw_residus_redresses(aj, res)` = `res$residu / sqrt(.mw_un_moins_h(aj, res))`. `.mw_pool_residus()` peut l'appeler sans changer un bit : mêmes opérations, dans le même ordre (« ALGÈBRE FIGÉE », #301). Le critère est `--seuil 0` sur les p_mc.
- **Affichage** : `plot_mw_qq()` est conservée mais réécrite.
  - Elle lit `pd$qqline` dans les **deux** rendus : `plot(d$theorique, d$empirique)` puis `abline()` en base R, et `add_lines()` en plotly.
  - Plus aucun `stats::` dans `display_helpers.R:967-983` (critère de la fiche).
  - `plot_qqnorm()` n'est pas réemployée sous (c) : ses titres nomment H3 et le bootstrap paramétrique lognormal.

### 2.2 (b) Enveloppe : options (a), (b), (c) — Q-40-6

**(b) Écartée sur le fond.** `mw_bootstrap()` rééchantillonne le vivier des résidus redressés (`sample(res_pool, …)`). Une enveloppe lue dans ses réplications décrirait la dispersion des statistiques d'ordre **autour de la loi empirique observée**. Les points observés y tombent par construction, et elle ne peut révéler aucun écart à la normalité. C'est la limite que `tab:conv` nomme déjà : le bootstrap de résidus « ne permet pas de tester la normalité ».

**(a) Simulation gaussienne sous le modèle de Mack ajusté** (construction d'Atkinson (1981) [P], adaptée au QQ normal ; bandes par `engine_enveloppe_qq()`). **Elle informe à T = 8, mais seulement contre une forte asymétrie [V, `m_fm_c.txt`].** Mesures avec bandes construites sur 999 triangles H0, k* = 3 :
- Taux in-sample : simultané 0,079 (brut) et 0,081 (redressé) ; ponctuel 0,78 et 0,77.
- Largeur de la bande simultanée (redressé) : 1,05 au rang 1, 0,97 au rang 14, 1,06 au rang 27.
- Taux de sortie d'au moins un point, sur 2 000 triangles indépendants par loi (intervalles de Clopper-Pearson à 95 %) :

  | Loi des erreurs (variance 1) | Bande simultanée, brut | Bande simultanée, redressé |
  |---|---|---|
  | gaussienne (H0) | 0,099 [0,086 ; 0,112] | 0,103 [0,090 ; 0,118] |
  | Student à 3 ddl | 0,202 | 0,215 [0,198 ; 0,234] |
  | exponentielle centrée (asymétrie 2) | 0,555 | 0,582 [0,560 ; 0,603] |
  | lognormale σ = 1 centrée réduite | 0,692 | 0,702 [0,681 ; 0,722] |
  | une cellule (i = 2, j = 1) déplacée de 4 σ | 0,143 | 0,156 |
  | même cellule, 6 σ | 0,228 | 0,226 |

- **Lecture.**
  - La bande simultanée est calibrée hors échantillon (environ 0,10). Avec une bande fixe sur des triangles indépendants, l'approximation de dessin fixe tient [V, ligne H0].
  - La puissance est utile contre une forte asymétrie (0,56 à 0,70), faible contre des queues lourdes (0,20) et contre une cellule isolée (0,14 à 0,23). La cellule aberrante relève de M4 (MinP4).
  - Sur `reserve2`, aucun point ne sort de la bande simultanée ; un point brut et trois points redressés sortent de la bande ponctuelle.
- **Portée.** La normalité n'est pas une hypothèse du modèle (D(2)(h) ; M5 est en diagnostic depuis #245) et σ_USP n'utilise aucun quantile. Une enveloppe calibrée reconstruirait, en graphique, une vérification de normalité au bon niveau, sur une question qui ne conditionne pas le paramètre.
- **Coût.**
  - Une septième source de tirage (l'annotation du 13/10 dénombre six sources) : graine propre et constante, à choisir par `architect` hors des plages connues. Le flux #229 couvre 20260831 + b ; une valeur voisine de 20261024 serait donc à éviter.
  - Feuilles `metadata$seed_enveloppe_qq_mw`, `qq_enveloppe` et `env_*`.
  - Annotation de l'ADR 0004, réouverture de `CONTEXT.md` « Enveloppe » (_Avoid_ « graine de l'enveloppe (il n'y en a plus) »), `CLAUDE.md` « Reproductibilité » (instruction du mainteneur), sous-section « Reproductibilité et gestion des graines » du `.tex`.
  - Choix du nombre de triangles : le B de l'exécution, ou une constante. À B = 99, il n'y a pas de bande simultanée (`ENVELOPPE_QQ_B_MIN_SIM` = 500).

**(c) Pas d'enveloppe** : résidus redressés et droite identité calculée par le moteur (§ 2.1). Aucune source d'aléa. La légende fixe (T-3) dit la courbure attendue sous H0, et la fiche M5 en donne la mesure.

**Recommandation (Q-D1-Fm-4) : (c)**, pour trois raisons :
- l'apport de (a) se limite à une asymétrie marquée, sur une hypothèse étrangère au paramètre ;
- son coût touche un contrat partagé (graines) et trois documents de décision ;
- la seule chose indispensable à la remise, le retrait du calcul de l'affichage, est obtenue par (c).

(a) reste une option défendable, et le texte T-3a est prêt.

### 2.3 (c) Cohérence avec les lignes M5

**Recommandation** : les lignes M5 (Shapiro-Wilk, Lilliefors) **restent sur les résidus bruts r**. Elles sont des diagnostics, et passer à r̃ changerait leurs valeurs hors du périmètre de #311.
- La fiche M5 et le recensement des graphiques disent la différence : le QQ-plot montre les résidus redressés, ceux du vivier du bootstrap ; les lignes M5 lisent les résidus bruts.
- Le facteur 1/√(1 − h) varie de 1,071 à 1,434 sur `reserve2` [V].
- Les deux résidus des colonnes à n_j = 2 valent exactement ±1 une fois redressés : ils ne portent qu'un signe.

### 2.4 (d) Davison et Hinkley (1997)

Le `.tex` (l. 4415-4418) écrit déjà que le redressement est « une interprétation de l'outil » et qu'« aucune référence bibliographique n'est citée à son appui ». L'algèbre du § 2.1 suffit. **Recommandation** : ne pas citer Davison et Hinkley (1997) pour le redressement. Si le mainteneur souhaite les citer, phrase datée selon Q-Fc-10 :

> « attribution à Davison et Hinkley (1997, chap. 6) non relue sur le texte intégral au 23 octobre 2026 (ouvrage non obtenu, commentaire `6238477255` de la PR #332) ».

Sous (a), la bande simultanée hérite de la citation existante « enveloppe globale de Davison et Hinkley (1997, chap. 4) » et de son statut actuel.

---

## 3. S-Fm-3 (#310) : effet de σ²_{J−1} sur √MSEP ; marquage du graphique

> **Erratum du 24/10/2026** (*consigné par la session principale (IA)*, sur la proposition d'`actuary-approfondi` à la validation de fond de #310 ; vérifié sur le code de `2ab9723`) :
>
> - **(a) § 7, valeurs de test.** Les √MSEP sont à tester à six décimales, et non à trois : 199,494435 (valeur de la règle), 226,413084, 271,305067 et 166,48… (`tests/unitaires/test_merz_wuthrich.R`, l. 583-585). Les valeurs à trois décimales du tableau ci-dessous et de T-4 restent celles qu'imprime le `detail` (`format(·, digits = 6)`).
> - **(b) § 3 (c) est faux.** `mw_valider_triangle()` ne refuse pas seulement nrow < ncol : elle refuse aussi I ≠ J (« Triangle non carre (I = %d, J = %d) : cas non couvert par la formule du paragraphe 4 », `R/engine.R`, l. 7705-7706). Le cas I > J n'est donc pas atteignable dans l'outil, et R2 (« aucun degré de liberté, I − j − 1 = 0 ») vaut **sans condition** dans l'outil. La fiche `mw:m6sig` l'écrit « sous la contrainte I = J imposée par `mw_valider_triangle()` ». La lecture de `regulatory` sur le cas I > J (aucun écart) reste valable, sans objet pour le code.
> - **(c) Condition de `CONTRE` (T-4).** Le contrefactuel est omis quand la règle donne 0 **à la tolérance de l'outil**, c'est-à-dire quand la colonne J − 3 ou J − 2 est dégénérée (`ex$degeneree`, prédicat `.mw_colonne_degeneree()` à 1e-12), et non seulement quand la valeur de la règle est exactement nulle (`R/engine.R`, l. 8247-8263 : `!isTRUE(ex$degeneree) && isTRUE(sens$valeur_regle > 0)`).
>
> **Erratum du 24/10/2026 (2)** (*consigné par la session principale (IA)*, sur la proposition d'`actuary` à la revue finale d'`audit`, constat C1) : **T-4, condition de « non defini »**. Le quotient σ̂⁴_{J−2}/σ̂²_{J−3} est dit « non defini » quand σ̂²_{J−3} = 0 **ou** quand la colonne J − 3 est dégénérée à la tolérance de l'outil (`ex$degeneree_Jm3`, prédicat `.mw_colonne_degeneree()` à 1e-12), et non seulement quand σ̂²_{J−3} est exactement nul. Sinon, une colonne constante à 1e-14 près produit un quotient de l'ordre de 1e+23 et une √MSEP sans sens (mesure d'`audit` : 2,1e+14). La condition est ainsi la même que pour l'omission du contrefactuel (erratum (c) ci-dessus). Le texte de T-4 est inchangé à la lettre. Le test attendu du § 7 (« quotient NA (σ̂²_{J−3} = 0) : « non defini », sans phrase contrefactuelle ») s'étend au cas dégénéré à la tolérance. σ_USP et les références sont inchangés (commit `0ec5395`).

**Lecture de `regulatory`, reprise** (23/10/2026, aucun écart) :
- le texte (consolidé, ▼B) donne σ̂²_{J−1} = min(σ̂²_{J−2}, σ̂²_{J−3}, σ̂⁴_{J−2}/σ̂²_{J−3}) : trois arguments exactement, aucune option ;
- σ̂²_{J−3} = 0 donne un minimum nul par application littérale (#7) ;
- le texte ne dit pas « extrapolation » ;
- le code est conforme ;
- la restitution est permise comme **sensibilité indicative, hors règle, sans effet sur σ_USP**, en écrivant « la règle retient ». Termes à éviter : « alternative », « option », « choix », « plus prudent / conservateur », ainsi que tout σ_USP alternatif.

**Mesures [V]** (`m_fm_d.txt`, identiques à `m310.R` et à l'issue). R = 9 140,843, √MSEP = 199,494, σ_estimé = 0,02182451, σ_USP = 0,04977646. Le contrôle `identical()` de la MSEP recalculée avec la valeur de la règle contre `mw_msep(aj)` est TRUE.

| σ²_{J−1} | valeur | √MSEP | écart |
|---|---|---|---|
| σ̂²_{J−2} | 0,1896737 | 226,413 | +13,5 % |
| **σ̂²_{J−3} (retenu par la règle)** | 0,0973248 | 199,494 | — |
| σ̂⁴_{J−2}/σ̂²_{J−3} | 0,36965 | 271,305 | +36,0 % |
| 0 (contrefactuel, hors des arguments) | 0 | 166,480 | −16,5 % |

**(a) Valeurs restituées.**
- **Les trois arguments**, dans l'ordre du texte. Par construction, ils sont tous ≥ la valeur de la règle : leur restitution ne montre que des hausses.
- **Le contrefactuel σ²_{J−1} = 0, dans une phrase séparée** (Q-D1-Fm-6) : c'est la seule valeur qui mesure le poids de la dernière année de développement dans la MSEP, objet même du constat de #310 (« effet non négligeable », sans chiffre). Il est nommé « contrefactuel qui n'est pas un argument du minimum » et omis quand la règle donne déjà 0.
- **σ_estimé n'est pas restitué** (Q-D1-Fm-7). Les écarts relatifs de √MSEP sont ceux de σ_estimé (même R) ; imprimer des σ_estimé reviendrait à afficher des paramètres concurrents.

**(b) Où** : dans le **`detail`** de la ligne M6. Les valeurs sont déterministes, sans nombre issu du bootstrap (règle #76) ; c'est une chaîne de caractères, donc un patch chirurgical est possible. Pas d'`estim` secondaire (contrat `add()`).
- Fonction nommée recommandée : `mw_sensibilite_sigma2_dernier(aj)`. Elle remplace `aj$sigma2[J]` **et** `aj$Q[J] = sigma2[J]/f[J]^2` (`mw_msep()` lit `Q`), puis appelle `mw_msep()`.
- Critère : avec la valeur de la règle, `identical()` à `mw_msep(aj)`.
- `.mw_detail_extrapolation(ex, sens = NULL)` reçoit son résultat.

**(c) Formulation** : texte T-4. Il applique aussi R1 (« valeur fixée par la règle de minimum… ») dans le `detail`, à l'occasion du même patch (Q-D1-Fm-8).
- **Point qui dépend de `regulatory`** : R2 (« aucun degré de liberté, I − j − 1 = 0 ») ne vaut que si I = J. La validation admet I > J (`mw_valider_triangle()` refuse seulement nrow < ncol). Dans ce cas, la colonne J − 1 porte I − J + 1 ≥ 2 facteurs, que `mw_ajuster()` n'estime pas non plus.
- T-4 évite donc tout décompte de facteurs. La fiche `mw:m6sig` doit conditionner R2 à I = J ; `regulatory` dira si le texte prescrit la règle quand I > J.

**(d) Graphique.**
- Feuille logique nouvelle `plots_data$facteurs$sigma_regle_minimum`, **en dernière colonne** : TRUE en j = J − 1 si `mw_extrapolation_sigma2(aj)$applicable`, FALSE sinon. C'est une règle métier, donc dans le moteur ; c'est aussi un booléen, donc patchable.
- `plot_mw_facteurs()` trace σ̂_j, déjà présent dans `facteurs$sigma`, sur un second axe ou un second panneau, au choix d'`app-review`, avec le point j = J − 1 marqué à part (T-5).

---

## 4. S-Fm-4 (#353, #362)

### 4.1 #353 : affichage de M = min p_ij

**Lieu [V]** : un seul site, `table_synthese_groupe()` (`display_helpers.R:267-268`), qui sert l'onglet Tests et le rapport figé : `fmt_nb(tb$statistique)` y affiche 4 décimales. `fmt_p(5.2e-9)` donne « 5,2e-09 » ; `fmt_p(0.1033278)` donne « 0,1033 », comme `fmt_nb()`. L'affichage de `reserve2` est donc inchangé [V].

**Règle (Q-D1-Fm-10)** : selon la recommandation du plan, une constante d'affichage `STAT_NOMS_PROBABILITE <- c("M = min p_ij")`.
- Une statistique dont le nom y figure est formatée par `fmt_p()`, toutes les autres par `fmt_nb()`.
- Aucun champ nouveau dans `add()`.
- Recensement [V] des `stat_nom` littéraux du moteur : « M = min p_ij » est la seule statistique qui soit une probabilité. L'amplitude relative de la famille α (0,00111) reste en `fmt_nb()` ; son format relève de Fg (#364) s'il le faut.

**Tests unitaires** :
- le `nom_statistique` de la ligne `.MW_LIGNE_CELLULE_ABERRANTE` de `engine_table_tests(ref_reserve2)` appartient à `STAT_NOMS_PROBABILITE` ;
- une ligne fabriquée à `statistique` = 5,2e-9 s'affiche « 5,2e-09 » ;
- `reserve2` donne « 0,1033 », comme avant.

**Références** : identiques au bit près.

**Alternative** : une constante du moteur, lue par `mw_tests()` et par l'affichage, sur le précédent de `.MW_LIGNE_CELLULE_ABERRANTE`. Le moteur serait touché, mais pas ses résultats.

### 4.2 #362 : lignes du bloc (C) de `tab:conv` (Q-D1-Fm-11)

**Critère de l'issue** : chaque ligne de `mw_tests()` qui porte une loi ou une approximation a sa ligne dans `tab:conv`. Les diagnostics sans loi y ont déjà des lignes « Aucune » (variance des résidus, identifiabilité), et je recommande de les y inscrire aussi.

**Inventaire des 21 lignes de `reserve2` [V].** Elles sont couvertes, sauf :
1. **Homogénéité des résidus entre années de survenance (Kruskal-Wallis)**, absente ;
2. **Cellules aberrantes multiples (ESD), diagnostic**, absente ;
3. **Extrapolation de σ̂²_{J−1} (M6)**, seulement évoquée dans la ligne « Variances σ̂²_j » ;
4. **Concentration de la réserve (M6)**, absente.

Les lignes M5 sont dans le bloc (A).

**Contenu de fond des quatre lignes nouvelles** :

| Ligne | Objet | Limite | Nature | Vitesse | Hypothèses | Conséquence à T = 8 |
|---|---|---|---|---|---|---|
| Kruskal-Wallis entre années de survenance | H | χ²(k − 1) | convergence en loi, sous échantillons i.i.d. continus et effectifs croissants (d'après `mw:m3acc`, Kruskal et Wallis (1952) ; non relu par cette spécification) | non établie ; groupes de 6, 6, 5, 4, 3, 2 et 1 résidus sur 8 × 8 | indépendance et échangeabilité des résidus, en défaut (contraintes de colonne) | p du χ² non retenue ; bootstrap retenu, niveau compatible sous le plan mesuré (0,096 N, 0,1005 E, 0,080 A à 0,10 ; #206) ; un résidu par année : H = N − 1, diagnostic |
| ESD généralisé sur résidus de Mack (diagnostic) | R_i de Rosner, valeurs critiques λ_i (éq. (2.5), Student-Bonferroni) | aucune pour des résidus de Mack | — | — | échantillon i.i.d. normal, domaine n ≥ 25 (Rosner 1983, selon `mw:m4ros`), non satisfait | aucune p-value (aucune des trois voies ouverte) ; 0/1 000 déclarations sous H0 (#309) ; repère sans verdict |
| Extrapolation de σ̂²_{J−1} (diagnostic) | *Aucune* : valeur fixée par la règle de minimum de D(5)(d)(ii) | — | — | — | σ̂²_{J−2} et σ̂²_{J−3}, estimées à 1 et 2 degrés de liberté sur 8 × 8 | rien ne converge en T ; sensibilité de √MSEP restituée (#310 : +13,5 % et +36,0 % ; contrefactuel −16,5 %) |
| Concentration de la réserve (diagnostic) | *Aucune* : part exacte sur l'observé | — | — | — | réserves chain-ladder par année | rien ne converge ; repère de 40 % sans fondement ; part non bornée si une réserve est négative |

**Correction d'une ligne existante (Refs #362)**, ligne « Durbin-Watson et suites » :
- dans `mw_tests()`, DW n'a **aucune** p non simulée (loi « residus de triangle -> Monte-Carlo », pas de `p_as`) ; seul le test des suites porte N(0,1) [V, `R/engine.R:11055-11073`]. La colonne « Limite » doit le dire ;
- la moyenne de DW sous H0 est de 2,35 environ (§ 1.3) ;
- sous l'option (B) de Q-D1-Fm-1, préciser que le test des suites est un diagnostic.

Enfin, la ligne « Variances σ̂²_j » renvoie à la ligne « Extrapolation », avec le vocabulaire R1 (« fixée par la règle de minimum », au lieu de « extrapolée »).

---

## 5. S-Fm-5 : textes fixes, à la lettre (leçon 1 de Fj)

Les chaînes du moteur sont en ASCII, sans accents, et `%` s'écrit `%%` dans `sprintf()`. Aucun nombre issu du bootstrap (#76). La source de chaque texte est indiquée ; un énoncé sans source le dit.

**T-1 (#312, option (B) seulement)** : `detail` de la ligne « Test des suites sur les residus de Mack », `type = "diagnostic"`, `variante = "secondaire"`. Source : décision du mainteneur à D1-Fm, forme des phrases de #299 et #302, mesures du § 1.1.
> `Restituee en diagnostic par decision (issue #312) : aucun verdict ni p-value retenue ; l'hypothese releve de la ligne Autocorrelation des residus (Durbin-Watson), calculee sur les residus de Mack dans le meme ordre de parcours, dont le type et le verdict font foi.`

Sous (A), aucun texte : seule la `variante` change.

**T-2 (#312, affichage)** : moyennes par groupe dans `plot_mw_residus_acc()` et `plot_mw_residus_cal()`. Texte d'interface, sans affirmation de fond ; marqueur distinct des points.
- Légende : `moyenne par annee d'accident (n = nombre de residus)` et `moyenne par annee calendaire i + j (n = nombre de residus)`.
- Infobulle plotly : `"i = %{x}<br>moyenne = %{y:.3f}<br>n = %{customdata}"`, et la même avec `i + j = %{x}`.

**T-3 (#311, option (c))** : `plot_mw_qq()`, deux rendus. Source : algèbre et borne du § 2.1 [V] ; mesure de la courbure, citée seulement dans la fiche.
- Titre : `QQ-plot des residus de Mack redresses par le levier (M5, diagnostic)`.
- Axes : `quantiles theoriques N(0,1)` et `r / sqrt(1 - h)`.
- Sous-titre ou annotation :
  > `droite y = x : variance unitaire a sigma_j connu ; |r / sqrt(1 - h)| <= sqrt(n_j - 1), donc points extremes attendus en deca de la droite, meme sous le modele`

**T-3a (#311, option (a) seulement)** : sous-titre
> `enveloppe de simulation gaussienne sous le modele de Mack ajuste (non issue du bootstrap de residus), %s`

`%s` est le gabarit de `.qq_sous_titre()` (bandes, k, réplications). La phrase sur la borne de T-3 est conservée.

**T-4 (#310)** : `detail` de « Extrapolation de sigma pour la derniere annee de developpement ». Source : texte de D(5)(d)(ii) (lecture de `regulatory`) ; valeurs calculées par `mw_msep()`.

Structure : `BASE` (remplace la tête actuelle) + `". min(… ) = …, minimum atteint par …"` (inchangé) + phrases des colonnes dégénérées (inchangées) + `". "` + `SENS` + `" "` + `CONTRE` (si la valeur de la règle est > 0).
- `BASE` (R1) :
  > `Valeur fixee par la regle de minimum de l'annexe XVII, D(5)(d)(ii), seconde ligne, et non estimee : la regle ne lit que les deux dernieres variances estimees`
- `SENS` : `sprintf()` avec `format(·, digits = 6)` pour les √MSEP, `%+.1f %%` pour les écarts, et « non defini » si le quotient est NA :
  > `Sensibilite indicative, hors regle et sans effet sur sigma_USP, de la racine de la MSEP (%s avec la valeur fixee par la regle) a la valeur de sigma2_(J-1) : avec sigma2_(J-2) : %s (%+.1f %%) ; avec sigma2_(J-3) : %s (%+.1f %%) ; avec sigma2_(J-2)^2/sigma2_(J-3) : %s (%+.1f %%).`
- `CONTRE` :
  > `Sans variance sur la derniere annee de developpement (sigma2_(J-1) = 0, contrefactuel qui n'est pas un argument du minimum) : %s (%+.1f %%).`
- Texte attendu sur `reserve2` [V, prototype hors moteur, `m_fm_d.txt`] :
  > `Valeur fixee par la regle de minimum de l'annexe XVII, D(5)(d)(ii), seconde ligne, et non estimee : la regle ne lit que les deux dernieres variances estimees. min(sigma2_(J-2) = 0.189674 ; sigma2_(J-3) = 0.0973248 ; sigma2_(J-2)^2/sigma2_(J-3) = 0.36965) = 0.0973248, minimum atteint par sigma2_(J-3). Sensibilite indicative, hors regle et sans effet sur sigma_USP, de la racine de la MSEP (199.494 avec la valeur fixee par la regle) a la valeur de sigma2_(J-1) : avec sigma2_(J-2) : 226.413 (+13.5 %) ; avec sigma2_(J-3) : 199.494 (+0.0 %) ; avec sigma2_(J-2)^2/sigma2_(J-3) : 271.305 (+36.0 %). Sans variance sur la derniere annee de developpement (sigma2_(J-1) = 0, contrefactuel qui n'est pas un argument du minimum) : 166.48 (-16.5 %).`

  Le prototype a été produit avec une `BASE` qui comptait les facteurs ; la `BASE` ci-dessus la remplace (§ 3 (c)). Le reste de la chaîne est collé de la sortie.
- Si Q-D1-Fm-6 retire le contrefactuel, `CONTRE` disparaît.

**T-5 (#310, affichage)** : légende du point j = J − 1 dans `plot_mw_facteurs()`.
> `sigma_(J-1) fixe par la regle de minimum (annexe XVII, D(5)(d)(ii)), non estime`

**Commentaires de code** (contenu, non à la lettre) :
- en tête de `mw_sensibilite_sigma2_dernier()` : remplacement de `sigma2[J]` et `Q[J]`, contrôle `identical()` ;
- en tête de `mw_residus_redresses()` : algèbre et borne du § 2.1, « ALGÈBRE FIGÉE » si `.mw_pool_residus()` l'appelle.

---

## 6. Documentation (pour `docwriter`, fin de branche) : contenu de fond

- **#310, `mw:m6sig`** :
  - le tableau du § 3 en rubrique Usage, qui remplace « effet non négligeable » sans chiffre ;
  - R1 (« fixée par la règle de minimum », au lieu de « imposée » et « extrapolée ») ;
  - R2 conditionné à I = J (point qui dépend de `regulatory`) ;
  - R3 (Q̂_{J−1} entre dans la MSEP de toutes les années i = 1..I ; la lecture de `regulatory` corrige « années de survenance récentes »).
- **#310, recensement des graphiques** : la ligne `plot_mw_facteurs()` cite σ̂_j et le marquage.
- **#312** :
  - `mw:m3cal` et `mw:m3dw` : lecture conjointe du § 1.3 ;
  - `mw:m3runs` : T-1 et Cadre, sous (B), sans toucher la phrase « cause proposée » (#317) ;
  - `sec:variantes` : tableau à compléter (ligne « Durbin-Watson | Test des suites sur les résidus de Mack | motif ») ; la phrase « Deux tests existent dans le dispositif » est à reformuler par méthode ;
  - synthèse de couverture M1-M6 (l. 14055) ; `tab:nature` ; `tab:pmin` si `p_min` change ;
  - recensement des graphiques (nuages avec moyennes et n_k).
- **#311** :
  - fiches M5 (`mw:m5sw`, Usage) : référence (résidus redressés, droite identité), borne √(n_j − 1), courbure attendue sous H0, tableau du § 2.1, différence avec les lignes M5 sur r bruts, raison du rejet de la droite par quartiles, et, sous (c), l'absence d'enveloppe et sa raison (§ 2.2) ;
  - recensement des graphiques (l. 13044) ;
  - index des fonctions.
- **#362** : § 4.2.
- **Pièce versionnée** (Q-D1-Fm-3) : les chiffres du § 1.3 et des § 2.1-2.2 viennent de scripts de session. Je recommande un tableau daté, `docs/tableaux/20261023-fm-mesures.md`, avec le code des quatre scripts, leurs sorties et les md5. Il serait versionné en commit `docs:` préparatoire, avant le passage de `docwriter`, pour que le `.tex` cite une pièce (précédent Q-D1-Fj-6).

---

## 7. Tableau prévisionnel de `reserve2`, décomptes, références

σ_USP = 0,04977646 reste inchangé à toutes les étapes [V : `mw_parametre()` ne lit ni `mw_tests()` ni `mw_plots_data()`]. Les cinq cas lognormaux ne sont pas touchés : ils sont identiques au bit près (`--seuil 0`) à chaque étape.

| Étape | Effet sur `reserve2.rds` | Feuilles de `plots_data` | Voie | Visa |
|---|---|---|---|---|
| #353 | aucun | — | `--seuil 0` | — |
| #310 | `detail` de la ligne M6 « Extrapolation » (T-4) | `facteurs` : + colonne logique `sigma_regle_minimum` en fin | patch chirurgical (chaîne et booléen, précédent `gamma_bord_au_moins_un`) ; régénération `claude/regeneration-310` si le patcheur refuse l'ajout de colonne | `actuary` |
| #312 (A) | ligne 15 : `variante` « principale » → « secondaire », verdict OK inchangé | + `residus_acc_groupes`, + `residus_cal_groupes` en fin (numériques) | régénération `claude/regeneration-312` | `actuary` |
| #312 (B) | ligne 15 : `variante` secondaire, `type` test → diagnostic, **verdict OK → INFO**, `p_retenue` 0,374 → NA, `nature_p` et `sens` → NA, `detail` T-1 ; `p_min` et `p_min_mc` à mesurer ; p_mc 0,374 conservée | idem | régénération `claude/regeneration-312` | **mainteneur** |
| #311 (c) | aucun résultat de test | `qqnorm` : 27 `empirique` (r → r̃) et 10 `theorique` (rangs) ; + `qqline` = c(0, 1) | régénération `claude/regeneration-311` | `actuary` |
| #311 (a) | idem | + `env_*`, + `qq_enveloppe` ; + `metadata$seed_enveloppe_qq_mw` | régénération ; ADR 0004 annoté avant | `actuary` ; mainteneur (source d'aléa) |
| #362 | aucun | — | — | — |

**Décomptes de `reserve2`** :

| État | Lignes | Tests | Diagnostics | OK | ALERTE | ECHEC | INFO | Variantes secondaires |
|---|---|---|---|---|---|---|---|---|
| Départ (`c63d609`) [V] | 21 | 13 | 8 | 6 | 3 | 4 | 8 | 1 |
| Q-D1-Fm-1 (A) | 21 | 13 | 8 | 6 | 3 | 4 | 8 | 2 |
| Q-D1-Fm-1 (B) | 21 | 12 | 9 | 5 | 3 | 4 | 9 | 2 |

**Registre `DECOMPTES`** :
- sous (B) :
  - « Merz-Wuthrich : entrées par type » passe de (21, 13, 0, 8) à (21, 12, 0, 9) ;
  - « tests reposant sur le bootstrap » passe de 13 à 12 ;
  - écart de concordance attendu, à corriger par un commit `docs:` minimal (M32) ;
- sous (A) : aucun écart. Le compteur « variante secondaire » ne mesure que `premium` et `reserve1`.

**Ordre** : celui de la fiche (#353 → #310 → #312 → #311 → #362), une régénération à la fois. Avant chaque exécution de `references.yml`, un audit léger recherche les désignations positionnelles ; aucune ligne n'est insérée.

**Tests unitaires attendus** :
- **#353** : § 4.1.
- **#310** :
  - `identical()` de la MSEP avec la valeur de la règle ;
  - √MSEP = 199,494, 226,413, 271,305 et 166,480 à 1e-6 relatif sur `reserve2` ;
  - T-4 à la lettre sur `reserve2` ;
  - quotient NA (σ̂²_{J−3} = 0) : « non defini », sans phrase contrefactuelle ;
  - colonne `sigma_regle_minimum` : un seul TRUE, en j = J − 1.
- **#312** :
  - tables de groupes : n et moyennes du § 1.2 à 1e-10 contre `tapply()` ;
  - somme des n = N ;
  - colonne dégénérée exclue comme dans `mw_residus()` ;
  - sous (B) : type, verdict INFO, `inoperant` FALSE, T-1, p_mc égale à `bootstrap$p_mc["Runs"]`.
- **#311** :
  - `qqnorm$empirique` triés égaux à `sort(mw_residus_redresses())` ;
  - |r̃| = 1 pour n_j = 2 ;
  - max |r̃|/√(n_j − 1) ≤ 1 + 1e-12 ;
  - `qqline` = c(0, 1) ;
  - p_mc du bootstrap `identical()` si `.mw_pool_residus()` appelle la fonction commune ;
  - contrôle textuel : aucun `stats::` dans `plot_mw_qq()`.

---

## 8. Relevé M38 (contenu proposé pour `docs/references/verifications-fm.md`)

- **Mack (1997), p. D6.15-D6.23** : [P], contenu non lu au 23/10/2026. À relever par une session à accès complet (Q-40-5). Aucune phrase de cette spécification n'en dépend (§ 1.4).
- **Davison et Hinkley (1997)** : non obtenu (commentaire `6238477255`). Non cité pour le redressement (§ 2.4).
- **Atkinson (1981)**, *Biometrika* 68(1), p. 13-20 : [P]. Le résumé (recherche web du 23/10/2026) atteste des graphiques semi-normaux avec enveloppes simulées. La construction « simuler sous le modèle ajusté, réajuster, trier » n'est attestée que par une documentation de paquet R. À citer seulement sous l'option (a), au statut existant du `.tex`.
- **Calculs sans référence externe** : borne r̃² ≤ n_j − 1 et Var(r) = 1 − h (algèbre, § 2.1) ; sensibilité de √MSEP (`mw_msep()`).

---

## Questions au mainteneur pour D1-Fm

- **Q-D1-Fm-1 — #312, statut du test des suites.**
  - *Recommandation* : (B), variante secondaire **et** diagnostic par décision, avec la phrase T-1 et la forme de Fh. Le verdict passe d'OK à INFO sur `reserve2` : visa requis. Les décomptes deviennent 12 tests et 9 diagnostics.
  - *Alternatives* : (A), variante secondaire de type test, prévision du plan ; le verdict OK est conservé, mais ce serait le seul test à verdict masqué par défaut. (C) retrait, déconseillé.
- **Q-D1-Fm-2 — #312, statistique par groupe.**
  - *Recommandation* : moyenne et n_k, dans deux tables `residus_acc_groupes` et `residus_cal_groupes` en fin de `plots_data`, sans bande ni recopie des L/S.
  - *Alternative* : la médiane.
- **Q-D1-Fm-3 — #312, lecture conjointe et pièce versionnée.**
  - *Recommandation* : adopter le texte du § 1.3, qui **corrige** le constat de l'issue (« un seul signal ») : DW et le test calendaire sont quasi indépendants sous H0 et, sur `reserve2`, portent deux traits distincts. Versionner les mesures en commit `docs:` préparatoire (`docs/tableaux/20261023-fm-mesures.md`).
  - *Alternative* : ne citer dans le `.tex` que le brut de #309 (T2 et paires recalculées) ; les mesures de simulation du § 2 resteraient alors au dossier de spécification.
- **Q-D1-Fm-4 — #311, enveloppe (Q-40-6).**
  - *Recommandation* : **(c)**, pas d'enveloppe : résidus redressés, droite identité posée par le moteur, légende T-3.
  - *Alternative* : (a), simulation gaussienne sous graine propre. Elle est calibrée (0,10 hors échantillon) et informative contre une forte asymétrie seulement (0,56 à 0,70 ; 0,20 contre Student à 3 ddl ; 0,14 à 0,23 contre une cellule isolée). Elle coûte une septième source d'aléa, l'annotation de l'ADR 0004, `CONTEXT.md` et `CLAUDE.md`. (b) est écartée.
- **Q-D1-Fm-5 — #311, référence.**
  - *Recommandation* : résidus redressés r/√(1 − h) et droite identité ; la droite par quartiles est écartée (pente attendue 1,23 sous H0). Les lignes M5 restent sur les résidus bruts.
  - *Facultatif, non recommandé* : une colonne `n_j` dans `qqnorm` pour marquer les points bornés.
- **Q-D1-Fm-6 — #310, contrefactuel σ²_{J−1} = 0** (question 1 de `regulatory`).
  - *Recommandation* : le garder, dans une phrase séparée et nommée « contrefactuel qui n'est pas un argument du minimum » (`CONTRE` de T-4) ; c'est la seule mesure du poids de la dernière année.
  - *Alternative* : le retirer.
- **Q-D1-Fm-7 — #310, σ_estimé** (question 2 de `regulatory`).
  - *Recommandation* : ne pas l'afficher. Les écarts relatifs de √MSEP sont ceux de σ_estimé, et des σ concurrents inviteraient à choisir.
- **Q-D1-Fm-8 — #310, vocabulaire R1 à R3** (question 3 de `regulatory`).
  - *Recommandation* : R1 dans le `detail` (T-4, même patch) ; R1 à R3 dans `mw:m6sig` par `docwriter`. R2 doit être conditionné à I = J, avec une **question à `regulatory`** : la règle s'applique-t-elle telle quelle quand I > J ?
- **Q-D1-Fm-9 — #310, graphique.**
  - *Recommandation* : colonne logique `sigma_regle_minimum` en fin de `facteurs` (patch), et σ̂_j tracé sur `plot_mw_facteurs()` avec le point J − 1 marqué (T-5). La forme, second axe ou panneau, est laissée à `app-review`.
- **Q-D1-Fm-10 — #353.**
  - *Recommandation* : constante d'affichage `STAT_NOMS_PROBABILITE`, confrontée par un test au `nom_statistique` du moteur ; aucun champ nouveau.
  - *Alternative* : une constante du moteur, lue aussi par l'affichage.
- **Q-D1-Fm-11 — #362.**
  - *Recommandation* : quatre lignes nouvelles dans le bloc (C) (Kruskal-Wallis, ESD, extrapolation de σ̂²_{J−1}, concentration) et la correction de la ligne « Durbin-Watson et suites » (DW sans p non simulée, moyenne d'environ 2,35 sous H0).

Recommandations annexes, sans question :
- `architect` annote #317 : son point 11 est couvert par #311 ; son point 9 reste à Fl.
- Si (c) est retenue, `CONTEXT.md` « Enveloppe » peut gagner l'_Avoid_ « enveloppe du QQ-plot Merz-Wüthrich (aucune, #311) ».
