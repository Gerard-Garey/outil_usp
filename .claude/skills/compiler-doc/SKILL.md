---
name: compiler-doc
description: Compiler la documentation LaTeX (docs/latex/doc_tests_usp.tex) et vérifier le PDF. Deux modes - « contrôle », après toute modification du .tex, sans commiter le PDF ; « fin de branche », pour le commit unique du PDF par la session principale, après le dernier commit du .tex et avant la sortie du brouillon. À utiliser aussi quand on demande de recompiler le PDF.
---

# Compiler la documentation

Le PDF compilé `docs/latex/doc_tests_usp.pdf` est versionné, mais **commité une fois par branche, en fin de branche** (ADR 0008 amendé le 18/10/2026, M37 ; `CONTEXT.md`, « Commit de PDF de fin de branche ») :

- **mode « contrôle »** : après toute modification du `.tex` (passage de `docwriter`, commit `docs:` minimal M32, corrections de la validation d'`actuary` ou de la revue finale). On compile pour vérifier le `.tex`, puis on **restaure le PDF** : le commit porte le `.tex` seul. Le PDF à lire en cours de branche est l'artefact `doc_tests_usp` de la CI ;
- **mode « fin de branche »** : par la session principale seule, une fois que plus aucun commit ne touchera le `.tex`, juste avant la sortie du brouillon. Le commit porte le PDF seul. Toute modification ultérieure du `.tex` (y compris une intégration de `main` qui fusionne deux versions du `.tex`) en demande un nouveau avant la fusion.

Une branche qui ne touche pas le `.tex` n'a pas de commit de PDF. Une intégration de `main` ne recompile pas : en cas de conflit sur le PDF, `git checkout --ours -- docs/latex/doc_tests_usp.pdf`. Un job de CI vérifie sur toute PR non brouillon qu'aucun commit du `.tex` n'est postérieur au dernier commit du PDF.

## Étapes communes

0. **Si `command -v pdflatex` échoue** (session cloud : le hook `SessionStart` n'installe pas TeX Live) : `bash .claude/hooks/preparer_latex.sh --installer` depuis la racine du dépôt, en arrière-plan dès que la tâche touche au `.tex` (plusieurs minutes). En cas d'échec, le PDF ne peut pas être compilé : le dire dans le compte rendu.

1. Depuis `docs/latex/`, compiler :

   ```bash
   pdflatex -interaction=nonstopmode -halt-on-error doc_tests_usp.tex
   ```

   Code de sortie non nul → lire l'erreur dans `doc_tests_usp.log` (lignes commençant par `!`, avec le numéro de ligne `l.NNN`), corriger le `.tex` et recommencer.

2. **Relancer tant que le log le demande** : répéter l'étape 1 tant que `doc_tests_usp.log` contient « Rerun to get cross-references right ». Trois passes en pratique après une modification de structure. Limite : cinq passes ; au-delà, un renvoi oscille et doit être corrigé.

3. **Contrôler le log final** :
   - aucune ligne commençant par `!` ;
   - aucun « undefined » (référence ou citation indéfinie) ;
   - les avertissements `Overfull \hbox` sur les lignes modifiées sont à corriger s'ils débordent visiblement (plus de 10pt).

## Mode « contrôle »

4. **Restaurer le PDF** : `git restore docs/latex/doc_tests_usp.pdf` (depuis la racine du dépôt). `git status docs/latex` ne doit montrer que le `.tex` ; les fichiers auxiliaires (`.aux`, `.log`, `.toc`, `.out`) sont ignorés par Git. Le commit `docs:` porte le `.tex` seul.

## Mode « fin de branche »

4. **Arbre propre** : à la tête de la branche, `git status` ne montre aucune modification hors du PDF ; le dernier commit qui touche le `.tex` est fait (`git log -1 --format=%h -- docs/latex/doc_tests_usp.tex`).

5. **Commit du PDF seul** (`docs:`), dont le message cite :
   - le SHA du dernier commit qui touche le `.tex` ;
   - la chaîne de composition (ligne `Producer` de `pdfinfo docs/latex/doc_tests_usp.pdf`) ;
   - le nombre de pages ;
   - les issues de la branche par `Refs` (jamais `Closes`, qui reste au corps de la PR).

   Ce commit ne compte ni comme passage de `docwriter` ni comme commit d'issue au sens de la règle 9.

La CI compile aussi le `.tex` à chaque push et publie le PDF en artefact : c'est un contrôle, pas une source du PDF versionné.
