# Validation réglementaire K2 : année de développement 0 (refus de la colonne vide au bord gauche)

> *Rédigé par l'agent regulatory (IA).* Branche `claude/fichiers-et-point-decimal`, tête `3653a8d`. Moteur : `.retirer_lignes_colonnes_vides()` dans `/home/user/outil_usp/R/engine.R`, l. 7765-7778 (commit `1dae258`, Refs #520). Documentation : `/home/user/outil_usp/docs/latex/doc_tests_usp.tex`, l. 3848-3861. Je n'ai rien écrit dans le dépôt.

## 0. Résultat

- **Le refus lui-même est conforme.** Le texte ne l'interdit pas, et il protège contre l'une des deux lectures, qui ne remplit pas D(1).
- **La documentation actuelle présente un écart.** « refusée de même » rattache le refus à D(2)(c) et à D(3)(c), comme dans la phrase précédente. D(2)(c) ne le fonde pas, et D(3)(c) ne fonde aucun refus : c'est une règle de notation.
- **La décision du mainteneur est défendable**, à une condition de rédaction. On peut ancrer le refus dans D(1) lu avec A(1)(b), mais en écrivant « se rattache à ». Le mot « fondé sur » sans réserve ne convient pas : le texte ne fonde le refus que dans la lecture où la colonne vide est l'année de développement 0.
- **Aucune issue n'est proposée.** Le code n'est pas en écart avec le texte, et la correction de la documentation relève de la branche en cours (`docwriter`).

## 1. Sources consultées

- **Version consolidée du 14.11.2024** (référence de lecture), annexe XVII, sections A et D. Les deux sections sont sous ▼B, sans marqueur de modification. J'ai extrait le texte courant. J'ai lu en rendu graphique les formules de D(4) et D(5) : images décodées du xhtml, f̂_j, Ĉ(i,j), S_j, σ̂²_j et son extrapolation, MSEP.
- **JOUE L 12 du 17.1.2015** (`Règlement délégué.pdf`) :
  - A(1) est en page L 12/272.
  - D(1) à D(2)(h)(ii) sont en page L 12/276.
  - D(2)(h)(iii) à D(5)(b) sont en page L 12/277.
  - D(5)(c) et (d) sont en page L 12/278.
  - J'ai lu les pages 277 et 278 en rendu graphique.
- **Concordance entre les deux versions.** Pour A(1)(b), D(1), D(2) et D(3), le texte est identique mot pour mot. Les formules de D(4) et D(5)(b) à (d) qui servent ici sont les mêmes ; seule la MSEP de D(5) diffère, ce que l'ADR 0005 a déjà traité et qui n'a pas d'effet ici.

## 2. Matrice paragraphe → texte → lecture → conformité

