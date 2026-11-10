> *Rédigé par l'agent architect (IA), fiche `architect-approfondi`, étape 1a de la branche K5 (#515), le 09/11/2026. Base : `CLAUDE.md` à la tête `d5cdb51` (139 lignes, 42 502 octets).*

# Tableau « règle → emplacement » de `CLAUDE.md` (#515, étape 1a)

## Conventions

- **Une ligne par règle** de l'actuel `CLAUDE.md` (tête `d5cdb51`). Un paragraphe qui porte plusieurs règles est découpé : une ligne par règle, numérotée par section (`CTX`, `CMD`, `GIT`, `GPT`, `ARC`, `FLX`, `STR`, `REP`, `DOC`, `RIG`, `SA`, `SK`).
- **Ligne d'origine** : numéro de ligne dans `CLAUDE.md` à `d5cdb51`.
- **Emplacement cible** :
  - **socle** : nouveau `CLAUDE.md`, chargé en permanence par la session et par chaque sous-agent personnalisé ; la section est nommée quand elle change ;
  - **règle** : `.claude/rules/moteur.md`, à champ `paths:` (chargée quand un fichier correspondant est lu ou écrit, voir `structure-cible.md`) ;
  - **skill `periode-gpt`** : `.claude/skills/periode-gpt/SKILL.md`, à créer (question Q-R2 de la synthèse ; variante : `docs/agents/periode-gpt.md`) ;
  - **document existant** : il porte déjà la règle (vérifié par lecture, référence donnée), et le socle y renvoie.
