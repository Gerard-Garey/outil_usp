# Vérification des références externes de la branche Fk (lecture conjointe, #297)

> *Rédigé par Claude (session de relevé groupé des sources, à accès internet par le proxy de la session), le 25/10/2026. Commande de la session principale de Fk, sur ordre du mainteneur du 25/10/2026 (décision Q-41-7 ; brief du commentaire `6388285797` de la PR #374). Branche `claude/lecture-conjointe-familles` (PR brouillon #374).* Forme reprise de `docs/references/verifications-fj.md`.

## Objet

Westfall et Young (1993), cité par la spécification D1-Fk (`docs/specifications/fk-lecture-conjointe.md`, § 0 « Sources externes », § 4.2 et § 4.5) et par le champ `reference` prévu pour les lignes de famille, pour :

- la p-value ajustée minP (et maxT) par rééchantillonnage, en une étape (single-step) et pas à pas (step-down), minP calculé sur les p de chaque réplication ;
- les conditions de validité (contrôle faible et fort, pivotalité des sous-ensembles) ;
- le traitement des statistiques discrètes et des ex æquo.

**L'ouvrage lui-même n'a pas pu être lu** (§ 2). Le relevé porte, en complément et signalé comme tel, sur **Ge, Dudoit et Speed (2003)**, que le brief désigne pour ce cas (§ 3). Les numéros de page et d'algorithme de Westfall et Young donnés au § 3 sont ceux que **Ge, Dudoit et Speed attribuent** à l'ouvrage : ils ne sont pas lus dans l'ouvrage.

Les numéros de ligne citent la tête `269883a` de la branche.

## Méthode et statuts

Statuts de `verifications-fi.md` et `verifications-fj.md` :

- **[V]** : vérifié sur le texte, avec la page, la section ou l'équation, et la source consultée. Citations en anglais, courtes, entre guillemets.
- **[P]** : vérification partielle (notice vérifiée, ou énoncé attribué par une source secondaire lue sur pièce, sans lecture de la source primaire ; la raison est donnée).
- **[X]** : affirmation fausse ou non trouvée, ou écart entre le dépôt et la source.
- **[NV]** : non vérifié (source non lue ; la raison est donnée).

Lecture du texte :

- **Formules** : lues en rendu graphique (pages du PDF converties en image à 110 dpi par `pdftoppm`), jamais sur l'extraction de texte.
- **Prose** : extraction de texte (`pdftotext`) pour repérer les passages, contrôlée sur le rendu graphique des pages citées.
- **Aucun fichier source n'a été déposé dans le dépôt** (téléchargements dans le répertoire temporaire de la session).

## Sources consultées (25/10/2026)

| Source | Accès | Contenu lu |
|---|---|---|
| Westfall et Young (1993), notice Open Library : `openlibrary.org/api/books?bibkeys=ISBN:0471557617` | libre | notice : titre, sous-titre, auteurs, éditeur (Wiley, New York), 1993, « xvii, 340 p. », ISBN 0-471-55761-7, LCCN 92022194 |
| Westfall et Young (1993), texte | **non obtenu** | aucun accès légitime trouvé (aucune version en libre accès ; ouvrage payant chez l'éditeur) ; aucune copie tierce n'a été cherchée ni utilisée |
| Ge, Dudoit et Speed, *Resampling-based multiple testing for microarray data analysis*, rapport technique n° 633, Department of Statistics, UC Berkeley, janvier 2003 : `https://statistics.berkeley.edu/sites/default/files/tech-reports/633.pdf` (l'adresse `stat.berkeley.edu/…/633.pdf` de `bloc-1.md:109` y redirige ; 41 p., 384 205 octets, SHA-256 `2a3b6553f6d356ddd013cdb1c28f174e99476290415d9169f32a300355b5ada9`) | libre (HTTP 200) | p. 8, 12-15 et 17-19 lues en rendu graphique ; p. 1-2 et 16 (titres de Box 2, phrase sur Box 3 et Box 4) en extraction de texte ; le reste parcouru en extraction de texte |
| Ge, Dudoit et Speed (2003), *TEST* 12(1), p. 1-77, DOI 10.1007/BF02595811 : notice Crossref | libre | notice : titre, revue *Test*, vol. 12, n° 1, p. 1-77, juin 2003, auteurs Ge, Dudoit, Speed |
| Même article, version publiée (`link.springer.com/content/pdf/10.1007/BF02595811.pdf`) | **non obtenu** (page HTML d'accès, pas de PDF) | — |

**Version lue.** Le rapport technique de janvier 2003 est la version de travail de l'article de *TEST* (même titre, mêmes auteurs). La version publiée n'a pas été vue : les numéros de page du § 3 sont ceux du **rapport technique**, pas de *TEST*.

---

## Tableau récapitulatif

| # | Référence | Affirmation | Lieu dans le dépôt | Page, section, équation | Statut |
|---|---|---|---|---|---|
| 1 | Westfall et Young (1993) | Notice (titre, éditeur, année, ISBN) | spéc. Fk § 0 (`fk-lecture-conjointe.md:64`) ; `bloc-1.md:109` | Open Library | [V] |
| 2 | Westfall et Young (1993) | Contenu : définitions, algorithmes, pages | spéc. Fk § 0, § 4.5 (`fk-lecture-conjointe.md:64`, `:315-321`) | — | [NV] |
| 3a | Ge, Dudoit et Speed (2003) | Notice | spéc. Fk § 0 (`fk-lecture-conjointe.md:64`) | Crossref ; p. 1 du rapport | [V] |
| 3b | idem | p ajustée minP en une étape : p̃_i = Pr(min_l P_l ≤ p_i \| H_M) | spéc. Fk § 1.1 (`:90`), § 2.1 (`:172-186`) | rapport, p. 12, éq. (10) | [V] |
| 3c | idem | Contrôle faible « under all conditions » ; contrôle fort sous pivotalité des sous-ensembles | spéc. Fk § 1.1 (`:90`) ; commentaire `6395430599` de #297, point 6 | rapport, p. 8 (définitions), p. 12, point 4 | [V] |
| 3d | idem | minP pas à pas (step-down), éq. (14) ; preuve du contrôle fort renvoyée à W&Y, section 2.8 | — | rapport, p. 14 | [V] (attribution à W&Y : [P]) |
| 3e | idem | Algorithme : p de chaque réplication par rang parmi **toutes** les réplications, l'observé compris ; minima successifs | spéc. Fk § 2.1 (`:172-200`) ; #297 corps, point 1 ; `bloc-1.md:87` | rapport, p. 14 (« including the observed »), p. 17 (Box 3), p. 18 (Box 4), p. 19, éq. (16) | [V] ; **[X]** pour le corps de #297 et `bloc-1.md:87` (§ 3.4) |
| 3f | idem | Ex æquo : p égale pour les valeurs égales, compte cumulé au sens « ≥ » | spéc. Fk § 2.1 (`:174-178`) | rapport, p. 19, « Ties » | [V] |
| 3g | idem | Statistiques discrètes : minP plus sensible au nombre de permutations et plus conservatrice que maxT | spéc. Fk § 1.1 (`:92`), § 5 | rapport, p. 13, point 5 | [V] |
| 3h | idem → W&Y | Pages de W&Y : p. 42 (pivotalité), p. 50, section 2.8, algorithme 2.8 p. 66-67, algorithme 4.1 p. 116-117 | — | rapport, p. 12-17 | [P] (attribution secondaire) |

---

## 1. Westfall et Young (1993) : notice [V]

> P. H. Westfall et S. S. Young, *Resampling-Based Multiple Testing: Examples and Methods for p-Value Adjustment*, Wiley (Wiley-Interscience), New York, 1993, xvii + 340 p., ISBN 0-471-55761-7.

Concorde avec `fk-lecture-conjointe.md:64` (titre, éditeur, année) et `bloc-1.md:109` (ISBN). Crossref ne connaît que des **comptes rendus** de l'ouvrage (DOI 10.2307/1270279, 10.2307/2533464, 10.2307/2348369), pas l'ouvrage lui-même.

## 2. Westfall et Young (1993) : contenu [NV]

Aucun accès au texte : pas de version en libre accès trouvée ; l'ouvrage est vendu par Wiley. Aucune copie tierce n'a été utilisée. **Rien de ce qui suit n'est lu dans l'ouvrage.**

Conséquence : la phrase datée prévue par la spécification (`fk-lecture-conjointe.md:317`, « Westfall et Young (1993) n'a pas été relu sur le texte intégral au 24 octobre 2026… ») reste nécessaire, avec la date du présent relevé si elle est mise à jour (25 octobre 2026).

## 3. Ge, Dudoit et Speed (2003), en complément [V sur le rapport technique]

### 3.1 Définitions du contrôle (rapport, p. 8) [V]

« Controlling an error rate under H_M is called *weak* control. For the FWER, weak control means control of Pr(V > 0 | H_M). *Strong* control means control for every possible choice M_0. » H_M est l'hypothèse nulle complète, intersection de toutes les H_i.

### 3.2 minP en une étape (rapport, p. 12) [V]

Formule lue en rendu graphique, éq. (10) :

> « Their *single-step minP adjusted p-values* are defined by p̃_i = Pr( min_{1≤l≤m} P_l ≤ p_i | H_M ) »,

où P_l est la p brute aléatoire de la l-ième hypothèse. Le maxT correspondant, éq. (11) : p̃_i = Pr( max_l |T_l| ≥ |t_i| | H_M ).

Point 4, même page :

> « Procedures based on the maxT and minP adjusted p-values control the FWER weakly under all conditions. Strong control of the FWER also holds under the assumption of subset pivotality (Westfall & Young 1993, p. 42). »

Définition de la pivotalité, même point : la loi jointe de {P_i : i ∈ K} est la même sous H_K = ∩_{i∈K} {H_i = 0} et sous H_M, pour tout sous-ensemble K.

**Confrontation au dépôt.**

- La p de famille de la spécification, p_f = P*(m ≤ m_obs) avec m = min_j p_j (`fk-lecture-conjointe.md:88-90`), est l'éq. (10) appliquée à la plus petite p brute : p̃ de la plus petite p, sous la loi jointe des réplications. **Conforme [V].**
- « Elle contrôle le taux d'erreur de la famille au sens faible » et « le contrôle au sens fort et la condition de pivotalité des sous-ensembles ne sont pas en cause » (`fk-lecture-conjointe.md:90`) : conforme au point 4, qui lie la pivotalité au contrôle **fort** seulement. **[V].** Réserve, déjà écrite dans la spécification (`:92`) : le « under all conditions » du rapport vaut pour une loi calculée sous H_M ; la loi bootstrap sous le modèle ajusté n'en est qu'une estimation plug-in.
- Même constat pour le commentaire `6395430599` de #297, point 6. **[V].**

### 3.3 minP pas à pas (rapport, p. 13-14) [V ; attribution à W&Y : P]

Éq. (14), lue en rendu graphique :

> « The Westfall & Young (1993) *step-down minP adjusted p-values* are defined by p̃_{r_i} = max_{k=1,…,i} { Pr( min_{l=k,…,m} P_{r_l} ≤ p_{r_k} | H_M ) } »,

avec p_{r_1} ≤ … ≤ p_{r_m} les p brutes ordonnées. « For a proof of strong control of the FWER for the maxT and minP procedures assuming subset pivotality we refer the reader to Westfall & Young (1993, Section 2.8). »

La spécification n'en fait pas usage (ligne de famille sans p ajustée par ligne, `fk-lecture-conjointe.md:90`). Sans écart.

### 3.4 Algorithme : p de chaque réplication (rapport, p. 14-19) [V], et écart du corps de #297 [X]

Ce que dit le rapport :

- p. 14 : « a random subset of B permutations (**including the observed**) is considered » ;
- p. 17, Box 3, intitulé « based on Westfall & Young (1993) Algorithm 2.8 p. 66-67 » : pour chaque permutation b, p brutes p_{1,b}, …, p_{m,b}, minima successifs q_{i,b} = min_{l=i,…,m} p_{r_l,b}, puis p̃*_{r_i} = #{b : q_{i,b} ≤ p*_{r_i}} / B, et monotonie imposée par p̃*_{r_i} ← max(p̃*_{r_{i−1}}, p̃*_{r_i}) ;
- p. 18, Box 4 : même résultat sans double permutation (« this algorithm produces the same p-values as the double permutation algorithm in Box 3 », p. 16) ;
- p. 19, éq. (16) : « p_{i,b} = #{b' : |t_{i,b'}| ≥ |t_{i,b}|} / B ». **Le compte porte sur les B permutations, la permutation b elle-même et l'observé compris** ; dénominateur B, nombre total d'items.

**Confrontation au dépôt.**

- **Spécification, § 2.1** (`fk-lecture-conjointe.md:174-184`) : c_j(k) compte tous les items k' ∈ 0..n, l'item k compris, l'observé étant l'item 0 ; p_j(k) = a_j(k)/(n + 1) ; p_f = #{k ∈ 0..n : m(k) ≤ m(0)}/(n + 1). C'est l'éq. (16) et le Box 3 en une étape, avec n + 1 = B items, observé compris. **Conforme [V].** Le commentaire `6395430599` de #297, point 4 (« parmi toutes les réplications, observé compris »), l'est aussi.
- **Corps de #297, point 1** (« p_j^(b) est le rang de S_j^(b) **parmi les autres réplications** ») et **`docs/revues/20261015-pertinence-tests-graphiques/bloc-1.md:87`** (« p_j^(b) = rang de S_j^(b) parmi les autres réplications ») : **[X]**. La construction de la source compte l'item lui-même et met toutes les p sur une seule grille. L'écart est déjà corrigé par la spécification (§ 2.1, construction « déconseillée », `:194-206`) et par le commentaire `6395430599`, point 4, qui remplace le corps ; il reste à le signaler si `bloc-1.md` est cité.

### 3.5 Ex æquo et discrétude (rapport, p. 13 et 19) [V]

- p. 19, « Ties » : les statistiques égales reçoivent la même p, égale au compte cumulé des valeurs au moins aussi extrêmes divisé par B, formule lue en rendu graphique : p_{i,r_j^1} = … = p_{i,r_j^{k_j}} = (Σ_{l=1}^{j} k_l)/B. C'est le compte « ≥ » de l'éq. (16), ex æquo inclus. La spécification fait de même (comptes c⁺ et c⁻ qui incluent les ex æquo, `fk-lecture-conjointe.md:174-176`). **Conforme [V].**
- p. 13, point 5 : « When adjusted p-values are estimated by permutation (Section 4) and a large number of hypotheses are tested, procedures based on the minP p-values tend to be more sensitive to the number of permutations and more conservative than those based on the maxT p-values. » Le rapport ne traite pas autrement les statistiques discrètes. La spécification n'affirme rien de contraire ; l'argument de sur-uniformité « ex æquo compris » (`:186-190`) y est établi par raisonnement, non par cette source.
- **Ce que le rapport ne dit pas** : rien sur une p minP dont les p brutes viennent d'un bootstrap paramétrique sous un modèle ajusté, ni sur le niveau à petit échantillon. Les statuts « plug-in, non exacte » et « niveau réel à T = 8 non établi » de la spécification (`:92`) restent les siens.

### 3.6 Pages de Westfall et Young citées par le rapport [P]

Attributions du rapport, **non contrôlées dans l'ouvrage** :

| Énoncé | Lieu dans W&Y selon le rapport | Page du rapport |
|---|---|---|
| Pivotalité des sous-ensembles, contrôle fort | p. 42 | p. 12 |
| Ajustements maxT déséquilibrés si les T_i ne sont pas de même loi | p. 50 | p. 13 |
| Preuve du contrôle fort, maxT et minP | section 2.8 | p. 14 |
| minP pas à pas, double permutation | algorithme 2.8, p. 66-67 | p. 17 (Box 3) |
| maxT pas à pas | algorithme 4.1, p. 116-117 | p. 16 (Box 2) |

**Aucun numéro d'algorithme ni de page de Westfall et Young n'est à reporter dans le `.tex` ou le moteur sur la seule foi de ce tableau** ; s'il l'était, il faudrait écrire « d'après Ge, Dudoit et Speed (2003) ».

---

## Recommandation

- **Champ `reference` des lignes de famille** (`fk-lecture-conjointe.md:270`, « Westfall & Young (1993), minP en une etape ; Dwass (1957), Hope (1968) ») : exact pour le nom et l'origine [P]. Si une source lue sur pièce est souhaitée, ajouter « Ge, Dudoit & Speed (2003), TEST 12(1), eq. (10) » ; l'éq. (10) est lue dans le rapport technique, la version publiée n'ayant pas été vue.
- **Phrase datée du § 4.5** (`fk-lecture-conjointe.md:317`) : à garder, Westfall et Young n'étant pas lu.
- **Construction du § 2.1** : confirmée par la source secondaire (§ 3.4) ; l'écart [X] du corps de #297 est déjà réglé par le commentaire `6395430599`.

*Aucune page, équation ni citation n'a été ajoutée hors du texte lu.*

---

# Relevé du 27/10/2026

> *Rédigé par Claude (session de relevé de sources, accès internet par le proxy de la session), le 27/10/2026, sur commande de la session principale de Fn et décision du mainteneur du 27/10/2026 (Q-42-12). Branche `claude/incertitude-bootstrap-graphiques` (PR brouillon #384). Le relevé du 25/10 ci-dessus est conservé ; ce qui suit le complète sur Westfall et Young (1993).*

## R27.0 Statuts au 27/10/2026 (ancien → nouveau)

| # | Affirmation | Lieu (tête `c564324`) | Ce qui est vérifié le 27/10 | Statut |
|---|---|---|---|---|
| 1 | Notice Westfall et Young (1993) | `doc_tests_usp.tex:17497-17499`, `:19341-19342` | Google Books (titre, auteurs, Wiley) | [V] → [V] |
| 2 | Contenu de l'ouvrage | spéc. Fk § 0, § 4.5 ; `doc_tests_usp.tex:17497-17499` (« cité pour le nom et l'origine de la procédure, non relu ») | p. 42-43, 49, 67, 116-117 lues ; p. 41, 44-48, 50-51, 65-66, 68 non servies par l'aperçu | [NV] → **[P+]** : pages lues, minP en une étape non lue |
| 3h-a | Pivotalité des sous-ensembles « p. 42 » (attribution de Ge, Dudoit et Speed) | rapport GDS p. 12 | p. 42, condition 2.1 | [P] → **[V]** |
| 3h-b | « p. 50 » (maxT déséquilibrés) | rapport GDS p. 13 | p. 50 non servie | [P] → [P] |
| 3h-c | Section 2.8, preuve du contrôle fort | rapport GDS p. 14 | non lue | [P] → [P] |
| 3h-d | « Algorithme 2.8, p. 66-67 », minP pas à pas | rapport GDS p. 17 (Box 3) | p. 67 : fin de l'algorithme 2.8 (monotonie) et algorithme 2.9 (minima successifs) ; p. 66 non servie | [P] → **[V]** pour la p. 67 ; début de l'algorithme [P] |
| 3h-e | « Algorithme 4.1, p. 116-117 », maxT pas à pas | rapport GDS p. 16 (Box 2) | p. 116-117 | [P] → **[V]** |

## R27.1 Source et méthode

| Source | URL | Résultat |
|---|---|---|
| Google Books, *Resampling-Based Multiple Testing: Examples and Methods for p-Value Adjustment*, P. H. Westfall et S. S. Young, identifiant `nuQXORVGI1QC` (trouvé par `https://books.google.com/books?vid=ISBN0471557617`, HTTP 200) | `https://books.google.com/books?id=nuQXORVGI1QC&pg=PA<n>` | HTTP 200 ; **aperçu limité autorisé par l'éditeur** (« Pages displayed by permission of John Wiley & Sons ») ; plusieurs pages remplacées par « You have either reached a page that is unavailable for viewing or reached your viewing limit for this book » |

Pages rendues par Chromium (Playwright) et lues **sur l'image**. Servies : p. 42, 43, 49, 67, 116, 117. Non servies (pages blanches de l'aperçu) : p. 41, 44, 46-48, 50, 51, 65, 66, 68 ; p. 45 non demandée. Aucune copie tierce, aucun fichier source dans le dépôt.

## R27.2 Ce qui est lu

### Pivotalité des sous-ensembles (§ 2.2.3, p. 42-43)

- P. 42, « Condition 2.1 Subset Pivotality » : « The distribution of **P** has the *subset pivotality* property if the joint distribution of the subvector {P_i; i ∈ K} is identical under the restrictions ∩_{i∈K} H_{0i} and H_0^C, for all subsets K = {i₁, …, i_j} of true null hypotheses. »
- P. 42 : « when subset pivotality holds, it will be shown that such resampling-based methods control the FWE in the *strong* sense (at least approximately, under asymptotic subset pivotality). Without this condition, resampling under H_0^C can be assumed to control only the FWEC. » Condition 2.2, pivotalité asymptotique, même page.
- P. 43, exemple 2.1 (statistiques t de moyennes, normale multivariée : la condition tient) ; exemple 2.2 (tests de corrélations nulles : « the subset pivotality condition fails »).

**Confrontation.** C'est l'énoncé que Ge, Dudoit et Speed attribuent à « Westfall & Young 1993, p. 42 » (§ 3.2) : **attribution exacte [V]**. Notation de l'ouvrage : H_0^C pour l'hypothèse nulle complète (H_M chez Ge, Dudoit et Speed), FWEC pour le contrôle sous l'hypothèse nulle complète (contrôle faible). La lecture de la spécification Fk (« contrôle […] au sens faible ; le contrôle au sens fort et la condition de pivotalité des sous-ensembles ne sont pas en cause », `fk-lecture-conjointe.md:90`) est **conforme** à la p. 42 : sans pivotalité, le rééchantillonnage sous H_0^C ne garantit que le contrôle sous H_0^C.

### Méthodes en une étape (§ 2.3, p. 43 et 49)

- P. 43 : « single-step methods are simultaneous test procedures, or STP's, that perform equivalent multiplicity adjustments for all tests, regardless of the *ordering* of the observed p-values ».
- P. 49, tableau 2.3 : erreur standard de p̃_i^{(N)} selon N (par exemple 0,0069 pour p̃ = 0,05 à N = 1 000). Algorithme 2.6 (« Normal Linear Model Application ») : données simulées y\*_ij = ε\*_ij i.i.d. N(0, 1) (éq. (2.7)), statistiques t\*_l et p\*_l de la loi de Student. Texte : sous pivotalité, « the joint distributions of the p-value vectors **P** and **P\*** are also identical ».
- **La définition du minP en une étape (pages précédant la p. 49 et p. 47-48) n'est pas servie** : elle reste lue par la seule source secondaire (Ge, Dudoit et Speed, éq. (10), § 3.2).

### minP pas à pas (p. 67, titre courant « Step-down methods for free combinations »)

- P. 67, étape 5 de l'algorithme 2.8 : monotonie par maximisation successive, p̃_(2)^{(N)} ← max(p̃_(1)^{(N)}, p̃_(2)^{(N)}), etc. ; « N ≥ 10,000 is recommended ». Calcul de toutes les Pr(min_{l∈{r_j,…,r_k}} P_l ≤ p_(j) | H_0^C) « within the *same* simulation ».
- Algorithme 2.9 (« A Specific Step-Down Illustration ») : minima successifs q\*_5 = p\*_5, q\*_4 = min(q\*_5, p\*_3), …, q\*_1 = min(q\*_2, p\*_2), dans l'ordre des p observées.
- **Le début de l'algorithme 2.8 (p. 66) n'est pas servi.** Concorde avec ce que Ge, Dudoit et Speed reproduisent dans leur Box 3 (§ 3.4) : [V] pour la p. 67.

### maxT pas à pas (§ 4, p. 116-117)

- Algorithme 4.1 (« Multivariate Permutation Resampling of t-Statistics ») : permutation des vecteurs entiers ; statistiques t\*_k ; maxima successifs u\*_3 = t\*_2, u\*_2 = max(u\*_3, t\*_1), u\*_1 = max(u\*_2, t\*_3) ; **étape 4 : « If u\*_i ≥ t_(i), then COUNT_i ← COUNT_i + 1 »** ; p̃_i^{(N)} = COUNT_i/N ; monotonie par maximisation successive.
- P. 116 : « the resampled multiplicity-adjusted p-values are exact (up to simulation error) even if the unadjusted p-values are not », dans le cadre de permutation de cet exemple.
- P. 117 : avec N = 100 000, p ajustée 0,0997, erreur standard {0,0997(1 − 0,0997)/100 000}^{1/2} = 0,00095.

**Confrontation.**
- Le compte « ≥ » de l'étape 4 (maxT) correspond, pour minP, au compte « ≤ » de la spécification Fk § 2.1 (`fk-lecture-conjointe.md:174-184`) : les ex æquo sont comptés contre l'hypothèse. **Conforme [V].**
- Le dénominateur de l'ouvrage est **N**, nombre de rééchantillons, sans l'observé. La spécification et Ge, Dudoit et Speed (éq. (16)) comptent l'observé parmi les items (dénominateur n + 1, ou B observé compris). C'est un écart de convention, **sans [X]** : la spécification suit Ge, Dudoit et Speed et Dwass (1957) pour l'exactitude à B fini, et non l'algorithme 4.1.
- L'exactitude « up to simulation error » de la p. 116 vaut pour un **rééchantillonnage par permutation**. Rien dans les pages lues ne porte sur un bootstrap paramétrique sous un modèle ajusté, ni sur des statistiques discrètes. La phrase du `.tex` « cité pour le nom et l'origine de la procédure » (`doc_tests_usp.tex:17497-17499`) reste juste.

## R27.3 Ce qui reste non lu

Définition du minP en une étape (p. 47-48 ou voisines), p. 50 (maxT déséquilibrés), section 2.8 (preuve du contrôle fort), p. 66 (début de l'algorithme 2.8), traitement des statistiques discrètes et des ex æquo hors de l'étape 4 de l'algorithme 4.1. Voie : l'aperçu Google Books plafonne les pages servies ; ouvrage complet par achat (Wiley) ou prêt.

**Conséquence pour le `.tex`** : la mention « non relu » de `doc_tests_usp.tex:17497-17499` peut devenir « lu en partie (p. 42-43, 49, 67, 116-117, aperçu de l'éditeur, 27 octobre 2026) » ; la p ajustée minP en une étape reste attribuée à l'ouvrage par Ge, Dudoit et Speed (2003, éq. (10)). Décision au passage de `docwriter`.

*Citations et formules lues sur le rendu graphique des pages de l'aperçu ; rien n'est rapporté des pages non servies.*
