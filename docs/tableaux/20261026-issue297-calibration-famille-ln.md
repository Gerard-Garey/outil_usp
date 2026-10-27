## Mesure #297 (Fk) : niveau réel à T = 8 des p de famille et de la p globale, méthode lognormale (J1, J2) -- combinaison de 16 sortie(s)

### T0 — provenance (contexte commun vérifié identique dans toutes les sorties)

| Grandeur | Valeur |
| --- | --- |
| Configuration de run_engine() | méthode premium, segment 1 de l'annexe II, données brutes, α = 0.1, theta_equiv = 0.1, σ standard = 0.1, barème long, B = 999 |
| Graines | jeux simulés : un flux sous 20260927 (chemin de #72) ; bootstrap et rapport de vraisemblance de la réplication b : 20260831 + b ; J1 observé (a) : 20260831 |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Commit | 7ff47251a769a4d864c54e363b1758c45362eaf4 |
| Plateforme de calcul (R, système, machine, BLAS, LAPACK) | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : libblas.so.3.12.0 ; LAPACK : liblapack.so.3.12.0 (version 3.12.0) |
| Empreintes md5 du code exécuté | R/engine.R 10bd74c2923cc1ac034df6a9a4e9c0c8 ; tests/outils_tests.R chargé (dépôt) 63a27805557d75069137e726102e685c ; script exécuté (dépôt) d82f6cd53d9ee5ff3e96940905a563e7 ; tests/taux_franchissement_reperes.R 5d167f442a86fddd96338ff7c5cab3bc |
| Contrôle (a) : J1 observé contre tests/reference/premium.rds | conforme ; 54866 feuille(s), 0 non strictement identique(s), écart maximal 0.000e+00 |
| Tailles des lois discrètes, P(p < 0,10) et P(p < 0,05) (T = 8, sans ex aequo) | suites (Swed-Eisenhart, 4 et 4) : atteignable 0,05714 et 0,00000, lissée 0,05713 et 0,00968 ; Mann-Kendall (loi mahonienne) : atteignable 0,06101 et 0,03115, lissée 0,07107 et 0,03355 ; Smirnov (4 et 4) : atteignable 0,02857 et 0,02857, lissée 0,02857 et 0,02856 ; Spearman (loi de permutation) : atteignable 0,09618 et 0,04583, lissée 0,09038 et 0,04295 ; Cox-Stuart (Binomiale(4, 1/2)) : atteignable 0,00000 et 0,00000, lissée 0,00059 et 0,00000 |
| Essai (--essai, non versionnable) | non |
| Empreinte sans commentaires de R/engine.R (#231) | 48adec179f5b1bab043ecfeecebba64a |
| Niveau de l'échelle et R | L0 (plan de la spécification de Fk, par. 5.2) : J1 R = 2000, J2 R = 2000 |
| J1 : paramètres | jeu=J1;R=2000;graine_jeux=20260927;graine_boot=20260831;B=999;methode=premium;segment=1;annexe=II;nature=brutes;alpha=0.1;theta_equiv=0.1 |
| J1 : Jeu | J1 : tests/donnees/donnees_ln.csv (jeu des cas de référence) |
| J1 : Modèle ajusté (usp_ajuster()) | δ̂ = 1 ; γ̂ = -1.93433 ; β̂ = 0.728685 ; σ̂ = 0.10531 ; π̂ constant : TRUE |
| J1 : σ_USP observé (usp_parametre() sur le modèle ajusté) | 0.111452 |
| J1 : Graines en collision (déclarées, non bloquantes) | réplication 96 : graine du bootstrap 20260927 = graine des jeux simulés (effet borné : réplication 96, \|Δp_mc\| ≤ 1/(B+1) = 0,001 en queue simple et 2/(B+1) = 0,002 en bilatéral, sur ses seules p_mc (au plus 1/R sur un taux), ses 998 autres réplications internes restant indépendantes de y_96) ; réplication 70 : graine du bootstrap 20260901 = SEED_LOI_NULLE_SW (loi nulle de Shapiro-Wilk) (réplication 70 : sans effet sur la branche lognormale depuis #302 (aucune ligne n'emploie la loi nulle de Shapiro-Wilk) ; collision déclarée pour la lecture des tableaux antérieurs) |
| J1 : réplications | 2000 (8 tranche(s) : ln-J1-R2000-0001-0250.txt 1-250, ln-J1-R2000-0251-0500.txt 251-500, ln-J1-R2000-0501-0750.txt 501-750, ln-J1-R2000-0751-1000.txt 751-1000, ln-J1-R2000-1001-1250.txt 1001-1250, ln-J1-R2000-1251-1500.txt 1251-1500, ln-J1-R2000-1501-1750.txt 1501-1750, ln-J1-R2000-1751-2000.txt 1751-2000) |
| J1 : durée cumulée (s) | contrôles 105 ; réplications 22933 (11.5 s par réplication) |
| J1 : (e3) et (e4) | OK : δ̂* au bord 0 : 930 (tableau de #72 : 930 sur 2000) ; au bord 1 : 995 (tableau de #72 : 995 sur 2000) ; usp_ajuster() en erreur : 0 ; docs/tableaux/20260930-issue122-J1.md ; OK : largeur relative de l'IC bootstrap 90 % au-dessus de 0,50 : 981 sur 2000 (tableau de #72 : 981 sur 2000) ; au-dessus de 0,80 : 0 (tableau de #72 : 0 sur 2000) ; docs/tableaux/20260930-issue122-J1.md |
| J2 : paramètres | jeu=J2;R=2000;graine_jeux=20260927;graine_boot=20260831;B=999;methode=premium;segment=1;annexe=II;nature=brutes;alpha=0.1;theta_equiv=0.1 |
| J2 : Jeu | J2 : xi, yi de tests/unitaires/test_controles_numeriques.R (δ estimé intérieur) |
| J2 : Modèle ajusté (usp_ajuster()) | δ̂ = 0.663991 ; γ̂ = -2.31999 ; β̂ = 0.701657 ; σ̂ = 0.0689553 ; π̂ constant : FALSE |
| J2 : σ_USP observé (usp_parametre() sur le modèle ajusté) | 0.0871309 |
| J2 : Graines en collision (déclarées, non bloquantes) | réplication 96 : graine du bootstrap 20260927 = graine des jeux simulés (effet borné : réplication 96, \|Δp_mc\| ≤ 1/(B+1) = 0,001 en queue simple et 2/(B+1) = 0,002 en bilatéral, sur ses seules p_mc (au plus 1/R sur un taux), ses 998 autres réplications internes restant indépendantes de y_96) ; réplication 70 : graine du bootstrap 20260901 = SEED_LOI_NULLE_SW (loi nulle de Shapiro-Wilk) (réplication 70 : sans effet sur la branche lognormale depuis #302 (aucune ligne n'emploie la loi nulle de Shapiro-Wilk) ; collision déclarée pour la lecture des tableaux antérieurs) |
| J2 : réplications | 2000 (8 tranche(s) : ln-J2-R2000-0001-0250.txt 1-250, ln-J2-R2000-0251-0500.txt 251-500, ln-J2-R2000-0501-0750.txt 501-750, ln-J2-R2000-0751-1000.txt 751-1000, ln-J2-R2000-1001-1250.txt 1001-1250, ln-J2-R2000-1251-1500.txt 1251-1500, ln-J2-R2000-1501-1750.txt 1501-1750, ln-J2-R2000-1751-2000.txt 1751-2000) |
| J2 : durée cumulée (s) | contrôles 105 ; réplications 23506 (11.8 s par réplication) |
| J2 : (e3) et (e4) | OK : δ̂* au bord 0 : 814 (tableau de #72 : 814 sur 2000) ; au bord 1 : 722 (tableau de #72 : 722 sur 2000) ; usp_ajuster() en erreur : 0 ; docs/tableaux/20260930-issue122-J2.md ; OK : largeur relative de l'IC bootstrap 90 % au-dessus de 0,50 : 85 sur 2000 (tableau de #72 : 85 sur 2000) ; au-dessus de 0,80 : 0 (tableau de #72 : 0 sur 2000) ; docs/tableaux/20260930-issue122-J2.md |
| Sorties combinées (nom, md5) | ln-J1-R2000-0001-0250.txt 47ec6ce7fcfbce5e9c4df7b6af095059 ; ln-J1-R2000-0251-0500.txt 1dc9780d68706de9bb4d5f3ef5b66068 ; ln-J1-R2000-0501-0750.txt 1a0a119e24da172d8cd32929102a0e5f ; ln-J1-R2000-0751-1000.txt 83c48bcd283a7c4fb36de27ff0ae1bac ; ln-J1-R2000-1001-1250.txt e9273e2c4c44f4a957916b69f0d80537 ; ln-J1-R2000-1251-1500.txt 5f85b35b7b2df47f4c5540d0384129c6 ; ln-J1-R2000-1501-1750.txt ebecb5eaafe851a58a853ce5bb88f446 ; ln-J1-R2000-1751-2000.txt 6d47db656022a732682e623b650f7da6 ; ln-J2-R2000-0001-0250.txt 095441257872817714b2f69d45bb2c8b ; ln-J2-R2000-0251-0500.txt 5629c6dd5bc232c88a16f3d4b1ca9109 ; ln-J2-R2000-0501-0750.txt 76c39bf945caff1be81c1b07aebd5340 ; ln-J2-R2000-0751-1000.txt 8a4d7510c475cb51dcf8076c1f71d490 ; ln-J2-R2000-1001-1250.txt f2464527f9c741396faf2c64a9295f0a ; ln-J2-R2000-1251-1500.txt 59ceda4c4b9b0cb69af42a7cfcfa5b84 ; ln-J2-R2000-1501-1750.txt 160382a611a62b6d65ab5521d2d8f5f2 ; ln-J2-R2000-1751-2000.txt 299e59e91b931d67099d5d21a63698a6 |
| JOURNAL | JOURNAL.md (md5 af942ef94ae0e08b1fc7b1b3ec774427) : md5 des 16 sorties conformes ; niveau : L0 |
| Commit de la combinaison | 7ff47251a769a4d864c54e363b1758c45362eaf4 |
| Empreintes md5 du combinateur | R/engine.R 10bd74c2923cc1ac034df6a9a4e9c0c8 ; tests/outils_tests.R chargé (dépôt) 63a27805557d75069137e726102e685c ; script exécuté (dépôt) d82f6cd53d9ee5ff3e96940905a563e7 ; tests/taux_franchissement_reperes.R 5d167f442a86fddd96338ff7c5cab3bc |
| Valeurs brutes | 20261026-issue297-calibration-famille-ln-brut.tsv : md5 17ee373ee1989d70e8afe5c1f8160928, 4000 lignes (copie hors du dépôt : --brut) |
| Journal de la combinaison | 20261026-issue297-journal-combinaison-ln.md |
| Versionnable (--ecrire) | oui |
| Contrôles d'intégrité | OK dans les 16 sorties (dont (k), (K-F3) et (t297)) ; invariants du corps vérifiés ; couvertures exactes par jeu |

### Aide à la lecture

Statut : **constat de simulation sous les modèles ajustés aux jeux J1 et J2** (usp_simuler(FIT0)), pas un résultat général. Lecture conjointe (#297) : p de famille et p globale minP en une étape (engine_p_famille()), diagnostics sans verdict, p plug-in non exactes (spécification de Fk, par. 1.1) ; référence ρ_F = 0,099 et 0,049 (par. 5.3), majorant en présence d'atomes de la plus petite p. IC : Clopper-Pearson à 95 %, incertitude Monte-Carlo sur le taux (fonction de R).

**Critère de la spécification de Fk (par. 5.3), reporté sans modification, évalué mécaniquement sans conclure :**

> ### 5.3 Critère, fixé avant toute exécution (reporté sans modification dans les scripts et au T0)
> 
> **Grandeurs.**
> - Pour chaque jeu simulé d, chaque famille f dont la ligne est présente (k_f ≥ 2, ou ≥ 1 sous Q-D1-Fk-2 (b)) et chaque α ∈ {0,10 ; 0,05} : D = 1 si p_f,d < α.
> - Une p de famille absente (T-3b) compte comme un non-rejet, comptée à part (#242).
> - τ_f(α) = (Σ D) / n_f, où n_f est le nombre de jeux où la ligne est présente. IC de Clopper-Pearson à 95 %, calculé sur les valeurs non arrondies.
> - La composition de la famille varie avec le jeu. Elle est rapportée : distribution de k_f et part des jeux où la ligne existe.
> 
> **Référence ρ_F(α)** : la taille du test de Monte-Carlo idéal à B_eff = 999, pour une statistique sans atome, P((1 + K)/1000 < α) = (⌈1 000 α⌉ − 1)/1 000. Elle vaut **0,099** et **0,049** [V, arithmétique]. Avec des atomes de m, nombreux près du plancher, le test idéal est plus conservateur : ρ_F en est un **majorant** [V, raisonnement du § 2.1]. La masse de p_f au plancher 1/(B_eff + 1) est rapportée.
> 
> **Classes**, celles de #166 et #206 avec ρ_F :
> - *compatible* : ρ_F ∈ IC ;
> - *écart mineur* : estimation dans [ρ_F/2 ; 3ρ_F/2] ;
> - *non tranché* : estimation hors de la bande, IC qui la recoupe ;
> - *distorsion matérielle* : IC disjoint de la bande, côté libéral ou conservateur.
> 
> **Conditions** (évaluées mécaniquement, sans conclusion dans le tableau) :
> - **K-F1** (principal) : classe de τ_f(α) pour chaque (jeu ou loi, famille ou globale, α).
> - **K-F2** (descriptif, T4) : part des jeux à au moins une ALERTE ou un ECHEC et à au moins un ECHEC, sur les tests ; part des jeux à p globale < α ; par famille, part à au moins un test membre à p < α contre part à p_f < α.
> - **K-F3** (intégrité) : les contrôles existants des deux scripts, plus un contrôle nouveau. Sur le premier jeu de chaque tranche, p_f et m_obs recalculés **dans le script**, en R de base, depuis `bootstrap$stats_boot`, `stats_obs`, le catalogue et les lignes, par une écriture indépendante d'`engine_p_famille()`, doivent être `identical()` aux champs de la ligne. Un échec met INTEGRITE à ECHEC.
> - **K-F4** (frontière, descriptif) : par clé et pour chaque p de famille, la fréquence sous H0 de |p − s| < 2 err_mc, pour s ∈ {α ; α/2} (T4 de #206, étendu).
> - **Merz-Wüthrich, remesure par clé** : K1 à K5 de la spécification de #206, § 5, inchangés, avec ses annotations du 10 et du 11/10/2026. La clé Runs, dont la ligne est un diagnostic depuis #312, est lue à titre descriptif.
> 
> **Profils de lecture pour D2-Fk** (actuary propose, le mainteneur tranche) :
> 
> | Profil | Condition | Lecture proposée |
> |---|---|---|
> | Φ0 | K-F3, ou K3 ou K4 de #206, en défaut sans explication | Lecture suspendue ; mesure à reprendre |
> | Φ1 | Toutes les p de famille et la p globale compatibles ou en écart mineur, aux deux α, sous chaque jeu et chaque loi | Diagnostic conservé ; niveau documenté comme constat ; **aucune décision** |
> | Φ2 | Pas de distorsion matérielle, mais des écarts non tranchés | Idem, avec les IC |
> | Φ3 | Distorsion matérielle **conservatrice** seulement | Conservé ; la documentation dit qu'une p de famille élevée est une preuve faible ; aucune décision |
> | Φ4 | Distorsion matérielle **libérale** pour au moins une (famille, jeu ou loi, α) | **Décision du mainteneur** : garder avec une phrase fixe sourcée par la mesure, retirer la ou les lignes, ou reformuler |
> | Φ5 | Distorsions de côtés opposés entre jeux ou lois pour une même famille | **Décision du mainteneur** ; documenter, aucune correction calibrée sur un seul plan |
> 
> Pour les clés Merz-Wüthrich, un Π3 ou un Π4 (profils de #206) donne lieu à une **issue proposée**, sans changement de verdict en Fk. L'issue est rapportée à D2-Fk à titre d'information.

### Évaluation mécanique de K-F1 à K-F4 et des profils Φ (sans conclusion)

États calculés par le script ; la lecture revient à actuary, la décision éventuelle au mainteneur (D2-Fk, Q-D1-Fk-9 : décision requise sous Φ0, Φ4 ou Φ5 seulement). Volet lognormal : K3 et K4 de #206 sans objet.

| Condition | État mécanique | Détail |
| --- | --- | --- |
| K-F1 (principal) | évaluée | J1 : compatible 10, écart mineur 0, écart non tranché 0, distorsion matérielle 0 ; J2 : compatible 9, écart mineur 1, écart non tranché 0, distorsion matérielle 0 |
| K-F2 (descriptif, T4) | descriptif | voir T-F3 |
| K-F3 (intégrité) | remplie | INTEGRITE OK et contrôle (K-F3) OK dans chaque sortie (refus de --combiner sinon) |
| K-F4 (frontière, descriptif) | descriptif | voir T-F4 |

| Profil | Condition mécanique | Présent | Cellules |
| --- | --- | --- | --- |
| Φ0 | K-F3, ou K3 ou K4 de #206, en défaut (« sans explication » : jugement d'actuary) | non | K-F3 rempli (INTEGRITE OK et ligne (K-F3) OK dans chaque sortie) ; K3 et K4 de #206 sans objet pour le volet lognormal |
| Φ1 | toutes les p de famille et la p globale compatibles ou en écart mineur, aux deux α, sous chaque jeu ou loi | **oui** | aucune |
| Φ2 | pas de distorsion matérielle, des écarts non tranchés | non | aucune |
| Φ3 | distorsion matérielle conservatrice seulement | non | aucune |
| Φ4 | distorsion matérielle libérale pour au moins une (famille, jeu ou loi, α) | non | aucune |
| Φ5 | même famille : distorsions de côtés opposés entre jeux ou lois | non | — |

Cellules non évaluables (aucune ligne de la famille sous le jeu ou la loi, hors profils) : J1 C. 0,10 ; J1 C. 0,05 ; J1 G. 0,10 ; J1 G. 0,05 ; J2 C. 0,10 ; J2 C. 0,05 ; J2 G. 0,10 ; J2 G. 0,05.

Profils propres à ce volet : la ligne globale LC de la méthode lognormale et celle de Merz-Wüthrich sont deux familles distinctes, et Φ5 reste interne à un volet. Profil global de D2-Fk = union des profils présents dans les deux volets ; décision requise si Φ0, Φ4 ou Φ5 apparaît dans l'un ou l'autre.

### T-F1 — niveau sous H0 des p de famille et de la p globale (K-F1)

Par jeu, famille et seuil : n réplications traitées où la ligne est présente (k ≥ 2), dont les p absentes (B effectif de famille < 50, texte T-3b ; comptées comme non-rejet) ; k rejets (p < α) ; taux k / n et IC de Clopper-Pearson à 95 % (5 décimales ; classe sur les valeurs non arrondies) ; référence ρ_F, taille du test de Monte-Carlo idéal à B_eff = 999 pour une statistique sans atome (majorant en présence d'atomes) ; classe de #166 et #206 (côté en gras si l'IC est disjoint de la bande [ρ_F/2 ; 3ρ_F/2]).

| Jeu | Famille | traitées | n (ligne présente) | abs. T-3b | ρ_F 0,10 | k 0,10 | taux [IC] 0,10 | classe 0,10 | ρ_F 0,05 | k 0,05 | taux [IC] 0,05 | classe 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| J1 | B. | 2000 | 2000 | 0 | 0,099 | 219 | 0,10950 [0,09614 ; 0,12401] | compatible | 0,049 | 117 | 0,05850 [0,04862 ; 0,06970] | compatible |
| J1 | C. | 2000 | 0 | 0 | 0,099 | 0 | — — | non évaluable (n = 0) | 0,049 | 0 | — — | non évaluable (n = 0) |
| J1 | D. | 2000 | 2000 | 0 | 0,099 | 186 | 0,09300 [0,08063 ; 0,10658] | compatible | 0,049 | 94 | 0,04700 [0,03815 ; 0,05721] | compatible |
| J1 | E. | 2000 | 2000 | 0 | 0,099 | 186 | 0,09300 [0,08063 ; 0,10658] | compatible | 0,049 | 104 | 0,05200 [0,04268 ; 0,06266] | compatible |
| J1 | F. | 2000 | 2000 | 0 | 0,099 | 199 | 0,09950 [0,08673 ; 0,11346] | compatible | 0,049 | 109 | 0,05450 [0,04496 ; 0,06537] | compatible |
| J1 | G. | 2000 | 0 | 0 | 0,099 | 0 | — — | non évaluable (n = 0) | 0,049 | 0 | — — | non évaluable (n = 0) |
| J1 | LC (globale) | 2000 | 2000 | 0 | 0,099 | 215 | 0,10750 [0,09426 ; 0,12190] | compatible | 0,049 | 105 | 0,05250 [0,04314 ; 0,06320] | compatible |
| J2 | B. | 2000 | 2000 | 0 | 0,099 | 166 | 0,08300 [0,07128 ; 0,09596] | écart mineur | 0,049 | 80 | 0,04000 [0,03184 ; 0,04954] | compatible |
| J2 | C. | 2000 | 0 | 0 | 0,099 | 0 | — — | non évaluable (n = 0) | 0,049 | 0 | — — | non évaluable (n = 0) |
| J2 | D. | 2000 | 2000 | 0 | 0,099 | 196 | 0,09800 [0,08532 ; 0,11188] | compatible | 0,049 | 85 | 0,04250 [0,03409 ; 0,05229] | compatible |
| J2 | E. | 2000 | 2000 | 0 | 0,099 | 192 | 0,09600 [0,08344 ; 0,10976] | compatible | 0,049 | 111 | 0,05550 [0,04587 ; 0,06645] | compatible |
| J2 | F. | 2000 | 2000 | 0 | 0,099 | 204 | 0,10200 [0,08908 ; 0,11610] | compatible | 0,049 | 109 | 0,05450 [0,04496 ; 0,06537] | compatible |
| J2 | G. | 2000 | 0 | 0 | 0,099 | 0 | — — | non évaluable (n = 0) | 0,049 | 0 | — — | non évaluable (n = 0) |
| J2 | LC (globale) | 2000 | 2000 | 0 | 0,099 | 198 | 0,09900 [0,08626 ; 0,11293] | compatible | 0,049 | 83 | 0,04150 [0,03319 ; 0,05119] | compatible |

### T-F2 — composition des familles : k, présence de la ligne, plancher

Sur les réplications traitées : k, nombre de tests membres (règle du par. 1.3 de la spécification de Fk, recomptée par le script) ; ligne présente si k ≥ 2 (Q-D1-Fk-2 (a)), absente pour k ≤ 1 ; présente sans p si le B effectif de famille est < 50 (T-3b) ; masse au plancher : part des p de famille définies égales à 1/(B effectif de famille + 1).

| Jeu | Famille | traitées | distribution de k (k : réplications) | ligne présente (part) | dont sans p (T-3b) | p définies | masse au plancher |
| --- | --- | --- | --- | --- | --- | --- | --- |
| J1 | B. | 2000 | 4 : 1937 ; 5 : 63 | 2000 (1,00000) | 0 | 2000 | 0,00150 |
| J1 | C. | 2000 | 1 : 2000 | 0 (0,00000) | 0 | 0 | — |
| J1 | D. | 2000 | 6 : 2000 | 2000 (1,00000) | 0 | 2000 | 0,00000 |
| J1 | E. | 2000 | 3 : 995 ; 5 : 1005 | 2000 (1,00000) | 0 | 2000 | 0,00100 |
| J1 | F. | 2000 | 3 : 995 ; 6 : 1005 | 2000 (1,00000) | 0 | 2000 | 0,00000 |
| J1 | G. | 2000 | 0 : 2000 | 0 (0,00000) | 0 | 0 | — |
| J1 | LC (globale) | 2000 | 17 : 995 ; 22 : 942 ; 23 : 63 | 2000 (1,00000) | 0 | 2000 | 0,00000 |
| J2 | B. | 2000 | 4 : 1997 ; 5 : 3 | 2000 (1,00000) | 0 | 2000 | 0,00050 |
| J2 | C. | 2000 | 1 : 2000 | 0 (0,00000) | 0 | 0 | — |
| J2 | D. | 2000 | 6 : 2000 | 2000 (1,00000) | 0 | 2000 | 0,00000 |
| J2 | E. | 2000 | 3 : 722 ; 5 : 1278 | 2000 (1,00000) | 0 | 2000 | 0,00200 |
| J2 | F. | 2000 | 3 : 722 ; 6 : 1278 | 2000 (1,00000) | 0 | 2000 | 0,00000 |
| J2 | G. | 2000 | 0 : 2000 | 0 (0,00000) | 0 | 0 | — |
| J2 | LC (globale) | 2000 | 17 : 722 ; 22 : 1275 ; 23 : 3 | 2000 (1,00000) | 0 | 2000 | 0,00000 |

### T-F3 — multiplicité sous H0 et lecture conjointe (K-F2, descriptif)

Sur les réplications traitées : part à au moins une ALERTE ou un ECHEC, et à au moins un ECHEC, parmi les lignes de type test, puis parmi les seules lignes de sens « ne pas rejeter » (sans le TOST ni le test de Pitman, de sens « rejeter », dont l'ALERTE ou l'ECHEC ne signale pas un écart au modèle) ; part à p globale < α (p absente : non-rejet) ; par famille, part à au moins un test membre de p_mc < α (plus petite p_mc des membres) contre part à p de famille < α (ligne absente ou sans p : non-rejet). Taux descriptifs, sans référence ni classe.

| Jeu | n | ≥ 1 A ou E (tests) | ≥ 1 A ou E (tests « ne pas rejeter ») | ≥ 1 E (tests) | ≥ 1 E (tests « ne pas rejeter ») | p globale < 0,10 | p globale < 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| J1 | 2000 | 0,70700 | 0,55350 | 0,36550 | 0,30750 | 0,10750 | 0,05250 |
| J2 | 2000 | 0,77850 | 0,61000 | 0,40950 | 0,35200 | 0,09900 | 0,04150 |

| Jeu | Famille | n | ≥ 1 membre p_mc < 0,10 | p de famille < 0,10 | ≥ 1 membre p_mc < 0,05 | p de famille < 0,05 |
| --- | --- | --- | --- | --- | --- | --- |
| J1 | B. | 2000 | 0,19100 | 0,10950 | 0,10950 | 0,05850 |
| J1 | C. | 2000 | 0,09950 | 0,00000 | 0,04950 | 0,00000 |
| J1 | D. | 2000 | 0,16900 | 0,09300 | 0,09050 | 0,04700 |
| J1 | E. | 2000 | 0,19850 | 0,09300 | 0,08200 | 0,05200 |
| J1 | F. | 2000 | 0,24700 | 0,09950 | 0,12050 | 0,05450 |
| J1 | G. | 2000 | 0,00000 | 0,00000 | 0,00000 | 0,00000 |
| J1 | LC (globale) | 2000 | 0,55400 | 0,10750 | 0,31000 | 0,05250 |
| J2 | B. | 2000 | 0,23300 | 0,08300 | 0,11900 | 0,04000 |
| J2 | C. | 2000 | 0,10950 | 0,00000 | 0,04900 | 0,00000 |
| J2 | D. | 2000 | 0,19450 | 0,09800 | 0,10150 | 0,04250 |
| J2 | E. | 2000 | 0,20600 | 0,09600 | 0,09250 | 0,05550 |
| J2 | F. | 2000 | 0,25350 | 0,10200 | 0,13350 | 0,05450 |
| J2 | G. | 2000 | 0,00000 | 0,00000 | 0,00000 | 0,00000 |
| J2 | LC (globale) | 2000 | 0,60650 | 0,09900 | 0,35150 | 0,04150 |

### T-F4 — voisinage des seuils (K-F4, descriptif)

Fréquence sous H0 de |p − s| < 2 err_mc, s ∈ {0,10 ; 0,05} : sur les p de famille définies (err_mc = √(p (1 − p)/B_eff), queue simple), puis par statistique du catalogue sur les p_mc définies (err_mc d'engine_p_mc()). Les lignes par statistique ignorent la bascule de la règle R1 et l'atteignabilité du seuil (plancher de la p) : ce n'est pas l'ensemble « à la frontière » de #244 (règle d'add(), PHRASE_VERDICT_SENSIBLE_MC), seulement la fréquence de la condition sur p_mc et err_mc.

| Jeu | Famille ou statistique | p définies | \|p − 0,10\| < 2 err_mc | \|p − 0,05\| < 2 err_mc |
| --- | --- | --- | --- | --- |
| J1 | B. | 2000 | 0,03750 | 0,03250 |
| J1 | C. | 0 | — | — |
| J1 | D. | 2000 | 0,02750 | 0,02800 |
| J1 | E. | 2000 | 0,04400 | 0,02100 |
| J1 | F. | 2000 | 0,03000 | 0,03600 |
| J1 | G. | 0 | — | — |
| J1 | LC (globale) | 2000 | 0,03650 | 0,02950 |
| J1 | AD | 2000 | 0,03450 | 0,02750 |
| J1 | CvM | 2000 | 0,03350 | 0,03000 |
| J1 | KS | 2000 | 0,02950 | 0,02350 |
| J1 | SW | 2000 | 0,03650 | 0,02500 |
| J1 | SF | 2000 | 0,03250 | 0,02750 |
| J1 | JB | 2000 | 0,03550 | 0,02450 |
| J1 | DW | 2000 | 0,06000 | 0,04800 |
| J1 | supF | 2000 | 0,04900 | 0,02450 |
| J1 | CUSUM | 2000 | 0,03500 | 0,02750 |
| J1 | Grubbs | 2000 | 0,03900 | 0,02250 |
| J1 | Lillie | 2000 | 0,02800 | 0,01950 |
| J1 | Intercept | 2000 | 0,06900 | 0,03800 |
| J1 | RESET | 2000 | 0,04300 | 0,03200 |
| J1 | BP | 2000 | 0,04050 | 0,02750 |
| J1 | BP79 | 2000 | 0,03700 | 0,02250 |
| J1 | White | 2000 | 0,04100 | 0,03250 |
| J1 | GQ | 2000 | 0,05750 | 0,04150 |
| J1 | BF | 2000 | 0,03400 | 0,03000 |
| J1 | Smirnov | 2000 | 0,00000 | 0,00250 |
| J1 | LB2 | 2000 | 0,03600 | 0,02550 |
| J1 | Runs | 2000 | 0,00550 | 0,05500 |
| J1 | MK | 2000 | 0,04550 | 0,03450 |
| J1 | SpearVol | 2000 | 0,05150 | 0,03450 |
| J1 | SpearTps | 2000 | 0,05600 | 0,03750 |
| J1 | DAgo | 2000 | 0,05250 | 0,03850 |
| J1 | CoxStuart | 2000 | 0,03650 | 0,00000 |
| J1 | DWr | 2000 | 0,06350 | 0,04600 |
| J1 | Runsr | 2000 | 0,00550 | 0,05450 |
| J1 | supFr | 2000 | 0,04650 | 0,02150 |
| J1 | CUSUMr | 2000 | 0,04250 | 0,03000 |
| J1 | Grubbsr | 2000 | 0,03600 | 0,03200 |
| J2 | B. | 2000 | 0,03600 | 0,02850 |
| J2 | C. | 0 | — | — |
| J2 | D. | 2000 | 0,04050 | 0,02750 |
| J2 | E. | 2000 | 0,02950 | 0,03050 |
| J2 | F. | 2000 | 0,02700 | 0,03150 |
| J2 | G. | 0 | — | — |
| J2 | LC (globale) | 2000 | 0,03850 | 0,02550 |
| J2 | AD | 2000 | 0,04050 | 0,02950 |
| J2 | CvM | 2000 | 0,03450 | 0,03050 |
| J2 | KS | 2000 | 0,04550 | 0,01800 |
| J2 | SW | 2000 | 0,03800 | 0,02600 |
| J2 | SF | 2000 | 0,03950 | 0,02400 |
| J2 | JB | 2000 | 0,04500 | 0,02600 |
| J2 | DW | 2000 | 0,06250 | 0,04250 |
| J2 | supF | 2000 | 0,04000 | 0,01950 |
| J2 | CUSUM | 2000 | 0,04750 | 0,02550 |
| J2 | Grubbs | 2000 | 0,04450 | 0,02700 |
| J2 | Lillie | 2000 | 0,03550 | 0,02800 |
| J2 | Intercept | 2000 | 0,04800 | 0,03600 |
| J2 | RESET | 2000 | 0,03950 | 0,02300 |
| J2 | BP | 2000 | 0,03550 | 0,03550 |
| J2 | BP79 | 2000 | 0,03800 | 0,02750 |
| J2 | White | 2000 | 0,03550 | 0,02900 |
| J2 | GQ | 2000 | 0,03700 | 0,02900 |
| J2 | BF | 2000 | 0,04500 | 0,02850 |
| J2 | Smirnov | 2000 | 0,00150 | 0,00150 |
| J2 | LB2 | 2000 | 0,04200 | 0,02650 |
| J2 | Runs | 2000 | 0,01000 | 0,05350 |
| J2 | MK | 2000 | 0,04200 | 0,03100 |
| J2 | SpearVol | 2000 | 0,04200 | 0,03900 |
| J2 | SpearTps | 2000 | 0,04700 | 0,04150 |
| J2 | DAgo | 2000 | 0,05300 | 0,03750 |
| J2 | CoxStuart | 2000 | 0,02950 | 0,00000 |
| J2 | DWr | 2000 | 0,06250 | 0,04250 |
| J2 | Runsr | 2000 | 0,00800 | 0,05150 |
| J2 | supFr | 2000 | 0,03500 | 0,02650 |
| J2 | CUSUMr | 2000 | 0,03400 | 0,03200 |
| J2 | Grubbsr | 2000 | 0,04200 | 0,02600 |

## Jeu J1 : tableaux de #166 sur la même exécution (T1, T1 bis, T2 étendu, T3)

### T1 -- calibration de p_mc : les 31 statistiques de USP_CATALOGUE_MC (p_mc retenue ou non)

| Statistique | Ligne de usp_tests() | Queue | n | < 0,10 : k | taux | IC 95 % | réf. | réf. dans l'IC | bande [réf/2 ; 3réf/2] | < 0,05 : k | taux | IC 95 % | réf. | réf. dans l'IC | bande [réf/2 ; 3réf/2] | p_mc absente |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AD | Anderson-Darling | haut | 2000 | 185 | 0,0925 | [0,0802 ; 0,1061] | 0,1000 | oui | — | 89 | 0,0445 | [0,0359 ; 0,0545] | 0,0500 | oui | — | 0 |
| CvM | Cramer-von Mises | haut | 2000 | 192 | 0,0960 | [0,0834 ; 0,1098] | 0,1000 | oui | — | 89 | 0,0445 | [0,0359 ; 0,0545] | 0,0500 | oui | — | 0 |
| KS | Kolmogorov-Smirnov contre N(0,1) | haut | 2000 | 168 | 0,0840 | [0,0722 ; 0,0970] | 0,1000 | **non** | dans | 91 | 0,0455 | [0,0368 ; 0,0556] | 0,0500 | oui | — | 0 |
| SW | Shapiro-Wilk sur residus standardises | bas | 2000 | 183 | 0,0915 | [0,0792 ; 0,1050] | 0,1000 | oui | — | 88 | 0,0440 | [0,0354 ; 0,0539] | 0,0500 | oui | — | 0 |
| SF | Shapiro-Francia | bas | 2000 | 179 | 0,0895 | [0,0773 ; 0,1029] | 0,1000 | oui | — | 94 | 0,0470 | [0,0381 ; 0,0572] | 0,0500 | oui | — | 0 |
| JB | Jarque-Bera | haut | 2000 | 184 | 0,0920 | [0,0797 ; 0,1055] | 0,1000 | oui | — | 95 | 0,0475 | [0,0386 ; 0,0578] | 0,0500 | oui | — | 0 |
| DW | Autocorrelation d'ordre 1 (Durbin-Watson) | deux | 2000 | 226 | 0,1130 | [0,0994 ; 0,1277] | 0,1000 | oui | — | 99 | 0,0495 | [0,0404 ; 0,0599] | 0,0500 | oui | — | 0 |
| supF | Rupture de niveau (sup-F) | haut | 2000 | 213 | 0,1065 | [0,0933 ; 0,1209] | 0,1000 | oui | — | 101 | 0,0505 | [0,0413 ; 0,0610] | 0,0500 | oui | — | 0 |
| CUSUM | Stabilite cumulee (OLS-CUSUM) | haut | 2000 | 211 | 0,1055 | [0,0924 ; 0,1198] | 0,1000 | oui | — | 98 | 0,0490 | [0,0400 ; 0,0594] | 0,0500 | oui | — | 0 |
| Grubbs | Valeur aberrante isolee (Grubbs) | haut | 2000 | 204 | 0,1020 | [0,0891 ; 0,1161] | 0,1000 | oui | — | 94 | 0,0470 | [0,0381 ; 0,0572] | 0,0500 | oui | — | 0 |
| Lillie | Lilliefors (KS a parametres estimes) | haut | 2000 | 174 | 0,0870 | [0,0750 ; 0,1002] | 0,1000 | oui | — | 97 | 0,0485 | [0,0395 ; 0,0588] | 0,0500 | oui | — | 0 |
| Intercept | Nullite de la constante (proportionnalite stricte) | deux | 2000 | 217 | 0,1085 | [0,0952 ; 0,1230] | 0,1000 | oui | — | 115 | 0,0575 | [0,0477 ; 0,0686] | 0,0500 | oui | — | 0 |
| RESET | RESET (forme fonctionnelle) | haut | 2000 | 225 | 0,1125 | [0,0990 ; 0,1272] | 0,1000 | oui | — | 113 | 0,0565 | [0,0468 ; 0,0675] | 0,0500 | oui | — | 0 |
| BP | Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | haut | 2000 | 199 | 0,0995 | [0,0867 ; 0,1135] | 0,1000 | oui | — | 99 | 0,0495 | [0,0404 ; 0,0599] | 0,0500 | oui | — | 0 |
| BP79 | Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | haut | 2000 | 190 | 0,0950 | [0,0825 ; 0,1087] | 0,1000 | oui | — | 99 | 0,0495 | [0,0404 ; 0,0599] | 0,0500 | oui | — | 0 |
| White | Heteroscedasticite (forme quadratique) | haut | 2000 | 209 | 0,1045 | [0,0914 ; 0,1187] | 0,1000 | oui | — | 96 | 0,0480 | [0,0391 ; 0,0583] | 0,0500 | oui | — | 0 |
| GQ | Egalite des variances petits vs gros volumes | deux | 2000 | 180 | 0,0900 | [0,0778 ; 0,1034] | 0,1000 | oui | — | 70 | 0,0350 | [0,0274 ; 0,0440] | 0,0500 | **non** | dans | 0 |
| BF | Homogeneite des dispersions (mediane) | haut | 2000 | 201 | 0,1005 | [0,0877 ; 0,1145] | 0,1000 | oui | — | 100 | 0,0500 | [0,0409 ; 0,0605] | 0,0500 | oui | — | 0 |
| Smirnov | Egalite des lois petits vs gros volumes (2 ech.) | haut | 2000 | 63 | 0,0315 | [0,0243 ; 0,0401] | 0,0286 † | oui | — | 63 | 0,0315 | [0,0243 ; 0,0401] | 0,0286 † | oui | — | 0 |
| LB2 | Ljung-Box (retard 2) | haut | 2000 | 204 | 0,1020 | [0,0891 ; 0,1161] | 0,1000 | oui | — | 95 | 0,0475 | [0,0386 ; 0,0578] | 0,0500 | oui | — | 0 |
| Runs | Test des suites (aleatoire des signes) | deux | 2000 | 125 | 0,0625 | [0,0523 ; 0,0740] | 0,0571 † | oui | — | 19 | 0,0095 | [0,0057 ; 0,0148] | 0,0097 † | oui | — | 0 |
| MK | Tendance monotone du ratio S/P | deux | 2000 | 147 | 0,0735 | [0,0624 ; 0,0858] | 0,0711 † | oui | — | 80 | 0,0400 | [0,0318 ; 0,0495] | 0,0336 † | oui | — | 0 |
| SpearVol | Independance ratio S/P vs volume | deux | 2000 | 183 | 0,0915 | [0,0792 ; 0,1050] | 0,0904 † | oui | — | 102 | 0,0510 | [0,0418 ; 0,0616] | 0,0429 † | oui | — | 0 |
| SpearTps | Correlation ratio S/P vs temps | deux | 2000 | 188 | 0,0940 | [0,0816 ; 0,1076] | 0,0904 † | oui | — | 97 | 0,0485 | [0,0395 ; 0,0588] | 0,0429 † | oui | — | 0 |
| DAgo | Asymetrie (D'Agostino, T >= 8) | deux | 2000 | 182 | 0,0910 | [0,0788 ; 0,1045] | 0,1000 | oui | — | 88 | 0,0440 | [0,0354 ; 0,0539] | 0,0500 | oui | — | 0 |
| CoxStuart | Tendance par signes du ratio S/P | haut | 2000 | 4 | 0,0020 | [0,0005 ; 0,0051] | 0,0006 † | oui | non applicable (réf. < 2/n) | 0 | 0,0000 | [0,0000 ; 0,0018] | 0,0000 † | oui | non applicable (réf. < 2/n) | 0 |
| DWr | Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | deux | 2000 | 217 | 0,1085 | [0,0952 ; 0,1230] | 0,1000 | oui | — | 99 | 0,0495 | [0,0404 ; 0,0599] | 0,0500 | oui | — | 0 |
| Runsr | Test des suites sur ratios bruts | deux | 2000 | 124 | 0,0620 | [0,0518 ; 0,0735] | 0,0571 † | oui | — | 19 | 0,0095 | [0,0057 ; 0,0148] | 0,0097 † | oui | — | 0 |
| supFr | Rupture de niveau (sup-F) sur ratios bruts | haut | 2000 | 204 | 0,1020 | [0,0891 ; 0,1161] | 0,1000 | oui | — | 106 | 0,0530 | [0,0436 ; 0,0637] | 0,0500 | oui | — | 0 |
| CUSUMr | Stabilite cumulee (OLS-CUSUM) sur ratios bruts | haut | 2000 | 212 | 0,1060 | [0,0928 ; 0,1203] | 0,1000 | oui | — | 101 | 0,0505 | [0,0413 ; 0,0610] | 0,0500 | oui | — | 0 |
| Grubbsr | Valeur aberrante isolee (Grubbs) sur ratios bruts | haut | 2000 | 206 | 0,1030 | [0,0900 ; 0,1172] | 0,1000 | oui | — | 100 | 0,0500 | [0,0409 ; 0,0605] | 0,0500 | oui | — | 0 |

n : réplications traitées (2000) où la p_mc est calculée ; p_mc absente : réplications traitées sans p_mc (motif en T3). Statistique continue : référence = seuil ; sous échangeabilité, P(p_mc < seuil) vaut en fait 0,099 et 0,049 en queue simple, 0,098 et 0,048 en bilatéral (B = 999), écart négligeable devant l'IC. † Loi de référence discrète : référence = taille lissée P(p_mc < seuil) sous la loi échangeable à T = 8 sans ex aequo et B = 999 (T0), qui tient compte du bruit Monte-Carlo de la p_mc autour des atomes de la loi.

Multiplicité : T1 compte 62 intervalles (31 statistiques × 2 seuils) ; ici 2 excluent la référence. Sur J1 et J2 réunis, 124 intervalles : environ 6 exclusions (5 % de 124) sont attendues par hasard même si toutes les références sont justes (intervalles corrélés entre eux ; ordre de grandeur, pas un test). T1 bis et T2 ajoutent leurs propres intervalles.

### T1 bis -- calibration de p_mc par régime de δ̂* du réajustement (références de T1)

| Statistique | Régime | n | < 0,10 : k | taux | IC 95 % | réf. dans l'IC | bande [réf/2 ; 3réf/2] | < 0,05 : k | taux | IC 95 % | réf. dans l'IC | bande [réf/2 ; 3réf/2] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AD | δ̂* = 1 (π̂* constant) | 995 | 96 | 0,0965 | [0,0788 ; 0,1165] | oui | — | 42 | 0,0422 | [0,0306 ; 0,0566] | oui | — |
| AD | δ̂* = 0 (π̂* variable) | 930 | 86 | 0,0925 | [0,0746 ; 0,1129] | oui | — | 46 | 0,0495 | [0,0364 ; 0,0654] | oui | — |
| AD | δ̂* intérieur (π̂* variable) | 75 | 3 | 0,0400 | [0,0083 ; 0,1125] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| CvM | δ̂* = 1 (π̂* constant) | 995 | 95 | 0,0955 | [0,0779 ; 0,1155] | oui | — | 44 | 0,0442 | [0,0323 ; 0,0589] | oui | — |
| CvM | δ̂* = 0 (π̂* variable) | 930 | 92 | 0,0989 | [0,0805 ; 0,1199] | oui | — | 44 | 0,0473 | [0,0346 ; 0,0630] | oui | — |
| CvM | δ̂* intérieur (π̂* variable) | 75 | 5 | 0,0667 | [0,0220 ; 0,1488] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| KS | δ̂* = 1 (π̂* constant) | 995 | 79 | 0,0794 | [0,0634 ; 0,0980] | **non** | dans | 45 | 0,0452 | [0,0332 ; 0,0601] | oui | — |
| KS | δ̂* = 0 (π̂* variable) | 930 | 85 | 0,0914 | [0,0737 ; 0,1118] | oui | — | 45 | 0,0484 | [0,0355 ; 0,0642] | oui | — |
| KS | δ̂* intérieur (π̂* variable) | 75 | 4 | 0,0533 | [0,0147 ; 0,1310] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| SW | δ̂* = 1 (π̂* constant) | 995 | 91 | 0,0915 | [0,0743 ; 0,1111] | oui | — | 40 | 0,0402 | [0,0289 ; 0,0543] | oui | — |
| SW | δ̂* = 0 (π̂* variable) | 930 | 89 | 0,0957 | [0,0776 ; 0,1164] | oui | — | 47 | 0,0505 | [0,0374 ; 0,0666] | oui | — |
| SW | δ̂* intérieur (π̂* variable) | 75 | 3 | 0,0400 | [0,0083 ; 0,1125] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| SF | δ̂* = 1 (π̂* constant) | 995 | 89 | 0,0894 | [0,0724 ; 0,1089] | oui | — | 46 | 0,0462 | [0,0340 ; 0,0612] | oui | — |
| SF | δ̂* = 0 (π̂* variable) | 930 | 87 | 0,0935 | [0,0756 ; 0,1141] | oui | — | 47 | 0,0505 | [0,0374 ; 0,0666] | oui | — |
| SF | δ̂* intérieur (π̂* variable) | 75 | 3 | 0,0400 | [0,0083 ; 0,1125] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| JB | δ̂* = 1 (π̂* constant) | 995 | 91 | 0,0915 | [0,0743 ; 0,1111] | oui | — | 49 | 0,0492 | [0,0367 ; 0,0646] | oui | — |
| JB | δ̂* = 0 (π̂* variable) | 930 | 89 | 0,0957 | [0,0776 ; 0,1164] | oui | — | 44 | 0,0473 | [0,0346 ; 0,0630] | oui | — |
| JB | δ̂* intérieur (π̂* variable) | 75 | 4 | 0,0533 | [0,0147 ; 0,1310] | oui | — | 2 | 0,0267 | [0,0032 ; 0,0930] | oui | — |
| DW | δ̂* = 1 (π̂* constant) | 995 | 121 | 0,1216 | [0,1019 ; 0,1435] | **non** | dans | 51 | 0,0513 | [0,0384 ; 0,0668] | oui | — |
| DW | δ̂* = 0 (π̂* variable) | 930 | 100 | 0,1075 | [0,0883 ; 0,1292] | oui | — | 47 | 0,0505 | [0,0374 ; 0,0666] | oui | — |
| DW | δ̂* intérieur (π̂* variable) | 75 | 5 | 0,0667 | [0,0220 ; 0,1488] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| supF | δ̂* = 1 (π̂* constant) | 995 | 104 | 0,1045 | [0,0862 ; 0,1252] | oui | — | 54 | 0,0543 | [0,0410 ; 0,0702] | oui | — |
| supF | δ̂* = 0 (π̂* variable) | 930 | 104 | 0,1118 | [0,0923 ; 0,1339] | oui | — | 45 | 0,0484 | [0,0355 ; 0,0642] | oui | — |
| supF | δ̂* intérieur (π̂* variable) | 75 | 5 | 0,0667 | [0,0220 ; 0,1488] | oui | — | 2 | 0,0267 | [0,0032 ; 0,0930] | oui | — |
| CUSUM | δ̂* = 1 (π̂* constant) | 995 | 109 | 0,1095 | [0,0908 ; 0,1306] | oui | — | 52 | 0,0523 | [0,0393 ; 0,0680] | oui | — |
| CUSUM | δ̂* = 0 (π̂* variable) | 930 | 98 | 0,1054 | [0,0864 ; 0,1269] | oui | — | 45 | 0,0484 | [0,0355 ; 0,0642] | oui | — |
| CUSUM | δ̂* intérieur (π̂* variable) | 75 | 4 | 0,0533 | [0,0147 ; 0,1310] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| Grubbs | δ̂* = 1 (π̂* constant) | 995 | 106 | 0,1065 | [0,0880 ; 0,1274] | oui | — | 51 | 0,0513 | [0,0384 ; 0,0668] | oui | — |
| Grubbs | δ̂* = 0 (π̂* variable) | 930 | 93 | 0,1000 | [0,0815 ; 0,1211] | oui | — | 43 | 0,0462 | [0,0337 ; 0,0618] | oui | — |
| Grubbs | δ̂* intérieur (π̂* variable) | 75 | 5 | 0,0667 | [0,0220 ; 0,1488] | oui | — | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors |
| Lillie | δ̂* = 1 (π̂* constant) | 995 | 80 | 0,0804 | [0,0643 ; 0,0991] | **non** | dans | 47 | 0,0472 | [0,0349 ; 0,0623] | oui | — |
| Lillie | δ̂* = 0 (π̂* variable) | 930 | 90 | 0,0968 | [0,0785 ; 0,1176] | oui | — | 48 | 0,0516 | [0,0383 ; 0,0679] | oui | — |
| Lillie | δ̂* intérieur (π̂* variable) | 75 | 4 | 0,0533 | [0,0147 ; 0,1310] | oui | — | 2 | 0,0267 | [0,0032 ; 0,0930] | oui | — |
| Intercept | δ̂* = 1 (π̂* constant) | 995 | 111 | 0,1116 | [0,0927 ; 0,1328] | oui | — | 55 | 0,0553 | [0,0419 ; 0,0713] | oui | — |
| Intercept | δ̂* = 0 (π̂* variable) | 930 | 100 | 0,1075 | [0,0883 ; 0,1292] | oui | — | 57 | 0,0613 | [0,0467 ; 0,0787] | oui | — |
| Intercept | δ̂* intérieur (π̂* variable) | 75 | 6 | 0,0800 | [0,0299 ; 0,1660] | oui | — | 3 | 0,0400 | [0,0083 ; 0,1125] | oui | — |
| RESET | δ̂* = 1 (π̂* constant) | 995 | 119 | 0,1196 | [0,1001 ; 0,1414] | **non** | dans | 60 | 0,0603 | [0,0463 ; 0,0769] | oui | — |
| RESET | δ̂* = 0 (π̂* variable) | 930 | 99 | 0,1065 | [0,0874 ; 0,1281] | oui | — | 51 | 0,0548 | [0,0411 ; 0,0715] | oui | — |
| RESET | δ̂* intérieur (π̂* variable) | 75 | 7 | 0,0933 | [0,0384 ; 0,1829] | oui | — | 2 | 0,0267 | [0,0032 ; 0,0930] | oui | — |
| BP | δ̂* = 1 (π̂* constant) | 995 | 127 | 0,1276 | [0,1075 ; 0,1500] | **non** | dans | 70 | 0,0704 | [0,0552 ; 0,0881] | **non** | dans |
| BP | δ̂* = 0 (π̂* variable) | 930 | 64 | 0,0688 | [0,0534 ; 0,0870] | **non** | dans | 25 | 0,0269 | [0,0175 ; 0,0394] | **non** | dans |
| BP | δ̂* intérieur (π̂* variable) | 75 | 8 | 0,1067 | [0,0472 ; 0,1994] | oui | — | 4 | 0,0533 | [0,0147 ; 0,1310] | oui | — |
| BP79 | δ̂* = 1 (π̂* constant) | 995 | 121 | 0,1216 | [0,1019 ; 0,1435] | **non** | dans | 64 | 0,0643 | [0,0499 ; 0,0814] | oui | — |
| BP79 | δ̂* = 0 (π̂* variable) | 930 | 63 | 0,0677 | [0,0524 ; 0,0858] | **non** | dans | 30 | 0,0323 | [0,0219 ; 0,0457] | **non** | dans |
| BP79 | δ̂* intérieur (π̂* variable) | 75 | 6 | 0,0800 | [0,0299 ; 0,1660] | oui | — | 5 | 0,0667 | [0,0220 ; 0,1488] | oui | — |
| White | δ̂* = 1 (π̂* constant) | 995 | 129 | 0,1296 | [0,1094 ; 0,1521] | **non** | dans | 61 | 0,0613 | [0,0472 ; 0,0781] | oui | — |
| White | δ̂* = 0 (π̂* variable) | 930 | 72 | 0,0774 | [0,0611 ; 0,0965] | **non** | dans | 32 | 0,0344 | [0,0237 ; 0,0482] | **non** | dans |
| White | δ̂* intérieur (π̂* variable) | 75 | 8 | 0,1067 | [0,0472 ; 0,1994] | oui | — | 3 | 0,0400 | [0,0083 ; 0,1125] | oui | — |
| GQ | δ̂* = 1 (π̂* constant) | 995 | 103 | 0,1035 | [0,0853 ; 0,1241] | oui | — | 36 | 0,0362 | [0,0255 ; 0,0497] | **non** | dans |
| GQ | δ̂* = 0 (π̂* variable) | 930 | 71 | 0,0763 | [0,0601 ; 0,0953] | **non** | dans | 34 | 0,0366 | [0,0254 ; 0,0507] | oui | — |
| GQ | δ̂* intérieur (π̂* variable) | 75 | 6 | 0,0800 | [0,0299 ; 0,1660] | oui | — | 0 | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors |
| BF | δ̂* = 1 (π̂* constant) | 995 | 116 | 0,1166 | [0,0973 ; 0,1382] | oui | — | 64 | 0,0643 | [0,0499 ; 0,0814] | oui | — |
| BF | δ̂* = 0 (π̂* variable) | 930 | 77 | 0,0828 | [0,0659 ; 0,1024] | oui | — | 35 | 0,0376 | [0,0264 ; 0,0520] | oui | — |
| BF | δ̂* intérieur (π̂* variable) | 75 | 8 | 0,1067 | [0,0472 ; 0,1994] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| Smirnov | δ̂* = 1 (π̂* constant) | 995 | 31 | 0,0312 | [0,0213 ; 0,0439] | oui | — | 31 | 0,0312 | [0,0213 ; 0,0439] | oui | — |
| Smirnov | δ̂* = 0 (π̂* variable) | 930 | 32 | 0,0344 | [0,0237 ; 0,0482] | oui | — | 32 | 0,0344 | [0,0237 ; 0,0482] | oui | — |
| Smirnov | δ̂* intérieur (π̂* variable) | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | oui | — | 0 | 0,0000 | [0,0000 ; 0,0480] | oui | — |
| LB2 | δ̂* = 1 (π̂* constant) | 995 | 101 | 0,1015 | [0,0834 ; 0,1220] | oui | — | 43 | 0,0432 | [0,0314 ; 0,0578] | oui | — |
| LB2 | δ̂* = 0 (π̂* variable) | 930 | 96 | 0,1032 | [0,0844 ; 0,1246] | oui | — | 50 | 0,0538 | [0,0402 ; 0,0703] | oui | — |
| LB2 | δ̂* intérieur (π̂* variable) | 75 | 7 | 0,0933 | [0,0384 ; 0,1829] | oui | — | 2 | 0,0267 | [0,0032 ; 0,0930] | oui | — |
| Runs | δ̂* = 1 (π̂* constant) | 995 | 58 | 0,0583 | [0,0446 ; 0,0747] | oui | — | 11 | 0,0111 | [0,0055 ; 0,0197] | oui | — |
| Runs | δ̂* = 0 (π̂* variable) | 930 | 65 | 0,0699 | [0,0544 ; 0,0882] | oui | — | 7 | 0,0075 | [0,0030 ; 0,0154] | oui | — |
| Runs | δ̂* intérieur (π̂* variable) | 75 | 2 | 0,0267 | [0,0032 ; 0,0930] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | non applicable (réf. < 2/n) |
| MK | δ̂* = 1 (π̂* constant) | 995 | 77 | 0,0774 | [0,0616 ; 0,0958] | oui | — | 38 | 0,0382 | [0,0272 ; 0,0520] | oui | — |
| MK | δ̂* = 0 (π̂* variable) | 930 | 66 | 0,0710 | [0,0553 ; 0,0894] | oui | — | 40 | 0,0430 | [0,0309 ; 0,0581] | oui | — |
| MK | δ̂* intérieur (π̂* variable) | 75 | 4 | 0,0533 | [0,0147 ; 0,1310] | oui | — | 2 | 0,0267 | [0,0032 ; 0,0930] | oui | — |
| SpearVol | δ̂* = 1 (π̂* constant) | 995 | 85 | 0,0854 | [0,0688 ; 0,1045] | oui | — | 44 | 0,0442 | [0,0323 ; 0,0589] | oui | — |
| SpearVol | δ̂* = 0 (π̂* variable) | 930 | 91 | 0,0978 | [0,0795 ; 0,1188] | oui | — | 56 | 0,0602 | [0,0458 ; 0,0775] | **non** | dans |
| SpearVol | δ̂* intérieur (π̂* variable) | 75 | 7 | 0,0933 | [0,0384 ; 0,1829] | oui | — | 2 | 0,0267 | [0,0032 ; 0,0930] | oui | — |
| SpearTps | δ̂* = 1 (π̂* constant) | 995 | 92 | 0,0925 | [0,0752 ; 0,1122] | oui | — | 48 | 0,0482 | [0,0358 ; 0,0635] | oui | — |
| SpearTps | δ̂* = 0 (π̂* variable) | 930 | 92 | 0,0989 | [0,0805 ; 0,1199] | oui | — | 47 | 0,0505 | [0,0374 ; 0,0666] | oui | — |
| SpearTps | δ̂* intérieur (π̂* variable) | 75 | 4 | 0,0533 | [0,0147 ; 0,1310] | oui | — | 2 | 0,0267 | [0,0032 ; 0,0930] | oui | — |
| DAgo | δ̂* = 1 (π̂* constant) | 995 | 89 | 0,0894 | [0,0724 ; 0,1089] | oui | — | 45 | 0,0452 | [0,0332 ; 0,0601] | oui | — |
| DAgo | δ̂* = 0 (π̂* variable) | 930 | 90 | 0,0968 | [0,0785 ; 0,1176] | oui | — | 42 | 0,0452 | [0,0327 ; 0,0606] | oui | — |
| DAgo | δ̂* intérieur (π̂* variable) | 75 | 3 | 0,0400 | [0,0083 ; 0,1125] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| CoxStuart | δ̂* = 1 (π̂* constant) | 995 | 0 | 0,0000 | [0,0000 ; 0,0037] | oui | non applicable (réf. < 2/n) | 0 | 0,0000 | [0,0000 ; 0,0037] | oui | non applicable (réf. < 2/n) |
| CoxStuart | δ̂* = 0 (π̂* variable) | 930 | 0 | 0,0000 | [0,0000 ; 0,0040] | oui | non applicable (réf. < 2/n) | 0 | 0,0000 | [0,0000 ; 0,0040] | oui | non applicable (réf. < 2/n) |
| CoxStuart | δ̂* intérieur (π̂* variable) | 75 | 4 | 0,0533 | [0,0147 ; 0,1310] | **non** | non applicable (réf. < 2/n) | 0 | 0,0000 | [0,0000 ; 0,0480] | oui | non applicable (réf. < 2/n) |
| DWr | δ̂* = 1 (π̂* constant) | 995 | 119 | 0,1196 | [0,1001 ; 0,1414] | **non** | dans | 50 | 0,0503 | [0,0375 ; 0,0657] | oui | — |
| DWr | δ̂* = 0 (π̂* variable) | 930 | 94 | 0,1011 | [0,0825 ; 0,1223] | oui | — | 48 | 0,0516 | [0,0383 ; 0,0679] | oui | — |
| DWr | δ̂* intérieur (π̂* variable) | 75 | 4 | 0,0533 | [0,0147 ; 0,1310] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| Runsr | δ̂* = 1 (π̂* constant) | 995 | 58 | 0,0583 | [0,0446 ; 0,0747] | oui | — | 11 | 0,0111 | [0,0055 ; 0,0197] | oui | — |
| Runsr | δ̂* = 0 (π̂* variable) | 930 | 64 | 0,0688 | [0,0534 ; 0,0870] | oui | — | 7 | 0,0075 | [0,0030 ; 0,0154] | oui | — |
| Runsr | δ̂* intérieur (π̂* variable) | 75 | 2 | 0,0267 | [0,0032 ; 0,0930] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | non applicable (réf. < 2/n) |
| supFr | δ̂* = 1 (π̂* constant) | 995 | 100 | 0,1005 | [0,0825 ; 0,1209] | oui | — | 55 | 0,0553 | [0,0419 ; 0,0713] | oui | — |
| supFr | δ̂* = 0 (π̂* variable) | 930 | 100 | 0,1075 | [0,0883 ; 0,1292] | oui | — | 49 | 0,0527 | [0,0392 ; 0,0691] | oui | — |
| supFr | δ̂* intérieur (π̂* variable) | 75 | 4 | 0,0533 | [0,0147 ; 0,1310] | oui | — | 2 | 0,0267 | [0,0032 ; 0,0930] | oui | — |
| CUSUMr | δ̂* = 1 (π̂* constant) | 995 | 107 | 0,1075 | [0,0890 ; 0,1285] | oui | — | 54 | 0,0543 | [0,0410 ; 0,0702] | oui | — |
| CUSUMr | δ̂* = 0 (π̂* variable) | 930 | 101 | 0,1086 | [0,0893 ; 0,1304] | oui | — | 46 | 0,0495 | [0,0364 ; 0,0654] | oui | — |
| CUSUMr | δ̂* intérieur (π̂* variable) | 75 | 4 | 0,0533 | [0,0147 ; 0,1310] | oui | — | 1 | 0,0133 | [0,0003 ; 0,0721] | oui | — |
| Grubbsr | δ̂* = 1 (π̂* constant) | 995 | 102 | 0,1025 | [0,0844 ; 0,1231] | oui | — | 51 | 0,0513 | [0,0384 ; 0,0668] | oui | — |
| Grubbsr | δ̂* = 0 (π̂* variable) | 930 | 99 | 0,1065 | [0,0874 ; 0,1281] | oui | — | 47 | 0,0505 | [0,0374 ; 0,0666] | oui | — |
| Grubbsr | δ̂* intérieur (π̂* variable) | 75 | 5 | 0,0667 | [0,0220 ; 0,1488] | oui | — | 2 | 0,0267 | [0,0032 ; 0,0930] | oui | — |

Régime du réajustement de run_engine() sur le jeu simulé (seuils TOL_DELTA_BORD de #72) ; effectifs en T3. Volumes non constants (contrôlé) : π̂* constant si et seulement si δ̂* au bord 1. Règle R7 : à π̂* constant, les lignes à loi exacte retiennent la p exacte ; ailleurs, la p_mc. Les taux par régime sont conditionnels à un événement fonction des données et n'ont pas de référence exacte même pour une p_mc parfaitement calibrée : T1 bis localise un écart, il ne teste pas la calibration par régime.

### T2 -- niveau des verdicts des 47 lignes (puis des lignes de lecture conjointe, #297) : fréquence de p retenue < α et < α/2 parmi les p retenues (règles R1, R3, R4, R7, R13 comprises)

| Ligne | n | p retenue | < 0,10 : k | taux | IC 95 % | réf. | réf. dans l'IC | bande [réf/2 ; 3réf/2] | < 0,05 : k | taux | IC 95 % | réf. | réf. dans l'IC | bande [réf/2 ; 3réf/2] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Nullite de la constante (proportionnalite stricte) | 2000 | 2000 | 217 | 0,1085 | [0,0952 ; 0,1230] | 0,1000 | oui | — | 115 | 0,0575 | [0,0477 ; 0,0686] | 0,0500 | oui | — |
| Equivalence de la constante a zero (TOST) | 2000 | 0 | 0 | — | — | sans objet (H0 \|a\| ≥ Δ fausse sous le modèle ajusté, a = 0 ; sens « rejeter ») | — | — | 0 | — | — | sans objet (H0 \|a\| ≥ Δ fausse sous le modèle ajusté, a = 0 ; sens « rejeter ») | — | — |
| Test de Pitman sur la pente (lien positif pertes / volume) | 2000 | 2000 | 1260 | 0,6300 | [0,6084 ; 0,6512] | sans objet (H0 d'échangeabilité, y indépendant de x, fausse sous le modèle réglementaire à volumes variables ; sens « rejeter ») | — | — | 950 | 0,4750 | [0,4529 ; 0,4972] | sans objet (H0 d'échangeabilité, y indépendant de x, fausse sous le modèle réglementaire à volumes variables ; sens « rejeter ») | — | — |
| Test de Fisher (significativite globale) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Coefficient de determination R2 | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| RESET (forme fonctionnelle) | 2000 | 2000 | 225 | 0,1125 | [0,0990 ; 0,1272] | 0,1000 | oui | — | 113 | 0,0565 | [0,0468 ; 0,0675] | 0,0500 | oui | — |
| Independance ratio S/P vs volume | 2000 | 2000 | 189 | 0,0945 | [0,0820 ; 0,1082] | 0,0933 † | oui | — | 106 | 0,0530 | [0,0436 ; 0,0637] | 0,0444 † | oui | — |
| Correlation ratio S/P vs temps | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Tendance monotone du ratio S/P | 2000 | 2000 | 138 | 0,0690 | [0,0583 ; 0,0810] | 0,0661 † | oui | — | 75 | 0,0375 | [0,0296 ; 0,0468] | 0,0324 † | oui | — |
| Tendance par signes du ratio S/P | 2000 | 63 | 4 | 0,0635 | [0,0176 ; 0,1547] | 0,0006 † | **non** | non applicable (réf. < 2/n) | 0 | 0,0000 | [0,0000 ; 0,0569] | 0,0000 † | oui | non applicable (réf. < 2/n) |
| Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | 2000 | 2000 | 199 | 0,0995 | [0,0867 ; 0,1135] | 0,1000 | oui | — | 99 | 0,0495 | [0,0404 ; 0,0599] | 0,0500 | oui | — |
| Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Heteroscedasticite (forme quadratique) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Egalite des variances petits vs gros volumes | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Homogeneite des dispersions (mediane) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Egalite des lois petits vs gros volumes (2 ech.) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Position de delta dans [0,1] | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Shapiro-Wilk sur residus standardises | 2000 | 2000 | 183 | 0,0915 | [0,0792 ; 0,1050] | 0,1000 | oui | — | 88 | 0,0440 | [0,0354 ; 0,0539] | 0,0500 | oui | — |
| Shapiro-Francia | 2000 | 2000 | 179 | 0,0895 | [0,0773 ; 0,1029] | 0,1000 | oui | — | 94 | 0,0470 | [0,0381 ; 0,0572] | 0,0500 | oui | — |
| Anderson-Darling | 2000 | 2000 | 185 | 0,0925 | [0,0802 ; 0,1061] | 0,1000 | oui | — | 89 | 0,0445 | [0,0359 ; 0,0545] | 0,0500 | oui | — |
| Cramer-von Mises | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Kolmogorov-Smirnov contre N(0,1) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Lilliefors (KS a parametres estimes) | 2000 | 2000 | 174 | 0,0870 | [0,0750 ; 0,1002] | 0,1000 | oui | — | 97 | 0,0485 | [0,0395 ; 0,0588] | 0,0500 | oui | — |
| Jarque-Bera | 2000 | 2000 | 184 | 0,0920 | [0,0797 ; 0,1055] | 0,1000 | oui | — | 95 | 0,0475 | [0,0386 ; 0,0578] | 0,0500 | oui | — |
| Asymetrie (D'Agostino, T >= 8) | 2000 | 2000 | 182 | 0,0910 | [0,0788 ; 0,1045] | 0,1000 | oui | — | 88 | 0,0440 | [0,0354 ; 0,0539] | 0,0500 | oui | — |
| Aplatissement (Anscombe-Glynn, T >= 20) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Autocorrelation d'ordre 1 (Durbin-Watson) | 2000 | 2000 | 222 | 0,1110 | [0,0976 ; 0,1256] | 0,1000 | oui | — | 95 | 0,0475 | [0,0386 ; 0,0578] | 0,0500 | oui | — |
| Ljung-Box (retard 2) | 2000 | 2000 | 204 | 0,1020 | [0,0891 ; 0,1161] | 0,1000 | oui | — | 95 | 0,0475 | [0,0386 ; 0,0578] | 0,0500 | oui | — |
| Test des suites (aleatoire des signes) | 2000 | 2000 | 125 | 0,0625 | [0,0523 ; 0,0740] | 0,0571 † | oui | — | 8 | 0,0040 | [0,0017 ; 0,0079] | 0,0049 † | oui | — |
| Centrage des residus standardises | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Variance unitaire des residus standardises | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Rupture de niveau (sup-F) | 2000 | 2000 | 213 | 0,1065 | [0,0933 ; 0,1209] | 0,1000 | oui | — | 101 | 0,0505 | [0,0413 ; 0,0610] | 0,0500 | oui | — |
| Stabilite cumulee (OLS-CUSUM) | 2000 | 2000 | 211 | 0,1055 | [0,0924 ; 0,1198] | 0,1000 | oui | — | 98 | 0,0490 | [0,0400 ; 0,0594] | 0,0500 | oui | — |
| Valeur aberrante isolee (Grubbs) | 2000 | 2000 | 204 | 0,1020 | [0,0891 ; 0,1161] | 0,1000 | oui | — | 94 | 0,0470 | [0,0381 ; 0,0572] | 0,0500 | oui | — |
| Valeurs aberrantes multiples (ESD generalise) | 2000 | diagnostic par decision (#304) : frequence de k̂ >= 1 | 279 | 0,1395 | [0,1246 ; 0,1555] | 0,1000 ‡ | **non** | dans | 107 | 0,0535 | [0,0440 ; 0,0643] | — | — | — |
| Points influents (distance de Cook) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | 2000 | 1005 | 98 | 0,0975 | [0,0799 ; 0,1175] | 0,1000 | oui | — | 49 | 0,0488 | [0,0363 ; 0,0639] | 0,0500 | oui | — |
| Test des suites sur ratios bruts | 2000 | 1005 | 66 | 0,0657 | [0,0512 ; 0,0828] | 0,0571 † | oui | — | 8 | 0,0080 | [0,0034 ; 0,0156] | 0,0097 † | oui | — |
| Rupture de niveau (sup-F) sur ratios bruts | 2000 | 1005 | 104 | 0,1035 | [0,0853 ; 0,1240] | 0,1000 | oui | — | 51 | 0,0507 | [0,0380 ; 0,0662] | 0,0500 | oui | — |
| Stabilite cumulee (OLS-CUSUM) sur ratios bruts | 2000 | 1005 | 105 | 0,1045 | [0,0862 ; 0,1251] | 0,1000 | oui | — | 47 | 0,0468 | [0,0346 ; 0,0617] | 0,0500 | oui | — |
| Valeur aberrante isolee (Grubbs) sur ratios bruts | 2000 | 1005 | 104 | 0,1035 | [0,0853 ; 0,1240] | 0,1000 | oui | — | 49 | 0,0488 | [0,0363 ; 0,0639] | 0,0500 | oui | — |
| Leviers (hat values) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Sensibilite au retrait d'une annee (jackknife) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Largeur relative de l'IC bootstrap 90% | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Rapport de vraisemblance : delta = 0 (variance lineaire en volume) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Rapport de vraisemblance : delta = 1 (variance quadratique en volume) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| p de famille (minP, lecture conjointe) [B.] | 2000 | 0 | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — |
| p de famille (minP, lecture conjointe) [C.] | 0 | 0 | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — |
| p de famille (minP, lecture conjointe) [D.] | 2000 | 0 | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — |
| p de famille (minP, lecture conjointe) [E.] | 2000 | 0 | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — |
| p de famille (minP, lecture conjointe) [F.] | 2000 | 0 | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — |
| p de famille (minP, lecture conjointe) [G.] | 0 | 0 | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — |
| p globale (minP, lecture conjointe de la batterie) [LC] | 2000 | 0 | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — |

n : réplications traitées ; p retenue : réplications où la ligne a une p retenue. Taux = rejets / p retenues (niveau conditionnel à l'existence d'une p retenue) ; la fréquence inconditionnelle du verdict, rejets / n, se lit dans T2 (suite), colonnes ALERTE et ECHEC. Sens « ne pas rejeter » : p < α donne ALERTE ou ECHEC, p < α/2 ECHEC. Pour les deux lignes en sens « rejeter » (pente, TOST), p < α est un OK : les colonnes donnent une puissance conditionnelle, sans référence.

† Loi de référence discrète : référence = (n_exacte × taille atteignable + n_MC × taille lissée) / (n_exacte + n_MC), sur les natures de la p retenue comptées en T2 (suite) ; référence **approchée** : elle suppose l'échangeabilité et ignore la sélection par le régime (à π̂* variable, la p retenue de ces lignes est la p_mc, règle R7, dont le niveau n'est qu'approché par la taille lissée). Une p retenue d'une autre nature (repli asymptotique nommé, règle R3 ; attendu 0 à T = 8 sans ex æquo) compte dans np et dans les rejets, non dans la référence, alors suivie de « (n hors réf. = k) ».

‡ Ligne ESD (diagnostic par décision depuis #304, sans p-value ni verdict) : première colonne, k̂ ≥ 1 (colonne estimation), mesure P(k̂ ≥ 1), sur les réplications traitées, contre 0,10, niveau nominal de la procédure de Rosner, valeurs critiques à 1 − α/(2 n_i) ; exactitude non établie à T = 8 ni sur z = Pε. Seconde colonne : k̂ = 2, mesure P(k̂ = 2), sans niveau nominal.

### T2 (suite) -- composition des lignes : types, nature de la p retenue, verdicts

| Ligne | n | test | diagnostic | dont inopérant (R1) | non applicable | procédure de décision | p exacte | p Monte-Carlo | p asymptotique | autre p | aucune p | OK | ALERTE | ECHEC | INFO |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Nullite de la constante (proportionnalite stricte) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1783 | 102 | 115 | 0 |
| Equivalence de la constante a zero (TOST) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Test de Pitman sur la pente (lien positif pertes / volume) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 1260 | 522 | 218 | 0 |
| Test de Fisher (significativite globale) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Coefficient de determination R2 | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| RESET (forme fonctionnelle) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1775 | 112 | 113 | 0 |
| Independance ratio S/P vs volume | 2000 | 2000 | 0 | 0 | 0 | 0 | 995 | 1005 | 0 | 0 | 0 | 1811 | 83 | 106 | 0 |
| Correlation ratio S/P vs temps | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Tendance monotone du ratio S/P | 2000 | 2000 | 0 | 0 | 0 | 0 | 995 | 1005 | 0 | 0 | 0 | 1862 | 63 | 75 | 0 |
| Tendance par signes du ratio S/P | 2000 | 63 | 1937 | 1937 | 0 | 0 | 0 | 63 | 0 | 0 | 1937 | 59 | 4 | 0 | 1937 |
| Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1801 | 100 | 99 | 0 |
| Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Heteroscedasticite (forme quadratique) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Egalite des variances petits vs gros volumes | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Homogeneite des dispersions (mediane) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Egalite des lois petits vs gros volumes (2 ech.) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Position de delta dans [0,1] | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Shapiro-Wilk sur residus standardises | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1817 | 95 | 88 | 0 |
| Shapiro-Francia | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1821 | 85 | 94 | 0 |
| Anderson-Darling | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1815 | 96 | 89 | 0 |
| Cramer-von Mises | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Kolmogorov-Smirnov contre N(0,1) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Lilliefors (KS a parametres estimes) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1826 | 77 | 97 | 0 |
| Jarque-Bera | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1816 | 89 | 95 | 0 |
| Asymetrie (D'Agostino, T >= 8) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1818 | 94 | 88 | 0 |
| Aplatissement (Anscombe-Glynn, T >= 20) | 2000 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Autocorrelation d'ordre 1 (Durbin-Watson) | 2000 | 2000 | 0 | 0 | 0 | 0 | 995 | 1005 | 0 | 0 | 0 | 1778 | 127 | 95 | 0 |
| Ljung-Box (retard 2) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1796 | 109 | 95 | 0 |
| Test des suites (aleatoire des signes) | 2000 | 2000 | 0 | 0 | 0 | 0 | 995 | 1005 | 0 | 0 | 0 | 1875 | 117 | 8 | 0 |
| Centrage des residus standardises | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Variance unitaire des residus standardises | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Rupture de niveau (sup-F) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1787 | 112 | 101 | 0 |
| Stabilite cumulee (OLS-CUSUM) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1789 | 113 | 98 | 0 |
| Valeur aberrante isolee (Grubbs) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1796 | 110 | 94 | 0 |
| Valeurs aberrantes multiples (ESD generalise) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Points influents (distance de Cook) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | 2000 | 1005 | 995 | 0 | 0 | 0 | 0 | 1005 | 0 | 0 | 995 | 907 | 49 | 49 | 995 |
| Test des suites sur ratios bruts | 2000 | 1005 | 995 | 0 | 0 | 0 | 0 | 1005 | 0 | 0 | 995 | 939 | 58 | 8 | 995 |
| Rupture de niveau (sup-F) sur ratios bruts | 2000 | 1005 | 995 | 0 | 0 | 0 | 0 | 1005 | 0 | 0 | 995 | 901 | 53 | 51 | 995 |
| Stabilite cumulee (OLS-CUSUM) sur ratios bruts | 2000 | 1005 | 995 | 0 | 0 | 0 | 0 | 1005 | 0 | 0 | 995 | 900 | 58 | 47 | 995 |
| Valeur aberrante isolee (Grubbs) sur ratios bruts | 2000 | 1005 | 995 | 0 | 0 | 0 | 0 | 1005 | 0 | 0 | 995 | 901 | 55 | 49 | 995 |
| Leviers (hat values) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Sensibilite au retrait d'une annee (jackknife) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Largeur relative de l'IC bootstrap 90% | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Rapport de vraisemblance : delta = 0 (variance lineaire en volume) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Rapport de vraisemblance : delta = 1 (variance quadratique en volume) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| p de famille (minP, lecture conjointe) [B.] | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| p de famille (minP, lecture conjointe) [C.] | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| p de famille (minP, lecture conjointe) [D.] | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| p de famille (minP, lecture conjointe) [E.] | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| p de famille (minP, lecture conjointe) [F.] | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| p de famille (minP, lecture conjointe) [G.] | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| p globale (minP, lecture conjointe de la batterie) [LC] | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |

Nature : champ nature_p de la ligne (exacte ; Monte-Carlo ; asymptotique, repli nommé compris ; autre : p sous le modèle auxiliaire pondéré du TOST, exacte par permutation de Pitman sur la pente). Inopérant : détail préfixé « TEST INOPERANT » (règle R1), compté aussi en diagnostic.

### T3 -- régimes, réplications écartées, motifs, contrôles de la famille H, rapport de vraisemblance, IC bootstrap

Régimes de δ̂* :

| Régime | run_engine() (réplications traitées) | code de #72 : usp_ajuster(x, y*) (toutes) |
| --- | --- | --- |
| δ̂* = 1 (π̂* constant) | 995 | 995 |
| δ̂* = 0 (π̂* variable) | 930 | 930 |
| δ̂* intérieur (π̂* variable) | 75 | 75 |
| usp_ajuster() en erreur | 0 | 0 |
| Total | 2000 | 2000 |

Réplications écartées (erreur de run_engine() ou ok = FALSE) : 0 sur 2000.

Motifs d'absence de p_mc (motif_mc, réplications traitées) :

aucun.

Contrôles numériques de la famille H (res$controles, verdicts) :

| Contrôle | OK | ALERTE | ECHEC | autre |
| --- | --- | --- | --- | --- |
| Condition du premier ordre (gradient projete, KKT) | 2000 | 0 | 0 | 0 |
| Convergence multi-demarrages | 2000 | 0 | 0 | 0 |

p_mc des deux lignes du rapport de vraisemblance (#45 ; hors objet de T1 et T2, sans référence) :

| Ligne | Régime de δ̂* | n | < 0,10 : k | taux | IC 95 % | < 0,05 : k | taux | IC 95 % |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Rapport de vraisemblance : δ = 0 | δ̂* = 1 (π̂* constant) | 995 | 268 | 0,2693 | [0,2420 ; 0,2981] | 127 | 0,1276 | [0,1075 ; 0,1500] |
| Rapport de vraisemblance : δ = 0 | δ̂* = 0 (π̂* variable) | 930 | 0 | 0,0000 | [0,0000 ; 0,0040] | 0 | 0,0000 | [0,0000 ; 0,0040] |
| Rapport de vraisemblance : δ = 0 | δ̂* intérieur (π̂* variable) | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0 | 0,0000 | [0,0000 ; 0,0480] |
| Rapport de vraisemblance : δ = 0 | tous | 2000 | 268 | 0,1340 | [0,1194 ; 0,1497] | 127 | 0,0635 | [0,0532 ; 0,0751] |
| Rapport de vraisemblance : δ = 1 | δ̂* = 1 (π̂* constant) | 995 | 0 | 0,0000 | [0,0000 ; 0,0037] | 0 | 0,0000 | [0,0000 ; 0,0037] |
| Rapport de vraisemblance : δ = 1 | δ̂* = 0 (π̂* variable) | 930 | 180 | 0,1935 | [0,1686 ; 0,2204] | 79 | 0,0849 | [0,0678 ; 0,1047] |
| Rapport de vraisemblance : δ = 1 | δ̂* intérieur (π̂* variable) | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0 | 0,0000 | [0,0000 ; 0,0480] |
| Rapport de vraisemblance : δ = 1 | tous | 2000 | 180 | 0,0900 | [0,0778 ; 0,1034] | 79 | 0,0395 | [0,0314 ; 0,0490] |

Motifs d'absence de p_mc du rapport de vraisemblance : aucun.

Largeur relative de l'IC bootstrap 90 % (contrôle (e4)) : au-dessus de 0,50 dans 981 réplication(s), au-dessus de 0,80 dans 0, sur 2000 où elle est finie.

Bootstrap interne : 0 réplication(s) écartée(s) par usp_bootstrap() sur 1998000 (B = 999 par réplication traitée), dans 0 réplication(s) ; bootstrap restreint (#45) : 0 échec(s) du réajustement contraint ; rapport de vraisemblance : 0 (δ = 0) et 0 (δ = 1) réplication(s) écartée(s) ; rapport de vraisemblance non calculable sur l'observé (réplication traitée, ligne non applicable, #161) : 0 (δ = 0), 0 (δ = 1).

## Jeu J2 : tableaux de #166 sur la même exécution (T1, T1 bis, T2 étendu, T3)

### T1 -- calibration de p_mc : les 31 statistiques de USP_CATALOGUE_MC (p_mc retenue ou non)

| Statistique | Ligne de usp_tests() | Queue | n | < 0,10 : k | taux | IC 95 % | réf. | réf. dans l'IC | bande [réf/2 ; 3réf/2] | < 0,05 : k | taux | IC 95 % | réf. | réf. dans l'IC | bande [réf/2 ; 3réf/2] | p_mc absente |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AD | Anderson-Darling | haut | 2000 | 204 | 0,1020 | [0,0891 ; 0,1161] | 0,1000 | oui | — | 90 | 0,0450 | [0,0363 ; 0,0550] | 0,0500 | oui | — | 0 |
| CvM | Cramer-von Mises | haut | 2000 | 187 | 0,0935 | [0,0811 ; 0,1071] | 0,1000 | oui | — | 94 | 0,0470 | [0,0381 ; 0,0572] | 0,0500 | oui | — | 0 |
| KS | Kolmogorov-Smirnov contre N(0,1) | haut | 2000 | 177 | 0,0885 | [0,0764 ; 0,1018] | 0,1000 | oui | — | 91 | 0,0455 | [0,0368 ; 0,0556] | 0,0500 | oui | — | 0 |
| SW | Shapiro-Wilk sur residus standardises | bas | 2000 | 192 | 0,0960 | [0,0834 ; 0,1098] | 0,1000 | oui | — | 92 | 0,0460 | [0,0372 ; 0,0561] | 0,0500 | oui | — | 0 |
| SF | Shapiro-Francia | bas | 2000 | 185 | 0,0925 | [0,0802 ; 0,1061] | 0,1000 | oui | — | 98 | 0,0490 | [0,0400 ; 0,0594] | 0,0500 | oui | — | 0 |
| JB | Jarque-Bera | haut | 2000 | 204 | 0,1020 | [0,0891 ; 0,1161] | 0,1000 | oui | — | 98 | 0,0490 | [0,0400 ; 0,0594] | 0,0500 | oui | — | 0 |
| DW | Autocorrelation d'ordre 1 (Durbin-Watson) | deux | 2000 | 222 | 0,1110 | [0,0976 ; 0,1256] | 0,1000 | oui | — | 107 | 0,0535 | [0,0440 ; 0,0643] | 0,0500 | oui | — | 0 |
| supF | Rupture de niveau (sup-F) | haut | 2000 | 190 | 0,0950 | [0,0825 ; 0,1087] | 0,1000 | oui | — | 106 | 0,0530 | [0,0436 ; 0,0637] | 0,0500 | oui | — | 0 |
| CUSUM | Stabilite cumulee (OLS-CUSUM) | haut | 2000 | 198 | 0,0990 | [0,0863 ; 0,1129] | 0,1000 | oui | — | 94 | 0,0470 | [0,0381 ; 0,0572] | 0,0500 | oui | — | 0 |
| Grubbs | Valeur aberrante isolee (Grubbs) | haut | 2000 | 200 | 0,1000 | [0,0872 ; 0,1140] | 0,1000 | oui | — | 103 | 0,0515 | [0,0422 ; 0,0621] | 0,0500 | oui | — | 0 |
| Lillie | Lilliefors (KS a parametres estimes) | haut | 2000 | 184 | 0,0920 | [0,0797 ; 0,1055] | 0,1000 | oui | — | 101 | 0,0505 | [0,0413 ; 0,0610] | 0,0500 | oui | — | 0 |
| Intercept | Nullite de la constante (proportionnalite stricte) | deux | 2000 | 190 | 0,0950 | [0,0825 ; 0,1087] | 0,1000 | oui | — | 104 | 0,0520 | [0,0427 ; 0,0627] | 0,0500 | oui | — | 0 |
| RESET | RESET (forme fonctionnelle) | haut | 2000 | 151 | 0,0755 | [0,0643 ; 0,0880] | 0,1000 | **non** | dans | 70 | 0,0350 | [0,0274 ; 0,0440] | 0,0500 | **non** | dans | 0 |
| BP | Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | haut | 2000 | 219 | 0,1095 | [0,0961 ; 0,1240] | 0,1000 | oui | — | 98 | 0,0490 | [0,0400 ; 0,0594] | 0,0500 | oui | — | 0 |
| BP79 | Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | haut | 2000 | 193 | 0,0965 | [0,0839 ; 0,1103] | 0,1000 | oui | — | 97 | 0,0485 | [0,0395 ; 0,0588] | 0,0500 | oui | — | 0 |
| White | Heteroscedasticite (forme quadratique) | haut | 2000 | 178 | 0,0890 | [0,0769 ; 0,1023] | 0,1000 | oui | — | 84 | 0,0420 | [0,0336 ; 0,0517] | 0,0500 | oui | — | 0 |
| GQ | Egalite des variances petits vs gros volumes | deux | 2000 | 158 | 0,0790 | [0,0676 ; 0,0917] | 0,1000 | **non** | dans | 81 | 0,0405 | [0,0323 ; 0,0501] | 0,0500 | oui | — | 0 |
| BF | Homogeneite des dispersions (mediane) | haut | 2000 | 219 | 0,1095 | [0,0961 ; 0,1240] | 0,1000 | oui | — | 113 | 0,0565 | [0,0468 ; 0,0675] | 0,0500 | oui | — | 0 |
| Smirnov | Egalite des lois petits vs gros volumes (2 ech.) | haut | 2000 | 55 | 0,0275 | [0,0208 ; 0,0356] | 0,0286 † | oui | — | 55 | 0,0275 | [0,0208 ; 0,0356] | 0,0286 † | oui | — | 0 |
| LB2 | Ljung-Box (retard 2) | haut | 2000 | 202 | 0,1010 | [0,0881 ; 0,1150] | 0,1000 | oui | — | 101 | 0,0505 | [0,0413 ; 0,0610] | 0,0500 | oui | — | 0 |
| Runs | Test des suites (aleatoire des signes) | deux | 2000 | 127 | 0,0635 | [0,0532 ; 0,0751] | 0,0571 † | oui | — | 13 | 0,0065 | [0,0035 ; 0,0111] | 0,0097 † | oui | — | 0 |
| MK | Tendance monotone du ratio S/P | deux | 2000 | 127 | 0,0635 | [0,0532 ; 0,0751] | 0,0711 † | oui | — | 59 | 0,0295 | [0,0225 ; 0,0379] | 0,0336 † | oui | — | 0 |
| SpearVol | Independance ratio S/P vs volume | deux | 2000 | 195 | 0,0975 | [0,0848 ; 0,1113] | 0,0904 † | oui | — | 103 | 0,0515 | [0,0422 ; 0,0621] | 0,0429 † | oui | — | 0 |
| SpearTps | Correlation ratio S/P vs temps | deux | 2000 | 165 | 0,0825 | [0,0708 ; 0,0954] | 0,0904 † | oui | — | 81 | 0,0405 | [0,0323 ; 0,0501] | 0,0429 † | oui | — | 0 |
| DAgo | Asymetrie (D'Agostino, T >= 8) | deux | 2000 | 197 | 0,0985 | [0,0858 ; 0,1124] | 0,1000 | oui | — | 102 | 0,0510 | [0,0418 ; 0,0616] | 0,0500 | oui | — | 0 |
| CoxStuart | Tendance par signes du ratio S/P | haut | 2000 | 0 | 0,0000 | [0,0000 ; 0,0018] | 0,0006 † | oui | non applicable (réf. < 2/n) | 0 | 0,0000 | [0,0000 ; 0,0018] | 0,0000 † | oui | non applicable (réf. < 2/n) | 0 |
| DWr | Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | deux | 2000 | 200 | 0,1000 | [0,0872 ; 0,1140] | 0,1000 | oui | — | 103 | 0,0515 | [0,0422 ; 0,0621] | 0,0500 | oui | — | 0 |
| Runsr | Test des suites sur ratios bruts | deux | 2000 | 122 | 0,0610 | [0,0509 ; 0,0724] | 0,0571 † | oui | — | 18 | 0,0090 | [0,0053 ; 0,0142] | 0,0097 † | oui | — | 0 |
| supFr | Rupture de niveau (sup-F) sur ratios bruts | haut | 2000 | 209 | 0,1045 | [0,0914 ; 0,1187] | 0,1000 | oui | — | 102 | 0,0510 | [0,0418 ; 0,0616] | 0,0500 | oui | — | 0 |
| CUSUMr | Stabilite cumulee (OLS-CUSUM) sur ratios bruts | haut | 2000 | 198 | 0,0990 | [0,0863 ; 0,1129] | 0,1000 | oui | — | 95 | 0,0475 | [0,0386 ; 0,0578] | 0,0500 | oui | — | 0 |
| Grubbsr | Valeur aberrante isolee (Grubbs) sur ratios bruts | haut | 2000 | 197 | 0,0985 | [0,0858 ; 0,1124] | 0,1000 | oui | — | 97 | 0,0485 | [0,0395 ; 0,0588] | 0,0500 | oui | — | 0 |

n : réplications traitées (2000) où la p_mc est calculée ; p_mc absente : réplications traitées sans p_mc (motif en T3). Statistique continue : référence = seuil ; sous échangeabilité, P(p_mc < seuil) vaut en fait 0,099 et 0,049 en queue simple, 0,098 et 0,048 en bilatéral (B = 999), écart négligeable devant l'IC. † Loi de référence discrète : référence = taille lissée P(p_mc < seuil) sous la loi échangeable à T = 8 sans ex aequo et B = 999 (T0), qui tient compte du bruit Monte-Carlo de la p_mc autour des atomes de la loi.

Multiplicité : T1 compte 62 intervalles (31 statistiques × 2 seuils) ; ici 3 excluent la référence. Sur J1 et J2 réunis, 124 intervalles : environ 6 exclusions (5 % de 124) sont attendues par hasard même si toutes les références sont justes (intervalles corrélés entre eux ; ordre de grandeur, pas un test). T1 bis et T2 ajoutent leurs propres intervalles.

### T1 bis -- calibration de p_mc par régime de δ̂* du réajustement (références de T1)

| Statistique | Régime | n | < 0,10 : k | taux | IC 95 % | réf. dans l'IC | bande [réf/2 ; 3réf/2] | < 0,05 : k | taux | IC 95 % | réf. dans l'IC | bande [réf/2 ; 3réf/2] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AD | δ̂* = 1 (π̂* constant) | 722 | 61 | 0,0845 | [0,0652 ; 0,1072] | oui | — | 27 | 0,0374 | [0,0248 ; 0,0539] | oui | — |
| AD | δ̂* = 0 (π̂* variable) | 814 | 91 | 0,1118 | [0,0910 ; 0,1355] | oui | — | 45 | 0,0553 | [0,0406 ; 0,0733] | oui | — |
| AD | δ̂* intérieur (π̂* variable) | 464 | 52 | 0,1121 | [0,0848 ; 0,1444] | oui | — | 18 | 0,0388 | [0,0232 ; 0,0606] | oui | — |
| CvM | δ̂* = 1 (π̂* constant) | 722 | 60 | 0,0831 | [0,0640 ; 0,1057] | oui | — | 26 | 0,0360 | [0,0237 ; 0,0523] | oui | — |
| CvM | δ̂* = 0 (π̂* variable) | 814 | 77 | 0,0946 | [0,0754 ; 0,1168] | oui | — | 44 | 0,0541 | [0,0395 ; 0,0719] | oui | — |
| CvM | δ̂* intérieur (π̂* variable) | 464 | 50 | 0,1078 | [0,0810 ; 0,1396] | oui | — | 24 | 0,0517 | [0,0334 ; 0,0760] | oui | — |
| KS | δ̂* = 1 (π̂* constant) | 722 | 55 | 0,0762 | [0,0579 ; 0,0980] | **non** | dans | 29 | 0,0402 | [0,0271 ; 0,0572] | oui | — |
| KS | δ̂* = 0 (π̂* variable) | 814 | 77 | 0,0946 | [0,0754 ; 0,1168] | oui | — | 34 | 0,0418 | [0,0291 ; 0,0579] | oui | — |
| KS | δ̂* intérieur (π̂* variable) | 464 | 45 | 0,0970 | [0,0716 ; 0,1276] | oui | — | 28 | 0,0603 | [0,0405 ; 0,0860] | oui | — |
| SW | δ̂* = 1 (π̂* constant) | 722 | 62 | 0,0859 | [0,0665 ; 0,1087] | oui | — | 27 | 0,0374 | [0,0248 ; 0,0539] | oui | — |
| SW | δ̂* = 0 (π̂* variable) | 814 | 84 | 0,1032 | [0,0831 ; 0,1262] | oui | — | 43 | 0,0528 | [0,0385 ; 0,0705] | oui | — |
| SW | δ̂* intérieur (π̂* variable) | 464 | 46 | 0,0991 | [0,0735 ; 0,1300] | oui | — | 22 | 0,0474 | [0,0299 ; 0,0709] | oui | — |
| SF | δ̂* = 1 (π̂* constant) | 722 | 59 | 0,0817 | [0,0628 ; 0,1041] | oui | — | 34 | 0,0471 | [0,0328 ; 0,0652] | oui | — |
| SF | δ̂* = 0 (π̂* variable) | 814 | 86 | 0,1057 | [0,0854 ; 0,1288] | oui | — | 45 | 0,0553 | [0,0406 ; 0,0733] | oui | — |
| SF | δ̂* intérieur (π̂* variable) | 464 | 40 | 0,0862 | [0,0623 ; 0,1155] | oui | — | 19 | 0,0409 | [0,0248 ; 0,0632] | oui | — |
| JB | δ̂* = 1 (π̂* constant) | 722 | 68 | 0,0942 | [0,0739 ; 0,1179] | oui | — | 36 | 0,0499 | [0,0352 ; 0,0684] | oui | — |
| JB | δ̂* = 0 (π̂* variable) | 814 | 89 | 0,1093 | [0,0887 ; 0,1328] | oui | — | 41 | 0,0504 | [0,0364 ; 0,0677] | oui | — |
| JB | δ̂* intérieur (π̂* variable) | 464 | 47 | 0,1013 | [0,0754 ; 0,1324] | oui | — | 21 | 0,0453 | [0,0282 ; 0,0684] | oui | — |
| DW | δ̂* = 1 (π̂* constant) | 722 | 88 | 0,1219 | [0,0989 ; 0,1480] | oui | — | 45 | 0,0623 | [0,0458 ; 0,0825] | oui | — |
| DW | δ̂* = 0 (π̂* variable) | 814 | 87 | 0,1069 | [0,0865 ; 0,1302] | oui | — | 37 | 0,0455 | [0,0322 ; 0,0621] | oui | — |
| DW | δ̂* intérieur (π̂* variable) | 464 | 47 | 0,1013 | [0,0754 ; 0,1324] | oui | — | 25 | 0,0539 | [0,0352 ; 0,0785] | oui | — |
| supF | δ̂* = 1 (π̂* constant) | 722 | 65 | 0,0900 | [0,0702 ; 0,1133] | oui | — | 36 | 0,0499 | [0,0352 ; 0,0684] | oui | — |
| supF | δ̂* = 0 (π̂* variable) | 814 | 92 | 0,1130 | [0,0921 ; 0,1368] | oui | — | 50 | 0,0614 | [0,0459 ; 0,0802] | oui | — |
| supF | δ̂* intérieur (π̂* variable) | 464 | 33 | 0,0711 | [0,0495 ; 0,0984] | **non** | dans | 20 | 0,0431 | [0,0265 ; 0,0658] | oui | — |
| CUSUM | δ̂* = 1 (π̂* constant) | 722 | 74 | 0,1025 | [0,0813 ; 0,1270] | oui | — | 37 | 0,0512 | [0,0363 ; 0,0699] | oui | — |
| CUSUM | δ̂* = 0 (π̂* variable) | 814 | 87 | 0,1069 | [0,0865 ; 0,1302] | oui | — | 40 | 0,0491 | [0,0353 ; 0,0663] | oui | — |
| CUSUM | δ̂* intérieur (π̂* variable) | 464 | 37 | 0,0797 | [0,0568 ; 0,1082] | oui | — | 17 | 0,0366 | [0,0215 ; 0,0580] | oui | — |
| Grubbs | δ̂* = 1 (π̂* constant) | 722 | 70 | 0,0970 | [0,0764 ; 0,1209] | oui | — | 36 | 0,0499 | [0,0352 ; 0,0684] | oui | — |
| Grubbs | δ̂* = 0 (π̂* variable) | 814 | 87 | 0,1069 | [0,0865 ; 0,1302] | oui | — | 44 | 0,0541 | [0,0395 ; 0,0719] | oui | — |
| Grubbs | δ̂* intérieur (π̂* variable) | 464 | 43 | 0,0927 | [0,0679 ; 0,1228] | oui | — | 23 | 0,0496 | [0,0317 ; 0,0735] | oui | — |
| Lillie | δ̂* = 1 (π̂* constant) | 722 | 62 | 0,0859 | [0,0665 ; 0,1087] | oui | — | 32 | 0,0443 | [0,0305 ; 0,0620] | oui | — |
| Lillie | δ̂* = 0 (π̂* variable) | 814 | 83 | 0,1020 | [0,0820 ; 0,1248] | oui | — | 48 | 0,0590 | [0,0438 ; 0,0774] | oui | — |
| Lillie | δ̂* intérieur (π̂* variable) | 464 | 39 | 0,0841 | [0,0605 ; 0,1131] | oui | — | 21 | 0,0453 | [0,0282 ; 0,0684] | oui | — |
| Intercept | δ̂* = 1 (π̂* constant) | 722 | 63 | 0,0873 | [0,0677 ; 0,1103] | oui | — | 32 | 0,0443 | [0,0305 ; 0,0620] | oui | — |
| Intercept | δ̂* = 0 (π̂* variable) | 814 | 80 | 0,0983 | [0,0787 ; 0,1208] | oui | — | 41 | 0,0504 | [0,0364 ; 0,0677] | oui | — |
| Intercept | δ̂* intérieur (π̂* variable) | 464 | 47 | 0,1013 | [0,0754 ; 0,1324] | oui | — | 31 | 0,0668 | [0,0458 ; 0,0935] | oui | — |
| RESET | δ̂* = 1 (π̂* constant) | 722 | 90 | 0,1247 | [0,1014 ; 0,1510] | **non** | dans | 43 | 0,0596 | [0,0434 ; 0,0794] | oui | — |
| RESET | δ̂* = 0 (π̂* variable) | 814 | 23 | 0,0283 | [0,0180 ; 0,0421] | **non** | IC entièrement hors | 9 | 0,0111 | [0,0051 ; 0,0209] | **non** | IC entièrement hors |
| RESET | δ̂* intérieur (π̂* variable) | 464 | 38 | 0,0819 | [0,0586 ; 0,1107] | oui | — | 18 | 0,0388 | [0,0232 ; 0,0606] | oui | — |
| BP | δ̂* = 1 (π̂* constant) | 722 | 87 | 0,1205 | [0,0976 ; 0,1465] | oui | — | 37 | 0,0512 | [0,0363 ; 0,0699] | oui | — |
| BP | δ̂* = 0 (π̂* variable) | 814 | 83 | 0,1020 | [0,0820 ; 0,1248] | oui | — | 37 | 0,0455 | [0,0322 ; 0,0621] | oui | — |
| BP | δ̂* intérieur (π̂* variable) | 464 | 49 | 0,1056 | [0,0792 ; 0,1372] | oui | — | 24 | 0,0517 | [0,0334 ; 0,0760] | oui | — |
| BP79 | δ̂* = 1 (π̂* constant) | 722 | 83 | 0,1150 | [0,0926 ; 0,1405] | oui | — | 44 | 0,0609 | [0,0446 ; 0,0810] | oui | — |
| BP79 | δ̂* = 0 (π̂* variable) | 814 | 68 | 0,0835 | [0,0655 ; 0,1047] | oui | — | 29 | 0,0356 | [0,0240 ; 0,0508] | oui | — |
| BP79 | δ̂* intérieur (π̂* variable) | 464 | 42 | 0,0905 | [0,0660 ; 0,1204] | oui | — | 24 | 0,0517 | [0,0334 ; 0,0760] | oui | — |
| White | δ̂* = 1 (π̂* constant) | 722 | 85 | 0,1177 | [0,0951 ; 0,1435] | oui | — | 46 | 0,0637 | [0,0470 ; 0,0841] | oui | — |
| White | δ̂* = 0 (π̂* variable) | 814 | 42 | 0,0516 | [0,0374 ; 0,0691] | **non** | dans | 16 | 0,0197 | [0,0113 ; 0,0317] | **non** | estimation hors |
| White | δ̂* intérieur (π̂* variable) | 464 | 51 | 0,1099 | [0,0829 ; 0,1420] | oui | — | 22 | 0,0474 | [0,0299 ; 0,0709] | oui | — |
| GQ | δ̂* = 1 (π̂* constant) | 722 | 52 | 0,0720 | [0,0543 ; 0,0934] | **non** | dans | 29 | 0,0402 | [0,0271 ; 0,0572] | oui | — |
| GQ | δ̂* = 0 (π̂* variable) | 814 | 56 | 0,0688 | [0,0524 ; 0,0884] | **non** | dans | 29 | 0,0356 | [0,0240 ; 0,0508] | oui | — |
| GQ | δ̂* intérieur (π̂* variable) | 464 | 50 | 0,1078 | [0,0810 ; 0,1396] | oui | — | 23 | 0,0496 | [0,0317 ; 0,0735] | oui | — |
| BF | δ̂* = 1 (π̂* constant) | 722 | 79 | 0,1094 | [0,0876 ; 0,1345] | oui | — | 38 | 0,0526 | [0,0375 ; 0,0715] | oui | — |
| BF | δ̂* = 0 (π̂* variable) | 814 | 85 | 0,1044 | [0,0843 ; 0,1275] | oui | — | 48 | 0,0590 | [0,0438 ; 0,0774] | oui | — |
| BF | δ̂* intérieur (π̂* variable) | 464 | 55 | 0,1185 | [0,0906 ; 0,1515] | oui | — | 27 | 0,0582 | [0,0387 ; 0,0835] | oui | — |
| Smirnov | δ̂* = 1 (π̂* constant) | 722 | 18 | 0,0249 | [0,0148 ; 0,0391] | oui | — | 18 | 0,0249 | [0,0148 ; 0,0391] | oui | — |
| Smirnov | δ̂* = 0 (π̂* variable) | 814 | 31 | 0,0381 | [0,0260 ; 0,0536] | oui | — | 31 | 0,0381 | [0,0260 ; 0,0536] | oui | — |
| Smirnov | δ̂* intérieur (π̂* variable) | 464 | 6 | 0,0129 | [0,0048 ; 0,0279] | **non** | estimation hors | 6 | 0,0129 | [0,0048 ; 0,0279] | **non** | estimation hors |
| LB2 | δ̂* = 1 (π̂* constant) | 722 | 90 | 0,1247 | [0,1014 ; 0,1510] | **non** | dans | 47 | 0,0651 | [0,0482 ; 0,0856] | oui | — |
| LB2 | δ̂* = 0 (π̂* variable) | 814 | 66 | 0,0811 | [0,0633 ; 0,1020] | oui | — | 28 | 0,0344 | [0,0230 ; 0,0493] | **non** | dans |
| LB2 | δ̂* intérieur (π̂* variable) | 464 | 46 | 0,0991 | [0,0735 ; 0,1300] | oui | — | 26 | 0,0560 | [0,0369 ; 0,0810] | oui | — |
| Runs | δ̂* = 1 (π̂* constant) | 722 | 43 | 0,0596 | [0,0434 ; 0,0794] | oui | — | 4 | 0,0055 | [0,0015 ; 0,0141] | oui | — |
| Runs | δ̂* = 0 (π̂* variable) | 814 | 57 | 0,0700 | [0,0535 ; 0,0898] | oui | — | 7 | 0,0086 | [0,0035 ; 0,0176] | oui | — |
| Runs | δ̂* intérieur (π̂* variable) | 464 | 27 | 0,0582 | [0,0387 ; 0,0835] | oui | — | 2 | 0,0043 | [0,0005 ; 0,0155] | oui | — |
| MK | δ̂* = 1 (π̂* constant) | 722 | 22 | 0,0305 | [0,0192 ; 0,0458] | **non** | estimation hors | 4 | 0,0055 | [0,0015 ; 0,0141] | **non** | IC entièrement hors |
| MK | δ̂* = 0 (π̂* variable) | 814 | 78 | 0,0958 | [0,0765 ; 0,1181] | **non** | dans | 42 | 0,0516 | [0,0374 ; 0,0691] | **non** | estimation hors |
| MK | δ̂* intérieur (π̂* variable) | 464 | 27 | 0,0582 | [0,0387 ; 0,0835] | oui | — | 13 | 0,0280 | [0,0150 ; 0,0474] | oui | — |
| SpearVol | δ̂* = 1 (π̂* constant) | 722 | 67 | 0,0928 | [0,0726 ; 0,1164] | oui | — | 36 | 0,0499 | [0,0352 ; 0,0684] | oui | — |
| SpearVol | δ̂* = 0 (π̂* variable) | 814 | 77 | 0,0946 | [0,0754 ; 0,1168] | oui | — | 36 | 0,0442 | [0,0312 ; 0,0607] | oui | — |
| SpearVol | δ̂* intérieur (π̂* variable) | 464 | 51 | 0,1099 | [0,0829 ; 0,1420] | oui | — | 31 | 0,0668 | [0,0458 ; 0,0935] | **non** | estimation hors |
| SpearTps | δ̂* = 1 (π̂* constant) | 722 | 44 | 0,0609 | [0,0446 ; 0,0810] | **non** | dans | 16 | 0,0222 | [0,0127 ; 0,0357] | **non** | dans |
| SpearTps | δ̂* = 0 (π̂* variable) | 814 | 95 | 0,1167 | [0,0955 ; 0,1408] | **non** | dans | 51 | 0,0627 | [0,0470 ; 0,0816] | **non** | dans |
| SpearTps | δ̂* intérieur (π̂* variable) | 464 | 26 | 0,0560 | [0,0369 ; 0,0810] | **non** | dans | 14 | 0,0302 | [0,0166 ; 0,0501] | oui | — |
| DAgo | δ̂* = 1 (π̂* constant) | 722 | 67 | 0,0928 | [0,0726 ; 0,1164] | oui | — | 36 | 0,0499 | [0,0352 ; 0,0684] | oui | — |
| DAgo | δ̂* = 0 (π̂* variable) | 814 | 87 | 0,1069 | [0,0865 ; 0,1302] | oui | — | 42 | 0,0516 | [0,0374 ; 0,0691] | oui | — |
| DAgo | δ̂* intérieur (π̂* variable) | 464 | 43 | 0,0927 | [0,0679 ; 0,1228] | oui | — | 24 | 0,0517 | [0,0334 ; 0,0760] | oui | — |
| CoxStuart | δ̂* = 1 (π̂* constant) | 722 | 0 | 0,0000 | [0,0000 ; 0,0051] | oui | non applicable (réf. < 2/n) | 0 | 0,0000 | [0,0000 ; 0,0051] | oui | non applicable (réf. < 2/n) |
| CoxStuart | δ̂* = 0 (π̂* variable) | 814 | 0 | 0,0000 | [0,0000 ; 0,0045] | oui | non applicable (réf. < 2/n) | 0 | 0,0000 | [0,0000 ; 0,0045] | oui | non applicable (réf. < 2/n) |
| CoxStuart | δ̂* intérieur (π̂* variable) | 464 | 0 | 0,0000 | [0,0000 ; 0,0079] | oui | non applicable (réf. < 2/n) | 0 | 0,0000 | [0,0000 ; 0,0079] | oui | non applicable (réf. < 2/n) |
| DWr | δ̂* = 1 (π̂* constant) | 722 | 83 | 0,1150 | [0,0926 ; 0,1405] | oui | — | 41 | 0,0568 | [0,0411 ; 0,0763] | oui | — |
| DWr | δ̂* = 0 (π̂* variable) | 814 | 75 | 0,0921 | [0,0732 ; 0,1141] | oui | — | 39 | 0,0479 | [0,0343 ; 0,0649] | oui | — |
| DWr | δ̂* intérieur (π̂* variable) | 464 | 42 | 0,0905 | [0,0660 ; 0,1204] | oui | — | 23 | 0,0496 | [0,0317 ; 0,0735] | oui | — |
| Runsr | δ̂* = 1 (π̂* constant) | 722 | 43 | 0,0596 | [0,0434 ; 0,0794] | oui | — | 5 | 0,0069 | [0,0023 ; 0,0161] | oui | — |
| Runsr | δ̂* = 0 (π̂* variable) | 814 | 51 | 0,0627 | [0,0470 ; 0,0816] | oui | — | 11 | 0,0135 | [0,0068 ; 0,0241] | oui | — |
| Runsr | δ̂* intérieur (π̂* variable) | 464 | 28 | 0,0603 | [0,0405 ; 0,0860] | oui | — | 2 | 0,0043 | [0,0005 ; 0,0155] | oui | — |
| supFr | δ̂* = 1 (π̂* constant) | 722 | 60 | 0,0831 | [0,0640 ; 0,1057] | oui | — | 31 | 0,0429 | [0,0294 ; 0,0604] | oui | — |
| supFr | δ̂* = 0 (π̂* variable) | 814 | 107 | 0,1314 | [0,1090 ; 0,1566] | **non** | dans | 53 | 0,0651 | [0,0491 ; 0,0843] | oui | — |
| supFr | δ̂* intérieur (π̂* variable) | 464 | 42 | 0,0905 | [0,0660 ; 0,1204] | oui | — | 18 | 0,0388 | [0,0232 ; 0,0606] | oui | — |
| CUSUMr | δ̂* = 1 (π̂* constant) | 722 | 72 | 0,0997 | [0,0788 ; 0,1239] | oui | — | 37 | 0,0512 | [0,0363 ; 0,0699] | oui | — |
| CUSUMr | δ̂* = 0 (π̂* variable) | 814 | 85 | 0,1044 | [0,0843 ; 0,1275] | oui | — | 43 | 0,0528 | [0,0385 ; 0,0705] | oui | — |
| CUSUMr | δ̂* intérieur (π̂* variable) | 464 | 41 | 0,0884 | [0,0642 ; 0,1180] | oui | — | 15 | 0,0323 | [0,0182 ; 0,0528] | oui | — |
| Grubbsr | δ̂* = 1 (π̂* constant) | 722 | 64 | 0,0886 | [0,0689 ; 0,1118] | oui | — | 25 | 0,0346 | [0,0225 ; 0,0507] | oui | — |
| Grubbsr | δ̂* = 0 (π̂* variable) | 814 | 90 | 0,1106 | [0,0898 ; 0,1341] | oui | — | 50 | 0,0614 | [0,0459 ; 0,0802] | oui | — |
| Grubbsr | δ̂* intérieur (π̂* variable) | 464 | 43 | 0,0927 | [0,0679 ; 0,1228] | oui | — | 22 | 0,0474 | [0,0299 ; 0,0709] | oui | — |

Régime du réajustement de run_engine() sur le jeu simulé (seuils TOL_DELTA_BORD de #72) ; effectifs en T3. Volumes non constants (contrôlé) : π̂* constant si et seulement si δ̂* au bord 1. Règle R7 : à π̂* constant, les lignes à loi exacte retiennent la p exacte ; ailleurs, la p_mc. Les taux par régime sont conditionnels à un événement fonction des données et n'ont pas de référence exacte même pour une p_mc parfaitement calibrée : T1 bis localise un écart, il ne teste pas la calibration par régime.

### T2 -- niveau des verdicts des 47 lignes (puis des lignes de lecture conjointe, #297) : fréquence de p retenue < α et < α/2 parmi les p retenues (règles R1, R3, R4, R7, R13 comprises)

| Ligne | n | p retenue | < 0,10 : k | taux | IC 95 % | réf. | réf. dans l'IC | bande [réf/2 ; 3réf/2] | < 0,05 : k | taux | IC 95 % | réf. | réf. dans l'IC | bande [réf/2 ; 3réf/2] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Nullite de la constante (proportionnalite stricte) | 2000 | 2000 | 190 | 0,0950 | [0,0825 ; 0,1087] | 0,1000 | oui | — | 104 | 0,0520 | [0,0427 ; 0,0627] | 0,0500 | oui | — |
| Equivalence de la constante a zero (TOST) | 2000 | 1814 | 873 | 0,4813 | [0,4580 ; 0,5045] | sans objet (H0 \|a\| ≥ Δ fausse sous le modèle ajusté, a = 0 ; sens « rejeter ») | — | — | 399 | 0,2200 | [0,2011 ; 0,2397] | sans objet (H0 \|a\| ≥ Δ fausse sous le modèle ajusté, a = 0 ; sens « rejeter ») | — | — |
| Test de Pitman sur la pente (lien positif pertes / volume) | 2000 | 2000 | 2000 | 1,0000 | [0,9982 ; 1,0000] | sans objet (H0 d'échangeabilité, y indépendant de x, fausse sous le modèle réglementaire à volumes variables ; sens « rejeter ») | — | — | 2000 | 1,0000 | [0,9982 ; 1,0000] | sans objet (H0 d'échangeabilité, y indépendant de x, fausse sous le modèle réglementaire à volumes variables ; sens « rejeter ») | — | — |
| Test de Fisher (significativite globale) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Coefficient de determination R2 | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| RESET (forme fonctionnelle) | 2000 | 2000 | 151 | 0,0755 | [0,0643 ; 0,0880] | 0,1000 | **non** | dans | 70 | 0,0350 | [0,0274 ; 0,0440] | 0,0500 | **non** | dans |
| Independance ratio S/P vs volume | 2000 | 2000 | 202 | 0,1010 | [0,0881 ; 0,1150] | 0,0925 † | oui | — | 101 | 0,0505 | [0,0413 ; 0,0610] | 0,0440 † | oui | — |
| Correlation ratio S/P vs temps | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Tendance monotone du ratio S/P | 2000 | 2000 | 121 | 0,0605 | [0,0505 ; 0,0719] | 0,0674 † | oui | — | 59 | 0,0295 | [0,0225 ; 0,0379] | 0,0327 † | oui | — |
| Tendance par signes du ratio S/P | 2000 | 3 | 0 | 0,0000 | [0,0000 ; 0,7076] | 0,0006 † | oui | non applicable (réf. < 2/n) | 0 | 0,0000 | [0,0000 ; 0,7076] | 0,0000 † | oui | non applicable (réf. < 2/n) |
| Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | 2000 | 2000 | 219 | 0,1095 | [0,0961 ; 0,1240] | 0,1000 | oui | — | 98 | 0,0490 | [0,0400 ; 0,0594] | 0,0500 | oui | — |
| Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Heteroscedasticite (forme quadratique) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Egalite des variances petits vs gros volumes | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Homogeneite des dispersions (mediane) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Egalite des lois petits vs gros volumes (2 ech.) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Position de delta dans [0,1] | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Shapiro-Wilk sur residus standardises | 2000 | 2000 | 192 | 0,0960 | [0,0834 ; 0,1098] | 0,1000 | oui | — | 92 | 0,0460 | [0,0372 ; 0,0561] | 0,0500 | oui | — |
| Shapiro-Francia | 2000 | 2000 | 185 | 0,0925 | [0,0802 ; 0,1061] | 0,1000 | oui | — | 98 | 0,0490 | [0,0400 ; 0,0594] | 0,0500 | oui | — |
| Anderson-Darling | 2000 | 2000 | 204 | 0,1020 | [0,0891 ; 0,1161] | 0,1000 | oui | — | 90 | 0,0450 | [0,0363 ; 0,0550] | 0,0500 | oui | — |
| Cramer-von Mises | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Kolmogorov-Smirnov contre N(0,1) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Lilliefors (KS a parametres estimes) | 2000 | 2000 | 184 | 0,0920 | [0,0797 ; 0,1055] | 0,1000 | oui | — | 101 | 0,0505 | [0,0413 ; 0,0610] | 0,0500 | oui | — |
| Jarque-Bera | 2000 | 2000 | 204 | 0,1020 | [0,0891 ; 0,1161] | 0,1000 | oui | — | 98 | 0,0490 | [0,0400 ; 0,0594] | 0,0500 | oui | — |
| Asymetrie (D'Agostino, T >= 8) | 2000 | 2000 | 197 | 0,0985 | [0,0858 ; 0,1124] | 0,1000 | oui | — | 102 | 0,0510 | [0,0418 ; 0,0616] | 0,0500 | oui | — |
| Aplatissement (Anscombe-Glynn, T >= 20) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Autocorrelation d'ordre 1 (Durbin-Watson) | 2000 | 2000 | 228 | 0,1140 | [0,1004 ; 0,1287] | 0,1000 | **non** | dans | 109 | 0,0545 | [0,0450 ; 0,0654] | 0,0500 | oui | — |
| Ljung-Box (retard 2) | 2000 | 2000 | 202 | 0,1010 | [0,0881 ; 0,1150] | 0,1000 | oui | — | 101 | 0,0505 | [0,0413 ; 0,0610] | 0,0500 | oui | — |
| Test des suites (aleatoire des signes) | 2000 | 2000 | 127 | 0,0635 | [0,0532 ; 0,0751] | 0,0571 † | oui | — | 9 | 0,0045 | [0,0021 ; 0,0085] | 0,0062 † | oui | — |
| Centrage des residus standardises | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Variance unitaire des residus standardises | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Rupture de niveau (sup-F) | 2000 | 2000 | 190 | 0,0950 | [0,0825 ; 0,1087] | 0,1000 | oui | — | 106 | 0,0530 | [0,0436 ; 0,0637] | 0,0500 | oui | — |
| Stabilite cumulee (OLS-CUSUM) | 2000 | 2000 | 198 | 0,0990 | [0,0863 ; 0,1129] | 0,1000 | oui | — | 94 | 0,0470 | [0,0381 ; 0,0572] | 0,0500 | oui | — |
| Valeur aberrante isolee (Grubbs) | 2000 | 2000 | 200 | 0,1000 | [0,0872 ; 0,1140] | 0,1000 | oui | — | 103 | 0,0515 | [0,0422 ; 0,0621] | 0,0500 | oui | — |
| Valeurs aberrantes multiples (ESD generalise) | 2000 | diagnostic par decision (#304) : frequence de k̂ >= 1 | 222 | 0,1110 | [0,0976 ; 0,1256] | 0,1000 ‡ | oui | — | 99 | 0,0495 | [0,0404 ; 0,0599] | — | — | — |
| Points influents (distance de Cook) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | 2000 | 1278 | 117 | 0,0915 | [0,0763 ; 0,1087] | 0,1000 | oui | — | 62 | 0,0485 | [0,0374 ; 0,0618] | 0,0500 | oui | — |
| Test des suites sur ratios bruts | 2000 | 1278 | 79 | 0,0618 | [0,0492 ; 0,0764] | 0,0571 † | oui | — | 13 | 0,0102 | [0,0054 ; 0,0173] | 0,0097 † | oui | — |
| Rupture de niveau (sup-F) sur ratios bruts | 2000 | 1278 | 149 | 0,1166 | [0,0995 ; 0,1355] | 0,1000 | oui | — | 71 | 0,0556 | [0,0436 ; 0,0696] | 0,0500 | oui | — |
| Stabilite cumulee (OLS-CUSUM) sur ratios bruts | 2000 | 1278 | 126 | 0,0986 | [0,0828 ; 0,1163] | 0,1000 | oui | — | 58 | 0,0454 | [0,0346 ; 0,0583] | 0,0500 | oui | — |
| Valeur aberrante isolee (Grubbs) sur ratios bruts | 2000 | 1278 | 133 | 0,1041 | [0,0879 ; 0,1221] | 0,1000 | oui | — | 72 | 0,0563 | [0,0443 ; 0,0704] | 0,0500 | oui | — |
| Leviers (hat values) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Sensibilite au retrait d'une annee (jackknife) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Largeur relative de l'IC bootstrap 90% | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Rapport de vraisemblance : delta = 0 (variance lineaire en volume) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| Rapport de vraisemblance : delta = 1 (variance quadratique en volume) | 2000 | 0 | 0 | — | — | sans objet (aucune p retenue) | — | — | 0 | — | — | sans objet (aucune p retenue) | — | — |
| p de famille (minP, lecture conjointe) [B.] | 2000 | 0 | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — |
| p de famille (minP, lecture conjointe) [C.] | 0 | 0 | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — |
| p de famille (minP, lecture conjointe) [D.] | 2000 | 0 | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — |
| p de famille (minP, lecture conjointe) [E.] | 2000 | 0 | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — |
| p de famille (minP, lecture conjointe) [F.] | 2000 | 0 | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — |
| p de famille (minP, lecture conjointe) [G.] | 0 | 0 | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — |
| p globale (minP, lecture conjointe de la batterie) [LC] | 2000 | 0 | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — | 0 | — | — | sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1) | — | — |

n : réplications traitées ; p retenue : réplications où la ligne a une p retenue. Taux = rejets / p retenues (niveau conditionnel à l'existence d'une p retenue) ; la fréquence inconditionnelle du verdict, rejets / n, se lit dans T2 (suite), colonnes ALERTE et ECHEC. Sens « ne pas rejeter » : p < α donne ALERTE ou ECHEC, p < α/2 ECHEC. Pour les deux lignes en sens « rejeter » (pente, TOST), p < α est un OK : les colonnes donnent une puissance conditionnelle, sans référence.

† Loi de référence discrète : référence = (n_exacte × taille atteignable + n_MC × taille lissée) / (n_exacte + n_MC), sur les natures de la p retenue comptées en T2 (suite) ; référence **approchée** : elle suppose l'échangeabilité et ignore la sélection par le régime (à π̂* variable, la p retenue de ces lignes est la p_mc, règle R7, dont le niveau n'est qu'approché par la taille lissée). Une p retenue d'une autre nature (repli asymptotique nommé, règle R3 ; attendu 0 à T = 8 sans ex æquo) compte dans np et dans les rejets, non dans la référence, alors suivie de « (n hors réf. = k) ».

‡ Ligne ESD (diagnostic par décision depuis #304, sans p-value ni verdict) : première colonne, k̂ ≥ 1 (colonne estimation), mesure P(k̂ ≥ 1), sur les réplications traitées, contre 0,10, niveau nominal de la procédure de Rosner, valeurs critiques à 1 − α/(2 n_i) ; exactitude non établie à T = 8 ni sur z = Pε. Seconde colonne : k̂ = 2, mesure P(k̂ = 2), sans niveau nominal.

### T2 (suite) -- composition des lignes : types, nature de la p retenue, verdicts

| Ligne | n | test | diagnostic | dont inopérant (R1) | non applicable | procédure de décision | p exacte | p Monte-Carlo | p asymptotique | autre p | aucune p | OK | ALERTE | ECHEC | INFO |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Nullite de la constante (proportionnalite stricte) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1810 | 86 | 104 | 0 |
| Equivalence de la constante a zero (TOST) | 2000 | 1814 | 186 | 0 | 0 | 0 | 0 | 0 | 0 | 1814 | 186 | 873 | 688 | 253 | 186 |
| Test de Pitman sur la pente (lien positif pertes / volume) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 2000 | 0 | 0 | 0 |
| Test de Fisher (significativite globale) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Coefficient de determination R2 | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| RESET (forme fonctionnelle) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1849 | 81 | 70 | 0 |
| Independance ratio S/P vs volume | 2000 | 2000 | 0 | 0 | 0 | 0 | 722 | 1278 | 0 | 0 | 0 | 1798 | 101 | 101 | 0 |
| Correlation ratio S/P vs temps | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Tendance monotone du ratio S/P | 2000 | 2000 | 0 | 0 | 0 | 0 | 722 | 1278 | 0 | 0 | 0 | 1879 | 62 | 59 | 0 |
| Tendance par signes du ratio S/P | 2000 | 3 | 1997 | 1997 | 0 | 0 | 0 | 3 | 0 | 0 | 1997 | 3 | 0 | 0 | 1997 |
| Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1781 | 121 | 98 | 0 |
| Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Heteroscedasticite (forme quadratique) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Egalite des variances petits vs gros volumes | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Homogeneite des dispersions (mediane) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Egalite des lois petits vs gros volumes (2 ech.) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Position de delta dans [0,1] | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Shapiro-Wilk sur residus standardises | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1808 | 100 | 92 | 0 |
| Shapiro-Francia | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1815 | 87 | 98 | 0 |
| Anderson-Darling | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1796 | 114 | 90 | 0 |
| Cramer-von Mises | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Kolmogorov-Smirnov contre N(0,1) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Lilliefors (KS a parametres estimes) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1816 | 83 | 101 | 0 |
| Jarque-Bera | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1796 | 106 | 98 | 0 |
| Asymetrie (D'Agostino, T >= 8) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1803 | 95 | 102 | 0 |
| Aplatissement (Anscombe-Glynn, T >= 20) | 2000 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Autocorrelation d'ordre 1 (Durbin-Watson) | 2000 | 2000 | 0 | 0 | 0 | 0 | 722 | 1278 | 0 | 0 | 0 | 1772 | 119 | 109 | 0 |
| Ljung-Box (retard 2) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1798 | 101 | 101 | 0 |
| Test des suites (aleatoire des signes) | 2000 | 2000 | 0 | 0 | 0 | 0 | 722 | 1278 | 0 | 0 | 0 | 1873 | 118 | 9 | 0 |
| Centrage des residus standardises | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Variance unitaire des residus standardises | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Rupture de niveau (sup-F) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1810 | 84 | 106 | 0 |
| Stabilite cumulee (OLS-CUSUM) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1802 | 104 | 94 | 0 |
| Valeur aberrante isolee (Grubbs) | 2000 | 2000 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 1800 | 97 | 103 | 0 |
| Valeurs aberrantes multiples (ESD generalise) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Points influents (distance de Cook) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | 2000 | 1278 | 722 | 0 | 0 | 0 | 0 | 1278 | 0 | 0 | 722 | 1161 | 55 | 62 | 722 |
| Test des suites sur ratios bruts | 2000 | 1278 | 722 | 0 | 0 | 0 | 0 | 1278 | 0 | 0 | 722 | 1199 | 66 | 13 | 722 |
| Rupture de niveau (sup-F) sur ratios bruts | 2000 | 1278 | 722 | 0 | 0 | 0 | 0 | 1278 | 0 | 0 | 722 | 1129 | 78 | 71 | 722 |
| Stabilite cumulee (OLS-CUSUM) sur ratios bruts | 2000 | 1278 | 722 | 0 | 0 | 0 | 0 | 1278 | 0 | 0 | 722 | 1152 | 68 | 58 | 722 |
| Valeur aberrante isolee (Grubbs) sur ratios bruts | 2000 | 1278 | 722 | 0 | 0 | 0 | 0 | 1278 | 0 | 0 | 722 | 1145 | 61 | 72 | 722 |
| Leviers (hat values) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Sensibilite au retrait d'une annee (jackknife) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Largeur relative de l'IC bootstrap 90% | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Rapport de vraisemblance : delta = 0 (variance lineaire en volume) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| Rapport de vraisemblance : delta = 1 (variance quadratique en volume) | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| p de famille (minP, lecture conjointe) [B.] | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| p de famille (minP, lecture conjointe) [C.] | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| p de famille (minP, lecture conjointe) [D.] | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| p de famille (minP, lecture conjointe) [E.] | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| p de famille (minP, lecture conjointe) [F.] | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |
| p de famille (minP, lecture conjointe) [G.] | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| p globale (minP, lecture conjointe de la batterie) [LC] | 2000 | 0 | 2000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2000 | 0 | 0 | 0 | 2000 |

Nature : champ nature_p de la ligne (exacte ; Monte-Carlo ; asymptotique, repli nommé compris ; autre : p sous le modèle auxiliaire pondéré du TOST, exacte par permutation de Pitman sur la pente). Inopérant : détail préfixé « TEST INOPERANT » (règle R1), compté aussi en diagnostic.

### T3 -- régimes, réplications écartées, motifs, contrôles de la famille H, rapport de vraisemblance, IC bootstrap

Régimes de δ̂* :

| Régime | run_engine() (réplications traitées) | code de #72 : usp_ajuster(x, y*) (toutes) |
| --- | --- | --- |
| δ̂* = 1 (π̂* constant) | 722 | 722 |
| δ̂* = 0 (π̂* variable) | 814 | 814 |
| δ̂* intérieur (π̂* variable) | 464 | 464 |
| usp_ajuster() en erreur | 0 | 0 |
| Total | 2000 | 2000 |

Réplications écartées (erreur de run_engine() ou ok = FALSE) : 0 sur 2000.

Motifs d'absence de p_mc (motif_mc, réplications traitées) :

aucun.

Contrôles numériques de la famille H (res$controles, verdicts) :

| Contrôle | OK | ALERTE | ECHEC | autre |
| --- | --- | --- | --- | --- |
| Condition du premier ordre (gradient projete, KKT) | 2000 | 0 | 0 | 0 |
| Convergence multi-demarrages | 2000 | 0 | 0 | 0 |

p_mc des deux lignes du rapport de vraisemblance (#45 ; hors objet de T1 et T2, sans référence) :

| Ligne | Régime de δ̂* | n | < 0,10 : k | taux | IC 95 % | < 0,05 : k | taux | IC 95 % |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Rapport de vraisemblance : δ = 0 | δ̂* = 1 (π̂* constant) | 722 | 420 | 0,5817 | [0,5448 ; 0,6180] | 248 | 0,3435 | [0,3089 ; 0,3794] |
| Rapport de vraisemblance : δ = 0 | δ̂* = 0 (π̂* variable) | 814 | 0 | 0,0000 | [0,0000 ; 0,0045] | 0 | 0,0000 | [0,0000 ; 0,0045] |
| Rapport de vraisemblance : δ = 0 | δ̂* intérieur (π̂* variable) | 464 | 24 | 0,0517 | [0,0334 ; 0,0760] | 4 | 0,0086 | [0,0024 ; 0,0219] |
| Rapport de vraisemblance : δ = 0 | tous | 2000 | 444 | 0,2220 | [0,2040 ; 0,2409] | 252 | 0,1260 | [0,1118 ; 0,1413] |
| Rapport de vraisemblance : δ = 1 | δ̂* = 1 (π̂* constant) | 722 | 0 | 0,0000 | [0,0000 ; 0,0051] | 0 | 0,0000 | [0,0000 ; 0,0051] |
| Rapport de vraisemblance : δ = 1 | δ̂* = 0 (π̂* variable) | 814 | 338 | 0,4152 | [0,3811 ; 0,4500] | 193 | 0,2371 | [0,2083 ; 0,2679] |
| Rapport de vraisemblance : δ = 1 | δ̂* intérieur (π̂* variable) | 464 | 4 | 0,0086 | [0,0024 ; 0,0219] | 0 | 0,0000 | [0,0000 ; 0,0079] |
| Rapport de vraisemblance : δ = 1 | tous | 2000 | 342 | 0,1710 | [0,1547 ; 0,1882] | 193 | 0,0965 | [0,0839 ; 0,1103] |

Motifs d'absence de p_mc du rapport de vraisemblance : aucun.

Largeur relative de l'IC bootstrap 90 % (contrôle (e4)) : au-dessus de 0,50 dans 85 réplication(s), au-dessus de 0,80 dans 0, sur 2000 où elle est finie.

Bootstrap interne : 0 réplication(s) écartée(s) par usp_bootstrap() sur 1998000 (B = 999 par réplication traitée), dans 0 réplication(s) ; bootstrap restreint (#45) : 0 échec(s) du réajustement contraint ; rapport de vraisemblance : 0 (δ = 0) et 0 (δ = 1) réplication(s) écartée(s) ; rapport de vraisemblance non calculable sur l'observé (réplication traitée, ligne non applicable, #161) : 0 (δ = 0), 0 (δ = 1).

### Aide à la lecture (sans conclusion)

Statut : **constat de simulation sous le modèle ajusté au jeu** (usp_simuler(FIT0)), pas un résultat général. Chaque réplication est traitée par run_engine() complet (B = 999) : la mesure porte sur la procédure du dossier (réajustement, bootstrap paramétrique, engine_p_mc(), verdict de add()). Protocole d'actuary (#122, commentaire 5905003573 ; décisions du mainteneur, commentaire 5905011303 ; issue #166).

IC : Clopper-Pearson à 95 %, incertitude Monte-Carlo sur le taux (fonction de R), pas l'erreur d'approximation en T ; l'erreur liée à B fait partie de la procédure mesurée. « oui » dans « réf. dans l'IC » se lit « compatible » au sens de « aucune distorsion détectée à la précision Monte-Carlo », jamais « exact ».

Bande de Bradley (1978), critère libéral [réf/2 ; 3réf/2] : **convention, pas théorème** (J. V. Bradley, « Robustness? », *British Journal of Mathematical and Statistical Psychology* 31(2), 1978, p. 144-152). Le rapport 0,5-1,5 au niveau nominal est la règle de Bradley elle-même à tout seuil : [0,05 ; 0,15] à 0,10, [0,025 ; 0,075] à 0,05. Pour une référence discrète (†), la bande est la transposition en rapport du critère de Bradley à la taille de référence (convention du script). Colonne « bande », écrite seulement si la référence est hors de l'IC : « dans » : estimation dans la bande ; « estimation hors » : estimation hors de la bande, IC la recoupant ; « IC entièrement hors » : IC disjoint de la bande ; « non applicable (réf. < 2/n) » : voir ci-dessous ; « — » : référence dans l'IC, ou pas de référence.

Lecture, par actuary, à partir des colonnes « réf. dans l'IC » et « bande » : (1) l'IC contient la référence : **compatible** (la bande n'est pas écrite) ; (2) sinon, estimation dans la bande : **écart mineur**, consigné en rubrique 7 ; (3) IC disjoint de la bande : **distorsion matérielle**, point de décision du mainteneur ; (4) sinon (estimation hors de la bande, IC la recoupant) : **écart non tranché**, distorsion possible non établie à la précision Monte-Carlo, consigné en rubrique 7 avec l'IC, à éclairer par T1 bis et les valeurs brutes, sans décision déclenchée. Bande non applicable quand la référence est inférieure à 2/n (sa demi-largeur ref/2 est sous la résolution 1/n du taux ; Cox-Stuart) : lecture binaire, compatible ou **écart à examiner** (k et IC cités), sans échelle mineur / matériel ni décision déclenchée ; une référence nulle n'est pas ramenée à une bande {0}.

