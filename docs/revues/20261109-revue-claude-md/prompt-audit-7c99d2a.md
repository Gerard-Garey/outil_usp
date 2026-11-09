# `/doctor prompt-audit` sur `7c99d2a` (après l'étape 1b de #515)

Rapport versé au titre de Q-R7 (a) (`structure-cible.md`, « `/doctor prompt-audit` ») : second des deux rapports prévus, sur l'état après 1b. Le premier, sur `d5cdb51`, n'a pas été produit à cette date.

- **Lancement** : par le mainteneur, sur le poste local (Windows), le 09/11/2026, Claude Code 2.1.319, session principale Opus 5.5 (`claude-opus-5-5`), effort `xhigh`.
- **Branche** : `claude/application`, tête `7c99d2a`.
- **Suites** : corrections appliquées dans `b221916` (`claude:`, Refs #515) sur instruction du mainteneur ; constat M1 porté par l'issue #523 (`needs-triage`).
- La phrase sentinelle de `.claude/rules/moteur.md` est remplacée ci-dessous par `<jeton>`, pour ne pas fausser la mesure E1 à E5 (`structure-cible.md`, § 7).

## Hypothèses de l'audit

- **Périmètre** : configuration chargée dans une session Claude Code du projet : `CLAUDE.md`, `.claude/rules/moteur.md`, les quatre skills de `.claude/skills/`, les dix fiches de `.claude/agents/`.
- **Modèle cible** : Opus 5.5 pour le socle, la règle et les skills ; pour les fiches qui fixent leur modèle, Opus (`architect`, `actuary`, `audit`, `docwriter`, `regulatory`, `coder-approfondi`) ou Sonnet 5.5 (`coder`, `app-review`). Aucun constat ne dépend du modèle.
- **Non lus** : `AGENTS.md` (`CLAUDE.md`, « Périmètres séparés » : un audit de prompts n'est pas un des cas admis ; à auditer sur confirmation du mainteneur) ; `.claude/workflows/circuit-technique.js` (script, hors des catégories auditées) ; mémoire, réglages, hooks, `.mcp.json`.
- **Rapport sans modification proposée** : skills synchronisées d'Anthropic (`~/.claude/skills/synced/`, 14 skills) et plugin `mattpocock-skills` 1.3.1 : propres aux motifs recherchés (seule emphase : `pdf/SKILL.md:171`, contrainte technique justifiée).
- **Absents** : `~/.claude/CLAUDE.md`, `CLAUDE.md` de politique gérée ou d'un dossier parent, règles, commandes, agents et styles de sortie au niveau utilisateur. Le plugin `document-skills` est en cache, ses skills ne sont pas chargées.

## Synthèse

Les instructions sont saines sur le fond : aucun langage de pression (aucune majuscule d'insistance), aucune consigne de raisonnement datée, aucun exemple modèle figé. Les interdits en gras sont des contraintes réelles du processus (git, ACPR, références produites par la CI), avec leur raison : ils restent. Les défauts sont des faits périmés.

| Groupe | Résultat |
|---|---|
| 1, texte de prompt daté | 2 constats (formulations relatives à un état antérieur) + 1 à faible confiance |
| 2, fichiers de skills et de configuration | 4 constats forts + 4 signalements à faible confiance |
| 3, descriptions d'outils | sans objet (les `description` des fiches sont du texte d'aiguillage, correctement calibré) |
| 4, configuration des requêtes | sans objet, sauf la liste des sous-agents : 1 constat |

## Constats

### Confiance haute (corrigés dans `b221916`)

- **H1** — `.claude/agents/coder.md:18` (et `coder-approfondi.md:19`) : « … avec la hiérarchie exacte > Monte-Carlo > asymptotique. » Conflit entre fichiers : la ligne date du 21/09/2026 ; la règle plus récente (`be74bed`, 12/10/2026, #120 ; `.claude/rules/moteur.md:20`, `CLAUDE.md:83`) nomme le troisième rang « p non simulée ». Réécrit ; jumelle régénérée par `fiches_jumelles.sh`.
- **H2** — `.claude/agents/app-review.md:38` : « en renvoyant aux issues existantes (notamment #4, piste 4) ». L'issue #4 est fermée depuis le 04/11/2026. Renvoi retiré.
- **H3** — `.claude/skills/verifier-reproductibilite/SKILL.md:10` : repli « sous Windows : `"/c/Program Files/R/R-4.3.1/bin/Rscript.exe"` ». L'en-tête de `.claude/hooks/preparer_r.sh` (l. 25-29) donne R 4.3.3 sur le poste du mainteneur et cherche lui-même les installations ; le hook de la session a trouvé `/c/Program Files/R/R-4.3.3`. Remplacé par le renvoi au hook.
- **H4** — `.claude/agents/docwriter.md:13` (« gabarit des fiches à six rubriques ») et `CLAUDE.md:95` (« fiches à six rubriques ») : `docs/latex/CONVENTIONS.md:24` ajoute la rubrique 7 `\Pertinence` aux fiches de test (`baa5be9`, 27/09/2026). Complété dans les deux fichiers.

### Confiance moyenne

- **M1** — fiches `architect-approfondi`, `actuary-approfondi`, `coder-approfondi` : même corps que la fiche de base ; seuls `effort`, `maxTurns` (`architect`, `actuary`) ou `model` et `effort` (`coder`) diffèrent. L'ADR 0013, annoté le 18/10/2026, constate que la prémisse de sa décision 1 est caduque (`effort` et `model` se passent à l'appel) sans la réexaminer ; seul `maxTurns` ne se règle pas à l'appel. Motif : sous-agents redondants. Non corrigé : le retrait rouvre une décision d'ADR et touche la CI, `fiches_jumelles.sh`, `circuit-technique.js`, `routage.md`, deux skills et `CLAUDE.md`. **Issue #523**, à trier.
- **M2** — `CLAUDE.md:31` : « aucune branche de travail parallèle ne se propose plus (nouvelle exception à l'initiative du mainteneur seulement) ». Formulation relative à un état antérieur. Réécrit au présent (corrigé dans `b221916`).
- **M3** — `.claude/skills/verifier-reproductibilite/SKILL.md:28` : « un cas seul s'écrit comme avant ». Même motif. Réécrit « sans « ;; » » (corrigé dans `b221916`).

### Faible confiance (signalés, non corrigés)

- **F1** — « Lis d'abord `CLAUDE.md` » (`coder.md:11`, `audit.md:11`, `docwriter.md:11`, `regulatory.md:11`, `app-review.md:11`) contre « `CLAUDE.md` est déjà dans ton contexte » (`architect.md:12`, `actuary.md:12`). Même commit `cf7ab2b` pour la plupart : l'historique ne les ordonne pas. À trancher par le mainteneur ; la mesure E1 à E5 peut l'éclairer.
- **F2** — mentions historiques : `moteur.md:12` et `periode-gpt/SKILL.md:8` (« Texte repris à l'identique de `CLAUDE.md` à `d5cdb51` »), `periode-gpt:12`, `coder.md:16` (« écart de #357, Q-44-11 »). Volontaires (traçabilité, `tableau-regles.md`).
- **F3** — `periode-gpt/SKILL.md:18` pose « `AGENTS.md` interdit à GPT de lire `.claude/` », amendé à la ligne 23 (exception pour `moteur.md`) ; texte déplacé à l'identique par l'ADR 0017.
- **F4** — `.claude/rules/moteur.md:30` : phrase sentinelle (« Repère de chargement de cette règle : `<jeton>` ») ; à retirer une fois la mesure E1 à E5 faite.
- **F5** — `CLAUDE.md:93` : « ~20 500 lignes » ; 21 017 mesurées.
- **F6** — `coder.md:9` : « à l'aise … en LaTeX », alors que la ligne 16 interdit `docs/latex/` ; phrase de rôle, sans effet démontré.

## Vérifications contre le dépôt

- Symboles de `moteur.md` et de `CLAUDE.md` présents dans `R/engine.R` et `tests/outils_tests.R`, valeurs conformes : `DECALAGE_GRAINE_FLUX_REGIME` = 539169, `SEED_LOI_NULLE_SW` = 20260901, `FACTEUR_B_MAX_MW` = 25, `TOLERANCE` = 1e-6 ; 13 statistiques déclarent des `extremes` ; T minimal = 5 (`engine.R:351`).
- Fichiers cités tous présents ; options de scripts définies (`--parallele`, `--deux-parts`, `--seuil`, `--tout`, `--attendu`, `--creer`, `--strict`, `--installer`) ; sections citées de `routage.md` et de `exigences.md` présentes ; tailles annoncées justes (feuille de route > 600 Ko, `CONTEXT.md` > 100 Ko).
- Après `b221916` : `fiches_jumelles.sh --verifier` conforme ; CI du commit verte (« Fiches d'agents », « Fichiers modifiés », « Mots-clés de fermeture »).

Les documents de l'étape 1a (`structure-cible.md`, `tableau-regles.md`) gardent le texte d'origine, qu'ils consignent.
