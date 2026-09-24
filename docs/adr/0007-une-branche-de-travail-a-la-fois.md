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

Depuis la bascule des références sur la CI (ADR 0011, `1fab10b`), une régénération ordinaire calcule sur la tête de la référence déclenchée. Pour tenir le point 2 du présent ADR (un commit par issue qui change un résultat) sans commit à CI rouge sur la branche de travail, le mainteneur a décidé le 24/09/2026 (M30, amendement du même jour de l'ADR 0011) que le commit de code est d'abord poussé sur une **branche temporaire** `claude/regeneration-<issue>`, où le workflow `references.yml` calcule ; le code et les `.rds` sont ensuite commités **ensemble, en un seul commit**, sur la branche de travail, et la branche temporaire est **supprimée aussitôt**.

Cette branche est une **exception au point 1** (« une seule branche de travail à la fois »), bornée par quatre traits : aucune PR ; aucun commit propre autre que la copie du commit de code de l'issue ; jamais fusionnée ; supprimée dès que l'artefact est vérifié (ADR 0011, amendement, point 6). Elle ne rouvre ni le point 5 (les sessions cloud continuent de travailler sur la branche de travail courante ; la branche éphémère n'est pas une branche de session) ni le point 6 (rien n'est réécrit : le commit final est un commit nouveau, distinct du commit calculé). Le correctif rapide du point 3 reste la seule autre branche autorisée hors de la branche de travail. Détail de la procédure et vérification du « commit calculé » : ADR 0011, amendement du 24/09/2026 ; `docs/feuille-de-route.md`, § 4 (M30).
