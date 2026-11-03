# Tableau avant / après — référence `premium_net` (issue #404)

- Date : 2026-11-03
- Plateforme : R version 4.3.1 (2023-06-16), Linux
- Commande : `Rscript tests/regenerer_et_rendre_compte.R premium --attendu '^plots_data\$surface\$objectif_coupe(\[[0-9]+\])?$' --attendu '^plots_data\$influence\$non_evaluable(\[[0-9]+\])?$' reserve1 --attendu '^plots_data\$surface\$objectif_coupe(\[[0-9]+\])?$' --attendu '^plots_data\$influence\$non_evaluable(\[[0-9]+\])?$' premium_ii6 --attendu '^plots_data\$surface\$objectif_coupe(\[[0-9]+\])?$' --attendu '^plots_data\$influence\$non_evaluable(\[[0-9]+\])?$' premium_net --attendu '^plots_data\$surface\$o… (869 car.)`
- Motifs attendus : `^plots_data\$surface\$objectif_coupe(\[[0-9]+\])?$`, `^plots_data\$influence\$non_evaluable(\[[0-9]+\])?$`
- Exécution à plusieurs cas (M33) : `premium`, `reserve1`, `premium_ii6`, `premium_net`, `premium_interieur`, `reserve2`, chacun avec ses motifs ; tout ou rien ; batteries relancées une seule fois, après le dernier cas
- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil 0 pour lister, seuil 1e-06 pour juger ; `INSTABLES` non neutralisé

**Synthèse** : 56964 feuille(s) dans l'ancienne référence, 57017 dans le résultat recalculé ; 53 non strictement identique(s) (dont 53 en écart au seuil 1e-06, 53 ajoutée(s), 0 supprimée(s)), toutes désignées par les motifs attendus ; 56964 feuille(s) identique(s) au bit près ; écart numérique maximal 0.000e+00.

Nœuds de structure modifiés (type ou attributs) : `plots_data$surface`, `plots_data$influence`, `plots_data$surface$objectif_coupe`, `plots_data$influence$non_evaluable`

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `plots_data$surface$objectif_coupe[1]` | (absente) | -22.46396101 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[2]` | (absente) | -22.47781711 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[3]` | (absente) | -22.49162166 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[4]` | (absente) | -22.50537525 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[5]` | (absente) | -22.51907849 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[6]` | (absente) | -22.53273196 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[7]` | (absente) | -22.54633627 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[8]` | (absente) | -22.55989198 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[9]` | (absente) | -22.57339968 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[10]` | (absente) | -22.58685993 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[11]` | (absente) | -22.60027329 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[12]` | (absente) | -22.61364032 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[13]` | (absente) | -22.62696158 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[14]` | (absente) | -22.6402376 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[15]` | (absente) | -22.65346892 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[16]` | (absente) | -22.66665608 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[17]` | (absente) | -22.6797996 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[18]` | (absente) | -22.69290002 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[19]` | (absente) | -22.70595784 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[20]` | (absente) | -22.71897357 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[21]` | (absente) | -22.73194773 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[22]` | (absente) | -22.74488082 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[23]` | (absente) | -22.75777332 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[24]` | (absente) | -22.77062574 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[25]` | (absente) | -22.78343856 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[26]` | (absente) | -22.79621226 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[27]` | (absente) | -22.80894732 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[28]` | (absente) | -22.82164421 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[29]` | (absente) | -22.83430339 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[30]` | (absente) | -22.84692534 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[31]` | (absente) | -22.85951051 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[32]` | (absente) | -22.87205936 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[33]` | (absente) | -22.88457232 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[34]` | (absente) | -22.89704986 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[35]` | (absente) | -22.90949241 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[36]` | (absente) | -22.92190041 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[37]` | (absente) | -22.93427429 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[38]` | (absente) | -22.94661449 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[39]` | (absente) | -22.95892142 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[40]` | (absente) | -22.97119551 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[41]` | (absente) | -22.98343718 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[42]` | (absente) | -22.99564684 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[43]` | (absente) | -23.0078249 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[44]` | (absente) | -23.01997176 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[45]` | (absente) | -23.03208784 |  | ajoutée (absente avant) |
| `plots_data$influence$non_evaluable[1]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$non_evaluable[2]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$non_evaluable[3]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$non_evaluable[4]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$non_evaluable[5]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$non_evaluable[6]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$non_evaluable[7]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$non_evaluable[8]` | (absente) | FALSE |  | ajoutée (absente avant) |

## Batteries

- `Rscript tests/test_reproductibilite.R` : code de sortie 0
  - `premium     sigma_USP = 0.1114524114  (19 s)`
  - `CONFORME : 57017 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve1    sigma_USP = 0.1073524114  (17 s)`
  - `CONFORME : 57016 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve2    sigma_USP = 0.0497764613  (37 s)`
  - `CONFORME : 18724 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_ii6 sigma_USP = 0.1483524114  (17 s)`
  - `CONFORME : 57017 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_net sigma_USP = 0.1032524114  (17 s)`
  - `CONFORME : 57017 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_interieur sigma_USP = 0.0871308679  (32 s)`
  - `CONFORME : 57017 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `OK : reproductibilite et non-regression verifiees pour 6 cas.`
- `Rscript tests/test_unitaires.R` : code de sortie 0
  - `TOTAL : 2844 assertions, 2844 ok, 0 echec(s), 0 echec(s) attendu(s) (defauts connus), 0 succes inattendu(s)`
  - `OK`
