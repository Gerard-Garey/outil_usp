> *Rédigé par l'agent architect (IA), fiche `architect-approfondi`, étape 1a de la branche K5 (#515), le 09/11/2026. Base : `CLAUDE.md` à la tête `d5cdb51`. Décisions appliquées : Q-56-3 (a), Q-56-4 (a) avec les corrections Fable n° 1 à 5, Q-56-12 (a).*

# Structure cible des instructions de Claude (#515, étape 1a)

Trois lieux, selon le moment où une règle sert (ADR 0017, proposé) :

1. **socle** : `CLAUDE.md`, chargé au lancement par la session et par chaque sous-agent personnalisé ;
2. **règle à chemins** : `.claude/rules/moteur.md`, chargée quand un fichier qui correspond à son champ `paths:` est lu, écrit ou modifié ;
3. **documents à la demande** : skills (chargées par leur description ou à l'appel) et documents de `docs/agents/` et `docs/adr/`, que le socle nomme.

Volumes en octets (`wc -c`), comme dans l'issue #515.

## 1. Plan du nouveau `CLAUDE.md`

Les titres actuels sont tous gardés, avec leur niveau : ils sont cités par `AGENTS.md` l. 15, par les fiches d'agents, par `.github/` et par le workflow. Les intitulés en gras des paragraphes de « Sous-agents » sont gardés en tête de ligne (« Déclencheurs », « Routage du modèle et de l'effort », « Modèle et effort des agents de réalisation et de vérification », « Circuits types », « Workflows », « Règle 9 », « Règle 10 », « Revues périodiques », « Approbation des changements de résultats »). Les procédures de retour arrière qui les nomment restent donc exécutables sans réécriture (ADR 0017, correspondance).

Une idée par ligne, en puces ; aucun historique (dates, PR, incidents), sauf l'identifiant d'une décision quand il sert à retrouver sa source (Q-45-12, Q-43-13, Q-54-10, M32, M37).

| Section | Contenu (une phrase) | Octets à `d5cdb51` | Octets visés (projet, annexe A) |
|---|---|---:|---:|
| `# CLAUDE.md` | Phrase d'usage, puis un commentaire HTML qui renvoie à l'ADR 0017 et au tableau ; le commentaire est retiré avant injection et ne coûte rien en contexte. | 117 | 314 |
| `## Contexte` | Objet de l'outil, textes sources et version de lecture, formules en images, dépôt public, primauté de la traçabilité, `docs/exigences.md`, T = 8. | 2 371 | 1 137 |
| `## Commandes` | Renvoi au README, `LC_ALL=C.UTF-8`, hook R, échecs attendus, skills `verifier-reproductibilite` et `compiler-doc`, chargement par `charger_moteur()`. | 2 114 | 936 |
| `## Git et GitHub` | Toutes les règles que seule la consigne fait respecter : `main`, branche unique et exceptions bornées, session cloud, `Closes` et mots-clés, aucune réécriture, commits, issues, handoff, préfixes, auteur. | 8 099 | 3 940 |
| `### ChatGPT (Codex) et la branche main-GPT` | Périmètres séparés, aucune écriture sur `main-GPT` hors des actes ordonnés, audit lancé par le mainteneur seul, `main` l'emporte ; procédures dans la skill `periode-gpt`. | 4 243 | 811 |
| `## Architecture (contrainte impérative)` | Tête intégrale : rôle des quatre fichiers, aucune dépendance hors R base + stats, moteur jamais éclaté, contrôle de saisie aussi dans le moteur. | 1 880 | 1 798 |
| `### Flux du moteur` | `run_engine()`, les deux branches et leurs fonctions, données réglementaires (ne pas modifier sans source ; validité à partir de M6). | 1 663 | 905 |
| `### Structure d'un résultat de test` | Deux lignes : `add()`, hiérarchie des p-values jamais lue à l'envers ; l'affichage lit les champs ; `GROUPES` ; renvoi à la règle. | 3 785 | 433 |
| `### Reproductibilité` | Deux lignes : bit près, tolérance 1e-6, résultat changé expliqué ; aléa par `engine_sous_graine()` seulement ; aucune régénération hors CI ; renvoi à la règle. | 3 568 | 396 |
| `## Documentation LaTeX (…)` | Document unique synchronisé, `CONVENTIONS.md`, vie du dépôt hors du document, langue ; règles du PDF une fois par branche (venues de « Contexte »). | 1 090 | 1 280 |
| `## Rigueur statistique (…)` | Les cinq règles, inchangées. | 737 | 737 |
| `## Sous-agents` | Tableau et séparation ; déclencheurs ; routage résumé (cas de Fable, plafonds chiffrés, aucun remplacement silencieux) ; règle d'office de `coder-approfondi` ; circuits ; workflows (lancement, interdictions) ; règles 9 et 10 ; revues et rapports versés ; approbations ; vocabulaire. | 12 333 | 5 541 |
| `## Agent skills` (trois sous-sections) | Inchangé. | 502 | 502 |
| **Total** | 169 lignes réelles | **42 502** | **19 034** (18 838 hors commentaire) |

Le projet de l'annexe A est **indicatif** : la session le reprend à l'étape 1b et `architect-approfondi` relit le diff à l'étape 1c. La mesure qui fait foi est celle du fichier commité (`wc -l -c CLAUDE.md`).

## 2. Plan de `.claude/rules/moteur.md`

**Frontmatter** (décision Q-56-4 (a) ; ajout recommandé en question Q-R3 de la synthèse, entre crochets) :

```yaml
---
paths:
  - "R/engine.R"
  - "R/charger_moteur.R"
  - "tests/**"
  - "docs/latex/**"
  [- "R/display_helpers.R"]
---
```

