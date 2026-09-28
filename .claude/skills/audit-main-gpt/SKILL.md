---
name: audit-main-gpt
description: Auditer la branche main-GPT de ChatGPT (Codex) avant sa fusion dans main - diff, issues déclarées résolues et créées, agents experts, simplification et optimisation du code, validation de la PR main-GPT vers main. Uniquement sur commande explicite du mainteneur, jamais de la propre initiative d'une session, d'un agent ou d'un hook.
---

# Auditer `main-GPT`

ChatGPT (Codex) travaille épisodiquement sur `main-GPT`, son `main` parallèle (`AGENTS.md`, ADR 0012). Avant toute fusion dans `main`, Claude audite ce que GPT a introduit, le corrige, le simplifie et l'optimise, puis valide la PR `main-GPT` → `main`. **Lancement par le mainteneur seul.** La fusion, vers `main-GPT` comme vers `main`, reste au mainteneur.

## Étapes

1. **État des lieux** (session principale, lecture seule) :
   - `git fetch origin main main-GPT` ; relever les SHA de `main` et de `main-GPT`, et le numéro de la PR `main-GPT` → `main`.
   - `main-GPT` doit contenir `main` (`git merge-base --is-ancestor origin/main origin/main-GPT`) ; sinon demander au mainteneur de faire intégrer `main` par GPT, ou l'intégrer sur la branche d'audit (point 3) par un commit de fusion.
   - Lire le corps de la PR : **issues déclarées résolues** (`Closes #N`, un par ligne), **issues créées** ; les confronter aux issues de libellé `gpt` et aux commits (`git log origin/main..origin/main-GPT`, auteur `Codex <noreply@openai.com>`). Tout écart entre la liste et les faits est un constat.
   - Diff : `git diff origin/main...origin/main-GPT` ; classer les fichiers touchés par domaine (`R/engine.R`, `app.R` / `R/display_helpers.R`, `tests/`, `docs/latex/`, `tests/reference/`, autres).

2. **Plan d'audit par `architect`** : lui transmettre la liste des issues, le diff par domaine et les commits à changement de résultats ; il dit quels agents interviennent, dans quel ordre, et si le travail de GPT est cohérent avec la feuille de route, les ADR et `CONTEXT.md`.

3. **Branche d'audit** : `git switch -c claude/audit-main-gpt-<AAAAMMJJ> origin/main-GPT`, PR vers `main-GPT` ouverte en brouillon (corps : « Audit de la PR #N »). Toutes les modifications de Claude y sont commitées, un commit par constat ou par issue, messages selon `CLAUDE.md`.

4. **Vérification par issue déclarée résolue** : l'issue est-elle résolue, et seulement elle ? Déclencheurs de `CLAUDE.md` (« Sous-agents ») :
   - méthode ou test statistique → **`actuary`** (pertinence à T = 8, fidélité à la spécification de l'issue) ;
   - formule, paramètre ou barème du règlement → **`regulatory`** ;
   - `R/engine.R` → **`audit`** (revue complète des fonctions touchées, appelants et appelés, batteries, scénarios adverses) ;
   - `app.R` ou `R/display_helpers.R` → **`app-review`** ;
   - `docs/latex/` → **`docwriter`** en dernier (règle 9), après le dernier commit de code de la branche d'audit.

   Pour chaque issue créée par GPT : pertinence, doublon, libellés, rattachement (avis d'`architect`).

5. **Simplification et optimisation** (point essentiel) : `coder`, sur les constats d'`audit` et sur la lecture du diff par la session (code dupliqué, fonctions à fusionner avec l'existant, branches mortes, calculs refaits hors du moteur, complexité inutile, lenteurs mesurables). Aucune simplification ne change un résultat hors du circuit de la skill `verifier-reproductibilite` ; références identiques attendues, sinon tableau avant / après et visa. Chaque reprise de `coder` est revue par `audit` sur son diff.

6. **Batteries** sous `LC_ALL=C.UTF-8` sur la tête de la branche d'audit : `tests/test_unitaires.R`, `tests/test_reproductibilite.R`, `tests/concordance_doc_moteur.R --strict` ; `tests/comparer_references.R --deux-parts` si `tests/reference/` a changé (références produites par la CI seulement, ADR 0011).

7. **Validation de fond** : `actuary` valide le diff final (GPT et Claude confondus) si une méthode ou un test a changé ; `regulatory` si une formule réglementaire a changé. Revue finale de la règle 10 et `/code-review` sur `git diff origin/main...HEAD` de la branche d'audit.

8. **Rapport au mainteneur**, en commentaire de la PR `main-GPT` → `main` :
   - tableau des issues déclarées résolues : résolue / partiellement / non, avec la preuve ;
   - issues créées par GPT : pertinence, rattachement proposé ;
   - constats par gravité (`fichier:ligne`, mesure), corrections faites (commits de la branche d'audit), simplifications et gains mesurés ;
   - changements de résultats (tableaux avant / après, visas requis) ;
   - verdict : **validée** (après fusion de la PR d'audit dans `main-GPT`) ou **refusée** avec les points bloquants.

9. **Après la fusion de `main-GPT` dans `main`** par le mainteneur : vérifier la fermeture de chaque issue annoncée ; `main-GPT` est supprimée (par le mainteneur si le proxy de la session l'empêche) ; la feuille de route est mise à jour par `architect`.

## Ce que l'audit ne fait pas

- Pas de fusion, pas d'auto-merge, pas de push sur `main` ni sur `main-GPT` en dehors de la PR d'audit.
- Pas de régénération ni de patch de `tests/reference/` hors de la procédure `verifier-reproductibilite`.
- Pas de création d'issue sans accord du mainteneur.
