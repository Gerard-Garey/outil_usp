---
status: accepted
date: 2026-09-21
---

# Toute simulation s'exécute sous graine locale et restaure l'état du générateur ; aucun aléa hors calcul

## Contexte

Le moteur tire des nombres aléatoires en quatre endroits, avec quatre conventions incompatibles sur `.Random.seed` : `usp_bootstrap()` et `mw_bootstrap()` posent la graine reçue de `run_engine()` sans restaurer l'état ; `sw_loi_nulle()` pose une graine propre (20260901), met en cache et restaure l'état seulement s'il existait ; `engine_plots_data()` pose une graine fixe (20260831) sans restaurer ; `engine_lire_xlsx()` / `engine_ecrire_xlsx()` tirent un `runif()` sans graine pour nommer un dossier temporaire. La sous-section « Reproductibilité et gestion des graines » de la documentation décrit un seul de ces quatre cas (issue #1). Effets concrets (issue #4, piste 2) : l'état du générateur de l'appelant est écrasé par `run_engine()` ; le « nom aléatoire » du dossier xlsx est le même après chaque calcul, les dossiers ne sont jamais supprimés, et dans le repli sans `openxlsx` un `sharedStrings.xml` résiduel peut produire des libellés faux. La reproductibilité au bit près n'est pas en cause aujourd'hui, mais elle ne tient que parce que l'ordre des appels dans `run_engine()` est figé : toute nouvelle simulation (bootstrap restreint sous H0, issue #5) décalerait les flux existants si elle prenait place dans le même flux.

## Décision

1. **Une fonction unique** du moteur exécute une expression sous graine locale : elle sauvegarde `.Random.seed` de l'environnement global (ou note son absence), pose la graine, évalue, puis restaure l'état initial (ou retire `.Random.seed` s'il n'existait pas), y compris en cas d'erreur.
2. **Toute simulation passe par elle** : `usp_bootstrap()` et `mw_bootstrap()` (graine `seed` de `run_engine()`), `sw_loi_nulle()` (graine propre 20260901, cache conservé), `engine_plots_data()` (graine fixe actuelle, jusqu'à ce que l'enveloppe soit construite à partir des réplications du bootstrap, issue #5 chantier 6), et toute simulation future, avec une graine explicite qui lui est propre et qui figure dans `metadata`.
3. **Propriété garantie et testée** : `run_engine()` laisse l'état du générateur de l'appelant intact ; deux appels à paramètres égaux restent identiques au bit près quel que soit l'état du générateur avant l'appel.
4. **Aucun aléa hors calcul** : les fichiers et dossiers temporaires viennent de `tempfile()` et sont supprimés par `on.exit(unlink(…, recursive = TRUE))`.
5. La sous-section « Reproductibilité et gestion des graines » de la documentation est réécrite à partir de l'état final du code, avec la liste exhaustive des fonctions qui tirent, leur graine, leur portée et la restauration (issue #1) ; elle suit le code, jamais l'inverse.

## Considered Options

- **Une graine unique dérivée pour tout `run_engine()`** (un seul `set.seed()` en tête, chaque simulation consommant le flux à la suite) : écarté ; toute simulation ajoutée ou déplacée changerait toutes les p_mc, et `sw_loi_nulle()` (loi nulle indépendante du modèle, mise en cache) n'a aucune raison de dépendre de la graine du calcul.
- **Laisser chaque fonction gérer sa graine et documenter les quatre conventions** : écarté ; la documentation décrirait une fragilité au lieu d'une garantie, et l'état de l'appelant resterait écrasé.

## Conséquences

Résultats strictement inchangés : mêmes graines, mêmes flux à l'intérieur de chaque simulation ; critère d'acceptation : `tests/test_reproductibilite.R` vert sans régénération. Les deux échecs attendus « état du générateur » de `tests/unitaires/test_defauts_connus.R` deviennent des tests ordinaires. Une simulation ajoutée ensuite (bootstrap restreint, enveloppe du QQ-plot) n'affecte aucune p-value existante. `CLAUDE.md` (« Reproductibilité ») et la documentation LaTeX décrivent la règle unique au lieu des quatre cas. Issues : #1, #4 (piste 2), #5 (chantiers 2 et 6) ; feuille de route, jalon J2.

## Annotation du 25 septembre 2026 — mise en œuvre par #42 et #37 (branche D) ; le générateur est fixé, le réglage de l'appelant restauré

**Point 1 et 2, réalisés par #42** (commit `23e6d4a`) : la fonction unique est `engine_sous_graine(seed, expr)` ; les quatre sources y passent avec leurs graines d'avant (`usp_bootstrap()` et `mw_bootstrap()` : `seed` ; `sw_loi_nulle()` : `SEED_LOI_NULLE_SW` = 20260901, cache conservé ; `engine_plots_data()` : `SEED_ENVELOPPE_QQ` = 20260831) ; les fichiers xlsx viennent de `tempfile()` (point 4). Critère du dernier paragraphe tenu : `tests/test_reproductibilite.R` vert sans régénération ; les deux échecs attendus « état du générateur » sont devenus des tests ordinaires.

**Point 2, complété par #37** (commit `642de59`, décision du mainteneur du 25/09/2026 sur la réserve d'`audit`) : les graines fixes « figurent dans `metadata` » depuis #37 et non depuis #42 — `$metadata$seed_loi_nulle_sw` (trois méthodes) et `$metadata$seed_enveloppe_qq` (méthodes lognormales), à côté de `seed` ; `B_null` = 20 000 et les 499 échantillons de l'enveloppe restent des constantes du code. Ce champ étant numérique, le patch chirurgical le refuse : régénération des cinq cas sur la CI (`36157180625`), aucune feuille modifiée.

**Extension de la décision, hors du texte de 2026-09-21** : la fonction unique **fixe le générateur** — `ENGINE_RNG_KIND` (Mersenne-Twister, Inversion, Rejection) posé avec la graine quel que soit le `RNGkind()` de l'appelant — et **restaure le réglage de l'appelant** (`RNGkind()` puis `.Random.seed`, ou son absence) en sortie, erreur comprise. Le point 3 se lit donc : « quel que soit l'état **et le type** de générateur avant l'appel », propriété mesurée sous L'Ecuyer-CMRG, `sample.kind = "Rounding"` et Box-Muller ; la clé du cache de `sw_loi_nulle()` (`sw_cle_cache()`) porte le générateur, et `$metadata$generateur` consigne celui qui a été posé (lecture de `coder` retenue par le mainteneur le 25/09/2026). Limite dite, sans effet sur le moteur : la réserve normale de Box-Muller, gardée par R hors `.Random.seed`, n'est pas restaurable.

**Point 5** : sous-section « Reproductibilité et gestion des graines » réécrite par `docwriter` (`da4d75e`, `0a06cfd`) ; `CONTEXT.md`, « Graine locale » et « Reproductibilité à graine égale », alignés (`a875a72`). Issues : #42, #37, #1 (close), #4 piste 2 ; feuille de route, fiche D et § 4 (ligne D-25/09).

---

## Annotation du 7 octobre 2026 — cinquième source de tirage : les permutations aléatoires du test de Pitman (#169, branche E1f)

**Origine.** Décision du mainteneur du 07/10/2026 (commentaire de la PR #211, « Décisions du mainteneur (07/10/2026) », qui autorise l'annotation) ; décision Q-D de #169 du 06/10/2026 ; ADR 0003, annotation du 6 octobre 2026. `CLAUDE.md`, « Reproductibilité », aligné par le commit `03f1f0f`.

**État des sources avant #169.** Quatre sources passent par `engine_sous_graine()` : `usp_bootstrap()` et `mw_bootstrap()` (graine `seed`), `sw_loi_nulle()` (`SEED_LOI_NULLE_SW` = 20260901) et `usp_lr_delta()` (graine `seed`, une pose par borne de δ, #45) ; `engine_plots_data()` ne tire plus depuis #47 (enveloppe du QQ-plot lue dans `bootstrap$z_boot`, `SEED_ENVELOPPE_QQ` retirée).

**Cinquième source.** `usp_permutation_pente()` (test de Pitman sur la pente, #169, commit `9d88e23`) tire **B permutations uniformes** de 1:T par `sample.int(T)`, sous `engine_sous_graine(seed, …)`, avec la **même graine `seed`** que le bootstrap et le B de l'exécution, transmis par `run_engine()` (`R/engine.R`, appel de `usp_permutation_pente(xt, yt, B = B, seed = seed, …)` avant `usp_tests()`) ; p = (1 + k)/(B + 1). Elle ne tire qu'à **T > `T_MAX_ENUM_PERMUTATION`** (= 9, comme `n_small` de `prho.c`) : en deçà, les T! appariements sont **énumérés** par `engine_permutations()` (matrice mise en cache, sans aléa). La graine étant posée localement, ce tirage ne décale aucun flux existant : le bootstrap principal, `usp_lr_delta()` et la loi nulle de Shapiro-Wilk sont inchangés (point 2 ; critère du dernier paragraphe de la décision). Un appel direct d'`usp_tests()` sans permutation transmise calcule la permutation aux valeurs par défaut (B = 999, `seed` = 20260831).

**Consignation dans `metadata` (point 2).** `res$metadata$permutation_pente`, liste à trois champs : `methode` (« enumeration », « aleatoire » ou « non calcule » — volumes constants, R13, ou pertes constantes, #189, où la ligne est non applicable), `B` (B de l'exécution à T > 9, `NA` sinon) et `p_bilateral` (p de permutation bilatérale, pour information, jamais retenue ; gardée à toute T, décision du 07/10/2026). La graine n'y est pas répétée : c'est `metadata$seed`, déjà consigné. Limite dite dans le code : sous R12 ou t non fini, la permutation est calculée mais la ligne est non applicable ; `metadata$permutation_pente` décrit alors un calcul non utilisé.

**Conséquences.** Aux valeurs des cas de test (T = 8), aucun tirage n'a lieu : les références ne dépendent pas de cette source. Le point 3 (état et type du générateur de l'appelant restaurés) couvre la nouvelle source sans code supplémentaire. `CONTEXT.md`, « Graine locale », porte la cinquième source depuis le 06/10/2026. La sous-section « Reproductibilité et gestion des graines » du `.tex` (point 5) ne la cite pas encore à la date de cette annotation : surface d'impact documentaire de #169, au passage unique de `docwriter` (règle 9) ; le `.tex` y appelle aujourd'hui « cinquième source » l'ancienne enveloppe du QQ-plot (avant #47), formulation à reprendre pour éviter la confusion. Issues : #169, #45 (précédent de la graine `seed` partagée), #47.
