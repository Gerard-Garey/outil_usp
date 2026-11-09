---
status: accepted
date: 2026-11-09
---

# Instructions de Claude : socle chargé en permanence, règles à chemins, documents à la demande

## Contexte

**Volume.** À la tête `d5cdb51` (09/11/2026), `CLAUDE.md` compte 139 lignes et 42 502 octets (`wc -l -c` ; 41 403 caractères par `LC_ALL=C.UTF-8 wc -m`), soit environ 300 octets par ligne et jusqu'à 3 745 pour une seule ligne (`awk '{print length}'`). Par section (octets, `awk` sur les titres) : « Contexte » 2 371 ; « Commandes » 2 114 ; « Git et GitHub » 8 099, plus « ChatGPT (Codex) et la branche `main-GPT` » 4 243 ; « Architecture (contrainte impérative) » 1 880, plus « Flux du moteur » 1 663, « Structure d'un résultat de test » 3 785, « Reproductibilité » 3 568 ; « Documentation LaTeX » 1 090 ; « Rigueur statistique » 737 ; « Sous-agents » 12 333 ; « Agent skills » 502. Le fichier a crû de 36 443 octets au commit `b7a5922` (ADR 0015, fait 3) à 42 502.

**Recommandation d'Anthropic** (documentation de Claude Code, « How Claude remembers your project », https://code.claude.com/docs/en/memory.md, lue le 09/11/2026) : « target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence. Move instructions that matter for only part of the codebase into path-scoped rules, which load only when Claude works with matching files » ; les imports `@chemin` « don't reduce its context cost » ; une procédure en plusieurs étapes va dans une skill. Le seuil est écrit en lignes ; ce qu'il protège (contexte consommé, adhérence) dépend du volume. À 42 502 octets, `CLAUDE.md` pèse autant qu'environ 530 lignes de 80 caractères (#515).

**Chargement par chaque sous-agent.** Un sous-agent personnalisé charge « every level of the CLAUDE.md hierarchy the main conversation loads, including […] project rules » (https://code.claude.com/docs/en/sub-agents.md, lue le 09/11/2026). Les dix fiches de `.claude/agents/` reçoivent donc tout `CLAUDE.md` à chaque appel : le coût est multiplié par le nombre d'appels d'une branche, workflows compris. La même page ajoute que la conversation principale garde le `CLAUDE.md` complet quand elle lit les résultats des sous-agents.

**Mécanisme des règles à chemins** (memory.md, *vérifié* sur le texte de la page) : une règle de `.claude/rules/` à champ `paths:` se charge quand Claude emploie Read, Write ou Edit sur un fichier correspondant, ou le lit par `cat` ou `head` sur un seul fichier ; une règle sans `paths:` se charge au lancement ; `paths` est le seul champ lu, et un YAML illisible fait charger la règle comme si elle n'avait pas de `paths:` ; une règle à chemins est tronquée au-delà de 40 000 caractères (fenêtre de 200 000 tokens, depuis 2.1.309) ; après `/compact`, `CLAUDE.md` est réinjecté et les règles à chemins se rechargent à la demande. `git diff` et `Grep` ne figurent pas parmi les déclencheurs.

**Contraintes propres au projet.**
- Plusieurs règles ne sont imposées que par la consigne : `.claude/settings.json` autorise `git commit` et `git push -u origin claude/*` sans dialogue (ADR 0010, principe 2). Elles doivent être présentes avant toute action, y compris avant la première lecture de fichier (règle « session cloud : la branche de travail l'emporte »).
- `AGENTS.md` l. 15 fait lire à GPT les sections de fond de `CLAUDE.md`, dont « Structure d'un résultat de test » et « Reproductibilité », et l. 18 lui interdit `.claude/` (avis Fable du 09/11/2026, M1, `docs/revues/20261109-plan-k5/avis-fable.md`).
- `docs/agents/routage.md` § 9 demandait que « Sous-agents » recopie la liste du § 4.1, les plafonds du § 5.2 et les règles du § 10, « à tenir identiques » (même avis, M2) : la condensation est impossible tant que cette recopie est exigée.
- Des procédures de retour arrière nomment des paragraphes de `CLAUDE.md` : ADR 0015 l. 75 et 87, `docs/agents/routage.md` § 8 (l. 150) et § 10 (l. 189). Elles doivent rester exécutables.
- Des titres de `CLAUDE.md` sont cités hors du fichier : « Git et GitHub » (sept fiches d'agents, `.github/scripts/controle_mots_cles_fermeture.sh` l. 3 et 133, `.github/workflows/mots-cles-fermeture.yml`, `.github/dependabot.yml`), « Sous-agents » (`.github/pull_request_template.md` l. 20, `architect.md` l. 36), « Contexte » (`regulatory.md` l. 15), « circuit 3 » (`.claude/workflows/circuit-technique.js` l. 3, 17, 361), et les sections de fond par `AGENTS.md` l. 15.

**Décisions déjà prises** (feuille de route, § 5, E-09/11 (56e point)) : Q-56-3 (a), #515 en tête de la branche K5 ; Q-56-4 (a), forme en trois lieux, avec les corrections Fable n° 1 à 5 ; Q-56-12 (a), une ligne ajoutée à `AGENTS.md` sur instruction du mainteneur. Le présent ADR consigne cette forme, ses critères et sa correspondance.

## Décision

1. **Trois lieux pour les instructions de Claude**, selon le moment où une règle sert :
   - **socle** : `CLAUDE.md`, chargé au lancement par la session et par chaque sous-agent ; volume visé de l'ordre de 200 lignes ordinaires (voir le point 6) ;
   - **règle à chemins** : `.claude/rules/moteur.md`, champ `paths:` couvrant `R/engine.R`, `R/charger_moteur.R`, `tests/**` et `docs/latex/**` (Q-56-4 (a) ; ajout de `R/display_helpers.R` soumis au mainteneur) ;
   - **documents à la demande** : skills de `.claude/skills/` (chargées par leur description ou à l'appel) et documents de `docs/agents/` et `docs/adr/`, nommés par le socle.

2. **Critères de placement**, à appliquer à toute règle nouvelle :
   1. une règle que seule la consigne fait respecter, ou qui peut servir avant toute lecture de fichier, est dans le socle ;
   2. une décision réservée au mainteneur (`docs/agents/routage.md` § 5.5, rang 1 : visa d'un changement de σ_USP ou d'un verdict, deux lectures d'une source, lancement des workflows, aucun remplacement silencieux de modèle) est dans le socle ;
   3. une règle qui ne sert qu'en travaillant sur des fichiers désignables par chemin va dans une règle à chemins ; si elle peut être enfreinte sans lire ces fichiers (session qui ne lit que par `git diff` ou `Grep`), le socle en garde une ligne de résumé ;
   4. une procédure en plusieurs étapes, déclenchée par un ordre ou un événement, va dans une skill ;
   5. le détail d'une politique dont un document fait foi reste dans ce document ; le socle en donne un résumé et le renvoi, **sans recopie à tenir identique** ; en cas d'écart, le document qui fait foi l'emporte ;
   6. l'historique (dates, PR, incidents) reste dans les ADR et la feuille de route ; le socle garde l'identifiant d'une décision quand il sert à retrouver sa source.

3. **Contenu du socle** : « Contexte » ; « Commandes » ; « Git et GitHub », avec toutes les règles que seule la consigne fait respecter (aucun push sur `main`, branche de travail unique et exceptions bornées, session cloud, `Closes` par ligne et aucun mot-clé ailleurs, aucune réécriture, un commit par issue à résultats, correctif rapide, issue sur accord, handoff, préfixes, auteur) ; sous-section ChatGPT réduite aux interdictions ; « Architecture (contrainte impérative) », tête intégrale ; « Flux du moteur » en résumé ; « Structure d'un résultat de test » et « Reproductibilité », deux lignes chacune avec le renvoi à la règle, dont « aucune source d'aléa hors `engine_sous_graine()` » et « aucune régénération hors CI » ; « Documentation LaTeX », qui reçoit les règles du PDF une fois par branche ; « Rigueur statistique » inchangée ; « Sous-agents » réduit au tableau, aux déclencheurs, au routage résumé (cas de Fable, plafonds chiffrés, aucun remplacement silencieux), à la règle d'office de `coder-approfondi`, aux circuits, aux interdictions des workflows, aux règles 9 et 10, aux revues, aux approbations ; « Agent skills ».

4. **Titres et intitulés gardés.** Tous les titres de section actuels sont gardés, à leur niveau. Les intitulés en gras des paragraphes de « Sous-agents » sont gardés en tête de ligne. Les renvois existants restent ainsi valides ; ceux qui ne le seraient plus sont listés à l'annexe A.

5. **`docs/agents/routage.md` fait foi pour le routage.** Son § 9 est amendé : `CLAUDE.md` en donne un résumé et un renvoi, plus une recopie. Les ADR 0010, 0013 et 0015 reçoivent une annotation qui renvoie au présent ADR.

6. **Mesure.** Le volume se mesure par `wc -l -c CLAUDE.md` (octets, convention de #515), avec `wc -m` en complément. La structure validée par le mainteneur fixe la cible (projet de l'étape 1a : environ 19 000 octets et 170 lignes, au lieu de 16 000 octets visés par Q-56-4 (a), écart soumis au mainteneur). Le chargement de la règle à chemins est mesuré à l'étape 1c par une phrase sentinelle (`docs/revues/20261109-revue-claude-md/structure-cible.md`, § 7) ; une règle non chargée par un sous-agent qui lit un fichier correspondant revient dans le socle (Fable n° 5).

7. **Fiches d'agents.** Les fiches `audit`, `coder`, `actuary`, `docwriter` (et `regulatory`, sous réserve du mainteneur) font lire `.claude/rules/moteur.md` explicitement : `audit` lit le code par `git diff` et `Grep`, qui ne déclenchent pas la règle. Les fiches `-approfondi` sont régénérées par `fiches_jumelles.sh`.

8. **GPT.** Sur instruction du mainteneur (Q-56-12 (a)), `AGENTS.md` reçoit une ligne qui fait de `.claude/rules/moteur.md` un document de fond lu par GPT, exception bornée à l'interdiction de `.claude/`. Les procédures de période GPT vont dans une skill `periode-gpt` (sous `.claude/`, hors de la lecture de GPT), sous réserve du mainteneur ; à défaut, dans `docs/agents/periode-gpt.md`.

## Options écartées

- **(b) Imports `@chemin`** : ils organisent le fichier sans réduire le coût en contexte, les fichiers importés étant chargés avec `CLAUDE.md` (memory.md).
- **(c) Retrait du seul historique** : les dates, PR et incidents pèsent quelques milliers d'octets ; la cible n'est pas atteinte sans déplacer de détail (*hypothèse* du 56e point, non mesurée isolément : dans le tableau de l'étape 1a, l'essentiel de la réduction vient du déplacement du détail vers la règle, la skill et les documents qui font foi).
- **(d) « Architecture (contrainte impérative) » en règle à chemins** : c'est un invariant nécessaire à tout travail, `app.R`, plans et revues compris, que `routage.md` § 4.2 rattache à `CLAUDE.md`.
- **(e) Pas d'ADR** : les procédures de retour arrière des ADR 0013 et 0015 nomment des paragraphes de `CLAUDE.md` ; un relecteur doit pouvoir retrouver pourquoi et où ils ont changé de place.
- **Q-56-12 (b) Garder « Structure d'un résultat de test » et « Reproductibilité » dans le socle** : `AGENTS.md` resterait inchangé, mais le socle approcherait 25 500 octets au lieu d'environ 19 000 (projet de l'étape 1a : 19 034 − 829 de résumés + 7 353 de texte intégral ; estimation de l'avis Fable : 23 000 sur une cible de 16 000), sans gain pour les sessions qui ne touchent ni le moteur ni les tests.
- **`omitClaudeMd` dans les fiches** (sub-agents.md) : retirerait le socle des sous-agents, alors que `docwriter` commite et que tous les agents doivent connaître les interdictions du socle.
- **Une règle à chemins par sous-section** (`resultats.md`, `reproductibilite.md`) : deux fichiers pour les mêmes chemins, sans gain de chargement ; une seule règle suffit, avec une seule ligne dans `AGENTS.md`.

## Conséquences

- **Gain** : environ 23 500 octets de moins à chaque chargement du socle (projet de l'étape 1a, à confirmer sur le fichier commité), pour la session et pour **chaque** appel de sous-agent. La règle (environ 8 700 octets) ne se charge que si un fichier du moteur, des tests ou du `.tex` est lu ou écrit.
- **Risque de non-chargement** : un agent qui ne lit que par `git diff` ou `Grep` ne reçoit pas la règle. Parades : lignes de résumé du socle (point 2, critère 3), consigne explicite des fiches (point 7), mesure de l'étape 1c.
- **Risque de chargement permanent** : un frontmatter illisible charge la règle à chaque session, sans erreur visible ; le témoin négatif de l'étape 1c le détecte, et toute modification du frontmatter demande de le rejouer.
- **Écart entre résumé et document qui fait foi** : réduit par le point 2, critère 5 (le document l'emporte) ; `routage.md` § 9 le dit.
- **Évolutions** : une règle nouvelle se place par les critères du point 2 ; un décompte ou un champ du registre des tests (par exemple « 13 statistiques discrètes », ADR 0007 l. 267) se met à jour dans `.claude/rules/moteur.md`.
- **GPT** : lit une règle de `.claude/` par exception, consignée dans `AGENTS.md` ; la séparation des périmètres reste entière pour le reste de `.claude/`.
- **Fichiers** : `CLAUDE.md`, `.claude/rules/moteur.md` (nouveau), `.claude/skills/periode-gpt/SKILL.md` (nouveau, sous réserve), fiches `audit.md`, `coder.md`, `actuary.md`, `docwriter.md` (et `regulatory.md`), fiches `-approfondi` régénérées, `AGENTS.md` (une ligne) : commit `claude:` ; `docs/agents/routage.md` § 9 et § 10, annotations des ADR 0007, 0010, 0013 et 0015 : commit `docs:` ; tableau de correspondance dans `docs/revues/20261109-revue-claude-md/`.
- **Retour arrière** : rétablir `CLAUDE.md` de `d5cdb51` (ou de la tête qui précède le commit `claude:` de #515), supprimer `.claude/rules/moteur.md` et la skill `periode-gpt`, retirer la ligne d'`AGENTS.md` et les consignes de lecture des fiches (régénérer les `-approfondi`), rétablir l'ancienne ligne de `routage.md` § 9, annoter le présent ADR (« abandonné le … »).

## Annexe A — Correspondance des paragraphes de `CLAUDE.md` nommés ailleurs

Ancien emplacement : `CLAUDE.md` à `d5cdb51`. La correspondance règle par règle (206 lignes) est dans `docs/revues/20261109-revue-claude-md/tableau-regles.md`.

| Paragraphe (ancien, ligne) | Cité par | Nouvel emplacement | Effet sur la procédure qui le cite |
|---|---|---|---|
| « Sous-agents », « Routage du modèle et de l'effort » (l. 102) | ADR 0015 l. 87 (P7) ; `routage.md` § 9 (l. 162) | socle, « Sous-agents », même intitulé en tête de ligne ; résumé (Fable § 4.1, plafonds § 5.2 chiffrés, aucun remplacement silencieux) ; détail : `routage.md` § 2 à § 7 | ADR 0015 l. 87 : inchangée ; § 9 : amendé (recopie → renvoi) |
| « Modèle et effort des agents de réalisation et de vérification » (l. 104) | `routage.md` § 10 (l. 189, retour arrière) ; ADR 0015 l. 75 | socle, même intitulé, une ligne (règle d'office) ; détail : `routage.md` § 10 | « retirer le paragraphe » devient « retirer la ligne » (§ 10 amendé) |
| « Circuits types » (l. 106-111), `coder` dans les circuits 1 et 2 | `routage.md` § 10 (l. 189) ; ADR 0010 l. 76 | socle, inchangé (circuit 3 renvoie au § 10 pour la règle d'office) | inchangée |
| Principe 8 des workflows (l. 113, « aucun `model` fixé dans un workflow… ») | `routage.md` § 10 (l. 189) ; ADR 0015 point 8 (l. 41) | ADR 0010, principe 8, tel que remplacé par l'ADR 0015, point 8 ; le socle ne le recopie plus | « rétablir le principe 8 » porte sur l'ADR 0010 (§ 10 amendé) |
| Décompte des fiches (l. 88, « dix fiches ») | `routage.md` § 10 (l. 189) | socle, « Sous-agents », inchangé | inchangée |
| Renvois aux fiches `-approfondi` (l. 88, 102, 104, 108-110) | `routage.md` § 8 (l. 150) | socle, « Sous-agents » (décompte, routage, circuits 1 à 3) | inchangée |
| Recopie du § 4.1, du § 5.2 et du § 10 (l. 102-104) | `routage.md` § 9 (l. 162) | renvoi ; cas et plafonds rappelés en une ligne | § 9 amendé |
| « Workflows » (l. 113) : huit principes, question pour `actuary`, trois statuts, écart de concordance | ADR 0010 l. 10, 24, 76, 103 | socle : lancement par le mainteneur, interdictions, question portée à `actuary`, écart de concordance (« Règle 9 ») ; détail : ADR 0010 et ses annotations | annotation de l'ADR 0010 |
| « Règle 9 » (l. 115), « Règle 10 » (l. 117) | fiches `coder`, `docwriter`, `audit`, `app-review` ; skills ; `README.md` l. 231 | socle, mêmes intitulés, condensés | inchangées |
| « quand le texte admet deux lectures, le mainteneur tranche » (l. 119) | ADR 0010 l. 58 ; `routage.md` § 4.4, § 5.5 | socle, « Sous-agents » | inchangées |
| « Git et GitHub », puces « Une seule branche de travail à la fois » et « Session cloud : la branche de travail l'emporte… » (l. 24-25) | ADR 0007 l. 28, 31, 101 | socle, mêmes intitulés en gras | inchangées |
| « Git et GitHub », règle des mots-clés de fermeture (l. 27) | `.github/scripts/controle_mots_cles_fermeture.sh` l. 3, 133 ; `mots-cles-fermeture.yml` l. 3 | socle, titre gardé | inchangées |
| « Architecture » (l. 45-54) | `routage.md` § 4.2 (l. 65) ; ADR 0007 l. 181 | socle, tête intégrale | inchangées |
| « Structure d'un résultat de test » (l. 68), dont « 13 statistiques discrètes » | `AGENTS.md` l. 15 ; ADR 0007 l. 267 ; ADR 0003 | titre et deux lignes dans le socle ; texte intégral dans `.claude/rules/moteur.md` | `AGENTS.md` : une ligne (Q-56-12 (a)) ; ADR 0007 l. 267 : annotation |
| « Reproductibilité » (l. 72) | `AGENTS.md` l. 15 ; ADR 0006 l. 64 ; ADR 0011 l. 69, 201 | titre et deux lignes dans le socle ; texte intégral dans `.claude/rules/moteur.md` | `AGENTS.md` : une ligne ; ADR 0006 et 0011 : citations historiques, inchangées |
| « Flux du moteur », données réglementaires (l. 64) | `CLAUDE.md` seul ; `regulatory.md` (lecture) | socle : noms, « ne pas modifier sans source », validité à partir de M6 ; détail des sources : `.claude/rules/moteur.md` | fiche `regulatory` : consigne de lecture (sous réserve) |
| « ChatGPT (Codex) et la branche `main-GPT` » (l. 36-43) | ADR 0012 ; skill `audit-main-gpt` l. 27 | socle : titre et interdictions ; procédures : skill `periode-gpt` | inchangées |
| « Contexte » (l. 7-11), textes sources | `regulatory.md` l. 15 | socle, « Contexte », textes sources gardés ; règles du PDF déplacées dans « Documentation LaTeX » | inchangée |

## Annexe B — Mentions historiques sans autre support

Retirées du socle et consignées ici, faute d'un ADR qui les porte :

- auteur des commits faits par Claude, `Claude <noreply@anthropic.com>` : décision du mainteneur du 24/09/2026 ; les commits antérieurs, déjà publiés, ne sont pas réécrits (`CLAUDE.md` l. 34 à `d5cdb51` ; `README.md` l. 236 porte la règle sans la date) ;
- emplacements de R sur le poste Windows : décision Q-E1f-8 du 06/10/2026, portée par l'en-tête de `.claude/hooks/preparer_r.sh` (l. 25-29) et par la feuille de route ;
- dépôt public depuis le 28/09/2026 (PR #137).

Les autres mentions historiques retirées sont portées par l'ADR 0007 et ses annotations (PR #81, #163, #400 ; Q-43-13, Q-45-12 ; décisions des 05/10, 09/10, 15/10 et 29/09/2026), l'ADR 0008 (M37), l'ADR 0011 (M30, M34) et la feuille de route (Q-54-10).

## Renvois

Issue #515 ; PR #516 (branche K5) ; décisions Q-56-3, Q-56-4, Q-56-12 (feuille de route, § 5) ; avis Fable du 09/11/2026 (`docs/revues/20261109-plan-k5.md`) ; tableau et structure cible : `docs/revues/20261109-revue-claude-md/`. Voir ADR 0007 (règles Git), 0010 (workflows, règles 9 et 10), 0012 (flux GPT), 0013 et 0015 (routage).

*Annotation du 9 novembre 2026, acceptation (décisions du mainteneur Q-R1 à Q-R8, `docs/revues/20261109-revue-claude-md.md`) : statut passé de `proposed` à `accepted`. Réserves du corps levées : point 1, `R/display_helpers.R` ajouté au champ `paths:` (Q-R3 (a)) ; point 3, règles du PDF dans « Documentation LaTeX » (Q-R5) ; point 6, volume d'environ 19 000 octets accepté au lieu de 16 000 (Q-R1 (a)), unité `wc -c` (Q-R6), `/doctor prompt-audit` lancé par le mainteneur sur le poste (Q-R7) ; point 7, consigne de lecture ajoutée à `regulatory.md` (Q-R4) ; point 8, skill `periode-gpt` (Q-R2 (a)) et ligne d'`AGENTS.md` insérée après la l. 18 (Q-R8). Mise en œuvre : `cf7ab2b` (`claude:`), `e94b2d1` (`docs:`) et `ab72921` (`claude:`, corrections de l'étape 1c), avec le présent commit `docs:` (retour arrière du § 10 de `docs/agents/routage.md`). Volumes mesurés sur les fichiers commités (`wc -l -c`) : `CLAUDE.md` 169 lignes, 19 357 octets (42 502 à `d5cdb51`) ; `.claude/rules/moteur.md` 30 lignes, 9 128 octets ; skill `periode-gpt` 23 lignes, 5 577 octets. Annexe A, lignes « Modèle et effort… », « Règle 9 » et « Règle 10 » : la procédure de retour arrière du § 10 de `docs/agents/routage.md` nomme aussi les efforts et modèles à l'appel portés par « Règle 9 » et « Règle 10 » (corrigé à l'étape 1c). La mesure du chargement de la règle à chemins (essais E1 à E5, `structure-cible.md` § 7) reste à faire dans une session neuve ; un échec rend son texte au socle (point 6), par une nouvelle annotation.*
