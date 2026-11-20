# S6, étape 2a (#567) : spécification D1 de l'extension de Merz-Wüthrich au trapèze I > J

> *Rédigé par l'agent actuary (IA), fiche approfondie, mission de jugement, en lecture seule.* Lu sur `claude/merz-wuthrich-trapeze` : base `c181bf1`, puis `804a45b` (lecture de `regulatory`, étape 1). Je n'ai rien écrit dans le dépôt, ni issue ni commentaire. Prototypes et sources externes sont restés dans le dossier temporaire de la session :
> - `…/scratchpad/proto/` : `msep_trap.R`, `msep_trap3.R`, `dir.R`, `cout.R` ;
> - `…/scratchpad/cl/` : archive CRAN ChainLadder 0.2.21.
>
> Légende : **[V]** vérifié (source relue ou commande exécutée), **[H]** hypothèse, **[NV]** non vérifié.
>
> *Note de versement (session principale) : rapport versé intégralement, tel que rendu (seul le préfixe du dossier temporaire de la session est abrégé en `…/scratchpad/`). Les prototypes sont versés sans modification dans `actuary-2a-prototypes/` (avec `msep_trap2.R`, étape intermédiaire) ; ils lisent l'archive CRAN ChainLadder 0.2.21 (md5 cité au § 0) à un chemin du dossier temporaire, à adapter. L'archive n'est pas versée (Q-2a-5).*

## 0. Synthèse

Verdict : **spécification prête pour D1'**, sous les décisions Q-2a-1 à Q-2a-6 (§ 11). Rien n'a été codé dans le moteur.

Quatre constats changent l'état du dossier :

1. **La MSEP restreinte (convention (B)) est confrontée à une implémentation indépendante, écrite par l'auteur.**
   - ChainLadder 0.2.21 (CRAN, publié le 18.2.2026, archive de md5 `2a1fc0fcc593ec99529a40399274a088`), fichier `R/MWChainLadder.R`. La fonction interne `CL_MSEPs` porte l'en-tête « Author: Mario Wuthrich ».
   - Elle prend `I0 = nrow`, `J0 = ncol`, et somme sur `for (i in (I0-J0+2):I0)`, c'est-à-dire i = I−J+1..I en indices 0. C'est exactement la convention (B) : elle traite le trapèze de façon native [V, lecture].
   - Je lui ai donné des paramètres transcrits indépendamment du moteur. Le prototype hors moteur coïncide avec elle à au plus 2,2e-16 en relatif [V, exécuté] :
     - triangle de `tests/donnees/triangle_mw.csv` tronqué en 8×7, 8×6 et 8×5 ;
     - GenIns tronqué en 10×9, 10×7 et 10×5 ;
     - sur les carrés 8×8 et 10×10, il est égal à `mw_msep()`.
   - Les σ obtenus (0,016621 ; 0,018101 ; 0,021331) sont ceux du script de `regulatory`. Trois calculs indépendants concordent donc.
   - Conséquence : le critère « Fable si l'égalité ne s'établit que par raisonnement » ne tient plus, dès que la mesure 5 (a) reproduit ce résultat sur le moteur.
   - Ce n'est pas une formule imprimée. Aucune source publiée imprimant le cas I > J n'a été relue (§ 1).
2. **Avec l'option (c) recommandée pour la colonne J−1 (§ 2), les tests d'un trapèze sont ceux du carré de même I, privé de ses colonnes courtes** (n_j ≤ I−J) [V, lecture du code ; identité au bit à vérifier en 3, H].
   - Le 8×7 a exactement les statistiques observées du 8×8 dont il est tronqué. Son niveau doit donc égaler, en loi, celui de #297.
   - L'étude de niveau s'en sert comme contrôle d'implémentation (K-T6).
3. **Mon avis du 12/11 est à corriger** : il donnait comme « sens attendu » de la règle de minimum une MSEP plus faible.
   - Sur le plan de #206, la règle appliquée aux valeurs vraies donne un σ²_{J−1} **inférieur** au vrai pour le 8×7 (0,0301 contre 0,1897) et **supérieur** pour le 8×6 (0,1419 contre 0,0973) et le 8×5 (0,6845 contre 0,3148) [V, arithmétique sur les valeurs de #206 § 2].
   - Sur `triangle_mw` même, σ avec l'estimateur direct / σ avec la règle vaut 1,147 (8×7), 0,976 (8×6) et 0,884 (8×5) [V].
   - Le signe dépend du profil des σ²_j, et non d'un biais systématique. L'argument de Jensen ne porte que sur l'écart entre l'espérance de la règle estimée et la règle aux valeurs vraies.
4. **Lecture de `regulatory`, intégrée.**
   - G(3)(c) : durée I + 1, une seule lecture.
   - D(5)(d)(ii) : règle de minimum prescrite pour j = J−1 quel que soit I.
   - R̂ ≤ 0 : refus transposé tel quel, `derniers` borné à la colonne J.
   - D(2)(e) admet le trapèze. Les lectures (A) et (B) portent sur D(4) et D(5).
   - Constat nouveau sur la forme de 2015 (§ 1.4) : j'en suis d'accord.