- **Forme** : **gardée** (texte inchangé, éventuellement découpé en lignes) ; **condensée** (même règle, formulation plus courte, sans historique) ; **renvoi** (la règle n'est plus écrite dans le socle, qui renvoie au document cible) ; **historique** (date, PR, incident : ce n'est pas une règle, la trace est conservée ailleurs).
- **Volumes** mesurés en octets par `wc -c` (convention de l'issue #515, dont les « 42 502 caractères » sont des octets ; `LC_ALL=C.UTF-8 wc -m CLAUDE.md` donne 41 403 caractères). Découpage par section : `awk` sur les lignes de titre (`/^#/`), octets de chaque ligne + saut de ligne. Le volume « après » est celui du projet de socle de `structure-cible.md`, annexe A, mesuré de la même façon.

## Volumes par section

| Section (titre à `d5cdb51`) | Lignes avant | Octets avant | Octets après (socle) | Ce qui sort, et où |
|---|---:|---:|---:|---|
| préambule (`# CLAUDE.md` et phrase d'usage) | 4 | 117 | 314 (dont 196 de commentaire HTML, retiré avant injection) | — |
| « Contexte » | 8 | 2 371 | 1 137 | PDF de fin de branche → « Documentation LaTeX » (socle) ; date de publication du dépôt (historique) |
| « Commandes » | 8 | 2 114 | 936 | emplacements Windows de R → en-tête de `.claude/hooks/preparer_r.sh` ; `generer_valeurs_externes.R` → règle |
| « Git et GitHub » | 15 | 8 099 | 3 940 | historique → ADR 0007 et annotations ; détail des branches de régénération et de sauvegarde → skill `verifier-reproductibilite`, ADR 0007 |
| « ChatGPT (Codex) et la branche `main-GPT` » | 9 | 4 243 | 811 | procédures de période → skill `periode-gpt` ; audit → skill `audit-main-gpt` (existante) |
| « Architecture (contrainte impérative) » (tête) | 11 | 1 880 | 1 798 | rien (tête intégrale, Fable n° 2) |
| « Flux du moteur » | 10 | 1 663 | 905 | détail des sources des annexes (M6, neuf écarts-types, barèmes ▼B) → règle |
| « Structure d'un résultat de test » | 4 | 3 785 | 433 | texte intégral → règle |
| « Reproductibilité » | 4 | 3 568 | 396 | texte intégral → règle |
| « Documentation LaTeX » | 4 | 1 090 | 1 280 | reçoit le PDF de fin de branche venu de « Contexte » |
| « Rigueur statistique » | 8 | 737 | 737 | rien |
| « Sous-agents » | 41 | 12 333 | 5 541 | détail du routage → `docs/agents/routage.md` (§ 2 à § 10) ; huit principes et statuts des workflows → ADR 0010 (et ADR 0015, point 8) |
| « Agent skills » (trois sous-sections) | 13 | 502 | 502 | rien |
| **Total** | **139** | **42 502** | **19 034** (18 838 hors commentaire HTML ; 18 529 caractères, `wc -m`) | règle `.claude/rules/moteur.md` ≈ 8 700 octets ; skill `periode-gpt` ≈ 3 800 octets |

Lecture : le socle passe de 42 502 à environ 19 000 octets (− 55 %), soit environ 235 lignes de 80 caractères, pour 169 lignes réelles. La cible décidée (≈ 16 000) n'est pas atteinte : écart et options en question Q-R1 de la synthèse.

## Correspondance règle par règle

### Préambule (l. 1-3)

| N° | Règle (citation courte) | L. | Emplacement cible | Forme |
|---|---|---|---|---|
| P-1 | « This file provides guidance to Claude Code… » | 3 | socle, préambule | gardée |

### « Contexte » (l. 5-11)

| N° | Règle (citation courte) | L. | Emplacement cible | Forme |
|---|---|---|---|---|
| CTX-1 | « Outil de calibrage des paramètres propres à l'entreprise (USP), Solvabilité II, règlement délégué (UE) 2015/35, art. 218-220 et annexe XVII » | 7 | socle, « Contexte » | gardée |
| CTX-2 | textes sources versionnés à la racine (`Règlement délégué.pdf`, JOUE L 12 du 17.1.2015 ; XHTML consolidé du 14.11.2024) | 7 | socle, « Contexte » | condensée (noms de fichiers gardés) |
| CTX-3 | « C'est la version consolidée que l'outil retient comme référence de lecture » ; sans effet juridique propre ; font foi les versions du JOUE | 7 | socle, « Contexte » | gardée |
| CTX-4 | la MSEP de l'annexe XVII D(5) diffère de 2015, acte correcteur non identifié, ADR 0005 | 7 | socle, « Contexte » | condensée |
| CTX-5 | « Les formules sont des images […] : les lire en rendu graphique, jamais par extraction de texte » (#7) | 7 | socle, « Contexte » | gardée |
| CTX-6 | « Les fichiers de données `usp_*.csv/.xlsx` ne sont pas versionnés » | 7 | socle, « Contexte » | gardée |
| CTX-7 | dépôt de référence `Gerard-Garey/outil_usp`, employé en local et en session cloud | 9 | socle, « Contexte » | condensée |
| CTX-7h | « public depuis le 28/09/2026, PR #137 » | 9 | historique : PR #137, `docs/feuille-de-route.md` | historique |
| CTX-8 | PDF compilé versionné, « commité une fois par branche, en fin de branche » (ADR 0008 amendé, M37) | 9 | socle, « Documentation LaTeX » | condensée |
| CTX-9 | « chaque commit qui touche le `.tex` compile pour contrôle sans indexer le PDF » | 9 | socle, « Documentation LaTeX » | gardée |
| CTX-10 | commit `docs:` du PDF seul, par la session principale, après le dernier commit du `.tex`, juste avant la sortie du brouillon | 9 | socle, « Documentation LaTeX » | gardée |
| CTX-11 | intégration de `main` sans recompilation ; conflit sur le PDF : garder la version de la branche qui reçoit | 9 | socle, « Documentation LaTeX » | gardée |
| CTX-12 | branche qui ne touche pas le `.tex` : pas de commit de PDF | 9 | socle, « Documentation LaTeX » | gardée |
| CTX-13 | skill `compiler-doc`, poste local et cloud | 9 | socle, « Commandes » (CMD-10) | condensée |
| CTX-14 | job de CI : sur toute PR non brouillon, le PDF suit le `.tex` | 9 | socle, « Documentation LaTeX » | condensée |
| CTX-15 | livrables ACPR : « la traçabilité entre documentation LaTeX, code R et résultats prime sur tout le reste » | 9 | socle, « Contexte » | gardée |
| CTX-16 | `docs/exigences.md`, cahier des charges : « le lire avant toute évolution méthodologique ou de l'interface » | 9 | socle, « Contexte » | gardée |
| CTX-17 | « Taille d'échantillon d'intérêt : **T = 8** » ; toute conclusion en tient compte | 11 | socle, « Contexte » | gardée |

### « Commandes » (l. 13-19)

| N° | Règle (citation courte) | L. | Emplacement cible | Forme |
|---|---|---|---|---|
| CMD-1 | commandes, prérequis, structure : `README.md`, sections nommées ; « s'y reporter plutôt que de les recopier » | 15 | socle, « Commandes » | condensée (sections gardées) |
| CMD-2 | batteries sous `LC_ALL=C.UTF-8` en session Linux (#113) | 15 | socle, « Commandes » | gardée |
| CMD-3 | le hook `SessionStart` rend `Rscript` disponible (PATH Windows, apt dans le cloud) | 17 | socle, « Commandes » | condensée |
| CMD-4 | emplacements cherchés sous Windows (`C:\Program Files\R`, installation utilisateur, `C:\R`, `\R\R-4.3.3`), R 4.3.x préférée, Q-E1f-8 ; la CI reste en R 4.3.1 | 17 | `.claude/hooks/preparer_r.sh`, en-tête (l. 25-29, porte déjà Q-E1f-8 et la préférence 4.3.x) ; ADR 0011 (R 4.3.1) | renvoi |
| CMD-5 | « S'il signale un échec, les commandes R ne peuvent pas tourner » | 17 | socle, « Commandes » | gardée |
| CMD-6 | défaut connu codé en échec attendu (`echec_attendu()`, renvoi à l'issue) | 19 | socle, « Commandes » | condensée |
| CMD-7 | règle stricte : succès inattendu fait échouer la batterie ; retirer la marque une fois le défaut corrigé | 19 | socle, « Commandes » | condensée |
| CMD-8 | `tests/unitaires/generer_valeurs_externes.R`, hors CI, recalcule les références externes (lmtest, tseries, car, ChainLadder) | 19 | règle | gardée |
| CMD-9 | après une modification du moteur ou des tests en échec : skill `verifier-reproductibilite` (tableau avant / après ; régénération par la CI, ADR 0011) | 19 | socle, « Commandes » | condensée (détail dans la skill) |
| CMD-10 | après une modification du `.tex` : skill `compiler-doc` | 19 | socle, « Commandes » | gardée |
| CMD-11 | point isolé : appel direct après `source("R/charger_moteur.R"); charger_moteur()` (environnement `usp_moteur`, ADR 0016) | 19 | socle, « Commandes » | condensée |
| CMD-12 | `source("R/engine.R")` admis en session vierge ou pour lire, « jamais pour un chiffre destiné au dossier » | 19 | socle, « Commandes » | condensée |

### « Git et GitHub » (l. 21-34)

| N° | Règle (citation courte) | L. | Emplacement cible | Forme |
|---|---|---|---|---|
| GIT-1 | « Aucun push direct sur `main` » : branche, PR, fusion par le mainteneur, commit de fusion jamais squash ni rebase, CI verte | 23 | socle | gardée |
| GIT-2 | « Seule exception : une instruction explicite du mainteneur pour un push donné » | 23 | socle | gardée |
| GIT-3 | « Une seule branche de travail à la fois », périmètre fermé fixé par le plan d'`architect`, PR brouillon dès la création | 24 | socle (intitulé gardé, cité par ADR 0007 l. 101) | gardée |
| GIT-4 | toute session se place sur la branche de travail courante et y pousse | 24 | socle | gardée |
| GIT-5 | branche de travail parallèle sur décision expresse du mainteneur seulement, traits bornants de sa décision (E2 réduite, annotation du 05/10/2026) | 24 | socle (règle) ; ADR 0007, annotation du 05/10/2026 (détail, premier cas) | condensée |
| GIT-6 | aucune session, aucun agent ni aucun workflow ne crée de sa propre initiative une branche de travail ou une PR de plus | 24 | socle | gardée |
| GIT-7 | « aucune branche de travail parallèle ne se propose plus » (après Fd et Fh ∥ Fi ; 15/10/2026) | 24 | socle (« nouvelle exception à l'initiative du mainteneur seulement ») ; ADR 0007, annotation du 15/10/2026 | condensée |
| GIT-8 | branche éphémère `claude/regeneration-<issue>` : depuis la tête de la branche de travail, un commit (plus un par correction), aucune PR, jamais fusionnée, supprimée après l'artefact vérifié et le commit unique code + `.rds` (M30) | 24 | socle (existence et bornes : sans PR ni fusion) ; skill `verifier-reproductibilite`, l. 29-34 (procédure) ; ADR 0011 amendé | condensée |
| GIT-9 | branche de sauvegarde `claude/sauvegarde-<issue>` : sur décision du mainteneur consignée dans la fiche, depuis le commit mesuré poussé, sorties brutes et journal seulement, aucune PR, écrite par la session seule, supprimée après le commit des sorties et la CI verte (M42) | 24 | socle (existence, décision du mainteneur, sans PR ni fusion) ; ADR 0007, annotation du 09/10/2026 (détail) | condensée |
| GIT-10 | branches de Claude bornées à la période GPT : `claude/ouverture-main-gpt-<date>`, résolution de conflit d'intégration, `claude/regeneration-gpt-<issue>`, `claude/audit-main-gpt-<date>` | 24 | socle (renvoi) ; skill `periode-gpt` ; ADR 0007, annotation du 29/09/2026 | renvoi |
| GIT-10h | « décision du 29/09/2026 […] à reporter dans l'ADR » | 24 | historique : déjà reportée (ADR 0007, annotation du 29 septembre 2026, l. 67) ; la mention « à reporter » est caduque | historique |
| GIT-11 | « Session cloud : la branche de travail l'emporte sur la branche assignée » ; consigne de démarrage écartée sans autre autorisation | 25 | socle (intitulé gardé, cité par ADR 0007 l. 101) | gardée |
| GIT-12 | identification de la branche de travail avant toute écriture : brief ou mainteneur ; à défaut, seule PR brouillon `claude/…` vers `main` ; sinon feuille de route | 25 | socle | gardée |
| GIT-13 | plusieurs PR brouillon `claude/…` : seule la désignation explicite vaut ; à défaut, s'arrêter et demander, sans écrire | 25 | socle | gardée |
| GIT-14 | `git fetch origin <branche>`, `git checkout -B <branche> origin/<branche>`, `git push -u origin <branche>` | 25 | socle | gardée |
| GIT-15 | supprimer la branche assignée (`git branch -D` ; `git push origin --delete` si poussée) | 25 | socle | gardée |
| GIT-16 | aucune branche de travail ouverte : demander au mainteneur | 25 | socle | gardée |
| GIT-17 | « Corps de PR : un `Closes #N` par ligne », un par issue, jamais une liste | 26 | socle | gardée |
| GIT-17h | motif : PR #81, sept issues restées ouvertes (Q-E10, ADR 0007 point 1) | 26 | ADR 0007, point 1 et annotation du 30/09/2026 | historique |
| GIT-18 | vérifier, cinq minutes après la fusion, que chaque issue annoncée est fermée | 26 | socle | gardée |
| GIT-18h | motif : PR #163, quatre issues restées ouvertes | 26 | ADR 0007, annotation du 30/09/2026 (l. 82-84) | historique |
| GIT-19 | issue liée encore ouverte : fermée à la main (`completed`), commentaire citant la PR et le commit de fusion | 26 | socle | gardée |
| GIT-20 | incident consigné avec horodatages dans la ligne du § 6 de la feuille de route | 26 | socle | condensée |
| GIT-21 | « Aucun mot-clé de fermeture hors des lignes `Closes #N` du corps de PR », ni commit, ni prose, même entre guillemets ou en code | 27 | socle (titre « Git et GitHub » gardé : cité par `.github/scripts/controle_mots_cles_fermeture.sh` l. 3 et 133) | gardée |
| GIT-22 | mots-clés visés : Close, Closes, Closed, Fix, Fixes, Fixed, Resolve, Resolves, Resolved, suivis d'un numéro | 27 | socle | gardée |
| GIT-23 | ailleurs, écrire « Refs #N » ou « fermeture de #N » | 27 | socle | gardée |
| GIT-23h | motif : issue fermée à tort à la fusion de la PR #400 | 27 | ADR 0007, annotation du 31/10/2026 (Q-45-12, l. 296-301) | historique |
| GIT-24 | quand un `Closes` devient `Refs` : chercher le motif dans `git log main..HEAD --format=%B` et dans le corps de PR avant la sortie du brouillon | 27 | socle | gardée |
| GIT-25 | commit fautif : jamais réécrit ; issue rouverte après la fusion, avec un commentaire | 27 | socle | condensée |
| GIT-25h | « contrôle de CI proposé dans #407 » | 27 | historique caduc : le contrôle existe (`.github/workflows/mots-cles-fermeture.yml`, en-tête « Issue #407 ») | historique |
| GIT-26 | « Aucune réécriture de commit » (`--amend`, `rebase`, `reset` d'un commit fait), même avant le push ; correction = nouveau commit | 28 | socle | gardée |
| GIT-26h | décision du 28/10/2026 (Q-43-13) après l'`--amend` de `docwriter` sur `50180d1` | 28 | socle (identifiant Q-43-13 gardé) ; ADR 0007 (Q-43-13, l. 301) ; fiche `docwriter.md` l. 64 | historique |
| GIT-27 | « Un commit par issue qui change un résultat », tableau avant / après et visa | 29 | socle | gardée |
| GIT-28 | « Un problème hors périmètre devient une issue », pas une branche | 30 | socle | gardée |
| GIT-29 | correctif rapide : références identiques, un seul domaine, pas de `.tex` ; branche temporaire de `main`, PR directe vers `main` | 30 | socle | gardée |
| GIT-30 | « Création d'issue sur accord du mainteneur » ; sauf autorisation explicite du brief | 31 | socle (intitulé cité par les fiches `architect`, `actuary`, `app-review`, `regulatory`) | gardée |
| GIT-31 | handoff demandé par le mainteneur : commentaire de la PR de la branche de travail, ni fichier ni réponse seule | 32 | socle | condensée |
| GIT-32 | le handoff cite en tête les identifiants des commentaires qu'il remplace | 32 | socle | gardée |
| GIT-33 | sans PR ouverte : demander où déposer le handoff, sans rien écrire avant la réponse | 32 | socle | gardée |
| GIT-34 | messages de commit en français, avec accents, préfixés par domaine (six domaines et leurs périmètres) | 33 | socle | gardée |
| GIT-35 | renvoyer à l'issue concernée (`#3`) | 33 | socle | gardée |
| GIT-36 | auteur des commits de Claude : `Claude <noreply@anthropic.com>` par `git config` dans le dépôt ; jamais l'identité du mainteneur ni `-c user.name=…` | 34 | socle | gardée |
| GIT-37 | pied de message : `Co-Authored-By` et, en session cloud, `Claude-Session` | 34 | socle | gardée |
| GIT-37h | décision du mainteneur du 24/09/2026 ; commits antérieurs non réécrits | 34 | ADR 0017, annexe B (aucun autre support que `CLAUDE.md` ; `README.md` l. 236 porte la règle sans la date) | historique |

### « ChatGPT (Codex) et la branche `main-GPT` » (l. 36-43)

| N° | Règle (citation courte) | L. | Emplacement cible | Forme |
|---|---|---|---|---|
| GPT-1 | ChatGPT intervient par périodes ; Claude contributeur principal ; règles dans `AGENTS.md` et `.codex/` ; décision ADR 0012 | 38 | socle (titre gardé, cité par ADR 0012) | condensée |
| GPT-2 | « Périmètres séparés » : Claude, ses agents et ses workflows ne lisent ni n'appliquent `AGENTS.md`, `.codex/`, `docs/feuille-de-route-gpt.md`, livrables GPT, sauf audit ordonné, ouverture ou fermeture de période, fermeture M30 déléguée | 40 | socle | condensée (exceptions gardées) |
| GPT-3 | « réciproquement, `AGENTS.md` interdit à GPT de lire `.claude/` et les sections de processus » | 40 | skill `periode-gpt` (avec l'exception `.claude/rules/moteur.md`, Q-56-12 (a)) | renvoi |
| GPT-4 | Claude ne modifie `AGENTS.md` et `.codex/` que sur instruction du mainteneur (domaine `claude:`) | 40 | socle | gardée |
| GPT-5 | `main-GPT`, `main` parallèle de GPT, reçoit les PR de ses branches, supprimée après sa fusion dans `main` | 41 | skill `periode-gpt` | gardée |
| GPT-6 | ouverture de période par Claude sur ordre du mainteneur, lot fixé dans la fiche « période GPT » ; création de `main-GPT` ; branche d'ouverture, commit `docs:` unique de copie de la feuille de route (SHA cité), PR vers `main-GPT`, puis PR de période brouillon | 41 | skill `periode-gpt` ; socle : « actes de période sur ordre du mainteneur » | renvoi |
| GPT-7 | intégration de `main` : « Update branch » du mainteneur, ou PR `main` → `main-GPT` ouverte par Claude ; conflit résolu sur une branche partie de `main-GPT` | 41 | skill `periode-gpt` | renvoi |
| GPT-8 | fermeture M30 déléguée : sur ordre, vérifications (a′)-(c) et commit unique code + `.rds` sur `claude/regeneration-gpt-<issue>`, PR vers la branche GPT, skill `verifier-reproductibilite` | 41 | skill `periode-gpt` ; ADR 0007 annotation du 29/09/2026 ; ADR 0012 | renvoi |
| GPT-9 | « Hors de ces actes et de l'audit, une session de Claude n'écrit jamais sur `main-GPT` ni sur une branche `gpt/…` » | 41 | socle | gardée |
| GPT-10 | audit de `main-GPT` lancé par le mainteneur seul, jamais d'office ; skill `audit-main-gpt` | 42 | socle | gardée |
| GPT-11 | objet de l'audit : diff `main...main-GPT`, issues déclarées résolues, issues créées (libellé `gpt`), chacune revue par l'agent que son objet désigne | 42 | skill `audit-main-gpt` (l. 8, 35, 57) | renvoi |
| GPT-12 | agents selon les déclencheurs, `architect` et `actuary` compris | 42 | skill `audit-main-gpt` (l. 43, 50) | renvoi |
| GPT-13 | audit plus exigeant qu'une revue finale ; aucune affirmation de GPT présumée vraie, tout remesuré | 42 | skill `audit-main-gpt` (l. 20, 43) | renvoi |
| GPT-14 | simplifier et optimiser le code de GPT | 42 | skill `audit-main-gpt` (l. 3, 76) | renvoi |
| GPT-15 | modifications par `claude/audit-main-gpt-<date>` depuis `main-GPT`, PR vers `main-GPT` | 42 | skill `audit-main-gpt` (l. 48) | renvoi |
| GPT-16 | la branche d'audit supprime `docs/feuille-de-route-gpt.md` ; `architect` tire le bilan, reporté dans `docs/feuille-de-route.md` | 42 | skill `audit-main-gpt` (l. 78, 103) | renvoi |
| GPT-17 | Claude valide la PR de période ; la fusion reste au mainteneur | 42 | skill `audit-main-gpt` ; skill `periode-gpt` | renvoi |
| GPT-18 | conflit de fond entre `main-GPT` et une décision prise sur `main` : `main` l'emporte | 43 | socle | gardée |

### « Architecture (contrainte impérative) », tête (l. 45-54)

| N° | Règle (citation courte) | L. | Emplacement cible | Forme |
|---|---|---|---|---|
| ARC-1 | séparation stricte moteur / affichage, exigée par `docs/exigences.md` pour la revue indépendante d'un fichier quantitatif unique | 47 | socle | gardée |
| ARC-2 | `R/engine.R` contient **toute** la logique quantitative (liste) | 49 | socle | gardée |
| ARC-3 | moteur utilisable sans Shiny et sans dépendance obligatoire hors R base + stats | 49 | socle | gardée |
| ARC-4 | seule exception : xlsx par `openxlsx` s'il est installé, avec repli interne ; calculs indépendants | 49 | socle | gardée |
| ARC-5 | « Ne jamais éclater le moteur en plusieurs fichiers » | 49 | socle | gardée |
| ARC-6 | `R/charger_moteur.R`, chargeur unique, environnement `usp_moteur`, copie exposée ; app et tests chargent par lui ; substitution de test dans `environment(run_engine)` (ADR 0016, #200) | 50 | socle | gardée (découpée en deux lignes) |
| ARC-7 | `R/display_helpers.R` : formatage, badges, tables, tracés à partir de `res$plots_data` ; aucun calcul | 51 | socle | gardée |
| ARC-8 | `app.R` : UI, saisie, `run_engine()` uniquement sur clic de « Relancer les calculs », stockage, affichage ; aucun calcul | 52 | socle | gardée |
| ARC-9 | tout contrôle de saisie à sens métier existe aussi dans le moteur (`engine_valider_donnees()`, `mw_valider_triangle()`) | 52 | socle | gardée |
| ARC-10 | « Si un résultat peut être calculé indépendamment de l'interface, il va dans `engine.R` » | 54 | socle | gardée |

### « Flux du moteur » (l. 56-64)

| N° | Règle (citation courte) | L. | Emplacement cible | Forme |
|---|---|---|---|---|
| FLX-1 | `run_engine()`, point d'entrée unique, objet `usp_engine` ; données invalides : `ok = FALSE` avec `validation`, sans erreur | 58 | socle | gardée |
| FLX-2 | branche lognormale : `usp_ajuster()` → `usp_bootstrap()` → `usp_parametre()` (correction √((T+1)/(T−1)), crédibilité, mélange) → `usp_tests()` | 61 | socle | condensée (chaîne gardée) |
| FLX-3 | branche Merz-Wüthrich : `.run_engine_mw()` → `mw_ajuster()`, `mw_msep()`, `mw_bootstrap()`, `mw_parametre()`, `mw_tests()` | 62 | socle | gardée |
| FLX-4 | données réglementaires en tête d'`engine.R` : `ANNEXE_II`, `ANNEXE_XIV`, `SEGMENTS`, `CRED_LONG`, `CRED_COURT` (nombre de segments, clé, partage des barèmes) | 64 | socle (noms) ; règle (nombre de segments, clé `annexe-segment`, segments de `CRED_LONG` et de `CRED_COURT`) | condensée |
| FLX-5 | annexes II et XIV vérifiées contre la version consolidée (▼M6, règlement délégué (UE) 2019/981 ; neuf écarts-types diffèrent de 2015, non conservés) ; barèmes contre le JOUE de 2015 (▼B) | 64 | règle | gardée |
| FLX-6 | l'outil ne vaut que pour une date de référence postérieure ou égale à l'application de M6 (#19) | 64 | socle | condensée |
| FLX-7 | « ne pas les modifier sans source » | 64 | socle | gardée |

### « Structure d'un résultat de test » (l. 66-68)

Le texte de la l. 68 passe **intégralement** dans la règle (forme : gardée, découpée une idée par ligne). Le socle garde le titre et deux lignes de résumé (STR-R1, STR-R2).

| N° | Règle (citation courte) | L. | Emplacement cible | Forme |
|---|---|---|---|---|
| STR-1 | chaque test enregistré par `add()` d'`engine_registre_tests()`, partagée par les deux méthodes (#41) | 68 | règle ; résumé socle (STR-R1) | gardée |
| STR-2 | séparation stricte `stat` (loi de référence) / `estim` (grandeur descriptive) | 68 | règle ; résumé socle | gardée |
| STR-3 | trois p-values `p_exacte`, `p_asymptotique`, `p_mc` ; `err_mc` | 68 | règle ; résumé socle | gardée |
| STR-4 | cinq champs finaux, dans cet ordre, posés par `add()` seul ; `p_min` (#44) | 68 | règle | gardée |
| STR-5 | `fonction` : argument obligatoire, refusé s'il ne désigne pas une fonction de l'environnement du moteur (#111) | 68 | règle | gardée |
| STR-6 | `inoperant` : `TRUE` si et seulement si R1 a basculé la ligne, jamais `NA` ; l'affichage lit ce champ, jamais le préfixe « TEST INOPERANT » (#129) | 68 | règle ; principe dans le socle (STR-R2) | gardée |
| STR-7 | `p_min_mc` : plancher Monte-Carlo, 13 statistiques discrètes (champ `extremes`), aussi dans `bootstrap$p_min_mc` (#125) | 68 | règle (« 13 statistiques discrètes » cité par ADR 0007 l. 267 : voir ADR 0017) | gardée |
| STR-8 | `mc_nom` (#330), lu par `granularite_lignes()` et la p-value de famille de #297 | 68 | règle | gardée |
| STR-9 | ADR 0003, annotations du 02/10, du 12/10 et du 25/10/2026 | 68 | règle | gardée |
| STR-10 | statistiques Monte-Carlo, sens de rejet et `engine_p_mc()` déclarés dans `USP_CATALOGUE_MC` et `MW_CATALOGUE_MC` ; `mc_nom` absent du catalogue : erreur | 68 | règle | gardée |
| STR-11 | hiérarchie **exacte > Monte-Carlo > p non simulée** ; `nature_p` la documente | 68 | règle ; résumé socle (STR-R1) | gardée |
| STR-12 | p non simulée retenue seulement sur une ligne sans p Monte-Carlo prévue ; p Monte-Carlo manquante : diagnostic (#181) ; `add()` refuse une p Monte-Carlo absente sans motif | 68 | règle | gardée |
| STR-13 | grandeur rivée : aucune p-value retenue (`p_retenue = NA`, INFO) ; repli sur la loi nominale interdit (ADR 0001) ; la hiérarchie ne se lit pas à l'envers | 68 | règle ; résumé socle (STR-R1 : « jamais lue à l'envers ») | gardée |
| STR-14 | le `detail` n'imprime aucun nombre issu du bootstrap (#76), sauf les trois gabarits de #204 (`.mw_phrase_b_effectif()`) et les deux phrases fixes de #257 ; phrase fixe de #244 en fin | 68 | règle | gardée |
| STR-15 | préfixe de `famille` (`B.`…`G.`, `M1`…`M6`) regroupé dans `GROUPES` de `display_helpers.R` ; tout nouveau préfixe y être déclaré | 68 | règle ; principe dans le socle (STR-R2) | gardée |
| STR-16 | `engine_table_tests()` aplatit les résultats en data.frame auditable | 68 | règle | gardée |
| STR-R1 | (nouveau, résumé) `add()`, `stat` / `estim`, trois p-values, cinq champs ; hiérarchie jamais lue à l'envers | — | socle, « Structure d'un résultat de test » | résumé + renvoi |
| STR-R2 | (nouveau, résumé) l'affichage lit les champs, jamais le texte du `detail` ; nouveau préfixe déclaré dans `GROUPES` | — | socle, « Structure d'un résultat de test » | résumé + renvoi |

### « Reproductibilité » (l. 70-72)

Le texte de la l. 72 passe **intégralement** dans la règle. Le socle garde le titre, deux lignes de résumé et les deux interdictions que seule la consigne fait respecter (REP-4, REP-10).

| N° | Règle (citation courte) | L. | Emplacement cible | Forme |
|---|---|---|---|---|
| REP-1 | objets identiques au bit près sur une même machine (volet `identical()` de `tests/test_reproductibilite.R`) | 72 | règle ; résumé socle | gardée |
| REP-2 | comparaison aux références par `comparer_objets()` seul, valeur par valeur, `TOLERANCE` = 1e-6 relative ou absolue ; dérive mesurée et seuil (M9, ADR 0006) | 72 | règle ; résumé socle (1e-6) | gardée |
| REP-3 | références produites par la CI (`references.yml`, `ubuntu-22.04`, R 4.3.1, BLAS et LAPACK de référence monothread, M34), déclenchée par la session sur ordre du mainteneur (ADR 0011, #67) | 72 | règle | gardée |
| REP-4 | aucune régénération hors de la CI, poste du mainteneur compris ; régénération ordinaire en mode `regeneration` ; patch chirurgical (`tests/patcher_reference.R`) pour les seuls changements non numériques | 72 | socle (interdiction et patch nommés) ; règle (intégral) | condensée |
| REP-5 | toute modification qui change un résultat est identifiée, quantifiée et expliquée | 72 | socle | gardée |
| REP-6 | tout tirage par `engine_sous_graine(seed, expr)`, générateur `ENGINE_RNG_KIND`, restauration de l'état de l'appelant (#42, #37) | 72 | socle (principe) ; règle (détail) | condensée |
| REP-7 | liste des sources d'aléa et de leurs graines (`usp_bootstrap()`, `mw_bootstrap()` et retrait des triangles, `usp_lr_delta()`, `usp_permutation_pente()`, flux complémentaire du régime, `sw_loi_nulle()`) | 72 | règle | gardée |
| REP-8 | générateur et graines consignés dans `res$metadata` | 72 | règle | gardée |
| REP-9 | l'enveloppe du QQ-plot ne tire plus (#47) | 72 | règle | gardée |
| REP-10 | « Ne pas ajouter d'autre source d'aléa sans passer par `engine_sous_graine()` avec une graine explicite » | 72 | socle ; règle | gardée |

### « Documentation LaTeX » (l. 74-76)

| N° | Règle (citation courte) | L. | Emplacement cible | Forme |
|---|---|---|---|---|
| DOC-1 | document unique (~20 500 lignes), synchronisé avec le code : `\code{}`, liste exacte des tests, méthode de chaque p-value | 76 | socle | gardée |
| DOC-2 | sections clés (architecture et index, « Nature des p-values et validité à T = 8 », tableaux 1 et 2, H1-H4, M1-M6) | 76 | socle | condensée |
| DOC-3 | bibliographie manuelle (`\label{sec:biblio}`), sans BibTeX | 76 | socle | gardée |
| DOC-4 | toute modification du `.tex` respecte `docs/latex/CONVENTIONS.md` (liste) | 76 | socle | gardée |
| DOC-5 | vie du dépôt et détail sorti par la grille → `docs/suivi-documentation/`, sous le `\label` d'origine | 76 | socle | gardée |
| DOC-6 | texte et commentaires en français ; commentaires du code R en français sans accents | 76 | socle | gardée |

### « Rigueur statistique » (l. 78-84)

| N° | Règle (citation courte) | L. | Emplacement cible | Forme |
|---|---|---|---|---|
| RIG-1 | « Ne jamais confondre : résultat exact / asymptotique / approximation numérique / comportement observé par simulation » | 80 | socle | gardée |
| RIG-2 | erreur Monte-Carlo (B) ≠ erreur d'approximation statistique (T) | 81 | socle | gardée |
| RIG-3 | loi asymptotique ou défaut d'une fonction R : pas une justification à T = 8 | 82 | socle | gardée |
| RIG-4 | ne fabriquer aucune référence, théorème, page ni vitesse ; si la littérature ne conclut pas à T = 8, l'écrire | 83 | socle | gardée |
| RIG-5 | faire évoluer les livrables ; jamais de remplacement silencieux de méthode ni de formule corrigée réintroduite | 84 | socle | gardée |

### « Sous-agents » (l. 86-125)

| N° | Règle (citation courte) | L. | Emplacement cible | Forme |
|---|---|---|---|---|
| SA-1 | sept sous-agents, dix fiches (`architect`, `actuary`, `coder` dédoublés), orchestrés par la session | 88 | socle (décompte des fiches gardé : cité par `routage.md` § 10) | gardée |
| SA-2 | « ceux qui écrivent ne vérifient pas, ceux qui vérifient n'écrivent pas » | 88 | socle | gardée |
| SA-3 | tableau des sept agents (famille, écrit, question) | 90-98 | socle | gardée |
| SA-4 | **Déclencheurs** (architect, actuary, regulatory, audit, app-review, docwriter) | 100 | socle | gardée |
| SA-5 | `architect` et `actuary` : fiche de base Opus `medium` (routine), `-approfondi` Opus `high` (jugement) | 102 | `docs/agents/routage.md` § 2 ; socle : « matrice du § 3 » | renvoi |
| SA-6 | fiches `-approfondi` générées par `fiches_jumelles.sh`, contrôlées par la CI ; jamais modifiées à la main | 102 | socle | condensée |
| SA-7 | choix de la fiche selon la matrice de `routage.md` § 3 | 102 | socle | gardée |
| SA-8 | `model: "fable"` seulement dans les cas du § 4.1 (échec documenté d'Opus `high`, désaccord, ADR d'architecture) ou sur accord | 102 | socle | gardée |
| SA-9 | plafonds : une relance ciblée, une hausse d'effort, une consultation Fable par question ; trois Fable par branche, ADR compris ; hors branche, par période ; au-delà, arrêt et compte rendu | 102 | socle (chiffres gardés) ; `routage.md` § 5.2 | condensée |
| SA-10 | modèle indisponible : arrêt du circuit, aucun remplacement silencieux | 102 | socle | gardée |
| SA-11 | les agents signalent les critères dans leur « Retour », sans décider de leur escalade | 102 | socle | condensée |
| SA-12 | la session note chaque escalade, relance ciblée ou arrêt d'une ligne dans la PR (hors branche : feuille de route § 7) | 102 | socle | condensée |
| SA-13 | modèle et effort fixés par chaque fiche (`coder` Sonnet `high`, `coder-approfondi` Opus `medium`, `audit` et `docwriter` Opus `medium`, `app-review` Sonnet `high`, `regulatory` Opus `medium`) | 104 | `routage.md` § 10 (tableau) ; socle : « fixés par la fiche » | renvoi |
| SA-14 | `coder-approfondi` d'office, reprises comprises : circuits 1 et 2 avec `effort: "high"` ; ailleurs, effort de la fiche, si résultat changé ou contrat partagé (§ 4.2) ; le plan d'`architect` désigne la fiche | 104 | socle (règle d'office) ; `routage.md` § 10 | condensée |
| SA-15 | hors de ces cas : `coder-approfondi` proposé au mainteneur, employé avec son accord ; `high` hors circuits 1 et 2 sur accord | 104 | socle | condensée |
| SA-16 | workflow `circuit-technique` : option `--approfondi` (`=high`), donnée par le mainteneur, y compris quand le plan la désigne | 104 | `routage.md` § 10 ; `.claude/workflows/circuit-technique.js` | renvoi |
| SA-17 | `effort: "high"` à l'appel pour la revue finale complète d'`audit` et pour le passage de fin de branche de `docwriter` en circuits 1 et 2 (pas M32) | 104 | socle (« Règle 9 », « Règle 10 ») ; `routage.md` § 10 | condensée |
| SA-18 | revue finale complète d'`app-review` avec `model: "opus"` si la branche touche l'interface | 104 | socle (« Règle 10 ») ; `routage.md` § 10 | condensée |
| SA-19 | l'audit léger renvoie à `actuary`, comme question, tout `detail` ou `reference` nouveau qui porte une affirmation de fond | 104 | `routage.md` § 10 (tableau) ; fiche `audit.md` (audit léger, ADR 0015 D-P4) | renvoi |
| SA-20 | fiche modifiée inconnue ou servie par l'ancien modèle : attendre, vérifier le modèle servi, jamais de repli ; au-delà de 15 minutes, arrêt | 104 | socle (« aucun repli sur une autre fiche ») ; `routage.md` § 2 et § 10 | condensée |
| SA-21 | trace d'une ligne dans la PR : `coder-approfondi` hors d'office, `high` sur accord, `regulatory` en `high` | 104 | socle (SA-12, « emploi du § 10 sur accord ») ; `routage.md` § 10 | condensée |
| SA-22 | **Circuits types**, chacun terminé par des commits sur la branche de travail | 106 | socle (intitulé gardé : cité par `routage.md` § 10) | gardée |
| SA-23 | circuit 1, évolution méthodologique | 108 | socle | gardée |
| SA-24 | circuit 2, conformité réglementaire (le mainteneur tranche si σ_USP change) | 109 | socle | gardée |
| SA-25 | circuit 3, correction technique (`coder`, `coder-approfondi` d'office selon le § 10) | 110 | socle (« circuit 3 » cité par `circuit-technique.js` l. 3, 17, 361) | condensée |
| SA-26 | circuit 4, documentation seule | 111 | socle | gardée |
| SA-27 | **Workflows** : mise en œuvre d'un circuit par `.claude/workflows/` ; premier : `circuit-technique <issue>` | 113 | socle | condensée |
| SA-28 | huit principes de l'ADR 0010 | 113 | ADR 0010 ; socle : renvoi | renvoi |
| SA-29 | lancement sur commande explicite du mainteneur uniquement | 113 | socle | gardée |
| SA-30 | ni commit, ni push, ni régénération ou patch de `tests/reference/`, ni issue par le workflow ou ses agents ; la session vérifie `git status` et `git log` après chaque workflow | 113 | socle | gardée |
| SA-31 | arrêt avec les rapports à tout point de décision | 113 | ADR 0010, principe 3 ; socle : principe implicite dans « porte à `actuary` » | renvoi |
| SA-32 | au plus une reprise `coder` → `audit` | 113 | ADR 0010, principe 4 | renvoi |
| SA-33 | vérificateurs ciblés sur le diff ; constats structurés (gravité, `fichier:ligne`, mesure) ; contrôles mécaniques confiés aux scripts | 113 | ADR 0010, principes 5 à 7 | renvoi |
| SA-34 | principe 8 : effort réduit pour les étapes mécaniques, aucun `model` fixé dans un workflow, modèle de la fiche par `agentType`, à confirmer par le journal | 113 | ADR 0010 principe 8, remplacé par ADR 0015 point 8 (l. 41) | renvoi |
| SA-35 | constat → reprise ou arrêt ; question pour `actuary` ne relance pas `coder` ; « termine avec questions » porté à `actuary` avant tout commit | 113 | socle (portée à `actuary` avant tout commit) ; ADR 0010, annotation (l. 89-103) | condensée |
| SA-36 | trois statuts de fin ; batterie en échec à la dernière vérification → `arrete` | 113 | ADR 0010, annotation ; `circuit-technique.js` | renvoi |
| SA-37 | concordance en `--strict` ; échec par écart n'est pas une batterie en échec ; « écart de concordance » corrigé par un commit `docs:` minimal avant push (M32) | 113 | socle (« Règle 9 », exception) ; ADR 0010, annotation (l. 119) | condensée |
| SA-38 | **Règle 9** : `docwriter` une fois, en fin de branche, sur l'état final ; un commit `docs:` par issue | 115 | socle (intitulé gardé) | condensée |
| SA-39 | `coder` ne modifie pas le `.tex` ; surface d'impact documentaire dans chaque commit proposé | 115 | socle | gardée |
| SA-40 | `concordance_doc_moteur.R` signale entre-temps noms et décomptes devenus faux | 115 | socle (dans l'exception) ; ADR 0010 | condensée |
| SA-41 | `actuary` valide le diff du `.tex` une fois, en fin de branche | 115 | socle | gardée |
| SA-42 | exceptions : commits préparatoires, document qui précède le code (amendement d'ADR, lecture réglementaire, circuit 2), écart de concordance (M32) | 115 | socle | condensée |
| SA-43 | **Règle 10** : audit léger en cours (diff, fonctions touchées, appelants et appelés) | 117 | socle (intitulé gardé) | condensée |
| SA-44 | revue finale complète de `git diff main...HEAD` avant la sortie du brouillon par les vérificateurs des déclencheurs, plus `/code-review` | 117 | socle ; détail (batteries, scénarios adverses, cohérence) : ADR 0010 règle 10, fiche `audit.md` l. 24 | condensée |
| SA-45 | toute correction postérieure revue sur son diff avant la sortie du brouillon | 117 | socle | gardée |
| SA-46 | relecture intégrale hors diff réservée à la remise | 117 | socle | condensée |
| SA-47 | constat bloquant ou majeur → retour à la réalisation | 119 | socle | gardée |
| SA-48 | `docwriter` après `coder` (après le dernier commit de code), jamais en parallèle | 119 | socle (« Règle 9 », « après le dernier commit de code ») | condensée |
| SA-49 | deux lectures du texte réglementaire : `regulatory` décrit, `actuary` avise, le mainteneur tranche | 119 | socle | gardée |
| SA-50 | **Revues périodiques** (`architect`, `regulatory`, `actuary`, `app-review`, `docwriter`) | 121 | socle | condensée |
| SA-51 | rapports hors scratchpad : matrice de `regulatory` et rapports de fond d'`actuary` versés par la session dans `docs/revues/<aaaammjj>-<objet>/` avec synthèse, avant la sortie du brouillon, ou hors branche par PR directe vers `main` (Q-54-10) | 121 | socle | condensée |
| SA-51h | « rapports de JF perdus » ; modèle `docs/revues/20261015-pertinence-tests-graphiques` | 121 | feuille de route, Q-54-10 ; `docs/revues/` | historique |
| SA-52 | **Approbation des changements de résultats** : un tableau par commit, joint à la PR ; σ_USP ou verdict → mainteneur ; autres p-values → `actuary` | 123 | socle | gardée |
| SA-53 | vocabulaire du domaine défini dans `CONTEXT.md`, employé tel quel | 125 | socle | condensée |

### « Agent skills » (l. 127-139)

| N° | Règle (citation courte) | L. | Emplacement cible | Forme |
|---|---|---|---|---|
| SK-1 | issue tracker : GitHub Issues, `mcp__github__*` en cloud, `gh` en local ; `docs/agents/issue-tracker.md` | 131 | socle | gardée |
| SK-2 | cinq libellés canoniques ; `docs/agents/triage-labels.md` | 135 | socle | gardée |
| SK-3 | mono-contexte : `CONTEXT.md` et `docs/adr/` ; `docs/agents/domain.md` | 139 | socle | gardée |

## Bilan

- **206 lignes** de correspondance : 195 règles de l'ancien texte, 9 mentions historiques (suffixe `h`) et 2 lignes de résumé nouvelles (STR-R1, STR-R2). Aucune règle sans emplacement (décompte : `grep -oE '^\| [A-Z]+-[0-9R]+h? \|'`).
- Règles **déplacées hors du socle** : vers la règle `.claude/rules/moteur.md` (STR-1 à STR-16, REP-1 à REP-10 en intégral, FLX-4 et FLX-5 en détail, CMD-8) ; vers la skill `periode-gpt` (GPT-3, GPT-5 à GPT-8, GPT-17) ; vers des documents **qui les portent déjà** (skill `audit-main-gpt`, skill `verifier-reproductibilite`, `docs/agents/routage.md` § 2, § 5.2, § 10, ADR 0010, ADR 0015 point 8, en-tête de `preparer_r.sh`).
- **Toutes les règles que seule la consigne fait respecter restent dans le socle** (avis Fable, question 2, point 2) : GIT-1, GIT-2, GIT-6, GIT-11 à GIT-16, GIT-17 à GIT-26, GIT-30, GIT-34 à GIT-37, REP-4, REP-10, CTX-8 à CTX-12, SA-29, SA-30 ; et les décisions réservées au mainteneur (`routage.md` § 5.5, rang 1) : SA-8, SA-10, SA-49, SA-52, SA-24.
- Deux mentions caduques corrigées au passage, sans changement de règle : GIT-10h (report dans l'ADR déjà fait) et GIT-25h (contrôle de #407 en place).
