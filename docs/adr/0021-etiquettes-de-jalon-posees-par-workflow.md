---
status: accepted
date: 2026-11-25
---

# L'étiquette annotée d'un jalon est posée par le workflow `etiquettes.yml`, à la fusion d'une PR courte qui verse son message ; c'est le seul workflow du dépôt qui écrit, et il n'écrit que des étiquettes

> *Rédigé par l'agent architect (IA), fiche `architect-approfondi` (ADR d'organisation : jugement, `docs/agents/routage.md`, § 3 ; modèle annoncé par l'environnement de la consultation : `claude-opus-5-5`), le 25/11/2026, soixante-quinzième point d'étape, partie 2, sur la branche de travail `claude/creneau-a3` (tête `2ddca5a`, `main` `c105f62`). Rédigé sur la décision Q-75-2 (a) du mainteneur du 25/11/2026 (`docs/feuille-de-route.md`, § 4, E-25/11 (Q-75)). **Statut : accepté le 25/11/2026** (rubrique « Acceptation » ; d'abord proposé, question Q-75-7). Aucun fichier de code, de test, de workflow ni de documentation LaTeX n'est modifié par cette proposition.*

## Contexte

**Ce qu'est une étiquette de jalon.** Un jalon de la phase S (Q-63-11 (a)) désigne un état de `main` employable pour un calcul du dossier : `Version` relevée, batterie sous Windows acceptée au critère de l'ADR 0006 (annotation du 14/11/2026), étiquette annotée. L'étiquette est ce qu'un relecteur trouve en clonant le dépôt : un nom (`v<Version>`, Q-67-2 (a)), un commit (la fusion du jalon) et un message qui cite le SHA de la batterie, les md5 de `R/engine.R` et de `R/charger_moteur.R`, le PDF, `\dateconsultation`, la dernière régénération de chaque cas et les limites connues.

**Règle écrite jusqu'ici.** Elle tient dans deux décisions de point d'étape, non dans un ADR :
- **Q-54-4 (a)**, 08/11/2026 : étiquette annotée posée « par le mainteneur, ou par la session sur son ordre exprès » sur l'état remis ;
- **Q-67-2 (a)**, 18/11/2026 : nom `v<Version>`, étiquette annotée (`git tag -a`), sur le commit de fusion du jalon, message de l'étape d'étiquette ; JS2 et JS3 suivent le même schéma.

`v2.1.0` (→ `abc6ff1`) et `v3.0.0` (→ `c013568`) ont été posées ainsi, par une session locale sur ordre du mainteneur (*vérifié*, `git cat-file -p` : tagger `Claude <noreply@anthropic.com>`, fuseau +0100).

**Ce qui s'est passé à l'étape 12 de JS2** (25/11/2026 ; `docs/feuille-de-route.md`, § 4, E-25/11 (JS2, 11-12), et § 6, bilan de JS2, écart (4)) :
1. la session cloud n'a pas pu pousser `v3.1.0` : refus du classificateur de l'environnement, puis du proxy git (HTTP 403) après l'autorisation du mainteneur ; le proxy n'admet que la branche assignée de la session ;
2. sur instruction du mainteneur : issue #621, puis correctif rapide PR #622 (commit `repo:` `94f5220`), qui ajoute `.github/workflows/etiquettes.yml` et `.github/etiquettes/v3.1.0.txt` ;
3. fusion par le mainteneur (`c105f62`, 22:04:27 UTC) ; exécution « Étiquettes annotées » 45710044766 `success` ; `v3.1.0` (objet `5f1605d`) → `3dae8bb`, message identique au fichier (*vérifié*, `git cat-file -p v3.1.0`) ; essai accepté par le mainteneur.

**Ce que fait le workflow** (*vérifié*, lecture de `.github/workflows/etiquettes.yml` à `c105f62`) :
- déclencheur : `push` sur `main` qui touche `.github/etiquettes/*.txt`, donc une fusion, que seul le mainteneur fait (ADR 0007, point 6) ;
- `permissions: contents: write` ; `concurrency` sans annulation ; `ubuntu-22.04`, cinq minutes au plus ; `actions/checkout` épinglée par SHA (`11d5960…`, v4.4.0), historique complet ;
- pour chaque fichier : nom `vX.Y.Z` exigé ; ligne 1 « `cible <SHA de 40 caractères>` », ligne 2 vide, sinon échec ; étiquette déjà présente sur `origin` : laissée telle quelle, jamais déplacée ni réécrite ; cible qui n'est pas un ancêtre de `main` : échec ; sinon `git tag -a <nom> <cible> -F <message>` (message : lignes 3 et suivantes), puis `git push origin refs/tags/<nom>` ; aucune branche n'est poussée ;
- identité de l'auteur de l'étiquette : `git config user.name "Claude"`, `user.email "noreply@anthropic.com"`, posée par le job.

**Pourquoi un ADR** (Q-75-2 (a)). C'est le **premier workflow du dépôt en `contents: write`** : `ci.yml`, `mots-cles-fermeture.yml`, `pdf-invariant.yml` et `references.yml` sont en `contents: read` (*vérifié*, `grep -n 'contents:' .github/workflows/*.yml`). La procédure d'un acte qui désigne l'état du dossier ne doit pas se lire dans un journal de 8 700 lignes. Enfin, le principe 2 de l'ADR 0010 (« aucune écriture dans l'historique ni dans l'état partagé du projet par un workflow ») pourrait être lu, à tort, comme interdisant ce workflow.

## Décision

### 1. Procédure ordinaire

1. **Préalables inchangés** (Q-67-8 (a)) : jalon fusionné ; batterie sous Windows acceptée ; aucune issue urgente ouverte (ADR 0018, § 5.1). Si l'un manque, aucune PR d'étiquette n'est ouverte.
2. **PR d'étiquette** : après la fusion du jalon (son commit de fusion, cible de l'étiquette, est inconnu avant), la session ouvre sur ordre du mainteneur une branche courte partie de `main`, `claude/etiquette-v<Version>`. Un seul commit `repo:` y ajoute `.github/etiquettes/v<Version>.txt` :
   - ligne 1 : `cible <SHA complet du commit de fusion du jalon>` ;
   - ligne 2 : vide ;
   - lignes suivantes : le message prévu par l'étape d'étiquette de la fiche du jalon (contenu de Q-67-2 (a), complété par les fiches JS1 et JS2).

   La PR remplit les trois conditions du **correctif rapide** (ADR 0007, point 3) : références identiques, un seul domaine (`repo:`), aucun `.tex`. Elle n'en demande pas d'issue propre : le commit et le corps de la PR renvoient à la PR du jalon, sans ligne `Closes` ni mot-clé de fermeture (Q-45-12).
