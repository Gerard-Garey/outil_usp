## Mesure #206 : niveau réel à T = 8 des p-values Monte-Carlo de Merz-Wüthrich (+ #119) -- combinaison de 33 sortie(s)

### T0 — provenance (identique dans toutes les sorties, vérifié)

| Grandeur | Valeur |
| --- | --- |
| DGP sous H0 (par. 2) | modèle de Mack ajusté à reserve2 (mw_ajuster(), tests/donnees/triangle_mw.csv), I = J = 7 ; f̂ = (3,20372 ; 1,65175 ; 1,32525 ; 1,15042 ; 1,09469 ; 1,06455 ; 1,02841) ; σ̂² = (0,72404 ; 0,71209 ; 0,69814 ; 0,31478 ; 0,097325 ; 0,18967 ; 0,097325), dont σ̂²_6 extrapolé ; première colonne fixée (300,0000 ; 311,4286 ; 322,8571 ; 334,2857 ; 345,7143 ; 357,1429 ; 368,5714 ; 380,0000) ; colonnes dégénérées de reserve2 : 6 ; conformes aux valeurs arrondies du par. 2 : oui ; lois : N (stats::rnorm), E (loi uniforme sur les 27 valeurs de .mw_pool_residus(aj0, jd0) divisées par leur écart-type de population 0,9988 ; pool : asymétrie -0,159, excès de kurtosis -1,393, bornes [-1,588 ; 1,452], bornes après division [-1,590 ; 1,454]), A ((G − 2)/√2, G ~ Gamma(2) par stats::qgamma(stats::runif(n), 2)) ; générateur gen_triangle_h0() |
| Configuration | méthode reserve2, segment 1 de l'annexe II ; B = 999 (donnée du test calibré) ; α des verdicts = 0,10 ; seuils mesurés 0,10 et 0,05 ; chemin mesuré mw_bootstrap() + mw_tests() (identité à run_engine() : contrôle (i2)) ; B_MIN_DEGENERESCENCE = 50 |
| Graines (par. 7) | triangle b, loi ℓ : 20840000 + 10000 (ℓ − 1) + b ; bootstrap b, loi ℓ (les deux pools) : 20870000 + 10000 (ℓ − 1) + b ; oracle k, loi ℓ : 20900000 + 20000 (ℓ − 1) + k ; ℓ = 1 (N), 2 (E), 3 (A) ; contrôles sur reserve2 : 20260831 |
| Graines : recherche des collisions (graines calculées comprises) | plages triangles 20840001-20862000, bootstrap 20870001-20892000, oracle 20900001-20960000 (disjointes : oui) ; 20 littéraux de graine dans 47 fichiers (R/engine.R, tests/*.R, tests/unitaires/*.R), de 20260831 à 23700237 ; littéraux L dont [L ; L + 20000] touche une plage : aucun ; littéraux au-dessus des plages (sans collision ; annotation du 10/10/2026 de la spécification, point 1) : 23700237 ; littéraux en écriture scientifique non recherchés ; SEED_LOI_NULLE_SW 20260901, graine de reserve2 20260831 et réseau 20260831 + 1000 k ≤ 20760831 de tests/puissance_t8.R hors des plages : oui |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Commit | 3a95e11400f2e770c6d7242c88a9e67fd394ca28 |
| Plateforme de calcul (R, système, machine, BLAS, LAPACK) | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : libblas.so.3.12.0 ; LAPACK : liblapack.so.3.12.0 (version 3.12.0) |
| Empreintes md5 du code exécuté | R/engine.R 25bff84c7828b632fe2b260b64663c9f ; tests/outils_tests.R chargé (dépôt) 51bc8fdda7ec510da61e30a962d58512 ; script exécuté (dépôt) cf1692f76e665ae0118c6db20c7666cd ; docs/specifications/206-calibration-mc-merz-wuthrich.md 153ad280a7e26f72a87cd327d8e2f89c |
| Empreinte sans commentaires de R/engine.R (#231) et md5 du fichier entier | 9c8bf0d7971dd5fb215e5e30e1784591 (md5 du fichier entier 25bff84c7828b632fe2b260b64663c9f) |
| Contrôle (a) : reserve2 contre tests/reference/reserve2.rds | conforme ; 4410 feuille(s), 0 non strictement identique(s), écart maximal 0.000e+00 |
| Lignes de mw_tests() (ordre de reserve2) | Absence de tendance des facteurs avec le cumul, a colonne donnee ; Nullite de l'ordonnee a l'origine, colonne par colonne ; Homogeneite de f_j entre annees de survenance ; Absence de courbure de la regression ; Stabilite du facteur selon la ponderation (famille alpha) ; Heteroscedasticite residuelle vs cumul ; Adequation de l'exposant de variance, colonne par colonne ; Variance unitaire des residus de Mack ; Effets d'annee calendaire (test de Mack) ; Homogeneite des residus entre annees de survenance ; Correlation entre annees de developpement adjacentes ; Autocorrelation des residus (Durbin-Watson) ; Test des suites sur les residus de Mack ; Cellule aberrante du triangle (Grubbs) ; Cellules aberrantes multiples (ESD generalise) ; Shapiro-Wilk sur les residus de Mack ; Lilliefors sur les residus de Mack ; Extrapolation de sigma pour la derniere annee de developpement ; Part de la reserve portee par la derniere annee d'accident |
| Correspondance clé → ligne (contrôle (b)) | Calendrier=9 ; CorrDev=11 ; BP=6 ; Grubbs=14 ; DW=12 ; Runs=13 ; PenteIntra=1 ; Origine=2 ; HomogF=3 ; Courbure=4 ; Alpha=5 ; ExpVar=7 ; KruskalAcc=10 |
| Essai (--essai, non versionnable) | non |
| Locale LC_CTYPE des sorties (origine → travail) | C.UTF-8 → C.UTF-8 |
| Niveau de l'échelle (par. 8) et R | L0 (—) : N_red = 2000, E_red = 2000, N_brut = 1000, E_brut = 1000, A_red = 1000 ; N0 = 20000 par loi ; sous-mesure N sur 1..500 |
| Débit (ligne du JOURNAL) | c_b = 20,68 s ; P = 3,750 (4 processus ; P_k = 1,000 / 1,944 / 2,932 / 3,750) ; F = 1,66 h CPU ; N_max = 12765 ; durée planifiée 11,17 h (pré-vol du 2026-10-10, commit 3a95e11) |
| Triangles refusés par loi (par. 2 : signalé au-delà de 1 %) | N 0 / 2000 (0,00000) ; E 0 / 2000 (0,00000) ; A 0 / 1000 (0,00000) ; oracle N 0 / 20000 (0,00000) ; oracle E 0 / 20000 (0,00000) ; oracle A 0 / 20000 (0,00000) |
| ρ approché (plus de 1 % de statistiques oracle non finies pour la clé ; annotation du 10/10/2026, point 2 (a)) | aucune |
| Sorties combinées (nom, md5, plage, échantillon des contrôles) | oracle-A.txt d614980dbe8988f6a79adb45330021c8 (oracle A, 1-20000) ; oracle-E.txt 3243e66efd3f8981b047aea4ba52b19c (oracle E, 1-20000) ; oracle-N.txt 21c8a42f84657d7e3d05b29dc04b5628 (oracle N, 1-20000) ; sm-0001-0250.txt 9199ab85bccf43ec04a9483d7258b2b7 (sm N, 1-250, échantillon 1) ; sm-0251-0500.txt 7b2769f2197f578ecd02a9185bbe4ce8 (sm N, 251-500, échantillon 251) ; tranche-A-0001-0250.txt 123d6cef099b3c290e75ba8972f4a2db (tranche A, 1-250, échantillon 1) ; tranche-A-0251-0500.txt 2fe31ba9b4d5536031afb347953414f3 (tranche A, 251-500, échantillon 251) ; tranche-A-0501-0750.txt 5bf70a7f60911ec90c07e7bd3c492e21 (tranche A, 501-750, échantillon 501) ; tranche-A-0751-1000.txt 3db548bb8d79d8dad801404821638954 (tranche A, 751-1000, échantillon 751) ; tranche-E-0001-0125.txt 15a7964b83af1c35f55052959556d319 (tranche E, 1-125, échantillon 1) ; tranche-E-0126-0250.txt 8310f4656346c72c485364249224d01f (tranche E, 126-250, échantillon 126) ; tranche-E-0251-0375.txt a104b899ea3083a9d9f61a3cf1f5f929 (tranche E, 251-375, échantillon 251) ; tranche-E-0376-0500.txt 8d8f0a62e98cd70f8af1cb153eb2d7be (tranche E, 376-500, échantillon 376) ; tranche-E-0501-0625.txt 35a56add5c1bbc158f789e2dd3e34527 (tranche E, 501-625, échantillon 501) ; tranche-E-0626-0750.txt 2225e1da082e4d1555e9edbd9a531349 (tranche E, 626-750, échantillon 626) ; tranche-E-0751-0875.txt 558397b2e86272a9c9dcef2912305001 (tranche E, 751-875, échantillon 751) ; tranche-E-0876-1000.txt d51d18d9795e90d7a8e473b11d034cc5 (tranche E, 876-1000, échantillon 876) ; tranche-E-1001-1250.txt 1c55477b8795ba18540936f04e06ae56 (tranche E, 1001-1250, échantillon 1001) ; tranche-E-1251-1500.txt fb6b969c16580de5cf514f67df4a6f90 (tranche E, 1251-1500, échantillon 1251) ; tranche-E-1501-1750.txt bb376297e635ea89dd15ec3a0cb4409b (tranche E, 1501-1750, échantillon 1501) ; tranche-E-1751-2000.txt 6fffa196495f77ef9713b89e7799d123 (tranche E, 1751-2000, échantillon 1751) ; tranche-N-0001-0125.txt e779d775dd6e5d91fe8bb1237ccdb0bc (tranche N, 1-125, échantillon 1) ; tranche-N-0126-0250.txt 81b06f446989f8b941e7663377db644a (tranche N, 126-250, échantillon 126) ; tranche-N-0251-0375.txt 265986ad710c25e1b0e1536c4c8f7c14 (tranche N, 251-375, échantillon 251) ; tranche-N-0376-0500.txt 0eb0f8de32377ac75a02a8585698c053 (tranche N, 376-500, échantillon 376) ; tranche-N-0501-0625.txt 669a5d7f8b25183e38c38b57082c8653 (tranche N, 501-625, échantillon 501) ; tranche-N-0626-0750.txt d9372b0eee4c69792f1743bfe956ae77 (tranche N, 626-750, échantillon 626) ; tranche-N-0751-0875.txt 9b38e131aa9b4bcdd7d46b98c0947037 (tranche N, 751-875, échantillon 751) ; tranche-N-0876-1000.txt 5c8063b64eea58a2b41940255625a37d (tranche N, 876-1000, échantillon 876) ; tranche-N-1001-1250.txt 9818834486cab0da28b724fd1f24b574 (tranche N, 1001-1250, échantillon 1001) ; tranche-N-1251-1500.txt 4b13d97605c178f3351b7c656a4792b7 (tranche N, 1251-1500, échantillon 1251) ; tranche-N-1501-1750.txt f8a6956dfb2044bb938abc7e04a0531c (tranche N, 1501-1750, échantillon 1501) ; tranche-N-1751-2000.txt 76b436d4eafbfcf61ad1646cecb16c73 (tranche N, 1751-2000, échantillon 1751) |
| Échantillons oracle (non versionnés, régénérables par leurs graines) : md5 des valeurs | A : 3ba36d5cb35e0a426b5207042ded52c1 (fichier d614980dbe8988f6a79adb45330021c8) ; E : 0da3968ee9d9a5f73c3a8be1ec73b4b3 (fichier 3243e66efd3f8981b047aea4ba52b19c) ; N : 37e311edfc69d7206f90a741bf797168 (fichier 21c8a42f84657d7e3d05b29dc04b5628) |
| JOURNAL | JOURNAL.md (md5 cef76e86a1121e8f1631f7f00d13078d) : md5 des 33 sorties conformes ; lignes du débit et de l'empreinte (#231) lues ; niveau : L0 |
| Empreinte sans commentaires (#231) du JOURNAL | 9c8bf0d7971dd5fb215e5e30e1784591, égale à celle des sorties (contrôle (i3)) |
| Commit de la combinaison | 3a95e11400f2e770c6d7242c88a9e67fd394ca28 |
| Empreintes md5 du combinateur | R/engine.R 25bff84c7828b632fe2b260b64663c9f ; tests/outils_tests.R chargé (dépôt) 51bc8fdda7ec510da61e30a962d58512 ; script exécuté (dépôt) cf1692f76e665ae0118c6db20c7666cd ; docs/specifications/206-calibration-mc-merz-wuthrich.md 153ad280a7e26f72a87cd327d8e2f89c |
| Empreinte sans commentaires de R/engine.R à la combinaison (#231) | 9c8bf0d7971dd5fb215e5e30e1784591 |
| Valeurs brutes | 20261011-issue206-calibration-mw-brut.tsv : md5 c4c7ac003ff1f501034a2d96e17ae196, 5500 lignes (copie hors du dépôt : --brut) |
| Journal de la combinaison | 20261011-issue206-journal-combinaison.md |
| Versionnable (--ecrire) | oui |
| Contrôles d'intégrité | OK dans les 33 sorties ; invariants (d) relus sur les champs ; couvertures exactes ; (i3) : empreinte égale dans les sorties et à la combinaison |

### Aide à la lecture

Statut : **constat de simulation sous un plan** (modèle de Mack ajusté à reserve2), pas un résultat général ; il ne se transpose ni à une autre géométrie de triangle ni à un autre paramétrage. Aucun théorème ne couvre ce test bootstrap à T = 8 ; Dwass (1957) et Hope (1968) ne fondent que le témoin oracle. IC : Clopper-Pearson à 95 %, incertitude Monte-Carlo sur le taux (fonction de R), distincte de l'erreur de ρ (fonction de N0) et de err_mc (fonction de B = 999, donnée du test calibré). Bande de Bradley : convention de lecture (#166), pas théorème.

**Critère de la spécification (par. 5), reporté sans modification, évalué mécaniquement sans conclure :**

> ## 5. Critère, fixé avant toute exécution
> 
> Ce texte est reporté sans modification dans le script et au T0.
> 
> **Grandeurs.**
> - Décision D = 1 si p_mc < α.
> - **Une p absente compte comme un non-rejet.** Elle est comptée à part dans chaque cellule (#242), avec le taux sur les seules p définies en colonne descriptive.
> - Population : les triangles admis, b ∈ 1..R_(ℓ,pool).
> - τ = k/n, avec IC de Clopper-Pearson à 95 %.
> - **Classes de #166, avec ρ pour référence** :
>   - *compatible* : ρ ∈ IC ;
>   - *écart mineur* : estimation dans la bande de Bradley [ρ/2 ; 3ρ/2] ;
>   - *écart non tranché* : estimation hors de la bande, IC la recoupant ;
>   - *distorsion matérielle* : IC disjoint de la bande, avec son côté, libéral ou conservateur.
> - Classes calculées sur les valeurs **non arrondies** (#242, D-e).
> 
> **Conditions** (évaluées mécaniquement, **sans conclusion** dans le tableau) :
> - **K1, niveau, pool redressé** (critère principal) : classe de chaque (ℓ, s, α), pour ℓ ∈ {N, E}, et A si exécutée.
> - **K2, brut contre redressé** : pour b ≤ R_brut et pour chaque (ℓ, α), McNemar exact bilatéral (binomiale de paramètre 1/2 sur n01 + n10) et Holm (1979) à 0,05 sur la famille des 13 clés. On rapporte les classes du pool brut et les écarts |τ − ρ| des deux pools sur les mêmes triangles.
> - **K3, témoins** : pour chaque (ℓ, α), test binomial exact de τ_or contre sa taille, Holm sur 13. **Un témoin significatif suspend la lecture** jusqu'à explication.
> - **K4, p absentes** : part des triangles où au moins une des 13 p_mc manque. Au plus 1 % par (ℓ, pool) ; au-delà, point de décision.
> - **K5, B effectif** (descriptif) : distribution, minimum, part < 999, motifs (`motif_mc`).
> 
> **Profils de lecture proposés pour B3** (actuary propose, le mainteneur tranche) :
> 
> | Profil | Condition | Lecture proposée |
> |---|---|---|
> | Π0 | K3 ou K4 en défaut, non expliqué | Lecture suspendue ; mesure à reprendre |
> | Π1 | Sous N et E, les 13 lignes sont compatibles ou en écart mineur aux deux seuils | Constat documenté seul (rubrique 7, `sec:calibration-mc` volet MW) ; aucune évolution du moteur |
> | Π2 | Pas de distorsion matérielle, mais des écarts non tranchés | Constat documenté avec ses IC ; aucune évolution |
> | Π3 | Distorsion matérielle **conservatrice** sur une ligne (IC sous ρ/2) | Les OK de la ligne sont une preuve faible (puissance), et une p de `reserve2` proche du seuil est probablement trop grande. Documenter ; issue B4 éventuelle (correction de niveau), sans engagement de méthode |
> | Π4 | Distorsion matérielle **libérale** sur une ligne, pour une loi | Les ALERTE et ECHEC de la ligne surestiment la preuve, en particulier les ECHEC de `reserve2` (Courbure, Alpha, Calendrier, DW). Issue B4 proposée (correction de niveau ou passage en diagnostic) ; décision du mainteneur |
> | Π5 | Classes de sens opposés entre lois pour une ligne | Niveau non robuste à la loi des erreurs, qu'aucune correction calibrée sur une seule loi ne règle : documenter |
> 
> **Effet de #46 (K2).**
> - R1 : aucun McNemar significatif après Holm. Le redressement est sans effet mesurable sur le niveau.
> - R2 : effet significatif, qui rapproche τ de ρ. #46 est confortée.
> - R3 : effet qui éloigne τ de ρ. Point du mainteneur : la variante B de #46 est à revoir par une issue B4, pas dans cette branche.
> 
> **Lignes « à la frontière » de `reserve2`** (BP 0,103 ; Origine 0,085 ; HomogF 0,080) : elles sont lues avec leur τ.
> - Compatible : le verdict est celui d'un test calibré, au bruit Monte-Carlo près, et c'est l'objet de Q-206-9, tranchée en B3.
> - Conservateur : la p de `reserve2` surestime l'absence de preuve.
> - Libéral : l'inverse.
> - T4 donne, sous H0, la fréquence des cas |p_mc − α| < 2 err_mc par ligne, c'est-à-dire la fréquence à laquelle le signalement proposé se déclencherait.
> 
> **Multiplicité sous H0** (T4, descriptif) : part des triangles à au moins une ALERTE ou un ECHEC, et à au moins un ECHEC, sur les 13 lignes MC et sur toutes les lignes à verdict. Le repère 1 − (1 − α)^13 est un ordre de grandeur, pas une référence.

### Référence ρ et diagnostics de l'oracle (par. 4)

ρ : taille lissée à B = 999 du test de Monte-Carlo idéal tirant ses répliques dans F0 (règle « ≥ » d'engine_p_mc(), une règle unique pour toutes les statistiques, aucune classification a priori) ; statistique oracle non finie comptée comme non-rejet. Erreur de ρ due à N0 : de l'ordre de 0,002 à α = 0,10 [H], distincte de l'IC sur τ (fonction de R) et de err_mc (fonction de B). Taille du témoin : même règle à B = N0 fini, même dénominateur (oracle admis ; statistique non finie comptée comme non-rejet, comme pour ρ) ; nominale continue à B = nombre de statistiques finies entre parenthèses (un écart taille < nominale peut venir des non finies ou des atomes). ρ marqué « approché » au-delà de 1 % de statistiques oracle non finies pour la clé (ρ suppose alors B = 999 répliques finies ; annotation du 10/10/2026 de la spécification, point 2 (a)).

| Loi | Clé (sens) | oracle admis | non finies | valeurs distinctes | masse du plus gros atome | ρ 0,10 | ρ 0,05 | taille témoin 0,10 (nominale) | taille témoin 0,05 (nominale) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | Calendrier (deux) | 20000 | 0 | 84 | 0,10130 | 0,08601 | 0,04327 | 0,09008 (0,10000) | 0,04682 (0,05000) |
| N | CorrDev (deux) | 20000 | 0 | 1026 | 0,00415 | 0,09751 | 0,04761 | 0,09945 (0,10000) | 0,04962 (0,05000) |
| N | BP (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| N | Grubbs (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| N | DW (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 (0,10000) | 0,04995 (0,05000) |
| N | Runs (deux) | 20000 | 0 | 17 | 0,16825 | 0,05122 | 0,03020 | 0,04630 (0,10000) | 0,02814 (0,05000) |
| N | PenteIntra (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 (0,10000) | 0,04995 (0,05000) |
| N | Origine (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| N | HomogF (haut) | 20000 | 0 | 10898 | 0,00065 | 0,09896 | 0,04896 | 0,09996 (0,10000) | 0,04996 (0,05000) |
| N | Courbure (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| N | Alpha (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| N | ExpVar (haut) | 20000 | 0 | 10902 | 0,00080 | 0,09896 | 0,04897 | 0,09995 (0,10000) | 0,04996 (0,05000) |
| N | KruskalAcc (haut) | 20000 | 0 | 13636 | 0,00045 | 0,09896 | 0,04897 | 0,09996 (0,10000) | 0,04997 (0,05000) |
| E | Calendrier (deux) | 20000 | 0 | 86 | 0,10535 | 0,08646 | 0,04032 | 0,08942 (0,10000) | 0,04571 (0,05000) |
| E | CorrDev (deux) | 20000 | 0 | 1020 | 0,00345 | 0,09751 | 0,04760 | 0,09951 (0,10000) | 0,04964 (0,05000) |
| E | BP (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| E | Grubbs (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| E | DW (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 (0,10000) | 0,04995 (0,05000) |
| E | Runs (deux) | 20000 | 0 | 17 | 0,17745 | 0,05311 | 0,03103 | 0,04687 (0,10000) | 0,03639 (0,05000) |
| E | PenteIntra (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 (0,10000) | 0,04995 (0,05000) |
| E | Origine (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| E | HomogF (haut) | 20000 | 0 | 10796 | 0,00065 | 0,09896 | 0,04896 | 0,09995 (0,10000) | 0,04996 (0,05000) |
| E | Courbure (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| E | Alpha (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| E | ExpVar (haut) | 20000 | 0 | 10892 | 0,00065 | 0,09896 | 0,04896 | 0,09995 (0,10000) | 0,04996 (0,05000) |
| E | KruskalAcc (haut) | 20000 | 0 | 13623 | 0,00045 | 0,09896 | 0,04897 | 0,09996 (0,10000) | 0,04997 (0,05000) |
| A | Calendrier (deux) | 20000 | 0 | 83 | 0,09955 | 0,08603 | 0,04273 | 0,08819 (0,10000) | 0,04630 (0,05000) |
| A | CorrDev (deux) | 20000 | 0 | 1025 | 0,00395 | 0,09752 | 0,04762 | 0,09955 (0,10000) | 0,04961 (0,05000) |
| A | BP (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| A | Grubbs (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| A | DW (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 (0,10000) | 0,04995 (0,05000) |
| A | Runs (deux) | 20000 | 0 | 17 | 0,17475 | 0,05315 | 0,03181 | 0,04565 (0,10000) | 0,03604 (0,05000) |
| A | PenteIntra (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 (0,10000) | 0,04995 (0,05000) |
| A | Origine (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| A | HomogF (haut) | 20000 | 0 | 10793 | 0,00075 | 0,09896 | 0,04896 | 0,09995 (0,10000) | 0,04996 (0,05000) |
| A | Courbure (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| A | Alpha (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| A | ExpVar (haut) | 20000 | 0 | 10838 | 0,00070 | 0,09896 | 0,04896 | 0,09995 (0,10000) | 0,04996 (0,05000) |
| A | KruskalAcc (haut) | 20000 | 0 | 13715 | 0,00050 | 0,09896 | 0,04897 | 0,09996 (0,10000) | 0,04996 (0,05000) |

### Évaluation mécanique de K1 à K5, profils Π et R (sans conclusion)

Les états ci-dessous sont calculés par le script ; la lecture (et la part « non expliqué » de Π0) revient à actuary, la conséquence au mainteneur (B3).

| Condition | État mécanique | Détail |
| --- | --- | --- |
| K1 (niveau, pool redressé) | évaluée | N : compatible 20, écart mineur 4, écart non tranché 0, distorsion matérielle 2 ; E : compatible 18, écart mineur 8, écart non tranché 0, distorsion matérielle 0 ; A : compatible 18, écart mineur 3, écart non tranché 3, distorsion matérielle 2 |
| K2 (brut contre redressé, McNemar, Holm) | 5 McNemar significatif(s) après Holm | N Alpha 0,10 (0/107, p Holm 1,6e-31 ; \|τ_R − ρ\| 0,00103, \|τ_B − ρ\| 0,10802 : R2) ; N Alpha 0,05 (0/75, p Holm 6,88e-22 ; \|τ_R − ρ\| 0,01197, \|τ_B − ρ\| 0,06302 : R2) ; E BP 0,10 (0/18, p Holm 9,16e-05 ; \|τ_R − ρ\| 0,03597, \|τ_B − ρ\| 0,01797 : R3) ; E Alpha 0,10 (0/83, p Holm 2,69e-24 ; \|τ_R − ρ\| 0,00197, \|τ_B − ρ\| 0,08102 : R2) ; E Alpha 0,05 (0/65, p Holm 7,05e-19 ; \|τ_R − ρ\| 0,00598, \|τ_B − ρ\| 0,05903 : R2) |
| K3 (témoins oracle) | **témoin(s) significatif(s) : lecture suspendue jusqu'à explication** | N HomogF 0,05 (k = 71 / 2000, taille 0,04996, p Holm 0,0314) ; E Runs 0,05 (k = 44 / 2000, taille 0,03639, p Holm 0,00422) |
| K4 (p absentes, au plus 1 % par (loi, pool)) | remplie | N redressé 0,00000 (0 / 2000) ; N brut 0,00000 (0 / 1000) ; E redressé 0,00000 (0 / 2000) ; E brut 0,00000 (0 / 1000) ; A redressé 0,00000 (0 / 1000) |
| K5 (B effectif, descriptif) | descriptif | voir T5 |
| Refus des triangles (au-delà de 1 % : signalé, par. 2) | sous 1 % | N 0,00000 ; E 0,00000 ; A 0,00000 |

| Profil | Condition mécanique | Présent | Cellules |
| --- | --- | --- | --- |
| Π0 | K3 ou K4 en défaut (« non expliqué » : jugement d'actuary) | **oui** | voir K3 et K4 |
| Π1 | sous N et E, les 13 lignes compatibles ou en écart mineur aux deux seuils | non | N BP 0,10 ; N BP 0,05 |
| Π2 | aucune distorsion matérielle, mais des écarts non tranchés | non | A Grubbs 0,10 ; A Grubbs 0,05 ; A PenteIntra 0,05 |
| Π3 | distorsion matérielle conservatrice (IC sous ρ/2) | **oui** | N BP 0,10 ; N BP 0,05 ; A BP 0,10 ; A BP 0,05 |
| Π4 | distorsion matérielle libérale | non | aucune |
| Π5 | même clé et même seuil : distorsions matérielles de côtés opposés (libéral et conservateur) entre deux lois | non | aucune |

Indication descriptive, hors profil (lecture large de Π5, annotation du 10/10/2026 de la spécification, point 3) : même clé et même seuil, classes non compatibles de part et d'autre de ρ entre lois : Grubbs 0,10 ; Grubbs 0,05.

| Effet de #46 (K2) | Présent | Cellules |
| --- | --- | --- |
| R1 : aucun McNemar significatif après Holm | non | — |
| R2 : effet significatif qui rapproche τ de ρ (\|τ_R − ρ\| < \|τ_B − ρ\|) | **oui** | N Alpha 0,10 ; N Alpha 0,05 ; E Alpha 0,10 ; E Alpha 0,05 |
| R3 : effet significatif qui éloigne τ de ρ | **oui** | E BP 0,10 |

Lignes « à la frontière » de reserve2 (BP 0,103 ; Origine 0,085 ; HomogF 0,080), classe par loi et seuil : N BP 0,10 : distorsion matérielle ; N BP 0,05 : distorsion matérielle ; N Origine 0,10 : compatible ; N Origine 0,05 : compatible ; N HomogF 0,10 : compatible ; N HomogF 0,05 : écart mineur ; E BP 0,10 : écart mineur ; E BP 0,05 : écart mineur ; E Origine 0,10 : compatible ; E Origine 0,05 : compatible ; E HomogF 0,10 : compatible ; E HomogF 0,05 : compatible ; A BP 0,10 : distorsion matérielle ; A BP 0,05 : distorsion matérielle ; A Origine 0,10 : compatible ; A Origine 0,05 : compatible ; A HomogF 0,10 : compatible ; A HomogF 0,05 : compatible.

### T1 — niveau du pool redressé (critère principal K1)

Par seuil : n triangles admis, p absentes (comptées comme non-rejet), k rejets (p_mc < α), taux k / n et IC de Clopper-Pearson à 95 % (5 décimales), classe de #166 contre ρ (côté en gras si l'IC est disjoint de la bande [ρ/2 ; 3ρ/2]), taux sur les seules p définies (descriptif).

| Loi | Clé (sens) | n | abs. 0,10 | ρ 0,10 | k 0,10 | taux [IC] 0,10 | classe 0,10 | taux déf. 0,10 | abs. 0,05 | ρ 0,05 | k 0,05 | taux [IC] 0,05 | classe 0,05 | taux déf. 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | Calendrier (deux) | 2000 | 0 | 0,08601 | 172 | 0,08600 [0,07408 ; 0,09915] | compatible | 0,08600 | 0 | 0,04327 | 91 | 0,04550 [0,03679 ; 0,05557] | compatible | 0,04550 |
| N | CorrDev (deux) | 2000 | 0 | 0,09751 | 193 | 0,09650 [0,08391 ; 0,11029] | compatible | 0,09650 | 0 | 0,04761 | 103 | 0,05150 [0,04223 ; 0,06211] | compatible | 0,05150 |
| N | BP (haut) | 2000 | 0 | 0,09897 | 32 | 0,01600 [0,01097 ; 0,02251] | distorsion matérielle (**conservateur**) | 0,01600 | 0 | 0,04897 | 10 | 0,00500 [0,00240 ; 0,00918] | distorsion matérielle (**conservateur**) | 0,00500 |
| N | Grubbs (haut) | 2000 | 0 | 0,09897 | 198 | 0,09900 [0,08626 ; 0,11293] | compatible | 0,09900 | 0 | 0,04897 | 89 | 0,04450 [0,03589 ; 0,05448] | compatible | 0,04450 |
| N | DW (deux) | 2000 | 0 | 0,09795 | 171 | 0,08550 [0,07361 ; 0,09862] | compatible | 0,08550 | 0 | 0,04795 | 91 | 0,04550 [0,03679 ; 0,05557] | compatible | 0,04550 |
| N | Runs (deux) | 2000 | 0 | 0,05122 | 116 | 0,05800 [0,04816 ; 0,06916] | compatible | 0,05800 | 0 | 0,03020 | 55 | 0,02750 [0,02078 ; 0,03565] | compatible | 0,02750 |
| N | PenteIntra (deux) | 2000 | 0 | 0,09795 | 228 | 0,11400 [0,10040 ; 0,12875] | écart mineur | 0,11400 | 0 | 0,04795 | 128 | 0,06400 [0,05367 ; 0,07563] | écart mineur | 0,06400 |
| N | Origine (haut) | 2000 | 0 | 0,09897 | 176 | 0,08800 [0,07595 ; 0,10128] | compatible | 0,08800 | 0 | 0,04897 | 84 | 0,04200 [0,03364 ; 0,05174] | compatible | 0,04200 |
| N | HomogF (haut) | 2000 | 0 | 0,09896 | 191 | 0,09550 [0,08297 ; 0,10923] | compatible | 0,09550 | 0 | 0,04896 | 78 | 0,03900 [0,03095 ; 0,04844] | écart mineur | 0,03900 |
| N | Courbure (haut) | 2000 | 0 | 0,09897 | 186 | 0,09300 [0,08063 ; 0,10658] | compatible | 0,09300 | 0 | 0,04897 | 89 | 0,04450 [0,03589 ; 0,05448] | compatible | 0,04450 |
| N | Alpha (haut) | 2000 | 0 | 0,09897 | 191 | 0,09550 [0,08297 ; 0,10923] | compatible | 0,09550 | 0 | 0,04897 | 77 | 0,03850 [0,03050 ; 0,04789] | écart mineur | 0,03850 |
| N | ExpVar (haut) | 2000 | 0 | 0,09896 | 191 | 0,09550 [0,08297 ; 0,10923] | compatible | 0,09550 | 0 | 0,04897 | 92 | 0,04600 [0,03724 ; 0,05612] | compatible | 0,04600 |
| N | KruskalAcc (haut) | 2000 | 0 | 0,09896 | 192 | 0,09600 [0,08344 ; 0,10976] | compatible | 0,09600 | 0 | 0,04897 | 101 | 0,05050 [0,04132 ; 0,06103] | compatible | 0,05050 |
| E | Calendrier (deux) | 2000 | 0 | 0,08646 | 162 | 0,08100 [0,06941 ; 0,09383] | compatible | 0,08100 | 0 | 0,04032 | 82 | 0,04100 [0,03274 ; 0,05064] | compatible | 0,04100 |
| E | CorrDev (deux) | 2000 | 0 | 0,09751 | 199 | 0,09950 [0,08673 ; 0,11346] | compatible | 0,09950 | 0 | 0,04760 | 104 | 0,05200 [0,04268 ; 0,06266] | compatible | 0,05200 |
| E | BP (haut) | 2000 | 0 | 0,09897 | 139 | 0,06950 [0,05874 ; 0,08154] | écart mineur | 0,06950 | 0 | 0,04897 | 49 | 0,02450 [0,01818 ; 0,03226] | écart mineur | 0,02450 |
| E | Grubbs (haut) | 2000 | 0 | 0,09897 | 150 | 0,07500 [0,06384 ; 0,08743] | écart mineur | 0,07500 | 0 | 0,04897 | 70 | 0,03500 [0,02738 ; 0,04402] | écart mineur | 0,03500 |
| E | DW (deux) | 2000 | 0 | 0,09795 | 202 | 0,10100 [0,08814 ; 0,11505] | compatible | 0,10100 | 0 | 0,04795 | 106 | 0,05300 [0,04359 ; 0,06374] | compatible | 0,05300 |
| E | Runs (deux) | 2000 | 0 | 0,05311 | 105 | 0,05250 [0,04314 ; 0,06320] | compatible | 0,05250 | 0 | 0,03103 | 45 | 0,02250 [0,01646 ; 0,02999] | écart mineur | 0,02250 |
| E | PenteIntra (deux) | 2000 | 0 | 0,09795 | 241 | 0,12050 [0,10655 ; 0,13558] | écart mineur | 0,12050 | 0 | 0,04795 | 106 | 0,05300 [0,04359 ; 0,06374] | compatible | 0,05300 |
| E | Origine (haut) | 2000 | 0 | 0,09897 | 194 | 0,09700 [0,08438 ; 0,11082] | compatible | 0,09700 | 0 | 0,04897 | 95 | 0,04750 [0,03860 ; 0,05776] | compatible | 0,04750 |
| E | HomogF (haut) | 2000 | 0 | 0,09896 | 178 | 0,08900 [0,07688 ; 0,10234] | compatible | 0,08900 | 0 | 0,04896 | 83 | 0,04150 [0,03319 ; 0,05119] | compatible | 0,04150 |
| E | Courbure (haut) | 2000 | 0 | 0,09897 | 160 | 0,08000 [0,06848 ; 0,09277] | écart mineur | 0,08000 | 0 | 0,04897 | 72 | 0,03600 [0,02827 ; 0,04512] | écart mineur | 0,03600 |
| E | Alpha (haut) | 2000 | 0 | 0,09897 | 194 | 0,09700 [0,08438 ; 0,11082] | compatible | 0,09700 | 0 | 0,04897 | 84 | 0,04200 [0,03364 ; 0,05174] | compatible | 0,04200 |
| E | ExpVar (haut) | 2000 | 0 | 0,09896 | 190 | 0,09500 [0,08250 ; 0,10870] | compatible | 0,09500 | 0 | 0,04896 | 99 | 0,04950 [0,04041 ; 0,05994] | compatible | 0,04950 |
| E | KruskalAcc (haut) | 2000 | 0 | 0,09896 | 201 | 0,10050 [0,08767 ; 0,11452] | compatible | 0,10050 | 0 | 0,04897 | 98 | 0,04900 [0,03996 ; 0,05939] | compatible | 0,04900 |
| A | Calendrier (deux) | 1000 | 0 | 0,08603 | 84 | 0,08400 [0,06755 ; 0,10294] | compatible | 0,08400 | 0 | 0,04273 | 40 | 0,04000 [0,02873 ; 0,05407] | compatible | 0,04000 |
| A | CorrDev (deux) | 1000 | 0 | 0,09752 | 88 | 0,08800 [0,07118 ; 0,10729] | compatible | 0,08800 | 0 | 0,04762 | 44 | 0,04400 [0,03215 ; 0,05862] | compatible | 0,04400 |
| A | BP (haut) | 1000 | 0 | 0,09897 | 4 | 0,00400 [0,00109 ; 0,01021] | distorsion matérielle (**conservateur**) | 0,00400 | 0 | 0,04897 | 0 | 0,00000 [0,00000 ; 0,00368] | distorsion matérielle (**conservateur**) | 0,00000 |
| A | Grubbs (haut) | 1000 | 0 | 0,09897 | 159 | 0,15900 [0,13687 ; 0,18316] | écart non tranché | 0,15900 | 0 | 0,04897 | 88 | 0,08800 [0,07118 ; 0,10729] | écart non tranché | 0,08800 |
| A | DW (deux) | 1000 | 0 | 0,09795 | 87 | 0,08700 [0,07027 ; 0,10621] | compatible | 0,08700 | 0 | 0,04795 | 32 | 0,03200 [0,02199 ; 0,04488] | écart mineur | 0,03200 |
| A | Runs (deux) | 1000 | 0 | 0,05315 | 51 | 0,05100 [0,03821 ; 0,06651] | compatible | 0,05100 | 0 | 0,03181 | 32 | 0,03200 [0,02199 ; 0,04488] | compatible | 0,03200 |
| A | PenteIntra (deux) | 1000 | 0 | 0,09795 | 130 | 0,13000 [0,10977 ; 0,15244] | écart mineur | 0,13000 | 0 | 0,04795 | 73 | 0,07300 [0,05765 ; 0,09091] | écart non tranché | 0,07300 |
| A | Origine (haut) | 1000 | 0 | 0,09897 | 106 | 0,10600 [0,08760 ; 0,12675] | compatible | 0,10600 | 0 | 0,04897 | 61 | 0,06100 [0,04698 ; 0,07767] | compatible | 0,06100 |
| A | HomogF (haut) | 1000 | 0 | 0,09896 | 91 | 0,09100 [0,07390 ; 0,11055] | compatible | 0,09100 | 0 | 0,04896 | 41 | 0,04100 [0,02958 ; 0,05521] | compatible | 0,04100 |
| A | Courbure (haut) | 1000 | 0 | 0,09897 | 95 | 0,09500 [0,07754 ; 0,11488] | compatible | 0,09500 | 0 | 0,04897 | 41 | 0,04100 [0,02958 ; 0,05521] | compatible | 0,04100 |
| A | Alpha (haut) | 1000 | 0 | 0,09897 | 102 | 0,10200 [0,08394 ; 0,12245] | compatible | 0,10200 | 0 | 0,04897 | 37 | 0,03700 [0,02618 ; 0,05064] | compatible | 0,03700 |
| A | ExpVar (haut) | 1000 | 0 | 0,09896 | 98 | 0,09800 [0,08028 ; 0,11813] | compatible | 0,09800 | 0 | 0,04896 | 48 | 0,04800 [0,03560 ; 0,06314] | compatible | 0,04800 |
| A | KruskalAcc (haut) | 1000 | 0 | 0,09896 | 80 | 0,08000 [0,06394 ; 0,09858] | écart mineur | 0,08000 | 0 | 0,04897 | 36 | 0,03600 [0,02534 ; 0,04949] | compatible | 0,03600 |

### T1 bis — niveau du pool brut d'avant #46 (b ≤ R_brut)

Par seuil : n triangles admis, p absentes (comptées comme non-rejet), k rejets (p_mc < α), taux k / n et IC de Clopper-Pearson à 95 % (5 décimales), classe de #166 contre ρ (côté en gras si l'IC est disjoint de la bande [ρ/2 ; 3ρ/2]), taux sur les seules p définies (descriptif).

| Loi | Clé (sens) | n | abs. 0,10 | ρ 0,10 | k 0,10 | taux [IC] 0,10 | classe 0,10 | taux déf. 0,10 | abs. 0,05 | ρ 0,05 | k 0,05 | taux [IC] 0,05 | classe 0,05 | taux déf. 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | Calendrier (deux) | 1000 | 0 | 0,08601 | 80 | 0,08000 [0,06394 ; 0,09858] | compatible | 0,08000 | 0 | 0,04327 | 40 | 0,04000 [0,02873 ; 0,05407] | compatible | 0,04000 |
| N | CorrDev (deux) | 1000 | 0 | 0,09751 | 90 | 0,09000 [0,07299 ; 0,10947] | compatible | 0,09000 | 0 | 0,04761 | 52 | 0,05200 [0,03908 ; 0,06764] | compatible | 0,05200 |
| N | BP (haut) | 1000 | 0 | 0,09897 | 21 | 0,02100 [0,01305 ; 0,03192] | distorsion matérielle (**conservateur**) | 0,02100 | 0 | 0,04897 | 8 | 0,00800 [0,00346 ; 0,01570] | distorsion matérielle (**conservateur**) | 0,00800 |
| N | Grubbs (haut) | 1000 | 0 | 0,09897 | 83 | 0,08300 [0,06665 ; 0,10185] | compatible | 0,08300 | 0 | 0,04897 | 36 | 0,03600 [0,02534 ; 0,04949] | compatible | 0,03600 |
| N | DW (deux) | 1000 | 0 | 0,09795 | 82 | 0,08200 [0,06575 ; 0,10076] | compatible | 0,08200 | 0 | 0,04795 | 45 | 0,04500 [0,03301 ; 0,05975] | compatible | 0,04500 |
| N | Runs (deux) | 1000 | 0 | 0,05122 | 53 | 0,05300 [0,03995 ; 0,06876] | compatible | 0,05300 | 0 | 0,03020 | 24 | 0,02400 [0,01544 ; 0,03550] | compatible | 0,02400 |
| N | PenteIntra (deux) | 1000 | 0 | 0,09795 | 115 | 0,11500 [0,09588 ; 0,13642] | compatible | 0,11500 | 0 | 0,04795 | 62 | 0,06200 [0,04786 ; 0,07878] | compatible | 0,06200 |
| N | Origine (haut) | 1000 | 0 | 0,09897 | 90 | 0,09000 [0,07299 ; 0,10947] | compatible | 0,09000 | 0 | 0,04897 | 43 | 0,04300 [0,03129 ; 0,05749] | compatible | 0,04300 |
| N | HomogF (haut) | 1000 | 0 | 0,09896 | 89 | 0,08900 [0,07208 ; 0,10838] | compatible | 0,08900 | 0 | 0,04896 | 35 | 0,03500 [0,02450 ; 0,04834] | écart mineur | 0,03500 |
| N | Courbure (haut) | 1000 | 0 | 0,09897 | 98 | 0,09800 [0,08028 ; 0,11813] | compatible | 0,09800 | 0 | 0,04897 | 51 | 0,05100 [0,03821 ; 0,06651] | compatible | 0,05100 |
| N | Alpha (haut) | 1000 | 0 | 0,09897 | 207 | 0,20700 [0,18228 ; 0,23346] | distorsion matérielle (**libéral**) | 0,20700 | 0 | 0,04897 | 112 | 0,11200 [0,09312 ; 0,13320] | distorsion matérielle (**libéral**) | 0,11200 |
| N | ExpVar (haut) | 1000 | 0 | 0,09896 | 90 | 0,09000 [0,07299 ; 0,10947] | compatible | 0,09000 | 0 | 0,04897 | 46 | 0,04600 [0,03387 ; 0,06088] | compatible | 0,04600 |
| N | KruskalAcc (haut) | 1000 | 0 | 0,09896 | 100 | 0,10000 [0,08211 ; 0,12029] | compatible | 0,10000 | 0 | 0,04897 | 45 | 0,04500 [0,03301 ; 0,05975] | compatible | 0,04500 |
| E | Calendrier (deux) | 1000 | 0 | 0,08646 | 74 | 0,07400 [0,05855 ; 0,09201] | compatible | 0,07400 | 0 | 0,04032 | 41 | 0,04100 [0,02958 ; 0,05521] | compatible | 0,04100 |
| E | CorrDev (deux) | 1000 | 0 | 0,09751 | 105 | 0,10500 [0,08668 ; 0,12568] | compatible | 0,10500 | 0 | 0,04760 | 56 | 0,05600 [0,04258 ; 0,07211] | compatible | 0,05600 |
| E | BP (haut) | 1000 | 0 | 0,09897 | 81 | 0,08100 [0,06484 ; 0,09967] | compatible | 0,08100 | 0 | 0,04897 | 23 | 0,02300 [0,01463 ; 0,03431] | écart non tranché | 0,02300 |
| E | Grubbs (haut) | 1000 | 0 | 0,09897 | 68 | 0,06800 [0,05319 ; 0,08541] | écart mineur | 0,06800 | 0 | 0,04897 | 30 | 0,03000 [0,02033 ; 0,04255] | écart mineur | 0,03000 |
| E | DW (deux) | 1000 | 0 | 0,09795 | 95 | 0,09500 [0,07754 ; 0,11488] | compatible | 0,09500 | 0 | 0,04795 | 53 | 0,05300 [0,03995 ; 0,06876] | compatible | 0,05300 |
| E | Runs (deux) | 1000 | 0 | 0,05311 | 58 | 0,05800 [0,04433 ; 0,07434] | compatible | 0,05800 | 0 | 0,03103 | 27 | 0,02700 [0,01787 ; 0,03904] | compatible | 0,02700 |
| E | PenteIntra (deux) | 1000 | 0 | 0,09795 | 122 | 0,12200 [0,10235 ; 0,14390] | écart mineur | 0,12200 | 0 | 0,04795 | 56 | 0,05600 [0,04258 ; 0,07211] | compatible | 0,05600 |
| E | Origine (haut) | 1000 | 0 | 0,09897 | 98 | 0,09800 [0,08028 ; 0,11813] | compatible | 0,09800 | 0 | 0,04897 | 51 | 0,05100 [0,03821 ; 0,06651] | compatible | 0,05100 |
| E | HomogF (haut) | 1000 | 0 | 0,09896 | 79 | 0,07900 [0,06304 ; 0,09749] | écart mineur | 0,07900 | 0 | 0,04896 | 35 | 0,03500 [0,02450 ; 0,04834] | écart mineur | 0,03500 |
| E | Courbure (haut) | 1000 | 0 | 0,09897 | 84 | 0,08400 [0,06755 ; 0,10294] | compatible | 0,08400 | 0 | 0,04897 | 43 | 0,04300 [0,03129 ; 0,05749] | compatible | 0,04300 |
| E | Alpha (haut) | 1000 | 0 | 0,09897 | 180 | 0,18000 [0,15666 ; 0,20524] | distorsion matérielle (**libéral**) | 0,18000 | 0 | 0,04897 | 108 | 0,10800 [0,08944 ; 0,12890] | distorsion matérielle (**libéral**) | 0,10800 |
| E | ExpVar (haut) | 1000 | 0 | 0,09896 | 106 | 0,10600 [0,08760 ; 0,12675] | compatible | 0,10600 | 0 | 0,04896 | 56 | 0,05600 [0,04258 ; 0,07211] | compatible | 0,05600 |
| E | KruskalAcc (haut) | 1000 | 0 | 0,09896 | 120 | 0,12000 [0,10050 ; 0,14177] | écart mineur | 0,12000 | 0 | 0,04897 | 63 | 0,06300 [0,04875 ; 0,07989] | compatible | 0,06300 |
| A | Calendrier (deux) | 0 | 0 | 0,08603 | 0 | — — | non évaluable (n = 0) | — | 0 | 0,04273 | 0 | — — | non évaluable (n = 0) | — |
| A | CorrDev (deux) | 0 | 0 | 0,09752 | 0 | — — | non évaluable (n = 0) | — | 0 | 0,04762 | 0 | — — | non évaluable (n = 0) | — |
| A | BP (haut) | 0 | 0 | 0,09897 | 0 | — — | non évaluable (n = 0) | — | 0 | 0,04897 | 0 | — — | non évaluable (n = 0) | — |
| A | Grubbs (haut) | 0 | 0 | 0,09897 | 0 | — — | non évaluable (n = 0) | — | 0 | 0,04897 | 0 | — — | non évaluable (n = 0) | — |
| A | DW (deux) | 0 | 0 | 0,09795 | 0 | — — | non évaluable (n = 0) | — | 0 | 0,04795 | 0 | — — | non évaluable (n = 0) | — |
| A | Runs (deux) | 0 | 0 | 0,05315 | 0 | — — | non évaluable (n = 0) | — | 0 | 0,03181 | 0 | — — | non évaluable (n = 0) | — |
| A | PenteIntra (deux) | 0 | 0 | 0,09795 | 0 | — — | non évaluable (n = 0) | — | 0 | 0,04795 | 0 | — — | non évaluable (n = 0) | — |
| A | Origine (haut) | 0 | 0 | 0,09897 | 0 | — — | non évaluable (n = 0) | — | 0 | 0,04897 | 0 | — — | non évaluable (n = 0) | — |
| A | HomogF (haut) | 0 | 0 | 0,09896 | 0 | — — | non évaluable (n = 0) | — | 0 | 0,04896 | 0 | — — | non évaluable (n = 0) | — |
| A | Courbure (haut) | 0 | 0 | 0,09897 | 0 | — — | non évaluable (n = 0) | — | 0 | 0,04897 | 0 | — — | non évaluable (n = 0) | — |
| A | Alpha (haut) | 0 | 0 | 0,09897 | 0 | — — | non évaluable (n = 0) | — | 0 | 0,04897 | 0 | — — | non évaluable (n = 0) | — |
| A | ExpVar (haut) | 0 | 0 | 0,09896 | 0 | — — | non évaluable (n = 0) | — | 0 | 0,04896 | 0 | — — | non évaluable (n = 0) | — |
| A | KruskalAcc (haut) | 0 | 0 | 0,09896 | 0 | — — | non évaluable (n = 0) | — | 0 | 0,04897 | 0 | — — | non évaluable (n = 0) | — |

### T2 — pool brut contre pool redressé (#46), mêmes triangles et mêmes graines (b ≤ R_brut)

McNemar exact bilatéral (binomiale de paramètre 1/2 sur n01 + n10 ; n01 : redressé rejette, brut non ; n10 : brut rejette, redressé non), Holm (1979) au niveau 0,05 sur la famille des 13 clés par (loi, α) ; écarts |τ − ρ| des deux pools sur les mêmes triangles. Lecture R1 à R3 : évaluation mécanique en fin de tableau.

| Loi | α | Clé (sens) | n | n01 / n10 | p | p Holm | significatif | τ redressé | τ brut | ρ | \|τ_R − ρ\| | \|τ_B − ρ\| |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | 0,10 | Calendrier (deux) | 1000 | 3 / 3 | 1 | 1 | non | 0,08000 | 0,08000 | 0,08601 | 0,00601 | 0,00601 |
| N | 0,10 | CorrDev (deux) | 1000 | 0 / 1 | 1 | 1 | non | 0,08900 | 0,09000 | 0,09751 | 0,00851 | 0,00751 |
| N | 0,10 | BP (haut) | 1000 | 0 / 4 | 0,125 | 1 | non | 0,01700 | 0,02100 | 0,09897 | 0,08197 | 0,07797 |
| N | 0,10 | Grubbs (haut) | 1000 | 4 / 0 | 0,125 | 1 | non | 0,08700 | 0,08300 | 0,09897 | 0,01197 | 0,01597 |
| N | 0,10 | DW (deux) | 1000 | 2 / 4 | 0,687 | 1 | non | 0,08000 | 0,08200 | 0,09795 | 0,01795 | 0,01595 |
| N | 0,10 | Runs (deux) | 1000 | 0 / 3 | 0,25 | 1 | non | 0,05000 | 0,05300 | 0,05122 | 0,00122 | 0,00178 |
| N | 0,10 | PenteIntra (deux) | 1000 | 2 / 4 | 0,687 | 1 | non | 0,11300 | 0,11500 | 0,09795 | 0,01505 | 0,01705 |
| N | 0,10 | Origine (haut) | 1000 | 0 / 0 | 1 | 1 | non | 0,09000 | 0,09000 | 0,09897 | 0,00897 | 0,00897 |
| N | 0,10 | HomogF (haut) | 1000 | 2 / 1 | 1 | 1 | non | 0,09000 | 0,08900 | 0,09896 | 0,00896 | 0,00996 |
| N | 0,10 | Courbure (haut) | 1000 | 3 / 2 | 1 | 1 | non | 0,09900 | 0,09800 | 0,09897 | 0,00003 | 0,00097 |
| N | 0,10 | Alpha (haut) | 1000 | 0 / 107 | 1,23e-32 | 1,6e-31 | oui | 0,10000 | 0,20700 | 0,09897 | 0,00103 | 0,10802 |
| N | 0,10 | ExpVar (haut) | 1000 | 2 / 1 | 1 | 1 | non | 0,09100 | 0,09000 | 0,09896 | 0,00796 | 0,00896 |
| N | 0,10 | KruskalAcc (haut) | 1000 | 0 / 1 | 1 | 1 | non | 0,09900 | 0,10000 | 0,09896 | 0,00004 | 0,00104 |
| N | 0,05 | Calendrier (deux) | 1000 | 3 / 1 | 0,625 | 1 | non | 0,04200 | 0,04000 | 0,04327 | 0,00127 | 0,00327 |
| N | 0,05 | CorrDev (deux) | 1000 | 1 / 3 | 0,625 | 1 | non | 0,05000 | 0,05200 | 0,04761 | 0,00239 | 0,00439 |
| N | 0,05 | BP (haut) | 1000 | 0 / 1 | 1 | 1 | non | 0,00700 | 0,00800 | 0,04897 | 0,04197 | 0,04097 |
| N | 0,05 | Grubbs (haut) | 1000 | 0 / 1 | 1 | 1 | non | 0,03500 | 0,03600 | 0,04897 | 0,01397 | 0,01298 |
| N | 0,05 | DW (deux) | 1000 | 3 / 2 | 1 | 1 | non | 0,04600 | 0,04500 | 0,04795 | 0,00195 | 0,00295 |
| N | 0,05 | Runs (deux) | 1000 | 1 / 1 | 1 | 1 | non | 0,02400 | 0,02400 | 0,03020 | 0,00620 | 0,00620 |
| N | 0,05 | PenteIntra (deux) | 1000 | 2 / 0 | 0,5 | 1 | non | 0,06400 | 0,06200 | 0,04795 | 0,01605 | 0,01405 |
| N | 0,05 | Origine (haut) | 1000 | 3 / 1 | 0,625 | 1 | non | 0,04500 | 0,04300 | 0,04897 | 0,00397 | 0,00598 |
| N | 0,05 | HomogF (haut) | 1000 | 2 / 1 | 1 | 1 | non | 0,03600 | 0,03500 | 0,04896 | 0,01296 | 0,01396 |
| N | 0,05 | Courbure (haut) | 1000 | 2 / 5 | 0,453 | 1 | non | 0,04800 | 0,05100 | 0,04897 | 0,00097 | 0,00202 |
| N | 0,05 | Alpha (haut) | 1000 | 0 / 75 | 5,29e-23 | 6,88e-22 | oui | 0,03700 | 0,11200 | 0,04897 | 0,01197 | 0,06302 |
| N | 0,05 | ExpVar (haut) | 1000 | 4 / 4 | 1 | 1 | non | 0,04600 | 0,04600 | 0,04897 | 0,00297 | 0,00297 |
| N | 0,05 | KruskalAcc (haut) | 1000 | 1 / 0 | 1 | 1 | non | 0,04600 | 0,04500 | 0,04897 | 0,00297 | 0,00397 |
| E | 0,10 | Calendrier (deux) | 1000 | 2 / 1 | 1 | 1 | non | 0,07500 | 0,07400 | 0,08646 | 0,01146 | 0,01246 |
| E | 0,10 | CorrDev (deux) | 1000 | 2 / 6 | 0,289 | 1 | non | 0,10100 | 0,10500 | 0,09751 | 0,00349 | 0,00749 |
| E | 0,10 | BP (haut) | 1000 | 0 / 18 | 7,63e-06 | 9,16e-05 | oui | 0,06300 | 0,08100 | 0,09897 | 0,03597 | 0,01797 |
| E | 0,10 | Grubbs (haut) | 1000 | 3 / 0 | 0,25 | 1 | non | 0,07100 | 0,06800 | 0,09897 | 0,02797 | 0,03097 |
| E | 0,10 | DW (deux) | 1000 | 2 / 2 | 1 | 1 | non | 0,09500 | 0,09500 | 0,09795 | 0,00295 | 0,00295 |
| E | 0,10 | Runs (deux) | 1000 | 4 / 5 | 1 | 1 | non | 0,05700 | 0,05800 | 0,05311 | 0,00389 | 0,00489 |
| E | 0,10 | PenteIntra (deux) | 1000 | 6 / 5 | 1 | 1 | non | 0,12300 | 0,12200 | 0,09795 | 0,02505 | 0,02405 |
| E | 0,10 | Origine (haut) | 1000 | 2 / 1 | 1 | 1 | non | 0,09900 | 0,09800 | 0,09897 | 0,00003 | 0,00097 |
| E | 0,10 | HomogF (haut) | 1000 | 5 / 1 | 0,219 | 1 | non | 0,08300 | 0,07900 | 0,09896 | 0,01596 | 0,01996 |
| E | 0,10 | Courbure (haut) | 1000 | 1 / 1 | 1 | 1 | non | 0,08400 | 0,08400 | 0,09897 | 0,01497 | 0,01497 |
| E | 0,10 | Alpha (haut) | 1000 | 0 / 83 | 2,07e-25 | 2,69e-24 | oui | 0,09700 | 0,18000 | 0,09897 | 0,00197 | 0,08102 |
| E | 0,10 | ExpVar (haut) | 1000 | 3 / 4 | 1 | 1 | non | 0,10500 | 0,10600 | 0,09896 | 0,00604 | 0,00704 |
| E | 0,10 | KruskalAcc (haut) | 1000 | 2 / 3 | 1 | 1 | non | 0,11900 | 0,12000 | 0,09896 | 0,02004 | 0,02104 |
| E | 0,05 | Calendrier (deux) | 1000 | 3 / 5 | 0,727 | 1 | non | 0,03900 | 0,04100 | 0,04032 | 0,00132 | 0,00068 |
| E | 0,05 | CorrDev (deux) | 1000 | 3 / 2 | 1 | 1 | non | 0,05700 | 0,05600 | 0,04760 | 0,00940 | 0,00840 |
| E | 0,05 | BP (haut) | 1000 | 0 / 4 | 0,125 | 1 | non | 0,01900 | 0,02300 | 0,04897 | 0,02997 | 0,02597 |
| E | 0,05 | Grubbs (haut) | 1000 | 3 / 0 | 0,25 | 1 | non | 0,03300 | 0,03000 | 0,04897 | 0,01597 | 0,01897 |
| E | 0,05 | DW (deux) | 1000 | 3 / 2 | 1 | 1 | non | 0,05400 | 0,05300 | 0,04795 | 0,00605 | 0,00505 |
| E | 0,05 | Runs (deux) | 1000 | 0 / 5 | 0,0625 | 0,75 | non | 0,02200 | 0,02700 | 0,03103 | 0,00903 | 0,00403 |
| E | 0,05 | PenteIntra (deux) | 1000 | 4 / 4 | 1 | 1 | non | 0,05600 | 0,05600 | 0,04795 | 0,00805 | 0,00805 |
| E | 0,05 | Origine (haut) | 1000 | 2 / 0 | 0,5 | 1 | non | 0,05300 | 0,05100 | 0,04897 | 0,00403 | 0,00202 |
| E | 0,05 | HomogF (haut) | 1000 | 0 / 2 | 0,5 | 1 | non | 0,03300 | 0,03500 | 0,04896 | 0,01596 | 0,01396 |
| E | 0,05 | Courbure (haut) | 1000 | 1 / 3 | 0,625 | 1 | non | 0,04100 | 0,04300 | 0,04897 | 0,00797 | 0,00598 |
| E | 0,05 | Alpha (haut) | 1000 | 0 / 65 | 5,42e-20 | 7,05e-19 | oui | 0,04300 | 0,10800 | 0,04897 | 0,00598 | 0,05903 |
| E | 0,05 | ExpVar (haut) | 1000 | 2 / 3 | 1 | 1 | non | 0,05500 | 0,05600 | 0,04896 | 0,00604 | 0,00704 |
| E | 0,05 | KruskalAcc (haut) | 1000 | 2 / 2 | 1 | 1 | non | 0,06300 | 0,06300 | 0,04897 | 0,01403 | 0,01403 |

### T3 — témoins oracle (K3)

p_or = engine_p_mc(S0, s_obs, sens) contre l'échantillon oracle de la loi (N0 triangles i.i.d. du même DGP) ; test binomial exact bilatéral du taux τ_or contre la taille du témoin (tableau de ρ), Holm sur les 13 clés par (loi, α). Un témoin significatif suspend la lecture jusqu'à explication (par. 5). Limite déclarée (annotation du 10/10/2026 de la spécification, point 2) : un seul échantillon oracle sert à tous les triangles mesurés ; Var(τ_or) vaut donc environ α(1 − α)(1/n + 1/N0), et non α(1 − α)/n. À n = 2 000 et N0 = 20 000, l'écart-type est multiplié par environ 1,05 et le binomial nominal à 5 % rejette environ 6 % du temps quand la mesure est correcte [calcul d'ordre de grandeur, non simulé]. Ce léger excès de signalement n'est pas corrigé ; il entre dans le jugement « non expliqué » de Π0.

| Loi | α | Clé (sens) | n | p_or absentes | k | τ_or [IC] | taille | p binomiale | p Holm | significatif |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | 0,10 | Calendrier (deux) | 2000 | 0 | 181 | 0,09050 [0,07828 ; 0,10393] | 0,09008 | 0,938 | 1 | non |
| N | 0,10 | CorrDev (deux) | 2000 | 0 | 197 | 0,09850 [0,08579 ; 0,11240] | 0,09945 | 0,911 | 1 | non |
| N | 0,10 | BP (haut) | 2000 | 0 | 171 | 0,08550 [0,07361 ; 0,09862] | 0,09997 | 0,0306 | 0,397 | non |
| N | 0,10 | Grubbs (haut) | 2000 | 0 | 206 | 0,10300 [0,09002 ; 0,11716] | 0,09997 | 0,655 | 1 | non |
| N | 0,10 | DW (deux) | 2000 | 0 | 178 | 0,08900 [0,07688 ; 0,10234] | 0,09995 | 0,109 | 1 | non |
| N | 0,10 | Runs (deux) | 2000 | 0 | 95 | 0,04750 [0,03860 ; 0,05776] | 0,04630 | 0,79 | 1 | non |
| N | 0,10 | PenteIntra (deux) | 2000 | 0 | 197 | 0,09850 [0,08579 ; 0,11240] | 0,09995 | 0,881 | 1 | non |
| N | 0,10 | Origine (haut) | 2000 | 0 | 179 | 0,08950 [0,07735 ; 0,10287] | 0,09997 | 0,126 | 1 | non |
| N | 0,10 | HomogF (haut) | 2000 | 0 | 195 | 0,09750 [0,08485 ; 0,11135] | 0,09996 | 0,737 | 1 | non |
| N | 0,10 | Courbure (haut) | 2000 | 0 | 208 | 0,10400 [0,09096 ; 0,11821] | 0,09997 | 0,551 | 1 | non |
| N | 0,10 | Alpha (haut) | 2000 | 0 | 175 | 0,08750 [0,07548 ; 0,10075] | 0,09997 | 0,0624 | 0,749 | non |
| N | 0,10 | ExpVar (haut) | 2000 | 0 | 189 | 0,09450 [0,08203 ; 0,10817] | 0,09995 | 0,434 | 1 | non |
| N | 0,10 | KruskalAcc (haut) | 2000 | 0 | 194 | 0,09700 [0,08438 ; 0,11082] | 0,09996 | 0,682 | 1 | non |
| N | 0,05 | Calendrier (deux) | 2000 | 0 | 98 | 0,04900 [0,03996 ; 0,05939] | 0,04682 | 0,634 | 1 | non |
| N | 0,05 | CorrDev (deux) | 2000 | 0 | 103 | 0,05150 [0,04223 ; 0,06211] | 0,04962 | 0,68 | 1 | non |
| N | 0,05 | BP (haut) | 2000 | 0 | 75 | 0,03750 [0,02961 ; 0,04678] | 0,04997 | 0,00883 | 0,106 | non |
| N | 0,05 | Grubbs (haut) | 2000 | 0 | 97 | 0,04850 [0,03950 ; 0,05885] | 0,04997 | 0,798 | 1 | non |
| N | 0,05 | DW (deux) | 2000 | 0 | 98 | 0,04900 [0,03996 ; 0,05939] | 0,04995 | 0,918 | 1 | non |
| N | 0,05 | Runs (deux) | 2000 | 0 | 54 | 0,02700 [0,02035 ; 0,03508] | 0,02814 | 0,839 | 1 | non |
| N | 0,05 | PenteIntra (deux) | 2000 | 0 | 107 | 0,05350 [0,04405 ; 0,06429] | 0,04995 | 0,472 | 1 | non |
| N | 0,05 | Origine (haut) | 2000 | 0 | 87 | 0,04350 [0,03499 ; 0,05338] | 0,04997 | 0,199 | 1 | non |
| N | 0,05 | HomogF (haut) | 2000 | 0 | 71 | 0,03550 [0,02783 ; 0,04457] | 0,04996 | 0,00241 | 0,0314 | **oui** |
| N | 0,05 | Courbure (haut) | 2000 | 0 | 109 | 0,05450 [0,04496 ; 0,06537] | 0,04997 | 0,355 | 1 | non |
| N | 0,05 | Alpha (haut) | 2000 | 0 | 87 | 0,04350 [0,03499 ; 0,05338] | 0,04997 | 0,199 | 1 | non |
| N | 0,05 | ExpVar (haut) | 2000 | 0 | 89 | 0,04450 [0,03589 ; 0,05448] | 0,04996 | 0,281 | 1 | non |
| N | 0,05 | KruskalAcc (haut) | 2000 | 0 | 97 | 0,04850 [0,03950 ; 0,05885] | 0,04997 | 0,837 | 1 | non |
| E | 0,10 | Calendrier (deux) | 2000 | 0 | 164 | 0,08200 [0,07035 ; 0,09490] | 0,08942 | 0,256 | 1 | non |
| E | 0,10 | CorrDev (deux) | 2000 | 0 | 208 | 0,10400 [0,09096 ; 0,11821] | 0,09951 | 0,501 | 1 | non |
| E | 0,10 | BP (haut) | 2000 | 0 | 226 | 0,11300 [0,09945 ; 0,12770] | 0,09997 | 0,0572 | 0,686 | non |
| E | 0,10 | Grubbs (haut) | 2000 | 0 | 196 | 0,09800 [0,08532 ; 0,11188] | 0,09997 | 0,794 | 1 | non |
| E | 0,10 | DW (deux) | 2000 | 0 | 202 | 0,10100 [0,08814 ; 0,11505] | 0,09995 | 0,852 | 1 | non |
| E | 0,10 | Runs (deux) | 2000 | 0 | 79 | 0,03950 [0,03139 ; 0,04899] | 0,04687 | 0,125 | 1 | non |
| E | 0,10 | PenteIntra (deux) | 2000 | 0 | 206 | 0,10300 [0,09002 ; 0,11716] | 0,09995 | 0,655 | 1 | non |
| E | 0,10 | Origine (haut) | 2000 | 0 | 204 | 0,10200 [0,08908 ; 0,11610] | 0,09997 | 0,766 | 1 | non |
| E | 0,10 | HomogF (haut) | 2000 | 0 | 189 | 0,09450 [0,08203 ; 0,10817] | 0,09995 | 0,434 | 1 | non |
| E | 0,10 | Courbure (haut) | 2000 | 0 | 172 | 0,08600 [0,07408 ; 0,09915] | 0,09997 | 0,0368 | 0,479 | non |
| E | 0,10 | Alpha (haut) | 2000 | 0 | 192 | 0,09600 [0,08344 ; 0,10976] | 0,09997 | 0,576 | 1 | non |
| E | 0,10 | ExpVar (haut) | 2000 | 0 | 193 | 0,09650 [0,08391 ; 0,11029] | 0,09995 | 0,628 | 1 | non |
| E | 0,10 | KruskalAcc (haut) | 2000 | 0 | 202 | 0,10100 [0,08814 ; 0,11505] | 0,09996 | 0,881 | 1 | non |
| E | 0,05 | Calendrier (deux) | 2000 | 0 | 84 | 0,04200 [0,03364 ; 0,05174] | 0,04571 | 0,454 | 1 | non |
| E | 0,05 | CorrDev (deux) | 2000 | 0 | 110 | 0,05500 [0,04542 ; 0,06591] | 0,04964 | 0,279 | 1 | non |
| E | 0,05 | BP (haut) | 2000 | 0 | 101 | 0,05050 [0,04132 ; 0,06103] | 0,04997 | 0,878 | 1 | non |
| E | 0,05 | Grubbs (haut) | 2000 | 0 | 94 | 0,04700 [0,03815 ; 0,05721] | 0,04997 | 0,573 | 1 | non |
| E | 0,05 | DW (deux) | 2000 | 0 | 103 | 0,05150 [0,04223 ; 0,06211] | 0,04995 | 0,72 | 1 | non |
| E | 0,05 | Runs (deux) | 2000 | 0 | 44 | 0,02200 [0,01603 ; 0,02942] | 0,03639 | 0,000324 | 0,00422 | **oui** |
| E | 0,05 | PenteIntra (deux) | 2000 | 0 | 81 | 0,04050 [0,03229 ; 0,05009] | 0,04995 | 0,0511 | 0,562 | non |
| E | 0,05 | Origine (haut) | 2000 | 0 | 95 | 0,04750 [0,03860 ; 0,05776] | 0,04997 | 0,644 | 1 | non |
| E | 0,05 | HomogF (haut) | 2000 | 0 | 84 | 0,04200 [0,03364 ; 0,05174] | 0,04996 | 0,111 | 1 | non |
| E | 0,05 | Courbure (haut) | 2000 | 0 | 76 | 0,03800 [0,03005 ; 0,04733] | 0,04997 | 0,0136 | 0,164 | non |
| E | 0,05 | Alpha (haut) | 2000 | 0 | 110 | 0,05500 [0,04542 ; 0,06591] | 0,04997 | 0,304 | 1 | non |
| E | 0,05 | ExpVar (haut) | 2000 | 0 | 100 | 0,05000 [0,04086 ; 0,06048] | 0,04996 | 0,959 | 1 | non |
| E | 0,05 | KruskalAcc (haut) | 2000 | 0 | 104 | 0,05200 [0,04268 ; 0,06266] | 0,04997 | 0,681 | 1 | non |
| A | 0,10 | Calendrier (deux) | 1000 | 0 | 82 | 0,08200 [0,06575 ; 0,10076] | 0,08819 | 0,539 | 1 | non |
| A | 0,10 | CorrDev (deux) | 1000 | 0 | 86 | 0,08600 [0,06936 ; 0,10512] | 0,09955 | 0,169 | 1 | non |
| A | 0,10 | BP (haut) | 1000 | 0 | 86 | 0,08600 [0,06936 ; 0,10512] | 0,09997 | 0,154 | 1 | non |
| A | 0,10 | Grubbs (haut) | 1000 | 0 | 105 | 0,10500 [0,08668 ; 0,12568] | 0,09997 | 0,598 | 1 | non |
| A | 0,10 | DW (deux) | 1000 | 0 | 101 | 0,10100 [0,08302 ; 0,12137] | 0,09995 | 0,916 | 1 | non |
| A | 0,10 | Runs (deux) | 1000 | 0 | 42 | 0,04200 [0,03043 ; 0,05635] | 0,04565 | 0,649 | 1 | non |
| A | 0,10 | PenteIntra (deux) | 1000 | 0 | 115 | 0,11500 [0,09588 ; 0,13642] | 0,09995 | 0,114 | 1 | non |
| A | 0,10 | Origine (haut) | 1000 | 0 | 114 | 0,11400 [0,09496 ; 0,13534] | 0,09997 | 0,14 | 1 | non |
| A | 0,10 | HomogF (haut) | 1000 | 0 | 95 | 0,09500 [0,07754 ; 0,11488] | 0,09995 | 0,635 | 1 | non |
| A | 0,10 | Courbure (haut) | 1000 | 0 | 101 | 0,10100 [0,08302 ; 0,12137] | 0,09997 | 0,916 | 1 | non |
| A | 0,10 | Alpha (haut) | 1000 | 0 | 90 | 0,09000 [0,07299 ; 0,10947] | 0,09997 | 0,316 | 1 | non |
| A | 0,10 | ExpVar (haut) | 1000 | 0 | 99 | 0,09900 [0,08119 ; 0,11921] | 0,09995 | 0,958 | 1 | non |
| A | 0,10 | KruskalAcc (haut) | 1000 | 0 | 80 | 0,08000 [0,06394 ; 0,09858] | 0,09996 | 0,0349 | 0,453 | non |
| A | 0,05 | Calendrier (deux) | 1000 | 0 | 50 | 0,05000 [0,03734 ; 0,06539] | 0,04630 | 0,547 | 1 | non |
| A | 0,05 | CorrDev (deux) | 1000 | 0 | 46 | 0,04600 [0,03387 ; 0,06088] | 0,04961 | 0,662 | 1 | non |
| A | 0,05 | BP (haut) | 1000 | 0 | 45 | 0,04500 [0,03301 ; 0,05975] | 0,04997 | 0,514 | 1 | non |
| A | 0,05 | Grubbs (haut) | 1000 | 0 | 51 | 0,05100 [0,03821 ; 0,06651] | 0,04997 | 0,884 | 1 | non |
| A | 0,05 | DW (deux) | 1000 | 0 | 44 | 0,04400 [0,03215 ; 0,05862] | 0,04995 | 0,425 | 1 | non |
| A | 0,05 | Runs (deux) | 1000 | 0 | 30 | 0,03000 [0,02033 ; 0,04255] | 0,03604 | 0,35 | 1 | non |
| A | 0,05 | PenteIntra (deux) | 1000 | 0 | 59 | 0,05900 [0,04521 ; 0,07545] | 0,04995 | 0,191 | 1 | non |
| A | 0,05 | Origine (haut) | 1000 | 0 | 59 | 0,05900 [0,04521 ; 0,07545] | 0,04997 | 0,191 | 1 | non |
| A | 0,05 | HomogF (haut) | 1000 | 0 | 45 | 0,04500 [0,03301 ; 0,05975] | 0,04996 | 0,514 | 1 | non |
| A | 0,05 | Courbure (haut) | 1000 | 0 | 51 | 0,05100 [0,03821 ; 0,06651] | 0,04997 | 0,884 | 1 | non |
| A | 0,05 | Alpha (haut) | 1000 | 0 | 50 | 0,05000 [0,03734 ; 0,06539] | 0,04997 | 1 | 1 | non |
| A | 0,05 | ExpVar (haut) | 1000 | 0 | 51 | 0,05100 [0,03821 ; 0,06651] | 0,04996 | 0,884 | 1 | non |
| A | 0,05 | KruskalAcc (haut) | 1000 | 0 | 34 | 0,03400 [0,02366 ; 0,04719] | 0,04996 | 0,0199 | 0,258 | non |

### T4 — verdicts sous H0, multiplicité, voisinage du seuil

Fréquences sur les triangles admis : ALERTE ou ECHEC (A ou E) et ECHEC (E) par ligne de mw_tests() (lignes INFO exclues du dénominateur) ; part des triangles à au moins une ALERTE ou un ECHEC, et à au moins un ECHEC, sur les 13 lignes Monte-Carlo et sur toutes les lignes à verdict (repère 1 − (1 − α)^13 : 0,7458 à α = 0,10, ordre de grandeur et non référence) ; fréquence de |p_mc − α| < 2 err_mc par clé (signalement proposé de Q-206-9), aux deux seuils, sur les p définies.

**Pool redressé.**

| Ligne de mw_tests() | clé | loi N : A ou E / E (n) | loi E : A ou E / E (n) | loi A : A ou E / E (n) |
| --- | --- | --- | --- | --- |
| Absence de tendance des facteurs avec le cumul, a colonne donnee | PenteIntra | 0,11400 / 0,06400 (2000) | 0,12050 / 0,05300 (2000) | 0,13000 / 0,07300 (1000) |
| Nullite de l'ordonnee a l'origine, colonne par colonne | Origine | 0,08800 / 0,04200 (2000) | 0,09700 / 0,04750 (2000) | 0,10600 / 0,06100 (1000) |
| Homogeneite de f_j entre annees de survenance | HomogF | 0,09550 / 0,03900 (2000) | 0,08900 / 0,04150 (2000) | 0,09100 / 0,04100 (1000) |
| Absence de courbure de la regression | Courbure | 0,09300 / 0,04450 (2000) | 0,08000 / 0,03600 (2000) | 0,09500 / 0,04100 (1000) |
| Stabilite du facteur selon la ponderation (famille alpha) | Alpha | 0,09550 / 0,03850 (2000) | 0,09700 / 0,04200 (2000) | 0,10200 / 0,03700 (1000) |
| Heteroscedasticite residuelle vs cumul | BP | 0,01600 / 0,00500 (2000) | 0,06950 / 0,02450 (2000) | 0,00400 / 0,00000 (1000) |
| Adequation de l'exposant de variance, colonne par colonne | ExpVar | 0,09550 / 0,04600 (2000) | 0,09500 / 0,04950 (2000) | 0,09800 / 0,04800 (1000) |
| Variance unitaire des residus de Mack |  | — | — | — |
| Effets d'annee calendaire (test de Mack) | Calendrier | 0,08600 / 0,04550 (2000) | 0,08100 / 0,04100 (2000) | 0,08400 / 0,04000 (1000) |
| Homogeneite des residus entre annees de survenance | KruskalAcc | 0,09600 / 0,05050 (2000) | 0,10050 / 0,04900 (2000) | 0,08000 / 0,03600 (1000) |
| Correlation entre annees de developpement adjacentes | CorrDev | 0,09650 / 0,05150 (2000) | 0,09950 / 0,05200 (2000) | 0,08800 / 0,04400 (1000) |
| Autocorrelation des residus (Durbin-Watson) | DW | 0,08550 / 0,04550 (2000) | 0,10100 / 0,05300 (2000) | 0,08700 / 0,03200 (1000) |
| Test des suites sur les residus de Mack | Runs | 0,05800 / 0,02750 (2000) | 0,05250 / 0,02250 (2000) | 0,05100 / 0,03200 (1000) |
| Cellule aberrante du triangle (Grubbs) | Grubbs | 0,09900 / 0,04450 (2000) | 0,07500 / 0,03500 (2000) | 0,15900 / 0,08800 (1000) |
| Cellules aberrantes multiples (ESD generalise) |  | 0,00000 / 0,00000 (2000) | 0,00250 / 0,00250 (2000) | 0,02300 / 0,02300 (1000) |
| Shapiro-Wilk sur les residus de Mack |  | 0,22100 / 0,10900 (2000) | 0,59450 / 0,41950 (2000) | 0,51700 / 0,36600 (1000) |
| Lilliefors sur les residus de Mack |  | 0,18750 / 0,10250 (2000) | 0,55900 / 0,37850 (2000) | 0,45600 / 0,31700 (1000) |
| Extrapolation de sigma pour la derniere annee de developpement |  | — | — | — |
| Part de la reserve portee par la derniere annee d'accident |  | — | — | — |

| Loi | n | ≥ 1 A ou E (13 lignes MC) | ≥ 1 E (13 lignes MC) | ≥ 1 A ou E (toutes lignes à verdict) | ≥ 1 E (toutes lignes à verdict) |
| --- | --- | --- | --- | --- | --- |
| N | 2000 | 0,63550 | 0,38750 | 0,73400 | 0,48200 |
| E | 2000 | 0,64150 | 0,38100 | 0,88700 | 0,69750 |
| A | 1000 | 0,65500 | 0,39800 | 0,84900 | 0,64900 |

| Loi | Clé | p définies | \|p − 0,10\| < 2 err_mc | \|p − 0,05\| < 2 err_mc |
| --- | --- | --- | --- | --- |
| N | Calendrier | 2000 | 0,03500 | 0,04550 |
| N | CorrDev | 2000 | 0,05600 | 0,03750 |
| N | BP | 2000 | 0,00900 | 0,00500 |
| N | Grubbs | 2000 | 0,03850 | 0,02650 |
| N | DW | 2000 | 0,05450 | 0,03250 |
| N | Runs | 2000 | 0,04150 | 0,03150 |
| N | PenteIntra | 2000 | 0,05650 | 0,04550 |
| N | Origine | 2000 | 0,03300 | 0,03000 |
| N | HomogF | 2000 | 0,03500 | 0,03000 |
| N | Courbure | 2000 | 0,03950 | 0,02550 |
| N | Alpha | 2000 | 0,04300 | 0,02750 |
| N | ExpVar | 2000 | 0,03400 | 0,02700 |
| N | KruskalAcc | 2000 | 0,03750 | 0,03000 |
| E | Calendrier | 2000 | 0,04300 | 0,04100 |
| E | CorrDev | 2000 | 0,05450 | 0,03700 |
| E | BP | 2000 | 0,04450 | 0,01950 |
| E | Grubbs | 2000 | 0,02550 | 0,02050 |
| E | DW | 2000 | 0,05000 | 0,04600 |
| E | Runs | 2000 | 0,04250 | 0,02300 |
| E | PenteIntra | 2000 | 0,06650 | 0,04900 |
| E | Origine | 2000 | 0,03850 | 0,03050 |
| E | HomogF | 2000 | 0,03950 | 0,02200 |
| E | Courbure | 2000 | 0,03950 | 0,02450 |
| E | Alpha | 2000 | 0,03650 | 0,02800 |
| E | ExpVar | 2000 | 0,02700 | 0,02200 |
| E | KruskalAcc | 2000 | 0,03100 | 0,02950 |
| A | Calendrier | 1000 | 0,04000 | 0,04200 |
| A | CorrDev | 1000 | 0,04700 | 0,03800 |
| A | BP | 1000 | 0,01100 | 0,00100 |
| A | Grubbs | 1000 | 0,05900 | 0,03700 |
| A | DW | 1000 | 0,05600 | 0,03600 |
| A | Runs | 1000 | 0,04200 | 0,02200 |
| A | PenteIntra | 1000 | 0,04800 | 0,04800 |
| A | Origine | 1000 | 0,04100 | 0,02900 |
| A | HomogF | 1000 | 0,03800 | 0,02600 |
| A | Courbure | 1000 | 0,04300 | 0,03100 |
| A | Alpha | 1000 | 0,04300 | 0,03900 |
| A | ExpVar | 1000 | 0,03700 | 0,03200 |
| A | KruskalAcc | 1000 | 0,03600 | 0,01600 |

**Pool brut.**

| Ligne de mw_tests() | clé | loi N : A ou E / E (n) | loi E : A ou E / E (n) |
| --- | --- | --- | --- |
| Absence de tendance des facteurs avec le cumul, a colonne donnee | PenteIntra | 0,11500 / 0,06200 (1000) | 0,12200 / 0,05600 (1000) |
| Nullite de l'ordonnee a l'origine, colonne par colonne | Origine | 0,09000 / 0,04300 (1000) | 0,09800 / 0,05100 (1000) |
| Homogeneite de f_j entre annees de survenance | HomogF | 0,08900 / 0,03500 (1000) | 0,07900 / 0,03500 (1000) |
| Absence de courbure de la regression | Courbure | 0,09800 / 0,05100 (1000) | 0,08400 / 0,04300 (1000) |
| Stabilite du facteur selon la ponderation (famille alpha) | Alpha | 0,20700 / 0,11200 (1000) | 0,18000 / 0,10800 (1000) |
| Heteroscedasticite residuelle vs cumul | BP | 0,02100 / 0,00800 (1000) | 0,08100 / 0,02300 (1000) |
| Adequation de l'exposant de variance, colonne par colonne | ExpVar | 0,09000 / 0,04600 (1000) | 0,10600 / 0,05600 (1000) |
| Variance unitaire des residus de Mack |  | — | — |
| Effets d'annee calendaire (test de Mack) | Calendrier | 0,08000 / 0,04000 (1000) | 0,07400 / 0,04100 (1000) |
| Homogeneite des residus entre annees de survenance | KruskalAcc | 0,10000 / 0,04500 (1000) | 0,12000 / 0,06300 (1000) |
| Correlation entre annees de developpement adjacentes | CorrDev | 0,09000 / 0,05200 (1000) | 0,10500 / 0,05600 (1000) |
| Autocorrelation des residus (Durbin-Watson) | DW | 0,08200 / 0,04500 (1000) | 0,09500 / 0,05300 (1000) |
| Test des suites sur les residus de Mack | Runs | 0,05300 / 0,02400 (1000) | 0,05800 / 0,02700 (1000) |
| Cellule aberrante du triangle (Grubbs) | Grubbs | 0,08300 / 0,03600 (1000) | 0,06800 / 0,03000 (1000) |
| Cellules aberrantes multiples (ESD generalise) |  | 0,00000 / 0,00000 (1000) | 0,00100 / 0,00100 (1000) |
| Shapiro-Wilk sur les residus de Mack |  | 0,22900 / 0,11900 (1000) | 0,60700 / 0,42500 (1000) |
| Lilliefors sur les residus de Mack |  | 0,20200 / 0,10500 (1000) | 0,56900 / 0,38500 (1000) |
| Extrapolation de sigma pour la derniere annee de developpement |  | — | — |
| Part de la reserve portee par la derniere annee d'accident |  | — | — |

| Loi | n | ≥ 1 A ou E (13 lignes MC) | ≥ 1 E (13 lignes MC) | ≥ 1 A ou E (toutes lignes à verdict) | ≥ 1 E (toutes lignes à verdict) |
| --- | --- | --- | --- | --- | --- |
| N | 1000 | 0,67100 | 0,41700 | 0,76600 | 0,52000 |
| E | 1000 | 0,67300 | 0,43300 | 0,89900 | 0,72900 |

| Loi | Clé | p définies | \|p − 0,10\| < 2 err_mc | \|p − 0,05\| < 2 err_mc |
| --- | --- | --- | --- | --- |
| N | Calendrier | 1000 | 0,03600 | 0,04200 |
| N | CorrDev | 1000 | 0,04400 | 0,03900 |
| N | BP | 1000 | 0,01600 | 0,00700 |
| N | Grubbs | 1000 | 0,03200 | 0,02100 |
| N | DW | 1000 | 0,05200 | 0,03300 |
| N | Runs | 1000 | 0,04200 | 0,02800 |
| N | PenteIntra | 1000 | 0,06200 | 0,04200 |
| N | Origine | 1000 | 0,02500 | 0,02700 |
| N | HomogF | 1000 | 0,03400 | 0,03000 |
| N | Courbure | 1000 | 0,04600 | 0,02400 |
| N | Alpha | 1000 | 0,05700 | 0,05700 |
| N | ExpVar | 1000 | 0,02400 | 0,02800 |
| N | KruskalAcc | 1000 | 0,03600 | 0,03600 |
| E | Calendrier | 1000 | 0,04100 | 0,04200 |
| E | CorrDev | 1000 | 0,04800 | 0,03800 |
| E | BP | 1000 | 0,05200 | 0,02300 |
| E | Grubbs | 1000 | 0,02900 | 0,01500 |
| E | DW | 1000 | 0,04100 | 0,04200 |
| E | Runs | 1000 | 0,04000 | 0,02900 |
| E | PenteIntra | 1000 | 0,06400 | 0,04700 |
| E | Origine | 1000 | 0,03400 | 0,02900 |
| E | HomogF | 1000 | 0,04100 | 0,01800 |
| E | Courbure | 1000 | 0,03100 | 0,02800 |
| E | Alpha | 1000 | 0,06500 | 0,04500 |
| E | ExpVar | 1000 | 0,03200 | 0,03000 |
| E | KruskalAcc | 1000 | 0,03900 | 0,03500 |

### T5 — B effectif, p absentes, triangles refusés, durées

| Loi | Pool | n admis | B eff. min | B eff. médiane | part des (triangle, clé) à B eff. < 999 | triangles à ≥ 1 p absente (K4) | p absentes par motif | durée par triangle (s) : moy. [méd. ; max] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | redressé | 2000 | 999 | 999 | 0,00000 | 0 (0,00000) | aucune | 20,6 [20,5 ; 26,6] |
| N | brut | 1000 | 999 | 999 | 0,00000 | 0 (0,00000) | aucune | 21,0 [20,9 ; 26,8] |
| E | redressé | 2000 | 998 | 999 | 0,00004 | 0 (0,00000) | aucune | 20,6 [20,4 ; 25,6] |
| E | brut | 1000 | 999 | 999 | 0,00000 | 0 (0,00000) | aucune | 21,0 [20,9 ; 24,7] |
| A | redressé | 1000 | 999 | 999 | 0,00000 | 0 (0,00000) | aucune | 19,9 [19,9 ; 21,7] |

| Loi | triangles | admis | refusés | part refusée | motifs de refus | en erreur |
| --- | --- | --- | --- | --- | --- | --- |
| N | 2000 | 2000 | 0 | 0,00000 | aucun | 0 |
| E | 2000 | 2000 | 0 | 0,00000 | aucun | 0 |
| A | 1000 | 1000 | 0 | 0,00000 | aucun | 0 |
| N (oracle) | 20000 | 20000 | 0 | 0,00000 | aucun | 0 |
| E (oracle) | 20000 | 20000 | 0 | 0,00000 | aucun | 0 |
| A (oracle) | 20000 | 20000 | 0 | 0,00000 | aucun | 0 |

