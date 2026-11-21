## Mesure #610 (S6, étape 4) : couverture à T = 8 des intervalles de σ calibrés par bootstrap imbriqué, méthode Merz-Wüthrich

### Statut épistémique (protocole, par. 3, reproduit tel quel)

**Statut épistémique (à écrire tel quel en tête de la sortie).** La couverture mesurée est un **constat de simulation**. Elle vaut sous le modèle de Mack ajusté au triangle de contrôle (f̂, σ̂² extrapolé compris, première colonne fixée), pour une loi d'erreurs donnée, à T = 8. Elle porte sur la procédure entière à B1 = 999 et B2 = 199, conditionnellement à l'admission (R̂ > 0) et à R\* > 0. Ce n'est pas un résultat général : aucun théorème ne couvre ces intervalles à triangle fixe, et les ordres asymptotiques du double bootstrap (Chang et Hall, 2014) ne fondent rien à T = 8. Erreurs à distinguer :
- l'erreur Monte-Carlo en N, encadrée par Clopper-Pearson ;
- les effets de B1 et B2, inclus dans la procédure mesurée et non isolés (C1-99 et C2-50 en donnent seulement un éclairage) ;
- l'écart au nominal, qui est l'objet mesuré ;
- l'erreur de substitution (plan et loi au lieu de la vérité), non quantifiée.

### T0 — provenance

