# A2, étape 1 (#612) : spécification et protocole de mesure de la simulation de la colonne J−1 d'un trapèze, et des constats (1) à (4) d'`actuary-10`

*Rédigé par l'agent `actuary-approfondi` (IA), 23/11/2026 ; versé intégralement par la session principale (Q-54-10). Ce fichier est l'entrée du contrôle (t) du script de l'étape 2 : sa section 4 ne se modifie pas.*

> Consultation en lecture seule sur `claude/creneau-a2`, tête `98183f2` ; md5 de `R/engine.R` `0f8167e59e3507dd40bd8a87d122e189` (= `main` `8d7bf2f`). L'agent n'a rien écrit dans le dépôt. Il a fait un pré-vol court (< 2 min de calcul) et une relecture du brut de #567, avec quatre scripts tenus dans le scratchpad de la session, non versés : `prevol.R` (coût, V0/V2 sur `mw_bootstrap()`), `prevol2.R` (`reserve2_trapeze` complet, V0/V2/référence), `disp.R` (dispersion des colonnes des triangles de référence), `ratio.R` (rapport σ²_règle/σ²_dir dans le brut de #567). Exécution sous `LC_ALL=C.UTF-8`, moteur chargé par `tests/outils_tests.R` (donc `charger_moteur()`), substitution posée dans `environment(run_engine)` puis restaurée (vérifiée par `identical()`).
>
> Légende : **[V]** vérifié (source relue ou commande exécutée), **[H]** hypothèse, **[NV]** non vérifié.

## 0. Synthèse

1. **Ce que V2 change.** V2 ne modifie que deux clés, PenteIntra et Alpha, ainsi que σ_boot et l'intervalle. Alpha n'est touché que quand n_{J−1} ≥ 3, donc sur 8×5 et 8×6.
   - Les 11 autres clés (12 sur le 8×7) sont invariantes trajectoriellement en σ_sim > 0, à retirage inchangé [H forte].
   - Appuis :
     - l'invariance relevée par `actuary-10` sur un triangle ;
     - aucun autre changement de nombre de rejets que sur PenteIntra, sur les 300 triangles de `a10`/`a11` ;
     - le pré-vol sur `reserve2_trapeze` : 13 p_mc identiques entre V0 et V2 [V].
   - Le protocole fait de cette invariance un **contrôle d'intégrité**, et non une hypothèse de lecture.
2. **Le carré 8×8 sert aussi de témoin apparié.**
   - Sous les graines de triangle de #567, chaque trapèze est la troncature du 8×8 tiré sous la même graine (plan emboîté).
   - Le 8×8 a les mêmes statistiques observées que le 8×7, donc le même témoin oracle. C'est [V] sur `reserve2` (contrôle (o) de #567) et [H] pour les triangles simulés, contrôlée triangle par triangle.
   - Le carré mesure, sur les mêmes triangles, le comportement que V2 doit atteindre si le trapèze est « le carré privé de ses colonnes courtes ».
   - Ce point est important : le carré n'est pas lui-même au niveau du témoin sous E (PenteIntra 0,05 : 109 contre 80, `actuary-5b` § 4).
3. **Réemploi des graines de #567** (triangles, bootstrap, oracle). Ce choix apporte trois choses :
   - un contrôle fort : V0 à la tête actuelle doit redonner au bit les p du brut de #567 sur un échantillon ;
   - des nombres aléatoires communs entre V0 et V2 ;
   - un **prolongement neuf du 8×7 (b = 1001 à 2000)**, qui sert de réplication confirmatoire du constat V0.

   V0 n'est recalculé en entier que sur ce prolongement. Sa couverture passe par la boucle allégée de #387 (~0,25 s par triangle).
4. **Critères de décision, écrits au § 4 avant toute mesure.**
   - **V2 est retenue si elle remplit quatre conditions :**
     - elle aligne PenteIntra du 8×7 sur le témoin ou sur le carré ;
     - elle ne dégrade ni 8×5 ni 8×6 ;
     - elle ne dégrade pas la couverture ;
     - l'excès de V0 se reproduit sur des triangles neufs.
   - V2 est aussi retenue sur une amélioration significative de V0 qui ne dégrade rien (amélioration partielle).
   - V1 est retenue si seule la couverture se dégrade sous V2.
   - V0 est retenue sinon, **et par défaut quand la mesure ne tranche pas** : la charge de la preuve pèse sur le changement d'une décision du mainteneur.
5. **V1 est motivée, sans aucun flux nouveau dans la mesure.**
   - V1 se lit comme un composite des deux exécutions : tests de V2, σ_boot de V0 sous la même graine.
   - Le contrat partagé (second flux sous graine) ne se pose qu'à l'implémentation, et seulement si la règle R-V1 se déclenche à PA-2.
6. **Coût.**
   - Niveau complet (L-A) : ≈ 21 h d'horloge à 4 processus, soit 12 à 13 segments de 1,8 h, en session cloud (même plateforme que #567) [H, extrapolé du pré-vol et du journal de #567].
   - Le pré-vol du script le fixera à l'étape 2. Deux niveaux réduits sont décrits au § 9.
7. **σ_USP n'est touché par aucune variante** [V].
   - Sur `reserve2_trapeze` sous V2 : aucune p retenue ni aucun verdict ne change ; σ_USP reste identique (0,04757971).
   - L'intervalle bouge au-delà de 1e-6 : il faudra régénérer la référence en (B).
   - En l'état, les mentions M6 et `usage_sigma` deviendraient fausses (E5).
   - Les six autres cas sont inchangés, par construction ou par mesure.

## 1. Question et grandeurs mesurées

**Question.** Le plan est celui de #567 : modèle de Mack ajusté à `reserve2`, T = I + 1 = 8, lois N et E, B = 999. Deux variantes de simulation de la colonne J−1 d'un trapèze sont comparées :
- **V0** : σ̂² de la règle de minimum, état actuel (Q-2a-2, dérogation M-1 (b) comprise) ;
- **V2** : estimateur direct σ̂²_{J−1,dir} pour toute la simulation.

