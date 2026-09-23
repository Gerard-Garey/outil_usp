---
status: accepted
date: 2026-09-22
---

# Les références de non-régression sont produites sur le poste local du mainteneur dans l'immédiat ; la CI (Linux, R 4.3.1) est la plateforme cible

## Contexte

Les fichiers `tests/reference/*.rds` sont des photographies complètes d'un résultat de `run_engine()` pour chacune des trois méthodes — environ 12 400 valeurs élémentaires par fichier — que `tests/test_reproductibilite.R` compare au résultat obtenu par `all.equal(tolerance = 1e-8)` (via `tests/outils_tests.R`) [*critère en vigueur à la date de l'ADR, 22/09/2026 ; remplacé par le critère élément par élément à 1e-6 du second amendement, 23/09/2026, ci-dessous*]. Le dépôt annonce, dans `CLAUDE.md` (« Reproductibilité »), `README.md` et `CONTEXT.md` (« Référence de non-régression »), que ce script vérifie une reproductibilité **au bit près**.

**Ce qui a été mesuré.** Lors de l'audit du jalon J1a, puis indépendamment par la session principale, le code de `main` exécuté sous Linux / R 4.3.3 a été confronté aux références versionnées (cas `premium`) :

```
bootstrap$sigma_boot : 995 / 999 tirages differents ; ecart relatif max 3,508e-07
bootstrap$gamma_boot : 998 / 999 ;                     max 1,657e-07
bootstrap$delta_boot :  46 / 999 ;                     max 6,121e-08
parametre_final$sigma_usp : 0,11145243587463113 (ref.) vs 0,11145243587462711 (ici)
objet entier : 5 515 feuilles differentes sur 12 409 (44 %)
mean relative difference : 6,200e-10  ->  all.equal(..., tol = 1e-8) = TRUE (test vert)
```

Deux faits distincts en ressortent :

