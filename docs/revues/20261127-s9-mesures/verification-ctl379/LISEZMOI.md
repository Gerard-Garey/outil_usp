# Vérification ciblée du contrôle « chaîne réduite » de #379 (lognormal, mode `--familles`)

Décision du mainteneur du 28/11/2026 (constat CR1 de `../code-review-revue-finale.md`) : corriger `controle_chaine()` de `tests/puissance_t8.R` (`18c8107`) et refaire le contrôle corrigé sur les 240 réplications contrôlées de la campagne versée (`docs/tableaux/20261127-issue379-familles-ln.md`), **sans `--ecrire`**, le tableau restant tel que produit.

Scripts écrits hors dépôt par `coder-approfondi` et copiés ici pour trace, tels qu'exécutés (le chemin `SP` désigne le dossier de travail de la session, qui n'existe plus) :

- `verif_ctl379.R` : évalue par `parse()` les définitions de `tests/puissance_t8.R` (md5 `f952813e72f35bcb46789d750bdfdce2`, version de `18c8107`) antérieures au bloc `if (OPT_FAMILLES) {`, avec les options par défaut de la campagne (B = 999, graine 20260930, matrice e 20260931, graine-ic 20260831, R = 300), puis appelle `unite_familles_ln(J, pt, b, TRUE)` pour b multiple de 10 sur les deux jeux et les quatre points (4 processus). Commande : `LC_ALL=C.UTF-8 Rscript verif_ctl379.R 4` depuis la racine du dépôt. Journal : `verif.log`.
- `compare_brut.R` : compare les 240 lignes recalculées au brut versé `docs/tableaux/20261127-issue379-familles-ln-brut.tsv` sur les 89 colonnes communes hors `ctl`. Journal : `compare_brut.log` (240 / 240). La ligne « lignes identiques au brut : 0 » de `verif.log` vient d'une première lecture qui convertissait « NA » en `NA` ; elle est remplacée par `compare_brut.R` (`na.strings = character(0)`).
- `perturbation_ctl379.R` : contrôle de méthode, une réplication b = 10 par jeu et point ; une p_mc d'une ligne de LIG_B augmentée de 1e-12 est détectée (« ECHEC ») 8 fois sur 8, le témoin non perturbé reste « identique » 8 fois sur 8. Journal : `perturbation.log`. Limite : réplications toutes en V1, branche V3b non exercée par perturbation.

Résultat : **240 identique, 0 exclusion (boucle), 0 exclusion (flux V3b), 0 ECHEC** ; 12 p_mc finies par réplication (2 880 / 2 880). Plateforme : R 4.3.3, Ubuntu 24.04.5, BLAS et LAPACK de référence 3.12.0 (celle du T0 de la campagne). Durée : 837 s d'horloge à 4 processus.
