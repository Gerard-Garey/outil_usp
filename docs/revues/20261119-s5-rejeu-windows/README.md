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
| (i) | oui | à relever |
| (ii) | oui | à relever |
| (iii) | oui | à relever |
| (iv) | oui | à relever |
| (v) | non (relevé) | à relever |
| (vi) | non (relevé, #608) | à relever |

Un échec à l'un des points (i) à (iv) devient un problème gardé (E5 : le `.tex` 4.2 dit le défaut corrigé). L'issue est rédigée au compte rendu, créée sur accord du mainteneur, et placée selon l'ADR 0018, § 5 : correctif rapide si elle en remplit les trois conditions, sinon créneau A2. Elle ne retient pas les étapes de code de S5.

Script contrôlé sous Linux le 19/11/2026, en session cloud : (ii) et (iii) passent, avec les verdicts propres à unix ; (v) et (vi) sont sans objet faute d'`openxlsx` et hors Windows. Ce contrôle ne remplace pas le rejeu.
