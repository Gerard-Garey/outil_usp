# Lecture ciblée de l'annexe XVII, sections D et G, pour un triangle trapèze I > J (S6, étape 1, #567)

> *Rédigé par l'agent regulatory (IA), effort `high`, le 20/11/2026.* Arbre lu : `claude/merz-wuthrich-trapeze`, tête `c181bf1`. Je n'ai rien écrit dans le dépôt : ni commit, ni issue, ni commentaire.
>
> *Note de versement (session principale) : rapport versé intégralement, tel que rendu. Le script de chiffrage cité au § 3 et dans « Fichiers concernés », écrit dans le répertoire de travail temporaire de la session, est versé à côté sous le nom `regulatory-1-trap.R` (contenu inchangé ; il se lance depuis la racine du dépôt).*

## 0. Résultat

Les lectures du 12/11 et du 13/11 sont **confirmées**, avec **une correction** et **un complément**.

- **Correction de la lecture du 12/11 (§ 1).** Celle-ci écrivait que l'écart entre la MSEP de 2015 et la MSEP consolidée « n'affecte pas la question de la géométrie ». C'est **inexact pour un trapèze**.
  - Dans la forme consolidée (k = i+1..I), la convention de la lecture (B) revient exactement à restreindre les sommes aux années i ≥ I−J+1.
  - Dans la forme de 2015 (k = 1..I, sans facteur 2), la même convention laisse des termes définis et non nuls, qui font entrer les années 1..I−J mais pas l'année 0.
  - Chiffrage sur un exemple au § 2, point 4. Constat *vérifié* : images des deux textes et Rscript.
