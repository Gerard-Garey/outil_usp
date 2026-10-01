---
status: accepted
date: 2026-09-30
---

# Opus par défaut pour architect et actuary, effort réglé à part, Fable réservé à une liste fermée de cas

## Contexte

`architect` et `actuary` tournaient sur Fable pour toutes leurs missions, sans effort ni plafond de tours fixés (effort hérité de la session). La lecture imposée au démarrage d'`architect` (`CLAUDE.md`, `docs/exigences.md`, `CONTEXT.md`, tous les ADR) représentait environ 415 Ko au 30/09/2026 (`wc -c` : 28 127 + 13 274 + 102 141 + 272 020 octets), sans compter `docs/feuille-de-route.md` (642 492 octets), qu'il tient en pratique ; elle était relue à chaque consultation, y compris pour un simple rattachement d'issues. Le mainteneur travaille sur abonnement : la contrainte est la limite d'usage. Aucune mesure de consommation par agent n'existait.

Le modèle `Modele_vibe_code` (dépôt privé du mainteneur, gabarit commun à ses projets) a adopté le 30/09/2026 une politique de routage (son ADR 0001, PR #1), arrêtée par le mainteneur après entretien ; le présent ADR la reprend et l'adapte. Contraintes techniques (Claude Code 2.1.286) : le paramètre `model` d'un appel `Agent` l'emporte sur la fiche ; l'effort ne se fixe que dans la fiche ; une fiche n'est pas rechargée en cours de session (`docs/agents/issue-tracker.md`, constat 3).

## Décision

Arrêtée par le mainteneur le 30 septembre 2026 (décision M35, PR #176) :

1. Opus par défaut ; deux fiches par rôle au même corps : de base (effort `medium`, 40 tours) et `-approfondi` (effort `high`, 80 tours), générée par `.claude/outils/fiches_jumelles.sh`, contrôlée par la CI (job « Fiches d'agents »). `regulatory` reste sur Opus, sans fiche `-approfondi`.
2. Fable (fiche `-approfondi` avec `model: "fable"`) sans demander dans trois cas : échec documenté d'Opus `high` sur un blocage de raisonnement ; désaccord entre agents ; rédaction d'un ADR d'architecture. Tout autre usage est proposé au mainteneur ; un changement de résultat final n'appelle Fable que sur sa décision.
3. Escalade selon la nature du blocage ; plafonds (une relance, une hausse d'effort, une consultation Fable par question ; trois consultations Fable par branche) ; arrêt sans remplacement silencieux si un modèle est indisponible.
4. Lecture ciblée par type de mission ; retour structuré ; journal local (hook `SubagentStop`), qui donne le modèle servi, que la session compare à celui qu'elle a demandé (l'entrée du hook ne porte pas le modèle demandé), et une ligne par escalade dans la PR.
5. Critères propres au projet : `docs/agents/routage.md` § 4.2, § 4.3 et § 9 ; le visa d'un changement de σ_USP ou d'un verdict et la lecture d'un texte réglementaire à deux lectures (circuit 2 : `regulatory`, `actuary`, mainteneur) restent régis par `CLAUDE.md`, quel que soit le modèle.
6. Ce que l'ADR ne modifie pas : les règles de modèle côté GPT (ADR 0012, annotation du 29/09/2026, point 5 : aucun nom de modèle fixé, le plus fort pour `architect` et `actuary`, au choix du mainteneur), ni `AGENTS.md` / `.codex/`, que Claude ne modifie que sur instruction du mainteneur ; la liste des modèles citée par la décision M28 (amendement du 24/09 de l'ADR 0010) est remplacée, pour `architect` et `actuary`, par le présent ADR (annotation du 30/09/2026 de l'ADR 0010).

## Options écartées

Celles de l'ADR 0001 du modèle : Fable pour tout (état antérieur) ; effort hérité de la session ; fiches jumelles tenues à la main ; Fable en `medium` par défaut ; routage par le nombre d'issues ou la confiance déclarée ; escalade décidée par le sous-agent. En propre : dédoubler aussi `regulatory`, écarté (déjà sur Opus, contrôle paragraphe par paragraphe sans palier de jugement distinct) ; étendre la politique au côté GPT (ADR 0012, annotation du 29/09, point 5), écarté (hors du périmètre de Claude sans instruction du mainteneur).

## Conséquences

- Fichiers : fiches `architect.md`, `actuary.md` et leurs `-approfondi` ; `.claude/outils/` ; `.claude/hooks/journal_agents.sh` et `journal_agents.py`, `.claude/settings.json` ; skill `audit-main-gpt` (plan d'audit et revues de fond en jugement) ; `.github/workflows/ci.yml` ; `docs/agents/routage.md` ; `CLAUDE.md`, `README.md`, `CONTEXT.md`, modèle de PR, `.gitignore`, `docs/feuille-de-route.md` (M35, et annotation de M28) ; annotation de l'ADR 0010.
- Branche : `claude/routage-modele-effort` (PR #176), exception ponctuelle au point 1 de l'ADR 0007, sur instruction du mainteneur du 30/09/2026, sans créer de catégorie de branche.
- Effet sur les résultats : aucun.
- Non réglé : l'effort de la fiche l'emporte sur celui de la session (documentation Claude Code, sous-agents, champ `effort`), mais il n'est pas observable dans le transcript ; `maxTurns` ne borne pas les tokens ; seuils à calibrer sur les premières consultations (`docs/agents/routage.md`, § 8), qui dit aussi comment revenir en arrière.
