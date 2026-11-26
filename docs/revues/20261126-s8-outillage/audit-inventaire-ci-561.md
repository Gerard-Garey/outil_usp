# Inventaire rafraîchi des redondances de la CI (S8, étape 3 ; Refs #561, #471)

> *Rapport de l'agent `audit` (IA), Opus, effort `medium`, rendu le 26/11/2026 à la session principale et versé tel quel par elle.* Lecture et mesure seulement. L'agent n'a rien écrit dans le dépôt : ni fichier, ni commit, ni issue. Ses essais ont tourné sur une extraction `git archive` de `217cc48` placée dans le scratchpad. Le dépôt a avancé depuis à `3367c5e`, qui ne touche que `docs/adr/0013…` et `docs/feuille-de-route.md` : les tests sont identiques. `tests/controle_doc_nd.R` et `tests/unitaires/test_controle_doc_nd.R`, en cours de modification par `coder`, n'ont été lus qu'à `HEAD`.

## Conclusion

- **Propositions 1 et 5 : confirmées**, sans perte de couverture.
- **Proposition 4 : confirmée et à étendre.** `test_controles_entree.R` est devenu le fichier le plus long : 275 s en moyenne, 357 s au maximum.
- **Propositions 2 et 3 (option B) : réévaluées.** Pour la 2, une assertion perd sa portée (PS-1-a). Pour la 3, le gain de CI annoncé est contredit par la répartition en lots : environ 35 s cumulées, pas environ 150 s (PS-1-b). Il n'y a pas de perte de couverture.
- **Proposition 6 : presque entièrement écartée.** Il reste un retrait (1 assertion) et un partage de résultat : environ 8 s, contre environ 65 s annoncées.
- **Job témoin :** on peut lancer ses quatre fichiers en parallèle. Mesure locale : 377 s en séquentiel, 226 s en parallèle.
- **Hors du plan, nouveaux :**
  - N1 : B = 999 superflu dans `test_texte_2026_269.R`, environ 40 s par exécution.
  - Le critère « écart entre lots < 20 % » échoue sur 4 des 6 exécutions relevées.
  - `tests/durees_unitaires.tsv` est périmé.

## Tableau de classement

| # | Proposition (inventaire du 12/11) | Classement | Gain estimé (s CI) | Couverture |
|---|---|---|---|---|
| 1 | Retirer la comparaison aux références de `test_enveloppe_spread.R` | **Confirmée** | ≈ 52 hors concurrence, ≈ 80-90 dans le lot 1 | Aucune perte |
| 2 | Retirer (c) de `test_incertitude_bootstrap.R` ; (b) et (d) sur le cache | **Réévaluée** | (c) seul : ≈ 0 ; avec le cache : ≈ 0 dans la répartition actuelle | (c) : aucune perte. (a) : vide si le cache répond (**PS-1-a**) |
| 3 | Cache commun des sept cas (option B) | **Réévaluée (gain)** | ≈ 35 cumulées, contre ≈ 150 annoncées ; aucun effet sur la durée réelle ; gain plein en séquentiel (poste) | Aucune perte (**PS-1-b** : gain contredit) |
| 4 | Couper `test_application.R` et `test_p_mc_regime.R` | **Confirmée, à étendre** à `test_controles_entree.R` | 0 cumulé ; seule piste qui abaisse la durée réelle | Aucune perte, **à condition** de mettre à jour la liste du job témoin (PS-1-c) |
| 5 | Mise en mémoire par fichier (`appels_run`, `run_mw()`) | **Confirmée** (sites corrigés, 1 site de plus) | ≈ 35-50 cumulées | Aucune perte hors des sites exclus (liste ci-dessous) |
| 6 | Candidats de `test_controles_entree.R` et `test_rapport_html.R` | **Presque entièrement écartée** | ≈ 8 | 1 retrait couvert, 1 partage ; le reste est voulu |
| — | Job témoin en parallèle (Q-77-3) | **Faisable** | Étape de test : 295-528 s → environ 150-250 s (estimation) | Aucune perte : mêmes fichiers, mêmes contrôles `[saute]` |
| N1 | (nouveau) B = 99 au lieu de 999 dans `test_texte_2026_269.R` l. 319-326 | Candidat, **décision du mainteneur** | ≈ 25-45 | σ_USP identique au bit près (mesuré) ; va contre l'intention écrite l. 24-25 |

## Méthode et mesures

- **Durées réelles :** journaux de 6 exécutions réussies de `ci.yml`, lus par `gh api …/actions/jobs/<id>/logs`.
  - Exécutions : 45818263273 (`b084e13`), 45815238600, 45801832642, 45798136199, 45783990248, 45780981226.
  - Lignes `##### [i/n] fichier : OK, N assertions, X s` pour les lots ; bilans de fichier pour le témoin.
  - La répartition des lots est la même dans les 6 exécutions (empreinte de la liste des fichiers par lot identique).
  - L'exécution de `217cc48` (45825078034) n'a pas lancé les tests : commit `docs:`.
