## Mesure #387 (S5, étape 4) : couverture à T = 8 de l'intervalle bootstrap de σ, méthode Merz-Wüthrich, et volet A.5 (ii) de #492

### Statut épistémique (protocole, par. 1, reproduit tel quel)

## 1. Statut épistémique (à écrire tel quel en tête de la sortie)

La couverture mesurée est un **constat de simulation**, sous trois conditions : le modèle de Mack ajusté à un triangle générateur (f̂, σ̂² extrapolé compris, première colonne fixée), une loi d'erreurs donnée, et T = 8. Elle porte sur la procédure du moteur à B = 999, conditionnellement à l'admission du triangle (M4) et à R* > 0 dans le bootstrap.

Ce n'est pas un résultat général. Aucun théorème ne couvre ces intervalles à triangle fixe (I = 7). Les ordres de précision asymptotiques de Davison et Hinkley (1997, § 5.2-5.3 ; relevé R27.2 du dépôt) ne fondent rien à T = 8. Aucune source relue par le dépôt ne chiffre cette couverture à n = 8 (spécification D1-Fn, § 6). Je n'ai pas fait de recherche bibliographique nouvelle : la mesure est la seule preuve visée.

Erreurs à distinguer :
- l'erreur Monte-Carlo en N, encadrée par l'intervalle de Clopper-Pearson ;
- l'effet de B, inclus dans la procédure mesurée et non isolé ;
- l'écart au niveau nominal, qui est l'objet mesuré (erreur à T = 8) ;
- l'erreur de substitution (plan et loi au lieu de la vérité), non quantifiée.

### T0 — provenance

