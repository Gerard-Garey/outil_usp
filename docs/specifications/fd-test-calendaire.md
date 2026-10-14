# Spécification de Fd : test calendaire de Mack (#276, #275, #268)

> *Rédigé par l'agent actuary (IA).* Le 14/10/2026, sur demande de la session principale, en exécution de la décision Q-P-4 du mainteneur : la branche Fd s'ouvre en parallèle de Fb à la fusion de F, **à condition** que la présente spécification soit versionnée sous `docs/specifications/` par un commit `docs:` de la branche F. Périmètre fixé par Q-P-4 et Q-P-5 : #276, #275 et #268, plus les deux facultatifs de #201 rattachés à #275 (commentaire `6170671455`, Q-F-10). La spécification est soumise au point d'arrêt **D1-Fd** : aucun code de Fd avant la décision du mainteneur sur les questions Q-Fd-1 à Q-Fd-11 (fin du document). Les décisions seront reportées en annotation datée, en fin de document.

**Marques** : **[V]** vérifié (source citée, ou commande exécutée et sortie lue) ; **[H]** hypothèse ; **[NV]** non vérifié.

## 0. Objet, sources, mesures, décisions déjà prises

**Objet.**
- **#276** : forme unilatérale de la statistique globale Z du test calendaire (ligne M3 « Effets d'annee calendaire (test de Mack) »). Lecture de H1, niveau et puissance sous le bootstrap du moteur, puis passage éventuel de la queue « deux » à « bas ».
- **#275** : restitution par diagonale (repère de Mack 1997), sans verdict.
- **#268** : noms de ligne du triangle refusés par `mw_valider_triangle()` avec un motif métier, et non par une erreur R interceptée.
- **Facultatifs de #201** (commentaire `6170671455` de #275) : comparaison Mack 1994 / D6 pour la fiche `mw:m3cor` ; forme qualifiée « non étudiée » à inscrire dans `docs/latex/CONVENTIONS.md`.