## 1. (i) MSEP du trapèze

### 1.1 Sources

- **Merz et Wüthrich (2008), *CAS E-Forum*, automne 2008, p. 546** : « we assume that I = J (note that all our results can be generalized to the case I > J) ». Vérifié les 12 et 13/11 sur le PDF de la CAS, non relu ce jour. Le cas est annoncé, sans formule.
- **Wüthrich et Merz (2008, Wiley) ; Merz, Wüthrich et Lysenko (2009, *Scandinavian Actuarial Journal*)** : **non consultés** [NV].
  - Les hôtes `core.ac.uk` et `www.research-collection.ethz.ch` ne résolvent pas dans cette session (réseau restreint).
  - L'ouvrage n'est pas en accès libre.
  - Accès selon Q-63-10 : session à réseau complet. Aucune citation tirée de ces textes.
- **ChainLadder 0.2.21, `CL_MSEPs` et `CDR.MackChainLadder`** [V, source lue] :
  - ce sont des implémentations, à citer comme telles et jamais comme formule publiée ;
  - `checkTriangle()` ne refuse que n > m (`R/ChainLadder.R` l. 120-124) : un trapèze est accepté ;
  - `Mack.S.E()` n'applique l'extrapolation de Mack qu'aux σ manquants (`R/MackChainLadderFunctions.R` l. 157-201). Sur un trapèze, la colonne J−1 a au moins 2 facteurs : `CDR(MackChainLadder(...))` y prend donc **l'estimateur direct**, et non la règle du règlement.

### 1.2 Forme à implémenter (convention (B), forme consolidée, ADR 0005)

- `mw_ajuster()` : `dernier_observe[i] = C(i, min(I−i, J))` pour toutes les lignes.
  - Pour i ≤ I−J : `ultime = C(i,J)` observé et `reserve_par_annee = 0` exactement.
  - Pour un carré, l'expression est identique, puisque I−i ≤ J.
- `mw_msep()` et `mw_contributions()` : boucles en i sur `(I−J+1):I`, au lieu de `1:I`.
  - Pour I = J, la séquence, l'ordre de sommation et les bits sont les mêmes [V, lecture].
- Estimateur direct de la colonne J−1, calculé seulement si I > J :
  - formule : σ̂²_{J−1,dir} = Σ_{i=0}^{I−J} C(i,J−1)(F(i,J−1) − f̂_{J−1})² / (I−J), soit la première ligne de D(5)(d)(ii) appliquée à j = J−1 ;
  - expression et ordre identiques à ceux de la boucle j ≤ J−2 ;
  - champ ajouté à l'objet d'ajustement **seulement si I > J** à l'étape 3 : l'objet `ajustement` est restitué, et le chemin carré doit rester identique au seuil 0.

### 1.3 Protocole de confrontation, tolérances fixées avant tout code

- **C1, critère d'acceptation, exécutable en session cloud.**
  - Comparaison : `mw_msep(mw_ajuster(tri))` généralisé contre `CL_MSEPs(FullTriangle, I0, J0, param)`. `param` = (f̂, σ̂² de la règle, Q̂, α_j = C(I−j,j)/S′_j), calculés par une transcription indépendante dans le script, et non par le moteur.
  - Lecture de la fonction : dans l'archive CRAN (chemin en argument, md5 contrôlé). **Aucune copie dans le dépôt** (licence GPL ≥ 2 ; Q-2a-5).
  - Tolérance : MSEP et R̂ à **1e-12 relatif** (mesuré : 2,2e-16) ; f̂, σ̂²_j et σ̂²_{J−1,dir} à 1e-12 contre la transcription indépendante.
  - Jeux : `triangle_mw` 8×7, 8×6, 8×5 ; GenIns 10×9, 10×7, 10×5 ; les carrés 8×8 et 10×10 ; le premier triangle admis de chaque tranche de l'étude de niveau.
  - Valeurs attendues, mesurées par le prototype [V] :

    | Jeu | MSEP | R̂ | σ̂²_{J−1}, règle | σ̂²_{J−1}, direct |
    |---|---|---|---|---|
    | 8×7 | 19915.3947059509 | 8490.81633282289 | 0.0300913181729469 | 0.189673662669698 |
    | 8×6 | 17334.2597283566 | 7273.53169003966 | 0.141927830391250 | 0.0973247604368617 |
    | 8×5 | 15763.5410314709 | 5885.87803675476 | 0.684464137043688 | 0.314778798976253 |
    | GenIns 10×9 | 2764721031511.53 | 17825075.6984623 | 24.3674453780781 | 1147.36596842866 |
    | GenIns 10×7 | 2220973209004.33 | 12983205.6743162 | 12418.5249545645 | 8185.77162000963 |
    | GenIns 10×5 | 1405527865679.78 | 8599219.11811852 | 37736.8550479964 | 15182.9026809764 |

  - Ces valeurs sont à régénérer hors CI par `tests/unitaires/generer_valeurs_externes.R`, étendu, puis écrites en dur dans `test_merz_wuthrich.R` (précédent GenIns).
