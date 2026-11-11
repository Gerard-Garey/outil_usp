# Revue finale complète `app-review` (model opus), branche `claude/tests-et-outillage` (K6, PR #539), 11/11/2026

**Tête** `ccb5771`. **Base** `origin/main` = `12872c3`, qui est aussi la base de fusion. **Profondeur** : revue finale complète (règle 10, M26), en lecture seule. Rien n'a été écrit dans le dépôt et aucune issue n'a été créée.

## Verdict

**Conforme. Aucun constat bloquant, majeur ni mineur ; trois remarques.** Seule `fmt_p()` change dans la partie application. Le changement est de la pure mise en forme, autorisée par `docs/exigences.md` § 4.4 (« formatage des nombres », « décimales »). Sous Linux, l'affichage est identique au caractère près dans l'onglet Tests, au survol plotly, dans la note M1 et dans le rapport figé des six références.

## Périmètre établi

- `git diff 12872c3...HEAD --stat -- app.R R/display_helpers.R` : `R/display_helpers.R` seul, +34 / −9, en un bloc de lignes (`R/display_helpers.R:63-97`). `app.R` est inchangé (`git diff --quiet` rend 0).
- L'ancien `display_helpers.R` (`git show 12872c3:…`) et le nouveau ont été chargés dans deux environnements, et chaque objet comparé par `deparse()`. Seul `fmt_p` diffère. `GROUPES`, `STAT_NOMS_PROBABILITE`, `.num_fr`, `fmt_nb` et `fmt_stat` sont inchangés.
- Appelants de `fmt_p()` :
  - `fmt_stat()` (l. 112) ;
  - `.sous_stat_famille()` (l. 377) ;
  - `table_synthese_groupe()` (l. 405) ;
  - `table_detail_groupe()` (l. 647-649) ;
  - survol de `plot_mw_origine()` (l. 2388) ;
  - `note_m1()` (l. 2736) ;
  - `rapport_html()`, annexe des tests exclus (l. 3442).

  `fmt_p()` appelle `.num_fr()` (l. 51), qui n'a pas changé.

## Points de contrôle

| Point de contrôle | Résultat | Fondement |
|---|---|---|
| Disposition, « Relancer les calculs », aucun calcul déclenché | Conforme, non touché | `app.R` est inchangé ; `fmt_p()` n'intervient qu'au rendu. |
| Onglet Données | Conforme, non touché | `fmt_p()` n'est employée ni dans la saisie, ni dans les contrôles, ni dans l'import. |
| Onglet Tests (p-values, nature, verdict…) | Conforme | Sortie de `table_synthese_groupe` et `table_detail_groupe` (data.frame et HTML) identique avant et après, pour chaque groupe des six références. `premium_interieur` a 5 p-values dans (0 ; 1e-4) et passe donc par la nouvelle branche des petites valeurs. Les champs lus (`p_exacte`, `p_asymptotique`, `p_monte_carlo`, `p_retenue`, `nature_p`, `verdict`) ne changent pas. La distinction test / diagnostic n'est pas touchée. |
| Onglets graphiques | Conforme | `note_m1()` et le texte de survol de `plot_mw_origine()` sont identiques sur `reserve2`, plotly installé (sortie de `plotly_build`). Ces textes lisent `res$plots_data$origine$p` sans calcul. |
| Onglet Calibration | Conforme, non touché | `fmt_p()` n'y est pas employée. |
| Aucun calcul hors du moteur | Conforme | Aucun arrondi propre : ni `signif()` ni `round()`. Deux conversions de format imposé seulement, `"%.4f"` et `"%.2e"` ; l'exposant lu dans `"%.2e"` ne sert qu'à choisir l'écriture. Aucun seuil métier : 1e-4 est une frontière de présentation, déjà présente avant (#323). |
| Messages, aucune erreur R brute | Conforme | Aucune erreur sur les entrées numériques, entières, logiques NA, de longueur 0, NULL, nommées ou matricielles (pour les chaînes non numériques, voir R1). |
| Cohérence onglet Tests / rapport figé / survol | Conforme | Même formateur partout ; sorties identiques avant et après sur les trois rendus. |
| Règles d'affichage des p-values | Conforme | Virgule décimale ; quatre décimales dès 1e-4 ; trois chiffres significatifs en deçà (« 2,48e-05 », « 1e-05 », « 1,5e-05 ») ; jamais « 0,0000 » pour une p-value non nulle (vérifié sur 510 022 valeurs) ; « 0,0000 » pour p = 0 exactement ; tiret pour NA, NaN, Inf et −Inf. La bande [9,995e-5 ; 1e-4) donne « 0,0001 » sans recours au choix de notation de la bibliothèque C, ce qui répond à #479. |

