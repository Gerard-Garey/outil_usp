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
- Aucune session, aucun agent ni aucun workflow ne crée de sa propre initiative une branche de travail ou une PR de plus, hors correctif rapide et exceptions bornées ci-dessous ; ne propose aucune branche de travail parallèle : seul le mainteneur, de sa propre initiative, en ouvre une.
- Exceptions bornées, sans PR ni fusion : `claude/regeneration-<issue>` (skill `verifier-reproductibilite`), `claude/sauvegarde-<issue>` (décision du mainteneur, ADR 0007 ; exécution selon M42, feuille de route § 4) ; en période GPT, celles de la skill `periode-gpt`.
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
- **Toute modification du `.tex` respecte `docs/latex/CONVENTIONS.md`** (plan fixe, fiches à six rubriques, plus `\Pertinence` pour un test, `\ref`, conservation du fond, pas de vie du dépôt, typographie).
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

**Déclencheurs** — un agent n'entre dans le circuit que si la modification touche son domaine : plusieurs issues ou forme du moteur → `architect` en amont ; méthode ou test statistique → `actuary` (spécification en amont, validation en aval) ; formule, paramètre ou barème du règlement → `regulatory` (lecture en amont, conformité en aval) ; `R/engine.R` → `audit` ; `app.R` ou `R/display_helpers.R` → `app-review` ; fond de `docs/latex/` → `docwriter`, en dernier, une fois par branche.

**Routage du modèle et de l'effort** (`docs/agents/routage.md`, qui fait foi ; ADR 0013) — matrice du § 3 ; Fable dans les seuls cas du § 4.1 (échec documenté d'Opus `high`, désaccord entre agents, ADR d'architecture) ou sur accord du mainteneur.
- Plafonds (§ 5.2) : par question, une relance ciblée, une hausse d'effort, une consultation Fable ; trois Fable par branche (hors branche : par période) ; au-delà, arrêt et compte rendu.
- Fiches `-approfondi` générées par `.claude/outils/fiches_jumelles.sh` : jamais modifiées à la main. Un modèle indisponible arrête le circuit ; aucun remplacement silencieux de modèle ni repli sur une autre fiche (§ 5.3, § 10).
- Les agents signalent les critères sans décider de leur escalade ; la session trace d'une ligne dans la PR chaque escalade, relance, arrêt, emploi du § 10 sur accord et appel de `regulatory` en `high` (§ 7, § 10).

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
- Matrice de `regulatory` et rapports de fond d'`actuary` : versés intégralement par la session dans `docs/revues/<aaaammjj>-<objet>/` avec une synthèse, avant la sortie du brouillon (hors branche : PR directe vers `main` ; Q-54-10).

**Approbation des changements de résultats** — un tableau avant / après par commit, joint à la PR : tout changement de **σ_USP** ou d'un **verdict** est soumis au mainteneur ; les autres p-values sont validées par `actuary`.

Le vocabulaire du domaine (test, diagnostic, verdict, test inopérant, p-value exacte…) est défini dans `CONTEXT.md` : l'employer tel quel.

## Agent skills

### Issue tracker

Issues et specs dans les GitHub Issues de `Gerard-Garey/outil_usp` : outils `mcp__github__*` en session cloud, CLI `gh` sur le poste local. Voir `docs/agents/issue-tracker.md`.

### Triage labels

Les cinq libellés canoniques, inchangés (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). Voir `docs/agents/triage-labels.md`.

### Domain docs

Mono-contexte : un `CONTEXT.md` et `docs/adr/` à la racine. Voir `docs/agents/domain.md`.
