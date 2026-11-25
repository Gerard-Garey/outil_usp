## Mesure #612 (A2) : simulation de la colonne J−1 d'un trapèze, V0 (règle de minimum) contre V2 (estimateur direct)

### Statut épistémique (protocole, par. 4, reproduit tel quel)

**Statut épistémique** : constat de simulation sous un plan (modèle de Mack ajusté à `reserve2`, T = I + 1 = 8, lois N et E, B = 999), conditionnel à l'admission ; aucun théorème ne couvre ces tests bootstrap ni cet intervalle à T = 8 ; rien ne se transpose à d'autres paramètres ni à d'autres géométries.

### T0 — provenance

| Grandeur | Valeur |
| --- | --- |
| Protocole | docs/revues/20261123-a2-creneau/actuary-1-protocole-612.md, par. 8 (et 2 à 7, 9) ; décisions du mainteneur à PA-1 (E-23/11 (PA-1)) ; md5 70176c2e3ded10922eeb81971b533ae7 |
| Mode | mesure, niveau L-A |
| Triangles par bloc et loi ; B | M7a=1000/1000,M7b=1000/1000,M5=2000/2000,M6=2000/2000,C=2000/2000,D=1000/1000,BAL=20/20,S=1,OR=20000/20000,OD=20000/20000 ; 999 |
| DGP | modèle de Mack ajusté à reserve2 (tests/donnees/triangle_mw.csv, md5 3e9a584da42443f3816fb63deeffa95b), j = 0..J − 1, première colonne fixée, I = 7 ; bloc D : 8 x 6 avec σ²_2 = 0 ; carré : 8 x 8 complet |
| Lois | N : stats::rnorm ; E : tirage uniforme dans les 27 valeurs du pool redressé de reserve2 divisées par leur écart-type de population (0,99879) |
| Chemin | gen_triangle_h0() sous engine_sous_graine() ; admission (cellule, mw_valider_triangle(), domaine, mw_ajuster(), mw_msep(), M4) ; mw_ajuster() → .mw_ensembles_figes() → mw_bootstrap(aj, B, graine, figes) → mw_tests(aj, boot, 0,10, figes) |
| Graines | triangle b, loi ℓ : 567 000 000 + 100 000 (ℓ − 1) + b ; bootstrap : 568 000 000 + 1 000 000 (g − 1) + 100 000 (ℓ − 1) + b, la même pour V0 et V2 ; oracle : 570 500 000 + 100 000 (ℓ − 1) + k (réemploi de #567) ; carré : 660 000 000 + 100 000 (ℓ − 1) + b ; D : 661 000 000, 661 500 000, 662 000 000 + 100 000 (ℓ − 1) + b ou k ; sonde : 663 000 000 + u ; pré-vol : 664 000 000 + u, 664 500 000 + u |
| Substitutions (environment(run_engine), on.exit, identical()) | V2 : `function (aj) !is.null(aj[["sigma2_Jm1_direct"]]) && !.mw_colonne_degeneree(aj, aj$J - 1L)` ; balayage_k : `function (aj, pool, reste) { aj$sigma2[aj$J] <- k * aj$sigma2_Jm1_direct orig(aj, pool, reste) }` ; balayage_regle : `function (aj, pool, reste) { aj$sigma2[aj$J] <- v orig(aj, pool, reste) }` ; sonde : `function (aj, j_degeneres = NULL) { jd <- .mw_j_exclues(aj, j_degeneres) deg <- .mw_colonnes_degenerees(aj) s2 <- .mw_sigma2_residus(aj) cand <- setdiff(deg, jd) touche <- any(vapply(cand, function(j) aj$I - j >= 2 && is.finite(s2[j + 1L]) && s2[j + 1L] > 0, logical(1))) if (!is.null(cpt$tri_obs) && identical(aj$tri, cpt$tri_obs)) { cpt$obs_appels <- cpt$obs_appels + 1L if (touche) cpt$obs_touche <- TRUE } else { cpt$appels <- cpt$appels + 1L if (!identical(aj$tri, cpt$dernier)) { cpt$dernier <- aj$tri cpt$triangles <- cpt$triangles + 1L cpt$marque <- FALSE } if (touche) { cpt$touches <- cpt$touches + 1L if (!cpt$marque) { cpt$tri_touches <- cpt$tri_touches + 1L cpt$marque <- TRUE } } } if (identical(mode, "P1")) orig(aj, union(jd, deg)) else orig(aj, j_degeneres) }` |
| Oracles (non versionnés) | 8x5 N : 20000 / 20000 admis ; 8x5 E : 20000 / 20000 admis ; 8x6 N : 20000 / 20000 admis ; 8x6 E : 20000 / 20000 admis ; 8x7 N : 20000 / 20000 admis ; 8x7 E : 20000 / 20000 admis ; D N : 20000 / 20000 admis ; D E : 20000 / 20000 admis ; oracle-567.tsv md5 5bdafe159cd5624fee6ba906896d4f40 ; oracle-D.tsv md5 ef76d8b8a7f46549d80024f34967af5c |
| Entrées | docs/tableaux/20261120-issue567-niveau-trapeze-mw-brut.tsv md5 9fcb59cd24212f7f1c851e7634a34e3f ; docs/tableaux/20261120-issue567-niveau-trapeze-mw.md md5 adf5de226021c2521cb564757086e26b ; docs/tableaux/20261026-issue297-calibration-famille-mw-brut.tsv md5 01325170c75ccc603707f96332dc1e96 |
| SHA (début ; fin) | d6ff8846b9516761dddd2c7de253ad863d79d268 ; d6ff8846b9516761dddd2c7de253ad863d79d268 |
| Commit (commit_depot(), au début) | d6ff8846b9516761dddd2c7de253ad863d79d268 |
| md5 R/engine.R (début ; fin) | 5bffa72279b34a7ab12bd5b9f13abc15 ; 5bffa72279b34a7ab12bd5b9f13abc15 |
| Empreinte #231 (début ; fin) | 87c53faa030fd1bb58dffe61e51aba69 ; 87c53faa030fd1bb58dffe61e51aba69 |
| Empreintes md5 du code exécuté | R/engine.R 5bffa72279b34a7ab12bd5b9f13abc15 ; tests/outils_tests.R chargé (dépôt) cd6f78dd811f125f1755acc55e1fd228 ; script exécuté (dépôt) 1e320e8e1b765dfd8ff64ad4b97df1ba |
| Plateforme de calcul | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : libblas.so.3.12.0 ; LAPACK : liblapack.so.3.12.0 (version 3.12.0) |
| Locale (LC_CTYPE) | C.UTF-8 → C.UTF-8 |
| Tranches | 1787 (taille 100) |
| Sorties | 20261123-issue612-simulation-jm1-trapeze.md ; 20261123-issue612-simulation-jm1-trapeze-brut.tsv ; 20261123-issue612-simulation-jm1-trapeze-balayage-brut.tsv ; 20261123-issue612-simulation-jm1-trapeze-sonde.tsv ; 20261123-issue612-simulation-jm1-trapeze-journal-mesure.md |
| Contrôles d'intégrité | OK |
| K0 (critères (inv), (o), (dc) carré ; refus et p absentes) | tenu |
| (dc) sur le bloc D | OK ou sans objet |

### Critères et règles (protocole, par. 4), reportés sans modification

> **Critère A2 / #612.** D = 1 si p_mc < α, α ∈ {0,05 ; 0,10} ; une p absente compte comme un non-rejet, comptée à part. Témoin : test idéal sur l'oracle de (G, ℓ), définition de #567 (K3). Pour deux décisions appariées A et B sur les mêmes triangles : Δ = (n10 − n01)/n ; test de McNemar exact (binomial bilatéral de paramètre 1/2 sur n10 + n01) ; intervalle exact conditionnel de Δ = (2π − 1)(n10 + n01)/n, π par Clopper-Pearson sur n10 parmi n10 + n01. Marges d'équivalence δ_0,05 = 0,010 et δ_0,10 = 0,020 (convention : α/5). « Aligné » : intervalle à 90 % de Δ inclus dans [−δ_α ; +δ_α] (équivalence par deux tests unilatéraux à 5 %, Schuirmann 1987). Valeurs non arrondies ; aucune extension du nombre de triangles après lecture ; un « non tranché » reste non tranché.
> - **K0 (intégrité)** : tous les contrôles du § 8 OK ; refus et p absentes ≤ 1 % par (G, ℓ) ; invariance : p_mc des clés autres que PenteIntra et Alpha (autres que PenteIntra sur 8×7) identiques entre V0 et V2 sur au moins 99,5 % des triangles de chaque (G, ℓ), écarts comptés avec leur cause.
> - **K1 (reproduction, confirmatoire)** : sur le 8×7, b = 1001 à 2000, PenteIntra à 0,05, V0 contre témoin, McNemar exact par loi, Holm sur les deux lois à 0,05 : « excès reproduit » si rejet avec Δ > 0 pour au moins une loi.
> - **K2 (correction)** : sur le 8×7, b ≤ 2000, PenteIntra, chaque loi et chaque α : V2 aligné sur le témoin (K2a) **ou** sur le carré 8×8 des mêmes triangles (K2b). K2 tenu si les quatre cellules le sont.
> - **K2′ (amélioration partielle)** : sur le 8×7, PenteIntra, V2 contre V0 (mêmes graines), McNemar exact unilatéral vers moins de rejets, Holm sur les quatre cellules à 0,05 : au moins une cellule significative, et aucune cellule où |Δ̂_V2| > |Δ̂_V0|.
> - **K3 (non-dégradation)** : sur 8×5 et 8×6, PenteIntra et Alpha, chaque loi et chaque α (16 cellules) : V2 aligné sur le témoin, **ou** |Δ̂_V2| ≤ |Δ̂_V0| + δ_α/2 ; et aucune cellule où τ_V2 est en distorsion matérielle (classes de #567) alors que τ_V0 ne l'est pas. K3 tenu si les 16 cellules le sont.
> - **K4 (couverture, comparative)** : intervalle percentile à 90 %, cible σ_A^règle, chaque (G, ℓ) des trois trapèzes : borne haute de l'intervalle à 90 % de la différence appariée des taux de non-couverture (V2 − V0) ≤ +0,02. Le 95 %, les queues séparées, σ_A^vrai et σ_B sont descriptifs.
>
> **Règles** (évaluées mécaniquement par le script, sans conclure ; lecture par `actuary` à l'étape 4, décision du mainteneur à PA-2) :
> - **R0** : K0 en défaut → lecture suspendue, aucune recommandation.
> - **R-V2** : K1, K2, K3, K4 tenus → simuler J−1 avec l'estimateur direct (V2).
> - **R-V2′** : K1, K2′, K3, K4 tenus, K2 non tenu → V2 recommandée comme amélioration, la réserve PenteIntra restant écrite sur le 8×7.
> - **R-V1** : K1, (K2 ou K2′), K3 tenus, K4 en défaut → V1 (tests de V2, σ_boot de V0), prototypée hors moteur avant toute implémentation (contrat partagé).
> - **R-V0** : K2 et K2′ en défaut, ou K3 en défaut → Q-2a-2 confirmée, réserves des fiches reprises avec les nouveaux chiffres.
> - **Défaut** : toute autre combinaison, K1 en défaut compris, est « non tranchée » → V0 par défaut, les deux lectures sont portées au mainteneur.
>
> **Statut épistémique** : constat de simulation sous un plan (modèle de Mack ajusté à `reserve2`, T = I + 1 = 8, lois N et E, B = 999), conditionnel à l'admission ; aucun théorème ne couvre ces tests bootstrap ni cet intervalle à T = 8 ; rien ne se transpose à d'autres paramètres ni à d'autres géométries.

### Contrôles d'intégrité (par. 8)

| Contrôle | Résultat | Détail |
| --- | --- | --- |
| (1) début | OK | git diff --quiet HEAD -- R/engine.R au début : vide ; md5 R/engine.R 5bffa72279b34a7ab12bd5b9f13abc15 ; SHA d6ff8846b9516761dddd2c7de253ad863d79d268 |
| (1) fin | OK | md5 du protocole début 70176c2e3ded10922eeb81971b533ae7, fin 70176c2e3ded10922eeb81971b533ae7 ; md5 R/engine.R début 5bffa72279b34a7ab12bd5b9f13abc15, fin 5bffa72279b34a7ab12bd5b9f13abc15, JOURNAL 5bffa72279b34a7ab12bd5b9f13abc15 ; SHA début d6ff8846b9516761dddd2c7de253ad863d79d268, fin d6ff8846b9516761dddd2c7de253ad863d79d268, JOURNAL d6ff8846b9516761dddd2c7de253ad863d79d268 ; empreinte #231 début 87c53faa030fd1bb58dffe61e51aba69, fin 87c53faa030fd1bb58dffe61e51aba69 ; git diff --quiet HEAD -- R/engine.R à la fin : vide ; substitutions restaurées : oui ; contexte identique dans les 1787 tranche(s) : oui |
| (t) | OK | par. 4 (critère, K0 à K4, règles R0 à défaut, statut épistémique ; 17 lignes) présent à l'identique dans docs/revues/20261123-a2-creneau/actuary-1-protocole-612.md ; md5 70176c2e3ded10922eeb81971b533ae7, identique au md5 approuvé à PA-1 (70176c2e3ded10922eeb81971b533ae7, exigé) ; md5 lu au T0 fixé dans le contexte des tranches et contrôlé à la fin ; vérifié avant tout tirage |
| (e) | OK | md5 des entrées : brut de #567 9fcb59cd24212f7f1c851e7634a34e3f, tableau de #567 adf5de226021c2521cb564757086e26b, brut de #297 01325170c75ccc603707f96332dc1e96 (attendus 9fcb59cd24212f7f1c851e7634a34e3f, adf5de226021c2521cb564757086e26b, 01325170c75ccc603707f96332dc1e96) ; brut de #567 : 10000 lignes ; taux de MinP4 de #297 relus (0,10 / 0,05) : N 0.071 / 0.029 ; E 0.0785 / 0.0395 (protocole : N 0,071 / 0,029 ; E 0,0785 / 0,0395) |
| (a) | OK | reserve2 contre tests/reference/reserve2.rds, comparer_objets(tol = 0) : 18746 feuilles, 0 différente(s), 0 écart(s), écart maximal 0 ; reserve2_trapeze contre tests/reference/reserve2_trapeze.rds, comparer_objets(tol = 0) : 18573 feuilles, 0 différente(s), 0 écart(s), écart maximal 0 ; plateforme = celle de #567 (R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : libblas.so.3.12.0 ; LAPACK : liblapack.so.3.12.0 (version 3.12.0)) |
| (v0) | OK | V0 du script (mw_bootstrap(), B = 999, graine 664 500 000 + u) identical() à run_engine() sur les 13 p_mc ; triangles du pré-vol (graine 664 000 000 + u, premier admis par (G, loi)) : 8x5 N u = 1 : 13 / 13 identiques ; 8x5 E u = 1 : 13 / 13 identiques ; 8x6 N u = 1 : 13 / 13 identiques ; 8x6 E u = 1 : 13 / 13 identiques ; 8x7 N u = 1 : 13 / 13 identiques ; 8x7 E u = 1 : 13 / 13 identiques ; substitutions restaurées (identical()) : oui |
| (v2) | OK | V2 du script (mw_bootstrap(), B = 999, graine 664 500 000 + u) identical() à run_engine() sous la même substitution sur les 13 p_mc ; triangles du pré-vol (graine 664 000 000 + u, premier admis par (G, loi)) : 8x5 N u = 1 : 13 / 13 identiques ; 8x5 E u = 1 : 13 / 13 identiques ; 8x6 N u = 1 : 13 / 13 identiques ; 8x6 E u = 1 : 13 / 13 identiques ; 8x7 N u = 1 : 13 / 13 identiques ; 8x7 E u = 1 : 13 / 13 identiques ; substitutions restaurées (identical()) : oui |
| (r567) initial | OK | 8 x 7, loi N, b = 1 (graines 567 000 001 et 570 000 001) : V0 recalculé à B = 999 identique au brut de #567 relu en %.17g (13 p_mc, obs, s2_regle, s2_dir, R_hat, msep) : oui ; md5 de R/engine.R à la mesure de #567 faf36c545999c147087759155a2bd38a, à ce calcul 5bffa72279b34a7ab12bd5b9f13abc15 (l'identité des nombres fait foi) |
| (r567) | OK | V0 recalculé à B = 999 sur le premier triangle admis de chaque tranche de #567 couverte (M7a, M5, M6) : 100 / 100 identiques au brut relu en %.17g (13 p_mc, obs, s2_regle, s2_dir, R_hat, msep) ; 100 tranche(s) ; md5 de R/engine.R à la mesure de #567 faf36c545999c147087759155a2bd38a, à ce calcul 5bffa72279b34a7ab12bd5b9f13abc15 (l'identité des nombres fait foi) |
| (g) | OK | gen_triangle_h0() = .mw_simuler_triangle_etat() sous la même graine (identical()) : 8x5 : 100 / 100 ; pool dilaté 30 fois : 100 / 100, dont 39 incomplet(s) ; 8x6 : 100 / 100 ; pool dilaté 30 fois : 100 / 100, dont 41 incomplet(s) ; 8x7 : 100 / 100 ; pool dilaté 30 fois : 100 / 100, dont 42 incomplet(s) ; 8x8 : 100 / 100 ; pool dilaté 30 fois : 100 / 100, dont 42 incomplet(s) ; D : 100 / 100 ; pool dilaté 30 fois : 100 / 100, dont 25 incomplet(s) ; .mw_simulation_sigma_direct, .mw_tirer_triangle_valide, mw_residus, mw_simuler_triangle, .mw_simuler_triangle_etat, .mw_triangle_incomplet, .mw_pool_residus, mw_bootstrap, mw_ajuster, mw_msep, mw_tests, mw_valider_triangle, .mw_ensembles_figes de l'environnement du moteur identiques (formals, body) à R/engine.R relu : oui |
| (g') | OK | trapèze = colonnes 0..J du 8 x 8 simulé sous la même graine, avant tout tirage : 8x5 : 200 / 200 ; ε dilatés 30 fois : 200 / 200, dont 82 incomplet(s) ; 8x6 : 200 / 200 ; ε dilatés 30 fois : 200 / 200, dont 85 incomplet(s) ; 8x7 : 200 / 200 ; ε dilatés 30 fois : 200 / 200, dont 91 incomplet(s) ; plan : 24000 / 24000 lignes de trapèze où le trapèze est la troncature du 8 x 8 |
| (c) | OK | σ²_(J−1) de la règle au générateur (reserve2 tronqué) : 8x5 0.684464, 8x6 0.141928, 8x7 0.030091 (protocole : 0.684464, 0.141928, 0.030091) ; σ²_(J−1) vrai du plan : 8x5 0.314779, 8x6 0.0973248, 8x7 0.189674 (protocole : 0.314779, 0.0973248, 0.189674) ; cibles : σ_A^règle = √MSEP/R du générateur 8x5 0.021331, 8x6 0.018101, 8x7 0.016621 ; σ_A^vrai (descriptive) 8x5 0.018859, 8x6 0.017675, 8x7 0.019065 |
| (graines) | OK | plages de la mesure de 567000001 à 664500050 ; neuves dans la plage d'A2 [660000000 ; 664999999] : oui ; disjointes de #610 610000001-644999999, #206/#297 MW, #297 LN, #305, #387 et de 360 380 123 : oui ; maximum ≤ 2^31 − 1 : oui ; 157 littéraux entiers de 8 à 10 chiffres dans 101 fichiers (R/engine.R, tests/*.R hors ce script, tests/unitaires/*.R) ; littéraux dans la plage d'A2 : aucun ; littéraux L dont [L ; L + 20000] touche une plage neuve : aucun ; fichiers portant un littéral de la plage de #567 [567000000 ; 572000000] (réemploi déclaré, hors contrôle de chevauchement) : couverture_ic_sigma_mw_imbrique_t8.R, niveau_mw_trapeze_t8.R ; chevauchements internes : aucun |
| (m) | OK | aucune occurrence de « simulation_jm1_trapeze » dans R/, app.R et .github/ (18 fichiers lus) ; en défaut : aucun |
| (i1) | OK | statistiques observées par le chemin de l'oracle (stats_oracle()) identical() à bootstrap$stats_obs (validité du témoin) : 180 / 180 triangles de contrôle |
| (al) | OK | σ* de la boucle allégée identical() à sigma_boot de mw_bootstrap(), premier triangle de chaque tranche des trapèzes : V2 120 / 120 ; V0 120 / 120 |
| (so) | OK | statistiques observées (13 clés) identiques entre V0 et V2, par triangle admis : 8x5 N 2000 / 2000 ; 8x5 E 2000 / 2000 ; 8x6 N 2000 / 2000 ; 8x6 E 2000 / 2000 ; 8x7 N 2000 / 2000 ; 8x7 E 2000 / 2000 |
| (inv) | OK | critère de K0, invariance : p_mc des clés autres que PenteIntra et Alpha (autres que PenteIntra sur 8 x 7) identiques entre V0 et V2 sur au moins 99,5 % des triangles de chaque (G, ℓ) : 8x5 N 2000 / 2000 (1,0000) ; 8x5 E 2000 / 2000 (1,0000) ; 8x6 N 2000 / 2000 (1,0000) ; 8x6 E 2000 / 2000 (1,0000) ; 8x7 N 2000 / 2000 (1,0000) ; 8x7 E 2000 / 2000 (1,0000) |
| (o) | OK | critère de K0 : carré 8 x 8 : statistiques observées identical() à celles du 8 x 7 tronqué (même témoin) : 4000 / 4000 triangles ; 8 x 7 tronqué non ajustable : 0 |
| (dc) carré | OK | critère de K0 : carré : prédicat .mw_simulation_sigma_direct() identique sous V0 et V2 (simulation identique, une exécution) : 4000 / 4000 ; prédicat faux : 4000 / 4000 |
| (dc) D | OK | bloc D (constats (3) et (4)) : prédicat .mw_simulation_sigma_direct() identique sous V0 et V2 (simulation identique, une exécution) : 2000 / 2000 ; cas M-1 (b) (prédicat vrai) : 2000 / 2000 ; un défaut rend les constats (3) et (4) non évaluables, sans R0 |
| (oracle) | OK | ρ (0,10 ; 0,05) et tailles du témoin de #567 reproduits aux cinq décimales : 78 / 78 lignes ; lecture du tableau de #567 (docs/tableaux/20261120-issue567-niveau-trapeze-mw.md) : 78 ligne(s) (78 attendues), 78 à quatre champs numériques à cinq décimales et (G, ℓ, clé) connus, 78 (G, ℓ, clé) distincts ; md5 oracle-567.tsv 5bdafe159cd5624fee6ba906896d4f40 (#567 : 5bdafe159cd5624fee6ba906896d4f40, identique) ; écarts : aucun |
| (bal) | OK | balayage : point k = 1 (σ² posé = σ̂²_dir) identique à V2 : 120 / 120 ; point « règle » (σ² posé = σ̂²_règle) identique à V0 : 120 / 120 (p_mc des 13 clés et retirage, %.17g) ; exceptions (colonne J−1 dégénérée ou cas M-1 (b)) : 0 |
| (rep) | OK | premier et dernier triangles admis de chaque cellule (blocs M7a, M7b, M5, M6, C, D) recalculés : 24 / 24 triangles aux lignes identiques, hors durée ; premier et dernier k de chaque cellule des oracles (OR, OD) recalculés : 16 / 16 lignes identiques, hors durée |

### Cibles de couverture (par. 1)

| G | σ_A^règle (cible principale) | σ_A^vrai (descriptive) | σ²_(J−1) de la règle | σ²_(J−1) vrai |
| --- | --- | --- | --- | --- |
| 8x5 | 0,021331 | 0,018859 | 0,684464 | 0,3147788 |
| 8x6 | 0,018101 | 0,017675 | 0,141928 | 0,0973248 |
| 8x7 | 0,016621 | 0,019065 | 0,030091 | 0,1896737 |

### Référence ρ par oracle et loi

ρ : taille lissée à B = 999 du test de Monte-Carlo idéal sur l'oracle (règle de #206, par. 4) ; carré : oracle du 8 x 7 ; D : oracle propre.

| Oracle | Loi | admis / tirés | ρ Calendrier 0,05 | ρ CorrDev 0,05 | ρ BP 0,05 | ρ MinP4 0,05 | ρ DW 0,05 | ρ Runs 0,05 | ρ PenteIntra 0,05 | ρ Origine 0,05 | ρ HomogF 0,05 | ρ Courbure 0,05 | ρ Alpha 0,05 | ρ ExpVar 0,05 | ρ KruskalAcc 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 8x5 | N | 20000 / 20000 | 0,03434 | 0,04753 | 0,04897 | 0,04897 | 0,04795 | 0,03331 | 0,04795 | 0,04897 | 0,04896 | 0,04897 | 0,04897 | 0,04897 | 0,04893 |
| 8x5 | E | 20000 / 20000 | 0,03274 | 0,04752 | 0,04897 | 0,04897 | 0,04795 | 0,03327 | 0,04795 | 0,04897 | 0,04897 | 0,04897 | 0,04897 | 0,04897 | 0,04893 |
| 8x6 | N | 20000 / 20000 | 0,04530 | 0,04760 | 0,04897 | 0,04897 | 0,04795 | 0,02467 | 0,04795 | 0,04897 | 0,04896 | 0,04897 | 0,04897 | 0,04897 | 0,04897 |
| 8x6 | E | 20000 / 20000 | 0,04586 | 0,04759 | 0,04897 | 0,04897 | 0,04795 | 0,02528 | 0,04795 | 0,04897 | 0,04897 | 0,04897 | 0,04897 | 0,04897 | 0,04897 |
| 8x7 | N | 20000 / 20000 | 0,04114 | 0,04760 | 0,04897 | 0,04897 | 0,04795 | 0,03156 | 0,04795 | 0,04897 | 0,04896 | 0,04897 | 0,04897 | 0,04897 | 0,04897 |
| 8x7 | E | 20000 / 20000 | 0,04128 | 0,04759 | 0,04897 | 0,04897 | 0,04795 | 0,02943 | 0,04795 | 0,04897 | 0,04897 | 0,04897 | 0,04897 | 0,04897 | 0,04897 |
| D | N | 20000 / 20000 | 0,03392 | 0,04362 | 0,04897 | 0,04897 | 0,04795 | 0,02252 | 0,04795 | 0,04897 | 0,04889 | 0,04897 | 0,04897 | 0,04889 | 0,04892 |
| D | E | 20000 / 20000 | 0,03404 | 0,04358 | 0,04897 | 0,04897 | 0,04795 | 0,02310 | 0,04795 | 0,04897 | 0,04889 | 0,04897 | 0,04897 | 0,04886 | 0,04891 |

### K0 (intégrité) : **tenu**

Contrôles d'intégrité : OK. Critères de K0 (décision C2 du mainteneur : défaut → R0, sans INTEGRITE ECHEC) : (inv) invariance, (o) carré, (dc) carré : OK. Refus et p absentes (au moins une des 13 p_mc) au plus 1 % par (bloc, G, ℓ, variante), bloc D affiché hors verdict (R3).

| Bloc | G | Loi | Variante | tirés | admis | échecs | refus | part des refus | p absentes | part | rempli | dans le verdict K0 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| M7a | 8x7 | N | V2 | 1000 | 1000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | oui |
| M7a | 8x7 | N | V0 | 1000 | 1000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | oui |
| M7a | 8x7 | E | V2 | 1000 | 1000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | oui |
| M7a | 8x7 | E | V0 | 1000 | 1000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | oui |
| M7b | 8x7 | N | V2 | 1000 | 1000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | oui |
| M7b | 8x7 | N | V0 | 1000 | 1000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | oui |
| M7b | 8x7 | E | V2 | 1000 | 1000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | oui |
| M7b | 8x7 | E | V0 | 1000 | 1000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | oui |
| M5 | 8x5 | N | V2 | 2000 | 2000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | oui |
| M5 | 8x5 | N | V0 | 2000 | 2000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | oui |
| M5 | 8x5 | E | V2 | 2000 | 2000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | oui |
| M5 | 8x5 | E | V0 | 2000 | 2000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | oui |
| M6 | 8x6 | N | V2 | 2000 | 2000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | oui |
| M6 | 8x6 | N | V0 | 2000 | 2000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | oui |
| M6 | 8x6 | E | V2 | 2000 | 2000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | oui |
| M6 | 8x6 | E | V0 | 2000 | 2000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | oui |
| C | 8x8 | N | V0 | 2000 | 2000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | oui |
| C | 8x8 | E | V0 | 2000 | 2000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | oui |
| D | 8x6 | N | V0 | 1000 | 1000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | non (bloc D, R3) |
| D | 8x6 | E | V0 | 1000 | 1000 | 0 | 0 | 0,0000 | 0 | 0,0000 | oui | non (bloc D, R3) |

| G | Loi | triangles appariés | p_mc invariantes | part | écarts par cause | ≥ 99,5 % |
| --- | --- | --- | --- | --- | --- | --- |
| 8x5 | N | 2000 | 2000 | 1,0000 | aucun | oui |
| 8x5 | E | 2000 | 2000 | 1,0000 | aucun | oui |
| 8x6 | N | 2000 | 2000 | 1,0000 | aucun | oui |
| 8x6 | E | 2000 | 2000 | 1,0000 | aucun | oui |
| 8x7 | N | 2000 | 2000 | 1,0000 | aucun | oui |
| 8x7 | E | 2000 | 2000 | 1,0000 | aucun | oui |

### K1 (reproduction, confirmatoire) : oui

8 x 7, b = 1001 à 2000 (bloc M7b), PenteIntra à 0,05, V0 contre témoin, McNemar exact bilatéral par loi, Holm sur les deux lois.

| Loi | n | k V0 | k témoin | Δ̂ [IC 90 %] (n10, n01) | p McNemar | p Holm | rejet avec Δ > 0 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| N | 1000 | 72 | 56 | 0,01600 [0,00870 ; 0,01928] (n10 = 18, n01 = 2) | 0,000402 | 0,000402 | **oui** |
| E | 1000 | 66 | 37 | 0,02900 [0,02331 ; 0,02900] (n10 = 29, n01 = 0) | 3,73e-09 | 7,45e-09 | **oui** |

### K2 (correction) : oui

8 x 7, b ≤ 2000 (M7a et M7b), PenteIntra : V2 aligné sur le témoin (K2a) ou sur le carré 8 x 8 des mêmes triangles (K2b) ; aligné : IC à 90 % de Δ dans [−δ_α ; +δ_α].

| Loi | α | n | V2 contre témoin Δ̂ [IC 90 %] | K2a | n (carré) | V2 contre carré Δ̂ [IC 90 %] | K2b | cellule tenue |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | 0,05 | 2000 | 0,00800 [0,00301 ; 0,01181] (n10 = 24, n01 = 8) | non | 2000 | 0,00050 [-0,00397 ; 0,00487] (n10 = 13, n01 = 12) | oui | oui |
| N | 0,10 | 2000 | 0,01400 [0,00901 ; 0,01730] (n10 = 34, n01 = 6) | oui | 2000 | 0,00150 [-0,00365 ; 0,00644] (n10 = 18, n01 = 15) | oui | oui |
| E | 0,05 | 2000 | 0,01750 [0,01238 ; 0,02082] (n10 = 41, n01 = 6) | non | 2000 | 0,00500 [0,00017 ; 0,00899] (n10 = 19, n01 = 9) | oui | oui |
| E | 0,10 | 2000 | 0,01700 [0,01240 ; 0,01961] (n10 = 38, n01 = 4) | oui | 2000 | 0,00200 [-0,00280 ; 0,00646] (n10 = 16, n01 = 12) | oui | oui |

### K2′ (amélioration partielle) : oui

| Loi | α | n | k V2 | k V0 | V2 contre V0 Δ̂ [IC 90 %] | p unilatérale | p Holm | |Δ̂_V2| | |Δ̂_V0| |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | 0,05 | 2000 | 121 | 144 | -0,01150 [-0,01447 ; -0,00685] (n10 = 5, n01 = 28) | 3,31e-05 | 0,000132 | 0,00800 | 0,01950 |
| N | 0,10 | 2000 | 228 | 248 | -0,01000 [-0,01408 ; -0,00468] (n10 = 9, n01 = 29) | 0,000829 | 0,00249 | 0,01400 | 0,02400 |
| E | 0,05 | 2000 | 121 | 141 | -0,01000 [-0,01431 ; -0,00452] (n10 = 10, n01 = 30) | 0,00111 | 0,00249 | 0,01750 | 0,02750 |
| E | 0,10 | 2000 | 231 | 252 | -0,01050 [-0,01559 ; -0,00441] (n10 = 14, n01 = 35) | 0,0019 | 0,00249 | 0,01700 | 0,02750 |

### K3 (non-dégradation) : oui

| G | Clé | Loi | α | n | V2 contre témoin Δ̂ [IC 90 %] | V0 contre témoin Δ̂ [IC 90 %] | aligné | |Δ̂_V2| ≤ |Δ̂_V0| + δ/2 | classe τ_V2 | classe τ_V0 | cellule tenue |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 8x5 | PenteIntra | N | 0,05 | 2000 | 0,00100 [-0,00245 ; 0,00411] (n10 = 8, n01 = 6) | -0,00100 [-0,00437 ; 0,00267] (n10 = 7, n01 = 9) | oui | oui | compatible | compatible | oui |
| 8x5 | PenteIntra | N | 0,10 | 2000 | -0,00450 [-0,00799 ; -0,00008] (n10 = 7, n01 = 16) | -0,00550 [-0,00874 ; -0,00113] (n10 = 6, n01 = 17) | oui | oui | compatible | compatible | oui |
| 8x5 | PenteIntra | E | 0,05 | 2000 | 0,00000 [-0,00396 ; 0,00396] (n10 = 10, n01 = 10) | -0,00100 [-0,00522 ; 0,00342] (n10 = 11, n01 = 13) | oui | oui | compatible | compatible | oui |
| 8x5 | PenteIntra | E | 0,10 | 2000 | 0,00000 [-0,00433 ; 0,00433] (n10 = 12, n01 = 12) | -0,00050 [-0,00487 ; 0,00397] (n10 = 12, n01 = 13) | oui | oui | compatible | compatible | oui |
| 8x5 | Alpha | N | 0,05 | 2000 | -0,01400 [-0,02148 ; -0,00581] (n10 = 31, n01 = 59) | -0,01100 [-0,01947 ; -0,00206] (n10 = 42, n01 = 64) | non | oui | compatible | compatible | oui |
| 8x5 | Alpha | N | 0,10 | 2000 | -0,00150 [-0,01188 ; 0,00892] (n10 = 72, n01 = 75) | -0,00200 [-0,01344 ; 0,00949] (n10 = 88, n01 = 92) | oui | oui | compatible | compatible | oui |
| 8x5 | Alpha | E | 0,05 | 2000 | -0,00550 [-0,01200 ; 0,00141] (n10 = 25, n01 = 36) | -0,00750 [-0,01465 ; 0,00011] (n10 = 30, n01 = 45) | non | oui | compatible | compatible | oui |
| 8x5 | Alpha | E | 0,10 | 2000 | 0,00400 [-0,00510 ; 0,01294] (n10 = 59, n01 = 51) | -0,00200 [-0,01123 ; 0,00731] (n10 = 56, n01 = 60) | oui | oui | compatible | compatible | oui |
| 8x6 | PenteIntra | N | 0,05 | 2000 | -0,00150 [-0,00575 ; 0,00303] (n10 = 11, n01 = 14) | -0,00350 [-0,00821 ; 0,00171] (n10 = 13, n01 = 20) | oui | oui | compatible | compatible | oui |
| 8x6 | PenteIntra | N | 0,10 | 2000 | 0,00800 [0,00239 ; 0,01268] (n10 = 28, n01 = 12) | 0,00650 [0,00133 ; 0,01074] (n10 = 23, n01 = 10) | oui | oui | compatible | compatible | oui |
| 8x6 | PenteIntra | E | 0,05 | 2000 | 0,00550 [0,00113 ; 0,00874] (n10 = 17, n01 = 6) | 0,00300 [-0,00134 ; 0,00670] (n10 = 14, n01 = 8) | oui | oui | compatible | compatible | oui |
| 8x6 | PenteIntra | E | 0,10 | 2000 | 0,00650 [0,00104 ; 0,01114] (n10 = 25, n01 = 12) | 0,00500 [-0,00028 ; 0,00959] (n10 = 22, n01 = 12) | oui | oui | écart mineur | compatible | oui |
| 8x6 | Alpha | N | 0,05 | 2000 | -0,01050 [-0,01848 ; -0,00202] (n10 = 37, n01 = 58) | -0,01050 [-0,01858 ; -0,00193] (n10 = 38, n01 = 59) | non | oui | compatible | compatible | oui |
| 8x6 | Alpha | N | 0,10 | 2000 | -0,00250 [-0,01229 ; 0,00738] (n10 = 63, n01 = 68) | -0,00600 [-0,01610 ; 0,00429] (n10 = 65, n01 = 77) | oui | oui | compatible | compatible | oui |
| 8x6 | Alpha | E | 0,05 | 2000 | -0,00350 [-0,01047 ; 0,00371] (n10 = 30, n01 = 37) | -0,00700 [-0,01380 ; 0,00027] (n10 = 27, n01 = 41) | non | oui | compatible | compatible | oui |
| 8x6 | Alpha | E | 0,10 | 2000 | 0,01350 [0,00432 ; 0,02214] (n10 = 70, n01 = 43) | 0,00450 [-0,00465 ; 0,01346] (n10 = 60, n01 = 51) | non | oui | compatible | compatible | oui |

### K4 (couverture, comparative) : oui

Intervalle percentile à 90 % [q_0,05 ; q_0,95] de σ* (ic_bootstrap à la transformation affine près), cible σ_A^règle ; triangles admis aux deux intervalles définis (plus de 20 σ*), les autres comptés à part, ventilés par variante sans intervalle (V2 seule, V0 seule, les deux). V0 des blocs M7a, M5, M6 : boucle allégée ; M7b : mw_bootstrap().

| G | Loi | n | sans intervalle (V2 seule / V0 seule / les deux) | non-couverture V2 | non-couverture V0 | V2 − V0 Δ̂ [IC 90 %] | borne haute ≤ 0,02 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 8x5 | N | 2000 | 0 (0 / 0 / 0) | 0,3545 | 0,3550 | -0,00050 [-0,00212 ; 0,00155] (n10 = 2, n01 = 3) | oui |
| 8x5 | E | 2000 | 0 (0 / 0 / 0) | 0,2645 | 0,2645 | 0,00000 [-0,00161 ; 0,00161] (n10 = 2, n01 = 2) | oui |
| 8x6 | N | 2000 | 0 (0 / 0 / 0) | 0,1920 | 0,1920 | 0,00000 [-0,00095 ; 0,00095] (n10 = 1, n01 = 1) | oui |
| 8x6 | E | 2000 | 0 (0 / 0 / 0) | 0,1090 | 0,1090 | 0,00000 [-0,00095 ; 0,00095] (n10 = 1, n01 = 1) | oui |
| 8x7 | N | 2000 | 0 (0 / 0 / 0) | 0,1625 | 0,1645 | -0,00200 [-0,00200 ; 0,00011] (n10 = 0, n01 = 4) | oui |
| 8x7 | E | 2000 | 0 (0 / 0 / 0) | 0,0940 | 0,0945 | -0,00050 [-0,00145 ; 0,00109] (n10 = 1, n01 = 2) | oui |

Descriptif (hors critère K4) : tous les triangles appariés, un triangle sans intervalle comptant comme une non-couverture.

| G | Loi | n | non-couverture V2 | non-couverture V0 | V2 − V0 Δ̂ [IC 90 %] |
| --- | --- | --- | --- | --- | --- |
| 8x5 | N | 2000 | 0,3545 | 0,3550 | -0,00050 [-0,00212 ; 0,00155] (n10 = 2, n01 = 3) |
| 8x5 | E | 2000 | 0,2645 | 0,2645 | 0,00000 [-0,00161 ; 0,00161] (n10 = 2, n01 = 2) |
| 8x6 | N | 2000 | 0,1920 | 0,1920 | 0,00000 [-0,00095 ; 0,00095] (n10 = 1, n01 = 1) |
| 8x6 | E | 2000 | 0,1090 | 0,1090 | 0,00000 [-0,00095 ; 0,00095] (n10 = 1, n01 = 1) |
| 8x7 | N | 2000 | 0,1625 | 0,1645 | -0,00200 [-0,00200 ; 0,00011] (n10 = 0, n01 = 4) |
| 8x7 | E | 2000 | 0,0940 | 0,0945 | -0,00050 [-0,00145 ; 0,00109] (n10 = 1, n01 = 2) |

Descriptif : non-couverture à 95 %, queues séparées à 90 % (haute : q_0,95 < cible ; basse : q_0,05 > cible), largeurs moyennes, cibles σ_A^vrai et σ_B.

| G | Loi | Variante | nc 95 % | queue haute 90 % | queue basse 90 % | largeur 90 % | largeur 95 % | nc 90 % (σ_A^vrai) | nc 90 % (σ_B) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 8x5 | N | V2 | 0,3005 | 0,3535 | 0,0010 | 0,01120 | 0,01312 | 0,2075 | 0,2035 |
| 8x5 | N | V0 | 0,3010 | 0,3540 | 0,0010 | 0,01120 | 0,01313 | 0,2080 | 0,2040 |
| 8x5 | E | V2 | 0,2220 | 0,2645 | 0,0000 | 0,01115 | 0,01307 | 0,1340 | 0,1315 |
| 8x5 | E | V0 | 0,2220 | 0,2645 | 0,0000 | 0,01116 | 0,01308 | 0,1345 | 0,1320 |
| 8x6 | N | V2 | 0,1485 | 0,1830 | 0,0090 | 0,00990 | 0,01164 | 0,1665 | 0,1630 |
| 8x6 | N | V0 | 0,1485 | 0,1830 | 0,0090 | 0,00990 | 0,01164 | 0,1665 | 0,1620 |
| 8x6 | E | V2 | 0,0830 | 0,1090 | 0,0000 | 0,00947 | 0,01116 | 0,0885 | 0,0860 |
| 8x6 | E | V0 | 0,0830 | 0,1090 | 0,0000 | 0,00947 | 0,01117 | 0,0890 | 0,0855 |
| 8x7 | N | V2 | 0,1190 | 0,1470 | 0,0155 | 0,00856 | 0,01009 | 0,3625 | 0,3355 |
| 8x7 | N | V0 | 0,1190 | 0,1490 | 0,0155 | 0,00855 | 0,01008 | 0,3625 | 0,3360 |
| 8x7 | E | V2 | 0,0600 | 0,0910 | 0,0030 | 0,00788 | 0,00933 | 0,3345 | 0,3065 |
| 8x7 | E | V0 | 0,0600 | 0,0915 | 0,0030 | 0,00787 | 0,00932 | 0,3370 | 0,3070 |

### Règles (par. 4), évaluées mécaniquement, sans conclure

| Critère | K0 | K1 | K2 | K2′ | K3 | K4 |
| --- | --- | --- | --- | --- | --- | --- |
| tenu | oui | oui | oui | oui | oui | oui |

**Règle déclenchée mécaniquement : R-V2.** Lecture par actuary (étape 4), décision du mainteneur (PA-2). V1 se lit en composite : tests de V2 (K1 à K3), σ_boot de V0 (couverture V0 ci-dessus).

### Tables des 13 clés : τ_V2, τ_V0, τ du témoin, ρ, Δ̂ appariés

| G | Loi | α | Clé | n | τ_V2 | τ_V0 | τ_T | ρ | classe τ_V2 | Δ̂ V2 − T [IC 90 %] | Δ̂ V0 − T [IC 90 %] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 8x5 | N | 0,05 | Calendrier | 2000 | 0,03150 | 0,03150 | 0,02950 | 0,03434 | compatible | 0,00200 [-0,00011 ; 0,00200] (n10 = 4, n01 = 0) | 0,00200 [-0,00011 ; 0,00200] (n10 = 4, n01 = 0) |
| 8x5 | N | 0,05 | CorrDev | 2000 | 0,04200 | 0,04200 | 0,04550 | 0,04753 | compatible | -0,00350 [-0,00605 ; 0,00016] (n10 = 4, n01 = 11) | -0,00350 [-0,00605 ; 0,00016] (n10 = 4, n01 = 11) |
| 8x5 | N | 0,05 | BP | 2000 | 0,05050 | 0,05050 | 0,06050 | 0,04897 | compatible | -0,01000 [-0,01000 ; -0,00722] (n10 = 0, n01 = 20) | -0,01000 [-0,01000 ; -0,00722] (n10 = 0, n01 = 20) |
| 8x5 | N | 0,05 | MinP4 | 2000 | 0,02100 | 0,02100 | 0,04950 | 0,04897 | écart non tranché | -0,02850 [-0,03014 ; -0,02442] (n10 = 2, n01 = 59) | -0,02850 [-0,03014 ; -0,02442] (n10 = 2, n01 = 59) |
| 8x5 | N | 0,05 | DW | 2000 | 0,03950 | 0,03950 | 0,04350 | 0,04795 | compatible | -0,00400 [-0,00563 ; -0,00074] (n10 = 2, n01 = 10) | -0,00400 [-0,00563 ; -0,00074] (n10 = 2, n01 = 10) |
| 8x5 | N | 0,05 | Runs | 2000 | 0,03300 | 0,03300 | 0,03600 | 0,03331 | compatible | -0,00300 [-0,00300 ; -0,00064] (n10 = 0, n01 = 6) | -0,00300 [-0,00300 ; -0,00064] (n10 = 0, n01 = 6) |
| 8x5 | N | 0,05 | PenteIntra | 2000 | 0,05050 | 0,04850 | 0,04950 | 0,04795 | compatible | 0,00100 [-0,00245 ; 0,00411] (n10 = 8, n01 = 6) | -0,00100 [-0,00437 ; 0,00267] (n10 = 7, n01 = 9) |
| 8x5 | N | 0,05 | Origine | 2000 | 0,04950 | 0,04950 | 0,05350 | 0,04897 | compatible | -0,00400 [-0,00614 ; -0,00048] (n10 = 3, n01 = 11) | -0,00400 [-0,00614 ; -0,00048] (n10 = 3, n01 = 11) |
| 8x5 | N | 0,05 | HomogF | 2000 | 0,04850 | 0,04850 | 0,05250 | 0,04896 | compatible | -0,00400 [-0,00563 ; -0,00074] (n10 = 2, n01 = 10) | -0,00400 [-0,00563 ; -0,00074] (n10 = 2, n01 = 10) |
| 8x5 | N | 0,05 | Courbure | 2000 | 0,04750 | 0,04750 | 0,05250 | 0,04897 | compatible | -0,00500 [-0,00664 ; -0,00160] (n10 = 2, n01 = 12) | -0,00500 [-0,00664 ; -0,00160] (n10 = 2, n01 = 12) |
| 8x5 | N | 0,05 | Alpha | 2000 | 0,03950 | 0,04250 | 0,05350 | 0,04897 | compatible | -0,01400 [-0,02148 ; -0,00581] (n10 = 31, n01 = 59) | -0,01100 [-0,01947 ; -0,00206] (n10 = 42, n01 = 64) |
| 8x5 | N | 0,05 | ExpVar | 2000 | 0,04800 | 0,04800 | 0,04950 | 0,04897 | compatible | -0,00150 [-0,00362 ; 0,00140] (n10 = 3, n01 = 6) | -0,00150 [-0,00362 ; 0,00140] (n10 = 3, n01 = 6) |
| 8x5 | N | 0,05 | KruskalAcc | 2000 | 0,04600 | 0,04600 | 0,04550 | 0,04893 | compatible | 0,00050 [-0,00224 ; 0,00298] (n10 = 5, n01 = 4) | 0,00050 [-0,00224 ; 0,00298] (n10 = 5, n01 = 4) |
| 8x5 | N | 0,10 | Calendrier | 2000 | 0,08700 | 0,08700 | 0,10550 | 0,08132 | compatible | -0,01850 [-0,02212 ; -0,01314] (n10 = 7, n01 = 44) | -0,01850 [-0,02212 ; -0,01314] (n10 = 7, n01 = 44) |
| 8x5 | N | 0,10 | CorrDev | 2000 | 0,08800 | 0,08800 | 0,09150 | 0,09737 | compatible | -0,00350 [-0,00744 ; 0,00110] (n10 = 9, n01 = 16) | -0,00350 [-0,00744 ; 0,00110] (n10 = 9, n01 = 16) |
| 8x5 | N | 0,10 | BP | 2000 | 0,10900 | 0,10900 | 0,11900 | 0,09897 | compatible | -0,01000 [-0,01095 ; -0,00664] (n10 = 1, n01 = 21) | -0,01000 [-0,01095 ; -0,00664] (n10 = 1, n01 = 21) |
| 8x5 | N | 0,10 | MinP4 | 2000 | 0,05000 | 0,05000 | 0,10500 | 0,09897 | écart mineur | -0,05500 [-0,05595 ; -0,05133] (n10 = 1, n01 = 111) | -0,05500 [-0,05595 ; -0,05133] (n10 = 1, n01 = 111) |
| 8x5 | N | 0,10 | DW | 2000 | 0,08950 | 0,08950 | 0,09450 | 0,09795 | compatible | -0,00500 [-0,00792 ; -0,00089] (n10 = 5, n01 = 15) | -0,00500 [-0,00792 ; -0,00089] (n10 = 5, n01 = 15) |
| 8x5 | N | 0,10 | Runs | 2000 | 0,05750 | 0,05750 | 0,03600 | 0,06108 | compatible | 0,02150 [0,01861 ; 0,02150] (n10 = 43, n01 = 0) | 0,02150 [0,01861 ; 0,02150] (n10 = 43, n01 = 0) |
| 8x5 | N | 0,10 | PenteIntra | 2000 | 0,08950 | 0,08850 | 0,09400 | 0,09795 | compatible | -0,00450 [-0,00799 ; -0,00008] (n10 = 7, n01 = 16) | -0,00550 [-0,00874 ; -0,00113] (n10 = 6, n01 = 17) |
| 8x5 | N | 0,10 | Origine | 2000 | 0,10400 | 0,10400 | 0,10850 | 0,09897 | compatible | -0,00450 [-0,00614 ; -0,00117] (n10 = 2, n01 = 11) | -0,00450 [-0,00614 ; -0,00117] (n10 = 2, n01 = 11) |
| 8x5 | N | 0,10 | HomogF | 2000 | 0,09150 | 0,09150 | 0,09750 | 0,09896 | compatible | -0,00600 [-0,00952 ; -0,00138] (n10 = 7, n01 = 19) | -0,00600 [-0,00952 ; -0,00138] (n10 = 7, n01 = 19) |
| 8x5 | N | 0,10 | Courbure | 2000 | 0,09250 | 0,09250 | 0,09950 | 0,09897 | compatible | -0,00700 [-0,00864 ; -0,00342] (n10 = 2, n01 = 16) | -0,00700 [-0,00864 ; -0,00342] (n10 = 2, n01 = 16) |
| 8x5 | N | 0,10 | Alpha | 2000 | 0,09900 | 0,09850 | 0,10050 | 0,09897 | compatible | -0,00150 [-0,01188 ; 0,00892] (n10 = 72, n01 = 75) | -0,00200 [-0,01344 ; 0,00949] (n10 = 88, n01 = 92) |
| 8x5 | N | 0,10 | ExpVar | 2000 | 0,09450 | 0,09450 | 0,09950 | 0,09896 | compatible | -0,00500 [-0,00715 ; -0,00133] (n10 = 3, n01 = 13) | -0,00500 [-0,00715 ; -0,00133] (n10 = 3, n01 = 13) |
| 8x5 | N | 0,10 | KruskalAcc | 2000 | 0,09850 | 0,09850 | 0,09700 | 0,09889 | compatible | 0,00150 [-0,00189 ; 0,00435] (n10 = 8, n01 = 5) | 0,00150 [-0,00189 ; 0,00435] (n10 = 8, n01 = 5) |
| 8x5 | E | 0,05 | Calendrier | 2000 | 0,04200 | 0,04200 | 0,03750 | 0,03274 | écart mineur | 0,00450 [0,00195 ; 0,00450] (n10 = 9, n01 = 0) | 0,00450 [0,00195 ; 0,00450] (n10 = 9, n01 = 0) |
| 8x5 | E | 0,05 | CorrDev | 2000 | 0,04300 | 0,04300 | 0,04600 | 0,04752 | compatible | -0,00300 [-0,00589 ; 0,00077] (n10 = 5, n01 = 11) | -0,00300 [-0,00589 ; 0,00077] (n10 = 5, n01 = 11) |
| 8x5 | E | 0,05 | BP | 2000 | 0,05000 | 0,05000 | 0,04850 | 0,04897 | compatible | 0,00150 [-0,00140 ; 0,00362] (n10 = 6, n01 = 3) | 0,00150 [-0,00140 ; 0,00362] (n10 = 6, n01 = 3) |
| 8x5 | E | 0,05 | MinP4 | 2000 | 0,03250 | 0,03250 | 0,05250 | 0,04897 | écart mineur | -0,02000 [-0,02217 ; -0,01564] (n10 = 3, n01 = 43) | -0,02000 [-0,02217 ; -0,01564] (n10 = 3, n01 = 43) |
| 8x5 | E | 0,05 | DW | 2000 | 0,05250 | 0,05250 | 0,05100 | 0,04795 | compatible | 0,00150 [-0,00231 ; 0,00490] (n10 = 10, n01 = 7) | 0,00150 [-0,00231 ; 0,00490] (n10 = 10, n01 = 7) |
| 8x5 | E | 0,05 | Runs | 2000 | 0,03900 | 0,03900 | 0,04250 | 0,03327 | compatible | -0,00350 [-0,00350 ; -0,00106] (n10 = 0, n01 = 7) | -0,00350 [-0,00350 ; -0,00106] (n10 = 0, n01 = 7) |
| 8x5 | E | 0,05 | PenteIntra | 2000 | 0,05200 | 0,05100 | 0,05200 | 0,04795 | compatible | 0,00000 [-0,00396 ; 0,00396] (n10 = 10, n01 = 10) | -0,00100 [-0,00522 ; 0,00342] (n10 = 11, n01 = 13) |
| 8x5 | E | 0,05 | Origine | 2000 | 0,06050 | 0,06050 | 0,05700 | 0,04897 | écart mineur | 0,00350 [0,00064 ; 0,00445] (n10 = 8, n01 = 1) | 0,00350 [0,00064 ; 0,00445] (n10 = 8, n01 = 1) |
| 8x5 | E | 0,05 | HomogF | 2000 | 0,06050 | 0,06050 | 0,06600 | 0,04897 | écart mineur | -0,00550 [-0,00842 ; -0,00132] (n10 = 5, n01 = 16) | -0,00550 [-0,00842 ; -0,00132] (n10 = 5, n01 = 16) |
| 8x5 | E | 0,05 | Courbure | 2000 | 0,04350 | 0,04350 | 0,04700 | 0,04897 | compatible | -0,00350 [-0,00445 ; -0,00064] (n10 = 1, n01 = 8) | -0,00350 [-0,00445 ; -0,00064] (n10 = 1, n01 = 8) |
| 8x5 | E | 0,05 | Alpha | 2000 | 0,04800 | 0,04600 | 0,05350 | 0,04897 | compatible | -0,00550 [-0,01200 ; 0,00141] (n10 = 25, n01 = 36) | -0,00750 [-0,01465 ; 0,00011] (n10 = 30, n01 = 45) |
| 8x5 | E | 0,05 | ExpVar | 2000 | 0,04200 | 0,04200 | 0,04300 | 0,04897 | compatible | -0,00100 [-0,00262 ; 0,00137] (n10 = 2, n01 = 4) | -0,00100 [-0,00262 ; 0,00137] (n10 = 2, n01 = 4) |
| 8x5 | E | 0,05 | KruskalAcc | 2000 | 0,05750 | 0,05750 | 0,05700 | 0,04893 | compatible | 0,00050 [-0,00277 ; 0,00359] (n10 = 7, n01 = 6) | 0,00050 [-0,00277 ; 0,00359] (n10 = 7, n01 = 6) |
| 8x5 | E | 0,10 | Calendrier | 2000 | 0,08300 | 0,08300 | 0,10650 | 0,08285 | compatible | -0,02350 [-0,02514 ; -0,01946] (n10 = 2, n01 = 49) | -0,02350 [-0,02514 ; -0,01946] (n10 = 2, n01 = 49) |
| 8x5 | E | 0,10 | CorrDev | 2000 | 0,09950 | 0,09950 | 0,10200 | 0,09738 | compatible | -0,00250 [-0,00750 ; 0,00283] (n10 = 15, n01 = 20) | -0,00250 [-0,00750 ; 0,00283] (n10 = 15, n01 = 20) |
| 8x5 | E | 0,10 | BP | 2000 | 0,09000 | 0,09000 | 0,09000 | 0,09897 | compatible | 0,00000 [-0,00306 ; 0,00306] (n10 = 6, n01 = 6) | 0,00000 [-0,00306 ; 0,00306] (n10 = 6, n01 = 6) |
| 8x5 | E | 0,10 | MinP4 | 2000 | 0,06850 | 0,06850 | 0,10450 | 0,09897 | écart mineur | -0,03600 [-0,03818 ; -0,03148] (n10 = 3, n01 = 75) | -0,03600 [-0,03818 ; -0,03148] (n10 = 3, n01 = 75) |
| 8x5 | E | 0,10 | DW | 2000 | 0,10200 | 0,10200 | 0,10350 | 0,09795 | compatible | -0,00150 [-0,00611 ; 0,00335] (n10 = 13, n01 = 16) | -0,00150 [-0,00611 ; 0,00335] (n10 = 13, n01 = 16) |
| 8x5 | E | 0,10 | Runs | 2000 | 0,06200 | 0,06200 | 0,04250 | 0,05871 | compatible | 0,01950 [0,01662 ; 0,01950] (n10 = 39, n01 = 0) | 0,01950 [0,01662 ; 0,01950] (n10 = 39, n01 = 0) |
| 8x5 | E | 0,10 | PenteIntra | 2000 | 0,10350 | 0,10300 | 0,10350 | 0,09795 | compatible | 0,00000 [-0,00433 ; 0,00433] (n10 = 12, n01 = 12) | -0,00050 [-0,00487 ; 0,00397] (n10 = 12, n01 = 13) |
| 8x5 | E | 0,10 | Origine | 2000 | 0,10900 | 0,10900 | 0,11250 | 0,09897 | compatible | -0,00350 [-0,00564 ; -0,00007] (n10 = 3, n01 = 10) | -0,00350 [-0,00564 ; -0,00007] (n10 = 3, n01 = 10) |
| 8x5 | E | 0,10 | HomogF | 2000 | 0,11400 | 0,11400 | 0,11650 | 0,09896 | écart mineur | -0,00250 [-0,00567 ; 0,00137] (n10 = 6, n01 = 11) | -0,00250 [-0,00567 ; 0,00137] (n10 = 6, n01 = 11) |
| 8x5 | E | 0,10 | Courbure | 2000 | 0,08650 | 0,08650 | 0,09000 | 0,09897 | compatible | -0,00350 [-0,00513 ; -0,00033] (n10 = 2, n01 = 9) | -0,00350 [-0,00513 ; -0,00033] (n10 = 2, n01 = 9) |
| 8x5 | E | 0,10 | Alpha | 2000 | 0,10450 | 0,09850 | 0,10050 | 0,09897 | compatible | 0,00400 [-0,00510 ; 0,01294] (n10 = 59, n01 = 51) | -0,00200 [-0,01123 ; 0,00731] (n10 = 56, n01 = 60) |
| 8x5 | E | 0,10 | ExpVar | 2000 | 0,08900 | 0,08900 | 0,09600 | 0,09896 | compatible | -0,00700 [-0,00916 ; -0,00313] (n10 = 3, n01 = 17) | -0,00700 [-0,00916 ; -0,00313] (n10 = 3, n01 = 17) |
| 8x5 | E | 0,10 | KruskalAcc | 2000 | 0,10900 | 0,10900 | 0,11300 | 0,09890 | compatible | -0,00400 [-0,00656 ; -0,00025] (n10 = 4, n01 = 12) | -0,00400 [-0,00656 ; -0,00025] (n10 = 4, n01 = 12) |
| 8x6 | N | 0,05 | Calendrier | 2000 | 0,04450 | 0,04450 | 0,04500 | 0,04530 | compatible | -0,00050 [-0,00359 ; 0,00277] (n10 = 6, n01 = 7) | -0,00050 [-0,00359 ; 0,00277] (n10 = 6, n01 = 7) |
| 8x6 | N | 0,05 | CorrDev | 2000 | 0,04150 | 0,04150 | 0,04200 | 0,04760 | compatible | -0,00050 [-0,00408 ; 0,00322] (n10 = 8, n01 = 9) | -0,00050 [-0,00408 ; 0,00322] (n10 = 8, n01 = 9) |
| 8x6 | N | 0,05 | BP | 2000 | 0,05450 | 0,05450 | 0,06200 | 0,04897 | compatible | -0,00750 [-0,00914 ; -0,00388] (n10 = 2, n01 = 17) | -0,00750 [-0,00914 ; -0,00388] (n10 = 2, n01 = 17) |
| 8x6 | N | 0,05 | MinP4 | 2000 | 0,02200 | 0,02200 | 0,04950 | 0,04897 | écart non tranché | -0,02750 [-0,02750 ; -0,02458] (n10 = 0, n01 = 55) | -0,02750 [-0,02750 ; -0,02458] (n10 = 0, n01 = 55) |
| 8x6 | N | 0,05 | DW | 2000 | 0,03850 | 0,03850 | 0,04300 | 0,04795 | écart mineur | -0,00450 [-0,00706 ; -0,00067] (n10 = 4, n01 = 13) | -0,00450 [-0,00706 ; -0,00067] (n10 = 4, n01 = 13) |
| 8x6 | N | 0,05 | Runs | 2000 | 0,02400 | 0,02400 | 0,02100 | 0,02467 | compatible | 0,00300 [0,00064 ; 0,00300] (n10 = 6, n01 = 0) | 0,00300 [0,00064 ; 0,00300] (n10 = 6, n01 = 0) |
| 8x6 | N | 0,05 | PenteIntra | 2000 | 0,04950 | 0,04750 | 0,05100 | 0,04795 | compatible | -0,00150 [-0,00575 ; 0,00303] (n10 = 11, n01 = 14) | -0,00350 [-0,00821 ; 0,00171] (n10 = 13, n01 = 20) |
| 8x6 | N | 0,05 | Origine | 2000 | 0,05100 | 0,05100 | 0,05450 | 0,04897 | compatible | -0,00350 [-0,00564 ; -0,00007] (n10 = 3, n01 = 10) | -0,00350 [-0,00564 ; -0,00007] (n10 = 3, n01 = 10) |
| 8x6 | N | 0,05 | HomogF | 2000 | 0,05000 | 0,05000 | 0,05250 | 0,04896 | compatible | -0,00250 [-0,00345 ; 0,00014] (n10 = 1, n01 = 6) | -0,00250 [-0,00345 ; 0,00014] (n10 = 1, n01 = 6) |
| 8x6 | N | 0,05 | Courbure | 2000 | 0,04800 | 0,04800 | 0,05250 | 0,04897 | compatible | -0,00450 [-0,00545 ; -0,00149] (n10 = 1, n01 = 10) | -0,00450 [-0,00545 ; -0,00149] (n10 = 1, n01 = 10) |
| 8x6 | N | 0,05 | Alpha | 2000 | 0,04200 | 0,04200 | 0,05250 | 0,04897 | compatible | -0,01050 [-0,01848 ; -0,00202] (n10 = 37, n01 = 58) | -0,01050 [-0,01858 ; -0,00193] (n10 = 38, n01 = 59) |
| 8x6 | N | 0,05 | ExpVar | 2000 | 0,04950 | 0,04950 | 0,04950 | 0,04897 | compatible | 0,00000 [-0,00208 ; 0,00208] (n10 = 3, n01 = 3) | 0,00000 [-0,00208 ; 0,00208] (n10 = 3, n01 = 3) |
| 8x6 | N | 0,05 | KruskalAcc | 2000 | 0,04400 | 0,04400 | 0,04750 | 0,04897 | compatible | -0,00350 [-0,00350 ; -0,00106] (n10 = 0, n01 = 7) | -0,00350 [-0,00350 ; -0,00106] (n10 = 0, n01 = 7) |
| 8x6 | N | 0,10 | Calendrier | 2000 | 0,08600 | 0,08600 | 0,08750 | 0,08921 | compatible | -0,00150 [-0,00313 ; 0,00111] (n10 = 2, n01 = 5) | -0,00150 [-0,00313 ; 0,00111] (n10 = 2, n01 = 5) |
| 8x6 | N | 0,10 | CorrDev | 2000 | 0,09000 | 0,09000 | 0,09150 | 0,09752 | compatible | -0,00150 [-0,00556 ; 0,00287] (n10 = 10, n01 = 13) | -0,00150 [-0,00556 ; 0,00287] (n10 = 10, n01 = 13) |
| 8x6 | N | 0,10 | BP | 2000 | 0,10200 | 0,10200 | 0,11600 | 0,09897 | compatible | -0,01400 [-0,01400 ; -0,01116] (n10 = 0, n01 = 28) | -0,01400 [-0,01400 ; -0,01116] (n10 = 0, n01 = 28) |
| 8x6 | N | 0,10 | MinP4 | 2000 | 0,06200 | 0,06200 | 0,10500 | 0,09897 | écart mineur | -0,04300 [-0,04300 ; -0,04006] (n10 = 0, n01 = 86) | -0,04300 [-0,04300 ; -0,04006] (n10 = 0, n01 = 86) |
| 8x6 | N | 0,10 | DW | 2000 | 0,09150 | 0,09150 | 0,09600 | 0,09795 | compatible | -0,00450 [-0,00907 ; 0,00071] (n10 = 12, n01 = 21) | -0,00450 [-0,00907 ; 0,00071] (n10 = 12, n01 = 21) |
| 8x6 | N | 0,10 | Runs | 2000 | 0,06300 | 0,06300 | 0,06950 | 0,06778 | compatible | -0,00650 [-0,00650 ; -0,00382] (n10 = 0, n01 = 13) | -0,00650 [-0,00650 ; -0,00382] (n10 = 0, n01 = 13) |
| 8x6 | N | 0,10 | PenteIntra | 2000 | 0,10750 | 0,10600 | 0,09950 | 0,09795 | compatible | 0,00800 [0,00239 ; 0,01268] (n10 = 28, n01 = 12) | 0,00650 [0,00133 ; 0,01074] (n10 = 23, n01 = 10) |
| 8x6 | N | 0,10 | Origine | 2000 | 0,09850 | 0,09850 | 0,10800 | 0,09897 | compatible | -0,00950 [-0,01114 ; -0,00577] (n10 = 2, n01 = 21) | -0,00950 [-0,01114 ; -0,00577] (n10 = 2, n01 = 21) |
| 8x6 | N | 0,10 | HomogF | 2000 | 0,09250 | 0,09250 | 0,09750 | 0,09896 | compatible | -0,00500 [-0,00715 ; -0,00133] (n10 = 3, n01 = 13) | -0,00500 [-0,00715 ; -0,00133] (n10 = 3, n01 = 13) |
| 8x6 | N | 0,10 | Courbure | 2000 | 0,09200 | 0,09200 | 0,09950 | 0,09897 | compatible | -0,00750 [-0,01008 ; -0,00334] (n10 = 4, n01 = 19) | -0,00750 [-0,01008 ; -0,00334] (n10 = 4, n01 = 19) |
| 8x6 | N | 0,10 | Alpha | 2000 | 0,09750 | 0,09400 | 0,10000 | 0,09897 | compatible | -0,00250 [-0,01229 ; 0,00738] (n10 = 63, n01 = 68) | -0,00600 [-0,01610 ; 0,00429] (n10 = 65, n01 = 77) |
| 8x6 | N | 0,10 | ExpVar | 2000 | 0,09450 | 0,09450 | 0,09950 | 0,09896 | compatible | -0,00500 [-0,00757 ; -0,00110] (n10 = 4, n01 = 14) | -0,00500 [-0,00757 ; -0,00110] (n10 = 4, n01 = 14) |
| 8x6 | N | 0,10 | KruskalAcc | 2000 | 0,09250 | 0,09250 | 0,09600 | 0,09896 | compatible | -0,00350 [-0,00744 ; 0,00110] (n10 = 9, n01 = 16) | -0,00350 [-0,00744 ; 0,00110] (n10 = 9, n01 = 16) |
| 8x6 | E | 0,05 | Calendrier | 2000 | 0,05100 | 0,05100 | 0,05250 | 0,04586 | compatible | -0,00150 [-0,00313 ; 0,00111] (n10 = 2, n01 = 5) | -0,00150 [-0,00313 ; 0,00111] (n10 = 2, n01 = 5) |
| 8x6 | E | 0,05 | CorrDev | 2000 | 0,04700 | 0,04700 | 0,04600 | 0,04759 | compatible | 0,00100 [-0,00245 ; 0,00411] (n10 = 8, n01 = 6) | 0,00100 [-0,00245 ; 0,00411] (n10 = 8, n01 = 6) |
| 8x6 | E | 0,05 | BP | 2000 | 0,03950 | 0,03950 | 0,04250 | 0,04897 | compatible | -0,00300 [-0,00554 ; 0,00056] (n10 = 4, n01 = 10) | -0,00300 [-0,00554 ; 0,00056] (n10 = 4, n01 = 10) |
| 8x6 | E | 0,05 | MinP4 | 2000 | 0,03350 | 0,03350 | 0,05250 | 0,04897 | écart mineur | -0,01900 [-0,02161 ; -0,01435] (n10 = 4, n01 = 42) | -0,01900 [-0,02161 ; -0,01435] (n10 = 4, n01 = 42) |
| 8x6 | E | 0,05 | DW | 2000 | 0,05700 | 0,05700 | 0,05900 | 0,04795 | compatible | -0,00200 [-0,00542 ; 0,00194] (n10 = 7, n01 = 11) | -0,00200 [-0,00542 ; 0,00194] (n10 = 7, n01 = 11) |
| 8x6 | E | 0,05 | Runs | 2000 | 0,03300 | 0,03300 | 0,02950 | 0,02528 | écart mineur | 0,00350 [0,00106 ; 0,00350] (n10 = 7, n01 = 0) | 0,00350 [0,00106 ; 0,00350] (n10 = 7, n01 = 0) |
| 8x6 | E | 0,05 | PenteIntra | 2000 | 0,05600 | 0,05350 | 0,05050 | 0,04795 | compatible | 0,00550 [0,00113 ; 0,00874] (n10 = 17, n01 = 6) | 0,00300 [-0,00134 ; 0,00670] (n10 = 14, n01 = 8) |
| 8x6 | E | 0,05 | Origine | 2000 | 0,05350 | 0,05350 | 0,05100 | 0,04897 | compatible | 0,00250 [-0,00156 ; 0,00594] (n10 = 12, n01 = 7) | 0,00250 [-0,00156 ; 0,00594] (n10 = 12, n01 = 7) |
| 8x6 | E | 0,05 | HomogF | 2000 | 0,06050 | 0,06050 | 0,06600 | 0,04897 | écart mineur | -0,00550 [-0,00842 ; -0,00132] (n10 = 5, n01 = 16) | -0,00550 [-0,00842 ; -0,00132] (n10 = 5, n01 = 16) |
| 8x6 | E | 0,05 | Courbure | 2000 | 0,04400 | 0,04400 | 0,04700 | 0,04897 | compatible | -0,00300 [-0,00300 ; -0,00064] (n10 = 0, n01 = 6) | -0,00300 [-0,00300 ; -0,00064] (n10 = 0, n01 = 6) |
| 8x6 | E | 0,05 | Alpha | 2000 | 0,05000 | 0,04650 | 0,05350 | 0,04897 | compatible | -0,00350 [-0,01047 ; 0,00371] (n10 = 30, n01 = 37) | -0,00700 [-0,01380 ; 0,00027] (n10 = 27, n01 = 41) |
| 8x6 | E | 0,05 | ExpVar | 2000 | 0,03950 | 0,03950 | 0,04300 | 0,04897 | compatible | -0,00350 [-0,00513 ; -0,00033] (n10 = 2, n01 = 9) | -0,00350 [-0,00513 ; -0,00033] (n10 = 2, n01 = 9) |
| 8x6 | E | 0,05 | KruskalAcc | 2000 | 0,05600 | 0,05600 | 0,05700 | 0,04897 | compatible | -0,00100 [-0,00195 ; 0,00101] (n10 = 1, n01 = 3) | -0,00100 [-0,00195 ; 0,00101] (n10 = 1, n01 = 3) |
| 8x6 | E | 0,10 | Calendrier | 2000 | 0,09400 | 0,09400 | 0,09450 | 0,08907 | compatible | -0,00050 [-0,00145 ; 0,00109] (n10 = 1, n01 = 2) | -0,00050 [-0,00145 ; 0,00109] (n10 = 1, n01 = 2) |
| 8x6 | E | 0,10 | CorrDev | 2000 | 0,10300 | 0,10300 | 0,10150 | 0,09747 | compatible | 0,00150 [-0,00269 ; 0,00536] (n10 = 12, n01 = 9) | 0,00150 [-0,00269 ; 0,00536] (n10 = 12, n01 = 9) |
| 8x6 | E | 0,10 | BP | 2000 | 0,09000 | 0,09000 | 0,08750 | 0,09897 | compatible | 0,00250 [-0,00116 ; 0,00538] (n10 = 10, n01 = 5) | 0,00250 [-0,00116 ; 0,00538] (n10 = 10, n01 = 5) |
| 8x6 | E | 0,10 | MinP4 | 2000 | 0,07750 | 0,07750 | 0,10450 | 0,09897 | écart mineur | -0,02700 [-0,03034 ; -0,02168] (n10 = 6, n01 = 60) | -0,02700 [-0,03034 ; -0,02168] (n10 = 6, n01 = 60) |
| 8x6 | E | 0,10 | DW | 2000 | 0,10100 | 0,10100 | 0,10400 | 0,09795 | compatible | -0,00300 [-0,00713 ; 0,00167] (n10 = 10, n01 = 16) | -0,00300 [-0,00713 ; 0,00167] (n10 = 10, n01 = 16) |
| 8x6 | E | 0,10 | Runs | 2000 | 0,07550 | 0,07550 | 0,08150 | 0,06747 | compatible | -0,00600 [-0,00600 ; -0,00335] (n10 = 0, n01 = 12) | -0,00600 [-0,00600 ; -0,00335] (n10 = 0, n01 = 12) |
| 8x6 | E | 0,10 | PenteIntra | 2000 | 0,11250 | 0,11100 | 0,10600 | 0,09795 | écart mineur | 0,00650 [0,00104 ; 0,01114] (n10 = 25, n01 = 12) | 0,00500 [-0,00028 ; 0,00959] (n10 = 22, n01 = 12) |
| 8x6 | E | 0,10 | Origine | 2000 | 0,11400 | 0,11400 | 0,11500 | 0,09897 | écart mineur | -0,00100 [-0,00483 ; 0,00306] (n10 = 9, n01 = 11) | -0,00100 [-0,00483 ; 0,00306] (n10 = 9, n01 = 11) |
| 8x6 | E | 0,10 | HomogF | 2000 | 0,11150 | 0,11150 | 0,11650 | 0,09896 | compatible | -0,00500 [-0,00664 ; -0,00160] (n10 = 2, n01 = 12) | -0,00500 [-0,00664 ; -0,00160] (n10 = 2, n01 = 12) |
| 8x6 | E | 0,10 | Courbure | 2000 | 0,08550 | 0,08550 | 0,09000 | 0,09897 | écart mineur | -0,00450 [-0,00706 ; -0,00067] (n10 = 4, n01 = 13) | -0,00450 [-0,00706 ; -0,00067] (n10 = 4, n01 = 13) |
| 8x6 | E | 0,10 | Alpha | 2000 | 0,10750 | 0,09850 | 0,09400 | 0,09897 | compatible | 0,01350 [0,00432 ; 0,02214] (n10 = 70, n01 = 43) | 0,00450 [-0,00465 ; 0,01346] (n10 = 60, n01 = 51) |
| 8x6 | E | 0,10 | ExpVar | 2000 | 0,08500 | 0,08500 | 0,09600 | 0,09896 | écart mineur | -0,01100 [-0,01195 ; -0,00761] (n10 = 1, n01 = 23) | -0,01100 [-0,01195 ; -0,00761] (n10 = 1, n01 = 23) |
| 8x6 | E | 0,10 | KruskalAcc | 2000 | 0,10300 | 0,10300 | 0,10250 | 0,09896 | compatible | 0,00050 [-0,00322 ; 0,00408] (n10 = 9, n01 = 8) | 0,00050 [-0,00322 ; 0,00408] (n10 = 9, n01 = 8) |
| 8x7 | N | 0,05 | Calendrier | 2000 | 0,04100 | 0,04100 | 0,04150 | 0,04114 | compatible | -0,00050 [-0,00212 ; 0,00155] (n10 = 2, n01 = 3) | -0,00050 [-0,00212 ; 0,00155] (n10 = 2, n01 = 3) |
| 8x7 | N | 0,05 | CorrDev | 2000 | 0,03950 | 0,03950 | 0,04200 | 0,04760 | compatible | -0,00250 [-0,00594 ; 0,00156] (n10 = 7, n01 = 12) | -0,00250 [-0,00594 ; 0,00156] (n10 = 7, n01 = 12) |
| 8x7 | N | 0,05 | BP | 2000 | 0,05250 | 0,05250 | 0,06200 | 0,04897 | compatible | -0,00950 [-0,00950 ; -0,00673] (n10 = 0, n01 = 19) | -0,00950 [-0,00950 ; -0,00673] (n10 = 0, n01 = 19) |
| 8x7 | N | 0,05 | MinP4 | 2000 | 0,02300 | 0,02300 | 0,04950 | 0,04897 | écart non tranché | -0,02650 [-0,02650 ; -0,02359] (n10 = 0, n01 = 53) | -0,02650 [-0,02650 ; -0,02359] (n10 = 0, n01 = 53) |
| 8x7 | N | 0,05 | DW | 2000 | 0,03950 | 0,03950 | 0,04600 | 0,04795 | compatible | -0,00650 [-0,00745 ; -0,00331] (n10 = 1, n01 = 14) | -0,00650 [-0,00745 ; -0,00331] (n10 = 1, n01 = 14) |
| 8x7 | N | 0,05 | Runs | 2000 | 0,02650 | 0,02650 | 0,04800 | 0,03156 | compatible | -0,02150 [-0,02150 ; -0,01861] (n10 = 0, n01 = 43) | -0,02150 [-0,02150 ; -0,01861] (n10 = 0, n01 = 43) |
| 8x7 | N | 0,05 | PenteIntra | 2000 | 0,06050 | 0,07200 | 0,05250 | 0,04795 | écart mineur | 0,00800 [0,00301 ; 0,01181] (n10 = 24, n01 = 8) | 0,01950 [0,01484 ; 0,02211] (n10 = 43, n01 = 4) |
| 8x7 | N | 0,05 | Origine | 2000 | 0,05100 | 0,05100 | 0,05450 | 0,04897 | compatible | -0,00350 [-0,00564 ; -0,00007] (n10 = 3, n01 = 10) | -0,00350 [-0,00564 ; -0,00007] (n10 = 3, n01 = 10) |
| 8x7 | N | 0,05 | HomogF | 2000 | 0,04850 | 0,04850 | 0,05250 | 0,04896 | compatible | -0,00400 [-0,00495 ; -0,00106] (n10 = 1, n01 = 9) | -0,00400 [-0,00495 ; -0,00106] (n10 = 1, n01 = 9) |
| 8x7 | N | 0,05 | Courbure | 2000 | 0,04450 | 0,04450 | 0,05250 | 0,04897 | compatible | -0,00800 [-0,00800 ; -0,00527] (n10 = 0, n01 = 16) | -0,00800 [-0,00800 ; -0,00527] (n10 = 0, n01 = 16) |
| 8x7 | N | 0,05 | Alpha | 2000 | 0,04150 | 0,04150 | 0,05250 | 0,04897 | compatible | -0,01100 [-0,01880 ; -0,00265] (n10 = 35, n01 = 57) | -0,01100 [-0,01880 ; -0,00265] (n10 = 35, n01 = 57) |
| 8x7 | N | 0,05 | ExpVar | 2000 | 0,04950 | 0,04950 | 0,04950 | 0,04897 | compatible | 0,00000 [-0,00306 ; 0,00306] (n10 = 6, n01 = 6) | 0,00000 [-0,00306 ; 0,00306] (n10 = 6, n01 = 6) |
| 8x7 | N | 0,05 | KruskalAcc | 2000 | 0,05050 | 0,05050 | 0,04650 | 0,04897 | compatible | 0,00400 [0,00048 ; 0,00614] (n10 = 11, n01 = 3) | 0,00400 [0,00048 ; 0,00614] (n10 = 11, n01 = 3) |
| 8x7 | N | 0,10 | Calendrier | 2000 | 0,09850 | 0,09850 | 0,10250 | 0,09025 | compatible | -0,00400 [-0,00748 ; 0,00034] (n10 = 7, n01 = 15) | -0,00400 [-0,00748 ; 0,00034] (n10 = 7, n01 = 15) |
| 8x7 | N | 0,10 | CorrDev | 2000 | 0,09100 | 0,09100 | 0,09150 | 0,09752 | compatible | -0,00050 [-0,00384 ; 0,00300] (n10 = 7, n01 = 8) | -0,00050 [-0,00384 ; 0,00300] (n10 = 7, n01 = 8) |
| 8x7 | N | 0,10 | BP | 2000 | 0,10450 | 0,10450 | 0,11600 | 0,09897 | compatible | -0,01150 [-0,01150 ; -0,00869] (n10 = 0, n01 = 23) | -0,01150 [-0,01150 ; -0,00869] (n10 = 0, n01 = 23) |
| 8x7 | N | 0,10 | MinP4 | 2000 | 0,06800 | 0,06800 | 0,10500 | 0,09897 | écart mineur | -0,03700 [-0,03918 ; -0,03247] (n10 = 3, n01 = 77) | -0,03700 [-0,03918 ; -0,03247] (n10 = 3, n01 = 77) |
| 8x7 | N | 0,10 | DW | 2000 | 0,08950 | 0,08950 | 0,10150 | 0,09795 | compatible | -0,01200 [-0,01497 ; -0,00732] (n10 = 5, n01 = 29) | -0,01200 [-0,01497 ; -0,00732] (n10 = 5, n01 = 29) |
| 8x7 | N | 0,10 | Runs | 2000 | 0,05650 | 0,05650 | 0,04800 | 0,05332 | compatible | 0,00850 [0,00520 ; 0,00945] (n10 = 18, n01 = 1) | 0,00850 [0,00520 ; 0,00945] (n10 = 18, n01 = 1) |
| 8x7 | N | 0,10 | PenteIntra | 2000 | 0,11400 | 0,12400 | 0,10000 | 0,09795 | écart mineur | 0,01400 [0,00901 ; 0,01730] (n10 = 34, n01 = 6) | 0,02400 [0,01958 ; 0,02617] (n10 = 51, n01 = 3) |
| 8x7 | N | 0,10 | Origine | 2000 | 0,09900 | 0,09900 | 0,10800 | 0,09897 | compatible | -0,00900 [-0,00995 ; -0,00568] (n10 = 1, n01 = 19) | -0,00900 [-0,00995 ; -0,00568] (n10 = 1, n01 = 19) |
| 8x7 | N | 0,10 | HomogF | 2000 | 0,09600 | 0,09600 | 0,09750 | 0,09896 | compatible | -0,00150 [-0,00435 ; 0,00189] (n10 = 5, n01 = 8) | -0,00150 [-0,00435 ; 0,00189] (n10 = 5, n01 = 8) |
| 8x7 | N | 0,10 | Courbure | 2000 | 0,09300 | 0,09300 | 0,09950 | 0,09897 | compatible | -0,00650 [-0,00814 ; -0,00295] (n10 = 2, n01 = 15) | -0,00650 [-0,00814 ; -0,00295] (n10 = 2, n01 = 15) |
| 8x7 | N | 0,10 | Alpha | 2000 | 0,09750 | 0,09750 | 0,10000 | 0,09897 | compatible | -0,00250 [-0,01243 ; 0,00752] (n10 = 65, n01 = 70) | -0,00250 [-0,01243 ; 0,00752] (n10 = 65, n01 = 70) |
| 8x7 | N | 0,10 | ExpVar | 2000 | 0,09750 | 0,09750 | 0,09950 | 0,09896 | compatible | -0,00200 [-0,00453 ; 0,00131] (n10 = 4, n01 = 8) | -0,00200 [-0,00453 ; 0,00131] (n10 = 4, n01 = 8) |
| 8x7 | N | 0,10 | KruskalAcc | 2000 | 0,09750 | 0,09750 | 0,09800 | 0,09897 | compatible | -0,00050 [-0,00384 ; 0,00300] (n10 = 7, n01 = 8) | -0,00050 [-0,00384 ; 0,00300] (n10 = 7, n01 = 8) |
| 8x7 | E | 0,05 | Calendrier | 2000 | 0,04150 | 0,04150 | 0,04150 | 0,04128 | compatible | 0,00000 [-0,00161 ; 0,00161] (n10 = 2, n01 = 2) | 0,00000 [-0,00161 ; 0,00161] (n10 = 2, n01 = 2) |
| 8x7 | E | 0,05 | CorrDev | 2000 | 0,04900 | 0,04900 | 0,04600 | 0,04759 | compatible | 0,00300 [-0,00097 ; 0,00619] (n10 = 12, n01 = 6) | 0,00300 [-0,00097 ; 0,00619] (n10 = 12, n01 = 6) |
| 8x7 | E | 0,05 | BP | 2000 | 0,03950 | 0,03950 | 0,04250 | 0,04897 | compatible | -0,00300 [-0,00589 ; 0,00077] (n10 = 5, n01 = 11) | -0,00300 [-0,00589 ; 0,00077] (n10 = 5, n01 = 11) |
| 8x7 | E | 0,05 | MinP4 | 2000 | 0,03350 | 0,03350 | 0,05250 | 0,04897 | écart mineur | -0,01900 [-0,02064 ; -0,01502] (n10 = 2, n01 = 40) | -0,01900 [-0,02064 ; -0,01502] (n10 = 2, n01 = 40) |
| 8x7 | E | 0,05 | DW | 2000 | 0,05300 | 0,05300 | 0,05600 | 0,04795 | compatible | -0,00300 [-0,00645 ; 0,00116] (n10 = 7, n01 = 13) | -0,00300 [-0,00645 ; 0,00116] (n10 = 7, n01 = 13) |
| 8x7 | E | 0,05 | Runs | 2000 | 0,03650 | 0,03650 | 0,03700 | 0,02943 | compatible | -0,00050 [-0,00260 ; 0,00192] (n10 = 3, n01 = 4) | -0,00050 [-0,00260 ; 0,00192] (n10 = 3, n01 = 4) |
| 8x7 | E | 0,05 | PenteIntra | 2000 | 0,06050 | 0,07050 | 0,04300 | 0,04795 | écart mineur | 0,01750 [0,01238 ; 0,02082] (n10 = 41, n01 = 6) | 0,02750 [0,02304 ; 0,02967] (n10 = 58, n01 = 3) |
| 8x7 | E | 0,05 | Origine | 2000 | 0,05250 | 0,05250 | 0,05100 | 0,04897 | compatible | 0,00150 [-0,00111 ; 0,00313] (n10 = 5, n01 = 2) | 0,00150 [-0,00111 ; 0,00313] (n10 = 5, n01 = 2) |
| 8x7 | E | 0,05 | HomogF | 2000 | 0,06150 | 0,06150 | 0,06600 | 0,04897 | écart mineur | -0,00450 [-0,00772 ; -0,00026] (n10 = 6, n01 = 15) | -0,00450 [-0,00772 ; -0,00026] (n10 = 6, n01 = 15) |
| 8x7 | E | 0,05 | Courbure | 2000 | 0,04300 | 0,04300 | 0,04700 | 0,04897 | compatible | -0,00400 [-0,00495 ; -0,00106] (n10 = 1, n01 = 9) | -0,00400 [-0,00495 ; -0,00106] (n10 = 1, n01 = 9) |
| 8x7 | E | 0,05 | Alpha | 2000 | 0,05000 | 0,05000 | 0,05350 | 0,04897 | compatible | -0,00350 [-0,01014 ; 0,00340] (n10 = 27, n01 = 34) | -0,00350 [-0,01014 ; 0,00340] (n10 = 27, n01 = 34) |
| 8x7 | E | 0,05 | ExpVar | 2000 | 0,03800 | 0,03800 | 0,04300 | 0,04897 | écart mineur | -0,00500 [-0,00595 ; -0,00194] (n10 = 1, n01 = 11) | -0,00500 [-0,00595 ; -0,00194] (n10 = 1, n01 = 11) |
| 8x7 | E | 0,05 | KruskalAcc | 2000 | 0,05100 | 0,05100 | 0,05200 | 0,04897 | compatible | -0,00100 [-0,00195 ; 0,00101] (n10 = 1, n01 = 3) | -0,00100 [-0,00195 ; 0,00101] (n10 = 1, n01 = 3) |
| 8x7 | E | 0,10 | Calendrier | 2000 | 0,09150 | 0,09150 | 0,09600 | 0,09036 | compatible | -0,00450 [-0,00614 ; -0,00117] (n10 = 2, n01 = 11) | -0,00450 [-0,00614 ; -0,00117] (n10 = 2, n01 = 11) |
| 8x7 | E | 0,10 | CorrDev | 2000 | 0,10050 | 0,10050 | 0,10150 | 0,09747 | compatible | -0,00100 [-0,00483 ; 0,00306] (n10 = 9, n01 = 11) | -0,00100 [-0,00483 ; 0,00306] (n10 = 9, n01 = 11) |
| 8x7 | E | 0,10 | BP | 2000 | 0,08550 | 0,08550 | 0,08750 | 0,09897 | écart mineur | -0,00200 [-0,00588 ; 0,00231] (n10 = 9, n01 = 13) | -0,00200 [-0,00588 ; 0,00231] (n10 = 9, n01 = 13) |
| 8x7 | E | 0,10 | MinP4 | 2000 | 0,07750 | 0,07750 | 0,10450 | 0,09897 | écart mineur | -0,02700 [-0,03093 ; -0,02123] (n10 = 8, n01 = 62) | -0,02700 [-0,03093 ; -0,02123] (n10 = 8, n01 = 62) |
| 8x7 | E | 0,10 | DW | 2000 | 0,10550 | 0,10550 | 0,10400 | 0,09795 | compatible | 0,00150 [-0,00335 ; 0,00611] (n10 = 16, n01 = 13) | 0,00150 [-0,00335 ; 0,00611] (n10 = 16, n01 = 13) |
| 8x7 | E | 0,10 | Runs | 2000 | 0,06550 | 0,06550 | 0,05150 | 0,05483 | écart mineur | 0,01400 [0,01116 ; 0,01400] (n10 = 28, n01 = 0) | 0,01400 [0,01116 ; 0,01400] (n10 = 28, n01 = 0) |
| 8x7 | E | 0,10 | PenteIntra | 2000 | 0,11550 | 0,12600 | 0,09850 | 0,09795 | écart mineur | 0,01700 [0,01240 ; 0,01961] (n10 = 38, n01 = 4) | 0,02750 [0,02272 ; 0,03012] (n10 = 59, n01 = 4) |
| 8x7 | E | 0,10 | Origine | 2000 | 0,11150 | 0,11150 | 0,11500 | 0,09897 | compatible | -0,00350 [-0,00744 ; 0,00110] (n10 = 9, n01 = 16) | -0,00350 [-0,00744 ; 0,00110] (n10 = 9, n01 = 16) |
| 8x7 | E | 0,10 | HomogF | 2000 | 0,11400 | 0,11400 | 0,11650 | 0,09896 | écart mineur | -0,00250 [-0,00538 ; 0,00116] (n10 = 5, n01 = 10) | -0,00250 [-0,00538 ; 0,00116] (n10 = 5, n01 = 10) |
| 8x7 | E | 0,10 | Courbure | 2000 | 0,08350 | 0,08350 | 0,09000 | 0,09897 | écart mineur | -0,00650 [-0,00745 ; -0,00331] (n10 = 1, n01 = 14) | -0,00650 [-0,00745 ; -0,00331] (n10 = 1, n01 = 14) |
| 8x7 | E | 0,10 | Alpha | 2000 | 0,10300 | 0,10300 | 0,09400 | 0,09897 | compatible | 0,00900 [-0,00012 ; 0,01774] (n10 = 64, n01 = 46) | 0,00900 [-0,00012 ; 0,01774] (n10 = 64, n01 = 46) |
| 8x7 | E | 0,10 | ExpVar | 2000 | 0,08850 | 0,08850 | 0,09600 | 0,09896 | compatible | -0,00750 [-0,00914 ; -0,00388] (n10 = 2, n01 = 17) | -0,00750 [-0,00914 ; -0,00388] (n10 = 2, n01 = 17) |
| 8x7 | E | 0,10 | KruskalAcc | 2000 | 0,10650 | 0,10650 | 0,10700 | 0,09896 | compatible | -0,00050 [-0,00430 ; 0,00342] (n10 = 9, n01 = 10) | -0,00050 [-0,00430 ; 0,00342] (n10 = 9, n01 = 10) |
| 8x8 (carré) | N | 0,05 | Calendrier | 2000 | 0,04300 | = V2 | 0,04150 | 0,04114 | compatible | 0,00150 [-0,00039 ; 0,00150] (n10 = 3, n01 = 0) | — |
| 8x8 (carré) | N | 0,05 | CorrDev | 2000 | 0,04000 | = V2 | 0,04200 | 0,04760 | compatible | -0,00200 [-0,00609 ; 0,00248] (n10 = 10, n01 = 14) | — |
| 8x8 (carré) | N | 0,05 | BP | 2000 | 0,05100 | = V2 | 0,06200 | 0,04897 | compatible | -0,01100 [-0,01100 ; -0,00820] (n10 = 0, n01 = 22) | — |
| 8x8 (carré) | N | 0,05 | MinP4 | 2000 | 0,02300 | = V2 | 0,04950 | 0,04897 | écart non tranché | -0,02650 [-0,02650 ; -0,02359] (n10 = 0, n01 = 53) | — |
| 8x8 (carré) | N | 0,05 | DW | 2000 | 0,03950 | = V2 | 0,04600 | 0,04795 | compatible | -0,00650 [-0,00814 ; -0,00295] (n10 = 2, n01 = 15) | — |
| 8x8 (carré) | N | 0,05 | Runs | 2000 | 0,02850 | = V2 | 0,04800 | 0,03156 | compatible | -0,01950 [-0,01950 ; -0,01662] (n10 = 0, n01 = 39) | — |
| 8x8 (carré) | N | 0,05 | PenteIntra | 2000 | 0,06000 | = V2 | 0,05250 | 0,04795 | écart mineur | 0,00750 [0,00273 ; 0,01104] (n10 = 22, n01 = 7) | — |
| 8x8 (carré) | N | 0,05 | Origine | 2000 | 0,05000 | = V2 | 0,05450 | 0,04897 | compatible | -0,00450 [-0,00614 ; -0,00117] (n10 = 2, n01 = 11) | — |
| 8x8 (carré) | N | 0,05 | HomogF | 2000 | 0,04850 | = V2 | 0,05250 | 0,04896 | compatible | -0,00400 [-0,00563 ; -0,00074] (n10 = 2, n01 = 10) | — |
| 8x8 (carré) | N | 0,05 | Courbure | 2000 | 0,04550 | = V2 | 0,05250 | 0,04897 | compatible | -0,00700 [-0,00795 ; -0,00378] (n10 = 1, n01 = 15) | — |
| 8x8 (carré) | N | 0,05 | Alpha | 2000 | 0,04050 | = V2 | 0,05250 | 0,04897 | compatible | -0,01200 [-0,01963 ; -0,00376] (n10 = 33, n01 = 57) | — |
| 8x8 (carré) | N | 0,05 | ExpVar | 2000 | 0,04700 | = V2 | 0,04950 | 0,04897 | compatible | -0,00250 [-0,00413 ; 0,00045] (n10 = 2, n01 = 7) | — |
| 8x8 (carré) | N | 0,05 | KruskalAcc | 2000 | 0,04950 | = V2 | 0,04650 | 0,04897 | compatible | 0,00300 [-0,00007 ; 0,00463] (n10 = 8, n01 = 2) | — |
| 8x8 (carré) | N | 0,10 | Calendrier | 2000 | 0,10000 | = V2 | 0,10250 | 0,09025 | compatible | -0,00250 [-0,00661 ; 0,00208] (n10 = 10, n01 = 15) | — |
| 8x8 (carré) | N | 0,10 | CorrDev | 2000 | 0,09200 | = V2 | 0,09150 | 0,09752 | compatible | 0,00050 [-0,00379 ; 0,00469] (n10 = 12, n01 = 11) | — |
| 8x8 (carré) | N | 0,10 | BP | 2000 | 0,10600 | = V2 | 0,11600 | 0,09897 | compatible | -0,01000 [-0,01000 ; -0,00722] (n10 = 0, n01 = 20) | — |
| 8x8 (carré) | N | 0,10 | MinP4 | 2000 | 0,06450 | = V2 | 0,10500 | 0,09897 | écart mineur | -0,04050 [-0,04145 ; -0,03686] (n10 = 1, n01 = 82) | — |
| 8x8 (carré) | N | 0,10 | DW | 2000 | 0,09000 | = V2 | 0,10150 | 0,09795 | compatible | -0,01150 [-0,01314 ; -0,00769] (n10 = 2, n01 = 25) | — |
| 8x8 (carré) | N | 0,10 | Runs | 2000 | 0,06300 | = V2 | 0,04800 | 0,05332 | compatible | 0,01500 [0,01215 ; 0,01500] (n10 = 30, n01 = 0) | — |
| 8x8 (carré) | N | 0,10 | PenteIntra | 2000 | 0,11250 | = V2 | 0,10000 | 0,09795 | écart mineur | 0,01250 [0,00738 ; 0,01609] (n10 = 32, n01 = 7) | — |
| 8x8 (carré) | N | 0,10 | Origine | 2000 | 0,09650 | = V2 | 0,10800 | 0,09897 | compatible | -0,01150 [-0,01245 ; -0,00810] (n10 = 1, n01 = 24) | — |
| 8x8 (carré) | N | 0,10 | HomogF | 2000 | 0,09400 | = V2 | 0,09750 | 0,09896 | compatible | -0,00350 [-0,00564 ; -0,00007] (n10 = 3, n01 = 10) | — |
| 8x8 (carré) | N | 0,10 | Courbure | 2000 | 0,09350 | = V2 | 0,09950 | 0,09897 | compatible | -0,00600 [-0,00764 ; -0,00250] (n10 = 2, n01 = 14) | — |
| 8x8 (carré) | N | 0,10 | Alpha | 2000 | 0,09500 | = V2 | 0,10000 | 0,09897 | compatible | -0,00500 [-0,01484 ; 0,00500] (n10 = 62, n01 = 72) | — |
| 8x8 (carré) | N | 0,10 | ExpVar | 2000 | 0,09850 | = V2 | 0,09950 | 0,09896 | compatible | -0,00100 [-0,00437 ; 0,00267] (n10 = 7, n01 = 9) | — |
| 8x8 (carré) | N | 0,10 | KruskalAcc | 2000 | 0,09800 | = V2 | 0,09800 | 0,09897 | compatible | 0,00000 [-0,00354 ; 0,00354] (n10 = 8, n01 = 8) | — |
| 8x8 (carré) | E | 0,05 | Calendrier | 2000 | 0,04150 | = V2 | 0,04150 | 0,04128 | compatible | 0,00000 [0,00000 ; 0,00000] (n10 = 0, n01 = 0) | — |
| 8x8 (carré) | E | 0,05 | CorrDev | 2000 | 0,04600 | = V2 | 0,04600 | 0,04759 | compatible | 0,00000 [-0,00331 ; 0,00331] (n10 = 7, n01 = 7) | — |
| 8x8 (carré) | E | 0,05 | BP | 2000 | 0,04050 | = V2 | 0,04250 | 0,04897 | compatible | -0,00200 [-0,00295 ; 0,00049] (n10 = 1, n01 = 5) | — |
| 8x8 (carré) | E | 0,05 | MinP4 | 2000 | 0,03300 | = V2 | 0,05250 | 0,04897 | écart mineur | -0,01950 [-0,02114 ; -0,01551] (n10 = 2, n01 = 41) | — |
| 8x8 (carré) | E | 0,05 | DW | 2000 | 0,05500 | = V2 | 0,05600 | 0,04795 | compatible | -0,00100 [-0,00437 ; 0,00267] (n10 = 7, n01 = 9) | — |
| 8x8 (carré) | E | 0,05 | Runs | 2000 | 0,03850 | = V2 | 0,03700 | 0,02943 | écart mineur | 0,00150 [-0,00211 ; 0,00464] (n10 = 9, n01 = 6) | — |
| 8x8 (carré) | E | 0,05 | PenteIntra | 2000 | 0,05550 | = V2 | 0,04300 | 0,04795 | compatible | 0,01250 [0,00832 ; 0,01467] (n10 = 28, n01 = 3) | — |
| 8x8 (carré) | E | 0,05 | Origine | 2000 | 0,05350 | = V2 | 0,05100 | 0,04897 | compatible | 0,00250 [-0,00116 ; 0,00538] (n10 = 10, n01 = 5) | — |
| 8x8 (carré) | E | 0,05 | HomogF | 2000 | 0,06350 | = V2 | 0,06600 | 0,04897 | écart mineur | -0,00250 [-0,00463 ; 0,00071] (n10 = 3, n01 = 8) | — |
| 8x8 (carré) | E | 0,05 | Courbure | 2000 | 0,04450 | = V2 | 0,04700 | 0,04897 | compatible | -0,00250 [-0,00463 ; 0,00071] (n10 = 3, n01 = 8) | — |
| 8x8 (carré) | E | 0,05 | Alpha | 2000 | 0,05150 | = V2 | 0,05350 | 0,04897 | compatible | -0,00200 [-0,00888 ; 0,00503] (n10 = 30, n01 = 34) | — |
| 8x8 (carré) | E | 0,05 | ExpVar | 2000 | 0,04050 | = V2 | 0,04300 | 0,04897 | compatible | -0,00250 [-0,00413 ; 0,00045] (n10 = 2, n01 = 7) | — |
| 8x8 (carré) | E | 0,05 | KruskalAcc | 2000 | 0,05100 | = V2 | 0,05200 | 0,04897 | compatible | -0,00100 [-0,00262 ; 0,00137] (n10 = 2, n01 = 4) | — |
| 8x8 (carré) | E | 0,10 | Calendrier | 2000 | 0,09000 | = V2 | 0,09600 | 0,09036 | compatible | -0,00600 [-0,00893 ; -0,00176] (n10 = 5, n01 = 17) | — |
| 8x8 (carré) | E | 0,10 | CorrDev | 2000 | 0,10100 | = V2 | 0,10150 | 0,09747 | compatible | -0,00050 [-0,00469 ; 0,00379] (n10 = 11, n01 = 12) | — |
| 8x8 (carré) | E | 0,10 | BP | 2000 | 0,08750 | = V2 | 0,08750 | 0,09897 | compatible | 0,00000 [-0,00331 ; 0,00331] (n10 = 7, n01 = 7) | — |
| 8x8 (carré) | E | 0,10 | MinP4 | 2000 | 0,07750 | = V2 | 0,10450 | 0,09897 | écart mineur | -0,02700 [-0,03065 ; -0,02144] (n10 = 7, n01 = 61) | — |
| 8x8 (carré) | E | 0,10 | DW | 2000 | 0,10300 | = V2 | 0,10400 | 0,09795 | compatible | -0,00100 [-0,00483 ; 0,00306] (n10 = 9, n01 = 11) | — |
| 8x8 (carré) | E | 0,10 | Runs | 2000 | 0,06450 | = V2 | 0,05150 | 0,05483 | compatible | 0,01300 [0,01017 ; 0,01300] (n10 = 26, n01 = 0) | — |
| 8x8 (carré) | E | 0,10 | PenteIntra | 2000 | 0,11350 | = V2 | 0,09850 | 0,09795 | écart mineur | 0,01500 [0,00957 ; 0,01888] (n10 = 38, n01 = 8) | — |
| 8x8 (carré) | E | 0,10 | Origine | 2000 | 0,11250 | = V2 | 0,11500 | 0,09897 | écart mineur | -0,00250 [-0,00594 ; 0,00156] (n10 = 7, n01 = 12) | — |
| 8x8 (carré) | E | 0,10 | HomogF | 2000 | 0,11400 | = V2 | 0,11650 | 0,09896 | écart mineur | -0,00250 [-0,00463 ; 0,00071] (n10 = 3, n01 = 8) | — |
| 8x8 (carré) | E | 0,10 | Courbure | 2000 | 0,08550 | = V2 | 0,09000 | 0,09897 | écart mineur | -0,00450 [-0,00706 ; -0,00067] (n10 = 4, n01 = 13) | — |
| 8x8 (carré) | E | 0,10 | Alpha | 2000 | 0,10500 | = V2 | 0,09400 | 0,09897 | compatible | 0,01100 [0,00166 ; 0,01991] (n10 = 69, n01 = 47) | — |
| 8x8 (carré) | E | 0,10 | ExpVar | 2000 | 0,08700 | = V2 | 0,09600 | 0,09896 | compatible | -0,00900 [-0,00995 ; -0,00568] (n10 = 1, n01 = 19) | — |
| 8x8 (carré) | E | 0,10 | KruskalAcc | 2000 | 0,10850 | = V2 | 0,10700 | 0,09896 | compatible | 0,00150 [-0,00303 ; 0,00575] (n10 = 14, n01 = 11) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,05 | Calendrier | 1000 | 0,03800 | = V2 | 0,03800 | 0,03392 | compatible | 0,00000 [0,00000 ; 0,00000] (n10 = 0, n01 = 0) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,05 | CorrDev | 1000 | 0,03500 | = V2 | 0,03500 | 0,04362 | compatible | 0,00000 [-0,00322 ; 0,00322] (n10 = 2, n01 = 2) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,05 | BP | 1000 | 0,03400 | = V2 | 0,04600 | 0,04897 | écart mineur | -0,01200 [-0,01200 ; -0,00670] (n10 = 0, n01 = 12) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,05 | MinP4 | 1000 | 0,01400 | = V2 | 0,04500 | 0,04897 | distorsion matérielle (**conservateur**) | -0,03100 [-0,03100 ; -0,02529] (n10 = 0, n01 = 31) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,05 | DW | 1000 | 0,04800 | = V2 | 0,05000 | 0,04795 | compatible | -0,00200 [-0,00525 ; 0,00274] (n10 = 2, n01 = 4) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,05 | Runs | 1000 | 0,01700 | = V2 | 0,01700 | 0,02252 | compatible | 0,00000 [0,00000 ; 0,00000] (n10 = 0, n01 = 0) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,05 | PenteIntra | 1000 | 0,05800 | = V2 | 0,05400 | 0,04795 | compatible | 0,00400 [-0,00213 ; 0,00825] (n10 = 7, n01 = 3) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,05 | Origine | 1000 | 0,03400 | = V2 | 0,04100 | 0,04897 | écart mineur | -0,00700 [-0,00700 ; -0,00213] (n10 = 0, n01 = 7) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,05 | HomogF | 1000 | 0,04000 | = V2 | 0,04300 | 0,04889 | compatible | -0,00300 [-0,00625 ; 0,00222] (n10 = 2, n01 = 5) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,05 | Courbure | 1000 | 0,04500 | = V2 | 0,05000 | 0,04897 | compatible | -0,00500 [-0,00690 ; 0,00029] (n10 = 1, n01 = 6) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,05 | Alpha | 1000 | 0,03800 | = V2 | 0,04500 | 0,04897 | compatible | -0,00700 [-0,01799 ; 0,00475] (n10 = 18, n01 = 25) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,05 | ExpVar | 1000 | 0,03700 | = V2 | 0,04000 | 0,04889 | compatible | -0,00300 [-0,00625 ; 0,00222] (n10 = 2, n01 = 5) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,05 | KruskalAcc | 1000 | 0,04900 | = V2 | 0,04800 | 0,04892 | compatible | 0,00100 [-0,00385 ; 0,00520] (n10 = 4, n01 = 3) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,10 | Calendrier | 1000 | 0,09400 | = V2 | 0,09000 | 0,08165 | compatible | 0,00400 [-0,00022 ; 0,00400] (n10 = 4, n01 = 0) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,10 | CorrDev | 1000 | 0,07800 | = V2 | 0,07900 | 0,09245 | compatible | -0,00100 [-0,00769 ; 0,00600] (n10 = 7, n01 = 8) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,10 | BP | 1000 | 0,07800 | = V2 | 0,09000 | 0,09897 | écart mineur | -0,01200 [-0,01390 ; -0,00569] (n10 = 1, n01 = 13) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,10 | MinP4 | 1000 | 0,05500 | = V2 | 0,09600 | 0,09897 | écart mineur | -0,04100 [-0,04100 ; -0,03522] (n10 = 0, n01 = 41) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,10 | DW | 1000 | 0,09800 | = V2 | 0,10400 | 0,09795 | compatible | -0,00600 [-0,00926 ; 0,00014] (n10 = 2, n01 = 8) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,10 | Runs | 1000 | 0,07700 | = V2 | 0,09000 | 0,07508 | compatible | -0,01300 [-0,01300 ; -0,00765] (n10 = 0, n01 = 13) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,10 | PenteIntra | 1000 | 0,11500 | = V2 | 0,10600 | 0,09795 | compatible | 0,00900 [0,00092 ; 0,01482] (n10 = 14, n01 = 5) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,10 | Origine | 1000 | 0,09300 | = V2 | 0,09800 | 0,09897 | compatible | -0,00500 [-0,00690 ; 0,00029] (n10 = 1, n01 = 6) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,10 | HomogF | 1000 | 0,07100 | = V2 | 0,07900 | 0,09883 | écart mineur | -0,00800 [-0,00990 ; -0,00212] (n10 = 1, n01 = 9) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,10 | Courbure | 1000 | 0,09700 | = V2 | 0,10400 | 0,09897 | compatible | -0,00700 [-0,00890 ; -0,00128] (n10 = 1, n01 = 8) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,10 | Alpha | 1000 | 0,09100 | = V2 | 0,08800 | 0,09897 | compatible | 0,00300 [-0,01231 ; 0,01813] (n10 = 40, n01 = 37) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,10 | ExpVar | 1000 | 0,08900 | = V2 | 0,09400 | 0,09884 | compatible | -0,00500 [-0,00690 ; 0,00029] (n10 = 1, n01 = 6) | — |
| D (8 x 6, σ²_2 = 0) | N | 0,10 | KruskalAcc | 1000 | 0,10400 | = V2 | 0,10800 | 0,09888 | compatible | -0,00400 [-0,00726 ; 0,00160] (n10 = 2, n01 = 6) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,05 | Calendrier | 1000 | 0,03100 | = V2 | 0,03100 | 0,03404 | compatible | 0,00000 [0,00000 ; 0,00000] (n10 = 0, n01 = 0) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,05 | CorrDev | 1000 | 0,05100 | = V2 | 0,05400 | 0,04358 | compatible | -0,00300 [-0,00724 ; 0,00279] (n10 = 3, n01 = 6) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,05 | BP | 1000 | 0,04600 | = V2 | 0,04600 | 0,04897 | compatible | 0,00000 [-0,00322 ; 0,00322] (n10 = 2, n01 = 2) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,05 | MinP4 | 1000 | 0,02200 | = V2 | 0,04300 | 0,04897 | écart non tranché | -0,02100 [-0,02290 ; -0,01425] (n10 = 1, n01 = 22) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,05 | DW | 1000 | 0,04400 | = V2 | 0,04700 | 0,04795 | compatible | -0,00300 [-0,00724 ; 0,00279] (n10 = 3, n01 = 6) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,05 | Runs | 1000 | 0,02000 | = V2 | 0,02000 | 0,02310 | compatible | 0,00000 [0,00000 ; 0,00000] (n10 = 0, n01 = 0) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,05 | PenteIntra | 1000 | 0,05800 | = V2 | 0,05300 | 0,04795 | compatible | 0,00500 [-0,00189 ; 0,01007] (n10 = 9, n01 = 4) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,05 | Origine | 1000 | 0,05300 | = V2 | 0,05400 | 0,04897 | compatible | -0,00100 [-0,00424 ; 0,00311] (n10 = 2, n01 = 3) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,05 | HomogF | 1000 | 0,04900 | = V2 | 0,05800 | 0,04889 | compatible | -0,00900 [-0,00900 ; -0,00390] (n10 = 0, n01 = 9) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,05 | Courbure | 1000 | 0,04600 | = V2 | 0,04600 | 0,04897 | compatible | 0,00000 [-0,00322 ; 0,00322] (n10 = 2, n01 = 2) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,05 | Alpha | 1000 | 0,04500 | = V2 | 0,06500 | 0,04897 | compatible | -0,02000 [-0,02981 ; -0,00816] (n10 = 13, n01 = 33) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,05 | ExpVar | 1000 | 0,04300 | = V2 | 0,04500 | 0,04886 | compatible | -0,00200 [-0,00200 ; 0,00111] (n10 = 0, n01 = 2) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,05 | KruskalAcc | 1000 | 0,06400 | = V2 | 0,06600 | 0,04891 | écart mineur | -0,00200 [-0,00525 ; 0,00274] (n10 = 2, n01 = 4) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,10 | Calendrier | 1000 | 0,07400 | = V2 | 0,07100 | 0,07885 | compatible | 0,00300 [-0,00079 ; 0,00300] (n10 = 3, n01 = 0) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,10 | CorrDev | 1000 | 0,09100 | = V2 | 0,09500 | 0,09249 | compatible | -0,00400 [-0,00825 ; 0,00213] (n10 = 3, n01 = 7) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,10 | BP | 1000 | 0,08800 | = V2 | 0,08900 | 0,09897 | compatible | -0,00100 [-0,00424 ; 0,00311] (n10 = 2, n01 = 3) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,10 | MinP4 | 1000 | 0,05800 | = V2 | 0,08900 | 0,09897 | écart mineur | -0,03100 [-0,03621 ; -0,02188] (n10 = 4, n01 = 35) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,10 | DW | 1000 | 0,09800 | = V2 | 0,10100 | 0,09795 | compatible | -0,00300 [-0,00869 ; 0,00378] (n10 = 5, n01 = 8) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,10 | Runs | 1000 | 0,08000 | = V2 | 0,09100 | 0,07391 | compatible | -0,01100 [-0,01100 ; -0,00576] (n10 = 0, n01 = 11) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,10 | PenteIntra | 1000 | 0,11100 | = V2 | 0,10900 | 0,09795 | compatible | 0,00200 [-0,00490 ; 0,00823] (n10 = 8, n01 = 6) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,10 | Origine | 1000 | 0,09400 | = V2 | 0,10300 | 0,09897 | compatible | -0,00900 [-0,01090 ; -0,00298] (n10 = 1, n01 = 10) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,10 | HomogF | 1000 | 0,10900 | = V2 | 0,11300 | 0,09884 | compatible | -0,00400 [-0,00590 ; 0,00098] (n10 = 1, n01 = 5) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,10 | Courbure | 1000 | 0,10200 | = V2 | 0,10200 | 0,09897 | compatible | 0,00000 [-0,00416 ; 0,00416] (n10 = 3, n01 = 3) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,10 | Alpha | 1000 | 0,11200 | = V2 | 0,10700 | 0,09897 | compatible | 0,00500 [-0,00834 ; 0,01793] (n10 = 31, n01 = 26) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,10 | ExpVar | 1000 | 0,08100 | = V2 | 0,08300 | 0,09884 | compatible | -0,00200 [-0,00525 ; 0,00274] (n10 = 2, n01 = 4) | — |
| D (8 x 6, σ²_2 = 0) | E | 0,10 | KruskalAcc | 1000 | 0,11200 | = V2 | 0,11100 | 0,09888 | compatible | 0,00100 [-0,00448 ; 0,00596] (n10 = 5, n01 = 4) | — |

### Constat (1) : sonde de la plage de dispersion relative 1e-12 à 1e-10 (bloc S)

Part touchée : réplications ajustées où une colonne hors de l'ensemble figé, dégénérée au sens de .mw_colonne_degeneree(), garde des résidus (code courant), divisées par le nombre de réplications ajustées, triangle observé exclu (compté à part) ; |Δp| max entre code courant et prototype P1 rapporté à err_mc du code courant. Règle (plage 1e-12 à 1e-10) : **correction (part touchée non nulle et |Δp| > 2 err_mc dans la plage)**.

| Colonne sondée | ρ | Variante | statut | colonnes figées | j* dégénérée | observé touché | réplications ajustées | touchées | part touchée | appels touchés / appels (réplications) | stats_obs identiques | |Δp| max | |Δp| / err_mc max (clé) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| J−2 du carré (j* = 5) | 5e-13 | V0 | admis | 5,6 | 1 | non | 999 | 0 | 0,0000 | 0 / 999 | oui | 0,00000 | 0,00 (-) |
| J−2 du carré (j* = 5) | 2e-12 | V0 | admis | 6 | 0 | non | 999 | 396 | 0,3964 | 396 / 999 | oui | 0,09400 | 3,19 (PenteIntra) |
| J−2 du carré (j* = 5) | 5e-12 | V0 | admis | 6 | 0 | non | 999 | 177 | 0,1772 | 177 / 999 | oui | 0,03400 | 1,56 (Runs) |
| J−2 du carré (j* = 5) | 1e-11 | V0 | admis | 6 | 0 | non | 999 | 107 | 0,1071 | 107 / 999 | oui | 0,01800 | 0,81 (PenteIntra) |
| J−2 du carré (j* = 5) | 3e-11 | V0 | admis | 6 | 0 | non | 999 | 41 | 0,0410 | 41 / 999 | oui | 0,00200 | 0,13 (Runs) |
| J−2 du carré (j* = 5) | 1e-10 | V0 | admis | 6 | 0 | non | 999 | 25 | 0,0250 | 25 / 999 | oui | 0,00200 | 0,12 (Runs) |
| J−2 du carré (j* = 5) | 3e-10 | V0 | admis | 6 | 0 | non | 999 | 11 | 0,0110 | 11 / 999 | oui | 0,00200 | 0,12 (PenteIntra) |
| J−2 du 8 x 6 (j* = 3) | 5e-13 | V0 | admis | 3 | 1 | non | 999 | 0 | 0,0000 | 0 / 999 | oui | 0,00000 | 0,00 (-) |
| J−2 du 8 x 6 (j* = 3) | 5e-13 | V2 | admis | 3 | 1 | non | 999 | 0 | 0,0000 | 0 / 999 | oui | 0,00000 | 0,00 (-) |
| J−2 du 8 x 6 (j* = 3) | 2e-12 | V0 | admis | - | 0 | non | 999 | 105 | 0,1051 | 105 / 999 | oui | 0,02200 | 1,43 (ExpVar) |
| J−2 du 8 x 6 (j* = 3) | 2e-12 | V2 | admis | - | 0 | non | 999 | 105 | 0,1051 | 105 / 999 | oui | 0,02200 | 1,43 (ExpVar) |
| J−2 du 8 x 6 (j* = 3) | 5e-12 | V0 | admis | - | 0 | non | 999 | 14 | 0,0140 | 14 / 999 | oui | 0,00400 | 0,33 (PenteIntra) |
| J−2 du 8 x 6 (j* = 3) | 5e-12 | V2 | admis | - | 0 | non | 999 | 14 | 0,0140 | 14 / 999 | oui | 0,00400 | 0,33 (PenteIntra) |
| J−2 du 8 x 6 (j* = 3) | 1e-11 | V0 | admis | - | 0 | non | 999 | 3 | 0,0030 | 3 / 999 | oui | 0,00000 | 0,00 (-) |
| J−2 du 8 x 6 (j* = 3) | 1e-11 | V2 | admis | - | 0 | non | 999 | 3 | 0,0030 | 3 / 999 | oui | 0,00000 | 0,00 (-) |
| J−2 du 8 x 6 (j* = 3) | 3e-11 | V0 | admis | - | 0 | non | 999 | 0 | 0,0000 | 0 / 999 | oui | 0,00000 | 0,00 (-) |
| J−2 du 8 x 6 (j* = 3) | 3e-11 | V2 | admis | - | 0 | non | 999 | 0 | 0,0000 | 0 / 999 | oui | 0,00000 | 0,00 (-) |
| J−2 du 8 x 6 (j* = 3) | 1e-10 | V0 | admis | - | 0 | non | 999 | 0 | 0,0000 | 0 / 999 | oui | 0,00000 | 0,00 (-) |
| J−2 du 8 x 6 (j* = 3) | 1e-10 | V2 | admis | - | 0 | non | 999 | 0 | 0,0000 | 0 / 999 | oui | 0,00000 | 0,00 (-) |
| J−2 du 8 x 6 (j* = 3) | 3e-10 | V0 | admis | - | 0 | non | 999 | 0 | 0,0000 | 0 / 999 | oui | 0,00000 | 0,00 (-) |
| J−2 du 8 x 6 (j* = 3) | 3e-10 | V2 | admis | - | 0 | non | 999 | 0 | 0,0000 | 0 / 999 | oui | 0,00000 | 0,00 (-) |
| J−1 du 8 x 6 (j* = 4) | 5e-13 | V0 | admis | 4 | 1 | non | 999 | 0 | 0,0000 | 0 / 999 | oui | 0,00000 | 0,00 (-) |
| J−1 du 8 x 6 (j* = 4) | 5e-13 | V2 | admis | 4 | 1 | non | 999 | 0 | 0,0000 | 0 / 999 | oui | 0,00000 | 0,00 (-) |
| J−1 du 8 x 6 (j* = 4) | 2e-12 | V0 | admis | - | 0 | non | 999 | 0 | 0,0000 | 0 / 999 | oui | 0,00000 | 0,00 (-) |
| J−1 du 8 x 6 (j* = 4) | 2e-12 | V2 | admis | - | 0 | non | 999 | 187 | 0,1872 | 187 / 999 | oui | 0,00400 | 0,32 (PenteIntra) |
| J−1 du 8 x 6 (j* = 4) | 5e-12 | V0 | admis | - | 0 | non | 999 | 0 | 0,0000 | 0 / 999 | oui | 0,00000 | 0,00 (-) |
| J−1 du 8 x 6 (j* = 4) | 5e-12 | V2 | admis | - | 0 | non | 999 | 25 | 0,0250 | 25 / 999 | oui | 0,00800 | 0,55 (PenteIntra) |
| J−1 du 8 x 6 (j* = 4) | 1e-11 | V0 | admis | - | 0 | non | 999 | 0 | 0,0000 | 0 / 999 | oui | 0,00000 | 0,00 (-) |
| J−1 du 8 x 6 (j* = 4) | 1e-11 | V2 | admis | - | 0 | non | 999 | 9 | 0,0090 | 9 / 999 | oui | 0,00200 | 0,14 (PenteIntra) |
| J−1 du 8 x 6 (j* = 4) | 3e-11 | V0 | admis | - | 0 | non | 999 | 0 | 0,0000 | 0 / 999 | oui | 0,00000 | 0,00 (-) |
| J−1 du 8 x 6 (j* = 4) | 3e-11 | V2 | admis | - | 0 | non | 999 | 2 | 0,0020 | 2 / 999 | oui | 0,00000 | 0,00 (-) |
| J−1 du 8 x 6 (j* = 4) | 1e-10 | V0 | admis | - | 0 | non | 999 | 0 | 0,0000 | 0 / 999 | oui | 0,00000 | 0,00 (-) |
| J−1 du 8 x 6 (j* = 4) | 1e-10 | V2 | admis | - | 0 | non | 999 | 0 | 0,0000 | 0 / 999 | oui | 0,00000 | 0,00 (-) |
| J−1 du 8 x 6 (j* = 4) | 3e-10 | V0 | admis | - | 0 | non | 999 | 0 | 0,0000 | 0 / 999 | oui | 0,00000 | 0,00 (-) |
| J−1 du 8 x 6 (j* = 4) | 3e-10 | V2 | admis | - | 0 | non | 999 | 0 | 0,0000 | 0 / 999 | oui | 0,00000 | 0,00 (-) |

### Constat (2) : balayage du σ² de simulation de J−1 (bloc BAL) et lecture stratifiée

| G | Loi | point | n | médiane p PenteIntra | rejets 0,05 | médiane p Alpha | rejets 0,05 | autres clés différentes de k = 1 (triangles) | retirage |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 8x5 | E | k=1e-08 | 20 | 0,6020 | 2 | 0,2795 | 3 | 0 | 0 |
| 8x5 | E | k=1e-06 | 20 | 0,6020 | 2 | 0,2795 | 3 | 0 | 0 |
| 8x5 | E | k=0.0001 | 20 | 0,5970 | 2 | 0,2805 | 3 | 0 | 0 |
| 8x5 | E | k=0.01 | 20 | 0,5770 | 2 | 0,2895 | 3 | 0 | 0 |
| 8x5 | E | k=0.1 | 20 | 0,5190 | 2 | 0,3205 | 3 | 0 | 0 |
| 8x5 | E | k=0.3 | 20 | 0,5020 | 2 | 0,3515 | 2 | 0 | 0 |
| 8x5 | E | k=1 | 20 | 0,5100 | 2 | 0,4195 | 2 | 0 | 0 |
| 8x5 | E | k=3 | 20 | 0,5030 | 2 | 0,5325 | 0 | 0 | 0 |
| 8x5 | E | k=10 | 20 | 0,5080 | 2 | 0,6870 | 0 | 0 | 0 |
| 8x5 | E | regle | 20 | 0,4970 | 2 | 0,4610 | 2 | 0 | 0 |
| 8x5 | N | k=1e-08 | 20 | 0,6550 | 1 | 0,2755 | 1 | 0 | 0 |
| 8x5 | N | k=1e-06 | 20 | 0,6540 | 1 | 0,2755 | 1 | 0 | 0 |
| 8x5 | N | k=0.0001 | 20 | 0,6510 | 1 | 0,2765 | 1 | 0 | 0 |
| 8x5 | N | k=0.01 | 20 | 0,6520 | 1 | 0,2905 | 1 | 0 | 0 |
| 8x5 | N | k=0.1 | 20 | 0,6210 | 1 | 0,3220 | 1 | 0 | 0 |
| 8x5 | N | k=0.3 | 20 | 0,6190 | 1 | 0,3505 | 1 | 0 | 0 |
| 8x5 | N | k=1 | 20 | 0,5870 | 1 | 0,4195 | 0 | 0 | 0 |
| 8x5 | N | k=3 | 20 | 0,5740 | 1 | 0,5155 | 0 | 0 | 0 |
| 8x5 | N | k=10 | 20 | 0,5830 | 1 | 0,6660 | 0 | 0 | 0 |
| 8x5 | N | regle | 20 | 0,5880 | 1 | 0,4110 | 1 | 0 | 0 |
| 8x6 | E | k=1e-08 | 20 | 0,7140 | 3 | 0,4105 | 2 | 0 | 0 |
| 8x6 | E | k=1e-06 | 20 | 0,7150 | 3 | 0,4105 | 2 | 0 | 0 |
| 8x6 | E | k=0.0001 | 20 | 0,7150 | 3 | 0,4110 | 2 | 0 | 0 |
| 8x6 | E | k=0.01 | 20 | 0,7010 | 3 | 0,4150 | 1 | 0 | 0 |
| 8x6 | E | k=0.1 | 20 | 0,6560 | 2 | 0,4320 | 1 | 0 | 0 |
| 8x6 | E | k=0.3 | 20 | 0,6130 | 2 | 0,4430 | 1 | 0 | 0 |
| 8x6 | E | k=1 | 20 | 0,5860 | 2 | 0,4620 | 1 | 0 | 0 |
| 8x6 | E | k=3 | 20 | 0,5450 | 2 | 0,4965 | 1 | 0 | 0 |
| 8x6 | E | k=10 | 20 | 0,5390 | 2 | 0,5550 | 1 | 0 | 0 |
| 8x6 | E | regle | 20 | 0,5380 | 2 | 0,4890 | 1 | 0 | 0 |
| 8x6 | N | k=1e-08 | 20 | 0,7080 | 0 | 0,3975 | 1 | 0 | 0 |
| 8x6 | N | k=1e-06 | 20 | 0,7090 | 0 | 0,3975 | 1 | 0 | 0 |
| 8x6 | N | k=0.0001 | 20 | 0,7050 | 0 | 0,3980 | 1 | 0 | 0 |
| 8x6 | N | k=0.01 | 20 | 0,6700 | 0 | 0,3995 | 1 | 0 | 0 |
| 8x6 | N | k=0.1 | 20 | 0,6040 | 0 | 0,4065 | 1 | 0 | 0 |
| 8x6 | N | k=0.3 | 20 | 0,5840 | 0 | 0,4130 | 1 | 0 | 0 |
| 8x6 | N | k=1 | 20 | 0,5490 | 0 | 0,4205 | 0 | 0 | 0 |
| 8x6 | N | k=3 | 20 | 0,5490 | 0 | 0,4370 | 0 | 0 | 0 |
| 8x6 | N | k=10 | 20 | 0,5270 | 0 | 0,4695 | 0 | 0 | 0 |
| 8x6 | N | regle | 20 | 0,5470 | 0 | 0,4535 | 0 | 0 | 0 |
| 8x7 | E | k=1e-08 | 20 | 0,9750 | 5 | 0,4265 | 1 | 0 | 0 |
| 8x7 | E | k=1e-06 | 20 | 0,9750 | 4 | 0,4265 | 1 | 0 | 0 |
| 8x7 | E | k=0.0001 | 20 | 0,9260 | 3 | 0,4265 | 1 | 0 | 0 |
| 8x7 | E | k=0.01 | 20 | 0,6870 | 3 | 0,4265 | 1 | 0 | 0 |
| 8x7 | E | k=0.1 | 20 | 0,6070 | 3 | 0,4265 | 1 | 0 | 0 |
| 8x7 | E | k=0.3 | 20 | 0,5700 | 3 | 0,4265 | 1 | 0 | 0 |
| 8x7 | E | k=1 | 20 | 0,5690 | 3 | 0,4265 | 1 | 0 | 0 |
| 8x7 | E | k=3 | 20 | 0,5630 | 3 | 0,4265 | 1 | 0 | 0 |
| 8x7 | E | k=10 | 20 | 0,5570 | 2 | 0,4265 | 1 | 0 | 0 |
| 8x7 | E | regle | 20 | 0,6560 | 2 | 0,4265 | 1 | 0 | 0 |
| 8x7 | N | k=1e-08 | 20 | 0,9670 | 5 | 0,4025 | 0 | 0 | 0 |
| 8x7 | N | k=1e-06 | 20 | 0,9620 | 5 | 0,4025 | 0 | 0 | 0 |
| 8x7 | N | k=0.0001 | 20 | 0,9510 | 3 | 0,4025 | 0 | 0 | 0 |
| 8x7 | N | k=0.01 | 20 | 0,7930 | 0 | 0,4025 | 0 | 0 | 0 |
| 8x7 | N | k=0.1 | 20 | 0,6680 | 0 | 0,4025 | 0 | 0 | 0 |
| 8x7 | N | k=0.3 | 20 | 0,6250 | 0 | 0,4025 | 0 | 0 | 0 |
| 8x7 | N | k=1 | 20 | 0,6020 | 0 | 0,4025 | 0 | 0 | 0 |
| 8x7 | N | k=3 | 20 | 0,5950 | 0 | 0,4025 | 0 | 0 | 0 |
| 8x7 | N | k=10 | 20 | 0,5640 | 0 | 0,4025 | 0 | 0 | 0 |
| 8x7 | N | regle | 20 | 0,6370 | 0 | 0,4025 | 0 | 0 | 0 |

Excès apparié contre le témoin à 0,05 par quartile de log r (r = σ̂²_règle / σ̂²_dir), N et E réunis ; descriptif, confondu avec la forme du triangle.

| G | Clé | quartile | r dans | n | V0 − T Δ̂ [IC 90 %] | V2 − T Δ̂ [IC 90 %] |
| --- | --- | --- | --- | --- | --- | --- |
| 8x7 | PenteIntra | 1 | ]— ; 0,0287] | 1000 | 0,06200 [0,05479 ; 0,06390] (n10 = 63, n01 = 1) | 0,02400 [0,01634 ; 0,02728] (n10 = 26, n01 = 2) |
| 8x7 | PenteIntra | 2 | ]0,0287 ; 0,2240] | 1000 | 0,01400 [0,00755 ; 0,01590] (n10 = 15, n01 = 1) | -0,00200 [-0,00823 ; 0,00490] (n10 = 6, n01 = 8) |
| 8x7 | PenteIntra | 3 | ]0,2240 ; 1,4082] | 1000 | 0,00500 [-0,00142 ; 0,00927] (n10 = 8, n01 = 3) | 0,00200 [-0,00337 ; 0,00622] (n10 = 5, n01 = 3) |
| 8x7 | PenteIntra | 4 | ]1,4082 ; —] | 1000 | 0,01300 [0,00591 ; 0,01628] (n10 = 15, n01 = 2) | 0,02700 [0,02010 ; 0,02890] (n10 = 28, n01 = 1) |
| 8x5 | Alpha | 1 | ]— ; 0,5756] | 1000 | 0,03300 [0,02098 ; 0,04220] (n10 = 44, n01 = 11) | 0,00900 [-0,00171 ; 0,01851] (n10 = 22, n01 = 13) |
| 8x5 | Alpha | 2 | ]0,5756 ; 1,3612] | 1000 | -0,00800 [-0,01875 ; 0,00363] (n10 = 17, n01 = 25) | -0,01300 [-0,02228 ; -0,00208] (n10 = 12, n01 = 25) |
| 8x5 | Alpha | 3 | ]1,3612 ; 2,8146] | 1000 | -0,02500 [-0,03218 ; -0,01475] (n10 = 7, n01 = 32) | -0,01800 [-0,02658 ; -0,00719] (n10 = 10, n01 = 28) |
| 8x5 | Alpha | 4 | ]2,8146 ; —] | 1000 | -0,03700 [-0,04222 ; -0,02772] (n10 = 4, n01 = 41) | -0,01700 [-0,02637 ; -0,00569] (n10 = 12, n01 = 29) |
| 8x6 | Alpha | 1 | ]— ; 0,4103] | 1000 | 0,01400 [0,00243 ; 0,02402] (n10 = 28, n01 = 14) | 0,00100 [-0,00948 ; 0,01135] (n10 = 18, n01 = 17) |
| 8x6 | Alpha | 2 | ]0,4103 ; 1,4419] | 1000 | -0,01300 [-0,02364 ; -0,00102] (n10 = 16, n01 = 29) | -0,01500 [-0,02505 ; -0,00333] (n10 = 14, n01 = 29) |
| 8x6 | Alpha | 3 | ]1,4419 ; 4,5262] | 1000 | -0,02300 [-0,03248 ; -0,01122] (n10 = 12, n01 = 35) | -0,01500 [-0,02571 ; -0,00281] (n10 = 16, n01 = 31) |
| 8x6 | Alpha | 4 | ]4,5262 ; —] | 1000 | -0,01300 [-0,02104 ; -0,00298] (n10 = 9, n01 = 22) | 0,00100 [-0,00976 ; 0,01164] (n10 = 19, n01 = 18) |

