# Tableau avant / après — référence `premium_net` (issue #405)

- Date : 2026-11-03
- Plateforme : R version 4.3.1 (2023-06-16), Linux
- Commande : `Rscript tests/regenerer_et_rendre_compte.R premium --attendu '^plots_data\$lr_delta\$seuil_asymptotique$' --attendu '^plots_data\$lr_delta\$q90_bootstrap' --attendu '^plots_data\$lr_delta\$repere_asymptotique$' --attendu '^plots_data\$lr_delta\$quantile_bootstrap' reserve1 --attendu '^plots_data\$lr_delta\$seuil_asymptotique$' --attendu '^plots_data\$lr_delta\$q90_bootstrap' --attendu '^plots_data\$lr_delta\$repere_asymptotique$' --attendu '^plots_data\$lr_delta\$quantile_bootstrap' premium_ii6… (1192 car.)`
- Motifs attendus : `^plots_data\$lr_delta\$seuil_asymptotique$`, `^plots_data\$lr_delta\$q90_bootstrap`, `^plots_data\$lr_delta\$repere_asymptotique$`, `^plots_data\$lr_delta\$quantile_bootstrap`
- Exécution à plusieurs cas (M33) : `premium`, `reserve1`, `premium_ii6`, `premium_net`, `premium_interieur`, chacun avec ses motifs ; tout ou rien ; batteries relancées une seule fois, après le dernier cas
- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil 0 pour lister, seuil 1e-06 pour juger ; `INSTABLES` non neutralisé

**Synthèse** : 56937 feuille(s) dans l'ancienne référence, 56937 dans le résultat recalculé ; 6 non strictement identique(s) (dont 6 en écart au seuil 1e-06, 3 ajoutée(s), 3 supprimée(s)), toutes désignées par les motifs attendus ; 56934 feuille(s) identique(s) au bit près ; écart numérique maximal 0.000e+00.

Nœuds de structure modifiés (type ou attributs) : `plots_data$lr_delta`, `plots_data$lr_delta$seuil_asymptotique`, `plots_data$lr_delta$q90_bootstrap`, `plots_data$lr_delta$repere_asymptotique`, `plots_data$lr_delta$quantile_bootstrap`

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `plots_data$lr_delta$seuil_asymptotique` | -21.38971342 | (absente) |  | supprimée (absente après) |
| `plots_data$lr_delta$q90_bootstrap["delta0"]` | -22.63250855 | (absente) |  | supprimée (absente après) |
| `plots_data$lr_delta$q90_bootstrap["delta1"]` | -22.6377591 | (absente) |  | supprimée (absente après) |
| `plots_data$lr_delta$repere_asymptotique` | (absente) | -21.38971342 |  | ajoutée (absente avant) |
| `plots_data$lr_delta$quantile_bootstrap["delta0"]` | (absente) | -22.63250855 |  | ajoutée (absente avant) |
| `plots_data$lr_delta$quantile_bootstrap["delta1"]` | (absente) | -22.6377591 |  | ajoutée (absente avant) |

## Batteries

- `Rscript tests/test_reproductibilite.R` : code de sortie 0
  - `premium     sigma_USP = 0.1114524114  (20 s)`
  - `CONFORME : 56937 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve1    sigma_USP = 0.1073524114  (18 s)`
  - `CONFORME : 56936 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve2    sigma_USP = 0.0497764613  (40 s)`
  - `CONFORME : 18694 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_ii6 sigma_USP = 0.1483524114  (18 s)`
  - `CONFORME : 56937 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_net sigma_USP = 0.1032524114  (18 s)`
  - `CONFORME : 56937 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_interieur sigma_USP = 0.0871308679  (33 s)`
  - `CONFORME : 56937 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `OK : reproductibilite et non-regression verifiees pour 6 cas.`
- `Rscript tests/test_unitaires.R` : code de sortie 0
  - `TOTAL : 2818 assertions, 2818 ok, 0 echec(s), 0 echec(s) attendu(s) (defauts connus), 0 succes inattendu(s)`
  - `OK`
