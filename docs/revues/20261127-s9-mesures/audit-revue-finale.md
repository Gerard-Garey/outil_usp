# Revue finale complète de la branche `claude/mesures-t8` (S9) par `audit`

> *Rédigée par l'agent `audit` (IA, effort `high`), revue finale complète (règle 10 de `CLAUDE.md`, étape 10 de la fiche « Branche S9 »), le 28/11/2026. PR #629 en brouillon, tête `f06c484`. Objet : `git diff 9f9efc2...HEAD`, soit 33 fichiers, +12 443 / −470 lignes. Rien n'a été écrit dans le dépôt. Versée par la session.*

## Verdict

**Conforme avec réserves.** Aucun constat bloquant, aucun majeur. Deux constats mineurs dans le périmètre de la branche, sans effet sur un chiffre, un verdict ou le `.tex`. Aucune question renvoyée à `actuary`.

> **Note de la session.** `/code-review` (niveau `high`, même objet) a relevé un défaut que cette revue n'a pas vu : le contrôle « chaîne réduite contre `run_engine()` » du mode `--familles` de `tests/puissance_t8.R` (l. 1445) comparait une colonne `p_mc` absente d'`engine_table_tests()` (NULL contre NULL). Voir `code-review-revue-finale.md` et la section « Étapes 10 et 11 » de `synthese.md`.

## Vérifications exécutées

Toutes sous `LC_ALL=C.UTF-8`, R 4.3.3, Ubuntu 24.04.5, BLAS et LAPACK de référence.

| Vérification | Commande | Résultat |
|---|---|---|
| Base de la comparaison | `git rev-parse --short origin/main` ; `git merge-base 9f9efc2 HEAD` | `9f9efc2` dans les deux cas (la référence locale `main` du clone était périmée, `cfa35b4` : la revue porte sur `9f9efc2...HEAD`) |
| Invariant de la branche | `git diff --stat cfa35b4 HEAD -- R/ app.R DESCRIPTION tests/reference/ tests/donnees/ tests/outils_tests.R` | vide |
| Empreinte du moteur | `md5sum R/engine.R` | `c7b767f5d9116c35a0a9237ffdd2d79a` |
| Tests unitaires | `Rscript tests/test_unitaires.R --parallele` | 64 fichiers, 4 418 assertions, 0 échec, 0 succès inattendu |
| ↳ `test_garde_ecrasement.R` | (batterie) | 203 assertions OK ; `mesure_correlation_cvm_ad_t8.R --ecrire` et `mesure_b_dossier_t8.R --grubbs-interieur --ecrire` refusés avant tout calcul |
| ↳ `test_outillage_mesure.R` | (batterie) | 94 assertions OK, dont (g) sur le dépôt réel |
| ↳ `test_dw_limite_rho.R` | (batterie) | 20 assertions OK |
| Reproductibilité | `Rscript tests/test_reproductibilite.R` | 7 cas conformes, écart maximal 0 |
| Concordance code ↔ `.tex` | `Rscript tests/concordance_doc_moteur.R --strict` | 0 écart |
| #421, essai | `mesure_dw_rho_negatif_t8.R --essai` | 43 contrôles, 0 échec ; K421-5 identique au tableau du 31/10 |
| #421, grille | lignes de la section 1 de l'essai contre le tableau versé | 16 lignes sur 16 identiques |
| #420, essai | `mesure_correlation_cvm_ad_t8.R --essai` (B = 299) | (c1) à (c5) conformes |
| #367, essai | `mesure_b_dossier_t8.R --grubbs-interieur --essai` (B = 199) | (g0) à (g3) et (c) conformes |
| #379 lognormal | `puissance_t8.R --familles --essai --n 1 --jeu J1 --points N,A+0.5 --coeurs 1` | `INTEGRITE OK` ; 10 issues de b = 1 concordantes avec le brut versé |
| #379 et #494 Merz-Wüthrich | `puissance_mw_t8.R --familles --essai --n 1 --cellules P1.H0,P1.AR05 --coeurs 2` | `INTEGRITE OK` ; (ar0) 100/100, (ar1) écart 2,0e-14, (i2) 2 OK, recoupement #309 conforme |
| Empreintes des tableaux | md5 des scripts aux commits de calcul et à la tête ; md5 des bruts | scripts inchangés depuis `6e0c7b6`, md5 égaux aux T0 ; bruts égaux aux T0 ; brut de #309 égal |
| Agrégats de #367 | `binom`, `qbeta`, `chisq.test` | p̂ = 0,100485 ; IC 99 % [0,096648 ; 0,104418] ; χ² p = 0,6861 : identiques |
| Signal PM-3 lognormal | `binom.test(14, 40)` | 0,0807 bilatéral, 0,0403 unilatéral : identiques à F1 |
| Mots-clés, auteurs | `git log 9f9efc2..HEAD --format=%B`, `%an <%ae>` | aucun mot-clé ; 46 commits `Claude <noreply@anthropic.com>` |
| Non exécuté | `mesure_dw_rho_negatif_t8.R` complet | refusé par le classifieur de permissions ; tableau de #421 vérifié sur les lignes déterministes et les empreintes |

