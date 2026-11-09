# Rapport de l'agent `audit` : évaluation de la durée de la CI (08/11/2026)

> *Rapport rendu par l'agent `audit` (IA) à la session principale le 08/11/2026, branche K1 (PR #511), étape 0b ; reproduit intégralement, mise en forme Markdown seule. Les chemins `/tmp/duree-ci/` renvoient aux sorties de l'agent ; celles qui sont versées sont dans `mesures/`, à côté du présent fichier.*

## Retour — évaluation de la durée de la CI (branche K1, PR #511), en lecture seule

**Statut** : évaluation terminée. Je n'ai rien modifié dans le dépôt. `git status` est propre. La tête est passée de `63b0319` à `973211d` pendant mon travail (commit `docs:` de la session principale, sans effet sur `R/`, `tests/` et `.github/`, vérifié par `git diff --quiet`). Toutes mes sorties sont dans `/tmp/duree-ci/`.

**Conditions de mesure** : conteneur à 4 vrais cœurs (`lscpu` : 1 thread par cœur), R 4.3.3, BLAS de référence, `LC_ALL=C.UTF-8`, shiny et plotly absents. La mesure séquentielle a tourné pendant mes profils, avec une charge de 1 à 2,5 : ses durées peuvent être gonflées de 0 à 10 %. Les mesures parallèles et les chronos répétés ont tourné seuls (charge de départ entre 0,4 et 1).

**Conclusion** : le levier principal est l'orchestration. Répartir les tests unitaires sur 2 ou 3 jobs (matrice) et sortir reproductibilité et concordance dans un job parallèle ramènerait le job critique d'environ 16,5 min à environ 6 à 8 min (estimé). Trois optimisations du moteur gardent des résultats **identiques au bit près** sur les six cas : elles réduisent de 10 % la somme des durées des tests unitaires (mesuré).

### 1. Durées par fichier

Sources : les durées séquentielles sont *mesurées* ici, un `Rscript` par fichier. Les durées CI sont *mesurées* dans le journal du run 1152 (`gh run view 42499334385 --log`), sous 4 processus. Le runner affiche `Cœurs du runner : 4`.

| fichier | séq. local (s) | CI, 4 proc. (s) | rang de lancement actuel (taille) |
|---|---|---|---|
| test_merz_wuthrich | 264.9 | **390.3** | 1 |
| test_p_mc_regime | 131.0 | 195.9 | 15 |
| test_application | 1.3 (shiny absent, bloc sauté) | 195.2 | 7 |
| test_controles_entree | 124.9 | 193.6 | 3 |
| test_concordance_doc_moteur | 123.2 | 189.9 | 5 |
| test_defauts_connus | 111.6 | 168.8 | 6 |
| test_incertitude_bootstrap | 78.9 | 125.4 | 26 |
| test_enveloppe_spread | 78.5 | 123.8 | 28 |
| test_rapport_html | 64.3 | 100.5 | 2 |
| test_outillage_mesure | 75.1 | 100.0 | 12 |
| test_forme_close_m1 | 59.7 | 89.6 | 17 |
| test_origine_non_identifiable | 63.2 | 88.3 | 34 |
| test_retirage_mw | 60.4 | 85.1 | 32 |
| test_plancher_mc | 59.7 | 83.5 | 19 |
| test_calibration | 49.9 | 76.4 | 9 |
| test_anti_bruit | 48.9 | 52.1 | 45 (fini en dernier en CI) |
| les 34 autres | entre 0.4 et 36 | entre 0.6 et 57 | |
| **somme** | **1823** | **2900** | |

Tableau complet : `/tmp/duree-ci/tableau_durees.tsv`.

- **Coût du parallélisme** :
  - En CI, la somme sous 4 processus vaut 2900 s, contre environ 1950 s en séquentiel (référence de `ci.yml`, run du 05/11), soit un ralentissement de 1,5 par fichier.
  - En local, ce ralentissement est absent : somme de 1841 s en parallèle contre 1823 s en séquentiel.
  - *Hypothèse* : les 4 vCPU du runner sont 2 cœurs physiques en hyperthreading. Dépasser 4 processus n'apporterait rien.