**Sources lues** **[V]** :
- Issues #276, #275 et son commentaire `6170671455`, #268 ; fil de #201, commentaires `6085972344`, `6154023807`, `6154082885`, `6154356870`.
- `R/engine.R` de `main` `553fa5e` (lu par `git show origin/main:R/engine.R`, le `coder` de #278 modifiant la zone Merz-Wüthrich de l'arbre de travail de F) :
  - `engine_p_mc()` (l. 3657), règle des verdicts d'`add()` (l. 4192 : ECHEC si p < α/2, ALERTE si p < α) ;
  - `mw_valider_triangle()` (l. 7012), `mw_parametre()` (l. 7746), `.mw_noms_lignes_empilees()` (l. 7803) ;
  - `.mack_moments_Z()` (l. 7929), `mw_test_annees_calendaires()` (l. 7948) ;
  - `.mw_calendrier_p_min()` (l. 8839), `.mw_p_min_ligne()` (l. 8937) ;
  - `mw_bootstrap()` (l. 9093), `.mw_calendrier_extremes()` (l. 9202), entrée `Calendrier` de `MW_CATALOGUE_MC` (l. 9240) ;
  - ligne M3 de `mw_tests()` (l. 9555-9573).
- Arbre de travail de F (tête `40c99ce`, modifications non commitées de #278) : l'entrée `Calendrier` y passe à `e$figes$degeneres` et `mw_tests()` reçoit `figes` ; la statistique, la queue et les extrémités ne changent pas. Fd part de `main` après la fusion de F : la présente spécification vaut pour cette forme.
- `tests/reference/reserve2.rds` (ligne 9 de `res$tests`, `bootstrap`, `parametre_final`).
- `docs/latex/doc_tests_usp.tex` (identique sur F et sur `main` : `git diff origin/main --stat -- docs/latex/ CONTEXT.md` vide) : fiche `mw:m3cal` (l. 13586-13744), index des fonctions (l. 2263-2266), `tab:nature` (l. 5606), `tab:conv` (l. 5885), `tab:pmin` (l. 6145-6152, 6184-6202), `tab:tracabilite-puissance` (l. 6556), section « Nature des p-values », règle R1 (l. 4795-4850), liste des lignes (l. 12470), l. 12500, calibration asymptotique (l. 15080), calibration Monte-Carlo (l. 15224, 15254), bibliographie (l. 15937-15943), limites (l. 16030-16036), seuils en T (l. 16349-16355).
- `CONTEXT.md` (« Test inopérant », « Plancher Monte-Carlo (p_min_mc) ») ; `docs/latex/CONVENTIONS.md` (l. 24-25) ; `docs/tableaux/20261011-issue206-calibration-mw.md` (T0, lignes `Calendrier`).
- Annexe XVII, section D, point (2)(h), version consolidée du 14.11.2024 (texte, pas une formule ; lu dans le fichier `.xhtml` du dépôt) : « i. les montants de sinistres cumulés des différentes années d'accident sont stochastiquement indépendants les uns des autres ».
- Modèle de forme : `docs/specifications/e2e-niveaux-et-documentation.md`.

**Sources non relues ici** **[NV]** : Mack (1994, *CAS Forum*, annexe H) et Mack (1997, *Claims Reserving Manual*, D6). Les PDF ne sont pas dans le dépôt (droits de la CAS) ni accessibles depuis la session. Toute citation de ces textes reprend **mot pour mot** la lecture consignée dans les commentaires `6154023807` et `6154356870` de #201, faite en rendu graphique par `actuary-approfondi` le 13/10/2026, et déjà reportée dans la fiche `mw:m3cal`. Aucune page ni phrase n'est ajoutée ici. Les implémentations logicielles du test (paquet R ChainLadder, `cyEffTest()` ; paquet Python chainladder) n'ont pas pu être consultées : l'accès réseau est refusé. Leur forme, uni- ou bilatérale, n'est pas connue.

**Mesures** **[V]** : `Rscript` (R 4.3, `LC_ALL=C.UTF-8`), moteur de `main` `553fa5e` chargé par `sys.source()`. Scripts de session, non versionnés (scratchpad), décrits au § 2.3 : `commun.R`, `pilote.R`, `pilote2.R`, `analyse.R`, `oracle.R`, `sous5.R`, `table97.R`.

**Décisions déjà prises, non rouvertes** :
- Q-201-1 option A : le moteur garde la procédure de 1994 (statistique globale) ; la D6 n'est pas retenue (repondération contraire à D(4)(c)) ; la restitution par diagonale est un **diagnostic** (#275).
- Q-201-2 : source et commentaires corrigés dans E2e.
- Q-201-3 : forme unilatérale étudiée dans #276.
- Q-P-4 : Fd ouverte en parallèle de Fb, sous condition de la présente spécification.
- Q-P-5 : #268 passe de Fc à Fd.
- Règle #76 et son exception bornée ; ADR 0001 (aucun repli sur la loi nominale) ; ADR 0003 (catalogue, `add()`, `p_min_mc`).

## 1. #276 : lecture de H1

### 1.1 Ce que teste la ligne

- **Hypothèse visée** : D(2)(h)(i), indépendance stochastique des années d'accident **[V]**. La ligne la teste contre une alternative particulière, l'**effet d'année calendaire** : un choc commun à tous les paiements d'un exercice comptable.
- **Base** : facteurs individuels F(i,j) = C(i,j+1)/C(i,j). Ils sont étiquetés L ou S par rapport à la médiane de leur colonne (« * » pour la valeur égale à la médiane et pour les colonnes dégénérées figées) et regroupés par diagonale k = i + j (`mw_test_annees_calendaires()`, champ `diag`). Le facteur F(i,j) contient les paiements de l'exercice i + j + 1 au numérateur, et ceux des exercices antérieurs au dénominateur.
- **Statistique** : Z = Σ_k min(L_k, S_k) sur les diagonales à n_k ≥ 2, centrée-réduite par les moments exacts (H1) et (H2) de Mack. À n_k fixés, c'est une fonction affine de Z.

### 1.2 Sens d'un effet calendaire sur Z

**Mécanisme** (raisonnement, **[H]** au sens où il n'est tiré d'aucune source). Un choc multiplicatif 1 + θ sur les paiements de l'exercice t :
- augmente tous les facteurs F(i, t − 1 − i) de la diagonale k = t − 1, qui deviennent à dominante L ;
- diminue un peu ceux de la diagonale k = t, dont le dénominateur est gonflé : dominante S, effet plus faible ;
- concentre donc les étiquettes et **fait baisser Z**.

Une dérive (inflation surajoutée croissante à partir d'un exercice) donne des diagonales successives à dominante L : Z baisse aussi. Une inflation constante n'est pas visible : elle se factorise en un effet d'année d'accident et un effet de développement, que la méthode de la chaîne absorbe.

**Mack (1994)**, tel que lu dans #201 **[NV ici]** :
- p. 164 : l'alternative est unilatérale ; il y a soupçon d'effet calendaire si Z_j est « significantly smaller than (L_j+S_j)/2 » ;
- p. 166 : la règle de décision est bilatérale, rejet hors de E(Z) ± 2√Var(Z), « error probability of 5 % ».

La lecture consignée ne rapporte aucune motivation du côté haut, et je n'en vois pas dans le mécanisme. La règle de la p. 166 se lit comme un intervalle conventionnel à ± 2 écarts-types.

**Un Z grand n'est pas sans interprétation**, et il faut le dire.
- Z grand signifie des diagonales plus équilibrées que le hasard.
- Un mécanisme possible : une **compensation entre années d'accident voisines dans un même exercice**, par exemple une réaffectation de paiements d'une année d'accident à la suivante. Elle alterne les L et les S le long de la diagonale.
- C'est une dépendance entre années d'accident, contraire elle aussi à D(2)(h)(i), mais **ce n'est pas un effet calendaire** au sens de la ligne (champ H1 : « inflation, changement de cadence »).
- Aucune source lue ne propose Z comme test de cette alternative.
- Sa puissance contre elle n'est pas mesurée (§ 2.2, cellule interrompue).

**Conclusion (avis)** :
- La forme unilatérale (queue basse) est **le test de l'alternative que la ligne annonce et que Mack énonce p. 164**.
- La forme bilatérale consacre la moitié du risque de première espèce à une alternative que la ligne n'annonce pas.
- Le pilote mesure ce coût : à taille égale, la forme unilatérale double ou presque la puissance contre les trois scénarios calendaires mesurés (θ = 0,10 ; g = 0,05 ; § 2.2).
- Ce que la forme unilatérale abandonne, le côté haut, est à écrire dans la fiche comme **hypothèse non testée** : la compensation entre années d'accident d'une même diagonale.
- **Littérature** : aucune source vérifiée ne compare à T = 8 les deux formes du test de Mack. Aucun résultat d'optimalité n'est invoqué. Le choix repose sur la lecture de H1 et sur la mesure, et la fiche le dira ainsi.

**Verdict sur la ligne M3 calendaire** : **à compléter** dans sa forme actuelle, la forme bilatérale ne testant pas exactement son H1. **Pertinent** sous la forme unilatérale, sous réserve du critère K1 de la mesure versionnée (§ 2.3).

### 1.3 Ce que la forme unilatérale change dans le moteur (D1-Fd, Q-Fd-1 et Q-Fd-3)

1. **`MW_CATALOGUE_MC`, entrée `Calendrier`** : `queue` passe de `"deux"` à `"bas"`. La fermeture `calc` et `extremes` ne changent pas. `.mw_calendrier_extremes()` rend toujours `c(bas, haut)` ; seul `bas` est lu en queue basse, ce qu'`engine_p_mc()` fait déjà.
2. **p-value asymptotique** (`mw_test_annees_calendaires()`, champ `p`) : `2 (1 − Φ(|Z*|))` devient **`Φ(Z*)`**, soit `stats::pnorm(st)` sous `.p_borne()` (Q-Fd-3). Sans ce changement, deux colonnes de la même ligne testeraient deux alternatives différentes.
3. **`p_min` sous la loi binomiale indépendante de Mack** (`.mw_calendrier_p_min()`) : `min_z 2 min(P(Z ≤ z), P(Z ≥ z))` devient **`min_z P(Z ≤ z) = P(Z = 0) = Π_k 2^(1 − n_k)`**. Recommandation : garder la convolution, prendre la masse cumulée à gauche, et ajouter la forme close en test unitaire.
   - Propriété démontrable : pour tout n ≥ 2, P(Z_k = 0) = 2^(1−n) ≤ P(Z_k = ⌊n/2⌋), avec égalité seulement à n = 2.
   - L'atome bas est donc toujours le moins lourd des deux, et la `p_min` unilatérale vaut **exactement la moitié** de la `p_min` bilatérale actuelle, pour toute configuration **[V]** (énumération, `table97.R`).
4. **Ligne M3 de `mw_tests()`** :
   - `H1 = "Z trop petit : une ou plusieurs diagonales a dominante L ou S (inflation, changement de cadence)"` ;
   - `loi = "N(0,1) approx., queue basse ; moments EXACTS de Z = min(L, n-L)"`.
   - `H0`, `stat_nom`, `stat`, `estim`, `detail`, `sens`, `reference` et `fonction` sont inchangés.
5. **Inchangés** : `add()`, `engine_registre_tests()`, `engine_p_mc()`, `.mc_entree()`, la statistique, les étiquettes, le flux de tirages de `mw_bootstrap()`, σ_USP.
   - Aucun contrat partagé n'est touché, ce qui est une condition du parallélisme avec Fb.
   - Si `coder` estime devoir toucher l'un de ces objets : **arrêt** et retour à la session principale.
6. **Commentaires du moteur** : en-têtes de `mw_test_annees_calendaires()`, de `.mw_calendrier_p_min()` (« Effet calendaire (bilateral) ») et du catalogue. Ils doivent dire « queue basse (Mack 1994, p. 164) » et que la règle bilatérale de la p. 166 n'est pas suivie.

## 2. #276 : niveau et puissance sous le bootstrap du moteur

### 2.1 Pilote, sur le cas de contrôle `reserve2` **[V]**

Reproduction de la boucle de `mw_bootstrap()` de `main` (même graine 20260831, même pool, même `.mw_tirer_triangle_valide()`, statistique calendaire seule) ; les deux p sont calculées par `engine_p_mc()` sur les **mêmes** réplications.

| Grandeur | Moteur actuel (`reserve2.rds`) | Reproduction, « deux » | Reproduction, « bas » |
|---|---|---|---|
| stat (Z*) | −3,5403 | −3,5403 | −3,5403 |
| Z ; E(Z) | 2 ; 7,375 | 2 ; 7,375 | 2 ; 7,375 |
| n_k | — | 2, 3, 4, 4, 6, 5 | idem |
| p_mc | 0,004 | 0,004 | **0,002** |
| p_min_mc | 0,002 | 0,002 | **0,001** |
| B_eff | 999 | 999 | 999 |

La reproduction redonne la référence à l'identique : contrôle de type (i2).

**Sous-triangle 5 × 5** du triangle de contrôle (celui de la fiche, l. 13735-13742 et 4840-4850 du `.tex`), n_k = 3, 3 :

| B | p_mc deux | p_mc bas | p_min_mc deux | p_min_mc bas | p_min (loi binomiale) deux → bas |
|---|---|---|---|---|---|
| 999 | 0,096 | **0,048** | 0,096 | **0,048** | 0,125 → 0,0625 |
| 99 | 0,10 | **0,05** | 0,10 | **0,05** | idem |

### 2.2 Pilote sous un plan **[V]**, constat de simulation, scripts non versionnés

**Plan** :
- modèle de Mack ajusté à `reserve2`, première colonne fixée, f̂ et σ̂² de `mw_ajuster()` (DGP de #206) ;
- lois des erreurs N (`rnorm`) et E (pool redressé normé, comme #206) ;
- triangle refusé si un cumul est ≤ 0 ou si `mw_ajuster()` échoue (aucun refus constaté) ;
- B = 999 par triangle, graines du pilote hors des plages de #206.

**Alternatives** : effet multiplicatif sur les **incréments** de l'exercice t = i + k, appliqué au triangle simulé sous H0, puis recumulé :
- **dernier** : t = 7, facteur 1 + θ ;
- **médian** : t = 4, facteur 1 + θ ;
- **dérive** : facteur (1 + g)^max(0, t − 3) ;
- **compensation** (alternative du côté haut) : t = 6, facteur 1 + (−1)^i θ, alterné selon l'année d'accident.

Les taux sont des proportions de p < seuil, avec IC de Clopper-Pearson à 95 %. « 97 » désigne la part des triangles où au moins une diagonale a P(Z_k ≤ z_k) ≤ 10 % (règle de Mack 1997 appliquée à toutes les diagonales, sans correction).

**Résultats partiels** : la session a été arrêtée avant les cellules θ = 0,05, g = 0,03, « compensation » et l'oracle, qui restent à la mesure versionnée (§ 2.3). Le tableau ne donne que les cellules terminées.

| Cellule | Loi | R | « deux » à 0,10 | « bas » à 0,10 | « deux » à 0,05 | « bas » à 0,05 | Discordantes à 0,10 (bas seul / deux seul) | « 97 » |
|---|---|---|---|---|---|---|---|---|
| H0 | N | 1 000 | 0,090 [0,073 ; 0,109] | 0,092 [0,075 ; 0,112] | 0,048 [0,036 ; 0,063] | 0,037 [0,026 ; 0,051] | 55 / 53 | 0,099 |
| H0 | E | 500 | 0,110 [0,084 ; 0,141] | 0,100 [0,075 ; 0,130] | 0,046 [0,029 ; 0,068] | 0,048 [0,031 ; 0,071] | 26 / 31 | 0,100 |
| Dernier, θ = 0,10 | N | 400 | 0,235 [0,194 ; 0,280] | **0,4025** [0,354 ; 0,452] | 0,160 [0,125 ; 0,200] | 0,235 [0,194 ; 0,280] | 67 / 0 | 0,530 |
| Médian, θ = 0,10 | N | 400 | 0,1675 [0,132 ; 0,208] | **0,3125** [0,267 ; 0,360] | 0,1025 [0,075 ; 0,136] | 0,1625 [0,128 ; 0,202] | 60 / 2 | 0,1875 |
| Dérive, g = 0,05 | N | 400 | 0,105 [0,077 ; 0,139] | **0,200** [0,162 ; 0,243] | 0,0725 [0,049 ; 0,102] | 0,0975 [0,070 ; 0,131] | 41 / 3 | 0,2375 |

Sous H0 et sous les trois alternatives mesurées, p_min_mc vaut au plus 0,002 en « bas » et 0,004 en « deux ». Aucun cas n'atteint α/2. La moyenne des statistiques simulées est nulle à 0,003 près (bootstrap centré).

**Lecture** :
- **Niveau** : sous N et E, la forme « bas » rejette au voisinage du seuil à 0,10. À 0,05 sous N (0,037), elle est sous le seuil, effet attendu de la discrétude : la statistique a peu de valeurs, et un atome de Z se partage moins bien d'un seul côté. La référence oracle ρ_bas n'a pas été calculée au pilote : la classe de #166 n'est donc pas attribuée, et elle relève de la mesure versionnée.
- **Puissance** : contre les trois alternatives calendaires, la forme « bas » rejette nettement plus que la forme « deux » à taille égale. Les paires discordantes vont presque toutes dans le même sens (McNemar). Contre la dérive à g = 0,05, la forme « deux » est à peine au-dessus de son niveau, et la forme « bas » le double environ.
- **Ce qui est abandonné** : la puissance contre la compensation (§ 1.2) n'a **pas** été mesurée au pilote (cellule interrompue). Par construction, la forme « bas » ne rejette pas du côté haut. La mesure versionnée chiffre ce que la forme « deux » y détecte.
- **Règle de 1997 appliquée à toutes les diagonales** : à T = 8, sous H0, elle signale au moins une diagonale dans environ 10 % des triangles du plan. Peu de diagonales peuvent descendre à 10 % : il faut n_k ≥ 5, soit 2 ou 3 diagonales sur 6 dans le plan. Sa puissance est du même ordre que celle de la forme « bas », plus grande contre un choc sur la dernière diagonale (longue) et plus petite contre un choc sur une diagonale courte (n_k = 4, qui ne peut pas descendre sous 12,5 %). Ce constat nuance le motif (ii) de Q-201-1 (« ne maîtrise pas la multiplicité ») : dans ce plan, la multiplicité reste faible, **parce que** la plupart des diagonales ne peuvent rien signaler. Il ne se transpose ni à un triangle plus grand ni à un autre plan. Il ne change pas la décision Q-201-1, dont le motif (i) suffit pour la repondération, mais il est à écrire dans la fiche du diagnostic (§ 3). Voir aussi la proposition hors Fd du § 3.6.
- **Statut** : pilote non versionné, R ≤ 1 000 triangles par cellule, plan unique. Il ne peut pas être cité dans le `.tex`. La mesure versionnée du § 2.3 le remplace.

### 2.3 Protocole de la mesure versionnée (étape 2 de Fd ; Q-Fd-2)

**Outil** : script hors CI, `tests/mesure_calendaire_t8.R` (nom indicatif).
- Même statut que `tests/calibration_mc_mw_t8.R` : il n'est lancé ni par la CI ni par les batteries, ne modifie ni le moteur ni les références, utilise R base + stats (et `parallel`, livré avec R, ou un découpage en tranches).
- Il réutilise autant que possible l'outillage de #206 : provenance, empreintes, tranches, combinaison, recherche de collisions de graines.
- Sortie : `docs/tableaux/AAAAMMJJ-issue276-calendaire.md`, avec les valeurs brutes `-brut.tsv`.

**Calcul par triangle.**
- Reproduction de la boucle de tirage de `mw_bootstrap()`, statistique calendaire seule, ensembles figés de `.mw_ensembles_figes(aj)` (forme de F).
- p_mc « deux » et « bas » par `engine_p_mc()` sur les mêmes réplications ; p_min_mc des deux formes ; p asymptotiques `2(1 − Φ(|Z*|))` et `Φ(Z*)`.
- Z, n_k ; nombre de diagonales à P(Z_k ≤ z_k) ≤ 10 % ; B_eff.

**Plan** : DGP de #206 (§ 2 de sa spécification), sans changement.

| Cellule | Lois | R | Seuils |
|---|---|---|---|
| H0 | N, E | 2 000 chacune | 0,10 et 0,05 |
| H0 | A | 1 000 | 0,10 et 0,05 |
| Dernier exercice (t = 7) | N | 1 000 par θ ∈ {0,05 ; 0,10} | 0,10 et 0,05 |
| Exercice médian (t = 4) | N | 1 000 par θ ∈ {0,05 ; 0,10} | 0,10 et 0,05 |
| Dérive à partir de t = 4 | N | 1 000 par g ∈ {0,03 ; 0,05} | 0,10 et 0,05 |
| Compensation (t = 6, alternée) | N | 1 000, θ = 0,10 | 0,10 et 0,05 |

**Oracle** :
- N0 = 20 000 triangles par loi sous H0, avec la statistique observée de chacun.
- Référence ρ de la règle de #206 (taille lissée à B = 999), calculée pour « bas » et pour « deux ».
- Rapporter le nombre de valeurs distinctes et la masse du plus gros atome.

**Graines** : plages disjointes de celles de #206 (20 840 001-20 960 000) et de tous les littéraux du dépôt, vérifiées par la recherche de collisions de #206 ; toutes sous `engine_sous_graine()`.

**Contrôles** :
- (a) `reserve2` reproduit `reserve2.rds` (p_mc et p_min_mc « deux ») ;
- (i2) sur `reserve2` et sur un triangle sur 50 du plan, la p « deux » du script est **identique** à `mw_bootstrap(aj, 999, graine)$p_mc["Calendrier"]` du moteur, et sa p_min_mc à celle du moteur ;
- (i2′), à lancer par `audit` **après** l'étape 3 : la p du moteur modifié est identique à la p « bas » du script, sur les mêmes triangles.

**Sorties** :
- T0 provenance ;
- T1 niveau sous H0 (loi × forme × seuil ; taux, IC, ρ, classe de #166) ;
- T2 puissance (scénario × forme × seuil ; taux, IC, paires discordantes, McNemar exact) ;
- T3 taux de la règle de 1997 sur toutes les diagonales, sous H0 et sous chaque alternative (descriptif, pour la fiche de #275) ;
- T4 p_min_mc des deux formes (maximum, parts > α/2 et > α) ;
- T5 transitions de verdict « deux » → « bas » (OK, ALERTE, ECHEC ; descriptif) ;
- T6 niveau des p asymptotiques uni- et bilatérale (pour la section de calibration asymptotique du `.tex`).

**Critère, fixé avant toute exécution et reporté sans modification dans le script et au T0** :
- **K1, décisif** : pour la forme « bas », sous N et sous E, aux deux seuils, classe *compatible* ou *écart mineur* par rapport à ρ_bas (classes de #166).
  - Une *distorsion matérielle libérale* ⇒ **arrêt au point D2-Fd** : #276 n'est pas implémentée, et le mainteneur décide sur le tableau.
  - Une distorsion conservatrice est documentée sans arrêt.
- **K2, descriptif** : puissance « bas » contre « deux » par scénario, avec McNemar. Aucun seuil ; le tableau est cité dans la fiche.
- **K3** : contrôles (a) et (i2) conformes, sinon le tableau n'est pas versionnable.
- Statut : **constat de simulation sous un plan**. Aucun théorème ne couvre ce test bootstrap à T = 8.

**Coût estimé** : 1,85 s par triangle à B = 999 (mesuré au pilote, statistique seule), soit environ 13 000 triangles et 6,7 h CPU, plus l'oracle (quelques minutes). Environ 2 h sur 4 cœurs.

**Hors périmètre** : loi A sous les alternatives ; autres géométries de triangle ; pool brut (#46).

## 3. #275 : forme du diagnostic par diagonale

### 3.1 Avis sur la quantité

- Pour chaque diagonale retenue par la statistique globale (n_k ≥ 2, mêmes étiquettes, mêmes colonnes figées), restituer n_k, L_k, S_k, Z_k = min(L_k, S_k) et **P(Z_k ≤ z_k)** sous Binomiale(n_k, 1/2).
- Cette probabilité est **exacte sous la loi binomiale indépendante de Mack, non sous le modèle de Mack** : dans une colonne, le nombre de L est fixé par la médiane, et les résidus ne sont pas échangeables.
- Le drapeau P ≤ 10 % est le repère de Mack (1997, D6, p. D6.49, lecture de #201 **[NV ici]**). Il n'a ni contrôle de multiplicité ni verdict.
- Ce n'est **pas** un test : diagnostic au sens de `CONTEXT.md`, verdict INFO, `p_retenue` `NA`.
- La queue est basse, cohérente avec #276.
- Seules les diagonales à n_k ≥ 5 peuvent porter le drapeau : P(Z_k ≤ 0) = 2^(1−n_k) vaut 0,125 à n_k = 4 et 0,0625 à n_k = 5 **[V]**.

**Verdict** : **pertinent comme diagnostic**. Il localise l'exercice en cause, ce que la statistique globale ne fait pas. Sa sensibilité dépend fortement de la longueur des diagonales (pilote, § 2.2).

### 3.2 Forme recommandée (Q-Fd-4) : une ligne de diagnostic, sans affichage nouveau

- **Nouvelle fonction nommée** `mw_calendrier_diagonales(cal)` (nom indicatif). Elle prend le résultat de `mw_test_annees_calendaires()`, part de `cal$etiquettes` (déjà rendu), exclut les « * » et groupe par `diag` en ne gardant que n_k ≥ 2, comme la statistique globale. Elle rend un `data.frame` à une ligne par diagonale : `k`, `n`, `L`, `S`, `Z`, `p_diag` = P(Z_k ≤ z_k), `repere` (logique, `p_diag <= REPERE_DIAGONALE_MACK_1997`).
  - Elle ne recalcule ni médiane ni étiquette, et `mw_test_annees_calendaires()` n'est pas modifiée par #275.
  - Calcul exact : `sum(dbinom(l, n, 0.5)[pmin(l, n - l) <= z])`, l = 0..n.
- **Constante** `REPERE_DIAGONALE_MACK_1997 <- 0.10` : repère de Mack, **indépendant de α** (Q-Fd-5).
- **Ligne de `mw_tests()`**, placée juste après la ligne du test calendaire, famille M3 (aucun préfixe nouveau, `GROUPES` inchangé) :
  - `add(fam, "Effets d'annee calendaire par diagonale (repere de Mack 1997)", fonction = "mw_calendrier_diagonales", "Mack (1997), Claims Reserving Manual, vol. 2, D6, annexe H, p. D6.47-D6.51", type = "diagnostic", ...)` ;
  - `H0` = « répartition aléatoire des L et des S sur chaque diagonale » ; `H1` = « diagonale à dominante L ou S » ;
  - `estim_nom = "diagonales sous le repere de 10 %"`, `estim` = nombre de diagonales portant le drapeau (entier) ;
  - aucune statistique ni p-value (`stat`, `p_ex`, `p_as` `NA`, pas de `mc_nom`). La plus petite `p_diag` n'est **pas** mise dans une colonne de p-value, où elle serait lue comme une p-value de test.
- **`detail`**, texte fixe puis une entrée par diagonale retenue, dans l'ordre de k. Aucun nombre issu du bootstrap (#76) ; les probabilités sont des calculs exacts sous la loi binomiale. Nombres au format du moteur (`format()`, point décimal). Forme :
  > `Repere par diagonale de Mack (1997, D6, p. D6.49), sans controle de multiplicite et sans verdict ; le test est la ligne precedente. P(Z_k <= z_k) sous la loi binomiale independante de Mack (exacte sous cette loi, non sous le modele de Mack) ; seule une diagonale d'au moins 5 etiquettes peut descendre a 10 %. Diagonales k = i + j des facteurs F(i,j) (paiements de l'exercice i + j + 1) : k = 1 : n = 2, L = 0, S = 2, Z = 0, P = 0.5 ; ... ; k = 5 : n = 6, L = 0, S = 6, Z = 0, P = 0.03125 (repere) ; k = 6 : n = 5, L = 2, S = 3, Z = 2, P = 1.`

  `coder` fixe la formulation exacte, ASCII sans accents comme les autres chaînes du moteur. Les valeurs de L et S de `reserve2` ci-dessus sont illustratives (seuls Z_k et n_k sont mesurés **[V]**).
- **Statistique globale non définie** (aucune diagonale retenue) : `estim` `NA`, `detail` « aucune diagonale retenue (n_k >= 2) ».
- **Repérage des diagonales** par l'indice k = i + j, celui du graphique « Résidus de Mack par année calendaire (M3) » (`res$calendrier` de `mw_residus()`, même convention), et **non** par les noms de ligne du triangle (Q-Fd-6). #275 reste ainsi indépendante de #268.
- **Affichage** : la ligne entre dans la table M3 existante. `app.R` et `R/display_helpers.R` ne changent pas, et `app-review` n'est pas déclenché. Un contrôle visuel de la longueur du `detail` par la session principale suffit **[H]**, à confirmer sur l'application.

### 3.3 Alternatives à Q-Fd-4

- **(b) Phrase dans le `detail` de la ligne du test** : pas de ligne nouvelle, mais le `detail` d'une ligne à verdict porterait des drapeaux non contrôlés en multiplicité, au voisinage des phrases de R1, #244, #257 et #204, ce qui en brouille la lecture. Non recommandé.
- **(c) Élément structuré** dans le résultat (par exemple `plots_data$calendrier_diagonales`), pour griser les diagonales signalées sur le graphique M3 : changement d'affichage, `app-review`, hors de « sans affichage nouveau ». À proposer plus tard si le mainteneur le souhaite.

### 3.4 Critères d'acceptation de #275 (reprise de l'issue, précisée)

- `p_diag` reproduit la table de prob(Z_j ≤ z_j) de D6.49 pour n = 2 à 11.
  - Valeurs attendues sous la loi binomiale **[V]**, `table97.R` :

    | n | z = 0 | 1 | 2 | 3 | 4 | 5 |
    |---|---|---|---|---|---|---|
    | 2 | 0,5000 | 1 | | | | |
    | 3 | 0,2500 | 1 | | | | |
    | 4 | 0,1250 | 0,6250 | 1 | | | |
    | 5 | 0,0625 | 0,3750 | 1 | | | |
    | 6 | 0,03125 | 0,21875 | 0,6875 | 1 | | |
    | 7 | 0,015625 | 0,1250 | 0,4531 | 1 | | |
    | 8 | 0,0078 | 0,0703 | 0,2891 | 0,7266 | 1 | |
    | 9 | 0,0039 | 0,0391 | 0,1797 | 0,5078 | 1 | |
    | 10 | 0,0020 | 0,0215 | 0,1094 | 0,3438 | 0,7539 | 1 |
    | 11 | 0,0010 | 0,0117 | 0,0654 | 0,2266 | 0,5488 | 1 |

  - **L'égalité avec la table publiée n'est pas vérifiée ici** (PDF hors dépôt) **[NV]**. Elle l'est par la session qui dispose du PDF, avant le commit ; à défaut, le critère devient « égalité avec la formule binomiale », et l'écart est consigné.
- Sur `reserve2`, une seule diagonale porte le drapeau : k = 5, n = 6, Z = 0, P = 0,03125 **[V]** (n_k et Z_k mesurés ; les autres n_k ≤ 4, ou n_k = 5 avec Z = 2).
- Aucun nombre issu du bootstrap dans le `detail`.
- σ_USP, p-values et verdict de la ligne M3 globale identiques à l'état laissé par #276.
- Le nombre de lignes de `reserve2` passe de 19 à 20, et les INFO de 5 à 6 (décompte de `reserve2.rds` : 2 ALERTE, 4 ECHEC, 5 INFO, 8 OK **[V]**).
- Test unitaire de `mw_calendrier_diagonales()` : énumération pour n = 2 à 11, cohérence avec `cal$detail` (`n`, `Z`), triangle sans diagonale retenue.

### 3.5 Lecture à écrire dans la fiche du diagnostic

Fiche à six rubriques, sans `\Pertinence` (`CONVENTIONS.md`, l. 24). Sa rubrique 6 dit pourquoi la ligne n'a pas de verdict :
- multiplicité non contrôlée ;
- loi de référence qui n'est pas celle du modèle ;
- diagonales courtes incapables de porter le drapeau ;
- taux sous H0 et sous les alternatives tirés du T3 de la mesure versionnée, et non du pilote.

### 3.6 Proposition hors Fd (issue sur accord, Q-Fd-10)

**Test du minimum par diagonale à p-value de Monte-Carlo.**
- **Hypothèse visée** : D(2)(h)(i), contre un choc sur un exercice isolé.
- **Statistique** : M = min_k P(Z_k ≤ z_k), sur les diagonales de #275.
- **p-value** : Monte-Carlo, par le même bootstrap, queue basse. Le niveau ne dépend alors plus du nombre de diagonales, la simulation intégrant la multiplicité.
- **Apport** : le pilote suggère qu'une règle par diagonale est plus puissante que Z contre un choc sur une diagonale longue. M en ferait un test de niveau contrôlé.
- **Fondement** : la validité repose sur la seule échangeabilité de la statistique observée et des réplications sous le modèle ajusté, comme pour toutes les lignes Monte-Carlo de M1 à M6. La combinaison par le minimum des p (méthode de Tippett) n'est pas invoquée pour sa loi, et sa référence n'est pas vérifiée ici **[NV]**.
- Puissance et niveau à T = 8 inconnus : à mesurer avant toute adoption.
- Hors de Fd : ce serait une ligne de test nouvelle, que #275 exclut expressément. Proposée pour après la remise ou pour Ff, au choix du mainteneur.

## 4. #268 : périmètre

**Constat** (issue, non remesuré ici) : un nom de ligne `NA` fait échouer la première fonction qui assemble une table nommée, et `run_engine()` rend `ok = FALSE` par une erreur R interceptée.

**Lecture actuarielle** **[V]** (lecture du code) :
- les noms de ligne ne servent à **aucun calcul** : le moteur indexe les cellules par position ;
- ils ne servent qu'aux noms de lignes des tables (`.mw_noms_lignes_empilees()`, par les vecteurs F dont les noms viennent de `rownames(tri)`) ;
- aucun résultat numérique n'en dépend.

C'est un contrôle de saisie à sens métier : le nom identifie l'année d'accident.

**Périmètre recommandé (Q-Fd-7)** : `mw_valider_triangle()` refuse, avec un motif métier, sans erreur R :
- (a) un nom de ligne `NA` ;
- (b) un nom de ligne vide (`""`) ;
- (c) des noms de ligne en double, qui désignent deux fois la même année d'accident (aujourd'hui remplacés en silence par des noms automatiques, selon l'audit cité dans #268).

Motif indicatif : « Nom d'annee d'accident manquant ou vide (ligne %d) » / « Annee d'accident en double : %s ». Un triangle **sans** noms de ligne reste admis. Les noms de colonne sont hors périmètre : ils n'alimentent aucune table, ce que `coder` confirme **[H]**.

**Pourquoi ne pas remplacer les noms par défaut** : le remplacement silencieux d'une étiquette saisie masquerait une erreur de données et rompt la traçabilité entre la saisie et les tables restituées.

**Critères d'acceptation** :
- (a), (b) et (c) donnent `ok = FALSE`, le motif dans `validation$erreurs`, aucun `erreur_r` ;
- les six cas de référence restent `identical()` ;
- `engine_valider_donnees()` (lognormale) n'est pas concernée ;
- l'application ne transmet pas de noms de ligne au moteur (`app.R`, l. 212 : `lire_tableau(..., row.names = NULL)`) **[H]**, à confirmer par `coder`. Si c'est le cas, le motif n'est atteignable que par appel direct, et `app-review` n'est pas déclenché.

**Circuit** : 3 (`coder` → `audit`). Aucune régénération ; aucun résultat changé ; aucune validation d'`actuary` requise.

## 5. Effets attendus sur `reserve2` et tableau avant / après

**σ_USP inchangé** dans tous les cas **[V]** : `mw_parametre(aj, msep, sigma_standard, bareme)` ne reçoit aucun test, et le flux de tirages de `mw_bootstrap()` n'est pas touché.

### 5.1 Étape #276 (une régénération de `reserve2`)

Ligne 9 de `res$tests`, « Effets d'annee calendaire (test de Mack) » :

| Champ | Avant | Après (attendu) | Statut |
|---|---|---|---|
| H1 | « une ou plusieurs diagonales atypiques (inflation, changement de cadence) » | texte du § 1.3, point 4 | chaîne |
| loi | « N(0,1) approx. ; moments EXACTS de Z = min(L, n-L) » | « … queue basse … » | chaîne |
| stat ; estim | −3,5403 ; 2 | inchangés | [V] |
| p_asymptotique | 3,997e-4 | **1,998e-4** (Φ(−3,5403)) | [V] calcul, si Q-Fd-3 |
| p_mc = p_retenue | 0,004 | **0,002** | [V] pilote |
| err_mc | 0,002827 (√(p(2−p)/B)) | **0,001414** (√(p(1−p)/B)) | [V] calcul |
| verdict | ECHEC | **ECHEC** (0,002 < α/2 = 0,05) | [V] |
| p_min | 7,63e-6 (2^−17) | **3,81e-6 (2^−18)** | [V] calcul |
| p_min_mc | 0,002 | **0,001** | [V] pilote |
| inoperant ; nature_p ; sens | FALSE ; Monte-Carlo ; ne pas rejeter | inchangés | [H] |

Objet `bootstrap` : `p_mc["Calendrier"]` 0,004 → 0,002 ; `err_mc["Calendrier"]` comme ci-dessus ; `granularite_stat["Calendrier"]` 0,002 → 0,001 ; `p_min_mc["Calendrier"]` 0,002 → 0,001. `B_effectif`, `motif_mc`, `stats_obs` et `sigma_boot` sont inchangés.

Toutes les autres feuilles sont inchangées **[H]**, à confirmer par le comparateur. Les cinq cas lognormaux sont `identical()` **[H]**.

**Aucun verdict ne change sur `reserve2`** : les changements de p sont validés par `actuary` ; aucun visa du mainteneur pour un verdict n'est requis.

**Hors références, des verdicts changent dans les deux sens**. Sous H0 au pilote (N, 1 000 triangles), à α = 0,10 : 55 OK → ALERTE, 12 ALERTE → ECHEC, 30 ALERTE → OK, 23 ECHEC → OK. Les rejets du côté haut disparaissent, ceux du côté bas se renforcent.

Sur le sous-triangle 5 × 5 (exemple du `.tex` et de `tests/unitaires/test_merz_wuthrich.R`) :
- à B = 999, ALERTE avec ECHEC dit inatteignable devient **ECHEC** (p = p_min_mc = 0,048 < 0,05, marge de 0,002, inférieure à l'erreur de Monte-Carlo de la p) ;
- à B = 99, l'inopérant devient un **test**, de verdict ALERTE, dont l'ECHEC est dit inatteignable (p_min_mc = 0,05 = α/2).

Ces changements sont à soumettre au mainteneur avec le tableau (Q-Fd-1). Les tests unitaires qui les codent sont à mettre à jour par `coder` (surface du § 7).

### 5.2 Étape #275 (une seconde régénération)

- Une ligne de plus après la ligne 9 : type diagnostic, INFO, `estim` = 1, `detail` du § 3.2.
- Les lignes suivantes sont décalées d'un rang. Aucune valeur numérique d'une ligne existante ne change.
- σ_USP inchangé ; `bootstrap` inchangé.

### 5.3 Étape #268 : aucun effet sur les références.

## 6. Plancher `p_min_mc` de M3 et bascule en test inopérant

- En queue basse, p_min_mc = (1 + N_bas)/(B_eff + 1). En bilatéral, c'est min(1, 2 (1 + min(N_haut, N_bas))/(B_eff + 1)).
- Sous la loi binomiale, l'atome bas Z = 0 est toujours au plus aussi lourd que l'atome haut (§ 1.3, point 3), et en général bien moins. En pratique N_bas ≤ N_haut, et **le plancher est divisé par deux, à une unité près**.
- **Le risque de bascule en test inopérant diminue.** Au pilote, sous H0 et sous les trois alternatives mesurées : maximum de p_min_mc 0,002 en « bas » contre 0,004 en « deux », aucun cas au-dessus de α/2.
- Seule exception concevable, par fluctuation de Monte-Carlo : une configuration où toutes les diagonales retenues comptent deux étiquettes (atomes égaux), N_bas pouvant alors dépasser 2 N_haut + 1. Ce cas n'a pas été rencontré.
- **Conséquence pour T < 8** : le sous-triangle 5 × 5 n'est plus inopérant à B = 99 (§ 5.1). Le tableau des seuils en T du `.tex` (l. 16349-16355) et la règle R1 illustrée l. 4840-4850 sont à mettre à jour.
- **La bascule dépend toujours des réplications tirées.** À B = 999 sur le 5 × 5, l'écart du plancher 0,048 à α/2 = 0,05 est du même ordre que l'erreur de Monte-Carlo : décision D1-8 d'E2b, inchangée.
- `.mw_calendrier_extremes()` est inchangée ; elle continue de rendre les deux extrémités.

## 7. Surface documentaire (passage unique de `docwriter`, règle 9)

**Un commit `docs:` par issue.**

**#276** :
- Fiche `mw:m3cal` :
  - **Cadre** : remplacer « la forme unilatérale relève de l'issue #276 » par la lecture du § 1.2, avec l'hypothèse non testée (compensation entre années d'accident d'une même diagonale).
  - **H0 / H1**.
  - **Rubrique 5** : p asymptotique Φ(Z*), p-value de Monte-Carlo en queue basse.
  - **« Comparaison avec la règle de décision de Mack »** : la règle de la p. 166 est bilatérale, l'outil suit l'alternative de la p. 164. Les niveaux 0,1125 et 0,089 de la p asymptotique sont ceux de **l'ancienne forme bilatérale** ; ajouter ceux de T6.
  - **Rubrique 7** : `p_min` 2^−18 ; plancher arithmétique 1/(B + 1) ; p_min_mc 0,001 sur `reserve2` ; exemple 5 × 5 ; niveau (T1) ; **puissance** (T2, source et statut), qui remplace « Puissance non étudiée ».
- Index des fonctions (l. 2263-2266).
- `tab:nature` (l. 5606) et `tab:conv` (l. 5885), tableaux 1 et 2 : préciser « queue basse ».
- `tab:pmin` et son texte (l. 6145-6152 : « (ii) Effet calendaire (bilatéral) » devient queue basse, p_min = Π_k 2^(1−n_k) ; l. 6184-6202).
- `tab:tracabilite-puissance` (l. 6556 : p_min, plancher 1/(B+1), puissance et sa source).
- Règle R1, section « Nature des p-values » (l. 4795-4850 : « 0,002 au bilatéral et 0,001 en queue haute pour les six vérifications », exemple 5 × 5).
- Liste des lignes (l. 12470) et l. 12500.
- Calibration asymptotique (l. 15080, 15115).
- Calibration Monte-Carlo (l. 15168, 15224, 15254) : les niveaux de #206 portent sur la forme bilatérale, à dire ; ajouter T1.
- Bibliographie, entrée Mack 1994 (l. 15937-15943).
- Seuils en T (l. 16349-16355).

**#275** :
- Fiche nouvelle de diagnostic, `mw:m3caldiag` (label indicatif), après `mw:m3cal`, six rubriques (§ 3.5). Alternative : un paragraphe dans `mw:m3cal`, si la concordance l'admet (Q-Fd-4).
- Liste des lignes (l. 12470) ; index des fonctions (nouvelle fonction).
- Registre de `tests/concordance_doc_moteur.R` (l. 1301), à modifier par `coder`.

**#268** : aucune modification du `.tex`, sauf si la section des contrôles de validité énumère les motifs de refus, ce que `docwriter` vérifie **[NV]**.

**`CONTEXT.md`** (domaine d'`architect`, non de `docwriter`) :
- « Plancher Monte-Carlo » : « 0,002 et 0,001 sur `reserve2` » reste vrai comme ensemble (CorrDev et Runs gardent 0,002) ; à relire.
- « Test inopérant », paragraphe Merz-Wüthrich : le calendrier n'est plus bilatéral ; l'exemple 5 × 5 est daté.
- « Diagnostic » : ajouter éventuellement l'exemple de #275.

**Facultatifs de #201** :
- **F1** : comparaison Mack 1994, annexe G (p. 155-161) / D6, annexe G (p. D6.42-D6.46) pour `mw:m3cor`, sur le modèle du paragraphe « Procédure suivie » de `mw:m3cal`. **Impossible sans les PDF** (Q-Fd-9) : à confier à `actuary-approfondi` dans Fd si le mainteneur les fournit, puis à `docwriter`. Sans les PDF, abandonné ; aucune affirmation fausse n'est en jeu (commentaire `6170671455`).
- **F2** : inscrire dans `docs/latex/CONVENTIONS.md`, l. 24-25, la forme qualifiée « Puissance non étudiée à $T = 8$ contre les écarts que vise la ligne ; des taux de rejet sous des alternatives d'une autre famille figurent au fichier …, sans être repris ici », comme variante admise de « puissance non étudiée à $T = 8$ ». Elle est employée 14 fois dans le `.tex` **[V]**, depuis D1-10 d'E2e. Commit `docs:` de `docwriter`.

**Commentaires du moteur et tests unitaires** (surface de `coder`, non de `docwriter`) :
- `tests/unitaires/test_merz_wuthrich.R` : l. 1944, p_min (3,3) 0,125 → 0,0625 et (2,3,2,4) 0,015625 → 0,0078125 ; l. 2017, 2^−17 → 2^−18 ; cas 5 × 5 à B = 99 qui n'est plus inopérant.
- `tests/unitaires/test_plancher_mc.R` : U125-3, extrémités inchangées, à relire.
- `tests/unitaires/test_tables_mw.R` : copie du catalogue, l. 342.
- `tests/calibration_mc_mw_t8.R` : le sens est lu au catalogue. Le tableau de #206 reste la trace de la forme bilatérale, et son en-tête le dira.

## 8. Circuit et ordre des étapes

#276 et #275 suivent le **circuit 1** ; #268 le **circuit 3**.

0. **Point d'arrêt D1-Fd** : décision du mainteneur sur Q-Fd-1 à Q-Fd-11 ; annotation datée ici. #276 et #275 passent de `needs-info` à `ready-for-agent`.
1. **#268** (circuit 3) : `coder` → `audit` léger ; références `identical()` ; commit `moteur:` + `tests:`.
2. **Mesure de #276** : `coder` écrit le script du § 2.3 → `audit` léger du script (contrôles (a), (i2)) → la session l'exécute hors CI → `actuary` lit les tableaux et applique K1. Commit `tests:` (script), puis `docs:` (tableau daté). **Point d'arrêt D2-Fd** si K1 échoue.
3. **#276, code** : `coder` (§ 1.3) → `audit` (avec (i2′)) → régénération de `reserve2` par la branche éphémère `claude/regeneration-276` → tableau avant / après (§ 5.1) → `actuary` valide les changements de p → commit unique code + `.rds`.
4. **#275, code** : `coder` (§ 3.2) → `audit` → régénération (`claude/regeneration-275`) → tableau avant / après (§ 5.2) → `actuary` valide → commit unique code + `.rds`.
5. **F1** (si les PDF sont fournis) : avis d'`actuary-approfondi`, en commentaire de #275.
6. **`docwriter`**, une fois, sur l'état final : un commit `docs:` par issue (#276, #275 ; F1 et F2 rattachés à #275) ; PDF recompilé ; concordance `--strict` à 0 écart.
7. **`actuary`** valide le diff du `.tex` (`git diff main...HEAD -- docs/latex/`). Revue finale complète (`audit` sur `git diff main...HEAD`, `/code-review`), puis sortie du brouillon.

**Parallélisme avec Fb.** Fd ne touche que la zone Merz-Wüthrich : catalogue `Calendrier`, `mw_test_annees_calendaires()` (p asymptotique), `.mw_calendrier_p_min()`, `mw_tests()` (bloc M3), une fonction nouvelle et `mw_valider_triangle()`. Elle ne touche aucun contrat partagé (§ 1.3, point 5). Si Fb modifie un contrat partagé qui change `reserve2`, la seconde branche fusionnée refait sa vérification de reproductibilité. La règle relève de l'annotation de l'ADR 0007 à l'ouverture de la paire (Q-P-7), non de la présente spécification.

## 9. Hors périmètre

- Toute repondération de f̂_j (procédure de 1997), contraire à D(4)(c).
- Toute ligne de test par diagonale, dont la proposition du § 3.6.
- La loi A sous les alternatives et les autres géométries de triangle (§ 2.3).
- Un élément structuré pour le graphique M3 (§ 3.3 (c)).
- La remesure de #206 pour les autres clés.
- Les noms de colonne du triangle (§ 4).

## Questions au mainteneur pour D1-Fd

- **Q-Fd-1 — #276, forme unilatérale.** *Recommandation* : **adopter la queue basse** pour la statistique globale Z, sous réserve de K1 (§ 2.3).
  - Motifs : c'est l'alternative que la ligne annonce et que Mack énonce p. 164 ; au pilote, la puissance passe par exemple de 0,105 à 0,200 contre une dérive, sans perte de niveau.
  - Effets : `reserve2` p_mc 0,004 → 0,002, verdict ECHEC inchangé, σ_USP inchangé. Hors références, des verdicts changent dans les deux sens (§ 5.1), dont le sous-triangle 5 × 5 (ALERTE → ECHEC à B = 999 ; inopérant → test à B = 99).
  - Hypothèse abandonnée, écrite dans la fiche : la compensation entre années d'accident d'une même diagonale.
  - *Alternative* : garder la forme bilatérale et documenter pourquoi. Elle teste alors en partie une alternative non annoncée.
- **Q-Fd-2 — Mesure avant le code.** *Recommandation* : protocole du § 2.3, exécuté à l'étape 2, avec arrêt D2-Fd si K1 échoue ; scénario « compensation » inclus pour chiffrer ce que la forme unilatérale abandonne. *Alternative* : s'en tenir au pilote, non versionné, ce qui ne suffit pas pour le dossier.
- **Q-Fd-3 — p asymptotique unilatérale aussi.** *Recommandation* : oui, Φ(Z*) ; `reserve2` 3,997e-4 → 1,998e-4. *Alternative* : la garder bilatérale, au prix de deux colonnes de la même ligne qui testent deux alternatives différentes.
- **Q-Fd-4 — #275, forme.** *Recommandation* : **une ligne de diagnostic** (INFO) juste après le test, `estim` = nombre de diagonales sous le repère, `detail` par diagonale, fonction nommée nouvelle, fiche de diagnostic propre ; aucun changement d'affichage. *Alternatives* : (b) phrase dans le `detail` du test ; (c) élément structuré pour le graphique, avec `app-review` (§ 3.3).
- **Q-Fd-5 — Repère de 10 %.** *Recommandation* : **fixe**, constante `REPERE_DIAGONALE_MACK_1997`, indépendante de α (c'est le repère de Mack). *Alternative* : α.
- **Q-Fd-6 — Repérage des diagonales.** *Recommandation* : indice k = i + j, celui du graphique M3, et non les noms de ligne. *Alternative* : exercice comptable tiré des noms de ligne, qui ferait dépendre #275 de #268 et de noms numériques consécutifs.
- **Q-Fd-7 — #268, périmètre.** *Recommandation* : refuser, avec un motif métier, les noms de ligne `NA`, vides et en double ; admettre l'absence de noms. *Alternatives* : remplacer par des noms par défaut (perte de traçabilité) ; ou refuser `NA` seulement.
- **Q-Fd-8 — Régénérations.** *Recommandation* : **deux**, une par issue qui change un résultat (#276, puis #275), chacune en commit unique code + `.rds`, comme le veut « un commit par issue qui change un résultat ». *Alternative* : une seule à la fin, avec un tableau décomposé par issue, comme E2e.
- **Q-Fd-9 — Facultatif F1** (`mw:m3cor`, 1994 / D6). *Recommandation* : à faire dans Fd **si** le mainteneur fournit les deux PDF, sinon abandon. F2 (`CONVENTIONS.md`) dans le passage de `docwriter`.
- **Q-Fd-10 — Proposition hors Fd** (§ 3.6, test du minimum par diagonale, p-value de Monte-Carlo). *Recommandation* : une issue à créer sur accord, titre « moteur: test calendaire par diagonale à p-value de Monte-Carlo (minimum des P(Z_k ≤ z_k)), niveau et puissance à T = 8 », libellés `enhancement`, `needs-triage`, après la remise ou en Ff. *Alternative* : ne rien ouvrir.
- **Q-Fd-11 — Validation des changements de verdict hors références** (§ 5.1, sous-triangle 5 × 5 et transitions sous H0). *Recommandation* : approuver sur le tableau de la mesure versionnée (T5) et sur le tableau avant / après de l'étape 3.

---
