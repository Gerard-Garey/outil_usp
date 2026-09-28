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
3. **Une branche de travail à la fois**, `gpt/<objet>`, créée depuis `main-GPT`, au périmètre fermé d'issues. Ce périmètre est le lot d'une **période GPT** : un lot d'issues **disjoint par fichier** de la branche de travail courante de Claude (aucun fichier commun, en particulier `R/engine.R`, `tests/reference/`, `docs/latex/doc_tests_usp.tex` et le PDF compilé), proposé par `architect` dans la feuille de route et **fixé par le mainteneur** avant l'ouverture de la période (ADR 0012, annotation du 28/09/2026 au soir, point 3). Une issue qui exigerait un fichier que la branche de Claude modifie attend la fusion de celle-ci. PR vers `main-GPT`, **fusionnée par le mainteneur** (commit de fusion), CI verte. GPT ne fusionne jamais une PR et n'active pas l'auto-merge.
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

## Sous-agents et rôles

Les sept fiches de `.claude/agents/` (`architect`, `actuary`, `regulatory`, `coder`, `docwriter`, `audit`, `app-review`) définissent des **rôles** : mission, périmètre d'écriture (champ `tools` et consignes), questions à traiter, forme du livrable. Les circuits types, les déclencheurs et la règle « **ceux qui écrivent ne vérifient pas, ceux qui vérifient n'écrivent pas** » de `CLAUDE.md` s'appliquent à GPT, qu'il dispose ou non de sous-agents. Le modèle de chaque rôle suit le champ `model` de sa fiche :

| `model` de la fiche | Modèle GPT |
|---|---|
| `fable` | `gpt-6-astra` |
| `opus`, `sonnet` | `gpt-6-sol` |

### Deux modes d'exécution

1. **Orchestré** (sous-agents disponibles) : la session principale confie chaque rôle à un sous-agent, avec la fiche comme consigne, et reçoit son livrable, comme le fait Claude.
2. **Incarné** (sous-agents indisponibles, par exemple Codex Cloud) : la session principale **joue elle-même le rôle**, un rôle à la fois, selon les règles ci-dessous. Le circuit, l'ordre des rôles et les livrables sont les mêmes qu'en mode orchestré ; seul change l'exécutant.

### Mode incarné : entrer dans un rôle, en sortir

- **Entrée.** La session principale annonce le rôle (« Rôle : `audit` — objet : diff de `<commit>` pour #N »), relit **intégralement** la fiche de `.claude/agents/<rôle>.md`, puis le brief qu'elle se donne : objet, périmètre, question posée. Ce brief est écrit **avant** d'entrer dans le rôle, dans les termes où il serait donné à un sous-agent.
- **Pendant le rôle, la fiche fait loi, y compris contre les habitudes de la session principale.** Le rôle :
  - n'utilise que les outils et n'écrit que dans les fichiers que sa fiche lui ouvre (un vérificateur n'écrit rien ; `actuary` et `regulatory` n'écrivent que des avis) ;
  - ne fait **aucune action réservée à la session principale** : pas de `git commit`, `git push`, fusion, PR, déclenchement de workflow, régénération ou patch de `tests/reference/`, création d'issue, sauf quand la fiche du rôle l'autorise expressément ;
  - ne tranche pas ce que sa fiche renvoie à un autre (un doute statistique de `coder` va à `actuary`, une lecture du règlement à `regulatory`, un arbitrage au mainteneur) ;
  - ne corrige pas ce qu'il constate s'il est vérificateur, et ne s'auto-valide pas s'il est réalisateur ;
  - ne passe pas à l'étape suivante du circuit et n'enchaîne pas un autre rôle.
- **Sortie.** Le rôle se termine par son **livrable, dans la forme exacte de sa fiche** (compte rendu, rapport à constats gradués, avis, matrice, issue proposée), titré du nom du rôle. Ce qui, dans la fiche, est adressé à « la session principale » (commiter après audit, porter une question à `actuary`, soumettre au mainteneur) est **laissé à la session principale** et figure dans le livrable comme remontée, non comme action faite.
- **Retour à la session principale.** Elle annonce la sortie du rôle, lit le livrable comme s'il venait d'un sous-agent, et décide de la suite selon le circuit : commit, reprise par `coder`, question à `actuary`, arrêt pour le mainteneur. Elle ne réécrit pas un livrable après coup ; si elle le conteste, elle le dit dans son propre compte rendu.

### Séparation entre réalisation et vérification en mode incarné

Une même session qui réalise puis vérifie garde en mémoire les intentions du réalisateur : c'est le biais que la séparation des rôles veut écarter.

- **Une vérification (`audit`, `app-review`, validation d'`actuary`, contrôle de `regulatory`) se fait de préférence dans une tâche Codex distincte**, ouverte par le mainteneur, sur la tête poussée de la branche, avec pour seules entrées la fiche, le brief et le diff.
- À défaut, dans la même session : le vérificateur part **du diff commité ou indexé** (`git diff`, `git show`) et des sorties des batteries qu'il **relance lui-même**, jamais du souvenir de ce que le réalisateur voulait faire ; il traite chaque affirmation du compte rendu de `coder` comme une hypothèse à vérifier.
- **Traçabilité** : le message de commit, ou la PR, indique pour chaque vérification le mode (« orchestré », « incarné, tâche distincte », « incarné, même session »), pour que le mainteneur et l'audit de Claude sachent quel degré d'indépendance elle a eu.

### Skills

Les procédures des skills de `.claude/skills/` s'appliquent (`verifier-reproductibilite`, `compiler-doc`), quel que soit le mode ; le workflow `circuit-technique` et la skill `audit-main-gpt` sont réservés à Claude.

## Reproductibilité et références

- Batteries sous `LC_ALL=C.UTF-8` : `Rscript tests/test_unitaires.R`, `Rscript tests/test_reproductibilite.R`, `Rscript tests/concordance_doc_moteur.R --strict`.
- **Aucune régénération de `tests/reference/*.rds` hors de la CI** (ADR 0011) ; procédure M30 de la skill `verifier-reproductibilite`, avec la répartition suivante (ADR 0012, annotation du 28/09/2026 au soir, point 1) :
  1. GPT prépare la branche éphémère `gpt/regeneration-<issue>` depuis la tête de sa branche de travail (commit de code, plus un par correction après un refus) et rédige les **motifs attendus par cas** (M33) ;
  2. **le mainteneur déclenche `references.yml`** (mode `regeneration` ou `creation`, `ref = gpt/regeneration-<issue>`) et **dépose l'artefact** à la disposition de GPT ; GPT ne déclenche jamais le workflow, et le mode `bascule` lui reste hors de portée ;
  3. GPT fait les vérifications (a′), (b) et (c), puis le **commit unique code + `.rds`** sur sa branche de travail, et supprime la branche éphémère.

  Tout changement de σ_USP ou d'un verdict est soumis au mainteneur, les autres changements de p-values à `actuary` ; chaque tableau avant / après est relu par Claude à l'audit.

## Hors du périmètre de GPT, sauf instruction du mainteneur

`CLAUDE.md`, `AGENTS.md`, `.claude/`, `.github/`, `LICENSE`, les ADR (`docs/adr/`, rédigés par l'agent `architect`) et les réglages du dépôt.
