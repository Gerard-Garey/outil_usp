# Suivi de la documentation — Annexe

Plage : Annexe, « Flux détaillés entre fonctions » : `sec:annexe-flux`.

Entrées dans l'ordre du `.tex`, selon le gabarit et les règles de `README.md`.

## Entrées transversales

### Relecture de l'annexe (étape 8 de JF, 08/11/2026)

Tête relue : `55ea997`. Appelants et appelés mesurés le 08/11/2026 sur le moteur chargé par `charger_moteur()` (noms de fonctions de l'environnement du moteur présents dans le corps de chaque fonction, `all.names(body(f))` ; les appels par argument par défaut ou par entrée de catalogue ne sont pas vus par ce relevé et ont été vérifiés à la lecture du code). Texte retiré cité, dans l'ordre du `.tex`.

**Historique.**
- Convention graphique, liste des blocs gris : « \code{mw\_simuler\_triangle()} » remplacé par « \code{.mw\_tirer\_triangle\_valide()} ». Motif : aucune fonction du moteur n'appelle `mw_simuler_triangle()`, contrairement à la définition du bloc gris (« appelée par une autre fonction du moteur ») ; `mw_bootstrap()` tire par `.mw_tirer_triangle_valide()`, qui appelle `.mw_simuler_triangle_etat()`, dont `mw_simuler_triangle()` est l'enveloppe aux mêmes tirages (commentaire de `R/engine.R`, l. 11370-11375 à `55ea997`), employée par les tests. Même remplacement dans le bloc gris du graphe Merz–Wüthrich. Le tableau de `sec:tracabilite-code` garde `mw_simuler_triangle()` (« tirages de `mw_simuler_triangle()` », mêmes tirages) : non modifié.
- Graphe chapeau, légende : « (familles et ligne globale, préfixe LC) » ; motif : les lignes de famille portent le champ `famille` de leurs membres, seule la ligne globale porte `FAMILLE_LECTURE_CONJOINTE` (préfixe LC) (`fiche:p-famille` ; mesuré sur le jeu de contrôle : lignes 49 à 52 aux préfixes B., D., E. et F., ligne 53 en LC.).
- Graphe H1 : « Fisher global » → « Fisher global (diagnostic) » et « Spearman ($\times2$) » → « Spearman ($\times2$ ; temps : diagnostic) », comme les deux autres diagnostics de toute donnée du graphe (Student sur la pente, R²). Mesure : jeu de contrôle, types `diagnostic` pour Fisher et Spearman contre le temps ; `tab:nature` et `fiche:spearman` (« diagnostic par décision »).
- Graphe H3 et H4 : bloc `usp_runsr_p_exacte()` dessiné en gris (fonction interne) ; il est appelé directement par `usp_tests()` (relevé), d'où le style « fonction dédiée ». La légende (« les blocs gris fournissent des lois de référence ») reste exacte.
- Graphe Merz–Wüthrich : « M3 DW, suites (diagnostic) » → « M3 DW ; suites (diagnostic) » (Durbin–Watson est de type test sur `reserve2`, les suites un diagnostic ; mesuré).
- Tableau « Lecture en termes de revue de code » : « Mann--Kendall (\code{test\_mann\_kendall()} + \code{mk\_p\_exacte()} + deux internes), Durbin--Watson (\code{stat\_dw()} + \code{dw\_p\_exacte()} + trois internes) » ; internes nommés, au même critère (fonctions internes de la loi exacte) : `.mk_loi_exacte()` et `.poly_mult()` ; `.dw_valeurs_propres()` et `.imhof_p_sup0()`. Le compte « trois » de Durbin–Watson ne se rattachait à aucun critère commun avec Mann–Kendall : `dw_p_exacte()` appelle `stat_dw()`, `.dw_valeurs_propres()`, `.imhof_p_sup0()` et `.p_borne()` ; `test_mann_kendall()` et `mk_p_exacte()` appellent aussi `.mk_z()`, `.p_borne()` et `engine_aplatir_ex_aequo()` (relevé). Coupure `\allowbreak` dans `.dw_valeurs_propres()` (Overfull de 2,1 pt sinon).

**Mesures retirées du guide.** Aucune.

**Implémentation.** Points vérifiés et conservés (relevé du 08/11/2026) : gris de `sw_loi_nulle()` (appelée par `sw_p_loi_nulle()`), `.imhof_p_sup0()` (`dw_p_exacte()`, `dw_puissance_ar1()`, puissance enveloppe de H2), `.runs_dens()` (`runs_p_exacte()`, `runs_p_min()`), `.fisher_combine()` (trois fonctions de M1, une de M2, et `.mw_fisher_x_max()`), `.mw_spearman()`, `.mack_moments_Z()`, `.mw_stats()`, `.mw_pool_residus()` ; `.shapiro_sur()`, `.mw_pente_relative()`, `.mw_detail_extrapolation()` appelées par `usp_tests()` ou `mw_tests()` ; portées LN, MW, LN + MW du tableau des fonctions mutualisées ; 31 et 13 statistiques des deux catalogues ; M1 6 entrées, M2 3, M3 2 + 2 + 2 (`reserve2`) ; une seule vérification de type test en H2 (jeu de contrôle) ; `.mw_sommes_autres()` (`.mw_un_moins_h()`, `mw_influence()`, `mw_test_cellule_aberrante()`) et `.mw_un_moins_h()` (`mw_residus_redresses()`, ligne d'hétéroscédasticité) ; `.runs_z()` et `.mk_z()` partagées avec `.runs_extremes()` et `.mk_extremes()` ; 13 statistiques à champ `extremes` (7 + 6) ; `engine_p_famille()` appelée par `usp_tests()` et `mw_tests()`.

**Renvois.** Aucune issue ouverte pour après la remise ne touche une affirmation de l'annexe (#379, #386, #387, #420, #421, #439, #445, #469 à #471, #475, #482 à #494, #497 à #502 examinées).

## `sec:annexe-flux` — Annexe, flux détaillés entre fonctions (annexe, § Annexe — flux détaillés entre fonctions)

Entrée qui couvre toute l'annexe (sous-sections sans `\label` « Convention graphique », graphes chapeau, H1, H2, H3 et H4, Merz–Wüthrich, « Lecture en termes de revue de code »), légendes et commentaires `%` des figures TikZ compris.

**Historique.**
- Champ `fonction` de chaque ligne de la table des tests : #111 (aussi cité dans deux commentaires TikZ du graphe H1, retirés).
- Tableau des fonctions mutualisées : `test_grubbs()` servait aussi la méthode Merz–Wüthrich (Grubbs sur les résidus de Mack) jusqu'à #300, qui l'a rendue propre à la méthode lognormale (la légende du graphe chapeau le disait) ; `mw_influence()` sert la ligne de la cellule aberrante depuis #300 ; procédure ESD diagnostic dans la méthode lognormale depuis #304, dans la méthode Merz–Wüthrich depuis #300 ; loi nulle simulée de Shapiro–Wilk retirée de la méthode lognormale par #302 (Merz–Wüthrich seulement depuis) ; restitution en diagnostic des cinq lignes sur ratios bruts (règle R15) depuis #303 ; attribution des p-values exactes des lignes à loi de référence échangeable par `usp_regime()` depuis #70 ; choix de la variante de la p-value de Monte-Carlo et flux complémentaire de `engine_sous_graine()` depuis #240.
- Graphe chapeau : lignes de lecture conjointe ajoutées par `engine_p_famille()` depuis #297.
- Graphe H1 : test de Pitman et loi de permutation (#169, aussi cité dans un commentaire TikZ, retiré) ; jusqu'à #215, l'estimation â_w affichée sur la ligne de la constante était lue dans l'ajustement de `test_lm_complet()` ; depuis, dans la régression pondérée de `test_intercept()`.
- Graphe H2 : une seule vérification de type test depuis #299.
- Graphe Merz–Wüthrich : `mw_test_cellule_aberrante()` propre à la ligne de la cellule aberrante depuis #300 ; lecture conjointe : #297.
- Tableau « Lecture en termes de revue de code » : `.usp_mco_qr()` : #237 ; `usp_identifiabilite_pente()` fixait aussi le type de la ligne de la pente jusqu'au retrait de la règle R4 (voir `II.md`, entrée « Règle R4 ») ; `usp_delta_bord()` : #331 ; `.usp_echelle_exacte()` : #153.
- Dernier paragraphe : `.mw_spearman()` calcule la corrélation de rang et la p-value de chaque colonne depuis #239 (p-values de colonne par la loi exacte : #90) ; `.mw_spearman_loi_rangs()` et `.mw_spearman_comptes()` depuis #207 ; `runs_p_min()` dans les deux méthodes depuis #115 ; plancher Monte-Carlo d'`engine_p_mc()` depuis #125 ; `mw_calendrier_diagonales()` lit les étiquettes de `mw_test_annees_calendaires()` depuis #275 ; résidus studentisés externes de la cellule aberrante tirés de `mw_influence()` depuis #300 ; `.mw_sommes_autres()` et ligne d'hétéroscédasticité : #301 ; `.mw_un_moins_h()` commun au vivier et à la ligne d'hétéroscédasticité depuis #356 ; `engine_p_famille()` et `.engine_minp_rangs()` : #297.
- Conclusion : « l'ordre de vérification retenu lors du développement » ; renvoie à `sec:verif`.
- Commentaire TikZ du graphe H3 et H4 : il racontait l'ancien placement des sorties (« Auparavant chaque sortie etait positionnee relativement a son bloc de gauche […] Toutes partagent desormais une abscisse de reference ») ; réécrit au présent.

**Renvois.** #70, #90, #111, #115, #125, #153, #169, #207, #215, #237, #239, #240, #275, #297, #299, #300, #301, #302, #303, #304, #331, #356.
