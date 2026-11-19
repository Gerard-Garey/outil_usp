> *Versé intégralement par la session principale le 19/11/2026 (`actuary-approfondi`, mission de jugement, matrice § 3).*

> *Rédigé par l'agent actuary (IA).* S5, étape 1b, issue #387 : protocole de mesure de la couverture à T = 8 de l'intervalle bootstrap de σ en Merz-Wüthrich. Consultation en lecture seule sur `claude/bootstrap-merz-wuthrich`, tête `b5efbef`. Le moteur a été lu dans `git show HEAD:R/engine.R` (md5 `40a1713ee16cbff25d319a6bbfd43fca`), jamais dans l'arbre de travail, où `R/engine.R` est modifié par `coder-approfondi`. Je n'ai rien écrit dans le dépôt, ni issue ni commentaire. Mes scripts de mesure sont restés dans le dossier temporaire de la session (`m387/` : `cout.R`, `verif.R`, `leger.R`, `oracle.R`). **Aucune couverture n'a été calculée avant la fixation du critère** : j'ai mesuré les coûts et les taux d'admission, jamais un intervalle.

## 0. Synthèse

**Verdict : protocole prêt pour `coder-approfondi` (étape 4), sous les décisions Q-1b-1 à Q-1b-8 du mainteneur (§ 5).**

Quatre constats changent la lettre du brief ou du plan :

1. **La vraie valeur de σ n'est pas un paramètre du modèle** (*vérifié*, lecture de `mw_parametre()` et de `mw_msep()`). σ̂ = √MSEP / R̂ dépend des paramètres et aussi des cumuls observés du triangle (diagonale, sommes de colonnes). On ne peut donc pas reprendre telle quelle la cible σ0 = σ(δ0, γ0) de #305. Je retiens comme cible principale σ_A = σ̂ du triangle générateur. Elle correspond exactement à la définition de la vérité dans le monde du bootstrap (§ 2, P3). La cible conditionnelle σ_B est mesurée à titre descriptif.
2. **Une boucle allégée reproduit `sigma_boot` au bit près pour 1/40 du coût** (*vérifié*). Elle refait les tirages et calcule seulement `mw_ajuster()` et `mw_msep()`, sans les 13 statistiques.
   - Triangle « volatil » de A.0 : 0,37 s au lieu de 15,05 s, `identical(sigma_boot)` TRUE, 453 réplications sans σ*.
   - `reserve2` : 0,39 s, `identical` TRUE, 0 réplication sans σ*.

   Elle donne aussi le masque aligné des σ* finis. On en tire sans tirage supplémentaire `n_sans_sigma` selon la règle de A.2 et la p conditionnelle de A.5 (ii). Je recommande un chemin hybride (Q-1b-2), qui s'écarte de la lettre « à partir de `sigma_boot` ».
3. **Profil volatil** (*vérifié*, 1 000 triangles tirés du modèle ajusté à la fixture de A.0) : 409 triangles sur 1 000 sont refusés par M4 (R̂ ≤ 0), sous E comme sous N. L'égalité des deux comptes est une coïncidence : corrélation des R̂ entre les deux lois −0,005 ; sur 2 000 triangles, 0,418 (E) et 0,4125 (N). Ce profil est extrême (σ̂ = 3,82, soit 382 %). Je le prends comme critère secondaire de portée, pas comme condition de l'extension.
4. **Débit mesuré à 4 processus : 2,72**, et non 3,917 comme dans #297 (*vérifié* ; la machine était peut-être chargée par `coder`, *hypothèse*). Toutes les durées ci-dessous en tiennent compte, et le pré-vol du script fait foi.

## 1. Statut épistémique (à écrire tel quel en tête de la sortie)

La couverture mesurée est un **constat de simulation**, sous trois conditions : le modèle de Mack ajusté à un triangle générateur (f̂, σ̂² extrapolé compris, première colonne fixée), une loi d'erreurs donnée, et T = 8. Elle porte sur la procédure du moteur à B = 999, conditionnellement à l'admission du triangle (M4) et à R* > 0 dans le bootstrap.

Ce n'est pas un résultat général. Aucun théorème ne couvre ces intervalles à triangle fixe (I = 7). Les ordres de précision asymptotiques de Davison et Hinkley (1997, § 5.2-5.3 ; relevé R27.2 du dépôt) ne fondent rien à T = 8. Aucune source relue par le dépôt ne chiffre cette couverture à n = 8 (spécification D1-Fn, § 6). Je n'ai pas fait de recherche bibliographique nouvelle : la mesure est la seule preuve visée.

