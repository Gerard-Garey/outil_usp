# Tableau avant / après — référence `reserve2` (issue #37)

- Date : 2026-09-25
- Plateforme : R version 4.3.1 (2023-06-16), Linux
- Commande : `Rscript tests/regenerer_et_rendre_compte.R premium --attendu '^plots_data\$influence\$fort_ecart_sigma' --attendu '^metadata\$generateur' --attendu '^metadata\$seed_loi_nulle_sw$' --attendu '^metadata\$seed_enveloppe_qq$' reserve1 --attendu '^plots_data\$influence\$fort_ecart_sigma' --attendu '^metadata\$generateur' --attendu '^metadata\$seed_loi_nulle_sw$' --attendu '^metadata\$seed_enveloppe_qq$' reserve2 --attendu '^plots_data\$influence\$fort_dfbeta' --attendu '^metadata\$generateur' --atte… (920 car.)`
- Motifs attendus : `^plots_data\$influence\$fort_dfbeta`, `^metadata\$generateur`, `^metadata\$seed_loi_nulle_sw$`
- Exécution à plusieurs cas (M33) : `premium`, `reserve1`, `reserve2`, `premium_ii6`, `premium_net`, chacun avec ses motifs ; tout ou rien ; batteries relancées une seule fois, après le dernier cas
- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil 0 pour lister, seuil 1e-06 pour juger ; `INSTABLES` non neutralisé

**Synthèse** : 4225 feuille(s) dans l'ancienne référence, 4256 dans le résultat recalculé ; 31 non strictement identique(s) (dont 31 en écart au seuil 1e-06, 31 ajoutée(s), 0 supprimée(s)), toutes désignées par les motifs attendus ; 4225 feuille(s) identique(s) au bit près ; écart numérique maximal 0.000e+00.

Nœuds de structure modifiés (type ou attributs) : `plots_data$influence`, `metadata`, `plots_data$influence$fort_dfbeta`, `metadata$generateur`, `metadata$generateur$kind`, `metadata$generateur$normal.kind`, `metadata$generateur$sample.kind`, `metadata$seed_loi_nulle_sw`

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `plots_data$influence$fort_dfbeta[1]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[2]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[3]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[4]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[5]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[6]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[7]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[8]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[9]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[10]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[11]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[12]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[13]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[14]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[15]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[16]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[17]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[18]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[19]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[20]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[21]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[22]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[23]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[24]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[25]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[26]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbeta[27]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `metadata$generateur$kind` | (absente) | Mersenne-Twister |  | ajoutée (absente avant) |
| `metadata$generateur$normal.kind` | (absente) | Inversion |  | ajoutée (absente avant) |
| `metadata$generateur$sample.kind` | (absente) | Rejection |  | ajoutée (absente avant) |
| `metadata$seed_loi_nulle_sw` | (absente) | 20260901 |  | ajoutée (absente avant) |

## Batteries

- `Rscript tests/test_reproductibilite.R` : code de sortie 0
  - `premium     sigma_USP = 0.1114524359  (25 s)`
  - `CONFORME : 12419 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve1    sigma_USP = 0.1073524359  (22 s)`
  - `CONFORME : 12418 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve2    sigma_USP = 0.0497764613  (77 s)`
  - `CONFORME : 4256 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_ii6 sigma_USP = 0.1483524359  (22 s)`
  - `CONFORME : 12419 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_net sigma_USP = 0.1032524359  (22 s)`
  - `CONFORME : 12419 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `OK : reproductibilite et non-regression verifiees pour 5 cas.`
- `Rscript tests/test_unitaires.R` : code de sortie 0
  - `TOTAL : 779 assertions, 779 ok, 0 echec(s), 0 echec(s) attendu(s) (defauts connus), 0 succes inattendu(s)`
  - `OK`
