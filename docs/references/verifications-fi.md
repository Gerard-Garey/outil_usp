# Vérification des références externes de la branche Fi (M1 à M4)

> *Rédigé par Claude (session de vérification bibliographique, en lecture seule sur le dépôt), le 22/10/2026, à la demande de la session principale de Fi : décision 2 du mainteneur dans le handoff de la PR #349 (branche `claude/merz-wuthrich-puissance`).*

## Objet

Le mainteneur veut que toutes les références externes de Fi soient vérifiées une fois pour toutes. Le présent relevé couvre :

- les champs `reference`, `loi` et `detail` des lignes M1 à M4 de `mw_tests()` (`R/engine.R`, tête `05c24ae`) et la phrase `PHRASE_MW_ROSNER_DIAGNOSTIC` ;
- les fiches M1 à M4 de `docs/latex/doc_tests_usp.tex` (`mw:m1` à `mw:m4ros`), la section `sec:calib-mc-mw` et les notices correspondantes de `sec:biblio` ;
- les références de la spécification `docs/specifications/fi-merz-wuthrich-puissance.md`.

Les numéros de ligne citent la tête `05c24ae` (`R/engine.R` et `.tex` identiques à `b372718`).

**Rosner (1983).** Ce que #347 a établi n'est pas refait :

