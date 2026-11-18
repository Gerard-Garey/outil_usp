# Script de lancement des etapes 2 (i) et 4 de JS1, tel qu'execute le 18/11/2026
# sous Windows PowerShell 5.1, depuis la racine du depot detache sur c75a112.
# Seul changement : le dossier de sortie, chemin de la session, est devenu le
# parametre $S. R_LIBS_USER n'est pose que pour l'execution "sans openxlsx" et
# retire aussitot (Remove-Item) : comparer_references.R et
# test_reproductibilite.R tournent avec la bibliotheque du poste.
param([string]$S)
$ErrorActionPreference = "Continue"
$R = "C:\Program Files\R\R-4.3.3\bin\Rscript.exe"
function Lancer($nom, [string[]]$args2) {
  $debut = Get-Date
  "HEAD: $(git rev-parse HEAD)" | Out-File "$S\$nom.log" -Encoding utf8
  "Debut: $($debut.ToString('o'))" | Out-File "$S\$nom.log" -Append -Encoding utf8
  & $R @args2 *>> "$S\$nom.log"
  $code = $LASTEXITCODE
  $fin = Get-Date
  "Fin: $($fin.ToString('o')) ; duree s: $([int]($fin-$debut).TotalSeconds) ; code de sortie: $code" | Out-File "$S\$nom.log" -Append -Encoding utf8
}
Lancer "e2i_avec_openxlsx" @("tests/unitaires/test_controles_entree.R")
$vide = "$S\lib_vide"; New-Item -ItemType Directory -Force $vide | Out-Null
$env:R_LIBS_USER = $vide
Lancer "e2i_sans_openxlsx" @("tests/unitaires/test_controles_entree.R")
Remove-Item Env:R_LIBS_USER
Lancer "e4_deux_parts" @("tests/comparer_references.R", "--deux-parts")
Lancer "e4_reproductibilite" @("tests/test_reproductibilite.R")
git status --porcelain | Out-File "$S\statut_apres.log" -Encoding utf8