3. **Relecture** : le mainteneur relit le message dans la PR. C'est la seule relecture : une fois posée, l'étiquette n'est plus réécrite.
4. **Pose** : à la fusion par le mainteneur, le workflow pose l'étiquette. La session vérifie ensuite :
   - l'exécution « Étiquettes annotées » (`success`) ;
   - `git ls-remote --tags origin` ;
   - `git cat-file -p v<Version>` : objet de type `tag`, cible attendue, message identique au fichier.

   Elle consigne au § 6 de la feuille de route le numéro de PR, le commit de fusion, l'exécution et l'objet.
5. **Le fichier reste versionné et n'est plus modifié.** Il trace le message exact. Une erreur relevée après la pose ne se corrige ni dans le fichier ni par un déplacement de l'étiquette. Elle se consigne au § 6, et dans le message de l'étiquette suivante si elle touche le dossier.

### 2. Voie de repli

`git tag -a` puis `git push` de l'étiquette, par le mainteneur, ou par une session **locale** sur son ordre exprès (cas de `v2.1.0` et `v3.0.0`). Le message est alors le contenu d'un fichier `.github/etiquettes/v<Version>.txt` déjà relu en PR, ou versé par une PR d'étiquette juste après la pose. Dans ce second cas, le workflow constate l'étiquette présente et la laisse telle quelle. Une session cloud ne pousse jamais d'étiquette (#621).

### 3. Garde-fous du workflow, à conserver

Toute modification de `etiquettes.yml` passe par une PR fusionnée par le mainteneur, et garde au moins :
- le déclencheur limité à `main` et à `.github/etiquettes/*.txt` ;
- le nom `vX.Y.Z` ;
- le format strict de l'en-tête ;
- la cible ancêtre de `main` ;
- l'interdiction de déplacer ou de réécrire une étiquette existante ;
- le seul `push` de `refs/tags/<nom>` ;
- l'action `checkout` épinglée par SHA.

