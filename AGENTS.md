# AGENTS.md

Consignes pour ChatGPT travaillant sur ce dépôt, que ce soit par Codex (Codex Cloud, `@codex` en commentaire de PR, Codex en local) ou par ChatGPT avec le connecteur GitHub. Décision du mainteneur du 28/09/2026, et organisation à distance du 29/09/2026. Raisons et détail : `docs/adr/0012-flux-gpt-main-gpt.md`.

GPT intervient **par périodes** ; Claude (Claude Code) reste le contributeur principal. Le présent fichier et le dossier `.codex/` sont **le seul cadre de travail de GPT**. Les règles de fond du projet, elles, sont communes aux deux contributeurs.

## Périmètre de GPT, séparé de celui de Claude

Les deux contributeurs ont des méthodes différentes. Pour qu'aucune ne déteigne sur l'autre, chacun a ses propres fichiers de processus.

- **À lire avant tout travail** :
  - `AGENTS.md` (ce fichier) ;
  - la fiche de son rôle dans `.codex/roles/` et, s'il y a lieu, les procédures de `.codex/procedures/` ;
  - `README.md` : objet de l'outil, prérequis, structure, commandes ;
  - dans `CLAUDE.md`, **les seules sections de fond** : « Contexte », « Architecture (contrainte impérative) » avec « Flux du moteur » et « Structure d'un résultat de test », « Reproductibilité », « Documentation LaTeX », « Rigueur statistique ». Ce sont des règles du projet ; elles s'appliquent à GPT sans changement ;
  - `CONTEXT.md` (vocabulaire du domaine, à employer tel quel), `docs/exigences.md` (cahier des charges), `docs/adr/` (décisions), `docs/latex/CONVENTIONS.md` (avant toute modification du `.tex`) ;
  - `docs/feuille-de-route-gpt.md` sur `main-GPT` (voir « Feuille de route de GPT »).
