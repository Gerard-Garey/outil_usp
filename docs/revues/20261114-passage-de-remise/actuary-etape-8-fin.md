**Verdict : visa avec réserves.** Aucun constat bloquant ni majeur. Il reste deux mineurs et un facultatif. Rien dans le diff n'affirme un changement de σ_USP, d'une p-value ou d'un verdict.

# Avis d'`actuary`, KR étape 8 : revue des reprises de `docwriter` et du README

> *Rapport de l'agent `actuary` (IA, fiche de base), rendu à la session principale le 14/11/2026 ; versé tel quel par la session principale (Q-54-10).*

Arbre lu : `claude/passage-de-remise`, tête `a0fe3e2`. Diffs relus : `git diff d1a15df..3a3bacf -- docs/latex/` (commits `929a5c4`, `fa2918d`, `79a2865`, `3a3bacf`) et `git show a0fe3e2`. Le code n'a pas bougé depuis le gel : `git diff a2f9c3a HEAD --stat -- R/ app.R tests/ DESCRIPTION` est vide. Je n'ai rien écrit dans le dépôt. Mes mesures sont faites dans le dossier temporaire de la session, sous `LC_ALL=C.UTF-8`, avec le moteur chargé par `charger_moteur()`. `openxlsx` n'est pas installé dans ce conteneur.

## 1. Constats repris, un par un

### Lot 3, `929a5c4` (`sec:graines`, l. 2756-2801)

| Constat | Verdict | Commentaire |
|---|---|---|
| G1 (majeur) | **repris conformément** | C'est le texte proposé, mot pour mot (« Ces deux écarts viennent de la plateforme… n'est pas établi »). L'affirmation « la CI reproduit ses références » est conforme à la règle du moteur : M34, deux exécutions successives de la CI sont identiques au bit près. |
| G2 | **repris conformément** | Texte proposé repris, « dérive maximale » compris. Recalcul : 0,0158 × 1,814e-6 ≈ 2,87e-8. Pour 4,2e-9, j'arrive à 4,27e-9 avec la valeur arrondie 0,0024 ; les 4,23e-9 de mon premier avis viennent de la valeur exacte du tirage. « environ 4,2 » est donc juste. |
| m3, m4, m6, m7 | **repris conformément** | Textes proposés repris mot pour mot. |
| m5 | **repris avec écart acceptable** | Le chiffre « au plus 4,545e-16 en relatif » n'est pas répété. Il figure déjà dans le même paragraphe (« vaut au plus 4,545·10⁻¹⁶ sur la branche Merz-Wüthrich »), donc rien n'est perdu. Le partage entre le mesuré (« une à trois unités du dernier bit… (mesuré) ») et le non établi (le mécanisme) est conservé, et c'était l'objet du constat. |

### Lot 4, `fa2918d` (lecteur xlsx, l. 830-836, 878-881, 4688-4735)

**A (majeur) : repris avec écart acceptable, plus une réserve mineure (m-a).**
- L'ajout de `sprintf("%.17g")` est exact : c'est la fonction `num()` d'`engine_empreinte()`, `R/engine.R` l. 9152. Il est même utile, car il nomme la règle d'écriture.
- Le reste du texte proposé est repris : « identifie ces valeurs », « sans passer par le lecteur de l'outil », « constance … attendue, non vérifiée ». Ce dernier point est conforme au commentaire du code, l. 9127.
- La table « Empreintes » du rapport figé existe bien (`R/display_helpers.R` l. 3263).
- **Réserve m-a, mineure** : le texte canonique est décrit trop sommairement pour être « reproduit ». C'est une lacune de mon texte d'origine, que `docwriter` a reprise.
  - L'en-tête exact n'est pas donné : `t;xt;yt`, ou `triangle;<n>;<m>` (l. 9161-9166).
  - L'écriture des valeurs manquantes (`NA`) n'est pas donnée.
  - La colonne t est écrite par `paste()`, pas par `sprintf`.
  - Chaque ligne, la dernière comprise, finit par un LF.
  - « à 17 chiffres significatifs » est inexact : `%.17g` retire les zéros de queue. Mesuré : `sprintf("%.17g", 100)` donne `100`, et `0.1` donne `0.10000000000000001`.

