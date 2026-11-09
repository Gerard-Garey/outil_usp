# Revue d'architecture de `CLAUDE.md` (09/11/2026, branche K5, #515, étape 1a)

> *Rédigé par l'agent architect (IA), fiche `architect-approfondi`. Tableau de correspondance, structure cible et projet de socle dans `20261109-revue-claude-md/` ; décision proposée : ADR 0017 (`docs/adr/0017-instructions-claude-socle-regles-documents.md`).*

## Objet

Réduire le volume de `CLAUDE.md`, chargé en permanence par la session et par chaque sous-agent, sans perdre de règle (#515). Forme décidée par le mainteneur le 09/11/2026 : Q-56-4 (a) avec les corrections Fable n° 1 à 5, et Q-56-12 (a). L'étape 1a produit la structure à valider ; la session l'applique à l'étape 1b ; `architect-approfondi` relit et mesure à l'étape 1c.

## Production

| Fichier | Contenu |
|---|---|
| `20261109-revue-claude-md/tableau-regles.md` | 206 lignes : 195 règles de l'ancien texte, 9 mentions historiques, 2 résumés nouveaux ; chacune avec sa citation, sa ligne, son emplacement cible et sa forme ; volumes avant / après par section. |
| `20261109-revue-claude-md/structure-cible.md` | Plan du socle, de `.claude/rules/moteur.md` (frontmatter exact) et de la skill `periode-gpt` ; documents cibles ; ligne proposée pour `AGENTS.md` ; renvois à mettre à jour en 1b ; protocole de mesure de 1c ; projet de socle en annexe. |
| `docs/adr/0017-instructions-claude-socle-regles-documents.md` | ADR **proposé** : critères de placement, options écartées, conséquences, correspondance des paragraphes que nomment les procédures de retour arrière. |

## Résultat

| Mesure (`wc -c`, octets) | À `d5cdb51` | Projet de socle |
|---|---:|---:|
| `CLAUDE.md` | 42 502 (139 lignes) | 19 034 (169 lignes ; 18 838 hors commentaire HTML ; 18 529 caractères) |
| `.claude/rules/moteur.md` | — | ≈ 8 700 (chargée à la demande) |
| skill `periode-gpt` | — | ≈ 3 800 (chargée à la demande) |

- Réduction du socle : − 55 %. La cible décidée de ≈ 16 000 octets **n'est pas atteinte** : environ 3 000 octets de plus (Q-R1).
- Ce qui fixe le plancher, sous les contraintes décidées : la tête intégrale d'« Architecture » (1 798), « Documentation LaTeX » avec les règles du PDF (1 280), « Rigueur statistique » (737), le tableau des agents, les circuits et les règles d'office (≈ 3 000), et les règles Git que seule la consigne fait respecter (3 940).
- Aucune règle n'est perdue : chacune a un emplacement, et les documents cibles qui existent déjà portent le détail renvoyé (vérifié par lecture : skills `audit-main-gpt` et `verifier-reproductibilite`, `docs/agents/routage.md` § 2 à § 10, ADR 0007, 0010 et 0015, en-tête de `preparer_r.sh`).
- Tous les titres sont gardés ; les intitulés en gras de « Sous-agents » restent en tête de ligne. Les procédures de retour arrière restent exécutables, avec deux retouches de `routage.md` § 10 (ADR 0017, annexe A).
- Deux mentions caduques sont relevées et corrigées sans changement de règle : le report dans l'ADR 0007 de la décision du 29/09, déjà fait ; le contrôle de CI de #407, déjà en place.

## Questions au mainteneur pour la validation de la structure

| N° | Question | Recommandation |
|---|---|---|
| Q-R1 | Volume cible : (a) accepter environ 19 000 octets (169 lignes réelles, environ 235 lignes de 80 caractères) ; (b) descendre à 16 000. Pour (b), il faudrait de plus condenser la tête d'« Architecture » (contraire à Fable n° 2), sortir le tableau des agents ou les circuits (contraire à Q-56-4 (a)), ou raccourcir des règles Git au risque de leur adhérence. | **(a)** |
| Q-R2 | Procédures de période GPT : (a) skill `periode-gpt`, sous `.claude/` ; (b) document `docs/agents/periode-gpt.md`. | **(a)** : la skill reste hors de la lecture de GPT (`AGENTS.md` l. 18), ce qui garde la séparation des périmètres, et elle se charge par sa description dès qu'une demande nomme `main-GPT`. |
| Q-R3 | Chemins de la règle : (a) ajouter `R/display_helpers.R` à la liste décidée ; (b) liste décidée seule. | **(a)** : `GROUPES`, `inoperant` et `nature_p` sont lus par l'affichage, et #509, dans K5, touche `GROUPES`. Le socle garde de toute façon la ligne « l'affichage lit les champs ; nouveau préfixe déclaré dans `GROUPES` ». |
| Q-R4 | Fiche `regulatory` : ajouter la consigne de lire `.claude/rules/moteur.md`, en plus des quatre fiches prévues (Fable n° 4) ? | **Oui** : le détail des sources d'`ANNEXE_II` et d'`ANNEXE_XIV` (M6, neuf écarts-types) passe dans la règle. |
| Q-R5 | Règles du PDF une fois par branche : les déplacer de « Contexte » vers « Documentation LaTeX ». Les deux sections restent dans le socle et dans la zone lisible par GPT. | **Oui** : « Contexte » ne garde que le fond. |
| Q-R6 | Unité de mesure du volume : `wc -c` (octets, convention de #515), avec `wc -m` en complément. | **Oui** |
| Q-R7 | `/doctor prompt-audit` est une commande interactive (Claude Code ≥ 2.1.283 ; 2.1.319 dans la session cloud du 09/11). (a) Le mainteneur la lance avant 1b (état `d5cdb51`) et après ; (b) le critère est consigné « non mesuré ». | **(a)**, rapports versés dans `20261109-revue-claude-md/`. |
| Q-R8 | Texte et emplacement de la ligne d'`AGENTS.md` (`structure-cible.md`, § 5) : après la l. 18, comme exception bornée à l'interdiction de `.claude/`. | **Approuver**. La session vérifie ensuite qu'une seule ligne est ajoutée. |

## Critères signalés (`docs/agents/routage.md`, § 4)

- **Invariant « Architecture » de `CLAUDE.md`** : la tête et « Flux du moteur » restent dans le socle. Ses deux sous-sections « Structure » et « Reproductibilité » changent de lieu, sans changer de contenu (§ 4.2, déjà prévu par Fable n° 1).
- **ADR nouveau** (0017) : c'est un ADR d'organisation (instructions, outillage), donc en jugement selon la matrice du § 3, sans Fable de routage initial. La qualification revient à la session.
- **Écart à une décision prise** : la cible de Q-56-4 (a) (≈ 16 000) est dépassée d'environ 3 000 octets (Q-R1).
- Aucun contrat partagé de code, aucun résultat, aucun désaccord avec un autre agent.

## Suite

Validation de la structure par le mainteneur (Q-R1 à Q-R8) → étape 1b (commits `claude:` puis `docs:` de la session, à partir du tableau et du projet de socle) → étape 1c (relecture du diff, mesure par phrase sentinelle, volume mesuré sur le fichier commité) → nouvelle session avant l'étape 2. Si la validation n'est pas acquise à la fin de l'étape 8, #515 sort de K5 (Fable n° 9).
