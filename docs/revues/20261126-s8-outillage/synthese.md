# Revues de la branche S8 (outillage) — synthèse

Branche `claude/outillage-ci-et-controles`, PR #626, partie de `main` `b084e13`. Rapports versés tels quels dans ce dossier.

| Fichier | Agent | Objet | Verdict |
|---|---|---|---|
| `audit-inventaire-ci-561.md` | `audit` | Inventaire rafraîchi de la CI (étape 3, #561, #471) | Propositions 1 et 5 confirmées, 4 étendue, 2 et 3 réévaluées, 6 presque écartée ; point d'arrêt PS-1 |
| `actuary-tableau-470.md` | `actuary` | Nouveau tableau de la mesure d'indépendance des t_j (étape 6, #470) | Visa ; synthèse identique à celle du 06/11, pas de PS-2 |
| `audit-revue-finale.md` | `audit` (high) | Revue finale complète de `git diff main...HEAD` à `98a2be6` (règle 10) | Conforme avec réserves : M1 (critère d'équilibre de #561), m1, m2 |

Suites données à la revue finale :

- **M1** : critère d'équilibre des lots de #561 reformulé par le mainteneur le 26/11/2026 (charges estimées par `repartir_lots()` à partir de la table mesurée, écart 0,1 %) ; `Closes #561` maintenu. Durées de CI observées consignées dans la PR et la feuille de route (E-26/11 (critère d'équilibre de #561, S8)).
- **m1** : faux positif A1 du contrôle ND après un `%` d'argument de `\url` ou de `\href`, corrigé (`8ae5655`), `CONVENTIONS.md` aligné (`c0e4afe`).
- **m2** : message de refus de `--fichiers`, corrigé (`918c62f`).
- Audit léger de ces corrections : conforme ; la réserve sur `CONVENTIONS.md` est levée par `c0e4afe`.

Aucun résultat du moteur n'a changé sur la branche : `R/`, `app.R`, `DESCRIPTION`, `tests/reference/`, `tests/donnees/` et `tests/outils_tests.R` sont identiques à `b084e13`.
