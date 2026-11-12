# Avis d'`actuary` sur #548 (seuil de M9, reproductibilité sous Windows)

> *Rapport de l'agent `actuary` (IA), fiche de base, rendu le 12/11/2026 à la session principale, hors branche, sur la question décidée par Q-59-6 (a) et reprise par Q-60-7 (a). Versé intégralement par la session principale sur la branche K3b (Refs #548). Arbre lu : `main` `7eca6e4`.*

**Avis : conforme.** Q-59-6 (a) est confirmée, avec deux corrections à porter dans l'annotation (points A et B) et une réserve sur le critère de KR (point C).

## 1. Garder le seuil de M9 est défendable

- **σ_USP ne dépend d'aucun tirage.** `usp_parametre()` (`R/engine.R` l. 2113-2125) ne lit que `fit$sigma`, la correction √((T+1)/(T−1)), la crédibilité et σ standard. Une réplication bootstrap ne peut donc pas changer σ_USP.
- **Une p Monte-Carlo est un rapport de décomptes**, de la forme (k+1)/(B_eff+1) : `p_mc` de BP = 0,377 avec 376 tirages ≥ obs. Une réplication isolée ne la modifie que si sa dérive **franchit la statistique observée** de la même colonne, qui dérive elle aussi. Si elle la franchit, la p bouge d'un pas : 1/(B_eff+1) en queue simple, 2/(B_eff+1) en bilatéral.
- Le verdict, lui, ne change que si ce pas fait passer la p retenue de l'autre côté de α/2 ou de α. La p de famille minP (`engine_p_famille()`, diagnostic INFO) dépend aussi des rangs entre réplications : elle peut bouger si la dérive inverse deux réplications voisines et que cela fait franchir `m_obs`.
- **Mesuré sur la référence** (`tests/reference/premium_interieur.rds`, Rscript en lecture seule) :
  - `stats_boot[13470]` et `[14469]` sont la ligne 483 des colonnes 14 et 15 (`BP`, `BP79`), donc **une seule réplication** ;
  - leurs valeurs (0,0158 et 0,0024) sont loin des observées (0,0750 et 0,0551) ;
  - l'écart relatif minimal de toute réplication à l'observée vaut 1,32e-3 pour `BP` et 1,96e-4 pour `BP79`, soit plus de 100 fois la dérive ;
  - rangs de la réplication 483 : voisines à environ 1e-3 en relatif, aucune inversion.
- **Mécanisme probable, non démontré.** BP79 calcule `sce = sum((g − résidus − mean(g))^2)` (l. 2916-2930) : une somme expliquée petite subit une compensation, et la tolérance relative amplifie l'écart absolu (≈ 2,9e-8 et 4,2e-9).
- **Les conclusions du relevé existant sont déjà là.** `resumer_comparaison()` compte comme écart toute feuille non numérique différente, et toute p_mc ou tout décompte de `p_mc_regime` modifié dépasse 1e-6 en relatif (au moins 1/k). Le relevé du 11/11 (« 2 en écart ») établit donc qu'aucun verdict, aucune p Monte-Carlo, aucun compte du régime V3b et aucune feuille de `parametre_final` n'ont dépassé le seuil sur cette exécution.
- **Portée statistique à T = 8 : nulle.** 1,8e-6 en relatif sur une statistique est très loin de la granularité 1e-3 et de l'erreur Monte-Carlo sqrt(p(1−p)/999) ≈ 0,015.
- **Réserve C, constat nouveau.** La colonne `SF` (p_mc = 0,650, retenue, verdict OK) a une réplication à **3,28e-6** en relatif de l'observée, soit environ 1,8 fois la dérive maximale du poste. `SW` est à 3,6e-5. Ce sont des statistiques concentrées près de 1. Une autre plateforme pourrait donc faire bouger SF d'un pas (0,650 → 0,649 ou 0,651) sans conséquence sur le verdict. Le critère strict de KR échouerait alors pour une raison bénigne. Le critère n'est pas assoupli ; son traitement est fixé au point 2.
- **Pourquoi garder le seuil.** Il garde la CI, plateforme des références (ADR 0011, point 10). Sur une session Linux R 4.3.3 (12/11, `main` `7eca6e4`), `comparer_references.R --deux-parts premium_interieur` donne **0 feuille non identique sur 57 018**. Relever le seuil à 1e-5 affaiblirait la détection d'un facteur 10 partout pour une dérive propre au poste.
- **A. Justification à reformuler.** La phrase du point 7 de l'ADR 0006 (« environ trois fois la dérive maximale mesurée ») est désormais fausse pour le poste. Le seuil se justifie comme garde de la CI, non comme marge du poste.
- **B. Formule à corriger.** « Première mesure de l'écart poste ↔ références CI » contredit l'annotation du 25/09/2026 de l'ADR 0011, qui consigne une mesure du poste contre `d9172c6` (5 505 feuilles ≤ 3,508e-07, alors sous R 4.3.1). Il faut écrire : première mesure consignée du poste **sur `premium_interieur`** (cas créé après, #240), sous R 4.3.3, et première **au-delà du seuil**.