- **À ne pas lire ni appliquer** : les autres sections de `CLAUDE.md` (Git et GitHub, Sous-agents, Agent skills), tout le dossier `.claude/` (fiches d'agents, skills, workflows, hooks), `docs/feuille-de-route.md` (feuille de route de Claude), ainsi que les corps de PR, handoffs et commentaires des branches `claude/…`. Ils décrivent la méthode de Claude, pas celle de GPT. En cas de contradiction apparente entre ces fichiers et `.codex/`, `.codex/` fait foi pour GPT, sauf sur une règle de fond.
- **Ce que GPT ne modifie jamais**, sauf instruction du mainteneur : `CLAUDE.md`, `AGENTS.md`, `.claude/`, `.codex/`, `.github/`, `LICENSE`, `docs/adr/`, `CONTEXT.md`, `docs/feuille-de-route.md` et les réglages du dépôt. Un terme nouveau, une décision d'architecture ou une règle à changer se **propose** dans la PR `main-GPT` → `main` ; Claude les consigne à l'audit.

## Qui exécute quoi : les rôles à distance

Les rôles sont ceux du projet. **Ceux qui écrivent ne vérifient pas, ceux qui vérifient n'écrivent pas.** À distance, **le mainteneur tient le rôle de session principale** : il appelle chaque rôle dans l'ordre du plan d'`architect`, lit les livrables, décide de la suite et fusionne. Aucun rôle n'enchaîne sur un autre.

| Rôle | Exécutant | Écrit dans le dépôt | Livrable |
|---|---|---|---|
| `architect` | ChatGPT (work) avec le connecteur GitHub | rien | propositions pour la feuille de route GPT et plan de branche à cases à cocher, **en commentaire de PR** |
| `actuary` | ChatGPT (work) avec le connecteur GitHub | rien | avis ou validation, en commentaire de PR |
| `regulatory` | ChatGPT (work) avec le connecteur GitHub | rien | matrice de conformité, en commentaire de PR |
| `coder` | `@codex` en commentaire de la PR de travail GPT | code R, tests, `docs/feuille-de-route-gpt.md` (pas `docs/latex/`) | commit publié sur la branche de la PR, avec son compte rendu |
| `audit` | tâche Codex Cloud **distincte**, sur la tête publiée | rien | rapport à constats gradués, collé en commentaire de PR par le mainteneur |
| `app-review` | tâche Codex Cloud **distincte**, sur la tête publiée | rien | rapport, collé en commentaire de PR par le mainteneur |
| `docwriter` | tâche Codex Cloud, puis `@codex` sur **sa propre PR** | `docs/latex/` (`.tex` et PDF) | un commit `docs:` par issue, sur `gpt/doc-<objet>` |

- **Rôles tenus dans ChatGPT (work)** : le connecteur GitHub leur sert à **lire** le dépôt, les issues et les PR, et à **poster un commentaire** sur la PR désignée par le mainteneur. Ils n'utilisent aucune autre action d'écriture du connecteur : pas de fichier, pas de commit, pas de branche, pas de PR, pas de libellé, pas de fusion. Une issue se **propose** dans le commentaire ; elle n'est jamais créée.
- **Rôles tenus dans Codex** : une tâche joue **un seul rôle**. Un `@codex` dont le texte ressemble à une demande de relecture peut partir en « Codex Review » automatique. Le commentaire commence donc toujours par `Rôle : <rôle>`, et une vérification (`audit`, `app-review`) se lance comme tâche Codex Cloud, jamais par `@codex`. **Une tâche lancée sans `Rôle : …`** (tâche d'office à l'ouverture d'une PR, revue automatique) **ne modifie rien** : elle rend l'en-tête avec le statut `arrete` et la cause, sans proposer de diff (constaté sur la PR #150 le 29/09/2026).
- **Poste local** (Codex en local, avec sous-agents ou non) : même répartition des rôles et mêmes livrables. Un rôle tenu par la session elle-même suit la règle d'entrée et de sortie de `.codex/roles/README.md`.

## Environnement Codex Cloud

- **R n'est pas installé par défaut.** Le mainteneur déclare une fois `bash .codex/setup.sh` comme script de setup de l'environnement, ou `USP_LATEX=1 bash .codex/setup.sh` pour un environnement qui sert aussi `docwriter` (TeX Live, plusieurs minutes).
- **En début de chaque tâche Codex** : `command -v Rscript`. S'il est absent, lancer `bash .codex/setup.sh`. Si R reste indisponible, **s'arrêter** avec le statut `arrete` et la cause. Un rôle qui doit exécuter une batterie ne rend jamais « tests non lancés » comme un succès.
- Les batteries se lancent sous `LC_ALL=C.UTF-8` (faux échec de la concordance sous POSIX, #113).
- **Pas de remote Git** : une tâche travaille sur une branche locale (`work`). Elle ne pousse pas, ne crée pas de PR et ne peut pas vérifier une publication. La publication est faite par le mainteneur, depuis l'interface (« Publication » ci-dessous).

## Branches

1. **Ne jamais toucher `main`** : ni commit, ni push, ni fusion, ni PR depuis une branche de travail.
2. **`main-GPT`** est le `main` de GPT.
   - **Claude la crée** depuis `main` à l'ouverture d'une période. Son premier commit est `docs/feuille-de-route-gpt.md`, copie de la feuille de route de Claude. Claude ouvre aussi la PR brouillon `main-GPT` → `main` : la **PR de période**.
   - **Intégration de `main`** : au début de chaque période et de chaque reprise, le mainteneur clique sur « Update branch » de la PR de période, ce qui produit un commit de fusion, jamais un rebase. En cas de conflit, Claude le résout sur une branche partie de `main-GPT`, avec une PR vers `main-GPT`. `main` prime : un conflit de fond avec une décision déjà prise sur `main` se règle en faveur de `main`.
   - **Base de toute tâche** : une tâche GPT vérifie que sa base est bien `main-GPT` ou la branche de travail GPT. Sur toute autre base, elle s'arrête.
3. **Une branche de travail à la fois**, `gpt/<objet>`, créée depuis `main-GPT`, au périmètre fermé d'issues. Ce périmètre est le lot de la période : un lot **disjoint par fichier** de la branche de travail courante de Claude. Aucun fichier n'est commun, en particulier `R/engine.R`, `tests/reference/`, `docs/latex/doc_tests_usp.tex` et le PDF compilé. Le lot est proposé par `architect` et **fixé par le mainteneur** (ADR 0012, annotation du 28/09/2026 au soir, point 3). La PR de la branche de travail vise `main-GPT` ; elle est **fusionnée par le mainteneur**, par commit de fusion, CI verte. GPT ne fusionne jamais et n'active pas l'auto-merge.
4. **Branche de documentation `gpt/doc-<objet>`** : branche temporaire, créée depuis la **tête de la branche de travail GPT**, après son dernier commit de code (un seul passage de `docwriter` par branche). Sa PR vise la branche de travail GPT et est fusionnée par le mainteneur avant la revue finale. La branche est ensuite supprimée.
5. **Branche éphémère de régénération `gpt/regeneration-<issue>`** : voir « Reproductibilité et références ».

### Publication sous Codex Cloud

- **Ouverture de la branche de travail**, quand aucune PR de travail GPT n'est ouverte : une tâche Codex Cloud est lancée **avec `main-GPT` pour base**. Le mainteneur examine le diff, puis crée depuis l'interface la PR vers `main-GPT`, en nommant la branche `gpt/<objet>` si l'interface le permet. Il vérifie ensuite la base de la PR, car l'interface propose `main` par défaut.
- **Toute réalisation ultérieure**, correction comprise, se fait **sur cette PR** (`@codex` en commentaire) et se publie sur sa branche. Ne jamais créer une deuxième PR pour contourner un push impossible, sauf la PR de documentation (point 4).
- **Publication impossible ou incertaine** : le livrable le dit explicitement (« publication non faite », avec la cause), finit en statut `arrete` et contient le diff complet, pour que le mainteneur le publie.
- **Vérification sur GitHub** : une publication annoncée (PR créée, commit publié) n'est tenue pour faite qu'une fois vérifiée sur GitHub : PR existante, base, SHA de tête, liste des commits. Ce contrôle revient à la tâche si elle y a accès, sinon au rôle suivant, au début de sa tâche. Un livrable ne vaut que pour le SHA effectivement publié.

## Feuille de route de GPT

- `docs/feuille-de-route-gpt.md` n'existe que sur `main-GPT`. C'est **la seule feuille de route que lit GPT**.
- **`architect` ne la modifie pas.** Il propose les changements en commentaire de PR, en texte prêt à appliquer, et `coder` les applique par un commit `docs:` quand le mainteneur le lui demande.
- **Si le fichier est absent de `main-GPT`**, c'est qu'aucune période n'est ouverte : Claude le supprime quand il reprend la main, à l'audit. GPT s'arrête alors et le signale au mainteneur. Il ne recrée pas le fichier et ne se rabat pas sur `docs/feuille-de-route.md`.

## Le plan de branche d'`architect`

Le mainteneur appelle les rôles un par un. Le plan d'`architect` lui donne donc, **dans l'ordre**, chaque appel avec son exécutant et son texte exact. Chaque ligne commence par une case à cocher, que le mainteneur coche une fois le livrable lu et accepté. `architect` poste le plan en commentaire de la PR de période ; le mainteneur le recopie dans le corps de la PR de travail dès sa création. Forme imposée (le détail est dans `.codex/roles/architect.md`) :

```markdown
### Plan de la branche gpt/<objet> — issues #A, #B

- [ ] 1. `coder` — tâche Codex Cloud, base `main-GPT` — « Rôle : coder. … »
- [ ] 2. `audit` — tâche Codex Cloud distincte, audit léger — « Rôle : audit. … »
- [ ] 3. `actuary` — ChatGPT (work), commentaire sur la PR #N — « Rôle : actuary. … »
- [ ] …
- [ ] k. `docwriter` — tâche Codex Cloud, base : tête de gpt/<objet>, PR gpt/doc-<objet> — « Rôle : docwriter. … »
- [ ] k+1. `audit` — tâche Codex Cloud distincte, revue finale complète — « … »
- [ ] k+2. `actuary` — ChatGPT (work) — validation du diff du `.tex` — « … »
- [ ] Mainteneur : sortie du brouillon, puis fusion dans `main-GPT`.
```

Les points de décision (visa d'un changement de σ_USP ou de verdict, question à `actuary`, arbitrage) sont des lignes du plan, à la place qu'ils occupent dans le circuit. Aucune étape ne les franchit sans décision.

## Rigueur : un livrable se prouve

Le risque d'erreur est plus élevé à distance : les rôles sont séparés dans le temps, et le mainteneur relaie. Chaque livrable se lit donc comme s'il allait être contesté.

- **Toute affirmation sur le comportement du code s'adosse à une commande exécutée**, citée avec sa sortie : code, tests, résultats, performance. Sans mesure, l'affirmation est présentée comme une hypothèse, ou elle est retirée.
- **Batteries** : les trois batteries du README, sous `LC_ALL=C.UTF-8`, sur l'état exact du SHA rendu, avec le décompte d'assertions et le code de sortie. Un « les tests passent » sans sortie n'est pas recevable.
- Un rôle tenu dans ChatGPT (work) **n'exécute pas R**. Un chiffre qu'il avance est soit tiré d'un livrable Codex qui le mesure (cité : SHA, commande), soit demandé en mesure au rôle suivant.
- **Aucune référence, aucun théorème, aucun numéro de page ni aucune vitesse de convergence inventés.** Quand la littérature ne permet pas de conclure à T = 8, l'écrire tel quel.
- **Chaque livrable commence par l'en-tête** :
  ```
  Rôle : <rôle> — Objet : <issue(s), étape du plan> — SHA examiné ou produit : <sha>
  Exécutant : <ChatGPT work | @codex | tâche Codex Cloud | local> — Statut : termine | termine avec questions | arrete
  ```
  - `termine avec questions` : les seules remontées sont des questions pour `actuary` ou le mainteneur.
  - `arrete` : constat bloquant, batterie en échec, R indisponible, publication non faite ou base erronée.

## Issues

- Création **sur accord du mainteneur** seulement. L'issue proposée (titre, libellés, corps) figure dans le livrable. Une fois approuvée, elle est créée par le mainteneur avec le libellé **`gpt`**, en plus des libellés de tri (`docs/agents/triage-labels.md`).
- Vocabulaire de `CONTEXT.md`. Un problème hors du lot devient une issue proposée, pas une modification.

## Commits

- En local et dans une tâche Codex : auteur **`Codex <noreply@openai.com>`** (`git config user.name Codex`, `git config user.email noreply@openai.com`).
- Un commit publié depuis l'interface Codex Cloud peut porter l'identité du mainteneur. Le dernier paragraphe de chaque message de commit porte donc la ligne **`Réalisé-par: Codex (rôle <rôle>)`** : c'est elle qui identifie un commit de GPT à l'audit.
- Messages en français, avec accents, préfixés par le domaine : `moteur:`, `app:`, `tests:`, `docs:` (dont `docs/feuille-de-route-gpt.md`), `repo:`. Le préfixe `claude:` est réservé à Claude. Renvoi à l'issue (`#N`).
- Un commit par issue qui change un résultat, avec son tableau avant / après.
- Aucun identifiant de modèle ni lien de session dans les commits, les PR ou le code.

## Reproductibilité et références

- Procédure : `.codex/procedures/reproductibilite.md`. **Aucune régénération de `tests/reference/*.rds` hors de la CI** (ADR 0011). Pendant une période GPT, **le mainteneur déclenche `references.yml`** et dépose l'artefact ; GPT prépare la branche éphémère et les motifs (ADR 0012, annotation du 28/09/2026 au soir, point 1). La fermeture (vérifications (a′) à (c) et commit unique code + `.rds`) se fait **par Codex en local** sur le poste du mainteneur ; à défaut, GPT **la délègue à Claude**, qui la fait par une PR vers la branche de travail GPT (décision du mainteneur du 29/09/2026).
- Tout changement de σ_USP ou d'un verdict est soumis au mainteneur, et les autres changements de p-values à `actuary`. Chaque tableau avant / après est relu par Claude à l'audit.
- Documentation LaTeX : `.codex/procedures/compilation-doc.md`. Le PDF est recompilé et commité avec le `.tex` (ADR 0008).

## PR de période `main-GPT` → `main`

Ouverte par Claude en brouillon ; son corps est tenu à jour par le mainteneur, sur les livrables de GPT. Il contient :

- les **issues que GPT considère comme résolues**, un `Closes #N` par ligne (GitHub ne lie que le premier numéro d'une liste) ;
- les **issues créées pendant la période** (libellé `gpt`) ;
- les commits qui changent un résultat, chacun avec son tableau avant / après et son visa ;
- pour chaque vérification, l'exécutant et le SHA examiné.

Cette PR est **auditée par Claude sur ordre du mainteneur**, avec la profondeur d'une revue de dossier. Claude y corrige, simplifie et optimise le code sur une branche `claude/audit-main-gpt-<date>`, et supprime `docs/feuille-de-route-gpt.md`. La fusion vers `main` appartient au mainteneur, puis `main-GPT` est supprimée.