Erreurs à distinguer :
- l'erreur Monte-Carlo en N, encadrée par l'intervalle de Clopper-Pearson ;
- l'effet de B, inclus dans la procédure mesurée et non isolé ;
- l'écart au niveau nominal, qui est l'objet mesuré (erreur à T = 8) ;
- l'erreur de substitution (plan et loi au lieu de la vérité), non quantifiée.

## 2. Protocole numéroté

**P1. Objet et frontières.**
- Script `tests/couverture_ic_sigma_mw_t8.R`, en R base + stats, avec `parallel`, `utils` et `tools` livrés avec R.
- Moteur chargé par `tests/outils_tests.R` (`charger_moteur()`, ADR 0016).
- Le nom ne commence pas par `test_` : le script n'est lancé ni par la CI ni par les batteries.
- Il ne modifie ni `R/`, ni `app.R`, ni `tests/reference/`.
- Les intervalles, la boucle allégée, `n_sans_sigma`, la p conditionnelle et σ_B sont calculés dans le script, jamais dans le moteur.
- Effet : aucun sur σ_USP, sur les p-values ou sur les verdicts.

**P2. Plan de triangles (point 1 du brief).** Cinq profils.

| Code | Générateur | Loi des ε | Rôle | Chemin (Q-1b-2 (b)) |
|---|---|---|---|---|
| P1 | `mw_ajuster(reserve2)`, plan de #206 | E : pool redressé de `reserve2` divisé par sd_pop, définition de #206 § 2 | **critère principal** | boucle allégée, plus échantillon d'identité |
| P2 | idem | N : `rnorm` | **critère principal** | idem |
| P3 | idem | A : (Gamma(2) − 2)/√2 | descriptif | idem |
| P4 | `mw_ajuster(fixture A.0)` | E : pool de la fixture divisé par sd_pop | **critère secondaire** (portée conditionnelle) et volet A.5 (ii) | `mw_bootstrap()` complet, plus boucle allégée pour le masque |
| P5 | idem | N | descriptif | boucle allégée |

- Valeurs *vérifiées* :
  - `reserve2` : R̂ = 9 140,84, MSEP = 39 798, σ̂ = 0,0218245 ; pool n = 27, sd_pop = 0,99879 ; jd = {6}.
  - Fixture : R̂ = 158,573, MSEP = 366 875, σ̂ = 3,8197 ; f̂ = (1,09601 ; 1,01256 ; 1,03592 ; 1,02696 ; 1,05167 ; 0,95287 ; 0,983319) ; pool n = 27, sd_pop = 0,99865, bornes réduites [−2,211 ; 1,601] ; jd = {6}.
- Générateur : `gen_triangle_h0()` et `admettre()` de `tests/calibration_mc_mw_t8.R` (l. 956 et 980), copiés ou mis en commun sans modifier ce script versionné. Un triangle refusé est compté avec son motif, sans nouveau tirage.
- La fixture est lue dans le fichier que versionne #492 (étape 3) s'il existe ; sinon on prend le `dput` de A.0 embarqué. Le T0 vérifie l'égalité des deux.

**P3. Vraie valeur de référence (point 3 du brief).**
- **σ_A, cible principale** : σ̂ du triangle générateur, soit 0,0218245 pour P1 à P3 et 3,8197 pour P4 et P5.
  - Justification (*vérifiée* par lecture de `mw_bootstrap()`, l. 15975-16060) : le bootstrap du moteur part d'un triangle observé D, garde sa première colonne, régénère toutes les autres cellules sous (f̂, σ̂², pool), et calcule σ* = √MSEP(D\*)/R̂(D\*). Dans ce monde, la vérité est g(D) = σ̂, et c'est elle que l'intervalle « basic » prend pour vérité (2σ̂ − q). Le monde simulé reproduit cette structure un niveau plus haut : générateur, simulation, vérité g(générateur). C'est la même correspondance que pour le double bootstrap (#246) et que pour #305, où σ0 était le σ̂ du jeu générateur (contrôle K-C3 (2)).
  - Limite écrite : le règlement définit σ par son estimation (annexe XVII, D(4)), et n'en définit aucun analogue en population. σ_A est donc une vérité **par convention** (*hypothèse de modélisation*).
- **σ_B(r), cible descriptive** : √MSEP / R calculés par `mw_msep()` sur une copie de l'ajustement du triangle r. Dans cette copie, f ← f0 et σ² ← σ0² ; Q, `C_chapeau`, `ultime` et `reserve` sont recalculés avec f0 ; `tri`, S, S′ et `dernier_observe` restent ceux du triangle r. C'est la formule à paramètres vrais, conditionnelle aux cumuls du triangle (*interprétation*, sans source). Un R_B ≤ 0 est compté à part.
  - Contrôle : la même reconstruction avec (f̂_r, σ̂²_r) redonne `identical()` la MSEP et R̂ de `mw_ajuster()` et `mw_msep()`.
- Échelle : la mesure se fait sur σ. L'application vers σ_USP est affine et croissante, de pente c = 0,59 > 0 (`reserve2.rds`, *vérifié* ; même c pour la fixture, segment 1 de l'annexe II, T = 8). La couverture est donc la même sur les deux échelles (raisonnement de D1-Fn § 2.1).