**B (majeur) : repris avec écart acceptable.**
- `B2` au lieu de `E2` : c'est justifié. `E2` déclenche le motif A8 (`\b(?:E2[a-z]?|…)\b`, CONVENTIONS l. 161). Le texte n'avance aucune valeur chiffrée qui dépendrait de la cellule choisie, et B2 est une cellule de données dans les deux formats (première valeur de xt ; C(0,1) du triangle).
- « Hors des formes préfixées » : la locution existe déjà dans la section (l. 4722, limite #575), et elle borne correctement la portée.
  - Ma mesure le confirme. Sur la voie de repli, un doublon préfixé `<x:c r="B2"><x:v>999</x:v></x:c>` placé après `<c r="B2"><v>100</v></c>` n'est pas lu : xt[1] = 100.
  - La règle « la dernière l'emporte » ne vaut donc pas pour les formes préfixées, et la restriction est fondée.
- « le contrôle de ces valeurs » : repris.
- Mesuré sur la voie de repli, au format lognormal : `<c r="B2">` répété, à la suite de la première cellule ou en fin de ligne → `engine_lire_donnees_csv()` rend `ok TRUE` et xt[1] = 999.
- Le chemin `openxlsx` n'a pas été mesuré par moi. Il repose sur l'audit (ii) et sur la remesure de `docwriter` (message de `fa2918d` : openxlsx 4.2.9, Windows 11).

**C (majeur sous condition, gel maintenu par le mainteneur) : repris avec écart acceptable.**
- « FALSE 0 » est exact : `.en_numerique()` (l. 8013-8017) appelle `as.numeric()` sur un vecteur logique.
- Les lignes d'inventaire (l. 832-835 et 880-881) sont corrigées, avec un renvoi vers `sec:controles`. C'est pertinent, puisque l'inventaire est hors de cette section. La formule « une colonne de type logique » est juste quelle que soit l'origine de la colonne. L'application lit le CSV en `colClasses = "character"` (`app.R` l. 280) : le cas ne survient pas par le CSV de l'application.
- Mesuré :
  - Voie de repli : colonne xt en `t="b"`, refusée avec « colonne xt : ligne(s) de donnees 1, 2, 3, 4, 5 et 3 autre(s) ».
  - Colonne logique passée directement, ce qui simule le retour d'`openxlsx` : `engine_lire_donnees_csv()` rend `ok TRUE` avec xt = 1 0 1 1 1 1 1 1 ; `engine_lire_triangle()` rend `ok TRUE` avec C(0,4) = 1.
- Que `openxlsx` rende lui-même une colonne logique n'a pas été mesuré par moi : audit (ii) avec 4.2.5.2, `docwriter` avec 4.2.9.
- **Facultatif (m-c)** : nommer les versions, comme pour #575 juste au-dessus : « (valeur fausse, mesuré sous \code{openxlsx}~4.2.5.2 et~4.2.9) ».

**#574-5 : repris avec écart acceptable.**
- Le sujet est précisé en « Les trois refus de la table des chaînes partagées ». Cela désigne sans ambiguïté les trois refus énumérés à l'avant-dernière phrase (segments sans mise en forme, indication phonétique vide, `<t>` successifs), et non le refus du nom d'entrée qui précède. C'est meilleur que mon texte.
- Mesuré sur la voie de repli, avec une table contenant l'octet 0xFF :
  - une forme qui serait refusée par Q-F (`<r>` sans `<rPr>`) n'est pas refusée ;
  - aucune chaîne n'est lue : la cellule `t="s"` est refusée comme non numérique ;
  - R émet six avertissements (`input string 1 is invalid`), sans erreur.
- Les mêmes contrôles sur une table en UTF-8 valide refusent bien. « sans valeur fausse » est donc vérifié sur la voie de repli.
- Non mesuré par moi : l'erreur R d'`openxlsx` 4.2.9, et le comportement sous une locale Windows.

### Lot 5, `79a2865` et `3a3bacf` (borne E-L1-1, CONVENTIONS E4)

| Constat | Verdict | Commentaire |
|---|---|---|
| D (date d'application) | **repris avec écart acceptable** | « antérieure au 30.1.2027, date d'application de cet acte fixée par son article 2 ». La forme pointée est celle du JOUE (« 25.3.2015 »). Elle reste hors du motif A10 par construction, et l'exception E4 la nomme (`3a3bacf`). La forme diffère de la borne inférieure (« 1er janvier 2020 »), mais c'est une asymétrie de forme, sans inconvénient pour le lecteur. |
| R2 | **repris conformément** | « série L, 2026/269 du 18.2.2026 ». |
| R3 | **repris avec écart acceptable** | « avec effet sur le seul risque de réserve » au lieu de « pour le seul risque de réserve ». Si le point 39) b) remplace la première phrase de l'art. 148(3), comme l'écrit `regulatory`, sans rien changer pour les primes, « avec effet sur » est plus précis que « pour ». Le sens est celui de R3. **Je n'ai pas pu relire le texte primaire** (EUR-Lex rend une page de navigation, l'Office des publications une redirection RDF). Je m'appuie sur la lecture de `regulatory` et sur la vérification à la source que `docwriter` déclare dans le message de `79a2865`. |
| E4 (`3a3bacf`) | **conforme** | « 30.1.2027 », « 18.2.2026 » et « 2026/269 » sont ajoutés à la liste des exemples. Les autres termes sont inchangés. |

