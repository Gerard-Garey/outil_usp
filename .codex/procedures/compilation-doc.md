# Procédure : compiler la documentation LaTeX (GPT)

Le PDF `docs/latex/doc_tests_usp.pdf` est versionné, mais **commité une fois par branche, en fin de branche** (ADR 0008 amendé le 18/10/2026, M37). Deux modes :

- **contrôle** : après toute modification du `.tex`, compiler pour vérifier, puis restaurer le PDF (`git restore docs/latex/doc_tests_usp.pdf`) ; le commit porte le `.tex` seul ;
- **fin de branche** : une fois que plus aucun commit ne touchera le `.tex` de la branche `gpt/…`, juste avant la sortie de son brouillon, un commit `docs:` qui porte le PDF seul, compilé sur un arbre **propre avant la compilation** (aucune modification non commitée ; toute modification après la compilation impose de recompiler) ; son message cite le SHA du dernier commit du `.tex`, la ligne `Producer` de `pdfinfo` et le nombre de pages. Toute modification ultérieure du `.tex` en demande un nouveau.

Une branche qui ne touche pas le `.tex` n'a pas de commit de PDF. Une intégration de `main` ne recompile pas : en cas de conflit sur le PDF, garder la version de la branche qui reçoit. Un job de CI vérifie sur toute PR non brouillon que le `.tex` de la PR est identique à celui du dernier commit du PDF (`.github/workflows/pdf-invariant.yml`).

0. **Si `command -v pdflatex pdfinfo` échoue** : `USP_LATEX=1 bash .codex/setup.sh` (plusieurs minutes). En cas d'échec, le livrable le dit (« PDF non recompilé ») ; en mode « fin de branche », le mainteneur dépose le PDF de l'artefact « Compilation de la documentation LaTeX » de la CI de la PR.
1. **Compiler l'état avant ta modification**, pour avoir une base de comparaison, puis l'état après. Depuis `docs/latex/` :
   ```bash
   pdflatex -interaction=nonstopmode -halt-on-error doc_tests_usp.tex
   ```
   Un code de sortie non nul se lit dans `doc_tests_usp.log` : lignes commençant par `!`, numéro de ligne `l.NNN`.
2. **Relancer tant que le log contient « Rerun to get cross-references right »**. Il faut en pratique trois passes, et au plus cinq ; au-delà, un renvoi oscille.
3. **Contrôler le log final**, en comparant l'avant et l'après :
   - nombre de passes et code de sortie de chacune ;
   - lignes commençant par `!` (aucune) ;
   - occurrences de `undefined` (aucune) ;
   - occurrences d'`Overfull` et d'`Underfull` ; un `Overfull` nouveau de plus de 10pt sur une ligne modifiée est à corriger ;
   - nombre de pages (`pdfinfo`) ;
   - différence des tables des matières, pagination neutralisée.
4. **Vérifier ce qui sera commité** : en mode « contrôle », `git status docs/latex` montre le `.tex` seul, le PDF restauré ; en mode « fin de branche », le PDF seul, sur un arbre propre. Les fichiers auxiliaires sont ignorés par Git. Nommer la chaîne de composition (ligne `Producer` de `pdfinfo`).

La CI compile aussi le `.tex` et publie le PDF en artefact. C'est un contrôle, et une source de repli quand Codex ne peut pas compiler.
