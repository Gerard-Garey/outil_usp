## Conservatisme des p-values Monte-Carlo au régime δ̂ intérieur, T = 8 -- combinaison de 12 tranche(s) (issue #175)

Paramètres : jeu=J2;R=2000;graine_jeux=20260927;graine_boot=20260831;B=999;methode=premium;segment=1;annexe=II;nature=brutes;alpha=0.1;theta_equiv=0.1 | jeu=J1;R=2000;graine_jeux=20260927;graine_boot=20260831;B=999;methode=premium;segment=1;annexe=II;nature=brutes;alpha=0.1;theta_equiv=0.1

### T0 -- provenance (identique dans les tranches de chaque jeu, vérifié)

| Grandeur | Valeur |
| --- | --- |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Commit | 139031d4cd8b5f61cf369f659c34187c9d23078f |
| Plateforme de calcul (R, système, machine, BLAS, LAPACK) | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.12.0 ; LAPACK : /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.12.0 (version 3.12.0) |
| Empreintes md5 du code exécuté | R/engine.R 344a4e03751e97b14e5ca1b733b856c6 ; tests/outils_tests.R chargé (dépôt) da6d2baa426f053e3000fb324828f57e ; script exécuté (dépôt) f72e6b337e01e737d11a86259521615b ; tests/taux_franchissement_reperes.R b06bc851a1ee4a3ff8a166ede8768f1f |
| Contrôle (a) : J1 observé contre tests/reference/premium.rds | conforme ; 23740 feuille(s), 0 non strictement identique(s), écart maximal 0.000e+00 |
| Configuration | méthode premium, segment 1 de l'annexe II, données brutes, B = 999, α = 0.1 et 0.05 ; B_MIN_DEGENERESCENCE = 50 ; TOL_DELTA_BORD = 1e-06 |
| Périmètre (jeu, régime de δ̂*, statistiques) | J1 : interieur (BP, BP79, GQ, BF, Grubbs, Grubbsr, DAgo, JB, AD, White) ; bord0 (GQ, RESET) | J2 : interieur (BP, BP79, GQ, BF, Grubbs, Grubbsr, DAgo, JB, AD, White) ; bord0 (GQ, RESET) ; bord1 (GQ) |
| J2 : Jeu | J2 : xi, yi de tests/unitaires/test_controles_numeriques.R (δ estimé intérieur) |
| J2 : Modèle ajusté (usp_ajuster()) | δ̂ = 0.663991 ; γ̂ = -2.31999 ; β̂ = 0.701657 ; σ̂ = 0.0689553 |
| J2 : Graines | jeux simulés : un flux sous 20260927 (chemin de #72) ; bootstrap de la réplication b : 20260831 + b ; jeu observé : 20260831 |
| J2 : Graines en collision (déclarées, non bloquantes) | réplication 96 : graine du bootstrap 20260927 = graine des jeux simulés (héritée de #166, effet décrit dans son T0) ; réplication 70 : graine du bootstrap 20260901 = SEED_LOI_NULLE_SW (loi nulle de Shapiro-Wilk) (héritée de #166, effet décrit dans son T0) |
| J2 : Valeurs brutes de #221 | docs/tableaux/20261008-issue166-brut-J2.tsv |
| J2 : md5 des valeurs brutes de #221 | d2f4f06dfe0bfb5c8ecedb6da456a47d |
| J2 : Valeurs brutes de #221 suivies par git | oui |
| J2 : Réplications des valeurs brutes de #221 | 2000 |
| J2 : Tableau de #221 (T0 : md5 du moteur) | docs/tableaux/20261008-issue166-calibration-J2.md |
| J2 : md5 du tableau de #221 | 26bb6a08e623fbb8a111ada9202ab10e |
| J2 : Tableau de #221 suivi par git | oui |
| J2 : Contrôle (i3) | OK : md5 de R/engine.R 344a4e03751e97b14e5ca1b733b856c6, T0 du tableau de #221 344a4e03751e97b14e5ca1b733b856c6 ; paramètres du tableau conformes |
| J2 : Réplications | 2000 (1-250, 251-500, 501-750, 751-1000, 1001-1250, 1251-1500, 1501-1750, 1751-2000) |
| J2 : Durée cumulée (s) | contrôles et jeu observé 693 s ; intérieur 7954 s (464 répl., 17,1 s par réplication) ; bord 0 7994 s (814 répl., 9,8 s par réplication) ; bord 1 1759 s (722 répl., 2,4 s par réplication) ; non rejouées ou écartées 0 s (0 répl., — s par réplication) |
| J1 : Jeu | J1 : tests/donnees/donnees_ln.csv (jeu des cas de référence) |
| J1 : Modèle ajusté (usp_ajuster()) | δ̂ = 1 ; γ̂ = -1.93433 ; β̂ = 0.728685 ; σ̂ = 0.10531 |
| J1 : Graines | jeux simulés : un flux sous 20260927 (chemin de #72) ; bootstrap de la réplication b : 20260831 + b ; jeu observé : 20260831 |
| J1 : Graines en collision (déclarées, non bloquantes) | réplication 96 : graine du bootstrap 20260927 = graine des jeux simulés (héritée de #166, effet décrit dans son T0) ; réplication 70 : graine du bootstrap 20260901 = SEED_LOI_NULLE_SW (loi nulle de Shapiro-Wilk) (héritée de #166, effet décrit dans son T0) |
| J1 : Valeurs brutes de #221 | docs/tableaux/20261008-issue166-brut-J1.tsv |
| J1 : md5 des valeurs brutes de #221 | 30d2a3ce0bd258ce8474b8d421281071 |
| J1 : Valeurs brutes de #221 suivies par git | oui |
| J1 : Réplications des valeurs brutes de #221 | 2000 |
| J1 : Tableau de #221 (T0 : md5 du moteur) | docs/tableaux/20261008-issue166-calibration-J1.md |
| J1 : md5 du tableau de #221 | 69157d32eade77bdad958db0de5d607d |
| J1 : Tableau de #221 suivi par git | oui |
| J1 : Contrôle (i3) | OK : md5 de R/engine.R 344a4e03751e97b14e5ca1b733b856c6, T0 du tableau de #221 344a4e03751e97b14e5ca1b733b856c6 ; paramètres du tableau conformes |
| J1 : Réplications | 2000 (1-500, 501-1000, 1001-1500, 1501-2000) |
| J1 : Durée cumulée (s) | contrôles et jeu observé 323 s ; intérieur 1335 s (75 répl., 17,8 s par réplication) ; bord 0 9088 s (930 répl., 9,8 s par réplication) ; bord 1 0 s (0 répl., — s par réplication) ; non rejouées ou écartées 48 s (995 répl., 0,0 s par réplication) |
| Commit de la combinaison | 139031d4cd8b5f61cf369f659c34187c9d23078f |
| Empreintes md5 du combinateur | R/engine.R 344a4e03751e97b14e5ca1b733b856c6 ; tests/outils_tests.R chargé (dépôt) da6d2baa426f053e3000fb324828f57e ; script exécuté (dépôt) f72e6b337e01e737d11a86259521615b ; tests/taux_franchissement_reperes.R b06bc851a1ee4a3ff8a166ede8768f1f |
| Versionnable (--ecrire) | oui |
| Contrôles d'intégrité | OK dans les 12 tranche(s) ((a), (b), (c), (i1), (i2), (i3), (d), cohérence), invariants du corps vérifiés |

### Aide à la lecture

Statut : **constat de simulation sous le modèle ajusté au jeu** (usp_simuler(FIT0)), pas un résultat général. Réplications de la calibration de #166 / #221 ; bootstrap de chaque réplication rejoué (mêmes y**, contrôles (i1) et (i2)), trois p-values sur les mêmes y** : 1, moteur (usp_ajuster_rapide()) ; 2, δ fixé à δ̂*_b (usp_ajuster_contraint()), sur les mêmes réplications internes retenues que la variante 1 ; 3, conditionnelle au régime (réplications internes retenues dont δ̂** est dans le régime de δ̂*_b ; p absente si le B effectif est inférieur à B_MIN_DEGENERESCENCE = 50). **Aucune référence ne fonde la variante 3 à T = 8.** J1 est descriptif.

IC : Clopper-Pearson à 95 %, incertitude Monte-Carlo sur le taux (fonction du nombre de réplications), pas l'erreur d'approximation en T. Taux par régime : conditionnels à un événement fonction des données, sans référence exacte même pour une p parfaitement calibrée ; « α dans l'IC » se lit « aucune distorsion détectée à la précision Monte-Carlo », jamais « exact ». Bande de Bradley (1978) [α/2 ; 3α/2] : convention, pas théorème (règle de lecture de #166). Taux du critère : k / n_rep, n_rep étant le nombre de réplications rejouées du régime, dénominateur commun aux trois variantes, une p absente comptant comme un non-rejet ; le taux sur les seules p définies (k / n, colonne « taux sur n ») est descriptif, n étant choisi par les données (la variante 3 est sélectionnée par son B effectif).

**Critère de verdict, fixé avant l'exécution** : critère révisé du commentaire 6060869720 de la PR #228 (décision du mainteneur du 08/10/2026), qui modifie celui de la spécification d'actuary (#175, commentaire 6058041254) approuvé dans le commentaire 6058031276 de la PR #228 ; texte reporté sans modification :

> ## #175 : critère de verdict révisé avant l'exécution (décision du mainteneur, 08/10/2026)
>
> `actuary-approfondi` propose une révision en réponse aux questions de `coder` sur `tests/conservatisme_interieur_t8.R`, et le mainteneur l'approuve. Elle modifie le critère approuvé dans le commentaire 6058031276. Le texte est reporté dans le script et commité **avant** le lancement des tranches, ce qui le fixe d'avance.
>
> **Motifs**
> - La variante conditionnelle était jugée sur les seules p définies. C'est un sous-ensemble choisi par les données, avec un IC plus large, ce qui biaise le jugement en faveur de « proposer ».
> - RESET au bord 0 est déjà disjoint de la bande pour le moteur au 30/09, et p2 ≡ p1 pour cette statistique. La lecture absolue de la condition (2) éliminait donc la variante δ fixé avant toute mesure.
>
> **Critère révisé**
>
> *Grandeurs.*
> - Le critère se lit sur J2, à α = 0,10 ; T1' (α = 0,05) et J1 sont descriptifs.
> - Pour une cellule (régime, statistique, variante) :
>   - n_rep est le nombre de réplications rejouées du régime, le même pour les trois variantes ;
>   - k est le nombre de p définies et inférieures à 0,10 ; une p absente compte comme un non-rejet ;
>   - le taux vaut k / n_rep ;
>   - l'IC est celui de Clopper-Pearson à 95 % sur (k, n_rep).
> - La bande est [0,05 ; 0,15].
> - Les classes de #166 sont, dans l'ordre : compatible, écart mineur, écart non tranché, distorsion matérielle (IC disjoint).
>
> *« Proposer une évolution »* si une variante (2 ou 3) remplit les trois conditions suivantes.
> 1. **Correction.** Parmi les huit statistiques au régime intérieur, au moins 5 ont un IC du moteur disjoint de la bande et un IC de la variante non disjoint.
> 2. **Aucune distorsion créée, inversée ni aggravée** sur les treize cellules de J2 : les huit statistiques, AD et White au régime intérieur ; GQ aux régimes δ̂* = 0 et δ̂* = 1 ; RESET à δ̂* = 0.
>    - (a) Si l'IC du moteur n'est pas disjoint de la bande, celui de la variante ne l'est pas non plus.
>    - (b) S'il l'est, celui de la variante n'est pas disjoint du côté opposé, et son taux ne dépasse pas l'IC du moteur du côté de la distorsion.
> 3. **Témoins.** Pour AD et White, la classe de la variante n'est pas pire que celle du moteur.
>
> Sinon, *« conserver et documenter »*.
>
> *Lectures descriptives, hors critère :* taux sur les seules p définies (k / n) ; pour la variante 3, taux du moteur restreint aux réplications où p3 est définie ; J1 ; α = 0,05.
>
> **Autres changements.** (i2) est étendu à la première réplication intérieure de chaque tranche. Les deux constats mineurs de l'audit léger sont corrigés dans la même reprise : cellule à n = 0 jugée « non évaluable », variantes 2 et 3 calculées sur le sous-catalogue du régime.

Suites prévues par la spécification d'actuary : « proposer une évolution » ouvre une issue nouvelle, avec une calibration complète avant tout changement du moteur ; « conserver et documenter » porte dans les rubriques 7 des fiches la mention « perte de puissance conditionnelle au régime intérieur ».

Évaluation mécanique ci-dessous, **sans conclure** (le verdict revient à actuary), avec les lectures conformes au critère : « disjoint de la bande » (hors bande) = IC à 95 % sur les rejouées disjoint de [0,05 ; 0,15], côté conservateur (borne haute < 0,05) ou libéral (borne basse > 0,15) ; régimes mesurés = ceux de J2, soit les treize cellules de la condition (2) ; témoins par classes de #166 (compatible : 0,10 dans l'IC ; sinon distorsion matérielle : IC disjoint de la bande ; sinon écart mineur : taux dans la bande ; sinon écart non tranché). Une cellule sans réplication rejouée (n_rep = 0) est « non évaluable » ; une cellule sans aucune p définie (n = 0) est évaluée avec k = 0 (une p absente compte comme un non-rejet), et T1 l'indique par n = 0. Une cellule non évaluable ne remplit jamais (1) ni (2), ni (3) ; une condition dont les cellules évaluables ne suffisent pas à trancher est « non évaluable ».

**Angle mort du sous-catalogue.** Dans une réplication, les trois variantes ne calculent que les statistiques du périmètre de son régime : une réplication interne y est retenue si le réajustement rapide et ces statistiques aboutissent, alors que usp_bootstrap() exige que les 34 statistiques du catalogue aboutissent. Si une statistique hors périmètre échouait seule, la rétention différerait de celle du moteur, et la p de la variante 1 pourrait alors différer de celle de #221 (contrôle (i1)). Sur les essais de mise au point (J2 à R = 6, J1 à R = 5), aucun échec de réajustement ni de statistique n'a été compté (T2, T3).

**Évaluation mécanique du critère révisé** (J2, α = 0,10, taux et IC sur les rejouées) :

| Variante | (1) statistiques sur 8 : IC du moteur disjoint, IC de la variante non disjoint | (1) état | (2) cellules en défaut (sur 13) | (2) état | (3) AD et White : classe moteur → variante | (3) état | Trois conditions |
| --- | --- | --- | --- | --- | --- | --- | --- |
| δ fixé (usp_ajuster_contraint()) | 0 (aucune) | non remplie | GQ (δ̂* intérieur) : aggravée (taux sous la borne basse de l'IC du moteur) ; JB (δ̂* intérieur) : aggravée (taux sous la borne basse de l'IC du moteur) | non remplie | AD : compatible → compatible ; White : compatible → compatible | remplie | non remplies |
| conditionnelle au régime | 7 (BP, BP79, GQ, BF, Grubbs, DAgo, JB) | remplie | aucune | remplie | AD : compatible → compatible ; White : compatible → compatible | remplie | **remplies** (« proposer une évolution ») |

Cellules de la condition (2), taux sur les rejouées [IC 95 %] et classe de #166 :

| Cellule | rejouées | moteur | δ fixé | défaut (2) | conditionnelle au régime | défaut (2) |
| --- | --- | --- | --- | --- | --- | --- |
| BP (δ̂* intérieur) | 464 | 0,0000 [0,0000 ; 0,0079], distorsion matérielle | 0,0000 [0,0000 ; 0,0079], distorsion matérielle | aucun | 0,1013 [0,0754 ; 0,1324], compatible | aucun |
| BP79 (δ̂* intérieur) | 464 | 0,0000 [0,0000 ; 0,0079], distorsion matérielle | 0,0000 [0,0000 ; 0,0079], distorsion matérielle | aucun | 0,0884 [0,0642 ; 0,1180], compatible | aucun |
| GQ (δ̂* intérieur) | 464 | 0,0022 [0,0001 ; 0,0119], distorsion matérielle | 0,0000 [0,0000 ; 0,0079], distorsion matérielle | aggravée (taux sous la borne basse de l'IC du moteur) | 0,1034 [0,0773 ; 0,1348], compatible | aucun |
| BF (δ̂* intérieur) | 464 | 0,0172 [0,0075 ; 0,0337], distorsion matérielle | 0,0129 [0,0048 ; 0,0279], distorsion matérielle | aucun | 0,1185 [0,0906 ; 0,1515], compatible | aucun |
| Grubbs (δ̂* intérieur) | 464 | 0,0216 [0,0104 ; 0,0393], distorsion matérielle | 0,0108 [0,0035 ; 0,0250], distorsion matérielle | aucun | 0,0927 [0,0679 ; 0,1228], compatible | aucun |
| Grubbsr (δ̂* intérieur) | 464 | 0,0323 [0,0182 ; 0,0528], écart non tranché | 0,0323 [0,0182 ; 0,0528], écart non tranché | aucun | 0,0991 [0,0735 ; 0,1300], compatible | aucun |
| DAgo (δ̂* intérieur) | 464 | 0,0194 [0,0089 ; 0,0365], distorsion matérielle | 0,0172 [0,0075 ; 0,0337], distorsion matérielle | aucun | 0,0948 [0,0697 ; 0,1252], compatible | aucun |
| JB (δ̂* intérieur) | 464 | 0,0280 [0,0150 ; 0,0474], distorsion matérielle | 0,0129 [0,0048 ; 0,0279], distorsion matérielle | aggravée (taux sous la borne basse de l'IC du moteur) | 0,1034 [0,0773 ; 0,1348], compatible | aucun |
| AD (δ̂* intérieur) | 464 | 0,1121 [0,0848 ; 0,1444], compatible | 0,1013 [0,0754 ; 0,1324], compatible | aucun | 0,1078 [0,0810 ; 0,1396], compatible | aucun |
| White (δ̂* intérieur) | 464 | 0,1056 [0,0792 ; 0,1372], compatible | 0,0754 [0,0531 ; 0,1033], compatible | aucun | 0,1142 [0,0867 ; 0,1467], compatible | aucun |
| GQ (δ̂* = 0) | 814 | 0,0688 [0,0524 ; 0,0884], écart mineur | 0,0614 [0,0459 ; 0,0802], écart mineur | aucun | 0,0921 [0,0732 ; 0,1141], compatible | aucun |
| GQ (δ̂* = 1) | 722 | 0,0720 [0,0543 ; 0,0934], écart mineur | 0,0720 [0,0543 ; 0,0934], écart mineur | aucun | 0,1122 [0,0901 ; 0,1375], compatible | aucun |
| RESET (δ̂* = 0) | 814 | 0,0283 [0,0180 ; 0,0421], distorsion matérielle | 0,0283 [0,0180 ; 0,0421], distorsion matérielle | aucun | 0,1032 [0,0831 ; 0,1262], compatible | aucun |

### T1 -- α = 0,10 : fréquence de p < 0,10 par jeu, régime, statistique et variante

| Jeu | Régime | Statistique (sens) | Variante | rejouées (n_rep) | p définies (n) | < 0,10 : k | taux sur n (k / n) | IC 95 % sur n | taux sur les rejouées (k / n_rep, p absente = non-rejet) | IC 95 % sur les rejouées | α dans l'IC (rejouées) | bande [α/2 ; 3α/2] (rejouées) | IC disjoint de la bande (rejouées) | classe de #166 (rejouées) | médiane de p | B effectif : médiane [min ; max] | p absentes (motif) | part des δ̂** aux bords (moyenne) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| J2 | δ̂* intérieur | AD (haut) | moteur (usp_ajuster_rapide()) | 464 | 464 | 52 | 0,1121 | [0,0848 ; 0,1444] | 0,1121 | [0,0848 ; 0,1444] | oui | — | non | compatible | 0,5005 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | AD (haut) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 47 | 0,1013 | [0,0754 ; 0,1324] | 0,1013 | [0,0754 ; 0,1324] | oui | — | non | compatible | 0,4985 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | AD (haut) | conditionnelle au régime | 464 | 464 | 50 | 0,1078 | [0,0810 ; 0,1396] | 0,1078 | [0,0810 ; 0,1396] | oui | — | non | compatible | 0,5000 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* intérieur | JB (haut) | moteur (usp_ajuster_rapide()) | 464 | 464 | 13 | 0,0280 | [0,0150 ; 0,0474] | 0,0280 | [0,0150 ; 0,0474] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,4960 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | JB (haut) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 6 | 0,0129 | [0,0048 ; 0,0279] | 0,0129 | [0,0048 ; 0,0279] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,4920 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | JB (haut) | conditionnelle au régime | 464 | 464 | 48 | 0,1034 | [0,0773 ; 0,1348] | 0,1034 | [0,0773 ; 0,1348] | oui | — | non | compatible | 0,4934 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* intérieur | Grubbs (haut) | moteur (usp_ajuster_rapide()) | 464 | 464 | 10 | 0,0216 | [0,0104 ; 0,0393] | 0,0216 | [0,0104 ; 0,0393] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6960 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | Grubbs (haut) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 5 | 0,0108 | [0,0035 ; 0,0250] | 0,0108 | [0,0035 ; 0,0250] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,7560 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | Grubbs (haut) | conditionnelle au régime | 464 | 464 | 43 | 0,0927 | [0,0679 ; 0,1228] | 0,0927 | [0,0679 ; 0,1228] | oui | — | non | compatible | 0,5329 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* intérieur | BP (haut) | moteur (usp_ajuster_rapide()) | 464 | 464 | 0 | 0,0000 | [0,0000 ; 0,0079] | 0,0000 | [0,0000 ; 0,0079] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,7555 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | BP (haut) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 0 | 0,0000 | [0,0000 ; 0,0079] | 0,0000 | [0,0000 ; 0,0079] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,8700 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | BP (haut) | conditionnelle au régime | 464 | 464 | 47 | 0,1013 | [0,0754 ; 0,1324] | 0,1013 | [0,0754 ; 0,1324] | oui | — | non | compatible | 0,4543 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* intérieur | BP79 (haut) | moteur (usp_ajuster_rapide()) | 464 | 464 | 0 | 0,0000 | [0,0000 ; 0,0079] | 0,0000 | [0,0000 ; 0,0079] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,7660 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | BP79 (haut) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 0 | 0,0000 | [0,0000 ; 0,0079] | 0,0000 | [0,0000 ; 0,0079] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,8800 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | BP79 (haut) | conditionnelle au régime | 464 | 464 | 41 | 0,0884 | [0,0642 ; 0,1180] | 0,0884 | [0,0642 ; 0,1180] | oui | — | non | compatible | 0,4388 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* intérieur | White (haut) | moteur (usp_ajuster_rapide()) | 464 | 464 | 49 | 0,1056 | [0,0792 ; 0,1372] | 0,1056 | [0,0792 ; 0,1372] | oui | — | non | compatible | 0,6645 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | White (haut) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 35 | 0,0754 | [0,0531 ; 0,1033] | 0,0754 | [0,0531 ; 0,1033] | oui | — | non | compatible | 0,7520 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | White (haut) | conditionnelle au régime | 464 | 464 | 53 | 0,1142 | [0,0867 ; 0,1467] | 0,1142 | [0,0867 ; 0,1467] | oui | — | non | compatible | 0,4788 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* intérieur | GQ (deux) | moteur (usp_ajuster_rapide()) | 464 | 464 | 1 | 0,0022 | [0,0001 ; 0,0119] | 0,0022 | [0,0001 ; 0,0119] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,7340 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | GQ (deux) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 0 | 0,0000 | [0,0000 ; 0,0079] | 0,0000 | [0,0000 ; 0,0079] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,8150 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | GQ (deux) | conditionnelle au régime | 464 | 464 | 48 | 0,1034 | [0,0773 ; 0,1348] | 0,1034 | [0,0773 ; 0,1348] | oui | — | non | compatible | 0,5529 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* intérieur | BF (haut) | moteur (usp_ajuster_rapide()) | 464 | 464 | 8 | 0,0172 | [0,0075 ; 0,0337] | 0,0172 | [0,0075 ; 0,0337] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6700 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | BF (haut) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 6 | 0,0129 | [0,0048 ; 0,0279] | 0,0129 | [0,0048 ; 0,0279] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,7420 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | BF (haut) | conditionnelle au régime | 464 | 464 | 55 | 0,1185 | [0,0906 ; 0,1515] | 0,1185 | [0,0906 ; 0,1515] | oui | — | non | compatible | 0,5257 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* intérieur | DAgo (deux) | moteur (usp_ajuster_rapide()) | 464 | 464 | 9 | 0,0194 | [0,0089 ; 0,0365] | 0,0194 | [0,0089 ; 0,0365] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6320 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | DAgo (deux) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 8 | 0,0172 | [0,0075 ; 0,0337] | 0,0172 | [0,0075 ; 0,0337] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6580 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | DAgo (deux) | conditionnelle au régime | 464 | 464 | 44 | 0,0948 | [0,0697 ; 0,1252] | 0,0948 | [0,0697 ; 0,1252] | oui | — | non | compatible | 0,5081 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* intérieur | Grubbsr (haut) | moteur (usp_ajuster_rapide()) | 464 | 464 | 15 | 0,0323 | [0,0182 ; 0,0528] | 0,0323 | [0,0182 ; 0,0528] | **non** | estimation hors | non | écart non tranché | 0,6705 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | Grubbsr (haut) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 15 | 0,0323 | [0,0182 ; 0,0528] | 0,0323 | [0,0182 ; 0,0528] | **non** | estimation hors | non | écart non tranché | 0,6705 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | Grubbsr (haut) | conditionnelle au régime | 464 | 464 | 46 | 0,0991 | [0,0735 ; 0,1300] | 0,0991 | [0,0735 ; 0,1300] | oui | — | non | compatible | 0,5400 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* = 0 | RESET (haut) | moteur (usp_ajuster_rapide()) | 814 | 814 | 23 | 0,0283 | [0,0180 ; 0,0421] | 0,0283 | [0,0180 ; 0,0421] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6380 | 999 [999 ; 999] | 0 | 0,814 |
| J2 | δ̂* = 0 | RESET (haut) | δ fixé (usp_ajuster_contraint()) | 814 | 814 | 23 | 0,0283 | [0,0180 ; 0,0421] | 0,0283 | [0,0180 ; 0,0421] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6380 | 999 [999 ; 999] | 0 | 0,814 |
| J2 | δ̂* = 0 | RESET (haut) | conditionnelle au régime | 814 | 814 | 84 | 0,1032 | [0,0831 ; 0,1262] | 0,1032 | [0,0831 ; 0,1262] | oui | — | non | compatible | 0,5017 | 608 [559 ; 660] | 0 | 0,814 |
| J2 | δ̂* = 0 | GQ (deux) | moteur (usp_ajuster_rapide()) | 814 | 814 | 56 | 0,0688 | [0,0524 ; 0,0884] | 0,0688 | [0,0524 ; 0,0884] | **non** | dans | non | écart mineur | 0,5240 | 999 [999 ; 999] | 0 | 0,814 |
| J2 | δ̂* = 0 | GQ (deux) | δ fixé (usp_ajuster_contraint()) | 814 | 814 | 50 | 0,0614 | [0,0459 ; 0,0802] | 0,0614 | [0,0459 ; 0,0802] | **non** | dans | non | écart mineur | 0,5720 | 999 [999 ; 999] | 0 | 0,814 |
| J2 | δ̂* = 0 | GQ (deux) | conditionnelle au régime | 814 | 814 | 75 | 0,0921 | [0,0732 ; 0,1141] | 0,0921 | [0,0732 ; 0,1141] | oui | — | non | compatible | 0,5242 | 608 [559 ; 660] | 0 | 0,814 |
| J2 | δ̂* = 1 | GQ (deux) | moteur (usp_ajuster_rapide()) | 722 | 722 | 52 | 0,0720 | [0,0543 ; 0,0934] | 0,0720 | [0,0543 ; 0,0934] | **non** | dans | non | écart mineur | 0,5250 | 999 [999 ; 999] | 0 | 0,796 |
| J2 | δ̂* = 1 | GQ (deux) | δ fixé (usp_ajuster_contraint()) | 722 | 722 | 52 | 0,0720 | [0,0543 ; 0,0934] | 0,0720 | [0,0543 ; 0,0934] | **non** | dans | non | écart mineur | 0,5540 | 999 [999 ; 999] | 0 | 0,796 |
| J2 | δ̂* = 1 | GQ (deux) | conditionnelle au régime | 722 | 722 | 81 | 0,1122 | [0,0901 ; 0,1375] | 0,1122 | [0,0901 ; 0,1375] | oui | — | non | compatible | 0,5358 | 498 [452 ; 554] | 0 | 0,796 |
| J1 | δ̂* intérieur | AD (haut) | moteur (usp_ajuster_rapide()) | 75 | 75 | 3 | 0,0400 | [0,0083 ; 0,1125] | 0,0400 | [0,0083 ; 0,1125] | oui | — | non | compatible | 0,5610 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | AD (haut) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 3 | 0,0400 | [0,0083 ; 0,1125] | 0,0400 | [0,0083 ; 0,1125] | oui | — | non | compatible | 0,5630 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | AD (haut) | conditionnelle au régime | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,3505 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* intérieur | JB (haut) | moteur (usp_ajuster_rapide()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,5510 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | JB (haut) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,5450 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | JB (haut) | conditionnelle au régime | 75 | 6 | 1 | 0,1667 | [0,0042 ; 0,6412] | 0,0133 | [0,0003 ; 0,0721] | **non** | estimation hors | non | écart non tranché | 0,3332 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* intérieur | Grubbs (haut) | moteur (usp_ajuster_rapide()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,7920 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | Grubbs (haut) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,8050 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | Grubbs (haut) | conditionnelle au régime | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6379 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* intérieur | BP (haut) | moteur (usp_ajuster_rapide()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,9140 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | BP (haut) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,9430 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | BP (haut) | conditionnelle au régime | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6895 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* intérieur | BP79 (haut) | moteur (usp_ajuster_rapide()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,9260 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | BP79 (haut) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,9490 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | BP79 (haut) | conditionnelle au régime | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6991 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* intérieur | White (haut) | moteur (usp_ajuster_rapide()) | 75 | 75 | 3 | 0,0400 | [0,0083 ; 0,1125] | 0,0400 | [0,0083 ; 0,1125] | oui | — | non | compatible | 0,7200 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | White (haut) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 3 | 0,0400 | [0,0083 ; 0,1125] | 0,0400 | [0,0083 ; 0,1125] | oui | — | non | compatible | 0,7400 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | White (haut) | conditionnelle au régime | 75 | 6 | 1 | 0,1667 | [0,0042 ; 0,6412] | 0,0133 | [0,0003 ; 0,0721] | **non** | estimation hors | non | écart non tranché | 0,6433 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* intérieur | GQ (deux) | moteur (usp_ajuster_rapide()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,8100 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | GQ (deux) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,8260 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | GQ (deux) | conditionnelle au régime | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,3375 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* intérieur | BF (haut) | moteur (usp_ajuster_rapide()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6960 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | BF (haut) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,7280 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | BF (haut) | conditionnelle au régime | 75 | 6 | 2 | 0,3333 | [0,0433 ; 0,7772] | 0,0267 | [0,0032 ; 0,0930] | **non** | estimation hors | non | écart non tranché | 0,1498 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* intérieur | DAgo (deux) | moteur (usp_ajuster_rapide()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6800 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | DAgo (deux) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6900 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | DAgo (deux) | conditionnelle au régime | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,4808 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* intérieur | Grubbsr (haut) | moteur (usp_ajuster_rapide()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,7580 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | Grubbsr (haut) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,7580 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | Grubbsr (haut) | conditionnelle au régime | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] | 0,0000 | [0,0000 ; 0,0480] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,5653 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* = 0 | RESET (haut) | moteur (usp_ajuster_rapide()) | 930 | 930 | 99 | 0,1065 | [0,0874 ; 0,1281] | 0,1065 | [0,0874 ; 0,1281] | oui | — | non | compatible | 0,4840 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* = 0 | RESET (haut) | δ fixé (usp_ajuster_contraint()) | 930 | 930 | 99 | 0,1065 | [0,0874 ; 0,1281] | 0,1065 | [0,0874 ; 0,1281] | oui | — | non | compatible | 0,4840 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* = 0 | RESET (haut) | conditionnelle au régime | 930 | 930 | 116 | 0,1247 | [0,1042 ; 0,1477] | 0,1247 | [0,1042 ; 0,1477] | **non** | dans | non | écart mineur | 0,4677 | 517 [460 ; 569] | 0 | 0,960 |
| J1 | δ̂* = 0 | GQ (deux) | moteur (usp_ajuster_rapide()) | 930 | 930 | 71 | 0,0763 | [0,0601 ; 0,0953] | 0,0763 | [0,0601 ; 0,0953] | **non** | dans | non | écart mineur | 0,5540 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* = 0 | GQ (deux) | δ fixé (usp_ajuster_contraint()) | 930 | 930 | 71 | 0,0763 | [0,0601 ; 0,0953] | 0,0763 | [0,0601 ; 0,0953] | **non** | dans | non | écart mineur | 0,5560 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* = 0 | GQ (deux) | conditionnelle au régime | 930 | 930 | 87 | 0,0935 | [0,0756 ; 0,1141] | 0,0935 | [0,0756 ; 0,1141] | oui | — | non | compatible | 0,5300 | 517 [460 ; 569] | 0 | 0,960 |

### T1' -- α = 0,05 : fréquence de p < 0,05 par jeu, régime, statistique et variante

| Jeu | Régime | Statistique (sens) | Variante | rejouées (n_rep) | p définies (n) | < 0,05 : k | taux sur n (k / n) | IC 95 % sur n | taux sur les rejouées (k / n_rep, p absente = non-rejet) | IC 95 % sur les rejouées | α dans l'IC (rejouées) | bande [α/2 ; 3α/2] (rejouées) | IC disjoint de la bande (rejouées) | classe de #166 (rejouées) | médiane de p | B effectif : médiane [min ; max] | p absentes (motif) | part des δ̂** aux bords (moyenne) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| J2 | δ̂* intérieur | AD (haut) | moteur (usp_ajuster_rapide()) | 464 | 464 | 18 | 0,0388 | [0,0232 ; 0,0606] | 0,0388 | [0,0232 ; 0,0606] | oui | — | non | compatible | 0,5005 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | AD (haut) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 18 | 0,0388 | [0,0232 ; 0,0606] | 0,0388 | [0,0232 ; 0,0606] | oui | — | non | compatible | 0,4985 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | AD (haut) | conditionnelle au régime | 464 | 464 | 20 | 0,0431 | [0,0265 ; 0,0658] | 0,0431 | [0,0265 ; 0,0658] | oui | — | non | compatible | 0,5000 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* intérieur | JB (haut) | moteur (usp_ajuster_rapide()) | 464 | 464 | 4 | 0,0086 | [0,0024 ; 0,0219] | 0,0086 | [0,0024 ; 0,0219] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,4960 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | JB (haut) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 2 | 0,0043 | [0,0005 ; 0,0155] | 0,0043 | [0,0005 ; 0,0155] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,4920 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | JB (haut) | conditionnelle au régime | 464 | 464 | 20 | 0,0431 | [0,0265 ; 0,0658] | 0,0431 | [0,0265 ; 0,0658] | oui | — | non | compatible | 0,4934 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* intérieur | Grubbs (haut) | moteur (usp_ajuster_rapide()) | 464 | 464 | 3 | 0,0065 | [0,0013 ; 0,0188] | 0,0065 | [0,0013 ; 0,0188] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6960 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | Grubbs (haut) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 1 | 0,0022 | [0,0001 ; 0,0119] | 0,0022 | [0,0001 ; 0,0119] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,7560 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | Grubbs (haut) | conditionnelle au régime | 464 | 464 | 22 | 0,0474 | [0,0299 ; 0,0709] | 0,0474 | [0,0299 ; 0,0709] | oui | — | non | compatible | 0,5329 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* intérieur | BP (haut) | moteur (usp_ajuster_rapide()) | 464 | 464 | 0 | 0,0000 | [0,0000 ; 0,0079] | 0,0000 | [0,0000 ; 0,0079] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,7555 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | BP (haut) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 0 | 0,0000 | [0,0000 ; 0,0079] | 0,0000 | [0,0000 ; 0,0079] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,8700 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | BP (haut) | conditionnelle au régime | 464 | 464 | 24 | 0,0517 | [0,0334 ; 0,0760] | 0,0517 | [0,0334 ; 0,0760] | oui | — | non | compatible | 0,4543 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* intérieur | BP79 (haut) | moteur (usp_ajuster_rapide()) | 464 | 464 | 0 | 0,0000 | [0,0000 ; 0,0079] | 0,0000 | [0,0000 ; 0,0079] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,7660 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | BP79 (haut) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 0 | 0,0000 | [0,0000 ; 0,0079] | 0,0000 | [0,0000 ; 0,0079] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,8800 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | BP79 (haut) | conditionnelle au régime | 464 | 464 | 20 | 0,0431 | [0,0265 ; 0,0658] | 0,0431 | [0,0265 ; 0,0658] | oui | — | non | compatible | 0,4388 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* intérieur | White (haut) | moteur (usp_ajuster_rapide()) | 464 | 464 | 18 | 0,0388 | [0,0232 ; 0,0606] | 0,0388 | [0,0232 ; 0,0606] | oui | — | non | compatible | 0,6645 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | White (haut) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 15 | 0,0323 | [0,0182 ; 0,0528] | 0,0323 | [0,0182 ; 0,0528] | oui | — | non | compatible | 0,7520 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | White (haut) | conditionnelle au régime | 464 | 464 | 23 | 0,0496 | [0,0317 ; 0,0735] | 0,0496 | [0,0317 ; 0,0735] | oui | — | non | compatible | 0,4788 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* intérieur | GQ (deux) | moteur (usp_ajuster_rapide()) | 464 | 464 | 0 | 0,0000 | [0,0000 ; 0,0079] | 0,0000 | [0,0000 ; 0,0079] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,7340 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | GQ (deux) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 0 | 0,0000 | [0,0000 ; 0,0079] | 0,0000 | [0,0000 ; 0,0079] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,8150 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | GQ (deux) | conditionnelle au régime | 464 | 464 | 24 | 0,0517 | [0,0334 ; 0,0760] | 0,0517 | [0,0334 ; 0,0760] | oui | — | non | compatible | 0,5529 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* intérieur | BF (haut) | moteur (usp_ajuster_rapide()) | 464 | 464 | 5 | 0,0108 | [0,0035 ; 0,0250] | 0,0108 | [0,0035 ; 0,0250] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6700 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | BF (haut) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 2 | 0,0043 | [0,0005 ; 0,0155] | 0,0043 | [0,0005 ; 0,0155] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,7420 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | BF (haut) | conditionnelle au régime | 464 | 464 | 26 | 0,0560 | [0,0369 ; 0,0810] | 0,0560 | [0,0369 ; 0,0810] | oui | — | non | compatible | 0,5257 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* intérieur | DAgo (deux) | moteur (usp_ajuster_rapide()) | 464 | 464 | 2 | 0,0043 | [0,0005 ; 0,0155] | 0,0043 | [0,0005 ; 0,0155] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6320 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | DAgo (deux) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 1 | 0,0022 | [0,0001 ; 0,0119] | 0,0022 | [0,0001 ; 0,0119] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6580 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | DAgo (deux) | conditionnelle au régime | 464 | 464 | 21 | 0,0453 | [0,0282 ; 0,0684] | 0,0453 | [0,0282 ; 0,0684] | oui | — | non | compatible | 0,5081 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* intérieur | Grubbsr (haut) | moteur (usp_ajuster_rapide()) | 464 | 464 | 3 | 0,0065 | [0,0013 ; 0,0188] | 0,0065 | [0,0013 ; 0,0188] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6705 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | Grubbsr (haut) | δ fixé (usp_ajuster_contraint()) | 464 | 464 | 3 | 0,0065 | [0,0013 ; 0,0188] | 0,0065 | [0,0013 ; 0,0188] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6705 | 999 [999 ; 999] | 0 | 0,783 |
| J2 | δ̂* intérieur | Grubbsr (haut) | conditionnelle au régime | 464 | 464 | 20 | 0,0431 | [0,0265 ; 0,0658] | 0,0431 | [0,0265 ; 0,0658] | oui | — | non | compatible | 0,5400 | 216 [172 ; 259] | 0 | 0,783 |
| J2 | δ̂* = 0 | RESET (haut) | moteur (usp_ajuster_rapide()) | 814 | 814 | 9 | 0,0111 | [0,0051 ; 0,0209] | 0,0111 | [0,0051 ; 0,0209] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6380 | 999 [999 ; 999] | 0 | 0,814 |
| J2 | δ̂* = 0 | RESET (haut) | δ fixé (usp_ajuster_contraint()) | 814 | 814 | 9 | 0,0111 | [0,0051 ; 0,0209] | 0,0111 | [0,0051 ; 0,0209] | **non** | IC entièrement hors | **oui** (conservateur) | distorsion matérielle | 0,6380 | 999 [999 ; 999] | 0 | 0,814 |
| J2 | δ̂* = 0 | RESET (haut) | conditionnelle au régime | 814 | 814 | 43 | 0,0528 | [0,0385 ; 0,0705] | 0,0528 | [0,0385 ; 0,0705] | oui | — | non | compatible | 0,5017 | 608 [559 ; 660] | 0 | 0,814 |
| J2 | δ̂* = 0 | GQ (deux) | moteur (usp_ajuster_rapide()) | 814 | 814 | 29 | 0,0356 | [0,0240 ; 0,0508] | 0,0356 | [0,0240 ; 0,0508] | oui | — | non | compatible | 0,5240 | 999 [999 ; 999] | 0 | 0,814 |
| J2 | δ̂* = 0 | GQ (deux) | δ fixé (usp_ajuster_contraint()) | 814 | 814 | 25 | 0,0307 | [0,0200 ; 0,0450] | 0,0307 | [0,0200 ; 0,0450] | **non** | dans | non | écart mineur | 0,5720 | 999 [999 ; 999] | 0 | 0,814 |
| J2 | δ̂* = 0 | GQ (deux) | conditionnelle au régime | 814 | 814 | 39 | 0,0479 | [0,0343 ; 0,0649] | 0,0479 | [0,0343 ; 0,0649] | oui | — | non | compatible | 0,5242 | 608 [559 ; 660] | 0 | 0,814 |
| J2 | δ̂* = 1 | GQ (deux) | moteur (usp_ajuster_rapide()) | 722 | 722 | 29 | 0,0402 | [0,0271 ; 0,0572] | 0,0402 | [0,0271 ; 0,0572] | oui | — | non | compatible | 0,5250 | 999 [999 ; 999] | 0 | 0,796 |
| J2 | δ̂* = 1 | GQ (deux) | δ fixé (usp_ajuster_contraint()) | 722 | 722 | 29 | 0,0402 | [0,0271 ; 0,0572] | 0,0402 | [0,0271 ; 0,0572] | oui | — | non | compatible | 0,5540 | 999 [999 ; 999] | 0 | 0,796 |
| J2 | δ̂* = 1 | GQ (deux) | conditionnelle au régime | 722 | 722 | 34 | 0,0471 | [0,0328 ; 0,0652] | 0,0471 | [0,0328 ; 0,0652] | oui | — | non | compatible | 0,5358 | 498 [452 ; 554] | 0 | 0,796 |
| J1 | δ̂* intérieur | AD (haut) | moteur (usp_ajuster_rapide()) | 75 | 75 | 1 | 0,0133 | [0,0003 ; 0,0721] | 0,0133 | [0,0003 ; 0,0721] | oui | — | non | compatible | 0,5610 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | AD (haut) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 1 | 0,0133 | [0,0003 ; 0,0721] | 0,0133 | [0,0003 ; 0,0721] | oui | — | non | compatible | 0,5630 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | AD (haut) | conditionnelle au régime | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,3505 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* intérieur | JB (haut) | moteur (usp_ajuster_rapide()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,5510 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | JB (haut) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,5450 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | JB (haut) | conditionnelle au régime | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,3332 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* intérieur | Grubbs (haut) | moteur (usp_ajuster_rapide()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,7920 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | Grubbs (haut) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,8050 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | Grubbs (haut) | conditionnelle au régime | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,6379 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* intérieur | BP (haut) | moteur (usp_ajuster_rapide()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,9140 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | BP (haut) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,9430 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | BP (haut) | conditionnelle au régime | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,6895 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* intérieur | BP79 (haut) | moteur (usp_ajuster_rapide()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,9260 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | BP79 (haut) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,9490 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | BP79 (haut) | conditionnelle au régime | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,6991 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* intérieur | White (haut) | moteur (usp_ajuster_rapide()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,7200 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | White (haut) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,7400 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | White (haut) | conditionnelle au régime | 75 | 6 | 1 | 0,1667 | [0,0042 ; 0,6412] | 0,0133 | [0,0003 ; 0,0721] | oui | — | non | compatible | 0,6433 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* intérieur | GQ (deux) | moteur (usp_ajuster_rapide()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,8100 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | GQ (deux) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,8260 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | GQ (deux) | conditionnelle au régime | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,3375 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* intérieur | BF (haut) | moteur (usp_ajuster_rapide()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,6960 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | BF (haut) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,7280 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | BF (haut) | conditionnelle au régime | 75 | 6 | 1 | 0,1667 | [0,0042 ; 0,6412] | 0,0133 | [0,0003 ; 0,0721] | oui | — | non | compatible | 0,1498 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* intérieur | DAgo (deux) | moteur (usp_ajuster_rapide()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,6800 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | DAgo (deux) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,6900 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | DAgo (deux) | conditionnelle au régime | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,4808 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* intérieur | Grubbsr (haut) | moteur (usp_ajuster_rapide()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,7580 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | Grubbsr (haut) | δ fixé (usp_ajuster_contraint()) | 75 | 75 | 0 | 0,0000 | [0,0000 ; 0,0480] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,7580 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* intérieur | Grubbsr (haut) | conditionnelle au régime | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] | 0,0000 | [0,0000 ; 0,0480] | **non** | estimation hors | non | écart non tranché | 0,5653 | 40 [25 ; 58] | 69 (B eff. < B_MIN_DEGENERESCENCE) | 0,960 |
| J1 | δ̂* = 0 | RESET (haut) | moteur (usp_ajuster_rapide()) | 930 | 930 | 51 | 0,0548 | [0,0411 ; 0,0715] | 0,0548 | [0,0411 ; 0,0715] | oui | — | non | compatible | 0,4840 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* = 0 | RESET (haut) | δ fixé (usp_ajuster_contraint()) | 930 | 930 | 51 | 0,0548 | [0,0411 ; 0,0715] | 0,0548 | [0,0411 ; 0,0715] | oui | — | non | compatible | 0,4840 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* = 0 | RESET (haut) | conditionnelle au régime | 930 | 930 | 57 | 0,0613 | [0,0467 ; 0,0787] | 0,0613 | [0,0467 ; 0,0787] | oui | — | non | compatible | 0,4677 | 517 [460 ; 569] | 0 | 0,960 |
| J1 | δ̂* = 0 | GQ (deux) | moteur (usp_ajuster_rapide()) | 930 | 930 | 34 | 0,0366 | [0,0254 ; 0,0507] | 0,0366 | [0,0254 ; 0,0507] | oui | — | non | compatible | 0,5540 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* = 0 | GQ (deux) | δ fixé (usp_ajuster_contraint()) | 930 | 930 | 34 | 0,0366 | [0,0254 ; 0,0507] | 0,0366 | [0,0254 ; 0,0507] | oui | — | non | compatible | 0,5560 | 999 [999 ; 999] | 0 | 0,960 |
| J1 | δ̂* = 0 | GQ (deux) | conditionnelle au régime | 930 | 930 | 39 | 0,0419 | [0,0300 ; 0,0569] | 0,0419 | [0,0300 ; 0,0569] | oui | — | non | compatible | 0,5300 | 517 [460 ; 569] | 0 | 0,960 |

### T2 -- mécanisme (descriptif)

Composition des δ̂** du moteur (réplications internes retenues) et échecs des réajustements :

| Jeu | Régime de δ̂* | rejouées | δ̂** = 0 (moyenne) | δ̂** intérieur (moyenne) | δ̂** = 1 (moyenne) | δ̂** du régime de δ̂* : médiane [min ; max] | échecs usp_ajuster_rapide() | échecs statistiques (1) | réplications internes écartées par la variante 1 (sous-catalogue ; variantes non calculées) | échecs usp_ajuster_contraint() (parmi les retenues) | échecs statistiques (2) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| J2 | δ̂* intérieur | 464 | 0,437 | 0,217 | 0,346 | 216 [172 ; 259] | 0 | 0 | 0 | 0 | 0 |
| J2 | δ̂* = 0 | 814 | 0,609 | 0,186 | 0,205 | 608 [559 ; 660] | 0 | 0 | 0 | 0 | 0 |
| J2 | δ̂* = 1 | 722 | 0,297 | 0,204 | 0,500 | 498 [452 ; 554] | 0 | 0 | 0 | 0 | 0 |
| J1 | δ̂* intérieur | 75 | 0,486 | 0,040 | 0,474 | 40 [25 ; 58] | 0 | 0 | 0 | 0 | 0 |
| J1 | δ̂* = 0 | 930 | 0,517 | 0,040 | 0,443 | 517 [460 ; 569] | 0 | 0 | 0 | 0 | 0 |

Comparaison appariée des p (réplications où les deux p sont calculées) :

| Jeu | Régime | Statistique | paires (2, 1) | p2 > p1 | p2 = p1 | p2 < p1 | médiane de p2 − p1 | paires (3, 1) | p3 > p1 | p3 = p1 | p3 < p1 | médiane de p3 − p1 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| J2 | δ̂* intérieur | AD | 464 | 171 | 8 | 285 | -0,0060 | 464 | 260 | 1 | 203 | 0,0035 |
| J2 | δ̂* intérieur | JB | 464 | 235 | 10 | 219 | 0,0010 | 464 | 189 | 2 | 273 | -0,0077 |
| J2 | δ̂* intérieur | Grubbs | 464 | 456 | 4 | 4 | 0,0510 | 464 | 2 | 2 | 460 | -0,1419 |
| J2 | δ̂* intérieur | BP | 464 | 461 | 2 | 1 | 0,1090 | 464 | 0 | 0 | 464 | -0,2721 |
| J2 | δ̂* intérieur | BP79 | 464 | 461 | 1 | 2 | 0,1100 | 464 | 1 | 0 | 463 | -0,2946 |
| J2 | δ̂* intérieur | White | 464 | 460 | 3 | 1 | 0,0590 | 464 | 39 | 1 | 424 | -0,1001 |
| J2 | δ̂* intérieur | GQ | 464 | 356 | 3 | 105 | 0,0690 | 464 | 87 | 0 | 377 | -0,1884 |
| J2 | δ̂* intérieur | BF | 464 | 455 | 3 | 6 | 0,0695 | 464 | 6 | 0 | 458 | -0,1177 |
| J2 | δ̂* intérieur | DAgo | 464 | 395 | 8 | 61 | 0,0360 | 464 | 58 | 0 | 406 | -0,0961 |
| J2 | δ̂* intérieur | Grubbsr | 464 | 0 | 464 | 0 | 0,0000 | 464 | 2 | 2 | 460 | -0,1026 |
| J2 | δ̂* = 0 | RESET | 814 | 0 | 814 | 0 | 0,0000 | 814 | 1 | 0 | 813 | -0,1144 |
| J2 | δ̂* = 0 | GQ | 814 | 260 | 195 | 359 | 0,0000 | 814 | 454 | 0 | 360 | 0,0439 |
| J2 | δ̂* = 1 | GQ | 722 | 171 | 82 | 469 | -0,0120 | 722 | 408 | 0 | 314 | 0,0627 |
| J1 | δ̂* intérieur | AD | 75 | 48 | 6 | 21 | 0,0020 | 6 | 4 | 0 | 2 | 0,0175 |
| J1 | δ̂* intérieur | JB | 75 | 38 | 5 | 32 | 0,0010 | 6 | 1 | 0 | 5 | -0,0652 |
| J1 | δ̂* intérieur | Grubbs | 75 | 71 | 2 | 2 | 0,0110 | 6 | 0 | 0 | 6 | -0,1974 |
| J1 | δ̂* intérieur | BP | 75 | 70 | 1 | 4 | 0,0250 | 6 | 0 | 0 | 6 | -0,2615 |
| J1 | δ̂* intérieur | BP79 | 75 | 71 | 2 | 2 | 0,0260 | 6 | 0 | 0 | 6 | -0,2561 |
| J1 | δ̂* intérieur | White | 75 | 73 | 1 | 1 | 0,0110 | 6 | 0 | 0 | 6 | -0,1151 |
| J1 | δ̂* intérieur | GQ | 75 | 48 | 2 | 25 | 0,0100 | 6 | 0 | 0 | 6 | -0,3085 |
| J1 | δ̂* intérieur | BF | 75 | 73 | 0 | 2 | 0,0160 | 6 | 0 | 0 | 6 | -0,2581 |
| J1 | δ̂* intérieur | DAgo | 75 | 55 | 5 | 15 | 0,0060 | 6 | 1 | 0 | 5 | -0,1799 |
| J1 | δ̂* intérieur | Grubbsr | 75 | 0 | 75 | 0 | 0,0000 | 6 | 0 | 0 | 6 | -0,2006 |
| J1 | δ̂* = 0 | RESET | 930 | 0 | 930 | 0 | 0,0000 | 930 | 171 | 3 | 756 | -0,0106 |
| J1 | δ̂* = 0 | GQ | 930 | 183 | 250 | 497 | -0,0020 | 930 | 560 | 0 | 370 | 0,0874 |

Variante 3 : taux du moteur (variante 1, p absente = non-rejet) restreint aux réplications où p3 est définie, α = 0,10 :

| Jeu | Régime | Statistique | rejouées | p3 définie (n) | p1 < 0,10 : k | taux du moteur | IC 95 % |
| --- | --- | --- | --- | --- | --- | --- | --- |
| J2 | δ̂* intérieur | AD | 464 | 464 | 52 | 0,1121 | [0,0848 ; 0,1444] |
| J2 | δ̂* intérieur | JB | 464 | 464 | 13 | 0,0280 | [0,0150 ; 0,0474] |
| J2 | δ̂* intérieur | Grubbs | 464 | 464 | 10 | 0,0216 | [0,0104 ; 0,0393] |
| J2 | δ̂* intérieur | BP | 464 | 464 | 0 | 0,0000 | [0,0000 ; 0,0079] |
| J2 | δ̂* intérieur | BP79 | 464 | 464 | 0 | 0,0000 | [0,0000 ; 0,0079] |
| J2 | δ̂* intérieur | White | 464 | 464 | 49 | 0,1056 | [0,0792 ; 0,1372] |
| J2 | δ̂* intérieur | GQ | 464 | 464 | 1 | 0,0022 | [0,0001 ; 0,0119] |
| J2 | δ̂* intérieur | BF | 464 | 464 | 8 | 0,0172 | [0,0075 ; 0,0337] |
| J2 | δ̂* intérieur | DAgo | 464 | 464 | 9 | 0,0194 | [0,0089 ; 0,0365] |
| J2 | δ̂* intérieur | Grubbsr | 464 | 464 | 15 | 0,0323 | [0,0182 ; 0,0528] |
| J2 | δ̂* = 0 | RESET | 814 | 814 | 23 | 0,0283 | [0,0180 ; 0,0421] |
| J2 | δ̂* = 0 | GQ | 814 | 814 | 56 | 0,0688 | [0,0524 ; 0,0884] |
| J2 | δ̂* = 1 | GQ | 722 | 722 | 52 | 0,0720 | [0,0543 ; 0,0934] |
| J1 | δ̂* intérieur | AD | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] |
| J1 | δ̂* intérieur | JB | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] |
| J1 | δ̂* intérieur | Grubbs | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] |
| J1 | δ̂* intérieur | BP | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] |
| J1 | δ̂* intérieur | BP79 | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] |
| J1 | δ̂* intérieur | White | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] |
| J1 | δ̂* intérieur | GQ | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] |
| J1 | δ̂* intérieur | BF | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] |
| J1 | δ̂* intérieur | DAgo | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] |
| J1 | δ̂* intérieur | Grubbsr | 75 | 6 | 0 | 0,0000 | [0,0000 ; 0,4593] |
| J1 | δ̂* = 0 | RESET | 930 | 930 | 99 | 0,1065 | [0,0874 ; 0,1281] |
| J1 | δ̂* = 0 | GQ | 930 | 930 | 71 | 0,0763 | [0,0601 ; 0,0953] |

Variante 1 : p de usp_bootstrap() (moteur), sous-catalogue du régime ; 2 : δ fixé à δ̂*_b, sur les mêmes réplications internes retenues que la variante 1 (les réplications internes écartées par la variante 1 ne sont pas rejouées à δ fixé) ; 3 : réplications internes retenues dont δ̂** est dans le régime de δ̂*_b. RESET et Grubbsr ne dépendent pas de l'ajustement : p2 = p1 si aucun réajustement à δ fixé n'échoue (contrôle de cohérence).

### T3 -- jeux observés (bootstrap de run_engine(), graine 20260831)

J2 : δ̂ = 0,663991 (δ̂* intérieur) ; δ̂** : 419 au bord 0, 203 intérieurs, 377 au bord 1 (sur 999 retenues) ; échecs : usp_ajuster_rapide() 0, statistiques (1) 0, usp_ajuster_contraint() 0, statistiques (2) 0.

| Statistique (sens) | p1 (B effectif) | p2 (B effectif) | p3 (B effectif) | motif d'absence |
| --- | --- | --- | --- | --- |
| AD (haut) | 0,8070 (999) | 0,7890 (999) | 0,7990 (203) | — |
| JB (haut) | 0,8650 (999) | 0,8590 (999) | 0,8480 (203) | — |
| Grubbs (haut) | 0,2730 (999) | 0,3170 (999) | 0,1373 (203) | — |
| RESET (haut) | 0,8200 (999) | 0,8200 (999) | 0,9412 (203) | — |
| BP (haut) | 0,6940 (999) | 0,8150 (999) | 0,3627 (203) | — |
| BP79 (haut) | 0,6290 (999) | 0,7960 (999) | 0,2206 (203) | — |
| White (haut) | 0,5480 (999) | 0,6360 (999) | 0,3922 (203) | — |
| GQ (deux) | 0,2680 (999) | 0,3280 (999) | 0,0196 (203) | — |
| BF (haut) | 0,5690 (999) | 0,6720 (999) | 0,3725 (203) | — |
| DAgo (deux) | 0,4680 (999) | 0,5100 (999) | 0,3137 (203) | — |
| Grubbsr (haut) | 0,3030 (999) | 0,3030 (999) | 0,2108 (203) | — |

J1 : δ̂ = 1,000000 (δ̂* = 1) ; δ̂** : 463 au bord 0, 46 intérieurs, 490 au bord 1 (sur 999 retenues) ; échecs : usp_ajuster_rapide() 0, statistiques (1) 0, usp_ajuster_contraint() 0, statistiques (2) 0.

| Statistique (sens) | p1 (B effectif) | p2 (B effectif) | p3 (B effectif) | motif d'absence |
| --- | --- | --- | --- | --- |
| AD (haut) | 0,5660 (999) | 0,5710 (999) | 0,5906 (490) | — |
| JB (haut) | 0,6740 (999) | 0,6650 (999) | 0,6762 (490) | — |
| Grubbs (haut) | 0,8610 (999) | 0,8740 (999) | 0,8656 (490) | — |
| RESET (haut) | 0,9960 (999) | 0,9960 (999) | 0,9959 (490) | — |
| BP (haut) | 0,0180 (999) | 0,0210 (999) | 0,0265 (490) | — |
| BP79 (haut) | 0,0900 (999) | 0,1010 (999) | 0,1100 (490) | — |
| White (haut) | 0,0670 (999) | 0,0690 (999) | 0,0733 (490) | — |
| GQ (deux) | 0,1900 (999) | 0,1900 (999) | 0,3870 (490) | — |
| BF (haut) | 0,1040 (999) | 0,1140 (999) | 0,1100 (490) | — |
| DAgo (deux) | 0,7080 (999) | 0,7160 (999) | 0,7658 (490) | — |
| Grubbsr (haut) | 0,7770 (999) | 0,7770 (999) | 0,7617 (490) | — |

