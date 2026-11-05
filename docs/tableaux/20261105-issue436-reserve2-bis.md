# Tableau avant / après — référence `reserve2` (issue #436, bis)

- Date : 2026-11-05
- Plateforme du patch : R version 4.3.3 (2024-02-29), Linux, BLAS et LAPACK de référence (`libblas.so.3.12.0`, `liblapack.so.3.12.0`), session cloud, `LC_ALL=C.UTF-8`
- Voie : **patch chirurgical** (changement purement non numérique ; ADR 0006, premier amendement ; skill `verifier-reproductibilite`, étape 4) ; pas de régénération par la CI
- Commande : `Rscript tests/patcher_reference.R reserve2 --motif '^tests\[\[8\]\]\$H1$' --ecrire`, sur la référence de `cadd58b` (dernier commit qui l'a modifiée : `cadd58b`, md5 `069bf958d3495977f6b126ade9b691e6`), dans l'état de l'arbre du commit proposé (moteur modifié)
- Motif : `^tests\[\[8\]\]\$H1$` (ligne « Adequation de l'exposant de variance, colonne par colonne », famille M2, `mw_test_exposant_variance()`, `mw_tests()`)
- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil 0 pour lister (`Rscript tests/comparer_references.R reserve2 --seuil 0`, avant le patch : 1 grandeur en écart, `tests[[8]]$H1`, non numérique), seuil 1e-06 pour juger ; `INSTABLES` non neutralisé par le patcher
- md5 de `tests/reference/reserve2.rds` : avant `069bf958d3495977f6b126ade9b691e6`, après `14c32b7ee19745c0a7dc5e8f8c6fe657` (écrit sur le poste de la session : md5 non comparable à celui d'un `.rds` de la CI, #83)

**Synthèse** : 18724 feuille(s) dans l'ancienne référence comme dans le résultat recalculé ; 1 non strictement identique, une chaîne (`non numerique`), désignée par le motif ; 18723 feuille(s) non désignées identiques au bit près à la référence (vérifié par le patcher) ; aucune feuille numérique modifiée, écart numérique maximal 0.000e+00. Contrôle indépendant du patcher : la nouvelle référence, une fois l'ancienne chaîne remise dans `tests[[8]]$H1`, est `identical()` à l'ancienne (`TRUE`). Aucune des cinq autres références (`premium`, `reserve1`, `premium_ii6`, `premium_net`, `premium_interieur`) ne porte cette ligne (0 feuille contenant « eloigne la ligne du rejet » ou « cumul pivot ») ; 0 feuille non strictement identique (`comparer_references.R --seuil 0`). σ_USP, p-values et verdicts inchangés.

| Feuille | Avant | Après | Écart | Explication |
|---|---|---|---|---|
| `tests[[8]]$H1` | … donne des residus des deux signes de part et d'autre d'un cumul pivot (identite sum_i sqrt(C(i,j)) r(i,j) = 0) et eloigne la ligne du rejet : il n'est pas vise ici, lignes de M1 | … donne des residus des deux signes de part et d'autre d'un cumul pivot (identite sum_i sqrt(C(i,j)) r(i,j) = 0) : il n'est pas vise ici, lignes de M1 | non numérique | #436, revue finale de la branche Ft (`audit` et `/code-review`), décision du mainteneur du 05/11/2026, validée sur le fond par `actuary-approfondi` : « et eloigne la ligne du rejet » retiré, constat de simulation sous plan présenté comme une propriété, non établi contre la dérive de f_j avec l'année (tableau T2 de #309). Début de la chaîne inchangé (texte complet dans `docs/tableaux/20261105-issue436-reserve2.md`) ; 1216 caractères, ASCII ; `identical()` au texte du test unitaire : `TRUE` ; H0, `reference` et `detail` inchangés |

## Batteries (après le patch)

Toutes sous `LC_ALL=C.UTF-8`, sur la plateforme du patch.

- `Rscript tests/comparer_references.R --seuil 0` : code de sortie 0, `CONFORME`, 0 non strictement identique sur les six cas (premium 57017, reserve1 57016, reserve2 18724, premium_ii6 57017, premium_net 57017, premium_interieur 57017 feuilles)
- `Rscript tests/test_reproductibilite.R` : code de sortie 0
  - `premium     sigma_USP = 0.1114524114`
  - `reserve1    sigma_USP = 0.1073524114`
  - `reserve2    sigma_USP = 0.0497764613`
  - `premium_ii6 sigma_USP = 0.1483524114`
  - `premium_net sigma_USP = 0.1032524114`
  - `premium_interieur sigma_USP = 0.0871308679`
  - `OK : reproductibilite et non-regression verifiees pour 6 cas.`
- `Rscript tests/unitaires/test_merz_wuthrich.R` : code de sortie 0, 267 assertions, 267 ok ; la batterie complète `tests/test_unitaires.R` n'a pas été lancée
- `Rscript tests/concordance_doc_moteur.R --strict` : code de sortie 0
  - `BILAN : 0 ecart(s) (mode strict) ; formulations de decompte : 36 verifiee(s), 16 exemptee(s), 0 non classee(s)`

## Visa

Visa : décision du mainteneur du 05/11/2026, texte validé sur le fond par `actuary-approfondi`. Changement non numérique : aucune p-value, aucun σ_USP ni verdict changé.