| Grandeur | Valeur |
| --- | --- |
| Protocole | docs/revues/20261120-s6-trapeze/actuary-2b-protocole-610.md, par. 2 à 5 ; décisions du mainteneur du 20/11/2026 (Q-2b-1 (a), Q-2b-2 (a), Q-2b-3 (a), Q-2b-4, Q-2b-6 (a)) ; md5 032a3948d02f246688b9f09b1c7efe1b |
| Mode ; niveau | mesure ; M1+P3 |
| R par profil (tirés) ; B1 ; B2 ; variantes | P1=1000,P2=1000,P3=500 ; 999 ; 199 ; C1=99,C2=50 |
| Candidats du critère (K-610-1) | C1, C2 |
| Règles de lecture (actuary, 20/11/2026) | Règle 1 (échelle P7) : M1+P3, M1, M3, M4 ; premier niveau dont la durée prévue tient dans 12 h ; sous M1, confirmation du mainteneur requise et aucun lancement implicite (--niveau explicite) ; M4 retire C1 de K-610-1 (décision du mainteneur). Règle 2 (formation) : C1 et C0 si plus de 20 b à n_b > 20 ; C2 si plus de 20 b à n_b > 20 et se*_b fini et > 1e-12, et si se externe est fini et > 1e-12 (sinon C2 non formé et compté) ; C1-99 et C2-50 : mêmes règles sur les 99 et 50 premiers σ**. Règle 3 (W) : C1 : saturation haute Q_w(α) = 0 à 90 % seule (/ triangles où C1 est formé) et b exclues (n_b ≤ 20, / σ* finis cumulés) ; C2 : se*_b dégénérés (/ b à n_b > 20 cumulées) et b exclues ; chaque taux comparé séparément à 0,01, proportion non arrondie sans IC, P1 et P2 séparément ; W-a si tous les taux sont au plus 0,01. Règle 4 (saturations basses) : C1 Q_w(1 − α) = 1, C0 Q_u(α) = 0 : descriptives (K-610-2), séparées de la haute, à 90 % et 95 %, hors W et Θ0. Règle 5 (Θ0) : trois taux distincts, chacun comparé à 0,01 sur P1 et P2 : refus / tirés ; triangles sans intervalle (admis où au moins un de I1, I4, C1, C2 à 90 % n'est pas formé) / admis ; b exclues / σ* finis ; les se*_b dégénérés relèvent de W. Règle 6 (préférence) : (i) calculée mécaniquement sur les estimations ponctuelles des queues (classes sur les valeurs non arrondies) ; (ii) non discriminante : coûts égaux à B2 = 199 ; le script ne désigne aucun candidat préféré. |
| Profils | P1 : reserve2, loi E ; critère principal (K-610-1) ; P2 : reserve2, loi N ; critère principal (K-610-1) ; P3 : reserve2, loi A ; descriptif (K-610-2) |
| Générateur | tests/donnees/triangle_mw.csv (md5 3e9a584da42443f3816fb63deeffa95b) ; R̂ = 9140.84 ; MSEP = 39798 ; σ_A = 0.02182451 ; f̂ = (3.20372 ; 1.65175 ; 1.32525 ; 1.15042 ; 1.09469 ; 1.06455 ; 1.02841) ; pool n = 27, sd_pop = 0.99879 ; colonnes dégénérées : 6 |
| Lois | E : tirage uniforme dans le pool redressé du générateur divisé par son écart-type de population ; N : stats::rnorm ; A : (G − 2)/√2, G ~ Gamma(2) par stats::qgamma(stats::runif(n), 2) |
| Chemin | gen_triangle_h0(aj0, loi) sous engine_sous_graine(G_TRI) ; admettre() ; boucle allégée externe à B1, graine G_EXT ; pour chaque b à σ* fini : boucle allégée appliquée à θ*_b avec .mw_ensembles_figes(θ*_b), à B2, graine G_INT ; b admise si plus de 20 σ** finis |
| Graines | triangle 610 000 000 + 1 000 000 (p − 1) + r ; externe 610 500 000 + 1 000 000 (p − 1) + r ; interne 620 000 000 + 4 000 000 (p − 1) + 1 000 (r − 1) + b ; contrôle 7 : graines de #387 ; disjonction : contrôle 8 |
| Générateur aléatoire | Mersenne-Twister, Inversion, Rejection |
| Cible | σ_A (principale) = σ̂ du triangle de contrôle ; σ_B (descriptive) = √MSEP/R de mw_msep() sur la copie de l'ajustement du triangle simulé à (f, σ²) du générateur (recomposer() de #387) |
| Intervalles | quantiles de type 7 ; I1 [Q*(α) ; Q*(1−α)] ; I4 [σ̂²/Q*(1−α) ; σ̂²/Q*(α)] ; C0 [Q*(Q_u(α)) ; Q*(Q_u(1−α))] ; C1 [σ̂²/Q*(Q_w(1−α)) ; σ̂²/Q*(Q_w(α))] ; C2 [σ̂ exp(−se Q_t(1−α)) ; σ̂ exp(−se Q_t(α))] ; 90 % (α = 0,05) et 95 % (α = 0,025) ; I1, I4 si plus de 20 σ* finis ; C0, C1 si de plus plus de 20 b admises ; C2 si plus de 20 b à se*_b valide |
| SHA, git rev-parse HEAD (début ; fin) | f573ddccf43211e980b0936b37924beeeae834c8 ; f573ddccf43211e980b0936b37924beeeae834c8 |
| Commit (commit_depot(), au début) | f573ddccf43211e980b0936b37924beeeae834c8 |
| md5 R/engine.R (début ; fin) | faf36c545999c147087759155a2bd38a ; faf36c545999c147087759155a2bd38a |
| Empreinte sans commentaires de R/engine.R (#231 ; début ; fin) | 307e07604e7d87b23173f48daebb9383 ; 307e07604e7d87b23173f48daebb9383 |
| Empreintes md5 du code exécuté | R/engine.R faf36c545999c147087759155a2bd38a ; tests/outils_tests.R chargé (dépôt) cdf8f7da242e2c6281fadcb4108aab63 ; script exécuté (dépôt) 725f005af894a4bdb3e54fdf879e9d30 |
| Plateforme de calcul | R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : libblas.so.3.12.0 ; LAPACK : liblapack.so.3.12.0 (version 3.12.0) |
| Locale (LC_CTYPE) | C.UTF-8 → C.UTF-8 |
| Tranches | 125 (taille 20) |
| JOURNAL ; valeurs brutes | 20261120-issue610-couverture-ic-sigma-mw-imbrique-journal-mesure.md ; 20261120-issue610-couverture-ic-sigma-mw-imbrique-brut.tsv (une ligne par triangle tiré, %.17g) |
| Versionnable (--ecrire) | oui |
| Contrôles d'intégrité | OK |

### Aide à la lecture

τ = part des triangles à intervalle formé où la cible est hors de l'intervalle ; IC de Clopper-Pearson à 95 % (qbeta), erreur Monte-Carlo du taux (fonction du nombre de triangles). Les effets de B1 et B2 sont inclus dans la procédure mesurée et non isolés. Couverture conditionnelle à l'admission (M4 : R̂ > 0) et à R* > 0. Classes et profils calculés mécaniquement, sur les valeurs non arrondies, **sans conclure** : la lecture revient à actuary, la décision (D3) au mainteneur.

**Critère et profils du protocole (par. 4), reportés sans modification :**

## 4. Critère et profils, fixés avant toute exécution (à reporter sans modification dans le script et au T0)

> **Critère.** Taux de non-couverture τ de chaque (profil, intervalle, niveau), cible σ_A, comparé au nominal ρ = 0,10 (90 %) ou 0,05 (95 %). Classes de #166, #206, Fk, #305 et #387, bande **fermée** [ρ/2 ; 3ρ/2] : *compatible* (ρ ∈ IC(τ)) ; *écart mineur* (τ̂ dans la bande, sans être compatible) ; *non tranché* (τ̂ hors de la bande, IC qui la recoupe) ; *distorsion matérielle libérale* (IC disjoint de la bande, au-dessus) ; *distorsion matérielle conservatrice* (IC disjoint, au-dessous). IC de Clopper-Pearson à 95 % ; classes sur les valeurs non arrondies ; une estimation sur un bord est dans la bande ; **aucune extension de R après lecture** ; un « non tranché » reste non tranché.
> - **K-610-1** (principal) : classe à 90 % de C1 et de C2 sur P1 et sur P2.
> - **K-610-2** (descriptif) : 95 % ; queues séparées contre ρ/2 (bande [ρ/4 ; 3ρ/4]) ; cible σ_B ; I1 et I4 recalculés, en regard, et comparés aux classes de #387 ; C0, C1-99, C2-50 ; P3 si mesuré ; largeur médiane / σ_A et rapport à la largeur de I1 ; couverture par tiers de σ̂/σ_A ; part de σ_A > max σ\* et > σ̂²/min σ\* (reproduction du § 1.1 sur graines nouvelles) ; saturations de C1 et C0 ; part des bornes de C2 hors de [min σ\* ; max σ\*] ; quantiles de Q_w(α), Q_w(1 − α) et de Q_t.
> - **K-610-3** (intégrité) : contrôles 1 à 11 de P11.
> - **K-610-4** (frontière, descriptif) : l'IC touche-t-il un bord de la bande.
>
> **Profils de lecture pour D3** (`actuary` propose, le mainteneur tranche ; ordre : Θ0, Θ4, Θ1 à Θ3, puis modificateur W) :
>
> | Profil | Condition | Lecture proposée |
> |---|---|---|
> | Θ0 | K-610-3 en défaut ; ou, sur P1 ou P2, refus, triangles sans intervalle ou réplications b exclues au-delà de 1 % | lecture suspendue ; mesure à reprendre |
> | Θ4 | un candidat en distorsion de côtés opposés entre P1 et P2 | décision du mainteneur ; aucune restitution de ce candidat |
> | Θ1 | C1 ou C2 compatible ou en écart mineur sur P1 **et** P2 | **candidat éligible** ; D3 : restitution **en regard du percentile, jamais à sa place** (Q-42-10), textes tranchés à D3. Si les deux sont éligibles, préférence fixée d'avance : (i) celui dont les deux queues à 90 % sont dans [ρ/4 ; 3ρ/4] sur P1 et P2 ; (ii) à égalité, celui de moindre coût par `run_engine()` au pré-vol ; le mainteneur décide en dernier ressort |
> | Θ2 | aucun candidat éligible, au moins un « non tranché » sur P1 ou P2 | constat seul ; aucune restitution par défaut ; note inchangée |
> | Θ3 | C1 et C2 chacun en distorsion matérielle sur au moins un profil principal, sans Θ4 | constat seul ; note inchangée (« aucun intervalle mesuré ne rétablit ce niveau » reste vrai) ; fiche complétée par `docwriter` |
>
> **Modificateur W**, sous Θ1, pour le candidat retenu. W-a : bornes dégénérées, saturations et b exclus au plus 1 % sur P1 et P2 : aucune limite de plus. W-b : au-delà de 1 % : limite écrite dans la fiche, et décision du mainteneur sur la restitution.
>
> **Portée écrite d'avance** : un Θ1 vaut pour le triangle de contrôle sous E et N seulement. Le profil volatil (P4) n'est pas mesuré : la restitution porterait la mention de ce domaine.

### Contrôles d'intégrité (K-610-3 : P11, contrôles 1 à 11)

| Contrôle | Résultat | Détail |
| --- | --- | --- |
| 1 | OK | md5 R/engine.R début faf36c545999c147087759155a2bd38a, fin faf36c545999c147087759155a2bd38a, JOURNAL faf36c545999c147087759155a2bd38a ; SHA début f573ddccf43211e980b0936b37924beeeae834c8, fin f573ddccf43211e980b0936b37924beeeae834c8, JOURNAL f573ddccf43211e980b0936b37924beeeae834c8 ; empreinte #231 début 307e07604e7d87b23173f48daebb9383, fin 307e07604e7d87b23173f48daebb9383, JOURNAL 307e07604e7d87b23173f48daebb9383 ; contexte (B1, B2, variantes, SHA, md5 du moteur et du script, empreinte, empreintes md5 du code exécuté dont tests/outils_tests.R, plateforme) identique dans les 125 tranche(s) : oui |
| 2 | OK | σ_A de P1 à P3 = 0.02182451066 ; reserve2.rds : parametre_final$sigma_estime = 0.02182451066 (écart relatif 0.000e+00) ; TOLERANCE 1e-06 |
| 3 | OK | σ* de la boucle allégée externe identical() à mw_bootstrap(aj_r, B1 = 999, G_EXT)$sigma_boot sur le premier triangle admis de chaque tranche : 125 / 125 tranches |
| 4 | OK | σ** de la boucle interne identical() à mw_bootstrap(θ*_b, B2 = 199, G_INT)$sigma_boot sur la première réplication b admise du premier triangle admis de chaque tranche : 125 / 125 tranches |
| 5 | OK | bornes de C0, C1, C2 (et des variantes) aux deux niveaux recalculées par une écriture indépendante (findInterval() sur les σ** triés, écart-type en clair, type 7 en clair, C1 = exp(2 log σ̂ − log q), C2 = exp(log σ̂ − se q)), seuil 1e-12 relatif : premier triangle de chaque tranche 125 / 125 ; tous les triangles calculés 2500 / 2500 (écart maximal 2.94e-15) ; borne basse ≤ borne haute sur toutes les bornes formées : oui |
| 6 (g) | OK | gen_triangle_h0() (ε tirés par sample(pool)) = mw_simuler_triangle() sous la même graine (identical()) : reserve2 : 100 / 100 identiques ; pool dilaté 30 fois : 100 / 100 identiques, dont 42 triangle(s) à cumul simulé non fini ou ≤ 0 ; mw_simuler_triangle, .mw_simuler_triangle_etat, .mw_tirer_triangle_valide, .mw_triangle_incomplet, .mw_pool_residus, .mw_ensembles_figes, mw_bootstrap, mw_ajuster, mw_msep de l'environnement identiques (formals, body) à celles de R/engine.R relu : oui |
| 7 | OK | graines de #387 (triangle 387000000 + r, bootstrap 387500000 + r ; P1, r = 1 à 20 ; B = 999, boucle allégée) : σ̂, I1 et I4 (90 % et 95 %) contre docs/tableaux/20261119-issue387-couverture-ic-sigma-mw-brut.tsv (md5 499a9d239bc123b6b35c9ce27b3551b8) : écart relatif maximal 0.00e+00 (seuil 1e-12) ; 20 / 20 triangles sous le seuil |
| 8 | OK | plages de la mesure (triangles, externes, internes des 3 profils ; pré-vol ; réserve du trapèze) de 610000001 à 644999999, disjointes entre elles : oui ; pas des sous-plages compatibles (b ≤ 999 < 1000, r ≤ 2000, u ≤ 50) : oui ; disjointes de 2a (#567) 567000000-572000000, #206/#297 MW 20840001-20960000, #297 LN 20260831-20262831, #305 305000000-305939169, #387 387000000-393100000, 360 380 123 360380123-360380123 : oui ; graines du contrôle 7 (#387) hors des plages : oui ; maximum ≤ 2^31 − 1 : oui ; 147 littéraux entiers de 8 à 10 chiffres dans 99 fichiers (R/engine.R, tests/*.R hors ce script, tests/unitaires/*.R ; écriture scientifique non recherchée) ; littéraux L dont [L ; L + 20000] touche une plage : aucun ; littéraux au-dessus des plages : 1073524114, 1138150042, 2146944479, 2147483647, 5864139292, 5888798043, 5904949481, 5904968834, 5904983887, 5904984418, 5905003573, 5905011303, 5905135878, 5927125080, 5927249876, 5927254443, 6021758543, 6058031276, 6058041254, 6060869720, 6062485163, 6120564480, 6170835485, 6172078766, 6172090383, 6261951079, 6541872644, 6588872570 |
| 9 (t610) | OK | par. 4 (critère et profils, 21 lignes) présent à l'identique ; statut épistémique du par. 3 (5 lignes) présent à l'identique, dans docs/revues/20261120-s6-trapeze/actuary-2b-protocole-610.md (md5 032a3948d02f246688b9f09b1c7efe1b) ; vérifié avant tout tirage |
| 10 (m) | OK | aucune occurrence de « couverture_ic_sigma_mw_imbrique » dans R/, app.R et .github/ (18 fichiers lus) ; en défaut : aucun |
| 11 | OK | tirés = admis + refusés + échecs : P1 1000 = 1000 + 0 + 0 ; P2 1000 = 1000 + 0 + 0 ; P3 500 = 500 + 0 + 0 ; b admises + b exclues = σ* finis, exclusions recomptées par deux sources indépendantes de stats_b() (n_b de bornes_independantes() et colSums(!is.na(S2))), sur 2500 / 2500 triangles à bootstrap interne (échecs internes comptés parmi les exclues) |

### T1 — K-610-1 (principal) : classe à 90 % des candidats sur P1 et P2, cible σ_A

| Profil | Intervalle | n | couverture [IC 95 %] | τ̂ [IC CP 95 %] | classe (τ, ρ = 0,10) | K-610-4 : IC touche un bord |
| --- | --- | --- | --- | --- | --- | --- |
| P1 | C1 I4 calibré (candidat) | 1000 | 0,6710 [0,6409 ; 0,7001] | 0,3290 [0,2999 ; 0,3591] | distorsion matérielle libérale (sous-couverture) | non |
| P1 | C2 studentisé log (candidat) | 1000 | 0,6690 [0,6389 ; 0,6981] | 0,3310 [0,3019 ; 0,3611] | distorsion matérielle libérale (sous-couverture) | non |
| P2 | C1 I4 calibré (candidat) | 1000 | 0,7290 [0,7003 ; 0,7563] | 0,2710 [0,2437 ; 0,2997] | distorsion matérielle libérale (sous-couverture) | non |
| P2 | C2 studentisé log (candidat) | 1000 | 0,7190 [0,6900 ; 0,7467] | 0,2810 [0,2533 ; 0,3100] | distorsion matérielle libérale (sous-couverture) | non |

### T2 — couverture par profil, intervalle et niveau, cible σ_A (K-610-1, K-610-2, K-610-4)

Queues séparées : part de σ_A sous la borne basse et au-dessus de la borne haute, classe contre ρ/2 (bande [ρ/4 ; 3ρ/4]). Largeur : médiane de (haute − basse)/σ_A, et médiane du rapport à la largeur de I1 du même triangle.

| Profil | Intervalle | Niveau | n | couverture [IC 95 %] | τ̂ [IC] | classe (τ, ρ) | K-610-4 | sous la borne basse [IC] ; classe (ρ/2) | au-dessus de la borne haute [IC] ; classe (ρ/2) | largeur médiane / σ_A | largeur / largeur de I1 (médiane) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P1 | I1 percentile (référence) | 90 % | 1000 | 0,5910 [0,5598 ; 0,6217] | 0,4090 [0,3783 ; 0,4402] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0037] ; distorsion matérielle conservatrice | 0,4090 [0,3783 ; 0,4402] ; distorsion matérielle libérale (sous-couverture) | 0,5035 | 1,0000 |
| P1 | I1 percentile (référence) | 95 % | 1000 | 0,6390 [0,6084 ; 0,6688] | 0,3610 [0,3312 ; 0,3916] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0037] ; distorsion matérielle conservatrice | 0,3610 [0,3312 ; 0,3916] ; distorsion matérielle libérale (sous-couverture) | 0,5935 | 1,0000 |
| P1 | I4 « basic » log (référence) | 90 % | 1000 | 0,7020 [0,6726 ; 0,7302] | 0,2980 [0,2698 ; 0,3274] | distorsion matérielle libérale (sous-couverture) | non | 0,0140 [0,0077 ; 0,0234] ; distorsion matérielle conservatrice | 0,2840 [0,2562 ; 0,3131] ; distorsion matérielle libérale (sous-couverture) | 0,5633 | 1,1320 |
| P1 | I4 « basic » log (référence) | 95 % | 1000 | 0,8050 [0,7791 ; 0,8291] | 0,1950 [0,1709 ; 0,2209] | distorsion matérielle libérale (sous-couverture) | non | 0,0040 [0,0011 ; 0,0102] ; distorsion matérielle conservatrice | 0,1910 [0,1671 ; 0,2168] ; distorsion matérielle libérale (sous-couverture) | 0,6773 | 1,1570 |
| P1 | C0 percentile calibré (descriptif) | 90 % | 1000 | 0,7040 [0,6746 ; 0,7322] | 0,2960 [0,2678 ; 0,3254] | distorsion matérielle libérale (sous-couverture) | non | 0,0280 [0,0187 ; 0,0402] ; écart mineur | 0,2680 [0,2408 ; 0,2966] ; distorsion matérielle libérale (sous-couverture) | 0,6052 | 1,1109 |
| P1 | C0 percentile calibré (descriptif) | 95 % | 1000 | 0,7890 [0,7624 ; 0,8139] | 0,2110 [0,1861 ; 0,2376] | distorsion matérielle libérale (sous-couverture) | non | 0,0130 [0,0069 ; 0,0221] ; écart mineur | 0,1980 [0,1737 ; 0,2241] ; distorsion matérielle libérale (sous-couverture) | 0,6367 | 1,0487 |
| P1 | C1 I4 calibré (candidat) | 90 % | 1000 | 0,6710 [0,6409 ; 0,7001] | 0,3290 [0,2999 ; 0,3591] | distorsion matérielle libérale (sous-couverture) | non | 0,0360 [0,0253 ; 0,0495] ; écart mineur | 0,2930 [0,2649 ; 0,3223] ; distorsion matérielle libérale (sous-couverture) | 0,6441 | 1,2817 |
| P1 | C1 I4 calibré (candidat) | 95 % | 1000 | 0,7820 [0,7551 ; 0,8072] | 0,2180 [0,1928 ; 0,2449] | distorsion matérielle libérale (sous-couverture) | non | 0,0190 [0,0115 ; 0,0295] ; compatible | 0,1990 [0,1747 ; 0,2251] ; distorsion matérielle libérale (sous-couverture) | 0,7737 | 1,3461 |
| P1 | C2 studentisé log (candidat) | 90 % | 1000 | 0,6690 [0,6389 ; 0,6981] | 0,3310 [0,3019 ; 0,3611] | distorsion matérielle libérale (sous-couverture) | non | 0,0460 [0,0339 ; 0,0609] ; compatible | 0,2850 [0,2572 ; 0,3141] ; distorsion matérielle libérale (sous-couverture) | 0,6356 | 1,2758 |
| P1 | C2 studentisé log (candidat) | 95 % | 1000 | 0,7790 [0,7520 ; 0,8044] | 0,2210 [0,1956 ; 0,2480] | distorsion matérielle libérale (sous-couverture) | non | 0,0260 [0,0171 ; 0,0379] ; compatible | 0,1950 [0,1709 ; 0,2209] ; distorsion matérielle libérale (sous-couverture) | 0,7864 | 1,3451 |
| P1 | C1-99 (descriptif) | 90 % | 1000 | 0,6800 [0,6501 ; 0,7088] | 0,3200 [0,2912 ; 0,3499] | distorsion matérielle libérale (sous-couverture) | non | 0,0370 [0,0262 ; 0,0506] ; compatible | 0,2830 [0,2553 ; 0,3120] ; distorsion matérielle libérale (sous-couverture) | 0,6558 | 1,3178 |
| P1 | C1-99 (descriptif) | 95 % | 1000 | 0,7940 [0,7676 ; 0,8187] | 0,2060 [0,1813 ; 0,2324] | distorsion matérielle libérale (sous-couverture) | non | 0,0170 [0,0099 ; 0,0271] ; compatible | 0,1890 [0,1652 ; 0,2147] ; distorsion matérielle libérale (sous-couverture) | 0,8338 | 1,4282 |
| P1 | C2-50 (descriptif) | 90 % | 1000 | 0,6730 [0,6429 ; 0,7020] | 0,3270 [0,2980 ; 0,3571] | distorsion matérielle libérale (sous-couverture) | non | 0,0440 [0,0321 ; 0,0586] ; compatible | 0,2830 [0,2553 ; 0,3120] ; distorsion matérielle libérale (sous-couverture) | 0,6492 | 1,3103 |
| P1 | C2-50 (descriptif) | 95 % | 1000 | 0,7860 [0,7593 ; 0,8110] | 0,2140 [0,1890 ; 0,2407] | distorsion matérielle libérale (sous-couverture) | non | 0,0250 [0,0162 ; 0,0367] ; compatible | 0,1890 [0,1652 ; 0,2147] ; distorsion matérielle libérale (sous-couverture) | 0,8079 | 1,3855 |
| P2 | I1 percentile (référence) | 90 % | 1000 | 0,6000 [0,5689 ; 0,6305] | 0,4000 [0,3695 ; 0,4311] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0037] ; distorsion matérielle conservatrice | 0,4000 [0,3695 ; 0,4311] ; distorsion matérielle libérale (sous-couverture) | 0,4962 | 1,0000 |
| P2 | I1 percentile (référence) | 95 % | 1000 | 0,6640 [0,6338 ; 0,6933] | 0,3360 [0,3067 ; 0,3662] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0037] ; distorsion matérielle conservatrice | 0,3360 [0,3067 ; 0,3662] ; distorsion matérielle libérale (sous-couverture) | 0,5913 | 1,0000 |
| P2 | I4 « basic » log (référence) | 90 % | 1000 | 0,7180 [0,6890 ; 0,7457] | 0,2820 [0,2543 ; 0,3110] | distorsion matérielle libérale (sous-couverture) | non | 0,0250 [0,0162 ; 0,0367] ; écart mineur | 0,2570 [0,2302 ; 0,2853] ; distorsion matérielle libérale (sous-couverture) | 0,5652 | 1,1375 |
| P2 | I4 « basic » log (référence) | 95 % | 1000 | 0,7990 [0,7728 ; 0,8234] | 0,2010 [0,1766 ; 0,2272] | distorsion matérielle libérale (sous-couverture) | non | 0,0110 [0,0055 ; 0,0196] ; non tranché | 0,1900 [0,1661 ; 0,2157] ; distorsion matérielle libérale (sous-couverture) | 0,6838 | 1,1636 |
| P2 | C0 percentile calibré (descriptif) | 90 % | 1000 | 0,7390 [0,7106 ; 0,7660] | 0,2610 [0,2340 ; 0,2894] | distorsion matérielle libérale (sous-couverture) | non | 0,0480 [0,0356 ; 0,0631] ; compatible | 0,2130 [0,1880 ; 0,2397] ; distorsion matérielle libérale (sous-couverture) | 0,6144 | 1,1758 |
| P2 | C0 percentile calibré (descriptif) | 95 % | 1000 | 0,7830 [0,7561 ; 0,8082] | 0,2170 [0,1918 ; 0,2439] | distorsion matérielle libérale (sous-couverture) | non | 0,0290 [0,0195 ; 0,0414] ; compatible | 0,1880 [0,1642 ; 0,2136] ; distorsion matérielle libérale (sous-couverture) | 0,6470 | 1,0857 |
| P2 | C1 I4 calibré (candidat) | 90 % | 1000 | 0,7290 [0,7003 ; 0,7563] | 0,2710 [0,2437 ; 0,2997] | distorsion matérielle libérale (sous-couverture) | non | 0,0440 [0,0321 ; 0,0586] ; compatible | 0,2270 [0,2014 ; 0,2542] ; distorsion matérielle libérale (sous-couverture) | 0,6623 | 1,3293 |
| P2 | C1 I4 calibré (candidat) | 95 % | 1000 | 0,8040 [0,7780 ; 0,8282] | 0,1960 [0,1718 ; 0,2220] | distorsion matérielle libérale (sous-couverture) | non | 0,0270 [0,0179 ; 0,0390] ; compatible | 0,1690 [0,1463 ; 0,1937] ; distorsion matérielle libérale (sous-couverture) | 0,8199 | 1,3811 |
| P2 | C2 studentisé log (candidat) | 90 % | 1000 | 0,7190 [0,6900 ; 0,7467] | 0,2810 [0,2533 ; 0,3100] | distorsion matérielle libérale (sous-couverture) | non | 0,0550 [0,0417 ; 0,0710] ; compatible | 0,2260 [0,2004 ; 0,2532] ; distorsion matérielle libérale (sous-couverture) | 0,6548 | 1,3301 |
| P2 | C2 studentisé log (candidat) | 95 % | 1000 | 0,7980 [0,7718 ; 0,8225] | 0,2020 [0,1775 ; 0,2282] | distorsion matérielle libérale (sous-couverture) | non | 0,0370 [0,0262 ; 0,0506] ; écart mineur | 0,1650 [0,1425 ; 0,1895] ; distorsion matérielle libérale (sous-couverture) | 0,8175 | 1,3948 |
| P2 | C1-99 (descriptif) | 90 % | 1000 | 0,7310 [0,7024 ; 0,7583] | 0,2690 [0,2417 ; 0,2976] | distorsion matérielle libérale (sous-couverture) | non | 0,0450 [0,0330 ; 0,0598] ; compatible | 0,2240 [0,1985 ; 0,2511] ; distorsion matérielle libérale (sous-couverture) | 0,6783 | 1,3582 |
| P2 | C1-99 (descriptif) | 95 % | 1000 | 0,8140 [0,7885 ; 0,8377] | 0,1860 [0,1623 ; 0,2115] | distorsion matérielle libérale (sous-couverture) | non | 0,0250 [0,0162 ; 0,0367] ; compatible | 0,1610 [0,1387 ; 0,1853] ; distorsion matérielle libérale (sous-couverture) | 0,9407 | 1,5276 |
| P2 | C2-50 (descriptif) | 90 % | 1000 | 0,7290 [0,7003 ; 0,7563] | 0,2710 [0,2437 ; 0,2997] | distorsion matérielle libérale (sous-couverture) | non | 0,0530 [0,0399 ; 0,0688] ; compatible | 0,2180 [0,1928 ; 0,2449] ; distorsion matérielle libérale (sous-couverture) | 0,6726 | 1,3544 |
| P2 | C2-50 (descriptif) | 95 % | 1000 | 0,8060 [0,7801 ; 0,8301] | 0,1940 [0,1699 ; 0,2199] | distorsion matérielle libérale (sous-couverture) | non | 0,0360 [0,0253 ; 0,0495] ; écart mineur | 0,1580 [0,1359 ; 0,1821] ; distorsion matérielle libérale (sous-couverture) | 0,8400 | 1,4249 |
| P3 | I1 percentile (référence) | 90 % | 500 | 0,5260 [0,4812 ; 0,5705] | 0,4740 [0,4295 ; 0,5188] | distorsion matérielle libérale (sous-couverture) | non | 0,0020 [0,0001 ; 0,0111] ; distorsion matérielle conservatrice | 0,4720 [0,4275 ; 0,5168] ; distorsion matérielle libérale (sous-couverture) | 0,4889 | 1,0000 |
| P3 | I1 percentile (référence) | 95 % | 500 | 0,5840 [0,5394 ; 0,6276] | 0,4160 [0,3724 ; 0,4606] | distorsion matérielle libérale (sous-couverture) | non | 0,0000 [0,0000 ; 0,0074] ; distorsion matérielle conservatrice | 0,4160 [0,3724 ; 0,4606] ; distorsion matérielle libérale (sous-couverture) | 0,5713 | 1,0000 |
| P3 | I4 « basic » log (référence) | 90 % | 500 | 0,6820 [0,6392 ; 0,7226] | 0,3180 [0,2774 ; 0,3608] | distorsion matérielle libérale (sous-couverture) | non | 0,0160 [0,0069 ; 0,0313] ; non tranché | 0,3020 [0,2620 ; 0,3443] ; distorsion matérielle libérale (sous-couverture) | 0,5648 | 1,1591 |
| P3 | I4 « basic » log (référence) | 95 % | 500 | 0,7520 [0,7117 ; 0,7893] | 0,2480 [0,2107 ; 0,2883] | distorsion matérielle libérale (sous-couverture) | non | 0,0100 [0,0033 ; 0,0232] ; non tranché | 0,2380 [0,2013 ; 0,2778] ; distorsion matérielle libérale (sous-couverture) | 0,6823 | 1,1962 |
| P3 | C0 percentile calibré (descriptif) | 90 % | 500 | 0,6920 [0,6495 ; 0,7322] | 0,3080 [0,2678 ; 0,3505] | distorsion matérielle libérale (sous-couverture) | non | 0,0220 [0,0110 ; 0,0390] ; non tranché | 0,2860 [0,2468 ; 0,3278] ; distorsion matérielle libérale (sous-couverture) | 0,5871 | 1,1665 |
| P3 | C0 percentile calibré (descriptif) | 95 % | 500 | 0,7300 [0,6888 ; 0,7685] | 0,2700 [0,2315 ; 0,3112] | distorsion matérielle libérale (sous-couverture) | non | 0,0140 [0,0056 ; 0,0286] ; compatible | 0,2560 [0,2183 ; 0,2966] ; distorsion matérielle libérale (sous-couverture) | 0,6195 | 1,0660 |
| P3 | C1 I4 calibré (candidat) | 90 % | 500 | 0,7100 [0,6681 ; 0,7494] | 0,2900 [0,2506 ; 0,3319] | distorsion matérielle libérale (sous-couverture) | non | 0,0300 [0,0169 ; 0,0490] ; écart mineur | 0,2600 [0,2221 ; 0,3008] ; distorsion matérielle libérale (sous-couverture) | 0,6738 | 1,3977 |
| P3 | C1 I4 calibré (candidat) | 95 % | 500 | 0,7960 [0,7580 ; 0,8305] | 0,2040 [0,1695 ; 0,2420] | distorsion matérielle libérale (sous-couverture) | non | 0,0160 [0,0069 ; 0,0313] ; compatible | 0,1880 [0,1547 ; 0,2251] ; distorsion matérielle libérale (sous-couverture) | 0,8719 | 1,4831 |
| P3 | C2 studentisé log (candidat) | 90 % | 500 | 0,6900 [0,6474 ; 0,7303] | 0,3100 [0,2697 ; 0,3526] | distorsion matérielle libérale (sous-couverture) | non | 0,0320 [0,0184 ; 0,0514] ; compatible | 0,2780 [0,2391 ; 0,3195] ; distorsion matérielle libérale (sous-couverture) | 0,6663 | 1,3822 |
| P3 | C2 studentisé log (candidat) | 95 % | 500 | 0,7940 [0,7559 ; 0,8286] | 0,2060 [0,1714 ; 0,2441] | distorsion matérielle libérale (sous-couverture) | non | 0,0200 [0,0096 ; 0,0365] ; compatible | 0,1860 [0,1528 ; 0,2229] ; distorsion matérielle libérale (sous-couverture) | 0,8344 | 1,4825 |
| P3 | C1-99 (descriptif) | 90 % | 500 | 0,7120 [0,6701 ; 0,7513] | 0,2880 [0,2487 ; 0,3299] | distorsion matérielle libérale (sous-couverture) | non | 0,0320 [0,0184 ; 0,0514] ; compatible | 0,2560 [0,2183 ; 0,2966] ; distorsion matérielle libérale (sous-couverture) | 0,7140 | 1,4358 |
| P3 | C1-99 (descriptif) | 95 % | 500 | 0,8160 [0,7792 ; 0,8490] | 0,1840 [0,1510 ; 0,2208] | distorsion matérielle libérale (sous-couverture) | non | 0,0140 [0,0056 ; 0,0286] ; compatible | 0,1700 [0,1381 ; 0,2059] ; distorsion matérielle libérale (sous-couverture) | 0,9516 | 1,6213 |
| P3 | C2-50 (descriptif) | 90 % | 500 | 0,7040 [0,6619 ; 0,7437] | 0,2960 [0,2563 ; 0,3381] | distorsion matérielle libérale (sous-couverture) | non | 0,0340 [0,0199 ; 0,0539] ; compatible | 0,2620 [0,2240 ; 0,3029] ; distorsion matérielle libérale (sous-couverture) | 0,6845 | 1,4173 |
| P3 | C2-50 (descriptif) | 95 % | 500 | 0,8020 [0,7643 ; 0,8361] | 0,1980 [0,1639 ; 0,2357] | distorsion matérielle libérale (sous-couverture) | non | 0,0200 [0,0096 ; 0,0365] ; compatible | 0,1780 [0,1455 ; 0,2144] ; distorsion matérielle libérale (sous-couverture) | 0,8663 | 1,5090 |

