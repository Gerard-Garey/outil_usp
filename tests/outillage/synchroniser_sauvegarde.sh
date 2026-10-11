#!/usr/bin/env bash
###############################################################################
#  tests/outillage/synchroniser_sauvegarde.sh  --  SYNCHRONISATION DES
#  SORTIES D'UNE MESURE LONGUE VERS SA BRANCHE DE SAUVEGARDE
#  (issue #206, Q-206-4, Q-206-5, lecons L-229-1 et L-229-5)
#
#  Outillage d'execution, SANS LOGIQUE DE MESURE. Versionne sur la branche
#  de travail ; il n'ecrit sur la branche de sauvegarde que des DONNEES
#  (sorties *.txt, partielles *.partielN, consoles *.log, JOURNAL.md),
#  jamais de code (trait 2 de l'annotation du 9 octobre 2026 de l'ADR 0007).
#
#  Usage :
#      bash tests/outillage/synchroniser_sauvegarde.sh -d DOSSIER -w WORKTREE
#           -b BRANCHE -c SOUS_DOSSIER [-i INTERVALLE_S]
#    DOSSIER      : dossier des sorties (celui du lanceur), qui contient le
#                   JOURNAL.md de la mesure ;
#    WORKTREE     : git worktree de la branche de sauvegarde ;
#    BRANCHE      : nom de la branche de sauvegarde (claude/sauvegarde-...),
#                   egal a la branche extraite dans WORKTREE ;
#    SOUS_DOSSIER : dossier de destination dans WORKTREE (ex.
#                   sauvegarde/issue206) ;
#    INTERVALLE_S : si present, synchronisation repetee toutes les
#                   INTERVALLE_S secondes (arret par le fichier DOSSIER/STOP) ;
#    -n           : essai a blanc, AUCUNE commande git (ni controle de la
#                   branche, ni add, commit, push) : etapes 1 et 2 seules,
#                   WORKTREE pouvant etre un simple dossier.
#  A chaque passage :
#    1. pour chaque sortie terminee (derniere ligne non vide "FIN<TAB>...")
#       absente du JOURNAL, ajout au JOURNAL de la ligne
#       "- Sortie <nom> : md5 <md5>, terminee, INTEGRITE <etat>, synchronisee <UTC>"
#       (nom de fichier seul : aucun chemin absolu, D-a de #242), lue par
#       --combiner --journal ;
#       une sortie citee au JOURNAL par plusieurs lignes "- Sortie <nom> :
#       md5", meme identiques, est signalee ("LIGNES MULTIPLES <nom> ...") et
#       traitee comme un md5 perime (une ligne et une seule : regle de
#       controler_md5.sh et de --combiner --journal) ;
#       une sortie deja citee au JOURNAL, terminee ou non, dont le md5
#       differe (sortie regeneree, ou retiree puis relancee et encore
#       partielle, apres sa synchronisation : md5 du JOURNAL perime, #248)
#       est signalee ("PERIME <nom> : JOURNAL <md5>, fichier <md5>", sur la
#       sortie d'erreur), n'est PAS copiee (la copie de WORKTREE reste celle
#       que cite le JOURNAL) et fait finir le passage en code 1, apres la
#       copie et la synchronisation des autres donnees ; la ligne du JOURNAL
#       n'est jamais modifiee (decision humaine : retirer la sortie
#       regeneree, ou corriger le JOURNAL en le consignant) ;
#    2. copie des donnees dans WORKTREE/SOUS_DOSSIER et controle des md5 des
#       copies (refus si une copie differe) ;
#    3. git add, commit (si changement) et push -u origin BRANCHE (quatre
#       nouvelles tentatives, attente 2, 4, 8, 16 s). Pied du message : contenu
#       de la variable d'environnement PIED_COMMIT si elle est definie.
#  L'identite git est celle du WORKTREE (Claude <noreply@anthropic.com> pour
#  une session de Claude, CLAUDE.md) ; une autre identite est signalee.
#  Code de sortie (passage unique) : 0 si la synchronisation aboutit sans
#  md5 perime ni ligne multiple, 1 sinon.
###############################################################################
set -u