On cherche celle qui rapproche la taille appariée des 13 clés de celle du test idéal, sans dégrader la couverture de σ_boot ni celle de l'intervalle. La question subsidiaire porte sur V1 : direct pour les tests, règle pour σ_boot.

**Grandeurs mesurées.** Elles sont calculées par géométrie G ∈ {8×5, 8×6, 8×7, 8×8}, par loi ℓ ∈ {N, E}, par seuil α ∈ {0,05 ; 0,10} et par clé s parmi les 13 de `MW_CATALOGUE_MC`.

- **Taux de rejet.** τ_V est le taux de rejet du moteur sous la variante V (D = 1{p_mc < α}). τ_T est celui du témoin oracle, définition de #567 (K3) reprise à l'identique.
- **Excès apparié.** Δ_V = τ_V − τ_T, avec les paires discordantes n10 et n01. Deux autres comparaisons appariées s'y ajoutent :
  - V2 contre V0, aux mêmes graines de bootstrap ;
  - le 8×7 sous V2 contre le 8×8, sur les mêmes triangles et avec le même témoin.
- **Classe de τ_V contre ρ**, à titre descriptif : bande fermée [ρ/2 ; 3ρ/2], classes de #567 (P7).
- **Couverture (Q-2b-6).** Non-couverture de l'intervalle percentile du moteur, à 90 % (principal) et à 95 %, avec la queue haute et la queue basse séparées, et les largeurs.
  - La transformation affine croissante vers σ_USP conserve la couverture : raisonnement de #387 (P3) [V, lecture de `.run_engine_mw()` l. 17948-17950].
- **Cibles de couverture.**
  - **σ_A^règle(G)**, cible principale : σ̂ = √MSEP/R̂ du triangle générateur (`reserve2` tronqué à G), qui applique la règle. C'est la convention Q-1b-1 (A) de #387, et la grandeur que σ̂ estime.
    - Valeurs de la règle au générateur : 0,684464 (8×5), 0,141928 (8×6), 0,030091 (8×7) [V, `20261121-issue567-levee-mw04.md` l. 34].
  - **σ_A^vrai(G)**, descriptive : MSEP avec le vrai σ²_{J−1} du plan (0,314779 ; 0,0973248 ; 0,189674).
  - **σ_B**, descriptive : `recomposer()` de #387.

## 2. Ce que le code calcule réellement (base du protocole)

### Point d'entrée unique

- `.mw_simulation_sigma_direct()` (l. 13872) est lue par deux fonctions [V, `grep`, aucun autre appel] :
  - `mw_bootstrap()` (l. 16416) ;
  - `.mw_cas_sigma_direct()` (l. 13888), dont dépendent la mention M6 (l. 17423) et `.mw_usage_sigma()` (l. 13949).
- Elle rend FALSE sans `sigma2_Jm1_direct`, donc sur tout carré.

### V2 par substitution (ADR 0016)

Corps imposé, d'environnement `environment(run_engine)` :

```
function(aj) !is.null(aj[["sigma2_Jm1_direct"]]) && !.mw_colonne_degeneree(aj, aj$J - 1L)
```

- Ce corps coïncide avec V0 dans deux cas :
  - le cas M-1 (b), où les deux valent TRUE ;
  - une colonne J−1 dégénérée, où les deux valent FALSE.
- Sur le carré, `mw_bootstrap()` sous V2 est `identical()` à V0 [V, pré-vol, `reserve2`, B = 999, graine 20260831].

### Pourquoi PenteIntra et Alpha seuls

- **Raisonnement général** [H ; mesuré sur un triangle par `actuary-10`] :
  - les écarts simulés F(i,J−1) − f̂ sont linéaires en σ_sim ;
  - les résidus de J−1 d'une réplication sont réduits par le σ̂ direct de la réplication ;
  - toute statistique invariante d'échelle par colonne ignore donc σ_sim.
