# K4, étape 10 : validation unique du diff du `.tex` par actuary

> *Rédigé par l'agent actuary (IA), le 11/11/2026, sur la branche `claude/textes-du-moteur` (tête `a8a840d`). Aucun fichier du dépôt n'a été modifié.*

Objet : `git diff origin/main...HEAD -- docs/latex/doc_tests_usp.tex` (109 insertions, 56 suppressions ; six commits `docs:` fe5c4cc #528, 57fd4a1 #506, 802927f #519 et Q-56-6, c46c404 #533, 2d18393 #503, a8a840d #527 et version 3.4). Règle 9 de CLAUDE.md, ADR 0010.

## 0. Pièces lues et contrôles exécutés

- Lu : le diff complet ; mes textes fixés (`docs/revues/20261111-avis-amont-k4/actuary-avis-amont.md`, `actuary-addendum-QA.md`, `actuary-validation-503.md`) ; `docs/latex/CONVENTIONS.md` (rubriques, budgets, plafond, grille de condensation) ; dans le `.tex` : sec:base-residus (l. 8385-8470), encadré « Point commun » de sec:h3 (l. 10590-10617), les six fiches de normalité de H3 (l. 10619-10990), mw:m2var (l. 16077-16200), mw:m5sw (l. 17213-17289) ; dans `R/engine.R` : `.engine_saisie_lisible()` et ses appels, `PHRASE_VERDICT_SENSIBLE_MC`, `DETAIL_P_FAMILLE`, `DETAIL_P_GLOBALE`, `H0n`, H0 des lignes M5, `detail` de Cramér–von Mises et de l'ESD, `PHRASE_MW_ROSNER_DIAGNOSTIC`, motif de `.engine_calcul_protege()`, branche R3 d'`add()` (l. 4659-4660), lecteur `engine_lire_donnees_csv()` ; `tests/unitaires/test_non_applicable.R` (invariant `loi`) ; `docs/tableaux/20261111-issue503-m2var-exposants.md` ; sorties de contrôle de docwriter (`k4-doc/i527.nd.txt`, `base.nd.txt`, `i527.concordance.txt`).
- Exécuté (`LC_ALL=C.UTF-8`, moteur chargé par `charger_moteur()`) :
  - textes restitués par les références (`engine_table_tests()` sur `premium.rds` et `reserve2.rds`) : `H0n`, H0 des deux lignes M5, `detail` Cramér–von Mises, ESD lognormal, Rosner M-W (`alpha = 0.1`), T-1 de famille ; tous identiques, à la lettre, aux citations du `.tex` ;
  - `run_engine(..., B = NA)` : « B = NA (valeur manquante) : le nombre de replications bootstrap doit etre ... » (citation du `.tex` exacte) ;
  - `engine_lire_donnees_csv()` avec une cellule texte « NA » en ligne 2 de `xt` : « ... (colonne xt : ligne(s) de donnees 2). Une cellule "NA" est lue comme du texte ... » (exact) ;
  - `engine_valider_donnees()` à ratio 100 : « Ratio y_t/x_t hors de la plage plausible [0.1 ; 5[ : verifier les unites. » (exact) ;
  - quadrature de A² et W² (script de la session `scratchpad/verif_ad_cvm.R`) : intégrales et `stat_ad()` / `stat_cvm()` égales à 1e-12 près (0,363194124173 ; 0,056967202769) ; la phrase « vérifié par quadrature numérique » est vraie ;
  - chiffres de mw:m2var recalculés sur T1 du tableau daté : max P1 3,68 / 3,69 / 3,69e-4 ; parts P2 12,6 / 11,2 / 9,8 % ; rapports de médianes P2/P1 13,3 à 13,8 ; variation des médianes entre exposants 1,10 (P2) et 1,06 (P1) ; volet R 0,80740 à 0,80769, étendue 2,90e-4 : tous conformes.
- Concordance `--strict` (sortie de docwriter) : 0 écart. Recherche des anciens textes du moteur dans le `.tex` (« tres correlee », « (n >= 25) », « alpha = 0.10, nombre », « Ratio y/x hors », « erreur R dans », « de ligne n'etant modifie », « A lire avec les lignes », « residus standardises suivent », « residus de Mack sont normaux », « verdict sensible » en minuscule, « note d'implementation », « (T = 4) ») : aucune occurrence.

## 1. Fond, issue par issue

| Issue | Passage | Avis |
|---|---|---|
| #528 | H0 des six fiches de normalité de H3, des deux fiches M5 | Juste. La H0 dit l'hypothèse éprouvée (normalité des ε_t du modèle réglementaire, lue à travers z = Pε), et la seconde phrase dit à quoi la statistique rapporte les z_t (famille normale pour W, W', D_L ; N(0,1) pour A², W², D, avec la mention exacte que les z_t ne la suivent pas sous H0). M5 : la H0 de diagnostic et le modèle auxiliaire de la p restituée sont bien séparés, et la référence « deux contraintes exactes par colonne, rubrique 6 » renvoie à un passage qui les écrit (l. 17271-17274). **Mais la rubrique 1 des fiches lognormales contredit maintenant la rubrique 2 : correction C1 (§ 2, point 1).** |
| #506 | T-1, T-2 cités ; fiches p-famille, p-globale | Citations exactes à la lettre (découpage `\code{}` contrôlé mot à mot contre les constantes). « rappelle la portée d'une p élevée » : juste. |
| #519 | ESD lognormal (sec:nature, fiche rosner-esd, rubrique 4 « C7.a, sous i.i.d. normal ») ; Rosner M-W ; phrase de #244 ; Cramér–von Mises | Juste. La condition « sous i.i.d. normal » du constat C7.a est posée à chaque occurrence, avec le statut « constat de simulation » ; aucun chiffre nouveau. Cramér–von Mises : la relation « A² est W² pondérée par [F0(1−F0)]^{-1} » est exacte par définition ; la dépendance entre A² et W² est dite non chiffrée et sa mesure reportée après la remise : le fond de l'ancien texte (corrélation non chiffrée) est conservé, rien n'est affaibli. |
| #533 | Champ `loi` à NA sur toute ligne non applicable (sec:nature, R3, libellés selon le régime, suites) | Juste et conforme au code (R3 d'`add()` l. 4659-4660, invariant de `test_non_applicable.R` sur les jeux du fichier et les six références). |
| #503 | mw:m2var, rubriques 5 et 6 | Texte fixé repris mot pour mot ; chiffres conformes au tableau. Le script est cité dans les deux rubriques, mais le tableau daté ne l'est pas : **correction C2 (§ 2, point 2)**. |
| #527 | Index (`.engine_saisie_lisible()`), sec:nature, motif du défaut de calcul intercepté, avertissement de ratio, positions de cellules | Citations exactes ; la description de `.engine_saisie_lisible()` (NA hors NaN, sans attribut ; sites d'emploi) correspond au code (l. 501-507 ; appels l. 8258, 8274, 8365, 13250 et dans `.engine_verifier_usage()`). |
| Version | 3.4, 11 novembre 2026 | Sans objection. |

Statut épistémique : aucune confusion exact / asymptotique / approximation / constat de simulation dans le diff. Aucune référence, aucun chiffre, aucun théorème nouveau non fondé. Vocabulaire de `CONTEXT.md` tenu (modèle réglementaire, diagnostic par décision, ligne non applicable, p-value de Monte-Carlo, constat de simulation). Aucun fond retiré à tort : les seuls retraits sont les anciennes H0 (reprises dans la seconde phrase des nouvelles), les chiffres de m2var du 08/11 tirés sous une graine non consignée (type 6 : valeurs non versionnées remplacées) et l'adjectif « tres correlee » (remplacé par une relation exacte, la réserve de non-mesure étant gardée).

## 2. Points ouverts laissés par docwriter

### Point 1 (#528) : rubrique 1 des fiches de normalité de H3 — **corriger**

Constat. « Échantillon $z_1,\dots,z_T$ supposé (hypothèse non testée) i.i.d. » (Shapiro–Wilk), « Échantillon i.i.d. (hypothèse non testée) » (Anderson–Darling, Lilliefors ; repris par renvoi par Shapiro–Francia, Cramér–von Mises, Kolmogorov–Smirnov) pose comme hypothèse de validité de la ligne une propriété que les z_t n'ont jamais sous le modèle (z = Pε, P projecteur de rang T − 1, résultat exact de sec:base-residus), et que la nouvelle H0 nie expressément. Ce qui est vrai :
- l'hypothèse i.i.d. est celle des **sources**, donc des **p-values non simulées** (Royston, Stephens, Dallal et Wilkinson, Kolmogorov), qui ne sont jamais retenues ;
- à π̂_t constant et pour une statistique invariante par translation et changement d'échelle positif, la statistique calculée sur z a exactement, sous le modèle ajusté, la loi qu'elle a sur un échantillon i.i.d. normal (encadré « Point commun » en tête de sec:h3) ; à π̂_t variable, non ; pour D contre N(0,1) calculée sur z (non invariante), jamais ;
- la p-value de Monte-Carlo retenue est simulée sous le modèle ajusté et ne suppose pas un échantillon i.i.d.

Correction minimale, en trois remplacements ; Shapiro–Francia (« Mêmes hypothèses que Shapiro--Wilk »), Cramér–von Mises (« Identique à Anderson--Darling ») et Kolmogorov–Smirnov (« Identique aux deux fiches précédentes ») suivent par renvoi, sans retouche : le texte d'Anderson–Darling est écrit pour couvrir aussi D sur z (statistique non invariante, condition jamais remplie), ce que dit déjà la rubrique 6 de Kolmogorov–Smirnov. Aucun `\ref` ajouté (la section sec:base-residus est déjà citée en rubrique 2 de chaque fiche, type 9).

**C1.a — fiche:shapiro-wilk, rubrique 1.** Remplacer :

```latex
Échantillon $z_1,\dots,z_T$ supposé (hypothèse non testée) i.i.d., sans ex \ae quo. Valable pour
$3 \le T \le 5000$.
```

par :

```latex
Résidus standardisés $z_1,\dots,z_T$, sans ex \ae quo. L'échantillon i.i.d. que suppose la source
est l'hypothèse de la p-value de Royston, non retenue~: $W$ étant invariante (rubrique~2), $W(z)$ a,
sous le modèle ajusté, exactement sa loi sur un échantillon i.i.d. normal de taille~$T$ à
$\hat\pi_t$ constant, et non à $\hat\pi_t$ variable (encadré en tête de section)~; la p-value de
Monte-Carlo retenue ne la suppose pas. Valable pour $3 \le T \le 5000$.
```

(la suite, « On note $m = \dots$ », inchangée.)

**C1.b — fiche:anderson-darling, rubrique 1.** Remplacer :

```latex
Échantillon i.i.d. (hypothèse non testée), $p_{(i)} = \Phi(z_{(i)})$. Statistique de distance à la
fonction de répartition empirique (famille EDF).
```

par :

```latex
Résidus standardisés $z_t$, $p_{(i)} = \Phi(z_{(i)})$. Statistique de distance à la fonction de
répartition empirique (famille EDF). L'échantillon i.i.d. que supposent les sources est
l'hypothèse des p-values non simulées, jamais retenues~: une statistique calculée sur les $z_t$
n'a, sous le modèle ajusté, la loi qu'elle aurait sur un échantillon i.i.d. normal que si elle est
invariante par translation et changement d'échelle positif, comme $A^2$ de $(z - \bar z)/s_z$
(rubrique~5), et à $\hat\pi_t$ constant (encadré en tête de section)~; la p-value de Monte-Carlo ne
la suppose pas.
```

**C1.c — fiche:lilliefors, rubrique 1.** Remplacer la seule première phrase :

```latex
Échantillon i.i.d. (hypothèse non testée).
```

par :

```latex
Résidus standardisés $z_t$. L'échantillon i.i.d. que supposent les sources est l'hypothèse de la
p-value de Dallal et Wilkinson, non retenue~: $D_{\mathrm{L}}$, invariante par translation et
changement d'échelle positif, n'a, sous le modèle ajusté, la loi qu'elle aurait sur un échantillon
i.i.d. normal qu'à $\hat\pi_t$ constant (encadré en tête de section)~; la p-value de Monte-Carlo
retenue ne la suppose pas.
```

(la suite, « \textbf{Différence essentielle avec la fiche précédente}~: … », inchangée.)

Fondement (*vérifié* par lecture) : sec:base-residus, l. 8423-8444 (z = Pε, résultat exact ; z ∝ Mε à π̂_t constant) ; encadré l. 10592-10617 (statistiques invariantes, égalité de lois à π̂_t constant, « sous le modèle ajusté pris pour vrai et non conditionnellement au régime de δ̂ » ; D de Kolmogorov–Smirnov contre N(0,1) dans la catégorie (ii)) ; Pval des fiches (p non simulées restituées, jamais retenues ; Monte-Carlo retenue pour SW, SF, AD, Lilliefors ; aucune retenue pour CvM et KS). Effet sur la taille (*estimation*) : environ +350 caractères pour SW et AD, +300 pour Lilliefors ; d'après `i527.nd.txt`, SW 6 296, AD 7 270 (3 pages, « à vérifier » depuis #528), Lilliefors 5 936 : toutes restent sous 10 500, donc sans violation possible. `compiler-doc` le confirmera.

### Point 2 (#503) : citer le tableau daté dans mw:m2var — **oui**

La grille (type 6) exige, pour chaque constat de simulation, le fichier `docs/tableaux/` ; le script seul donne le moyen de refaire la mesure, mais pas le résultat daté (md5, plateforme, contrôles, T2b qui fonde « décalage faible mais systématique »). Mon texte fixé l'omettait : c'est une lacune de ma part, non de docwriter. Le constat du bootstrap (999 triangles) est en **rubrique 5** (`\Pval`), non en rubrique 4 comme l'écrivait ma validation de #503 ; docwriter l'a correctement placé.

**C2.a — mw:m2var, rubrique 5.** Remplacer :

```latex
section~\ref{sec:boot-mw}, graine 20260831, \code{tests/mesure\_m2var\_exposants\_mw.R}) et en recalculant $\operatorname{Var}(r)$ sur chacun,
```

par :

```latex
section~\ref{sec:boot-mw}, graine 20260831, \code{tests/mesure\_m2var\_exposants\_mw.R}, tableau~T3
de \code{docs/tableaux/}\allowbreak\code{20261111-}\allowbreak\code{issue503-m2var-exposants.md}) et
en recalculant $\operatorname{Var}(r)$ sur chacun,
```

**C2.b — mw:m2var, rubrique 6.** Remplacer :

```latex
\code{tests/mesure\_m2var\_exposants\_mw.R})~: l'écart à $(N-k)/(N-1)$ a des lois voisines sous
```

par :

```latex
\code{tests/mesure\_m2var\_exposants\_mw.R}, tableaux~T1 et~T2b du fichier cité en rubrique~5)~:
l'écart à $(N-k)/(N-1)$ a des lois voisines sous
```

(T1 porte les maxima, parts et médianes cités ; T2b, le test exact de McNemar apparié qui fonde « que les graines communes rendent détectable ».) Taille : +170 caractères environ sur 8 111.

Constat hors `.tex`, mineur : l'en-tête du script (« rubriques 4 et 6 ») et le titre de T3 du tableau daté (« support de la rubrique 4 de `mw:m2var` ») portent la même erreur de numéro, issue de ma validation de #503. Aucun chiffre en cause ; la correction demande une modification de texte du script et la régénération du tableau (md5 changé). À traiter hors de K4, en issue `tests:` ou correctif rapide, sur accord du mainteneur ; je ne la juge pas bloquante pour la sortie du brouillon.

### Point 3 (#506) : condensation préventive de fiche:p-famille — **non**

- Verdict du contrôle : « à vérifier » (3 pages, 10 443 caractères), **pas** une violation (CONVENTIONS.md, « Plafond » : violation si 3 pages **et** plus de 10 500 caractères).
- La fiche était déjà à 3 pages et « à vérifier » avant la branche (10 406 caractères, `base.nd.txt`) ; K4 n'ajoute que 37 caractères, une phrase de renvoi au texte T-1.
- Une condensation sortirait du périmètre de K4 (textes du moteur), demanderait le relevé des retraits dans `docs/suivi-documentation/`, et toucherait une fiche dont le fond (lecture conjointe, nature plug-in, puissance non mesurée) est précisément celui que #506 vient de renforcer.
- Plusieurs fiches sont plus près du seuil (`mw:influence` 10 499, `mw:m1b` 10 496, `fiche:qqnorm` 10 495) sans qu'aucune condensation soit demandée.
- Recommandation : toute addition future à fiche:p-famille passe d'abord par une condensation de forme (types 5, 6, 9) ou une demande d'exception motivée ; à consigner, si la session le souhaite, dans la feuille de route, sans issue nouvelle.

## 3. Observations non bloquantes (aucune correction demandée)

- Les nouvelles rubriques 2 des fiches de normalité dépassent le budget indicatif de 300 caractères (environ 400). Le budget n'est qu'indicatif ; le fond (H0 du modèle, et ce à quoi la statistique rapporte les z_t) prime.
- « vérifié par quadrature numérique » (Cramér–von Mises) s'appuie sur un contrôle non versionné ; je l'ai rejoué (égalité à 1e-12 près). L'identité des formes discrètes et intégrales est par ailleurs classique ; aucune retouche requise.
- La H0 « lognormalité (H3), soit les erreurs ε_t ... i.i.d. N(0,1) » condense, par « soit », l'équivalence que l'encadré de sec:h3 n'établit qu'avec H1, H2 et l'indépendance des années ; l'encadré le dit, et le texte reprend celui du moteur (`H0n`), que j'ai fixé. Pas de changement.

## 4. Verdict

**Validé avec réserves.** Réserves : appliquer C1 (a, b, c) et C2 (a, b) mot pour mot, en un commit `docs:` minimal (Refs #528, Refs #503), compilé et contrôlé (`compiler-doc`, concordance `--strict`, contrôle du plafond). Si ces textes sont appliqués à la lettre et que le contrôle ne signale aucune violation, aucune nouvelle validation d'actuary n'est requise ; tout écart au texte cible revient à actuary.

Aucun σ_USP, aucune p-value ni aucun verdict ne change du fait du `.tex`. Aucune question au mainteneur sur σ_USP ou sur la lecture d'un verdict. Pour information (déjà signalé à l'avis amont) : `H0n` s'affiche sur des lignes à verdict (SW, SF, AD, Lilliefors) ; il dit ce que ces verdicts ont toujours éprouvé.

## Retour

- **Statut** : `complet`.
- **Résultat** : validé avec réserves ; deux corrections (C1 : rubrique 1 de SW, AD, Lilliefors ; C2 : tableau daté dans mw:m2var, rubriques 5 et 6) ; point 3 : pas de condensation.
- **Preuves** :
  - *vérifiées* : citations du moteur contre `R/engine.R` et contre les références (`engine_table_tests()`), messages de #527 par exécution ; chiffres de m2var contre T1 et T3 ; quadrature A²/W² ; tailles et verdicts de plafond (`i527.nd.txt`, `base.nd.txt`) ; concordance stricte à 0 écart ; R3 d'`add()` et invariant de `test_non_applicable.R` par lecture ;
  - *hypothèses* : les tailles après C1 et C2 (estimées, à mesurer par `compiler-doc`) ;
  - *non vérifiés* : rendu PDF des passages corrigés (non compilés par moi).
- **Informations manquantes** : aucune.
- **Décisions non résolues** : traitement du numéro de rubrique erroné dans l'en-tête du script et le titre de T3 du tableau daté (mainteneur : issue `tests:` ou correctif rapide).
- **Critères déclenchés** : aucun désaccord avec `audit`, un ADR ou un autre agent ; aucun changement de résultat ; écart entre mon texte fixé de #503 et la grille (tableau non cité ; numéro de rubrique), corrigé ici.
- **Prochaine action recommandée** : docwriter applique C1 et C2 en un commit `docs:` minimal, `compiler-doc` et concordance `--strict` ; puis la session verse cet avis dans `docs/revues/` et prépare le commit du PDF avant la sortie du brouillon.
