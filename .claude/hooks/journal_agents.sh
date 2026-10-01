#!/usr/bin/env bash
###############################################################################
#  .claude/hooks/journal_agents.sh  --  HOOK SubagentStop DE CLAUDE CODE
#
#  Ajoute une ligne JSON par sous-agent termine a
#  .claude/journal-agents.jsonl (non versionne) : date, agent, identifiant,
#  modeles servis, nombre d'appels au modele, contexte au dernier appel
#  (tokens d'entree, cache compris) et duree, lus dans le transcript du
#  sous-agent (corps en Python : journal_agents.py). Sert a calibrer la
#  politique de routage (docs/agents/routage.md, § 7 et § 8) et donne le
#  modele servi, que la session compare a celui qu'elle a demande (l'entree
#  SubagentStop ne porte pas le modele demande).
#
#  Ne mesure ni l'effort (non expose dans le transcript) ni les tokens de
#  sortie (valeurs partielles de streaming dans le transcript). Le transcript
#  est ecrit de facon asynchrone : appels et contexte sont des minorants
#  possibles.
#  N'echoue jamais et n'ecrit rien sur la sortie standard : une session sans
#  Python, ou un transcript illisible, se poursuit sans journal.
###############################################################################

racine="${CLAUDE_PROJECT_DIR:-$(pwd)}"

py=""
for c in python3 python; do
  if command -v "$c" >/dev/null 2>&1 && "$c" -c "import json" >/dev/null 2>&1; then py="$c"; break; fi
done
if [ -z "$py" ]; then cat >/dev/null; exit 0; fi

JOURNAL="$racine/.claude/journal-agents.jsonl" "$py" "$racine/.claude/hooks/journal_agents.py" >/dev/null 2>&1 || true
exit 0
