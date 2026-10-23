# Vérification des références externes de la branche Fj (M1, M2, M4)

> *Rédigé par Claude (seconde session de vérification bibliographique, à accès complet à internet), le 22/10/2026. Commande de la session principale de Fj, en application de la décision Q-D1-Fj-8 du mainteneur du 22/10/2026 (spécification `docs/specifications/fj-merz-wuthrich-identifiabilite.md`, encadré de décisions), selon la règle M38. Branche `claude/merz-wuthrich-identifiabilite` (PR brouillon #360).* Précédent : `docs/references/verifications-fi.md` (commit `af4710e`), dont la forme est reprise.

## Objet

Le relevé M38 de Fj couvre les références de la spécification D1-Fj (§ 4.3, § 4.5 et § 9) :

- les références déjà vérifiées pour Fi, reprises sans relecture nouvelle (§ 1) ;
- **Mack (1999)**, *ASTIN Bulletin* 29(2), laissé [NV] par la consultation `actuary-approfondi` du 22/10 (spéc. § 4.5), faute d'accès au texte (proxy 403). Le mainteneur a demandé sa vérification avant toute décision sur son ajout à la fiche `mw:m1d` (Q-D1-Fj-8) (§ 2) ;
- les calculs qui n'appellent pas de référence externe (§ 3).

Les numéros de ligne citent la tête `0ad328b` de la branche.

**Statut qui fait foi.** Pour Mack (1999), le statut du § 2 remplace le [NV] de la spécification (§ 4.5, § 9 et Q-D1-Fj-8). Les autres statuts sont ceux de `verifications-fi.md`, inchangés.

## Méthode et statuts

Statuts de `verifications-fi.md` (« Méthode et statuts »), plus un quatrième :

- **[V]** : vérifié sur le texte, avec la page, la section ou l'équation, et la source consultée. Citations en anglais, courtes, entre guillemets.
- **[P]** : vérification partielle (notice vérifiée, énoncé non lu dans le texte ; la raison est donnée).
- **[X]** : affirmation fausse ou non trouvée.
- **[NV]** : non vérifié (marque de la spécification D1-Fj).

Lecture du texte :

- **Formules** : lues en rendu graphique (pages du PDF converties en image à 110 dpi), jamais sur l'extraction de texte, qui les rend illisibles dans ce fichier (indices et exposants perdus).
- **Prose** : extraction de texte, contrôlée sur le rendu graphique et sur les en-têtes de page imprimés.
- **Aucun fichier source n'a été déposé dans le dépôt.**

## Sources consultées (22/10/2026)

| Source | Accès | Contenu lu |
|---|---|---|
| Crossref, `api.crossref.org/works/10.2143/AST.29.2.504622` | libre | notice : auteur, titre, revue, volume, numéro, pages, date, éditeur, DOI |
| Mack (1999), *ASTIN Bulletin* : `casact.org/sites/default/files/database/astin_vol29no2_361.pdf` (7 p. ; md5 `b6301cdd75c178de5ee2bd16860074fa`) | libre (HTTP 200) | texte intégral, p. 361-366 ; p. 361-364 lues en rendu graphique. La 7ᵉ page du PDF est la nécrologie de N. De Pril, p. 367 du même numéro, sans rapport |

---

## Tableau récapitulatif

| # | Référence | Affirmation | Lieu | Page, section, équation | Statut |
|---|---|---|---|---|---|
| 1a | Mack (1993) | Hyp. (1) et (3), σ̂² | reprise de `verifications-fi.md` § 6.1 | p. 214, 217 | [V] |
| 1b | Mack (1994, *CAS Forum*) | Chap. 3, p. 111 ; chap. 5, p. 121-124 | reprise de `verifications-fi.md` § 6.2 | p. 111, 121-124 | [V] |
| 1c | Cook et Weisberg (1982) | Résidu studentisé externe, Bonferroni, pondération | reprise de `verifications-fi.md` § 2.1 | p. 20, 21, 22, 26, 209 | [V] |
| 1d | Belsley, Kuh et Welsch (1980) | Nom RSTUDENT | reprise de `verifications-fi.md` § 2.2 | chap. 2 | [P] |
| 1e | Frisch et Waugh (1933) | Partialisation | reprise de `verifications-fi.md` § 3.2 | p. 387-401 | [V] |
| 2a | Mack (1999) | Notice | spéc. Fj § 4.5 et § 9 | p. 361-366, DOI 10.2143/AST.29.2.504622 | [V] |
| 2b | Mack (1999) | Famille des estimateurs pondérés α ∈ {0 ; 1 ; 2} | candidat pour `mw:m1d` (`doc_tests_usp.tex:14865-14868`) | p. 361 (définition), p. 362 (lecture des trois valeurs, modèle CL1-CL3), p. 363 (propriétés) | [V] |
| 2c | Mack (1999) | Absence de biais des estimateurs | candidat pour `mw:m1d` (Cadre, `doc_tests_usp.tex:14878-14880`) | p. 363, dans le modèle CL1-CL3 seulement, renvoi à Mack (1993) | [V], avec une nuance (§ 2.3) |

---

## 1. Reprises de `verifications-fi.md`, sans relecture nouvelle

Ces références ont été vérifiées le 22/10/2026 pour Fi (`verifications-fi.md`, commit `af4710e`). Elles ne sont pas relues ici ; le statut et le détail sont ceux du paragraphe indiqué.

- **Mack (1993)**, *ASTIN Bulletin* 23(2), p. 213-225 : hypothèse (1), p. 214, et hypothèse (3) avec σ̂²_k, p. 217. Voir `verifications-fi.md`, § 6.1. **[V]**
- **Mack (1994, *CAS Forum*)**, p. 101-182 : chap. 3, p. 111 (facteur chain-ladder moyenne des facteurs individuels pondérée par C_jk, chacun sans biais pour f_k) ; chap. 5, p. 121-124 (régression pondérée sans constante ; f_k0 pondéré par C², éq. (12), p. 122 ; f_k2 moyenne simple, éq. (13), p. 124). Voir `verifications-fi.md`, § 6.2. **[V]**
- **Cook et Weisberg (1982)**, *Residuals and Influence in Regression* : p. 20, 21, 22, 26 et 209. Voir `verifications-fi.md`, § 2.1. **[V]**
- **Belsley, Kuh et Welsch (1980)**, chap. 2 : nom RSTUDENT, attesté par Atkinson (1983). Voir `verifications-fi.md`, § 2.2. **[P]**
- **Frisch et Waugh (1933)**, *Econometrica* 1(4), p. 387-401. Voir `verifications-fi.md`, § 3.2. **[V]**

## 2. Mack (1999)

### 2.1 Notice [V]

**Notice [V]** (Crossref ; contrôlée sur le pied de la p. 361 du PDF, « ASTIN BULLETIN, Vol. 29, No. 2, 1999, pp. 361-366 ») :

> T. Mack, « The Standard Error of Chain Ladder Reserve Estimates: Recursive Calculation and Inclusion of a Tail Factor », *ASTIN Bulletin*, vol. 29, n° 2, novembre 1999, p. 361-366, DOI 10.2143/AST.29.2.504622 (Crossref le rend en minuscules, `10.2143/ast.29.2.504622` ; éditeur actuel : Cambridge University Press).

La notice de la spécification (§ 4.5 et § 9 : *ASTIN Bulletin* 29(2), 1999, p. 361-366, DOI 10.2143/AST.29.2.504622) est **exacte**. Crossref ajoute le mois (novembre 1999).

Plan de l'article (sans numérotation de sections) : résumé et « Introduction », p. 361-362 ; « Recursive Calculation of the Standard Error », p. 362-364 ; « Inclusion of a Tail Factor », p. 364-366, avec les tables 1 et 2 ; une seule référence, Mack (1993). L'article n'a **aucune équation numérotée**, sauf la formule (*) de la p. 363.

### 2.2 La famille α : traitée, p. 361-363 [V]

**L'article traite explicitement de la famille des estimateurs pondérés α = 0, 1, 2.** C'est même son cadre de départ : il généralise à α = 0 et α = 2, et à des poids w_ik ∈ [0 ; 1], le calcul de l'erreur type de Mack (1993), établi pour α = 1.

| Énoncé | Page, lieu | Texte (formules lues en rendu graphique) | Statut |
|---|---|---|---|
| Définition de la famille | p. 361, « Introduction » | « the age-to-age factor f̂_k is defined by f̂_k = Σ_{i=1}^{n−k} w_ik C_ik^α F_ik / Σ_{i=1}^{n−k} w_ik C_ik^α, α ∈ {0; 1; 2} », avec « F_ik = C_{i,k+1}/C_ik » les facteurs individuels et w_ik ∈ [0 ; 1] des poids au choix de l'actuaire | [V] |
| Lecture des trois valeurs | p. 362, l. 2-6 | « Normally, w_ik = 1 for all i, k. Then, α = 1 gives the historical chain ladder age-to-age factors, α = 0 gives the straight average of the observed individual development factors and α = 2 is the result of an ordinary regression of C_{i,k+1} against C_ik with intercept 0. » | [V] |
| Généralisation annoncée | p. 362, fin de l'« Introduction » | « In Mack (1993), a formula for the standard error of the predictor Ĉ_in was derived for α = 1 and all w_ik = 1. In the next section, this formula is generalized for the cases α = 0 or α = 2 and w_ik < 1. » | [V] |
| Modèle stochastique propre à α | p. 362, (CL1)-(CL3) | « (CL1) E(F_ik \| C_i1, …, C_ik) = f_k » ; « (CL2) Var(F_ik \| C_i1, …, C_ik) = σ_k² / (w_ik C_ik^α) » ; « (CL3) The accident years (C_i1, …, C_in), 1 ≤ i ≤ n, are independent. » Présenté comme le modèle de Mack (1993) « in its more general form without the restriction on α and w_ik » | [V] |
| Propriétés des estimateurs | p. 363, l. 1-7 | « Within this model, the following statements hold (see Mack (1993)): […] f̂_k is the minimum variance unbiased linear estimator of f_k (for w_ik and α given) » ; « f̂_{n+1−i} · … · f̂_{n−1} is an unbiased estimator of f_{n+1−i} · … · f_{n−1} » | [V] |
| Variance de f̂_k | p. 363 | « Var(f̂_k) = σ_k² / Σ_{j=1}^{n−k} w_jk C_jk^α », et σ̂_k² = (1/(n−k−1)) Σ_{i=1}^{n−k} w_ik C_ik^α (F_ik − f̂_k)², « an unbiased estimator for σ_k² », 1 ≤ k ≤ n − 2 | [V] |
| Formule (*) pour α = 0, 1, 2 | p. 363 | « In this last form, formula (*) also holds for α = 0 and α = 2 and any w_ik ∈ [0; 1] as can be seen by applying the proof for α = 0 and w_ik = 1 analogously. » La preuve n'est pas donnée dans l'article | [V] |

**Ce que l'article ne traite pas** (lecture intégrale des p. 361-366) :

- aucune **comparaison** des trois estimateurs entre eux sur un même triangle ;
- aucun **test**, ni aucune statistique d'écart (du type de l'amplitude A de `mw:m1d`) ;
- aucun énoncé sur l'**absence de biais des trois estimateurs sous une même hypothèse de variance**. À chaque α est associée sa propre hypothèse (CL2), sous laquelle f̂_k est le meilleur estimateur linéaire sans biais. L'exemple numérique (tables 1 et 2) est calculé à α = 1 et w_ik = 1 seulement (p. 364) ;
- aucune discussion de M2 ou d'un choix de α fondé sur les données.