Seul le champ `paths` est lu par Claude Code ; un YAML illisible fait charger la règle **en permanence**, sans erreur visible (documentation memory.md, « Rule frontmatter reference »). Le témoin négatif de l'étape 1c (§ 7) le détecte.

**Contenu** (ordre proposé ; texte repris **à l'identique** de `d5cdb51`, seulement découpé une idée par ligne) :

| Section de la règle | Origine | Octets (estimés) |
|---|---|---:|
| Phrase d'objet : « Détail des sous-sections « Structure d'un résultat de test » et « Reproductibilité » de `CLAUDE.md` (ADR 0017) ; document de fond, lu aussi par GPT (`AGENTS.md`, Q-56-12). » | nouveau | ≈ 250 |
| `## Données réglementaires` : nombre de segments et clés, `CRED_LONG` / `CRED_COURT`, vérification contre la version consolidée (▼M6, 2019/981, neuf écarts-types de 2015 non conservés) et contre le JOUE de 2015 pour les barèmes (▼B), « ne pas les modifier sans source » | `CLAUDE.md` l. 64 (FLX-4, FLX-5, FLX-7) | ≈ 800 |
| `## Structure d'un résultat de test` | l. 68, intégral (STR-1 à STR-16) | 3 785 |
| `## Reproductibilité` | l. 72, intégral (REP-1 à REP-10) | 3 568 |
| `## Références externes des tests` : `generer_valeurs_externes.R` | l. 19 (CMD-8) | ≈ 200 |
| Repère de chargement (phrase sentinelle, § 7), dernière ligne | nouveau | ≈ 80 |
| **Total** | | **≈ 8 700** |

Limite de taille d'une règle à chemins : 40 000 caractères en fenêtre de 200 000 tokens (memory.md, « Claude ignores the end of my subdirectory CLAUDE.md », depuis 2.1.309) ; la règle en fait environ le cinquième.

Les deux lignes de résumé du socle disent ce qu'il faut savoir **sans** la règle (session qui ne lit que par `Grep` ou `git diff`) : la hiérarchie des p-values, la lecture des champs par l'affichage, l'aléa par `engine_sous_graine()`, l'interdiction de régénérer hors CI.

## 3. Skill `periode-gpt` (question Q-R2)

Fichier `.claude/skills/periode-gpt/SKILL.md`, domaine `claude:` :

```yaml
---
name: periode-gpt
description: Actes de Claude pendant une période GPT, sur ordre du mainteneur seulement - ouverture de main-GPT et de la PR de période, intégration de main dans main-GPT et résolution de conflit, fermeture M30 déléguée sur claude/regeneration-gpt-<issue>. À charger avant tout acte sur main-GPT ou une branche gpt/. L'audit de main-GPT relève de la skill audit-main-gpt.
---
```

Corps : `CLAUDE.md` l. 38-43 à `d5cdb51`, repris **à l'identique** (GPT-1 à GPT-18), avec deux ajouts sans changement de règle : la phrase « réciproquement, `AGENTS.md` interdit à GPT `.claude/`… » complétée par l'exception `.claude/rules/moteur.md` (Q-56-12 (a)) ; la liste des quatre branches de période (GIT-10). Volume ≈ 3 800 octets.

Pourquoi une skill plutôt que `docs/agents/periode-gpt.md` : la skill reste sous `.claude/`, que `AGENTS.md` l. 18 interdit à GPT, ce qui garde la séparation des périmètres (`CLAUDE.md` l. 40) ; un fichier de `docs/agents/` n'est pas nommé par cette interdiction (*hypothèse* : `AGENTS.md` n'est connu ici que par les l. 15 et 18 citées par Fable). La skill se charge aussi par sa description quand une demande nomme `main-GPT`, ce qui vaut mieux qu'un renvoi qu'il faut penser à suivre.

## 4. Documents cibles et renvois du socle

| Document cible | Statut | Ce qu'il reçoit | Renvoi depuis le socle |
|---|---|---|---|
| `.claude/rules/moteur.md` | à créer (1b) | STR, REP, FLX-4/5, CMD-8 | « Détail : `.claude/rules/moteur.md` » (deux fois) |
| `.claude/skills/periode-gpt/SKILL.md` | à créer (1b) | GPT-3, GPT-5 à GPT-8, GPT-17, GIT-10 | « skill `periode-gpt` » (deux fois) |
| `.claude/skills/audit-main-gpt/SKILL.md` | existante, inchangée | GPT-11 à GPT-16 (déjà portés) | « skill `audit-main-gpt` » |
| `.claude/skills/verifier-reproductibilite/SKILL.md` | existante, inchangée | GIT-8 (procédure de la branche éphémère, déjà portée) | « skill `verifier-reproductibilite` » |
| `docs/agents/routage.md` | existant ; § 9 et § 10 amendés en 1b | SA-5, SA-13, SA-16, SA-19, SA-20 (déjà portés) | « (`docs/agents/routage.md`, qui fait foi) », § 3, § 4.1, § 5.2, § 5.3, § 7, § 10 |
| ADR 0007 et annotations | existant ; inchangé | historique GIT (déjà porté) ; GIT-5, GIT-7, GIT-9 (détail déjà porté) | « (ADR 0007) » |
| ADR 0010 (et ADR 0015, point 8) | existant ; annotation en 1b | SA-28, SA-31 à SA-36 (déjà portés) | « huit principes de l'ADR 0010 » |
| `.claude/hooks/preparer_r.sh` | existant ; inchangé | CMD-4 (déjà porté, l. 25-29) | « (détail en en-tête) » |
| ADR 0017 | proposé (1a) | correspondance des paragraphes nommés ; mentions historiques sans autre support (annexe B) | commentaire HTML d'en-tête |