- le relevé du 19/10 (corps de #347) ;
- le contrôle sur le texte intégral du 20/10 (commentaire `6290307185`, archive *Technometrics* de CMU).

Le § 1 ne reprend que le rattachement des affirmations de Fi à ces relevés, et les deux notices que #347 laissait au niveau des métadonnées.

## Méthode et statuts

- **[V]** : vérifié sur le texte, avec la page, la section ou l'équation, et la source consultée. Les citations sont en anglais, courtes, entre guillemets.
- **[P]** : vérification partielle. La notice est vérifiée (Crossref, éditeur, JSTOR ou RePEc), mais l'énoncé n'a pas été lu dans le texte ; la raison est donnée.
- **[X]** : affirmation fausse ou non trouvée. La correction est proposée au § « Corrections à apporter ».

Lecture du texte :

- **Formules et tableaux** : lus en rendu graphique (pages converties en image).
- **Prose** : extraction de texte, la page étant ensuite contrôlée par son en-tête ou son pied de page imprimé.
- **Aucun fichier source n'a été déposé dans le dépôt.**

## Sources consultées (22/10/2026)

| Source | Accès | Contenu lu |
|---|---|---|
| Crossref (`api.crossref.org`), OpenAlex, RePEc/IDEAS, pages de l'Econometric Society, métadonnées JSTOR d'archive.org | libre | notices : auteurs, titre, revue, volume, numéro, pages, DOI ; résumés de Harvey (1976) et de Breusch-Pagan (1979) |
| Mack (1993), *ASTIN Bulletin* : `casact.org/sites/default/files/database/astin_vol23no2_213.pdf` (14 p.) | libre | texte intégral, p. 213-225 |
| Mack (1994), *CAS Forum* : `casact.org/pubs/forum/94spforum/94spf101.pdf` (82 p., pagination imprimée 101-182 conforme) | libre | texte intégral ; p. 110-111, 121-126, 155-158, 162-167 lues en rendu graphique |
| Cook et Weisberg (1982) : University Digital Conservancy (UMN), `hdl.handle.net/11299/37076`, fichier `Cook_Weisberg_Residuals_and_Influence.pdf` (240 p.) | libre | texte intégral ; p. 20-26 et 209 lues |
| *Econometrica*, vol. 1 (1933), archive.org `sim_econometrica_1933_1` (texte OCR) | libre | Frisch et Waugh (1933), p. 387-401 |
| *Ann. Math. Stat.* 21(1) (1950), archive.org `sim_annals-of-mathematical-statistics_1950-03_21_1` (texte OCR) | libre | Grubbs (1950), p. 27 |
| *Ann. Math. Stat.* 28(1) (1957), archive.org `sim_annals-of-mathematical-statistics_1957-03_28_1` (texte OCR) | libre | Dwass (1957), p. 181-182 |
| Grubbs (1969), *Technometrics* : `stat.cmu.edu/technometrics/59-69/VOL-11-01/v1101001.pdf` (21 p.) | libre | texte intégral, p. 1-5 |
| Atkinson (1983), *Technometrics* 25(1) : `stat.cmu.edu/technometrics/80-89/VOL-25-01/v2501023.pdf` | libre | p. 24 (attestation secondaire de Belsley, Kuh et Welsch) |
| Fisher, *Statistical Methods for Research Workers*, 12ᵉ éd. (1954), archive.org `dli.scoerat.2986statisticalmethodsforresearchworkers` ; 2ᵉ éd. (1928), `statisticalmethoe2fish` | libre | § 21.1 (12ᵉ éd., p. 99-100) ; table du § 21 (2ᵉ éd.) |
| Merz et Wüthrich (2008) : `casact.org/pubs/forum/08fforum/21merz_wuetrich.pdf` (27 p.) | libre | pagination 542-568 |
| Powell, notes de cours *Models, Testing, and Correction of Heteroskedasticity* (Berkeley, 2006) : `eml.berkeley.edu/~powell/e240b_sp06/hetnotes.pdf` | libre | p. 3-4, attestation secondaire de Koenker (1981) |

**Non accessibles** (motif) :

- Koenker (1981) : ScienceDirect et CORE répondent 403.
- Harvey (1976) et Breusch et Pagan (1979) : JSTOR, accès payant.
- Belsley, Kuh et Welsch (1980) : archive.org `regressiondiagno0000bels`, prêt contrôlé ; recherche plein texte refusée.
- Fisher, 4ᵉ éd. (1932) : archive.org `statisticalmetho00fish`, prêt contrôlé.
- Mack (1997), *Claims Reserving Manual* : `actuaries.org.uk` en maintenance le 22/10/2026 ; Wayback Machine bloquée par le proxy ; la copie `mnb.hu` est celle du *CAS Forum* de 1994.
- Holm (1979) : JSTOR ; la copie `ime.usp.br` répond 503.
- Hope (1968), McNemar (1947), Clopper et Pearson (1934), Ramsey (1969), Kruskal et Wallis (1952), Durbin et Watson (1950, 1951), Wald et Wolfowitz (1940) : non cherchés en texte intégral. Fi ne leur attribue aucun énoncé précis, et leurs notices sont vérifiées.

---

## Tableau récapitulatif

| # | Référence | Affirmation du dépôt | Lieu dans le dépôt | Page / éq. | Statut |
|---|---|---|---|---|---|
| 1 | Rosner (1983) | Valeurs critiques par l'éq. (2.5), approximation de Student-Bonferroni ; domaine déclaré n ≥ 25 ; cadre i.i.d. normal | `R/engine.R:10260-10267`, `:10657` ; spéc. l. 33, 331-335 | p. 165, 166 (éq. (2.3), (2.5)), 167, 171 | [V] (#347) |
| 1b | Rosner (1983) | Fiche `mw:m4ros` : « λ_i tabulées », « séquentiellement », « résout le masquage », « limite de son domaine », k = ⌊n/4⌋ | `doc_tests_usp.tex:15165-15183` | p. 165-167, 171 | [X] (écarts 1, 2, 3, 6, 7 de #347) |
| 2a | Cook et Weisberg (1982) | Résidu studentisé externe ; loi de Student à n − p′ − 1 ddl sous normalité, donc n_j − 2 ici (p′ = 1) | `R/engine.R:10621-10624`, `:10627`, `:10632-10637` ; spéc. l. 21, 320, 481 | p. 20, éq. (2.2.7)-(2.2.10) ; p. 21, éq. (2.2.15) | [V] |
| 2b | Cook et Weisberg (1982) | Régression pondérée de poids 1/C(·,j) | `R/engine.R:10622`, `:10633` | annexe A.1, p. 209 | [V] |
| 2c | Cook et Weisberg (1982) | Borne de Bonferroni sur le maximum des t_i | `R/engine.R:10624`, `:10630`, `:10637-10638` ; spéc. l. 319 | p. 22 et 26 | [V], avec une précision : publiée pour une régression, l'extension aux colonnes est de l'outil |
| 2d | Belsley, Kuh et Welsch (1980) | Résidu studentisé externe (RSTUDENT, `rstudent()`) | `R/engine.R:10622` ; `doc_tests_usp.tex:16921-16926` | chap. 2 (d'après Atkinson 1983, p. 24) | [P] |
| 3a | Koenker (1981) | Forme N R² studentisée de Breusch-Pagan | `R/engine.R:10431` ; `doc_tests_usp.tex:9009-9012`, `:14292` ; spéc. l. 233 | — | [P] |
| 3b | Frisch et Waugh (1933) | Théorème de partialisation, établi pour une tendance temporelle | `R/engine.R:10432`, `:10444`, `:8619` ; `doc_tests_usp.tex:13423-13426` | p. 388, 393, 396 | [V] |
| 3c | Breusch et Pagan (1979) | Notice ; test du multiplicateur de Lagrange | `doc_tests_usp.tex:9009-9010`, `:14291` | — | [P] (notice et résumé [V]) |
| 4 | Harvey (1976) | « Variante de Harvey (log r² ~ facteur(j) + log C) », non retenue | spéc. l. 11, 21, 75, 236-239, 445, 481 | résumé | [P] (notice et résumé [V]) |
| 5a | Grubbs (1950) | Statistique de l'écart extrême studentisé | `doc_tests_usp.tex:11333-11335`, `:15122` | p. 27 | [V] |
| 5b | Grubbs (1969) | Même statistique ; usage bilatéral ; hypothèse de normalité | `doc_tests_usp.tex:11333-11337`, `:15122`, `:15124-15126` | p. 3-5 (§ 3.2, 4.1, 4.2) | [V] |
| 5c | Grubbs (1950, 1969) | Référence de la ligne M4 « Cellule aberrante » | `doc_tests_usp.tex:15120-15157` (`mw:m4gr`) | — | [X] (concordance : statistique remplacée par MinP4) |
| 6a | Mack (1993) | Hyp. (1), section 2, p. 214 ; hyp. (3), section 3, p. 217 ; σ̂²_j, section 3, p. 217 | `R/engine.R:10337`, `:10352` ; `doc_tests_usp.tex:13377-13379`, `:13487-13489`, `:14411-14412`, `:17170-17172` | p. 213-225 | [V] |
| 6b | Mack (1994, *CAS Forum*) | chap. 3, p. 111 ; chap. 5, p. 121-125 ; annexe G, p. 155-161, (G4)-(G6) ; annexe H, p. 162-168, avec les p. 163, 164, 165 (H1, H2), 166 et 166-167 ; données RAA, p. 125-126 | `R/engine.R:10352`, `:10415`, `:10511`, `:10577` ; `doc_tests_usp.tex:13490-13491`, `:14221-14224`, `:14546-14560`, `:14664-14693`, `:14947-14950`, `:17180-17194` | voir § 6 | [V] |
| 6c | Mack (1997, *CRM*) | Annexe H révisée p. D6.47-D6.51, repère de 10 % p. D6.49, note p. D6.1, annexe G p. D6.42-D6.46 | `R/engine.R:10527`, `:10542`, `:8497` ; `doc_tests_usp.tex:14549-14553`, `:14765`, `:14949`, `:17196-17209` | — | [P] |
| 6d | Merz et Wüthrich (2008) | Notice *CAS E-Forum*, automne 2008, p. 542-568 | `doc_tests_usp.tex:17223-17225` | p. 542-568 | [V] (notice) |
| 6e | Fisher (1932), 4ᵉ éd., § 21.1 | Combinaison des p-values | `doc_tests_usp.tex:13492-13493` (`mw:m1a`) | § 21.1 | [P] (§ 21.1 [V] dans la 12ᵉ éd.) |
| 6f | Spearman (1904) | Notice | `doc_tests_usp.tex:8654-8655`, `:13820`, `:14950` | p. 72-101 | [V] (notice) |
| 6g | Ramsey (1969) | Notice ; « dans l'esprit de » | `R/engine.R:10395` ; `doc_tests_usp.tex:8560-8562`, `:13934` | p. 350-371 | [V] (notice) |
| 6h | Kruskal et Wallis (1952) | Notice | `R/engine.R:10555` ; `doc_tests_usp.tex:14881-14883` | p. 583-621 | [V] (notice) |
| 6i | Durbin et Watson (1950, 1951) | Notice | `R/engine.R:10586` ; `doc_tests_usp.tex:10029-10031` | p. 409-428 ; 159-178 | [V] (notice) |
| 6j | Wald et Wolfowitz (1940) | Notice | `R/engine.R:10597` ; `doc_tests_usp.tex:10161-10162` | p. 147-162 | [V] (notice) |
| 6k | Dwass (1957) | Exactitude à B fini d'un test fondé sur un échantillon de permutations | `doc_tests_usp.tex:16323-16324`, `:16706-16707` | p. 181-182 | [V], avec une nuance |
| 6l | Hope (1968) | Idem (tests de Monte-Carlo) | `doc_tests_usp.tex:16324`, `:16708-16710` | p. 582-598 | [P] |
| 6m | Holm (1979) | Correction séquentielle de Bonferroni | `doc_tests_usp.tex:16485`, `:16816-16823` ; spéc. l. 348 | p. 65-70 | [P] |
| 6n | McNemar (1947) ; Clopper et Pearson (1934) | Notices | `doc_tests_usp.tex:16825-16826`, `:16794-16796` | p. 153-157 ; p. 404-413 | [V] (notices) |
| 6o | Thompson (1935) ; Quesenberry et David (1961) | Notices citées par Rosner (1983), relevées dans #347 | #347, commentaire `6290307185` | p. 214-219 ; p. 379-390 | [V] (notices) |

---

## 1. Rosner (1983)

**Notice [V]** (Crossref, DOI 10.1080/00401706.1983.10487848) : B. Rosner, « Percentage Points for a Generalized ESD Many-Outlier Procedure », *Technometrics*, 25(2), mai 1983, p. 165-172.

**Contenu.** Le contenu est établi sur le texte intégral par #347 : relevé du 19/10, puis contrôle du 20/10 (commentaire `6290307185`, archive CMU `stat.cmu.edu/technometrics/80-89/VOL-25-02/v2502165.pdf`). Ces relevés ne sont pas refaits ici.

**Rattachement des affirmations de Fi.**

| Affirmation | Lieu | Appui dans #347 | Statut |
|---|---|---|---|
| « Ses valeurs critiques (eq. (2.5), approximation de Student-Bonferroni) » | `R/engine.R:10262-10263` | éq. (2.5), p. 166 ; borne de Bonferroni (2.3), p. 166, « we will approximate Pr(max y_i > λ_{l+1}) by (n − l) Pr(y_i > λ_{l+1}) » ; loi d'un écart studentisé (2.2), p. 166 (Thompson 1935) | [V] |
| « son domaine declare (n >= 25) » | `R/engine.R:10263` | résumé, p. 165 : « for detecting up to 10 outliers in samples as small as 25 » ; p. 167 : « for n ≥ 25 the estimated α levels are quite close to .05 » ; p. 171 : « does not work well for small samples (n < 25) » | [V] |
| « valent pour un echantillon i.i.d. normal » | `R/engine.R:10263-10264` | p. 165 : « under the assumption that the main body of data comes from a normal distribution » | [V] |
| « le cadre de Rosner (1983) ne les couvre pas » (résidus de Mack) | `R/engine.R:10265-10266` | le mot « residual » n'apparaît nulle part dans l'article (#347, contrôle du 20/10, ligne 1b) | [V], par absence dans le texte |
| λ à T = 8 : 2,0317 et 1,9381 (α = 0,10) ; 2,1266 et 2,0200 (α = 0,05) | spéc. l. 331 | recalcul par (2.5), code R dans #347 | [V] |
| « Monte-Carlo pour les petits n », p. 171 ; non-normalité renvoyée à des travaux futurs, p. 171 | spéc. l. 335 | #347, lignes 7b et 7e | [V] |

Les pages que la spécification déclare « reprises de #347, non relues ici » (l. 22, 335, 481) sont donc **toutes [V]** sur le texte intégral depuis le contrôle du 20/10. La réserve (ii) de l'encadré de la spécification est levée sur ce point.

**Notices citées par Rosner, que #347 laissait aux métadonnées (Crossref) [V] :**

- W. R. Thompson, « On a Criterion for the Rejection of Observations and the Distribution of the Ratio of Deviation to Sample Standard Deviation », *Annals of Mathematical Statistics*, 6(4), 1935, p. 214-219, DOI 10.1214/aoms/1177732567. Texte non lu.
- C. P. Quesenberry, H. A. David, « Some tests for outliers », *Biometrika*, 48(3-4), 1961, p. 379-390, DOI 10.1093/biomet/48.3-4.379. Texte non lu.

**Fiche `mw:m4ros` [X].** Ses écarts au texte de Rosner sont ceux que #347 a numérotés ; voir « Corrections à apporter », point 1.

---

## 2. Résidu studentisé externe : Cook et Weisberg (1982) ; Belsley, Kuh et Welsch (1980)

### 2.1 Cook et Weisberg (1982) [V]

**Notice [V]** (page de titre et page de copyright, PDF p. 4-5) : R. D. Cook, S. Weisberg, *Residuals and Influence in Regression*, Chapman and Hall, New York et Londres, 1982 (Monographs on Statistics and Applied Probability), x + 230 p., ISBN 0-412-24280-0.

Accès libre : University Digital Conservancy de l'université du Minnesota, `hdl.handle.net/11299/37076`.

**Définition et loi** (§ 2.2.1, « External Studentization », p. 20) :

- σ̂²₍ᵢ₎ est la variance résiduelle calculée sans le cas i (éq. (2.2.7)-(2.2.8)).
- « Under normality, σ̂²₍ᵢ₎ and e_i are independent, and the externally Studentized residuals are defined by » t_i = e_i / [σ̂₍ᵢ₎ (1 − v_ii)^{1/2}] (éq. (2.2.9)).
- « The distribution of t_i is Student's t with n − p′ − 1 degrees of freedom. » p′ est le nombre de paramètres du modèle.
- Relation au résidu studentisé interne r_i : éq. (2.2.10).

**Modèle de décalage de moyenne** (§ 2.2.2, p. 20-21, éq. (2.2.11)-(2.2.15)) :

- La statistique t du test de φ = 0 « follows a t(n − p′ − 1) distribution under the null hypothesis ».
- « this test statistic for the shift model is identical to the externally Studentized residual » (p. 21).
- Cela fonde H1 = « exactement un résidu aberrant » de `R/engine.R:10626`.

**Application à M4.** La régression de chaque colonne est sans constante, avec un régresseur, C(·,j) : p′ = 1, d'où n_j − 2 degrés de liberté. C'est conforme à `R/engine.R:10627` et `:10636`.

Le livre traite X comme fixe (modèle (2.1.1)). La lecture « conditionnellement aux cumuls de la colonne j » (`R/engine.R:10636`) revient à conditionner par C(·,j). Ce conditionnement est une étape de l'outil, cohérente avec le modèle de Mack, qui est conditionnel ; le livre ne l'énonce pas.

**Moindres carrés pondérés** (annexe A.1, p. 209) :

- Modèle Var(ε) = σ² W⁻¹, ramené aux moindres carrés ordinaires par W^{1/2}.
- « Studentized residuals are identical under either formulation. »

Les poids 1/C(·,j) de `R/engine.R:10622` sont donc couverts.

**Borne de Bonferroni sur le maximum** :

- p. 22 : « When the candidate case for an outlier is unknown, the test is usually based on the maximum of the t_i over all i. A multiple testing procedure, such as one based on the first Bonferroni inequality (Miller, 1966), must be used to find significance levels. A nominal level α, two-tailed test for a single outlier will reject if max_i |t_i| > t(α/n; n − p′ − 1). »
- p. 26 (« Accuracy of the Bonferroni bound for the outlier test ») : « the first Bonferroni upper bound for the true p-value is p-value ≤ n Pr(F > t̃²) », F suivant une loi F(1, n − p′ − 1). L'exactitude de cette borne est évaluée par Cook et Prescott (1981).
- p. 25 (exemple 2.2.1) : borne de Bonferroni de la p-value égale à 0,0425 pour t₁₉ = 3,607.

**Conséquence pour la `reference` de M4** (`R/engine.R:10624-10625`, « construction de l'outil »). La borne min(1, N_t·M) est la borne de Bonferroni publiée (p. 22 et 26), appliquée à toutes les cellules. Sont propres à l'outil :

- le passage au **minimum des p de Student**, imposé par des degrés de liberté n_j − 2 qui varient d'une colonne à l'autre, à la place de max |t_i| ;
- la restriction aux colonnes n_j ≥ 4 ;
- la p-value de Monte-Carlo.

Précision proposée en « Corrections à apporter », point 3. Ce n'est pas une erreur.

### 2.2 Belsley, Kuh et Welsch (1980) [P]

**Notice [V]** (métadonnées et MARC d'archive.org `regressiondiagno0000bels` ; Atkinson 1983, bibliographie) : D. A. Belsley, E. Kuh, R. E. Welsch, *Regression Diagnostics: Identifying Influential Data and Sources of Collinearity*, John Wiley & Sons, New York, 1980.

**Contenu non lu.** L'exemplaire d'archive.org est en prêt contrôlé, et sa recherche plein texte est refusée. Aucune page ni équation n'est donnée.

**Attestation secondaire [V]** : A. C. Atkinson, « Diagnostic Regression Analysis and Shifted Power Transformations », *Technometrics*, 25(1), 1983, p. 23-33, à la p. 24. Les résidus studentisés externes y sont « called RSTUDENT by Belsley, Kuh, and Welsch (1980, Ch. 2) ».

**Aide de R** (`?influence.measures`, R 4.3.3) : elle renvoie à « Belsley, Kuh and Welsch (1980), Cook and Weisberg (1982) » pour `rstudent()`, qui donne les « Studentized residuals […] using […] leave-one-out measure of the error variance ».

**Recommandation.** Garder Belsley, Kuh et Welsch (1980) pour le nom RSTUDENT seulement, en le disant attesté par Atkinson (1983, p. 24). Appuyer la **loi de Student** sur Cook et Weisberg (1982, p. 20), lu.

---

## 3. Ligne M2 : Koenker (1981), Frisch et Waugh (1933), Breusch et Pagan (1979)

### 3.1 Koenker (1981) [P]

**Notice [V]** (Crossref ; RePEc `RePEc:eee:econom:v:17:y:1981:i:1:p:107-112`) : R. Koenker, « A note on studentizing a test for heteroscedasticity », *Journal of Econometrics*, 17(1), septembre 1981, p. 107-112, DOI 10.1016/0304-4076(81)90062-2.

**Contenu non lu.** ScienceDirect répond 403, RePEc n'a pas de résumé, et aucune copie libre n'a été trouvée.

**Attestation secondaire [V].** J. L. Powell (Berkeley, 2006), p. 3-4 :

- « The resulting test, termed the "Studentized LM Test" by Koenker (1981), is a modification of the Score or Lagrange Multiplier (LM) test for heteroskedasticity proposed by Breusch and Pagan (1979) ».
- Statistique T ≡ N R² de la régression des résidus au carré sur 1 et z_i, de loi χ²(p) asymptotique.

**Ce qui reste [P] :**

- l'attribution de la forme « N R² » à Koenker lui-même (`R/engine.R:10431`, « forme n R^2 studentisee ») ;
- la phrase de la spécification (l. 233) : « La forme « n × R² partiel » est celle d'un multiplicateur de Lagrange à paramètres de nuisance estimés sous H0 », que la spécification marque elle-même [H].

Le corps de la `reference` ne dit rien de faux ; seule la page manque.

### 3.2 Frisch et Waugh (1933) [V]

**Notice [V]** (Crossref ; texte archive.org) : R. Frisch, F. V. Waugh, « Partial Time Regressions as Compared with Individual Trends », *Econometrica*, 1(4), octobre 1933, p. 387-401, DOI 10.2307/1907330.

L'article finit p. 401 ; la p. 402 ouvre l'article de R. Garver.

**Énoncés :**

- **p. 388** : « the two methods lead by definition to identically the same results. They differ only in the technique of computation ». La « partial time regression method » est comparée à l'« individual trend method » (p. 387).
- **p. 393** : cas de deux variables et d'une tendance linéaire, « Therefore the regression equations given by the two methods are identical ».
- **p. 396** : cas de n variables, éq. (4.21). « Thus the complete regression equation determined by the partial time regression method and the method of individual trends are identical ». Les auteurs relient cette identité à l'algorithme de Gauss, p. 396-397 : « this successive fitting of individual trends is identical with the determination of a simultaneous partial regression ».

**Affirmation du `.tex`** (`doc_tests_usp.tex:13423-13426`), « qui l'établissent pour une tendance temporelle ; il est appliqué ici à des indicatrices de colonne » : **[V]**.

**Nuance utile.** La forme par blocs de régresseurs (ici les indicatrices de colonne) est d'ordinaire attribuée à M. C. Lovell, « Seasonal Adjustment of Economic Time Series and Multiple Regression Analysis », *JASA*, 58(304), 1963, p. 993-1010, DOI 10.1080/01621459.1963.10480682. Notice [V] par Crossref, texte non lu. Le `.tex` présente déjà l'application aux indicatrices comme celle de l'outil ; aucune correction n'est nécessaire.

### 3.3 Breusch et Pagan (1979) [P]

**Notice [V]** (Crossref ; page de l'Econometric Society) : T. S. Breusch, A. R. Pagan, « A Simple Test for Heteroscedasticity and Random Coefficient Variation », *Econometrica*, 47(5), septembre 1979, p. 1287-1294, DOI 10.2307/1911963.

**Résumé [V]** : « A simple test for heteroscedastic disturbances in a linear regression model is developed », dans le cadre du multiplicateur de Lagrange.

**Texte non lu** (JSTOR). La fiche `mw:m2bp` (`doc_tests_usp.tex:14291`) ne lui attribue que le cadre général.

---

## 4. Harvey (1976) [P]

**Notice [V]** (Crossref ; page de l'Econometric Society ; JSTOR 1913974) : A. C. Harvey, « Estimating Regression Models with Multiplicative Heteroscedasticity », *Econometrica*, 44(3), mai 1976, p. 461-465, DOI 10.2307/1913974.

**Résumé [V]**, trois phrases :

- « A regression model in which the disturbances exhibit a certain type of heteroscedasticity is considered. »
- « Maximum likelihood methods of estimation are developed and compared with the two-step estimation procedure. »
- « A likelihood ratio test for heteroscedasticity is suggested. »

**Texte non lu** (JSTOR).

**Conséquence pour la spécification** (l. 236-239). Le test que l'article propose est, d'après son résumé, un **test du rapport de vraisemblance**. La régression auxiliaire de log r² relève de la procédure d'estimation en deux étapes, d'après des sources secondaires non retenues ici (documentation du paquet R `skedastic`, fonction `harvey`). L'appellation « Variante de Harvey (log r² ~ facteur(j) + log C) » désigne donc une régression auxiliaire inspirée de Harvey, et non le test de l'article.

La spécification marque déjà la forme du test **[NV]**, et la variante n'est pas retenue (Q-D1-Fi-5) : aucune affirmation du moteur ni du `.tex` n'en dépend. Précision facultative : « Corrections à apporter », point 6.

---

## 5. Grubbs (1950, 1969)

### 5.1 Grubbs (1950) [V]

**Notice [V]** (Crossref ; texte archive.org) : F. E. Grubbs, « Sample Criteria for Testing Outlying Observations », *Annals of Mathematical Statistics*, 21(1), mars 1950, p. 27-58, DOI 10.1214/aoms/1177729885.

**p. 27, § 1 (Summary)** :

- Grubbs propose S²ₙ/S² pour tester la plus grande observation d'un échantillon normal.
- Il le relie à T_n, « the studentized extreme deviation already suggested by E. Pearson and C. Chandra Sekar [1] for testing the significance of the largest observation ».
- Il en dérive la loi exacte.

**Notice de Pearson et Chandra Sekar [V]** (Crossref) : E. S. Pearson, C. Chandra Sekar, « The Efficiency of Statistical Tools and a Criterion for the Rejection of Outlying Observations », *Biometrika*, 28(3-4), 1936, p. 308-320, DOI 10.1093/biomet/28.3-4.308.

**Affirmation du dépôt.** La statistique G = max |x − x̄|/s est l'écart extrême studentisé de Grubbs, éventuellement en bilatéral (`doc_tests_usp.tex:15131`). Conforme [V] ; la forme bilatérale est au § 5.2.

### 5.2 Grubbs (1969) [V]

**Notice [V]** (Crossref ; texte CMU) : F. E. Grubbs, « Procedures for Detecting Outlying Observations in Samples », *Technometrics*, 11(1), février 1969, p. 1-21, DOI 10.1080/00401706.1969.10490657.

**§ 3.2, p. 3** : « almost all criteria for outliers are based on an assumed underlying normal (Gaussian) population or distribution ».

**§ 4.1, p. 3-5** : T_n = (x_n − x̄)/s, avec s au diviseur n − 1. Table 1, p. 4, en significations « one-sided ».

**§ 4.2, p. 5**, usage bilatéral :

- prendre la plus grande des deux statistiques ;
- « the true significance level would be twice 0.05 or 0.10 » ;
- on prend donc le point à 0,025 pour un niveau de 0,05.

**Note de la table 1, p. 4** : « Values of T for n < 25 are based on those given in Reference [8] », c'est-à-dire Grubbs (1950).

**Affirmation du dépôt.** La normalité est une hypothèse déterminante (`doc_tests_usp.tex:11336-11337`, `:15124-15126`). Conforme [V] (§ 3.2).

### 5.3 Ligne M4 de Fi [X] (concordance)

Depuis Fi (MinP4, décision Q-D2-Fi-2), la ligne M4 « Cellule aberrante » ne calcule plus G : `R/engine.R:10620-10642`, `fonction = "mw_test_cellule_aberrante"`.

La fiche `mw:m4gr` (`doc_tests_usp.tex:15120-15157`) cite encore Grubbs (1950, 1969) et décrit G. Cela relève du passage de fin de branche de `docwriter` (spéc. § 4.5) : « Corrections à apporter », point 2. `test_grubbs()` reste citée par la fiche lognormale `fiche:grubbs`, inchangée.

---

## 6. Autres références des fiches M1 à M4 et de `sec:calib-mc-mw`

### 6.1 Mack (1993) [V]

**Notice [V]** (Crossref ; texte casact.org) : T. Mack, « Distribution-free Calculation of the Standard Error of Chain Ladder Reserve Estimates », *ASTIN Bulletin*, 23(2), novembre 1993, p. 213-225, DOI 10.2143/AST.23.2.2005092.

| Affirmation | Lieu | Texte | Statut |
|---|---|---|---|
| Section 2, hyp. (1), p. 214 | `R/engine.R:10337`, `:10352` ; `doc_tests_usp.tex:13378-13379`, `:13488-13489` | § 2 « Notations and basic results », p. 214 : « The basic chain ladder assumption is that there are development factors f_1, …, f_{I−1} > 0 with (1) E(C_{i,k+1} \| C_{i1}, …, C_{ik}) = C_{ik} f_k » | [V] |
| Section 3, hyp. (3), p. 217 | mêmes lieux | § 3, p. 217 : « (3) Var(C_{i,k+1} \| C_{i1}, …, C_{ik}) = C_{ik} σ²_k », « This is the variance assumption which is implicitly underlying the chain ladder method » | [V] |
| σ̂²_j défini section 3, p. 217 | `doc_tests_usp.tex:14411-14412` (`mw:m2var`) | p. 217 : estimateur « unbiased » de σ²_k pour 1 ≤ k ≤ I − 2, et extrapolation de σ̂²_{I−1} sur la même page | [V] |
| p. 213-225 | `doc_tests_usp.tex:17172` | PDF de 14 pages, p. 213 à 225 | [V] |

L'hypothèse (2), indépendance des années d'accident, figure à la p. 215.

### 6.2 Mack (1994, *CAS Forum*) [V]

**Notice [V]** (PDF casact.org ; pagination imprimée vérifiée page à page) : T. Mack, « Measuring the Variability of Chain Ladder Reserve Estimates », *Casualty Actuarial Society Forum*, printemps 1994, vol. 1, p. 101-182.

| Affirmation | Lieu | Texte (page) | Statut |
|---|---|---|---|
| chap. 3, p. 111 : facteur chain-ladder, moyenne des facteurs individuels pondérée par C(i,j), chacun sans biais | `doc_tests_usp.tex:14221-14223` (`mw:m1d`) ; `R/engine.R:10415` | p. 111 : « is a weighted average of the observed individual development factors […] where the weights are proportional to C_jk. Like f_k every individual development factor […] is also an unbiased estimator of f_k » | [V] |
| chap. 5, p. 121-123 : régression pondérée sans constante, de poids 1/C(i,j), dont l'estimateur est le facteur chain-ladder | `doc_tests_usp.tex:13490-13491` (`mw:m1a`) ; `R/engine.R:10352` | p. 121 : modèle Y_i = c + x_i b + ε_i, « In our special case, we have c = 0, b = f_k » ; p. 123 : poids proportionnels à 1/C_ik, et f_k1 = Σ C_{i,k+1} / Σ C_ik « is identical to the usual chain ladder age-to-age factor » | [V] |
| chap. 5, p. 122-124 : f_k0 pondéré par C², f_k2 moyenne simple | `doc_tests_usp.tex:14223-14224` | p. 122, éq. (12) : « f_k0 is the C_ik²-weighted average » ; p. 124, éq. (13) : « f_k2 […] which is the ordinary unweighted average » | [V] |
| chap. 5, p. 121-125 (graphiques de contrôle) | `doc_tests_usp.tex:17193` | p. 124-125 : graphiques des résidus pondérés (« Plot 0 », « Plot 1 », « Plot 2 », p. 125) ; le chap. 6 commence p. 125 | [V] |
| Données RAA, I = 10, p. 125-126 | `doc_tests_usp.tex:14689-14690` | p. 125-126 : « 'Historical Loss Development Study', 1991 Edition […] (RAA) », triangle 1981-1990 | [V] |
| Annexe G, p. 155-161, T pondérée par I − k − 1, (G4)-(G6) | `doc_tests_usp.tex:14947-14948` ; `R/engine.R:10577` | p. 155 : début de l'annexe G ; p. 157, (G4) : T_k de Spearman ; p. 158, (G5) : T = Σ (I − k − 1) T_k / Σ (I − k − 1), et (G6) : Var(T) ; l'annexe H commence p. 162 | [V] |
| Annexe H, p. 162-168 | `doc_tests_usp.tex:14548-14549`, `:17183-17184` ; `R/engine.R:10511` | p. 162 : « Appendix H: Testing for Calendar Year Effects » ; les figures commencent p. 169 | [V] |
| Élément égal à la médiane éliminé (p. 163) | `doc_tests_usp.tex:14557-14558` | p. 163 : « If the number I-k of elements of F_k is odd there is one element of F_k which is equal to the median and therefore assigned to neither of the sets […] this element is eliminated » | [V] |
| Z_k = min(L_k, S_k), L_k binomiale de paramètre 1/2 (p. 164) ; « alternative unilatérale » (p. 164) | `doc_tests_usp.tex:14559-14560`, `:14668` | p. 164 : « Z_j = min(L_j, S_j) » ; « if Z_j […] is significantly smaller than (L_j+S_j)/2, then there is some reason for a specific calendar year influence » ; loi binomiale, n = 5, p = 0,5 | [V] |
| (H1) et (H2), p. 165 | `doc_tests_usp.tex:14560`, `:14688` | p. 165 : (H1) E(Z_j) = n/2 − C(n−1, m) n/2ⁿ ; (H2) Var(Z_j) = n(n−1)/4 − C(n−1, m) n(n−1)/2ⁿ + E(Z_j) − (E(Z_j))², avec m = [(n−1)/2], soit les formules de la fiche | [V], lu en rendu graphique |
| Diagonales à L_k + S_k ≤ 1 écartées (p. 165) ; « accumulation of the error probabilities » (p. 165) | `doc_tests_usp.tex:14563`, `:14605` | p. 165 : « we have to leave out any other Z_j if L_j+S_j ≤ 1 » ; « in order to avoid an accumulation of the error probabilities » | [V] |
| Règle bilatérale E(Z) ± 2√Var(Z) (p. 166) | `doc_tests_usp.tex:14575`, `:17186` | p. 166 : « we reject […] only if not E(Z) − 2·√Var(Z) ≤ Z ≤ E(Z) + 2·√Var(Z) » | [V] |
| Exemple publié : Z = 14, E[Z] = 12,875, Var[Z] arrondie à 3,9785, huit diagonales (p. 166-167) | `doc_tests_usp.tex:14690-14693` | p. 167 : table pour j = 2 à 9, « Total 14 12.875 3.9785 = (1.9946)² » | [V] |

### 6.3 Mack (1997, *Claims Reserving Manual*) [P]

**Notice [P]** : T. Mack, « Measuring the variability of chain ladder reserve estimates », *Claims Reserving Manual*, vol. 2, section D6, Faculty and Institute of Actuaries, septembre 1997. Elle est attestée par l'URL de l'IFoA, `actuaries.org.uk/system/files/documents/pdf/crm2-D6.pdf`, qui répondait le 22/10/2026 par une page de maintenance ; la Wayback Machine est bloquée par le proxy de la session.

**Contenu non lu dans cette session.** La note liminaire (p. D6.1), l'annexe G (p. D6.42-D6.46), l'annexe H révisée (p. D6.47-D6.51) et le repère de la p. D6.49 restent dans l'état que le `.tex` déclare lui-même (`doc_tests_usp.tex:17205-17208`) : lecture consignée à #201, table de la p. D6.49 vérifiée sur une transcription. **À reprendre** quand le site de l'IFoA répondra ; l'URL est ci-dessus.

### 6.4 Merz et Wüthrich (2008) [V] (notice)

M. Merz, M. V. Wüthrich, « Modelling The Claims Development Result For Solvency Purposes », *Casualty Actuarial Society E-Forum*, automne 2008, p. 542-568. Texte casact.org (27 p.), dont les pieds de page imprimés vont de 542 à 568.

L'en-tête courant écrit « Modeling », le titre « Modelling ». La notice du `.tex` (`doc_tests_usp.tex:17223-17225`) suit le titre ; elle est conforme.

### 6.5 Fisher, *Statistical Methods for Research Workers*, 4ᵉ éd. (1932), § 21.1 [P]

**Cité à** `doc_tests_usp.tex:13492-13493` (`mw:m1a`), pour la combinaison des p-values.

**Contrôlé [V] :**

- **12ᵉ éd.** (Oliver and Boyd, 1954), § 21.1, p. 99-100. Titre : « 21·1. The Combination of Probabilities from Tests of Significance ». Énoncé : « If therefore we take the natural logarithm of a probability, change its sign and double it, we have the equivalent value of χ² for 2 degrees of freedom. Any number of such values may be added together ».
- La liste des éditions de cet exemplaire date la **4ᵉ édition de 1932**.
- **2ᵉ éd.** (1928) : le § 21, « Tests of Independence, Contingency Tables », ne contient pas cette sous-section. Elle est donc postérieure à 1928.

**Non lu.** La 4ᵉ éd. (1932) est en prêt contrôlé sur archive.org, et la 3ᵉ éd. (1930) aussi. L'attribution à la 4ᵉ éd. reste [P]. Elle est cohérente avec ce qui précède, mais la 3ᵉ éd. n'est pas exclue sur pièce.

### 6.6 Notices seules [V]

Fi ne leur attribue que leur notice ou un renvoi général. Vérification par Crossref, OpenAlex ou les métadonnées JSTOR :

- C. Spearman, « The Proof and Measurement of Association between Two Things », *American Journal of Psychology*, 15(1), 1904, p. 72-101, DOI 10.2307/1412159. Les pages viennent des métadonnées JSTOR (archive.org `jstor-1412159`).
- J. B. Ramsey, « Tests for Specification Errors in Classical Linear Least-Squares Regression Analysis », *JRSS B*, 31(2), 1969, p. 350-371, DOI 10.1111/j.2517-6161.1969.tb00796.x. M1 le cite « dans l'esprit de » (`R/engine.R:10395`), formule qui n'engage aucun énoncé.
- W. H. Kruskal, W. A. Wallis, « Use of Ranks in One-Criterion Variance Analysis », *JASA*, 47(260), 1952, p. 583-621, DOI 10.1080/01621459.1952.10483441.
- J. Durbin, G. S. Watson, « Testing for Serial Correlation in Least Squares Regression. I », *Biometrika*, 37(3-4), 1950, p. 409-428, DOI 10.1093/biomet/37.3-4.409 ; « … II », *Biometrika*, 38(1-2), 1951, p. 159-178, DOI 10.1093/biomet/38.1-2.159.
- A. Wald, J. Wolfowitz, « On a Test Whether Two Samples are from the Same Population », *Ann. Math. Stat.*, 11(2), 1940, p. 147-162, DOI 10.1214/aoms/1177731909.
- Q. McNemar, « Note on the Sampling Error of the Difference Between Correlated Proportions or Percentages », *Psychometrika*, 12(2), 1947, p. 153-157, DOI 10.1007/BF02295996.
- C. J. Clopper, E. S. Pearson, « The Use of Confidence or Fiducial Limits Illustrated in the Case of the Binomial », *Biometrika*, 26(4), 1934, p. 404-413, DOI 10.1093/biomet/26.4.404.

### 6.7 `sec:calib-mc-mw` : Dwass (1957), Hope (1968), Holm (1979)

**Dwass (1957) [V].**

- Notice (Crossref ; texte archive.org) : M. Dwass, « Modified Randomization Tests for Nonparametric Hypotheses », *Ann. Math. Stat.*, 28(1), 1957, p. 181-187, DOI 10.1214/aoms/1177707045.
- p. 182 : l'auteur propose d'examiner « a "random sample" of permutations » ; ses bornes portent sur des tests « which in both original and modified form have size α ».
- **Nuance.** Dwass traite des tests de **permutation** (randomisation), à échantillon aléatoire de permutations. L'usage du `.tex` (`doc_tests_usp.tex:16323-16325`) est exact : l'exactitude à B fini « suppose des répliques tirées dans la loi nulle vraie ». Le transfert à un bootstrap paramétrique sous un modèle ajusté n'est pas couvert par Dwass, et le `.tex` le dit déjà.

**Hope (1968) [P].** Notice (Crossref) : A. C. A. Hope, « A Simplified Monte Carlo Significance Test Procedure », *JRSS B*, 30(3), 1968, p. 582-598, DOI 10.1111/j.2517-6161.1968.tb00759.x. Texte non lu (Wiley).

**Holm (1979) [P].**

- Notice (OpenAlex ; métadonnées JSTOR 4615733) : S. Holm, « A Simple Sequentially Rejective Multiple Test Procedure », *Scandinavian Journal of Statistics*, 6(2), 1979, p. 65-70.
- Texte non lu : JSTOR, et la copie `ime.usp.br` répond 503. La « Portée » de `doc_tests_usp.tex:16818-16820`, contrôle au sens fort sans hypothèse sur la dépendance, est la propriété classique de la procédure, non relue sur le texte.
- La « procédure de Holm sur les p_ij », envisagée hors de Fi par la spéc. l. 348, reste à sourcer sur le texte si elle est un jour proposée.

---

## Corrections à apporter

Les points 1, 2 et 4 relèvent du passage de fin de branche de `docwriter` (règle 9). Le point 3 touche le moteur et revient à `coder`, si la session principale le retient. Les points 5 et 6 sont des mises à jour de statut ou des précisions.

1. **[X] Fiche `mw:m4ros` (`doc_tests_usp.tex:15161-15190`).** La fiche est en désaccord avec Rosner (1983) et avec la `PHRASE_MW_ROSNER_DIAGNOSTIC` du moteur (`R/engine.R:10260-10267`). Ce sont les écarts de #347, à reprendre avec la réécriture en fiche de diagnostic (spéc. Q-D1-Fi-7 et § 4.5).
   - l. 15173, « Valeurs critiques λ_i tabulées » : les λ_i sont calculées en forme close par l'éq. (2.5), p. 166, et la table 3 est elle-même calculée par (2.5), p. 167. À remplacer par « valeurs critiques de l'éq. (2.5), approximation de Student-Bonferroni » (écart 2).
   - l. 15167-15168, « On teste séquentiellement les alternatives » : Rosner calcule tous les R_i et retient l = max{i : R_i > λ_i}. Voir l'éq. (1.2), p. 165, reprise par l'éq. (1.3), p. 166, et l'exemple de la p. 171 (écart 3).
   - l. 15178, « Résout le problème de masquage de Grubbs » : l'avantage revendiqué est le contrôle du niveau sous H_l (p. 171 et résumé p. 165) ; le masquage n'apparaît que dans l'exemple de la p. 171 (écart 6).
   - l. 15179-15183, « La littérature recommande n ≥ 25 […] ce qui place la procédure à la limite de son domaine » : le domaine n ≥ 25 (p. 165, 167 et 171) vaut pour un échantillon i.i.d. normal, et l'article ne traite pas de résidus. À aligner sur la phrase fixe du moteur (écart 1).
   - l. 15165, « k = ⌊n/4⌋ » : le code donne max(1, ⌊n/4⌋) (écart 7, concordance).
2. **[X] Fiche `mw:m4gr` (`doc_tests_usp.tex:15120-15157`).** Elle cite Grubbs (1950, 1969) et décrit G, alors que la ligne calcule M = min p_ij (MinP4) depuis Fi. La rubrique `\refl` est à remplacer :
   - Cook et Weisberg (1982), § 2.2.1, p. 20, éq. (2.2.9), pour t_i et sa loi t(n − p′ − 1) ;
   - p. 21, éq. (2.2.15), pour l'équivalence au test du décalage de moyenne ;
   - p. 22 et 26, pour la borne de Bonferroni ;
   - annexe A.1, p. 209, pour la pondération ;
   - Belsley, Kuh et Welsch (1980), chap. 2, pour le nom RSTUDENT, d'après Atkinson (1983, p. 24), ouvrage non relu.
3. **Précision (moteur, `R/engine.R:10621-10625`).** La `reference` de M4 dit « minimum des p de Student, borne de Bonferroni : construction de l'outil ». Or la borne de Bonferroni sur max |t_i| est publiée (Cook et Weisberg 1982, p. 22 et 26). Ce qui est propre à l'outil : le minimum des p à degrés de liberté variables d'une colonne à l'autre, la restriction aux colonnes n_j ≥ 4 et la p de Monte-Carlo. Formulation possible :

   > « borne de Bonferroni de Cook & Weisberg (1982, p. 22) ; minimum des p de Student entre colonnes : construction de l'outil »

   Le texte du moteur reste sans accents et sans nombre issu du bootstrap. **Changement non numérique** : à juger par la session principale. S'il est fait, il passe par le patch chirurgical de la référence `reserve2.rds` (`tests/patcher_reference.R`), et non par une régénération.
4. **Bibliographie `sec:biblio`.**
   - **Ajouter** la notice de Cook et Weisberg (1982), absente du document (aucune occurrence de « Weisberg » dans le `.tex`) : R. D. Cook, S. Weisberg, *Residuals and Influence in Regression*, Chapman and Hall, New York et Londres, 1982, x + 230 p., accès libre à l'University Digital Conservancy de l'université du Minnesota (hdl 11299/37076). Portée : § 2.2.1-2.2.2, p. 20-26, et annexe A.1, p. 209.
   - **Compléter** la notice de Belsley, Kuh et Welsch (`doc_tests_usp.tex:16921-16926`, « Ouvrage non relu », à garder) par l'attribution du nom RSTUDENT (chap. 2), attestée par Atkinson (1983, *Technometrics* 25(1), p. 24).
5. **Spécification (`docs/specifications/fi-merz-wuthrich-puissance.md`), mises à jour de statut.** Ce fichier est historique ; ces points peuvent être reportés dans la PR plutôt que dans le fichier.
   - l. 21, 75, 320 et 481 : la loi de Student de t(i,j) est **[V]** (Cook et Weisberg 1982, p. 20) ; Belsley, Kuh et Welsch reste **[P]**.
   - l. 22, 335 et 481 : les pages de Rosner (1983) sont **[V]** sur le texte intégral (#347, commentaire `6290307185`).
   - l. 233 : la forme N R² de Koenker reste **[P]** (texte non accessible).
6. **Précision facultative (spéc. l. 236-239), Harvey (1976).** D'après son résumé, l'article propose un test du **rapport de vraisemblance**. La régression de log r² est une construction inspirée de sa procédure d'estimation. Si la variante est un jour reprise, l'écrire « régression auxiliaire de log r² inspirée de Harvey (1976) », et non « test de Harvey ».

**Aucune affirmation du moteur n'est fausse** au regard des textes lus : les points 1 et 2 portent sur le `.tex`, et le point 3 est une précision.

Restent **[P]**, faute d'accès au texte :

- Koenker (1981) ;
- Belsley, Kuh et Welsch (1980) ;
- Harvey (1976) et Breusch et Pagan (1979), au-delà de leur résumé ;
- Mack (1997, *CRM*) ;
- Fisher, 4ᵉ éd. (1932) ;
- Hope (1968) ;
- Holm (1979).

*Aucune page, équation ni citation n'a été ajoutée hors des textes lus. Les attestations secondaires sont signalées comme telles.*
