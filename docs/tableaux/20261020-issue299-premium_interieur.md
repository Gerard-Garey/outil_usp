# Tableau avant / après — référence `premium_interieur` (issue #299)

- Date : 2026-10-20
- Plateforme : R version 4.3.1 (2023-06-16), Linux
- Commande : `Rscript tests/regenerer_et_rendre_compte.R premium --attendu '^tests\[\[(8|1[1-6])\]\]' premium_net --attendu '^tests\[\[(8|1[1-6])\]\]' premium_ii6 --attendu '^tests\[\[(8|1[1-6])\]\]' reserve1 --attendu '^tests\[\[(8|1[1-6])\]\]' premium_interieur --attendu '^tests\[\[(8|1[1-6])\]\]' --issue 299 --ecrire`
- Motifs attendus : `^tests\[\[(8|1[1-6])\]\]`
- Exécution à plusieurs cas (M33) : `premium`, `premium_net`, `premium_ii6`, `reserve1`, `premium_interieur`, chacun avec ses motifs ; tout ou rien ; batteries relancées une seule fois, après le dernier cas
- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil 0 pour lister, seuil 1e-06 pour juger ; `INSTABLES` non neutralisé

**Synthèse** : 23715 feuille(s) dans l'ancienne référence, 23715 dans le résultat recalculé ; 39 non strictement identique(s) (dont 39 en écart au seuil 1e-06, 0 ajoutée(s), 0 supprimée(s)), toutes désignées par les motifs attendus ; 23676 feuille(s) identique(s) au bit près ; écart numérique maximal 0.000e+00.

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `tests[[8]]$type` | test | diagnostic |  | non numerique |
| `tests[[8]]$p_retenue` | 0.866 | \<NA\> |  | non fini |
| `tests[[8]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[8]]$verdict` | OK | INFO |  | non numerique |
| `tests[[8]]$detail` | …quement distribues). (141 car., 1re différence au car. 142) | …quement distribues). Restituee en diagnostic par decision (i… (338 car., 1re différence au car. 142) |  | non numerique |
| `tests[[8]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[8]]$p_min_mc` | 0.002 | \<NA\> |  | non fini |
| `tests[[11]]$detail` | …on pi_t est correcte (62 car., 1re différence au car. 63) | …on pi_t est correcte. Puissance maximale, au seuil alpha = 0… (361 car., 1re différence au car. 63) |  | non numerique |
| `tests[[12]]$type` | test | diagnostic |  | non numerique |
| `tests[[12]]$p_retenue` | 0.271 | \<NA\> |  | non fini |
| `tests[[12]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[12]]$verdict` | OK | INFO |  | non numerique |
| `tests[[12]]$detail` | … sont pas normales. A confronter systematiquement a la versi… (194 car., 1re différence au car. 131) | … sont pas normales. Restituee en diagnostic par decision (is… (333 car., 1re différence au car. 131) |  | non numerique |
| `tests[[12]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[13]]$type` | test | diagnostic |  | non numerique |
| `tests[[13]]$p_retenue` | 0.429 | \<NA\> |  | non fini |
| `tests[[13]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[13]]$verdict` | OK | INFO |  | non numerique |
| `tests[[13]]$detail` |  | Restituee en diagnostic par decision (issue #299) : aucun v… (203 car.) |  | non numerique |
| `tests[[13]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[14]]$type` | test | diagnostic |  | non numerique |
| `tests[[14]]$p_retenue` | 0.018 | \<NA\> |  | non fini |
| `tests[[14]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[14]]$verdict` | ECHEC | INFO |  | non numerique |
| `tests[[14]]$detail` |  | Restituee en diagnostic par decision (issue #299) : aucun v… (203 car.) |  | non numerique |
| `tests[[14]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[15]]$type` | test | diagnostic |  | non numerique |
| `tests[[15]]$p_retenue` | 0.417 | \<NA\> |  | non fini |
| `tests[[15]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[15]]$verdict` | OK | INFO |  | non numerique |
| `tests[[15]]$detail` |  | Restituee en diagnostic par decision (issue #299) : aucun v… (203 car.) |  | non numerique |
| `tests[[15]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[16]]$type` | test | diagnostic |  | non numerique |
| `tests[[16]]$p_retenue` | 1 | \<NA\> |  | non fini |
| `tests[[16]]$nature_p` | Monte-Carlo (bootstrap parametrique, conditionnel au regime… (86 car.) | \<NA\> |  | non numerique |
| `tests[[16]]$verdict` | OK | INFO |  | non numerique |
| `tests[[16]]$detail` | … totalement separes) (325 car., 1re différence au car. 326) | … totalement separes). Restituee en diagnostic par decision (… (593 car., 1re différence au car. 326) |  | non numerique |
| `tests[[16]]$sens` | ne pas rejeter | \<NA\> |  | non numerique |
| `tests[[16]]$p_min_mc` | 0.007 | \<NA\> |  | non fini |

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
