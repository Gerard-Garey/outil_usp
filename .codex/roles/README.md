# Fiches de rôle de GPT

Une fiche par rôle. Elle fixe la mission, l'exécutant, ce que le rôle peut écrire, les questions qu'il traite et la forme de son livrable. Ces fiches sont propres à GPT : elles ne renvoient pas à `.claude/`, qui décrit la méthode de Claude (`AGENTS.md`, « Périmètre de GPT »).

| Fiche | Famille | Exécutant à distance | Écrit |
|---|---|---|---|
| `architect.md` | pilotage | ChatGPT (work) | rien ; commentaire de PR |
| `actuary.md` | fond | ChatGPT (work) | rien ; commentaire de PR |
| `regulatory.md` | fond | ChatGPT (work) | rien ; commentaire de PR |
| `coder.md` | réalisation | `@codex` sur la PR de travail | code R, tests, `docs/feuille-de-route-gpt.md` |
| `docwriter.md` | réalisation | tâche Codex Cloud, puis `@codex` sur sa PR | `docs/latex/` |
| `audit.md` | vérification | tâche Codex Cloud distincte | rien |
| `app-review.md` | vérification | tâche Codex Cloud distincte | rien |

Modèles : le mainteneur les choisit dans l'interface, à raison du modèle le plus fort pour `architect` et `actuary` et du modèle standard pour les autres rôles. Aucun nom n'est fixé ici (décision du 29/09/2026 ; la correspondance de l'ADR 0012, point 5, n'est pas vérifiée).

## Règles communes

- **La fiche fait loi** pendant le rôle. Le rôle n'écrit que ce que sa fiche lui ouvre. Il ne fait aucune action réservée au mainteneur : fusion, création d'issue, déclenchement de workflow, choix de la suite du circuit. Seul `coder` écrit dans `tests/reference/`, et seulement selon `.codex/procedures/reproductibilite.md` (patch chirurgical, fermeture M30).
- **Il ne tranche pas ce que sa fiche renvoie à un autre.** Un doute statistique va à `actuary`, une lecture du règlement à `regulatory`, un arbitrage au mainteneur.
- **Un vérificateur ne corrige pas, un réalisateur ne s'auto-valide pas.** Aucun rôle n'enchaîne sur un autre.
- **Le livrable** commence par l'en-tête d'`AGENTS.md` (« Rigueur : un livrable se prouve ») et suit la forme de la fiche. Ce qui revient au mainteneur (commiter, porter une question, viser un tableau) y figure comme **remontée**, jamais comme action faite.

## Rôle tenu par la session elle-même (poste local sans sous-agents)

- **Entrée.** Annoncer le rôle (« Rôle : `audit` — objet : diff de `<sha>` pour #N »), relire intégralement sa fiche, puis écrire le brief **avant** d'entrer dans le rôle, dans les termes où on le donnerait à un tiers.
- **Sortie.** Rendre le livrable, annoncer la sortie du rôle, puis décider de la suite selon le plan. Un livrable n'est jamais réécrit après coup ; un désaccord se dit dans le compte rendu de la session.
- **Indépendance.** Une vérification se fait de préférence dans une tâche distincte. À défaut, le vérificateur part du diff commité (`git diff`, `git show`) et de batteries **qu'il relance lui-même**, jamais du souvenir des intentions du réalisateur. Le livrable indique le mode : « tâche distincte » ou « même session ».
