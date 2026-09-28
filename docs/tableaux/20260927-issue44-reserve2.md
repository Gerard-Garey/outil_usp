# Tableau avant / après — référence `reserve2` (issue #44)

- Date : 2026-09-27
- Plateforme : R version 4.3.1 (2023-06-16), Linux
- Commande : `Rscript tests/regenerer_et_rendre_compte.R premium --attendu '^tests\[\[(1|2|3|4|10|16|21|22|32|42)\]\]' --attendu '^tests\[\[[0-9]+\]\]($|\$p_min$)' --attendu '^bootstrap($|\$motif_mc)' reserve1 --attendu '^tests\[\[(1|2|3|4|10|16|21|22|32|42)\]\]' --attendu '^tests\[\[[0-9]+\]\]($|\$p_min$)' --attendu '^bootstrap($|\$motif_mc)' reserve2 --attendu '^tests\[\[[0-9]+\]\]($|\$p_min$)' --attendu '^bootstrap($|\$motif_mc)' premium_ii6 --attendu '^tests\[\[(1|2|3|4|10|16|21|22|32|42)\]\]' --attendu … (738 car.)`
- Motifs attendus : `^tests\[\[[0-9]+\]\]($|\$p_min$)`, `^bootstrap($|\$motif_mc)`
- Exécution à plusieurs cas (M33) : `premium`, `reserve1`, `reserve2`, `premium_ii6`, `premium_net`, chacun avec ses motifs ; tout ou rien ; batteries relancées une seule fois, après le dernier cas
- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil 0 pour lister, seuil 1e-06 pour juger ; `INSTABLES` non neutralisé

**Synthèse** : 4257 feuille(s) dans l'ancienne référence, 4289 dans le résultat recalculé ; 32 non strictement identique(s) (dont 32 en écart au seuil 1e-06, 32 ajoutée(s), 0 supprimée(s)), toutes désignées par les motifs attendus ; 4257 feuille(s) identique(s) au bit près ; écart numérique maximal 0.000e+00.

Nœuds de structure modifiés (type ou attributs) : `tests[[1]]`, `tests[[2]]`, `tests[[3]]`, `tests[[4]]`, `tests[[5]]`, `tests[[6]]`, `tests[[7]]`, `tests[[8]]`, `tests[[9]]`, `tests[[10]]`, `tests[[11]]`, `tests[[12]]`, `tests[[13]]`, `tests[[14]]`, `tests[[15]]`, `tests[[16]]`, `tests[[17]]`, `tests[[18]]`, `tests[[19]]`, `bootstrap`, `tests[[1]]$p_min`, `tests[[2]]$p_min`, `tests[[3]]$p_min`, `tests[[4]]$p_min`, `tests[[5]]$p_min`, `tests[[6]]$p_min`, `tests[[7]]$p_min`, `tests[[8]]$p_min`, `tests[[9]]$p_min`, `tests[[10]]$p_min`, `tests[[11]]$p_min`, `tests[[12]]$p_min`, `tests[[13]]$p_min`, `tests[[14]]$p_min`, `tests[[15]]$p_min`, `tests[[16]]$p_min`, `tests[[17]]$p_min`, `tests[[18]]$p_min`, `tests[[19]]$p_min`, `bootstrap$motif_mc`

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `tests[[1]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[2]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[3]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[4]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[5]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[6]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[7]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[8]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[9]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[10]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[11]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[12]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[13]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[14]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[15]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[16]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[17]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[18]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `tests[[19]]$p_min` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["Calendrier"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["CorrDev"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["BP"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["Grubbs"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["DW"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["Runs"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["PenteIntra"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["Origine"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["HomogF"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["Courbure"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["Alpha"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["ExpVar"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `bootstrap$motif_mc["KruskalAcc"]` | (absente) | \<NA\> |  | ajoutée (absente avant) |

## Batteries

- `Rscript tests/test_reproductibilite.R` : code de sortie 0
  - `premium     sigma_USP = 0.1114524359  (25 s)`
  - `CONFORME : 12502 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve1    sigma_USP = 0.1073524359  (21 s)`
  - `CONFORME : 12501 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve2    sigma_USP = 0.0497764613  (76 s)`
  - `CONFORME : 4289 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_ii6 sigma_USP = 0.1483524359  (21 s)`
  - `CONFORME : 12502 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_net sigma_USP = 0.1032524359  (21 s)`
  - `CONFORME : 12502 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `OK : reproductibilite et non-regression verifiees pour 5 cas.`
- `Rscript tests/test_unitaires.R` : code de sortie 0
  - `TOTAL : 918 assertions, 918 ok, 0 echec(s), 0 echec(s) attendu(s) (defauts connus), 0 succes inattendu(s)`
  - `OK`