- **C2, complément sur un poste où ChainLadder est installé** :
  - `MackChainLadder(trap, est.sigma = "Mack")` puis `CDR()` ;
  - f̂ à 1e-12 ; σ̂²_j (j ≤ J−2) et σ̂²_{J−1,dir} à 1e-10 (tolérances du précédent GenIns, `test_merz_wuthrich.R` l. 989-998) ;
  - `CDR(1)S.E.` total à 1e-10 contre √MSEP généralisée où σ²_{J−1} et Q̂_{J−1} sont remplacés par l'estimateur direct (mécanique de `mw_sensibilite_sigma2_dernier()`) ;
  - ChainLadder est absent de la session cloud, et l'installation depuis CRAN (joignable) n'a pas été tentée [NV].
- **C3, simulation directe du CDR : non retenue comme critère.**
  - La MSEP de Merz-Wüthrich est un estimateur, à paramètres estimés, de l'erreur conditionnelle.
  - Une simulation avant, sous des paramètres fixés, ne reproduit pas cet estimateur. Elle n'admettrait qu'une tolérance statistique sur une partie des termes [H, raisonnement].
  - Seul contrôle trivial gardé : CDR identiquement nul pour i ≤ I−J.

### 1.4 Constat (5) de `regulatory` sur la forme de 2015

D'accord. L'outil applique la forme consolidée (ADR 0005), qui seule est une MSEP. C'est aussi celle de `CL_MSEPs` (sommes restreintes, termes croisés `min(i,i1)`) [V]. La non-transposition à la forme de 2015 est à porter dans l'annotation de l'ADR 0005 à D2 ; elle ne change rien au calcul.

## 2. (ii) Sort des résidus de la colonne J−1

Avec I > J, la colonne J−1 a n = I−J+1 facteurs : 2, 3 et 4 pour les 8×7, 8×6 et 8×5.

**Recommandée, (c)** : la colonne J−1 est traitée par la règle générique de toutes les colonnes. Ses résidus sont réduits par **σ̂²_{J−1,dir}** dans `mw_residus()`, `mw_influence()` et `mw_identifiabilite_intra()`, donc dans toutes les lignes fondées sur les résidus et dans le vivier. f̂, Ĉ, la MSEP et la simulation (§ 3) gardent σ̂²_{J−1} de la règle.

Raisons :
- (iii) et (iv) de D(2)(h) sont des hypothèses du modèle, où σ_j est une constante de colonne. La règle de minimum est une prescription d'estimation pour la MSEP, pas une hypothèse.
- Réduire par un σ qui ne vient pas de la colonne romprait Σ_i r²_ij = n_j − 1 et la variance unitaire qui fondent le vivier (`.mw_un_moins_h()`, `mw_residus_redresses()`) [V, lecture].
- Avec (c), aucune règle nouvelle n'apparaît pour les tests. Un trapèze est le carré de même I privé des colonnes j ≥ J (n_j ≤ I−J). En particulier, l'ancienne colonne 5 du 8×8 (n = 2, σ̂²_5 direct, résidus inclus) reste traitée de même dans le 8×7.
- Colonne J−1 dégénérée (facteurs égaux) : σ̂²_dir = 0, et le prédicat existant (`.mw_colonne_degeneree()`, exclusion par σ² ≤ 0) l'écarte, sans règle nouvelle.
- Chemin carré : la colonne J−1 n'a qu'un facteur et sort par `length(idx) < 2` avant toute lecture de σ. Un aide qui lit le vecteur des σ de diagnostic, égal à `aj$sigma2` quand le champ direct est absent, laisse les bits inchangés.

**Écartées** :
- (a) colonne J−1 hors des résidus et du vivier seulement : les lignes fondées sur les facteurs (Calendrier, CorrDev, Origine) la gardent, d'où une couverture incohérente entre lignes ; un même jeu de données serait testé dans le carré et non dans le trapèze ; on perd 2 à 4 résidus sur 22 à 27.
- (b) réduction par σ̂ de la règle : échelle fausse et vivier invalide.

## 3. Simulation du bootstrap pour la colonne J−1

**Recommandée** : σ̂_{J−1} de la règle, sans changement de `.mw_simuler_triangle_etat()`.
- C'est cohérent avec le modèle de D(5)(d)(ii) qui produit la MSEP, comme aujourd'hui pour la ligne 0 du carré.
- Les statistiques réduites par colonne et les statistiques de rang y sont invariantes. Seuls σ* (donc `sigma_boot` et l'intervalle) et, au-delà de n ≥ 3, la ligne Alpha en dépendent [V, lecture de `.mw_pente_relative()`, de BP et des fonctions de rang ; invariance d'échelle par colonne, H argumentée].

