# Inventaire des redondances des tests et de la CI (#561)

> *Rapport de l'agent audit (IA), rendu le 12/11/2026 à la session principale, hors branche, sur décision du mainteneur (Q-60-6 (b) : inventaire pendant K3b, sans retrait ; retraits éventuels après la remise).* Versé intégralement par la session principale sur la branche K3b (Refs #561). Arbre lu : `main` `7eca6e4`. L'agent n'a rien écrit dans le dépôt. Aucun retrait n'est proposé, seulement des pistes classées.

## Conclusion

Il y a de vraies redondances. La principale : les six cas de référence (B = 999) sont recalculés dans quatre fichiers unitaires, alors que `test_reproductibilite.R` les vérifie déjà en entier. D'autres résultats moteur sont aussi recalculés à l'identique à l'intérieur de plusieurs fichiers.

**Mais la durée réelle de la CI est bornée par les fichiers les plus longs**, pas par le temps total. Chaque lot fait tourner 4 processus à la fois. Le lot 1 dure 289 s quand `test_application.R` seul en prend 234 à 277. Au-dessous d'environ 230 à 280 s, un lot ne peut donc descendre que si l'on raccourcit ou coupe `test_application`, `test_merz_wuthrich_suite` et `test_p_mc_regime`. Les autres gains font économiser des minutes de runner et aident à équilibrer les lots.

## Ce qui a été mesuré

- **Traçage** de `run_engine`, `usp_bootstrap`, `mw_bootstrap` et `usp_lr_delta` sur les 55 fichiers, avec la durée de chaque expression de premier niveau (script et agrégat dans le scratchpad de la session, non versés).
  - Bilan : 3 745 assertions en local (3 775 en CI ; l'écart vient des blocs shiny/plotly, absents du poste de l'agent). Un seul faux échec, causé par le traçage lui-même (`test_outdec`, contrôle du corps de `run_engine`).
  - 1 472 appels de `run_engine` au premier niveau, dont 97 combinaisons d'arguments répétées. 367 `usp_bootstrap` pour 149 combinaisons distinctes, 228 `mw_bootstrap` pour 98.
