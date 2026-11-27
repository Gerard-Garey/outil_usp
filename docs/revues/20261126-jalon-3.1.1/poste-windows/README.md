# Jalon court 3.1.1 : batterie sous Windows (#625, 27/11/2026)

> Étape 3 du jalon court 3.1.1, reportée à #625 (E-26/11 (jalon 3.1.1, poste)), faite **après la fusion du jalon** (PR #624, `b084e13`). Exécution par la session principale (IA), en session locale de Claude Code sur le poste du mainteneur, à sa demande du 27/11. Versement par une PR courte `docs:` partie de `main` (Q-77-1 (a), E-26/11 (Q-77)). Modèle : `docs/revues/20261125-js2-jalon/poste-windows/etape-4a-batterie.md`.

## Arbre mesuré

- `git rev-parse HEAD` : `7ad4e2f7b9875c0692d5b7d3f32dae26173da8e4`, **SHA de la batterie** (`repo:`, `Version: 3.1.1`), en tête détachée, dans un arbre de travail Git séparé (`git worktree`) créé pour la batterie.
- `git status --porcelain`, avant et après : vide.
- `git diff 7ad4e2f b084e13 -- R/ app.R tests/ DESCRIPTION` : vide. La batterie vaut donc pour la cible de l'étiquette `v3.1.1`, `b084e13` (condition de Q-77-1 (a)).
- md5 calculés par `tools::md5sum()`, égaux aux valeurs du jalon :
  - `R/engine.R` : `c7b767f5d9116c35a0a9237ffdd2d79a` ;
  - `R/charger_moteur.R` : `5ed6226c768d5ad781ea03a7306ccc11`.

## Plateforme

| Élément | Valeur |
|---|---|
| Système | Windows 11 Famille x64, 10.0.26300 |
| R | `R version 4.3.3 (2024-02-29 ucrt)` |
| Locale | `French_France.utf8` (`LC_NUMERIC=C`), laissée telle quelle |
| Paquets R | `openxlsx` 4.2.9, `zip` 2.3.0 (ceux de JS1 et JS2) |

## Exécution

Sous PowerShell, avec `C:\Program Files\R\R-4.3.3\bin\Rscript.exe`, en séquence. Heures UTC et codes : `codes_de_sortie.txt`. Sorties brutes : `sortie_*.txt`. Les sorties d'erreur des trois commandes sont vides.

| Commande | Début | Fin | Code |
|---|---|---|---|
| `Rscript tests/comparer_references.R --deux-parts` (sept cas) | 08:32:12 | 08:33:08 | 1 |
| `Rscript tests/test_reproductibilite.R` | 08:33:08 | 08:34:46 | 1 |
| `Rscript tests/unitaires/test_merz_wuthrich_trapeze.R` (information, Q-76-5 (a)) | 08:34:46 | 08:35:24 | 0 |

## Résultats

| Cas | Feuilles | Part numérique (≠ au bit) | Écart maximal | Au-delà de 1e-6 | Part non numérique / structure | σ_USP |
|---|---|---|---|---|---|---|
| premium | 57 022 | 1 584 | 3,454e-08 | 0 | 0 / 0 | 0,1114524114 |
| reserve1 | 57 021 | 1 586 | 3,454e-08 | 0 | 0 / 0 | 0,1073524114 |
| reserve2 | 18 746 | 8 | 4,545e-16 | 0 | 0 / 0 | 0,0497764613 |
| premium_ii6 | 57 022 | 1 584 | 3,454e-08 | 0 | 0 / 0 | 0,1483524114 |
| premium_net | 57 022 | 1 586 | 3,454e-08 | 0 | 0 / 0 | 0,1032524114 |
| premium_interieur | 57 022 | 2 658 | 1,814e-06 | **2** | 0 / 0 | 0,0871308679 |
| reserve2_trapeze | 18 573 | 8 | 5,831e-16 | 0 | 0 / 0 | 0,0475797067 |

