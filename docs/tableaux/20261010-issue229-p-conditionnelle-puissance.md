## Mesure #229 : p-value Monte-Carlo conditionnelle au régime de δ̂, T = 8 -- puissance (partie P) -- combinaison de 24 tranche(s)

Paramètres : partie=puissance;groupe=H0;R=1000;graine_jeux=20260927;graine_boot=20260831+b;graine_v3b=20800000+b;graine_P=20810000+s;B=999;B_cible=999;B_max=25000;methode=premium;segment=1;annexe=II;nature=brutes;alpha=0.1;theta_equiv=0.1;intensite=0 | partie=puissance;groupe=H3;R=1000;graine_jeux=20260927;graine_boot=20260831+b;graine_v3b=20800000+b;graine_P=20810000+s;B=999;B_cible=999;B_max=25000;methode=premium;segment=1;annexe=II;nature=brutes;alpha=0.1;theta_equiv=0.1;intensite=3 | partie=puissance;groupe=C3;R=1000;graine_jeux=20260927;graine_boot=20260831+b;graine_v3b=20800000+b;graine_P=20810000+s;B=999;B_cible=999;B_max=25000;methode=premium;segment=1;annexe=II;nature=brutes;alpha=0.1;theta_equiv=0.1;intensite=3 | partie=puissance;groupe=C4;R=1000;graine_jeux=20260927;graine_boot=20260831+b;graine_v3b=20800000+b;graine_P=20810000+s;B=999;B_cible=999;B_max=25000;methode=premium;segment=1;annexe=II;nature=brutes;alpha=0.1;theta_equiv=0.1;intensite=4 | partie=puissance;groupe=A4;R=1000;graine_jeux=20260927;graine_boot=20260831+b;graine_v3b=20800000+b;graine_P=20810000+s;B=999;B_cible=999;B_max=25000;methode=premium;segment=1;annexe=II;nature=brutes;alpha=0.1;theta_equiv=0.1;intensite=4 | partie=puissance;groupe=A2;R=1000;graine_jeux=20260927;graine_boot=20260831+b;graine_v3b=20800000+b;graine_P=20810000+s;B=999;B_cible=999;B_max=25000;methode=premium;segment=1;annexe=II;nature=brutes;alpha=0.1;theta_equiv=0.1;intensite=2

### T0 -- provenance (identique dans les tranches de chaque groupe, vérifié)