Le job n'appelle aucun script de `tests/` ni de `R/`, ne lit pas `tests/reference/` et ne publie aucun artefact.

### 4. Auteur déclaré et acteur réel

L'étiquette porte le tagger `Claude <noreply@anthropic.com>` : c'est la configuration du job, non une identification. L'acteur réel est le jeton `GITHUB_TOKEN` de l'exécution. La responsabilité de l'acte est celle du mainteneur, qui fusionne la PR d'étiquette. La trace de l'acte comprend trois pièces : le commit de fusion de la PR d'étiquette, l'exécution du workflow (numéro au § 6), et l'objet étiquette.

### 5. `contents: write` et principe 2 de l'ADR 0010

Le principe 2 de l'ADR 0010 vise les **workflows d'agents** de `.claude/workflows/` : des séquences d'agents lancées par le mainteneur dans une session, qui laissent un arbre de travail et des rapports. Il ne vise pas GitHub Actions. Le présent ADR le précise et borne l'exception côté GitHub Actions :
- `etiquettes.yml` est le **seul** workflow du dépôt en `contents: write` ;
- il n'écrit que des étiquettes ; il ne pousse aucune branche, ne commite pas, ne touche ni `tests/reference/` ni aucune issue ;
- les autres workflows du dépôt restent en `contents: read`. Accorder un droit d'écriture à un autre workflow demande un ADR, ou une annotation du présent ADR.

`references.yml` produit les références comme artefact. Un commit de la session les fait entrer (ADR 0011) : la règle est inchangée.

### 6. Décisions antérieures annotées

- **Q-54-4 (a)** (08/11/2026) : « posée par le mainteneur, ou par la session sur son ordre exprès » se lit désormais ainsi : posée par le workflow à la fusion, par le mainteneur, d'une PR d'étiquette (§ 1) ; à défaut, voie de repli (§ 2).
- **Q-67-2 (a)** (18/11/2026) : inchangée sur le nom (`v<Version>`), la nature (annotée) et la cible (commit de fusion du jalon). Le `git tag -a` en local devient la voie de repli.

### 7. Effet sur les jalons suivants

- **JS3** (et tout jalon court, Q-75-5 (a)) : l'étape d'étiquette de la fiche suit le § 1. La fiche nomme la voie de repli (§ 2), ce qu'aurait dû faire l'étape 12 de JS2 (§ 6 de la feuille de route, bilan de JS2, leçon (ii)).
- La faisabilité de l'acte se vérifie à l'ouverture du jalon : workflow présent sur `main` et dernière exécution `success`.
- Le gel d'un jalon ne couvre pas `.github/etiquettes/` : la PR d'étiquette vient après la fusion et ne touche ni `R/`, ni `app.R`, ni `DESCRIPTION`, ni `tests/`.

## Options écartées

