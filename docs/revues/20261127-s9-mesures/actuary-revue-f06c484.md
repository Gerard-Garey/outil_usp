# Visa d'`actuary` sur le commit `f06c484` (S9, constat E5 de l'étape 9, option (a))

> *Rédigé par l'agent `actuary` (IA), revue sur diff, le 28/11/2026. Versé intégralement par la session.*

**Verdict : conforme.**

1. **Code.** Dans `mw_ajuster()`, `I = nrow(tri) − 1` (`R/engine.R`, l. 13197), donc I = 7 sur le triangle 8 × 8. Dans `mw_stat_correlation_dev()` (l. 14848-14872), `idx <- 0:(I − k − 1)` donne n_k = 7 − k facteurs par paire. La garde `length(idx) < 3` écarte les paires k ≥ 5. Il reste au plus quatre paires (k = 1 à 4, n_k = 6, 5, 4, 3, poids n_k − 1 = 5, 4, 3, 2), ce qui concorde avec la mesure sur `reserve2` citée dans le commit. « Au plus » est exact : les colonnes dégénérées (`.mw_j_exclues()`) et la garde `sd() == 0` peuvent encore retirer des paires. L'ancien texte « cinq à six » était faux.
2. **Fiche `mw:m3cor`.** La correction concorde avec la rubrique 6 (« seules quatre paires de colonnes comptent au moins trois facteurs ») et avec la rubrique 7 (p_min = 2/(6! 5! 4! 3!), « quatre paires de n_k = 6, 5, 4, 3 facteurs »). « Facteurs » au lieu d'« observations » et « triangle 8 × 8 » au lieu de « T = 8 » reprennent le vocabulaire de la fiche. Les autres cellules de la ligne ne changent pas.
3. **Forme (`docs/latex/CONVENTIONS.md`).** Aucune trace de vie du dépôt dans le `.tex` : l'historique est dans `docs/suivi-documentation/II.md`, sous `sec:tests-fragiles`. Correction minimale, fond conservé. Seul écart, typographique : `$8 \times 8$` ici, `$8\times8$` dans la fiche ; rendu identique, rien à reprendre.
4. **Résultats.** Aucun : documentation seule, sans effet sur σ_USP, un verdict ni une p-value.

**Retour** — Statut : complet. Preuves vérifiées : `git show f06c484` ; `R/engine.R`, l. 13197 et 14848-14872 ; fiche `mw:m3cor`, rubriques 6 et 7. Non vérifié : la compilation et les contrôles `controle_doc_nd.R` et `concordance_doc_moteur.R`, repris des déclarations du commit. Décisions non résolues : aucune. Critères déclenchés : aucun. Constat hors périmètre : écart de typographie `\times` (ADR 0018 : aucun critère, écarté).