| Paragraphe | Texte (consolidé = JOUE) | Lecture sur l'année de développement 0 | Verdict pour le refus au bord gauche |
|---|---|---|---|
| **A(1)(b)** (L 12/272) | « "année de développement", en ce qui concerne le paiement d'un sinistre d'assurance ou de réassurance, la différence entre l'année de ce paiement et l'année de l'accident auquel il correspond » | L'année de développement est une différence d'années civiles, pas un rang. Un paiement fait dans l'année même de l'accident relève de l'année de développement 0. L'année 0 fait donc partie des années de développement des paiements dès qu'un paiement intervient dans l'année de l'accident. | **Fondement partiel**, avec D(1) |
| **D(1)** (L 12/276) | « […] montants de paiements cumulés […] (montants de sinistres cumulés), indiqués séparément pour chaque année d'accident et chaque année de développement des paiements. » | Lu avec A(1)(b), « chaque année de développement des paiements » comprend l'année 0. Un triangle sans montant pour l'année 0 ne fournit pas les données que décrit D(1). D(1) ne fixe aucun nombre de colonnes ni aucun format de fichier : il dit ce que les données doivent contenir, pas comment repérer une colonne. | **Interprétation** : ancrage possible, valable dans une seule des deux lectures (§ 3) |
| **D(2)(b)** | « […] disponibles pour cinq années d'accident consécutives au moins » | Ne dit rien sur l'année de développement. | Sans objet |
| **D(2)(c)** | « pour la première année d'accident, des données sont disponibles pour cinq années de développement consécutives au moins » | C'est un minimum de cinq années consécutives, quelle que soit la première. Il n'exige ni de commencer à 0 ni que toutes les années soient consécutives. Dans les deux lectures du fichier, les années renseignées restent consécutives (0 à 6, ou 1 à 7) et sont au moins cinq. | **Ne fonde pas le refus.** Le citer serait un **écart** de la documentation. |
| **D(2)(e)** | nombre d'années d'accident consécutives ≥ nombre d'années de développement consécutives de la première année d'accident | Remplie dans les deux lectures (7 ≥ 7). | Sans objet, ne fonde pas le refus |
| **D(3)(a)** (L 12/277) | « les années d'accident sont représentées par des nombres consécutifs, commençant par 0 pour la première année d'accident pour laquelle des données sont disponibles » | Seules les années d'accident sont **renumérotées** à partir de 0. D(3) ne renumérote pas les années de développement, qui gardent donc le sens de A(1)(b). | Corrobore la lecture de A(1)(b), sans fonder le refus |
| **D(3)(b), (c)** | « I représente la dernière année d'accident pour laquelle des données sont disponibles » ; « J représente l'année de développement la plus récente de la première année d'accident pour laquelle des données sont disponibles » | Ce sont des règles de **notation** (« Aux fins des paragraphes 4 et 5 »). L'ambiguïté du fichier rend J indéterminé (6 ou 7). C'est la conséquence de l'ambiguïté, pas une exigence. | **Ne fonde pas le refus** ; ne pas le citer comme fondement |
| **D(3)(d)** | « C(i,j) représente les sinistres cumulés pour l'année d'accident i et l'année de développement j » | j est l'année de développement au sens de A(1)(b) : j = 0 désigne les paiements de l'année de l'accident. | Corrobore |
| **D(4)**, **D(4)(c)** et **D(5)** (lus en rendu graphique, L 12/277-278) | Somme Σ_{i=0}^{I} (Ĉ(i,J) − C(i,I−i)) ; Ĉ(i,j) = C(i,I−i) f̂_{I−i} ⋯ f̂_{j−1} ; f̂_j = Σ_{i=0}^{I−j−1} C(i,j+1) / Σ_{i=0}^{I−j−1} C(i,j) ; S_j = Σ_{i=0}^{I−j−1} C(i,j) ; σ̂²_j pour « j = 0,…,(J – 2) » ; MSEP avec Q̂_{I−i}/C(i,I−i) pour i = 1..I | La dernière diagonale est i + j = I. Pour i = I, elle désigne C(I,0). Les formules supposent donc C(i,0) et f̂_0, ce qui suppose que les colonnes commencent à l'année de développement 0. | **Corrobore fortement** la lecture de D(1) avec A(1)(b). Ce n'est pas l'ancrage décidé : option au § 5, D2. |

### Les deux lectures du même fichier, sans colonne `i`

- **Lecture 1 : tableau décalé d'une colonne.** Le fichier contient 7 années d'accident et les années de développement 0 à 6, posées une colonne trop à droite.
  - D(1), D(2)(b), D(2)(c) et D(2)(e) sont remplis, avec I = J = 6.
  - Le texte **n'exige pas** de refus. Le refus n'est ici qu'une précaution de l'outil.
- **Lecture 2 : triangle 8 × 8 dont la colonne 0 est vide.**
  - Aucun montant n'est indiqué pour l'année de développement 0, pour aucune année d'accident. D(1) lu avec A(1)(b) n'est **pas rempli**.
  - La dernière année d'accident, dont la seule cellule est C(7,0), n'a aucune donnée : sa ligne vide de fin est retirée.
  - Les formules de D(4) et D(5), qui lisent la diagonale C(i,I−i), ne s'appliquent pas à la lettre.
  - Le refus est alors fondé sur le texte.