## 5. Ligne à ajouter dans `AGENTS.md` (Q-56-12 (a))

`AGENTS.md` n'a pas été ouvert (brief) ; le texte s'appuie sur les l. 15 et 18 telles que les cite l'avis Fable du 09/11 (`docs/revues/20261109-plan-k5/avis-fable.md`, M1) : l. 15, GPT lit dans `CLAUDE.md` « les seules sections de fond : « Contexte », « Architecture (contrainte impérative) » avec « Flux du moteur » et « Structure d'un résultat de test », « Reproductibilité », « Documentation LaTeX », « Rigueur statistique » […] elles s'appliquent à GPT sans changement » ; l. 18, « À ne pas lire ni appliquer : […] tout le dossier `.claude/` ».

**Emplacement proposé** : nouvelle ligne immédiatement **après la l. 18**, pour que l'exception suive l'interdiction qu'elle borne. Si la l. 18 est une puce de liste, la ligne ajoutée est une puce de même niveau ; sinon, un paragraphe d'une ligne.

**Texte proposé** :

> - Exception bornée à l'interdiction de `.claude/` : lire aussi `.claude/rules/moteur.md`, qui porte depuis le <date du commit> le détail des sections « Structure d'un résultat de test » et « Reproductibilité » de `CLAUDE.md` (et des données réglementaires de « Flux du moteur ») ; c'est un document de fond, qui s'applique à GPT sans changement, comme les sections de la l. 15 ; le reste de `.claude/` reste exclu (décision du mainteneur du 09/11/2026, Q-56-12).

Contrôle avant commit (session) : `git diff --stat AGENTS.md` = une ligne ajoutée, aucune supprimée (critère de l'étape 1, fiche K5).

## 6. Renvois à mettre à jour à l'étape 1b

Commit `claude:` (session) : `CLAUDE.md`, `.claude/rules/moteur.md`, `.claude/skills/periode-gpt/SKILL.md`, fiches, `AGENTS.md`. Commit `docs:` (session) : `docs/agents/routage.md`, annotations d'ADR. Les citations historiques (listes de « Conséquences » ou « Documents à aligner » des ADR 0006, 0010 l. 76, 0011 l. 69 et 201, 0013 l. 44) ne se modifient pas : elles décrivent un état passé, et l'ADR 0017 en donne la correspondance.

| Fichier : ligne (à `d5cdb51`) | Texte actuel (extrait) | Modification proposée | Commit |
|---|---|---|---|
| `docs/agents/routage.md` l. 162 (§ 9) | « `CLAUDE.md`, « Sous-agents » \| renvoi à ce fichier ; règles qui priment (§ 5.5, rang 1) ; liste du § 4.1, plafonds du § 5.2 et règles du § 10, recopiés : à tenir identiques » | « `CLAUDE.md`, « Sous-agents » \| résumé et renvoi à ce fichier, qui fait foi ; règles qui priment (§ 5.5, rang 1) écrites en clair ; cas du § 4.1 et plafonds du § 5.2 rappelés en une ligne chacun, règles du § 10 résumées à la règle d'office : en cas d'écart, ce fichier l'emporte (ADR 0017) » | `docs:` |
| `docs/agents/routage.md` l. 189 (§ 10, retour arrière) | « dans `CLAUDE.md`, retirer le paragraphe « Modèle et effort des agents de réalisation et de vérification », remettre `coder` dans les circuits 1 et 2 (« Circuits types »), rétablir le principe 8 et le décompte des fiches » | « dans `CLAUDE.md`, « Sous-agents », retirer la ligne « Modèle et effort des agents de réalisation et de vérification », remettre `coder` dans les circuits 1 et 2 (« Circuits types ») et rétablir le décompte des fiches ; rétablir le principe 8 dans l'ADR 0010, que `CLAUDE.md` ne recopie plus (ADR 0017) » | `docs:` |
| `docs/agents/routage.md` l. 150 (§ 8, retour arrière) | « retirer les renvois aux fiches `-approfondi` (`CLAUDE.md`, skills…) » | inchangé (le socle nomme toujours les fiches `-approfondi`) ; vérifier à 1c que la procédure reste exacte | — |
| ADR 0015, après l. 75 (Conséquences) | « Retour arrière […] : procédure du § 10 de `routage.md`, qui fait foi » | annotation datée : « *Annotation du <date> (ADR 0017) : les paragraphes de `CLAUDE.md` nommés ici et au § 10 de `routage.md` gardent leur intitulé en tête de ligne dans « Sous-agents » ; le principe 8 n'est plus recopié dans `CLAUDE.md` (ADR 0010 et point 8 du présent ADR) ; correspondance : ADR 0017.* » | `docs:` |
| ADR 0015 l. 87 (P7) | « `CLAUDE.md`, « Routage du modèle et de l'effort » : aucun remplacement silencieux » | inchangé (intitulé et règle gardés dans le socle) | — |
| ADR 0013, fin | — | annotation datée : « *Annotation du <date> (ADR 0017) : `CLAUDE.md`, « Sous-agents », ne recopie plus les listes du routage ; `docs/agents/routage.md` fait foi (§ 9 amendé).* » | `docs:` |
| ADR 0010, fin | — | annotation datée : « *Annotation du <date> (ADR 0017) : `CLAUDE.md`, « Sous-agents », « Workflows », ne résume plus que le lancement par le mainteneur, les interdictions d'écriture et la question pour `actuary` ; les huit principes, le statut des questions et l'écart de concordance sont lus ici.* » | `docs:` |
| ADR 0007 l. 267 | « `CLAUDE.md` (« 13 statistiques discrètes »), par la session principale sur instruction du mainteneur, si #304 (option (b)) ou #300 ajoute une statistique discrète » | annotation datée : « *(ADR 0017) : le décompte est désormais dans `.claude/rules/moteur.md`, à mettre à jour de la même façon.* » | `docs:` |
| `.claude/agents/audit.md` l. 11 | « Lis d'abord `CLAUDE.md` : architecture, commandes, règles de reproductibilité. » | « Lis d'abord `CLAUDE.md` (architecture, commandes) et `.claude/rules/moteur.md` (structure d'un résultat de test, reproductibilité) : tu lis le code par `git diff` et `Grep`, qui ne chargent pas cette règle. » | `claude:` |
| `.claude/agents/coder.md` l. 11 | « Lis d'abord `CLAUDE.md` : il décrit l'architecture, les commandes et les règles de reproductibilité. » | « Lis d'abord `CLAUDE.md` (architecture, commandes) et, pour toute tâche sur le moteur ou les tests, `.claude/rules/moteur.md` (structure d'un résultat de test, reproductibilité). » ; puis `bash .claude/outils/fiches_jumelles.sh` (régénère `coder-approfondi.md`) | `claude:` |
| `.claude/agents/actuary.md` l. 12 | « `CLAUDE.md` est déjà dans ton contexte ; lis dans `docs/exigences.md` les sections qui touchent la question » | ajouter : « et `.claude/rules/moteur.md` quand la question touche un résultat de test, une p-value ou l'aléa » ; régénérer `actuary-approfondi.md` | `claude:` |
| `.claude/agents/docwriter.md` l. 11 | « Lis d'abord `CLAUDE.md`, `CONTEXT.md` (vocabulaire imposé) et `docs/exigences.md` § 2-3 » | ajouter `.claude/rules/moteur.md` après `CLAUDE.md` (la règle se charge aussi à la lecture du `.tex`, `docs/latex/**`, mais `docwriter` part de la surface d'impact) | `claude:` |
| `.claude/agents/regulatory.md` l. 11 (question Q-R4) | « Lis d'abord `CLAUDE.md` et `CONTEXT.md`. » | « Lis d'abord `CLAUDE.md`, `CONTEXT.md` et, pour les données réglementaires du moteur, `.claude/rules/moteur.md`. » | `claude:` |
| `.github/scripts/controle_mots_cles_fermeture.sh` l. 3 et 133 ; `.github/workflows/mots-cles-fermeture.yml` l. 3 ; `.github/dependabot.yml` l. 3 | « Git et GitHub » | inchangés (titre gardé) | — |
| `.github/pull_request_template.md` l. 20 | « Sous-agents » | inchangé (titre gardé) | — |
| `.claude/workflows/circuit-technique.js` l. 3, 17, 361, 362, 377 | « Circuit 3 de CLAUDE.md », « ta fiche et CLAUDE.md », « message au format de CLAUDE.md » | inchangés (« circuit 3 » et règles de commit gardés ; `coder` charge la règle en lisant `R/engine.R` et par sa fiche) | — |
| `.claude/outils/fiches_jumelles.sh` l. 39 | « circuits 1 et 2 de `CLAUDE.md` » | inchangé | — |
| Fiches `architect`, `actuary`, `app-review`, `regulatory` (« Git et GitHub ») ; `regulatory.md` l. 15 (« Contexte ») ; `architect.md` l. 36 (« Sous-agents ») | titres | inchangés (titres gardés ; « Contexte » garde les deux textes sources) | — |
| `README.md` l. 209, 227, 231, 236 | « règles de `CLAUDE.md` priment », « règle 9 », auteur | inchangés | — |