**P4. Intervalles mesurés (point 2 du brief).** Sur l'échelle de σ, quantiles empiriques de type 7 des σ\* finis (ceux de `res$ic_bootstrap`), au niveau 1 − 2α.

| Code | Bornes | Source |
|---|---|---|
| I1 | percentile, [q_α ; q_{1−α}] : l'intervalle affiché | Davison et Hinkley, éq. (5.18) |
| I2 | « basic », [2σ̂ − q_{1−α} ; 2σ̂ − q_α] | Davison et Hinkley, éq. (5.6) |
| I4 | « basic » logarithmique, [σ̂²/q_{1−α} ; σ̂²/q_α] | Davison et Hinkley, éq. (5.10) ; c'est `usp_ic_basic_log()` sans l'application affine |

- Les références sont vérifiées par le dépôt (relevé R27.2, D1-Fn § 2.3) ; je ne les ai pas relues.
- Niveaux : 90 % (principal) et 95 %.
- Un intervalle n'est formé que si plus de 20 σ\* sont finis (règle du moteur, l. 17484) ; sinon le triangle est compté « sans intervalle ».
- Si q_α = 0, la borne haute de I4 vaut +∞ : elle est comptée à part, sans troncature.
- Couverture : borne basse ≤ σ ≤ borne haute.
- Pas d'A1 en Merz-Wüthrich (aucun facteur de correction), pas d'I3.