## Constats

- **Bloquant** : aucun.
- **Majeur** : aucun.
- **Mineur** : aucun.
- **Remarques** :
  - **R1, `R/display_helpers.R:81`.** Si `fmt_p()` reçoit une chaîne non numérique, `x <- as.double(v)` émet l'avertissement « NAs introduced by coercion ». La sortie reste celle d'avant (« – »), mais l'ancienne version n'avertissait pas. Ce cas ne se produit pas dans l'application : tous les appels passent des colonnes numériques du moteur. Rien à corriger, signalé pour mémoire.
  - **R2, `tests/unitaires/test_rapport_html.R:2471-2475`.** Sous Linux, l'assertion étendue ne distingue pas l'ancienne version de la nouvelle : l'ancien code la passait déjà sous glibc. Elle ne protège contre une régression de #479 que sur un poste Windows, et toute la CI tourne sous `ubuntu-22.04`. C'est cohérent avec la consigne de #479 (« vérifier ensuite l'assertion sur le poste et en CI »). La vérification sur le poste Windows du mainteneur reste à faire et à tracer dans la PR.
  - **R3, `README.md:171-175`, hors du périmètre de l'application.** La phrase qui range « l'affichage de `fmt_p()` sous la bibliothèque C de Windows (#479) » parmi les échecs Windows connus devient caduque une fois #479 traitée. (À la date de la revue, la référence locale `main` de la session était périmée, à `d783fe4`. La session l'a remise à `12872c3`.)

## Vérifications exécutées

Toutes lancées depuis la racine, avec `LC_ALL=C.UTF-8` et `R_LIBS_USER` pointant sur la bibliothèque du scratchpad.

1. `git diff 12872c3...HEAD --stat -- app.R R/display_helpers.R` et `git diff -U0` : un seul bloc touché, dans `fmt_p()`.
2. Comparaison de l'ancienne et de la nouvelle `fmt_p` côte à côte :
   - seul l'objet `fmt_p` diffère ;
   - 510 022 valeurs, aucune différence : 2e5 sur [9,9e-5 ; 1,01e-4], 2e5 log-uniformes sur [1e-12 ; 1], 1e5 uniformes, 1e4 négatives, plus 0, −0, 5e-324, `double.xmin`, 1e-300, NA, NaN, ±Inf, 1,5 et 2 ;
   - 80 valeurs aux frontières d'arrondi à trois chiffres (exposants −20 à −5), aucune différence ;
   - aucun « 0,0000 » pour p > 0 ;
   - types identiques : entier, NA logique, longueur 0, NULL, noms, matrice ;
   - un exposant à trois chiffres (« 1.50e-005 », ancien msvcrt) est relu correctement.
3. Rapport figé des six références (fichier « avant » vérifié par `cmp` contre `12872c3:R/display_helpers.R`) : **IDENTIQUE**, horodatage masqué, pour `premium`, `premium_ii6`, `premium_interieur`, `premium_net`, `reserve1` et `reserve2`.
4. Onglet Tests reconstitué comme dans `app.R:1512-1530` (`table_synthese_groupe`, `table_detail_groupe` et `html_table` pour chaque groupe, plus `note_m1` et le survol plotly de `plot_mw_origine`) : identique pour les six références (21 objets ; 23 pour `reserve2`).
5. `Rscript tests/unitaires/test_rapport_html.R` : 296 sur 296, 0 échec. `Rscript tests/unitaires/test_application.R` : 215 sur 215, 0 échec.
6. Message de `ccb5771` : préfixe `app:`, accents, `Refs #479`, auteur `Claude <noreply@anthropic.com>`. Aucun mot-clé de fermeture dans `git log 12872c3..HEAD --format=%B`.
7. `git status --short` vide après les vérifications.

## Issue proposée

Aucune : aucun écart. R2 relève de la vérification sur le poste prévue par #479 ; R3 est signalée dans la PR.
