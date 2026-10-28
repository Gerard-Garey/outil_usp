# Vérification des références externes de la branche Fl (Mack 1997, Kruskal et Wallis 1952, Venter 1998)

> *Rédigé par Claude (session de relevé groupé des sources, à accès internet par le proxy de la session), le 25/10/2026. Commande de la session principale de Fk, sur ordre du mainteneur du 25/10/2026 (décision Q-41-7 ; brief du commentaire `6388285797` de la PR #374). Relevé versé sur la branche `claude/lecture-conjointe-familles` (PR brouillon #374), à reprendre par la branche Fl.* Forme reprise de `docs/references/verifications-fj.md`.

## Objet

- **Mack (1997)**, *Claims Reserving Manual*, vol. 2, section D6, p. D6.15-D6.23 : résidus de Mack, graphiques de résidus, tendances calendaires (repère par diagonale), normalité (§ 1) ;
- **Kruskal et Wallis (1952)**, *JASA* 47(260), p. 583-621 : statistique H, loi exacte et approximation χ², correction des ex æquo (§ 2) ;
- **Venter (1998)**, « Testing the Assumptions of Age-to-Age Factors », *PCAS* 85 : tests des hypothèses de chain-ladder cités par la revue de pertinence (§ 3).

**Résultat** : Venter (1998) lu sur le texte intégral ; Mack (1997) et Kruskal et Wallis (1952) **non lus** (site de l'IFoA en maintenance ; JSTOR et Taylor & Francis refusés). Pour Mack, le passage correspondant de la version de 1994 (*CAS Forum*) est relevé en complément, signalé comme tel (§ 1.3).

Les numéros de ligne citent la tête `269883a` de la branche `claude/lecture-conjointe-familles`.

## Méthode et statuts

Statuts de `verifications-fj.md` : **[V]** vérifié sur le texte ; **[P]** vérification partielle (raison donnée) ; **[X]** affirmation fausse, non trouvée, ou écart ; **[NV]** non vérifié (raison donnée).

- **Formules** : lues en rendu graphique (pages du PDF converties en image à 100 dpi par `pdftoppm`), jamais sur l'extraction de texte.
- **Prose** : extraction de texte (`pdftotext`), contrôlée sur le rendu graphique des pages citées.
- **Aucun fichier source n'a été déposé dans le dépôt.**

## Sources consultées (25/10/2026)

| Source | Accès | Contenu lu |
|---|---|---|
| Mack (1997) : `https://www.actuaries.org.uk/system/files/documents/pdf/crm2-D6.pdf` | **refusé** : HTTP 503, page « Site Maintenance » de l'IFoA (« We're performing maintenance currently »), six essais entre le début et la fin de la session | — |
| Mack (1997), Wayback Machine (`archive.org/wayback/available`, `web.archive.org/web/2019id_/…`) | **refusé** : HTTP 429 (« Too Many Requests »), puis connexion coupée par le tunnel du proxy | — |
| Mack (1994), *CAS Forum*, printemps 1994, p. 101-182 : `https://www.casact.org/sites/default/files/database/forum_94spforum_94spf101.pdf` (2 466 476 octets, SHA-256 `f20a3d7ff26247fb26839073418b918b9823e6908829f9ae8f889f636e1a9da5`, identique au fichier du commentaire `6238477255` de la PR #332) | libre | p. 124-125 en rendu graphique ; p. 121-126 en extraction de texte |
| Kruskal et Wallis (1952) : `https://www.jstor.org/stable/pdf/2280779.pdf` ; `https://www.tandfonline.com/doi/pdf/10.1080/01621459.1952.10483441` | **refusés** : JSTOR renvoie une page anti-robot ; Taylor & Francis, HTTP 403 | — |
| Kruskal et Wallis (1952), autres copies | non utilisées : seules des copies tierces (support de cours, cache Zotero) ont été trouvées par recherche web ; conformément à la pratique des relevés précédents, aucune copie tierce n'a été utilisée | — |
| Venter (1998) : `https://www.casact.org/sites/default/files/database/proceed_proceed98_980807.pdf` (41 p., 251 343 octets, SHA-256 `58523222aa33f1b8c82455818e8c2da1b8f24aee7d83badf8c88d2f71a638dcb`) | libre (HTTP 200) | texte intégral, p. 807-847 ; p. 808, 809, 812, 813, 833 et 834 en rendu graphique |
| Venter (1998), notice : `https://www.casact.org/abstract/testing-assumptions-age-age-factors` | libre | auteur, titre, *Proceedings of the CAS* vol. LXXXV, 1998, p. 807-847, prix Dorweiler |

---

## Tableau récapitulatif

| # | Référence | Affirmation | Lieu dans le dépôt | Page, section | Statut |
|---|---|---|---|---|---|
| 1a | Mack (1997) | p. D6.15-D6.23 : résidus, graphiques, tendances calendaires, normalité | `doc_tests_usp.tex:15877-15879`, `:16077-16078`, `:16394-16395` | — | [NV] |
| 1b | Mack (1997) | Repère de 10 % par diagonale, p. D6.49 | `doc_tests_usp.tex:1237`, `:2602`, `:6351`, `:14178`, `:15862-15863`, `:16112-16113` ; `R/engine.R:8933` | — | [NV] (état antérieur inchangé, `verifications-fi.md` § 6.3) |
| 1c | Mack (1994), en complément | Résidus pondérés (C_{i,k+1} − C_ik f_k)/√C_ik tracés contre C_ik ; trois graphiques comparés | `doc_tests_usp.tex:13471-13475` (`sec:graph-mw`) | p. 124-125 | [V] |
| 1d | Mack (1994), en complément | Graphiques « for every development year k for which we have sufficient data points, say at least 6, i.e. for k ≤ I−6 » | non repris par le `.tex` | p. 125 | [V] ; observation, § 1.3 |
| 2a | Kruskal et Wallis (1952) | Notice | `doc_tests_usp.tex:16214-16216` | — | [P] (notice par sources secondaires) |
| 2b | Kruskal et Wallis (1952) | H, loi exacte, χ²(k−1), ex æquo | `doc_tests_usp.tex:6747-6748`, `:16228-16245` ; `R/engine.R:10192` | — | [NV] |
| 3a | Venter (1998) | Notice *PCAS* LXXXV, 1998, p. 807-847 | `bloc-5.md:121`, `:131` | p. 807 ; notice CAS | [V] |
| 3b | Venter (1998) | « et *CAS Forum* 1998 » | `bloc-5.md:121`, `:131` | — | [NV] |
| 3c | Venter (1998) | Tests colonne par colonne de M1 : constante | `bloc-5.md:62`, `:98` | p. 812, implication 2(a) ; p. 815-816 | [V] |
| 3d | Venter (1998) | Stabilité des facteurs selon l'année de survenance | `bloc-5.md:98` | p. 813, implication 4 ; p. 830-832, fig. 4 | [V], avec une nuance (§ 3.3) |
| 3e | Venter (1998) | « texte intégral inaccessible » ; contenu « par sources secondaires seulement » | `bloc-5.md:131`, `:142`, `:145` | — | **dépassé** (lu le 25/10/2026) |

---

## 1. Mack (1997), p. D6.15-D6.23

### 1.1 Texte [NV]

Le site de l'IFoA répond par une page de maintenance (HTTP 503) pendant toute la session ; la Wayback Machine est inaccessible (429, puis tunnel coupé). Le PDF obtenu le 17/10/2026 (SHA-256 `4d8efee2ecf73dc011720e7d8802e722920db2e41264092f4cb5cf856e095e18`, commentaire `6238477255` de la PR #332) n'est ni déposé ni accessible à cette session.

**Aucun énoncé des p. D6.15-D6.23 n'est donc relevé** : ni sur les résidus, ni sur les graphiques, ni sur les tendances calendaires, ni sur la normalité. Les phrases datées du `.tex` restent exactes et nécessaires :

- `doc_tests_usp.tex:15877-15879` : « le corps du texte (p. D6.15--D6.23) ne motive pas autrement le changement (affirmation non relue sur le texte intégral au 18 octobre 2026 […]) » ;
- `doc_tests_usp.tex:16077-16078` et `:16394-16395` : « Mack (1997), p. D6.15--D6.23, non relues sur le texte intégral au 23 octobre 2026 ».

La condition Q-40-5 (feuille de route) n'est **pas levée** par ce relevé.

### 1.2 Annexe H révisée et repère de 10 % [NV]

Non relus (même cause). L'état reste celui de `verifications-fi.md` § 6.3 et du `.tex` (table de la p. D6.49 vérifiée sur une transcription, #333). `REPERE_DIAGONALE_MACK_1997 <- 0.10` (`R/engine.R:8933`) n'est ni confirmé ni infirmé ici.

### 1.3 Complément : Mack (1994, *CAS Forum*), p. 124-125 [V]

**Ce n'est pas le texte de 1997.** La version du *Claims Reserving Manual* est une réimpression revue de l'article de 1994 (note liminaire de la p. D6.1, citée par le `.tex`, l. 15861) ; la correspondance des pages D6.15-D6.23 avec les pages du *Forum* n'a pas pu être établie. Ce complément ne lève donc aucune phrase datée sur 1997.

Lu en rendu graphique, p. 124 :

> « This check is usually done by carefully inspecting plots of the data and of the residuals: First, we plot C_{i,k+1} against C_ik, i = 1, …, I−k, in order to see if we really have an approximately linear relationship around a straight line through the origin with slope f_k = f_k1. Second, if linearity seems acceptable, we plot the weighted residuals (C_{i,k+1} − C_ik f_k)/√C_ik, 1 ≤ i ≤ I−k, (whose squares have been minimized) against C_ik in order to see if the employed variance assumption really leads to a plot in which the residuals do not show any specific trend but appear purely random. »

P. 125 :

> « It is recommended to compare all three residual plots (for i = 1, …, I−k) Plot 0: C_{i,k+1} − C_ik f_k0 against C_ik, Plot 1: (C_{i,k+1} − C_ik f_k1)/√C_ik against C_ik, Plot 2: (C_{i,k+1} − C_ik f_k2)/C_ik against C_ik […]. All this should be done for every development year k for which we have sufficient data points, say at least 6, i.e. for k ≤ I−6. »

**Confrontation au dépôt.**

- `doc_tests_usp.tex:13471-13475` (fiche `sec:graph-mw`, renvoi au chap. 5, p. 121-125 : linéarité et variance contrôlées par les nuages C(i,j+1) contre C(i,j) et par les résidus pondérés ; comparaison des estimateurs pondérés par C², C et non pondéré) : **conforme [V]**.
- **Observation, sans [X]** : la recommandation « say at least 6, i.e. for k ≤ I−6 » n'est pas reprise par la fiche. Sur un triangle 8 × 8 (I = 8 dans la notation de Mack, années 1 à 8), elle ne retient que k ≤ 2, soit les deux premières colonnes de facteurs. Fl pourrait la citer pour borner la lecture des graphiques de résidus par colonne à T = 8.
- **Tendances calendaires et normalité** : le passage lu (p. 121-126) n'en traite pas. L'annexe H de 1994 (p. 162-168) est déjà relevée par le `.tex` (fiche `mw:m3cal`) et n'est pas reprise ici.

## 2. Kruskal et Wallis (1952)

### 2.1 Notice [P]

> W. H. Kruskal et W. A. Wallis, « Use of ranks in one-criterion variance analysis », *Journal of the American Statistical Association*, vol. 47, n° 260, décembre 1952, p. 583-621, DOI 10.2307/2280779 (JSTOR, stable 2280779).

Attestée par des sources secondaires (résultats de recherche web du 25/10/2026 : notice JSTOR, manuel Stata `kwallis`, documentation R `SuppDists::KruskalWallis`). Concorde avec `doc_tests_usp.tex:16214-16216` (titre, revue, 47(260), 1952, p. 583-621). La documentation `SuppDists` signale des **errata** parus en 1953 (Kruskal et Wallis, *JASA* 48) ; le `.tex` ne les cite pas. Ni l'article ni les errata n'ont été vus.

### 2.2 Texte [NV]

JSTOR renvoie une page anti-robot ; Taylor & Francis refuse l'accès (HTTP 403). Aucune copie légitime en libre accès trouvée ; les copies tierces repérées n'ont pas été utilisées.

**Rien n'est relevé** sur la statistique H, la loi exacte, l'approximation χ²(k−1) ni la correction des ex æquo. En particulier :

- la phrase « Kruskal et Wallis, 1952, non relu sur le texte intégral au 24 octobre 2026 » (`doc_tests_usp.tex:6748`) reste exacte ; à mettre à jour, le cas échéant, à la date du 25 octobre 2026 ;
- la loi de référence « de Kruskal et Wallis, sans ex æquo » et la forme close p_min = k! Π n_i!/N! (`doc_tests_usp.tex:16243-16250` ; `.mw_kruskal_p_min()`, `R/engine.R:10192`) sont **démontrées dans le `.tex`**, sans dépendre d'un énoncé de l'article : le relevé n'y change rien ;
- la correction des ex æquo de `stats::kruskal.test()` (`R/engine.R:10072`) n'est pas confrontée à l'article.

## 3. Venter (1998) [V]

### 3.1 Notice [V]

> G. G. Venter, « Testing the Assumptions of Age-to-Age Factors », *Proceedings of the Casualty Actuarial Society*, vol. LXXXV, 1998, p. 807-847 (prix Dorweiler).

Notice CAS ; pages imprimées du PDF de 807 à 847. Concorde avec `bloc-5.md:121` et `:131` (« PCAS LXXXV 807-847 »). La mention « et *CAS Forum* 1998 » (`bloc-5.md:121`, `:131`) n'est **pas vérifiée** : la page de la CAS n'en parle pas [NV].

### 3.2 Cadre et six implications testables (p. 808-813)

Notation, p. 808 (rendu graphique) : c(w, d) cumul de l'année de survenance w à l'âge d ; q(w, d) incrément de d − 1 à d ; f(d) facteur appliqué à c(w, d) pour estimer q(w, d + 1). Les hypothèses de Mack sont reformulées sur les **incréments** (p. 809) :

1. « E[q(w, d + 1) | data to w + d] = f(d)c(w, d) » ; « this formula is a linear relationship with no constant term » ;
2. « Unless v = w, c(w, d) and c(v, g) are independent for all v, w, d and g » ;
3. « Var[q(w, d + 1) | data to w + d] = a[d, c(w, d)] ».

Implications testables, p. 812-813 (rendu graphique) :

> « 1. Significance of factor f(d). 2. Superiority of factor assumption to alternative emergence patterns such as: (a) linear with constant: E[q(w, d + 1) | data to w + d] = f(d)c(w, d) + g(d); (b) factor times parameter: […] = f(d)h(w); (c) including calendar year effect: […] = f(d)h(w)g(w + d). […] 3. Linearity of model: look at residuals as a function of c(w, d). 4. Stability of factor: look at residuals as a function of time. 5. No correlation among columns. 6. No particularly high or low diagonals. »

« The first four of these implications are tests of assumption (1). Standard diagnostic tests for weighted least-squares regression can be used as measures. » (p. 813)

### 3.3 Confrontation aux points d'ancrage

**Constante colonne par colonne (`bloc-5.md:62`, `:98`) [V].** Implication 2(a), p. 812 : modèle avec constante g(d) **par âge d**. P. 815-816 : « The first alternative mentioned is just to add a constant term to the model. This is often significant in the age 0 to age 1 stage […] If the constant is statistically significant, this emergence pattern is more strongly supported than that underlying the chain ladder. » Nuances, sans [X] :

- le critère de signification que Venter emploie pour les paramètres est un ratio au moins égal à 2 (ou 1,65) entre le paramètre et son écart type ; « The requirement that the factor be twice the standard deviation is not a strict statistical test, but more like a level of comfort » (p. 813) ;
- la comparaison des modèles se fait par la somme des carrés des résidus divisée par (n − p)², ou par AIC ou BIC (p. 814-815) : ce n'est pas un test à loi de référence. La p Monte-Carlo de la ligne de l'outil est donc une construction de l'outil, que Venter ne fonde pas.

**Stabilité des facteurs selon l'année de survenance (`bloc-5.md:98`) [V], avec une nuance.** Implication 4, p. 830 : « If a similar pattern of sequences of high and low residuals is found when plotted against time, instability of the factors may be indicated. » La fig. 4 (p. 831) trace le facteur de développement 2 → 3 **par année de survenance** avec sa moyenne mobile sur cinq termes. La « stabilité selon l'année de survenance » est donc bien chez Venter. Mais l'examen y est **graphique** (suites de résidus de même signe, moyenne mobile) ; Venter ne propose pas de statistique de test pour cette implication et renvoie aux modèles espace-état de Verrall et Zehnwirth pour un traitement formel, « beyond the scope of this paper » (p. 832).

**« Référence canonique » (`bloc-5.md:98`)** : jugement de la revue, non vérifiable sur pièce ; l'article présente ses tests comme dérivés pour la plupart de diagnostics de régression (résumé, p. 807).

**Autres implications, pour mémoire (aucun point d'ancrage dans le `.tex`)** :

- **Implication 3, linéarité** (p. 829-830) : suites de résidus positifs et négatifs contre c(w, d), « This can be tested for each age » ; examen graphique.
- **Implication 5, corrélation** (p. 833-834, rendu graphique) : corrélation de Pearson pour **toutes les paires** de colonnes, sur les n premiers éléments communs ; « T = r[(n − 2)/(1 − r²)]^{1/2} » comparé à la loi de Student à n − 2 degrés de liberté (renvoi à Miller et Wichern, p. 214) ; puis nombre de corrélations significatives à 10 % traité comme binomial (m, 0,1), « more than 0.1m + m^{1/2} significant correlations […] would strongly suggest there is actual correlation ». C'est distinct de la statistique de Mack (Spearman, colonnes adjacentes) suivie par l'outil (fiche `mw:m3cor`).
- **Implication 6, diagonales** (p. 834-835) : rappel du test haut-bas de Mack ; Venter propose une régression avec indicatrices de diagonale.

Venter cite Mack par la version *CAS Forum* 1994 (« Casualty Actuarial Society Forum 1, Spring 1994, pp. 101–182 », référence [6], p. 839), non par celle de 1997.

### 3.4 Points d'ancrage dépassés

`bloc-5.md:131` (« contenu […] par sources secondaires seulement, texte intégral inaccessible »), `:142` (« Non vérifiés : […] contenu détaillé de Venter 1998 ») et `:145` (« lecture d'une source non accessible (Venter, […]) ») datent de la revue du 15/10/2026 ; le texte est lu ici. Ce n'est pas une erreur de la revue.

---

## Recommandations pour Fl

- **Mack (1997)** : garder les trois phrases datées ; le relevé est à refaire quand le site de l'IFoA répondra (URL ci-dessus), ou sur le PDF du 17/10 fourni par le mainteneur (SHA-256 `4d8efee2…`).
- **Mack (1994), p. 125** : la recommandation « at least 6, i.e. for k ≤ I−6 » peut être citée pour la lecture des graphiques de résidus par colonne à T = 8 (§ 1.3).
- **Kruskal et Wallis (1952)** : garder la phrase datée ; voie d'accès : JSTOR (stable 2280779) ou Taylor & Francis, par accès institutionnel ou achat ; lire aussi les errata de 1953.
- **Venter (1998)** : citable pour les fiches `mw:m1a` et `mw:m1b` (`bloc-5.md:121`) avec la notice du § 3.1 et les pages du § 3.3 (constante : p. 812, 815-816 ; stabilité : p. 813, 830-832) ; **à ne pas lui attribuer** : une statistique de test à loi de référence pour la stabilité, ni la p Monte-Carlo de la ligne de constante.

*Aucune page, équation ni citation n'a été ajoutée hors du texte lu.*

---

# Relevé du 27/10/2026

> *Rédigé par Claude (session de relevé de sources, accès internet par le proxy de la session), le 27/10/2026, sur commande de la session principale de Fn et décision du mainteneur du 27/10/2026 (Q-42-12) ; issue #377. Branche `claude/incertitude-bootstrap-graphiques` (PR brouillon #384). Le relevé du 25/10 ci-dessus est conservé.*

## R27.0 Statuts au 27/10/2026 (ancien → nouveau)

| # | Référence | Affirmation | Statut |
|---|---|---|---|
| 1a | Mack (1997) | p. D6.15-D6.23 | [NV] → [NV] (site de l'IFoA : HTTP 503 le 27/10/2026 à 08:18 UTC) |
| 1b | Mack (1997) | repère de 10 %, p. D6.49 | [NV] → [NV] (même cause) |
| 2a | Kruskal et Wallis (1952) | Notice | [P] → **[V]** (Crossref) |
| 2a′ | Kruskal et Wallis (1953), errata | Notice | nouveau : **[V]** (Crossref) ; contenu [NV] |
| 2b | Kruskal et Wallis (1952) | H, loi exacte, χ²(k − 1), ex æquo | [NV] → [NV] |

## R27.1 Mack (1997) : site toujours indisponible [NV]

Une seule requête, conformément à #377 (« vérifier d'abord le site par une seule requête, et s'arrêter si le code est 503 ou 429 ») :

| Date (UTC) | URL | Réponse |
|---|---|---|
| 27/10/2026 08:18 | `https://www.actuaries.org.uk/system/files/documents/pdf/crm2-D6.pdf` | **HTTP 503**, `text/html`, 1 020 octets (page de maintenance) ; pas de PDF, SHA-256 attendu (`4d8efee2…`) non vérifiable |

Arrêt après cette requête ; Wayback Machine non retentée (HTTP 429 et tunnel coupé le 25/10). Rien de nouveau sur les p. D6.15-D6.23 ni sur la p. D6.49 : les phrases datées du `.tex` (`doc_tests_usp.tex:16088`, `:16287-16288`, `:16610-16611` sur la tête `c564324`) et la condition Q-40-5 restent en l'état. Historique des tentatives : 25/10 (deux fois), 26/10, 27/10, toutes en 503.

## R27.2 Kruskal et Wallis (1952) et errata (1953)

### Notices [V] (Crossref, `https://api.crossref.org/works?query.bibliographic=…`, HTTP 200)

> W. H. Kruskal et W. A. Wallis, « Use of Ranks in One-Criterion Variance Analysis », *Journal of the American Statistical Association*, vol. 47, n° 260, décembre 1952, p. 583-621, DOI 10.1080/01621459.1952.10483441.

> W. H. Kruskal et W. A. Wallis, « Errata: Use of Ranks in One-Criterion Variance Analysis », *Journal of the American Statistical Association*, vol. 48, n° 264, décembre 1953, p. 907, DOI 10.2307/2281082.

La notice de 1952 concorde avec `doc_tests_usp.tex:16426-16429`. Les errata ne sont pas cités par le `.tex` ; Crossref ne donne que la première page (907).

### Texte [NV]

Aucune nouvelle requête vers JSTOR ni Taylor & Francis : les seules voies sont les pages de l'éditeur qui ont refusé l'accès le 25/10 (JSTOR, page anti-robot ; Taylor & Francis, HTTP 403). Les relancer par un navigateur automatisé pour passer outre ce refus reviendrait à contourner une protection anti-robot ; ce n'est pas fait. Aucune version en libre accès des auteurs n'est connue ; aucune copie tierce n'est utilisée. **Rien n'est relevé** sur H, la loi exacte, l'approximation χ² ni la correction des ex æquo. La phrase datée du `.tex` (« Kruskal et Wallis, 1952, non relu sur le texte intégral au 24~octobre 2026 », `doc_tests_usp.tex:6874`) reste exacte.

Voie d'accès : JSTOR (stable 2280779, et 2281082 pour les errata) ou Taylor & Francis, par accès institutionnel ou achat.

*Aucun énoncé de Mack (1997) ni de Kruskal et Wallis (1952) n'est rapporté.*
