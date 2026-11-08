# Avis de l'agent `actuary` sur les questions de l'évaluation de la durée de la CI (08/11/2026)

> *Avis rendu par l'agent `actuary` (IA, fiche de base) à la session principale le 08/11/2026, branche K1 (PR #511), à la demande du mainteneur ; reproduit intégralement, mise en forme Markdown seule. Les scripts de mesure cités (`t5.R`, `t6.R`) sont versés dans `mesures/` sous les noms `actuary_t5_merz_wuthrich_B.R` et `actuary_t6_enveloppe_B.R`.*

Avis sur les deux questions d'`audit` (rapport `rapport-audit.md`, § 5). Branche `claude/entrees-et-validation`, tête `88531fc`. Lecture seule : rien n'a été écrit dans le dépôt, aucune issue créée ni commentée. Trois mesures, faites en session sous `LC_ALL=C.UTF-8` avec des scripts du scratchpad.

## Principe commun

Un test unitaire à graine fixe est déterministe. L'erreur Monte-Carlo, qui dépend de B, ne rend donc pas le test instable. En revanche, changer B change le tirage obtenu. La question est de savoir si l'assertion fige une valeur qui dépend de ce tirage. C'est le cas de trois sortes d'assertions :
- une comparaison aux références `.rds`, calculées par la CI à B = 999 (`tests/outils_tests.R:84`) ;
- un oracle de spécification calculé à B = 999 ;
- un plancher `p_min_mc`, de la forme `(1 + N)/(B_eff + 1)` (`R/engine.R:4128-4141`), lu par la règle R1 (`R/engine.R:4543-4556`).

Dans ces trois cas, réduire B oblige à recalculer la valeur attendue avec le code testé lui-même. On perd alors l'indépendance de l'oracle, ou le lien avec les références. Une assertion qui recalcule en clair à partir des réplications obtenues, ou qui porte sur la forme d'un objet, ne dépend pas de B.

## Question 1 — B dans les tests unitaires

### (a) `tests/unitaires/test_merz_wuthrich.R:2574-2603`, appel l. 2588-2589 (reserve2, triangle 5 × 5, B = 999)

**Ce que vérifie l'assertion.** À α = 0,10, elle oppose deux cas sur la ligne calendaire (queue basse, #276) :
- à B = 99, le plancher vaut 0,05 = α/2 : l'ECHEC est inatteignable, le verdict est ALERTE ;
- à B = 999, elle fige `p_retenue` = `p_min_mc` = 0,048 < α/2 : le verdict est ECHEC, sans texte de R1.

L'assertion dépend donc directement de B, par le plancher Monte-Carlo.

**Mesure.** Même triangle, graine 20260831, α = 0,10 :

| B | `p_min_mc` | verdict |
|---|---|---|
| 99 | 0,050 | ALERTE, inatteignable |
| 199 | 0,045 | ECHEC |
| 499 | 0,062 | ALERTE, inatteignable |
| 999 | 0,048 | ECHEC (valeur figée par le test) |

Le plancher oscille autour de 0,05 : la probabilité de l'extrême sous la loi bootstrap est d'environ 0,046, d'après (4 + 47)/(99 + 999). À B = 999, la valeur figée n'est qu'à deux réplications du seuil.

**Conclusion.**
- Réduire B ne garde pas la même force de contrôle. Une valeur de B choisie parce que l'assertion passe encore reviendrait à régler le jeu d'essai sur le bruit Monte-Carlo : déconseillé.
- Ce jeu d'essai est déjà fragile à B = 999. Tout changement de l'ordre des tirages de `mw_bootstrap()` fera basculer l'assertion avec une probabilité d'environ un tiers, et pas seulement une vraie régression. *Estimation : approximation binomiale, avec N ≈ 47 à B = 999.*

**Alternative proposée, qui est une refonte du test et non une simple baisse de B.** Garder B = 99 et passer α à 0,20. Mesuré : p = `p_min_mc` = 0,05 < α/2 = 0,10, verdict ECHEC, aucun texte « inatteignable », en 1,7 s au lieu de 10,1 s ici et de 17 s en CI selon `audit`.
- Ce qui est conservé : la même branche de R1 (plancher sous α/2, aucun texte, ECHEC possible) et une valeur au plancher lui-même, loin du seuil (0,05 contre 0,10). C'est plus robuste qu'aujourd'hui.
- Ce qui est perdu : l'illustration « à α fixé, B gouverne l'atteignabilité ». Si on y tient, il faut la tester sans `run_engine()`, par `engine_p_mc()` sur des simulations construites à la main.
- Pas d'objection de fond. C'est une modification de test à faire par `coder` et à vérifier par `audit`.