**P5. Admission et conditionnement (point 4 du brief).**
- (i) Un triangle simulé à R̂ ≤ 0 est refusé par `mw_valider_ajustement()` (M4), compté, et sort de la population. La couverture est donc **conditionnelle à l'admission**.
- (ii) σ\* est conditionnel à R\* > 0 : c'est l'intervalle du moteur, formé sur `sigma_boot`.
- (iii) `n_sans_sigma` est calculé pour chaque triangle par la règle de A.2 : #{b : ligne b de `stats_boot` avec au moins une valeur finie et σ\*_b non fini}, sur le masque de la boucle allégée. Contrôles :
  - il est égal au nombre de lignes calculées moins `length(sigma_boot)` ;
  - il est égal à `boot$n_sans_sigma` si le champ existe (après #492) ;
  - un écart donne ECHEC.
- Sur P1 et P2, la population vaut en pratique sans condition (A.5 de 1a : 0 réplication sur 999 sur `reserve2`). Seuls P4 et P5 exercent le conditionnement.

**P6. Graines (point 5 du brief).** Toutes passent par `engine_sous_graine()`. p est l'indice du profil (1 à 5) et r ≤ 100 000.
- Triangle r du profil p : 387 000 000 + 1 000 000 (p − 1) + r.
- Bootstrap r du profil p : 387 500 000 + 1 000 000 (p − 1) + r.
- Oracle de P4, triangle k : 392 000 000 + k.
- Pré-vol : 393 000 000 + k.
- Maximum : 393 100 000, inférieur à 2³¹ − 1.

Les plages sont disjointes entre elles. Elles le sont aussi de celles de #206 et #297 (20 840 001-20 960 000 ; lognormale de #297 : 20 260 831 + b et 20 260 927), de #305 (305 000 000 à 305 889 169 + R) et des littéraux à 9 chiffres du dépôt (*vérifié* par `grep` : 305·10⁶ et 360 380 123 seuls). Le script refait au T0 le contrôle de l'annotation du 10/10/2026 de #206 : [L ; L + 20 000] disjoint des plages pour tout littéral L de `R/engine.R`, `tests/*.R` et `tests/unitaires/*.R`.

Les graines de #206 ne servent qu'au contrôle d'intégrité (10), jamais à la mesure.

**P7. Nombre de triangles et B (point 5 du brief).**
- B = 999, en double comme dans `calibration_mc_mw_t8.R`. C'est une donnée de la procédure, pas un levier.
- R est un nombre de triangles **tirés**, fixé avant l'exécution et écrit au JOURNAL. On ne tire pas « jusqu'à n admis ».

| Niveau | P1 | P2 | P3 | P4 (tirés, admis attendus ≈ 0,58 R) | P5 | Oracle P4 (tirés) | Durée prévue à 4 processus (débit 2,72) |
|---|---|---|---|---|---|---|---|
| **L0** | 2 000 | 2 000 | 1 000 | 1 700 (≈ 990) | 3 400 (≈ 2 000) | 17 000 (≈ 9 900) | ≈ 2,1 h |
| L1 | 2 000 | 2 000 | 1 000 | 1 200 (≈ 700) | 3 400 | 17 000 | ≈ 1,6 h |
| L2 (minimum) | 1 000 | 1 000 | — | 850 (≈ 500) | — | 17 000 | ≈ 1,1 h |

- Règle : on retient le premier niveau dont la durée planifiée tient dans **3 h d'horloge sur 4 processus**, avec les coûts du pré-vol à 1, 2, 3 et 4 processus. Sous L2, retour au mainteneur.
- Option (a) de Q-1b-2, chemin du moteur partout : environ 1 900 bootstraps tiennent en 3 h (P1 600, P2 600, P4 1 100 tirés, soit environ 640 admis ; environ 2,9 h). Demi-largeur d'environ 0,024 à τ = 0,10.

**P8. Volet A.5 (ii), sur les triangles admis de P4 (point 8 du brief).**
- Taux de rejet τ des 13 `p_mc` (clés et sens lus dans `MW_CATALOGUE_MC`) à α = 0,10 et 0,05, avec intervalle de Clopper-Pearson. Une p absente compte comme un non-rejet et est comptée à part.
- **Référence ρ** : taille lissée du test de Monte-Carlo idéal à B = 999 (règle de #206 § 4, `taille_lissee()`). Elle est calculée sur un oracle tiré de P4 et **restreint aux triangles admis** (R̂ > 0), soit environ 9 900 triangles. Coût mesuré : 0,026 s par triangle admis.
- **p conditionnelle**, en option recommandée, calculée dans le script seulement : `.mc_p_values()` sur les seules lignes de `stats_boot` à σ\* fini (masque de P5 (iii)), avec le contexte observé reconstruit par `.mw_contexte_mc()`.
  - Contrôle : `.mc_p_values()` sur `stats_boot` entier redonne `boot$p_mc` `identical()`.
  - Comparaison appariée avec la p du moteur : McNemar exact et Holm sur 13 clés pour chaque α.
- Témoin oracle : règle bêta-binomiale de l'annotation du 05/11/2026 de #206.
- Distribution de `n_sans_sigma`/B : quantiles, part nulle, part > 0,05, part > 0,20.

**P9. Coût (point 9 du brief)** : voir § 4.

**P10. Script (point 10 du brief).**
- Modes :
  - `--essai` : R = 4 par profil, B = 199, dossier temporaire, sorties marquées, `--ecrire` refusé ;
  - `--prevol [--unites k]` : coûts de la boucle allégée, de `mw_bootstrap()` et de l'oracle à 1, 2, 3 et 4 processus, taux d'admission de P4 sur les graines du pré-vol, choix du niveau ; rien d'écrit ;
  - mesure : `--R`, ou `--niveau Lk`, fixé par le pré-vol et écrit au JOURNAL avant tout calcul ; `--processus`, `--travail`, `--ecrire [--remplacer]`.
- Tranches de 100 triangles, reprise selon M42 (b), contexte comparé entre tranches (B, SHA, md5, empreinte, plateforme). Mécanique de `couverture_ic_sigma_t8.R`.
- Sorties nouvelles, jamais patchées :
  - `docs/tableaux/<AAAAMMJJ>-issue387-couverture-ic-sigma-mw.md` ;
  - `docs/tableaux/<AAAAMMJJ>-issue387-couverture-ic-sigma-mw-brut.tsv` : une ligne par triangle tiré, valeurs en `%.17g` ;
  - `docs/tableaux/<AAAAMMJJ>-issue387-journal-mesure.md`.
- L'oracle n'est pas versionné ; son md5 figure au T0.
- Critères de #242 : échappements `\u`, aucun chemin absolu, IC non arrondis dans les classes.
- `--ecrire` exige un commit propre, `motifs_non_versionnable()` et `garde_ecrasement()`.
- Dernière ligne de la console : `INTEGRITE OK` ou `INTEGRITE ECHEC`.

**P11. Contrôles d'intégrité.** Un seul échec donne `INTEGRITE ECHEC`.
1. md5 de `R/engine.R`, SHA et **empreinte #231** (`empreinte_sans_commentaires()`) identiques au début, à la fin, dans le JOURNAL et dans chaque tranche.
2. σ_A de P1 égal à `parametre_final$sigma_estime` de `reserve2.rds`, à `TOLERANCE` près. σ_A de P4 égal au `sigma_estime` de `run_engine()` sur la fixture.
3. Percentile du script porté sur l'échelle de σ_USP, `identical()` à `ic_bootstrap` de `reserve2.rds` et de `run_engine()` sur la fixture.
4. Bornes recalculées par une écriture indépendante sur le premier triangle admis de chaque tranche, à 1e-12 relatif.
5. `sigma_boot` de la boucle allégée `identical()` à celui de `mw_bootstrap()` : sur le premier triangle admis de chaque tranche de P1, P2, P3 et P5 ; sur **chaque** triangle de P4.
6. Contrôle (g) : `gen_triangle_h0()` `identical()` à `mw_simuler_triangle()` sur 100 graines, pour les deux générateurs.
7. Contrôle (i2) : `run_engine(methode = "reserve2", triangle = tri_r, segment = 1, annexe = "II", seed = graine_boot, date_reference = DATE_REFERENCE_TESTS)` redonne `$bootstrap` et `$ic_bootstrap` `identical()` au chemin du script, sur 5 triangles de P4 et 2 de P1.
8. `n_sans_sigma` selon P5 (iii) ; sur la fixture, 77 à B = 199 et 453 à B = 999 (valeurs de 1a, Linux).
9. Les `p_mc` des lignes E b = 1 et b = 2 du brut de #297 sont reproduites `identical()` sous les graines de #206 (forme de 1c).
10. Disjonction des graines (P6).
11. Contrôle (t387) : le critère et les profils du § 3 sont présents à l'identique dans le rapport versé (`docs/revues/20261119-s5-bootstrap-mw/`).
12. Contrôle (m) : `grep -rn couverture_ic_sigma_mw R/ app.R .github/` ne renvoie rien.
13. Reconstruction de σ_B (P3).
14. `.mc_p_values()` redonne `boot$p_mc` (P8).

## 3. Critère et profils, fixés avant toute exécution (point 6 du brief ; à reporter sans modification dans le script et au T0)

> **Critère.** Taux de non-couverture τ de chaque (profil, intervalle, niveau), cible σ_A, comparé au nominal ρ = 0,10 (90 %) ou 0,05 (95 %). Classes de #166, #206, Fk et #305, bande **fermée** [ρ/2 ; 3ρ/2] : *compatible* (ρ ∈ IC(τ)) ; *écart mineur* (τ̂ dans la bande, sans être compatible) ; *non tranché* (τ̂ hors de la bande, IC qui la recoupe) ; *distorsion matérielle libérale* (IC disjoint de la bande, au-dessus) ; *distorsion matérielle conservatrice* (IC disjoint, au-dessous). IC de Clopper-Pearson à 95 % ; classes sur les valeurs non arrondies ; une estimation sur un bord est dans la bande ; **aucune extension de R après lecture** ; un « non tranché » reste non tranché.
> - **K-M1** (principal) : classe à 90 % de I1, I2 et I4 sur P1 et P2.
> - **K-M2** (secondaire, portée conditionnelle) : classe à 90 % de I1, I2 et I4 sur les triangles admis de P4.
> - **K-M3** (descriptif) : 95 % ; queues séparées contre ρ/2 ; cible σ_B ; P3 et P5 ; couverture de P4 et P5 par strate de π̂ = `n_sans_sigma`/B (0 ; ]0 ; 0,05] ; ]0,05 ; 0,20] ; > 0,20) ; largeurs (médiane et quantiles divisés par σ_A ; pas de moyenne sur P4 et P5) ; bornes basses ≤ 0 de I2 ; bornes hautes infinies de I4 ; biais (médiane de σ̂/σ_A ; moyenne de σ̂/moyenne(σ\*) sur P1 à P3 seulement ; médiane du rang de σ̂ dans σ\*).
> - **K-M4** (intégrité) : contrôles 1 à 14 de P11.
> - **K-M5** (frontière, descriptif) : l'IC touche-t-il un bord de la bande.
>
> **Profils de lecture pour D2** (`actuary` propose, le mainteneur tranche ; ordre : Ω0, Ω4, Ω1 à Ω3, puis modificateur V) :
>
> | Profil | Condition | Lecture proposée |
> |---|---|---|
> | Ω0 | K-M4 en défaut ; ou, sur P1 ou P2, refus ou triangles sans intervalle au-delà de 1 % ; ou, sur P4, refus d'un autre motif que M4 au-delà de 1 % | lecture suspendue ; mesure à reprendre |
> | Ω4 | I1 en distorsion de côtés opposés entre P1 et P2 | décision du mainteneur ; aucune extension |
> | Ω1 | I1 compatible ou en écart mineur sur P1 et P2 | percentile conservé ; couverture écrite ; « basic » non étendu par défaut |
> | Ω2 | I1 ni compatible ni en écart mineur sur au moins un des deux profils, et I4 compatible ou en écart mineur sur P1 et P2 | **décision du mainteneur** : extension de I4 à Merz-Wüthrich en regard du percentile, jamais à sa place (Q-42-10) ; note requalifiée comme en lognormale |
> | Ω2′ | même cas pour I1, I4 non retenu, mais I2 compatible ou en écart mineur sur P1 et P2 | décision du mainteneur ; I2 n'étant pas restitué en lognormale (Q-D2-Fn-2), aucune restitution sans décision expresse |
> | Ω3 | I1 dans ce même cas, et ni I2 ni I4 compatible ou en écart mineur sur P1 et P2 | aucun « basic » ; note requalifiée (percentile sous le nominal) ; issue proposée pour un autre intervalle |
>
> **Modificateur V (K-M2)**, sous Ω1 ou Ω2, pour l'intervalle ou les intervalles retenus (I1, plus I4 sous Ω2). V-a : compatible ou en écart mineur sur P4, aucune limite de plus que la phrase conditionnelle de #492. V-b : non tranché ou en distorsion sur P4 : l'extension n'est pas remise en cause, mais la limite est écrite (note quand `n_sans_sigma` > 0, et fiche) avec la couverture par strate de π̂ ; le mainteneur décide s'il rouvre l'option (b) de 1a (seuil de retrait) au vu des strates. Aucun seuil n'est posé par défaut.
>
> **Volet A.5 (ii)** (P4, triangles admis). **K-V1** : classe de #206 de τ contre ρ (oracle conditionnel) pour chaque clé et chaque α. **K-V2** : McNemar exact entre la p du moteur et la p conditionnelle, Holm sur 13 par α. **K-V3** : témoin, règle bêta-binomiale du 05/11/2026. **K-V4** : p absentes au plus 1 % ; distribution de π̂. Profils : **Λ0**, K-V3 non expliqué ou K-V4 en défaut : lecture suspendue ; **Λ1**, 13 clés compatibles ou en écart mineur aux deux seuils et aucun McNemar significatif : limite (i) de 1a écrite comme « niveau mesuré sur un profil volatil, sans distorsion » ; **Λ2**, aucune distorsion matérielle, des non tranchés, aucun McNemar significatif : constat avec ses IC ; **Λ3**, une distorsion matérielle ou un McNemar significatif : limite écrite et issue proposée (p conditionnelle, hors S5), sans changer aucune p ni aucun verdict dans S5.