| Grandeur | Valeur |
| --- | --- |
| Protocole | docs/revues/20261119-s5-bootstrap-mw/actuary-1b-protocole-387.md, P1 à P11 et par. 3 ; décisions du mainteneur du 19/11/2026 (Q-1b-1 (A), Q-1b-2 (b), Q-1b-3, 4, 6, 8, Q-1b-5 (A), Q-1b-7) ; md5 d6ddf1161f7b4932024b599394e7e558 |
| Spécification de la fixture et de n_sans_sigma | docs/revues/20261119-s5-bootstrap-mw/actuary-1a-specification-492-avis-b1.md, A.0 et A.2 ; md5 c0a2ae7ae71733a3a236b0044c4995c0 |
| Mode | mesure |
| R par profil (tirés) ; B ; niveau | P1=2000,P2=2000,P3=1000,P4=1700,P5=3400,OR=17000 ; 999 ; L0 |
| Profils | P1 : reserve2, loi E ; critère principal (K-M1) ; P2 : reserve2, loi N ; critère principal (K-M1) ; P3 : reserve2, loi A ; descriptif (K-M3) ; P4 : fixture, loi E ; critère secondaire (K-M2) ; volet A.5 (ii) ; P5 : fixture, loi N ; descriptif (K-M3) |
| Générateur reserve2 | tests/donnees/triangle_mw.csv (md5 3e9a584da42443f3816fb63deeffa95b) ; R̂ = 9140.84 ; MSEP = 39798 ; σ_A = 0.02182451 ; f̂ = (3.20372 ; 1.65175 ; 1.32525 ; 1.15042 ; 1.09469 ; 1.06455 ; 1.02841) ; pool n = 27, sd_pop = 0.99879 ; colonnes dégénérées : 6 |
| Générateur fixture | tests/donnees/triangle_mw_volatil.csv (md5 89b0d65628c79b2225806372c424cb31) ; R̂ = 158.573 ; MSEP = 366875 ; σ_A = 3.819696 ; f̂ = (1.09601 ; 1.01256 ; 1.03592 ; 1.02696 ; 1.05167 ; 0.95287 ; 0.983319) ; pool n = 27, sd_pop = 0.99865 ; colonnes dégénérées : 6 |
| Lois | E : tirage uniforme dans le pool redressé du générateur (.mw_pool_residus(aj0, jd0)) divisé par son écart-type de population ; N : stats::rnorm ; A : (G − 2)/√2, G ~ Gamma(2) par stats::qgamma(stats::runif(n), 2) |
| Chemin | gen_triangle_h0(aj0, loi) sous engine_sous_graine(G_tri) ; admettre() (mw_valider_triangle(), mw_ajuster(), mw_msep(), mw_valider_ajustement() ; segment 1, annexe II) ; boucle allégée à B, graine G_boot ; P4, et premier triangle admis de chaque tranche ailleurs : mw_bootstrap(aj, B, G_boot, .mw_ensembles_figes(aj)) complet (Q-1b-2 (b)) |
| Graines | triangle r du profil p : 387 000 000 + 1 000 000 (p − 1) + r ; bootstrap : 387 500 000 + 1 000 000 (p − 1) + r ; oracle de P4 : 392 000 000 + k ; pré-vol : 393 000 000 + 10 000 (p − 1) + u et 393 050 000 + 10 000 (p − 1) + u ; contrôle 9 : graines de #206 (loi E, b = 1, 2) ; disjonction : contrôle 10 |
| Générateur aléatoire | Mersenne-Twister, Inversion, Rejection |
| Cible | σ_A (cible principale, Q-1b-1 (A)) = σ̂ du triangle générateur ; σ_B (descriptive) = √MSEP/R de mw_msep() sur la copie de l'ajustement du triangle simulé à (f, σ²) du générateur (P3) |
| Intervalles | quantiles de type 7 des σ* finis ; I1 [q_α ; q_(1−α)] ; I2 [2σ̂ − q_(1−α) ; 2σ̂ − q_α] ; I4 [σ̂²/q_(1−α) ; σ̂²/q_α] ; 90 % (α = 0,05) et 95 % (α = 0,025) ; intervalle formé si plus de 20 σ* finis |
| Oracle de P4 | 17000 triangles tirés, 9988 admis ; valeurs non versionnées (oracle-P4.tsv du dossier de travail), md5 3004f0d1cb14b0b343791ccb9cec5c7f |
| SHA, git rev-parse HEAD (début ; fin) | e6547adbb614ac58ee8b92411a49f4e76e0d2ad6 ; e6547adbb614ac58ee8b92411a49f4e76e0d2ad6 |
| Commit (commit_depot(), au début) | e6547adbb614ac58ee8b92411a49f4e76e0d2ad6 |
| md5 R/engine.R (début ; fin) | e5ac6cbe50873533e2908b361e254d9a ; e5ac6cbe50873533e2908b361e254d9a |
| Empreinte sans commentaires de R/engine.R (#231 ; début ; fin) | 17ce964a3e7d6b464851480162f75426 ; 17ce964a3e7d6b464851480162f75426 |
| Empreintes md5 du code exécuté | R/engine.R e5ac6cbe50873533e2908b361e254d9a ; tests/outils_tests.R chargé (dépôt) cdf8f7da242e2c6281fadcb4108aab63 ; script exécuté (dépôt) 76c92d9d6533c225eaf6e02d14e54af4 |
| Champ bootstrap$n_sans_sigma (#492) | présent dans le moteur : comparé (contrôle 8) |
| Plateforme de calcul | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : libblas.so.3.12.0 ; LAPACK : liblapack.so.3.12.0 (version 3.12.0) |
| Locale (LC_CTYPE) | C.UTF-8 → C.UTF-8 |
| Tranches | 271 (taille 100), profils et oracle |
| JOURNAL ; valeurs brutes | 20261119-issue387-journal-mesure.md ; 20261119-issue387-couverture-ic-sigma-mw-brut.tsv (une ligne par triangle tiré, %.17g) |
| Versionnable (--ecrire) | oui |
| Contrôles d'intégrité | OK |

### Aide à la lecture

τ = part des triangles admis à intervalle où la cible est hors de l'intervalle ; IC de Clopper-Pearson à 95 % (qbeta), erreur Monte-Carlo du taux (fonction du nombre de triangles). L'effet de B est inclus dans la procédure mesurée et non isolé. Couverture conditionnelle à l'admission (M4 : R̂ > 0) et, pour les σ*, à R* > 0. Classes et profils calculés mécaniquement, sur les valeurs non arrondies, **sans conclure** : la lecture revient à actuary, la décision (D2) au mainteneur.

**Critère et profils du protocole (par. 3), reportés sans modification :**

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

### Contrôles d'intégrité (K-M4 : P11, contrôles 1 à 14, plus le contrôle de la fixture)

| Contrôle | Résultat | Détail |
| --- | --- | --- |
| 1 | OK | md5 R/engine.R début e5ac6cbe50873533e2908b361e254d9a, fin e5ac6cbe50873533e2908b361e254d9a, JOURNAL e5ac6cbe50873533e2908b361e254d9a ; SHA début e6547adbb614ac58ee8b92411a49f4e76e0d2ad6, fin e6547adbb614ac58ee8b92411a49f4e76e0d2ad6, JOURNAL e6547adbb614ac58ee8b92411a49f4e76e0d2ad6 ; empreinte #231 début 17ce964a3e7d6b464851480162f75426, fin 17ce964a3e7d6b464851480162f75426, JOURNAL 17ce964a3e7d6b464851480162f75426 ; contexte (B, SHA, md5 du moteur et du script, empreinte, plateforme) identique dans les 271 tranche(s) : oui |
| 2 | OK | σ_A de P1 à P3 = 0.02182451066 ; reserve2.rds : parametre_final$sigma_estime = 0.02182451066 (écart relatif 0.000e+00) ; σ_A de P4 et P5 = 3.819696329 ; run_engine() sur la fixture : 3.819696329 (écart relatif 0.000e+00) ; TOLERANCE 1e-06 |
| 3 | OK | c = 0.59, σ standard = 0.09 (usp_credibilite(8, "long"), usp_parametre_standard()) identiques à reserve2.rds : oui ; c σ* + (1 − c) σ standard, quantiles de type 7 (0.025, 0.05, 0.5, 0.95, 0.975) : reserve2.rds identical ; fixture (run_engine()) identical |
| 4 | OK | bornes de I1, I2, I4 aux deux niveaux recalculées par une écriture indépendante (statistiques d'ordre, type 7 en clair, I4 = exp(2 log σ̂ − log q)), seuil 1e-12 relatif, premier triangle à intervalle de chaque tranche : P1-r000001-000100.tsv (r = 1) : 2.90e-16 ; P1-r000101-000200.tsv (r = 101) : 6.02e-16 ; P1-r000201-000300.tsv (r = 201) : 6.29e-16 ; P1-r000301-000400.tsv (r = 301) : 4.90e-16 ; P1-r000401-000500.tsv (r = 401) : 5.22e-16 ; P1-r000501-000600.tsv (r = 501) : 7.82e-16 ; P1-r000601-000700.tsv (r = 601) : 2.83e-16 ; P1-r000701-000800.tsv (r = 701) : 1.42e-16 ; P1-r000801-000900.tsv (r = 801) : 4.32e-16 ; P1-r000901-001000.tsv (r = 901) : 5.08e-16 ; P1-r001001-001100.tsv (r = 1001) : 4.47e-16 ; P1-r001101-001200.tsv (r = 1101) : 1.12e-15 ; P1-r001201-001300.tsv (r = 1201) : 7.36e-16 ; P1-r001301-001400.tsv (r = 1301) : 6.07e-16 ; P1-r001401-001500.tsv (r = 1401) : 5.62e-16 ; P1-r001501-001600.tsv (r = 1501) : 3.37e-16 ; P1-r001601-001700.tsv (r = 1601) : 6.43e-16 ; P1-r001701-001800.tsv (r = 1701) : 6.27e-16 ; P1-r001801-001900.tsv (r = 1801) : 6.37e-16 ; P1-r001901-002000.tsv (r = 1901) : 3.68e-16 ; P2-r000001-000100.tsv (r = 1) : 4.90e-16 ; P2-r000101-000200.tsv (r = 101) : 1.54e-15 ; P2-r000201-000300.tsv (r = 201) : 6.27e-16 ; P2-r000301-000400.tsv (r = 301) : 4.09e-16 ; P2-r000401-000500.tsv (r = 401) : 8.81e-16 ; P2-r000501-000600.tsv (r = 501) : 5.39e-16 ; P2-r000601-000700.tsv (r = 601) : 5.31e-16 ; P2-r000701-000800.tsv (r = 701) : 5.04e-16 ; P2-r000801-000900.tsv (r = 801) : 6.81e-16 ; P2-r000901-001000.tsv (r = 901) : 7.80e-16 ; P2-r001001-001100.tsv (r = 1001) : 5.61e-16 ; P2-r001101-001200.tsv (r = 1101) : 6.44e-16 ; P2-r001201-001300.tsv (r = 1201) : 2.44e-16 ; P2-r001301-001400.tsv (r = 1301) : 2.11e-16 ; P2-r001401-001500.tsv (r = 1401) : 6.20e-16 ; P2-r001501-001600.tsv (r = 1501) : 4.24e-16 ; P2-r001601-001700.tsv (r = 1601) : 5.50e-16 ; P2-r001701-001800.tsv (r = 1701) : 6.45e-16 ; P2-r001801-001900.tsv (r = 1801) : 3.61e-16 ; P2-r001901-002000.tsv (r = 1901) : 4.71e-16 ; P3-r000001-000100.tsv (r = 1) : 5.48e-16 ; P3-r000101-000200.tsv (r = 101) : 9.12e-16 ; P3-r000201-000300.tsv (r = 201) : 8.55e-16 ; P3-r000301-000400.tsv (r = 301) : 6.58e-16 ; P3-r000401-000500.tsv (r = 401) : 6.01e-16 ; P3-r000501-000600.tsv (r = 501) : 5.26e-16 ; P3-r000601-000700.tsv (r = 601) : 1.21e-15 ; P3-r000701-000800.tsv (r = 701) : 6.04e-16 ; P3-r000801-000900.tsv (r = 801) : 7.93e-16 ; P3-r000901-001000.tsv (r = 901) : 1.28e-15 ; P4-r000001-000100.tsv (r = 1) : 3.29e-16 ; P4-r000101-000200.tsv (r = 101) : 1.98e-16 ; P4-r000201-000300.tsv (r = 201) : 0.00e+00 ; P4-r000301-000400.tsv (r = 301) : 2.95e-16 ; P4-r000401-000500.tsv (r = 401) : 2.56e-16 ; P4-r000501-000600.tsv (r = 504) : 1.72e-16 ; P4-r000601-000700.tsv (r = 602) : 2.94e-16 ; P4-r000701-000800.tsv (r = 702) : 1.03e-15 ; P4-r000801-000900.tsv (r = 801) : 2.53e-16 ; P4-r000901-001000.tsv (r = 901) : 2.56e-16 ; P4-r001001-001100.tsv (r = 1002) : 1.99e-16 ; P4-r001101-001200.tsv (r = 1101) : 2.27e-16 ; P4-r001201-001300.tsv (r = 1201) : 3.76e-16 ; P4-r001301-001400.tsv (r = 1301) : 4.63e-16 ; P4-r001401-001500.tsv (r = 1401) : 4.29e-16 ; P4-r001501-001600.tsv (r = 1501) : 1.93e-16 ; P4-r001601-001700.tsv (r = 1602) : 2.12e-16 ; P5-r000001-000100.tsv (r = 1) : 3.96e-16 ; P5-r000101-000200.tsv (r = 101) : 4.05e-16 ; P5-r000201-000300.tsv (r = 201) : 4.96e-16 ; P5-r000301-000400.tsv (r = 303) : 2.06e-16 ; P5-r000401-000500.tsv (r = 401) : 1.65e-16 ; P5-r000501-000600.tsv (r = 501) : 1.90e-16 ; P5-r000601-000700.tsv (r = 602) : 2.19e-16 ; P5-r000701-000800.tsv (r = 701) : 4.20e-16 ; P5-r000801-000900.tsv (r = 801) : 1.64e-16 ; P5-r000901-001000.tsv (r = 901) : 2.49e-16 ; P5-r001001-001100.tsv (r = 1004) : 2.11e-16 ; P5-r001101-001200.tsv (r = 1101) : 7.77e-15 ; P5-r001201-001300.tsv (r = 1201) : 1.66e-16 ; P5-r001301-001400.tsv (r = 1304) : 3.03e-15 ; P5-r001401-001500.tsv (r = 1401) : 4.66e-15 ; P5-r001501-001600.tsv (r = 1501) : 2.06e-16 ; P5-r001601-001700.tsv (r = 1601) : 3.29e-16 ; P5-r001701-001800.tsv (r = 1702) : 2.38e-16 ; P5-r001801-001900.tsv (r = 1801) : 2.01e-16 ; P5-r001901-002000.tsv (r = 1902) : 2.85e-16 ; P5-r002001-002100.tsv (r = 2002) : 1.53e-16 ; P5-r002101-002200.tsv (r = 2103) : 3.67e-16 ; P5-r002201-002300.tsv (r = 2202) : 3.62e-16 ; P5-r002301-002400.tsv (r = 2301) : 3.49e-16 ; P5-r002401-002500.tsv (r = 2401) : 2.18e-16 ; P5-r002501-002600.tsv (r = 2501) : 3.16e-16 ; P5-r002601-002700.tsv (r = 2601) : 1.47e-16 ; P5-r002701-002800.tsv (r = 2701) : 3.77e-16 ; P5-r002801-002900.tsv (r = 2801) : 2.47e-16 ; P5-r002901-003000.tsv (r = 2901) : 5.36e-16 ; P5-r003001-003100.tsv (r = 3001) : 8.23e-15 ; P5-r003101-003200.tsv (r = 3101) : 2.18e-16 ; P5-r003201-003300.tsv (r = 3201) : 5.18e-16 ; P5-r003301-003400.tsv (r = 3303) : 2.28e-16 ; tous les triangles à intervalle : 7966 / 7966 sous le seuil (écart maximal 4.20e-13) ; borne basse ≤ borne haute (I1, I2, I4, deux niveaux) sur tous les triangles à intervalle : oui |
| 5 | OK | sigma_boot de la boucle allégée identical() à celui de mw_bootstrap() : P1 : 20 / 20 tranches (premier triangle admis) ; P2 : 20 / 20 tranches (premier triangle admis) ; P3 : 10 / 10 tranches (premier triangle admis) ; P4 : 1016 / 1016 triangles admis (chacun) ; P5 : 34 / 34 tranches (premier triangle admis) |
| 6 (g) | OK | gen_triangle_h0() (ε tirés par sample(pool)) = mw_simuler_triangle() sous la même graine (identical()) : reserve2 : 100 / 100 identiques ; pool dilaté 30 fois : 100 / 100 identiques, dont 45 triangle(s) à cumul simulé non fini ou ≤ 0 ; fixture : 100 / 100 identiques ; pool dilaté 30 fois : 100 / 100 identiques, dont 99 triangle(s) à cumul simulé non fini ou ≤ 0 ; mw_simuler_triangle, .mw_simuler_triangle_etat, .mw_tirer_triangle_valide, .mw_triangle_incomplet, .mw_pool_residus, mw_bootstrap, mw_ajuster, mw_msep de l'environnement identiques (formals, body) à celles de R/engine.R relu : oui |
| 7 (i2) | OK | run_engine(methode = "reserve2", triangle = tri_r, segment = 1, annexe = "II", B, seed = graine du bootstrap, date_reference = DATE_REFERENCE_TESTS) sur 5 triangle(s) de P4 (r = 1, 436, 851, 1270, 1700) et 2 de P1 (r = 1, 2000) : $bootstrap identical() à mw_bootstrap() du script oui ; $ic_bootstrap identical() au percentile du script (σ* de la boucle allégée) oui ; ligne recalculée identique à celle de la tranche, hors durée : oui |
| 8 | OK | fixture (graine 20260831) : B = 199 : masque 77, boucle allégée 77, lignes calculées − length(sigma_boot) = 77, attendu 77 (1a) ; champ bootstrap$n_sans_sigma : 77 (égal) ; B = 999 : masque 453, boucle allégée 453, lignes calculées − length(sigma_boot) = 453, attendu 453 (1a) ; champ bootstrap$n_sans_sigma : 453 (égal) ; plan : 1100 / 1100 triangles à bootstrap complet où n_sans_sigma (masque de la boucle allégée sur les lignes de stats_boot à au moins une valeur finie) = lignes calculées − length(sigma_boot), et = bootstrap$n_sans_sigma (champ présent sur 1100) ; écart entre n_sans_sigma du masque et de la boucle allégée seule : 0 triangle(s) |
| 9 | OK | docs/tableaux/20261026-issue297-calibration-famille-mw-brut.tsv, lignes rep, loi E, colonnes pR:<clé> : b = 1 (graines 20850001 et 20880001) : 13 / 13 p_mc identiques ; b = 2 (graines 20850002 et 20880002) : 13 / 13 p_mc identiques (identical()) |
| 10 | OK | plages de la mesure (triangles, bootstraps des 5 profils, oracle, pré-vol) de 387000001 à 393100000, disjointes entre elles : oui ; disjointes de #206/#297 MW 20840001-20960000, #297 LN 20260831-20262831, #305 305000000-305939169 : oui ; graines du contrôle 9 hors des plages : oui ; maximum ≤ 2^31 − 1 : oui ; 127 littéraux entiers de 8 à 10 chiffres dans 95 fichiers (R/engine.R, tests/*.R hors ce script, tests/unitaires/*.R ; écriture scientifique non recherchée), dont 41 à 9 ou 10 chiffres (123456789, 262350178, 305000000, 305100000, 305200000, 305250000, 305300000, 305350000, 305600000, 305650000, 305700000, 305750000, 448000000, 1073524114, 1138150042, 2146944479, 2147483647, 5864139292, 5888798043, 5904949481, 5904968834, 5904983887, 5904984418, 5905003573, 5905011303, 5905135878, 5927125080, 5927249876, 5927254443, 6021758543, 6058031276, 6058041254, 6060869720, 6062485163, 6120564480, 6170835485, 6172078766, 6172090383, 6261951079, 6541872644, 6588872570) ; littéraux L dont [L ; L + 20000] touche une plage : aucun ; littéraux au-dessus des plages : 448000000, 1073524114, 1138150042, 2146944479, 2147483647, 5864139292, 5888798043, 5904949481, 5904968834, 5904983887, 5904984418, 5905003573, 5905011303, 5905135878, 5927125080, 5927249876, 5927254443, 6021758543, 6058031276, 6058041254, 6060869720, 6062485163, 6120564480, 6170835485, 6172078766, 6172090383, 6261951079, 6541872644, 6588872570 |
| 11 (t387) | OK | par. 3 (critère et profils, 23 lignes) présent à l'identique ; par. 1 (statut épistémique) présent à l'identique, dans docs/revues/20261119-s5-bootstrap-mw/actuary-1b-protocole-387.md (md5 d6ddf1161f7b4932024b599394e7e558) ; vérifié avant la boucle de calcul |
| 12 (m) | OK | aucune occurrence de « couverture_ic_sigma_mw » dans R/, app.R et .github/ (18 fichiers lus) ; en défaut : aucun |
| 13 | OK | recomposer(aj, f chapeau, σ̂²) redonne MSEP et R identical() : générateurs reserve2 oui, fixture oui ; 7966 / 7966 triangles admis ; σ_B : R_B ≤ 0 ou MSEP_B non finie sur 0 triangle(s) (compté(s) à part) |
| 14 | OK | .mc_p_values(stats_boot, obs, MW_CATALOGUE_MC, contexte observé) identical() à boot$p_mc, et statistiques observées de stats_oracle() identical() à boot$stats_obs : fixture oui ; P4 : 1016 / 1016 et 1016 / 1016 triangles admis |
| fixture | OK | tests/donnees/triangle_mw_volatil.csv présent (md5 89b0d65628c79b2225806372c424cb31) ; identique au dput de A.0 (identical()) : oui ; générateur de P4 et P5 lu dans le fichier |

### T1 — K-M1 (principal) : classe à 90 % de I1, I2 et I4 sur P1 et P2, cible σ_A

| Profil | Intervalle | n | couverture [IC 95 %] | τ̂ [IC CP 95 %] | classe (τ, ρ = 0,10) | K-M5 : IC touche un bord |
| --- | --- | --- | --- | --- | --- | --- |
| P1 | I1 percentile | 2000 | 0,5730 [0,5510 ; 0,5948] | 0,4270 [0,4052 ; 0,4490] | distorsion matérielle libérale (sous-couverture) | non |
| P1 | I2 « basic » | 2000 | 0,5960 [0,5741 ; 0,6176] | 0,4040 [0,3824 ; 0,4259] | distorsion matérielle libérale (sous-couverture) | non |
| P1 | I4 « basic » log | 2000 | 0,6915 [0,6707 ; 0,7117] | 0,3085 [0,2883 ; 0,3293] | distorsion matérielle libérale (sous-couverture) | non |
| P2 | I1 percentile | 2000 | 0,6170 [0,5953 ; 0,6384] | 0,3830 [0,3616 ; 0,4047] | distorsion matérielle libérale (sous-couverture) | non |
| P2 | I2 « basic » | 2000 | 0,6400 [0,6185 ; 0,6611] | 0,3600 [0,3389 ; 0,3815] | distorsion matérielle libérale (sous-couverture) | non |
| P2 | I4 « basic » log | 2000 | 0,7325 [0,7125 ; 0,7518] | 0,2675 [0,2482 ; 0,2875] | distorsion matérielle libérale (sous-couverture) | non |

### T2 — K-M2 (secondaire, portée conditionnelle) : classe à 90 % de I1, I2 et I4 sur les triangles admis de P4, cible σ_A

| Profil | Intervalle | n | couverture [IC 95 %] | τ̂ [IC CP 95 %] | classe (τ, ρ = 0,10) | K-M5 : IC touche un bord |
| --- | --- | --- | --- | --- | --- | --- |
| P4 | I1 percentile | 1016 | 0,5374 [0,5062 ; 0,5684] | 0,4626 [0,4316 ; 0,4938] | distorsion matérielle libérale (sous-couverture) | non |
| P4 | I2 « basic » | 1016 | 0,1250 [0,1053 ; 0,1469] | 0,8750 [0,8531 ; 0,8947] | distorsion matérielle libérale (sous-couverture) | non |
| P4 | I4 « basic » log | 1016 | 0,3799 [0,3500 ; 0,4106] | 0,6201 [0,5894 ; 0,6500] | distorsion matérielle libérale (sous-couverture) | non |

### T3 — couverture par profil, intervalle et niveau, cible σ_A (K-M1 à K-M3, K-M5)

Queues séparées (K-M3) : part de σ_A sous la borne basse et au-dessus de la borne haute, classe contre ρ/2 (bande [ρ/4 ; 3ρ/4]). Largeurs divisées par σ_A : quantiles 10 %, 50 %, 90 % ; moyenne sur P1 à P3 seulement (P4, P5 : non informative, protocole par. 4).

| Profil | Intervalle | Niveau | n | couverture [IC 95 %] | τ̂ [IC] | classe (τ, ρ) | K-M5 | sous la borne basse [IC] ; classe (ρ/2) | au-dessus de la borne haute [IC] ; classe (ρ/2) | largeur / σ_A : q10 ; médiane ; q90 | largeur moyenne / σ_A | bornes basses ≤ 0 | bornes hautes infinies |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P1 | I1 percentile | 90 % | 2000 | 0,5730 [0,5510 ; 0,5948] | 0,4270 [0,4052 ; 0,4490] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0018] ; distorsion matérielle conservatrice | 0,4270 [0,4052 ; 0,4490] ; distorsion matérielle libérale (sous-couverture) | 0,2898 ; 0,4795 ; 1,0646 | 0,5913 | 0 | 0 |
| P1 | I1 percentile | 95 % | 2000 | 0,6285 [0,6069 ; 0,6497] | 0,3715 [0,3503 ; 0,3931] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0018] ; distorsion matérielle conservatrice | 0,3715 [0,3503 ; 0,3931] ; distorsion matérielle libérale (sous-couverture) | 0,3431 ; 0,5670 ; 1,2054 | 0,6867 | 0 | 0 |
| P1 | I2 « basic » | 90 % | 2000 | 0,5960 [0,5741 ; 0,6176] | 0,4040 [0,3824 ; 0,4259] | distorsion matérielle libérale (sous-couverture) | non | 0,0010 [0,0001 ; 0,0036] ; distorsion matérielle conservatrice | 0,4030 [0,3814 ; 0,4249] ; distorsion matérielle libérale (sous-couverture) | 0,2898 ; 0,4795 ; 1,0646 | 0,5913 | 0 | 0 |
| P1 | I2 « basic » | 95 % | 2000 | 0,6545 [0,6332 ; 0,6754] | 0,3455 [0,3246 ; 0,3668] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0018] ; distorsion matérielle conservatrice | 0,3455 [0,3246 ; 0,3668] ; distorsion matérielle libérale (sous-couverture) | 0,3431 ; 0,5670 ; 1,2054 | 0,6867 | 0 | 0 |
| P1 | I4 « basic » log | 90 % | 2000 | 0,6915 [0,6707 ; 0,7117] | 0,3085 [0,2883 ; 0,3293] | distorsion matérielle libérale (sous-couverture) | non | 0,0145 [0,0097 ; 0,0208] ; distorsion matérielle conservatrice | 0,2940 [0,2741 ; 0,3145] ; distorsion matérielle libérale (sous-couverture) | 0,3123 ; 0,5392 ; 1,4123 | 0,7256 | 0 | 0 |
| P1 | I4 « basic » log | 95 % | 2000 | 0,7950 [0,7766 ; 0,8125] | 0,2050 [0,1875 ; 0,2234] | distorsion matérielle libérale (sous-couverture) | non | 0,0035 [0,0014 ; 0,0072] ; distorsion matérielle conservatrice | 0,2015 [0,1841 ; 0,2198] ; distorsion matérielle libérale (sous-couverture) | 0,3814 ; 0,6461 ; 1,6286 | 0,8521 | 0 | 0 |
| P2 | I1 percentile | 90 % | 2000 | 0,6170 [0,5953 ; 0,6384] | 0,3830 [0,3616 ; 0,4047] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0018] ; distorsion matérielle conservatrice | 0,3830 [0,3616 ; 0,4047] ; distorsion matérielle libérale (sous-couverture) | 0,3043 ; 0,4961 ; 1,0265 | 0,5946 | 0 | 0 |
| P2 | I1 percentile | 95 % | 2000 | 0,6770 [0,6560 ; 0,6975] | 0,3230 [0,3025 ; 0,3440] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0018] ; distorsion matérielle conservatrice | 0,3230 [0,3025 ; 0,3440] ; distorsion matérielle libérale (sous-couverture) | 0,3607 ; 0,5904 ; 1,1842 | 0,6953 | 0 | 0 |
| P2 | I2 « basic » | 90 % | 2000 | 0,6400 [0,6185 ; 0,6611] | 0,3600 [0,3389 ; 0,3815] | distorsion matérielle libérale (sous-couverture) | non | 0,0060 [0,0031 ; 0,0105] ; distorsion matérielle conservatrice | 0,3540 [0,3330 ; 0,3754] ; distorsion matérielle libérale (sous-couverture) | 0,3043 ; 0,4961 ; 1,0265 | 0,5946 | 0 | 0 |
| P2 | I2 « basic » | 95 % | 2000 | 0,6920 [0,6712 ; 0,7122] | 0,3080 [0,2878 ; 0,3288] | distorsion matérielle libérale (sous-couverture) | non | 0,0010 [0,0001 ; 0,0036] ; distorsion matérielle conservatrice | 0,3070 [0,2868 ; 0,3277] ; distorsion matérielle libérale (sous-couverture) | 0,3607 ; 0,5904 ; 1,1842 | 0,6953 | 0 | 0 |
| P2 | I4 « basic » log | 90 % | 2000 | 0,7325 [0,7125 ; 0,7518] | 0,2675 [0,2482 ; 0,2875] | distorsion matérielle libérale (sous-couverture) | non | 0,0190 [0,0135 ; 0,0260] ; non tranché | 0,2485 [0,2297 ; 0,2680] ; distorsion matérielle libérale (sous-couverture) | 0,3316 ; 0,5700 ; 1,3395 | 0,7258 | 0 | 0 |
| P2 | I4 « basic » log | 95 % | 2000 | 0,8160 [0,7983 ; 0,8328] | 0,1840 [0,1672 ; 0,2017] | distorsion matérielle libérale (sous-couverture) | non | 0,0090 [0,0053 ; 0,0142] ; non tranché | 0,1750 [0,1586 ; 0,1924] ; distorsion matérielle libérale (sous-couverture) | 0,4024 ; 0,6856 ; 1,5427 | 0,8589 | 0 | 0 |
| P3 | I1 percentile | 90 % | 1000 | 0,5180 [0,4865 ; 0,5494] | 0,4820 [0,4506 ; 0,5135] | distorsion matérielle libérale (sous-couverture) | non | 0,0010 [0,0000 ; 0,0056] ; distorsion matérielle conservatrice | 0,4810 [0,4496 ; 0,5125] ; distorsion matérielle libérale (sous-couverture) | 0,2823 ; 0,4795 ; 1,0324 | 0,5852 | 0 | 0 |
| P3 | I1 percentile | 95 % | 1000 | 0,5680 [0,5366 ; 0,5990] | 0,4320 [0,4010 ; 0,4634] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0037] ; distorsion matérielle conservatrice | 0,4320 [0,4010 ; 0,4634] ; distorsion matérielle libérale (sous-couverture) | 0,3357 ; 0,5728 ; 1,1867 | 0,6814 | 0 | 0 |
| P3 | I2 « basic » | 90 % | 1000 | 0,5520 [0,5206 ; 0,5831] | 0,4480 [0,4169 ; 0,4794] | distorsion matérielle libérale (sous-couverture) | non | 0,0050 [0,0016 ; 0,0116] ; distorsion matérielle conservatrice | 0,4430 [0,4119 ; 0,4744] ; distorsion matérielle libérale (sous-couverture) | 0,2823 ; 0,4795 ; 1,0324 | 0,5852 | 0 | 0 |
| P3 | I2 « basic » | 95 % | 1000 | 0,6040 [0,5729 ; 0,6345] | 0,3960 [0,3655 ; 0,4271] | distorsion matérielle libérale (sous-couverture) | non | 0,0020 [0,0002 ; 0,0072] ; distorsion matérielle conservatrice | 0,3940 [0,3636 ; 0,4251] ; distorsion matérielle libérale (sous-couverture) | 0,3357 ; 0,5728 ; 1,1867 | 0,6814 | 0 | 0 |
| P3 | I4 « basic » log | 90 % | 1000 | 0,6570 [0,6266 ; 0,6864] | 0,3430 [0,3136 ; 0,3734] | distorsion matérielle libérale (sous-couverture) | non | 0,0230 [0,0146 ; 0,0343] ; non tranché | 0,3200 [0,2912 ; 0,3499] ; distorsion matérielle libérale (sous-couverture) | 0,3085 ; 0,5585 ; 1,4096 | 0,7327 | 0 | 0 |
| P3 | I4 « basic » log | 95 % | 1000 | 0,7360 [0,7075 ; 0,7631] | 0,2640 [0,2369 ; 0,2925] | distorsion matérielle libérale (sous-couverture) | non | 0,0160 [0,0092 ; 0,0259] ; compatible | 0,2480 [0,2215 ; 0,2760] ; distorsion matérielle libérale (sous-couverture) | 0,3754 ; 0,6814 ; 1,6032 | 0,8713 | 0 | 0 |
| P4 | I1 percentile | 90 % | 1016 | 0,5374 [0,5062 ; 0,5684] | 0,4626 [0,4316 ; 0,4938] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0036] ; distorsion matérielle conservatrice | 0,4626 [0,4316 ; 0,4938] ; distorsion matérielle libérale (sous-couverture) | 0,1135 ; 1,0674 ; 2,6360 | — | 0 | 0 |
| P4 | I1 percentile | 95 % | 1016 | 0,6811 [0,6515 ; 0,7097] | 0,3189 [0,2903 ; 0,3485] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0036] ; distorsion matérielle conservatrice | 0,3189 [0,2903 ; 0,3485] ; distorsion matérielle libérale (sous-couverture) | 0,1461 ; 1,9867 ; 5,2457 | — | 0 | 0 |
| P4 | I2 « basic » | 90 % | 1016 | 0,1250 [0,1053 ; 0,1469] | 0,8750 [0,8531 ; 0,8947] | distorsion matérielle libérale (sous-couverture) | non | 0,0561 [0,0428 ; 0,0721] ; compatible | 0,8189 [0,7938 ; 0,8421] ; distorsion matérielle libérale (sous-couverture) | 0,1135 ; 1,0674 ; 2,6360 | — | 834 | 0 |
| P4 | I2 « basic » | 95 % | 1016 | 0,1457 [0,1245 ; 0,1689] | 0,8543 [0,8311 ; 0,8755] | distorsion matérielle libérale (sous-couverture) | non | 0,0384 [0,0274 ; 0,0521] ; non tranché | 0,8159 [0,7907 ; 0,8393] ; distorsion matérielle libérale (sous-couverture) | 0,1461 ; 1,9867 ; 5,2457 | — | 907 | 0 |
| P4 | I4 « basic » log | 90 % | 1016 | 0,3799 [0,3500 ; 0,4106] | 0,6201 [0,5894 ; 0,6500] | distorsion matérielle libérale (sous-couverture) | non | 0,0640 [0,0497 ; 0,0808] ; compatible | 0,5561 [0,5249 ; 0,5869] ; distorsion matérielle libérale (sous-couverture) | 0,1095 ; 0,7960 ; 13,8716 | — | 0 | 0 |
| P4 | I4 « basic » log | 95 % | 1016 | 0,4459 [0,4150 ; 0,4770] | 0,5541 [0,5230 ; 0,5850] | distorsion matérielle libérale (sous-couverture) | non | 0,0453 [0,0333 ; 0,0599] ; non tranché | 0,5089 [0,4776 ; 0,5400] ; distorsion matérielle libérale (sous-couverture) | 0,1365 ; 0,9548 ; 16,7057 | — | 0 | 0 |
| P5 | I1 percentile | 90 % | 1950 | 0,5641 [0,5418 ; 0,5863] | 0,4359 [0,4137 ; 0,4582] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0019] ; distorsion matérielle conservatrice | 0,4359 [0,4137 ; 0,4582] ; distorsion matérielle libérale (sous-couverture) | 0,1222 ; 1,1618 ; 2,7133 | — | 0 | 0 |
| P5 | I1 percentile | 95 % | 1950 | 0,6862 [0,6650 ; 0,7067] | 0,3138 [0,2933 ; 0,3350] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0019] ; distorsion matérielle conservatrice | 0,3138 [0,2933 ; 0,3350] ; distorsion matérielle libérale (sous-couverture) | 0,1547 ; 2,1997 ; 5,5821 | — | 0 | 0 |
| P5 | I2 « basic » | 90 % | 1950 | 0,1631 [0,1469 ; 0,1802] | 0,8369 [0,8198 ; 0,8531] | distorsion matérielle libérale (sous-couverture) | non | 0,0513 [0,0419 ; 0,0620] ; compatible | 0,7856 [0,7667 ; 0,8037] ; distorsion matérielle libérale (sous-couverture) | 0,1222 ; 1,1618 ; 2,7133 | — | 1605 | 0 |
| P5 | I2 « basic » | 95 % | 1950 | 0,1851 [0,1681 ; 0,2031] | 0,8149 [0,7969 ; 0,8319] | distorsion matérielle libérale (sous-couverture) | non | 0,0318 [0,0245 ; 0,0406] ; compatible | 0,7831 [0,7641 ; 0,8012] ; distorsion matérielle libérale (sous-couverture) | 0,1547 ; 2,1997 ; 5,5821 | — | 1756 | 0 |
| P5 | I4 « basic » log | 90 % | 1950 | 0,4041 [0,3822 ; 0,4263] | 0,5959 [0,5737 ; 0,6178] | distorsion matérielle libérale (sous-couverture) | non | 0,0615 [0,0513 ; 0,0731] ; écart mineur | 0,5344 [0,5119 ; 0,5567] ; distorsion matérielle libérale (sous-couverture) | 0,1128 ; 0,8424 ; 17,5612 | — | 0 | 0 |
| P5 | I4 « basic » log | 95 % | 1950 | 0,4621 [0,4397 ; 0,4845] | 0,5379 [0,5155 ; 0,5603] | distorsion matérielle libérale (sous-couverture) | non | 0,0436 [0,0350 ; 0,0536] ; non tranché | 0,4944 [0,4719 ; 0,5168] ; distorsion matérielle libérale (sous-couverture) | 0,1403 ; 1,0115 ; 20,8826 | — | 0 | 0 |

