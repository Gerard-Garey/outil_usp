# Audit des corrections postérieures à la revue finale (règle 10), 11/11/2026

Diff non commité sur `ccb5771`, devenu les commits `76490b1` (#475), `ba93491` (#502) et `f6b33f5` (#479). Quatre fichiers : `tests/controle_doc_nd.R`, `tests/unitaires/test_controle_doc_nd.R`, `tests/mesure_dw_rho_negatif_t8.R`, `tests/unitaires/test_rapport_html.R`.

## Verdict : conforme

Aucun constat bloquant, majeur ni mineur. Quatre remarques, sans reprise. Aucune question pour `actuary`.

## Lot A (#502), `tests/mesure_dw_rho_negatif_t8.R`

- Conformité mot pour mot avec l'avis d'`actuary` (`actuary-libelle-502.md`) : en-tête, occurrence 1 (l. 33-38) et occurrence 2 (l. 47) ; sortie (l. 401), précédée de « erreur numérique de quadrature et de uniroot() », ce qui répond à la question Q1 de l'audit.
- Fichier en ASCII : 0 caractère hors ASCII, avant comme après.
- `--essai` : code 0, nouveau libellé imprimé.

## Lot B (#479), `tests/unitaires/test_rapport_html.R`

- Seul le bloc de l'assertion #323 de la frontière change (l. 2471-2494) ; le second volet `fmt_p_win` est ajouté.
- L'émulation est fidèle à #479 : notation e si l'exposant de la valeur non arrondie est inférieur à −4. L'ancienne `fmt_p` émulée rend « 1e-04 » sur 9,995e-5 et 9,9995e-5.
- Mordant, mesuré sur le bloc réel : `12872c3` échoue, `ccb5771` passe, le mutant `ex >= -3L` échoue.
- Aucune fuite d'état : `fmt_p` et `.num_fr` sont intacts et aucun `sprintf` n'est posé dans l'environnement du fichier.
- 296 assertions sur 296.

## Lot C (#475), `tests/controle_doc_nd.R` et `tests/unitaires/test_controle_doc_nd.R`

- Le contrôle (a) est lancé une seule fois, avant le test du refus. L'en-tête est imprimé dans les mêmes cas qu'à `ccb5771`. L'annotation est émise sur les deux chemins, avec la même condition et le même texte.
- Le diff ne touche aucun seuil, motif, règle ou budget.
- Harnais du `coder` (52 cas) relancé : les codes de sortie sont identiques. Trois sorties diffèrent (refus avec .tex sale sous `GITHUB_ACTIONS=true`), et seulement par la ligne d'annotation : c'est la seule exception permise.
- 16 cas ajoutés par l'audit (refus faute de labels `-fin`, appariement 77 / 32, croisés avec `--remplissage`, argument inconnu, `--debordements`) : les seules différences sont l'annotation attendue.
- L'étape de CI (`ci.yml` l. 459-472) reste correcte.
- 282 assertions sur 282, sans et avec `GITHUB_ACTIONS=true`. La première assertion ajoutée échoue sur `ccb5771`.

## Remarques

1. `mesure_dw_rho_negatif_t8.R:48-49` : l'occurrence 2 ajoute « seulement » après « −0,99 ». Le mot est repris de l'occurrence 1 et de la sortie ; le fond est inchangé.
2. `docs/tableaux/20261031-issue164-dw-rho-negatif.md:3` : la ligne « Statut » du tableau daté porte encore l'ancien libellé (« approximation numérique d'Imhof… »). Ce tableau est hors périmètre (C3-K6, aucun tableau daté réécrit) : la décision revient au mainteneur.
3. `controle_doc_nd.R:1099` : dans le refus, l'annotation affiche « 0 fiche(s) en violation, 0 débordement(s) » pour des contrôles non lancés (même message que le chemin normal, par contrainte). Lue seule dans le résumé de GitHub, elle pourrait passer pour un contrôle vert sur ces deux points.
4. `test_rapport_html.R:2472-2492` : `g`, `att`, `ev` et `fmt_p_win` sont assignés dans l'environnement du fichier, selon la convention existante. L'émulation ne modélise que le choix de notation de Windows ; la portabilité réelle reste à confirmer à l'étape 7.