### T3 — I1 et I4 recalculés sur les graines nouvelles, en regard des classes de #387 (90 %, cible σ_A, K-610-2)

Classes de #387 recalculées par ce script sur docs/tableaux/20261119-issue387-couverture-ic-sigma-mw-brut.tsv (lignes ok), avec la même fonction classer().

| Profil | Intervalle | #610 : τ̂ [IC] ; classe | #387 : τ̂ [IC] ; classe |
| --- | --- | --- | --- |
| P1 | I1 percentile (référence) | 0,4090 [0,3783 ; 0,4402] ; distorsion matérielle libérale (sous-couverture) | 0,4270 [0,4052 ; 0,4490] ; distorsion matérielle libérale (sous-couverture) |
| P1 | I4 « basic » log (référence) | 0,2980 [0,2698 ; 0,3274] ; distorsion matérielle libérale (sous-couverture) | 0,3085 [0,2883 ; 0,3293] ; distorsion matérielle libérale (sous-couverture) |
| P2 | I1 percentile (référence) | 0,4000 [0,3695 ; 0,4311] ; distorsion matérielle libérale (sous-couverture) | 0,3830 [0,3616 ; 0,4047] ; distorsion matérielle libérale (sous-couverture) |
| P2 | I4 « basic » log (référence) | 0,2820 [0,2543 ; 0,3110] ; distorsion matérielle libérale (sous-couverture) | 0,2675 [0,2482 ; 0,2875] ; distorsion matérielle libérale (sous-couverture) |