- **Coût d'un cas à B = 999,** hors concurrence, d'après les horodatages de l'étape « Reproductibilité » de 45818263273 (deux exécutions par cas) :

  | Cas | s par exécution |
  |---|---|
  | `premium` | ≈ 10 |
  | `reserve1` | ≈ 9 |
  | `reserve2` | ≈ 15,5 |
  | `premium_ii6` | ≈ 9 |
  | `premium_net` | ≈ 9 |
  | `premium_interieur` | ≈ 16,5 |
  | `reserve2_trapeze` | ≈ 14,5 |

  Soit ≈ 83 s pour les sept cas. Dans un lot à 4 processus, la concurrence multiplie ces durées par 1,6 à 2,6. Comparaison des durées d'un même fichier, seul dans le témoin puis dans son lot : `test_controles_entree` 145 contre 245 s ; `test_defauts_connus` 74 contre 196 s.
- **Mesures locales :** `LC_ALL=C.UTF-8`, R 4.3.3, 4 cœurs, sans shiny, plotly, openxlsx ni le paquet zip ; la commande `zip` est présente.
- **Volume :** `tests/unitaires/` compte 63 fichiers, dont **60 fichiers `test_*.R`** (les trois autres sont `outils_unitaires.R` et deux `generer_*.R`), 47 767 lignes. Par exécution : 1 729 + 1 920 + 916 = **4 565 assertions** dans les lots, plus 1 180 dans le témoin.

## 1. Les propositions 1 à 6 sur l'état actuel

### Proposition 1 — confirmée

