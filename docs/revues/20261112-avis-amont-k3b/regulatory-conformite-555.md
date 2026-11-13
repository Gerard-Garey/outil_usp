# K3b, étape 8 (#555) : contrôle de conformité des textes réancrés par `regulatory`

> *Matrice de l'agent regulatory (IA), fiche de base, le 12/11/2026, sur le diff non commité de #555 (tête `bb390cd`).* Versée intégralement par la session principale (Refs #555).

Je n'ai rien écrit dans le dépôt et je n'ai créé aucune issue.

## Contrôle de conformité en aval, K3b étape 8 (#555) : réancrage des motifs « (2)(b) … exige des années consécutives »

**Réponse courte : tous les renvois sont exacts et la présomption est bien attribuée à l'outil. Aucun site à reformuler dans le périmètre.** Deux remarques non bloquantes et une observation hors périmètre sont en fin de matrice.

Branche `claude/registre-restes`, tête `bb390cd`, avec le diff non commité de `R/engine.R` et de `tests/unitaires/test_controles_entree.R`.

### Sources

- **Texte consolidé du 14.11.2024** (référence de lecture), annexe XVII, sections B(1) à (3), C(1) à (3) et D(1) à (3). Ce sont des passages de texte sans formule ; je les ai extraits de l'xhtml.
- **JOUE L 12 du 17.1.2015** (`Règlement délégué.pdf`), texte courant extrait page par page :
  - B(1)-(2) en p. L 12/272, B(3) en p. L 12/273 ;
  - C(1)-(2) en p. L 12/274, C(3) en p. L 12/275 ;
  - D(1)-(2) en p. L 12/276, D(3) en p. L 12/277.
- Le libellé est identique mot pour mot dans les deux versions, sans marqueur de modification sur ces points.

Textes de référence :
- **B(3)** et **C(3)** : « Aux fins des paragraphes 4 à 6, les règles de notation suivantes s'appliquent ».
  - B(3)(a) : « les années d'accident sont représentées par des nombres consécutifs, commençant par 1 pour la première année d'accident pour laquelle des données sont disponibles » ; B(3)(b) : « T représente la dernière année d'accident pour laquelle des données sont disponibles ».
  - C(3)(a) : « les exercices sont représentés par des nombres consécutifs, commençant par 1 pour le premier exercice pour lequel des données sont disponibles » ; C(3)(b) : « T représente le dernier exercice pour lequel des données sont disponibles ».
- **D(1)** : « indiqués séparément pour chaque année d'accident et chaque année de développement des paiements ».
- **D(3)**, « Aux fins des paragraphes 4 et 5 » : (a) « représentées par des nombres consécutifs, commençant par 0 » ; (b) « I représente la dernière année d'accident pour laquelle des données sont disponibles ».
- **B(2)(b)** : « cinq années d'accident consécutives au moins ». **C(2)(b)** : « cinq exercices consécutifs au moins ». **D(2)(b)** : « cinq années d'accident consécutives au moins ».
- **B(1)** dit « séparément pour chaque année d'accident », mais **C(1)** dit seulement « séparément pour des exercices différents ». Actuary a donc eu raison de ne pas citer (1) pour le lecteur des séries, qui est commun à B et C.

### Matrice site → texte → paragraphe cité → verdict