## 3. Ce que le texte permet d'écrire, et ce qu'il ne permet pas

**Le texte permet d'écrire :**
- « se rattache à D(1), lu avec A(1)(b) », ou une formule équivalente, avec la condition explicite : le refus est fondé si la colonne vide est l'année de développement 0, et c'est une précaution si le tableau est décalé ;
- « précaution de l'outil, qui ne peut pas déterminer l'année de développement de chaque colonne » : c'est la proposition d'`actuary`, et elle est exacte ;
- l'étiquette « lecture retenue par l'outil » (CONVENTIONS, ligne 11 du tableau, et § « Formules réglementaires »).

**Le texte ne permet pas d'écrire :**
- « fondé sur D(1) lu avec A(1)(b) » sans réserve, ou « exigé par D(1) » : c'est faux dans la lecture 1 ;
- tout fondement sur **D(2)(c)** : la consécutivité est préservée dans les deux lectures ;
- un fondement sur **D(2)(e)** ou **D(2)(b)** ;
- un fondement sur **D(3)(c)** : c'est une règle de notation ;
- « de même » renvoyant à la parenthèse « (D(1), D(2)(c) et D(3)(c) […]) » de la phrase précédente, puisque cela importe ces deux références à tort. **C'est l'écart actuel.**

« Cohérent avec D(1) » serait exact mais trop faible : dans la lecture 2, le texte fonde réellement le refus. « Se rattache à », assorti de la condition, est la formule juste.

## 4. Texte LaTeX proposé

Il remplace, aux l. 3848-3861, le passage qui va de « Au bord gauche, » à « est refusée (mesuré). » inclus. La phrase suivante, « La fonction appelle ensuite \code{mw\_valider\_triangle()}. », est inchangée.

Les faits descriptifs de `docwriter` sont conservés : motif, numérotation par position, exception de la colonne `i`, mesure. J'ai vérifié que les deux fragments de motif cités sont exacts au regard de `R/engine.R`, l. 7776-7778. Rien ne relève de la vie du dépôt.

```latex
Au bord gauche,
une colonne vide sans en-tête placée avant la première colonne de développement renseignée, autre
que la colonne \code{i}, est refusée, avec ou sans colonne \code{i}, comme année de
développement~0 manquante présumée (motif «~\code{\ldots{} sans en-tete avant la premiere colonne
renseignee du triangle}~» suivi de «~\code{annee de developpement 0 manquante presumee}~», qui la
numérote par sa position dans le tableau lu, colonne \code{i} comprise). Ce refus est une
précaution de l'outil, qui ne peut pas déterminer l'année de développement de chaque colonne~:
sans colonne \code{i}, un tableau décalé d'une colonne a les mêmes cellules qu'un triangle dont la
colonne~0 est vide, et l'outil ne choisit pas entre les deux lectures. Il se rattache à
l'annexe~XVII, D(1), lu avec A(1)(b)~: l'année de développement d'un paiement étant «~la
différence entre l'année de ce paiement et l'année de l'accident auquel il correspond~»
(A(1)(b)), les paiements de l'année de l'accident relèvent de l'année de développement~0, et un
triangle dont cette colonne est vide n'indique pas les montants que D(1) demande «~pour chaque
année d'accident et chaque année de développement des paiements~». Un tableau décalé, dont la
première colonne renseignée est l'année de développement~0, satisfait au contraire D(1) sur ce
point~: son refus relève de la seule précaution (lecture retenue par l'outil). D(2)(c) n'est pas
en cause, les années de développement renseignées restant consécutives dans l'une et l'autre
lecture. Seule exception, une colonne vide placée avant la colonne \code{i}, quand celle-ci
précède elle-même les données, est retirée sans message (tableau décalé, qui se reconnaît à sa
colonne \code{i})~; une colonne vide placée entre la colonne \code{i} et les données, ou à gauche
quand la colonne \code{i} suit les données, est refusée (mesuré).
```

