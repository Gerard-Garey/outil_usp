# KR, étape 2 : balayage des chaînes du moteur et mesure de #575 (14/11/2026)

> Versé par la session principale. Branche `claude/passage-de-remise`, SHA du gel `a2f9c3a`.

## (i) Balayage (ajustement A) et renumérotation (ajustement H)

**Méthode** (`balayage_chaines.py`, sortie brute dans `balayage-sortie.txt`) :
- extraction des littéraux de chaîne d'au moins 25 caractères de `R/engine.R` à `9f7290f` (base de l'ajustement G) et à `a2f9c3a` ;
- 543 littéraux disparus ou modifiés ;
- recherche de chacun, normalisé (accents, commandes LaTeX, casse et espaces retirés), dans `docs/latex/doc_tests_usp.tex` et `docs/suivi-documentation/` ;
- filtre : on ne garde que les fragments cités par le `.tex` et absents du moteur gelé, même recomposés (concaténation des littéraux).

Usage : `git show 9f7290f:R/engine.R > <dir>/old.R ; git show a2f9c3a:R/engine.R > <dir>/new.R ; python3 balayage_chaines.py <dir>`.

**Résultat** :
- 12 fragments du filtre ; 10 sont de la prose du `.tex` qui ne cite pas le moteur (énoncés de méthode) ;
- les 2 citations textuelles (`\code{}`) sont **conformes au moteur gelé** :
  - l. 12495 : « un seul cote de la mediane represente : loi de R non definie, test non applicable », composé par `usp_tests()` (`R/engine.R` l. 7027, `paste0(ru$cause, ", test non applicable")`) ;
  - l. 17209 : « Un seul cote de la mediane represente : loi de R non definie. », composé par `mw_tests()` (l. 14001, majuscule et point).
- Hors filtre : le `.tex` l. 4398 paraphrase la phrase retirée par #573 (« le rappel que la méthode n° 2 reste ouverte ») ; c'est déjà dans le brief de `docwriter`. Les occurrences dans `docs/suivi-documentation/` sont historiques par nature.

**Renumérotation** : les cinq renvois de lignes de `R/engine.R` dans `docs/suivi-documentation/` (`III-H.md` l. 52, `III-M.md` l. 72, `IV.md` l. 42 et 227, `annexe.md` l. 14) sont tous **datés à un SHA** (« à la tête `a0ad35f` », « à `cefa3b8` », « à la tête `55ea997` », « à la tête `1a8f4f2` », « à `55ea997` ») : ils restent exacts et **aucune renumérotation n'est requise**.

**Brief de `docwriter`** : rien à ajouter au titre du balayage, hors #573 (l. 4398, l. 4444, puce de `sec:mw`).

## (ii) Mesure de #575 sous `openxlsx` 4.2.5.2

À compléter.
