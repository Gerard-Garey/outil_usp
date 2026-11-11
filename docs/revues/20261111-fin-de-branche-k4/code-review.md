# `/code-review` (effort `medium`), branche K4 — `git diff origin/main...c90e65a`

> *Constats de la skill reproduits par la session K4, avec leur suite.*

| # | Emplacement | Constat | Suite |
|---|---|---|---|
| 1 | `R/engine.R`, `.engine_calcul_protege()` | le motif dit « du moteur » d'une fonction de R quand la pile ne contient aucune fonction du moteur (reproduit : `stats::lm`, `eval()`) | **retenu** : avis d'`actuary` (Q2), `origine` à NA, motif neutre existant (`0aaf10d`) |
| 2 | `R/engine.R`, `PHRASE_VERDICT_SENSIBLE_MC` | majuscule après « ; » si le `detail` précédent ne finit pas par un point | écarté : cas accepté par `actuary` (avis amont § 3.3) ; jamais observé (audit : 0 sur 73 lignes) |
| 3 | `R/engine.R`, noms d'année d'accident | forme « (i=%d) » restante | hors inventaire de #527 : reste O1 de la fiche K4 |
| 4 | `R/engine.R`, `engine_valider_donnees()` | « xt et yt doivent etre numeriques » | hors de l'inventaire de l'étape 1 (classé parmi les gardes internes, `inventaire_527.md` § 4) ; consigné, sans suite dans K4 |
| 5 | `R/engine.R`, `usp_tests()` | règle « loi = NA » posée site par site plutôt qu'une fois dans `add()` | écarté : forme voulue par la spécification (ligne à ligne, Q-47-7 (a)) et par Q-A2 (une seule affectation dans `add()`) |
| 6 | `R/engine.R`, message d'alpha en double | duplication assumée (note d'US-03) ; identité gardée par `test_regle_verdicts.R` | sans défaut actuel |
| 7 | `R/engine.R`, commentaire « 393 caracteres » | longueur écrite dans un commentaire | mis à jour par `9e1259f` (385) ; plafond gardé par `test_detail_deux_phrases.R` |
| 8 | `R/engine.R`, `engine_motif_b_alpha()` | `.engine_saisie()` au lieu de l'enrobage | sans défaut actuel (B et alpha finis à ce point ; NA → NULL) |