## 4. Coût, mesuré dans cette session (point 9 du brief)

Mesures *vérifiées* : R 4.3.3, Linux, 4 cœurs, moteur HEAD, 19/11/2026. La machine était possiblement chargée par `coder`.
- `mw_bootstrap()` à B = 999, un processus :
  - `reserve2` : 16,11 s ;
  - fixture : 15,05 s (546 σ\*, 453 sans σ\*) ;
  - deux triangles simulés de P1 : 16,15 et 15,27 s ;
  - deux triangles simulés de P4 : 15,38 s (0 sans σ\*) et 15,66 s (65 sans σ\*).
- `mw_tests()` sur la fixture : 2,45 s. Il n'est pas nécessaire : les `p_mc` sont dans `boot`.
- Débit sur 4 bootstraps de `reserve2` : 59,1 s à 1 processus, 29,8 s à 2, 21,7 s à 4. Soit 5,41 s par bootstrap et un débit de 2,72.
- Boucle allégée : 0,37 s (fixture) et 0,39 s (`reserve2`).
- Statistiques de l'oracle : 0,026 s par triangle admis.
- Admission, sur 1 000 triangles par profil : P1 et P2, 1 000 sur 1 000 ; P4 et P5, 591 sur 1 000 (motif unique : M4).
- Total L0, *estimé* d'après ces mesures : environ 20 400 s CPU, soit environ 2,1 h d'horloge à 4 processus au débit de 2,72 (environ 1,5 h au débit de 3,9). L'essentiel est P4 : environ 990 bootstraps complets, environ 15 750 s. Objectif de moins de 3 h tenu, sans réduction.

