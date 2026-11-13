# K3b, lecture ciblée de l'annexe XVII D(2)(b) et D(3)(a) pour le motif V5 (#555)

> *Rapport de l'agent regulatory (IA), effort `medium`, rendu le 12/11/2026 à la session principale, sur demande de l'avis amont d'`actuary` (§ 8).* Versé intégralement par la session principale (Refs #555). Branche lue : `claude/registre-restes`, tête `b5cb496`. L'agent n'a rien écrit dans le dépôt et n'a créé aucune issue.

## Sources

- **Version consolidée** (`TEXTE consolidé_ 32015R0035 — FR — 14.11.2024.xhtml`, référence de lecture), annexe XVII, section D, (1), (2)(b), (2)(e), (3)(a) à (d). Section A, (1)(a) et (b), pour les définitions d'« année d'accident » et d'« année de développement ».
- **JOUE L 12 du 17.1.2015** (`Règlement délégué.pdf`) : pages imprimées L 12/276, pour D(1) et D(2), et L 12/277, pour D(3). Ces passages sont du texte courant, sans formule, donc l'extraction de texte est admise. Le libellé est identique mot pour mot à celui du consolidé, sans aucune marque de modification sur ces points.

Textes cités :
- **D(1)** : « montants de paiements cumulés […] indiqués séparément pour chaque année d'accident et chaque année de développement des paiements ».
- **D(2)(b)** : « les données sont disponibles pour cinq années d'accident consécutives au moins ».
- **D(2)(e)** : « le nombre d'années d'accident consécutives pour lesquelles des données sont disponibles n'est pas inférieur au nombre d'années de développement consécutives de la première année d'accident […] ».
- **D(3)** : « Aux fins des paragraphes 4 et 5, les règles de notation suivantes s'appliquent :
  - (a) les années d'accident sont représentées par des nombres consécutifs, commençant par 0 pour la première année d'accident pour laquelle des données sont disponibles ;
  - (b) I représente la dernière année d'accident pour laquelle des données sont disponibles ;
  - (c) J représente l'année de développement la plus récente de la première année d'accident […] ;
  - (d) C(i,j) […] ».

## Matrice

| # | Texte | Lecture | Verdict |
|---|---|---|---|
| 1 | D(2)(b) | C'est une **exigence de profondeur minimale** : il faut au moins une suite de cinq années d'accident consécutives. Le texte n'interdit pas un trou en tant que tel. Exemple : `i` = 0, 1, 2, 3, 4, 5, 7 contient six années consécutives, donc respecte D(2)(b) à la lettre. Ce point ne fonde donc pas, à lui seul, le refus d'un écart dans `i`. Il ne le fonde que lorsque le trou empêche toute suite de 5 (ex. 0 à 3 puis 5 à 8). | **Interprétation** si V5 cite D(2)(b) seul. Ancrage inexact. |
| 1 bis | D(2)(e) | C'est aussi une condition de nombre, posée sur des années consécutives. Elle n'interdit pas non plus un trou. | Ne fonde pas V5. |
| 1 ter | D(1), avec D(3)(a)-(b) et la structure de D(4)-(5) | Trois éléments, pris ensemble, présupposent un triangle sans année manquante : les données sont fournies « pour chaque année d'accident » ; les années disponibles sont numérotées par des nombres consécutifs de 0 à I ; les formules de D(4)-(5) sont indexées sur i = 0..I, et la diagonale i + j relie chaque cellule à un exercice. Un trou casse cette correspondance : la ligne numérotée k ne serait plus l'année « première + k », et l'année de développement définie en A(1)(b) serait faussée sur la diagonale. Le refus est donc **justifié par la structure du triangle de la section D**. Aucune phrase du texte ne dit « les années doivent être consécutives » : c'est une lecture, cohérente et défendable, retenue par l'outil. | **Interprétation**, à trancher par le mainteneur. Ancrage recommandé, présenté comme une présomption de l'outil. |
| 2 | Phrase du moteur « l'annexe XVII, D(2)(b), exige des annees d'accident consecutives » | Ce n'est **pas une citation exacte**. C'est une lecture abrégée qui omet « cinq […] au moins » et transforme une condition de profondeur en interdiction de tout trou. Sites : `R/engine.R` l. 7791 (au moment de la lecture), reprise dans les deux motifs des lignes vides, tête et intercalée, plus le commentaire vers la l. 7676. Le même défaut existe pour les séries : l. 7790 et l. 7946, qui citent « B(2)(b) et C(2)(b), exige des annees consecutives » pour un trou dans la colonne `t` ou une ligne vide. Or C(2)(b) dit « cinq exercices consécutifs au moins », et B(3)(a) et C(3)(a) sont les notations « commençant par 1 ». Côté documentation : `docs/latex/doc_tests_usp.tex` l. 3879 ; à l'inverse, l. 3882 qualifie déjà la présomption de « lecture retenue par l'outil » pour les colonnes. Le motif l. 9850 (« D(2)(b) : au moins %d annees d'accident consecutives (%d fournies) ») est, lui, **fidèle**. | **Écart de citation**, sans effet sur un chiffre : aucun σ_USP ni aucun verdict n'est touché. Hors périmètre : texte d'issue proposé ci-dessous. |
| 3 | D(3)(a) | C'est une **règle de notation** (« Aux fins des paragraphes 4 et 5 »). Elle ne contraint pas les valeurs de la colonne `i` du fichier : un départ à 0, à 1, à une année civile ou à une valeur négative reste compatible, puisque l'outil renumérote de 0 à I en interne. Elle a pourtant un contenu sur les trous : elle numérote *consécutivement les années disponibles* et définit I comme la dernière disponible. Elle n'a donc de sens, avec D(4)-(5), que si ces années se suivent. Elle peut servir d'appui à V5 (ligne 1 ter), mais pas comme obligation autonome. | **Conforme** à la règle retenue par le mainteneur, avec départ libre. |
| 4 | Motif V5 | L'ancrage proposé par `actuary` (« D(2)(b) exige des annees d'accident consecutives ») reproduit l'écart du point 2. Il faut le remplacer : voir ci-dessous. | **Écart** dans le texte proposé. Correction proposée. |

