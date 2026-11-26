# Tableau avant / après — #620, piste (b) : colonne J−1 dégénérée d'un trapèze simulée avec son estimateur direct

| Grandeur | Valeur |
| --- | --- |
| Date | 2026-11-26 |
| Décision | Mainteneur, point d'arrêt PA-2 d'A3, 26/11/2026 : piste (b) (PA-2-1), textes du cas « degenere » du § 4.3 de la lecture d'`actuary-approfondi` approuvés (PA-2-4) ; ADR 0005, annotation du 26/11/2026 ; `docs/revues/20261125-a3-creneau/actuary-2-lecture-mesure-620.md` |
| Modification | `.mw_simulation_sigma_direct()` vrai si et seulement si le triangle est un trapèze (champ `sigma2_Jm1_direct` présent), colonne J−1 dégénérée comprise ; `.mw_cas_sigma_direct()` lit `.mw_colonne_degeneree()` directement pour le cas « degenere » ; `FORMAT_MENTION_MW_SIGMA_DIRECT_DEGENERE` et `MW_USAGE_SIGMA_DEGENERE` réécrits (§ 4.3) |
| Commande | `LC_ALL=C.UTF-8 B_CMP=999 Rscript comparer_vb.R` puis `LC_ALL=C.UTF-8 Rscript tableau_620.R` (racine du dépôt ; scripts hors dépôt, `comparer_vb.R` reproduit en annexe, md5 `df762e699e568a808934c729226dc5c4` ; `tableau_620.R`, mise en forme seule, md5 `6ad503b0818995ea28fdc4d68670abc9`) |
| Moteur avant | `R/engine.R` de `36e2041` (`git show 36e2041:R/engine.R`), md5 `723277ddfa5736d7411838d15d8dad00` |
| Moteur après | `R/engine.R` de l'arbre de travail (commit `moteur:` de ce tableau), md5 `c7b767f5d9116c35a0a9237ffdd2d79a`. Mesures faites sur des versions qui n'en diffèrent que par des commentaires de l'en-tête de `.mw_simulation_sigma_direct()` : `comparer_vb.R` (B = 999) sur la version md5 `60f5d32630708e47425c6b3ffa1c3619`, rejeu adapté de `mesure_620.R` et `comparer_references.R --seuil 0` sur la version md5 `105949ad708ad15ae2a2705cea3ac42c`. Empreinte sans commentaires (`empreinte_sans_commentaires()`) identique pour les trois versions : `15a74c3dbd831c56c259df106e9e4667` |
| R, plateforme | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; BLAS : /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.12.0 |
| Appels | `run_engine(methode = "reserve2", triangle, segment = 1, annexe = "II", date_reference = "2026-12-31", B = 999, seed = 20260831)` (et `seed = 20261125` pour T1 et T2), alpha = 0,10 (défaut) |
| Triangles | Construits par `mesure_620.R` (§ 3.3 de la spécification ; construction recopiée dans `comparer_vb.R`) : **T1** = 8 × 6 de `reserve2_trapeze`, colonne J−1 = 4 rendue dégénérée (3 facteurs) ; **T2** = colonnes 0..4 de `triangle_mw.csv`, colonne J−1 = 3 dégénérée (4 facteurs) ; **T0** = T1 dont la colonne j = 2 est aussi dégénérée (règle 7,8·10⁻²⁹, estimateur direct 1,2·10⁻²⁸) ; **T3** = colonnes 0..6, colonne J−1 = 5 dégénérée (2 facteurs, hors de A) ; témoins **K1**, **KA** (carrés), **R2** (`reserve2`), **R2T** (`reserve2_trapeze`). Hors références, sauf R2 et R2T. |

## 1. Références : les sept cas inchangés

Aucun cas de `CAS` n'emprunte le chemin modifié : `reserve2` est un carré (pas d'estimateur direct) ; `reserve2_trapeze` est un trapèze à colonne J−1 non dégénérée, déjà simulé avec l'estimateur direct sous V2 (#612) ; les cinq cas lognormaux n'appellent pas `mw_bootstrap()`.

Mesure : `LC_ALL=C.UTF-8 Rscript tests/comparer_references.R --seuil 0` (moteur md5 `105949ad…`), code de sortie 0 :

| Cas | Feuilles | Non strictement identiques | Écart maximal |
| --- | --- | --- | --- |
| `premium` | 57022 | 0 | 0.000e+00 |
| `reserve1` | 57021 | 0 | 0.000e+00 |
| `reserve2` | 18746 | 0 | 0.000e+00 |
| `premium_ii6` | 57022 | 0 | 0.000e+00 |
| `premium_net` | 57022 | 0 | 0.000e+00 |
| `premium_interieur` | 57022 | 0 | 0.000e+00 |
| `reserve2_trapeze` | 18573 | 0 | 0.000e+00 |

