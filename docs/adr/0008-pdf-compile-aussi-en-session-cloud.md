---
status: accepted
date: 2026-09-22
---

# Le PDF de la documentation se compile et se commite aussi depuis une session cloud ; sa chaîne de composition peut changer d'un commit à l'autre

## Contexte

Le PDF compilé `docs/latex/doc_tests_usp.pdf` est un livrable versionné, recompilé et commité avec toute modification du `.tex` (`CLAUDE.md`). Jusqu'ici, seul le poste local du mainteneur le recompilait ; la fiche `docwriter` interdisait de le commiter depuis une session cloud. Motif mesuré : le PDF du poste est composé par MiKTeX (pdfTeX 1.40.29), celui des conteneurs cloud par TeX Live 2023/Debian (pdfTeX 1.40.25) ; même source, même nombre de pages (109), mais 994 632 octets contre 824 136, soit 17 % d'écart de taille.

Conséquence observée le 22 septembre 2026 : chaque branche touchant au `.tex` devait être reprise sur le poste local avant fusion (PR #15, #16, #17, #18), et une session cloud ne pouvait pas terminer une modification de la documentation. Avec une seule branche de travail (ADR 0007), c'est la dernière raison de faire passer le travail par le poste local.

## Décision

Arrêtée par le mainteneur le 22 septembre 2026.

1. Le PDF est recompilé et commité avec le `.tex` **dans tout environnement**, poste local ou session cloud.
2. `pdflatex` est rendu disponible par le hook `SessionStart` `.claude/hooks/preparer_latex.sh` : ajout de MiKTeX au PATH sur le poste Windows ; en session cloud, installation de TeX Live par apt **à la demande** (`--installer`, lancé par la skill `compiler-doc`), pour que les sessions qui ne touchent pas au `.tex` ne paient pas plusieurs minutes d'installation.
3. Le compte rendu de compilation nomme la chaîne utilisée (ligne `Producer` du PDF).

## Options écartées

- **PDF recompilé seulement sur le poste local** (règle antérieure) : une seule chaîne de composition pour le livrable, mais une session cloud ne peut pas terminer une modification du `.tex`, et le mainteneur doit reprendre chaque branche.
- **PDF produit et commité par la CI** : une chaîne unique et neutre, mais des commits poussés par un robot sur la branche de travail, à rapatrier dans chaque copie, et un droit d'écriture à donner au workflow.

## Conséquences

- La chaîne de composition du PDF versionné peut alterner entre MiKTeX et TeX Live d'un commit à l'autre. Le contenu ne change pas ; la taille, la compression et les métadonnées changent. Tout commit du PDF enregistre de toute façon un binaire complet : l'alternance n'alourdit pas l'historique davantage.
- Si le dossier remis à l'ACPR doit porter une chaîne unique, une recompilation finale sur le poste local suffit ; elle n'est pas imposée par le présent ADR.
- La liste des paquets TeX Live du hook suit le préambule du `.tex` : tout nouveau `\usepackage` peut exiger un paquet de plus.