- **Note seule** (§ 4 de la feuille de route, ou annotation de l'ADR 0007) : aucune décision existante ne porte la procédure d'étiquette hors des fiches de jalon. Un droit d'écriture accordé à la CI doit se trouver dans `docs/adr/` (Q-75-2, option (b)).
- **Retirer le workflow** (`v3.1.0` restant en place) : JS3 dépendrait de nouveau du poste ou du `git tag` du mainteneur, la session cloud ne pouvant pas pousser d'étiquette (#621). Gardé comme retour arrière possible (« Conséquences »).
- **Garder le workflow sans trace** : contraire à la traçabilité exigée pour le dossier.
- **Déclenchement manuel (`workflow_dispatch`)** avec nom et cible en paramètres : le message ne serait ni relu en PR ni versionné. Le déclencheur par fusion lie l'acte au geste du mainteneur.
- **Étiquette posée sur la tête de la PR d'étiquette** : elle désignerait un état qui contient le fichier de message, non le jalon. La cible reste le commit de fusion du jalon (Q-67-2 (a)).
- **Jeton personnel** au lieu du `GITHUB_TOKEN` : un secret de plus à garder et un acteur nommé à la place du mainteneur ; sans gain.

## Conséquences

- **Feuille de route** : les fiches de jalon (JS3, jalon court éventuel après A3) écrivent leur étape d'étiquette selon le § 1, avec la voie de repli du § 2.
- **`CLAUDE.md`** : aucune modification par le présent ADR. *Proposition*, sur instruction du mainteneur seulement (Q-75-8) : une ligne sous « Git et GitHub », commit `claude:`, par exemple : « **Étiquette de jalon** : fichier `.github/etiquettes/v<Version>.txt` par une PR courte (`repo:`) après la fusion du jalon, posée par le workflow `etiquettes.yml` à la fusion (ADR 0021) ; une session cloud ne pousse jamais d'étiquette. »
- **Sécurité** : le droit `contents: write` du jeton couvre aussi les branches. La borne tient au code du workflow et à sa relecture en PR, non à la permission elle-même. La protection de `main` côté GitHub n'est pas lue ici (*non vérifié*).
- **Retour arrière** : sur décision du mainteneur, retrait de `etiquettes.yml` par une PR courte. Les étiquettes posées et les fichiers de message restent. Le présent ADR passe alors `superseded`, ou reçoit une annotation datée, et Q-54-4 (a) reprend sa lecture d'origine.

## Renvois

- Issue #621 ; PR #622 (`94f5220`, fusion `c105f62`) ; exécution 45710044766 ; étiquette `v3.1.0` (objet `5f1605d`).
- `docs/feuille-de-route.md` : § 4, E-08/11 (54e point) (Q-54-4), E-18/11 (Q-67) (Q-67-2, Q-67-8), E-25/11 (JS2, 11-12), E-25/11 (Q-75) ; § 5, soixante-quinzième point (Q-75-2, Q-75-7, Q-75-8) ; § 6, lignes #619 et #622, bilan de JS2.
- ADR 0006 (critère de la batterie), ADR 0007 (points 3 et 6), ADR 0010 (principe 2), ADR 0011 (références par la CI), ADR 0018 (§ 5.1, issue urgente).

## Acceptation

**Accepté** par le mainteneur le 25/11/2026, tel que proposé, sans amendement (**Q-75-7 (a)**, `docs/feuille-de-route.md`, § 4, E-25/11 (Q-75, suite) ; consigné par l'agent architect (IA), routine, étape 1 du créneau A3, sur `claude/creneau-a3`). Le statut `accepted` est porté par un commit `docs:` d'A3, hors du circuit de #620. L'étape d'étiquette du jalon court éventuel après A3 et celle de JS3 suivent les § 1 et 2.

**Q-75-8 (a)** : la ligne de `CLAUDE.md` proposée sous « Conséquences » est décidée, sous « Git et GitHub » ; posée par la session principale par le commit `claude:` `9fd81f5` d'A3.

## Annotation du 27/11/2026 — une seule étiquette, à la fin de la phase ; `v3.1.1` abandonnée

> *Rédigée par l'agent architect (IA), sur décision du mainteneur du 27/11/2026 (`docs/feuille-de-route.md`, § 4, E-27/11 (étiquettes)) ; texte proposé par l'agent et accepté tel quel par le mainteneur le 27/11 ; écrite sur la branche de travail `claude/mesures-t8` (PR brouillon #629), tête `56670bf`.*

1. Plus d'étiquette intermédiaire. La seule étiquette à venir est celle de JS3, posée une fois toutes les issues traitées, selon les § 1 et 2. Au § 7, la mention « tout jalon court (Q-75-5 (a)) » ne s'applique plus.
2. `v3.1.1` : la PR #628 est fusionnée (`9f9efc2`), mais l'exécution 45975575165 échoue. Le push de l'étiquette est refusé (workflow `ci.yml`, permission `workflows` absente ; cause à établir par #630). L'étiquette est abandonnée et n'a jamais été posée.
3. Dérogation au § 1, point 5 : le fichier d'une étiquette jamais posée puis abandonnée est retiré (`7180bd5`), faute de quoi le workflow la retenterait. Son message reste lisible à `ac205aa`. Une étiquette posée garde son fichier, inchangé.
4. La procédure de l'étiquette finale, et toute vérification préalable sur `.github/workflows/`, sera écrite par une annotation faite avec #630 (S11, cinquième numéro, Q-S9-4 (a)).