`LC_ALL=C.UTF-8 Rscript tests/test_reproductibilite.R` : « OK : reproductibilite et non-regression verifiees pour 7 cas », code 0, σ_USP inchangés (`reserve2` 0,0497764613 ; `reserve2_trapeze` 0,0475797067). Aucune régénération de référence.

## 2. Synthèse (B = 999, graine 20260831)

σ_USP, `parametre`, `parametre_final`, `ajustement`, `msep`, `residus` et `bootstrap$stats_obs` sont `identical()` avant et après sur les quatre triangles : seule la loi simulée de la colonne J−1 change (σ_USP : propriété exacte, `mw_parametre()` ne reçoit pas le bootstrap). Aucun verdict ne change au seuil 0,10 (0 ligne sur 25 par triangle).

| Triangle | p d'Alpha avant → après | p de famille M1 | p globale (LC) | Verdict d'Alpha à 0,10 | α saisi où le verdict d'Alpha diffère | σ_boot, écart relatif (moyenne ; q05 ; q50 ; q95) | `ic_bootstrap`, écart relatif (2,5 ; 5 ; 50 ; 95 ; 97,5 %) | σ_USP |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| T0 | 0,016 → 0,016 | 0,056 → 0,056 | 0,111 → 0,111 | ECHEC → ECHEC | aucun | 0 à 6 chiffres (non `identical`) | `identical` | 0,0449184869, `identical` |
| T1 | 0,008 → **0,007** | 0,015 → 0,015 | 0,027 → 0,027 | ECHEC → ECHEC | ]0,007 ; 0,008] ∪ ]0,014 ; 0,016] | −0,019 ; −0,016 ; −0,159 ; +0,131 % | +0,038 ; −0,003 ; −0,035 ; +0,034 ; −0,085 % | 0,04757970671, `identical` |
| T2 | 0,023 → **0,010** | 0,019 → 0,019 | 0,022 → **0,023** | ECHEC → ECHEC | ]0,010 ; 0,046] | −0,005 ; +0,028 ; −0,021 ; +0,048 % | −0,069 ; +0,005 ; −0,005 ; +0,014 ; −0,244 % | 0,04948541798, `identical` |
| T3 | 0,004 → 0,004 | 0,017 → 0,017 | 0,042 → 0,042 | ECHEC → ECHEC | aucun | −0,000 ; +0,117 ; −0,039 ; −0,078 % | −0,010 ; +0,020 ; −0,008 ; −0,019 ; +0,020 % | 0,04670611595, `identical` |

Graine secondaire 20261125 : T1, p d'Alpha 0,008 → 0,005, M1 0,010 et LC 0,021 inchangées ; T2, p d'Alpha 0,023 → 0,006, M1 0,009 et LC 0,008 inchangées ; aucun verdict changé à 0,10 ; σ_boot jusqu'à −0,386 % (q95 de T1), `ic_bootstrap` jusqu'à −0,103 % (détail au § 3).

Verdicts à α saisi : règle d'`add()`, ECHEC si p < α/2, ALERTE si α/2 ≤ p < α, OK sinon. Sur les intervalles indiqués, le verdict d'Alpha passe dans le sens plus sévère (OK → ALERTE, ALERTE → ECHEC). Les p de famille et la p globale sont de type diagnostic (verdict INFO à tout α). **Visas** : verdicts changés à α saisi visés par le mainteneur le 26/11/2026 (visa préalable, avant le commit `moteur:`) ; autres p, σ_boot, intervalle et références visés par `actuary` le 26/11/2026, sans réserve.

Témoins : K1, KA, R2, R2T `identical()` avant et après (objet entier, hors horodatage, durée et version de R).

## 3. Détail par triangle

Feuilles de `res$tests` qui changent (comparaison feuille à feuille de `comparer_vb.R`, B = 999) : `p_mc`, `err_mc` et `p_retenue` de la ligne Alpha (T1, T2), `p_mc` et `err_mc` de la p globale (T2), `detail` de la ligne M6 (T0 à T3, § 5) ; aucune autre, verdicts et `detail` de la ligne Alpha compris. Hors `res$tests` : `bootstrap$p_mc`, `bootstrap$err_mc` (T1, T2), `bootstrap$sigma_boot` (T0 à T3), `bootstrap$stats_boot` (T0 à T2), `ic_bootstrap` (T1 à T3), `plots_data$sigma_boot`, `plots_data$sigma_usp_boot` (T0 à T3), `plots_data$boot_reperes` (T1 à T3), `plots_data$usage_sigma` (T0 à T3). « Prototype Vb » : moteur d'origine (`36e2041`) dont le seam `.mw_simulation_sigma_direct` est substitué dans l'environnement du moteur par le corps de `sim_direct_vb` de `mesure_620.R` (ADR 0016), comme dans la mesure.