1. Ce que le script vérifie se dédouble. Le premier volet — `identical()` entre deux appels sur une **même machine** — est bien du bit près, et il tient (mesuré). Le second volet — `all.equal` agrégé contre les références versionnées — ne l'est pas : `all.equal.numeric` compare une différence relative **moyenne**, si bien qu'une dérive diffuse sur 44 % des feuilles passe sous la tolérance. C'est ce second volet qu'un relecteur de l'ACPR exercerait en refaisant les calculs sur sa propre machine.
2. **La branche Merz-Wüthrich est indemne** : `identical(reference_reserve2, calcul_ici)` vaut `TRUE`, 0 tirage différent sur 999 (mesuré sur le triangle de test). La question ne concerne donc que `premium.rds` et `reserve1.rds`. [*Annotation du 23/09/2026 : vrai sous Linux R 4.3.3 (session cloud), faux sous Linux R 4.3.1 (CI) — voir la mesure consignée à la fin du second amendement : 8 feuilles de `reserve2.rds` diffèrent, écart maximal 1,339e-13, sur `tests[[1]]$stat`. « Indemne » doit se lire « à 1e-13 près », six ordres de grandeur sous la branche lognormale ; le point 4 de la décision, qui refusait déjà de faire de `reserve2.rds` une exception, s'en trouve confirmé.*]

**Ce qui est une explication, pas une démonstration.** La branche lognormale passe par `L-BFGS-B` (`usp_ajuster()`, `usp_ajuster_rapide()`) sur une vraisemblance quasi plate en δ — le défaut d'identifiabilité que documente l'issue #5 (§ 2). Sur une surface plate, le chemin de l'optimiseur dépend de l'ordre des opérations en virgule flottante, donc de la bibliothèque BLAS et de la version de R ; `mw_ajuster()`, arithmétique fermée sans optimiseur, n'y est pas exposé. Cette origine est **cohérente** avec la répartition observée des écarts (tirages bootstrap touchés en quasi-totalité, Merz-Wüthrich intact, flux `rnorm` identique — sans quoi les écarts seraient d'ordre 1 et non 1e-7) ; elle n'a pas été démontrée par une expérience qui isolerait la BLAS ou la version de R.

**Ce qui est une présomption.** Les références versionnées semblent avoir été produites sur le poste Windows du mainteneur (R 4.3.1). Indices : le commit qui les a créées (`95dca89`) est signé du compte local du mainteneur, fuseau +02:00, hors session cloud ; et la p-value Monte-Carlo `MeanZ` y vaut 0,742, contre ≈ 0,56 sur la CI Linux R 4.3.1 et 0,674 sous Linux R 4.3.3. Ce second indice doit être lu avec précaution : l'écart sur `MeanZ` relève du défaut de l'issue #3 (statistique dégénérée à δ̂ = 1, comparant du bruit d'arrondi à du bruit d'arrondi), que le jalon J1a supprime ; il **n'est pas** la dérive décrite ici, qui est d'ordre 1e-7 et subsiste après J1a. Rien de plus solide n'est disponible : `nettoyer()` retire `metadata$version_R` avant `saveRDS()` (mesuré : le champ est absent des trois `.rds`), de sorte que les références ne portent aucune trace de leur plateforme de production.

**Trois plateformes sont en jeu** : le poste Windows du mainteneur (R 4.3.1), la CI GitHub Actions (Linux, R 4.3.1, désignée par `CLAUDE.md` comme référence pour R), et les sessions cloud (Linux, R 4.3.3). Sans décision, chaque régénération faite sur une machine différente déplace silencieusement les références (issue #14, point 3). La question s'est posée concrètement sur la branche du jalon J1a, faite en session cloud, qui change deux verdicts (OK → INFO) et impose donc une régénération de `premium.rds` et `reserve1.rds`.

## Décision

Arbitrage du mainteneur (issue #14, commentaire « Décision du mainteneur : poste local dans l'immédiat, CI à terme »), consigné ici pour le dossier :

1. **Dans l'immédiat, le poste local du mainteneur fait foi.** Toute régénération de `tests/reference/*.rds` est faite par le mainteneur, sur son poste, avec `Rscript tests/generer_references.R <cas>`. Cela assure la continuité avec les références existantes : les écarts entre une régénération et la référence précédente ne mêlent pas un changement de plateforme à un changement de méthode, et le tableau avant / après ne contient que ce que la PR a voulu changer.
2. **À terme, la CI (Linux, R 4.3.1) est la plateforme de référence.** C'est la seule plateforme qu'un tiers — un relecteur de l'ACPR — puisse reproduire à l'identique, et `CLAUDE.md` la désigne déjà comme référence pour R. La bascule demande d'outiller la CI pour produire les `.rds` et les récupérer (artefact de workflow ou commit automatisé) ; ce chantier est distinct des jalons de fond en cours et ne doit pas leur être mêlé. Il fera l'objet d'un jalon propre de la feuille de route ; son ADR de mise en œuvre remplacera le point 1 du présent ADR.
3. **Aucune régénération depuis une session cloud** tant que la CI n'a pas pris le relais. Une PR faite en cloud qui change des résultats livre son code et ses tests, laisse les `.rds` à leur état de `main`, et reste rouge sur `tests/test_reproductibilite.R` jusqu'à ce que le mainteneur régénère les références sur son poste et les commite sur la branche. C'est l'état volontaire du jalon J1a sur `claude/admiring-brahmagupta-bunwdf`.
4. **La règle vaut pour les trois fichiers**, y compris `reserve2.rds` dont l'invariance entre plateformes a été mesurée : une mesure sur un triangle n'est pas une garantie, et une provenance unique est plus simple à défendre qu'une exception.
5. **Chaque commit qui régénère un `.rds` indique, dans son message, la plateforme de production** (système, version de R, et BLAS si connue). C'est la trace minimale que les fichiers eux-mêmes ne portent pas, jusqu'à ce que l'issue #14 en décide autrement.

## Considered Options

- **Régénérer depuis la session cloud (Linux, R 4.3.3) qui porte la PR** : écarté. Cela introduirait une **troisième** plateforme dans l'historique des références au lieu d'en retirer une ; et R 4.3.3 n'est ni la version du poste, ni celle de la CI. Le tableau avant / après de J1a mêlerait alors 5 000 feuilles de dérive de plateforme aux deux verdicts que la PR change, ce qui priverait le mainteneur d'un visa lisible.
- **Basculer sur la CI immédiatement** : écarté pour l'instant, non sur le principe mais sur le calendrier. La CI ne sait aujourd'hui que lancer les tests ; produire et récupérer des `.rds` demande un outillage (workflow dédié, artefact, procédure de commit) qui n'existe pas, et le développer au milieu de J1a / J3 mêlerait dans une même série de PR deux motifs de changement des références, contre la règle 1 de la feuille de route (« une PR ne porte qu'un seul motif de changement de résultats »).
- **Conserver la tolérance agrégée et ne rien décider** : écarté. Le test vert masque la dérive au lieu de la restituer, et sans plateforme désignée le prochain contributeur qui régénère déplace les références sans le savoir. Le critère de comparaison lui-même (élément par élément) est traité par l'issue #14, pas ici.
- **Rendre l'estimation insensible à la plateforme** (par exemple en fixant δ à sa borne quand la vraisemblance est plate, ou par un optimiseur déterministe sur grille) : hors du présent ADR. Ce serait un changement de méthode, qui relève de `actuary` et du jalon « identifiabilité de δ » (issue #5, § 2 et § 4.1) ; il ne règle pas la question de la plateforme de référence, il en réduit seulement l'enjeu.

## Conséquences

**Aucun résultat publié n'est en cause.** Les écarts mesurés vont de 3,6e-14 en relatif sur σ_USP (0,11145243587463113 contre 0,11145243587462711, soit 4,0e-15 en absolu) à 3,5e-07 sur les tirages bootstrap, très en deçà de la précision à laquelle les paramètres sont lus et restitués. Ce qui était faux, c'est la garantie annoncée, pas les chiffres.

**La garantie annoncée doit être corrigée** (issue #14, point 2 ; hors du présent ADR, qui se limite à la plateforme). Les formulations à reprendre distinguent deux propriétés qui n'en faisaient qu'une :

| Propriété | Ce qui est vérifié | Statut |
|---|---|---|
| Reproductibilité | `identical()` entre deux appels à graine égale, même machine | au bit près, mesuré |
| Non-régression | comparaison aux références versionnées, produites sur la plateforme désignée par le présent ADR | à une tolérance explicite, entre plateformes ; critère à revoir |

Endroits concernés : `CLAUDE.md` § « Reproductibilité » (« objets identiques au bit près, vérifié par `tests/test_reproductibilite.R` ») ; `CONTEXT.md`, entrée « Référence de non-régression » (« comparé au bit près (tolérance relative 1e-8) », contradictoire en elle-même) ; `README.md` § « Reproductibilité et tests » ; `docs/latex/doc_tests_usp.tex`, sous-section « Reproductibilité et gestion des graines », à traiter avec le jalon J2a (issue #1) — cette dernière est déjà la plus proche du vrai (elle nomme la tolérance et son motif) mais présente encore la seconde comparaison comme une vérification du bit près.

**Le critère de comparaison et la bascule vers la CI sont liés**, et l'issue #14 doit les ordonner : avec des références produites sous Windows, un critère élément par élément à 1e-8 ferait échouer la CI Linux sur la branche lognormale (écart maximal mesuré 3,5e-07). Tant que le point 1 du présent ADR est en vigueur, le seuil élément par élément doit donc être choisi au vu de cette mesure (et justifié comme tel), ou la bascule vers la CI doit précéder le resserrement. Ce n'est pas une raison de différer #14 : c'est la raison pour laquelle sa décision doit être explicite. [*Tranché le 22/09/2026 par la décision M9, première option : seuil choisi au vu de la mesure. Voir le second amendement.*]

**Circuit d'une PR cloud qui change des résultats**, jusqu'à la bascule : `coder` livre code et tests avec les `.rds` de `main` ; `audit` vérifie sur la base du tableau avant / après produit par `tests/comparer_references.R` en session (le tableau distingue les lignes que la PR change de la dérive de plateforme, qu'il faut nommer comme telle) ; le mainteneur régénère sur son poste, commite les `.rds` avec la plateforme dans le message, vise le tableau (décision M3), et la CI redevient verte. Pour J1a, `premium.rds` et `reserve1.rds` sont à régénérer, `reserve2.rds` ne bouge pas.

**Feuille de route** : J1a reste rouge jusqu'à la régénération locale ; un jalon « outillage de la CI pour la production des références » est à ajouter à la prochaine revue, après J1a et J3, avec pour critère d'acceptation qu'une régénération sur la CI reproduise `identical()` les références du poste sur `reserve2.rds` et documente, feuille par feuille, l'écart initial sur `premium.rds` et `reserve1.rds` — ce sera la première mesure directe de la dérive entre les deux plateformes désignées.

Issues : #14 (points 2 et 3 ; le point 1, critère de comparaison, reste ouvert à la date de l'ADR — traité par le second amendement, 23/09/2026), #5 (§ 2, origine du défaut d'identifiabilité de δ), #3 (écart sur `MeanZ`, distinct de la dérive décrite ici). Voir `CLAUDE.md` (« Reproductibilité », « Commandes »), `CONTEXT.md` (référence de non-régression, graine locale), `docs/feuille-de-route.md` (jalon J1a, règles de découpage 1 à 4), ADR 0004 (graine locale : la reproductibilité à graine égale sur une même machine, que le présent ADR ne remet pas en cause).

---

## Amendement du 22 septembre 2026 — le patch chirurgical d'une référence n'est pas une régénération

### Ce que le point 3 laissait sans issue

Tel qu'il était rédigé, le point 3 ci-dessus faisait de la CI rouge l'état normal de toute PR faite en session cloud qui change un résultat, jusqu'à une intervention manuelle du mainteneur. Deux branches s'y trouvaient simultanément (J1a sur `claude/admiring-brahmagupta-bunwdf`, σ̂²_{J−1} sur `claude/sigma-j1-lettre-du-texte`), et aucune ne pouvait être fusionnée. Une PR durablement rouge ne se relit plus : elle rend indiscernables l'échec voulu et l'échec subi.

### Ce que la mesure a montré

L'écart entre les références versionnées et le résultat des branches en question **se sépare en deux groupes disjoints**, et cette séparation est mécanique, pas une appréciation :

| Groupe | `premium` / `reserve1` (J1a) | `reserve2` (σ̂²_{J−1}) |
|---|---|---|
| Changement voulu par la PR | 44 grandeurs | 3 grandeurs |
| Dérive de plateforme | 23 grandeurs, écart relatif max **3,508e-07** | aucune |

Les 44 grandeurs du premier groupe sont : les champs de `tests[[33]]` et `tests[[34]]` (`type` passant de `test` à `diagnostic`, `verdict` de `OK` à `INFO`, statistiques et p-values mises à `NA`), et la disparition de `MeanZ`, `VarZ`, `LB2r`, `BP2r` de `bootstrap$stats_obs`, `bootstrap$p_mc`, `bootstrap$err_mc` et `bootstrap$B_effectif`. **Aucune n'est un nombre** : ce sont des chaînes de caractères, des `NA` et des suppressions d'entrée. Les trois grandeurs du second cas sont deux libellés (`tests[[18]]$detail`, `tests[[19]]$detail`) et un verdict passant de `OK` à `INFO` (`tests[[19]]$verdict`, application de l'ADR 0001 à la ligne M6 de concentration de la réserve). Aucune n'est un nombre non plus.

L'écart relatif maximal du second groupe, 3,508e-07, est **exactement** celui que mesure la section « Contexte » ci-dessus sur `main` : la dérive constatée est celle déjà documentée, et la PR ne l'aggrave pas.

### Décision

**Une troisième voie est ouverte, à côté de la régénération : le patch chirurgical**, outillé par `tests/patcher_reference.R`. Il recalcule le cas, puis reprend du résultat recalculé les **seules** grandeurs désignées par des motifs explicites, et laisse toutes les autres à leur valeur enregistrée, au bit près.

1. **Le patch chirurgical est autorisé depuis une session cloud.** Il est même préférable à la régénération pour ce qu'il sait faire : là où une régénération réécrit les ~12 400 valeurs du fichier avec celles de la machine qui la lance, le patch n'en touche que celles que la PR change. La provenance des valeurs numériques reste unique — le poste du mainteneur — ce que le point 1 cherchait précisément à garantir.
2. **Invariant de sûreté, vérifié par le script avant toute écriture : le patch n'introduit aucune valeur numérique finie.** Il ne peut poser que des chaînes, des `NA`, des booléens, ou supprimer une entrée — c'est-à-dire uniquement des grandeurs insensibles à la plateforme. Une valeur numérique dans le périmètre du patch le fait échouer avec un refus explicite.
3. **Un changement de résultat numérique reste non patchable.** σ_USP, une p-value ou une statistique qui change relèvent du point 1 : régénération sur la plateforme désignée, et visa du mainteneur sur le tableau avant / après. Le patch ne contourne pas cette règle, il en sort le cas où il n'y a, par construction, aucun nombre à produire.
4. **Le script refuse tout ce qu'il ne comprend pas.** Un motif qui ne filtre rien (faute de frappe) fait échouer le patch ; un écart non désigné qui n'est pas imputable à la dérive de plateforme — non numérique, ou supérieur au seuil relatif de 1e-6 — le fait échouer aussi, plutôt que d'être laissé en silence. [*Annotation du 23/09/2026 : depuis le second amendement, le tri des grandeurs différentes est fait par `ecart_feuille()` de `tests/outils_tests.R`, même règle que le comparateur unique — relatif si |ref| > 1e-6, absolu sinon. Une référence nulle est donc jugée en absolu, alors que le tri initial lui donnait un écart relatif `NA` et la classait « SUSPECT » ; le refus vaut désormais pour tout écart au seuil au sens du point 4 du second amendement, non plus pour le seul « seuil relatif ».*]
5. **Quatre vérifications sont exécutées après le patch et avant l'écriture**, et leur sortie est reportée dans le message de commit : toutes les grandeurs non désignées sont `identical()` à la référence ; les grandeurs désignées valent celles du résultat recalculé ; la structure du fichier est celle du résultat recalculé ; et `all.equal(patché, recalculé, tolerance = 1e-8)` vaut `TRUE`, c'est-à-dire que la CI passera au vert [*quatrième vérification telle que rédigée le 22/09/2026 ; depuis le second amendement du 23/09/2026, elle applique le comparateur unique de `tests/outils_tests.R` — critère élément par élément à 1e-6 — et non plus `all.equal` agrégé*].
6. **Les points 1, 2, 4 et 5 de la décision initiale sont inchangés.** Le point 3 est amendé : il ne vaut plus que pour la régénération proprement dite. Le point 5 (plateforme indiquée dans le message de commit) s'applique au patch sous une forme adaptée : le commit indique qu'il s'agit d'un patch chirurgical, les motifs employés, et le compte des grandeurs patchées et laissées. [*Annotation du 23/09/2026 : depuis le second amendement, « différente » s'entend au sens du comparateur unique (écart au seuil 1e-6), et non plus au sens strict. Une dérive de plateforme sous le seuil n'est donc plus une grandeur « laissée » : elle est comptée dans la ligne « Comparaison avant patch » du script (feuilles non strictement identiques, écart maximal), et le compte « LAISSEES » ne recense que les écarts au seuil non désignés par un motif — il vaut toujours 0 quand le patch aboutit, puisque le point 4 fait échouer le patch dès qu'il est non nul. Le message de commit reporte donc : les motifs, le compte des grandeurs patchées, et la ligne « Comparaison avant patch » (qui tient lieu de compte des grandeurs laissées à leur dérive).*]

### Ce que cela ne règle pas

Le patch **ne retire pas** la dérive de plateforme déjà présente dans `premium.rds` et `reserve1.rds` : il la conserve délibérément, faute de pouvoir la distinguer d'une valeur légitime. La bascule vers la CI comme plateforme de référence (point 2 de la décision initiale) reste le seul geste qui l'élimine, et reste à faire. Le patch chirurgical est ce qui permet d'y arriver sans laisser des PR rouges s'accumuler entre-temps.

Il ne dispense pas non plus du tableau avant / après : `tests/comparer_references.R` reste la pièce soumise au mainteneur, et le patch n'en est que l'application mécanique une fois le tableau visé.

---

## Second amendement du 23 septembre 2026 — critère de non-régression élément par élément, tolérance 1e-6 par valeur

### Ce que le critère agrégé laissait passer

La section « Contexte » l'a mesuré : `all.equal.numeric` juge une différence relative **moyenne**. Une dérive diffuse sur 44 % des feuilles, d'écart relatif maximal 3,508e-07, s'y résume en 6,2e-10 et passe sous 1e-8. La portée de cette dilution est toutefois plus étroite que ne le suggère « l'objet entier », et il faut la décrire exactement (mesures du 23/09/2026, R 4.3.3, refaites par `architect`) : `all.equal` sur une liste descend **composant par composant**, et, dans un vecteur, la moyenne ne porte que sur les éléments **différents** (`countEQ = FALSE`, défaut de `all.equal.numeric`). Ainsi un scalaire décalé de 2e-8 dans une liste est détecté (« Component "a": Mean relative difference: 2e-08 ») ; une seule valeur perturbée de 2e-6 parmi 5 000, les 4 999 autres égales, est détectée (« Mean relative difference: 2e-06 ») ; mais la même perturbation, quand les 4 999 autres dérivent de 5e-9, donne `TRUE`. Un changement de méthode localisé n'était donc dilué que s'il tombait dans un vecteur qui dérive **aussi** — ce qui est précisément le cas réel : les tirages bootstrap (`sigma_boot`, `gamma_boot`, 995 et 998 tirages différents sur 999). Le critère agrégé ne restituait donc pas la dérive qu'il absorbait, et il pouvait laisser passer un changement d'un tirage ou d'une statistique dérivée d'un vecteur qui dérive ; un changement sur un scalaire isolé (σ_USP, une p-value) restait, lui, détecté à 1e-8. L'issue #14 (point 1) demandait un critère élément par élément ; la section « Conséquences » ci-dessus avait établi qu'un tel critère à 1e-8 ferait échouer la CI Linux contre des références produites sur le poste, et que le seuil devait être choisi au vu de la mesure ou la bascule CI (jalon J10) précéder le resserrement.

### Décision

Arbitrage du mainteneur (décision M9, issue #14, commentaire du 22/09/2026) : **critère valeur par valeur, tolérance relative de 1e-6**. Sa mise en œuvre, fixée pour `coder`, est la suivante.

1. **Unité de comparaison : la feuille atomique.** L'objet retourné par `run_engine()` (après `nettoyer()`) est aplati par `aplatir()` de `tests/outils_tests.R` en feuilles nommées par leur chemin (`parametre_final$sigma_usp`, `tests[[12]]$p_mc`, `bootstrap$sigma_boot[7]`…). Chaque feuille est jugée **isolément** ; aucune moyenne, aucun agrégat.
2. **Même ensemble de chemins des deux côtés.** Un chemin présent d'un seul côté (champ ajouté, retiré, renommé) est un écart, quelle que soit la valeur.
3. **Feuilles non numériques** (chaînes, booléens, `NA` logiques, facteurs) : `identical()`. **Le type fait partie de la valeur** : une feuille `integer` contre une feuille `double` de même valeur, ou un booléen contre un nombre (`TRUE` contre `1`), est un écart, là où `all.equal` les tient pour égales. C'est voulu : un changement de type est un changement de code, donc de résultat au sens de ce critère, et il doit être nommé dans le tableau avant / après plutôt qu'absorbé. Le comparateur est ainsi plus strict que `all.equal` sur ce point (`ecart_feuille()` exige `typeof` identiques avant toute comparaison numérique).
4. **Feuilles numériques**, notées `ref` (référence) et `val` (résultat courant), avec Δ = val − ref :
   - si l'une des deux est **non finie** (`NA`, `NaN`, `±Inf`) : les deux doivent être `identical()` — un `NA` de référence ne s'échange contre rien, un `NaN` non plus ;
   - sinon, si **|ref| > 1e-6** : |Δ| / |ref| ≤ 1e-6 (tolérance relative) ;
   - sinon : |Δ| ≤ 1e-6 (tolérance absolue).
   C'est la règle de `all.equal.numeric`, appliquée valeur par valeur au lieu de l'être à la moyenne. La bascule vers l'absolu est nécessaire : une grandeur **nulle par construction** — le centrage des résidus, Σ √π̂_t z_t = 0, vaut ~1e-16 par pur arrondi — aurait, d'une plateforme à l'autre, un écart relatif d'ordre 1 sans qu'aucun résultat ait changé.
5. **La structure de l'objet entier est contrôlée à part.** `aplatir()` ne restitue que les feuilles ; les attributs (`dim`, `class`, `row.names`, noms) et les listes vides n'y apparaissent pas. Ils font l'objet d'une comparaison dédiée sur l'objet entier (`structure_arbre()`), qui relève, pour chaque nœud, `typeof` et **tous** ses attributs, et les compare par `identical()` ; les noms d'un scalaire nommé en font partie. Ce contrôle est insensible à la plateforme parce que les seuls attributs présents dans les références sont `class`, `names`, `row.names` et `dim`, de type `character` ou `integer` (mesuré au moment de l'issue #14) ; un futur attribut en double précision y serait jugé au bit près, ce qui peut produire une fausse alerte mais jamais laisser passer un écart.
6. **Un comparateur unique**, dans `tests/outils_tests.R`, appelé par `tests/test_reproductibilite.R` (second volet), `tests/comparer_references.R` (tableau avant / après) et `tests/patcher_reference.R` — à la fois pour le tri des grandeurs différentes avant patch (`ecart_feuille()`, feuille par feuille) et pour la quatrième vérification après patch (`comparer_objets()`). Trois scripts, une seule définition de « même résultat » : le tableau visé par le mainteneur et le test qui passe au vert ne peuvent pas diverger sur ce qu'ils appellent un écart.
7. **Justification du seuil.** 1e-6 est environ trois fois la dérive maximale mesurée entre le poste du mainteneur et Linux R 4.3.3 (3,508e-07, `bootstrap$sigma_boot`, section « Contexte ») ; il absorbe cette dérive avec une marge, tout en restant très en deçà de tout changement de méthode observé jusqu'ici (les écarts d'une correction de formule ou d'un changement de test sont d'ordre 1e-3 à 1, ou portent sur des chaînes et des `NA`). C'est un seuil **empirique**, calé sur une mesure, pas une borne théorique : il vaut tant que le point 1 de la décision initiale (références produites sur le poste) est en vigueur, et il devra être réexaminé — resserré, vraisemblablement — quand la bascule vers la CI (point 2, jalon J10) aura fait de la plateforme de test la plateforme de production des références.

### Ce qui n'a pas été mesuré, et la règle de repli

La dérive de 3,508e-07 a été mesurée en session cloud, **Linux R 4.3.3**, contre les références du poste. L'écart contre la plateforme de la CI, **Linux R 4.3.1**, n'a jamais été mesuré directement : la CI était verte sous le critère agrégé, ce qui ne dit rien de l'écart maximal par feuille. La première exécution de la CI sur le commit qui met en œuvre ce critère constitue donc cette mesure.

**Repli**, décidé à l'avance pour ne pas laisser une PR rouge s'installer (premier amendement) : si cette première CI passe au rouge sur `tests/test_reproductibilite.R` — c'est-à-dire si l'écart poste / CI dépasse 1e-6 sur au moins une feuille —, le commit est annulé par un commit de retour (`git revert`), le critère agrégé reste en vigueur, le point 1 de l'issue #14 rejoint le jalon J10 (bascule CI, branche F), et la branche de travail en cours continue avec ses autres issues. Le seuil ne sera **pas** relevé pour faire passer la CI : un seuil relevé au-delà de la mesure qui le justifie ne serait plus justifié, et l'écart mesuré sur la CI ira alors nourrir la décision de J10 (qui élimine la dérive plutôt que de l'absorber).

### Mesure du 23 septembre 2026 sur la CI (annotation)

La première exécution de la CI sur le commit de mise en œuvre (`f7e6d4f`, branche B, PR #57 ; Linux, R 4.3.1) a donné, contre les références produites sur le poste du mainteneur, la ligne de synthèse par fichier suivante :

| Fichier | Écart maximal par feuille | Où | Sous le seuil 1e-6 |
|---|---|---|---|
| `premium.rds` | 3,508e-07 | `bootstrap$sigma_boot` | oui |
| `reserve1.rds` | 3,508e-07 | `bootstrap$sigma_boot` | oui |
| `reserve2.rds` | 1,339e-13 | `tests[[1]]$stat`, 8 feuilles non strictement identiques | oui |

Trois enseignements. (1) **Le repli est sans objet** : la CI est verte au critère strict, le point 1 de l'issue #14 est clos par la branche B et ne rejoint pas J10. (2) **La dérive poste / CI R 4.3.1 sur la branche lognormale est exactement celle mesurée en session cloud R 4.3.3** (3,508e-07, même feuille) : la version mineure de R n'y change rien, ce qui est cohérent avec l'explication par la BLAS et l'optimiseur donnée en section « Contexte » (cohérence, toujours pas démonstration). Le seuil 1e-6 conserve sa marge (≈ 3 ×). (3) **La branche Merz-Wüthrich n'est pas strictement indemne sous R 4.3.1** : 8 feuilles diffèrent à 1,339e-13 (`tests[[1]]$stat`), alors que l'objet entier était `identical()` sous R 4.3.3 (section « Contexte », point 2, annoté en place ; issue #14). C'est un écart d'arrondi de dernier bit, six ordres de grandeur sous la dérive lognormale et treize sous le seuil ; il ne remet en cause ni le critère ni le point 4 de la décision initiale (aucune exception pour `reserve2.rds`, désormais justifiée par une mesure et non plus par prudence). Il modifie en revanche le critère d'acceptation du jalon J10 énoncé en « Conséquences » de la décision initiale (« une régénération sur la CI reproduit `identical()` les références du poste sur `reserve2.rds` ») : ce critère est faux tel quel et sera réécrit dans l'ADR de mise en œuvre de J10, avec la tolérance observée.

### Conséquences

- **Aucun résultat ne change** ; les `.rds` ne sont pas régénérés. Seul le juge change, et il devient plus exigeant : tout ce que le critère agrégé acceptait à tort (une valeur déplacée dans un vecteur qui dérive, comme les tirages bootstrap) est désormais un écart nommé par son chemin.
- **Le tableau avant / après** produit par `tests/comparer_references.R` et le verdict du test reposent sur la même fonction ; la ligne « dérive de plateforme » du tableau y est définie comme « feuille numérique dont l'écart est sous le seuil », et non plus par appréciation.
- **Le premier amendement est inchangé sur le fond** ; sa quatrième vérification (point 5) applique le comparateur unique, ce qui est annoté en place.
- **Les points 1 à 5 de la décision initiale sont inchangés.** Le seuil est indexé sur le point 1 (plateforme de production) et sera réexaminé avec le point 2.
- `CONTEXT.md`, entrée « Référence de non-régression », énonce le critère et renvoie ici ; `CLAUDE.md`, `README.md` et `docs/latex/doc_tests_usp.tex` sont à aligner par leurs responsables respectifs.

Issues : #14 (point 1, clos par le commit de mise en œuvre si la CI reste verte), jalon J10 (`docs/feuille-de-route.md`, bascule CI ; reprend #14 point 1 en cas de repli). Décision M9 (`docs/feuille-de-route.md`, tableau des décisions du mainteneur).