**Écartée** : σ̂_{J−1,dir}, plus fidèle aux données, mais incohérent avec la MSEP et sans base dans le texte (Q-2a-2).

## 4. (iii) Règle de minimum et M6

- La règle est gardée pour j = J−1 quel que soit I (`regulatory`, point 4 ; `mw_ajuster()` l. 13411-13419 l'applique déjà) [V].
- Ligne M6 « Extrapolation de sigma … » :
  - `estim` reste la valeur de la règle, en diagnostic sans verdict ;
  - pour I > J, le détail et un champ restituent **pour information** σ̂²_{J−1,dir} et ses degrés de liberté (I−J) ;
  - phrase R-3 : la règle s'applique par prescription du texte alors qu'un estimateur direct existe ;
  - **aucun σ ni aucune √MSEP alternative** (précédent Q-D1-Fm-7) ;
  - le champ commun à tous les cas (NA pour un carré) n'arrive qu'à l'étape 6, avec régénération par la CI.
- Bruit de l'estimateur direct à T = 8 : sous erreurs gaussiennes, ν σ̂²/σ² suit un χ²_ν, avec ν = I−J (résultat classique du modèle linéaire gaussien de la régression pondérée par l'origine, conditionnellement à la colonne).
  - CV √(2/ν) = 1,41, 1,00 et 0,82 pour ν = 1, 2 et 3.
  - Hors normalité : NV.
  - Aucune littérature retrouvée ne dit lequel des deux estimateurs est préférable à T = 8.

## 5. (iv) T de crédibilité

- **I + 1, une seule lecture** (`regulatory`, point 5). Le code l'applique déjà :
  - `mw_parametre()` l. 14127 (`T_cred <- aj$I + 1L`) ;
  - avertissement de crédibilité, `nrow(tri)`, l. 13340-13345 ;
  - `metadata$T = aj$I + 1` [V].
- Aucune modification du moteur. Critère : sur un 8×5, c vaut c(8) du barème appliqué. L'application lit T dans l'objet (étape 6).

## 6. (v) Refus de R̂ ≤ 0 (M4)

- Gardé sans changement. `mw_valider_ajustement()` lit `aj$reserve`, où les lignes i ≤ I−J contribuent exactement 0 (`identical(0)` à tester).
- Le bootstrap garde `ab$reserve > 0` pour σ*.

## 7. (vi) Lignes M1 à M6 : effectifs, p_min et ensembles figés

Aucune table ni constante codée en dur ne dépend de I = J.
- Les fonctions de p_min prennent les effectifs en argument : `.mw_calendrier_p_min(n_k)`, `.mw_corr_p_min(n_k)`, `.mw_fisher_rangs_p_min(n_j)`, `.mw_kruskal_p_min(tailles)`.
- Les ensembles figés sont calculés sur l'ajustement observé [V, lecture].
- Aucune ligne de Merz-Wüthrich n'a de p exacte retenue : les lois discrètes ne servent qu'à p_min.
- À I + 1 = 8, n_j ≤ 7, sous le plafond d'énumération n ≤ 9.

Seul changement d'ensemble figé : J−1 n'est plus dégénérée par construction. Elle sort de `jd`, où elle figurait toujours pour un carré (jd = {6} sur `reserve2`).

Sous (c), colonnes retenues par ligne (effectifs n_j = 7−j) :

| Ligne (clé) | Seuil | 8×8 (réf.) | 8×7 | 8×6 | 8×5 | p_min ou ensemble figé changé |
|---|---|---|---|---|---|---|
| PenteIntra, DW, KruskalAcc, Runs, Variance unitaire, ESD, M5 (résidus) | n ≥ 2 | 7..2 | 7..2 | 7..3 | 7..4 | p_min de KruskalAcc et de Runs : 8×6 et 8×5 |
| Calendrier, et par diagonale | n ≥ 2, hors jd | 7..2 | 7..2 | 7..3 | 7..4 | p_min : 8×6 et 8×5 |
| HomogF, Alpha, BP, ExpVar, identifiabilité, Origine | n ≥ 3 | 7..3 | 7..3 | 7..3 | 7..4 | p_min de HomogF et d'ExpVar : 8×5 ; ensemble `origine_non_identifiables` : J−1 admissible en 8×6 et 8×5 |
| CorrDev (paires) | n ≥ 3 | 6..3 | 6..3 | 6..3 | 6..4 | p_min : 8×5 |
| Courbure, MinP4 | n ≥ 4 | 7..4 | 7..4 | 7..4 | 7..4 | aucun ; ensemble `non_identifiables` : J−1 admissible en 8×5 (même colonne 3 que le carré) |
| M6, extrapolation | J ≥ 3 | règle | règle + direct | règle + direct | règle + direct | champ d'information (§ 4) |
| M6, part de la dernière année ; lignes de famille | — | — | — | — | — | composition seule |

