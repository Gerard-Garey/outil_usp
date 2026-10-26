## Mesure #297 (Fk) : niveau réel à T = 8 des p de famille et de la p globale de Merz-Wüthrich, et remesure de #206 -- combinaison de 18 sortie(s)

### T0 — provenance (identique dans toutes les sorties, vérifié)

| Grandeur | Valeur |
| --- | --- |
| DGP sous H0 (par. 2) | modèle de Mack ajusté à reserve2 (mw_ajuster(), tests/donnees/triangle_mw.csv), I = J = 7 ; f̂ = (3,20372 ; 1,65175 ; 1,32525 ; 1,15042 ; 1,09469 ; 1,06455 ; 1,02841) ; σ̂² = (0,72404 ; 0,71209 ; 0,69814 ; 0,31478 ; 0,097325 ; 0,18967 ; 0,097325), dont σ̂²_6 extrapolé ; première colonne fixée (300,0000 ; 311,4286 ; 322,8571 ; 334,2857 ; 345,7143 ; 357,1429 ; 368,5714 ; 380,0000) ; colonnes dégénérées de reserve2 : 6 ; conformes aux valeurs arrondies du par. 2 : oui ; lois : N (stats::rnorm), E (loi uniforme sur les 27 valeurs de .mw_pool_residus(aj0, jd0) divisées par leur écart-type de population 0,9988 ; pool : asymétrie -0,159, excès de kurtosis -1,393, bornes [-1,588 ; 1,452], bornes après division [-1,590 ; 1,454]), A ((G − 2)/√2, G ~ Gamma(2) par stats::qgamma(stats::runif(n), 2)) ; générateur gen_triangle_h0() |
| Configuration | méthode reserve2, segment 1 de l'annexe II ; B = 999 (donnée du test calibré) ; α des verdicts = 0,10 ; seuils mesurés 0,10 et 0,05 ; chemin mesuré mw_bootstrap() + mw_tests() (identité à run_engine() : contrôle (i2)) ; B_MIN_DEGENERESCENCE = 50 |
| Graines (par. 7) | triangle b, loi ℓ : 20840000 + 10000 (ℓ − 1) + b ; bootstrap b, loi ℓ (les deux pools) : 20870000 + 10000 (ℓ − 1) + b ; oracle k, loi ℓ : 20900000 + 20000 (ℓ − 1) + k ; ℓ = 1 (N), 2 (E), 3 (A) ; contrôles sur reserve2 : 20260831 |
| Graines : recherche des collisions (graines calculées comprises) | plages triangles 20840001-20862000, bootstrap 20870001-20892000, oracle 20900001-20960000 (disjointes : oui) ; 32 littéraux de graine dans 71 fichiers (R/engine.R, tests/*.R, tests/unitaires/*.R), de 20260831 à 23700237 ; littéraux L dont [L ; L + 20000] touche une plage : aucun ; littéraux au-dessus des plages (sans collision ; annotation du 10/10/2026 de la spécification, point 1) : 21000000, 21100000, 21200000, 23700237 ; littéraux écartés de la recherche : lignes affectant PLAGE_* (bornes de plage, R21 #350) et réemploi déclaré des trois graines de base de #206 par tests/puissance_mw_t8.R ; littéraux en écriture scientifique non recherchés ; SEED_LOI_NULLE_SW 20260901, graine de reserve2 20260831 et réseau 20260831 + 1000 k ≤ 20760831 de tests/puissance_t8.R hors des plages : oui |
| Générateur | Mersenne-Twister, Inversion, Rejection |
| Commit | 7ff47251a769a4d864c54e363b1758c45362eaf4 |
| Plateforme de calcul (R, système, machine, BLAS, LAPACK) | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : libblas.so.3.12.0 ; LAPACK : liblapack.so.3.12.0 (version 3.12.0) |
| Empreintes md5 du code exécuté | R/engine.R 10bd74c2923cc1ac034df6a9a4e9c0c8 ; tests/outils_tests.R chargé (dépôt) 63a27805557d75069137e726102e685c ; script exécuté (dépôt) bcfd4d7f0b1f4b145afd56f82e781df7 ; docs/specifications/206-calibration-mc-merz-wuthrich.md 318367a408d9c94ae7791c756eed02c0 ; docs/specifications/fk-lecture-conjointe.md 941956bccaf278672469040b5c52caf8 |
| Empreinte sans commentaires de R/engine.R (#231) et md5 du fichier entier | 48adec179f5b1bab043ecfeecebba64a (md5 du fichier entier 10bd74c2923cc1ac034df6a9a4e9c0c8) |
| Contrôle (a) : reserve2 contre tests/reference/reserve2.rds | conforme ; 17663 feuille(s), 0 non strictement identique(s), écart maximal 0.000e+00 |
| Lignes de mw_tests() (ordre de reserve2) | Absence de tendance des facteurs avec le cumul, a colonne donnee ; Nullite de l'ordonnee a l'origine, colonne par colonne ; Homogeneite de f_j entre annees de survenance ; Absence de courbure de la regression ; Stabilite du facteur selon la ponderation (famille alpha) ; Identifiabilite intra-colonne (dispersion des cumuls par colonne) ; Heteroscedasticite residuelle vs cumul ; Adequation de l'exposant de variance, colonne par colonne ; Variance unitaire des residus de Mack ; Effets d'annee calendaire (test de Mack) ; Effets d'annee calendaire par diagonale (repere de Mack 1997) ; Homogeneite des residus entre annees de survenance ; Correlation entre annees de developpement adjacentes ; Autocorrelation des residus (Durbin-Watson) ; Test des suites sur les residus de Mack ; Cellule aberrante du triangle (residus studentises externes) ; Cellules aberrantes multiples (ESD generalise) ; Shapiro-Wilk sur les residus de Mack ; Lilliefors sur les residus de Mack ; Extrapolation de sigma pour la derniere annee de developpement ; Part de la reserve portee par la derniere annee d'accident ; p de famille (minP, lecture conjointe) [M1] ; p de famille (minP, lecture conjointe) [M2] ; p de famille (minP, lecture conjointe) [M3] ; p globale (minP, lecture conjointe de la batterie) [LC] |
| Correspondance clé → ligne (contrôle (b)) | Calendrier=10 ; CorrDev=13 ; BP=7 ; MinP4=16 ; DW=14 ; Runs=15 ; PenteIntra=1 ; Origine=2 ; HomogF=3 ; Courbure=4 ; Alpha=5 ; ExpVar=8 ; KruskalAcc=12 |
| Essai (--essai, non versionnable) | non |
| Locale LC_CTYPE des sorties (origine → travail) | C.UTF-8 → C.UTF-8 |
| Niveau de l'échelle (spécification de Fk, par. 5.2) et R | L0 (— ; plan de la spécification de Fk, par. 5.2) : N = 2000, E = 2000 (pool redressé seul) ; N0 = 20000 par loi ; ni pool brut, ni loi A, ni sous-mesure N |
| Débit (ligne du JOURNAL) | MW c_b = 17,53 s, P_k = 1,000 / 1,943 / 2,986 / 3,917 ; LN c_J1 = 11,45 s, c_J2 = 8,87 s, P_k = 1,000 / 2,055 / 3,169 / 4,205 ; durée planifiée 7,86 h à 4 processus (pré-vol du 2026-10-25, commit 7ff4725) |
| Triangles refusés par loi (par. 2 : signalé au-delà de 1 %) | N 0 / 2000 (0,00000) ; E 0 / 2000 (0,00000) ; oracle N 0 / 20000 (0,00000) ; oracle E 0 / 20000 (0,00000) |
| ρ approché (plus de 1 % de statistiques oracle non finies pour la clé ; annotation du 10/10/2026, point 2 (a)) | aucune |
| Sorties combinées (nom, md5, plage, échantillon des contrôles) | oracle-E.txt a69a9ff00f99d1327a835fb5e728259f (oracle E, 1-20000, reprise : oracle-E.txt.partiel1 6688e9a09adc5d39e38562a5951f769e 13452 50 0) ; oracle-N.txt 50ab11d6f243d51543e8a02f1df59816 (oracle N, 1-20000, reprise : oracle-N.txt.partiel1 673c8528ea4b166ba0f343f4ff85a650 13480 50 0) ; tranche-E-0001-0250.txt 0e17424175e3f6bb4505147af82b8a6c (tranche E, 1-250, échantillon 1, reprise : tranche-E-0001-0250.txt.partiel1 cd8653966880db0b0d39a7c8c1db8376 4 10 0) ; tranche-E-0251-0500.txt 564ff35f5ccffe4c2034e6243a02c5af (tranche E, 251-500, échantillon 251) ; tranche-E-0501-0750.txt 5f68323faa58fb754779a3b9f3d706f2 (tranche E, 501-750, échantillon 501, reprise : tranche-E-0501-0750.txt.partiel1 9d4162caa8903ac5c62e0186dd1f4762 123 10 0) ; tranche-E-0751-1000.txt 67b46c4928624049af02e18e85c0ad8e (tranche E, 751-1000, échantillon 751, reprise : tranche-E-0751-1000.txt.partiel1 87deadf88f318b6628b07e998266a2b7 106 10 0) ; tranche-E-1001-1250.txt 91bc5e5ab2193da67145b404c614b0d3 (tranche E, 1001-1250, échantillon 1001, reprise : tranche-E-1001-1250.txt.partiel1 9fa52cc213b3a476bb22d5775fd18d5a 218 10 0) ; tranche-E-1251-1500.txt ee6c3a727f55564bcd026654ad182b6d (tranche E, 1251-1500, échantillon 1251, reprise : tranche-E-1251-1500.txt.partiel1 440026216bdbc09db41d094fc37d909d 201 10 0) ; tranche-E-1501-1750.txt 1d1132cc6a7626f987f289e3e6d2f228 (tranche E, 1501-1750, échantillon 1501) ; tranche-E-1751-2000.txt 0708aba896d8f1947c5f9c554ef369c1 (tranche E, 1751-2000, échantillon 1751) ; tranche-N-0001-0250.txt 8d075dee50e1eb8a453739502855ca3a (tranche N, 1-250, échantillon 1, reprise : tranche-N-0001-0250.txt.partiel1 653036de551e8ae4256536c797609c1e 5 10 0) ; tranche-N-0251-0500.txt f56e5de62fc5ca73dbf560e62cd2687f (tranche N, 251-500, échantillon 251) ; tranche-N-0501-0750.txt 8b8d4668c98e4514291bb4a611ce6657 (tranche N, 501-750, échantillon 501, reprise : tranche-N-0501-0750.txt.partiel1 aa18ac986cb636a18d78ec72b860c0da 124 10 0) ; tranche-N-0751-1000.txt 0217a001af83ae816c88efca84a917cf (tranche N, 751-1000, échantillon 751, reprise : tranche-N-0751-1000.txt.partiel1 41496f868c3cae1258ee379f17bc282d 107 10 0) ; tranche-N-1001-1250.txt 2d2945ddd9ef3e06d1231a0c907cbb8a (tranche N, 1001-1250, échantillon 1001, reprise : tranche-N-1001-1250.txt.partiel1 1fcd57c679227c07f231c4b47480343e 217 10 0) ; tranche-N-1251-1500.txt 61a703242d35721589bc169745a5a7df (tranche N, 1251-1500, échantillon 1251, reprise : tranche-N-1251-1500.txt.partiel1 64c0c1c3d00f9c06b40a245d28a642bd 201 10 0) ; tranche-N-1501-1750.txt 7a3e6c7cce8d3ad2ea9e7e19a8f201a9 (tranche N, 1501-1750, échantillon 1501) ; tranche-N-1751-2000.txt d61b3e40a449fd7ffff9a2c507ea5aff (tranche N, 1751-2000, échantillon 1751) |
| Échantillons oracle (non versionnés, régénérables par leurs graines) : md5 des valeurs | E : 20d6491fdcf78b3747d07f681cf5f503 (fichier a69a9ff00f99d1327a835fb5e728259f) ; N : 9644d84850069dc0149f3e1f2fac58cf (fichier 50ab11d6f243d51543e8a02f1df59816) |
| JOURNAL | JOURNAL.md (md5 af942ef94ae0e08b1fc7b1b3ec774427) : md5 des 18 sorties conformes ; lignes du débit et de l'empreinte (#231) lues ; niveau : L0 |
| Empreinte sans commentaires (#231) du JOURNAL | 48adec179f5b1bab043ecfeecebba64a, égale à celle des sorties (contrôle (i3)) |
| Commit de la combinaison | 7ff47251a769a4d864c54e363b1758c45362eaf4 |
| Empreintes md5 du combinateur | R/engine.R 10bd74c2923cc1ac034df6a9a4e9c0c8 ; tests/outils_tests.R chargé (dépôt) 63a27805557d75069137e726102e685c ; script exécuté (dépôt) bcfd4d7f0b1f4b145afd56f82e781df7 ; docs/specifications/206-calibration-mc-merz-wuthrich.md 318367a408d9c94ae7791c756eed02c0 ; docs/specifications/fk-lecture-conjointe.md 941956bccaf278672469040b5c52caf8 |
| Empreinte sans commentaires de R/engine.R à la combinaison (#231) | 48adec179f5b1bab043ecfeecebba64a |
| Valeurs brutes | 20261026-issue297-calibration-famille-mw-brut.tsv : md5 01325170c75ccc603707f96332dc1e96, 4000 lignes (copie hors du dépôt : --brut) |
| Journal de la combinaison | 20261026-issue297-journal-combinaison-mw.md |
| Versionnable (--ecrire) | oui |
| Contrôles d'intégrité | OK dans les 18 sorties ; invariants (d) relus sur les champs ; couvertures exactes ; (i3) : empreinte égale dans les sorties et à la combinaison |

### Aide à la lecture

Statut : **constat de simulation sous un plan** (modèle de Mack ajusté à reserve2), pas un résultat général ; il ne se transpose ni à une autre géométrie de triangle ni à un autre paramétrage. Aucun théorème ne couvre ce test bootstrap à T = 8 ; Dwass (1957) et Hope (1968) ne fondent que le témoin oracle. IC : Clopper-Pearson à 95 %, incertitude Monte-Carlo sur le taux (fonction de R), distincte de l'erreur de ρ (fonction de N0) et de err_mc (fonction de B = 999, donnée du test calibré). Bande de Bradley : convention de lecture (#166), pas théorème.

Lecture conjointe (#297) : p de famille et p globale minP en une étape (engine_p_famille()), diagnostics sans verdict ; leur niveau sous H0 est un **constat de simulation sous ce plan**, la p de famille étant une p plug-in, non exacte, comme chaque p Monte-Carlo (spécification de Fk, par. 1.1). Référence ρ_F = 0,099 et 0,049 (par. 5.3), majorant en présence d'atomes de la plus petite p ; la remesure par clé (ρ, K1 à K5) suit la spécification de #206, inchangée.

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

**Critère de la spécification de #206 (par. 5), pour la remesure par clé, reporté sans modification :**

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

Annotation du 24/10/2026 de la spécification de #206, point 4 : la liste « à la frontière » du critère ci-dessus (BP, Origine, HomogF) est retirée ; l'ensemble est désormais lu dans la référence versionnée (règle de #244), liste calculée dans l'évaluation de K1 à K5 plus bas.

### Évaluation mécanique de K-F1 à K-F4 et des profils Φ (sans conclusion)

États calculés par le script ; la lecture revient à actuary, la décision éventuelle au mainteneur (D2-Fk, Q-D1-Fk-9 : décision requise sous Φ0, Φ4 ou Φ5 seulement).

| Condition | État mécanique | Détail |
| --- | --- | --- |
| K-F1 (principal) | évaluée | N : compatible 4, écart mineur 4, écart non tranché 0, distorsion matérielle 0 ; E : compatible 6, écart mineur 2, écart non tranché 0, distorsion matérielle 0 |
| K-F2 (descriptif, T4) | descriptif | voir T-F3 et T4 |
| K-F3 (intégrité) | remplie | INTEGRITE OK et contrôle (K-F3) OK dans chaque sortie de tranche (refus de --combiner sinon) |
| K-F4 (frontière, descriptif) | descriptif | voir T-F4 ; par clé : T4 |

| Profil | Condition mécanique | Présent | Cellules |
| --- | --- | --- | --- |
| Φ0 | K-F3, ou K3 ou K4 de #206, en défaut (« sans explication » : jugement d'actuary) | **oui** | K-F3 : rempli (INTEGRITE OK et ligne (K-F3) OK dans chaque sortie de tranche) ; K3 : **témoin(s) significatif(s)** ; K4 : remplie |
| Φ1 | toutes les p de famille et la p globale compatibles ou en écart mineur, aux deux α, sous chaque jeu ou loi | **oui** | aucune |
| Φ2 | pas de distorsion matérielle, des écarts non tranchés | non | aucune |
| Φ3 | distorsion matérielle conservatrice seulement | non | aucune |
| Φ4 | distorsion matérielle libérale pour au moins une (famille, jeu ou loi, α) | non | aucune |
| Φ5 | même famille : distorsions de côtés opposés entre jeux ou lois | non | — |

Cellules non évaluables (aucune ligne de la famille sous le jeu ou la loi, hors profils) : N M4 0,10 ; N M4 0,05 ; E M4 0,10 ; E M4 0,05.

Profils propres à ce volet : la ligne globale LC de la méthode lognormale et celle de Merz-Wüthrich sont deux familles distinctes, et Φ5 reste interne à un volet. Profil global de D2-Fk = union des profils présents dans les deux volets ; décision requise si Φ0, Φ4 ou Φ5 apparaît dans l'un ou l'autre.

### T-F1 — niveau sous H0 des p de famille et de la p globale (K-F1)

Par loi, famille et seuil : n triangles admis où la ligne est présente (k ≥ 2), dont les p absentes (B effectif de famille < 50, texte T-3b ; comptées comme non-rejet) ; k rejets (p < α) ; taux k / n et IC de Clopper-Pearson à 95 % (5 décimales ; classe sur les valeurs non arrondies) ; référence ρ_F, taille du test de Monte-Carlo idéal à B_eff = 999 pour une statistique sans atome (majorant en présence d'atomes) ; classe de #166 et #206 (côté en gras si l'IC est disjoint de la bande [ρ_F/2 ; 3ρ_F/2]).

| Loi | Famille | admis | n (ligne présente) | abs. T-3b | ρ_F 0,10 | k 0,10 | taux [IC] 0,10 | classe 0,10 | ρ_F 0,05 | k 0,05 | taux [IC] 0,05 | classe 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | M1 | 2000 | 2000 | 0 | 0,099 | 185 | 0,09250 [0,08016 ; 0,10605] | compatible | 0,049 | 79 | 0,03950 [0,03139 ; 0,04899] | écart mineur |
| N | M2 | 2000 | 2000 | 0 | 0,099 | 176 | 0,08800 [0,07595 ; 0,10128] | compatible | 0,049 | 75 | 0,03750 [0,02961 ; 0,04678] | écart mineur |
| N | M3 | 2000 | 2000 | 0 | 0,099 | 192 | 0,09600 [0,08344 ; 0,10976] | compatible | 0,049 | 88 | 0,04400 [0,03544 ; 0,05393] | compatible |
| N | M4 | 2000 | 0 | 0 | 0,099 | 0 | — — | non évaluable (n = 0) | 0,049 | 0 | — — | non évaluable (n = 0) |
| N | LC (globale) | 2000 | 2000 | 0 | 0,099 | 143 | 0,07150 [0,06059 ; 0,08368] | écart mineur | 0,049 | 73 | 0,03650 [0,02872 ; 0,04568] | écart mineur |
| E | M1 | 2000 | 2000 | 0 | 0,099 | 170 | 0,08500 [0,07314 ; 0,09809] | écart mineur | 0,049 | 81 | 0,04050 [0,03229 ; 0,05009] | compatible |
| E | M2 | 2000 | 2000 | 0 | 0,099 | 192 | 0,09600 [0,08344 ; 0,10976] | compatible | 0,049 | 100 | 0,05000 [0,04086 ; 0,06048] | compatible |
| E | M3 | 2000 | 2000 | 0 | 0,099 | 203 | 0,10150 [0,08861 ; 0,11557] | compatible | 0,049 | 91 | 0,04550 [0,03679 ; 0,05557] | compatible |
| E | M4 | 2000 | 0 | 0 | 0,099 | 0 | — — | non évaluable (n = 0) | 0,049 | 0 | — — | non évaluable (n = 0) |
| E | LC (globale) | 2000 | 2000 | 0 | 0,099 | 172 | 0,08600 [0,07408 ; 0,09915] | compatible | 0,049 | 74 | 0,03700 [0,02916 ; 0,04623] | écart mineur |

### T-F2 — composition des familles : k, présence de la ligne, B effectif, plancher

Sur les triangles admis (pool redressé) : k, nombre de tests membres (règle du par. 1.3 de la spécification de Fk, recomptée par le script) ; ligne présente si k ≥ 2 (Q-D1-Fk-2 (a)), absente pour k ≤ 1 ; présente sans p si le B effectif de famille (réplications où les statistiques de tous les membres sont finies) est < 50 (T-3b) ; masse au plancher : part des p de famille définies égales à 1/(B effectif de famille + 1).

| Loi | Famille | admis | distribution de k (k : triangles) | ligne présente (part) | dont sans p (T-3b) | B effectif de famille : min [médiane] | p définies | masse au plancher |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | M1 | 2000 | 5 : 2000 | 2000 (1,00000) | 0 | 999 [999] | 2000 | 0,00000 |
| N | M2 | 2000 | 2 : 2000 | 2000 (1,00000) | 0 | 999 [999] | 2000 | 0,00000 |
| N | M3 | 2000 | 4 : 2000 | 2000 (1,00000) | 0 | 999 [999] | 2000 | 0,00050 |
| N | M4 | 2000 | 1 : 2000 | 0 (0,00000) | 0 | — | 0 | — |
| N | LC (globale) | 2000 | 12 : 2000 | 2000 (1,00000) | 0 | 999 [999] | 2000 | 0,00000 |
| E | M1 | 2000 | 5 : 2000 | 2000 (1,00000) | 0 | 999 [999] | 2000 | 0,00000 |
| E | M2 | 2000 | 2 : 2000 | 2000 (1,00000) | 0 | 999 [999] | 2000 | 0,00000 |
| E | M3 | 2000 | 4 : 2000 | 2000 (1,00000) | 0 | 999 [999] | 2000 | 0,00000 |
| E | M4 | 2000 | 1 : 2000 | 0 (0,00000) | 0 | — | 0 | — |
| E | LC (globale) | 2000 | 12 : 2000 | 2000 (1,00000) | 0 | 999 [999] | 2000 | 0,00000 |

### T-F3 — multiplicité sous H0 et lecture conjointe (K-F2, descriptif)

Sur les triangles admis (pool redressé) : part à au moins une ALERTE ou un ECHEC, et à au moins un ECHEC, parmi les lignes de type test de mw_tests() (types et verdicts lus à chaque triangle), puis parmi les seules lignes de sens « ne pas rejeter » (les deux lignes de sens « rejeter », TOST et Pitman, sont lognormales : colonnes égales ici) ; part à p globale < α (p absente : non-rejet) ; par famille, part à au moins un test membre de p_mc < α (plus petite p_mc des membres) contre part à p de famille < α (ligne absente ou sans p : non-rejet). Taux descriptifs, sans référence ni classe.

| Loi | n | ≥ 1 A ou E (tests) | ≥ 1 A ou E (tests « ne pas rejeter ») | ≥ 1 E (tests) | ≥ 1 E (tests « ne pas rejeter ») | p globale < 0,10 | p globale < 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| N | 2000 | 0,62450 | 0,62450 | 0,38000 | 0,38000 | 0,07150 | 0,03650 |
| E | 2000 | 0,64000 | 0,64000 | 0,39000 | 0,39000 | 0,08600 | 0,03700 |

| Loi | Famille | n | ≥ 1 membre p_mc < 0,10 | p de famille < 0,10 | ≥ 1 membre p_mc < 0,05 | p de famille < 0,05 |
| --- | --- | --- | --- | --- | --- | --- |
| N | M1 | 2000 | 0,31800 | 0,09250 | 0,17300 | 0,03950 |
| N | M2 | 2000 | 0,16750 | 0,08800 | 0,08050 | 0,03750 |
| N | M3 | 2000 | 0,31150 | 0,09600 | 0,16700 | 0,04400 |
| N | M4 | 2000 | 0,07100 | 0,00000 | 0,02900 | 0,00000 |
| N | LC (globale) | 2000 | 0,62450 | 0,07150 | 0,38000 | 0,03650 |
| E | M1 | 2000 | 0,31500 | 0,08500 | 0,16400 | 0,04050 |
| E | M2 | 2000 | 0,17150 | 0,09600 | 0,09200 | 0,05000 |
| E | M3 | 2000 | 0,32300 | 0,10150 | 0,16550 | 0,04550 |
| E | M4 | 2000 | 0,07850 | 0,00000 | 0,03950 | 0,00000 |
| E | LC (globale) | 2000 | 0,64000 | 0,08600 | 0,39000 | 0,03700 |

### T-F4 — voisinage des seuils des p de famille (K-F4, descriptif)

Fréquence sous H0 de |p − s| < 2 err_mc, s ∈ {0,10 ; 0,05}, sur les p de famille définies (err_mc = √(p (1 − p)/B_eff), queue simple) ; la même fréquence par clé du catalogue est en T4 (remesure de #206).

| Loi | Famille | p définies | \|p − 0,10\| < 2 err_mc | \|p − 0,05\| < 2 err_mc |
| --- | --- | --- | --- | --- |
| N | M1 | 2000 | 0,03850 | 0,02600 |
| N | M2 | 2000 | 0,03850 | 0,02500 |
| N | M3 | 2000 | 0,04450 | 0,02850 |
| N | M4 | 0 | — | — |
| N | LC (globale) | 2000 | 0,03400 | 0,02700 |
| E | M1 | 2000 | 0,03200 | 0,02500 |
| E | M2 | 2000 | 0,03200 | 0,03300 |
| E | M3 | 2000 | 0,03800 | 0,02550 |
| E | M4 | 0 | — | — |
| E | LC (globale) | 2000 | 0,04200 | 0,02900 |

## Remesure par clé de #206 (K1 à K5, spécification de #206, par. 5, inchangés)

### Référence ρ et diagnostics de l'oracle (par. 4)

ρ : taille lissée à B = 999 du test de Monte-Carlo idéal tirant ses répliques dans F0 (règle « ≥ » d'engine_p_mc(), une règle unique pour toutes les statistiques, aucune classification a priori) ; statistique oracle non finie comptée comme non-rejet. Erreur de ρ due à N0 : de l'ordre de 0,002 à α = 0,10 [H], distincte de l'IC sur τ (fonction de R) et de err_mc (fonction de B). Taille du témoin : même règle à B = N0 fini, même dénominateur (oracle admis ; statistique non finie comptée comme non-rejet, comme pour ρ) ; nominale continue à B = nombre de statistiques finies entre parenthèses (un écart taille < nominale peut venir des non finies ou des atomes). ρ marqué « approché » au-delà de 1 % de statistiques oracle non finies pour la clé (ρ suppose alors B = 999 répliques finies ; annotation du 10/10/2026 de la spécification, point 2 (a)).

| Loi | Clé (sens) | oracle admis | non finies | valeurs distinctes | masse du plus gros atome | ρ 0,10 | ρ 0,05 | taille témoin 0,10 (nominale) | taille témoin 0,05 (nominale) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | Calendrier (bas) | 20000 | 0 | 84 | 0,10130 | 0,09004 | 0,04119 | 0,09551 (0,10000) | 0,04200 (0,05000) |
| N | CorrDev (deux) | 20000 | 0 | 1026 | 0,00415 | 0,09751 | 0,04761 | 0,09945 (0,10000) | 0,04962 (0,05000) |
| N | BP (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| N | MinP4 (bas) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| N | DW (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 (0,10000) | 0,04995 (0,05000) |
| N | Runs (deux) | 20000 | 0 | 17 | 0,16825 | 0,05122 | 0,03020 | 0,04630 (0,10000) | 0,02814 (0,05000) |
| N | PenteIntra (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 (0,10000) | 0,04995 (0,05000) |
| N | Origine (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| N | HomogF (haut) | 20000 | 0 | 10898 | 0,00065 | 0,09896 | 0,04896 | 0,09996 (0,10000) | 0,04996 (0,05000) |
| N | Courbure (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| N | Alpha (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| N | ExpVar (haut) | 20000 | 0 | 10902 | 0,00080 | 0,09896 | 0,04897 | 0,09995 (0,10000) | 0,04996 (0,05000) |
| N | KruskalAcc (haut) | 20000 | 0 | 13636 | 0,00045 | 0,09896 | 0,04897 | 0,09996 (0,10000) | 0,04997 (0,05000) |
| E | Calendrier (bas) | 20000 | 0 | 86 | 0,10535 | 0,09183 | 0,04120 | 0,09330 (0,10000) | 0,04155 (0,05000) |
| E | CorrDev (deux) | 20000 | 0 | 1020 | 0,00345 | 0,09751 | 0,04760 | 0,09951 (0,10000) | 0,04964 (0,05000) |
| E | BP (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| E | MinP4 (bas) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| E | DW (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 (0,10000) | 0,04995 (0,05000) |
| E | Runs (deux) | 20000 | 0 | 17 | 0,17745 | 0,05311 | 0,03103 | 0,04687 (0,10000) | 0,03639 (0,05000) |
| E | PenteIntra (deux) | 20000 | 0 | 20000 | 0,00005 | 0,09795 | 0,04795 | 0,09995 (0,10000) | 0,04995 (0,05000) |
| E | Origine (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| E | HomogF (haut) | 20000 | 0 | 10796 | 0,00065 | 0,09896 | 0,04896 | 0,09995 (0,10000) | 0,04996 (0,05000) |
| E | Courbure (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| E | Alpha (haut) | 20000 | 0 | 20000 | 0,00005 | 0,09897 | 0,04897 | 0,09997 (0,10000) | 0,04997 (0,05000) |
| E | ExpVar (haut) | 20000 | 0 | 10892 | 0,00065 | 0,09896 | 0,04896 | 0,09995 (0,10000) | 0,04996 (0,05000) |
| E | KruskalAcc (haut) | 20000 | 0 | 13623 | 0,00045 | 0,09896 | 0,04897 | 0,09996 (0,10000) | 0,04997 (0,05000) |

### Évaluation mécanique de K1 à K5, profils Π et R (sans conclusion)

Les états ci-dessous sont calculés par le script ; la lecture (et la part « non expliqué » de Π0) revient à actuary, la conséquence au mainteneur (B3).

| Condition | État mécanique | Détail |
| --- | --- | --- |
| K1 (niveau, pool redressé) | évaluée | N : compatible 20, écart mineur 6, écart non tranché 0, distorsion matérielle 0 ; E : compatible 22, écart mineur 4, écart non tranché 0, distorsion matérielle 0 |
| K2 (brut contre redressé, McNemar, Holm) | non évaluable (pool brut absent) | — |
| K3 (témoins oracle) | **témoin(s) significatif(s) : lecture suspendue jusqu'à explication** | N HomogF 0,05 (k = 71 / 2000, taille 0,04996, p Holm 0,0314) ; E Runs 0,05 (k = 44 / 2000, taille 0,03639, p Holm 0,00422) |
| K4 (p absentes, au plus 1 % par (loi, pool)) | remplie | N redressé 0,00000 (0 / 2000) ; E redressé 0,00000 (0 / 2000) |
| K5 (B effectif, descriptif) | descriptif | voir T5 |
| Refus des triangles (au-delà de 1 % : signalé, par. 2) | sous 1 % | N 0,00000 ; E 0,00000 |

| Profil | Condition mécanique | Présent | Cellules |
| --- | --- | --- | --- |
| Π0 | K3 ou K4 en défaut (« non expliqué » : jugement d'actuary) | **oui** | voir K3 et K4 |
| Π1 | sous N et E, les 13 lignes compatibles ou en écart mineur aux deux seuils | **oui** | aucune |
| Π2 | aucune distorsion matérielle, mais des écarts non tranchés | non | aucune |
| Π3 | distorsion matérielle conservatrice (IC sous ρ/2) | non | aucune |
| Π4 | distorsion matérielle libérale | non | aucune |
| Π5 | même clé et même seuil : distorsions matérielles de côtés opposés (libéral et conservateur) entre deux lois | non | aucune |

Indication descriptive, hors profil (lecture large de Π5, annotation du 10/10/2026 de la spécification, point 3) : même clé et même seuil, classes non compatibles de part et d'autre de ρ entre lois : aucune.

| Effet de #46 (K2) | Présent | Cellules |
| --- | --- | --- |
| R1 : aucun McNemar significatif après Holm | non évaluable | — |
| R2 : effet significatif qui rapproche τ de ρ (\|τ_R − ρ\| < \|τ_B − ρ\|) | non | — |
| R3 : effet significatif qui éloigne τ de ρ | non | — |

Lignes « à la frontière » de reserve2 (ensemble « à la frontière » lu dans tests/reference/reserve2.rds (lignes de type test, sens « ne pas rejeter », detail terminé par PHRASE_VERDICT_SENSIBLE_MC) : PenteIntra (p_mc 0,090, err_mc 0,0131), Origine (p_mc 0,085, err_mc 0,0088) ; inégalité |p_mc − s| < 2 err_mc recalculée (s atteignable) : accord sur toutes les lignes), classe par loi et seuil : N PenteIntra 0,10 : écart mineur ; N PenteIntra 0,05 : écart mineur ; N Origine 0,10 : compatible ; N Origine 0,05 : compatible ; E PenteIntra 0,10 : compatible ; E PenteIntra 0,05 : compatible ; E Origine 0,10 : compatible ; E Origine 0,05 : compatible.

### T1 — niveau du pool redressé (critère principal K1)

Par seuil : n triangles admis, p absentes (comptées comme non-rejet), k rejets (p_mc < α), taux k / n et IC de Clopper-Pearson à 95 % (5 décimales), classe de #166 contre ρ (côté en gras si l'IC est disjoint de la bande [ρ/2 ; 3ρ/2]), taux sur les seules p définies (descriptif).

| Loi | Clé (sens) | n | abs. 0,10 | ρ 0,10 | k 0,10 | taux [IC] 0,10 | classe 0,10 | taux déf. 0,10 | abs. 0,05 | ρ 0,05 | k 0,05 | taux [IC] 0,05 | classe 0,05 | taux déf. 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | Calendrier (bas) | 2000 | 0 | 0,09004 | 180 | 0,09000 [0,07782 ; 0,10340] | compatible | 0,09000 | 0 | 0,04119 | 89 | 0,04450 [0,03589 ; 0,05448] | compatible | 0,04450 |
| N | CorrDev (deux) | 2000 | 0 | 0,09751 | 193 | 0,09650 [0,08391 ; 0,11029] | compatible | 0,09650 | 0 | 0,04761 | 103 | 0,05150 [0,04223 ; 0,06211] | compatible | 0,05150 |
| N | BP (haut) | 2000 | 0 | 0,09897 | 178 | 0,08900 [0,07688 ; 0,10234] | compatible | 0,08900 | 0 | 0,04897 | 82 | 0,04100 [0,03274 ; 0,05064] | compatible | 0,04100 |
| N | MinP4 (bas) | 2000 | 0 | 0,09897 | 142 | 0,07100 [0,06013 ; 0,08315] | écart mineur | 0,07100 | 0 | 0,04897 | 58 | 0,02900 [0,02209 ; 0,03733] | écart mineur | 0,02900 |
| N | DW (deux) | 2000 | 0 | 0,09795 | 171 | 0,08550 [0,07361 ; 0,09862] | compatible | 0,08550 | 0 | 0,04795 | 91 | 0,04550 [0,03679 ; 0,05557] | compatible | 0,04550 |
| N | Runs (deux) | 2000 | 0 | 0,05122 | 116 | 0,05800 [0,04816 ; 0,06916] | compatible | 0,05800 | 0 | 0,03020 | 55 | 0,02750 [0,02078 ; 0,03565] | compatible | 0,02750 |
| N | PenteIntra (deux) | 2000 | 0 | 0,09795 | 223 | 0,11150 [0,09803 ; 0,12612] | écart mineur | 0,11150 | 0 | 0,04795 | 122 | 0,06100 [0,05091 ; 0,07240] | écart mineur | 0,06100 |
| N | Origine (haut) | 2000 | 0 | 0,09897 | 176 | 0,08800 [0,07595 ; 0,10128] | compatible | 0,08800 | 0 | 0,04897 | 84 | 0,04200 [0,03364 ; 0,05174] | compatible | 0,04200 |
| N | HomogF (haut) | 2000 | 0 | 0,09896 | 191 | 0,09550 [0,08297 ; 0,10923] | compatible | 0,09550 | 0 | 0,04896 | 78 | 0,03900 [0,03095 ; 0,04844] | écart mineur | 0,03900 |
| N | Courbure (haut) | 2000 | 0 | 0,09897 | 186 | 0,09300 [0,08063 ; 0,10658] | compatible | 0,09300 | 0 | 0,04897 | 89 | 0,04450 [0,03589 ; 0,05448] | compatible | 0,04450 |
| N | Alpha (haut) | 2000 | 0 | 0,09897 | 191 | 0,09550 [0,08297 ; 0,10923] | compatible | 0,09550 | 0 | 0,04897 | 77 | 0,03850 [0,03050 ; 0,04789] | écart mineur | 0,03850 |
| N | ExpVar (haut) | 2000 | 0 | 0,09896 | 191 | 0,09550 [0,08297 ; 0,10923] | compatible | 0,09550 | 0 | 0,04897 | 92 | 0,04600 [0,03724 ; 0,05612] | compatible | 0,04600 |
| N | KruskalAcc (haut) | 2000 | 0 | 0,09896 | 192 | 0,09600 [0,08344 ; 0,10976] | compatible | 0,09600 | 0 | 0,04897 | 101 | 0,05050 [0,04132 ; 0,06103] | compatible | 0,05050 |
| E | Calendrier (bas) | 2000 | 0 | 0,09183 | 186 | 0,09300 [0,08063 ; 0,10658] | compatible | 0,09300 | 0 | 0,04120 | 76 | 0,03800 [0,03005 ; 0,04733] | compatible | 0,03800 |
| E | CorrDev (deux) | 2000 | 0 | 0,09751 | 199 | 0,09950 [0,08673 ; 0,11346] | compatible | 0,09950 | 0 | 0,04760 | 104 | 0,05200 [0,04268 ; 0,06266] | compatible | 0,05200 |
| E | BP (haut) | 2000 | 0 | 0,09897 | 194 | 0,09700 [0,08438 ; 0,11082] | compatible | 0,09700 | 0 | 0,04897 | 106 | 0,05300 [0,04359 ; 0,06374] | compatible | 0,05300 |
| E | MinP4 (bas) | 2000 | 0 | 0,09897 | 157 | 0,07850 [0,06709 ; 0,09117] | écart mineur | 0,07850 | 0 | 0,04897 | 79 | 0,03950 [0,03139 ; 0,04899] | compatible | 0,03950 |
| E | DW (deux) | 2000 | 0 | 0,09795 | 202 | 0,10100 [0,08814 ; 0,11505] | compatible | 0,10100 | 0 | 0,04795 | 106 | 0,05300 [0,04359 ; 0,06374] | compatible | 0,05300 |
| E | Runs (deux) | 2000 | 0 | 0,05311 | 105 | 0,05250 [0,04314 ; 0,06320] | compatible | 0,05250 | 0 | 0,03103 | 45 | 0,02250 [0,01646 ; 0,02999] | écart mineur | 0,02250 |
| E | PenteIntra (deux) | 2000 | 0 | 0,09795 | 221 | 0,11050 [0,09709 ; 0,12506] | compatible | 0,11050 | 0 | 0,04795 | 109 | 0,05450 [0,04496 ; 0,06537] | compatible | 0,05450 |
| E | Origine (haut) | 2000 | 0 | 0,09897 | 194 | 0,09700 [0,08438 ; 0,11082] | compatible | 0,09700 | 0 | 0,04897 | 95 | 0,04750 [0,03860 ; 0,05776] | compatible | 0,04750 |
| E | HomogF (haut) | 2000 | 0 | 0,09896 | 178 | 0,08900 [0,07688 ; 0,10234] | compatible | 0,08900 | 0 | 0,04896 | 83 | 0,04150 [0,03319 ; 0,05119] | compatible | 0,04150 |
| E | Courbure (haut) | 2000 | 0 | 0,09897 | 160 | 0,08000 [0,06848 ; 0,09277] | écart mineur | 0,08000 | 0 | 0,04897 | 72 | 0,03600 [0,02827 ; 0,04512] | écart mineur | 0,03600 |
| E | Alpha (haut) | 2000 | 0 | 0,09897 | 194 | 0,09700 [0,08438 ; 0,11082] | compatible | 0,09700 | 0 | 0,04897 | 84 | 0,04200 [0,03364 ; 0,05174] | compatible | 0,04200 |
| E | ExpVar (haut) | 2000 | 0 | 0,09896 | 190 | 0,09500 [0,08250 ; 0,10870] | compatible | 0,09500 | 0 | 0,04896 | 99 | 0,04950 [0,04041 ; 0,05994] | compatible | 0,04950 |
| E | KruskalAcc (haut) | 2000 | 0 | 0,09896 | 201 | 0,10050 [0,08767 ; 0,11452] | compatible | 0,10050 | 0 | 0,04897 | 98 | 0,04900 [0,03996 ; 0,05939] | compatible | 0,04900 |

### T3 — témoins oracle (K3)

p_or = engine_p_mc(S0, s_obs, sens) contre l'échantillon oracle de la loi (N0 triangles i.i.d. du même DGP) ; test binomial exact bilatéral du taux τ_or contre la taille du témoin (tableau de ρ), Holm sur les 13 clés par (loi, α). Un témoin significatif suspend la lecture jusqu'à explication (par. 5). Limite déclarée (annotation du 10/10/2026 de la spécification, point 2) : un seul échantillon oracle sert à tous les triangles mesurés ; Var(τ_or) vaut donc environ α(1 − α)(1/n + 1/N0), et non α(1 − α)/n. À n = 2 000 et N0 = 20 000, l'écart-type est multiplié par environ 1,05 et le binomial nominal à 5 % rejette environ 6 % du temps quand la mesure est correcte [calcul d'ordre de grandeur, non simulé]. Ce léger excès de signalement n'est pas corrigé ; il entre dans le jugement « non expliqué » de Π0.

| Loi | α | Clé (sens) | n | p_or absentes | k | τ_or [IC] | taille | p binomiale | p Holm | significatif |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | 0,10 | Calendrier (bas) | 2000 | 0 | 185 | 0,09250 [0,08016 ; 0,10605] | 0,09551 | 0,676 | 1 | non |
| N | 0,10 | CorrDev (deux) | 2000 | 0 | 197 | 0,09850 [0,08579 ; 0,11240] | 0,09945 | 0,911 | 1 | non |
| N | 0,10 | BP (haut) | 2000 | 0 | 185 | 0,09250 [0,08016 ; 0,10605] | 0,09997 | 0,28 | 1 | non |
| N | 0,10 | MinP4 (bas) | 2000 | 0 | 211 | 0,10550 [0,09237 ; 0,11980] | 0,09997 | 0,412 | 1 | non |
| N | 0,10 | DW (deux) | 2000 | 0 | 178 | 0,08900 [0,07688 ; 0,10234] | 0,09995 | 0,109 | 1 | non |
| N | 0,10 | Runs (deux) | 2000 | 0 | 95 | 0,04750 [0,03860 ; 0,05776] | 0,04630 | 0,79 | 1 | non |
| N | 0,10 | PenteIntra (deux) | 2000 | 0 | 200 | 0,10000 [0,08720 ; 0,11399] | 0,09995 | 0,97 | 1 | non |
| N | 0,10 | Origine (haut) | 2000 | 0 | 179 | 0,08950 [0,07735 ; 0,10287] | 0,09997 | 0,126 | 1 | non |
| N | 0,10 | HomogF (haut) | 2000 | 0 | 195 | 0,09750 [0,08485 ; 0,11135] | 0,09996 | 0,737 | 1 | non |
| N | 0,10 | Courbure (haut) | 2000 | 0 | 208 | 0,10400 [0,09096 ; 0,11821] | 0,09997 | 0,551 | 1 | non |
| N | 0,10 | Alpha (haut) | 2000 | 0 | 175 | 0,08750 [0,07548 ; 0,10075] | 0,09997 | 0,0624 | 0,811 | non |
| N | 0,10 | ExpVar (haut) | 2000 | 0 | 189 | 0,09450 [0,08203 ; 0,10817] | 0,09995 | 0,434 | 1 | non |
| N | 0,10 | KruskalAcc (haut) | 2000 | 0 | 194 | 0,09700 [0,08438 ; 0,11082] | 0,09996 | 0,682 | 1 | non |
| N | 0,05 | Calendrier (bas) | 2000 | 0 | 90 | 0,04500 [0,03634 ; 0,05503] | 0,04200 | 0,503 | 1 | non |
| N | 0,05 | CorrDev (deux) | 2000 | 0 | 103 | 0,05150 [0,04223 ; 0,06211] | 0,04962 | 0,68 | 1 | non |
| N | 0,05 | BP (haut) | 2000 | 0 | 90 | 0,04500 [0,03634 ; 0,05503] | 0,04997 | 0,33 | 1 | non |
| N | 0,05 | MinP4 (bas) | 2000 | 0 | 113 | 0,05650 [0,04679 ; 0,06754] | 0,04997 | 0,182 | 1 | non |
| N | 0,05 | DW (deux) | 2000 | 0 | 98 | 0,04900 [0,03996 ; 0,05939] | 0,04995 | 0,918 | 1 | non |
| N | 0,05 | Runs (deux) | 2000 | 0 | 54 | 0,02700 [0,02035 ; 0,03508] | 0,02814 | 0,839 | 1 | non |
| N | 0,05 | PenteIntra (deux) | 2000 | 0 | 109 | 0,05450 [0,04496 ; 0,06537] | 0,04995 | 0,355 | 1 | non |
| N | 0,05 | Origine (haut) | 2000 | 0 | 87 | 0,04350 [0,03499 ; 0,05338] | 0,04997 | 0,199 | 1 | non |
| N | 0,05 | HomogF (haut) | 2000 | 0 | 71 | 0,03550 [0,02783 ; 0,04457] | 0,04996 | 0,00241 | 0,0314 | **oui** |
| N | 0,05 | Courbure (haut) | 2000 | 0 | 109 | 0,05450 [0,04496 ; 0,06537] | 0,04997 | 0,355 | 1 | non |
| N | 0,05 | Alpha (haut) | 2000 | 0 | 87 | 0,04350 [0,03499 ; 0,05338] | 0,04997 | 0,199 | 1 | non |
| N | 0,05 | ExpVar (haut) | 2000 | 0 | 89 | 0,04450 [0,03589 ; 0,05448] | 0,04996 | 0,281 | 1 | non |
| N | 0,05 | KruskalAcc (haut) | 2000 | 0 | 97 | 0,04850 [0,03950 ; 0,05885] | 0,04997 | 0,837 | 1 | non |
| E | 0,10 | Calendrier (bas) | 2000 | 0 | 197 | 0,09850 [0,08579 ; 0,11240] | 0,09330 | 0,419 | 1 | non |
| E | 0,10 | CorrDev (deux) | 2000 | 0 | 208 | 0,10400 [0,09096 ; 0,11821] | 0,09951 | 0,501 | 1 | non |
| E | 0,10 | BP (haut) | 2000 | 0 | 206 | 0,10300 [0,09002 ; 0,11716] | 0,09997 | 0,655 | 1 | non |
| E | 0,10 | MinP4 (bas) | 2000 | 0 | 202 | 0,10100 [0,08814 ; 0,11505] | 0,09997 | 0,881 | 1 | non |
| E | 0,10 | DW (deux) | 2000 | 0 | 202 | 0,10100 [0,08814 ; 0,11505] | 0,09995 | 0,852 | 1 | non |
| E | 0,10 | Runs (deux) | 2000 | 0 | 79 | 0,03950 [0,03139 ; 0,04899] | 0,04687 | 0,125 | 1 | non |
| E | 0,10 | PenteIntra (deux) | 2000 | 0 | 202 | 0,10100 [0,08814 ; 0,11505] | 0,09995 | 0,852 | 1 | non |
| E | 0,10 | Origine (haut) | 2000 | 0 | 204 | 0,10200 [0,08908 ; 0,11610] | 0,09997 | 0,766 | 1 | non |
| E | 0,10 | HomogF (haut) | 2000 | 0 | 189 | 0,09450 [0,08203 ; 0,10817] | 0,09995 | 0,434 | 1 | non |
| E | 0,10 | Courbure (haut) | 2000 | 0 | 172 | 0,08600 [0,07408 ; 0,09915] | 0,09997 | 0,0368 | 0,479 | non |
| E | 0,10 | Alpha (haut) | 2000 | 0 | 192 | 0,09600 [0,08344 ; 0,10976] | 0,09997 | 0,576 | 1 | non |
| E | 0,10 | ExpVar (haut) | 2000 | 0 | 193 | 0,09650 [0,08391 ; 0,11029] | 0,09995 | 0,628 | 1 | non |
| E | 0,10 | KruskalAcc (haut) | 2000 | 0 | 202 | 0,10100 [0,08814 ; 0,11505] | 0,09996 | 0,881 | 1 | non |
| E | 0,05 | Calendrier (bas) | 2000 | 0 | 72 | 0,03600 [0,02827 ; 0,04512] | 0,04155 | 0,239 | 1 | non |
| E | 0,05 | CorrDev (deux) | 2000 | 0 | 110 | 0,05500 [0,04542 ; 0,06591] | 0,04964 | 0,279 | 1 | non |
| E | 0,05 | BP (haut) | 2000 | 0 | 109 | 0,05450 [0,04496 ; 0,06537] | 0,04997 | 0,355 | 1 | non |
| E | 0,05 | MinP4 (bas) | 2000 | 0 | 105 | 0,05250 [0,04314 ; 0,06320] | 0,04997 | 0,608 | 1 | non |
| E | 0,05 | DW (deux) | 2000 | 0 | 103 | 0,05150 [0,04223 ; 0,06211] | 0,04995 | 0,72 | 1 | non |
| E | 0,05 | Runs (deux) | 2000 | 0 | 44 | 0,02200 [0,01603 ; 0,02942] | 0,03639 | 0,000324 | 0,00422 | **oui** |
| E | 0,05 | PenteIntra (deux) | 2000 | 0 | 88 | 0,04400 [0,03544 ; 0,05393] | 0,04995 | 0,238 | 1 | non |
| E | 0,05 | Origine (haut) | 2000 | 0 | 95 | 0,04750 [0,03860 ; 0,05776] | 0,04997 | 0,644 | 1 | non |
| E | 0,05 | HomogF (haut) | 2000 | 0 | 84 | 0,04200 [0,03364 ; 0,05174] | 0,04996 | 0,111 | 1 | non |
| E | 0,05 | Courbure (haut) | 2000 | 0 | 76 | 0,03800 [0,03005 ; 0,04733] | 0,04997 | 0,0136 | 0,164 | non |
| E | 0,05 | Alpha (haut) | 2000 | 0 | 110 | 0,05500 [0,04542 ; 0,06591] | 0,04997 | 0,304 | 1 | non |
| E | 0,05 | ExpVar (haut) | 2000 | 0 | 100 | 0,05000 [0,04086 ; 0,06048] | 0,04996 | 0,959 | 1 | non |
| E | 0,05 | KruskalAcc (haut) | 2000 | 0 | 104 | 0,05200 [0,04268 ; 0,06266] | 0,04997 | 0,681 | 1 | non |

### T4 — verdicts sous H0, multiplicité, voisinage du seuil

Fréquences sur les triangles admis : ALERTE ou ECHEC (A ou E) et ECHEC (E) par ligne de mw_tests() (lignes INFO exclues du dénominateur) ; part des triangles à au moins une ALERTE ou un ECHEC, et à au moins un ECHEC, sur les 13 lignes Monte-Carlo et sur toutes les lignes à verdict (repère 1 − (1 − α)^13 : 0,7458 à α = 0,10, ordre de grandeur et non référence) ; fréquence de |p_mc − α| < 2 err_mc par clé (signalement proposé de Q-206-9), aux deux seuils, sur les p définies.

**Pool redressé.**

| Ligne de mw_tests() | clé | loi N : A ou E / E (n) | loi E : A ou E / E (n) |
| --- | --- | --- | --- |
| Absence de tendance des facteurs avec le cumul, a colonne donnee | PenteIntra | 0,11150 / 0,06100 (2000) | 0,11050 / 0,05450 (2000) |
| Nullite de l'ordonnee a l'origine, colonne par colonne | Origine | 0,08800 / 0,04200 (2000) | 0,09700 / 0,04750 (2000) |
| Homogeneite de f_j entre annees de survenance | HomogF | 0,09550 / 0,03900 (2000) | 0,08900 / 0,04150 (2000) |
| Absence de courbure de la regression | Courbure | 0,09300 / 0,04450 (2000) | 0,08000 / 0,03600 (2000) |
| Stabilite du facteur selon la ponderation (famille alpha) | Alpha | 0,09550 / 0,03850 (2000) | 0,09700 / 0,04200 (2000) |
| Identifiabilite intra-colonne (dispersion des cumuls par colonne) |  | — | — |
| Heteroscedasticite residuelle vs cumul | BP | 0,08900 / 0,04100 (2000) | 0,09700 / 0,05300 (2000) |
| Adequation de l'exposant de variance, colonne par colonne | ExpVar | 0,09550 / 0,04600 (2000) | 0,09500 / 0,04950 (2000) |
| Variance unitaire des residus de Mack |  | — | — |
| Effets d'annee calendaire (test de Mack) | Calendrier | 0,09000 / 0,04450 (2000) | 0,09300 / 0,03800 (2000) |
| Effets d'annee calendaire par diagonale (repere de Mack 1997) |  | — | — |
| Homogeneite des residus entre annees de survenance | KruskalAcc | 0,09600 / 0,05050 (2000) | 0,10050 / 0,04900 (2000) |
| Correlation entre annees de developpement adjacentes | CorrDev | 0,09650 / 0,05150 (2000) | 0,09950 / 0,05200 (2000) |
| Autocorrelation des residus (Durbin-Watson) | DW | 0,08550 / 0,04550 (2000) | 0,10100 / 0,05300 (2000) |
| Test des suites sur les residus de Mack | Runs | — | — |
| Cellule aberrante du triangle (residus studentises externes) | MinP4 | 0,07100 / 0,02900 (2000) | 0,07850 / 0,03950 (2000) |
| Cellules aberrantes multiples (ESD generalise) |  | — | — |
| Shapiro-Wilk sur les residus de Mack |  | — | — |
| Lilliefors sur les residus de Mack |  | — | — |
| Extrapolation de sigma pour la derniere annee de developpement |  | — | — |
| Part de la reserve portee par la derniere annee d'accident |  | — | — |
| p de famille (minP, lecture conjointe) [M1] |  | — | — |
| p de famille (minP, lecture conjointe) [M2] |  | — | — |
| p de famille (minP, lecture conjointe) [M3] |  | — | — |
| p globale (minP, lecture conjointe de la batterie) [LC] |  | — | — |

| Loi | n | ≥ 1 A ou E (13 lignes MC) | ≥ 1 E (13 lignes MC) | ≥ 1 A ou E (toutes lignes à verdict) | ≥ 1 E (toutes lignes à verdict) |
| --- | --- | --- | --- | --- | --- |
| N | 2000 | 0,62450 | 0,38000 | 0,62450 | 0,38000 |
| E | 2000 | 0,64000 | 0,39000 | 0,64000 | 0,39000 |

| Loi | Clé | p définies | \|p − 0,10\| < 2 err_mc | \|p − 0,05\| < 2 err_mc |
| --- | --- | --- | --- | --- |
| N | Calendrier | 2000 | 0,03500 | 0,01950 |
| N | CorrDev | 2000 | 0,05600 | 0,03750 |
| N | BP | 2000 | 0,03400 | 0,02900 |
| N | MinP4 | 2000 | 0,03250 | 0,02400 |
| N | DW | 2000 | 0,05450 | 0,03250 |
| N | Runs | 2000 | 0,04150 | 0,03150 |
| N | PenteIntra | 2000 | 0,05950 | 0,04100 |
| N | Origine | 2000 | 0,03300 | 0,03000 |
| N | HomogF | 2000 | 0,03500 | 0,03000 |
| N | Courbure | 2000 | 0,03950 | 0,02550 |
| N | Alpha | 2000 | 0,04300 | 0,02750 |
| N | ExpVar | 2000 | 0,03400 | 0,02700 |
| N | KruskalAcc | 2000 | 0,03750 | 0,03000 |
| E | Calendrier | 2000 | 0,03950 | 0,02550 |
| E | CorrDev | 2000 | 0,05450 | 0,03700 |
| E | BP | 2000 | 0,03900 | 0,02800 |
| E | MinP4 | 2000 | 0,02650 | 0,02250 |
| E | DW | 2000 | 0,05000 | 0,04600 |
| E | Runs | 2000 | 0,04250 | 0,02300 |
| E | PenteIntra | 2000 | 0,06700 | 0,04050 |
| E | Origine | 2000 | 0,03850 | 0,03050 |
| E | HomogF | 2000 | 0,03950 | 0,02200 |
| E | Courbure | 2000 | 0,03950 | 0,02450 |
| E | Alpha | 2000 | 0,03650 | 0,02800 |
| E | ExpVar | 2000 | 0,02700 | 0,02200 |
| E | KruskalAcc | 2000 | 0,03100 | 0,02950 |

### T5 — B effectif, p absentes, triangles refusés, durées

| Loi | Pool | n admis | B eff. min | B eff. médiane | part des (triangle, clé) à B eff. < 999 | triangles à ≥ 1 p absente (K4) | p absentes par motif | durée par triangle (s) : moy. [méd. ; max] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N | redressé | 2000 | 999 | 999 | 0,00000 | 0 (0,00000) | aucune | 19,4 [19,2 ; 27,1] |
| E | redressé | 2000 | 999 | 999 | 0,00000 | 0 (0,00000) | aucune | 19,4 [19,1 ; 27,6] |

| Loi | triangles | admis | refusés | part refusée | motifs de refus | en erreur |
| --- | --- | --- | --- | --- | --- | --- |
| N | 2000 | 2000 | 0 | 0,00000 | aucun | 0 |
| E | 2000 | 2000 | 0 | 0,00000 | aucun | 0 |
| N (oracle) | 20000 | 20000 | 0 | 0,00000 | aucun | 0 |
| E (oracle) | 20000 | 20000 | 0 | 0,00000 | aucun | 0 |