## 2. Critère de la batterie sous Windows, mot pour mot

Il est suffisant et vérifiable, parce qu'il juge l'effet : décomptes, p, verdicts.

> **Critère de la batterie sous Windows** (poste du mainteneur ; KR et toute mesure ultérieure du poste contre les références de la CI). Sur un arbre propre, `Rscript tests/comparer_references.R --deux-parts` (six cas de `CAS`) puis `Rscript tests/test_reproductibilite.R` sont exécutés. La batterie est acceptée si et seulement si :
> (1) pour chaque cas, la part non numérique et la structure sont vides (aucun verdict, libellé, booléen, `NA`, entier, chemin ni nœud modifié) ;
> (2) aucune feuille de `parametre_final` n'est au-delà du seuil `TOLERANCE` = 1e-6, et σ_USP est conforme ;
> (3) aucune feuille de p-value (`tests[[i]]$p_exacte`, `p_asymptotique`, `p_mc`, `p_retenue`, `p_min`, `p_min_mc`, `bootstrap$p_mc`, `bootstrap$p_min_mc`), ni de `bootstrap$B_effectif` ou `bootstrap$p_mc_regime`, n'est au-delà du seuil, et les p-values Monte-Carlo, rapports de décomptes, n'apparaissent pas dans la liste au seuil 0 ;
> (4) le volet `identical()` (deux exécutions sur le poste) est vert ;
> (5) chaque feuille au-delà du seuil est listée (chemin ; statistique et réplication ; valeur de référence ; valeur du poste ; écart et mesure) et expliquée comme feuille d'une matrice de réplications (`bootstrap$stats_boot` ou tirages bootstrap) dont la dérive ne franchit pas la statistique observée correspondante.
> Toute autre feuille au-delà du seuil, ou toute p Monte-Carlo différente d'un pas, arrête la batterie. L'écart est alors porté à `actuary` s'il touche une p-value, au mainteneur s'il touche σ_USP ou un verdict, sans régénération ni changement de seuil. Le code de sortie 1 de `--deux-parts` dû aux seules feuilles du point (5) n'est pas un échec du critère.

## 3. Mesure à faire sur le poste Windows

Depuis la racine, arbre propre, sur la tête mesurée. La locale `French_France.utf8` convient ; le défaut de #113 est propre à Linux.

```
git rev-parse HEAD
git status --short
Rscript -e "sessionInfo(); print(La_version()); print(extSoftVersion())"
Rscript tests/comparer_references.R --deux-parts --markdown %TEMP%\releve_548.md
Rscript tests/test_reproductibilite.R
```

- Le markdown doit être écrit hors du dépôt, pour ne pas salir l'arbre.
- Pour #548 seul, `premium_interieur` suffit en argument. À KR, il faut les six cas.

**Contenu du relevé :**
- commit et état de l'arbre ;
- plateforme : Windows, `R.version.string`, BLAS et LAPACK, locale ;
- la ligne de synthèse de chaque cas ;
- le nombre de feuilles de la part non numérique et de la structure (attendu : 0) ;
- la liste complète des feuilles au-delà de 1e-6 (chemin, référence, valeur, écart, mesure), avec pour `stats_boot` la traduction (ligne, colonne) → réplication et statistique ;
- la confirmation qu'aucune feuille `parametre_final$*`, `*p_*`, `B_effectif` ou `p_mc_regime$*` ne figure dans la liste au seuil 0 ;
- la sortie de `test_reproductibilite.R`, volet `identical()` compris.

