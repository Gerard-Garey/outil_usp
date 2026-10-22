# Tableau avant / après — référence `premium_net` (issue #299)

- Date : 2026-10-20
- Plateforme : R version 4.3.1 (2023-06-16), Linux
- Commande : `Rscript tests/regenerer_et_rendre_compte.R premium --attendu '^tests\[\[(8|1[1-6])\]\]' premium_net --attendu '^tests\[\[(8|1[1-6])\]\]' premium_ii6 --attendu '^tests\[\[(8|1[1-6])\]\]' reserve1 --attendu '^tests\[\[(8|1[1-6])\]\]' premium_interieur --attendu '^tests\[\[(8|1[1-6])\]\]' --issue 299 --ecrire`
- Motifs attendus : `^tests\[\[(8|1[1-6])\]\]`
- Exécution à plusieurs cas (M33) : `premium`, `premium_net`, `premium_ii6`, `reserve1`, `premium_interieur`, chacun avec ses motifs ; tout ou rien ; batteries relancées une seule fois, après le dernier cas
- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil 0 pour lister, seuil 1e-06 pour juger ; `INSTABLES` non neutralisé

**Synthèse** : 23715 feuille(s) dans l'ancienne référence, 23715 dans le résultat recalculé ; 37 non strictement identique(s) (dont 37 en écart au seuil 1e-06, 0 ajoutée(s), 0 supprimée(s)), toutes désignées par les motifs attendus ; 23678 feuille(s) identique(s) au bit près ; écart numérique maximal 0.000e+00.

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `tests[[8]]$type` | test | diagnostic |  | non numerique |
| `tests[[8]]$p_retenue` | 0.8401289683 | \<NA\> |  | non fini |
| `tests[[8]]$nature_p` | exacte | \<NA\> |  | non numerique |
| `tests[[8]]$verdict` | OK | INFO |  | non numerique |
| `tests[[8]]$detail` |  | Restituee en diagnostic par decision (issue #299) : aucun v… (196 car.) |  | non numerique |
| `tests[[8]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[11]]$detail` | …on pi_t est correcte (62 car., 1re différence au car. 63) | …on pi_t est correcte. Puissance maximale, au seuil alpha = 0… (361 car., 1re différence au car. 63) |  | non numerique |
| `tests[[12]]$type` | test | diagnostic |  | non numerique |
| `tests[[12]]$p_retenue` | 0.09 | \<NA\> |  | non fini |
| `tests[[12]]$nature_p` | Monte-Carlo (bootstrap parametrique) | \<NA\> |  | non numerique |
| `tests[[12]]$verdict` | ALERTE | INFO |  | non numerique |
| `tests[[12]]$detail` | … sont pas normales. A confronter systematiquement a la versi… (283 car., 1re différence au car. 131) | … sont pas normales. Restituee en diagnostic par decision (is… (333 car., 1re différence au car. 131) |  | non numerique |
| `tests[[12]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[13]]$type` | test | diagnostic |  | non numerique |
| `tests[[13]]$p_retenue` | 0.067 | \<NA\> |  | non fini |
| `tests[[13]]$nature_p` | Monte-Carlo (bootstrap parametrique) | \<NA\> |  | non numerique |
| `tests[[13]]$verdict` | ALERTE | INFO |  | non numerique |
| `tests[[13]]$detail` |  | Restituee en diagnostic par decision (issue #299) : aucun v… (203 car.) |  | non numerique |
| `tests[[13]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[14]]$type` | test | diagnostic |  | non numerique |
| `tests[[14]]$p_retenue` | 0.19 | \<NA\> |  | non fini |
| `tests[[14]]$nature_p` | Monte-Carlo (bootstrap parametrique) | \<NA\> |  | non numerique |
| `tests[[14]]$verdict` | OK | INFO |  | non numerique |
| `tests[[14]]$detail` |  | Restituee en diagnostic par decision (issue #299) : aucun v… (203 car.) |  | non numerique |
| `tests[[14]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[15]]$type` | test | diagnostic |  | non numerique |
| `tests[[15]]$p_retenue` | 0.104 | \<NA\> |  | non fini |
| `tests[[15]]$nature_p` | Monte-Carlo (bootstrap parametrique) | \<NA\> |  | non numerique |
| `tests[[15]]$verdict` | OK | INFO |  | non numerique |
| `tests[[15]]$detail` | verdict sensible a l'alea de simulation (p a moins de 2 err… (88 car.) | Restituee en diagnostic par decision (issue #299) : aucun v… (203 car.) |  | non numerique |
| `tests[[15]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[16]]$type` | test | diagnostic |  | non numerique |
| `tests[[16]]$p_retenue` | 0.7714285714 | \<NA\> |  | non fini |
| `tests[[16]]$nature_p` | exacte | \<NA\> |  | non numerique |
| `tests[[16]]$verdict` | OK | INFO |  | non numerique |
| `tests[[16]]$detail` | … totalement separes) (146 car., 1re différence au car. 147) | … totalement separes). Restituee en diagnostic par decision (… (414 car., 1re différence au car. 147) |  | non numerique |
| `tests[[16]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |

## Batteries

- `Rscript tests/test_reproductibilite.R` : code de sortie 0
  - `premium     sigma_USP = 0.1114524114  (9 s)`
  - `CONFORME : 23715 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve1    sigma_USP = 0.1073524114  (8 s)`
  - `CONFORME : 23714 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve2    sigma_USP = 0.0497764613  (17 s)`
  - `CONFORME : 4470 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_ii6 sigma_USP = 0.1483524114  (8 s)`
  - `CONFORME : 23715 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_net sigma_USP = 0.1032524114  (8 s)`
  - `CONFORME : 23715 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_interieur sigma_USP = 0.0871308679  (15 s)`
  - `CONFORME : 23715 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `OK : reproductibilite et non-regression verifiees pour 6 cas.`
- `Rscript tests/test_unitaires.R` : code de sortie 0
  - `TOTAL : 2463 assertions, 2463 ok, 0 echec(s), 0 echec(s) attendu(s) (defauts connus), 0 succes inattendu(s)`
  - `OK`