DOSSIER=""; WT=""; BRANCHE=""; SOUS=""; INTERVALLE=""; BLANC=0
while [ $# -gt 0 ]; do
  case "$1" in
    -d) DOSSIER="$2"; shift 2 ;;
    -w) WT="$2"; shift 2 ;;
    -b) BRANCHE="$2"; shift 2 ;;
    -c) SOUS="$2"; shift 2 ;;
    -i) INTERVALLE="$2"; shift 2 ;;
    -n) BLANC=1; shift ;;
    *) echo "option inconnue : $1" >&2; exit 2 ;;
  esac
done
[ -d "$DOSSIER" ] || { echo "dossier des sorties introuvable (-d)" >&2; exit 2; }
[ -d "$WT" ] || { echo "worktree introuvable (-w)" >&2; exit 2; }
[ -n "$SOUS" ] || { echo "sous-dossier de destination obligatoire (-c)" >&2; exit 2; }
case "$SOUS" in /*|*..*) echo "-c : chemin relatif au worktree, sans '..'" >&2; exit 2 ;; esac
case "$BRANCHE" in claude/sauvegarde-*) ;; *) echo "-b : branche de sauvegarde claude/sauvegarde-... attendue" >&2; exit 2 ;; esac
if [ "$BLANC" -eq 0 ]; then
  courante=$(git -C "$WT" rev-parse --abbrev-ref HEAD 2>/dev/null)
  [ "$courante" = "$BRANCHE" ] || { echo "le worktree est sur '$courante', pas sur '$BRANCHE'" >&2; exit 2; }
  [ "$(git -C "$WT" config user.email)" = "noreply@anthropic.com" ] || \
    echo "avertissement : identite git du worktree '$(git -C "$WT" config user.name) <$(git -C "$WT" config user.email)>' (attendue pour Claude : Claude <noreply@anthropic.com>)" >&2
fi

md5() { if command -v md5sum >/dev/null 2>&1; then md5sum "$1" | cut -d' ' -f1; else command md5 -q "$1"; fi; }
utc() { date -u +%Y-%m-%dT%H:%M:%SZ; }
terminee() { [ -f "$1" ] && [ "$(grep -v '^[[:space:]]*$' "$1" | tail -n 1 | cut -f1)" = "FIN" ]; }

# md5 cites au JOURNAL pour une sortie (lignes "- Sortie <nom> : md5 <md5>"
# en debut de ligne, regle de controler_md5.sh), un par ligne.
md5_journal() { awk -v n="$2" 'index($0, "- Sortie " n " : md5 ") == 1 { r = substr($0, length("- Sortie " n " : md5 ") + 1); m = substr(r, 1, 32); c = substr(r, 33, 1); if (length(m) == 32 && m !~ /[^0-9a-f]/ && (c == "" || c == "," || c == " " || c == "\t" || c == "\r")) print m }' "$1"; }

passage() {
  local journal="$DOSSIER/JOURNAL.md" f nom n_new=0 dest="$WT/$SOUS" mj mf perimes=" " n_perimes=0
  [ -f "$journal" ] || { echo "JOURNAL.md absent de $DOSSIER (cree par la session avant le lancement)" >&2; return 1; }
  # 1. Sorties terminees absentes du JOURNAL ; md5 du JOURNAL perimes (#248).
  for f in "$DOSSIER"/*.txt; do
    [ -e "$f" ] || continue
    nom=$(basename "$f")
    # Sortie deja citee au JOURNAL, terminee OU NON (retiree puis relancee :
    # sa version partielle ne doit pas ecraser la copie terminee) : md5 compare.
    # Une ligne et une seule (regle de controler_md5.sh et de --combiner
    # --journal) : des lignes multiples, meme identiques, sont un ecart.
    mj=$(md5_journal "$journal" "$nom")
    if [ -n "$mj" ]; then
      mf=$(md5 "$f")
      if [ "$(printf '%s\n' "$mj" | wc -l)" -ne 1 ]; then
        echo "LIGNES MULTIPLES $nom : $(printf '%s\n' "$mj" | wc -l | tr -d ' ') lignes \"- Sortie $nom : md5\" au JOURNAL (une attendue), md5 $(echo $mj) ; fichier $mf, non copiee" >&2
        perimes="$perimes$nom "; n_perimes=$((n_perimes + 1))
      elif [ "$mj" != "$mf" ]; then
        echo "PERIME $nom : JOURNAL $(echo $mj), fichier $mf ($(terminee "$f" && echo "sortie regeneree" || echo "sortie partielle, relancee") apres sa synchronisation ; non copiee)" >&2
        perimes="$perimes$nom "; n_perimes=$((n_perimes + 1))
      fi
      continue
    fi
    terminee "$f" || continue
    printf -- '- Sortie %s : md5 %s, terminee, INTEGRITE %s, synchronisee %s\n' "$nom" "$(md5 "$f")" \
      "$(grep -m1 '^INTEGRITE	' "$f" | cut -f2)" "$(utc)" >> "$journal"
    n_new=$((n_new + 1))
  done
  # 2. Copie des donnees seules (sauf sorties au md5 perime), controle des md5.
  mkdir -p "$dest"
  for f in "$DOSSIER"/*.txt "$DOSSIER"/*.txt.partiel* "$DOSSIER"/*.log "$journal"; do
    [ -f "$f" ] || continue
    case "$perimes" in *" $(basename "$f") "*) continue ;; esac
    cp -p "$f" "$dest/" || { echo "copie refusee : $(basename "$f")" >&2; return 1; }
    [ "$(md5 "$f")" = "$(md5 "$dest/$(basename "$f")")" ] || { echo "md5 de la copie different : $(basename "$f")" >&2; return 1; }
  done
  # 3. Commit et push (sauf essai a blanc).
  local code_fin=0
  [ "$n_perimes" -gt 0 ] && code_fin=1
  if [ "$BLANC" -eq 1 ]; then echo "$(utc) : essai a blanc, $n_new nouvelle(s) sortie(s) terminee(s) au JOURNAL, copies conformes, $n_perimes md5 perime(s) ou ligne(s) multiple(s) (aucune commande git)"; return "$code_fin"; fi
  git -C "$WT" add -- "$SOUS" || return 1
  if git -C "$WT" diff --cached --quiet -- "$SOUS"; then echo "$(utc) : rien a synchroniser"; return "$code_fin"; fi
  local msg
  msg="sauvegarde: $n_new sortie(s) terminee(s) ajoutee(s) au JOURNAL, $(utc)"
  [ -n "${PIED_COMMIT:-}" ] && msg="$msg

$PIED_COMMIT"
  git -C "$WT" commit -q -m "$msg" -- "$SOUS" || return 1
  local essai attente=2
  for essai in 1 2 3 4 5; do
    if git -C "$WT" push -q -u origin "$BRANCHE"; then echo "$(utc) : synchronise ($n_new nouvelle(s) sortie(s) terminee(s), $n_perimes md5 perime(s) ou ligne(s) multiple(s))"; return "$code_fin"; fi
    [ "$essai" -lt 5 ] && { sleep "$attente"; attente=$((attente * 2)); }
  done
  echo "push refuse apres cinq tentatives" >&2
  return 1
}

if [ -z "$INTERVALLE" ]; then passage; exit $?; fi
case "$INTERVALLE" in ''|*[!0-9]*) echo "-i : entier (secondes) attendu" >&2; exit 2 ;; esac
while [ ! -e "$DOSSIER/STOP" ]; do
  passage || echo "$(utc) : passage en echec (nouvel essai au prochain intervalle)" >&2
  sleep "$INTERVALLE"
done
passage
