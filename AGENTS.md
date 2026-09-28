# AGENTS.md

Consignes pour ChatGPT travaillant sur ce dépôt via Codex. Décision du mainteneur du 28/09/2026 ; raisons et détail : `docs/adr/0012-flux-gpt-main-gpt.md`.

GPT intervient **épisodiquement** ; Claude (Claude Code) reste le contributeur principal. Ce fichier ne recopie pas les règles du projet : il dit lesquelles s'appliquent et ce qui change pour GPT.

## À lire avant tout travail

- `README.md` : objet de l'outil, prérequis, structure, commandes (application, moteur seul, tests).
- `CLAUDE.md` : **toutes ses règles de fond s'appliquent à GPT** — contexte et textes sources (la version consolidée du règlement fait foi ; formules lues en rendu graphique), architecture moteur / affichage (contrainte impérative), flux du moteur, structure d'un résultat de test, reproductibilité, documentation LaTeX, rigueur statistique, sous-agents et circuits, messages de commit. Seuls ses passages propres à Claude sont remplacés par le présent fichier : branche de travail et session cloud, identité des commits, audit de `main-GPT`.
- `CONTEXT.md` (vocabulaire du domaine, à employer tel quel), `docs/exigences.md` (cahier des charges), `docs/adr/` (décisions), `docs/latex/CONVENTIONS.md` (avant toute modification du `.tex`).

## Branches

1. **Ne jamais toucher `main`** : ni commit, ni push, ni fusion, ni PR depuis une branche de travail.
2. **`main-GPT`** est le `main` de GPT. Si elle n'existe pas, la créer depuis `main` au début du travail et la pousser. **En début de chaque session**, y intégrer `main` par un commit de fusion (`git merge origin/main`, jamais de rebase ni de force-push) et résoudre les conflits ; `main` prime : un conflit de fond avec une décision déjà prise sur `main` se règle en faveur de `main`, ou se signale au mainteneur.
3. **Une branche de travail à la fois**, `gpt/<objet>`, créée depuis `main-GPT`, au périmètre fermé d'issues ; PR vers `main-GPT`, **fusionnée par le mainteneur** (commit de fusion), CI verte. GPT ne fusionne jamais une PR et n'active pas l'auto-merge.
4. **PR `main-GPT` → `main`** : ouverte par GPT quand son travail est prêt. Son corps contient :
   - la liste des **issues que GPT considère comme résolues**, un `Closes #N` par ligne (GitHub ne lie que le premier numéro d'une liste) ;
   - la liste des **issues créées par GPT** ;
   - les commits qui changent un résultat, chacun avec son tableau avant / après.

   Cette PR est **auditée par Claude sur demande du mainteneur** ; Claude peut modifier le code (branche `claude/audit-main-gpt-<date>`, PR vers `main-GPT`), en particulier pour le simplifier et l'optimiser. La fusion vers `main` appartient au mainteneur ; `main-GPT` est ensuite supprimée.

## Issues

- Création **sur accord du mainteneur** seulement : rédiger l'issue proposée (titre, libellés, corps) dans le compte rendu ; une fois approuvée, la créer avec le libellé **`gpt`** en plus des libellés de tri (`docs/agents/triage-labels.md`).
- Vocabulaire de `CONTEXT.md` ; un problème hors périmètre devient une issue, pas une branche.

## Commits

- Auteur : **`Codex <noreply@openai.com>`** (`git config user.name Codex`, `git config user.email noreply@openai.com` dans le dépôt).
- Messages en français, avec accents, préfixés par le domaine (`moteur:`, `app:`, `tests:`, `docs:`, `repo:` ; `claude:` est réservé à Claude), renvoi à l'issue (`#N`). Un commit par issue qui change un résultat, avec son tableau avant / après.
- Aucun identifiant de modèle ni lien de session dans les commits, les PR ou le code.

## Sous-agents

GPT peut reprendre les fiches de `.claude/agents/` (rôle, périmètre d'écriture, questions) et la règle de séparation « ceux qui écrivent ne vérifient pas, ceux qui vérifient n'écrivent pas ». Le modèle de chaque sous-agent suit le champ `model` de sa fiche :

| `model` de la fiche | Modèle GPT |
|---|---|
| `fable` | `gpt-6-astra` |
| `opus`, `sonnet` | `gpt-6-sol` |

Les procédures des skills de `.claude/skills/` s'appliquent (`verifier-reproductibilite`, `compiler-doc`) ; le workflow `circuit-technique` et la skill `audit-main-gpt` sont réservés à Claude.

## Reproductibilité et références

- Batteries sous `LC_ALL=C.UTF-8` : `Rscript tests/test_unitaires.R`, `Rscript tests/test_reproductibilite.R`, `Rscript tests/concordance_doc_moteur.R --strict`.
- **Aucune régénération de `tests/reference/*.rds` hors de la CI** (ADR 0011) ; procédure de la skill `verifier-reproductibilite`, branche éphémère `gpt/regeneration-<issue>` depuis la tête de la branche de travail GPT, déclenchement du workflow `references.yml` **sur ordre du mainteneur**. Tout changement de σ_USP ou d'un verdict est soumis au mainteneur.

## Hors du périmètre de GPT, sauf instruction du mainteneur

`CLAUDE.md`, `AGENTS.md`, `.claude/`, `.github/`, `LICENSE`, les ADR (`docs/adr/`, rédigés par l'agent `architect`) et les réglages du dépôt.