**Erreur Monte-Carlo du taux, fonction de N (point 7 du brief)** : demi-largeur de l'IC de Clopper-Pearson d'environ 0,013 à τ = 0,10 et 0,020 à τ = 0,30 pour n = 2 000 ; d'environ 0,019 pour n ≈ 990 ; d'environ 0,027 pour n = 500.

**Effet de B** : les bornes sont des quantiles de B_eff σ\*, et B_eff peut tomber vers 450 sur P4. La couverture mesurée est celle de la procédure à B = 999, effet de B compris, sans le séparer. Pour le volet A.5 (ii), ρ intègre B = 999, comme dans #206. L'erreur de ρ due à l'oracle est d'environ 0,003 (*hypothèse*, ordre de grandeur de #206). Sur P4 et P5, la moyenne de σ̂ n'est pas informative : infinie sous N (densité de R̂ positive en 0⁺), instable sous E, dont le support est fini (*hypothèse* argumentée).

## 5. Décisions du mainteneur

- **Q-1b-1. Cible.** (A, recommandée) σ_A principale, σ_B descriptive. (B) σ_B principale. (C) Les deux dans le critère : il faudrait alors réécrire Ω.
- **Q-1b-2. Chemin.** (b, recommandée) Hybride : boucle allégée sur P1, P2, P3 et P5, avec le contrôle 5 ; `mw_bootstrap()` complet sur P4. Elle s'écarte de la lettre du brief (« à partir de `sigma_boot` ») et du précédent Q-D1-Fn-4 (a). L'écart avec le moteur n'existe que si `.mw_stats()` échoue sur une réplication : 0 cas sur les 2 × 2 000 triangles de #297 (B effectif de 999 partout, T5, moteur du 26/10), et le contrôle 5 met l'écart en échec. (a) Chemin du moteur partout, avec N d'environ 600 par profil principal.
- **Q-1b-3. Profils et R** : P1 et P2 principaux, P4 secondaire, P3 et P5 descriptifs ; niveaux L0 à L2, budget de 3 h.
- **Q-1b-4. Critère** : K-M1 à K-M5, Ω0 à Ω4, Ω2′ et V approuvés tels quels avant toute exécution.
- **Q-1b-5. Volet A.5 (ii)** : (A, recommandée) oracle conditionnel, McNemar avec la p conditionnelle, témoin, profils Λ. (B) Taux contre le nominal seulement, illisible pour les statistiques à atomes.
- **Q-1b-6. Fixture comme générateur de P4.** C'est un profil extrême (σ̂ de 382 %). Un profil intermédiaire n'est pas proposé ; les strates de π̂ en tiennent lieu.
- **Q-1b-7. D2** : sous Ω2, extension de I4 en regard ; textes de la note (dont celle de #492, « Couverture à T = 8 non mesurée ») tranchés à D2 après lecture.
- **Q-1b-8.** Au-dessous de L2 au pré-vol : retour au mainteneur.

## Retour

- **Statut** : `revue requise`. Le protocole est complet, mais il reste les décisions Q-1b-1 à Q-1b-8, dont un écart à la lettre du brief (Q-1b-2).
- **Résultat** : protocole P1 à P11, critère et profils du § 3 écrits avant tout tirage, coût mesuré (environ 2,1 h à L0). Verdict : prêt pour l'étape 4 après décision.
- **Preuves** :
  - *Vérifiées* :
    - issue #387 et ses deux commentaires ;
    - rapports de 1a et 1c ;
    - spécification de #206 (dont les annotations jusqu'au 05/11) et spécification D1-Fn ;
    - sorties de #305 et T5 de #297 ;
    - Q-D2-Fn dans `fn-d2-lecture-couverture.md` ;
    - `mw_bootstrap()`, `mw_msep()`, `mw_ajuster()`, `mw_parametre()`, `mw_valider_ajustement()`, `usp_ic_basic_log()`, l'IC de `.run_engine_mw()` (lus dans HEAD), et `textes_ic_bootstrap()` (lu dans HEAD de `display_helpers.R`) ;
    - toutes les mesures du § 4 et du § 0, par commande ;
    - littéraux de graines, par `grep` ;
    - c = 0,59 dans `reserve2.rds`.
  - *Hypothèses* : σ_A comme vérité par convention ; sens de σ_B ; débit réduit par une charge concurrente ; moments infinis sur P4 ; absence d'échec de `.mw_stats()` sur les plans P1 à P3 avec le moteur actuel (couverte par le contrôle 5).
  - *Non vérifiés* : aucune recherche bibliographique nouvelle ; les sources de Davison et Hinkley sont citées d'après le relevé R27.2 du dépôt ; portabilité hors Linux.
- **Informations manquantes** : aucune source ne chiffre cette couverture à T = 8.
- **Décisions non résolues** : Q-1b-1 à Q-1b-8, par le mainteneur.
- **Critères déclenchés** :
  - écart à la lettre du brief et au précédent Q-D1-Fn-4 (a) (Q-1b-2) ;
  - question de modélisation qu'aucune source ne tranche (cible σ, Q-1b-1) ;
  - validité à T = 8 qu'aucun résultat exact ne tranche, inhérente à la mesure ;
  - changement de résultat seulement si D2 étend I4 (étape 4b, affichage, régénération) ; aucun σ_USP ni verdict.
- **Constats hors périmètre** :
  1. Débit mesuré à 4 processus de 2,72 contre 3,917 dans #297 : l'estimation de durée de 1c (environ 1,05 h pour #246) est peut-être optimiste. Critère : aucun ; le pré-vol de #246 fait foi.
  2. À HEAD (#445 B3 et B4 non commités), `mw_bootstrap()` coûte 15 à 16 s, comme dans 1c : aucun gain encore. Le motif « −20 % » est déjà signalé par 1a. Critère : aucun.
- **Prochaine action recommandée** : la session verse ce rapport, puis le mainteneur tranche Q-1b-1 à Q-1b-8. Ensuite, étape 4 : `coder-approfondi` (`high`) écrit le script, lance `--essai` puis `--prevol`, et exécute selon M42 seulement après #492 (champ `n_sans_sigma` comparé par le contrôle 8) et après #445.

---

## Décisions du mainteneur du 19/11/2026 (questionnaire de la session principale, avant toute exécution)

- **Q-1b-1 (A)** : σ_A (σ̂ du triangle générateur) est la cible principale, σ_B est descriptive.
- **Q-1b-2 (b)** : chemin hybride (boucle allégée sur P1, P2, P3 et P5, avec le contrôle 5 ; `mw_bootstrap()` complet sur P4).
- **Q-1b-3, Q-1b-4, Q-1b-6, Q-1b-8** : profils, niveaux L0 à L2 (budget de 3 h), critère K-M1 à K-M5, profils de lecture Ω0 à Ω4, Ω2′ et V, retour au mainteneur sous L2 : **approuvés tels quels**.
- **Q-1b-5 (A)** et **Q-1b-7** : oracle conditionnel, McNemar avec la p conditionnelle (dans le script seulement), témoin, profils Λ ; sous Ω2, extension de I4 en regard du percentile, textes de la note tranchés à D2 après lecture.

---

## Questions d'application Q5, Q8 et Q9 (avis d'actuary-approfondi du 19/11/2026, avant toute exécution)

Posées par `coder-approfondi` et l'audit léger du script ; elles ne changent ni les classes du § 3 ni les profils approuvés, et ajoutent deux états pour un cas non prévu (signalés au mainteneur dans la PR #609).

- **Q5 (Λ)** : état distinct « Λ non évaluable », juste après Λ0 (clé dont ρ est absente : défaut du script ou oracle trop petit, non un résultat) ; lecture du volet suspendue, retour au mainteneur. Ordre : Λ0, Λ non évaluable, Λ3, Λ1, Λ2.
- **Q9 (V)** : « V non évaluable (n = 0 sur P4) » si une classe sur P4 est absente ; K-M2 non lu, extension non remise en cause, décision du mainteneur à D2. Cas d'essai seulement.
- **Q8** : classe de τ de la p conditionnelle gardée, intitulée « descriptif : ρ à B = 999, p conditionnelle à B_eff variable, écart de référence non corrigé », avec les quantiles de B_eff sur P4 ; hors de Λ. Pour une statistique continue, l'écart de taille dû à B reste inférieur à 1/(B_eff + 1) ≈ 0,002 (calcul exact sur la règle de rejet de `taille_lissee()`), moins que la demi-largeur de l'IC de τ ; non borné pour les statistiques à atomes.