- **Bloc visé :** `tests/unitaires/test_enveloppe_spread.R` l. 212-234 (`outils306`, `CAS_LN306`, `comp306` et l'assertion « Cinq cas lognormaux : spread_lisse et qq_enveloppe conformes… »). Il recalcule 5 cas par `executer_cas()` et compare `plots_data[c("spread_lisse","qq_enveloppe")]` aux références par `comparer_objets()`, à `TOLERANCE`.
- **Assertion couvrante :** `tests/test_reproductibilite.R` l. 38-46, qui passe l'objet entier des 7 cas par `comparer_objets(neutraliser_instables(ref), neutraliser_instables(a), tol = TOLERANCE)`.
  - `neutraliser_instables()` (`tests/outils_tests.R` l. 213-228) ne touche que `res$ajustement` et `INSTABLES`, qui est vide : `plots_data` est donc comparé en entier.
  - Même comparateur, même tolérance ; même condition de déclenchement (étape `ci.yml` l. 303, `moteur == 'true'` ; lots l. 119) ; job branché sur l'agrégat bloquant (l. 543).
- **Perte :** l'information « identical() : … » du libellé, sans valeur de verdict.
- **Gain :** les 5 cas lognormaux, ≈ 52 s hors concurrence (moyenne du fichier : 97 s).

### Proposition 2 — réévaluée

- **Bloc visé :** `test_incertitude_bootstrap.R`, qui calcule désormais **7 cas** (`R7`, l. 66), plus 6.
- **(c) l. 212-226 :** `ic_bootstrap`, `ic_bootstrap_restreint`, `parametre_final` et `bootstrap$sigma_boot` comparés aux références. Couvert par la même assertion de `test_reproductibilite.R` l. 38-46 (champs non neutralisés). **Retrait sans perte.**
- **Mais le retrait de (c) seul ne fait rien gagner** : `R7` reste nécessaire pour (a) l. 67-69, pour (b) (l. 71-150 : propriétés de l'objet, quantiles, `boot_reperes`, `regime_boot`, `basic_log`, lignes de l'IC) et pour (d) (affichage, l. 228 et suivantes).
- **Le gain ne vient que du cache, et seulement si un autre consommateur du même lot a déjà rempli le cache.** Dans la répartition actuelle, `test_incertitude_bootstrap.R` est le seul consommateur des 7 cas dans le lot 1 : gain ≈ 0.
- **Assertion (a) :** voir PS-1-a.

### Proposition 3 (option B) — réévaluée sur le gain

Consommateurs à `HEAD` :

| Fichier : ligne | Cas | Lot (exécution 45818263273) |
|---|---|---|
| `test_detail_deux_phrases.R:193` (A2, `res514`) | les 7 cas | lot 3 |
| `test_merz_wuthrich_suite.R:1792` (`res300 <- outils300$CAS$reserve2()`) | `reserve2` | lot 2 |
| `test_constante_ponderee.R:163` `r1 <- run_jeu(x1, y1)` | = `premium` (mêmes données, `donnees_ln.csv` ; B et graine par défaut) | lot 1 |
| `test_constante_ponderee.R:163` `r2 <- run_jeu(x2, y2)` | = **`premium_interieur`** (x2, y2 = `donnees_ln_interieur.csv`, l. 28-29 ; l'inventaire ne l'avait pas vu) | lot 1 |
| `test_enveloppe_qq.R:159` `r999` | = `premium` | lot 1 |
| `test_incertitude_bootstrap.R:66` | les 7 cas | lot 1 |
| `test_enveloppe_spread.R:224` | 5 cas lognormaux (sans objet si la proposition 1 est faite) | lot 1 |

- **Gain dans la répartition actuelle :** lot 1 : `premium` ×2 et `premium_interieur` servis par le cache, soit ≈ 10 × 2 + 16,5 ≈ **35 s hors concurrence** ; lots 2 et 3 : un seul consommateur chacun, gain **nul** ; le job Reproductibilité est un autre job (pas de partage, écarté par l'inventaire).
- **En séquentiel** (poste, repli Windows de `tests/test_unitaires.R` l. 35 et l. 320-323), le gain est plein : ≈ 11 calculs de cas, ≈ 120 s en équivalent CI.
- **Points d'attention pour `coder` :**
  - **Répertoire partagé.** En `--parallele`, chaque fichier tourne dans un Rscript séparé, avec son propre `tempdir()` : il faut un répertoire commun, transmis par variable d'environnement par `test_unitaires.R`.
  - **Portée du cache.** La limiter à une exécution. S'il est persistant, la clé doit inclure `R.version.string` et la BLAS en plus des md5 prévus.
  - **Sérialisation.** Les 7 références ne contiennent ni environnement ni fonction (contrôle exécuté) : un aller-retour `saveRDS`/`readRDS` rend un objet `identical`.
  - **`res300`** appelle `CAS$reserve2()` sans `nettoyer()`. Un cache qui rend `executer_cas()` en diffère par trois champs de `metadata` ; `res300$metadata` n'est jamais lu (`grep`).
  - **Verrou par cas**, sans quoi deux fichiers du même lot calculent en double.

### Proposition 4 — confirmée et à étendre

- **La durée de chaque lot = son fichier le plus long + 20 à 60 s,** sur les 6 exécutions :

  | Lot | Fichier le plus long | Durée du fichier (s) | Durée du lot (s) |
  |---|---|---|---|
  | 1 | `test_application.R` | 210-332 | 223-377 |
  | 2 | `test_controles_entree.R` | 207-357 | 231-404 |
  | 3 | `test_p_mc_regime.R` | 172-251 | 210-303 |

- **`test_application.R` :** un seul processus fils pour 20 blocs `testServer`, script assemblé l. 2659-2807 et lancé l. 2816. La coupe ne perd rien. Les deux moitiés doivent garder le motif `MOTIF_APPLICATION` (`tests/test_unitaires.R` l. 139) pour rester dans le groupe du lot 1.
- **`test_controles_entree.R`** (7 906 lignes, 636 assertions) **est à ajouter** : la table l'estime à 149,5 s, la moyenne mesurée est de 275 s.
- **Condition :** voir PS-1-c.

### Proposition 5 — confirmée (sites corrigés)

**`test_defauts_connus.R`** (lignes de l'inventaire décalées) :

- **Lectures seules réutilisables, 11 appels :** l. 1437 (×3, métadonnées) ; l. 1464 (`appels_run$reserve2()$metadata`) ; l. 1476 (×2) ; l. 1496 (×2) ; l. 1512 (×2) ; l. 1547 (reserve2 ; absent de l'inventaire).
- **Réservoir :** `r_def` (l. 1414). Le contrôle l. 1423 établit qu'il est identique sous les trois générateurs.
- **À garder neufs :** l. 1318-1338 (`r_a`, les deux `appel()`, `r_0`, `r_1`, `r_2` : état du générateur) ; l. 1421 (`r_g` : générateur substitué, cache de Shapiro-Wilk vidé).
- **Gain :** ≈ 11 × (≈ 1,1 à 2,4 s) ≈ 15 s.

**`test_merz_wuthrich_suite.R` (#471) :** voir § 3.

**`test_merz_wuthrich.R`** (`run_mw` défini l. 256) :

- **Répétitions :**

  | Triangle | Lignes |
  |---|---|
  | `tri_deg` | 295, 658, 930, 1468 |
  | `t_ref` (= `triangle_mw.csv`, l. 615) | 637 (×2), 646 |
  | `tri_sym` | 268, 486 |
  | `tri_2` | 303, 448 |
  | `tri_j1` | 426, 451 |
  | `t4` (même construction) | 363, 674 |

  Soit ≈ 9 appels évitables.
- **Pas de piège :** aucune substitution n'enveloppe un `run_mw()`. Celles des l. 523-526 et 892-895 appellent `mw_tests()` directement ; les comptes d'avertissements (l. 1298, 1774) appellent `run_engine()` directement.
- **Gain :** ≈ 10-15 s.

**Forme recommandée :** une mise en mémoire **sur demande, site par site**, ou des variables hissées. Une mise en mémoire implicite dans `run_mw()` servirait aussi les sites qui comptent les avertissements : `test_merz_wuthrich_suite.R` l. 273 (`withCallingHandlers(run_mw(bin_pert_j5))`).

### Proposition 6 — lue cas par cas

| Candidat (lignes du 12/11 → `HEAD`) | Lecture | Classement |
|---|---|---|
| `test_controles_entree.R` 1119/1356 → **1148/1398** | l. 1398 `usage_accepte("alpha", list(0.05, 0.10))` est un sous-ensemble strict de l. 1148 `usage_accepte("alpha", list(0.05, 0.10, 0.29))`. Même aide (l. 1126), même appel nominal à B = `B_MIN_USAGE` ; `x`, `y`, `tri_usage` ne sont pas réaffectés entre les deux (`awk` vide) | **Retrait de l'assertion l. 1398-1399**, couverte par l. 1148-1149 ; 4 `run_engine` à B = 99, ≈ 7 s |
| idem, appels nominaux | l. 1149 (alpha 0,10), 1156 (sigma NULL), 1173 (seed 20260831), 1184 (bareme NULL) et 1200 (B 99) refont le calcul nominal, mais chacun passe une valeur explicite différente | Écarté : chacun teste l'acceptation d'une saisie explicite |
| 3149/3190 → **5856/5897** | Même `run_engine(xc[1:16], yc[1:16], …, T = 10, B = 99)` ; `xc`, `yc` fixés l. 5816 ; les deux assertions ne font que lire, des champs différents | **Partage** (résultat hissé avant l. 5856) ; aucune assertion retirée ; ≈ 1 s |
| 4059/4061 → **6766/6768** | `neutre189` passe sous `avec_injection("usp_pertes_constantes", …)` | **Écarté** (substitution voulue) |
| `test_rapport_html.R` 1014/1054 → **1045/1085** | `res161` sous deux injections (`usp_ajuster_contraint`, `usp_objectif`) ; `res161_ord` ordinaire, comparé à dessein (l. 1088) | **Écarté** |
| 2124/2125 → **2158/2159** | Données distinctes (`.ln_int` contre J1 perturbé) | **Écarté** (pas de doublon) |
| 2125/2391 → **2159/2515** | `.m285` passe sous la substitution d'`engine_registre_tests` (relevé des `mc_nom`) ; l. 2520 vérifie le rejeu « à l'identique » de `res_bmax` | **Écarté** (capture voulue) |
| (lu en plus) `test_rapport_html.R` l. 117 | Recalcul voulu (stabilité des empreintes) | Écarté |

## 2. Job « Témoin openxlsx et archive zip »

- **Couverture propre** (`ci.yml` l. 398-525, boucle l. 503-509) :
  - (i) **17 assertions** que les lots n'exécutent pas, toutes dans `test_controles_entree.R` (653 assertions dans le témoin contre 636 dans le lot 2). Elles tiennent en 9 blocs `[saute]` dans le journal du lot 2 : l. 2659 (corpus naturel), 2685 (absence de chargement), 4023 (D-S1-37), 4731 (#574 R9), 7260 (export par le paquet zip), 7265 (relecture par le témoin), 7300 (divergence), 7373 (repli de `zip::zipr`), 7880 (#580, guillemet).
  - (ii) **La voie `zip::zipr()`** sous les mêmes assertions, dans les trois autres fichiers : même nombre d'assertions que dans les lots (102, 127, 298 ; aucun `[saute]` dans les lots). Sites : `test_outdec.R` l. 309-357 ; `test_defauts_connus.R` l. 1656-1671 ; `test_application.R` l. 715-772, 1273-1296, 1935, 2336.
  - Le reste, ≈ 1 160 assertions, refait ce que font les lots.
- **Durée,** somme séquentielle de l'étape sur les 6 exécutions :

  | Exécution | Témoin (s) | Lot le plus long (s) |
  |---|---|---|
  | 45780981226 | 515,8 | 396,4 |
  | 45783990248 | 527,5 | 404,1 |
  | 45798136199 | 491,7 | 376,8 |
  | 45801832642 | 294,6 | 292,2 |
  | 45815238600 | 386,3 | 286,9 |
  | 45818263273 | 382,9 | 297,8 |

  Le témoin est le chemin critique dans **les 6 exécutions** (au coude à coude dans la quatrième).
- **Parallélisme possible :** les quatre fichiers tournent déjà en parallèle avec d'autres dans les lots (6 exécutions vertes). Le mode `--parallele` capture la sortie de chaque fichier et la réimprime en bloc (`tests/test_unitaires.R` l. 270-282) : le contrôle `[saute]` sur le journal (`ci.yml` l. 511) reste possible. Les blocs propres au témoin écrivent dans `tempfile()` ; ils n'ont pas été exécutés en parallèle (paquets absents en session) : risque faible.
- **Mesure locale** (application sans shiny, donc réduite à 109 assertions) : séquentiel **377 s** ; parallèle **226 s**, soit la durée de `test_controles_entree` seul.
- **Estimation CI :** maximum des fichiers seuls (145-200 s), majoré par la concurrence de 3 processus lourds : **≈ 150-250 s** pour l'étape ; au niveau des lots, sans garantie d'être sous eux.
- **Suggestions à `coder` :** l'option de sélection refuse un nom inconnu, comme le lanceur refuse un argument inconnu (l. 60-67) ; elle garde l'ordre de la table des durées ; les commentaires de `ci.yml` l. 382-384 (« pas d'option de sélection ») et l. 404 (« 195 s en CI ») sont à mettre à jour.

## 3. Les `run_mw(tri_ref)` de `test_merz_wuthrich_suite.R` (#471)

`run_mw` est défini l. 48-49 (B = 99) ; `tri_ref` l. 84-87. Il y a **six sites, pas cinq**. Tous peuvent partager un seul résultat :

| Ligne | Ce qui est lu | Générateur, avertissements, substitution | Partage |
|---|---|---|---|
| 677 | `engine_table_tests()` : `p_min`, `inoperant` | aucun | oui |
| 1357 | `r$tests`, `r$ajustement` | aucun | oui |
| 1443 | `r$tests`, `r$ajustement` | aucun | oui |
| 2069 | `r311` : `ajustement`, `plots_data`. La substitution de `.mw_pool_residus` (l. 2116-2118) vient après, appelle `mw_bootstrap()` directement et se restaure par `finally` | aucun | oui |
| **2141** (absent du brief) | `r10` : `plots_data$origine`, `metadata$alpha`, `residus`, `bootstrap`, `msep` | aucun ; `r05` (l. 2142, alpha = 0,05) reste neuf | oui |
| 2207 | `$tests`, champ `loi` (`LOI_447` reste littéral) | aucun | oui |

- Pour les mêmes arguments, `run_engine()` rend un objet identique au bit près (volet `identical()` de la reproductibilité). La copie à la modification de R empêche un lecteur d'altérer le résultat partagé. `res300` (B = 999) ne peut pas servir : la valeur de B diffère.
- **Gain :** 5 appels à ≈ 2,4 s hors concurrence, soit ≈ 12 s (≈ 20 s dans le lot).
- **Constats de #471 vérifiés :** le test de #449 lit `res300` (l. 2003) ; `LOI_447` est l. 2206.

## 4. Durées par fichier (CI, 6 exécutions, s) comparées à `tests/durees_unitaires.tsv`

« moy » est la moyenne des 6 exécutions ; le ratio est moy / table.

| Fichier | moy | min | max | `b084e13` | table | ratio |
|---|---|---|---|---|---|---|
| test_controles_entree.R | 275,0 | 206,9 | 356,9 | 245,3 | 149,5 | **1,84** |
| test_application.R | 262,9 | 209,6 | 331,5 | 237,5 | 233,7 | 1,12 |
| test_p_mc_regime.R | 219,1 | 171,7 | 251,2 | 241,5 | 218,9 | 1,00 |
| test_concordance_doc_moteur.R | 199,8 | 150,2 | 254,5 | 179,5 | 146,7 | 1,36 |
| test_defauts_connus.R | 174,4 | 134,3 | 197,9 | 196,4 | 192,1 | 0,91 |
| test_merz_wuthrich_suite.R | 172,2 | 123,0 | 225,6 | 154,5 | 231,2 | 0,74 |
| test_detail_deux_phrases.R | 149,8 | 115,5 | 169,5 | 168,3 | 135,7 | 1,10 |
| test_merz_wuthrich.R | 141,2 | 100,0 | 184,2 | 130,2 | 106,3 | 1,33 |
| test_texte_2026_269.R | 134,7 | 106,5 | 174,7 | 121,7 | **absent** | — |
| test_incertitude_bootstrap.R | 121,7 | 90,8 | 159,4 | 108,5 | 111,4 | 1,09 |
| test_rapport_html.R | 111,0 | 81,2 | 145,5 | 100,5 | 105,2 | 1,05 |
| test_enveloppe_spread.R | 96,9 | 73,8 | 126,8 | 86,9 | 107,2 | 0,90 |
| test_outillage_mesure.R | 90,3 | 66,9 | 111,8 | 84,3 | 70,0 | 1,29 |
| test_merz_wuthrich_trapeze.R | 79,9 | 59,2 | 103,7 | 70,6 | 46,9 | **1,70** |
| test_forme_close_m1.R | 79,4 | 61,9 | 89,1 | 89,0 | 88,2 | 0,90 |
| test_origine_non_identifiable.R | 75,1 | 60,5 | 83,8 | 83,0 | 69,3 | 1,08 |
| test_calibration.R | 70,1 | 53,1 | 92,9 | 62,8 | 68,5 | 1,02 |
| test_plancher_mc.R | 66,5 | 50,2 | 85,4 | 59,1 | 53,9 | 1,23 |
| test_garde_ecrasement.R | 62,4 | 50,9 | 69,4 | 68,1 | 66,0 | 0,94 |
| test_anti_bruit.R | 60,9 | 46,4 | 78,6 | 54,5 | 67,8 | 0,90 |
| test_retirage_mw.R | 57,5 | 42,5 | 75,3 | 51,4 | 80,8 | 0,71 |
| test_ex_aequo.R | 55,9 | 43,4 | 64,3 | 62,4 | 37,3 | 1,50 |
| test_lr_delta.R | 51,8 | 39,4 | 59,9 | 58,8 | 55,9 | 0,93 |
| test_inoperance.R | 47,7 | 36,3 | 62,6 | 42,4 | 50,7 | 0,94 |
| test_constante_ponderee.R | 44,4 | 33,6 | 58,8 | 39,9 | 35,7 | 1,24 |
| test_date_reference.R | 41,8 | 33,6 | 47,4 | 47,4 | **absent** | — |
| test_empreinte_moteur.R | 39,6 | 32,0 | 44,5 | 43,5 | 32,5 | 1,22 |
| test_sans_sigma_mw.R | 38,7 | 29,2 | 48,9 | 34,6 | **absent** | — |
| test_chemins_chauds_445.R | 37,9 | 27,7 | 49,7 | 35,2 | **absent** | — |
| test_outdec.R | 35,9 | 28,8 | 46,7 | 32,4 | 25,6 | 1,40 |
| test_enveloppe_qq.R | 32,6 | 25,6 | 42,2 | 28,9 | 34,4 | 0,95 |
| test_controle_doc_nd.R | 29,4 | 23,0 | 37,6 | 27,1 | 22,9 | 1,28 |
| test_statistiques.R | 29,3 | 20,8 | 38,4 | 26,2 | 17,8 | 1,64 |
| test_p_famille.R | 26,7 | 21,3 | 29,8 | 29,6 | 23,3 | 1,15 |
| test_volumes_constants.R | 25,6 | 19,3 | 33,2 | 22,7 | 31,6 | 0,81 |
| test_b_effectif_mw.R | 21,8 | 17,5 | 24,5 | 24,4 | 20,1 | 1,08 |
| test_textes_inconditionnels.R | 18,0 | 13,1 | 23,2 | 16,2 | 23,1 | 0,78 |
| test_tables_mw.R | 17,2 | 13,2 | 22,2 | 15,6 | 13,4 | 1,29 |
| test_verdict_sensible_mc.R | 16,2 | 12,6 | 18,3 | 18,0 | 14,9 | 1,09 |
| test_chargement_moteur.R | 14,3 | 11,1 | 16,3 | 15,9 | 12,1 | 1,18 |
| test_regressions_qr.R | 13,9 | 11,3 | 17,3 | 12,6 | 17,0 | 0,82 |
| test_nature_p_non_simulee.R | 12,9 | 9,5 | 16,8 | 12,1 | 10,0 | 1,29 |
| test_sans_repli_p_non_simulee.R | 12,5 | 10,2 | 14,0 | 14,0 | 11,1 | 1,13 |
| test_mc_nom.R | 12,0 | 9,4 | 13,6 | 13,4 | 7,5 | 1,60 |
| test_regimes_p_exactes.R | 11,8 | 8,3 | 15,0 | 10,8 | 13,9 | 0,85 |
| test_ordonnee_wls.R | 10,0 | 7,0 | 12,5 | 9,2 | 11,9 | 0,84 |
| test_lois_exactes.R | 9,9 | 6,8 | 12,9 | 9,2 | 9,3 | 1,07 |
| test_registre_add.R | 9,1 | 6,5 | 12,6 | 8,2 | 7,4 | 1,23 |
| test_controles_numeriques.R | 7,5 | 5,8 | 9,9 | 6,8 | 9,2 | 0,82 |
| test_m5_diagnostic.R | 7,1 | 5,9 | 8,7 | 8,6 | 5,4 | 1,32 |
| test_modele_lognormal.R | 4,3 | 3,3 | 5,5 | 3,9 | 4,6 | 0,93 |
| test_non_applicable.R | 3,7 | 3,0 | 4,6 | 3,6 | 3,5 | 1,06 |
| test_mk_spearman.R | 3,4 | 2,4 | 4,5 | 3,1 | 4,1 | 0,83 |
| test_affichage_regime_t8.R | 3,3 | 2,7 | 3,8 | 3,6 | 3,4 | 0,97 |
| test_regenerer_et_rendre_compte.R | 2,3 | 1,7 | 2,9 | 2,2 | 2,3 | 1,01 |
| test_comparer_references.R | 2,2 | 1,8 | 2,5 | 2,5 | 1,5 | 1,44 |
| test_comparateur.R | 1,7 | 1,2 | 2,3 | 1,6 | 1,9 | 0,89 |
| test_patcher_reference.R | 1,1 | 0,9 | 1,3 | 1,0 | 1,1 | 0,97 |
| test_jonction_detail.R | 0,8 | 0,6 | 1,0 | 0,9 | 0,5 | 1,67 |
| test_regle_verdicts.R | 0,7 | 0,5 | 1,0 | 0,7 | 0,8 | 0,87 |

Témoin, fichiers seuls :

| Fichier | min-max (s) | moyenne (s) |
|---|---|---|
| `test_controles_entree.R` | 108-201 | 164 |
| `test_outdec.R` | 12,5-25,9 | 20,7 |
| `test_defauts_connus.R` | 55-106 | 85,5 |
| `test_application.R` | 119-195 | 162,7 |

**Écarts à la table :**

- **4 fichiers absents** : `test_texte_2026_269`, `test_date_reference`, `test_sans_sigma_mw`, `test_chemins_chauds_445` (le lanceur le confirme : « 4 fichier(s) hors de durees_unitaires.tsv ») ; la fiche S8 n'en cite que deux.
- **Somme** des moyennes : 3 456 s, contre 2 927 s pour la table.
- **Critère d'équilibre,** (max − min) / min, sur les 6 exécutions :

  | Exécution | Écart entre lots |
  |---|---|
  | 45780981226 | 30,7 % |
  | 45783990248 | 74,3 % |
  | 45798136199 | 79,6 % |
  | 45801832642 | 12,5 % |
  | 45815238600 | 28,7 % |
  | 45818263273 | 14,6 % |

  **Quatre sur six dépassent 20 %.** La mesure unique de la fiche S8 (14,6 %) n'est pas représentative. Le critère de l'étape 4 (trois exécutions) ne paraît accessible qu'avec la proposition 4 étendue.

## 5. Assertions couvrantes des retraits envisagés

| Retrait | Assertion couvrante |
|---|---|
| `test_enveloppe_spread.R` l. 212-234 | `tests/test_reproductibilite.R` l. 38-46 : `comparer_objets` de l'objet entier, `plots_data` non neutralisé |
| `test_incertitude_bootstrap.R` l. 212-226 (c) | idem (`ic_bootstrap`, `ic_bootstrap_restreint`, `parametre_final`, `bootstrap$sigma_boot`) |
| `test_controles_entree.R` l. 1398-1399 | `test_controles_entree.R` l. 1148-1149 (sur-ensemble strict, mêmes aides et même état) |
| Propositions 3 et 5, partages | Aucune assertion retirée : chaque assertion lit le même objet, servi une fois |

## PS-1 (section explicite)

- **PS-1-a — proposition 2 par l'option B : perte partielle de couverture.**
  - **Assertion touchée :** « Sept cas : run_engine() laisse .Random.seed de l'appelant intact » (`test_incertitude_bootstrap.R` l. 65-69). Quand le cache répond, `run_engine()` n'est pas appelé : l'assertion ne contrôle plus rien.
  - **Couvert ailleurs :** `test_defauts_connus.R` l. 1318-1330 (`premium`, `reserve1`, `reserve2` à B = 99 par `run_engine`) ; `test_p_mc_regime.R` l. 638-649 (U11 : `usp_bootstrap` V3b en appel direct, B = 99) ; `test_retirage_mw.R` l. 250 (T257-6 : retirage de Merz-Wüthrich).
  - **Perdu :** le contrôle par `run_engine()` sur `premium_interieur` (flux du régime) et sur `reserve2_trapeze`.
  - **Remède sans perte :** garder (a) sur des appels neufs hors cache, par exemple ces deux jeux à B = 99. À trancher par le mainteneur ; en attendant, ce volet sort du plan.
- **PS-1-b — proposition 3 : l'inventaire est contredit sur le gain, pas sur la couverture.**
  - Annoncé : ≈ 150 s. Mesurable dans la répartition actuelle : ≈ 35 s cumulées, toutes dans le lot 1 ; aucun effet sur la durée réelle. Les consommateurs sont dans trois jobs différents.
  - Le gain plein n'existe qu'en séquentiel (poste) ou si l'on regroupe les consommateurs dans un même lot, ce qui déséquilibre les lots.
  - L'option B reste juste (moteur courant jugé, intention de A2). Le mainteneur décide si son intérêt local justifie le code d'outillage.
- **PS-1-c — proposition 4 : condition de non-perte.** La boucle du témoin (`ci.yml` l. 503) nomme `test_controles_entree`, `test_outdec`, `test_defauts_connus` et `test_application`. Couper `test_application.R`, ou `test_controles_entree.R` (extension proposée), sans ajouter les nouveaux fichiers à cette liste ferait perdre la voie du paquet zip et les 17 assertions propres au témoin des blocs déplacés. Ce n'est pas une perte si la liste suit ; à inscrire comme critère de l'étape 4.
- **Propositions 1 et 5 :** aucune perte, aucune contradiction. **Proposition 6 :** l'inventaire est contredit sur le gain (≈ 8 s au lieu de ≈ 65 s) ; ce qu'on garde ne perd rien.

## Constats hors de la branche (ADR 0018, à trier par la session)

- **N1** — `tests/unitaires/test_texte_2026_269.R` l. 319-326 : quatre `run_engine(B = 999)` servent à comparer σ_USP aux références. `usp_parametre(fit, sigma_standard, bareme)` (`R/engine.R` l. 2527) et `mw_parametre(aj, msep, …)` (l. 14432) ne reçoivent pas le bootstrap. Mesuré : σ_USP **identique au bit près** à B = 99 et à B = 999, sur les cas de 2026 (`premium`, `reserve1`, `reserve2`) contre les références et sur les quatre appels de 2027 (`0.111452411422309342`, `0.103252411422309343`, `0.107352411422309335`, `0.049776461289219934`). Durée locale : 48 s contre 5 s. Cela contredit, pour ce fichier postérieur au 12/11, la conclusion de l'inventaire « aucune réduction de B possible sans perte », mais va contre l'intention écrite l. 24-25. **Critère :** aucun (mineur, durée seule) ; décision du mainteneur, hors Q-77-3.
- **N2** — `tests/durees_unitaires.tsv` : 4 fichiers absents ; `test_controles_entree.R` sous-estimé de 84 %. Mineur ; déjà prévu à l'étape 4 (Q-72-5 (a)).
- **N3** — `ci.yml` l. 382-384 et 404 : commentaires périmés (option de sélection, « 195 s en CI »). Mineur ; tombe avec l'étape 4.
- **N4** — fiche S8 (feuille de route, constats #561) : « deux » fichiers absents de la table au lieu de quatre ; « cinq » `run_mw(tri_ref)` au lieu de six. Mineur, documentaire.

## Vérifications exécutées

- Issues #561 et #471 avec commentaires (`gh api`, REST) ; inventaire et synthèse du 12/11 ; fiche « Branche S8 » et Q-77-3 (feuille de route l. 4812-4895, 8452-8466).
- Jobs et étapes de 45818263273 ; journaux de 30 jobs sur 6 exécutions.
- Lecture de `ci.yml` (lots, reproductibilité, témoin, agrégat), `tests/test_unitaires.R`, `tests/outils_tests.R` (`CAS`, `nettoyer`, `neutraliser_instables`) et `tests/test_reproductibilite.R`.
- Lecture des sites cités, dans `test_enveloppe_spread`, `test_incertitude_bootstrap`, `test_detail_deux_phrases`, `test_constante_ponderee`, `test_enveloppe_qq`, `test_defauts_connus`, `test_merz_wuthrich`, `test_merz_wuthrich_suite`, `test_controles_entree`, `test_rapport_html`, `test_texte_2026_269`, `test_p_mc_regime`, `test_application`.
- Références : aucun environnement ni fonction dans les 7 `.rds`.
- Mesure locale du témoin : séquentiel 377 s, parallèle 226 s ; 636 + 102 + 127 + 109 assertions, toutes vertes.
- σ_USP à B = 99 contre les références et à 2027 : identiques au bit près.
- `git status` : seuls les deux fichiers de `coder` sont modifiés ; rien de l'agent.

## Questions pour `actuary`

Aucune. Rien ne touche à la pertinence statistique. N1 relève du code (σ_USP ne dépend pas de B par construction) et de l'intention du test, donc du mainteneur.

## Statut

**termine.** Inventaire sans défaut du code. Trois points PS-1 sont à porter au mainteneur : PS-1-a (perte partielle), PS-1-b (gain contredit), PS-1-c (condition de non-perte). Aucun critère d'escalade du routage n'est atteint. **Verdict : conforme avec réserves** (les trois points PS-1).
