# Contrôle de conformité en aval, S6 étape 7 : Merz-Wüthrich sur un trapèze I > J (#567)

> *Rédigé par l'agent regulatory (IA), effort `high`, le 21/11/2026 ; versé intégralement par la session principale.* Branche lue : `claude/merz-wuthrich-trapeze`, tête `1dc1888`. Le code y est identique à `f9eaff7` : les deux commits suivants ne touchent que `CONTEXT.md` et `.claude/rules/moteur.md`. md5 de `R/engine.R` : `f32e6514ff1cd5431a172bb6ae123c6c`. Rien n'a été écrit dans le dépôt par l'agent : ni commit, ni issue, ni commentaire. Les scripts de contrôle (`c7.R`, `carre.R`, `deg.R`, `tf.R`, `m6.R`, `t27.R`) sont restés hors dépôt, dans le répertoire temporaire de la session.

## 0. Résultat

- **Aucun constat bloquant ni majeur.**
  - Le code applique exactement la lecture retenue : convention (B) de l'ADR 0005 (annotation du 21/11/2026, points 2 à 7), sur la forme consolidée de D(5) seule.
  - Indices des sommes, R̂, MSEP, règle de minimum, durée I + 1, crédibilité, mélange et refus de R̂ ≤ 0 sont conformes.
  - Il n'y a pas de correction de taille finie, et c'est conforme : D(4) n'en prévoit pas.
