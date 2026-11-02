#!/usr/bin/env bash
# Tests de controle_mots_cles_fermeture.sh (issue #407). Depot d'essai jetable
# dans un dossier temporaire ; aucune ecriture dans le depot courant.
# Usage : bash .github/scripts/test_controle_mots_cles_fermeture.sh
# Les mots-cles des exemples ne sont lus par GitHub que dans un message de
# commit ou un corps de PR ; ici ils ne sont que dans un fichier.

set -uo pipefail
ici=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=controle_mots_cles_fermeture.sh
source "$ici/controle_mots_cles_fermeture.sh"

nb=0; echec=0
verifie() { # description, condition (0 = vrai)
  nb=$((nb + 1))
  if [ "$2" -eq 0 ]; then echo "ok   $1"; else echo "ECHEC $1"; echec=$((echec + 1)); fi
}
contient() { case "$1" in *"$2"*) return 0 ;; *) return 1 ;; esac; }

# 1. Motif : formes lues (doivent etre signalees)
for l in 'Closes #4' 'closes #12' 'CLOSED #4' 'Fix #3' 'fixes: #3' 'Fixed #3' 'Resolve #3' 'resolves #3' 'RESOLVED: #3' \
         'Fixes owner/repo#9' 'closes https://github.com/o/r/issues/5' 'plus Closes #4 hors plafond' \
         '« Closes #4 »' '"Fixes #4"' '- Closes #4' 'closed GH-7' 'Close   #8' \
         'Closes `#4`' 'Closes **#4**' 'Closes [#4](https://x)' '**Closes**: #4' 'Fixes _owner/repo#9_'; do
  r=$(printf '%s\n' "$l" | fermeture_lignes_motif)
  verifie "motif lu : $l" "$([ -n "$r" ]; echo $?)"
done
# 2. Motif : formes non lues (ne doivent pas etre signalees)
for l in 'Refs #4' 'fermeture de #4' 'Closes #N' 'Closes #...' 'disclose #4' 'prefix #3' 'fixture #3' 'Closes' 'closes: aucun numero' 'Closes la page 4' 'Closes `x`' 'Closes **gras**'; do
  r=$(printf '%s\n' "$l" | fermeture_lignes_motif)
  verifie "motif non lu : $l" "$([ -z "$r" ]; echo $?)"
done

# 3. Corps de PR
corps_propre=$'## Objet\r\n\r\nCloses #407\r\nCloses #4\nRefs #408\n<!-- Closes #... -->'
r=$(printf '%s\n' "$corps_propre" | fermeture_rapport_corps)
verifie "corps : seules lignes dediees Closes #N (CRLF compris) -> aucun rapport" "$([ -z "$r" ]; echo $?)"
corps_faux=$'Objet\nCloses #407\nLa règle interdit « Closes #4 » dans la prose.\nCloses #5'
r=$(printf '%s\n' "$corps_faux" | fermeture_rapport_corps)
verifie "corps : la ligne de prose est nommee (ligne 3)" "$(contient "$r" 'corps de la PR : ligne 3:La règle interdit « Closes #4 »' ; echo $?)"
verifie "corps : les lignes dediees ne sont pas nommees" "$([ "$(printf '%s\n' "$r" | wc -l)" -eq 1 ]; echo $?)"
r=$(printf '%s\n' $'closes #4' | fermeture_rapport_corps)
verifie "corps : « closes #4 » en minuscules seul sur sa ligne n'est pas la ligne dediee" "$([ -n "$r" ]; echo $?)"
r=$(printf '%s\n' $'Closes #4, #5' | fermeture_rapport_corps)
verifie "corps : « Closes #4, #5 » (plusieurs numeros) n'est pas la ligne dediee" "$([ -n "$r" ]; echo $?)"
r=$(printf '%s\n' 'Fixes: #4' | fermeture_rapport_titre)
verifie "titre : toute occurrence est nommee" "$(contient "$r" 'titre de la PR : ligne 1:Fixes: #4' ; echo $?)"