### (b) `tests/unitaires/test_enveloppe_spread.R:149-190` (premium, B = 999)

**Ce que vérifie l'assertion.**
- Les bandes sont recalculées en clair sur les courbes obtenues : quantiles de type 7, k* par (4.17), égalité avec `boot::envelope`, emboîtement des bandes. Rien de cela ne dépend de B.
- Ces contrôles exigent seulement B_eff ≥ `ENVELOPPE_QQ_B_MIN_SIM` = 500 (`R/engine.R:8198`), pour que la bande simultanée existe, et ≥ 500 lignes pour le test des seuils 19/20/499/500 (l. 255-265).
- Seuls deux chiffres sont propres à B = 999 : `nrow(L999) == 999L` (l. 166-168) et B_eff = 996 dans le test des lignes NA.

**Mesure.** B = 599 : B_eff = 599, k* = 6, motif NA, 5,75 s. B = 999 : k* = 9, 9,26 s.

**Conclusion.**
- B = 599 garde la même force de contrôle. C'est préférable à 500, qui ne laisse aucune marge au-dessus du seuil si une réplication tombe.
- Il faut alors remplacer 999 par B et 996 par B − 3.
- Gain mesuré en local : environ 3,5 s.

**Accessoire.** Le test « niveau fixe » (l. 192-197, deux appels à B = 199) ne vérifie que l'invariance en α de la bande ponctuelle, qui existe dès B_eff ≥ 20 : B = 99 suffit.

**À ne pas réduire.** Le bloc `comp306` (l. 202-224) compare cinq cas à leurs références. Il est fixé à B = 999 par construction, et il représente l'essentiel des 78 s du fichier.

### (c) `tests/unitaires/test_incertitude_bootstrap.R` (six cas `executer_cas`, B = 999)

Les assertions coûteuses dépendent de B par construction :
- conformité aux références à `TOLERANCE` de `ic_bootstrap`, `parametre_final` et `sigma_boot` (l. 238-248) ;
- oracles de l'intervalle basic (spécification, par. 4) à 1e-5 (l. 173-180) ;
- effectifs de `regime_boot` 463/46/490 et 419/203/377 (spécification, par. 7.2, l. 124-133) ;
- longueur 999 (l. 70-77).

**Conclusion.** Réduire B affaiblirait le contrôle, ou obligerait à refaire les oracles de la spécification avec le code testé : refusé. Les autres assertions, identités et forme des objets, ne dépendent pas de B, mais elles ne coûtent rien de plus une fois R6 calculé. Le seul levier serait B1 (partage des six cas avec `test_reproductibilite`), refusé par le mainteneur.

### Tests où réduire B affaiblirait la détection d'une régression

- (a) en l'état ;
- (c) en entier ;
- le bloc `comp306` de (b) ;
- plus généralement, toute assertion qui fige un `p_min_mc`, un verdict proche d'un seuil, une phrase #244 (qui dépend de `err_mc`, donc de B), ou une valeur comparée aux références.

## Question 2 — Cache de `sw_loi_nulle()` sur disque

**Ce que fait la fonction aujourd'hui.**
- `sw_loi_nulle()` (`R/engine.R:2206-2220`) trie 20 000 valeurs de W tirées sous `engine_sous_graine(SEED_LOI_NULLE_SW)`.
- La clé du cache est `n`, `B_null`, `seed`, `ENGINE_RNG_KIND` (l. 2207-2208).
- La loi ne sert qu'à la ligne de diagnostic M5 « Shapiro-Wilk sur les résidus de Mack » (`R/engine.R:12506-12514`) :
  - p en colonne `p_asymptotique`, comme p sous un modèle auxiliaire (loi de W pour un échantillon i.i.d. normal, et non sous le modèle de Mack) ;
  - type `diagnostic`, aucun verdict ;
  - graine consignée dans `metadata$seed_loi_nulle_sw` (l. 13042).
- Mesure : 1,44 s par n distinct (n = 8 et n = 11).