## 7. Protocole de mesure de l'étape 1c

Objet : vérifier, par une observation et non par la seule documentation, (a) que la règle se charge quand un sous-agent lit un fichier correspondant, (b) qu'elle ne se charge pas sans cela (frontmatter lu, gain de volume réel), (c) ce que voit un agent qui ne lit que par `git diff`.

**Phrase sentinelle**, dernière ligne de `.claude/rules/moteur.md`, en texte visible (pas en commentaire HTML, qui pourrait être retiré avant injection) :

> Repère de chargement de cette règle : <jeton>.

où `<jeton>` est une chaîne arbitraire choisie par la session à l'étape 1b, écrite **uniquement** dans la règle (contrôle : `git grep -l '<jeton>'` ne rend que `.claude/rules/moteur.md`) ; le présent document ne la donne pas, pour qu'aucun agent ne puisse la trouver ailleurs que dans ses instructions.

**Conditions** : session **neuve** après le push de 1b (fiches rechargées, `docs/agents/routage.md` § 2) ; aucun agent ne lit `.claude/rules/` ni `docs/revues/20261109-revue-claude-md/` ; chaque agent répond sans écrire ; modèle servi relevé par `bash .claude/outils/bilan_journal.sh`.

| Essai | Agent (fiche) | Consigne (résumé) | Attendu | Si l'attendu manque |
|---|---|---|---|---|
| E1 (positif) | `coder` | « Lis `R/engine.R` lignes 1 à 40 avec l'outil Read, et aucun autre fichier. Puis, si tes instructions contiennent une ligne qui commence par « Repère de chargement », recopie-la mot pour mot ; sinon réponds « absent ». N'écris rien. » | ligne recopiée | règle non chargée par un sous-agent : elle reste dans le socle (Fable n° 5) ; arrêt et compte rendu au mainteneur |
| E2 (négatif) | `coder` | même consigne, avec `app.R` lignes 1 à 40 au lieu de `R/engine.R` (ou `README.md` si Q-R3 ajoute un chemin qui couvre `app.R`) | « absent » | règle chargée en permanence (frontmatter illisible) : corriger le frontmatter ; sans correction, le gain de volume est nul |
| E3 (lecture par diff) | `audit` | « Exécute `git diff main...HEAD --stat` et `git log -1 --format=%H`, sans lire aucun fichier par Read, `cat` ou `head`. Puis même question. » | « absent » (attendu de la documentation : `git diff` ne déclenche pas la règle) | « présent » : noter le constat (chargement plus large que documenté) ; la consigne des fiches reste utile |
| E4 (fiche amendée) | `audit` | « Applique la première consigne de ta fiche qui nomme un fichier à lire, puis même question. » | ligne recopiée (la fiche fait lire la règle) | fiche non rechargée (attendre, 15 minutes au plus) ou consigne de fiche inefficace : arrêt et compte rendu |
| E5 (session) | session principale | après `Read` de `R/engine.R`, la session cite la ligne sentinelle de ses instructions | ligne citée | idem E1 |

