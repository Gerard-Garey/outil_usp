# K3b, étape 2 : avis amont d'`actuary`

> *Avis de l'agent actuary (IA), fiche de base. K3b, étape 2 (avis amont), branche `claude/registre-restes`, tête `57de0c3`, le 12/11/2026.* Versé intégralement par la session principale (Refs #537). L'agent n'a rien écrit dans le dépôt et n'a créé aucune issue.

**Ce qui a été lu.** La fiche K3b (`docs/feuille-de-route.md` l. 3600-3659), le rapport `docs/revues/20261112-rejeu-k3b/coder-rejeu-etape1.md` et les issues #537, #535, #536, #532, #534 et #555.

Dans `R/engine.R` :
- l. 2404-2430 (`test_anscombe_kurt`) ;
- l. 2600-2630 (`test_runs`), l. 2700-2727 (`runs_p_exacte`), l. 2806-2822 (`usp_runsr_p_exacte`, `.signes_mediane_egaux`) ;
- l. 4215-4227, 4655-4680, 4710-4740 et 4836-4895 (`add()`) ;
- l. 6886-6902, 7244-7312 et 7360-7368 ;
- l. 7700-7842 et 7940-8012 (lecteurs).

Aussi : `tests/unitaires/test_registre_add.R` l. 45-90, `test_non_applicable.R` l. 158-171, `test_statistiques.R` l. 208-218, et le `.tex` l. 3874-3905.