### T4 — couverture de σ_B (cible descriptive, K-610-2)

| Profil | Intervalle | Niveau | n | couverture de σ_B [IC 95 %] | τ̂ [IC] | classe (τ, ρ), descriptive | σ_B non défini |
| --- | --- | --- | --- | --- | --- | --- | --- |
| P1 | I1 percentile (référence) | 90 % | 1000 | 0,6070 [0,5759 ; 0,6374] | 0,3930 [0,3626 ; 0,4241] | distorsion matérielle libérale (sous-couverture) | 0 |
| P1 | I1 percentile (référence) | 95 % | 1000 | 0,6570 [0,6266 ; 0,6864] | 0,3430 [0,3136 ; 0,3734] | distorsion matérielle libérale (sous-couverture) | 0 |
| P1 | I4 « basic » log (référence) | 90 % | 1000 | 0,7200 [0,6911 ; 0,7476] | 0,2800 [0,2524 ; 0,3089] | distorsion matérielle libérale (sous-couverture) | 0 |
| P1 | I4 « basic » log (référence) | 95 % | 1000 | 0,8230 [0,7979 ; 0,8462] | 0,1770 [0,1538 ; 0,2021] | distorsion matérielle libérale (sous-couverture) | 0 |
| P1 | C0 percentile calibré (descriptif) | 90 % | 1000 | 0,7100 [0,6808 ; 0,7380] | 0,2900 [0,2620 ; 0,3192] | distorsion matérielle libérale (sous-couverture) | 0 |
| P1 | C0 percentile calibré (descriptif) | 95 % | 1000 | 0,8040 [0,7780 ; 0,8282] | 0,1960 [0,1718 ; 0,2220] | distorsion matérielle libérale (sous-couverture) | 0 |
| P1 | C1 I4 calibré (candidat) | 90 % | 1000 | 0,6790 [0,6491 ; 0,7079] | 0,3210 [0,2921 ; 0,3509] | distorsion matérielle libérale (sous-couverture) | 0 |
| P1 | C1 I4 calibré (candidat) | 95 % | 1000 | 0,7990 [0,7728 ; 0,8234] | 0,2010 [0,1766 ; 0,2272] | distorsion matérielle libérale (sous-couverture) | 0 |
| P1 | C2 studentisé log (candidat) | 90 % | 1000 | 0,6720 [0,6419 ; 0,7011] | 0,3280 [0,2989 ; 0,3581] | distorsion matérielle libérale (sous-couverture) | 0 |
| P1 | C2 studentisé log (candidat) | 95 % | 1000 | 0,7890 [0,7624 ; 0,8139] | 0,2110 [0,1861 ; 0,2376] | distorsion matérielle libérale (sous-couverture) | 0 |
| P1 | C1-99 (descriptif) | 90 % | 1000 | 0,6800 [0,6501 ; 0,7088] | 0,3200 [0,2912 ; 0,3499] | distorsion matérielle libérale (sous-couverture) | 0 |
| P1 | C1-99 (descriptif) | 95 % | 1000 | 0,8090 [0,7832 ; 0,8329] | 0,1910 [0,1671 ; 0,2168] | distorsion matérielle libérale (sous-couverture) | 0 |
| P1 | C2-50 (descriptif) | 90 % | 1000 | 0,6790 [0,6491 ; 0,7079] | 0,3210 [0,2921 ; 0,3509] | distorsion matérielle libérale (sous-couverture) | 0 |
| P1 | C2-50 (descriptif) | 95 % | 1000 | 0,7980 [0,7718 ; 0,8225] | 0,2020 [0,1775 ; 0,2282] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | I1 percentile (référence) | 90 % | 1000 | 0,6150 [0,5840 ; 0,6453] | 0,3850 [0,3547 ; 0,4160] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | I1 percentile (référence) | 95 % | 1000 | 0,6830 [0,6532 ; 0,7118] | 0,3170 [0,2882 ; 0,3468] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | I4 « basic » log (référence) | 90 % | 1000 | 0,7310 [0,7024 ; 0,7583] | 0,2690 [0,2417 ; 0,2976] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | I4 « basic » log (référence) | 95 % | 1000 | 0,8060 [0,7801 ; 0,8301] | 0,1940 [0,1699 ; 0,2199] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | C0 percentile calibré (descriptif) | 90 % | 1000 | 0,7380 [0,7096 ; 0,7650] | 0,2620 [0,2350 ; 0,2904] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | C0 percentile calibré (descriptif) | 95 % | 1000 | 0,7870 [0,7603 ; 0,8120] | 0,2130 [0,1880 ; 0,2397] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | C1 I4 calibré (candidat) | 90 % | 1000 | 0,7280 [0,6993 ; 0,7554] | 0,2720 [0,2446 ; 0,3007] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | C1 I4 calibré (candidat) | 95 % | 1000 | 0,8060 [0,7801 ; 0,8301] | 0,1940 [0,1699 ; 0,2199] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | C2 studentisé log (candidat) | 90 % | 1000 | 0,7280 [0,6993 ; 0,7554] | 0,2720 [0,2446 ; 0,3007] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | C2 studentisé log (candidat) | 95 % | 1000 | 0,8010 [0,7749 ; 0,8253] | 0,1990 [0,1747 ; 0,2251] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | C1-99 (descriptif) | 90 % | 1000 | 0,7360 [0,7075 ; 0,7631] | 0,2640 [0,2369 ; 0,2925] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | C1-99 (descriptif) | 95 % | 1000 | 0,8220 [0,7969 ; 0,8452] | 0,1780 [0,1548 ; 0,2031] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | C2-50 (descriptif) | 90 % | 1000 | 0,7360 [0,7075 ; 0,7631] | 0,2640 [0,2369 ; 0,2925] | distorsion matérielle libérale (sous-couverture) | 0 |
| P2 | C2-50 (descriptif) | 95 % | 1000 | 0,8050 [0,7791 ; 0,8291] | 0,1950 [0,1709 ; 0,2209] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | I1 percentile (référence) | 90 % | 500 | 0,5440 [0,4992 ; 0,5883] | 0,4560 [0,4117 ; 0,5008] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | I1 percentile (référence) | 95 % | 500 | 0,5980 [0,5535 ; 0,6413] | 0,4020 [0,3587 ; 0,4465] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | I4 « basic » log (référence) | 90 % | 500 | 0,6820 [0,6392 ; 0,7226] | 0,3180 [0,2774 ; 0,3608] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | I4 « basic » log (référence) | 95 % | 500 | 0,7640 [0,7243 ; 0,8006] | 0,2360 [0,1994 ; 0,2757] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | C0 percentile calibré (descriptif) | 90 % | 500 | 0,6900 [0,6474 ; 0,7303] | 0,3100 [0,2697 ; 0,3526] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | C0 percentile calibré (descriptif) | 95 % | 500 | 0,7320 [0,6909 ; 0,7704] | 0,2680 [0,2296 ; 0,3091] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | C1 I4 calibré (candidat) | 90 % | 500 | 0,7160 [0,6743 ; 0,7551] | 0,2840 [0,2449 ; 0,3257] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | C1 I4 calibré (candidat) | 95 % | 500 | 0,8100 [0,7728 ; 0,8435] | 0,1900 [0,1565 ; 0,2272] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | C2 studentisé log (candidat) | 90 % | 500 | 0,7000 [0,6577 ; 0,7399] | 0,3000 [0,2601 ; 0,3423] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | C2 studentisé log (candidat) | 95 % | 500 | 0,8100 [0,7728 ; 0,8435] | 0,1900 [0,1565 ; 0,2272] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | C1-99 (descriptif) | 90 % | 500 | 0,7180 [0,6763 ; 0,7571] | 0,2820 [0,2429 ; 0,3237] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | C1-99 (descriptif) | 95 % | 500 | 0,8240 [0,7877 ; 0,8564] | 0,1760 [0,1436 ; 0,2123] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | C2-50 (descriptif) | 90 % | 500 | 0,7140 [0,6722 ; 0,7532] | 0,2860 [0,2468 ; 0,3278] | distorsion matérielle libérale (sous-couverture) | 0 |
| P3 | C2-50 (descriptif) | 95 % | 500 | 0,8120 [0,7749 ; 0,8453] | 0,1880 [0,1547 ; 0,2251] | distorsion matérielle libérale (sous-couverture) | 0 |

