# Revue finale complète (règle 10), `audit` en effort high : branche K6 « Tests et outillage », 11/11/2026

**Base** : `12872c3` (= `origin/main`). **Tête** : `ccb5771`. **PR** : #539, brouillon. **Périmètre lu** : `git diff 12872c3...HEAD` en entier (8 fichiers, +270/−68), avec chaque fonction touchée, ses appelants et ses appelés : `nd_avec_env`, `nd_passe_mesure`, `nd_raison_imprimee`, `nd_texte_regle_pages`, `nd_imprimer_pages`, `nd_main`, `nd_verdict_fiche`, `lancer`, `fmt_p`, `.num_fr` et les appelants de `fmt_p`, `.mw_summary_lm`, `controler_motifs`.

## Verdict : conforme avec réserves

Aucun constat bloquant ni majeur. Deux constats mineurs et des remarques. Réserve de fond : la portabilité sous Windows (#477, #479, et #478 en session française) n'est établie ici que par raisonnement et émulation. Elle reste à confirmer à l'étape 7, sur le poste du mainteneur.

## Constats

**Bloquant** : aucun. **Majeur** : aucun.

**M1 — README périmé après fusion, absent de la PR** (`README.md:170-174`, hors du périmètre C3-K6). Le paragraphe « Sous Windows, quelques assertions de la batterie échouent… (#477), (#478), (#479) » énumère les trois défauts que la branche corrige. Le message de `ccb5771` le dit « signalé dans la PR », ce qui n'était pas encore le cas. Correction suggérée : un point dans « Hors périmètre ». Décision au mainteneur.

**M2 — L'assertion #323 ne mord pas sous Linux sur le défaut qu'elle ferme** (`tests/unitaires/test_rapport_html.R:2471`, `R/display_helpers.R:80`). Remettre `"%.3g"` laisse l'assertion verte en CI, car la glibc écrit « 0.0001 ». Mesure : un `sprintf` posé dans l'environnement de `fmt_p` émule le `%g` de Windows. L'ancienne version donne `1e-04` sur la bande (défaut de #479 reproduit) ; la nouvelle, `0,0001` (insensible) ; le mutant `ex >= -3L` est attrapé. Correction suggérée : ajouter dans l'assertion #323 un volet qui évalue `fmt_p` avec ce `sprintf` émulé.

### Remarques (sans reprise)

- **R1** : le `main` local de la session était périmé (`d783fe4`), ce qui fausse un `git diff main...HEAD` littéral (150 fichiers). La revue a pris `12872c3` pour base. *(La session a remis `main` à `12872c3` ensuite.)*
- **R2 — #477** : un retour à `system2(env = …)` ne serait pas décelé sous Linux. Les 9 assertions de restauration mordent sur `nd_avec_env` (oubli de restauration, remise à vide au lieu de `Sys.unsetenv`).
- **R3 — `nd_avec_env` (l. 915)** : un `vars` non nommé n'est pas refusé explicitement, mais `Sys.setenv` lève alors une erreur, sans effet résiduel. Sous Windows, restaurer une variable vide la supprime ; sans portée ici.
- **R4 — passe de remplissage sous Windows** : `.Platform$path.sep` est nécessaire (« C: »). Le séparateur final est sûr sous kpathsea, mais non vérifié sous MiKTeX. Défaut antérieur, hors diff : MiKTeX ne lit pas `max_print_line`, `error_line` ni `half_error_line`.
- **R5** : la sortie de `mesure_dw_rho_negatif_t8.R` (l. 396) dit « erreur numérique de quadrature », l'en-tête « de quadrature et de uniroot() » (voir Q1).
- **R6** : section « État » de la PR non à jour ; pied d'attribution du corps de PR à mettre dans la forme demandée.

## Vérifications

- **Périmètre (C3-K6)** : conforme. Exactement les 8 fichiers autorisés. Dans `R/display_helpers.R`, seule `fmt_p()` change ; dans `test_merz_wuthrich.R`, seule l'assertion #203 ; dans `test_rapport_html.R`, seule l'assertion #323 de la frontière ; dans `CONVENTIONS.md`, seul le § 5. `tests/outils_tests.R` et les fichiers interdits ne sont pas touchés.
- **`controle_doc_nd.R`** : comparaison objet par objet avec `12872c3`. Ajouts : `nd_avec_env`, `nd_raison_imprimee`, `nd_texte_regle_pages`. Données modifiées : `EXCEPTIONS_PLAFOND` seule. Fonctions modifiées : `nd_imprimer_pages`, `nd_main`, `nd_passe_mesure` seules. Motifs, exceptions de motifs et seuils identiques. Les 13 exceptions ont mêmes labels, pages et budgets, et la raison reconstruite est identique à l'ancienne.
- **Sorties avant / après** (`.aux`, `.log`, `.pdf` compilés de `12872c3`) :
  - défaut, `--bloquant`, `--pages-seules`, `--max-lignes=0` : codes 0 / 0, seule la ligne « Regle : » diffère ;
  - `--motifs-seuls`, `--debordements` : codes 0 / 0, aucune différence ;
  - `--bloquant` avec `.aux` absent, et `--bloquant` avec `.log` absent : codes 2 / 2, le bloc (a) est imprimé avant le refus ;
  - `--bloquant --pages-seules` avec `.aux` absent : codes 2 / 2, aucune différence ;
  - `--remplissage` (pdflatex réel) : codes 0 / 0, seule la durée diffère.
- **Fonctions** :
  - `nd_avec_env` : promesse forcée après `Sys.setenv` ; `on.exit` posé avant ; vecteur vide sans effet.
  - `lancer()` : trois assertions de restauration de `LC_ALL`.
  - `nd_passe_mesure` : `TEXINPUTS` identique sous Linux.
  - `fmt_p` : 0 différence sur 340 023 valeurs ; noms, matrice, longueur 0, entiers et NA rendus à l'identique ; exposant à trois chiffres relu.
  - Assertion #203 : même reconnaissance que `.mw_summary_lm()` (`R/engine.R:10921-10930`).
- **Mordant** :
  - #203 : 1 échec sous `fr_FR.UTF-8` avant, 112 sur 112 après, sous `en` comme sous `fr`.
  - #475 : l'ordre est vérifié par index de ligne.
  - #477 et #479 : voir R2 et M2.
- **#502** : mesure refaite de façon indépendante (`usp_ajuster()`, 49 couples) : 26 sur 49 ; (1,1) = 51, (1,3) = 53, (2,4) = 51, (3,7) = 54. Conforme à l'en-tête et à la note. Le titre de #502 et `I.md` l. 97 sont démentis.
- **Références** : `test_reproductibilite.R` OK sur 6 cas, écart maximal 0 ; `tests/reference/` non touché.
- **Git** : aucun mot-clé de fermeture dans les messages ; 5 commits de `Claude <noreply@anthropic.com>`, un par issue ; préfixes conformes ; pieds présents.

## Question pour actuary

**Q1** : le statut de `mesure_dw_rho_negatif_t8.R` dit l'erreur numérique « contrôlée par le recoupement par simulation ». Un recoupement de N tirages ne décèle qu'une erreur supérieure à son erreur Monte-Carlo. « Contrôlée » convient-il ? Et faut-il citer l'erreur de `uniroot()` dans la sortie ? *(Traitée : avis d'actuary, `actuary-libelle-502.md`.)*
