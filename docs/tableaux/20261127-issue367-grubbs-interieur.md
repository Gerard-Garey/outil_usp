# Rejeu de `premium_interieur` à B = 9 999 sous cinq graines : ligne Grubbs et p bootstrap à B infini (issue #367)

### T0 — Exécution

| Grandeur | Valeur |
|---|---|
| Date | 2026-11-27 14:38:44 UTC |
| Script | `tests/mesure_b_dossier_t8.R` --grubbs-interieur |
| Commit | `c8829b7382da3dd48f93c7341946b18005c9ded4` |
| Empreintes du code | tests/mesure_b_dossier_t8.R 00716c94a367ec9ac4984e19f3c3e015 ; tests/outils_tests.R cd6f78dd811f125f1755acc55e1fd228 |
| Moteur | `R/engine.R`, md5 `c7b767f5d9116c35a0a9237ffdd2d79a`, empreinte sans commentaires `15a74c3dbd831c56c259df106e9e4667` |
| R | R version 4.3.3 (2024-02-29), Ubuntu 24.04.5 LTS, Linux, x86_64 ; cœurs (`parallel::detectCores()`) : 4 |
| BLAS / LAPACK | /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.12.0 / /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.12.0 |
| Plan | cas `premium_interieur` de `CAS` (`tests/outils_tests.R`) à B = 9 999 sous 5 graines ; appel du cas avec les seuls arguments B et seed posés ; une exécution à la fois, dans un seul processus ; ligne `Grubbs` (variante principale) |
| Graines (`res$metadata`) | seed 20260831, seed_flux_regime 20800000, permutation_pente : enumeration, générateur Mersenne-Twister/Inversion/Rejection ; seed 36100001, seed_flux_regime 36639170, permutation_pente : enumeration, générateur Mersenne-Twister/Inversion/Rejection ; seed 36100002, seed_flux_regime 36639171, permutation_pente : enumeration, générateur Mersenne-Twister/Inversion/Rejection ; seed 36100003, seed_flux_regime 36639172, permutation_pente : enumeration, générateur Mersenne-Twister/Inversion/Rejection ; seed 36100004, seed_flux_regime 36639173, permutation_pente : enumeration, générateur Mersenne-Twister/Inversion/Rejection |
| Plage nouvelle déclarée (graines secondaires et flux V3b) | 36100001 – 36639173 |
| Contrôles | tous conformes (T3) |
| Durée totale du script | 838.4 s |

Quantité visée : p_∞, p bootstrap à B infini de la ligne Grubbs sur ces données, sous le modèle ajusté et conditionnelle au régime intérieur de δ** (V3b) ;
quantité exacte définie par les données, approchée par Monte-Carlo. Erreur purement Monte-Carlo (fonction de B), binomiale : K = #{G* ≥ g_obs} sur N tirages retenus ;
les cinq flux sont tenus pour indépendants (graines distinctes : hypothèse d'usage, non vérifiée). La mesure ne réduit pas l'erreur de l'approximation bootstrap (plug-in, T = 8)
et ne dit ni si Grubbs est juste à T = 8, ni si B = 999 suffit ailleurs.

Lecture sur l'agrégat des quatre graines secondaires (avis d'actuary, Q7) : la graine du dossier, dont les 999 et 4 999 premiers tirages ont fait naître #367 (effet de sélection),
est rapportée à part, comme contexte, hors de la lecture ; l'agrégat à cinq graines est imprimé à titre d'information.

### T1 — Par graine

