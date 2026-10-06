# Tableau avant / après — référence `reserve2` (issue #90)

- Date : 2026-10-06
- Plateforme : R version 4.3.1 (2023-06-16), Linux
- Commande : `Rscript tests/regenerer_et_rendre_compte.R reserve2 --attendu '^tests\[\[(3|7)\]\]\$(stat|p_asymptotique|p_mc|err_mc|p_retenue)$' --attendu '^bootstrap\$(stats_obs\$(HomogF|ExpVar)|(p_mc|err_mc)\["(HomogF|ExpVar)"\])$' --issue 90 --ecrire`
- Motifs attendus : `^tests\[\[(3|7)\]\]\$(stat|p_asymptotique|p_mc|err_mc|p_retenue)$`, `^bootstrap\$(stats_obs\$(HomogF|ExpVar)|(p_mc|err_mc)\["(HomogF|ExpVar)"\])$`
- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil 0 pour lister, seuil 1e-06 pour juger ; `INSTABLES` non neutralisé

**Synthèse** : 4329 feuille(s) dans l'ancienne référence, 4329 dans le résultat recalculé ; 16 non strictement identique(s) (dont 16 en écart au seuil 1e-06, 0 ajoutée(s), 0 supprimée(s)), toutes désignées par les motifs attendus ; 4313 feuille(s) identique(s) au bit près ; écart numérique maximal 7.796e-01 (relatif, `tests[[3]]$p_asymptotique`).

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `tests[[3]]$stat` | 13.86487191 | 11.9844729 | 1.356e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[3]]$p_asymptotique` | 0.08535618323 | 0.1518980095 | 7.796e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[3]]$p_mc` | 0.075 | 0.081 | 8.000e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[3]]$err_mc` | 0.008333333333 | 0.008632121032 | 3.585e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[3]]$p_retenue` | 0.075 | 0.081 | 8.000e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[7]]$stat` | 8.486109579 | 6.929875735 | 1.834e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[7]]$p_asymptotique` | 0.3874803603 | 0.5442171637 | 4.045e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[7]]$p_mc` | 0.347 | 0.425 | 2.248e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[7]]$err_mc` | 0.01506047203 | 0.01564032032 | 3.850e-02 | relatif, au-delà du seuil 1e-06 |
| `tests[[7]]$p_retenue` | 0.347 | 0.425 | 2.248e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_obs$HomogF` | 13.86487191 | 11.9844729 | 1.356e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$stats_obs$ExpVar` | 8.486109579 | 6.929875735 | 1.834e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$p_mc["HomogF"]` | 0.075 | 0.081 | 8.000e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$p_mc["ExpVar"]` | 0.347 | 0.425 | 2.248e-01 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$err_mc["HomogF"]` | 0.008333333333 | 0.008632121032 | 3.585e-02 | relatif, au-delà du seuil 1e-06 |
| `bootstrap$err_mc["ExpVar"]` | 0.01506047203 | 0.01564032032 | 3.850e-02 | relatif, au-delà du seuil 1e-06 |

## Batteries

- `Rscript tests/test_reproductibilite.R` : code de sortie 0
  - `premium     sigma_USP = 0.1114524114  (17 s)`
  - `CONFORME : 23737 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve1    sigma_USP = 0.1073524114  (15 s)`
  - `CONFORME : 23736 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve2    sigma_USP = 0.0497764613  (43 s)`
  - `CONFORME : 4329 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_ii6 sigma_USP = 0.1483524114  (15 s)`
  - `CONFORME : 23737 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_net sigma_USP = 0.1032524114  (16 s)`
  - `CONFORME : 23737 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `OK : reproductibilite et non-regression verifiees pour 5 cas.`
- `Rscript tests/test_unitaires.R` : code de sortie 0
  - `TOTAL : 1426 assertions, 1426 ok, 0 echec(s), 0 echec(s) attendu(s) (defauts connus), 0 succes inattendu(s)`
  - `OK`
