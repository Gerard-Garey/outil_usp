# Suivi des issues : GitHub

Les issues et les specs de ce dépôt sont des issues GitHub de `Gerard-Garey/outil_usp`. Toutes les opérations passent par la CLI `gh`.

Sur le poste local, `gh` doit être installé (`winget install GitHub.cli`) et authentifié (`gh auth login`) avant usage.

## Conventions

- **Créer une issue** : `gh issue create --title "..." --body "..."`. Utiliser un heredoc pour un corps sur plusieurs lignes.
- **Lire une issue** : `gh issue view <numéro> --comments`, en filtrant les commentaires avec `jq` et en récupérant aussi les libellés.
- **Lister les issues** : `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'`, avec les filtres `--label` et `--state` appropriés.
- **Commenter une issue** : `gh issue comment <numéro> --body "..."`
- **Ajouter / retirer des libellés** : `gh issue edit <numéro> --add-label "..."` / `--remove-label "..."`
- **Fermer** : `gh issue close <numéro> --comment "..."`

Déduire le dépôt de `git remote -v` ; `gh` le fait automatiquement lorsqu'il est lancé dans un clone.

## Pull requests comme surface de tri

**PR comme surface de demande : non.** _(Passer à `oui` si ce dépôt traite les PR externes comme des demandes de fonctionnalité ; `/triage` lit ce paramètre.)_

Lorsqu'il vaut `oui`, les PR suivent les mêmes libellés et états que les issues, avec les équivalents `gh pr` :

- **Lire une PR** : `gh pr view <numéro> --comments`, et `gh pr diff <numéro>` pour le diff.
- **Lister les PR externes à trier** : `gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments`, puis ne garder que les `authorAssociation` valant `CONTRIBUTOR`, `FIRST_TIME_CONTRIBUTOR` ou `NONE` (écarter `OWNER`/`MEMBER`/`COLLABORATOR`).
- **Commenter / étiqueter / fermer** : `gh pr comment`, `gh pr edit --add-label`/`--remove-label`, `gh pr close`.

GitHub partage une seule numérotation entre issues et PR : un `#42` isolé peut désigner l'une ou l'autre. Résoudre avec `gh pr view 42`, puis à défaut `gh issue view 42`.

## Quand un skill demande de « publier dans le suivi des issues »

Créer une issue GitHub.

## Quand un skill demande de « récupérer le ticket concerné »

Lancer `gh issue view <numéro> --comments`.

## Opérations de wayfinding

Utilisées par `/wayfinder`. La **carte** est une issue unique, dont les tickets sont des issues **enfants**.

- **Carte** : une issue unique portant le libellé `wayfinder:map`, dont le corps contient les sections Notes / Décisions à ce jour / Zones floues. `gh issue create --label wayfinder:map`.
- **Ticket enfant** : une issue rattachée à la carte comme sous-issue GitHub (`gh api` sur l'endpoint des sous-issues). Si les sous-issues ne sont pas activées, ajouter l'enfant à une liste de tâches dans le corps de la carte et placer `Part of #<carte>` en tête du corps de l'enfant. Libellés : `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Une fois pris, le ticket est assigné au développeur qui le pilote.
- **Blocage** : les **dépendances natives d'issues** de GitHub, représentation canonique et visible dans l'interface. Ajouter une dépendance avec `gh api --method POST repos/<owner>/<repo>/issues/<enfant>/dependencies/blocked_by -F issue_id=<id-bdd-bloquant>`, où `<id-bdd-bloquant>` est l'**identifiant de base de données** numérique de l'issue bloquante (`gh api repos/<owner>/<repo>/issues/<n> --jq .id`, et _non_ le `#numéro` ni le `node_id`). GitHub expose `issue_dependencies_summary.blocked_by` (bloquants ouverts uniquement, le verrou effectif). Si les dépendances ne sont pas disponibles, se rabattre sur une ligne `Blocked by: #<n>, #<n>` en tête du corps de l'enfant. Un ticket est débloqué lorsque tous ses bloquants sont fermés.
- **Requête de frontière** : lister les enfants ouverts de la carte (`gh issue list --state open`, restreint aux sous-issues ou à la liste de tâches de la carte), écarter ceux qui ont un bloquant ouvert (`issue_dependencies_summary.blocked_by > 0`, ou une issue ouverte dans la ligne `Blocked by`) ou un assigné ; le premier dans l'ordre de la carte l'emporte.
- **Prise en charge** : `gh issue edit <n> --add-assignee @me`, première écriture de la session.
- **Résolution** : `gh issue comment <n> --body "<réponse>"`, puis `gh issue close <n>`, puis ajouter un pointeur de contexte (résumé + lien) dans la section Décisions à ce jour de la carte.
