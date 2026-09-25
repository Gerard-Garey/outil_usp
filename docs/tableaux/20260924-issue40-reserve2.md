# Tableau avant / après — référence `reserve2` (issue #40)

- Date : 2026-09-24
- Plateforme : R version 4.3.1 (2023-06-16), Linux
- Commande : `Rscript tests/regenerer_et_rendre_compte.R premium --attendu 'err_mc' --attendu 'stats_obs\$Spear(Vol|Tps)$' --attendu '^tests\[\[10\]\]\$loi$' --attendu 'granularite_stat' reserve1 --attendu 'err_mc' --attendu 'stats_obs\$Spear(Vol|Tps)$' --attendu '^tests\[\[10\]\]\$loi$' --attendu 'granularite_stat' reserve2 --attendu 'err_mc' --attendu 'stats_obs\$(Intercept|PenteIntra)$' --attendu '(p_mc|B_effectif)\["(Intercept|PenteIntra)"\]$' --attendu 'granularite_stat' premium_ii6 --attendu 'err_mc' -… (620 car.)`
- Motifs attendus : `err_mc`, `stats_obs\$(Intercept|PenteIntra)$`, `(p_mc|B_effectif)\["(Intercept|PenteIntra)"\]$`, `granularite_stat`
- Exécution à plusieurs cas (M33) : `premium`, `reserve1`, `reserve2`, `premium_ii6`, chacun avec ses motifs ; tout ou rien ; batteries relancées une seule fois, après le dernier cas
- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil 0 pour lister, seuil 1e-06 pour juger ; `INSTABLES` non neutralisé

**Synthèse** : 4211 feuille(s) dans l'ancienne référence, 4224 dans le résultat recalculé ; 30 non strictement identique(s) (dont 30 en écart au seuil 1e-06, 17 ajoutée(s), 4 supprimée(s)), toutes désignées par les motifs attendus ; 4198 feuille(s) identique(s) au bit près ; écart numérique maximal 1.304e+00 (relatif, `tests[[1]]$err_mc`).

Nœuds de structure modifiés (type ou attributs) : `bootstrap`, `bootstrap$stats_obs`, `bootstrap$stats_obs$Intercept`, `bootstrap$p_mc`, `bootstrap$err_mc`, `bootstrap$B_effectif`, `bootstrap$stats_obs$PenteIntra`, `bootstrap$granularite_stat`

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `bootstrap$stats_obs$Intercept` | 0.2600197443 | (absente) |  | supprimée (absente après) |
| `bootstrap$p_mc["Intercept"]` | 0.768 | (absente) |  | supprimée (absente après) |
| `bootstrap$err_mc["Intercept"]` | 0.01335493745 | (absente) |  | supprimée (absente après) |
| `bootstrap$B_effectif["Intercept"]` | 999 | (absente) |  | supprimée (absente après) |
| `bootstrap$stats_obs$PenteIntra` | (absente) | 0.2600197443 |  | ajoutée (absente avant) |
| `bootstrap$p_mc["PenteIntra"]` | (absente) | 0.768 |  | ajoutée (absente avant) |
| `bootstrap$err_mc["PenteIntra"]` | (absente) | 0.03077536552 |  | ajoutée (absente avant) |
| `bootstrap$B_effectif["PenteIntra"]` | (absente) | 999 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["Calendrier"]` | (absente) | 0.002 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["CorrDev"]` | (absente) | 0.002 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["BP"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["Grubbs"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["DW"]` | (absente) | 0.002 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["Runs"]` | (absente) | 0.002 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["PenteIntra"]` | (absente) | 0.002 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["Origine"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["HomogF"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["Courbure"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["Alpha"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["ExpVar"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `bootstrap$granularite_stat["KruskalAcc"]` | (absente) | 0.001 |  | ajoutée (absente avant) |
| `tests[[1]]$err_mc` | 0.01335493745 | 0.03077536552 | 1.304e+00 | relatif, au-delà du seuil 1e-06 |
| `tests[[9]]$err_mc` | 0.001413505571 | 0.002 | 4.149e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[11]]$err_mc` | 0.01177211037 | 0.01745705441 | 4.829e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[12]]$err_mc` | 0.005397140829 | 0.007691499149 | 4.251e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[13]]$err_mc` | 0.01530876737 | 0.02467250966 | 6.117e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$err_mc["Calendrier"]` | 0.001413505571 | 0.002 | 4.149e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$err_mc["CorrDev"]` | 0.01177211037 | 0.01745705441 | 4.829e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$err_mc["DW"]` | 0.005397140829 | 0.007691499149 | 4.251e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$err_mc["Runs"]` | 0.01530876737 | 0.02467250966 | 6.117e-01 | relatif, au-delà du seuil 1e-06 |

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
