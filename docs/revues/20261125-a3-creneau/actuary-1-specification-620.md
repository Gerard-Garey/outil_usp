# A3, étape 2 : spécification et protocole de l'issue #620 (famille α, colonne J−1 dégénérée d'un trapèze)

*Rédigé par l'agent `actuary-approfondi` (IA), le 25/11/2026.* La session doit verser ce texte tel quel dans `docs/revues/20261125-a3-creneau/` avant toute mesure.

**Recommandation.** Si la mesure valide les contrôles d'admissibilité de la piste (b), la retenir : la colonne J−1 dégénérée est alors simulée par l'estimateur direct, qui est nul. Sinon, (a), puis (c). Sur le domaine de l'issue, (a) et (b) donnent la même p d'Alpha, la même p de famille M1 et la même p globale. La mesure ne départage donc pas les deux pistes sur Alpha. Elle décide en revanche si (b) est admissible (§ 2). Le reste du choix est un jugement de doctrine, à approuver à PA-1.

> **État consulté.** Lecture seule sur `claude/creneau-a3`, tête `14d36b0`. md5 de `R/engine.R` : `723277ddfa5736d7411838d15d8dad00`, identique à `main` `c105f62`. Rien n'est écrit dans le dépôt.
>
> **Lu** :
> - la fiche A3 (`docs/feuille-de-route.md` l. 4638-4724) ;
> - #620 et ses deux commentaires ;
> - `docs/revues/20261125-js2-jalon/actuary-1-protocole-617.md`, `actuary-2-lecture-617.md`, `mesure-617/mesure_617.R` ;
> - l'ADR 0005 (annotation du 25/11 et sa note) ;
> - `docs/revues/20261123-a2-creneau/actuary-1-protocole-612.md` l. 80-100 et `actuary-6-textes-v2.md` (motif du cas dégénéré dans V2) ;
> - dans `R/engine.R` : `mw_famille_alpha()` l. 15872, `MW_CATALOGUE_MC` l. 16616 (Alpha l. 16690), `.mw_contexte_mc()` l. 16556, `.mw_ensembles_figes()` l. 15766, `.mw_simulation_sigma_direct()` l. 13861, `.mw_cas_sigma_direct()` l. 13872, `.mw_colonne_degeneree()` l. 13611, `mw_bootstrap()` l. 16383, `.mw_simuler_triangle_etat()` l. 16202, `.MW_LIGNES_COLONNES_ECARTEES_HORS_RESIDUS` l. 14158, l'avertissement l. 14350-14373, `engine_p_mc()` l. 4746, `engine_p_famille()` l. 5643, `.engine_minp_rangs()`, `add()` (l. 5217-5220 et verdicts l. 5485), la restitution l. 18457 ;
> - `plot_mw_alpha()` (`R/display_helpers.R` l. 2602) ;
> - dans `docs/latex/doc_tests_usp.tex` : `sec:boot-mw` l. 6535-6600, `sec:mwm1` (1)-(3) l. 16373-16450, la fiche `mw:m1d` l. 17212-17376 ;
> - `docs/latex/CONVENTIONS.md` l. 64 et `tests/controle_doc_nd.R` l. 25-60 et 137 ;
> - l'ADR 0018, critères E1 à E6.
>
> **Exécuté** (sonde en lecture seule par `charger_moteur()`, `LC_ALL=C.UTF-8`, scripts dans le scratchpad, aucune p-value lue) :
> - les préconditions des triangles du § 3 ;
> - l'admission du triangle KA par `run_engine()` à B = 99 : seul `ok` a été lu ;
> - le décompte des caractères de `mw:m1d` et des textes proposés.
>
> **Légende** : [V] vérifié (code relu à la ligne citée, ou commande exécutée) ; [H] hypothèse ; [NV] non vérifié.

## 1. Les pistes (i)

### 1.0 Socle commun [V]

