# JS2, étape 4a : batterie sous Windows sur sept cas (25/11/2026)

> Relevé de la session principale (IA), session locale de Claude Code sur le poste du mainteneur. Critère : ADR 0006, annotation du 14/11/2026, « Critère de la batterie sous Windows », lu sur sept cas par la note du 25/11. Modèle : `docs/revues/20261118-js1-poste-windows/etape-4-batterie.md`.

## Arbre mesuré

- `git rev-parse HEAD` : `1ac95810e72ee8f277c6e943b3585a561d5975b2`. C'est le **SHA de la batterie** (`repo:`, `Version` 3.1.0), en tête détachée.
- `git status --porcelain`, avant et après : seulement `?? prompt-poste-local.md` et `?? sorties-p/`, fichiers du mainteneur hors dépôt et sans rapport avec le moteur.
- md5 calculés par `tools::md5sum()`, égaux aux valeurs attendues par le handoff :
  - `R/engine.R` : `723277ddfa5736d7411838d15d8dad00` ;
  - `R/charger_moteur.R` : `5ed6226c768d5ad781ea03a7306ccc11`.
- La tête de branche (`e04e8a3`) ne diffère de `1ac9581`, sous `R/`, `app.R` et `tests/`, que par la constante de `34d07f0` (`tests/controle_doc_nd.R`), sans effet sur aucun chiffre.

## Plateforme

- Windows 11 Famille x64 (10.0.26300, build 26300), `R version 4.3.3 (2024-02-29 ucrt)`.
- Locale : `French_France.utf8` (`LC_NUMERIC=C`), laissée telle quelle.
- Paquets : `openxlsx` 4.2.9 et `zip` 2.3.0, ceux de JS1.

## Exécution

Commandes, sous PowerShell, avec `C:\Program Files\R\R-4.3.3\bin\Rscript.exe` :
1. `Rscript tests/comparer_references.R --deux-parts` (sept cas) : 116 s, code 1 ;
2. `Rscript tests/test_reproductibilite.R` : 210 s, code 1 ;
3. `Rscript tests/unitaires/test_controles_entree.R`, à titre d'information : 398 s, code 0.

Le troisième script a tourné en parallèle des deux premiers. Aucun ne lit ni n'écrit de fichier versionné ; l'arbre est resté propre.

Sorties brutes : `sortie_comparer_references_deux_parts.txt`, `sortie_test_reproductibilite.txt`, `sortie_test_controles_entree.txt` ; heures UTC et codes : `codes_de_sortie.txt`.

## Résultats

| Cas | Feuilles | Part numérique (≠ au bit) | Écart maximal | Au-delà de 1e-6 | Part non numérique / structure | σ_USP |
|---|---|---|---|---|---|---|
| premium | 57 022 | 1 584 | 3,454e-08 | 0 | 0 / 0 | 0,1114524114 |
| reserve1 | 57 021 | 1 586 | 3,454e-08 | 0 | 0 / 0 | 0,1073524114 |
| reserve2 | 18 746 | 8 | 4,545e-16 | 0 | 0 / 0 | 0,0497764613 |
| premium_ii6 | 57 022 | 1 584 | 3,454e-08 | 0 | 0 / 0 | 0,1483524114 |
| premium_net | 57 022 | 1 586 | 3,454e-08 | 0 | 0 / 0 | 0,1032524114 |
| premium_interieur | 57 022 | 2 658 | 1,814e-06 | **2** | 0 / 0 | 0,0871308679 |
| **reserve2_trapeze** | 18 573 | 8 | 5,831e-16 | 0 | 0 / 0 | 0,0475797067 |

- Les six premiers cas reproduisent JS1 : mêmes décomptes de la part numérique, mêmes écarts maximaux, mêmes σ_USP. `reserve2` passe de 18 729 à 18 746 feuilles : champs ajoutés par S5 à S7, sans écart.
- `reserve2_trapeze`, **première mesure au poste** : 8 feuilles non identiques au bit, toutes dans `bootstrap$stats_boot`, au plus à 5,831e-16 ; aucune feuille de `ic_bootstrap` ni d'une autre branche de l'objet ne s'écarte.

