# Revue finale d'`audit` sur K2b (étape 10, règle 10)

> Versée par la session principale (condensé fidèle). `audit`, effort high. 14/11/2026. Tête `8d4ced3`, base `8205955`. Sondes : `scratchpad/audit/sonde.R`, `sonde2.R` (session, non versées).

**Verdict : conforme avec réserves.**

**Remarque préalable.** Dans la session, openxlsx ne se chargeait pas (`stringi` manquant) : la batterie « avec openxlsx » de la session avait sauté les parités. L'agent a compilé `stringi` ; avec openxlsx 4.2.9, `test_controles_entree.R` : 435/435, aucun saut. La CI avait passé le job de parité sous openxlsx 4.2.5.2 (exécution 43529857660). *La session a relancé la batterie avec openxlsx après la reprise.*

## Constats

- **M-1 (majeur)**, `R/engine.R:8952-8953` : seuls `xl/sharedStrings.xml` est contrôlé, alors qu'openxlsx (`read.xlsx.default`) prend toute entrée qui finit par `sharedStrings.xml`. Classeur forgé avec `Target="strings/sharedStrings.xml"` et table `<si><r><t>1</t></r><r><t>1.5</t></r></si>` : openxlsx `ok = TRUE`, 11,5 lu 1 ; interne : refus en aval. Même chose pour X1. Deux tables : openxlsx s'arrête sur « Expecting a single string value ». Décision du mainteneur requise (refus ou limite consignée).
- **m-1 (mineur)**, `R/engine.R:8985-8986` : `<si><t>1</t><x:t>1.5</x:t></si>` lu 1 sur les deux chemins, accepté (X1 ne compte pas les `<t>` préfixés).
- **m-2 (mineur)**, `.github/workflows/ci.yml:360-361, 397, 367` : « À CONFIRMER » périmé (versions confirmées par l'exécution 43519555424) ; « 403 sur 403 » périmé.
- **m-3 (mineur)**, `tests/unitaires/test_controles_entree.R:3157, 3163` : libellé « NA puis refus en aval » inexact pour la forme X1 en ligne (lue `"1</t><t>1.5"` par openxlsx).

## Vérifié sans constat

Références de cellule (décisions 3 et 8) ; retrait de `<rPh>` en deux temps attentif aux guillemets (M1 de l'audit de la reprise de #557 levé) ; ordre des contrôles Q-F, P2, X1 ; MW-04 seulement si `nrow > ncol` ; `.refus_ecriture()` ; `proteger_export()`. Formes admises sans divergence entre chemins (deux `<t>` dans un `<r>`, `<rPh></rPh>` vide, `<rPh>` dans un `<r>`, `<r foo="1">`…). Robustesse : 20 000 chaînes, contrôles en 0,22 s, `.xml_textes()` en 2,5 s. Architecture, CI (cache propre, versions contrôlées, branchement à `tests-moteur`, `[saute]` bloquant), traçabilité `.tex` ↔ code, 29 commits de l'auteur Claude sans mot-clé de fermeture.

## Suite

Mainteneur : refus dans K2b. Texte fixé par `actuary` ; reprise unique par `coder-approfondi` (`c848562`, `585a40d`, `20f7d50`) ; audit léger de la reprise : `audit-leger-reprise-m1.md`.