Les effectifs se déduisent de I et j ; les seuils ont été lus dans le code [V]. Ils ne sont pas exécutés sur un moteur généralisé [H].

## 8. (vii) Protocole de l'étude de niveau (fixé avant tout tirage)

**Statut épistémique**, à écrire en tête des sorties : constat de simulation sous un plan (modèle de Mack ajusté à `reserve2`, T = I + 1 = 8, lois N et E, B = 999), conditionnel à l'admission. Ce n'est pas un résultat général ; il ne se transpose ni à d'autres paramètres ni à d'autres géométries. Aucun théorème ne couvre ces tests bootstrap à T = 8.

**P1. Objet.**
- Script hors CI (nom sans `test_`), sur le code de l'étape 3 chargé par `charger_moteur()` ; calcule la sortie de la mesure 5 (b).
- Il reprend les générateurs, l'oracle, `taille_lissee()` et la règle bêta-binomiale de `tests/calibration_mc_mw_t8.R`, copiés ou mis en commun sans modifier ce script versionné.
- Admission : les erreurs de `mw_valider_triangle()` **hors le seul motif MW-04** (préfixe « Triangle non carre (»), puis `mw_valider_ajustement()`. Tout autre motif fait refuser le triangle, compté, sans retirage.
- Par triangle : `mw_ajuster()` → `.mw_ensembles_figes()` → `mw_bootstrap(B = 999)` → `mw_tests(alpha = 0,10)`, soit le chemin de `.run_engine_mw()`.

**P2. Plan (DGP).**
- Pour chaque géométrie G ∈ {8×5, 8×6, 8×7} (J = 4, 5, 6) : f_j et σ²_j de `mw_ajuster(reserve2)` pour j = 0..J−1. Tous sont des estimateurs directs du carré, puisque J−1 ≤ 5 [V, #206 § 2].
- Première colonne de `reserve2` fixée ; I = 7.
- Lois : **N** et **E** (pool redressé de `reserve2`, 27 valeurs divisées par l'écart-type de population, définition de #206 § 2). Loi A hors budget.
- Plan emboîté : pour une même graine, le trapèze G est la troncature du 8×8 simulé (même consommation des ε par colonne) [H, à contrôler : (g′)].

**P3. Graines** (toutes sous `engine_sous_graine()`), avec ℓ = 1 (N), 2 (E) et g = 1 (8×5), 2 (8×6), 3 (8×7) :

| Usage | Graine |
|---|---|
| triangle b | 567 000 000 + 100 000 (ℓ−1) + b, commune aux géométries |
| bootstrap | 568 000 000 + 1 000 000 (g−1) + 100 000 (ℓ−1) + b |
| oracle k | 570 000 000 + 100 000 (ℓ−1) + k (k ≤ 20 000) |
| pré-vol | 571 000 000 + k |

- Maximum : 571 100 000 < 2³¹ − 1.
- Plages disjointes de #206 et #297 (20 840 001-20 960 000), #305 (305·10⁶), #387 (387·10⁶ à 393,1·10⁶) et 360 380 123. Contrôle des littéraux au T0, comme pour #206.
- **2b (#610) doit éviter 567·10⁶ à 572·10⁶.**

**P4. Nombre de triangles et B.**
- B = 999 : donnée de la procédure.
- R = nombre de triangles **tirés**, fixé par le pré-vol et écrit au JOURNAL avant tout calcul. Aucune extension après lecture.

| Niveau | 8×5 (N, E) | 8×6 (N, E) | 8×7 (N, E) | Bootstraps | h CPU (16 s chacun) | Horloge à 4 processus (débit 3,92 à 2,72) |
|---|---|---|---|---|---|---|
| L0 | 2 000 | 2 000 | 1 000 | 10 000 | ≈ 44 | ≈ 11 à 16 h |
| L1 | 1 500 | 1 500 | 500 | 7 000 | ≈ 31 | ≈ 8 à 11 h |
| L2 (minimum) | 1 000 | 1 000 | 500 | 5 000 | ≈ 22 | ≈ 6 à 8 h |

- Oracle : N0 = 20 000 par (G, ℓ), soit environ 1 h CPU [H, 0,026 s par triangle mesuré en S5].
- Règle : premier niveau dont la durée planifiée tient dans **H_max = 20 h d'horloge sur 4 processus** (Q-2a-3).
- Tranches de 100, reprise selon M42 (b). Sous L2, retour au mainteneur.
- Le 8×7 est réduit parce que son niveau est attendu égal à celui de #297 (K-T6). Avec l'option (a), il repasse à R plein.
- Demi-largeur de l'IC à τ = 0,10 : environ 0,013 (n = 2 000), 0,019 (1 000), 0,027 (500).

**P5. Erreurs, séparées.**
1. Erreur Monte-Carlo de τ, fonction de R : IC de Clopper-Pearson.
2. err_mc de chaque p, fonction de B, intégrée à la procédure et à ρ.
3. Erreur de ρ due à N0 : environ 0,002 [H, #206].
4. Écart τ − ρ : **l'objet mesuré**, erreur à T = 8 du test bootstrap à paramètres estimés.
5. Erreur de substitution (plan et loi au lieu de la vérité) : non quantifiée.

**P6. Contrôles d'intégrité** (`INTEGRITE OK` ou `INTEGRITE ECHEC` en dernière ligne de console) :
- (1) md5, SHA et empreinte #231 constants.
- (a) `reserve2` contre `reserve2.rds` au seuil 0 : chemin carré intact.
- (m4) `run_engine()` sur un 8×7 rend `ok = FALSE` avec MW-04 seul : la garde est en place.
- (g) le générateur du script est `identical()` à `.mw_simuler_triangle_etat()`.
- (g′) troncature du 8×8 = trapèze, sous la même graine.
- (c1) C1 sur le premier triangle admis de chaque tranche.
- (r297) p_mc des lignes b = 1 et 2 du brut de #297, N et E, reproduites `identical()`. La synthèse de S5 l'atteste à `c8840d4` (13 clés sur 13).
- (o) observées du 8×7 tiré de `reserve2` `identical()` aux `stats_obs` de `reserve2.rds`, 13 clés (sous (c)).
- (t) critère du § 8 présent à l'identique dans le rapport versé.
- Après D2 : 20 triangles par géométrie repassés par `run_engine()`, `identical()` (étape 6).

**P7. Critère**, à reporter sans modification :

> **Critère.** D = 1 si p_mc < α, α ∈ {0,10 ; 0,05} ; une p absente compte comme un non-rejet, comptée à part. τ = k/n sur les triangles admis, IC de Clopper-Pearson à 95 %. Référence ρ(s, α, G, ℓ) : taille lissée du test de Monte-Carlo idéal à B = 999 sur l'oracle de (G, ℓ) (règle de #206 § 4). Classes de #166 et #206, bande fermée [ρ/2 ; 3ρ/2] : compatible ; écart mineur ; non tranché ; distorsion matérielle libérale ou conservatrice ; valeurs non arrondies ; un non tranché reste non tranché.
> - **K1** (principal) : classe des 13 clés de `MW_CATALOGUE_MC` par (G, ℓ, α), G ∈ {8×5, 8×6}.
> - **K-T6** (contrôle d'implémentation, sous (c)) : pour 8×7, classes K1 ; et, par clé et par α, test exact de Fisher bilatéral de τ(8×7) contre τ(8×8, #297, même loi), Holm sur 13 à 0,05.
> - **K3** : témoin oracle, règle bêta-binomiale du 05/11/2026, Holm sur 13.
> - **K4** : p absentes au plus 1 % par (G, ℓ) ; refus au plus 1 %.
> - **K5** (descriptif) : B effectif, motifs ; part des lignes inopérantes (champ `inoperant` de `mw_tests()`) et des statistiques NA par clé et par G.
> - **K-T4** (descriptif, sans critère) : distribution de σ̂²_{J−1} de la règle / σ²_{J−1} vrai et de σ̂²_{J−1,dir} / σ²_{J−1} vrai (vrais : 0,31478 ; 0,097325 ; 0,18967 pour 8×5, 8×6, 8×7) ; rapport des √MSEP règle / direct ; taux de M4.
> - **K-T7** (descriptif) : niveau des p de famille et de la p globale (`engine_p_famille()`).
>
> **Profils pour D2** (`actuary` propose, le mainteneur tranche ; ordre Θ0, Θ5, Θ4, Θ3, Θ2, Θ1) :
>
> | Profil | Condition | Lecture proposée |
> |---|---|---|
> | Θ0 | intégrité, K3 ou K4 en défaut ; ou K-T6 significatif, non expliqué | lecture suspendue ; implémentation à revoir |
> | Θ5 | une clé en distorsion de côtés opposés entre N et E pour une G | niveau non robuste à la loi : documenter ; décision du mainteneur pour la clé |
> | Θ4 | distorsion matérielle libérale d'une clé sur 8×5 ou 8×6, pour une loi | les ALERTE et ECHEC de la clé sur cette géométrie surestiment la preuve. Options : extension avec la clé en diagnostic sur la géométrie, ou refus maintenu. Si la même distorsion existe sur le 8×8 (#297), elle n'est pas propre au trapèze et se lit comme telle |
> | Θ3 | distorsion matérielle conservatrice sur une clé | extension possible ; OK de la clé = preuve faible, écrit par géométrie |
> | Θ2 | aucune distorsion, des non tranchés | extension possible, IC documentés |
> | Θ1 | 13 clés compatibles ou en écart mineur sur 8×5 et 8×6, N et E, aux deux seuils, et K-T6 sans signal | niveau comparable au carré ; le volet « tests » ne s'oppose pas à l'extension |

**P8. Sorties** : `docs/tableaux/<aaaammjj>-issue567-niveau-trapeze-mw.md`, `-brut.tsv` (`%.17g`) et `-journal-mesure.md` ; la confrontation dans `-issue567-msep-trapeze.md`. Critères de #242 ; `--ecrire` exige un commit propre.

## 9. (viii) Cas par géométrie et par chemin

**Géométries**
- **Carrés, identiques au bit** : les six références (seuil 0 et `identical()`), 5×5, 8×8 (`triangle_mw`), GenIns 10×10.
- **Trapèzes à T = 8** : 8×7, 8×6, 8×5 (troncatures de `triangle_mw`).
- **Bornes** : 6×5 (I−J = 1, T = 6) ; 10×5 (I−J = 5) ; GenIns 10×9, 10×7, 10×5 (valeurs C1 du § 1.3).
- **Refus inchangés** : 5×6 (MW-03 seul) ; D(2)(b) et D(2)(c) (8×4, 4×4) ; cellule observée manquante dans un trapèze.

**Cas spéciaux sur trapèze**
- (s1) colonne J−1 dégénérée : σ̂²_dir = 0, J−1 dans jd, aucun résidu, M6 affiche 0.
- (s2) σ̂²_{J−3} = 0 : règle à 0 (existant).
- (s3) R̂ ≤ 0 : M4.
- (s4) ligne i ≤ I−J à cumul décroissant : avertissement gardé, réserve de la ligne `identical(0)`.
- (s5) colonnes 0..J−2 dégénérées et J−1 non : refus « totalement dégénéré » gardé ; le prédicat reste sur 0..J−2, puisque la règle rend la MSEP nulle.
- (s6) noms de ligne.
- (s7) cellules sous la diagonale : avertissement, NA.
- (s8) Ĉ(i,J) = C(i,J) et contributions nulles pour i ≤ I−J (`mw_contributions()`, `mw_plots_data()`).

**Chemins**
- P1 : fonctions internes par `charger_moteur()` (étape 3 ; tous les cas ci-dessus) ;
- P2 : `run_engine()`, qui refuse MW-04 jusqu'à D2 puis calcule (tableau avant / après) ;
- P3 : `engine_lire_triangle()`, CSV et xlsx, section 7ter non touchée ;
- P4 : grille de l'application (étape 6) ;
- P5 : réplications du bootstrap. `.mw_triangle_incomplet()` est généralisé sur i + j ≤ I ; même ensemble de cellules pour un carré, contrôle des tests seulement ;
- P6 : `mw_sensibilite_sigma2_dernier()` sur trapèze ;
- P7 : identité (o) du § 8, à tester en 3.

**Commentaires du moteur devenus faux, à corriger en 3 ou 6** : l. 13064-13076 ; l. 13416-13417 (« impose … I = J ») ; l. 14292-14295 ; l. 15939-15944.

## 10. (ix) Domaine de `engine_lire_triangle()`

- Le lecteur n'a **aucun refus « non carré » propre** [V].
  - Le motif vient de `mw_valider_triangle()` (MW-04, l. 13148-13154), appelée en fin de lecteur (l. 8848, `v <- mw_valider_triangle(m)`).
  - Les commentaires des l. 8205 et 8261 citent ce motif comme effet aval : règle R-a du bord gauche, et en-têtes romains de #568.
- Après D2, le domaine du lecteur suit celui de `mw_valider_triangle()`, sans code propre. Les deux commentaires sont à reformuler à l'étape 6.
- **Risque nouveau** [V, raisonnement sur la structure i + j ≤ I] : un carré dont la dernière colonne a été perdue est un trapèze recevable, indiscernable d'un vrai trapèze. MW-04 l'arrêtait de fait (Q-2a-6).

**Budget de calcul** [V, mesuré ce jour] : R 4.3.3, Linux, 4 cœurs ; sur `reserve2`, `mw_bootstrap()` à B = 999 en 13,76 s, `mw_tests()` en 2,18 s, `mw_ajuster()` en 0,1 ms. Le coût d'un trapèze est attendu inférieur [H]. Le pré-vol de l'étape 4 ou 5 fait foi. Durées : § 8, P4.

## 11. Questions pour le mainteneur (avant D1', sauf mention)

- **Q-2a-1, colonne J−1.** *Recommandation* (c). *Écartées* : (a) et (b) (§ 2).
- **Q-2a-2, simulation de la colonne J−1.** *Recommandation* : σ de la règle, sans changement. *Écartée* : estimateur direct (§ 3). σ_boot et l'intervalle d'un trapèze en dépendent ; ils seront visés à D2.
- **Q-2a-3, budget de 5 (b).** *Recommandation* : H_max = 20 h sur 4 processus, en tranches, échelle L0 à L2 avec le 8×7 réduit (contrôle K-T6), niveau choisi par le pré-vol. *Écartées* : R plein sur le 8×7 (environ 4 h de plus, redondant sous (c)) ; une seule loi (le niveau dépend de la loi, #206).
- **Q-2a-4, contenu de M6.** *Recommandation* : σ̂²_dir et ses degrés de liberté, pour information, sans σ ni √MSEP alternatifs. *Écartée* : √MSEP contrefactuelle (précédent Q-D1-Fm-7).
- **Q-2a-5, `CL_MSEPs`.** *Recommandation* : lue depuis l'archive CRAN (md5 fixé) par les scripts hors CI, valeurs écrites en dur dans les tests unitaires. *Écartée* : copie dans `tests/` (code GPL dans le dépôt).
- **Q-2a-6 (pour D2 et l'étape 6), garde contre une colonne perdue.** *Recommandation* : avertissement non bloquant sur tout trapèze. Il nomme la géométrie et demande de vérifier qu'aucune colonne de développement ne manque. Il déclare l'hypothèse « aucun développement au-delà de J » pour les années 0..I−J (D(2)(d), justification à l'entreprise). *Écartée* : refus (il rétablirait la lecture (A)).

**Points d'arrêt** : D1' (décisions ci-dessus ; engagement de l'étape 3), puis D2. Aucun nouveau point d'arrêt.

## Retour

- **Statut** : `revue requise`. La spécification est complète ; Q-2a-1 à Q-2a-6 relèvent du mainteneur.
- **Résultat** : spécification D1, points (i) à (ix) et budget. La MSEP restreinte est confrontée à l'implémentation de l'auteur (ChainLadder 0.2.21), à 2,2e-16 près, sur six trapèzes et deux carrés (prototype hors moteur). Option (c) pour la colonne J−1, protocole de niveau et critère fixés avant tout tirage.
- **Preuves**
  - *Vérifiées* :
    - source ChainLadder 0.2.21 lue (`CL_MSEPs`, `checkTriangle`, `Mack.S.E`) et prototype exécuté ;
    - concordance avec les σ du script de `regulatory` ;
    - code du moteur lu : l. 13126-13154, 13365-13443, 13732-13767, 14127, 14296-14325, 15887-15982, 16057-16164, 17492-17732, 17913-17922 ; seuils de colonne ; signatures de p_min ; `engine_lire_triangle()` l. 8727-8851 ;
    - coûts mesurés ;
    - valeurs du plan de #206 (spécification, § 2) ;
    - lecture de `regulatory` (`804a45b`).
  - *Hypothèses* :
    - identité au bit (o) et invariance d'échelle par colonne (raisonnement) ;
    - troncature (g′) ;
    - coût d'un trapèze inférieur à celui du carré ;
    - débit à 4 processus et coût de l'oracle.
  - *Non vérifiés* :
    - formule imprimée pour I > J (Wüthrich et Merz 2008, Wiley ; Merz, Wüthrich et Lysenko 2009) ;
    - C2 (ChainLadder non installé) ;
    - comportement de l'estimateur direct hors normalité.
- **Informations manquantes** : `core.ac.uk` et `www.research-collection.ethz.ch` sont à autoriser dans les réglages réseau de la session pour la recherche de source (sinon Q-63-10). L'accès en lecture de la session GitHub au dépôt `mages/ChainLadder` a été refusé ; CRAN a suffi.
- **Décisions non résolues** : Q-2a-1 à Q-2a-6 (mainteneur) ; D1' et D2.
- **Critères déclenchés** :
  - correction de mon propre avis du 12/11 (sens du biais de la règle), sans désaccord avec `regulatory`, dont je partage les cinq points ;
  - changement de σ_USP et de verdicts sur une classe d'entrées (après D2, visa) ;
  - validité à T = 8 des tests sur 8×5 et 8×6, qu'aucune simulation ne tranche encore (étape 5 (b)) ;
  - le critère Fable du plan (« par raisonnement seul ») tombe dès que 5 (a) reproduit C1 sur le moteur.
- **Constats hors périmètre** : aucun qui relève de l'ADR 0018. Les commentaires périmés du moteur (§ 9) sont dans le périmètre de #567. L'intitulé imprécis de #567 (« lecture B de D(2)(e) ») est déjà relevé par `regulatory`.
- **Prochaine action recommandée** : la session verse ce rapport dans `docs/revues/20261120-s6-trapeze/`, porte Q-2a-1 à Q-2a-6 au mainteneur à D1', transmet la plage de graines réservée à 2b (#610), puis lance l'étape 3 (`coder-approfondi`, `high`) avec C1 et (o) comme critères d'acceptation.

Sources web consultées : [CAS E-Forum, Merz et Wüthrich (2008)](https://www.casact.org/pubs/forum/08fforum/21merz_wuetrich.pdf) (non relu ce jour) ; [index CRAN des sources](https://cran.r-project.org/src/contrib/) (ChainLadder_0.2.21.tar.gz).
