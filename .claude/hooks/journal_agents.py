#!/usr/bin/env python3
###############################################################################
#  .claude/hooks/journal_agents.py  --  corps du hook SubagentStop
#
#  Appele par journal_agents.sh ; lit l'entree du hook sur l'entree standard
#  (et non par une variable d'environnement, limitee a 128 Kio, que depasse
#  un long last_assistant_message). Detail : en-tete de journal_agents.sh.
###############################################################################
import json, os, sys
from datetime import datetime, timezone

e = json.loads(sys.stdin.buffer.read().decode("utf-8") or "{}")
aid = e.get("agent_id") or ""
chemin = e.get("agent_transcript_path") or ""
if not chemin and aid and e.get("transcript_path"):
    base = e["transcript_path"][:-len(".jsonl")] if e["transcript_path"].endswith(".jsonl") else e["transcript_path"]
    chemin = os.path.join(base, "subagents", "agent-%s.jsonl" % aid)

agent = e.get("agent_type") or ""
if not agent and chemin:
    try:
        agent = json.load(open(chemin[:-len(".jsonl")] + ".meta.json", encoding="utf-8")).get("agentType", "")
    except Exception:
        pass

modeles, ids, contexte, debut, fin = [], set(), None, None, None
if chemin and os.path.exists(chemin):
    for ligne in open(chemin, encoding="utf-8"):
        try:
            d = json.loads(ligne)
        except Exception:
            continue
        t = d.get("timestamp")
        if t:
            debut = debut or t
            fin = t
        if d.get("type") != "assistant":
            continue
        m = d.get("message") or {}
        if m.get("model") and m["model"] not in modeles and not m["model"].startswith("<"):
            modeles.append(m["model"])
        if m.get("id"):
            ids.add(m["id"])
        u = m.get("usage") or {}
        if u:
            contexte = sum(int(u.get(k) or 0) for k in ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens"))

def iso(x):
    return datetime.fromisoformat(x.replace("Z", "+00:00"))

duree = None
if debut and fin:
    try:
        duree = round((iso(fin) - iso(debut)).total_seconds())
    except Exception:
        pass

ligne = {
    "date": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "session": e.get("session_id", ""),
    "agent": agent,
    "id": aid,
    "modeles": modeles,
    "appels": len(ids),
    "contexte_final": contexte,
    "duree_s": duree,
}
with open(os.environ["JOURNAL"], "a", encoding="utf-8") as f:
    f.write(json.dumps(ligne, ensure_ascii=False) + "\n")