Annexe XVII, section D, paragraphes (1) à (3), lus dans le texte consolidé `.xhtml` par extraction de texte (du texte et non une formule : la règle #7 ne s'applique pas).

Trois mesures courtes avec `Rscript`, hors dépôt (sorties citées plus bas). Les ADR 0001 et 0003 n'ont pas été relus en entier : #535 garde la hiérarchie telle quelle, et la fiche le constate déjà.

---

## 1. #537 : forme de la valeur imprimée dans le refus

**Recommandation (a) : la plus courte écriture qui se relit à l'identique, de 15 à 17 chiffres, avec le point décimal imposé.**

Implémentation proposée : pour `d` de 15 à 17, `s <- format(val, digits = d, decimal.mark = ".")`, et on garde le premier `s` tel que `as.numeric(s) == val`. À défaut, `d = 17`.

Motifs :
- Ce refus signale une erreur de programmation. La valeur imprimée doit donc identifier le double fautif sans ambiguïté, ce que garantit la relecture à l'identique. `digits = 15` ne la garantit pas. Mesure : pour 1 + 5000 ε, `digits = 15` écrit « 1.00000000000111 », alors que l'écriture fidèle est « 1.0000000000011102 ».
- `-0.2`, `1.7`, `2`, `-0.01` et `1.5` gardent leur écriture actuelle. `test_registre_add.R` l. 54 reste donc vert sans modification.
- `decimal.mark = "."` suit la convention des autres messages d'`add()` (l. 4638 et 4644). Sous `OutDec = ","`, sans cette option, la boucle de relecture ne trouverait jamais l'égalité, car `as.numeric("1,000000001")` vaut NA.

Mesure (Rscript, R 4.3.3, en appelant l'aide directement) :
- 1 + 1e-9 → « 1.000000001 » ;
- −1e-9 → « -1e-09 » ;
- 1 + 1,1e-12 → « 1.0000000000011 » ;
- 1 + 2e-12 → « 1.000000000002 » ;
- −0,2 → « -0.2 ».

Le gabarit du message ne change pas : `add() : p-value hors de [0, 1] : <arg> = <valeur> (<nom>)`.

**Options écartées :**
- `digits = 15` : acceptable (tout dépassement de la tolérance de 1e-12 reste visible), mais moins fidèle.
- modifier le test l. 54 pour `digits = 17` : cela dégrade la lisibilité (« -0.20000000000000001 ») sans rien apporter.

**Correction du critère de l'étape 3 :** « valeur écrite par la plus courte écriture qui se relit à l'identique (15 à 17 chiffres significatifs), au point décimal », au lieu de « 17 chiffres significatifs ». Nouveau test : `identical()` du message pour 1 + 1e-9 et pour −1e-9 avec les textes du tableau ci-dessous.

## 2. #535 : aucun enjeu de fond

Confirmé par lecture (l. 4882-4895 et l. 4963-4974 d'après le rapport). Entre les deux blocs, `p_ex`, `p_mc` et `p_as` ne changent pas. La cascade du contrôle est donc la même hiérarchie, exacte > Monte-Carlo > p non simulée (ADR 0001, ADR 0003).

Poser `rang` dans les quatre branches (avec `NA_character_` quand aucune p n'existe) ne change ni la p retenue, ni `nature_p`, ni le texte d'aucun refus.

Les libellés du rang sont ceux du message d'erreur (« exacte », « Monte-Carlo », « p non simulee »), distincts de `nature_mc` et `nature_as`. Il ne faut pas réutiliser `nature`, puisque `nature_mc` peut valoir une autre chaîne pour une p Monte-Carlo externe. Aucune réserve de fond.

## 3. #536 : site l. 4842

**Recommandation (a) : garder `.prefixe_motif_mc()` à ce site et n'extraire que la garde**, ou toute forme équivalente où le texte posé sous R1 reste choisi selon la classe du motif.

Motif de fond :
- Aujourd'hui, la branche dégénérée est inatteignable à ce site uniquement parce que la bascule en diagnostic se fait plus haut (l. 4718-4720). Cette condition est invisible depuis la l. 4842.
- Avec un appel direct de l'aide, toute évolution de l'amont qui laisserait passer un motif dégénéré produirait « Monte-Carlo indisponible : <motif>. ».
- Ce texte serait faux : sous un motif de dégénérescence, la p Monte-Carlo n'est pas indisponible, elle est écartée (forme « <motif> : aucune p-value retenue. »). Il perdrait aussi le complément de #126.

Option (b) acceptable sur le fond : appeler l'aide directement, précédée d'une assertion `stop()` si `motif_boot %in% MOTIFS_MC_DEGENERES`.

L'architecture revient à `audit`. Textes inchangés octet pour octet (Q-60-2 (a)).

## 4. #532 : branche 2b de `detail_runsr`

**Recommandation (a) : option (ii), retirer la branche 2b et lever `stop()` sur l'objet incohérent.**

Démonstration, par lecture :
- `test_runs()` et `runs_p_exacte()` calculent les signes de la même façon (aplatissement au même plancher, `sign(z - median)`, zéros écartés). `test_runs` est à la l. 2608, `runs_p_exacte` à la l. 2718.
- `Runsr` est finie seulement si n1 ≥ 1, n2 ≥ 1 et (n1, n2) ≠ (1, 1). Dans ce cas, `runs_p_exacte(u, plancher_u)` est finie.
- La seule autre source de NA dans `usp_runsr_p_exacte()` est π_t non constant, ou des signes qui diffèrent entre u et z. Ce sont exactement les branches 3 et 2.
- La branche 2b exige donc un `stats_obs$Runsr` fini qui ne serait pas `test_runs(u, plancher_u)$stat`. C'est un bootstrap incohérent. Le rejeu le confirme : 0 sur 72 000 tirages.

Pourquoi pas les autres options :
- (i) : le cas fictif tomberait dans la branche 3, qui affirme que π_t est variable alors que `pi_constant` est vrai. Texte faux, refusé.
- (iii) : un test sur un objet impossible donnerait un statut à un état incohérent. De plus, le texte de 2b (« un seul cote de la mediane represente ») contredit lui-même une statistique observée finie.
- (ii) suit le précédent l. 7366-7367 (« assertion de programmation ») et ne touche aucune donnée réelle.

Texte du `stop()` (sans accents, comme les messages du moteur) :
`usp_tests() : p exacte de Runsr non definie a pi_t constant et signes identiques, statistique observee finie : objet bootstrap incoherent`

Éléments associés :
- Commentaire de régime l. 7255-7267 : retirer l'item 2b et écrire que ce cas est une assertion (« Runsr finie implique n1, n2 >= 1 et (n1, n2) != (1, 1), donc une p exacte finie a pi_t constant et signes identiques »).
- l. 7282 : « branches 1 et 2 ».
- Commentaire du test `test_detail_deux_phrases.R` l. 379 à corriger.
- Test : l'objet fictif du rejeu de l'étape 1 doit lever ce message.
- `.tex` l. 12333-12334 : retirer la phrase citée, à la charge de `docwriter`.

Effet : aucun sur les références (le texte de 2b est absent des six `.rds`).

## 5. #534 : b2 non fini

**Constat complémentaire, mesuré :** `m2 == 0` n'identifie pas exactement les résidus constants.
- Pour des résidus normaux à l'échelle 1e-100 : m2 = 8,7e-201 > 0, mais b2 = NaN, car m2² vaut 0 par soupassement de capacité.
- À l'échelle 1e-170 : m2 = 0 exactement, alors que les résidus ne sont pas constants.

Le critère de l'issue (« tester m2 == 0 ») doit donc devenir **« résidus exactement constants »** : `all(z == z[1])`, testé sur des z finis.

**Recommandation (a)**, dans `test_anscombe_kurt()`, sans changer son interface :
1. Garder le test `n < 20` en premier : aucun comportement ne change à T = 8.
2. `if (!all(is.finite(z))) stop("test_anscombe_kurt() : residus non finis", call. = FALSE)`. Même convention que `engine_aplatir_ex_aequo()` l. 326. Le chemin `NA` d'`usp_tests()` échoue de toute façon plus tôt.
3. `if (all(z == z[1]))` → `b2_non_defini = TRUE`. Le motif de la l. 6896-6898 reste inchangé, et il est vrai.
4. Si b2 n'est pas fini alors que les z sont finis et non constants (dépassement ou soupassement de capacité des moments) : `stop("test_anscombe_kurt() : aplatissement b2 non calculable en virgule flottante (depassement de capacite des moments centres), residus non constants", call. = FALSE)`.

Justification : les résidus d'un ajustement validé sont finis et standardisés, donc d'ordre 1. C'est une hypothèse forte, mais pas démontrée. Les points 2 et 4 sont donc des assertions, et un refus vaut mieux qu'un motif.

Options :
- (b) Au point 4, recalculer b2 sur y = (z − m)/max|z − m| (b2 ne dépend pas de l'échelle). Les bits des cas finis actuels ne bougent pas, puisque le recalcul n'intervient que dans ce cas. Mais c'est du code inatteignable de plus.
- (c) Ajouter un champ `b2_non_calculable` et un motif de ligne non applicable. Texte, si cette option était retenue : « aplatissement b2 non calculable (residus non finis ou depassement de capacite des moments centres) ; aucune p-value de Monte-Carlo prevue : test non applicable ». Cela change l'interface, contrairement à la fiche (« sans changement d'interface »).

Tests prévus :
- `rep(0.5, 25)` → `b2_non_defini` vaut TRUE ;
- un `NA` → erreur « residus non finis » ;
- un `Inf` → erreur « residus non finis » ;
- 1e80 / −1e80 dans 23 normales → erreur « non calculable » ;
- `rnorm(25) * 1e-170` → erreur « non calculable », et non `b2_non_defini`.

`.tex` l. 11368 : écrire « résidus constants » au lieu de « m2 = 0, résidus constants » (`docwriter`).

## 6. #555 : portée et textes (le mainteneur tranche)

### Ce que dit le règlement

Lu dans le consolidé, annexe XVII, section D :
- **D(2)(b)** : « les données sont disponibles pour cinq années d'accident consécutives au moins ».
- **D(3)(a)** : « les années d'accident sont représentées par des nombres consécutifs, commençant par 0 pour la première année d'accident pour laquelle des données sont disponibles ».

D(3)(a) est une règle de notation des formules, pas une exigence sur le fichier de l'utilisateur. Rien n'impose donc une numérotation 0-basée, 1-basée ou en années civiles de la colonne `i`.

Deux lectures possibles. À la lettre, D(2)(b) exige au moins cinq années consécutives, pas l'absence de trou. Le moteur l. 7782 écrit pourtant « exige des annees d'accident consecutives ». C'est une lecture plus large, que `regulatory` doit confirmer (voir § 8).

### Raison métier du contrôle

La colonne `i` n'est jamais lue : l'année d'accident vient de l'ordre des lignes, la plus ancienne en premier. Quand l'utilisateur fournit `i` et que `i` contredit cette lecture, le triangle calculé peut ne pas être celui qu'il voulait fournir. C'est une erreur silencieuse sur σ_USP. Le contrôle a donc un sens métier : il doit être dans le moteur et il est commun au CSV et au classeur.

### Recommandation (a), une seule règle

**Si la colonne `i` est présente, elle porte, ligne après ligne, des entiers croissants de pas 1, sans vide. La valeur de départ est libre** (0, 1, année civile, valeur négative comprise).

Cette règle couvre les critères de l'issue (doublons, vides) et, par extension, l'ordre non croissant, la non-consécutivité, les valeurs non entières, le texte et `Inf`.

Les valeurs sont lues par `.nettoyer_cellules()` puis `.en_numerique()`, comme les cellules (point décimal, #439). Une valeur est vide selon la même définition que pour les cellules.

Aucune règle sur une valeur négative : rien dans le texte ne permet de la refuser.

**Hors périmètre** : les en-têtes `I` ou ` i ` (avec blancs). Le cas est déjà refusé, avec le motif inadapté « Triangle non carre », sans calcul silencieux. Il pourrait faire l'objet d'une issue (candidate pour K2b), à créer seulement sur accord du mainteneur.

### Nom de colonne `NA`

**Recommandation (a) : le traiter comme un en-tête absent, comme `""`, sans refus.** Motifs :
- `.entete_absent()` (l. 7700) déclare déjà NA comme forme d'en-tête vide ;
- la piste de l'issue (`!(names(df) %in% "i")`) mène exactement à ce comportement ;
- seul un appel direct produit ce cas.

Cela s'écarte de la lettre du critère (« refus motivé »). Le mainteneur doit confirmer. Le critère « jamais d'erreur R brute » reste tenu.

Option (b), un refus, avec ce texte : `En-tete de colonne manquant (NA) en colonne(s) %s : nommer la colonne, ou laisser l'en-tete vide.`

### Ordre et cumul

- **Étape A, sur les noms reçus** : après `MOTIF_LIGNE1_VIDE` (règle « avant toute autre » de #522), avant `.retirer_lignes_colonnes_vides()`, donc avant le renommage en `i.1` par la l. 7841. C'est le refus de l'en-tête `i` en double, retourné seul (plus le refus du nom NA si l'option (b) est retenue, les deux étant cumulés).
- **Étape B, sur les valeurs de `i`** : après le retour des erreurs de `lv` et avant la l. 7985. Étape à part, conformément à la convention de refus par étape d'`engine_lire_triangle()`.
  - V1 et V2 sont cumulés.
  - V3, V4 et V5 ne sont évalués que sans V1 ni V2. Ils s'excluent, et seul le premier qui s'applique est émis, dans l'ordre V3 → V4 → V5 : un doublon implique une suite non croissante, et un ordre non croissant rend l'écart sans objet.
- Numérotation : « ligne(s) de donnees », comme les motifs des lignes vides, listée par `liste()`.

## 7. Critère Q-A2

**Confirmé.** Par lecture :
- `test_non_applicable.R` l. 158-171 passe `loi = "chi2(1) asymptotique"` à `add()` et exige `loi = NA_character_`. C'est la garde directe de l'affectation l. 4723.
- `test_statistiques.R` l. 215 vérifie une ligne dont l'appelant passe déjà `loi = NA_character_`. Elle ne peut pas détecter le retrait de l'affectation.

La mesure par mutant du rapport (3 échecs dans `test_non_applicable.R`, 0 dans `test_statistiques.R`) concorde ; non rejouée.

Critère corrigé : « `tests/unitaires/test_non_applicable.R` (dont l. 158-171) vert à chaque commit d'`add()` ; `test_statistiques.R:215` vert ».

## 8. Faut-il `regulatory` (`medium`) ?

**Oui, pour le seul motif V5**, qui cite D(2)(b). Points à lire :
1. D(2)(b) fonde-t-il le refus d'un écart dans la colonne `i` (année d'accident manquante présumée), alors que sa lettre exige « cinq années d'accident consécutives au moins » ?
2. La phrase existante « l'annexe XVII, D(2)(b), exige des annees d'accident consecutives » (l. 7782, reprise par les motifs des lignes vides) est-elle une citation exacte ou une lecture de l'outil ? La correction éventuelle des motifs existants est hors périmètre et deviendrait une issue.
3. Confirmer que D(3)(a) (« commençant par 0 ») est une notation et ne contraint pas la colonne `i`.

Aucun autre texte ne cite le règlement.

---

## Tableau des textes fixés

Messages sans accents, comme dans le moteur ; `%s` est rempli par `liste()`.

| Issue | Site | Texte fixé mot pour mot |
|---|---|---|
| #537 | `verifier_p()` l. 4675 | gabarit inchangé `add() : p-value hors de [0, 1] : <arg> = <v> (<nom>)` ; `<v>` = plus courte écriture qui se relit à l'identique parmi `format(val, digits = d, decimal.mark = ".")`, d = 15, 16, 17 (à défaut, 17). Ex. : `add() : p-value hors de [0, 1] : p_ex = 1.000000001 (t)` ; `… : p_ex = -1e-09 (t)` ; `… : p_ex = -0.2 (t)` |
| #535 | — | aucun texte changé |
| #536 | — | aucun texte changé (Q-60-2 (a)) |
| #532 | branche 2b retirée, assertion | `usp_tests() : p exacte de Runsr non definie a pi_t constant et signes identiques, statistique observee finie : objet bootstrap incoherent` |
| #534 | `test_anscombe_kurt()`, z non finis | `test_anscombe_kurt() : residus non finis` |
| #534 | b2 non fini, z finis non constants | `test_anscombe_kurt() : aplatissement b2 non calculable en virgule flottante (depassement de capacite des moments centres), residus non constants` |
| #534 | z constants (l. 6896-6898) | inchangé : `aplatissement b2 non defini (moment centre d'ordre 2 des residus nul : residus constants) ; aucune p-value de Monte-Carlo prevue : test non applicable` |
| #555 H1 | en-tête `i` en double | `En-tete "i" present plusieurs fois (colonnes %s) : la colonne i, facultative, porte l'annee d'accident de chaque ligne et ne peut figurer qu'une fois ; retirer ou renommer la colonne en trop.` |
| #555 V1 | vides | `Colonne i incomplete (ligne(s) de donnees %s sans valeur) : la colonne i, facultative, numerote les annees d'accident ; la renseigner pour chaque ligne, ou la retirer.` |
| #555 V2 | non numérique, non entière, non finie | `Colonne i non entiere ou non numerique (ligne(s) de donnees %s) : la colonne i, facultative, numerote les annees d'accident par des entiers ; la corriger, ou la retirer.` |
| #555 V3 | doublons | `Colonne i a valeurs repetees (ligne(s) de donnees %s) : chaque ligne est une annee d'accident distincte ; corriger la colonne i, ou la retirer.` |
| #555 V4 (extension) | non croissante | `Colonne i non croissante (ligne(s) de donnees %s) : les annees d'accident sont lues dans l'ordre des lignes, de la plus ancienne a la plus recente ; ordonner les lignes selon la colonne i, ou la corriger.` |
| #555 V5 (extension, sous réserve de `regulatory`) | écart supérieur à 1 | `Colonne i non consecutive (entre les lignes de donnees %s) : annee d'accident manquante presumee ; l'annexe XVII, D(2)(b), exige des annees d'accident consecutives. Renseigner l'annee d'accident manquante, ou corriger la colonne i.` (`%s` : paires « k-1 et k ») |
| #555 nom NA | option (b) seulement | `En-tete de colonne manquant (NA) en colonne(s) %s : nommer la colonne, ou laisser l'en-tete vide.` |

## Décisions à soumettre au mainteneur

1. **#555, portée.** Recommandation : règle unique « entiers croissants de pas 1, sans vide, départ libre », qui inclut l'ordre non croissant, la non-consécutivité, les valeurs non entières, le texte et `Inf` (extension au-delà des critères). Option minimale : seulement V1 et V3, plus H1.
2. **#555, nom `NA`.** Recommandation : le traiter comme un en-tête absent, sans refus. Cela s'écarte de la lettre « refus motivé » du critère. Option : refus avec le texte du tableau.
3. **#555, en-têtes `I` / ` i `.** Recommandation : hors périmètre, avec une issue à rédiger sur accord.
4. **#534, cas d'un z fini à b2 non fini.** Recommandation : `stop()`. Options : recalcul après mise à l'échelle, ou nouveau champ et nouveau motif.
5. Pour information (validation par `actuary` suffisante, aucun σ_USP ni verdict touché) : #537 avec relecture à l'identique ; #532 option (ii).

## Retour

- **Statut** : `revue requise`. Les décisions 1 à 4 reviennent au mainteneur, et la lecture de D(2)(b) pour V5 revient à `regulatory`.
- **Résultat** : textes fixés (tableau) ; #537 relecture à l'identique, de 15 à 17 chiffres, au point décimal ; #535 aucun enjeu de fond ; #536 sélection selon la classe du motif conservée au site l. 4842 ; #532 option (ii) ; #534 constance testée directement, assertions sinon ; #555 règle unique sur `i`, deux étapes de refus ; Q-A2 critère corrigé.
- **Preuves** :
  - *Vérifié par mesure* (Rscript, hors dépôt) : écritures de #537 sous les deux formats, et sous `OutDec = ","` avec `decimal.mark = "."` ; soupassement de capacité de b2 (échelle 1e-100 : m2 = 8,7e-201, b2 = NaN ; échelle 1e-170 : m2 = 0 pour des résidus non constants).
  - *Vérifié par lecture* : identité du calcul des signes entre `test_runs` et `runs_p_exacte`, d'où l'inatteignabilité de 2b ; gardes Q-A2 ; `.entete_absent()` traite NA comme un en-tête absent ; texte de D(2)(b) et de D(3)(a) dans le consolidé.
  - *Repris du rapport de l'étape 1, non rejoué* : 72 000 tirages pour #532 ; mutant Q-A2 ; corpus de 4 800 appels pour #536.
  - *Hypothèses* : résidus standardisés d'ordre 1 dans `run_engine()`, d'où l'inatteignabilité des assertions de #534 ; usage plausible des années civiles dans `i`.
- **Informations manquantes** : parité avec `openxlsx` non mesurable dans cette session (paquet absent) ; aucun fichier d'utilisateur pour vérifier les usages réels de `i`.
- **Décisions non résolues** : les points 1 à 4 ci-dessus (mainteneur) ; la lecture de D(2)(b) (`regulatory`).
- **Critères déclenchés** : deux lectures d'une source (D(2)(b) à la lettre contre la phrase du moteur l. 7782) ; écart avec le critère écrit de #534 (« m2 == 0 ») et de #555 (refus d'un nom NA) ; changement de comportement hors références (#555, et extension de sa portée) ; aucun changement de σ_USP, de p-value ni de verdict attendu.
- **Prochaine action recommandée** : soumettre les décisions 1 à 4 au mainteneur ; consulter `regulatory` (`medium`) sur V5, D(2)(b) et D(3)(a) ; corriger dans la fiche les critères des étapes 3 (#537) et 4 (Q-A2 : `test_non_applicable.R`) ; puis l'étape 3 en `coder-approfondi`.