### Constats (3) et (4) : Alpha sous E et MinP4 (bloc D contre son oracle ; MinP4 contre #297)

Règle (3) : constat clos. Règle (4) : (4) s'explique par la référence nominale et B = 199, et se clôt.

| Clé | Loi | α | n | τ [IC 95 %] | ρ_D | classe | contre témoin D Δ̂ [IC 90 %] |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Alpha | N | 0,05 | 1000 | 0,03800 [0,02703 ; 0,05179] | 0,04897 | compatible | -0,00700 [-0,01799 ; 0,00475] (n10 = 18, n01 = 25) |
| Alpha | N | 0,10 | 1000 | 0,09100 [0,07390 ; 0,11055] | 0,09897 | compatible | 0,00300 [-0,01231 ; 0,01813] (n10 = 40, n01 = 37) |
| Alpha | E | 0,05 | 1000 | 0,04500 [0,03301 ; 0,05975] | 0,04897 | compatible | -0,02000 [-0,02981 ; -0,00816] (n10 = 13, n01 = 33) |
| Alpha | E | 0,10 | 1000 | 0,11200 [0,09312 ; 0,13320] | 0,09897 | compatible | 0,00500 [-0,00834 ; 0,01793] (n10 = 31, n01 = 26) |
| MinP4 | N | 0,05 | 1000 | 0,01400 [0,00767 ; 0,02338] | 0,04897 | distorsion matérielle (**conservateur**) | -0,03100 [-0,03100 ; -0,02529] (n10 = 0, n01 = 31) |
| MinP4 | N | 0,10 | 1000 | 0,05500 [0,04170 ; 0,07099] | 0,09897 | écart mineur | -0,04100 [-0,04100 ; -0,03522] (n10 = 0, n01 = 41) |
| MinP4 | E | 0,05 | 1000 | 0,02200 [0,01384 ; 0,03312] | 0,04897 | écart non tranché | -0,02100 [-0,02290 ; -0,01425] (n10 = 1, n01 = 22) |
| MinP4 | E | 0,10 | 1000 | 0,05800 [0,04433 ; 0,07434] | 0,09897 | écart mineur | -0,03100 [-0,03621 ; -0,02188] (n10 = 4, n01 = 35) |