## 4. Texte proposé pour l'annotation de l'ADR 0006 (point 7)

> *Annotation du <date> — mesure du poste Windows sur `premium_interieur` (#548).* Le 11/11/2026, sur le poste du mainteneur (Windows 11, R 4.3.3 ucrt), `tests/test_reproductibilite.R` rend `premium_interieur` non conforme. Deux feuilles sur 57 018 dépassent 1e-6, `bootstrap$stats_boot[13470]` et `[14469]`, c'est-à-dire la réplication 483 de `BP` et `BP79` (écarts relatifs 1,814e-06 et 1,779e-06) ; les cinq autres cas restent sous 3,454e-08. C'est la première mesure consignée du poste sur ce cas, postérieur à celle du 25/09/2026 (ADR 0011), et la première au-delà du seuil. Ces deux statistiques, petites (0,0158 et 0,0024) et donc lues en relatif, sont loin des statistiques observées : l'écart relatif minimal de toute réplication à l'observée est de 1,3e-3 pour `BP` et 2,0e-4 pour `BP79`. Aucun décompte Monte-Carlo, aucune p-value, aucun verdict n'est atteint, ni σ_USP, qui ne dépend d'aucun tirage. **Le seuil de 1e-6 est maintenu** (Q-59-6 (a)) comme garde de la CI, plateforme de production des références, où ce cas est reproduit au bit ; il n'est plus une marge du poste, et la justification « environ trois fois la dérive maximale mesurée » ne vaut plus pour lui. Sous Windows, `test_reproductibilite.R` peut donc être rouge sans défaut, et la batterie y est jugée par le critère suivant : [texte du point 2].

## Retour

- **Statut** : `complet` pour l'avis demandé (conforme). Le relevé Windows sur l'état de KR reste à faire par le mainteneur, comme la décision le prévoit.
- **Résultat** : seuil de M9 confirmé. Critère de KR formulé et précisé : effet jugé sur les décomptes, traitement d'un pas de p Monte-Carlo. Annotation rédigée, avec les corrections A et B.
- **Preuves vérifiées** :
  - lecture de `ecart_feuille()` et `comparer_objets()` (`tests/outils_tests.R` l. 373-470), de `TOLERANCE` (l. 70), de `separer_parts()` et `refus_bascule()` (`tests/comparer_references.R` l. 226-256) ;
  - lecture de l'ADR 0006 (second amendement, point 7) et de l'ADR 0011 (annotation du 25/09) ;
  - lecture de `usp_parametre()`, `usp_bootstrap()` (V3b), `engine_p_famille()` et `test_breusch_pagan_original()` ;
  - Rscript sur la référence : indices → ligne 483, colonnes BP et BP79 ; marges de toutes les colonnes ; SF à 3,28e-6 ; δ* intérieurs à au moins 0,0049 du bord ;
  - `comparer_references.R --deux-parts premium_interieur` sous `LC_ALL=C.UTF-8`, Linux R 4.3.3 : 0 feuille non identique.
- **Hypothèses** : le mécanisme de compensation dans la somme expliquée de BP n'est pas démontré. Le déterminisme des p_mc entre plateformes en l'absence de changement de décompte est déduit de l'arithmétique IEEE, non mesuré sous Windows.
- **Non vérifié** : la sortie Windows, non exécutable par l'agent ; les tirages du flux complémentaire V3b, qui ne sont pas stockés, de sorte que leur marge au bord n'est pas mesurable.
- **Décisions non résolues** : le mainteneur adopte, ou non, les corrections A et B et le traitement d'un pas de p Monte-Carlo (point C). L'annotation revient à `architect` à KR.
- **Critères déclenchés** : contradiction de formulation avec l'ADR 0011 (point B), qui relève de la documentation et non du fond. Aucun changement de résultat.
- **Prochaine action recommandée** : le mainteneur lance la mesure du point 3 et dépose le relevé sur #548 ; `architect` annote l'ADR 0006 au premier commit `docs:` de KR et écrit le critère dans la fiche KR.