- **Temps mural attendu** (simulation à partir des durées CI) :
  - 4 processus dans l'ordre actuel (taille des fichiers) : 748 s. C'est la valeur relevée en CI (747,5 s).
  - Ordonnancement LPT (plus longs d'abord) : 725 s, qui est aussi la borne somme/4.
  - À 8 processus (2 jobs), le temps est borné par test_merz_wuthrich : 390 s.
- **Le fichier le plus long ne borne pas le total aujourd'hui** (390 s contre 725 s) ; c'est la somme qui le borne. Il devient la borne dès qu'on répartit sur 2 jobs ou plus : le couper en deux donne 363 s pour 2 jobs et 245 s pour 3 jobs.
- **Reproductibilité, par cas** (mesurée) :
  - En CI, deux appels par cas : premium 18 s, reserve1 16, reserve2 34, premium_ii6 16, premium_net 16, premium_interieur 28, soit 128 s.
  - En local, au repos : 147 s.
  - Un seul `run_engine()` en local : premium 9,3 s, reserve1 10,0, reserve2 20,6, premium_ii6 8,3, premium_net 8,9, premium_interieur 15,3.
  - Les 3 autres cœurs restent inactifs pendant cette étape.
- **Chronologie du job en CI** : setup-r 39 s, paquets 42 s, BLAS 5 s, tests unitaires 748 s, reproductibilité 128 s, concordance 26 s, soit 992 s au total.

### 2. Fonctions chaudes

Mesuré avec Rprof, en pourcentage du temps total de l'appel.

- **premium** (10,5 s) :
  - `usp_bootstrap` 57 %, dont `.mc_evaluer`/`.stats_bootstrapables` (statistiques par réplication) 40 % ;
  - `usp_ajuster_rapide` → `optim` 35 % ;
  - `usp_lr_delta` 28 % ;
  - `usp_noyau` 21,6 % au total (10,7 % en propre) ;
  - `usp_gradient` 14,5 % ;
  - compilation JIT (`cmpfun`) 11,9 %.
- **reserve1** (8,6 s) : même profil (`usp_noyau` 22 %, `optim` 36 %, `usp_lr_delta` 32 %).
- **premium_interieur** (16,3 s) : `usp_bootstrap` 82 %, flux complémentaire compris ; `usp_ajuster_rapide` 42 %.
- **reserve2** (18,8 s) :
  - `mw_bootstrap` 98 %, dont `.mc_evaluer` 93 % ;
  - `mw_test_ordonnee_origine` 25 % (`stats::lm` + `summary.lm` 15 %) ;
  - `mw_test_courbure` 20 % ;
  - `engine_aplatir_ex_aequo` 16 % ;
  - `mw_test_cellule_aberrante` 10 %.
- **Coût par statistique et par réplication** (`/tmp/duree-ci/cout_catalogue.log`) :
  - Merz-Wüthrich (MW) : Origine 4,5 ms, MinP4 3,6, Courbure 3,2, ExpVar 1,8, HomogF 1,5, soit 18,9 ms et 18,8 s pour B = 999.
  - Lognormale : 2,9 ms au total (Smirnov 0,28, RESET 0,27, BF 0,24).
- **Dans test_merz_wuthrich** (272 s échantillonnées) : `mw_bootstrap` 79 %, construction de `data.frame()` 24 s (9 %), `deparse` 21,5 s (8 % ; `deparse1` de `cor.test`/`shapiro.test`), `sw_loi_nulle` 25,5 s (9 %), `pspearman` 14 s, `lm` 33 s.
- **Coût intrinsèque** : les B réajustements (`optim`, trois démarrages par réplication), les statistiques par réplication, le bootstrap restreint de `usp_lr_delta` (2B réajustements), et `sw_loi_nulle` (1,7 s par n distinct et par processus, 20 000 `shapiro.test`).
- **Répétitions évitables** :
  1. Le noyau est calculé deux fois par point d'`optim`, une fois par `fn` et une fois par `gr`.
  2. Des `data.frame()` vides sont reconstruits à chaque réplication.
  3. La formule de `lm` et le `summary` sont refaits à chaque colonne de chaque réplication.
  4. La compilation JIT est refaite dans chaque processus, 3 à 5 s par fichier d'après les profils. Les fonctions du moteur vivent hors de l'environnement global : R ne les compile qu'au second passage, et jamais les petites (`usp_pi`).
  5. `sw_loi_nulle` est recalculée dans chaque processus.
  6. test_incertitude_bootstrap recalcule les six cas de référence (125 s en CI), déjà calculés deux fois par test_reproductibilite.
  7. Le chargement du moteur ne coûte presque rien : `charger_moteur()` prend 0,03 s.

### 3. Propositions, classées par gain sur le chemin critique

| # | type | proposition | gain | risque |
|---|---|---|---|---|
| A1 | (a) | Matrice de 2 ou 3 jobs de tests unitaires, répartis par LPT sur les durées CI, et test_merz_wuthrich coupé en deux. Shiny et plotly seulement dans le job qui contient test_application, test_rapport_html, test_enveloppe_spread et test_incertitude_bootstrap. `.github/workflows/ci.yml:85-185`, `tests/test_unitaires.R:100-180` (option de sélection de fichiers). | estimé de −500 à −650 s : job critique d'environ 86 s de préparation + 363 s (2 jobs) ou 245 s (3 jobs), au lieu de 992 s | faible à moyen : plus de minutes de runner, chaque job s'expose à un setup-r lent (14 min le 04/11 selon `ci.yml`), bilan réparti entre jobs |
| A2 | (a) | Reproductibilité, concordance et résumé des écarts (#66) dans un job parallèle. `ci.yml:~186-200` | estimé −154 s (128 + 26) | faible |
| A3 | (a) | À défaut de A2 : six cas × deux appels en processus séparés (4 à la fois) dans `tests/test_reproductibilite.R:26-55`. Le contrôle `identical()` reste un contrôle sur une même machine. | estimé de −75 à −85 s : reste environ 34 s × 1,5 | faible |
| C1 | (c) | Mémoïsation du dernier `usp_noyau()` dans `usp_ajuster_rapide` (`R/engine.R:5143`). Donner à `usp_gradient` (`:1311`) un argument noyau facultatif plutôt que dupliquer la formule comme dans mon essai. | mesuré : premium de 8,88 à 7,72 s en médiane sur 3 essais (−13 %) | faible : `identical()` vrai sur les 5 cas lognormaux. Noms cités dans le `.tex` (`usp_gradient_optim`) : surface documentaire à vérifier |
| C3 | (c) | `mw_test_ordonnee_origine` (`R/engine.R:10644`) : `stats::lm.wfit` plus transcription de `summary.lm` au lieu de `lm(C1 ~ C0, weights = 1/C0)` et `.mw_summary_lm` | mesuré : reserve2 de 18,6 à 15,7 s (−15 %) | faible à moyen : `identical()` vrai sur reserve2, et sur 3000 cas différentiels (fit parfait, C0 constant, ex aequo, échelle 1e8). Comportement différent seulement avec des NA ou sur un avertissement de `summary.lm`, ce qui suppose des cumuls non positifs, exclus par `.mw_tirer_triangle_valide` |
| C4 | (c) | `data.frame` vide constant pour `.mw_exclues_vide` (`:10481`) et `.mw_table_non_identifiables` (`:10600`) ; même idée pour `vide_nb` dans `mw_test_cellule_aberrante` (`:13231`) | mesuré : reserve2 de 18,6 à 17,7 s. Avec C3 : 14,2 s (−23 %) | très faible : objets identiques, R copie à l'écriture |
| C1+C3+C4 | (c) | Les trois appliqués à une copie du dépôt (`/tmp/duree-ci/copie`) | mesuré : tests unitaires `--parallele` de 490 à 442 s, somme de 1841 à 1659 s (−10 %), 0 échec ; reproductibilité de 147 à 130 s. En CI, estimé −70 s sur les tests et −15 s sur la reproductibilité | `identical()` vrai sur les **six cas**, et 0 feuille non strictement identique aux références. Une assertion de moins (test_affichage_regime_t8, contrôle « grille suivie du dépôt »), due à l'absence de git dans la copie et non au moteur |
| A4 | (a) | `actions/cache` des paquets shiny et plotly, clé = instantané Posit Package Manager + version de R (`ci.yml:~120`) | estimé −35 s sur 42 | faible |
| A5 | (a) | LPT sur une table de durées mesurées au lieu de la taille des fichiers (`tests/test_unitaires.R:105`) | calculé −23 s (de 748 à 725) | très faible |
| B1 | (b) | Partager les six cas de référence entre test_reproductibilite et test_incertitude_bootstrap (fichier temporaire du job) | estimé −30 s mural (125 s CPU) | moyen : couplage entre étapes ; touche l'indépendance des tests, à trancher par le mainteneur |
| J1 | (c), orchestration de test | Lanceur qui charge le moteur, le précompile et fait un fork par fichier au lieu d'un `Rscript` neuf | mesuré : environ −5 % (1197 → 1136 s sur 34 fichiers compatibles) ; 16 fichiers incompatibles (chemin `--file`, sous-processus) | moyen ; **non recommandé** maintenant. `R_JIT_STRATEGY=3` : `identical()` vrai, gain non reproductible (71,3 contre 72,4 s) |
| exclus | (c) | Remplacer `cor.test` ou `shapiro.test` par les routines C internes (`stats:::C_pRho`, `C_SWilk`) | `deparse` fait 8 % de MW | API non exportée. Une loi de Spearman énumérée changerait la source de la p-value, donc un résultat possible |

Dans les trois cas (c) retenus, aucun tirage aléatoire ne change d'ordre de consommation.

### 4. Garde-fous exécutés

- `identical()` entre le moteur de référence et les variantes, sur les résultats nettoyés de `executer_cas` (`/tmp/duree-ci/comparer_identiques.R`). Vrai pour :
  - memo : 5 cas lognormaux ;
  - objectif léger : 5 cas lognormaux ;
  - wls : reserve2 ;
  - wls + df vides : reserve2 ;
  - jit3 : 6 cas ;
  - copie C1+C3+C4 : **6 cas**.
- `tests/test_reproductibilite.R` dans la copie modifiée : OK, 0 non strictement identique.
- `tests/test_unitaires.R --parallele` dans la copie modifiée : 3213 assertions, 0 échec.
- Dans le dépôt réel, référence : test_unitaires `--parallele` OK (3214 assertions, 489,7 s) ; test_reproductibilite OK.
- Je n'ai pas lancé `tests/concordance_doc_moteur.R --strict` sur la copie modifiée. Je l'ai lancé une fois dans le dépôt réel, sous profilage : 0 écart, 28,9 s.

### 5. Questions pour `actuary`

1. Peut-on réduire B dans les tests unitaires qui appellent `run_engine()` ou le bootstrap avec B = 999 sans que l'assertion l'exige ? Exemples : `test_merz_wuthrich.R:2589` (reserve2 à B = 999, environ 17 s), `test_enveloppe_spread.R:150`, test_incertitude_bootstrap (six cas au B par défaut, 125 s en CI). Je ne le recommande pas : je le signale.
2. Le tirage de `sw_loi_nulle` (B_null = 20 000) pourrait-il être partagé entre processus par un cache sur disque, sans changer la loi ? C'est aussi une question d'architecture pour le mainteneur (entrée-sortie dans le moteur).

Pour le mainteneur (couverture, pas `actuary`) : B1, et toute idée de ne garder le double appel `identical()` que sur une partie des cas. A3 conserve ce contrôle intégral.

### 6. Issues proposées (non créées)

1. **« CI : répartir les tests du moteur sur plusieurs jobs et sortir reproductibilité et concordance dans un job parallèle »**, libellé `needs-triage`. Corps : chemin critique mesuré de 992 s (run 1152) ; matrice de 2 ou 3 jobs répartis par LPT sur les durées CI ; test_merz_wuthrich coupé en deux ; shiny seulement où il sert ; reproductibilité, concordance et #66 dans un job dédié ; gain estimé de 8 à 10 min ; risque : setup-r lent multiplié par le nombre de jobs.
2. **« moteur : accélérer usp_ajuster_rapide et mw_test_ordonnee_origine sans changer de résultat »**, libellé `needs-triage`. Corps : C1, C3, C4 ; −10 % sur la somme des tests unitaires (mesuré) ; `identical()` vrai sur les six cas ; circuit 3 avec `audit` ; surface documentaire (fonctions citées dans le `.tex`) ; `coder-approfondi` puisque le contrat de reproductibilité est en jeu.
3. **« tests : paralléliser test_reproductibilite.R et ordonner --parallele par durées mesurées »**, libellé `needs-triage`. Corps : A3 et A5, environ −100 s, sans changer ce qui est vérifié.
4. **« CI : mettre en cache les paquets shiny et plotly de l'instantané épinglé »**, libellé `needs-triage`. Corps : A4, environ −35 s.

### 7. Sorties dans `/tmp/duree-ci/`

- **Durées** : `durees_seq.tsv`, `durees_ci_1152.tsv`, `tableau_durees.tsv`, `ci_1152.log`, `par_actuel.tsv`, `par_copie.tsv`, `parallele_actuel.log`, `copie_parallele.log`, `repro_base2.log`, `copie_repro2.log`.
- **Simulations d'ordonnancement** : `ordonnancement.R`, `sharding.R`.
- **Profils** : `rprof_*.out`, `profil_cas.log`, `resume_prof.R`, `rprofile_prof.R`, `cout_catalogue.log`.
- **Patchs** : `patch_noyau_memo.R`, `patch_objectif_leger.R`, `patch_mw_wls.R`, `patch_df_vides.R`.
- **Contrôles et chronos** : `cas_identiques.R`, `comparer_identiques.R`, `chrono_patch.log`, `diff_wls.R`, `res_*.rds`.
- **JIT et prototype de fork** : `essai_jit.R`, `trace_jit.R`, `lanceur_fork.R`, `fork_precomp.tsv`.
- **Copie modifiée du dépôt** : `copie/`, obtenue par `git archive`, avec C1, C3 et C4 appliqués.

**Critères de routage rencontrés** : aucun.
