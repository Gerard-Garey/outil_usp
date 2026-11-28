# Audit léger : correction du contrôle de la chaîne réduite (#379), commits `18c8107` et `2c800d6`

> *Rédigé par l'agent `audit` (IA), le 28/11/2026, sur `git diff 5619845 2c800d6` (règle 10 : correction postérieure à la revue finale revue sur son diff). Rien n'a été écrit dans le dépôt. Versé par la session.*

## Verdict : conforme avec réserves

La correction fait ce que demande le par. 5.1 de l'avis d'`actuary` (`actuary-protocoles-etape-1.md`) : les p Monte-Carlo des douze lignes de `LIG_B` sont comparées pour de vrai, et une comparaison vide ne peut plus passer pour une égalité. La vérification hors dépôt prouve ce qu'elle annonce (sous la réserve m2). Deux mineurs, aucun bloquant ni majeur.

## Constats

**m1 (mineur).** `tests/unitaires/test_outillage_mesure.R:772`, bloc (u) : le test « z_boot différents par leurs seuls attributs : ECHEC » pose des `dimnames` de colonnes ; `zm[i, ]` en hérite et `za[i, ]` non, donc toutes les lignes diffèrent et le résultat est l'ECHEC « hors réplications écartées », déjà produit avant la correction. La nouvelle garde (`tests/puissance_t8.R:1476`) est juste (mesure : avec `rownames` seuls ou un attribut ajouté, « ECHEC : z_boot differents sans ligne differente (attributs) » avec la garde, « exclusion (boucle) » à tort sans elle) mais aucun test ne la protège. Correction : `rownames` ou attribut ajouté dans ce test.

**m2 (mineur, traçabilité de la preuve).** `verif.log` porte « lignes identiques au brut ( 89 colonnes ) : 0 », artefact de lecture (`na.strings`) ; le 240 / 240 vient de `compare_brut.R`, dont la sortie n'était consignée dans aucun journal. Mesure : relance de `compare_brut.R`, 240 / 240 ; 0 différence sur chacune des 89 colonnes. Le « 240 identique » du brut versé vient de l'ancienne écriture ; seule la relance hors dépôt le confirme. Correction : consigner la sortie de `compare_brut.R` en signalant l'artefact.

## La vérification hors dépôt prouve-t-elle ce qu'elle annonce ?

Oui, sous la réserve m2 : mêmes réplications (`R_RUN` = 300, b multiple de `CTL_CHAINE_PERIODE` = 10, 30 × 4 points × 2 jeux = 240) ; mêmes tirages (`tirer_e(OPT_GRAINE + 1, R_RUN)`, `usp_ajuster(J$x, J$y)`, comme `PLAN_FAM`) ; même graine de bootstrap (fixée dans `unite_familles_ln()`) ; mêmes options (B = 999, pas d'essai, jeux J1 et J2, points N, A+0.5, T2, R4_2, contrôlés par le script) ; mêmes lignes que le brut (89 colonnes, dont les 31 `pmc:`) ; comparaison non vide (2 880 p finies sur 2 880 ; `p_mc_lignes()` l'interdit structurellement) ; perturbation détectée 8 fois sur 8 (limite : un cas par jeu et point, tous en V1).

## Points vérifiés

- Fidélité à l'intention ; aucun écart masqué (`stop()` sur ligne ou colonne absente, NA comparés par `identical()`) ; pas de faux ECHEC en pratique (colonne `p_monte_carlo` de type double).
- Les tests échoueraient sur l'ancienne écriture (scénario (u) rejoué sur `5619845` : « identique » à tort), sauf le test de la l. 772 (m1).
- `empreintes_code()` : sortie inchangée depuis le dépôt (seul le md5 de `outils_mesure_dw.R` change) ; « (hors dépôt) » correct depuis une copie.
- Gardes `--familles --ecrire` : refus avec le code 1 avant calcul pour les deux scripts.
- Invariant de branche vide ; md5 de `R/engine.R` `c7b767f5d9116c35a0a9237ffdd2d79a` ; aucun littéral de 5 chiffres ou plus dans les lignes ajoutées.

## Vérifications exécutées

| Commande | Résultat |
|---|---|
| `LC_ALL=C.UTF-8 Rscript tests/unitaires/test_outillage_mesure.R` | 0 échec |
| `LC_ALL=C.UTF-8 Rscript tests/unitaires/test_garde_ecrasement.R` | 207 assertions, 207 ok, 0 échec, rc = 0 |
| `compare_brut.R` | 240 / 240 sur 89 colonnes |
| scénario (u) sur `5619845` | défaut reproduit |
| garde des attributs, avec et sans la ligne | garde nécessaire, non vue par le test de la l. 772 (m1) |

Questions pour `actuary` : aucune. Constats hors périmètre : aucun.

## Suite donnée par la session

- m2 : levé par `verification-ctl379/compare_brut.log` et `verification-ctl379/LISEZMOI.md` (`5e6e589`), qui signale l'artefact de `verif.log`.
- m1 : test corrigé par `coder` (voir `synthese.md`, « Étapes 10 et 11 »).