Notes de forme :
- La graphie « D(1) », « A(1)(b) », « D(2)(c) » est celle du document (voir par exemple l. 3531, 4669 et 16383).
- « l'annexe~XVII » n'est posé qu'une fois, à la première référence.
- Les espaces insécables `~` sont mis avant les deux-points et à l'intérieur des guillemets français, comme dans le reste du document.
- Les deux citations entre guillemets reproduisent la lettre de A(1)(b) et de D(1), identique dans le consolidé et le JOUE.
- Le passage ne touche aucune ligne `\reglement` ni aucun encadré d'énoncé.

## 5. Statut et décisions renvoyées au mainteneur

- **Statut** : interprétation. Le refus est conforme, la documentation actuelle est en écart, et le texte du § 4 la corrige dans la ligne de la décision du mainteneur. `actuary` a validé le fond ; le circuit 4 revient à `docwriter` pour reporter le texte.
- **D1 (déjà tranchée, rappelée pour mémoire).** Le texte admet deux lectures du fichier, et l'ancrage dans D(1) lu avec A(1)(b) ne vaut que dans l'une. La décision du mainteneur est compatible avec le texte, à condition de garder la formule conditionnelle du § 4.
- **D2 (facultative, à trancher par le mainteneur avec `actuary`) : ajouter D(3)(d) et D(4) comme appui.** Cela consisterait à ajouter, après la citation de D(1) : « les formules de D(4) et D(5), qui lisent la dernière diagonale C(i,I−i), dont C(I,0), supposent elles aussi des colonnes qui commencent à l'année de développement~0 ».
  - Pour : c'est l'appui textuel le plus fort.
  - Contre : la décision du mainteneur a retenu le seul ancrage dans D(1), et l'ajout allonge le paragraphe.
  - Je ne l'ai pas intégré au texte proposé.

## 6. Autres citations de l'annexe XVII dans le diff `.tex` de la branche

J'ai lu `git diff origin/main...HEAD -- docs/latex/doc_tests_usp.tex` en entier.

- **Lignes ajoutées ou modifiées** : la seule citation de l'annexe XVII est celle des l. 3848-3861, traitée ci-dessus. La mention ajoutée dans l'index des fonctions, « (année de développement~0 manquante présumée) », vers la l. 842, ne cite aucun texte : elle est conforme.
- **Lignes de contexte, inchangées et venues de `main`, signalées pour mémoire sans constat bloquant :**
  - **l. 3846, « ligne vide intercalée ou en tête […] (D(2)(b)) ».** D(2)(b) n'exige que cinq années consécutives au moins ; c'est D(3)(a) qui exige des années d'accident numérotées consécutivement.
  - **l. 3846-3849, « (D(1), D(2)(c) et D(3)(c) […] ; la présomption est une lecture retenue par l'outil) ».** Pour une colonne intercalée, D(2)(c) ne vise que cinq années consécutives au minimum. Le rattachement est déjà présenté comme une lecture retenue par l'outil, ce que permet CONVENTIONS.
  - Pour ces deux points, D(4)(c), qui relie j à j + 1, serait un appui plus juste. C'est une **interprétation**, hors du périmètre de la branche : je ne propose pas d'issue, sauf si le mainteneur souhaite revoir ces ancrages lors de la revue `regulatory` d'avant remise.

## 7. Fichiers

- `/home/user/outil_usp/docs/latex/doc_tests_usp.tex` (l. 3836-3866)
- `/home/user/outil_usp/R/engine.R` (l. 7765-7782)
- `/home/user/outil_usp/TEXTE consolidé_ 32015R0035 — FR — 14.11.2024.xhtml` (annexe XVII, sections A et D)
- `/home/user/outil_usp/Règlement délégué.pdf` (pages L 12/272, 276, 277 et 278)