MinP4 contre #297 (8 x 8, lignes rep admises, pR:MinP4) : Fisher exact bilatéral, Holm sur les cellules ; trapèzes : V2 (MinP4 invariant).

| G | Loi | α | k / n | k / n (#297) | p Fisher | p Holm | significatif |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 8x5 | N | 0,05 | 42 / 2000 | 58 / 2000 | 0,128 | 1 | non |
| 8x5 | N | 0,10 | 100 / 2000 | 142 / 2000 | 0,00644 | 0,103 | non |
| 8x5 | E | 0,05 | 65 / 2000 | 79 / 2000 | 0,27 | 1 | non |
| 8x5 | E | 0,10 | 137 / 2000 | 157 / 2000 | 0,25 | 1 | non |
| 8x6 | N | 0,05 | 44 / 2000 | 58 / 2000 | 0,192 | 1 | non |
| 8x6 | N | 0,10 | 124 / 2000 | 142 / 2000 | 0,281 | 1 | non |
| 8x6 | E | 0,05 | 67 / 2000 | 79 / 2000 | 0,354 | 1 | non |
| 8x6 | E | 0,10 | 155 / 2000 | 157 / 2000 | 0,953 | 1 | non |
| 8x7 | N | 0,05 | 46 / 2000 | 58 / 2000 | 0,274 | 1 | non |
| 8x7 | N | 0,10 | 136 / 2000 | 142 / 2000 | 0,756 | 1 | non |
| 8x7 | E | 0,05 | 67 / 2000 | 79 / 2000 | 0,354 | 1 | non |
| 8x7 | E | 0,10 | 155 / 2000 | 157 / 2000 | 0,953 | 1 | non |
| 8x8 | N | 0,05 | 46 / 2000 | 58 / 2000 | 0,274 | 1 | non |
| 8x8 | N | 0,10 | 129 / 2000 | 142 / 2000 | 0,45 | 1 | non |
| 8x8 | E | 0,05 | 66 / 2000 | 79 / 2000 | 0,31 | 1 | non |
| 8x8 | E | 0,10 | 155 / 2000 | 157 / 2000 | 0,953 | 1 | non |

### p de famille et p globale (descriptif, K-T7 de #567)

| G | Loi | Variante | Famille | n | τ 0,10 | τ 0,05 |
| --- | --- | --- | --- | --- | --- | --- |
| 8x5 | N | V2 | M1 | 2000 | 0,0895 | 0,0405 |
| 8x5 | N | V2 | M2 | 2000 | 0,0980 | 0,0520 |
| 8x5 | N | V2 | M3 | 2000 | 0,0880 | 0,0335 |
| 8x5 | N | V2 | M4 | 2000 | 0,0000 | 0,0000 |
| 8x5 | N | V2 | LC | 2000 | 0,0755 | 0,0415 |
| 8x5 | N | V0 | M1 | 2000 | 0,0905 | 0,0415 |
| 8x5 | N | V0 | M2 | 2000 | 0,0980 | 0,0520 |
| 8x5 | N | V0 | M3 | 2000 | 0,0880 | 0,0335 |
| 8x5 | N | V0 | M4 | 2000 | 0,0000 | 0,0000 |
| 8x5 | N | V0 | LC | 2000 | 0,0765 | 0,0420 |
| 8x5 | E | V2 | M1 | 2000 | 0,0950 | 0,0490 |
| 8x5 | E | V2 | M2 | 2000 | 0,0870 | 0,0435 |
| 8x5 | E | V2 | M3 | 2000 | 0,0980 | 0,0460 |
| 8x5 | E | V2 | M4 | 2000 | 0,0000 | 0,0000 |
| 8x5 | E | V2 | LC | 2000 | 0,0820 | 0,0385 |
| 8x5 | E | V0 | M1 | 2000 | 0,0925 | 0,0480 |
| 8x5 | E | V0 | M2 | 2000 | 0,0870 | 0,0435 |
| 8x5 | E | V0 | M3 | 2000 | 0,0980 | 0,0460 |
| 8x5 | E | V0 | M4 | 2000 | 0,0000 | 0,0000 |
| 8x5 | E | V0 | LC | 2000 | 0,0810 | 0,0375 |
| 8x6 | N | V2 | M1 | 2000 | 0,0885 | 0,0420 |
| 8x6 | N | V2 | M2 | 2000 | 0,1050 | 0,0570 |
| 8x6 | N | V2 | M3 | 2000 | 0,0880 | 0,0345 |
| 8x6 | N | V2 | M4 | 2000 | 0,0000 | 0,0000 |
| 8x6 | N | V2 | LC | 2000 | 0,0700 | 0,0330 |
| 8x6 | N | V0 | M1 | 2000 | 0,0875 | 0,0425 |
| 8x6 | N | V0 | M2 | 2000 | 0,1050 | 0,0570 |
| 8x6 | N | V0 | M3 | 2000 | 0,0880 | 0,0345 |
| 8x6 | N | V0 | M4 | 2000 | 0,0000 | 0,0000 |
| 8x6 | N | V0 | LC | 2000 | 0,0680 | 0,0320 |
| 8x6 | E | V2 | M1 | 2000 | 0,1005 | 0,0490 |
| 8x6 | E | V2 | M2 | 2000 | 0,0795 | 0,0380 |
| 8x6 | E | V2 | M3 | 2000 | 0,1075 | 0,0500 |
| 8x6 | E | V2 | M4 | 2000 | 0,0000 | 0,0000 |
| 8x6 | E | V2 | LC | 2000 | 0,0850 | 0,0410 |
| 8x6 | E | V0 | M1 | 2000 | 0,1010 | 0,0485 |
| 8x6 | E | V0 | M2 | 2000 | 0,0795 | 0,0380 |
| 8x6 | E | V0 | M3 | 2000 | 0,1075 | 0,0500 |
| 8x6 | E | V0 | M4 | 2000 | 0,0000 | 0,0000 |
| 8x6 | E | V0 | LC | 2000 | 0,0860 | 0,0415 |
| 8x7 | N | V2 | M1 | 2000 | 0,0880 | 0,0450 |
| 8x7 | N | V2 | M2 | 2000 | 0,1040 | 0,0545 |
| 8x7 | N | V2 | M3 | 2000 | 0,0850 | 0,0380 |
| 8x7 | N | V2 | M4 | 2000 | 0,0000 | 0,0000 |
| 8x7 | N | V2 | LC | 2000 | 0,0785 | 0,0390 |
| 8x7 | N | V0 | M1 | 2000 | 0,0925 | 0,0485 |
| 8x7 | N | V0 | M2 | 2000 | 0,1040 | 0,0545 |
| 8x7 | N | V0 | M3 | 2000 | 0,0850 | 0,0380 |
| 8x7 | N | V0 | M4 | 2000 | 0,0000 | 0,0000 |
| 8x7 | N | V0 | LC | 2000 | 0,0810 | 0,0410 |
| 8x7 | E | V2 | M1 | 2000 | 0,1040 | 0,0470 |
| 8x7 | E | V2 | M2 | 2000 | 0,0815 | 0,0395 |
| 8x7 | E | V2 | M3 | 2000 | 0,0995 | 0,0530 |
| 8x7 | E | V2 | M4 | 2000 | 0,0000 | 0,0000 |
| 8x7 | E | V2 | LC | 2000 | 0,0860 | 0,0370 |
| 8x7 | E | V0 | M1 | 2000 | 0,1150 | 0,0520 |
| 8x7 | E | V0 | M2 | 2000 | 0,0815 | 0,0395 |
| 8x7 | E | V0 | M3 | 2000 | 0,0995 | 0,0530 |
| 8x7 | E | V0 | M4 | 2000 | 0,0000 | 0,0000 |
| 8x7 | E | V0 | LC | 2000 | 0,0900 | 0,0360 |

Bilan : intégrité OK ; K0 tenu ; règle R-V2 ; constats (3) et (4) : évalués ou sans objet

### Exécution (varie d'une exécution à l'autre)

- Lancement (JOURNAL) : 2026-11-23T17:42:27Z ; fin : 2026-11-25T02:06:13Z
- Processus : 4 ; lignes calculées par cette exécution : 400, 2 tranche(s), 1585 s d'horloge ; tranches reprises : 1785
- Durée cumulée des lignes : 572821 s ; contrôles avant tirage : 113,2 s ; (rep) : 145,1 s ; durée totale : 1948 s