Trace : une ligne par essai dans la PR #516 (`agent / modèle servi / essai / réponse / suite`). Critère de l'étape : E1, E2, E4 et E5 conformes ; E3 consigné tel qu'observé.

**`/doctor prompt-audit`** : commande interactive (Claude Code ≥ 2.1.283 ; version de la session cloud du 09/11 : 2.1.319, `claude --version`, *vérifié*), à lancer **par le mainteneur** sur l'état `d5cdb51` avant 1b, puis après 1b ; elle couvre `CLAUDE.md`, `AGENTS.md`, `.claude/rules/`, les skills et les fiches. Les deux rapports sont versés dans `docs/revues/20261109-revue-claude-md/`. Si le mainteneur ne peut pas la lancer, le critère est consigné « non mesuré » (question Q-R7).

**Volume** : `wc -l -c CLAUDE.md` et `LC_ALL=C.UTF-8 wc -m CLAUDE.md` sur le fichier commité ; `wc -c .claude/rules/moteur.md` ; résultat comparé au § 1 et noté dans la PR.

## Annexe A — Projet de socle (indicatif, 169 lignes, 19 034 octets)

Projet rédigé pour mesurer le volume atteignable sous les contraintes décidées ; la session le reprend librement à l'étape 1b, sans y perdre une règle du tableau.

````markdown
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

<!-- Organisation des instructions : ADR 0017 (socle, règle à chemins, documents à la demande). Correspondance avec l'ancien texte : docs/revues/20261109-revue-claude-md/tableau-regles.md. -->

## Contexte

