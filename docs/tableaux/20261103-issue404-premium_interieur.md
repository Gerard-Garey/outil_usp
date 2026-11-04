# Tableau avant / après — référence `premium_interieur` (issue #404)

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
| `plots_data$surface$objectif_coupe[1]` | (absente) | -28.24732259 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[2]` | (absente) | -28.25309823 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[3]` | (absente) | -28.25926481 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[4]` | (absente) | -28.26577616 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[5]` | (absente) | -28.27258843 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[6]` | (absente) | -28.27965975 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[7]` | (absente) | -28.2869498 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[8]` | (absente) | -28.29441955 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[9]` | (absente) | -28.30203094 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[10]` | (absente) | -28.30974659 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[11]` | (absente) | -28.31752956 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[12]` | (absente) | -28.32534306 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[13]` | (absente) | -28.33315026 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[14]` | (absente) | -28.34091399 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[15]` | (absente) | -28.34859653 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[16]` | (absente) | -28.35615936 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[17]` | (absente) | -28.36356293 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[18]` | (absente) | -28.37076635 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[19]` | (absente) | -28.3777272 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[20]` | (absente) | -28.38440116 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[21]` | (absente) | -28.39074178 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[22]` | (absente) | -28.39670011 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[23]` | (absente) | -28.40222437 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[24]` | (absente) | -28.40725956 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[25]` | (absente) | -28.41174703 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[26]` | (absente) | -28.41562403 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[27]` | (absente) | -28.41882319 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[28]` | (absente) | -28.42127193 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[29]` | (absente) | -28.42289182 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[30]` | (absente) | -28.4235979 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[31]` | (absente) | -28.42329778 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[32]` | (absente) | -28.42189077 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[33]` | (absente) | -28.41926682 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[34]` | (absente) | -28.41530528 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[35]` | (absente) | -28.40987356 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[36]` | (absente) | -28.40282548 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[37]` | (absente) | -28.39399946 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[38]` | (absente) | -28.38321638 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[39]` | (absente) | -28.37027705 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[40]` | (absente) | -28.35495934 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[41]` | (absente) | -28.33701467 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[42]` | (absente) | -28.31616398 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[43]` | (absente) | -28.2920929 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[44]` | (absente) | -28.26444597 |  | ajoutée (absente avant) |
| `plots_data$surface$objectif_coupe[45]` | (absente) | -28.23281971 |  | ajoutée (absente avant) |
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
