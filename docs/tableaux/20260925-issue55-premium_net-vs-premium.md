# Issue #55 — tableau (iii) : cas `premium_net` (II-1 déclaré net) contre `premium` (II-1 déclaré brut)

Calcul local (arbre de travail sur `claude/entrees-refactors`, tête ebba9f8 + modifications non commitées de #55),
R 4.3.3, Linux, B = 999, graine 20260831, α = 0,10, données `tests/donnees/donnees_ln.csv`, T = 8, barème long (c = 0,59).
Commande : `Rscript tableau_premium_net.R (script de session, non versionné)` (source `tests/outils_tests.R`, `executer_cas("premium")` et
`executer_cas("premium_net")`). Sortie brute : `tableau_premium_net_brut.txt` (même dossier).
Ce tableau n'est PAS le tableau de la CI (mode `creation` : « absent / ajouté ») ; il est produit à part pour le visa M3.

## Paramètre final

| Grandeur | premium (brutes) | premium_net (nettes) | Écart | Explication |
|---|---|---|---|---|
| σ standard du mélange | 0,1 | 0,08 | −0,02 | NP standard 0,8 × σ brut 10 % (art. 117 § 3 ; B(2)(d), M1) |
| σ estimé corrigé | 0,1194109083 | 0,1194109083 | 0 | σ̂ ne dépend pas du σ standard |
| crédibilité c | 0,59 | 0,59 | 0 | barème long, T = 8 |
| **σ_USP** | **0,1114524359** | **0,1032524359** | **−0,0082** | = −(1 − c)(1 − NP) σ brut = −0,41 × 0,2 × 0,1 = −0,0082 (exact) |
| variation relative / σ standard | +11,45 % | +29,07 % | | dénominateur σ standard changé |

Annonce du 23/09 (M13) : σ_USP 0,1114524 → 0,1032524 (−0,0082). **Coïncide.**

## Verdicts

Table auditable : 48 lignes. **Aucun verdict ne change** (0 ligne), aucune p-value retenue ne change (0 ligne).

Deux estimations changent (lignes de type diagnostic, verdict INFO des deux côtés, par le seul dénominateur σ_USP) :

| Ligne | premium | premium_net | Verdict avant → après |
|---|---|---|---|
| Sensibilité au retrait d'une année (jackknife), écart relatif max | 0,09376395211 (9,4 %) | 0,1012104051 (10,1 %) | INFO → INFO |
| Largeur relative de l'IC bootstrap 90 % | 0,5539084555 | 0,5978982103 | INFO → INFO |

**ÉCART À L'ANNONCE** : l'annonce (avis actuary et M13 du 23/09, fiche D point 6, visa conditionnel du 24/09 au soir)
prévoyait « un verdict change : jackknife OK → ALERTE (9,4 % → 10,1 %, seuil 10 %) ». Depuis la branche C (#24), la ligne
jackknife est un **diagnostic** au verdict **INFO** (référence `premium.rds` : `tests[[47]]$type = "diagnostic"`,
`verdict = "INFO"`) ; le repère de 10 % n'est plus un seuil de verdict, il ne sert qu'à la couleur des barres du graphique
d'influence (`REPERE_INFLUENCE_SIGMA`, `plot_influence_sigma()`) : dans `premium_net`, l'année 8 (−10,12 %) passe au-dessus
du repère. L'ampleur annoncée (9,4 % → 10,1 %) coïncide ; le changement de verdict n'a pas lieu. Le visa M3 étant
conditionnel à la coïncidence, ce tableau est à soumettre au mainteneur.

## Ensemble des feuilles différentes (comparer_objets, tol 1e-6) : 42 feuilles

| Racine | Feuilles | Contenu |
|---|---|---|
| parametre_final | 3 | sigma_standard, sigma_usp, variation_relative |
| metadata | 2 | sigma_standard (0,1 → 0,08), nature_donnees (brutes → nettes) |
| calibration | 2 | valeur[8] (σ standard), valeur[9] (σ_USP) |
| candidats | 2 | valeur[1] (σ standard), valeur[3] (σ_USP) |
| ic_bootstrap | 5 | quantiles de c·σ_boot·corr + (1 − c)·σ standard, tous décalés de −0,0082 |
| jackknife | 8 | sigma_usp[1..8], tous décalés de −0,0082 |
| ajustement | 2 | ecart_jackknife, largeur_ic (dénominateur σ_USP) |
| tests | 2 | tests[[47]]$estim, tests[[48]]$estim (les mêmes) |
| plots_data | 16 | influence$sigma_usp_sans_t[1..8] (−0,0082), influence$ecart_sigma[1..8] (×1,0794) |

Aucune autre feuille (bootstrap, statistiques, p-values, contrôles) ne diffère : le σ standard n'entre que dans le mélange final.
