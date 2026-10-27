# Spécification de Fn — graphiques et incertitude du bootstrap (#306, #305, champ de #190) — point d'arrêt D1-Fn

> **Décisions du mainteneur du 27/10/2026 (point d'arrêt D1-Fn franchi)**, toutes selon les recommandations, questions soumises par la session principale :
> - Q-D1-Fn-1 : **(A)**, bandes ponctuelle et simultanée à 90 % tirées de `z_boot` ;
> - Q-D1-Fn-2 : règle de rang de l'**éq. (4.17)** de Davison et Hinkley ; le QQ-plot garde la sienne jusqu'à #385 ;
> - Q-D1-Fn-3 : bande **inconditionnelle** ; limite écrite dans la fiche ; issue n° 1 du § 9 créée (**#386**) ;
> - Q-D1-Fn-4 et Q-D1-Fn-5 : plan de mesure, critère K-C1 à K-C4 et profils Ψ0 à Ψ4 approuvés tels quels avant toute exécution ; I4 mesuré comme candidat ;
> - Q-D1-Fn-6 : cible σ0 ; A1 et E[corr·σ̂]/σ0 descriptifs ; `regulatory` non consulté ;
> - Q-D1-Fn-7 et Q-D1-Fn-8 : échelle de σ_USP, repères, régimes, « effectif », deux méthodes ; forme du « basic » ; issue n° 2 du § 9 (Merz-Wüthrich) créée (**#387**) ;
> - Q-D1-Fn-9 : D2-Fn toujours tenu, sur le « basic » et, sous Ψ2 ou Ψ3, sur le libellé « Intervalle bootstrap 90 % » ;
> - Q-D1-Fn-10 : pièces de la consultation versées dans `docs/tableaux/20261027-fn-pilote.md`.
>
> *Rédigé par l'agent actuary (IA).* Consultation `actuary-approfondi` du 27/10/2026, en lecture seule, demandée par la session principale ; versionnée par la session principale avant décision (`192a84d`, comme D1-Fk), décisions ajoutées ensuite. Elle porte sur la fiche « Branche Fn » du quarante-deuxième point d'étape (E-27/10 (42e point), Q-42-9 à Q-42-12) et sur la branche `claude/incertitude-bootstrap-graphiques` (tête `2295d97` ; relevé des sources `90c6590`, lu le 27/10). Périmètre fermé, dans l'ordre des commits : #190, #306, #305 (et #380, sans objet ici). Ordre S-Fn-1 à S-Fn-7.
>
> **Point d'arrêt D1-Fn** (*franchi le 27/10/2026*) : aucun code de #306, ni de la mesure ou du code de #305, tant que le mainteneur n'a pas tranché les questions Q-D1-Fn. #190 n'en dépend pas : le § 7.1 confirme seulement sa forme.

**Marques** : **[V]** vérifié (source citée avec `fichier:ligne` ou page, ou commande exécutée dont la sortie a été lue) ; **[P]** vérification partielle (source secondaire, résumé ou notice) ; **[H]** hypothèse ou raisonnement non mesuré ; **[NV]** non vérifié.

## 0. Sources, mesures, contraintes

**Lu [V]** :
- issues #190 (corps ; commentaires `5999798264`, `6019187314`, `6435443589`), #306 (corps ; commentaire `6261949593`) et #305 (corps ; commentaire `6388164820`) ;
- fiche « Branche Fn » (`docs/feuille-de-route.md:2394-2453`), lignes E-27/10 (42e point) (l. 2685) et M42 (l. 2686) ;
- `docs/specifications/fk-lecture-conjointe.md`, pour la forme ;
- `docs/references/verifications-fn.md` à `90c6590`, relevés du 25/10 et du 27/10, R27.1 à R27.6 ;
- `docs/revues/20261015-pertinence-tests-graphiques/bloc-4.md` (§ 4.8) et `bloc-1.md:101` ;
- `R/engine.R` (md5 `17dad9e6c1ebc2477eb7e4c33b77b270`) : `usp_noyau()` (l. 1237-1252), `usp_regime()` (l. 1936-1953), `usp_parametre()` (l. 1956-1970) ; `usp_bootstrap()` (l. 4815-5001), `usp_ajuster_rapide()` (l. 5016-5032), `usp_ajuster_contraint()` (l. 5043-5054) ; ligne de l'IC dans `usp_tests()` (l. 6961-6986) ; `engine_enveloppe_qq()` (l. 7772-7865) et `engine_plots_data()` (l. 7867-7950) ; `mw_parametre()` (l. 8948-8962), `sigma_boot` de `mw_bootstrap()` (l. 10770-10804), IC Merz-Wüthrich (l. 12108-12111) ; IC lognormal (l. 12627-12647) ;
- `R/display_helpers.R:635-649` (`plot_spread()`), `:909-920` (`plot_boot_sigma()`), `:2352-2360` (rapport) ; `app.R:1474-1487` (bloc Calibration) ;
- `doc_tests_usp.tex:13079-13175` (fiche de l'IC) et `:13638-13662` (fiche dispersion-niveau).

**Faits de forme confirmés [V]** :
- `plots_data$sigma_boot` porte σ\* brut (`R/engine.R:7912`, issu de `:4965`).
- `res$ic_bootstrap` porte les quantiles 2,5 / 5 / 50 / 95 / 97,5 % de `cred·σ*·√((T+1)/(T−1)) + (1−cred)·σ_std` en lognormal (`:12630-12632`) et de `cred·σ* + (1−cred)·σ_std` en Merz-Wüthrich (`:12108-12111`). Recalculés par la même expression depuis les références, ces quantiles sont `identical()` à `ic_bootstrap` dans les six cas (script `g_oracles.R`).
- Ces deux applications de σ\* vers l'échelle de σ_USP sont affines, croissantes, de pente a = c·√((T+1)/(T−1)) en lognormal et a = c en Merz-Wüthrich, et d'ordonnée b = (1−c)·σ_std. L'image de σ̂ est exactement σ_USP (`usp_parametre()`, `mw_parametre()`).

**Mesures de cette consultation [V]** : R 4.3.3, session cloud, 4 cœurs, 27/10/2026, moteur md5 ci-dessus. Scripts hors dépôt (scratchpad de la session ; à verser selon Q-D1-Fn-10) : `a_refs.R` (loi bootstrap des six références) ; `b_spread.R` (bandes du lissage sur `z_boot`) ; `c_cout.R` (coûts unitaires, identité de la boucle allégée avec `usp_bootstrap()`) ; `d_hors_ech.R` (taux de sortie hors échantillon) ; `e_cond.R` (bande conditionnelle au régime) ; `f_pilote.R` (pilote de couverture, annexe A) ; `g_oracles.R` (intervalles sur l'échelle de σ_USP, six cas) ; `h_rang.R` (règle de rang de l'éq. (4.17) contre celle du moteur).

**Contraintes** : le moteur seul calcule, l'affichage ne fait que tracer ; aucune source d'aléa nouvelle dans le moteur (bandes et marques lues dans `z_boot`, `sigma_boot`, `delta_boot`) ; σ_USP, verdicts et p-values inchangés ; tout champ numérique nouveau passe par une régénération CI ; la mesure de #305 se fait dans un script nouveau, sans modifier le moteur.

---

## 1. S-Fn-1 (#306) : graphique dispersion-niveau

### 1.1 Ce que montre le graphique

Le nuage (x_t, √|z_t|) et la courbe `lowess(x, √|z|)` (`R/engine.R:7891`) sont une aide à la lecture de H2 : une structure de variance résiduelle en fonction du volume, non captée par π_t(δ, γ). Le graphique n'est ni un test ni une source de p-value ou de verdict (ADR 0001). À T = 8, `lowess` avec f = 2/3 lisse sur 5 points (fenêtre `round(f·n)`) avec 3 itérations robustes ; les arguments explicites `f = 2/3, iter = 3, delta = 0,01·étendue(x)` redonnent la courbe actuelle à l'identique (`identical()` TRUE sur J1 et J2).

### 1.2 Mesures sous le modèle ajusté (bootstrap paramétrique réajusté, `z_boot`) [V]

| Grandeur | J1 (`premium`, δ̂ = 1) | J2 (`premium_interieur`, δ̂ = 0,664) |
|---|---|---|
| \|fin − début\| > 0,3 (référence, B = 999) | 43,5 % | 43,2 % |
| Amplitude de la courbe : médiane ; q90 | 0,519 ; 0,842 | 0,611 ; 0,947 |
| Amplitude observée ; son rang dans la loi simulée | 0,591 ; 0,378 | 0,611 ; 0,501 |
| Bande ponctuelle 5-95 % : part des courbes simulées qui en sortent en au moins un point, hors échantillon (8 graines 1001 à 1008, B = 999 ; évaluation sur un bootstrap indépendant de B = 8 000, graine 424242) | 40,2 à 44,5 % (moyenne 42,2 %) | 44,1 à 47,3 % (moyenne 45,7 %) |
| Bande simultanée, règle du moteur (QQ-plot) : k\* ; taux hors échantillon | k\* = 9 à 11 ; 8,9 à 11,7 % (moyenne 10,3 %) | k\* = 8 ou 9 ; 7,8 à 11,8 % (moyenne 10,25 %) |
| Bande simultanée, règle de l'éq. (4.17) : k\* ; taux in-sample ; taux hors échantillon | k\* = 8 à 10 ; moyenne 9,3 % ; 8,3 à 10,6 % (moyenne 9,2 %) | k\* = 7 ou 8 ; moyenne 9,45 % ; 6,8 à 10,7 % (moyenne 9,2 %) |
| Courbe observée hors de la bande ponctuelle, ou de la bande simultanée (référence) | non, non | non, non |

Lectures :
- **La bande ponctuelle seule ne sert pas de critère** : une courbe tirée sous le modèle en sort plus de 4 fois sur 10. C'est le phénomène décrit par Davison et Hinkley (1997, § 4.2.4, p. 153 ; exemple 4.7 : environ 0,5 de chance de sortie contre 0,1 ponctuellement) [V, R27.3]. Le chiffre de 46 % de #306 (z i.i.d. normal) est retrouvé sous le modèle ajusté : 43 % [V].
- **La bande simultanée est calibrée sur ces deux jeux**, à environ 10 % nominal : constat de simulation sur deux jeux, pas un résultat général.
- **Puissance contre une hétéroscédasticité résiduelle : non mesurée [NV].** Avec une amplitude médiane de 0,52 à 0,61 sous le modèle, seule une structure forte sortira de la bande. Une courbe dans la bande n'est pas une preuve d'adéquation.

### 1.3 Options

- **(A), recommandée** : deux bandes, ponctuelle et simultanée, à 90 %, construites sur les B_eff lignes finies de `z_boot`, sans aucun tirage — construction de l'enveloppe du QQ-plot (#47, Atkinson 1981). Davison et Hinkley recommandent de tracer les deux (1997, § 4.2.4, p. 154 : « it seems wise to plot envelopes corresponding to both pointwise […] and simultaneous […] error rate ») [V, R27.3].
- (B) la bande simultanée seule.
- (C) le retrait de la courbe `spread_lisse`, motivé par écrit (`docs/exigences.md` § 5.4) : **pas justifié**, la bande simultanée rendant la courbe lisible au taux mesuré.

### 1.4 Spécification de la bande (option A)

- **Courbes simulées** : pour chaque ligne b entièrement finie de `boot$z_boot`, `stats::lowess(fit$x, sqrt(abs(z_boot[b, ])), f = SPREAD_LOWESS_F, iter = SPREAD_LOWESS_ITER)`, avec deux constantes nouvelles `SPREAD_LOWESS_F <- 2/3` et `SPREAD_LOWESS_ITER <- 3L`. L'appel observé (`R/engine.R:7891`) passe aux mêmes constantes ; la courbe actuelle est inchangée [V]. Les colonnes de `z_boot` sont dans l'ordre des années, comme `fit$x` (`R/engine.R:4831-4833`) ; `lowess` rend ses points dans l'ordre croissant de x, alignés sur `spread_lisse`. Matrice L (B_eff × T). Une ligne dont la sortie de `lowess` n'est pas finie est écartée (garde ; cas non observé).
- **Bande ponctuelle** : quantiles 5 % et 95 % de type 7 par colonne de L, avec `ENVELOPPE_QQ_PROBS` et `ENVELOPPE_QQ_NIVEAU` (pas de constante dupliquée). Davison et Hinkley (éq. (4.16), p. 152) prennent les statistiques d'ordre de rang k et B + 1 − k avec k/(B + 1) = p ; le type 7 est retenu par cohérence avec le QQ-plot et `res$ic_bootstrap` (écart de convention, sans [X], R27.3).
- **Bande simultanée** : bornes Sc[k\*, ] et Sc[B_eff + 1 − k\*, ], Sc = L triée par colonne.
  - **Convention de rang** (Q-D1-Fn-2), recommandation : celle de l'**éq. (4.17)** de Davison et Hinkley (p. 153-154 [V]) et de `boot::envelope` (`bootfuns.q:1888` [V, R27.3]) : une ligne sort si, dans au moins une colonne, sa valeur est ≤ Sc[k, ] ou ≥ Sc[B_eff + 1 − k, ] (rang ≤ k ou ≥ B_eff + 1 − k) ; taux rapporté à B_eff ; k\* = plus grand k dont le taux est ≤ `ENVELOPPE_QQ_TAUX_MAX`.
  - Raison : (4.17) estime, par retrait de la ligne, le taux de sortie d'une courbe **nouvelle**, ce qu'est la courbe observée. La règle du moteur (`taux_hors()`, inégalités strictes, bande construite avec la ligne elle-même, `R/engine.R:7845-7846`) donne le même taux au rang k + 1, d'où un k\* plus grand d'une unité [V, `h_rang.R`]. Mesure : 9,2 % hors échantillon avec (4.17), contre 10,3 % avec la règle du moteur, pour 10 % nominal.
  - La règle du QQ-plot n'est **pas** modifiée dans Fn (#385). L'écart entre les deux graphiques est écrit dans les deux fiches tant que #385 n'est pas tranchée.
  - Conséquence de (4.17) : k = 1 n'est plus admissible par construction ; si le taux à k = 1 dépasse 0,10, pas de bande simultanée (`NA`, motif), comme l'avertissement de `boot::envelope` (`bootfuns.q:1907-1908`).
- **Dégénérescences** (seuils du QQ-plot) : B_eff < `ENVELOPPE_QQ_B_MIN` (20) → quatre bornes à `NA` ; B_eff < `ENVELOPPE_QQ_B_MIN_SIM` (500) → bande ponctuelle seule.
- **Volumes constants** (`usp_volumes_constants(x)`) : graphique sans objet (courbe constante, mesuré) ; bornes à `NA`, motif « volumes constants : graphique dispersion-niveau sans objet ». Aucun cas de référence concerné.
- **Régimes de δ\*** (Q-D1-Fn-3), recommandation : bande **inconditionnelle** sur toutes les lignes de `z_boot`, comme le QQ-plot. Raisons : (1) la courbe observée est calculée avec δ̂ réestimé, sa loi de référence est celle de la même statistique sous le modèle ajusté, réestimation comprise ; (2) le flux complémentaire V3b ne conserve pas les z\* (`R/engine.R:4912-4914`), et une bande conditionnelle se limiterait aux lignes V1 de régime intérieur (203 sur `premium_interieur`, 46 sur `premium`, sous le seuil de 500) ; (3) tout tirage nouveau est interdit.
  - **Sensibilité [V, `e_cond.R`]** : sur `premium_interieur`, la bande simultanée conditionnelle au régime intérieur (203 lignes, k\* = 2, règle du moteur) **exclut** la courbe observée en x = 300 (rang 0,005 dans la loi intérieure, contre 0,107 dans la loi inconditionnelle). Le régime change donc la lecture en un point du cas de référence ; constat sur une bande in-sample à faible granularité (k\* = 2), sans valeur probante. Il va dans la fiche comme limite datée ; issue proposée au § 9.

### 1.5 Restitution

- **Champ** `plots_data$spread_enveloppe`, ajouté **en fin** de liste (§ 7) : `bandes`, data.frame de T lignes dans l'ordre de `spread_lisse` (`x`, `bas`, `haut`, `sim_bas`, `sim_haut`), et les champs de description de `qq_enveloppe` (`source`, `B_eff`, `niveau_ponctuel`, `niveau_simultane`, `k`, `taux_global_ponctuel`, `taux_global_simultane`, `B_min_simultane`), plus `regle_rang = "DH1997_4.17"` et `motif` (`NA` sauf dégénérescence).
- **Affichage** (revu par `app-review`) : les deux bandes en aplat, intérieure ponctuelle et extérieure simultanée, sous la courbe et le nuage, en base R et en plotly ; légende « niveau 90 % » lue dans `niveau_*`, sans littéral.
- **Fiche** `fiche:spread-location` (étape 5) : construction et règle (4.17) ; lecture : seule une sortie de la bande simultanée est un signal, au taux nominal de 10 % (mesuré à 9,2 % sur J1 et J2) ; une sortie de la bande ponctuelle se produit sous le modèle dans 42 à 46 % des cas ; aucune p-value ni aucun verdict ; puissance non mesurée ; mélange des régimes et sensibilité de `premium_interieur`. La phrase « seule une pente très prononcée doit être retenue » est remplacée par cette lecture chiffrée.

### 1.6 Tests unitaires

Bande ponctuelle égale aux quantiles de type 7 sur une matrice jouet ; k\* selon (4.17) calculé à la main sur un jeu de rangs connu, y compris « aucun k admissible » et les ex æquo ; courbe observée `identical()` avant et après le passage aux constantes ; `.Random.seed` inchangé ; seuils B_eff < 20 et < 500, motif à volumes constants ; chemins existants identiques à seuil 0 sur les cinq cas lognormaux.

---

## 2. S-Fn-2 (#305) : mesure de la couverture

### 2.1 Objet et paramètre cible

**Cible principale** : σ0 = σ(δ0, γ0) du modèle simulé (`fit$sigma` à la vérité). Les intervalles restitués sont sur l'échelle de σ_USP, image affine croissante de σ (a > 0, § 0) : [ℓ, u] couvre σ0 si et seulement si [aℓ + b, au + b] couvre aσ0 + b, c'est-à-dire σ_USP évalué aux vrais paramètres, la fonctionnelle qu'estime σ_USP [V, raisonnement]. Mesurer sur σ suffit pour les deux lectures ; la mesure ne dépend ni de c, ni de σ_std, ni du segment.

**Lecture auxiliaire, descriptive** : cible c·σ0 + (1−c)·σ_std, où le facteur √((T+1)/(T−1)) serait lu comme une correction de petit échantillon de σ̂ ; revient à la couverture de σ0 par [corr·ℓ, corr·u]. La spécification ne tranche **pas** le sens réglementaire du facteur [H, hors du champ d'`actuary` ; `regulatory` si le mainteneur le souhaite].

### 2.2 Plan

**Jeux** : J1 = `tests/donnees/donnees_ln.csv`, δ0 = 1, **sur la borne** (cas d'Andrews) ; J2 = `tests/donnees/donnees_ln_interieur.csv`, δ0 = 0,664, intérieur. T = 8, volumes x fixés. Paramètres vrais : ajustement `usp_ajuster()` de chaque jeu, σ0 = 0,105310 (J1) et 0,068955 (J2) [V].

**Chemin de chaque jeu simulé r** :
1. y⁽ʳ⁾ = `usp_simuler(fit0)`, sous `engine_sous_graine(G_ext(r))` ;
2. `engine_valider_donnees()` avec les arguments du cas `premium` ;
3. `usp_ajuster()` ;
4. `usp_valider_ajustement(fit, "premium")` ; refus et échecs comptés et rapportés à part ; couverture conditionnelle à l'acceptation ;
5. **`usp_bootstrap(fit_r, B = 999, seed = G_int(r))`**, chemin du moteur (option (a) de Q-D1-Fn-4) ; σ\* = `$sigma_boot`, σ\*_r = `$sigma_boot_restreint`.

**Graines déclarées** (r = 1, …, R, R ≤ 50 000) :

| Jeu | G_ext(r) | G_int(r) |
|---|---|---|
| J1 | 305 200 000 + r | 305 300 000 + r |
| J2 | 305 250 000 + r | 305 350 000 + r |

Les graines du flux complémentaire, G_int + 539 169, commencent à 305 839 170 : aucun chevauchement [V, arithmétique]. Plages disjointes de celles du pilote (305 000 000 + r et 305 100 000 + r, r ≤ 300). Chaque r porte ses propres graines : le résultat ne dépend pas du nombre de processus.

**Niveaux** : 90 % (principal : ligne de diagnostic et libellé) et 95 % (affiché dans le bloc Calibration).

### 2.3 Intervalles calculés par le script

Calculés sans toucher au moteur, sur l'échelle de σ, par quantiles empiriques q\_p de type 7 de σ\* (ceux de `res$ic_bootstrap`). Niveau 1 − 2α, α par queue.

| Code | Intervalle | Bornes 1 − 2α | Source |
|---|---|---|---|
| I1 | percentile | [q\_α, q\_{1−α}] | D-H (1997) § 5.3.1, éq. (5.18), p. 203 ; E-T (1993) § 13.3, éq. (13.3)-(13.4), p. 170 [V, R27.2, R27.5] |
| I2 | « basic » | [2σ̂ − q\_{1−α}, 2σ̂ − q\_α] | D-H § 5.2.1, éq. (5.6), p. 194 (nom et formule) ; E-T § 13.4, éq. (13.9), p. 174 (même borne, sans le nom) [V] |
| I3 | restreint (percentile de σ\*_r) | [q^r\_α, q^r\_{1−α}] | descriptif ; intervalle `ic_bootstrap_restreint` |
| I4 | « basic » sur l'échelle logarithmique | [σ̂²/q\_{1−α}, σ̂²/q\_α] = exp(2 log σ̂ − log q) | D-H § 5.2.1, éq. (5.10), p. 195 : « The accuracy of the basic bootstrap confidence limits (5.6) will also tend to be improved by use of such a transformation » ; exemple 5.4, p. 203 [V, R27.2] ; c'est `boot::boot.ci(type = "basic", h = log, hinv = exp)` (code de `boot:::basic.ci`, boot 1.3.30 [V]) |
| A1 | percentile × corr | [corr·q\_α, corr·q\_{1−α}] | lecture auxiliaire du § 2.1, descriptive |

I4 est **proposé par cette spécification** (Q-D1-Fn-5) : σ est un paramètre d'échelle, et le pivot log σ̂ − log σ est le candidat naturel de (5.10). Sa quasi-pivotalité est une hypothèse [H], que la mesure tranche pour ce plan. C'est un intervalle « basic », donc dans le cadre de Q-42-10 : en regard du percentile, jamais à sa place.

### 2.4 Grandeurs rapportées

Par jeu, intervalle et niveau : couverture, avec la part de σ0 sous la borne basse et au-dessus de la borne haute ; IC de Clopper-Pearson à 95 % sur les valeurs non arrondies ; largeur médiane et largeur moyenne divisées par σ0 ; part de bornes basses ≤ 0 (I2) ; couverture par régime de δ̂ (bord ou intérieur), à titre descriptif.

**Biais (B1)**, moyenne ± 1,96·sd/√R : E[σ̂]/σ0 et E[corr·σ̂]/σ0 ; moyenne de σ̂/moyenne(σ\*) et médiane du rang de σ̂ dans σ\* ; part de δ̂ intérieur ; refus, échecs et variante V1/V3b des bootstraps.

### 2.5 Critère, fixé avant toute exécution

Reporté sans modification dans le script et au T0. Taux de non-couverture τ de chaque (jeu, intervalle, niveau), comparé au nominal ρ = 0,10 (90 %) ou 0,05 (95 %). Classes de #166, #206 et Fk, avec une bande **fermée** [ρ/2 ; 3ρ/2] (couverture dans [0,85 ; 0,95] à 90 %, dans [0,925 ; 0,975] à 95 %) :

| Classe | Condition |
|---|---|
| compatible | ρ ∈ IC(τ) |
| écart mineur | τ̂ dans la bande, sans être compatible |
| non tranché | τ̂ hors de la bande, et IC qui la recoupe |
| distorsion matérielle libérale (sous-couverture) | IC disjoint de la bande, au-dessus |
| distorsion matérielle conservatrice | IC disjoint de la bande, au-dessous |

- **Règle de frontière** : classes calculées sur les valeurs non arrondies ; une estimation sur un bord de la bande est dans la bande ; **aucune extension de R après lecture des résultats** (pas d'arrêt optionnel) : R est fixé par le pré-vol et écrit au JOURNAL avant le lancement ; un « non tranché » reste non tranché.
- **K-C1** (principal) : classe à 90 % de I1, I2 et I4 sur J1 et J2.
- **K-C2** (descriptif) : classes à 95 % ; queues séparées, par rapport à ρ/2 ; I3, A1 et B1.
- **K-C3** (intégrité ; un seul échec met INTEGRITE à ECHEC) : (1) md5 de `R/engine.R` et SHA consignés, identiques au début et à la fin ; (2) σ0 de J1 et J2 égal à `ajustement$sigma` de `premium` et `premium_interieur`, à `TOLERANCE` près ; (3) percentile du script, porté sur l'échelle de σ_USP par l'expression du moteur, `identical()` à `ic_bootstrap` des six références ; (4) sur le premier jeu de chaque tranche, bornes recalculées par une écriture indépendante (statistiques d'ordre et interpolation de type 7 en clair), égales à 1e-12 relatif près ; (5) sous l'option (b) seulement : σ\* et σ\*_r de la boucle allégée `identical()` à ceux d'`usp_bootstrap()` sur le premier jeu de chaque tranche.
- **K-C4** (frontière, descriptif) : pour chaque classe, dire si l'IC touche un bord de la bande.

### 2.6 Profils de lecture pour D2-Fn

`actuary` propose, le mainteneur tranche. Ordre d'évaluation : Ψ0, puis Ψ4, puis Ψ1 à Ψ3.

| Profil | Condition | Lecture proposée |
|---|---|---|
| Ψ0 | K-C3 en défaut, ou refus et échecs au-delà de 2 % de R sur un jeu sans explication | lecture suspendue ; mesure à reprendre |
| Ψ4 | I1 en distorsion de côtés opposés entre J1 et J2 | décision du mainteneur ; aucune correction calibrée sur un seul plan |
| Ψ1 | I1 compatible ou en écart mineur sur J1 et J2 | percentile conservé ; couverture écrite dans la fiche ; « basic » non restitué par défaut (le mainteneur peut le restituer en regard) |
| Ψ2 | I1 ni compatible ni en écart mineur sur au moins un jeu, et au moins un des intervalles I2 ou I4 compatible ou en écart mineur sur les deux | **décision du mainteneur** : restituer en regard le ou les intervalles « basic » qui satisfont la condition ; libellé du percentile requalifié (« niveau nominal 90 % ; couverture mesurée … ») |
| Ψ3 | I1 dans ce même cas, et aucun des intervalles I2 ou I4 compatible ou en écart mineur sur les deux jeux | **décision du mainteneur** : aucun « basic » restitué ; libellé du percentile requalifié ; issue proposée pour un autre intervalle |

D2-Fn est **toujours tenu** : la décision sur le « basic » revient au mainteneur (Q-42-10). σ_USP n'est jamais touché.

### 2.7 Budget, pré-vol, M42

**Coûts mesurés [V]**, un processus : `usp_bootstrap()` à B = 999 : 7,0 s sur J1 (V1), 13,7 s sur J2 (V3b, 4 490 tirages) ; `usp_ajuster()` : 0,04 à 0,35 s. **Part de δ̂ intérieur** parmi les jeux simulés [V, pilote] : 3,7 % sous J1, 20,3 % sous J2. Coût moyen estimé par jeu : J1 ≈ 7,6 s, J2 ≈ 8,8 s [H].

| Niveau | R par jeu | h CPU [H] | Horloge sur 4 cœurs, débit linéaire [H] | Demi-largeur de l'IC à τ = 0,10 |
|---|---|---|---|---|
| L0 | 2 000 | ≈ 9,1 | ≈ 2,3 h | ≈ 0,013 |
| **L1** | **1 000** | ≈ 4,6 | **≈ 1,15 h** | ≈ 0,019 |
| L2 (minimum) | 500 | ≈ 2,3 | ≈ 0,6 h | ≈ 0,027 |

- **Règle** : budget plafond de **2 h d'horloge sur 4 cœurs** ; on retient le premier niveau dont la durée planifiée (coûts mesurés au pré-vol à 1, 2, 3 et 4 processus) tient dans ce budget. L1 attendu ; pas de segment prévu. Si même L2 dépasse 2 h, le mainteneur choisit entre les segments de M42 (b), autorisés d'avance par Q-42-11, et l'option (b) de Q-D1-Fn-4.
- **M42 (a)** : tâche de fond suivie, `timeout` ≤ 7 200 000 ms, jamais de processus détaché ; sortie de `bilan_journal.sh` collée dans la PR avant le lancement (M40 (a)).
- **`--essai`** dès la création du script : R = 4 par jeu, B = 199, sorties non versionnables, `--ecrire` refusé (sémantique de M41 (c)) ; il passe avant le pré-vol.
- La **boucle allégée** (option (b)) reproduit `sigma_boot`, `sigma_boot_restreint` et `delta_boot` à l'identique sur J1 et J2 [V, `c_cout.R`], pour 1,3 s par jeu au lieu de 7 à 14 s. Elle n'est pas le chemin du moteur (un tirage dont le calcul des statistiques échoue y serait gardé) ; repli seulement, sous K-C3 (5).

### 2.8 Sorties

`docs/tableaux/<AAAAMMJJ>-issue305-couverture-ic-sigma.md`, le brut `.tsv` et le JOURNAL ; sorties nouvelles, jamais patchées, conformes aux critères de #242 ; **commit unique des sorties avant l'étape 4** (fiche Fn).

### 2.9 Pilote, déclaré [V, hors dépôt, annexe A]

Exécuté **avant** la fixation du critère ; il n'a servi qu'au budget et au choix des intervalles à mesurer : le critère reprend sans réglage les classes de #166, #206 et Fk, et les graines officielles sont disjointes. Conditions : R = 300 par jeu, B = 999, boucle allégée (identique à `usp_bootstrap()` pour σ\* [V]), 0 refus, 0 échec. Couverture et IC de Clopper-Pearson :

| | I1 90 % | I2 90 % | I4 90 % | I3 90 % | A1 90 % | I1 95 % | I2 95 % | I4 95 % |
|---|---|---|---|---|---|---|---|---|
| J1 | 0,703 [0,648 ; 0,754] | 0,810 [0,761 ; 0,853] | **0,923** [0,887 ; 0,951] | 0,707 | 0,830 | 0,770 | 0,853 | 0,953 |
| J2 | 0,650 [0,593 ; 0,704] | 0,787 [0,736 ; 0,832] | **0,920** [0,883 ; 0,948] | 0,670 | 0,783 | 0,720 | 0,840 | 0,947 |

- Pour I1, I2 et I3, presque tous les manques sont **au-dessus** : σ0 dépasse la borne haute (I1 : 29,7 % et 35,0 % ; sous la borne basse : 0). Pour I4, queues équilibrées : 3,3 et 4,3 % (J1), 4,0 et 4,0 % (J2).
- E[σ̂]/σ0 : 0,899 (J1), 0,870 (J2) ; E[corr·σ̂]/σ0 : 1,020 et 0,987.
- **Ce que le pilote laisse prévoir [H]** : Ψ2 par I4 seul ; un percentile « 90 % » couvrant environ 65 à 70 % sous les deux plans ; I2 non tranché ou en distorsion. Le pilote n'est pas la mesure et ne fonde aucune décision ; il signale que **D2-Fn portera probablement aussi sur le libellé « Intervalle bootstrap 90 % »** (bloc Calibration, rapport, ligne de diagnostic). Cette restitution changerait, sans que σ_USP change.

---

## 3. S-Fn-3 (#305) : graphique `plot_boot_sigma()`, deux méthodes

**Échelle, recommandation (B)** : l'histogramme passe sur l'échelle de **σ_USP**. La distribution tracée est celle dont les quantiles **sont** `res$ic_bootstrap` : graphique et nombre affiché concordent, sans recalcul.
- Champ nouveau `plots_data$sigma_usp_boot` : le vecteur `usp_b` en lognormal (`R/engine.R:12630`) et son analogue Merz-Wüthrich, calculé **une fois** dans `run_engine()` / `.run_engine_mw()` par l'expression qui forme `ic`, puis passé à `engine_plots_data()` et `mw_plots_data()`. On aura `identical(unname(quantile(pd$sigma_usp_boot, c(.025, .05, .5, .95, .975))), unname(res$ic_bootstrap))`.
- `plots_data$sigma_boot` est conservé tel quel (le retirer serait un changement de structure sans utilité).
- Alternative (A) : σ\* brut, avec σ̂ et les quantiles de σ\* ; obligerait à stocker un second IC sur l'échelle de σ, et σ_USP n'y aurait pas de place. Écartée.

**Marques**, champ `plots_data$boot_reperes` (liste ajoutée en fin) : `echelle = "sigma_USP"`, `niveau = 0.90` ; `sigma_usp`, image exacte de σ̂ (§ 0 : « σ̂ » et « σ_USP » sont la même marque sur cette échelle, ce que la fiche dit) ; `ic_bas`, `ic_haut` (`ic[2]`, `ic[4]`, `NA` si `ic` est `NULL`, B_eff ≤ 20) ; `moyenne` = mean(`sigma_usp_boot`) (l'écart avec `sigma_usp` rend le biais visible) ; `sigma_standard`, repère de contexte (la fiche précise qu'aucune inférence n'en découle) ; `basic_bas`, `basic_haut` (et `basic_log_*`) **si et seulement si** D2-Fn les retient.

**Coloration par régime de δ\*** (lognormal seulement) : champ `plots_data$regime_boot`, vecteur caractère aligné sur `sigma_usp_boot`, valeurs `"bord0"`, `"interieur"`, `"bord1"`, lu par `usp_regime(δ*, x)` et `usp_delta_bord()` (convention unique du bord, #331).
- **Alignement** : `sigma_boot` et `delta_boot` sont compactés séparément (`R/engine.R:4965-4966`) ; même longueur, 999, dans les six cas [V]. Alignés par construction quand σ\* = exp(γ\* + ln β\*) est fini [H, `:1237-1252`, `:5016-5031`]. Le moteur ne s'y fie pas en silence : `regime_boot` vaut `NULL` avec un motif si les longueurs diffèrent, à volumes constants (motif V1 existant) et sous `refit = FALSE`.
- **Affichage** : histogramme empilé à classes communes (plotly : `bingroup` ; base R : classes de `hist()`). Aucune quantité nouvelle calculée par `display_helpers.R` (revue `app-review`).
- Médianes par régime, constat de #305 retrouvé [V] : 0,05608 (bord 0, 419 tirages), 0,06127 (intérieur, 203), 0,05987 (bord 1, 377).

**Libellés** : « sigma_USP simulé » et « effectif » (base R, `R/display_helpers.R:913`, au lieu de « Frequency ») ; titre « Distribution bootstrap de sigma_USP ».

**Merz-Wüthrich** : mêmes champs, sans `regime_boot`.

---

## 4. S-Fn-4 : intervalle « basic », à décider à D2-Fn

- **Formule**, sur l'échelle de σ_USP, aux quantiles mêmes de `ic_bootstrap` (D-H éq. (5.6) ; équivariance affine) : `basic = 2·σ_USP − c(ic[5], ic[4], ic[2], ic[1])`.
  - Oracles : `premium` [0,08593 ; 0,14768] à 90 % et [0,08131 ; 0,15170] à 95 % ; `premium_interieur` [0,07311 ; 0,11098] à 90 % ; `reserve2` [0,04638 ; 0,05476] à 90 % [V, `g_oracles.R`].
  - Variante I4, si D2-Fn la retient : `a·σ̂²/q + b`, q quantiles de `sigma_boot`, sur l'échelle de σ. Oracles 90 % : `premium` [0,09272 ; 0,18605] ; `premium_interieur` [0,07638 ; 0,13652].
  - La largeur de I2 est celle du percentile : aucune ligne « largeur » nouvelle. Aucune troncature à 0 : une borne ≤ 0 serait restituée telle quelle et signalée par la fiche (aucun des six cas n'en a).
- **Nom et place** : `res$ic_bootstrap_basic`, vecteur nommé `c(bas_95, bas_90, haut_90, haut_95)`, plus `res$ic_bootstrap_basic_log` si I4 est retenu ; ajoutés **en fin** de l'objet `usp_engine` ; `NULL` quand `ic` l'est.
- **Onglet Calibration et rapport** : une ligne « Intervalle bootstrap « basic » 90 % : [ ; ] | 95 % : [ ; ] » **sous** la ligne du percentile, qui devient « Intervalle bootstrap de percentile ». Le libellé exact du niveau suit D2-Fn.
- **`detail` de la ligne « Largeur relative de l'IC bootstrap 90% »**, par renvoi seul et sans nombre (règle #76) : `"Intervalle bootstrap du parametre retenu : res$ic_bootstrap (percentile) ; intervalle basic en regard : res$ic_bootstrap_basic."`. Si D2-Fn le décide, ajouter au champ `reference` « Davison et Hinkley (1997), section 5.2 ».
- **Méthodes** : lognormal seulement dans Fn. La couverture Merz-Wüthrich n'est pas mesurée, alors que le rapport σ̂/moyenne(σ\*) y est de 1,127 [V]. Issue proposée au § 9.

## 5. S-Fn-5 : biais, texte de la fiche `fiche:ic-bootstrap`

À rédiger par `docwriter` à l'étape 5, sur ces éléments.
1. **Constat sur les références [V]** : moyenne(σ\*) inférieure à σ̂ de 11,2 % sur les quatre cas de J1 (mêmes réplications, σ̂/moyenne = 1,1264), de 13,9 % sur `premium_interieur` (1,1609), de 11,3 % sur `reserve2` (1,1271) ; rang de σ̂ dans σ\* : 0,694, 0,733, 0,713 ; correction de biais de BC_a, ẑ0 = Φ⁻¹(#{σ\* < σ̂}/B) (E-T éq. (14.14), p. 186 [V, R27.5]) : 0,51, 0,62, 0,56. BC_a n'est pas proposé dans Fn : l'accélération â n'est pas spécifiée pour ce modèle.
2. **Lecture** : l'écart moyenne(σ\*) − σ̂ est l'estimation bootstrap du biais de σ̂. Le percentile suppose T sans biais sur une échelle transformée (D-H § 5.3.2, p. 203 : « This does not usually happen » ; E-T § 13.8, p. 176) [V]. L'intervalle de percentile est donc décalé vers le bas autour d'un σ̂ lui-même bas ; la mesure du § 2 en donne la couverture, pour le plan seulement.
3. **√(9/7)** : l'observation σ̂/moyenne(σ\*) ≈ 1,134 **reste [H]**, affaiblie par `reserve2` (1,127 sans facteur dans sa formule) [V]. La fiche rapporte E[corr·σ̂]/σ0 mesuré par B1 (pilote : 1,020 et 0,987) comme un constat sous deux plans, **jamais** comme « le facteur corrige le biais ».
4. **« les variantes BCa seraient plus exactes »** : conforme à D-H p. 203 et 214 au sens d'une précision du second ordre **asymptotique** [V, R27.2] ; la phrase doit le dire, et dire qu'aucune page lue ne chiffre la couverture à n = 8 (R27.6).
5. **Andrews (2000)** : la nuance « percentile plus que nominal au bord » est rapportée au niveau du résumé [P], comme portant sur la moyenne contrainte de son exemple ; elle ne se transpose pas à σ, dont δ n'est qu'un paramètre de nuisance. J1 (δ0 = 1) en donne la mesure à T = 8 pour ce plan.

## 6. S-Fn-6 : sources

- **Vérifié [V]** (relevé du 27/10, R27.2 à R27.5) : Davison et Hinkley (1997) : § 5.2.1, éq. (5.6), p. 194, et éq. (5.10), p. 195 ; § 5.3.1, éq. (5.18), p. 203 ; § 5.3.2, p. 203 ; § 5.4.1, p. 211-214 ; § 4.2.4, éq. (4.16) et (4.17), p. 152-154. Efron et Tibshirani (1993) : § 13.3, éq. (13.3) et (13.4), p. 170 ; § 13.4, éq. (13.9), p. 174 ; tableau 13.3, p. 175 ; § 13.8, p. 176 ; éq. (14.14), p. 186. Code de `boot:::basic.ci` et `boot:::perc.ci` (boot 1.3.30).
- **Aucune formule de cette spécification ne dépend d'une page non lue.** Les ordres O(n^{−1/2}) sont asymptotiques et ne fondent rien à T = 8.
- **Andrews (2000)**, *Econometrica* 68(2), mars 2000, p. 399-405, DOI 10.1111/1468-0262.00114 : notice confirmée par recherche [P]. Résumé lu par la revue du 15/10 (`bloc-1.md:101`, `bloc-4.md:63`), non relu le 27/10 (page de l'Econometric Society inaccessible depuis la session) : **[P]**. La pagination 399-406 du `.tex` (l. 13083) est à vérifier par `docwriter` contre 399-405.
- **Cleveland (1979)** (fiche dispersion-niveau) : non relu [NV], sans dépendance.

## 7. S-Fn-7 : chemins prévisionnels de `plots_data` et de l'objet

### 7.1 #190, sans question

- Constante `LR_DELTA_NIVEAU_REPERES <- 0.90`, domaine ]0,5 ; 1[.
- `seuil_asymptotique = obj_min + qchisq(2·niveau − 1, 1)` : quantile au niveau `niveau` du mélange ½χ²(0) + ½χ²(1), puisque P(LR > c) = ½P(χ²₁ > c) [V, raisonnement] ; qchisq(0,8 ; 1) à 0,90 [V, `architect`].
- `q90_bootstrap = quantile(·, niveau, type = 7)` ; nom du champ conservé (stabilité du chemin), documenté comme « quantile au niveau `niveau` ».
- Test à 0,95 : seuil qchisq(0,9 ; 1) ≈ 2,706.

### 7.2 Chemins ajoutés par cas

| Cas | #190 | #306 | #305 (et D2-Fn) |
|---|---|---|---|
| `premium`, `reserve1`, `premium_ii6`, `premium_net` | `plots_data$lr_delta$niveau` (0,9 ; en fin de `lr_delta`) | `plots_data$spread_enveloppe` (en fin ; k\* attendu ≈ 9 selon (4.17) [H]) | `plots_data$sigma_usp_boot` (999), `$regime_boot` (999 ; 463 bord 0, 46 intérieur, 490 bord 1), `$boot_reperes` ; si D2-Fn : `res$ic_bootstrap_basic` (et `_log`) en fin d'objet, `detail` de la ligne de l'IC |
| `premium_interieur` | idem | idem | idem (419 bord 0, 203 intérieur, 377 bord 1) |
| `reserve2` | aucun | aucun | `plots_data$sigma_usp_boot` (999), `$boot_reperes` ; basic seulement si D2-Fn l'étend |

Inchangés, à vérifier à seuil 0 sur les chemins existants : σ_USP, verdicts, p-values, `ic_bootstrap`, `sigma_boot`, `spread_lisse`, `qq_enveloppe`. Seuls changent des chemins ajoutés, plus, si D2-Fn le décide, le `detail` et la `reference` de la ligne de l'IC (non numériques, tableau avant/après). `DECOMPTES` non touché (aucune ligne de test ajoutée). Taille : environ +16 Ko par cas lognormal [H].

## 8. Tests unitaires attendus

- **#190** : base R et plotly à `niveau` = 0,95, sans aucun « 90 % » littéral.
- **#306** : § 1.6.
- **#305** : `quantile(sigma_usp_boot)` `identical()` à `ic_bootstrap` (six cas) ; `boot_reperes$sigma_usp` `identical()` à `parametre_final$sigma_usp` ; `regime_boot` de la longueur de `sigma_usp_boot`, effectifs du § 7.2, `NULL` à volumes constants ; axe de `plot_boot_sigma()` « effectif » ; si D2-Fn : oracles du § 4 au millième, `detail` à la lettre.
- **Partout** : `.Random.seed` inchangé.

## 9. Issues proposées (sur accord seulement)

1. **« moteur: enveloppes du QQ-plot et du graphique dispersion-niveau conditionnelles au régime intérieur de δ̂ (z\* du flux complémentaire V3b) »** — `enhancement`, `needs-triage`. Constat du § 1.4 sur `premium_interieur`. Conserver les z\* du flux complémentaire ne crée aucun aléa nouveau, mais change l'objet `bootstrap`.
2. **« tests/docs: couverture à T = 8 de l'intervalle bootstrap de σ_USP en Merz-Wüthrich (plan de #206) »** — `enhancement`, `needs-triage`. Rapport σ̂/moyenne(σ\*) de 1,127 [V].
3. La règle de rang du QQ-plot est l'issue #385 (relevé R27.3) ; le § 1.4 en fait une contrainte de cohérence pour Fn.

---

## Questions au mainteneur pour D1-Fn

- **Q-D1-Fn-1 — #306, option.** *Recommandation* : (A), bandes ponctuelle et simultanée à 90 % tirées de `z_boot`, sans tirage ; constantes du QQ-plot reprises, `lowess` à f = 2/3 et iter = 3 explicites ; restitution du § 1.5 ; la fiche dit que seule la bande simultanée est un critère (taux de sortie de 9,2 % mesuré sur J1 et J2, contre 42 à 46 % pour la bande ponctuelle). *Alternatives* : (B) bande simultanée seule ; (C) retrait, non justifié par les mesures.
- **Q-D1-Fn-2 — règle de rang de la bande simultanée (suite de R27.3).** *Recommandation* : règle de l'éq. (4.17) de Davison et Hinkley et de `boot::envelope` (sortie si rang ≤ k ou ≥ B_eff + 1 − k, taux sur B_eff ; 9,2 % hors échantillon contre 10,3 % pour la règle du moteur). Le QQ-plot reste sur sa règle jusqu'à #385, et l'écart entre les deux graphiques est écrit dans les deux fiches. *Alternative* : reprendre la règle du QQ-plot (cohérence immédiate, mais [X] par rapport à la source).
- **Q-D1-Fn-3 — régimes de δ\* pour la bande.** *Recommandation* : bande inconditionnelle, comme le QQ-plot ; la sensibilité de `premium_interieur` (x = 300 hors de la bande conditionnelle intérieure, k\* = 2 sur 203 lignes) est écrite comme limite ; l'issue n° 1 du § 9 est créée sur accord.
- **Q-D1-Fn-4 — plan de mesure de #305.** *Recommandation* : plan du § 2.2 (J1, J2 ; cible σ0 ; graines déclarées), chemin `usp_bootstrap()` (option (a)), niveaux 90 et 95 % ; budget plafond de 2 h d'horloge sur 4 cœurs, échelle L0 à L2, L1 attendu ; critère K-C1 à K-C4 et profils Ψ0 à Ψ4 approuvés **tels quels avant toute exécution** ; aucune extension de R après lecture ; `--essai` dès la création. Option (b), boucle allégée sous K-C3 (5), en repli seulement.
- **Q-D1-Fn-5 — intervalle I4 (« basic » sur l'échelle logarithmique).** *Recommandation* : le mesurer comme candidat à côté de I2 (D-H éq. (5.10), p. 195 [V]) ; restitué seulement si D2-Fn le retient, **en regard du percentile, jamais à sa place**. Le pilote le donne près du nominal (0,92 à 90 % sur les deux jeux, quand I2 est vers 0,79 à 0,81).
- **Q-D1-Fn-6 — cible auxiliaire et facteur √((T+1)/(T−1)).** *Recommandation* : cible principale σ0 (équivalente à σ_USP aux vrais paramètres) ; A1 et E[corr·σ̂]/σ0 rapportés à titre descriptif ; aucune phrase sur la finalité du facteur ; consultation de `regulatory` non demandée dans Fn.
- **Q-D1-Fn-7 — échelle et marques de `plot_boot_sigma()`.** *Recommandation* : (B), échelle de σ_USP, champs `sigma_usp_boot` et `boot_reperes` (σ_USP, bornes à 90 %, moyenne, σ_std), `regime_boot` en lognormal, « effectif », pour les deux méthodes.
- **Q-D1-Fn-8 — forme de l'intervalle « basic » s'il est retenu.** *Recommandation* : `res$ic_bootstrap_basic` (et `_log`) en fin d'objet ; une ligne sous le percentile dans Calibration et dans le rapport ; `detail` par renvoi ; lognormal seulement ; issue n° 2 du § 9 pour Merz-Wüthrich.
- **Q-D1-Fn-9 — D2-Fn.** *Recommandation* : D2-Fn est toujours tenu ; il porte sur le « basic » (I2, I4) **et**, sous Ψ2 ou Ψ3, sur le libellé « Intervalle bootstrap 90 % » (application, rapport, ligne de diagnostic, `.tex`), que le pilote donne couvrant environ 65 à 70 %. σ_USP et verdicts hors de cause.
- **Q-D1-Fn-10 — pièces de cette consultation.** *Recommandation* : verser les scripts et leurs sorties dans `docs/tableaux/20261027-fn-pilote.md`, par un commit `docs:` préparatoire (précédent Q-D1-Fk-11), pour que le pilote et la mesure de la bande soient des pièces citables.

---

# Annexe A — `f_pilote.R` (pilote de couverture, hors dépôt, lancé avec R = 300)

```r
setwd("/home/user/outil_usp"); source("R/engine.R")
ln <- read.csv("tests/donnees/donnees_ln.csv"); li <- read.csv("tests/donnees/donnees_ln_interieur.csv")
leger <- function(fit, B, seed) engine_sous_graine(seed, {
  sig <- sig_r <- rep(NA_real_, B)
  for (b in seq_len(B)) { yb <- usp_simuler(fit)
    f <- try(usp_ajuster_rapide(fit$x, yb, fit$delta, fit$gamma), silent = TRUE)
    if (inherits(f, "try-error")) next
    sig[b] <- f$sigma
    fr <- try(usp_ajuster_contraint(fit$x, yb, fit$delta, fit$gamma), silent = TRUE)
    if (!inherits(fr, "try-error")) sig_r[b] <- fr$sigma }
  list(sig = sig[is.finite(sig)], sig_r = sig_r[is.finite(sig_r)]) })
R <- as.integer(commandArgs(TRUE)[1]); corr <- sqrt(9/7)
for (nm in c("J1","J2")) {
  d <- if (nm=="J1") ln else li; f0 <- usp_ajuster(d$xt, d$yt); s0 <- f0$sigma
  un <- function(r) {
    y <- engine_sous_graine(305000000L + r, usp_simuler(f0))
    f <- try(usp_ajuster(d$xt, y), silent=TRUE); if (inherits(f,"try-error")) return(c(ok=0))
    va <- usp_valider_ajustement(f, "premium"); if (!va$ok) return(c(ok=-1))
    bo <- leger(f, 999, 305100000L + r); s <- bo$sig; sh <- f$sigma
    q <- unname(quantile(s, c(.025,.05,.95,.975), type=7)); qr <- unname(quantile(bo$sig_r, c(.05,.95), type=7))
    c(ok=1, sh=sh, ms=mean(s), dint=as.numeric(!usp_regime(f$delta, d$xt)$delta_au_bord),
      p90lo = s0 < q[2], p90hi = s0 > q[3], p95lo = s0 < q[1], p95hi = s0 > q[4],
      b90lo = s0 < 2*sh-q[3], b90hi = s0 > 2*sh-q[2], b95lo = s0 < 2*sh-q[4], b95hi = s0 > 2*sh-q[1],
      r90lo = s0 < qr[1], r90hi = s0 > qr[2], c90lo = s0 < corr*q[2], c90hi = s0 > corr*q[3],
      l90lo = s0 < sh^2/q[3], l90hi = s0 > sh^2/q[2], l95lo = s0 < sh^2/q[4], l95hi = s0 > sh^2/q[1],
      bneg = (2*sh - q[4]) <= 0) }
  M <- do.call(rbind, parallel::mclapply(seq_len(R), un, mc.cores = 4))
  # ... agregation : couverture = 1 - mean(lo) - mean(hi) par intervalle
}
```

Les autres scripts (`a_refs.R`, `b_spread.R`, `c_cout.R`, `d_hors_ech.R`, `e_cond.R`, `g_oracles.R`, `h_rang.R`) sont hors dépôt (scratchpad de la session principale du 27/10) ; à verser selon Q-D1-Fn-10.