| Grandeur | Valeur |
| --- | --- |
| Partie | puissance |
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
| H0 : Jeu ou scénario | scénario H0 (H, k = 0) sur le modèle ajusté de J2 |
| H0 : Modèle | modèle ajusté de J2 : δ̂ = 0.663991 ; γ̂ = -2.31999 ; β̂ = 0.701657 |
| H0 : Graines | jeux du scénario : 20810001 ; bootstrap de la réplication b : 20260831 + b ; flux de V3b : 20800000 + b |
| H0 : Graines en collision (déclarées, non bloquantes) | jeux de J1, J2, J3 = bootstrap, réplication 96 ; bootstrap, réplication 70 = SEED_LOI_NULLE_SW |
| H0 : Sources (valeurs brutes de #221 et de #175, tableaux de #221, valeurs brutes de la grille) | docs/tableaux/20261008-issue166-calibration-J2.md (md5 26bb6a08e623fbb8a111ada9202ab10e, suivi par git : oui) |
| H0 : Jeux du scénario (L8) | intensité H, k = 0 ; tirés à R_P = 1000 complet sous 20810001 ; md5 ε d93756db8edf562a40efd996218702b8, md5 Y d1060f9a9ac2e2569e198c4358523fc8 |
| H0 : Contrôle (i3) | OK : empreinte sans commentaires de R/engine.R 46fe1025c2c4a6f241822a89e74b4c06, (g5) de la grille 46fe1025c2c4a6f241822a89e74b4c06 ; md5 du fichier entier 95a48eaf3588a58c507299954597fef1 ; md5 du moteur du T0 de #221 (pour mémoire, lien par (i1) et (c)) 344a4e03751e97b14e5ca1b733b856c6 |
| H0 : Réplications | 1000 (tranches 1-250, 251-500, 501-750, 751-1000) |
| H0 : Durée cumulée (s) | contrôles 51 ; total 8850 ; réplications 8794 |
| H3 : Jeu ou scénario | scénario H3 (H, k = 3) sur le modèle ajusté de J2 |
| H3 : Modèle | modèle ajusté de J2 : δ̂ = 0.663991 ; γ̂ = -2.31999 ; β̂ = 0.701657 |
| H3 : Graines | jeux du scénario : 20810002 ; bootstrap de la réplication b : 20260831 + b ; flux de V3b : 20800000 + b |
| H3 : Graines en collision (déclarées, non bloquantes) | jeux de J1, J2, J3 = bootstrap, réplication 96 ; bootstrap, réplication 70 = SEED_LOI_NULLE_SW |
| H3 : Sources (valeurs brutes de #221 et de #175, tableaux de #221, valeurs brutes de la grille) | docs/tableaux/20261008-issue166-calibration-J2.md (md5 26bb6a08e623fbb8a111ada9202ab10e, suivi par git : oui) |
| H3 : Jeux du scénario (L8) | intensité H, k = 3 ; tirés à R_P = 1000 complet sous 20810002 ; md5 ε 6ba864d90be852e97349905d641f8b8c, md5 Y 65b467742023ab1964958dac6c2da953 |
| H3 : Contrôle (i3) | OK : empreinte sans commentaires de R/engine.R 46fe1025c2c4a6f241822a89e74b4c06, (g5) de la grille 46fe1025c2c4a6f241822a89e74b4c06 ; md5 du fichier entier 95a48eaf3588a58c507299954597fef1 ; md5 du moteur du T0 de #221 (pour mémoire, lien par (i1) et (c)) 344a4e03751e97b14e5ca1b733b856c6 |
| H3 : Réplications | 1000 (tranches 1-250, 251-500, 501-750, 751-1000) |
| H3 : Durée cumulée (s) | contrôles 53 ; total 9948 ; réplications 9891 |
| C3 : Jeu ou scénario | scénario C3 (C, λ = 3) sur le modèle ajusté de J2 |
| C3 : Modèle | modèle ajusté de J2 : δ̂ = 0.663991 ; γ̂ = -2.31999 ; β̂ = 0.701657 |
| C3 : Graines | jeux du scénario : 20810003 ; bootstrap de la réplication b : 20260831 + b ; flux de V3b : 20800000 + b |
| C3 : Graines en collision (déclarées, non bloquantes) | jeux de J1, J2, J3 = bootstrap, réplication 96 ; bootstrap, réplication 70 = SEED_LOI_NULLE_SW |
| C3 : Sources (valeurs brutes de #221 et de #175, tableaux de #221, valeurs brutes de la grille) | docs/tableaux/20261008-issue166-calibration-J2.md (md5 26bb6a08e623fbb8a111ada9202ab10e, suivi par git : oui) |
| C3 : Jeux du scénario (L8) | intensité C, λ = 3 ; tirés à R_P = 1000 complet sous 20810003 ; md5 ε 8b8e52cc112c8a3a30965043af6a1240, md5 t* 00db0fd0728d99fbc33c15f313bdc066, md5 Y e8c1e6e0649968855f4ba1623f43f0d7 |
| C3 : Contrôle (i3) | OK : empreinte sans commentaires de R/engine.R 46fe1025c2c4a6f241822a89e74b4c06, (g5) de la grille 46fe1025c2c4a6f241822a89e74b4c06 ; md5 du fichier entier 95a48eaf3588a58c507299954597fef1 ; md5 du moteur du T0 de #221 (pour mémoire, lien par (i1) et (c)) 344a4e03751e97b14e5ca1b733b856c6 |
| C3 : Réplications | 1000 (tranches 1-250, 251-500, 501-750, 751-1000) |
| C3 : Durée cumulée (s) | contrôles 55 ; total 9787 ; réplications 9728 |
| C4 : Jeu ou scénario | scénario C4 (C, λ = 4) sur le modèle ajusté de J2 |
| C4 : Modèle | modèle ajusté de J2 : δ̂ = 0.663991 ; γ̂ = -2.31999 ; β̂ = 0.701657 |
| C4 : Graines | jeux du scénario : 20810004 ; bootstrap de la réplication b : 20260831 + b ; flux de V3b : 20800000 + b |
| C4 : Graines en collision (déclarées, non bloquantes) | jeux de J1, J2, J3 = bootstrap, réplication 96 ; bootstrap, réplication 70 = SEED_LOI_NULLE_SW |
| C4 : Sources (valeurs brutes de #221 et de #175, tableaux de #221, valeurs brutes de la grille) | docs/tableaux/20261008-issue166-calibration-J2.md (md5 26bb6a08e623fbb8a111ada9202ab10e, suivi par git : oui) |
| C4 : Jeux du scénario (L8) | intensité C, λ = 4 ; tirés à R_P = 1000 complet sous 20810004 ; md5 ε 8a034d3b9ef214bb6dd691b4e2dd902e, md5 t* 5d3944e777c94771605d7c7374d7450e, md5 Y 18c41672a03e23d381c630cdf1c9e7b5 |
| C4 : Contrôle (i3) | OK : empreinte sans commentaires de R/engine.R 46fe1025c2c4a6f241822a89e74b4c06, (g5) de la grille 46fe1025c2c4a6f241822a89e74b4c06 ; md5 du fichier entier 95a48eaf3588a58c507299954597fef1 ; md5 du moteur du T0 de #221 (pour mémoire, lien par (i1) et (c)) 344a4e03751e97b14e5ca1b733b856c6 |
| C4 : Réplications | 1000 (tranches 1-250, 251-500, 501-750, 751-1000) |
| C4 : Durée cumulée (s) | contrôles 54 ; total 9923 ; réplications 9864 |
| A4 : Jeu ou scénario | scénario A4 (A, ν = 4) sur le modèle ajusté de J2 |
| A4 : Modèle | modèle ajusté de J2 : δ̂ = 0.663991 ; γ̂ = -2.31999 ; β̂ = 0.701657 |
| A4 : Graines | jeux du scénario : 20810005 ; bootstrap de la réplication b : 20260831 + b ; flux de V3b : 20800000 + b |
| A4 : Graines en collision (déclarées, non bloquantes) | jeux de J1, J2, J3 = bootstrap, réplication 96 ; bootstrap, réplication 70 = SEED_LOI_NULLE_SW |
| A4 : Sources (valeurs brutes de #221 et de #175, tableaux de #221, valeurs brutes de la grille) | docs/tableaux/20261008-issue166-calibration-J2.md (md5 26bb6a08e623fbb8a111ada9202ab10e, suivi par git : oui) |
| A4 : Jeux du scénario (L8) | intensité A, ν = 4 ; tirés à R_P = 1000 complet sous 20810005 ; md5 ε 24b220ddef224d38e19eb4bb2a947b18, md5 Y 04c46e144ac2e23ea5959a28ad0d761d |
| A4 : Contrôle (i3) | OK : empreinte sans commentaires de R/engine.R 46fe1025c2c4a6f241822a89e74b4c06, (g5) de la grille 46fe1025c2c4a6f241822a89e74b4c06 ; md5 du fichier entier 95a48eaf3588a58c507299954597fef1 ; md5 du moteur du T0 de #221 (pour mémoire, lien par (i1) et (c)) 344a4e03751e97b14e5ca1b733b856c6 |
| A4 : Réplications | 1000 (tranches 1-250, 251-500, 501-750, 751-1000) |
| A4 : Durée cumulée (s) | contrôles 57 ; total 10543 ; réplications 10483 |
| A2 : Jeu ou scénario | scénario A2 (A, ν = 2) sur le modèle ajusté de J2 |
| A2 : Modèle | modèle ajusté de J2 : δ̂ = 0.663991 ; γ̂ = -2.31999 ; β̂ = 0.701657 |
| A2 : Graines | jeux du scénario : 20810006 ; bootstrap de la réplication b : 20260831 + b ; flux de V3b : 20800000 + b |
| A2 : Graines en collision (déclarées, non bloquantes) | jeux de J1, J2, J3 = bootstrap, réplication 96 ; bootstrap, réplication 70 = SEED_LOI_NULLE_SW |
| A2 : Sources (valeurs brutes de #221 et de #175, tableaux de #221, valeurs brutes de la grille) | docs/tableaux/20261008-issue166-calibration-J2.md (md5 26bb6a08e623fbb8a111ada9202ab10e, suivi par git : oui) |
| A2 : Jeux du scénario (L8) | intensité A, ν = 2 ; tirés à R_P = 1000 complet sous 20810006 ; md5 ε 9b1b7218ed01d6cd1d91d62c4766ce69, md5 Y 825966eb7555b75ecf8b550cb6196446 |
| A2 : Contrôle (i3) | OK : empreinte sans commentaires de R/engine.R 46fe1025c2c4a6f241822a89e74b4c06, (g5) de la grille 46fe1025c2c4a6f241822a89e74b4c06 ; md5 du fichier entier 95a48eaf3588a58c507299954597fef1 ; md5 du moteur du T0 de #221 (pour mémoire, lien par (i1) et (c)) 344a4e03751e97b14e5ca1b733b856c6 |
| A2 : Réplications | 1000 (tranches 1-250, 251-500, 501-750, 751-1000) |
| A2 : Durée cumulée (s) | contrôles 58 ; total 10572 ; réplications 10510 |
| Fichiers de tranches (md5) | A2-01de04.txt 40b3099e74945780b5b8957cb62adb22 ; A2-02de04.txt 538dd88bc6e13e5620a4d053b6536809 ; A2-03de04.txt 82ecda7091c1535958ed28eaee278c7a ; A2-04de04.txt 6925adccfa9360770a482d0bbfaac518 ; A4-01de04.txt 669617d386d4b91b387091b93d18d5b8 ; A4-02de04.txt f1406163e3054732357509f5af625d0b ; A4-03de04.txt 836573aa5dd47993cfa4b364af52eee6 ; A4-04de04.txt 53a8789250840222734acbc5862c012e ; C3-01de04.txt 427b5df718cf767dad87f62bad7789da ; C3-02de04.txt 6cdea33a4dc02ca99c7879e3a0767d1f ; C3-03de04.txt 8b627bc438f42c81ce78bb43a9d88dd6 ; C3-04de04.txt 07d5547d7061531762b8c7a511bf96a4 ; C4-01de04.txt b93dafd495b8052cf091854f95945269 ; C4-02de04.txt bab05d3b950617ad31eeac1f20beb9a2 ; C4-03de04.txt 731a291fa9d7cd174e3d22a7d61b93e1 ; C4-04de04.txt 6ac1bafe8e32daccccc08fd0e93a4283 ; H0-01de04.txt 7b8c2e0e1e9ea4b806de740ec3dc0116 ; H0-02de04.txt 7091d19681e49813f73d32e7d635bb72 ; H0-03de04.txt ff08ae462a847215a88f6a860d4d1647 ; H0-04de04.txt 237298913bde55ab7a95763429552314 ; H3-01de04.txt 1c007102117696ab455a25981511532e ; H3-02de04.txt 3be02e1952fce9e0b60572e9e3188b48 ; H3-03de04.txt 055b2806e17c384f55bd9f3a82dbd49e ; H3-04de04.txt e32a30a4704dd3211c41fd4da2a07828 |
| JOURNAL | /tmp/claude-0/-home-user-outil-usp/177c6ea9-4e50-557d-aabd-014e9ca1fdc6/scratchpad/wt-sauvegarde/sauvegarde/issue229/JOURNAL.md (md5 70219fe70d366de52e2d5dc6668b977c) : md5 des 24 tranches conformes ; lignes du débit P4 et de l'empreinte (#231) lues |
| Débit P4 (ligne du JOURNAL) | J2 intérieur, 3 réplications par exécution, durée moyenne par réplication 13,06 s à 1 exécution, 12,10 à 12,70 s à 2, 12,65 à 13,35 s à 3, 12,91 à 13,27 s à 4 exécutions concurrentes (horloge 51 à 54 s pour chaque k) : débit agrégé proportionnel au nombre de tranches jusqu'à 4 ; 4 tranches concurrentes retenues. Estimation (coder, sur ces coûts) : 32 à 35 h CPU, environ 9 à 10 h d'horloge, sous le plafond de 54 h fixé par le mainteneur. |
| Empreinte sans commentaires (#231) du JOURNAL | 46fe1025c2c4a6f241822a89e74b4c06, égale à celle des tranches (contrôle (i3)) |
| Reprises (--reprendre : sortie partielle relue, réplications faites conservées) | aucune |
| Commit de la combinaison | 1c1476061f3ac128517ad2a12ca388409c96e8d5 |
| Empreintes md5 du combinateur | R/engine.R 95a48eaf3588a58c507299954597fef1 ; tests/outils_tests.R chargé (dépôt) 30318c792ac0cc633f415154e15c037c ; script exécuté (dépôt) aa00fcf9451196cd2a7b33a8ca67c882 ; tests/taux_franchissement_reperes.R 9e46c0ad40949e93d35e0c3e1a30ec57 ; docs/specifications/229-p-conditionnelle-regime.md e4c6e21276b469e4362423083750f686 |
| Empreinte sans commentaires de R/engine.R à la combinaison (#231) | 46fe1025c2c4a6f241822a89e74b4c06 |
| Références des lois discrètes (tailles lissées de #166 à B = 999, T0 du tableau de #221 de J2) | suites 0,05713 et 0,00968 ; mk 0,07107 et 0,03355 ; smirnov 0,02857 et 0,02856 ; spearman 0,09038 et 0,04295 ; coxstuart 0,00059 et 0,00000 |
| Valeurs brutes de cette sortie | 20261010-issue229-p-conditionnelle-puissance-brut.tsv : md5 1288dcb1322346e54dd487023725c401, 6000 lignes de réplications (copie hors du dépôt : --brut) |
| Valeurs brutes de la partie régime (C1 à C3, niveaux de J2) | docs/tableaux/20261010-issue229-p-conditionnelle-regime-brut.tsv (md5 bd38957680e4880a5bb5aaabb8e33047, suivi par git : oui) |
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

### Partie P -- conditions C4 et profils (sans conclure)

| Condition | Variante | État (mécanique) | Détail |
| --- | --- | --- | --- |
| C4a | V3b | en défaut | perte significative (McNemar Holm < 0,05, n10 > n01, F_R, toutes réplications) : H0 JB 0,10 (6/22, p Holm 0,0409) ; H0 Grubbs 0,10 (3/19, p Holm 0,0111) ; H0 BP 0,10 (3/30, p Holm 2,52e-05) ; H0 BP79 0,10 (2/59, p Holm 3,61e-14) ; H0 BF 0,10 (4/37, p Holm 2,05e-06) ; H0 MK 0,10 (4/22, p Holm 0,00747) ; H0 SpearTps 0,10 (4/20, p Holm 0,0185) ; H0 DAgo 0,10 (5/28, p Holm 0,00106) ; H0 Grubbsr 0,10 (4/30, p Holm 0,000105) ; H0 Grubbs 0,05 (1/23, p Holm 5,96e-05) ; ... (52 en tout) |
| C4b | V3b | remplie | gain significatif à δ̂* intérieur (α = 0,10, Holm sur l'ensemble cible, n01 > n10) : H3 BP (9/0, p Holm 0,0195) ; H3 BP79 (8/0, p Holm 0,0312) ; H3 BF (8/0, p Holm 0,0312) ; C3 Grubbs (31/0, p Holm 4,66e-09) ; C3 Grubbsr (15/0, p Holm 0,000183) ; C3 DAgo (20/0, p Holm 7,63e-06) ; C3 JB (8/0, p Holm 0,0156) ; C4 Grubbs (37/0, p Holm 7,28e-11) ; C4 Grubbsr (20/0, p Holm 7,63e-06) ; C4 DAgo (19/0, p Holm 1,14e-05) ; ... (22 en tout) |
| C4a | V3a | en défaut | perte significative (McNemar Holm < 0,05, n10 > n01, F_R, toutes réplications) : H0 SF 0,10 (0/11, p Holm 0,0117) ; H0 JB 0,10 (7/25, p Holm 0,021) ; H0 Grubbs 0,10 (3/21, p Holm 0,0036) ; H0 BP 0,10 (3/30, p Holm 2,38e-05) ; H0 BP79 0,10 (3/57, p Holm 1,38e-12) ; H0 BF 0,10 (3/44, p Holm 5,18e-09) ; H0 MK 0,10 (3/23, p Holm 0,00123) ; H0 SpearTps 0,10 (3/18, p Holm 0,0164) ; H0 DAgo 0,10 (4/28, p Holm 0,000309) ; H0 Grubbsr 0,10 (3/34, p Holm 2,34e-06) ; ... (53 en tout) |
| C4b | V3a | remplie | gain significatif à δ̂* intérieur (α = 0,10, Holm sur l'ensemble cible, n01 > n10) : H3 BP (10/0, p Holm 0,00977) ; H3 BP79 (10/0, p Holm 0,00977) ; H3 BF (8/0, p Holm 0,0234) ; C3 Grubbs (28/0, p Holm 3,73e-08) ; C3 Grubbsr (15/0, p Holm 0,000183) ; C3 DAgo (18/0, p Holm 3,05e-05) ; C3 JB (7/0, p Holm 0,0313) ; C4 Grubbs (38/0, p Holm 3,64e-11) ; C4 Grubbsr (21/0, p Holm 3,81e-06) ; C4 DAgo (18/0, p Holm 2,29e-05) ; ... (20 en tout) |
| C4a | V3h | remplie | perte significative (McNemar Holm < 0,05, n10 > n01, F_R, toutes réplications) : aucune |
| C4b | V3h | remplie | gain significatif à δ̂* intérieur (α = 0,10, Holm sur l'ensemble cible, n01 > n10) : H3 BP (9/0, p Holm 0,0195) ; H3 BP79 (8/0, p Holm 0,0312) ; H3 BF (8/0, p Holm 0,0312) ; C3 Grubbs (31/0, p Holm 4,66e-09) ; C3 Grubbsr (15/0, p Holm 0,000183) ; C3 DAgo (20/0, p Holm 7,63e-06) ; C3 JB (8/0, p Holm 0,0156) ; C4 Grubbs (37/0, p Holm 7,28e-11) ; C4 Grubbsr (20/0, p Holm 7,63e-06) ; C4 DAgo (19/0, p Holm 1,14e-05) ; ... (22 en tout) |

**Profils (par. 2.3) : C1 à C3 relus dans les valeurs brutes de la partie régime, C4 de cette partie :**

| Variante | C1 | C2 | C3 | C4 | Profil(s) (par. 2.3) |
| --- | --- | --- | --- | --- | --- |
| V3b | remplie | remplie | remplie | en défaut | **D3** (C1, C2, C3 remplies ; C4 en défaut : arbitrage entre calibration conditionnelle et puissance) |
| V3a | remplie | remplie | remplie | en défaut | **D3** (C1, C2, C3 remplies ; C4 en défaut : arbitrage entre calibration conditionnelle et puissance) |
| V3h | remplie | remplie | remplie | remplie | **D1** (C1, C2, C3, C4 remplies : la variante domine V1 quelle que soit la cible) |

Compléments du par. 2.3 : si V3a a le même profil que V3b, elle devient la candidate moins coûteuse ; un témoin de C5 en défaut et non expliqué suspend la lecture ; T2 est rapporté sans critère.

### P1 -- puissance par scénario, statistique et variante (toutes réplications traitées ; p absente = non-rejet)

Taux de rejet [IC 95 %], McNemar contre V1 (n01 / n10, p Holm : famille (scénario, α, variante) sur F_R ; F_T séparée, descriptive) ; niveau de la variante sur J2 (T1 de la partie régime) entre parenthèses.

| Scénario | Statistique | cible | Variante | n | puissance 0,10 [IC] (niveau J2) | McNemar 0,10 | puissance 0,05 [IC] (niveau J2) | McNemar 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| H0 (H, k = 0) | AD |  | V1 | 1000 | 0,1340 [0,1135 ; 0,1567] (0,1020) | — | 0,0660 [0,0514 ; 0,0832] (0,0450) | — |
| H0 (H, k = 0) | AD |  | V3a | 1000 | 0,1280 [0,1079 ; 0,1503] (0,1000) | 3 / 9, 1 | 0,0600 [0,0461 ; 0,0766] (0,0435) | 0 / 6, 0,344 |
| H0 (H, k = 0) | AD |  | V3b | 1000 | 0,1280 [0,1079 ; 0,1503] (0,1000) | 2 / 8, 0,984 | 0,0610 [0,0470 ; 0,0777] (0,0420) | 0 / 5, 0,75 |
| H0 (H, k = 0) | AD |  | V3h | 1000 | 0,1330 [0,1126 ; 0,1556] (0,1020) | 0 / 1, 1 | 0,0650 [0,0505 ; 0,0821] (0,0450) | 0 / 1, 1 |
| H0 (H, k = 0) | CvM |  | V1 | 1000 | 0,1120 [0,0931 ; 0,1332] (0,0970) | — | 0,0550 [0,0417 ; 0,0710] (0,0465) | — |
| H0 (H, k = 0) | CvM |  | V3a | 1000 | 0,1140 [0,0950 ; 0,1353] (0,0985) | 6 / 4, 1 | 0,0580 [0,0443 ; 0,0743] (0,0465) | 6 / 3, 1 |
| H0 (H, k = 0) | CvM |  | V3b | 1000 | 0,1160 [0,0968 ; 0,1375] (0,0955) | 6 / 2, 1 | 0,0580 [0,0443 ; 0,0743] (0,0465) | 5 / 2, 1 |
| H0 (H, k = 0) | CvM |  | V3h | 1000 | 0,1110 [0,0922 ; 0,1321] (0,0935) | 0 / 1, 1 | 0,0550 [0,0417 ; 0,0710] (0,0470) | 0 / 0, 1 |
| H0 (H, k = 0) | KS |  | V1 | 1000 | 0,1080 [0,0894 ; 0,1289] (0,0900) | — | 0,0560 [0,0426 ; 0,0721] (0,0460) | — |
| H0 (H, k = 0) | KS |  | V3a | 1000 | 0,1120 [0,0931 ; 0,1332] (0,0885) | 6 / 2, 1 | 0,0530 [0,0399 ; 0,0688] (0,0425) | 3 / 6, 1 |
| H0 (H, k = 0) | KS |  | V3b | 1000 | 0,1140 [0,0950 ; 0,1353] (0,0885) | 7 / 1, 0,72 | 0,0560 [0,0426 ; 0,0721] (0,0440) | 2 / 2, 1 |
| H0 (H, k = 0) | KS |  | V3h | 1000 | 0,1080 [0,0894 ; 0,1289] (0,0885) | 0 / 0, 1 | 0,0570 [0,0435 ; 0,0732] (0,0455) | 1 / 0, 1 |
| H0 (H, k = 0) | SW |  | V1 | 1000 | 0,1530 [0,1312 ; 0,1768] (0,0945) | — | 0,0740 [0,0585 ; 0,0920] (0,0445) | — |
| H0 (H, k = 0) | SW |  | V3a | 1000 | 0,1460 [0,1247 ; 0,1694] (0,0925) | 1 / 8, 0,469 | 0,0710 [0,0559 ; 0,0887] (0,0450) | 2 / 5, 1 |
| H0 (H, k = 0) | SW |  | V3b | 1000 | 0,1460 [0,1247 ; 0,1694] (0,0915) | 0 / 7, 0,188 | 0,0700 [0,0550 ; 0,0876] (0,0455) | 1 / 5, 1 |
| H0 (H, k = 0) | SW |  | V3h | 1000 | 0,1530 [0,1312 ; 0,1768] (0,0960) | 0 / 0, 1 | 0,0750 [0,0594 ; 0,0931] (0,0460) | 1 / 0, 1 |
| H0 (H, k = 0) | SF |  | V1 | 1000 | 0,1510 [0,1294 ; 0,1747] (0,0850) | — | 0,0750 [0,0594 ; 0,0931] (0,0460) | — |
| H0 (H, k = 0) | SF |  | V3a | 1000 | 0,1400 [0,1191 ; 0,1631] (0,0830) | 0 / 11, 0,0117 | 0,0660 [0,0514 ; 0,0832] (0,0405) | 2 / 11, 0,292 |
| H0 (H, k = 0) | SF |  | V3b | 1000 | 0,1450 [0,1237 ; 0,1684] (0,0800) | 2 / 8, 0,656 | 0,0670 [0,0523 ; 0,0843] (0,0405) | 3 / 11, 0,746 |
| H0 (H, k = 0) | SF |  | V3h | 1000 | 0,1520 [0,1303 ; 0,1758] (0,0925) | 1 / 0, 1 | 0,0780 [0,0621 ; 0,0964] (0,0490) | 3 / 0, 1 |
| H0 (H, k = 0) | JB |  | V1 | 1000 | 0,1620 [0,1397 ; 0,1863] (0,0850) | — | 0,0880 [0,0712 ; 0,1073] (0,0405) | — |
| H0 (H, k = 0) | JB |  | V3a | 1000 | 0,1440 [0,1228 ; 0,1673] (0,0855) | 7 / 25, 0,021 | 0,0810 [0,0648 ; 0,0997] (0,0400) | 4 / 11, 1 |
| H0 (H, k = 0) | JB |  | V3b | 1000 | 0,1460 [0,1247 ; 0,1694] (0,0845) | 6 / 22, 0,0409 | 0,0810 [0,0648 ; 0,0997] (0,0425) | 4 / 11, 1 |
| H0 (H, k = 0) | JB |  | V3h | 1000 | 0,1680 [0,1453 ; 0,1926] (0,1020) | 6 / 0, 0,688 | 0,0920 [0,0748 ; 0,1116] (0,0490) | 4 / 0, 1 |
| H0 (H, k = 0) | DW |  | V1 | 1000 | 0,1010 [0,0830 ; 0,1214] (0,1025) | — | 0,0520 [0,0391 ; 0,0676] (0,0480) | — |
| H0 (H, k = 0) | DW |  | V3a | 1000 | 0,0960 [0,0785 ; 0,1160] (0,1030) | 13 / 18, 1 | 0,0490 [0,0365 ; 0,0643] (0,0540) | 6 / 9, 1 |
| H0 (H, k = 0) | DW |  | V3b | 1000 | 0,0960 [0,0785 ; 0,1160] (0,1060) | 14 / 19, 0,754 | 0,0460 [0,0339 ; 0,0609] (0,0535) | 6 / 12, 1 |
| H0 (H, k = 0) | DW |  | V3h | 1000 | 0,1040 [0,0858 ; 0,1246] (0,1110) | 3 / 0, 1 | 0,0520 [0,0391 ; 0,0676] (0,0535) | 0 / 0, 1 |
| H0 (H, k = 0) | LB1 |  | V1 | 1000 | 0,0870 [0,0703 ; 0,1062] (0,1090) | — | 0,0430 [0,0313 ; 0,0575] (0,0530) | — |
| H0 (H, k = 0) | LB1 |  | V3a | 1000 | 0,0910 [0,0739 ; 0,1106] (0,1130) | 5 / 1, 1 | 0,0450 [0,0330 ; 0,0598] (0,0505) | 4 / 2, 1 |
| H0 (H, k = 0) | LB1 |  | V3b | 1000 | 0,0940 [0,0766 ; 0,1138] (0,1110) | 9 / 2, 0,72 | 0,0450 [0,0330 ; 0,0598] (0,0500) | 4 / 2, 1 |
| H0 (H, k = 0) | LB1 |  | V3h | 1000 | 0,0870 [0,0703 ; 0,1062] (0,1135) | 0 / 0, 1 | 0,0440 [0,0321 ; 0,0586] (0,0550) | 1 / 0, 1 |
| H0 (H, k = 0) | supF |  | V1 | 1000 | 0,1120 [0,0931 ; 0,1332] (0,0935) | — | 0,0560 [0,0426 ; 0,0721] (0,0515) | — |
| H0 (H, k = 0) | supF |  | V3a | 1000 | 0,1060 [0,0876 ; 0,1268] (0,0920) | 5 / 11, 1 | 0,0460 [0,0339 ; 0,0609] (0,0555) | 1 / 11, 0,0952 |
| H0 (H, k = 0) | supF |  | V3b | 1000 | 0,1040 [0,0858 ; 0,1246] (0,0905) | 7 / 15, 0,656 | 0,0490 [0,0365 ; 0,0643] (0,0555) | 4 / 11, 1 |
| H0 (H, k = 0) | supF |  | V3h | 1000 | 0,1140 [0,0950 ; 0,1353] (0,0950) | 2 / 0, 1 | 0,0580 [0,0443 ; 0,0743] (0,0530) | 2 / 0, 1 |
| H0 (H, k = 0) | CUSUM |  | V1 | 1000 | 0,0960 [0,0785 ; 0,1160] (0,0990) | — | 0,0420 [0,0304 ; 0,0564] (0,0480) | — |
| H0 (H, k = 0) | CUSUM |  | V3a | 1000 | 0,0910 [0,0739 ; 0,1106] (0,0990) | 0 / 5, 0,688 | 0,0410 [0,0296 ; 0,0552] (0,0475) | 2 / 3, 1 |
| H0 (H, k = 0) | CUSUM |  | V3b | 1000 | 0,0930 [0,0757 ; 0,1127] (0,0995) | 2 / 5, 1 | 0,0410 [0,0296 ; 0,0552] (0,0510) | 3 / 4, 1 |
| H0 (H, k = 0) | CUSUM |  | V3h | 1000 | 0,0950 [0,0775 ; 0,1149] (0,0990) | 0 / 1, 1 | 0,0410 [0,0296 ; 0,0552] (0,0470) | 0 / 1, 1 |
| H0 (H, k = 0) | Grubbs |  | V1 | 1000 | 0,1640 [0,1416 ; 0,1884] (0,0835) | — | 0,0950 [0,0775 ; 0,1149] (0,0415) | — |
| H0 (H, k = 0) | Grubbs |  | V3a | 1000 | 0,1460 [0,1247 ; 0,1694] (0,0835) | 3 / 21, 0,0036 | 0,0740 [0,0585 ; 0,0920] (0,0400) | 1 / 22, 0,000109 |
| H0 (H, k = 0) | Grubbs |  | V3b | 1000 | 0,1480 [0,1266 ; 0,1715] (0,0845) | 3 / 19, 0,0111 | 0,0730 [0,0577 ; 0,0909] (0,0430) | 1 / 23, 5,96e-05 |
| H0 (H, k = 0) | Grubbs |  | V3h | 1000 | 0,1670 [0,1444 ; 0,1916] (0,1000) | 3 / 0, 1 | 0,0960 [0,0785 ; 0,1160] (0,0515) | 1 / 0, 1 |
| H0 (H, k = 0) | Lillie |  | V1 | 1000 | 0,1290 [0,1088 ; 0,1514] (0,0880) | — | 0,0730 [0,0577 ; 0,0909] (0,0480) | — |
| H0 (H, k = 0) | Lillie |  | V3a | 1000 | 0,1270 [0,1070 ; 0,1492] (0,0875) | 3 / 5, 1 | 0,0660 [0,0514 ; 0,0832] (0,0465) | 2 / 9, 0,589 |
| H0 (H, k = 0) | Lillie |  | V3b | 1000 | 0,1260 [0,1061 ; 0,1482] (0,0860) | 3 / 6, 1 | 0,0680 [0,0532 ; 0,0854] (0,0435) | 1 / 6, 1 |
| H0 (H, k = 0) | Lillie |  | V3h | 1000 | 0,1290 [0,1088 ; 0,1514] (0,0920) | 0 / 0, 1 | 0,0730 [0,0577 ; 0,0909] (0,0505) | 0 / 0, 1 |
| H0 (H, k = 0) | Intercept |  | V1 | 1000 | 0,1330 [0,1126 ; 0,1556] (0,0975) | — | 0,0660 [0,0514 ; 0,0832] (0,0535) | — |
| H0 (H, k = 0) | Intercept |  | V3a | 1000 | 0,1310 [0,1107 ; 0,1535] (0,1035) | 9 / 11, 1 | 0,0680 [0,0532 ; 0,0854] (0,0540) | 6 / 4, 1 |
| H0 (H, k = 0) | Intercept |  | V3b | 1000 | 0,1310 [0,1107 ; 0,1535] (0,0995) | 6 / 8, 1 | 0,0640 [0,0496 ; 0,0810] (0,0560) | 5 / 7, 1 |
| H0 (H, k = 0) | Intercept |  | V3h | 1000 | 0,1320 [0,1116 ; 0,1546] (0,0950) | 0 / 1, 1 | 0,0630 [0,0487 ; 0,0799] (0,0520) | 0 / 3, 1 |
| H0 (H, k = 0) | RESET |  | V1 | 1000 | 0,0360 [0,0253 ; 0,0495] (0,0830) | — | 0,0130 [0,0069 ; 0,0221] (0,0325) | — |
| H0 (H, k = 0) | RESET |  | V3a | 1000 | 0,0790 [0,0630 ; 0,0975] (0,0855) | 48 / 5, 1,42e-08 | 0,0460 [0,0339 ; 0,0609] (0,0435) | 33 / 0, 5,12e-09 |
| H0 (H, k = 0) | RESET |  | V3b | 1000 | 0,0770 [0,0612 ; 0,0953] (0,0865) | 47 / 6, 1,22e-07 | 0,0460 [0,0339 ; 0,0609] (0,0440) | 35 / 2, 2,25e-07 |
| H0 (H, k = 0) | RESET |  | V3h | 1000 | 0,0310 [0,0212 ; 0,0437] (0,0755) | 0 / 5, 1 | 0,0130 [0,0069 ; 0,0221] (0,0350) | 2 / 2, 1 |
| H0 (H, k = 0) | BP | oui | V1 | 1000 | 0,1850 [0,1614 ; 0,2105] (0,0850) | — | 0,0830 [0,0666 ; 0,1019] (0,0370) | — |
| H0 (H, k = 0) | BP | oui | V3a | 1000 | 0,1580 [0,1359 ; 0,1821] (0,0770) | 3 / 30, 2,38e-05 | 0,0750 [0,0594 ; 0,0931] (0,0365) | 2 / 10, 0,463 |
| H0 (H, k = 0) | BP | oui | V3b | 1000 | 0,1580 [0,1359 ; 0,1821] (0,0780) | 3 / 30, 2,52e-05 | 0,0760 [0,0603 ; 0,0942] (0,0380) | 2 / 9, 0,75 |
| H0 (H, k = 0) | BP | oui | V3h | 1000 | 0,1870 [0,1633 ; 0,2126] (0,1095) | 2 / 0, 1 | 0,0840 [0,0676 ; 0,1029] (0,0490) | 1 / 0, 1 |
| H0 (H, k = 0) | BP79 | oui | V1 | 1000 | 0,2610 [0,2340 ; 0,2894] (0,0755) | — | 0,1420 [0,1209 ; 0,1652] (0,0365) | — |
| H0 (H, k = 0) | BP79 | oui | V3a | 1000 | 0,2070 [0,1823 ; 0,2335] (0,0680) | 3 / 57, 1,38e-12 | 0,1170 [0,0977 ; 0,1386] (0,0345) | 1 / 26, 8,34e-06 |
| H0 (H, k = 0) | BP79 | oui | V3b | 1000 | 0,2040 [0,1794 ; 0,2303] (0,0685) | 2 / 59, 3,61e-14 | 0,1240 [0,1042 ; 0,1460] (0,0355) | 1 / 19, 0,000761 |
| H0 (H, k = 0) | BP79 | oui | V3h | 1000 | 0,2630 [0,2359 ; 0,2915] (0,0965) | 2 / 0, 1 | 0,1430 [0,1219 ; 0,1662] (0,0485) | 1 / 0, 1 |
| H0 (H, k = 0) | White | oui | V1 | 1000 | 0,1080 [0,0894 ; 0,1289] (0,0880) | — | 0,0350 [0,0245 ; 0,0483] (0,0400) | — |
| H0 (H, k = 0) | White | oui | V3a | 1000 | 0,1330 [0,1126 ; 0,1556] (0,0825) | 26 / 1, 7,51e-06 | 0,0600 [0,0461 ; 0,0766] (0,0360) | 25 / 0, 1,25e-06 |
| H0 (H, k = 0) | White | oui | V3b | 1000 | 0,1340 [0,1135 ; 0,1567] (0,0810) | 28 / 2, 1,65e-05 | 0,0580 [0,0443 ; 0,0743] (0,0360) | 23 / 0, 5,01e-06 |
| H0 (H, k = 0) | White | oui | V3h | 1000 | 0,1080 [0,0894 ; 0,1289] (0,0890) | 1 / 1, 1 | 0,0350 [0,0245 ; 0,0483] (0,0420) | 0 / 0, 1 |
| H0 (H, k = 0) | GQ | oui | V1 | 1000 | 0,1650 [0,1425 ; 0,1895] (0,0545) | — | 0,0920 [0,0748 ; 0,1116] (0,0290) | — |
| H0 (H, k = 0) | GQ | oui | V3a | 1000 | 0,1410 [0,1200 ; 0,1641] (0,1020) | 25 / 49, 0,0638 | 0,0710 [0,0559 ; 0,0887] (0,0485) | 13 / 34, 0,0525 |
| H0 (H, k = 0) | GQ | oui | V3b | 1000 | 0,1410 [0,1200 ; 0,1641] (0,1000) | 27 / 51, 0,0877 | 0,0670 [0,0523 ; 0,0843] (0,0495) | 13 / 38, 0,0112 |
| H0 (H, k = 0) | GQ | oui | V3h | 1000 | 0,1700 [0,1472 ; 0,1947] (0,0790) | 5 / 0, 1 | 0,0920 [0,0748 ; 0,1116] (0,0405) | 0 / 0, 1 |
| H0 (H, k = 0) | BF | oui | V1 | 1000 | 0,1780 [0,1548 ; 0,2031] (0,0860) | — | 0,0860 [0,0694 ; 0,1051] (0,0455) | — |
| H0 (H, k = 0) | BF | oui | V3a | 1000 | 0,1370 [0,1163 ; 0,1599] (0,0865) | 3 / 44, 5,18e-09 | 0,0720 [0,0568 ; 0,0898] (0,0445) | 4 / 18, 0,0695 |
| H0 (H, k = 0) | BF | oui | V3b | 1000 | 0,1450 [0,1237 ; 0,1684] (0,0875) | 4 / 37, 2,05e-06 | 0,0750 [0,0594 ; 0,0931] (0,0455) | 5 / 16, 0,399 |
| H0 (H, k = 0) | BF | oui | V3h | 1000 | 0,1820 [0,1585 ; 0,2073] (0,1095) | 4 / 0, 1 | 0,0910 [0,0739 ; 0,1106] (0,0565) | 5 / 0, 1 |
| H0 (H, k = 0) | Smirnov |  | V1 | 1000 | 0,0370 [0,0262 ; 0,0506] (0,0275) | — | 0,0370 [0,0262 ; 0,0506] (0,0275) | — |
| H0 (H, k = 0) | Smirnov |  | V3a | 1000 | 0,0380 [0,0270 ; 0,0518] (0,0290) | 1 / 0, 1 | 0,0330 [0,0228 ; 0,0460] (0,0275) | 0 / 4, 1 |
| H0 (H, k = 0) | Smirnov |  | V3b | 1000 | 0,0370 [0,0262 ; 0,0506] (0,0275) | 0 / 0, 1 | 0,0350 [0,0245 ; 0,0483] (0,0275) | 0 / 2, 1 |
| H0 (H, k = 0) | Smirnov |  | V3h | 1000 | 0,0370 [0,0262 ; 0,0506] (0,0275) | 0 / 0, 1 | 0,0370 [0,0262 ; 0,0506] (0,0275) | 0 / 0, 1 |
| H0 (H, k = 0) | LB2 |  | V1 | 1000 | 0,0640 [0,0496 ; 0,0810] (0,1065) | — | 0,0380 [0,0270 ; 0,0518] (0,0530) | — |
| H0 (H, k = 0) | LB2 |  | V3a | 1000 | 0,0810 [0,0648 ; 0,0997] (0,1005) | 18 / 1, 0,00114 | 0,0450 [0,0330 ; 0,0598] (0,0545) | 9 / 2, 0,654 |
| H0 (H, k = 0) | LB2 |  | V3b | 1000 | 0,0800 [0,0639 ; 0,0986] (0,0980) | 17 / 1, 0,00217 | 0,0430 [0,0313 ; 0,0575] (0,0540) | 5 / 0, 0,75 |
| H0 (H, k = 0) | LB2 |  | V3h | 1000 | 0,0630 [0,0487 ; 0,0799] (0,1010) | 0 / 1, 1 | 0,0380 [0,0270 ; 0,0518] (0,0505) | 0 / 0, 1 |
| H0 (H, k = 0) | BP2 |  | V1 | 1000 | 0,0710 [0,0559 ; 0,0887] (0,1040) | — | 0,0420 [0,0304 ; 0,0564] (0,0530) | — |
| H0 (H, k = 0) | BP2 |  | V3a | 1000 | 0,0800 [0,0639 ; 0,0986] (0,1025) | 11 / 2, 0,18 | 0,0470 [0,0347 ; 0,0620] (0,0550) | 7 / 2, 1 |
| H0 (H, k = 0) | BP2 |  | V3b | 1000 | 0,0790 [0,0630 ; 0,0975] (0,1015) | 11 / 3, 0,459 | 0,0430 [0,0313 ; 0,0575] (0,0560) | 4 / 3, 1 |
| H0 (H, k = 0) | BP2 |  | V3h | 1000 | 0,0700 [0,0550 ; 0,0876] (0,1025) | 0 / 1, 1 | 0,0410 [0,0296 ; 0,0552] (0,0510) | 1 / 2, 1 |
| H0 (H, k = 0) | Runs |  | V1 | 1000 | 0,0470 [0,0347 ; 0,0620] (0,0635) | — | 0,0080 [0,0035 ; 0,0157] (0,0075) | — |
| H0 (H, k = 0) | Runs |  | V3a | 1000 | 0,0470 [0,0347 ; 0,0620] (0,0610) | 1 / 1, 1 | 0,0200 [0,0123 ; 0,0307] (0,0145) | 12 / 0, 0,00586 |
| H0 (H, k = 0) | Runs |  | V3b | 1000 | 0,0470 [0,0347 ; 0,0620] (0,0635) | 0 / 0, 1 | 0,0130 [0,0069 ; 0,0221] (0,0095) | 9 / 4, 1 |
| H0 (H, k = 0) | Runs |  | V3h | 1000 | 0,0470 [0,0347 ; 0,0620] (0,0635) | 0 / 0, 1 | 0,0080 [0,0035 ; 0,0157] (0,0065) | 0 / 0, 1 |
| H0 (H, k = 0) | MK |  | V1 | 1000 | 0,0940 [0,0766 ; 0,1138] (0,0650) | — | 0,0420 [0,0304 ; 0,0564] (0,0290) | — |
| H0 (H, k = 0) | MK |  | V3a | 1000 | 0,0740 [0,0585 ; 0,0920] (0,0715) | 3 / 23, 0,00123 | 0,0380 [0,0270 ; 0,0518] (0,0355) | 0 / 4, 1 |
| H0 (H, k = 0) | MK |  | V3b | 1000 | 0,0760 [0,0603 ; 0,0942] (0,0755) | 4 / 22, 0,00747 | 0,0370 [0,0262 ; 0,0506] (0,0375) | 0 / 5, 0,75 |
| H0 (H, k = 0) | MK |  | V3h | 1000 | 0,0950 [0,0775 ; 0,1149] (0,0635) | 1 / 0, 1 | 0,0420 [0,0304 ; 0,0564] (0,0295) | 0 / 0, 1 |
| H0 (H, k = 0) | SpearVol |  | V1 | 1000 | 0,1120 [0,0931 ; 0,1332] (0,0965) | — | 0,0540 [0,0408 ; 0,0699] (0,0505) | — |
| H0 (H, k = 0) | SpearVol |  | V3a | 1000 | 0,1080 [0,0894 ; 0,1289] (0,1020) | 2 / 6, 1 | 0,0600 [0,0461 ; 0,0766] (0,0470) | 12 / 6, 1 |
| H0 (H, k = 0) | SpearVol |  | V3b | 1000 | 0,1070 [0,0885 ; 0,1278] (0,1020) | 2 / 7, 0,656 | 0,0560 [0,0426 ; 0,0721] (0,0530) | 7 / 5, 1 |
| H0 (H, k = 0) | SpearVol |  | V3h | 1000 | 0,1130 [0,0940 ; 0,1343] (0,0975) | 1 / 0, 1 | 0,0540 [0,0408 ; 0,0699] (0,0515) | 0 / 0, 1 |
| H0 (H, k = 0) | SpearTps |  | V1 | 1000 | 0,1030 [0,0849 ; 0,1235] (0,0885) | — | 0,0550 [0,0417 ; 0,0710] (0,0390) | — |
| H0 (H, k = 0) | SpearTps |  | V3a | 1000 | 0,0880 [0,0712 ; 0,1073] (0,0845) | 3 / 18, 0,0164 | 0,0470 [0,0347 ; 0,0620] (0,0420) | 2 / 10, 0,463 |
| H0 (H, k = 0) | SpearTps |  | V3b | 1000 | 0,0870 [0,0703 ; 0,1062] (0,0875) | 4 / 20, 0,0185 | 0,0420 [0,0304 ; 0,0564] (0,0445) | 1 / 14, 0,0156 |
| H0 (H, k = 0) | SpearTps |  | V3h | 1000 | 0,1030 [0,0849 ; 0,1235] (0,0825) | 1 / 1, 1 | 0,0540 [0,0408 ; 0,0699] (0,0405) | 0 / 1, 1 |
| H0 (H, k = 0) | DAgo |  | V1 | 1000 | 0,1630 [0,1406 ; 0,1874] (0,0815) | — | 0,0880 [0,0712 ; 0,1073] (0,0400) | — |
| H0 (H, k = 0) | DAgo |  | V3a | 1000 | 0,1390 [0,1181 ; 0,1620] (0,0810) | 4 / 28, 0,000309 | 0,0760 [0,0603 ; 0,0942] (0,0395) | 3 / 15, 0,106 |
| H0 (H, k = 0) | DAgo |  | V3b | 1000 | 0,1400 [0,1191 ; 0,1631] (0,0810) | 5 / 28, 0,00106 | 0,0790 [0,0630 ; 0,0975] (0,0415) | 3 / 12, 0,492 |
| H0 (H, k = 0) | DAgo |  | V3h | 1000 | 0,1680 [0,1453 ; 0,1926] (0,0985) | 5 / 0, 1 | 0,0910 [0,0739 ; 0,1106] (0,0510) | 3 / 0, 1 |
| H0 (H, k = 0) | CoxStuart |  | V1 | 1000 | 0,0010 [0,0000 ; 0,0056] (0,0000) | — | 0,0000 [0,0000 ; 0,0037] (0,0000) | — |
| H0 (H, k = 0) | CoxStuart |  | V3a | 1000 | 0,0030 [0,0006 ; 0,0087] (0,0030) | 3 / 1, 1 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 |
| H0 (H, k = 0) | CoxStuart |  | V3b | 1000 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 1, 1 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 |
| H0 (H, k = 0) | CoxStuart |  | V3h | 1000 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 1, 1 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 |
| H0 (H, k = 0) | DWr |  | V1 | 1000 | 0,0950 [0,0775 ; 0,1149] (0,0920) | — | 0,0460 [0,0339 ; 0,0609] (0,0455) | — |
| H0 (H, k = 0) | DWr |  | V3a | 1000 | 0,0890 [0,0721 ; 0,1084] (0,0965) | 12 / 18, 1 | 0,0430 [0,0313 ; 0,0575] (0,0560) | 6 / 9, 1 |
| H0 (H, k = 0) | DWr |  | V3b | 1000 | 0,0890 [0,0721 ; 0,1084] (0,1010) | 13 / 19, 0,754 | 0,0420 [0,0304 ; 0,0564] (0,0575) | 5 / 9, 1 |
| H0 (H, k = 0) | DWr |  | V3h | 1000 | 0,0990 [0,0812 ; 0,1192] (0,1000) | 4 / 0, 1 | 0,0470 [0,0347 ; 0,0620] (0,0515) | 1 / 0, 1 |
| H0 (H, k = 0) | LB1r |  | V1 | 1000 | 0,0810 [0,0648 ; 0,0997] (0,1035) | — | 0,0350 [0,0245 ; 0,0483] (0,0525) | — |
| H0 (H, k = 0) | LB1r |  | V3a | 1000 | 0,0870 [0,0703 ; 0,1062] (0,1105) | 7 / 1, 0,422 | 0,0370 [0,0262 ; 0,0506] (0,0480) | 3 / 1, 1 |
| H0 (H, k = 0) | LB1r |  | V3b | 1000 | 0,0880 [0,0712 ; 0,1073] (0,1105) | 9 / 2, 0,459 | 0,0380 [0,0270 ; 0,0518] (0,0505) | 4 / 1, 1 |
| H0 (H, k = 0) | LB1r |  | V3h | 1000 | 0,0810 [0,0648 ; 0,0997] (0,1130) | 0 / 0, 1 | 0,0360 [0,0253 ; 0,0495] (0,0545) | 1 / 0, 1 |
| H0 (H, k = 0) | Runsr |  | V1 | 1000 | 0,0460 [0,0339 ; 0,0609] (0,0610) | — | 0,0090 [0,0041 ; 0,0170] (0,0105) | — |
| H0 (H, k = 0) | Runsr |  | V3a | 1000 | 0,0470 [0,0347 ; 0,0620] (0,0585) | 1 / 0, 1 | 0,0170 [0,0099 ; 0,0271] (0,0145) | 10 / 2, 0,386 |
| H0 (H, k = 0) | Runsr |  | V3b | 1000 | 0,0460 [0,0339 ; 0,0609] (0,0610) | 0 / 0, 1 | 0,0110 [0,0055 ; 0,0196] (0,0105) | 7 / 5, 1 |
| H0 (H, k = 0) | Runsr |  | V3h | 1000 | 0,0460 [0,0339 ; 0,0609] (0,0610) | 0 / 0, 1 | 0,0090 [0,0041 ; 0,0170] (0,0090) | 0 / 0, 1 |
| H0 (H, k = 0) | supFr |  | V1 | 1000 | 0,1000 [0,0821 ; 0,1203] (0,1010) | — | 0,0510 [0,0382 ; 0,0665] (0,0490) | — |
| H0 (H, k = 0) | supFr |  | V3a | 1000 | 0,0890 [0,0721 ; 0,1084] (0,1020) | 5 / 16, 0,186 | 0,0460 [0,0339 ; 0,0609] (0,0510) | 1 / 6, 1 |
| H0 (H, k = 0) | supFr |  | V3b | 1000 | 0,0890 [0,0721 ; 0,1084] (0,1040) | 6 / 17, 0,312 | 0,0470 [0,0347 ; 0,0620] (0,0535) | 2 / 6, 1 |
| H0 (H, k = 0) | supFr |  | V3h | 1000 | 0,1010 [0,0830 ; 0,1214] (0,1045) | 1 / 0, 1 | 0,0520 [0,0391 ; 0,0676] (0,0510) | 1 / 0, 1 |
| H0 (H, k = 0) | CUSUMr |  | V1 | 1000 | 0,0930 [0,0757 ; 0,1127] (0,0995) | — | 0,0410 [0,0296 ; 0,0552] (0,0505) | — |
| H0 (H, k = 0) | CUSUMr |  | V3a | 1000 | 0,0920 [0,0748 ; 0,1116] (0,1020) | 5 / 6, 1 | 0,0420 [0,0304 ; 0,0564] (0,0500) | 2 / 1, 1 |
| H0 (H, k = 0) | CUSUMr |  | V3b | 1000 | 0,0870 [0,0703 ; 0,1062] (0,0995) | 2 / 8, 0,656 | 0,0410 [0,0296 ; 0,0552] (0,0505) | 1 / 1, 1 |
| H0 (H, k = 0) | CUSUMr |  | V3h | 1000 | 0,0940 [0,0766 ; 0,1138] (0,0990) | 1 / 0, 1 | 0,0410 [0,0296 ; 0,0552] (0,0475) | 0 / 0, 1 |
| H0 (H, k = 0) | Grubbsr |  | V1 | 1000 | 0,1720 [0,1491 ; 0,1968] (0,0845) | — | 0,0970 [0,0794 ; 0,1170] (0,0390) | — |
| H0 (H, k = 0) | Grubbsr |  | V3a | 1000 | 0,1410 [0,1200 ; 0,1641] (0,0870) | 3 / 34, 2,34e-06 | 0,0800 [0,0639 ; 0,0986] (0,0390) | 1 / 18, 0,00137 |
| H0 (H, k = 0) | Grubbsr |  | V3b | 1000 | 0,1460 [0,1247 ; 0,1694] (0,0845) | 4 / 30, 0,000105 | 0,0820 [0,0657 ; 0,1008] (0,0410) | 2 / 17, 0,0124 |
| H0 (H, k = 0) | Grubbsr |  | V3h | 1000 | 0,1760 [0,1529 ; 0,2010] (0,0985) | 4 / 0, 1 | 0,0980 [0,0803 ; 0,1181] (0,0485) | 1 / 0, 1 |
| H3 (H, k = 3) | AD |  | V1 | 1000 | 0,1290 [0,1088 ; 0,1514] (0,1020) | — | 0,0700 [0,0550 ; 0,0876] (0,0450) | — |
| H3 (H, k = 3) | AD |  | V3a | 1000 | 0,1290 [0,1088 ; 0,1514] (0,1000) | 3 / 3, 1 | 0,0700 [0,0550 ; 0,0876] (0,0435) | 5 / 5, 1 |
| H3 (H, k = 3) | AD |  | V3b | 1000 | 0,1310 [0,1107 ; 0,1535] (0,1000) | 4 / 2, 1 | 0,0720 [0,0568 ; 0,0898] (0,0420) | 7 / 5, 1 |
| H3 (H, k = 3) | AD |  | V3h | 1000 | 0,1300 [0,1098 ; 0,1524] (0,1020) | 1 / 0, 1 | 0,0690 [0,0541 ; 0,0865] (0,0450) | 0 / 1, 1 |
| H3 (H, k = 3) | CvM |  | V1 | 1000 | 0,1230 [0,1033 ; 0,1450] (0,0970) | — | 0,0650 [0,0505 ; 0,0821] (0,0465) | — |
| H3 (H, k = 3) | CvM |  | V3a | 1000 | 0,1240 [0,1042 ; 0,1460] (0,0985) | 4 / 3, 1 | 0,0660 [0,0514 ; 0,0832] (0,0465) | 6 / 5, 1 |
| H3 (H, k = 3) | CvM |  | V3b | 1000 | 0,1260 [0,1061 ; 0,1482] (0,0955) | 4 / 1, 1 | 0,0690 [0,0541 ; 0,0865] (0,0465) | 6 / 2, 1 |
| H3 (H, k = 3) | CvM |  | V3h | 1000 | 0,1230 [0,1033 ; 0,1450] (0,0935) | 0 / 0, 1 | 0,0640 [0,0496 ; 0,0810] (0,0470) | 0 / 1, 1 |
| H3 (H, k = 3) | KS |  | V1 | 1000 | 0,1180 [0,0987 ; 0,1396] (0,0900) | — | 0,0590 [0,0452 ; 0,0754] (0,0460) | — |
| H3 (H, k = 3) | KS |  | V3a | 1000 | 0,1160 [0,0968 ; 0,1375] (0,0885) | 4 / 6, 1 | 0,0630 [0,0487 ; 0,0799] (0,0425) | 4 / 0, 1 |
| H3 (H, k = 3) | KS |  | V3b | 1000 | 0,1190 [0,0996 ; 0,1407] (0,0885) | 4 / 3, 1 | 0,0620 [0,0479 ; 0,0788] (0,0440) | 4 / 1, 1 |
| H3 (H, k = 3) | KS |  | V3h | 1000 | 0,1180 [0,0987 ; 0,1396] (0,0885) | 0 / 0, 1 | 0,0590 [0,0452 ; 0,0754] (0,0455) | 0 / 0, 1 |
| H3 (H, k = 3) | SW |  | V1 | 1000 | 0,1300 [0,1098 ; 0,1524] (0,0945) | — | 0,0790 [0,0630 ; 0,0975] (0,0445) | — |
| H3 (H, k = 3) | SW |  | V3a | 1000 | 0,1300 [0,1098 ; 0,1524] (0,0925) | 6 / 6, 1 | 0,0770 [0,0612 ; 0,0953] (0,0450) | 2 / 4, 1 |
| H3 (H, k = 3) | SW |  | V3b | 1000 | 0,1250 [0,1051 ; 0,1471] (0,0915) | 4 / 9, 1 | 0,0750 [0,0594 ; 0,0931] (0,0455) | 3 / 7, 1 |
| H3 (H, k = 3) | SW |  | V3h | 1000 | 0,1300 [0,1098 ; 0,1524] (0,0960) | 0 / 0, 1 | 0,0800 [0,0639 ; 0,0986] (0,0460) | 1 / 0, 1 |
| H3 (H, k = 3) | SF |  | V1 | 1000 | 0,1470 [0,1256 ; 0,1705] (0,0850) | — | 0,0900 [0,0730 ; 0,1095] (0,0460) | — |
| H3 (H, k = 3) | SF |  | V3a | 1000 | 0,1380 [0,1172 ; 0,1609] (0,0830) | 2 / 11, 0,15 | 0,0820 [0,0657 ; 0,1008] (0,0405) | 1 / 9, 0,277 |
| H3 (H, k = 3) | SF |  | V3b | 1000 | 0,1350 [0,1144 ; 0,1578] (0,0800) | 2 / 14, 0,046 | 0,0840 [0,0676 ; 0,1029] (0,0405) | 0 / 6, 0,313 |
| H3 (H, k = 3) | SF |  | V3h | 1000 | 0,1490 [0,1275 ; 0,1726] (0,0925) | 2 / 0, 1 | 0,0900 [0,0730 ; 0,1095] (0,0490) | 0 / 0, 1 |
| H3 (H, k = 3) | JB |  | V1 | 1000 | 0,1700 [0,1472 ; 0,1947] (0,0850) | — | 0,1060 [0,0876 ; 0,1268] (0,0405) | — |
| H3 (H, k = 3) | JB |  | V3a | 1000 | 0,1480 [0,1266 ; 0,1715] (0,0855) | 6 / 28, 0,00293 | 0,0890 [0,0721 ; 0,1084] (0,0400) | 3 / 20, 0,00732 |
| H3 (H, k = 3) | JB |  | V3b | 1000 | 0,1490 [0,1275 ; 0,1726] (0,0845) | 7 / 28, 0,00712 | 0,0900 [0,0730 ; 0,1095] (0,0425) | 3 / 19, 0,0128 |
| H3 (H, k = 3) | JB |  | V3h | 1000 | 0,1770 [0,1538 ; 0,2021] (0,1020) | 7 / 0, 0,297 | 0,1090 [0,0904 ; 0,1300] (0,0490) | 3 / 0, 1 |
| H3 (H, k = 3) | DW |  | V1 | 1000 | 0,0900 [0,0730 ; 0,1095] (0,1025) | — | 0,0430 [0,0313 ; 0,0575] (0,0480) | — |
| H3 (H, k = 3) | DW |  | V3a | 1000 | 0,0920 [0,0748 ; 0,1116] (0,1030) | 14 / 12, 1 | 0,0470 [0,0347 ; 0,0620] (0,0540) | 13 / 9, 1 |
| H3 (H, k = 3) | DW |  | V3b | 1000 | 0,0860 [0,0694 ; 0,1051] (0,1060) | 12 / 16, 1 | 0,0480 [0,0356 ; 0,0631] (0,0535) | 13 / 8, 1 |
| H3 (H, k = 3) | DW |  | V3h | 1000 | 0,0930 [0,0757 ; 0,1127] (0,1110) | 3 / 0, 1 | 0,0470 [0,0347 ; 0,0620] (0,0535) | 4 / 0, 1 |
| H3 (H, k = 3) | LB1 |  | V1 | 1000 | 0,0990 [0,0812 ; 0,1192] (0,1090) | — | 0,0470 [0,0347 ; 0,0620] (0,0530) | — |
| H3 (H, k = 3) | LB1 |  | V3a | 1000 | 0,0850 [0,0685 ; 0,1040] (0,1130) | 3 / 17, 0,0309 | 0,0430 [0,0313 ; 0,0575] (0,0505) | 2 / 6, 1 |
| H3 (H, k = 3) | LB1 |  | V3b | 1000 | 0,0860 [0,0694 ; 0,1051] (0,1110) | 2 / 15, 0,0235 | 0,0420 [0,0304 ; 0,0564] (0,0500) | 2 / 7, 1 |
| H3 (H, k = 3) | LB1 |  | V3h | 1000 | 0,1010 [0,0830 ; 0,1214] (0,1135) | 2 / 0, 1 | 0,0480 [0,0356 ; 0,0631] (0,0550) | 1 / 0, 1 |
| H3 (H, k = 3) | supF |  | V1 | 1000 | 0,0660 [0,0514 ; 0,0832] (0,0935) | — | 0,0260 [0,0171 ; 0,0379] (0,0515) | — |
| H3 (H, k = 3) | supF |  | V3a | 1000 | 0,0820 [0,0657 ; 0,1008] (0,0920) | 19 / 3, 0,0111 | 0,0340 [0,0237 ; 0,0472] (0,0555) | 11 / 3, 0,459 |
| H3 (H, k = 3) | supF |  | V3b | 1000 | 0,0820 [0,0657 ; 0,1008] (0,0905) | 18 / 2, 0,00604 | 0,0360 [0,0253 ; 0,0495] (0,0555) | 13 / 3, 0,255 |
| H3 (H, k = 3) | supF |  | V3h | 1000 | 0,0660 [0,0514 ; 0,0832] (0,0950) | 0 / 0, 1 | 0,0280 [0,0187 ; 0,0402] (0,0530) | 2 / 0, 1 |
| H3 (H, k = 3) | CUSUM |  | V1 | 1000 | 0,0850 [0,0685 ; 0,1040] (0,0990) | — | 0,0390 [0,0279 ; 0,0529] (0,0480) | — |
| H3 (H, k = 3) | CUSUM |  | V3a | 1000 | 0,0910 [0,0739 ; 0,1106] (0,0990) | 10 / 4, 1 | 0,0410 [0,0296 ; 0,0552] (0,0475) | 4 / 2, 1 |
| H3 (H, k = 3) | CUSUM |  | V3b | 1000 | 0,0950 [0,0775 ; 0,1149] (0,0995) | 10 / 0, 0,0215 | 0,0400 [0,0287 ; 0,0541] (0,0510) | 4 / 3, 1 |
| H3 (H, k = 3) | CUSUM |  | V3h | 1000 | 0,0850 [0,0685 ; 0,1040] (0,0990) | 0 / 0, 1 | 0,0370 [0,0262 ; 0,0506] (0,0470) | 0 / 2, 1 |
| H3 (H, k = 3) | Grubbs |  | V1 | 1000 | 0,1900 [0,1661 ; 0,2157] (0,0835) | — | 0,1090 [0,0904 ; 0,1300] (0,0415) | — |
| H3 (H, k = 3) | Grubbs |  | V3a | 1000 | 0,1660 [0,1434 ; 0,1905] (0,0835) | 6 / 30, 0,00118 | 0,0900 [0,0730 ; 0,1095] (0,0400) | 3 / 22, 0,00282 |
| H3 (H, k = 3) | Grubbs |  | V3b | 1000 | 0,1720 [0,1491 ; 0,1968] (0,0845) | 6 / 24, 0,0172 | 0,0910 [0,0739 ; 0,1106] (0,0430) | 4 / 22, 0,00907 |
| H3 (H, k = 3) | Grubbs |  | V3h | 1000 | 0,1960 [0,1718 ; 0,2220] (0,1000) | 6 / 0, 0,531 | 0,1130 [0,0940 ; 0,1343] (0,0515) | 4 / 0, 1 |
| H3 (H, k = 3) | Lillie |  | V1 | 1000 | 0,1270 [0,1070 ; 0,1492] (0,0880) | — | 0,0720 [0,0568 ; 0,0898] (0,0480) | — |
| H3 (H, k = 3) | Lillie |  | V3a | 1000 | 0,1230 [0,1033 ; 0,1450] (0,0875) | 3 / 7, 1 | 0,0700 [0,0550 ; 0,0876] (0,0465) | 4 / 6, 1 |
| H3 (H, k = 3) | Lillie |  | V3b | 1000 | 0,1230 [0,1033 ; 0,1450] (0,0860) | 2 / 6, 1 | 0,0670 [0,0523 ; 0,0843] (0,0435) | 3 / 8, 1 |
| H3 (H, k = 3) | Lillie |  | V3h | 1000 | 0,1280 [0,1079 ; 0,1503] (0,0920) | 1 / 0, 1 | 0,0730 [0,0577 ; 0,0909] (0,0505) | 1 / 0, 1 |
| H3 (H, k = 3) | Intercept |  | V1 | 1000 | 0,1070 [0,0885 ; 0,1278] (0,0975) | — | 0,0490 [0,0365 ; 0,0643] (0,0535) | — |
| H3 (H, k = 3) | Intercept |  | V3a | 1000 | 0,1200 [0,1005 ; 0,1418] (0,1035) | 18 / 5, 0,117 | 0,0620 [0,0479 ; 0,0788] (0,0540) | 16 / 3, 0,0531 |
| H3 (H, k = 3) | Intercept |  | V3b | 1000 | 0,1230 [0,1033 ; 0,1450] (0,0995) | 17 / 1, 0,00174 | 0,0640 [0,0496 ; 0,0810] (0,0560) | 19 / 4, 0,0312 |
| H3 (H, k = 3) | Intercept |  | V3h | 1000 | 0,1060 [0,0876 ; 0,1268] (0,0950) | 0 / 1, 1 | 0,0470 [0,0347 ; 0,0620] (0,0520) | 0 / 2, 1 |
| H3 (H, k = 3) | RESET |  | V1 | 1000 | 0,2330 [0,2071 ; 0,2605] (0,0830) | — | 0,1450 [0,1237 ; 0,1684] (0,0325) | — |
| H3 (H, k = 3) | RESET |  | V3a | 1000 | 0,1900 [0,1661 ; 0,2157] (0,0855) | 13 / 56, 3,03e-06 | 0,1070 [0,0885 ; 0,1278] (0,0435) | 7 / 45, 1,33e-06 |
| H3 (H, k = 3) | RESET |  | V3b | 1000 | 0,1930 [0,1690 ; 0,2189] (0,0865) | 14 / 54, 2e-05 | 0,1110 [0,0922 ; 0,1321] (0,0440) | 7 / 41, 1,19e-05 |
| H3 (H, k = 3) | RESET |  | V3h | 1000 | 0,2340 [0,2081 ; 0,2615] (0,0755) | 1 / 0, 1 | 0,1450 [0,1237 ; 0,1684] (0,0350) | 0 / 0, 1 |
| H3 (H, k = 3) | BP | oui | V1 | 1000 | 0,2800 [0,2524 ; 0,3089] (0,0850) | — | 0,1910 [0,1671 ; 0,2168] (0,0370) | — |
| H3 (H, k = 3) | BP | oui | V3a | 1000 | 0,2010 [0,1766 ; 0,2272] (0,0770) | 10 / 89, 1,16e-15 | 0,1160 [0,0968 ; 0,1375] (0,0365) | 6 / 81, 1,48e-16 |
| H3 (H, k = 3) | BP | oui | V3b | 1000 | 0,2050 [0,1804 ; 0,2314] (0,0780) | 9 / 84, 4,34e-15 | 0,1080 [0,0894 ; 0,1289] (0,0380) | 4 / 87, 4,97e-20 |
| H3 (H, k = 3) | BP | oui | V3h | 1000 | 0,2890 [0,2611 ; 0,3182] (0,1095) | 9 / 0, 0,0859 | 0,1950 [0,1709 ; 0,2209] (0,0490) | 4 / 0, 1 |
| H3 (H, k = 3) | BP79 | oui | V1 | 1000 | 0,3000 [0,2717 ; 0,3295] (0,0755) | — | 0,2070 [0,1823 ; 0,2335] (0,0365) | — |
| H3 (H, k = 3) | BP79 | oui | V3a | 1000 | 0,2220 [0,1966 ; 0,2491] (0,0680) | 10 / 88, 1,99e-15 | 0,1370 [0,1163 ; 0,1599] (0,0345) | 3 / 73, 4,26e-17 |
| H3 (H, k = 3) | BP79 | oui | V3b | 1000 | 0,2230 [0,1975 ; 0,2501] (0,0685) | 8 / 85, 4,76e-16 | 0,1380 [0,1172 ; 0,1609] (0,0355) | 3 / 72, 7,82e-17 |
| H3 (H, k = 3) | BP79 | oui | V3h | 1000 | 0,3080 [0,2795 ; 0,3376] (0,0965) | 8 / 0, 0,164 | 0,2100 [0,1851 ; 0,2366] (0,0485) | 3 / 0, 1 |
| H3 (H, k = 3) | White | oui | V1 | 1000 | 0,2600 [0,2331 ; 0,2884] (0,0880) | — | 0,1610 [0,1387 ; 0,1853] (0,0400) | — |
| H3 (H, k = 3) | White | oui | V3a | 1000 | 0,1950 [0,1709 ; 0,2209] (0,0825) | 2 / 67, 1,8e-16 | 0,1050 [0,0867 ; 0,1257] (0,0360) | 4 / 60, 1,47e-12 |
| H3 (H, k = 3) | White | oui | V3b | 1000 | 0,1930 [0,1690 ; 0,2189] (0,0810) | 2 / 69, 4,76e-17 | 0,1090 [0,0904 ; 0,1300] (0,0360) | 6 / 58, 1,81e-10 |
| H3 (H, k = 3) | White | oui | V3h | 1000 | 0,2590 [0,2321 ; 0,2873] (0,0890) | 0 / 1, 1 | 0,1640 [0,1416 ; 0,1884] (0,0420) | 3 / 0, 1 |
| H3 (H, k = 3) | GQ | oui | V1 | 1000 | 0,1650 [0,1425 ; 0,1895] (0,0545) | — | 0,0900 [0,0730 ; 0,1095] (0,0290) | — |
| H3 (H, k = 3) | GQ | oui | V3a | 1000 | 0,1340 [0,1135 ; 0,1567] (0,1020) | 39 / 70, 0,0347 | 0,0750 [0,0594 ; 0,0931] (0,0485) | 22 / 37, 0,459 |
| H3 (H, k = 3) | GQ | oui | V3b | 1000 | 0,1380 [0,1172 ; 0,1609] (0,1000) | 42 / 69, 0,106 | 0,0770 [0,0612 ; 0,0953] (0,0495) | 24 / 37, 0,99 |
| H3 (H, k = 3) | GQ | oui | V3h | 1000 | 0,1710 [0,1482 ; 0,1958] (0,0790) | 6 / 0, 0,531 | 0,0930 [0,0757 ; 0,1127] (0,0405) | 3 / 0, 1 |
| H3 (H, k = 3) | BF | oui | V1 | 1000 | 0,1820 [0,1585 ; 0,2073] (0,0860) | — | 0,0940 [0,0766 ; 0,1138] (0,0455) | — |
| H3 (H, k = 3) | BF | oui | V3a | 1000 | 0,1390 [0,1181 ; 0,1620] (0,0865) | 8 / 51, 1,72e-07 | 0,0730 [0,0577 ; 0,0909] (0,0445) | 6 / 27, 0,00519 |
| H3 (H, k = 3) | BF | oui | V3b | 1000 | 0,1440 [0,1228 ; 0,1673] (0,0875) | 8 / 46, 2,63e-06 | 0,0740 [0,0585 ; 0,0920] (0,0455) | 6 / 26, 0,00907 |
| H3 (H, k = 3) | BF | oui | V3h | 1000 | 0,1900 [0,1661 ; 0,2157] (0,1095) | 8 / 0, 0,164 | 0,1000 [0,0821 ; 0,1203] (0,0565) | 6 / 0, 0,688 |
| H3 (H, k = 3) | Smirnov |  | V1 | 1000 | 0,0470 [0,0347 ; 0,0620] (0,0275) | — | 0,0470 [0,0347 ; 0,0620] (0,0275) | — |
| H3 (H, k = 3) | Smirnov |  | V3a | 1000 | 0,0480 [0,0356 ; 0,0631] (0,0290) | 1 / 0, 1 | 0,0470 [0,0347 ; 0,0620] (0,0275) | 0 / 0, 1 |
| H3 (H, k = 3) | Smirnov |  | V3b | 1000 | 0,0470 [0,0347 ; 0,0620] (0,0275) | 0 / 0, 1 | 0,0470 [0,0347 ; 0,0620] (0,0275) | 0 / 0, 1 |
| H3 (H, k = 3) | Smirnov |  | V3h | 1000 | 0,0470 [0,0347 ; 0,0620] (0,0275) | 0 / 0, 1 | 0,0470 [0,0347 ; 0,0620] (0,0275) | 0 / 0, 1 |
| H3 (H, k = 3) | LB2 |  | V1 | 1000 | 0,1030 [0,0849 ; 0,1235] (0,1065) | — | 0,0500 [0,0373 ; 0,0654] (0,0530) | — |
| H3 (H, k = 3) | LB2 |  | V3a | 1000 | 0,0900 [0,0730 ; 0,1095] (0,1005) | 3 / 16, 0,0354 | 0,0420 [0,0304 ; 0,0564] (0,0545) | 3 / 11, 0,459 |
| H3 (H, k = 3) | LB2 |  | V3b | 1000 | 0,0920 [0,0748 ; 0,1116] (0,0980) | 2 / 13, 0,0665 | 0,0440 [0,0321 ; 0,0586] (0,0540) | 3 / 9, 1 |
| H3 (H, k = 3) | LB2 |  | V3h | 1000 | 0,1030 [0,0849 ; 0,1235] (0,1010) | 0 / 0, 1 | 0,0490 [0,0365 ; 0,0643] (0,0505) | 0 / 1, 1 |
| H3 (H, k = 3) | BP2 |  | V1 | 1000 | 0,1050 [0,0867 ; 0,1257] (0,1040) | — | 0,0480 [0,0356 ; 0,0631] (0,0530) | — |
| H3 (H, k = 3) | BP2 |  | V3a | 1000 | 0,0910 [0,0739 ; 0,1106] (0,1025) | 3 / 17, 0,0258 | 0,0410 [0,0296 ; 0,0552] (0,0550) | 1 / 8, 0,424 |
| H3 (H, k = 3) | BP2 |  | V3b | 1000 | 0,0920 [0,0748 ; 0,1116] (0,1015) | 3 / 16, 0,046 | 0,0410 [0,0296 ; 0,0552] (0,0560) | 3 / 10, 0,831 |
| H3 (H, k = 3) | BP2 |  | V3h | 1000 | 0,1040 [0,0858 ; 0,1246] (0,1025) | 0 / 1, 1 | 0,0480 [0,0356 ; 0,0631] (0,0510) | 1 / 1, 1 |
| H3 (H, k = 3) | Runs |  | V1 | 1000 | 0,0700 [0,0550 ; 0,0876] (0,0635) | — | 0,0100 [0,0048 ; 0,0183] (0,0075) | — |
| H3 (H, k = 3) | Runs |  | V3a | 1000 | 0,0680 [0,0532 ; 0,0854] (0,0610) | 0 / 2, 1 | 0,0190 [0,0115 ; 0,0295] (0,0145) | 11 / 2, 0,225 |
| H3 (H, k = 3) | Runs |  | V3b | 1000 | 0,0700 [0,0550 ; 0,0876] (0,0635) | 0 / 0, 1 | 0,0140 [0,0077 ; 0,0234] (0,0095) | 9 / 5, 1 |
| H3 (H, k = 3) | Runs |  | V3h | 1000 | 0,0700 [0,0550 ; 0,0876] (0,0635) | 0 / 0, 1 | 0,0100 [0,0048 ; 0,0183] (0,0065) | 0 / 0, 1 |
| H3 (H, k = 3) | MK |  | V1 | 1000 | 0,0300 [0,0203 ; 0,0426] (0,0650) | — | 0,0080 [0,0035 ; 0,0157] (0,0290) | — |
| H3 (H, k = 3) | MK |  | V3a | 1000 | 0,0480 [0,0356 ; 0,0631] (0,0715) | 25 / 7, 0,0231 | 0,0180 [0,0107 ; 0,0283] (0,0355) | 12 / 2, 0,181 |
| H3 (H, k = 3) | MK |  | V3b | 1000 | 0,0430 [0,0313 ; 0,0575] (0,0755) | 21 / 8, 0,169 | 0,0190 [0,0115 ; 0,0295] (0,0375) | 12 / 1, 0,0479 |
| H3 (H, k = 3) | MK |  | V3h | 1000 | 0,0270 [0,0179 ; 0,0390] (0,0635) | 0 / 3, 1 | 0,0080 [0,0035 ; 0,0157] (0,0295) | 0 / 0, 1 |
| H3 (H, k = 3) | SpearVol |  | V1 | 1000 | 0,1050 [0,0867 ; 0,1257] (0,0965) | — | 0,0460 [0,0339 ; 0,0609] (0,0505) | — |
| H3 (H, k = 3) | SpearVol |  | V3a | 1000 | 0,1130 [0,0940 ; 0,1343] (0,1020) | 14 / 6, 0,461 | 0,0530 [0,0399 ; 0,0688] (0,0470) | 8 / 1, 0,424 |
| H3 (H, k = 3) | SpearVol |  | V3b | 1000 | 0,1100 [0,0913 ; 0,1311] (0,1020) | 11 / 6, 1 | 0,0540 [0,0408 ; 0,0699] (0,0530) | 9 / 1, 0,255 |
| H3 (H, k = 3) | SpearVol |  | V3h | 1000 | 0,1020 [0,0839 ; 0,1224] (0,0975) | 0 / 3, 1 | 0,0450 [0,0330 ; 0,0598] (0,0515) | 0 / 1, 1 |
| H3 (H, k = 3) | SpearTps |  | V1 | 1000 | 0,0490 [0,0365 ; 0,0643] (0,0885) | — | 0,0170 [0,0099 ; 0,0271] (0,0390) | — |
| H3 (H, k = 3) | SpearTps |  | V3a | 1000 | 0,0680 [0,0532 ; 0,0854] (0,0845) | 27 / 8, 0,0225 | 0,0250 [0,0162 ; 0,0367] (0,0420) | 12 / 4, 0,459 |
| H3 (H, k = 3) | SpearTps |  | V3b | 1000 | 0,0680 [0,0532 ; 0,0854] (0,0875) | 23 / 4, 0,00497 | 0,0240 [0,0154 ; 0,0355] (0,0445) | 15 / 8, 1 |
| H3 (H, k = 3) | SpearTps |  | V3h | 1000 | 0,0480 [0,0356 ; 0,0631] (0,0825) | 0 / 1, 1 | 0,0140 [0,0077 ; 0,0234] (0,0405) | 0 / 3, 1 |
| H3 (H, k = 3) | DAgo |  | V1 | 1000 | 0,1690 [0,1463 ; 0,1937] (0,0815) | — | 0,1030 [0,0849 ; 0,1235] (0,0400) | — |
| H3 (H, k = 3) | DAgo |  | V3a | 1000 | 0,1510 [0,1294 ; 0,1747] (0,0810) | 4 / 22, 0,00747 | 0,0860 [0,0694 ; 0,1051] (0,0395) | 2 / 19, 0,00376 |
| H3 (H, k = 3) | DAgo |  | V3b | 1000 | 0,1490 [0,1275 ; 0,1726] (0,0810) | 7 / 27, 0,0107 | 0,0850 [0,0685 ; 0,1040] (0,0415) | 1 / 19, 0,000721 |
| H3 (H, k = 3) | DAgo |  | V3h | 1000 | 0,1760 [0,1529 ; 0,2010] (0,0985) | 7 / 0, 0,297 | 0,1040 [0,0858 ; 0,1246] (0,0510) | 1 / 0, 1 |
| H3 (H, k = 3) | CoxStuart |  | V1 | 1000 | 0,0000 [0,0000 ; 0,0037] (0,0000) | — | 0,0000 [0,0000 ; 0,0037] (0,0000) | — |
| H3 (H, k = 3) | CoxStuart |  | V3a | 1000 | 0,0020 [0,0002 ; 0,0072] (0,0030) | 2 / 0, 1 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 |
| H3 (H, k = 3) | CoxStuart |  | V3b | 1000 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 |
| H3 (H, k = 3) | CoxStuart |  | V3h | 1000 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 |
| H3 (H, k = 3) | DWr |  | V1 | 1000 | 0,0880 [0,0712 ; 0,1073] (0,0920) | — | 0,0440 [0,0321 ; 0,0586] (0,0455) | — |
| H3 (H, k = 3) | DWr |  | V3a | 1000 | 0,0880 [0,0712 ; 0,1073] (0,0965) | 20 / 20, 1 | 0,0500 [0,0373 ; 0,0654] (0,0560) | 17 / 11, 1 |
| H3 (H, k = 3) | DWr |  | V3b | 1000 | 0,0860 [0,0694 ; 0,1051] (0,1010) | 20 / 22, 1 | 0,0460 [0,0339 ; 0,0609] (0,0575) | 13 / 11, 1 |
| H3 (H, k = 3) | DWr |  | V3h | 1000 | 0,0910 [0,0739 ; 0,1106] (0,1000) | 3 / 0, 1 | 0,0460 [0,0339 ; 0,0609] (0,0515) | 2 / 0, 1 |
| H3 (H, k = 3) | LB1r |  | V1 | 1000 | 0,0970 [0,0794 ; 0,1170] (0,1035) | — | 0,0460 [0,0339 ; 0,0609] (0,0525) | — |
| H3 (H, k = 3) | LB1r |  | V3a | 1000 | 0,0880 [0,0712 ; 0,1073] (0,1105) | 4 / 13, 0,245 | 0,0420 [0,0304 ; 0,0564] (0,0480) | 3 / 7, 1 |
| H3 (H, k = 3) | LB1r |  | V3b | 1000 | 0,0880 [0,0712 ; 0,1073] (0,1105) | 4 / 13, 0,245 | 0,0440 [0,0321 ; 0,0586] (0,0505) | 5 / 7, 1 |
| H3 (H, k = 3) | LB1r |  | V3h | 1000 | 0,1000 [0,0821 ; 0,1203] (0,1130) | 3 / 0, 1 | 0,0480 [0,0356 ; 0,0631] (0,0545) | 2 / 0, 1 |
| H3 (H, k = 3) | Runsr |  | V1 | 1000 | 0,0710 [0,0559 ; 0,0887] (0,0610) | — | 0,0070 [0,0028 ; 0,0144] (0,0105) | — |
| H3 (H, k = 3) | Runsr |  | V3a | 1000 | 0,0680 [0,0532 ; 0,0854] (0,0585) | 0 / 3, 1 | 0,0180 [0,0107 ; 0,0283] (0,0145) | 13 / 2, 0,0812 |
| H3 (H, k = 3) | Runsr |  | V3b | 1000 | 0,0710 [0,0559 ; 0,0887] (0,0610) | 0 / 0, 1 | 0,0130 [0,0069 ; 0,0221] (0,0105) | 9 / 3, 1 |
| H3 (H, k = 3) | Runsr |  | V3h | 1000 | 0,0710 [0,0559 ; 0,0887] (0,0610) | 0 / 0, 1 | 0,0070 [0,0028 ; 0,0144] (0,0090) | 0 / 0, 1 |
| H3 (H, k = 3) | supFr |  | V1 | 1000 | 0,0640 [0,0496 ; 0,0810] (0,1010) | — | 0,0240 [0,0154 ; 0,0355] (0,0490) | — |
| H3 (H, k = 3) | supFr |  | V3a | 1000 | 0,0880 [0,0712 ; 0,1073] (0,1020) | 30 / 6, 0,00118 | 0,0340 [0,0237 ; 0,0472] (0,0510) | 13 / 3, 0,277 |
| H3 (H, k = 3) | supFr |  | V3b | 1000 | 0,0870 [0,0703 ; 0,1062] (0,1040) | 29 / 6, 0,00199 | 0,0360 [0,0253 ; 0,0495] (0,0535) | 15 / 3, 0,098 |
| H3 (H, k = 3) | supFr |  | V3h | 1000 | 0,0650 [0,0505 ; 0,0821] (0,1045) | 1 / 0, 1 | 0,0240 [0,0154 ; 0,0355] (0,0510) | 0 / 0, 1 |
| H3 (H, k = 3) | CUSUMr |  | V1 | 1000 | 0,0860 [0,0694 ; 0,1051] (0,0995) | — | 0,0370 [0,0262 ; 0,0506] (0,0505) | — |
| H3 (H, k = 3) | CUSUMr |  | V3a | 1000 | 0,0940 [0,0766 ; 0,1138] (0,1020) | 9 / 1, 0,15 | 0,0390 [0,0279 ; 0,0529] (0,0500) | 4 / 2, 1 |
| H3 (H, k = 3) | CUSUMr |  | V3b | 1000 | 0,0930 [0,0757 ; 0,1127] (0,0995) | 8 / 1, 0,234 | 0,0410 [0,0296 ; 0,0552] (0,0505) | 7 / 3, 1 |
| H3 (H, k = 3) | CUSUMr |  | V3h | 1000 | 0,0860 [0,0694 ; 0,1051] (0,0990) | 0 / 0, 1 | 0,0350 [0,0245 ; 0,0483] (0,0475) | 0 / 2, 1 |
| H3 (H, k = 3) | Grubbsr |  | V1 | 1000 | 0,1520 [0,1303 ; 0,1758] (0,0845) | — | 0,0740 [0,0585 ; 0,0920] (0,0390) | — |
| H3 (H, k = 3) | Grubbsr |  | V3a | 1000 | 0,1560 [0,1340 ; 0,1800] (0,0870) | 10 / 6, 1 | 0,0820 [0,0657 ; 0,1008] (0,0390) | 10 / 2, 0,424 |
| H3 (H, k = 3) | Grubbsr |  | V3b | 1000 | 0,1570 [0,1350 ; 0,1811] (0,0845) | 12 / 7, 1 | 0,0780 [0,0621 ; 0,0964] (0,0410) | 9 / 5, 1 |
| H3 (H, k = 3) | Grubbsr |  | V3h | 1000 | 0,1540 [0,1322 ; 0,1779] (0,0985) | 2 / 0, 1 | 0,0750 [0,0594 ; 0,0931] (0,0485) | 1 / 0, 1 |
| C3 (C, λ = 3) | AD |  | V1 | 1000 | 0,1860 [0,1623 ; 0,2115] (0,1020) | — | 0,0990 [0,0812 ; 0,1192] (0,0450) | — |
| C3 (C, λ = 3) | AD |  | V3a | 1000 | 0,1850 [0,1614 ; 0,2105] (0,1000) | 4 / 5, 1 | 0,0960 [0,0785 ; 0,1160] (0,0435) | 3 / 6, 1 |
| C3 (C, λ = 3) | AD |  | V3b | 1000 | 0,1880 [0,1642 ; 0,2136] (0,1000) | 6 / 4, 1 | 0,0960 [0,0785 ; 0,1160] (0,0420) | 1 / 4, 1 |
| C3 (C, λ = 3) | AD |  | V3h | 1000 | 0,1870 [0,1633 ; 0,2126] (0,1020) | 1 / 0, 1 | 0,0990 [0,0812 ; 0,1192] (0,0450) | 0 / 0, 1 |
| C3 (C, λ = 3) | CvM |  | V1 | 1000 | 0,1640 [0,1416 ; 0,1884] (0,0970) | — | 0,0990 [0,0812 ; 0,1192] (0,0465) | — |
| C3 (C, λ = 3) | CvM |  | V3a | 1000 | 0,1690 [0,1463 ; 0,1937] (0,0985) | 7 / 2, 1 | 0,1020 [0,0839 ; 0,1224] (0,0465) | 9 / 6, 1 |
| C3 (C, λ = 3) | CvM |  | V3b | 1000 | 0,1690 [0,1463 ; 0,1937] (0,0955) | 6 / 1, 1 | 0,1040 [0,0858 ; 0,1246] (0,0465) | 9 / 4, 1 |
| C3 (C, λ = 3) | CvM |  | V3h | 1000 | 0,1640 [0,1416 ; 0,1884] (0,0935) | 1 / 1, 1 | 0,0970 [0,0794 ; 0,1170] (0,0470) | 0 / 2, 1 |
| C3 (C, λ = 3) | KS |  | V1 | 1000 | 0,1610 [0,1387 ; 0,1853] (0,0900) | — | 0,0860 [0,0694 ; 0,1051] (0,0460) | — |
| C3 (C, λ = 3) | KS |  | V3a | 1000 | 0,1600 [0,1378 ; 0,1842] (0,0885) | 5 / 6, 1 | 0,0880 [0,0712 ; 0,1073] (0,0425) | 7 / 5, 1 |
| C3 (C, λ = 3) | KS |  | V3b | 1000 | 0,1620 [0,1397 ; 0,1863] (0,0885) | 5 / 4, 1 | 0,0840 [0,0676 ; 0,1029] (0,0440) | 4 / 6, 1 |
| C3 (C, λ = 3) | KS |  | V3h | 1000 | 0,1610 [0,1387 ; 0,1853] (0,0885) | 0 / 0, 1 | 0,0860 [0,0694 ; 0,1051] (0,0455) | 0 / 0, 1 |
| C3 (C, λ = 3) | SW |  | V1 | 1000 | 0,2010 [0,1766 ; 0,2272] (0,0945) | — | 0,1250 [0,1051 ; 0,1471] (0,0445) | — |
| C3 (C, λ = 3) | SW |  | V3a | 1000 | 0,1940 [0,1699 ; 0,2199] (0,0925) | 1 / 8, 0,391 | 0,1190 [0,0996 ; 0,1407] (0,0450) | 3 / 9, 1 |
| C3 (C, λ = 3) | SW |  | V3b | 1000 | 0,1970 [0,1728 ; 0,2230] (0,0915) | 2 / 6, 1 | 0,1140 [0,0950 ; 0,1353] (0,0455) | 2 / 13, 0,0886 |
| C3 (C, λ = 3) | SW |  | V3h | 1000 | 0,2010 [0,1766 ; 0,2272] (0,0960) | 0 / 0, 1 | 0,1260 [0,1061 ; 0,1482] (0,0460) | 1 / 0, 1 |
| C3 (C, λ = 3) | SF | oui | V1 | 1000 | 0,2560 [0,2292 ; 0,2842] (0,0850) | — | 0,1530 [0,1312 ; 0,1768] (0,0460) | — |
| C3 (C, λ = 3) | SF | oui | V3a | 1000 | 0,2320 [0,2062 ; 0,2594] (0,0830) | 3 / 27, 0,000185 | 0,1410 [0,1200 ; 0,1641] (0,0405) | 3 / 15, 0,121 |
| C3 (C, λ = 3) | SF | oui | V3b | 1000 | 0,2340 [0,2081 ; 0,2615] (0,0800) | 4 / 26, 0,00131 | 0,1460 [0,1247 ; 0,1694] (0,0405) | 4 / 11, 1 |
| C3 (C, λ = 3) | SF | oui | V3h | 1000 | 0,2600 [0,2331 ; 0,2884] (0,0925) | 4 / 0, 1 | 0,1550 [0,1331 ; 0,1789] (0,0490) | 2 / 0, 1 |
| C3 (C, λ = 3) | JB | oui | V1 | 1000 | 0,3030 [0,2746 ; 0,3325] (0,0850) | — | 0,1990 [0,1747 ; 0,2251] (0,0405) | — |
| C3 (C, λ = 3) | JB | oui | V3a | 1000 | 0,2800 [0,2524 ; 0,3089] (0,0855) | 7 / 30, 0,00363 | 0,1680 [0,1453 ; 0,1926] (0,0400) | 8 / 39, 0,000122 |
| C3 (C, λ = 3) | JB | oui | V3b | 1000 | 0,2840 [0,2562 ; 0,3131] (0,0845) | 8 / 27, 0,0357 | 0,1760 [0,1529 ; 0,2010] (0,0425) | 8 / 31, 0,00588 |
| C3 (C, λ = 3) | JB | oui | V3h | 1000 | 0,3110 [0,2824 ; 0,3407] (0,1020) | 8 / 0, 0,117 | 0,2070 [0,1823 ; 0,2335] (0,0490) | 8 / 0, 0,117 |
| C3 (C, λ = 3) | DW |  | V1 | 1000 | 0,0730 [0,0577 ; 0,0909] (0,1025) | — | 0,0250 [0,0162 ; 0,0367] (0,0480) | — |
| C3 (C, λ = 3) | DW |  | V3a | 1000 | 0,0730 [0,0577 ; 0,0909] (0,1030) | 12 / 12, 1 | 0,0330 [0,0228 ; 0,0460] (0,0540) | 11 / 3, 0,803 |
| C3 (C, λ = 3) | DW |  | V3b | 1000 | 0,0760 [0,0603 ; 0,0942] (0,1060) | 17 / 14, 1 | 0,0320 [0,0220 ; 0,0449] (0,0535) | 11 / 4, 1 |
| C3 (C, λ = 3) | DW |  | V3h | 1000 | 0,0780 [0,0621 ; 0,0964] (0,1110) | 5 / 0, 0,812 | 0,0310 [0,0212 ; 0,0437] (0,0535) | 6 / 0, 0,438 |
| C3 (C, λ = 3) | LB1 |  | V1 | 1000 | 0,0700 [0,0550 ; 0,0876] (0,1090) | — | 0,0270 [0,0179 ; 0,0390] (0,0530) | — |
| C3 (C, λ = 3) | LB1 |  | V3a | 1000 | 0,0650 [0,0505 ; 0,0821] (0,1130) | 2 / 7, 1 | 0,0260 [0,0171 ; 0,0379] (0,0505) | 3 / 4, 1 |
| C3 (C, λ = 3) | LB1 |  | V3b | 1000 | 0,0670 [0,0523 ; 0,0843] (0,1110) | 3 / 6, 1 | 0,0270 [0,0179 ; 0,0390] (0,0500) | 4 / 4, 1 |
| C3 (C, λ = 3) | LB1 |  | V3h | 1000 | 0,0730 [0,0577 ; 0,0909] (0,1135) | 3 / 0, 1 | 0,0280 [0,0187 ; 0,0402] (0,0550) | 1 / 0, 1 |
| C3 (C, λ = 3) | supF |  | V1 | 1000 | 0,0740 [0,0585 ; 0,0920] (0,0935) | — | 0,0300 [0,0203 ; 0,0426] (0,0515) | — |
| C3 (C, λ = 3) | supF |  | V3a | 1000 | 0,0800 [0,0639 ; 0,0986] (0,0920) | 12 / 6, 1 | 0,0270 [0,0179 ; 0,0390] (0,0555) | 3 / 6, 1 |
| C3 (C, λ = 3) | supF |  | V3b | 1000 | 0,0760 [0,0603 ; 0,0942] (0,0905) | 11 / 9, 1 | 0,0300 [0,0203 ; 0,0426] (0,0555) | 4 / 4, 1 |
| C3 (C, λ = 3) | supF |  | V3h | 1000 | 0,0740 [0,0585 ; 0,0920] (0,0950) | 1 / 1, 1 | 0,0300 [0,0203 ; 0,0426] (0,0530) | 0 / 0, 1 |
| C3 (C, λ = 3) | CUSUM |  | V1 | 1000 | 0,0640 [0,0496 ; 0,0810] (0,0990) | — | 0,0290 [0,0195 ; 0,0414] (0,0480) | — |
| C3 (C, λ = 3) | CUSUM |  | V3a | 1000 | 0,0690 [0,0541 ; 0,0865] (0,0990) | 8 / 3, 1 | 0,0260 [0,0171 ; 0,0379] (0,0475) | 3 / 6, 1 |
| C3 (C, λ = 3) | CUSUM |  | V3b | 1000 | 0,0680 [0,0532 ; 0,0854] (0,0995) | 7 / 3, 1 | 0,0280 [0,0187 ; 0,0402] (0,0510) | 2 / 3, 1 |
| C3 (C, λ = 3) | CUSUM |  | V3h | 1000 | 0,0650 [0,0505 ; 0,0821] (0,0990) | 1 / 0, 1 | 0,0280 [0,0187 ; 0,0402] (0,0470) | 1 / 2, 1 |
| C3 (C, λ = 3) | Grubbs | oui | V1 | 1000 | 0,3340 [0,3048 ; 0,3642] (0,0835) | — | 0,2080 [0,1832 ; 0,2345] (0,0415) | — |
| C3 (C, λ = 3) | Grubbs | oui | V3a | 1000 | 0,3290 [0,2999 ; 0,3591] (0,0835) | 28 / 33, 1 | 0,1840 [0,1604 ; 0,2094] (0,0400) | 22 / 46, 0,0834 |
| C3 (C, λ = 3) | Grubbs | oui | V3b | 1000 | 0,3310 [0,3019 ; 0,3611] (0,0845) | 31 / 34, 1 | 0,1870 [0,1633 ; 0,2126] (0,0430) | 22 / 43, 0,225 |
| C3 (C, λ = 3) | Grubbs | oui | V3h | 1000 | 0,3650 [0,3351 ; 0,3957] (0,1000) | 31 / 0, 2,05e-08 | 0,2300 [0,2042 ; 0,2574] (0,0515) | 22 / 0, 1e-05 |
| C3 (C, λ = 3) | Lillie |  | V1 | 1000 | 0,1890 [0,1652 ; 0,2147] (0,0880) | — | 0,1050 [0,0867 ; 0,1257] (0,0480) | — |
| C3 (C, λ = 3) | Lillie |  | V3a | 1000 | 0,1790 [0,1557 ; 0,2042] (0,0875) | 2 / 12, 0,142 | 0,0990 [0,0812 ; 0,1192] (0,0465) | 2 / 8, 1 |
| C3 (C, λ = 3) | Lillie |  | V3b | 1000 | 0,1810 [0,1576 ; 0,2063] (0,0860) | 4 / 12, 0,845 | 0,1000 [0,0821 ; 0,1203] (0,0435) | 2 / 7, 1 |
| C3 (C, λ = 3) | Lillie |  | V3h | 1000 | 0,1920 [0,1680 ; 0,2178] (0,0920) | 3 / 0, 1 | 0,1070 [0,0885 ; 0,1278] (0,0505) | 2 / 0, 1 |
| C3 (C, λ = 3) | Intercept |  | V1 | 1000 | 0,1110 [0,0922 ; 0,1321] (0,0975) | — | 0,0570 [0,0435 ; 0,0732] (0,0535) | — |
| C3 (C, λ = 3) | Intercept |  | V3a | 1000 | 0,1270 [0,1070 ; 0,1492] (0,1035) | 24 / 8, 0,084 | 0,0540 [0,0408 ; 0,0699] (0,0540) | 5 / 8, 1 |
| C3 (C, λ = 3) | Intercept |  | V3b | 1000 | 0,1230 [0,1033 ; 0,1450] (0,0995) | 21 / 9, 0,513 | 0,0550 [0,0417 ; 0,0710] (0,0560) | 3 / 5, 1 |
| C3 (C, λ = 3) | Intercept |  | V3h | 1000 | 0,1040 [0,0858 ; 0,1246] (0,0950) | 1 / 8, 0,469 | 0,0530 [0,0399 ; 0,0688] (0,0520) | 0 / 4, 1 |
| C3 (C, λ = 3) | RESET |  | V1 | 1000 | 0,1230 [0,1033 ; 0,1450] (0,0830) | — | 0,0830 [0,0666 ; 0,1019] (0,0325) | — |
| C3 (C, λ = 3) | RESET |  | V3a | 1000 | 0,1240 [0,1042 ; 0,1460] (0,0855) | 25 / 24, 1 | 0,0730 [0,0577 ; 0,0909] (0,0435) | 11 / 21, 1 |
| C3 (C, λ = 3) | RESET |  | V3b | 1000 | 0,1250 [0,1051 ; 0,1471] (0,0865) | 25 / 23, 1 | 0,0780 [0,0621 ; 0,0964] (0,0440) | 14 / 19, 1 |
| C3 (C, λ = 3) | RESET |  | V3h | 1000 | 0,1200 [0,1005 ; 0,1418] (0,0755) | 0 / 3, 1 | 0,0860 [0,0694 ; 0,1051] (0,0350) | 3 / 0, 1 |
| C3 (C, λ = 3) | BP |  | V1 | 1000 | 0,1010 [0,0830 ; 0,1214] (0,0850) | — | 0,0520 [0,0391 ; 0,0676] (0,0370) | — |
| C3 (C, λ = 3) | BP |  | V3a | 1000 | 0,0770 [0,0612 ; 0,0953] (0,0770) | 15 / 39, 0,0269 | 0,0340 [0,0237 ; 0,0472] (0,0365) | 9 / 27, 0,0708 |
| C3 (C, λ = 3) | BP |  | V3b | 1000 | 0,0800 [0,0639 ; 0,0986] (0,0780) | 16 / 37, 0,0964 | 0,0310 [0,0212 ; 0,0437] (0,0380) | 9 / 30, 0,0202 |
| C3 (C, λ = 3) | BP |  | V3h | 1000 | 0,1170 [0,0977 ; 0,1386] (0,1095) | 16 / 0, 0,000549 | 0,0610 [0,0470 ; 0,0777] (0,0490) | 9 / 0, 0,0664 |
| C3 (C, λ = 3) | BP79 |  | V1 | 1000 | 0,1660 [0,1434 ; 0,1905] (0,0755) | — | 0,0960 [0,0785 ; 0,1160] (0,0365) | — |
| C3 (C, λ = 3) | BP79 |  | V3a | 1000 | 0,1330 [0,1126 ; 0,1556] (0,0680) | 18 / 51, 0,00175 | 0,0850 [0,0685 ; 0,1040] (0,0345) | 11 / 22, 0,962 |
| C3 (C, λ = 3) | BP79 |  | V3b | 1000 | 0,1350 [0,1144 ; 0,1578] (0,0685) | 18 / 49, 0,00408 | 0,0860 [0,0694 ; 0,1051] (0,0355) | 10 / 20, 1 |
| C3 (C, λ = 3) | BP79 |  | V3h | 1000 | 0,1840 [0,1604 ; 0,2094] (0,0965) | 18 / 0, 0,000145 | 0,1060 [0,0876 ; 0,1268] (0,0485) | 10 / 0, 0,0352 |
| C3 (C, λ = 3) | White |  | V1 | 1000 | 0,1130 [0,0940 ; 0,1343] (0,0880) | — | 0,0690 [0,0541 ; 0,0865] (0,0400) | — |
| C3 (C, λ = 3) | White |  | V3a | 1000 | 0,0900 [0,0730 ; 0,1095] (0,0825) | 5 / 28, 0,00139 | 0,0590 [0,0452 ; 0,0754] (0,0360) | 7 / 17, 0,831 |
| C3 (C, λ = 3) | White |  | V3b | 1000 | 0,0920 [0,0748 ; 0,1116] (0,0810) | 7 / 28, 0,0102 | 0,0590 [0,0452 ; 0,0754] (0,0360) | 7 / 17, 0,959 |
| C3 (C, λ = 3) | White |  | V3h | 1000 | 0,1150 [0,0959 ; 0,1364] (0,0890) | 3 / 1, 1 | 0,0730 [0,0577 ; 0,0909] (0,0420) | 4 / 0, 1 |
| C3 (C, λ = 3) | GQ |  | V1 | 1000 | 0,1270 [0,1070 ; 0,1492] (0,0545) | — | 0,0580 [0,0443 ; 0,0743] (0,0290) | — |
| C3 (C, λ = 3) | GQ |  | V3a | 1000 | 0,1540 [0,1322 ; 0,1779] (0,1020) | 77 / 50, 0,298 | 0,0910 [0,0739 ; 0,1106] (0,0485) | 58 / 25, 0,00757 |
| C3 (C, λ = 3) | GQ |  | V3b | 1000 | 0,1540 [0,1322 ; 0,1779] (0,1000) | 78 / 51, 0,326 | 0,0940 [0,0766 ; 0,1138] (0,0495) | 61 / 25, 0,00274 |
| C3 (C, λ = 3) | GQ |  | V3h | 1000 | 0,1580 [0,1359 ; 0,1821] (0,0790) | 31 / 0, 2,05e-08 | 0,0830 [0,0666 ; 0,1019] (0,0405) | 25 / 0, 1,31e-06 |
| C3 (C, λ = 3) | BF |  | V1 | 1000 | 0,0760 [0,0603 ; 0,0942] (0,0860) | — | 0,0230 [0,0146 ; 0,0343] (0,0455) | — |
| C3 (C, λ = 3) | BF |  | V3a | 1000 | 0,0660 [0,0514 ; 0,0832] (0,0865) | 12 / 22, 1 | 0,0270 [0,0179 ; 0,0390] (0,0445) | 9 / 5, 1 |
| C3 (C, λ = 3) | BF |  | V3b | 1000 | 0,0640 [0,0496 ; 0,0810] (0,0875) | 12 / 24, 0,848 | 0,0280 [0,0187 ; 0,0402] (0,0455) | 11 / 6, 1 |
| C3 (C, λ = 3) | BF |  | V3h | 1000 | 0,0880 [0,0712 ; 0,1073] (0,1095) | 12 / 0, 0,00781 | 0,0340 [0,0237 ; 0,0472] (0,0565) | 11 / 0, 0,0186 |
| C3 (C, λ = 3) | Smirnov |  | V1 | 1000 | 0,0210 [0,0130 ; 0,0319] (0,0275) | — | 0,0210 [0,0130 ; 0,0319] (0,0275) | — |
| C3 (C, λ = 3) | Smirnov |  | V3a | 1000 | 0,0220 [0,0138 ; 0,0331] (0,0290) | 1 / 0, 1 | 0,0210 [0,0130 ; 0,0319] (0,0275) | 0 / 0, 1 |
| C3 (C, λ = 3) | Smirnov |  | V3b | 1000 | 0,0210 [0,0130 ; 0,0319] (0,0275) | 0 / 0, 1 | 0,0210 [0,0130 ; 0,0319] (0,0275) | 0 / 0, 1 |
| C3 (C, λ = 3) | Smirnov |  | V3h | 1000 | 0,0210 [0,0130 ; 0,0319] (0,0275) | 0 / 0, 1 | 0,0210 [0,0130 ; 0,0319] (0,0275) | 0 / 0, 1 |
| C3 (C, λ = 3) | LB2 |  | V1 | 1000 | 0,0790 [0,0630 ; 0,0975] (0,1065) | — | 0,0390 [0,0279 ; 0,0529] (0,0530) | — |
| C3 (C, λ = 3) | LB2 |  | V3a | 1000 | 0,0800 [0,0639 ; 0,0986] (0,1005) | 12 / 11, 1 | 0,0330 [0,0228 ; 0,0460] (0,0545) | 4 / 10, 1 |
| C3 (C, λ = 3) | LB2 |  | V3b | 1000 | 0,0770 [0,0612 ; 0,0953] (0,0980) | 13 / 15, 1 | 0,0320 [0,0220 ; 0,0449] (0,0540) | 3 / 10, 1 |
| C3 (C, λ = 3) | LB2 |  | V3h | 1000 | 0,0790 [0,0630 ; 0,0975] (0,1010) | 0 / 0, 1 | 0,0380 [0,0270 ; 0,0518] (0,0505) | 0 / 1, 1 |
| C3 (C, λ = 3) | BP2 |  | V1 | 1000 | 0,0830 [0,0666 ; 0,1019] (0,1040) | — | 0,0310 [0,0212 ; 0,0437] (0,0530) | — |
| C3 (C, λ = 3) | BP2 |  | V3a | 1000 | 0,0720 [0,0568 ; 0,0898] (0,1025) | 2 / 13, 0,118 | 0,0310 [0,0212 ; 0,0437] (0,0550) | 4 / 4, 1 |
| C3 (C, λ = 3) | BP2 |  | V3b | 1000 | 0,0750 [0,0594 ; 0,0931] (0,1015) | 3 / 11, 0,803 | 0,0330 [0,0228 ; 0,0460] (0,0560) | 6 / 4, 1 |
| C3 (C, λ = 3) | BP2 |  | V3h | 1000 | 0,0820 [0,0657 ; 0,1008] (0,1025) | 0 / 1, 1 | 0,0320 [0,0220 ; 0,0449] (0,0510) | 1 / 0, 1 |
| C3 (C, λ = 3) | Runs |  | V1 | 1000 | 0,0560 [0,0426 ; 0,0721] (0,0635) | — | 0,0100 [0,0048 ; 0,0183] (0,0075) | — |
| C3 (C, λ = 3) | Runs |  | V3a | 1000 | 0,0520 [0,0391 ; 0,0676] (0,0610) | 0 / 4, 1 | 0,0170 [0,0099 ; 0,0271] (0,0145) | 8 / 1, 0,469 |
| C3 (C, λ = 3) | Runs |  | V3b | 1000 | 0,0560 [0,0426 ; 0,0721] (0,0635) | 0 / 0, 1 | 0,0110 [0,0055 ; 0,0196] (0,0095) | 6 / 5, 1 |
| C3 (C, λ = 3) | Runs |  | V3h | 1000 | 0,0560 [0,0426 ; 0,0721] (0,0635) | 0 / 0, 1 | 0,0110 [0,0055 ; 0,0196] (0,0065) | 1 / 0, 1 |
| C3 (C, λ = 3) | MK |  | V1 | 1000 | 0,0550 [0,0417 ; 0,0710] (0,0650) | — | 0,0210 [0,0130 ; 0,0319] (0,0290) | — |
| C3 (C, λ = 3) | MK |  | V3a | 1000 | 0,0570 [0,0435 ; 0,0732] (0,0715) | 20 / 18, 1 | 0,0290 [0,0195 ; 0,0414] (0,0355) | 13 / 5, 1 |
| C3 (C, λ = 3) | MK |  | V3b | 1000 | 0,0630 [0,0487 ; 0,0799] (0,0755) | 22 / 14, 1 | 0,0300 [0,0203 ; 0,0426] (0,0375) | 13 / 4, 0,785 |
| C3 (C, λ = 3) | MK |  | V3h | 1000 | 0,0560 [0,0426 ; 0,0721] (0,0635) | 1 / 0, 1 | 0,0190 [0,0115 ; 0,0295] (0,0295) | 0 / 2, 1 |
| C3 (C, λ = 3) | SpearVol |  | V1 | 1000 | 0,1090 [0,0904 ; 0,1300] (0,0965) | — | 0,0430 [0,0313 ; 0,0575] (0,0505) | — |
| C3 (C, λ = 3) | SpearVol |  | V3a | 1000 | 0,1150 [0,0959 ; 0,1364] (0,1020) | 11 / 5, 1 | 0,0580 [0,0443 ; 0,0743] (0,0470) | 18 / 3, 0,0283 |
| C3 (C, λ = 3) | SpearVol |  | V3b | 1000 | 0,1150 [0,0959 ; 0,1364] (0,1020) | 12 / 6, 1 | 0,0600 [0,0461 ; 0,0766] (0,0530) | 17 / 0, 0,000336 |
| C3 (C, λ = 3) | SpearVol |  | V3h | 1000 | 0,1080 [0,0894 ; 0,1289] (0,0975) | 0 / 1, 1 | 0,0430 [0,0313 ; 0,0575] (0,0515) | 0 / 0, 1 |
| C3 (C, λ = 3) | SpearTps |  | V1 | 1000 | 0,0810 [0,0648 ; 0,0997] (0,0885) | — | 0,0280 [0,0187 ; 0,0402] (0,0390) | — |
| C3 (C, λ = 3) | SpearTps |  | V3a | 1000 | 0,0800 [0,0639 ; 0,0986] (0,0845) | 12 / 13, 1 | 0,0360 [0,0253 ; 0,0495] (0,0420) | 15 / 7, 1 |
| C3 (C, λ = 3) | SpearTps |  | V3b | 1000 | 0,0830 [0,0666 ; 0,1019] (0,0875) | 14 / 12, 1 | 0,0360 [0,0253 ; 0,0495] (0,0445) | 13 / 5, 1 |
| C3 (C, λ = 3) | SpearTps |  | V3h | 1000 | 0,0770 [0,0612 ; 0,0953] (0,0825) | 0 / 4, 1 | 0,0280 [0,0187 ; 0,0402] (0,0405) | 1 / 1, 1 |
| C3 (C, λ = 3) | DAgo | oui | V1 | 1000 | 0,3020 [0,2737 ; 0,3315] (0,0815) | — | 0,1870 [0,1633 ; 0,2126] (0,0400) | — |
| C3 (C, λ = 3) | DAgo | oui | V3a | 1000 | 0,2840 [0,2562 ; 0,3131] (0,0810) | 18 / 36, 0,298 | 0,1650 [0,1425 ; 0,1895] (0,0395) | 7 / 29, 0,00656 |
| C3 (C, λ = 3) | DAgo | oui | V3b | 1000 | 0,2820 [0,2543 ; 0,3110] (0,0810) | 20 / 40, 0,216 | 0,1720 [0,1491 ; 0,1968] (0,0415) | 10 / 25, 0,283 |
| C3 (C, λ = 3) | DAgo | oui | V3h | 1000 | 0,3220 [0,2931 ; 0,3520] (0,0985) | 20 / 0, 3,81e-05 | 0,1960 [0,1718 ; 0,2220] (0,0510) | 9 / 0, 0,0664 |
| C3 (C, λ = 3) | CoxStuart |  | V1 | 1000 | 0,0000 [0,0000 ; 0,0037] (0,0000) | — | 0,0000 [0,0000 ; 0,0037] (0,0000) | — |
| C3 (C, λ = 3) | CoxStuart |  | V3a | 1000 | 0,0020 [0,0002 ; 0,0072] (0,0030) | 2 / 0, 1 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 |
| C3 (C, λ = 3) | CoxStuart |  | V3b | 1000 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 |
| C3 (C, λ = 3) | CoxStuart |  | V3h | 1000 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 |
| C3 (C, λ = 3) | DWr |  | V1 | 1000 | 0,0550 [0,0417 ; 0,0710] (0,0920) | — | 0,0250 [0,0162 ; 0,0367] (0,0455) | — |
| C3 (C, λ = 3) | DWr |  | V3a | 1000 | 0,0580 [0,0443 ; 0,0743] (0,0965) | 19 / 16, 1 | 0,0240 [0,0154 ; 0,0355] (0,0560) | 9 / 10, 1 |
| C3 (C, λ = 3) | DWr |  | V3b | 1000 | 0,0610 [0,0470 ; 0,0777] (0,1010) | 22 / 16, 1 | 0,0250 [0,0162 ; 0,0367] (0,0575) | 9 / 9, 1 |
| C3 (C, λ = 3) | DWr |  | V3h | 1000 | 0,0610 [0,0470 ; 0,0777] (0,1000) | 6 / 0, 0,438 | 0,0290 [0,0195 ; 0,0414] (0,0515) | 4 / 0, 1 |
| C3 (C, λ = 3) | LB1r |  | V1 | 1000 | 0,0610 [0,0470 ; 0,0777] (0,1035) | — | 0,0260 [0,0171 ; 0,0379] (0,0525) | — |
| C3 (C, λ = 3) | LB1r |  | V3a | 1000 | 0,0570 [0,0435 ; 0,0732] (0,1105) | 4 / 8, 1 | 0,0250 [0,0162 ; 0,0367] (0,0480) | 1 / 2, 1 |
| C3 (C, λ = 3) | LB1r |  | V3b | 1000 | 0,0610 [0,0470 ; 0,0777] (0,1105) | 7 / 7, 1 | 0,0240 [0,0154 ; 0,0355] (0,0505) | 0 / 2, 1 |
| C3 (C, λ = 3) | LB1r |  | V3h | 1000 | 0,0650 [0,0505 ; 0,0821] (0,1130) | 4 / 0, 1 | 0,0260 [0,0171 ; 0,0379] (0,0545) | 0 / 0, 1 |
| C3 (C, λ = 3) | Runsr |  | V1 | 1000 | 0,0550 [0,0417 ; 0,0710] (0,0610) | — | 0,0100 [0,0048 ; 0,0183] (0,0105) | — |
| C3 (C, λ = 3) | Runsr |  | V3a | 1000 | 0,0510 [0,0382 ; 0,0665] (0,0585) | 0 / 4, 1 | 0,0170 [0,0099 ; 0,0271] (0,0145) | 9 / 2, 0,72 |
| C3 (C, λ = 3) | Runsr |  | V3b | 1000 | 0,0550 [0,0417 ; 0,0710] (0,0610) | 0 / 0, 1 | 0,0110 [0,0055 ; 0,0196] (0,0105) | 7 / 6, 1 |
| C3 (C, λ = 3) | Runsr |  | V3h | 1000 | 0,0550 [0,0417 ; 0,0710] (0,0610) | 0 / 0, 1 | 0,0110 [0,0055 ; 0,0196] (0,0090) | 1 / 0, 1 |
| C3 (C, λ = 3) | supFr |  | V1 | 1000 | 0,0660 [0,0514 ; 0,0832] (0,1010) | — | 0,0330 [0,0228 ; 0,0460] (0,0490) | — |
| C3 (C, λ = 3) | supFr |  | V3a | 1000 | 0,0660 [0,0514 ; 0,0832] (0,1020) | 9 / 9, 1 | 0,0280 [0,0187 ; 0,0402] (0,0510) | 2 / 7, 1 |
| C3 (C, λ = 3) | supFr |  | V3b | 1000 | 0,0640 [0,0496 ; 0,0810] (0,1040) | 8 / 10, 1 | 0,0290 [0,0195 ; 0,0414] (0,0535) | 2 / 6, 1 |
| C3 (C, λ = 3) | supFr |  | V3h | 1000 | 0,0660 [0,0514 ; 0,0832] (0,1045) | 0 / 0, 1 | 0,0310 [0,0212 ; 0,0437] (0,0510) | 0 / 2, 1 |
| C3 (C, λ = 3) | CUSUMr |  | V1 | 1000 | 0,0620 [0,0479 ; 0,0788] (0,0995) | — | 0,0290 [0,0195 ; 0,0414] (0,0505) | — |
| C3 (C, λ = 3) | CUSUMr |  | V3a | 1000 | 0,0650 [0,0505 ; 0,0821] (0,1020) | 5 / 2, 1 | 0,0210 [0,0130 ; 0,0319] (0,0500) | 0 / 8, 0,121 |
| C3 (C, λ = 3) | CUSUMr |  | V3b | 1000 | 0,0620 [0,0479 ; 0,0788] (0,0995) | 3 / 3, 1 | 0,0280 [0,0187 ; 0,0402] (0,0505) | 1 / 2, 1 |
| C3 (C, λ = 3) | CUSUMr |  | V3h | 1000 | 0,0620 [0,0479 ; 0,0788] (0,0990) | 1 / 1, 1 | 0,0290 [0,0195 ; 0,0414] (0,0475) | 1 / 1, 1 |
| C3 (C, λ = 3) | Grubbsr | oui | V1 | 1000 | 0,4270 [0,3961 ; 0,4583] (0,0845) | — | 0,2920 [0,2640 ; 0,3213] (0,0390) | — |
| C3 (C, λ = 3) | Grubbsr | oui | V3a | 1000 | 0,4030 [0,3724 ; 0,4341] (0,0870) | 17 / 41, 0,038 | 0,2850 [0,2572 ; 0,3141] (0,0390) | 25 / 32, 1 |
| C3 (C, λ = 3) | Grubbsr | oui | V3b | 1000 | 0,4050 [0,3744 ; 0,4362] (0,0845) | 18 / 40, 0,0964 | 0,2820 [0,2543 ; 0,3110] (0,0410) | 24 / 34, 1 |
| C3 (C, λ = 3) | Grubbsr | oui | V3h | 1000 | 0,4420 [0,4109 ; 0,4734] (0,0985) | 15 / 0, 0,00104 | 0,3130 [0,2843 ; 0,3428] (0,0485) | 21 / 0, 1,91e-05 |
| C4 (C, λ = 4) | AD |  | V1 | 1000 | 0,3170 [0,2882 ; 0,3468] (0,1020) | — | 0,2080 [0,1832 ; 0,2345] (0,0450) | — |
| C4 (C, λ = 4) | AD |  | V3a | 1000 | 0,3230 [0,2941 ; 0,3530] (0,1000) | 8 / 2, 0,984 | 0,2090 [0,1842 ; 0,2355] (0,0435) | 5 / 4, 1 |
| C4 (C, λ = 4) | AD |  | V3b | 1000 | 0,3210 [0,2921 ; 0,3509] (0,1000) | 7 / 3, 1 | 0,2180 [0,1928 ; 0,2449] (0,0420) | 12 / 2, 0,142 |
| C4 (C, λ = 4) | AD |  | V3h | 1000 | 0,3180 [0,2892 ; 0,3479] (0,1020) | 1 / 0, 1 | 0,2080 [0,1832 ; 0,2345] (0,0450) | 0 / 0, 1 |
| C4 (C, λ = 4) | CvM |  | V1 | 1000 | 0,2580 [0,2311 ; 0,2863] (0,0970) | — | 0,1660 [0,1434 ; 0,1905] (0,0465) | — |
| C4 (C, λ = 4) | CvM |  | V3a | 1000 | 0,2610 [0,2340 ; 0,2894] (0,0985) | 8 / 5, 1 | 0,1700 [0,1472 ; 0,1947] (0,0465) | 9 / 5, 1 |
| C4 (C, λ = 4) | CvM |  | V3b | 1000 | 0,2640 [0,2369 ; 0,2925] (0,0955) | 7 / 1, 0,703 | 0,1720 [0,1491 ; 0,1968] (0,0465) | 10 / 4, 1 |
| C4 (C, λ = 4) | CvM |  | V3h | 1000 | 0,2580 [0,2311 ; 0,2863] (0,0935) | 0 / 0, 1 | 0,1650 [0,1425 ; 0,1895] (0,0470) | 0 / 1, 1 |
| C4 (C, λ = 4) | KS |  | V1 | 1000 | 0,2250 [0,1995 ; 0,2522] (0,0900) | — | 0,1560 [0,1340 ; 0,1800] (0,0460) | — |
| C4 (C, λ = 4) | KS |  | V3a | 1000 | 0,2270 [0,2014 ; 0,2542] (0,0885) | 7 / 5, 1 | 0,1520 [0,1303 ; 0,1758] (0,0425) | 2 / 6, 1 |
| C4 (C, λ = 4) | KS |  | V3b | 1000 | 0,2250 [0,1995 ; 0,2522] (0,0885) | 4 / 4, 1 | 0,1610 [0,1387 ; 0,1853] (0,0440) | 6 / 1, 1 |
| C4 (C, λ = 4) | KS |  | V3h | 1000 | 0,2240 [0,1985 ; 0,2511] (0,0885) | 0 / 1, 1 | 0,1560 [0,1340 ; 0,1800] (0,0455) | 1 / 1, 1 |
| C4 (C, λ = 4) | SW |  | V1 | 1000 | 0,3800 [0,3498 ; 0,4109] (0,0945) | — | 0,2810 [0,2533 ; 0,3100] (0,0445) | — |
| C4 (C, λ = 4) | SW |  | V3a | 1000 | 0,3720 [0,3420 ; 0,4028] (0,0925) | 3 / 11, 0,574 | 0,2760 [0,2485 ; 0,3048] (0,0450) | 3 / 8, 1 |
| C4 (C, λ = 4) | SW |  | V3b | 1000 | 0,3700 [0,3400 ; 0,4008] (0,0915) | 3 / 13, 0,234 | 0,2730 [0,2456 ; 0,3018] (0,0455) | 3 / 11, 0,516 |
| C4 (C, λ = 4) | SW |  | V3h | 1000 | 0,3800 [0,3498 ; 0,4109] (0,0960) | 1 / 1, 1 | 0,2810 [0,2533 ; 0,3100] (0,0460) | 0 / 0, 1 |
| C4 (C, λ = 4) | SF | oui | V1 | 1000 | 0,4570 [0,4258 ; 0,4885] (0,0850) | — | 0,3420 [0,3126 ; 0,3723] (0,0460) | — |
| C4 (C, λ = 4) | SF | oui | V3a | 1000 | 0,4410 [0,4099 ; 0,4724] (0,0830) | 5 / 21, 0,0449 | 0,3160 [0,2873 ; 0,3458] (0,0405) | 4 / 30, 0,000129 |
| C4 (C, λ = 4) | SF | oui | V3b | 1000 | 0,4400 [0,4089 ; 0,4714] (0,0800) | 8 / 25, 0,0728 | 0,3200 [0,2912 ; 0,3499] (0,0405) | 7 / 29, 0,00594 |
| C4 (C, λ = 4) | SF | oui | V3h | 1000 | 0,4630 [0,4317 ; 0,4945] (0,0925) | 6 / 0, 0,438 | 0,3460 [0,3165 ; 0,3764] (0,0490) | 4 / 0, 1 |
| C4 (C, λ = 4) | JB | oui | V1 | 1000 | 0,5300 [0,4985 ; 0,5613] (0,0850) | — | 0,4020 [0,3714 ; 0,4331] (0,0405) | — |
| C4 (C, λ = 4) | JB | oui | V3a | 1000 | 0,5030 [0,4715 ; 0,5344] (0,0855) | 6 / 33, 0,0003 | 0,3700 [0,3400 ; 0,4008] (0,0400) | 11 / 43, 0,00028 |
| C4 (C, λ = 4) | JB | oui | V3b | 1000 | 0,5090 [0,4775 ; 0,5404] (0,0845) | 7 / 28, 0,0102 | 0,3700 [0,3400 ; 0,4008] (0,0425) | 11 / 43, 0,000294 |
| C4 (C, λ = 4) | JB | oui | V3h | 1000 | 0,5370 [0,5055 ; 0,5683] (0,1020) | 7 / 0, 0,234 | 0,4130 [0,3823 ; 0,4442] (0,0490) | 11 / 0, 0,0176 |
| C4 (C, λ = 4) | DW |  | V1 | 1000 | 0,0700 [0,0550 ; 0,0876] (0,1025) | — | 0,0210 [0,0130 ; 0,0319] (0,0480) | — |
| C4 (C, λ = 4) | DW |  | V3a | 1000 | 0,0640 [0,0496 ; 0,0810] (0,1030) | 5 / 11, 1 | 0,0260 [0,0171 ; 0,0379] (0,0540) | 9 / 4, 1 |
| C4 (C, λ = 4) | DW |  | V3b | 1000 | 0,0680 [0,0532 ; 0,0854] (0,1060) | 9 / 11, 1 | 0,0280 [0,0187 ; 0,0402] (0,0535) | 9 / 2, 0,916 |
| C4 (C, λ = 4) | DW |  | V3h | 1000 | 0,0730 [0,0577 ; 0,0909] (0,1110) | 3 / 0, 1 | 0,0270 [0,0179 ; 0,0390] (0,0535) | 6 / 0, 0,438 |
| C4 (C, λ = 4) | LB1 |  | V1 | 1000 | 0,0580 [0,0443 ; 0,0743] (0,1090) | — | 0,0240 [0,0154 ; 0,0355] (0,0530) | — |
| C4 (C, λ = 4) | LB1 |  | V3a | 1000 | 0,0530 [0,0399 ; 0,0688] (0,1130) | 1 / 6, 1 | 0,0220 [0,0138 ; 0,0331] (0,0505) | 1 / 3, 1 |
| C4 (C, λ = 4) | LB1 |  | V3b | 1000 | 0,0540 [0,0408 ; 0,0699] (0,1110) | 3 / 7, 1 | 0,0230 [0,0146 ; 0,0343] (0,0500) | 4 / 5, 1 |
| C4 (C, λ = 4) | LB1 |  | V3h | 1000 | 0,0600 [0,0461 ; 0,0766] (0,1135) | 2 / 0, 1 | 0,0250 [0,0162 ; 0,0367] (0,0550) | 1 / 0, 1 |
| C4 (C, λ = 4) | supF |  | V1 | 1000 | 0,0750 [0,0594 ; 0,0931] (0,0935) | — | 0,0210 [0,0130 ; 0,0319] (0,0515) | — |
| C4 (C, λ = 4) | supF |  | V3a | 1000 | 0,0740 [0,0585 ; 0,0920] (0,0920) | 10 / 11, 1 | 0,0220 [0,0138 ; 0,0331] (0,0555) | 5 / 4, 1 |
| C4 (C, λ = 4) | supF |  | V3b | 1000 | 0,0800 [0,0639 ; 0,0986] (0,0905) | 13 / 8, 1 | 0,0250 [0,0162 ; 0,0367] (0,0555) | 8 / 4, 1 |
| C4 (C, λ = 4) | supF |  | V3h | 1000 | 0,0790 [0,0630 ; 0,0975] (0,0950) | 4 / 0, 1 | 0,0240 [0,0154 ; 0,0355] (0,0530) | 4 / 1, 1 |
| C4 (C, λ = 4) | CUSUM |  | V1 | 1000 | 0,0620 [0,0479 ; 0,0788] (0,0990) | — | 0,0200 [0,0123 ; 0,0307] (0,0480) | — |
| C4 (C, λ = 4) | CUSUM |  | V3a | 1000 | 0,0650 [0,0505 ; 0,0821] (0,0990) | 6 / 3, 1 | 0,0180 [0,0107 ; 0,0283] (0,0475) | 3 / 5, 1 |
| C4 (C, λ = 4) | CUSUM |  | V3b | 1000 | 0,0650 [0,0505 ; 0,0821] (0,0995) | 4 / 1, 1 | 0,0220 [0,0138 ; 0,0331] (0,0510) | 3 / 1, 1 |
| C4 (C, λ = 4) | CUSUM |  | V3h | 1000 | 0,0630 [0,0487 ; 0,0799] (0,0990) | 1 / 0, 1 | 0,0210 [0,0130 ; 0,0319] (0,0470) | 1 / 0, 1 |
| C4 (C, λ = 4) | Grubbs | oui | V1 | 1000 | 0,5760 [0,5447 ; 0,6069] (0,0835) | — | 0,4110 [0,3803 ; 0,4422] (0,0415) | — |
| C4 (C, λ = 4) | Grubbs | oui | V3a | 1000 | 0,5590 [0,5276 ; 0,5901] (0,0835) | 38 / 55, 1 | 0,3880 [0,3577 ; 0,4190] (0,0400) | 26 / 49, 0,169 |
| C4 (C, λ = 4) | Grubbs | oui | V3b | 1000 | 0,5650 [0,5336 ; 0,5960] (0,0845) | 37 / 48, 1 | 0,3880 [0,3577 ; 0,4190] (0,0430) | 23 / 46, 0,122 |
| C4 (C, λ = 4) | Grubbs | oui | V3h | 1000 | 0,6130 [0,5820 ; 0,6433] (0,1000) | 37 / 0, 3,2e-10 | 0,4340 [0,4030 ; 0,4654] (0,0515) | 23 / 0, 5,25e-06 |
| C4 (C, λ = 4) | Lillie |  | V1 | 1000 | 0,3150 [0,2863 ; 0,3448] (0,0880) | — | 0,2170 [0,1918 ; 0,2439] (0,0480) | — |
| C4 (C, λ = 4) | Lillie |  | V3a | 1000 | 0,3090 [0,2805 ; 0,3387] (0,0875) | 3 / 9, 1 | 0,2070 [0,1823 ; 0,2335] (0,0465) | 5 / 15, 0,424 |
| C4 (C, λ = 4) | Lillie |  | V3b | 1000 | 0,3070 [0,2785 ; 0,3366] (0,0860) | 4 / 12, 0,703 | 0,2040 [0,1794 ; 0,2303] (0,0435) | 5 / 18, 0,127 |
| C4 (C, λ = 4) | Lillie |  | V3h | 1000 | 0,3170 [0,2882 ; 0,3468] (0,0920) | 2 / 0, 1 | 0,2200 [0,1947 ; 0,2470] (0,0505) | 3 / 0, 1 |
| C4 (C, λ = 4) | Intercept |  | V1 | 1000 | 0,1040 [0,0858 ; 0,1246] (0,0975) | — | 0,0420 [0,0304 ; 0,0564] (0,0535) | — |
| C4 (C, λ = 4) | Intercept |  | V3a | 1000 | 0,1170 [0,0977 ; 0,1386] (0,1035) | 22 / 9, 0,353 | 0,0510 [0,0382 ; 0,0665] (0,0540) | 13 / 4, 0,441 |
| C4 (C, λ = 4) | Intercept |  | V3b | 1000 | 0,1200 [0,1005 ; 0,1418] (0,0995) | 24 / 8, 0,084 | 0,0520 [0,0391 ; 0,0676] (0,0560) | 14 / 4, 0,309 |
| C4 (C, λ = 4) | Intercept |  | V3h | 1000 | 0,1000 [0,0821 ; 0,1203] (0,0950) | 0 / 4, 1 | 0,0400 [0,0287 ; 0,0541] (0,0520) | 0 / 2, 1 |
| C4 (C, λ = 4) | RESET |  | V1 | 1000 | 0,1280 [0,1079 ; 0,1503] (0,0830) | — | 0,1010 [0,0830 ; 0,1214] (0,0325) | — |
| C4 (C, λ = 4) | RESET |  | V3a | 1000 | 0,1370 [0,1163 ; 0,1599] (0,0855) | 23 / 14, 1 | 0,0960 [0,0785 ; 0,1160] (0,0435) | 10 / 15, 1 |
| C4 (C, λ = 4) | RESET |  | V3b | 1000 | 0,1350 [0,1144 ; 0,1578] (0,0865) | 22 / 15, 1 | 0,0960 [0,0785 ; 0,1160] (0,0440) | 9 / 14, 1 |
| C4 (C, λ = 4) | RESET |  | V3h | 1000 | 0,1270 [0,1070 ; 0,1492] (0,0755) | 1 / 2, 1 | 0,1010 [0,0830 ; 0,1214] (0,0350) | 0 / 0, 1 |
| C4 (C, λ = 4) | BP |  | V1 | 1000 | 0,1140 [0,0950 ; 0,1353] (0,0850) | — | 0,0790 [0,0630 ; 0,0975] (0,0370) | — |
| C4 (C, λ = 4) | BP |  | V3a | 1000 | 0,0970 [0,0794 ; 0,1170] (0,0770) | 12 / 29, 0,184 | 0,0460 [0,0339 ; 0,0609] (0,0365) | 7 / 40, 2,36e-05 |
| C4 (C, λ = 4) | BP |  | V3b | 1000 | 0,0930 [0,0757 ; 0,1127] (0,0780) | 11 / 32, 0,0345 | 0,0460 [0,0339 ; 0,0609] (0,0380) | 8 / 41, 4,32e-05 |
| C4 (C, λ = 4) | BP |  | V3h | 1000 | 0,1250 [0,1051 ; 0,1471] (0,1095) | 11 / 0, 0,0166 | 0,0870 [0,0703 ; 0,1062] (0,0490) | 8 / 0, 0,125 |
| C4 (C, λ = 4) | BP79 |  | V1 | 1000 | 0,2410 [0,2148 ; 0,2687] (0,0755) | — | 0,1640 [0,1416 ; 0,1884] (0,0365) | — |
| C4 (C, λ = 4) | BP79 |  | V3a | 1000 | 0,1990 [0,1747 ; 0,2251] (0,0680) | 9 / 51, 6,79e-07 | 0,1460 [0,1247 ; 0,1694] (0,0345) | 9 / 27, 0,0669 |
| C4 (C, λ = 4) | BP79 |  | V3b | 1000 | 0,2000 [0,1756 ; 0,2262] (0,0685) | 9 / 50, 1,16e-06 | 0,1460 [0,1247 ; 0,1694] (0,0355) | 9 / 27, 0,0669 |
| C4 (C, λ = 4) | BP79 |  | V3h | 1000 | 0,2500 [0,2234 ; 0,2781] (0,0965) | 9 / 0, 0,0625 | 0,1730 [0,1500 ; 0,1979] (0,0485) | 9 / 0, 0,0664 |
| C4 (C, λ = 4) | White |  | V1 | 1000 | 0,1310 [0,1107 ; 0,1535] (0,0880) | — | 0,0970 [0,0794 ; 0,1170] (0,0400) | — |
| C4 (C, λ = 4) | White |  | V3a | 1000 | 0,1160 [0,0968 ; 0,1375] (0,0825) | 3 / 18, 0,0283 | 0,0730 [0,0577 ; 0,0909] (0,0360) | 4 / 28, 0,000367 |
| C4 (C, λ = 4) | White |  | V3b | 1000 | 0,1150 [0,0959 ; 0,1364] (0,0810) | 3 / 19, 0,0163 | 0,0730 [0,0577 ; 0,0909] (0,0360) | 4 / 28, 0,000386 |
| C4 (C, λ = 4) | White |  | V3h | 1000 | 0,1300 [0,1098 ; 0,1524] (0,0890) | 0 / 1, 1 | 0,0980 [0,0803 ; 0,1181] (0,0420) | 1 / 0, 1 |
| C4 (C, λ = 4) | GQ |  | V1 | 1000 | 0,2090 [0,1842 ; 0,2355] (0,0545) | — | 0,1130 [0,0940 ; 0,1343] (0,0290) | — |
| C4 (C, λ = 4) | GQ |  | V3a | 1000 | 0,2010 [0,1766 ; 0,2272] (0,1020) | 68 / 76, 1 | 0,1320 [0,1116 ; 0,1546] (0,0485) | 61 / 42, 1 |
| C4 (C, λ = 4) | GQ |  | V3b | 1000 | 0,2080 [0,1832 ; 0,2345] (0,1000) | 74 / 75, 1 | 0,1310 [0,1107 ; 0,1535] (0,0495) | 62 / 44, 1 |
| C4 (C, λ = 4) | GQ |  | V3h | 1000 | 0,2440 [0,2177 ; 0,2719] (0,0790) | 35 / 0, 1,22e-09 | 0,1350 [0,1144 ; 0,1578] (0,0405) | 22 / 0, 1e-05 |
| C4 (C, λ = 4) | BF |  | V1 | 1000 | 0,0690 [0,0541 ; 0,0865] (0,0860) | — | 0,0290 [0,0195 ; 0,0414] (0,0455) | — |
| C4 (C, λ = 4) | BF |  | V3a | 1000 | 0,0620 [0,0479 ; 0,0788] (0,0865) | 10 / 17, 1 | 0,0250 [0,0162 ; 0,0367] (0,0445) | 5 / 9, 1 |
| C4 (C, λ = 4) | BF |  | V3b | 1000 | 0,0620 [0,0479 ; 0,0788] (0,0875) | 12 / 19, 1 | 0,0250 [0,0162 ; 0,0367] (0,0455) | 5 / 9, 1 |
| C4 (C, λ = 4) | BF |  | V3h | 1000 | 0,0810 [0,0648 ; 0,0997] (0,1095) | 12 / 0, 0,00879 | 0,0340 [0,0237 ; 0,0472] (0,0565) | 5 / 0, 0,812 |
| C4 (C, λ = 4) | Smirnov |  | V1 | 1000 | 0,0280 [0,0187 ; 0,0402] (0,0275) | — | 0,0280 [0,0187 ; 0,0402] (0,0275) | — |
| C4 (C, λ = 4) | Smirnov |  | V3a | 1000 | 0,0290 [0,0195 ; 0,0414] (0,0290) | 1 / 0, 1 | 0,0270 [0,0179 ; 0,0390] (0,0275) | 0 / 1, 1 |
| C4 (C, λ = 4) | Smirnov |  | V3b | 1000 | 0,0280 [0,0187 ; 0,0402] (0,0275) | 0 / 0, 1 | 0,0280 [0,0187 ; 0,0402] (0,0275) | 0 / 0, 1 |
| C4 (C, λ = 4) | Smirnov |  | V3h | 1000 | 0,0280 [0,0187 ; 0,0402] (0,0275) | 0 / 0, 1 | 0,0280 [0,0187 ; 0,0402] (0,0275) | 0 / 0, 1 |
| C4 (C, λ = 4) | LB2 |  | V1 | 1000 | 0,0450 [0,0330 ; 0,0598] (0,1065) | — | 0,0160 [0,0092 ; 0,0259] (0,0530) | — |
| C4 (C, λ = 4) | LB2 |  | V3a | 1000 | 0,0480 [0,0356 ; 0,0631] (0,1005) | 6 / 3, 1 | 0,0160 [0,0092 ; 0,0259] (0,0545) | 3 / 3, 1 |
| C4 (C, λ = 4) | LB2 |  | V3b | 1000 | 0,0480 [0,0356 ; 0,0631] (0,0980) | 6 / 3, 1 | 0,0160 [0,0092 ; 0,0259] (0,0540) | 2 / 2, 1 |
| C4 (C, λ = 4) | LB2 |  | V3h | 1000 | 0,0430 [0,0313 ; 0,0575] (0,1010) | 0 / 2, 1 | 0,0160 [0,0092 ; 0,0259] (0,0505) | 0 / 0, 1 |
| C4 (C, λ = 4) | BP2 |  | V1 | 1000 | 0,0460 [0,0339 ; 0,0609] (0,1040) | — | 0,0170 [0,0099 ; 0,0271] (0,0530) | — |
| C4 (C, λ = 4) | BP2 |  | V3a | 1000 | 0,0470 [0,0347 ; 0,0620] (0,1025) | 7 / 6, 1 | 0,0170 [0,0099 ; 0,0271] (0,0550) | 2 / 2, 1 |
| C4 (C, λ = 4) | BP2 |  | V3b | 1000 | 0,0490 [0,0365 ; 0,0643] (0,1015) | 7 / 4, 1 | 0,0170 [0,0099 ; 0,0271] (0,0560) | 2 / 2, 1 |
| C4 (C, λ = 4) | BP2 |  | V3h | 1000 | 0,0450 [0,0330 ; 0,0598] (0,1025) | 0 / 1, 1 | 0,0160 [0,0092 ; 0,0259] (0,0510) | 0 / 1, 1 |
| C4 (C, λ = 4) | Runs |  | V1 | 1000 | 0,0650 [0,0505 ; 0,0821] (0,0635) | — | 0,0090 [0,0041 ; 0,0170] (0,0075) | — |
| C4 (C, λ = 4) | Runs |  | V3a | 1000 | 0,0590 [0,0452 ; 0,0754] (0,0610) | 0 / 6, 0,353 | 0,0190 [0,0115 ; 0,0295] (0,0145) | 12 / 2, 0,155 |
| C4 (C, λ = 4) | Runs |  | V3b | 1000 | 0,0650 [0,0505 ; 0,0821] (0,0635) | 0 / 0, 1 | 0,0120 [0,0062 ; 0,0209] (0,0095) | 8 / 5, 1 |
| C4 (C, λ = 4) | Runs |  | V3h | 1000 | 0,0650 [0,0505 ; 0,0821] (0,0635) | 0 / 0, 1 | 0,0100 [0,0048 ; 0,0183] (0,0065) | 1 / 0, 1 |
| C4 (C, λ = 4) | MK |  | V1 | 1000 | 0,0470 [0,0347 ; 0,0620] (0,0650) | — | 0,0270 [0,0179 ; 0,0390] (0,0290) | — |
| C4 (C, λ = 4) | MK |  | V3a | 1000 | 0,0640 [0,0496 ; 0,0810] (0,0715) | 24 / 7, 0,0566 | 0,0290 [0,0195 ; 0,0414] (0,0355) | 6 / 4, 1 |
| C4 (C, λ = 4) | MK |  | V3b | 1000 | 0,0640 [0,0496 ; 0,0810] (0,0755) | 23 / 6, 0,0394 | 0,0300 [0,0203 ; 0,0426] (0,0375) | 7 / 4, 1 |
| C4 (C, λ = 4) | MK |  | V3h | 1000 | 0,0480 [0,0356 ; 0,0631] (0,0635) | 2 / 1, 1 | 0,0270 [0,0179 ; 0,0390] (0,0295) | 0 / 0, 1 |
| C4 (C, λ = 4) | SpearVol |  | V1 | 1000 | 0,1050 [0,0867 ; 0,1257] (0,0965) | — | 0,0470 [0,0347 ; 0,0620] (0,0505) | — |
| C4 (C, λ = 4) | SpearVol |  | V3a | 1000 | 0,1220 [0,1024 ; 0,1439] (0,1020) | 21 / 4, 0,0182 | 0,0570 [0,0435 ; 0,0732] (0,0470) | 12 / 2, 0,194 |
| C4 (C, λ = 4) | SpearVol |  | V3b | 1000 | 0,1260 [0,1061 ; 0,1482] (0,1020) | 23 / 2, 0,000408 | 0,0580 [0,0443 ; 0,0743] (0,0530) | 15 / 4, 0,288 |
| C4 (C, λ = 4) | SpearVol |  | V3h | 1000 | 0,1060 [0,0876 ; 0,1268] (0,0975) | 2 / 1, 1 | 0,0480 [0,0356 ; 0,0631] (0,0515) | 2 / 1, 1 |
| C4 (C, λ = 4) | SpearTps |  | V1 | 1000 | 0,0720 [0,0568 ; 0,0898] (0,0885) | — | 0,0340 [0,0237 ; 0,0472] (0,0390) | — |
| C4 (C, λ = 4) | SpearTps |  | V3a | 1000 | 0,0830 [0,0666 ; 0,1019] (0,0845) | 22 / 11, 1 | 0,0370 [0,0262 ; 0,0506] (0,0420) | 8 / 5, 1 |
| C4 (C, λ = 4) | SpearTps |  | V3b | 1000 | 0,0800 [0,0639 ; 0,0986] (0,0875) | 20 / 12, 1 | 0,0360 [0,0253 ; 0,0495] (0,0445) | 7 / 5, 1 |
| C4 (C, λ = 4) | SpearTps |  | V3h | 1000 | 0,0710 [0,0559 ; 0,0887] (0,0825) | 0 / 1, 1 | 0,0340 [0,0237 ; 0,0472] (0,0405) | 0 / 0, 1 |
| C4 (C, λ = 4) | DAgo | oui | V1 | 1000 | 0,5270 [0,4955 ; 0,5583] (0,0815) | — | 0,3900 [0,3596 ; 0,4210] (0,0400) | — |
| C4 (C, λ = 4) | DAgo | oui | V3a | 1000 | 0,5100 [0,4785 ; 0,5414] (0,0810) | 18 / 35, 0,405 | 0,3600 [0,3302 ; 0,3906] (0,0395) | 15 / 45, 0,00242 |
| C4 (C, λ = 4) | DAgo | oui | V3b | 1000 | 0,5170 [0,4855 ; 0,5484] (0,0810) | 19 / 29, 1 | 0,3670 [0,3371 ; 0,3977] (0,0415) | 15 / 38, 0,0394 |
| C4 (C, λ = 4) | DAgo | oui | V3h | 1000 | 0,5460 [0,5145 ; 0,5772] (0,0985) | 19 / 0, 7,25e-05 | 0,4050 [0,3744 ; 0,4362] (0,0510) | 15 / 0, 0,00116 |
| C4 (C, λ = 4) | CoxStuart |  | V1 | 1000 | 0,0000 [0,0000 ; 0,0037] (0,0000) | — | 0,0000 [0,0000 ; 0,0037] (0,0000) | — |
| C4 (C, λ = 4) | CoxStuart |  | V3a | 1000 | 0,0030 [0,0006 ; 0,0087] (0,0030) | 3 / 0, 1 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 |
| C4 (C, λ = 4) | CoxStuart |  | V3b | 1000 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 |
| C4 (C, λ = 4) | CoxStuart |  | V3h | 1000 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 |
| C4 (C, λ = 4) | DWr |  | V1 | 1000 | 0,0560 [0,0426 ; 0,0721] (0,0920) | — | 0,0170 [0,0099 ; 0,0271] (0,0455) | — |
| C4 (C, λ = 4) | DWr |  | V3a | 1000 | 0,0540 [0,0408 ; 0,0699] (0,0965) | 18 / 20, 1 | 0,0250 [0,0162 ; 0,0367] (0,0560) | 12 / 4, 1 |
| C4 (C, λ = 4) | DWr |  | V3b | 1000 | 0,0530 [0,0399 ; 0,0688] (0,1010) | 15 / 18, 1 | 0,0220 [0,0138 ; 0,0331] (0,0575) | 11 / 6, 1 |
| C4 (C, λ = 4) | DWr |  | V3h | 1000 | 0,0580 [0,0443 ; 0,0743] (0,1000) | 2 / 0, 1 | 0,0240 [0,0154 ; 0,0355] (0,0515) | 7 / 0, 0,234 |
| C4 (C, λ = 4) | LB1r |  | V1 | 1000 | 0,0470 [0,0347 ; 0,0620] (0,1035) | — | 0,0150 [0,0084 ; 0,0246] (0,0525) | — |
| C4 (C, λ = 4) | LB1r |  | V3a | 1000 | 0,0470 [0,0347 ; 0,0620] (0,1105) | 4 / 4, 1 | 0,0140 [0,0077 ; 0,0234] (0,0480) | 1 / 2, 1 |
| C4 (C, λ = 4) | LB1r |  | V3b | 1000 | 0,0470 [0,0347 ; 0,0620] (0,1105) | 6 / 6, 1 | 0,0170 [0,0099 ; 0,0271] (0,0505) | 4 / 2, 1 |
| C4 (C, λ = 4) | LB1r |  | V3h | 1000 | 0,0500 [0,0373 ; 0,0654] (0,1130) | 3 / 0, 1 | 0,0160 [0,0092 ; 0,0259] (0,0545) | 1 / 0, 1 |
| C4 (C, λ = 4) | Runsr |  | V1 | 1000 | 0,0660 [0,0514 ; 0,0832] (0,0610) | — | 0,0150 [0,0084 ; 0,0246] (0,0105) | — |
| C4 (C, λ = 4) | Runsr |  | V3a | 1000 | 0,0620 [0,0479 ; 0,0788] (0,0585) | 0 / 4, 1 | 0,0230 [0,0146 ; 0,0343] (0,0145) | 10 / 2, 0,424 |
| C4 (C, λ = 4) | Runsr |  | V3b | 1000 | 0,0660 [0,0514 ; 0,0832] (0,0610) | 0 / 0, 1 | 0,0160 [0,0092 ; 0,0259] (0,0105) | 9 / 8, 1 |
| C4 (C, λ = 4) | Runsr |  | V3h | 1000 | 0,0660 [0,0514 ; 0,0832] (0,0610) | 0 / 0, 1 | 0,0170 [0,0099 ; 0,0271] (0,0090) | 2 / 0, 1 |
| C4 (C, λ = 4) | supFr |  | V1 | 1000 | 0,0530 [0,0399 ; 0,0688] (0,1010) | — | 0,0230 [0,0146 ; 0,0343] (0,0490) | — |
| C4 (C, λ = 4) | supFr |  | V3a | 1000 | 0,0590 [0,0452 ; 0,0754] (0,1020) | 12 / 6, 1 | 0,0270 [0,0179 ; 0,0390] (0,0510) | 8 / 4, 1 |
| C4 (C, λ = 4) | supFr |  | V3b | 1000 | 0,0580 [0,0443 ; 0,0743] (0,1040) | 11 / 6, 1 | 0,0290 [0,0195 ; 0,0414] (0,0535) | 9 / 3, 1 |
| C4 (C, λ = 4) | supFr |  | V3h | 1000 | 0,0580 [0,0443 ; 0,0743] (0,1045) | 5 / 0, 0,812 | 0,0240 [0,0154 ; 0,0355] (0,0510) | 1 / 0, 1 |
| C4 (C, λ = 4) | CUSUMr |  | V1 | 1000 | 0,0510 [0,0382 ; 0,0665] (0,0995) | — | 0,0170 [0,0099 ; 0,0271] (0,0505) | — |
| C4 (C, λ = 4) | CUSUMr |  | V3a | 1000 | 0,0510 [0,0382 ; 0,0665] (0,1020) | 5 / 5, 1 | 0,0170 [0,0099 ; 0,0271] (0,0500) | 3 / 3, 1 |
| C4 (C, λ = 4) | CUSUMr |  | V3b | 1000 | 0,0530 [0,0399 ; 0,0688] (0,0995) | 3 / 1, 1 | 0,0180 [0,0107 ; 0,0283] (0,0505) | 3 / 2, 1 |
| C4 (C, λ = 4) | CUSUMr |  | V3h | 1000 | 0,0510 [0,0382 ; 0,0665] (0,0990) | 0 / 0, 1 | 0,0180 [0,0107 ; 0,0283] (0,0475) | 1 / 0, 1 |
| C4 (C, λ = 4) | Grubbsr | oui | V1 | 1000 | 0,6780 [0,6480 ; 0,7069] (0,0845) | — | 0,5220 [0,4905 ; 0,5534] (0,0390) | — |
| C4 (C, λ = 4) | Grubbsr | oui | V3a | 1000 | 0,6740 [0,6440 ; 0,7030] (0,0870) | 23 / 27, 1 | 0,5200 [0,4885 ; 0,5514] (0,0390) | 32 / 34, 1 |
| C4 (C, λ = 4) | Grubbsr | oui | V3b | 1000 | 0,6770 [0,6470 ; 0,7059] (0,0845) | 26 / 27, 1 | 0,5080 [0,4765 ; 0,5394] (0,0410) | 25 / 39, 1 |
| C4 (C, λ = 4) | Grubbsr | oui | V3h | 1000 | 0,6980 [0,6685 ; 0,7263] (0,0985) | 20 / 0, 3,81e-05 | 0,5420 [0,5105 ; 0,5732] (0,0485) | 20 / 0, 3,81e-05 |
| A4 (A, ν = 4) | AD |  | V1 | 1000 | 0,2350 [0,2090 ; 0,2625] (0,1020) | — | 0,1350 [0,1144 ; 0,1578] (0,0450) | — |
| A4 (A, ν = 4) | AD |  | V3a | 1000 | 0,2350 [0,2090 ; 0,2625] (0,1000) | 7 / 7, 1 | 0,1320 [0,1116 ; 0,1546] (0,0435) | 6 / 9, 1 |
| A4 (A, ν = 4) | AD |  | V3b | 1000 | 0,2370 [0,2109 ; 0,2646] (0,1000) | 8 / 6, 1 | 0,1330 [0,1126 ; 0,1556] (0,0420) | 6 / 8, 1 |
| A4 (A, ν = 4) | AD |  | V3h | 1000 | 0,2340 [0,2081 ; 0,2615] (0,1020) | 1 / 2, 1 | 0,1380 [0,1172 ; 0,1609] (0,0450) | 3 / 0, 1 |
| A4 (A, ν = 4) | CvM |  | V1 | 1000 | 0,2100 [0,1851 ; 0,2366] (0,0970) | — | 0,1160 [0,0968 ; 0,1375] (0,0465) | — |
| A4 (A, ν = 4) | CvM |  | V3a | 1000 | 0,2140 [0,1890 ; 0,2407] (0,0985) | 7 / 3, 1 | 0,1210 [0,1014 ; 0,1428] (0,0465) | 10 / 5, 1 |
| A4 (A, ν = 4) | CvM |  | V3b | 1000 | 0,2110 [0,1861 ; 0,2376] (0,0955) | 7 / 6, 1 | 0,1150 [0,0959 ; 0,1364] (0,0465) | 5 / 6, 1 |
| A4 (A, ν = 4) | CvM |  | V3h | 1000 | 0,2070 [0,1823 ; 0,2335] (0,0935) | 0 / 3, 1 | 0,1140 [0,0950 ; 0,1353] (0,0470) | 0 / 2, 1 |
| A4 (A, ν = 4) | KS |  | V1 | 1000 | 0,1740 [0,1510 ; 0,1989] (0,0900) | — | 0,1020 [0,0839 ; 0,1224] (0,0460) | — |
| A4 (A, ν = 4) | KS |  | V3a | 1000 | 0,1790 [0,1557 ; 0,2042] (0,0885) | 7 / 2, 1 | 0,1060 [0,0876 ; 0,1268] (0,0425) | 8 / 4, 1 |
| A4 (A, ν = 4) | KS |  | V3b | 1000 | 0,1790 [0,1557 ; 0,2042] (0,0885) | 6 / 1, 1 | 0,1010 [0,0830 ; 0,1214] (0,0440) | 4 / 5, 1 |
| A4 (A, ν = 4) | KS |  | V3h | 1000 | 0,1750 [0,1519 ; 0,2000] (0,0885) | 1 / 0, 1 | 0,1000 [0,0821 ; 0,1203] (0,0455) | 1 / 3, 1 |
| A4 (A, ν = 4) | SW |  | V1 | 1000 | 0,2450 [0,2186 ; 0,2729] (0,0945) | — | 0,1420 [0,1209 ; 0,1652] (0,0445) | — |
| A4 (A, ν = 4) | SW |  | V3a | 1000 | 0,2430 [0,2167 ; 0,2708] (0,0925) | 10 / 12, 1 | 0,1410 [0,1200 ; 0,1641] (0,0450) | 8 / 9, 1 |
| A4 (A, ν = 4) | SW |  | V3b | 1000 | 0,2480 [0,2215 ; 0,2760] (0,0915) | 10 / 7, 1 | 0,1390 [0,1181 ; 0,1620] (0,0455) | 6 / 9, 1 |
| A4 (A, ν = 4) | SW |  | V3h | 1000 | 0,2520 [0,2254 ; 0,2801] (0,0960) | 7 / 0, 0,188 | 0,1460 [0,1247 ; 0,1694] (0,0460) | 4 / 0, 1 |
| A4 (A, ν = 4) | SF | oui | V1 | 1000 | 0,2360 [0,2100 ; 0,2636] (0,0850) | — | 0,1460 [0,1247 ; 0,1694] (0,0460) | — |
| A4 (A, ν = 4) | SF | oui | V3a | 1000 | 0,2400 [0,2138 ; 0,2677] (0,0830) | 20 / 16, 1 | 0,1450 [0,1237 ; 0,1684] (0,0405) | 14 / 15, 1 |
| A4 (A, ν = 4) | SF | oui | V3b | 1000 | 0,2450 [0,2186 ; 0,2729] (0,0800) | 20 / 11, 1 | 0,1470 [0,1256 ; 0,1705] (0,0405) | 17 / 16, 1 |
| A4 (A, ν = 4) | SF | oui | V3h | 1000 | 0,2560 [0,2292 ; 0,2842] (0,0925) | 20 / 0, 3,43e-05 | 0,1630 [0,1406 ; 0,1874] (0,0490) | 17 / 0, 0,000305 |
| A4 (A, ν = 4) | JB | oui | V1 | 1000 | 0,2150 [0,1899 ; 0,2418] (0,0850) | — | 0,1350 [0,1144 ; 0,1578] (0,0405) | — |
| A4 (A, ν = 4) | JB | oui | V3a | 1000 | 0,2310 [0,2052 ; 0,2584] (0,0855) | 36 / 20, 0,793 | 0,1420 [0,1209 ; 0,1652] (0,0400) | 25 / 18, 1 |
| A4 (A, ν = 4) | JB | oui | V3b | 1000 | 0,2270 [0,2014 ; 0,2542] (0,0845) | 35 / 23, 1 | 0,1390 [0,1181 ; 0,1620] (0,0425) | 24 / 20, 1 |
| A4 (A, ν = 4) | JB | oui | V3h | 1000 | 0,2500 [0,2234 ; 0,2781] (0,1020) | 35 / 0, 1,28e-09 | 0,1590 [0,1369 ; 0,1832] (0,0490) | 24 / 0, 2,62e-06 |
| A4 (A, ν = 4) | DW |  | V1 | 1000 | 0,0880 [0,0712 ; 0,1073] (0,1025) | — | 0,0450 [0,0330 ; 0,0598] (0,0480) | — |
| A4 (A, ν = 4) | DW |  | V3a | 1000 | 0,0960 [0,0785 ; 0,1160] (0,1030) | 22 / 14, 1 | 0,0470 [0,0347 ; 0,0620] (0,0540) | 9 / 7, 1 |
| A4 (A, ν = 4) | DW |  | V3b | 1000 | 0,0950 [0,0775 ; 0,1149] (0,1060) | 21 / 14, 1 | 0,0460 [0,0339 ; 0,0609] (0,0535) | 7 / 6, 1 |
| A4 (A, ν = 4) | DW |  | V3h | 1000 | 0,0980 [0,0803 ; 0,1181] (0,1110) | 10 / 0, 0,0254 | 0,0470 [0,0347 ; 0,0620] (0,0535) | 2 / 0, 1 |
| A4 (A, ν = 4) | LB1 |  | V1 | 1000 | 0,0870 [0,0703 ; 0,1062] (0,1090) | — | 0,0430 [0,0313 ; 0,0575] (0,0530) | — |
| A4 (A, ν = 4) | LB1 |  | V3a | 1000 | 0,0880 [0,0712 ; 0,1073] (0,1130) | 7 / 6, 1 | 0,0380 [0,0270 ; 0,0518] (0,0505) | 1 / 6, 1 |
| A4 (A, ν = 4) | LB1 |  | V3b | 1000 | 0,0860 [0,0694 ; 0,1051] (0,1110) | 5 / 6, 1 | 0,0400 [0,0287 ; 0,0541] (0,0500) | 2 / 5, 1 |
| A4 (A, ν = 4) | LB1 |  | V3h | 1000 | 0,0910 [0,0739 ; 0,1106] (0,1135) | 5 / 1, 1 | 0,0430 [0,0313 ; 0,0575] (0,0550) | 0 / 0, 1 |
| A4 (A, ν = 4) | supF |  | V1 | 1000 | 0,0920 [0,0748 ; 0,1116] (0,0935) | — | 0,0410 [0,0296 ; 0,0552] (0,0515) | — |
| A4 (A, ν = 4) | supF |  | V3a | 1000 | 0,0980 [0,0803 ; 0,1181] (0,0920) | 15 / 9, 1 | 0,0490 [0,0365 ; 0,0643] (0,0555) | 8 / 0, 0,172 |
| A4 (A, ν = 4) | supF |  | V3b | 1000 | 0,0950 [0,0775 ; 0,1149] (0,0905) | 15 / 12, 1 | 0,0460 [0,0339 ; 0,0609] (0,0555) | 8 / 3, 1 |
| A4 (A, ν = 4) | supF |  | V3h | 1000 | 0,0940 [0,0766 ; 0,1138] (0,0950) | 2 / 0, 1 | 0,0410 [0,0296 ; 0,0552] (0,0530) | 0 / 0, 1 |
| A4 (A, ν = 4) | CUSUM |  | V1 | 1000 | 0,0880 [0,0712 ; 0,1073] (0,0990) | — | 0,0490 [0,0365 ; 0,0643] (0,0480) | — |
| A4 (A, ν = 4) | CUSUM |  | V3a | 1000 | 0,0920 [0,0748 ; 0,1116] (0,0990) | 7 / 3, 1 | 0,0560 [0,0426 ; 0,0721] (0,0475) | 9 / 2, 0,72 |
| A4 (A, ν = 4) | CUSUM |  | V3b | 1000 | 0,0900 [0,0730 ; 0,1095] (0,0995) | 4 / 2, 1 | 0,0530 [0,0399 ; 0,0688] (0,0510) | 6 / 2, 1 |
| A4 (A, ν = 4) | CUSUM |  | V3h | 1000 | 0,0870 [0,0703 ; 0,1062] (0,0990) | 0 / 1, 1 | 0,0490 [0,0365 ; 0,0643] (0,0470) | 0 / 0, 1 |
| A4 (A, ν = 4) | Grubbs | oui | V1 | 1000 | 0,1900 [0,1661 ; 0,2157] (0,0835) | — | 0,1220 [0,1024 ; 0,1439] (0,0415) | — |
| A4 (A, ν = 4) | Grubbs | oui | V3a | 1000 | 0,1940 [0,1699 ; 0,2199] (0,0835) | 23 / 19, 1 | 0,1250 [0,1051 ; 0,1471] (0,0400) | 18 / 15, 1 |
| A4 (A, ν = 4) | Grubbs | oui | V3b | 1000 | 0,1920 [0,1680 ; 0,2178] (0,0845) | 21 / 19, 1 | 0,1270 [0,1070 ; 0,1492] (0,0430) | 19 / 14, 1 |
| A4 (A, ν = 4) | Grubbs | oui | V3h | 1000 | 0,2110 [0,1861 ; 0,2376] (0,1000) | 21 / 0, 1,81e-05 | 0,1400 [0,1191 ; 0,1631] (0,0515) | 18 / 0, 0,00016 |
| A4 (A, ν = 4) | Lillie |  | V1 | 1000 | 0,1890 [0,1652 ; 0,2147] (0,0880) | — | 0,1160 [0,0968 ; 0,1375] (0,0480) | — |
| A4 (A, ν = 4) | Lillie |  | V3a | 1000 | 0,1840 [0,1604 ; 0,2094] (0,0875) | 5 / 10, 1 | 0,1140 [0,0950 ; 0,1353] (0,0465) | 11 / 13, 1 |
| A4 (A, ν = 4) | Lillie |  | V3b | 1000 | 0,1920 [0,1680 ; 0,2178] (0,0860) | 12 / 9, 1 | 0,1150 [0,0959 ; 0,1364] (0,0435) | 12 / 13, 1 |
| A4 (A, ν = 4) | Lillie |  | V3h | 1000 | 0,1960 [0,1718 ; 0,2220] (0,0920) | 7 / 0, 0,188 | 0,1250 [0,1051 ; 0,1471] (0,0505) | 10 / 1, 0,141 |
| A4 (A, ν = 4) | Intercept |  | V1 | 1000 | 0,1180 [0,0987 ; 0,1396] (0,0975) | — | 0,0610 [0,0470 ; 0,0777] (0,0535) | — |
| A4 (A, ν = 4) | Intercept |  | V3a | 1000 | 0,1290 [0,1088 ; 0,1514] (0,1035) | 16 / 5, 0,319 | 0,0600 [0,0461 ; 0,0766] (0,0540) | 4 / 5, 1 |
| A4 (A, ν = 4) | Intercept |  | V3b | 1000 | 0,1300 [0,1098 ; 0,1524] (0,0995) | 17 / 5, 0,203 | 0,0620 [0,0479 ; 0,0788] (0,0560) | 6 / 5, 1 |
| A4 (A, ν = 4) | Intercept |  | V3h | 1000 | 0,1170 [0,0977 ; 0,1386] (0,0950) | 0 / 1, 1 | 0,0580 [0,0443 ; 0,0743] (0,0520) | 0 / 3, 1 |
| A4 (A, ν = 4) | RESET |  | V1 | 1000 | 0,0900 [0,0730 ; 0,1095] (0,0830) | — | 0,0530 [0,0399 ; 0,0688] (0,0325) | — |
| A4 (A, ν = 4) | RESET |  | V3a | 1000 | 0,0980 [0,0803 ; 0,1181] (0,0855) | 23 / 15, 1 | 0,0460 [0,0339 ; 0,0609] (0,0435) | 11 / 18, 1 |
| A4 (A, ν = 4) | RESET |  | V3b | 1000 | 0,1020 [0,0839 ; 0,1224] (0,0865) | 24 / 12, 1 | 0,0470 [0,0347 ; 0,0620] (0,0440) | 10 / 16, 1 |
| A4 (A, ν = 4) | RESET |  | V3h | 1000 | 0,0890 [0,0721 ; 0,1084] (0,0755) | 2 / 3, 1 | 0,0510 [0,0382 ; 0,0665] (0,0350) | 1 / 3, 1 |
| A4 (A, ν = 4) | BP |  | V1 | 1000 | 0,0950 [0,0775 ; 0,1149] (0,0850) | — | 0,0460 [0,0339 ; 0,0609] (0,0370) | — |
| A4 (A, ν = 4) | BP |  | V3a | 1000 | 0,0810 [0,0648 ; 0,0997] (0,0770) | 22 / 36, 1 | 0,0350 [0,0245 ; 0,0483] (0,0365) | 11 / 22, 1 |
| A4 (A, ν = 4) | BP |  | V3b | 1000 | 0,0840 [0,0676 ; 0,1029] (0,0780) | 26 / 37, 1 | 0,0350 [0,0245 ; 0,0483] (0,0380) | 11 / 22, 1 |
| A4 (A, ν = 4) | BP |  | V3h | 1000 | 0,1210 [0,1014 ; 0,1428] (0,1095) | 26 / 0, 5,96e-07 | 0,0560 [0,0426 ; 0,0721] (0,0490) | 10 / 0, 0,0313 |
| A4 (A, ν = 4) | BP79 |  | V1 | 1000 | 0,1160 [0,0968 ; 0,1375] (0,0755) | — | 0,0650 [0,0505 ; 0,0821] (0,0365) | — |
| A4 (A, ν = 4) | BP79 |  | V3a | 1000 | 0,0950 [0,0775 ; 0,1149] (0,0680) | 17 / 38, 0,129 | 0,0550 [0,0417 ; 0,0710] (0,0345) | 10 / 20, 1 |
| A4 (A, ν = 4) | BP79 |  | V3b | 1000 | 0,0970 [0,0794 ; 0,1170] (0,0685) | 19 / 38, 0,327 | 0,0570 [0,0435 ; 0,0732] (0,0355) | 11 / 19, 1 |
| A4 (A, ν = 4) | BP79 |  | V3h | 1000 | 0,1350 [0,1144 ; 0,1578] (0,0965) | 19 / 0, 6,1e-05 | 0,0760 [0,0603 ; 0,0942] (0,0485) | 11 / 0, 0,0176 |
| A4 (A, ν = 4) | White |  | V1 | 1000 | 0,1000 [0,0821 ; 0,1203] (0,0880) | — | 0,0570 [0,0435 ; 0,0732] (0,0400) | — |
| A4 (A, ν = 4) | White |  | V3a | 1000 | 0,0880 [0,0712 ; 0,1073] (0,0825) | 5 / 17, 0,321 | 0,0500 [0,0373 ; 0,0654] (0,0360) | 10 / 17, 1 |
| A4 (A, ν = 4) | White |  | V3b | 1000 | 0,0920 [0,0748 ; 0,1116] (0,0810) | 6 / 14, 1 | 0,0490 [0,0365 ; 0,0643] (0,0360) | 10 / 18, 1 |
| A4 (A, ν = 4) | White |  | V3h | 1000 | 0,1010 [0,0830 ; 0,1214] (0,0890) | 2 / 1, 1 | 0,0590 [0,0452 ; 0,0754] (0,0420) | 2 / 0, 1 |
| A4 (A, ν = 4) | GQ |  | V1 | 1000 | 0,0730 [0,0577 ; 0,0909] (0,0545) | — | 0,0310 [0,0212 ; 0,0437] (0,0290) | — |
| A4 (A, ν = 4) | GQ |  | V3a | 1000 | 0,1010 [0,0830 ; 0,1214] (0,1020) | 58 / 30, 0,0787 | 0,0490 [0,0365 ; 0,0643] (0,0485) | 35 / 17, 0,368 |
| A4 (A, ν = 4) | GQ |  | V3b | 1000 | 0,0990 [0,0812 ; 0,1192] (0,1000) | 57 / 31, 0,154 | 0,0480 [0,0356 ; 0,0631] (0,0495) | 37 / 20, 0,696 |
| A4 (A, ν = 4) | GQ |  | V3h | 1000 | 0,0900 [0,0730 ; 0,1095] (0,0790) | 17 / 0, 0,000214 | 0,0390 [0,0279 ; 0,0529] (0,0405) | 8 / 0, 0,117 |
| A4 (A, ν = 4) | BF |  | V1 | 1000 | 0,1210 [0,1014 ; 0,1428] (0,0860) | — | 0,0690 [0,0541 ; 0,0865] (0,0455) | — |
| A4 (A, ν = 4) | BF |  | V3a | 1000 | 0,1150 [0,0959 ; 0,1364] (0,0865) | 17 / 23, 1 | 0,0590 [0,0452 ; 0,0754] (0,0445) | 10 / 20, 1 |
| A4 (A, ν = 4) | BF |  | V3b | 1000 | 0,1140 [0,0950 ; 0,1353] (0,0875) | 20 / 27, 1 | 0,0610 [0,0470 ; 0,0777] (0,0455) | 8 / 16, 1 |
| A4 (A, ν = 4) | BF |  | V3h | 1000 | 0,1410 [0,1200 ; 0,1641] (0,1095) | 20 / 0, 3,43e-05 | 0,0770 [0,0612 ; 0,0953] (0,0565) | 8 / 0, 0,117 |
| A4 (A, ν = 4) | Smirnov |  | V1 | 1000 | 0,0290 [0,0195 ; 0,0414] (0,0275) | — | 0,0290 [0,0195 ; 0,0414] (0,0275) | — |
| A4 (A, ν = 4) | Smirnov |  | V3a | 1000 | 0,0310 [0,0212 ; 0,0437] (0,0290) | 2 / 0, 1 | 0,0280 [0,0187 ; 0,0402] (0,0275) | 0 / 1, 1 |
| A4 (A, ν = 4) | Smirnov |  | V3b | 1000 | 0,0290 [0,0195 ; 0,0414] (0,0275) | 0 / 0, 1 | 0,0290 [0,0195 ; 0,0414] (0,0275) | 0 / 0, 1 |
| A4 (A, ν = 4) | Smirnov |  | V3h | 1000 | 0,0290 [0,0195 ; 0,0414] (0,0275) | 0 / 0, 1 | 0,0290 [0,0195 ; 0,0414] (0,0275) | 0 / 0, 1 |
| A4 (A, ν = 4) | LB2 |  | V1 | 1000 | 0,0910 [0,0739 ; 0,1106] (0,1065) | — | 0,0470 [0,0347 ; 0,0620] (0,0530) | — |
| A4 (A, ν = 4) | LB2 |  | V3a | 1000 | 0,0910 [0,0739 ; 0,1106] (0,1005) | 10 / 10, 1 | 0,0460 [0,0339 ; 0,0609] (0,0545) | 6 / 7, 1 |
| A4 (A, ν = 4) | LB2 |  | V3b | 1000 | 0,0960 [0,0785 ; 0,1160] (0,0980) | 12 / 7, 1 | 0,0460 [0,0339 ; 0,0609] (0,0540) | 5 / 6, 1 |
| A4 (A, ν = 4) | LB2 |  | V3h | 1000 | 0,0900 [0,0730 ; 0,1095] (0,1010) | 1 / 2, 1 | 0,0440 [0,0321 ; 0,0586] (0,0505) | 0 / 3, 1 |
| A4 (A, ν = 4) | BP2 |  | V1 | 1000 | 0,0980 [0,0803 ; 0,1181] (0,1040) | — | 0,0440 [0,0321 ; 0,0586] (0,0530) | — |
| A4 (A, ν = 4) | BP2 |  | V3a | 1000 | 0,0920 [0,0748 ; 0,1116] (0,1025) | 5 / 11, 1 | 0,0430 [0,0313 ; 0,0575] (0,0550) | 5 / 6, 1 |
| A4 (A, ν = 4) | BP2 |  | V3b | 1000 | 0,0950 [0,0775 ; 0,1149] (0,1015) | 5 / 8, 1 | 0,0450 [0,0330 ; 0,0598] (0,0560) | 5 / 4, 1 |
| A4 (A, ν = 4) | BP2 |  | V3h | 1000 | 0,0970 [0,0794 ; 0,1170] (0,1025) | 1 / 2, 1 | 0,0430 [0,0313 ; 0,0575] (0,0510) | 1 / 2, 1 |
| A4 (A, ν = 4) | Runs |  | V1 | 1000 | 0,0670 [0,0523 ; 0,0843] (0,0635) | — | 0,0100 [0,0048 ; 0,0183] (0,0075) | — |
| A4 (A, ν = 4) | Runs |  | V3a | 1000 | 0,0640 [0,0496 ; 0,0810] (0,0610) | 0 / 3, 1 | 0,0220 [0,0138 ; 0,0331] (0,0145) | 18 / 6, 0,272 |
| A4 (A, ν = 4) | Runs |  | V3b | 1000 | 0,0670 [0,0523 ; 0,0843] (0,0635) | 0 / 0, 1 | 0,0070 [0,0028 ; 0,0144] (0,0095) | 2 / 5, 1 |
| A4 (A, ν = 4) | Runs |  | V3h | 1000 | 0,0670 [0,0523 ; 0,0843] (0,0635) | 0 / 0, 1 | 0,0080 [0,0035 ; 0,0157] (0,0065) | 0 / 2, 1 |
| A4 (A, ν = 4) | MK |  | V1 | 1000 | 0,0750 [0,0594 ; 0,0931] (0,0650) | — | 0,0300 [0,0203 ; 0,0426] (0,0290) | — |
| A4 (A, ν = 4) | MK |  | V3a | 1000 | 0,0820 [0,0657 ; 0,1008] (0,0715) | 19 / 12, 1 | 0,0320 [0,0220 ; 0,0449] (0,0355) | 10 / 8, 1 |
| A4 (A, ν = 4) | MK |  | V3b | 1000 | 0,0770 [0,0612 ; 0,0953] (0,0755) | 18 / 16, 1 | 0,0310 [0,0212 ; 0,0437] (0,0375) | 9 / 8, 1 |
| A4 (A, ν = 4) | MK |  | V3h | 1000 | 0,0720 [0,0568 ; 0,0898] (0,0635) | 1 / 4, 1 | 0,0280 [0,0187 ; 0,0402] (0,0295) | 1 / 3, 1 |
| A4 (A, ν = 4) | SpearVol |  | V1 | 1000 | 0,1070 [0,0885 ; 0,1278] (0,0965) | — | 0,0590 [0,0452 ; 0,0754] (0,0505) | — |
| A4 (A, ν = 4) | SpearVol |  | V3a | 1000 | 0,1250 [0,1051 ; 0,1471] (0,1020) | 20 / 2, 0,00266 | 0,0640 [0,0496 ; 0,0810] (0,0470) | 12 / 7, 1 |
| A4 (A, ν = 4) | SpearVol |  | V3b | 1000 | 0,1200 [0,1005 ; 0,1418] (0,1020) | 16 / 3, 0,0974 | 0,0700 [0,0550 ; 0,0876] (0,0530) | 12 / 1, 0,0752 |
| A4 (A, ν = 4) | SpearVol |  | V3h | 1000 | 0,1060 [0,0876 ; 0,1268] (0,0975) | 1 / 2, 1 | 0,0610 [0,0470 ; 0,0777] (0,0515) | 2 / 0, 1 |
| A4 (A, ν = 4) | SpearTps |  | V1 | 1000 | 0,0940 [0,0766 ; 0,1138] (0,0885) | — | 0,0450 [0,0330 ; 0,0598] (0,0390) | — |
| A4 (A, ν = 4) | SpearTps |  | V3a | 1000 | 0,1010 [0,0830 ; 0,1214] (0,0845) | 20 / 13, 1 | 0,0450 [0,0330 ; 0,0598] (0,0420) | 15 / 15, 1 |
| A4 (A, ν = 4) | SpearTps |  | V3b | 1000 | 0,0990 [0,0812 ; 0,1192] (0,0875) | 19 / 14, 1 | 0,0410 [0,0296 ; 0,0552] (0,0445) | 11 / 15, 1 |
| A4 (A, ν = 4) | SpearTps |  | V3h | 1000 | 0,0920 [0,0748 ; 0,1116] (0,0825) | 1 / 3, 1 | 0,0420 [0,0304 ; 0,0564] (0,0405) | 1 / 4, 1 |
| A4 (A, ν = 4) | DAgo | oui | V1 | 1000 | 0,2110 [0,1861 ; 0,2376] (0,0815) | — | 0,1390 [0,1181 ; 0,1620] (0,0400) | — |
| A4 (A, ν = 4) | DAgo | oui | V3a | 1000 | 0,2160 [0,1909 ; 0,2428] (0,0810) | 30 / 25, 1 | 0,1290 [0,1088 ; 0,1514] (0,0395) | 16 / 26, 1 |
| A4 (A, ν = 4) | DAgo | oui | V3b | 1000 | 0,2170 [0,1918 ; 0,2439] (0,0810) | 28 / 22, 1 | 0,1340 [0,1135 ; 0,1567] (0,0415) | 17 / 22, 1 |
| A4 (A, ν = 4) | DAgo | oui | V3h | 1000 | 0,2390 [0,2129 ; 0,2667] (0,0985) | 28 / 0, 1,56e-07 | 0,1550 [0,1331 ; 0,1789] (0,0510) | 16 / 0, 0,00058 |
| A4 (A, ν = 4) | CoxStuart |  | V1 | 1000 | 0,0000 [0,0000 ; 0,0037] (0,0000) | — | 0,0000 [0,0000 ; 0,0037] (0,0000) | — |
| A4 (A, ν = 4) | CoxStuart |  | V3a | 1000 | 0,0040 [0,0011 ; 0,0102] (0,0030) | 4 / 0, 1 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 |
| A4 (A, ν = 4) | CoxStuart |  | V3b | 1000 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 |
| A4 (A, ν = 4) | CoxStuart |  | V3h | 1000 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 |
| A4 (A, ν = 4) | DWr |  | V1 | 1000 | 0,0860 [0,0694 ; 0,1051] (0,0920) | — | 0,0370 [0,0262 ; 0,0506] (0,0455) | — |
| A4 (A, ν = 4) | DWr |  | V3a | 1000 | 0,0900 [0,0730 ; 0,1095] (0,0965) | 25 / 21, 1 | 0,0430 [0,0313 ; 0,0575] (0,0560) | 14 / 8, 1 |
| A4 (A, ν = 4) | DWr |  | V3b | 1000 | 0,0920 [0,0748 ; 0,1116] (0,1010) | 26 / 20, 1 | 0,0430 [0,0313 ; 0,0575] (0,0575) | 17 / 11, 1 |
| A4 (A, ν = 4) | DWr |  | V3h | 1000 | 0,0950 [0,0775 ; 0,1149] (0,1000) | 9 / 0, 0,0469 | 0,0430 [0,0313 ; 0,0575] (0,0515) | 7 / 1, 0,914 |
| A4 (A, ν = 4) | LB1r |  | V1 | 1000 | 0,0780 [0,0621 ; 0,0964] (0,1035) | — | 0,0410 [0,0296 ; 0,0552] (0,0525) | — |
| A4 (A, ν = 4) | LB1r |  | V3a | 1000 | 0,0810 [0,0648 ; 0,0997] (0,1105) | 8 / 5, 1 | 0,0360 [0,0253 ; 0,0495] (0,0480) | 3 / 8, 1 |
| A4 (A, ν = 4) | LB1r |  | V3b | 1000 | 0,0830 [0,0666 ; 0,1019] (0,1105) | 11 / 6, 1 | 0,0390 [0,0279 ; 0,0529] (0,0505) | 6 / 8, 1 |
| A4 (A, ν = 4) | LB1r |  | V3h | 1000 | 0,0830 [0,0666 ; 0,1019] (0,1130) | 5 / 0, 0,688 | 0,0450 [0,0330 ; 0,0598] (0,0545) | 4 / 0, 1 |
| A4 (A, ν = 4) | Runsr |  | V1 | 1000 | 0,0640 [0,0496 ; 0,0810] (0,0610) | — | 0,0130 [0,0069 ; 0,0221] (0,0105) | — |
| A4 (A, ν = 4) | Runsr |  | V3a | 1000 | 0,0630 [0,0487 ; 0,0799] (0,0585) | 0 / 1, 1 | 0,0180 [0,0107 ; 0,0283] (0,0145) | 11 / 6, 1 |
| A4 (A, ν = 4) | Runsr |  | V3b | 1000 | 0,0640 [0,0496 ; 0,0810] (0,0610) | 0 / 0, 1 | 0,0070 [0,0028 ; 0,0144] (0,0105) | 3 / 9, 1 |
| A4 (A, ν = 4) | Runsr |  | V3h | 1000 | 0,0640 [0,0496 ; 0,0810] (0,0610) | 0 / 0, 1 | 0,0100 [0,0048 ; 0,0183] (0,0090) | 1 / 4, 1 |
| A4 (A, ν = 4) | supFr |  | V1 | 1000 | 0,0960 [0,0785 ; 0,1160] (0,1010) | — | 0,0510 [0,0382 ; 0,0665] (0,0490) | — |
| A4 (A, ν = 4) | supFr |  | V3a | 1000 | 0,0990 [0,0812 ; 0,1192] (0,1020) | 12 / 9, 1 | 0,0530 [0,0399 ; 0,0688] (0,0510) | 9 / 7, 1 |
| A4 (A, ν = 4) | supFr |  | V3b | 1000 | 0,1000 [0,0821 ; 0,1203] (0,1040) | 15 / 11, 1 | 0,0520 [0,0391 ; 0,0676] (0,0535) | 8 / 7, 1 |
| A4 (A, ν = 4) | supFr |  | V3h | 1000 | 0,1000 [0,0821 ; 0,1203] (0,1045) | 4 / 0, 1 | 0,0510 [0,0382 ; 0,0665] (0,0510) | 0 / 0, 1 |
| A4 (A, ν = 4) | CUSUMr |  | V1 | 1000 | 0,0950 [0,0775 ; 0,1149] (0,0995) | — | 0,0470 [0,0347 ; 0,0620] (0,0505) | — |
| A4 (A, ν = 4) | CUSUMr |  | V3a | 1000 | 0,0970 [0,0794 ; 0,1170] (0,1020) | 5 / 3, 1 | 0,0520 [0,0391 ; 0,0676] (0,0500) | 7 / 2, 1 |
| A4 (A, ν = 4) | CUSUMr |  | V3b | 1000 | 0,0970 [0,0794 ; 0,1170] (0,0995) | 8 / 6, 1 | 0,0530 [0,0399 ; 0,0688] (0,0505) | 7 / 1, 1 |
| A4 (A, ν = 4) | CUSUMr |  | V3h | 1000 | 0,0940 [0,0766 ; 0,1138] (0,0990) | 1 / 2, 1 | 0,0470 [0,0347 ; 0,0620] (0,0475) | 0 / 0, 1 |
| A4 (A, ν = 4) | Grubbsr | oui | V1 | 1000 | 0,2370 [0,2109 ; 0,2646] (0,0845) | — | 0,1580 [0,1359 ; 0,1821] (0,0390) | — |
| A4 (A, ν = 4) | Grubbsr | oui | V3a | 1000 | 0,2310 [0,2052 ; 0,2584] (0,0870) | 19 / 25, 1 | 0,1550 [0,1331 ; 0,1789] (0,0390) | 12 / 15, 1 |
| A4 (A, ν = 4) | Grubbsr | oui | V3b | 1000 | 0,2350 [0,2090 ; 0,2625] (0,0845) | 21 / 23, 1 | 0,1550 [0,1331 ; 0,1789] (0,0410) | 14 / 17, 1 |
| A4 (A, ν = 4) | Grubbsr | oui | V3h | 1000 | 0,2550 [0,2282 ; 0,2832] (0,0985) | 18 / 0, 0,000114 | 0,1690 [0,1463 ; 0,1937] (0,0485) | 11 / 0, 0,0176 |
| A2 (A, ν = 2) | AD |  | V1 | 1000 | 0,3550 [0,3253 ; 0,3856] (0,1020) | — | 0,2530 [0,2263 ; 0,2811] (0,0450) | — |
| A2 (A, ν = 2) | AD |  | V3a | 1000 | 0,3580 [0,3282 ; 0,3886] (0,1000) | 14 / 11, 1 | 0,2490 [0,2225 ; 0,2770] (0,0435) | 5 / 9, 1 |
| A2 (A, ν = 2) | AD |  | V3b | 1000 | 0,3590 [0,3292 ; 0,3896] (0,1000) | 13 / 9, 1 | 0,2510 [0,2244 ; 0,2791] (0,0420) | 7 / 9, 1 |
| A2 (A, ν = 2) | AD |  | V3h | 1000 | 0,3580 [0,3282 ; 0,3886] (0,1020) | 4 / 1, 1 | 0,2520 [0,2254 ; 0,2801] (0,0450) | 2 / 3, 1 |
| A2 (A, ν = 2) | CvM |  | V1 | 1000 | 0,3170 [0,2882 ; 0,3468] (0,0970) | — | 0,2350 [0,2090 ; 0,2625] (0,0465) | — |
| A2 (A, ν = 2) | CvM |  | V3a | 1000 | 0,3210 [0,2921 ; 0,3509] (0,0985) | 8 / 4, 1 | 0,2330 [0,2071 ; 0,2605] (0,0465) | 6 / 8, 1 |
| A2 (A, ν = 2) | CvM |  | V3b | 1000 | 0,3210 [0,2921 ; 0,3509] (0,0955) | 9 / 5, 1 | 0,2320 [0,2062 ; 0,2594] (0,0465) | 3 / 6, 1 |
| A2 (A, ν = 2) | CvM |  | V3h | 1000 | 0,3160 [0,2873 ; 0,3458] (0,0935) | 1 / 2, 1 | 0,2320 [0,2062 ; 0,2594] (0,0470) | 0 / 3, 1 |
| A2 (A, ν = 2) | KS |  | V1 | 1000 | 0,2820 [0,2543 ; 0,3110] (0,0900) | — | 0,1970 [0,1728 ; 0,2230] (0,0460) | — |
| A2 (A, ν = 2) | KS |  | V3a | 1000 | 0,2790 [0,2514 ; 0,3079] (0,0885) | 5 / 8, 1 | 0,1950 [0,1709 ; 0,2209] (0,0425) | 7 / 9, 1 |
| A2 (A, ν = 2) | KS |  | V3b | 1000 | 0,2820 [0,2543 ; 0,3110] (0,0885) | 7 / 7, 1 | 0,1990 [0,1747 ; 0,2251] (0,0440) | 7 / 5, 1 |
| A2 (A, ν = 2) | KS |  | V3h | 1000 | 0,2790 [0,2514 ; 0,3079] (0,0885) | 0 / 3, 1 | 0,1930 [0,1690 ; 0,2189] (0,0455) | 0 / 4, 1 |
| A2 (A, ν = 2) | SW |  | V1 | 1000 | 0,4100 [0,3793 ; 0,4412] (0,0945) | — | 0,2750 [0,2475 ; 0,3038] (0,0445) | — |
| A2 (A, ν = 2) | SW |  | V3a | 1000 | 0,3930 [0,3626 ; 0,4241] (0,0925) | 5 / 22, 0,0182 | 0,2630 [0,2359 ; 0,2915] (0,0450) | 4 / 16, 0,142 |
| A2 (A, ν = 2) | SW |  | V3b | 1000 | 0,4060 [0,3754 ; 0,4372] (0,0915) | 9 / 13, 1 | 0,2700 [0,2427 ; 0,2987] (0,0455) | 7 / 12, 1 |
| A2 (A, ν = 2) | SW |  | V3h | 1000 | 0,4150 [0,3843 ; 0,4463] (0,0960) | 5 / 0, 0,75 | 0,2800 [0,2524 ; 0,3089] (0,0460) | 5 / 0, 0,688 |
| A2 (A, ν = 2) | SF | oui | V1 | 1000 | 0,3850 [0,3547 ; 0,4160] (0,0850) | — | 0,2730 [0,2456 ; 0,3018] (0,0460) | — |
| A2 (A, ν = 2) | SF | oui | V3a | 1000 | 0,3790 [0,3488 ; 0,4099] (0,0830) | 12 / 18, 1 | 0,2600 [0,2331 ; 0,2884] (0,0405) | 10 / 23, 0,631 |
| A2 (A, ν = 2) | SF | oui | V3b | 1000 | 0,3830 [0,3528 ; 0,4139] (0,0800) | 15 / 17, 1 | 0,2590 [0,2321 ; 0,2873] (0,0405) | 12 / 26, 0,57 |
| A2 (A, ν = 2) | SF | oui | V3h | 1000 | 0,3980 [0,3675 ; 0,4291] (0,0925) | 13 / 0, 0,00391 | 0,2830 [0,2553 ; 0,3120] (0,0490) | 10 / 0, 0,0332 |
| A2 (A, ν = 2) | JB | oui | V1 | 1000 | 0,3700 [0,3400 ; 0,4008] (0,0850) | — | 0,2240 [0,1985 ; 0,2511] (0,0405) | — |
| A2 (A, ν = 2) | JB | oui | V3a | 1000 | 0,3610 [0,3312 ; 0,3916] (0,0855) | 28 / 37, 1 | 0,2310 [0,2052 ; 0,2584] (0,0400) | 36 / 29, 1 |
| A2 (A, ν = 2) | JB | oui | V3b | 1000 | 0,3560 [0,3263 ; 0,3866] (0,0845) | 26 / 40, 1 | 0,2310 [0,2052 ; 0,2584] (0,0425) | 34 / 27, 1 |
| A2 (A, ν = 2) | JB | oui | V3h | 1000 | 0,3960 [0,3655 ; 0,4271] (0,1020) | 26 / 0, 6,56e-07 | 0,2580 [0,2311 ; 0,2863] (0,0490) | 34 / 0, 2,56e-09 |
| A2 (A, ν = 2) | DW |  | V1 | 1000 | 0,0740 [0,0585 ; 0,0920] (0,1025) | — | 0,0330 [0,0228 ; 0,0460] (0,0480) | — |
| A2 (A, ν = 2) | DW |  | V3a | 1000 | 0,0720 [0,0568 ; 0,0898] (0,1030) | 12 / 14, 1 | 0,0320 [0,0220 ; 0,0449] (0,0540) | 4 / 5, 1 |
| A2 (A, ν = 2) | DW |  | V3b | 1000 | 0,0720 [0,0568 ; 0,0898] (0,1060) | 12 / 14, 1 | 0,0330 [0,0228 ; 0,0460] (0,0535) | 4 / 4, 1 |
| A2 (A, ν = 2) | DW |  | V3h | 1000 | 0,0810 [0,0648 ; 0,0997] (0,1110) | 7 / 0, 0,203 | 0,0340 [0,0237 ; 0,0472] (0,0535) | 1 / 0, 1 |
| A2 (A, ν = 2) | LB1 |  | V1 | 1000 | 0,0740 [0,0585 ; 0,0920] (0,1090) | — | 0,0310 [0,0212 ; 0,0437] (0,0530) | — |
| A2 (A, ν = 2) | LB1 |  | V3a | 1000 | 0,0770 [0,0612 ; 0,0953] (0,1130) | 4 / 1, 1 | 0,0320 [0,0220 ; 0,0449] (0,0505) | 4 / 3, 1 |
| A2 (A, ν = 2) | LB1 |  | V3b | 1000 | 0,0780 [0,0621 ; 0,0964] (0,1110) | 5 / 1, 1 | 0,0310 [0,0212 ; 0,0437] (0,0500) | 3 / 3, 1 |
| A2 (A, ν = 2) | LB1 |  | V3h | 1000 | 0,0770 [0,0612 ; 0,0953] (0,1135) | 4 / 1, 1 | 0,0330 [0,0228 ; 0,0460] (0,0550) | 2 / 0, 1 |
| A2 (A, ν = 2) | supF |  | V1 | 1000 | 0,0790 [0,0630 ; 0,0975] (0,0935) | — | 0,0390 [0,0279 ; 0,0529] (0,0515) | — |
| A2 (A, ν = 2) | supF |  | V3a | 1000 | 0,0800 [0,0639 ; 0,0986] (0,0920) | 10 / 9, 1 | 0,0340 [0,0237 ; 0,0472] (0,0555) | 2 / 7, 1 |
| A2 (A, ν = 2) | supF |  | V3b | 1000 | 0,0820 [0,0657 ; 0,1008] (0,0905) | 9 / 6, 1 | 0,0320 [0,0220 ; 0,0449] (0,0555) | 3 / 10, 1 |
| A2 (A, ν = 2) | supF |  | V3h | 1000 | 0,0810 [0,0648 ; 0,0997] (0,0950) | 2 / 0, 1 | 0,0420 [0,0304 ; 0,0564] (0,0530) | 3 / 0, 1 |
| A2 (A, ν = 2) | CUSUM |  | V1 | 1000 | 0,0770 [0,0612 ; 0,0953] (0,0990) | — | 0,0300 [0,0203 ; 0,0426] (0,0480) | — |
| A2 (A, ν = 2) | CUSUM |  | V3a | 1000 | 0,0750 [0,0594 ; 0,0931] (0,0990) | 5 / 7, 1 | 0,0310 [0,0212 ; 0,0437] (0,0475) | 5 / 4, 1 |
| A2 (A, ν = 2) | CUSUM |  | V3b | 1000 | 0,0770 [0,0612 ; 0,0953] (0,0995) | 5 / 5, 1 | 0,0280 [0,0187 ; 0,0402] (0,0510) | 3 / 5, 1 |
| A2 (A, ν = 2) | CUSUM |  | V3h | 1000 | 0,0770 [0,0612 ; 0,0953] (0,0990) | 0 / 0, 1 | 0,0300 [0,0203 ; 0,0426] (0,0470) | 1 / 1, 1 |
| A2 (A, ν = 2) | Grubbs | oui | V1 | 1000 | 0,2740 [0,2466 ; 0,3028] (0,0835) | — | 0,1970 [0,1728 ; 0,2230] (0,0415) | — |
| A2 (A, ν = 2) | Grubbs | oui | V3a | 1000 | 0,2620 [0,2350 ; 0,2904] (0,0835) | 15 / 27, 1 | 0,1870 [0,1633 ; 0,2126] (0,0400) | 14 / 24, 1 |
| A2 (A, ν = 2) | Grubbs | oui | V3b | 1000 | 0,2580 [0,2311 ; 0,2863] (0,0845) | 13 / 29, 0,351 | 0,1880 [0,1642 ; 0,2136] (0,0430) | 14 / 23, 1 |
| A2 (A, ν = 2) | Grubbs | oui | V3h | 1000 | 0,2870 [0,2591 ; 0,3161] (0,1000) | 13 / 0, 0,00391 | 0,2110 [0,1861 ; 0,2376] (0,0515) | 14 / 0, 0,00244 |
| A2 (A, ν = 2) | Lillie |  | V1 | 1000 | 0,3120 [0,2834 ; 0,3417] (0,0880) | — | 0,2010 [0,1766 ; 0,2272] (0,0480) | — |
| A2 (A, ν = 2) | Lillie |  | V3a | 1000 | 0,3070 [0,2785 ; 0,3366] (0,0875) | 3 / 8, 1 | 0,1980 [0,1737 ; 0,2241] (0,0465) | 9 / 12, 1 |
| A2 (A, ν = 2) | Lillie |  | V3b | 1000 | 0,3080 [0,2795 ; 0,3376] (0,0860) | 2 / 6, 1 | 0,2050 [0,1804 ; 0,2314] (0,0435) | 14 / 10, 1 |
| A2 (A, ν = 2) | Lillie |  | V3h | 1000 | 0,3140 [0,2853 ; 0,3438] (0,0920) | 2 / 0, 1 | 0,2130 [0,1880 ; 0,2397] (0,0505) | 12 / 0, 0,00586 |
| A2 (A, ν = 2) | Intercept |  | V1 | 1000 | 0,1100 [0,0913 ; 0,1311] (0,0975) | — | 0,0510 [0,0382 ; 0,0665] (0,0535) | — |
| A2 (A, ν = 2) | Intercept |  | V3a | 1000 | 0,1260 [0,1061 ; 0,1482] (0,1035) | 22 / 6, 0,0409 | 0,0630 [0,0487 ; 0,0799] (0,0540) | 17 / 5, 0,186 |
| A2 (A, ν = 2) | Intercept |  | V3b | 1000 | 0,1210 [0,1014 ; 0,1428] (0,0995) | 18 / 7, 0,519 | 0,0600 [0,0461 ; 0,0766] (0,0560) | 15 / 6, 0,94 |
| A2 (A, ν = 2) | Intercept |  | V3h | 1000 | 0,1080 [0,0894 ; 0,1289] (0,0950) | 0 / 2, 1 | 0,0480 [0,0356 ; 0,0631] (0,0520) | 0 / 3, 1 |
| A2 (A, ν = 2) | RESET |  | V1 | 1000 | 0,1140 [0,0950 ; 0,1353] (0,0830) | — | 0,0710 [0,0559 ; 0,0887] (0,0325) | — |
| A2 (A, ν = 2) | RESET |  | V3a | 1000 | 0,1250 [0,1051 ; 0,1471] (0,0855) | 33 / 22, 1 | 0,0730 [0,0577 ; 0,0909] (0,0435) | 16 / 14, 1 |
| A2 (A, ν = 2) | RESET |  | V3b | 1000 | 0,1230 [0,1033 ; 0,1450] (0,0865) | 32 / 23, 1 | 0,0700 [0,0550 ; 0,0876] (0,0440) | 16 / 17, 1 |
| A2 (A, ν = 2) | RESET |  | V3h | 1000 | 0,1080 [0,0894 ; 0,1289] (0,0755) | 0 / 6, 0,344 | 0,0680 [0,0532 ; 0,0854] (0,0350) | 2 / 5, 1 |
| A2 (A, ν = 2) | BP |  | V1 | 1000 | 0,1210 [0,1014 ; 0,1428] (0,0850) | — | 0,0680 [0,0532 ; 0,0854] (0,0370) | — |
| A2 (A, ν = 2) | BP |  | V3a | 1000 | 0,0980 [0,0803 ; 0,1181] (0,0770) | 18 / 41, 0,0759 | 0,0400 [0,0287 ; 0,0541] (0,0365) | 11 / 39, 0,00198 |
| A2 (A, ν = 2) | BP |  | V3b | 1000 | 0,1010 [0,0830 ; 0,1214] (0,0780) | 17 / 37, 0,172 | 0,0430 [0,0313 ; 0,0575] (0,0380) | 13 / 38, 0,0137 |
| A2 (A, ν = 2) | BP |  | V3h | 1000 | 0,1380 [0,1172 ; 0,1609] (0,1095) | 17 / 0, 0,000275 | 0,0800 [0,0639 ; 0,0986] (0,0490) | 12 / 0, 0,00879 |
| A2 (A, ν = 2) | BP79 |  | V1 | 1000 | 0,1510 [0,1294 ; 0,1747] (0,0755) | — | 0,0900 [0,0730 ; 0,1095] (0,0365) | — |
| A2 (A, ν = 2) | BP79 |  | V3a | 1000 | 0,1190 [0,0996 ; 0,1407] (0,0680) | 15 / 47, 0,00127 | 0,0680 [0,0532 ; 0,0854] (0,0345) | 8 / 30, 0,00991 |
| A2 (A, ν = 2) | BP79 |  | V3b | 1000 | 0,1190 [0,0996 ; 0,1407] (0,0685) | 15 / 47, 0,00127 | 0,0700 [0,0550 ; 0,0876] (0,0355) | 10 / 30, 0,0444 |
| A2 (A, ν = 2) | BP79 |  | V3h | 1000 | 0,1660 [0,1434 ; 0,1905] (0,0965) | 15 / 0, 0,00104 | 0,1000 [0,0821 ; 0,1203] (0,0485) | 10 / 0, 0,0332 |
| A2 (A, ν = 2) | White |  | V1 | 1000 | 0,1180 [0,0987 ; 0,1396] (0,0880) | — | 0,0880 [0,0712 ; 0,1073] (0,0400) | — |
| A2 (A, ν = 2) | White |  | V3a | 1000 | 0,1150 [0,0959 ; 0,1364] (0,0825) | 8 / 11, 1 | 0,0730 [0,0577 ; 0,0909] (0,0360) | 5 / 20, 0,0815 |
| A2 (A, ν = 2) | White |  | V3b | 1000 | 0,1170 [0,0977 ; 0,1386] (0,0810) | 9 / 10, 1 | 0,0720 [0,0568 ; 0,0898] (0,0360) | 4 / 20, 0,0324 |
| A2 (A, ν = 2) | White |  | V3h | 1000 | 0,1200 [0,1005 ; 0,1418] (0,0890) | 2 / 0, 1 | 0,0900 [0,0730 ; 0,1095] (0,0420) | 2 / 0, 1 |
| A2 (A, ν = 2) | GQ |  | V1 | 1000 | 0,0990 [0,0812 ; 0,1192] (0,0545) | — | 0,0300 [0,0203 ; 0,0426] (0,0290) | — |
| A2 (A, ν = 2) | GQ |  | V3a | 1000 | 0,0940 [0,0766 ; 0,1138] (0,1020) | 50 / 55, 1 | 0,0410 [0,0296 ; 0,0552] (0,0485) | 28 / 17, 1 |
| A2 (A, ν = 2) | GQ |  | V3b | 1000 | 0,0950 [0,0775 ; 0,1149] (0,1000) | 51 / 55, 1 | 0,0430 [0,0313 ; 0,0575] (0,0495) | 28 / 15, 1 |
| A2 (A, ν = 2) | GQ |  | V3h | 1000 | 0,1180 [0,0987 ; 0,1396] (0,0790) | 19 / 0, 7,63e-05 | 0,0380 [0,0270 ; 0,0518] (0,0405) | 8 / 0, 0,117 |
| A2 (A, ν = 2) | BF |  | V1 | 1000 | 0,1330 [0,1126 ; 0,1556] (0,0860) | — | 0,0760 [0,0603 ; 0,0942] (0,0455) | — |
| A2 (A, ν = 2) | BF |  | V3a | 1000 | 0,1130 [0,0940 ; 0,1343] (0,0865) | 8 / 28, 0,0251 | 0,0670 [0,0523 ; 0,0843] (0,0445) | 8 / 17, 1 |
| A2 (A, ν = 2) | BF |  | V3b | 1000 | 0,1120 [0,0931 ; 0,1332] (0,0875) | 7 / 28, 0,0107 | 0,0640 [0,0496 ; 0,0810] (0,0455) | 7 / 19, 0,521 |
| A2 (A, ν = 2) | BF |  | V3h | 1000 | 0,1400 [0,1191 ; 0,1631] (0,1095) | 7 / 0, 0,203 | 0,0830 [0,0666 ; 0,1019] (0,0565) | 7 / 0, 0,219 |
| A2 (A, ν = 2) | Smirnov |  | V1 | 1000 | 0,0280 [0,0187 ; 0,0402] (0,0275) | — | 0,0280 [0,0187 ; 0,0402] (0,0275) | — |
| A2 (A, ν = 2) | Smirnov |  | V3a | 1000 | 0,0290 [0,0195 ; 0,0414] (0,0290) | 1 / 0, 1 | 0,0270 [0,0179 ; 0,0390] (0,0275) | 0 / 1, 1 |
| A2 (A, ν = 2) | Smirnov |  | V3b | 1000 | 0,0280 [0,0187 ; 0,0402] (0,0275) | 0 / 0, 1 | 0,0280 [0,0187 ; 0,0402] (0,0275) | 0 / 0, 1 |
| A2 (A, ν = 2) | Smirnov |  | V3h | 1000 | 0,0280 [0,0187 ; 0,0402] (0,0275) | 0 / 0, 1 | 0,0280 [0,0187 ; 0,0402] (0,0275) | 0 / 0, 1 |
| A2 (A, ν = 2) | LB2 |  | V1 | 1000 | 0,0780 [0,0621 ; 0,0964] (0,1065) | — | 0,0340 [0,0237 ; 0,0472] (0,0530) | — |
| A2 (A, ν = 2) | LB2 |  | V3a | 1000 | 0,0870 [0,0703 ; 0,1062] (0,1005) | 12 / 3, 0,668 | 0,0380 [0,0270 ; 0,0518] (0,0545) | 8 / 4, 1 |
| A2 (A, ν = 2) | LB2 |  | V3b | 1000 | 0,0870 [0,0703 ; 0,1062] (0,0980) | 12 / 3, 0,598 | 0,0390 [0,0279 ; 0,0529] (0,0540) | 8 / 3, 1 |
| A2 (A, ν = 2) | LB2 |  | V3h | 1000 | 0,0790 [0,0630 ; 0,0975] (0,1010) | 1 / 0, 1 | 0,0340 [0,0237 ; 0,0472] (0,0505) | 2 / 2, 1 |
| A2 (A, ν = 2) | BP2 |  | V1 | 1000 | 0,0790 [0,0630 ; 0,0975] (0,1040) | — | 0,0350 [0,0245 ; 0,0483] (0,0530) | — |
| A2 (A, ν = 2) | BP2 |  | V3a | 1000 | 0,0770 [0,0612 ; 0,0953] (0,1025) | 9 / 11, 1 | 0,0350 [0,0245 ; 0,0483] (0,0550) | 4 / 4, 1 |
| A2 (A, ν = 2) | BP2 |  | V3b | 1000 | 0,0770 [0,0612 ; 0,0953] (0,1015) | 8 / 10, 1 | 0,0380 [0,0270 ; 0,0518] (0,0560) | 6 / 3, 1 |
| A2 (A, ν = 2) | BP2 |  | V3h | 1000 | 0,0780 [0,0621 ; 0,0964] (0,1025) | 0 / 1, 1 | 0,0350 [0,0245 ; 0,0483] (0,0510) | 2 / 2, 1 |
| A2 (A, ν = 2) | Runs |  | V1 | 1000 | 0,0410 [0,0296 ; 0,0552] (0,0635) | — | 0,0090 [0,0041 ; 0,0170] (0,0075) | — |
| A2 (A, ν = 2) | Runs |  | V3a | 1000 | 0,0410 [0,0296 ; 0,0552] (0,0610) | 1 / 1, 1 | 0,0120 [0,0062 ; 0,0209] (0,0145) | 5 / 2, 1 |
| A2 (A, ν = 2) | Runs |  | V3b | 1000 | 0,0410 [0,0296 ; 0,0552] (0,0635) | 0 / 0, 1 | 0,0080 [0,0035 ; 0,0157] (0,0095) | 5 / 6, 1 |
| A2 (A, ν = 2) | Runs |  | V3h | 1000 | 0,0410 [0,0296 ; 0,0552] (0,0635) | 0 / 0, 1 | 0,0060 [0,0022 ; 0,0130] (0,0065) | 0 / 3, 1 |
| A2 (A, ν = 2) | MK |  | V1 | 1000 | 0,0670 [0,0523 ; 0,0843] (0,0650) | — | 0,0280 [0,0187 ; 0,0402] (0,0290) | — |
| A2 (A, ν = 2) | MK |  | V3a | 1000 | 0,0690 [0,0541 ; 0,0865] (0,0715) | 17 / 15, 1 | 0,0330 [0,0228 ; 0,0460] (0,0355) | 11 / 6, 1 |
| A2 (A, ν = 2) | MK |  | V3b | 1000 | 0,0730 [0,0577 ; 0,0909] (0,0755) | 19 / 13, 1 | 0,0330 [0,0228 ; 0,0460] (0,0375) | 11 / 6, 1 |
| A2 (A, ν = 2) | MK |  | V3h | 1000 | 0,0630 [0,0487 ; 0,0799] (0,0635) | 2 / 6, 1 | 0,0290 [0,0195 ; 0,0414] (0,0295) | 1 / 0, 1 |
| A2 (A, ν = 2) | SpearVol |  | V1 | 1000 | 0,1000 [0,0821 ; 0,1203] (0,0965) | — | 0,0460 [0,0339 ; 0,0609] (0,0505) | — |
| A2 (A, ν = 2) | SpearVol |  | V3a | 1000 | 0,1100 [0,0913 ; 0,1311] (0,1020) | 15 / 5, 0,745 | 0,0550 [0,0417 ; 0,0710] (0,0470) | 11 / 2, 0,427 |
| A2 (A, ν = 2) | SpearVol |  | V3b | 1000 | 0,1110 [0,0922 ; 0,1321] (0,1020) | 13 / 2, 0,148 | 0,0560 [0,0426 ; 0,0721] (0,0530) | 11 / 1, 0,121 |
| A2 (A, ν = 2) | SpearVol |  | V3h | 1000 | 0,1010 [0,0830 ; 0,1214] (0,0975) | 1 / 0, 1 | 0,0480 [0,0356 ; 0,0631] (0,0515) | 2 / 0, 1 |
| A2 (A, ν = 2) | SpearTps |  | V1 | 1000 | 0,0840 [0,0676 ; 0,1029] (0,0885) | — | 0,0360 [0,0253 ; 0,0495] (0,0390) | — |
| A2 (A, ν = 2) | SpearTps |  | V3a | 1000 | 0,0850 [0,0685 ; 0,1040] (0,0845) | 16 / 15, 1 | 0,0350 [0,0245 ; 0,0483] (0,0420) | 7 / 8, 1 |
| A2 (A, ν = 2) | SpearTps |  | V3b | 1000 | 0,0850 [0,0685 ; 0,1040] (0,0875) | 16 / 15, 1 | 0,0370 [0,0262 ; 0,0506] (0,0445) | 8 / 7, 1 |
| A2 (A, ν = 2) | SpearTps |  | V3h | 1000 | 0,0790 [0,0630 ; 0,0975] (0,0825) | 1 / 6, 1 | 0,0370 [0,0262 ; 0,0506] (0,0405) | 2 / 1, 1 |
| A2 (A, ν = 2) | DAgo | oui | V1 | 1000 | 0,3540 [0,3243 ; 0,3845] (0,0815) | — | 0,2230 [0,1975 ; 0,2501] (0,0400) | — |
| A2 (A, ν = 2) | DAgo | oui | V3a | 1000 | 0,3480 [0,3185 ; 0,3784] (0,0810) | 25 / 31, 1 | 0,2150 [0,1899 ; 0,2418] (0,0395) | 20 / 28, 1 |
| A2 (A, ν = 2) | DAgo | oui | V3b | 1000 | 0,3430 [0,3136 ; 0,3734] (0,0810) | 28 / 39, 1 | 0,2240 [0,1985 ; 0,2511] (0,0415) | 28 / 27, 1 |
| A2 (A, ν = 2) | DAgo | oui | V3h | 1000 | 0,3800 [0,3498 ; 0,4109] (0,0985) | 26 / 0, 6,56e-07 | 0,2500 [0,2234 ; 0,2781] (0,0510) | 27 / 0, 3,13e-07 |
| A2 (A, ν = 2) | CoxStuart |  | V1 | 1000 | 0,0000 [0,0000 ; 0,0037] (0,0000) | — | 0,0000 [0,0000 ; 0,0037] (0,0000) | — |
| A2 (A, ν = 2) | CoxStuart |  | V3a | 1000 | 0,0050 [0,0016 ; 0,0116] (0,0030) | 5 / 0, 0,625 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 |
| A2 (A, ν = 2) | CoxStuart |  | V3b | 1000 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 |
| A2 (A, ν = 2) | CoxStuart |  | V3h | 1000 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 | 0,0000 [0,0000 ; 0,0037] (0,0000) | 0 / 0, 1 |
| A2 (A, ν = 2) | DWr |  | V1 | 1000 | 0,0630 [0,0487 ; 0,0799] (0,0920) | — | 0,0300 [0,0203 ; 0,0426] (0,0455) | — |
| A2 (A, ν = 2) | DWr |  | V3a | 1000 | 0,0670 [0,0523 ; 0,0843] (0,0965) | 20 / 16, 1 | 0,0330 [0,0228 ; 0,0460] (0,0560) | 7 / 4, 1 |
| A2 (A, ν = 2) | DWr |  | V3b | 1000 | 0,0670 [0,0523 ; 0,0843] (0,1010) | 19 / 15, 1 | 0,0340 [0,0237 ; 0,0472] (0,0575) | 9 / 5, 1 |
| A2 (A, ν = 2) | DWr |  | V3h | 1000 | 0,0720 [0,0568 ; 0,0898] (0,1000) | 9 / 0, 0,0547 | 0,0330 [0,0228 ; 0,0460] (0,0515) | 3 / 0, 1 |
| A2 (A, ν = 2) | LB1r |  | V1 | 1000 | 0,0600 [0,0461 ; 0,0766] (0,1035) | — | 0,0330 [0,0228 ; 0,0460] (0,0525) | — |
| A2 (A, ν = 2) | LB1r |  | V3a | 1000 | 0,0650 [0,0505 ; 0,0821] (0,1105) | 6 / 1, 1 | 0,0330 [0,0228 ; 0,0460] (0,0480) | 3 / 3, 1 |
| A2 (A, ν = 2) | LB1r |  | V3b | 1000 | 0,0660 [0,0514 ; 0,0832] (0,1105) | 9 / 3, 1 | 0,0320 [0,0220 ; 0,0449] (0,0505) | 3 / 4, 1 |
| A2 (A, ν = 2) | LB1r |  | V3h | 1000 | 0,0650 [0,0505 ; 0,0821] (0,1130) | 5 / 0, 0,625 | 0,0360 [0,0253 ; 0,0495] (0,0545) | 3 / 0, 1 |
| A2 (A, ν = 2) | Runsr |  | V1 | 1000 | 0,0360 [0,0253 ; 0,0495] (0,0610) | — | 0,0080 [0,0035 ; 0,0157] (0,0105) | — |
| A2 (A, ν = 2) | Runsr |  | V3a | 1000 | 0,0350 [0,0245 ; 0,0483] (0,0585) | 0 / 1, 1 | 0,0100 [0,0048 ; 0,0183] (0,0145) | 3 / 1, 1 |
| A2 (A, ν = 2) | Runsr |  | V3b | 1000 | 0,0360 [0,0253 ; 0,0495] (0,0610) | 0 / 0, 1 | 0,0080 [0,0035 ; 0,0157] (0,0105) | 3 / 3, 1 |
| A2 (A, ν = 2) | Runsr |  | V3h | 1000 | 0,0360 [0,0253 ; 0,0495] (0,0610) | 0 / 0, 1 | 0,0060 [0,0022 ; 0,0130] (0,0090) | 0 / 2, 1 |
| A2 (A, ν = 2) | supFr |  | V1 | 1000 | 0,0730 [0,0577 ; 0,0909] (0,1010) | — | 0,0460 [0,0339 ; 0,0609] (0,0490) | — |
| A2 (A, ν = 2) | supFr |  | V3a | 1000 | 0,0750 [0,0594 ; 0,0931] (0,1020) | 7 / 5, 1 | 0,0480 [0,0356 ; 0,0631] (0,0510) | 5 / 3, 1 |
| A2 (A, ν = 2) | supFr |  | V3b | 1000 | 0,0750 [0,0594 ; 0,0931] (0,1040) | 6 / 4, 1 | 0,0440 [0,0321 ; 0,0586] (0,0535) | 3 / 5, 1 |
| A2 (A, ν = 2) | supFr |  | V3h | 1000 | 0,0730 [0,0577 ; 0,0909] (0,1045) | 0 / 0, 1 | 0,0460 [0,0339 ; 0,0609] (0,0510) | 1 / 1, 1 |
| A2 (A, ν = 2) | CUSUMr |  | V1 | 1000 | 0,0750 [0,0594 ; 0,0931] (0,0995) | — | 0,0330 [0,0228 ; 0,0460] (0,0505) | — |
| A2 (A, ν = 2) | CUSUMr |  | V3a | 1000 | 0,0760 [0,0603 ; 0,0942] (0,1020) | 5 / 4, 1 | 0,0310 [0,0212 ; 0,0437] (0,0500) | 2 / 4, 1 |
| A2 (A, ν = 2) | CUSUMr |  | V3b | 1000 | 0,0740 [0,0585 ; 0,0920] (0,0995) | 4 / 5, 1 | 0,0310 [0,0212 ; 0,0437] (0,0505) | 1 / 3, 1 |
| A2 (A, ν = 2) | CUSUMr |  | V3h | 1000 | 0,0760 [0,0603 ; 0,0942] (0,0990) | 1 / 0, 1 | 0,0340 [0,0237 ; 0,0472] (0,0475) | 1 / 0, 1 |
| A2 (A, ν = 2) | Grubbsr | oui | V1 | 1000 | 0,3180 [0,2892 ; 0,3479] (0,0845) | — | 0,2270 [0,2014 ; 0,2542] (0,0390) | — |
| A2 (A, ν = 2) | Grubbsr | oui | V3a | 1000 | 0,3150 [0,2863 ; 0,3448] (0,0870) | 18 / 21, 1 | 0,2190 [0,1937 ; 0,2459] (0,0390) | 14 / 22, 1 |
| A2 (A, ν = 2) | Grubbsr | oui | V3b | 1000 | 0,3160 [0,2873 ; 0,3458] (0,0845) | 21 / 23, 1 | 0,2230 [0,1975 ; 0,2501] (0,0410) | 16 / 20, 1 |
| A2 (A, ν = 2) | Grubbsr | oui | V3h | 1000 | 0,3370 [0,3077 ; 0,3672] (0,0985) | 19 / 0, 7,63e-05 | 0,2410 [0,2148 ; 0,2687] (0,0485) | 14 / 0, 0,00244 |

### C4c (descriptif) -- puissance de l'ensemble cible par régime de δ̂* (α = 0,10 ; tous / δ̂* = 0 / intérieur / δ̂* = 1)

| Scénario | Statistique | n (tous ; 0 ; int. ; 1) | V1 | V3a | V3b | V3h |
| --- | --- | --- | --- | --- | --- | --- |
| H0 (H, k = 0) | BP | 1000 ; 871 ; 67 ; 62 | 0,185 ; 0,208 ; 0,000 ; 0,065 | 0,158 ; 0,175 ; 0,045 ; 0,048 | 0,158 ; 0,177 ; 0,030 ; 0,032 | 0,187 ; 0,208 ; 0,030 ; 0,065 |
| H0 (H, k = 0) | BP79 | 1000 ; 871 ; 67 ; 62 | 0,261 ; 0,299 ; 0,000 ; 0,016 | 0,207 ; 0,234 ; 0,045 ; 0,000 | 0,204 ; 0,232 ; 0,030 ; 0,000 | 0,263 ; 0,299 ; 0,030 ; 0,016 |
| H0 (H, k = 0) | White | 1000 ; 871 ; 67 ; 62 | 0,108 ; 0,118 ; 0,045 ; 0,032 | 0,133 ; 0,148 ; 0,045 ; 0,016 | 0,134 ; 0,149 ; 0,045 ; 0,016 | 0,108 ; 0,118 ; 0,045 ; 0,032 |
| H0 (H, k = 0) | GQ | 1000 ; 871 ; 67 ; 62 | 0,165 ; 0,185 ; 0,000 ; 0,065 | 0,141 ; 0,147 ; 0,090 ; 0,113 | 0,141 ; 0,148 ; 0,075 ; 0,113 | 0,170 ; 0,185 ; 0,075 ; 0,065 |
| H0 (H, k = 0) | BF | 1000 ; 871 ; 67 ; 62 | 0,178 ; 0,191 ; 0,045 ; 0,145 | 0,137 ; 0,146 ; 0,090 ; 0,065 | 0,145 ; 0,153 ; 0,104 ; 0,081 | 0,182 ; 0,191 ; 0,104 ; 0,145 |
| H3 (H, k = 3) | BP | 1000 ; 124 ; 76 ; 800 | 0,280 ; 0,048 ; 0,000 ; 0,343 | 0,201 ; 0,032 ; 0,132 ; 0,234 | 0,205 ; 0,032 ; 0,118 ; 0,240 | 0,289 ; 0,048 ; 0,118 ; 0,343 |
| H3 (H, k = 3) | BP79 | 1000 ; 124 ; 76 ; 800 | 0,300 ; 0,032 ; 0,013 ; 0,369 | 0,222 ; 0,024 ; 0,145 ; 0,260 | 0,223 ; 0,024 ; 0,118 ; 0,264 | 0,308 ; 0,032 ; 0,118 ; 0,369 |
| H3 (H, k = 3) | White | 1000 ; 124 ; 76 ; 800 | 0,260 ; 0,040 ; 0,132 ; 0,306 | 0,195 ; 0,056 ; 0,118 ; 0,224 | 0,193 ; 0,056 ; 0,118 ; 0,221 | 0,259 ; 0,040 ; 0,118 ; 0,306 |
| H3 (H, k = 3) | GQ | 1000 ; 124 ; 76 ; 800 | 0,165 ; 0,040 ; 0,000 ; 0,200 | 0,134 ; 0,129 ; 0,066 ; 0,141 | 0,138 ; 0,129 ; 0,079 ; 0,145 | 0,171 ; 0,040 ; 0,079 ; 0,200 |
| H3 (H, k = 3) | BF | 1000 ; 124 ; 76 ; 800 | 0,182 ; 0,048 ; 0,053 ; 0,215 | 0,139 ; 0,024 ; 0,158 ; 0,155 | 0,144 ; 0,024 ; 0,158 ; 0,161 | 0,190 ; 0,048 ; 0,158 ; 0,215 |
| C3 (C, λ = 3) | Grubbs | 1000 ; 425 ; 143 ; 432 | 0,334 ; 0,369 ; 0,105 ; 0,375 | 0,329 ; 0,334 ; 0,301 ; 0,333 | 0,331 ; 0,334 ; 0,322 ; 0,331 | 0,365 ; 0,369 ; 0,322 ; 0,375 |
| C3 (C, λ = 3) | Grubbsr | 1000 ; 425 ; 143 ; 432 | 0,427 ; 0,492 ; 0,273 ; 0,414 | 0,403 ; 0,400 ; 0,378 ; 0,414 | 0,405 ; 0,402 ; 0,378 ; 0,417 | 0,442 ; 0,492 ; 0,378 ; 0,414 |
| C3 (C, λ = 3) | DAgo | 1000 ; 425 ; 143 ; 432 | 0,302 ; 0,344 ; 0,077 ; 0,336 | 0,284 ; 0,308 ; 0,203 ; 0,287 | 0,282 ; 0,301 ; 0,217 ; 0,285 | 0,322 ; 0,344 ; 0,217 ; 0,336 |
| C3 (C, λ = 3) | JB | 1000 ; 425 ; 143 ; 432 | 0,303 ; 0,341 ; 0,084 ; 0,338 | 0,280 ; 0,308 ; 0,133 ; 0,301 | 0,284 ; 0,311 ; 0,140 ; 0,306 | 0,311 ; 0,341 ; 0,140 ; 0,338 |
| C3 (C, λ = 3) | SF | 1000 ; 425 ; 143 ; 432 | 0,256 ; 0,278 ; 0,091 ; 0,289 | 0,232 ; 0,245 ; 0,112 ; 0,259 | 0,234 ; 0,247 ; 0,119 ; 0,259 | 0,260 ; 0,278 ; 0,119 ; 0,289 |
| C4 (C, λ = 4) | Grubbs | 1000 ; 450 ; 108 ; 442 | 0,576 ; 0,627 ; 0,194 ; 0,618 | 0,559 ; 0,571 ; 0,546 ; 0,550 | 0,565 ; 0,578 ; 0,537 ; 0,559 | 0,613 ; 0,627 ; 0,537 ; 0,618 |
| C4 (C, λ = 4) | Grubbsr | 1000 ; 450 ; 108 ; 442 | 0,678 ; 0,747 ; 0,380 ; 0,681 | 0,674 ; 0,696 ; 0,574 ; 0,676 | 0,677 ; 0,691 ; 0,565 ; 0,690 | 0,698 ; 0,747 ; 0,565 ; 0,681 |
| C4 (C, λ = 4) | DAgo | 1000 ; 450 ; 108 ; 442 | 0,527 ; 0,593 ; 0,148 ; 0,552 | 0,510 ; 0,560 ; 0,315 ; 0,507 | 0,517 ; 0,567 ; 0,324 ; 0,514 | 0,546 ; 0,593 ; 0,324 ; 0,552 |
| C4 (C, λ = 4) | JB | 1000 ; 450 ; 108 ; 442 | 0,530 ; 0,596 ; 0,148 ; 0,557 | 0,503 ; 0,562 ; 0,204 ; 0,516 | 0,509 ; 0,567 ; 0,213 ; 0,523 | 0,537 ; 0,596 ; 0,213 ; 0,557 |
| C4 (C, λ = 4) | SF | 1000 ; 450 ; 108 ; 442 | 0,457 ; 0,511 ; 0,157 ; 0,475 | 0,441 ; 0,493 ; 0,194 ; 0,448 | 0,440 ; 0,496 ; 0,213 ; 0,439 | 0,463 ; 0,511 ; 0,213 ; 0,475 |
| A4 (A, ν = 4) | DAgo | 1000 ; 421 ; 218 ; 361 | 0,211 ; 0,254 ; 0,037 ; 0,266 | 0,216 ; 0,223 ; 0,174 ; 0,233 | 0,217 ; 0,226 ; 0,165 ; 0,238 | 0,239 ; 0,254 ; 0,165 ; 0,266 |
| A4 (A, ν = 4) | JB | 1000 ; 421 ; 218 ; 361 | 0,215 ; 0,247 ; 0,050 ; 0,277 | 0,231 ; 0,221 ; 0,216 ; 0,252 | 0,227 ; 0,219 ; 0,211 ; 0,247 | 0,250 ; 0,247 ; 0,211 ; 0,277 |
| A4 (A, ν = 4) | SF | 1000 ; 421 ; 218 ; 361 | 0,236 ; 0,242 ; 0,142 ; 0,285 | 0,240 ; 0,221 ; 0,234 ; 0,266 | 0,245 ; 0,230 ; 0,234 ; 0,269 | 0,256 ; 0,242 ; 0,234 ; 0,285 |
| A4 (A, ν = 4) | Grubbs | 1000 ; 421 ; 218 ; 361 | 0,190 ; 0,233 ; 0,018 ; 0,244 | 0,194 ; 0,209 ; 0,124 ; 0,219 | 0,192 ; 0,214 ; 0,115 ; 0,213 | 0,211 ; 0,233 ; 0,115 ; 0,244 |
| A4 (A, ν = 4) | Grubbsr | 1000 ; 421 ; 218 ; 361 | 0,237 ; 0,316 ; 0,069 ; 0,247 | 0,231 ; 0,257 ; 0,133 ; 0,260 | 0,235 ; 0,261 ; 0,151 ; 0,255 | 0,255 ; 0,316 ; 0,151 ; 0,247 |
| A2 (A, ν = 2) | DAgo | 1000 ; 439 ; 186 ; 375 | 0,354 ; 0,360 ; 0,113 ; 0,467 | 0,348 ; 0,326 ; 0,247 ; 0,424 | 0,343 ; 0,326 ; 0,253 ; 0,408 | 0,380 ; 0,360 ; 0,253 ; 0,467 |
| A2 (A, ν = 2) | JB | 1000 ; 439 ; 186 ; 375 | 0,370 ; 0,362 ; 0,161 ; 0,483 | 0,361 ; 0,335 ; 0,312 ; 0,416 | 0,356 ; 0,330 ; 0,301 ; 0,413 | 0,396 ; 0,362 ; 0,301 ; 0,483 |
| A2 (A, ν = 2) | SF | 1000 ; 439 ; 186 ; 375 | 0,385 ; 0,369 ; 0,242 ; 0,475 | 0,379 ; 0,349 ; 0,301 ; 0,453 | 0,383 ; 0,353 ; 0,312 ; 0,453 | 0,398 ; 0,369 ; 0,312 ; 0,475 |
| A2 (A, ν = 2) | Grubbs | 1000 ; 439 ; 186 ; 375 | 0,274 ; 0,278 ; 0,027 ; 0,392 | 0,262 ; 0,251 ; 0,108 ; 0,352 | 0,258 ; 0,253 ; 0,097 ; 0,344 | 0,287 ; 0,278 ; 0,097 ; 0,392 |
| A2 (A, ν = 2) | Grubbsr | 1000 ; 439 ; 186 ; 375 | 0,318 ; 0,360 ; 0,070 ; 0,392 | 0,315 ; 0,317 ; 0,161 ; 0,389 | 0,316 ; 0,312 ; 0,172 ; 0,392 | 0,337 ; 0,360 ; 0,172 ; 0,392 |

### T3 -- B effectifs, tirages de V3b, p absentes, quasi-égalités (h2) et durées par régime

| Jeu | Régime | n | retenues de V1 : méd. [min ; max] | |A| de V3a : méd. [min ; max] | |A| de V3b : méd. [min ; max] | tirages de V3b : moyenne [méd. ; max] | B_max atteint | p absentes V1 ; V3a ; V3b (cellules réplication x statistique, motifs) | (h2) répl. avec ≥ 1 quasi-égalité (BP, BP79, White, BF, RESET, Intercept) | durée par réplication (s) : moyenne [méd. ; max] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| H0 (H, k = 0) | δ̂* = 0 | 871 | 999 [999 ; 999] | 608 [559 ; 660] | 999 [999 ; 999] | 1641 [1641 ; 1741] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 8,33 [8,22 ; 37,55] |
| H0 (H, k = 0) | δ̂* intérieur | 67 | 999 [999 ; 999] | 218 [151 ; 256] | 999 [999 ; 999] | 4632 [4607 ; 5472] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 14,73 [13,00 ; 44,55] |
| H0 (H, k = 0) | δ̂* = 1 | 62 | 999 [999 ; 999] | 500 [468 ; 531] | 999 [999 ; 999] | 1997 [1990 ; 2125] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 8,96 [8,96 ; 10,64] |
| H3 (H, k = 3) | δ̂* = 0 | 124 | 999 [999 ; 999] | 610 [563 ; 654] | 999 [999 ; 999] | 1640 [1636 ; 1723] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 8,73 [8,45 ; 36,50] |
| H3 (H, k = 3) | δ̂* intérieur | 76 | 999 [999 ; 999] | 217 [187 ; 263] | 999 [999 ; 999] | 4580 [4540 ; 5162] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 15,12 [13,37 ; 49,29] |
| H3 (H, k = 3) | δ̂* = 1 | 800 | 999 [999 ; 999] | 499 [455 ; 558] | 999 [999 ; 999] | 1999 [1999 ; 2131] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 9,57 [9,40 ; 43,73] |
| C3 (C, λ = 3) | δ̂* = 0 | 425 | 999 [999 ; 999] | 607 [561 ; 654] | 999 [999 ; 999] | 1642 [1642 ; 1735] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 8,52 [8,48 ; 38,45] |
| C3 (C, λ = 3) | δ̂* intérieur | 143 | 999 [999 ; 999] | 215 [178 ; 251] | 999 [999 ; 999] | 4665 [4620 ; 5512] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 14,36 [13,18 ; 64,33] |
| C3 (C, λ = 3) | δ̂* = 1 | 432 | 999 [999 ; 999] | 498 [456 ; 550] | 999 [999 ; 999] | 2000 [1997 ; 2140] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 9,38 [9,29 ; 44,05] |
| C4 (C, λ = 4) | δ̂* = 0 | 450 | 999 [999 ; 999] | 608 [565 ; 654] | 999 [999 ; 999] | 1642 [1644 ; 1741] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 1 ; 0 ; 0 | 8,71 [8,64 ; 38,99] |
| C4 (C, λ = 4) | δ̂* intérieur | 108 | 999 [999 ; 999] | 216 [168 ; 252] | 999 [999 ; 999] | 4673 [4598 ; 5496] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 14,89 [13,52 ; 51,79] |
| C4 (C, λ = 4) | δ̂* = 1 | 442 | 999 [999 ; 999] | 499 [453 ; 545] | 999 [999 ; 999] | 1999 [1997 ; 2140] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 9,81 [9,58 ; 43,29] |
| A4 (A, ν = 4) | δ̂* = 0 | 421 | 999 [999 ; 999] | 608 [563 ; 657] | 999 [999 ; 999] | 1643 [1642 ; 1738] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 8,93 [8,78 ; 38,86] |
| A4 (A, ν = 4) | δ̂* intérieur | 218 | 999 [999 ; 999] | 215 [169 ; 263] | 999 [999 ; 999] | 4644 [4572 ; 5625] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 14,53 [13,78 ; 70,60] |
| A4 (A, ν = 4) | δ̂* = 1 | 361 | 999 [999 ; 999] | 498 [452 ; 544] | 999 [999 ; 999] | 1995 [1993 ; 2137] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 9,85 [9,72 ; 43,56] |
| A2 (A, ν = 2) | δ̂* = 0 | 439 | 999 [999 ; 999] | 609 [562 ; 654] | 999 [999 ; 999] | 1640 [1640 ; 1737] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 9,16 [8,91 ; 41,54] |
| A2 (A, ν = 2) | δ̂* intérieur | 186 | 999 [999 ; 999] | 216 [169 ; 256] | 999 [999 ; 999] | 4642 [4600 ; 5438] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 14,93 [13,96 ; 68,24] |
| A2 (A, ν = 2) | δ̂* = 1 | 375 | 999 [999 ; 999] | 497 [448 ; 558] | 999 [999 ; 999] | 1998 [1995 ; 2136] | 0 (0,0000) | 0 ; 0 ; 0 | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 9,90 [9,83 ; 11,77] |

