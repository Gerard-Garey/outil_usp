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