### T5 — couverture à 90 % par tiers de σ̂/σ_A (K-610-2, descriptif ; bornes des tiers : quantiles de type 7 à 1/3 et 2/3 de σ̂/σ_A sur les triangles à I1 formé du profil)

| Profil | Intervalle | tiers 1 : n ; couverture [IC] | tiers 2 : n ; couverture [IC] | tiers 3 : n ; couverture [IC] |
| --- | --- | --- | --- | --- |
P1 : bornes des tiers 0,7652 et 0,9747.
| P1 | I1 percentile (référence) | 334 ; 0,0449 [0,0254 ; 0,0730] | 333 ; 0,7297 [0,6786 ; 0,7767] | 333 ; 1,0000 [0,9890 ; 1,0000] |
| P1 | I4 « basic » log (référence) | 334 ; 0,1826 [0,1427 ; 0,2283] | 333 ; 0,9670 [0,9417 ; 0,9834] | 333 ; 0,9580 [0,9305 ; 0,9768] |
| P1 | C0 percentile calibré (descriptif) | 334 ; 0,2784 [0,2310 ; 0,3298] | 333 ; 0,9189 [0,8842 ; 0,9459] | 333 ; 0,9159 [0,8808 ; 0,9434] |
| P1 | C1 I4 calibré (candidat) | 334 ; 0,2275 [0,1837 ; 0,2763] | 333 ; 0,8949 [0,8569 ; 0,9257] | 333 ; 0,8919 [0,8535 ; 0,9231] |
| P1 | C2 studentisé log (candidat) | 334 ; 0,2395 [0,1947 ; 0,2890] | 333 ; 0,9069 [0,8705 ; 0,9359] | 333 ; 0,8619 [0,8201 ; 0,8971] |
| P1 | C1-99 (descriptif) | 334 ; 0,2455 [0,2003 ; 0,2953] | 333 ; 0,9069 [0,8705 ; 0,9359] | 333 ; 0,8889 [0,8501 ; 0,9206] |
| P1 | C2-50 (descriptif) | 334 ; 0,2485 [0,2031 ; 0,2985] | 333 ; 0,9039 [0,8671 ; 0,9333] | 333 ; 0,8679 [0,8267 ; 0,9023] |
P2 : bornes des tiers 0,7607 et 0,9402.
| P2 | I1 percentile (référence) | 334 ; 0,0479 [0,0276 ; 0,0766] | 333 ; 0,7538 [0,7038 ; 0,7991] | 333 ; 1,0000 [0,9890 ; 1,0000] |
| P2 | I4 « basic » log (référence) | 334 ; 0,2575 [0,2114 ; 0,3079] | 333 ; 0,9730 [0,9493 ; 0,9876] | 333 ; 0,9249 [0,8912 ; 0,9508] |
| P2 | C0 percentile calibré (descriptif) | 334 ; 0,3892 [0,3366 ; 0,4438] | 333 ; 0,9730 [0,9493 ; 0,9876] | 333 ; 0,8559 [0,8135 ; 0,8918] |
| P2 | C1 I4 calibré (candidat) | 334 ; 0,3623 [0,3107 ; 0,4164] | 333 ; 0,9580 [0,9305 ; 0,9768] | 333 ; 0,8679 [0,8267 ; 0,9023] |
| P2 | C2 studentisé log (candidat) | 334 ; 0,3683 [0,3164 ; 0,4225] | 333 ; 0,9550 [0,9268 ; 0,9746] | 333 ; 0,8348 [0,7905 ; 0,8731] |
| P2 | C1-99 (descriptif) | 334 ; 0,3743 [0,3222 ; 0,4286] | 333 ; 0,9550 [0,9268 ; 0,9746] | 333 ; 0,8649 [0,8234 ; 0,8997] |
| P2 | C2-50 (descriptif) | 334 ; 0,3862 [0,3337 ; 0,4408] | 333 ; 0,9610 [0,9342 ; 0,9791] | 333 ; 0,8408 [0,7970 ; 0,8784] |
P3 : bornes des tiers 0,7137 et 0,9064.
| P3 | I1 percentile (référence) | 167 ; 0,0060 [0,0002 ; 0,0329] | 166 ; 0,5783 [0,4993 ; 0,6544] | 167 ; 0,9940 [0,9671 ; 0,9998] |
| P3 | I4 « basic » log (référence) | 167 ; 0,1617 [0,1093 ; 0,2264] | 166 ; 0,9337 [0,8845 ; 0,9665] | 167 ; 0,9521 [0,9078 ; 0,9791] |
| P3 | C0 percentile calibré (descriptif) | 167 ; 0,2275 [0,1663 ; 0,2987] | 166 ; 0,9157 [0,8625 ; 0,9531] | 167 ; 0,9341 [0,8852 ; 0,9667] |
| P3 | C1 I4 calibré (candidat) | 167 ; 0,2874 [0,2201 ; 0,3624] | 166 ; 0,9337 [0,8845 ; 0,9665] | 167 ; 0,9102 [0,8562 ; 0,9489] |
| P3 | C2 studentisé log (candidat) | 167 ; 0,2515 [0,1877 ; 0,3244] | 166 ; 0,9157 [0,8625 ; 0,9531] | 167 ; 0,9042 [0,8491 ; 0,9442] |
| P3 | C1-99 (descriptif) | 167 ; 0,2994 [0,2311 ; 0,3750] | 166 ; 0,9337 [0,8845 ; 0,9665] | 167 ; 0,9042 [0,8491 ; 0,9442] |
| P3 | C2-50 (descriptif) | 167 ; 0,2754 [0,2093 ; 0,3498] | 166 ; 0,9398 [0,8920 ; 0,9707] | 167 ; 0,8982 [0,8420 ; 0,9396] |

