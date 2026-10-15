# Revue de pertinence actuarielle et statistique des tests et des graphiques (15/10/2026)

> *Cadrage rédigé par la session principale (IA). Le rapport consolidé remplacera ce cadrage à la fin de la revue.*

## Mandat

Mission hors feuille de route, sur ordre du mainteneur du 15/10/2026 : faire vérifier par `actuary-approfondi`, appelé avec le modèle Fable et l'effort `xhigh`, la **pertinence actuarielle et statistique** de tous les tests statistiques et de tous les graphiques de l'outil, à T = 8. La revue porte sur la méthode, pas sur l'implémentation : elle lit d'abord la documentation (`docs/latex/doc_tests_usp.tex`), et le code seulement pour savoir ce qui est réellement calculé quand la documentation est ambiguë. Les issues ouvertes sont examinées dans le même mouvement.

Point de départ : la revue précédente du même type, l'issue #5 (21/09/2026, moteur au commit `f93847f`). Pour chaque test, la revue indique si le constat de #5 qui le concerne est réglé, l'est en partie ou reste ouvert.

## Décisions de cadrage du mainteneur (15/10/2026)

| Question | Décision |
|---|---|
| Livrable | Le présent rapport, versionné ; aucune modification du `.tex` ni du code sur cette branche ; les corrections suivront dans des branches ultérieures. |
| Consultations Fable | Six blocs en parallèle, soit six consultations `actuary-approfondi` / Fable / `xhigh`, au-delà du plafond ordinaire de trois par branche (`docs/agents/routage.md`, § 5.2), sur accord exprès ; une septième consultation, de synthèse, seulement si deux blocs se contredisent (§ 4.1.2) ; au plus une relance ciblée par bloc. Consolidation par la session principale. |
| Issues ouvertes | Toutes reçoivent un verdict dans ce rapport ; les agents n'écrivent rien sur GitHub ; les commentaires d'issues et les issues nouvelles proposées ne sont publiés qu'après l'accord du mainteneur. |
| Périmètre | Tests (H1 à H4, stabilité, robustesse, M1 à M6), graphiques, sections transversales sur les p-values, vérification empirique (niveaux, puissances, calibrations), synthèse des verdicts. Hors périmètre : contrôles de qualité des données, architecture, reproductibilité, calibration de σ_USP (estimation, crédibilité, mélange, MSEP). |

## Blocs

| Bloc | Objet | Sections du `.tex` (lignes à `c645926`) | Issues ouvertes examinées |
|---|---|---|---|
| 1 | Transversal : bootstrap paramétrique, modèle auxiliaire MCO, nature des p-values et validité à T = 8 (tableaux 1 et 2, p-values minimales, base de résidus, variantes, tests fragiles), calibration des p Monte-Carlo, synthèse des verdicts | 3894-4093, 4333-7182, 14636-15211 (parties transversales), 16388-16722 | #5 (parties transversales), #4, #164, #274, #200, #210, #284, #292, #294 |
| 2 | H1 (linéarité, proportionnalité) et H2 (structure de variance) | 7183-8876 | #158, #159, #213, #218, #222, #230 |
| 3 | H3 (lognormalité) et H4 (indépendance, validité du maximum de vraisemblance) | 8877-10613 | #48, #170, #286, #288 |
| 4 | Stabilité, ruptures et points aberrants ; robustesse de l'estimation ; graphiques de la méthode lognormale | 10614-11950 | #174, #190, #224, #227, #255, #285, #287, #295 |
| 5 | Merz-Wüthrich : cadre, bootstrap semi-paramétrique, M1, M2 | 4094-4332, 12178-13850 | #49, #268, #289, #290 |
| 6 | Merz-Wüthrich : M3 à M6, graphiques, vérification et calibration | 11951-12177, 13851-14635, 15212-15647 | #209, #246, #275, #276, #291, #293 |

## Grille de jugement (fiche `actuary`, « Quand on te demande une revue »)

Pour chaque test, diagnostic ou graphique : hypothèse de l'annexe XVII réellement visée et base de résidus ; nature de la p-value retenue et validité à T = 8 (existence d'une loi limite, vitesse de convergence et qualité pratique distinguées) ; puissance plausible à T = 8 ; verdict **pertinent / à compléter / fragile / à remplacer**, justifié et sourcé. Écart entre la documentation et ce qui est calculé : constat en soi.

## État

Revue en cours.