### README, `a0fe3e2`

**Conforme.** « est lue 1 pour `TRUE` et 0 pour `FALSE` » est aligné sur le `.tex` et sur le code. Les reprises précédentes du README (`d1a15df`, hors du diff soumis) sont présentes dans l'état actuel (l. 37-61) : versions 4.2.5.2 sous Linux et 4.2.9 sous Linux et Windows, puce #574 sur les cellules de même référence, nuance de l'empreinte.

## 2. Contrôles automatiques (exécutés sur la tête `a0fe3e2`)

- `tests/controle_doc_nd.R` : « 0 occurrence(s) de la liste A, 0 fiche(s) en violation du plafond ». Aucun journal `.log` n'était présent : les débordements n'ont pas été lus.
- `tests/concordance_doc_moteur.R --strict` : « 0 ecart(s) (mode strict) ».
- Je n'ai pas compilé le `.tex`. `docwriter` déclare une compilation MiKTeX : 448 pages, 0 erreur, 0 renvoi indéfini.

## 3. Point 4 : renvoi aux l. ~3958 et ~4780

Les deux phrases sont **dans `sec:controles`**, comme le paragraphe booléen (l. 4731-4735). La section commence à la l. 3906 et le paragraphe n'a pas de `\label` propre. Un `\ref{sec:controles}` renverrait donc à la section où se trouve déjà le lecteur, ce qui est inutile. Un renvoi en clair convient mieux.

- **l. 3960-3962 (`engine_lire_triangle()`) : renvoi recommandé (mineur, m-b).**
  - La phrase est catégorique : « une cellule non vide et non numérique … est refusée avec sa position, jamais lue comme manquante ».
  - Elle est à environ 770 lignes du paragraphe booléen.
  - Le triangle est justement le cas mesuré d'acceptation (C(0,4) = 1).
  - Texte à confier à `docwriter` : après « jamais lue comme manquante », insérer « , hors le cas d'une colonne booléenne lue par \code{openxlsx}, décrit ci-après parmi les limites de la lecture des classeurs ».
- **l. 4779-4780 (« Une cellule de xt ou de yt non numérique est refusée ») : facultatif.** Le paragraphe booléen est 45 lignes plus haut, dans le même développement. Si le mainteneur le veut : après « est refusée avec sa position », insérer « (colonne booléenne lue par \code{openxlsx} exceptée, ci-dessus) ».

Décision au mainteneur. Aucun des deux ajouts ne touche un résultat.

## 4. Textes de correction pour `docwriter` (tous mineurs, aucun bloquant)

