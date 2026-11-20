# Étape P de S5 : rejeu sous Windows (reliquat 10b d'A1)

Marche à suivre pour le poste Windows du mainteneur (R 4.3.3 ucrt, `French_France.utf8`, `openxlsx` 4.2.9). Il s'agit de l'étape P de la fiche « Branche S5 » (`docs/feuille-de-route.md`, § 3), PR #609, Refs #602, #603, #604, #608. Moment de l'étape : dès l'ouverture de S5, sur un code identique à `e4a8ae4`, au plus tard avant la sortie du brouillon (Q-70-4 (a)). Une session cloud ne peut pas la faire.

Le rejeu peut être lancé par le mainteneur lui-même, ou par une session locale de Claude Code sur ce poste (précédent : JS1, étape 2). Toutes les commandes se tapent sous PowerShell, à la racine du dépôt.

## 0. Se placer sur la branche

```powershell
git fetch origin claude/bootstrap-merz-wuthrich
git checkout -B claude/bootstrap-merz-wuthrich origin/claude/bootstrap-merz-wuthrich
git status                                      # arbre propre attendu
git rev-parse HEAD                              # SHA à citer dans le relevé
git diff --stat e4a8ae4 HEAD -- R tests app.R   # sortie vide attendue : code identique à e4a8ae4
mkdir sorties-p                                 # dossier des sorties, hors suivi
```

## 1. Point (i) : batterie `test_controles_entree.R` entière

```powershell
Rscript tests/unitaires/test_controles_entree.R *> sorties-p/i_controles_entree.txt
```

- Attendu : aucun échec. Copier la dernière ligne du bilan.
- Sous `openxlsx` 4.2.9, une ligne « [saute] temoin openxlsx, corpus naturel (ADR 0020) : liste des ecarts non datee pour la version 4.2.9 » est attendue. Elle n'est pas un échec : le point (v) la remplace par un relevé.

## 2. Points (ii), (iii), (v) et (vi) : script du rejeu

```powershell
Rscript docs/revues/20261119-s5-rejeu-windows/rejeu_windows.R . --mesure-608 *> sorties-p/rejeu.txt
```

| Point | Ce que le script contrôle | Attendu |
|---|---|---|
| (ii) #602 | `"a\nb"` (avec une tabulation et un texte simple) écrit par `engine_ecrire_xlsx()`, puis relu par `engine_lire_xlsx()` | deux `[OK]` : cellules `identical()`, aucun octet 0x0D dans les parties de l'archive |
| (iii) #603 | `engine_ecrire_xlsx(df, "C:f.xlsx")` lancé depuis un dossier temporaire de `C:` | deux `[OK]` : refus motivé « forme X: sans barre », aucun `f.xlsx` créé |
| (v) relevé | emploi 1 du témoin sous la version installée d'`openxlsx` : écarts du témoin à la source sur les 38 classeurs du corpus ; lecture du corpus par le lecteur interne | liste des écarts à recopier, sans effet sur la branche ; lecteur interne : `[OK]`, 38 sur 38 |
| (vi) #608 | lecteur virtuel `subst` (lettre libre de Z à P) pris comme dossier courant ; écriture de `\usp608_s5\f.xlsx` et de `/usp608_s5/f.xlsx`, sans puis avec un dossier `C:\usp608_s5` | relevé seul ; le fichier devrait être écrit sur le lecteur virtuel ; s'il l'est sur `C:`, ou si l'appel échoue, le constat de #608 est confirmé |

- Le script ne modifie aucun fichier du dépôt. Il supprime ce qu'il crée : dossiers temporaires, lettre `subst` et `C:\usp608_s5`.
- Il abandonne (vi) si `C:\usp608_s5` existe déjà.
- Sans l'option `--mesure-608`, (vi) n'est pas fait.

## 3. Point (iv) : sondes de JS1

```powershell
Rscript docs/revues/20261118-js1-poste-windows/etape-2-i/sonde_tab.R . *> sorties-p/iv_sonde_tab.txt
Rscript docs/revues/20261118-js1-poste-windows/etape-2-iii/sonde_unlink.R . *> sorties-p/iv_sonde_unlink.txt
```

Comparer chaque sortie à celle de JS1, dans le même dossier : `sortie_sonde_tab.txt` et `sortie_trace_unlink.txt`.
- `sonde_tab.R` : les deux chemins doivent maintenant donner `identical cellules = TRUE`, et aucun octet `0d` ne doit apparaître dans les valeurs lues. Depuis A1 (ADR 0020), les deux chemins de la sonde sont un même lecteur interne.
- `sonde_unlink.R` : l'appel doit être refusé avant toute écriture, avec un message « X: sans barre ». La sonde s'arrête alors sur une erreur à la ligne `r <- engine_ecrire_xlsx(...)` : c'est le résultat attendu (#603). Aucune ligne « f.xlsx present dans d : TRUE » ne doit paraître.

## 4. Versement

