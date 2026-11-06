# Suivi de la documentation — Annexe

Plage : Annexe, « Flux détaillés entre fonctions » : `sec:annexe-flux`.

Entrées dans l'ordre du `.tex`, selon le gabarit et les règles de `README.md`.

## Entrées transversales

Aucune entrée.

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