#### T0, graine 20260831

| Grandeur | Avant | Après |
| --- | --- | --- |
| ok | TRUE | TRUE |
| σ_USP | 0,0449184869 | 0,0449184869 |
| σ_USP, `parametre` et `parametre_final` identical() | TRUE | |
| `ajustement`, `msep`, `residus`, `bootstrap$stats_obs` identical() | TRUE | |
| p Monte-Carlo d'Alpha (p retenue) | 0,016 (0,016) | 0,016 (0,016) |
| verdict d'Alpha à α = 0,10 | ECHEC | ECHEC |
| α saisi où le verdict d'Alpha diffère | | aucun (p égales) |
| p de famille M1 | 0,056 | 0,056 |
| p globale (LC) | 0,111 | 0,111 |
| lignes à verdict changé à α = 0,10 (sur 25) | | 0 |
| lignes à p Monte-Carlo changée | | aucune |
| `stats_boot` : colonne Alpha identical() ; 12 autres colonnes identical() | | FALSE ; TRUE |
| σ_boot (moyenne ; q05 ; q50 ; q95) | 0,0134061 ; 0,010054 ; 0,0135209 ; 0,0163075 | 0,0134061 ; 0,010054 ; 0,0135209 ; 0,0163075 |
| σ_boot, écart relatif après / avant − 1 | | +0,000 % ; +0,000 % ; +0,000 % ; +0,000 % (identical : FALSE) |
| `ic_bootstrap` (2.5% ; 5% ; 50% ; 95% ; 97.5%) | 0,0422854 ; 0,0428319 ; 0,0448773 ; 0,0465214 ; 0,0468576 | 0,0422854 ; 0,0428319 ; 0,0448773 ; 0,0465214 ; 0,0468576 |
| `ic_bootstrap`, écart relatif | | +0,000 % ; +0,000 % ; +0,000 % ; +0,000 % ; +0,000 % (identical : TRUE) |
| B effectif d'Alpha ; triangle retiré (`cumuls_retires`) | 999 ; FALSE | 999 ; FALSE |
| Prototype Vb (moteur d'origine, seam substitué) contre moteur modifié : objet identical() hors `tests[[20]]$detail` et `plots_data$usage_sigma` | | TRUE |
| p d'Alpha sous Vb ; moteur modifié | | 0,016 ; 0,016 |

#### T1, graine 20260831

| Grandeur | Avant | Après |
| --- | --- | --- |
| ok | TRUE | TRUE |
| σ_USP | 0,04757970671 | 0,04757970671 |
| σ_USP, `parametre` et `parametre_final` identical() | TRUE | |
| `ajustement`, `msep`, `residus`, `bootstrap$stats_obs` identical() | TRUE | |
| p Monte-Carlo d'Alpha (p retenue) | 0,008 (0,008) | 0,007 (0,007) |
| verdict d'Alpha à α = 0,10 | ECHEC | ECHEC |
| α saisi où le verdict d'Alpha diffère | | ]0,007 ; 0,008] ∪ ]0,014 ; 0,016] |
| p de famille M1 | 0,015 | 0,015 |
| p globale (LC) | 0,027 | 0,027 |
| lignes à verdict changé à α = 0,10 (sur 25) | | 0 |
| lignes à p Monte-Carlo changée | | Stabilite du facteur selon la ponderation (famille alpha) (0,008 → 0,007) |
| `stats_boot` : colonne Alpha identical() ; 12 autres colonnes identical() | | FALSE ; TRUE |
| σ_boot (moyenne ; q05 ; q50 ; q95) | 0,0178843 ; 0,0133401 ; 0,0178698 ; 0,0222821 | 0,0178808 ; 0,0133379 ; 0,0178413 ; 0,0223113 |
| σ_boot, écart relatif après / avant − 1 | | -0,019 % ; -0,016 % ; -0,159 % ; +0,131 % (identical : FALSE) |
| `ic_bootstrap` (2.5% ; 5% ; 50% ; 95% ; 97.5%) | 0,0443931 ; 0,0447706 ; 0,0474432 ; 0,0500465 ; 0,0505636 | 0,0444099 ; 0,0447694 ; 0,0474264 ; 0,0500637 ; 0,0505205 |
| `ic_bootstrap`, écart relatif | | +0,038 % ; -0,003 % ; -0,035 % ; +0,034 % ; -0,085 % (identical : FALSE) |
| B effectif d'Alpha ; triangle retiré (`cumuls_retires`) | 999 ; FALSE | 999 ; FALSE |
| Prototype Vb (moteur d'origine, seam substitué) contre moteur modifié : objet identical() hors `tests[[20]]$detail` et `plots_data$usage_sigma` | | TRUE |
| p d'Alpha sous Vb ; moteur modifié | | 0,007 ; 0,007 |

#### T2, graine 20260831

| Grandeur | Avant | Après |
| --- | --- | --- |
| ok | TRUE | TRUE |
| σ_USP | 0,04948541798 | 0,04948541798 |
| σ_USP, `parametre` et `parametre_final` identical() | TRUE | |
| `ajustement`, `msep`, `residus`, `bootstrap$stats_obs` identical() | TRUE | |
| p Monte-Carlo d'Alpha (p retenue) | 0,023 (0,023) | 0,010 (0,010) |
| verdict d'Alpha à α = 0,10 | ECHEC | ECHEC |
| α saisi où le verdict d'Alpha diffère | | ]0,010 ; 0,046] |
| p de famille M1 | 0,019 | 0,019 |
| p globale (LC) | 0,022 | 0,023 |
| lignes à verdict changé à α = 0,10 (sur 25) | | 0 |
| lignes à p Monte-Carlo changée | | Stabilite du facteur selon la ponderation (famille alpha) (0,023 → 0,010) ; p globale (minP, lecture conjointe de la batterie) (0,022 → 0,023) |
| `stats_boot` : colonne Alpha identical() ; 12 autres colonnes identical() | | FALSE ; TRUE |
| σ_boot (moyenne ; q05 ; q50 ; q95) | 0,0192005 ; 0,0132778 ; 0,0193767 ; 0,0245937 | 0,0191996 ; 0,0132815 ; 0,0193727 ; 0,0246055 |
| σ_boot, écart relatif après / avant − 1 | | -0,005 % ; +0,028 % ; -0,021 % ; +0,048 % (identical : FALSE) |
| `ic_bootstrap` (2.5% ; 5% ; 50% ; 95% ; 97.5%) | 0,0441099 ; 0,0447339 ; 0,0483323 ; 0,0514103 ; 0,052059 | 0,0440793 ; 0,0447361 ; 0,0483299 ; 0,0514172 ; 0,0519318 |
| `ic_bootstrap`, écart relatif | | -0,069 % ; +0,005 % ; -0,005 % ; +0,014 % ; -0,244 % (identical : FALSE) |
| B effectif d'Alpha ; triangle retiré (`cumuls_retires`) | 999 ; FALSE | 999 ; FALSE |
| Prototype Vb (moteur d'origine, seam substitué) contre moteur modifié : objet identical() hors `tests[[20]]$detail` et `plots_data$usage_sigma` | | TRUE |
| p d'Alpha sous Vb ; moteur modifié | | 0,010 ; 0,010 |

#### T3, graine 20260831

| Grandeur | Avant | Après |
| --- | --- | --- |
| ok | TRUE | TRUE |
| σ_USP | 0,04670611595 | 0,04670611595 |
| σ_USP, `parametre` et `parametre_final` identical() | TRUE | |
| `ajustement`, `msep`, `residus`, `bootstrap$stats_obs` identical() | TRUE | |
| p Monte-Carlo d'Alpha (p retenue) | 0,004 (0,004) | 0,004 (0,004) |
| verdict d'Alpha à α = 0,10 | ECHEC | ECHEC |
| α saisi où le verdict d'Alpha diffère | | aucun (p égales) |
| p de famille M1 | 0,017 | 0,017 |
| p globale (LC) | 0,042 | 0,042 |
| lignes à verdict changé à α = 0,10 (sur 25) | | 0 |
| lignes à p Monte-Carlo changée | | aucune |
| `stats_boot` : colonne Alpha identical() ; 12 autres colonnes identical() | | TRUE ; TRUE |
| σ_boot (moyenne ; q05 ; q50 ; q95) | 0,0165398 ; 0,0127605 ; 0,0166048 ; 0,0200002 | 0,0165398 ; 0,0127755 ; 0,0165982 ; 0,0199846 |
| σ_boot, écart relatif après / avant − 1 | | -0,000 % ; +0,117 % ; -0,039 % ; -0,078 % (identical : FALSE) |
| `ic_bootstrap` (2.5% ; 5% ; 50% ; 95% ; 97.5%) | 0,0440319 ; 0,0444287 ; 0,0466968 ; 0,0487001 ; 0,0489718 | 0,0440276 ; 0,0444375 ; 0,046693 ; 0,0486909 ; 0,0489815 |
| `ic_bootstrap`, écart relatif | | -0,010 % ; +0,020 % ; -0,008 % ; -0,019 % ; +0,020 % (identical : FALSE) |
| B effectif d'Alpha ; triangle retiré (`cumuls_retires`) | 999 ; FALSE | 999 ; FALSE |
| Prototype Vb (moteur d'origine, seam substitué) contre moteur modifié : objet identical() hors `tests[[20]]$detail` et `plots_data$usage_sigma` | | TRUE |
| p d'Alpha sous Vb ; moteur modifié | | 0,004 ; 0,004 |

#### T1, graine secondaire 20261125

| Grandeur | Avant | Après |
| --- | --- | --- |
| ok | TRUE | TRUE |
| σ_USP | 0,04757970671 | 0,04757970671 |
| σ_USP, `parametre` et `parametre_final` identical() | TRUE | |
| `ajustement`, `msep`, `residus`, `bootstrap$stats_obs` identical() | TRUE | |
| p Monte-Carlo d'Alpha (p retenue) | 0,008 (0,008) | 0,005 (0,005) |
| verdict d'Alpha à α = 0,10 | ECHEC | ECHEC |
| α saisi où le verdict d'Alpha diffère | | ]0,005 ; 0,008] ∪ ]0,010 ; 0,016] |
| p de famille M1 | 0,010 | 0,010 |
| p globale (LC) | 0,021 | 0,021 |
| lignes à verdict changé à α = 0,10 (sur 25) | | 0 |
| lignes à p Monte-Carlo changée | | Stabilite du facteur selon la ponderation (famille alpha) (0,008 → 0,005) |
| `stats_boot` : colonne Alpha identical() ; 12 autres colonnes identical() | | FALSE ; TRUE |
| σ_boot (moyenne ; q05 ; q50 ; q95) | 0,0180997 ; 0,013635 ; 0,018069 ; 0,0226171 | 0,0180965 ; 0,0135993 ; 0,0181119 ; 0,0225297 |
| σ_boot, écart relatif après / avant − 1 | | -0,017 % ; -0,262 % ; +0,237 % ; -0,386 % (identical : FALSE) |
| `ic_bootstrap` (2.5% ; 5% ; 50% ; 95% ; 97.5%) | 0,0444888 ; 0,0449447 ; 0,0475607 ; 0,0502441 ; 0,0508236 | 0,0444635 ; 0,0449236 ; 0,047586 ; 0,0501926 ; 0,0507724 |
| `ic_bootstrap`, écart relatif | | -0,057 % ; -0,047 % ; +0,053 % ; -0,103 % ; -0,101 % (identical : FALSE) |
| B effectif d'Alpha ; triangle retiré (`cumuls_retires`) | 999 ; FALSE | 999 ; FALSE |
| Prototype Vb (moteur d'origine, seam substitué) contre moteur modifié : objet identical() hors `tests[[20]]$detail` et `plots_data$usage_sigma` | | TRUE |
| p d'Alpha sous Vb ; moteur modifié | | 0,005 ; 0,005 |

#### T2, graine secondaire 20261125

| Grandeur | Avant | Après |
| --- | --- | --- |
| ok | TRUE | TRUE |
| σ_USP | 0,04948541798 | 0,04948541798 |
| σ_USP, `parametre` et `parametre_final` identical() | TRUE | |
| `ajustement`, `msep`, `residus`, `bootstrap$stats_obs` identical() | TRUE | |
| p Monte-Carlo d'Alpha (p retenue) | 0,023 (0,023) | 0,006 (0,006) |
| verdict d'Alpha à α = 0,10 | ECHEC | ECHEC |
| α saisi où le verdict d'Alpha diffère | | ]0,006 ; 0,046] |
| p de famille M1 | 0,009 | 0,009 |
| p globale (LC) | 0,008 | 0,008 |
| lignes à verdict changé à α = 0,10 (sur 25) | | 0 |
| lignes à p Monte-Carlo changée | | Stabilite du facteur selon la ponderation (famille alpha) (0,023 → 0,006) |
| `stats_boot` : colonne Alpha identical() ; 12 autres colonnes identical() | | FALSE ; TRUE |
| σ_boot (moyenne ; q05 ; q50 ; q95) | 0,0193223 ; 0,0137439 ; 0,0195646 ; 0,0243603 | 0,0193156 ; 0,0137423 ; 0,0195341 ; 0,0243571 |
| σ_boot, écart relatif après / avant − 1 | | -0,035 % ; -0,012 % ; -0,156 % ; -0,013 % (identical : FALSE) |
| `ic_bootstrap` (2.5% ; 5% ; 50% ; 95% ; 97.5%) | 0,044575 ; 0,0450089 ; 0,0484431 ; 0,0512726 ; 0,0517011 | 0,0445682 ; 0,045008 ; 0,0484251 ; 0,0512707 ; 0,0516516 |
| `ic_bootstrap`, écart relatif | | -0,015 % ; -0,002 % ; -0,037 % ; -0,004 % ; -0,096 % (identical : FALSE) |
| B effectif d'Alpha ; triangle retiré (`cumuls_retires`) | 999 ; FALSE | 999 ; FALSE |
| Prototype Vb (moteur d'origine, seam substitué) contre moteur modifié : objet identical() hors `tests[[20]]$detail` et `plots_data$usage_sigma` | | TRUE |
| p d'Alpha sous Vb ; moteur modifié | | 0,006 ; 0,006 |

## 4. Critère 1 : Δp = 0 contre le prototype Vb

Sur les huit triangles et les deux graines de T1 et T2, l'objet rendu par le moteur modifié est `identical()` à celui du prototype Vb **hors deux feuilles**, `tests[[20]]$detail` (mention M6) et `plots_data$usage_sigma`, sur T0 à T3 ; il lui est `identical()` en entier sur K1, KA, R2 et R2T. Ces deux feuilles sont l'artefact connu du prototype (§ 3.2 de la spécification) : sous Vb, `.mw_cas_sigma_direct()` lisait le seam et rendait « simulation » ; le moteur modifié lit `.mw_colonne_degeneree()` et rend « degenere » (point obligatoire du § 4.3 de la lecture). Les p d'Alpha du moteur sont celles de Vb : 0,016 ; 0,007 ; 0,010 ; 0,004 (T0 à T3), 0,005 et 0,006 (graine secondaire).

Rejeu de `mesure_620.R` en mode adapté (copie hors dépôt dont seuls changent `MD5_ENGINE_ATTENDU`, posé à `105949ad…`, et l'exigence d'un `git status` vide dans I3 ; B = 999, graines 20260831 et 20261125, 614,7 s, code 0) :
- Gb1 à Gb4 et Ga1 à Ga4 : OK ; « Vb : res identical a V0 : OK » sur les huit triangles (sous le moteur modifié, substituer le seam par le corps de Vb ne change plus rien, textes compris) ;
- synthèse : p d'Alpha sous V0 = Vb = p_sans = 0,016 ; 0,007 ; 0,010 (T0, T1, T2) ; M1 et LC sous V0 égales à celles de Vb de la sortie versée (0,056 / 0,111 ; 0,015 / 0,027 ; 0,019 / 0,023) ; M-h identique à la sortie versée pour Vb ;
- R0 **rouge par I4 seul** (T1, T2) : I4 contrôle la reproduction des p du moteur d'avant (0,008 et 0,023), celles du défaut corrigé ; I1, I2, I3 (md5), I5 (références `reserve2` et `reserve2_trapeze` conformes), I6 à I9 : OK. Attendu.

## 5. Textes restitués du cas « degenere » (T0 à T3)

Mention M6 (fin du `detail` de « Extrapolation de sigma pour la derniere annee de developpement »), exemple de T1 :

- avant : `... Trapeze (I > J) : la regle de minimum s'applique a sigma2_(J-1) par prescription de l'annexe XVII, D(5)(d)(ii), seconde ligne, bien que la colonne J-1 porte 3 facteurs, dont l'estimateur direct vaut 0 a 2 degre(s) de liberte ; cette colonne etant degeneree (voir l'avertissement sur les donnees), aucun de ses residus n'est retenu (tests, influence, vivier du bootstrap) et l'estimateur n'entre ni dans la MSEP ni dans la simulation : valeur donnee pour information.`
- après : `... Trapeze (I > J) : la regle de minimum s'applique a sigma2_(J-1) par prescription de l'annexe XVII, D(5)(d)(ii), seconde ligne, bien que la colonne J-1 porte 3 facteurs, dont l'estimateur direct vaut 0 a 2 degre(s) de liberte ; cette colonne etant degeneree (voir l'avertissement sur les donnees), aucun de ses residus n'est retenu (tests, influence, vivier du bootstrap). Par convention de l'outil, non reglementaire, l'estimateur direct sert a simuler la colonne J-1 des triangles tires par le bootstrap ; il n'entre ni dans la MSEP ni dans sigma(res,s,USP) : valeur donnee pour information.`

`plots_data$usage_sigma` :

| Élément | Avant | Après |
| --- | --- | --- |
| `sigma` | sigma_(J-1) de la regle de minimum (D(5)(d)(ii)) : MSEP et simulation | sigma_(J-1) regle de minimum : MSEP, sigma_USP, replications |
| `sigma_residus` | sigma_(J-1) estime directement : colonne degeneree, sans residu | sigma_(J-1) direct : colonne degeneree, sans residu ; simulation (convention) |

Textes du § 4.3 de la lecture repris à l'identique (vérifié par `identical()` sur la chaîne du gabarit et les deux légendes).

## 6. Explication

Sous l'état d'avant (annotation du 25/11/2026 de l'ADR 0005), la colonne J−1 dégénérée d'un trapèze était simulée avec la valeur de la règle de minimum : non négligeable sur T1, T2, T3 (0,142 ; 0,684 ; 0,030), elle rendait la colonne dispersée dans les réplications, alors que son amplitude observée est nulle. Sous (b), elle est simulée avec l'estimateur direct, nul sur T1 à T3 et 1,2·10⁻²⁸ sur T0 : la colonne reste dégénérée dans chaque réplication (constat de la mesure, Gb4, 999 sur 999 ; assertion unitaire sur un 8 × 6 à B = 99). D'où :
- la colonne Alpha de `stats_boot` change (T0, T1, T2 ; sur T3 la colonne J−1 n'a que 2 facteurs et n'entre pas dans A : colonne Alpha `identical`), et la p d'Alpha baisse sur T1 et T2 jusqu'à la p sans la colonne (exact sous V0 : p ≥ p_sans ; sous (b), égalité à la tolérance près, constat 0 discordance) ;
- les 12 autres colonnes de `stats_boot` sont `identical()` (aucun triangle retiré, mêmes appels à `sample()`) ;
- σ_boot et `ic_bootstrap` changent par le σ* des réplications, recalculé sur des triangles dont la colonne J−1 diffère ; l'intervalle est atténué par le mélange de crédibilité ; grandeur dépendant de la graine : jusqu'à 0,16 % (σ_boot) et 0,24 % (intervalle) à la graine 20260831, 0,39 % et 0,10 % à la graine 20261125 ;
- la p globale de T2 change d'un compte (0,022 → 0,023) par les rangs d'Alpha dans minP ; sens non garanti, très inférieur à l'erreur de Monte-Carlo (≈ 0,0046) ;
- σ_USP ne change pas (exact).

Nature : p de Monte-Carlo d'un bootstrap semi-paramétrique, non exacte ; écarts appariés (mêmes tirages), dont le sens est exact et la grandeur dépend de la graine (T2 : 13/1000 à la graine principale, 17/1000 à la graine secondaire). Aucun théorème ne couvre cette p à T = 8 ; niveau du test dans le cas dégénéré non mesuré.

## Annexe : script de comparaison (hors dépôt)

`comparer_vb.R`, md5 `df762e699e568a808934c729226dc5c4`. Ce md5, cité aussi en tête du tableau, est celui du script exécuté pour la mesure. Le texte reproduit ci-dessous en diffère par un seul commentaire, corrigé après la mesure : il citait « (l. 231) » au lieu de « (l. 226) » pour la ligne de `sim_direct_vb` dans `mesure_620.R`.

```r
# Comparaison : moteur d'origine (36e2041) sous le prototype Vb de mesure_620.R
# contre moteur modifie (V0), et moteur d'origine V0 contre moteur modifie
# (tableau avant / apres). Lancer depuis la racine du depot.
SCR <- "/tmp/claude-0/-home-user-outil-usp/a5d4dadf-ccb2-5434-955a-3a8e6b59d300/scratchpad"
B <- as.integer(Sys.getenv("B_CMP", "999"))
source("R/charger_moteur.R")
m_old <- charger_moteur(file.path(SCR, "avant", "engine.R"), dans = NULL)
m_new <- charger_moteur("R/engine.R", dans = NULL)
cat("md5 avant :", tools::md5sum(file.path(SCR, "avant", "engine.R")), "\n")
cat("md5 apres :", tools::md5sum("R/engine.R"), "\n")

# Triangles : construction recopiee de mesure_620.R (l. 150-191), sur le moteur d'origine.
local({
  env <- m_old
  lire_csv_triangle <- function(fichier) {
    df <- utils::read.csv(file.path("tests", "donnees", fichier))
    m <- as.matrix(df[, setdiff(names(df), "i")]); storage.mode(m) <- "double"; unname(m)
  }
  degenerer_derniere <- function(tri) {
    aj <- env$mw_ajuster(tri); I <- aj$I; J <- aj$J
    for (i in 0:(I - J)) tri[i + 1, J + 1] <- tri[i + 1, J] * aj$f[J]
    tri
  }
  degenerer_colonne <- function(tri, j) {
    aj <- env$mw_ajuster(tri); fj <- aj$f[j + 1]; nc <- ncol(tri)
    for (i in 0:(aj$I - j - 1)) {
      r <- fj * tri[i + 1, j + 1] / tri[i + 1, j + 2]
      tri[i + 1, (j + 2):nc] <- tri[i + 1, (j + 2):nc] * r
    }
    tri
  }
  tri_trap <- lire_csv_triangle("triangle_mw_trapeze.csv")
  tri_mw   <- lire_csv_triangle("triangle_mw.csv")
  T1 <- degenerer_derniere(tri_trap)
  T2 <- degenerer_derniere(tri_mw[, 1:5])
  T0 <- degenerer_colonne(T1, 2L)
  T3 <- degenerer_derniere(tri_mw[, 1:7])
  K1 <- degenerer_colonne(tri_mw, 2L)
  KA <- tri_mw
  for (j in 0:4) KA <- degenerer_colonne(KA, j)
  TRIS <<- list(T0 = T0, T1 = T1, T2 = T2, T3 = T3, K1 = K1, KA = KA, R2 = tri_mw, R2T = tri_trap)
})

nettoyer <- function(res) {
  if (is.list(res$metadata)) res$metadata[c("horodatage", "duree_sec", "version_R")] <- NULL
  res
}
appel <- function(m, tri, graine) nettoyer(m$run_engine(methode = "reserve2", triangle = tri,
  segment = 1, annexe = "II", date_reference = "2026-12-31", B = B, seed = graine))

# Prototype Vb : corps de sim_direct_vb de mesure_620.R (l. 226).
sim_direct_vb <- function(aj) !is.null(aj[["sigma2_Jm1_direct"]])
environment(sim_direct_vb) <- m_old
orig_seam <- get(".mw_simulation_sigma_direct", envir = m_old, inherits = FALSE)
appel_vb <- function(tri, graine) {
  assign(".mw_simulation_sigma_direct", sim_direct_vb, envir = m_old)
  on.exit(assign(".mw_simulation_sigma_direct", orig_seam, envir = m_old))
  appel(m_old, tri, graine)
}

# Chemins des feuilles differentes (structure recursive).
diff_chemins <- function(a, b, ch = "") {
  if (identical(a, b)) return(character(0))
  if (is.list(a) && is.list(b) && !is.data.frame(a) && length(a) == length(b) &&
      identical(names(a), names(b))) {
    nm <- if (is.null(names(a))) as.character(seq_along(a)) else names(a)
    return(unlist(lapply(seq_along(a), function(k) diff_chemins(a[[k]], b[[k]], paste0(ch, "$", nm[k])))))
  }
  ch
}
nom_test <- function(res, ch) {
  m <- regmatches(ch, regexec("^\\$tests\\$([0-9]+)", ch))[[1]]
  if (length(m) == 2) paste0(ch, "  [", res$tests[[as.integer(m[2])]]$test, "]") else ch
}

RES <- list()
cas <- list()
for (nm in names(TRIS)) cas[[length(cas) + 1]] <- list(nm = nm, g = 20260831)
for (nm in c("T1", "T2")) cas[[length(cas) + 1]] <- list(nm = nm, g = 20261125)
for (k in cas) {
  cle <- paste0(k$nm, "_", k$g)
  t0 <- Sys.time()
  r_old <- appel(m_old, TRIS[[k$nm]], k$g)
  r_vb  <- appel_vb(TRIS[[k$nm]], k$g)
  r_new <- appel(m_new, TRIS[[k$nm]], k$g)
  stopifnot(identical(get(".mw_simulation_sigma_direct", envir = m_old, inherits = FALSE), orig_seam))
  RES[[cle]] <- list(old = r_old, vb = r_vb, new = r_new)
  d_vb <- diff_chemins(r_vb, r_new)
  d_old <- diff_chemins(r_old, r_new)
  cat(sprintf("\n=== %s (graine %d) : %.1f s ===\n", k$nm, k$g, as.numeric(difftime(Sys.time(), t0, units = "secs"))))
  cat("  Vb(origine) contre moteur modifie : identical =", identical(r_vb, r_new),
      "; feuilles differentes :", length(d_vb), "\n")
  for (ch in d_vb) cat("    ", nom_test(r_new, ch), "\n")
  cat("  V0(origine) contre moteur modifie : identical =", identical(r_old, r_new),
      "; feuilles differentes :", length(d_old), "\n")
  for (ch in d_old) cat("    ", nom_test(r_new, ch), "\n")
}
saveRDS(RES, file.path(SCR, "comparer_vb_res.rds"))
cat("\nFIN\n")
```