Remettre à la session les fichiers de `sorties-p/` (ou leur contenu), avec le SHA cité au § 0. La session les verse dans ce dossier, par un commit `docs:` (Refs #602, #603, #604), et met à jour le tableau ci-dessous.

| Point | Condition de la sortie du brouillon | Résultat |
|---|---|---|
| (i) | oui | **OK** : 645 assertions, 645 ok, 0 échec ; trois sauts, dont celui, attendu, du témoin sous 4.2.9 |
| (ii) | oui | **OK** : deux `[OK]` ; `"a\nb"` relu `identical()`, aucun octet 0x0D dans les 4 parties de l'archive |
| (iii) | oui | **OK** : deux `[OK]` ; `C:f.xlsx` refusé (« forme X: sans barre »), aucun `f.xlsx` créé aux trois lieux contrôlés |
| (iv) | oui | **OK** : `sonde_tab` : `identical cellules = TRUE` sur les deux chemins, aucun octet `0d` lu (JS1 : `FALSE` et `61 0d 0a 62` sur le chemin interne) ; `sonde_unlink` : arrêt sur le refus « X: sans barre » avant écriture, aucune ligne « f.xlsx present dans d : TRUE » (JS1 : `TRUE`) |
| (v) | non (relevé) | sous 4.2.9, deux écarts du témoin (`blancs/ligne_finale_note_blanche.xlsx`, `entete/openpyxl_entete_lu_blanc.xlsx`), égaux à la liste datée 4.2.5.2 ; lecteur interne `[OK]`, 38 classeurs sur 38 |
| (vi) | non (relevé, #608) | lettre `Z:` ; dans les quatre cas (`\usp608_s5\f.xlsx` et `/usp608_s5/f.xlsx`, sans puis avec `C:\usp608_s5`), fichier écrit sur `Z:`, lecteur de l'appelant, aucun sur `C:` : **le constat de #608 n'est pas reproduit** dans cette configuration |

### Relevé du 19/11/2026

Rejeu fait par une session locale de Claude Code sur le poste Windows du mainteneur, le 19/11/2026.

- **Contexte** : SHA `8a3ebc52d4086b449f5930caef91db693e711c7e` (tête de S5) ; R 4.3.3 (2024-02-29 ucrt) ; `LC_CTYPE = French_France.utf8` ; `openxlsx` 4.2.9.
- **Code xlsx identique à `e4a8ae4`** : `git diff e4a8ae4 HEAD -- R/engine.R | Select-String -Pattern 'xlsx|xml' | Measure-Object` donne `Count = 0`. La ligne « R/, tests/ et app.R identiques a e4a8ae4 : FALSE » est attendue : depuis `e4a8ae4`, #445, #492 et #387 ont touché `R/engine.R` et `R/display_helpers.R`, hors de la section 7ter. Le § 0, qui attendait une sortie vide, est dépassé sur ce point.
- **Arbre** : « arbre propre : FALSE » vient de deux fichiers non suivis seulement (`sorties-p/`, dossier des sorties, et un fichier de notes du poste) ; aucun fichier suivi n'est modifié.
- **Témoin facultatif** (`tests/test_reproductibilite.R`) : cinq cas `CONFORME` ; `premium_interieur` `NON CONFORME` sur les deux mêmes feuilles de `bootstrap$stats_boot` (13470 et 14469, écart relatif maximal 1,814e-06, 2 658 feuilles non strictement identiques) que le relevé de JS1 (`../20261118-js1-poste-windows/etape-4/sortie_test_reproductibilite.txt`, point 5 de `etape-4-batterie.md`), aux mêmes valeurs. Le code de #445 et de #492 ne change donc rien sous Windows à la dérive déjà connue. `reserve2` est conforme (écart maximal 4,5e-16).
- **(vi), lecture** : la lettre `subst` pointe vers un dossier du lecteur `C:`, et le chemin rendu est la forme résolue de ce dossier. Un poste à deux lecteurs physiques n'a pas été essayé.
- **Pré-vol de #246 sous Windows** (hors étape P) : `tests/double_bootstrap_mw.R --prevol` échoue au débit par sous-processus, sur « Permission denied » à l'ouverture d'un fichier temporaire `k1-1.txt`. La mesure de #246 reste à faire sous Linux, comme prévu.

Sorties, chemins personnels masqués (`<TEMP>`, `<DEPOT>`) : `sortie_i_controles_entree.txt`, `sortie_rejeu.txt`, `sortie_iv_sonde_tab.txt`, `sortie_iv_sonde_unlink.txt` (bruit de PowerShell retiré autour de la ligne « Tracing »), `sortie_test_reproductibilite.txt`.

Conditions de la sortie du brouillon : (i) à (iv) tenues.

Un échec à l'un des points (i) à (iv) devient un problème gardé (E5 : le `.tex` 4.2 dit le défaut corrigé). L'issue est rédigée au compte rendu, créée sur accord du mainteneur, et placée selon l'ADR 0018, § 5 : correctif rapide si elle en remplit les trois conditions, sinon créneau A2. Elle ne retient pas les étapes de code de S5.

Script contrôlé sous Linux le 19/11/2026, en session cloud : (ii) et (iii) passent, avec les verdicts propres à unix ; (v) et (vi) sont sans objet faute d'`openxlsx` et hors Windows. Ce contrôle ne remplace pas le rejeu.
