# Tableau avant / après — référence `premium` (issue #40)

- Date : 2026-09-24
- Plateforme : R version 4.3.1 (2023-06-16), Linux
- Commande : `Rscript tests/regenerer_et_rendre_compte.R premium --attendu 'err_mc' --attendu 'stats_obs\$Spear(Vol|Tps)$' --attendu '^tests\[\[10\]\]\$loi$' --attendu 'granularite_stat' reserve1 --attendu 'err_mc' --attendu 'stats_obs\$Spear(Vol|Tps)$' --attendu '^tests\[\[10\]\]\$loi$' --attendu 'granularite_stat' reserve2 --attendu 'err_mc' --attendu 'stats_obs\$(Intercept|PenteIntra)$' --attendu '(p_mc|B_effectif)\["(Intercept|PenteIntra)"\]$' --attendu 'granularite_stat' premium_ii6 --attendu 'err_mc' -… (620 car.)`
- Motifs attendus : `err_mc`, `stats_obs\$Spear(Vol|Tps)$`, `^tests\[\[10\]\]\$loi$`, `granularite_stat`
- Exécution à plusieurs cas (M33) : `premium`, `reserve1`, `reserve2`, `premium_ii6`, chacun avec ses motifs ; tout ou rien ; batteries relancées une seule fois, après le dernier cas
- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil 0 pour lister, seuil 1e-06 pour juger ; `INSTABLES` non neutralisé

**Synthèse** : 12370 feuille(s) dans l'ancienne référence, 12404 dans le résultat recalculé ; 57 non strictement identique(s) (dont 57 en écart au seuil 1e-06, 34 ajoutée(s), 0 supprimée(s)), toutes désignées par les motifs attendus ; 12347 feuille(s) identique(s) au bit près ; écart numérique maximal 1.261e+03 (relatif, `bootstrap$stats_obs$SpearVol`).

Nœuds de structure modifiés (type ou attributs) : `bootstrap`, `bootstrap$granularite_stat`

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `bootstrap$granularite_stat["AD"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["CvM"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["KS"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["SW"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["SF"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["JB"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["DW"]` | (absente) | 0.002 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["LB1"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["supF"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["CUSUM"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["Grubbs"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["Lillie"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["Intercept"]` | (absente) | 0.002 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["RESET"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["BP"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["BP79"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["White"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["GQ"]` | (absente) | 0.002 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["BF"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["Smirnov"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["LB2"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["BP2"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["Runs"]` | (absente) | 0.002 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["MK"]` | (absente) | 0.002 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["SpearVol"]` | (absente) | 0.002 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["SpearTps"]` | (absente) | 0.002 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["DAgo"]` | (absente) | 0.002 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["CoxStuart"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["DWr"]` | (absente) | 0.002 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["LB1r"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["Runsr"]` | (absente) | 0.002 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["supFr"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["CUSUMr"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["Grubbsr"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `tests[[1]]$err_mc` | 0.007274401482 | 0.03158895158 | 3.342e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[7]]$err_mc` | 0.01035486471 | 0.03140226269 | 2.033e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[8]]$err_mc` | 0.01057013376 | 0.03137834605 | 1.969e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[9]]$err_mc` | 0.01355063171 | 0.030698182 | 1.265e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[10]]$loi` | Binomiale(m, 1/2) EXACTE | Binomiale(m, 1/2) EXACTE, m differences non nulles ; p_mc p… (98 car.) |  | non numerique |
| `tests[[14]]$err_mc` | 0.01241185135 | 0.01855382021 | 4.948e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[26]]$err_mc` | 0.01438551156 | 0.03025973648 | 1.103e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[28]]$err_mc` | 0.01571250721 | 0.02838030024 | 8.062e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[32]]$err_mc` | 0.01347358666 | 0.03072946957 | 1.281e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[40]]$err_mc` | 0.01568087657 | 0.02850362181 | 8.177e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[42]]$err_mc` | 0.01335493745 | 0.03077536552 | 1.304e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_obs$SpearVol` | -0.07142857143 | 90 | 1.261e+03 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_obs$SpearTps` | 0.09523809524 | 76 | 7.970e+02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$err_mc["DW"]` | 0.01571250721 | 0.02838030024 | 8.062e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$err_mc["Intercept"]` | 0.007274401482 | 0.03158895158 | 3.342e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$err_mc["GQ"]` | 0.01241185135 | 0.01855382021 | 4.948e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$err_mc["Runs"]` | 0.01347358666 | 0.03072946957 | 1.281e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$err_mc["MK"]` | 0.01355063171 | 0.030698182 | 1.265e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$err_mc["SpearVol"]` | 0.01035486471 | 0.03140226269 | 2.033e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$err_mc["SpearTps"]` | 0.01057013376 | 0.03137834605 | 1.969e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$err_mc["DAgo"]` | 0.01438551156 | 0.03025973648 | 1.103e+00 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$err_mc["DWr"]` | 0.01568087657 | 0.02850362181 | 8.177e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$err_mc["Runsr"]` | 0.01335493745 | 0.03077536552 | 1.304e+00 | relatif, au-delà du seuil 1e-06 |

## Batteries

- `Rscript tests/test_reproductibilite.R` : code de sortie 0
  - `premium     sigma_USP = 0.1114524359  (27 s)`
  - `CONFORME : 12404 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve1    sigma_USP = 0.1073524359  (22 s)`
  - `CONFORME : 12404 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve2    sigma_USP = 0.0497764613  (76 s)`
  - `CONFORME : 4224 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_ii6 sigma_USP = 0.1483524359  (22 s)`
  - `CONFORME : 12404 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `OK : reproductibilite et non-regression verifiees pour 4 cas.`
- `Rscript tests/test_unitaires.R` : code de sortie 0
  - `TOTAL : 678 assertions, 665 ok, 0 echec(s), 13 echec(s) attendu(s) (defauts connus), 0 succes inattendu(s)`
  - `OK`