### 2.3 Nuance sur l'absence de biais [V]

La fiche `mw:m1d` (Cadre, `doc_tests_usp.tex:14878-14880`) dit : « Sous l'hypothèse M1, les trois estiment la même quantité : […] tout jeu de poids positifs fournit un estimateur sans biais de f_j ». Ce que Mack (1999) atteste, p. 363, est plus étroit :

- l'absence de biais (avec l'optimalité) est énoncée **« within this model »**, c'est-à-dire sous CL1-CL3, CL2 étant écrite avec l'α de l'estimateur ;
- elle est **renvoyée à Mack (1993)** (« see Mack (1993) »), sans preuve dans l'article.

Que l'absence de biais ne dépende que de CL1 et CL3, quelle que soit la variance, se déduit de la définition (f̂_k est une moyenne pondérée des F_ik à poids fonctions de C_i1, …, C_ik seulement), mais **l'article ne l'écrit pas**. L'énoncé de la fiche reste fondé par Mack (1994), chap. 3, p. 111 (`verifications-fi.md`, § 6.2), qui le dit pour tout facteur individuel, donc pour toute moyenne pondérée à poids positifs.

En revanche, Mack (1999) éclaire la phrase de l'Usage de `mw:m1d` (`doc_tests_usp.tex:14896-14899`) que la spécification juge inexacte (§ 4.3). Le choix de α y est lié à l'hypothèse de **variance** (CL2), pas à celle d'espérance (CL1) : une pondération « inadaptée » à la variance coûte en efficacité, pas en biais. Cela va dans le sens du constat de la spécification (sous une violation de M2 seule, l'hypothèse nulle de la ligne reste vraie), sans que l'article le formule.