### T6 — reproduction du § 1.1 sur graines nouvelles, saturations, bornes de C2 hors de [min σ* ; max σ*], niveaux calibrés (K-610-2)

| Grandeur | P1 | P2 | P3 |
| --- | --- | --- | --- |
| σ_A > max σ* (triangles à I1) | 187 / 1000 = 0,1870 [0,1633 ; 0,2126] | 181 / 1000 = 0,1810 [0,1576 ; 0,2063] | 127 / 500 = 0,2540 [0,2164 ; 0,2945] |
| σ_A < min σ* | 0 / 1000 = 0,0000 [0,0000 ; 0,0037] | 0 / 1000 = 0,0000 [0,0000 ; 0,0037] | 0 / 500 = 0,0000 [0,0000 ; 0,0074] |
| σ_A > σ̂²/min σ* (plafond de I4 et de C1) | 12 / 1000 = 0,0120 [0,0062 ; 0,0209] | 29 / 1000 = 0,0290 [0,0195 ; 0,0414] | 31 / 500 = 0,0620 [0,0425 ; 0,0869] |
| saturation de C1, borne haute, 90 % | 293 / 1000 = 0,2930 [0,2649 ; 0,3223] | 238 / 1000 = 0,2380 [0,2119 ; 0,2656] | 99 / 500 = 0,1980 [0,1639 ; 0,2357] |
| saturation de C1, borne basse, 90 % | 0 / 1000 = 0,0000 [0,0000 ; 0,0037] | 0 / 1000 = 0,0000 [0,0000 ; 0,0037] | 0 / 500 = 0,0000 [0,0000 ; 0,0074] |
| saturation de C0, borne haute, 90 % | 670 / 1000 = 0,6700 [0,6399 ; 0,6991] | 758 / 1000 = 0,7580 [0,7302 ; 0,7843] | 407 / 500 = 0,8140 [0,7771 ; 0,8472] |
| saturation de C0, borne basse, 90 % | 0 / 1000 = 0,0000 [0,0000 ; 0,0037] | 0 / 1000 = 0,0000 [0,0000 ; 0,0037] | 0 / 500 = 0,0000 [0,0000 ; 0,0074] |
| saturation de C1-r, borne haute, 90 % | 371 / 1000 = 0,3710 [0,3410 ; 0,4018] | 333 / 1000 = 0,3330 [0,3038 ; 0,3632] | 148 / 500 = 0,2960 [0,2563 ; 0,3381] |
| saturation de C1-r, borne basse, 90 % | 0 / 1000 = 0,0000 [0,0000 ; 0,0037] | 0 / 1000 = 0,0000 [0,0000 ; 0,0037] | 0 / 500 = 0,0000 [0,0000 ; 0,0074] |
| saturation de C1, borne haute, 95 % | 397 / 1000 = 0,3970 [0,3665 ; 0,4281] | 377 / 1000 = 0,3770 [0,3469 ; 0,4079] | 185 / 500 = 0,3700 [0,3276 ; 0,4140] |
| saturation de C1, borne basse, 95 % | 1 / 1000 = 0,0010 [0,0000 ; 0,0056] | 2 / 1000 = 0,0020 [0,0002 ; 0,0072] | 3 / 500 = 0,0060 [0,0012 ; 0,0174] |
| saturation de C0, borne haute, 95 % | 924 / 1000 = 0,9240 [0,9058 ; 0,9397] | 974 / 1000 = 0,9740 [0,9621 ; 0,9829] | 489 / 500 = 0,9780 [0,9610 ; 0,9890] |
| saturation de C0, borne basse, 95 % | 0 / 1000 = 0,0000 [0,0000 ; 0,0037] | 0 / 1000 = 0,0000 [0,0000 ; 0,0037] | 0 / 500 = 0,0000 [0,0000 ; 0,0074] |
| saturation de C1-r, borne haute, 95 % | 485 / 1000 = 0,4850 [0,4536 ; 0,5165] | 520 / 1000 = 0,5200 [0,4885 ; 0,5514] | 274 / 500 = 0,5480 [0,5032 ; 0,5922] |
| saturation de C1-r, borne basse, 95 % | 9 / 1000 = 0,0090 [0,0041 ; 0,0170] | 14 / 1000 = 0,0140 [0,0077 ; 0,0234] | 14 / 500 = 0,0280 [0,0154 ; 0,0465] |
| bornes de C2 hors de [min σ* ; max σ*], 90 % : basse < min ; haute > max | 0 ; 534 (n = 1000) | 0 ; 547 (n = 1000) | 0 ; 336 (n = 500) |
| bornes de C2-r hors de [min σ* ; max σ*], 90 % : basse < min ; haute > max | 0 ; 549 (n = 1000) | 0 ; 567 (n = 1000) | 0 ; 340 (n = 500) |
| bornes de C2 hors de [min σ* ; max σ*], 95 % : basse < min ; haute > max | 0 ; 701 (n = 1000) | 0 ; 748 (n = 1000) | 0 ; 422 (n = 500) |
| bornes de C2-r hors de [min σ* ; max σ*], 95 % : basse < min ; haute > max | 0 ; 725 (n = 1000) | 0 ; 776 (n = 1000) | 0 ; 430 (n = 500) |
| Q_w(0,025), quantiles 5 / 50 / 95 % entre triangles | 0,0000 ; 0,0101 ; 0,0500 | 0,0000 ; 0,0050 ; 0,0352 | 0,0000 ; 0,0050 ; 0,0349 |
| Q_t(0,025), quantiles 5 / 50 / 95 % entre triangles | -5,1798 ; -2,9101 ; -1,9164 | -5,3239 ; -2,9989 ; -2,0876 | -5,6533 ; -3,0582 ; -2,1490 |
| Q_u(0,025), quantiles 5 / 50 / 95 % entre triangles | 0,0804 ; 0,2211 ; 0,4274 | 0,0799 ; 0,1907 ; 0,4121 | 0,0804 ; 0,1658 ; 0,3920 |
| Q_w(0,05), quantiles 5 / 50 / 95 % entre triangles | 0,0000 ; 0,0201 ; 0,0854 | 0,0000 ; 0,0201 ; 0,0698 | 0,0000 ; 0,0196 ; 0,0653 |
| Q_t(0,05), quantiles 5 / 50 / 95 % entre triangles | -4,6340 ; -2,4098 ; -1,5333 | -4,6318 ; -2,4857 ; -1,7071 | -4,9067 ; -2,5428 ; -1,7343 |
| Q_u(0,05), quantiles 5 / 50 / 95 % entre triangles | 0,1156 ; 0,2809 ; 0,4673 | 0,1151 ; 0,2407 ; 0,4573 | 0,1148 ; 0,2156 ; 0,4322 |
| Q_w(0,95), quantiles 5 / 50 / 95 % entre triangles | 0,8749 ; 0,9196 ; 0,9698 | 0,8849 ; 0,9251 ; 0,9698 | 0,8894 ; 0,9324 ; 0,9698 |
| Q_t(0,95), quantiles 5 / 50 / 95 % entre triangles | 0,7094 ; 0,9733 ; 1,3336 | 0,7252 ; 1,0211 ; 1,3545 | 0,7717 ; 1,0460 ; 1,3696 |
| Q_u(0,95), quantiles 5 / 50 / 95 % entre triangles | 0,9749 ; 1,0000 ; 1,0000 | 0,9854 ; 1,0000 ; 1,0000 | 0,9897 ; 1,0000 ; 1,0000 |
| Q_w(0,975), quantiles 5 / 50 / 95 % entre triangles | 0,9095 ; 0,9548 ; 0,9899 | 0,9196 ; 0,9601 ; 0,9899 | 0,9246 ; 0,9648 ; 0,9899 |
| Q_t(0,975), quantiles 5 / 50 / 95 % entre triangles | 0,8316 ; 1,1310 ; 1,5774 | 0,8703 ; 1,1982 ; 1,6090 | 0,8737 ; 1,2182 ; 1,6041 |
| Q_u(0,975), quantiles 5 / 50 / 95 % entre triangles | 0,9950 ; 1,0000 ; 1,0000 | 1,0000 ; 1,0000 ; 1,0000 | 1,0000 ; 1,0000 ; 1,0000 |

