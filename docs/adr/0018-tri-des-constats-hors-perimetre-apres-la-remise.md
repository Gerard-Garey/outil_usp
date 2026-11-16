---
status: accepted
date: 2026-11-15
---

# Après la remise, seul un problème hors périmètre marquant devient une issue ; un mineur est écarté et tracé d'une ligne ; une issue gardée entre au plan par une règle d'insertion

> *Rédigé par l'agent architect (IA), soixante-troisième point d'étape, 15/11/2026, sur `main` `abc6ff1` (fusion de la PR #578, KR). ADR d'organisation (`docs/agents/routage.md`, § 3). **Le principe est décidé par le mainteneur le 15/11/2026** (Q-63-2, `docs/feuille-de-route.md`, § 4, ligne E-15/11 (63e point)) ; **la forme ci-dessous (critères écrits, qui décide, trace, règle d'insertion) est acceptée par le mainteneur le 15/11/2026** (Q-63-4 (a), `docs/feuille-de-route.md`, § 4, ligne E-15/11 (Q-63-3 à Q-63-12)) : statut `accepted`, même date.*

## Contexte

**Règle en vigueur jusqu'au 15/11/2026.** L'ADR 0007, point 3 : « Un problème hors périmètre devient une issue, pas une branche », sauf correctif rapide ; point 4 : création sur accord du mainteneur. Pendant un gel du code, la décision Q-48-9 (a) y ajoutait : tout défaut de code trouvé devient une issue. Aucun critère de gravité ne filtrait l'entrée.

**Ce que la règle a produit** (*vérifié* le 15/11/2026, `mcp__github__list_issues` et corps des issues) :

- quarante et une issues ouvertes à la fusion de la branche KR (passage de remise, PR #578, `abc6ff1`) ;
- la seule journée du 14/11/2026 en a créé douze (#579 à #590), toutes tirées des rapports de revue de KR. Selon la gravité que ces rapports leur donnent eux-mêmes, **deux sont majeures** (#579, cellule booléenne lue 1 par le chemin `openxlsx` ; #582, légende plotly qui masque le bas de l'histogramme bootstrap) et **dix sont mineures** (commentaires périmés, messages, libellés, chemins de sortie, formes de transcription) ;
- le document remis (`\versiondoc` 3.8) porte par ailleurs quinze mentions « travail postérieur à la remise » (*vérifié*, `grep`), que des issues ouvertes soldent une à une.

Le coût n'est pas la création d'une issue, mais sa suite : chaque issue appelle un rattachement au point d'étape, un circuit, un passage de vérificateur, souvent un passage de `docwriter`, et une ligne de fermeture. À douze issues par revue intégrale, la file croît plus vite que les branches ne la vident, et les deux constats majeurs se lisent au milieu de dix mineurs.

**Décision du mainteneur du 15/11/2026** (brief de la session principale, consignée telle quelle au § 4 de la feuille de route) :

1. *On entre dans la phase de correction après remise. Objectif : résoudre toutes les issues ouvertes aujourd'hui (41). Aucune n'est écartée d'office : chacune reçoit une branche (ou un correctif rapide) et un circuit* (Q-63-1).
2. *Issues futures (créées à partir d'aujourd'hui) : à chaque problème identifié, la session se demande s'il est gardé. Seuls les problèmes marquants sont gardés (bloquant ou majeur, ou effet sur σ_USP, un verdict, une p-value, la conformité réglementaire, une affirmation fausse de la documentation sur le code, la reproductibilité) et intégrés au plan (périmètre d'une branche à venir). Les mineurs sont écartés : pas d'issue (ou issue fermée `not planned`, libellé `wontfix`), mention d'une ligne dans le rapport de revue concerné. La dette peut remonter ; le plan doit prévoir comment absorber les issues gardées* (Q-63-2).

Le présent ADR donne à ce second point une forme durable. Il modifie la lecture du point 3 de l'ADR 0007 et le dit (annotation du 15/11/2026 de l'ADR 0007).

## Décision

### 1. Champ

La règle vaut pour tout **problème hors périmètre** constaté à partir du 15/11/2026 par un agent, une session, un workflow ou une revue.

Elle ne vaut pas :

- pour les **quarante et une issues ouvertes le 15/11/2026**, toutes rattachées au plan (Q-63-1) ;
- pour les constats qui portent sur **le diff de la branche en cours** : un constat bloquant ou majeur y renvoie à la réalisation (`CLAUDE.md`, « Sous-agents »), un mineur y est repris ou laissé par la décision de fin de branche du mainteneur, comme aujourd'hui ;
- pour la **veille réglementaire** (relecture datée de #463 et de #504 le jour de chaque PDF de fin de branche, Q-53-6 (a)), qui reste due quel qu'en soit le résultat.

### 2. Critères

Un problème est **marquant**, et donc gardé, s'il remplit **au moins un** des critères suivants. La liste est celle du mainteneur ; elle est fermée.

| Sigle | Critère | Précision |
|---|---|---|
| G | gravité **bloquante** ou **majeure** | sur l'échelle du vérificateur qui constate (`audit`, `app-review`, `regulatory`, `actuary`, `docwriter`) |
| E1 | effet sur **σ_USP** | valeur changée, rendue à tort, ou refusée à tort |
| E2 | effet sur un **verdict** | au sens de `CONTEXT.md` |
| E3 | effet sur une **p-value** | exacte, Monte-Carlo ou non simulée ; retenue ou seulement restituée |
| E4 | **conformité réglementaire** | écart au règlement délégué (UE) 2015/35, art. 218 à 220, annexes II, XIV et XVII : formule, paramètre, barème, exigence de données ; ou texte restitué qui prête au règlement ce qu'il ne dit pas |
| E5 | **affirmation fausse de la documentation sur le code** | `.tex` et PDF, `README.md`, textes restitués par le moteur ou l'application (`detail`, `reference`, motifs de refus, aides) : la documentation dit que le code fait une chose qu'il ne fait pas |
| E6 | **reproductibilité** | identité au bit près à graine égale, graines, références, comparateur et seuil, CI, critère de la batterie sous Windows |

Trois précisions de lecture :

- **L'effet se juge sur toute entrée admissible, pas sur les seuls six cas de référence.** Une valeur fausse acceptée sans message sur un fichier hors références remplit E1 (exemple : #579).
- **L'effet est montré, non supposé.** Le constat cite la mesure, la sonde ou le chemin de code qui l'établit. Un effet seulement concevable ne suffit pas ; s'il est plausible et non mesuré, la session obtient d'abord la mesure (`docs/agents/routage.md`, § 4.4).
- **Un commentaire du code périmé est mineur**, sauf s'il énonce une règle de calcul ou une disposition réglementaire que le code n'applique pas (E4 ou E5).

Est **mineur** tout le reste : forme du code, commentaire, libellé ou message sans affirmation fausse, confort de l'interface, performance, redondance de tests, forme d'un script hors CI, amélioration ou mesure facultative.

### 3. Qui décide

1. **L'agent qui constate rapporte tout.** Il ne filtre rien : pour chaque constat hors périmètre, il donne l'emplacement (`fichier:ligne` ou sortie), la gravité, le critère invoqué (G, E1 à E6, ou « aucun ») et la preuve. Le tri n'a jamais lieu en amont du rapport.
2. **La session principale applique le tri** et le présente au mainteneur dans son compte rendu, en deux listes : les problèmes **gardés**, chacun avec son issue rédigée ; les mineurs **écartés**, une ligne chacun.
3. **Le mainteneur décide.** La création d'une issue reste soumise à son accord (ADR 0007, point 4, inchangé). Il peut requalifier dans les deux sens.
4. **En cas de doute sur un fait** (gravité, existence de l'effet), le vérificateur du domaine le tranche : `audit` pour le code et la reproductibilité, `actuary` pour une p-value ou une méthode, `regulatory` pour la conformité, `app-review` pour l'affichage, `docwriter` pour la documentation. **Si le doute subsiste, le problème est présenté comme gardé.**

### 4. Trace

- **Mineur écarté** : une ligne dans le rapport de revue concerné, sous l'intitulé fixe **« Constats mineurs écartés (ADR 0018) »**, de la forme `emplacement — constat en une phrase — agent, date — aucun critère`. Le rapport est versé dans `docs/revues/<aaaammjj>-<objet>/` (Q-54-10). Sans rapport de revue (constat d'une session), la ligne va dans la PR de la branche de travail, sous le même intitulé.
- **Issue déjà créée puis jugée mineure** : fermée `not planned`, libellé `wontfix`, avec un commentaire qui cite la ligne du rapport.
- **Problème gardé** : issue rédigée dans le compte rendu, créée sur accord, corps citant le critère (G, E1 à E6) et la preuve.
- **Au point d'étape**, `architect` compte, par branche, les problèmes gardés et les mineurs écartés (§ 5 et § 6 de la feuille de route), et relit les lignes écartées de la période (`grep -rn "Constats mineurs écartés" docs/revues/`). **Un mineur relevé une seconde fois par une revue indépendante est réexaminé** et proposé à la garde.

### 5. Entrée au plan des issues gardées

Une issue gardée est rattachée par `architect` (mission de routine « rattacher les nouvelles issues », `docs/agents/routage.md`, § 3), selon l'ordre suivant :

1. **Urgente** — bloquante, ou σ_USP, verdict ou conformité faux sur une entrée admissible de l'état en service (dernière étiquette posée) : traitée avant tout le reste. Correctif rapide si elle en remplit les trois conditions (ADR 0007, point 3) ; sinon elle rejoint la branche en cours si elle touche le même module, ou devient la branche suivante. Dans les deux cas par décision expresse du mainteneur.
2. **Courante** — placée dans la première branche prévue qui touche le même module et dont le plan compte moins de cinq numéros (ADR 0007, annotation du 10/11/2026).
3. **À défaut**, placée dans un **créneau d'absorption** : une branche réservée par le plan après chaque bloc de branches, de cinq numéros au plus, sautée si elle est vide.
4. **Indicateur de dette**, relevé à chaque point d'étape : nombre d'issues gardées en attente et ancienneté de la plus ancienne. Au-delà de **cinq en attente**, ou si une issue gardée a attendu **plus de deux branches fusionnées**, `architect` propose d'avancer un créneau d'absorption devant la prochaine branche de moindre priorité (outillage, études, bibliographie).

### 6. Ce que la règle ne change pas

La création d'issue sur accord ; la définition du correctif rapide ; une seule branche de travail à la fois et le plafond indicatif de cinq numéros au plan ; le traitement des constats sur le diff de la branche ; la revue finale (règle 10) et les revues périodiques, qui continuent de tout relever ; l'approbation des changements de résultats.

## Options écartées

- **Statu quo** (tout problème hors périmètre devient une issue) : c'est la situation mesurée au § « Contexte ».
- **Filtre sur la seule gravité** (bloquant ou majeur) : il écarterait un écart de conformité jugé mineur par son auteur, ou une phrase fausse du `.tex` sans effet numérique. Or la traçabilité règlement ↔ documentation ↔ code est ce que le dossier doit montrer : les critères E4 et E5 gardent ces constats quelle que soit leur gravité.
- **Registre cumulatif des mineurs** (un fichier unique) : un second suivi d'issues, à tenir à jour et à relire. Le mainteneur demande une ligne dans le rapport concerné ; l'intitulé fixe suffit à les retrouver par `grep`.
- **Issue créée puis fermée `wontfix` pour chaque mineur** : trace dans GitHub, mais un numéro, une notification et un commentaire par constat. Gardé pour le seul cas d'une issue déjà créée.
- **Tri fait par l'agent qui constate** : un constat non rapporté ne peut plus être requalifié, et le vérificateur déciderait seul de ce que le mainteneur voit.

## Conséquences

- **`CLAUDE.md`, « Git et GitHub »** : la ligne « Un problème hors périmètre devient une issue » est à remplacer (texte proposé dans le retour d'`architect` du 15/11/2026). **Instruction du mainteneur donnée le 15/11/2026** (Q-63-4 (a)) : alignement par la session dans la branche S1 (`claude/lecteurs-contrat-ferme`), commit `claude:`.
- **Fiches d'agents** à aligner par un commit `claude:` dans S1 (Q-63-4 (a) ; puis `bash .claude/outils/fiches_jumelles.sh` pour les jumelles) : `app-review` et `regulatory` (« s'il y a des écarts, une issue proposée »), `docwriter` (défaut hors périmètre décrit au compte rendu), `audit`, `actuary`, `architect` : chaque constat hors périmètre porte gravité, critère et preuve.
- **`docs/agents/triage-labels.md`** : `wontfix` couvre aussi « mineur écarté selon l'ADR 0018 ».
- **Modèle de PR** (`.github/pull_request_template.md`) : une rubrique « Constats mineurs écartés (ADR 0018) » (commit `repo:` dans S1, Q-63-4 (a)).
- **`CONTEXT.md`** : entrées « Problème marquant » et « Constat mineur écarté », écrites par `architect` le 15/11/2026, à l'acceptation.
- **Feuille de route** : § 5, deux compteurs par point d'étape (gardés, écartés) et l'indicateur de dette ; § 3, créneaux d'absorption dans le plan de la phase.
- **Risque accepté** : un mineur écarté peut être le symptôme d'un défaut plus grave. Trois garde-fous le bornent : l'effet doit être cherché avant le classement (§ 2), le doute profite à la garde (§ 3), et la récurrence rouvre le constat (§ 4).
- **Retour arrière** : sur décision du mainteneur, statut `superseded` ou annotation datée ; le point 3 de l'ADR 0007 reprend alors sa lecture d'origine. Les lignes écartées restent dans les rapports versés et peuvent être reprises en issues.

## Renvois

- ADR 0007, points 3 et 4, et annotations du 10/11/2026 (plafond) et du 15/11/2026 (renvoi au présent ADR).
- `docs/feuille-de-route.md`, § 4 (E-15/11 (63e point) : Q-63-1, Q-63-2 ; E-15/11 (Q-63-3 à Q-63-12) : Q-63-4 (a)), § 5 (Q-63-4), § 3 (phase S, créneaux d'absorption).
- `docs/agents/routage.md`, § 3 (rattachement d'issues), § 4.4 (obtenir une preuve) ; `docs/agents/triage-labels.md`.
- Issues qui ont servi de mesure : #579 à #590 (revues de KR, PR #578).