### T4 — couverture de σ_B (cible descriptive, K-M3)

σ_B(r) = √MSEP/R de mw_msep() sur la copie de l'ajustement du triangle r à (f, σ²) du générateur (P3, interprétation sans source) ; triangles à R_B ≤ 0 ou MSEP_B non finie comptés à part.

| Profil | Intervalle | Niveau | n | couverture de σ_B [IC 95 %] | τ̂ [IC] | classe (τ, ρ), descriptive | R_B ≤ 0 ou MSEP_B non finie |
| --- | --- | --- | --- | --- | --- | --- | --- |
| P1 | I1 percentile | 90 % | 2000 | 0,5900 [0,5681 ; 0,6117] | 0,4100 [0,3883 ; 0,4319] | distorsion matérielle libérale (sous-couverture) | 0 |
| P1 | I1 percentile | 95 % | 2000 | 0,6460 [0,6246 ; 0,6670] | 0,3540 [0,3330 ; 0,3754] | distorsion matérielle libérale (sous-couverture) | 0 |
| P1 | I2 « basic » | 90 % | 2000 | 0,6120 [0,5902 ; 0,6334] | 0,3880 [0,3666 ; 0,4098] | distorsion matérielle libérale (sous-couverture) | 0 |
| P1 | I2 « basic » | 95 % | 2000 | 0,6730 [0,6519 ; 0,6935] | 0,3270 [0,3065 ; 0,3481] | distorsion matérielle libérale (sous-couverture) | 0 |
| P1 | I4 « basic » log | 90 % | 2000 | 0,7070 [0,6865 ; 0,7269] | 0,2930 [0,2731 ; 0,3135] | distorsion matérielle libérale (sous-couverture) | 0 |
| P1 | I4 « basic » log | 95 % | 2000 | 0,8140 [0,7962 ; 0,8308] | 0,1860 [0,1692 ; 0,2038] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | I1 percentile | 90 % | 2000 | 0,6355 [0,6140 ; 0,6566] | 0,3645 [0,3434 ; 0,3860] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | I1 percentile | 95 % | 2000 | 0,6935 [0,6728 ; 0,7137] | 0,3065 [0,2863 ; 0,3272] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | I2 « basic » | 90 % | 2000 | 0,6585 [0,6372 ; 0,6793] | 0,3415 [0,3207 ; 0,3628] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | I2 « basic » | 95 % | 2000 | 0,7070 [0,6865 ; 0,7269] | 0,2930 [0,2731 ; 0,3135] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | I4 « basic » log | 90 % | 2000 | 0,7455 [0,7258 ; 0,7645] | 0,2545 [0,2355 ; 0,2742] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | I4 « basic » log | 95 % | 2000 | 0,8225 [0,8050 ; 0,8390] | 0,1775 [0,1610 ; 0,1950] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | I1 percentile | 90 % | 1000 | 0,5310 [0,4995 ; 0,5623] | 0,4690 [0,4377 ; 0,5005] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | I1 percentile | 95 % | 1000 | 0,5870 [0,5558 ; 0,6177] | 0,4130 [0,3823 ; 0,4442] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | I2 « basic » | 90 % | 1000 | 0,5730 [0,5417 ; 0,6039] | 0,4270 [0,3961 ; 0,4583] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | I2 « basic » | 95 % | 1000 | 0,6200 [0,5891 ; 0,6502] | 0,3800 [0,3498 ; 0,4109] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | I4 « basic » log | 90 % | 1000 | 0,6760 [0,6460 ; 0,7050] | 0,3240 [0,2950 ; 0,3540] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | I4 « basic » log | 95 % | 1000 | 0,7440 [0,7158 ; 0,7708] | 0,2560 [0,2292 ; 0,2842] | distorsion matérielle libérale (sous-couverture) | 0 |
| P4 | I1 percentile | 90 % | 1016 | 0,5354 [0,5042 ; 0,5665] | 0,4646 [0,4335 ; 0,4958] | distorsion matérielle libérale (sous-couverture) | 0 |
| P4 | I1 percentile | 95 % | 1016 | 0,6821 [0,6525 ; 0,7106] | 0,3179 [0,2894 ; 0,3475] | distorsion matérielle libérale (sous-couverture) | 0 |
| P4 | I2 « basic » | 90 % | 1016 | 0,1447 [0,1236 ; 0,1678] | 0,8553 [0,8322 ; 0,8764] | distorsion matérielle libérale (sous-couverture) | 0 |
| P4 | I2 « basic » | 95 % | 1016 | 0,1663 [0,1439 ; 0,1907] | 0,8337 [0,8093 ; 0,8561] | distorsion matérielle libérale (sous-couverture) | 0 |
| P4 | I4 « basic » log | 90 % | 1016 | 0,3839 [0,3538 ; 0,4146] | 0,6161 [0,5854 ; 0,6462] | distorsion matérielle libérale (sous-couverture) | 0 |
| P4 | I4 « basic » log | 95 % | 1016 | 0,4409 [0,4101 ; 0,4721] | 0,5591 [0,5279 ; 0,5899] | distorsion matérielle libérale (sous-couverture) | 0 |
| P5 | I1 percentile | 90 % | 1950 | 0,5651 [0,5428 ; 0,5873] | 0,4349 [0,4127 ; 0,4572] | distorsion matérielle libérale (sous-couverture) | 0 |
| P5 | I1 percentile | 95 % | 1950 | 0,6913 [0,6702 ; 0,7117] | 0,3087 [0,2883 ; 0,3298] | distorsion matérielle libérale (sous-couverture) | 0 |
| P5 | I2 « basic » | 90 % | 1950 | 0,1697 [0,1533 ; 0,1872] | 0,8303 [0,8128 ; 0,8467] | distorsion matérielle libérale (sous-couverture) | 0 |
| P5 | I2 « basic » | 95 % | 1950 | 0,1933 [0,1760 ; 0,2116] | 0,8067 [0,7884 ; 0,8240] | distorsion matérielle libérale (sous-couverture) | 0 |
| P5 | I4 « basic » log | 90 % | 1950 | 0,4092 [0,3873 ; 0,4314] | 0,5908 [0,5686 ; 0,6127] | distorsion matérielle libérale (sous-couverture) | 0 |
| P5 | I4 « basic » log | 95 % | 1950 | 0,4656 [0,4433 ; 0,4881] | 0,5344 [0,5119 ; 0,5567] | distorsion matérielle libérale (sous-couverture) | 0 |

