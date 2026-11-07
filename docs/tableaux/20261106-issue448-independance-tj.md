## Indépendance des t_j et loi des p-values de l'ordonnée à l'origine et de la courbure (M1) à T = 8, modèle de Mack gaussien (issue #448)

Statut : **constat de simulation sous un plan** (modèle de Mack gaussien ajusté à `reserve2`, plans P1 à P3 de #309), de compatibilité avec le résultat « p χ²(2K) exacte sous erreurs conditionnelles gaussiennes et années indépendantes » des fiches `mw:m1a` et `mw:m1c`, **pas une démonstration** ni un résultat général. Aucun bootstrap : les p lues sont les p χ²(2K) de la combinaison de Fisher du moteur (`mw_test_ordonnee_origine()`, `mw_test_courbure()`), les t_j et p_j sont lus dans leur tableau `detail`.

### En-tête

| Paramètre | Valeur |
| --- | --- |
| Date | 06/11/2026 |
| Plan | plan d'`actuary`, accepté par le mainteneur le 06/11/2026 (issue #448) ; script `tests/mesure_independance_tj_t8.R` |
| Commit | `2964d1fcd3f8e77bd47b28baadcdf6ce11e19b8b (script non suivi)` — exécution sur un arbre de travail non propre ou un script non encore suivi ; le md5 du script ci-dessous identifie le code exécuté |
| md5 du script | `6f84bc4648e53b6252dbde4dfb12e756` |
| md5 de `R/engine.R` | `e32a375ad3b0635d1526dbf1a12af6f7` |
| Plateforme | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : libblas.so.3.12.0 ; LAPACK : liblapack.so.3.12.0 (version 3.12.0) |
| Locale | C.UTF-8 |
| Générateur | `engine_sous_graine()`, `ENGINE_RNG_KIND` = Mersenne-Twister, Inversion, Rejection |
| Graines | une par triangle : `448000000 + 1000000 k + b`, k = 1, 2, 3 pour P1, P2, P3, b = 1..N (plage 449 000 001 à 451 100 000) ; essai pilote : k = 0, b ≤ 2 000 ; aucun autre aléa |
| N | 100 000 triangles tirés par plan, 300 000 au total |
| Durée | calcul : 22,6 min (3 cœur(s), `parallel::mclapply`, blocs de 2 500 triangles) ; exécution complète : 22,7 min ; le résultat ne dépend pas du nombre de cœurs (graine par triangle) |
| Modèle générateur | Mack gaussien ajusté à `reserve2` (`mw_ajuster()` sur `tests/donnees/triangle_mw.csv`), I = J = 7 ; f̂ = (3,203722 ; 1,651754 ; 1,325245 ; 1,150424 ; 1,094687 ; 1,064551 ; 1,028407) ; σ̂² = (0,7240 ; 0,7121 ; 0,6981 ; 0,3148 ; 0,0973 ; 0,1897 ; 0,0973), non réestimés ; générateur `gen_triangle_h0()` (copie déclarée de `tests/puissance_mw_t8.R`), ε ~ N(0, 1) par `stats::rnorm` ; triangle à cumul ≤ 0 compté puis écarté |
| Plans (première colonne fixée, lignes 0..7) | P1 = (300,0000 ; 311,4286 ; 322,8571 ; 334,2857 ; 345,7143 ; 357,1429 ; 368,5714 ; 380,0000) ; P2 = C̄₀ + 3,4 (C₀ − C̄₀) = (204,0000 ; 242,8571 ; 281,7143 ; 320,5714 ; 359,4286 ; 398,2857 ; 437,1429 ; 476,0000) ; P3 = P2[c(2, 8, 6, 4, 3, 5, 7, 1)] = (242,8571 ; 476,0000 ; 398,2857 ; 320,5714 ; 281,7143 ; 359,4286 ; 437,1429 ; 204,0000) |
| Lignes | ordonnée à l'origine : colonnes j = 0..4 (n_j = 7..3), K = 5, t_j ~ Student(n_j − 2) ; courbure : colonnes j = 0..3 (n_j = 7..4), K = 4, t_j ~ Student(n_j − 3) |
| Contrôle des degrés de liberté | p_j du moteur ↔ 2 P(T_df > abs t_j), df = n_j − 2 (ordonnée) ou n_j − 3 (courbure) : écart absolu maximal 0,00e+00 sur les six (plan, ligne), tolérance 1e-09 : tenu |

### Critères, fixés avant l'exécution

- Niveau 0,05/m par contrôle ; m = 3 (taux) + 1 (KS de p) + K (KS des t_j) + K(K − 1) (Spearman sur t et sur |t|, K(K − 1)/2 paires chacun) : m = 29 pour l'ordonnée (K = 5), m = 20 pour la courbure (K = 4) ; m est recalculé sur le K le plus fréquent mesuré et signalé s'il diffère.
- Un taux est compatible si l'intervalle de Clopper–Pearson de niveau 1 − 0,05/m contient α (0,10 ; 0,05 ; 0,01).
- Un KS (p contre U(0, 1) ; chaque t_j contre sa Student, par la transformation pt(t_j, df)) est compatible si sa p-value est ≥ 0,05/m ; p-value asymptotique de `ks.test()` (n > 100).
- Une corrélation de Spearman est compatible si |ρ| ≤ z₁₋₀,₀₂₅/ₘ / √(n − 1), n = triangles admis portant les deux colonnes.
- Le critère est tenu si aucun contrôle ne rejette. C'est un constat de compatibilité, pas une démonstration.

### Synthèse

| Plan | Ligne | Admis | K le plus fréquent | m | Taux à 0,10 / 0,05 / 0,01 | KS de p (p-value) | max abs ρ(t) (seuil) | max abs ρ(abs t) (seuil) | Contrôles rejetés | Critère |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P1 | ordonnée à l'origine | 100 000 | 5 | 29 | 0,1005 / 0,0497 / 0,0103 | 0,6953 | 0,0077 (0,0099) | 0,0068 (0,0099) | 0 | **tenu** |
| P1 | courbure | 100 000 | 4 | 20 | 0,0993 / 0,0496 / 0,0097 | 0,3471 | 0,0038 (0,0096) | 0,0040 (0,0096) | 0 | **tenu** |
| P2 | ordonnée à l'origine | 100 000 | 5 | 29 | 0,1006 / 0,0505 / 0,0103 | 0,3669 | 0,0054 (0,0099) | 0,0092 (0,0099) | 0 | **tenu** |
| P2 | courbure | 100 000 | 4 | 20 | 0,1000 / 0,0498 / 0,0097 | 0,1573 | 0,0055 (0,0096) | 0,0058 (0,0096) | 0 | **tenu** |
| P3 | ordonnée à l'origine | 100 000 | 5 | 29 | 0,1007 / 0,0489 / 0,0098 | 0,2078 | 0,0051 (0,0099) | 0,0048 (0,0099) | 0 | **tenu** |
| P3 | courbure | 100 000 | 4 | 20 | 0,0997 / 0,0498 / 0,0098 | 0,7578 | 0,0071 (0,0096) | 0,0044 (0,0096) | 0 | **tenu** |

Critère tenu pour 6 des 6 couples (plan, ligne).

### P1 — ordonnée à l'origine

Triangles tirés : 100 000 ; écartés, cumul ≤ 0 : 0 ; écartés, ajustement en erreur : 0 ; statistique de la ligne non définie : 0 ; **admis : 100 000**. Répartition de K : K = 5 : 100 000 (100,00 %). K le plus fréquent : 5 (prévu : 5) ; m = 29, niveau par contrôle 0,05/m = 1,72e-03.

| Contrôle | Observé | Référence (niveau 1 − 0,05/m) | Compatible |
| --- | --- | --- | --- |
| taux de rejet de la p χ²(2K) à 0,10 | 10 052 / 100 000 = 0,10052 | Clopper–Pearson [0,09756 ; 0,10353] ∋ 0,10 | oui |
| taux de rejet de la p χ²(2K) à 0,05 | 4 970 / 100 000 = 0,04970 | Clopper–Pearson [0,04757 ; 0,05189] ∋ 0,05 | oui |
| taux de rejet de la p χ²(2K) à 0,01 | 1 034 / 100 000 = 0,01034 | Clopper–Pearson [0,00937 ; 0,01138] ∋ 0,01 | oui |
| KS de p contre U(0, 1) | D = 0,00224, p = 0,6953 | p ≥ 1,72e-03 | oui |
| KS de t_0 contre Student(5) (n_j = 7) | D = 0,00200, p = 0,8197 | p ≥ 1,72e-03 | oui |
| KS de t_1 contre Student(4) (n_j = 6) | D = 0,00283, p = 0,4019 | p ≥ 1,72e-03 | oui |
| KS de t_2 contre Student(3) (n_j = 5) | D = 0,00146, p = 0,9838 | p ≥ 1,72e-03 | oui |
| KS de t_3 contre Student(2) (n_j = 4) | D = 0,00208, p = 0,7787 | p ≥ 1,72e-03 | oui |
| KS de t_4 contre Student(1) (n_j = 3) | D = 0,00278, p = 0,4228 | p ≥ 1,72e-03 | oui |
| Spearman, 10 paires : max abs ρ(t_j, t_k) | 0,00767 (paire (1, 2)) | seuil 0,00991 ; paires hors seuil : 0 | oui |
| Spearman, 10 paires : max abs ρ(abs t_j, abs t_k) | 0,00677 (paire (1, 4)) | seuil 0,00991 ; paires hors seuil : 0 | oui |

Contrôle des degrés de liberté (hors critère) : écart absolu maximal entre p_j du moteur et 2 P(T_df > |t_j|), df = n_j − 2 : 0,00e+00.

**Critère tenu** (0 contrôle(s) rejeté(s) sur 29).

### P1 — courbure

Triangles tirés : 100 000 ; écartés, cumul ≤ 0 : 0 ; écartés, ajustement en erreur : 0 ; statistique de la ligne non définie : 0 ; **admis : 100 000**. Répartition de K : K = 4 : 100 000 (100,00 %). K le plus fréquent : 4 (prévu : 4) ; m = 20, niveau par contrôle 0,05/m = 2,50e-03.

| Contrôle | Observé | Référence (niveau 1 − 0,05/m) | Compatible |
| --- | --- | --- | --- |
| taux de rejet de la p χ²(2K) à 0,10 | 9 933 / 100 000 = 0,09933 | Clopper–Pearson [0,09649 ; 0,10222] ∋ 0,10 | oui |
| taux de rejet de la p χ²(2K) à 0,05 | 4 965 / 100 000 = 0,04965 | Clopper–Pearson [0,04760 ; 0,05176] ∋ 0,05 | oui |
| taux de rejet de la p χ²(2K) à 0,01 | 973 / 100 000 = 0,00973 | Clopper–Pearson [0,00882 ; 0,01071] ∋ 0,01 | oui |
| KS de p contre U(0, 1) | D = 0,00295, p = 0,3471 | p ≥ 2,50e-03 | oui |
| KS de t_0 contre Student(4) (n_j = 7) | D = 0,00292, p = 0,3607 | p ≥ 2,50e-03 | oui |
| KS de t_1 contre Student(3) (n_j = 6) | D = 0,00200, p = 0,8197 | p ≥ 2,50e-03 | oui |
| KS de t_2 contre Student(2) (n_j = 5) | D = 0,00155, p = 0,9706 | p ≥ 2,50e-03 | oui |
| KS de t_3 contre Student(1) (n_j = 4) | D = 0,00328, p = 0,2334 | p ≥ 2,50e-03 | oui |
| Spearman, 6 paires : max abs ρ(t_j, t_k) | 0,00375 (paire (0, 3)) | seuil 0,00956 ; paires hors seuil : 0 | oui |
| Spearman, 6 paires : max abs ρ(abs t_j, abs t_k) | 0,00403 (paire (0, 2)) | seuil 0,00956 ; paires hors seuil : 0 | oui |

Contrôle des degrés de liberté (hors critère) : écart absolu maximal entre p_j du moteur et 2 P(T_df > |t_j|), df = n_j − 3 : 0,00e+00.

**Critère tenu** (0 contrôle(s) rejeté(s) sur 20).

### P2 — ordonnée à l'origine

Triangles tirés : 100 000 ; écartés, cumul ≤ 0 : 0 ; écartés, ajustement en erreur : 0 ; statistique de la ligne non définie : 0 ; **admis : 100 000**. Répartition de K : K = 5 : 100 000 (100,00 %). K le plus fréquent : 5 (prévu : 5) ; m = 29, niveau par contrôle 0,05/m = 1,72e-03.

| Contrôle | Observé | Référence (niveau 1 − 0,05/m) | Compatible |
| --- | --- | --- | --- |
| taux de rejet de la p χ²(2K) à 0,10 | 10 064 / 100 000 = 0,10064 | Clopper–Pearson [0,09768 ; 0,10365] ∋ 0,10 | oui |
| taux de rejet de la p χ²(2K) à 0,05 | 5 048 / 100 000 = 0,05048 | Clopper–Pearson [0,04834 ; 0,05269] ∋ 0,05 | oui |
| taux de rejet de la p χ²(2K) à 0,01 | 1 027 / 100 000 = 0,01027 | Clopper–Pearson [0,00930 ; 0,01131] ∋ 0,01 | oui |
| KS de p contre U(0, 1) | D = 0,00291, p = 0,3669 | p ≥ 1,72e-03 | oui |
| KS de t_0 contre Student(5) (n_j = 7) | D = 0,00316, p = 0,2697 | p ≥ 1,72e-03 | oui |
| KS de t_1 contre Student(4) (n_j = 6) | D = 0,00263, p = 0,4927 | p ≥ 1,72e-03 | oui |
| KS de t_2 contre Student(3) (n_j = 5) | D = 0,00239, p = 0,6178 | p ≥ 1,72e-03 | oui |
| KS de t_3 contre Student(2) (n_j = 4) | D = 0,00246, p = 0,5811 | p ≥ 1,72e-03 | oui |
| KS de t_4 contre Student(1) (n_j = 3) | D = 0,00178, p = 0,9091 | p ≥ 1,72e-03 | oui |
| Spearman, 10 paires : max abs ρ(t_j, t_k) | 0,00537 (paire (1, 3)) | seuil 0,00991 ; paires hors seuil : 0 | oui |
| Spearman, 10 paires : max abs ρ(abs t_j, abs t_k) | 0,00922 (paire (2, 4)) | seuil 0,00991 ; paires hors seuil : 0 | oui |

Contrôle des degrés de liberté (hors critère) : écart absolu maximal entre p_j du moteur et 2 P(T_df > |t_j|), df = n_j − 2 : 0,00e+00.

**Critère tenu** (0 contrôle(s) rejeté(s) sur 29).

### P2 — courbure

Triangles tirés : 100 000 ; écartés, cumul ≤ 0 : 0 ; écartés, ajustement en erreur : 0 ; statistique de la ligne non définie : 0 ; **admis : 100 000**. Répartition de K : K = 4 : 100 000 (100,00 %). K le plus fréquent : 4 (prévu : 4) ; m = 20, niveau par contrôle 0,05/m = 2,50e-03.

| Contrôle | Observé | Référence (niveau 1 − 0,05/m) | Compatible |
| --- | --- | --- | --- |
| taux de rejet de la p χ²(2K) à 0,10 | 10 000 / 100 000 = 0,10000 | Clopper–Pearson [0,09715 ; 0,10290] ∋ 0,10 | oui |
| taux de rejet de la p χ²(2K) à 0,05 | 4 982 / 100 000 = 0,04982 | Clopper–Pearson [0,04776 ; 0,05193] ∋ 0,05 | oui |
| taux de rejet de la p χ²(2K) à 0,01 | 974 / 100 000 = 0,00974 | Clopper–Pearson [0,00883 ; 0,01072] ∋ 0,01 | oui |
| KS de p contre U(0, 1) | D = 0,00357, p = 0,1573 | p ≥ 2,50e-03 | oui |
| KS de t_0 contre Student(4) (n_j = 7) | D = 0,00232, p = 0,6570 | p ≥ 2,50e-03 | oui |
| KS de t_1 contre Student(3) (n_j = 6) | D = 0,00328, p = 0,2332 | p ≥ 2,50e-03 | oui |
| KS de t_2 contre Student(2) (n_j = 5) | D = 0,00216, p = 0,7373 | p ≥ 2,50e-03 | oui |
| KS de t_3 contre Student(1) (n_j = 4) | D = 0,00231, p = 0,6595 | p ≥ 2,50e-03 | oui |
| Spearman, 6 paires : max abs ρ(t_j, t_k) | 0,00550 (paire (2, 3)) | seuil 0,00956 ; paires hors seuil : 0 | oui |
| Spearman, 6 paires : max abs ρ(abs t_j, abs t_k) | 0,00575 (paire (2, 3)) | seuil 0,00956 ; paires hors seuil : 0 | oui |

Contrôle des degrés de liberté (hors critère) : écart absolu maximal entre p_j du moteur et 2 P(T_df > |t_j|), df = n_j − 3 : 0,00e+00.

**Critère tenu** (0 contrôle(s) rejeté(s) sur 20).

### P3 — ordonnée à l'origine

Triangles tirés : 100 000 ; écartés, cumul ≤ 0 : 0 ; écartés, ajustement en erreur : 0 ; statistique de la ligne non définie : 0 ; **admis : 100 000**. Répartition de K : K = 5 : 100 000 (100,00 %). K le plus fréquent : 5 (prévu : 5) ; m = 29, niveau par contrôle 0,05/m = 1,72e-03.

| Contrôle | Observé | Référence (niveau 1 − 0,05/m) | Compatible |
| --- | --- | --- | --- |
| taux de rejet de la p χ²(2K) à 0,10 | 10 065 / 100 000 = 0,10065 | Clopper–Pearson [0,09769 ; 0,10366] ∋ 0,10 | oui |
| taux de rejet de la p χ²(2K) à 0,05 | 4 888 / 100 000 = 0,04888 | Clopper–Pearson [0,04677 ; 0,05105] ∋ 0,05 | oui |
| taux de rejet de la p χ²(2K) à 0,01 | 976 / 100 000 = 0,00976 | Clopper–Pearson [0,00881 ; 0,01077] ∋ 0,01 | oui |
| KS de p contre U(0, 1) | D = 0,00336, p = 0,2078 | p ≥ 1,72e-03 | oui |
| KS de t_0 contre Student(5) (n_j = 7) | D = 0,00203, p = 0,8060 | p ≥ 1,72e-03 | oui |
| KS de t_1 contre Student(4) (n_j = 6) | D = 0,00301, p = 0,3263 | p ≥ 1,72e-03 | oui |
| KS de t_2 contre Student(3) (n_j = 5) | D = 0,00277, p = 0,4281 | p ≥ 1,72e-03 | oui |
| KS de t_3 contre Student(2) (n_j = 4) | D = 0,00380, p = 0,1105 | p ≥ 1,72e-03 | oui |
| KS de t_4 contre Student(1) (n_j = 3) | D = 0,00203, p = 0,8022 | p ≥ 1,72e-03 | oui |
| Spearman, 10 paires : max abs ρ(t_j, t_k) | 0,00511 (paire (0, 1)) | seuil 0,00991 ; paires hors seuil : 0 | oui |
| Spearman, 10 paires : max abs ρ(abs t_j, abs t_k) | 0,00476 (paire (2, 3)) | seuil 0,00991 ; paires hors seuil : 0 | oui |

Contrôle des degrés de liberté (hors critère) : écart absolu maximal entre p_j du moteur et 2 P(T_df > |t_j|), df = n_j − 2 : 0,00e+00.

**Critère tenu** (0 contrôle(s) rejeté(s) sur 29).

### P3 — courbure

Triangles tirés : 100 000 ; écartés, cumul ≤ 0 : 0 ; écartés, ajustement en erreur : 0 ; statistique de la ligne non définie : 0 ; **admis : 100 000**. Répartition de K : K = 4 : 100 000 (100,00 %). K le plus fréquent : 4 (prévu : 4) ; m = 20, niveau par contrôle 0,05/m = 2,50e-03.

| Contrôle | Observé | Référence (niveau 1 − 0,05/m) | Compatible |
| --- | --- | --- | --- |
| taux de rejet de la p χ²(2K) à 0,10 | 9 969 / 100 000 = 0,09969 | Clopper–Pearson [0,09685 ; 0,10259] ∋ 0,10 | oui |
| taux de rejet de la p χ²(2K) à 0,05 | 4 979 / 100 000 = 0,04979 | Clopper–Pearson [0,04773 ; 0,05190] ∋ 0,05 | oui |
| taux de rejet de la p χ²(2K) à 0,01 | 978 / 100 000 = 0,00978 | Clopper–Pearson [0,00887 ; 0,01076] ∋ 0,01 | oui |
| KS de p contre U(0, 1) | D = 0,00212, p = 0,7578 | p ≥ 2,50e-03 | oui |
| KS de t_0 contre Student(4) (n_j = 7) | D = 0,00233, p = 0,6518 | p ≥ 2,50e-03 | oui |
| KS de t_1 contre Student(3) (n_j = 6) | D = 0,00216, p = 0,7381 | p ≥ 2,50e-03 | oui |
| KS de t_2 contre Student(2) (n_j = 5) | D = 0,00406, p = 0,0740 | p ≥ 2,50e-03 | oui |
| KS de t_3 contre Student(1) (n_j = 4) | D = 0,00302, p = 0,3199 | p ≥ 2,50e-03 | oui |
| Spearman, 6 paires : max abs ρ(t_j, t_k) | 0,00706 (paire (2, 3)) | seuil 0,00956 ; paires hors seuil : 0 | oui |
| Spearman, 6 paires : max abs ρ(abs t_j, abs t_k) | 0,00443 (paire (0, 1)) | seuil 0,00956 ; paires hors seuil : 0 | oui |

Contrôle des degrés de liberté (hors critère) : écart absolu maximal entre p_j du moteur et 2 P(T_df > |t_j|), df = n_j − 3 : 0,00e+00.

**Critère tenu** (0 contrôle(s) rejeté(s) sur 20).

### Limites

- Un constat de compatibilité à N = 100 000 par plan : un écart plus petit que la puissance de la mesure ne s'y voit pas, et une corrélation de Spearman nulle n'établit pas l'indépendance des t_j.
- Sous le seul modèle de Mack gaussien ajusté à `reserve2` (f et σ² fixés) et les trois plans de la première colonne : aucun résultat pour une autre forme de triangle, ni sous des erreurs non gaussiennes.
- Les triangles à cumul ≤ 0 sont écartés, non retirés : la loi mesurée est celle conditionnelle à des cumuls strictement positifs (effet de l'écart non mesuré séparément).
- Les niveaux 0,05/m sont des seuils de Bonferroni par ligne ; il n'est pas fait de correction entre les six couples (plan, ligne).