## Point 4 : texte du motif V5

**Recommandé** (ancré, sans accents, `%s` pour les paires « k-1 et k ») :

`Colonne i non consecutive (entre les lignes de donnees %s) : annee d'accident manquante presumee ; le triangle de l'annexe XVII, section D, porte les montants de chaque annee d'accident, numerotees par des nombres consecutifs de 0 a I (D(1), D(3)(a) et (b)). Renseigner l'annee d'accident manquante, ou corriger la colonne i.`

Chaque élément de l'ancrage est littéral : « chaque année d'accident » vient de D(1), « nombres consécutifs » et « commençant par 0 » de D(3)(a), « I » de D(3)(b). La présomption est attribuée à l'outil par le mot « presumee ».

**Variante sans ancrage**, si le mainteneur préfère ne citer aucun texte pour un contrôle de cohérence propre à l'outil :

`Colonne i non consecutive (entre les lignes de donnees %s) : annee d'accident manquante presumee ; le triangle exige une ligne par annee d'accident, sans annee manquante. Renseigner l'annee d'accident manquante, ou corriger la colonne i.`

Ne pas citer D(2)(b) dans V5. Ce point ne s'appliquerait qu'en complément, lorsque le trou laisse moins de cinq années consécutives, et ce cas est déjà couvert par le motif l. 9850.

## Issue proposée (point 2 ; soumise au mainteneur par la session, non créée)

**Titre** : `Motifs de lecture : l'annexe XVII, (2)(b), cité comme exigeant des années consécutives, au lieu de cinq années consécutives au moins`
**Libellés** : `bug`, `needs-triage`

**Corps** : constat (motifs des lignes vides et de la colonne `t`, commentaires, `.tex`), texte de B(2)(b), C(2)(b) et D(2)(b) (« cinq […] consécutives au moins », identique au consolidé et au JOUE), lecture (refus justifié par la structure de la méthode, D(1), B/C/D(3)(a)-(b), indexation de D(4)-(5) ; présomption à qualifier de lecture de l'outil, ou aucun texte cité), portée (messages et documentation, aucun σ_USP, p-value ni verdict ; références touchées seulement si elles stockent ces textes, patch non numérique), circuit 2 allégé, choix d'ancrage par le mainteneur sur avis d'`actuary`. Refs #555, #483.

Avant création, la session doit vérifier qu'aucune issue existante ne traite déjà ce point.

## Retour

- **Statut** : `revue requise`. Deux lectures d'une source ; le choix de l'ancrage de V5 et de l'issue revient au mainteneur, sur avis d'`actuary`.
- **Résultat** : D(2)(b) ne fonde pas V5 à lui seul. Le refus se justifie par la structure du triangle (D(1), D(3)(a)-(b), D(4)-(5)), ce qui reste une lecture de l'outil. La phrase existante du moteur est une lecture abrégée, pas une citation. D(3)(a) est une notation sans contrainte sur les valeurs de `i`, départ libre compris. Un texte V5 corrigé est proposé.
- **Preuves** : *vérifié par lecture* : texte du consolidé et du JOUE (p. L 12/276-277), identique ; sites du moteur l. 7790-7791, 7946, 9850 ; doc l. 3879 et 3882. *Hypothèse* : la renumérotation interne de 0 à I par l'outil. *Non vérifié* : autres sites susceptibles de reprendre la phrase (références, tests).
- **Critères déclenchés** : deux lectures d'une source réglementaire (§ 4). Aucun changement de σ_USP ni de verdict.