### T5 — couverture de σ_A par strate de π̂ = n_sans_sigma / B (P4 et P5, K-M3, descriptif)

| Profil | Intervalle | Niveau | π̂ 0 : n ; couverture [IC] | π̂ ]0 ; 0,05] : n ; couverture [IC] | π̂ ]0,05 ; 0,20] : n ; couverture [IC] | π̂ > 0,20 : n ; couverture [IC] |
| --- | --- | --- | --- | --- | --- | --- |
| P4 | I1 percentile | 90 % | 111 ; 0,0000 [0,0000 ; 0,0327] | 212 ; 0,0000 [0,0000 ; 0,0172] | 292 ; 0,5068 [0,4480 ; 0,5656] | 401 ; 0,9925 [0,9783 ; 0,9985] |
| P4 | I1 percentile | 95 % | 111 ; 0,0000 [0,0000 ; 0,0327] | 212 ; 0,0660 [0,0366 ; 0,1083] | 292 ; 0,9486 [0,9167 ; 0,9710] | 401 ; 1,0000 [0,9908 ; 1,0000] |
| P4 | I2 « basic » | 90 % | 111 ; 0,0000 [0,0000 ; 0,0327] | 212 ; 0,0000 [0,0000 ; 0,0172] | 292 ; 0,0000 [0,0000 ; 0,0126] | 401 ; 0,3167 [0,2714 ; 0,3647] |
| P4 | I2 « basic » | 95 % | 111 ; 0,0000 [0,0000 ; 0,0327] | 212 ; 0,0000 [0,0000 ; 0,0172] | 292 ; 0,0000 [0,0000 ; 0,0126] | 401 ; 0,3691 [0,3217 ; 0,4184] |
| P4 | I4 « basic » log | 90 % | 111 ; 0,0000 [0,0000 ; 0,0327] | 212 ; 0,0000 [0,0000 ; 0,0172] | 292 ; 0,1952 [0,1513 ; 0,2454] | 401 ; 0,8204 [0,7793 ; 0,8568] |
| P4 | I4 « basic » log | 95 % | 111 ; 0,0000 [0,0000 ; 0,0327] | 212 ; 0,0000 [0,0000 ; 0,0172] | 292 ; 0,3390 [0,2849 ; 0,3965] | 401 ; 0,8828 [0,8472 ; 0,9126] |
| P5 | I1 percentile | 90 % | 217 ; 0,0000 [0,0000 ; 0,0169] | 391 ; 0,0026 [0,0001 ; 0,0142] | 498 ; 0,5141 [0,4692 ; 0,5588] | 844 ; 0,9988 [0,9934 ; 1,0000] |
| P5 | I1 percentile | 95 % | 217 ; 0,0000 [0,0000 ; 0,0169] | 391 ; 0,0665 [0,0439 ; 0,0959] | 498 ; 0,9398 [0,9151 ; 0,9590] | 844 ; 1,0000 [0,9956 ; 1,0000] |
| P5 | I2 « basic » | 90 % | 217 ; 0,0000 [0,0000 ; 0,0169] | 391 ; 0,0000 [0,0000 ; 0,0094] | 498 ; 0,0000 [0,0000 ; 0,0074] | 844 ; 0,3768 [0,3440 ; 0,4104] |
| P5 | I2 « basic » | 95 % | 217 ; 0,0000 [0,0000 ; 0,0169] | 391 ; 0,0000 [0,0000 ; 0,0094] | 498 ; 0,0000 [0,0000 ; 0,0074] | 844 ; 0,4277 [0,3941 ; 0,4619] |
| P5 | I4 « basic » log | 90 % | 217 ; 0,0000 [0,0000 ; 0,0169] | 391 ; 0,0000 [0,0000 ; 0,0094] | 498 ; 0,1586 [0,1277 ; 0,1937] | 844 ; 0,8400 [0,8135 ; 0,8641] |
| P5 | I4 « basic » log | 95 % | 217 ; 0,0000 [0,0000 ; 0,0169] | 391 ; 0,0000 [0,0000 ; 0,0094] | 498 ; 0,2912 [0,2516 ; 0,3332] | 844 ; 0,8957 [0,8731 ; 0,9155] |