# 4. Commits, dans un depot d'essai
tmp=$(mktemp -d) || exit 2
trap 'rm -rf "$tmp"' EXIT
cd "$tmp" || exit 2
git init -q -b main . || exit 2
git config user.name essai; git config user.email essai@example.invalid; git config commit.gpgsign false
git commit -q --allow-empty -m "base"
git update-ref refs/remotes/origin/main HEAD
git commit -q --allow-empty -m "tests: commit propre (Refs #407)"
propre=$(git rev-parse HEAD)
git commit -q --allow-empty -m "tests: commit fautif" -m "Corps du message, avec Closes #4 dans la prose."
faux=$(git rev-parse HEAD); faux_court=$(git rev-parse --short HEAD)
git commit -q --allow-empty -m "tests: autre commit propre" -m "Fermeture de #4 selon la décision."
tete=$(git rev-parse HEAD)

liste="$tmp/liste.txt"; : > "$liste"
r=$(fermeture_rapport_commits origin/main "$propre" "$liste")
verifie "commits : plage propre -> aucun rapport" "$([ -z "$r" ]; echo $?)"
r=$(fermeture_rapport_commits origin/main "$tete" "$liste")
verifie "commits : le commit fautif est nomme (SHA court)" "$(contient "$r" "commit $faux_court « tests: commit fautif » : ligne" ; echo $?)"
verifie "commits : la ligne fautive est citee" "$(contient "$r" 'Corps du message, avec Closes #4 dans la prose.' ; echo $?)"
verifie "commits : les commits propres ne sont pas nommes" "$([ "$(printf '%s\n' "$r" | wc -l)" -eq 1 ]; echo $?)"
# Une ligne « Closes #N » dediee n'est admise que dans le corps de PR : dans un commit elle est fautive
git commit -q --allow-empty -m "tests: ligne dediee dans un commit" -m "Closes #407"
r=$(fermeture_rapport_commits origin/main HEAD "$liste")
verifie "commits : une ligne dediee Closes #N dans un message de commit est fautive" "$(contient "$r" 'ligne dediee dans un commit' ; echo $?)"
git reset -q --hard "$tete"

# 5. Acquittement
printf '# commentaire\n\n%s  # issue 4 rouverte, Refs #4\n' "$faux" > "$liste"
r=$(fermeture_rapport_commits origin/main "$tete" "$liste")
verifie "acquittement : SHA complet de la liste -> admis" "$([ -z "$r" ]; echo $?)"
printf '%s  # SHA tronque\n' "${faux:0:12}" > "$liste"
r=$(fermeture_rapport_commits origin/main "$tete" "$liste")
verifie "acquittement : SHA tronque -> refuse" "$([ -n "$r" ]; echo $?)"
printf '%s\r\n' "$faux" > "$liste"
r=$(fermeture_rapport_commits origin/main "$tete" "$liste")
verifie "acquittement : ligne de liste en CRLF -> admis" "$([ -z "$r" ]; echo $?)"
printf '%s  # commentaire\r\n' "$faux" > "$liste"
r=$(fermeture_rapport_commits origin/main "$tete" "$liste")
verifie "acquittement : ligne de liste en CRLF avec commentaire -> admis" "$([ -z "$r" ]; echo $?)"
printf '# %s  # ligne commentee\n' "$faux" > "$liste"
r=$(fermeture_rapport_commits origin/main "$tete" "$liste")
verifie "acquittement : ligne commentee -> refuse" "$([ -n "$r" ]; echo $?)"
r=$(fermeture_rapport_commits origin/main "$tete" "$tmp/inexistante.txt")
verifie "acquittement : liste absente -> refuse (pas d'erreur)" "$([ -n "$r" ]; echo $?)"