- **Complément sur le vocabulaire.** D(2)(e) n'a qu'une lecture : il admet I ≥ J. L'alternative (A) / (B) porte sur la façon dont **D(4) et D(5)** traitent I > J, et non sur D(2)(e). Le titre de #567 (« lecture B de D(2)(e) ») est donc imprécis. C'est une précision de forme, utile pour l'annotation de l'ADR 0005 à D2.
- **Point 5, G(3)(c) :** la durée est **I + 1** (ni J + 1, ni I). Le « T de crédibilité (I + 1) » du plan est **confirmé**.
- **Point 4, D(5)(d)(ii) :** la règle de minimum vaut pour j = J−1 **sans condition sur I**. C'est la seule lecture de la lettre, confirmée à l'image dans les deux versions. `mw_ajuster()` l'applique déjà quel que soit I.
- **Point 3, D(4) :** le refus de R̂ ≤ 0 (M4, #7) se transpose sans changement. Sous (B), les années 0..I−J contribuent zéro à R̂.
- **Point 1, D(2)(c) :** il impose J + 1 ≥ 5. Aucune autre condition de dimension ne s'applique au trapèze. Le code est conforme.
- **Règlement 2026/269 :** il ne modifie ni l'annexe XVII (sections D et G), ni les art. 218 à 220, ni l'art. 19. Il n'agit que sur σ_(res,s) de D(4)(d), par les art. 117 et 148 (facteur NP, ADR 0019), ce qui est sans lien avec la géométrie.
- **Deux lectures subsistent** pour I > J : (A) refus, (B) extension. Je ne tranche pas : avis d'`actuary`, puis décision du mainteneur à D1' et D2.
- **Aucune issue créée ni proposée** : tout relève de #567.

## 1. Sources

- **Version consolidée du 14.11.2024** (référence de lecture), xhtml à la racine.
  - Texte courant de D(1) à D(5) et de G : extraits.
  - Formules de la section D décodées depuis le xhtml (15 images GIF) et lues **à l'image** : σ_USP, Ĉ(i,j), MSEP, les deux lignes de σ̂²_j.
  - La section D est placée sous ▼B (marqueurs précédents ▼B, ▼M1, ▼B ; aucun dans la section). G est placée sous ▼B.
- **JOUE L 12 du 17.1.2015** (`Règlement délégué.pdf`), pages rendues en image (110 ppp, et 400 ppp pour σ̂²_j) :
  - L 12/276 : D(1), D(2)(a) à (h)(ii) ;
  - L 12/277 : D(2)(h)(iii)-(iv), D(3), D(4) avec Ĉ et f̂, formule de la MSEP, D(5)(a)-(b) ;
  - L 12/278 : D(5)(c), (d), (d)(i), (d)(ii) ;
  - L 12/282 : section G, (1) à (3)(e).
  - Concordance : D(2), D(3), D(4) et D(5)(a)-(d) sont identiques dans les deux versions, texte et formules. Seule la formule de la MSEP diffère (ADR 0005, confirmé). G est identique.
- **Règlement délégué (UE) 2026/269** (`Règlement délégué 2026-269.pdf`, JO L du 18.2.2026), texte courant (pages du PDF) :
  - liste des annexes modifiées, points 131 à 148, p. 93 : l'annexe XVII du règlement 2015/35 n'y figure pas ;
  - art. 216-217, point 76, p. 54, puis art. 231, point 77, p. 55 : les art. 218 à 220 ne sont pas touchés ;
  - art. 18 et 20, points 4 et 5, p. 12 : l'art. 19 n'est pas touché ;
  - art. 148, point 39, p. 29 ;
  - date d'application : 30.1.2027, art. 2, p. 94.
- **Code lu** : `R/engine.R` (tête `c181bf1`).
  - En-tête de section : l. 13064-13076.
  - `mw_valider_triangle()` : l. 13126 ; D(2)(b) l. 13137-13139, D(2)(c) l. 13140-13142, MW-03 l. 13143-13144, MW-04 l. 13148-13154 ; avertissement de crédibilité l. 13340-13345.
  - `mw_ajuster()` : l. 13365 ; f̂ l. 13368-13373, σ̂² l. 13375-13382, règle de minimum l. 13411-13419, Ĉ l. 13422-13427, Q̂, S, S′ l. 13429-13436, `derniers` l. 13438, réserve l. 13443.
  - `mw_msep()` : l. 13732-13767.
  - `mw_valider_ajustement()` : R̂ ≤ 0, l. 13938-13943.
  - `mw_parametre()` : l. 14126, avec `T_cred` l. 14127.
- **Documentation lue** : `docs/latex/doc_tests_usp.tex` l. 5859-5870 (`sec:controles`), l. 15850-15873 (encadré « Restriction d'implémentation »), l. 18831 et suivantes (fiche `mw:m6sig`), l. 2698-2706, l. 15515. L'ADR 0005 a été lu avec ses annotations du 13/11 et du 13/11 (bis).

## 2. Matrice point par point

Abréviations : « eng. » = `R/engine.R` ; « tex » = `docs/latex/doc_tests_usp.tex`.

### Point 1 — D(2)(c) : J minimal et conditions de dimension

- **Texte (L 12/276 ; consolidé identique) :**
  - D(2)(b) : « les données sont disponibles pour cinq années d'accident consécutives au moins » ;
  - D(2)(c) : « pour la première année d'accident, des données sont disponibles pour cinq années de développement consécutives au moins ».
- **Lecture (une seule).**
  - On a J + 1 ≥ 5, donc J ≥ 4, et I + 1 ≥ 5.
  - Avec D(2)(e) (I ≥ J), ce sont les **seules** conditions de dimension. Aucun texte ne borne I − J, et il n'y a pas de borne supérieure.
  - Les formules exigent J ≥ 3 (existence de σ̂²_{J−3}) et I ≥ J−1 (diviseur I−j−1 ≥ 1 pour j ≤ J−2). Les deux découlent de D(2)(c) et de D(2)(e).
  - Le trapèze n'ajoute donc aucune condition. Un 8×5 (J = 4) est exactement au minimum de D(2)(c).
- **Code actuel.**
  - `ncol(tri) < T_min` → refus « D(2)(c) » (eng. l. 13140-13142), avec `T_min = 5` par défaut. Aucun appelant ne passe une autre valeur (*vérifié*, `grep`).
  - La complétude de la ligne 0 jusqu'à J est contrôlée par la boucle des cellules observées (i + j ≤ I).
  - tex l. 5861 : « J + 1 ≥ 5, D(2)(c) ».
- **Verdict : conforme.**
  - Remarque mineure, déjà faite pour MW-03 le 13/11 : le motif omet « consécutives ». La consécutivité tient à la structure matricielle : ce n'est pas un écart.
- **Conséquence pour un trapèze :** aucune. Le contrôle s'applique tel quel.
- **Statut :** *vérifié* (texte et image ; code).

### Point 2 — D(2)(e) : lecture (A) ou (B), état après #540

- **Texte (L 12/276 ; consolidé identique) :** « le nombre d'années d'accident consécutives pour lesquelles des données sont disponibles n'est pas inférieur au nombre d'années de développement consécutives de la première année d'accident pour laquelle des données sont disponibles ».
- **Lecture de D(2)(e) (une seule) :** I + 1 ≥ J + 1. Le trapèze est **expressément admis**.
  - D(3)(a) à (c) (L 12/277) définissent I et J séparément, et D(3)(c) fixe J sur la première année d'accident. Dans un trapèze, l'année 0 n'a donc pas de données au-delà de J, ce que D(2)(d) suppose complet.
- **Où naissent les deux lectures : dans D(4) et D(5), pas dans D(2)(e).**
  - Pour I > J, C(i,I−i) est indéfini si i < I−J (D(4), Ĉ de D(4)(c), MSEP).
  - Q̂_{I−i} est indéfini si 1 ≤ i ≤ I−J, puisque D(5)(d) ne définit Q̂_j que jusqu'à j = J−1.
  - L'année i = I−J joue dans le trapèze le rôle de l'année 0 du carré : Ĉ(I−J,J) = C(I−J,J), par le produit vide de D(4)(c), comme Ĉ(0,J) dans un carré. Mais elle entre dans les sommes de la MSEP, qui partent de i = 1, avec Q̂_J indéfini.
  - Ces constats du 12/11 sont **confirmés à l'image** (consolidé : images 0, 2, 5 et 13-14 de la section D ; JOUE : L 12/277-278).
- **Lecture (A)**, stricte : refus d'un triangle I > J. C'est la lecture retenue pour la remise (13/11 ; ADR 0005, annotations du 13/11 et du 13/11 (bis)).
- **Lecture (B)**, extensive : par convention, Ĉ(i,J) = C(i,J) et une contribution nulle à R̂ et à la MSEP pour i ≤ I−J. Elle est évaluée par S6 (Q-63-6 : un trapèze est prévu au dossier ; Q-71).
- **Code actuel.**
  - MW-04, émis si `I > J` (eng. l. 13148-13154). Le libellé correspond à la décision 2 du 13/11 et ne dit pas que le texte pose I = J.
  - L'en-tête (eng. l. 13064-13076), tex l. 5863-5870 et l'encadré tex l. 15850-15873 donnent une qualification exacte sous (A).
  - Le refus est aussi une garde technique : sur un trapèze, `mw_ajuster()` échouerait à `tri[i + 1, I - i + 1]` (eng. l. 13438, i < I−J, colonne > J+1), et `mw_msep()` lirait `Q[I - i + 1]` hors de la longueur J (NA).
- **Conséquence pour un trapèze :** (A) refus, (B) σ_USP rendu.
- **Verdict : deux lectures.** Je ne tranche pas : avis d'`actuary`, puis décision du mainteneur (D1', D2).
- **Statut :** *vérifié* pour le texte, le code et le refus (refus des 8×5, 8×6 et 8×7 par MW-04 seul, remesuré par Rscript ; motifs ci-dessous).

### Point 3 — D(4) : refus de R̂ ≤ 0 et effet d'un trapèze

- **Texte (L 12/277, lu à l'image ; consolidé identique, image 0) :** σ_(res,s,USP) = c·√MSEP / Σ_{i=0}^{I}(Ĉ(i,J) − C(i,I−i)) + (1 − c)·σ_(res,s).
  - Le texte ne pose aucune condition de signe sur le dénominateur.
- **Lecture.**
  - Le refus de R̂ ≤ 0 est une **interprétation déjà tranchée** (M4, #7 ; tex l. 4611 et suivantes), que je ne rouvre pas.
  - Pour un trapèze :
    - sous (A), il n'y a pas de calcul ;
    - sous (B), les termes i < I−J exigent la convention C(i,I−i) := C(i,J) (littéralement indéfini) et valent zéro, comme le terme i = I−J (Ĉ = C(I−J,J)). On a donc R̂ = Σ_{i=I−J+1}^{I}(Ĉ(i,J) − C(i,I−i)), avec des f̂_j estimés sur **toutes** les lignes.
  - Le refus garde le même fondement et le même énoncé. Le trapèze ne crée aucun cas de R̂ indéfini qui ne soit couvert par la convention de (B).
- **Code actuel.**
  - `mw_valider_ajustement()` (eng. l. 13938-13943) refuse R̂ ≤ 0 et R̂ non fini, avant `mw_parametre()` (eng. l. 14126-14141).
  - Le dénominateur vaut `aj$reserve` = Σ(ultimes − derniers) (eng. l. 13443).
- **Conséquence pour un trapèze (B) :** le refus est inchangé. Le calcul de `derniers` doit être borné à la colonne J, `tri[i+1, min(I−i, J)+1]`.
  - Hors texte (*hypothèse*, à voir par `actuary` et `audit`) : le refus du triangle totalement dégénéré (#192, `.mw_triangle_totalement_degenere()`) est à généraliser à la même géométrie.
  - Exemple (Rscript, script indépendant, convention (B)) : R̂ = 5 885,88 (8×5), 7 273,53 (8×6), 8 490,82 (8×7). Tous sont positifs.
- **Verdict : conforme**, pour le carré comme sous (B). L'interprétation M4 se transpose sans changement.
- **Statut :** *vérifié* (texte et image ; code). Valeurs : *vérifiées* par script hors moteur, sur des trapèzes illustratifs (§ 3).

### Point 4 — D(5)(d)(ii) et MSEP de D(5)

#### 4a — Règle de minimum pour σ̂²_{J−1}

- **Texte (L 12/278, lu à 400 ppp ; consolidé identique, images 13 et 14) :**
  - première ligne : σ̂²_j = 1/(I−j−1) · Σ_{i=0}^{I−j−1} C(i,j)(C(i,j+1)/C(i,j) − f̂_j)², pour « j = 0,…, (J – 2) » ;
  - seconde ligne : σ̂²_j = min(σ̂²_{J−2}, σ̂²_{J−3}, σ̂⁴_{J−2}/σ̂²_{J−3}), pour « j = (J – 1) ».
- **Lecture (une seule pour la lettre).**
  - Le domaine de chaque ligne est indexé sur J seul. La règle de minimum est **prescrite pour j = J−1 quel que soit I** (R-4 du 12/11, confirmé).
  - Pour I > J, la première ligne serait calculable avec I−J degrés de liberté. L'appliquer à j = J−1 serait un **écart à la lettre**.
  - Une lecture finaliste (la règle n'existerait que faute de degré de liberté quand I = J) s'éloigne du texte : ce n'est pas une seconde lecture de la lettre.
  - L'estimateur direct peut être restitué **pour information** (critère de #567, M6), à condition de ne pas entrer dans σ_USP.
- **Code actuel.**
  - `mw_ajuster()` applique la règle de minimum dès que J ≥ 3, **sans condition sur I** (eng. l. 13411-13413).
  - La première ligne tourne pour j = 0..J−2 sur les lignes 0..I−j−1 (eng. l. 13375-13382). La règle est donc respectée sous (B) sans changement de fond.
  - Le commentaire eng. l. 13416-13417 (« mw_valider_triangle impose T >= 5 et I = J, donc J >= 4 ») serait périmé sous (B) quant à « I = J ». J ≥ 4 reste acquis par D(2)(c), et la branche de repli reste inatteignable.
  - La fiche `mw:m6sig` (tex l. 18831 et suivantes) dit « faute de degré de liberté : sous la contrainte I = J ». C'est exact sous (A). Sous (B), elle doit dire que la règle s'applique **par prescription** (R-3 du 12/11).
- **Conséquence pour un trapèze.** Exemple (σ̂²_{J−1}, valeur de la règle / estimateur direct pour information) :
  - 8×5 : 0,684 / 0,315 ;
  - 8×6 : 0,142 / 0,097 ;
  - 8×7 : 0,0301 / 0,190.
  - La règle n'est donc pas toujours inférieure à l'estimateur direct. La lecture statistique revient à `actuary`.
- **Verdict : conforme.**
- **Statut :** *vérifié*.

#### 4b — Formule de la MSEP (ADR 0005)

- **Texte, version consolidée (image 5) :** MSEP = Σ_{i=1}^{I} Ĉ²(i,J)·(Q̂_{I−i}/C(i,I−i) + Q̂_{I−i}/S_{I−i} + Σ_{j=I−i+1}^{J−1} C(I−j,j)/S′_j · Q̂_j/S_j) + 2·Σ_{i=1}^{I} Σ_{k=i+1}^{I} Ĉ(i,J)·Ĉ(k,J)·(Q̂_{I−i}/S_{I−i} + Σ_{j=I−i+1}^{J−1} C(I−j,j)/S′_j · Q̂_j/S_j).
- **Texte, version de 2015 (L 12/277) :** pas de crochet dans la première somme (seul le terme Q̂_{I−i}/C(i,I−i)) ; double somme Σ_{i=1}^{I} Σ_{k=1}^{I}, sans facteur 2.
- **Lecture, et correction de la lecture du 12/11.**
  - Dans la **forme consolidée**, avec la convention (B) (Q̂_j := 0 pour j ≥ J ; Ĉ(i,J) := C(i,J) pour i ≤ I−J), les termes i ≤ I−J s'annulent. Les termes croisés pour i > I−J n'atteignent que k > i > I−J. La convention équivaut donc **exactement** à restreindre les sommes à i, k ∈ {I−J+1..I}.
  - Dans la **forme de 2015**, la double somme k = 1..I garde, pour i > I−J et 1 ≤ k ≤ I−J, des termes Ĉ(i,J)·Ĉ(k,J)·Δ_i définis et non nuls sous la même convention. Elle fait entrer les années **1..I−J** et exclut l'année 0 (borne k = 1), ce qui est arbitraire.
  - L'extension (B) n'a donc de forme naturelle que sur le texte consolidé. Sur le texte de 2015, qui seul fait foi, il faudrait une convention de plus, sur k.
  - La phrase du 12/11, § 1 (« Cette différence n'affecte pas la question de la géométrie ») est à corriger dans ce sens.
- **Code actuel.**
  - `mw_msep()` (eng. l. 13732-13767) transcrit la forme consolidée, terme à terme, pour I = J. C'est conforme sous l'ADR 0005.
  - Contrôle : sur le carré 8×8, mon script redonne la MSEP de `mw_msep()` à l'identique (écart relatif 0).
- **Conséquence pour un trapèze.** Exemple (σ estimé = √MSEP / R̂, convention (B)) :

| Trapèze | Consolidé | 2015 avec k = 1..I | 2015 restreinte à i, k ≥ I−J+1 |
|---|---|---|---|
| 8×5 | 0,021331 | 0,024817 (+16,3 %) | 0,021338 |
| 8×6 | 0,018101 | 0,021056 (+16,3 %) | 0,019204 |
| 8×7 | 0,016621 | 0,019265 (+15,9 %) | 0,018461 |

  - Sur le carré 8×8, l'écart propre aux deux versions est déjà de +7,3 % (0,023415 contre 0,021825).
  - La part due aux années 1..I−J dans la forme de 2015 se lit en comparant les deux dernières colonnes : +16,3 % (8×5), +9,6 % (8×6), +4,4 % (8×7).
- **Verdict.**
  - **Conforme** pour le carré (ADR 0005).
  - Pour le trapèze, **deux lectures** (point 2), et un **constat nouveau** à porter dans l'annotation de l'ADR 0005 à D2 : la convention (B) se formule sur le texte consolidé, et ne se transpose pas à la forme de 2015 sans convention de plus sur k.
- **Statut :** *vérifié* (images ; script hors moteur, validé sur le carré contre `mw_msep()`). L'égalité de la MSEP restreinte avec l'erreur à un an de Merz-Wüthrich sur un trapèze reste *non vérifiée* (`actuary`, 2a (i)).

### Point 5 — G(3)(c) : durée retenue pour la crédibilité

- **Texte (L 12/282 ; consolidé identique, ▼B) :** « La durée correspond: […] (c) pour la méthode du risque de réserve n° 2, au nombre d'années d'accident pour lesquelles des données sont disponibles ». Barèmes G(1) et G(2), de 5 ans à « 15 et plus » et à « 10 et plus ».
- **Lecture (une seule) : durée = I + 1.**
  - D(3)(a)-(b) numérote les années d'accident de 0 à I, I étant « la dernière année d'accident pour laquelle des données sont disponibles ». D(2)(b) emploie la même locution. Le nombre d'années d'accident est donc I + 1.
  - Ce n'est **pas J + 1**, qui est un nombre d'années de développement, ni **I**, qui est un indice.
  - Le « T de crédibilité (I + 1) » du plan (étape 2a (iv)) est **confirmé**.
- **Code actuel.**
  - `T_cred <- aj$I + 1L` (eng. l. 14127), avec `aj$I = nrow(tri) − 1` (eng. l. 13366).
  - L'avertissement de crédibilité partielle porte sur `nrow(tri)` (eng. l. 13340-13345).
  - tex l. 2702, 5950 et 15515 : « durée I + 1 (G(3)(c)) ».
- **Conséquence pour un trapèze (B) :** la durée vaut I + 1 et le code n'a rien à changer.
  - Exemple, 8×J : c(8) = 0,81 au barème court, 0,59 au barème long.
  - Pour comparaison, le contournement de (A) (tronquer au carré J+1 × J+1) donnerait c(5) = 0,34 (8×5), c(6) = 0,51 / 0,43 (8×6), c(7) = 0,67 / 0,51 (8×7).
- **Verdict : conforme.**
  - **Remarque R-5**, sans écart : sous (A), une entreprise qui tronque son trapèze fait calculer la durée sur les lignes saisies, alors que G(3)(c) parle des années « pour lesquelles des données sont disponibles ». Dans la section D, cette locution définit I (D(3)(b)), ce qui fonde la pratique de l'outil. Mais la troncature réduit c, ce qui s'ajoute à la justification requise par l'art. 219(1)(a) / 19(1)(b). La remarque tombe sous (B).
- **Statut :** *vérifié*.

### Point transversal — règlement 2026/269 (applicable au 30.1.2027)

- **Texte :**
  - points 131 à 148 (p. 93) : l'annexe XVII de 2015/35 n'est pas modifiée (le point 147 vise l'annexe XXV) ;
  - point 76 (p. 54), art. 216-217, puis point 77 (p. 55), art. 231 : les art. 218 à 220 ne sont pas modifiés ;
  - points 4 et 5 (p. 12), art. 18 et 20 : l'art. 19 n'est pas modifié ;
  - point 39 (p. 29), art. 148 : facteur NP sur σ(res,s) en santé non-SLT.
- **Lecture :** aucun des points 1 à 5 n'est touché. Seul σ_(res,s) de D(4)(d) dépend du texte applicable, par les art. 117 et 148 (ADR 0019, `TEXTES_APPLICABLES`), et cela vaut quelle que soit la géométrie.
- **Code :** déjà traité (ADR 0019, #504).
- **Verdict : conforme**, sans conséquence pour un trapèze.
- **Statut :** *vérifié* par le texte courant ; formules sans objet.

## 3. Mesures (Rscript, lecture seule)

- **Script :** `trap.R` dans le répertoire de travail temporaire de la session (versé ici sous `regulatory-1-trap.R`). Il charge le moteur par `charger_moteur()` et calcule à part, hors moteur : f̂, σ̂² (règle de minimum et estimateur direct), Q̂, S, S′, Ĉ, R̂ et les trois formes de la MSEP sous la convention (B).
- **Contrôle :** sur le carré `tests/donnees/triangle_mw.csv` (8×8), la MSEP du script est égale à `mw_msep()` (39 798,0296160152 des deux côtés).
- **Trapèzes :** 8×5, 8×6 et 8×7, obtenus en retirant les dernières colonnes du 8×8. Ils sont **illustratifs** : D(2)(d) n'y est pas jugé (en 8×7, la cellule (0,7) est retirée).
- **`mw_valider_triangle()`** sur ces trois trapèzes : `ok = FALSE`, avec le seul motif « Triangle non carre (8 annees d'accident, … ».
- Lancé sous `LC_ALL=C.UTF-8`.

## 4. Conséquences pour la suite de S6

Elles ne sont pas des constats d'écart : ce sont les points de conformité à reprendre si D1' engage la généralisation, puis si D2 étend le calcul.

1. **Spécification 2a (i) et annotation de l'ADR 0005 à D2.**
   - Formuler la convention (B) sur le texte consolidé, en restreignant les sommes de la MSEP et de R̂ aux années I−J+1..I. Écrire qu'elle équivaut à « Q̂_j := 0 pour j ≥ J, Ĉ(i,J) := C(i,J) pour i ≤ I−J » **dans la forme consolidée seulement**.
   - Écrire aussi qu'elle ne se transpose pas à la forme de 2015 sans convention de plus sur k (point 4b).
   - Dire « années ayant atteint l'année de développement J », et non « entièrement développées » (correction du 13/11, confirmée).
2. **Garder la règle de minimum** pour j = J−1 (eng. l. 13411-13413, inchangé). L'estimateur direct est restitué pour information seulement.
3. **Garder `T_cred = I + 1`** (eng. l. 14127, inchangé) ; l'application lit `duree_credibilite`.
4. **Garder le refus de R̂ ≤ 0** (eng. l. 13938-13943, inchangé). Borner `derniers` à la colonne J (eng. l. 13438). Dans `mw_msep()`, ne lire ni `Q[I − i + 1]` ni `S[I − i + 1]` au-delà de J−1.
5. **Textes à reprendre si D2 étend :**
   - en-tête eng. l. 13064-13076 ;
   - commentaire eng. l. 13416-13417 ;
   - motif MW-04, eng. l. 13148-13154 (retiré si la garde est levée) ;
   - tex l. 5863-5870 et 15850-15873 ;
   - fiche `mw:m6sig` (R-3 : « par prescription ») ;
   - titre de #567 : (B) est une lecture de D(4) et D(5), D(2)(e) admettant le trapèze sans ambiguïté. Ce point est de forme.

## 5. Constats hors périmètre (ADR 0018)

**Aucun.** Tous les constats relèvent de #567.

Mineur rappelé pour mémoire, déjà consigné le 13/11 : le motif D(2)(c) omet « consécutives » (eng. l. 13141). Critère : **aucun** (abrègement exact, la consécutivité tient à la structure). Preuve : D(2)(c), L 12/276.

## 6. Synthèse courte

- **Points 1, 3, 4a, 5 : conformes.**
  - D(2)(c) impose J ≥ 4, sans autre condition de dimension.
  - Le refus de R̂ ≤ 0 se transpose sans changement.
  - La règle de minimum est prescrite pour j = J−1 quel que soit I, et le code l'applique déjà.
  - La durée de G(3)(c) est **I + 1**, ce qui confirme le plan.
- **Point 2 : deux lectures**, (A) refus et (B) extension. Je ne tranche pas.
  - Elles portent sur D(4) et D(5). D(2)(e) admet le trapèze sans ambiguïté.
- **Point 4b : correction de la lecture du 12/11.** L'écart entre la MSEP de 2015 et la MSEP consolidée compte pour le trapèze.
  - La convention (B) n'équivaut à la restriction des sommes aux années I−J+1..I que dans la forme consolidée.
  - Dans la forme de 2015, la même convention laisse entrer les années 1..I−J, soit +4 % à +16 % sur σ estimé dans l'exemple.
  - À porter dans l'annotation de l'ADR 0005 à D2.
- **Règlement 2026/269 :** sans effet sur ces points.
- **Aucune issue.**

## Retour

- **Statut : complet.**
- **Preuves.**
  - D(2), D(3), D(4) et D(5), dans la version consolidée (images du xhtml) et au JOUE L 12/276-278 (rendu en image, σ̂²_j à 400 ppp) : *vérifié*.
  - G, dans la version consolidée et au JOUE L 12/282 : *vérifié*.
  - Règlement 2026/269 : *vérifié* par le texte courant (pp. 12, 29, 54-55, 93, 94).
  - Correspondance avec le code (tête `c181bf1`) : *vérifié*.
  - Chiffrage par script hors moteur, validé contre `mw_msep()` sur le 8×8 : *vérifié*.
  - Validité de la MSEP restreinte comme erreur à un an de Merz-Wüthrich sur un trapèze : *non vérifié*, renvoyé à `actuary` (2a (i)).
- **Décision non résolue :** (A) ou (B), à D1' puis D2, après avis d'`actuary`. Le choix de la forme de la convention (B), et la mention de la limite propre à la forme de 2015 dans l'ADR 0005, reviennent à `architect` et au mainteneur à D2.
- **Critères déclenchés :** lecture à deux sens, donc circuit 2 (`actuary` éclaire, le mainteneur tranche). Fable n'est pas requis par cette lecture. σ_USP ne change que sous (B), et seulement pour des triangles aujourd'hui refusés.
- **Fichiers concernés :**
  - `R/engine.R` (l. 13064-13076, 13126-13154, 13340-13345, 13365-13443, 13732-13767, 13938-13943, 14126-14141)
  - `docs/latex/doc_tests_usp.tex` (l. 2702, 5859-5870, 15850-15873, 18831 et suivantes)
  - `docs/adr/0005-msep-reserve-2-formule-imprimee-d5.md`
  - `docs/revues/20261112-lecture-d2e-540/regulatory-lecture-d2e-d4-d5.md` (§ 1, phrase corrigée au point 4b)
  - `regulatory-1-trap.R` (script de chiffrage, versé à côté)
