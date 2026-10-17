# Spécification de Fc : validation de l'ajustement lognormal, jackknife et contrôles — point d'arrêt D1-Fc (#227, #224, #213, #158)

> *Rédigé par l'agent actuary (IA)* (fiche `actuary-approfondi`, Opus, effort high ; pas de Fable, Q-Fc-15), le 17/10/2026, sur demande de la session principale. Étape 2 de la branche Fc (`claude/validation-ajustement-lognormal`, PR #324, tête `60f135e`). Versionné par la session principale.
>
> Décisions déjà prises le 17/10 (E-17/10 (Fc)), que ce texte applique :
> - **Q-Fb-11** : règle de #227 ;
> - **Q-Fc-3** : doctrine de l'ensemble des démarrages à l'optimum ;
> - **Q-Fc-4** : champ logique après `kkt_au_moins_un`, patch chirurgical, motif réécrit, pas de lecture de `regulatory` sauf renvoi nouveau ;
> - **Q-Fc-5** : `NA` sans changement de signature ;
> - **Q-Fc-6** : #158 en dernier, D2-Fc, retrait du périmètre si D2-Fc n'est pas levé à la fin de l'étape 5.
>
> Contraintes : C-Fc-1 (aucun champ dans `res$jackknife` ni dans une ligne de test ; `add()` et `engine_registre_tests()` intacts) et C-Fc-3 (signature et colonnes d'`usp_jackknife()` inchangées). La spécification les respecte toutes deux. **Aucun arrêt n'est requis.**

**Marques** : **[V]** vérifié (source citée, ou commande exécutée et sortie lue) ; **[H]** hypothèse ; **[NV]** non vérifié.

## 0. Objet, sources, mesures

**Objet.**
- **#227** : refus d'`usp_valider_ajustement()` jugé sur l'ensemble des démarrages à l'optimum.
- **#224** : réajustements du jackknife refusés par la même règle.
- **#213** : avertissement « volumes x_t constants » ; sort de la ligne Spearman ratio / volume en régime « pertes constantes ».
- **#158** : protocole de mesure borné et options soumises à D2-Fc.

**Sources lues [V].**
- `docs/feuille-de-route.md` : fiche « Branche Fc » (l. 1725-1771 : constats 1 à 5, tableau des étapes, C-Fc-1 à C-Fc-7) ; ligne E-17/10 (Fc) (l. 1977) ; Q-Fb-11 (l. 2809).
- Issues :
  - #227 et le commentaire 6198672213 (avis du 15/10 : règle conservatrice) ;
  - #224 et le commentaire 6198671120 (choix d'`actuary` : écarter du maximum, phrase « année t non évaluable », pas de non-applicabilité de toute la ligne) ;
  - #213 et le commentaire 6038350486 (Spearman ratio / volume en pertes constantes) ;
  - #158 et le commentaire 5891684473 (audit du 29/09 : courbure réelle, non du bruit ; piste « démarrage qui satisfait KKT »).
- `CONTEXT.md` : « Contrôle numérique de l'estimation » (l. 43-48, dont M15, M23, M25 et la limite #158) ; « Contrôle de validité » (l. 169-171, paragraphe #188).
- `R/engine.R` à `60f135e` :
  - `usp_hessienne()` l. 1334, `usp_hessienne_libre()` l. 1366, `usp_pas_newton_borne()` l. 1391 ;
  - `usp_gamma_bord()` l. 1437, `usp_condition_premier_ordre()` l. 1461, `usp_kkt_satisfaite()` l. 1499, `usp_ajuster()` l. 1528-1615 ;
  - `usp_controles_numeriques()` l. 1631-1731, `usp_valider_ajustement()` l. 1757-1786 ;
  - `usp_volumes_constants()` l. 1798, `usp_pertes_constantes()` l. 1812 ;
  - `usp_ajuster_rapide()` l. 4484, `usp_jackknife()` l. 4626-4642 ;
  - R13, `txt_vol_cst` et pertes constantes dans `usp_tests()` l. 4749-4790 ; ligne Spearman ratio / volume l. 5276-5302 ; ligne jackknife l. 6126-6153 ;
  - `engine_valider_donnees()` l. 6618-6752 (avertissement de #189, l. 6728-6736) ; `engine_influence()` l. 6902-6930 ;
  - `run_engine()` l. 11085-11150.
- Tests et scripts : `tests/unitaires/test_controles_numeriques.R` (l. 441-470, 509-523, 610-630, 745-790) ; `tests/unitaires/test_controles_entree.R` (l. 2552-2590, par `git grep`) ; en-tête de `tests/patcher_reference.R` ; `tests/outils_tests.R` (`CAS`) ; usages hors CI d'`usp_valider_ajustement()` (`git grep`, § 2.7).
- `docs/latex/doc_tests_usp.tex` à `60f135e` : l. 586-590, 1966-1972, 2329-2333, 2922-3010, 3327-3365, fiche `fiche:foc` (l. 10070-10335, dont l. 10303-10314), fiche `fiche:jackknife` (l. 11561-11630), `fiche:spearman` (l. 8457), `sec:volumes-constants` (l. 17213).
- Modèle de forme : `docs/specifications/fb-pente-et-constante.md`.

**Mesures exécutées [V].**
- Session cloud Linux, R 4.3.3, BLAS et LAPACK de référence (`libblas.so.3.12.0`), `LC_ALL=C.UTF-8`, moteur de `60f135e`, lecture seule. Durée totale de calcul : environ 9 minutes. Scripts de mesure non versionnés.
- `demarrages()` refait la boucle d'`usp_ajuster()` : même grille, même `optim()`, même règle du premier démarrage à 1e-10, même ensemble `a_optimum`, mêmes `usp_kkt_satisfaite()` et `usp_gamma_bord()`. Elle rend, par démarrage à l'optimum, γ, δ, KKT et « sur une borne ».
- **Statut de toutes les simulations (M3 à M6) : constats de simulation, non versionnés, à ne pas citer au dossier.** Le nombre de jeux fixe l'incertitude de Monte-Carlo, pas l'erreur en T.

| Mesure | Objet | Résultat |
|---|---|---|
| **(M1)** | Constat 1 de la fiche : J1, J2, échantillon complet et huit réajustements du jackknife (`n_starts_delta = 5`) | Complet : 54 démarrages à l'optimum, **aucun sur une borne**, KKT satisfaite (J1 γ = −1,9343, δ = 1 ; J2 γ = −2,3200, δ = 0,664). Jackknife : 30 démarrages à l'optimum (24 pour J2 sans l'année 7), **aucun sur une borne**, KKT satisfaite partout ; γ dans [−2,67 ; −1,87]. Références : `kkt_au_moins_un = TRUE`, 54 démarrages à l'optimum, derniers champs `ecart_jackknife, largeur_ic, largeur_ic_restreint, kkt_au_moins_un`, deux avertissements. **L'hypothèse du constat 1 est confirmée.** |
| **(M2)** | Jeu de #224 : x de J1, y = 0,7 x, y₅ = 0,8 x₅, `run_engine()` prime II-1 | Complet : γ = −3,1194, KKT satisfaite, accepté. Sans l'année 5 : γ = −12 (30 démarrages sur la borne), KKT non satisfaite, **refusé par la règle de #188**. Les sept autres réajustements sont intérieurs, KKT satisfaite. Ligne actuelle : `estim` = 0,3393 ; `detail` « Annee la plus influente : 5 (sigma_USP en baisse). » ; σ_USP = 0,06205954. |
| **(M3)** | Ensembles mixtes à la transition. 20 graines (1000 + s), y = 0,7 x exp(ε w), w centré ; ε localisé par bisection sur la bascule de γ̂ à la borne, puis 81 valeurs sur ± 4e-4 en log ε. Deux bornes, 3 240 jeux. | Borne basse : 800 « tous sur la borne » (KKT non), 810 intérieurs (KKT oui), **10 mixtes, tous KKT oui**, retenu intérieur dans les 10. Borne haute : 801 / 792, **27 mixtes, tous KKT oui** (retenu sur la borne 19, intérieur 8). **Aucun ensemble mixte sans KKT.** |
| **(M4)** | Même famille avec l'optimiseur dégradé (`controle`, factr de 1e7 à 1e13, maxit de 5 à 500), 640 jeux | **Aucun ensemble mixte.** Quand les arrêts sont prématurés, les démarrages se dispersent au-delà de `TOL_OPTIMUM`. |
| **(M5)** | Pilote de #158, quatre générateurs, ε de 1,5e-6 à 1e-2 (en tout environ 5 600 ajustements) | (a) volumes 100 (1 + ε U(−1, 1)), y = y de J1 · exp(N(0, s)), s ∈ {0 ; 0,01}, graine 7, 100 jeux par ε : **7 libellés « courbure non strictement positive » sur 1 600 jeux** (ε = 1,5e-6 à 1,3e-5 ; étendue relative réelle de 2e-6 à 1,7e-5), **tous de verdict OK**, aucun au-delà de 1,3e-5. (b) volumes de J1, J2 ou uniformes comprimés, ratios conservés : **0 libellé sur 3 980 jeux**, δ̂ presque toujours au bord. |
| **(M6)** | Sur les 7 jeux libellés | H_δδ **stable à trois chiffres pour h de 1e-2 à 1e-6** (par exemple −5,71e-11 à toutes les valeurs de h). Plancher de bruit empirique (écart-type de H_δδ(h) sur 20 points décalés de j·1e-12 en δ) : 1e-18 à 3e-17 à h = 1e-4, 2e-16 à 3e-15 à h = 1e-6, soit **5 à 6 ordres de grandeur sous \|H_δδ\|** (2,8e-13 à 5,7e-11). Autres grandeurs : \|∂ln σ/∂δ\| ≤ 5e-7 ; effet de δ sur σ sur tout [0 ; 1], à γ̂ fixé (eff_δ = max_b \|ln σ(b, γ̂) − ln σ(δ̂, γ̂)\|), ≤ 5e-7 ; \|H_δδ\|/H_γγ ≤ 1,8e-12 ; écart relatif de σ entre le démarrage retenu et le premier démarrage qui satisfait KKT ≤ 5,1e-8. Repères par ε (10 jeux) : eff_δ ∈ [1e-6 ; 3,5e-6] à 1e-4, [9,1e-7 ; 6,5e-5] à 1e-3, [1,1e-6 ; 7,1e-4] à 1e-2 ; J1 1,09e-3, J2 5,0e-3. |
| **(M7)** | J1 et J2 | Le démarrage retenu satisfait lui-même KKT (54 démarrages sur 54) ; ε_σ = −3,3e-9 (J1) et 1,7e-16 (J2). |
| **(M8)** | Jeu de #224, écarts du jackknife sans l'année 5 | Sept valeurs égales à 1e-11 près, **six valeurs distinctes** ; `which.max` désigne **l'année 6** ; écart maximal 0,02063. |

## 1. Doctrine commune (D1-Fc)

**Principe (extension de M15, M23 et M25).** Toute décision que le moteur prend sur l'estimateur du maximum de vraisemblance porte sur **l'ensemble des démarrages à l'optimum**, et non sur le démarrage retenu. Ces décisions sont trois : contrôle de validité, condition du premier ordre, convergence. Le démarrage retenu est départagé par l'ordre de la grille et peut changer d'une plateforme à l'autre. Il sert seulement à **calculer** σ̂ (hors module) et à décrire, dans un libellé, le point où σ̂ est calculé.

**Conséquences.**
- **#227** : le volet « borne » du refus passe sur l'ensemble (§ 2).
- **#224** : c'est la même règle, appliquée sans modification à chaque réajustement (§ 3).
- **#158** : le libellé décrit le démarrage retenu, ce qui reste légitime au titre de la description. La question est de savoir si une anomalie de ce point, **sans effet mesurable sur σ**, doit être affichée comme une anomalie. Le § 5 la soumet à la mesure.

## 2. #227 : refus jugé sur l'ensemble des démarrages à l'optimum

### 2.1 Ce que fait la règle ; validité à T = 8

- **Objet.** Contrôle de validité après ajustement. Ce n'est pas un test : aucune loi, aucune p-value. Il établit si le minimum de B(6) / C(6) de l'annexe XVII, dont dépend le paramètre de B(4) / C(4), est déterminé dans le domaine de recherche `BORNES_GAMMA` = [−12 ; 3]. Renvois de #188, lus par `regulatory` en E1g ; non relus ici [NV].
- **Validité à T = 8.** La règle est numérique et ne dépend pas de T. Le refus est **exact au sens de sa définition** (prédicats à tolérance fixe), non statistique.
- **Règle décidée (Q-Fb-11)** : **refus si au moins un démarrage à l'optimum a γ sur une borne et si aucun démarrage à l'optimum ne satisfait la condition KKT.** Le démarrage retenu appartient à l'ensemble à l'optimum (\|vals − best\| = 0 < `TOL_OPTIMUM`) [V, code l. 1563]. La règle nouvelle refuse donc **tout ce que refuse la règle actuelle**, plus les ensembles mixtes dont le démarrage retenu est intérieur. Aucun cas accepté par la règle nouvelle n'est refusé par l'ancienne.
- **Fréquence [V], (M3) et (M4).** Des ensembles mixtes existent : 37 sur 3 240 jeux construits à la bascule de la borne. **Aucun n'est sans KKT**, sur 3 240 + 640 jeux, et l'audit du 08/10 en trouvait 0 sur 96 + 5. Le cas visé reste **théorique** : la règle supprime une dépendance au démarrage retenu (et à la plateforme) qui n'a jamais été observée.
- **Verdict : pertinent** (règle conservatrice, voulue : l'estimateur n'est pas établi, quel que soit le démarrage retenu).

### 2.2 Champ nouveau de `res$ajustement`

- **Nom : `gamma_bord_au_moins_un`**. Logique de longueur 1 : TRUE si et seulement si au moins un démarrage à l'optimum a `!is.na(usp_gamma_bord(gamma_s))`, à la tolérance par défaut `TOL_DELTA_BORD`.
  - Le nom suit `kkt_au_moins_un` et le prédicat `usp_gamma_bord()` de #322.
  - Il est calculé dans `usp_ajuster()` sur **le même** `idx <- which(!is.na(vals) & a_optimum)` que `kkt_ok`, sans deuxième notion d'optimum : `any(vapply(idx, function(i) !is.na(usp_gamma_bord(pars[i, 2])), logical(1)))`.
- **Place.**
  - Dans `usp_ajuster()` : **dernier élément**, après `kkt_au_moins_un`.
  - Dans `run_engine()` : la remise en fin de liste (l. 11140) devient `fit[c(setdiff(names(fit), c("kkt_au_moins_un", "gamma_bord_au_moins_un")), "kkt_au_moins_un", "gamma_bord_au_moins_un")]`. C'est le constat 3 : le patcheur n'ajoute une feuille qu'en fin de conteneur.
- **Références** : `FALSE` sur les cinq cas lognormaux [V, (M1)]. Un booléen n'est pas une valeur numérique : patch admis par l'invariant de `tests/patcher_reference.R` [V, en-tête]. Essai à blanc d'abord [H : accepté ; précédents M25 et #257].

### 2.3 Prédicat d'`usp_valider_ajustement()`

```r
bord <- usp_gamma_bord(fit$gamma)                       # retenu : "basse", "haute" ou NA
bord_ensemble <- !is.na(bord) || isTRUE(fit$gamma_bord_au_moins_un)
refus <- bord_ensemble && !isTRUE(fit$kkt_au_moins_un)
```

- Le `||` rend la fonction **totale** : un ajustement fictif sans le champ, ou une sortie d'`usp_ajuster_rapide()`, garde la règle actuelle.
- Sur une sortie d'`usp_ajuster()`, il est redondant (le retenu est dans l'ensemble).
- Les tests existants sur ajustements fictifs à deux champs (`test_controles_entree.R`, l. 2556) restent vrais sans modification [V, lecture].
- Signature inchangée. `methode` n'agit que sur le motif.

### 2.4 Motif (constat 5)

**Forme 1, démarrage retenu sur une borne** : le motif actuel, **identique octet pour octet** (constat, cause selon le côté, article 220, réserve n° 2, vérification selon le côté).

**Forme 2, démarrage retenu intérieur** (nouvelle). Le côté de la borne n'est pas connu par un logique unique (§ 2.5). Texte ASCII ; `%s` = B ou C ; bornes par `format(BORNES_GAMMA)` :

> `Maximum de vraisemblance non etabli (annexe XVII, %s(6)) : parmi les demarrages qui atteignent l'objectif minimal a la tolerance de l'outil, au moins un a gamma sur une borne du domaine de recherche [-12 ; 3] (BORNES_GAMMA, bornes de l'outil, non reglementaires) et aucun ne satisfait la condition du premier ordre (KKT) ; le demarrage retenu, de gamma interieur, n'est pas un point stationnaire certifie, et les valeurs delta et gamma qui minimisent le montant de %s(6), dont depend le parametre de %s(4), ne sont pas determinees dans ce domaine. Cause : objectif egal, a cette tolerance, au demarrage retenu et sur la borne (ratios y_t/x_t quasi egaux pres de la borne basse ; dispersion des ratios extreme pres de la borne haute).`

Suivie, **sans changement**, de :
- la phrase « L'outil ne calcule pas de parametre sur ces donnees (article 220, paragraphe 1, point a) / b)) … (B(2)(g) / C(2)(e), iii et iv ; article 219, paragraphe 1, point d)). » ;
- pour la réserve n° 1, « La methode du risque de reserve no 2 reste ouverte (meme point). » ;
- puis de la vérification réunie : `Verifier que y_t est observe (%s(1)(a)) et non deduit de x_t par un coefficient fixe, ainsi que les unites, la correspondance des annees et les valeurs aberrantes (%s(1) et %s(2)(a)).`

**Renvois au règlement** : exactement ceux du motif de #188 (B(6) / C(6), B(4) / C(4), art. 220(1)(a) / (b), B(2)(g) / C(2)(e) iii et iv, art. 219(1)(d), B(1)(a), B(1), B(2)(a)), sans formule [V, comparaison au code l. 1765-1784]. Aucun renvoi nouveau : **pas de lecture de `regulatory`** (Q-Fc-4).

### 2.5 Options pour le côté de la borne (Q-D1-Fc-1)

- **(a) recommandé** : un logique unique (décision Q-Fc-4) et la forme 2 sans côté. Le cas est théorique (§ 2.1) ; la forme 2 reste exacte ; un booléen à patcher.
- **(b)** : deux logiques, `gamma_borne_basse_au_moins_un` et `gamma_borne_haute_au_moins_un`, d'où une forme 2 qui nomme le côté. Le coût est un booléen de plus à patcher (précédent #257). C'est un écart à Q-Fc-4, qui demande la décision du mainteneur.
- **Écartée** : déduire le côté de la borne la plus proche de γ̂ retenu. Dans (M3), le retenu intérieur est à moins de 1e-6 de la borne de l'ensemble, mais rien ne le garantit en général.

### 2.6 Critères d'acceptation (étape 3)

Les ajustements fictifs sont des listes `list(gamma, kkt_au_moins_un, gamma_bord_au_moins_un)`, méthodes prime et réserve n° 1.

- **(a) Indépendance du démarrage retenu.**
  - F1 `(-12, FALSE, TRUE)` et F2 `(-11.5, FALSE, TRUE)` : **refus tous deux** ; F1 avec le motif actuel octet pour octet, F2 avec la forme 2.
  - Même chose à la borne haute : `(3, FALSE, TRUE)` et `(2.5, FALSE, TRUE)`.
- **(b) Acceptations** : F3 `(-11.5, TRUE, TRUE)`, F4 `(-12, TRUE, TRUE)` (règle actuelle conservée), F5 `(-11.5, FALSE, FALSE)` (ECHEC non bloquant de la famille H, inchangé).
- **(c) Champ absent ou incohérent** : `(-12, FALSE)` → refus forme 1 ; `(-11.5, FALSE)` → accepté ; `(-12, FALSE, FALSE)` → refus forme 1 ; `(NaN, FALSE)` → refus, borne basse (inchangé).
- **(d) Calcul du champ sur données réelles** : J1 et J2 `FALSE` ; y = 0,7 x `TRUE` et refus forme 1 identique à l'actuel ; `is.logical()`, longueur 1. Le champ est le dernier élément de la sortie d'`usp_ajuster()`, et le dernier de `res$ajustement` après `run_engine()`.
- **(e) Contrôle hors CI**, sur les 3 240 jeux de (M3) : le champ égale `any(bord)` de `demarrages()` dans 3 240 cas sur 3 240, et aucune décision d'acceptation ne change. Les jeux de (M3) sont à la bascule : leur classement mixte peut changer d'une plateforme à l'autre. **Ils ne vont pas en CI.**
- **(f)** Tableau avant / après ; `comparer_references.R --seuil 0` ne montre que `ajustement$gamma_bord_au_moins_un` (5 × `FALSE`) ; σ_USP et verdicts inchangés sur les six cas.

### 2.7 Scripts hors CI

`git grep` [V] relève les appelants d'`usp_valider_ajustement()` : `tests/conservatisme_interieur_t8.R` (l. 1293), `tests/grille_regime_t8.R` (l. 810), `tests/p_conditionnelle_regime_t8.R` (l. 2086, 2267, 2328, 2739, 2751) et `tests/constats_puissance_t8.R` (l. 1065, 1331).
- Tous passent des sorties d'`usp_ajuster()` : le champ y est présent, et la règle nouvelle s'applique d'elle-même.
- Leurs tableaux versionnés ne sont pas recalculés. Aucun ensemble mixte sans KKT n'a été observé (§ 2.1) [H : tableaux inchangés s'ils étaient recalculés].
- Commentaires « refus de #188 » à compléter en « (#188, #227) » : cosmétique, au choix de `coder`.

## 3. #224 : réajustements du jackknife

### 3.1 Ce que mesure la ligne ; avis

- **Nature.** Diagnostic sans loi ni p-value (Quenouille 1949, Tukey 1958, déjà cités).
- **Grandeur.** Δ_max = max_t \|σ_USP^(−t) − σ_USP\| / σ_USP, crédibilité et correction de taille de l'échantillon complet.
- **Défaut, (M2) [V].** Le réajustement sans l'année 5 n'a pas d'estimateur du maximum de vraisemblance : γ = −12, KKT non satisfaite, refusé par la règle de #188. Il fournit pourtant le maximum, 33,9 %, et désigne l'année 5.
- **Exclusion.** Ce nombre n'est pas une influence mesurée : la quantité n'est pas définie. L'exclure du maximum est juste.
- **Formulation.** Il faut dire que l'année n'est **pas évaluée**, et non qu'elle est sans influence. Dans ce jeu, l'année 5 porte toute la dispersion : son influence est en fait extrême, mais non mesurable par σ̂^(−5).
- **Verdict : pertinent après correction** (règle de l'échantillon complet réutilisée).

### 3.2 Comportement

- **`usp_jackknife()`.** Après `f <- try(usp_ajuster(xi, yi, n_starts_delta = 5), silent = TRUE)` :
  ```r
  if (inherits(f, "try-error") || !isTRUE(usp_valider_ajustement(f)$ok)) next
  ```
  - La ligne reste entièrement à `NA` (`sigma`, `sigma_usp`, `delta`, `gamma`), comme un réajustement en échec. Signature et colonnes inchangées (C-Fc-3).
  - `methode` par défaut : seul le motif en dépend, et il n'est pas lu.
  - Un réajustement à γ intérieur sans KKT reste **retenu**, comme l'échantillon complet (ECHEC non bloquant, non refus).
- **`run_engine()`.** `jack_non_evaluables <- which(!is.finite(jack$sigma_usp))` (entiers, éventuellement vide), ajouté à `robustesse`, liste non stockée (C-Fc-1). `ecart_jackknife`, `jack_annee` et `jack_usp` gardent leur calcul sur les seules valeurs finies. Si aucun réajustement n'est évaluable, la ligne reste absente (statu quo, fiche jackknife).
- **`usp_tests()`.** Si `length(rb$jack_non_evaluables) > 0`, une phrase est ajoutée au `detail`, après « Annee la plus influente : … », séparée par une espace :
  - une année : `Annee 5 non evaluable (reajustement sans maximum de vraisemblance etabli, ou en echec) : ecartee du maximum, influence non mesuree.`
  - plusieurs : `Annees 2 et 5 non evaluables (reajustements sans maximum de vraisemblance etabli, ou en echec) : ecartees du maximum, influence non mesuree.`, années jointes par « , » puis « et ».
  - Seuls des numéros d'année sont imprimés. Aucun nombre de réajustement, aucun effectif ni aucune valeur issue des réajustements (#76). Refus et échec ne sont pas distingués : les distinguer exigerait une colonne (C-Fc-3).
- **Graphique d'influence.** `engine_influence()` reçoit `sigma_usp` à `NA` pour l'année. `ecart_sigma` et `fort_ecart_sigma` valent alors `NA`, chemin déjà emprunté par les réajustements en échec. Le rendu d'une couleur `NA` par `display_helpers.R` (l. 1077-1089) n'est pas vérifié [NV] : point d'`audit`. Un défaut éventuel est antérieur à #224 et devient une issue, pas un correctif de Fc.

### 3.3 Critères d'acceptation (étape 4)

- **(a)** Jeu de l'issue : `res$jackknife[5, ]` entièrement `NA` ; le `detail` contient « Annee 5 non evaluable » et pas « Annee la plus influente : 5 » ; `estim` = 0,02063 (à 1e-4). **Ne pas tester le numéro de l'année la plus influente** : (M8), § 3.4.
- **(b)** Signature (`formals`) et `names()` d'`usp_jackknife()` identiques ; `test_rapport_html.R` passe sans modification.
- **(c)** Échec simulé (un réajustement forcé en erreur) : même phrase.
- **(d)** Aucune phrase si toutes les années sont évaluables (J1, J2) ; `comparer_references.R --seuil 0` sans écart.
- **(e)** σ_USP inchangé sur le jeu de l'issue (0,06205954).

### 3.4 Constat hors périmètre : année la plus influente parmi des ex æquo

Sur le jeu de l'issue, une fois l'année 5 écartée, les sept écarts sont égaux à 1e-11 près. `which.max` désigne l'année 6 ([V], (M8)) au gré du bruit d'optimiseur, qui peut changer d'une plateforme à l'autre. C'est contraire à l'argument de #76 (« entier stable »). Le défaut est antérieur à #224, que celle-ci rend visible. **Issue proposée (I-Fc-1, Q-D1-Fc-3)**, création sur accord :

- titre : « moteur: année la plus influente du jackknife désignée parmi des écarts égaux à la précision de l'optimiseur » ;
- libellés `bug`, `needs-triage` ;
- corps : constat (M8) ; piste à faire spécifier par `actuary`, sans décider ici : désigner seulement si l'écart maximal dépasse le suivant d'une tolérance, à justifier ; sinon « années ex aequo » ;
- hors Fc (Fl ou Ff).

## 4. #213 : avertissement « volumes constants » ; Spearman ratio / volume en pertes constantes

### 4.1 Avertissement

- **Prédicat** : `usp_volumes_constants(xt)` seul, sur la série reçue (série retenue pour `run_engine()`), dans le bloc `if (!length(err))` d'`engine_valider_donnees()`. **Immédiatement avant** celui des pertes constantes, dans l'ordre de priorité des motifs (R13 > pertes constantes).
- **Texte**, rédigé comme celui de #189 :

> `Volumes x_t constants a la tolerance relative TOL_DELTA_BORD = %g pres (etendue relative = %.2g) : delta non identifie (la vraisemblance n'en depend pas a cette tolerance pres) ; regression et partition sur le volume sans objet (constante, TOST, pente, Fisher, R2, RESET, Spearman ratio / volume, Breusch-Pagan (Koenker et 1979), White, Goldfeld-Quandt, Brown-Forsythe et Smirnov non applicables) ; verifier la saisie.`

- Arguments : `TOL_DELTA_BORD`, `diff(range(xt)) / mean(xt)`.
- **Fondement de « delta non identifie »** [V, formule] : à x_t = x̄, a_t = δ + (1 − δ) x̄/x_t = 1, donc π_t et l'objectif ne dépendent pas de δ. Dans la bande, la dépendance est de l'ordre de l'étendue relative (pilote (M6) : eff_δ ≈ 9e-8 à une étendue de 2e-6).
- **Liste des lignes** : celle de la règle R13 (commentaire l. 4752-4755 [V]), treize lignes (Breusch-Pagan en compte deux).
- Ni refus ni modification `app:`.

**Critères (étape 5).**
- (a) `x = rep(100, 8)` avec le y de J1 : `run_engine()$ok` TRUE ; avertissement présent, exact, un de plus qu'avant.
- (b) Les noms cités correspondent un à un aux lignes de type « non applicable » dont le `detail` est le motif R13 (test par décompte : 13 lignes).
- (c) Volumes de J1 : absent. Étendue 1e-7 : présent. Étendue 2e-6 : absent.
- (d) Série tronquée par `T` : jugé sur la série retenue.
- (e) Données refusées : absent.
- (f) Assertions cassées listées (nombre ou rang des avertissements, par exemple dans `test_volumes_constants.R`, `test_controles_entree.R`) [NV, à relever par `coder`].
- (g) Références identiques ([V] constat 2 ; J1 : étendue relative 0,258).

### 4.2 Ligne « Independance ratio S/P vs volume » en régime « pertes constantes »

- **Ce que teste la ligne.** H0 : absence d'association monotone entre r_t = y_t/x_t et x_t. p **exacte** par permutation (T ≤ 9, sans ex aequo), valide à T = 8 sans loi limite.
- **En pertes constantes (y_t = c)** : r_t = c/x_t décroît strictement avec x_t. ρ_s = −1, p = 2/8! = 4,96e-5, ECHEC (commentaire du 07/10). La statistique est bien définie, contrairement aux cinq lignes de la régression (variance de y nulle, t non défini).
- **Le rejet n'est pas un artefact.** Des pertes constantes sous des volumes variables contredisent E[Y_t] = β x_t. C'est la seule ligne de H1 sur le volume qui le dise dans ce régime : **type test et verdict conservés** (statu quo sur la décision).
- **Options (Q-D1-Fc-5).**
  - **(b) recommandée** : une phrase de contexte, ajoutée au `detail` de la branche calculée quand `pertes_cst` est vrai (jamais à volumes constants, où la ligne est non applicable), sans nombre :
    > `Pertes y_t constantes a la tolerance relative TOL_DELTA_BORD pres (voir l'avertissement sur les donnees) : le ratio y_t/x_t varie alors en sens inverse du volume ; un rejet traduit des pertes non proportionnelles au volume, ce que teste la ligne.`
  - **(a)** : statu quo, acceptable. L'avertissement de #189 signale déjà le régime, mais il cite cinq lignes non applicables et « verifier la saisie », et le lecteur peut prendre cet ECHEC pour un effet de dégénérescence.
- Effet : hors références. C-Fc-1 respectée (texte seulement).

*Note de correction du 17/10/2026 (validation d'`actuary-approfondi` du passage de `docwriter` ; consignée par `architect`, sans réécriture du texte ci-dessus).* La phrase « C'est la seule ligne de H1 sur le volume qui le dise dans ce régime » (§ 4.2) est inexacte. Le test RESET (famille B, H1, qui régresse aussi sur le volume) reste calculé à pertes constantes et rejette lui aussi : sur les volumes de J1, avec y_t = 80, prime II-1 et B = 99, RESET est ECHEC (p Monte-Carlo 0,01) et Spearman ratio / volume ECHEC (p exacte 4,96e-5) ; mesure d'`actuary-approfondi` du 17/10/2026, que l'auteur de cette note n'a pas refaite. Ce qui suit de la phrase ne change pas : rejet qui n'est pas un artefact, type test et verdict conservés, option (b) décidée (Q-D1-Fc-5). La lecture corrigée (« cette ligne et le test RESET ») est portée par `fiche:spearman` (`10c226a`).

## 5. #158 : protocole de mesure borné et options pour D2-Fc

### 5.1 Ce que dit le pilote ; correction du diagnostic

[V], (M5) et (M6), constat de simulation, à remesurer par le protocole.
- Le libellé apparaît (7 jeux sur 1 600, volumes d'étendue relative de 2e-6 à 1,7e-5, y non proportionnel à x), toujours avec un verdict OK.
- **La courbure négative est réelle, pas du bruit.**
  - H_δδ est stable à trois chiffres pour h de 1e-2 à 1e-6.
  - Le plancher de bruit empirique est 10⁵ à 10⁶ fois plus petit que \|H_δδ\|.
  - Cela confirme l'audit du 29/09 et contredit la cause écrite dans le corps de #158, dans `CONTEXT.md` (« H_δδ tombe sous le bruit ») et dans la fiche `fiche:foc` (l. 10303-10314).
- **Mécanisme [H, cohérent avec les mesures].**
  - À volumes quasi constants, l'objectif profilé est presque plat en δ, localement concave, avec ses minima aux bords.
  - L-BFGS-B s'arrête sur la partie concave, car les écarts d'objectif sont de 1e-11 à 1e-13, sous `factr`.
  - Le démarrage retenu n'est donc **pas** un minimum en δ, et le libellé est exact.
- **Sans effet sur σ** : écart de σ au démarrage certifié ≤ 5,1e-8 ; \|∂ln σ/∂δ\| ≤ 5e-7 ; eff_δ ≤ 5e-7, sous `REP_SIGMA_KKT` = 1e-6.
- **Conséquence.** L'option « courbure immesurable » repose sur une prémisse contredite. Elle n'est retenue que si le protocole trouve des jeux dont le signe de H_δδ change avec h.

### 5.2 Protocole (script `tests/mesure_courbure_delta_158.R`, hors CI ; tableau daté `docs/tableaux/2026MMJJ-issue158-courbure-delta.md`)

Ni bootstrap ni `run_engine()` : `usp_ajuster()`, `usp_controles_numeriques()`, `usp_hessienne()`, `usp_noyau()` et une copie de la boucle des démarrages (comme `kkt_reference()` de `test_controles_numeriques.R`).

**Générateurs.**
- G1 : x = 100 (1 + ε U(−1, 1)), y = y de J1 · exp(N(0, s)), s ∈ {0 ; 0,01} ;
- G2 : volumes de J1 comprimés à l'étendue ε, ratios de J1 ;
- G3 : idem avec J2.

**Grille.** ε ∈ {1,5e-6 ; 2e-6 ; 3e-6 ; 5e-6 ; 1e-5 ; 1,3e-5 ; 2e-5 ; 3e-5 ; 1e-4 ; 1e-3 ; 1e-2}, 100 jeux par cellule, graine 20261018 + indice de cellule. Soit 4 400 jeux, environ 4 min [H, sur la durée du pilote].

**(P1) Plancher de bruit, point (a).** Sur 40 jeux par ε de G1 (s = 0,01) et aux échelles (x, y) × {1e-3 ; 1 ; 1e6} :
- H_δδ(h) au démarrage retenu, pour h ∈ {1e-2 ; 1e-3 ; 1e-4 ; 1e-5 ; 1e-6} ;
- bruit ν̂(h) = écart-type de H_δδ(h) sur 20 points δ̂ ± j·1e-12, pour h ∈ {1e-4 ; 1e-6}.

Classement « réel » si le signe est le même pour tous les h et si \|H(h) − H(1e-2)\| ≤ 0,1 \|H(1e-2)\|, « bruit » sinon. Sortie : médiane et maximum de ν̂(h)/\|H_δδ\| par (ε, h, échelle).

**(P2) Relation ε ↔ (H_δδ, ∂ln σ/∂δ), point (b).** Par jeu des 4 400 :
- libellé, verdict, δ̂ et sa position (bord / intérieur), δ libre ;
- H_δδ, H_γγ, \|H_δδ\|/H_γγ, ∂ln σ/∂δ, eff_δ = max_{b ∈ {0, 1}} \|ln σ(b, γ̂) − ln σ(δ̂, γ̂)\| ;
- démarrages à l'optimum et ceux qui satisfont KKT, écart relatif de σ entre le retenu et le premier démarrage KKT.

Sorties par (générateur, ε) : fréquence du libellé avec IC de Clopper-Pearson à 95 % ; quantiles des grandeurs, séparés entre jeux libellés et non libellés.

**(P3) Effets des options (§ 5.3)**, contrefactuels calculés sur P2 et sur trois ensembles :
- les **1 238 jeux** des générateurs de `test_controles_numeriques.R` (graine 20260924 × 1 051, graine 12345 × 187) ;
- les deux valeurs l du cas `xw` (bascule du bord, l. 509-523) ;
- J1 et J2.

Pour chaque option et chaque valeur de son paramètre :
- nombre de libellés « courbure » restants pour ε ∈ [2e-6 ; 1e-2] ;
- bascules de δ libre vers non libre à ε ≥ 1e-2 et sur les 1 238 jeux ;
- désaccords de la décision `kkt_au_moins_un` avec la règle actuelle (OK → ECHEC et ECHEC → OK) ;
- continuité OK / OK et δ libre au cas `xw` ;
- variation de `stat` sur J1 et J2.

**Bornes.**
- 20 minutes de calcul au total (`timeout` dans le script).
- Écriture incrémentale d'une ligne par cellule. En cas de dépassement, **sortie partielle versionnée** avec la liste des cellules faites, sans relance (leçon du 15/10).
- En tête du tableau : plateforme, version de R, BLAS, graines, durées.
- Statut : constat de simulation, non résultat général.

### 5.3 Options soumises à D2-Fc (après la mesure)

- **(A) δ non libre si \|H_δδ\| ≤ τ·H_γγ** (texte de l'issue). Pilote : jeux libellés à un rapport ≤ 1,8e-12, mais des jeux non libellés à ε = 1e-4 descendent à 2e-13. τ est une constante nouvelle sans ancrage sur la précision de σ : **fragile**, sauf si P3 montre un τ qui sépare sans recouvrement.
- **(B) Troisième état « courbure immesurable »** (texte de l'issue). **À écarter** si P1 confirme le pilote : le libellé serait faux, puisque la courbure est mesurée.
- **(C) Libellé et `stat` lus sur un démarrage qui satisfait KKT** (piste de l'audit). Cohérente avec la doctrine du § 1, mais deux défauts :
  - `stat` cesserait d'être `res$ajustement$erreur_sigma`, d'où une perte de traçabilité, sauf à ajouter des champs (contrat `usp_engine`, donc nouvel arrêt C-Fc-1) ;
  - le libellé ne décrirait plus le point où σ̂ est calculé.

  Variante (C′) : n'imprimer les anomalies du démarrage retenu que si le contrôle sort ECHEC. Plus simple, mais `stat` resterait `NA` sans explication sur un contrôle OK. **À compléter.**
- **(D) Proposition d'`actuary`, absente de l'issue** : δ non libre dans le contrôle quand eff_δ ≤ `REP_SIGMA_KKT`, c'est-à-dire quand δ ne peut pas faire bouger σ de plus que la précision que le contrôle certifie.
  - C'est une généralisation de l'exception « volumes constants » (#58, #71 reprise) : « δ non identifié à la précision du contrôle ».
  - Aucune constante nouvelle ; repère ancré sur M9.
  - Pilote : couvre les 7 jeux libellés (eff_δ ≤ 5e-7) ; références intactes (J1 1,09e-3, J2 5,0e-3).
  - Réserves :
    - à ε = 1e-2, eff_δ descend à 1,1e-6 : bascule possible près de 1 % d'étendue, à mesurer par P3 ;
    - la majoration de premier ordre \|Δ ln σ\| ≤ \|ε_σ(γ)\| + eff_δ donne 2·`REP_SIGMA_KKT` et non `REP_SIGMA_KKT` : à trancher (repère `REP_SIGMA_KKT` ou `REP_SIGMA_KKT`/2) ;
    - elle modifie la règle KKT de #71 (M16, M17, M25) et exige une phrase de libellé (M27).
- **(E) Statu quo documenté.** Le libellé est exact et sans effet sur σ (≤ 5,1e-8 mesuré) ; le régime est irréaliste (volumes égaux à 0,002 % près). Aucun code ; la cause fausse est corrigée dans le `.tex` et dans `CONTEXT.md`, et le critère d'acceptation de l'issue (« aucun libellé pour ε ∈ [2e-6 ; 1e-2] ») est abandonné. #158 se ferme alors sur la documentation.

**Avis préliminaire, avant mesure** : (E) ou (D). (E) si P2 ne trouve aucun libellé au-delà de ε ≈ 3e-5 ; (D) si des libellés apparaissent à des étendues plausibles (≥ 1e-4). (A) et (B) seulement si P1 ou P3 contredisent le pilote. D2-Fc suit la mesure (Q-Fc-6 : retrait du périmètre si D2-Fc n'est pas levé à la fin de l'étape 5).

**Effet sur σ̂** (critère de l'issue). Aucune option ne modifie σ̂ : seul le contrôle change. L'effet de « la variable retirée » se lit sur eff_δ (P2), borné par construction sous (D).

*Note de correction du 17/10/2026 (D2-Fc ; consignée par `architect`, sans réécriture du texte ci-dessus).* La mesure du protocole (§ 5.2 ; `docs/tableaux/20261017-issue158-courbure-delta.md`, commit `6f4bff7`, moteur `cef48a9`) remplace les chiffres du pilote repris au § 5.1, selon la lecture d'`actuary-approfondi` au point d'arrêt D2-Fc :
- « plancher de bruit empirique 10⁵ à 10⁶ fois plus petit que \|H_δδ\| » : la mesure donne un bruit au plus 3,5e-5 \|H_δδ\| au pas h = 1e-4 du moteur et 4,2e-3 \|H_δδ\| à h = 1e-6 (P1, 1 320 évaluations, aux échelles 1e-3, 1 et 1e6 ; H_δδ classé « réel », signe et valeur à 10 % près pour h de 1e-2 à 1e-6, sur 1 320 sur 1 320) — marge plus mince que celle du pilote, conclusion inchangée ;
- « eff_δ ≤ 5e-7 » (§ 5.1 et option (D) du § 5.3) : eff_δ va jusqu'à 1,14e-6 sur les 14 jeux libellés de P2 (T7) ; l'option (D), au repère `REP_SIGMA_KKT`, laisse donc un libellé (T5) ;
- précision de lecture : eff_δ s'entend **aux bornes de [0 ; 1]** (b ∈ {0, 1}, à γ̂ fixé), comme le définit le § 5.2 ; ce n'est pas un maximum sur tout [0 ; 1] ;
- bande des libellés : étendues relatives de 1,5e-6 à 5,4e-5 (et non 2e-6 à 1,7e-5), 14 libellés sur 4 400 jeux, tous OK, aucun à ε ≥ 1e-4 (0 sur 1 200, IC 95 % [0 ; 0,0031]) ; écart relatif de σ au premier démarrage KKT au plus 4,25e-8 (et non 5,1e-8).

Décision D2-Fc du mainteneur (17/10/2026) : **option (E)**, statu quo documenté ; (A), (B), (C), (C′) et (D) écartées ; critère d'acceptation de l'issue (« aucun libellé pour ε ∈ [2e-6 ; 1e-2] ») abandonné ; mécanisme (arrêt de L-BFGS-B dans la région concave) conservé comme hypothèse cohérente avec les mesures, sans mesure complémentaire versionnée. Texte définitif de la limite : `CONTEXT.md`, « Contrôle numérique de l'estimation ».

## 6. Effets attendus par cas de référence

| Cas | #227 | #224 | #213 | #158 | σ_USP | Mode |
|---|---|---|---|---|---|---|
| `premium`, `reserve1`, `premium_ii6`, `premium_net` | `ajustement$gamma_bord_au_moins_un` = `FALSE` ajouté en fin de liste ; aucun refus | aucun changement (8 réajustements valides, (M1)) | aucun avertissement nouveau (étendue 0,258) | aucun changement de libellé (retenu KKT, (M7)), sous toutes les options | inchangé | un patch (#227) |
| `premium_interieur` | idem | idem (8 valides) | aucun (étendue 1,9, constat 2) | idem | inchangé | un patch (#227) |
| `reserve2` | — | — | — | — | — | aucun |

- **Hors références** : refus des ensembles mixtes sans KKT (cas théorique, 0 jeu observé) ; années non évaluables du jackknife (jeu de #224 : 33,9 % → 2,06 %, année 5 non évaluable) ; avertissement « volumes constants » ; phrase Spearman en pertes constantes (si Q-D1-Fc-5 (b)) ; #158 selon D2-Fc.
- Commit à changement de résultat : #227 seul (structure). Aucun σ_USP ni verdict de référence ne change, donc pas de visa au sens de `CLAUDE.md` ; tableau lu par `actuary`.

## 7. Surface documentaire (passage unique de `docwriter`, règle 9 ; M32 pour les écarts de concordance)

Lignes à `60f135e`.

**`.tex`.**
- **#227** :
  - l. 590 (« `$kkt_au_moins_un`, dernier champ » devient faux) ;
  - index l. 2329-2333 (`usp_valider_ajustement()` lit aussi `$gamma_bord_au_moins_un`) ;
  - `sec:controles` l. 3345-3365 (prédicat sur l'ensemble, forme 2 du motif, fondement inchangé) ;
  - l. 2922-3010, 3950, 9763, 11153 (renvois au refus) ;
  - fiche `fiche:foc` l. 10080-10082, 10119, 10186.
  - Décomptes datés l. 1966-1972 : inchangés (datés).
- **#224** : fiche `fiche:jackknife` l. 11561-11630 :
  - rubrique Stat : maximum sur les années **évaluables**, réajustement refusé par la même règle que l'échantillon complet ;
  - phrase « non évaluable » ;
  - l'estimateur jackknife du biais n'est plus calculable dès qu'une année manque ;
  - index l. 887, 2368.
- **#213** : `sec:volumes-constants` (l. 17213 sqq.), avertissement et liste ; paragraphe des pertes constantes l. 3327-3341 (ordre des deux avertissements) ; `fiche:spearman` (l. 8457 sqq.), régime « pertes constantes » si Q-D1-Fc-5 (b).
- **#158** : fiche `fiche:foc` l. 10303-10314, cause corrigée (« courbure réelle, mesurée, sans effet sur σ », avec les grandeurs du tableau de P2), puis option de D2-Fc. **Cette correction est due même si #158 sort du périmètre** (Q-D1-Fc-7).
- **#322** : index des fonctions (`usp_gamma_bord()`).

**`CONTEXT.md`** (par `architect`, C-Fc-7).
- « Contrôle de validité », paragraphe #188 : prédicat sur l'ensemble (`gamma_bord_au_moins_un`), deux formes du motif, réutilisation par le jackknife (#224).
- « Contrôle numérique de l'estimation » : phrase « Exception depuis #188 » alignée ; « Limite dite et acceptée (issue #158) » à réécrire après D2-Fc (la cause « sous le bruit » est contredite, § 5.1).
- « Volumes constants » : avertissement de #213.

**Hors `.tex`.** Corps de #158 (cause) : commentaire de correction par la session principale. Scripts du § 2.7 (commentaires).

## 8. Questions au mainteneur (D1-Fc)

- **Q-D1-Fc-1 — #227, champ et côté.** (a) un logique `gamma_bord_au_moins_un`, et forme 2 du motif sans côté ; (b) deux logiques par côté. *Recommandation* : (a).
- **Q-D1-Fc-2 — #227, texte de la forme 2** (§ 2.4), forme 1 inchangée, renvois identiques et donc sans `regulatory`. *Recommandation* : adopter.
- **Q-D1-Fc-3 — #224.** Phrase du § 3.2 adoptée ; issue **I-Fc-1** (année la plus influente parmi des ex æquo, § 3.4) créée hors Fc. *Recommandation* : oui aux deux, I-Fc-1 rangée en Fl ou Ff.
- **Q-D1-Fc-4 — #213, texte de l'avertissement** (§ 4.1). *Recommandation* : adopter.
- **Q-D1-Fc-5 — Spearman ratio / volume en pertes constantes.** (a) statu quo ; (b) phrase de contexte, type et verdict conservés. *Recommandation* : (b).
- **Q-D1-Fc-6 — #158, protocole** (§ 5.2 : 4 400 + 1 238 jeux, 20 min au plus, sortie partielle versionnée) et menu de D2-Fc élargi à (D) et (E). *Recommandation* : adopter ; (B) écartée sauf contradiction de P1.
- **Q-D1-Fc-7 — #158, documentation de la cause.** Corriger « sous le bruit » dans le `.tex` (passage de `docwriter`, `Refs #158`) et dans `CONTEXT.md`, même si #158 sort du périmètre. *Recommandation* : oui.

## 9. Hors périmètre

- σ̂ et le choix du démarrage retenu.
- `usp_ajuster_rapide()` et les réplications bootstrap sur une borne.
- `BORNES_GAMMA`, `TOL_DELTA_BORD`, `TOL_OPTIMUM`, `REP_SIGMA_KKT`.
- `add()`, `engine_registre_tests()`, Merz-Wüthrich, l'affichage.
- La désignation entre ex æquo du jackknife (I-Fc-1).

## 10. Références

- Quenouille (1949), Tukey (1958), Spearman (1904) : déjà citées par le moteur et le `.tex`, non relues ici [NV].
- Nocedal et Wright (2006), chap. 16 : cité par le moteur pour l'écrêtage, non relu [NV], non invoqué ici.
- Aucune autre référence. Les résultats invoqués sont des propriétés du code ou des mesures du § 0 : inclusion de la règle actuelle dans la règle nouvelle, indépendance de l'objectif vis-à-vis de δ à volumes constants, inégalité de premier ordre sur Δ ln σ.