| # | Site | Texte (rendu ou fixé) | Paragraphe cité | Verdict |
|---|---|---|---|---|
| 1 | `R/engine.R`, `.retirer_lignes_colonnes_vides()`, variable `texte` des séries ; motif ligne vide **en tête** | « … refusee comme annee manquante presumee ; les annees d'accident (annexe XVII, section B) ou exercices (section C) sont numerotes par des nombres consecutifs de 1 a T (B(3)(a) et (b), C(3)(a) et (b)). Renseigner… » | B(3)(a)-(b), C(3)(a)-(b) | **Conforme.** « consécutifs », « commençant par 1 » et « T » sont littéraux ; « numerotes » paraphrase « représentés ». La présomption est attribuée à l'outil par « presumee ». (2)(b) n'est plus cité. |
| 2 | Même site, ligne vide **intercalée** (rendu vérifié par `Rscript`) | Même texte | Idem | **Conforme** |
| 3 | `texte` du triangle ; motifs en tête et intercalée | « … annee d'accident manquante presumee ; le triangle de l'annexe XVII, section D, porte les montants de chaque annee d'accident, numerotees par des nombres consecutifs de 0 a I (D(1), D(3)(a) et (b)). Renseigner… » | D(1), D(3)(a)-(b) | **Conforme.** Le texte est celui que j'avais recommandé pour V5 : « chaque année d'accident » vient de D(1), « nombres consécutifs » et « commençant par 0 » de D(3)(a), « I » de D(3)(b). « Triangle » est un terme descriptif, pas une citation. |
| 4 | `engine_lire_donnees_csv()`, colonne `t` non consécutive (l. 8124-8127 ; rendu vérifié) | « Colonne t : annees non consecutives (%s), annee manquante presumee ; les annees d'accident (annexe XVII, section B) ou exercices (section C) sont numerotes par des nombres consecutifs de 1 a T (B(3)(a) et (b), C(3)(a) et (b)). » | B(3)(a)-(b), C(3)(a)-(b) | **Conforme.** « presumee » couvre aussi le cas d'un pas autre que 1 (par exemple 2001, 2003…). |
| 5 | `.motifs_colonne_i()`, motif V5 | « … annee d'accident manquante presumee ; le triangle de l'annexe XVII, section D, … de 0 a I (D(1), D(3)(a) et (b)). … » | D(1), D(3)(a)-(b) | **Conforme**, identique au texte recommandé dans `regulatory-lecture-d2b-v5.md`, point 4 |
| 6 | Commentaire, l. 7697-7701 (colonne `t`) | « lecture de l'outil : annexe XVII, B(3)(a)-(b) et C(3)(a)-(b) … ; B(2)(b) et C(2)(b) n'exigent que "cinq [...] consecutives au moins" (resp. "consecutifs"), controle de profondeur distinct » | B(3), C(3), B(2)(b), C(2)(b) | **Conforme.** L'élision et le « resp. » sont exacts. |
| 7 | Commentaire, l. 7726-7731 (lignes vides) | « lecture de l'outil ; series : annexe XVII, B(3)(a)-(b) et C(3)(a)-(b) ; triangle : D(1) et D(3)(a)-(b) » | Idem | **Conforme** |
| 8 | Commentaires de `.motifs_colonne_i()`, `.entete_designe()` et de l'étape A/B | Aucun renvoi réglementaire hors du texte de V5 | — | **Conforme** (rien à contrôler) |
| 9 | Tests, l. 1800-1802 (commentaire) | « annees consecutives (lecture de l'outil, annexe XVII, B(3)(a)-(b) et C(3)(a)-(b)) » | B(3), C(3) | **Conforme** |
| 10 | Tests, l. 1983-1987 et 2032-2038 (libellés et assertions) | « B(3)(a) et (b), C(3)(a) et (b) » avec `!contient("(2)(b)")` ; « (D(1), D(3)(a) et (b)) » avec `!contient("D(2)(b)")` | Idem | **Conforme.** Les assertions négatives empêchent le retour de l'ancien renvoi. |
| 11 | Tests, bloc « Textes reancres (#555, décisions 5 et 6) », `V5_555` et cas `T` à trou | `identical()` sur les textes complets | Idem | **Conforme.** Les textes vérifiés reproduisent mot pour mot ceux d'`actuary-textes-555.md`, § 2.2. |
| 12 | Site fidèle, l. 1316 | « Profondeur minimale (annexe XVII, B/C(2)(b)) », `T >= 5` | B(2)(b), C(2)(b) | **Conforme**, c'est bien la profondeur minimale. |
| 13 | Site fidèle, l. 10059 | « D(2)(b) : au moins %d annees d'accident consecutives (%d fournies). » | D(2)(b) | **Conforme.** `T_min` vaut 5 chez tous les appelants (app.R l. 1121 et 1297, engine l. 8225 et 14337). |
| 14 | Sites fidèles, l. 9073, 9191 et 9205 | « Annexe XVII, B/C(2)(b) : au moins %d annees consecutives sont exigees… » ; « l'annexe XVII, B/C(2)(b), exige au moins %d annees consecutives » | B(2)(b), C(2)(b) | **Conforme.** `T_min` vaut 5 par défaut, et l. 9191 ne cite l'annexe que si `T_min >= 5`. « Années » couvre aussi les exercices de C, ce qui reste acceptable. |
| 15 | Site fidèle, l. 354 (barème) | « Annexe XVII : au moins 5 annees consecutives sont exigees » | Pas de paragraphe cité | **Conforme** |
| 16 | `.tex` l. 3879, texte fixé | « (D(1), D(3)(a) et~(b)~: montants indiqués pour chaque année d'accident, années d'accident représentées par des nombres consécutifs de~0 à~$I$~; lecture retenue par l'outil) » | D(1), D(3)(a)-(b) | **Conforme.** Formulation littérale (« représentées »), présomption attribuée à l'outil. |
| 17 | `.tex` l. 4480-4481, texte fixé | « (lecture retenue par l'outil~: annexe~XVII, B/C(3)(a) et~(b), années d'accident ou exercices représentés par des nombres consécutifs de~1 à~$T$) » | B(3), C(3) | **Conforme** |
| 18 | `.tex` l. 4485, texte fixé | « (B/C(3)(a) et~(b), même lecture) » | Idem | **Conforme** |
| 19 | `.tex` l. 4967, texte fixé | « (B/C(3)(a) et~(b), lecture retenue par l'outil~; B/C(2)(b) n'exige que cinq années consécutives au moins) » | B(3), C(3), B(2)(b), C(2)(b) | **Conforme**, avec une précision facultative (remarque b). |

**Remarques non bloquantes, laissées au mainteneur et à docwriter :**

- **a) La notation n'est pas une règle sur les valeurs saisies.** B/C/D(3) sont des règles de notation « aux fins des paragraphes 4 à 6 » (resp. 4 et 5). « Numerotes … de 1 a T » ou « de 0 a I » décrit la notation du règlement, pas les valeurs que doivent porter `t` ou `i`, dont le départ est libre (par exemple 2015 à 2020). Le message reste exact. Un utilisateur pourrait pourtant croire qu'il doit numéroter de 1 à T. Ma lecture antérieure (point 3) en avait tenu compte, et l'ancrage a été validé en ces termes par la décision 5. Je ne demande aucune modification.
- **b) `.tex` l. 4967 : « années » couvre deux notions.** Pour C, le texte dit « exercices consécutifs ». Pour coller au texte, docwriter peut écrire « cinq années d'accident (B) ou exercices (C) consécutifs au moins ». Ce n'est pas un écart.

**Observation hors périmètre (aucune issue créée) : `.tex` l. 3880-3882, colonne vide du triangle.** Le passage, qui n'est pas modifié, cite « (D(1), D(2)(c) et D(3)(c)~: … années de développement consécutives, $J$ étant la plus récente … ; la présomption est une lecture retenue par l'outil) ».
- D(2)(c) n'exige que « cinq années de développement consécutives au moins » : c'est l'abréviation que #555 vient de corriger pour (2)(b), en plus faible ici puisque la présomption est déjà qualifiée de lecture de l'outil.
- D(3)(c) ne fait que définir J. Contrairement aux années d'accident, D(3) ne numérote pas les années de développement par des nombres consécutifs.
- Le moteur, lui, ne cite rien dans les motifs de colonnes. L'écart ne touche donc que la documentation.
- Piste, pour le mainteneur : soit faire harmoniser ce passage par docwriter lors du passage de fin de branche, s'il juge que cela entre dans la décision 6, soit en faire une issue de documentation à créer sur accord.