**m-a, l. 4709-4711, parenthèse d'`engine_empreinte()`.** Remplacer :
> (\code{engine\_empreinte()}~: une ligne d'en-tête, puis une ligne par année ou par ligne du triangle, valeurs écrites par \code{sprintf("\%.17g")}, à 17 chiffres significatifs, et séparées par «~\code{;}~»)

par :
> (\code{engine\_empreinte()}~: une ligne d'en-tête, «~\code{t;xt;yt}~» ou «~\code{triangle;}~» suivi des nombres de lignes et de colonnes séparés par «~\code{;}~», puis une ligne par année ou par ligne du triangle, valeurs écrites par \code{sprintf("\%.17g")}, au plus 17 chiffres significatifs, valeur manquante écrite «~\code{NA}~», année écrite telle quelle, séparées par «~\code{;}~», chaque ligne terminée par un saut de ligne LF)

Cette description suit `R/engine.R` l. 9152, 9161-9168 et 9169 (`writeBin` en UTF-8).

**m-b** : l. 3960-3962, texte au § 3.

**m-c (facultatif)** : l. 4734, « (valeur fausse, mesuré sous \code{openxlsx}~4.2.5.2 et~4.2.9) ».

## Retour

- **Statut** : `complet` pour ce qui est mesurable ici. Le chemin `openxlsx` ne l'est pas : le paquet n'est pas installé, comme prévu.
- **Résultat** : **visa avec réserves.**
  - Repris conformément : G1, G2, m3, m4, m6, m7, R2, E4, README `a0fe3e2`.
  - Repris avec écart acceptable : m5, A, B, C, #574-5, D, R3.
  - Réserves mineures : m-a (description du texte canonique de l'empreinte) et m-b (renvoi l. 3960).
  - Facultatifs : m-c, et le renvoi l. 4779.
  - Aucun bloquant, aucun majeur. Aucune phrase n'annonce de changement de σ_USP, d'une p-value ou d'un verdict.
- **Preuves vérifiées** :
  - Code : `R/engine.R` l. 8013-8017 (`.en_numerique`), 9066-9070 (booléens de la voie de repli), 9071-9072 (affectation `m[cbind(lig, col)] <- val`, la dernière l'emporte), 8492-8496 et 8993-9045 (table des chaînes partagées), 9144-9185 (`engine_empreinte`) ; `R/display_helpers.R` l. 3263 ; `app.R` l. 280.
  - Mesures sur la voie de repli : doublon B2, en fin de ligne et à la suite (lu 999, `ok TRUE`) ; doublon préfixé (non lu, 100) ; colonne `t="b"` (refusée) ; table en UTF-8 invalide, avec et sans forme Q-F (pas de refus, chaîne non lue, cellule refusée) ; contre-épreuve en UTF-8 valide (refus Q-F).
  - Simulation du retour d'`openxlsx` par une colonne logique : séries (`ok TRUE`, 1/0) et triangle (`ok TRUE`, C(0,4) = 1).
  - `controle_doc_nd.R` (liste A : 0) ; `concordance_doc_moteur.R --strict` (0 écart) ; `sprintf("%.17g")` mesuré.
- **Hypothèses** : comportement d'`openxlsx` (colonne logique, doublon, erreur R sur UTF-8 invalide) tel que mesuré par l'audit (ii) avec 4.2.5.2 et par `docwriter` avec 4.2.9.
- **Non vérifié** :
  - le chemin `openxlsx` dans son ensemble ;
  - les mesures sous une locale Windows ;
  - le texte primaire du règlement délégué (UE) 2026/269 (point 39) et article 2), inaccessible depuis l'agent ;
  - la compilation du `.tex` ;
  - les chiffres de `sec:graines`, non remesurés ici : ils ont été remesurés sur le poste à l'avis précédent et ne sont pas modifiés par le diff.
- **Informations manquantes** : `openxlsx` absent ; EUR-Lex inaccessible.
- **Décisions non résolues (mainteneur)** : renvoi l. 3960 (recommandé) et l. 4779 (facultatif) ; reprise de m-a et m-c.
- **Critères déclenchés** : aucun. Pas de changement de résultat, pas de désaccord avec `audit`, `regulatory` ni un ADR. La lecture de R3 repose sur `regulatory`, sans contradiction.
- **Prochaine action recommandée** : `docwriter` fait un commit `docs:` pour m-a, et pour m-b et m-c selon la décision du mainteneur. `actuary` revoit ce seul diff, puis l'étape 9 part de `git fetch` et de `origin/main...HEAD`.
