---
name: compiler-doc
description: Compiler la documentation LaTeX (docs/latex/doc_tests_usp.tex) et vérifier le PDF avant commit. À utiliser après toute modification du .tex, ou quand on demande de recompiler ou de régénérer le PDF.
---

# Compiler la documentation

Le PDF compilé `docs/latex/doc_tests_usp.pdf` est versionné : il est recompilé et commité avec toute modification du `.tex`, sur le poste local comme en session cloud (ADR 0007).

## Étapes

0. **Rendre `pdflatex` disponible** si `command -v pdflatex` échoue : `source .claude/scripts/preparer_latex.sh` depuis la racine du dépôt (ajout de MiKTeX au PATH sur le poste Windows, installation de TeX Live par apt en session cloud, plusieurs minutes). S'il signale un échec, le PDF ne peut pas être compilé : le dire dans le compte rendu.

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

4. **Vérifier ce qui sera commité** : `git status docs/latex` doit montrer le `.tex` et le `.pdf` modifiés ensemble. Les fichiers auxiliaires (`.aux`, `.log`, `.toc`, `.out`) sont ignorés par Git.

La CI compile aussi le `.tex` à chaque push et publie le PDF en artefact : c'est un contrôle, pas une source du PDF versionné.