- **Limites de cette mesure** :
  - Les durées tracées sont gonflées par le calcul de l'empreinte des arguments. Elles sont ramenées en secondes CI par le rapport entre la durée CI (`tests/durees_unitaires.tsv`) et la durée tracée : ce sont des ordres de grandeur.
  - Les moteurs chargés par `outils_tests.R` (fonctions `CAS`, `executer_cas`) ne sont pas tracés ; ils ont été mesurés par la durée des expressions de premier niveau.
  - Deux appels aux mêmes arguments ne sont pas forcément redondants : contexte différent (substitution dans `environment(run_engine)`, `OutDec`, état du générateur aléatoire). Chaque cas « confirmé » ci-dessous a été lu.
  - Les fichiers de trace par fichier ont été effacés en cours de route (répertoire scratchpad partagé avec d'autres agents de la session) ; l'agrégat a été conservé.
- **Temps sans traçage, en local** (le poste est environ 1,8 fois plus lent que la CI) :
  - `run_engine` à B = 99 : premium 2,0 s, reserve1 1,1 s, reserve2 4,3 s.
  - À B = 999 : premium 10,8 s, reserve1 9,5 s, reserve2 14,7 s, premium_interieur 16,2 s, soit environ 70 s pour les six cas.
  - En CI, `test_reproductibilite.R` fait les six cas deux fois en 76 s, soit environ 38 s par série.
  - `concordance_doc_moteur.R --strict` seul : 33 s en local, 20 s en CI.

## Piste 1 — concordance `--strict` en double ? **Non, chaque exécution couvre autre chose**

- **Étape CI `--strict`** (`ci.yml`, job reproductibilité) : seul contrôle de l'état réel du dépôt (vrai `.tex`, vrai moteur, sortie 0). Le fichier unitaire ne contrôle jamais l'état réel, par décision (a) de #65, écrite l. 1290-1295.
- **`test_concordance_doc_moteur.R` l. 545-548 (`.lancer_concordance`)** : employé une seule fois, l. 639 (`--B 98`). Il couvre le refus d'un B trop petit, sans lancer le moteur, en environ 1 s.
- **l. 551-577 (`.juger_tex`)** : les copies mutantes du `.tex` sont jugées dans le processus, avec les objets moteur construits une fois (#444).
  - Coût en local : 34 s pour le premier jugement (l. 579, qui inclut environ 9 `run_engine` à B = 99), puis environ 11 à 18 s pour chacune des cinq autres copies (l. 595, 618, 825, 1179, 1228), soit environ 80 s.
  - Ce coût vient de `concordance_executer()` sur un `.tex` de 20 k lignes, pas du moteur.
- **l. 896-906** : extraction sous `LC_ALL=C` dans un processus fils (#113), environ 17 + 15 s en local. Elle couvre la locale, que rien d'autre ne couvre.
- **l. 1248-1275 (copie mutante du dépôt, #160)** : 58 s en local sous charge, environ 20 à 30 s en CI. Elle couvre deux choses que la CI ne couvre pas : le vrai `quit(status = 1)` ; un moteur muté (constantes et champs renommés, donc des objets moteur qui ne peuvent pas être réutilisés).
- **Gain possible sans perte de couverture :** aucun.
- **Optimisation sans redondance :** regrouper les injections compatibles dans moins de copies du `.tex`, environ 30 à 40 s CI. Risque moyen : une injection peut en masquer une autre dans les décomptes ; aujourd'hui chacune est jugée seule.

## Piste 3 — `test_reproductibilite.R` et les fichiers qui rejouent les six cas : **redondance réelle, le plus gros gain**

`test_empreinte_moteur.R` ne rejoue aucun cas : il contrôle l'empreinte syntaxique d'`engine.R` sur des copies. Il n'est pas concerné. `test_reproductibilite.R` compare l'objet entier aux références : tous les chemins, à 1e-6, et les champs non numériques à l'identique. Les références contiennent `plots_data`, `bootstrap`, `tests`, `ic_bootstrap`, etc. Recalculs à B = 999 dans les fichiers unitaires :

| Fichier : ligne | Recalcul | Coût (local tracé → estimation CI) | Ce qui est lu | Verdict |
|---|---|---|---|---|
| `test_enveloppe_spread.R:216-230` | 5 cas lognormaux | 251 s → environ 90 s (sur 107) | `spread_lisse` et `qq_enveloppe` comparés aux références par `comparer_objets` à `TOLERANCE` | **Redondance pure** : sous-ensemble strict de la comparaison de `test_reproductibilite.R` (même comparateur, même tolérance, même condition de déclenchement `moteur == true`) |
| `test_incertitude_bootstrap.R:60-66` (puis l. 70-230) | 6 cas | 374 s → environ 100 s (sur 111) | (a) `.Random.seed` intact ; (b) identité exacte quantiles ↔ `ic_bootstrap` ; (c) `ic_bootstrap`, `parametre_final` et `sigma_boot` comparés aux références ; (d) affichage | (c) **redondant** avec la reproductibilité ; (b) et (d) propriétés de l'objet, lisibles sur la référence ; (a) en partie couvert ailleurs (`test_defauts_connus` l. 1304-1324, 3 méthodes à B = 99 ; `test_p_mc_regime` l. 640-647, flux du régime) |
| `test_detail_deux_phrases.R:186-193` (A2) | 6 cas | 125 s → environ 115 s (sur 136) | règles du `detail` (texte) | Le texte est comparé à l'identique par la reproductibilité. Le commentaire l. 187-189 veut délibérément le moteur courant plutôt que des références antérieures à un patch |
| `test_merz_wuthrich_suite.R:1787-1790` (`res300`) | reserve2 | 77 s → environ 30 s | décomptes et verdicts ; `sigma_usp` comparé à la référence (l. 1866) | Lisible sur `reserve2.rds`, déjà lu l. 1866 |
| `test_constante_ponderee.R:160-161` (r1) et `test_enveloppe_qq.R:159` | premium sur J1, B = 999, même empreinte d'arguments, donc égal à `CAS$premium` | environ 11 + 11 s tracés → environ 15 s | p Monte-Carlo de #215 ; bande simultanée (B_eff ≥ 500) | B = 999 nécessaire. Recalcul inter-fichiers du cas `premium` |

- **Gain** : environ 330 à 350 s CI cumulés. Deux de ces fichiers sont dans le groupe shiny du lot 1 (`test_enveloppe_spread`, `test_incertitude_bootstrap`) : ce gain allège le lot 1 en dehors de `test_application`.
- **Option A, lire `tests/reference/<cas>.rds`** au lieu de recalculer :
  - Pour les assertions de type (c), le retrait ne perd aucune couverture.
  - Pour les autres, risque réel : quand un commit change un résultat et que les références ne sont pas encore régénérées par `references.yml`, les fichiers unitaires jugeraient des références périmées. La protection reste le job de reproductibilité, rouge dans cette fenêtre, qui bloque la fusion.
  - C'est contraire à l'intention écrite de A2. **Décision du mainteneur.**
- **Option B, cache commun des six cas** : clé = md5 d'`engine.R`, de `outils_tests.R` et de `tests/donnees/` ; un fichier dans un répertoire temporaire, avec un verrou en mode `--parallele`.
  - Le moteur courant reste jugé. Gain réduit à environ 38 s CI par lot qui en a besoin, au lieu d'environ 38 s par fichier.
  - Risque faible si la clé est complète. Plus de code d'outillage.
- **À écarter :** partager entre jobs les résultats de `test_reproductibilite.R`. Il faudrait des artefacts et des `needs:`, qui mettraient les jobs en série et allongeraient la durée réelle.

## Piste 2 — `run_engine()` et bootstraps refaits dans un même fichier : **redondance partielle**

- **Estimation brute** (même empreinte d'arguments, sans tenir compte du contexte) : environ 385 s CI de recalculs à l'intérieur des fichiers, sur environ 1 550 s d'appels moteur. Au niveau des bootstraps (calcul déterministe à arguments égaux) : 926 s tracés, environ 350 à 400 s CI.
- **Confirmés par lecture** (aucune substitution, aucun changement d'option ni de générateur ; les assertions ne lisent que le résultat) :
  - `test_defauts_connus.R` : l. 1422 (3 appels, métadonnées), 1446 (`appels_run$reserve2()$metadata`), 1458, 1478 et 1494 (premium et reserve1, 3 fois). Soit 10 `run_engine` à B = 99 identiques à `r_def` (l. 1401), environ 11 s CI. `r_def` lui-même pourrait reprendre `r_0` du bloc l. 1317 (3 appels de plus, environ 4 s).
  - `test_merz_wuthrich.R` : `run_mw(tri_deg)` (définie l. 255) est appelée environ 9 fois, aux l. 199, 212, 291, 650, 922, 1460, plus `run_engine` l. 1460 et `test_merz_wuthrich_suite.R:551`. `run_mw(tri_sym|tri_2|tri_ach)` est répétée l. 263, 298, 324, 335, 440 et 478. Une mise en mémoire par fichier dans `run_mw()` fait gagner environ 25 à 55 s CI sur les deux fichiers (`suite` l. 205, 340, 398-455 à vérifier une par une).
- **Écartés, ce n'est pas de la redondance** :
  - `test_outdec.R` l. 65/67, 75/78, 86/88, 109/111 : paires « . » et « , » (OutDec), voulues.
  - `test_lr_delta.R` l. 345-488 : `calcul_j2()` sous injection (`avec_injection_161`), voulu.
  - `test_defauts_connus.R` l. 856-1011 : `jk_imposer()` substitue `usp_jackknife`. Seul le bootstrap y est identique.
  - `test_defauts_connus.R` l. 1304-1412 : appels répétés exigés par le contrôle du générateur.
  - `test_merz_wuthrich.R:1297` : compte les avertissements de R, il faut un appel neuf.
- **Non vérifiés** (candidats signalés par l'empreinte, à lire au cas par cas) : `test_controles_entree.R` (1 053 appels, 959 combinaisons distinctes ; l. 1119/1356, 4059/4061, 3149/3190 ; environ 45 s CI) et `test_rapport_html.R` (l. 1014/1054/2124, 2125/2391 ; environ 20 s CI).
- **B réduit** : la plupart des appels sont déjà à B = 99 = `B_MIN_USAGE`, le minimum admis par `run_engine()`. Les appels restants à B = 999 lisent tous une valeur qui dépend de B (cas de référence, p Monte-Carlo de #215, bande simultanée). **Aucune réduction de B possible sans perte.**
- **Mise en mémoire de `usp_bootstrap` / `mw_bootstrap` substituée dans `environment(run_engine)`** :
  - Elle conserverait les résultats, même sous des substitutions en aval comme `jk_imposer`.
  - **Mais elle affaiblirait les contrôles de `.Random.seed` et de `RNGkind`** : pas de tirage sur un appel déjà servi par le cache. Il faudrait donc l'activer bloc par bloc, jamais pour tout le fichier.
  - Elle serait fausse si une fonction appelée par le bootstrap est substituée (`usp_simuler`, `usp_ajuster_contraint` dans `test_lr_delta`).
  - Risque moyen.

## Piste 4 — assertions dupliquées entre fichiers : **pas de doublon littéral**

- Recherche statique des intitulés passés à `verifier()` : aucun intitulé complet n'est identique dans deux fichiers.
- Recouvrements de fond :
  - (i) les comparaisons aux références de `test_incertitude_bootstrap` et `test_enveloppe_spread` sont incluses dans celle de `test_reproductibilite.R` (piste 3) ;
  - (ii) « `.Random.seed` intact après `run_engine` » est contrôlé dans `test_defauts_connus` (3 méthodes), `test_incertitude_bootstrap` (6 cas) et `test_p_mc_regime` U11 (flux du régime), avec des portées différentes.
- `test_merz_wuthrich_suite.R` déclare ne reprendre que le préambule (l. 1-12) ; non contredit.
- Les nombreuses lectures de `tests/reference/*.rds` (`test_rapport_html`, `test_inoperance`, `test_p_famille`, `test_mc_nom`, `test_non_applicable`…) contrôlent des propriétés propres, ne coûtent presque rien, et ne sont pas redondantes.

## Piste 5 — préparation (`setup-r`)

- `setup-r` tourne dans 5 jobs (3 lots, reproductibilité, documentation ; plus `ecarts-references` en cas d'échec). Aucune action R dans `pdf-invariant.yml` ni dans `mots-cles-fermeture.yml`.
- Les paquets shiny et plotly sont déjà en cache, mais pas R lui-même : `setup-r` v2.14 ne met pas R en cache, à la connaissance de l'agent ; non vérifié dans le code de l'action.
- Mettre en cache `/opt/R/4.3.1` avec `actions/cache`, ou employer une image conteneur, touche la plateforme qui produit les références (ADR 0011, M34). Il faudrait que le contrôle bloquant `blas-reference` et `controle_blas.R` restent après le cache. Avec une image différente, il faudrait une bascule et une régénération. **Risque élevé, décision du mainteneur.**
- Gain : environ 30 à 60 s de durée réelle par lot, car c'est le chemin critique. Pour les jobs reproductibilité et documentation, qui ne sont pas sur le chemin critique (environ 200 s contre environ 350 s par lot), le gain n'est qu'en minutes de runner.

## Autres constats

- **Borne de la durée réelle** : `test_application.R` fait tous ses scénarios shiny dans **un seul** processus fils (l. 1860-2040, 140 assertions, `base` à B = 99). Il n'y a pas de double exécution entre les blocs du processus principal et ceux du processus fils : les blocs `testServer` sont des chaînes `r"---(...)---"` jointes au script. Non profilé (shiny absent du poste de l'agent).
  - Le couper en deux fichiers ou deux processus parallèles ne perd aucune couverture et lève la borne du lot 1.
  - Pour `test_p_mc_regime.R`, les oracles U2-U4 coûtent 140 + 133 s tracés (l. 204-262), conformément à la décision Q-240-3 « tout dans la batterie ». Aucune redondance notable (environ 15 s CI). Même remède : couper en deux fichiers.
- **Équilibrage** : le groupe shiny forcé dans le lot 1 (environ 590 s CI cumulés sur 5 fichiers) se combine mal avec un maximum par fichier de 234 à 277 s. L'option A ou B de la piste 3 l'allège d'environ 200 s.

## Propositions classées (gain CI cumulé / risque de perte de couverture)

1. **Retirer la comparaison aux références de `test_enveloppe_spread.R:216-230`** (sous-ensemble de la reproductibilité) : environ 90 s, risque nul, sauf la perte d'un message ciblé.
2. **Retirer l'assertion (c) de `test_incertitude_bootstrap.R`** (l. 216-230) et passer (b) et (d) sur les références ou sur le cache : environ 100 s, risque faible (moyen pour (a), en partie couvert ailleurs).
3. **Cache commun des six cas (option B)** pour `test_detail_deux_phrases` A2, `test_merz_wuthrich_suite` `res300`, et J1 à B = 999 dans `test_constante_ponderee` / `test_enveloppe_qq` : environ 150 s, risque faible ; à préférer à l'option A, qui contredit l'intention de A2.
4. **Couper `test_application.R` et `test_p_mc_regime.R` en deux fichiers** : 0 s cumulé, mais c'est la seule piste qui fait baisser la durée réelle sous environ 280 s par lot. Risque nul.
5. **Mise en mémoire par fichier des résultats lus seulement** (`appels_run` dans `test_defauts_connus`, `run_mw()` dans les deux fichiers Merz-Wüthrich) : environ 40 à 70 s, risque faible si l'on garde hors cache les blocs qui touchent au générateur, aux avertissements ou aux substitutions.
6. **Candidats non vérifiés** de `test_controles_entree` et `test_rapport_html` : environ 65 s, risque à évaluer cas par cas.
7. **Regrouper les copies mutantes du `.tex`** dans `test_concordance_doc_moteur.R` : environ 30 à 40 s, risque moyen (masquage entre injections).
8. **Cache de R (`setup-r`)** : environ 30 à 60 s de durée réelle par lot, risque élevé (plateforme des références, M34) ; décision du mainteneur.

**À écarter :** retirer l'étape `--strict` ou ses processus fils (piste 1), réduire B, partager des résultats entre jobs. Aucune proposition ne touche à la régénération des références (CI seule), à la concordance `--strict` dans la CI, aux contrôles ND ni à `engine_sous_graine()`.

## Vérifications exécutées

- Lecture de l'issue #561, de `ci.yml`, de `blas-reference/action.yml`, de `test_unitaires.R` (lots, mode parallèle), d'`outils_tests.R` (`CAS`, `neutraliser_instables`), de `test_reproductibilite.R` et des sections citées des fichiers longs.
- Traçage des 55 fichiers (4 en parallèle, `LC_ALL=C.UTF-8`) : terminé, 3 745 assertions.
- Temps de `run_engine` sans traçage : chiffres plus haut.
- `concordance_doc_moteur.R --strict` : 33 s en local.
- Recherche statique des intitulés `verifier()` en double : aucun.
- Les batteries complètes n'ont pas été relancées hors traçage : pas de modification à valider.

## Questions pour `actuary`

Aucune : rien ne touche à la pertinence statistique.

Le choix entre l'option A (lire les références) et l'option B (cache commun) est une décision de reproductibilité, qui revient au mainteneur. La note de l. 187-189 de `test_detail_deux_phrases.R` va contre l'option A.

## Statut

**termine** : inventaire sans constat de défaut du code. Aucun critère d'escalade du routage n'est atteint (ni échec documenté, ni désaccord entre agents). Les recommandations ne sont pas des retraits ; ceux-ci viendront après la remise, comme décidé.