| Graine | Rôle | Graine du flux V3b | Variante | Tirages / retenus (arrêt) | N | K | K / N [Clopper–Pearson 99 %] | p_mc ± err_mc (moteur) | Verdict | Mention #244 | Écart au seuil le plus proche (err_mc) | σ_USP | Temps écoulé (s) | Temps CPU (s) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 36100001 | secondaire (lecture) | 36639170 | V3b | 43968 / 9999 (cible) | 9999 | 1025 | 0.10251 [0.09484 ; 0.11056] | 0.1026 ± 0.0030 | OK | oui | 0.86 (s = 0.1) | 0.0871308679 | 165.3 | 163.8 |
| 36100002 | secondaire (lecture) | 36639171 | V3b | 43818 / 9999 (cible) | 9999 | 1021 | 0.10211 [0.09445 ; 0.11015] | 0.1022 ± 0.0030 | OK | oui | 0.73 (s = 0.1) | 0.0871308679 | 162.1 | 159.9 |
| 36100003 | secondaire (lecture) | 36639172 | V3b | 44313 / 9999 (cible) | 9999 | 986 | 0.09861 [0.09107 ; 0.10653] | 0.0987 ± 0.0030 | ALERTE | oui | 0.44 (s = 0.1) | 0.0871308679 | 164.0 | 162.2 |
| 36100004 | secondaire (lecture) | 36639173 | V3b | 44372 / 9999 (cible) | 9999 | 987 | 0.09871 [0.09117 ; 0.10664] | 0.0988 ± 0.0030 | ALERTE | oui | 0.40 (s = 0.1) | 0.0871308679 | 165.6 | 163.7 |
| 20260831 | dossier (contexte, hors lecture) | 20800000 | V3b | 44686 / 9999 (cible) | 9999 | 974 | 0.09741 [0.08991 ; 0.10529] | 0.0975 ± 0.0030 | ALERTE | oui | 0.84 (s = 0.1) | 0.0871308679 | 174.1 | 172.7 |

g_obs (statistique de Grubbs observée) : 1.793630721.

### T2 — Agrégats et lecture du critère (avis d'actuary, par. 3.4, complété par Q6 à Q8)

| Grandeur | Quatre graines secondaires (lecture) | Cinq graines (information, sans lecture) |
|---|---|---|
| K_tot / N_tot | 4019 / 39996 | 4993 / 49995 |
| Estimation de p_∞ (K_tot / N_tot) | 0.10049 | 0.09987 |
| ET binomiale | 0.00150 | 0.00134 |
| Intervalle de Clopper–Pearson bilatéral à 99 % | [0.09665 ; 0.10442] | [0.09644 ; 0.10337] |
| Classification de l'intervalle (seuils α/2 = 0,05 et α = 0,10 de `add()`, sens « ne pas rejeter ») | ALERTE/OK | ALERTE/OK (sans lecture) |
| Khi-2 d'homogénéité des K_s / N_s entre graines (constat, sans effet sur la lecture) : X² (ddl) ; p asymptotique (loi du khi-2 à s − 1 ddl, s graines) ; effectif attendu minimal | 1.4835 (3) ; 0.6861 ; 1004.8 | 2.3332 (4) ; 0.6747 ; 998.6 |
| α du cas (`res$metadata$alpha`, contrôle (g3)) | 0,10 | 0,10 |

**Indécidable ALERTE/OK à N_tot près** : l'intervalle à 99 % de p_∞ contient α = 0,10.

Agrégat à cinq graines (information, sans lecture) : même classification (ALERTE/OK) que celui des quatre graines secondaires.

Khi-2 : tableau 2 × graines (K_s, N_s − K_s), statistique de Pearson, p par la loi du χ² à (graines − 1) ddl ; peu puissant contre une corrélation entre flux, il détecte une anomalie grossière (loi différente d'une graine à l'autre, erreur de comptage). Conditionnellement à N_s, K_s ~ Bin(N_s, p_∞) ; Clopper–Pearson sur l'agrégat suppose des flux indépendants (hypothèse d'usage, non vérifiée).