### T7 — admission, refus, triangles sans intervalle, réplications b exclues, se*_b dégénérés

| Profil | tirés | statut ok | statut sans_candidat | statut sans_intervalle | statut refus | statut echec_autre | motifs de refus | refus / tirés | sans intervalle (union I1, I4, C1, C2 à 90 %) / admis | b exclues / σ* finis (dont échecs internes) | se*_b dégénérés / b admises | C2 non formé (triangles à C0, C1) : total ; dont se externe dégénéré | retirage (cumuls) ; plafond |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P1 | 1000 | 1000 | 0 | 0 | 0 | 0 | aucun | 0,00000 | 0,00000 | 0 / 999000 = 0,00000 (0) | 0 / 999000 = 0,00000 | 0 ; 0 | 0 ; 0 |
| P2 | 1000 | 1000 | 0 | 0 | 0 | 0 | aucun | 0,00000 | 0,00000 | 0 / 999000 = 0,00000 (0) | 0 / 999000 = 0,00000 | 0 ; 0 | 0 ; 0 |
| P3 | 500 | 500 | 0 | 0 | 0 | 0 | aucun | 0,00000 | 0,00000 | 0 / 499500 = 0,00000 (0) | 0 / 499500 = 0,00000 | 0 ; 0 | 0 ; 0 |