**Plan statistique.**
- Si le contenu servi est identique au bit près, rien ne change :
  - ni la loi ;
  - ni la nature de la p-value (approximation Monte-Carlo, d'erreur en O(B_null^-1/2), de la loi exacte de W sous i.i.d. normal, restituée comme p sous modèle auxiliaire) ;
  - ni le contrat de reproductibilité (un `identical()` sur une même machine).
- La difficulté est la portée de la clé. La clé en mémoire n'est complète que parce que le processus fixe implicitement le reste : version de R, code C de `swilk` et de `qnorm`, corps de `sw_loi_nulle()`, plateforme. Un fichier qui survit au processus doit porter ces éléments dans sa clé : version de R, plateforme, empreinte md5 du corps de `sw_loi_nulle()` et de `stats::shapiro.test`.
- Traçabilité, exigence ferme : aucun chiffre destiné au dossier ne doit dépendre d'un fichier hors version et hors code. La régénération par `references.yml`, l'application et les scripts de mesure doivent calculer la loi, jamais la lire. Le cache doit donc être réservé aux tests et éphémère : `tempdir` ou `RUNNER_TEMP` du job, jamais `actions/cache` d'un run à l'autre.

**Plan de l'architecture (obstacle de fond seulement).**
- **Dans le moteur.** Une lecture-écriture disque dans `engine.R` ferait du fichier une entrée implicite du calcul. Cela contredit `docs/exigences.md` § 4.2 : « Les entrées sont des arguments R explicites ». C'est une réserve de fond, pas un interdit absolu ; le mainteneur tranche.
- **Côté tests.** La même économie s'obtient sans toucher au moteur :
  1. le lanceur appelle lui-même `sw_loi_nulle(n)` pour les n requis ;
  2. il écrit le résultat dans un fichier temporaire ;
  3. chaque processus fils pré-remplit `environment(run_engine)$.cache_sw` après `charger_moteur()`, au point de substitution de l'ADR 0016.

  Contenu et clé sont produits par le code testé, dans le même job. Condition : les tests du cache (`tests/unitaires/test_defauts_connus.R:1356-1420`, `tests/unitaires/test_lois_exactes.R:726-746`) doivent continuer à vider leurs entrées avant de calculer. C'est déjà le cas pour ceux qui ont été lus : `rm(... .cache_sw)` aux l. 1358, 1376 et 1418.

## Retour

- **Statut** : `complet` sur les deux questions, sous réserve des points non vérifiés ci-dessous.
- **Résultat** :
  - Q1 :
    - (a) ne pas réduire B : le jeu d'essai est fragile même à B = 999 ; refonte proposée à B = 99 et α = 0,20 ;
    - (b) B = 599 acceptable, en remplaçant 999 par B et 996 par B − 3 ; « niveau fixe » à B = 99 ; `comp306` intouchable ;
    - (c) ne pas réduire B ; le seul levier était B1.
  - Q2 : aucun effet statistique si le contenu est identique et la clé complète (version de R, plateforme, empreinte du code), à condition que le cache soit réservé aux tests, éphémère, et jamais utilisé pour un chiffre du dossier. Le pré-remplissage côté tests est recommandé plutôt qu'une lecture-écriture disque dans le moteur, qui heurterait § 4.2.
- **Preuves** :
  - *Vérifié (lecture)* :
    - `test_merz_wuthrich.R:2563-2603` ;
    - `test_enveloppe_spread.R:149-224, 255-280` ;
    - `test_incertitude_bootstrap.R:56-133, 173-180, 238-248` ;
    - `tests/outils_tests.R:84` ;
    - `R/engine.R:4085-4145, 4543-4556, 8197-8198, 2130-2228, 12506-12514, 13036-13046` ;
    - `docs/exigences.md:94`.
  - *Vérifié (mesure)* :
    - t5 : B = 99 à α = 0,10, ALERTE inatteignable ; B = 99 à α = 0,20, ECHEC en 1,7 s ; B = 199, 0,045, ECHEC ; B = 499, 0,062, ALERTE ; B = 999, 10,1 s ;
    - premium : B = 999, 9,26 s, k* = 9 ; B = 599, 5,75 s, B_eff = 599, k* = 6, motif NA ;
    - `sw_loi_nulle` : 1,44 s par n.
  - *Hypothèses* :
    - probabilité d'environ un tiers de basculement de (a) à chaque changement de l'ordre des tirages ;
    - gain en CI d'environ 1,5 fois le gain local.
  - *Non vérifié* : fichiers de test modifiés selon ces propositions non exécutés ; gain total du cache côté tests non mesuré.
- **Décisions non résolues** :
  - pour le mainteneur : architecture du cache (moteur ou tests) ;
  - pour le mainteneur, sur avis d'`audit` : acceptation de la refonte de (a), qui change le contraste testé.
- **Critères déclenchés** : aucun.
- **Prochaine action recommandée** : une issue de tests (`needs-triage`), sur accord du mainteneur, qui regroupe :
  - la refonte de (a) à B = 99 et α = 0,20, en signalant la fragilité actuelle ;
  - B = 599 dans (b) et B = 99 pour « niveau fixe » ;
  - en option, le pré-remplissage de `.cache_sw` par le lanceur (fichier éphémère du job, clé complète, interdit hors tests).