### Retour

- **Statut** : `complet`.
- **Résultat** :
  - Les 11 sites réancrés (messages, commentaires, tests) et les 4 lignes du `.tex` fixées par actuary sont conformes au consolidé et au JOUE.
  - La présomption est attribuée à l'outil partout : « presumee » dans les messages, « lecture de l'outil » ou « lecture retenue par l'outil » dans les commentaires et le `.tex`.
  - Les sites fidèles (l. 354, 1316, 9073, 9191, 9205, 10059) restent exacts.
  - Aucun σ_USP, aucune p-value ni aucun verdict n'est touché.
- **Preuves** :
  - *Vérifié par lecture* : texte du consolidé (xhtml) et du JOUE (p. L 12/272 à 277, identiques) ; diff `git diff -- R/engine.R tests/` ; lignes 3876-3902, 4478-4487 et 4964-4970 du `.tex` ; appelants de `engine_valider_donnees()` et de `mw_valider_triangle()` (tous avec `T_min = 5`).
  - *Vérifié par mesure* : messages rendus de la ligne vide intercalée et de la colonne `t` à trou, via `charger_moteur()` sous `LC_ALL=C.UTF-8`.
  - *Non vérifié* : je n'ai pas exécuté la batterie complète.
- **Critères déclenchés** : aucun. Les deux lectures du texte ont déjà été tranchées par les décisions 5 et 6.
- **Prochaine action recommandée** : verser les textes fixés du `.tex` à docwriter pour le passage de fin de branche, avec la remarque b en option ; soumettre au mainteneur l'observation sur la l. 3880 (D(2)(c), D(3)(c)), à harmoniser dans K3b ou à traiter par une issue à créer sur accord.

Fichiers : /home/user/outil_usp/R/engine.R, /home/user/outil_usp/tests/unitaires/test_controles_entree.R, /home/user/outil_usp/docs/latex/doc_tests_usp.tex, /home/user/outil_usp/docs/revues/20261112-avis-amont-k3b/actuary-textes-555.md, /home/user/outil_usp/docs/revues/20261112-avis-amont-k3b/regulatory-lecture-d2b-v5.md
