# Tableau avant / après — référence `reserve2` (issue #89)

- Date : 2026-10-06
- Plateforme : R version 4.3.1 (2023-06-16), Linux
- Commande : `Rscript tests/regenerer_et_rendre_compte.R reserve2 --attendu '^plots_data\$influence\$(dfbetas|repere_dfbetas|fort_dfbetas?|dfbetas_non_borne)' --issue 89 --ecrire`
- Motifs attendus : `^plots_data\$influence\$(dfbetas|repere_dfbetas|fort_dfbetas?|dfbetas_non_borne)`
- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil 0 pour lister, seuil 1e-06 pour juger ; `INSTABLES` non neutralisé

**Synthèse** : 4329 feuille(s) dans l'ancienne référence, 4410 dans le résultat recalculé ; 135 non strictement identique(s) (dont 135 en écart au seuil 1e-06, 108 ajoutée(s), 27 supprimée(s)), toutes désignées par les motifs attendus ; 4302 feuille(s) identique(s) au bit près ; écart numérique maximal 0.000e+00.

**Avertissement** : motif `^plots_data\$influence\$(dfbetas|repere_dfbetas|fort_dfbetas?|dfbetas_non_borne)` : 135 feuilles désignées (seuil d'avertissement 50) ; vérifier qu'il n'est pas trop large.

Nœuds de structure modifiés (type ou attributs) : `plots_data$influence`, `plots_data$influence$fort_dfbeta`, `plots_data$influence$dfbetas`, `plots_data$influence$repere_dfbetas`, `plots_data$influence$fort_dfbetas`, `plots_data$influence$dfbetas_non_borne`

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `plots_data$influence$fort_dfbeta[1]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[2]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[3]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[4]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[5]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[6]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[7]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[8]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[9]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[10]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[11]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[12]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[13]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[14]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[15]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[16]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[17]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[18]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[19]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[20]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[21]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[22]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[23]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[24]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[25]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[26]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$fort_dfbeta[27]` | FALSE | (absente) |  | supprimée (absente après) |
| `plots_data$influence$dfbetas[1]` | (absente) | 0.04057869902 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[2]` | (absente) | -0.4719166776 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[3]` | (absente) | -0.6786112821 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[4]` | (absente) | -0.1908112636 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[5]` | (absente) | 0.3711102056 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[6]` | (absente) | 0.6880469713 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[7]` | (absente) | 0.2257039248 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[8]` | (absente) | -0.4612054682 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[9]` | (absente) | -0.6497426416 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[10]` | (absente) | -0.1805742034 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[11]` | (absente) | 0.3674231771 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[12]` | (absente) | 0.7055792051 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[13]` | (absente) | 0.2327317367 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[14]` | (absente) | -1.102437857 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[15]` | (absente) | -0.2945999717 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[16]` | (absente) | 0.2983523826 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[17]` | (absente) | 0.6562695479 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[18]` | (absente) | 0.1559392101 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[19]` | (absente) | -1.497598725 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[20]` | (absente) | 0.2005790886 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[21]` | (absente) | 0.7709618857 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[22]` | (absente) | -0.05293468344 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[23]` | (absente) | -0.04428955592 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[24]` | (absente) | 1.526553247 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[25]` | (absente) | -1.102541799 |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[26]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas[27]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[1]` | (absente) | 0.755928946 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[2]` | (absente) | 0.755928946 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[3]` | (absente) | 0.755928946 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[4]` | (absente) | 0.755928946 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[5]` | (absente) | 0.755928946 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[6]` | (absente) | 0.755928946 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[7]` | (absente) | 0.755928946 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[8]` | (absente) | 0.8164965809 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[9]` | (absente) | 0.8164965809 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[10]` | (absente) | 0.8164965809 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[11]` | (absente) | 0.8164965809 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[12]` | (absente) | 0.8164965809 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[13]` | (absente) | 0.8164965809 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[14]` | (absente) | 0.894427191 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[15]` | (absente) | 0.894427191 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[16]` | (absente) | 0.894427191 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[17]` | (absente) | 0.894427191 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[18]` | (absente) | 0.894427191 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[19]` | (absente) | 1 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[20]` | (absente) | 1 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[21]` | (absente) | 1 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[22]` | (absente) | 1 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[23]` | (absente) | 1.154700538 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[24]` | (absente) | 1.154700538 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[25]` | (absente) | 1.154700538 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[26]` | (absente) | 1.414213562 |  | ajoutée (absente avant) |
| `plots_data$influence$repere_dfbetas[27]` | (absente) | 1.414213562 |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[1]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[2]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[3]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[4]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[5]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[6]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[7]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[8]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[9]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[10]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[11]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[12]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[13]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[14]` | (absente) | TRUE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[15]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[16]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[17]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[18]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[19]` | (absente) | TRUE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[20]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[21]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[22]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[23]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[24]` | (absente) | TRUE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[25]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[26]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$fort_dfbetas[27]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[1]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[2]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[3]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[4]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[5]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[6]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[7]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[8]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[9]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[10]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[11]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[12]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[13]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[14]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[15]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[16]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[17]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[18]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[19]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[20]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[21]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[22]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[23]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[24]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[25]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[26]` | (absente) | FALSE |  | ajoutée (absente avant) |
| `plots_data$influence$dfbetas_non_borne[27]` | (absente) | FALSE |  | ajoutée (absente avant) |

## Batteries

- `Rscript tests/test_reproductibilite.R` : code de sortie 0
  - `premium     sigma_USP = 0.1114524114  (34 s)`
  - `CONFORME : 23737 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve1    sigma_USP = 0.1073524114  (30 s)`
  - `CONFORME : 23736 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve2    sigma_USP = 0.0497764613  (88 s)`
  - `CONFORME : 4410 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_ii6 sigma_USP = 0.1483524114  (29 s)`
  - `CONFORME : 23737 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_net sigma_USP = 0.1032524114  (29 s)`
  - `CONFORME : 23737 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `OK : reproductibilite et non-regression verifiees pour 5 cas.`
- `Rscript tests/test_unitaires.R` : code de sortie 0
  - `TOTAL : 1524 assertions, 1524 ok, 0 echec(s), 0 echec(s) attendu(s) (defauts connus), 0 succes inattendu(s)`
  - `OK`
