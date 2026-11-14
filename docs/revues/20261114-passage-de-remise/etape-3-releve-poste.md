# KR, étape 3 : relevé du poste Windows (14/11/2026)

> Relevé de la session principale sur le poste du mainteneur (Q-54-10). Il est déposé sur #548 et versé ici. Critère : avis d'`actuary` sur #548, § 2 (`docs/revues/20261112-avis-548-seuil-m9/actuary-avis-548.md`), repris dans la fiche KR, étape 3.

## Arbre mesuré

- Tête `f179ce2` (branche `claude/passage-de-remise`). `git diff a2f9c3a f179ce2 -- R/ app.R DESCRIPTION tests/` est vide : le code mesuré est celui du **gel `a2f9c3a`**.
- `git status --short` : seulement `?? prompt-poste-local.md`, un fichier du mainteneur hors dépôt et sans rapport avec le moteur.
- **md5**, calculés par `Get-FileHash -Algorithm MD5` : `R/engine.R` `818f276d8941e5780468382c640f8cfa`, `R/charger_moteur.R` `5ed6226c768d5ad781ea03a7306ccc11`. Ils sont **égaux à ceux du gel**. Le relevé des md5 affichés par l'application (rapport figé) reste à faire par le mainteneur (voir « Contrôles restants »).

## Plateforme

- Windows 11 x64 (build 26300), `R version 4.3.3 (2024-02-29 ucrt)`, x86_64-w64-mingw32.
- `Matrix products: default` (BLAS et LAPACK de R), LAPACK 3.11.0.
- Locale : `French_France.utf8` (`LC_NUMERIC=C`).
- Paquets : `openxlsx` **4.2.9** (installé le 14/11 depuis le CRAN, compilé depuis les sources), `zip` 2.3.0, `shiny` 1.12.1, `plotly` 4.12.0.

## Batterie au critère de #548

Les commandes ont été lancées dans l'ordre : `Rscript tests/comparer_references.R --deux-parts` (six cas), puis `Rscript tests/test_reproductibilite.R`.

| Cas | Feuilles | Part numérique (≠ au bit) | Écart maximal | Au-delà de 1e-6 | Part non numérique / structure |
|---|---|---|---|---|---|
| premium | 57 018 | 1 584 | 3,454e-08 | 0 | 0 / 0 |
| reserve1 | 57 017 | 1 586 | 3,454e-08 | 0 | 0 / 0 |
| reserve2 | 18 725 | 8 | 4,545e-16 | 0 | 0 / 0 |
| premium_ii6 | 57 018 | 1 584 | 3,454e-08 | 0 | 0 / 0 |
| premium_net | 57 018 | 1 586 | 3,454e-08 | 0 | 0 / 0 |
| premium_interieur | 57 018 | 2 658 | 1,814e-06 | **2** | 0 / 0 |

Feuilles au-delà du seuil. `stats_boot` a 999 lignes (réplications) et 31 colonnes (statistiques).

| Chemin | Réplication, statistique | Référence | Poste | Écart (relatif) | Statistique observée | Écart relatif minimal des réplications à l'observée |
|---|---|---|---|---|---|---|
| `bootstrap$stats_boot[13470]` | 483, `BP` | 0,0158362387 | 0,01583626742 | 1,814e-06 | 0,0749955153 | 1,32e-03 |
| `bootstrap$stats_boot[14469]` | 483, `BP79` | 0,002375132188 | 0,002375136413 | 1,779e-06 | 0,0550691823 | 1,96e-04 |

Points du critère :
1. **Part non numérique et structure vides** dans les six cas : aucun verdict, libellé, booléen, `NA`, entier, chemin ni nœud n'est modifié. Tenu.
2. **`parametre_final`** : aucune feuille au-delà du seuil. Les σ_USP sont conformes (`test_reproductibilite.R`) : 0,1114524114, 0,1073524114, 0,0497764613, 0,1483524114, 0,1032524114 et 0,0871308679. Tenu.
3. **P-values** : aucune feuille `p_exacte`, `p_asymptotique`, `p_mc`, `p_retenue`, `p_min`, `p_min_mc`, `B_effectif` ou `p_mc_regime` n'est au-delà du seuil. Aucune feuille `p_mc`, `p_min_mc`, `B_effectif` ni `p_mc_regime` ne figure dans la liste au seuil 0 (recherche dans la sortie : 0 occurrence). Seules des p non simulées y figurent, au plus à 4,0e-15. Tenu.
4. **Volet `identical()`** : deux appels sur le poste, objets identiques dans les six cas. Le message « deux appels a graine identique different » n'apparaît pas. Tenu.
5. Les **deux feuilles au-delà du seuil** sont des réplications bootstrap (`stats_boot`). Pour chacune, la valeur de référence et celle du poste restent du même côté de la statistique observée, et la marge minimale des réplications à l'observée (1,3e-3 et 2,0e-4) vaut plus de cent fois la dérive. Aucun décompte Monte-Carlo n'est donc touché. Tenu.

Le code de sortie vaut 1 pour les deux scripts, uniquement à cause des feuilles du point (5). Ce n'est pas un échec du critère.

**Critère accepté.** Le relevé est identique à la mesure du 11/11/2026 : mêmes deux feuilles, mêmes valeurs, et les cinq autres cas restent sous 3,454e-08.

## Contrôles d'entrée avec `openxlsx` (m4)

`Rscript tests/unitaires/test_controles_entree.R`, avec `openxlsx` 4.2.9 installé : **444 assertions, 443 ok, 1 échec, 0 ligne « [saute] »**, et aucun plantage.

L'assertion en échec est « Colonnes presentes (#522) : octet 0x89 declare Latin-1 lu comme Windows-1252… ». Elle n'a pas de lien avec `openxlsx`, mais dépend de la plateforme :
- Sous Windows, R convertit l'octet 0x81 déclaré Latin-1 en contrôle U+0081, que `.echapper_texte()` écrit `\u0081`.
- Sous Linux (C.UTF-8, mesure qui a fondé le test), il reste « <81> ».
- Les deux autres volets de l'assertion (0x89 → U+2030, 0xA0 → ` `, octet 0x89 non déclaré) sont conformes sur le poste.
- Effet : la seule citation d'un nom de colonne illisible dans un message de refus d'import. Aucun nombre, verdict ni σ_USP n'est touché.

Le gel couvre `tests/` : le test n'est pas modifié. Le constat est proposé en issue, pour la prise en charge après la remise.

## Contrôles restants (mainteneur, sur le poste)

- Classeurs écrits par l'Excel du poste et importés dans l'application ; version d'Excel.
- md5 affichés par l'application au rapport figé, après un calcul abouti et le téléchargement du rapport.
- Impressions de contrôle de #566 et de #576 dans un navigateur avec GPU.
- Facultatif : `mesure_557d.R` (blancs d'en-tête).
