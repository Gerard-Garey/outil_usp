# Revue finale d'`audit` (`high`), branche K4 — deux tours

> *Rapports d'`audit` reproduits par la session K4 (mise en forme seule). Journaux d'exécution dans le scratchpad de la session (non versés).*

## Premier tour — tête `c90e65a`, `git diff origin/main...HEAD` (`main` = `12872c3`)

**Conclusion : conforme avec réserves.** Aucun constat bloquant ni majeur ; quatre mineurs de traçabilité.

### Batteries (`LC_ALL=C.UTF-8`)

| Vérification | Résultat |
|---|---|
| `test_reproductibilite.R` | 6 cas conformes, écart maximal 0 |
| `test_unitaires.R --parallele` | 55 fichiers, 3750 / 3750 |
| `comparer_references.R --seuil 0` | écart 0 sur les 6 cas |
| `concordance_doc_moteur.R --strict` | 0 écart |
| `pdflatex` ×2 | 430 pages, aucune référence indéfinie ; PDF restauré |
| `controle_doc_nd.R --bloquant` | 0 liste A, 0 fiche en violation, 0 débordement |
| rejeu de la mesure de #503 | chiffres de T1, T2, T2b, T3 identiques (2 et 4 processus) |

### Références (`origin/main` contre HEAD)

75 feuilles différentes, toutes `character` : 32 `H0` (`aed5177`) et 43 `detail` (29 `d644aa5`, 14 `49f4600`), conformes au tableau du corps de la PR, lignes et indices compris. Aucune différence de structure, d'attribut ni de valeur numérique.

### Scénarios adverses (moteur de `main` contre moteur de HEAD, B = 99)

Volumes constants, pertes constantes, entrée minimale de #533, ajustement exact, J1, δ̂ intérieur, ex æquo, `delta_equiv`, T = 13, six jeux aléatoires, triangles 5×5, 6×6, exact et bruité : 0 différence non autorisée ; seuls `H0`, `detail`, `loi` (toujours sur une ligne non applicable, à `NA`) et les textes de `validation` diffèrent.

### Architecture, périmètre, historique

Seul `R/engine.R` change côté code R ; `app.R`, `R/display_helpers.R`, `R/charger_moteur.R` non modifiés ; aucun fichier de K6 touché (assertion #203 intacte) ; `add()` : la seule affectation `loi <- NA_character_` (R3) ; `detail_runsr` absent du diff ; aucun mot-clé de fermeture dans l'historique ; aucune réécriture ; auteur `Claude <noreply@anthropic.com>`.

### Constats

- **Mineur 1** : corps de la PR #538 en retard (étape 9, fonctions de #527, `\label`, escalades).
- **Mineur 2** : `CONTEXT.md:136` cite l'ancienne phrase de #244 (à ajouter à Q-E).
- **Mineur 3** : `app-review` léger non tracé alors que `test_application.R` change.
- **Mineur 4** : « Effet attendu » de la fiche K4 périmé (ESD : cinq ; `H0` : six cas).
- **Q1 pour `actuary`** : « puissance non mesuree a T = 8 » imprimé pour tout T et pour `reserve2`.
- Remarques : ADR 0003:195 cite l'ancienne phrase de #244 (annotation historique) ; jonction « ; Verdict » jamais observée (0 sur 73 lignes, 25 jeux) ; l'assertion « références : `loi` NA » est une non-régression, pas une preuve de #533.

## Second tour — tête `7897a4a`, après intégration de `main` (`b1561d3`, K6) : C7-K6

**Conclusion côté code : conforme.** Aucun constat bloquant ni majeur.

- `9e1259f` (Q1) : 29 `detail` changent, rien d'autre ; gabarit global à 385 caractères.
- `0aaf10d` (Q2) : `origine` à NA hors fonction du moteur ; assertion discriminante ; aucune référence.
- `196cf86` (fusion) : les fichiers de K6 identiques à `b1561d3`, ceux de K4 identiques à `0aaf10d`, sauf `test_merz_wuthrich.R`, où les deltas des deux branches sont conservés (assertion #203 de K6 comprise) ; `tests/controle_doc_nd.R` est la version de K6.
- `50b8ebf` : mineurs 2, 3 et 4 clos.
- `7897a4a` : T-1 et T-2 recités à la lettre du moteur.
- Diff complet : 75 feuilles `character` (32 `H0`, 43 `detail`), les 29 `detail` de lecture conjointe au nouveau texte ; K6 n'a pas touché les références ; aucun mot-clé de fermeture ; 32 commits, une seule fusion.
- Batteries : reproductibilité OK ; 3772 / 3772 ; références à écart 0 ; concordance 0 ; compilation 430 pages ; `controle_doc_nd.R --bloquant` (version de K6) 0 violation.
- **Mineur 1** (non résolu au second tour) : corps de la PR à mettre à jour avant la sortie du brouillon — traité par la session.

## Restes à trier (Q-49-2 (a))

O1, O2 (fiche K4) ; Q-E étendue (`CONTEXT.md:136`, `:198`) ; #540 ; #541 ; annotation éventuelle de l'ADR 0003.