Verdict et mention #244 de chaque graine à B = 9 999 : T1. Contexte (tableau du 22/10/2026, `docs/tableaux/20261022-issue325-b-dossier.md`, graine du dossier, non recalculé) :
- B = 999 (dossier) : p = 0,1050 ± 0,0097, OK, mention #244
- B = 4 999 (#325) : p = 0,0926 ± 0,0041, ALERTE, mention #244

### T3 — Contrôles

| Contrôle | Résultat | Détail |
|---|---|---|
| (g0) | conforme | graines secondaires 36100001, 36100002, 36100003, 36100004, flux V3b 36639170, 36639171, 36639172, 36639173 (graine + 539169), enveloppe 36100001 - 36639173 ; 155 littéraux entiers isolés de 8 à 10 chiffres dans 112 fichiers (R/*.R, app.R, tests/*.R hors ce script, tests/unitaires/*.R ; écriture scientifique non recherchée, décimales après une virgule exclues ; ni paires de bornes ni graines calculées) ; littéraux L dont [L ; L + 539169] touche l'enveloppe : aucun ; plus proches : 34420000 en dessous, 123456789 au-dessus ; graine du dossier et son flux (20260831, 20800000) hors de l'enveloppe : oui |
| (g1) sens | conforme | sens de rejet de Grubbs au catalogue : haut |
| (g1) 20260831 | conforme | (1 + K) / (N + 1) = 0.097500000000000003 ; p_mc du moteur 0.097500000000000003 ; B effectif 9999 ; sens de la ligne : ne pas rejeter |
| (g3) 20260831 | conforme | seed 20260831, B 9999, graine du flux 20800000 (attendue 20800000), α 0.1 |
| (c) 20260831 | conforme | condition de #244 recalculée vraie, mention du moteur posée |
| (g1) 36100001 | conforme | (1 + K) / (N + 1) = 0.1026 ; p_mc du moteur 0.1026 ; B effectif 9999 ; sens de la ligne : ne pas rejeter |
| (g3) 36100001 | conforme | seed 36100001, B 9999, graine du flux 36639170 (attendue 36639170), α 0.1 |
| (c) 36100001 | conforme | condition de #244 recalculée vraie, mention du moteur posée |
| (g1) 36100002 | conforme | (1 + K) / (N + 1) = 0.1022 ; p_mc du moteur 0.1022 ; B effectif 9999 ; sens de la ligne : ne pas rejeter |
| (g3) 36100002 | conforme | seed 36100002, B 9999, graine du flux 36639171 (attendue 36639171), α 0.1 |
| (c) 36100002 | conforme | condition de #244 recalculée vraie, mention du moteur posée |
| (g1) 36100003 | conforme | (1 + K) / (N + 1) = 0.098699999999999996 ; p_mc du moteur 0.098699999999999996 ; B effectif 9999 ; sens de la ligne : ne pas rejeter |
| (g3) 36100003 | conforme | seed 36100003, B 9999, graine du flux 36639172 (attendue 36639172), α 0.1 |
| (c) 36100003 | conforme | condition de #244 recalculée vraie, mention du moteur posée |
| (g1) 36100004 | conforme | (1 + K) / (N + 1) = 0.098799999999999999 ; p_mc du moteur 0.098799999999999999 ; B effectif 9999 ; sens de la ligne : ne pas rejeter |
| (g3) 36100004 | conforme | seed 36100004, B 9999, graine du flux 36639173 (attendue 36639173), α 0.1 |
| (c) 36100004 | conforme | condition de #244 recalculée vraie, mention du moteur posée |
| (g2) | conforme | identiques (identical()) entre les 5 graines : g_obs oui (1.7936307205863251) ; δ̂ oui (0.66399074210833875) ; γ̂ oui (-2.3199869025861255) ; σ̂ oui (0.068955256562127129) ; σ_USP oui (0.08713086785766519) |

(g0) collision de la plage nouvelle avec les littéraux entiers isolés du dépôt (ni paires de bornes d'une plage, ni graines calculées ; décimales après une virgule exclues) ; (g1) sens de rejet au catalogue, puis par graine (1 + K) / (N + 1) identique à `bootstrap$p_mc` et à la ligne, N = B effectif, sans motif, sens de la ligne « ne pas rejeter » ;
(g2) g_obs, δ̂, γ̂, σ̂ et σ_USP identiques entre les graines ; (g3) graine, B, graine du flux V3b et α conformes au plan ; (c) condition de #244 recalculée = mention posée par le moteur.