# 6. Controle complet (variables d'environnement, code de sortie)
printf '%s  # essai\n' "$faux" > "$liste"
sortie=$(BASE_REF=main HEAD_SHA="$tete" LISTE_ADMIS="$liste" PR_BODY=$'Objet\nCloses #407' PR_TITLE='repo: essai' fermeture_controle); code=$?
verifie "complet : commit acquitte + corps propre -> succes" "$([ "$code" -eq 0 ]; echo $?)"
sortie=$(BASE_REF=main HEAD_SHA="$tete" LISTE_ADMIS=/dev/null PR_BODY=$'Objet\nCloses #407' PR_TITLE='repo: essai' fermeture_controle); code=$?
verifie "complet : commit fautif non acquitte -> echec nommant le commit" "$([ "$code" -eq 1 ] && contient "$sortie" "commit $faux_court" ; echo $?)"
sortie=$(BASE_REF=main HEAD_SHA="$propre" LISTE_ADMIS=/dev/null PR_BODY=$'Objet\nVoir « Fixes #4 »' PR_TITLE='repo: essai' fermeture_controle); code=$?
verifie "complet : corps fautif -> echec nommant la ligne" "$([ "$code" -eq 1 ] && contient "$sortie" 'corps de la PR : ligne 2:Voir « Fixes #4 »' ; echo $?)"
# Controle impossible : jamais un succes silencieux (code 2)
sortie=$(BASE_REF=inexistante HEAD_SHA="$tete" LISTE_ADMIS=/dev/null PR_BODY='Objet' PR_TITLE='t' fermeture_controle); code=$?
verifie "impossible : base inexistante -> code 2 et ::error" "$([ "$code" -eq 2 ] && contient "$sortie" 'Commit ou référence introuvable' ; echo $?)"
sortie=$(BASE_REF=main HEAD_SHA=0123456789abcdef0123456789abcdef01234567 LISTE_ADMIS=/dev/null PR_BODY='Objet' PR_TITLE='t' fermeture_controle); code=$?
verifie "impossible : HEAD_SHA inconnu -> code 2 et ::error" "$([ "$code" -eq 2 ] && contient "$sortie" 'Commit ou référence introuvable' ; echo $?)"
fermeture_rapport_commits origin/inexistante "$tete" "$liste" > /dev/null 2>&1; code=$?
verifie "impossible : fermeture_rapport_commits sur base inexistante -> code 2" "$([ "$code" -eq 2 ]; echo $?)"
fermeture_rapport_commits origin/main 0123456789abcdef0123456789abcdef01234567 "$liste" > /dev/null 2>&1; code=$?
verifie "impossible : fermeture_rapport_commits sur tete inconnue -> code 2" "$([ "$code" -eq 2 ]; echo $?)"
# Une erreur de grep (code 2) n'est pas prise pour « aucune ligne »
motif_sauve="$MOTIF_FERMETURE"; MOTIF_FERMETURE='('
printf 'texte\n' | fermeture_lignes_motif > /dev/null 2>&1; code=$?
verifie "impossible : motif invalide (grep code 2) -> code non nul" "$([ "$code" -ne 0 ]; echo $?)"
printf 'texte\n' | fermeture_rapport_corps > /dev/null 2>&1; code=$?
verifie "impossible : motif invalide -> fermeture_rapport_corps code 2" "$([ "$code" -eq 2 ]; echo $?)"
MOTIF_FERMETURE="$motif_sauve"
# Injection de shell : le corps est une donnee, jamais executee
sortie=$(BASE_REF=main HEAD_SHA="$propre" LISTE_ADMIS=/dev/null PR_BODY=$'$(touch '"$tmp"$'/injecte)\n`touch '"$tmp"$'/injecte2`\nCloses #407' PR_TITLE='' fermeture_controle); code=$?
verifie "complet : corps a metacaracteres de shell -> succes, rien d'execute" "$([ "$code" -eq 0 ] && [ ! -e "$tmp/injecte" ] && [ ! -e "$tmp/injecte2" ]; echo $?)"

echo
echo "$((nb - echec)) / $nb verifications reussies."
[ "$echec" -eq 0 ]
