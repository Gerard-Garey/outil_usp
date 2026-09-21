---
status: accepted
date: 2026-09-21
---

# Une p-value n'est « exacte » que sous le modèle réglementaire

La p-value retenue privilégie une p-value exacte quand elle existe. Or certaines p-values dites exactes ne le sont que sous un autre modèle que celui de l'annexe XVII — par exemple le Student sur la constante, exact sous un modèle à variance constante que les hypothèses H2 et H3 contredisent (issue #5). Nous décidons qu'une p-value n'est **exacte**, au sens de l'outil, que si la loi de la statistique sous H0 est exacte sous le **modèle réglementaire** ; à défaut, la p-value Monte-Carlo est retenue.

Aucune étiquette ne change sans démonstration : `actuary` évalue d'abord, test par test, si une p-value exacte est obtenable sous le modèle réglementaire (notamment Durbin-Watson, suites, Mann-Kendall, Spearman, Student sur la constante, Shapiro-Wilk par loi nulle simulée), et seules les conclusions de cette évaluation modifient `nature_p` et la p-value retenue.

## Consequences

Des p-values aujourd'hui qualifiées d'exactes pourront devenir Monte-Carlo, ce qui change `nature_p` et parfois la p-value retenue ; ces changements suivent la règle d'approbation de `CLAUDE.md` (verdict modifié : mainteneur ; p-value seule : `actuary`). Voir `CONTEXT.md` (p-value exacte, p-value retenue).
