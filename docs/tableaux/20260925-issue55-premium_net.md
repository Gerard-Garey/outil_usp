# Tableau avant / après — création de la référence `premium_net` (issue #55)

- Date : 2026-09-25
- Plateforme : R version 4.3.1 (2023-06-16), Linux
- Commande : `Rscript tests/regenerer_et_rendre_compte.R premium_net --creer --issue 55 --ecrire`
- Mode : création (M31) ; tableau de non-régression « absent / ajouté » seulement

| Référence | Avant | Après |
|---|---|---|
| `tests/reference/premium_net.rds` | (absente) | ajoutée : 12406 feuille(s), md5 `496b1b781d7664843c0c65cfe9779714` |

- σ_USP du cas ajouté (`parametre_final$sigma_usp`) : 0.1032524359
- Références existantes : 4 fichier(s), md5 identiques avant / après (`premium_ii6.rds`, `premium.rds`, `reserve1.rds`, `reserve2.rds`) ; aucun autre fichier ajouté

## Batteries

- `Rscript tests/test_reproductibilite.R` : code de sortie 0
  - `premium     sigma_USP = 0.1114524359  (25 s)`
  - `CONFORME : 12406 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve1    sigma_USP = 0.1073524359  (21 s)`
  - `CONFORME : 12405 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `reserve2    sigma_USP = 0.0497764613  (77 s)`
  - `CONFORME : 4225 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_ii6 sigma_USP = 0.1483524359  (21 s)`
  - `CONFORME : 12406 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `premium_net sigma_USP = 0.1032524359  (21 s)`
  - `CONFORME : 12406 feuille(s), 0 non strictement identique(s), 0 en ecart au seuil 1e-06 ; ecart maximal 0.000e+00`
  - `OK : reproductibilite et non-regression verifiees pour 5 cas.`
- `Rscript tests/test_unitaires.R` : code de sortie 0
  - `TOTAL : 749 assertions, 749 ok, 0 echec(s), 0 echec(s) attendu(s) (defauts connus), 0 succes inattendu(s)`
  - `OK`
