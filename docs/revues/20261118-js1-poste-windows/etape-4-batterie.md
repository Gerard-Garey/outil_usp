# JS1, étape 4 : batterie au critère de #548 sur le poste Windows (18/11/2026)

> Relevé de la session principale (IA), session locale de Claude Code sur le poste du mainteneur. Le critère est celui de l'ADR 0006, annotation du 14/11/2026, « Critère de la batterie sous Windows ». Modèle : `docs/revues/20261114-passage-de-remise/etape-3-releve-poste.md`.

## Arbre mesuré

- `git rev-parse HEAD` : `c75a112214d757ad778b89aaf2e680ba719d6c0f`. C'est le **SHA de la batterie** (`repo:`, `Version` 3.0.0), en tête détachée.
- `git status --porcelain`, avant et après : seulement `?? prompt-poste-local.md`, fichier du mainteneur hors dépôt et sans rapport avec le moteur.
- `git diff c75a112 182ee7f -- R/ app.R DESCRIPTION tests/` est vide : la tête de branche porte le même code.
- md5, calculés par `Get-FileHash -Algorithm MD5` et par `tools::md5sum()` :
  - `R/engine.R` : `26220144141d922f4ea85d259004f093` ;
  - `R/charger_moteur.R` : `5ed6226c768d5ad781ea03a7306ccc11`.

## Plateforme

- Windows 11 x64 (build 26300), `R version 4.3.3 (2024-02-29 ucrt)`.
- Locale : `French_France.utf8` (`LC_NUMERIC=C`), laissée telle quelle ; pas de `LC_ALL=C.UTF-8` sous Windows.
- Paquets : `openxlsx` 4.2.9 et `zip` 2.3.0, ceux du relevé de KR.

## Exécution

Commandes, lancées sous PowerShell, dans l'ordre :
1. `Rscript tests/comparer_references.R --deux-parts` (six cas) : 130 s ;
2. `Rscript tests/test_reproductibilite.R` : 236 s.

Sorties brutes : `etape-4/sortie_comparer_references_deux_parts.txt` et `etape-4/sortie_test_reproductibilite.txt`.

Script de lancement : `etape-4/lancer.ps1`, qui enchaîne aussi les deux exécutions de l'étape 2 (i).
- `R_LIBS_USER` n'y est posé que pour l'exécution « sans openxlsx ». Il est retiré par `Remove-Item` avant les deux scripts de la batterie.
- Contrôle fait dans la même session après ce retrait : `.libPaths()` rend la bibliothèque du poste, et `packageVersion("openxlsx")` rend 4.2.9.
- Aucun des deux scripts de la batterie ne lit de classeur xlsx.

## Résultats

| Cas | Feuilles | Part numérique (≠ au bit) | Écart maximal | Au-delà de 1e-6 | Part non numérique / structure | σ_USP |
|---|---|---|---|---|---|---|
| premium | 57 022 | 1 584 | 3,454e-08 | 0 | 0 / 0 | 0,1114524114 |
| reserve1 | 57 021 | 1 586 | 3,454e-08 | 0 | 0 / 0 | 0,1073524114 |
| reserve2 | 18 729 | 8 | 4,545e-16 | 0 | 0 / 0 | 0,0497764613 |
| premium_ii6 | 57 022 | 1 584 | 3,454e-08 | 0 | 0 / 0 | 0,1483524114 |
| premium_net | 57 022 | 1 586 | 3,454e-08 | 0 | 0 / 0 | 0,1032524114 |
| premium_interieur | 57 022 | 2 658 | 1,814e-06 | **2** | 0 / 0 | 0,0871308679 |

Le nombre de feuilles dépasse de quatre celui du relevé de KR (57 018) : ce sont les champs ajoutés par S1 à S4. Les décomptes de la part numérique et les écarts maximaux sont **identiques** à ceux de KR.

Feuilles au-delà du seuil (`stats_boot` : 999 réplications × 31 statistiques) :

| Chemin | Réplication, statistique | Référence | Poste | Écart (relatif) |
|---|---|---|---|---|
| `bootstrap$stats_boot[13470]` | 483, `BP` | 0,0158362387 | 0,01583626742 | 1,814e-06 |
| `bootstrap$stats_boot[14469]` | 483, `BP79` | 0,002375132188 | 0,002375136413 | 1,779e-06 |

## Points du critère

1. **Part non numérique et structure vides** dans les six cas. **Tenu.**
2. **`parametre_final`** : aucune feuille au-delà du seuil, et aucune feuille listée au seuil 0. Les six σ_USP sont ceux du relevé de KR. **Tenu.**
3. **P-values** :
   - aucune feuille `p_exacte`, `p_asymptotique`, `p_mc`, `p_retenue`, `p_min`, `p_min_mc`, `B_effectif` ou `p_mc_regime` n'est au-delà du seuil ;
   - au seuil 0, aucune occurrence de `p_mc`, `p_min_mc`, `B_effectif`, `p_mc_regime` ni `parametre_final` dans la sortie (recherche) ;
   - seules trois p non simulées y figurent, au plus à 4,016e-15 : `tests[[1]]$p_asymptotique`, `tests[[2]]$p_asymptotique` et `tests[[2]]$p_retenue`.

   **Tenu.**
4. **Volet `identical()`** : objets identiques dans les six cas. Le message « deux appels a graine identique different » n'apparaît pas (0 occurrence). **Tenu.**
5. **Feuilles au-delà du seuil** : ce sont les deux réplications bootstrap de `stats_boot` du relevé de KR, aux mêmes valeurs. Les marges de KR s'appliquent donc : la valeur de référence et celle du poste restent du même côté de la statistique observée, et la marge minimale des réplications à l'observée (1,3e-3 et 2,0e-4) vaut plus de cent fois la dérive. Aucun décompte Monte-Carlo n'est touché. **Tenu.**

Les deux scripts rendent le code de sortie 1, uniquement à cause des feuilles du point 5 : `--deux-parts` affiche « BASCULE REFUSEE » pour `premium_interieur`, et `test_reproductibilite.R` « NON CONFORME ». Ce n'est pas un échec du critère, qui juge la batterie sous Windows.

**Critère accepté.** Le relevé est identique à ceux du 11/11 et du 14/11/2026 (KR).