### Profils de lecture pour D3, évalués mécaniquement, sans décision

| Élément | Valeur |
| --- | --- |
| K-610-3 (contrôles d'intégrité) | rempli |
| Θ0 : au-delà de 1 % sur P1 ou P2 (refus / tirés ; triangles sans intervalle, union I1, I4, C1, C2 à 90 %, / admis ; b exclues / σ* finis) | P1 : 0,00000 ; 0,00000 ; 0,00000 | P2 : 0,00000 ; 0,00000 ; 0,00000 |
| classe à 90 % des candidats | C1 : P1 distorsion matérielle libérale (sous-couverture) ; P2 distorsion matérielle libérale (sous-couverture) | C2 : P1 distorsion matérielle libérale (sous-couverture) ; P2 distorsion matérielle libérale (sous-couverture) |
| candidat en distorsion de côtés opposés (Θ4) | aucun |
| candidats éligibles (Θ1) | aucun |
| **Profil Θ (lecture proposée)** | **Θ3** |
| Préférence (i) : deux queues à 90 % dans [ρ/4 ; 3ρ/4] sur P1 et P2 (comparaison sur les estimations ponctuelles des queues, lecture des classes du protocole : « classes sur les valeurs non arrondies ») | sans objet (moins de deux candidats éligibles) |
| Préférence (ii) | sans objet (moins de deux candidats éligibles) |
| Modificateur W (sous Θ1, par candidat éligible ; règle 3) | sans objet |

Les profils sont des lectures proposées : D3 revient au mainteneur.

Bilan : OK

### Exécution (varie d'une exécution à l'autre)

- Lancement (JOURNAL) : 2026-11-20T10:56:09Z ; fin : 2026-11-20T20:06:18Z
- Processus : 4 ; triangles calculés par cette exécution : 340, 17 tranche(s), 4276 s d'horloge ; tranches reprises : 108
- Durée cumulée des triangles (somme des processus) : 130835 s ; médiane par triangle admis : 51,04 s (externe 0,45, interne 49,90) ; durée totale : 4290 s