Feuilles au-delà du seuil (`premium_interieur`, `stats_boot` : 999 réplications × 31 statistiques) :

| Chemin | Réplication, statistique | Référence | Poste | Écart (relatif) |
|---|---|---|---|---|
| `bootstrap$stats_boot[13470]` | 483, `BP` | 0,0158362387 | 0,01583626742 | 1,814e-06 |
| `bootstrap$stats_boot[14469]` | 483, `BP79` | 0,002375132188 | 0,002375136413 | 1,779e-06 |

## Points du critère, par cas

| Point | premium | reserve1 | reserve2 | premium_ii6 | premium_net | premium_interieur | reserve2_trapeze |
|---|---|---|---|---|---|---|---|
| 1. Structure et non numérique vides | tenu | tenu | tenu | tenu | tenu | tenu | tenu |
| 2. `parametre_final`, σ_USP | tenu | tenu | tenu | tenu | tenu | tenu | tenu |
| 3. p-values, `B_effectif`, `p_mc_regime` | tenu | tenu | tenu | tenu | tenu | tenu | tenu |
| 4. Volet `identical()` | tenu | tenu | tenu | tenu | tenu | tenu | tenu |
| 5. Feuilles au-delà du seuil expliquées | sans objet | sans objet | sans objet | sans objet | sans objet | tenu | sans objet |

1. **Part non numérique et structure** : 0 feuille, 0 nœud dans les sept cas.
2. **`parametre_final`** : aucune feuille au-delà du seuil ni listée au seuil 0 ; les sept σ_USP sont ceux des références (verdict « CONFORME » de `test_reproductibilite.R` hors `premium_interieur`, dont l'écart ne touche que `stats_boot`).
3. **P-values** : aucune feuille `p_exacte`, `p_asymptotique`, `p_mc`, `p_retenue`, `p_min`, `p_min_mc`, `B_effectif`, `p_mc_regime` au-delà du seuil. Au seuil 0, seules trois p non simulées figurent, au plus à 4,016e-15 (`tests[[1]]$p_asymptotique`, `tests[[2]]$p_asymptotique`, `tests[[2]]$p_retenue`), comme à JS1. Aucune p Monte-Carlo ne diffère d'un pas.
4. **`identical()`** : le message « deux appels a graine identique different » n'apparaît dans aucune sortie (0 occurrence).
5. **Feuilles au-delà du seuil** : les deux réplications bootstrap de `stats_boot` de `premium_interieur` relevées à KR et à JS1, aux mêmes valeurs au dernier chiffre. Les marges de KR s'appliquent : référence et poste restent du même côté de la statistique observée (marge minimale 1,3e-3 et 2,0e-4, plus de cent fois la dérive). Aucun décompte Monte-Carlo n'est touché.

Les deux scripts rendent le code 1 uniquement à cause des feuilles du point 5 (« BASCULE REFUSEE » pour `premium_interieur`, « NON CONFORME » dans `test_reproductibilite.R`). Ce n'est pas un échec du critère.

## Information : `test_controles_entree.R`

647 assertions, 647 ok, 0 échec, 0 échec attendu, 0 succès inattendu ; trois sauts déclarés (témoin `openxlsx` 4.2.9 non daté, locale `C.UTF-8` indisponible, `HOME` non redirigeable). Ce n'est pas une condition du jalon.

## PJ-2

Aucun des trois cas d'arrêt : pas d'autre feuille au-delà du seuil (`ic_bootstrap` de `reserve2_trapeze` compris), aucune p Monte-Carlo différente d'un pas, aucun écart sur un verdict ni sur σ_USP.

**Verdict : accepté.**