### T6 — biais (K-M3, descriptif)

| Profil | n | médiane de σ̂/σ_A | moyenne de σ̂/moyenne(σ*) (P1 à P3) | médiane du rang de σ̂ dans σ* (#{σ* < σ̂}/B_eff) |
| --- | --- | --- | --- | --- |
| P1 | 2000 | 0,8447 | 1,0547 | 0,6011 |
| P2 | 2000 | 0,8450 | 1,0528 | 0,6026 |
| P3 | 1000 | 0,7897 | 1,0509 | 0,5811 |
| P4 | 1016 | 0,2025 | — | 0,6312 |
| P5 | 1950 | 0,2151 | — | 0,6338 |

### T7 — admission, refus, triangles sans intervalle, n_sans_sigma

| Profil | tirés | statut ok | statut sans_intervalle | statut refus | statut echec_bootstrap | statut echec_autre | motifs de refus | non retenus / tirés (Ω0 : P1, P2) | π̂ : min ; q10 ; q25 ; médiane ; q75 ; q90 ; max | π̂ = 0 ; > 0,05 ; > 0,20 | retirage (cumuls) ; plafond |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P1 | 2000 | 2000 | 0 | 0 | 0 | 0 | aucun | 0,0000 | 0,0000 ; 0,0000 ; 0,0000 ; 0,0000 ; 0,0000 ; 0,0000 ; 0,0000 | 1,0000 ; 0,0000 ; 0,0000 | 0 ; 0 |
| P2 | 2000 | 2000 | 0 | 0 | 0 | 0 | aucun | 0,0000 | 0,0000 ; 0,0000 ; 0,0000 ; 0,0000 ; 0,0000 ; 0,0000 ; 0,0000 | 1,0000 ; 0,0000 ; 0,0000 | 0 ; 0 |
| P3 | 1000 | 1000 | 0 | 0 | 0 | 0 | aucun | 0,0000 | 0,0000 ; 0,0000 ; 0,0000 ; 0,0000 ; 0,0000 ; 0,0000 ; 0,0000 | 1,0000 ; 0,0000 ; 0,0000 | 0 ; 0 |
| P4 | 1700 | 1016 | 0 | 684 | 0 | 0 | M4 (684) | 0,4024 | 0,0000 ; 0,0000 ; 0,0220 ; 0,1381 ; 0,3056 ; 0,4184 ; 0,5375 | 0,1093 ; 0,6821 ; 0,3947 | 0 ; 0 |
| P5 | 3400 | 1950 | 0 | 1450 | 0 | 0 | M4 (1450) | 0,4265 | 0,0000 ; 0,0000 ; 0,0233 ; 0,1552 ; 0,3261 ; 0,4304 ; 0,5576 | 0,1113 ; 0,6882 ; 0,4328 | 0 ; 0 |

P4 : refus d'un autre motif que M4 et échecs / tirés (Ω0) : 0,0000.

### T8 — volet A.5 (ii) de #492 : taux de rejet des 13 p de Monte-Carlo sur les triangles admis de P4 (Q-1b-5 (A))

Population : 1016 triangles admis de P4 à bootstrap complet. Décision : p < α ; une p absente compte comme un non-rejet (comptée à part). ρ : taille lissée du test de Monte-Carlo idéal à B = 999 (règle de #206, par. 4), calculée sur l'oracle de P4 restreint aux triangles admis (9988 sur 17000 tirés) ; statistique oracle non finie comptée comme non-rejet. p conditionnelle : .mc_p_values() sur les seules lignes de stats_boot à σ* fini (masque de P5 (iii)), calculée dans ce script seulement ; elle ne change ni p ni verdict du moteur.

**Oracle et ρ**

| Clé (sens) | oracle admis | non finies | valeurs distinctes | masse du plus gros atome | ρ 0,10 | ρ 0,05 | taille témoin 0,10 | taille témoin 0,05 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Calendrier (bas) | 9988 | 0 | 108 | 0,09401 | 0,09116 | 0,04173 | 0,09429 | 0,04295 |
| CorrDev (deux) | 9988 | 0 | 2835 | 0,00210 | 0,09749 | 0,04760 | 0,09940 | 0,04942 |
| BP (haut) | 9988 | 0 | 9988 | 0,00010 | 0,09895 | 0,04895 | 0,09986 | 0,04990 |
| MinP4 (bas) | 9988 | 0 | 9988 | 0,00010 | 0,09895 | 0,04895 | 0,09986 | 0,04990 |
| DW (deux) | 9988 | 0 | 9988 | 0,00010 | 0,09790 | 0,04790 | 0,09981 | 0,04975 |
| Runs (deux) | 9988 | 0 | 27 | 0,16780 | 0,05409 | 0,03029 | 0,04739 | 0,03067 |
| PenteIntra (deux) | 9988 | 0 | 9988 | 0,00010 | 0,09790 | 0,04790 | 0,09981 | 0,04975 |
| Origine (haut) | 9988 | 0 | 9988 | 0,00010 | 0,09895 | 0,04895 | 0,09986 | 0,04990 |
| HomogF (haut) | 9988 | 0 | 7170 | 0,00100 | 0,09894 | 0,04894 | 0,09985 | 0,04990 |
| Courbure (haut) | 9988 | 0 | 9988 | 0,00010 | 0,09895 | 0,04895 | 0,09986 | 0,04990 |
| Alpha (haut) | 9988 | 0 | 9988 | 0,00010 | 0,09895 | 0,04895 | 0,09986 | 0,04990 |
| ExpVar (haut) | 9988 | 0 | 8259 | 0,00070 | 0,09894 | 0,04894 | 0,09985 | 0,04990 |
| KruskalAcc (haut) | 9988 | 0 | 8248 | 0,00060 | 0,09894 | 0,04894 | 0,09985 | 0,04989 |

**K-V1 : classe de #206 de τ contre ρ ; p conditionnelle en regard (descriptive)**

| α | Clé (sens) | n | p absentes (moteur ; cond.) | ρ | τ moteur [IC] | classe K-V1 | τ sur p définies | τ conditionnelle [IC] | classe de τ conditionnelle (descriptif : ρ à B = 999, p conditionnelle à B_eff variable, écart de référence non corrigé) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0,10 | Calendrier (bas) | 1016 | 0 ; 0 | 0,09116 | 0,09055 [0,07362 ; 0,10990] | compatible | 0,09055 | 0,09252 [0,07541 ; 0,11203] | compatible |
| 0,10 | CorrDev (deux) | 1016 | 0 ; 0 | 0,09749 | 0,08071 [0,06470 ; 0,09919] | compatible | 0,08071 | 0,08366 [0,06737 ; 0,10241] | compatible |
| 0,10 | BP (haut) | 1016 | 0 ; 0 | 0,09895 | 0,08661 [0,07004 ; 0,10562] | compatible | 0,08661 | 0,08858 [0,07183 ; 0,10776] | compatible |
| 0,10 | MinP4 (bas) | 1016 | 0 ; 0 | 0,09895 | 0,08465 [0,06826 ; 0,10348] | compatible | 0,08465 | 0,08563 [0,06915 ; 0,10455] | compatible |
| 0,10 | DW (deux) | 1016 | 0 ; 0 | 0,09790 | 0,08071 [0,06470 ; 0,09919] | compatible | 0,08071 | 0,08071 [0,06470 ; 0,09919] | compatible |
| 0,10 | Runs (deux) | 1016 | 0 ; 0 | 0,05409 | 0,05118 [0,03846 ; 0,06658] | compatible | 0,05118 | 0,05118 [0,03846 ; 0,06658] | compatible |
| 0,10 | PenteIntra (deux) | 1016 | 0 ; 0 | 0,09790 | 0,11516 [0,09617 ; 0,13640] | compatible | 0,11516 | 0,11713 [0,09799 ; 0,13851] | écart mineur |
| 0,10 | Origine (haut) | 1016 | 0 ; 0 | 0,09895 | 0,08957 [0,07273 ; 0,10883] | compatible | 0,08957 | 0,08858 [0,07183 ; 0,10776] | compatible |
| 0,10 | HomogF (haut) | 1016 | 0 ; 0 | 0,09894 | 0,10925 [0,09073 ; 0,13007] | compatible | 0,10925 | 0,10827 [0,08983 ; 0,12901] | compatible |
| 0,10 | Courbure (haut) | 1016 | 0 ; 0 | 0,09895 | 0,10433 [0,08621 ; 0,12478] | compatible | 0,10433 | 0,10335 [0,08531 ; 0,12372] | compatible |
| 0,10 | Alpha (haut) | 1016 | 0 ; 0 | 0,09895 | 0,08760 [0,07094 ; 0,10669] | compatible | 0,08760 | 0,09252 [0,07541 ; 0,11203] | compatible |
| 0,10 | ExpVar (haut) | 1016 | 0 ; 0 | 0,09894 | 0,07972 [0,06381 ; 0,09812] | écart mineur | 0,07972 | 0,07874 [0,06293 ; 0,09704] | écart mineur |
| 0,10 | KruskalAcc (haut) | 1016 | 0 ; 0 | 0,09894 | 0,08366 [0,06737 ; 0,10241] | compatible | 0,08366 | 0,08563 [0,06915 ; 0,10455] | compatible |
| 0,05 | Calendrier (bas) | 1016 | 0 ; 0 | 0,04173 | 0,04035 [0,02911 ; 0,05435] | compatible | 0,04035 | 0,04134 [0,02995 ; 0,05547] | compatible |
| 0,05 | CorrDev (deux) | 1016 | 0 ; 0 | 0,04760 | 0,03937 [0,02827 ; 0,05323] | compatible | 0,03937 | 0,03937 [0,02827 ; 0,05323] | compatible |
| 0,05 | BP (haut) | 1016 | 0 ; 0 | 0,04895 | 0,04429 [0,03249 ; 0,05882] | compatible | 0,04429 | 0,04429 [0,03249 ; 0,05882] | compatible |
| 0,05 | MinP4 (bas) | 1016 | 0 ; 0 | 0,04895 | 0,04035 [0,02911 ; 0,05435] | compatible | 0,04035 | 0,04035 [0,02911 ; 0,05435] | compatible |
| 0,05 | DW (deux) | 1016 | 0 ; 0 | 0,04790 | 0,04134 [0,02995 ; 0,05547] | compatible | 0,04134 | 0,04134 [0,02995 ; 0,05547] | compatible |
| 0,05 | Runs (deux) | 1016 | 0 ; 0 | 0,03029 | 0,02953 [0,02001 ; 0,04189] | compatible | 0,02953 | 0,02854 [0,01920 ; 0,04074] | compatible |
| 0,05 | PenteIntra (deux) | 1016 | 0 ; 0 | 0,04790 | 0,05413 [0,04104 ; 0,06988] | compatible | 0,05413 | 0,05413 [0,04104 ; 0,06988] | compatible |
| 0,05 | Origine (haut) | 1016 | 0 ; 0 | 0,04895 | 0,04232 [0,03080 ; 0,05659] | compatible | 0,04232 | 0,04429 [0,03249 ; 0,05882] | compatible |
| 0,05 | HomogF (haut) | 1016 | 0 ; 0 | 0,04894 | 0,06102 [0,04710 ; 0,07755] | compatible | 0,06102 | 0,06102 [0,04710 ; 0,07755] | compatible |
| 0,05 | Courbure (haut) | 1016 | 0 ; 0 | 0,04895 | 0,05118 [0,03846 ; 0,06658] | compatible | 0,05118 | 0,05512 [0,04190 ; 0,07098] | compatible |
| 0,05 | Alpha (haut) | 1016 | 0 ; 0 | 0,04895 | 0,02854 [0,01920 ; 0,04074] | écart mineur | 0,02854 | 0,03150 [0,02164 ; 0,04417] | écart mineur |
| 0,05 | ExpVar (haut) | 1016 | 0 ; 0 | 0,04894 | 0,04134 [0,02995 ; 0,05547] | compatible | 0,04134 | 0,04232 [0,03080 ; 0,05659] | compatible |
| 0,05 | KruskalAcc (haut) | 1016 | 0 ; 0 | 0,04894 | 0,03937 [0,02827 ; 0,05323] | compatible | 0,03937 | 0,04134 [0,02995 ; 0,05547] | compatible |
| — | B_eff de la p conditionnelle sur P4 (lignes à σ* fini) | 1016 | — | — | — | — | — | min 462,0 ; q25 693,8 ; médiane 861,0 ; q75 977,0 ; max 999,0 | — |

**K-V2 : McNemar exact (binomiale 1/2 sur n01 + n10 ; n01 : le moteur rejette, la p conditionnelle non), Holm sur 13 par α**

| α | Clé (sens) | n01 / n10 | p | p Holm | significatif (0,05) |
| --- | --- | --- | --- | --- | --- |
| 0,10 | Calendrier (bas) | 2 / 4 | 0,687 | 1 | non |
| 0,10 | CorrDev (deux) | 1 / 4 | 0,375 | 1 | non |
| 0,10 | BP (haut) | 1 / 3 | 0,625 | 1 | non |
| 0,10 | MinP4 (bas) | 0 / 1 | 1 | 1 | non |
| 0,10 | DW (deux) | 1 / 1 | 1 | 1 | non |
| 0,10 | Runs (deux) | 1 / 1 | 1 | 1 | non |
| 0,10 | PenteIntra (deux) | 1 / 3 | 0,625 | 1 | non |
| 0,10 | Origine (haut) | 1 / 0 | 1 | 1 | non |
| 0,10 | HomogF (haut) | 2 / 1 | 1 | 1 | non |
| 0,10 | Courbure (haut) | 2 / 1 | 1 | 1 | non |
| 0,10 | Alpha (haut) | 2 / 7 | 0,18 | 1 | non |
| 0,10 | ExpVar (haut) | 1 / 0 | 1 | 1 | non |
| 0,10 | KruskalAcc (haut) | 1 / 3 | 0,625 | 1 | non |
| 0,05 | Calendrier (bas) | 0 / 1 | 1 | 1 | non |
| 0,05 | CorrDev (deux) | 2 / 2 | 1 | 1 | non |
| 0,05 | BP (haut) | 1 / 1 | 1 | 1 | non |
| 0,05 | MinP4 (bas) | 2 / 2 | 1 | 1 | non |
| 0,05 | DW (deux) | 2 / 2 | 1 | 1 | non |
| 0,05 | Runs (deux) | 1 / 0 | 1 | 1 | non |
| 0,05 | PenteIntra (deux) | 1 / 1 | 1 | 1 | non |
| 0,05 | Origine (haut) | 0 / 2 | 0,5 | 1 | non |
| 0,05 | HomogF (haut) | 2 / 2 | 1 | 1 | non |
| 0,05 | Courbure (haut) | 0 / 4 | 0,125 | 1 | non |
| 0,05 | Alpha (haut) | 0 / 3 | 0,25 | 1 | non |
| 0,05 | ExpVar (haut) | 0 / 1 | 1 | 1 | non |
| 0,05 | KruskalAcc (haut) | 1 / 3 | 0,625 | 1 | non |

**K-V3 : témoin oracle** (p_or = engine_p_mc(S0, s_obs, sens) contre l'oracle ; binomial exact contre la taille du témoin, Holm sur 13 par α ; signal expliqué si la p de Holm bêta-binomiale sur la région de rejet réalisée de l'oracle est au moins 0,05, règle de l'annotation du 05/11/2026 de #206)

| α | Clé (sens) | n | p_or absentes | k | τ_or | taille | p Holm binomiale | m_r / N | p Holm bêta-binomiale | atomes à cheval | K-V3 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0,10 | Calendrier (bas) | 1016 | 0 | 96 | 0,09449 | 0,09429 | 1 | 952 / 9988 | 1 | 1 | — |
| 0,10 | CorrDev (deux) | 1016 | 0 | 80 | 0,07874 | 0,09940 | 0,358 | 995 / 9988 | 0,416 | 2 | — |
| 0,10 | BP (haut) | 1016 | 0 | 95 | 0,09350 | 0,09986 | 1 | 997 / 9988 | 1 | 0 | — |
| 0,10 | MinP4 (bas) | 1016 | 0 | 115 | 0,11319 | 0,09986 | 1 | 997 / 9988 | 1 | 0 | — |
| 0,10 | DW (deux) | 1016 | 0 | 85 | 0,08366 | 0,09981 | 0,937 | 996 / 9988 | 1 | 0 | — |
| 0,10 | Runs (deux) | 1016 | 0 | 44 | 0,04331 | 0,04739 | 1 | 460 / 9988 | 1 | 2 | — |
| 0,10 | PenteIntra (deux) | 1016 | 0 | 106 | 0,10433 | 0,09981 | 1 | 996 / 9988 | 1 | 0 | — |
| 0,10 | Origine (haut) | 1016 | 0 | 101 | 0,09941 | 0,09986 | 1 | 997 / 9988 | 1 | 0 | — |
| 0,10 | HomogF (haut) | 1016 | 0 | 112 | 0,11024 | 0,09985 | 1 | 997 / 9988 | 1 | 0 | — |
| 0,10 | Courbure (haut) | 1016 | 0 | 107 | 0,10531 | 0,09986 | 1 | 997 / 9988 | 1 | 0 | — |
| 0,10 | Alpha (haut) | 1016 | 0 | 96 | 0,09449 | 0,09986 | 1 | 997 / 9988 | 1 | 0 | — |
| 0,10 | ExpVar (haut) | 1016 | 0 | 84 | 0,08268 | 0,09985 | 0,899 | 997 / 9988 | 1 | 0 | — |
| 0,10 | KruskalAcc (haut) | 1016 | 0 | 84 | 0,08268 | 0,09985 | 0,899 | 997 / 9988 | 1 | 0 | — |
| 0,05 | Calendrier (bas) | 1016 | 0 | 41 | 0,04035 | 0,04295 | 1 | 429 / 9988 | 1 | 1 | — |
| 0,05 | CorrDev (deux) | 1016 | 0 | 35 | 0,03445 | 0,04942 | 0,297 | 494 / 9988 | 0,377 | 2 | — |
| 0,05 | BP (haut) | 1016 | 0 | 45 | 0,04429 | 0,04990 | 1 | 498 / 9988 | 1 | 0 | — |
| 0,05 | MinP4 (bas) | 1016 | 0 | 63 | 0,06201 | 0,04990 | 0,916 | 498 / 9988 | 1 | 0 | — |
| 0,05 | DW (deux) | 1016 | 0 | 43 | 0,04232 | 0,04975 | 1 | 496 / 9988 | 1 | 0 | — |
| 0,05 | Runs (deux) | 1016 | 0 | 25 | 0,02461 | 0,03067 | 1 | 272 / 9988 | 1 | 2 | — |
| 0,05 | PenteIntra (deux) | 1016 | 0 | 53 | 0,05217 | 0,04975 | 1 | 496 / 9988 | 1 | 0 | — |
| 0,05 | Origine (haut) | 1016 | 0 | 45 | 0,04429 | 0,04990 | 1 | 498 / 9988 | 1 | 0 | — |
| 0,05 | HomogF (haut) | 1016 | 0 | 69 | 0,06791 | 0,04990 | 0,149 | 498 / 9988 | 0,258 | 0 | — |
| 0,05 | Courbure (haut) | 1016 | 0 | 59 | 0,05807 | 0,04990 | 1 | 498 / 9988 | 1 | 0 | — |
| 0,05 | Alpha (haut) | 1016 | 0 | 42 | 0,04134 | 0,04990 | 1 | 498 / 9988 | 1 | 0 | — |
| 0,05 | ExpVar (haut) | 1016 | 0 | 40 | 0,03937 | 0,04990 | 1 | 498 / 9988 | 1 | 1 | — |
| 0,05 | KruskalAcc (haut) | 1016 | 0 | 42 | 0,04134 | 0,04989 | 1 | 498 / 9988 | 1 | 0 | — |

**K-V4** : triangles admis de P4 à au moins une p_mc absente : 0 / 1016 (0,0000 ; seuil 0,01). Distribution de π̂ : tableau T7, ligne P4.

### Profils de lecture pour D2, évalués mécaniquement, sans décision

| Élément | Valeur |
| --- | --- |
| K-M4 (contrôles d'intégrité) | rempli |
| non retenus au-delà de 1 % (P1, P2 : refus, échecs, sans intervalle ; P4 : autre motif que M4) | non (P1 0,0000 ; P2 0,0000 ; P4 autre motif 0,0000) |
| classe de I1 à 90 % | P1 distorsion matérielle libérale (sous-couverture) ; P2 distorsion matérielle libérale (sous-couverture) |
| I1 en distorsion de côtés opposés (Ω4) | non |
| I4 compatible ou en écart mineur sur P1 et P2 | non |
| I2 compatible ou en écart mineur sur P1 et P2 | non |
| **Profil Ω (lecture proposée)** | **Ω3** |
| Modificateur V (K-M2, sous Ω1 ou Ω2) | sans objet |
| **Profil Λ (volet A.5 (ii))** | **Λ1** (K-V3 non expliqué : non ; K-V4 rempli : oui ; distorsion matérielle K-V1 : non ; McNemar significatif : non ; clés non tranchées : 0 ; non évaluables : 0) |

Les profils sont des lectures proposées : D2 revient au mainteneur.

Bilan : OK

### Exécution (varie d'une exécution à l'autre)

- Lancement (JOURNAL) : 2026-11-19T19:07:17Z ; fin : 2026-11-19T20:21:31Z
- Processus : 4 ; triangles calculés par cette exécution : 27100, 271 tranche(s), 4347 s d'horloge ; tranches reprises : 0
- Durée cumulée des triangles (somme des processus) : 16649 s ; run_engine() sur la fixture : 15,3 s ; contrôle 7 : 51,7 s ; durée totale : 4456 s