**Statistique.** A = Σ n_j a_j / Σ n_j, sur les colonnes à n_j ≥ 3, avec a_j ≥ 0 (l. 15872-15889). Dans le cas de l'issue :
- l'amplitude de J−1 vaut 0 exactement à l'observé (rapports 22/25 et 18/22, écart 0, lecture 2c de #617) ;
- elle est positive dans chaque réplication, la colonne étant tirée avec la règle (l. 16416-16417, 16215-16219).

D'où p_moteur ≥ p_sans. La propriété est exacte.

**Les douze autres clés et le vivier** écartent `figes$degeneres` dans chaque réplication : code relu, et contrôle D4 de #617 (999/999 identiques).

**p de famille et p globale.**
- Elles sont calculées par `engine_p_famille()` sur les rangs des colonnes de `stats_boot`, l'observé compris (minP en une étape, `.engine_minp_rangs()`).
- Changer la colonne Alpha change ses rangs pour tous les items, l'observé et chaque réplication.
- Aucune propriété exacte ne donne donc le sens de l'effet sur ces deux p [V, lecture]. C'est la réserve du commentaire du mainteneur du 25/11.

**Point structurant, déduit de la lecture.** Sur le domaine de l'issue, (a) et (b) rangent les réplications dans le même ordre :
- sous (a), la colonne Alpha de `stats_boot` vaut A^sans* ;
- sous (b), elle vaut (Σ'n/Σn)·A^sans* + O(10⁻¹⁶), ce qui donne les mêmes rangs aux égalités de tolérance près, puisque le vivier et les tirages des autres colonnes sont inchangés.

La p d'Alpha, la p de famille M1 et la p globale doivent donc être égales sous (a) et (b) (prédiction H3, § 3.6). Ce qui distingue les deux pistes n'est pas Alpha.

### 1.1 Piste (a) : Alpha reçoit l'ensemble figé

**Forme.**
- Signature `mw_famille_alpha(aj, j_degeneres = NULL)` : `jd <- .mw_j_exclues(aj, j_degeneres)`, et la colonne est sautée si `j %in% jd`. Le reste du corps est inchangé.
- Entrée du catalogue : `function(e) mw_famille_alpha(e$aj, e$figes$degeneres)$stat`.
- `mw_tests()` et la restitution (l. 18457) appellent la fonction sur `aj` observé. NULL y donne `.mw_colonnes_degenerees(aj)`, égal à `figes$degeneres` (même `aj`, même prédicat, `.mw_ensembles_figes()` l. 15766).

**Domaine d'effet exact.** Tout triangle qui a une colonne dégénérée à n_j ≥ 3 facteurs, carré compris :
- la valeur restituée de A change, multipliée par Σn/Σ'n quand l'amplitude observée vaut 0 exactement ;
- `plots_data$alpha` perd les lignes écartées ;
- la p MC change :
  - pour J−1 d'un trapèze I ≥ J + 2 à règle non négligeable : jusqu'à p_sans ;
  - pour j ≤ J−2 : seulement aux égalités de tolérance près (constat de #617 sur T0).
- Le texte de l'avertissement des colonnes dégénérées change sur **tout** triangle qui le porte, n_j = 2 compris : la liste est statique.

**Contrat partagé.** Selon `docs/agents/routage.md`, § 4.2, il porte sur :
- la signature, les trois appelants, l'entrée Alpha de `MW_CATALOGUE_MC` ;
- `.MW_LIGNES_COLONNES_ECARTEES_HORS_RESIDUS$M1`, l'ajout du libellé Alpha ;
- le test de `test_merz_wuthrich.R` qui mesure les lignes lisant `jd` ;
- le contenu de `plots_data$alpha` ;
- la phrase d'exclusion du `detail`, par `.mw_phrase_colonnes_ecartees()` : il faut alors rendre `exclues` et `eligibles`.

Le tout en un seul commit `moteur:`.

**Valeur de A sans colonne restante** (ADR 0001, R1). Triangle KA du § 3 ; admis par `run_engine()` [V].
- **(a-i) recommandée** : A = `NA`. `engine_p_mc()` rend `MOTIF_MC_OBS_NON_FINIE` (l. 4757). `add()` bascule alors la ligne en « non applicable », sans loi ni p retenue (l. 5217-5220), et la première phrase du `detail` est seule.
- **(a-ii) écartée** : un motif propre par `non_definie` de `.mc_entree()`. Il passerait par la branche « autre motif » d'`add()`, dont l'effet sur une ligne sans p non simulée est à établir [NV].
- **(a-iii) écartée** : A = 0. Ce serait une valeur fabriquée (0/0 sur un ensemble vide), contraire à l'ADR 0001.

À trancher à PA-2. Le prototype Va mesure (a-i).

**Doctrine.**
- Cohérente avec `sec:mwm1` (2), « figer l'ensemble compare la même fonction du triangle » : Alpha devient la treizième clé qui lit `figes`.
- Elle renverse le paragraphe « Colonnes dégénérées » de `mw:m1d`.
- `sec:mwm1` (1) ajoute Alpha à la liste des lecteurs de l'ensemble figé.
- `sec:boot-mw` est inchangée. La simulation de J−1 dégénérée par la règle y reste alors en tension avec son propre fondement (constat C5, § 5).

**Nature de la p à T = 8.**
- p de Monte-Carlo d'un bootstrap de résidus semi-paramétrique, plug-in, non exacte ; aucun théorème ne la couvre à T = 8.
- Elle est conditionnelle à la définition de la statistique : ensemble figé à l'observé, argument élémentaire que le `.tex` déclare lui-même « adossé à aucune référence publiée ».
- Δp = 0 est **exact par construction**, et vaut quelle que soit la loi de simulation de la colonne.

### 1.2 Piste (b) : la colonne J−1 dégénérée est simulée par l'estimateur direct

**Forme.**
- `.mw_simulation_sigma_direct <- function(aj) !is.null(aj[["sigma2_Jm1_direct"]])` : tout trapèze est simulé avec son estimateur direct, nul (T1, T2, T3) ou négligeable (T0 : 1,2·10⁻²⁸).
- **Point de mise en œuvre obligatoire** : `.mw_cas_sigma_direct()` lit aujourd'hui ce seam. Sous (b), il rendrait « simulation » pour une colonne dégénérée. Il doit donc lire `.mw_colonne_degeneree()` directement, pour garder le cas « degenere » des textes (l. 13872-13875).
- `FORMAT_MENTION_MW_SIGMA_DIRECT_DEGENERE` (« n'entre ni dans la MSEP ni dans la simulation ») et `MW_USAGE_SIGMA_DEGENERE` (« MSEP et simulation ») deviendraient faux. Ils sont à réécrire : textes d'`actuary` ; `regulatory` en routine, parce qu'ils citent D(5)(d)(ii) ; `app-review` léger.
- Variante (b′), forcer σ = 0 exactement, **écartée** : elle ajoute un cas, et l'estimateur direct est déjà nul ou négligeable dans le cas dégénéré.

**Domaine d'effet exact.** Tout trapèze I > J dont la colonne J−1 est dégénérée, I = J + 1 compris :
- σ_boot, `ic_bootstrap`, `boot_reperes`, `plots_data$sigma_boot`, `plots_data$sigma_usp_boot` ;
- la colonne Alpha de `stats_boot`, et ses p (Alpha, famille M1, globale) seulement si n_{J−1} ≥ 3 et la règle n'est pas négligeable ;
- les textes M6 et `usage_sigma` du cas « degenere ».

Les douze autres clés ne changent pas, à deux conditions [H, testée par Gb2] :
- aucun triangle n'est retiré à la colonne J−1 sous V0 : le flux `sample()` est alors identique ;
- la clé lit la colonne par l'ensemble figé.

Sur T1 et T2, ce retirage est pratiquement exclu. Il faudrait e ≤ −139 (T1) ou e ≤ −62,6 (T2), au plus petit cumul observé, alors que le minimum du vivier vaut −1,58 [V, sonde]. Le carré n'est pas touché : il n'a pas d'estimateur direct.

**Effet sur l'ADR 0005.** Il remplace la clause « Colonne J−1 dégénérée : simulation inchangée (règle) » du point 1 de la Décision de l'annotation du 25/11. `architect` annote **avant** le commit `moteur:`, et l'entrée de `CONTEXT.md` « σ des résidus » est alignée.

Constat de lecture : cette exception est héritée. Dans le protocole de #612 (l. 87-92), le prédicat de V2 est imposé pour « coïncider avec V0 » dans le cas dégénéré, sans mesure dans ce cas. Je n'ai trouvé, dans les pièces d'A2 lues, aucun autre motif propre à ce cas [V, lecture partielle d'A2].

**Doctrine.**
- (b) étend le fondement écrit en `sec:boot-mw` : « Simuler la colonne J−1 avec la variance qui en réduit les résidus observés ». L'argument miroir y figure déjà : une règle « nulle ou négligeable alors que la colonne observée est dispersée » rendrait le triangle observé « de probabilité nulle sous la loi de référence ».
- Sous V0, c'est l'inverse : une colonne observée dégénérée, simulée dispersée, rend le triangle observé de probabilité pratiquement nulle sous la loi bootstrap. (b) supprime cette incohérence.
- (b) supprime aussi la discontinuité au bord du prédicat. Juste au-dessus de la tolérance, la colonne est simulée avec un estimateur direct minuscule ; juste en dessous, avec la règle. Le saut porte sur la p d'Alpha comme sur σ_boot.
- (b) rétablit la prémisse de `sec:mwm1` (2) : le modèle simulé produit ce qui déclenche la sélection.
- (b) rétablit celle de `mw:m1d` : la colonne reste dégénérée. Le paragraphe existant survit, sans la réserve sur J−1.

**Nature de la p.** Même nature que sous (a) : Monte-Carlo, plug-in, non exacte. Δp = 0 à des égalités de l'ordre de la tolérance près, et non exactement. C'est le même statut que la doctrine déjà écrite pour j ≤ J−2.

### 1.3 Piste (c) : statu quo documenté

- Aucun code.
- La phrase du critère 4 dans `mw:m1d` reste due (commentaire du mainteneur du 25/11).
- Fermeture `not planned` à la main, après passage de `Closes #620` en `Refs #620` (PA-2, point 5).
- La p reste majorée, dans le sens conservateur. E2 est retenu par le mainteneur.

### 1.4 Variantes écartées

- **(a′) restreinte à la colonne J−1.** Lecture partielle de l'ensemble figé, nouvelle classe de lecteurs, et texte d'avertissement conditionnel. Sur le domaine de l'issue, elle donne la même p que (a), et ailleurs la même que V0. Rien à mesurer qui puisse décider.
- **(a)+(b).** Deux contrats et un ADR, sans effet de plus sur la p d'Alpha. (b) reste applicable plus tard, indépendamment, s'il faut corriger σ_boot (constat C5).

## 2. Critères de décision, écrits avant toute mesure (ii)

**R0 — validité.** I1 à I9 verts (§ 3.4). Sinon : aucune conclusion ; le script est repris, puis repasse l'audit léger.

**Admissibilité de (b)** : tous les contrôles suivants doivent être verts.
- **Gb1** : p_Alpha(Vb) = p_sans sur T0, T1 et T2. p_sans est recalculée sur le journal de V0, comme `sans()` dans `mesure_617.R`. Toute réplication discordante doit être une quasi-égalité : |A^sans*_b − A^sans_obs| ≤ 10⁻¹² × A^sans_obs, la liste étant imprimée.
- **Gb2** : les douze autres p_mc, leurs verdicts à 0,10 et leurs colonnes de `stats_boot` sont `identical()` entre V0 et Vb sur T0 à T3. Aucun écart n'est toléré, même s'il s'explique par un retirage : un tel écart est hors de la prévision.
- **Gb3** : σ_USP est `identical()` dans tous les triangles. Les objets `res` de `reserve2`, `reserve2_trapeze`, K1 et KA sont `identical()` entre V0 et Vb.
- **Gb4** : sous Vb, sur T1, T2 et T3, la colonne J−1 est dégénérée dans 100 % des réplications (`.mw_colonne_degeneree()`).

**Admissibilité de (a)** : tous les contrôles suivants doivent être verts.
- **Ga1** : p_Alpha(Va) `identical()` à p_sans sur T0, T1 et T2. Sur K1, p_Alpha(Va) = p_V0, aux quasi-égalités près (même règle que Gb1).
- **Ga2** : les douze autres p_mc et leurs colonnes de `stats_boot`, σ_boot, `ic_bootstrap` et σ_USP sont `identical()` entre V0 et Va, sur les huit triangles.
- **Ga3** : les objets `res` de `reserve2`, `reserve2_trapeze` et T3 sont `identical()` entre V0 et Va.
- **Ga4** : sur KA, la ligne Alpha est « non applicable », `p_retenue` vaut `NA`, sans erreur. Le comportement de V0 sur KA est imprimé.

**Règle de choix** (dans cet ordre) :
1. (b) admissible → **recommander (b)**.
2. Sinon, (a) admissible → recommander (a).
3. Sinon → (c), avec la phrase du critère 4.

La grandeur de Δp n'est jamais un critère : E2 est retenu. La grandeur de l'effet de Vb sur σ_boot et l'intervalle n'est pas non plus un critère de choix. Elle est rapportée et soumise au mainteneur avec le tableau.

**Motifs de l'ordre (b) avant (a).** C'est un jugement, que la mesure ne tranche pas (critère signalé, § 7).
- (b) corrige la cause : la loi de simulation, incohérente avec la colonne observée.
- Elle unifie la règle de simulation de tout trapèze et supprime une exception héritée, non mesurée.
- Elle ne touche aucun contrat partagé et n'élargit pas le domaine des textes restitués au-delà des trapèzes à J−1 dégénérée.
- Ses deux risques sont exactement ce que Gb2 et Gb4 mesurent : un flux de tirage modifié, une prémisse fausse.

(a) a pour elle deux avantages réels :
- l'exactitude par construction, indépendante de toute simulation future ;
- la fin de la dilution de A.

Elle a pour coûts :
- un contrat partagé ;
- un domaine restitué plus large (A sur les carrés, avertissement sur tout triangle à colonne dégénérée) ;
- une loi de σ_boot qui reste incohérente dans le cas dégénéré.

## 3. Mesures du script de l'étape 3 (iii)

### 3.1 Fichiers et commande

- Fichiers : `docs/revues/20261125-a3-creneau/mesure-620/mesure_620.R` (adaptation de `mesure_617.R`), `sortie_mesure_620.txt`, `README.md`. Sortie en ASCII, sans accents.
- Aucun fichier de `R/`, `tests/` ni `app.R` n'est modifié.
- Commande, depuis la racine : `LC_ALL=C.UTF-8 Rscript docs/revues/20261125-a3-creneau/mesure-620/mesure_620.R > …/sortie_mesure_620.txt 2>&1`.
- Options, avec leurs défauts : `--B=999`, `--graine=20260831`, `--graine2=20261125`, `--triangles=T0,T1,T2,T3,K1,KA,R2,R2T`. L'option `--essai` (B = 99) porte l'en-tête « ESSAI, NON VERSABLE ».

### 3.2 Variantes

Toutes passent par substitution dans `env <- environment(run_engine)` (ADR 0016), avec `environment(f) <- env`. Elles sont retirées par `tryCatch(finally=)`. Le script ne tire rien lui-même.

**V0** : moteur tel quel.

**Va**, deux liaisons :
- `mw_famille_alpha` ← corps imposé :
  ```r
  function(aj, j_degeneres = NULL) {
    I <- aj$I; J <- aj$J; tri <- aj$tri
    jd <- .mw_j_exclues(aj, j_degeneres)
    blocs <- list()
    for (j in 0:(J - 1)) {
      idx <- 0:(I - j - 1)
      if (length(idx) < 3 || j %in% jd) next
      C0 <- tri[idx + 1, j + 1]; F <- tri[idx + 1, j + 2] / C0
      f <- vapply(c(0, 1, 2), function(a) sum(C0^a * F) / sum(C0^a), numeric(1))
      blocs[[length(blocs) + 1L]] <- list(j = j, n = length(idx), f0 = f[1], f1 = f[2],
                                          f2 = f[3], amplitude = (max(f) - min(f)) / f[2])
    }
    det <- .mw_empiler(blocs)
    if (!nrow(det)) return(list(stat = NA_real_, detail = det))
    list(stat = sum(det$n * det$amplitude) / sum(det$n), detail = det)
  }
  ```
- `MW_CATALOGUE_MC` ← copie dont `Alpha = .mc_entree(function(e) mw_famille_alpha(e$aj, e$figes$degeneres)$stat, "haut")`.

**Vb** : `.mw_simulation_sigma_direct` ← `function(aj) !is.null(aj[["sigma2_Jm1_direct"]])`. Artefact connu du prototype : les textes M6 et `usage_sigma` des trapèzes dégénérés basculent en « simulation ». Ils sont exclus des comparaisons et listés.

**Journal** (V0 seulement, sur T0, T1, T2 et K1) : crochet de lecture sur `.mw_stats`, comme dans #617. Il fournit p_sans par `engine_p_mc(·, ·, "haut")`.

### 3.3 Triangles

Constructions exactes. Préconditions vérifiées par ma sonde ; elles deviennent les valeurs attendues du contrôle I6.

| Nom | Construction | I, J | `degeneres` | cas | règle | direct | Colonnes d'Alpha | Rôle |
|---|---|---|---|---|---|---|---|---|
| T1 | `triangle_mw_trapeze.csv`, C(i,5) := C(i,4)·f̂_4, i = 0..2 | 7, 5 | {4} | degenere | 0,141928 | 0 | 0..4 | domaine de l'issue |
| T2 | colonnes j0 à j4 de `triangle_mw.csv`, C(i,4) := C(i,3)·f̂_3, i = 0..3 | 7, 4 | {3} | degenere | 0,684464 | 0 | 0..3 | domaine de l'issue |
| T0 | comme `mesure_617.R` | 7, 5 | {2, 4} | degenere | 7,8e-29 | 1,2e-28 | — | témoin, règle négligeable |
| T3 | colonnes j0 à j6 de `triangle_mw.csv`, C(i,6) := C(i,5)·f̂_5, i = 0..1 | 7, 6 | {5} | degenere | 0,0300913 | 0 | 0..4 | (b) à I = J + 1 : σ_boot seul |
| K1 | `triangle_mw.csv` ; pour i = 0..4, C(i,3..7) × f̂_2·C(i,2)/C(i,3) | 7, 7 | {2, 6} | carre | 0,0974525 | absent | 0..4, dont la colonne 2 (n = 5) | (a) sur un carré, j ≤ J−2 |
| KA | `triangle_mw.csv`, colonnes 0 à 4 rendues dégénérées l'une après l'autre (même opération) | 7, 7 | {0..4, 6} | carre | — | absent | 0..4, toutes figées | (a) sans colonne restante ; admis, vivier de 2 résidus |
| R2 | `reserve2` | 7, 7 | {6} | carre | 0,0973248 | absent | 0..4 | témoin |
| R2T | `reserve2_trapeze` | 7, 5 | {} | simulation | 0,141928 | 0,0973248 | 0..4 | témoin |

### 3.4 Contrôles d'intégrité

- **I1** : V0 exécuté deux fois, au début et à la fin (après toutes les variantes) : `identical()` sur `res` entier. Le V0 avec journal est `identical()` au V0 sans journal.
- **I2** : après chaque variante, chaque liaison substituée est `identical()` à l'originale.
- **I3** : md5 de `R/engine.R` = `723277dd…`, et `git status --porcelain -- R/ tests/ app.R` vide, au début et à la fin.
- **I4** : reproduction de #617. V0 sur T1, T2 et T0 redonne N_moteur = 7, 22 et 15, et N_sans = 6, 9 et 15, soit p = 0,008, 0,023 et 0,016 contre 0,007, 0,010 et 0,016.
- **I5** : « V0 = moteur ». V0 de R2 et R2T comparé à `tests/reference/reserve2.rds` et `reserve2_trapeze.rds` par `comparer_objets()` (seuil 10⁻⁶). Les p_mc, verdicts et σ_USP sont égaux.
- **I6** : préconditions du tableau du § 3.3.
- **I7** : Va. Sur chaque triangle, `.mw_colonnes_degenerees(aj)` est `identical()` à `figes$degeneres`.
- **I8** : graines passées par `run_engine(seed=)` seulement ; B = 999.
- **I9** : les substitutions agissent bien.
  - Vb : `aj$sigma2[J]` reçu par `.mw_tirer_triangle_valide()` vaut `sigma2_Jm1_direct` (crochet de lecture, comme D1 de #617).
  - Va : sur les 50 premières réplications du journal, la variante redonne la colonne Alpha de `stats_boot`.

### 3.5 Grandeurs relevées, par triangle et par variante

- **M-a** : les 13 `p_mc`, `err_mc`, `B_effectif` ; `stats_obs` ; `identical()` de chaque colonne de `stats_boot` contre V0.
- **M-b**, ligne Alpha : `stat`, `p_retenue`, `nature_p`, `type`, `verdict` à 0,10, `inoperant`.
- **M-c, critère 4** : lignes « p de famille (minP…) » de chaque famille, et ligne LC. Pour chacune : `p`, `stat` (m_obs), membres, `B_eff`, et la décomposition `num_obs`, `num_m_obs`, `num_p`, `N`, qui dit quel membre atteint le minimum. Les familles sans Alpha (M2, M3, M4) doivent rester `identical()`.
- **M-d, verdicts à α saisi.** Les intervalles d'α où le verdict d'Alpha diffère entre V0 et la variante, ]p₁ ; p₂] ∪ ]2p₁ ; 2p₂], se calculent par la règle de la l. 5485 (ECHEC si p < α/2 ; ALERTE si α/2 ≤ p < α ; OK sinon). Ils sont bornés à l'α admissible ]0 ; 0,30[, avec le repère de l'application α ≤ 4/(B+1). Les verdicts de toutes les autres lignes à 0,10 restent identiques.
- **M-e** : σ_USP ; σ_boot (longueur, moyenne, quantiles 0,05, 0,5 et 0,95) ; bornes de `ic_bootstrap` ; écarts relatifs Vb/V0 ; `n_sans_sigma`, `cumuls_retires`, `plafond_cumuls`.
- **M-f**, valeur de A : A_obs sous V0 et Va, rapport contrôlé à Σn/Σ'n (T1 : 25/22 ; T2 : 22/18 ; K1 : 25/20) ; lignes de `detail`.
- **M-g**, discordances : liste des réplications où l'indicateur A* ≥ A_obs diffère entre Vb et Va, avec leur écart relatif (pour Gb1).
- **M-h**, graine secondaire 20261125 : T1 et T2, V0, Va et Vb. Seulement p d'Alpha, p de famille M1 et p globale, pour situer la variabilité Monte-Carlo de l'effet du critère 4.

### 3.6 Prédictions écrites avant la mesure [H]

- **H1** : Va donne p_Alpha = p_sans au bit près sur T0 à T2 : 0,016, 0,007 et 0,010. Sur K1, Δp = 0. A_obs est multiplié par Σn/Σ'n.
- **H2** : Vb donne p_Alpha = p_sans sur T0 à T2, sans discordance. Les douze autres clés sont `identical()` sur T0 à T3. σ_boot et `ic_bootstrap` changent sur T1, T2 et T3, et de façon négligeable sur T0.
- **H3** : sous Va et Vb, la p de famille M1 et la p globale sont égales entre elles sur T0 à T2. Le sens de leur écart à V0 n'est pas prédit.
- **H4** : R2 et R2T sont `identical()` sous Va et sous Vb. T3 l'est sous Va, et K1 et KA sous Vb.
- **H5** : V0 sur KA rend `MOTIF_MC_DISPERSION_NULLE` sur Alpha (diagnostic, `inoperant` = TRUE). Va rend « non applicable ». Si V0 rendait une p finie, calculée sur du bruit d'arrondi, ce serait un constat E3 à rapporter.
- **H6** : au seuil 0,10, aucun verdict d'Alpha ne change sur T1 et T2 (ECHEC des deux côtés).

### 3.7 Erreur de Monte-Carlo et erreur d'approximation

**Erreur de Monte-Carlo (fonction de B).**
- Chaque p a une erreur de l'ordre de √(p(1−p)/B) (champ `err_mc`).
- Va reprend exactement les réplications de V0. Vb reprend les mêmes tirages e, nombres aléatoires communs, sous réserve de Gb2.
- Les écarts sont donc **appariés**. Pour Alpha, l'écart vaut D/(B+1), avec D binomial, d'erreur √(δ(1−δ)/B) (lecture 2c de #617, § 1.5).
- Pour la p de famille et la p globale, l'écart n'est pas monotone. Aucune loi simple ne le décrit : la graine secondaire (M-h) en donne une idée de variabilité, sans en fournir une erreur type.

**Erreur d'approximation (fonction de T).**
- Aucun modèle sous H0 à σ_{J−1} > 0 ne produit une colonne dégénérée : le niveau de la ligne et des p de lecture conjointe n'est **pas mesurable** dans ce cas.
- Aucune piste ne peut donc être dite « mieux calibrée » à T = 8. Elles se distinguent par la cohérence de la statistique avec sa loi de référence, non par un niveau.
- Tous les chiffres sont des constats de simulation conditionnels aux triangles construits, non transposables.

### 3.8 Budget de calcul [H]

- `run_engine()` à B = 99 prend 1,08 s sur KA [V]. À B = 999, environ 10 s par exécution, par extrapolation linéaire.
- Huit triangles × 4 exécutions (V0, V0 final, Va, Vb), plus le V0 avec journal sur 4 triangles, plus 6 exécutions de graine secondaire : environ 42 exécutions, plus le recalcul du journal. **Environ 8 minutes.**
- Pré-vol : `--essai` deux fois, qui doivent être identiques au bit (critère de l'étape 3), environ 1,5 minute.
- Pour mémoire, #617 a pris 95,9 s pour 3 triangles.

## 4. Texte prévisionnel de `mw:m1d` (iv)

**Méthode de décompte.** Python, du `\begin{fiche}` au `\end{fiche}` inclus. Il donne 12 798 caractères, contre 12 799 au contrôleur officiel : 1 caractère d'écart constant, sans doute le saut de ligne final. Les projections ci-dessous sont sur la base officielle.

**Paragraphes remplacés** :
- rubrique 6, « Colonnes dégénérées », 1 662 caractères hors ligne blanche ;
- rubrique 7, « Colonnes dégénérées … sans la colonne. », 690 caractères.

La phrase « Membre, quand elle est de type test, … verdict inchangé. » est gardée telle quelle. Les nombres `0{,}0xx` sont à remplir après la lecture ; leur longueur est celle des vraies valeurs. Textes conformes à `CONVENTIONS.md` : ni SHA, ni numéro d'issue.

### (b) — rubrique 6 (1 243 caractères)

```latex
\emph{Colonnes dégénérées.} \code{mw\_famille\_alpha()} ne reçoit pas l'ensemble figé des colonnes
dégénérées (règle commune, section~\ref{sec:mwm1})~: elle garde ces colonnes dans $A$, avec leur
poids $n_j$, et l'avertissement des colonnes dégénérées ne nomme pas la ligne parmi celles qui les
écartent (§\ref{sec:controles}). L'amplitude observée d'une telle colonne est nulle ou de l'ordre
de la tolérance $10^{-12}$ du prédicat, mais son poids reste au dénominateur. Tirée avec un
$\hat\sigma_j^2$ nul ou négligeable (le sien pour $j \le J-2$, l'estimateur direct pour la colonne
$J-1$ d'un trapèze, section~\ref{sec:boot-mw}), la colonne garde une amplitude négligeable dans les
réplications (dégénérée dans chaque réplication mesurée, rubrique~7)~: $A$ observée et simulées
sont multipliées par $\sum' n_j/\sum_j n_j$ ($\sum'$ sur les colonnes non dégénérées)~; la p-value
de Monte-Carlo, comme la p de famille de M1 et la p globale, n'en est pas modifiée, à des égalités
près de l'ordre de la tolérance, et seule la valeur restituée de $A$, diminuée, ne se lit plus
comme l'amplitude moyenne des colonnes non dégénérées. La colonne $J-1$ d'un carré, qui n'a qu'un
facteur, ou d'un trapèze à moins de trois facteurs n'entre pas dans $A$.
```

### (b) — rubrique 7 (784 caractères)

```latex
Colonnes dégénérées (rubrique~6~; $B = 999$, graine 20260831, triangles construits)~: constats de
simulation, non transposables. Colonnes tirées avec $\hat\sigma_j^2$ nul ou négligeable (triangle de
six années, $j = 0$~; trapèze de référence modifié, $j = 2$ et $J-1$~; colonne $J-1$ de deux
trapèzes construits, $8\times6$ et $8\times5$, estimateur direct nul)~: dégénérées dans chaque
réplication, p-value inchangée sans la colonne. Tirée avec la règle de minimum ($0{,}14$ et
$0{,}68$), la colonne $J-1$ de ces deux trapèzes ne serait dégénérée dans aucune réplication~:
p-value $0{,}008$ et $0{,}023$ au lieu de $0{,}0xx$ et $0{,}0xx$, p de famille de M1 $0{,}0xx$ et
$0{,}0xx$ au lieu de $0{,}0xx$ et $0{,}0xx$, p globale $0{,}0xx$ et $0{,}0xx$ au lieu de $0{,}0xx$
et $0{,}0xx$.
```

**Bilan (b)** : 12 799 − 1 662 + 1 243 − 690 + 784 = **≈ 12 474** (marge ≈ 326).

Hors budget, dans `sec:boot-mw` :
- « où $\hat\sigma_{J-1}$ est la valeur de la règle de minimum, sauf sur un trapèze dont la colonne $J-1$ n'est pas dégénérée, simulée avec l'estimateur direct qui en réduit les résidus » devient « … est la valeur de la règle de minimum sur un carré et l'estimateur direct sur un trapèze » ;
- « Sur un trapèze $I > J$ dont la colonne $J-1$ n'est pas dégénérée (\code{.mw\_colonne\_degeneree()}), » devient « Sur un trapèze $I > J$, » ;
- « Colonne $J-1$ dégénérée, ou triangle carré, qui n'a pas d'estimateur direct~: simulation avec la valeur de la règle. » devient « Triangle carré, qui n'a pas d'estimateur direct~: simulation avec la valeur de la règle. Colonne $J-1$ dégénérée~: son estimateur direct, nul ou négligeable, la garde dégénérée dans les réplications, comme une colonne $j \le J-2$ dégénérée tirée avec son propre $\hat\sigma_j^2$~; tirée avec la règle, elle ne le serait plus, et le triangle observé serait de probabilité nulle sous la loi de référence. »

`regulatory` passe en routine : le passage cite D(4) et D(5).

### (a) — rubrique 6 (1 068 caractères)

```latex
\emph{Colonnes dégénérées.} \code{mw\_famille\_alpha()} reçoit l'ensemble figé des colonnes
dégénérées (règle commune, section~\ref{sec:mwm1}) et les écarte de $A$, à l'observé comme dans
chaque réplication~; l'avertissement des colonnes dégénérées nomme la ligne parmi celles qui les
écartent (§\ref{sec:controles}). $A$ est l'amplitude moyenne des colonnes non dégénérées d'au moins
trois facteurs~; sans colonne restante, elle n'est pas définie et la ligne est non applicable.
Aucune colonne figée n'entre dans $A$ observée ni simulée, quelle que soit sa loi de simulation~:
la p-value n'en dépend pas (propriété exacte), pas plus que la p de famille de M1 et la p globale,
dont aucun membre ne lit ces colonnes. C'est le cas de la colonne $J-1$ d'un trapèze, dégénérée à
l'observé mais tirée avec la valeur de la règle de minimum (section~\ref{sec:boot-mw}), qui ne
l'est plus dans les réplications quand cette valeur n'est pas négligeable~: gardée dans $A$, son
amplitude, nulle à l'observé et positive dans chaque réplication, majorerait la p-value (rubrique~7).
```

### (a) — rubrique 7 (579 caractères)

```latex
Colonnes dégénérées (rubrique~6~; $B = 999$, graine 20260831, triangles construits)~: constats de
simulation, non transposables. Colonne $J-1$ tirée avec une règle de minimum de $0{,}14$ (trapèze de
référence modifié, $8\times6$, trois facteurs) ou de $0{,}68$ (triangle de contrôle réduit et
modifié, $8\times5$, quatre)~: dégénérée dans aucune réplication~; p-value $0{,}0xx$ et $0{,}0xx$,
p de famille de M1 $0{,}0xx$ et $0{,}0xx$, p globale $0{,}0xx$ et $0{,}0xx$, contre $0{,}008$,
$0{,}023$, $0{,}0xx$, $0{,}0xx$, $0{,}0xx$ et $0{,}0xx$ si la colonne était gardée dans $A$.
```

**Bilan (a)** : 12 799 − 1 662 + 1 068 − 690 + 579 = **≈ 12 094** (marge ≈ 706).

Deux passages sont retirés de la fiche et vont au suivi, sous `mw:m1d` :
- le constat « colonnes tirées avec σ̂² nul ou négligeable … p-value inchangée sans la colonne » (triangle de six années, T0), sans objet sous une propriété exacte ;
- l'explication de la dilution de A.

Hors budget, `sec:mwm1` (1), en fin de liste des lecteurs de l'ensemble figé : « …, et à la famille~$\alpha$ (entrée \code{Alpha}, fiche~\ref{mw:m1d}) ».

### (c) — rubrique 6 réécrite avec la phrase du critère 4, condensée sans retrait de fond (1 712 caractères)

```latex
\emph{Colonnes dégénérées.} \code{mw\_famille\_alpha()} ne reçoit pas l'ensemble figé des colonnes
dégénérées (règle commune, section~\ref{sec:mwm1})~: elle les garde dans $A$, avec leur poids
$n_j$, et l'avertissement des colonnes dégénérées ne la nomme pas parmi les lignes qui les écartent
(§\ref{sec:controles}). Leur amplitude observée est nulle ou de l'ordre de la tolérance $10^{-12}$
du prédicat, leur poids restant au dénominateur. Tirée avec un $\hat\sigma_j^2$ nul ou négligeable
(colonne $j \le J-2$, ou $J-1$ quand la règle de minimum l'est, section~\ref{sec:boot-mw}), une
telle colonne garde une amplitude négligeable dans les réplications (dégénérée dans chaque
réplication mesurée, rubrique~7)~: $A$ observée et simulées sont multipliées par
$\sum' n_j/\sum_j n_j$ ($\sum'$ sur les colonnes non dégénérées)~; la p-value de Monte-Carlo n'en
est pas modifiée, à des égalités près de l'ordre de la tolérance, et seule la valeur restituée de
$A$, diminuée, ne se lit plus comme l'amplitude moyenne des colonnes non dégénérées. La colonne
$J-1$ d'un trapèze, tirée avec la valeur de la règle de minimum, n'est en général plus dégénérée
quand cette valeur n'est pas négligeable~; avec au moins trois facteurs, son amplitude, nulle à
l'observé, entre dans chaque $A$ simulée, et la p-value est au moins égale à celle de $A$ sans la
colonne (propriété exacte, les amplitudes étant positives ou nulles)~: écart conservateur, de
grandeur non transposable, d'effet sur le niveau et la puissance non mesuré~; la p de famille de
M1 et la p globale, dont la ligne est membre, en sont modifiées sans sens garanti (rubrique~7).
Avec moins de trois facteurs, carré compris, la colonne $J-1$ n'entre pas dans $A$.
```

### (c) — rubrique 7 (738 caractères)

```latex
Colonnes dégénérées (rubrique~6~; $B = 999$, graine 20260831, triangles construits)~: constats de
simulation, non transposables. Colonnes tirées avec $\hat\sigma_j^2$ nul ou négligeable (triangle de
six années, $j = 0$~; trapèze de référence modifié, $j = 2$ et $J-1$, $\hat\sigma_j^2$ voisin de
$10^{-28}$)~: dégénérées dans chaque réplication, p-value inchangée sans la colonne. Colonne $J-1$
tirée avec une règle de minimum de $0{,}14$ ($8\times6$, trois facteurs) ou $0{,}68$ ($8\times5$,
quatre)~: dégénérée dans aucune réplication~; p-value $0{,}008$ et $0{,}023$, p de famille de M1
$0{,}0xx$ et $0{,}0xx$, p globale $0{,}0xx$ et $0{,}0xx$, contre $0{,}007$, $0{,}010$, $0{,}0xx$,
$0{,}0xx$, $0{,}0xx$ et $0{,}0xx$ sans la colonne.
```

**Bilan (c)** : 12 799 − 1 662 + 1 712 − 690 + 738 = **≈ 12 897** : **dépassement d'environ 97**. Deux voies :
- `docwriter` condense environ 100 caractères ailleurs dans la fiche (règle 5) ;
- relèvement à 12 900 ou 13 000, décidé à PA-2.

**Lecture du commentaire du 25/11 sous (a) ou (b)** (PA-1-3). La fiche dit :
- la propriété d'indépendance des deux p de lecture conjointe, exacte en (a), aux égalités de tolérance près en (b) ;
- les valeurs avec la colonne gardée (a) ou tirée avec la règle (b), à titre de justification du traitement, non d'historique.

L'avant / après daté va au tableau et à `docs/suivi-documentation/III-M.md`.

## 5. Constats hors périmètre, triés selon l'ADR 0018 (v)

Aucun constat marquant. Aucune issue proposée.

### Constats mineurs écartés (ADR 0018)

- **C1** — `tests/controle_doc_nd.R` et `docs/latex/CONVENTIONS.md` l. 64 donnent 12 799 caractères pour `mw:m1d` ; ma méthode en compte 12 798. Écart constant de convention (saut de ligne final probable), sans effet sur le plafond — actuary-approfondi, 25/11/2026 — aucun critère.
- **C2** — `R/engine.R` l. 14142-14143 : le commentaire dit « la famille alpha garde ces colonnes (amplitude nulle) ». C'est vrai à l'observé, pas dans les réplications de J−1 tirée avec la règle. Commentaire descriptif, sans règle de calcul énoncée ; réécrit de toute façon sous (a) ou (b) — actuary-approfondi, 25/11/2026 — aucun critère.
- **C5** — `docs/latex/doc_tests_usp.tex`, `sec:boot-mw` (l. 6569-6576). Le fondement écrit (le triangle observé doit garder une probabilité non nulle sous la loi de référence) est contredit par le cas « Colonne J−1 dégénérée : simulation avec la valeur de la règle », que le texte décrit pourtant exactement. Tension de doctrine, non affirmation fausse sur le code, donc pas E5. Sous (b), elle disparaît. Sous (a) ou (c), elle demeure pour σ_boot ; une phrase serait à ajouter en `sec:boot-mw` sur décision du mainteneur — actuary-approfondi, 25/11/2026 — aucun critère.

**Point à lire à l'étape 5, non constaté** : H5. Si V0 rend sur KA une p d'Alpha finie calculée sur du bruit d'arrondi, ce sera un constat E3.

## 6. Questions au mainteneur pour PA-1

- **PA-1-1 — Protocole de mesure.** Les huit triangles du § 3.3, les variantes V0, Va et Vb du § 3.2 par substitution, B = 999, graine 20260831, graine secondaire 20261125 sur T1 et T2 (M-h), contrôles I1 à I9. *Recommandation* : approuver. *Écartés* :
  - B = 9 999 : coût multiplié par 10, alors que Δp est structurel et que l'appariement retire l'essentiel de l'erreur de Monte-Carlo ;
  - sans graine secondaire : aucun repère de variabilité pour l'effet non monotone du critère 4 ;
  - mesure de (a)+(b) et de (a′) : aucune valeur de décision (§ 1.4).
- **PA-1-2 — Règle de décision du § 2.** Ordre (b), puis (a), puis (c), sous les contrôles d'admissibilité ; la grandeur de Δp et celle de l'effet sur σ_boot hors critère. *Recommandation* : approuver l'ordre (b) puis (a) (motifs au § 2). *Options* :
  - (a) d'abord, si le mainteneur préfère ne pas revenir sur la clause du 25/11 de l'ADR 0005 et veut une propriété exacte, indépendante de la simulation ;
  - aucun ordre fixé d'avance, écarté : la fiche exige que les critères soient écrits avant la mesure.
- **PA-1-3 — Lecture du commentaire du 25/11 sous (a) ou (b)** (fin du § 4). *Recommandation* : la fiche dit la propriété d'indépendance et les valeurs avec ou sans la colonne comme justification ; l'avant / après daté va au suivi. *Écarté* : un avant / après dans le `.tex` (vie du dépôt, `CONVENTIONS.md`).
- **PA-1-4 — Prototype Va** : A = `NA` sans colonne restante, soit (a-i). *Recommandation* : approuver pour la mesure. La forme définitive se décide à PA-2, comme le prévoit la fiche.

## 7. Retour

**Statut** : `revue requise`. La spécification est complète, avec ses preuves de lecture et de sonde. PA-1 (décision du mainteneur) est requis avant toute mesure.

**Résultat** :
- trois pistes comparées, deux variantes écartées avec leur motif ;
- critères d'admissibilité Ga1 à Ga4 et Gb1 à Gb4, et règle de choix (b) > (a) > (c), écrits avant toute mesure ;
- protocole de l'étape 3 (variantes, triangles, I1 à I9, M-a à M-h, prédictions H1 à H6), budget d'environ 8 minutes [H] ;
- textes de `mw:m1d` comptés : (a) ≈ 12 094, (b) ≈ 12 474, (c) ≈ 12 897 (dépassement d'environ 97).

**Preuves**

*Vérifiées*
- Code relu aux lignes citées : `mw_famille_alpha()` ; entrée Alpha ; l. 16416-16417 ; `.mw_simulation_sigma_direct()` et `.mw_cas_sigma_direct()` (couplage) ; règle des verdicts l. 5485 ; `engine_p_mc()` (dispersion, l. 4757-4762) ; branche « non applicable » d'`add()` l. 5217-5220 ; minP par rangs ; l'avertissement et sa liste statique ; `plot_mw_alpha()` qui tolère une table vide.
- Sonde : préconditions des huit triangles (tableau du § 3.3) ; `reserve2` et `reserve2_trapeze` sans avertissement de colonnes dégénérées ; KA admis ; seuils de retirage de la colonne J−1 (−139 et −62,6, contre −1,58 au minimum du vivier) ; `run_engine()` à B = 99 en 1,08 s.
- Comptes de caractères des textes du § 4.
- Motif du cas dégénéré dans V2 : protocole de #612, l. 87-92.

*Hypothèses*
- H1 à H6.
- Flux de tirage inchangé sous Vb.
- Budget de calcul.
- Références identiques sous (a) et (b) : *hypothèse forte*, à prouver à l'étape 6.

*Non vérifiées*
- Comportement de la branche `non_definie` d'`add()` pour (a-ii).
- Références externes du minP (Westfall et Young ; Ge, Dudoit et Speed) : citées par le moteur, non relues par moi, et non invoquées ici pour une propriété.

**Informations manquantes** : aucune pour la spécification. Le niveau à T = 8 n'est mesurable sous aucune piste (§ 3.7).

**Décisions non résolues** : PA-1-1 à PA-1-4 (mainteneur). À PA-2 : la piste, la forme de A sans colonne restante, le budget de `mw:m1d`, l'annotation de l'ADR 0005 si (b).

**Critères déclenchés** (`docs/agents/routage.md`, § 4)
- Question qu'aucun test ni aucune source ne tranche : le choix entre (a) et (b) quand les deux sont admissibles. La mesure ne les départage pas sur Alpha.
- Désaccord avec un ADR : la piste recommandée (b) remplace une clause de l'ADR 0005 (annotation du 25/11, point 1).
- Contrat partagé, en (a).
- Changement de résultat : p d'Alpha, p de famille M1 et p globale, verdict à α saisi, sous (a) comme sous (b) ; en plus, σ_boot et l'intervalle sous (b).
- Validité à T = 8 qu'aucun résultat exact ni aucune simulation ne tranche : aucun modèle sous H0 ne produit le cas.

**Constats hors périmètre** : § 5 (C1, C2, C5 mineurs, aucun critère ; H5 à lire).

**Prochaine action recommandée**
1. La session verse ce rapport dans `docs/revues/20261125-a3-creneau/`.
2. PA-1.
3. Étape 3 : `coder-approfondi` (`high`) écrit `mesure_620.R` selon le § 3, puis audit léger.

Chemins utiles :
- `/home/user/outil_usp/docs/revues/20261125-js2-jalon/mesure-617/mesure_617.R` (base du script) ;
- `/home/user/outil_usp/R/engine.R` ;
- `/home/user/outil_usp/docs/latex/doc_tests_usp.tex` (l. 6535-6600, 16373-16450, 17212-17376) ;
- `/home/user/outil_usp/docs/adr/0005-msep-reserve-2-formule-imprimee-d5.md`.