## Points de contrôle

- **Correction** : formules conformes aux en-têtes et aux avis (p laisser-un-de-côté `(1 + n − rang_min)/n` ; jackknife par groupes ; Clopper–Pearson par `qbeta` ; `gr_classe()` ; binomiale exacte bilatérale de K421-2 ; McNemar unilatéral `alternative = "less"` ; Fisher unilatéral). `gen_triangle_ar1()` consomme l'aléa dans l'ordre de `gen_triangle_h0()` ((ar0) à ρ = 0). `tirer_e()` en `byrow = TRUE`. p-values bornées, aucun `NaN` silencieux.
- **Architecture** : ni `R/`, ni `app.R`, ni `DESCRIPTION` touchés ; scripts en R base, `stats`, `utils`, `tools`, `parallel`.
- **Reproductibilité** : tirages nouveaux par `engine_sous_graine()` ; graines explicites (421 000 000 + T ; 36 100 001 à 36 100 004 ; 20 260 931) ; (g) vert ; aucune référence régénérée.
- **Traçabilité code ↔ `.tex` ↔ tableaux** : chaque affirmation nouvelle recoupée avec les tableaux versés (#421, #420, #367, #494, #379), toutes tiennent ; « quatre paires de colonnes au plus » exact.
- **Garde d'écrasement** : `mesure_correlation_cvm_ad_t8.R` enregistré dans `SCRIPTS_ECRIRE`, `GARDES_ANTICIPEES` et `CAS_A` (`db53649`) : reste à faire soldé.

## Constats

### Bloquants
Aucun.

### Majeurs
Aucun.

### Mineurs (dans le périmètre)

**m1 — Gardes anticipées du mode `--familles --ecrire` non exercées par un test d'exécution.** `tests/puissance_t8.R:1565`, `tests/puissance_mw_t8.R:2977` ; `CAS_A` (`tests/unitaires/test_garde_ecrasement.R:681-697`) ne lance jamais `--familles --ecrire`, et le test statique est satisfait par la première garde du fichier. Correction suggérée : second cas `c("--familles", "--ecrire")` pour chaque script.

**m2 — La classe « faible » couvre aussi une puissance significativement inférieure au niveau.** `classe_puissance()` des deux scripts : p < 0,05 avec π̂(s) < π̂(H0) donne « faible ». Aucune occurrence dans les tableaux versés ; le code applique fidèlement le § 4.5 de l'avis. Qui tranche : `actuary`, convention de classe.

### Hors périmètre
Aucun.

## Points de procédure
- PDF du `.tex` non encore commité (ADR 0008 amendé : commit de la session avant la sortie du brouillon).
- Référence `main` locale périmée : `git fetch origin main` avant tout contrôle `main..HEAD`.

## Constats mineurs écartés (ADR 0018), proposition
- Séparateur décimal mixte dans les tableaux de #420 et #367 (« 0.10251 », « α = 0.1 ») — critère : aucun.
- Recoupement de deux graines de bootstrap du mode `--familles` lognormal (b = 1 et 2) avec la plage de #297, jeux de données différents — critère : aucun.
- m1 et m2, si non repris — critère : aucun.
