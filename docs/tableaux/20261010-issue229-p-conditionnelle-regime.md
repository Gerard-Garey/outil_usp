## Mesure #229 : p-value Monte-Carlo conditionnelle au régime de δ̂, T = 8 -- niveaux (T0 à T3) -- combinaison de 24 tranche(s)

Paramètres : partie=regime;groupe=J1;R=2000;graine_jeux=20260927;graine_boot=20260831+b;graine_v3b=20800000+b;graine_P=20810000+s;B=999;B_cible=999;B_max=25000;methode=premium;segment=1;annexe=II;nature=brutes;alpha=0.1;theta_equiv=0.1 | partie=regime;groupe=J2;R=2000;graine_jeux=20260927;graine_boot=20260831+b;graine_v3b=20800000+b;graine_P=20810000+s;B=999;B_cible=999;B_max=25000;methode=premium;segment=1;annexe=II;nature=brutes;alpha=0.1;theta_equiv=0.1 | partie=regime;groupe=J3;R=2000;graine_jeux=20260927;graine_boot=20260831+b;graine_v3b=20800000+b;graine_P=20810000+s;B=999;B_cible=999;B_max=25000;methode=premium;segment=1;annexe=II;nature=brutes;alpha=0.1;theta_equiv=0.1

### T0 -- provenance (identique dans les tranches de chaque groupe, vérifié)

| Grandeur | Valeur |
| --- | --- |
| Partie | regime |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Commit | fee9968a6cda9f7e7397683b81d01e1648939093 |
| Plateforme de calcul (R, système, machine, BLAS, LAPACK) | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.12.0 ; LAPACK : /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.12.0 (version 3.12.0) |
| Empreintes md5 du code exécuté | R/engine.R 95a48eaf3588a58c507299954597fef1 ; tests/outils_tests.R chargé (dépôt) 30318c792ac0cc633f415154e15c037c ; script exécuté (dépôt) 6c047bafbff524547046fde278bf0d13 ; tests/taux_franchissement_reperes.R 9e46c0ad40949e93d35e0c3e1a30ec57 ; docs/specifications/229-p-conditionnelle-regime.md e4c6e21276b469e4362423083750f686 |
| Empreinte sans commentaires de R/engine.R (#231) et md5 du fichier entier | 46fe1025c2c4a6f241822a89e74b4c06 (md5 du fichier entier 95a48eaf3588a58c507299954597fef1) |
| Tableau de la grille (étape 4) | docs/tableaux/20261010-issue229-grille.md (md5 ba5e29a2aa3d727b4c4ffa61d11de05f, suivi par git : oui ; paramètres de la spécification : oui) |
| Contrôle (a) : J1 observé contre tests/reference/premium.rds | conforme ; 23740 feuille(s), 0 non strictement identique(s), écart maximal 0.000e+00 |
| Configuration | méthode premium, segment 1 de l'annexe II, données brutes, B = 999, B_cible = 999, B_max = 25000, α = 0,10 et 0,05 ; B_MIN_DEGENERESCENCE = 50 ; TOL_DELTA_BORD = 1e-06 ; tolérance (h2) 1e-09 ; (h1) 1e-12 relatif |
| Règle R4 au commit mesuré (C-229-5) | SEUIL_PUISSANCE_PENTE = 0.5, SENS_PITMAN_PENTE = unilateral : ligne du test de Pitman sur la pente restituée en diagnostic si la puissance approchée du test unilatéral sous le modèle ajusté (usp_identifiabilite_pente()) est inférieure au seuil |
| Lignes de T2 (périmètre) | Nullite de la constante (proportionnalite stricte) ; Equivalence de la constante a zero (TOST) ; Test de Pitman sur la pente (lien positif pertes / volume) ; Test de Fisher (significativite globale) ; Coefficient de determination R2 ; RESET (forme fonctionnelle) ; Independance ratio S/P vs volume ; Correlation ratio S/P vs temps ; Tendance monotone du ratio S/P ; Tendance par signes du ratio S/P ; Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) ; Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) ; Heteroscedasticite (forme quadratique) ; Egalite des variances petits vs gros volumes ; Homogeneite des dispersions (mediane) ; Egalite des lois petits vs gros volumes (2 ech.) ; Position de delta dans [0,1] ; Shapiro-Wilk sur residus standardises ; Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston) ; Shapiro-Francia ; Anderson-Darling ; Cramer-von Mises ; Kolmogorov-Smirnov contre N(0,1) ; Lilliefors (KS a parametres estimes) ; Jarque-Bera ; Asymetrie (D'Agostino, T >= 8) ; Aplatissement (Anscombe-Glynn, T >= 20) ; Autocorrelation d'ordre 1 (Durbin-Watson) ; Ljung-Box (retard 1) ; Ljung-Box (retard 2) ; Box-Pierce (retard 2) ; Test des suites (aleatoire des signes) ; Centrage des residus standardises ; Variance unitaire des residus standardises ; Rupture de niveau (sup-F) ; Stabilite cumulee (OLS-CUSUM) ; Valeur aberrante isolee (Grubbs) ; Valeurs aberrantes multiples (ESD generalise) ; Points influents (distance de Cook) ; Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts ; Ljung-Box (retard 1) sur ratios bruts ; Test des suites sur ratios bruts ; Rupture de niveau (sup-F) sur ratios bruts ; Stabilite cumulee (OLS-CUSUM) sur ratios bruts ; Valeur aberrante isolee (Grubbs) sur ratios bruts ; Leviers (hat values) ; Sensibilite au retrait d'une annee (jackknife) ; Largeur relative de l'IC bootstrap 90% |
| Essai (--essai, non versionnable) | non |
| J1 : Jeu ou scénario | J1 : tests/donnees/donnees_ln.csv |
| J1 : Modèle | δ̂ = 1 ; γ̂ = -1.93433 ; β̂ = 0.728685 ; σ̂ = 0.10531 (usp_ajuster()) |
| J1 : Graines | jeux : un flux sous 20260927 (chemin de #72) ; bootstrap de la réplication b : 20260831 + b ; flux de V3b : 20800000 + b ; jeu observé : 20260831 et 20800000 |
| J1 : Graines en collision (déclarées, non bloquantes) | jeux de J1, J2, J3 = bootstrap, réplication 96 ; bootstrap, réplication 70 = SEED_LOI_NULLE_SW |
| J1 : Sources (valeurs brutes de #221 et de #175, tableaux de #221, valeurs brutes de la grille) | docs/tableaux/20261008-issue166-brut-J1.tsv (md5 30d2a3ce0bd258ce8474b8d421281071, suivi par git : oui) ; docs/tableaux/20261008-issue166-calibration-J1.md (md5 69157d32eade77bdad958db0de5d607d, suivi par git : oui) ; docs/tableaux/20261009-issue175-brut.tsv (md5 526435e7522ce2fb34d19e2e4b8fdae4, suivi par git : oui) |
| J1 : Jeux du scénario (L8) | sans objet |
| J1 : Contrôle (i3) | OK : empreinte sans commentaires de R/engine.R 46fe1025c2c4a6f241822a89e74b4c06, (g5) de la grille 46fe1025c2c4a6f241822a89e74b4c06 ; md5 du fichier entier 95a48eaf3588a58c507299954597fef1 ; md5 du moteur du T0 de #221 (pour mémoire, lien par (i1) et (c)) 344a4e03751e97b14e5ca1b733b856c6 |
| J1 : Réplications | 2000 (tranches 1-250, 251-500, 501-750, 751-1000, 1001-1250, 1251-1500, 1501-1750, 1751-2000) |
| J1 : Durée cumulée (s) | contrôles 327 ; total 21749 ; réplications 21408 |
| J2 : Jeu ou scénario | J2 : xi, yi de tests/unitaires/test_controles_numeriques.R |
| J2 : Modèle | δ̂ = 0.663991 ; γ̂ = -2.31999 ; β̂ = 0.701657 ; σ̂ = 0.0689553 (usp_ajuster()) |
| J2 : Graines | jeux : un flux sous 20260927 (chemin de #72) ; bootstrap de la réplication b : 20260831 + b ; flux de V3b : 20800000 + b ; jeu observé : 20260831 et 20800000 |
| J2 : Graines en collision (déclarées, non bloquantes) | jeux de J1, J2, J3 = bootstrap, réplication 96 ; bootstrap, réplication 70 = SEED_LOI_NULLE_SW |
| J2 : Sources (valeurs brutes de #221 et de #175, tableaux de #221, valeurs brutes de la grille) | docs/tableaux/20261008-issue166-brut-J2.tsv (md5 d2f4f06dfe0bfb5c8ecedb6da456a47d, suivi par git : oui) ; docs/tableaux/20261008-issue166-calibration-J2.md (md5 26bb6a08e623fbb8a111ada9202ab10e, suivi par git : oui) ; docs/tableaux/20261009-issue175-brut.tsv (md5 526435e7522ce2fb34d19e2e4b8fdae4, suivi par git : oui) |
| J2 : Jeux du scénario (L8) | sans objet |
| J2 : Contrôle (i3) | OK : empreinte sans commentaires de R/engine.R 46fe1025c2c4a6f241822a89e74b4c06, (g5) de la grille 46fe1025c2c4a6f241822a89e74b4c06 ; md5 du fichier entier 95a48eaf3588a58c507299954597fef1 ; md5 du moteur du T0 de #221 (pour mémoire, lien par (i1) et (c)) 344a4e03751e97b14e5ca1b733b856c6 |
| J2 : Réplications | 2000 (tranches 1-250, 251-500, 501-750, 751-1000, 1001-1250, 1251-1500, 1501-1750, 1751-2000) |
| J2 : Durée cumulée (s) | contrôles 472 ; total 18466 ; réplications 18990 |
| J3 : Jeu ou scénario | J3 : FIT0_J3 synthétique, x3 = (10.0 ; 10.5 ; 95.0 ; 92.0 ; 11.0 ; 11.5 ; 98.0 ; 90.0), δ0 = 0.6, β0 = 0.7, γ0 = ln(σ0 / β0) = -1.945910 (σ0 = 0.1), aucun jeu observé |
| J3 : Modèle | δ = 0.6 ; γ = -1.945910 ; β = 0.7 (synthétique) |
| J3 : Graines | jeux : un flux sous 20260927 (chemin de #72) ; bootstrap de la réplication b : 20260831 + b ; flux de V3b : 20800000 + b |
| J3 : Graines en collision (déclarées, non bloquantes) | jeux de J1, J2, J3 = bootstrap, réplication 96 ; bootstrap, réplication 70 = SEED_LOI_NULLE_SW |
| J3 : Sources (valeurs brutes de #221 et de #175, tableaux de #221, valeurs brutes de la grille) | docs/tableaux/20261008-issue166-calibration-J2.md (md5 26bb6a08e623fbb8a111ada9202ab10e, suivi par git : oui) ; valeurs brutes de la grille /tmp/claude-0/-home-user-outil-usp/177c6ea9-4e50-557d-aabd-014e9ca1fdc6/scratchpad/wt-sauvegarde/sauvegarde/issue229/20261010-issue229-grille-brut.tsv (md5 5fd8d9630dd8518c6add582054c77098) |
| J3 : Jeux du scénario (L8) | sans objet |
| J3 : Contrôle (i3) | OK : empreinte sans commentaires de R/engine.R 46fe1025c2c4a6f241822a89e74b4c06, (g5) de la grille 46fe1025c2c4a6f241822a89e74b4c06 ; md5 du fichier entier 95a48eaf3588a58c507299954597fef1 ; md5 du moteur du T0 de #221 (pour mémoire, lien par (i1) et (c)) 344a4e03751e97b14e5ca1b733b856c6 |
| J3 : Réplications | 2000 (tranches 1-250, 251-500, 501-750, 751-1000, 1001-1250, 1251-1500, 1501-1750, 1751-2000) |
| J3 : Durée cumulée (s) | contrôles 104 ; total 19541 ; réplications 19429 |
| Fichiers de tranches (md5) | J1-01de08.txt 1d48124b642e13442c4781f4a8fa8b2b ; J1-02de08.txt 7fa554735a24acf752ac531fe639d515 ; J1-03de08.txt 3f029e12d1a3cc0b94378d54c577d7ea ; J1-04de08.txt f8f47d9b945eb35a16c34bed47796c73 ; J1-05de08.txt b833f3627f49cf4cc5cec62b2e2ce898 ; J1-06de08.txt 9ab05bee1628907cd3eea0b66d320823 ; J1-07de08.txt 7d80d0c7f33b28743a093a6a52352aa6 ; J1-08de08.txt ee06c64dc0b0cd2a433d1156f59bc8a0 ; J2-01de08.txt 70b33502fe0c9b933373682b4a99c289 ; J2-02de08.txt 9d780994a92f8b02a7b32adf3f71b6e0 ; J2-03de08.txt 795cd0bd71fc33d1cfc116bf2c8c653a ; J2-04de08.txt 160abcc82a2452651603136be4e30c3a ; J2-05de08.txt 2b29bf13c83dca5be1d0f7ae206b3d12 ; J2-06de08.txt 2744e8f1200c294f5be6cb54ed161777 ; J2-07de08.txt 6031b5625e5d505f43097f0c51613689 ; J2-08de08.txt c1d18a8e9267030b6c552f35199681ac ; J3-01de08.txt 2250094ff6e03853a2789ef416db74d9 ; J3-02de08.txt 3044ca2769cd91775d6db2ea06433f9a ; J3-03de08.txt 510918c5e785c6abb66829ca25fcd878 ; J3-04de08.txt 6fff9ba3335cd6076dbc4475d6495243 ; J3-05de08.txt a2632a0b808c56857edd9b88753f9ae4 ; J3-06de08.txt 95aa3500bff7c18bfbae067aa72d0c7b ; J3-07de08.txt 498760ae0d56331aa8e2acac71d786a4 ; J3-08de08.txt 75379b52dc9527fe43506353a8b8d397 |
| JOURNAL | /tmp/claude-0/-home-user-outil-usp/177c6ea9-4e50-557d-aabd-014e9ca1fdc6/scratchpad/wt-sauvegarde/sauvegarde/issue229/JOURNAL.md (md5 e0360a2d0765fbf2885e2268ed9badee) : md5 des 24 tranches conformes ; lignes du débit P4 et de l'empreinte (#231) lues |
| Débit P4 (ligne du JOURNAL) | J2 intérieur, 3 réplications par exécution, durée moyenne par réplication 13,06 s à 1 exécution, 12,10 à 12,70 s à 2, 12,65 à 13,35 s à 3, 12,91 à 13,27 s à 4 exécutions concurrentes (horloge 51 à 54 s pour chaque k) : débit agrégé proportionnel au nombre de tranches jusqu'à 4 ; 4 tranches concurrentes retenues. Estimation (coder, sur ces coûts) : 32 à 35 h CPU, environ 9 à 10 h d'horloge, sous le plafond de 54 h fixé par le mainteneur. |
| Empreinte sans commentaires (#231) du JOURNAL | 46fe1025c2c4a6f241822a89e74b4c06, égale à celle des tranches (contrôle (i3)) |
| Reprises (--reprendre : sortie partielle relue, réplications faites conservées) | J2-01de08.txt : J2-01de08.partiel1.txt 7a2fc6ce5be645bbf5b39efebb8df5e2 27 2 0 ; J2-02de08.txt : J2-02de08.partiel1.txt a5ce7fe73b12298ac110a816023bea70 27 2 0 ; J2-03de08.txt : J2-03de08.partiel1.txt e702769d4273c2c3971a694fd6e04e46 29 1 0 ; J2-04de08.txt : J2-04de08.partiel1.txt 9aee08fd4cf27fc819af5db60411ed6b 26 2 0 |
| Commit de la combinaison | 14f04ce0c2e787b8e2b9f1f5b8f7045b516cfbc1 |
| Empreintes md5 du combinateur | R/engine.R 95a48eaf3588a58c507299954597fef1 ; tests/outils_tests.R chargé (dépôt) 30318c792ac0cc633f415154e15c037c ; script exécuté (dépôt) aa00fcf9451196cd2a7b33a8ca67c882 ; tests/taux_franchissement_reperes.R 9e46c0ad40949e93d35e0c3e1a30ec57 ; docs/specifications/229-p-conditionnelle-regime.md e4c6e21276b469e4362423083750f686 |
| Empreinte sans commentaires de R/engine.R à la combinaison (#231) | 46fe1025c2c4a6f241822a89e74b4c06 |
| Références des lois discrètes (tailles lissées de #166 à B = 999, T0 du tableau de #221 de J2) | suites 0,05713 et 0,00968 ; mk 0,07107 et 0,03355 ; smirnov 0,02857 et 0,02856 ; spearman 0,09038 et 0,04295 ; coxstuart 0,00059 et 0,00000 |
| Valeurs brutes de cette sortie | 20261010-issue229-p-conditionnelle-regime-brut.tsv : md5 bd38957680e4880a5bb5aaabb8e33047, 6002 lignes de réplications (copie hors du dépôt : --brut) |
| Intensités des scénarios de P (constantes INTENSITES) | H0 : H, k = 0 ; H3 : H, k = 3 ; C3 : C, λ = 3 ; C4 : C, λ = 4 ; A4 : A, ν = 4 ; A2 : A, ν = 2 |
| Discordances listées (i1), (v3a), (t2) (expliquées) | aucune |
| Versionnable (--ecrire) | oui |
| Contrôles d'intégrité | OK dans les 24 tranche(s), invariants du corps vérifiés |

### Aide à la lecture

Statut : **constat de simulation** sous les modèles ajustés à J1 et J2 et sous le modèle synthétique J3, pas un résultat général. V1 : p_mc du moteur (rejeu de usp_bootstrap(), contrôles (i1), (i2)) ; V3a : tirages de V1 dont δ̂** est dans le régime de δ̂*_b ; V3b : V3a complétée par un flux distinct jusqu'à 999 retenus ou 25 000 tirages ; V3h : V3b à δ̂* intérieur, V1 aux bords. **Aucune référence ne fonde V3 à T = 8.**

IC : Clopper-Pearson à 95 %, incertitude Monte-Carlo sur le taux (fonction du nombre de réplications), pas l'erreur d'approximation en T. L'erreur liée à B fait partie de la procédure mesurée. Taux par régime : conditionnels à un événement fonction des données. Bande de Bradley (1978) : convention, pas théorème (règle de lecture de #166) ; bande non applicable si la référence est inférieure à 2/n (L6). Population : J1 aux bords (intérieur descriptif, T1 bis) ; J2 et J3, réplications traitées (écartées par le refus de #188 ou une erreur de usp_ajuster(), ou au statut erreur : T3).

McNemar exact, Holm au niveau 0,05 par famille (par. 2.1, Q-A1-5). À l'étape 6, les décisions sont mesurées : la lecture « au point » et la lecture « sous indépendance » de L10, qui portent sur un McNemar prédit par la grille, se réduisent au test exact sur les paires discordantes mesurées. C5 se lit selon L15 (annotation du 10/10/2026) : un témoin significatif est expliqué si sa différence V3b − V1 mesurée a le signe prédit par la grille et reste à moins de e* de la prédiction ; sinon il suspend la lecture.

**Critère de la spécification (par. 2.1 et 2.2), reporté sans modification, évalué mécaniquement sans conclure :**

> ### 2.1 Grandeurs
> 
> - **Décision.** Pour un jeu j, un seuil α ∈ {0,10 ; 0,05}, une statistique s et une variante v : D_v(b) = 1 si p_v(b) < α. **Une p absente compte comme un non-rejet** dans T1, T1 bis et P.
> - **Population du critère.**
>   - J2 et J3 : les R réplications.
>   - **J1 : les seules réplications dont δ̂* est au bord** (bord 0 ∪ bord 1 ; 1 925 sur 2 000 dans #221 **[V]**).
>   - Les 75 réplications intérieures de J1 sont calculées pour les trois variantes et rapportées à titre **descriptif**, hors critère. C'est la lecture proposée de « J1 aux bords seulement » : Q-A1-2.
> - **Taux marginal** τ_v = k / n, avec l'IC de Clopper-Pearson à 95 % et les classes de #166 : compatible ; écart mineur ; écart non tranché ; distorsion matérielle (IC disjoint de la bande de Bradley [α/2 ; 3α/2]), avec son côté.
>   - Lois discrètes (†) : référence lissée de #166 à B = 999 pour V1 et V3b.
>   - Pour V3a, les références discrètes sont **descriptives**, son B effectif étant variable.
> - **Taux par régime** τ_v^r : même définition sur les réplications dont r(δ̂*) = r. Une cellule est évaluable si n^r ≥ 100 ; sinon elle est « non évaluable ».
> - **Comparaison appariée** de v à V1 sur les mêmes réplications :
>   - n01 : v rejette, V1 non ; n10 : V1 rejette, v non ;
>   - **test de McNemar exact** : test binomial bilatéral de paramètre 1/2 sur les n01 + n10 paires discordantes, comme pour #221 (`.tex`, § `sec:calibration-mc`) **[V]** ;
>   - **multiplicité** : correction de Holm (1979) au niveau 0,05, à l'intérieur de chaque famille de tests désignée ci-dessous (Q-A1-5).
> 
> ### 2.2 Conditions
> 
> Chaque condition est évaluée mécaniquement pour **V3b, V3a et V3h si retenue**, et pour V1 quand elle a un sens absolu.
> 
> **C1, calibration marginale (en apparié).** Sur J1 (bords), J2 et J3, aux deux seuils :
> - **(C1a), absolu, sur les 34 statistiques** : la variante n'a pas de distorsion matérielle marginale, sauf si V1 en a une du même côté, et alors sans l'aggraver (règle (b) de #175 : pas de disjonction du côté opposé, pas de taux au-delà de l'IC de V1 du côté de la distorsion).
> - **(C1b), aggravation libérale, sur F_R** (Holm par famille (jeu, α), 22 tests) : on ne doit pas avoir à la fois un McNemar significatif après Holm, n01 > n10, et une borne basse de l'IC de τ_v supérieure à α.
> - **(C1c), descriptif** : aggravation conservatrice (McNemar significatif, n10 > n01, borne haute de l'IC de τ_v inférieure à α). Elle n'est pas éliminatoire, son coût relevant de C4 ; c'est l'asymétrie de la condition 1 d'origine.
> 
> **C2, calibration conditionnelle** (cellules évaluables) :
> - **(C2a), correction, au sens de #175, à α = 0,10.**
>   - Au régime intérieur de J2 : au moins 5 des 8 statistiques de F_8 ont un IC de V1 disjoint de la bande et un IC de la variante non disjoint.
>   - Au régime intérieur de J3 : même règle, avec un seuil de min(5, m₃), où m₃ est le nombre de statistiques de F_8 dont l'IC de V1 y est disjoint.
> - **(C2b), aucune distorsion créée, inversée ni aggravée**, sur toutes les cellules (J1 bord 0 et bord 1 ; J2 et J3, trois régimes) × F_R × deux seuils. Règles (a) et (b) de #175 : si l'IC de V1 n'est pas disjoint, celui de la variante ne l'est pas non plus ; s'il l'est, la variante n'est pas disjointe du côté opposé et son taux ne dépasse pas l'IC de V1 du côté de la distorsion.
> - Le McNemar par régime est rapporté (Holm par famille (jeu, régime, α)), sans entrer dans C2.
> 
> **C3, p absentes.** Par jeu (J1 sur ses bords), la part des réplications où la p de la variante manque pour au moins une statistique de F_R, **alors que celle de V1 existe**, est au plus 1 %. Les motifs communs à V1 (statistique dégénérée, observée non finie) sont exclus.
> 
> **C4, puissance (partie P, § 6).**
> - **(C4a), non-infériorité.** Pour chaque scénario et chaque seuil, aucune statistique de F_R n'a de McNemar significatif après Holm (famille (scénario, α), 22 tests) avec n10 > n01. On compte toutes les réplications du scénario.
> - **(C4b), gain.** Pour au moins une famille d'alternatives, au moins une statistique de son ensemble cible (§ 6) a, **sur les réplications à δ̂* intérieur**, un McNemar significatif après Holm (famille (scénario, α = 0,10, ensemble cible)) avec n01 > n10.
> - **(C4c), descriptif** : puissance par régime, bords compris, et taux bruts rapportés avec le niveau mesuré de chaque variante (T1 du même jeu).
> 
> **C5, témoins (validité de la mesure, et non condition sur une variante).** Pour chaque jeu et chaque seuil, McNemar V3b contre V1 sur les 12 statistiques de F_T, avec Holm sur la famille. Un témoin significatif est un **point d'examen avant la lecture d'A3** : soit défaut de la mesure, soit l'indépendance au régime ne tient pas pour ce témoin.

### Évaluation mécanique des conditions C1, C2, C3, C5 (sans conclure ; C4 : partie P)

| Condition | Variante | État (mécanique) | Détail |
| --- | --- | --- | --- |
| C1a | V1 | distorsions de V1 (sens absolu) | distorsions matérielles marginales : J3 GQ 0,10 (conservateur) ; J3 GQ 0,05 (conservateur) ; bande non applicable (L6) : J1 (bords) CoxStuart 0,10 ; J1 (bords) CoxStuart 0,05 ; J2 CoxStuart 0,10 ; J2 CoxStuart 0,05 ; J3 CoxStuart 0,10 ; J3 CoxStuart 0,05 |
| C1a | V3b | remplie | cellules en défaut : aucune ; bande non applicable (L6) : J1 (bords) CoxStuart 0,10 ; J1 (bords) CoxStuart 0,05 ; J2 CoxStuart 0,10 ; J2 CoxStuart 0,05 ; J3 CoxStuart 0,10 ; J3 CoxStuart 0,05 |
| C1a | V3a | remplie | cellules en défaut : aucune ; bande non applicable (L6) : J1 (bords) CoxStuart 0,10 ; J1 (bords) CoxStuart 0,05 ; J2 CoxStuart 0,10 ; J2 CoxStuart 0,05 ; J3 CoxStuart 0,10 ; J3 CoxStuart 0,05 ; descriptives pour V3a (loi discrète, L13) : Smirnov, Runs, MK, SpearVol, SpearTps, Runsr |
| C1a | V3h | remplie | cellules en défaut : aucune ; bande non applicable (L6) : J1 (bords) CoxStuart 0,10 ; J1 (bords) CoxStuart 0,05 ; J2 CoxStuart 0,10 ; J2 CoxStuart 0,05 ; J3 CoxStuart 0,10 ; J3 CoxStuart 0,05 |
| C1b | V3b | remplie | aggravation libérale (McNemar Holm < 0,05, n01 > n10, borne basse > α, L9) : aucune |
| C1c (descriptif) | V3b | aggravation conservatrice | J1 (bords) BP79 0,10 (1/30) ; J1 (bords) BP79 0,05 (0/17) |
| C1b | V3a | remplie | aggravation libérale (McNemar Holm < 0,05, n01 > n10, borne basse > α, L9) : aucune |
| C1c (descriptif) | V3a | aggravation conservatrice | J1 (bords) BP79 0,10 (1/32) ; J1 (bords) BP79 0,05 (0/17) |
| C1b | V3h | remplie | aggravation libérale (McNemar Holm < 0,05, n01 > n10, borne basse > α, L9) : aucune |
| C1c (descriptif) | V3h | aggravation conservatrice | J2 RESET 0,10 (0/15) ; J2 SpearTps 0,10 (1/13) |
| C2a (J2 intérieur) | V3b | remplie | n = 464 ; IC de V1 disjoint et IC de la variante non disjoint : 7 (BP, BP79, GQ, BF, Grubbs, DAgo, JB), seuil 5 |
| C2a (J3 intérieur) | V3b | remplie | n = 1125 ; IC de V1 disjoint et IC de la variante non disjoint : 4 (BP, BP79, GQ, BF), seuil 4 (m3 = 4) |
| C2a (J2 intérieur) | V3a | remplie | n = 464 ; IC de V1 disjoint et IC de la variante non disjoint : 7 (BP, BP79, GQ, BF, Grubbs, DAgo, JB), seuil 5 |
| C2a (J3 intérieur) | V3a | remplie | n = 1125 ; IC de V1 disjoint et IC de la variante non disjoint : 4 (BP, BP79, GQ, BF), seuil 4 (m3 = 4) |
| C2a (J2 intérieur) | V3h | remplie | n = 464 ; IC de V1 disjoint et IC de la variante non disjoint : 7 (BP, BP79, GQ, BF, Grubbs, DAgo, JB), seuil 5 |
| C2a (J3 intérieur) | V3h | remplie | n = 1125 ; IC de V1 disjoint et IC de la variante non disjoint : 4 (BP, BP79, GQ, BF), seuil 4 (m3 = 4) |
| C2b | V3b | remplie | cellules en défaut : aucune ; cellules non évaluables (n < 100) : aucune |
| C2b | V3a | remplie | cellules en défaut : aucune ; cellules non évaluables (n < 100) : aucune ; descriptives pour V3a (L13) : MK, SpearVol, SpearTps |
| C2b | V3h | remplie | cellules en défaut : aucune ; cellules non évaluables (n < 100) : aucune |
| C3 | V3b | remplie | part des réplications où la p manque pour au moins une statistique de F_R alors que celle de V1 existe (seuil 1 %) : J1 (bords) 0,0000 (0 répl. ; motifs : B eff. < B_MIN_DEGENERESCENCE 0, B eff. = 0 0, dispersion nulle 0, atome hors obs. 0) ; J2 0,0000 (0 répl. ; motifs : B eff. < B_MIN_DEGENERESCENCE 0, B eff. = 0 0, dispersion nulle 0, atome hors obs. 0) ; J3 0,0000 (0 répl. ; motifs : B eff. < B_MIN_DEGENERESCENCE 0, B eff. = 0 0, dispersion nulle 0, atome hors obs. 0) |
| C3 | V3a | remplie | part des réplications où la p manque pour au moins une statistique de F_R alors que celle de V1 existe (seuil 1 %) : J1 (bords) 0,0000 (0 répl. ; motifs : B eff. < B_MIN_DEGENERESCENCE 0, B eff. = 0 0, dispersion nulle 0, atome hors obs. 0) ; J2 0,0000 (0 répl. ; motifs : B eff. < B_MIN_DEGENERESCENCE 0, B eff. = 0 0, dispersion nulle 0, atome hors obs. 0) ; J3 0,0000 (0 répl. ; motifs : B eff. < B_MIN_DEGENERESCENCE 0, B eff. = 0 0, dispersion nulle 0, atome hors obs. 0) |
| C3 | V3h | remplie | part des réplications où la p manque pour au moins une statistique de F_R alors que celle de V1 existe (seuil 1 %) : J1 (bords) 0,0000 (0 répl. ; motifs : B eff. < B_MIN_DEGENERESCENCE 0, B eff. = 0 0, dispersion nulle 0, atome hors obs. 0) ; J2 0,0000 (0 répl. ; motifs : B eff. < B_MIN_DEGENERESCENCE 0, B eff. = 0 0, dispersion nulle 0, atome hors obs. 0) ; J3 0,0000 (0 répl. ; motifs : B eff. < B_MIN_DEGENERESCENCE 0, B eff. = 0 0, dispersion nulle 0, atome hors obs. 0) |
| C5 (témoins, V3b contre V1) | V3b | témoins significatifs tous expliqués (L15) | témoins significatifs après Holm : J3 AD 0,10 (27/7, p Holm 0,00821 ; V3b − V1 mesuré 0,0100, prédit 0,0099, écart 0,0001, e* 0,0169 : expliqué (L15)) ; J3 Intercept 0,10 (58/18, p Holm 5,66e-05 ; V3b − V1 mesuré 0,0200, prédit 0,0218, écart -0,0018, e* 0,0169 : expliqué (L15)) ; J3 Smirnov 0,10 (13/0, p Holm 0,00269 ; V3b − V1 mesuré 0,0065, prédit 0,0175, écart -0,0110, e* 0,0169 : expliqué (L15)) ; prédictions : docs/tableaux/20261010-issue229-grille.md (md5 ba5e29a2aa3d727b4c4ffa61d11de05f) : T1 prédit, 102 lignes ; e* J1 0,0136 / 0,0182, J2 et J3 0,0169 / 0,0172 |

**Profils (par. 2.3), partiels avant la partie P :**

| Variante | C1 | C2 | C3 | C4 | Profil(s) (par. 2.3) |
| --- | --- | --- | --- | --- | --- |
| V3b | remplie | remplie | remplie | en attente (partie P) | en attente de C4 (partie P) : D1, D2 ou D3 selon C1 et C4 |
| V3a | remplie | remplie | remplie | en attente (partie P) | en attente de C4 (partie P) : D1, D2 ou D3 selon C1 et C4 |
| V3h | remplie | remplie | remplie | en attente (partie P) | en attente de C4 (partie P) : D1, D2 ou D3 selon C1 et C4 |

Compléments du par. 2.3 : si V3a a le même profil que V3b, elle devient la candidate moins coûteuse ; un témoin de C5 en défaut et non expliqué suspend la lecture ; T2 est rapporté sans critère.

### C5 -- témoins (F_T) : différence V3b − V1 mesurée et prédite par la grille (L15)

Population du critère ; McNemar V3b contre V1, Holm sur F_T par (jeu, α) ; prédiction : T1 prédit du tableau de la grille (π à B fini, colonnes V3b et V1) ; e* du jeu et du seuil (J3 : celui de J2). Un témoin significatif est expliqué si le signe mesuré est le signe prédit et si l'écart est inférieur à e* ; sinon il suspend la lecture (par. 2.3). Prédictions : docs/tableaux/20261010-issue229-grille.md (md5 ba5e29a2aa3d727b4c4ffa61d11de05f) : T1 prédit, 102 lignes ; e* J1 0,0136 / 0,0182, J2 et J3 0,0169 / 0,0172.

| Jeu | α | Témoin | n01 / n10 | p Holm | significatif | V3b − V1 mesuré | prédit | écart | e* | signe concordant | lecture L15 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| J1 (bords) | 0,10 | AD | 3 / 11 | 0,631 | non | -0,0042 | 0,0005 | -0,0047 | 0,0136 | non | — |
| J1 (bords) | 0,10 | CvM | 4 / 7 | 1 | non | -0,0016 | -0,0008 | -0,0008 | 0,0136 | oui | — |
| J1 (bords) | 0,10 | KS | 7 / 4 | 1 | non | 0,0016 | -0,0014 | 0,0030 | 0,0136 | non | — |
| J1 (bords) | 0,10 | SW | 2 / 11 | 0,27 | non | -0,0047 | -0,0003 | -0,0044 | 0,0136 | oui | — |
| J1 (bords) | 0,10 | Lillie | 5 / 4 | 1 | non | 0,0005 | -0,0038 | 0,0043 | 0,0136 | non | — |
| J1 (bords) | 0,10 | Intercept | 16 / 17 | 1 | non | -0,0005 | -0,0007 | 0,0002 | 0,0136 | oui | — |
| J1 (bords) | 0,10 | CUSUM | 3 / 9 | 1 | non | -0,0031 | -0,0003 | -0,0028 | 0,0136 | oui | — |
| J1 (bords) | 0,10 | LB1 | 8 / 9 | 1 | non | -0,0005 | -0,0011 | 0,0006 | 0,0136 | oui | — |
| J1 (bords) | 0,10 | Runs | 0 / 0 | 1 | non | 0,0000 | 0,0002 | -0,0002 | 0,0136 | non | — |
| J1 (bords) | 0,10 | Runsr | 0 / 0 | 1 | non | 0,0000 | 0,0002 | -0,0002 | 0,0136 | non | — |
| J1 (bords) | 0,10 | Smirnov | 0 / 0 | 1 | non | 0,0000 | 0,0000 | 0,0000 | 0,0136 | oui | — |
| J1 (bords) | 0,10 | CoxStuart | 2 / 0 | 1 | non | 0,0010 | -0,0007 | 0,0017 | 0,0136 | non | — |
| J1 (bords) | 0,05 | AD | 8 / 5 | 1 | non | 0,0016 | -0,0007 | 0,0023 | 0,0182 | non | — |
| J1 (bords) | 0,05 | CvM | 6 / 7 | 1 | non | -0,0005 | -0,0016 | 0,0011 | 0,0182 | oui | — |
| J1 (bords) | 0,05 | KS | 7 / 6 | 1 | non | 0,0005 | -0,0020 | 0,0025 | 0,0182 | non | — |
| J1 (bords) | 0,05 | SW | 4 / 2 | 1 | non | 0,0010 | -0,0004 | 0,0014 | 0,0182 | non | — |
| J1 (bords) | 0,05 | Lillie | 3 / 8 | 1 | non | -0,0026 | -0,0013 | -0,0013 | 0,0182 | oui | — |
| J1 (bords) | 0,05 | Intercept | 7 / 14 | 1 | non | -0,0036 | -0,0015 | -0,0021 | 0,0182 | oui | — |
| J1 (bords) | 0,05 | CUSUM | 4 / 4 | 1 | non | 0,0000 | 0,0011 | -0,0011 | 0,0182 | non | — |
| J1 (bords) | 0,05 | LB1 | 5 / 5 | 1 | non | 0,0000 | 0,0012 | -0,0012 | 0,0182 | non | — |
| J1 (bords) | 0,05 | Runs | 14 / 12 | 1 | non | 0,0010 | 0,0067 | -0,0057 | 0,0182 | oui | — |
| J1 (bords) | 0,05 | Runsr | 14 / 11 | 1 | non | 0,0016 | 0,0072 | -0,0056 | 0,0182 | oui | — |
| J1 (bords) | 0,05 | Smirnov | 0 / 0 | 1 | non | 0,0000 | 0,0003 | -0,0003 | 0,0182 | non | — |
| J1 (bords) | 0,05 | CoxStuart | 0 / 0 | 1 | non | 0,0000 | 0,0000 | 0,0000 | 0,0182 | oui | — |
| J2 | 0,10 | AD | 5 / 9 | 1 | non | -0,0020 | -0,0007 | -0,0013 | 0,0169 | oui | — |
| J2 | 0,10 | CvM | 7 / 10 | 1 | non | -0,0015 | 0,0005 | -0,0020 | 0,0169 | non | — |
| J2 | 0,10 | KS | 8 / 11 | 1 | non | -0,0015 | -0,0001 | -0,0014 | 0,0169 | oui | — |
| J2 | 0,10 | SW | 6 / 12 | 1 | non | -0,0030 | -0,0007 | -0,0023 | 0,0169 | oui | — |
| J2 | 0,10 | Lillie | 9 / 13 | 1 | non | -0,0020 | 0,0000 | -0,0020 | 0,0169 | non | — |
| J2 | 0,10 | Intercept | 17 / 13 | 1 | non | 0,0020 | -0,0030 | 0,0050 | 0,0169 | non | — |
| J2 | 0,10 | CUSUM | 13 / 12 | 1 | non | 0,0005 | 0,0026 | -0,0021 | 0,0169 | oui | — |
| J2 | 0,10 | LB1 | 14 / 10 | 1 | non | 0,0020 | 0,0010 | 0,0010 | 0,0169 | oui | — |
| J2 | 0,10 | Runs | 0 / 0 | 1 | non | 0,0000 | -0,0003 | 0,0003 | 0,0169 | non | — |
| J2 | 0,10 | Runsr | 0 / 0 | 1 | non | 0,0000 | -0,0002 | 0,0002 | 0,0169 | non | — |
| J2 | 0,10 | Smirnov | 0 / 0 | 1 | non | 0,0000 | 0,0001 | -0,0001 | 0,0169 | non | — |
| J2 | 0,10 | CoxStuart | 0 / 0 | 1 | non | 0,0000 | 0,0019 | -0,0019 | 0,0169 | non | — |
| J2 | 0,05 | AD | 3 / 9 | 1 | non | -0,0030 | -0,0013 | -0,0017 | 0,0172 | oui | — |
| J2 | 0,05 | CvM | 5 / 5 | 1 | non | 0,0000 | -0,0010 | 0,0010 | 0,0172 | non | — |
| J2 | 0,05 | KS | 1 / 5 | 1 | non | -0,0020 | -0,0014 | -0,0006 | 0,0172 | oui | — |
| J2 | 0,05 | SW | 4 / 2 | 1 | non | 0,0010 | -0,0019 | 0,0029 | 0,0172 | non | — |
| J2 | 0,05 | Lillie | 5 / 14 | 0,763 | non | -0,0045 | -0,0030 | -0,0015 | 0,0172 | oui | — |
| J2 | 0,05 | Intercept | 13 / 8 | 1 | non | 0,0025 | 0,0027 | -0,0002 | 0,0172 | oui | — |
| J2 | 0,05 | CUSUM | 10 / 4 | 1 | non | 0,0030 | 0,0029 | 0,0001 | 0,0172 | oui | — |
| J2 | 0,05 | LB1 | 6 / 12 | 1 | non | -0,0030 | 0,0004 | -0,0034 | 0,0172 | non | — |
| J2 | 0,05 | Runs | 14 / 10 | 1 | non | 0,0020 | 0,0002 | 0,0018 | 0,0172 | oui | — |
| J2 | 0,05 | Runsr | 12 / 12 | 1 | non | 0,0000 | 0,0011 | -0,0011 | 0,0172 | non | — |
| J2 | 0,05 | Smirnov | 0 / 0 | 1 | non | 0,0000 | 0,0000 | 0,0000 | 0,0172 | oui | — |
| J2 | 0,05 | CoxStuart | 0 / 0 | 1 | non | 0,0000 | 0,0000 | 0,0000 | 0,0172 | oui | — |
| J3 | 0,10 | AD | 27 / 7 | 0,00821 | oui | 0,0100 | 0,0099 | 0,0001 | 0,0169 | oui | expliqué |
| J3 | 0,10 | CvM | 18 / 8 | 0,453 | non | 0,0050 | 0,0074 | -0,0024 | 0,0169 | oui | — |
| J3 | 0,10 | KS | 14 / 4 | 0,232 | non | 0,0050 | 0,0060 | -0,0010 | 0,0169 | oui | — |
| J3 | 0,10 | SW | 10 / 8 | 1 | non | 0,0010 | -0,0012 | 0,0022 | 0,0169 | non | — |
| J3 | 0,10 | Lillie | 6 / 18 | 0,204 | non | -0,0060 | 0,0010 | -0,0070 | 0,0169 | non | — |
| J3 | 0,10 | Intercept | 58 / 18 | 5,66e-05 | oui | 0,0200 | 0,0218 | -0,0018 | 0,0169 | oui | expliqué |
| J3 | 0,10 | CUSUM | 9 / 10 | 1 | non | -0,0005 | 0,0006 | -0,0011 | 0,0169 | non | — |
| J3 | 0,10 | LB1 | 7 / 19 | 0,232 | non | -0,0060 | -0,0035 | -0,0025 | 0,0169 | oui | — |
| J3 | 0,10 | Runs | 0 / 1 | 1 | non | -0,0005 | -0,0004 | -0,0001 | 0,0169 | oui | — |
| J3 | 0,10 | Runsr | 0 / 1 | 1 | non | -0,0005 | -0,0001 | -0,0004 | 0,0169 | oui | — |
| J3 | 0,10 | Smirnov | 13 / 0 | 0,00269 | oui | 0,0065 | 0,0175 | -0,0110 | 0,0169 | oui | expliqué |
| J3 | 0,10 | CoxStuart | 0 / 0 | 1 | non | 0,0000 | 0,0006 | -0,0006 | 0,0169 | non | — |
| J3 | 0,05 | AD | 10 / 2 | 0,463 | non | 0,0040 | 0,0039 | 0,0001 | 0,0172 | oui | — |
| J3 | 0,05 | CvM | 8 / 5 | 1 | non | 0,0015 | 0,0051 | -0,0036 | 0,0172 | oui | — |
| J3 | 0,05 | KS | 10 / 6 | 1 | non | 0,0020 | 0,0057 | -0,0037 | 0,0172 | oui | — |
| J3 | 0,05 | SW | 6 / 1 | 1 | non | 0,0025 | 0,0003 | 0,0022 | 0,0172 | oui | — |
| J3 | 0,05 | Lillie | 9 / 6 | 1 | non | 0,0015 | -0,0007 | 0,0022 | 0,0172 | non | — |
| J3 | 0,05 | Intercept | 35 / 19 | 0,463 | non | 0,0080 | 0,0099 | -0,0019 | 0,0172 | oui | — |
| J3 | 0,05 | CUSUM | 5 / 9 | 1 | non | -0,0020 | -0,0007 | -0,0013 | 0,0172 | oui | — |
| J3 | 0,05 | LB1 | 9 / 13 | 1 | non | -0,0020 | -0,0021 | 0,0001 | 0,0172 | oui | — |
| J3 | 0,05 | Runs | 10 / 5 | 1 | non | 0,0025 | -0,0008 | 0,0033 | 0,0172 | non | — |
| J3 | 0,05 | Runsr | 13 / 18 | 1 | non | -0,0025 | -0,0024 | -0,0001 | 0,0172 | oui | — |
| J3 | 0,05 | Smirnov | 0 / 0 | 1 | non | 0,0000 | 0,0000 | 0,0000 | 0,0172 | oui | — |
| J3 | 0,05 | CoxStuart | 0 / 0 | 1 | non | 0,0000 | 0,0000 | 0,0000 | 0,0172 | oui | — |

### T1 -- taux marginaux de rejet par jeu, statistique et variante (population du critère ; p absente = non-rejet)

Par seuil : k, taux k / n et IC de Clopper-Pearson à 95 % (côté en gras si l'IC est disjoint de la bande [réf/2 ; 3 réf/2]), classe de #166, McNemar contre V1 (n01 / n10, p après Holm : famille (jeu, α, variante) sur F_R pour une statistique de F_R, sur F_T pour un témoin). † : loi discrète, référence lissée de #166 à B = 999 (descriptive pour V3a, L13).

| Jeu | Statistique (sens) | famille | Variante | n | réf. 0,10 | k | taux [IC] 0,10 | classe 0,10 | McNemar 0,10 | réf. 0,05 | k | taux [IC] 0,05 | classe 0,05 | McNemar 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| J1 (bords) | AD (haut) | F_T | V1 | 1925 | 0,1000 | 182 | 0,0945 [0,0818 ; 0,1085] | compatible | — | 0,0500 | 88 | 0,0457 [0,0368 ; 0,0560] | compatible | — |
| J1 (bords) | AD (haut) | F_T | V3a | 1925 | 0,1000 | 177 | 0,0919 [0,0794 ; 0,1057] | compatible | 3 / 8, 1 | 0,0500 | 94 | 0,0488 [0,0396 ; 0,0594] | compatible | 12 / 6, 1 |
| J1 (bords) | AD (haut) | F_T | V3b | 1925 | 0,1000 | 174 | 0,0904 [0,0780 ; 0,1041] | compatible | 3 / 11, 0,631 | 0,0500 | 91 | 0,0473 [0,0382 ; 0,0577] | compatible | 8 / 5, 1 |
| J1 (bords) | AD (haut) | F_T | V3h | 1925 | 0,1000 | 182 | 0,0945 [0,0818 ; 0,1085] | compatible | 0 / 0, 1 | 0,0500 | 88 | 0,0457 [0,0368 ; 0,0560] | compatible | 0 / 0, 1 |
| J1 (bords) | CvM (haut) | F_T | V1 | 1925 | 0,1000 | 187 | 0,0971 [0,0843 ; 0,1113] | compatible | — | 0,0500 | 88 | 0,0457 [0,0368 ; 0,0560] | compatible | — |
| J1 (bords) | CvM (haut) | F_T | V3a | 1925 | 0,1000 | 181 | 0,0940 [0,0814 ; 0,1079] | compatible | 4 / 10, 1 | 0,0500 | 90 | 0,0468 [0,0378 ; 0,0572] | compatible | 7 / 5, 1 |
| J1 (bords) | CvM (haut) | F_T | V3b | 1925 | 0,1000 | 184 | 0,0956 [0,0828 ; 0,1096] | compatible | 4 / 7, 1 | 0,0500 | 87 | 0,0452 [0,0364 ; 0,0555] | compatible | 6 / 7, 1 |
| J1 (bords) | CvM (haut) | F_T | V3h | 1925 | 0,1000 | 187 | 0,0971 [0,0843 ; 0,1113] | compatible | 0 / 0, 1 | 0,0500 | 88 | 0,0457 [0,0368 ; 0,0560] | compatible | 0 / 0, 1 |
| J1 (bords) | KS (haut) | F_T | V1 | 1925 | 0,1000 | 164 | 0,0852 [0,0731 ; 0,0986] | écart mineur | — | 0,0500 | 90 | 0,0468 [0,0378 ; 0,0572] | compatible | — |
| J1 (bords) | KS (haut) | F_T | V3a | 1925 | 0,1000 | 165 | 0,0857 [0,0736 ; 0,0991] | écart mineur | 5 / 4, 1 | 0,0500 | 87 | 0,0452 [0,0364 ; 0,0555] | compatible | 5 / 8, 1 |
| J1 (bords) | KS (haut) | F_T | V3b | 1925 | 0,1000 | 167 | 0,0868 [0,0746 ; 0,1002] | compatible | 7 / 4, 1 | 0,0500 | 91 | 0,0473 [0,0382 ; 0,0577] | compatible | 7 / 6, 1 |
| J1 (bords) | KS (haut) | F_T | V3h | 1925 | 0,1000 | 164 | 0,0852 [0,0731 ; 0,0986] | écart mineur | 0 / 0, 1 | 0,0500 | 90 | 0,0468 [0,0378 ; 0,0572] | compatible | 0 / 0, 1 |
| J1 (bords) | SW (bas) | F_T | V1 | 1925 | 0,1000 | 180 | 0,0935 [0,0809 ; 0,1074] | compatible | — | 0,0500 | 87 | 0,0452 [0,0364 ; 0,0555] | compatible | — |
| J1 (bords) | SW (bas) | F_T | V3a | 1925 | 0,1000 | 178 | 0,0925 [0,0799 ; 0,1063] | compatible | 8 / 10, 1 | 0,0500 | 90 | 0,0468 [0,0378 ; 0,0572] | compatible | 7 / 4, 1 |
| J1 (bords) | SW (bas) | F_T | V3b | 1925 | 0,1000 | 171 | 0,0888 [0,0765 ; 0,1024] | compatible | 2 / 11, 0,27 | 0,0500 | 89 | 0,0462 [0,0373 ; 0,0566] | compatible | 4 / 2, 1 |
| J1 (bords) | SW (bas) | F_T | V3h | 1925 | 0,1000 | 180 | 0,0935 [0,0809 ; 0,1074] | compatible | 0 / 0, 1 | 0,0500 | 87 | 0,0452 [0,0364 ; 0,0555] | compatible | 0 / 0, 1 |
| J1 (bords) | SF (bas) | F_R | V1 | 1925 | 0,1000 | 176 | 0,0914 [0,0789 ; 0,1052] | compatible | — | 0,0500 | 93 | 0,0483 [0,0392 ; 0,0589] | compatible | — |
| J1 (bords) | SF (bas) | F_R | V3a | 1925 | 0,1000 | 171 | 0,0888 [0,0765 ; 0,1024] | compatible | 5 / 10, 1 | 0,0500 | 90 | 0,0468 [0,0378 ; 0,0572] | compatible | 6 / 9, 1 |
| J1 (bords) | SF (bas) | F_R | V3b | 1925 | 0,1000 | 171 | 0,0888 [0,0765 ; 0,1024] | compatible | 6 / 11, 1 | 0,0500 | 85 | 0,0442 [0,0354 ; 0,0543] | compatible | 4 / 12, 1 |
| J1 (bords) | SF (bas) | F_R | V3h | 1925 | 0,1000 | 176 | 0,0914 [0,0789 ; 0,1052] | compatible | 0 / 0, 1 | 0,0500 | 93 | 0,0483 [0,0392 ; 0,0589] | compatible | 0 / 0, 1 |
| J1 (bords) | JB (haut) | F_R, F_8 | V1 | 1925 | 0,1000 | 180 | 0,0935 [0,0809 ; 0,1074] | compatible | — | 0,0500 | 93 | 0,0483 [0,0392 ; 0,0589] | compatible | — |
| J1 (bords) | JB (haut) | F_R, F_8 | V3a | 1925 | 0,1000 | 177 | 0,0919 [0,0794 ; 0,1057] | compatible | 0 / 3, 1 | 0,0500 | 92 | 0,0478 [0,0387 ; 0,0583] | compatible | 4 / 5, 1 |
| J1 (bords) | JB (haut) | F_R, F_8 | V3b | 1925 | 0,1000 | 170 | 0,0883 [0,0760 ; 0,1019] | compatible | 5 / 15, 0,621 | 0,0500 | 88 | 0,0457 [0,0368 ; 0,0560] | compatible | 1 / 6, 1 |
| J1 (bords) | JB (haut) | F_R, F_8 | V3h | 1925 | 0,1000 | 180 | 0,0935 [0,0809 ; 0,1074] | compatible | 0 / 0, 1 | 0,0500 | 93 | 0,0483 [0,0392 ; 0,0589] | compatible | 0 / 0, 1 |
| J1 (bords) | DW (deux) | F_R | V1 | 1925 | 0,1000 | 221 | 0,1148 [0,1009 ; 0,1299] | écart mineur | — | 0,0500 | 98 | 0,0509 [0,0415 ; 0,0617] | compatible | — |
| J1 (bords) | DW (deux) | F_R | V3a | 1925 | 0,1000 | 215 | 0,1117 [0,0980 ; 0,1266] | compatible | 9 / 15, 1 | 0,0500 | 94 | 0,0488 [0,0396 ; 0,0594] | compatible | 8 / 12, 1 |
| J1 (bords) | DW (deux) | F_R | V3b | 1925 | 0,1000 | 213 | 0,1106 [0,0970 ; 0,1255] | compatible | 6 / 14, 1 | 0,0500 | 90 | 0,0468 [0,0378 ; 0,0572] | compatible | 3 / 11, 1 |
| J1 (bords) | DW (deux) | F_R | V3h | 1925 | 0,1000 | 221 | 0,1148 [0,1009 ; 0,1299] | écart mineur | 0 / 0, 1 | 0,0500 | 98 | 0,0509 [0,0415 ; 0,0617] | compatible | 0 / 0, 1 |
| J1 (bords) | LB1 (haut) | F_T | V1 | 1925 | 0,1000 | 206 | 0,1070 [0,0936 ; 0,1217] | compatible | — | 0,0500 | 100 | 0,0519 [0,0425 ; 0,0628] | compatible | — |
| J1 (bords) | LB1 (haut) | F_T | V3a | 1925 | 0,1000 | 201 | 0,1044 [0,0911 ; 0,1189] | compatible | 4 / 9, 1 | 0,0500 | 101 | 0,0525 [0,0429 ; 0,0634] | compatible | 4 / 3, 1 |
| J1 (bords) | LB1 (haut) | F_T | V3b | 1925 | 0,1000 | 205 | 0,1065 [0,0931 ; 0,1211] | compatible | 8 / 9, 1 | 0,0500 | 100 | 0,0519 [0,0425 ; 0,0628] | compatible | 5 / 5, 1 |
| J1 (bords) | LB1 (haut) | F_T | V3h | 1925 | 0,1000 | 206 | 0,1070 [0,0936 ; 0,1217] | compatible | 0 / 0, 1 | 0,0500 | 100 | 0,0519 [0,0425 ; 0,0628] | compatible | 0 / 0, 1 |
| J1 (bords) | supF (haut) | F_R | V1 | 1925 | 0,1000 | 208 | 0,1081 [0,0945 ; 0,1228] | compatible | — | 0,0500 | 99 | 0,0514 [0,0420 ; 0,0623] | compatible | — |
| J1 (bords) | supF (haut) | F_R | V3a | 1925 | 0,1000 | 193 | 0,1003 [0,0872 ; 0,1146] | compatible | 5 / 20, 0,0734 | 0,0500 | 98 | 0,0509 [0,0415 ; 0,0617] | compatible | 5 / 6, 1 |
| J1 (bords) | supF (haut) | F_R | V3b | 1925 | 0,1000 | 199 | 0,1034 [0,0901 ; 0,1178] | compatible | 8 / 17, 1 | 0,0500 | 95 | 0,0494 [0,0401 ; 0,0600] | compatible | 3 / 7, 1 |
| J1 (bords) | supF (haut) | F_R | V3h | 1925 | 0,1000 | 208 | 0,1081 [0,0945 ; 0,1228] | compatible | 0 / 0, 1 | 0,0500 | 99 | 0,0514 [0,0420 ; 0,0623] | compatible | 0 / 0, 1 |
| J1 (bords) | CUSUM (haut) | F_T | V1 | 1925 | 0,1000 | 207 | 0,1075 [0,0940 ; 0,1222] | compatible | — | 0,0500 | 97 | 0,0504 [0,0410 ; 0,0611] | compatible | — |
| J1 (bords) | CUSUM (haut) | F_T | V3a | 1925 | 0,1000 | 201 | 0,1044 [0,0911 ; 0,1189] | compatible | 3 / 9, 1 | 0,0500 | 92 | 0,0478 [0,0387 ; 0,0583] | compatible | 2 / 7, 1 |
| J1 (bords) | CUSUM (haut) | F_T | V3b | 1925 | 0,1000 | 201 | 0,1044 [0,0911 ; 0,1189] | compatible | 3 / 9, 1 | 0,0500 | 97 | 0,0504 [0,0410 ; 0,0611] | compatible | 4 / 4, 1 |
| J1 (bords) | CUSUM (haut) | F_T | V3h | 1925 | 0,1000 | 207 | 0,1075 [0,0940 ; 0,1222] | compatible | 0 / 0, 1 | 0,0500 | 97 | 0,0504 [0,0410 ; 0,0611] | compatible | 0 / 0, 1 |
| J1 (bords) | Grubbs (haut) | F_R, F_8 | V1 | 1925 | 0,1000 | 199 | 0,1034 [0,0901 ; 0,1178] | compatible | — | 0,0500 | 94 | 0,0488 [0,0396 ; 0,0594] | compatible | — |
| J1 (bords) | Grubbs (haut) | F_R, F_8 | V3a | 1925 | 0,1000 | 192 | 0,0997 [0,0867 ; 0,1140] | compatible | 2 / 9, 0,851 | 0,0500 | 90 | 0,0468 [0,0378 ; 0,0572] | compatible | 3 / 7, 1 |
| J1 (bords) | Grubbs (haut) | F_R, F_8 | V3b | 1925 | 0,1000 | 185 | 0,0961 [0,0833 ; 0,1102] | compatible | 2 / 16, 0,0236 | 0,0500 | 84 | 0,0436 [0,0350 ; 0,0537] | compatible | 0 / 10, 0,041 |
| J1 (bords) | Grubbs (haut) | F_R, F_8 | V3h | 1925 | 0,1000 | 199 | 0,1034 [0,0901 ; 0,1178] | compatible | 0 / 0, 1 | 0,0500 | 94 | 0,0488 [0,0396 ; 0,0594] | compatible | 0 / 0, 1 |
| J1 (bords) | Lillie (haut) | F_T | V1 | 1925 | 0,1000 | 170 | 0,0883 [0,0760 ; 0,1019] | compatible | — | 0,0500 | 95 | 0,0494 [0,0401 ; 0,0600] | compatible | — |
| J1 (bords) | Lillie (haut) | F_T | V3a | 1925 | 0,1000 | 168 | 0,0873 [0,0750 ; 0,1008] | compatible | 3 / 5, 1 | 0,0500 | 89 | 0,0462 [0,0373 ; 0,0566] | compatible | 3 / 9, 1 |
| J1 (bords) | Lillie (haut) | F_T | V3b | 1925 | 0,1000 | 171 | 0,0888 [0,0765 ; 0,1024] | compatible | 5 / 4, 1 | 0,0500 | 90 | 0,0468 [0,0378 ; 0,0572] | compatible | 3 / 8, 1 |
| J1 (bords) | Lillie (haut) | F_T | V3h | 1925 | 0,1000 | 170 | 0,0883 [0,0760 ; 0,1019] | compatible | 0 / 0, 1 | 0,0500 | 95 | 0,0494 [0,0401 ; 0,0600] | compatible | 0 / 0, 1 |
| J1 (bords) | Intercept (deux) | F_T | V1 | 1925 | 0,1000 | 211 | 0,1096 [0,0960 ; 0,1244] | compatible | — | 0,0500 | 112 | 0,0582 [0,0481 ; 0,0696] | compatible | — |
| J1 (bords) | Intercept (deux) | F_T | V3a | 1925 | 0,1000 | 211 | 0,1096 [0,0960 ; 0,1244] | compatible | 14 / 14, 1 | 0,0500 | 106 | 0,0551 [0,0453 ; 0,0662] | compatible | 9 / 15, 1 |
| J1 (bords) | Intercept (deux) | F_T | V3b | 1925 | 0,1000 | 210 | 0,1091 [0,0955 ; 0,1239] | compatible | 16 / 17, 1 | 0,0500 | 105 | 0,0545 [0,0448 ; 0,0656] | compatible | 7 / 14, 1 |
| J1 (bords) | Intercept (deux) | F_T | V3h | 1925 | 0,1000 | 211 | 0,1096 [0,0960 ; 0,1244] | compatible | 0 / 0, 1 | 0,0500 | 112 | 0,0582 [0,0481 ; 0,0696] | compatible | 0 / 0, 1 |
| J1 (bords) | RESET (haut) | F_R | V1 | 1925 | 0,1000 | 218 | 0,1132 [0,0994 ; 0,1283] | compatible | — | 0,0500 | 111 | 0,0577 [0,0477 ; 0,0690] | compatible | — |
| J1 (bords) | RESET (haut) | F_R | V3a | 1925 | 0,1000 | 224 | 0,1164 [0,1024 ; 0,1315] | écart mineur | 17 / 11, 1 | 0,0500 | 109 | 0,0566 [0,0467 ; 0,0679] | compatible | 6 / 8, 1 |
| J1 (bords) | RESET (haut) | F_R | V3b | 1925 | 0,1000 | 222 | 0,1153 [0,1014 ; 0,1304] | écart mineur | 15 / 11, 1 | 0,0500 | 112 | 0,0582 [0,0481 ; 0,0696] | compatible | 8 / 7, 1 |
| J1 (bords) | RESET (haut) | F_R | V3h | 1925 | 0,1000 | 218 | 0,1132 [0,0994 ; 0,1283] | compatible | 0 / 0, 1 | 0,0500 | 111 | 0,0577 [0,0477 ; 0,0690] | compatible | 0 / 0, 1 |
| J1 (bords) | BP (haut) | F_R, F_8 | V1 | 1925 | 0,1000 | 191 | 0,0992 [0,0862 ; 0,1135] | compatible | — | 0,0500 | 95 | 0,0494 [0,0401 ; 0,0600] | compatible | — |
| J1 (bords) | BP (haut) | F_R, F_8 | V3a | 1925 | 0,1000 | 172 | 0,0894 [0,0770 ; 0,1030] | compatible | 1 / 20, 0,000441 | 0,0500 | 79 | 0,0410 [0,0326 ; 0,0509] | compatible | 2 / 18, 0,00845 |
| J1 (bords) | BP (haut) | F_R, F_8 | V3b | 1925 | 0,1000 | 172 | 0,0894 [0,0770 ; 0,1030] | compatible | 2 / 21, 0,00132 | 0,0500 | 83 | 0,0431 [0,0345 ; 0,0532] | compatible | 2 / 14, 0,0836 |
| J1 (bords) | BP (haut) | F_R, F_8 | V3h | 1925 | 0,1000 | 191 | 0,0992 [0,0862 ; 0,1135] | compatible | 0 / 0, 1 | 0,0500 | 95 | 0,0494 [0,0401 ; 0,0600] | compatible | 0 / 0, 1 |
| J1 (bords) | BP79 (haut) | F_R, F_8 | V1 | 1925 | 0,1000 | 184 | 0,0956 [0,0828 ; 0,1096] | compatible | — | 0,0500 | 94 | 0,0488 [0,0396 ; 0,0594] | compatible | — |
| J1 (bords) | BP79 (haut) | F_R, F_8 | V3a | 1925 | 0,1000 | 153 | 0,0795 [0,0678 ; 0,0925] | écart mineur | 1 / 32, 1,74e-07 | 0,0500 | 77 | 0,0400 [0,0317 ; 0,0497] | écart mineur | 0 / 17, 0,000336 |
| J1 (bords) | BP79 (haut) | F_R, F_8 | V3b | 1925 | 0,1000 | 155 | 0,0805 [0,0688 ; 0,0936] | écart mineur | 1 / 30, 6,56e-07 | 0,0500 | 77 | 0,0400 [0,0317 ; 0,0497] | écart mineur | 0 / 17, 0,000336 |
| J1 (bords) | BP79 (haut) | F_R, F_8 | V3h | 1925 | 0,1000 | 184 | 0,0956 [0,0828 ; 0,1096] | compatible | 0 / 0, 1 | 0,0500 | 94 | 0,0488 [0,0396 ; 0,0594] | compatible | 0 / 0, 1 |
| J1 (bords) | White (haut) | F_R | V1 | 1925 | 0,1000 | 201 | 0,1044 [0,0911 ; 0,1189] | compatible | — | 0,0500 | 93 | 0,0483 [0,0392 ; 0,0589] | compatible | — |
| J1 (bords) | White (haut) | F_R | V3a | 1925 | 0,1000 | 186 | 0,0966 [0,0838 ; 0,1107] | compatible | 4 / 19, 0,0494 | 0,0500 | 87 | 0,0452 [0,0364 ; 0,0555] | compatible | 3 / 9, 1 |
| J1 (bords) | White (haut) | F_R | V3b | 1925 | 0,1000 | 180 | 0,0935 [0,0809 ; 0,1074] | compatible | 3 / 24, 0,00103 | 0,0500 | 89 | 0,0462 [0,0373 ; 0,0566] | compatible | 4 / 8, 1 |
| J1 (bords) | White (haut) | F_R | V3h | 1925 | 0,1000 | 201 | 0,1044 [0,0911 ; 0,1189] | compatible | 0 / 0, 1 | 0,0500 | 93 | 0,0483 [0,0392 ; 0,0589] | compatible | 0 / 0, 1 |
| J1 (bords) | GQ (deux) | F_R, F_8 | V1 | 1925 | 0,1000 | 174 | 0,0904 [0,0780 ; 0,1041] | compatible | — | 0,0500 | 70 | 0,0364 [0,0285 ; 0,0457] | écart mineur | — |
| J1 (bords) | GQ (deux) | F_R, F_8 | V3a | 1925 | 0,1000 | 170 | 0,0883 [0,0760 ; 0,1019] | compatible | 96 / 100, 1 | 0,0500 | 80 | 0,0416 [0,0331 ; 0,0515] | compatible | 51 / 41, 1 |
| J1 (bords) | GQ (deux) | F_R, F_8 | V3b | 1925 | 0,1000 | 170 | 0,0883 [0,0760 ; 0,1019] | compatible | 97 / 101, 1 | 0,0500 | 72 | 0,0374 [0,0294 ; 0,0469] | écart mineur | 47 / 45, 1 |
| J1 (bords) | GQ (deux) | F_R, F_8 | V3h | 1925 | 0,1000 | 174 | 0,0904 [0,0780 ; 0,1041] | compatible | 0 / 0, 1 | 0,0500 | 70 | 0,0364 [0,0285 ; 0,0457] | écart mineur | 0 / 0, 1 |
| J1 (bords) | BF (haut) | F_R, F_8 | V1 | 1925 | 0,1000 | 193 | 0,1003 [0,0872 ; 0,1146] | compatible | — | 0,0500 | 99 | 0,0514 [0,0420 ; 0,0623] | compatible | — |
| J1 (bords) | BF (haut) | F_R, F_8 | V3a | 1925 | 0,1000 | 179 | 0,0930 [0,0804 ; 0,1068] | compatible | 0 / 14, 0,00244 | 0,0500 | 92 | 0,0478 [0,0387 ; 0,0583] | compatible | 3 / 10, 1 |
| J1 (bords) | BF (haut) | F_R, F_8 | V3b | 1925 | 0,1000 | 182 | 0,0945 [0,0818 ; 0,1085] | compatible | 3 / 14, 0,216 | 0,0500 | 91 | 0,0473 [0,0382 ; 0,0577] | compatible | 1 / 9, 0,408 |
| J1 (bords) | BF (haut) | F_R, F_8 | V3h | 1925 | 0,1000 | 193 | 0,1003 [0,0872 ; 0,1146] | compatible | 0 / 0, 1 | 0,0500 | 99 | 0,0514 [0,0420 ; 0,0623] | compatible | 0 / 0, 1 |
| J1 (bords) | Smirnov (haut) † | F_T | V1 | 1925 | 0,0286 | 63 | 0,0327 [0,0252 ; 0,0417] | compatible | — | 0,0286 | 63 | 0,0327 [0,0252 ; 0,0417] | compatible | — |
| J1 (bords) | Smirnov (haut) † | F_T | V3a | 1925 | 0,0286 | 63 | 0,0327 [0,0252 ; 0,0417] | compatible | 0 / 0, 1 | 0,0286 | 62 | 0,0322 [0,0248 ; 0,0411] | compatible | 0 / 1, 1 |
| J1 (bords) | Smirnov (haut) † | F_T | V3b | 1925 | 0,0286 | 63 | 0,0327 [0,0252 ; 0,0417] | compatible | 0 / 0, 1 | 0,0286 | 63 | 0,0327 [0,0252 ; 0,0417] | compatible | 0 / 0, 1 |
| J1 (bords) | Smirnov (haut) † | F_T | V3h | 1925 | 0,0286 | 63 | 0,0327 [0,0252 ; 0,0417] | compatible | 0 / 0, 1 | 0,0286 | 63 | 0,0327 [0,0252 ; 0,0417] | compatible | 0 / 0, 1 |
| J1 (bords) | LB2 (haut) | F_R | V1 | 1925 | 0,1000 | 197 | 0,1023 [0,0892 ; 0,1167] | compatible | — | 0,0500 | 93 | 0,0483 [0,0392 ; 0,0589] | compatible | — |
| J1 (bords) | LB2 (haut) | F_R | V3a | 1925 | 0,1000 | 195 | 0,1013 [0,0882 ; 0,1157] | compatible | 6 / 8, 1 | 0,0500 | 94 | 0,0488 [0,0396 ; 0,0594] | compatible | 5 / 4, 1 |
| J1 (bords) | LB2 (haut) | F_R | V3b | 1925 | 0,1000 | 199 | 0,1034 [0,0901 ; 0,1178] | compatible | 9 / 7, 1 | 0,0500 | 89 | 0,0462 [0,0373 ; 0,0566] | compatible | 3 / 7, 1 |
| J1 (bords) | LB2 (haut) | F_R | V3h | 1925 | 0,1000 | 197 | 0,1023 [0,0892 ; 0,1167] | compatible | 0 / 0, 1 | 0,0500 | 93 | 0,0483 [0,0392 ; 0,0589] | compatible | 0 / 0, 1 |
| J1 (bords) | BP2 (haut) | F_R | V1 | 1925 | 0,1000 | 195 | 0,1013 [0,0882 ; 0,1157] | compatible | — | 0,0500 | 97 | 0,0504 [0,0410 ; 0,0611] | compatible | — |
| J1 (bords) | BP2 (haut) | F_R | V3a | 1925 | 0,1000 | 191 | 0,0992 [0,0862 ; 0,1135] | compatible | 6 / 10, 1 | 0,0500 | 100 | 0,0519 [0,0425 ; 0,0628] | compatible | 6 / 3, 1 |
| J1 (bords) | BP2 (haut) | F_R | V3b | 1925 | 0,1000 | 191 | 0,0992 [0,0862 ; 0,1135] | compatible | 5 / 9, 1 | 0,0500 | 97 | 0,0504 [0,0410 ; 0,0611] | compatible | 5 / 5, 1 |
| J1 (bords) | BP2 (haut) | F_R | V3h | 1925 | 0,1000 | 195 | 0,1013 [0,0882 ; 0,1157] | compatible | 0 / 0, 1 | 0,0500 | 97 | 0,0504 [0,0410 ; 0,0611] | compatible | 0 / 0, 1 |
| J1 (bords) | Runs (deux) † | F_T | V1 | 1925 | 0,0571 | 123 | 0,0639 [0,0534 ; 0,0758] | compatible | — | 0,0097 | 18 | 0,0094 [0,0056 ; 0,0147] | compatible | — |
| J1 (bords) | Runs (deux) † | F_T | V3a | 1925 | 0,0571 | 121 | 0,0629 [0,0524 ; 0,0746] | compatible | 0 / 2, 1 | 0,0097 | 34 | 0,0177 [0,0123 ; 0,0246] | écart non tranché | 21 / 5, 0,0274 |
| J1 (bords) | Runs (deux) † | F_T | V3b | 1925 | 0,0571 | 123 | 0,0639 [0,0534 ; 0,0758] | compatible | 0 / 0, 1 | 0,0097 | 20 | 0,0104 [0,0064 ; 0,0160] | compatible | 14 / 12, 1 |
| J1 (bords) | Runs (deux) † | F_T | V3h | 1925 | 0,0571 | 123 | 0,0639 [0,0534 ; 0,0758] | compatible | 0 / 0, 1 | 0,0097 | 18 | 0,0094 [0,0056 ; 0,0147] | compatible | 0 / 0, 1 |
| J1 (bords) | MK (deux) † | F_R | V1 | 1925 | 0,0711 | 143 | 0,0743 [0,0630 ; 0,0869] | compatible | — | 0,0336 | 78 | 0,0405 [0,0322 ; 0,0503] | compatible | — |
| J1 (bords) | MK (deux) † | F_R | V3a | 1925 | 0,0711 | 156 | 0,0810 [0,0692 ; 0,0941] | compatible | 18 / 5, 0,181 | 0,0336 | 81 | 0,0421 [0,0336 ; 0,0520] | écart mineur | 6 / 3, 1 |
| J1 (bords) | MK (deux) † | F_R | V3b | 1925 | 0,0711 | 155 | 0,0805 [0,0688 ; 0,0936] | compatible | 19 / 7, 0,463 | 0,0336 | 75 | 0,0390 [0,0308 ; 0,0486] | compatible | 7 / 10, 1 |
| J1 (bords) | MK (deux) † | F_R | V3h | 1925 | 0,0711 | 143 | 0,0743 [0,0630 ; 0,0869] | compatible | 0 / 0, 1 | 0,0336 | 78 | 0,0405 [0,0322 ; 0,0503] | compatible | 0 / 0, 1 |
| J1 (bords) | SpearVol (deux) † | F_R | V1 | 1925 | 0,0904 | 176 | 0,0914 [0,0789 ; 0,1052] | compatible | — | 0,0430 | 100 | 0,0519 [0,0425 ; 0,0628] | compatible | — |
| J1 (bords) | SpearVol (deux) † | F_R | V3a | 1925 | 0,0904 | 180 | 0,0935 [0,0809 ; 0,1074] | compatible | 21 / 17, 1 | 0,0430 | 98 | 0,0509 [0,0415 ; 0,0617] | compatible | 7 / 9, 1 |
| J1 (bords) | SpearVol (deux) † | F_R | V3b | 1925 | 0,0904 | 183 | 0,0951 [0,0823 ; 0,1091] | compatible | 21 / 14, 1 | 0,0430 | 98 | 0,0509 [0,0415 ; 0,0617] | compatible | 7 / 9, 1 |
| J1 (bords) | SpearVol (deux) † | F_R | V3h | 1925 | 0,0904 | 176 | 0,0914 [0,0789 ; 0,1052] | compatible | 0 / 0, 1 | 0,0430 | 100 | 0,0519 [0,0425 ; 0,0628] | compatible | 0 / 0, 1 |
| J1 (bords) | SpearTps (deux) † | F_R | V1 | 1925 | 0,0904 | 184 | 0,0956 [0,0828 ; 0,1096] | compatible | — | 0,0430 | 95 | 0,0494 [0,0401 ; 0,0600] | compatible | — |
| J1 (bords) | SpearTps (deux) † | F_R | V3a | 1925 | 0,0904 | 182 | 0,0945 [0,0818 ; 0,1085] | compatible | 11 / 13, 1 | 0,0430 | 94 | 0,0488 [0,0396 ; 0,0594] | compatible | 8 / 9, 1 |
| J1 (bords) | SpearTps (deux) † | F_R | V3b | 1925 | 0,0904 | 181 | 0,0940 [0,0814 ; 0,1079] | compatible | 11 / 14, 1 | 0,0430 | 90 | 0,0468 [0,0378 ; 0,0572] | compatible | 6 / 11, 1 |
| J1 (bords) | SpearTps (deux) † | F_R | V3h | 1925 | 0,0904 | 184 | 0,0956 [0,0828 ; 0,1096] | compatible | 0 / 0, 1 | 0,0430 | 95 | 0,0494 [0,0401 ; 0,0600] | compatible | 0 / 0, 1 |
| J1 (bords) | DAgo (deux) | F_R, F_8 | V1 | 1925 | 0,1000 | 179 | 0,0930 [0,0804 ; 0,1068] | compatible | — | 0,0500 | 87 | 0,0452 [0,0364 ; 0,0555] | compatible | — |
| J1 (bords) | DAgo (deux) | F_R, F_8 | V3a | 1925 | 0,1000 | 173 | 0,0899 [0,0775 ; 0,1035] | compatible | 9 / 15, 1 | 0,0500 | 82 | 0,0426 [0,0340 ; 0,0526] | compatible | 4 / 9, 1 |
| J1 (bords) | DAgo (deux) | F_R, F_8 | V3b | 1925 | 0,1000 | 169 | 0,0878 [0,0755 ; 0,1013] | compatible | 9 / 19, 1 | 0,0500 | 85 | 0,0442 [0,0354 ; 0,0543] | compatible | 5 / 7, 1 |
| J1 (bords) | DAgo (deux) | F_R, F_8 | V3h | 1925 | 0,1000 | 179 | 0,0930 [0,0804 ; 0,1068] | compatible | 0 / 0, 1 | 0,0500 | 87 | 0,0452 [0,0364 ; 0,0555] | compatible | 0 / 0, 1 |
| J1 (bords) | CoxStuart (haut) † | F_T | V1 | 1925 | 0,0006 | 0 | 0,0000 [0,0000 ; 0,0019] | compatible | — | 0,0000 | 0 | 0,0000 [0,0000 ; 0,0019] | compatible | — |
| J1 (bords) | CoxStuart (haut) † | F_T | V3a | 1925 | 0,0006 | 7 | 0,0036 [0,0015 ; 0,0075] | écart à examiner (bande non applicable) | 7 / 0, 0,188 | 0,0000 | 0 | 0,0000 [0,0000 ; 0,0019] | compatible | 0 / 0, 1 |
| J1 (bords) | CoxStuart (haut) † | F_T | V3b | 1925 | 0,0006 | 2 | 0,0010 [0,0001 ; 0,0037] | compatible | 2 / 0, 1 | 0,0000 | 0 | 0,0000 [0,0000 ; 0,0019] | compatible | 0 / 0, 1 |
| J1 (bords) | CoxStuart (haut) † | F_T | V3h | 1925 | 0,0006 | 0 | 0,0000 [0,0000 ; 0,0019] | compatible | 0 / 0, 1 | 0,0000 | 0 | 0,0000 [0,0000 ; 0,0019] | compatible | 0 / 0, 1 |
| J1 (bords) | DWr (deux) | F_R | V1 | 1925 | 0,1000 | 213 | 0,1106 [0,0970 ; 0,1255] | compatible | — | 0,0500 | 98 | 0,0509 [0,0415 ; 0,0617] | compatible | — |
| J1 (bords) | DWr (deux) | F_R | V3a | 1925 | 0,1000 | 208 | 0,1081 [0,0945 ; 0,1228] | compatible | 8 / 13, 1 | 0,0500 | 101 | 0,0525 [0,0429 ; 0,0634] | compatible | 11 / 8, 1 |
| J1 (bords) | DWr (deux) | F_R | V3b | 1925 | 0,1000 | 209 | 0,1086 [0,0950 ; 0,1233] | compatible | 7 / 11, 1 | 0,0500 | 97 | 0,0504 [0,0410 ; 0,0611] | compatible | 7 / 8, 1 |
| J1 (bords) | DWr (deux) | F_R | V3h | 1925 | 0,1000 | 213 | 0,1106 [0,0970 ; 0,1255] | compatible | 0 / 0, 1 | 0,0500 | 98 | 0,0509 [0,0415 ; 0,0617] | compatible | 0 / 0, 1 |
| J1 (bords) | LB1r (haut) | F_R | V1 | 1925 | 0,1000 | 202 | 0,1049 [0,0916 ; 0,1195] | compatible | — | 0,0500 | 99 | 0,0514 [0,0420 ; 0,0623] | compatible | — |
| J1 (bords) | LB1r (haut) | F_R | V3a | 1925 | 0,1000 | 193 | 0,1003 [0,0872 ; 0,1146] | compatible | 4 / 13, 0,736 | 0,0500 | 101 | 0,0525 [0,0429 ; 0,0634] | compatible | 6 / 4, 1 |
| J1 (bords) | LB1r (haut) | F_R | V3b | 1925 | 0,1000 | 199 | 0,1034 [0,0901 ; 0,1178] | compatible | 7 / 10, 1 | 0,0500 | 99 | 0,0514 [0,0420 ; 0,0623] | compatible | 6 / 6, 1 |
| J1 (bords) | LB1r (haut) | F_R | V3h | 1925 | 0,1000 | 202 | 0,1049 [0,0916 ; 0,1195] | compatible | 0 / 0, 1 | 0,0500 | 99 | 0,0514 [0,0420 ; 0,0623] | compatible | 0 / 0, 1 |
| J1 (bords) | Runsr (deux) † | F_T | V1 | 1925 | 0,0571 | 122 | 0,0634 [0,0529 ; 0,0752] | compatible | — | 0,0097 | 18 | 0,0094 [0,0056 ; 0,0147] | compatible | — |
| J1 (bords) | Runsr (deux) † | F_T | V3a | 1925 | 0,0571 | 120 | 0,0623 [0,0520 ; 0,0741] | compatible | 0 / 2, 1 | 0,0097 | 36 | 0,0187 [0,0131 ; 0,0258] | écart non tranché | 23 / 5, 0,0109 |
| J1 (bords) | Runsr (deux) † | F_T | V3b | 1925 | 0,0571 | 122 | 0,0634 [0,0529 ; 0,0752] | compatible | 0 / 0, 1 | 0,0097 | 21 | 0,0109 [0,0068 ; 0,0166] | compatible | 14 / 11, 1 |
| J1 (bords) | Runsr (deux) † | F_T | V3h | 1925 | 0,0571 | 122 | 0,0634 [0,0529 ; 0,0752] | compatible | 0 / 0, 1 | 0,0097 | 18 | 0,0094 [0,0056 ; 0,0147] | compatible | 0 / 0, 1 |
| J1 (bords) | supFr (haut) | F_R | V1 | 1925 | 0,1000 | 200 | 0,1039 [0,0906 ; 0,1184] | compatible | — | 0,0500 | 104 | 0,0540 [0,0444 ; 0,0651] | compatible | — |
| J1 (bords) | supFr (haut) | F_R | V3a | 1925 | 0,1000 | 189 | 0,0982 [0,0852 ; 0,1124] | compatible | 5 / 16, 0,426 | 0,0500 | 108 | 0,0561 [0,0462 ; 0,0673] | compatible | 6 / 2, 1 |
| J1 (bords) | supFr (haut) | F_R | V3b | 1925 | 0,1000 | 192 | 0,0997 [0,0867 ; 0,1140] | compatible | 6 / 14, 1 | 0,0500 | 104 | 0,0540 [0,0444 ; 0,0651] | compatible | 4 / 4, 1 |
| J1 (bords) | supFr (haut) | F_R | V3h | 1925 | 0,1000 | 200 | 0,1039 [0,0906 ; 0,1184] | compatible | 0 / 0, 1 | 0,0500 | 104 | 0,0540 [0,0444 ; 0,0651] | compatible | 0 / 0, 1 |
| J1 (bords) | CUSUMr (haut) | F_R | V1 | 1925 | 0,1000 | 208 | 0,1081 [0,0945 ; 0,1228] | compatible | — | 0,0500 | 100 | 0,0519 [0,0425 ; 0,0628] | compatible | — |
| J1 (bords) | CUSUMr (haut) | F_R | V3a | 1925 | 0,1000 | 209 | 0,1086 [0,0950 ; 0,1233] | compatible | 10 / 9, 1 | 0,0500 | 95 | 0,0494 [0,0401 ; 0,0600] | compatible | 0 / 5, 1 |
| J1 (bords) | CUSUMr (haut) | F_R | V3b | 1925 | 0,1000 | 206 | 0,1070 [0,0936 ; 0,1217] | compatible | 7 / 9, 1 | 0,0500 | 93 | 0,0483 [0,0392 ; 0,0589] | compatible | 3 / 10, 1 |
| J1 (bords) | CUSUMr (haut) | F_R | V3h | 1925 | 0,1000 | 208 | 0,1081 [0,0945 ; 0,1228] | compatible | 0 / 0, 1 | 0,0500 | 100 | 0,0519 [0,0425 ; 0,0628] | compatible | 0 / 0, 1 |
| J1 (bords) | Grubbsr (haut) | F_R, F_8 | V1 | 1925 | 0,1000 | 201 | 0,1044 [0,0911 ; 0,1189] | compatible | — | 0,0500 | 98 | 0,0509 [0,0415 ; 0,0617] | compatible | — |
| J1 (bords) | Grubbsr (haut) | F_R, F_8 | V3a | 1925 | 0,1000 | 192 | 0,0997 [0,0867 ; 0,1140] | compatible | 4 / 13, 0,736 | 0,0500 | 89 | 0,0462 [0,0373 ; 0,0566] | compatible | 2 / 11, 0,449 |
| J1 (bords) | Grubbsr (haut) | F_R, F_8 | V3b | 1925 | 0,1000 | 189 | 0,0982 [0,0852 ; 0,1124] | compatible | 0 / 12, 0,00928 | 0,0500 | 90 | 0,0468 [0,0378 ; 0,0572] | compatible | 3 / 11, 1 |
| J1 (bords) | Grubbsr (haut) | F_R, F_8 | V3h | 1925 | 0,1000 | 201 | 0,1044 [0,0911 ; 0,1189] | compatible | 0 / 0, 1 | 0,0500 | 98 | 0,0509 [0,0415 ; 0,0617] | compatible | 0 / 0, 1 |
| J2 | AD (haut) | F_T | V1 | 2000 | 0,1000 | 204 | 0,1020 [0,0891 ; 0,1161] | compatible | — | 0,0500 | 90 | 0,0450 [0,0363 ; 0,0550] | compatible | — |
| J2 | AD (haut) | F_T | V3a | 2000 | 0,1000 | 200 | 0,1000 [0,0872 ; 0,1140] | compatible | 10 / 14, 1 | 0,0500 | 87 | 0,0435 [0,0350 ; 0,0534] | compatible | 5 / 8, 1 |
| J2 | AD (haut) | F_T | V3b | 2000 | 0,1000 | 200 | 0,1000 [0,0872 ; 0,1140] | compatible | 5 / 9, 1 | 0,0500 | 84 | 0,0420 [0,0336 ; 0,0517] | compatible | 3 / 9, 1 |
| J2 | AD (haut) | F_T | V3h | 2000 | 0,1000 | 204 | 0,1020 [0,0891 ; 0,1161] | compatible | 2 / 2, 1 | 0,0500 | 90 | 0,0450 [0,0363 ; 0,0550] | compatible | 2 / 2, 1 |
| J2 | CvM (haut) | F_T | V1 | 2000 | 0,1000 | 194 | 0,0970 [0,0844 ; 0,1108] | compatible | — | 0,0500 | 93 | 0,0465 [0,0377 ; 0,0567] | compatible | — |
| J2 | CvM (haut) | F_T | V3a | 2000 | 0,1000 | 197 | 0,0985 [0,0858 ; 0,1124] | compatible | 11 / 8, 1 | 0,0500 | 93 | 0,0465 [0,0377 ; 0,0567] | compatible | 3 / 3, 1 |
| J2 | CvM (haut) | F_T | V3b | 2000 | 0,1000 | 191 | 0,0955 [0,0830 ; 0,1092] | compatible | 7 / 10, 1 | 0,0500 | 93 | 0,0465 [0,0377 ; 0,0567] | compatible | 5 / 5, 1 |
| J2 | CvM (haut) | F_T | V3h | 2000 | 0,1000 | 187 | 0,0935 [0,0811 ; 0,1071] | compatible | 0 / 7, 0,156 | 0,0500 | 94 | 0,0470 [0,0381 ; 0,0572] | compatible | 3 / 2, 1 |
| J2 | KS (haut) | F_T | V1 | 2000 | 0,1000 | 180 | 0,0900 [0,0778 ; 0,1034] | compatible | — | 0,0500 | 92 | 0,0460 [0,0372 ; 0,0561] | compatible | — |
| J2 | KS (haut) | F_T | V3a | 2000 | 0,1000 | 177 | 0,0885 [0,0764 ; 0,1018] | compatible | 10 / 13, 1 | 0,0500 | 85 | 0,0425 [0,0341 ; 0,0523] | compatible | 1 / 8, 0,43 |
| J2 | KS (haut) | F_T | V3b | 2000 | 0,1000 | 177 | 0,0885 [0,0764 ; 0,1018] | compatible | 8 / 11, 1 | 0,0500 | 88 | 0,0440 [0,0354 ; 0,0539] | compatible | 1 / 5, 1 |
| J2 | KS (haut) | F_T | V3h | 2000 | 0,1000 | 177 | 0,0885 [0,0764 ; 0,1018] | compatible | 1 / 4, 1 | 0,0500 | 91 | 0,0455 [0,0368 ; 0,0556] | compatible | 0 / 1, 1 |
| J2 | SW (bas) | F_T | V1 | 2000 | 0,1000 | 189 | 0,0945 [0,0820 ; 0,1082] | compatible | — | 0,0500 | 89 | 0,0445 [0,0359 ; 0,0545] | compatible | — |
| J2 | SW (bas) | F_T | V3a | 2000 | 0,1000 | 185 | 0,0925 [0,0802 ; 0,1061] | compatible | 7 / 11, 1 | 0,0500 | 90 | 0,0450 [0,0363 ; 0,0550] | compatible | 5 / 4, 1 |
| J2 | SW (bas) | F_T | V3b | 2000 | 0,1000 | 183 | 0,0915 [0,0792 ; 0,1050] | compatible | 6 / 12, 1 | 0,0500 | 91 | 0,0455 [0,0368 ; 0,0556] | compatible | 4 / 2, 1 |
| J2 | SW (bas) | F_T | V3h | 2000 | 0,1000 | 192 | 0,0960 [0,0834 ; 0,1098] | compatible | 4 / 1, 1 | 0,0500 | 92 | 0,0460 [0,0372 ; 0,0561] | compatible | 3 / 0, 1 |
| J2 | SF (bas) | F_R | V1 | 2000 | 0,1000 | 170 | 0,0850 [0,0731 ; 0,0981] | écart mineur | — | 0,0500 | 92 | 0,0460 [0,0372 ; 0,0561] | compatible | — |
| J2 | SF (bas) | F_R | V3a | 2000 | 0,1000 | 166 | 0,0830 [0,0713 ; 0,0960] | écart mineur | 17 / 21, 1 | 0,0500 | 81 | 0,0405 [0,0323 ; 0,0501] | compatible | 6 / 17, 0,659 |
| J2 | SF (bas) | F_R | V3b | 2000 | 0,1000 | 160 | 0,0800 [0,0685 ; 0,0928] | écart mineur | 15 / 25, 1 | 0,0500 | 81 | 0,0405 [0,0323 ; 0,0501] | compatible | 6 / 17, 0,624 |
| J2 | SF (bas) | F_R | V3h | 2000 | 0,1000 | 185 | 0,0925 [0,0802 ; 0,1061] | compatible | 15 / 0, 0,000671 | 0,0500 | 98 | 0,0490 [0,0400 ; 0,0594] | compatible | 6 / 0, 0,375 |
| J2 | JB (haut) | F_R, F_8 | V1 | 2000 | 0,1000 | 170 | 0,0850 [0,0731 ; 0,0981] | écart mineur | — | 0,0500 | 81 | 0,0405 [0,0323 ; 0,0501] | compatible | — |
| J2 | JB (haut) | F_R, F_8 | V3a | 2000 | 0,1000 | 171 | 0,0855 [0,0736 ; 0,0986] | écart mineur | 35 / 34, 1 | 0,0500 | 80 | 0,0400 [0,0318 ; 0,0495] | écart mineur | 16 / 17, 1 |
| J2 | JB (haut) | F_R, F_8 | V3b | 2000 | 0,1000 | 169 | 0,0845 [0,0727 ; 0,0976] | écart mineur | 34 / 35, 1 | 0,0500 | 85 | 0,0425 [0,0341 ; 0,0523] | compatible | 17 / 13, 1 |
| J2 | JB (haut) | F_R, F_8 | V3h | 2000 | 0,1000 | 204 | 0,1020 [0,0891 ; 0,1161] | compatible | 34 / 0, 2,1e-09 | 0,0500 | 98 | 0,0490 [0,0400 ; 0,0594] | compatible | 17 / 0, 0,000229 |
| J2 | DW (deux) | F_R | V1 | 2000 | 0,1000 | 205 | 0,1025 [0,0895 ; 0,1166] | compatible | — | 0,0500 | 96 | 0,0480 [0,0391 ; 0,0583] | compatible | — |
| J2 | DW (deux) | F_R | V3a | 2000 | 0,1000 | 206 | 0,1030 [0,0900 ; 0,1172] | compatible | 27 / 26, 1 | 0,0500 | 108 | 0,0540 [0,0445 ; 0,0648] | compatible | 23 / 11, 1 |
| J2 | DW (deux) | F_R | V3b | 2000 | 0,1000 | 212 | 0,1060 [0,0928 ; 0,1203] | compatible | 30 / 23, 1 | 0,0500 | 107 | 0,0535 [0,0440 ; 0,0643] | compatible | 25 / 14, 1 |
| J2 | DW (deux) | F_R | V3h | 2000 | 0,1000 | 222 | 0,1110 [0,0976 ; 0,1256] | compatible | 17 / 0, 0,000198 | 0,0500 | 107 | 0,0535 [0,0440 ; 0,0643] | compatible | 11 / 0, 0,0127 |
| J2 | LB1 (haut) | F_T | V1 | 2000 | 0,1000 | 218 | 0,1090 [0,0957 ; 0,1235] | compatible | — | 0,0500 | 106 | 0,0530 [0,0436 ; 0,0637] | compatible | — |
| J2 | LB1 (haut) | F_T | V3a | 2000 | 0,1000 | 226 | 0,1130 [0,0994 ; 0,1277] | compatible | 17 / 9, 1 | 0,0500 | 101 | 0,0505 [0,0413 ; 0,0610] | compatible | 7 / 12, 1 |
| J2 | LB1 (haut) | F_T | V3b | 2000 | 0,1000 | 222 | 0,1110 [0,0976 ; 0,1256] | compatible | 14 / 10, 1 | 0,0500 | 100 | 0,0500 [0,0409 ; 0,0605] | compatible | 6 / 12, 1 |
| J2 | LB1 (haut) | F_T | V3h | 2000 | 0,1000 | 227 | 0,1135 [0,0999 ; 0,1282] | compatible | 9 / 0, 0,0469 | 0,0500 | 110 | 0,0550 [0,0454 ; 0,0659] | compatible | 5 / 1, 1 |
| J2 | supF (haut) | F_R | V1 | 2000 | 0,1000 | 187 | 0,0935 [0,0811 ; 0,1071] | compatible | — | 0,0500 | 103 | 0,0515 [0,0422 ; 0,0621] | compatible | — |
| J2 | supF (haut) | F_R | V3a | 2000 | 0,1000 | 184 | 0,0920 [0,0797 ; 0,1055] | compatible | 17 / 20, 1 | 0,0500 | 111 | 0,0555 [0,0459 ; 0,0665] | compatible | 12 / 4, 1 |
| J2 | supF (haut) | F_R | V3b | 2000 | 0,1000 | 181 | 0,0905 [0,0783 ; 0,1039] | compatible | 15 / 21, 1 | 0,0500 | 111 | 0,0555 [0,0459 ; 0,0665] | compatible | 14 / 6, 1 |
| J2 | supF (haut) | F_R | V3h | 2000 | 0,1000 | 190 | 0,0950 [0,0825 ; 0,1087] | compatible | 3 / 0, 1 | 0,0500 | 106 | 0,0530 [0,0436 ; 0,0637] | compatible | 3 / 0, 1 |
| J2 | CUSUM (haut) | F_T | V1 | 2000 | 0,1000 | 198 | 0,0990 [0,0863 ; 0,1129] | compatible | — | 0,0500 | 96 | 0,0480 [0,0391 ; 0,0583] | compatible | — |
| J2 | CUSUM (haut) | F_T | V3a | 2000 | 0,1000 | 198 | 0,0990 [0,0863 ; 0,1129] | compatible | 12 / 12, 1 | 0,0500 | 95 | 0,0475 [0,0386 ; 0,0578] | compatible | 5 / 6, 1 |
| J2 | CUSUM (haut) | F_T | V3b | 2000 | 0,1000 | 199 | 0,0995 [0,0867 ; 0,1135] | compatible | 13 / 12, 1 | 0,0500 | 102 | 0,0510 [0,0418 ; 0,0616] | compatible | 10 / 4, 1 |
| J2 | CUSUM (haut) | F_T | V3h | 2000 | 0,1000 | 198 | 0,0990 [0,0863 ; 0,1129] | compatible | 4 / 4, 1 | 0,0500 | 94 | 0,0470 [0,0381 ; 0,0572] | compatible | 1 / 3, 1 |
| J2 | Grubbs (haut) | F_R, F_8 | V1 | 2000 | 0,1000 | 167 | 0,0835 [0,0717 ; 0,0965] | écart mineur | — | 0,0500 | 83 | 0,0415 [0,0332 ; 0,0512] | compatible | — |
| J2 | Grubbs (haut) | F_R, F_8 | V3a | 2000 | 0,1000 | 167 | 0,0835 [0,0717 ; 0,0965] | écart mineur | 33 / 33, 1 | 0,0500 | 80 | 0,0400 [0,0318 ; 0,0495] | écart mineur | 19 / 22, 1 |
| J2 | Grubbs (haut) | F_R, F_8 | V3b | 2000 | 0,1000 | 169 | 0,0845 [0,0727 ; 0,0976] | écart mineur | 33 / 31, 1 | 0,0500 | 86 | 0,0430 [0,0345 ; 0,0528] | compatible | 20 / 17, 1 |
| J2 | Grubbs (haut) | F_R, F_8 | V3h | 2000 | 0,1000 | 200 | 0,1000 [0,0872 ; 0,1140] | compatible | 33 / 0, 3,73e-09 | 0,0500 | 103 | 0,0515 [0,0422 ; 0,0621] | compatible | 20 / 0, 3,24e-05 |
| J2 | Lillie (haut) | F_T | V1 | 2000 | 0,1000 | 176 | 0,0880 [0,0759 ; 0,1013] | compatible | — | 0,0500 | 96 | 0,0480 [0,0391 ; 0,0583] | compatible | — |
| J2 | Lillie (haut) | F_T | V3a | 2000 | 0,1000 | 175 | 0,0875 [0,0755 ; 0,1007] | compatible | 10 / 11, 1 | 0,0500 | 93 | 0,0465 [0,0377 ; 0,0567] | compatible | 8 / 11, 1 |
| J2 | Lillie (haut) | F_T | V3b | 2000 | 0,1000 | 172 | 0,0860 [0,0741 ; 0,0992] | écart mineur | 9 / 13, 1 | 0,0500 | 87 | 0,0435 [0,0350 ; 0,0534] | compatible | 5 / 14, 0,763 |
| J2 | Lillie (haut) | F_T | V3h | 2000 | 0,1000 | 184 | 0,0920 [0,0797 ; 0,1055] | compatible | 8 / 0, 0,0859 | 0,0500 | 101 | 0,0505 [0,0413 ; 0,0610] | compatible | 5 / 0, 0,75 |
| J2 | Intercept (deux) | F_T | V1 | 2000 | 0,1000 | 195 | 0,0975 [0,0848 ; 0,1113] | compatible | — | 0,0500 | 107 | 0,0535 [0,0440 ; 0,0643] | compatible | — |
| J2 | Intercept (deux) | F_T | V3a | 2000 | 0,1000 | 207 | 0,1035 [0,0905 ; 0,1177] | compatible | 20 / 8, 0,393 | 0,0500 | 108 | 0,0540 [0,0445 ; 0,0648] | compatible | 10 / 9, 1 |
| J2 | Intercept (deux) | F_T | V3b | 2000 | 0,1000 | 199 | 0,0995 [0,0867 ; 0,1135] | compatible | 17 / 13, 1 | 0,0500 | 112 | 0,0560 [0,0463 ; 0,0670] | compatible | 13 / 8, 1 |
| J2 | Intercept (deux) | F_T | V3h | 2000 | 0,1000 | 190 | 0,0950 [0,0825 ; 0,1087] | compatible | 1 / 6, 1 | 0,0500 | 104 | 0,0520 [0,0427 ; 0,0627] | compatible | 1 / 4, 1 |
| J2 | RESET (haut) | F_R | V1 | 2000 | 0,1000 | 166 | 0,0830 [0,0713 ; 0,0960] | écart mineur | — | 0,0500 | 65 | 0,0325 [0,0252 ; 0,0412] | écart mineur | — |
| J2 | RESET (haut) | F_R | V3a | 2000 | 0,1000 | 171 | 0,0855 [0,0736 ; 0,0986] | écart mineur | 62 / 57, 1 | 0,0500 | 87 | 0,0435 [0,0350 ; 0,0534] | compatible | 41 / 19, 0,124 |
| J2 | RESET (haut) | F_R | V3b | 2000 | 0,1000 | 173 | 0,0865 [0,0745 ; 0,0997] | écart mineur | 59 / 52, 1 | 0,0500 | 88 | 0,0440 [0,0354 ; 0,0539] | compatible | 42 / 19, 0,0889 |
| J2 | RESET (haut) | F_R | V3h | 2000 | 0,1000 | 151 | 0,0755 [0,0643 ; 0,0880] | écart mineur | 0 / 15, 0,000671 | 0,0500 | 70 | 0,0350 [0,0274 ; 0,0440] | écart mineur | 7 / 2, 1 |
| J2 | BP (haut) | F_R, F_8 | V1 | 2000 | 0,1000 | 170 | 0,0850 [0,0731 ; 0,0981] | écart mineur | — | 0,0500 | 74 | 0,0370 [0,0292 ; 0,0462] | écart mineur | — |
| J2 | BP (haut) | F_R, F_8 | V3a | 2000 | 0,1000 | 154 | 0,0770 [0,0657 ; 0,0896] | écart mineur | 47 / 63, 1 | 0,0500 | 73 | 0,0365 [0,0287 ; 0,0457] | écart mineur | 24 / 25, 1 |
| J2 | BP (haut) | F_R, F_8 | V3b | 2000 | 0,1000 | 156 | 0,0780 [0,0666 ; 0,0906] | écart mineur | 49 / 63, 1 | 0,0500 | 76 | 0,0380 [0,0301 ; 0,0473] | écart mineur | 27 / 25, 1 |
| J2 | BP (haut) | F_R, F_8 | V3h | 2000 | 0,1000 | 219 | 0,1095 [0,0961 ; 0,1240] | compatible | 49 / 0, 7,82e-14 | 0,0500 | 98 | 0,0490 [0,0400 ; 0,0594] | compatible | 24 / 0, 2,62e-06 |
| J2 | BP79 (haut) | F_R, F_8 | V1 | 2000 | 0,1000 | 151 | 0,0755 [0,0643 ; 0,0880] | écart mineur | — | 0,0500 | 73 | 0,0365 [0,0287 ; 0,0457] | écart mineur | — |
| J2 | BP79 (haut) | F_R, F_8 | V3a | 2000 | 0,1000 | 136 | 0,0680 [0,0574 ; 0,0799] | écart mineur | 41 / 56, 1 | 0,0500 | 69 | 0,0345 [0,0269 ; 0,0435] | écart mineur | 20 / 24, 1 |
| J2 | BP79 (haut) | F_R, F_8 | V3b | 2000 | 0,1000 | 137 | 0,0685 [0,0578 ; 0,0805] | écart mineur | 42 / 56, 1 | 0,0500 | 71 | 0,0355 [0,0278 ; 0,0446] | écart mineur | 24 / 26, 1 |
| J2 | BP79 (haut) | F_R, F_8 | V3h | 2000 | 0,1000 | 193 | 0,0965 [0,0839 ; 0,1103] | compatible | 42 / 0, 8,64e-12 | 0,0500 | 97 | 0,0485 [0,0395 ; 0,0588] | compatible | 24 / 0, 2,62e-06 |
| J2 | White (haut) | F_R | V1 | 2000 | 0,1000 | 176 | 0,0880 [0,0759 ; 0,1013] | compatible | — | 0,0500 | 80 | 0,0400 [0,0318 ; 0,0495] | écart mineur | — |
| J2 | White (haut) | F_R | V3a | 2000 | 0,1000 | 165 | 0,0825 [0,0708 ; 0,0954] | écart mineur | 24 / 35, 1 | 0,0500 | 72 | 0,0360 [0,0283 ; 0,0451] | écart mineur | 16 / 24, 1 |
| J2 | White (haut) | F_R | V3b | 2000 | 0,1000 | 162 | 0,0810 [0,0694 ; 0,0938] | écart mineur | 22 / 36, 1 | 0,0500 | 72 | 0,0360 [0,0283 ; 0,0451] | écart mineur | 18 / 26, 1 |
| J2 | White (haut) | F_R | V3h | 2000 | 0,1000 | 178 | 0,0890 [0,0769 ; 0,1023] | compatible | 4 / 2, 1 | 0,0500 | 84 | 0,0420 [0,0336 ; 0,0517] | compatible | 5 / 1, 1 |
| J2 | GQ (deux) | F_R, F_8 | V1 | 2000 | 0,1000 | 109 | 0,0545 [0,0450 ; 0,0654] | écart mineur | — | 0,0500 | 58 | 0,0290 [0,0221 ; 0,0373] | écart mineur | — |
| J2 | GQ (deux) | F_R, F_8 | V3a | 2000 | 0,1000 | 204 | 0,1020 [0,0891 ; 0,1161] | compatible | 137 / 42, 1,3e-11 | 0,0500 | 97 | 0,0485 [0,0395 ; 0,0588] | compatible | 61 / 22, 0,00048 |
| J2 | GQ (deux) | F_R, F_8 | V3b | 2000 | 0,1000 | 200 | 0,1000 [0,0872 ; 0,1140] | compatible | 132 / 41, 5,21e-11 | 0,0500 | 99 | 0,0495 [0,0404 ; 0,0599] | compatible | 62 / 21, 0,000165 |
| J2 | GQ (deux) | F_R, F_8 | V3h | 2000 | 0,1000 | 158 | 0,0790 [0,0676 ; 0,0917] | écart mineur | 49 / 0, 7,82e-14 | 0,0500 | 81 | 0,0405 [0,0323 ; 0,0501] | compatible | 23 / 0, 4,77e-06 |
| J2 | BF (haut) | F_R, F_8 | V1 | 2000 | 0,1000 | 172 | 0,0860 [0,0741 ; 0,0992] | écart mineur | — | 0,0500 | 91 | 0,0455 [0,0368 ; 0,0556] | compatible | — |
| J2 | BF (haut) | F_R, F_8 | V3a | 2000 | 0,1000 | 173 | 0,0865 [0,0745 ; 0,0997] | écart mineur | 47 / 46, 1 | 0,0500 | 89 | 0,0445 [0,0359 ; 0,0545] | compatible | 21 / 23, 1 |
| J2 | BF (haut) | F_R, F_8 | V3b | 2000 | 0,1000 | 175 | 0,0875 [0,0755 ; 0,1007] | compatible | 47 / 44, 1 | 0,0500 | 91 | 0,0455 [0,0368 ; 0,0556] | compatible | 22 / 22, 1 |
| J2 | BF (haut) | F_R, F_8 | V3h | 2000 | 0,1000 | 219 | 0,1095 [0,0961 ; 0,1240] | compatible | 47 / 0, 2,84e-13 | 0,0500 | 113 | 0,0565 [0,0468 ; 0,0675] | compatible | 22 / 0, 9,06e-06 |
| J2 | Smirnov (haut) † | F_T | V1 | 2000 | 0,0286 | 55 | 0,0275 [0,0208 ; 0,0356] | compatible | — | 0,0286 | 55 | 0,0275 [0,0208 ; 0,0356] | compatible | — |
| J2 | Smirnov (haut) † | F_T | V3a | 2000 | 0,0286 | 58 | 0,0290 [0,0221 ; 0,0373] | compatible | 3 / 0, 1 | 0,0286 | 55 | 0,0275 [0,0208 ; 0,0356] | compatible | 0 / 0, 1 |
| J2 | Smirnov (haut) † | F_T | V3b | 2000 | 0,0286 | 55 | 0,0275 [0,0208 ; 0,0356] | compatible | 0 / 0, 1 | 0,0286 | 55 | 0,0275 [0,0208 ; 0,0356] | compatible | 0 / 0, 1 |
| J2 | Smirnov (haut) † | F_T | V3h | 2000 | 0,0286 | 55 | 0,0275 [0,0208 ; 0,0356] | compatible | 0 / 0, 1 | 0,0286 | 55 | 0,0275 [0,0208 ; 0,0356] | compatible | 0 / 0, 1 |
| J2 | LB2 (haut) | F_R | V1 | 2000 | 0,1000 | 213 | 0,1065 [0,0933 ; 0,1209] | compatible | — | 0,0500 | 106 | 0,0530 [0,0436 ; 0,0637] | compatible | — |
| J2 | LB2 (haut) | F_R | V3a | 2000 | 0,1000 | 201 | 0,1005 [0,0877 ; 0,1145] | compatible | 19 / 31, 1 | 0,0500 | 109 | 0,0545 [0,0450 ; 0,0654] | compatible | 14 / 11, 1 |
| J2 | LB2 (haut) | F_R | V3b | 2000 | 0,1000 | 196 | 0,0980 [0,0853 ; 0,1119] | compatible | 16 / 33, 0,426 | 0,0500 | 108 | 0,0540 [0,0445 ; 0,0648] | compatible | 14 / 12, 1 |
| J2 | LB2 (haut) | F_R | V3h | 2000 | 0,1000 | 202 | 0,1010 [0,0881 ; 0,1150] | compatible | 0 / 11, 0,00879 | 0,0500 | 101 | 0,0505 [0,0413 ; 0,0610] | compatible | 0 / 5, 0,625 |
| J2 | BP2 (haut) | F_R | V1 | 2000 | 0,1000 | 208 | 0,1040 [0,0910 ; 0,1182] | compatible | — | 0,0500 | 106 | 0,0530 [0,0436 ; 0,0637] | compatible | — |
| J2 | BP2 (haut) | F_R | V3a | 2000 | 0,1000 | 205 | 0,1025 [0,0895 ; 0,1166] | compatible | 17 / 20, 1 | 0,0500 | 110 | 0,0550 [0,0454 ; 0,0659] | compatible | 16 / 12, 1 |
| J2 | BP2 (haut) | F_R | V3b | 2000 | 0,1000 | 203 | 0,1015 [0,0886 ; 0,1156] | compatible | 17 / 22, 1 | 0,0500 | 112 | 0,0560 [0,0463 ; 0,0670] | compatible | 16 / 10, 1 |
| J2 | BP2 (haut) | F_R | V3h | 2000 | 0,1000 | 205 | 0,1025 [0,0895 ; 0,1166] | compatible | 0 / 3, 1 | 0,0500 | 102 | 0,0510 [0,0418 ; 0,0616] | compatible | 1 / 5, 1 |
| J2 | Runs (deux) † | F_T | V1 | 2000 | 0,0571 | 127 | 0,0635 [0,0532 ; 0,0751] | compatible | — | 0,0097 | 15 | 0,0075 [0,0042 ; 0,0123] | compatible | — |
| J2 | Runs (deux) † | F_T | V3a | 2000 | 0,0571 | 122 | 0,0610 [0,0509 ; 0,0724] | compatible | 1 / 6, 1 | 0,0097 | 29 | 0,0145 [0,0097 ; 0,0208] | écart mineur | 16 / 2, 0,0157 |
| J2 | Runs (deux) † | F_T | V3b | 2000 | 0,0571 | 127 | 0,0635 [0,0532 ; 0,0751] | compatible | 0 / 0, 1 | 0,0097 | 19 | 0,0095 [0,0057 ; 0,0148] | compatible | 14 / 10, 1 |
| J2 | Runs (deux) † | F_T | V3h | 2000 | 0,0571 | 127 | 0,0635 [0,0532 ; 0,0751] | compatible | 0 / 0, 1 | 0,0097 | 13 | 0,0065 [0,0035 ; 0,0111] | compatible | 1 / 3, 1 |
| J2 | MK (deux) † | F_R | V1 | 2000 | 0,0711 | 130 | 0,0650 [0,0546 ; 0,0767] | compatible | — | 0,0336 | 58 | 0,0290 [0,0221 ; 0,0373] | compatible | — |
| J2 | MK (deux) † | F_R | V3a | 2000 | 0,0711 | 143 | 0,0715 [0,0606 ; 0,0837] | compatible | 36 / 23, 1 | 0,0336 | 71 | 0,0355 [0,0278 ; 0,0446] | compatible | 29 / 16, 1 |
| J2 | MK (deux) † | F_R | V3b | 2000 | 0,0711 | 151 | 0,0755 [0,0643 ; 0,0880] | compatible | 38 / 17, 0,136 | 0,0336 | 75 | 0,0375 [0,0296 ; 0,0468] | compatible | 30 / 13, 0,261 |
| J2 | MK (deux) † | F_R | V3h | 2000 | 0,0711 | 127 | 0,0635 [0,0532 ; 0,0751] | compatible | 2 / 5, 1 | 0,0336 | 59 | 0,0295 [0,0225 ; 0,0379] | compatible | 3 / 2, 1 |
| J2 | SpearVol (deux) † | F_R | V1 | 2000 | 0,0904 | 193 | 0,0965 [0,0839 ; 0,1103] | compatible | — | 0,0430 | 101 | 0,0505 [0,0413 ; 0,0610] | compatible | — |
| J2 | SpearVol (deux) † | F_R | V3a | 2000 | 0,0904 | 204 | 0,1020 [0,0891 ; 0,1161] | compatible | 18 / 7, 0,909 | 0,0430 | 94 | 0,0470 [0,0381 ; 0,0572] | compatible | 4 / 11, 1 |
| J2 | SpearVol (deux) † | F_R | V3b | 2000 | 0,0904 | 204 | 0,1020 [0,0891 ; 0,1161] | compatible | 21 / 10, 1 | 0,0430 | 106 | 0,0530 [0,0436 ; 0,0637] | écart mineur | 7 / 2, 1 |
| J2 | SpearVol (deux) † | F_R | V3h | 2000 | 0,0904 | 195 | 0,0975 [0,0848 ; 0,1113] | compatible | 5 / 3, 1 | 0,0430 | 103 | 0,0515 [0,0422 ; 0,0621] | compatible | 2 / 0, 1 |
| J2 | SpearTps (deux) † | F_R | V1 | 2000 | 0,0904 | 177 | 0,0885 [0,0764 ; 0,1018] | compatible | — | 0,0430 | 78 | 0,0390 [0,0309 ; 0,0484] | compatible | — |
| J2 | SpearTps (deux) † | F_R | V3a | 2000 | 0,0904 | 169 | 0,0845 [0,0727 ; 0,0976] | compatible | 28 / 36, 1 | 0,0430 | 84 | 0,0420 [0,0336 ; 0,0517] | compatible | 28 / 22, 1 |
| J2 | SpearTps (deux) † | F_R | V3b | 2000 | 0,0904 | 175 | 0,0875 [0,0755 ; 0,1007] | compatible | 30 / 32, 1 | 0,0430 | 89 | 0,0445 [0,0359 ; 0,0545] | compatible | 30 / 19, 1 |
| J2 | SpearTps (deux) † | F_R | V3h | 2000 | 0,0904 | 165 | 0,0825 [0,0708 ; 0,0954] | compatible | 1 / 13, 0,0146 | 0,0430 | 81 | 0,0405 [0,0323 ; 0,0501] | compatible | 4 / 1, 1 |
| J2 | DAgo (deux) | F_R, F_8 | V1 | 2000 | 0,1000 | 163 | 0,0815 [0,0699 ; 0,0944] | écart mineur | — | 0,0500 | 80 | 0,0400 [0,0318 ; 0,0495] | écart mineur | — |
| J2 | DAgo (deux) | F_R, F_8 | V3a | 2000 | 0,1000 | 162 | 0,0810 [0,0694 ; 0,0938] | écart mineur | 35 / 36, 1 | 0,0500 | 79 | 0,0395 [0,0314 ; 0,0490] | écart mineur | 19 / 20, 1 |
| J2 | DAgo (deux) | F_R, F_8 | V3b | 2000 | 0,1000 | 162 | 0,0810 [0,0694 ; 0,0938] | écart mineur | 34 / 35, 1 | 0,0500 | 83 | 0,0415 [0,0332 ; 0,0512] | compatible | 22 / 19, 1 |
| J2 | DAgo (deux) | F_R, F_8 | V3h | 2000 | 0,1000 | 197 | 0,0985 [0,0858 ; 0,1124] | compatible | 34 / 0, 2,1e-09 | 0,0500 | 102 | 0,0510 [0,0418 ; 0,0616] | compatible | 22 / 0, 9,06e-06 |
| J2 | CoxStuart (haut) † | F_T | V1 | 2000 | 0,0006 | 0 | 0,0000 [0,0000 ; 0,0018] | compatible | — | 0,0000 | 0 | 0,0000 [0,0000 ; 0,0018] | compatible | — |
| J2 | CoxStuart (haut) † | F_T | V3a | 2000 | 0,0006 | 6 | 0,0030 [0,0011 ; 0,0065] | écart à examiner (bande non applicable) | 6 / 0, 0,375 | 0,0000 | 0 | 0,0000 [0,0000 ; 0,0018] | compatible | 0 / 0, 1 |
| J2 | CoxStuart (haut) † | F_T | V3b | 2000 | 0,0006 | 0 | 0,0000 [0,0000 ; 0,0018] | compatible | 0 / 0, 1 | 0,0000 | 0 | 0,0000 [0,0000 ; 0,0018] | compatible | 0 / 0, 1 |
| J2 | CoxStuart (haut) † | F_T | V3h | 2000 | 0,0006 | 0 | 0,0000 [0,0000 ; 0,0018] | compatible | 0 / 0, 1 | 0,0000 | 0 | 0,0000 [0,0000 ; 0,0018] | compatible | 0 / 0, 1 |
| J2 | DWr (deux) | F_R | V1 | 2000 | 0,1000 | 184 | 0,0920 [0,0797 ; 0,1055] | compatible | — | 0,0500 | 91 | 0,0455 [0,0368 ; 0,0556] | compatible | — |
| J2 | DWr (deux) | F_R | V3a | 2000 | 0,1000 | 193 | 0,0965 [0,0839 ; 0,1103] | compatible | 43 / 34, 1 | 0,0500 | 112 | 0,0560 [0,0463 ; 0,0670] | compatible | 36 / 15, 0,0966 |
| J2 | DWr (deux) | F_R | V3b | 2000 | 0,1000 | 202 | 0,1010 [0,0881 ; 0,1150] | compatible | 48 / 30, 0,964 | 0,0500 | 115 | 0,0575 [0,0477 ; 0,0686] | compatible | 42 / 18, 0,0561 |
| J2 | DWr (deux) | F_R | V3h | 2000 | 0,1000 | 200 | 0,1000 [0,0872 ; 0,1140] | compatible | 16 / 0, 0,000366 | 0,0500 | 103 | 0,0515 [0,0422 ; 0,0621] | compatible | 12 / 0, 0,00684 |
| J2 | LB1r (haut) | F_R | V1 | 2000 | 0,1000 | 207 | 0,1035 [0,0905 ; 0,1177] | compatible | — | 0,0500 | 105 | 0,0525 [0,0431 ; 0,0632] | compatible | — |
| J2 | LB1r (haut) | F_R | V3a | 2000 | 0,1000 | 221 | 0,1105 [0,0971 ; 0,1251] | compatible | 28 / 14, 0,909 | 0,0500 | 96 | 0,0480 [0,0391 ; 0,0583] | compatible | 8 / 17, 1 |
| J2 | LB1r (haut) | F_R | V3b | 2000 | 0,1000 | 221 | 0,1105 [0,0971 ; 0,1251] | compatible | 25 / 11, 0,548 | 0,0500 | 101 | 0,0505 [0,0413 ; 0,0610] | compatible | 8 / 12, 1 |
| J2 | LB1r (haut) | F_R | V3h | 2000 | 0,1000 | 226 | 0,1130 [0,0994 ; 0,1277] | compatible | 19 / 0, 5,34e-05 | 0,0500 | 109 | 0,0545 [0,0450 ; 0,0654] | compatible | 4 / 0, 1 |
| J2 | Runsr (deux) † | F_T | V1 | 2000 | 0,0571 | 122 | 0,0610 [0,0509 ; 0,0724] | compatible | — | 0,0097 | 21 | 0,0105 [0,0065 ; 0,0160] | compatible | — |
| J2 | Runsr (deux) † | F_T | V3a | 2000 | 0,0571 | 117 | 0,0585 [0,0486 ; 0,0697] | compatible | 0 / 5, 0,625 | 0,0097 | 29 | 0,0145 [0,0097 ; 0,0208] | écart mineur | 13 / 5, 0,963 |
| J2 | Runsr (deux) † | F_T | V3b | 2000 | 0,0571 | 122 | 0,0610 [0,0509 ; 0,0724] | compatible | 0 / 0, 1 | 0,0097 | 21 | 0,0105 [0,0065 ; 0,0160] | compatible | 12 / 12, 1 |
| J2 | Runsr (deux) † | F_T | V3h | 2000 | 0,0571 | 122 | 0,0610 [0,0509 ; 0,0724] | compatible | 0 / 0, 1 | 0,0097 | 18 | 0,0090 [0,0053 ; 0,0142] | compatible | 1 / 4, 1 |
| J2 | supFr (haut) | F_R | V1 | 2000 | 0,1000 | 202 | 0,1010 [0,0881 ; 0,1150] | compatible | — | 0,0500 | 98 | 0,0490 [0,0400 ; 0,0594] | compatible | — |
| J2 | supFr (haut) | F_R | V3a | 2000 | 0,1000 | 204 | 0,1020 [0,0891 ; 0,1161] | compatible | 25 / 23, 1 | 0,0500 | 102 | 0,0510 [0,0418 ; 0,0616] | compatible | 18 / 14, 1 |
| J2 | supFr (haut) | F_R | V3b | 2000 | 0,1000 | 208 | 0,1040 [0,0910 ; 0,1182] | compatible | 28 / 22, 1 | 0,0500 | 107 | 0,0535 [0,0440 ; 0,0643] | compatible | 21 / 12, 1 |
| J2 | supFr (haut) | F_R | V3h | 2000 | 0,1000 | 209 | 0,1045 [0,0914 ; 0,1187] | compatible | 8 / 1, 0,273 | 0,0500 | 102 | 0,0510 [0,0418 ; 0,0616] | compatible | 4 / 0, 1 |
| J2 | CUSUMr (haut) | F_R | V1 | 2000 | 0,1000 | 199 | 0,0995 [0,0867 ; 0,1135] | compatible | — | 0,0500 | 101 | 0,0505 [0,0413 ; 0,0610] | compatible | — |
| J2 | CUSUMr (haut) | F_R | V3a | 2000 | 0,1000 | 204 | 0,1020 [0,0891 ; 0,1161] | compatible | 9 / 4, 1 | 0,0500 | 100 | 0,0500 [0,0409 ; 0,0605] | compatible | 7 / 8, 1 |
| J2 | CUSUMr (haut) | F_R | V3b | 2000 | 0,1000 | 199 | 0,0995 [0,0867 ; 0,1135] | compatible | 8 / 8, 1 | 0,0500 | 101 | 0,0505 [0,0413 ; 0,0610] | compatible | 9 / 9, 1 |
| J2 | CUSUMr (haut) | F_R | V3h | 2000 | 0,1000 | 198 | 0,0990 [0,0863 ; 0,1129] | compatible | 2 / 3, 1 | 0,0500 | 95 | 0,0475 [0,0386 ; 0,0578] | compatible | 0 / 6, 0,375 |
| J2 | Grubbsr (haut) | F_R, F_8 | V1 | 2000 | 0,1000 | 169 | 0,0845 [0,0727 ; 0,0976] | écart mineur | — | 0,0500 | 78 | 0,0390 [0,0309 ; 0,0484] | écart mineur | — |
| J2 | Grubbsr (haut) | F_R, F_8 | V3a | 2000 | 0,1000 | 174 | 0,0870 [0,0750 ; 0,1002] | compatible | 34 / 29, 1 | 0,0500 | 78 | 0,0390 [0,0309 ; 0,0484] | écart mineur | 18 / 18, 1 |
| J2 | Grubbsr (haut) | F_R, F_8 | V3b | 2000 | 0,1000 | 169 | 0,0845 [0,0727 ; 0,0976] | écart mineur | 30 / 30, 1 | 0,0500 | 82 | 0,0410 [0,0327 ; 0,0506] | compatible | 22 / 18, 1 |
| J2 | Grubbsr (haut) | F_R, F_8 | V3h | 2000 | 0,1000 | 197 | 0,0985 [0,0858 ; 0,1124] | compatible | 28 / 0, 1,12e-07 | 0,0500 | 97 | 0,0485 [0,0395 ; 0,0588] | compatible | 19 / 0, 6,1e-05 |
| J3 | AD (haut) | F_T | V1 | 2000 | 0,1000 | 172 | 0,0860 [0,0741 ; 0,0992] | écart mineur | — | 0,0500 | 96 | 0,0480 [0,0391 ; 0,0583] | compatible | — |
| J3 | AD (haut) | F_T | V3a | 2000 | 0,1000 | 188 | 0,0940 [0,0816 ; 0,1076] | compatible | 26 / 10, 0,0906 | 0,0500 | 102 | 0,0510 [0,0418 ; 0,0616] | compatible | 10 / 4, 1 |
| J3 | AD (haut) | F_T | V3b | 2000 | 0,1000 | 192 | 0,0960 [0,0834 ; 0,1098] | compatible | 27 / 7, 0,00821 | 0,0500 | 104 | 0,0520 [0,0427 ; 0,0627] | compatible | 10 / 2, 0,463 |
| J3 | AD (haut) | F_T | V3h | 2000 | 0,1000 | 189 | 0,0945 [0,0820 ; 0,1082] | compatible | 17 / 0, 0,000168 | 0,0500 | 102 | 0,0510 [0,0418 ; 0,0616] | compatible | 6 / 0, 0,25 |
| J3 | CvM (haut) | F_T | V1 | 2000 | 0,1000 | 184 | 0,0920 [0,0797 ; 0,1055] | compatible | — | 0,0500 | 102 | 0,0510 [0,0418 ; 0,0616] | compatible | — |
| J3 | CvM (haut) | F_T | V3a | 2000 | 0,1000 | 194 | 0,0970 [0,0844 ; 0,1108] | compatible | 18 / 8, 0,453 | 0,0500 | 102 | 0,0510 [0,0418 ; 0,0616] | compatible | 6 / 6, 1 |
| J3 | CvM (haut) | F_T | V3b | 2000 | 0,1000 | 194 | 0,0970 [0,0844 ; 0,1108] | compatible | 18 / 8, 0,453 | 0,0500 | 105 | 0,0525 [0,0431 ; 0,0632] | compatible | 8 / 5, 1 |
| J3 | CvM (haut) | F_T | V3h | 2000 | 0,1000 | 189 | 0,0945 [0,0820 ; 0,1082] | compatible | 7 / 2, 1 | 0,0500 | 105 | 0,0525 [0,0431 ; 0,0632] | compatible | 4 / 1, 1 |
| J3 | KS (haut) | F_T | V1 | 2000 | 0,1000 | 193 | 0,0965 [0,0839 ; 0,1103] | compatible | — | 0,0500 | 96 | 0,0480 [0,0391 ; 0,0583] | compatible | — |
| J3 | KS (haut) | F_T | V3a | 2000 | 0,1000 | 198 | 0,0990 [0,0863 ; 0,1129] | compatible | 13 / 8, 1 | 0,0500 | 104 | 0,0520 [0,0427 ; 0,0627] | compatible | 12 / 4, 0,845 |
| J3 | KS (haut) | F_T | V3b | 2000 | 0,1000 | 203 | 0,1015 [0,0886 ; 0,1156] | compatible | 14 / 4, 0,232 | 0,0500 | 100 | 0,0500 [0,0409 ; 0,0605] | compatible | 10 / 6, 1 |
| J3 | KS (haut) | F_T | V3h | 2000 | 0,1000 | 194 | 0,0970 [0,0844 ; 0,1108] | compatible | 3 / 2, 1 | 0,0500 | 94 | 0,0470 [0,0381 ; 0,0572] | compatible | 3 / 5, 1 |
| J3 | SW (bas) | F_T | V1 | 2000 | 0,1000 | 177 | 0,0885 [0,0764 ; 0,1018] | compatible | — | 0,0500 | 84 | 0,0420 [0,0336 ; 0,0517] | compatible | — |
| J3 | SW (bas) | F_T | V3a | 2000 | 0,1000 | 178 | 0,0890 [0,0769 ; 0,1023] | compatible | 11 / 10, 1 | 0,0500 | 86 | 0,0430 [0,0345 ; 0,0528] | compatible | 4 / 2, 1 |
| J3 | SW (bas) | F_T | V3b | 2000 | 0,1000 | 179 | 0,0895 [0,0773 ; 0,1029] | compatible | 10 / 8, 1 | 0,0500 | 89 | 0,0445 [0,0359 ; 0,0545] | compatible | 6 / 1, 1 |
| J3 | SW (bas) | F_T | V3h | 2000 | 0,1000 | 177 | 0,0885 [0,0764 ; 0,1018] | compatible | 5 / 5, 1 | 0,0500 | 88 | 0,0440 [0,0354 ; 0,0539] | compatible | 4 / 0, 0,75 |
| J3 | SF (bas) | F_R | V1 | 2000 | 0,1000 | 165 | 0,0825 [0,0708 ; 0,0954] | écart mineur | — | 0,0500 | 80 | 0,0400 [0,0318 ; 0,0495] | écart mineur | — |
| J3 | SF (bas) | F_R | V3a | 2000 | 0,1000 | 169 | 0,0845 [0,0727 ; 0,0976] | écart mineur | 16 / 12, 1 | 0,0500 | 80 | 0,0400 [0,0318 ; 0,0495] | écart mineur | 11 / 11, 1 |
| J3 | SF (bas) | F_R | V3b | 2000 | 0,1000 | 173 | 0,0865 [0,0745 ; 0,0997] | écart mineur | 21 / 13, 1 | 0,0500 | 78 | 0,0390 [0,0309 ; 0,0484] | écart mineur | 7 / 9, 1 |
| J3 | SF (bas) | F_R | V3h | 2000 | 0,1000 | 185 | 0,0925 [0,0802 ; 0,1061] | compatible | 21 / 1, 0,000121 | 0,0500 | 87 | 0,0435 [0,0350 ; 0,0534] | compatible | 7 / 0, 0,0781 |
| J3 | JB (haut) | F_R, F_8 | V1 | 2000 | 0,1000 | 161 | 0,0805 [0,0689 ; 0,0933] | écart mineur | — | 0,0500 | 67 | 0,0335 [0,0261 ; 0,0424] | écart mineur | — |
| J3 | JB (haut) | F_R, F_8 | V3a | 2000 | 0,1000 | 166 | 0,0830 [0,0713 ; 0,0960] | écart mineur | 33 / 28, 1 | 0,0500 | 78 | 0,0390 [0,0309 ; 0,0484] | écart mineur | 26 / 15, 1 |
| J3 | JB (haut) | F_R, F_8 | V3b | 2000 | 0,1000 | 171 | 0,0855 [0,0736 ; 0,0986] | écart mineur | 39 / 29, 1 | 0,0500 | 77 | 0,0385 [0,0305 ; 0,0479] | écart mineur | 26 / 16, 1 |
| J3 | JB (haut) | F_R, F_8 | V3h | 2000 | 0,1000 | 200 | 0,1000 [0,0872 ; 0,1140] | compatible | 39 / 0, 5,46e-11 | 0,0500 | 93 | 0,0465 [0,0377 ; 0,0567] | compatible | 26 / 0, 4,77e-07 |
| J3 | DW (deux) | F_R | V1 | 2000 | 0,1000 | 210 | 0,1050 [0,0919 ; 0,1193] | compatible | — | 0,0500 | 107 | 0,0535 [0,0440 ; 0,0643] | compatible | — |
| J3 | DW (deux) | F_R | V3a | 2000 | 0,1000 | 204 | 0,1020 [0,0891 ; 0,1161] | compatible | 12 / 18, 1 | 0,0500 | 101 | 0,0505 [0,0413 ; 0,0610] | compatible | 7 / 13, 1 |
| J3 | DW (deux) | F_R | V3b | 2000 | 0,1000 | 198 | 0,0990 [0,0863 ; 0,1129] | compatible | 10 / 22, 0,651 | 0,0500 | 104 | 0,0520 [0,0427 ; 0,0627] | compatible | 9 / 12, 1 |
| J3 | DW (deux) | F_R | V3h | 2000 | 0,1000 | 201 | 0,1005 [0,0877 ; 0,1145] | compatible | 5 / 14, 0,445 | 0,0500 | 105 | 0,0525 [0,0431 ; 0,0632] | compatible | 6 / 8, 1 |
| J3 | LB1 (haut) | F_T | V1 | 2000 | 0,1000 | 212 | 0,1060 [0,0928 ; 0,1203] | compatible | — | 0,0500 | 112 | 0,0560 [0,0463 ; 0,0670] | compatible | — |
| J3 | LB1 (haut) | F_T | V3a | 2000 | 0,1000 | 204 | 0,1020 [0,0891 ; 0,1161] | compatible | 6 / 14, 0,577 | 0,0500 | 108 | 0,0540 [0,0445 ; 0,0648] | compatible | 8 / 12, 1 |
| J3 | LB1 (haut) | F_T | V3b | 2000 | 0,1000 | 200 | 0,1000 [0,0872 ; 0,1140] | compatible | 7 / 19, 0,232 | 0,0500 | 108 | 0,0540 [0,0445 ; 0,0648] | compatible | 9 / 13, 1 |
| J3 | LB1 (haut) | F_T | V3h | 2000 | 0,1000 | 196 | 0,0980 [0,0853 ; 0,1119] | compatible | 1 / 17, 0,00145 | 0,0500 | 102 | 0,0510 [0,0418 ; 0,0616] | compatible | 2 / 12, 0,116 |
| J3 | supF (haut) | F_R | V1 | 2000 | 0,1000 | 215 | 0,1075 [0,0943 ; 0,1219] | compatible | — | 0,0500 | 102 | 0,0510 [0,0418 ; 0,0616] | compatible | — |
| J3 | supF (haut) | F_R | V3a | 2000 | 0,1000 | 216 | 0,1080 [0,0947 ; 0,1224] | compatible | 6 / 5, 1 | 0,0500 | 106 | 0,0530 [0,0436 ; 0,0637] | compatible | 9 / 5, 1 |
| J3 | supF (haut) | F_R | V3b | 2000 | 0,1000 | 210 | 0,1050 [0,0919 ; 0,1193] | compatible | 4 / 9, 1 | 0,0500 | 107 | 0,0535 [0,0440 ; 0,0643] | compatible | 10 / 5, 1 |
| J3 | supF (haut) | F_R | V3h | 2000 | 0,1000 | 215 | 0,1075 [0,0943 ; 0,1219] | compatible | 4 / 4, 1 | 0,0500 | 103 | 0,0515 [0,0422 ; 0,0621] | compatible | 4 / 3, 1 |
| J3 | CUSUM (haut) | F_T | V1 | 2000 | 0,1000 | 217 | 0,1085 [0,0952 ; 0,1230] | compatible | — | 0,0500 | 101 | 0,0505 [0,0413 ; 0,0610] | compatible | — |
| J3 | CUSUM (haut) | F_T | V3a | 2000 | 0,1000 | 212 | 0,1060 [0,0928 ; 0,1203] | compatible | 6 / 11, 1 | 0,0500 | 99 | 0,0495 [0,0404 ; 0,0599] | compatible | 4 / 6, 1 |
| J3 | CUSUM (haut) | F_T | V3b | 2000 | 0,1000 | 216 | 0,1080 [0,0947 ; 0,1224] | compatible | 9 / 10, 1 | 0,0500 | 97 | 0,0485 [0,0395 ; 0,0588] | compatible | 5 / 9, 1 |
| J3 | CUSUM (haut) | F_T | V3h | 2000 | 0,1000 | 210 | 0,1050 [0,0919 ; 0,1193] | compatible | 1 / 8, 0,312 | 0,0500 | 92 | 0,0460 [0,0372 ; 0,0561] | compatible | 0 / 9, 0,0391 |
| J3 | Grubbs (haut) | F_R, F_8 | V1 | 2000 | 0,1000 | 150 | 0,0750 [0,0638 ; 0,0874] | écart mineur | — | 0,0500 | 67 | 0,0335 [0,0261 ; 0,0424] | écart mineur | — |
| J3 | Grubbs (haut) | F_R, F_8 | V3a | 2000 | 0,1000 | 181 | 0,0905 [0,0783 ; 0,1039] | compatible | 66 / 35, 0,0425 | 0,0500 | 84 | 0,0420 [0,0336 ; 0,0517] | compatible | 47 / 30, 0,924 |
| J3 | Grubbs (haut) | F_R, F_8 | V3b | 2000 | 0,1000 | 180 | 0,0900 [0,0778 ; 0,1034] | compatible | 65 / 35, 0,0563 | 0,0500 | 93 | 0,0465 [0,0377 ; 0,0567] | compatible | 51 / 25, 0,0652 |
| J3 | Grubbs (haut) | F_R, F_8 | V3h | 2000 | 0,1000 | 215 | 0,1075 [0,0943 ; 0,1219] | compatible | 65 / 0, 9,76e-19 | 0,0500 | 118 | 0,0590 [0,0491 ; 0,0702] | compatible | 51 / 0, 1,69e-14 |
| J3 | Lillie (haut) | F_T | V1 | 2000 | 0,1000 | 180 | 0,0900 [0,0778 ; 0,1034] | compatible | — | 0,0500 | 77 | 0,0385 [0,0305 ; 0,0479] | écart mineur | — |
| J3 | Lillie (haut) | F_T | V3a | 2000 | 0,1000 | 164 | 0,0820 [0,0703 ; 0,0949] | écart mineur | 2 / 18, 0,00402 | 0,0500 | 81 | 0,0405 [0,0323 ; 0,0501] | compatible | 7 / 3, 1 |
| J3 | Lillie (haut) | F_T | V3b | 2000 | 0,1000 | 168 | 0,0840 [0,0722 ; 0,0970] | écart mineur | 6 / 18, 0,204 | 0,0500 | 80 | 0,0400 [0,0318 ; 0,0495] | écart mineur | 9 / 6, 1 |
| J3 | Lillie (haut) | F_T | V3h | 2000 | 0,1000 | 180 | 0,0900 [0,0778 ; 0,1034] | compatible | 4 / 4, 1 | 0,0500 | 83 | 0,0415 [0,0332 ; 0,0512] | compatible | 7 / 1, 0,492 |
| J3 | Intercept (deux) | F_T | V1 | 2000 | 0,1000 | 183 | 0,0915 [0,0792 ; 0,1050] | compatible | — | 0,0500 | 87 | 0,0435 [0,0350 ; 0,0534] | compatible | — |
| J3 | Intercept (deux) | F_T | V3a | 2000 | 0,1000 | 222 | 0,1110 [0,0976 ; 0,1256] | compatible | 57 / 18, 7,97e-05 | 0,0500 | 104 | 0,0520 [0,0427 ; 0,0627] | compatible | 36 / 19, 0,36 |
| J3 | Intercept (deux) | F_T | V3b | 2000 | 0,1000 | 223 | 0,1115 [0,0980 ; 0,1261] | compatible | 58 / 18, 5,66e-05 | 0,0500 | 103 | 0,0515 [0,0422 ; 0,0621] | compatible | 35 / 19, 0,463 |
| J3 | Intercept (deux) | F_T | V3h | 2000 | 0,1000 | 236 | 0,1180 [0,1042 ; 0,1330] | écart mineur | 53 / 0, 2,66e-15 | 0,0500 | 118 | 0,0590 [0,0491 ; 0,0702] | compatible | 31 / 0, 1,12e-08 |
| J3 | RESET (haut) | F_R | V1 | 2000 | 0,1000 | 226 | 0,1130 [0,0994 ; 0,1277] | compatible | — | 0,0500 | 115 | 0,0575 [0,0477 ; 0,0686] | compatible | — |
| J3 | RESET (haut) | F_R | V3a | 2000 | 0,1000 | 216 | 0,1080 [0,0947 ; 0,1224] | compatible | 13 / 23, 1 | 0,0500 | 114 | 0,0570 [0,0472 ; 0,0681] | compatible | 15 / 16, 1 |
| J3 | RESET (haut) | F_R | V3b | 2000 | 0,1000 | 223 | 0,1115 [0,0980 ; 0,1261] | compatible | 15 / 18, 1 | 0,0500 | 114 | 0,0570 [0,0472 ; 0,0681] | compatible | 15 / 16, 1 |
| J3 | RESET (haut) | F_R | V3h | 2000 | 0,1000 | 211 | 0,1055 [0,0924 ; 0,1198] | compatible | 1 / 16, 0,00275 | 0,0500 | 102 | 0,0510 [0,0418 ; 0,0616] | compatible | 0 / 13, 0,00244 |
| J3 | BP (haut) | F_R, F_8 | V1 | 2000 | 0,1000 | 90 | 0,0450 [0,0363 ; 0,0550] | écart non tranché | — | 0,0500 | 51 | 0,0255 [0,0190 ; 0,0334] | écart mineur | — |
| J3 | BP (haut) | F_R, F_8 | V3a | 2000 | 0,1000 | 192 | 0,0960 [0,0834 ; 0,1098] | compatible | 136 / 34, 2,5e-14 | 0,0500 | 101 | 0,0505 [0,0413 ; 0,0610] | compatible | 69 / 19, 1,65e-06 |
| J3 | BP (haut) | F_R, F_8 | V3b | 2000 | 0,1000 | 188 | 0,0940 [0,0816 ; 0,1076] | compatible | 135 / 37, 5,53e-13 | 0,0500 | 101 | 0,0505 [0,0413 ; 0,0610] | compatible | 69 / 19, 1,65e-06 |
| J3 | BP (haut) | F_R, F_8 | V3h | 2000 | 0,1000 | 225 | 0,1125 [0,0990 ; 0,1272] | compatible | 135 / 0, 1,01e-39 | 0,0500 | 120 | 0,0600 [0,0500 ; 0,0713] | compatible | 69 / 0, 7,45e-20 |
| J3 | BP79 (haut) | F_R, F_8 | V1 | 2000 | 0,1000 | 91 | 0,0455 [0,0368 ; 0,0556] | écart non tranché | — | 0,0500 | 39 | 0,0195 [0,0139 ; 0,0266] | écart non tranché | — |
| J3 | BP79 (haut) | F_R, F_8 | V3a | 2000 | 0,1000 | 179 | 0,0895 [0,0773 ; 0,1029] | compatible | 134 / 46, 7,2e-10 | 0,0500 | 84 | 0,0420 [0,0336 ; 0,0517] | compatible | 64 / 19, 1,48e-05 |
| J3 | BP79 (haut) | F_R, F_8 | V3b | 2000 | 0,1000 | 175 | 0,0875 [0,0755 ; 0,1007] | compatible | 132 / 48, 5,86e-09 | 0,0500 | 87 | 0,0435 [0,0350 ; 0,0534] | compatible | 69 / 21, 7,76e-06 |
| J3 | BP79 (haut) | F_R, F_8 | V3h | 2000 | 0,1000 | 223 | 0,1115 [0,0980 ; 0,1261] | compatible | 132 / 0, 7,71e-39 | 0,0500 | 108 | 0,0540 [0,0445 ; 0,0648] | compatible | 69 / 0, 7,45e-20 |
| J3 | White (haut) | F_R | V1 | 2000 | 0,1000 | 171 | 0,0855 [0,0736 ; 0,0986] | écart mineur | — | 0,0500 | 82 | 0,0410 [0,0327 ; 0,0506] | compatible | — |
| J3 | White (haut) | F_R | V3a | 2000 | 0,1000 | 201 | 0,1005 [0,0877 ; 0,1145] | compatible | 49 / 19, 0,00609 | 0,0500 | 95 | 0,0475 [0,0386 ; 0,0578] | compatible | 28 / 15, 0,924 |
| J3 | White (haut) | F_R | V3b | 2000 | 0,1000 | 201 | 0,1005 [0,0877 ; 0,1145] | compatible | 51 / 21, 0,00963 | 0,0500 | 92 | 0,0460 [0,0372 ; 0,0561] | compatible | 27 / 17, 1 |
| J3 | White (haut) | F_R | V3h | 2000 | 0,1000 | 221 | 0,1105 [0,0971 ; 0,1251] | compatible | 50 / 0, 2,84e-14 | 0,0500 | 105 | 0,0525 [0,0431 ; 0,0632] | compatible | 23 / 0, 3,34e-06 |
| J3 | GQ (deux) | F_R, F_8 | V1 | 2000 | 0,1000 | 50 | 0,0250 [0,0186 ; 0,0328] **conservateur** | distorsion matérielle | — | 0,0500 | 20 | 0,0100 [0,0061 ; 0,0154] **conservateur** | distorsion matérielle | — |
| J3 | GQ (deux) | F_R, F_8 | V3a | 2000 | 0,1000 | 227 | 0,1135 [0,0999 ; 0,1282] | compatible | 198 / 21, 5,98e-36 | 0,0500 | 88 | 0,0440 [0,0354 ; 0,0539] | compatible | 78 / 10, 7,33e-13 |
| J3 | GQ (deux) | F_R, F_8 | V3b | 2000 | 0,1000 | 225 | 0,1125 [0,0990 ; 0,1272] | compatible | 197 / 22, 5,42e-35 | 0,0500 | 88 | 0,0440 [0,0354 ; 0,0539] | compatible | 79 / 11, 1,71e-12 |
| J3 | GQ (deux) | F_R, F_8 | V3h | 2000 | 0,1000 | 180 | 0,0900 [0,0778 ; 0,1034] | compatible | 130 / 0, 2,94e-38 | 0,0500 | 75 | 0,0375 [0,0296 ; 0,0468] | écart mineur | 55 / 0, 1,11e-15 |
| J3 | BF (haut) | F_R, F_8 | V1 | 2000 | 0,1000 | 119 | 0,0595 [0,0495 ; 0,0708] | écart mineur | — | 0,0500 | 52 | 0,0260 [0,0195 ; 0,0340] | écart mineur | — |
| J3 | BF (haut) | F_R, F_8 | V3a | 2000 | 0,1000 | 171 | 0,0855 [0,0736 ; 0,0986] | écart mineur | 89 / 37, 7,79e-05 | 0,0500 | 84 | 0,0420 [0,0336 ; 0,0517] | compatible | 44 / 12, 0,000397 |
| J3 | BF (haut) | F_R, F_8 | V3b | 2000 | 0,1000 | 169 | 0,0845 [0,0727 ; 0,0976] | écart mineur | 88 / 38, 0,000187 | 0,0500 | 83 | 0,0415 [0,0332 ; 0,0512] | compatible | 44 / 13, 0,000895 |
| J3 | BF (haut) | F_R, F_8 | V3h | 2000 | 0,1000 | 207 | 0,1035 [0,0905 ; 0,1177] | compatible | 88 / 0, 1,23e-25 | 0,0500 | 96 | 0,0480 [0,0391 ; 0,0583] | compatible | 44 / 0, 2,05e-12 |
| J3 | Smirnov (haut) † | F_T | V1 | 2000 | 0,0286 | 40 | 0,0200 [0,0143 ; 0,0271] | écart mineur | — | 0,0286 | 40 | 0,0200 [0,0143 ; 0,0271] | écart mineur | — |
| J3 | Smirnov (haut) † | F_T | V3a | 2000 | 0,0286 | 62 | 0,0310 [0,0238 ; 0,0396] | compatible | 22 / 0, 5,72e-06 | 0,0286 | 40 | 0,0200 [0,0143 ; 0,0271] | écart mineur | 0 / 0, 1 |
| J3 | Smirnov (haut) † | F_T | V3b | 2000 | 0,0286 | 53 | 0,0265 [0,0199 ; 0,0345] | compatible | 13 / 0, 0,00269 | 0,0286 | 40 | 0,0200 [0,0143 ; 0,0271] | écart mineur | 0 / 0, 1 |
| J3 | Smirnov (haut) † | F_T | V3h | 2000 | 0,0286 | 53 | 0,0265 [0,0199 ; 0,0345] | compatible | 13 / 0, 0,0022 | 0,0286 | 40 | 0,0200 [0,0143 ; 0,0271] | écart mineur | 0 / 0, 1 |
| J3 | LB2 (haut) | F_R | V1 | 2000 | 0,1000 | 209 | 0,1045 [0,0914 ; 0,1187] | compatible | — | 0,0500 | 99 | 0,0495 [0,0404 ; 0,0599] | compatible | — |
| J3 | LB2 (haut) | F_R | V3a | 2000 | 0,1000 | 209 | 0,1045 [0,0914 ; 0,1187] | compatible | 9 / 9, 1 | 0,0500 | 94 | 0,0470 [0,0381 ; 0,0572] | compatible | 7 / 12, 1 |
| J3 | LB2 (haut) | F_R | V3b | 2000 | 0,1000 | 207 | 0,1035 [0,0905 ; 0,1177] | compatible | 11 / 13, 1 | 0,0500 | 92 | 0,0460 [0,0372 ; 0,0561] | compatible | 5 / 12, 1 |
| J3 | LB2 (haut) | F_R | V3h | 2000 | 0,1000 | 200 | 0,1000 [0,0872 ; 0,1140] | compatible | 1 / 10, 0,105 | 0,0500 | 88 | 0,0440 [0,0354 ; 0,0539] | compatible | 0 / 11, 0,00879 |
| J3 | BP2 (haut) | F_R | V1 | 2000 | 0,1000 | 204 | 0,1020 [0,0891 ; 0,1161] | compatible | — | 0,0500 | 104 | 0,0520 [0,0427 ; 0,0627] | compatible | — |
| J3 | BP2 (haut) | F_R | V3a | 2000 | 0,1000 | 201 | 0,1005 [0,0877 ; 0,1145] | compatible | 10 / 13, 1 | 0,0500 | 96 | 0,0480 [0,0391 ; 0,0583] | compatible | 5 / 13, 1 |
| J3 | BP2 (haut) | F_R | V3b | 2000 | 0,1000 | 207 | 0,1035 [0,0905 ; 0,1177] | compatible | 11 / 8, 1 | 0,0500 | 93 | 0,0465 [0,0377 ; 0,0567] | compatible | 5 / 16, 0,399 |
| J3 | BP2 (haut) | F_R | V3h | 2000 | 0,1000 | 198 | 0,0990 [0,0863 ; 0,1129] | compatible | 2 / 8, 0,656 | 0,0500 | 88 | 0,0440 [0,0354 ; 0,0539] | compatible | 0 / 16, 0,000366 |
| J3 | Runs (deux) † | F_T | V1 | 2000 | 0,0571 | 132 | 0,0660 [0,0555 ; 0,0778] | compatible | — | 0,0097 | 14 | 0,0070 [0,0038 ; 0,0117] | compatible | — |
| J3 | Runs (deux) † | F_T | V3a | 2000 | 0,0571 | 126 | 0,0630 [0,0527 ; 0,0746] | compatible | 0 / 6, 0,219 | 0,0097 | 21 | 0,0105 [0,0065 ; 0,0160] | compatible | 11 / 4, 1 |
| J3 | Runs (deux) † | F_T | V3b | 2000 | 0,0571 | 131 | 0,0655 [0,0551 ; 0,0772] | compatible | 0 / 1, 1 | 0,0097 | 19 | 0,0095 [0,0057 ; 0,0148] | compatible | 10 / 5, 1 |
| J3 | Runs (deux) † | F_T | V3h | 2000 | 0,0571 | 131 | 0,0655 [0,0551 ; 0,0772] | compatible | 0 / 1, 1 | 0,0097 | 11 | 0,0055 [0,0027 ; 0,0098] | compatible | 1 / 4, 1 |
| J3 | MK (deux) † | F_R | V1 | 2000 | 0,0711 | 162 | 0,0810 [0,0694 ; 0,0938] | compatible | — | 0,0336 | 82 | 0,0410 [0,0327 ; 0,0506] | compatible | — |
| J3 | MK (deux) † | F_R | V3a | 2000 | 0,0711 | 161 | 0,0805 [0,0689 ; 0,0933] | compatible | 7 / 8, 1 | 0,0336 | 87 | 0,0435 [0,0350 ; 0,0534] | écart mineur | 7 / 2, 1 |
| J3 | MK (deux) † | F_R | V3b | 2000 | 0,0711 | 165 | 0,0825 [0,0708 ; 0,0954] | compatible | 12 / 9, 1 | 0,0336 | 85 | 0,0425 [0,0341 ; 0,0523] | écart mineur | 8 / 5, 1 |
| J3 | MK (deux) † | F_R | V3h | 2000 | 0,0711 | 164 | 0,0820 [0,0703 ; 0,0949] | compatible | 6 / 4, 1 | 0,0336 | 82 | 0,0410 [0,0327 ; 0,0506] | compatible | 3 / 3, 1 |
| J3 | SpearVol (deux) † | F_R | V1 | 2000 | 0,0904 | 162 | 0,0810 [0,0694 ; 0,0938] | compatible | — | 0,0430 | 72 | 0,0360 [0,0283 ; 0,0451] | compatible | — |
| J3 | SpearVol (deux) † | F_R | V3a | 2000 | 0,0904 | 186 | 0,0930 [0,0806 ; 0,1066] | compatible | 32 / 8, 0,00328 | 0,0430 | 92 | 0,0460 [0,0372 ; 0,0561] | compatible | 26 / 6, 0,00963 |
| J3 | SpearVol (deux) † | F_R | V3b | 2000 | 0,0904 | 182 | 0,0910 [0,0788 ; 0,1045] | compatible | 29 / 9, 0,0282 | 0,0430 | 89 | 0,0445 [0,0359 ; 0,0545] | compatible | 25 / 8, 0,0728 |
| J3 | SpearVol (deux) † | F_R | V3h | 2000 | 0,0904 | 184 | 0,0920 [0,0797 ; 0,1055] | compatible | 22 / 0, 6,2e-06 | 0,0430 | 90 | 0,0450 [0,0363 ; 0,0550] | compatible | 18 / 0, 9,92e-05 |
| J3 | SpearTps (deux) † | F_R | V1 | 2000 | 0,0904 | 200 | 0,1000 [0,0872 ; 0,1140] | compatible | — | 0,0430 | 102 | 0,0510 [0,0418 ; 0,0616] | compatible | — |
| J3 | SpearTps (deux) † | F_R | V3a | 2000 | 0,0904 | 198 | 0,0990 [0,0863 ; 0,1129] | compatible | 8 / 10, 1 | 0,0430 | 103 | 0,0515 [0,0422 ; 0,0621] | compatible | 6 / 5, 1 |
| J3 | SpearTps (deux) † | F_R | V3b | 2000 | 0,0904 | 202 | 0,1010 [0,0881 ; 0,1150] | compatible | 13 / 11, 1 | 0,0430 | 102 | 0,0510 [0,0418 ; 0,0616] | compatible | 6 / 6, 1 |
| J3 | SpearTps (deux) † | F_R | V3h | 2000 | 0,0904 | 199 | 0,0995 [0,0867 ; 0,1135] | compatible | 8 / 9, 1 | 0,0430 | 101 | 0,0505 [0,0413 ; 0,0610] | compatible | 4 / 5, 1 |
| J3 | DAgo (deux) | F_R, F_8 | V1 | 2000 | 0,1000 | 138 | 0,0690 [0,0583 ; 0,0810] | écart mineur | — | 0,0500 | 66 | 0,0330 [0,0256 ; 0,0418] | écart mineur | — |
| J3 | DAgo (deux) | F_R, F_8 | V3a | 2000 | 0,1000 | 154 | 0,0770 [0,0657 ; 0,0896] | écart mineur | 44 / 28, 1 | 0,0500 | 77 | 0,0385 [0,0305 ; 0,0479] | écart mineur | 29 / 18, 1 |
| J3 | DAgo (deux) | F_R, F_8 | V3b | 2000 | 0,1000 | 161 | 0,0805 [0,0689 ; 0,0933] | écart mineur | 51 / 28, 0,192 | 0,0500 | 74 | 0,0370 [0,0292 ; 0,0462] | écart mineur | 25 / 17, 1 |
| J3 | DAgo (deux) | F_R, F_8 | V3h | 2000 | 0,1000 | 189 | 0,0945 [0,0820 ; 0,1082] | compatible | 51 / 0, 1,51e-14 | 0,0500 | 91 | 0,0455 [0,0368 ; 0,0556] | compatible | 25 / 0, 8,94e-07 |
| J3 | CoxStuart (haut) † | F_T | V1 | 2000 | 0,0006 | 0 | 0,0000 [0,0000 ; 0,0018] | compatible | — | 0,0000 | 0 | 0,0000 [0,0000 ; 0,0018] | compatible | — |
| J3 | CoxStuart (haut) † | F_T | V3a | 2000 | 0,0006 | 8 | 0,0040 [0,0017 ; 0,0079] | écart à examiner (bande non applicable) | 8 / 0, 0,0703 | 0,0000 | 0 | 0,0000 [0,0000 ; 0,0018] | compatible | 0 / 0, 1 |
| J3 | CoxStuart (haut) † | F_T | V3b | 2000 | 0,0006 | 0 | 0,0000 [0,0000 ; 0,0018] | compatible | 0 / 0, 1 | 0,0000 | 0 | 0,0000 [0,0000 ; 0,0018] | compatible | 0 / 0, 1 |
| J3 | CoxStuart (haut) † | F_T | V3h | 2000 | 0,0006 | 0 | 0,0000 [0,0000 ; 0,0018] | compatible | 0 / 0, 1 | 0,0000 | 0 | 0,0000 [0,0000 ; 0,0018] | compatible | 0 / 0, 1 |
| J3 | DWr (deux) | F_R | V1 | 2000 | 0,1000 | 197 | 0,0985 [0,0858 ; 0,1124] | compatible | — | 0,0500 | 104 | 0,0520 [0,0427 ; 0,0627] | compatible | — |
| J3 | DWr (deux) | F_R | V3a | 2000 | 0,1000 | 193 | 0,0965 [0,0839 ; 0,1103] | compatible | 18 / 22, 1 | 0,0500 | 93 | 0,0465 [0,0377 ; 0,0567] | compatible | 6 / 17, 0,52 |
| J3 | DWr (deux) | F_R | V3b | 2000 | 0,1000 | 193 | 0,0965 [0,0839 ; 0,1103] | compatible | 17 / 21, 1 | 0,0500 | 95 | 0,0475 [0,0386 ; 0,0578] | compatible | 4 / 13, 0,638 |
| J3 | DWr (deux) | F_R | V3h | 2000 | 0,1000 | 189 | 0,0945 [0,0820 ; 0,1082] | compatible | 9 / 17, 0,843 | 0,0500 | 93 | 0,0465 [0,0377 ; 0,0567] | compatible | 1 / 12, 0,0273 |
| J3 | LB1r (haut) | F_R | V1 | 2000 | 0,1000 | 204 | 0,1020 [0,0891 ; 0,1161] | compatible | — | 0,0500 | 107 | 0,0535 [0,0440 ; 0,0643] | compatible | — |
| J3 | LB1r (haut) | F_R | V3a | 2000 | 0,1000 | 195 | 0,0975 [0,0848 ; 0,1113] | compatible | 9 / 18, 1 | 0,0500 | 93 | 0,0465 [0,0377 ; 0,0567] | compatible | 7 / 21, 0,201 |
| J3 | LB1r (haut) | F_R | V3b | 2000 | 0,1000 | 197 | 0,0985 [0,0858 ; 0,1124] | compatible | 13 / 20, 1 | 0,0500 | 94 | 0,0470 [0,0381 ; 0,0572] | compatible | 9 / 22, 0,412 |
| J3 | LB1r (haut) | F_R | V3h | 2000 | 0,1000 | 186 | 0,0930 [0,0806 ; 0,1066] | compatible | 0 / 18, 9,16e-05 | 0,0500 | 90 | 0,0450 [0,0363 ; 0,0550] | compatible | 1 / 18, 0,000839 |
| J3 | Runsr (deux) † | F_T | V1 | 2000 | 0,0571 | 116 | 0,0580 [0,0482 ; 0,0692] | compatible | — | 0,0097 | 30 | 0,0150 [0,0101 ; 0,0213] | écart non tranché | — |
| J3 | Runsr (deux) † | F_T | V3a | 2000 | 0,0571 | 115 | 0,0575 [0,0477 ; 0,0686] | compatible | 0 / 1, 1 | 0,0097 | 28 | 0,0140 [0,0093 ; 0,0202] | compatible | 8 / 10, 1 |
| J3 | Runsr (deux) † | F_T | V3b | 2000 | 0,0571 | 115 | 0,0575 [0,0477 ; 0,0686] | compatible | 0 / 1, 1 | 0,0097 | 25 | 0,0125 [0,0081 ; 0,0184] | compatible | 13 / 18, 1 |
| J3 | Runsr (deux) † | F_T | V3h | 2000 | 0,0571 | 115 | 0,0575 [0,0477 ; 0,0686] | compatible | 0 / 1, 1 | 0,0097 | 17 | 0,0085 [0,0050 ; 0,0136] | compatible | 1 / 14, 0,0107 |
| J3 | supFr (haut) | F_R | V1 | 2000 | 0,1000 | 211 | 0,1055 [0,0924 ; 0,1198] | compatible | — | 0,0500 | 104 | 0,0520 [0,0427 ; 0,0627] | compatible | — |
| J3 | supFr (haut) | F_R | V3a | 2000 | 0,1000 | 214 | 0,1070 [0,0938 ; 0,1214] | compatible | 11 / 8, 1 | 0,0500 | 110 | 0,0550 [0,0454 ; 0,0659] | compatible | 12 / 6, 1 |
| J3 | supFr (haut) | F_R | V3b | 2000 | 0,1000 | 210 | 0,1050 [0,0919 ; 0,1193] | compatible | 6 / 7, 1 | 0,0500 | 107 | 0,0535 [0,0440 ; 0,0643] | compatible | 8 / 5, 1 |
| J3 | supFr (haut) | F_R | V3h | 2000 | 0,1000 | 215 | 0,1075 [0,0943 ; 0,1219] | compatible | 6 / 2, 1 | 0,0500 | 112 | 0,0560 [0,0463 ; 0,0670] | compatible | 8 / 0, 0,0547 |
| J3 | CUSUMr (haut) | F_R | V1 | 2000 | 0,1000 | 218 | 0,1090 [0,0957 ; 0,1235] | compatible | — | 0,0500 | 100 | 0,0500 [0,0409 ; 0,0605] | compatible | — |
| J3 | CUSUMr (haut) | F_R | V3a | 2000 | 0,1000 | 211 | 0,1055 [0,0924 ; 0,1198] | compatible | 11 / 18, 1 | 0,0500 | 106 | 0,0530 [0,0436 ; 0,0637] | compatible | 13 / 7, 1 |
| J3 | CUSUMr (haut) | F_R | V3b | 2000 | 0,1000 | 212 | 0,1060 [0,0928 ; 0,1203] | compatible | 6 / 12, 1 | 0,0500 | 102 | 0,0510 [0,0418 ; 0,0616] | compatible | 14 / 12, 1 |
| J3 | CUSUMr (haut) | F_R | V3h | 2000 | 0,1000 | 209 | 0,1045 [0,0914 ; 0,1187] | compatible | 2 / 11, 0,18 | 0,0500 | 90 | 0,0450 [0,0363 ; 0,0550] | compatible | 2 / 12, 0,0776 |
| J3 | Grubbsr (haut) | F_R, F_8 | V1 | 2000 | 0,1000 | 151 | 0,0755 [0,0643 ; 0,0880] | écart mineur | — | 0,0500 | 73 | 0,0365 [0,0287 ; 0,0457] | écart mineur | — |
| J3 | Grubbsr (haut) | F_R, F_8 | V3a | 2000 | 0,1000 | 172 | 0,0860 [0,0741 ; 0,0992] | écart mineur | 39 / 18, 0,113 | 0,0500 | 98 | 0,0490 [0,0400 ; 0,0594] | compatible | 38 / 13, 0,0106 |
| J3 | Grubbsr (haut) | F_R, F_8 | V3b | 2000 | 0,1000 | 166 | 0,0830 [0,0713 ; 0,0960] | écart mineur | 31 / 16, 0,56 | 0,0500 | 96 | 0,0480 [0,0391 ; 0,0583] | compatible | 37 / 14, 0,0318 |
| J3 | Grubbsr (haut) | F_R, F_8 | V3h | 2000 | 0,1000 | 182 | 0,0910 [0,0788 ; 0,1045] | compatible | 31 / 0, 1,3e-08 | 0,0500 | 109 | 0,0545 [0,0450 ; 0,0654] | compatible | 36 / 0, 4,95e-10 |

### T1 bis -- taux par régime de δ̂* (évaluable si n ≥ 100 ; McNemar : Holm par famille (jeu, régime, α, variante), F_R et F_T séparées)

| Jeu | Régime | Statistique | Variante | n | évaluable | taux [IC] 0,10 | classe 0,10 | McNemar 0,10 | taux [IC] 0,05 | classe 0,05 | McNemar 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| J1 | δ̂* = 0 | AD | V1 | 930 | oui | 0,0925 [0,0746 ; 0,1129] | compatible | — | 0,0495 [0,0364 ; 0,0654] | compatible | — |
| J1 | δ̂* = 0 | AD | V3a | 930 | oui | 0,0946 [0,0766 ; 0,1153] | compatible | 3 / 1, 1 | 0,0548 [0,0411 ; 0,0715] | compatible | 7 / 2, 1 |
| J1 | δ̂* = 0 | AD | V3b | 930 | oui | 0,0925 [0,0746 ; 0,1129] | compatible | 2 / 2, 1 | 0,0527 [0,0392 ; 0,0691] | compatible | 4 / 1, 1 |
| J1 | δ̂* = 0 | AD | V3h | 930 | oui | 0,0925 [0,0746 ; 0,1129] | compatible | 0 / 0, 1 | 0,0495 [0,0364 ; 0,0654] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | CvM | V1 | 930 | oui | 0,0989 [0,0805 ; 0,1199] | compatible | — | 0,0473 [0,0346 ; 0,0630] | compatible | — |
| J1 | δ̂* = 0 | CvM | V3a | 930 | oui | 0,0957 [0,0776 ; 0,1164] | compatible | 2 / 5, 1 | 0,0495 [0,0364 ; 0,0654] | compatible | 4 / 2, 1 |
| J1 | δ̂* = 0 | CvM | V3b | 930 | oui | 0,0978 [0,0795 ; 0,1188] | compatible | 2 / 3, 1 | 0,0495 [0,0364 ; 0,0654] | compatible | 3 / 1, 1 |
| J1 | δ̂* = 0 | CvM | V3h | 930 | oui | 0,0989 [0,0805 ; 0,1199] | compatible | 0 / 0, 1 | 0,0473 [0,0346 ; 0,0630] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | KS | V1 | 930 | oui | 0,0914 [0,0737 ; 0,1118] | compatible | — | 0,0484 [0,0355 ; 0,0642] | compatible | — |
| J1 | δ̂* = 0 | KS | V3a | 930 | oui | 0,0925 [0,0746 ; 0,1129] | compatible | 3 / 2, 1 | 0,0505 [0,0374 ; 0,0666] | compatible | 5 / 3, 1 |
| J1 | δ̂* = 0 | KS | V3b | 930 | oui | 0,0946 [0,0766 ; 0,1153] | compatible | 5 / 2, 1 | 0,0527 [0,0392 ; 0,0691] | compatible | 6 / 2, 1 |
| J1 | δ̂* = 0 | KS | V3h | 930 | oui | 0,0914 [0,0737 ; 0,1118] | compatible | 0 / 0, 1 | 0,0484 [0,0355 ; 0,0642] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | SW | V1 | 930 | oui | 0,0957 [0,0776 ; 0,1164] | compatible | — | 0,0505 [0,0374 ; 0,0666] | compatible | — |
| J1 | δ̂* = 0 | SW | V3a | 930 | oui | 0,0957 [0,0776 ; 0,1164] | compatible | 5 / 5, 1 | 0,0516 [0,0383 ; 0,0679] | compatible | 3 / 2, 1 |
| J1 | δ̂* = 0 | SW | V3b | 930 | oui | 0,0957 [0,0776 ; 0,1164] | compatible | 2 / 2, 1 | 0,0505 [0,0374 ; 0,0666] | compatible | 2 / 2, 1 |
| J1 | δ̂* = 0 | SW | V3h | 930 | oui | 0,0957 [0,0776 ; 0,1164] | compatible | 0 / 0, 1 | 0,0505 [0,0374 ; 0,0666] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | SF | V1 | 930 | oui | 0,0935 [0,0756 ; 0,1141] | compatible | — | 0,0505 [0,0374 ; 0,0666] | compatible | — |
| J1 | δ̂* = 0 | SF | V3a | 930 | oui | 0,0925 [0,0746 ; 0,1129] | compatible | 3 / 4, 1 | 0,0527 [0,0392 ; 0,0691] | compatible | 5 / 3, 1 |
| J1 | δ̂* = 0 | SF | V3b | 930 | oui | 0,0925 [0,0746 ; 0,1129] | compatible | 3 / 4, 1 | 0,0484 [0,0355 ; 0,0642] | compatible | 2 / 4, 1 |
| J1 | δ̂* = 0 | SF | V3h | 930 | oui | 0,0935 [0,0756 ; 0,1141] | compatible | 0 / 0, 1 | 0,0505 [0,0374 ; 0,0666] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | JB | V1 | 930 | oui | 0,0957 [0,0776 ; 0,1164] | compatible | — | 0,0473 [0,0346 ; 0,0630] | compatible | — |
| J1 | δ̂* = 0 | JB | V3a | 930 | oui | 0,0946 [0,0766 ; 0,1153] | compatible | 0 / 1, 1 | 0,0484 [0,0355 ; 0,0642] | compatible | 2 / 1, 1 |
| J1 | δ̂* = 0 | JB | V3b | 930 | oui | 0,0935 [0,0756 ; 0,1141] | compatible | 2 / 4, 1 | 0,0452 [0,0327 ; 0,0606] | compatible | 1 / 3, 1 |
| J1 | δ̂* = 0 | JB | V3h | 930 | oui | 0,0957 [0,0776 ; 0,1164] | compatible | 0 / 0, 1 | 0,0473 [0,0346 ; 0,0630] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | DW | V1 | 930 | oui | 0,1075 [0,0883 ; 0,1292] | compatible | — | 0,0505 [0,0374 ; 0,0666] | compatible | — |
| J1 | δ̂* = 0 | DW | V3a | 930 | oui | 0,1054 [0,0864 ; 0,1269] | compatible | 4 / 6, 1 | 0,0538 [0,0402 ; 0,0703] | compatible | 5 / 2, 1 |
| J1 | δ̂* = 0 | DW | V3b | 930 | oui | 0,1043 [0,0854 ; 0,1258] | compatible | 3 / 6, 1 | 0,0484 [0,0355 ; 0,0642] | compatible | 2 / 4, 1 |
| J1 | δ̂* = 0 | DW | V3h | 930 | oui | 0,1075 [0,0883 ; 0,1292] | compatible | 0 / 0, 1 | 0,0505 [0,0374 ; 0,0666] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | LB1 | V1 | 930 | oui | 0,1086 [0,0893 ; 0,1304] | compatible | — | 0,0473 [0,0346 ; 0,0630] | compatible | — |
| J1 | δ̂* = 0 | LB1 | V3a | 930 | oui | 0,1054 [0,0864 ; 0,1269] | compatible | 1 / 4, 1 | 0,0495 [0,0364 ; 0,0654] | compatible | 2 / 0, 1 |
| J1 | δ̂* = 0 | LB1 | V3b | 930 | oui | 0,1075 [0,0883 ; 0,1292] | compatible | 3 / 4, 1 | 0,0484 [0,0355 ; 0,0642] | compatible | 1 / 0, 1 |
| J1 | δ̂* = 0 | LB1 | V3h | 930 | oui | 0,1086 [0,0893 ; 0,1304] | compatible | 0 / 0, 1 | 0,0473 [0,0346 ; 0,0630] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | supF | V1 | 930 | oui | 0,1118 [0,0923 ; 0,1339] | compatible | — | 0,0484 [0,0355 ; 0,0642] | compatible | — |
| J1 | δ̂* = 0 | supF | V3a | 930 | oui | 0,0957 [0,0776 ; 0,1164] | compatible | 1 / 16, 0,00577 | 0,0462 [0,0337 ; 0,0618] | compatible | 0 / 2, 1 |
| J1 | δ̂* = 0 | supF | V3b | 930 | oui | 0,1032 [0,0844 ; 0,1246] | compatible | 2 / 10, 0,733 | 0,0452 [0,0327 ; 0,0606] | compatible | 0 / 3, 1 |
| J1 | δ̂* = 0 | supF | V3h | 930 | oui | 0,1118 [0,0923 ; 0,1339] | compatible | 0 / 0, 1 | 0,0484 [0,0355 ; 0,0642] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | CUSUM | V1 | 930 | oui | 0,1054 [0,0864 ; 0,1269] | compatible | — | 0,0484 [0,0355 ; 0,0642] | compatible | — |
| J1 | δ̂* = 0 | CUSUM | V3a | 930 | oui | 0,1000 [0,0815 ; 0,1211] | compatible | 2 / 7, 1 | 0,0462 [0,0337 ; 0,0618] | compatible | 1 / 3, 1 |
| J1 | δ̂* = 0 | CUSUM | V3b | 930 | oui | 0,1011 [0,0825 ; 0,1223] | compatible | 3 / 7, 1 | 0,0473 [0,0346 ; 0,0630] | compatible | 2 / 3, 1 |
| J1 | δ̂* = 0 | CUSUM | V3h | 930 | oui | 0,1054 [0,0864 ; 0,1269] | compatible | 0 / 0, 1 | 0,0484 [0,0355 ; 0,0642] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | Grubbs | V1 | 930 | oui | 0,1000 [0,0815 ; 0,1211] | compatible | — | 0,0462 [0,0337 ; 0,0618] | compatible | — |
| J1 | δ̂* = 0 | Grubbs | V3a | 930 | oui | 0,0968 [0,0785 ; 0,1176] | compatible | 1 / 4, 1 | 0,0462 [0,0337 ; 0,0618] | compatible | 3 / 3, 1 |
| J1 | δ̂* = 0 | Grubbs | V3b | 930 | oui | 0,0957 [0,0776 ; 0,1164] | compatible | 1 / 5, 1 | 0,0409 [0,0291 ; 0,0557] | compatible | 0 / 5, 1 |
| J1 | δ̂* = 0 | Grubbs | V3h | 930 | oui | 0,1000 [0,0815 ; 0,1211] | compatible | 0 / 0, 1 | 0,0462 [0,0337 ; 0,0618] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | Lillie | V1 | 930 | oui | 0,0968 [0,0785 ; 0,1176] | compatible | — | 0,0516 [0,0383 ; 0,0679] | compatible | — |
| J1 | δ̂* = 0 | Lillie | V3a | 930 | oui | 0,0978 [0,0795 ; 0,1188] | compatible | 2 / 1, 1 | 0,0505 [0,0374 ; 0,0666] | compatible | 3 / 4, 1 |
| J1 | δ̂* = 0 | Lillie | V3b | 930 | oui | 0,0978 [0,0795 ; 0,1188] | compatible | 3 / 2, 1 | 0,0505 [0,0374 ; 0,0666] | compatible | 3 / 4, 1 |
| J1 | δ̂* = 0 | Lillie | V3h | 930 | oui | 0,0968 [0,0785 ; 0,1176] | compatible | 0 / 0, 1 | 0,0516 [0,0383 ; 0,0679] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | Intercept | V1 | 930 | oui | 0,1075 [0,0883 ; 0,1292] | compatible | — | 0,0613 [0,0467 ; 0,0787] | compatible | — |
| J1 | δ̂* = 0 | Intercept | V3a | 930 | oui | 0,1086 [0,0893 ; 0,1304] | compatible | 7 / 6, 1 | 0,0581 [0,0439 ; 0,0751] | compatible | 4 / 7, 1 |
| J1 | δ̂* = 0 | Intercept | V3b | 930 | oui | 0,1075 [0,0883 ; 0,1292] | compatible | 8 / 8, 1 | 0,0581 [0,0439 ; 0,0751] | compatible | 4 / 7, 1 |
| J1 | δ̂* = 0 | Intercept | V3h | 930 | oui | 0,1075 [0,0883 ; 0,1292] | compatible | 0 / 0, 1 | 0,0613 [0,0467 ; 0,0787] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | RESET | V1 | 930 | oui | 0,1065 [0,0874 ; 0,1281] | compatible | — | 0,0548 [0,0411 ; 0,0715] | compatible | — |
| J1 | δ̂* = 0 | RESET | V3a | 930 | oui | 0,1247 [0,1042 ; 0,1477] | écart mineur | 17 / 0, 0,000336 | 0,0613 [0,0467 ; 0,0787] | compatible | 6 / 0, 0,656 |
| J1 | δ̂* = 0 | RESET | V3b | 930 | oui | 0,1226 [0,1022 ; 0,1454] | écart mineur | 15 / 0, 0,00134 | 0,0634 [0,0486 ; 0,0811] | compatible | 8 / 0, 0,172 |
| J1 | δ̂* = 0 | RESET | V3h | 930 | oui | 0,1065 [0,0874 ; 0,1281] | compatible | 0 / 0, 1 | 0,0548 [0,0411 ; 0,0715] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | BP | V1 | 930 | oui | 0,0688 [0,0534 ; 0,0870] | écart mineur | — | 0,0269 [0,0175 ; 0,0394] | écart mineur | — |
| J1 | δ̂* = 0 | BP | V3a | 930 | oui | 0,0656 [0,0505 ; 0,0835] | écart mineur | 1 / 4, 1 | 0,0280 [0,0183 ; 0,0407] | écart mineur | 2 / 1, 1 |
| J1 | δ̂* = 0 | BP | V3b | 930 | oui | 0,0677 [0,0524 ; 0,0858] | écart mineur | 2 / 3, 1 | 0,0280 [0,0183 ; 0,0407] | écart mineur | 2 / 1, 1 |
| J1 | δ̂* = 0 | BP | V3h | 930 | oui | 0,0688 [0,0534 ; 0,0870] | écart mineur | 0 / 0, 1 | 0,0269 [0,0175 ; 0,0394] | écart mineur | 0 / 0, 1 |
| J1 | δ̂* = 0 | BP79 | V1 | 930 | oui | 0,0677 [0,0524 ; 0,0858] | écart mineur | — | 0,0323 [0,0219 ; 0,0457] | écart mineur | — |
| J1 | δ̂* = 0 | BP79 | V3a | 930 | oui | 0,0656 [0,0505 ; 0,0835] | écart mineur | 1 / 3, 1 | 0,0301 [0,0201 ; 0,0432] | écart mineur | 0 / 2, 1 |
| J1 | δ̂* = 0 | BP79 | V3b | 930 | oui | 0,0656 [0,0505 ; 0,0835] | écart mineur | 1 / 3, 1 | 0,0290 [0,0192 ; 0,0420] | écart mineur | 0 / 3, 1 |
| J1 | δ̂* = 0 | BP79 | V3h | 930 | oui | 0,0677 [0,0524 ; 0,0858] | écart mineur | 0 / 0, 1 | 0,0323 [0,0219 ; 0,0457] | écart mineur | 0 / 0, 1 |
| J1 | δ̂* = 0 | White | V1 | 930 | oui | 0,0774 [0,0611 ; 0,0965] | écart mineur | — | 0,0344 [0,0237 ; 0,0482] | écart mineur | — |
| J1 | δ̂* = 0 | White | V3a | 930 | oui | 0,0774 [0,0611 ; 0,0965] | écart mineur | 3 / 3, 1 | 0,0376 [0,0264 ; 0,0520] | compatible | 3 / 0, 1 |
| J1 | δ̂* = 0 | White | V3b | 930 | oui | 0,0753 [0,0591 ; 0,0941] | écart mineur | 2 / 4, 1 | 0,0376 [0,0264 ; 0,0520] | compatible | 4 / 1, 1 |
| J1 | δ̂* = 0 | White | V3h | 930 | oui | 0,0774 [0,0611 ; 0,0965] | écart mineur | 0 / 0, 1 | 0,0344 [0,0237 ; 0,0482] | écart mineur | 0 / 0, 1 |
| J1 | δ̂* = 0 | GQ | V1 | 930 | oui | 0,0763 [0,0601 ; 0,0953] | écart mineur | — | 0,0366 [0,0254 ; 0,0507] | compatible | — |
| J1 | δ̂* = 0 | GQ | V3a | 930 | oui | 0,0935 [0,0756 ; 0,1141] | compatible | 51 / 35, 1 | 0,0419 [0,0300 ; 0,0569] | compatible | 26 / 21, 1 |
| J1 | δ̂* = 0 | GQ | V3b | 930 | oui | 0,0935 [0,0756 ; 0,1141] | compatible | 51 / 35, 1 | 0,0366 [0,0254 ; 0,0507] | compatible | 22 / 22, 1 |
| J1 | δ̂* = 0 | GQ | V3h | 930 | oui | 0,0763 [0,0601 ; 0,0953] | écart mineur | 0 / 0, 1 | 0,0366 [0,0254 ; 0,0507] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | BF | V1 | 930 | oui | 0,0828 [0,0659 ; 0,1024] | compatible | — | 0,0376 [0,0264 ; 0,0520] | compatible | — |
| J1 | δ̂* = 0 | BF | V3a | 930 | oui | 0,0774 [0,0611 ; 0,0965] | écart mineur | 0 / 5, 1 | 0,0344 [0,0237 ; 0,0482] | écart mineur | 1 / 4, 1 |
| J1 | δ̂* = 0 | BF | V3b | 930 | oui | 0,0785 [0,0620 ; 0,0977] | écart mineur | 2 / 6, 1 | 0,0366 [0,0254 ; 0,0507] | compatible | 1 / 2, 1 |
| J1 | δ̂* = 0 | BF | V3h | 930 | oui | 0,0828 [0,0659 ; 0,1024] | compatible | 0 / 0, 1 | 0,0376 [0,0264 ; 0,0520] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | Smirnov | V1 | 930 | oui | 0,0344 [0,0237 ; 0,0482] | compatible | — | 0,0344 [0,0237 ; 0,0482] | compatible | — |
| J1 | δ̂* = 0 | Smirnov | V3a | 930 | oui | 0,0344 [0,0237 ; 0,0482] | compatible | 0 / 0, 1 | 0,0333 [0,0228 ; 0,0470] | compatible | 0 / 1, 1 |
| J1 | δ̂* = 0 | Smirnov | V3b | 930 | oui | 0,0344 [0,0237 ; 0,0482] | compatible | 0 / 0, 1 | 0,0344 [0,0237 ; 0,0482] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | Smirnov | V3h | 930 | oui | 0,0344 [0,0237 ; 0,0482] | compatible | 0 / 0, 1 | 0,0344 [0,0237 ; 0,0482] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | LB2 | V1 | 930 | oui | 0,1032 [0,0844 ; 0,1246] | compatible | — | 0,0538 [0,0402 ; 0,0703] | compatible | — |
| J1 | δ̂* = 0 | LB2 | V3a | 930 | oui | 0,1022 [0,0834 ; 0,1234] | compatible | 1 / 2, 1 | 0,0559 [0,0420 ; 0,0727] | compatible | 4 / 2, 1 |
| J1 | δ̂* = 0 | LB2 | V3b | 930 | oui | 0,1054 [0,0864 ; 0,1269] | compatible | 4 / 2, 1 | 0,0527 [0,0392 ; 0,0691] | compatible | 3 / 4, 1 |
| J1 | δ̂* = 0 | LB2 | V3h | 930 | oui | 0,1032 [0,0844 ; 0,1246] | compatible | 0 / 0, 1 | 0,0538 [0,0402 ; 0,0703] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | BP2 | V1 | 930 | oui | 0,1032 [0,0844 ; 0,1246] | compatible | — | 0,0527 [0,0392 ; 0,0691] | compatible | — |
| J1 | δ̂* = 0 | BP2 | V3a | 930 | oui | 0,1054 [0,0864 ; 0,1269] | compatible | 6 / 4, 1 | 0,0581 [0,0439 ; 0,0751] | compatible | 5 / 0, 1 |
| J1 | δ̂* = 0 | BP2 | V3b | 930 | oui | 0,1032 [0,0844 ; 0,1246] | compatible | 3 / 3, 1 | 0,0548 [0,0411 ; 0,0715] | compatible | 3 / 1, 1 |
| J1 | δ̂* = 0 | BP2 | V3h | 930 | oui | 0,1032 [0,0844 ; 0,1246] | compatible | 0 / 0, 1 | 0,0527 [0,0392 ; 0,0691] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | Runs | V1 | 930 | oui | 0,0699 [0,0544 ; 0,0882] | compatible | — | 0,0075 [0,0030 ; 0,0154] | compatible | — |
| J1 | δ̂* = 0 | Runs | V3a | 930 | oui | 0,0688 [0,0534 ; 0,0870] | compatible | 0 / 1, 1 | 0,0140 [0,0075 ; 0,0238] | compatible | 10 / 4, 1 |
| J1 | δ̂* = 0 | Runs | V3b | 930 | oui | 0,0699 [0,0544 ; 0,0882] | compatible | 0 / 0, 1 | 0,0086 [0,0037 ; 0,0169] | compatible | 7 / 6, 1 |
| J1 | δ̂* = 0 | Runs | V3h | 930 | oui | 0,0699 [0,0544 ; 0,0882] | compatible | 0 / 0, 1 | 0,0075 [0,0030 ; 0,0154] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | MK | V1 | 930 | oui | 0,0710 [0,0553 ; 0,0894] | compatible | — | 0,0430 [0,0309 ; 0,0581] | compatible | — |
| J1 | δ̂* = 0 | MK | V3a | 930 | oui | 0,0774 [0,0611 ; 0,0965] | compatible | 9 / 3, 1 | 0,0452 [0,0327 ; 0,0606] | compatible | 3 / 1, 1 |
| J1 | δ̂* = 0 | MK | V3b | 930 | oui | 0,0785 [0,0620 ; 0,0977] | compatible | 10 / 3, 1 | 0,0419 [0,0300 ; 0,0569] | compatible | 4 / 5, 1 |
| J1 | δ̂* = 0 | MK | V3h | 930 | oui | 0,0710 [0,0553 ; 0,0894] | compatible | 0 / 0, 1 | 0,0430 [0,0309 ; 0,0581] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | SpearVol | V1 | 930 | oui | 0,0978 [0,0795 ; 0,1188] | compatible | — | 0,0602 [0,0458 ; 0,0775] | écart mineur | — |
| J1 | δ̂* = 0 | SpearVol | V3a | 930 | oui | 0,0957 [0,0776 ; 0,1164] | compatible | 9 / 11, 1 | 0,0559 [0,0420 ; 0,0727] | compatible | 2 / 6, 1 |
| J1 | δ̂* = 0 | SpearVol | V3b | 930 | oui | 0,0978 [0,0795 ; 0,1188] | compatible | 8 / 8, 1 | 0,0538 [0,0402 ; 0,0703] | compatible | 1 / 7, 1 |
| J1 | δ̂* = 0 | SpearVol | V3h | 930 | oui | 0,0978 [0,0795 ; 0,1188] | compatible | 0 / 0, 1 | 0,0602 [0,0458 ; 0,0775] | écart mineur | 0 / 0, 1 |
| J1 | δ̂* = 0 | SpearTps | V1 | 930 | oui | 0,0989 [0,0805 ; 0,1199] | compatible | — | 0,0505 [0,0374 ; 0,0666] | compatible | — |
| J1 | δ̂* = 0 | SpearTps | V3a | 930 | oui | 0,0989 [0,0805 ; 0,1199] | compatible | 7 / 7, 1 | 0,0473 [0,0346 ; 0,0630] | compatible | 3 / 6, 1 |
| J1 | δ̂* = 0 | SpearTps | V3b | 930 | oui | 0,0957 [0,0776 ; 0,1164] | compatible | 7 / 10, 1 | 0,0484 [0,0355 ; 0,0642] | compatible | 2 / 4, 1 |
| J1 | δ̂* = 0 | SpearTps | V3h | 930 | oui | 0,0989 [0,0805 ; 0,1199] | compatible | 0 / 0, 1 | 0,0505 [0,0374 ; 0,0666] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | DAgo | V1 | 930 | oui | 0,0968 [0,0785 ; 0,1176] | compatible | — | 0,0452 [0,0327 ; 0,0606] | compatible | — |
| J1 | δ̂* = 0 | DAgo | V3a | 930 | oui | 0,0968 [0,0785 ; 0,1176] | compatible | 7 / 7, 1 | 0,0430 [0,0309 ; 0,0581] | compatible | 1 / 3, 1 |
| J1 | δ̂* = 0 | DAgo | V3b | 930 | oui | 0,0946 [0,0766 ; 0,1153] | compatible | 5 / 7, 1 | 0,0441 [0,0318 ; 0,0593] | compatible | 3 / 4, 1 |
| J1 | δ̂* = 0 | DAgo | V3h | 930 | oui | 0,0968 [0,0785 ; 0,1176] | compatible | 0 / 0, 1 | 0,0452 [0,0327 ; 0,0606] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | CoxStuart | V1 | 930 | oui | 0,0000 [0,0000 ; 0,0040] | compatible | — | 0,0000 [0,0000 ; 0,0040] | compatible | — |
| J1 | δ̂* = 0 | CoxStuart | V3a | 930 | oui | 0,0022 [0,0003 ; 0,0077] | compatible | 2 / 0, 1 | 0,0000 [0,0000 ; 0,0040] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | CoxStuart | V3b | 930 | oui | 0,0000 [0,0000 ; 0,0040] | compatible | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0040] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | CoxStuart | V3h | 930 | oui | 0,0000 [0,0000 ; 0,0040] | compatible | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0040] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | DWr | V1 | 930 | oui | 0,1011 [0,0825 ; 0,1223] | compatible | — | 0,0516 [0,0383 ; 0,0679] | compatible | — |
| J1 | δ̂* = 0 | DWr | V3a | 930 | oui | 0,0968 [0,0785 ; 0,1176] | compatible | 2 / 6, 1 | 0,0548 [0,0411 ; 0,0715] | compatible | 6 / 3, 1 |
| J1 | δ̂* = 0 | DWr | V3b | 930 | oui | 0,0989 [0,0805 ; 0,1199] | compatible | 2 / 4, 1 | 0,0527 [0,0392 ; 0,0691] | compatible | 4 / 3, 1 |
| J1 | δ̂* = 0 | DWr | V3h | 930 | oui | 0,1011 [0,0825 ; 0,1223] | compatible | 0 / 0, 1 | 0,0516 [0,0383 ; 0,0679] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | LB1r | V1 | 930 | oui | 0,1054 [0,0864 ; 0,1269] | compatible | — | 0,0484 [0,0355 ; 0,0642] | compatible | — |
| J1 | δ̂* = 0 | LB1r | V3a | 930 | oui | 0,1000 [0,0815 ; 0,1211] | compatible | 2 / 7, 1 | 0,0495 [0,0364 ; 0,0654] | compatible | 2 / 1, 1 |
| J1 | δ̂* = 0 | LB1r | V3b | 930 | oui | 0,1032 [0,0844 ; 0,1246] | compatible | 4 / 6, 1 | 0,0484 [0,0355 ; 0,0642] | compatible | 1 / 1, 1 |
| J1 | δ̂* = 0 | LB1r | V3h | 930 | oui | 0,1054 [0,0864 ; 0,1269] | compatible | 0 / 0, 1 | 0,0484 [0,0355 ; 0,0642] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | Runsr | V1 | 930 | oui | 0,0688 [0,0534 ; 0,0870] | compatible | — | 0,0075 [0,0030 ; 0,0154] | compatible | — |
| J1 | δ̂* = 0 | Runsr | V3a | 930 | oui | 0,0677 [0,0524 ; 0,0858] | compatible | 0 / 1, 1 | 0,0161 [0,0091 ; 0,0265] | compatible | 12 / 4, 0,922 |
| J1 | δ̂* = 0 | Runsr | V3b | 930 | oui | 0,0688 [0,0534 ; 0,0870] | compatible | 0 / 0, 1 | 0,0097 [0,0044 ; 0,0183] | compatible | 7 / 5, 1 |
| J1 | δ̂* = 0 | Runsr | V3h | 930 | oui | 0,0688 [0,0534 ; 0,0870] | compatible | 0 / 0, 1 | 0,0075 [0,0030 ; 0,0154] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | supFr | V1 | 930 | oui | 0,1075 [0,0883 ; 0,1292] | compatible | — | 0,0527 [0,0392 ; 0,0691] | compatible | — |
| J1 | δ̂* = 0 | supFr | V3a | 930 | oui | 0,0968 [0,0785 ; 0,1176] | compatible | 2 / 12, 0,246 | 0,0505 [0,0374 ; 0,0666] | compatible | 0 / 2, 1 |
| J1 | δ̂* = 0 | supFr | V3b | 930 | oui | 0,0978 [0,0795 ; 0,1188] | compatible | 1 / 10, 0,234 | 0,0484 [0,0355 ; 0,0642] | compatible | 0 / 4, 1 |
| J1 | δ̂* = 0 | supFr | V3h | 930 | oui | 0,1075 [0,0883 ; 0,1292] | compatible | 0 / 0, 1 | 0,0527 [0,0392 ; 0,0691] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | CUSUMr | V1 | 930 | oui | 0,1086 [0,0893 ; 0,1304] | compatible | — | 0,0495 [0,0364 ; 0,0654] | compatible | — |
| J1 | δ̂* = 0 | CUSUMr | V3a | 930 | oui | 0,1043 [0,0854 ; 0,1258] | compatible | 4 / 8, 1 | 0,0462 [0,0337 ; 0,0618] | compatible | 0 / 3, 1 |
| J1 | δ̂* = 0 | CUSUMr | V3b | 930 | oui | 0,1043 [0,0854 ; 0,1258] | compatible | 3 / 7, 1 | 0,0419 [0,0300 ; 0,0569] | compatible | 2 / 9, 1 |
| J1 | δ̂* = 0 | CUSUMr | V3h | 930 | oui | 0,1086 [0,0893 ; 0,1304] | compatible | 0 / 0, 1 | 0,0495 [0,0364 ; 0,0654] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 0 | Grubbsr | V1 | 930 | oui | 0,1065 [0,0874 ; 0,1281] | compatible | — | 0,0505 [0,0374 ; 0,0666] | compatible | — |
| J1 | δ̂* = 0 | Grubbsr | V3a | 930 | oui | 0,0968 [0,0785 ; 0,1176] | compatible | 0 / 9, 0,0781 | 0,0430 [0,0309 ; 0,0581] | compatible | 0 / 7, 0,344 |
| J1 | δ̂* = 0 | Grubbsr | V3b | 930 | oui | 0,0978 [0,0795 ; 0,1188] | compatible | 0 / 8, 0,164 | 0,0441 [0,0318 ; 0,0593] | compatible | 2 / 8, 1 |
| J1 | δ̂* = 0 | Grubbsr | V3h | 930 | oui | 0,1065 [0,0874 ; 0,1281] | compatible | 0 / 0, 1 | 0,0505 [0,0374 ; 0,0666] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | AD | V1 | 75 | non | 0,0400 [0,0083 ; 0,1125] | compatible | — | 0,0133 [0,0003 ; 0,0721] | compatible | — |
| J1 | δ̂* intérieur | AD | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 3, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 1, 1 |
| J1 | δ̂* intérieur | AD | V3b | 75 | non | 0,0400 [0,0083 ; 0,1125] | compatible | 0 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | AD | V3h | 75 | non | 0,0400 [0,0083 ; 0,1125] | compatible | 0 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | CvM | V1 | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | — | 0,0133 [0,0003 ; 0,0721] | compatible | — |
| J1 | δ̂* intérieur | CvM | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 4, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 1, 1 |
| J1 | δ̂* intérieur | CvM | V3b | 75 | non | 0,0667 [0,0220 ; 0,1488] | compatible | 1 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | CvM | V3h | 75 | non | 0,0667 [0,0220 ; 0,1488] | compatible | 1 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | KS | V1 | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | — | 0,0133 [0,0003 ; 0,0721] | compatible | — |
| J1 | δ̂* intérieur | KS | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 4, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 1, 1 |
| J1 | δ̂* intérieur | KS | V3b | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | 0 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | KS | V3h | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | 0 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | SW | V1 | 75 | non | 0,0400 [0,0083 ; 0,1125] | compatible | — | 0,0133 [0,0003 ; 0,0721] | compatible | — |
| J1 | δ̂* intérieur | SW | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 3, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 1, 1 |
| J1 | δ̂* intérieur | SW | V3b | 75 | non | 0,0400 [0,0083 ; 0,1125] | compatible | 0 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | SW | V3h | 75 | non | 0,0400 [0,0083 ; 0,1125] | compatible | 0 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | SF | V1 | 75 | non | 0,0267 [0,0032 ; 0,0930] | écart non tranché | — | 0,0133 [0,0003 ; 0,0721] | compatible | — |
| J1 | δ̂* intérieur | SF | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 2, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 1, 1 |
| J1 | δ̂* intérieur | SF | V3b | 75 | non | 0,0400 [0,0083 ; 0,1125] | compatible | 1 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | SF | V3h | 75 | non | 0,0400 [0,0083 ; 0,1125] | compatible | 1 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | JB | V1 | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | — | 0,0000 [0,0000 ; 0,0480] | écart non tranché | — |
| J1 | δ̂* intérieur | JB | V3a | 75 | non | 0,0133 [0,0003 ; 0,0721] | écart non tranché | 1 / 0, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 0, 1 |
| J1 | δ̂* intérieur | JB | V3b | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | 4 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 2 / 0, 1 |
| J1 | δ̂* intérieur | JB | V3h | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | 4 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 2 / 0, 1 |
| J1 | δ̂* intérieur | DW | V1 | 75 | non | 0,0133 [0,0003 ; 0,0721] | écart non tranché | — | 0,0133 [0,0003 ; 0,0721] | compatible | — |
| J1 | δ̂* intérieur | DW | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 1, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 1, 1 |
| J1 | δ̂* intérieur | DW | V3b | 75 | non | 0,0667 [0,0220 ; 0,1488] | compatible | 4 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | DW | V3h | 75 | non | 0,0667 [0,0220 ; 0,1488] | compatible | 4 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | LB1 | V1 | 75 | non | 0,1067 [0,0472 ; 0,1994] | compatible | — | 0,0000 [0,0000 ; 0,0480] | écart non tranché | — |
| J1 | δ̂* intérieur | LB1 | V3a | 75 | non | 0,0267 [0,0032 ; 0,0930] | écart non tranché | 1 / 7, 0,773 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 0, 1 |
| J1 | δ̂* intérieur | LB1 | V3b | 75 | non | 0,1333 [0,0658 ; 0,2316] | compatible | 2 / 0, 1 | 0,0400 [0,0083 ; 0,1125] | compatible | 3 / 0, 1 |
| J1 | δ̂* intérieur | LB1 | V3h | 75 | non | 0,1333 [0,0658 ; 0,2316] | compatible | 2 / 0, 1 | 0,0400 [0,0083 ; 0,1125] | compatible | 3 / 0, 1 |
| J1 | δ̂* intérieur | supF | V1 | 75 | non | 0,0133 [0,0003 ; 0,0721] | écart non tranché | — | 0,0133 [0,0003 ; 0,0721] | compatible | — |
| J1 | δ̂* intérieur | supF | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 1, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 1, 1 |
| J1 | δ̂* intérieur | supF | V3b | 75 | non | 0,0667 [0,0220 ; 0,1488] | compatible | 4 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | supF | V3h | 75 | non | 0,0667 [0,0220 ; 0,1488] | compatible | 4 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | CUSUM | V1 | 75 | non | 0,0133 [0,0003 ; 0,0721] | écart non tranché | — | 0,0133 [0,0003 ; 0,0721] | compatible | — |
| J1 | δ̂* intérieur | CUSUM | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 1, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 1, 1 |
| J1 | δ̂* intérieur | CUSUM | V3b | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | 3 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | CUSUM | V3h | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | 3 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | Grubbs | V1 | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | — | 0,0000 [0,0000 ; 0,0480] | écart non tranché | — |
| J1 | δ̂* intérieur | Grubbs | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 0, 1 |
| J1 | δ̂* intérieur | Grubbs | V3b | 75 | non | 0,0667 [0,0220 ; 0,1488] | compatible | 5 / 0, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 0, 1 |
| J1 | δ̂* intérieur | Grubbs | V3h | 75 | non | 0,0667 [0,0220 ; 0,1488] | compatible | 5 / 0, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 0, 1 |
| J1 | δ̂* intérieur | Lillie | V1 | 75 | non | 0,0400 [0,0083 ; 0,1125] | compatible | — | 0,0133 [0,0003 ; 0,0721] | compatible | — |
| J1 | δ̂* intérieur | Lillie | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 3, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 1, 1 |
| J1 | δ̂* intérieur | Lillie | V3b | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | 1 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | Lillie | V3h | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | 1 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | Intercept | V1 | 75 | non | 0,0800 [0,0299 ; 0,1660] | compatible | — | 0,0400 [0,0083 ; 0,1125] | compatible | — |
| J1 | δ̂* intérieur | Intercept | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 6, 0,375 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 3, 1 |
| J1 | δ̂* intérieur | Intercept | V3b | 75 | non | 0,0800 [0,0299 ; 0,1660] | compatible | 0 / 0, 1 | 0,0400 [0,0083 ; 0,1125] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | Intercept | V3h | 75 | non | 0,0800 [0,0299 ; 0,1660] | compatible | 0 / 0, 1 | 0,0400 [0,0083 ; 0,1125] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | RESET | V1 | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | — | 0,0133 [0,0003 ; 0,0721] | compatible | — |
| J1 | δ̂* intérieur | RESET | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 4, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 1, 1 |
| J1 | δ̂* intérieur | RESET | V3b | 75 | non | 0,0933 [0,0384 ; 0,1829] | compatible | 3 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | RESET | V3h | 75 | non | 0,0933 [0,0384 ; 0,1829] | compatible | 3 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | BP | V1 | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | — | 0,0000 [0,0000 ; 0,0480] | écart non tranché | — |
| J1 | δ̂* intérieur | BP | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 0, 1 |
| J1 | δ̂* intérieur | BP | V3b | 75 | non | 0,1067 [0,0472 ; 0,1994] | compatible | 8 / 0, 0,172 | 0,0533 [0,0147 ; 0,1310] | compatible | 4 / 0, 1 |
| J1 | δ̂* intérieur | BP | V3h | 75 | non | 0,1067 [0,0472 ; 0,1994] | compatible | 8 / 0, 0,172 | 0,0533 [0,0147 ; 0,1310] | compatible | 4 / 0, 1 |
| J1 | δ̂* intérieur | BP79 | V1 | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | — | 0,0000 [0,0000 ; 0,0480] | écart non tranché | — |
| J1 | δ̂* intérieur | BP79 | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 0, 1 |
| J1 | δ̂* intérieur | BP79 | V3b | 75 | non | 0,0800 [0,0299 ; 0,1660] | compatible | 6 / 0, 0,625 | 0,0667 [0,0220 ; 0,1488] | compatible | 5 / 0, 1 |
| J1 | δ̂* intérieur | BP79 | V3h | 75 | non | 0,0800 [0,0299 ; 0,1660] | compatible | 6 / 0, 0,625 | 0,0667 [0,0220 ; 0,1488] | compatible | 5 / 0, 1 |
| J1 | δ̂* intérieur | White | V1 | 75 | non | 0,0400 [0,0083 ; 0,1125] | compatible | — | 0,0000 [0,0000 ; 0,0480] | écart non tranché | — |
| J1 | δ̂* intérieur | White | V3a | 75 | non | 0,0133 [0,0003 ; 0,0721] | écart non tranché | 1 / 3, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | White | V3b | 75 | non | 0,1067 [0,0472 ; 0,1994] | compatible | 5 / 0, 1 | 0,0400 [0,0083 ; 0,1125] | compatible | 3 / 0, 1 |
| J1 | δ̂* intérieur | White | V3h | 75 | non | 0,1067 [0,0472 ; 0,1994] | compatible | 5 / 0, 1 | 0,0400 [0,0083 ; 0,1125] | compatible | 3 / 0, 1 |
| J1 | δ̂* intérieur | GQ | V1 | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | — | 0,0000 [0,0000 ; 0,0480] | écart non tranché | — |
| J1 | δ̂* intérieur | GQ | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 0, 1 |
| J1 | δ̂* intérieur | GQ | V3b | 75 | non | 0,0800 [0,0299 ; 0,1660] | compatible | 6 / 0, 0,625 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 0, 1 |
| J1 | δ̂* intérieur | GQ | V3h | 75 | non | 0,0800 [0,0299 ; 0,1660] | compatible | 6 / 0, 0,625 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 0, 1 |
| J1 | δ̂* intérieur | BF | V1 | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | — | 0,0000 [0,0000 ; 0,0480] | écart non tranché | — |
| J1 | δ̂* intérieur | BF | V3a | 75 | non | 0,0267 [0,0032 ; 0,0930] | écart non tranché | 2 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | BF | V3b | 75 | non | 0,1067 [0,0472 ; 0,1994] | compatible | 8 / 0, 0,172 | 0,0133 [0,0003 ; 0,0721] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | BF | V3h | 75 | non | 0,1067 [0,0472 ; 0,1994] | compatible | 8 / 0, 0,172 | 0,0133 [0,0003 ; 0,0721] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | Smirnov | V1 | 75 | non | 0,0000 [0,0000 ; 0,0480] | compatible | — | 0,0000 [0,0000 ; 0,0480] | compatible | — |
| J1 | δ̂* intérieur | Smirnov | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] | compatible | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0480] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | Smirnov | V3b | 75 | non | 0,0000 [0,0000 ; 0,0480] | compatible | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0480] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | Smirnov | V3h | 75 | non | 0,0000 [0,0000 ; 0,0480] | compatible | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0480] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | LB2 | V1 | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | — | 0,0133 [0,0003 ; 0,0721] | compatible | — |
| J1 | δ̂* intérieur | LB2 | V3a | 75 | non | 0,0133 [0,0003 ; 0,0721] | écart non tranché | 1 / 4, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 1, 1 |
| J1 | δ̂* intérieur | LB2 | V3b | 75 | non | 0,0933 [0,0384 ; 0,1829] | compatible | 3 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | LB2 | V3h | 75 | non | 0,0933 [0,0384 ; 0,1829] | compatible | 3 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | BP2 | V1 | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | — | 0,0000 [0,0000 ; 0,0480] | écart non tranché | — |
| J1 | δ̂* intérieur | BP2 | V3a | 75 | non | 0,0133 [0,0003 ; 0,0721] | écart non tranché | 1 / 4, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 0, 1 |
| J1 | δ̂* intérieur | BP2 | V3b | 75 | non | 0,1200 [0,0564 ; 0,2156] | compatible | 5 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 2 / 0, 1 |
| J1 | δ̂* intérieur | BP2 | V3h | 75 | non | 0,1200 [0,0564 ; 0,2156] | compatible | 5 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 2 / 0, 1 |
| J1 | δ̂* intérieur | Runs | V1 | 75 | non | 0,0267 [0,0032 ; 0,0930] | compatible | — | 0,0000 [0,0000 ; 0,0480] | compatible | — |
| J1 | δ̂* intérieur | Runs | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 2, 1 | 0,0000 [0,0000 ; 0,0480] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | Runs | V3b | 75 | non | 0,0267 [0,0032 ; 0,0930] | compatible | 0 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | Runs | V3h | 75 | non | 0,0267 [0,0032 ; 0,0930] | compatible | 0 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | MK | V1 | 75 | non | 0,0667 [0,0220 ; 0,1488] | compatible | — | 0,0267 [0,0032 ; 0,0930] | compatible | — |
| J1 | δ̂* intérieur | MK | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 5, 1 | 0,0000 [0,0000 ; 0,0480] | compatible | 0 / 2, 1 |
| J1 | δ̂* intérieur | MK | V3b | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | 0 / 1, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | MK | V3h | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | 0 / 1, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | SpearVol | V1 | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | — | 0,0133 [0,0003 ; 0,0721] | compatible | — |
| J1 | δ̂* intérieur | SpearVol | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 4, 1 | 0,0000 [0,0000 ; 0,0480] | compatible | 0 / 1, 1 |
| J1 | δ̂* intérieur | SpearVol | V3b | 75 | non | 0,0933 [0,0384 ; 0,1829] | compatible | 3 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | SpearVol | V3h | 75 | non | 0,0933 [0,0384 ; 0,1829] | compatible | 3 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | SpearTps | V1 | 75 | non | 0,0400 [0,0083 ; 0,1125] | compatible | — | 0,0267 [0,0032 ; 0,0930] | compatible | — |
| J1 | δ̂* intérieur | SpearTps | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 3, 1 | 0,0000 [0,0000 ; 0,0480] | compatible | 0 / 2, 1 |
| J1 | δ̂* intérieur | SpearTps | V3b | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | 1 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | SpearTps | V3h | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | 1 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | DAgo | V1 | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | — | 0,0000 [0,0000 ; 0,0480] | écart non tranché | — |
| J1 | δ̂* intérieur | DAgo | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 0, 1 |
| J1 | δ̂* intérieur | DAgo | V3b | 75 | non | 0,0400 [0,0083 ; 0,1125] | compatible | 3 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | DAgo | V3h | 75 | non | 0,0400 [0,0083 ; 0,1125] | compatible | 3 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | CoxStuart | V1 | 75 | non | 0,0000 [0,0000 ; 0,0480] | compatible | — | 0,0000 [0,0000 ; 0,0480] | compatible | — |
| J1 | δ̂* intérieur | CoxStuart | V3a | 75 | non | 0,0133 [0,0003 ; 0,0721] | compatible | 1 / 0, 1 | 0,0000 [0,0000 ; 0,0480] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | CoxStuart | V3b | 75 | non | 0,0533 [0,0147 ; 0,1310] | écart à examiner (bande non applicable) | 4 / 0, 1 | 0,0000 [0,0000 ; 0,0480] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | CoxStuart | V3h | 75 | non | 0,0533 [0,0147 ; 0,1310] | écart à examiner (bande non applicable) | 4 / 0, 1 | 0,0000 [0,0000 ; 0,0480] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | DWr | V1 | 75 | non | 0,0133 [0,0003 ; 0,0721] | écart non tranché | — | 0,0133 [0,0003 ; 0,0721] | compatible | — |
| J1 | δ̂* intérieur | DWr | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 1, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 1, 1 |
| J1 | δ̂* intérieur | DWr | V3b | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | 3 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | DWr | V3h | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | 3 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | LB1r | V1 | 75 | non | 0,0800 [0,0299 ; 0,1660] | compatible | — | 0,0000 [0,0000 ; 0,0480] | écart non tranché | — |
| J1 | δ̂* intérieur | LB1r | V3a | 75 | non | 0,0267 [0,0032 ; 0,0930] | écart non tranché | 1 / 5, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 0, 1 |
| J1 | δ̂* intérieur | LB1r | V3b | 75 | non | 0,1200 [0,0564 ; 0,2156] | compatible | 3 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 2 / 0, 1 |
| J1 | δ̂* intérieur | LB1r | V3h | 75 | non | 0,1200 [0,0564 ; 0,2156] | compatible | 3 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 2 / 0, 1 |
| J1 | δ̂* intérieur | Runsr | V1 | 75 | non | 0,0267 [0,0032 ; 0,0930] | compatible | — | 0,0000 [0,0000 ; 0,0480] | compatible | — |
| J1 | δ̂* intérieur | Runsr | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 2, 1 | 0,0000 [0,0000 ; 0,0480] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | Runsr | V3b | 75 | non | 0,0267 [0,0032 ; 0,0930] | compatible | 0 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | Runsr | V3h | 75 | non | 0,0267 [0,0032 ; 0,0930] | compatible | 0 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | supFr | V1 | 75 | non | 0,0267 [0,0032 ; 0,0930] | écart non tranché | — | 0,0133 [0,0003 ; 0,0721] | compatible | — |
| J1 | δ̂* intérieur | supFr | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 2, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 1, 1 |
| J1 | δ̂* intérieur | supFr | V3b | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | 2 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | supFr | V3h | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | 2 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 1 / 0, 1 |
| J1 | δ̂* intérieur | CUSUMr | V1 | 75 | non | 0,0133 [0,0003 ; 0,0721] | écart non tranché | — | 0,0133 [0,0003 ; 0,0721] | compatible | — |
| J1 | δ̂* intérieur | CUSUMr | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 1, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 1, 1 |
| J1 | δ̂* intérieur | CUSUMr | V3b | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | 3 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | CUSUMr | V3h | 75 | non | 0,0533 [0,0147 ; 0,1310] | compatible | 3 / 0, 1 | 0,0133 [0,0003 ; 0,0721] | compatible | 0 / 0, 1 |
| J1 | δ̂* intérieur | Grubbsr | V1 | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | — | 0,0000 [0,0000 ; 0,0480] | écart non tranché | — |
| J1 | δ̂* intérieur | Grubbsr | V3a | 75 | non | 0,0000 [0,0000 ; 0,0480] **conservateur** | distorsion matérielle | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0480] | écart non tranché | 0 / 0, 1 |
| J1 | δ̂* intérieur | Grubbsr | V3b | 75 | non | 0,0667 [0,0220 ; 0,1488] | compatible | 5 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 2 / 0, 1 |
| J1 | δ̂* intérieur | Grubbsr | V3h | 75 | non | 0,0667 [0,0220 ; 0,1488] | compatible | 5 / 0, 1 | 0,0267 [0,0032 ; 0,0930] | compatible | 2 / 0, 1 |
| J1 | δ̂* = 1 | AD | V1 | 995 | oui | 0,0965 [0,0788 ; 0,1165] | compatible | — | 0,0422 [0,0306 ; 0,0566] | compatible | — |
| J1 | δ̂* = 1 | AD | V3a | 995 | oui | 0,0894 [0,0724 ; 0,1089] | compatible | 0 / 7, 0,188 | 0,0432 [0,0314 ; 0,0578] | compatible | 5 / 4, 1 |
| J1 | δ̂* = 1 | AD | V3b | 995 | oui | 0,0884 [0,0715 ; 0,1078] | compatible | 1 / 9, 0,236 | 0,0422 [0,0306 ; 0,0566] | compatible | 4 / 4, 1 |
| J1 | δ̂* = 1 | AD | V3h | 995 | oui | 0,0965 [0,0788 ; 0,1165] | compatible | 0 / 0, 1 | 0,0422 [0,0306 ; 0,0566] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | CvM | V1 | 995 | oui | 0,0955 [0,0779 ; 0,1155] | compatible | — | 0,0442 [0,0323 ; 0,0589] | compatible | — |
| J1 | δ̂* = 1 | CvM | V3a | 995 | oui | 0,0925 [0,0752 ; 0,1122] | compatible | 2 / 5, 1 | 0,0442 [0,0323 ; 0,0589] | compatible | 3 / 3, 1 |
| J1 | δ̂* = 1 | CvM | V3b | 995 | oui | 0,0935 [0,0761 ; 0,1133] | compatible | 2 / 4, 1 | 0,0412 [0,0297 ; 0,0555] | compatible | 3 / 6, 1 |
| J1 | δ̂* = 1 | CvM | V3h | 995 | oui | 0,0955 [0,0779 ; 0,1155] | compatible | 0 / 0, 1 | 0,0442 [0,0323 ; 0,0589] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | KS | V1 | 995 | oui | 0,0794 [0,0634 ; 0,0980] | écart mineur | — | 0,0452 [0,0332 ; 0,0601] | compatible | — |
| J1 | δ̂* = 1 | KS | V3a | 995 | oui | 0,0794 [0,0634 ; 0,0980] | écart mineur | 2 / 2, 1 | 0,0402 [0,0289 ; 0,0543] | compatible | 0 / 5, 0,625 |
| J1 | δ̂* = 1 | KS | V3b | 995 | oui | 0,0794 [0,0634 ; 0,0980] | écart mineur | 2 / 2, 1 | 0,0422 [0,0306 ; 0,0566] | compatible | 1 / 4, 1 |
| J1 | δ̂* = 1 | KS | V3h | 995 | oui | 0,0794 [0,0634 ; 0,0980] | écart mineur | 0 / 0, 1 | 0,0452 [0,0332 ; 0,0601] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | SW | V1 | 995 | oui | 0,0915 [0,0743 ; 0,1111] | compatible | — | 0,0402 [0,0289 ; 0,0543] | compatible | — |
| J1 | δ̂* = 1 | SW | V3a | 995 | oui | 0,0894 [0,0724 ; 0,1089] | compatible | 3 / 5, 1 | 0,0422 [0,0306 ; 0,0566] | compatible | 4 / 2, 1 |
| J1 | δ̂* = 1 | SW | V3b | 995 | oui | 0,0824 [0,0661 ; 0,1013] | compatible | 0 / 9, 0,0469 | 0,0422 [0,0306 ; 0,0566] | compatible | 2 / 0, 1 |
| J1 | δ̂* = 1 | SW | V3h | 995 | oui | 0,0915 [0,0743 ; 0,1111] | compatible | 0 / 0, 1 | 0,0402 [0,0289 ; 0,0543] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | SF | V1 | 995 | oui | 0,0894 [0,0724 ; 0,1089] | compatible | — | 0,0462 [0,0340 ; 0,0612] | compatible | — |
| J1 | δ̂* = 1 | SF | V3a | 995 | oui | 0,0854 [0,0688 ; 0,1045] | compatible | 2 / 6, 1 | 0,0412 [0,0297 ; 0,0555] | compatible | 1 / 6, 1 |
| J1 | δ̂* = 1 | SF | V3b | 995 | oui | 0,0854 [0,0688 ; 0,1045] | compatible | 3 / 7, 1 | 0,0402 [0,0289 ; 0,0543] | compatible | 2 / 8, 1 |
| J1 | δ̂* = 1 | SF | V3h | 995 | oui | 0,0894 [0,0724 ; 0,1089] | compatible | 0 / 0, 1 | 0,0462 [0,0340 ; 0,0612] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | JB | V1 | 995 | oui | 0,0915 [0,0743 ; 0,1111] | compatible | — | 0,0492 [0,0367 ; 0,0646] | compatible | — |
| J1 | δ̂* = 1 | JB | V3a | 995 | oui | 0,0894 [0,0724 ; 0,1089] | compatible | 0 / 2, 1 | 0,0472 [0,0349 ; 0,0623] | compatible | 2 / 4, 1 |
| J1 | δ̂* = 1 | JB | V3b | 995 | oui | 0,0834 [0,0670 ; 0,1024] | compatible | 3 / 11, 0,918 | 0,0462 [0,0340 ; 0,0612] | compatible | 0 / 3, 1 |
| J1 | δ̂* = 1 | JB | V3h | 995 | oui | 0,0915 [0,0743 ; 0,1111] | compatible | 0 / 0, 1 | 0,0492 [0,0367 ; 0,0646] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | DW | V1 | 995 | oui | 0,1216 [0,1019 ; 0,1435] | écart mineur | — | 0,0513 [0,0384 ; 0,0668] | compatible | — |
| J1 | δ̂* = 1 | DW | V3a | 995 | oui | 0,1176 [0,0982 ; 0,1392] | compatible | 5 / 9, 1 | 0,0442 [0,0323 ; 0,0589] | compatible | 3 / 10, 1 |
| J1 | δ̂* = 1 | DW | V3b | 995 | oui | 0,1166 [0,0973 ; 0,1382] | compatible | 3 / 8, 1 | 0,0452 [0,0332 ; 0,0601] | compatible | 1 / 7, 1 |
| J1 | δ̂* = 1 | DW | V3h | 995 | oui | 0,1216 [0,1019 ; 0,1435] | écart mineur | 0 / 0, 1 | 0,0513 [0,0384 ; 0,0668] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | LB1 | V1 | 995 | oui | 0,1055 [0,0871 ; 0,1263] | compatible | — | 0,0563 [0,0428 ; 0,0725] | compatible | — |
| J1 | δ̂* = 1 | LB1 | V3a | 995 | oui | 0,1035 [0,0853 ; 0,1241] | compatible | 3 / 5, 1 | 0,0553 [0,0419 ; 0,0713] | compatible | 2 / 3, 1 |
| J1 | δ̂* = 1 | LB1 | V3b | 995 | oui | 0,1055 [0,0871 ; 0,1263] | compatible | 5 / 5, 1 | 0,0553 [0,0419 ; 0,0713] | compatible | 4 / 5, 1 |
| J1 | δ̂* = 1 | LB1 | V3h | 995 | oui | 0,1055 [0,0871 ; 0,1263] | compatible | 0 / 0, 1 | 0,0563 [0,0428 ; 0,0725] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | supF | V1 | 995 | oui | 0,1045 [0,0862 ; 0,1252] | compatible | — | 0,0543 [0,0410 ; 0,0702] | compatible | — |
| J1 | δ̂* = 1 | supF | V3a | 995 | oui | 0,1045 [0,0862 ; 0,1252] | compatible | 4 / 4, 1 | 0,0553 [0,0419 ; 0,0713] | compatible | 5 / 4, 1 |
| J1 | δ̂* = 1 | supF | V3b | 995 | oui | 0,1035 [0,0853 ; 0,1241] | compatible | 6 / 7, 1 | 0,0533 [0,0402 ; 0,0691] | compatible | 3 / 4, 1 |
| J1 | δ̂* = 1 | supF | V3h | 995 | oui | 0,1045 [0,0862 ; 0,1252] | compatible | 0 / 0, 1 | 0,0543 [0,0410 ; 0,0702] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | CUSUM | V1 | 995 | oui | 0,1095 [0,0908 ; 0,1306] | compatible | — | 0,0523 [0,0393 ; 0,0680] | compatible | — |
| J1 | δ̂* = 1 | CUSUM | V3a | 995 | oui | 0,1085 [0,0899 ; 0,1295] | compatible | 1 / 2, 1 | 0,0492 [0,0367 ; 0,0646] | compatible | 1 / 4, 1 |
| J1 | δ̂* = 1 | CUSUM | V3b | 995 | oui | 0,1075 [0,0890 ; 0,1285] | compatible | 0 / 2, 1 | 0,0533 [0,0402 ; 0,0691] | compatible | 2 / 1, 1 |
| J1 | δ̂* = 1 | CUSUM | V3h | 995 | oui | 0,1095 [0,0908 ; 0,1306] | compatible | 0 / 0, 1 | 0,0523 [0,0393 ; 0,0680] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | Grubbs | V1 | 995 | oui | 0,1065 [0,0880 ; 0,1274] | compatible | — | 0,0513 [0,0384 ; 0,0668] | compatible | — |
| J1 | δ̂* = 1 | Grubbs | V3a | 995 | oui | 0,1025 [0,0844 ; 0,1231] | compatible | 1 / 5, 1 | 0,0472 [0,0349 ; 0,0623] | compatible | 0 / 4, 1 |
| J1 | δ̂* = 1 | Grubbs | V3b | 995 | oui | 0,0965 [0,0788 ; 0,1165] | compatible | 1 / 11, 0,114 | 0,0462 [0,0340 ; 0,0612] | compatible | 0 / 5, 1 |
| J1 | δ̂* = 1 | Grubbs | V3h | 995 | oui | 0,1065 [0,0880 ; 0,1274] | compatible | 0 / 0, 1 | 0,0513 [0,0384 ; 0,0668] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | Lillie | V1 | 995 | oui | 0,0804 [0,0643 ; 0,0991] | écart mineur | — | 0,0472 [0,0349 ; 0,0623] | compatible | — |
| J1 | δ̂* = 1 | Lillie | V3a | 995 | oui | 0,0774 [0,0616 ; 0,0958] | écart mineur | 1 / 4, 1 | 0,0422 [0,0306 ; 0,0566] | compatible | 0 / 5, 0,625 |
| J1 | δ̂* = 1 | Lillie | V3b | 995 | oui | 0,0804 [0,0643 ; 0,0991] | écart mineur | 2 / 2, 1 | 0,0432 [0,0314 ; 0,0578] | compatible | 0 / 4, 1 |
| J1 | δ̂* = 1 | Lillie | V3h | 995 | oui | 0,0804 [0,0643 ; 0,0991] | écart mineur | 0 / 0, 1 | 0,0472 [0,0349 ; 0,0623] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | Intercept | V1 | 995 | oui | 0,1116 [0,0927 ; 0,1328] | compatible | — | 0,0553 [0,0419 ; 0,0713] | compatible | — |
| J1 | δ̂* = 1 | Intercept | V3a | 995 | oui | 0,1106 [0,0917 ; 0,1317] | compatible | 7 / 8, 1 | 0,0523 [0,0393 ; 0,0680] | compatible | 5 / 8, 1 |
| J1 | δ̂* = 1 | Intercept | V3b | 995 | oui | 0,1106 [0,0917 ; 0,1317] | compatible | 8 / 9, 1 | 0,0513 [0,0384 ; 0,0668] | compatible | 3 / 7, 1 |
| J1 | δ̂* = 1 | Intercept | V3h | 995 | oui | 0,1116 [0,0927 ; 0,1328] | compatible | 0 / 0, 1 | 0,0553 [0,0419 ; 0,0713] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | RESET | V1 | 995 | oui | 0,1196 [0,1001 ; 0,1414] | écart mineur | — | 0,0603 [0,0463 ; 0,0769] | compatible | — |
| J1 | δ̂* = 1 | RESET | V3a | 995 | oui | 0,1085 [0,0899 ; 0,1295] | compatible | 0 / 11, 0,0186 | 0,0523 [0,0393 ; 0,0680] | compatible | 0 / 8, 0,148 |
| J1 | δ̂* = 1 | RESET | V3b | 995 | oui | 0,1085 [0,0899 ; 0,1295] | compatible | 0 / 11, 0,0186 | 0,0533 [0,0402 ; 0,0691] | compatible | 0 / 7, 0,313 |
| J1 | δ̂* = 1 | RESET | V3h | 995 | oui | 0,1196 [0,1001 ; 0,1414] | écart mineur | 0 / 0, 1 | 0,0603 [0,0463 ; 0,0769] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | BP | V1 | 995 | oui | 0,1276 [0,1075 ; 0,1500] | écart mineur | — | 0,0704 [0,0552 ; 0,0881] | écart mineur | — |
| J1 | δ̂* = 1 | BP | V3a | 995 | oui | 0,1116 [0,0927 ; 0,1328] | compatible | 0 / 16, 0,000641 | 0,0533 [0,0402 ; 0,0691] | compatible | 0 / 17, 0,000336 |
| J1 | δ̂* = 1 | BP | V3b | 995 | oui | 0,1095 [0,0908 ; 0,1306] | compatible | 0 / 18, 0,00016 | 0,0573 [0,0437 ; 0,0736] | compatible | 0 / 13, 0,00513 |
| J1 | δ̂* = 1 | BP | V3h | 995 | oui | 0,1276 [0,1075 ; 0,1500] | écart mineur | 0 / 0, 1 | 0,0704 [0,0552 ; 0,0881] | écart mineur | 0 / 0, 1 |
| J1 | δ̂* = 1 | BP79 | V1 | 995 | oui | 0,1216 [0,1019 ; 0,1435] | écart mineur | — | 0,0643 [0,0499 ; 0,0814] | compatible | — |
| J1 | δ̂* = 1 | BP79 | V3a | 995 | oui | 0,0925 [0,0752 ; 0,1122] | compatible | 0 / 29, 8,2e-08 | 0,0492 [0,0367 ; 0,0646] | compatible | 0 / 15, 0,00128 |
| J1 | δ̂* = 1 | BP79 | V3b | 995 | oui | 0,0945 [0,0770 ; 0,1144] | compatible | 0 / 27, 3,28e-07 | 0,0503 [0,0375 ; 0,0657] | compatible | 0 / 14, 0,00269 |
| J1 | δ̂* = 1 | BP79 | V3h | 995 | oui | 0,1216 [0,1019 ; 0,1435] | écart mineur | 0 / 0, 1 | 0,0643 [0,0499 ; 0,0814] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | White | V1 | 995 | oui | 0,1296 [0,1094 ; 0,1521] | écart mineur | — | 0,0613 [0,0472 ; 0,0781] | compatible | — |
| J1 | δ̂* = 1 | White | V3a | 995 | oui | 0,1146 [0,0954 ; 0,1360] | compatible | 1 / 16, 0,00549 | 0,0523 [0,0393 ; 0,0680] | compatible | 0 / 9, 0,0781 |
| J1 | δ̂* = 1 | White | V3b | 995 | oui | 0,1106 [0,0917 ; 0,1317] | compatible | 1 / 20, 0,00042 | 0,0543 [0,0410 ; 0,0702] | compatible | 0 / 7, 0,313 |
| J1 | δ̂* = 1 | White | V3h | 995 | oui | 0,1296 [0,1094 ; 0,1521] | écart mineur | 0 / 0, 1 | 0,0613 [0,0472 ; 0,0781] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | GQ | V1 | 995 | oui | 0,1035 [0,0853 ; 0,1241] | compatible | — | 0,0362 [0,0255 ; 0,0497] | écart mineur | — |
| J1 | δ̂* = 1 | GQ | V3a | 995 | oui | 0,0834 [0,0670 ; 0,1024] | compatible | 45 / 65, 1 | 0,0412 [0,0297 ; 0,0555] | compatible | 25 / 20, 1 |
| J1 | δ̂* = 1 | GQ | V3b | 995 | oui | 0,0834 [0,0670 ; 0,1024] | compatible | 46 / 66, 1 | 0,0382 [0,0272 ; 0,0520] | compatible | 25 / 23, 1 |
| J1 | δ̂* = 1 | GQ | V3h | 995 | oui | 0,1035 [0,0853 ; 0,1241] | compatible | 0 / 0, 1 | 0,0362 [0,0255 ; 0,0497] | écart mineur | 0 / 0, 1 |
| J1 | δ̂* = 1 | BF | V1 | 995 | oui | 0,1166 [0,0973 ; 0,1382] | compatible | — | 0,0643 [0,0499 ; 0,0814] | compatible | — |
| J1 | δ̂* = 1 | BF | V3a | 995 | oui | 0,1075 [0,0890 ; 0,1285] | compatible | 0 / 9, 0,0703 | 0,0603 [0,0463 ; 0,0769] | compatible | 2 / 6, 1 |
| J1 | δ̂* = 1 | BF | V3b | 995 | oui | 0,1095 [0,0908 ; 0,1306] | compatible | 1 / 8, 0,664 | 0,0573 [0,0437 ; 0,0736] | compatible | 0 / 7, 0,313 |
| J1 | δ̂* = 1 | BF | V3h | 995 | oui | 0,1166 [0,0973 ; 0,1382] | compatible | 0 / 0, 1 | 0,0643 [0,0499 ; 0,0814] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | Smirnov | V1 | 995 | oui | 0,0312 [0,0213 ; 0,0439] | compatible | — | 0,0312 [0,0213 ; 0,0439] | compatible | — |
| J1 | δ̂* = 1 | Smirnov | V3a | 995 | oui | 0,0312 [0,0213 ; 0,0439] | compatible | 0 / 0, 1 | 0,0312 [0,0213 ; 0,0439] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | Smirnov | V3b | 995 | oui | 0,0312 [0,0213 ; 0,0439] | compatible | 0 / 0, 1 | 0,0312 [0,0213 ; 0,0439] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | Smirnov | V3h | 995 | oui | 0,0312 [0,0213 ; 0,0439] | compatible | 0 / 0, 1 | 0,0312 [0,0213 ; 0,0439] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | LB2 | V1 | 995 | oui | 0,1015 [0,0834 ; 0,1220] | compatible | — | 0,0432 [0,0314 ; 0,0578] | compatible | — |
| J1 | δ̂* = 1 | LB2 | V3a | 995 | oui | 0,1005 [0,0825 ; 0,1209] | compatible | 5 / 6, 1 | 0,0422 [0,0306 ; 0,0566] | compatible | 1 / 2, 1 |
| J1 | δ̂* = 1 | LB2 | V3b | 995 | oui | 0,1015 [0,0834 ; 0,1220] | compatible | 5 / 5, 1 | 0,0402 [0,0289 ; 0,0543] | compatible | 0 / 3, 1 |
| J1 | δ̂* = 1 | LB2 | V3h | 995 | oui | 0,1015 [0,0834 ; 0,1220] | compatible | 0 / 0, 1 | 0,0432 [0,0314 ; 0,0578] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | BP2 | V1 | 995 | oui | 0,0995 [0,0816 ; 0,1198] | compatible | — | 0,0482 [0,0358 ; 0,0635] | compatible | — |
| J1 | δ̂* = 1 | BP2 | V3a | 995 | oui | 0,0935 [0,0761 ; 0,1133] | compatible | 0 / 6, 0,531 | 0,0462 [0,0340 ; 0,0612] | compatible | 1 / 3, 1 |
| J1 | δ̂* = 1 | BP2 | V3b | 995 | oui | 0,0955 [0,0779 ; 0,1155] | compatible | 2 / 6, 1 | 0,0462 [0,0340 ; 0,0612] | compatible | 2 / 4, 1 |
| J1 | δ̂* = 1 | BP2 | V3h | 995 | oui | 0,0995 [0,0816 ; 0,1198] | compatible | 0 / 0, 1 | 0,0482 [0,0358 ; 0,0635] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | Runs | V1 | 995 | oui | 0,0583 [0,0446 ; 0,0747] | compatible | — | 0,0111 [0,0055 ; 0,0197] | compatible | — |
| J1 | δ̂* = 1 | Runs | V3a | 995 | oui | 0,0573 [0,0437 ; 0,0736] | compatible | 0 / 1, 1 | 0,0211 [0,0131 ; 0,0321] | écart non tranché | 11 / 1, 0,0762 |
| J1 | δ̂* = 1 | Runs | V3b | 995 | oui | 0,0583 [0,0446 ; 0,0747] | compatible | 0 / 0, 1 | 0,0121 [0,0062 ; 0,0210] | compatible | 7 / 6, 1 |
| J1 | δ̂* = 1 | Runs | V3h | 995 | oui | 0,0583 [0,0446 ; 0,0747] | compatible | 0 / 0, 1 | 0,0111 [0,0055 ; 0,0197] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | MK | V1 | 995 | oui | 0,0774 [0,0616 ; 0,0958] | compatible | — | 0,0382 [0,0272 ; 0,0520] | compatible | — |
| J1 | δ̂* = 1 | MK | V3a | 995 | oui | 0,0844 [0,0679 ; 0,1035] | compatible | 9 / 2, 1 | 0,0392 [0,0280 ; 0,0532] | compatible | 3 / 2, 1 |
| J1 | δ̂* = 1 | MK | V3b | 995 | oui | 0,0824 [0,0661 ; 0,1013] | compatible | 9 / 4, 1 | 0,0362 [0,0255 ; 0,0497] | compatible | 3 / 5, 1 |
| J1 | δ̂* = 1 | MK | V3h | 995 | oui | 0,0774 [0,0616 ; 0,0958] | compatible | 0 / 0, 1 | 0,0382 [0,0272 ; 0,0520] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | SpearVol | V1 | 995 | oui | 0,0854 [0,0688 ; 0,1045] | compatible | — | 0,0442 [0,0323 ; 0,0589] | compatible | — |
| J1 | δ̂* = 1 | SpearVol | V3a | 995 | oui | 0,0915 [0,0743 ; 0,1111] | compatible | 12 / 6, 1 | 0,0462 [0,0340 ; 0,0612] | compatible | 5 / 3, 1 |
| J1 | δ̂* = 1 | SpearVol | V3b | 995 | oui | 0,0925 [0,0752 ; 0,1122] | compatible | 13 / 6, 1 | 0,0482 [0,0358 ; 0,0635] | compatible | 6 / 2, 1 |
| J1 | δ̂* = 1 | SpearVol | V3h | 995 | oui | 0,0854 [0,0688 ; 0,1045] | compatible | 0 / 0, 1 | 0,0442 [0,0323 ; 0,0589] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | SpearTps | V1 | 995 | oui | 0,0925 [0,0752 ; 0,1122] | compatible | — | 0,0482 [0,0358 ; 0,0635] | compatible | — |
| J1 | δ̂* = 1 | SpearTps | V3a | 995 | oui | 0,0905 [0,0734 ; 0,1100] | compatible | 4 / 6, 1 | 0,0503 [0,0375 ; 0,0657] | compatible | 5 / 3, 1 |
| J1 | δ̂* = 1 | SpearTps | V3b | 995 | oui | 0,0925 [0,0752 ; 0,1122] | compatible | 4 / 4, 1 | 0,0452 [0,0332 ; 0,0601] | compatible | 4 / 7, 1 |
| J1 | δ̂* = 1 | SpearTps | V3h | 995 | oui | 0,0925 [0,0752 ; 0,1122] | compatible | 0 / 0, 1 | 0,0482 [0,0358 ; 0,0635] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | DAgo | V1 | 995 | oui | 0,0894 [0,0724 ; 0,1089] | compatible | — | 0,0452 [0,0332 ; 0,0601] | compatible | — |
| J1 | δ̂* = 1 | DAgo | V3a | 995 | oui | 0,0834 [0,0670 ; 0,1024] | compatible | 2 / 8, 1 | 0,0422 [0,0306 ; 0,0566] | compatible | 3 / 6, 1 |
| J1 | δ̂* = 1 | DAgo | V3b | 995 | oui | 0,0814 [0,0652 ; 0,1002] | compatible | 4 / 12, 1 | 0,0442 [0,0323 ; 0,0589] | compatible | 2 / 3, 1 |
| J1 | δ̂* = 1 | DAgo | V3h | 995 | oui | 0,0894 [0,0724 ; 0,1089] | compatible | 0 / 0, 1 | 0,0452 [0,0332 ; 0,0601] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | CoxStuart | V1 | 995 | oui | 0,0000 [0,0000 ; 0,0037] | compatible | — | 0,0000 [0,0000 ; 0,0037] | compatible | — |
| J1 | δ̂* = 1 | CoxStuart | V3a | 995 | oui | 0,0050 [0,0016 ; 0,0117] | écart à examiner (bande non applicable) | 5 / 0, 0,688 | 0,0000 [0,0000 ; 0,0037] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | CoxStuart | V3b | 995 | oui | 0,0020 [0,0002 ; 0,0072] | compatible | 2 / 0, 1 | 0,0000 [0,0000 ; 0,0037] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | CoxStuart | V3h | 995 | oui | 0,0000 [0,0000 ; 0,0037] | compatible | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0037] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | DWr | V1 | 995 | oui | 0,1196 [0,1001 ; 0,1414] | écart mineur | — | 0,0503 [0,0375 ; 0,0657] | compatible | — |
| J1 | δ̂* = 1 | DWr | V3a | 995 | oui | 0,1186 [0,0992 ; 0,1403] | compatible | 6 / 7, 1 | 0,0503 [0,0375 ; 0,0657] | compatible | 5 / 5, 1 |
| J1 | δ̂* = 1 | DWr | V3b | 995 | oui | 0,1176 [0,0982 ; 0,1392] | compatible | 5 / 7, 1 | 0,0482 [0,0358 ; 0,0635] | compatible | 3 / 5, 1 |
| J1 | δ̂* = 1 | DWr | V3h | 995 | oui | 0,1196 [0,1001 ; 0,1414] | écart mineur | 0 / 0, 1 | 0,0503 [0,0375 ; 0,0657] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | LB1r | V1 | 995 | oui | 0,1045 [0,0862 ; 0,1252] | compatible | — | 0,0543 [0,0410 ; 0,0702] | compatible | — |
| J1 | δ̂* = 1 | LB1r | V3a | 995 | oui | 0,1005 [0,0825 ; 0,1209] | compatible | 2 / 6, 1 | 0,0553 [0,0419 ; 0,0713] | compatible | 4 / 3, 1 |
| J1 | δ̂* = 1 | LB1r | V3b | 995 | oui | 0,1035 [0,0853 ; 0,1241] | compatible | 3 / 4, 1 | 0,0543 [0,0410 ; 0,0702] | compatible | 5 / 5, 1 |
| J1 | δ̂* = 1 | LB1r | V3h | 995 | oui | 0,1045 [0,0862 ; 0,1252] | compatible | 0 / 0, 1 | 0,0543 [0,0410 ; 0,0702] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | Runsr | V1 | 995 | oui | 0,0583 [0,0446 ; 0,0747] | compatible | — | 0,0111 [0,0055 ; 0,0197] | compatible | — |
| J1 | δ̂* = 1 | Runsr | V3a | 995 | oui | 0,0573 [0,0437 ; 0,0736] | compatible | 0 / 1, 1 | 0,0211 [0,0131 ; 0,0321] | écart non tranché | 11 / 1, 0,0762 |
| J1 | δ̂* = 1 | Runsr | V3b | 995 | oui | 0,0583 [0,0446 ; 0,0747] | compatible | 0 / 0, 1 | 0,0121 [0,0062 ; 0,0210] | compatible | 7 / 6, 1 |
| J1 | δ̂* = 1 | Runsr | V3h | 995 | oui | 0,0583 [0,0446 ; 0,0747] | compatible | 0 / 0, 1 | 0,0111 [0,0055 ; 0,0197] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | supFr | V1 | 995 | oui | 0,1005 [0,0825 ; 0,1209] | compatible | — | 0,0553 [0,0419 ; 0,0713] | compatible | — |
| J1 | δ̂* = 1 | supFr | V3a | 995 | oui | 0,0995 [0,0816 ; 0,1198] | compatible | 3 / 4, 1 | 0,0613 [0,0472 ; 0,0781] | compatible | 6 / 0, 0,563 |
| J1 | δ̂* = 1 | supFr | V3b | 995 | oui | 0,1015 [0,0834 ; 0,1220] | compatible | 5 / 4, 1 | 0,0593 [0,0454 ; 0,0758] | compatible | 4 / 0, 1 |
| J1 | δ̂* = 1 | supFr | V3h | 995 | oui | 0,1005 [0,0825 ; 0,1209] | compatible | 0 / 0, 1 | 0,0553 [0,0419 ; 0,0713] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | CUSUMr | V1 | 995 | oui | 0,1075 [0,0890 ; 0,1285] | compatible | — | 0,0543 [0,0410 ; 0,0702] | compatible | — |
| J1 | δ̂* = 1 | CUSUMr | V3a | 995 | oui | 0,1126 [0,0936 ; 0,1339] | compatible | 6 / 1, 1 | 0,0523 [0,0393 ; 0,0680] | compatible | 0 / 2, 1 |
| J1 | δ̂* = 1 | CUSUMr | V3b | 995 | oui | 0,1095 [0,0908 ; 0,1306] | compatible | 4 / 2, 1 | 0,0543 [0,0410 ; 0,0702] | compatible | 1 / 1, 1 |
| J1 | δ̂* = 1 | CUSUMr | V3h | 995 | oui | 0,1075 [0,0890 ; 0,1285] | compatible | 0 / 0, 1 | 0,0543 [0,0410 ; 0,0702] | compatible | 0 / 0, 1 |
| J1 | δ̂* = 1 | Grubbsr | V1 | 995 | oui | 0,1025 [0,0844 ; 0,1231] | compatible | — | 0,0513 [0,0384 ; 0,0668] | compatible | — |
| J1 | δ̂* = 1 | Grubbsr | V3a | 995 | oui | 0,1025 [0,0844 ; 0,1231] | compatible | 4 / 4, 1 | 0,0492 [0,0367 ; 0,0646] | compatible | 2 / 4, 1 |
| J1 | δ̂* = 1 | Grubbsr | V3b | 995 | oui | 0,0985 [0,0807 ; 0,1187] | compatible | 0 / 4, 1 | 0,0492 [0,0367 ; 0,0646] | compatible | 1 / 3, 1 |
| J1 | δ̂* = 1 | Grubbsr | V3h | 995 | oui | 0,1025 [0,0844 ; 0,1231] | compatible | 0 / 0, 1 | 0,0513 [0,0384 ; 0,0668] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | AD | V1 | 814 | oui | 0,1118 [0,0910 ; 0,1355] | compatible | — | 0,0553 [0,0406 ; 0,0733] | compatible | — |
| J2 | δ̂* = 0 | AD | V3a | 814 | oui | 0,1057 [0,0854 ; 0,1288] | compatible | 2 / 7, 1 | 0,0504 [0,0364 ; 0,0677] | compatible | 0 / 4, 1 |
| J2 | δ̂* = 0 | AD | V3b | 814 | oui | 0,1057 [0,0854 ; 0,1288] | compatible | 1 / 6, 1 | 0,0491 [0,0353 ; 0,0663] | compatible | 0 / 5, 0,688 |
| J2 | δ̂* = 0 | AD | V3h | 814 | oui | 0,1118 [0,0910 ; 0,1355] | compatible | 0 / 0, 1 | 0,0553 [0,0406 ; 0,0733] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | CvM | V1 | 814 | oui | 0,0946 [0,0754 ; 0,1168] | compatible | — | 0,0541 [0,0395 ; 0,0719] | compatible | — |
| J2 | δ̂* = 0 | CvM | V3a | 814 | oui | 0,0971 [0,0776 ; 0,1195] | compatible | 3 / 1, 1 | 0,0553 [0,0406 ; 0,0733] | compatible | 1 / 0, 1 |
| J2 | δ̂* = 0 | CvM | V3b | 814 | oui | 0,0958 [0,0765 ; 0,1181] | compatible | 3 / 2, 1 | 0,0516 [0,0374 ; 0,0691] | compatible | 1 / 3, 1 |
| J2 | δ̂* = 0 | CvM | V3h | 814 | oui | 0,0946 [0,0754 ; 0,1168] | compatible | 0 / 0, 1 | 0,0541 [0,0395 ; 0,0719] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | KS | V1 | 814 | oui | 0,0946 [0,0754 ; 0,1168] | compatible | — | 0,0418 [0,0291 ; 0,0579] | compatible | — |
| J2 | δ̂* = 0 | KS | V3a | 814 | oui | 0,0958 [0,0765 ; 0,1181] | compatible | 5 / 4, 1 | 0,0393 [0,0270 ; 0,0550] | compatible | 0 / 2, 1 |
| J2 | δ̂* = 0 | KS | V3b | 814 | oui | 0,0971 [0,0776 ; 0,1195] | compatible | 6 / 4, 1 | 0,0381 [0,0260 ; 0,0536] | compatible | 0 / 3, 1 |
| J2 | δ̂* = 0 | KS | V3h | 814 | oui | 0,0946 [0,0754 ; 0,1168] | compatible | 0 / 0, 1 | 0,0418 [0,0291 ; 0,0579] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | SW | V1 | 814 | oui | 0,1032 [0,0831 ; 0,1262] | compatible | — | 0,0528 [0,0385 ; 0,0705] | compatible | — |
| J2 | δ̂* = 0 | SW | V3a | 814 | oui | 0,0983 [0,0787 ; 0,1208] | compatible | 0 / 4, 1 | 0,0504 [0,0364 ; 0,0677] | compatible | 1 / 3, 1 |
| J2 | δ̂* = 0 | SW | V3b | 814 | oui | 0,0958 [0,0765 ; 0,1181] | compatible | 0 / 6, 0,375 | 0,0516 [0,0374 ; 0,0691] | compatible | 1 / 2, 1 |
| J2 | δ̂* = 0 | SW | V3h | 814 | oui | 0,1032 [0,0831 ; 0,1262] | compatible | 0 / 0, 1 | 0,0528 [0,0385 ; 0,0705] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | SF | V1 | 814 | oui | 0,1057 [0,0854 ; 0,1288] | compatible | — | 0,0553 [0,0406 ; 0,0733] | compatible | — |
| J2 | δ̂* = 0 | SF | V3a | 814 | oui | 0,0921 [0,0732 ; 0,1141] | compatible | 0 / 11, 0,00781 | 0,0455 [0,0322 ; 0,0621] | compatible | 0 / 8, 0,0781 |
| J2 | δ̂* = 0 | SF | V3b | 814 | oui | 0,0885 [0,0699 ; 0,1101] | compatible | 0 / 14, 0,000977 | 0,0430 [0,0301 ; 0,0593] | compatible | 0 / 10, 0,0254 |
| J2 | δ̂* = 0 | SF | V3h | 814 | oui | 0,1057 [0,0854 ; 0,1288] | compatible | 0 / 0, 1 | 0,0553 [0,0406 ; 0,0733] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | JB | V1 | 814 | oui | 0,1093 [0,0887 ; 0,1328] | compatible | — | 0,0504 [0,0364 ; 0,0677] | compatible | — |
| J2 | δ̂* = 0 | JB | V3a | 814 | oui | 0,0860 [0,0676 ; 0,1074] | compatible | 0 / 19, 6,87e-05 | 0,0393 [0,0270 ; 0,0550] | compatible | 0 / 9, 0,043 |
| J2 | δ̂* = 0 | JB | V3b | 814 | oui | 0,0897 [0,0710 ; 0,1114] | compatible | 0 / 16, 0,000427 | 0,0430 [0,0301 ; 0,0593] | compatible | 0 / 6, 0,281 |
| J2 | δ̂* = 0 | JB | V3h | 814 | oui | 0,1093 [0,0887 ; 0,1328] | compatible | 0 / 0, 1 | 0,0504 [0,0364 ; 0,0677] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | DW | V1 | 814 | oui | 0,1069 [0,0865 ; 0,1302] | compatible | — | 0,0455 [0,0322 ; 0,0621] | compatible | — |
| J2 | δ̂* = 0 | DW | V3a | 814 | oui | 0,0958 [0,0765 ; 0,1181] | compatible | 6 / 15, 0,352 | 0,0455 [0,0322 ; 0,0621] | compatible | 6 / 6, 1 |
| J2 | δ̂* = 0 | DW | V3b | 814 | oui | 0,1007 [0,0809 ; 0,1235] | compatible | 7 / 12, 1 | 0,0442 [0,0312 ; 0,0607] | compatible | 5 / 6, 1 |
| J2 | δ̂* = 0 | DW | V3h | 814 | oui | 0,1069 [0,0865 ; 0,1302] | compatible | 0 / 0, 1 | 0,0455 [0,0322 ; 0,0621] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | LB1 | V1 | 814 | oui | 0,0971 [0,0776 ; 0,1195] | compatible | — | 0,0393 [0,0270 ; 0,0550] | compatible | — |
| J2 | δ̂* = 0 | LB1 | V3a | 814 | oui | 0,1032 [0,0831 ; 0,1262] | compatible | 5 / 0, 0,75 | 0,0418 [0,0291 ; 0,0579] | compatible | 2 / 0, 1 |
| J2 | δ̂* = 0 | LB1 | V3b | 814 | oui | 0,1007 [0,0809 ; 0,1235] | compatible | 4 / 1, 1 | 0,0381 [0,0260 ; 0,0536] | compatible | 1 / 2, 1 |
| J2 | δ̂* = 0 | LB1 | V3h | 814 | oui | 0,0971 [0,0776 ; 0,1195] | compatible | 0 / 0, 1 | 0,0393 [0,0270 ; 0,0550] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | supF | V1 | 814 | oui | 0,1130 [0,0921 ; 0,1368] | compatible | — | 0,0614 [0,0459 ; 0,0802] | compatible | — |
| J2 | δ̂* = 0 | supF | V3a | 814 | oui | 0,0921 [0,0732 ; 0,1141] | compatible | 1 / 18, 0,000732 | 0,0577 [0,0427 ; 0,0760] | compatible | 0 / 3, 1 |
| J2 | δ̂* = 0 | supF | V3b | 814 | oui | 0,0872 [0,0687 ; 0,1087] | compatible | 0 / 21, 1,91e-05 | 0,0541 [0,0395 ; 0,0719] | compatible | 0 / 6, 0,281 |
| J2 | δ̂* = 0 | supF | V3h | 814 | oui | 0,1130 [0,0921 ; 0,1368] | compatible | 0 / 0, 1 | 0,0614 [0,0459 ; 0,0802] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | CUSUM | V1 | 814 | oui | 0,1069 [0,0865 ; 0,1302] | compatible | — | 0,0491 [0,0353 ; 0,0663] | compatible | — |
| J2 | δ̂* = 0 | CUSUM | V3a | 814 | oui | 0,1032 [0,0831 ; 0,1262] | compatible | 2 / 5, 1 | 0,0479 [0,0343 ; 0,0649] | compatible | 0 / 1, 1 |
| J2 | δ̂* = 0 | CUSUM | V3b | 814 | oui | 0,1020 [0,0820 ; 0,1248] | compatible | 3 / 7, 1 | 0,0491 [0,0353 ; 0,0663] | compatible | 1 / 1, 1 |
| J2 | δ̂* = 0 | CUSUM | V3h | 814 | oui | 0,1069 [0,0865 ; 0,1302] | compatible | 0 / 0, 1 | 0,0491 [0,0353 ; 0,0663] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | Grubbs | V1 | 814 | oui | 0,1069 [0,0865 ; 0,1302] | compatible | — | 0,0541 [0,0395 ; 0,0719] | compatible | — |
| J2 | δ̂* = 0 | Grubbs | V3a | 814 | oui | 0,0885 [0,0699 ; 0,1101] | compatible | 0 / 15, 0,000732 | 0,0369 [0,0250 ; 0,0522] | compatible | 0 / 14, 0,0022 |
| J2 | δ̂* = 0 | Grubbs | V3b | 814 | oui | 0,0885 [0,0699 ; 0,1101] | compatible | 0 / 15, 0,00061 | 0,0393 [0,0270 ; 0,0550] | compatible | 0 / 12, 0,00781 |
| J2 | δ̂* = 0 | Grubbs | V3h | 814 | oui | 0,1069 [0,0865 ; 0,1302] | compatible | 0 / 0, 1 | 0,0541 [0,0395 ; 0,0719] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | Lillie | V1 | 814 | oui | 0,1020 [0,0820 ; 0,1248] | compatible | — | 0,0590 [0,0438 ; 0,0774] | compatible | — |
| J2 | δ̂* = 0 | Lillie | V3a | 814 | oui | 0,0983 [0,0787 ; 0,1208] | compatible | 0 / 3, 1 | 0,0528 [0,0385 ; 0,0705] | compatible | 1 / 6, 1 |
| J2 | δ̂* = 0 | Lillie | V3b | 814 | oui | 0,0995 [0,0798 ; 0,1222] | compatible | 1 / 3, 1 | 0,0479 [0,0343 ; 0,0649] | compatible | 0 / 9, 0,0469 |
| J2 | δ̂* = 0 | Lillie | V3h | 814 | oui | 0,1020 [0,0820 ; 0,1248] | compatible | 0 / 0, 1 | 0,0590 [0,0438 ; 0,0774] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | Intercept | V1 | 814 | oui | 0,0983 [0,0787 ; 0,1208] | compatible | — | 0,0504 [0,0364 ; 0,0677] | compatible | — |
| J2 | δ̂* = 0 | Intercept | V3a | 814 | oui | 0,1020 [0,0820 ; 0,1248] | compatible | 5 / 2, 1 | 0,0479 [0,0343 ; 0,0649] | compatible | 1 / 3, 1 |
| J2 | δ̂* = 0 | Intercept | V3b | 814 | oui | 0,0921 [0,0732 ; 0,1141] | compatible | 1 / 6, 1 | 0,0467 [0,0332 ; 0,0635] | compatible | 0 / 3, 1 |
| J2 | δ̂* = 0 | Intercept | V3h | 814 | oui | 0,0983 [0,0787 ; 0,1208] | compatible | 0 / 0, 1 | 0,0504 [0,0364 ; 0,0677] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | RESET | V1 | 814 | oui | 0,0283 [0,0180 ; 0,0421] **conservateur** | distorsion matérielle | — | 0,0111 [0,0051 ; 0,0209] **conservateur** | distorsion matérielle | — |
| J2 | δ̂* = 0 | RESET | V3a | 814 | oui | 0,1032 [0,0831 ; 0,1262] | compatible | 61 / 0, 1,91e-17 | 0,0528 [0,0385 ; 0,0705] | compatible | 34 / 0, 2,56e-09 |
| J2 | δ̂* = 0 | RESET | V3b | 814 | oui | 0,1007 [0,0809 ; 0,1235] | compatible | 59 / 0, 7,63e-17 | 0,0541 [0,0395 ; 0,0719] | compatible | 35 / 0, 1,28e-09 |
| J2 | δ̂* = 0 | RESET | V3h | 814 | oui | 0,0283 [0,0180 ; 0,0421] **conservateur** | distorsion matérielle | 0 / 0, 1 | 0,0111 [0,0051 ; 0,0209] **conservateur** | distorsion matérielle | 0 / 0, 1 |
| J2 | δ̂* = 0 | BP | V1 | 814 | oui | 0,1020 [0,0820 ; 0,1248] | compatible | — | 0,0455 [0,0322 ; 0,0621] | compatible | — |
| J2 | δ̂* = 0 | BP | V3a | 814 | oui | 0,0835 [0,0655 ; 0,1047] | compatible | 0 / 15, 0,000732 | 0,0369 [0,0250 ; 0,0522] | compatible | 0 / 7, 0,141 |
| J2 | δ̂* = 0 | BP | V3b | 814 | oui | 0,0823 [0,0644 ; 0,1034] | compatible | 0 / 16, 0,000427 | 0,0393 [0,0270 ; 0,0550] | compatible | 3 / 8, 0,906 |
| J2 | δ̂* = 0 | BP | V3h | 814 | oui | 0,1020 [0,0820 ; 0,1248] | compatible | 0 / 0, 1 | 0,0455 [0,0322 ; 0,0621] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | BP79 | V1 | 814 | oui | 0,0835 [0,0655 ; 0,1047] | compatible | — | 0,0356 [0,0240 ; 0,0508] | compatible | — |
| J2 | δ̂* = 0 | BP79 | V3a | 814 | oui | 0,0627 [0,0470 ; 0,0816] | écart mineur | 0 / 17, 0,000229 | 0,0295 [0,0190 ; 0,0436] | écart mineur | 0 / 5, 0,5 |
| J2 | δ̂* = 0 | BP79 | V3b | 814 | oui | 0,0639 [0,0481 ; 0,0829] | écart mineur | 0 / 16, 0,000427 | 0,0295 [0,0190 ; 0,0436] | écart mineur | 0 / 5, 0,438 |
| J2 | δ̂* = 0 | BP79 | V3h | 814 | oui | 0,0835 [0,0655 ; 0,1047] | compatible | 0 / 0, 1 | 0,0356 [0,0240 ; 0,0508] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | White | V1 | 814 | oui | 0,0516 [0,0374 ; 0,0691] | écart mineur | — | 0,0197 [0,0113 ; 0,0317] | écart non tranché | — |
| J2 | δ̂* = 0 | White | V3a | 814 | oui | 0,0725 [0,0556 ; 0,0925] | écart mineur | 17 / 0, 0,000229 | 0,0332 [0,0220 ; 0,0479] | écart mineur | 11 / 0, 0,0137 |
| J2 | δ̂* = 0 | White | V3b | 814 | oui | 0,0737 [0,0567 ; 0,0939] | écart mineur | 18 / 0, 0,00013 | 0,0356 [0,0240 ; 0,0508] | compatible | 13 / 0, 0,00415 |
| J2 | δ̂* = 0 | White | V3h | 814 | oui | 0,0516 [0,0374 ; 0,0691] | écart mineur | 0 / 0, 1 | 0,0197 [0,0113 ; 0,0317] | écart non tranché | 0 / 0, 1 |
| J2 | δ̂* = 0 | GQ | V1 | 814 | oui | 0,0688 [0,0524 ; 0,0884] | écart mineur | — | 0,0356 [0,0240 ; 0,0508] | compatible | — |
| J2 | δ̂* = 0 | GQ | V3a | 814 | oui | 0,0921 [0,0732 ; 0,1141] | compatible | 39 / 20, 0,11 | 0,0479 [0,0343 ; 0,0649] | compatible | 17 / 7, 0,5 |
| J2 | δ̂* = 0 | GQ | V3b | 814 | oui | 0,0946 [0,0754 ; 0,1168] | compatible | 39 / 18, 0,045 | 0,0516 [0,0374 ; 0,0691] | compatible | 19 / 6, 0,146 |
| J2 | δ̂* = 0 | GQ | V3h | 814 | oui | 0,0688 [0,0524 ; 0,0884] | écart mineur | 0 / 0, 1 | 0,0356 [0,0240 ; 0,0508] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | BF | V1 | 814 | oui | 0,1044 [0,0843 ; 0,1275] | compatible | — | 0,0590 [0,0438 ; 0,0774] | compatible | — |
| J2 | δ̂* = 0 | BF | V3a | 814 | oui | 0,0860 [0,0676 ; 0,1074] | compatible | 0 / 15, 0,000732 | 0,0467 [0,0332 ; 0,0635] | compatible | 0 / 10, 0,0234 |
| J2 | δ̂* = 0 | BF | V3b | 814 | oui | 0,0860 [0,0676 ; 0,1074] | compatible | 0 / 15, 0,00061 | 0,0467 [0,0332 ; 0,0635] | compatible | 0 / 10, 0,0254 |
| J2 | δ̂* = 0 | BF | V3h | 814 | oui | 0,1044 [0,0843 ; 0,1275] | compatible | 0 / 0, 1 | 0,0590 [0,0438 ; 0,0774] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | Smirnov | V1 | 814 | oui | 0,0381 [0,0260 ; 0,0536] | compatible | — | 0,0381 [0,0260 ; 0,0536] | compatible | — |
| J2 | δ̂* = 0 | Smirnov | V3a | 814 | oui | 0,0381 [0,0260 ; 0,0536] | compatible | 0 / 0, 1 | 0,0381 [0,0260 ; 0,0536] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | Smirnov | V3b | 814 | oui | 0,0381 [0,0260 ; 0,0536] | compatible | 0 / 0, 1 | 0,0381 [0,0260 ; 0,0536] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | Smirnov | V3h | 814 | oui | 0,0381 [0,0260 ; 0,0536] | compatible | 0 / 0, 1 | 0,0381 [0,0260 ; 0,0536] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | LB2 | V1 | 814 | oui | 0,0811 [0,0633 ; 0,1020] | compatible | — | 0,0344 [0,0230 ; 0,0493] | écart mineur | — |
| J2 | δ̂* = 0 | LB2 | V3a | 814 | oui | 0,1032 [0,0831 ; 0,1262] | compatible | 18 / 0, 0,000122 | 0,0504 [0,0364 ; 0,0677] | compatible | 13 / 0, 0,00415 |
| J2 | δ̂* = 0 | LB2 | V3b | 814 | oui | 0,1007 [0,0809 ; 0,1235] | compatible | 16 / 0, 0,000427 | 0,0516 [0,0374 ; 0,0691] | compatible | 14 / 0, 0,0022 |
| J2 | δ̂* = 0 | LB2 | V3h | 814 | oui | 0,0811 [0,0633 ; 0,1020] | compatible | 0 / 0, 1 | 0,0344 [0,0230 ; 0,0493] | écart mineur | 0 / 0, 1 |
| J2 | δ̂* = 0 | BP2 | V1 | 814 | oui | 0,0799 [0,0622 ; 0,1006] | compatible | — | 0,0369 [0,0250 ; 0,0522] | compatible | — |
| J2 | δ̂* = 0 | BP2 | V3a | 814 | oui | 0,1007 [0,0809 ; 0,1235] | compatible | 17 / 0, 0,000229 | 0,0553 [0,0406 ; 0,0733] | compatible | 15 / 0, 0,00116 |
| J2 | δ̂* = 0 | BP2 | V3b | 814 | oui | 0,1007 [0,0809 ; 0,1235] | compatible | 17 / 0, 0,000229 | 0,0553 [0,0406 ; 0,0733] | compatible | 15 / 0, 0,00116 |
| J2 | δ̂* = 0 | BP2 | V3h | 814 | oui | 0,0799 [0,0622 ; 0,1006] | compatible | 0 / 0, 1 | 0,0369 [0,0250 ; 0,0522] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | Runs | V1 | 814 | oui | 0,0700 [0,0535 ; 0,0898] | compatible | — | 0,0086 [0,0035 ; 0,0176] | compatible | — |
| J2 | δ̂* = 0 | Runs | V3a | 814 | oui | 0,0700 [0,0535 ; 0,0898] | compatible | 0 / 0, 1 | 0,0184 [0,0103 ; 0,0302] | écart non tranché | 8 / 0, 0,0938 |
| J2 | δ̂* = 0 | Runs | V3b | 814 | oui | 0,0700 [0,0535 ; 0,0898] | compatible | 0 / 0, 1 | 0,0147 [0,0076 ; 0,0256] | compatible | 9 / 4, 1 |
| J2 | δ̂* = 0 | Runs | V3h | 814 | oui | 0,0700 [0,0535 ; 0,0898] | compatible | 0 / 0, 1 | 0,0086 [0,0035 ; 0,0176] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | MK | V1 | 814 | oui | 0,0958 [0,0765 ; 0,1181] | écart mineur | — | 0,0516 [0,0374 ; 0,0691] | écart non tranché | — |
| J2 | δ̂* = 0 | MK | V3a | 814 | oui | 0,0823 [0,0644 ; 0,1034] | compatible | 0 / 11, 0,00781 | 0,0356 [0,0240 ; 0,0508] | compatible | 0 / 13, 0,00415 |
| J2 | δ̂* = 0 | MK | V3b | 814 | oui | 0,0811 [0,0633 ; 0,1020] | compatible | 0 / 12, 0,00342 | 0,0381 [0,0260 ; 0,0536] | compatible | 0 / 11, 0,0137 |
| J2 | δ̂* = 0 | MK | V3h | 814 | oui | 0,0958 [0,0765 ; 0,1181] | écart mineur | 0 / 0, 1 | 0,0516 [0,0374 ; 0,0691] | écart non tranché | 0 / 0, 1 |
| J2 | δ̂* = 0 | SpearVol | V1 | 814 | oui | 0,0946 [0,0754 ; 0,1168] | compatible | — | 0,0442 [0,0312 ; 0,0607] | compatible | — |
| J2 | δ̂* = 0 | SpearVol | V3a | 814 | oui | 0,0897 [0,0710 ; 0,1114] | compatible | 1 / 5, 0,656 | 0,0405 [0,0281 ; 0,0565] | compatible | 0 / 3, 1 |
| J2 | δ̂* = 0 | SpearVol | V3b | 814 | oui | 0,0921 [0,0732 ; 0,1141] | compatible | 4 / 6, 1 | 0,0442 [0,0312 ; 0,0607] | compatible | 1 / 1, 1 |
| J2 | δ̂* = 0 | SpearVol | V3h | 814 | oui | 0,0946 [0,0754 ; 0,1168] | compatible | 0 / 0, 1 | 0,0442 [0,0312 ; 0,0607] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | SpearTps | V1 | 814 | oui | 0,1167 [0,0955 ; 0,1408] | écart mineur | — | 0,0627 [0,0470 ; 0,0816] | écart mineur | — |
| J2 | δ̂* = 0 | SpearTps | V3a | 814 | oui | 0,0921 [0,0732 ; 0,1141] | compatible | 0 / 20, 3,62e-05 | 0,0381 [0,0260 ; 0,0536] | compatible | 0 / 20, 4,01e-05 |
| J2 | δ̂* = 0 | SpearTps | V3b | 814 | oui | 0,0934 [0,0743 ; 0,1155] | compatible | 0 / 19, 6,87e-05 | 0,0405 [0,0281 ; 0,0565] | compatible | 0 / 18, 0,00016 |
| J2 | δ̂* = 0 | SpearTps | V3h | 814 | oui | 0,1167 [0,0955 ; 0,1408] | écart mineur | 0 / 0, 1 | 0,0627 [0,0470 ; 0,0816] | écart mineur | 0 / 0, 1 |
| J2 | δ̂* = 0 | DAgo | V1 | 814 | oui | 0,1069 [0,0865 ; 0,1302] | compatible | — | 0,0516 [0,0374 ; 0,0691] | compatible | — |
| J2 | δ̂* = 0 | DAgo | V3a | 814 | oui | 0,0835 [0,0655 ; 0,1047] | compatible | 0 / 19, 6,87e-05 | 0,0381 [0,0260 ; 0,0536] | compatible | 0 / 11, 0,0137 |
| J2 | δ̂* = 0 | DAgo | V3b | 814 | oui | 0,0848 [0,0666 ; 0,1061] | compatible | 0 / 18, 0,00013 | 0,0393 [0,0270 ; 0,0550] | compatible | 0 / 10, 0,0254 |
| J2 | δ̂* = 0 | DAgo | V3h | 814 | oui | 0,1069 [0,0865 ; 0,1302] | compatible | 0 / 0, 1 | 0,0516 [0,0374 ; 0,0691] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | CoxStuart | V1 | 814 | oui | 0,0000 [0,0000 ; 0,0045] | compatible | — | 0,0000 [0,0000 ; 0,0045] | compatible | — |
| J2 | δ̂* = 0 | CoxStuart | V3a | 814 | oui | 0,0037 [0,0008 ; 0,0107] | écart à examiner (bande non applicable) | 3 / 0, 1 | 0,0000 [0,0000 ; 0,0045] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | CoxStuart | V3b | 814 | oui | 0,0000 [0,0000 ; 0,0045] | compatible | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0045] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | CoxStuart | V3h | 814 | oui | 0,0000 [0,0000 ; 0,0045] | compatible | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0045] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | DWr | V1 | 814 | oui | 0,0921 [0,0732 ; 0,1141] | compatible | — | 0,0479 [0,0343 ; 0,0649] | compatible | — |
| J2 | δ̂* = 0 | DWr | V3a | 814 | oui | 0,0934 [0,0743 ; 0,1155] | compatible | 15 / 14, 1 | 0,0565 [0,0417 ; 0,0747] | compatible | 10 / 3, 0,554 |
| J2 | δ̂* = 0 | DWr | V3b | 814 | oui | 0,0958 [0,0765 ; 0,1181] | compatible | 14 / 11, 1 | 0,0553 [0,0406 ; 0,0733] | compatible | 10 / 4, 0,898 |
| J2 | δ̂* = 0 | DWr | V3h | 814 | oui | 0,0921 [0,0732 ; 0,1141] | compatible | 0 / 0, 1 | 0,0479 [0,0343 ; 0,0649] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | LB1r | V1 | 814 | oui | 0,0848 [0,0666 ; 0,1061] | compatible | — | 0,0393 [0,0270 ; 0,0550] | compatible | — |
| J2 | δ̂* = 0 | LB1r | V3a | 814 | oui | 0,0921 [0,0732 ; 0,1141] | compatible | 7 / 1, 0,352 | 0,0418 [0,0291 ; 0,0579] | compatible | 3 / 1, 1 |
| J2 | δ̂* = 0 | LB1r | V3b | 814 | oui | 0,0921 [0,0732 ; 0,1141] | compatible | 6 / 0, 0,156 | 0,0442 [0,0312 ; 0,0607] | compatible | 4 / 0, 0,75 |
| J2 | δ̂* = 0 | LB1r | V3h | 814 | oui | 0,0848 [0,0666 ; 0,1061] | compatible | 0 / 0, 1 | 0,0393 [0,0270 ; 0,0550] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | Runsr | V1 | 814 | oui | 0,0627 [0,0470 ; 0,0816] | compatible | — | 0,0135 [0,0068 ; 0,0241] | compatible | — |
| J2 | δ̂* = 0 | Runsr | V3a | 814 | oui | 0,0627 [0,0470 ; 0,0816] | compatible | 0 / 0, 1 | 0,0184 [0,0103 ; 0,0302] | écart non tranché | 5 / 1, 1 |
| J2 | δ̂* = 0 | Runsr | V3b | 814 | oui | 0,0627 [0,0470 ; 0,0816] | compatible | 0 / 0, 1 | 0,0172 [0,0094 ; 0,0287] | compatible | 7 / 4, 1 |
| J2 | δ̂* = 0 | Runsr | V3h | 814 | oui | 0,0627 [0,0470 ; 0,0816] | compatible | 0 / 0, 1 | 0,0135 [0,0068 ; 0,0241] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | supFr | V1 | 814 | oui | 0,1314 [0,1090 ; 0,1566] | écart mineur | — | 0,0651 [0,0491 ; 0,0843] | compatible | — |
| J2 | δ̂* = 0 | supFr | V3a | 814 | oui | 0,1044 [0,0843 ; 0,1275] | compatible | 0 / 22, 9,54e-06 | 0,0491 [0,0353 ; 0,0663] | compatible | 0 / 13, 0,00415 |
| J2 | δ̂* = 0 | supFr | V3b | 814 | oui | 0,1057 [0,0854 ; 0,1288] | compatible | 0 / 21, 1,91e-05 | 0,0504 [0,0364 ; 0,0677] | compatible | 0 / 12, 0,00781 |
| J2 | δ̂* = 0 | supFr | V3h | 814 | oui | 0,1314 [0,1090 ; 0,1566] | écart mineur | 0 / 0, 1 | 0,0651 [0,0491 ; 0,0843] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | CUSUMr | V1 | 814 | oui | 0,1044 [0,0843 ; 0,1275] | compatible | — | 0,0528 [0,0385 ; 0,0705] | compatible | — |
| J2 | δ̂* = 0 | CUSUMr | V3a | 814 | oui | 0,1057 [0,0854 ; 0,1288] | compatible | 2 / 1, 1 | 0,0528 [0,0385 ; 0,0705] | compatible | 2 / 2, 1 |
| J2 | δ̂* = 0 | CUSUMr | V3b | 814 | oui | 0,0995 [0,0798 ; 0,1222] | compatible | 1 / 5, 0,875 | 0,0528 [0,0385 ; 0,0705] | compatible | 3 / 3, 1 |
| J2 | δ̂* = 0 | CUSUMr | V3h | 814 | oui | 0,1044 [0,0843 ; 0,1275] | compatible | 0 / 0, 1 | 0,0528 [0,0385 ; 0,0705] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 0 | Grubbsr | V1 | 814 | oui | 0,1106 [0,0898 ; 0,1341] | compatible | — | 0,0614 [0,0459 ; 0,0802] | compatible | — |
| J2 | δ̂* = 0 | Grubbsr | V3a | 814 | oui | 0,0799 [0,0622 ; 0,1006] | compatible | 0 / 25, 1,25e-06 | 0,0405 [0,0281 ; 0,0565] | compatible | 0 / 17, 0,000305 |
| J2 | δ̂* = 0 | Grubbsr | V3b | 814 | oui | 0,0774 [0,0600 ; 0,0979] | écart mineur | 0 / 27, 3,13e-07 | 0,0418 [0,0291 ; 0,0579] | compatible | 0 / 16, 0,00061 |
| J2 | δ̂* = 0 | Grubbsr | V3h | 814 | oui | 0,1106 [0,0898 ; 0,1341] | compatible | 0 / 0, 1 | 0,0614 [0,0459 ; 0,0802] | compatible | 0 / 0, 1 |
| J2 | δ̂* intérieur | AD | V1 | 464 | oui | 0,1121 [0,0848 ; 0,1444] | compatible | — | 0,0388 [0,0232 ; 0,0606] | compatible | — |
| J2 | δ̂* intérieur | AD | V3a | 464 | oui | 0,1078 [0,0810 ; 0,1396] | compatible | 3 / 5, 1 | 0,0431 [0,0265 ; 0,0658] | compatible | 4 / 2, 1 |
| J2 | δ̂* intérieur | AD | V3b | 464 | oui | 0,1121 [0,0848 ; 0,1444] | compatible | 2 / 2, 1 | 0,0388 [0,0232 ; 0,0606] | compatible | 2 / 2, 1 |
| J2 | δ̂* intérieur | AD | V3h | 464 | oui | 0,1121 [0,0848 ; 0,1444] | compatible | 2 / 2, 1 | 0,0388 [0,0232 ; 0,0606] | compatible | 2 / 2, 1 |
| J2 | δ̂* intérieur | CvM | V1 | 464 | oui | 0,1228 [0,0944 ; 0,1562] | compatible | — | 0,0496 [0,0317 ; 0,0735] | compatible | — |
| J2 | δ̂* intérieur | CvM | V3a | 464 | oui | 0,1099 [0,0829 ; 0,1420] | compatible | 1 / 7, 0,563 | 0,0474 [0,0299 ; 0,0709] | compatible | 2 / 3, 1 |
| J2 | δ̂* intérieur | CvM | V3b | 464 | oui | 0,1078 [0,0810 ; 0,1396] | compatible | 0 / 7, 0,156 | 0,0517 [0,0334 ; 0,0760] | compatible | 3 / 2, 1 |
| J2 | δ̂* intérieur | CvM | V3h | 464 | oui | 0,1078 [0,0810 ; 0,1396] | compatible | 0 / 7, 0,156 | 0,0517 [0,0334 ; 0,0760] | compatible | 3 / 2, 1 |
| J2 | δ̂* intérieur | KS | V1 | 464 | oui | 0,1034 [0,0773 ; 0,1348] | compatible | — | 0,0625 [0,0423 ; 0,0885] | compatible | — |
| J2 | δ̂* intérieur | KS | V3a | 464 | oui | 0,0970 [0,0716 ; 0,1276] | compatible | 3 / 6, 1 | 0,0582 [0,0387 ; 0,0835] | compatible | 0 / 2, 1 |
| J2 | δ̂* intérieur | KS | V3b | 464 | oui | 0,0970 [0,0716 ; 0,1276] | compatible | 1 / 4, 1 | 0,0603 [0,0405 ; 0,0860] | compatible | 0 / 1, 1 |
| J2 | δ̂* intérieur | KS | V3h | 464 | oui | 0,0970 [0,0716 ; 0,1276] | compatible | 1 / 4, 1 | 0,0603 [0,0405 ; 0,0860] | compatible | 0 / 1, 1 |
| J2 | δ̂* intérieur | SW | V1 | 464 | oui | 0,0927 [0,0679 ; 0,1228] | compatible | — | 0,0409 [0,0248 ; 0,0632] | compatible | — |
| J2 | δ̂* intérieur | SW | V3a | 464 | oui | 0,1034 [0,0773 ; 0,1348] | compatible | 6 / 1, 0,875 | 0,0474 [0,0299 ; 0,0709] | compatible | 4 / 1, 1 |
| J2 | δ̂* intérieur | SW | V3b | 464 | oui | 0,0991 [0,0735 ; 0,1300] | compatible | 4 / 1, 1 | 0,0474 [0,0299 ; 0,0709] | compatible | 3 / 0, 1 |
| J2 | δ̂* intérieur | SW | V3h | 464 | oui | 0,0991 [0,0735 ; 0,1300] | compatible | 4 / 1, 1 | 0,0474 [0,0299 ; 0,0709] | compatible | 3 / 0, 1 |
| J2 | δ̂* intérieur | SF | V1 | 464 | oui | 0,0539 [0,0352 ; 0,0785] | écart mineur | — | 0,0280 [0,0150 ; 0,0474] | écart mineur | — |
| J2 | δ̂* intérieur | SF | V3a | 464 | oui | 0,0905 [0,0660 ; 0,1204] | compatible | 17 / 0, 0,000198 | 0,0409 [0,0248 ; 0,0632] | compatible | 6 / 0, 0,375 |
| J2 | δ̂* intérieur | SF | V3b | 464 | oui | 0,0862 [0,0623 ; 0,1155] | compatible | 15 / 0, 0,000671 | 0,0409 [0,0248 ; 0,0632] | compatible | 6 / 0, 0,375 |
| J2 | δ̂* intérieur | SF | V3h | 464 | oui | 0,0862 [0,0623 ; 0,1155] | compatible | 15 / 0, 0,000671 | 0,0409 [0,0248 ; 0,0632] | compatible | 6 / 0, 0,375 |
| J2 | δ̂* intérieur | JB | V1 | 464 | oui | 0,0280 [0,0150 ; 0,0474] **conservateur** | distorsion matérielle | — | 0,0086 [0,0024 ; 0,0219] **conservateur** | distorsion matérielle | — |
| J2 | δ̂* intérieur | JB | V3a | 464 | oui | 0,1034 [0,0773 ; 0,1348] | compatible | 35 / 0, 1,05e-09 | 0,0431 [0,0265 ; 0,0658] | compatible | 16 / 0, 0,000458 |
| J2 | δ̂* intérieur | JB | V3b | 464 | oui | 0,1013 [0,0754 ; 0,1324] | compatible | 34 / 0, 2,1e-09 | 0,0453 [0,0282 ; 0,0684] | compatible | 17 / 0, 0,000229 |
| J2 | δ̂* intérieur | JB | V3h | 464 | oui | 0,1013 [0,0754 ; 0,1324] | compatible | 34 / 0, 2,1e-09 | 0,0453 [0,0282 ; 0,0684] | compatible | 17 / 0, 0,000229 |
| J2 | δ̂* intérieur | DW | V1 | 464 | oui | 0,0647 [0,0440 ; 0,0910] | écart mineur | — | 0,0302 [0,0166 ; 0,0501] | compatible | — |
| J2 | δ̂* intérieur | DW | V3a | 464 | oui | 0,0948 [0,0697 ; 0,1252] | compatible | 14 / 0, 0,00134 | 0,0496 [0,0317 ; 0,0735] | compatible | 9 / 0, 0,0547 |
| J2 | δ̂* intérieur | DW | V3b | 464 | oui | 0,1013 [0,0754 ; 0,1324] | compatible | 17 / 0, 0,000198 | 0,0539 [0,0352 ; 0,0785] | compatible | 11 / 0, 0,0127 |
| J2 | δ̂* intérieur | DW | V3h | 464 | oui | 0,1013 [0,0754 ; 0,1324] | compatible | 17 / 0, 0,000198 | 0,0539 [0,0352 ; 0,0785] | compatible | 11 / 0, 0,0127 |
| J2 | δ̂* intérieur | LB1 | V1 | 464 | oui | 0,0905 [0,0660 ; 0,1204] | compatible | — | 0,0539 [0,0352 ; 0,0785] | compatible | — |
| J2 | δ̂* intérieur | LB1 | V3a | 464 | oui | 0,1121 [0,0848 ; 0,1444] | compatible | 10 / 0, 0,0234 | 0,0625 [0,0423 ; 0,0885] | compatible | 5 / 1, 1 |
| J2 | δ̂* intérieur | LB1 | V3b | 464 | oui | 0,1099 [0,0829 ; 0,1420] | compatible | 9 / 0, 0,0469 | 0,0625 [0,0423 ; 0,0885] | compatible | 5 / 1, 1 |
| J2 | δ̂* intérieur | LB1 | V3h | 464 | oui | 0,1099 [0,0829 ; 0,1420] | compatible | 9 / 0, 0,0469 | 0,0625 [0,0423 ; 0,0885] | compatible | 5 / 1, 1 |
| J2 | δ̂* intérieur | supF | V1 | 464 | oui | 0,0647 [0,0440 ; 0,0910] | écart mineur | — | 0,0366 [0,0215 ; 0,0580] | compatible | — |
| J2 | δ̂* intérieur | supF | V3a | 464 | oui | 0,0690 [0,0476 ; 0,0960] | écart mineur | 4 / 2, 1 | 0,0409 [0,0248 ; 0,0632] | compatible | 3 / 1, 1 |
| J2 | δ̂* intérieur | supF | V3b | 464 | oui | 0,0711 [0,0495 ; 0,0984] | écart mineur | 3 / 0, 1 | 0,0431 [0,0265 ; 0,0658] | compatible | 3 / 0, 1 |
| J2 | δ̂* intérieur | supF | V3h | 464 | oui | 0,0711 [0,0495 ; 0,0984] | écart mineur | 3 / 0, 1 | 0,0431 [0,0265 ; 0,0658] | compatible | 3 / 0, 1 |
| J2 | δ̂* intérieur | CUSUM | V1 | 464 | oui | 0,0797 [0,0568 ; 0,1082] | compatible | — | 0,0409 [0,0248 ; 0,0632] | compatible | — |
| J2 | δ̂* intérieur | CUSUM | V3a | 464 | oui | 0,0754 [0,0531 ; 0,1033] | compatible | 4 / 6, 1 | 0,0302 [0,0166 ; 0,0501] | compatible | 0 / 5, 0,688 |
| J2 | δ̂* intérieur | CUSUM | V3b | 464 | oui | 0,0797 [0,0568 ; 0,1082] | compatible | 4 / 4, 1 | 0,0366 [0,0215 ; 0,0580] | compatible | 1 / 3, 1 |
| J2 | δ̂* intérieur | CUSUM | V3h | 464 | oui | 0,0797 [0,0568 ; 0,1082] | compatible | 4 / 4, 1 | 0,0366 [0,0215 ; 0,0580] | compatible | 1 / 3, 1 |
| J2 | δ̂* intérieur | Grubbs | V1 | 464 | oui | 0,0216 [0,0104 ; 0,0393] **conservateur** | distorsion matérielle | — | 0,0065 [0,0013 ; 0,0188] **conservateur** | distorsion matérielle | — |
| J2 | δ̂* intérieur | Grubbs | V3a | 464 | oui | 0,0927 [0,0679 ; 0,1228] | compatible | 33 / 0, 3,73e-09 | 0,0474 [0,0299 ; 0,0709] | compatible | 19 / 0, 6,87e-05 |
| J2 | δ̂* intérieur | Grubbs | V3b | 464 | oui | 0,0927 [0,0679 ; 0,1228] | compatible | 33 / 0, 3,73e-09 | 0,0496 [0,0317 ; 0,0735] | compatible | 20 / 0, 3,24e-05 |
| J2 | δ̂* intérieur | Grubbs | V3h | 464 | oui | 0,0927 [0,0679 ; 0,1228] | compatible | 33 / 0, 3,73e-09 | 0,0496 [0,0317 ; 0,0735] | compatible | 20 / 0, 3,24e-05 |
| J2 | δ̂* intérieur | Lillie | V1 | 464 | oui | 0,0668 [0,0458 ; 0,0935] | écart mineur | — | 0,0345 [0,0198 ; 0,0554] | compatible | — |
| J2 | δ̂* intérieur | Lillie | V3a | 464 | oui | 0,0884 [0,0642 ; 0,1180] | compatible | 10 / 0, 0,0234 | 0,0474 [0,0299 ; 0,0709] | compatible | 6 / 0, 0,375 |
| J2 | δ̂* intérieur | Lillie | V3b | 464 | oui | 0,0841 [0,0605 ; 0,1131] | compatible | 8 / 0, 0,0859 | 0,0453 [0,0282 ; 0,0684] | compatible | 5 / 0, 0,75 |
| J2 | δ̂* intérieur | Lillie | V3h | 464 | oui | 0,0841 [0,0605 ; 0,1131] | compatible | 8 / 0, 0,0859 | 0,0453 [0,0282 ; 0,0684] | compatible | 5 / 0, 0,75 |
| J2 | δ̂* intérieur | Intercept | V1 | 464 | oui | 0,1121 [0,0848 ; 0,1444] | compatible | — | 0,0733 [0,0513 ; 0,1009] | écart mineur | — |
| J2 | δ̂* intérieur | Intercept | V3a | 464 | oui | 0,0991 [0,0735 ; 0,1300] | compatible | 0 / 6, 0,313 | 0,0647 [0,0440 ; 0,0910] | compatible | 1 / 5, 1 |
| J2 | δ̂* intérieur | Intercept | V3b | 464 | oui | 0,1013 [0,0754 ; 0,1324] | compatible | 1 / 6, 1 | 0,0668 [0,0458 ; 0,0935] | compatible | 1 / 4, 1 |
| J2 | δ̂* intérieur | Intercept | V3h | 464 | oui | 0,1013 [0,0754 ; 0,1324] | compatible | 1 / 6, 1 | 0,0668 [0,0458 ; 0,0935] | compatible | 1 / 4, 1 |
| J2 | δ̂* intérieur | RESET | V1 | 464 | oui | 0,1142 [0,0867 ; 0,1467] | compatible | — | 0,0280 [0,0150 ; 0,0474] | écart mineur | — |
| J2 | δ̂* intérieur | RESET | V3a | 464 | oui | 0,0797 [0,0568 ; 0,1082] | compatible | 1 / 17, 0,00145 | 0,0388 [0,0232 ; 0,0606] | compatible | 7 / 2, 1 |
| J2 | δ̂* intérieur | RESET | V3b | 464 | oui | 0,0819 [0,0586 ; 0,1107] | compatible | 0 / 15, 0,000671 | 0,0388 [0,0232 ; 0,0606] | compatible | 7 / 2, 1 |
| J2 | δ̂* intérieur | RESET | V3h | 464 | oui | 0,0819 [0,0586 ; 0,1107] | compatible | 0 / 15, 0,000671 | 0,0388 [0,0232 ; 0,0606] | compatible | 7 / 2, 1 |
| J2 | δ̂* intérieur | BP | V1 | 464 | oui | 0,0000 [0,0000 ; 0,0079] **conservateur** | distorsion matérielle | — | 0,0000 [0,0000 ; 0,0079] **conservateur** | distorsion matérielle | — |
| J2 | δ̂* intérieur | BP | V3a | 464 | oui | 0,1013 [0,0754 ; 0,1324] | compatible | 47 / 0, 3,13e-13 | 0,0517 [0,0334 ; 0,0760] | compatible | 24 / 0, 2,62e-06 |
| J2 | δ̂* intérieur | BP | V3b | 464 | oui | 0,1056 [0,0792 ; 0,1372] | compatible | 49 / 0, 7,82e-14 | 0,0517 [0,0334 ; 0,0760] | compatible | 24 / 0, 2,62e-06 |
| J2 | δ̂* intérieur | BP | V3h | 464 | oui | 0,1056 [0,0792 ; 0,1372] | compatible | 49 / 0, 7,82e-14 | 0,0517 [0,0334 ; 0,0760] | compatible | 24 / 0, 2,62e-06 |
| J2 | δ̂* intérieur | BP79 | V1 | 464 | oui | 0,0000 [0,0000 ; 0,0079] **conservateur** | distorsion matérielle | — | 0,0000 [0,0000 ; 0,0079] **conservateur** | distorsion matérielle | — |
| J2 | δ̂* intérieur | BP79 | V3a | 464 | oui | 0,0884 [0,0642 ; 0,1180] | compatible | 41 / 0, 1,73e-11 | 0,0431 [0,0265 ; 0,0658] | compatible | 20 / 0, 3,62e-05 |
| J2 | δ̂* intérieur | BP79 | V3b | 464 | oui | 0,0905 [0,0660 ; 0,1204] | compatible | 42 / 0, 8,64e-12 | 0,0517 [0,0334 ; 0,0760] | compatible | 24 / 0, 2,62e-06 |
| J2 | δ̂* intérieur | BP79 | V3h | 464 | oui | 0,0905 [0,0660 ; 0,1204] | compatible | 42 / 0, 8,64e-12 | 0,0517 [0,0334 ; 0,0760] | compatible | 24 / 0, 2,62e-06 |
| J2 | δ̂* intérieur | White | V1 | 464 | oui | 0,1056 [0,0792 ; 0,1372] | compatible | — | 0,0388 [0,0232 ; 0,0606] | compatible | — |
| J2 | δ̂* intérieur | White | V3a | 464 | oui | 0,1142 [0,0867 ; 0,1467] | compatible | 7 / 3, 1 | 0,0496 [0,0317 ; 0,0735] | compatible | 5 / 0, 0,688 |
| J2 | δ̂* intérieur | White | V3b | 464 | oui | 0,1099 [0,0829 ; 0,1420] | compatible | 4 / 2, 1 | 0,0474 [0,0299 ; 0,0709] | compatible | 5 / 1, 1 |
| J2 | δ̂* intérieur | White | V3h | 464 | oui | 0,1099 [0,0829 ; 0,1420] | compatible | 4 / 2, 1 | 0,0474 [0,0299 ; 0,0709] | compatible | 5 / 1, 1 |
| J2 | δ̂* intérieur | GQ | V1 | 464 | oui | 0,0022 [0,0001 ; 0,0119] **conservateur** | distorsion matérielle | — | 0,0000 [0,0000 ; 0,0079] **conservateur** | distorsion matérielle | — |
| J2 | δ̂* intérieur | GQ | V3a | 464 | oui | 0,1034 [0,0773 ; 0,1348] | compatible | 47 / 0, 3,13e-13 | 0,0517 [0,0334 ; 0,0760] | compatible | 24 / 0, 2,62e-06 |
| J2 | δ̂* intérieur | GQ | V3b | 464 | oui | 0,1078 [0,0810 ; 0,1396] | compatible | 49 / 0, 7,82e-14 | 0,0496 [0,0317 ; 0,0735] | compatible | 23 / 0, 4,77e-06 |
| J2 | δ̂* intérieur | GQ | V3h | 464 | oui | 0,1078 [0,0810 ; 0,1396] | compatible | 49 / 0, 7,82e-14 | 0,0496 [0,0317 ; 0,0735] | compatible | 23 / 0, 4,77e-06 |
| J2 | δ̂* intérieur | BF | V1 | 464 | oui | 0,0172 [0,0075 ; 0,0337] **conservateur** | distorsion matérielle | — | 0,0108 [0,0035 ; 0,0250] **conservateur** | distorsion matérielle | — |
| J2 | δ̂* intérieur | BF | V3a | 464 | oui | 0,1185 [0,0906 ; 0,1515] | compatible | 47 / 0, 3,13e-13 | 0,0560 [0,0369 ; 0,0810] | compatible | 21 / 0, 1,91e-05 |
| J2 | δ̂* intérieur | BF | V3b | 464 | oui | 0,1185 [0,0906 ; 0,1515] | compatible | 47 / 0, 2,84e-13 | 0,0582 [0,0387 ; 0,0835] | compatible | 22 / 0, 9,06e-06 |
| J2 | δ̂* intérieur | BF | V3h | 464 | oui | 0,1185 [0,0906 ; 0,1515] | compatible | 47 / 0, 2,84e-13 | 0,0582 [0,0387 ; 0,0835] | compatible | 22 / 0, 9,06e-06 |
| J2 | δ̂* intérieur | Smirnov | V1 | 464 | oui | 0,0129 [0,0048 ; 0,0279] | écart non tranché | — | 0,0129 [0,0048 ; 0,0279] | écart non tranché | — |
| J2 | δ̂* intérieur | Smirnov | V3a | 464 | oui | 0,0194 [0,0089 ; 0,0365] | compatible | 3 / 0, 1 | 0,0129 [0,0048 ; 0,0279] | écart non tranché | 0 / 0, 1 |
| J2 | δ̂* intérieur | Smirnov | V3b | 464 | oui | 0,0129 [0,0048 ; 0,0279] | écart non tranché | 0 / 0, 1 | 0,0129 [0,0048 ; 0,0279] | écart non tranché | 0 / 0, 1 |
| J2 | δ̂* intérieur | Smirnov | V3h | 464 | oui | 0,0129 [0,0048 ; 0,0279] | écart non tranché | 0 / 0, 1 | 0,0129 [0,0048 ; 0,0279] | écart non tranché | 0 / 0, 1 |
| J2 | δ̂* intérieur | LB2 | V1 | 464 | oui | 0,1228 [0,0944 ; 0,1562] | compatible | — | 0,0668 [0,0458 ; 0,0935] | compatible | — |
| J2 | δ̂* intérieur | LB2 | V3a | 464 | oui | 0,0970 [0,0716 ; 0,1276] | compatible | 1 / 13, 0,0146 | 0,0582 [0,0387 ; 0,0835] | compatible | 1 / 5, 1 |
| J2 | δ̂* intérieur | LB2 | V3b | 464 | oui | 0,0991 [0,0735 ; 0,1300] | compatible | 0 / 11, 0,00879 | 0,0560 [0,0369 ; 0,0810] | compatible | 0 / 5, 0,625 |
| J2 | δ̂* intérieur | LB2 | V3h | 464 | oui | 0,0991 [0,0735 ; 0,1300] | compatible | 0 / 11, 0,00879 | 0,0560 [0,0369 ; 0,0810] | compatible | 0 / 5, 0,625 |
| J2 | δ̂* intérieur | BP2 | V1 | 464 | oui | 0,1185 [0,0906 ; 0,1515] | compatible | — | 0,0625 [0,0423 ; 0,0885] | compatible | — |
| J2 | δ̂* intérieur | BP2 | V3a | 464 | oui | 0,1078 [0,0810 ; 0,1396] | compatible | 0 / 5, 0,312 | 0,0517 [0,0334 ; 0,0760] | compatible | 1 / 6, 1 |
| J2 | δ̂* intérieur | BP2 | V3b | 464 | oui | 0,1121 [0,0848 ; 0,1444] | compatible | 0 / 3, 1 | 0,0539 [0,0352 ; 0,0785] | compatible | 1 / 5, 1 |
| J2 | δ̂* intérieur | BP2 | V3h | 464 | oui | 0,1121 [0,0848 ; 0,1444] | compatible | 0 / 3, 1 | 0,0539 [0,0352 ; 0,0785] | compatible | 1 / 5, 1 |
| J2 | δ̂* intérieur | Runs | V1 | 464 | oui | 0,0582 [0,0387 ; 0,0835] | compatible | — | 0,0086 [0,0024 ; 0,0219] | compatible | — |
| J2 | δ̂* intérieur | Runs | V3a | 464 | oui | 0,0474 [0,0299 ; 0,0709] | compatible | 1 / 6, 0,875 | 0,0108 [0,0035 ; 0,0250] | compatible | 3 / 2, 1 |
| J2 | δ̂* intérieur | Runs | V3b | 464 | oui | 0,0582 [0,0387 ; 0,0835] | compatible | 0 / 0, 1 | 0,0043 [0,0005 ; 0,0155] | compatible | 1 / 3, 1 |
| J2 | δ̂* intérieur | Runs | V3h | 464 | oui | 0,0582 [0,0387 ; 0,0835] | compatible | 0 / 0, 1 | 0,0043 [0,0005 ; 0,0155] | compatible | 1 / 3, 1 |
| J2 | δ̂* intérieur | MK | V1 | 464 | oui | 0,0647 [0,0440 ; 0,0910] | compatible | — | 0,0259 [0,0134 ; 0,0447] | compatible | — |
| J2 | δ̂* intérieur | MK | V3a | 464 | oui | 0,0409 [0,0248 ; 0,0632] | écart mineur | 1 / 12, 0,0239 | 0,0237 [0,0119 ; 0,0420] | compatible | 2 / 3, 1 |
| J2 | δ̂* intérieur | MK | V3b | 464 | oui | 0,0582 [0,0387 ; 0,0835] | compatible | 2 / 5, 1 | 0,0280 [0,0150 ; 0,0474] | compatible | 3 / 2, 1 |
| J2 | δ̂* intérieur | MK | V3h | 464 | oui | 0,0582 [0,0387 ; 0,0835] | compatible | 2 / 5, 1 | 0,0280 [0,0150 ; 0,0474] | compatible | 3 / 2, 1 |
| J2 | δ̂* intérieur | SpearVol | V1 | 464 | oui | 0,1056 [0,0792 ; 0,1372] | compatible | — | 0,0625 [0,0423 ; 0,0885] | compatible | — |
| J2 | δ̂* intérieur | SpearVol | V3a | 464 | oui | 0,1099 [0,0829 ; 0,1420] | compatible | 4 / 2, 1 | 0,0560 [0,0369 ; 0,0810] | compatible | 2 / 5, 1 |
| J2 | δ̂* intérieur | SpearVol | V3b | 464 | oui | 0,1099 [0,0829 ; 0,1420] | compatible | 5 / 3, 1 | 0,0668 [0,0458 ; 0,0935] | écart non tranché | 2 / 0, 1 |
| J2 | δ̂* intérieur | SpearVol | V3h | 464 | oui | 0,1099 [0,0829 ; 0,1420] | compatible | 5 / 3, 1 | 0,0668 [0,0458 ; 0,0935] | écart non tranché | 2 / 0, 1 |
| J2 | δ̂* intérieur | SpearTps | V1 | 464 | oui | 0,0819 [0,0586 ; 0,1107] | compatible | — | 0,0237 [0,0119 ; 0,0420] | écart mineur | — |
| J2 | δ̂* intérieur | SpearTps | V3a | 464 | oui | 0,0474 [0,0299 ; 0,0709] | écart mineur | 0 / 16, 0,000366 | 0,0259 [0,0134 ; 0,0447] | compatible | 3 / 2, 1 |
| J2 | δ̂* intérieur | SpearTps | V3b | 464 | oui | 0,0560 [0,0369 ; 0,0810] | écart mineur | 1 / 13, 0,0146 | 0,0302 [0,0166 ; 0,0501] | compatible | 4 / 1, 1 |
| J2 | δ̂* intérieur | SpearTps | V3h | 464 | oui | 0,0560 [0,0369 ; 0,0810] | écart mineur | 1 / 13, 0,0146 | 0,0302 [0,0166 ; 0,0501] | compatible | 4 / 1, 1 |
| J2 | δ̂* intérieur | DAgo | V1 | 464 | oui | 0,0194 [0,0089 ; 0,0365] **conservateur** | distorsion matérielle | — | 0,0043 [0,0005 ; 0,0155] **conservateur** | distorsion matérielle | — |
| J2 | δ̂* intérieur | DAgo | V3a | 464 | oui | 0,0948 [0,0697 ; 0,1252] | compatible | 35 / 0, 1,05e-09 | 0,0453 [0,0282 ; 0,0684] | compatible | 19 / 0, 6,87e-05 |
| J2 | δ̂* intérieur | DAgo | V3b | 464 | oui | 0,0927 [0,0679 ; 0,1228] | compatible | 34 / 0, 2,1e-09 | 0,0517 [0,0334 ; 0,0760] | compatible | 22 / 0, 9,06e-06 |
| J2 | δ̂* intérieur | DAgo | V3h | 464 | oui | 0,0927 [0,0679 ; 0,1228] | compatible | 34 / 0, 2,1e-09 | 0,0517 [0,0334 ; 0,0760] | compatible | 22 / 0, 9,06e-06 |
| J2 | δ̂* intérieur | CoxStuart | V1 | 464 | oui | 0,0000 [0,0000 ; 0,0079] | compatible | — | 0,0000 [0,0000 ; 0,0079] | compatible | — |
| J2 | δ̂* intérieur | CoxStuart | V3a | 464 | oui | 0,0022 [0,0001 ; 0,0119] | compatible | 1 / 0, 1 | 0,0000 [0,0000 ; 0,0079] | compatible | 0 / 0, 1 |
| J2 | δ̂* intérieur | CoxStuart | V3b | 464 | oui | 0,0000 [0,0000 ; 0,0079] | compatible | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0079] | compatible | 0 / 0, 1 |
| J2 | δ̂* intérieur | CoxStuart | V3h | 464 | oui | 0,0000 [0,0000 ; 0,0079] | compatible | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0079] | compatible | 0 / 0, 1 |
| J2 | δ̂* intérieur | DWr | V1 | 464 | oui | 0,0560 [0,0369 ; 0,0810] | écart mineur | — | 0,0237 [0,0119 ; 0,0420] | écart non tranché | — |
| J2 | δ̂* intérieur | DWr | V3a | 464 | oui | 0,0819 [0,0586 ; 0,1107] | compatible | 12 / 0, 0,00439 | 0,0409 [0,0248 ; 0,0632] | compatible | 8 / 0, 0,102 |
| J2 | δ̂* intérieur | DWr | V3b | 464 | oui | 0,0905 [0,0660 ; 0,1204] | compatible | 16 / 0, 0,000366 | 0,0496 [0,0317 ; 0,0735] | compatible | 12 / 0, 0,00684 |
| J2 | δ̂* intérieur | DWr | V3h | 464 | oui | 0,0905 [0,0660 ; 0,1204] | compatible | 16 / 0, 0,000366 | 0,0496 [0,0317 ; 0,0735] | compatible | 12 / 0, 0,00684 |
| J2 | δ̂* intérieur | LB1r | V1 | 464 | oui | 0,0776 [0,0549 ; 0,1058] | compatible | — | 0,0453 [0,0282 ; 0,0684] | compatible | — |
| J2 | δ̂* intérieur | LB1r | V3a | 464 | oui | 0,1207 [0,0925 ; 0,1539] | compatible | 20 / 0, 2,67e-05 | 0,0496 [0,0317 ; 0,0735] | compatible | 5 / 3, 1 |
| J2 | δ̂* intérieur | LB1r | V3b | 464 | oui | 0,1185 [0,0906 ; 0,1515] | compatible | 19 / 0, 5,34e-05 | 0,0539 [0,0352 ; 0,0785] | compatible | 4 / 0, 1 |
| J2 | δ̂* intérieur | LB1r | V3h | 464 | oui | 0,1185 [0,0906 ; 0,1515] | compatible | 19 / 0, 5,34e-05 | 0,0539 [0,0352 ; 0,0785] | compatible | 4 / 0, 1 |
| J2 | δ̂* intérieur | Runsr | V1 | 464 | oui | 0,0603 [0,0405 ; 0,0860] | compatible | — | 0,0108 [0,0035 ; 0,0250] | compatible | — |
| J2 | δ̂* intérieur | Runsr | V3a | 464 | oui | 0,0496 [0,0317 ; 0,0735] | compatible | 0 / 5, 0,562 | 0,0108 [0,0035 ; 0,0250] | compatible | 3 / 3, 1 |
| J2 | δ̂* intérieur | Runsr | V3b | 464 | oui | 0,0603 [0,0405 ; 0,0860] | compatible | 0 / 0, 1 | 0,0043 [0,0005 ; 0,0155] | compatible | 1 / 4, 1 |
| J2 | δ̂* intérieur | Runsr | V3h | 464 | oui | 0,0603 [0,0405 ; 0,0860] | compatible | 0 / 0, 1 | 0,0043 [0,0005 ; 0,0155] | compatible | 1 / 4, 1 |
| J2 | δ̂* intérieur | supFr | V1 | 464 | oui | 0,0754 [0,0531 ; 0,1033] | compatible | — | 0,0302 [0,0166 ; 0,0501] | compatible | — |
| J2 | δ̂* intérieur | supFr | V3a | 464 | oui | 0,0905 [0,0660 ; 0,1204] | compatible | 8 / 1, 0,234 | 0,0366 [0,0215 ; 0,0580] | compatible | 4 / 1, 1 |
| J2 | δ̂* intérieur | supFr | V3b | 464 | oui | 0,0905 [0,0660 ; 0,1204] | compatible | 8 / 1, 0,273 | 0,0388 [0,0232 ; 0,0606] | compatible | 4 / 0, 1 |
| J2 | δ̂* intérieur | supFr | V3h | 464 | oui | 0,0905 [0,0660 ; 0,1204] | compatible | 8 / 1, 0,273 | 0,0388 [0,0232 ; 0,0606] | compatible | 4 / 0, 1 |
| J2 | δ̂* intérieur | CUSUMr | V1 | 464 | oui | 0,0905 [0,0660 ; 0,1204] | compatible | — | 0,0453 [0,0282 ; 0,0684] | compatible | — |
| J2 | δ̂* intérieur | CUSUMr | V3a | 464 | oui | 0,0884 [0,0642 ; 0,1180] | compatible | 2 / 3, 1 | 0,0345 [0,0198 ; 0,0554] | compatible | 0 / 5, 0,688 |
| J2 | δ̂* intérieur | CUSUMr | V3b | 464 | oui | 0,0884 [0,0642 ; 0,1180] | compatible | 2 / 3, 1 | 0,0323 [0,0182 ; 0,0528] | compatible | 0 / 6, 0,375 |
| J2 | δ̂* intérieur | CUSUMr | V3h | 464 | oui | 0,0884 [0,0642 ; 0,1180] | compatible | 2 / 3, 1 | 0,0323 [0,0182 ; 0,0528] | compatible | 0 / 6, 0,375 |
| J2 | δ̂* intérieur | Grubbsr | V1 | 464 | oui | 0,0323 [0,0182 ; 0,0528] | écart non tranché | — | 0,0065 [0,0013 ; 0,0188] **conservateur** | distorsion matérielle | — |
| J2 | δ̂* intérieur | Grubbsr | V3a | 464 | oui | 0,0991 [0,0735 ; 0,1300] | compatible | 31 / 0, 1,4e-08 | 0,0431 [0,0265 ; 0,0658] | compatible | 17 / 0, 0,000244 |
| J2 | δ̂* intérieur | Grubbsr | V3b | 464 | oui | 0,0927 [0,0679 ; 0,1228] | compatible | 28 / 0, 1,12e-07 | 0,0474 [0,0299 ; 0,0709] | compatible | 19 / 0, 6,1e-05 |
| J2 | δ̂* intérieur | Grubbsr | V3h | 464 | oui | 0,0927 [0,0679 ; 0,1228] | compatible | 28 / 0, 1,12e-07 | 0,0474 [0,0299 ; 0,0709] | compatible | 19 / 0, 6,1e-05 |
| J2 | δ̂* = 1 | AD | V1 | 722 | oui | 0,0845 [0,0652 ; 0,1072] | compatible | — | 0,0374 [0,0248 ; 0,0539] | compatible | — |
| J2 | δ̂* = 1 | AD | V3a | 722 | oui | 0,0886 [0,0689 ; 0,1118] | compatible | 5 / 2, 1 | 0,0360 [0,0237 ; 0,0523] | compatible | 1 / 2, 1 |
| J2 | δ̂* = 1 | AD | V3b | 722 | oui | 0,0859 [0,0665 ; 0,1087] | compatible | 2 / 1, 1 | 0,0360 [0,0237 ; 0,0523] | compatible | 1 / 2, 1 |
| J2 | δ̂* = 1 | AD | V3h | 722 | oui | 0,0845 [0,0652 ; 0,1072] | compatible | 0 / 0, 1 | 0,0374 [0,0248 ; 0,0539] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | CvM | V1 | 722 | oui | 0,0831 [0,0640 ; 0,1057] | compatible | — | 0,0360 [0,0237 ; 0,0523] | compatible | — |
| J2 | δ̂* = 1 | CvM | V3a | 722 | oui | 0,0928 [0,0726 ; 0,1164] | compatible | 7 / 0, 0,156 | 0,0360 [0,0237 ; 0,0523] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | CvM | V3b | 722 | oui | 0,0873 [0,0677 ; 0,1103] | compatible | 4 / 1, 1 | 0,0374 [0,0248 ; 0,0539] | compatible | 1 / 0, 1 |
| J2 | δ̂* = 1 | CvM | V3h | 722 | oui | 0,0831 [0,0640 ; 0,1057] | compatible | 0 / 0, 1 | 0,0360 [0,0237 ; 0,0523] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | KS | V1 | 722 | oui | 0,0762 [0,0579 ; 0,0980] | écart mineur | — | 0,0402 [0,0271 ; 0,0572] | compatible | — |
| J2 | δ̂* = 1 | KS | V3a | 722 | oui | 0,0748 [0,0567 ; 0,0965] | écart mineur | 2 / 3, 1 | 0,0360 [0,0237 ; 0,0523] | compatible | 1 / 4, 1 |
| J2 | δ̂* = 1 | KS | V3b | 722 | oui | 0,0734 [0,0555 ; 0,0949] | écart mineur | 1 / 3, 1 | 0,0402 [0,0271 ; 0,0572] | compatible | 1 / 1, 1 |
| J2 | δ̂* = 1 | KS | V3h | 722 | oui | 0,0762 [0,0579 ; 0,0980] | écart mineur | 0 / 0, 1 | 0,0402 [0,0271 ; 0,0572] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | SW | V1 | 722 | oui | 0,0859 [0,0665 ; 0,1087] | compatible | — | 0,0374 [0,0248 ; 0,0539] | compatible | — |
| J2 | δ̂* = 1 | SW | V3a | 722 | oui | 0,0789 [0,0603 ; 0,1011] | compatible | 1 / 6, 1 | 0,0374 [0,0248 ; 0,0539] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | SW | V3b | 722 | oui | 0,0817 [0,0628 ; 0,1041] | compatible | 2 / 5, 1 | 0,0374 [0,0248 ; 0,0539] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | SW | V3h | 722 | oui | 0,0859 [0,0665 ; 0,1087] | compatible | 0 / 0, 1 | 0,0374 [0,0248 ; 0,0539] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | SF | V1 | 722 | oui | 0,0817 [0,0628 ; 0,1041] | compatible | — | 0,0471 [0,0328 ; 0,0652] | compatible | — |
| J2 | δ̂* = 1 | SF | V3a | 722 | oui | 0,0679 [0,0506 ; 0,0887] | écart mineur | 0 / 10, 0,011 | 0,0346 [0,0225 ; 0,0507] | compatible | 0 / 9, 0,0508 |
| J2 | δ̂* = 1 | SF | V3b | 722 | oui | 0,0665 [0,0494 ; 0,0872] | écart mineur | 0 / 11, 0,00781 | 0,0374 [0,0248 ; 0,0539] | compatible | 0 / 7, 0,172 |
| J2 | δ̂* = 1 | SF | V3h | 722 | oui | 0,0817 [0,0628 ; 0,1041] | compatible | 0 / 0, 1 | 0,0471 [0,0328 ; 0,0652] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | JB | V1 | 722 | oui | 0,0942 [0,0739 ; 0,1179] | compatible | — | 0,0499 [0,0352 ; 0,0684] | compatible | — |
| J2 | δ̂* = 1 | JB | V3a | 722 | oui | 0,0734 [0,0555 ; 0,0949] | écart mineur | 0 / 15, 0,000671 | 0,0388 [0,0259 ; 0,0556] | compatible | 0 / 8, 0,0781 |
| J2 | δ̂* = 1 | JB | V3b | 722 | oui | 0,0679 [0,0506 ; 0,0887] | écart mineur | 0 / 19, 4,96e-05 | 0,0402 [0,0271 ; 0,0572] | compatible | 0 / 7, 0,172 |
| J2 | δ̂* = 1 | JB | V3h | 722 | oui | 0,0942 [0,0739 ; 0,1179] | compatible | 0 / 0, 1 | 0,0499 [0,0352 ; 0,0684] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | DW | V1 | 722 | oui | 0,1219 [0,0989 ; 0,1480] | compatible | — | 0,0623 [0,0458 ; 0,0825] | compatible | — |
| J2 | δ̂* = 1 | DW | V3a | 722 | oui | 0,1163 [0,0939 ; 0,1420] | compatible | 7 / 11, 1 | 0,0665 [0,0494 ; 0,0872] | compatible | 8 / 5, 1 |
| J2 | δ̂* = 1 | DW | V3b | 722 | oui | 0,1150 [0,0926 ; 0,1405] | compatible | 6 / 11, 0,997 | 0,0637 [0,0470 ; 0,0841] | compatible | 9 / 8, 1 |
| J2 | δ̂* = 1 | DW | V3h | 722 | oui | 0,1219 [0,0989 ; 0,1480] | compatible | 0 / 0, 1 | 0,0623 [0,0458 ; 0,0825] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | LB1 | V1 | 722 | oui | 0,1343 [0,1103 ; 0,1614] | écart mineur | — | 0,0679 [0,0506 ; 0,0887] | écart mineur | — |
| J2 | δ̂* = 1 | LB1 | V3a | 722 | oui | 0,1247 [0,1014 ; 0,1510] | écart mineur | 2 / 9, 0,589 | 0,0526 [0,0375 ; 0,0715] | compatible | 0 / 11, 0,0117 |
| J2 | δ̂* = 1 | LB1 | V3b | 722 | oui | 0,1233 [0,1002 ; 0,1495] | écart mineur | 1 / 9, 0,215 | 0,0554 [0,0399 ; 0,0747] | compatible | 0 / 9, 0,043 |
| J2 | δ̂* = 1 | LB1 | V3h | 722 | oui | 0,1343 [0,1103 ; 0,1614] | écart mineur | 0 / 0, 1 | 0,0679 [0,0506 ; 0,0887] | écart mineur | 0 / 0, 1 |
| J2 | δ̂* = 1 | supF | V1 | 722 | oui | 0,0900 [0,0702 ; 0,1133] | compatible | — | 0,0499 [0,0352 ; 0,0684] | compatible | — |
| J2 | δ̂* = 1 | supF | V3a | 722 | oui | 0,1066 [0,0851 ; 0,1315] | compatible | 12 / 0, 0,00391 | 0,0623 [0,0458 ; 0,0825] | compatible | 9 / 0, 0,0508 |
| J2 | δ̂* = 1 | supF | V3b | 722 | oui | 0,1066 [0,0851 ; 0,1315] | compatible | 12 / 0, 0,00439 | 0,0651 [0,0482 ; 0,0856] | compatible | 11 / 0, 0,0127 |
| J2 | δ̂* = 1 | supF | V3h | 722 | oui | 0,0900 [0,0702 ; 0,1133] | compatible | 0 / 0, 1 | 0,0499 [0,0352 ; 0,0684] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | CUSUM | V1 | 722 | oui | 0,1025 [0,0813 ; 0,1270] | compatible | — | 0,0512 [0,0363 ; 0,0699] | compatible | — |
| J2 | δ̂* = 1 | CUSUM | V3a | 722 | oui | 0,1094 [0,0876 ; 0,1345] | compatible | 6 / 1, 1 | 0,0582 [0,0422 ; 0,0778] | compatible | 5 / 0, 0,625 |
| J2 | δ̂* = 1 | CUSUM | V3b | 722 | oui | 0,1094 [0,0876 ; 0,1345] | compatible | 6 / 1, 1 | 0,0623 [0,0458 ; 0,0825] | compatible | 8 / 0, 0,0781 |
| J2 | δ̂* = 1 | CUSUM | V3h | 722 | oui | 0,1025 [0,0813 ; 0,1270] | compatible | 0 / 0, 1 | 0,0512 [0,0363 ; 0,0699] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | Grubbs | V1 | 722 | oui | 0,0970 [0,0764 ; 0,1209] | compatible | — | 0,0499 [0,0352 ; 0,0684] | compatible | — |
| J2 | δ̂* = 1 | Grubbs | V3a | 722 | oui | 0,0720 [0,0543 ; 0,0934] | écart mineur | 0 / 18, 0,000114 | 0,0388 [0,0259 ; 0,0556] | compatible | 0 / 8, 0,0781 |
| J2 | δ̂* = 1 | Grubbs | V3b | 722 | oui | 0,0748 [0,0567 ; 0,0965] | écart mineur | 0 / 16, 0,000305 | 0,0429 [0,0294 ; 0,0604] | compatible | 0 / 5, 0,438 |
| J2 | δ̂* = 1 | Grubbs | V3h | 722 | oui | 0,0970 [0,0764 ; 0,1209] | compatible | 0 / 0, 1 | 0,0499 [0,0352 ; 0,0684] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | Lillie | V1 | 722 | oui | 0,0859 [0,0665 ; 0,1087] | compatible | — | 0,0443 [0,0305 ; 0,0620] | compatible | — |
| J2 | δ̂* = 1 | Lillie | V3a | 722 | oui | 0,0748 [0,0567 ; 0,0965] | écart mineur | 0 / 8, 0,0859 | 0,0388 [0,0259 ; 0,0556] | compatible | 1 / 5, 1 |
| J2 | δ̂* = 1 | Lillie | V3b | 722 | oui | 0,0720 [0,0543 ; 0,0934] | écart mineur | 0 / 10, 0,0215 | 0,0374 [0,0248 ; 0,0539] | compatible | 0 / 5, 0,562 |
| J2 | δ̂* = 1 | Lillie | V3h | 722 | oui | 0,0859 [0,0665 ; 0,1087] | compatible | 0 / 0, 1 | 0,0443 [0,0305 ; 0,0620] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | Intercept | V1 | 722 | oui | 0,0873 [0,0677 ; 0,1103] | compatible | — | 0,0443 [0,0305 ; 0,0620] | compatible | — |
| J2 | δ̂* = 1 | Intercept | V3a | 722 | oui | 0,1080 [0,0863 ; 0,1330] | compatible | 15 / 0, 0,000732 | 0,0540 [0,0387 ; 0,0731] | compatible | 8 / 1, 0,43 |
| J2 | δ̂* = 1 | Intercept | V3b | 722 | oui | 0,1066 [0,0851 ; 0,1315] | compatible | 15 / 1, 0,00623 | 0,0596 [0,0434 ; 0,0794] | compatible | 12 / 1, 0,041 |
| J2 | δ̂* = 1 | Intercept | V3h | 722 | oui | 0,0873 [0,0677 ; 0,1103] | compatible | 0 / 0, 1 | 0,0443 [0,0305 ; 0,0620] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | RESET | V1 | 722 | oui | 0,1247 [0,1014 ; 0,1510] | écart mineur | — | 0,0596 [0,0434 ; 0,0794] | compatible | — |
| J2 | δ̂* = 1 | RESET | V3a | 722 | oui | 0,0693 [0,0518 ; 0,0903] | écart mineur | 0 / 40, 3,82e-11 | 0,0360 [0,0237 ; 0,0523] | compatible | 0 / 17, 0,000259 |
| J2 | δ̂* = 1 | RESET | V3b | 722 | oui | 0,0734 [0,0555 ; 0,0949] | écart mineur | 0 / 37, 2,91e-10 | 0,0360 [0,0237 ; 0,0523] | compatible | 0 / 17, 0,000275 |
| J2 | δ̂* = 1 | RESET | V3h | 722 | oui | 0,1247 [0,1014 ; 0,1510] | écart mineur | 0 / 0, 1 | 0,0596 [0,0434 ; 0,0794] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | BP | V1 | 722 | oui | 0,1205 [0,0976 ; 0,1465] | compatible | — | 0,0512 [0,0363 ; 0,0699] | compatible | — |
| J2 | δ̂* = 1 | BP | V3a | 722 | oui | 0,0540 [0,0387 ; 0,0731] | écart mineur | 0 / 48, 1,56e-13 | 0,0263 [0,0159 ; 0,0408] | écart mineur | 0 / 18, 0,000137 |
| J2 | δ̂* = 1 | BP | V3b | 722 | oui | 0,0554 [0,0399 ; 0,0747] | écart mineur | 0 / 47, 3,13e-13 | 0,0277 [0,0170 ; 0,0425] | écart mineur | 0 / 17, 0,000275 |
| J2 | δ̂* = 1 | BP | V3h | 722 | oui | 0,1205 [0,0976 ; 0,1465] | compatible | 0 / 0, 1 | 0,0512 [0,0363 ; 0,0699] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | BP79 | V1 | 722 | oui | 0,1150 [0,0926 ; 0,1405] | compatible | — | 0,0609 [0,0446 ; 0,0810] | compatible | — |
| J2 | δ̂* = 1 | BP79 | V3a | 722 | oui | 0,0609 [0,0446 ; 0,0810] | écart mineur | 0 / 39, 7,28e-11 | 0,0346 [0,0225 ; 0,0507] | compatible | 0 / 19, 7,25e-05 |
| J2 | δ̂* = 1 | BP79 | V3b | 722 | oui | 0,0596 [0,0434 ; 0,0794] | écart mineur | 0 / 40, 3,82e-11 | 0,0319 [0,0203 ; 0,0474] | écart mineur | 0 / 21, 1,81e-05 |
| J2 | δ̂* = 1 | BP79 | V3h | 722 | oui | 0,1150 [0,0926 ; 0,1405] | compatible | 0 / 0, 1 | 0,0609 [0,0446 ; 0,0810] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | White | V1 | 722 | oui | 0,1177 [0,0951 ; 0,1435] | compatible | — | 0,0637 [0,0470 ; 0,0841] | compatible | — |
| J2 | δ̂* = 1 | White | V3a | 722 | oui | 0,0734 [0,0555 ; 0,0949] | écart mineur | 0 / 32, 8,38e-09 | 0,0305 [0,0192 ; 0,0458] | écart mineur | 0 / 24, 2,38e-06 |
| J2 | δ̂* = 1 | White | V3b | 722 | oui | 0,0706 [0,0530 ; 0,0918] | écart mineur | 0 / 34, 2,1e-09 | 0,0291 [0,0181 ; 0,0441] | écart mineur | 0 / 25, 1,19e-06 |
| J2 | δ̂* = 1 | White | V3h | 722 | oui | 0,1177 [0,0951 ; 0,1435] | compatible | 0 / 0, 1 | 0,0637 [0,0470 ; 0,0841] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | GQ | V1 | 722 | oui | 0,0720 [0,0543 ; 0,0934] | écart mineur | — | 0,0402 [0,0271 ; 0,0572] | compatible | — |
| J2 | δ̂* = 1 | GQ | V3a | 722 | oui | 0,1122 [0,0901 ; 0,1375] | compatible | 51 / 22, 0,0064 | 0,0471 [0,0328 ; 0,0652] | compatible | 20 / 15, 1 |
| J2 | δ̂* = 1 | GQ | V3b | 722 | oui | 0,1011 [0,0801 ; 0,1254] | compatible | 44 / 23, 0,0697 | 0,0471 [0,0328 ; 0,0652] | compatible | 20 / 15, 1 |
| J2 | δ̂* = 1 | GQ | V3h | 722 | oui | 0,0720 [0,0543 ; 0,0934] | écart mineur | 0 / 0, 1 | 0,0402 [0,0271 ; 0,0572] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | BF | V1 | 722 | oui | 0,1094 [0,0876 ; 0,1345] | compatible | — | 0,0526 [0,0375 ; 0,0715] | compatible | — |
| J2 | δ̂* = 1 | BF | V3a | 722 | oui | 0,0665 [0,0494 ; 0,0872] | écart mineur | 0 / 31, 1,58e-08 | 0,0346 [0,0225 ; 0,0507] | compatible | 0 / 13, 0,00366 |
| J2 | δ̂* = 1 | BF | V3b | 722 | oui | 0,0693 [0,0518 ; 0,0903] | écart mineur | 0 / 29, 6,33e-08 | 0,0360 [0,0237 ; 0,0523] | compatible | 0 / 12, 0,00732 |
| J2 | δ̂* = 1 | BF | V3h | 722 | oui | 0,1094 [0,0876 ; 0,1345] | compatible | 0 / 0, 1 | 0,0526 [0,0375 ; 0,0715] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | Smirnov | V1 | 722 | oui | 0,0249 [0,0148 ; 0,0391] | compatible | — | 0,0249 [0,0148 ; 0,0391] | compatible | — |
| J2 | δ̂* = 1 | Smirnov | V3a | 722 | oui | 0,0249 [0,0148 ; 0,0391] | compatible | 0 / 0, 1 | 0,0249 [0,0148 ; 0,0391] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | Smirnov | V3b | 722 | oui | 0,0249 [0,0148 ; 0,0391] | compatible | 0 / 0, 1 | 0,0249 [0,0148 ; 0,0391] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | Smirnov | V3h | 722 | oui | 0,0249 [0,0148 ; 0,0391] | compatible | 0 / 0, 1 | 0,0249 [0,0148 ; 0,0391] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | LB2 | V1 | 722 | oui | 0,1247 [0,1014 ; 0,1510] | écart mineur | — | 0,0651 [0,0482 ; 0,0856] | compatible | — |
| J2 | δ̂* = 1 | LB2 | V3a | 722 | oui | 0,0997 [0,0788 ; 0,1239] | compatible | 0 / 18, 0,000114 | 0,0568 [0,0411 ; 0,0763] | compatible | 0 / 6, 0,25 |
| J2 | δ̂* = 1 | LB2 | V3b | 722 | oui | 0,0942 [0,0739 ; 0,1179] | compatible | 0 / 22, 7,15e-06 | 0,0554 [0,0399 ; 0,0747] | compatible | 0 / 7, 0,172 |
| J2 | δ̂* = 1 | LB2 | V3h | 722 | oui | 0,1247 [0,1014 ; 0,1510] | écart mineur | 0 / 0, 1 | 0,0651 [0,0482 ; 0,0856] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | BP2 | V1 | 722 | oui | 0,1219 [0,0989 ; 0,1480] | compatible | — | 0,0651 [0,0482 ; 0,0856] | compatible | — |
| J2 | δ̂* = 1 | BP2 | V3a | 722 | oui | 0,1011 [0,0801 ; 0,1254] | compatible | 0 / 15, 0,000671 | 0,0568 [0,0411 ; 0,0763] | compatible | 0 / 6, 0,25 |
| J2 | δ̂* = 1 | BP2 | V3b | 722 | oui | 0,0956 [0,0751 ; 0,1194] | compatible | 0 / 19, 4,96e-05 | 0,0582 [0,0422 ; 0,0778] | compatible | 0 / 5, 0,438 |
| J2 | δ̂* = 1 | BP2 | V3h | 722 | oui | 0,1219 [0,0989 ; 0,1480] | compatible | 0 / 0, 1 | 0,0651 [0,0482 ; 0,0856] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | Runs | V1 | 722 | oui | 0,0596 [0,0434 ; 0,0794] | compatible | — | 0,0055 [0,0015 ; 0,0141] | compatible | — |
| J2 | δ̂* = 1 | Runs | V3a | 722 | oui | 0,0596 [0,0434 ; 0,0794] | compatible | 0 / 0, 1 | 0,0125 [0,0057 ; 0,0235] | compatible | 5 / 0, 0,625 |
| J2 | δ̂* = 1 | Runs | V3b | 722 | oui | 0,0596 [0,0434 ; 0,0794] | compatible | 0 / 0, 1 | 0,0069 [0,0023 ; 0,0161] | compatible | 4 / 3, 1 |
| J2 | δ̂* = 1 | Runs | V3h | 722 | oui | 0,0596 [0,0434 ; 0,0794] | compatible | 0 / 0, 1 | 0,0055 [0,0015 ; 0,0141] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | MK | V1 | 722 | oui | 0,0305 [0,0192 ; 0,0458] | écart non tranché | — | 0,0055 [0,0015 ; 0,0141] **conservateur** | distorsion matérielle | — |
| J2 | δ̂* = 1 | MK | V3a | 722 | oui | 0,0789 [0,0603 ; 0,1011] | compatible | 35 / 0, 1,11e-09 | 0,0429 [0,0294 ; 0,0604] | compatible | 27 / 0, 3,28e-07 |
| J2 | δ̂* = 1 | MK | V3b | 722 | oui | 0,0803 [0,0616 ; 0,1026] | compatible | 36 / 0, 5,53e-10 | 0,0429 [0,0294 ; 0,0604] | compatible | 27 / 0, 3,28e-07 |
| J2 | δ̂* = 1 | MK | V3h | 722 | oui | 0,0305 [0,0192 ; 0,0458] | écart non tranché | 0 / 0, 1 | 0,0055 [0,0015 ; 0,0141] **conservateur** | distorsion matérielle | 0 / 0, 1 |
| J2 | δ̂* = 1 | SpearVol | V1 | 722 | oui | 0,0928 [0,0726 ; 0,1164] | compatible | — | 0,0499 [0,0352 ; 0,0684] | compatible | — |
| J2 | δ̂* = 1 | SpearVol | V3a | 722 | oui | 0,1108 [0,0888 ; 0,1360] | compatible | 13 / 0, 0,0022 | 0,0485 [0,0340 ; 0,0668] | compatible | 2 / 3, 1 |
| J2 | δ̂* = 1 | SpearVol | V3b | 722 | oui | 0,1080 [0,0863 ; 0,1330] | compatible | 12 / 1, 0,0205 | 0,0540 [0,0387 ; 0,0731] | compatible | 4 / 1, 1 |
| J2 | δ̂* = 1 | SpearVol | V3h | 722 | oui | 0,0928 [0,0726 ; 0,1164] | compatible | 0 / 0, 1 | 0,0499 [0,0352 ; 0,0684] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | SpearTps | V1 | 722 | oui | 0,0609 [0,0446 ; 0,0810] | écart mineur | — | 0,0222 [0,0127 ; 0,0357] | écart mineur | — |
| J2 | δ̂* = 1 | SpearTps | V3a | 722 | oui | 0,0997 [0,0788 ; 0,1239] | compatible | 28 / 0, 1,19e-07 | 0,0568 [0,0411 ; 0,0763] | compatible | 25 / 0, 1,25e-06 |
| J2 | δ̂* = 1 | SpearTps | V3b | 722 | oui | 0,1011 [0,0801 ; 0,1254] | compatible | 29 / 0, 6,33e-08 | 0,0582 [0,0422 ; 0,0778] | compatible | 26 / 0, 6,26e-07 |
| J2 | δ̂* = 1 | SpearTps | V3h | 722 | oui | 0,0609 [0,0446 ; 0,0810] | écart mineur | 0 / 0, 1 | 0,0222 [0,0127 ; 0,0357] | écart mineur | 0 / 0, 1 |
| J2 | δ̂* = 1 | DAgo | V1 | 722 | oui | 0,0928 [0,0726 ; 0,1164] | compatible | — | 0,0499 [0,0352 ; 0,0684] | compatible | — |
| J2 | δ̂* = 1 | DAgo | V3a | 722 | oui | 0,0693 [0,0518 ; 0,0903] | écart mineur | 0 / 17, 0,000198 | 0,0374 [0,0248 ; 0,0539] | compatible | 0 / 9, 0,0508 |
| J2 | δ̂* = 1 | DAgo | V3b | 722 | oui | 0,0693 [0,0518 ; 0,0903] | écart mineur | 0 / 17, 0,000168 | 0,0374 [0,0248 ; 0,0539] | compatible | 0 / 9, 0,0469 |
| J2 | δ̂* = 1 | DAgo | V3h | 722 | oui | 0,0928 [0,0726 ; 0,1164] | compatible | 0 / 0, 1 | 0,0499 [0,0352 ; 0,0684] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | CoxStuart | V1 | 722 | oui | 0,0000 [0,0000 ; 0,0051] | compatible | — | 0,0000 [0,0000 ; 0,0051] | compatible | — |
| J2 | δ̂* = 1 | CoxStuart | V3a | 722 | oui | 0,0028 [0,0003 ; 0,0100] | compatible | 2 / 0, 1 | 0,0000 [0,0000 ; 0,0051] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | CoxStuart | V3b | 722 | oui | 0,0000 [0,0000 ; 0,0051] | compatible | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0051] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | CoxStuart | V3h | 722 | oui | 0,0000 [0,0000 ; 0,0051] | compatible | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0051] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | DWr | V1 | 722 | oui | 0,1150 [0,0926 ; 0,1405] | compatible | — | 0,0568 [0,0411 ; 0,0763] | compatible | — |
| J2 | δ̂* = 1 | DWr | V3a | 722 | oui | 0,1094 [0,0876 ; 0,1345] | compatible | 16 / 20, 1 | 0,0651 [0,0482 ; 0,0856] | compatible | 18 / 12, 1 |
| J2 | δ̂* = 1 | DWr | V3b | 722 | oui | 0,1136 [0,0914 ; 0,1390] | compatible | 18 / 19, 1 | 0,0651 [0,0482 ; 0,0856] | compatible | 20 / 14, 1 |
| J2 | δ̂* = 1 | DWr | V3h | 722 | oui | 0,1150 [0,0926 ; 0,1405] | compatible | 0 / 0, 1 | 0,0568 [0,0411 ; 0,0763] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | LB1r | V1 | 722 | oui | 0,1413 [0,1167 ; 0,1688] | écart mineur | — | 0,0720 [0,0543 ; 0,0934] | écart mineur | — |
| J2 | δ̂* = 1 | LB1r | V3a | 722 | oui | 0,1247 [0,1014 ; 0,1510] | écart mineur | 1 / 13, 0,011 | 0,0540 [0,0387 ; 0,0731] | compatible | 0 / 13, 0,00366 |
| J2 | δ̂* = 1 | LB1r | V3b | 722 | oui | 0,1260 [0,1027 ; 0,1525] | écart mineur | 0 / 11, 0,00781 | 0,0554 [0,0399 ; 0,0747] | compatible | 0 / 12, 0,00732 |
| J2 | δ̂* = 1 | LB1r | V3h | 722 | oui | 0,1413 [0,1167 ; 0,1688] | écart mineur | 0 / 0, 1 | 0,0720 [0,0543 ; 0,0934] | écart mineur | 0 / 0, 1 |
| J2 | δ̂* = 1 | Runsr | V1 | 722 | oui | 0,0596 [0,0434 ; 0,0794] | compatible | — | 0,0069 [0,0023 ; 0,0161] | compatible | — |
| J2 | δ̂* = 1 | Runsr | V3a | 722 | oui | 0,0596 [0,0434 ; 0,0794] | compatible | 0 / 0, 1 | 0,0125 [0,0057 ; 0,0235] | compatible | 5 / 1, 1 |
| J2 | δ̂* = 1 | Runsr | V3b | 722 | oui | 0,0596 [0,0434 ; 0,0794] | compatible | 0 / 0, 1 | 0,0069 [0,0023 ; 0,0161] | compatible | 4 / 4, 1 |
| J2 | δ̂* = 1 | Runsr | V3h | 722 | oui | 0,0596 [0,0434 ; 0,0794] | compatible | 0 / 0, 1 | 0,0069 [0,0023 ; 0,0161] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | supFr | V1 | 722 | oui | 0,0831 [0,0640 ; 0,1057] | compatible | — | 0,0429 [0,0294 ; 0,0604] | compatible | — |
| J2 | δ̂* = 1 | supFr | V3a | 722 | oui | 0,1066 [0,0851 ; 0,1315] | compatible | 17 / 0, 0,000198 | 0,0623 [0,0458 ; 0,0825] | compatible | 14 / 0, 0,00195 |
| J2 | δ̂* = 1 | supFr | V3b | 722 | oui | 0,1108 [0,0888 ; 0,1360] | compatible | 20 / 0, 2,67e-05 | 0,0665 [0,0494 ; 0,0872] | compatible | 17 / 0, 0,000275 |
| J2 | δ̂* = 1 | supFr | V3h | 722 | oui | 0,0831 [0,0640 ; 0,1057] | compatible | 0 / 0, 1 | 0,0429 [0,0294 ; 0,0604] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | CUSUMr | V1 | 722 | oui | 0,0997 [0,0788 ; 0,1239] | compatible | — | 0,0512 [0,0363 ; 0,0699] | compatible | — |
| J2 | δ̂* = 1 | CUSUMr | V3a | 722 | oui | 0,1066 [0,0851 ; 0,1315] | compatible | 5 / 0, 0,25 | 0,0568 [0,0411 ; 0,0763] | compatible | 5 / 1, 1 |
| J2 | δ̂* = 1 | CUSUMr | V3b | 722 | oui | 0,1066 [0,0851 ; 0,1315] | compatible | 5 / 0, 0,25 | 0,0596 [0,0434 ; 0,0794] | compatible | 6 / 0, 0,25 |
| J2 | δ̂* = 1 | CUSUMr | V3h | 722 | oui | 0,0997 [0,0788 ; 0,1239] | compatible | 0 / 0, 1 | 0,0512 [0,0363 ; 0,0699] | compatible | 0 / 0, 1 |
| J2 | δ̂* = 1 | Grubbsr | V1 | 722 | oui | 0,0886 [0,0689 ; 0,1118] | compatible | — | 0,0346 [0,0225 ; 0,0507] | compatible | — |
| J2 | δ̂* = 1 | Grubbsr | V3a | 722 | oui | 0,0873 [0,0677 ; 0,1103] | compatible | 3 / 4, 1 | 0,0346 [0,0225 ; 0,0507] | compatible | 1 / 1, 1 |
| J2 | δ̂* = 1 | Grubbsr | V3b | 722 | oui | 0,0873 [0,0677 ; 0,1103] | compatible | 2 / 3, 1 | 0,0360 [0,0237 ; 0,0523] | compatible | 3 / 2, 1 |
| J2 | δ̂* = 1 | Grubbsr | V3h | 722 | oui | 0,0886 [0,0689 ; 0,1118] | compatible | 0 / 0, 1 | 0,0346 [0,0225 ; 0,0507] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | AD | V1 | 507 | oui | 0,1460 [0,1164 ; 0,1797] | écart mineur | — | 0,0809 [0,0587 ; 0,1081] | écart non tranché | — |
| J3 | δ̂* = 0 | AD | V3a | 507 | oui | 0,1262 [0,0986 ; 0,1583] | compatible | 0 / 10, 0,0215 | 0,0750 [0,0536 ; 0,1014] | écart mineur | 1 / 4, 1 |
| J3 | δ̂* = 0 | AD | V3b | 507 | oui | 0,1321 [0,1039 ; 0,1648] | écart mineur | 0 / 7, 0,172 | 0,0789 [0,0570 ; 0,1059] | écart non tranché | 1 / 2, 1 |
| J3 | δ̂* = 0 | AD | V3h | 507 | oui | 0,1460 [0,1164 ; 0,1797] | écart mineur | 0 / 0, 1 | 0,0809 [0,0587 ; 0,1081] | écart non tranché | 0 / 0, 1 |
| J3 | δ̂* = 0 | CvM | V1 | 507 | oui | 0,1499 [0,1200 ; 0,1840] | écart mineur | — | 0,0907 [0,0672 ; 0,1192] | écart non tranché | — |
| J3 | δ̂* = 0 | CvM | V3a | 507 | oui | 0,1400 [0,1110 ; 0,1733] | écart mineur | 0 / 5, 0,625 | 0,0828 [0,0604 ; 0,1103] | écart non tranché | 0 / 4, 1 |
| J3 | δ̂* = 0 | CvM | V3b | 507 | oui | 0,1381 [0,1092 ; 0,1712] | écart mineur | 0 / 6, 0,313 | 0,0828 [0,0604 ; 0,1103] | écart non tranché | 0 / 4, 1 |
| J3 | δ̂* = 0 | CvM | V3h | 507 | oui | 0,1499 [0,1200 ; 0,1840] | écart mineur | 0 / 0, 1 | 0,0907 [0,0672 ; 0,1192] | écart non tranché | 0 / 0, 1 |
| J3 | δ̂* = 0 | KS | V1 | 507 | oui | 0,1341 [0,1057 ; 0,1669] | écart mineur | — | 0,0750 [0,0536 ; 0,1014] | écart mineur | — |
| J3 | δ̂* = 0 | KS | V3a | 507 | oui | 0,1381 [0,1092 ; 0,1712] | écart mineur | 4 / 2, 1 | 0,0730 [0,0519 ; 0,0992] | écart mineur | 0 / 1, 1 |
| J3 | δ̂* = 0 | KS | V3b | 507 | oui | 0,1381 [0,1092 ; 0,1712] | écart mineur | 4 / 2, 1 | 0,0750 [0,0536 ; 0,1014] | écart mineur | 1 / 1, 1 |
| J3 | δ̂* = 0 | KS | V3h | 507 | oui | 0,1341 [0,1057 ; 0,1669] | écart mineur | 0 / 0, 1 | 0,0750 [0,0536 ; 0,1014] | écart mineur | 0 / 0, 1 |
| J3 | δ̂* = 0 | SW | V1 | 507 | oui | 0,0828 [0,0604 ; 0,1103] | compatible | — | 0,0394 [0,0243 ; 0,0603] | compatible | — |
| J3 | δ̂* = 0 | SW | V3a | 507 | oui | 0,0888 [0,0655 ; 0,1170] | compatible | 5 / 2, 1 | 0,0394 [0,0243 ; 0,0603] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | SW | V3b | 507 | oui | 0,0888 [0,0655 ; 0,1170] | compatible | 4 / 1, 1 | 0,0434 [0,0274 ; 0,0650] | compatible | 2 / 0, 1 |
| J3 | δ̂* = 0 | SW | V3h | 507 | oui | 0,0828 [0,0604 ; 0,1103] | compatible | 0 / 0, 1 | 0,0394 [0,0243 ; 0,0603] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | SF | V1 | 507 | oui | 0,0947 [0,0706 ; 0,1236] | compatible | — | 0,0434 [0,0274 ; 0,0650] | compatible | — |
| J3 | δ̂* = 0 | SF | V3a | 507 | oui | 0,0828 [0,0604 ; 0,1103] | compatible | 0 / 6, 0,344 | 0,0316 [0,0181 ; 0,0507] | compatible | 0 / 6, 0,438 |
| J3 | δ̂* = 0 | SF | V3b | 507 | oui | 0,0828 [0,0604 ; 0,1103] | compatible | 0 / 6, 0,313 | 0,0355 [0,0212 ; 0,0555] | compatible | 0 / 4, 1 |
| J3 | δ̂* = 0 | SF | V3h | 507 | oui | 0,0947 [0,0706 ; 0,1236] | compatible | 0 / 0, 1 | 0,0434 [0,0274 ; 0,0650] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | JB | V1 | 507 | oui | 0,1026 [0,0776 ; 0,1323] | compatible | — | 0,0414 [0,0258 ; 0,0626] | compatible | — |
| J3 | δ̂* = 0 | JB | V3a | 507 | oui | 0,0690 [0,0486 ; 0,0947] | écart mineur | 0 / 17, 0,000305 | 0,0335 [0,0197 ; 0,0531] | compatible | 0 / 4, 1 |
| J3 | δ̂* = 0 | JB | V3b | 507 | oui | 0,0671 [0,0469 ; 0,0925] | écart mineur | 0 / 18, 0,000153 | 0,0316 [0,0181 ; 0,0507] | compatible | 0 / 5, 0,75 |
| J3 | δ̂* = 0 | JB | V3h | 507 | oui | 0,1026 [0,0776 ; 0,1323] | compatible | 0 / 0, 1 | 0,0414 [0,0258 ; 0,0626] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | DW | V1 | 507 | oui | 0,1065 [0,0810 ; 0,1367] | compatible | — | 0,0552 [0,0370 ; 0,0788] | compatible | — |
| J3 | δ̂* = 0 | DW | V3a | 507 | oui | 0,1026 [0,0776 ; 0,1323] | compatible | 3 / 5, 1 | 0,0592 [0,0403 ; 0,0834] | compatible | 3 / 1, 1 |
| J3 | δ̂* = 0 | DW | V3b | 507 | oui | 0,0966 [0,0724 ; 0,1258] | compatible | 1 / 6, 1 | 0,0513 [0,0338 ; 0,0742] | compatible | 1 / 3, 1 |
| J3 | δ̂* = 0 | DW | V3h | 507 | oui | 0,1065 [0,0810 ; 0,1367] | compatible | 0 / 0, 1 | 0,0552 [0,0370 ; 0,0788] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | LB1 | V1 | 507 | oui | 0,0966 [0,0724 ; 0,1258] | compatible | — | 0,0493 [0,0322 ; 0,0719] | compatible | — |
| J3 | δ̂* = 0 | LB1 | V3a | 507 | oui | 0,1026 [0,0776 ; 0,1323] | compatible | 3 / 0, 1 | 0,0592 [0,0403 ; 0,0834] | compatible | 5 / 0, 0,625 |
| J3 | δ̂* = 0 | LB1 | V3b | 507 | oui | 0,1045 [0,0793 ; 0,1345] | compatible | 5 / 1, 1 | 0,0611 [0,0419 ; 0,0857] | compatible | 6 / 0, 0,344 |
| J3 | δ̂* = 0 | LB1 | V3h | 507 | oui | 0,0966 [0,0724 ; 0,1258] | compatible | 0 / 0, 1 | 0,0493 [0,0322 ; 0,0719] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | supF | V1 | 507 | oui | 0,1006 [0,0758 ; 0,1301] | compatible | — | 0,0434 [0,0274 ; 0,0650] | compatible | — |
| J3 | δ̂* = 0 | supF | V3a | 507 | oui | 0,0986 [0,0741 ; 0,1279] | compatible | 1 / 2, 1 | 0,0533 [0,0354 ; 0,0765] | compatible | 5 / 0, 0,75 |
| J3 | δ̂* = 0 | supF | V3b | 507 | oui | 0,0986 [0,0741 ; 0,1279] | compatible | 0 / 1, 1 | 0,0533 [0,0354 ; 0,0765] | compatible | 5 / 0, 0,75 |
| J3 | δ̂* = 0 | supF | V3h | 507 | oui | 0,1006 [0,0758 ; 0,1301] | compatible | 0 / 0, 1 | 0,0434 [0,0274 ; 0,0650] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | CUSUM | V1 | 507 | oui | 0,0927 [0,0689 ; 0,1214] | compatible | — | 0,0296 [0,0167 ; 0,0483] | écart mineur | — |
| J3 | δ̂* = 0 | CUSUM | V3a | 507 | oui | 0,0986 [0,0741 ; 0,1279] | compatible | 4 / 1, 1 | 0,0335 [0,0197 ; 0,0531] | compatible | 2 / 0, 1 |
| J3 | δ̂* = 0 | CUSUM | V3b | 507 | oui | 0,0986 [0,0741 ; 0,1279] | compatible | 5 / 2, 1 | 0,0335 [0,0197 ; 0,0531] | compatible | 2 / 0, 1 |
| J3 | δ̂* = 0 | CUSUM | V3h | 507 | oui | 0,0927 [0,0689 ; 0,1214] | compatible | 0 / 0, 1 | 0,0296 [0,0167 ; 0,0483] | écart mineur | 0 / 0, 1 |
| J3 | δ̂* = 0 | Grubbs | V1 | 507 | oui | 0,1105 [0,0845 ; 0,1410] | compatible | — | 0,0572 [0,0386 ; 0,0811] | compatible | — |
| J3 | δ̂* = 0 | Grubbs | V3a | 507 | oui | 0,0769 [0,0553 ; 0,1037] | compatible | 0 / 17, 0,000305 | 0,0276 [0,0152 ; 0,0459] | écart mineur | 0 / 15, 0,00134 |
| J3 | δ̂* = 0 | Grubbs | V3b | 507 | oui | 0,0769 [0,0553 ; 0,1037] | compatible | 0 / 17, 0,000275 | 0,0335 [0,0197 ; 0,0531] | compatible | 0 / 12, 0,00977 |
| J3 | δ̂* = 0 | Grubbs | V3h | 507 | oui | 0,1105 [0,0845 ; 0,1410] | compatible | 0 / 0, 1 | 0,0572 [0,0386 ; 0,0811] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | Lillie | V1 | 507 | oui | 0,0966 [0,0724 ; 0,1258] | compatible | — | 0,0394 [0,0243 ; 0,0603] | compatible | — |
| J3 | δ̂* = 0 | Lillie | V3a | 507 | oui | 0,0848 [0,0621 ; 0,1125] | compatible | 1 / 7, 0,633 | 0,0394 [0,0243 ; 0,0603] | compatible | 1 / 1, 1 |
| J3 | δ̂* = 0 | Lillie | V3b | 507 | oui | 0,0907 [0,0672 ; 0,1192] | compatible | 2 / 5, 1 | 0,0394 [0,0243 ; 0,0603] | compatible | 2 / 2, 1 |
| J3 | δ̂* = 0 | Lillie | V3h | 507 | oui | 0,0966 [0,0724 ; 0,1258] | compatible | 0 / 0, 1 | 0,0394 [0,0243 ; 0,0603] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | Intercept | V1 | 507 | oui | 0,1440 [0,1146 ; 0,1776] | écart mineur | — | 0,0828 [0,0604 ; 0,1103] | écart non tranché | — |
| J3 | δ̂* = 0 | Intercept | V3a | 507 | oui | 0,1164 [0,0898 ; 0,1475] | compatible | 0 / 14, 0,00146 | 0,0552 [0,0370 ; 0,0788] | compatible | 0 / 14, 0,00146 |
| J3 | δ̂* = 0 | Intercept | V3b | 507 | oui | 0,1183 [0,0915 ; 0,1497] | compatible | 0 / 13, 0,00293 | 0,0533 [0,0354 ; 0,0765] | compatible | 0 / 15, 0,000732 |
| J3 | δ̂* = 0 | Intercept | V3h | 507 | oui | 0,1440 [0,1146 ; 0,1776] | écart mineur | 0 / 0, 1 | 0,0828 [0,0604 ; 0,1103] | écart non tranché | 0 / 0, 1 |
| J3 | δ̂* = 0 | RESET | V1 | 507 | oui | 0,1006 [0,0758 ; 0,1301] | compatible | — | 0,0394 [0,0243 ; 0,0603] | compatible | — |
| J3 | δ̂* = 0 | RESET | V3a | 507 | oui | 0,1223 [0,0951 ; 0,1540] | compatible | 11 / 0, 0,0137 | 0,0690 [0,0486 ; 0,0947] | compatible | 15 / 0, 0,00134 |
| J3 | δ̂* = 0 | RESET | V3b | 507 | oui | 0,1243 [0,0968 ; 0,1562] | compatible | 12 / 0, 0,00684 | 0,0690 [0,0486 ; 0,0947] | compatible | 15 / 0, 0,00134 |
| J3 | δ̂* = 0 | RESET | V3h | 507 | oui | 0,1006 [0,0758 ; 0,1301] | compatible | 0 / 0, 1 | 0,0394 [0,0243 ; 0,0603] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | BP | V1 | 507 | oui | 0,1026 [0,0776 ; 0,1323] | compatible | — | 0,0631 [0,0436 ; 0,0879] | compatible | — |
| J3 | δ̂* = 0 | BP | V3a | 507 | oui | 0,0710 [0,0502 ; 0,0969] | écart mineur | 0 / 16, 0,000519 | 0,0434 [0,0274 ; 0,0650] | compatible | 0 / 10, 0,0371 |
| J3 | δ̂* = 0 | BP | V3b | 507 | oui | 0,0671 [0,0469 ; 0,0925] | écart mineur | 0 / 18, 0,000153 | 0,0434 [0,0274 ; 0,0650] | compatible | 0 / 10, 0,0371 |
| J3 | δ̂* = 0 | BP | V3h | 507 | oui | 0,1026 [0,0776 ; 0,1323] | compatible | 0 / 0, 1 | 0,0631 [0,0436 ; 0,0879] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | BP79 | V1 | 507 | oui | 0,1006 [0,0758 ; 0,1301] | compatible | — | 0,0375 [0,0227 ; 0,0579] | compatible | — |
| J3 | δ̂* = 0 | BP79 | V3a | 507 | oui | 0,0454 [0,0290 ; 0,0673] | écart non tranché | 0 / 28, 1,64e-07 | 0,0197 [0,0095 ; 0,0360] | écart non tranché | 0 / 9, 0,0703 |
| J3 | δ̂* = 0 | BP79 | V3b | 507 | oui | 0,0434 [0,0274 ; 0,0650] | écart non tranché | 0 / 29, 8,2e-08 | 0,0197 [0,0095 ; 0,0360] | écart non tranché | 0 / 9, 0,0703 |
| J3 | δ̂* = 0 | BP79 | V3h | 507 | oui | 0,1006 [0,0758 ; 0,1301] | compatible | 0 / 0, 1 | 0,0375 [0,0227 ; 0,0579] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | White | V1 | 507 | oui | 0,0966 [0,0724 ; 0,1258] | compatible | — | 0,0414 [0,0258 ; 0,0626] | compatible | — |
| J3 | δ̂* = 0 | White | V3a | 507 | oui | 0,0966 [0,0724 ; 0,1258] | compatible | 2 / 2, 1 | 0,0473 [0,0306 ; 0,0696] | compatible | 4 / 1, 1 |
| J3 | δ̂* = 0 | White | V3b | 507 | oui | 0,0907 [0,0672 ; 0,1192] | compatible | 1 / 4, 1 | 0,0473 [0,0306 ; 0,0696] | compatible | 4 / 1, 1 |
| J3 | δ̂* = 0 | White | V3h | 507 | oui | 0,0966 [0,0724 ; 0,1258] | compatible | 0 / 0, 1 | 0,0414 [0,0258 ; 0,0626] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | GQ | V1 | 507 | oui | 0,0414 [0,0258 ; 0,0626] | écart non tranché | — | 0,0197 [0,0095 ; 0,0360] | écart non tranché | — |
| J3 | δ̂* = 0 | GQ | V3a | 507 | oui | 0,0986 [0,0741 ; 0,1279] | compatible | 39 / 10, 0,000615 | 0,0355 [0,0212 ; 0,0555] | compatible | 12 / 4, 0,75 |
| J3 | δ̂* = 0 | GQ | V3b | 507 | oui | 0,0986 [0,0741 ; 0,1279] | compatible | 39 / 10, 0,000654 | 0,0375 [0,0227 ; 0,0579] | compatible | 14 / 5, 0,75 |
| J3 | δ̂* = 0 | GQ | V3h | 507 | oui | 0,0414 [0,0258 ; 0,0626] | écart non tranché | 0 / 0, 1 | 0,0197 [0,0095 ; 0,0360] | écart non tranché | 0 / 0, 1 |
| J3 | δ̂* = 0 | BF | V1 | 507 | oui | 0,1243 [0,0968 ; 0,1562] | compatible | — | 0,0552 [0,0370 ; 0,0788] | compatible | — |
| J3 | δ̂* = 0 | BF | V3a | 507 | oui | 0,0828 [0,0604 ; 0,1103] | compatible | 0 / 21, 2e-05 | 0,0394 [0,0243 ; 0,0603] | compatible | 0 / 8, 0,125 |
| J3 | δ̂* = 0 | BF | V3b | 507 | oui | 0,0828 [0,0604 ; 0,1103] | compatible | 0 / 21, 2e-05 | 0,0375 [0,0227 ; 0,0579] | compatible | 0 / 9, 0,0703 |
| J3 | δ̂* = 0 | BF | V3h | 507 | oui | 0,1243 [0,0968 ; 0,1562] | compatible | 0 / 0, 1 | 0,0552 [0,0370 ; 0,0788] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | Smirnov | V1 | 507 | oui | 0,0434 [0,0274 ; 0,0650] | compatible | — | 0,0434 [0,0274 ; 0,0650] | compatible | — |
| J3 | δ̂* = 0 | Smirnov | V3a | 507 | oui | 0,0434 [0,0274 ; 0,0650] | compatible | 0 / 0, 1 | 0,0434 [0,0274 ; 0,0650] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | Smirnov | V3b | 507 | oui | 0,0434 [0,0274 ; 0,0650] | compatible | 0 / 0, 1 | 0,0434 [0,0274 ; 0,0650] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | Smirnov | V3h | 507 | oui | 0,0434 [0,0274 ; 0,0650] | compatible | 0 / 0, 1 | 0,0434 [0,0274 ; 0,0650] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | LB2 | V1 | 507 | oui | 0,1065 [0,0810 ; 0,1367] | compatible | — | 0,0454 [0,0290 ; 0,0673] | compatible | — |
| J3 | δ̂* = 0 | LB2 | V3a | 507 | oui | 0,1144 [0,0880 ; 0,1454] | compatible | 6 / 2, 1 | 0,0533 [0,0354 ; 0,0765] | compatible | 4 / 0, 1 |
| J3 | δ̂* = 0 | LB2 | V3b | 507 | oui | 0,1124 [0,0863 ; 0,1432] | compatible | 6 / 3, 1 | 0,0493 [0,0322 ; 0,0719] | compatible | 2 / 0, 1 |
| J3 | δ̂* = 0 | LB2 | V3h | 507 | oui | 0,1065 [0,0810 ; 0,1367] | compatible | 0 / 0, 1 | 0,0454 [0,0290 ; 0,0673] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | BP2 | V1 | 507 | oui | 0,0947 [0,0706 ; 0,1236] | compatible | — | 0,0454 [0,0290 ; 0,0673] | compatible | — |
| J3 | δ̂* = 0 | BP2 | V3a | 507 | oui | 0,1105 [0,0845 ; 0,1410] | compatible | 8 / 0, 0,102 | 0,0552 [0,0370 ; 0,0788] | compatible | 5 / 0, 0,75 |
| J3 | δ̂* = 0 | BP2 | V3b | 507 | oui | 0,1085 [0,0828 ; 0,1389] | compatible | 7 / 0, 0,188 | 0,0533 [0,0354 ; 0,0765] | compatible | 4 / 0, 1 |
| J3 | δ̂* = 0 | BP2 | V3h | 507 | oui | 0,0947 [0,0706 ; 0,1236] | compatible | 0 / 0, 1 | 0,0454 [0,0290 ; 0,0673] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | Runs | V1 | 507 | oui | 0,0572 [0,0386 ; 0,0811] | compatible | — | 0,0039 [0,0005 ; 0,0142] | compatible | — |
| J3 | δ̂* = 0 | Runs | V3a | 507 | oui | 0,0552 [0,0370 ; 0,0788] | compatible | 0 / 1, 1 | 0,0158 [0,0068 ; 0,0309] | compatible | 6 / 0, 0,344 |
| J3 | δ̂* = 0 | Runs | V3b | 507 | oui | 0,0572 [0,0386 ; 0,0811] | compatible | 0 / 0, 1 | 0,0138 [0,0056 ; 0,0282] | compatible | 5 / 0, 0,625 |
| J3 | δ̂* = 0 | Runs | V3h | 507 | oui | 0,0572 [0,0386 ; 0,0811] | compatible | 0 / 0, 1 | 0,0039 [0,0005 ; 0,0142] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | MK | V1 | 507 | oui | 0,0769 [0,0553 ; 0,1037] | compatible | — | 0,0355 [0,0212 ; 0,0555] | compatible | — |
| J3 | δ̂* = 0 | MK | V3a | 507 | oui | 0,0769 [0,0553 ; 0,1037] | compatible | 2 / 2, 1 | 0,0375 [0,0227 ; 0,0579] | compatible | 1 / 0, 1 |
| J3 | δ̂* = 0 | MK | V3b | 507 | oui | 0,0769 [0,0553 ; 0,1037] | compatible | 3 / 3, 1 | 0,0375 [0,0227 ; 0,0579] | compatible | 2 / 1, 1 |
| J3 | δ̂* = 0 | MK | V3h | 507 | oui | 0,0769 [0,0553 ; 0,1037] | compatible | 0 / 0, 1 | 0,0355 [0,0212 ; 0,0555] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | SpearVol | V1 | 507 | oui | 0,1085 [0,0828 ; 0,1389] | compatible | — | 0,0592 [0,0403 ; 0,0834] | compatible | — |
| J3 | δ̂* = 0 | SpearVol | V3a | 507 | oui | 0,1006 [0,0758 ; 0,1301] | compatible | 1 / 5, 1 | 0,0513 [0,0338 ; 0,0742] | compatible | 1 / 5, 1 |
| J3 | δ̂* = 0 | SpearVol | V3b | 507 | oui | 0,0947 [0,0706 ; 0,1236] | compatible | 0 / 7, 0,188 | 0,0473 [0,0306 ; 0,0696] | compatible | 0 / 6, 0,406 |
| J3 | δ̂* = 0 | SpearVol | V3h | 507 | oui | 0,1085 [0,0828 ; 0,1389] | compatible | 0 / 0, 1 | 0,0592 [0,0403 ; 0,0834] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | SpearTps | V1 | 507 | oui | 0,0947 [0,0706 ; 0,1236] | compatible | — | 0,0493 [0,0322 ; 0,0719] | compatible | — |
| J3 | δ̂* = 0 | SpearTps | V3a | 507 | oui | 0,0947 [0,0706 ; 0,1236] | compatible | 2 / 2, 1 | 0,0533 [0,0354 ; 0,0765] | compatible | 2 / 0, 1 |
| J3 | δ̂* = 0 | SpearTps | V3b | 507 | oui | 0,0966 [0,0724 ; 0,1258] | compatible | 3 / 2, 1 | 0,0513 [0,0338 ; 0,0742] | compatible | 2 / 1, 1 |
| J3 | δ̂* = 0 | SpearTps | V3h | 507 | oui | 0,0947 [0,0706 ; 0,1236] | compatible | 0 / 0, 1 | 0,0493 [0,0322 ; 0,0719] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | DAgo | V1 | 507 | oui | 0,1006 [0,0758 ; 0,1301] | compatible | — | 0,0473 [0,0306 ; 0,0696] | compatible | — |
| J3 | δ̂* = 0 | DAgo | V3a | 507 | oui | 0,0730 [0,0519 ; 0,0992] | écart mineur | 0 / 14, 0,00183 | 0,0335 [0,0197 ; 0,0531] | compatible | 0 / 7, 0,234 |
| J3 | δ̂* = 0 | DAgo | V3b | 507 | oui | 0,0710 [0,0502 ; 0,0969] | écart mineur | 0 / 15, 0,000977 | 0,0335 [0,0197 ; 0,0531] | compatible | 0 / 7, 0,234 |
| J3 | δ̂* = 0 | DAgo | V3h | 507 | oui | 0,1006 [0,0758 ; 0,1301] | compatible | 0 / 0, 1 | 0,0473 [0,0306 ; 0,0696] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | CoxStuart | V1 | 507 | oui | 0,0000 [0,0000 ; 0,0072] | compatible | — | 0,0000 [0,0000 ; 0,0072] | compatible | — |
| J3 | δ̂* = 0 | CoxStuart | V3a | 507 | oui | 0,0020 [0,0000 ; 0,0109] | compatible | 1 / 0, 1 | 0,0000 [0,0000 ; 0,0072] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | CoxStuart | V3b | 507 | oui | 0,0000 [0,0000 ; 0,0072] | compatible | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0072] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | CoxStuart | V3h | 507 | oui | 0,0000 [0,0000 ; 0,0072] | compatible | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0072] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | DWr | V1 | 507 | oui | 0,0868 [0,0638 ; 0,1148] | compatible | — | 0,0454 [0,0290 ; 0,0673] | compatible | — |
| J3 | δ̂* = 0 | DWr | V3a | 507 | oui | 0,0848 [0,0621 ; 0,1125] | compatible | 4 / 5, 1 | 0,0473 [0,0306 ; 0,0696] | compatible | 2 / 1, 1 |
| J3 | δ̂* = 0 | DWr | V3b | 507 | oui | 0,0868 [0,0638 ; 0,1148] | compatible | 4 / 4, 1 | 0,0473 [0,0306 ; 0,0696] | compatible | 2 / 1, 1 |
| J3 | δ̂* = 0 | DWr | V3h | 507 | oui | 0,0868 [0,0638 ; 0,1148] | compatible | 0 / 0, 1 | 0,0454 [0,0290 ; 0,0673] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | LB1r | V1 | 507 | oui | 0,0809 [0,0587 ; 0,1081] | compatible | — | 0,0316 [0,0181 ; 0,0507] | compatible | — |
| J3 | δ̂* = 0 | LB1r | V3a | 507 | oui | 0,0966 [0,0724 ; 0,1258] | compatible | 8 / 0, 0,102 | 0,0434 [0,0274 ; 0,0650] | compatible | 6 / 0, 0,438 |
| J3 | δ̂* = 0 | LB1r | V3b | 507 | oui | 0,1026 [0,0776 ; 0,1323] | compatible | 12 / 1, 0,0444 | 0,0454 [0,0290 ; 0,0673] | compatible | 7 / 0, 0,234 |
| J3 | δ̂* = 0 | LB1r | V3h | 507 | oui | 0,0809 [0,0587 ; 0,1081] | compatible | 0 / 0, 1 | 0,0316 [0,0181 ; 0,0507] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | Runsr | V1 | 507 | oui | 0,0473 [0,0306 ; 0,0696] | compatible | — | 0,0099 [0,0032 ; 0,0229] | compatible | — |
| J3 | δ̂* = 0 | Runsr | V3a | 507 | oui | 0,0473 [0,0306 ; 0,0696] | compatible | 0 / 0, 1 | 0,0217 [0,0109 ; 0,0385] | écart non tranché | 7 / 1, 0,633 |
| J3 | δ̂* = 0 | Runsr | V3b | 507 | oui | 0,0473 [0,0306 ; 0,0696] | compatible | 0 / 0, 1 | 0,0237 [0,0123 ; 0,0410] | écart non tranché | 10 / 3, 0,831 |
| J3 | δ̂* = 0 | Runsr | V3h | 507 | oui | 0,0473 [0,0306 ; 0,0696] | compatible | 0 / 0, 1 | 0,0099 [0,0032 ; 0,0229] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | supFr | V1 | 507 | oui | 0,1124 [0,0863 ; 0,1432] | compatible | — | 0,0671 [0,0469 ; 0,0925] | compatible | — |
| J3 | δ̂* = 0 | supFr | V3a | 507 | oui | 0,1085 [0,0828 ; 0,1389] | compatible | 2 / 4, 1 | 0,0572 [0,0386 ; 0,0811] | compatible | 0 / 5, 0,75 |
| J3 | δ̂* = 0 | supFr | V3b | 507 | oui | 0,1045 [0,0793 ; 0,1345] | compatible | 0 / 4, 1 | 0,0611 [0,0419 ; 0,0857] | compatible | 0 / 3, 1 |
| J3 | δ̂* = 0 | supFr | V3h | 507 | oui | 0,1124 [0,0863 ; 0,1432] | compatible | 0 / 0, 1 | 0,0671 [0,0469 ; 0,0925] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | CUSUMr | V1 | 507 | oui | 0,0927 [0,0689 ; 0,1214] | compatible | — | 0,0316 [0,0181 ; 0,0507] | compatible | — |
| J3 | δ̂* = 0 | CUSUMr | V3a | 507 | oui | 0,1045 [0,0793 ; 0,1345] | compatible | 6 / 0, 0,344 | 0,0493 [0,0322 ; 0,0719] | compatible | 9 / 0, 0,0703 |
| J3 | δ̂* = 0 | CUSUMr | V3b | 507 | oui | 0,0986 [0,0741 ; 0,1279] | compatible | 3 / 0, 1 | 0,0493 [0,0322 ; 0,0719] | compatible | 9 / 0, 0,0703 |
| J3 | δ̂* = 0 | CUSUMr | V3h | 507 | oui | 0,0927 [0,0689 ; 0,1214] | compatible | 0 / 0, 1 | 0,0316 [0,0181 ; 0,0507] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 0 | Grubbsr | V1 | 507 | oui | 0,1223 [0,0951 ; 0,1540] | compatible | — | 0,0671 [0,0469 ; 0,0925] | compatible | — |
| J3 | δ̂* = 0 | Grubbsr | V3a | 507 | oui | 0,0888 [0,0655 ; 0,1170] | compatible | 0 / 17, 0,000305 | 0,0414 [0,0258 ; 0,0626] | compatible | 0 / 13, 0,00488 |
| J3 | δ̂* = 0 | Grubbsr | V3b | 507 | oui | 0,0927 [0,0689 ; 0,1214] | compatible | 0 / 15, 0,000977 | 0,0394 [0,0243 ; 0,0603] | compatible | 0 / 14, 0,00256 |
| J3 | δ̂* = 0 | Grubbsr | V3h | 507 | oui | 0,1223 [0,0951 ; 0,1540] | compatible | 0 / 0, 1 | 0,0671 [0,0469 ; 0,0925] | compatible | 0 / 0, 1 |
| J3 | δ̂* intérieur | AD | V1 | 1125 | oui | 0,0702 [0,0560 ; 0,0868] | écart mineur | — | 0,0391 [0,0286 ; 0,0522] | compatible | — |
| J3 | δ̂* intérieur | AD | V3a | 1125 | oui | 0,0836 [0,0680 ; 0,1013] | compatible | 15 / 0, 0,00061 | 0,0444 [0,0332 ; 0,0582] | compatible | 6 / 0, 0,281 |
| J3 | δ̂* intérieur | AD | V3b | 1125 | oui | 0,0853 [0,0697 ; 0,1032] | compatible | 17 / 0, 0,000168 | 0,0444 [0,0332 ; 0,0582] | compatible | 6 / 0, 0,25 |
| J3 | δ̂* intérieur | AD | V3h | 1125 | oui | 0,0853 [0,0697 ; 0,1032] | compatible | 17 / 0, 0,000168 | 0,0444 [0,0332 ; 0,0582] | compatible | 6 / 0, 0,25 |
| J3 | δ̂* intérieur | CvM | V1 | 1125 | oui | 0,0791 [0,0640 ; 0,0965] | écart mineur | — | 0,0409 [0,0301 ; 0,0542] | compatible | — |
| J3 | δ̂* intérieur | CvM | V3a | 1125 | oui | 0,0844 [0,0689 ; 0,1022] | compatible | 9 / 3, 0,75 | 0,0418 [0,0309 ; 0,0552] | compatible | 3 / 2, 1 |
| J3 | δ̂* intérieur | CvM | V3b | 1125 | oui | 0,0836 [0,0680 ; 0,1013] | compatible | 7 / 2, 1 | 0,0436 [0,0324 ; 0,0572] | compatible | 4 / 1, 1 |
| J3 | δ̂* intérieur | CvM | V3h | 1125 | oui | 0,0836 [0,0680 ; 0,1013] | compatible | 7 / 2, 1 | 0,0436 [0,0324 ; 0,0572] | compatible | 4 / 1, 1 |
| J3 | δ̂* intérieur | KS | V1 | 1125 | oui | 0,0942 [0,0778 ; 0,1128] | compatible | — | 0,0471 [0,0355 ; 0,0612] | compatible | — |
| J3 | δ̂* intérieur | KS | V3a | 1125 | oui | 0,0916 [0,0753 ; 0,1099] | compatible | 3 / 6, 1 | 0,0489 [0,0370 ; 0,0632] | compatible | 5 / 3, 1 |
| J3 | δ̂* intérieur | KS | V3b | 1125 | oui | 0,0951 [0,0786 ; 0,1138] | compatible | 3 / 2, 1 | 0,0453 [0,0339 ; 0,0592] | compatible | 3 / 5, 1 |
| J3 | δ̂* intérieur | KS | V3h | 1125 | oui | 0,0951 [0,0786 ; 0,1138] | compatible | 3 / 2, 1 | 0,0453 [0,0339 ; 0,0592] | compatible | 3 / 5, 1 |
| J3 | δ̂* intérieur | SW | V1 | 1125 | oui | 0,0916 [0,0753 ; 0,1099] | compatible | — | 0,0409 [0,0301 ; 0,0542] | compatible | — |
| J3 | δ̂* intérieur | SW | V3a | 1125 | oui | 0,0933 [0,0770 ; 0,1119] | compatible | 5 / 3, 1 | 0,0436 [0,0324 ; 0,0572] | compatible | 4 / 1, 1 |
| J3 | δ̂* intérieur | SW | V3b | 1125 | oui | 0,0916 [0,0753 ; 0,1099] | compatible | 5 / 5, 1 | 0,0444 [0,0332 ; 0,0582] | compatible | 4 / 0, 0,75 |
| J3 | δ̂* intérieur | SW | V3h | 1125 | oui | 0,0916 [0,0753 ; 0,1099] | compatible | 5 / 5, 1 | 0,0444 [0,0332 ; 0,0582] | compatible | 4 / 0, 0,75 |
| J3 | δ̂* intérieur | SF | V1 | 1125 | oui | 0,0756 [0,0608 ; 0,0926] | écart mineur | — | 0,0338 [0,0240 ; 0,0461] | écart mineur | — |
| J3 | δ̂* intérieur | SF | V3a | 1125 | oui | 0,0889 [0,0729 ; 0,1071] | compatible | 16 / 1, 0,00247 | 0,0436 [0,0324 ; 0,0572] | compatible | 11 / 0, 0,00684 |
| J3 | δ̂* intérieur | SF | V3b | 1125 | oui | 0,0933 [0,0770 ; 0,1119] | compatible | 21 / 1, 0,000121 | 0,0400 [0,0293 ; 0,0532] | compatible | 7 / 0, 0,0781 |
| J3 | δ̂* intérieur | SF | V3h | 1125 | oui | 0,0933 [0,0770 ; 0,1119] | compatible | 21 / 1, 0,000121 | 0,0400 [0,0293 ; 0,0532] | compatible | 7 / 0, 0,0781 |
| J3 | δ̂* intérieur | JB | V1 | 1125 | oui | 0,0631 [0,0496 ; 0,0789] | écart mineur | — | 0,0196 [0,0123 ; 0,0295] | écart non tranché | — |
| J3 | δ̂* intérieur | JB | V3a | 1125 | oui | 0,0924 [0,0762 ; 0,1109] | compatible | 33 / 0, 3,26e-09 | 0,0427 [0,0316 ; 0,0562] | compatible | 26 / 0, 4,47e-07 |
| J3 | δ̂* intérieur | JB | V3b | 1125 | oui | 0,0978 [0,0810 ; 0,1166] | compatible | 39 / 0, 5,46e-11 | 0,0427 [0,0316 ; 0,0562] | compatible | 26 / 0, 4,77e-07 |
| J3 | δ̂* intérieur | JB | V3h | 1125 | oui | 0,0978 [0,0810 ; 0,1166] | compatible | 39 / 0, 5,46e-11 | 0,0427 [0,0316 ; 0,0562] | compatible | 26 / 0, 4,77e-07 |
| J3 | δ̂* intérieur | DW | V1 | 1125 | oui | 0,1147 [0,0966 ; 0,1347] | compatible | — | 0,0560 [0,0433 ; 0,0711] | compatible | — |
| J3 | δ̂* intérieur | DW | V3a | 1125 | oui | 0,1093 [0,0917 ; 0,1290] | compatible | 6 / 12, 1 | 0,0489 [0,0370 ; 0,0632] | compatible | 3 / 11, 0,287 |
| J3 | δ̂* intérieur | DW | V3b | 1125 | oui | 0,1067 [0,0892 ; 0,1262] | compatible | 5 / 14, 0,445 | 0,0542 [0,0417 ; 0,0691] | compatible | 6 / 8, 1 |
| J3 | δ̂* intérieur | DW | V3h | 1125 | oui | 0,1067 [0,0892 ; 0,1262] | compatible | 5 / 14, 0,445 | 0,0542 [0,0417 ; 0,0691] | compatible | 6 / 8, 1 |
| J3 | δ̂* intérieur | LB1 | V1 | 1125 | oui | 0,1227 [0,1041 ; 0,1433] | écart mineur | — | 0,0676 [0,0536 ; 0,0838] | écart mineur | — |
| J3 | δ̂* intérieur | LB1 | V3a | 1125 | oui | 0,1111 [0,0933 ; 0,1309] | compatible | 0 / 13, 0,0022 | 0,0587 [0,0457 ; 0,0740] | compatible | 1 / 11, 0,0635 |
| J3 | δ̂* intérieur | LB1 | V3b | 1125 | oui | 0,1084 [0,0909 ; 0,1281] | compatible | 1 / 17, 0,00145 | 0,0587 [0,0457 ; 0,0740] | compatible | 2 / 12, 0,116 |
| J3 | δ̂* intérieur | LB1 | V3h | 1125 | oui | 0,1084 [0,0909 ; 0,1281] | compatible | 1 / 17, 0,00145 | 0,0587 [0,0457 ; 0,0740] | compatible | 2 / 12, 0,116 |
| J3 | δ̂* intérieur | supF | V1 | 1125 | oui | 0,1084 [0,0909 ; 0,1281] | compatible | — | 0,0542 [0,0417 ; 0,0691] | compatible | — |
| J3 | δ̂* intérieur | supF | V3a | 1125 | oui | 0,1102 [0,0925 ; 0,1300] | compatible | 3 / 1, 1 | 0,0551 [0,0425 ; 0,0701] | compatible | 4 / 3, 1 |
| J3 | δ̂* intérieur | supF | V3b | 1125 | oui | 0,1084 [0,0909 ; 0,1281] | compatible | 4 / 4, 1 | 0,0551 [0,0425 ; 0,0701] | compatible | 4 / 3, 1 |
| J3 | δ̂* intérieur | supF | V3h | 1125 | oui | 0,1084 [0,0909 ; 0,1281] | compatible | 4 / 4, 1 | 0,0551 [0,0425 ; 0,0701] | compatible | 4 / 3, 1 |
| J3 | δ̂* intérieur | CUSUM | V1 | 1125 | oui | 0,1191 [0,1008 ; 0,1395] | écart mineur | — | 0,0622 [0,0488 ; 0,0780] | compatible | — |
| J3 | δ̂* intérieur | CUSUM | V3a | 1125 | oui | 0,1102 [0,0925 ; 0,1300] | compatible | 0 / 10, 0,0156 | 0,0569 [0,0441 ; 0,0721] | compatible | 0 / 6, 0,281 |
| J3 | δ̂* intérieur | CUSUM | V3b | 1125 | oui | 0,1129 [0,0950 ; 0,1328] | compatible | 1 / 8, 0,312 | 0,0542 [0,0417 ; 0,0691] | compatible | 0 / 9, 0,0391 |
| J3 | δ̂* intérieur | CUSUM | V3h | 1125 | oui | 0,1129 [0,0950 ; 0,1328] | compatible | 1 / 8, 0,312 | 0,0542 [0,0417 ; 0,0691] | compatible | 0 / 9, 0,0391 |
| J3 | δ̂* intérieur | Grubbs | V1 | 1125 | oui | 0,0427 [0,0316 ; 0,0562] | écart non tranché | — | 0,0116 [0,0062 ; 0,0197] **conservateur** | distorsion matérielle | — |
| J3 | δ̂* intérieur | Grubbs | V3a | 1125 | oui | 0,1013 [0,0843 ; 0,1205] | compatible | 66 / 0, 4,88e-19 | 0,0533 [0,0409 ; 0,0681] | compatible | 47 / 0, 2,7e-13 |
| J3 | δ̂* intérieur | Grubbs | V3b | 1125 | oui | 0,1004 [0,0835 ; 0,1195] | compatible | 65 / 0, 9,76e-19 | 0,0569 [0,0441 ; 0,0721] | compatible | 51 / 0, 1,69e-14 |
| J3 | δ̂* intérieur | Grubbs | V3h | 1125 | oui | 0,1004 [0,0835 ; 0,1195] | compatible | 65 / 0, 9,76e-19 | 0,0569 [0,0441 ; 0,0721] | compatible | 51 / 0, 1,69e-14 |
| J3 | δ̂* intérieur | Lillie | V1 | 1125 | oui | 0,0880 [0,0721 ; 0,1061] | compatible | — | 0,0382 [0,0278 ; 0,0511] | compatible | — |
| J3 | δ̂* intérieur | Lillie | V3a | 1125 | oui | 0,0871 [0,0713 ; 0,1051] | compatible | 1 / 2, 1 | 0,0436 [0,0324 ; 0,0572] | compatible | 6 / 0, 0,281 |
| J3 | δ̂* intérieur | Lillie | V3b | 1125 | oui | 0,0880 [0,0721 ; 0,1061] | compatible | 4 / 4, 1 | 0,0436 [0,0324 ; 0,0572] | compatible | 7 / 1, 0,492 |
| J3 | δ̂* intérieur | Lillie | V3h | 1125 | oui | 0,0880 [0,0721 ; 0,1061] | compatible | 4 / 4, 1 | 0,0436 [0,0324 ; 0,0572] | compatible | 7 / 1, 0,492 |
| J3 | δ̂* intérieur | Intercept | V1 | 1125 | oui | 0,0347 [0,0248 ; 0,0471] **conservateur** | distorsion matérielle | — | 0,0116 [0,0062 ; 0,0197] **conservateur** | distorsion matérielle | — |
| J3 | δ̂* intérieur | Intercept | V3a | 1125 | oui | 0,0818 [0,0664 ; 0,0994] | écart mineur | 53 / 0, 2,66e-15 | 0,0400 [0,0293 ; 0,0532] | compatible | 32 / 0, 5,59e-09 |
| J3 | δ̂* intérieur | Intercept | V3b | 1125 | oui | 0,0818 [0,0664 ; 0,0994] | écart mineur | 53 / 0, 2,66e-15 | 0,0391 [0,0286 ; 0,0522] | compatible | 31 / 0, 1,12e-08 |
| J3 | δ̂* intérieur | Intercept | V3h | 1125 | oui | 0,0818 [0,0664 ; 0,0994] | écart mineur | 53 / 0, 2,66e-15 | 0,0391 [0,0286 ; 0,0522] | compatible | 31 / 0, 1,12e-08 |
| J3 | δ̂* intérieur | RESET | V1 | 1125 | oui | 0,1280 [0,1090 ; 0,1489] | écart mineur | — | 0,0711 [0,0568 ; 0,0877] | écart mineur | — |
| J3 | δ̂* intérieur | RESET | V3a | 1125 | oui | 0,1102 [0,0925 ; 0,1300] | compatible | 1 / 21, 0,000132 | 0,0604 [0,0472 ; 0,0760] | compatible | 0 / 12, 0,00488 |
| J3 | δ̂* intérieur | RESET | V3b | 1125 | oui | 0,1147 [0,0966 ; 0,1347] | compatible | 1 / 16, 0,00275 | 0,0596 [0,0464 ; 0,0750] | compatible | 0 / 13, 0,00244 |
| J3 | δ̂* intérieur | RESET | V3h | 1125 | oui | 0,1147 [0,0966 ; 0,1347] | compatible | 1 / 16, 0,00275 | 0,0596 [0,0464 ; 0,0750] | compatible | 0 / 13, 0,00244 |
| J3 | δ̂* intérieur | BP | V1 | 1125 | oui | 0,0000 [0,0000 ; 0,0033] **conservateur** | distorsion matérielle | — | 0,0000 [0,0000 ; 0,0033] **conservateur** | distorsion matérielle | — |
| J3 | δ̂* intérieur | BP | V3a | 1125 | oui | 0,1209 [0,1024 ; 0,1414] | écart mineur | 136 / 0, 5,05e-40 | 0,0613 [0,0480 ; 0,0770] | compatible | 69 / 0, 7,45e-20 |
| J3 | δ̂* intérieur | BP | V3b | 1125 | oui | 0,1200 [0,1016 ; 0,1404] | écart mineur | 135 / 0, 1,01e-39 | 0,0613 [0,0480 ; 0,0770] | compatible | 69 / 0, 7,45e-20 |
| J3 | δ̂* intérieur | BP | V3h | 1125 | oui | 0,1200 [0,1016 ; 0,1404] | écart mineur | 135 / 0, 1,01e-39 | 0,0613 [0,0480 ; 0,0770] | compatible | 69 / 0, 7,45e-20 |
| J3 | δ̂* intérieur | BP79 | V1 | 1125 | oui | 0,0000 [0,0000 ; 0,0033] **conservateur** | distorsion matérielle | — | 0,0000 [0,0000 ; 0,0033] **conservateur** | distorsion matérielle | — |
| J3 | δ̂* intérieur | BP79 | V3a | 1125 | oui | 0,1191 [0,1008 ; 0,1395] | écart mineur | 134 / 0, 1,93e-39 | 0,0569 [0,0441 ; 0,0721] | compatible | 64 / 0, 2,28e-18 |
| J3 | δ̂* intérieur | BP79 | V3b | 1125 | oui | 0,1173 [0,0991 ; 0,1376] | compatible | 132 / 0, 7,71e-39 | 0,0613 [0,0480 ; 0,0770] | compatible | 69 / 0, 7,45e-20 |
| J3 | δ̂* intérieur | BP79 | V3h | 1125 | oui | 0,1173 [0,0991 ; 0,1376] | compatible | 132 / 0, 7,71e-39 | 0,0613 [0,0480 ; 0,0770] | compatible | 69 / 0, 7,45e-20 |
| J3 | δ̂* intérieur | White | V1 | 1125 | oui | 0,0729 [0,0584 ; 0,0897] | écart mineur | — | 0,0347 [0,0248 ; 0,0471] | écart mineur | — |
| J3 | δ̂* intérieur | White | V3a | 1125 | oui | 0,1147 [0,0966 ; 0,1347] | compatible | 47 / 0, 2,42e-13 | 0,0560 [0,0433 ; 0,0711] | compatible | 24 / 0, 1,67e-06 |
| J3 | δ̂* intérieur | White | V3b | 1125 | oui | 0,1173 [0,0991 ; 0,1376] | compatible | 50 / 0, 2,84e-14 | 0,0551 [0,0425 ; 0,0701] | compatible | 23 / 0, 3,34e-06 |
| J3 | δ̂* intérieur | White | V3h | 1125 | oui | 0,1173 [0,0991 ; 0,1376] | compatible | 50 / 0, 2,84e-14 | 0,0551 [0,0425 ; 0,0701] | compatible | 23 / 0, 3,34e-06 |
| J3 | δ̂* intérieur | GQ | V1 | 1125 | oui | 0,0071 [0,0031 ; 0,0140] **conservateur** | distorsion matérielle | — | 0,0000 [0,0000 ; 0,0033] **conservateur** | distorsion matérielle | — |
| J3 | δ̂* intérieur | GQ | V3a | 1125 | oui | 0,1244 [0,1057 ; 0,1452] | écart mineur | 132 / 0, 7,35e-39 | 0,0489 [0,0370 ; 0,0632] | compatible | 55 / 0, 1,11e-15 |
| J3 | δ̂* intérieur | GQ | V3b | 1125 | oui | 0,1227 [0,1041 ; 0,1433] | écart mineur | 130 / 0, 2,94e-38 | 0,0489 [0,0370 ; 0,0632] | compatible | 55 / 0, 1,11e-15 |
| J3 | δ̂* intérieur | GQ | V3h | 1125 | oui | 0,1227 [0,1041 ; 0,1433] | écart mineur | 130 / 0, 2,94e-38 | 0,0489 [0,0370 ; 0,0632] | compatible | 55 / 0, 1,11e-15 |
| J3 | δ̂* intérieur | BF | V1 | 1125 | oui | 0,0160 [0,0095 ; 0,0252] **conservateur** | distorsion matérielle | — | 0,0053 [0,0020 ; 0,0116] **conservateur** | distorsion matérielle | — |
| J3 | δ̂* intérieur | BF | V3a | 1125 | oui | 0,0951 [0,0786 ; 0,1138] | compatible | 89 / 0, 6,14e-26 | 0,0444 [0,0332 ; 0,0582] | compatible | 44 / 0, 2,05e-12 |
| J3 | δ̂* intérieur | BF | V3b | 1125 | oui | 0,0942 [0,0778 ; 0,1128] | compatible | 88 / 0, 1,23e-25 | 0,0444 [0,0332 ; 0,0582] | compatible | 44 / 0, 2,05e-12 |
| J3 | δ̂* intérieur | BF | V3h | 1125 | oui | 0,0942 [0,0778 ; 0,1128] | compatible | 88 / 0, 1,23e-25 | 0,0444 [0,0332 ; 0,0582] | compatible | 44 / 0, 2,05e-12 |
| J3 | δ̂* intérieur | Smirnov | V1 | 1125 | oui | 0,0018 [0,0002 ; 0,0064] **conservateur** | distorsion matérielle | — | 0,0018 [0,0002 ; 0,0064] **conservateur** | distorsion matérielle | — |
| J3 | δ̂* intérieur | Smirnov | V3a | 1125 | oui | 0,0213 [0,0137 ; 0,0316] | compatible | 22 / 0, 5,25e-06 | 0,0018 [0,0002 ; 0,0064] **conservateur** | distorsion matérielle | 0 / 0, 1 |
| J3 | δ̂* intérieur | Smirnov | V3b | 1125 | oui | 0,0133 [0,0075 ; 0,0219] | écart non tranché | 13 / 0, 0,0022 | 0,0018 [0,0002 ; 0,0064] **conservateur** | distorsion matérielle | 0 / 0, 1 |
| J3 | δ̂* intérieur | Smirnov | V3h | 1125 | oui | 0,0133 [0,0075 ; 0,0219] | écart non tranché | 13 / 0, 0,0022 | 0,0018 [0,0002 ; 0,0064] **conservateur** | distorsion matérielle | 0 / 0, 1 |
| J3 | δ̂* intérieur | LB2 | V1 | 1125 | oui | 0,1138 [0,0958 ; 0,1338] | compatible | — | 0,0596 [0,0464 ; 0,0750] | compatible | — |
| J3 | δ̂* intérieur | LB2 | V3a | 1125 | oui | 0,1084 [0,0909 ; 0,1281] | compatible | 1 / 7, 0,492 | 0,0489 [0,0370 ; 0,0632] | compatible | 0 / 12, 0,00488 |
| J3 | δ̂* intérieur | LB2 | V3b | 1125 | oui | 0,1058 [0,0884 ; 0,1252] | compatible | 1 / 10, 0,105 | 0,0498 [0,0378 ; 0,0642] | compatible | 0 / 11, 0,00879 |
| J3 | δ̂* intérieur | LB2 | V3h | 1125 | oui | 0,1058 [0,0884 ; 0,1252] | compatible | 1 / 10, 0,105 | 0,0498 [0,0378 ; 0,0642] | compatible | 0 / 11, 0,00879 |
| J3 | δ̂* intérieur | BP2 | V1 | 1125 | oui | 0,1156 [0,0975 ; 0,1357] | compatible | — | 0,0640 [0,0504 ; 0,0799] | écart mineur | — |
| J3 | δ̂* intérieur | BP2 | V3a | 1125 | oui | 0,1040 [0,0868 ; 0,1233] | compatible | 0 / 13, 0,00244 | 0,0524 [0,0402 ; 0,0671] | compatible | 0 / 13, 0,00269 |
| J3 | δ̂* intérieur | BP2 | V3b | 1125 | oui | 0,1102 [0,0925 ; 0,1300] | compatible | 2 / 8, 0,656 | 0,0498 [0,0378 ; 0,0642] | compatible | 0 / 16, 0,000366 |
| J3 | δ̂* intérieur | BP2 | V3h | 1125 | oui | 0,1102 [0,0925 ; 0,1300] | compatible | 2 / 8, 0,656 | 0,0498 [0,0378 ; 0,0642] | compatible | 0 / 16, 0,000366 |
| J3 | δ̂* intérieur | Runs | V1 | 1125 | oui | 0,0782 [0,0632 ; 0,0955] | écart mineur | — | 0,0089 [0,0043 ; 0,0163] | compatible | — |
| J3 | δ̂* intérieur | Runs | V3a | 1125 | oui | 0,0738 [0,0592 ; 0,0906] | écart mineur | 0 / 5, 0,438 | 0,0071 [0,0031 ; 0,0140] | compatible | 2 / 4, 1 |
| J3 | δ̂* intérieur | Runs | V3b | 1125 | oui | 0,0773 [0,0624 ; 0,0945] | écart mineur | 0 / 1, 1 | 0,0062 [0,0025 ; 0,0128] | compatible | 1 / 4, 1 |
| J3 | δ̂* intérieur | Runs | V3h | 1125 | oui | 0,0773 [0,0624 ; 0,0945] | écart mineur | 0 / 1, 1 | 0,0062 [0,0025 ; 0,0128] | compatible | 1 / 4, 1 |
| J3 | δ̂* intérieur | MK | V1 | 1125 | oui | 0,0844 [0,0689 ; 0,1022] | compatible | — | 0,0444 [0,0332 ; 0,0582] | compatible | — |
| J3 | δ̂* intérieur | MK | V3a | 1125 | oui | 0,0836 [0,0680 ; 0,1013] | compatible | 4 / 5, 1 | 0,0471 [0,0355 ; 0,0612] | écart mineur | 4 / 1, 1 |
| J3 | δ̂* intérieur | MK | V3b | 1125 | oui | 0,0862 [0,0705 ; 0,1042] | compatible | 6 / 4, 1 | 0,0444 [0,0332 ; 0,0582] | compatible | 3 / 3, 1 |
| J3 | δ̂* intérieur | MK | V3h | 1125 | oui | 0,0862 [0,0705 ; 0,1042] | compatible | 6 / 4, 1 | 0,0444 [0,0332 ; 0,0582] | compatible | 3 / 3, 1 |
| J3 | δ̂* intérieur | SpearVol | V1 | 1125 | oui | 0,0533 [0,0409 ; 0,0681] | écart mineur | — | 0,0142 [0,0082 ; 0,0230] | écart non tranché | — |
| J3 | δ̂* intérieur | SpearVol | V3a | 1125 | oui | 0,0756 [0,0608 ; 0,0926] | compatible | 26 / 1, 5,42e-06 | 0,0293 [0,0203 ; 0,0409] | écart mineur | 17 / 0, 0,000183 |
| J3 | δ̂* intérieur | SpearVol | V3b | 1125 | oui | 0,0729 [0,0584 ; 0,0897] | écart mineur | 22 / 0, 6,2e-06 | 0,0302 [0,0210 ; 0,0420] | écart mineur | 18 / 0, 9,92e-05 |
| J3 | δ̂* intérieur | SpearVol | V3h | 1125 | oui | 0,0729 [0,0584 ; 0,0897] | écart mineur | 22 / 0, 6,2e-06 | 0,0302 [0,0210 ; 0,0420] | écart mineur | 18 / 0, 9,92e-05 |
| J3 | δ̂* intérieur | SpearTps | V1 | 1125 | oui | 0,1040 [0,0868 ; 0,1233] | compatible | — | 0,0542 [0,0417 ; 0,0691] | compatible | — |
| J3 | δ̂* intérieur | SpearTps | V3a | 1125 | oui | 0,1013 [0,0843 ; 0,1205] | compatible | 4 / 7, 1 | 0,0507 [0,0386 ; 0,0651] | compatible | 1 / 5, 0,875 |
| J3 | δ̂* intérieur | SpearTps | V3b | 1125 | oui | 0,1031 [0,0860 ; 0,1224] | compatible | 8 / 9, 1 | 0,0533 [0,0409 ; 0,0681] | compatible | 4 / 5, 1 |
| J3 | δ̂* intérieur | SpearTps | V3h | 1125 | oui | 0,1031 [0,0860 ; 0,1224] | compatible | 8 / 9, 1 | 0,0533 [0,0409 ; 0,0681] | compatible | 4 / 5, 1 |
| J3 | δ̂* intérieur | DAgo | V1 | 1125 | oui | 0,0427 [0,0316 ; 0,0562] | écart non tranché | — | 0,0169 [0,0102 ; 0,0262] | écart non tranché | — |
| J3 | δ̂* intérieur | DAgo | V3a | 1125 | oui | 0,0818 [0,0664 ; 0,0994] | écart mineur | 44 / 0, 1,82e-12 | 0,0427 [0,0316 ; 0,0562] | compatible | 29 / 0, 5,96e-08 |
| J3 | δ̂* intérieur | DAgo | V3b | 1125 | oui | 0,0880 [0,0721 ; 0,1061] | compatible | 51 / 0, 1,51e-14 | 0,0391 [0,0286 ; 0,0522] | compatible | 25 / 0, 8,94e-07 |
| J3 | δ̂* intérieur | DAgo | V3h | 1125 | oui | 0,0880 [0,0721 ; 0,1061] | compatible | 51 / 0, 1,51e-14 | 0,0391 [0,0286 ; 0,0522] | compatible | 25 / 0, 8,94e-07 |
| J3 | δ̂* intérieur | CoxStuart | V1 | 1125 | oui | 0,0000 [0,0000 ; 0,0033] | compatible | — | 0,0000 [0,0000 ; 0,0033] | compatible | — |
| J3 | δ̂* intérieur | CoxStuart | V3a | 1125 | oui | 0,0036 [0,0010 ; 0,0091] | écart à examiner (bande non applicable) | 4 / 0, 0,75 | 0,0000 [0,0000 ; 0,0033] | compatible | 0 / 0, 1 |
| J3 | δ̂* intérieur | CoxStuart | V3b | 1125 | oui | 0,0000 [0,0000 ; 0,0033] | compatible | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0033] | compatible | 0 / 0, 1 |
| J3 | δ̂* intérieur | CoxStuart | V3h | 1125 | oui | 0,0000 [0,0000 ; 0,0033] | compatible | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0033] | compatible | 0 / 0, 1 |
| J3 | δ̂* intérieur | DWr | V1 | 1125 | oui | 0,1120 [0,0942 ; 0,1319] | compatible | — | 0,0587 [0,0457 ; 0,0740] | compatible | — |
| J3 | δ̂* intérieur | DWr | V3a | 1125 | oui | 0,1067 [0,0892 ; 0,1262] | compatible | 11 / 17, 1 | 0,0480 [0,0363 ; 0,0622] | compatible | 4 / 16, 0,0709 |
| J3 | δ̂* intérieur | DWr | V3b | 1125 | oui | 0,1049 [0,0876 ; 0,1243] | compatible | 9 / 17, 0,843 | 0,0489 [0,0370 ; 0,0632] | compatible | 1 / 12, 0,0273 |
| J3 | δ̂* intérieur | DWr | V3h | 1125 | oui | 0,1049 [0,0876 ; 0,1243] | compatible | 9 / 17, 0,843 | 0,0489 [0,0370 ; 0,0632] | compatible | 1 / 12, 0,0273 |
| J3 | δ̂* intérieur | LB1r | V1 | 1125 | oui | 0,1218 [0,1032 ; 0,1423] | écart mineur | — | 0,0702 [0,0560 ; 0,0868] | écart mineur | — |
| J3 | δ̂* intérieur | LB1r | V3a | 1125 | oui | 0,1084 [0,0909 ; 0,1281] | compatible | 0 / 15, 0,000671 | 0,0533 [0,0409 ; 0,0681] | compatible | 0 / 19, 4,96e-05 |
| J3 | δ̂* intérieur | LB1r | V3b | 1125 | oui | 0,1058 [0,0884 ; 0,1252] | compatible | 0 / 18, 9,16e-05 | 0,0551 [0,0425 ; 0,0701] | compatible | 1 / 18, 0,000839 |
| J3 | δ̂* intérieur | LB1r | V3h | 1125 | oui | 0,1058 [0,0884 ; 0,1252] | compatible | 0 / 18, 9,16e-05 | 0,0551 [0,0425 ; 0,0701] | compatible | 1 / 18, 0,000839 |
| J3 | δ̂* intérieur | Runsr | V1 | 1125 | oui | 0,0684 [0,0544 ; 0,0848] | compatible | — | 0,0187 [0,0116 ; 0,0284] | écart non tranché | — |
| J3 | δ̂* intérieur | Runsr | V3a | 1125 | oui | 0,0676 [0,0536 ; 0,0838] | compatible | 0 / 1, 1 | 0,0107 [0,0055 ; 0,0186] | compatible | 0 / 9, 0,043 |
| J3 | δ̂* intérieur | Runsr | V3b | 1125 | oui | 0,0676 [0,0536 ; 0,0838] | compatible | 0 / 1, 1 | 0,0071 [0,0031 ; 0,0140] | compatible | 1 / 14, 0,0107 |
| J3 | δ̂* intérieur | Runsr | V3h | 1125 | oui | 0,0676 [0,0536 ; 0,0838] | compatible | 0 / 1, 1 | 0,0071 [0,0031 ; 0,0140] | compatible | 1 / 14, 0,0107 |
| J3 | δ̂* intérieur | supFr | V1 | 1125 | oui | 0,1058 [0,0884 ; 0,1252] | compatible | — | 0,0462 [0,0347 ; 0,0602] | compatible | — |
| J3 | δ̂* intérieur | supFr | V3a | 1125 | oui | 0,1093 [0,0917 ; 0,1290] | compatible | 7 / 3, 1 | 0,0569 [0,0441 ; 0,0721] | compatible | 12 / 0, 0,00488 |
| J3 | δ̂* intérieur | supFr | V3b | 1125 | oui | 0,1093 [0,0917 ; 0,1290] | compatible | 6 / 2, 1 | 0,0533 [0,0409 ; 0,0681] | compatible | 8 / 0, 0,0547 |
| J3 | δ̂* intérieur | supFr | V3h | 1125 | oui | 0,1093 [0,0917 ; 0,1290] | compatible | 6 / 2, 1 | 0,0533 [0,0409 ; 0,0681] | compatible | 8 / 0, 0,0547 |
| J3 | δ̂* intérieur | CUSUMr | V1 | 1125 | oui | 0,1173 [0,0991 ; 0,1376] | compatible | — | 0,0596 [0,0464 ; 0,0750] | compatible | — |
| J3 | δ̂* intérieur | CUSUMr | V3a | 1125 | oui | 0,1067 [0,0892 ; 0,1262] | compatible | 3 / 15, 0,0603 | 0,0569 [0,0441 ; 0,0721] | compatible | 3 / 6, 1 |
| J3 | δ̂* intérieur | CUSUMr | V3b | 1125 | oui | 0,1093 [0,0917 ; 0,1290] | compatible | 2 / 11, 0,18 | 0,0507 [0,0386 ; 0,0651] | compatible | 2 / 12, 0,0776 |
| J3 | δ̂* intérieur | CUSUMr | V3h | 1125 | oui | 0,1093 [0,0917 ; 0,1290] | compatible | 2 / 11, 0,18 | 0,0507 [0,0386 ; 0,0651] | compatible | 2 / 12, 0,0776 |
| J3 | δ̂* intérieur | Grubbsr | V1 | 1125 | oui | 0,0524 [0,0402 ; 0,0671] | écart mineur | — | 0,0222 [0,0144 ; 0,0326] | écart non tranché | — |
| J3 | δ̂* intérieur | Grubbsr | V3a | 1125 | oui | 0,0862 [0,0705 ; 0,1042] | compatible | 38 / 0, 1,09e-10 | 0,0560 [0,0433 ; 0,0711] | compatible | 38 / 0, 1,24e-10 |
| J3 | δ̂* intérieur | Grubbsr | V3b | 1125 | oui | 0,0800 [0,0648 ; 0,0974] | écart mineur | 31 / 0, 1,3e-08 | 0,0542 [0,0417 ; 0,0691] | compatible | 36 / 0, 4,95e-10 |
| J3 | δ̂* intérieur | Grubbsr | V3h | 1125 | oui | 0,0800 [0,0648 ; 0,0974] | écart mineur | 31 / 0, 1,3e-08 | 0,0542 [0,0417 ; 0,0691] | compatible | 36 / 0, 4,95e-10 |
| J3 | δ̂* = 1 | AD | V1 | 368 | oui | 0,0516 [0,0314 ; 0,0795] | écart mineur | — | 0,0299 [0,0150 ; 0,0529] | compatible | — |
| J3 | δ̂* = 1 | AD | V3a | 368 | oui | 0,0815 [0,0557 ; 0,1143] | compatible | 11 / 0, 0,0117 | 0,0380 [0,0210 ; 0,0630] | compatible | 3 / 0, 1 |
| J3 | δ̂* = 1 | AD | V3b | 368 | oui | 0,0788 [0,0534 ; 0,1112] | compatible | 10 / 0, 0,0215 | 0,0380 [0,0210 ; 0,0630] | compatible | 3 / 0, 1 |
| J3 | δ̂* = 1 | AD | V3h | 368 | oui | 0,0516 [0,0314 ; 0,0795] | écart mineur | 0 / 0, 1 | 0,0299 [0,0150 ; 0,0529] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | CvM | V1 | 368 | oui | 0,0516 [0,0314 ; 0,0795] | écart mineur | — | 0,0272 [0,0131 ; 0,0494] | écart mineur | — |
| J3 | δ̂* = 1 | CvM | V3a | 368 | oui | 0,0761 [0,0512 ; 0,1081] | compatible | 9 / 0, 0,043 | 0,0353 [0,0189 ; 0,0597] | compatible | 3 / 0, 1 |
| J3 | δ̂* = 1 | CvM | V3b | 368 | oui | 0,0815 [0,0557 ; 0,1143] | compatible | 11 / 0, 0,0117 | 0,0380 [0,0210 ; 0,0630] | compatible | 4 / 0, 1 |
| J3 | δ̂* = 1 | CvM | V3h | 368 | oui | 0,0516 [0,0314 ; 0,0795] | écart mineur | 0 / 0, 1 | 0,0272 [0,0131 ; 0,0494] | écart mineur | 0 / 0, 1 |
| J3 | δ̂* = 1 | KS | V1 | 368 | oui | 0,0516 [0,0314 ; 0,0795] | écart mineur | — | 0,0136 [0,0044 ; 0,0314] | écart non tranché | — |
| J3 | δ̂* = 1 | KS | V3a | 368 | oui | 0,0679 [0,0444 ; 0,0987] | écart mineur | 6 / 0, 0,281 | 0,0326 [0,0170 ; 0,0563] | compatible | 7 / 0, 0,188 |
| J3 | δ̂* = 1 | KS | V3b | 368 | oui | 0,0707 [0,0467 ; 0,1018] | compatible | 7 / 0, 0,141 | 0,0299 [0,0150 ; 0,0529] | compatible | 6 / 0, 0,375 |
| J3 | δ̂* = 1 | KS | V3h | 368 | oui | 0,0516 [0,0314 ; 0,0795] | écart mineur | 0 / 0, 1 | 0,0136 [0,0044 ; 0,0314] | écart non tranché | 0 / 0, 1 |
| J3 | δ̂* = 1 | SW | V1 | 368 | oui | 0,0870 [0,0602 ; 0,1205] | compatible | — | 0,0489 [0,0292 ; 0,0762] | compatible | — |
| J3 | δ̂* = 1 | SW | V3a | 368 | oui | 0,0761 [0,0512 ; 0,1081] | compatible | 1 / 5, 1 | 0,0462 [0,0271 ; 0,0729] | compatible | 0 / 1, 1 |
| J3 | δ̂* = 1 | SW | V3b | 368 | oui | 0,0842 [0,0580 ; 0,1174] | compatible | 1 / 2, 1 | 0,0462 [0,0271 ; 0,0729] | compatible | 0 / 1, 1 |
| J3 | δ̂* = 1 | SW | V3h | 368 | oui | 0,0870 [0,0602 ; 0,1205] | compatible | 0 / 0, 1 | 0,0489 [0,0292 ; 0,0762] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | SF | V1 | 368 | oui | 0,0870 [0,0602 ; 0,1205] | compatible | — | 0,0543 [0,0335 ; 0,0827] | compatible | — |
| J3 | δ̂* = 1 | SF | V3a | 368 | oui | 0,0734 [0,0489 ; 0,1050] | compatible | 0 / 5, 0,875 | 0,0408 [0,0230 ; 0,0663] | compatible | 0 / 5, 0,938 |
| J3 | δ̂* = 1 | SF | V3b | 368 | oui | 0,0707 [0,0467 ; 0,1018] | compatible | 0 / 6, 0,438 | 0,0408 [0,0230 ; 0,0663] | compatible | 0 / 5, 1 |
| J3 | δ̂* = 1 | SF | V3h | 368 | oui | 0,0870 [0,0602 ; 0,1205] | compatible | 0 / 0, 1 | 0,0543 [0,0335 ; 0,0827] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | JB | V1 | 368 | oui | 0,1033 [0,0741 ; 0,1390] | compatible | — | 0,0652 [0,0422 ; 0,0955] | compatible | — |
| J3 | δ̂* = 1 | JB | V3a | 368 | oui | 0,0734 [0,0489 ; 0,1050] | compatible | 0 / 11, 0,0156 | 0,0353 [0,0189 ; 0,0597] | compatible | 0 / 11, 0,0195 |
| J3 | δ̂* = 1 | JB | V3b | 368 | oui | 0,0734 [0,0489 ; 0,1050] | compatible | 0 / 11, 0,0156 | 0,0353 [0,0189 ; 0,0597] | compatible | 0 / 11, 0,0186 |
| J3 | δ̂* = 1 | JB | V3h | 368 | oui | 0,1033 [0,0741 ; 0,1390] | compatible | 0 / 0, 1 | 0,0652 [0,0422 ; 0,0955] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | DW | V1 | 368 | oui | 0,0734 [0,0489 ; 0,1050] | compatible | — | 0,0435 [0,0251 ; 0,0696] | compatible | — |
| J3 | δ̂* = 1 | DW | V3a | 368 | oui | 0,0788 [0,0534 ; 0,1112] | compatible | 3 / 1, 1 | 0,0435 [0,0251 ; 0,0696] | compatible | 1 / 1, 1 |
| J3 | δ̂* = 1 | DW | V3b | 368 | oui | 0,0788 [0,0534 ; 0,1112] | compatible | 4 / 2, 1 | 0,0462 [0,0271 ; 0,0729] | compatible | 2 / 1, 1 |
| J3 | δ̂* = 1 | DW | V3h | 368 | oui | 0,0734 [0,0489 ; 0,1050] | compatible | 0 / 0, 1 | 0,0435 [0,0251 ; 0,0696] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | LB1 | V1 | 368 | oui | 0,0679 [0,0444 ; 0,0987] | écart mineur | — | 0,0299 [0,0150 ; 0,0529] | compatible | — |
| J3 | δ̂* = 1 | LB1 | V3a | 368 | oui | 0,0734 [0,0489 ; 0,1050] | compatible | 3 / 1, 1 | 0,0326 [0,0170 ; 0,0563] | compatible | 2 / 1, 1 |
| J3 | δ̂* = 1 | LB1 | V3b | 368 | oui | 0,0679 [0,0444 ; 0,0987] | écart mineur | 1 / 1, 1 | 0,0299 [0,0150 ; 0,0529] | compatible | 1 / 1, 1 |
| J3 | δ̂* = 1 | LB1 | V3h | 368 | oui | 0,0679 [0,0444 ; 0,0987] | écart mineur | 0 / 0, 1 | 0,0299 [0,0150 ; 0,0529] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | supF | V1 | 368 | oui | 0,1141 [0,0835 ; 0,1511] | compatible | — | 0,0516 [0,0314 ; 0,0795] | compatible | — |
| J3 | δ̂* = 1 | supF | V3a | 368 | oui | 0,1141 [0,0835 ; 0,1511] | compatible | 2 / 2, 1 | 0,0462 [0,0271 ; 0,0729] | compatible | 0 / 2, 1 |
| J3 | δ̂* = 1 | supF | V3b | 368 | oui | 0,1033 [0,0741 ; 0,1390] | compatible | 0 / 4, 1 | 0,0489 [0,0292 ; 0,0762] | compatible | 1 / 2, 1 |
| J3 | δ̂* = 1 | supF | V3h | 368 | oui | 0,1141 [0,0835 ; 0,1511] | compatible | 0 / 0, 1 | 0,0516 [0,0314 ; 0,0795] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | CUSUM | V1 | 368 | oui | 0,0978 [0,0695 ; 0,1329] | compatible | — | 0,0435 [0,0251 ; 0,0696] | compatible | — |
| J3 | δ̂* = 1 | CUSUM | V3a | 368 | oui | 0,1033 [0,0741 ; 0,1390] | compatible | 2 / 0, 1 | 0,0489 [0,0292 ; 0,0762] | compatible | 2 / 0, 1 |
| J3 | δ̂* = 1 | CUSUM | V3b | 368 | oui | 0,1060 [0,0765 ; 0,1420] | compatible | 3 / 0, 1 | 0,0516 [0,0314 ; 0,0795] | compatible | 3 / 0, 1 |
| J3 | δ̂* = 1 | CUSUM | V3h | 368 | oui | 0,0978 [0,0695 ; 0,1329] | compatible | 0 / 0, 1 | 0,0435 [0,0251 ; 0,0696] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | Grubbs | V1 | 368 | oui | 0,1250 [0,0930 ; 0,1632] | compatible | — | 0,0679 [0,0444 ; 0,0987] | compatible | — |
| J3 | δ̂* = 1 | Grubbs | V3a | 368 | oui | 0,0761 [0,0512 ; 0,1081] | compatible | 0 / 18, 0,000168 | 0,0272 [0,0131 ; 0,0494] | écart mineur | 0 / 15, 0,00134 |
| J3 | δ̂* = 1 | Grubbs | V3b | 368 | oui | 0,0761 [0,0512 ; 0,1081] | compatible | 0 / 18, 0,000153 | 0,0326 [0,0170 ; 0,0563] | compatible | 0 / 13, 0,00513 |
| J3 | δ̂* = 1 | Grubbs | V3h | 368 | oui | 0,1250 [0,0930 ; 0,1632] | compatible | 0 / 0, 1 | 0,0679 [0,0444 ; 0,0987] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | Lillie | V1 | 368 | oui | 0,0870 [0,0602 ; 0,1205] | compatible | — | 0,0380 [0,0210 ; 0,0630] | compatible | — |
| J3 | δ̂* = 1 | Lillie | V3a | 368 | oui | 0,0625 [0,0400 ; 0,0923] | écart mineur | 0 / 9, 0,043 | 0,0326 [0,0170 ; 0,0563] | compatible | 0 / 2, 1 |
| J3 | δ̂* = 1 | Lillie | V3b | 368 | oui | 0,0625 [0,0400 ; 0,0923] | écart mineur | 0 / 9, 0,0391 | 0,0299 [0,0150 ; 0,0529] | compatible | 0 / 3, 1 |
| J3 | δ̂* = 1 | Lillie | V3h | 368 | oui | 0,0870 [0,0602 ; 0,1205] | compatible | 0 / 0, 1 | 0,0380 [0,0210 ; 0,0630] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | Intercept | V1 | 368 | oui | 0,1929 [0,1539 ; 0,2370] **libéral** | distorsion matérielle | — | 0,0870 [0,0602 ; 0,1205] | écart non tranché | — |
| J3 | δ̂* = 1 | Intercept | V3a | 368 | oui | 0,1929 [0,1539 ; 0,2370] **libéral** | distorsion matérielle | 4 / 4, 1 | 0,0842 [0,0580 ; 0,1174] | écart non tranché | 4 / 5, 1 |
| J3 | δ̂* = 1 | Intercept | V3b | 368 | oui | 0,1929 [0,1539 ; 0,2370] **libéral** | distorsion matérielle | 5 / 5, 1 | 0,0870 [0,0602 ; 0,1205] | écart non tranché | 4 / 4, 1 |
| J3 | δ̂* = 1 | Intercept | V3h | 368 | oui | 0,1929 [0,1539 ; 0,2370] **libéral** | distorsion matérielle | 0 / 0, 1 | 0,0870 [0,0602 ; 0,1205] | écart non tranché | 0 / 0, 1 |
| J3 | δ̂* = 1 | RESET | V1 | 368 | oui | 0,0842 [0,0580 ; 0,1174] | compatible | — | 0,0408 [0,0230 ; 0,0663] | compatible | — |
| J3 | δ̂* = 1 | RESET | V3a | 368 | oui | 0,0815 [0,0557 ; 0,1143] | compatible | 1 / 2, 1 | 0,0299 [0,0150 ; 0,0529] | compatible | 0 / 4, 1 |
| J3 | δ̂* = 1 | RESET | V3b | 368 | oui | 0,0842 [0,0580 ; 0,1174] | compatible | 2 / 2, 1 | 0,0326 [0,0170 ; 0,0563] | compatible | 0 / 3, 1 |
| J3 | δ̂* = 1 | RESET | V3h | 368 | oui | 0,0842 [0,0580 ; 0,1174] | compatible | 0 / 0, 1 | 0,0408 [0,0230 ; 0,0663] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | BP | V1 | 368 | oui | 0,1033 [0,0741 ; 0,1390] | compatible | — | 0,0516 [0,0314 ; 0,0795] | compatible | — |
| J3 | δ̂* = 1 | BP | V3a | 368 | oui | 0,0543 [0,0335 ; 0,0827] | écart mineur | 0 / 18, 0,000168 | 0,0272 [0,0131 ; 0,0494] | écart mineur | 0 / 9, 0,0664 |
| J3 | δ̂* = 1 | BP | V3b | 368 | oui | 0,0516 [0,0314 ; 0,0795] | écart mineur | 0 / 19, 8,39e-05 | 0,0272 [0,0131 ; 0,0494] | écart mineur | 0 / 9, 0,0664 |
| J3 | δ̂* = 1 | BP | V3h | 368 | oui | 0,1033 [0,0741 ; 0,1390] | compatible | 0 / 0, 1 | 0,0516 [0,0314 ; 0,0795] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | BP79 | V1 | 368 | oui | 0,1087 [0,0788 ; 0,1451] | compatible | — | 0,0543 [0,0335 ; 0,0827] | compatible | — |
| J3 | δ̂* = 1 | BP79 | V3a | 368 | oui | 0,0598 [0,0378 ; 0,0891] | écart mineur | 0 / 18, 0,000168 | 0,0272 [0,0131 ; 0,0494] | écart mineur | 0 / 10, 0,0352 |
| J3 | δ̂* = 1 | BP79 | V3b | 368 | oui | 0,0571 [0,0357 ; 0,0859] | écart mineur | 0 / 19, 8,39e-05 | 0,0217 [0,0094 ; 0,0424] | écart non tranché | 0 / 12, 0,00977 |
| J3 | δ̂* = 1 | BP79 | V3h | 368 | oui | 0,1087 [0,0788 ; 0,1451] | compatible | 0 / 0, 1 | 0,0543 [0,0335 ; 0,0827] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | White | V1 | 368 | oui | 0,1087 [0,0788 ; 0,1451] | compatible | — | 0,0598 [0,0378 ; 0,0891] | compatible | — |
| J3 | δ̂* = 1 | White | V3a | 368 | oui | 0,0625 [0,0400 ; 0,0923] | écart mineur | 0 / 17, 0,00029 | 0,0217 [0,0094 ; 0,0424] | écart non tranché | 0 / 14, 0,00256 |
| J3 | δ̂* = 1 | White | V3b | 368 | oui | 0,0625 [0,0400 ; 0,0923] | écart mineur | 0 / 17, 0,00029 | 0,0163 [0,0060 ; 0,0351] | écart non tranché | 0 / 16, 0,000671 |
| J3 | δ̂* = 1 | White | V3h | 368 | oui | 0,1087 [0,0788 ; 0,1451] | compatible | 0 / 0, 1 | 0,0598 [0,0378 ; 0,0891] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | GQ | V1 | 368 | oui | 0,0571 [0,0357 ; 0,0859] | écart mineur | — | 0,0272 [0,0131 ; 0,0494] | écart mineur | — |
| J3 | δ̂* = 1 | GQ | V3a | 368 | oui | 0,1005 [0,0718 ; 0,1359] | compatible | 27 / 11, 0,208 | 0,0408 [0,0230 ; 0,0663] | compatible | 11 / 6, 1 |
| J3 | δ̂* = 1 | GQ | V3b | 368 | oui | 0,1005 [0,0718 ; 0,1359] | compatible | 28 / 12, 0,249 | 0,0380 [0,0210 ; 0,0630] | compatible | 10 / 6, 1 |
| J3 | δ̂* = 1 | GQ | V3h | 368 | oui | 0,0571 [0,0357 ; 0,0859] | écart mineur | 0 / 0, 1 | 0,0272 [0,0131 ; 0,0494] | écart mineur | 0 / 0, 1 |
| J3 | δ̂* = 1 | BF | V1 | 368 | oui | 0,1033 [0,0741 ; 0,1390] | compatible | — | 0,0489 [0,0292 ; 0,0762] | compatible | — |
| J3 | δ̂* = 1 | BF | V3a | 368 | oui | 0,0598 [0,0378 ; 0,0891] | écart mineur | 0 / 16, 0,000549 | 0,0380 [0,0210 ; 0,0630] | compatible | 0 / 4, 1 |
| J3 | δ̂* = 1 | BF | V3b | 368 | oui | 0,0571 [0,0357 ; 0,0859] | écart mineur | 0 / 17, 0,00029 | 0,0380 [0,0210 ; 0,0630] | compatible | 0 / 4, 1 |
| J3 | δ̂* = 1 | BF | V3h | 368 | oui | 0,1033 [0,0741 ; 0,1390] | compatible | 0 / 0, 1 | 0,0489 [0,0292 ; 0,0762] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | Smirnov | V1 | 368 | oui | 0,0435 [0,0251 ; 0,0696] | compatible | — | 0,0435 [0,0251 ; 0,0696] | compatible | — |
| J3 | δ̂* = 1 | Smirnov | V3a | 368 | oui | 0,0435 [0,0251 ; 0,0696] | compatible | 0 / 0, 1 | 0,0435 [0,0251 ; 0,0696] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | Smirnov | V3b | 368 | oui | 0,0435 [0,0251 ; 0,0696] | compatible | 0 / 0, 1 | 0,0435 [0,0251 ; 0,0696] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | Smirnov | V3h | 368 | oui | 0,0435 [0,0251 ; 0,0696] | compatible | 0 / 0, 1 | 0,0435 [0,0251 ; 0,0696] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | LB2 | V1 | 368 | oui | 0,0734 [0,0489 ; 0,1050] | compatible | — | 0,0245 [0,0112 ; 0,0459] | écart non tranché | — |
| J3 | δ̂* = 1 | LB2 | V3a | 368 | oui | 0,0788 [0,0534 ; 0,1112] | compatible | 2 / 0, 1 | 0,0326 [0,0170 ; 0,0563] | compatible | 3 / 0, 1 |
| J3 | δ̂* = 1 | LB2 | V3b | 368 | oui | 0,0842 [0,0580 ; 0,1174] | compatible | 4 / 0, 1 | 0,0299 [0,0150 ; 0,0529] | compatible | 3 / 1, 1 |
| J3 | δ̂* = 1 | LB2 | V3h | 368 | oui | 0,0734 [0,0489 ; 0,1050] | compatible | 0 / 0, 1 | 0,0245 [0,0112 ; 0,0459] | écart non tranché | 0 / 0, 1 |
| J3 | δ̂* = 1 | BP2 | V1 | 368 | oui | 0,0707 [0,0467 ; 0,1018] | compatible | — | 0,0245 [0,0112 ; 0,0459] | écart non tranché | — |
| J3 | δ̂* = 1 | BP2 | V3a | 368 | oui | 0,0761 [0,0512 ; 0,1081] | compatible | 2 / 0, 1 | 0,0245 [0,0112 ; 0,0459] | écart non tranché | 0 / 0, 1 |
| J3 | δ̂* = 1 | BP2 | V3b | 368 | oui | 0,0761 [0,0512 ; 0,1081] | compatible | 2 / 0, 1 | 0,0272 [0,0131 ; 0,0494] | écart mineur | 1 / 0, 1 |
| J3 | δ̂* = 1 | BP2 | V3h | 368 | oui | 0,0707 [0,0467 ; 0,1018] | compatible | 0 / 0, 1 | 0,0245 [0,0112 ; 0,0459] | écart non tranché | 0 / 0, 1 |
| J3 | δ̂* = 1 | Runs | V1 | 368 | oui | 0,0408 [0,0230 ; 0,0663] | compatible | — | 0,0054 [0,0007 ; 0,0195] | compatible | — |
| J3 | δ̂* = 1 | Runs | V3a | 368 | oui | 0,0408 [0,0230 ; 0,0663] | compatible | 0 / 0, 1 | 0,0136 [0,0044 ; 0,0314] | compatible | 3 / 0, 1 |
| J3 | δ̂* = 1 | Runs | V3b | 368 | oui | 0,0408 [0,0230 ; 0,0663] | compatible | 0 / 0, 1 | 0,0136 [0,0044 ; 0,0314] | compatible | 4 / 1, 1 |
| J3 | δ̂* = 1 | Runs | V3h | 368 | oui | 0,0408 [0,0230 ; 0,0663] | compatible | 0 / 0, 1 | 0,0054 [0,0007 ; 0,0195] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | MK | V1 | 368 | oui | 0,0761 [0,0512 ; 0,1081] | compatible | — | 0,0380 [0,0210 ; 0,0630] | compatible | — |
| J3 | δ̂* = 1 | MK | V3a | 368 | oui | 0,0761 [0,0512 ; 0,1081] | compatible | 1 / 1, 1 | 0,0408 [0,0230 ; 0,0663] | compatible | 2 / 1, 1 |
| J3 | δ̂* = 1 | MK | V3b | 368 | oui | 0,0788 [0,0534 ; 0,1112] | compatible | 3 / 2, 1 | 0,0435 [0,0251 ; 0,0696] | compatible | 3 / 1, 1 |
| J3 | δ̂* = 1 | MK | V3h | 368 | oui | 0,0761 [0,0512 ; 0,1081] | compatible | 0 / 0, 1 | 0,0380 [0,0210 ; 0,0630] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | SpearVol | V1 | 368 | oui | 0,1277 [0,0954 ; 0,1662] | écart mineur | — | 0,0707 [0,0467 ; 0,1018] | écart non tranché | — |
| J3 | δ̂* = 1 | SpearVol | V3a | 368 | oui | 0,1359 [0,1026 ; 0,1752] | écart non tranché | 5 / 2, 1 | 0,0897 [0,0625 ; 0,1236] | écart non tranché | 8 / 1, 0,625 |
| J3 | δ̂* = 1 | SpearVol | V3b | 368 | oui | 0,1413 [0,1074 ; 0,1811] | écart non tranché | 7 / 2, 1 | 0,0842 [0,0580 ; 0,1174] | écart non tranché | 7 / 2, 1 |
| J3 | δ̂* = 1 | SpearVol | V3h | 368 | oui | 0,1277 [0,0954 ; 0,1662] | écart mineur | 0 / 0, 1 | 0,0707 [0,0467 ; 0,1018] | écart non tranché | 0 / 0, 1 |
| J3 | δ̂* = 1 | SpearTps | V1 | 368 | oui | 0,0951 [0,0671 ; 0,1298] | compatible | — | 0,0435 [0,0251 ; 0,0696] | compatible | — |
| J3 | δ̂* = 1 | SpearTps | V3a | 368 | oui | 0,0978 [0,0695 ; 0,1329] | compatible | 2 / 1, 1 | 0,0516 [0,0314 ; 0,0795] | compatible | 3 / 0, 1 |
| J3 | δ̂* = 1 | SpearTps | V3b | 368 | oui | 0,1005 [0,0718 ; 0,1359] | compatible | 2 / 0, 1 | 0,0435 [0,0251 ; 0,0696] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | SpearTps | V3h | 368 | oui | 0,0951 [0,0671 ; 0,1298] | compatible | 0 / 0, 1 | 0,0435 [0,0251 ; 0,0696] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | DAgo | V1 | 368 | oui | 0,1060 [0,0765 ; 0,1420] | compatible | — | 0,0625 [0,0400 ; 0,0923] | compatible | — |
| J3 | δ̂* = 1 | DAgo | V3a | 368 | oui | 0,0679 [0,0444 ; 0,0987] | écart mineur | 0 / 14, 0,00208 | 0,0326 [0,0170 ; 0,0563] | compatible | 0 / 11, 0,0195 |
| J3 | δ̂* = 1 | DAgo | V3b | 368 | oui | 0,0707 [0,0467 ; 0,1018] | compatible | 0 / 13, 0,00415 | 0,0353 [0,0189 ; 0,0597] | compatible | 0 / 10, 0,0352 |
| J3 | δ̂* = 1 | DAgo | V3h | 368 | oui | 0,1060 [0,0765 ; 0,1420] | compatible | 0 / 0, 1 | 0,0625 [0,0400 ; 0,0923] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | CoxStuart | V1 | 368 | oui | 0,0000 [0,0000 ; 0,0100] | compatible | — | 0,0000 [0,0000 ; 0,0100] | compatible | — |
| J3 | δ̂* = 1 | CoxStuart | V3a | 368 | oui | 0,0082 [0,0017 ; 0,0236] | écart à examiner (bande non applicable) | 3 / 0, 1 | 0,0000 [0,0000 ; 0,0100] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | CoxStuart | V3b | 368 | oui | 0,0000 [0,0000 ; 0,0100] | compatible | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0100] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | CoxStuart | V3h | 368 | oui | 0,0000 [0,0000 ; 0,0100] | compatible | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0100] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | DWr | V1 | 368 | oui | 0,0734 [0,0489 ; 0,1050] | compatible | — | 0,0408 [0,0230 ; 0,0663] | compatible | — |
| J3 | δ̂* = 1 | DWr | V3a | 368 | oui | 0,0815 [0,0557 ; 0,1143] | compatible | 3 / 0, 1 | 0,0408 [0,0230 ; 0,0663] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | DWr | V3b | 368 | oui | 0,0842 [0,0580 ; 0,1174] | compatible | 4 / 0, 1 | 0,0435 [0,0251 ; 0,0696] | compatible | 1 / 0, 1 |
| J3 | δ̂* = 1 | DWr | V3h | 368 | oui | 0,0734 [0,0489 ; 0,1050] | compatible | 0 / 0, 1 | 0,0408 [0,0230 ; 0,0663] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | LB1r | V1 | 368 | oui | 0,0707 [0,0467 ; 0,1018] | compatible | — | 0,0326 [0,0170 ; 0,0563] | compatible | — |
| J3 | δ̂* = 1 | LB1r | V3a | 368 | oui | 0,0652 [0,0422 ; 0,0955] | écart mineur | 1 / 3, 1 | 0,0299 [0,0150 ; 0,0529] | compatible | 1 / 2, 1 |
| J3 | δ̂* = 1 | LB1r | V3b | 368 | oui | 0,0707 [0,0467 ; 0,1018] | compatible | 1 / 1, 1 | 0,0245 [0,0112 ; 0,0459] | écart non tranché | 1 / 4, 1 |
| J3 | δ̂* = 1 | LB1r | V3h | 368 | oui | 0,0707 [0,0467 ; 0,1018] | compatible | 0 / 0, 1 | 0,0326 [0,0170 ; 0,0563] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | Runsr | V1 | 368 | oui | 0,0408 [0,0230 ; 0,0663] | compatible | — | 0,0109 [0,0030 ; 0,0276] | compatible | — |
| J3 | δ̂* = 1 | Runsr | V3a | 368 | oui | 0,0408 [0,0230 ; 0,0663] | compatible | 0 / 0, 1 | 0,0136 [0,0044 ; 0,0314] | compatible | 1 / 0, 1 |
| J3 | δ̂* = 1 | Runsr | V3b | 368 | oui | 0,0408 [0,0230 ; 0,0663] | compatible | 0 / 0, 1 | 0,0136 [0,0044 ; 0,0314] | compatible | 2 / 1, 1 |
| J3 | δ̂* = 1 | Runsr | V3h | 368 | oui | 0,0408 [0,0230 ; 0,0663] | compatible | 0 / 0, 1 | 0,0109 [0,0030 ; 0,0276] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | supFr | V1 | 368 | oui | 0,0951 [0,0671 ; 0,1298] | compatible | — | 0,0489 [0,0292 ; 0,0762] | compatible | — |
| J3 | δ̂* = 1 | supFr | V3a | 368 | oui | 0,0978 [0,0695 ; 0,1329] | compatible | 2 / 1, 1 | 0,0462 [0,0271 ; 0,0729] | compatible | 0 / 1, 1 |
| J3 | δ̂* = 1 | supFr | V3b | 368 | oui | 0,0924 [0,0648 ; 0,1267] | compatible | 0 / 1, 1 | 0,0435 [0,0251 ; 0,0696] | compatible | 0 / 2, 1 |
| J3 | δ̂* = 1 | supFr | V3h | 368 | oui | 0,0951 [0,0671 ; 0,1298] | compatible | 0 / 0, 1 | 0,0489 [0,0292 ; 0,0762] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | CUSUMr | V1 | 368 | oui | 0,1060 [0,0765 ; 0,1420] | compatible | — | 0,0462 [0,0271 ; 0,0729] | compatible | — |
| J3 | δ̂* = 1 | CUSUMr | V3a | 368 | oui | 0,1033 [0,0741 ; 0,1390] | compatible | 2 / 3, 1 | 0,0462 [0,0271 ; 0,0729] | compatible | 1 / 1, 1 |
| J3 | δ̂* = 1 | CUSUMr | V3b | 368 | oui | 0,1060 [0,0765 ; 0,1420] | compatible | 1 / 1, 1 | 0,0543 [0,0335 ; 0,0827] | compatible | 3 / 0, 1 |
| J3 | δ̂* = 1 | CUSUMr | V3h | 368 | oui | 0,1060 [0,0765 ; 0,1420] | compatible | 0 / 0, 1 | 0,0462 [0,0271 ; 0,0729] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | Grubbsr | V1 | 368 | oui | 0,0815 [0,0557 ; 0,1143] | compatible | — | 0,0380 [0,0210 ; 0,0630] | compatible | — |
| J3 | δ̂* = 1 | Grubbsr | V3a | 368 | oui | 0,0815 [0,0557 ; 0,1143] | compatible | 1 / 1, 1 | 0,0380 [0,0210 ; 0,0630] | compatible | 0 / 0, 1 |
| J3 | δ̂* = 1 | Grubbsr | V3b | 368 | oui | 0,0788 [0,0534 ; 0,1112] | compatible | 0 / 1, 1 | 0,0408 [0,0230 ; 0,0663] | compatible | 1 / 0, 1 |
| J3 | δ̂* = 1 | Grubbsr | V3h | 368 | oui | 0,0815 [0,0557 ; 0,1143] | compatible | 0 / 0, 1 | 0,0380 [0,0210 ; 0,0630] | compatible | 0 / 0, 1 |

### T2 -- verdicts des lignes de usp_tests() (sans critère ; population du critère)

Par ligne et par variante : fréquence de ALERTE ou ECHEC, fréquence de ECHEC, sur les réplications où la ligne est écrite ; replis asymptotiques (règle R3 : p retenue de nature asymptotique alors que celle de V1 est Monte-Carlo) comptés à part. Lignes du jackknife et de la largeur de l'IC bootstrap 90 % absentes de ce chemin (diagnostics sans p retenue, verdict indépendant de la variante).

| Jeu | Ligne | n | V1 A ou E / E | V3a A ou E / E | V3b A ou E / E | V3h A ou E / E | replis R3 (V3a ; V3b ; V3h) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| J1 (bords) | Nullite de la constante (proportionnalite stricte) | 1925 | 0,1096 / 0,0582 | 0,1096 / 0,0551 | 0,1091 / 0,0545 | 0,1096 / 0,0582 | 0 ; 0 ; 0 |
| J1 (bords) | Equivalence de la constante a zero (TOST) | 1925 | 1,0000 / 1,0000 | 1,0000 / 1,0000 | 1,0000 / 1,0000 | 1,0000 / 1,0000 | 0 ; 0 ; 0 |
| J1 (bords) | Test de Pitman sur la pente (lien positif pertes / volume) | 1925 | 0,3382 / 0,0930 | 0,3382 / 0,0930 | 0,3382 / 0,0930 | 0,3382 / 0,0930 | 0 ; 0 ; 0 |
| J1 (bords) | Test de Fisher (significativite globale) | 1925 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J1 (bords) | Coefficient de determination R2 | 1925 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J1 (bords) | RESET (forme fonctionnelle) | 1925 | 0,1132 / 0,0577 | 0,1164 / 0,0566 | 0,1153 / 0,0582 | 0,1132 / 0,0577 | 0 ; 0 ; 0 |
| J1 (bords) | Independance ratio S/P vs volume | 1925 | 0,0945 / 0,0540 | 0,0935 / 0,0519 | 0,0945 / 0,0509 | 0,0945 / 0,0540 | 0 ; 0 ; 0 |
| J1 (bords) | Correlation ratio S/P vs temps | 1925 | 0,0951 / 0,0494 | 0,0951 / 0,0478 | 0,0935 / 0,0483 | 0,0951 / 0,0494 | 0 ; 0 ; 0 |
| J1 (bords) | Tendance monotone du ratio S/P | 1925 | 0,0696 / 0,0379 | 0,0727 / 0,0390 | 0,0732 / 0,0374 | 0,0696 / 0,0379 | 0 ; 0 ; 0 |
| J1 (bords) | Tendance par signes du ratio S/P | 1925 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J1 (bords) | Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | 1925 | 0,0992 / 0,0494 | 0,0894 / 0,0410 | 0,0894 / 0,0431 | 0,0992 / 0,0494 | 0 ; 0 ; 0 |
| J1 (bords) | Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | 1925 | 0,0956 / 0,0488 | 0,0795 / 0,0400 | 0,0805 / 0,0400 | 0,0956 / 0,0488 | 0 ; 0 ; 0 |
| J1 (bords) | Heteroscedasticite (forme quadratique) | 1925 | 0,1044 / 0,0483 | 0,0966 / 0,0452 | 0,0935 / 0,0462 | 0,1044 / 0,0483 | 0 ; 0 ; 0 |
| J1 (bords) | Egalite des variances petits vs gros volumes | 1925 | 0,0904 / 0,0364 | 0,0883 / 0,0416 | 0,0883 / 0,0374 | 0,0904 / 0,0364 | 0 ; 0 ; 0 |
| J1 (bords) | Homogeneite des dispersions (mediane) | 1925 | 0,1003 / 0,0514 | 0,0930 / 0,0478 | 0,0945 / 0,0473 | 0,1003 / 0,0514 | 0 ; 0 ; 0 |
| J1 (bords) | Egalite des lois petits vs gros volumes (2 ech.) | 1925 | 0,0327 / 0,0327 | 0,0327 / 0,0322 | 0,0327 / 0,0327 | 0,0327 / 0,0327 | 0 ; 0 ; 0 |
| J1 (bords) | Position de delta dans [0,1] | 1925 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J1 (bords) | Shapiro-Wilk sur residus standardises | 1925 | 0,0935 / 0,0452 | 0,0925 / 0,0468 | 0,0888 / 0,0462 | 0,0935 / 0,0452 | 0 ; 0 ; 0 |
| J1 (bords) | Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston) | 1925 | 0,0488 / 0,0223 | 0,0488 / 0,0223 | 0,0488 / 0,0223 | 0,0488 / 0,0223 | 0 ; 0 ; 0 |
| J1 (bords) | Shapiro-Francia | 1925 | 0,0914 / 0,0483 | 0,0888 / 0,0468 | 0,0888 / 0,0442 | 0,0914 / 0,0483 | 0 ; 0 ; 0 |
| J1 (bords) | Anderson-Darling | 1925 | 0,0945 / 0,0457 | 0,0919 / 0,0488 | 0,0904 / 0,0473 | 0,0945 / 0,0457 | 0 ; 0 ; 0 |
| J1 (bords) | Cramer-von Mises | 1925 | 0,0971 / 0,0457 | 0,0940 / 0,0468 | 0,0956 / 0,0452 | 0,0971 / 0,0457 | 0 ; 0 ; 0 |
| J1 (bords) | Kolmogorov-Smirnov contre N(0,1) | 1925 | 0,0852 / 0,0468 | 0,0857 / 0,0452 | 0,0868 / 0,0473 | 0,0852 / 0,0468 | 0 ; 0 ; 0 |
| J1 (bords) | Lilliefors (KS a parametres estimes) | 1925 | 0,0883 / 0,0494 | 0,0873 / 0,0462 | 0,0888 / 0,0468 | 0,0883 / 0,0494 | 0 ; 0 ; 0 |
| J1 (bords) | Jarque-Bera | 1925 | 0,0935 / 0,0483 | 0,0919 / 0,0478 | 0,0883 / 0,0457 | 0,0935 / 0,0483 | 0 ; 0 ; 0 |
| J1 (bords) | Asymetrie (D'Agostino, T >= 8) | 1925 | 0,0930 / 0,0452 | 0,0899 / 0,0426 | 0,0878 / 0,0442 | 0,0930 / 0,0452 | 0 ; 0 ; 0 |
| J1 (bords) | Aplatissement (Anscombe-Glynn, T >= 20) | 1925 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J1 (bords) | Autocorrelation d'ordre 1 (Durbin-Watson) | 1925 | 0,1127 / 0,0488 | 0,1117 / 0,0504 | 0,1112 / 0,0478 | 0,1127 / 0,0488 | 0 ; 0 ; 0 |
| J1 (bords) | Ljung-Box (retard 1) | 1925 | 0,1070 / 0,0519 | 0,1044 / 0,0525 | 0,1065 / 0,0519 | 0,1070 / 0,0519 | 0 ; 0 ; 0 |
| J1 (bords) | Ljung-Box (retard 2) | 1925 | 0,1023 / 0,0483 | 0,1013 / 0,0488 | 0,1034 / 0,0462 | 0,1023 / 0,0483 | 0 ; 0 ; 0 |
| J1 (bords) | Box-Pierce (retard 2) | 1925 | 0,1013 / 0,0504 | 0,0992 / 0,0519 | 0,0992 / 0,0504 | 0,1013 / 0,0504 | 0 ; 0 ; 0 |
| J1 (bords) | Test des suites (aleatoire des signes) | 1925 | 0,0639 / 0,0036 | 0,0634 / 0,0068 | 0,0639 / 0,0042 | 0,0639 / 0,0036 | 0 ; 0 ; 0 |
| J1 (bords) | Centrage des residus standardises | 1925 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J1 (bords) | Variance unitaire des residus standardises | 1925 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J1 (bords) | Rupture de niveau (sup-F) | 1925 | 0,1081 / 0,0514 | 0,1003 / 0,0509 | 0,1034 / 0,0494 | 0,1081 / 0,0514 | 0 ; 0 ; 0 |
| J1 (bords) | Stabilite cumulee (OLS-CUSUM) | 1925 | 0,1075 / 0,0504 | 0,1044 / 0,0478 | 0,1044 / 0,0504 | 0,1075 / 0,0504 | 0 ; 0 ; 0 |
| J1 (bords) | Valeur aberrante isolee (Grubbs) | 1925 | 0,1034 / 0,0488 | 0,0997 / 0,0468 | 0,0961 / 0,0436 | 0,1034 / 0,0488 | 0 ; 0 ; 0 |
| J1 (bords) | Valeurs aberrantes multiples (ESD generalise) | 1925 | 0,1434 / 0,0540 | 0,1434 / 0,0540 | 0,1434 / 0,0540 | 0,1434 / 0,0540 | 0 ; 0 ; 0 |
| J1 (bords) | Points influents (distance de Cook) | 1925 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J1 (bords) | Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | 1925 | 0,1106 / 0,0509 | 0,1081 / 0,0525 | 0,1086 / 0,0504 | 0,1106 / 0,0509 | 0 ; 0 ; 0 |
| J1 (bords) | Ljung-Box (retard 1) sur ratios bruts | 1925 | 0,1049 / 0,0514 | 0,1003 / 0,0525 | 0,1034 / 0,0514 | 0,1049 / 0,0514 | 0 ; 0 ; 0 |
| J1 (bords) | Test des suites sur ratios bruts | 1925 | 0,0634 / 0,0036 | 0,0629 / 0,0078 | 0,0634 / 0,0047 | 0,0634 / 0,0036 | 0 ; 0 ; 0 |
| J1 (bords) | Rupture de niveau (sup-F) sur ratios bruts | 1925 | 0,1039 / 0,0540 | 0,0982 / 0,0561 | 0,0997 / 0,0540 | 0,1039 / 0,0540 | 0 ; 0 ; 0 |
| J1 (bords) | Stabilite cumulee (OLS-CUSUM) sur ratios bruts | 1925 | 0,1081 / 0,0519 | 0,1086 / 0,0494 | 0,1070 / 0,0483 | 0,1081 / 0,0519 | 0 ; 0 ; 0 |
| J1 (bords) | Valeur aberrante isolee (Grubbs) sur ratios bruts | 1925 | 0,1044 / 0,0509 | 0,0997 / 0,0462 | 0,0982 / 0,0468 | 0,1044 / 0,0509 | 0 ; 0 ; 0 |
| J1 (bords) | Leviers (hat values) | 1925 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J2 | Nullite de la constante (proportionnalite stricte) | 2000 | 0,0975 / 0,0535 | 0,1035 / 0,0540 | 0,0995 / 0,0560 | 0,0950 / 0,0520 | 0 ; 0 ; 0 |
| J2 | Equivalence de la constante a zero (TOST) | 2000 | 0,5635 / 0,1535 | 0,5635 / 0,1535 | 0,5635 / 0,1535 | 0,5635 / 0,1535 | 0 ; 0 ; 0 |
| J2 | Test de Pitman sur la pente (lien positif pertes / volume) | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J2 | Test de Fisher (significativite globale) | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J2 | Coefficient de determination R2 | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J2 | RESET (forme fonctionnelle) | 2000 | 0,0830 / 0,0325 | 0,0855 / 0,0435 | 0,0865 / 0,0440 | 0,0755 / 0,0350 | 0 ; 0 ; 0 |
| J2 | Independance ratio S/P vs volume | 2000 | 0,1000 / 0,0495 | 0,0990 / 0,0465 | 0,1000 / 0,0505 | 0,1010 / 0,0505 | 0 ; 0 ; 0 |
| J2 | Correlation ratio S/P vs temps | 2000 | 0,0895 / 0,0390 | 0,0715 / 0,0295 | 0,0740 / 0,0315 | 0,0835 / 0,0405 | 0 ; 0 ; 0 |
| J2 | Tendance monotone du ratio S/P | 2000 | 0,0620 / 0,0290 | 0,0510 / 0,0220 | 0,0545 / 0,0240 | 0,0605 / 0,0295 | 0 ; 0 ; 0 |
| J2 | Tendance par signes du ratio S/P | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J2 | Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | 2000 | 0,0850 / 0,0370 | 0,0770 / 0,0365 | 0,0780 / 0,0380 | 0,1095 / 0,0490 | 0 ; 0 ; 0 |
| J2 | Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | 2000 | 0,0755 / 0,0365 | 0,0680 / 0,0345 | 0,0685 / 0,0355 | 0,0965 / 0,0485 | 0 ; 0 ; 0 |
| J2 | Heteroscedasticite (forme quadratique) | 2000 | 0,0880 / 0,0400 | 0,0825 / 0,0360 | 0,0810 / 0,0360 | 0,0890 / 0,0420 | 0 ; 0 ; 0 |
| J2 | Egalite des variances petits vs gros volumes | 2000 | 0,0545 / 0,0290 | 0,1020 / 0,0485 | 0,1000 / 0,0495 | 0,0790 / 0,0405 | 0 ; 0 ; 0 |
| J2 | Homogeneite des dispersions (mediane) | 2000 | 0,0860 / 0,0455 | 0,0865 / 0,0445 | 0,0875 / 0,0455 | 0,1095 / 0,0565 | 0 ; 0 ; 0 |
| J2 | Egalite des lois petits vs gros volumes (2 ech.) | 2000 | 0,0275 / 0,0275 | 0,0290 / 0,0275 | 0,0275 / 0,0275 | 0,0275 / 0,0275 | 0 ; 0 ; 0 |
| J2 | Position de delta dans [0,1] | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J2 | Shapiro-Wilk sur residus standardises | 2000 | 0,0945 / 0,0445 | 0,0925 / 0,0450 | 0,0915 / 0,0455 | 0,0960 / 0,0460 | 0 ; 0 ; 0 |
| J2 | Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston) | 2000 | 0,0330 / 0,0150 | 0,0330 / 0,0150 | 0,0330 / 0,0150 | 0,0330 / 0,0150 | 0 ; 0 ; 0 |
| J2 | Shapiro-Francia | 2000 | 0,0850 / 0,0460 | 0,0830 / 0,0405 | 0,0800 / 0,0405 | 0,0925 / 0,0490 | 0 ; 0 ; 0 |
| J2 | Anderson-Darling | 2000 | 0,1020 / 0,0450 | 0,1000 / 0,0435 | 0,1000 / 0,0420 | 0,1020 / 0,0450 | 0 ; 0 ; 0 |
| J2 | Cramer-von Mises | 2000 | 0,0970 / 0,0465 | 0,0985 / 0,0465 | 0,0955 / 0,0465 | 0,0935 / 0,0470 | 0 ; 0 ; 0 |
| J2 | Kolmogorov-Smirnov contre N(0,1) | 2000 | 0,0900 / 0,0460 | 0,0885 / 0,0425 | 0,0885 / 0,0440 | 0,0885 / 0,0455 | 0 ; 0 ; 0 |
| J2 | Lilliefors (KS a parametres estimes) | 2000 | 0,0880 / 0,0480 | 0,0875 / 0,0465 | 0,0860 / 0,0435 | 0,0920 / 0,0505 | 0 ; 0 ; 0 |
| J2 | Jarque-Bera | 2000 | 0,0850 / 0,0405 | 0,0855 / 0,0400 | 0,0845 / 0,0425 | 0,1020 / 0,0490 | 0 ; 0 ; 0 |
| J2 | Asymetrie (D'Agostino, T >= 8) | 2000 | 0,0815 / 0,0400 | 0,0810 / 0,0395 | 0,0810 / 0,0415 | 0,0985 / 0,0510 | 0 ; 0 ; 0 |
| J2 | Aplatissement (Anscombe-Glynn, T >= 20) | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J2 | Autocorrelation d'ordre 1 (Durbin-Watson) | 2000 | 0,1055 / 0,0490 | 0,1080 / 0,0535 | 0,1115 / 0,0540 | 0,1140 / 0,0545 | 0 ; 0 ; 0 |
| J2 | Ljung-Box (retard 1) | 2000 | 0,1090 / 0,0530 | 0,1130 / 0,0505 | 0,1110 / 0,0500 | 0,1135 / 0,0550 | 0 ; 0 ; 0 |
| J2 | Ljung-Box (retard 2) | 2000 | 0,1065 / 0,0530 | 0,1005 / 0,0545 | 0,0980 / 0,0540 | 0,1010 / 0,0505 | 0 ; 0 ; 0 |
| J2 | Box-Pierce (retard 2) | 2000 | 0,1040 / 0,0530 | 0,1025 / 0,0550 | 0,1015 / 0,0560 | 0,1025 / 0,0510 | 0 ; 0 ; 0 |
| J2 | Test des suites (aleatoire des signes) | 2000 | 0,0635 / 0,0055 | 0,0610 / 0,0100 | 0,0635 / 0,0070 | 0,0635 / 0,0045 | 0 ; 0 ; 0 |
| J2 | Centrage des residus standardises | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J2 | Variance unitaire des residus standardises | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J2 | Rupture de niveau (sup-F) | 2000 | 0,0935 / 0,0515 | 0,0920 / 0,0555 | 0,0905 / 0,0555 | 0,0950 / 0,0530 | 0 ; 0 ; 0 |
| J2 | Stabilite cumulee (OLS-CUSUM) | 2000 | 0,0990 / 0,0480 | 0,0990 / 0,0475 | 0,0995 / 0,0510 | 0,0990 / 0,0470 | 0 ; 0 ; 0 |
| J2 | Valeur aberrante isolee (Grubbs) | 2000 | 0,0835 / 0,0415 | 0,0835 / 0,0400 | 0,0845 / 0,0430 | 0,1000 / 0,0515 | 0 ; 0 ; 0 |
| J2 | Valeurs aberrantes multiples (ESD generalise) | 2000 | 0,1110 / 0,0495 | 0,1110 / 0,0495 | 0,1110 / 0,0495 | 0,1110 / 0,0495 | 0 ; 0 ; 0 |
| J2 | Points influents (distance de Cook) | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J2 | Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | 2000 | 0,0920 / 0,0455 | 0,0965 / 0,0560 | 0,1010 / 0,0575 | 0,1000 / 0,0515 | 0 ; 0 ; 0 |
| J2 | Ljung-Box (retard 1) sur ratios bruts | 2000 | 0,1035 / 0,0525 | 0,1105 / 0,0480 | 0,1105 / 0,0505 | 0,1130 / 0,0545 | 0 ; 0 ; 0 |
| J2 | Test des suites sur ratios bruts | 2000 | 0,0610 / 0,0080 | 0,0585 / 0,0100 | 0,0610 / 0,0080 | 0,0610 / 0,0065 | 0 ; 0 ; 0 |
| J2 | Rupture de niveau (sup-F) sur ratios bruts | 2000 | 0,1010 / 0,0490 | 0,1020 / 0,0510 | 0,1040 / 0,0535 | 0,1045 / 0,0510 | 0 ; 0 ; 0 |
| J2 | Stabilite cumulee (OLS-CUSUM) sur ratios bruts | 2000 | 0,0995 / 0,0505 | 0,1020 / 0,0500 | 0,0995 / 0,0505 | 0,0990 / 0,0475 | 0 ; 0 ; 0 |
| J2 | Valeur aberrante isolee (Grubbs) sur ratios bruts | 2000 | 0,0845 / 0,0390 | 0,0870 / 0,0390 | 0,0845 / 0,0410 | 0,0985 / 0,0485 | 0 ; 0 ; 0 |
| J2 | Leviers (hat values) | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J3 | Nullite de la constante (proportionnalite stricte) | 2000 | 0,0915 / 0,0435 | 0,1110 / 0,0520 | 0,1115 / 0,0515 | 0,1180 / 0,0590 | 0 ; 0 ; 0 |
| J3 | Equivalence de la constante a zero (TOST) | 2000 | 0,0850 / 0,0105 | 0,0850 / 0,0105 | 0,0850 / 0,0105 | 0,0850 / 0,0105 | 0 ; 0 ; 0 |
| J3 | Test de Pitman sur la pente (lien positif pertes / volume) | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J3 | Test de Fisher (significativite globale) | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J3 | Coefficient de determination R2 | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J3 | RESET (forme fonctionnelle) | 2000 | 0,1130 / 0,0575 | 0,1080 / 0,0570 | 0,1115 / 0,0570 | 0,1055 / 0,0510 | 0 ; 0 ; 0 |
| J3 | Independance ratio S/P vs volume | 2000 | 0,0815 / 0,0370 | 0,0920 / 0,0435 | 0,0890 / 0,0430 | 0,0925 / 0,0460 | 0 ; 0 ; 0 |
| J3 | Correlation ratio S/P vs temps | 2000 | 0,1015 / 0,0515 | 0,1000 / 0,0505 | 0,1015 / 0,0515 | 0,1010 / 0,0510 | 0 ; 0 ; 0 |
| J3 | Tendance monotone du ratio S/P | 2000 | 0,0790 / 0,0400 | 0,0785 / 0,0420 | 0,0800 / 0,0405 | 0,0800 / 0,0400 | 0 ; 0 ; 0 |
| J3 | Tendance par signes du ratio S/P | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J3 | Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) | 2000 | 0,0450 / 0,0255 | 0,0960 / 0,0505 | 0,0940 / 0,0505 | 0,1125 / 0,0600 | 0 ; 0 ; 0 |
| J3 | Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) | 2000 | 0,0455 / 0,0195 | 0,0895 / 0,0420 | 0,0875 / 0,0435 | 0,1115 / 0,0540 | 0 ; 0 ; 0 |
| J3 | Heteroscedasticite (forme quadratique) | 2000 | 0,0855 / 0,0410 | 0,1005 / 0,0475 | 0,1005 / 0,0460 | 0,1105 / 0,0525 | 0 ; 0 ; 0 |
| J3 | Egalite des variances petits vs gros volumes | 2000 | 0,0250 / 0,0100 | 0,1135 / 0,0440 | 0,1125 / 0,0440 | 0,0900 / 0,0375 | 0 ; 0 ; 0 |
| J3 | Homogeneite des dispersions (mediane) | 2000 | 0,0595 / 0,0260 | 0,0855 / 0,0420 | 0,0845 / 0,0415 | 0,1035 / 0,0480 | 0 ; 0 ; 0 |
| J3 | Egalite des lois petits vs gros volumes (2 ech.) | 2000 | 0,0200 / 0,0200 | 0,0310 / 0,0200 | 0,0265 / 0,0200 | 0,0265 / 0,0200 | 0 ; 0 ; 0 |
| J3 | Position de delta dans [0,1] | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J3 | Shapiro-Wilk sur residus standardises | 2000 | 0,0885 / 0,0420 | 0,0890 / 0,0430 | 0,0895 / 0,0445 | 0,0885 / 0,0440 | 0 ; 0 ; 0 |
| J3 | Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston) | 2000 | 0,0155 / 0,0090 | 0,0155 / 0,0090 | 0,0155 / 0,0090 | 0,0155 / 0,0090 | 0 ; 0 ; 0 |
| J3 | Shapiro-Francia | 2000 | 0,0825 / 0,0400 | 0,0845 / 0,0400 | 0,0865 / 0,0390 | 0,0925 / 0,0435 | 0 ; 0 ; 0 |
| J3 | Anderson-Darling | 2000 | 0,0860 / 0,0480 | 0,0940 / 0,0510 | 0,0960 / 0,0520 | 0,0945 / 0,0510 | 0 ; 0 ; 0 |
| J3 | Cramer-von Mises | 2000 | 0,0920 / 0,0510 | 0,0970 / 0,0510 | 0,0970 / 0,0525 | 0,0945 / 0,0525 | 0 ; 0 ; 0 |
| J3 | Kolmogorov-Smirnov contre N(0,1) | 2000 | 0,0965 / 0,0480 | 0,0990 / 0,0520 | 0,1015 / 0,0500 | 0,0970 / 0,0470 | 0 ; 0 ; 0 |
| J3 | Lilliefors (KS a parametres estimes) | 2000 | 0,0900 / 0,0385 | 0,0820 / 0,0405 | 0,0840 / 0,0400 | 0,0900 / 0,0415 | 0 ; 0 ; 0 |
| J3 | Jarque-Bera | 2000 | 0,0805 / 0,0335 | 0,0830 / 0,0390 | 0,0855 / 0,0385 | 0,1000 / 0,0465 | 0 ; 0 ; 0 |
| J3 | Asymetrie (D'Agostino, T >= 8) | 2000 | 0,0690 / 0,0330 | 0,0770 / 0,0385 | 0,0805 / 0,0370 | 0,0945 / 0,0455 | 0 ; 0 ; 0 |
| J3 | Aplatissement (Anscombe-Glynn, T >= 20) | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J3 | Autocorrelation d'ordre 1 (Durbin-Watson) | 2000 | 0,1070 / 0,0545 | 0,1030 / 0,0515 | 0,1000 / 0,0525 | 0,1025 / 0,0535 | 0 ; 0 ; 0 |
| J3 | Ljung-Box (retard 1) | 2000 | 0,1060 / 0,0560 | 0,1020 / 0,0540 | 0,1000 / 0,0540 | 0,0980 / 0,0510 | 0 ; 0 ; 0 |
| J3 | Ljung-Box (retard 2) | 2000 | 0,1045 / 0,0495 | 0,1045 / 0,0470 | 0,1035 / 0,0460 | 0,1000 / 0,0440 | 0 ; 0 ; 0 |
| J3 | Box-Pierce (retard 2) | 2000 | 0,1020 / 0,0520 | 0,1005 / 0,0480 | 0,1035 / 0,0465 | 0,0990 / 0,0440 | 0 ; 0 ; 0 |
| J3 | Test des suites (aleatoire des signes) | 2000 | 0,0660 / 0,0060 | 0,0630 / 0,0080 | 0,0655 / 0,0070 | 0,0655 / 0,0045 | 0 ; 0 ; 0 |
| J3 | Centrage des residus standardises | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J3 | Variance unitaire des residus standardises | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J3 | Rupture de niveau (sup-F) | 2000 | 0,1075 / 0,0510 | 0,1080 / 0,0530 | 0,1050 / 0,0535 | 0,1075 / 0,0515 | 0 ; 0 ; 0 |
| J3 | Stabilite cumulee (OLS-CUSUM) | 2000 | 0,1085 / 0,0505 | 0,1060 / 0,0495 | 0,1080 / 0,0485 | 0,1050 / 0,0460 | 0 ; 0 ; 0 |
| J3 | Valeur aberrante isolee (Grubbs) | 2000 | 0,0750 / 0,0335 | 0,0905 / 0,0420 | 0,0900 / 0,0465 | 0,1075 / 0,0590 | 0 ; 0 ; 0 |
| J3 | Valeurs aberrantes multiples (ESD generalise) | 2000 | 0,0920 / 0,0590 | 0,0920 / 0,0590 | 0,0920 / 0,0590 | 0,0920 / 0,0590 | 0 ; 0 ; 0 |
| J3 | Points influents (distance de Cook) | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |
| J3 | Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts | 2000 | 0,0985 / 0,0520 | 0,0965 / 0,0465 | 0,0965 / 0,0475 | 0,0945 / 0,0465 | 0 ; 0 ; 0 |
| J3 | Ljung-Box (retard 1) sur ratios bruts | 2000 | 0,1020 / 0,0535 | 0,0975 / 0,0465 | 0,0985 / 0,0470 | 0,0930 / 0,0450 | 0 ; 0 ; 0 |
| J3 | Test des suites sur ratios bruts | 2000 | 0,0580 / 0,0130 | 0,0575 / 0,0115 | 0,0575 / 0,0100 | 0,0575 / 0,0065 | 0 ; 0 ; 0 |
| J3 | Rupture de niveau (sup-F) sur ratios bruts | 2000 | 0,1055 / 0,0520 | 0,1070 / 0,0550 | 0,1050 / 0,0535 | 0,1075 / 0,0560 | 0 ; 0 ; 0 |
| J3 | Stabilite cumulee (OLS-CUSUM) sur ratios bruts | 2000 | 0,1090 / 0,0500 | 0,1055 / 0,0530 | 0,1060 / 0,0510 | 0,1045 / 0,0450 | 0 ; 0 ; 0 |
| J3 | Valeur aberrante isolee (Grubbs) sur ratios bruts | 2000 | 0,0755 / 0,0365 | 0,0860 / 0,0490 | 0,0830 / 0,0480 | 0,0910 / 0,0545 | 0 ; 0 ; 0 |
| J3 | Leviers (hat values) | 2000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0,0000 / 0,0000 | 0 ; 0 ; 0 |

Agrégats par réplication (au moins une ligne en ALERTE ou ECHEC ; au moins une en ECHEC), par jeu et par régime :

| Jeu | Régime | n | V1 ≥ 1 A ou E / ≥ 1 E | V3a ≥ 1 A ou E / ≥ 1 E | V3b ≥ 1 A ou E / ≥ 1 E | V3h ≥ 1 A ou E / ≥ 1 E |
| --- | --- | --- | --- | --- | --- | --- |
| J1 | tous | 2000 | 1,0000 / 1,0000 | 1,0000 / 1,0000 | 1,0000 / 1,0000 | 1,0000 / 1,0000 |
| J1 | δ̂* = 0 | 930 | 1,0000 / 1,0000 | 1,0000 / 1,0000 | 1,0000 / 1,0000 | 1,0000 / 1,0000 |
| J1 | δ̂* intérieur | 75 | 1,0000 / 1,0000 | 1,0000 / 1,0000 | 1,0000 / 1,0000 | 1,0000 / 1,0000 |
| J1 | δ̂* = 1 | 995 | 1,0000 / 1,0000 | 1,0000 / 1,0000 | 1,0000 / 1,0000 | 1,0000 / 1,0000 |
| J2 | tous | 2000 | 0,8445 / 0,4835 | 0,8490 / 0,5020 | 0,8480 / 0,5020 | 0,8540 / 0,5050 |
| J2 | δ̂* = 0 | 814 | 0,8452 / 0,5098 | 0,8538 / 0,5160 | 0,8550 / 0,5160 | 0,8452 / 0,5098 |
| J2 | δ̂* intérieur | 464 | 0,8405 / 0,4375 | 0,8836 / 0,5323 | 0,8815 / 0,5302 | 0,8815 / 0,5302 |
| J2 | δ̂* = 1 | 722 | 0,8463 / 0,4834 | 0,8213 / 0,4668 | 0,8186 / 0,4681 | 0,8463 / 0,4834 |
| J3 | tous | 2000 | 0,7025 / 0,4425 | 0,7450 / 0,4970 | 0,7415 / 0,4985 | 0,7400 / 0,5005 |
| J3 | δ̂* = 0 | 507 | 0,7515 / 0,5030 | 0,7554 / 0,5148 | 0,7594 / 0,5089 | 0,7515 / 0,5030 |
| J3 | δ̂* intérieur | 1125 | 0,6791 / 0,4169 | 0,7529 / 0,5191 | 0,7458 / 0,5200 | 0,7458 / 0,5200 |
| J3 | δ̂* = 1 | 368 | 0,7065 / 0,4375 | 0,7065 / 0,4049 | 0,7038 / 0,4185 | 0,7065 / 0,4375 |

### T3 -- B effectifs, tirages de V3b, p absentes, quasi-égalités (h2) et durées par régime

| Jeu | Régime | n | retenues de V1 : méd. [min ; max] | |A| de V3a : méd. [min ; max] | |A| de V3b : méd. [min ; max] | tirages de V3b : moyenne [méd. ; max] | B_max atteint | p absentes V1 ; V3a ; V3b (cellules réplication x statistique, motifs) | (h2) répl. avec ≥ 1 quasi-égalité (BP, BP79, White, BF, RESET, Intercept) | durée par réplication (s) : moyenne [méd. ; max] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| J1 (bords) | δ̂* = 0 | 930 | 999 [999 ; 999] | 517 [460 ; 569] | 999 [999 ; 999] | 1934 [1935 ; 2074] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 9,14 [9,02 ; 42,76] |
| J1 (bords) | δ̂* intérieur | 75 | 999 [999 ; 999] | 40 [25 ; 58] | 999 [930 ; 999] | 24633 [24833 ; 25000] | 35 (0,4667) | 0 ; 2346 (B eff. < B_MIN_DEGENERESCENCE 2346) ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 48,57 [32,64 ; 207,43] |
| J1 (bords) | δ̂* = 1 | 995 | 999 [999 ; 999] | 498 [448 ; 547] | 999 [999 ; 999] | 2002 [2002 ; 2169] | 0 (0,0000) | 0 ; 0 ; 0 | 1 ; 1 ; 1 ; 1 ; 0 ; 0 | 9,31 [9,22 ; 42,54] |
| J2 | δ̂* = 0 | 814 | 999 [999 ; 999] | 608 [559 ; 660] | 999 [999 ; 999] | 1643 [1644 ; 1757] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 7,96 [7,94 ; 39,06] |
| J2 | δ̂* intérieur | 464 | 999 [999 ; 999] | 216 [172 ; 259] | 999 [999 ; 999] | 4613 [4552 ; 5459] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 13,01 [12,33 ; 61,35] |
| J2 | δ̂* = 1 | 722 | 999 [999 ; 999] | 498 [452 ; 554] | 999 [999 ; 999] | 1999 [2000 ; 2137] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 8,97 [8,77 ; 42,64] |
| J3 | δ̂* = 0 | 507 | 999 [999 ; 999] | 600 [555 ; 647] | 999 [999 ; 999] | 1665 [1664 ; 1772] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 8,73 [8,74 ; 10,01] |
| J3 | δ̂* intérieur | 1125 | 999 [999 ; 999] | 492 [329 ; 579] | 999 [999 ; 999] | 2103 [2017 ; 2965] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 10,11 [9,82 ; 48,55] |
| J3 | δ̂* = 1 | 368 | 999 [999 ; 999] | 497 [451 ; 543] | 999 [999 ; 999] | 2015 [2016 ; 2123] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 9,85 [9,67 ; 45,90] |

**Jeu observé J1** (b = 0, bootstrap sous 20260831, flux de V3b sous 20800000) : δ̂ = 1,000000 (δ̂* = 1) ; δ̂** : 463 au bord 0, 46 intérieurs, 490 au bord 1 ; V3b : 2033 tirages, 999 retenus, arrêt cible.

| Statistique (sens) | p V1 (B) | p V3a (B) | p V3b (B) | motifs d'absence |
| --- | --- | --- | --- | --- |
| AD (haut) | 0,5660 (999) | 0,5906 (490) | 0,5680 (999) | — |
| CvM (haut) | 0,4760 (999) | 0,4847 (490) | 0,4760 (999) | — |
| KS (haut) | 0,2670 (999) | 0,2811 (490) | 0,2740 (999) | — |
| SW (bas) | 0,6200 (999) | 0,6253 (490) | 0,6090 (999) | — |
| SF (bas) | 0,6860 (999) | 0,7006 (490) | 0,6890 (999) | — |
| JB (haut) | 0,6740 (999) | 0,6762 (490) | 0,6600 (999) | — |
| DW (deux) | 0,5580 (999) | 0,5458 (490) | 0,5700 (999) | — |
| LB1 (haut) | 0,9370 (999) | 0,9491 (490) | 0,9280 (999) | — |
| supF (haut) | 0,8400 (999) | 0,8391 (490) | 0,8370 (999) | — |
| CUSUM (haut) | 0,8170 (999) | 0,8045 (490) | 0,8240 (999) | — |
| Grubbs (haut) | 0,8610 (999) | 0,8656 (490) | 0,8780 (999) | — |
| Lillie (haut) | 0,2690 (999) | 0,2770 (490) | 0,2780 (999) | — |
| Intercept (deux) | 0,9640 (999) | 0,9898 (490) | 0,9860 (999) | — |
| RESET (haut) | 0,9960 (999) | 0,9959 (490) | 0,9950 (999) | — |
| BP (haut) | 0,0180 (999) | 0,0265 (490) | 0,0220 (999) | — |
| BP79 (haut) | 0,0900 (999) | 0,1100 (490) | 0,1120 (999) | — |
| White (haut) | 0,0670 (999) | 0,0733 (490) | 0,0700 (999) | — |
| GQ (deux) | 0,1900 (999) | 0,3870 (490) | 0,4140 (999) | — |
| BF (haut) | 0,1040 (999) | 0,1100 (490) | 0,1020 (999) | — |
| Smirnov (haut) | 0,7650 (999) | 0,7800 (490) | 0,7770 (999) | — |
| LB2 (haut) | 0,1880 (999) | 0,1772 (490) | 0,1880 (999) | — |
| BP2 (haut) | 0,2160 (999) | 0,2138 (490) | 0,2210 (999) | — |
| Runs (deux) | 0,7620 (999) | 0,7495 (490) | 0,7420 (999) | — |
| MK (deux) | 0,7580 (999) | 0,6762 (490) | 0,6460 (999) | — |
| SpearVol (deux) | 0,8780 (999) | 0,9491 (490) | 0,9740 (999) | — |
| SpearTps (deux) | 0,8720 (999) | 0,7780 (490) | 0,7580 (999) | — |
| DAgo (deux) | 0,7080 (999) | 0,7658 (490) | 0,7460 (999) | — |
| CoxStuart (haut) | 1,0000 (999) | 1,0000 (490) | 1,0000 (999) | — |
| DWr (deux) | 0,5660 (999) | 0,5662 (490) | 0,5860 (999) | — |
| LB1r (haut) | 0,9960 (999) | 0,9959 (490) | 0,9910 (999) | — |
| Runsr (deux) | 0,7680 (999) | 0,7495 (490) | 0,7420 (999) | — |
| supFr (haut) | 0,9310 (999) | 0,9328 (490) | 0,9320 (999) | — |
| CUSUMr (haut) | 0,7560 (999) | 0,7475 (490) | 0,7640 (999) | — |
| Grubbsr (haut) | 0,7770 (999) | 0,7617 (490) | 0,7850 (999) | — |

**Jeu observé J2** (b = 0, bootstrap sous 20260831, flux de V3b sous 20800000) : δ̂ = 0,663991 (δ̂* intérieur) ; δ̂** : 419 au bord 0, 203 intérieurs, 377 au bord 1 ; V3b : 4490 tirages, 999 retenus, arrêt cible.

| Statistique (sens) | p V1 (B) | p V3a (B) | p V3b (B) | motifs d'absence |
| --- | --- | --- | --- | --- |
| AD (haut) | 0,8070 (999) | 0,7990 (203) | 0,7950 (999) | — |
| CvM (haut) | 0,8300 (999) | 0,8137 (203) | 0,8230 (999) | — |
| KS (haut) | 0,7040 (999) | 0,7108 (203) | 0,6950 (999) | — |
| SW (bas) | 0,7510 (999) | 0,7500 (203) | 0,7380 (999) | — |
| SF (bas) | 0,6840 (999) | 0,6569 (203) | 0,6500 (999) | — |
| JB (haut) | 0,8650 (999) | 0,8480 (203) | 0,8620 (999) | — |
| DW (deux) | 0,4960 (999) | 0,4608 (203) | 0,3900 (999) | — |
| LB1 (haut) | 0,3160 (999) | 0,2990 (203) | 0,2900 (999) | — |
| supF (haut) | 0,9180 (999) | 0,8922 (203) | 0,9110 (999) | — |
| CUSUM (haut) | 0,9360 (999) | 0,9461 (203) | 0,9540 (999) | — |
| Grubbs (haut) | 0,2730 (999) | 0,1373 (203) | 0,1050 (999) | — |
| Lillie (haut) | 0,6440 (999) | 0,6029 (203) | 0,6060 (999) | — |
| Intercept (deux) | 0,6920 (999) | 0,5980 (203) | 0,6700 (999) | — |
| RESET (haut) | 0,8200 (999) | 0,9412 (203) | 0,9580 (999) | — |
| BP (haut) | 0,6940 (999) | 0,3627 (203) | 0,3770 (999) | — |
| BP79 (haut) | 0,6290 (999) | 0,2206 (203) | 0,2710 (999) | — |
| White (haut) | 0,5480 (999) | 0,3922 (203) | 0,4290 (999) | — |
| GQ (deux) | 0,2680 (999) | 0,0196 (203) | 0,0180 (999) | — |
| BF (haut) | 0,5690 (999) | 0,3725 (203) | 0,4170 (999) | — |
| Smirnov (haut) | 1,0000 (999) | 1,0000 (203) | 1,0000 (999) | — |
| LB2 (haut) | 0,2090 (999) | 0,2157 (203) | 0,2200 (999) | — |
| BP2 (haut) | 0,2240 (999) | 0,2255 (203) | 0,2350 (999) | — |
| Runs (deux) | 1,0000 (999) | 1,0000 (203) | 1,0000 (999) | — |
| MK (deux) | 0,7840 (999) | 0,7255 (203) | 0,8300 (999) | — |
| SpearVol (deux) | 0,7060 (999) | 0,6569 (203) | 0,6900 (999) | — |
| SpearTps (deux) | 0,8000 (999) | 0,7157 (203) | 0,8660 (999) | — |
| DAgo (deux) | 0,4680 (999) | 0,3137 (203) | 0,3340 (999) | — |
| CoxStuart (haut) | 1,0000 (999) | 1,0000 (203) | 1,0000 (999) | — |
| DWr (deux) | 0,5180 (999) | 0,4216 (203) | 0,3920 (999) | — |
| LB1r (haut) | 0,3450 (999) | 0,3186 (203) | 0,3280 (999) | — |
| Runsr (deux) | 1,0000 (999) | 1,0000 (203) | 1,0000 (999) | — |
| supFr (haut) | 0,8420 (999) | 0,8186 (203) | 0,8210 (999) | — |
| CUSUMr (haut) | 0,9020 (999) | 0,9069 (203) | 0,9240 (999) | — |
| Grubbsr (haut) | 0,3030 (999) | 0,2108 (203) | 0,2040 (999) | — |