- **Identique point pour point à JS2** (25/11, SHA `1ac9581`, md5 `723277dd…`) : mêmes nombres de feuilles, mêmes décomptes de la part numérique, mêmes écarts maximaux et mêmes σ_USP dans les sept cas. Le changement de `R/engine.R` apporté par A3 (#620) ne modifie donc aucun écart entre le poste et les références de la CI.
- `reserve2_trapeze` : 8 feuilles non identiques au bit, toutes dans `bootstrap$stats_boot`, au plus à 5,831e-16 ; aucune feuille de `ic_bootstrap` ni d'une autre branche de l'objet ne s'écarte.

Feuilles au-delà du seuil (`premium_interieur`, `stats_boot` : 999 réplications × 31 statistiques) :

| Chemin | Réplication, statistique | Référence | Poste | Écart (relatif) |
|---|---|---|---|---|
| `bootstrap$stats_boot[13470]` | 483, `BP` | 0,0158362387 | 0,01583626742 | 1,814e-06 |
| `bootstrap$stats_boot[14469]` | 483, `BP79` | 0,002375132188 | 0,002375136413 | 1,779e-06 |

## Critère de l'ADR 0006 (annotation du 14/11, note du 25/11), par cas

| Point | premium | reserve1 | reserve2 | premium_ii6 | premium_net | premium_interieur | reserve2_trapeze |
|---|---|---|---|---|---|---|---|
| 1. Structure et non numérique vides | tenu | tenu | tenu | tenu | tenu | tenu | tenu |
| 2. `parametre_final`, σ_USP | tenu | tenu | tenu | tenu | tenu | tenu | tenu |
| 3. p-values, `B_effectif`, `p_mc_regime` | tenu | tenu | tenu | tenu | tenu | tenu | tenu |
| 4. Volet `identical()` | tenu | tenu | tenu | tenu | tenu | tenu | tenu |
| 5. Feuilles au-delà du seuil expliquées | sans objet | sans objet | sans objet | sans objet | sans objet | tenu | sans objet |

1. **Part non numérique et structure** : 0 feuille, 0 nœud dans les sept cas.
2. **`parametre_final`** : aucune feuille listée, même au seuil 0 ; les sept σ_USP sont ceux des références.
3. **P-values** : aucune feuille `p_exacte`, `p_asymptotique`, `p_mc`, `p_retenue`, `p_min`, `p_min_mc`, `B_effectif` ni `p_mc_regime` au-delà du seuil. Au seuil 0, seules trois p non simulées figurent, au plus à 4,016e-15 (`tests[[2]]$p_asymptotique`, `tests[[2]]$p_retenue`, `tests[[1]]$p_asymptotique`), comme à JS1 et JS2. Aucune p Monte-Carlo n'est listée.
4. **`identical()`** : le message « deux appels a graine identique different » n'apparaît dans aucune sortie (0 occurrence).
5. **Feuilles au-delà du seuil** : les deux réplications bootstrap de `premium_interieur` relevées à KR, JS1 et JS2, aux mêmes valeurs au dernier chiffre. Les marges de KR s'appliquent : la référence et le poste restent du même côté de la statistique observée (marges minimales 1,3e-3 et 2,0e-4, plus de cent fois la dérive). Aucun décompte Monte-Carlo n'est touché.

Les deux scripts rendent le code 1 à cause des seules feuilles du point 5 (« BASCULE REFUSEE » pour `premium_interieur`, « NON CONFORME » dans `test_reproductibilite.R`). Ce n'est pas un échec du critère.

**Verdict : accepté sur les sept cas.** Aucun point d'arrêt PC-1 : pas d'autre feuille au-delà du seuil, `ic_bootstrap` de `reserve2_trapeze` compris ; aucune p Monte-Carlo différente d'un pas ; aucun écart sur un verdict ni sur σ_USP.

## Information

- **`test_merz_wuthrich_trapeze.R`** (Q-76-5 (a)) : 156 assertions, 156 ok, 0 échec, 0 échec attendu, 0 succès inattendu. C'est le seul fichier qui exerce le chemin changé par A3 (trapèze à colonne J−1 dégénérée, volet à tolérance de `.mw_colonne_degeneree()`). Ce chemin est donc vert sous Windows, comme sous Linux (`../session-cloud/`). Ce n'est pas une condition d'acceptation.
- **Scripts changés par S8** (Q-77-5 (a)), à la tête de `main` `5c52a2d3695516e4b2f121cbcbdd3bcab0f29e97`, après la fusion de S8, dans un second arbre détaché lancé en parallèle de la batterie (`information-main/`) :
  - `Rscript tests/test_unitaires.R` (séquentiel sous Windows) : 08:32:13 → 09:03:19, code 0 ; 4 611 assertions, 4 611 ok, 0 échec, 0 échec attendu, 0 succès inattendu. La sortie d'erreur, non versée, ne contient que des messages de `plotly` (« A marker object has been specified… »).
  - `Rscript tests/controle_doc_nd.R` : 09:03:19 → 09:03:24, code 0 ; bilan : 0 occurrence de la liste A, 0 fiche en violation, 0 débordement en violation. Un avertissement attendu : aucun journal LaTeX `.log` dans un arbre fraîchement extrait, donc débordements non lus.
  - `git status --porcelain` après : vide (le cache à verrou de S8 n'a laissé aucun fichier suivi ni non ignoré).

## Tri ADR 0018

- **Problèmes gardés** : aucun. Pas de PC-2.
- **Écartés** : aucun.

## Suite

- Étiquette `v3.1.1` : la condition de E-26/11 (PC-1 du jalon 3.1.1), (ii), amendée par Q-77-1 (a), est remplie. Les étapes 7 et 8 du jalon peuvent reprendre sur ordre du mainteneur : PR d'étiquette (ADR 0021, § 1), cible `b084e13634af5cafe658b6154647f94357aee206`. Son message cite ce dossier, la date de la batterie (27/11), le fait qu'elle a suivi la fusion, et que `main` a avancé depuis (S8) sans toucher `R/`, `app.R` ni `DESCRIPTION`.

Issues : #625 ; Refs #624, #620, #548.