- **Chiffres concordants.** La transcription indépendante prend les sommes **complètes** de la forme consolidée (i = 1..I, k = i+1..I) et y pose la convention (B) terme à terme. Sur quatre trapèzes et sur le carré, elle redonne R̂, la MSEP et σ_USP du moteur avec un **écart relatif de 0** (§ 3). L'équivalence « convention (B) = restriction aux années I−J+1..I » est donc vérifiée numériquement sur le moteur lui-même.
- **Chemin carré inchangé au bit.** `run_engine()` de `main` et de la tête comparés par `identical()`, sur deux carrés (`triangle_mw.csv` et `triangle_mw_volatil.csv`). Seuls diffèrent deux ajouts de `plots_data` : les colonnes `sigma_residus` et `sigma_residus_direct` ajoutées en fin de `facteurs`, et `usage_sigma`. Les colonnes communes sont identiques.
- **Textes (t1) à (t4) : conformes.** Ils ne prêtent au règlement rien qu'il ne dit pas (critère E4). Une remarque sur (t4), sans écart (R-2).
- **Un constat mineur (m1), critère E5.** Le motif de refus « Triangle totalement dégénéré » (#192) affirme « aucun résidu de Mack n'est retenu ». Sur un trapèze dont seule la colonne J−1 n'est pas dégénérée, c'est faux : chiffré au § 4.
- **Documentation LaTeX non modifiée sur la branche** (attendu : règle 9, `docwriter` à l'étape 8). Le `.tex` décrit aujourd'hui un refus que le code n'applique plus. À contrôler à l'étape 8 ; ce n'est pas un constat de la présente étape (§ 2, ligne D-doc).

## 1. Sources

- **JOUE L 12 du 17.1.2015** (`Règlement délégué.pdf`), pages rendues en image à 110 ppp :
  - L 12/276 : D(1), D(2)(a) à (h)(ii) ;
  - L 12/277 : D(2)(h)(iii)-(iv), D(3), D(4) avec Ĉ et f̂, MSEP de 2015, D(5)(a)-(b) ;
  - L 12/278 : D(5)(c), (d), (d)(i), (d)(ii) ;
  - L 12/282 : section G, barèmes G(1), G(2) et durée G(3).
- **Version consolidée du 14.11.2024** (référence de lecture) : les 15 images de la section D ont été extraites du xhtml et lues **à l'image**.
  - image 0 : σ_USP ;
  - image 2 : Ĉ(i,j) ;
  - image 5 : MSEP consolidée, avec Σ_{i=1}^{I} Ĉ²(i,J)·(Q̂_{I−i}/C(i,I−i) + Q̂_{I−i}/S_{I−i} + Σ_{j=I−i+1}^{J−1} C(I−j,j)/S′_j·Q̂_j/S_j) + 2·Σ_{i=1}^{I} Σ_{k=i+1}^{I} Ĉ(i,J)Ĉ(k,J)·(Q̂_{I−i}/S_{I−i} + Σ_{j=I−i+1}^{J−1} …) ;
  - images 13 et 14 : les deux lignes de σ̂²_j.
  - Aucun marqueur de modification dans la section D.
- **Règlement délégué (UE) 2026/269** : il ne modifie ni l'annexe XVII ni les art. 218 à 220 (lecture amont, point transversal, confirmée). Contrôle d'exécution : un trapèze avec une date de référence au 30.6.2027 (texte 2026/269, `cdd_qualifiante = FALSE`) donne le même σ_USP qu'au 31.12.2026 (0,04757971).
- **Pièces de décision** : ADR 0005, annotation du 21/11/2026 ; `regulatory-1-lecture-trapeze.md` ; `t0-textes-etape6.md` ; spécification `actuary-2a-specification-567.md` (cas (s5)).
- **Diff contrôlé** : `git diff main...HEAD -- R/engine.R app.R R/display_helpers.R` (commits `74e6819`, `59ef487`, `ac363b1`, `f9eaff7` ; `ea80386` ne touche que les tests).

## 2. Matrice de conformité

Abréviations : « eng. » = `R/engine.R` ; « dh » = `R/display_helpers.R` ; les numéros de ligne sont ceux de la tête `1dc1888`.

| # | Disposition (texte, page) | Lecture retenue (ADR 0005, 21/11) | Code | Verdict |
|---|---|---|---|---|
| D(2)(b) | « cinq années d'accident consécutives au moins » (L 12/276) | I + 1 ≥ 5 | eng. 13170-13172, `nrow(tri) < T_min`, inchangé | **Conforme** |
| D(2)(c) | « pour la première année d'accident, […] cinq années de développement consécutives au moins » (L 12/276) | J + 1 ≥ 5 ; seule condition de dimension du trapèze | eng. 13173-13175, inchangé ; commentaire de repli mis à jour (eng. 13462-13465 : « J + 1 >= 5, D(2)(c) […] pour un carré comme pour un trapèze ») | **Conforme** (mineur déjà écarté le 13/11 : « consécutives » omis du motif ; critère aucun) |
| D(2)(e) | nombre d'années d'accident « pas inférieur » au nombre d'années de développement de la première année (L 12/276) | I ≥ J admis ; I < J refusé par le seul motif D(2)(e) (R-1) | eng. 13176-13177 inchangé ; motif MW-04 retiré (eng. 13178-13181) | **Conforme** : le domaine de l'outil est désormais celui du texte |
| D(2)(d) | complétude exigée « pour la première année d'accident » seulement (L 12/276) | hypothèse de la convention (B) pour les années 0..I−J, déclarée par l'avertissement (t1) | eng. 13355-13363 | **Conforme**, voir (t1) ci-dessous |
| D(3)(a)-(c) | numérotation de 0, I = dernière année d'accident, J = année de développement la plus récente de la première année d'accident (L 12/277) | I = nrow − 1, J = ncol − 1 ; partie observée i + j ≤ I, j ≤ J | `mw_cellules_observees()` eng. 13107-13110 ; contrôle des cellules eng. 13187-13210 (boucle j = 0..J, donc ligne 0 complète jusqu'à J) ; grille de l'application `app.R` 1413-1446 et `champs_triangle()` 1480 | **Conforme** |
| D(4)(c), f̂_j | f̂_j = Σ_{i=0}^{I−j−1} C(i,j+1) / Σ_{i=0}^{I−j−1} C(i,j) (L 12/277 ; consolidé image 4) | estimé sur **toutes** les lignes | eng. 13415-13420, inchangé | **Conforme** (écart 0 au § 3) |
| D(4)(c), Ĉ(i,j) | Ĉ(i,j) = C(i,I−i)·f̂_{I−i}⋯f̂_{j−1} (L 12/277 ; image 2) | lignes i ≤ I−J : Ĉ(i,J) := C(i,J) | eng. 13492-13497 : projection seulement si I − i < J ; sinon la cellule observée est gardée | **Conforme** à la convention (B), point 2 |
| D(4), dénominateur R̂ | Σ_{i=0}^{I}(Ĉ(i,J) − C(i,I−i)) (L 12/277 ; image 0) | C(i,I−i) := C(i,J) pour i ≤ I−J ; contribution exactement nulle | `derniers` = `tri[i+1, min(I−i, J)+1]` (eng. 13513) ; `reserve = sum(ultimes − derniers)`. Contrôle : `reserve_par_annee` vaut exactement 0,0000 sur i = 0..2 du 8 × 6 | **Conforme** |
| D(4), refus R̂ ≤ 0 (interprétation M4, #7) | le texte ne pose aucune condition de signe | se transpose sans changement (ADR, point 6) | `mw_valider_ajustement()` eng. 14070-14080, inchangé | **Conforme** |
| D(4), σ_USP | c·√MSEP / R̂ + (1 − c)·σ_(res,s) (L 12/277 ; image 0) | sans correction de taille finie | `mw_parametre()` eng. 14263-14277 : `sigma_usp = cred * sigma_est + (1 − cred) * sigma_standard` ; `correction_taille = 1` (eng. 17807) | **Conforme**. Le facteur √((T+1)/(T−1)) est propre aux sections B et C ; il n'existe pas en D et n'est pas appliqué |
| D(4)(d), σ_(res,s) | paramètre standard du segment (annexe II / XIV selon M6 ; art. 117 et 148 modifiés par 2026/269) | inchangé, sans lien avec la géométrie | `usp_parametre_standard()` (eng. 17710), inchangé | **Conforme** (II-1 : 0,09 ; même valeur sous 2026/269, `cdd_qualifiante = FALSE`) |
| D(5), MSEP | forme consolidée (image 5) ; forme de 2015 différente (L 12/277) | forme consolidée seule ; sommes en i et en k restreintes à I−J+1..I, équivalentes à la convention (B) | `mw_msep()` eng. 13856-13904 : `ii <- (I − J + 1L):I` (eng. 13872), boucles t1, t2 et termes croisés sur `ii`, k = i+1..I, facteur 2 ; Q̂_{I−i} et S_{I−i} lus seulement pour I − i ≤ J − 1 | **Conforme**. Écart relatif 0 avec la transcription littérale à sommes complètes (§ 3) |
| D(5)(b)-(c), S_j et S′_j | S_j = Σ_{i=0}^{I−j−1} C(i,j), S′_j = Σ_{i=0}^{I−j} C(i,j) (L 12/277-278) | inchangés | eng. 13502-13506 | **Conforme** |
| D(5)(d), Q̂_j | σ̂²_j / f̂²_j (L 12/278) | Q̂_j := 0 pour j ≥ J (convention), sans lecture | eng. 13500 ; aucune lecture de Q au-delà de J−1 (`ii`) | **Conforme** |
| D(5)(d)(ii), première ligne | σ̂²_j = 1/(I−j−1)·Σ_{i=0}^{I−j−1} C(i,j)(C(i,j+1)/C(i,j) − f̂_j)², pour j = 0..J−2 (L 12/278 ; image 13) | inchangée | eng. 13422-13429 | **Conforme** |
| D(5)(d)(ii), seconde ligne | σ̂²_{J−1} = min(σ̂²_{J−2}, σ̂²_{J−3}, σ̂⁴_{J−2}/σ̂²_{J−3}), « j = (J – 1) » (L 12/278 ; image 14) | prescrite **quel que soit I** | eng. 13458-13460, sans condition sur I | **Conforme**. Valeur de la règle sur le 8 × 6 : 0,141928 (moteur = transcription) |
| Estimateur direct de σ²_{J−1} (hors texte, Q-2a-1 (c), Q-2a-4) | aucune disposition | restitué pour information ; réduit les résidus seulement ; n'entre ni dans f̂, ni dans Ĉ, ni dans Q̂, ni dans la MSEP, ni dans la simulation, ni dans σ_USP | eng. 13481-13487, avec le diviseur I − J ; `.mw_sigma2_residus()` lu par `mw_residus()`, `mw_influence()` et `mw_identifiabilite_intra()` seulement ; la simulation lit `aj$sigma2` (eng. 16049) | **Conforme**. σ_USP n'en dépend pas : il est égal à la transcription, qui ne calcule pas cet estimateur. Valeur sur le 8 × 6 : 0,0973248, 2 degrés de liberté |
| `mw_contributions()` | (restitution, hors texte) | mêmes années que la MSEP | eng. 18092 : `(I − J + 1L):I` | **Conforme** à la MSEP |
| G(1) et G(2), barèmes | long : 34, 43, 51, 59, 67, 74, 81, 87, 92, 96, 100 % ; court : 34, 51, 67, 81, 92, 100 % (L 12/282) | inchangés | `CRED_LONG` et `CRED_COURT` (eng. 204-210), relus contre l'image | **Conforme** |
| G(3)(c), durée | « nombre d'années d'accident pour lesquelles des données sont disponibles » (L 12/282) | I + 1 (ni J + 1, ni I) | `T_cred <- aj$I + 1L` (eng. 14264) ; `metadata$T = aj$I + 1L` (eng. 17816) ; avertissement de crédibilité sur `nrow(tri)` (eng. 13388) | **Conforme** : 8 × 5, 8 × 6 et 8 × 7 donnent tous c(8) = 0,59 au barème long (II-1) |
| Mélange c / σ standard | D(4) et section G | sans objet propre au trapèze | eng. 14273 ; IC bootstrap `usp_b` (eng. 17763), même expression | **Conforme** |
| Art. 218 à 220 | non modifiés par la branche, ni par 2026/269 | — | — | **Sans objet** pour ce diff |
| (t1), avertissement | D(2)(d) : la complétude n'est exigée que de la première année d'accident | hypothèse déclarée, justification à la charge de l'entreprise | eng. 13355-13363 ; texte identique au texte définitif de T0 ; `%d` = I − J. Rendu contrôlé sur 8 × 5, 8 × 6 et 8 × 7 (« i = 0 a 3 / 2 / 1 ») | **Conforme (E4)** : le renvoi à D(2)(d) est exact ; « hypothese a justifier par l'entreprise » est présentée comme une exigence de l'outil ; « verifier qu'aucune annee de developpement ne manque » est un conseil de l'outil, non attribué au texte |
| (t2), mention M6 | D(5)(d)(ii), seconde ligne | règle « par prescription » ; estimateur direct pour information | `FORMAT_MENTION_MW_SIGMA_DIRECT` (eng. 13809-13814) ; jointe par `mw_tests()` (eng. 17243-17252) ; référence de la ligne : « Annexe XVII, D(5)(d)(ii), seconde ligne » | **Conforme (E4)** : texte corrigé de T0 repris mot pour mot. Rendu sur le 8 × 6 : « porte 3 facteurs, dont l'estimateur direct, 0.0973248 a 2 degre(s) de liberte » ; I − J + 1 = 3 facteurs, I − J = 2 degrés de liberté, exacts. L'estimateur direct n'est attribué à aucune disposition |
| (t3), `usage_sigma` | D(5)(d)(ii) | forme (ii) de Q-A1 | `MW_USAGE_SIGMA` (eng. 13820-13822), `pd$usage_sigma` (eng. 18312) ; légendes de dh 1931-2027 lues telles quelles | **Conforme** |
| (t4), `texte_formule()` | D(4) | min(I−i, J) signalé comme convention de l'outil | dh 2532-2540 ; branche `m$I > m$J` seulement ; carré inchangé (dh 2541 et suivantes). Rendu sur le 8 × 6 contrôlé (« i = 0 a 2 […] c = 59 % (bareme long, duree 8 ans) ») | **Conforme (E4)** ; remarque R-2 ci-dessous |
| Application, aide et dimension | D(2)(e) | — | aide « n annees d'accident x m annees de developpement, n ≥ m » (`app.R` 1327-1331), cohérente avec D(2)(e) ; `refus_dimension_triangle()` (`app.R` 405) porte sur PROFONDEUR_MAX, limite de l'outil sans fondement réglementaire et non présentée comme telle | **Conforme** |
| Chemin carré | — | identique au bit (ADR, « Ce qui ne change pas ») | `identical()` de `main` et de la tête sur deux carrés : tous les champs identiques, hors les deux ajouts de `plots_data` | **Conforme** |
| D-doc, `.tex` | — | à reprendre à l'étape 8 (ADR, décision 5) | `docs/latex/doc_tests_usp.tex` non modifié sur la branche. L. 5863 (« Géométrie carrée & I = J (motif émis si I > J) »), l. 15850 (« Restriction d'implémentation ») et la fiche `mw:m6sig` (« faute de degré de liberté ») décrivent l'état antérieur | **Non jugé à cette étape** (règle 9). À contrôler par `regulatory` sur le diff de `docwriter` à l'étape 8, avant la sortie du brouillon. En l'état, le `.tex` contredit le code (relèverait de E5 s'il était remis tel quel) |

## 3. Mesures (Rscript, `LC_ALL=C.UTF-8`, lecture seule)

Script `c7.R` : transcription littérale de la **forme consolidée à sommes complètes** (i = 1..I ; k = i+1..I ; facteur 2). La convention (B) y est posée terme à terme : Q̂_j = 0 pour j ≥ J, Ĉ(i,J) = C(i,J) et C(i,I−i) := C(i,J) pour i ≤ I−J, 0/S := 0. Elle est comparée à `run_engine()` (segment II-1, date de référence 2026-12-31, B = 199).

| Cas | I | J | R̂ (moteur = transcription) | MSEP (moteur = transcription) | écart relatif | σ estimé | c | σ_USP (moteur = recalcul) | σ²_{J−1} (règle) |
|---|---|---|---|---|---|---|---|---|---|
| carré 8 × 8 | 7 | 7 | 9 140,843438 | 39 798,02962 | 0 | 0,02182451 | 0,59 | 0,04977646 | 0,0973248 |
| `triangle_mw_trapeze.csv` (8 × 6) | 7 | 5 | 7 273,53169 | 17 334,25973 | 0 | 0,01810120 | 0,59 | 0,04757971 | 0,141928 |
| 8 × 5 | 7 | 4 | 5 885,878037 | 15 763,54103 | 0 | 0,02133122 | 0,59 | 0,04948542 | 0,684464 |
| 8 × 6 | 7 | 5 | 7 273,53169 | 17 334,25973 | 0 | 0,01810120 | 0,59 | 0,04757971 | 0,141928 |
| 8 × 7 | 7 | 6 | 8 490,816333 | 19 915,39471 | 0 | 0,01662054 | 0,59 | 0,04670612 | 0,0300913 |

- Les σ estimés égalent ceux de la lecture amont (0,021331 ; 0,018101 ; 0,016621).
- Les termes ajoutés par les sommes complètes sont donc exactement nuls sur le moteur. **L'équivalence du point 3 de l'ADR est vérifiée** sur ces cas.
- Script `carre.R` : `engine.R` de `main` (`git show`) et de la tête, chargés par `charger_moteur()` dans deux environnements ; `identical()` vrai sur `parametre_final`, `msep`, `tests`, `validation`, `ajustement`, `bootstrap`, etc.

## 4. Constats

### Bloquants : aucun. Majeurs : aucun.

### m1 (mineur) : motif « Triangle totalement dégénéré » faux sur un trapèze à colonne J−1 non dégénérée

- **Où.** `R/engine.R` 14109-14126 (texte du motif) et le commentaire 14090-14105 (fondement : « inverifiables quand aucune variance n'est observee »).
- **Ce qu'écrit le motif.** « […] aucun residu de Mack n'est retenu et, par D(4), sigma(res,s,USP) = (1 − c) * sigma(res,s) […] Ces donnees ne permettent pas d'etablir leur coherence avec […] D(2)(h), en particulier iv […] ».
- **Ce qui se passe.** Le cas (s5) de la spécification 2a garde le prédicat sur j = 0..J−2 et donc le refus. Mais sur un trapèze, la colonne J−1 porte I−J+1 facteurs, qui peuvent différer.
- **Preuve** (script `deg.R`). Trapèze 8 × 5, colonnes 0..J−2 à facteurs égaux, colonne J−1 à facteurs 1,05 / 1,15 / 1,10 / 1,08 :
  - `run_engine()` rend `ok = FALSE` avec ce motif ;
  - `mw_ajuster()` donne σ̂²_{0..3} ≈ 1e-29, ce qui confirme la MSEP nulle à la lettre par la règle de minimum, et `sigma2_Jm1_direct` = 3,396 ;
  - **`mw_residus()` retient 4 résidus (colonne j = 3)**.
  - « aucun residu de Mack n'est retenu » est donc faux sur ce cas, et la prémisse « aucune variance observée » ne tient plus.
- **Ce qui reste exact.** La partie réglementaire : σ²_{J−1} = 0 par D(5)(d)(ii), la MSEP est nulle, et D(4) donne (1 − c)·σ_(res,s).
- **Gravité : mineur.** Triangle pathologique ; l'issue (refus) est celle décidée en (s5) ; aucun σ_USP rendu à tort.
- **Critère ADR 0018 : E5** (texte restitué, un motif de refus, qui dit du code une chose qu'il ne fait pas). Ce n'est pas E4.
- **Interprétation à trancher.** Le fondement du refus #192 (art. 219(1)(d), D(2)(h)(iv) invérifiable) est un choix de mise en œuvre. Quand la colonne J−1 d'un trapèze montre de la variance, ce fondement mérite d'être reformulé. Deux voies :
  - (i) motif conditionné à la géométrie (« aucun résidu sur j = 0..J−2 ; la colonne J−1, seule à varier, n'entre pas dans la MSEP par D(5)(d)(ii) ») ;
  - (ii) réexamen du refus dans ce cas.
  - Avis d'`actuary`, puis décision du mainteneur. Dans le périmètre de #567 : aucune issue nouvelle n'est nécessaire.

### Remarques sans écart

- **R-1, (t1).** Il n'est émis qu'en l'absence d'erreur : mineur déjà écarté en T0 (critère aucun), rappelé pour mémoire.
- **R-2, (t4).** Seul min(I−i, J) est signalé comme convention de l'outil. Ĉ(i,J) = C(i,J) pour i < I−J, que D(4)(c) ne définit pas à la lettre, n'est dit qu'implicitement (« observees jusqu'a J, ne contribuent pas »).
  - Admis en T0. D(4)(c) qualifie Ĉ d'« estimation des sinistres cumulés » ; pour une cellule observée, la lecture naturelle est l'observation elle-même, comme pour i = I−J, où le produit est vide.
  - Rien de faux n'est prêté au texte. Critère : **aucun**. Si `docwriter` reprend la convention dans le `.tex`, il devra nommer les deux éléments (ADR, point 2).
- **R-3, numérotation.** « section D, point (2)(d) » et « paragraphe 4 » cohabitent (mineur déjà écarté en T0, critère aucun).

## 5. Constats hors périmètre (ADR 0018)

**Aucun.** m1 relève de #567. Le décalage du `.tex` est attendu à l'étape 8 de la même branche.

## 6. Retour

- **Statut : complet.** Chaque disposition du périmètre a un verdict : D(2)(b)-(e), D(3), D(4) et (c)-(d), D(5) et (b)-(d)(ii), G(1)-(3)(c), mélange, refus de R̂ ≤ 0, (t1)-(t4), chemin carré. Seule la documentation est renvoyée à l'étape 8.
- **Preuves.**
  - Formules lues à l'image : JOUE L 12/276-278 et 282 ; images 0, 2, 5, 13 et 14 de la version consolidée. *Vérifié.*
  - Correspondance avec le code, tête `1dc1888`. *Vérifié.*
  - Chiffres : moteur et transcription littérale indépendante, écart 0 sur cinq cas ; `identical()` sur le carré entre `main` et la tête ; m1 reproduit. *Vérifiés.*
- **Décision non résolue :** m1, reformulation du motif ou réexamen du refus (`actuary` puis mainteneur).
- **Critères déclenchés :** aucun nouveau ; ni σ_USP ni verdict ne change du fait de ce contrôle.
- **Prochaine action :** contrôle de conformité du diff `.tex` de `docwriter` à l'étape 8 : encadré `sec:mw`, `sec:controles` l. 5863, fiche `mw:m6sig` « par prescription », convention (B) avec ses deux éléments, limites (i) à (iv) de l'ADR.
- **Fichiers concernés :**
  - `R/engine.R` (l. 13107-13110, 13159-13407, 13412-13540, 13809-13822, 13856-13904, 14067-14126, 14263-14277, 16039-16049, 17243-17252, 17807, 17816, 18092, 18230, 18312)
  - `R/display_helpers.R` (l. 1909-2027, 2530-2550)
  - `app.R` (l. 405, 1327-1346, 1413-1446, 1480-1496)
  - `docs/latex/doc_tests_usp.tex` (l. 5863, 15850 et suivantes, fiche `mw:m6sig` : étape 8)
  - `docs/adr/0005-msep-reserve-2-formule-imprimee-d5.md` (annotation du 21/11/2026)

termine avec questions : m1, fondement et texte du motif #192 sur un trapèze, à porter à `actuary` puis au mainteneur.