### 2.4 Statut

**[V]** pour la notice et pour les énoncés du § 2.2, lus sur le texte intégral, formules en rendu graphique. La nuance du § 2.3 est un constat de lecture, pas une erreur de la spécification ou de la fiche : aucun **[X]**.

## 3. Calculs sans référence externe

Repris de la spécification (§ 9), sans changement :

- quantiles de la loi de Student décentrée (multiplicateurs de l'effet minimal détectable, § 3.3) : calcul numérique R, sans référence ;
- identités algébriques des § 3.3, 4.1 et 4.3 de la spécification, dont f̂^(α+1) − f̂^(α) = Cov_{w_α}(C, F) / E_{w_α}[C] avec w_α ∝ C^α (§ 4.3) : établies dans la spécification, sans référence externe.

---

## Recommandation (Q-D1-Fj-8)

**Citer Mack (1999) dans `mw:m1d`, en complément de Mack (1994) et non à sa place.** C'est la seule des références vérifiées qui pose **la famille α ∈ {0 ; 1 ; 2} elle-même**, sous cette notation et avec les trois lectures de la fiche (moyenne simple, chain-ladder, régression sans constante, donc pondération par C²). Mack (1994) les donne en deux chapitres et sous d'autres noms (f_k0, f_k1, f_k2).

Énoncé proposé pour la rubrique `\refl` (à confier à `docwriter` en fin de branche, règle 9) :

> T. Mack (1999), *ASTIN Bulletin* 29(2), p. 361-362 : famille f̂_k = Σ w_ik C_ik^α F_ik / Σ w_ik C_ik^α, α ∈ {0 ; 1 ; 2} ; « α = 1 gives the historical chain ladder age-to-age factors, α = 0 gives the straight average […] and α = 2 is the result of an ordinary regression of C_{i,k+1} against C_ik with intercept 0 ».

Et pour `sec:biblio`, la notice du § 2.1.

**À ne pas lui attribuer :**

- l'absence de biais sous M1 **quelle que soit la variance** : la garder sur Mack (1994), chap. 3, p. 111 (§ 2.3) ;
- tout test ou toute comparaison des trois estimateurs : l'article n'en contient pas. La statistique A et sa p-value de Monte-Carlo restent une **construction de l'outil**.

Si la phrase de l'Usage sur M2 est réécrite (spéc. § 4.3, texte T-5), Mack (1999, p. 362) peut être cité pour le lien entre α et l'hypothèse de variance, (CL2) : Var(F_ik | C_i1, …, C_ik) = σ_k² / (w_ik C_ik^α).

Le moteur n'est pas touché : la `reference` de la ligne (`R/engine.R:10739`, « Mack (1994), CAS Forum (printemps), 101-182, chap. 3 et 5 ») est exacte. L'ajout de Mack (1999) au moteur serait un changement non numérique, à juger par la session principale. Il passerait par le patch chirurgical (`tests/patcher_reference.R`), pas par une régénération.

*Aucune page, équation ni citation n'a été ajoutée hors du texte lu.*
