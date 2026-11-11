# K4, étape 2 : avis amont d'actuary (spécification des textes)

> *Rédigé par l'agent actuary (IA), fiche `-approfondi`, le 11/11/2026, sur la branche `claude/textes-du-moteur` (tête `3b931b4`, `R/engine.R` identique à `main` `12872c3`). Aucun fichier du dépôt n'a été modifié.*

## 0. Sources, méthode, conventions

- **Lus** : la fiche « Branche K4 » de `docs/feuille-de-route.md` (l. 3387 et suivantes, dont la décision E-11/11 sur l'inventaire de #527) ; `docs/revues/20261111-avis-amont-k4/rejeu.md` et `inventaire_527.md` ; les issues #528, #506, #519, #533, #503, #493 (et son commentaire du 08/11), #527, #420 (et son commentaire Q-56-6) ; `CONTEXT.md` (entrées « Modèle réglementaire », « Diagnostic », « Verdict », « Test inopérant », « Ligne non applicable », « Contrôle de validité », « Erreur d'usage », « Défaut de calcul intercepté ») ; `docs/revues/20261109-fin-de-branche-k1/actuary-validation-reprise.md` (réserves R1 et R2, qui fondent #519) ; `R/engine.R` aux lignes citées ci-dessous ; `docs/latex/doc_tests_usp.tex` l. 3470-3495, 8395-8450, 10580-10595 (loi de z), fiches `mw:m2var` (l. 16038-16160), `fiche:p-famille` et `fiche:p-globale` (l. 17617-17830) ; `tests/puissance_mw_t8.R` (plans P1 et P2, générateur) ; `tests/unitaires/outils_unitaires.R` (règle #514).
- **Mesures** (`LC_ALL=C.UTF-8`, `Rscript`, moteur chargé par `charger_moteur()`, lecture seule des références `tests/reference/*.rds`) : scripts dans `docs/revues/20261111-avis-amont-k4/scripts-actuary/` (copies versées par la session) : `mesure.R` (préambule : extrait `texte_propre()`, `compter_phrases()` et leurs dépendances de `outils_unitaires.R` par `parse()`, comme `lg.R` de l'étape 1), `c506b.R` (#506), `c519.R` (#519, Cramér–von Mises, #244, longueurs des H0), `na17.R` (lignes non applicables de l'entrée minimale de #533). Les longueurs « phr / car » ci-dessous sont celles du **texte propre** (mentions retirées), mesuré sur le `detail` de la référence où l'ancien texte est remplacé par le nouveau.
- **Marques** : *vérifié* = lecture de la source citée ou commande exécutée ; *hypothèse* = jugement ou lecture non exécutée.
- Toutes les chaînes du moteur sont en ASCII sans accents. Aucun texte ci-dessous n'imprime de nombre issu du bootstrap (règle #76) ; les seuls nombres sont des constantes du moteur, des valeurs saisies ou des grandeurs calculées sur les données observées.

---

## 1. #528 — H0 des lignes de normalité

### 1.1 Lognormale : `H0n` (`R/engine.R:6568`)

**Défaut confirmé** (*vérifié*, `.tex` l. 8414-8440) : sous le modèle ajusté, π̂_t tenus pour connus, z = Pε avec ε_t i.i.d. N(0,1) et P projection de rang T − 1 ; z suit N(0, P), non N(0, I_T) ; les z_t sont corrélés, de variances 1 − π_t/Σπ_s. « les residus standardises suivent une loi normale » dit donc une chose fausse ou au mieux ambiguë (z est gaussien, mais dégénéré et non i.i.d.). L'hypothèse réellement éprouvée par les six lignes (p Monte-Carlo simulée sous le modèle ajusté ; à π̂_t constant, égalité exacte de loi avec un échantillon i.i.d. normal, `.tex` l. 10580-10590) est la **normalité des erreurs ε_t du modèle réglementaire**, c'est-à-dire la lognormalité H3, éprouvée **à travers** z.

**Texte fixé** (*vérifié* : 114 caractères ; le plus long H0 actuel des références en compte 173) :

```r
H0n <- "lognormalite (H3) : erreurs epsilon_t du modele reglementaire i.i.d. N(0,1), testee sur les residus standardises z"
```

`H1n <- "loi non normale"` : **inchangé** (il se lit sans ambiguïté contre ce H0 ; le changer doublerait le patch sans gain).

- Le mot « standardises » est gardé : l'assertion #39 (`tests/unitaires/test_defauts_connus.R:243-254`) refuse « normalises » ; son `identical(sw, ...)` (l. 252) est à remplacer par le nouveau texte.
- « modele reglementaire » : vocabulaire de `CONTEXT.md` (et non « modèle de l'annexe XVII », forme à éviter).
- Portée : six lignes × cinq références lognormales = 30 champs `H0` (*vérifié* à l'étape 1).

### 1.2 Merz-Wüthrich : les deux lignes M5 (`R/engine.R:12975`, `12992`)

**Même défaut, oui** (*vérifié* par lecture du code et du commentaire l. 12957-12969) : « les residus de Mack sont normaux » ne peut pas être l'hypothèse que la p-value éprouve. Les résidus de Mack portent deux contraintes exactes par colonne et ne forment pas un échantillon i.i.d. ; même à erreurs gaussiennes, Shapiro-Wilk et Lilliefors rejettent à 0,221 et 0,1875 au seuil 0,10 sous le plan `reserve2` (constat de simulation de `docs/tableaux/20261011-issue119-mw.md`, cité par le commentaire). L'hypothèse visée par le diagnostic est la normalité des **erreurs** du modèle de Mack (utile pour un quantile de la MSEP), lue sur des résidus qui n'en sont pas un échantillon. Le `loi` et le `detail` des deux lignes le disent déjà ; le H0 doit s'y aligner.

**Texte fixé**, identique pour les deux lignes (*vérifié* : 104 caractères) :

```r
H0 = "erreurs gaussiennes du modele de Mack, lues sur les residus de Mack (contraints par colonne, non i.i.d.)"
```

`H1 = "loi non normale"` : inchangé.

- **Conséquence pour le plan** : #528 patche aussi `reserve2` (deux champs `H0`, lignes 18 et 19). Le patch de #528 porte donc sur les six références (30 + 2 champs). C'est l'option que la fiche K4 réservait (« homologues Merz-Wüthrich si l'étape 2 le demande ») ; l'étape 2 la demande.
- Les deux lignes M5 sont des diagnostics sans verdict : aucun effet sur la lecture d'un verdict.

### 1.3 Autres H0 relus, laissés tels quels (*hypothèse* : jugement)

« c1 = 0 ET erreurs normales : ... » (Breusch-Pagan original, l. 6429) emploie déjà « erreurs », ce qui est cohérent avec le nouveau `H0n`. Pour Grubbs (l. 7014), Jarque-Bera, D'Agostino et Anscombe-Glynn, les H0 (« echantillon normal homogene », « asymetrie nulle ET aplatissement egal a 3 », « ... de la population ») ne disent rien de faux sur z ; ils sont hors du périmètre de #528.

---

## 2. #506 — phrase de puissance dans `DETAIL_P_FAMILLE` et `DETAIL_P_GLOBALE`

**Arbitrage** : la règle #514 est tenue (deux phrases, 400 caractères au plus) **par reformulation**, sans dérogation. La phrase de l'issue n'est pas insérée telle quelle : elle ajoutait une troisième phrase. Son fond est fondu dans les phrases existantes, dans les termes du tableau 2 et des fiches (« une p élevée n'atteste pas l'adéquation, puissance non mesurée », `.tex` l. 7176 ; « non mesurée à T = 8 », l. 17736 et 17812, *vérifié*).

Ce qu'on perd, et pourquoi c'est acceptable :
- famille : la proposition « aucun verdict de ligne n'etant modifie » (38 caractères) est retirée. Avec elle, le texte atteint 412 à 426 caractères sur les références (*vérifié*, variante FA de `c506.R`). « Diagnostic sans verdict » reste en tête, et la fiche `fiche:p-famille` dit que les verdicts des lignes ne sont pas modifiés ;
- globale : le dernier « de chaque famille » est retiré, et « A lire avec » devient « voir ».

**Textes complets fixés** (chaînes R exactes) :

```r
DETAIL_P_FAMILLE <- paste(
  "Diagnostic sans verdict : une p de famille faible signale qu'au moins une",
  "hypothese de la famille est mise en cause sous le modele ajuste (p plug-in non",
  "exacte), une p elevee n'atteste pas l'adequation (puissance non mesuree a T = 8).",
  "Tests de la famille (cles mc_nom) : [%s], voir aussi \"p globale (minP, lecture",
  "conjointe de la batterie)\".")

DETAIL_P_GLOBALE <- paste(
  "Diagnostic sans verdict : une p globale faible signale qu'au moins une hypothese",
  "de la batterie est mise en cause sous le modele ajuste, compte tenu des %d tests",
  "et de leur dependance (p plug-in non exacte, sur les p Monte-Carlo et non les p",
  "retenues). Une p elevee n'atteste pas l'adequation du modele (puissance non",
  "mesuree a T = 8), voir les lignes \"p de famille (minP, lecture conjointe)\".")
```

**Mesures** (*vérifié*, `c506b.R`) : gabarits de 341 et 393 caractères (« %s » et « %d » compris).

| Lignes | Avant (phr / car) | Après (phr / car) |
|---|---|---|
| famille, cinq cas lognormaux | 2 / 319 à 349 | 2 / 352 à 382 |
| famille, `reserve2` | 2 / 316 à 350 | 2 / 349 à 383 |
| globale, six cas | 2 / 335 | 2 / 393 |
| pire liste théorique, famille B à six membres (`Intercept, RESET, SpearVol, SpearTps, MK, CoxStuart`) | — | 2 / 390 |
| globale à k = 99 tests | — | 2 / 393 |

- La marge de la ligne globale est de 7 caractères. Elle ne dépend que de `%d`, qui a au plus deux chiffres. Tout texte joint plus tard à cette constante devra être remesuré.
- Les 29 lignes des six références changent. C'est un patch non numérique du champ `detail`, sans p-value ni verdict touché (ce sont des diagnostics).
- Fixtures à mettre à jour (étape 1) : `tests/unitaires/test_p_famille.R:174-181`, qui lit le texte à la lettre ; les autres lisent les constantes par leur nom.

---

## 3. #519 — trois `detail` et le repli Q-56-6

### 3.1 (a) Réserve R1 : elle vise le `detail` de l'ESD lognormal, **non** le `loi` de Grubbs

*Vérifié* (`actuary-validation-reprise.md`, R1, l. 60-66) : R1 porte sur « a niveau superieur a alpha a T = 8 en simulation », sans la condition du constat C7.a, établi sur des échantillons i.i.d. N(0,1). Le `loi` de Grubbs (l. 7026-7031) est **exact et reste inchangé**. À π̂_t constant, z est proportionnel à Mε (`.tex` l. 8429-8437), et G = max|z_t − z̄|/s_z est invariant par changement de position et d'échelle ; G(z) a donc la loi de G sur un échantillon i.i.d. normal de taille T (*vérifié* par l'algèbre). À π̂_t variable, le libellé dit déjà « ni exacte ni majorant garanti ».

**Texte fixé** (`R/engine.R:7055-7060`) :

```r
      detail = sprintf(paste(
        "Repere de valeurs aberrantes multiples (ESD de Rosner, alpha = %g, nombre en",
        "estimation), a niveau superieur a alpha a T = 8 en simulation sous i.i.d. normal",
        "(valeurs critiques adequates a partir de n = 25 selon l'auteur). Diagnostic par",
        "decision, sans verdict ni p-value retenue : la ligne \"Valeur aberrante isolee",
        "(Grubbs)\" fait foi."), alpha))
```

Mesure (*vérifié*) : 2 / 317 → 2 / 336 sur les cinq références lognormales. Dans « i.i.d. normal », le « . » de « d. » n'est pas compté comme fin de phrase par `compter_phrases()`. Patch : cinq champs `detail`. Fixture : l'assertion `detail_esd_attendu` (citée par R1).

### 3.2 (b) Rosner Merz-Wüthrich (`PHRASE_MW_ROSNER_DIAGNOSTIC`, l. 12395-12398)

Alpha est imprimé en **`%g`**, comme en lognormale et comme toutes les autres impressions d'alpha du moteur (`%g` aux l. 4729, 4755, 4822, 4824, 6019, 6406, 7057, *vérifié*). « (n >= 25) » est retiré : la parenthèse laissait croire que l'effectif était en cause, alors qu'un 8 × 8 donne n = 27. C'est le texte que j'avais proposé en fin de K1.

```r
PHRASE_MW_ROSNER_DIAGNOSTIC <- paste(
  "Repere du nombre de cellules aberrantes (ESD de Rosner a alpha = %g, nombre en",
  "estimation), sans p-value : son cadre (echantillon i.i.d. normal) ne couvre pas les",
  "residus de Mack, contraints par colonne. Diagnostic sans verdict : la ligne",
  "\"Cellule aberrante du triangle (residus studentises externes)\" fait foi.")
```

- Rendu d'alpha (*vérifié*) : 0.1 → « 0.1 », 0.05 → « 0.05 », 0.025 → « 0.025 », 0.0125 → « 0.0125 », 0.2999 → « 0.2999 ». 1/30 → « 0.0333333 » : six chiffres significatifs, la même convention que partout ailleurs, sans arrondi qui change la décimale lue.
- Mesure : 2 / 309 → 2 / 312 sur `reserve2`. La valeur rendue passe de « alpha = 0.10 » à « alpha = 0.1 » : patch d'un champ `detail`.
- Le commentaire des l. 12389-12394 doit lire « %g = alpha » au lieu de « %.2f = alpha ». Fixtures : `tests/unitaires/test_merz_wuthrich_suite.R:1835, 1841, 1850`.

### 3.3 (c) Phrase de #244 (`PHRASE_VERDICT_SENSIBLE_MC`, l. 4317-4319) : **oui, la toucher**

C'est ma réserve R2 (défaut réel, de forme). La correction se fait dans la constante, pas dans la jonction : une règle de capitalisation dans `.engine_joindre()` toucherait toutes les jonctions.

```r
PHRASE_VERDICT_SENSIBLE_MC <- paste(
  "Verdict sensible a l'alea de simulation",
  "(p a moins de 2 erreurs de Monte-Carlo du seuil).")
```

- Rendu sur les trois lignes des références (*vérifié*, `c519.R`) : « ... sur ratios bruts". Verdict sensible a l'alea de simulation (p a moins de 2 erreurs de Monte-Carlo du seuil). » (`premium_interieur`, Grubbs ; de même sur les deux lignes M1 de `reserve2`). Trois champs `detail` à patcher.
- Les lecteurs passent par le nom de la constante : `endsWith()` dans `R/display_helpers.R:501-527` et dans `.usp_poser_renvois()` (`R/engine.R:14708-14719`), la regex M11 dans `outils_unitaires.R`. Le contenu suit sans modification de code. Seul `tests/unitaires/test_verdict_sensible_mc.R:54` lit le texte à la lettre (*vérifié*, `grep`). L'application l'affiche dans son pied stylé, désormais avec majuscule et point : affichage changé sans code changé, à faire constater par un `app-review` léger (*hypothèse* : aucun autre lecteur ; `coder` refait le `grep`).
- Reste un cas : derrière une mention qui ne finit pas par un point (M6, M7, M10), la jonction « ; » précède une majuscule. Je l'accepte ; c'est moins gênant qu'une minuscule après un point.
- Aucun effet sur un verdict, une p-value ou le champ `inoperant`.

### 3.4 (d) Repli Q-56-6 : Cramér–von Mises sans « tres correlee »

L'adjectif est remplacé par une **relation exacte par définition**, qui ne demande aucune mesure : W² = n∫(F_n − F)² dF et A² = n∫(F_n − F)²/[F(1 − F)] dF. A² est W² pondéré par 1/[F(1 − F)], qui charge les queues. Ce sont les définitions d'Anderson & Darling (1954) et de Stephens (1974), déjà citées par les deux lignes. *Hypothèse à confirmer par `coder`* : `stat_ad()` et `stat_cvm()` implémentent bien ces deux définitions (je ne les ai pas relues).

`detail` (l. 6668-6670) :

```r
      detail = detail_h3(detail_diag("CvM", paste(
        "Distance de Cramer-von Mises a la loi normale, celle d'Anderson-Darling sans la",
        "ponderation des queues, pour information."), raison_cvm), p_cvm))
```

Mesure (*vérifié*) : 2 / 203 → 2 / 218 sur les cinq références lognormales. Patch : cinq champs `detail`.

Commentaire l. 6647, remplacement exact de « W2 etant tres correlee a A2 » :

```r
  # Kolmogorov sur (z - zbar)/s_z, quand stat_ks() la calcule sur z) et, W2
  # etant la distance d'Anderson-Darling sans la ponderation des queues, de la
  # ligne Anderson-Darling ; c'est leur type
```

Fixture : `tests/unitaires/test_regimes_p_exactes.R:575`. **Ne pas toucher** `tests/p_conditionnelle_regime_t8.R:870`. Son marqueur `MARQUEUR_DIAG_DECISION` (« Restituee en diagnostic par decision : ... ») n'existe plus dans le moteur (`grep -c` dans `R/engine.R` : 0, *vérifié*). Il est donc déjà périmé depuis #514, indépendamment de K4. C'est un constat hors périmètre, à signaler (§ 8).

---

## 4. #533 — `loi` des lignes de suites non applicables

**Texte fixé : `NA_character_`** pour les deux lignes de suites lorsqu'elles sont non applicables. Il n'y a donc pas de chaîne.

Motifs (*vérifié*) :
- C'est la forme déjà employée par le moteur pour une ligne non applicable qui n'a pas de loi de référence : Student sur la pente (l. 6178-6181), Fisher (l. 6202-6204), R², D'Agostino et Anscombe-Glynn sur l'entrée minimale (`na17.R`).
- Le motif obligatoire du `detail` dit déjà la cause exacte : « loi de R degeneree (variance nulle), test non applicable ».
- Une chaîne comme « loi de R non definie » serait inexacte : la loi de R existe, elle est **dégénérée** (R constant). C'est Z et le test qui ne sont pas définis.

Si le mainteneur préfère une chaîne à `NA`, le seul libellé que je valide est : `"loi de R degeneree sur ces effectifs : aucune loi de reference"`. Il ne vaut que pour les causes que rend `test_runs()`, pas pour la branche « cause NA » de Runsr, qu'on n'atteint que par un bootstrap fictif.

Mise en œuvre attendue :
- ligne z (l. 6843) : `loi = if (is.finite(ru$stat)) loi_r7("loi combinatoire EXACTE de R", "loi combinatoire de R") else NA_character_` ;
- ligne Runsr (l. 7212-7214) : `loi = if (!is.finite(boot$stats_obs$Runsr)) NA_character_ else if (is.finite(p_ex_r)) "loi combinatoire EXACTE de R (pi_t constant : r_t i.i.d., signes identiques a ceux de z_t)" else loi_ind` ;
- `detail_runsr` inchangé (K3b) ; références identiques (aucune ligne de suites non applicable dans les six cas, étape 1) ; test unitaire sur l'entrée de l'étape 1 (π_t constant, n1 = n2 = 1), qui doit rendre les deux `loi` à `NA`.

**Les 15 autres lignes non applicables de l'entrée minimale** (*vérifié*, `na17.R`) :
- 13 relèvent de R13 (volumes constants). Neuf gardent leur loi nominale (« t(3) sous le modele auxiliaire pondere ... ; non retenue », « loi de permutation de t (...) », « F(2,2) approx. », « permutation exacte (T <= 9, sans ex aequo) », « chi2(1) asymptotique », « chi2(1) asymptotique, SOUS NORMALITE », « chi2(2) asymptotique », « F(2,2) approx. (residus ...) », « F(1,3) approx. ») ; quatre sont déjà à `NA` (Student, Fisher, R², puis D'Agostino hors R13).
- Ces libellés nominaux ne sont pas faux en eux-mêmes : ils décrivent la loi qu'aurait le test. Le défaut de #533 est d'une autre nature : sur les suites, le libellé qualifie d'« EXACTE » une loi justement dégénérée, ou annonce « ratios heteroscedastiques -> Monte-Carlo » à π_t constant, sans p Monte-Carlo.
- Je limite donc la décision de #533 aux deux lignes de suites. Harmoniser `loi = NA` sur toute ligne non applicable (R13, Anscombe-Glynn à π̂_t variable) est un **élargissement de périmètre**, à signaler et non à décider : question au mainteneur (§ 8, Q-A). Coût estimé : quelques sites, aucune référence touchée (*hypothèse* : à T = 8, la seule ligne non applicable des références est Anscombe-Glynn, déjà à `NA`).

---

## 5. #503 — « Variance unitaire des residus de Mack »

### 5.1 `detail` : **inchangé**

*Vérifié* : il n'imprime plus « 2.5e-03 » (#514) ; le premier critère de l'issue est atteint.

Je ne demande pas d'y redire que l'écart à la référence a sensiblement la même loi sous les trois exposants. Ce serait un constat de simulation sous un plan, que seule la fiche peut accompagner de son plan et de ses chiffres. Le `detail` dit déjà l'essentiel pour le lecteur : la grandeur « ne teste PAS la structure de variance », et il renvoie aux deux tests qui la portent. Le « ici -0.0151 » imprimé est la moyenne des résidus observés : ce n'est pas un nombre issu du bootstrap, et la règle #76 est respectée.

**Aucun patch de référence pour #503.**

### 5.2 Commentaire l. 12707-12708, texte fixé

```r
      # Texte de #514 (specification finale d'actuary). N - k, l'identite
      # somme des r(i,j)^2 = N - k et la loi de l'ecart a la reference sous des
      # variances en C^0, C^1 et C^2 (plans P1 et P2,
      # tests/mesure_m2var_exposants_mw.R, tableau date sous docs/tableaux/) sont
      # dans la fiche mw:m2var ; le detail n'imprime aucun nombre de simulation.
```

### 5.3 Spécification de la mesure versionnée (pour `coder`)

- **Fichier** : `tests/mesure_m2var_exposants_mw.R`. Il est hors CI : nom sans préfixe `test_`, non appelé par `test_unitaires.R` ni par `test_reproductibilite.R`. Il utilise R base et stats, charge le moteur par `source("R/charger_moteur.R"); charger_moteur()` (ADR 0016), ne modifie ni le moteur ni `tests/reference/`, écrit sur la console et n'écrit un fichier que sur option explicite (`--sortie`), comme les autres scripts de mesure. En-tête au format de `tests/puissance_mw_t8.R` : objet, statut « constat de simulation sous un plan », modes.
- **Modèle générateur** : modèle de Mack à erreurs gaussiennes ajusté à `reserve2`. `AJ0 <- mw_ajuster()` du triangle de `tests/reference/reserve2.rds` (`$ajustement$tri`), avec contrôle `identical(AJ0$sigma2, ref$ajustement$sigma2)`. f_j et σ_j² de `reserve2` ne sont pas réestimés. Récursion colonne par colonne :
  `C(i,j+1) = f_j C(i,j) + e · σ_j · sqrt(C(i,j)^κ · Cb_j^(1−κ))`, e ~ N(0,1), Cb_j = moyenne des C(0..I−j−1, j) **simulés** de la colonne. C'est la copie déclarée de `gen_triangle_scen(aj, tirer, delta = 0, kappa = κ, gamma = 0)` de `tests/puissance_mw_t8.R:663-685` : même ordre de consommation des ε, même arrêt au premier cumul invalide. La variance vaut celle du modèle au cumul moyen de la colonne, ce que dit la fiche (*vérifié*, l. 16123-16126).
- **Exposants** : κ ∈ {0, 1, 2}.
- **Plans** (`tests/puissance_mw_t8.R:646-652`) : **P1**, première colonne = celle de `reserve2` ; **P2**, première colonne `mean(C0) + 3.4 · (C0 − mean(C0))` (KAPPA_P2 = 3,4). Pas de P3 : la fiche ne cite que P1 et P2.
- **Effectifs** : 2 000 triangles **tirés** par cellule (plan, κ), b = 1 … 2 000, soit 12 000 tirages au total.
- **Graines** : `GRAINE_M2VAR <- 20261111` ; graine du triangle b du plan p = `GRAINE_M2VAR + 10000 * (p - 1) + b`, P1 = 1, P2 = 2. La graine est **commune aux trois exposants** (nombres aléatoires communs) : la comparaison entre exposants est appariée, ce que l'en-tête et le tableau doivent dire, les trois colonnes n'étant pas indépendantes. Chaque tirage se fait sous `engine_sous_graine(g, ...)`, générateur `ENGINE_RNG_KIND`.
- **Admission** : copie déclarée de `admettre()` (`tests/puissance_mw_t8.R:633-646`) : triangle complet, `mw_valider_triangle()`, `mw_ajuster()`, `mw_msep()`, `mw_valider_ajustement()` sans erreur et `ok`. Les refus sont comptés par motif.
- **Grandeurs par triangle admis** : comme `mw_tests()` (l. 12433-12436 et 12702-12704) : `figes <- .mw_ensembles_figes(aj)`, `res <- mw_residus(aj, figes$degeneres)`, `r <- res$residu`, N = `length(r)`, k = `length(unique(res$j))`, v = `stats::var(r)`, ref = (N − k)/(N − 1), écart = v − ref, défaut d'identité `abs(ecart + N * mean(r)^2 / (N - 1))`.
- **Contrôles bloquants**, avant la boucle et après :
  - (sc) à κ = 1, le générateur rend, à graine égale, le même triangle que la copie déclarée de `gen_triangle_h0()` (`identical()`) ;
  - (r2) sur `reserve2` lui-même, ref et `mean(r)` recalculés donnent les deux nombres imprimés dans le `detail` de la référence : « 0.807692 », par `format(ref, digits = 6)`, et « -0.0151 », par `format(mean(r), digits = 3)` ;
  - (id) le défaut d'identité maximal sur tous les triangles admis est au plus 1e-12, en valeur absolue (*hypothèse* sur l'ordre de grandeur en double : à ajuster si la mesure le contredit, en le disant).
- **Sorties par cellule** (plan, κ) : tirés ; admis ; refus par motif ; max |écart| ; quantiles 50 %, 90 % et 99 % de |écart| ; moyenne de l'écart ; nombre et part des triangles admis à |écart| > 1e-3, avec IC de Clopper-Pearson à 95 % ; défaut d'identité maximal. Ajouter une ligne par plan : maximum de |écart(κ = 0) − écart(κ = 1)| et de |écart(κ = 2) − écart(κ = 1)| sur les triangles admis sous les trois exposants (comparaison appariée).
- **Volet R, facultatif mais recommandé** : il donne un support à la rubrique 4 de `mw:m2var`, qui cite aujourd'hui sans script « 999 triangles produits par `mw_simuler_triangle()` ..., graine 20260831 ..., entre 0,80740 et 0,80769 ». Il s'agit de rejouer B = 999 triangles par `.mw_tirer_triangle_valide()` sur le vivier de `reserve2` (`.mw_pool_residus()`), sous `engine_sous_graine(20260831, ...)`, et de restituer le min, le max et l'étendue de var(r). Décision de périmètre : § 8, Q-D.
- **Tableau daté** : `docs/tableaux/<aaaammjj>-issue503-m2var-exposants.md`, sur le modèle de `20261023-fm-mesures.md` : origine, commande exacte, `R/engine.R` et script avec leurs md5, version de R, plateforme, `LC_ALL`, durée, sortie complète, statut « constat de simulation sous un plan (modèle de Mack gaussien ajusté à `reserve2`, géométrie 8 × 8) ; aucun théorème ».
- **Critères d'acceptation** : deux exécutions de suite donnent une sortie identique, durée exclue ; les contrôles (sc), (r2) et (id) sont OK.
- **Les chiffres du tableau remplacent ceux de la fiche** (« 3,3, 3,7 et 5,6·10⁻⁴ » sous P1, « 10 à 11 % » sous P2). `docwriter` les reporte à l'étape 10, après visa d'`actuary` (étape 10, validation). Les chiffres du 08/11 viennent d'une graine non consignée : un écart n'est donc pas un défaut. Mais si le tableau **infirme** le constat qualitatif « sensiblement la même loi sous les trois exposants » (par exemple, des IC des parts disjoints entre exposants sous un même plan), le fond de la fiche change, et le tableau revient à `actuary` avant `docwriter`.

---

## 6. #493 — commentaires

Tous les textes sont des commentaires : `identical()` sur les six cas, aucune référence touchée, `regulatory` non requis (aucun texte restitué ne cite l'annexe XVII).

1. **l. 3702-3703** :
   ```r
   # Toutes les statistiques dont la loi sous H0 "le modele reglementaire (lecture
   # de l'outil) est correct" peut etre simulee. IMPORTANT : le bootstrap parametrique simule sous
   ```
   La suite du bloc est inchangée.
2. **En-tête d'`engine_sous_graine()`, l. 2147-2148** (*vérifié* : six appels, l. 2253 `sw_loi_nulle`, 3310 `usp_permutation_pente`, 5145 et 5235 `usp_bootstrap`, 5459 `usp_lr_delta`, 12032 `mw_bootstrap`) :
   ```r
   # Fonction unique par laquelle passe toute simulation du moteur
   # (usp_bootstrap(), y compris le flux complementaire de la p-value Monte-Carlo
   # conditionnelle au regime de delta, #240 ; usp_lr_delta() ;
   # usp_permutation_pente(), #169 ; mw_bootstrap() ; sw_loi_nulle()).
   ```
3. **Commentaire de `run_engine()`** (l. 13396-13448) : à **déplacer** juste au-dessus de `run_engine <- function(` (l. 14054). Le bloc de `.run_engine_mw()` (« # Orchestrateur de la methode du risque de reserve no 2 ... », l. 13449-13451) reste à sa place. Remplacer les entrées périmées et ajouter les arguments manquants (*vérifié* : signature l. 14054-14064, contrôles l. 13225-13310 et 8098-8106) :
   ```r
   #   xt, yt         methodes lognormales : vecteurs numeriques de meme longueur
   #                  (primes / pertes, ou provision d'ouverture / montant de
   #                  liquidation) ; a ne pas fournir en reserve2 (#489)
   #   methode        "premium", "reserve1" ou "reserve2", exactement (aucune
   #                  abreviation, #489)
   #   segment        segment de l'annexe choisie (annexe II : 1 a 12 ; annexe
   #                  XIV : 1 a 4) ; sert a determiner sigma_standard et le
   #                  bareme de credibilite
   #   annexe         "II" ou "XIV", exactement (#489)
   #   triangle       reserve2 seulement : triangle de paiements cumules (une
   #                  ligne par annee d'accident, une colonne par annee de
   #                  developpement) ; a ne pas fournir pour premium et reserve1
   ```
   Après `bareme`, ajouter :
   ```r
   #   theta_equiv    marge du test d'equivalence de la constante (TOST), en
   #                  fraction de la perte moyenne, 0 < theta < 1 ; ignoree si
   #                  delta_equiv est fourni ; methodes lognormales seulement
   #   delta_equiv    marge absolue Delta du TOST, fixee a priori, 0 < Delta <
   #                  moyenne(yt) ; NULL : marge theta_equiv ; methodes
   #                  lognormales seulement
   #   plus_recent_en_dernier TRUE si xt et yt sont dans l'ordre chronologique
   #                  (annee la plus recente en dernier), FALSE sinon (series
   #                  inversees avant tout calcul) ; logique scalaire non NA ;
   #                  methodes lognormales seulement
   ```
   Dans « Erreurs (issue #88) », ajouter après « reserve no 2 sans triangle » : « , argument sans effet pour la methode ou plus_recent_en_dernier invalide (#489) ». Les entrées `sigma_standard`, `nature_donnees`, `T`, `B`, `alpha`, `seed`, `bareme` et « Valeur » sont inchangées.
4. **Les trois points du commentaire du 08/11 : dans le périmètre de #493.** Le mainteneur les a versés à l'issue (Q-54-2) ; fermer #493 sans eux la laisserait incomplète. L'étape 8 du plan les omet : c'est un écart à signaler, que je ne tranche pas (§ 8, Q-B).
   - `R/engine.R:45-47`, remplacement de la parenthèse :
     ```r
     # consolidee du 14.11.2024 (fichier "TEXTE consolide_ 32015R0035 - FR -
     # 14.11.2024.xhtml" a la racine du depot, retenue par l'outil comme
     # reference de lecture, sans effet juridique propre : font foi les textes
     # publies au Journal officiel de l'Union europeenne ; ADR 0005). Les annexes II et XIV
     ```
   - `tests/unitaires/test_calibration.R:8-10`, même formule :
     ```r
     #  - annexes II et XIV : version consolidee du 14.11.2024 du reglement
     #    delegue (UE) 2015/35 (xhtml a la racine du depot, retenue par l'outil
     #    comme reference de lecture, sans effet juridique propre : font foi les
     #    textes publies au Journal officiel de l'Union europeenne), tableaux
     ```
     Ce fichier relève du préfixe `tests:`.
   - `R/engine.R:11896-11897` (*vérifié* : le corps appelle `.mw_simuler_triangle_etat()`, l. 11919) :
     ```r
     # A1 de la specification, par. 3, point 2) : tire par
     # .mw_simuler_triangle_etat(), le calcul de mw_simuler_triangle() (memes
     # tirages, meme triangle, #278), jusqu'a un triangle sans NA dans sa partie
     ```
   Le vocabulaire « modèle réglementaire » est tenu partout ; plus aucune occurrence de « modele de l'annexe XVII » dans le code après le point 1 (*vérifié* à l'étape 1 : c'était la seule).

---

## 7. #527 — fond des messages reformulés

### 7.1 Règle de rédaction (R-527)

1. **Ce qui est du jargon R, à retirer** : types et formes R d'une valeur (`NA_real_`, `NULL` cité comme valeur, `structure(...)` hors appel direct), « scalaire », « sans attribut » dans le corps du message, « erreur R », noms de fonctions du moteur hors diagnostic de défaut, chemins de champs (`validation$...`) non expliqués, noms d'arguments R employés comme sujet de la phrase (`xt`, `yt`, `delta_equiv`, `theta_equiv`, `sigma_standard`) lorsque l'utilisateur de l'application ne les voit pas.
2. **Ce qui n'est pas du jargon, à garder** :
   - les notations du règlement et de la documentation (x_t, y_t, δ, γ, σ, MSEP, R, C(i,j), f_j, sigma2_j, I + 1, D(4), B(6)) ;
   - les termes mathématiques expliqués (« condition du premier ordre (KKT) ») ;
   - la notation scientifique (« 1e+50 », celle des tableurs) ;
   - les coordonnées (i, j) de la grille, dont l'application affiche les en-têtes « i \ j », 0, 1, ... (`app.R:983-987`, *vérifié*) ;
   - les noms de colonnes d'un **fichier** importé (`t`, `xt`, `yt`, `i`), qui sont ce que l'utilisateur a écrit ;
   - le contenu littéral d'une cellule du fichier (« NA », « Inf »).
3. **Un nom de constante du moteur n'est admis qu'entre parenthèses, après sa valeur et son sens en mots** (« au moins 99 (B_MIN_USAGE) », « a la tolerance relative TOL_DELTA_BORD = 1e-06 pres », « bornes de l'outil (BORNES_GAMMA, ...) »). C'est la trace pour le relecteur du dossier ; la constante TOL_DELTA_BORD est d'ailleurs un terme de `CONTEXT.md`.
4. **Erreur d'usage** : le message commence toujours par `<argument> = <valeur citee> :`, qu'on garde parce que les tests le lisent et que l'erreur nomme l'argument (`CONTEXT.md`, « Erreur d'usage »). Suit le sens de l'argument en mots et ce qui est attendu. Les conditions propres à l'appel direct (nombre seul, sans attribut, NULL) passent en fin de phrase, introduites par « en appel direct ».
5. **Valeur manquante citée** : une valeur atomique de longueur 1, `NA` hors `NaN`, sans attribut, est citée **« NA (valeur manquante) »**. Point de production : un enrobage mince de `.engine_saisie()`, par exemple `.engine_saisie_lisible(v)`, employé **par les seuls messages de l'inventaire** (US-01, -02, -03, -05, LN-08, LN-10, PR-01).
   **`.engine_saisie()` n'est pas modifiée.** Son contrat, posé et testé par #133 (`test_calibration.R:204-210`, « NA_real_ cites tels quels »), est une écriture qui se relit exactement. Elle sert aussi aux gardes internes et aux appels directs ; la changer renverserait une décision testée.
6. **Les valeurs à 17 chiffres restent** (LN-06, MW-08, US-01 à US-05). Ce n'est pas du jargon mais une exactitude voulue (#133, #180, #198) : à 15 chiffres, une valeur juste hors d'une borne serait citée comme la borne, ou une Delta refusée comme égale à la moyenne. Les réintroduire serait rouvrir un défaut corrigé.
7. **Textes décidés par le mainteneur et conformes à la règle : inchangés.** Il s'agit de AJ-01 à AJ-03 (spécification Q-D1-Fc-2), MW-09, MW-10 (#192, Q-E2r-192), AV-12 à AV-14 (Q-E2r-60-2, #33) ; leur longueur n'est pas soumise à #514.
8. **Nature inchangée** : un `stop()` reste un `stop()`, un refus reste `ok = FALSE`. Aucun message ajouté ou retiré, sauf LN-07, où deux textes identiques deviennent distincts (même nombre de motifs).

### 7.2 Tableau id → texte cible

« = » : inchangé (motif). Les textes cibles sont donnés en rendu sur l'entrée de l'inventaire. Les gabarits suivent le code actuel, où seuls les mots changent.

**G5 — Usage (stop()), commit 9a**

| Id | Texte cible (mot pour mot, rendu) |
|---|---|
| US-01 | `B = NA (valeur manquante) : le nombre de replications bootstrap doit etre un nombre entier au moins egal a 99 (B_MIN_USAGE) ; en appel direct, un nombre seul, sans attribut.` — gabarit : `sprintf(paste("B = %s : le nombre de replications bootstrap doit etre un nombre entier", "au moins egal a %d (B_MIN_USAGE) ; en appel direct, un nombre seul, sans attribut."), saisie(B), B_MIN_USAGE)` |
| US-02 | `seed = NA (valeur manquante) : la graine doit etre un nombre entier compris entre -2147483647 et 2147483647 ; elle est obligatoire, faute de quoi le calcul ne serait pas reproductible (en appel direct : un nombre seul, sans attribut, NULL refuse).` — bornes par `%d` de `.Machine$integer.max` (*vérifié* : condition `abs(seed) <= .Machine$integer.max`) |
| US-03 | `alpha = NA (valeur manquante) : le seuil des verdicts doit etre un nombre strictement compris entre 0 et 0.3 (SEUIL_ECHEC_SENS_REJETER) ; au-dela, la zone ALERTE des tests en sens rejeter disparait et le verdict ne suit plus la regle documentee (en appel direct : un nombre seul, sans attribut).` — « 0.3 » par `format(SEUIL_ECHEC_SENS_REJETER, decimal.mark = ".")`. Même texte à reporter dans `engine_regle_verdicts()` (l. 13153-13157, message jumeau, hors bandeau) pour que les deux restent identiques |
| US-04 | `B = 99 et alpha = 0.01 : B + 1 > 4/alpha est requis, soit B >= 400 a ce seuil (en plus du minimum B >= 99, B_MIN_USAGE). Le plancher bilateral de la p-value Monte-Carlo, 2/(B+1) = 0.02, n'est pas inferieur a alpha/2 = 0.005 : l'ECHEC des tests dont la seule p-value est Monte-Carlo serait inatteignable (regle des verdicts).` — changements : « (en plus de B >= B_MIN_USAGE = %.0f) » → « (en plus du minimum B >= %.0f, B_MIN_USAGE) » ; « (regle des verdicts d'engine_registre_tests()) » → « (regle des verdicts) ». Même texte avant le clic (`avert_b_alpha`), par construction |
| US-05 | `sigma_standard = NA (valeur manquante) : l'ecart-type standard saisi doit etre un nombre strictement positif ; pour retenir le parametre standard du segment, ne pas le saisir (en appel direct : un nombre seul, sans attribut, ou NULL).` |

**G1, G1b, G2 — Lognormale, commit 9b**

| Id | Texte cible |
|---|---|
| LN-01 | = (aucun jargon R ; texte de M13) |
| LN-02 | = |
| LN-03 | `Valeurs infinies : x_t et y_t doivent etre des nombres finis.` |
| LN-04 | `Toutes les valeurs de x_t doivent etre strictement positives.` |
| LN-05 | `Toutes les valeurs de y_t doivent etre strictement positives (loi lognormale).` |
| LN-06 | `Valeur de x_t hors du domaine numerique [1e-50 ; 1e+50] : x_t = 1e-108 (< 1e-50, borne inferieure) ; 8 valeurs hors du domaine. sigma_USP et les tests sont invariants par un changement d'unite commun a x_t et y_t (et a la marge Delta du test d'equivalence si elle est fournie) : exprimer les montants dans une unite qui les ramene dans le domaine.` — le nom de série cité devient `x_t` / `y_t` (correspondance `c(xt = "x_t", yt = "y_t")[nm]`) ; valeur par `.engine_saisie()` inchangée (17 chiffres si nécessaire, règle R-527.6) |
| LN-07 | **Deux textes distincts** (le doublon disparaît sans logique nouvelle). `engine_valider_donnees()` l. 8174 : `sprintf("Annexe XVII, B/C(2)(b) : au moins %d annees consecutives sont exigees, la serie en compte %d.", T_min, length(xt))` → « ... sont exigees, la serie en compte 4. » ; `engine_valider_profondeur()` l. 8300 (branche T_min >= 5) : `sprintf("Profondeur T = %s inferieure a %d : l'annexe XVII, B/C(2)(b), exige au moins %d annees consecutives.", format(T, decimal.mark = "."), T_min, T_min)` → « Profondeur T = 4 inferieure a 5 : l'annexe XVII, B/C(2)(b), exige au moins 5 annees consecutives. » |
| LN-08 | `Marge Delta du test d'equivalence (delta_equiv) = NA (valeur manquante) : un nombre fini strictement positif est attendu.` |
| LN-09 | `Marge Delta du test d'equivalence (delta_equiv) = 500, superieure ou egale a la perte moyenne (96.25) : l'equivalence ne se lirait plus comme une proportionnalite ; 0 < Delta < moyenne des y_t est attendu.` |
| LN-10 | `Marge theta du test d'equivalence (theta_equiv) = NA (valeur manquante) : un nombre fini, 0 < theta < 1 (fraction de la perte moyenne), est attendu.` |
| PR-01 | `Profondeur T = NA (valeur manquante) : un nombre entier d'annees est attendu (annexe XVII, B/C(2)(b)) ; la serie n'est pas tronquee.` — seul l'enrobage R-527.5 change |
| PR-02 | = |
| PR-03 | = |
| AJ-01, AJ-02, AJ-03 | = (règles R-527.2, .3 et .7 : δ, γ, y_t/x_t sont les notations de B(6) ; BORNES_GAMMA est entre parenthèses avec son sens ; « KKT » est expliqué ; texte de spécification décidé) |
| AJ-04 | `Defaut de calcul intercepte dans la fonction usp_controle_donnees() du moteur : aucun resultat n'est produit ; diagnostic technique dans le champ validation$erreur_r du resultat.` — sans origine : `Defaut de calcul intercepte : aucun resultat n'est produit ; diagnostic technique dans le champ validation$erreur_r du resultat.` Le nom de fonction reste : il sert à rapporter le défaut (`CONTEXT.md`). **`CONTEXT.md` cite l'ancien motif à la lettre** : mise à jour par `architect` (§ 8, Q-E) |

**G3 — Merz-Wüthrich, commit 9c**

| Id | Texte cible |
|---|---|
| MW-01, MW-02, MW-03 | = |
| MW-04 | `sprintf("Triangle non carre (%d annees d'accident, %d annees de developpement) : cas non couvert par les formules des paragraphes 4 et 5 de la section D de l'annexe XVII.", nrow(tri), ncol(tri))` → « Triangle non carre (8 annees d'accident, 6 annees de developpement) : ... ». Le renvoi à une « note d'implementation » inaccessible est retiré ; le fond, inchangé, est fermé à `regulatory` (§ 8, remarque R-1) |
| MW-05 | `Cellule observee manquante : annee d'accident i = 0, annee de developpement j = 2.` |
| MW-06 | `Valeur non finie en annee d'accident i = 0, annee de developpement j = 2 : Inf.` |
| MW-07 | `Cumul non strictement positif : annee d'accident i = 0, annee de developpement j = 2.` |
| MW-08 | `Cumul hors du domaine numerique [1e-50 ; 1e+50] en annee d'accident i = 0, annee de developpement j = 2 : 1e+120 (> 1e+50, borne superieure). sigma_USP et les tests sont invariants par un changement d'unite commun a toutes les cellules du triangle : exprimer les cumuls dans une unite qui les ramene dans le domaine.` (suffixe « ; %d cellules observees hors du domaine » inchangé) |
| MW-09, MW-10 | = (notation de D(4), D(5) ; textes décidés) |

**G4 — Lecteurs, commit 9d**

| Id | Texte cible |
|---|---|
| LE-01 à LE-05 | = |
| LE-06 | `Colonne(s) vide(s) portant un en-tete dans le triangle (colonne(s) 9, d'en-tete(s) 7) : annee de developpement sans valeur ; la renseigner ou retirer la colonne.` |
| LE-07 | `Certaines valeurs des colonnes xt ou yt ne sont pas numeriques (colonne xt : ligne(s) de donnees 3).` (plusieurs : « colonne xt : ... ; colonne yt : ... ») ; phrase « Une cellule "NA" ... » = |
| LE-08 à LE-12 | = |
| LE-13 | `Cellule(s) non numerique(s) en (i = 1, j = 3) (i : annee d'accident, j : annee de developpement).` (liste : « (i = 1, j = 3), (i = 2, j = 0) et 2 autre(s) (i : ..., j : ...). ») ; phrase « Une cellule "NA" ... » = |

**Avertissements, commit 9e**

| Id | Texte cible |
|---|---|
| AV-01 | `Ratio y_t/x_t hors de la plage plausible [0.1 ; 5[ : verifier les unites.` |
| AV-02 | = |
| AV-03 | `Couples (x_t, y_t) dupliques detectes.` |
| AV-04, AV-05 | = (TOL_DELTA_BORD : règle R-527.3, terme de `CONTEXT.md`) |
| AV-06, AV-07 | = (aucun jargon) |
| AV-08 | `Cellule(s) renseignee(s) sous la diagonale (i + j > I) en (i = 7, j = 7) (i : annee d'accident, j : annee de developpement) : hors de la partie observee ...` (suite inchangée ; même gabarit de coordonnées que LE-13) |
| AV-09, AV-10, AV-11 | = |
| AV-12, AV-13, AV-14 | = (règle R-527.7) |

**Conséquence importante pour le plan** : les quatre avertissements présents dans les références (AV-06, AV-07, AV-10, AV-11) **ne changent pas**. Le commit 9e ne touche que AV-01, AV-03 et AV-08, absents des six références, et **ne demande aucun patch de référence** (*hypothèse* d'après l'inventaire de l'étape 1 ; `comparer_references.R` le confirmera). La décision (2) du mainteneur (avertissements dans #527) est appliquée ; elle ne produit simplement pas de patch.

### 7.3 Points signalés par l'étape 1

- **Doublon « au moins 5 annees consecutives (T = 4) »** : traité par LN-07, avec deux textes distincts, chacun vrai sur son objet (le paramètre T, la série). Pas de `unique()`, aucune logique nouvelle. « (T = 4) » disparaît du motif des données, où « T » désignait à tort la longueur de la série.
- **« NA_real_ » de `.engine_saisie()`** : corrigé au point de production **des messages**, par l'enrobage R-527.5, et non dans `.engine_saisie()` (contrat #133, testé).
- **Valeur à 17 chiffres** : gardée (R-527.6).
- **US-03 et le maximum 0,20 de l'application** : pas d'incohérence de fond dans le moteur. Le domaine 0 < α < 0,30 est une nécessité de la règle des verdicts (zone ALERTE en sens « rejeter ») ; `max = 0.20` est un réglage de `numericInput` côté client (`app.R:613-614`, *vérifié*). Le serveur ne l'applique pas à une saisie tapée (*hypothèse* de l'étape 1, comportement usuel de Shiny, non testé). C'est **hors périmètre** (`app.R`), **à remonter** : aligner l'aide ou les bornes du champ, ou consigner le choix (issue `app:`, sur accord du mainteneur).
- **Message d'usage affiché deux fois dans l'application** (bandeau et notification, `app.R:837-838`) : hors périmètre (`app.R`), à remonter (issue `app:`, sur accord du mainteneur).

---

## 8. Questions qui relèvent du mainteneur, et textes qui touchent la lecture d'un verdict

**Aucun σ_USP, aucune p-value et aucun verdict ne change** (*vérifié* par construction : seuls des champs texte, `H0`, `detail`, `loi`, `validation$erreurs` et `validation$avertissements`, et des commentaires sont touchés ; la recomparaison `comparer_references.R` reste à faire à chaque commit).

**Textes qui touchent la lecture d'un verdict** :
- Aucun texte ne change la lecture d'un verdict.
- Le plus proche : `H0n` (§ 1.1), qui s'affiche sur les lignes à verdict Shapiro-Wilk, Shapiro-Francia, Anderson-Darling et Lilliefors. Il dit ce que ces verdicts ont toujours éprouvé (la normalité des erreurs du modèle réglementaire, à travers z), là où l'ancien texte le disait mal. Je le soumets au mainteneur pour information.
- Les autres textes portent sur des diagnostics sans verdict (#506, ESD, Rosner, Cramér–von Mises, M5), sur des lignes non applicables (#533) ou sur des messages de refus et d'usage (#527).
- La phrase de #244 (§ 3.3) change de typographie, pas de sens.

**Questions** :
- **Q-A (élargissement de périmètre, #533)** : harmoniser `loi = NA` sur toutes les lignes non applicables (neuf lignes R13 et Anscombe-Glynn à π̂_t variable), au-delà des deux lignes de suites ? Mon avis : **non dans K4**. Ces libellés décrivent une loi nominale sans affirmer de fausseté de régime ; je recommande une issue distincte (`enhancement`, `needs-triage`), sans effet sur les références (*hypothèse*).
- **Q-B (périmètre de l'étape 8, #493)** : les trois points du commentaire du 08/11 (`R/engine.R:47`, `tests/unitaires/test_calibration.R:10`, `R/engine.R:11897`) font partie de #493 par Q-54-2 ; l'étape 8 du plan les omet. Mon avis : les inclure (commentaires seuls). Le fichier de tests appelle un commit `tests:` distinct ou une mention dans le commit de #493 ; c'est à la session et au mainteneur de le décider.
- **Q-C (#533, forme)** : `NA_character_` (mon choix) ou la chaîne de repli « loi de R degeneree sur ces effectifs : aucune loi de reference » ? L'issue suggérait une chaîne ; le moteur emploie `NA` ailleurs pour ce cas.
- **Q-D (#503, volet R)** : verser aussi le support de la rubrique 4 de `mw:m2var` (bootstrap de résidus, 999 triangles, graine 20260831) ? Mon avis : oui, le coût est faible ; sans lui, ce chiffre de la fiche reste sans script.
- **Q-E (#527, AJ-04)** : le motif du défaut de calcul intercepté est cité à la lettre par `CONTEXT.md` (« Défaut de calcul intercepté ») : `architect` doit le mettre à jour. Je n'ai pas vérifié si le `.tex` le cite aussi : c'est à `coder` de le relever dans la surface documentaire.
- **Remarques hors périmètre, issues à proposer sur accord du mainteneur** :
  - R-1 : MW-04 dit les formules de D(4)-D(5) « non couvertes » pour un triangle non carré, alors que D(2)(e) admet plus d'années d'accident que d'années de développement. C'est une question de lecture pour `regulatory` ; K4 ne touche pas ce fond.
  - R-2 : le marqueur `MARQUEUR_DIAG_DECISION` de `tests/p_conditionnelle_regime_t8.R` (script hors CI) n'existe plus dans le moteur depuis #514 (*vérifié* : 0 occurrence).
  - R-3 : US-03 et le maximum 0,20 du champ alpha (§ 7.3).
  - R-4 : message d'usage affiché deux fois (§ 7.3).

---

## Retour

- **Statut** : `complet` pour ce qui m'était demandé : textes fixés pour les sept points, avec mesures #514 sur les références pour chaque `detail`. Deux réserves de preuve, signalées :
  - la définition de `stat_ad()` et `stat_cvm()` (§ 3.4), non relue, qui fonde le nouveau texte de Cramér–von Mises ;
  - l'absence de toute chaîne de `validation` modifiée dans les références (§ 7.2), qui reste à confirmer par `comparer_references.R`.
- **Résultat** :
  - #528 : `H0n` et H0 des deux lignes M5 réécrits, ce qui étend le patch à `reserve2` ;
  - #506 : deux constantes reformulées, #514 tenu sans dérogation (au plus 383 et 393 caractères, deux phrases) ;
  - #519 : ESD lognormal « en simulation sous i.i.d. normal », `loi` de Grubbs inchangé (exact), Rosner M-W en `%g` sans « (n >= 25) », phrase de #244 avec majuscule et point, Cramér–von Mises décrit par une relation de définition ;
  - #533 : `loi = NA_character_` sur les deux lignes de suites non applicables ;
  - #503 : `detail` inchangé, commentaire réécrit, mesure P1/P2 × κ ∈ {0, 1, 2} spécifiée ;
  - #493 : commentaires fixés, trois points du 08/11 inclus ;
  - #527 : règle R-527 et tableau des 45 + 14 messages. 26 messages changent (US-01 à US-05, LN-03 à LN-10, PR-01, AJ-04, MW-04 à MW-08, LE-06, LE-07, LE-13, AV-01, AV-03, AV-08) ; les quatre avertissements des références ne changent pas.
- **Preuves** :
  - *vérifiées* : longueurs et nombres de phrases (`c506b.R`, `c519.R`) ; lignes non applicables (`na17.R`) ; sites d'`engine_sous_graine()` (`grep`) ; corps de `.mw_tirer_triangle_valide()` ; signature de `run_engine()` ; formats d'alpha ailleurs (`%g`) ; lecteurs de `PHRASE_VERDICT_SENSIBLE_MC` ; loi de z (`.tex` l. 8414-8440) ; R1 et R2 (`actuary-validation-reprise.md`) ; générateur et plans de `tests/puissance_mw_t8.R` ; libellés de l'application ;
  - *hypothèses* : la définition des statistiques W² et A² du moteur ; l'absence d'autre lecteur littéral des textes changés ; le non-respect par Shiny du maximum côté serveur ; le seuil 1e-12 du contrôle (id) ; l'absence d'effet sur les références de l'harmonisation Q-A ;
  - *non vérifiés* : citations éventuelles dans le `.tex` des messages de #527 (surface documentaire de `coder`).
- **Informations manquantes** : la graine et le script de la mesure du 08/11 de #503 (non consignés), d'où une nouvelle graine.
- **Décisions non résolues** : Q-A à Q-E (mainteneur ; Q-E aussi `architect`).
- **Critères déclenchés** (`routage.md`, § 4) :
  - écarts au plan adopté : #528 étendu à `reserve2`, #533 limité aux suites avec élargissement signalé, commit 9e sans patch, étape 8 étendue aux trois points de #493 ;
  - contrat partagé : textes de l'objet `usp_engine` ;
  - aucun désaccord avec un ADR ;
  - aucun changement de résultat numérique ni de verdict.
- **Prochaine action recommandée** : la session porte Q-A à Q-E au mainteneur, puis lance l'étape 3 (#528) avec les textes du § 1, en `coder-approfondi` d'office.
