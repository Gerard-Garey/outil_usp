## Mesure #309 : puissance à T = 8 des lignes M1 à M4 de Merz-Wüthrich et niveau des candidats de #300 et #301 -- combinaison de 89 sortie(s)

### T0 — provenance (identique dans toutes les sorties, vérifié)

| Grandeur | Valeur |
| --- | --- |
| DGP sous H0 et plans (par. 2.2) | modèle de Mack ajusté à reserve2 (mw_ajuster(), tests/donnees/triangle_mw.csv), I = J = 7 ; f̂ = (3,20372 ; 1,65175 ; 1,32525 ; 1,15042 ; 1,09469 ; 1,06455 ; 1,02841) ; σ̂² = (0,72404 ; 0,71209 ; 0,69814 ; 0,31478 ; 0,097325 ; 0,18967 ; 0,097325), non réestimés sous P2 et P3 ; plans de la première colonne fixée (lignes 0..7) : P1 = (300,0000 ; 311,4286 ; 322,8571 ; 334,2857 ; 345,7143 ; 357,1429 ; 368,5714 ; 380,0000), P2 = C̄₀ + 3,4 (C₀ − C̄₀) = (204,0000 ; 242,8571 ; 281,7143 ; 320,5714 ; 359,4286 ; 398,2857 ; 437,1429 ; 476,0000), P3 = P2[c(2, 8, 6, 4, 3, 5, 7, 1)] (π = (1, 7, 5, 3, 2, 4, 6, 0)) = (242,8571 ; 476,0000 ; 398,2857 ; 320,5714 ; 281,7143 ; 359,4286 ; 437,1429 ; 204,0000) ; colonnes dégénérées de reserve2 : 6 ; loi N (stats::rnorm) sous le volet B ; volet A : N, E (loi uniforme sur les 27 valeurs de .mw_pool_residus(aj0, jd0) divisées par leur écart-type de population 0,9988), A ((G − 2)/√2, G ~ Gamma(2) par inversion) ; générateurs gen_triangle_h0() (H0 de #206) et gen_triangle_scen() (CST, EXP, DFI) ; scénarios d'incréments recumulés CAL7, CAL4 (θ = 0,1), DCAL (1,05^max(0, t − 3)), LIG (× 1,5 pour j ≥ 2, ligne 2), CEL4 et CEL6 (λ = 4 et 6), CELx4 ; CST10, CST20 (δ = 0,1 ; 0,2), EXP0, EXP2 (κ = 0 ; 2), DFI (γ = 0,2) ; cellule visée (i, j) = (2, 1) |
| Configuration | méthode reserve2, segment 1 de l'annexe II ; B = 999 (donnée du test calibré) ; seuils mesurés 0,10 et 0,05 ; chemin mesuré mw_bootstrap(aj, B, seed) avec entrées des candidats injectées dans MW_CATALOGUE_MC (restauré par finally), catalogue complet (volet B : 13 clés + 6 candidats) ou réduit (volet A : BP, Grubbs + 6 candidats) ; la boucle de tirage n'est pas recopiée ; B_MIN_DEGENERESCENCE = 50 ; FACTEUR_B_MAX_MW = 25 ; un bootstrap plein est rejoué sans injection pour b multiple de 50 (contrôle (i2)) |
| Graines (par. 2.5 et 2.6, complément du 19/10/2026) | volet A (graines de #206) : triangle b, loi ℓ : 20840000 + 10000 (ℓ − 1) + b ; bootstrap : 20870000 + 10000 (ℓ − 1) + b ; oracle k : 20900000 + 20000 (ℓ − 1) + k ; ℓ = 1 (N), 2 (E), 3 (A) ; volet B, P1 et P2, cellule de rang c (P1 : 1 à 13, P2 : 14 à 19, dans l'ordre de CELLULES) : triangle 32000000 + 20000 (c − 1) + b, bootstrap 32500000 + 20000 (c − 1) + b, oracle de P2 : 33000000 + k ; P3, c3 = 1 (H0), 2 (CST20), 3 (DFI) : triangle 34000000 + 20000 (c3 − 1) + b, bootstrap 34200000 + 20000 (c3 − 1) + b, oracle 34400000 + k ; contrôles sur reserve2 : 20260831 ; tous les tirages sous engine_sous_graine() |
| Graines : recherche des collisions (plages de P3 comprises) | plages du volet A (celles de #206) triangles 20840001-20862000, bootstrap 20870001-20892000, oracle 20900001-20960000 ; plages du volet B triangles 32000001-32380000, bootstrap 32500001-32880000, oracle P2 33000001-33020000 ; plages de P3 triangles 34000001-34060000, bootstrap 34200001-34260000, oracle 34400001-34420000 ; les neuf plages sont disjointes deux à deux : oui ; graines réelles des cellules dans les plages déclarées : oui ; 42 littéraux de graine de huit chiffres dans 68 fichiers (R/engine.R, tests/*.R hors ce script, tests/unitaires/*.R), de 10000000 à 99999809 ; littéraux L dont [L ; L + 20000] touche une plage du volet B ou de P3 : aucun ; SEED_LOI_NULLE_SW 20260901, graine de reserve2 20260831 et réseau 20260831 + 1000 k ≤ 20760831 de tests/puissance_t8.R hors des plages : oui |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Commit | 754dd0a71e48243bc87240f2c0f3a825c23c8776 |
| Plateforme de calcul (R, système, machine, BLAS, LAPACK) | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : libblas.so.3.12.0 ; LAPACK : liblapack.so.3.12.0 (version 3.12.0) |
| Empreintes md5 du code exécuté (moteur, outils, script) | R/engine.R a6250d419ea27cb2e87bf4ed70dac453 ; tests/outils_tests.R chargé (dépôt) 7127605f20e8c261d41d3c372f4f2f1b ; script exécuté (dépôt) cd4df329e47cdff297ce173234960a04 ; docs/specifications/fi-merz-wuthrich-puissance.md 072e12472ef287ff163ace3c3332ea6f |
| Empreinte sans commentaires de R/engine.R (#231) et md5 du fichier entier | 6ce112eecc6a7e9b6500ab639e757891 (md5 du fichier entier a6250d419ea27cb2e87bf4ed70dac453) |
| Contrôle (a) : reserve2 contre tests/reference/reserve2.rds | conforme ; 4470 feuille(s), 0 non strictement identique(s), écart maximal 0.000e+00 |
| Contrôle (c) : candidats sur reserve2 (graine 20260831, B = 999) | BP 0,6502 / 0,103 ; FWb 1,7598 / 0,214 ; FWr 1,4373 / 0,285 ; MinP 0,1033 / 0,944 ; MinP4 0,1033 / 0,898 ; TMax 2,7242 / 0,944 ; PenteRel (informatif, issue #307 : t = 1,73 ; p_mc = 0,090) : t = 1,733, p_mc = 0,090 |
| Contrôle (sc) : scénarios et plans, écriture indépendante | paramètres neutres de gen_triangle_scen() = gen_triangle_h0() (identical(), 20 graines) : oui ; moyenne et écart-type des générateurs CST10, CST20, EXP0, EXP2, DFI (ε = 0 puis ε = 1) contre une écriture indépendante cellule par cellule : écart relatif maximal 4.97e-16 ; scénarios d'incréments CAL7, CAL4, DCAL, LIG, CELx4, CEL4, CEL6 sur le triangle observé de reserve2 contre une écriture indépendante : écart relatif maximal 2.56e-15 ; CEL4 et CEL6 déplacent F(2, 1) de λ écarts-types de bruit et laissent les autres lignes identiques : oui ; plans P2 (204 à 476, mean inchangée, équidistante) et P3 (P2[c(2, 8, 6, 4, 3, 5, 7, 1)], π = (1, 7, 5, 3, 2, 4, 6, 0)) : oui ; CAL7, CAL4 et DCAL de appliquer_increments() identical() à appliquer_effet("dernier", 0,10), ("median", 0,10) et ("derive", 0,05) de tests/mesure_calendaire_t8.R (md5 68bbcc77a0b0d84a96363ee5ef54cf01 ; fonctions lues par parse(), script non exécuté) sur 20 triangles H0 de P1 (dont 0 incomplets, rendus tels quels par les deux) : oui |
| Contrôle (copie) : fonctions reprises de tests/calibration_mc_mw_t8.R | 37 fonctions et 25 constantes de tests/calibration_mc_mw_t8.R (md5 d35b0f92d648732dbb570cb00c7fca07) identiques (formals, corps ; valeur) à celles de ce script, et N_ECH_REPRISE (tranche 10, oracle 50 : #248) identique pour ces deux éléments |
| Provisoire (--provisoire, --essai, --B, --N0 réduit : non versionnable) | non |
| Locale LC_CTYPE des sorties (origine → travail) | C.UTF-8 → C.UTF-8 |
| Plan et effectifs R (par. 2.5, 2.6 et complément du 19/10/2026) | volet A : N R = 2000, E R = 2000, A R = 1000 (oracle N0 = 20000 par loi) ; volet B : P1.H0 R = 1000, P1.CST20 R = 1000, P1.EXP2 R = 1000, P1.CEL4 R = 1000, P1.CEL6 R = 1000, P1.CST10 R = 500, P1.EXP0 R = 500, P1.DFI R = 500, P1.CAL7 R = 500, P1.CAL4 R = 500, P1.DCAL R = 500, P1.LIG R = 500, P1.CELx4 R = 500, P2.H0 R = 1000, P2.CST20 R = 1000, P2.EXP2 R = 1000, P2.CST10 R = 500, P2.EXP0 R = 500, P2.DFI R = 500, P3.H0 R = 1000, P3.CST20 R = 1000, P3.DFI R = 500 ; oracles P2 et P3 : N0 = 20000 ; l'oracle de P1 est celui de la loi N du volet A |
| Débit (ligne du JOURNAL) | essai du 2026-10-19 au commit mesuré (--essai --n 1 --coeurs 4, arbre propre) : volet A 2,17 h, volet B 30,02 h, (i2) 0,71 h, oracles 0,21 h, contrôles 0,70 h ; total 33,80 h d'horloge (133,09 h CPU) ; essais antérieurs sur arbre de travail 34,45 h, 32,87 h, 32,34 h |
| Triangles refusés par jeu (DGP, par. 2.2 : signalé au-delà de 1 %) | A-A 0 / 1000 (0,00000) ; A-E 0 / 2000 (0,00000) ; A-N 0 / 2000 (0,00000) ; B-P1.CAL4 0 / 500 (0,00000) ; B-P1.CAL7 0 / 500 (0,00000) ; B-P1.CEL4 0 / 1000 (0,00000) ; B-P1.CEL6 0 / 1000 (0,00000) ; B-P1.CELx4 0 / 500 (0,00000) ; B-P1.CST10 0 / 500 (0,00000) ; B-P1.CST20 0 / 1000 (0,00000) ; B-P1.DCAL 0 / 500 (0,00000) ; B-P1.DFI 0 / 500 (0,00000) ; B-P1.EXP0 0 / 500 (0,00000) ; B-P1.EXP2 0 / 1000 (0,00000) ; B-P1.H0 0 / 1000 (0,00000) ; B-P1.LIG 0 / 500 (0,00000) ; B-P2.CST10 0 / 500 (0,00000) ; B-P2.CST20 0 / 1000 (0,00000) ; B-P2.DFI 0 / 500 (0,00000) ; B-P2.EXP0 0 / 500 (0,00000) ; B-P2.EXP2 0 / 1000 (0,00000) ; B-P2.H0 0 / 1000 (0,00000) ; B-P3.CST20 0 / 1000 (0,00000) ; B-P3.DFI 0 / 500 (0,00000) ; B-P3.H0 0 / 1000 (0,00000) |
| Contrôle (i2) en tranche (b multiple de 50 : bootstrap plein rejoué sans injection) | 420 triangle(s) contrôlé(s), 420 identique(s) (identical()) pour p_mc, B effectif, motif et stats_obs des clés communes |
| Triangles d'oracle refusés | ORA-A-A 0 / 20000 (0,00000) ; ORA-A-E 0 / 20000 (0,00000) ; ORA-A-N 0 / 20000 (0,00000) ; ORA-B-P2 0 / 20000 (0,00000) ; ORA-B-P3 0 / 20000 (0,00000) |
| ρ approché (plus de 1 % de statistiques oracle non finies pour la statistique) | aucune |
| CV intra-colonne réalisé par colonne (moyenne sur les triangles admis de la cellule H0 de chaque plan ; j = 0 à 5 ; détail au T7 (a)) | P1 : 0,0739 ; 0,0666 ; 0,0591 ; 0,0517 ; 0,0437 ; 0,0336 / P2 : 0,2618 ; 0,2419 ; 0,2194 ; 0,1926 ; 0,1622 ; 0,1242 / P3 : 0,2335 ; 0,2424 ; 0,2725 ; 0,2800 ; 0,3198 ; 0,4594 |
| K0-c (CV réalisé, moyenne de j = 0 à 3 dans [0,22 ; 0,28], P2 et P3 séparément) | P2 : 0,2289 (tenu) ; P3 : 0,2571 (tenu) |
| K0-x : test exact de Fisher bilatéral, seuil 0,025 par cellule (Bonferroni sur deux cellules) ; Calendrier de CAL7 et CAL4 à 0,10 contre le T2 de #276 | CAL7 : mesuré 190 / 500, 0,38000 [0,33727 ; 0,42415] ; publié 401 / 1000, 0,40100 [0,37045 ; 0,43213] ; Fisher bilatéral p = 0,466 (tenu) ; CAL4 : mesuré 172 / 500, 0,34400 [0,30239 ; 0,38747] ; publié 319 / 1000, 0,31900 [0,29018 ; 0,34889] ; Fisher bilatéral p = 0,35 (tenu) ; seuil 0,025 par cellule (Bonferroni sur deux cellules) |
| K0-t (BP et Grubbs du volet A : identiques au brut de #206) | 10000 (triangle, témoin) comparés (BP et Grubbs, volet A) : p_mc et B effectifs identiques à pR: et BR: du brut de #206 (|écart| ≤ 1e-12) |
| Explication de K0-t (--explication-k0t) | — |
| Facteur confondant de P2 contre P3 (complément du 19/10/2026) | la différence de profil de CV réalisé entre P2 et P3 (T7 (a)) est un facteur confondant résiduel de la comparaison P2 / P3 ; K0-c y est évalué séparément |
| Sorties combinées (nom, md5, plage) | ora-A-A.txt 3d347653bbd194abb4bb6c72936dd5aa (oracle ORA-A-A, 1-20000) ; ora-A-E.txt 3ab15cf7be671a4d8b07fe14b6461cc6 (oracle ORA-A-E, 1-20000, reprise : ora-A-E.txt.partiel1 76d7acece6c33240d3b53635d147d407 16150 50 0) ; ora-A-N.txt 9d2b3f8ec0969889e3083a36a61d5937 (oracle ORA-A-N, 1-20000) ; ora-B-P2.txt 527c6852bb47ff53b30738ca98563f96 (oracle ORA-B-P2, 1-20000) ; ora-B-P3.txt 85ad7d03c5a44768ecd453ba4031c8f2 (oracle ORA-B-P3, 1-20000) ; va-A-0001-0250.txt 6552df3c400f6db15c187e259779b1f3 (tranche A-A, 1-250) ; va-A-0251-0500.txt 2ead36601e21cb4259cb6947998d1a3e (tranche A-A, 251-500) ; va-A-0501-0750.txt b631ffb356feca52650dc0c55a3356c0 (tranche A-A, 501-750) ; va-A-0751-1000.txt 4b9a0b96de56e27984d90b2748e80c5e (tranche A-A, 751-1000) ; va-E-0001-0250.txt b9db1dce5825f092cddfa58e56d389c9 (tranche A-E, 1-250) ; va-E-0251-0500.txt b349a47c2591c38b0581626dd7437b26 (tranche A-E, 251-500) ; va-E-0501-0750.txt aba309c4d634c76a31051ba9bc53fe4b (tranche A-E, 501-750) ; va-E-0751-1000.txt d0cc306ce571639b032a025348660e48 (tranche A-E, 751-1000) ; va-E-1001-1250.txt a476b54825ade5178d24b42cdc6c99eb (tranche A-E, 1001-1250) ; va-E-1251-1500.txt c72c7f08a609939dc065d851f724576a (tranche A-E, 1251-1500) ; va-E-1501-1750.txt bd4c43bd3e63f84e665c3018da7bfe57 (tranche A-E, 1501-1750) ; va-E-1751-2000.txt dd15bdfdf167a7632c278e77d5ae131e (tranche A-E, 1751-2000) ; va-N-0001-0250.txt 1d03b729dffd05d986026a53389a0686 (tranche A-N, 1-250, reprise : va-N-0001-0250.txt.partiel1 7732a6645d30c4ce158b4a870a724d11 166 10 0) ; va-N-0251-0500.txt 10e39ef50a10c77501e862623e288c00 (tranche A-N, 251-500) ; va-N-0501-0750.txt 266cc4a7ca36d619fbec71e411974476 (tranche A-N, 501-750) ; va-N-0751-1000.txt 43333940976688ac7d266d6d79a74765 (tranche A-N, 751-1000) ; va-N-1001-1250.txt 04e3a46395206add50ad22c340f0a9cf (tranche A-N, 1001-1250) ; va-N-1251-1500.txt b147e2387ddd8014dadc4b6ae4df0c54 (tranche A-N, 1251-1500) ; va-N-1501-1750.txt 14a4ecc412d9450dff0651c275217000 (tranche A-N, 1501-1750) ; va-N-1751-2000.txt 405b9125d6f624dc7dfda8f4b14a4f61 (tranche A-N, 1751-2000) ; vb-P1-CAL4-0001-0250.txt 5332bfcbe34a014e0c6986e4d07ad735 (tranche B-P1.CAL4, 1-250) ; vb-P1-CAL4-0251-0500.txt 090a75bbc5a1137e1907f0b1085b69a3 (tranche B-P1.CAL4, 251-500) ; vb-P1-CAL7-0001-0250.txt 0603569fdd50251761c37d72ef02afc1 (tranche B-P1.CAL7, 1-250) ; vb-P1-CAL7-0251-0500.txt 39ce21ff110c8d502da8ff7fd36185da (tranche B-P1.CAL7, 251-500) ; vb-P1-CEL4-0001-0250.txt 1ebdeebd4596800a79eb382f065182c3 (tranche B-P1.CEL4, 1-250) ; vb-P1-CEL4-0251-0500.txt b88ea758c56b93d3105c54874cfb1eab (tranche B-P1.CEL4, 251-500) ; vb-P1-CEL4-0501-0750.txt 94282735e47638ed053d52e52897a1e9 (tranche B-P1.CEL4, 501-750) ; vb-P1-CEL4-0751-1000.txt 6d0a823acff57a0c7007c6b39d924ee1 (tranche B-P1.CEL4, 751-1000) ; vb-P1-CEL6-0001-0250.txt 492e6cf88069b00a352e3c436378abfc (tranche B-P1.CEL6, 1-250) ; vb-P1-CEL6-0251-0500.txt e36589e8219f29c983b7ba12cd9bce90 (tranche B-P1.CEL6, 251-500) ; vb-P1-CEL6-0501-0750.txt c9cc32eea13b6d8ca6bbecac86a613bf (tranche B-P1.CEL6, 501-750) ; vb-P1-CEL6-0751-1000.txt c4a6243fbf0952d3b3b77f074a283db8 (tranche B-P1.CEL6, 751-1000) ; vb-P1-CELx4-0001-0250.txt 681867222553122c8aa73870a511ee60 (tranche B-P1.CELx4, 1-250) ; vb-P1-CELx4-0251-0500.txt 8d2ce3911fce5a598e42f93de2e25872 (tranche B-P1.CELx4, 251-500) ; vb-P1-CST10-0001-0250.txt 638a05185b488baa6979c22480b61eba (tranche B-P1.CST10, 1-250, reprise : vb-P1-CST10-0001-0250.txt.partiel1 5aa0e0ef2567ebfee672ea2649b14577 62 10 0) ; vb-P1-CST10-0251-0500.txt 90bbe8879943410c69ce62c2a25cbfed (tranche B-P1.CST10, 251-500) ; vb-P1-CST20-0001-0250.txt 94bb19f9f3f89c7c735cf6e01dd4d2f9 (tranche B-P1.CST20, 1-250) ; vb-P1-CST20-0251-0500.txt 7f4e559e4932404a190a347c18177e34 (tranche B-P1.CST20, 251-500) ; vb-P1-CST20-0501-0750.txt 9456ee8e4b7d326a6cb5947010d3c60f (tranche B-P1.CST20, 501-750) ; vb-P1-CST20-0751-1000.txt 771e70a1f79746c6ab6f60a5c33b4f68 (tranche B-P1.CST20, 751-1000) ; vb-P1-DCAL-0001-0250.txt 1025a22ee50a31c3e3387bc84938ba7c (tranche B-P1.DCAL, 1-250) ; vb-P1-DCAL-0251-0500.txt 6f20313dc9b7e5f4300cee301311149e (tranche B-P1.DCAL, 251-500) ; vb-P1-DFI-0001-0250.txt c7dea51a0940497d414c5ebaf623f546 (tranche B-P1.DFI, 1-250) ; vb-P1-DFI-0251-0500.txt 0e29a59407273baa5f7b1a7d83e1a39c (tranche B-P1.DFI, 251-500) ; vb-P1-EXP0-0001-0250.txt 08e9471a3cbabd7625a91348ae0d7507 (tranche B-P1.EXP0, 1-250) ; vb-P1-EXP0-0251-0500.txt d5ff283d55bbb946a4978a861aa76e50 (tranche B-P1.EXP0, 251-500) ; vb-P1-EXP2-0001-0250.txt f0d17167bdf207170e7d77a3452f0a27 (tranche B-P1.EXP2, 1-250) ; vb-P1-EXP2-0251-0500.txt 018a799dd3c06914880d0103c1fa8716 (tranche B-P1.EXP2, 251-500) ; vb-P1-EXP2-0501-0750.txt 8e33a395abac9ce960dd954a3a4d8ae6 (tranche B-P1.EXP2, 501-750) ; vb-P1-EXP2-0751-1000.txt 7ffd123837d138f749d43f420a27ca83 (tranche B-P1.EXP2, 751-1000) ; vb-P1-H0-0001-0250.txt dbb09e7cc9d942b361987c27ab8cbb0a (tranche B-P1.H0, 1-250) ; vb-P1-H0-0251-0500.txt e1216efd43105789071fd7ee513efabe (tranche B-P1.H0, 251-500) ; vb-P1-H0-0501-0750.txt 0d0c43f6894476218cd848e9a2a2b881 (tranche B-P1.H0, 501-750) ; vb-P1-H0-0751-1000.txt e24e19235da5b0a741156e2cebc19f83 (tranche B-P1.H0, 751-1000) ; vb-P1-LIG-0001-0250.txt 80eec1b7a06e0ef04757e9678304924d (tranche B-P1.LIG, 1-250) ; vb-P1-LIG-0251-0500.txt c242727fe372dea12b39b0d255af6506 (tranche B-P1.LIG, 251-500) ; vb-P2-CST10-0001-0250.txt 3619caad9e24d571ef9a29f5a940045d (tranche B-P2.CST10, 1-250) ; vb-P2-CST10-0251-0500.txt 2af622fcaee22af613a038a1acc0a031 (tranche B-P2.CST10, 251-500) ; vb-P2-CST20-0001-0250.txt 779620e746efea5d9d8f86593299387b (tranche B-P2.CST20, 1-250) ; vb-P2-CST20-0251-0500.txt bf7bc31de278e5f3e4dec78557dac16c (tranche B-P2.CST20, 251-500) ; vb-P2-CST20-0501-0750.txt 7f4f354c489bd695dafe1a17ca5a2b57 (tranche B-P2.CST20, 501-750) ; vb-P2-CST20-0751-1000.txt 815945985d68a1930a971f7f66e07efa (tranche B-P2.CST20, 751-1000) ; vb-P2-DFI-0001-0250.txt dbabd95fde6c92dbd2ef4bb865eb49ff (tranche B-P2.DFI, 1-250) ; vb-P2-DFI-0251-0500.txt 9f258c4a8c40cd57fb901150ad5af355 (tranche B-P2.DFI, 251-500) ; vb-P2-EXP0-0001-0250.txt c1c1debb133f4050cc256dc3df89f752 (tranche B-P2.EXP0, 1-250) ; vb-P2-EXP0-0251-0500.txt 1b17ae657d343695f1586dca529154d3 (tranche B-P2.EXP0, 251-500) ; vb-P2-EXP2-0001-0250.txt 69055b8271a0e009367ffa1026789499 (tranche B-P2.EXP2, 1-250) ; vb-P2-EXP2-0251-0500.txt e4be00fed14743dccc50f70874675ed4 (tranche B-P2.EXP2, 251-500) ; vb-P2-EXP2-0501-0750.txt 761b1356168fdcf991a35e0ee3b71551 (tranche B-P2.EXP2, 501-750) ; vb-P2-EXP2-0751-1000.txt ade5dbcfa770cb78d25577f48131205a (tranche B-P2.EXP2, 751-1000) ; vb-P2-H0-0001-0250.txt 0858f26b38946425c429f99de52b987a (tranche B-P2.H0, 1-250) ; vb-P2-H0-0251-0500.txt 090d531ac7f9bcc638233a19de1e7764 (tranche B-P2.H0, 251-500) ; vb-P2-H0-0501-0750.txt 31782b696e86744889d70ed115506751 (tranche B-P2.H0, 501-750) ; vb-P2-H0-0751-1000.txt c1c01b9419b8a2e6994a41c53abbbba8 (tranche B-P2.H0, 751-1000) ; vb-P3-CST20-0001-0250.txt 231a244a9e1554b4f77533998374cdd9 (tranche B-P3.CST20, 1-250) ; vb-P3-CST20-0251-0500.txt 5ffeb1985b2ecc7d7f3c6d4a0cdb48c8 (tranche B-P3.CST20, 251-500) ; vb-P3-CST20-0501-0750.txt 067d871b4df111f3039aa177c8c82bc9 (tranche B-P3.CST20, 501-750) ; vb-P3-CST20-0751-1000.txt 162958201cd6abb1e0e8419fb9349d2d (tranche B-P3.CST20, 751-1000) ; vb-P3-DFI-0001-0250.txt a4270b9003bf83e8495d0bb0508a97e4 (tranche B-P3.DFI, 1-250) ; vb-P3-DFI-0251-0500.txt f54c0e0bd10a0263380901b5556c5120 (tranche B-P3.DFI, 251-500) ; vb-P3-H0-0001-0250.txt 64d174573f2e8454541d364c256f6dc5 (tranche B-P3.H0, 1-250) ; vb-P3-H0-0251-0500.txt 15acc5b9f8d2bfeeeb8034b740938b4f (tranche B-P3.H0, 251-500) ; vb-P3-H0-0501-0750.txt d0d1146c33e8fa5f6c8f9f40b3d8e042 (tranche B-P3.H0, 501-750) ; vb-P3-H0-0751-1000.txt 220b54d396722e48f9724f563f83a172 (tranche B-P3.H0, 751-1000) |
| Échantillons oracle (non versionnés, régénérables par leurs graines) : md5 des valeurs | ORA-A-A : f483fd98b194b08ad68a90445764b4a7 (fichier 3d347653bbd194abb4bb6c72936dd5aa) ; ORA-A-E : beb5ef8010dd8e09dfdecedb50e17337 (fichier 3ab15cf7be671a4d8b07fe14b6461cc6) ; ORA-A-N : 2657cd4956b4ef784935162082598d1c (fichier 9d2b3f8ec0969889e3083a36a61d5937) ; ORA-B-P2 : 315db0d8c53051009d3e4f5ca8523ca3 (fichier 527c6852bb47ff53b30738ca98563f96) ; ORA-B-P3 : e7098c098df7da2964c790bd402bdb6f (fichier 85ad7d03c5a44768ecd453ba4031c8f2) |
| JOURNAL | JOURNAL.md (md5 fe10b23239104d47798a152c797884f2) : md5 des 89 sorties conformes ; lignes du débit et de l'empreinte (#231) lues |
| Journaux versionnés de la mesure (second complément du 19/10/2026) | docs/tableaux/20261021-issue309-journal-mesure.md (copie du JOURNAL) ; docs/tableaux/20261021-issue309-journal-combinaison.md (journal de la combinaison) |
| Commit des sorties et commit de la combinaison | un même commit est exigé ENTRE LES SORTIES (contexte « commit » identique), non pour la combinaison, qui peut être faite à un autre commit, cité ci-dessous ; l'empreinte sans commentaires de R/engine.R (#231) doit être la même dans les sorties et à la combinaison |
| Empreinte sans commentaires (#231) du JOURNAL | 6ce112eecc6a7e9b6500ab639e757891, égale à celle des sorties (contrôle (i3)) |
| Commit de la combinaison | 754dd0a71e48243bc87240f2c0f3a825c23c8776 |
| Empreintes md5 du combinateur (moteur, outils, script) | R/engine.R a6250d419ea27cb2e87bf4ed70dac453 ; tests/outils_tests.R chargé (dépôt) 7127605f20e8c261d41d3c372f4f2f1b ; script exécuté (dépôt) cd4df329e47cdff297ce173234960a04 ; docs/specifications/fi-merz-wuthrich-puissance.md 072e12472ef287ff163ace3c3332ea6f |
| Empreinte sans commentaires de R/engine.R à la combinaison (#231) | 6ce112eecc6a7e9b6500ab639e757891 |
| Valeurs brutes | 20261021-issue309-puissance-mw-brut.tsv : md5 f616a3bc2e9a0cb6ce255396b0130ba0, 21000 lignes (copie hors du dépôt : --brut) |
| Versionnable (--ecrire) | oui |
| Contrôles d'intégrité | OK dans les 89 sorties ; invariants (d) relus sur les champs ; couvertures exactes ; (i3) : empreinte égale dans les sorties et à la combinaison |

### Aide à la lecture

Statut : **constat de simulation sous un plan** (modèle de Mack ajusté à reserve2, géométrie 8 × 8, plans de dispersion P1, P2, P3), pas un résultat général ; il ne se transpose ni à une autre géométrie de triangle ni à un autre paramétrage. Aucun théorème ne couvre ces tests bootstrap à T = 8. IC : Clopper-Pearson à 95 %, incertitude Monte-Carlo sur le taux (fonction de R), distincte de l'erreur de ρ (fonction de N0) et de err_mc (fonction de B = 999). Bande de Bradley : convention de lecture (#166), pas théorème. La puissance est lue **pour les scénarios, paramètres et plans fixés** (θ = 0,10, γ = 0,20, λ = 4 et 6, cellule visée (2, 1) ; κ = 3,4 pour P2) ; les statistiques FWb, FWr, MinP, MinP4, TMax sont des **candidats mesurés** de #301 et #300, PenteRel celui de #307 (Q-D1-Fi-9) : aucune décision n'est prise ici (point d'arrêt D2-Fi).

### Critères K-301 et K-300, fixés avant toute exécution

Texte recopié tel quel de la spécification (par. 2.7), identique dans le script (TEXTE_CRITERES_309, contrôle (t)) et au T0 ; évalué mécaniquement, **sans conclure**.

> - **K-301 (choix de la variante de BP)** :
>   1. FWr est retenue si, sous N et E, aux deux seuils, sa classe est compatible, écart mineur ou distorsion conservatrice, sans distorsion matérielle libérale sous A ;
>   2. à défaut, FWb aux mêmes conditions ;
>   3. à défaut, arrêt D2-Fi.
> - **K-300 (choix de la statistique de M4)**. Un candidat est éligible si :
>   - (i) son niveau Monte-Carlo n'a aucune distorsion matérielle libérale sous N, E et A ;
>   - (ii) sous P1, son taux de rejet est au moins celui de Grubbs à 0,10, à CEL6 et CELx4, et strictement plus grand à 0,05 (McNemar exact à 0,05).
> 
>   Entre MinP et MinP4 éligibles, on retient celui que le McNemar favorise à CEL4 et CEL6 ; à égalité, MinP, qui couvre plus de cellules. TMax n'est retenu que s'il domine les deux. Aucun candidat éligible : arrêt D2-Fi, et Grubbs reste en l'état.
> - Les autres grandeurs sont descriptives, sans seuil.

Précisions d'implémentation de l'évaluation mécanique (fixées avant exécution, distinctes du texte ci-dessus, soumises à actuary) :

- **Lecture mécanique de K-301** (lettre du texte, second complément du 19/10/2026) : pour une variante V, « condition remplie » si, pour ℓ ∈ {N, E} et aux deux seuils, la classe de #166 de V (volet A, p Monte-Carlo) est *compatible*, *écart mineur* ou *distorsion matérielle conservatrice* (un *écart non tranché* ne l'est pas ; son côté, conservateur si le taux est sous ρ/2 et libéral s'il est au-dessus de 3ρ/2, est affiché pour D2-Fi), et si, sous A, aucune des deux classes n'est une *distorsion matérielle libérale*. FWr, puis FWb à défaut ; sinon « arrêt D2-Fi ».
- **Lecture mécanique de K-300** (second complément du 19/10/2026) : (i) aucune distorsion matérielle *libérale* du candidat sous N, E et A, aux deux seuils (volet A). (ii) sous P1, aux cellules CEL6 et CELx4 (volet B) : à 0,10, taux du candidat ≥ celui de Grubbs (non-infériorité ponctuelle) ; à 0,05, taux strictement plus grand que celui de Grubbs et McNemar exact bilatéral < 0,05 en sa faveur (supériorité établie ; asymétrie voulue). « Le McNemar favorise X contre Y » : à CEL4 **et** à CEL6, au moins un des deux seuils (0,10 ; 0,05) donne un McNemar exact bilatéral < 0,05 en faveur de X (n01 > n10), et aucun des quatre couples (CEL4, CEL6) × (0,10 ; 0,05) ne le donne en faveur de Y. MinP4 n'est retenu contre MinP que s'il est favorisé, sinon MinP. TMax domine s'il est éligible et favorisé contre MinP **et** contre MinP4 ; un TMax éligible qui ne domine pas, seul éligible, relève de D2-Fi.
- **K0-x** (second complément du 19/10/2026) : test exact de Fisher bilatéral entre le taux mesuré de la colonne Calendrier (R = 500, 0,10) et le taux publié du T2 de #276 (401 / 1 000 et 319 / 1 000), tenu si p ≥ 0,025 par cellule (Bonferroni sur deux cellules).

### Évaluation mécanique de K0-c, K0-x, K0-t, K-301 et K-300 (sans conclusion)

| Critère | État mécanique | Détail |
| --- | --- | --- |
| K0-c | tenu | P2 : 0,2289 (tenu) ; P3 : 0,2571 (tenu) |
| K0-x (Fisher bilatéral, seuil 0,025 par cellule) | tenu | CAL7 : mesuré 190 / 500, 0,38000 [0,33727 ; 0,42415] ; publié 401 / 1000, 0,40100 [0,37045 ; 0,43213] ; Fisher bilatéral p = 0,466 (tenu) ; CAL4 : mesuré 172 / 500, 0,34400 [0,30239 ; 0,38747] ; publié 319 / 1000, 0,31900 [0,29018 ; 0,34889] ; Fisher bilatéral p = 0,35 (tenu) ; seuil 0,025 par cellule (Bonferroni sur deux cellules) |
| K0-t | tenu | 10000 (triangle, témoin) comparés (BP et Grubbs, volet A) : p_mc et B effectifs identiques à pR: et BR: du brut de #206 (|écart| ≤ 1e-12) |
| K-301 | FWr | FWr : condition remplie ; FWb : condition remplie ; état mécanique (sans conclure) : FWr |
| K-300 | MinP4 | MinP : (i) remplie ; (ii) non remplie [CEL6 0,10 : 349 contre 372 (Grubbs)] ; MinP4 : (i) remplie ; (ii) remplie ; TMax : (i) remplie ; (ii) non remplie [CEL6 0,10 : 37 contre 372 (Grubbs) ; CEL6 0,05 : 16 contre 86 (Grubbs), McNemar n01 / n10 = 15 / 85, p = 4,83e-13] ; McNemar (n01 / n10 de X contre Y, par couple cellule et seuil) — MinP4 contre MinP : CEL4 0,10 : 49 / 5, p = 3,89e-10 ; CEL4 0,05 : 20 / 1, p = 2,1e-05 ; CEL6 0,10 : 83 / 6, p = 2,02e-18 ; CEL6 0,05 : 49 / 4, p = 7,05e-11 ; favorisé : oui — TMax contre MinP : CEL4 0,10 : 25 / 129, p = 4,33e-18 ; CEL4 0,05 : 15 / 64, p = 2,3e-08 ; CEL6 0,10 : 19 / 331, p = 1,01e-74 ; CEL6 0,05 : 9 / 173, p = 1,7e-40 ; favorisé : non — TMax contre MinP4 : CEL4 0,10 : 27 / 175, p = 9,6e-28 ; CEL4 0,05 : 16 / 84, p = 2,61e-12 ; CEL6 0,10 : 25 / 414, p = 5,55e-92 ; CEL6 0,05 : 12 / 221, p = 6,14e-51 ; favorisé : non ; TMax domine : non ; état mécanique (sans conclure) : MinP4 |

### Référence ρ et diagnostics des oracles

ρ : taille lissée à B du test de Monte-Carlo idéal tirant ses répliques dans F0 (règle « ≥ » d'engine_p_mc(), règle unique de #206 pour les 19 statistiques, aucune classification a priori) ; statistique oracle non finie comptée comme non-rejet. Un oracle par jeu : ORA-A-N (loi N du volet A, **aussi l'oracle de P1** du volet B), ORA-A-E, ORA-A-A, ORA-B-P2, ORA-B-P3 (N0 triangles i.i.d. du même DGP). Erreur de ρ due à N0 : de l'ordre de 0,002 à α = 0,10 [H], distincte de l'IC sur τ (fonction de R) et de err_mc (fonction de B). ρ marqué « approché » au-delà de 1 % de statistiques oracle non finies pour la statistique.

| Oracle | Statistique (sens) | admis | non finies | valeurs distinctes | masse du plus gros atome | ρ 0,10 | ρ 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| ORA-A-A | Calendrier (bas) | 20000 | 0 | 83 | 0,09955 | 0,09114 | 0,04101 |
| ORA-A-A | CorrDev (deux) | 20000 | 0 | 1025 | 0,00395 | 0,09752 | 0,04762 |
| ORA-A-A | BP (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-A | Grubbs (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-A | DW (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 |
| ORA-A-A | Runs (deux) | 20000 | 0 | 17 | 0,17475 | 0,05315 | 0,03181 |
| ORA-A-A | PenteIntra (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 |
| ORA-A-A | Origine (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-A | HomogF (haut) | 20000 | 0 | 10793 | 0,00075 | 0,09896 | 0,04896 |
| ORA-A-A | Courbure (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-A | Alpha (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-A | ExpVar (haut) | 20000 | 0 | 10838 | 0,00070 | 0,09896 | 0,04896 |
| ORA-A-A | KruskalAcc (haut) | 20000 | 0 | 13715 | 0,00050 | 0,09896 | 0,04897 |
| ORA-A-A | FWb (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-A | FWr (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-A | MinP (bas) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-A | MinP4 (bas) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-A | TMax (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-A | PenteRel (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 |
| ORA-A-E | Calendrier (bas) | 20000 | 0 | 86 | 0,10535 | 0,09183 | 0,04120 |
| ORA-A-E | CorrDev (deux) | 20000 | 0 | 1020 | 0,00345 | 0,09751 | 0,04760 |
| ORA-A-E | BP (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-E | Grubbs (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-E | DW (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 |
| ORA-A-E | Runs (deux) | 20000 | 0 | 17 | 0,17745 | 0,05311 | 0,03103 |
| ORA-A-E | PenteIntra (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 |
| ORA-A-E | Origine (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-E | HomogF (haut) | 20000 | 0 | 10796 | 0,00065 | 0,09896 | 0,04896 |
| ORA-A-E | Courbure (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-E | Alpha (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-E | ExpVar (haut) | 20000 | 0 | 10892 | 0,00065 | 0,09896 | 0,04896 |
| ORA-A-E | KruskalAcc (haut) | 20000 | 0 | 13623 | 0,00045 | 0,09896 | 0,04897 |
| ORA-A-E | FWb (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-E | FWr (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-E | MinP (bas) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-E | MinP4 (bas) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-E | TMax (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-E | PenteRel (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 |
| ORA-A-N | Calendrier (bas) | 20000 | 0 | 84 | 0,10130 | 0,09004 | 0,04119 |
| ORA-A-N | CorrDev (deux) | 20000 | 0 | 1026 | 0,00415 | 0,09751 | 0,04761 |
| ORA-A-N | BP (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-N | Grubbs (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-N | DW (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 |
| ORA-A-N | Runs (deux) | 20000 | 0 | 17 | 0,16825 | 0,05122 | 0,03020 |
| ORA-A-N | PenteIntra (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 |
| ORA-A-N | Origine (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-N | HomogF (haut) | 20000 | 0 | 10898 | 0,00065 | 0,09896 | 0,04896 |
| ORA-A-N | Courbure (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-N | Alpha (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-N | ExpVar (haut) | 20000 | 0 | 10902 | 0,00080 | 0,09896 | 0,04897 |
| ORA-A-N | KruskalAcc (haut) | 20000 | 0 | 13636 | 0,00045 | 0,09896 | 0,04897 |
| ORA-A-N | FWb (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-N | FWr (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-N | MinP (bas) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-N | MinP4 (bas) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-N | TMax (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-A-N | PenteRel (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 |
| ORA-B-P2 | Calendrier (bas) | 20000 | 0 | 83 | 0,11120 | 0,09180 | 0,03968 |
| ORA-B-P2 | CorrDev (deux) | 20000 | 0 | 1018 | 0,00390 | 0,09751 | 0,04759 |
| ORA-B-P2 | BP (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P2 | Grubbs (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P2 | DW (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 |
| ORA-B-P2 | Runs (deux) | 20000 | 0 | 18 | 0,17350 | 0,05309 | 0,03018 |
| ORA-B-P2 | PenteIntra (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 |
| ORA-B-P2 | Origine (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P2 | HomogF (haut) | 20000 | 0 | 10830 | 0,00070 | 0,09896 | 0,04896 |
| ORA-B-P2 | Courbure (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P2 | Alpha (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P2 | ExpVar (haut) | 20000 | 0 | 10894 | 0,00080 | 0,09896 | 0,04896 |
| ORA-B-P2 | KruskalAcc (haut) | 20000 | 0 | 13645 | 0,00040 | 0,09897 | 0,04897 |
| ORA-B-P2 | FWb (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P2 | FWr (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P2 | MinP (bas) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P2 | MinP4 (bas) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P2 | TMax (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P2 | PenteRel (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 |
| ORA-B-P3 | Calendrier (bas) | 20000 | 0 | 84 | 0,10215 | 0,09069 | 0,04249 |
| ORA-B-P3 | CorrDev (deux) | 20000 | 0 | 1022 | 0,00380 | 0,09746 | 0,04759 |
| ORA-B-P3 | BP (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P3 | Grubbs (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P3 | DW (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 |
| ORA-B-P3 | Runs (deux) | 20000 | 0 | 17 | 0,16480 | 0,05000 | 0,03087 |
| ORA-B-P3 | PenteIntra (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 |
| ORA-B-P3 | Origine (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P3 | HomogF (haut) | 20000 | 0 | 10790 | 0,00090 | 0,09896 | 0,04896 |
| ORA-B-P3 | Courbure (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P3 | Alpha (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P3 | ExpVar (haut) | 20000 | 0 | 10905 | 0,00075 | 0,09896 | 0,04896 |
| ORA-B-P3 | KruskalAcc (haut) | 20000 | 0 | 13584 | 0,00045 | 0,09897 | 0,04897 |
| ORA-B-P3 | FWb (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P3 | FWr (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P3 | MinP (bas) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P3 | MinP4 (bas) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P3 | TMax (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 |
| ORA-B-P3 | PenteRel (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 |

### T1 — niveau des candidats (volet A : loi × statistique × seuil)

Par seuil : n triangles admis, p absentes (comptées comme non-rejet), ρ (taille lissée de l'oracle de la loi), k rejets (p_mc < α), taux k / n et IC de Clopper-Pearson à 95 % (5 décimales), classe de #166 contre ρ (côté en gras si l'IC est disjoint de la bande [ρ/2 ; 3ρ/2]), taux sur les seules p définies (descriptif). Plan et graines de #206 ; catalogue réduit {BP, Grubbs, FWb, FWr, MinP, MinP4, TMax} et PenteRel.

| Jeu | Statistique (sens) | n | abs. 0,10 | ρ 0,10 | k 0,10 | taux [IC] 0,10 | classe 0,10 | taux déf. 0,10 | abs. 0,05 | ρ 0,05 | k 0,05 | taux [IC] 0,05 | classe 0,05 | taux déf. 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| volet A, loi N (P1, H0) | BP (haut) | 2000 | 0 | 0,09897 | 32 | 0,01600 [0,01097 ; 0,02251] | distorsion matérielle (**conservateur**) | 0,01600 | 0 | 0,04897 | 10 | 0,00500 [0,00240 ; 0,00918] | distorsion matérielle (**conservateur**) | 0,00500 |
| volet A, loi N (P1, H0) | Grubbs (haut) | 2000 | 0 | 0,09897 | 198 | 0,09900 [0,08626 ; 0,11293] | compatible | 0,09900 | 0 | 0,04897 | 89 | 0,04450 [0,03589 ; 0,05448] | compatible | 0,04450 |
| volet A, loi N (P1, H0) | FWb (haut) | 2000 | 0 | 0,09897 | 176 | 0,08800 [0,07595 ; 0,10128] | compatible | 0,08800 | 0 | 0,04897 | 83 | 0,04150 [0,03319 ; 0,05119] | compatible | 0,04150 |
| volet A, loi N (P1, H0) | FWr (haut) | 2000 | 0 | 0,09897 | 178 | 0,08900 [0,07688 ; 0,10234] | compatible | 0,08900 | 0 | 0,04897 | 82 | 0,04100 [0,03274 ; 0,05064] | compatible | 0,04100 |
| volet A, loi N (P1, H0) | MinP (bas) | 2000 | 0 | 0,09897 | 114 | 0,05700 [0,04724 ; 0,06808] | écart mineur | 0,05700 | 0 | 0,04897 | 45 | 0,02250 [0,01646 ; 0,02999] | écart non tranché (côté conservateur) | 0,02250 |
| volet A, loi N (P1, H0) | MinP4 (bas) | 2000 | 0 | 0,09897 | 142 | 0,07100 [0,06013 ; 0,08315] | écart mineur | 0,07100 | 0 | 0,04897 | 58 | 0,02900 [0,02209 ; 0,03733] | écart mineur | 0,02900 |
| volet A, loi N (P1, H0) | TMax (haut) | 2000 | 0 | 0,09897 | 67 | 0,03350 [0,02605 ; 0,04235] | distorsion matérielle (**conservateur**) | 0,03350 | 0 | 0,04897 | 28 | 0,01400 [0,00932 ; 0,02017] | distorsion matérielle (**conservateur**) | 0,01400 |
| volet A, loi N (P1, H0) | PenteRel (deux) | 2000 | 0 | 0,09795 | 223 | 0,11150 [0,09803 ; 0,12612] | écart mineur | 0,11150 | 0 | 0,04795 | 122 | 0,06100 [0,05091 ; 0,07240] | écart mineur | 0,06100 |
| volet A, loi E (P1, H0) | BP (haut) | 2000 | 0 | 0,09897 | 139 | 0,06950 [0,05874 ; 0,08154] | écart mineur | 0,06950 | 0 | 0,04897 | 49 | 0,02450 [0,01818 ; 0,03226] | écart mineur | 0,02450 |
| volet A, loi E (P1, H0) | Grubbs (haut) | 2000 | 0 | 0,09897 | 150 | 0,07500 [0,06384 ; 0,08743] | écart mineur | 0,07500 | 0 | 0,04897 | 70 | 0,03500 [0,02738 ; 0,04402] | écart mineur | 0,03500 |
| volet A, loi E (P1, H0) | FWb (haut) | 2000 | 0 | 0,09897 | 192 | 0,09600 [0,08344 ; 0,10976] | compatible | 0,09600 | 0 | 0,04897 | 102 | 0,05100 [0,04177 ; 0,06157] | compatible | 0,05100 |
| volet A, loi E (P1, H0) | FWr (haut) | 2000 | 0 | 0,09897 | 194 | 0,09700 [0,08438 ; 0,11082] | compatible | 0,09700 | 0 | 0,04897 | 106 | 0,05300 [0,04359 ; 0,06374] | compatible | 0,05300 |
| volet A, loi E (P1, H0) | MinP (bas) | 2000 | 0 | 0,09897 | 165 | 0,08250 [0,07081 ; 0,09543] | écart mineur | 0,08250 | 0 | 0,04897 | 80 | 0,04000 [0,03184 ; 0,04954] | compatible | 0,04000 |
| volet A, loi E (P1, H0) | MinP4 (bas) | 2000 | 0 | 0,09897 | 157 | 0,07850 [0,06709 ; 0,09117] | écart mineur | 0,07850 | 0 | 0,04897 | 79 | 0,03950 [0,03139 ; 0,04899] | compatible | 0,03950 |
| volet A, loi E (P1, H0) | TMax (haut) | 2000 | 0 | 0,09897 | 177 | 0,08850 [0,07641 ; 0,10181] | compatible | 0,08850 | 0 | 0,04897 | 94 | 0,04700 [0,03815 ; 0,05721] | compatible | 0,04700 |
| volet A, loi E (P1, H0) | PenteRel (deux) | 2000 | 0 | 0,09795 | 221 | 0,11050 [0,09709 ; 0,12506] | compatible | 0,11050 | 0 | 0,04795 | 109 | 0,05450 [0,04496 ; 0,06537] | compatible | 0,05450 |
| volet A, loi A (P1, H0) | BP (haut) | 1000 | 0 | 0,09897 | 4 | 0,00400 [0,00109 ; 0,01021] | distorsion matérielle (**conservateur**) | 0,00400 | 0 | 0,04897 | 0 | 0,00000 [0,00000 ; 0,00368] | distorsion matérielle (**conservateur**) | 0,00000 |
| volet A, loi A (P1, H0) | Grubbs (haut) | 1000 | 0 | 0,09897 | 159 | 0,15900 [0,13687 ; 0,18316] | écart non tranché (côté libéral) | 0,15900 | 0 | 0,04897 | 88 | 0,08800 [0,07118 ; 0,10729] | écart non tranché (côté libéral) | 0,08800 |
| volet A, loi A (P1, H0) | FWb (haut) | 1000 | 0 | 0,09897 | 87 | 0,08700 [0,07027 ; 0,10621] | compatible | 0,08700 | 0 | 0,04897 | 49 | 0,04900 [0,03647 ; 0,06427] | compatible | 0,04900 |
| volet A, loi A (P1, H0) | FWr (haut) | 1000 | 0 | 0,09897 | 86 | 0,08600 [0,06936 ; 0,10512] | compatible | 0,08600 | 0 | 0,04897 | 46 | 0,04600 [0,03387 ; 0,06088] | compatible | 0,04600 |
| volet A, loi A (P1, H0) | MinP (bas) | 1000 | 0 | 0,09897 | 92 | 0,09200 [0,07481 ; 0,11164] | compatible | 0,09200 | 0 | 0,04897 | 41 | 0,04100 [0,02958 ; 0,05521] | compatible | 0,04100 |
| volet A, loi A (P1, H0) | MinP4 (bas) | 1000 | 0 | 0,09897 | 118 | 0,11800 [0,09865 ; 0,13963] | compatible | 0,11800 | 0 | 0,04897 | 47 | 0,04700 [0,03474 ; 0,06201] | compatible | 0,04700 |
| volet A, loi A (P1, H0) | TMax (haut) | 1000 | 0 | 0,09897 | 37 | 0,03700 [0,02618 ; 0,05064] | écart non tranché (côté conservateur) | 0,03700 | 0 | 0,04897 | 19 | 0,01900 [0,01148 ; 0,02951] | écart non tranché (côté conservateur) | 0,01900 |
| volet A, loi A (P1, H0) | PenteRel (deux) | 1000 | 0 | 0,09795 | 118 | 0,11800 [0,09865 ; 0,13963] | écart mineur | 0,11800 | 0 | 0,04795 | 59 | 0,05900 [0,04521 ; 0,07545] | compatible | 0,05900 |

### T1 bis — niveau sous H0 de chaque plan (volet B, loi N : P1, P2, P3), les 19 statistiques

Même lecture ; ρ de P1 : oracle de la loi N du volet A (même DGP) ; ρ de P2 et de P3 : leur oracle propre.

| Jeu | Statistique (sens) | n | abs. 0,10 | ρ 0,10 | k 0,10 | taux [IC] 0,10 | classe 0,10 | taux déf. 0,10 | abs. 0,05 | ρ 0,05 | k 0,05 | taux [IC] 0,05 | classe 0,05 | taux déf. 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P1.H0 | Calendrier (bas) | 1000 | 0 | 0,09004 | 100 | 0,10000 [0,08211 ; 0,12029] | compatible | 0,10000 | 0 | 0,04119 | 43 | 0,04300 [0,03129 ; 0,05749] | compatible | 0,04300 |
| P1.H0 | CorrDev (deux) | 1000 | 0 | 0,09751 | 87 | 0,08700 [0,07027 ; 0,10621] | compatible | 0,08700 | 0 | 0,04761 | 40 | 0,04000 [0,02873 ; 0,05407] | compatible | 0,04000 |
| P1.H0 | BP (haut) | 1000 | 0 | 0,09897 | 22 | 0,02200 [0,01384 ; 0,03312] | distorsion matérielle (**conservateur**) | 0,02200 | 0 | 0,04897 | 6 | 0,00600 [0,00220 ; 0,01301] | distorsion matérielle (**conservateur**) | 0,00600 |
| P1.H0 | Grubbs (haut) | 1000 | 0 | 0,09897 | 83 | 0,08300 [0,06665 ; 0,10185] | compatible | 0,08300 | 0 | 0,04897 | 35 | 0,03500 [0,02450 ; 0,04834] | écart mineur | 0,03500 |
| P1.H0 | DW (deux) | 1000 | 0 | 0,09795 | 112 | 0,11200 [0,09312 ; 0,13320] | compatible | 0,11200 | 0 | 0,04795 | 55 | 0,05500 [0,04170 ; 0,07099] | compatible | 0,05500 |
| P1.H0 | Runs (deux) | 1000 | 0 | 0,05122 | 47 | 0,04700 [0,03474 ; 0,06201] | compatible | 0,04700 | 0 | 0,03020 | 20 | 0,02000 [0,01226 ; 0,03072] | compatible | 0,02000 |
| P1.H0 | PenteIntra (deux) | 1000 | 0 | 0,09795 | 122 | 0,12200 [0,10235 ; 0,14390] | écart mineur | 0,12200 | 0 | 0,04795 | 67 | 0,06700 [0,05230 ; 0,08431] | écart mineur | 0,06700 |
| P1.H0 | Origine (haut) | 1000 | 0 | 0,09897 | 96 | 0,09600 [0,07845 ; 0,11597] | compatible | 0,09600 | 0 | 0,04897 | 45 | 0,04500 [0,03301 ; 0,05975] | compatible | 0,04500 |
| P1.H0 | HomogF (haut) | 1000 | 0 | 0,09896 | 106 | 0,10600 [0,08760 ; 0,12675] | compatible | 0,10600 | 0 | 0,04896 | 51 | 0,05100 [0,03821 ; 0,06651] | compatible | 0,05100 |
| P1.H0 | Courbure (haut) | 1000 | 0 | 0,09897 | 90 | 0,09000 [0,07299 ; 0,10947] | compatible | 0,09000 | 0 | 0,04897 | 45 | 0,04500 [0,03301 ; 0,05975] | compatible | 0,04500 |
| P1.H0 | Alpha (haut) | 1000 | 0 | 0,09897 | 102 | 0,10200 [0,08394 ; 0,12245] | compatible | 0,10200 | 0 | 0,04897 | 44 | 0,04400 [0,03215 ; 0,05862] | compatible | 0,04400 |
| P1.H0 | ExpVar (haut) | 1000 | 0 | 0,09896 | 91 | 0,09100 [0,07390 ; 0,11055] | compatible | 0,09100 | 0 | 0,04897 | 45 | 0,04500 [0,03301 ; 0,05975] | compatible | 0,04500 |
| P1.H0 | KruskalAcc (haut) | 1000 | 0 | 0,09896 | 98 | 0,09800 [0,08028 ; 0,11813] | compatible | 0,09800 | 0 | 0,04897 | 47 | 0,04700 [0,03474 ; 0,06201] | compatible | 0,04700 |
| P1.H0 | FWb (haut) | 1000 | 0 | 0,09897 | 90 | 0,09000 [0,07299 ; 0,10947] | compatible | 0,09000 | 0 | 0,04897 | 44 | 0,04400 [0,03215 ; 0,05862] | compatible | 0,04400 |
| P1.H0 | FWr (haut) | 1000 | 0 | 0,09897 | 90 | 0,09000 [0,07299 ; 0,10947] | compatible | 0,09000 | 0 | 0,04897 | 42 | 0,04200 [0,03043 ; 0,05635] | compatible | 0,04200 |
| P1.H0 | MinP (bas) | 1000 | 0 | 0,09897 | 46 | 0,04600 [0,03387 ; 0,06088] | écart non tranché (côté conservateur) | 0,04600 | 0 | 0,04897 | 12 | 0,01200 [0,00622 ; 0,02087] | distorsion matérielle (**conservateur**) | 0,01200 |
| P1.H0 | MinP4 (bas) | 1000 | 0 | 0,09897 | 54 | 0,05400 [0,04082 ; 0,06987] | écart mineur | 0,05400 | 0 | 0,04897 | 18 | 0,01800 [0,01070 ; 0,02830] | écart non tranché (côté conservateur) | 0,01800 |
| P1.H0 | TMax (haut) | 1000 | 0 | 0,09897 | 38 | 0,03800 [0,02703 ; 0,05179] | écart non tranché (côté conservateur) | 0,03800 | 0 | 0,04897 | 11 | 0,01100 [0,00550 ; 0,01960] | distorsion matérielle (**conservateur**) | 0,01100 |
| P1.H0 | PenteRel (deux) | 1000 | 0 | 0,09795 | 118 | 0,11800 [0,09865 ; 0,13963] | écart mineur | 0,11800 | 0 | 0,04795 | 59 | 0,05900 [0,04521 ; 0,07545] | compatible | 0,05900 |
| P2.H0 | Calendrier (bas) | 1000 | 0 | 0,09180 | 97 | 0,09700 [0,07936 ; 0,11705] | compatible | 0,09700 | 0 | 0,03968 | 39 | 0,03900 [0,02788 ; 0,05293] | compatible | 0,03900 |
| P2.H0 | CorrDev (deux) | 1000 | 0 | 0,09751 | 119 | 0,11900 [0,09958 ; 0,14070] | écart mineur | 0,11900 | 0 | 0,04759 | 52 | 0,05200 [0,03908 ; 0,06764] | compatible | 0,05200 |
| P2.H0 | BP (haut) | 1000 | 0 | 0,09897 | 63 | 0,06300 [0,04875 ; 0,07989] | écart mineur | 0,06300 | 0 | 0,04897 | 30 | 0,03000 [0,02033 ; 0,04255] | écart mineur | 0,03000 |
| P2.H0 | Grubbs (haut) | 1000 | 0 | 0,09897 | 107 | 0,10700 [0,08852 ; 0,12783] | compatible | 0,10700 | 0 | 0,04897 | 54 | 0,05400 [0,04082 ; 0,06987] | compatible | 0,05400 |
| P2.H0 | DW (deux) | 1000 | 0 | 0,09795 | 84 | 0,08400 [0,06755 ; 0,10294] | compatible | 0,08400 | 0 | 0,04795 | 45 | 0,04500 [0,03301 ; 0,05975] | compatible | 0,04500 |
| P2.H0 | Runs (deux) | 1000 | 0 | 0,05309 | 47 | 0,04700 [0,03474 ; 0,06201] | compatible | 0,04700 | 0 | 0,03018 | 22 | 0,02200 [0,01384 ; 0,03312] | compatible | 0,02200 |
| P2.H0 | PenteIntra (deux) | 1000 | 0 | 0,09795 | 116 | 0,11600 [0,09681 ; 0,13749] | compatible | 0,11600 | 0 | 0,04795 | 56 | 0,05600 [0,04258 ; 0,07211] | compatible | 0,05600 |
| P2.H0 | Origine (haut) | 1000 | 0 | 0,09897 | 96 | 0,09600 [0,07845 ; 0,11597] | compatible | 0,09600 | 0 | 0,04897 | 46 | 0,04600 [0,03387 ; 0,06088] | compatible | 0,04600 |
| P2.H0 | HomogF (haut) | 1000 | 0 | 0,09896 | 101 | 0,10100 [0,08302 ; 0,12137] | compatible | 0,10100 | 0 | 0,04896 | 49 | 0,04900 [0,03647 ; 0,06427] | compatible | 0,04900 |
| P2.H0 | Courbure (haut) | 1000 | 0 | 0,09897 | 89 | 0,08900 [0,07208 ; 0,10838] | compatible | 0,08900 | 0 | 0,04897 | 49 | 0,04900 [0,03647 ; 0,06427] | compatible | 0,04900 |
| P2.H0 | Alpha (haut) | 1000 | 0 | 0,09897 | 95 | 0,09500 [0,07754 ; 0,11488] | compatible | 0,09500 | 0 | 0,04897 | 37 | 0,03700 [0,02618 ; 0,05064] | compatible | 0,03700 |
| P2.H0 | ExpVar (haut) | 1000 | 0 | 0,09896 | 89 | 0,08900 [0,07208 ; 0,10838] | compatible | 0,08900 | 0 | 0,04896 | 39 | 0,03900 [0,02788 ; 0,05293] | compatible | 0,03900 |
| P2.H0 | KruskalAcc (haut) | 1000 | 0 | 0,09897 | 99 | 0,09900 [0,08119 ; 0,11921] | compatible | 0,09900 | 0 | 0,04897 | 50 | 0,05000 [0,03734 ; 0,06539] | compatible | 0,05000 |
| P2.H0 | FWb (haut) | 1000 | 0 | 0,09897 | 97 | 0,09700 [0,07936 ; 0,11705] | compatible | 0,09700 | 0 | 0,04897 | 47 | 0,04700 [0,03474 ; 0,06201] | compatible | 0,04700 |
| P2.H0 | FWr (haut) | 1000 | 0 | 0,09897 | 94 | 0,09400 [0,07663 ; 0,11380] | compatible | 0,09400 | 0 | 0,04897 | 49 | 0,04900 [0,03647 ; 0,06427] | compatible | 0,04900 |
| P2.H0 | MinP (bas) | 1000 | 0 | 0,09897 | 72 | 0,07200 [0,05676 ; 0,08982] | écart mineur | 0,07200 | 0 | 0,04897 | 34 | 0,03400 [0,02366 ; 0,04719] | écart mineur | 0,03400 |
| P2.H0 | MinP4 (bas) | 1000 | 0 | 0,09897 | 74 | 0,07400 [0,05855 ; 0,09201] | écart mineur | 0,07400 | 0 | 0,04897 | 34 | 0,03400 [0,02366 ; 0,04719] | écart mineur | 0,03400 |
| P2.H0 | TMax (haut) | 1000 | 0 | 0,09897 | 71 | 0,07100 [0,05586 ; 0,08872] | écart mineur | 0,07100 | 0 | 0,04897 | 34 | 0,03400 [0,02366 ; 0,04719] | écart mineur | 0,03400 |
| P2.H0 | PenteRel (deux) | 1000 | 0 | 0,09795 | 112 | 0,11200 [0,09312 ; 0,13320] | compatible | 0,11200 | 0 | 0,04795 | 59 | 0,05900 [0,04521 ; 0,07545] | compatible | 0,05900 |
| P3.H0 | Calendrier (bas) | 1000 | 0 | 0,09069 | 86 | 0,08600 [0,06936 ; 0,10512] | compatible | 0,08600 | 0 | 0,04249 | 36 | 0,03600 [0,02534 ; 0,04949] | compatible | 0,03600 |
| P3.H0 | CorrDev (deux) | 1000 | 0 | 0,09746 | 84 | 0,08400 [0,06755 ; 0,10294] | compatible | 0,08400 | 0 | 0,04759 | 45 | 0,04500 [0,03301 ; 0,05975] | compatible | 0,04500 |
| P3.H0 | BP (haut) | 1000 | 0 | 0,09897 | 54 | 0,05400 [0,04082 ; 0,06987] | écart mineur | 0,05400 | 0 | 0,04897 | 16 | 0,01600 [0,00917 ; 0,02585] | écart non tranché (côté conservateur) | 0,01600 |
| P3.H0 | Grubbs (haut) | 1000 | 0 | 0,09897 | 92 | 0,09200 [0,07481 ; 0,11164] | compatible | 0,09200 | 0 | 0,04897 | 35 | 0,03500 [0,02450 ; 0,04834] | écart mineur | 0,03500 |
| P3.H0 | DW (deux) | 1000 | 0 | 0,09795 | 81 | 0,08100 [0,06484 ; 0,09967] | compatible | 0,08100 | 0 | 0,04795 | 37 | 0,03700 [0,02618 ; 0,05064] | compatible | 0,03700 |
| P3.H0 | Runs (deux) | 1000 | 0 | 0,05000 | 42 | 0,04200 [0,03043 ; 0,05635] | compatible | 0,04200 | 0 | 0,03087 | 20 | 0,02000 [0,01226 ; 0,03072] | écart mineur | 0,02000 |
| P3.H0 | PenteIntra (deux) | 1000 | 0 | 0,09795 | 129 | 0,12900 [0,10884 ; 0,15137] | écart mineur | 0,12900 | 0 | 0,04795 | 66 | 0,06600 [0,05141 ; 0,08321] | écart mineur | 0,06600 |
| P3.H0 | Origine (haut) | 1000 | 0 | 0,09897 | 105 | 0,10500 [0,08668 ; 0,12568] | compatible | 0,10500 | 0 | 0,04897 | 54 | 0,05400 [0,04082 ; 0,06987] | compatible | 0,05400 |
| P3.H0 | HomogF (haut) | 1000 | 0 | 0,09896 | 64 | 0,06400 [0,04963 ; 0,08100] | écart mineur | 0,06400 | 0 | 0,04896 | 33 | 0,03300 [0,02282 ; 0,04603] | écart mineur | 0,03300 |
| P3.H0 | Courbure (haut) | 1000 | 0 | 0,09897 | 104 | 0,10400 [0,08577 ; 0,12460] | compatible | 0,10400 | 0 | 0,04897 | 49 | 0,04900 [0,03647 ; 0,06427] | compatible | 0,04900 |
| P3.H0 | Alpha (haut) | 1000 | 0 | 0,09897 | 98 | 0,09800 [0,08028 ; 0,11813] | compatible | 0,09800 | 0 | 0,04897 | 42 | 0,04200 [0,03043 ; 0,05635] | compatible | 0,04200 |
| P3.H0 | ExpVar (haut) | 1000 | 0 | 0,09896 | 82 | 0,08200 [0,06575 ; 0,10076] | compatible | 0,08200 | 0 | 0,04896 | 38 | 0,03800 [0,02703 ; 0,05179] | compatible | 0,03800 |
| P3.H0 | KruskalAcc (haut) | 1000 | 0 | 0,09897 | 101 | 0,10100 [0,08302 ; 0,12137] | compatible | 0,10100 | 0 | 0,04897 | 57 | 0,05700 [0,04345 ; 0,07322] | compatible | 0,05700 |
| P3.H0 | FWb (haut) | 1000 | 0 | 0,09897 | 76 | 0,07600 [0,06034 ; 0,09420] | écart mineur | 0,07600 | 0 | 0,04897 | 34 | 0,03400 [0,02366 ; 0,04719] | écart mineur | 0,03400 |
| P3.H0 | FWr (haut) | 1000 | 0 | 0,09897 | 89 | 0,08900 [0,07208 ; 0,10838] | compatible | 0,08900 | 0 | 0,04897 | 43 | 0,04300 [0,03129 ; 0,05749] | compatible | 0,04300 |
| P3.H0 | MinP (bas) | 1000 | 0 | 0,09897 | 64 | 0,06400 [0,04963 ; 0,08100] | écart mineur | 0,06400 | 0 | 0,04897 | 37 | 0,03700 [0,02618 ; 0,05064] | compatible | 0,03700 |
| P3.H0 | MinP4 (bas) | 1000 | 0 | 0,09897 | 64 | 0,06400 [0,04963 ; 0,08100] | écart mineur | 0,06400 | 0 | 0,04897 | 32 | 0,03200 [0,02199 ; 0,04488] | écart mineur | 0,03200 |
| P3.H0 | TMax (haut) | 1000 | 0 | 0,09897 | 85 | 0,08500 [0,06846 ; 0,10403] | compatible | 0,08500 | 0 | 0,04897 | 53 | 0,05300 [0,03995 ; 0,06876] | compatible | 0,05300 |
| P3.H0 | PenteRel (deux) | 1000 | 0 | 0,09795 | 137 | 0,13700 [0,11628 ; 0,15988] | écart mineur | 0,13700 | 0 | 0,04795 | 75 | 0,07500 [0,05945 ; 0,09311] | écart non tranché (côté libéral) | 0,07500 |

### T2 — puissance : taux de rejet (p_mc < α) par cellule, statistique et seuil

Volet B, loi N, B = 999, triangles admis de chaque cellule (plan P1, P2 ou P3 × scénario) ; p absente comptée comme non-rejet ; k / n, taux et IC de Clopper-Pearson à 95 % (5 décimales). La ligne H0 de chaque plan est le niveau de la cellule (voir T1 pour ρ et la classe). Rosner : procédure à niveau α sans p-value ; taux de triangles à ≥ 1 cellule déclarée (k̂ ≥ 1) au seuil α de la ligne, sur les mêmes triangles. Constat de simulation sous un plan, non général.

| Plan | Scénario | Statistique (sens) | n | abs. 0,10 | k 0,10 | taux [IC] 0,10 | abs. 0,05 | k 0,05 | taux [IC] 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P1 | H0 | Calendrier (bas) | 1000 | 0 | 100 | 0,10000 [0,08211 ; 0,12029] | 0 | 43 | 0,04300 [0,03129 ; 0,05749] |
| P1 | H0 | CorrDev (deux) | 1000 | 0 | 87 | 0,08700 [0,07027 ; 0,10621] | 0 | 40 | 0,04000 [0,02873 ; 0,05407] |
| P1 | H0 | BP (haut) | 1000 | 0 | 22 | 0,02200 [0,01384 ; 0,03312] | 0 | 6 | 0,00600 [0,00220 ; 0,01301] |
| P1 | H0 | Grubbs (haut) | 1000 | 0 | 83 | 0,08300 [0,06665 ; 0,10185] | 0 | 35 | 0,03500 [0,02450 ; 0,04834] |
| P1 | H0 | DW (deux) | 1000 | 0 | 112 | 0,11200 [0,09312 ; 0,13320] | 0 | 55 | 0,05500 [0,04170 ; 0,07099] |
| P1 | H0 | Runs (deux) | 1000 | 0 | 47 | 0,04700 [0,03474 ; 0,06201] | 0 | 20 | 0,02000 [0,01226 ; 0,03072] |
| P1 | H0 | PenteIntra (deux) | 1000 | 0 | 122 | 0,12200 [0,10235 ; 0,14390] | 0 | 67 | 0,06700 [0,05230 ; 0,08431] |
| P1 | H0 | Origine (haut) | 1000 | 0 | 96 | 0,09600 [0,07845 ; 0,11597] | 0 | 45 | 0,04500 [0,03301 ; 0,05975] |
| P1 | H0 | HomogF (haut) | 1000 | 0 | 106 | 0,10600 [0,08760 ; 0,12675] | 0 | 51 | 0,05100 [0,03821 ; 0,06651] |
| P1 | H0 | Courbure (haut) | 1000 | 0 | 90 | 0,09000 [0,07299 ; 0,10947] | 0 | 45 | 0,04500 [0,03301 ; 0,05975] |
| P1 | H0 | Alpha (haut) | 1000 | 0 | 102 | 0,10200 [0,08394 ; 0,12245] | 0 | 44 | 0,04400 [0,03215 ; 0,05862] |
| P1 | H0 | ExpVar (haut) | 1000 | 0 | 91 | 0,09100 [0,07390 ; 0,11055] | 0 | 45 | 0,04500 [0,03301 ; 0,05975] |
| P1 | H0 | KruskalAcc (haut) | 1000 | 0 | 98 | 0,09800 [0,08028 ; 0,11813] | 0 | 47 | 0,04700 [0,03474 ; 0,06201] |
| P1 | H0 | FWb (haut) | 1000 | 0 | 90 | 0,09000 [0,07299 ; 0,10947] | 0 | 44 | 0,04400 [0,03215 ; 0,05862] |
| P1 | H0 | FWr (haut) | 1000 | 0 | 90 | 0,09000 [0,07299 ; 0,10947] | 0 | 42 | 0,04200 [0,03043 ; 0,05635] |
| P1 | H0 | MinP (bas) | 1000 | 0 | 46 | 0,04600 [0,03387 ; 0,06088] | 0 | 12 | 0,01200 [0,00622 ; 0,02087] |
| P1 | H0 | MinP4 (bas) | 1000 | 0 | 54 | 0,05400 [0,04082 ; 0,06987] | 0 | 18 | 0,01800 [0,01070 ; 0,02830] |
| P1 | H0 | TMax (haut) | 1000 | 0 | 38 | 0,03800 [0,02703 ; 0,05179] | 0 | 11 | 0,01100 [0,00550 ; 0,01960] |
| P1 | H0 | PenteRel (deux) | 1000 | 0 | 118 | 0,11800 [0,09865 ; 0,13963] | 0 | 59 | 0,05900 [0,04521 ; 0,07545] |
| P1 | H0 | Rosner, k̂ ≥ 1 (α = 0,10) | 1000 | 0 | 0 | 0,00000 [0,00000 ; 0,00368] | — | — | — |
| P1 | H0 | Rosner, k̂ ≥ 1 (α = 0,05) | 1000 | — | — | — | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P1 | CST20 | Calendrier (bas) | 1000 | 0 | 216 | 0,21600 [0,19086 ; 0,24282] | 0 | 106 | 0,10600 [0,08760 ; 0,12675] |
| P1 | CST20 | CorrDev (deux) | 1000 | 0 | 128 | 0,12800 [0,10791 ; 0,15031] | 0 | 62 | 0,06200 [0,04786 ; 0,07878] |
| P1 | CST20 | BP (haut) | 1000 | 0 | 2 | 0,00200 [0,00024 ; 0,00721] | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P1 | CST20 | Grubbs (haut) | 1000 | 0 | 72 | 0,07200 [0,05676 ; 0,08982] | 0 | 32 | 0,03200 [0,02199 ; 0,04488] |
| P1 | CST20 | DW (deux) | 1000 | 0 | 140 | 0,14000 [0,11908 ; 0,16307] | 0 | 65 | 0,06500 [0,05052 ; 0,08210] |
| P1 | CST20 | Runs (deux) | 1000 | 0 | 61 | 0,06100 [0,04698 ; 0,07767] | 0 | 26 | 0,02600 [0,01705 ; 0,03787] |
| P1 | CST20 | PenteIntra (deux) | 1000 | 0 | 522 | 0,52200 [0,49051 ; 0,55336] | 0 | 419 | 0,41900 [0,38820 ; 0,45028] |
| P1 | CST20 | Origine (haut) | 1000 | 0 | 683 | 0,68300 [0,65315 ; 0,71177] | 0 | 504 | 0,50400 [0,47254 ; 0,53544] |
| P1 | CST20 | HomogF (haut) | 1000 | 0 | 612 | 0,61200 [0,58100 ; 0,64233] | 0 | 444 | 0,44400 [0,41291 ; 0,47542] |
| P1 | CST20 | Courbure (haut) | 1000 | 0 | 78 | 0,07800 [0,06214 ; 0,09639] | 0 | 40 | 0,04000 [0,02873 ; 0,05407] |
| P1 | CST20 | Alpha (haut) | 1000 | 0 | 466 | 0,46600 [0,43472 ; 0,49748] | 0 | 110 | 0,11000 [0,09128 ; 0,13105] |
| P1 | CST20 | ExpVar (haut) | 1000 | 0 | 46 | 0,04600 [0,03387 ; 0,06088] | 0 | 22 | 0,02200 [0,01384 ; 0,03312] |
| P1 | CST20 | KruskalAcc (haut) | 1000 | 0 | 124 | 0,12400 [0,10420 ; 0,14604] | 0 | 52 | 0,05200 [0,03908 ; 0,06764] |
| P1 | CST20 | FWb (haut) | 1000 | 0 | 98 | 0,09800 [0,08028 ; 0,11813] | 0 | 43 | 0,04300 [0,03129 ; 0,05749] |
| P1 | CST20 | FWr (haut) | 1000 | 0 | 80 | 0,08000 [0,06394 ; 0,09858] | 0 | 36 | 0,03600 [0,02534 ; 0,04949] |
| P1 | CST20 | MinP (bas) | 1000 | 0 | 43 | 0,04300 [0,03129 ; 0,05749] | 0 | 17 | 0,01700 [0,00993 ; 0,02708] |
| P1 | CST20 | MinP4 (bas) | 1000 | 0 | 65 | 0,06500 [0,05052 ; 0,08210] | 0 | 25 | 0,02500 [0,01624 ; 0,03668] |
| P1 | CST20 | TMax (haut) | 1000 | 0 | 25 | 0,02500 [0,01624 ; 0,03668] | 0 | 9 | 0,00900 [0,00412 ; 0,01702] |
| P1 | CST20 | PenteRel (deux) | 1000 | 0 | 796 | 0,79600 [0,76967 ; 0,82057] | 0 | 709 | 0,70900 [0,67976 ; 0,73700] |
| P1 | CST20 | Rosner, k̂ ≥ 1 (α = 0,10) | 1000 | 0 | 1 | 0,00100 [0,00003 ; 0,00556] | — | — | — |
| P1 | CST20 | Rosner, k̂ ≥ 1 (α = 0,05) | 1000 | — | — | — | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P1 | EXP2 | Calendrier (bas) | 1000 | 0 | 100 | 0,10000 [0,08211 ; 0,12029] | 0 | 41 | 0,04100 [0,02958 ; 0,05521] |
| P1 | EXP2 | CorrDev (deux) | 1000 | 0 | 100 | 0,10000 [0,08211 ; 0,12029] | 0 | 53 | 0,05300 [0,03995 ; 0,06876] |
| P1 | EXP2 | BP (haut) | 1000 | 0 | 22 | 0,02200 [0,01384 ; 0,03312] | 0 | 4 | 0,00400 [0,00109 ; 0,01021] |
| P1 | EXP2 | Grubbs (haut) | 1000 | 0 | 81 | 0,08100 [0,06484 ; 0,09967] | 0 | 41 | 0,04100 [0,02958 ; 0,05521] |
| P1 | EXP2 | DW (deux) | 1000 | 0 | 89 | 0,08900 [0,07208 ; 0,10838] | 0 | 34 | 0,03400 [0,02366 ; 0,04719] |
| P1 | EXP2 | Runs (deux) | 1000 | 0 | 64 | 0,06400 [0,04963 ; 0,08100] | 0 | 37 | 0,03700 [0,02618 ; 0,05064] |
| P1 | EXP2 | PenteIntra (deux) | 1000 | 0 | 128 | 0,12800 [0,10791 ; 0,15031] | 0 | 69 | 0,06900 [0,05408 ; 0,08652] |
| P1 | EXP2 | Origine (haut) | 1000 | 0 | 88 | 0,08800 [0,07118 ; 0,10729] | 0 | 46 | 0,04600 [0,03387 ; 0,06088] |
| P1 | EXP2 | HomogF (haut) | 1000 | 0 | 85 | 0,08500 [0,06846 ; 0,10403] | 0 | 49 | 0,04900 [0,03647 ; 0,06427] |
| P1 | EXP2 | Courbure (haut) | 1000 | 0 | 82 | 0,08200 [0,06575 ; 0,10076] | 0 | 47 | 0,04700 [0,03474 ; 0,06201] |
| P1 | EXP2 | Alpha (haut) | 1000 | 0 | 81 | 0,08100 [0,06484 ; 0,09967] | 0 | 29 | 0,02900 [0,01951 ; 0,04138] |
| P1 | EXP2 | ExpVar (haut) | 1000 | 0 | 98 | 0,09800 [0,08028 ; 0,11813] | 0 | 55 | 0,05500 [0,04170 ; 0,07099] |
| P1 | EXP2 | KruskalAcc (haut) | 1000 | 0 | 90 | 0,09000 [0,07299 ; 0,10947] | 0 | 44 | 0,04400 [0,03215 ; 0,05862] |
| P1 | EXP2 | FWb (haut) | 1000 | 0 | 94 | 0,09400 [0,07663 ; 0,11380] | 0 | 47 | 0,04700 [0,03474 ; 0,06201] |
| P1 | EXP2 | FWr (haut) | 1000 | 0 | 93 | 0,09300 [0,07572 ; 0,11272] | 0 | 49 | 0,04900 [0,03647 ; 0,06427] |
| P1 | EXP2 | MinP (bas) | 1000 | 0 | 47 | 0,04700 [0,03474 ; 0,06201] | 0 | 17 | 0,01700 [0,00993 ; 0,02708] |
| P1 | EXP2 | MinP4 (bas) | 1000 | 0 | 58 | 0,05800 [0,04433 ; 0,07434] | 0 | 18 | 0,01800 [0,01070 ; 0,02830] |
| P1 | EXP2 | TMax (haut) | 1000 | 0 | 32 | 0,03200 [0,02199 ; 0,04488] | 0 | 17 | 0,01700 [0,00993 ; 0,02708] |
| P1 | EXP2 | PenteRel (deux) | 1000 | 0 | 109 | 0,10900 [0,09036 ; 0,12998] | 0 | 55 | 0,05500 [0,04170 ; 0,07099] |
| P1 | EXP2 | Rosner, k̂ ≥ 1 (α = 0,10) | 1000 | 0 | 0 | 0,00000 [0,00000 ; 0,00368] | — | — | — |
| P1 | EXP2 | Rosner, k̂ ≥ 1 (α = 0,05) | 1000 | — | — | — | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P1 | CEL4 | Calendrier (bas) | 1000 | 0 | 102 | 0,10200 [0,08394 ; 0,12245] | 0 | 45 | 0,04500 [0,03301 ; 0,05975] |
| P1 | CEL4 | CorrDev (deux) | 1000 | 0 | 105 | 0,10500 [0,08668 ; 0,12568] | 0 | 52 | 0,05200 [0,03908 ; 0,06764] |
| P1 | CEL4 | BP (haut) | 1000 | 0 | 4 | 0,00400 [0,00109 ; 0,01021] | 0 | 2 | 0,00200 [0,00024 ; 0,00721] |
| P1 | CEL4 | Grubbs (haut) | 1000 | 0 | 211 | 0,21100 [0,18609 ; 0,23762] | 0 | 63 | 0,06300 [0,04875 ; 0,07989] |
| P1 | CEL4 | DW (deux) | 1000 | 0 | 61 | 0,06100 [0,04698 ; 0,07767] | 0 | 30 | 0,03000 [0,02033 ; 0,04255] |
| P1 | CEL4 | Runs (deux) | 1000 | 0 | 42 | 0,04200 [0,03043 ; 0,05635] | 0 | 26 | 0,02600 [0,01705 ; 0,03787] |
| P1 | CEL4 | PenteIntra (deux) | 1000 | 0 | 153 | 0,15300 [0,13124 ; 0,17683] | 0 | 89 | 0,08900 [0,07208 ; 0,10838] |
| P1 | CEL4 | Origine (haut) | 1000 | 0 | 57 | 0,05700 [0,04345 ; 0,07322] | 0 | 20 | 0,02000 [0,01226 ; 0,03072] |
| P1 | CEL4 | HomogF (haut) | 1000 | 0 | 63 | 0,06300 [0,04875 ; 0,07989] | 0 | 33 | 0,03300 [0,02282 ; 0,04603] |
| P1 | CEL4 | Courbure (haut) | 1000 | 0 | 71 | 0,07100 [0,05586 ; 0,08872] | 0 | 29 | 0,02900 [0,01951 ; 0,04138] |
| P1 | CEL4 | Alpha (haut) | 1000 | 0 | 18 | 0,01800 [0,01070 ; 0,02830] | 0 | 5 | 0,00500 [0,00163 ; 0,01163] |
| P1 | CEL4 | ExpVar (haut) | 1000 | 0 | 80 | 0,08000 [0,06394 ; 0,09858] | 0 | 33 | 0,03300 [0,02282 ; 0,04603] |
| P1 | CEL4 | KruskalAcc (haut) | 1000 | 0 | 37 | 0,03700 [0,02618 ; 0,05064] | 0 | 17 | 0,01700 [0,00993 ; 0,02708] |
| P1 | CEL4 | FWb (haut) | 1000 | 0 | 29 | 0,02900 [0,01951 ; 0,04138] | 0 | 9 | 0,00900 [0,00412 ; 0,01702] |
| P1 | CEL4 | FWr (haut) | 1000 | 0 | 37 | 0,03700 [0,02618 ; 0,05064] | 0 | 8 | 0,00800 [0,00346 ; 0,01570] |
| P1 | CEL4 | MinP (bas) | 1000 | 0 | 139 | 0,13900 [0,11815 ; 0,16200] | 0 | 65 | 0,06500 [0,05052 ; 0,08210] |
| P1 | CEL4 | MinP4 (bas) | 1000 | 0 | 183 | 0,18300 [0,15950 ; 0,20839] | 0 | 84 | 0,08400 [0,06755 ; 0,10294] |
| P1 | CEL4 | TMax (haut) | 1000 | 0 | 35 | 0,03500 [0,02450 ; 0,04834] | 0 | 16 | 0,01600 [0,00917 ; 0,02585] |
| P1 | CEL4 | PenteRel (deux) | 1000 | 0 | 144 | 0,14400 [0,12281 ; 0,16731] | 0 | 76 | 0,07600 [0,06034 ; 0,09420] |
| P1 | CEL4 | Rosner, k̂ ≥ 1 (α = 0,10) | 1000 | 0 | 1 | 0,00100 [0,00003 ; 0,00556] | — | — | — |
| P1 | CEL4 | Rosner, k̂ ≥ 1 (α = 0,05) | 1000 | — | — | — | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P1 | CEL6 | Calendrier (bas) | 1000 | 0 | 97 | 0,09700 [0,07936 ; 0,11705] | 0 | 53 | 0,05300 [0,03995 ; 0,06876] |
| P1 | CEL6 | CorrDev (deux) | 1000 | 0 | 88 | 0,08800 [0,07118 ; 0,10729] | 0 | 39 | 0,03900 [0,02788 ; 0,05293] |
| P1 | CEL6 | BP (haut) | 1000 | 0 | 1 | 0,00100 [0,00003 ; 0,00556] | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P1 | CEL6 | Grubbs (haut) | 1000 | 0 | 372 | 0,37200 [0,34196 ; 0,40280] | 0 | 86 | 0,08600 [0,06936 ; 0,10512] |
| P1 | CEL6 | DW (deux) | 1000 | 0 | 42 | 0,04200 [0,03043 ; 0,05635] | 0 | 17 | 0,01700 [0,00993 ; 0,02708] |
| P1 | CEL6 | Runs (deux) | 1000 | 0 | 38 | 0,03800 [0,02703 ; 0,05179] | 0 | 20 | 0,02000 [0,01226 ; 0,03072] |
| P1 | CEL6 | PenteIntra (deux) | 1000 | 0 | 236 | 0,23600 [0,20999 ; 0,26357] | 0 | 152 | 0,15200 [0,13030 ; 0,17577] |
| P1 | CEL6 | Origine (haut) | 1000 | 0 | 60 | 0,06000 [0,04610 ; 0,07656] | 0 | 26 | 0,02600 [0,01705 ; 0,03787] |
| P1 | CEL6 | HomogF (haut) | 1000 | 0 | 59 | 0,05900 [0,04521 ; 0,07545] | 0 | 29 | 0,02900 [0,01951 ; 0,04138] |
| P1 | CEL6 | Courbure (haut) | 1000 | 0 | 75 | 0,07500 [0,05945 ; 0,09311] | 0 | 34 | 0,03400 [0,02366 ; 0,04719] |
| P1 | CEL6 | Alpha (haut) | 1000 | 0 | 3 | 0,00300 [0,00062 ; 0,00874] | 0 | 1 | 0,00100 [0,00003 ; 0,00556] |
| P1 | CEL6 | ExpVar (haut) | 1000 | 0 | 72 | 0,07200 [0,05676 ; 0,08982] | 0 | 24 | 0,02400 [0,01544 ; 0,03550] |
| P1 | CEL6 | KruskalAcc (haut) | 1000 | 0 | 24 | 0,02400 [0,01544 ; 0,03550] | 0 | 9 | 0,00900 [0,00412 ; 0,01702] |
| P1 | CEL6 | FWb (haut) | 1000 | 0 | 28 | 0,02800 [0,01868 ; 0,04021] | 0 | 6 | 0,00600 [0,00220 ; 0,01301] |
| P1 | CEL6 | FWr (haut) | 1000 | 0 | 36 | 0,03600 [0,02534 ; 0,04949] | 0 | 10 | 0,01000 [0,00481 ; 0,01831] |
| P1 | CEL6 | MinP (bas) | 1000 | 0 | 349 | 0,34900 [0,31944 ; 0,37945] | 0 | 180 | 0,18000 [0,15666 ; 0,20524] |
| P1 | CEL6 | MinP4 (bas) | 1000 | 0 | 426 | 0,42600 [0,39511 ; 0,45733] | 0 | 225 | 0,22500 [0,19946 ; 0,25217] |
| P1 | CEL6 | TMax (haut) | 1000 | 0 | 37 | 0,03700 [0,02618 ; 0,05064] | 0 | 16 | 0,01600 [0,00917 ; 0,02585] |
| P1 | CEL6 | PenteRel (deux) | 1000 | 0 | 200 | 0,20000 [0,17562 ; 0,22616] | 0 | 117 | 0,11700 [0,09773 ; 0,13856] |
| P1 | CEL6 | Rosner, k̂ ≥ 1 (α = 0,10) | 1000 | 0 | 2 | 0,00200 [0,00024 ; 0,00721] | — | — | — |
| P1 | CEL6 | Rosner, k̂ ≥ 1 (α = 0,05) | 1000 | — | — | — | 0 | 1 | 0,00100 [0,00003 ; 0,00556] |
| P1 | CST10 | Calendrier (bas) | 500 | 0 | 86 | 0,17200 [0,13994 ; 0,20799] | 0 | 39 | 0,07800 [0,05605 ; 0,10509] |
| P1 | CST10 | CorrDev (deux) | 500 | 0 | 42 | 0,08400 [0,06121 ; 0,11185] | 0 | 20 | 0,04000 [0,02460 ; 0,06110] |
| P1 | CST10 | BP (haut) | 500 | 0 | 4 | 0,00800 [0,00218 ; 0,02036] | 0 | 1 | 0,00200 [0,00005 ; 0,01109] |
| P1 | CST10 | Grubbs (haut) | 500 | 0 | 55 | 0,11000 [0,08395 ; 0,14077] | 0 | 30 | 0,06000 [0,04084 ; 0,08455] |
| P1 | CST10 | DW (deux) | 500 | 0 | 48 | 0,09600 [0,07163 ; 0,12526] | 0 | 22 | 0,04400 [0,02778 ; 0,06586] |
| P1 | CST10 | Runs (deux) | 500 | 0 | 32 | 0,06400 [0,04418 ; 0,08915] | 0 | 13 | 0,02600 [0,01391 ; 0,04405] |
| P1 | CST10 | PenteIntra (deux) | 500 | 0 | 165 | 0,33000 [0,28890 ; 0,37313] | 0 | 113 | 0,22600 [0,19005 ; 0,26522] |
| P1 | CST10 | Origine (haut) | 500 | 0 | 136 | 0,27200 [0,23344 ; 0,31328] | 0 | 83 | 0,16600 [0,13444 ; 0,20157] |
| P1 | CST10 | HomogF (haut) | 500 | 0 | 132 | 0,26400 [0,22586 ; 0,30496] | 0 | 71 | 0,14200 [0,11260 ; 0,17571] |
| P1 | CST10 | Courbure (haut) | 500 | 0 | 46 | 0,09200 [0,06814 ; 0,12081] | 0 | 26 | 0,05200 [0,03425 ; 0,07527] |
| P1 | CST10 | Alpha (haut) | 500 | 0 | 84 | 0,16800 [0,13627 ; 0,20371] | 0 | 22 | 0,04400 [0,02778 ; 0,06586] |
| P1 | CST10 | ExpVar (haut) | 500 | 0 | 38 | 0,07600 [0,05434 ; 0,10283] | 0 | 20 | 0,04000 [0,02460 ; 0,06110] |
| P1 | CST10 | KruskalAcc (haut) | 500 | 0 | 41 | 0,08200 [0,05949 ; 0,10960] | 0 | 23 | 0,04600 [0,02938 ; 0,06823] |
| P1 | CST10 | FWb (haut) | 500 | 0 | 49 | 0,09800 [0,07338 ; 0,12749] | 0 | 19 | 0,03800 [0,02303 ; 0,05871] |
| P1 | CST10 | FWr (haut) | 500 | 0 | 46 | 0,09200 [0,06814 ; 0,12081] | 0 | 19 | 0,03800 [0,02303 ; 0,05871] |
| P1 | CST10 | MinP (bas) | 500 | 0 | 31 | 0,06200 [0,04251 ; 0,08685] | 0 | 8 | 0,01600 [0,00693 ; 0,03128] |
| P1 | CST10 | MinP4 (bas) | 500 | 0 | 40 | 0,08000 [0,05777 ; 0,10735] | 0 | 11 | 0,02200 [0,01103 ; 0,03902] |
| P1 | CST10 | TMax (haut) | 500 | 0 | 17 | 0,03400 [0,01993 ; 0,05388] | 0 | 7 | 0,01400 [0,00565 ; 0,02863] |
| P1 | CST10 | PenteRel (deux) | 500 | 0 | 217 | 0,43400 [0,39006 ; 0,47873] | 0 | 169 | 0,33800 [0,29660 ; 0,38133] |
| P1 | CST10 | Rosner, k̂ ≥ 1 (α = 0,10) | 500 | 0 | 0 | 0,00000 [0,00000 ; 0,00735] | — | — | — |
| P1 | CST10 | Rosner, k̂ ≥ 1 (α = 0,05) | 500 | — | — | — | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |
| P1 | EXP0 | Calendrier (bas) | 500 | 0 | 44 | 0,08800 [0,06467 ; 0,11634] | 0 | 21 | 0,04200 [0,02618 ; 0,06349] |
| P1 | EXP0 | CorrDev (deux) | 500 | 0 | 58 | 0,11600 [0,08927 ; 0,14737] | 0 | 28 | 0,05600 [0,03753 ; 0,07992] |
| P1 | EXP0 | BP (haut) | 500 | 0 | 10 | 0,02000 [0,00963 ; 0,03647] | 0 | 3 | 0,00600 [0,00124 ; 0,01743] |
| P1 | EXP0 | Grubbs (haut) | 500 | 0 | 44 | 0,08800 [0,06467 ; 0,11634] | 0 | 28 | 0,05600 [0,03753 ; 0,07992] |
| P1 | EXP0 | DW (deux) | 500 | 0 | 52 | 0,10400 [0,07865 ; 0,13414] | 0 | 24 | 0,04800 [0,03099 ; 0,07058] |
| P1 | EXP0 | Runs (deux) | 500 | 0 | 27 | 0,05400 [0,03588 ; 0,07760] | 0 | 14 | 0,02800 [0,01539 ; 0,04653] |
| P1 | EXP0 | PenteIntra (deux) | 500 | 0 | 58 | 0,11600 [0,08927 ; 0,14737] | 0 | 32 | 0,06400 [0,04418 ; 0,08915] |
| P1 | EXP0 | Origine (haut) | 500 | 0 | 48 | 0,09600 [0,07163 ; 0,12526] | 0 | 21 | 0,04200 [0,02618 ; 0,06349] |
| P1 | EXP0 | HomogF (haut) | 500 | 0 | 53 | 0,10600 [0,08041 ; 0,13635] | 0 | 27 | 0,05400 [0,03588 ; 0,07760] |
| P1 | EXP0 | Courbure (haut) | 500 | 0 | 39 | 0,07800 [0,05605 ; 0,10509] | 0 | 19 | 0,03800 [0,02303 ; 0,05871] |
| P1 | EXP0 | Alpha (haut) | 500 | 0 | 58 | 0,11600 [0,08927 ; 0,14737] | 0 | 22 | 0,04400 [0,02778 ; 0,06586] |
| P1 | EXP0 | ExpVar (haut) | 500 | 0 | 46 | 0,09200 [0,06814 ; 0,12081] | 0 | 21 | 0,04200 [0,02618 ; 0,06349] |
| P1 | EXP0 | KruskalAcc (haut) | 500 | 0 | 46 | 0,09200 [0,06814 ; 0,12081] | 0 | 26 | 0,05200 [0,03425 ; 0,07527] |
| P1 | EXP0 | FWb (haut) | 500 | 0 | 32 | 0,06400 [0,04418 ; 0,08915] | 0 | 12 | 0,02400 [0,01246 ; 0,04155] |
| P1 | EXP0 | FWr (haut) | 500 | 0 | 35 | 0,07000 [0,04924 ; 0,09601] | 0 | 11 | 0,02200 [0,01103 ; 0,03902] |
| P1 | EXP0 | MinP (bas) | 500 | 0 | 24 | 0,04800 [0,03099 ; 0,07058] | 0 | 7 | 0,01400 [0,00565 ; 0,02863] |
| P1 | EXP0 | MinP4 (bas) | 500 | 0 | 33 | 0,06600 [0,04586 ; 0,09144] | 0 | 13 | 0,02600 [0,01391 ; 0,04405] |
| P1 | EXP0 | TMax (haut) | 500 | 0 | 27 | 0,05400 [0,03588 ; 0,07760] | 0 | 9 | 0,01800 [0,00826 ; 0,03389] |
| P1 | EXP0 | PenteRel (deux) | 500 | 0 | 58 | 0,11600 [0,08927 ; 0,14737] | 0 | 32 | 0,06400 [0,04418 ; 0,08915] |
| P1 | EXP0 | Rosner, k̂ ≥ 1 (α = 0,10) | 500 | 0 | 0 | 0,00000 [0,00000 ; 0,00735] | — | — | — |
| P1 | EXP0 | Rosner, k̂ ≥ 1 (α = 0,05) | 500 | — | — | — | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |
| P1 | DFI | Calendrier (bas) | 500 | 0 | 63 | 0,12600 [0,09820 ; 0,15831] | 0 | 29 | 0,05800 [0,03918 ; 0,08224] |
| P1 | DFI | CorrDev (deux) | 500 | 0 | 66 | 0,13200 [0,10358 ; 0,16485] | 0 | 34 | 0,06800 [0,04755 ; 0,09373] |
| P1 | DFI | BP (haut) | 500 | 0 | 11 | 0,02200 [0,01103 ; 0,03902] | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |
| P1 | DFI | Grubbs (haut) | 500 | 0 | 36 | 0,07200 [0,05093 ; 0,09829] | 0 | 8 | 0,01600 [0,00693 ; 0,03128] |
| P1 | DFI | DW (deux) | 500 | 0 | 52 | 0,10400 [0,07865 ; 0,13414] | 0 | 31 | 0,06200 [0,04251 ; 0,08685] |
| P1 | DFI | Runs (deux) | 500 | 0 | 25 | 0,05000 [0,03262 ; 0,07293] | 0 | 12 | 0,02400 [0,01246 ; 0,04155] |
| P1 | DFI | PenteIntra (deux) | 500 | 0 | 89 | 0,17800 [0,14546 ; 0,21440] | 0 | 56 | 0,11200 [0,08572 ; 0,14297] |
| P1 | DFI | Origine (haut) | 500 | 0 | 98 | 0,19600 [0,16209 ; 0,23355] | 0 | 45 | 0,09000 [0,06640 ; 0,11857] |
| P1 | DFI | HomogF (haut) | 500 | 0 | 107 | 0,21400 [0,17883 ; 0,25259] | 0 | 62 | 0,12400 [0,09641 ; 0,15613] |
| P1 | DFI | Courbure (haut) | 500 | 0 | 52 | 0,10400 [0,07865 ; 0,13414] | 0 | 22 | 0,04400 [0,02778 ; 0,06586] |
| P1 | DFI | Alpha (haut) | 500 | 0 | 174 | 0,34800 [0,30625 ; 0,39156] | 0 | 100 | 0,20000 [0,16580 ; 0,23779] |
| P1 | DFI | ExpVar (haut) | 500 | 0 | 37 | 0,07400 [0,05264 ; 0,10056] | 0 | 15 | 0,03000 [0,01689 ; 0,04900] |
| P1 | DFI | KruskalAcc (haut) | 500 | 0 | 83 | 0,16600 [0,13444 ; 0,20157] | 0 | 41 | 0,08200 [0,05949 ; 0,10960] |
| P1 | DFI | FWb (haut) | 500 | 0 | 42 | 0,08400 [0,06121 ; 0,11185] | 0 | 19 | 0,03800 [0,02303 ; 0,05871] |
| P1 | DFI | FWr (haut) | 500 | 0 | 43 | 0,08600 [0,06294 ; 0,11409] | 0 | 18 | 0,03600 [0,02147 ; 0,05630] |
| P1 | DFI | MinP (bas) | 500 | 0 | 25 | 0,05000 [0,03262 ; 0,07293] | 0 | 10 | 0,02000 [0,00963 ; 0,03647] |
| P1 | DFI | MinP4 (bas) | 500 | 0 | 28 | 0,05600 [0,03753 ; 0,07992] | 0 | 11 | 0,02200 [0,01103 ; 0,03902] |
| P1 | DFI | TMax (haut) | 500 | 0 | 26 | 0,05200 [0,03425 ; 0,07527] | 0 | 9 | 0,01800 [0,00826 ; 0,03389] |
| P1 | DFI | PenteRel (deux) | 500 | 0 | 135 | 0,27000 [0,23154 ; 0,31120] | 0 | 92 | 0,18400 [0,15099 ; 0,22080] |
| P1 | DFI | Rosner, k̂ ≥ 1 (α = 0,10) | 500 | 0 | 0 | 0,00000 [0,00000 ; 0,00735] | — | — | — |
| P1 | DFI | Rosner, k̂ ≥ 1 (α = 0,05) | 500 | — | — | — | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |
| P1 | CAL7 | Calendrier (bas) | 500 | 0 | 190 | 0,38000 [0,33727 ; 0,42415] | 0 | 97 | 0,19400 [0,16024 ; 0,23143] |
| P1 | CAL7 | CorrDev (deux) | 500 | 0 | 52 | 0,10400 [0,07865 ; 0,13414] | 0 | 21 | 0,04200 [0,02618 ; 0,06349] |
| P1 | CAL7 | BP (haut) | 500 | 0 | 1 | 0,00200 [0,00005 ; 0,01109] | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |
| P1 | CAL7 | Grubbs (haut) | 500 | 0 | 305 | 0,61000 [0,56570 ; 0,65299] | 0 | 209 | 0,41800 [0,37436 ; 0,46261] |
| P1 | CAL7 | DW (deux) | 500 | 0 | 34 | 0,06800 [0,04755 ; 0,09373] | 0 | 13 | 0,02600 [0,01391 ; 0,04405] |
| P1 | CAL7 | Runs (deux) | 500 | 0 | 23 | 0,04600 [0,02938 ; 0,06823] | 0 | 12 | 0,02400 [0,01246 ; 0,04155] |
| P1 | CAL7 | PenteIntra (deux) | 500 | 0 | 165 | 0,33000 [0,28890 ; 0,37313] | 0 | 123 | 0,24600 [0,20885 ; 0,28619] |
| P1 | CAL7 | Origine (haut) | 500 | 0 | 111 | 0,22200 [0,18631 ; 0,26102] | 0 | 63 | 0,12600 [0,09820 ; 0,15831] |
| P1 | CAL7 | HomogF (haut) | 500 | 0 | 99 | 0,19800 [0,16394 ; 0,23567] | 0 | 63 | 0,12600 [0,09820 ; 0,15831] |
| P1 | CAL7 | Courbure (haut) | 500 | 0 | 148 | 0,29600 [0,25630 ; 0,33814] | 0 | 89 | 0,17800 [0,14546 ; 0,21440] |
| P1 | CAL7 | Alpha (haut) | 500 | 0 | 152 | 0,30400 [0,26394 ; 0,34639] | 0 | 79 | 0,15800 [0,12713 ; 0,19298] |
| P1 | CAL7 | ExpVar (haut) | 500 | 0 | 80 | 0,16000 [0,12896 ; 0,19513] | 0 | 49 | 0,09800 [0,07338 ; 0,12749] |
| P1 | CAL7 | KruskalAcc (haut) | 500 | 0 | 46 | 0,09200 [0,06814 ; 0,12081] | 0 | 22 | 0,04400 [0,02778 ; 0,06586] |
| P1 | CAL7 | FWb (haut) | 500 | 0 | 182 | 0,36400 [0,32174 ; 0,40788] | 0 | 108 | 0,21600 [0,18070 ; 0,25470] |
| P1 | CAL7 | FWr (haut) | 500 | 0 | 182 | 0,36400 [0,32174 ; 0,40788] | 0 | 116 | 0,23200 [0,19568 ; 0,27152] |
| P1 | CAL7 | MinP (bas) | 500 | 0 | 156 | 0,31200 [0,27161 ; 0,35463] | 0 | 75 | 0,15000 [0,11985 ; 0,18436] |
| P1 | CAL7 | MinP4 (bas) | 500 | 0 | 183 | 0,36600 [0,32368 ; 0,40992] | 0 | 90 | 0,18000 [0,14730 ; 0,21654] |
| P1 | CAL7 | TMax (haut) | 500 | 0 | 22 | 0,04400 [0,02778 ; 0,06586] | 0 | 6 | 0,01200 [0,00442 ; 0,02593] |
| P1 | CAL7 | PenteRel (deux) | 500 | 0 | 258 | 0,51600 [0,47121 ; 0,56060] | 0 | 209 | 0,41800 [0,37436 ; 0,46261] |
| P1 | CAL7 | Rosner, k̂ ≥ 1 (α = 0,10) | 500 | 0 | 12 | 0,02400 [0,01246 ; 0,04155] | — | — | — |
| P1 | CAL7 | Rosner, k̂ ≥ 1 (α = 0,05) | 500 | — | — | — | 0 | 4 | 0,00800 [0,00218 ; 0,02036] |
| P1 | CAL4 | Calendrier (bas) | 500 | 0 | 172 | 0,34400 [0,30239 ; 0,38747] | 0 | 88 | 0,17600 [0,14362 ; 0,21227] |
| P1 | CAL4 | CorrDev (deux) | 500 | 0 | 25 | 0,05000 [0,03262 ; 0,07293] | 0 | 10 | 0,02000 [0,00963 ; 0,03647] |
| P1 | CAL4 | BP (haut) | 500 | 0 | 0 | 0,00000 [0,00000 ; 0,00735] | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |
| P1 | CAL4 | Grubbs (haut) | 500 | 0 | 41 | 0,08200 [0,05949 ; 0,10960] | 0 | 21 | 0,04200 [0,02618 ; 0,06349] |
| P1 | CAL4 | DW (deux) | 500 | 0 | 61 | 0,12200 [0,09462 ; 0,15394] | 0 | 28 | 0,05600 [0,03753 ; 0,07992] |
| P1 | CAL4 | Runs (deux) | 500 | 0 | 23 | 0,04600 [0,02938 ; 0,06823] | 0 | 15 | 0,03000 [0,01689 ; 0,04900] |
| P1 | CAL4 | PenteIntra (deux) | 500 | 0 | 116 | 0,23200 [0,19568 ; 0,27152] | 0 | 75 | 0,15000 [0,11985 ; 0,18436] |
| P1 | CAL4 | Origine (haut) | 500 | 0 | 50 | 0,10000 [0,07514 ; 0,12971] | 0 | 25 | 0,05000 [0,03262 ; 0,07293] |
| P1 | CAL4 | HomogF (haut) | 500 | 0 | 13 | 0,02600 [0,01391 ; 0,04405] | 0 | 3 | 0,00600 [0,00124 ; 0,01743] |
| P1 | CAL4 | Courbure (haut) | 500 | 0 | 152 | 0,30400 [0,26394 ; 0,34639] | 0 | 79 | 0,15800 [0,12713 ; 0,19298] |
| P1 | CAL4 | Alpha (haut) | 500 | 0 | 1 | 0,00200 [0,00005 ; 0,01109] | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |
| P1 | CAL4 | ExpVar (haut) | 500 | 0 | 33 | 0,06600 [0,04586 ; 0,09144] | 0 | 14 | 0,02800 [0,01539 ; 0,04653] |
| P1 | CAL4 | KruskalAcc (haut) | 500 | 0 | 13 | 0,02600 [0,01391 ; 0,04405] | 0 | 3 | 0,00600 [0,00124 ; 0,01743] |
| P1 | CAL4 | FWb (haut) | 500 | 0 | 7 | 0,01400 [0,00565 ; 0,02863] | 0 | 1 | 0,00200 [0,00005 ; 0,01109] |
| P1 | CAL4 | FWr (haut) | 500 | 0 | 11 | 0,02200 [0,01103 ; 0,03902] | 0 | 1 | 0,00200 [0,00005 ; 0,01109] |
| P1 | CAL4 | MinP (bas) | 500 | 0 | 28 | 0,05600 [0,03753 ; 0,07992] | 0 | 7 | 0,01400 [0,00565 ; 0,02863] |
| P1 | CAL4 | MinP4 (bas) | 500 | 0 | 36 | 0,07200 [0,05093 ; 0,09829] | 0 | 9 | 0,01800 [0,00826 ; 0,03389] |
| P1 | CAL4 | TMax (haut) | 500 | 0 | 17 | 0,03400 [0,01993 ; 0,05388] | 0 | 7 | 0,01400 [0,00565 ; 0,02863] |
| P1 | CAL4 | PenteRel (deux) | 500 | 0 | 170 | 0,34000 [0,29853 ; 0,38337] | 0 | 131 | 0,26200 [0,22396 ; 0,30288] |
| P1 | CAL4 | Rosner, k̂ ≥ 1 (α = 0,10) | 500 | 0 | 0 | 0,00000 [0,00000 ; 0,00735] | — | — | — |
| P1 | CAL4 | Rosner, k̂ ≥ 1 (α = 0,05) | 500 | — | — | — | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |
| P1 | DCAL | Calendrier (bas) | 500 | 0 | 108 | 0,21600 [0,18070 ; 0,25470] | 0 | 50 | 0,10000 [0,07514 ; 0,12971] |
| P1 | DCAL | CorrDev (deux) | 500 | 0 | 131 | 0,26200 [0,22396 ; 0,30288] | 0 | 83 | 0,16600 [0,13444 ; 0,20157] |
| P1 | DCAL | BP (haut) | 500 | 0 | 42 | 0,08400 [0,06121 ; 0,11185] | 0 | 18 | 0,03600 [0,02147 ; 0,05630] |
| P1 | DCAL | Grubbs (haut) | 500 | 0 | 26 | 0,05200 [0,03425 ; 0,07527] | 0 | 9 | 0,01800 [0,00826 ; 0,03389] |
| P1 | DCAL | DW (deux) | 500 | 0 | 102 | 0,20400 [0,16952 ; 0,24203] | 0 | 55 | 0,11000 [0,08395 ; 0,14077] |
| P1 | DCAL | Runs (deux) | 500 | 0 | 63 | 0,12600 [0,09820 ; 0,15831] | 0 | 24 | 0,04800 [0,03099 ; 0,07058] |
| P1 | DCAL | PenteIntra (deux) | 500 | 0 | 146 | 0,29200 [0,25248 ; 0,33400] | 0 | 110 | 0,22000 [0,18444 ; 0,25891] |
| P1 | DCAL | Origine (haut) | 500 | 0 | 218 | 0,43600 [0,39202 ; 0,48074] | 0 | 140 | 0,28000 [0,24104 ; 0,32158] |
| P1 | DCAL | HomogF (haut) | 500 | 0 | 275 | 0,55000 [0,50521 ; 0,59420] | 0 | 195 | 0,39000 [0,34701 ; 0,43430] |
| P1 | DCAL | Courbure (haut) | 500 | 0 | 74 | 0,14800 [0,11803 ; 0,18220] | 0 | 34 | 0,06800 [0,04755 ; 0,09373] |
| P1 | DCAL | Alpha (haut) | 500 | 0 | 359 | 0,71800 [0,67635 ; 0,75705] | 0 | 268 | 0,53600 [0,49118 ; 0,58039] |
| P1 | DCAL | ExpVar (haut) | 500 | 0 | 22 | 0,04400 [0,02778 ; 0,06586] | 0 | 9 | 0,01800 [0,00826 ; 0,03389] |
| P1 | DCAL | KruskalAcc (haut) | 500 | 0 | 175 | 0,35000 [0,30819 ; 0,39360] | 0 | 100 | 0,20000 [0,16580 ; 0,23779] |
| P1 | DCAL | FWb (haut) | 500 | 0 | 45 | 0,09000 [0,06640 ; 0,11857] | 0 | 23 | 0,04600 [0,02938 ; 0,06823] |
| P1 | DCAL | FWr (haut) | 500 | 0 | 41 | 0,08200 [0,05949 ; 0,10960] | 0 | 20 | 0,04000 [0,02460 ; 0,06110] |
| P1 | DCAL | MinP (bas) | 500 | 0 | 13 | 0,02600 [0,01391 ; 0,04405] | 0 | 3 | 0,00600 [0,00124 ; 0,01743] |
| P1 | DCAL | MinP4 (bas) | 500 | 0 | 20 | 0,04000 [0,02460 ; 0,06110] | 0 | 3 | 0,00600 [0,00124 ; 0,01743] |
| P1 | DCAL | TMax (haut) | 500 | 0 | 21 | 0,04200 [0,02618 ; 0,06349] | 0 | 10 | 0,02000 [0,00963 ; 0,03647] |
| P1 | DCAL | PenteRel (deux) | 500 | 0 | 255 | 0,51000 [0,46523 ; 0,55465] | 0 | 200 | 0,40000 [0,35676 ; 0,44443] |
| P1 | DCAL | Rosner, k̂ ≥ 1 (α = 0,10) | 500 | 0 | 0 | 0,00000 [0,00000 ; 0,00735] | — | — | — |
| P1 | DCAL | Rosner, k̂ ≥ 1 (α = 0,05) | 500 | — | — | — | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |
| P1 | LIG | Calendrier (bas) | 500 | 0 | 20 | 0,04000 [0,02460 ; 0,06110] | 0 | 3 | 0,00600 [0,00124 ; 0,01743] |
| P1 | LIG | CorrDev (deux) | 500 | 0 | 139 | 0,27800 [0,23914 ; 0,31951] | 0 | 90 | 0,18000 [0,14730 ; 0,21654] |
| P1 | LIG | BP (haut) | 500 | 0 | 0 | 0,00000 [0,00000 ; 0,00735] | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |
| P1 | LIG | Grubbs (haut) | 500 | 0 | 203 | 0,40600 [0,36262 ; 0,45050] | 0 | 35 | 0,07000 [0,04924 ; 0,09601] |
| P1 | LIG | DW (deux) | 500 | 0 | 10 | 0,02000 [0,00963 ; 0,03647] | 0 | 2 | 0,00400 [0,00048 ; 0,01437] |
| P1 | LIG | Runs (deux) | 500 | 0 | 25 | 0,05000 [0,03262 ; 0,07293] | 0 | 16 | 0,03200 [0,01840 ; 0,05145] |
| P1 | LIG | PenteIntra (deux) | 500 | 0 | 306 | 0,61200 [0,56773 ; 0,65494] | 0 | 240 | 0,48000 [0,43544 ; 0,52480] |
| P1 | LIG | Origine (haut) | 500 | 0 | 156 | 0,31200 [0,27161 ; 0,35463] | 0 | 91 | 0,18200 [0,14914 ; 0,21867] |
| P1 | LIG | HomogF (haut) | 500 | 0 | 17 | 0,03400 [0,01993 ; 0,05388] | 0 | 7 | 0,01400 [0,00565 ; 0,02863] |
| P1 | LIG | Courbure (haut) | 500 | 0 | 89 | 0,17800 [0,14546 ; 0,21440] | 0 | 44 | 0,08800 [0,06467 ; 0,11634] |
| P1 | LIG | Alpha (haut) | 500 | 0 | 37 | 0,07400 [0,05264 ; 0,10056] | 0 | 3 | 0,00600 [0,00124 ; 0,01743] |
| P1 | LIG | ExpVar (haut) | 500 | 0 | 37 | 0,07400 [0,05264 ; 0,10056] | 0 | 16 | 0,03200 [0,01840 ; 0,05145] |
| P1 | LIG | KruskalAcc (haut) | 500 | 0 | 295 | 0,59000 [0,54546 ; 0,63347] | 0 | 218 | 0,43600 [0,39202 ; 0,48074] |
| P1 | LIG | FWb (haut) | 500 | 0 | 88 | 0,17600 [0,14362 ; 0,21227] | 0 | 8 | 0,01600 [0,00693 ; 0,03128] |
| P1 | LIG | FWr (haut) | 500 | 0 | 141 | 0,28200 [0,24295 ; 0,32365] | 0 | 43 | 0,08600 [0,06294 ; 0,11409] |
| P1 | LIG | MinP (bas) | 500 | 0 | 408 | 0,81600 [0,77920 ; 0,84901] | 0 | 305 | 0,61000 [0,56570 ; 0,65299] |
| P1 | LIG | MinP4 (bas) | 500 | 0 | 418 | 0,83600 [0,80058 ; 0,86739] | 0 | 321 | 0,64200 [0,59824 ; 0,68407] |
| P1 | LIG | TMax (haut) | 500 | 0 | 23 | 0,04600 [0,02938 ; 0,06823] | 0 | 8 | 0,01600 [0,00693 ; 0,03128] |
| P1 | LIG | PenteRel (deux) | 500 | 0 | 263 | 0,52600 [0,48119 ; 0,57050] | 0 | 189 | 0,37800 [0,33533 ; 0,42212] |
| P1 | LIG | Rosner, k̂ ≥ 1 (α = 0,10) | 500 | 0 | 30 | 0,06000 [0,04084 ; 0,08455] | — | — | — |
| P1 | LIG | Rosner, k̂ ≥ 1 (α = 0,05) | 500 | — | — | — | 0 | 9 | 0,01800 [0,00826 ; 0,03389] |
| P1 | CELx4 | Calendrier (bas) | 500 | 0 | 34 | 0,06800 [0,04755 ; 0,09373] | 0 | 15 | 0,03000 [0,01689 ; 0,04900] |
| P1 | CELx4 | CorrDev (deux) | 500 | 0 | 18 | 0,03600 [0,02147 ; 0,05630] | 0 | 8 | 0,01600 [0,00693 ; 0,03128] |
| P1 | CELx4 | BP (haut) | 500 | 0 | 0 | 0,00000 [0,00000 ; 0,00735] | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |
| P1 | CELx4 | Grubbs (haut) | 500 | 0 | 316 | 0,63200 [0,58805 ; 0,67438] | 0 | 19 | 0,03800 [0,02303 ; 0,05871] |
| P1 | CELx4 | DW (deux) | 500 | 0 | 2 | 0,00400 [0,00048 ; 0,01437] | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |
| P1 | CELx4 | Runs (deux) | 500 | 0 | 13 | 0,02600 [0,01391 ; 0,04405] | 0 | 3 | 0,00600 [0,00124 ; 0,01743] |
| P1 | CELx4 | PenteIntra (deux) | 500 | 0 | 469 | 0,93800 [0,91315 ; 0,95749] | 0 | 463 | 0,92600 [0,89944 ; 0,94736] |
| P1 | CELx4 | Origine (haut) | 500 | 0 | 499 | 0,99800 [0,98891 ; 0,99995] | 0 | 489 | 0,97800 [0,96098 ; 0,98897] |
| P1 | CELx4 | HomogF (haut) | 500 | 0 | 12 | 0,02400 [0,01246 ; 0,04155] | 0 | 3 | 0,00600 [0,00124 ; 0,01743] |
| P1 | CELx4 | Courbure (haut) | 500 | 0 | 98 | 0,19600 [0,16209 ; 0,23355] | 0 | 44 | 0,08800 [0,06467 ; 0,11634] |
| P1 | CELx4 | Alpha (haut) | 500 | 0 | 0 | 0,00000 [0,00000 ; 0,00735] | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |
| P1 | CELx4 | ExpVar (haut) | 500 | 0 | 71 | 0,14200 [0,11260 ; 0,17571] | 0 | 34 | 0,06800 [0,04755 ; 0,09373] |
| P1 | CELx4 | KruskalAcc (haut) | 500 | 0 | 2 | 0,00400 [0,00048 ; 0,01437] | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |
| P1 | CELx4 | FWb (haut) | 500 | 0 | 462 | 0,92400 [0,89717 ; 0,94566] | 0 | 132 | 0,26400 [0,22586 ; 0,30496] |
| P1 | CELx4 | FWr (haut) | 500 | 0 | 500 | 1,00000 [0,99265 ; 1,00000] | 0 | 500 | 1,00000 [0,99265 ; 1,00000] |
| P1 | CELx4 | MinP (bas) | 500 | 0 | 500 | 1,00000 [0,99265 ; 1,00000] | 0 | 500 | 1,00000 [0,99265 ; 1,00000] |
| P1 | CELx4 | MinP4 (bas) | 500 | 0 | 500 | 1,00000 [0,99265 ; 1,00000] | 0 | 500 | 1,00000 [0,99265 ; 1,00000] |
| P1 | CELx4 | TMax (haut) | 500 | 0 | 500 | 1,00000 [0,99265 ; 1,00000] | 0 | 353 | 0,70600 [0,66393 ; 0,74561] |
| P1 | CELx4 | PenteRel (deux) | 500 | 0 | 460 | 0,92000 [0,89265 ; 0,94223] | 0 | 441 | 0,88200 [0,85044 ; 0,90895] |
| P1 | CELx4 | Rosner, k̂ ≥ 1 (α = 0,10) | 500 | 0 | 0 | 0,00000 [0,00000 ; 0,00735] | — | — | — |
| P1 | CELx4 | Rosner, k̂ ≥ 1 (α = 0,05) | 500 | — | — | — | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |
| P2 | H0 | Calendrier (bas) | 1000 | 0 | 97 | 0,09700 [0,07936 ; 0,11705] | 0 | 39 | 0,03900 [0,02788 ; 0,05293] |
| P2 | H0 | CorrDev (deux) | 1000 | 0 | 119 | 0,11900 [0,09958 ; 0,14070] | 0 | 52 | 0,05200 [0,03908 ; 0,06764] |
| P2 | H0 | BP (haut) | 1000 | 0 | 63 | 0,06300 [0,04875 ; 0,07989] | 0 | 30 | 0,03000 [0,02033 ; 0,04255] |
| P2 | H0 | Grubbs (haut) | 1000 | 0 | 107 | 0,10700 [0,08852 ; 0,12783] | 0 | 54 | 0,05400 [0,04082 ; 0,06987] |
| P2 | H0 | DW (deux) | 1000 | 0 | 84 | 0,08400 [0,06755 ; 0,10294] | 0 | 45 | 0,04500 [0,03301 ; 0,05975] |
| P2 | H0 | Runs (deux) | 1000 | 0 | 47 | 0,04700 [0,03474 ; 0,06201] | 0 | 22 | 0,02200 [0,01384 ; 0,03312] |
| P2 | H0 | PenteIntra (deux) | 1000 | 0 | 116 | 0,11600 [0,09681 ; 0,13749] | 0 | 56 | 0,05600 [0,04258 ; 0,07211] |
| P2 | H0 | Origine (haut) | 1000 | 0 | 96 | 0,09600 [0,07845 ; 0,11597] | 0 | 46 | 0,04600 [0,03387 ; 0,06088] |
| P2 | H0 | HomogF (haut) | 1000 | 0 | 101 | 0,10100 [0,08302 ; 0,12137] | 0 | 49 | 0,04900 [0,03647 ; 0,06427] |
| P2 | H0 | Courbure (haut) | 1000 | 0 | 89 | 0,08900 [0,07208 ; 0,10838] | 0 | 49 | 0,04900 [0,03647 ; 0,06427] |
| P2 | H0 | Alpha (haut) | 1000 | 0 | 95 | 0,09500 [0,07754 ; 0,11488] | 0 | 37 | 0,03700 [0,02618 ; 0,05064] |
| P2 | H0 | ExpVar (haut) | 1000 | 0 | 89 | 0,08900 [0,07208 ; 0,10838] | 0 | 39 | 0,03900 [0,02788 ; 0,05293] |
| P2 | H0 | KruskalAcc (haut) | 1000 | 0 | 99 | 0,09900 [0,08119 ; 0,11921] | 0 | 50 | 0,05000 [0,03734 ; 0,06539] |
| P2 | H0 | FWb (haut) | 1000 | 0 | 97 | 0,09700 [0,07936 ; 0,11705] | 0 | 47 | 0,04700 [0,03474 ; 0,06201] |
| P2 | H0 | FWr (haut) | 1000 | 0 | 94 | 0,09400 [0,07663 ; 0,11380] | 0 | 49 | 0,04900 [0,03647 ; 0,06427] |
| P2 | H0 | MinP (bas) | 1000 | 0 | 72 | 0,07200 [0,05676 ; 0,08982] | 0 | 34 | 0,03400 [0,02366 ; 0,04719] |
| P2 | H0 | MinP4 (bas) | 1000 | 0 | 74 | 0,07400 [0,05855 ; 0,09201] | 0 | 34 | 0,03400 [0,02366 ; 0,04719] |
| P2 | H0 | TMax (haut) | 1000 | 0 | 71 | 0,07100 [0,05586 ; 0,08872] | 0 | 34 | 0,03400 [0,02366 ; 0,04719] |
| P2 | H0 | PenteRel (deux) | 1000 | 0 | 112 | 0,11200 [0,09312 ; 0,13320] | 0 | 59 | 0,05900 [0,04521 ; 0,07545] |
| P2 | H0 | Rosner, k̂ ≥ 1 (α = 0,10) | 1000 | 0 | 1 | 0,00100 [0,00003 ; 0,00556] | — | — | — |
| P2 | H0 | Rosner, k̂ ≥ 1 (α = 0,05) | 1000 | — | — | — | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P2 | CST20 | Calendrier (bas) | 1000 | 0 | 879 | 0,87900 [0,85716 ; 0,89857] | 0 | 782 | 0,78200 [0,75510 ; 0,80723] |
| P2 | CST20 | CorrDev (deux) | 1000 | 0 | 955 | 0,95500 [0,94025 ; 0,96699] | 0 | 905 | 0,90500 [0,88512 ; 0,92246] |
| P2 | CST20 | BP (haut) | 1000 | 0 | 6 | 0,00600 [0,00220 ; 0,01301] | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P2 | CST20 | Grubbs (haut) | 1000 | 0 | 12 | 0,01200 [0,00622 ; 0,02087] | 0 | 1 | 0,00100 [0,00003 ; 0,00556] |
| P2 | CST20 | DW (deux) | 1000 | 0 | 432 | 0,43200 [0,40104 ; 0,46336] | 0 | 174 | 0,17400 [0,15099 ; 0,19895] |
| P2 | CST20 | Runs (deux) | 1000 | 0 | 159 | 0,15900 [0,13687 ; 0,18316] | 0 | 40 | 0,04000 [0,02873 ; 0,05407] |
| P2 | CST20 | PenteIntra (deux) | 1000 | 0 | 932 | 0,93200 [0,91459 ; 0,94681] | 0 | 905 | 0,90500 [0,88512 ; 0,92246] |
| P2 | CST20 | Origine (haut) | 1000 | 0 | 1000 | 1,00000 [0,99632 ; 1,00000] | 0 | 1000 | 1,00000 [0,99632 ; 1,00000] |
| P2 | CST20 | HomogF (haut) | 1000 | 0 | 1000 | 1,00000 [0,99632 ; 1,00000] | 0 | 1000 | 1,00000 [0,99632 ; 1,00000] |
| P2 | CST20 | Courbure (haut) | 1000 | 0 | 96 | 0,09600 [0,07845 ; 0,11597] | 0 | 43 | 0,04300 [0,03129 ; 0,05749] |
| P2 | CST20 | Alpha (haut) | 1000 | 0 | 1000 | 1,00000 [0,99632 ; 1,00000] | 0 | 1000 | 1,00000 [0,99632 ; 1,00000] |
| P2 | CST20 | ExpVar (haut) | 1000 | 0 | 1 | 0,00100 [0,00003 ; 0,00556] | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P2 | CST20 | KruskalAcc (haut) | 1000 | 0 | 999 | 0,99900 [0,99444 ; 0,99997] | 0 | 989 | 0,98900 [0,98040 ; 0,99450] |
| P2 | CST20 | FWb (haut) | 1000 | 0 | 161 | 0,16100 [0,13874 ; 0,18527] | 0 | 67 | 0,06700 [0,05230 ; 0,08431] |
| P2 | CST20 | FWr (haut) | 1000 | 0 | 88 | 0,08800 [0,07118 ; 0,10729] | 0 | 34 | 0,03400 [0,02366 ; 0,04719] |
| P2 | CST20 | MinP (bas) | 1000 | 0 | 21 | 0,02100 [0,01305 ; 0,03192] | 0 | 8 | 0,00800 [0,00346 ; 0,01570] |
| P2 | CST20 | MinP4 (bas) | 1000 | 0 | 18 | 0,01800 [0,01070 ; 0,02830] | 0 | 9 | 0,00900 [0,00412 ; 0,01702] |
| P2 | CST20 | TMax (haut) | 1000 | 0 | 50 | 0,05000 [0,03734 ; 0,06539] | 0 | 18 | 0,01800 [0,01070 ; 0,02830] |
| P2 | CST20 | PenteRel (deux) | 1000 | 0 | 967 | 0,96700 [0,95397 ; 0,97718] | 0 | 963 | 0,96300 [0,94936 ; 0,97382] |
| P2 | CST20 | Rosner, k̂ ≥ 1 (α = 0,10) | 1000 | 0 | 0 | 0,00000 [0,00000 ; 0,00368] | — | — | — |
| P2 | CST20 | Rosner, k̂ ≥ 1 (α = 0,05) | 1000 | — | — | — | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P2 | EXP2 | Calendrier (bas) | 1000 | 0 | 114 | 0,11400 [0,09496 ; 0,13534] | 0 | 53 | 0,05300 [0,03995 ; 0,06876] |
| P2 | EXP2 | CorrDev (deux) | 1000 | 0 | 91 | 0,09100 [0,07390 ; 0,11055] | 0 | 43 | 0,04300 [0,03129 ; 0,05749] |
| P2 | EXP2 | BP (haut) | 1000 | 0 | 29 | 0,02900 [0,01951 ; 0,04138] | 0 | 10 | 0,01000 [0,00481 ; 0,01831] |
| P2 | EXP2 | Grubbs (haut) | 1000 | 0 | 115 | 0,11500 [0,09588 ; 0,13642] | 0 | 46 | 0,04600 [0,03387 ; 0,06088] |
| P2 | EXP2 | DW (deux) | 1000 | 0 | 103 | 0,10300 [0,08485 ; 0,12352] | 0 | 44 | 0,04400 [0,03215 ; 0,05862] |
| P2 | EXP2 | Runs (deux) | 1000 | 0 | 45 | 0,04500 [0,03301 ; 0,05975] | 0 | 30 | 0,03000 [0,02033 ; 0,04255] |
| P2 | EXP2 | PenteIntra (deux) | 1000 | 0 | 129 | 0,12900 [0,10884 ; 0,15137] | 0 | 73 | 0,07300 [0,05765 ; 0,09091] |
| P2 | EXP2 | Origine (haut) | 1000 | 0 | 90 | 0,09000 [0,07299 ; 0,10947] | 0 | 48 | 0,04800 [0,03560 ; 0,06314] |
| P2 | EXP2 | HomogF (haut) | 1000 | 0 | 88 | 0,08800 [0,07118 ; 0,10729] | 0 | 45 | 0,04500 [0,03301 ; 0,05975] |
| P2 | EXP2 | Courbure (haut) | 1000 | 0 | 95 | 0,09500 [0,07754 ; 0,11488] | 0 | 41 | 0,04100 [0,02958 ; 0,05521] |
| P2 | EXP2 | Alpha (haut) | 1000 | 0 | 91 | 0,09100 [0,07390 ; 0,11055] | 0 | 25 | 0,02500 [0,01624 ; 0,03668] |
| P2 | EXP2 | ExpVar (haut) | 1000 | 0 | 91 | 0,09100 [0,07390 ; 0,11055] | 0 | 49 | 0,04900 [0,03647 ; 0,06427] |
| P2 | EXP2 | KruskalAcc (haut) | 1000 | 0 | 115 | 0,11500 [0,09588 ; 0,13642] | 0 | 55 | 0,05500 [0,04170 ; 0,07099] |
| P2 | EXP2 | FWb (haut) | 1000 | 0 | 83 | 0,08300 [0,06665 ; 0,10185] | 0 | 34 | 0,03400 [0,02366 ; 0,04719] |
| P2 | EXP2 | FWr (haut) | 1000 | 0 | 112 | 0,11200 [0,09312 ; 0,13320] | 0 | 47 | 0,04700 [0,03474 ; 0,06201] |
| P2 | EXP2 | MinP (bas) | 1000 | 0 | 76 | 0,07600 [0,06034 ; 0,09420] | 0 | 38 | 0,03800 [0,02703 ; 0,05179] |
| P2 | EXP2 | MinP4 (bas) | 1000 | 0 | 77 | 0,07700 [0,06124 ; 0,09530] | 0 | 35 | 0,03500 [0,02450 ; 0,04834] |
| P2 | EXP2 | TMax (haut) | 1000 | 0 | 72 | 0,07200 [0,05676 ; 0,08982] | 0 | 40 | 0,04000 [0,02873 ; 0,05407] |
| P2 | EXP2 | PenteRel (deux) | 1000 | 0 | 122 | 0,12200 [0,10235 ; 0,14390] | 0 | 62 | 0,06200 [0,04786 ; 0,07878] |
| P2 | EXP2 | Rosner, k̂ ≥ 1 (α = 0,10) | 1000 | 0 | 1 | 0,00100 [0,00003 ; 0,00556] | — | — | — |
| P2 | EXP2 | Rosner, k̂ ≥ 1 (α = 0,05) | 1000 | — | — | — | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P2 | CST10 | Calendrier (bas) | 500 | 0 | 314 | 0,62800 [0,58398 ; 0,67050] | 0 | 210 | 0,42000 [0,37632 ; 0,46463] |
| P2 | CST10 | CorrDev (deux) | 500 | 0 | 374 | 0,74800 [0,70755 ; 0,78549] | 0 | 302 | 0,60400 [0,55962 ; 0,64714] |
| P2 | CST10 | BP (haut) | 500 | 0 | 26 | 0,05200 [0,03425 ; 0,07527] | 0 | 2 | 0,00400 [0,00048 ; 0,01437] |
| P2 | CST10 | Grubbs (haut) | 500 | 0 | 21 | 0,04200 [0,02618 ; 0,06349] | 0 | 10 | 0,02000 [0,00963 ; 0,03647] |
| P2 | CST10 | DW (deux) | 500 | 0 | 113 | 0,22600 [0,19005 ; 0,26522] | 0 | 49 | 0,09800 [0,07338 ; 0,12749] |
| P2 | CST10 | Runs (deux) | 500 | 0 | 43 | 0,08600 [0,06294 ; 0,11409] | 0 | 13 | 0,02600 [0,01391 ; 0,04405] |
| P2 | CST10 | PenteIntra (deux) | 500 | 0 | 431 | 0,86200 [0,82863 ; 0,89102] | 0 | 409 | 0,81800 [0,78133 ; 0,85086] |
| P2 | CST10 | Origine (haut) | 500 | 0 | 500 | 1,00000 [0,99265 ; 1,00000] | 0 | 500 | 1,00000 [0,99265 ; 1,00000] |
| P2 | CST10 | HomogF (haut) | 500 | 0 | 496 | 0,99200 [0,97964 ; 0,99782] | 0 | 484 | 0,96800 [0,94855 ; 0,98160] |
| P2 | CST10 | Courbure (haut) | 500 | 0 | 41 | 0,08200 [0,05949 ; 0,10960] | 0 | 18 | 0,03600 [0,02147 ; 0,05630] |
| P2 | CST10 | Alpha (haut) | 500 | 0 | 499 | 0,99800 [0,98891 ; 0,99995] | 0 | 495 | 0,99000 [0,97682 ; 0,99675] |
| P2 | CST10 | ExpVar (haut) | 500 | 0 | 7 | 0,01400 [0,00565 ; 0,02863] | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |
| P2 | CST10 | KruskalAcc (haut) | 500 | 0 | 472 | 0,94400 [0,92008 ; 0,96247] | 0 | 414 | 0,82800 [0,79201 ; 0,86006] |
| P2 | CST10 | FWb (haut) | 500 | 0 | 81 | 0,16200 [0,13078 ; 0,19728] | 0 | 40 | 0,08000 [0,05777 ; 0,10735] |
| P2 | CST10 | FWr (haut) | 500 | 0 | 56 | 0,11200 [0,08572 ; 0,14297] | 0 | 22 | 0,04400 [0,02778 ; 0,06586] |
| P2 | CST10 | MinP (bas) | 500 | 0 | 14 | 0,02800 [0,01539 ; 0,04653] | 0 | 6 | 0,01200 [0,00442 ; 0,02593] |
| P2 | CST10 | MinP4 (bas) | 500 | 0 | 17 | 0,03400 [0,01993 ; 0,05388] | 0 | 8 | 0,01600 [0,00693 ; 0,03128] |
| P2 | CST10 | TMax (haut) | 500 | 0 | 21 | 0,04200 [0,02618 ; 0,06349] | 0 | 12 | 0,02400 [0,01246 ; 0,04155] |
| P2 | CST10 | PenteRel (deux) | 500 | 0 | 472 | 0,94400 [0,92008 ; 0,96247] | 0 | 467 | 0,93400 [0,90856 ; 0,95414] |
| P2 | CST10 | Rosner, k̂ ≥ 1 (α = 0,10) | 500 | 0 | 1 | 0,00200 [0,00005 ; 0,01109] | — | — | — |
| P2 | CST10 | Rosner, k̂ ≥ 1 (α = 0,05) | 500 | — | — | — | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |
| P2 | EXP0 | Calendrier (bas) | 500 | 0 | 47 | 0,09400 [0,06989 ; 0,12304] | 0 | 19 | 0,03800 [0,02303 ; 0,05871] |
| P2 | EXP0 | CorrDev (deux) | 500 | 0 | 50 | 0,10000 [0,07514 ; 0,12971] | 0 | 28 | 0,05600 [0,03753 ; 0,07992] |
| P2 | EXP0 | BP (haut) | 500 | 0 | 77 | 0,15400 [0,12349 ; 0,18867] | 0 | 32 | 0,06400 [0,04418 ; 0,08915] |
| P2 | EXP0 | Grubbs (haut) | 500 | 0 | 58 | 0,11600 [0,08927 ; 0,14737] | 0 | 27 | 0,05400 [0,03588 ; 0,07760] |
| P2 | EXP0 | DW (deux) | 500 | 0 | 56 | 0,11200 [0,08572 ; 0,14297] | 0 | 24 | 0,04800 [0,03099 ; 0,07058] |
| P2 | EXP0 | Runs (deux) | 500 | 0 | 37 | 0,07400 [0,05264 ; 0,10056] | 0 | 13 | 0,02600 [0,01391 ; 0,04405] |
| P2 | EXP0 | PenteIntra (deux) | 500 | 0 | 57 | 0,11400 [0,08749 ; 0,14517] | 0 | 29 | 0,05800 [0,03918 ; 0,08224] |
| P2 | EXP0 | Origine (haut) | 500 | 0 | 74 | 0,14800 [0,11803 ; 0,18220] | 0 | 39 | 0,07800 [0,05605 ; 0,10509] |
| P2 | EXP0 | HomogF (haut) | 500 | 0 | 50 | 0,10000 [0,07514 ; 0,12971] | 0 | 30 | 0,06000 [0,04084 ; 0,08455] |
| P2 | EXP0 | Courbure (haut) | 500 | 0 | 44 | 0,08800 [0,06467 ; 0,11634] | 0 | 20 | 0,04000 [0,02460 ; 0,06110] |
| P2 | EXP0 | Alpha (haut) | 500 | 0 | 73 | 0,14600 [0,11622 ; 0,18004] | 0 | 35 | 0,07000 [0,04924 ; 0,09601] |
| P2 | EXP0 | ExpVar (haut) | 500 | 0 | 40 | 0,08000 [0,05777 ; 0,10735] | 0 | 22 | 0,04400 [0,02778 ; 0,06586] |
| P2 | EXP0 | KruskalAcc (haut) | 500 | 0 | 45 | 0,09000 [0,06640 ; 0,11857] | 0 | 20 | 0,04000 [0,02460 ; 0,06110] |
| P2 | EXP0 | FWb (haut) | 500 | 0 | 81 | 0,16200 [0,13078 ; 0,19728] | 0 | 37 | 0,07400 [0,05264 ; 0,10056] |
| P2 | EXP0 | FWr (haut) | 500 | 0 | 62 | 0,12400 [0,09641 ; 0,15613] | 0 | 31 | 0,06200 [0,04251 ; 0,08685] |
| P2 | EXP0 | MinP (bas) | 500 | 0 | 37 | 0,07400 [0,05264 ; 0,10056] | 0 | 13 | 0,02600 [0,01391 ; 0,04405] |
| P2 | EXP0 | MinP4 (bas) | 500 | 0 | 37 | 0,07400 [0,05264 ; 0,10056] | 0 | 11 | 0,02200 [0,01103 ; 0,03902] |
| P2 | EXP0 | TMax (haut) | 500 | 0 | 28 | 0,05600 [0,03753 ; 0,07992] | 0 | 17 | 0,03400 [0,01993 ; 0,05388] |
| P2 | EXP0 | PenteRel (deux) | 500 | 0 | 54 | 0,10800 [0,08218 ; 0,13856] | 0 | 28 | 0,05600 [0,03753 ; 0,07992] |
| P2 | EXP0 | Rosner, k̂ ≥ 1 (α = 0,10) | 500 | 0 | 0 | 0,00000 [0,00000 ; 0,00735] | — | — | — |
| P2 | EXP0 | Rosner, k̂ ≥ 1 (α = 0,05) | 500 | — | — | — | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |
| P2 | DFI | Calendrier (bas) | 500 | 0 | 55 | 0,11000 [0,08395 ; 0,14077] | 0 | 25 | 0,05000 [0,03262 ; 0,07293] |
| P2 | DFI | CorrDev (deux) | 500 | 0 | 55 | 0,11000 [0,08395 ; 0,14077] | 0 | 26 | 0,05200 [0,03425 ; 0,07527] |
| P2 | DFI | BP (haut) | 500 | 0 | 36 | 0,07200 [0,05093 ; 0,09829] | 0 | 16 | 0,03200 [0,01840 ; 0,05145] |
| P2 | DFI | Grubbs (haut) | 500 | 0 | 50 | 0,10000 [0,07514 ; 0,12971] | 0 | 23 | 0,04600 [0,02938 ; 0,06823] |
| P2 | DFI | DW (deux) | 500 | 0 | 37 | 0,07400 [0,05264 ; 0,10056] | 0 | 21 | 0,04200 [0,02618 ; 0,06349] |
| P2 | DFI | Runs (deux) | 500 | 0 | 31 | 0,06200 [0,04251 ; 0,08685] | 0 | 18 | 0,03600 [0,02147 ; 0,05630] |
| P2 | DFI | PenteIntra (deux) | 500 | 0 | 99 | 0,19800 [0,16394 ; 0,23567] | 0 | 57 | 0,11400 [0,08749 ; 0,14517] |
| P2 | DFI | Origine (haut) | 500 | 0 | 91 | 0,18200 [0,14914 ; 0,21867] | 0 | 49 | 0,09800 [0,07338 ; 0,12749] |
| P2 | DFI | HomogF (haut) | 500 | 0 | 95 | 0,19000 [0,15653 ; 0,22718] | 0 | 49 | 0,09800 [0,07338 ; 0,12749] |
| P2 | DFI | Courbure (haut) | 500 | 0 | 56 | 0,11200 [0,08572 ; 0,14297] | 0 | 29 | 0,05800 [0,03918 ; 0,08224] |
| P2 | DFI | Alpha (haut) | 500 | 0 | 152 | 0,30400 [0,26394 ; 0,34639] | 0 | 80 | 0,16000 [0,12896 ; 0,19513] |
| P2 | DFI | ExpVar (haut) | 500 | 0 | 42 | 0,08400 [0,06121 ; 0,11185] | 0 | 25 | 0,05000 [0,03262 ; 0,07293] |
| P2 | DFI | KruskalAcc (haut) | 500 | 0 | 62 | 0,12400 [0,09641 ; 0,15613] | 0 | 23 | 0,04600 [0,02938 ; 0,06823] |
| P2 | DFI | FWb (haut) | 500 | 0 | 35 | 0,07000 [0,04924 ; 0,09601] | 0 | 14 | 0,02800 [0,01539 ; 0,04653] |
| P2 | DFI | FWr (haut) | 500 | 0 | 40 | 0,08000 [0,05777 ; 0,10735] | 0 | 16 | 0,03200 [0,01840 ; 0,05145] |
| P2 | DFI | MinP (bas) | 500 | 0 | 43 | 0,08600 [0,06294 ; 0,11409] | 0 | 19 | 0,03800 [0,02303 ; 0,05871] |
| P2 | DFI | MinP4 (bas) | 500 | 0 | 44 | 0,08800 [0,06467 ; 0,11634] | 0 | 21 | 0,04200 [0,02618 ; 0,06349] |
| P2 | DFI | TMax (haut) | 500 | 0 | 44 | 0,08800 [0,06467 ; 0,11634] | 0 | 21 | 0,04200 [0,02618 ; 0,06349] |
| P2 | DFI | PenteRel (deux) | 500 | 0 | 135 | 0,27000 [0,23154 ; 0,31120] | 0 | 89 | 0,17800 [0,14546 ; 0,21440] |
| P2 | DFI | Rosner, k̂ ≥ 1 (α = 0,10) | 500 | 0 | 0 | 0,00000 [0,00000 ; 0,00735] | — | — | — |
| P2 | DFI | Rosner, k̂ ≥ 1 (α = 0,05) | 500 | — | — | — | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |
| P3 | H0 | Calendrier (bas) | 1000 | 0 | 86 | 0,08600 [0,06936 ; 0,10512] | 0 | 36 | 0,03600 [0,02534 ; 0,04949] |
| P3 | H0 | CorrDev (deux) | 1000 | 0 | 84 | 0,08400 [0,06755 ; 0,10294] | 0 | 45 | 0,04500 [0,03301 ; 0,05975] |
| P3 | H0 | BP (haut) | 1000 | 0 | 54 | 0,05400 [0,04082 ; 0,06987] | 0 | 16 | 0,01600 [0,00917 ; 0,02585] |
| P3 | H0 | Grubbs (haut) | 1000 | 0 | 92 | 0,09200 [0,07481 ; 0,11164] | 0 | 35 | 0,03500 [0,02450 ; 0,04834] |
| P3 | H0 | DW (deux) | 1000 | 0 | 81 | 0,08100 [0,06484 ; 0,09967] | 0 | 37 | 0,03700 [0,02618 ; 0,05064] |
| P3 | H0 | Runs (deux) | 1000 | 0 | 42 | 0,04200 [0,03043 ; 0,05635] | 0 | 20 | 0,02000 [0,01226 ; 0,03072] |
| P3 | H0 | PenteIntra (deux) | 1000 | 0 | 129 | 0,12900 [0,10884 ; 0,15137] | 0 | 66 | 0,06600 [0,05141 ; 0,08321] |
| P3 | H0 | Origine (haut) | 1000 | 0 | 105 | 0,10500 [0,08668 ; 0,12568] | 0 | 54 | 0,05400 [0,04082 ; 0,06987] |
| P3 | H0 | HomogF (haut) | 1000 | 0 | 64 | 0,06400 [0,04963 ; 0,08100] | 0 | 33 | 0,03300 [0,02282 ; 0,04603] |
| P3 | H0 | Courbure (haut) | 1000 | 0 | 104 | 0,10400 [0,08577 ; 0,12460] | 0 | 49 | 0,04900 [0,03647 ; 0,06427] |
| P3 | H0 | Alpha (haut) | 1000 | 0 | 98 | 0,09800 [0,08028 ; 0,11813] | 0 | 42 | 0,04200 [0,03043 ; 0,05635] |
| P3 | H0 | ExpVar (haut) | 1000 | 0 | 82 | 0,08200 [0,06575 ; 0,10076] | 0 | 38 | 0,03800 [0,02703 ; 0,05179] |
| P3 | H0 | KruskalAcc (haut) | 1000 | 0 | 101 | 0,10100 [0,08302 ; 0,12137] | 0 | 57 | 0,05700 [0,04345 ; 0,07322] |
| P3 | H0 | FWb (haut) | 1000 | 0 | 76 | 0,07600 [0,06034 ; 0,09420] | 0 | 34 | 0,03400 [0,02366 ; 0,04719] |
| P3 | H0 | FWr (haut) | 1000 | 0 | 89 | 0,08900 [0,07208 ; 0,10838] | 0 | 43 | 0,04300 [0,03129 ; 0,05749] |
| P3 | H0 | MinP (bas) | 1000 | 0 | 64 | 0,06400 [0,04963 ; 0,08100] | 0 | 37 | 0,03700 [0,02618 ; 0,05064] |
| P3 | H0 | MinP4 (bas) | 1000 | 0 | 64 | 0,06400 [0,04963 ; 0,08100] | 0 | 32 | 0,03200 [0,02199 ; 0,04488] |
| P3 | H0 | TMax (haut) | 1000 | 0 | 85 | 0,08500 [0,06846 ; 0,10403] | 0 | 53 | 0,05300 [0,03995 ; 0,06876] |
| P3 | H0 | PenteRel (deux) | 1000 | 0 | 137 | 0,13700 [0,11628 ; 0,15988] | 0 | 75 | 0,07500 [0,05945 ; 0,09311] |
| P3 | H0 | Rosner, k̂ ≥ 1 (α = 0,10) | 1000 | 0 | 0 | 0,00000 [0,00000 ; 0,00368] | — | — | — |
| P3 | H0 | Rosner, k̂ ≥ 1 (α = 0,05) | 1000 | — | — | — | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P3 | CST20 | Calendrier (bas) | 1000 | 0 | 0 | 0,00000 [0,00000 ; 0,00368] | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P3 | CST20 | CorrDev (deux) | 1000 | 0 | 998 | 0,99800 [0,99279 ; 0,99976] | 0 | 997 | 0,99700 [0,99126 ; 0,99938] |
| P3 | CST20 | BP (haut) | 1000 | 0 | 0 | 0,00000 [0,00000 ; 0,00368] | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P3 | CST20 | Grubbs (haut) | 1000 | 0 | 10 | 0,01000 [0,00481 ; 0,01831] | 0 | 1 | 0,00100 [0,00003 ; 0,00556] |
| P3 | CST20 | DW (deux) | 1000 | 0 | 0 | 0,00000 [0,00000 ; 0,00368] | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P3 | CST20 | Runs (deux) | 1000 | 0 | 0 | 0,00000 [0,00000 ; 0,00368] | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P3 | CST20 | PenteIntra (deux) | 1000 | 0 | 1000 | 1,00000 [0,99632 ; 1,00000] | 0 | 1000 | 1,00000 [0,99632 ; 1,00000] |
| P3 | CST20 | Origine (haut) | 1000 | 0 | 1000 | 1,00000 [0,99632 ; 1,00000] | 0 | 1000 | 1,00000 [0,99632 ; 1,00000] |
| P3 | CST20 | HomogF (haut) | 1000 | 0 | 0 | 0,00000 [0,00000 ; 0,00368] | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P3 | CST20 | Courbure (haut) | 1000 | 0 | 92 | 0,09200 [0,07481 ; 0,11164] | 0 | 52 | 0,05200 [0,03908 ; 0,06764] |
| P3 | CST20 | Alpha (haut) | 1000 | 0 | 1000 | 1,00000 [0,99632 ; 1,00000] | 0 | 1000 | 1,00000 [0,99632 ; 1,00000] |
| P3 | CST20 | ExpVar (haut) | 1000 | 0 | 0 | 0,00000 [0,00000 ; 0,00368] | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P3 | CST20 | KruskalAcc (haut) | 1000 | 0 | 1000 | 1,00000 [0,99632 ; 1,00000] | 0 | 1000 | 1,00000 [0,99632 ; 1,00000] |
| P3 | CST20 | FWb (haut) | 1000 | 0 | 4 | 0,00400 [0,00109 ; 0,01021] | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P3 | CST20 | FWr (haut) | 1000 | 0 | 1 | 0,00100 [0,00003 ; 0,00556] | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P3 | CST20 | MinP (bas) | 1000 | 0 | 8 | 0,00800 [0,00346 ; 0,01570] | 0 | 2 | 0,00200 [0,00024 ; 0,00721] |
| P3 | CST20 | MinP4 (bas) | 1000 | 0 | 6 | 0,00600 [0,00220 ; 0,01301] | 0 | 2 | 0,00200 [0,00024 ; 0,00721] |
| P3 | CST20 | TMax (haut) | 1000 | 0 | 43 | 0,04300 [0,03129 ; 0,05749] | 0 | 20 | 0,02000 [0,01226 ; 0,03072] |
| P3 | CST20 | PenteRel (deux) | 1000 | 0 | 1000 | 1,00000 [0,99632 ; 1,00000] | 0 | 1000 | 1,00000 [0,99632 ; 1,00000] |
| P3 | CST20 | Rosner, k̂ ≥ 1 (α = 0,10) | 1000 | 0 | 0 | 0,00000 [0,00000 ; 0,00368] | — | — | — |
| P3 | CST20 | Rosner, k̂ ≥ 1 (α = 0,05) | 1000 | — | — | — | 0 | 0 | 0,00000 [0,00000 ; 0,00368] |
| P3 | DFI | Calendrier (bas) | 500 | 0 | 74 | 0,14800 [0,11803 ; 0,18220] | 0 | 38 | 0,07600 [0,05434 ; 0,10283] |
| P3 | DFI | CorrDev (deux) | 500 | 0 | 54 | 0,10800 [0,08218 ; 0,13856] | 0 | 26 | 0,05200 [0,03425 ; 0,07527] |
| P3 | DFI | BP (haut) | 500 | 0 | 30 | 0,06000 [0,04084 ; 0,08455] | 0 | 11 | 0,02200 [0,01103 ; 0,03902] |
| P3 | DFI | Grubbs (haut) | 500 | 0 | 49 | 0,09800 [0,07338 ; 0,12749] | 0 | 26 | 0,05200 [0,03425 ; 0,07527] |
| P3 | DFI | DW (deux) | 500 | 0 | 38 | 0,07600 [0,05434 ; 0,10283] | 0 | 18 | 0,03600 [0,02147 ; 0,05630] |
| P3 | DFI | Runs (deux) | 500 | 0 | 20 | 0,04000 [0,02460 ; 0,06110] | 0 | 13 | 0,02600 [0,01391 ; 0,04405] |
| P3 | DFI | PenteIntra (deux) | 500 | 0 | 62 | 0,12400 [0,09641 ; 0,15613] | 0 | 27 | 0,05400 [0,03588 ; 0,07760] |
| P3 | DFI | Origine (haut) | 500 | 0 | 45 | 0,09000 [0,06640 ; 0,11857] | 0 | 16 | 0,03200 [0,01840 ; 0,05145] |
| P3 | DFI | HomogF (haut) | 500 | 0 | 104 | 0,20800 [0,17324 ; 0,24626] | 0 | 57 | 0,11400 [0,08749 ; 0,14517] |
| P3 | DFI | Courbure (haut) | 500 | 0 | 81 | 0,16200 [0,13078 ; 0,19728] | 0 | 38 | 0,07600 [0,05434 ; 0,10283] |
| P3 | DFI | Alpha (haut) | 500 | 0 | 43 | 0,08600 [0,06294 ; 0,11409] | 0 | 13 | 0,02600 [0,01391 ; 0,04405] |
| P3 | DFI | ExpVar (haut) | 500 | 0 | 50 | 0,10000 [0,07514 ; 0,12971] | 0 | 25 | 0,05000 [0,03262 ; 0,07293] |
| P3 | DFI | KruskalAcc (haut) | 500 | 0 | 85 | 0,17000 [0,13811 ; 0,20585] | 0 | 42 | 0,08400 [0,06121 ; 0,11185] |
| P3 | DFI | FWb (haut) | 500 | 0 | 37 | 0,07400 [0,05264 ; 0,10056] | 0 | 17 | 0,03400 [0,01993 ; 0,05388] |
| P3 | DFI | FWr (haut) | 500 | 0 | 41 | 0,08200 [0,05949 ; 0,10960] | 0 | 21 | 0,04200 [0,02618 ; 0,06349] |
| P3 | DFI | MinP (bas) | 500 | 0 | 49 | 0,09800 [0,07338 ; 0,12749] | 0 | 16 | 0,03200 [0,01840 ; 0,05145] |
| P3 | DFI | MinP4 (bas) | 500 | 0 | 46 | 0,09200 [0,06814 ; 0,12081] | 0 | 16 | 0,03200 [0,01840 ; 0,05145] |
| P3 | DFI | TMax (haut) | 500 | 0 | 45 | 0,09000 [0,06640 ; 0,11857] | 0 | 23 | 0,04600 [0,02938 ; 0,06823] |
| P3 | DFI | PenteRel (deux) | 500 | 0 | 54 | 0,10800 [0,08218 ; 0,13856] | 0 | 28 | 0,05600 [0,03753 ; 0,07992] |
| P3 | DFI | Rosner, k̂ ≥ 1 (α = 0,10) | 500 | 0 | 0 | 0,00000 [0,00000 ; 0,00735] | — | — | — |
| P3 | DFI | Rosner, k̂ ≥ 1 (α = 0,05) | 500 | — | — | — | 0 | 0 | 0,00000 [0,00000 ; 0,00735] |

### T3 — McNemar exact sur les paires de décision (paires discordantes, mêmes triangles et mêmes répliques)

D = 1 si p_mc < α (p absente : non-rejet). n01 : la **première** statistique de la paire rejette, la seconde non ; n10 : l'inverse ; p : test binomial exact bilatéral de paramètre 1/2 sur n01 + n10 (p = 1 sans paire discordante). Aucune correction de multiplicité : les paires lues par K-300 sont CEL4, CEL6 et CELx4 (P1) et les niveaux du volet A.

| Jeu | Paire | n | taux 1ère / 2nde 0,10 | n01 / n10 0,10 | p 0,10 | taux 1ère / 2nde 0,05 | n01 / n10 0,05 | p 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| volet A, loi N (P1, H0) | MinP / Grubbs | 2000 | 0,0570 / 0,0990 | 58 / 142 | 2,58e-09 | 0,0225 / 0,0445 | 28 / 72 | 1,26e-05 |
| volet A, loi N (P1, H0) | MinP4 / Grubbs | 2000 | 0,0710 / 0,0990 | 67 / 123 | 5,89e-05 | 0,0290 / 0,0445 | 38 / 69 | 0,00353 |
| volet A, loi N (P1, H0) | TMax / Grubbs | 2000 | 0,0335 / 0,0990 | 61 / 192 | 5,78e-17 | 0,0140 / 0,0445 | 25 / 86 | 5,03e-09 |
| volet A, loi N (P1, H0) | MinP / MinP4 | 2000 | 0,0570 / 0,0710 | 12 / 40 | 0,000128 | 0,0225 / 0,0290 | 4 / 17 | 0,0072 |
| volet A, loi N (P1, H0) | MinP / TMax | 2000 | 0,0570 / 0,0335 | 95 / 48 | 0,000105 | 0,0225 / 0,0140 | 41 / 24 | 0,0464 |
| volet A, loi N (P1, H0) | TMax / MinP4 | 2000 | 0,0335 / 0,0710 | 60 / 135 | 8,14e-08 | 0,0140 / 0,0290 | 28 / 58 | 0,00161 |
| volet A, loi N (P1, H0) | FWr / FWb | 2000 | 0,0890 / 0,0880 | 11 / 9 | 0,824 | 0,0410 / 0,0415 | 8 / 9 | 1 |
| volet A, loi N (P1, H0) | FWr / BP | 2000 | 0,0890 / 0,0160 | 159 / 13 | 4,23e-33 | 0,0410 / 0,0050 | 75 / 3 | 5,24e-19 |
| volet A, loi N (P1, H0) | FWb / BP | 2000 | 0,0880 / 0,0160 | 158 / 14 | 4,84e-32 | 0,0415 / 0,0050 | 76 / 3 | 2,72e-19 |
| volet A, loi E (P1, H0) | MinP / Grubbs | 2000 | 0,0825 / 0,0750 | 104 / 89 | 0,314 | 0,0400 / 0,0350 | 62 / 52 | 0,399 |
| volet A, loi E (P1, H0) | MinP4 / Grubbs | 2000 | 0,0785 / 0,0750 | 86 / 79 | 0,641 | 0,0395 / 0,0350 | 55 / 46 | 0,426 |
| volet A, loi E (P1, H0) | TMax / Grubbs | 2000 | 0,0885 / 0,0750 | 168 / 141 | 0,139 | 0,0470 / 0,0350 | 92 / 68 | 0,0687 |
| volet A, loi E (P1, H0) | MinP / MinP4 | 2000 | 0,0825 / 0,0785 | 32 / 24 | 0,35 | 0,0400 / 0,0395 | 13 / 12 | 1 |
| volet A, loi E (P1, H0) | MinP / TMax | 2000 | 0,0825 / 0,0885 | 107 / 119 | 0,464 | 0,0400 / 0,0470 | 59 / 73 | 0,258 |
| volet A, loi E (P1, H0) | TMax / MinP4 | 2000 | 0,0885 / 0,0785 | 150 / 130 | 0,256 | 0,0470 / 0,0395 | 86 / 71 | 0,264 |
| volet A, loi E (P1, H0) | FWr / FWb | 2000 | 0,0970 / 0,0960 | 20 / 18 | 0,871 | 0,0530 / 0,0510 | 11 / 7 | 0,481 |
| volet A, loi E (P1, H0) | FWr / BP | 2000 | 0,0970 / 0,0695 | 137 / 82 | 0,000246 | 0,0530 / 0,0245 | 83 / 26 | 4,01e-08 |
| volet A, loi E (P1, H0) | FWb / BP | 2000 | 0,0960 / 0,0695 | 133 / 80 | 0,000344 | 0,0510 / 0,0245 | 79 / 26 | 2,17e-07 |
| volet A, loi A (P1, H0) | MinP / Grubbs | 1000 | 0,0920 / 0,1590 | 37 / 104 | 1,47e-08 | 0,0410 / 0,0880 | 20 / 67 | 4,31e-07 |
| volet A, loi A (P1, H0) | MinP4 / Grubbs | 1000 | 0,1180 / 0,1590 | 46 / 87 | 0,000477 | 0,0470 / 0,0880 | 20 / 61 | 5,66e-06 |
| volet A, loi A (P1, H0) | TMax / Grubbs | 1000 | 0,0370 / 0,1590 | 28 / 150 | 2,29e-21 | 0,0190 / 0,0880 | 19 / 88 | 8,48e-12 |
| volet A, loi A (P1, H0) | MinP / MinP4 | 1000 | 0,0920 / 0,1180 | 5 / 31 | 1,29e-05 | 0,0410 / 0,0470 | 4 / 10 | 0,18 |
| volet A, loi A (P1, H0) | MinP / TMax | 1000 | 0,0920 / 0,0370 | 84 / 29 | 2,2e-07 | 0,0410 / 0,0190 | 35 / 13 | 0,00209 |
| volet A, loi A (P1, H0) | TMax / MinP4 | 1000 | 0,0370 / 0,1180 | 33 / 114 | 1,22e-11 | 0,0190 / 0,0470 | 17 / 45 | 0,000497 |
| volet A, loi A (P1, H0) | FWr / FWb | 1000 | 0,0860 / 0,0870 | 6 / 7 | 1 | 0,0460 / 0,0490 | 3 / 6 | 0,508 |
| volet A, loi A (P1, H0) | FWr / BP | 1000 | 0,0860 / 0,0040 | 84 / 2 | 9,67e-23 | 0,0460 / 0,0000 | 46 / 0 | 2,84e-14 |
| volet A, loi A (P1, H0) | FWb / BP | 1000 | 0,0870 / 0,0040 | 85 / 2 | 4,95e-23 | 0,0490 / 0,0000 | 49 / 0 | 3,55e-15 |
| P1.H0 | MinP / Grubbs | 1000 | 0,0460 / 0,0830 | 28 / 65 | 0,000158 | 0,0120 / 0,0350 | 9 / 32 | 0,000431 |
| P1.H0 | MinP4 / Grubbs | 1000 | 0,0540 / 0,0830 | 28 / 57 | 0,00219 | 0,0180 / 0,0350 | 15 / 32 | 0,0186 |
| P1.H0 | TMax / Grubbs | 1000 | 0,0380 / 0,0830 | 34 / 79 | 2,77e-05 | 0,0110 / 0,0350 | 9 / 33 | 0,000272 |
| P1.H0 | MinP / MinP4 | 1000 | 0,0460 / 0,0540 | 4 / 12 | 0,0768 | 0,0120 / 0,0180 | 1 / 7 | 0,0703 |
| P1.H0 | MinP / TMax | 1000 | 0,0460 / 0,0380 | 37 / 29 | 0,389 | 0,0120 / 0,0110 | 10 / 9 | 1 |
| P1.H0 | TMax / MinP4 | 1000 | 0,0380 / 0,0540 | 33 / 49 | 0,097 | 0,0110 / 0,0180 | 10 / 17 | 0,248 |
| P1.H0 | FWr / FWb | 1000 | 0,0900 / 0,0900 | 6 / 6 | 1 | 0,0420 / 0,0440 | 5 / 7 | 0,774 |
| P1.H0 | FWr / BP | 1000 | 0,0900 / 0,0220 | 77 / 9 | 1,34e-14 | 0,0420 / 0,0060 | 38 / 2 | 1,49e-09 |
| P1.H0 | FWb / BP | 1000 | 0,0900 / 0,0220 | 75 / 7 | 1,73e-15 | 0,0440 / 0,0060 | 40 / 2 | 4,11e-10 |
| P1.CST20 | MinP / Grubbs | 1000 | 0,0430 / 0,0720 | 26 / 55 | 0,00169 | 0,0170 / 0,0320 | 15 / 30 | 0,0357 |
| P1.CST20 | MinP4 / Grubbs | 1000 | 0,0650 / 0,0720 | 38 / 45 | 0,51 | 0,0250 / 0,0320 | 22 / 29 | 0,401 |
| P1.CST20 | TMax / Grubbs | 1000 | 0,0250 / 0,0720 | 24 / 71 | 1,46e-06 | 0,0090 / 0,0320 | 9 / 32 | 0,000431 |
| P1.CST20 | MinP / MinP4 | 1000 | 0,0430 / 0,0650 | 1 / 23 | 2,98e-06 | 0,0170 / 0,0250 | 0 / 8 | 0,00781 |
| P1.CST20 | MinP / TMax | 1000 | 0,0430 / 0,0250 | 40 / 22 | 0,03 | 0,0170 / 0,0090 | 16 / 8 | 0,152 |
| P1.CST20 | TMax / MinP4 | 1000 | 0,0250 / 0,0650 | 23 / 63 | 1,88e-05 | 0,0090 / 0,0250 | 8 / 24 | 0,007 |
| P1.CST20 | FWr / FWb | 1000 | 0,0800 / 0,0980 | 3 / 21 | 0,000277 | 0,0360 / 0,0430 | 2 / 9 | 0,0654 |
| P1.CST20 | FWr / BP | 1000 | 0,0800 / 0,0020 | 80 / 2 | 1,41e-21 | 0,0360 / 0,0000 | 36 / 0 | 2,91e-11 |
| P1.CST20 | FWb / BP | 1000 | 0,0980 / 0,0020 | 98 / 2 | 7,97e-27 | 0,0430 / 0,0000 | 43 / 0 | 2,27e-13 |
| P1.EXP2 | MinP / Grubbs | 1000 | 0,0470 / 0,0810 | 27 / 61 | 0,000374 | 0,0170 / 0,0410 | 13 / 37 | 0,000936 |
| P1.EXP2 | MinP4 / Grubbs | 1000 | 0,0580 / 0,0810 | 29 / 52 | 0,014 | 0,0180 / 0,0410 | 12 / 35 | 0,00109 |
| P1.EXP2 | TMax / Grubbs | 1000 | 0,0320 / 0,0810 | 29 / 78 | 2,35e-06 | 0,0170 / 0,0410 | 17 / 41 | 0,00223 |
| P1.EXP2 | MinP / MinP4 | 1000 | 0,0470 / 0,0580 | 6 / 17 | 0,0347 | 0,0170 / 0,0180 | 3 / 4 | 1 |
| P1.EXP2 | MinP / TMax | 1000 | 0,0470 / 0,0320 | 38 / 23 | 0,0722 | 0,0170 / 0,0170 | 14 / 14 | 1 |
| P1.EXP2 | TMax / MinP4 | 1000 | 0,0320 / 0,0580 | 29 / 55 | 0,00604 | 0,0170 / 0,0180 | 17 / 18 | 1 |
| P1.EXP2 | FWr / FWb | 1000 | 0,0930 / 0,0940 | 8 / 9 | 1 | 0,0490 / 0,0470 | 5 / 3 | 0,727 |
| P1.EXP2 | FWr / BP | 1000 | 0,0930 / 0,0220 | 81 / 10 | 5,9e-15 | 0,0490 / 0,0040 | 47 / 2 | 4,36e-12 |
| P1.EXP2 | FWb / BP | 1000 | 0,0940 / 0,0220 | 80 / 8 | 4,6e-16 | 0,0470 / 0,0040 | 44 / 1 | 2,61e-12 |
| P1.CEL4 | MinP / Grubbs | 1000 | 0,1390 / 0,2110 | 32 / 104 | 4,43e-10 | 0,0650 / 0,0630 | 50 / 48 | 0,92 |
| P1.CEL4 | MinP4 / Grubbs | 1000 | 0,1830 / 0,2110 | 46 / 74 | 0,0134 | 0,0840 / 0,0630 | 63 / 42 | 0,0504 |
| P1.CEL4 | TMax / Grubbs | 1000 | 0,0350 / 0,2110 | 31 / 207 | 3,95e-33 | 0,0160 / 0,0630 | 15 / 62 | 6,08e-08 |
| P1.CEL4 | MinP / MinP4 | 1000 | 0,1390 / 0,1830 | 5 / 49 | 3,89e-10 | 0,0650 / 0,0840 | 1 / 20 | 2,1e-05 |
| P1.CEL4 | MinP / TMax | 1000 | 0,1390 / 0,0350 | 129 / 25 | 4,33e-18 | 0,0650 / 0,0160 | 64 / 15 | 2,3e-08 |
| P1.CEL4 | TMax / MinP4 | 1000 | 0,0350 / 0,1830 | 27 / 175 | 9,6e-28 | 0,0160 / 0,0840 | 16 / 84 | 2,61e-12 |
| P1.CEL4 | FWr / FWb | 1000 | 0,0370 / 0,0290 | 9 / 1 | 0,0215 | 0,0080 / 0,0090 | 0 / 1 | 1 |
| P1.CEL4 | FWr / BP | 1000 | 0,0370 / 0,0040 | 34 / 1 | 2,1e-09 | 0,0080 / 0,0020 | 6 / 0 | 0,0313 |
| P1.CEL4 | FWb / BP | 1000 | 0,0290 / 0,0040 | 27 / 2 | 1,62e-06 | 0,0090 / 0,0020 | 7 / 0 | 0,0156 |
| P1.CEL6 | MinP / Grubbs | 1000 | 0,3490 / 0,3720 | 73 / 96 | 0,0903 | 0,1800 / 0,0860 | 134 / 40 | 4,66e-13 |
| P1.CEL6 | MinP4 / Grubbs | 1000 | 0,4260 / 0,3720 | 110 / 56 | 3,36e-05 | 0,2250 / 0,0860 | 177 / 38 | 1,22e-22 |
| P1.CEL6 | TMax / Grubbs | 1000 | 0,0370 / 0,3720 | 25 / 360 | 3,43e-77 | 0,0160 / 0,0860 | 15 / 85 | 4,83e-13 |
| P1.CEL6 | MinP / MinP4 | 1000 | 0,3490 / 0,4260 | 6 / 83 | 2,02e-18 | 0,1800 / 0,2250 | 4 / 49 | 7,05e-11 |
| P1.CEL6 | MinP / TMax | 1000 | 0,3490 / 0,0370 | 331 / 19 | 1,01e-74 | 0,1800 / 0,0160 | 173 / 9 | 1,7e-40 |
| P1.CEL6 | TMax / MinP4 | 1000 | 0,0370 / 0,4260 | 25 / 414 | 5,55e-92 | 0,0160 / 0,2250 | 12 / 221 | 6,14e-51 |
| P1.CEL6 | FWr / FWb | 1000 | 0,0360 / 0,0280 | 8 / 0 | 0,00781 | 0,0100 / 0,0060 | 4 / 0 | 0,125 |
| P1.CEL6 | FWr / BP | 1000 | 0,0360 / 0,0010 | 36 / 1 | 5,53e-10 | 0,0100 / 0,0000 | 10 / 0 | 0,00195 |
| P1.CEL6 | FWb / BP | 1000 | 0,0280 / 0,0010 | 28 / 1 | 1,12e-07 | 0,0060 / 0,0000 | 6 / 0 | 0,0313 |
| P1.CST10 | MinP / Grubbs | 500 | 0,0620 / 0,1100 | 15 / 39 | 0,0015 | 0,0160 / 0,0600 | 6 / 28 | 0,000195 |
| P1.CST10 | MinP4 / Grubbs | 500 | 0,0800 / 0,1100 | 19 / 34 | 0,0534 | 0,0220 / 0,0600 | 9 / 28 | 0,00256 |
| P1.CST10 | TMax / Grubbs | 500 | 0,0340 / 0,1100 | 14 / 52 | 2,82e-06 | 0,0140 / 0,0600 | 6 / 29 | 0,000117 |
| P1.CST10 | MinP / MinP4 | 500 | 0,0620 / 0,0800 | 3 / 12 | 0,0352 | 0,0160 / 0,0220 | 0 / 3 | 0,25 |
| P1.CST10 | MinP / TMax | 500 | 0,0620 / 0,0340 | 25 / 11 | 0,0288 | 0,0160 / 0,0140 | 7 / 6 | 1 |
| P1.CST10 | TMax / MinP4 | 500 | 0,0340 / 0,0800 | 14 / 37 | 0,00177 | 0,0140 / 0,0220 | 6 / 10 | 0,454 |
| P1.CST10 | FWr / FWb | 500 | 0,0920 / 0,0980 | 4 / 7 | 0,549 | 0,0380 / 0,0380 | 3 / 3 | 1 |
| P1.CST10 | FWr / BP | 500 | 0,0920 / 0,0080 | 44 / 2 | 3,08e-11 | 0,0380 / 0,0020 | 18 / 0 | 7,63e-06 |
| P1.CST10 | FWb / BP | 500 | 0,0980 / 0,0080 | 47 / 2 | 4,36e-12 | 0,0380 / 0,0020 | 18 / 0 | 7,63e-06 |
| P1.EXP0 | MinP / Grubbs | 500 | 0,0480 / 0,0880 | 12 / 32 | 0,00366 | 0,0140 / 0,0560 | 6 / 27 | 0,000324 |
| P1.EXP0 | MinP4 / Grubbs | 500 | 0,0660 / 0,0880 | 15 / 26 | 0,117 | 0,0260 / 0,0560 | 8 / 23 | 0,0107 |
| P1.EXP0 | TMax / Grubbs | 500 | 0,0540 / 0,0880 | 23 / 40 | 0,043 | 0,0180 / 0,0560 | 9 / 28 | 0,00256 |
| P1.EXP0 | MinP / MinP4 | 500 | 0,0480 / 0,0660 | 2 / 11 | 0,0225 | 0,0140 / 0,0260 | 2 / 8 | 0,109 |
| P1.EXP0 | MinP / TMax | 500 | 0,0480 / 0,0540 | 20 / 23 | 0,761 | 0,0140 / 0,0180 | 5 / 7 | 0,774 |
| P1.EXP0 | TMax / MinP4 | 500 | 0,0540 / 0,0660 | 23 / 29 | 0,488 | 0,0180 / 0,0260 | 9 / 13 | 0,523 |
| P1.EXP0 | FWr / FWb | 500 | 0,0700 / 0,0640 | 8 / 5 | 0,581 | 0,0220 / 0,0240 | 2 / 3 | 1 |
| P1.EXP0 | FWr / BP | 500 | 0,0700 / 0,0200 | 29 / 4 | 1,09e-05 | 0,0220 / 0,0060 | 8 / 0 | 0,00781 |
| P1.EXP0 | FWb / BP | 500 | 0,0640 / 0,0200 | 25 / 3 | 2,74e-05 | 0,0240 / 0,0060 | 10 / 1 | 0,0117 |
| P1.DFI | MinP / Grubbs | 500 | 0,0500 / 0,0720 | 18 / 29 | 0,144 | 0,0200 / 0,0160 | 8 / 6 | 0,791 |
| P1.DFI | MinP4 / Grubbs | 500 | 0,0560 / 0,0720 | 19 / 27 | 0,302 | 0,0220 / 0,0160 | 8 / 5 | 0,581 |
| P1.DFI | TMax / Grubbs | 500 | 0,0520 / 0,0720 | 24 / 34 | 0,237 | 0,0180 / 0,0160 | 9 / 8 | 1 |
| P1.DFI | MinP / MinP4 | 500 | 0,0500 / 0,0560 | 6 / 9 | 0,607 | 0,0200 / 0,0220 | 2 / 3 | 1 |
| P1.DFI | MinP / TMax | 500 | 0,0500 / 0,0520 | 17 / 18 | 1 | 0,0200 / 0,0180 | 7 / 6 | 1 |
| P1.DFI | TMax / MinP4 | 500 | 0,0520 / 0,0560 | 24 / 26 | 0,888 | 0,0180 / 0,0220 | 8 / 10 | 0,815 |
| P1.DFI | FWr / FWb | 500 | 0,0860 / 0,0840 | 5 / 4 | 1 | 0,0360 / 0,0380 | 0 / 1 | 1 |
| P1.DFI | FWr / BP | 500 | 0,0860 / 0,0220 | 38 / 6 | 9,43e-07 | 0,0360 / 0,0000 | 18 / 0 | 7,63e-06 |
| P1.DFI | FWb / BP | 500 | 0,0840 / 0,0220 | 37 / 6 | 1,64e-06 | 0,0380 / 0,0000 | 19 / 0 | 3,81e-06 |
| P1.CAL7 | MinP / Grubbs | 500 | 0,3120 / 0,6100 | 9 / 158 | 2,53e-36 | 0,1500 / 0,4180 | 4 / 138 | 6e-36 |
| P1.CAL7 | MinP4 / Grubbs | 500 | 0,3660 / 0,6100 | 11 / 133 | 9,13e-28 | 0,1800 / 0,4180 | 4 / 123 | 1,25e-31 |
| P1.CAL7 | TMax / Grubbs | 500 | 0,0440 / 0,6100 | 11 / 294 | 1,41e-72 | 0,0120 / 0,4180 | 6 / 209 | 5e-54 |
| P1.CAL7 | MinP / MinP4 | 500 | 0,3120 / 0,3660 | 1 / 28 | 1,12e-07 | 0,1500 / 0,1800 | 1 / 16 | 0,000275 |
| P1.CAL7 | MinP / TMax | 500 | 0,3120 / 0,0440 | 151 / 17 | 4,95e-28 | 0,1500 / 0,0120 | 74 / 5 | 7,98e-17 |
| P1.CAL7 | TMax / MinP4 | 500 | 0,0440 / 0,3660 | 18 / 179 | 1,55e-34 | 0,0120 / 0,1800 | 6 / 90 | 2,5e-20 |
| P1.CAL7 | FWr / FWb | 500 | 0,3640 / 0,3640 | 9 / 9 | 1 | 0,2320 / 0,2160 | 12 / 4 | 0,0768 |
| P1.CAL7 | FWr / BP | 500 | 0,3640 / 0,0020 | 181 / 0 | 6,53e-55 | 0,2320 / 0,0000 | 116 / 0 | 2,41e-35 |
| P1.CAL7 | FWb / BP | 500 | 0,3640 / 0,0020 | 181 / 0 | 6,53e-55 | 0,2160 / 0,0000 | 108 / 0 | 6,16e-33 |
| P1.CAL4 | MinP / Grubbs | 500 | 0,0560 / 0,0820 | 24 / 37 | 0,124 | 0,0140 / 0,0420 | 7 / 21 | 0,0125 |
| P1.CAL4 | MinP4 / Grubbs | 500 | 0,0720 / 0,0820 | 27 / 32 | 0,603 | 0,0180 / 0,0420 | 9 / 21 | 0,0428 |
| P1.CAL4 | TMax / Grubbs | 500 | 0,0340 / 0,0820 | 16 / 40 | 0,00184 | 0,0140 / 0,0420 | 7 / 21 | 0,0125 |
| P1.CAL4 | MinP / MinP4 | 500 | 0,0560 / 0,0720 | 5 / 13 | 0,0963 | 0,0140 / 0,0180 | 0 / 2 | 0,5 |
| P1.CAL4 | MinP / TMax | 500 | 0,0560 / 0,0340 | 22 / 11 | 0,0801 | 0,0140 / 0,0140 | 7 / 7 | 1 |
| P1.CAL4 | TMax / MinP4 | 500 | 0,0340 / 0,0720 | 15 / 34 | 0,0094 | 0,0140 / 0,0180 | 7 / 9 | 0,804 |
| P1.CAL4 | FWr / FWb | 500 | 0,0220 / 0,0140 | 4 / 0 | 0,125 | 0,0020 / 0,0020 | 0 / 0 | 1 |
| P1.CAL4 | FWr / BP | 500 | 0,0220 / 0,0000 | 11 / 0 | 0,000977 | 0,0020 / 0,0000 | 1 / 0 | 1 |
| P1.CAL4 | FWb / BP | 500 | 0,0140 / 0,0000 | 7 / 0 | 0,0156 | 0,0020 / 0,0000 | 1 / 0 | 1 |
| P1.DCAL | MinP / Grubbs | 500 | 0,0260 / 0,0520 | 10 / 23 | 0,0351 | 0,0060 / 0,0180 | 2 / 8 | 0,109 |
| P1.DCAL | MinP4 / Grubbs | 500 | 0,0400 / 0,0520 | 12 / 18 | 0,362 | 0,0060 / 0,0180 | 2 / 8 | 0,109 |
| P1.DCAL | TMax / Grubbs | 500 | 0,0420 / 0,0520 | 19 / 24 | 0,542 | 0,0200 / 0,0180 | 10 / 9 | 1 |
| P1.DCAL | MinP / MinP4 | 500 | 0,0260 / 0,0400 | 1 / 8 | 0,0391 | 0,0060 / 0,0060 | 1 / 1 | 1 |
| P1.DCAL | MinP / TMax | 500 | 0,0260 / 0,0420 | 11 / 19 | 0,2 | 0,0060 / 0,0200 | 2 / 9 | 0,0654 |
| P1.DCAL | TMax / MinP4 | 500 | 0,0420 / 0,0400 | 19 / 18 | 1 | 0,0200 / 0,0060 | 10 / 3 | 0,0923 |
| P1.DCAL | FWr / FWb | 500 | 0,0820 / 0,0900 | 3 / 7 | 0,344 | 0,0400 / 0,0460 | 0 / 3 | 0,25 |
| P1.DCAL | FWr / BP | 500 | 0,0820 / 0,0840 | 20 / 21 | 1 | 0,0400 / 0,0360 | 13 / 11 | 0,839 |
| P1.DCAL | FWb / BP | 500 | 0,0900 / 0,0840 | 21 / 18 | 0,749 | 0,0460 / 0,0360 | 15 / 10 | 0,424 |
| P1.LIG | MinP / Grubbs | 500 | 0,8160 / 0,4060 | 214 / 9 | 4,94e-52 | 0,6100 / 0,0700 | 272 / 2 | 2,48e-78 |
| P1.LIG | MinP4 / Grubbs | 500 | 0,8360 / 0,4060 | 219 / 4 | 1,52e-59 | 0,6420 / 0,0700 | 287 / 1 | 1,16e-84 |
| P1.LIG | TMax / Grubbs | 500 | 0,0460 / 0,4060 | 13 / 193 | 2,73e-42 | 0,0160 / 0,0700 | 8 / 35 | 4,19e-05 |
| P1.LIG | MinP / MinP4 | 500 | 0,8160 / 0,8360 | 0 / 10 | 0,00195 | 0,6100 / 0,6420 | 0 / 16 | 3,05e-05 |
| P1.LIG | MinP / TMax | 500 | 0,8160 / 0,0460 | 391 / 6 | 3,29e-107 | 0,6100 / 0,0160 | 302 / 5 | 1,72e-82 |
| P1.LIG | TMax / MinP4 | 500 | 0,0460 / 0,8360 | 6 / 401 | 3,74e-110 | 0,0160 / 0,6420 | 5 / 318 | 3,38e-87 |
| P1.LIG | FWr / FWb | 500 | 0,2820 / 0,1760 | 53 / 0 | 2,22e-16 | 0,0860 / 0,0160 | 35 / 0 | 5,82e-11 |
| P1.LIG | FWr / BP | 500 | 0,2820 / 0,0000 | 141 / 0 | 7,17e-43 | 0,0860 / 0,0000 | 43 / 0 | 2,27e-13 |
| P1.LIG | FWb / BP | 500 | 0,1760 / 0,0000 | 88 / 0 | 6,46e-27 | 0,0160 / 0,0000 | 8 / 0 | 0,00781 |
| P1.CELx4 | MinP / Grubbs | 500 | 1,0000 / 0,6320 | 184 / 0 | 8,16e-56 | 1,0000 / 0,0380 | 481 / 0 | 3,2e-145 |
| P1.CELx4 | MinP4 / Grubbs | 500 | 1,0000 / 0,6320 | 184 / 0 | 8,16e-56 | 1,0000 / 0,0380 | 481 / 0 | 3,2e-145 |
| P1.CELx4 | TMax / Grubbs | 500 | 1,0000 / 0,6320 | 184 / 0 | 8,16e-56 | 0,7060 / 0,0380 | 339 / 5 | 2,21e-93 |
| P1.CELx4 | MinP / MinP4 | 500 | 1,0000 / 1,0000 | 0 / 0 | 1 | 1,0000 / 1,0000 | 0 / 0 | 1 |
| P1.CELx4 | MinP / TMax | 500 | 1,0000 / 1,0000 | 0 / 0 | 1 | 1,0000 / 0,7060 | 147 / 0 | 1,12e-44 |
| P1.CELx4 | TMax / MinP4 | 500 | 1,0000 / 1,0000 | 0 / 0 | 1 | 0,7060 / 1,0000 | 0 / 147 | 1,12e-44 |
| P1.CELx4 | FWr / FWb | 500 | 1,0000 / 0,9240 | 38 / 0 | 7,28e-12 | 1,0000 / 0,2640 | 368 / 0 | 3,33e-111 |
| P1.CELx4 | FWr / BP | 500 | 1,0000 / 0,0000 | 500 / 0 | 6,11e-151 | 1,0000 / 0,0000 | 500 / 0 | 6,11e-151 |
| P1.CELx4 | FWb / BP | 500 | 0,9240 / 0,0000 | 462 / 0 | 1,68e-139 | 0,2640 / 0,0000 | 132 / 0 | 3,67e-40 |
| P2.H0 | MinP / Grubbs | 1000 | 0,0720 / 0,1070 | 36 / 71 | 0,000923 | 0,0340 / 0,0540 | 17 / 37 | 0,00907 |
| P2.H0 | MinP4 / Grubbs | 1000 | 0,0740 / 0,1070 | 37 / 70 | 0,00184 | 0,0340 / 0,0540 | 15 / 35 | 0,0066 |
| P2.H0 | TMax / Grubbs | 1000 | 0,0710 / 0,1070 | 63 / 99 | 0,00579 | 0,0340 / 0,0540 | 32 / 52 | 0,0375 |
| P2.H0 | MinP / MinP4 | 1000 | 0,0720 / 0,0740 | 5 / 7 | 0,774 | 0,0340 / 0,0340 | 2 / 2 | 1 |
| P2.H0 | MinP / TMax | 1000 | 0,0720 / 0,0710 | 56 / 55 | 1 | 0,0340 / 0,0340 | 29 / 29 | 1 |
| P2.H0 | TMax / MinP4 | 1000 | 0,0710 / 0,0740 | 60 / 63 | 0,857 | 0,0340 / 0,0340 | 31 / 31 | 1 |
| P2.H0 | FWr / FWb | 1000 | 0,0940 / 0,0970 | 17 / 20 | 0,743 | 0,0490 / 0,0470 | 13 / 11 | 0,839 |
| P2.H0 | FWr / BP | 1000 | 0,0940 / 0,0630 | 57 / 26 | 0,000878 | 0,0490 / 0,0300 | 33 / 14 | 0,00794 |
| P2.H0 | FWb / BP | 1000 | 0,0970 / 0,0630 | 44 / 10 | 3,39e-06 | 0,0470 / 0,0300 | 23 / 6 | 0,00232 |
| P2.CST20 | MinP / Grubbs | 1000 | 0,0210 / 0,0120 | 19 / 10 | 0,136 | 0,0080 / 0,0010 | 8 / 1 | 0,0391 |
| P2.CST20 | MinP4 / Grubbs | 1000 | 0,0180 / 0,0120 | 16 / 10 | 0,327 | 0,0090 / 0,0010 | 9 / 1 | 0,0215 |
| P2.CST20 | TMax / Grubbs | 1000 | 0,0500 / 0,0120 | 49 / 11 | 7,56e-07 | 0,0180 / 0,0010 | 18 / 1 | 7,63e-05 |
| P2.CST20 | MinP / MinP4 | 1000 | 0,0210 / 0,0180 | 4 / 1 | 0,375 | 0,0080 / 0,0090 | 0 / 1 | 1 |
| P2.CST20 | MinP / TMax | 1000 | 0,0210 / 0,0500 | 12 / 41 | 8,17e-05 | 0,0080 / 0,0180 | 7 / 17 | 0,0639 |
| P2.CST20 | TMax / MinP4 | 1000 | 0,0500 / 0,0180 | 45 / 13 | 3,01e-05 | 0,0180 / 0,0090 | 17 / 8 | 0,108 |
| P2.CST20 | FWr / FWb | 1000 | 0,0880 / 0,1610 | 0 / 73 | 2,12e-22 | 0,0340 / 0,0670 | 0 / 33 | 2,33e-10 |
| P2.CST20 | FWr / BP | 1000 | 0,0880 / 0,0060 | 82 / 0 | 4,14e-25 | 0,0340 / 0,0000 | 34 / 0 | 1,16e-10 |
| P2.CST20 | FWb / BP | 1000 | 0,1610 / 0,0060 | 155 / 0 | 4,38e-47 | 0,0670 / 0,0000 | 67 / 0 | 1,36e-20 |
| P2.EXP2 | MinP / Grubbs | 1000 | 0,0760 / 0,1150 | 37 / 76 | 0,00031 | 0,0380 / 0,0460 | 22 / 30 | 0,332 |
| P2.EXP2 | MinP4 / Grubbs | 1000 | 0,0770 / 0,1150 | 36 / 74 | 0,000371 | 0,0350 / 0,0460 | 19 / 30 | 0,152 |
| P2.EXP2 | TMax / Grubbs | 1000 | 0,0720 / 0,1150 | 62 / 105 | 0,00109 | 0,0400 / 0,0460 | 35 / 41 | 0,567 |
| P2.EXP2 | MinP / MinP4 | 1000 | 0,0760 / 0,0770 | 6 / 7 | 1 | 0,0380 / 0,0350 | 4 / 1 | 0,375 |
| P2.EXP2 | MinP / TMax | 1000 | 0,0760 / 0,0720 | 58 / 54 | 0,777 | 0,0380 / 0,0400 | 31 / 33 | 0,901 |
| P2.EXP2 | TMax / MinP4 | 1000 | 0,0720 / 0,0770 | 60 / 65 | 0,721 | 0,0400 / 0,0350 | 37 / 32 | 0,63 |
| P2.EXP2 | FWr / FWb | 1000 | 0,1120 / 0,0830 | 39 / 10 | 3,85e-05 | 0,0470 / 0,0340 | 15 / 2 | 0,00235 |
| P2.EXP2 | FWr / BP | 1000 | 0,1120 / 0,0290 | 98 / 15 | 4,1e-16 | 0,0470 / 0,0100 | 42 / 5 | 2,46e-08 |
| P2.EXP2 | FWb / BP | 1000 | 0,0830 / 0,0290 | 60 / 6 | 2,73e-12 | 0,0340 / 0,0100 | 27 / 3 | 8,43e-06 |
| P2.CST10 | MinP / Grubbs | 500 | 0,0280 / 0,0420 | 8 / 15 | 0,21 | 0,0120 / 0,0200 | 4 / 8 | 0,388 |
| P2.CST10 | MinP4 / Grubbs | 500 | 0,0340 / 0,0420 | 10 / 14 | 0,541 | 0,0160 / 0,0200 | 6 / 8 | 0,791 |
| P2.CST10 | TMax / Grubbs | 500 | 0,0420 / 0,0420 | 21 / 21 | 1 | 0,0240 / 0,0200 | 12 / 10 | 0,832 |
| P2.CST10 | MinP / MinP4 | 500 | 0,0280 / 0,0340 | 2 / 5 | 0,453 | 0,0120 / 0,0160 | 0 / 2 | 0,5 |
| P2.CST10 | MinP / TMax | 500 | 0,0280 / 0,0420 | 11 / 18 | 0,265 | 0,0120 / 0,0240 | 6 / 12 | 0,238 |
| P2.CST10 | TMax / MinP4 | 500 | 0,0420 / 0,0340 | 20 / 16 | 0,618 | 0,0240 / 0,0160 | 12 / 8 | 0,503 |
| P2.CST10 | FWr / FWb | 500 | 0,1120 / 0,1620 | 0 / 25 | 5,96e-08 | 0,0440 / 0,0800 | 0 / 18 | 7,63e-06 |
| P2.CST10 | FWr / BP | 500 | 0,1120 / 0,0520 | 33 / 3 | 2,27e-07 | 0,0440 / 0,0040 | 20 / 0 | 1,91e-06 |
| P2.CST10 | FWb / BP | 500 | 0,1620 / 0,0520 | 55 / 0 | 5,55e-17 | 0,0800 / 0,0040 | 38 / 0 | 7,28e-12 |
| P2.EXP0 | MinP / Grubbs | 500 | 0,0740 / 0,1160 | 17 / 38 | 0,00646 | 0,0260 / 0,0540 | 10 / 24 | 0,0243 |
| P2.EXP0 | MinP4 / Grubbs | 500 | 0,0740 / 0,1160 | 16 / 37 | 0,00549 | 0,0220 / 0,0540 | 7 / 23 | 0,00522 |
| P2.EXP0 | TMax / Grubbs | 500 | 0,0560 / 0,1160 | 24 / 54 | 0,000901 | 0,0340 / 0,0540 | 15 / 25 | 0,154 |
| P2.EXP0 | MinP / MinP4 | 500 | 0,0740 / 0,0740 | 4 / 4 | 1 | 0,0260 / 0,0220 | 4 / 2 | 0,687 |
| P2.EXP0 | MinP / TMax | 500 | 0,0740 / 0,0560 | 30 / 21 | 0,262 | 0,0260 / 0,0340 | 9 / 13 | 0,523 |
| P2.EXP0 | TMax / MinP4 | 500 | 0,0560 / 0,0740 | 24 / 33 | 0,289 | 0,0340 / 0,0220 | 17 / 11 | 0,345 |
| P2.EXP0 | FWr / FWb | 500 | 0,1240 / 0,1620 | 5 / 24 | 0,000546 | 0,0620 / 0,0740 | 3 / 9 | 0,146 |
| P2.EXP0 | FWr / BP | 500 | 0,1240 / 0,1540 | 12 / 27 | 0,0237 | 0,0620 / 0,0640 | 9 / 10 | 1 |
| P2.EXP0 | FWb / BP | 500 | 0,1620 / 0,1540 | 12 / 8 | 0,503 | 0,0740 / 0,0640 | 13 / 8 | 0,383 |
| P2.DFI | MinP / Grubbs | 500 | 0,0860 / 0,1000 | 24 / 31 | 0,419 | 0,0380 / 0,0460 | 13 / 17 | 0,585 |
| P2.DFI | MinP4 / Grubbs | 500 | 0,0880 / 0,1000 | 24 / 30 | 0,497 | 0,0420 / 0,0460 | 13 / 15 | 0,851 |
| P2.DFI | TMax / Grubbs | 500 | 0,0880 / 0,1000 | 40 / 46 | 0,59 | 0,0420 / 0,0460 | 19 / 21 | 0,875 |
| P2.DFI | MinP / MinP4 | 500 | 0,0860 / 0,0880 | 1 / 2 | 1 | 0,0380 / 0,0420 | 1 / 3 | 0,625 |
| P2.DFI | MinP / TMax | 500 | 0,0860 / 0,0880 | 35 / 36 | 1 | 0,0380 / 0,0420 | 17 / 19 | 0,868 |
| P2.DFI | TMax / MinP4 | 500 | 0,0880 / 0,0880 | 37 / 37 | 1 | 0,0420 / 0,0420 | 20 / 20 | 1 |
| P2.DFI | FWr / FWb | 500 | 0,0800 / 0,0700 | 12 / 7 | 0,359 | 0,0320 / 0,0280 | 4 / 2 | 0,687 |
| P2.DFI | FWr / BP | 500 | 0,0800 / 0,0720 | 20 / 16 | 0,618 | 0,0320 / 0,0320 | 5 / 5 | 1 |
| P2.DFI | FWb / BP | 500 | 0,0700 / 0,0720 | 9 / 10 | 1 | 0,0280 / 0,0320 | 1 / 3 | 0,625 |
| P3.H0 | MinP / Grubbs | 1000 | 0,0640 / 0,0920 | 43 / 71 | 0,0111 | 0,0370 / 0,0350 | 26 / 24 | 0,888 |
| P3.H0 | MinP4 / Grubbs | 1000 | 0,0640 / 0,0920 | 38 / 66 | 0,0078 | 0,0320 / 0,0350 | 20 / 23 | 0,761 |
| P3.H0 | TMax / Grubbs | 1000 | 0,0850 / 0,0920 | 75 / 82 | 0,632 | 0,0530 / 0,0350 | 50 / 32 | 0,0598 |
| P3.H0 | MinP / MinP4 | 1000 | 0,0640 / 0,0640 | 13 / 13 | 1 | 0,0370 / 0,0320 | 8 / 3 | 0,227 |
| P3.H0 | MinP / TMax | 1000 | 0,0640 / 0,0850 | 37 / 58 | 0,0396 | 0,0370 / 0,0530 | 23 / 39 | 0,0559 |
| P3.H0 | TMax / MinP4 | 1000 | 0,0850 / 0,0640 | 70 / 49 | 0,0663 | 0,0530 / 0,0320 | 46 / 25 | 0,017 |
| P3.H0 | FWr / FWb | 1000 | 0,0890 / 0,0760 | 40 / 27 | 0,142 | 0,0430 / 0,0340 | 19 / 10 | 0,136 |
| P3.H0 | FWr / BP | 1000 | 0,0890 / 0,0540 | 51 / 16 | 2,17e-05 | 0,0430 / 0,0160 | 32 / 5 | 7,43e-06 |
| P3.H0 | FWb / BP | 1000 | 0,0760 / 0,0540 | 22 / 0 | 4,77e-07 | 0,0340 / 0,0160 | 18 / 0 | 7,63e-06 |
| P3.CST20 | MinP / Grubbs | 1000 | 0,0080 / 0,0100 | 7 / 9 | 0,804 | 0,0020 / 0,0010 | 2 / 1 | 1 |
| P3.CST20 | MinP4 / Grubbs | 1000 | 0,0060 / 0,0100 | 5 / 9 | 0,424 | 0,0020 / 0,0010 | 2 / 1 | 1 |
| P3.CST20 | TMax / Grubbs | 1000 | 0,0430 / 0,0100 | 43 / 10 | 5,55e-06 | 0,0200 / 0,0010 | 20 / 1 | 2,1e-05 |
| P3.CST20 | MinP / MinP4 | 1000 | 0,0080 / 0,0060 | 2 / 0 | 0,5 | 0,0020 / 0,0020 | 1 / 1 | 1 |
| P3.CST20 | MinP / TMax | 1000 | 0,0080 / 0,0430 | 5 / 40 | 7,88e-08 | 0,0020 / 0,0200 | 1 / 19 | 4,01e-05 |
| P3.CST20 | TMax / MinP4 | 1000 | 0,0430 / 0,0060 | 42 / 5 | 2,46e-08 | 0,0200 / 0,0020 | 20 / 2 | 0,000121 |
| P3.CST20 | FWr / FWb | 1000 | 0,0010 / 0,0040 | 0 / 3 | 0,25 | 0,0000 / 0,0000 | 0 / 0 | 1 |
| P3.CST20 | FWr / BP | 1000 | 0,0010 / 0,0000 | 1 / 0 | 1 | 0,0000 / 0,0000 | 0 / 0 | 1 |
| P3.CST20 | FWb / BP | 1000 | 0,0040 / 0,0000 | 4 / 0 | 0,125 | 0,0000 / 0,0000 | 0 / 0 | 1 |
| P3.DFI | MinP / Grubbs | 500 | 0,0980 / 0,0980 | 23 / 23 | 1 | 0,0320 / 0,0520 | 9 / 19 | 0,0872 |
| P3.DFI | MinP4 / Grubbs | 500 | 0,0920 / 0,0980 | 23 / 26 | 0,775 | 0,0320 / 0,0520 | 9 / 19 | 0,0872 |
| P3.DFI | TMax / Grubbs | 500 | 0,0900 / 0,0980 | 38 / 42 | 0,738 | 0,0460 / 0,0520 | 19 / 22 | 0,755 |
| P3.DFI | MinP / MinP4 | 500 | 0,0980 / 0,0920 | 5 / 2 | 0,453 | 0,0320 / 0,0320 | 1 / 1 | 1 |
| P3.DFI | MinP / TMax | 500 | 0,0980 / 0,0900 | 38 / 34 | 0,724 | 0,0320 / 0,0460 | 13 / 20 | 0,296 |
| P3.DFI | TMax / MinP4 | 500 | 0,0900 / 0,0920 | 39 / 40 | 1 | 0,0460 / 0,0320 | 21 / 14 | 0,311 |
| P3.DFI | FWr / FWb | 500 | 0,0820 / 0,0740 | 16 / 12 | 0,572 | 0,0420 / 0,0340 | 14 / 10 | 0,541 |
| P3.DFI | FWr / BP | 500 | 0,0820 / 0,0600 | 21 / 10 | 0,0708 | 0,0420 / 0,0220 | 15 / 5 | 0,0414 |
| P3.DFI | FWb / BP | 500 | 0,0740 / 0,0600 | 10 / 3 | 0,0923 | 0,0340 / 0,0220 | 6 / 0 | 0,0313 |

### T4 — cellule désignée par chaque statistique de M4 (cellule visée : (i, j) = (2, 1), coordonnées de résidus de Mack)

Part des triangles admis dont la cellule désignée à l'observé est (2, 1) : Grubbs (résidu de plus grande valeur absolue centrée), MinP et MinP4 (cellule de p_ij minimale), TMax (cellule de |t| maximal) ; IC de Clopper-Pearson à 95 %. H0 : référence de désignation par hasard (la cellule n'est pas ciblee). « Parmi les rejets » : même part sur les triangles où la statistique rejette à 0,10 (p_mc < 0,10).

| Cellule | n | Statistique | désigne (2, 1) [IC] | rejets à 0,10 | désigne (2, 1) parmi les rejets [IC] |
| --- | --- | --- | --- | --- | --- |
| P1.H0 | 1000 | Grubbs | 0,05600 [0,04258 ; 0,07211] | 83 | 0,06024 [0,01985 ; 0,13501] |
| P1.H0 | 1000 | MinP | 0,04100 [0,02958 ; 0,05521] | 46 | 0,08696 [0,02420 ; 0,20792] |
| P1.H0 | 1000 | MinP4 | 0,04800 [0,03560 ; 0,06314] | 54 | 0,09259 [0,03075 ; 0,20300] |
| P1.H0 | 1000 | TMax | 0,01600 [0,00917 ; 0,02585] | 38 | 0,00000 [0,00000 ; 0,09251] |
| P1.CEL4 | 1000 | Grubbs | 0,65000 [0,61953 ; 0,67958] | 211 | 0,56398 [0,49420 ; 0,63194] |
| P1.CEL4 | 1000 | MinP | 0,62000 [0,58910 ; 0,65019] | 139 | 0,76259 [0,68306 ; 0,83060] |
| P1.CEL4 | 1000 | MinP4 | 0,64100 [0,61039 ; 0,67078] | 183 | 0,77049 [0,70270 ; 0,82931] |
| P1.CEL4 | 1000 | TMax | 0,33000 [0,30089 ; 0,36011] | 35 | 0,00000 [0,00000 ; 0,10003] |
| P1.CEL6 | 1000 | Grubbs | 0,84800 [0,82423 ; 0,86970] | 372 | 0,80376 [0,75971 ; 0,84291] |
| P1.CEL6 | 1000 | MinP | 0,85100 [0,82740 ; 0,87251] | 349 | 0,93123 [0,89940 ; 0,95545] |
| P1.CEL6 | 1000 | MinP4 | 0,86400 [0,84118 ; 0,88465] | 426 | 0,92488 [0,89561 ; 0,94806] |
| P1.CEL6 | 1000 | TMax | 0,55100 [0,51956 ; 0,58214] | 37 | 0,00000 [0,00000 ; 0,09489] |
| P1.CELx4 | 500 | Grubbs | 0,92400 [0,89717 ; 0,94566] | 316 | 0,89873 [0,86006 ; 0,92970] |
| P1.CELx4 | 500 | MinP | 1,00000 [0,99265 ; 1,00000] | 500 | 1,00000 [0,99265 ; 1,00000] |
| P1.CELx4 | 500 | MinP4 | 1,00000 [0,99265 ; 1,00000] | 500 | 1,00000 [0,99265 ; 1,00000] |
| P1.CELx4 | 500 | TMax | 0,92800 [0,90171 ; 0,94907] | 500 | 0,92800 [0,90171 ; 0,94907] |

### T5 — décomposition de BP sous H0 (par. 3.4)

Régression r² ~ C sur les cellules de e$res (27 sur reserve2). S_xx entre colonnes = Σ n_j (C̄_j − C̄)² ; S_xy entre colonnes = Σ n_j (C̄_j − C̄)(r̄²_j − r̄²) ; intra colonne : somme des produits des écarts à la moyenne de colonne. nR² de BP = n S_xy² / (S_xx S_yy) ; « nR² entre » et « nR² intra » : la même forme avec S_xy entre (resp. intra) seul(e) (les deux ne s'additionnent pas : terme croisé) ; « part de S_xy entre » : S_xy entre / S_xy. « Écart de contrainte » : max_j |moyenne de colonne de r² − (n_j − 1)/n_j| (identité exacte Σ_i r(i,j)² = n_j − 1, attendue ~ 1e-15). « Écart au BP observé » : max |n S_xy² / (S_xx S_yy) − obs:BP| sur les triangles du jeu (contrôle, seuil 1e-10 : un dépassement fait refuser la combinaison). Moyenne [écart-type] sur les triangles admis du jeu. Le mécanisme de #301 est une hypothèse [H] que ce tableau confirme ou non.

| Jeu | n triangles | part de S_xx entre colonnes | part de S_xy entre | S_xy entre | S_xy intra | nR² de BP | nR² entre | nR² intra | écart de contrainte max | écart au BP observé max |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| volet A, loi N (P1, H0) | 2000 | 0,9920 [0,0032] | 1,0251 [0,1822] | -1858,0094 [44,2652] | -7,0602 [305,1612] | 0,3162 [0,1327] | 0,3069 [0,0876] | 0,0079 [0,0119] | 7.77e-16 | 2.53e-15 |
| volet A, loi E (P1, H0) | 2000 | 0,9919 [0,0031] | 1,0097 [0,1664] | -1858,2416 [44,8502] | -29,1414 [295,3404] | 0,4125 [0,1859] | 0,3921 [0,1391] | 0,0092 [0,0139] | 5.55e-16 | 3.77e-15 |
| volet A, loi A (P1, H0) | 1000 | 0,9919 [0,0029] | 1,0336 [0,2163] | -1855,7366 [42,8286] | -6,6397 [324,9942] | 0,2976 [0,1320] | 0,2881 [0,0950] | 0,0081 [0,0110] | 6.66e-16 | 1.83e-15 |
| P1.H0 | 1000 | 0,9919 [0,0031] | 1,0199 [0,1860] | -1859,0133 [44,2741] | -17,9900 [307,5629] | 0,3204 [0,1358] | 0,3066 [0,0857] | 0,0082 [0,0121] | 6.66e-16 | 2.44e-15 |
| P2.H0 | 1000 | 0,8848 [0,0133] | 1,5268 [18,3651] | -1286,6573 [39,6992] | -201,6124 [978,6300] | 0,4250 [0,4235] | 0,2322 [0,0711] | 0,1327 [0,1799] | 6.66e-16 | 3.33e-15 |
| P3.H0 | 1000 | 0,7956 [0,0150] | 1,1968 [4,5596] | -2271,8646 [49,0465] | -806,5931 [1719,3981] | 0,5972 [0,5343] | 0,2603 [0,0735] | 0,1702 [0,2179] | 5.55e-16 | 2.78e-15 |

### T6 — niveau des p non simulées (volet A) : χ²(1) des variantes de #301, Bonferroni de #300, Grubbs

Taux k / n de rejets p < α sur les triangles admis, IC de Clopper-Pearson à 95 % ; référence **nominale α** (une p non simulée n'a pas d'oracle) ; classe de #166 contre α à titre descriptif. Ces p ne sont **jamais retenues** (#181) : la p retenue est la p Monte-Carlo (T1).

| Loi | p non simulée | loi de référence | n | abs. 0,10 | taux [IC] 0,10 | classe vs 0,10 | abs. 0,05 | taux [IC] 0,05 | classe vs 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | BP | chi2(1) | 2000 | 0 | 0,00000 [0,00000 ; 0,00184] | distorsion matérielle (**conservateur**) | 0 | 0,00000 [0,00000 ; 0,00184] | distorsion matérielle (**conservateur**) |
| N | FWb | chi2(1) | 2000 | 0 | 0,10800 [0,09473 ; 0,12243] | compatible | 0 | 0,05450 [0,04496 ; 0,06537] | compatible |
| N | FWr | chi2(1) | 2000 | 0 | 0,12500 [0,11081 ; 0,14030] | écart mineur | 0 | 0,06750 [0,05690 ; 0,07939] | écart mineur |
| N | Grubbs | Student + Bonferroni (test_grubbs()) | 2000 | 0 | 0,00000 [0,00000 ; 0,00184] | distorsion matérielle (**conservateur**) | 0 | 0,00000 [0,00000 ; 0,00184] | distorsion matérielle (**conservateur**) |
| N | MinP | Bonferroni N_t M | 2000 | 0 | 0,10700 [0,09379 ; 0,12138] | compatible | 0 | 0,05750 [0,04770 ; 0,06862] | compatible |
| N | MinP4 | Bonferroni N_t M | 2000 | 0 | 0,10650 [0,09331 ; 0,12085] | compatible | 0 | 0,05950 [0,04953 ; 0,07078] | compatible |
| E | BP | chi2(1) | 2000 | 0 | 0,00000 [0,00000 ; 0,00184] | distorsion matérielle (**conservateur**) | 0 | 0,00000 [0,00000 ; 0,00184] | distorsion matérielle (**conservateur**) |
| E | FWb | chi2(1) | 2000 | 0 | 0,12950 [0,11509 ; 0,14501] | écart mineur | 0 | 0,06600 [0,05551 ; 0,07778] | écart mineur |
| E | FWr | chi2(1) | 2000 | 0 | 0,14250 [0,12746 ; 0,15859] | écart mineur | 0 | 0,07450 [0,06337 ; 0,08689] | écart mineur |
| E | Grubbs | Student + Bonferroni (test_grubbs()) | 2000 | 0 | 0,00000 [0,00000 ; 0,00184] | distorsion matérielle (**conservateur**) | 0 | 0,00000 [0,00000 ; 0,00184] | distorsion matérielle (**conservateur**) |
| E | MinP | Bonferroni N_t M | 2000 | 0 | 0,16850 [0,15234 ; 0,18564] | distorsion matérielle (**libéral**) | 0 | 0,10050 [0,08767 ; 0,11452] | distorsion matérielle (**libéral**) |
| E | MinP4 | Bonferroni N_t M | 2000 | 0 | 0,14050 [0,12556 ; 0,15651] | écart mineur | 0 | 0,09000 [0,07782 ; 0,10340] | distorsion matérielle (**libéral**) |
| A | BP | chi2(1) | 1000 | 0 | 0,00000 [0,00000 ; 0,00368] | distorsion matérielle (**conservateur**) | 0 | 0,00000 [0,00000 ; 0,00368] | distorsion matérielle (**conservateur**) |
| A | FWb | chi2(1) | 1000 | 0 | 0,11500 [0,09588 ; 0,13642] | compatible | 0 | 0,06300 [0,04875 ; 0,07989] | compatible |
| A | FWr | chi2(1) | 1000 | 0 | 0,12900 [0,10884 ; 0,15137] | écart mineur | 0 | 0,07100 [0,05586 ; 0,08872] | écart mineur |
| A | Grubbs | Student + Bonferroni (test_grubbs()) | 1000 | 0 | 0,00000 [0,00000 ; 0,00368] | distorsion matérielle (**conservateur**) | 0 | 0,00000 [0,00000 ; 0,00368] | distorsion matérielle (**conservateur**) |
| A | MinP | Bonferroni N_t M | 1000 | 0 | 0,24600 [0,21959 ; 0,27392] | distorsion matérielle (**libéral**) | 0 | 0,14100 [0,12001 ; 0,16413] | distorsion matérielle (**libéral**) |
| A | MinP4 | Bonferroni N_t M | 1000 | 0 | 0,25600 [0,22920 ; 0,28424] | distorsion matérielle (**libéral**) | 0 | 0,14700 [0,12562 ; 0,17048] | distorsion matérielle (**libéral**) |

### T7 — grandeurs pour Fj (par. 6 ; #308, #307)

**(a) CV intra-colonne réalisé par colonne** (sd / moyenne de C(0..I−j−1, j), moyenne sur les triangles admis de la cellule H0 de chaque plan) ; colonnes j = 0 à 5 (j = 6 : une cellule).

| Plan | n | j = 0 | j = 1 | j = 2 | j = 3 | j = 4 | j = 5 | moyenne j = 0 à 3 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P1 | 1000 | 0,0739 | 0,0666 | 0,0591 | 0,0517 | 0,0437 | 0,0336 | 0,0628 |
| P2 | 1000 | 0,2618 | 0,2419 | 0,2194 | 0,1926 | 0,1622 | 0,1242 | 0,2289 |
| P3 | 1000 | 0,2335 | 0,2424 | 0,2725 | 0,2800 | 0,3198 | 0,4594 | 0,2571 |

**(b) Colinéarité volume / année** (par. 2.2) : corrélation de Pearson et de Spearman entre l'année de survenance i et C(i, 0) de la première colonne fixée, lignes 0..7 puis 0..6 (celles qui portent un facteur de j = 0).

| Plan | Pearson, lignes 0..7 | Spearman, lignes 0..7 | Pearson, lignes 0..6 | Spearman, lignes 0..6 |
| --- | --- | --- | --- | --- |
| P1 | 1,000 | 1,000 | 1,000 | 1,000 |
| P2 | 1,000 | 1,000 | 1,000 | 1,000 |
| P3 | -0,190 | -0,190 | 0,214 | 0,214 |

**(c) Puissance de M1, M2 et des variantes de BP contre CST, EXP et DFI selon le plan** (taux de rejet p_mc < 0,10 [IC de Clopper-Pearson], cellules des plans P1, P2, P3 ; — : cellule non mesurée).

| Statistique | Scénario | P1 | P2 | P3 |
| --- | --- | --- | --- | --- |
| Origine (haut) | H0 | 0,09600 [0,07845 ; 0,11597] | 0,09600 [0,07845 ; 0,11597] | 0,10500 [0,08668 ; 0,12568] |
| Origine (haut) | CST10 | 0,27200 [0,23344 ; 0,31328] | 1,00000 [0,99265 ; 1,00000] | — |
| Origine (haut) | CST20 | 0,68300 [0,65315 ; 0,71177] | 1,00000 [0,99632 ; 1,00000] | 1,00000 [0,99632 ; 1,00000] |
| Origine (haut) | EXP0 | 0,09600 [0,07163 ; 0,12526] | 0,14800 [0,11803 ; 0,18220] | — |
| Origine (haut) | EXP2 | 0,08800 [0,07118 ; 0,10729] | 0,09000 [0,07299 ; 0,10947] | — |
| Origine (haut) | DFI | 0,19600 [0,16209 ; 0,23355] | 0,18200 [0,14914 ; 0,21867] | 0,09000 [0,06640 ; 0,11857] |
| PenteIntra (deux) | H0 | 0,12200 [0,10235 ; 0,14390] | 0,11600 [0,09681 ; 0,13749] | 0,12900 [0,10884 ; 0,15137] |
| PenteIntra (deux) | CST10 | 0,33000 [0,28890 ; 0,37313] | 0,86200 [0,82863 ; 0,89102] | — |
| PenteIntra (deux) | CST20 | 0,52200 [0,49051 ; 0,55336] | 0,93200 [0,91459 ; 0,94681] | 1,00000 [0,99632 ; 1,00000] |
| PenteIntra (deux) | EXP0 | 0,11600 [0,08927 ; 0,14737] | 0,11400 [0,08749 ; 0,14517] | — |
| PenteIntra (deux) | EXP2 | 0,12800 [0,10791 ; 0,15031] | 0,12900 [0,10884 ; 0,15137] | — |
| PenteIntra (deux) | DFI | 0,17800 [0,14546 ; 0,21440] | 0,19800 [0,16394 ; 0,23567] | 0,12400 [0,09641 ; 0,15613] |
| Courbure (haut) | H0 | 0,09000 [0,07299 ; 0,10947] | 0,08900 [0,07208 ; 0,10838] | 0,10400 [0,08577 ; 0,12460] |
| Courbure (haut) | CST10 | 0,09200 [0,06814 ; 0,12081] | 0,08200 [0,05949 ; 0,10960] | — |
| Courbure (haut) | CST20 | 0,07800 [0,06214 ; 0,09639] | 0,09600 [0,07845 ; 0,11597] | 0,09200 [0,07481 ; 0,11164] |
| Courbure (haut) | EXP0 | 0,07800 [0,05605 ; 0,10509] | 0,08800 [0,06467 ; 0,11634] | — |
| Courbure (haut) | EXP2 | 0,08200 [0,06575 ; 0,10076] | 0,09500 [0,07754 ; 0,11488] | — |
| Courbure (haut) | DFI | 0,10400 [0,07865 ; 0,13414] | 0,11200 [0,08572 ; 0,14297] | 0,16200 [0,13078 ; 0,19728] |
| HomogF (haut) | H0 | 0,10600 [0,08760 ; 0,12675] | 0,10100 [0,08302 ; 0,12137] | 0,06400 [0,04963 ; 0,08100] |
| HomogF (haut) | CST10 | 0,26400 [0,22586 ; 0,30496] | 0,99200 [0,97964 ; 0,99782] | — |
| HomogF (haut) | CST20 | 0,61200 [0,58100 ; 0,64233] | 1,00000 [0,99632 ; 1,00000] | 0,00000 [0,00000 ; 0,00368] |
| HomogF (haut) | EXP0 | 0,10600 [0,08041 ; 0,13635] | 0,10000 [0,07514 ; 0,12971] | — |
| HomogF (haut) | EXP2 | 0,08500 [0,06846 ; 0,10403] | 0,08800 [0,07118 ; 0,10729] | — |
| HomogF (haut) | DFI | 0,21400 [0,17883 ; 0,25259] | 0,19000 [0,15653 ; 0,22718] | 0,20800 [0,17324 ; 0,24626] |
| ExpVar (haut) | H0 | 0,09100 [0,07390 ; 0,11055] | 0,08900 [0,07208 ; 0,10838] | 0,08200 [0,06575 ; 0,10076] |
| ExpVar (haut) | CST10 | 0,07600 [0,05434 ; 0,10283] | 0,01400 [0,00565 ; 0,02863] | — |
| ExpVar (haut) | CST20 | 0,04600 [0,03387 ; 0,06088] | 0,00100 [0,00003 ; 0,00556] | 0,00000 [0,00000 ; 0,00368] |
| ExpVar (haut) | EXP0 | 0,09200 [0,06814 ; 0,12081] | 0,08000 [0,05777 ; 0,10735] | — |
| ExpVar (haut) | EXP2 | 0,09800 [0,08028 ; 0,11813] | 0,09100 [0,07390 ; 0,11055] | — |
| ExpVar (haut) | DFI | 0,07400 [0,05264 ; 0,10056] | 0,08400 [0,06121 ; 0,11185] | 0,10000 [0,07514 ; 0,12971] |
| BP (haut) | H0 | 0,02200 [0,01384 ; 0,03312] | 0,06300 [0,04875 ; 0,07989] | 0,05400 [0,04082 ; 0,06987] |
| BP (haut) | CST10 | 0,00800 [0,00218 ; 0,02036] | 0,05200 [0,03425 ; 0,07527] | — |
| BP (haut) | CST20 | 0,00200 [0,00024 ; 0,00721] | 0,00600 [0,00220 ; 0,01301] | 0,00000 [0,00000 ; 0,00368] |
| BP (haut) | EXP0 | 0,02000 [0,00963 ; 0,03647] | 0,15400 [0,12349 ; 0,18867] | — |
| BP (haut) | EXP2 | 0,02200 [0,01384 ; 0,03312] | 0,02900 [0,01951 ; 0,04138] | — |
| BP (haut) | DFI | 0,02200 [0,01103 ; 0,03902] | 0,07200 [0,05093 ; 0,09829] | 0,06000 [0,04084 ; 0,08455] |
| FWb (haut) | H0 | 0,09000 [0,07299 ; 0,10947] | 0,09700 [0,07936 ; 0,11705] | 0,07600 [0,06034 ; 0,09420] |
| FWb (haut) | CST10 | 0,09800 [0,07338 ; 0,12749] | 0,16200 [0,13078 ; 0,19728] | — |
| FWb (haut) | CST20 | 0,09800 [0,08028 ; 0,11813] | 0,16100 [0,13874 ; 0,18527] | 0,00400 [0,00109 ; 0,01021] |
| FWb (haut) | EXP0 | 0,06400 [0,04418 ; 0,08915] | 0,16200 [0,13078 ; 0,19728] | — |
| FWb (haut) | EXP2 | 0,09400 [0,07663 ; 0,11380] | 0,08300 [0,06665 ; 0,10185] | — |
| FWb (haut) | DFI | 0,08400 [0,06121 ; 0,11185] | 0,07000 [0,04924 ; 0,09601] | 0,07400 [0,05264 ; 0,10056] |
| FWr (haut) | H0 | 0,09000 [0,07299 ; 0,10947] | 0,09400 [0,07663 ; 0,11380] | 0,08900 [0,07208 ; 0,10838] |
| FWr (haut) | CST10 | 0,09200 [0,06814 ; 0,12081] | 0,11200 [0,08572 ; 0,14297] | — |
| FWr (haut) | CST20 | 0,08000 [0,06394 ; 0,09858] | 0,08800 [0,07118 ; 0,10729] | 0,00100 [0,00003 ; 0,00556] |
| FWr (haut) | EXP0 | 0,07000 [0,04924 ; 0,09601] | 0,12400 [0,09641 ; 0,15613] | — |
| FWr (haut) | EXP2 | 0,09300 [0,07572 ; 0,11272] | 0,11200 [0,09312 ; 0,13320] | — |
| FWr (haut) | DFI | 0,08600 [0,06294 ; 0,11409] | 0,08000 [0,05777 ; 0,10735] | 0,08200 [0,05949 ; 0,10960] |
| PenteRel (deux) | H0 | 0,11800 [0,09865 ; 0,13963] | 0,11200 [0,09312 ; 0,13320] | 0,13700 [0,11628 ; 0,15988] |
| PenteRel (deux) | CST10 | 0,43400 [0,39006 ; 0,47873] | 0,94400 [0,92008 ; 0,96247] | — |
| PenteRel (deux) | CST20 | 0,79600 [0,76967 ; 0,82057] | 0,96700 [0,95397 ; 0,97718] | 1,00000 [0,99632 ; 1,00000] |
| PenteRel (deux) | EXP0 | 0,11600 [0,08927 ; 0,14737] | 0,10800 [0,08218 ; 0,13856] | — |
| PenteRel (deux) | EXP2 | 0,10900 [0,09036 ; 0,12998] | 0,12200 [0,10235 ; 0,14390] | — |
| PenteRel (deux) | DFI | 0,27000 [0,23154 ; 0,31120] | 0,27000 [0,23154 ; 0,31120] | 0,10800 [0,08218 ; 0,13856] |

**(d) Taux de rejet par colonne du t de Student de l'ordonnée à l'origine à l'observé** (mw_test_ordonnee_origine()$detail$p, p < α ; colonnes j = 0 à 4), à confronter aux effets minimaux détectables de #308 (20, 16, 26, 36 et 67 %).

| Cellule | α | n | j = 0 | j = 1 | j = 2 | j = 3 | j = 4 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| P1.H0 | 0,10 | 1000 | 0,09200 [0,07481 ; 0,11164] | 0,10400 [0,08577 ; 0,12460] | 0,09300 [0,07572 ; 0,11272] | 0,09500 [0,07754 ; 0,11488] | 0,10100 [0,08302 ; 0,12137] |
| P1.H0 | 0,05 | 1000 | 0,05700 [0,04345 ; 0,07322] | 0,06000 [0,04610 ; 0,07656] | 0,04300 [0,03129 ; 0,05749] | 0,04900 [0,03647 ; 0,06427] | 0,05200 [0,03908 ; 0,06764] |
| P1.CST20 | 0,10 | 1000 | 0,69500 [0,66542 ; 0,72343] | 0,34300 [0,31358 ; 0,37335] | 0,21100 [0,18609 ; 0,23762] | 0,18700 [0,16328 ; 0,21258] | 0,15700 [0,13499 ; 0,18105] |
| P1.CST20 | 0,05 | 1000 | 0,53800 [0,50653 ; 0,56925] | 0,20900 [0,18419 ; 0,23554] | 0,11400 [0,09496 ; 0,13534] | 0,10800 [0,08944 ; 0,12890] | 0,08000 [0,06394 ; 0,09858] |
| P1.EXP2 | 0,10 | 1000 | 0,09800 [0,08028 ; 0,11813] | 0,08500 [0,06846 ; 0,10403] | 0,10500 [0,08668 ; 0,12568] | 0,09100 [0,07390 ; 0,11055] | 0,09500 [0,07754 ; 0,11488] |
| P1.EXP2 | 0,05 | 1000 | 0,05300 [0,03995 ; 0,06876] | 0,02900 [0,01951 ; 0,04138] | 0,05100 [0,03821 ; 0,06651] | 0,04600 [0,03387 ; 0,06088] | 0,04600 [0,03387 ; 0,06088] |
| P1.CEL4 | 0,10 | 1000 | 0,09100 [0,07390 ; 0,11055] | 0,00600 [0,00220 ; 0,01301] | 0,09200 [0,07481 ; 0,11164] | 0,10200 [0,08394 ; 0,12245] | 0,10500 [0,08668 ; 0,12568] |
| P1.CEL4 | 0,05 | 1000 | 0,04100 [0,02958 ; 0,05521] | 0,00300 [0,00062 ; 0,00874] | 0,03400 [0,02366 ; 0,04719] | 0,04900 [0,03647 ; 0,06427] | 0,05900 [0,04521 ; 0,07545] |
| P1.CEL6 | 0,10 | 1000 | 0,09800 [0,08028 ; 0,11813] | 0,00000 [0,00000 ; 0,00368] | 0,11000 [0,09128 ; 0,13105] | 0,12500 [0,10513 ; 0,14711] | 0,12100 [0,10143 ; 0,14284] |
| P1.CEL6 | 0,05 | 1000 | 0,04900 [0,03647 ; 0,06427] | 0,00000 [0,00000 ; 0,00368] | 0,06900 [0,05408 ; 0,08652] | 0,05200 [0,03908 ; 0,06764] | 0,05400 [0,04082 ; 0,06987] |
| P1.CST10 | 0,10 | 500 | 0,29800 [0,25821 ; 0,34020] | 0,18200 [0,14914 ; 0,21867] | 0,18800 [0,15468 ; 0,22506] | 0,15600 [0,12531 ; 0,19083] | 0,10800 [0,08218 ; 0,13856] |
| P1.CST10 | 0,05 | 500 | 0,15800 [0,12713 ; 0,19298] | 0,10400 [0,07865 ; 0,13414] | 0,07800 [0,05605 ; 0,10509] | 0,08400 [0,06121 ; 0,11185] | 0,05000 [0,03262 ; 0,07293] |
| P1.EXP0 | 0,10 | 500 | 0,11200 [0,08572 ; 0,14297] | 0,10200 [0,07689 ; 0,13193] | 0,11800 [0,09105 ; 0,14956] | 0,11800 [0,09105 ; 0,14956] | 0,10800 [0,08218 ; 0,13856] |
| P1.EXP0 | 0,05 | 500 | 0,06000 [0,04084 ; 0,08455] | 0,04800 [0,03099 ; 0,07058] | 0,06600 [0,04586 ; 0,09144] | 0,04600 [0,02938 ; 0,06823] | 0,05200 [0,03425 ; 0,07527] |
| P1.DFI | 0,10 | 500 | 0,21000 [0,17510 ; 0,24837] | 0,18400 [0,15099 ; 0,22080] | 0,12400 [0,09641 ; 0,15613] | 0,12000 [0,09283 ; 0,15175] | 0,09200 [0,06814 ; 0,12081] |
| P1.DFI | 0,05 | 500 | 0,12200 [0,09462 ; 0,15394] | 0,09800 [0,07338 ; 0,12749] | 0,07800 [0,05605 ; 0,10509] | 0,05200 [0,03425 ; 0,07527] | 0,05200 [0,03425 ; 0,07527] |
| P1.CAL7 | 0,10 | 500 | 0,20800 [0,17324 ; 0,24626] | 0,18200 [0,14914 ; 0,21867] | 0,14000 [0,11079 ; 0,17354] | 0,13400 [0,10538 ; 0,16703] | 0,12000 [0,09283 ; 0,15175] |
| P1.CAL7 | 0,05 | 500 | 0,07000 [0,04924 ; 0,09601] | 0,07600 [0,05434 ; 0,10283] | 0,06800 [0,04755 ; 0,09373] | 0,08400 [0,06121 ; 0,11185] | 0,05800 [0,03918 ; 0,08224] |
| P1.CAL4 | 0,10 | 500 | 0,02400 [0,01246 ; 0,04155] | 0,09400 [0,06989 ; 0,12304] | 0,10200 [0,07689 ; 0,13193] | 0,15600 [0,12531 ; 0,19083] | 0,08200 [0,05949 ; 0,10960] |
| P1.CAL4 | 0,05 | 500 | 0,00000 [0,00000 ; 0,00735] | 0,03200 [0,01840 ; 0,05145] | 0,05400 [0,03588 ; 0,07760] | 0,09000 [0,06640 ; 0,11857] | 0,04800 [0,03099 ; 0,07058] |
| P1.DCAL | 0,10 | 500 | 0,47200 [0,42752 ; 0,51681] | 0,30400 [0,26394 ; 0,34639] | 0,17800 [0,14546 ; 0,21440] | 0,12200 [0,09462 ; 0,15394] | 0,10200 [0,07689 ; 0,13193] |
| P1.DCAL | 0,05 | 500 | 0,30600 [0,26586 ; 0,34845] | 0,18800 [0,15468 ; 0,22506] | 0,09200 [0,06814 ; 0,12081] | 0,06600 [0,04586 ; 0,09144] | 0,04600 [0,02938 ; 0,06823] |
| P1.LIG | 0,10 | 500 | 0,10600 [0,08041 ; 0,13635] | 0,00000 [0,00000 ; 0,00735] | 0,38200 [0,33922 ; 0,42618] | 0,32600 [0,28505 ; 0,36903] | 0,24600 [0,20885 ; 0,28619] |
| P1.LIG | 0,05 | 500 | 0,04800 [0,03099 ; 0,07058] | 0,00000 [0,00000 ; 0,00735] | 0,20800 [0,17324 ; 0,24626] | 0,20000 [0,16580 ; 0,23779] | 0,10400 [0,07865 ; 0,13414] |
| P1.CELx4 | 0,10 | 500 | 0,12400 [0,09641 ; 0,15613] | 0,00000 [0,00000 ; 0,00735] | 1,00000 [0,99265 ; 1,00000] | 0,95400 [0,93177 ; 0,97062] | 0,64400 [0,60028 ; 0,68601] |
| P1.CELx4 | 0,05 | 500 | 0,05400 [0,03588 ; 0,07760] | 0,00000 [0,00000 ; 0,00735] | 1,00000 [0,99265 ; 1,00000] | 0,77600 [0,73688 ; 0,81182] | 0,36000 [0,31786 ; 0,40380] |
| P2.H0 | 0,10 | 1000 | 0,10400 [0,08577 ; 0,12460] | 0,11100 [0,09220 ; 0,13213] | 0,10600 [0,08760 ; 0,12675] | 0,11200 [0,09312 ; 0,13320] | 0,09300 [0,07572 ; 0,11272] |
| P2.H0 | 0,05 | 1000 | 0,05000 [0,03734 ; 0,06539] | 0,05800 [0,04433 ; 0,07434] | 0,05700 [0,04345 ; 0,07322] | 0,05800 [0,04433 ; 0,07434] | 0,04600 [0,03387 ; 0,06088] |
| P2.CST20 | 0,10 | 1000 | 1,00000 [0,99632 ; 1,00000] | 0,99700 [0,99126 ; 0,99938] | 0,83200 [0,80736 ; 0,85467] | 0,59000 [0,55879 ; 0,62068] | 0,31800 [0,28921 ; 0,34787] |
| P2.CST20 | 0,05 | 1000 | 1,00000 [0,99632 ; 1,00000] | 0,97400 [0,96213 ; 0,98295] | 0,64900 [0,61851 ; 0,67861] | 0,37500 [0,34490 ; 0,40584] | 0,16400 [0,14157 ; 0,18843] |
| P2.EXP2 | 0,10 | 1000 | 0,09500 [0,07754 ; 0,11488] | 0,06700 [0,05230 ; 0,08431] | 0,09800 [0,08028 ; 0,11813] | 0,10300 [0,08485 ; 0,12352] | 0,10700 [0,08852 ; 0,12783] |
| P2.EXP2 | 0,05 | 1000 | 0,05500 [0,04170 ; 0,07099] | 0,03600 [0,02534 ; 0,04949] | 0,04700 [0,03474 ; 0,06201] | 0,05500 [0,04170 ; 0,07099] | 0,05600 [0,04258 ; 0,07211] |
| P2.CST10 | 0,10 | 500 | 0,98400 [0,96872 ; 0,99307] | 0,79600 [0,75797 ; 0,83048] | 0,52200 [0,47720 ; 0,56654] | 0,40600 [0,36262 ; 0,45050] | 0,27800 [0,23914 ; 0,31951] |
| P2.CST10 | 0,05 | 500 | 0,95600 [0,93414 ; 0,97222] | 0,66000 [0,61663 ; 0,70147] | 0,33400 [0,29275 ; 0,37723] | 0,23200 [0,19568 ; 0,27152] | 0,15600 [0,12531 ; 0,19083] |
| P2.EXP0 | 0,10 | 500 | 0,12200 [0,09462 ; 0,15394] | 0,12400 [0,09641 ; 0,15613] | 0,11600 [0,08927 ; 0,14737] | 0,12400 [0,09641 ; 0,15613] | 0,10800 [0,08218 ; 0,13856] |
| P2.EXP0 | 0,05 | 500 | 0,06200 [0,04251 ; 0,08685] | 0,07000 [0,04924 ; 0,09601] | 0,06000 [0,04084 ; 0,08455] | 0,05200 [0,03425 ; 0,07527] | 0,06200 [0,04251 ; 0,08685] |
| P2.DFI | 0,10 | 500 | 0,22000 [0,18444 ; 0,25891] | 0,16200 [0,13078 ; 0,19728] | 0,15200 [0,12167 ; 0,18652] | 0,09000 [0,06640 ; 0,11857] | 0,10200 [0,07689 ; 0,13193] |
| P2.DFI | 0,05 | 500 | 0,12000 [0,09283 ; 0,15175] | 0,08600 [0,06294 ; 0,11409] | 0,08000 [0,05777 ; 0,10735] | 0,03800 [0,02303 ; 0,05871] | 0,03600 [0,02147 ; 0,05630] |
| P3.H0 | 0,10 | 1000 | 0,09200 [0,07481 ; 0,11164] | 0,10200 [0,08394 ; 0,12245] | 0,11000 [0,09128 ; 0,13105] | 0,10200 [0,08394 ; 0,12245] | 0,09800 [0,08028 ; 0,11813] |
| P3.H0 | 0,05 | 1000 | 0,05000 [0,03734 ; 0,06539] | 0,04300 [0,03129 ; 0,05749] | 0,06200 [0,04786 ; 0,07878] | 0,05000 [0,03734 ; 0,06539] | 0,04700 [0,03474 ; 0,06201] |
| P3.CST20 | 0,10 | 1000 | 1,00000 [0,99632 ; 1,00000] | 0,99800 [0,99279 ; 0,99976] | 0,96900 [0,95628 ; 0,97884] | 0,94000 [0,92344 ; 0,95390] | 0,75300 [0,72505 ; 0,77945] |
| P3.CST20 | 0,05 | 1000 | 1,00000 [0,99632 ; 1,00000] | 0,98400 [0,97415 ; 0,99083] | 0,86200 [0,83906 ; 0,88279] | 0,74000 [0,71163 ; 0,76695] | 0,44400 [0,41291 ; 0,47542] |
| P3.DFI | 0,10 | 500 | 0,09800 [0,07338 ; 0,12749] | 0,08000 [0,05777 ; 0,10735] | 0,10200 [0,07689 ; 0,13193] | 0,07800 [0,05605 ; 0,10509] | 0,10600 [0,08041 ; 0,13635] |
| P3.DFI | 0,05 | 500 | 0,04800 [0,03099 ; 0,07058] | 0,03600 [0,02147 ; 0,05630] | 0,05200 [0,03425 ; 0,07527] | 0,04200 [0,02618 ; 0,06349] | 0,05400 [0,03588 ; 0,07760] |

### T8 — triangles refusés, B effectif, retirage de #257, durées

| Jeu | triangles | admis | refusés | part refusée | motifs de refus | B eff. minimal | part des (triangle, statistique) à B eff. < B | triangles à triangle retiré / plafond atteint | durée par triangle admis (s) : moy. [méd. ; max] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| volet A, loi A (P1, H0) | 1000 | 1000 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 7,1 [6,7 ; 32,8] |
| volet A, loi E (P1, H0) | 2000 | 2000 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 6,9 [6,4 ; 35,9] |
| volet A, loi N (P1, H0) | 2000 | 2000 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 6,3 [5,9 ; 27,9] |
| P1.CAL4 | 500 | 500 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 38,3 [37,8 ; 74,2] |
| P1.CAL7 | 500 | 500 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 37,6 [36,5 ; 73,6] |
| P1.CEL4 | 1000 | 1000 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 21,3 [21,0 ; 40,9] |
| P1.CEL6 | 1000 | 1000 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 22,0 [22,0 ; 41,9] |
| P1.CELx4 | 500 | 500 | 0 | 0,00000 | aucun | 999 | 0,00000 | 13 / 0 | 39,5 [38,7 ; 78,9] |
| P1.CST10 | 500 | 500 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 30,4 [31,5 ; 60,8] |
| P1.CST20 | 1000 | 1000 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 23,5 [23,1 ; 44,0] |
| P1.DCAL | 500 | 500 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 36,7 [36,1 ; 72,5] |
| P1.DFI | 500 | 500 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 35,1 [34,3 ; 64,6] |
| P1.EXP0 | 500 | 500 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 33,9 [33,3 ; 63,1] |
| P1.EXP2 | 1000 | 1000 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 21,3 [21,0 ; 42,7] |
| P1.H0 | 1000 | 1000 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 23,7 [23,4 ; 45,4] |
| P1.LIG | 500 | 500 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 39,1 [38,2 ; 74,8] |
| P2.CST10 | 500 | 500 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 32,6 [32,0 ; 61,0] |
| P2.CST20 | 1000 | 1000 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 37,4 [36,7 ; 70,5] |
| P2.DFI | 500 | 500 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 32,9 [32,4 ; 61,2] |
| P2.EXP0 | 500 | 500 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 32,5 [31,9 ; 60,7] |
| P2.EXP2 | 1000 | 1000 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 35,5 [34,8 ; 68,1] |
| P2.H0 | 1000 | 1000 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 42,5 [41,8 ; 85,8] |
| P3.CST20 | 1000 | 1000 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 38,2 [37,5 ; 74,8] |
| P3.DFI | 500 | 500 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 39,9 [39,2 ; 80,5] |
| P3.H0 | 1000 | 1000 | 0 | 0,00000 | aucun | 999 | 0,00000 | 0 / 0 | 33,6 [33,0 ; 64,5] |
| oracle ORA-A-A | 20000 | 20000 | 0 | 0,00000 | aucun | — | — | — | — |
| oracle ORA-A-E | 20000 | 20000 | 0 | 0,00000 | aucun | — | — | — | — |
| oracle ORA-A-N | 20000 | 20000 | 0 | 0,00000 | aucun | — | — | — | — |
| oracle ORA-B-P2 | 20000 | 20000 | 0 | 0,00000 | aucun | — | — | — | — |
| oracle ORA-B-P3 | 20000 | 20000 | 0 | 0,00000 | aucun | — | — | — | — |

