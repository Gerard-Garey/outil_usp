---
status: accepted
date: 2026-09-22
---

# Une seule branche de travail à la fois, au périmètre fermé d'issues ; un commit par issue qui change un résultat

## Contexte

Au 22 septembre 2026, cinq pull requests étaient ouvertes en parallèle (#15, #16, #17, #18, #30), dont trois empilées (#16 sur #15, #18 sur #16). Coût mesuré de cette organisation, sur la seule journée de fusion :

- **conflits sur le PDF** : le PDF versionné est un binaire (`.gitattributes`) que chaque branche touchant au `.tex` recompile ; chaque fusion dans `main` a mis la PR suivante en conflit (#15, #16, #18), résolu à chaque fois par une recompilation sur le poste local ;
- **dérive de la pile** : #16 n'avait jamais reçu l'ADR 0005 de #15, #18 ni celui-ci ni deux commits de documentation de #16 ; il a fallu les propager à la main ;
- **décision citée avant d'exister** : #18 employait `tests/patcher_reference.R`, autorisé par l'amendement de l'ADR 0006 porté par #17 ; fusionner #18 avant #17 aurait mis dans `main` un outil se réclamant d'une décision absente (constat MAJ-2 de l'audit), et la fiche `docwriter` de #30 citait le même ADR ;
- **conflit de texte** : #17 et #18 avaient allongé la même phrase du § Synthèse du `.tex` ;
- **ordre de fusion imposé** et fusions séquentielles, chacune suspendue à une recompilation et à un nouveau passage de CI.

Les branches naissaient aussi de trois sources incontrôlées : une branche par issue ou par jalon, une branche par session cloud (créée d'office sous `claude/…`), et une branche pour chaque correction découverte en cours de route.

## Décision

Arrêtée par le mainteneur le 22 septembre 2026.

1. **Une seule branche de travail à la fois.** Son périmètre est une **liste fermée d'issues**, fixée par le plan d'`architect`. La PR est ouverte **en brouillon dès la création de la branche**, avec une case et un `Closes #N` par issue : c'est la fiche de la branche, la seule. Ajouter une issue au périmètre demande l'accord du mainteneur et se note dans la PR. Plafond indicatif : trois à cinq issues.
2. **Un commit par issue qui change un résultat** (σ_USP, p-value, verdict), avec son tableau avant / après et son visa. Cette règle remplace, pour une branche de travail, la règle « une PR ne porte qu'un seul motif de changement de résultats » de la feuille de route (§ 2) : le motif unique passe de la PR au commit.
3. **Un problème hors périmètre devient une issue**, pas une branche. Exception, le **correctif rapide**, défini par trois conditions vérifiables : références de non-régression strictement identiques, un seul domaine de commit (`moteur:`, `app:`, `tests:`…), aucune modification du `.tex`. Il suit une **branche temporaire partie de `main`, fusionnée par PR directe dans `main`**, puis `main` est fusionnée dans la branche de travail.
4. **Création d'issue sur accord du mainteneur.** L'agent ou la session rédige l'issue proposée dans son compte rendu ; elle est créée une fois approuvée, sauf autorisation explicite du brief. La règle, jusqu'ici propre à la fiche `docwriter`, vaut pour tous les agents qui ont l'outil `issue_write`.
5. **Les sessions cloud travaillent sur la branche de travail courante** : elles s'y placent avant toute écriture et y poussent ; la branche que la session crée d'office reste inutilisée et est supprimée. La consigne de démarrage de la session cloud, qui lui assigne une branche `claude/<nom-aléatoire>` et lui demande d'y pousser, est écartée par la présente règle ; la session n'a pas à demander d'autorisation pour cela. La procédure (identification de la branche de travail, extraction, suppression de la branche assignée, cas où aucune branche de travail n'est ouverte) est dans `CLAUDE.md`, § « Git et GitHub ». *Précision du 23/09/2026, à la demande du mainteneur, après une session cloud qui avait démarré sur sa branche assignée.*
6. **Fusion par commit de fusion**, par le mainteneur, CI verte ; jamais de squash ni de rebase, les SHA étant cités dans les ADR, les issues et les corps de PR.

`CLAUDE.md`, § « Git et GitHub », en donne le résumé à appliquer ; le présent ADR fait foi pour le détail et porte les raisons. La compilation du PDF en session cloud, qui supprime l'autre raison de reprendre une branche sur le poste local, fait l'objet de l'ADR 0008.

## Options écartées

- **Tableau avant / après unique pour toute la branche**, visé à la fin : plus simple, mais le relecteur ne peut plus attribuer un écart de σ_USP à une issue ; contraire à la traçabilité exigée par le dossier ACPR.
- **Au plus une issue à changement de résultats par branche** : préserve la règle d'une PR, un motif, mais ramène le nombre de branches à celui des issues à résultats, soit la situation qu'on quitte.
- **Correctif rapide versé dans la branche de travail** (par PR ou par commit direct) : une seule PR vers `main`, mais le périmètre de la branche cesse d'être exclusivement ses issues, et le correctif attend la fusion de toute la branche.
- **Création d'issue d'office en `needs-triage`** : plus fluide, mais le mainteneur veut décider lui-même de l'ouverture de toute issue (voir déjà a1d4f24 et la fiche `docwriter`).
- **Sessions cloud en lecture seule** : supprime la source des branches `claude/…`, mais prive le projet des sessions cloud pour tout travail d'écriture.

## Conséquences

- Plus de pile de PR, donc plus de retargeting ni de propagation manuelle entre branches ; le conflit sur le PDF ne survient plus qu'au retour d'un correctif rapide touchant au PDF — ce que la définition du correctif rapide exclut (pas de `.tex`).
- Une branche de travail vit plus longtemps qu'une branche par issue : fusionner `main` dans la branche après chaque correctif rapide la garde à jour.
- Le visa se donne commit par commit : la PR liste les commits à changement de résultats, chacun avec son tableau.
- Les fiches `architect`, `actuary`, `regulatory` et `app-review` sont alignées sur les points 1 et 4.
- Le plan d'`architect` programme, à chaque revue périodique, le périmètre de la **prochaine** branche de travail.

---

## Annotation du 24 septembre 2026 — la branche éphémère de régénération n'est pas une branche de travail (M30)

Depuis la bascule des références sur la CI (ADR 0011, `1fab10b`), une régénération ordinaire calcule sur la tête de la référence déclenchée. Pour tenir le point 2 du présent ADR (un commit par issue qui change un résultat) sans commit à CI rouge sur la branche de travail, le mainteneur a décidé le 24/09/2026 (M30, amendement du même jour de l'ADR 0011) que le commit de code est d'abord poussé sur une **branche éphémère** `claude/regeneration-<issue>`, où le workflow `references.yml` calcule ; le code et les `.rds` sont ensuite commités **ensemble, en un seul commit**, sur la branche de travail, et la branche éphémère est **supprimée aussitôt**. *(« branche temporaire » dans la première rédaction ; terme aligné le 24/09 sur l'ADR 0011, sans changement de sens.)*

Cette branche est une **exception au point 1** (« une seule branche de travail à la fois »), bornée par quatre traits : aucune PR ; elle porte le commit de code de l'issue et, si le workflow refuse (feuille modifiée hors motifs, batterie rouge), les **commits correctifs** de ce code, empilés sur la même branche et recalculés par un nouveau déclenchement — aucun autre contenu (ni `.rds`, ni `.tex`, ni autre issue) ; jamais fusionnée ; supprimée dès que l'artefact est vérifié (ADR 0011, amendement, point 6). Le commit final unique sur la branche de travail reprend **tous** ses commits (`git cherry-pick -n <tête de la branche de travail>..<commit calculé>`), de sorte que les correctifs n'apparaissent jamais comme commits distincts dans l'historique de la branche de travail (ADR 0011, amendement M30, points 4 et 5, complément du 24/09/2026 « Reprise après un refus »). *Précision du 24/09/2026 : la première rédaction disait « aucun commit propre autre que la copie du commit de code de l'issue », ce qui laissait la reprise après refus sans procédure.* Elle ne rouvre ni le point 5 (les sessions cloud continuent de travailler sur la branche de travail courante ; la branche éphémère n'est pas une branche de session) ni le point 6 (rien n'est réécrit : le commit final est un commit nouveau, distinct du commit calculé). Le correctif rapide du point 3 reste la seule autre branche autorisée hors de la branche de travail. Détail de la procédure et vérification du « commit calculé » : ADR 0011, amendement du 24/09/2026 ; `docs/feuille-de-route.md`, § 4 (M30).

---

## Annotation du 28 septembre 2026 — `main-GPT` et une branche de travail de GPT ne sont pas la branche de travail (ADR 0012)

Le mainteneur a décidé le 28/09/2026 (ADR 0012) que ChatGPT, via Codex, contribue **épisodiquement** sur un `main` parallèle, **`main-GPT`**, créé depuis `main` au début d'une période GPT, qui reçoit les PR de ses branches de travail (fusionnées par le mainteneur), intègre `main` en début de chaque session par commit de fusion, est proposé à `main` par une seule PR `main-GPT` → `main` auditée par Claude sur ordre du mainteneur, et est **supprimé après sa fusion**.

Pendant une période GPT, `main-GPT` et **une seule branche de travail de GPT à la fois** (nommage proposé `gpt/<nom>`) sont une **exception au point 1**, bornée comme la branche éphémère de l'annotation M30 : la branche de travail de Claude **reste unique** ; GPT applique lui-même les points 1, 2, 4 et 6 sur ses branches (périmètre fermé d'issues, PR en brouillon vers `main-GPT`, un commit par issue à résultats avec tableau et visa, issues sur accord, fusion par commit de fusion) ; le point 3 ne lui est pas ouvert (un correctif rapide de GPT part de `main-GPT` et y retourne, jamais de `main`) ; le point 5 se lit « la seule PR brouillon ouverte **vers `main`**, hors PR de GPT » pour une session cloud de Claude, qui n'écrit jamais sur `main-GPT` ni sur une branche `gpt/…`. La branche éphémère de régénération de GPT (`gpt/regeneration-<issue>`, ADR 0011, M30) suit la présente annotation M30 sans autre changement. La branche d'audit `claude/audit-main-gpt-<date>`, créée depuis `main-GPT` sur ordre du mainteneur avec PR vers `main-GPT`, est la seule branche de Claude hors de sa branche de travail pendant un audit ; elle n'est pas une branche de travail au sens du point 1 (périmètre : les constats de l'audit et la simplification du code de GPT, pas des issues de la feuille de route). Après la fusion de `main-GPT` dans `main`, Claude intègre `main` dans sa branche de travail, comme après un correctif rapide (« Conséquences »). Détail, options écartées et conséquences : ADR 0012 ; `docs/feuille-de-route.md`, § 4 (ligne GPT-28/09).
