# Commentaires des lignes de test limités à deux phrases (09/11/2026, branche K1, #514)

> *Rédigé par la session principale (IA). Spécification de l'agent `actuary-approfondi` (fiche de jugement, Opus, effort `high`) reproduite intégralement dans `20261109-detail-deux-phrases/specification-actuary.md`.*

## Demande

Le 09/11/2026, le mainteneur a jugé beaucoup trop longs les commentaires des lignes de test dans la vue Détail de l'onglet Tests. Il a demandé **deux phrases au plus**. Ce sont les champs `detail` posés par `add()` dans `usp_tests()` et `mw_tests()`.

Mesure de départ, sur les références : 29 lignes sur 49 en premium et 16 sur 24 en reserve2 dépassent deux phrases au sens de `.fins_de_phrase()`. Médiane de 4 phrases, maximum de 10, jusqu'à 1 130 caractères.

## Décisions du mainteneur

| Question | Décision |
|---|---|
| Portée | Réécriture du `detail` dans le moteur. La troncature à l'affichage est écartée. |
| Traçabilité | Issue #514 créée et rattachée à K1 (huitième numéro, `Closes` dans la PR #511). |
| Q-1, comptage | Règle (P) : fins de phrase « . » et « ; » sans condition de majuscule, à profondeur nulle de parenthèses. Le texte propre compte au plus deux phrases ; les mentions conditionnelles M1 à M16 (R1, motifs Monte-Carlo, #204/#279, #257, #244…) sont hors compte. |
| Q-2, séparateurs | Le « ; » de M3, M4, M5, M7, M8, M9, M14 et T-3b devient « , ». |
| Q-3, énumérations | Retrait du `detail` des énumérations numériques : identifiabilité par colonne, diagonales de Mack 1997, sensibilité de la MSEP en M6, rangs de Rosner et de Cook, cellule du minimum. Quatre familles de valeurs quittent ainsi l'objet résultat ; elles restent recalculables par la fonction nommée de la ligne (§ 4 de la spécification). |
| Q-4, plafond | Plafond dur de **400 caractères** sur le texte propre. Le pire cas mesuré des textes cibles est de 392. |
| Q-5, jackknife | Les années sont citées jusqu'à 3 ; au-delà, seul leur nombre est donné. Elles restent dans `res$plots_data$influence`. |
| Objet du texte (précision du 09/11) | « Décrire de façon concise comment utiliser le test ainsi que les tests potentiellement liés. » D'où le gabarit : phrase 1, usage et lecture de la ligne ; phrase 2, lignes liées, nommées par leur libellé affiché. La construction (formules, lois, dérivations) va dans la fiche du `.tex`. Les textes cibles de la spécification sont révisés par `actuary` selon ce gabarit. |
| Périmètre (précision du 09/11) | La revue vaut aussi pour les commentaires du tableau « Robustesse du calibrage » (`table_robustesse()`, onglet Calibration et section 4 du rapport figé). Ce tableau affiche le `detail` des lignes des familles G (lognormale) et M6 (Merz-Wüthrich) : toutes suivent le gabarit, y compris la position de δ et le jackknife. |

## Effet attendu

- Aucun σ_USP, aucune p-value, aucun verdict ne change.
- Les références changent par leurs seuls champs `tests[[i]]$detail` (changement non numérique) : patch chirurgical.
- Un nouveau test, `tests/unitaires/test_detail_deux_phrases.R`, vérifie la règle sur les six cas de référence et sur les branches rares.
- `docwriter` reporte dans les fiches du `.tex` les contenus retirés qui n'y figurent pas encore, et indique où retrouver les valeurs retirées.

## Circuit

1. `actuary-approfondi` spécifie (fait).
2. `coder-approfondi` implémente (contrat partagé : objet `usp_engine`).
3. `audit` et `app-review` vérifient.
4. Patch des références.
5. `docwriter` reprend le `.tex` en fin de branche.
6. `actuary` valide.