- **PenteIntra** pondère les colonnes entre elles par C f̂²/σ̂_j² (l. 14892) : le poids de J−1 dans la pente commune dépend de σ_sim.
- **Alpha** moyenne des amplitudes de colonnes pondérées par n_j, et ne retient que n_j ≥ 3 (l. 15871). La colonne J−1 y entre donc sur 8×5 (n = 4) et 8×6 (n = 3), mais pas sur 8×7 (n = 2) [V, lecture].
- **Le retirage (#257)** peut dépendre de σ_sim. Il est compté par triangle.

### Rapport r = σ²_règle/σ²_dir dans la population mesurée

[V, `ratio.R` sur le brut de #567, triangles admis]

| G | Loi | Médiane de r | P(r < 0,01) | P(r < 1e-3) | P(r > 10) |
|---|---|---|---|---|---|
| 8×5 | N / E | 1,24 / 1,45 | 0,012 / 0,005 | 0,002 / 0,001 | 0,056 / 0,059 |
| 8×6 | N / E | 1,26 / 1,60 | 0,028 / 0,033 | 0,005 / 0,006 | 0,134 / 0,158 |
| 8×7 | N / E | 0,19 / 0,22 | **0,167 / 0,172** | 0,041 / 0,071 | 0,083 / 0,110 |

Taux de rejet sous V0 à 0,05, N et E réunis, par quartile de r croissant :

| Clé et géométrie | Q1 | Q2 | Q3 | Q4 |
|---|---|---|---|---|
| PenteIntra, 8×7 | 0,090 | 0,072 | 0,068 | 0,064 |
| Alpha, 8×5 | 0,066 | 0,052 | 0,029 | 0,030 |
| Alpha, 8×6 | 0,066 | 0,046 | 0,028 | 0,037 |

Ce tableau est descriptif : il n'a pas de témoin, et il est confondu avec la forme du triangle.

Lecture :
- le régime σ_règle ≪ σ_dir (constat 2) n'est pas marginal sur le 8×7 ;
- le sens attendu pour Alpha (conservateur quand r est grand) se voit déjà ;
- statut : [V] pour les nombres, [H] pour le mécanisme.

## 3. Plan de mesure

### Générateur, lois et admission

Ils sont ceux de #567, copiés et déclarés : `gen_triangle_h0()`, `stats_oracle()`, DGP des quatre géométries, pool E redressé. Les contrôles (g) et (g′) sont repris.

L'admission suit P1 de #567, adaptée à la levée de MW-04. Un triangle est refusé dans les cas suivants :
- cellule NA ou cumul ≤ 0 ;
- toute erreur de `mw_valider_triangle()` ;
- domaine numérique ;
- `mw_ajuster()` ;
- `mw_msep()` ;
- refus M4.

L'avertissement de géométrie, non bloquant, n'est pas un motif de refus.

Le chemin par triangle est celui de `.run_engine_mw()` :
1. `mw_ajuster()` ;
2. `.mw_ensembles_figes()` ;
3. `mw_bootstrap(aj, 999, graine, figes)` ;
4. `mw_tests(aj, boot, 0,10, figes)`.

### Blocs

| Bloc | Contenu | Variantes | Triangles / loi | Rôle |
|---|---|---|---|---|
| M7a | 8×7, b ≤ 1000 (triangles de #567) | V2 complet ; V0 lu dans le brut de #567 (échantillon recalculé), couverture V0 par boucle allégée | 1000 | K2, K4 |
| M7b | 8×7, b = 1001 à 2000 (**neufs** pour le 8×7) | V0 et V2 complets | 1000 | **K1 confirmatoire**, K2, K4 |
| M5, M6 | 8×5, 8×6, b ≤ 2000 (triangles de #567) | V2 complet ; V0 lu dans le brut (échantillon recalculé), couverture V0 par boucle allégée | 2000 | K3, K4 |
| C | carré 8×8, b ≤ 2000, mêmes graines de triangle (parents des trapèzes) | une exécution (V0 ≡ V2) | 2000 | K2 (parité), constat (4) |
| D | plan de `actuary-10` : 8×6 de #567 avec σ²_2 := 0 (colonne J−3 déterministe) ; règle nulle → cas M-1 (b), V0 ≡ V2 | une exécution ; oracle propre N0 = 20 000 | 1000 | constats (3), (4) |
| Bal | balayage du σ² de simulation de J−1 | 9 valeurs de k | 20 par (G, ℓ) | constat (2) |
| S | sonde de la plage de dispersion relative 1e-12 à 1e-10 | V0 courant contre prototype P1 | triangles construits | constat (1) |

**Oracle.** C'est celui de #567 (N0 = 20 000 par (G, ℓ)), régénéré sous ses graines. Celui du 8×7 sert au carré, sous réserve du contrôle (o) par triangle.

## 4. Critères de décision (à reporter sans modification, contrôle (t) du script)

> **Critère A2 / #612.** D = 1 si p_mc < α, α ∈ {0,05 ; 0,10} ; une p absente compte comme un non-rejet, comptée à part. Témoin : test idéal sur l'oracle de (G, ℓ), définition de #567 (K3). Pour deux décisions appariées A et B sur les mêmes triangles : Δ = (n10 − n01)/n ; test de McNemar exact (binomial bilatéral de paramètre 1/2 sur n10 + n01) ; intervalle exact conditionnel de Δ = (2π − 1)(n10 + n01)/n, π par Clopper-Pearson sur n10 parmi n10 + n01. Marges d'équivalence δ_0,05 = 0,010 et δ_0,10 = 0,020 (convention : α/5). « Aligné » : intervalle à 90 % de Δ inclus dans [−δ_α ; +δ_α] (équivalence par deux tests unilatéraux à 5 %, Schuirmann 1987). Valeurs non arrondies ; aucune extension du nombre de triangles après lecture ; un « non tranché » reste non tranché.
> - **K0 (intégrité)** : tous les contrôles du § 8 OK ; refus et p absentes ≤ 1 % par (G, ℓ) ; invariance : p_mc des clés autres que PenteIntra et Alpha (autres que PenteIntra sur 8×7) identiques entre V0 et V2 sur au moins 99,5 % des triangles de chaque (G, ℓ), écarts comptés avec leur cause.
> - **K1 (reproduction, confirmatoire)** : sur le 8×7, b = 1001 à 2000, PenteIntra à 0,05, V0 contre témoin, McNemar exact par loi, Holm sur les deux lois à 0,05 : « excès reproduit » si rejet avec Δ > 0 pour au moins une loi.
> - **K2 (correction)** : sur le 8×7, b ≤ 2000, PenteIntra, chaque loi et chaque α : V2 aligné sur le témoin (K2a) **ou** sur le carré 8×8 des mêmes triangles (K2b). K2 tenu si les quatre cellules le sont.
> - **K2′ (amélioration partielle)** : sur le 8×7, PenteIntra, V2 contre V0 (mêmes graines), McNemar exact unilatéral vers moins de rejets, Holm sur les quatre cellules à 0,05 : au moins une cellule significative, et aucune cellule où |Δ̂_V2| > |Δ̂_V0|.
> - **K3 (non-dégradation)** : sur 8×5 et 8×6, PenteIntra et Alpha, chaque loi et chaque α (16 cellules) : V2 aligné sur le témoin, **ou** |Δ̂_V2| ≤ |Δ̂_V0| + δ_α/2 ; et aucune cellule où τ_V2 est en distorsion matérielle (classes de #567) alors que τ_V0 ne l'est pas. K3 tenu si les 16 cellules le sont.
> - **K4 (couverture, comparative)** : intervalle percentile à 90 %, cible σ_A^règle, chaque (G, ℓ) des trois trapèzes : borne haute de l'intervalle à 90 % de la différence appariée des taux de non-couverture (V2 − V0) ≤ +0,02. Le 95 %, les queues séparées, σ_A^vrai et σ_B sont descriptifs.
>
> **Règles** (évaluées mécaniquement par le script, sans conclure ; lecture par `actuary` à l'étape 4, décision du mainteneur à PA-2) :
> - **R0** : K0 en défaut → lecture suspendue, aucune recommandation.
> - **R-V2** : K1, K2, K3, K4 tenus → simuler J−1 avec l'estimateur direct (V2).
> - **R-V2′** : K1, K2′, K3, K4 tenus, K2 non tenu → V2 recommandée comme amélioration, la réserve PenteIntra restant écrite sur le 8×7.
> - **R-V1** : K1, (K2 ou K2′), K3 tenus, K4 en défaut → V1 (tests de V2, σ_boot de V0), prototypée hors moteur avant toute implémentation (contrat partagé).
> - **R-V0** : K2 et K2′ en défaut, ou K3 en défaut → Q-2a-2 confirmée, réserves des fiches reprises avec les nouveaux chiffres.
> - **Défaut** : toute autre combinaison, K1 en défaut compris, est « non tranchée » → V0 par défaut, les deux lectures sont portées au mainteneur.
>
> **Statut épistémique** : constat de simulation sous un plan (modèle de Mack ajusté à `reserve2`, T = I + 1 = 8, lois N et E, B = 999), conditionnel à l'admission ; aucun théorème ne couvre ces tests bootstrap ni cet intervalle à T = 8 ; rien ne se transpose à d'autres paramètres ni à d'autres géométries.

### Justification des critères

- **Toutes les cellules doivent passer.** C'est une procédure d'intersection-union : chaque test unilatéral à 5 % suffit, sans correction de multiplicité [H, raisonnement classique, source non relue].
- **Seconde branche de K3.** Elle évite qu'un manque de puissance sur une des 16 cellules ne fasse rejeter V2 à tort.
- **K2b est indispensable.** Si V2 rend le 8×7 équivalent au carré, l'excès résiduel sous E est celui du carré : il n'est pas propre au trapèze.
- **V0 par défaut.** Q-2a-2 a été décidée pour la cohérence avec la MSEP ; la changer demande un gain démontré (`actuary-5b` § 5).

## 5. Constats (1) à (4)

### (1) Sonde de la plage de dispersion relative 1e-12 à 1e-10 (bloc S)

**Constat.** `mw_residus()` (l. 14599) n'écarte une colonne non figée que si `s2 <= 0`. Les lignes M1 lisent le prédicat de la réplication (`.mw_degeneree_courante()`, l. 13624) [V, lecture].

**Construction des triangles sondés.**
- Bases : `reserve2` (8×8) et `reserve2_trapeze` (8×6).
- Colonne sondée j* ∈ {J−2, J−1 (trapèze seul)}.
- Cette colonne est remplacée par C(i,j*+1) = C(i,j*) f_{j*} (1 + ρ u_i), où u est un motif fixe d'écart relatif maximal 1. Les colonnes suivantes gardent leurs facteurs d'origine.
- Grille ρ ∈ {5e-13 (témoin : colonne figée), 2e-12, 5e-12, 1e-11, 3e-11, 1e-10, 3e-10}.
- B = 999, graine 663 000 000 + u, V0 et V2.

**Instrumentation.** Une enveloppe de `mw_residus` est substituée dans `environment(run_engine)`. Elle fait deux choses :
- compter les appels où une colonne j hors de `j_degeneres`, dégénérée au sens de `.mw_colonne_degeneree(aj, j)`, garde `s2 > 0`, donc ses résidus ;
- évaluer le prototype P1 : exclusion de `union(jd, .mw_colonnes_degenerees(aj))`.

**Sorties.**
- part des réplications touchées ;
- |Δp| maximal sur les 13 clés entre le code courant et P1, rapporté à err_mc ;
- `stats_obs` identiques (contrôle).

**Règle.**
- Correction si une part touchée non nulle et un |Δp| > 2 err_mc existent dans la plage. La correction est un commit `moteur:` distinct, avant celui de la simulation, prouvé au seuil 0 sur les sept cas.
- Sinon, constat documenté, mineur (ADR 0018).

**Seuil 0 attendu en cas de correction** [H forte] :
- la plus petite dispersion relative des colonnes de `reserve2` et `reserve2_trapeze` vaut 5,85e-3 [V, `disp.R`], loin de la plage ;
- les cinq cas lognormaux n'empruntent pas ce code [V, `grep`].

### (2) Balayage de σ_règle/σ_dir, avec PenteIntra et Alpha (bloc Bal, plus lecture stratifiée)

**Triangles.** b = 1 à 20 de chaque (G, ℓ) des trapèzes, avec les mêmes graines de bootstrap que M (nombres aléatoires communs).

**Substitution** (diagnostic seulement). Une enveloppe de `.mw_tirer_triangle_valide()` pose `aj$sigma2[aj$J] <- k · σ̂²_dir` avant l'appel d'origine, pour k ∈ {1e-8, 1e-6, 1e-4, 1e-2, 0,1, 0,3, 1, 3, 10}.

**Contrôles bloquants.**
- valeur posée à σ̂²_règle → `identical()` à V0 ;
- valeur posée à σ̂²_dir → `identical()` à V2.

**Sorties.**
- p(PenteIntra) et p(Alpha) en fonction de log k ;
- invariance des 11 autres clés à chaque k, exceptions comptées ;
- sur les données de M, excès apparié de V0 et de V2 contre le témoin, par quartile de log r (descriptif, confondu avec la forme du triangle).

**Lecture.**
- Sous R-V2 : le régime de faible rapport disparaît, puisque la simulation est toujours directe. La constante `MW_TOL_SIGMA_SIMULATION` devient sans objet pour la simulation (étape 6).
- Sous R-V0 : la réserve est écrite avec la fréquence de r < 0,01 (§ 2) et la courbe.

### (3) Alpha sous E

**Sources de lecture.**
- M5 et M6 : Alpha, V0 contre V2 contre témoin ;
- bloc D : chemin M-1 (b), donc V0 ≡ V2, comparé à l'oracle propre de D, et non à α nominal comme dans `actuary-10` (7/400).

**Règle.**
- Distorsion matérielle conservatrice dans D : réserve « un OK d'Alpha est une preuve faible quand la règle est nulle ».
- Distorsion libérale : constat gardé (E3), trié par la session (ADR 0018).
- Sinon : constat clos.

### (4) MinP4 comparé à #297

MinP4 est invariant à σ_sim [H, appuyée par `actuary-10`, `a10` et le pré-vol] : V0 et V2 n'y changent rien.

**Lectures.**
- τ(MinP4) de M (8×5, 8×6, 8×7) et de C (8×8), comparé à #297, par Fisher exact bilatéral et Holm sur les cellules, comme K-T6 de #567.
  - #297 porte sur le 8×8, avec 2 000 triangles par loi.
  - Taux de #297 à 0,10 / 0,05 : N 0,071 / 0,029 ; E 0,0785 / 0,0395 [V, `20261026-issue297-calibration-famille-mw.md` l. 305, 318].
- MinP4 de D contre l'oracle de D. On cherche si le 0,158 à 0,10 sous E de `actuary-10` (B = 199, référence nominale) subsiste contre un oracle.

**Règle.**
- Distorsion matérielle libérale dans D : constat gardé (E3), hors de #612, trié par la session.
- Sinon : (4) s'explique par la référence nominale et B = 199, et se clôt.

## 6. Graines, nombre de triangles, segments

### Graines

Toutes les graines passent sous `engine_sous_graine()`. Elles sont explicites et toutes < 2³¹ − 1. Notation : ℓ = 1 (N), 2 (E).

**Réemploi déclaré des graines de #567** (P3 amendé), hors du contrôle de chevauchement :
- triangle : 567 000 000 + 100 000 (ℓ − 1) + b ;
- bootstrap : 568 000 000 + 1 000 000 (g − 1) + 100 000 (ℓ − 1) + b, avec g = 1, 2, 3, **la même pour V0 et V2** ;
- oracle : 570 500 000 + 100 000 (ℓ − 1) + k.

Le prolongement du 8×7 (b = 1001 à 2000) tombe dans des graines de bootstrap jamais tirées par #567 : 570 001 001 à 570 102 000. Elles sont disjointes de l'oracle et du pré-vol de #567 [V, arithmétique].

**Plage neuve d'A2 : 660 000 000 à 664 999 999.** Aucun littéral de cette plage n'existe dans `R/` ni `tests/` [V, `grep`].
- carré : bootstrap 660 000 000 + 100 000 (ℓ − 1) + b ;
- D : triangle 661 000 000 + 100 000 (ℓ − 1) + b ; bootstrap 661 500 000 + … ; oracle 662 000 000 + 100 000 (ℓ − 1) + k ;
- sonde : 663 000 000 + u ;
- pré-vol : 664 000 000 + u et 664 500 000 + u (u ≤ 50).

**Disjonction contrôlée** avec :
- 610 000 001 à 644 999 999 (#610, dont la sous-plage du trapèze à 642·10⁶) ;
- les plages de #206/#297, #305 et #387 ;
- 360 380 123.

### Nombre de triangles

Il est fixé par l'erreur Monte-Carlo visée (formules usuelles, [V] par calcul).

**2 000 par (G, ℓ) pour les trois trapèzes et le carré.**
- Demi-largeur de Clopper-Pearson : ±0,0095 pour τ ≈ 0,05 ; ±0,013 pour τ ≈ 0,10.
- Excès apparié : écart-type ≈ √d / n. Avec 2 à 3 % de paires discordantes, l'intervalle à 90 % fait ±0,005 à ±0,006, sous δ_0,05 = 0,010.
  - La part de paires discordantes vient de #567 : 27 à 32 pour 1 000 sous V0 [V] ; sous V2 [H].
- À n = 1 000, l'intervalle serait de ±0,007 à ±0,009, trop près de δ. D'où le prolongement du 8×7 à 2 000.

**K1 sur 1 000 triangles neufs par loi.** Si l'excès de #567 (25 contre 2 pour 1 000) se reproduit, même à moitié, la p de McNemar exacte est ≲ 1e-3 [H] : la puissance est proche de 1.

**D : 1 000 par loi.**
- Assez pour distinguer τ ≈ 0,158 de ρ ≈ 0,10 (intervalle [0,135 ; 0,181]).
- Pas assez pour classer « distorsion matérielle » contre la bande de 0,15 : la lecture de (4) porte donc sur ρ.

**Couverture.**
- Non-couverture attendue vers 0,4, d'après #387 sur le carré [H pour le trapèze] : ±0,022 en absolu.
- La différence appariée V2 − V0, à graines communes, est plus étroite [H].

**Balayage (20 triangles) et sonde** : descriptifs, aucun taux.

### Ordre des segments

L'ordre suit une priorité : une interruption laisse d'abord les cellules décisives.

| # | Segment | Durée |
|---|---|---|
| 0 | contrôles, oracle | ~0,8 h |
| 1 | M7a V2 et échantillon V0 | ~2 h |
| 2-3 | M7b V0 et V2 | ~4 h |
| 4-5 | M5 V2 | ~4 h |
| 6-7 | M6 V2 | ~4 h |
| 8-9 | C | ~4 h |
| 10 | D | ~2,2 h |
| 11 | Bal, S, boucle allégée | ~1,2 h |

Conditions d'exécution :
- segments ≤ 1,8 h (M42 (b), `--duree-max 1.8`) ;
- tranches de 100 triangles, reprise aux tranches absentes ;
- contexte comparé entre tranches : B, SHA, md5 du moteur et du script, empreinte #231, plateforme.

## 7. Séparation des erreurs

1. **Erreur Monte-Carlo de B (B = 999).** Elle fait partie de la procédure du moteur.
   - err_mc d'une p voisine de 0,05 : ≈ 0,0069.
   - Le témoin est lissé à B = 999 (règle de #206 § 4), sans biais de Δ au premier ordre [H, comme #206].
   - Entre V0 et V2, les graines communes la retirent en partie de la différence : les tirages sont les mêmes, seule la statistique change.
2. **Erreur Monte-Carlo du nombre de triangles n.** Elle se lit dans les intervalles de τ, de Δ et de la couverture (§ 6).
3. **Erreur de l'oracle (N0 = 20 000).** Le quantile du témoin est connu à ≈ √(α(1−α)/N0) = 0,0015 près à 0,05 [V, calcul]. Elle est commune à V0, V2 et C.
4. **Erreur d'approximation à T = 8**, objet mesuré : τ_V − τ_T. C'est la distorsion du test bootstrap à paramètres estimés, dont le choix de σ²_{J−1}, et la couverture.
5. **Erreur de substitution** (plan et lois au lieu de la vérité) : **non quantifiée**. Les conclusions sont conditionnelles au plan.

**Littérature.** L'agent n'a retrouvé aucune source qui établisse le niveau de ces tests bootstrap sur résidus de Mack, ni la couverture de cet intervalle, à T = 8.
- Il reprend le constat de `actuary-5b` § 6 et de l'ADR 0005 (annotation du 21/11, points 9 et 10), sans nouvelle recherche bibliographique propre [NV].
- **La littérature ne permet pas de conclure à T = 8.** Seule la mesure tranche, sous ce plan.

## 8. Spécification du script pour `coder-approfondi` (étape 2)

### Fichier et contraintes

- Fichier : `tests/simulation_jm1_trapeze_t8.R`, outil de mesure hors CI (nom sans préfixe `test_`).
- Dépendances : R base, stats, parallel, utils, tools.
- Encodage : source en ASCII avec échappements `\u`, sortie en UTF-8 (#242).
- Moteur chargé par `tests/outils_tests.R`.
- Les fonctions de #567 et de #387 sont **copiées et déclarées**, sans modifier `niveau_mw_trapeze_t8.R` ni `couverture_ic_sigma_mw_t8.R`.
- Aucune écriture dans `R/`, `app.R` ni `tests/reference/`.

### Entrées lues, md5 contrôlés

- brut de #567 : `9fcb59cd24212f7f1c851e7634a34e3f` ;
- tableau de #567 : `adf5de226021c2521cb564757086e26b` ;
- brut de #297 : `01325170c75ccc603707f96332dc1e96` ;
- le présent fichier (contrôle (t)).

### Modes

- `--essai` : R = 3 par cellule, B = 199, sorties marquées, `--ecrire` refusé.
- `--prevol` : coût à 1, 2, 3 et 4 processus ; niveau L-A, L-B ou L-C qui tient dans le budget de PA-1 ; nombre de segments ; rien d'écrit.
- Mesure : options `--niveau`, `--bloc`, `--processus`, `--travail`, `--duree-max`, `--ecrire [--remplacer]`.

Dernière ligne de la console :

| Ligne | Code de sortie |
|---|---|
| `INTEGRITE OK` | 0 |
| `INTEGRITE ECHEC` | 1 |
| `SEGMENT INTERROMPU` | 3 |

### Substitutions

Trois substitutions sont posées, toutes dans `environment(run_engine)` :
- V2 (corps du § 2) ;
- balayage (`.mw_tirer_triangle_valide`) ;
- sonde (`mw_residus`).

Chacune est restaurée par `on.exit`. La restauration est contrôlée par `identical()` au corps d'origine. Les corps des trois substitutions sont imprimés au T0.

### Contrôles

Tous les contrôles sont bloquants. Ceux qui ne dépendent pas de la mesure passent avant tout tirage.

- **(1) Contexte.** md5, SHA et empreinte constants ; `git diff --quiet -- R/engine.R` au début et à la fin.
- **(a) Références.** `reserve2` et `reserve2_trapeze` contre `tests/reference/` au seuil 0 sur la plateforme de #567. Sur une autre plateforme : 1e-6, plateforme notée.
- **(v0) V0.** V0 du script `identical()` à `run_engine()` sur les 13 p_mc des triangles du pré-vol.
- **(v2) V2.** Même contrôle sous la substitution V2.
- **(r567) Reproduction de #567.** V0 est recalculé sur le premier triangle admis de chaque tranche de #567.
  - Doivent être identiques au brut relu en `%.17g` : les 13 p_mc, `obs`, `s2_regle`, `s2_dir`, `R_hat`, `msep`.
  - Un échec arrête la mesure et revient au mainteneur : le coût change, car V0 serait à recalculer en entier.
- **(inv) Invariance.** Critère K0, sur chaque triangle.
- **(so) Statistiques observées.** `stats_obs` identiques entre V0 et V2.
- **(o) Carré.** `stats_obs` du 8×8 `identical()` à ceux du 8×7, par triangle.
- **(g) et (g′).** Repris de #567.
- **(al) Boucle allégée.** `sigma_boot` de la boucle allégée `identical()` à celui de `mw_bootstrap()`, sur le premier triangle de chaque tranche, en V0 et en V2.
- **(oracle) Témoin de #567.** ρ et tailles du témoin de #567 reproduits aux cinq décimales imprimées, sur les 78 lignes. md5 `5bdafe159cd5624fee6ba906896d4f40` si le format d'`oracle.tsv` est repris.
- **(bal) Balayage.** Points règle et direct `identical()` à V0 et à V2.
- **(graines), (m), (t).**
- **(rep) Recalcul.** Premier et dernier triangle de chaque cellule recalculés.

### Sorties

Les sorties vont dans `docs/tableaux/`, à quatre conditions : `--ecrire`, INTEGRITE OK, commit propre, `garde_ecrasement()`. Ce sont des fichiers nouveaux, jamais patchés.

- **`<AAAAMMJJ>-issue612-simulation-jm1-trapeze.md`** :
  - T0 et contrôles ;
  - K0 à K4 ;
  - règle évaluée mécaniquement, **sans conclure** ;
  - tables des 13 clés ;
  - constats (1) à (4) ;
  - p de famille en descriptif (K-T7).
- **`…-brut.tsv`** : une ligne par (bloc, G, ℓ, b, variante), en `%.17g`, sans durée. Colonnes :
  - graines, statut, motif ;
  - r, `R_hat`, `msep`, `msep_dir`, σ̂ ;
  - quantiles de σ_boot (0,025 / 0,05 / 0,5 / 0,95 / 0,975) ;
  - `n_sans_sigma`, retirage, B effectif ;
  - `obs` et p des 13 clés, p du témoin des 13 clés ;
  - drapeaux de contrôle.
- **`…-balayage-brut.tsv`**, **`…-sonde.tsv`** et **`…-journal-mesure.md`**.

Les oracles restent dans le dossier de travail ; leur md5 est cité.

### Critères d'acceptation de l'étape 2

- `git diff -- R/engine.R` vide ;
- deux exécutions du pré-vol identiques au bit, hors durées ;
- (v0) et (v2) OK ;
- `--essai` avec INTEGRITE OK ;
- audit léger ;
- conformité au protocole vue par `actuary` (routine).

## 9. Coût et budget (éléments pour PA-1)

### Pré-vol

[V] Un processus, sur cette machine (Linux, 4 cœurs, R 4.3.3). `mw_bootstrap()` à B = 999, graine 20260831 ; deux exécutions par cas :

| Triangle | V0 | V2 |
|---|---|---|
| `reserve2_trapeze` (8×6) | 12,95 s ; 11,79 s | 11,33 s ; 12,07 s |
| carré | 11,78 s ; 11,59 s | 11,72 s ; 11,54 s |

### Débit à 4 processus

≈ 1 000 bootstraps par heure d'horloge [V] :
- 10 000 triangles et 120 000 oracles de #567 en 10 h 04 (20:10:25 → 06:14:53) ;
- 142 501 s de calcul cumulé ;
- même plateforme (Ubuntu 24.04.5, R 4.3.3).

### Niveaux

[H, ±15 %, à fixer par le pré-vol du script]

| Niveau | Contenu | Bootstraps | Horloge | Segments de 1,8 h |
|---|---|---|---|---|
| **L-A (recommandé)** | tout le § 3 | ≈ 21 000 | **≈ 21 h** | 12-13 |
| L-B | carré à 1 000 par loi, D sous E seul, balayage sous N seul | ≈ 17 600 | ≈ 18 h | 10-11 |
| L-C | M seul, plus la sonde ; sans carré, sans D, sans balayage (contraire au carré témoin de Q-73-3 (a) ; constats (2) à (4) sur le brut de #567 seulement) | ≈ 14 200 | ≈ 15 h | 9 |
| L-A′ | L-A avec des graines neuves partout (sans réemploi de #567) | ≈ 31 000 | ≈ 31 h | ≈ 18 |

Comptes de L-A :

| Poste | Bootstraps |
|---|---|
| V2 | 12 000 |
| V0 sur le prolongement du 8×7 | 2 000 |
| échantillon de contrôle V0 | 100 |
| carré | 4 000 |
| D | 2 000 |
| balayage | 840 |
| sonde | ≈ 70 |

S'ajoutent ≈ 0,8 h pour les oracles (160 000 lignes) et la boucle allégée.

### Poste ou cloud

**Session cloud recommandée**, pour deux raisons :
- c'est la plateforme du brut de #567, condition du contrôle (r567) au bit ;
- elle offre 4 processus par fork.

Contraintes M42 :
- tâche de fond suivie, `timeout` ≤ 7 200 000 ms ;
- enchaînement de segments sur accord exprès, avec le nombre de segments ;
- branche de sauvegarde `claude/sauvegarde-612` des tranches, proposée au mainteneur (M42 (c)).

**Poste Windows déconseillé** :
- un seul processus par défaut, soit ≈ 4 fois plus long ;
- (r567) non garanti au bit ;
- sorties jamais mélangées entre plateformes.

## 10. Effets prévisibles

- **σ_USP : inchangé** dans toutes les variantes [V].
  - `mw_parametre(aj, msep, sigma_standard, bareme)` (l. 14425) ne reçoit pas le bootstrap.
  - Pré-vol : σ_USP de `reserve2_trapeze` identique sous V2 (0,04757971).
- **`reserve2_trapeze` sous V2** [V, `prevol2.R`].
  - Aucune p retenue ni aucun verdict ne change. Les 13 p_mc de `mw_bootstrap()` sont identiques (r = 1,458).
  - `ic_bootstrap` change, avec des écarts au-delà de 1e-6 en relatif :

    | Variante | `ic_bootstrap` |
    |---|---|
    | V0 | 0,04438426 / 0,04481744 / 0,04753332 / 0,05029606 / 0,05062466 |
    | V2 | 0,04438554 / 0,04482070 / 0,04753261 / 0,05029163 / 0,05061619 |

  - `sigma_boot`, `plots_data$sigma_usp_boot` et `boot_reperes` changent aussi.
  - D'où, en (B), une régénération par la CI et un tableau avant / après.
  - V0 actuel est conforme à la référence à 1e-6 (18 573 feuilles) [V].
- **Textes, en (B)** [E5].
  - Avec le point d'entrée tel quel, `.mw_cas_sigma_direct()` classerait tout trapèze non dégénéré en « simulation ».
  - Le gabarit `FORMAT_MENTION_MW_SIGMA_DIRECT_SIMULATION` (« ici nulle ou négligeable ») et `MW_USAGE_SIGMA` deviendraient alors faux. Ils sont à réécrire à l'étape 6, puis à faire relire par `app-review`.
  - `MW_TOL_SIGMA_SIMULATION` deviendrait sans objet pour la simulation [H].
- **Sous V1.**
  - Les p seraient comme sous V2, σ_boot comme sous V0.
  - Avec une boucle σ seule à la même graine (≈ 0,25 s de plus par calcul [H, coût de #610]), les nombres de `reserve2_trapeze` seraient probablement inchangés [H].
  - Mais il y aurait un second flux, ou une seconde boucle sous `engine_sous_graine()`, et un champ de métadonnées : c'est un contrat partagé (§ 4.2).
- **Les six autres cas.**
  - `reserve2` (carré) est identique dans toutes les variantes : point d'entrée à FALSE, `mw_bootstrap()` `identical()` [V].
  - Les cinq cas lognormaux n'appellent pas ce code [V, `grep` des appelants].
- **Constat (1), s'il est corrigé** : seuil 0 attendu sur les sept cas [H forte, § 5], à prouver.

## Retour

**Statut** : `revue requise`. Le protocole est complet ; son lancement attend les décisions de PA-1.

### Preuves

**Vérifiées :**
- lecture de `R/engine.R` : point d'entrée, `mw_bootstrap()`, `mw_residus()`, `.mw_pente_relative()`, `mw_famille_alpha()`, catalogue, signature de `mw_parametre()` ;
- pré-vols (`prevol.R`, `prevol2.R`) ;
- `disp.R` et `ratio.R` ;
- journal et tableaux de #567 et de #297 ;
- ADR 0005 (annotation du 21/11) ;
- avis `actuary-5b` et `actuary-10` ;
- protocole de #610 ;
- plage de graines libre ;
- Schuirmann (1987), *J. Pharmacokinetics and Biopharmaceutics* 15, 657-680, doi 10.1007/BF01068419 : notice retrouvée (la procédure TOST équivaut à un intervalle à 1 − 2α inclus dans les marges), texte non relu.

McNemar (1947), Clopper-Pearson (1934) et Holm (1979) sont cités d'après la bibliographie du `.tex` : notices vérifiées par le projet, non relues par l'agent.

**Hypothèses :**
- invariance des 11 clés hors cas étudié ;
- V2 sur le 8×7 identique en loi au carré ;
- taux de discordance sous V2 ;
- débit et durées ;
- non-couverture ≈ 0,4 sur trapèze ;
- seuil 0 d'une correction de (1) ;
- effet de V1 sur `reserve2_trapeze`.

**Non vérifié :** l'absence de littérature à T = 8, reprise des avis antérieurs.

### Informations manquantes

- L'oracle de #567 n'est pas versionné. Il est régénéré, et son identité se contrôle par ρ et les tailles du témoin.
- Le brut de #567 ne contient pas σ_boot : la couverture de V0 passe par la boucle allégée.

### Décisions pour le mainteneur (PA-1)

- **Q-PA1-1 — Budget.** Recommandation : L-A (≈ 21 h, 12-13 segments). Autres niveaux : L-B (≈ 18 h) ; L-C (≈ 15 h), écarté car sans carré.
- **Q-PA1-2 — Plateforme.** Recommandation : session cloud, segments de 1,8 h, accord exprès (M42 (b)), branche `claude/sauvegarde-612` (M42 (c)). Écarté : le poste Windows.
- **Q-PA1-3 — Graines.** Recommandation : réemploi déclaré des graines de #567, avec le prolongement neuf du 8×7 en partie confirmatoire. Écarté : des graines neuves partout (L-A′, ≈ 31 h).
- **Q-PA1-4 — Couverture.**
  - Recommandation : la mesurer pour V0 et V2, en comparaison appariée, à coût quasi nul (K4). Sans V0, on ne peut ni juger V2 sur la couverture, ni motiver V1.
  - C'est un écart à la lettre « pour la seule variante proposée » (Q-2b-6), à confirmer.
  - Cible principale : σ_A^règle (précédent Q-1b-1 (A)).
- **Q-PA1-5 — V1.** Lecture composite sans implémentation ; prototype et contrat partagé seulement sous R-V1, à PA-2.
- **Q-PA1-6 — Critères.** Approuver K0 à K4, les marges δ (0,010 / 0,020) et 0,02, et la règle « V0 par défaut si non tranché ».
- **Q-PA1-7 — Bloc D.** L'inclure (≈ 2,2 h) pour les constats (3) et (4).

### Critères de routage (`docs/agents/routage.md`)

- **§ 4.1** : aucun.
- **§ 4.2** : seulement à PA-2.
  - En (B) : l'ADR 0005 est modifié (décision, point 4), et un résultat change (`ic_bootstrap` et σ_boot de `reserve2_trapeze` ; verdicts possibles sur d'autres trapèzes).
  - Sous R-V1 : contrat partagé (`engine_sous_graine()` et graines).
- **Validité à T = 8** : aucun résultat exact ne la tranche ; seule la mesure le fait, sous un plan.
- **Écart à la lettre d'une décision** (Q-2b-6, couverture des deux variantes) : porté à Q-PA1-4.
- **Désaccords** : aucun avec `audit`, un autre expert ou un ADR.
- **Constats hors périmètre** : aucun. La surface E5 des gabarits M6 et de `usage_sigma` sous V2 est dans le périmètre de #612, à l'étape 6.
