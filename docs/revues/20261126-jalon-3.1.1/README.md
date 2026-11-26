# Jalon court 3.1.1 : relevés de la batterie (26/11/2026)

Pièces de l'étape 4 de la fiche « Jalon court 3.1.1 » (§ 3 de `docs/feuille-de-route.md`), PR #624.

## Batterie sous Windows : non faite dans le jalon

- Le 26/11/2026, le mainteneur a demandé de poursuivre le jalon **sans le poste Windows**, avec une issue si besoin.
- L'étape 3 (critère de l'ADR 0006, annotation du 14/11, note du 25/11) **n'est donc pas faite**. Elle est reportée à l'issue #625, à rejouer au SHA de la batterie ou à tout commit où `R/`, `app.R`, `tests/` et `DESCRIPTION` sont identiques.
- Les relevés ci-dessous **ne valent pas** ce critère. Ils établissent la non-régression sous Linux. Ils n'établissent rien sur le poste.

## Relevé en session cloud (`session-cloud/`)

- **SHA de la batterie** : `7ad4e2f7b9875c0692d5b7d3f32dae26173da8e4` (commit `repo:` `Version: 3.1.1`), arbre propre (`environnement.txt`).
- **Plateforme** : Linux, R 4.3.3 (2024-02-29), `LC_ALL=C.UTF-8`.
- **md5** : `R/engine.R` `c7b767f5d9116c35a0a9237ffdd2d79a` ; `R/charger_moteur.R` `5ed6226c768d5ad781ea03a7306ccc11`.
- **Codes de sortie et heures UTC** (`codes_de_sortie.txt` ; sorties complètes dans `comparer_references.txt`, `test_reproductibilite.txt` et `test_merz_wuthrich_trapeze.txt`) :

| Commande | Début | Fin | Code | Résultat |
|---|---|---|---|---|
| `Rscript tests/comparer_references.R --deux-parts` | 11:47:33 | 11:49:09 | 0 | sept cas : part non numérique vide, part numérique 0 feuille, écart maximal 0 |
| `Rscript tests/test_reproductibilite.R` | 11:49:09 | 11:52:06 | 0 | sept cas `CONFORME`, 0 feuille non strictement identique, écart maximal 0 |
| `Rscript tests/unitaires/test_merz_wuthrich_trapeze.R` (informatif, Q-76-5) | 11:52:06 | 11:53:16 | 0 | 156 assertions, 156 ok, 0 échec |

- **σ_USP** par cas (`test_reproductibilite.txt`) : identiques aux références au bit.
- **Chemin changé par A3** : seul le troisième relevé l'exerce (trapèze à colonne J−1 dégénérée, `.mw_simulation_sigma_direct()`). Il est vert sous Linux. Son comportement sous Windows, en particulier le volet à tolérance de `.mw_colonne_degeneree()`, reste **non mesuré** (#625).

## CI sur le SHA de la batterie

- Exécution 45801832642 (Linux, R 4.3.1) : trois lots de tests unitaires, « Reproductibilité et concordance », témoin openxlsx, fiches d'agents, fichiers modifiés : tous `success`. CodeQL et « mots-cles-fermeture » : `success`.

## Tri ADR 0018

- **Problèmes gardés** : un seul, la batterie sous Windows non faite. Le critère de reproductibilité de l'ADR 0018 est rempli, car c'est la condition de l'ADR 0006 pour désigner l'état. Issue #625, créée sur autorisation du mainteneur, **hors du jalon** (aucune ligne de fermeture, § 5.2).
- **Écartés** : aucun.
- **Suite** : l'étiquette `v3.1.1` relève du point d'arrêt PC-1 et de Q-67-8 (a). Une étiquette sans batterie sous Windows demande une décision du mainteneur, et son message doit alors citer #625 parmi les limites.
