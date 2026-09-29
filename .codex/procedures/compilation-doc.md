# Procédure : compiler la documentation LaTeX (GPT)

Le PDF `docs/latex/doc_tests_usp.pdf` est versionné. Il est recompilé et commité **avec** toute modification du `.tex` (ADR 0008).

0. **Si `command -v pdflatex` échoue** : `USP_LATEX=1 bash .codex/setup.sh` (plusieurs minutes). En cas d'échec, le livrable le dit (« PDF non recompilé »), et le mainteneur dépose le PDF de l'artefact « Compilation de la documentation LaTeX » de la CI de la PR.
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
4. **Vérifier ce qui sera commité** : `git status docs/latex` montre le `.tex` et le `.pdf` ensemble. Les fichiers auxiliaires sont ignorés par Git. Nommer la chaîne de composition (ligne `Producer` de `pdfinfo`).

La CI compile aussi le `.tex` et publie le PDF en artefact. C'est un contrôle, et une source de repli quand Codex ne peut pas compiler.
