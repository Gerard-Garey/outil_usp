# Tableau avant / après — référence `premium` (issue #169)

- Date : 2026-10-07
- Plateforme : R version 4.3.1 (2023-06-16), Linux
- Commande : `Rscript tests/regenerer_et_rendre_compte.R premium --attendu '^metadata\$permutation_pente' --attendu '^tests\[\[3\]\]\$' --attendu '^tests\[\[4\]\]\$detail$' reserve1 --attendu '^metadata\$permutation_pente' --attendu '^tests\[\[3\]\]\$' --attendu '^tests\[\[4\]\]\$detail$' premium_ii6 --attendu '^metadata\$permutation_pente' --attendu '^tests\[\[3\]\]\$' --attendu '^tests\[\[4\]\]\$detail$' premium_net --attendu '^metadata\$permutation_pente' --attendu '^tests\[\[3\]\]\$' --attendu '^tests\[\… (536 car.)`
- Motifs attendus : `^metadata\$permutation_pente`, `^tests\[\[3\]\]\$`, `^tests\[\[4\]\]\$detail$`
- Exécution à plusieurs cas (M33) : `premium`, `reserve1`, `premium_ii6`, `premium_net`, chacun avec ses motifs ; tout ou rien ; batteries relancées une seule fois, après le dernier cas
- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil 0 pour lister, seuil 1e-06 pour juger ; `INSTABLES` non neutralisé

**Synthèse** : 23737 feuille(s) dans l'ancienne référence, 23740 dans le résultat recalculé ; 19 non strictement identique(s) (dont 19 en écart au seuil 1e-06, 3 ajoutée(s), 0 supprimée(s)), toutes désignées par les motifs attendus ; 23721 feuille(s) identique(s) au bit près ; écart numérique maximal 5.000e-01 (relatif, `tests[[3]]$p_asymptotique`).

Nœuds de structure modifiés (type ou attributs) : `metadata`, `metadata$permutation_pente`, `metadata$permutation_pente$methode`, `metadata$permutation_pente$B`, `metadata$permutation_pente$p_bilateral`

| Feuille | Avant | Après | Écart | Mesure |
|---|---|---|---|---|
| `metadata$permutation_pente$methode` | (absente) | enumeration |  | ajoutée (absente avant) |
| `metadata$permutation_pente$B` | (absente) | \<NA\> |  | ajoutée (absente avant) |
| `metadata$permutation_pente$p_bilateral` | (absente) | 0.2111855159 |  | ajoutée (absente avant) |
| `tests[[3]]$test` | Test de Student sur la pente (lm(y~x)) | Test de Pitman sur la pente (lien positif pertes / volume) |  | non numerique |
| `tests[[3]]$reference` | Student (1908), Biometrika 6 | Pitman (1937), Suppl. JRSS 4 |  | non numerique |
| `tests[[3]]$type` | diagnostic | test |  | non numerique |
| `tests[[3]]$H0` | b = 0 (aucun lien volume / pertes) | Y_1..Y_T independants de x (echangeables) : aucun lien pert… (70 car.) |  | non numerique |
| `tests[[3]]$H1` | b != 0 | lien positif pertes / volume (dont E[Y] = beta x, beta > 0) |  | non numerique |
| `tests[[3]]$loi` | t(6) exacte sous le modele auxiliaire MCO (erreurs i.i.d. n… (84 car.) | loi de permutation de t (enumeration des T! appariements) |  | non numerique |
| `tests[[3]]$p_exacte` | \<NA\> | 0.1106646825 |  | non fini |
| `tests[[3]]$p_asymptotique` | 0.2133906175 | 0.1066953087 | 5.000e-01 | relatif, au-delà du seuil 1e-06 |
| `tests[[3]]$p_retenue` | \<NA\> | 0.1106646825 |  | non fini |
| `tests[[3]]$nature_p` | \<NA\> | exacte par permutation (H0 : y independant de x, hors model… (75 car.) |  | non numerique |
| `tests[[3]]$verdict` | INFO | ALERTE |  | non numerique |
| `tests[[3]]$detail` | Ici on souhaite REJETER H0. PENTE NON IDENTIFIABLE PAR LES … (277 car.) | Ici on souhaite REJETER H0. Test de Pitman : loi de permuta… (795 car.) |  | non numerique |
| `tests[[3]]$sens` | \<NA\> | rejeter |  | non numerique |
| `tests[[3]]$p_min` | \<NA\> | 2.48015873e-05 |  | non fini |
| `tests[[3]]$fonction` | test_lm_complet | usp_permutation_pente |  | non numerique |
| `tests[[4]]$detail` | Equivaut a t^2 en regression simple. PENTE NON IDENTIFIABLE… (286 car.) | Diagnostic, redondante avec le test de Pitman (F = t^2) : a… (166 car.) |  | non numerique |

## Batteries

- `Rscript tests/test_reproductibilite.R` : code de sortie 0
  - `premium     sigma_USP = 0.1114524114  (33 s)`
  - `CONFORME : 23740 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve1    sigma_USP = 0.1073524114  (29 s)`
  - `CONFORME : 23739 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve2    sigma_USP = 0.0497764613  (76 s)`
  - `CONFORME : 4329 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_ii6 sigma_USP = 0.1483524114  (29 s)`
  - `CONFORME : 23740 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_net sigma_USP = 0.1032524114  (29 s)`
  - `CONFORME : 23740 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `OK : reproductibilite et non-regression verifiees pour 5 cas.`
- `Rscript tests/test_unitaires.R` : code de sortie 0
  - `TOTAL : 1493 assertions, 1493 ok, 0 echec(s), 0 echec(s) attendu(s) (defauts connus), 0 succes inattendu(s)`
  - `OK`
