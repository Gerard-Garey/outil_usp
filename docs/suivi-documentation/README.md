# Suivi de la documentation LaTeX

## Objet

Ce dossier reçoit ce que la grille de condensation de `docs/latex/CONVENTIONS.md` (§ 2, « Conservation du fond, condensation de la forme ») sort de `docs/latex/doc_tests_usp.tex` sans le faire tomber : la vie du dépôt (historique, décisions, numéros d'issue, SHA) et les informations importantes qui n'ont pas leur place dans le guide (mesures retirées, justifications d'une règle retirée, détails d'implémentation). Une information est *importante* si elle fonde une affirmation du document, borne sa portée, ou permettrait à un relecteur de refaire une mesure.

Le document décrit l'outil ; ce dossier garde la trace de ce qui a été retiré du document, sous le `\label` d'origine. Il n'est pas un second guide : il ne reformule pas la méthode, qui est dans le `.tex`.

## Fichiers

| Fichier | Plage du document |
|---|---|
| `I.md` | Préambule, page de garde, « Objet du document » et partie I (`sec:archi`, `sec:notations`, `sec:controles`) |
| `II.md` | Partie II (`sec:mc`, `sec:modele-auxiliaire`, `sec:nature`) |
| `III-H.md` | Partie III, introduction, hypothèses H1 à H4 et diagnostics de stabilité, de robustesse et graphiques (`sec:h1` à `sec:graphiques`) |
| `III-M.md` | Partie III, méthode Merz-Wüthrich (`sec:mw`, `sec:mwm1` à `sec:mwm6`) et lecture conjointe (`sec:lecture-conjointe`) |
| `IV.md` | Partie IV (`sec:verif`, `sec:biblio` et `sec:tracabilite-code`, `sec:synthese`) |
| `annexe.md` | Annexe (`sec:annexe-flux`) |

## Règles de rédaction

- Les entrées suivent l'ordre du `.tex`. Une entrée par `\label` qui a perdu quelque chose, jamais d'entrée vide.
- En tête de chaque fichier, une section « Entrées transversales » reçoit ce qui ne relève d'aucun `\label` (par exemple un paragraphe répété dans plusieurs fiches, rangé sous le `\label` de la section qui le porte désormais).
- Titres de rubrique fixes et dans l'ordre du gabarit ci-dessous ; seules les rubriques non vides sont écrites.
- Une issue est citée nue (`#N`), une décision par son identifiant, une date en `jj/mm/aaaa`.
- **Aucune recopie** d'un ADR, de la feuille de route ni d'un fichier `docs/tableaux/` : on renvoie.
- Un chiffre n'est recopié que s'il ne vit nulle part ailleurs (valeur citée dans le `.tex` sans fichier versionné) ; il porte alors la mention « sans script versionné » et n'est jamais supprimé.
- L'entrée ne reformule pas la méthode (elle est dans le `.tex`).
- La rubrique « Correspondance SHA » suffit à retrouver l'état du moteur d'une mesure.
- L'entrée est écrite dans le même commit `docs:` que le retrait du `.tex`, à partir du tri du lot, qui désigne pour chaque passage « part en Markdown » sa rubrique de destination.
- Après chaque ajout, la table d'index ci-dessous est mise à jour.

## Gabarit d'une entrée

```markdown
## `<label>` — <titre courant de la fiche ou de la section> (partie <n>, § <section>)

**Historique.** <ancien état ; issue (#N) ; décision ; date (jj/mm/aaaa)>
**Décisions.** <règle décidée, par qui, quand ; identifiant (Q-…, D1-…, Mnn) ; ADR et point, par renvoi>
**Règle retirée (<identifiant>).** <définition de la règle retirée ; motif du retrait ; coût mesuré, par renvoi au fichier>
**Mesures retirées du guide.** <valeurs retirées et fichier `docs/tableaux/` qui les porte ; valeurs sans fichier : « sans script versionné »>
**Implémentation.** <détail d'implémentation retiré : fonction interne, tolérance, mesure de non-régression>
**Correspondance SHA.** <SHA> = <état mesuré> (fichier `docs/tableaux/…`)
**Renvois.** <ADR, feuille de route, issues>
```

## Index des entrées

Une ligne par entrée, dans l'ordre du `.tex`.

| `\label` | Fichier | Titre courant | Partie |
|---|---|---|---|
| Préambule (entrée transversale) | `I.md` | Commentaires `%` de la charte | Préliminaires |
| Page d'objet (entrée transversale) | `I.md` | Objet du document (tableau des références, encadré art. 104(7)) | Préliminaires |
| `sec:archi` | `I.md` | Architecture du moteur de calcul (Principe de séparation) | I |
| `sec:inventaire` | `I.md` | Inventaire des fonctions | I |
| `sec:segments` | `I.md` | Périmètres couverts et paramètres standard | I |
| `sec:graines` | `I.md` | Reproductibilité et gestion des graines | I |
| `sec:index-fonctions` | `I.md` | Index des fonctions de statistique et de p-value | I |
| `sec:ex-aequo` | `I.md` | Ex æquo des tests de rang et de signe | I |
| `sec:notations` | `I.md` | Notations générales (convention de restitution, graphie des textes) | I |
| `sec:controles` | `I.md` | Contrôles de qualité des données | I |
| Règle R4 (entrée transversale) | `II.md` | Renvois à l'entrée de la règle retirée | II |
| `fiche:procedure-mc` | `II.md` | Procédure générale de p-value de Monte-Carlo | II |
| `sec:boot-mw` | `II.md` | Bootstrap semi-paramétrique de la méthode Merz–Wüthrich | II |
| `sec:modele-auxiliaire` | `II.md` | Le modèle auxiliaire des moindres carrés (tête, `-spec`, `-ecart`, `-lignes`) | II |
| `sec:modele-auxiliaire-regles` | `II.md` | Règles liées (règle retirée R4) | II |
| `sec:modele-auxiliaire-autres` | `II.md` | Ce qui n'est pas le modèle auxiliaire MCO | II |
| `sec:nature` | `II.md` | Nature des p-values et validité à T = 8 | II |
| `sec:deuxerreurs` | `II.md` | Deux sources d'erreur distinctes | II |
| `sec:t8` | `II.md` | Ce que l'on peut et ne peut pas affirmer à T = 8 | II |
| `tab:nature` | `II.md` | Tableau 1 : disponibilité et choix des p-values | II |
| `tab:conv` | `II.md` | Tableau 2 : nature et vitesse des convergences | II |
| `tab:pmin` | `II.md` | Tableau des p-values minimales atteignables | II |
| `tab:tracabilite-puissance` | `II.md` | Tableau de traçabilité de la rubrique 7 | II |
| `sec:base-residus` | `II.md` | Choix de la base de résidus | II |
| `sec:variantes` | `II.md` | Variantes principales et secondaires | II |
| `sec:tests-fragiles` | `II.md` | Tests dont l'usage reste fragile à T = 8 | II |
| Introduction de la partie III (entrée transversale) | `III-H.md` | Fondement de la batterie de tests | III |
| Correspondance SHA (entrée transversale) | `III-H.md` | Correspondance SHA de la partie III lognormale | III |
| Blocs répétés (entrée transversale) | `III-H.md` | Blocs répétés des fiches de test | III |
| Relecture de la partie III-H (entrée transversale) | `III-H.md` | Relecture de la partie III-H (étape 8 de JF) | III |
| `sec:h1` | `III-H.md` | Hypothèse H1, linéarité et proportionnalité | III |
| `fiche:student-constante` | `III-H.md` | Test de Student sur la constante | III |
| `fiche:tost-constante` | `III-H.md` | Équivalence de la constante à zéro (TOST) | III |
| `fiche:student-pente` | `III-H.md` | Test de Pitman sur la pente (lien positif pertes / volume) | III |
| `fiche:student-pente-modele-auxiliaire` | `III-H.md` | Test de Student sur la pente (modèle auxiliaire MCO) | III |
| `fiche:fisher-global` | `III-H.md` | Test de Fisher de significativité globale | III |
| `fiche:r2` | `III-H.md` | Coefficient de détermination R² | III |
| `fiche:reset` | `III-H.md` | Test RESET de Ramsey | III |
| `fiche:spearman` | `III-H.md` | Corrélation de rang de Spearman (ratio contre volume, ratio contre temps) | III |
| `fiche:mann-kendall` | `III-H.md` | Test de tendance de Mann–Kendall | III |
| `fiche:cox-stuart` | `III-H.md` | Test de tendance par signes de Cox–Stuart | III |
| `sec:h2` | `III-H.md` | Hypothèse H2, structure de variance quadratique | III |
| `fiche:breusch-pagan-koenker` | `III-H.md` | Test de Breusch–Pagan, version studentisée de Koenker | III |
| `fiche:breusch-pagan-1979` | `III-H.md` | Test de Breusch–Pagan, version originale de 1979 | III |
| `fiche:white` | `III-H.md` | Test de White | III |
| `fiche:goldfeld-quandt` | `III-H.md` | Test de Goldfeld–Quandt | III |
| `fiche:brown-forsythe` | `III-H.md` | Test de Brown–Forsythe | III |
| `fiche:smirnov` | `III-H.md` | Test de Smirnov à deux échantillons | III |
| `fiche:position-delta` | `III-H.md` | Position de δ̂ dans son domaine (diagnostic) | III |
| `sec:h3` | `III-H.md` | Hypothèse H3, lognormalité de la variable modélisée | III |
| `fiche:shapiro-wilk` | `III-H.md` | Test de Shapiro–Wilk | III |
| `fiche:shapiro-francia` | `III-H.md` | Test de Shapiro–Francia | III |
| `fiche:anderson-darling` | `III-H.md` | Test d'Anderson–Darling | III |
| `fiche:cramer-von-mises` | `III-H.md` | Test de Cramér–von Mises | III |
| `fiche:kolmogorov-smirnov` | `III-H.md` | Test de Kolmogorov–Smirnov contre N(0,1) | III |
| `fiche:lilliefors` | `III-H.md` | Test de Lilliefors | III |
| `fiche:jarque-bera` | `III-H.md` | Test de Jarque–Bera | III |
| `fiche:dagostino-asymetrie` | `III-H.md` | Test d'asymétrie de D'Agostino | III |
| `fiche:anscombe-glynn-aplatissement` | `III-H.md` | Test d'aplatissement d'Anscombe–Glynn | III |
| `sec:h4` | `III-H.md` | Hypothèse H4, indépendance et validité du maximum de vraisemblance | III |
| `fiche:durbin-watson` | `III-H.md` | Test de Durbin–Watson | III |
| `fiche:ljung-box` | `III-H.md` | Test portemanteau de Ljung–Box (retard 2) | III |
| `fiche:suites-wald-wolfowitz` | `III-H.md` | Test des suites de Wald–Wolfowitz | III |
| `fiche:foc` | `III-H.md` | Condition du premier ordre (gradient projeté, KKT) | III |
| `fiche:centrage` | `III-H.md` | Centrage des résidus standardisés (diagnostic) | III |
| `fiche:variance-unitaire` | `III-H.md` | Variance unitaire des résidus standardisés (diagnostic) | III |
| `fiche:durbin-watson-ratios-bruts` | `III-H.md` | Durbin–Watson sur ratios bruts | III |
| `fiche:suites-ratios-bruts` | `III-H.md` | Test des suites sur ratios bruts | III |
| `fiche:sup-f` | `III-H.md` | Test de rupture sup-F (Quandt / Chow / Andrews) | III |
| `fiche:ols-cusum` | `III-H.md` | Test de stabilité OLS-CUSUM | III |
| `fiche:grubbs` | `III-H.md` | Test de Grubbs | III |
| `fiche:rosner-esd` | `III-H.md` | Procédure ESD généralisée de Rosner | III |
| `fiche:cook` | `III-H.md` | Distance de Cook (diagnostic) | III |
| `fiche:leviers` | `III-H.md` | Leviers (hat values, diagnostic) | III |
| `fiche:sup-f-ratios-bruts` | `III-H.md` | Rupture sup-F sur ratios bruts | III |
| `fiche:ols-cusum-ratios-bruts` | `III-H.md` | Stabilité OLS-CUSUM sur ratios bruts | III |
| `fiche:grubbs-ratios-bruts` | `III-H.md` | Grubbs sur ratios bruts | III |
| `fiche:rv-delta` | `III-H.md` | Rapport de vraisemblance sur les cas limites de δ | III |
| `fiche:jackknife` | `III-H.md` | Jackknife (sensibilité au retrait d'une année) | III |
| `fiche:ic-bootstrap` | `III-H.md` | Intervalle de confiance par bootstrap paramétrique | III |
| `fiche:multi-demarrages` | `III-H.md` | Convergence multi-démarrages | III |
| `sec:graphiques` | `III-H.md` | Diagnostics graphiques, couverture exhaustive | III |
| `fiche:qqnorm` | `III-H.md` | QQ-plot normal | III |
| `fiche:qqplot-deux-echantillons` | `III-H.md` | QQ-plot à deux échantillons | III |
| `fiche:graph-influence-levier` | `III-H.md` | Graphiques d'influence et de levier | III |
| `fiche:spread-location` | `III-H.md` | Graphique dispersion-niveau | III |
| `sec:graph-mw` | `III-H.md` | Visualisation de la régression chain-ladder (Merz–Wüthrich) | III |
| `mw:influence` | `III-H.md` | Influence et leviers du triangle (Merz–Wüthrich) | III |
| Correspondance SHA (entrée transversale) | `III-M.md` | Correspondance SHA de la partie Merz–Wüthrich | III |
| Règles communes de M1 (entrée transversale) | `III-M.md` | Colonnes dégénérées et ensembles figés (règles communes de M1, `sec:mwm1`) | III |
| Phrases de B effectif (entrée transversale) | `III-M.md` | Phrases de B effectif et du retirage (`sec:boot-mw`) | III |
| Règle R1 (entrée transversale) | `III-M.md` | Règle R1 sur le plancher Monte-Carlo (lignes de rang et de comptage de M1 à M3) | III |
| Relecture de la partie III-M (entrée transversale) | `III-M.md` | Relecture de la partie III-M (étape 8 de JF) | III |
| `sec:mw` | `III-M.md` | Méthode Merz–Wüthrich, cadre et spécification | III |
| `mw:m1` | `III-M.md` | Absence de tendance des facteurs avec le cumulé | III |
| `mw:m1a` | `III-M.md` | Nullité de l'ordonnée à l'origine, colonne par colonne | III |
| `mw:m1b` | `III-M.md` | Homogénéité de f_j entre années de survenance | III |
| `mw:m1c` | `III-M.md` | Absence de courbure de la régression | III |
| `mw:m1d` | `III-M.md` | Stabilité du facteur selon la pondération (famille α) | III |
| `mw:m1id` | `III-M.md` | Identifiabilité intra-colonne | III |
| `mw:m2bp` | `III-M.md` | Hétéroscédasticité résiduelle contre le cumulé | III |
| `mw:m2b` | `III-M.md` | Adéquation de l'exposant de variance, colonne par colonne | III |
| `mw:m2var` | `III-M.md` | Variance unitaire des résidus de Mack | III |
| `sec:mwm3` | `III-M.md` | Hypothèse M3, indépendance (tête de section) | III |
| `mw:m3cal` | `III-M.md` | Effets d'année calendaire (test de Mack) | III |
| `mw:m3caldiag` | `III-M.md` | Effets d'année calendaire par diagonale | III |
| `mw:m3acc` | `III-M.md` | Homogénéité des résidus entre années de survenance | III |
| `mw:m3cor` | `III-M.md` | Corrélation entre années de développement adjacentes | III |
| `mw:m3runs` | `III-M.md` | Test des suites sur les résidus de Mack | III |
| `mw:m4gr` | `III-M.md` | Cellule aberrante du triangle | III |
| `mw:m4ros` | `III-M.md` | Cellules aberrantes multiples, ESD de Rosner | III |
| `sec:mwm5` | `III-M.md` | Diagnostics M5, normalité (tête de section) | III |
| `mw:m5sw` | `III-M.md` | Shapiro–Wilk sur les résidus de Mack | III |
| `mw:m5li` | `III-M.md` | Lilliefors sur les résidus de Mack | III |
| `mw:m6sig` | `III-M.md` | Extrapolation de σ̂²_{J−1} | III |
| `sec:lecture-conjointe` | `III-M.md` | Lecture conjointe (tête de section) | III |
| `fiche:p-famille` | `III-M.md` | p de famille (minP, lecture conjointe) | III |
| `fiche:p-globale` | `III-M.md` | p globale (minP, lecture conjointe de la batterie) | III |
| `sec:verif` | `IV.md` | Vérification empirique de l'implémentation | IV |
| `sec:calibration-mc` | `IV.md` | Calibration des p-values de Monte-Carlo | IV |
| `sec:calib-asympt-mw` | `IV.md` | Calibration des p-values non simulées (Merz–Wüthrich) | IV |
| `sec:calib-mc-mw` | `IV.md` | Calibration des p-values de Monte-Carlo (Merz–Wüthrich) | IV |
| `sec:biblio` | `IV.md` | Compléments bibliographiques | IV |
| `sec:tracabilite-code` | `IV.md` | Traçabilité entre la documentation et le code | IV |
| `sec:synthese` | `IV.md` | Synthèse et lecture des verdicts | IV |
| `sec:taux-reperes` | `IV.md` | Taux de franchissement des repères sous le modèle ajusté | IV |
| `sec:volumes-constants` | `IV.md` | Lignes non applicables à volumes constants | IV |
| `sec:annexe-flux` | `annexe.md` | Annexe, flux détaillés entre fonctions | Annexe |