- Outil de calibrage des paramètres propres à l'entreprise (USP), Solvabilité II : règlement délégué (UE) 2015/35, art. 218-220 et annexe XVII.
- Textes sources à la racine : `Règlement délégué.pdf` (JOUE L 12 du 17.1.2015) et `TEXTE consolidé_ 32015R0035 — FR — 14.11.2024.xhtml`.
- **La version consolidée est la référence de lecture** (sans effet juridique propre : font foi les versions du JOUE) ; sa MSEP de l'annexe XVII D(5) diffère de 2015 (ADR 0005).
- Les formules sont des images : les lire en rendu graphique, jamais par extraction de texte (#7). Données `usp_*.csv/.xlsx` non versionnées.
- Dépôt de référence public `https://github.com/Gerard-Garey/outil_usp`, employé en local et en session cloud.
- Livrables destinés à un dossier soumis à l'ACPR : la traçabilité documentation LaTeX ↔ code R ↔ résultats prime sur tout le reste.
- `docs/exigences.md` est le cahier des charges : le lire avant toute évolution méthodologique ou de l'interface.
- Taille d'échantillon d'intérêt : **T = 8**. Toute conclusion statistique en tient compte (« Rigueur statistique »).

## Commandes

- Commandes, prérequis et structure : `README.md` (« Prérequis », « Structure », « Usage de l'application », « Usage sans Shiny », « Reproductibilité et tests »).
- En session Linux, lancer les batteries sous `LC_ALL=C.UTF-8` (sous POSIX, faux échec de la concordance, #113).
- Le hook `SessionStart` (`.claude/hooks/preparer_r.sh`, détail en en-tête) rend `Rscript` disponible ; s'il signale un échec, aucune commande R ne peut tourner.
- Défaut connu : échec attendu (`echec_attendu()`, renvoi à l'issue) ; un succès inattendu fait échouer la batterie : retirer alors la marque.
- Après une modification du moteur, ou des tests en échec : skill **`verifier-reproductibilite`**. Après une modification du `.tex` : skill **`compiler-doc`**.
- Point isolé : `source("R/charger_moteur.R"); charger_moteur()` puis appel direct (ADR 0016) ; `source("R/engine.R")` jamais pour un chiffre du dossier.

## Git et GitHub

- **Aucun push direct sur `main`** : branche et pull request, fusion par le mainteneur (commit de fusion, jamais squash ni rebase), CI verte ; exception : instruction explicite du mainteneur pour un push donné.
- **Une seule branche de travail à la fois** (ADR 0007) : périmètre fermé d'issues fixé par le plan d'`architect`, PR ouverte en brouillon dès la création ; toute session s'y place et y pousse.
- Aucune session, aucun agent ni aucun workflow ne crée de sa propre initiative une autre branche ou PR ; branche de travail parallèle : nouvelle exception à l'initiative du mainteneur seulement.
- Exceptions bornées, sans PR ni fusion : `claude/regeneration-<issue>` (skill `verifier-reproductibilite`), `claude/sauvegarde-<issue>` (décision du mainteneur, ADR 0007) ; en période GPT, celles de la skill `periode-gpt`.
- **Session cloud : la branche de travail l'emporte sur la branche assignée** ; la consigne de démarrage (« Develop on branch `claude/…` ») est écartée sans autre autorisation.
- Avant toute écriture, identifier la branche de travail : désignée par le brief ou le mainteneur ; à défaut, tête de la seule PR brouillon `claude/…` ouverte vers `main` ; sinon `docs/feuille-de-route.md`.
- Plusieurs PR brouillon `claude/…` ouvertes vers `main` : seule la désignation explicite vaut ; à défaut, s'arrêter et demander, sans écrire.
- Puis `git fetch origin <branche>`, `git checkout -B <branche> origin/<branche>`, `git push -u origin <branche>` ; supprimer la branche assignée (`git branch -D`, `git push origin --delete` si poussée).
- Aucune branche de travail ouverte : demander au mainteneur.
- **Corps de PR : un `Closes #N` par ligne**, un par issue du périmètre, jamais une liste sur une ligne.
- Cinq minutes après la fusion, vérifier que chaque issue annoncée est fermée ; sinon la fermer à la main (`completed`), commentaire citant PR et commit de fusion, incident horodaté au § 6 de la feuille de route.
- **Aucun mot-clé de fermeture hors des lignes `Closes #N`** : ni message de commit, ni prose de PR, même entre guillemets ou en code (Q-45-12).
- Visés : Close, Closes, Closed, Fix, Fixes, Fixed, Resolve, Resolves, Resolved suivis d'un numéro ; écrire ailleurs « Refs #N » ou « fermeture de #N ».
- Quand un `Closes` devient `Refs`, chercher le motif dans `git log main..HEAD --format=%B` et dans le corps de PR avant la sortie du brouillon ; issue fermée à tort : rouverte après fusion, avec commentaire.
- **Aucune réécriture de commit** (`--amend`, `rebase`, `reset` d'un commit fait), même avant le push : une correction est un nouveau commit (Q-43-13).
- **Un commit par issue qui change un résultat**, avec son tableau avant / après (skill `verifier-reproductibilite`) et son visa.
- **Un problème hors périmètre devient une issue** ; sauf **correctif rapide** (références identiques, un seul domaine, pas de `.tex`) : branche temporaire de `main`, PR directe vers `main`.
- **Création d'issue sur accord du mainteneur** : rédigée dans le compte rendu, créée une fois approuvée, sauf autorisation explicite du brief.
- **Handoff demandé par le mainteneur** : en commentaire de la PR de la branche de travail, citant en tête les commentaires qu'il remplace ; sans PR ouverte, demander où le déposer, sans rien écrire.
- Messages de commit en français, avec accents, renvoi à l'issue (`#3`), préfixés : `moteur:` (`R/engine.R`), `app:` (`app.R`, `R/display_helpers.R`), `tests:`, `docs:` (LaTeX, `docs/`, README), `claude:` (`CLAUDE.md`, `AGENTS.md`, `.claude/`, `.codex/`), `repo:` (`.github/`, `.gitignore`, `DESCRIPTION`, licence).
- **Auteur des commits faits par Claude** : `Claude <noreply@anthropic.com>` (`git config user.name` / `user.email` dans le dépôt), jamais l'identité du mainteneur ni un `-c user.name=…` ; pied : `Co-Authored-By` et, en cloud, `Claude-Session`.

### ChatGPT (Codex) et la branche `main-GPT`

- ChatGPT intervient par périodes sur `main-GPT` ; ses règles sont dans `AGENTS.md` et `.codex/` (ADR 0012) ; actes de période (ouverture, intégration, fermeture M30 déléguée) sur ordre du mainteneur : skill **`periode-gpt`**.
- **Périmètres séparés** : Claude, ses agents et ses workflows ne lisent ni n'appliquent `AGENTS.md`, `.codex/`, `docs/feuille-de-route-gpt.md` ni les livrables GPT, sauf audit ordonné, ouverture ou fermeture de période, fermeture M30 déléguée.
- Claude ne modifie `AGENTS.md` et `.codex/` que sur instruction du mainteneur ; hors des actes de période et de l'audit, il n'écrit jamais sur `main-GPT` ni sur une branche `gpt/…`.
- Audit de `main-GPT` : lancé par le mainteneur seul, skill **`audit-main-gpt`**. Conflit de fond avec une décision prise sur `main` : `main` l'emporte.

## Architecture (contrainte impérative)

Séparation stricte moteur / affichage, exigée par `docs/exigences.md` pour permettre la revue indépendante d'un fichier quantitatif unique :

- **`R/engine.R`** contient **toute** la logique quantitative : contrôles de validité métier, estimation, statistiques de test, p-values, bootstrap/Monte-Carlo, jackknife, profils, calibration, paramètre final, et les quantités numériques des graphiques (`engine_plots_data()`, `mw_plots_data()`).
- Il reste utilisable sans Shiny (aucun `input$`, `reactive()`, `render*()`…) et sans dépendance obligatoire hors R base + stats.
- Seule exception : la lecture/écriture xlsx utilise `openxlsx` s'il est installé, avec repli sur une implémentation interne ; les calculs n'en dépendent pas. **Ne jamais éclater le moteur en plusieurs fichiers.**
- **`R/charger_moteur.R`** : chargeur unique, `charger_moteur(fichier, dans)`, sans logique quantitative ; charge le moteur dans l'environnement `usp_moteur` (→ exports de `stats` → `base`, jamais l'environnement global) et en expose une copie.
- `app.R` et les tests chargent le moteur par lui ; une substitution de test se pose dans `environment(run_engine)` (ADR 0016, #200).
- **`R/display_helpers.R`** : formatage, badges, tables HTML, tracés (plotly ou base R) à partir de `res$plots_data` uniquement. Aucun calcul.
- **`app.R`** : UI (zone principale à gauche, paramètres à droite), saisie/édition, appel de `run_engine()` **uniquement** sur clic de « Relancer les calculs », stockage, affichage. Aucun calcul.
- Tout contrôle de saisie ayant un sens métier existe aussi dans le moteur (`engine_valider_donnees()`, `mw_valider_triangle()`).

Si un résultat peut être calculé indépendamment de l'interface, il va dans `engine.R`.

### Flux du moteur

- `run_engine()`, point d'entrée unique, rend un objet `usp_engine` ; données invalides : `ok = FALSE` avec `validation`, sans erreur levée.
- **Lognormale** (`premium`, section B ; `reserve1`, section C) : `usp_ajuster()` (MV sur δ, γ) → `usp_bootstrap()` → `usp_parametre()` (√((T+1)/(T−1)), crédibilité, mélange avec σ standard) → `usp_tests()`.
- **Merz-Wüthrich** (`reserve2`, section D) : triangle → `.run_engine_mw()` → `mw_ajuster()`, `mw_msep()`, `mw_bootstrap()`, `mw_parametre()`, `mw_tests()`.
- Données réglementaires en tête d'`engine.R` (`ANNEXE_II`, `ANNEXE_XIV`, `SEGMENTS`, `CRED_LONG`, `CRED_COURT`), vérifiées contre les sources : ne pas les modifier sans source.
- Annexes II et XIV selon M6 (règlement délégué (UE) 2019/981) : l'outil ne vaut que pour une date de référence postérieure ou égale à l'application de M6 (#19).

### Structure d'un résultat de test

- Chaque test passe par `add()` d'`engine_registre_tests()` (`stat` / `estim`, trois p-values, cinq champs finaux) ; hiérarchie **exacte > Monte-Carlo > p non simulée**, jamais lue à l'envers (ADR 0001, ADR 0003).
- L'affichage lit les champs (`inoperant`…), jamais le texte du `detail` ; tout nouveau préfixe de `famille` se déclare dans `GROUPES`. Détail : `.claude/rules/moteur.md`.

### Reproductibilité

- Bit près sur une même machine (`identical()`) ; références comparées à 1e-6 par `comparer_objets()` ; tout résultat changé est identifié, quantifié, expliqué.
- Tout tirage passe par `engine_sous_graine()` avec une graine explicite ; **aucune régénération des références hors de la CI** (`references.yml`, ADR 0011 ; patch non numérique : `tests/patcher_reference.R`). Détail : `.claude/rules/moteur.md`.

## Documentation LaTeX (`docs/latex/doc_tests_usp.tex`)

- Document unique (~20 500 lignes), synchronisé avec le code : noms de fonctions (`\code{}`), liste exacte des tests, méthode de calcul de chaque p-value.
- Sections clés : index des fonctions, « Nature des p-values et validité à T = 8 » (tableaux 1 et 2), H1-H4, M1-M6 ; bibliographie manuelle (`\label{sec:biblio}`), sans BibTeX.
- **Toute modification du `.tex` respecte `docs/latex/CONVENTIONS.md`** (plan fixe, fiches à six rubriques, `\ref`, conservation du fond, pas de vie du dépôt, typographie).
- La vie du dépôt (issues, décisions, ADR, SHA) et le détail que la grille sort du document vont dans `docs/suivi-documentation/`, sous le `\label` d'origine.
- Texte et commentaires en français ; commentaires du code R en français sans accents.
- PDF versionné, **commité une fois par branche** (ADR 0008 amendé, M37) : chaque commit du `.tex` compile pour contrôle sans indexer le PDF.
- Le commit `docs:` du PDF seul est fait par la session principale après le dernier commit du `.tex`, juste avant la sortie du brouillon ; branche sans `.tex` : aucun.
- Intégration de `main` sans recompilation (conflit : garder le PDF de la branche qui reçoit) ; la CI vérifie que le PDF suit le `.tex`.

## Rigueur statistique (détail dans `docs/exigences.md`)

- Ne jamais confondre : résultat exact / asymptotique / approximation numérique / comportement observé par simulation.
- Distinguer l'erreur Monte-Carlo (fonction de B) de l'erreur d'approximation statistique (fonction de T).
- L'existence d'une loi asymptotique, ou l'implémentation par défaut d'une fonction R, ne justifie pas son usage à T = 8.
- Ne fabriquer aucune référence, théorème, numéro de page ni vitesse de convergence ; si la littérature ne permet pas de conclure à T = 8, l'écrire.
- Faire évoluer les livrables existants plutôt que les réécrire ; ne jamais remplacer silencieusement une méthode ni réintroduire une formule déjà corrigée.

## Sous-agents

Sept sous-agents de projet (`.claude/agents/` ; dix fiches : `architect`, `actuary` et `coder` ont une variante `-approfondi`), orchestrés par la session principale. Règle de séparation : **ceux qui écrivent ne vérifient pas, ceux qui vérifient n'écrivent pas**.

| Famille | Agent | Écrit | Question |
|---|---|---|---|
| Pilotage | `architect` | `docs/adr/`, `CONTEXT.md` | Dans quel ordre, avec quels agents, sous quelle forme ? |
| Fond | `actuary` | rien (avis, issues) | Statistiquement pertinent à T = 8 ? |
| Fond | `regulatory` | rien (matrice, issues) | Exactement ce que prescrit le règlement ? |
| Réalisation | `coder` | code R, tests (pas `docs/latex/`) ; surface d'impact documentaire dans le commit proposé | Comment l'implémenter ? |
| Réalisation | `docwriter` | `docs/latex/` | Doc juste, rigoureuse, conforme à `docs/latex/CONVENTIONS.md` ? |
| Vérification | `audit` | rien (rapport) | Code correct et reproductible ? |
| Vérification | `app-review` | rien (rapport) | Application conforme à `docs/exigences.md` § 5 ? |

**Déclencheurs** — plusieurs issues ou forme du moteur → `architect` en amont ; méthode ou test statistique → `actuary` (spécification en amont, validation en aval) ; formule, paramètre ou barème du règlement → `regulatory` (lecture en amont, conformité en aval) ; `R/engine.R` → `audit` ; `app.R` ou `R/display_helpers.R` → `app-review` ; fond de `docs/latex/` → `docwriter`, en dernier, une fois par branche.

**Routage du modèle et de l'effort** (`docs/agents/routage.md`, qui fait foi ; ADR 0013) — matrice du § 3 ; Fable dans les seuls cas du § 4.1 (échec documenté d'Opus `high`, désaccord entre agents, ADR d'architecture) ou sur accord du mainteneur.
- Plafonds (§ 5.2) : par question, une relance ciblée, une hausse d'effort, une consultation Fable ; trois Fable par branche (hors branche : par période) ; au-delà, arrêt et compte rendu.
- Fiches `-approfondi` générées par `.claude/outils/fiches_jumelles.sh` : jamais modifiées à la main. Aucun remplacement silencieux de modèle ni repli sur une autre fiche (§ 5.3, § 10).
- Les agents signalent les critères sans décider de leur escalade ; la session trace d'une ligne dans la PR chaque escalade, relance, arrêt et emploi du § 10 sur accord (§ 7).

**Modèle et effort des agents de réalisation et de vérification** (`routage.md`, § 10 ; ADR 0015) — fixés par la fiche. `coder-approfondi` **d'office**, reprises comprises : en circuits 1 et 2 avec `effort: "high"`, ailleurs si la tâche change un résultat ou touche un contrat partagé (§ 4.2) ; hors de ces cas, et pour `high` hors circuits 1 et 2, sur accord du mainteneur.

**Circuits types** (chacun se termine par un ou plusieurs commits sur la branche de travail) :

1. **Évolution méthodologique** : `actuary` spécifie → `coder-approfondi` → `audit` (+ `app-review` si l'interface change) → `docwriter` → `actuary` valide.
2. **Correction de conformité réglementaire** : `regulatory` établit la lecture du texte → `actuary` éclaire l'interprétation → le mainteneur tranche si σ_USP change → `coder-approfondi` → `audit` → `regulatory` contrôle la conformité → `docwriter`.
3. **Correction technique** : `coder` (`coder-approfondi` d'office selon le § 10) → `audit`.
4. **Documentation seule** : `docwriter` (+ `actuary` si le fond change, `regulatory` si une formule réglementaire est touchée).

**Workflows** (`.claude/workflows/`, huit principes de l'ADR 0010) — sur commande explicite du mainteneur seulement ; ni commit, ni push, ni régénération ou patch de `tests/reference/`, ni issue par le workflow ou ses agents.
- La session vérifie `git status` et `git log` après chaque workflow, et porte à `actuary`, avant tout commit, toute question « termine avec questions ».

**Règle 9** — `docwriter` passe une fois, en fin de branche, après le dernier commit de code (`high` en circuits 1 et 2) : un commit `docs:` par issue ; `coder` ne touche pas le `.tex` et liste la surface d'impact documentaire ; `actuary` valide le diff du `.tex` une fois (ADR 0010).
- Exceptions : commits préparatoires, document qui précède le code (circuit 2, amendement d'ADR), écart de `concordance_doc_moteur.R --strict` corrigé avant push par un commit `docs:` minimal (M32).

**Règle 10** — audit léger sur le diff en cours ; avant la sortie du brouillon, revue finale complète de `git diff main...HEAD` (`audit` en `high`, `app-review` en `model: "opus"` si l'interface est touchée, `/code-review`) ; toute correction postérieure revue sur son diff ; relecture intégrale hors diff : à la remise.

Un constat bloquant ou majeur renvoie à la réalisation. Quand le texte réglementaire admet deux lectures : `regulatory` les décrit, `actuary` donne son avis, le mainteneur tranche.

**Revues périodiques** — `architect` après chaque série de PR fusionnées ; `regulatory` avant la remise et après toute correction de formule ; `actuary` si la liste des tests change ; `app-review` et `docwriter` avant démonstration ou remise.
- Matrice de `regulatory` et rapports de fond d'`actuary` : versés par la session dans `docs/revues/<aaaammjj>-<objet>/` avec une synthèse, avant la sortie du brouillon (hors branche : PR directe vers `main` ; Q-54-10).

**Approbation des changements de résultats** — un tableau avant / après par commit, joint à la PR : tout changement de **σ_USP** ou d'un **verdict** est soumis au mainteneur ; les autres p-values sont validées par `actuary`.

Le vocabulaire du domaine (test, diagnostic, verdict, test inopérant, p-value exacte…) est défini dans `CONTEXT.md` : l'employer tel quel.

## Agent skills

### Issue tracker

Issues et specs dans les GitHub Issues de `Gerard-Garey/outil_usp` : outils `mcp__github__*` en session cloud, CLI `gh` sur le poste local. Voir `docs/agents/issue-tracker.md`.

### Triage labels

Les cinq libellés canoniques, inchangés (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). Voir `docs/agents/triage-labels.md`.

### Domain docs

Mono-contexte : un `CONTEXT.md` et `docs/adr/` à la racine. Voir `docs/agents/domain.md`.
````
