# S6, étape 6, T0 : textes fixés par `actuary`, renvois contrôlés par `regulatory` (21/11/2026)

Sous-étape T0 du découpage de l'étape 6 (consultation Fable d'`architect`, `architect-6-forme-etape6-fable.md`, § 1.6 ; décisions E-21/11 (D2)). Les deux rapports sont versés intégralement par la session ci-dessous. Les textes **définitifs**, transmis à `coder-approfondi` pour C1, C2 et C3, sont ceux de la section suivante : ceux d'`actuary`, avec les deux corrections de `regulatory` ((t2) et (t4)).

## Textes définitifs (chaînes R, sans accents ; `ù` pour « où » dans `texte_formule()`)

**(t1)** avertissement de `mw_valider_triangle()` si I > J (C3), en tête de `avt` dans le bloc `if (!length(err))` ; `sprintf(…, nrow(tri), ncol(tri), nrow(tri) - ncol(tri))` :

"Triangle a %d annees d'accident et %d annees de developpement : verifier qu'aucune annee de developpement ne manque en fin de tableau (un triangle carre prive de ses dernieres colonnes a la meme forme). Le calcul tient pour acheve a la derniere annee de developpement fournie le developpement des annees d'accident i = 0 a %d (reserve nulle) : hypothese a justifier par l'entreprise, l'annexe XVII, section D, point (2)(d), ne l'exigeant que de la premiere annee d'accident."

**(t2)** mention conditionnelle du `detail` de la ligne M6 « Extrapolation de sigma… » si I > J (C1), jointe par `.engine_joindre()` ; `sprintf(…, aj$I - aj$J + 1L, format(aj$sigma2_Jm1_direct, digits = 6, decimal.mark = "."), aj$I - aj$J)` ; à déclarer dans `MENTIONS` (`tests/unitaires/outils_unitaires.R`) comme `M23`, mesure de #514 à refaire sur ce texte :

"Trapeze (I > J) : la regle de minimum s'applique a sigma2_(J-1) par prescription de l'annexe XVII, D(5)(d)(ii), seconde ligne, bien que la colonne J-1 porte %d facteurs, dont l'estimateur direct, %s a %d degre(s) de liberte, reduit les residus de cette colonne (tests, influence, vivier du bootstrap) sans entrer dans la MSEP ni dans la simulation : valeur donnee pour information."

**(t3)** `plots_data$usage_sigma` (C1), vecteur nommé :

```
sigma         = "sigma_(J-1) de la regle de minimum (D(5)(d)(ii)) : MSEP et simulation"
sigma_residus = "sigma_(J-1) estime directement : residus de Mack et tests"
```

**(t4)** variante de `texte_formule()` pour `m$I > m$J` (C2) ; arguments `m$I - m$J`, `100 * p$credibilite`, `m$bareme`, `as.integer(m$T)` :

```
paste("Formule appliquee (annexe XVII, section D, paragraphe 4) :",
      "sigma_USP = c x racine(MSEP) / R + (1-c) x sigma_standard,",
      "ù R = somme_i (C^(i,J) - C(i,min(I-i,J))) est la reserve chain-ladder totale (min(I-i,J) : convention de l'outil pour I > J, le texte ecrivant C(i,I-i)),",
      "a laquelle les annees d'accident i = 0 a %d, observees jusqu'a J, ne contribuent pas,",
      "sans correction de taille finie, avec c = %.0f %% (bareme %s, duree %d ans).")
```

Écart de forme confirmé par `actuary` (§ 1.2, point 5, de la consultation) : `ajustement$sigma2_Jm1_direct` reste absent sur un carré ; lecture par `aj[["sigma2_Jm1_direct"]]`.

Constats mineurs écartés (ADR 0018, critère : aucun) : deux formes de numérotation dans les chaînes du moteur (« section D, point (2)(e) » et « section D, paragraphe 2, point f) ») ; (t1) non émis quand un trapèze est refusé pour une autre cause.

## Rapport d'`actuary`

# T0 : textes de l'étape 6, fixés par actuary, 21/11/2026

Base : tête `8b9c920`. Lus : consultation d'`architect` (§ 1.2 à 1.6), décisions D2 et Q-A1, spécification 2a (§ 4, Q-2a-4, Q-2a-6), `mw_valider_triangle()`, `mw_ajuster()`, `.mw_detail_extrapolation()`, `plot_mw_facteurs()`, `texte_formule()`, `verifier_detail()` et `MENTIONS`, et l'annexe XVII, D(2), dans le texte consolidé.

Convention vérifiée : les chaînes voisines n'ont aucun accent. Seule exception, `texte_formule()`, qui écrit déjà « où » par `où` (12 occurrences de `\u00` dans `display_helpers.R`). (t4) garde cet échappement.

## (t1) Avertissement de `mw_valider_triangle()` si I > J

Il se place en tête de `avt`, dans le bloc `if (!length(err))`. Le `sprintf` prend trois arguments : `nrow(tri)`, `ncol(tri)`, `nrow(tri) - ncol(tri)`. Le troisième vaut I − J ; sans lui, le message citerait un « I − J » que l'utilisateur ne peut pas lire.

"Triangle a %d annees d'accident et %d annees de developpement : verifier qu'aucune annee de developpement ne manque en fin de tableau (un triangle carre prive de ses dernieres colonnes a la meme forme). Le calcul tient pour acheve a la derniere annee de developpement fournie le developpement des annees d'accident i = 0 a %d (reserve nulle) : hypothese a justifier par l'entreprise, l'annexe XVII, section D, point (2)(d), ne l'exigeant que de la premiere annee d'accident."

- Justification : Q-2a-6 (nommer la géométrie, garde contre une colonne perdue, hypothèse déclarée).
- Le renvoi à D(2)(d) dit seulement ce que ce point exige, c'est-à-dire la première année d'accident (texte consolidé relu). Il ne prête donc rien au règlement, ce qui répond au point d'attention E4. [à contrôler par regulatory]
- « Reserve nulle » est conforme au code : `derniers` = C(i, min(I−i, J)) dans `mw_ajuster()`.

## (t2) Mention conditionnelle M6 (I > J)

Elle est jointe en fin de `detail` par `.engine_joindre()` : le détail actuel finit par un point, la jonction est donc une espace. Le `sprintf` prend `aj$I - aj$J + 1L`, `format(aj$sigma2_Jm1_direct, digits = 6, decimal.mark = ".")`, `aj$I - aj$J`.

"Trapeze (I > J) : la regle de minimum s'applique a sigma2_(J-1) par prescription du texte, bien que la colonne J-1 porte %d facteurs, dont l'estimateur direct, %s a %d degre(s) de liberte, reduit les residus de cette colonne (tests, influence, vivier du bootstrap) sans entrer dans la MSEP ni dans la simulation : valeur donnee pour information."

- Justification : Q-2a-4 et R-3. Les usages listés sont ceux de `.mw_sigma2_residus()`, lue par `mw_residus()`, `mw_influence()` et `mw_identifiabilite_intra()`.
- « Par prescription du texte » (D(5)(d)(ii) pour j = J−1 quel que soit I) : [à contrôler par regulatory].
- **Règle #514, mesurée** (`Rscript`, détail réel de `.mw_detail_extrapolation()` sur 8×5, 8×6 et 8×7, plus la mention) :
  - le détail actuel fait 283 à 286 caractères en 2 phrases ;
  - sans déclaration dans `MENTIONS`, l'ensemble donne 3 phrases et 636 caractères, et `verifier_detail()` est en ÉCHEC ;
  - déclarée comme `M23`, le texte propre reste à 2 phrases et 283 à 286 caractères, et `verifier_detail()` est OK sur les trois cas.
  - La déclaration est donc obligatoire. Expression testée : le texte fixe échappé, avec `\d+` pour les deux entiers et `.rx_num` pour la valeur.
- **Règle #76** : σ̂²_dir vient de `mw_ajuster()` et non du bootstrap, donc aucun nombre issu du bootstrap n'est imprimé.

## (t3) `plots_data$usage_sigma`

```
sigma         = "sigma_(J-1) de la regle de minimum (D(5)(d)(ii)) : MSEP et simulation"
sigma_residus = "sigma_(J-1) estime directement : residus de Mack et tests"
```

- Justification : forme (ii) de Q-A1.
- Longueurs : 69 et 57 caractères, sous les 79 de `.LEGENDE_SIGMA_REGLE`, qui tient en base R à 395 px. Pour plotly, la coupure se fait au premier " : " (63 et 32 caractères avant la coupure) ; `app-review` doit le vérifier sur rendu réel.
- Renvoi : [à contrôler par regulatory].

## (t4) `texte_formule()`, variante `m$I > m$J`

```
paste("Formule appliquee (annexe XVII, section D, paragraphe 4) :",
      "sigma_USP = c x racine(MSEP) / R + (1-c) x sigma_standard,",
      "où R = somme_i (C^(i,J) - C(i,min(I-i,J))) est la reserve chain-ladder totale,",
      "a laquelle les annees d'accident i = 0 a %d, observees jusqu'a J, ne contribuent pas,",
      "sans correction de taille finie, avec c = %.0f %% (bareme %s, duree %d ans).")
```

- Arguments : `m$I - m$J`, `100 * p$credibilite`, `m$bareme`, `as.integer(m$T)`.
- Justification : c'est la convention (B) telle que codée (`dernier_observe`), et l'ancien texte cite un C(i, I−i) qui n'existe pas pour i < I−J. [convention (B) de D(4) à contrôler par regulatory]

## Point 2 : écart du § 1.2, point 5

**Confirmé.**
- Le « NA pour un carré » de ma spécification 2a visait un champ restitué dans tous les cas. Q-A1, décidé après, le porte par `plots_data$facteurs$sigma_residus` et le drapeau `sigma_residus_direct`.
- Sur un carré, l'estimateur n'existe pas (un facteur, 0 degré de liberté).
- Un NA dans `ajustement` changerait l'objet du carré et le code mesuré à l'étape 5.
- Condition : la lecture se fait par `aj[["sigma2_Jm1_direct"]]` (correspondance exacte), comme le fait `.mw_sigma2_residus()`.

## Point 3 : autres points de fond

- Le projet (t2) d'`architect` omettait la simulation du bootstrap parmi les usages exclus ; c'est corrigé ci-dessus. Mineur, aucun critère.
- (t1) : l'avertissement n'est émis qu'en l'absence d'erreur. Un trapèze refusé pour une autre cause ne reçoit pas le signal de géométrie. C'est acceptable : son refus est déjà un signal. Mineur, aucun critère.
- Je n'ai trouvé rien d'autre de faux dans la forme.

## Retour

- **Statut** : complet pour le fond. Les renvois sont marqués pour `regulatory`.
- **Preuves vérifiées** : mesures #514 par `Rscript` sous `LC_ALL=C.UTF-8` (script `/tmp/claude-0/-home-user-outil-usp/45d0bf23-bb8a-56cb-8f97-92627ff53473/scratchpad/t0/t2.R`) ; longueurs des textes (`l2.R`, même dossier) ; texte de D(2)(d). **Hypothèse** : tenue de la légende plotly à 395 px.
- **Critères déclenchés** : aucun nouveau.
- **Hors périmètre** : aucun.
- **Prochaine action** : contrôle des renvois par `regulatory`, puis C1.

termine sans question

## Contrôle de `regulatory`

Contrôle T0 des renvois de (t1) à (t4), base `8b9c920`. Je n'ai rien écrit dans le dépôt. Sources : texte consolidé, D(2) relu dans le xhtml ; D(4) et D(5)(d)(ii) d'après mes lectures à l'image, `docs/revues/20261120-s6-trapeze/regulatory-1-lecture-trapeze.md`, points 3 et 4a.

**(t1) Conforme.**
- D(2)(d) dit : « pour la première année d'accident, le montant de paiements cumulé de la dernière année de développement [...] inclut tous les paiements de l'année d'accident à quelque différence non significative près ». Le renvoi est exact : le texte ne l'exige que de la première année d'accident.
- Rien n'est prêté au règlement (E4) : « hypothese a justifier par l'entreprise » est présentée comme une exigence de l'outil.
- Numérotation : dans la nomenclature de l'UE, (2) est un paragraphe et (d) un point. Le moteur emploie deux formes :
  - « section D, point (2)(e) » dans le message MW-04 de la même fonction (`R/engine.R` l. 13150) ;
  - « section D, paragraphe 2, point f) » aux l. 713 et 1079.
- « point (2)(d) » reprend la forme de MW-04, sa voisine immédiate : à garder. L'harmonisation des deux formes est un constat mineur, critère ADR 0018 : aucun.

**(t2) À corriger (précision du renvoi seulement).**
- Sur le fond, c'est exact : D(5)(d)(ii), seconde ligne, vaut pour « j = (J – 1) » sans condition sur I, dans les deux versions du texte (vérifié à l'image).
- Mais « par prescription du texte » ne dit pas quel texte. Les chaînes voisines le nomment (`R/engine.R` l. 13702 et 13744 : « l'annexe XVII, D(5)(d)(ii) »).
- Formulation corrigée, début de la chaîne :
  "Trapeze (I > J) : la regle de minimum s'applique a sigma2_(J-1) par prescription de l'annexe XVII, D(5)(d)(ii), seconde ligne, bien que la colonne J-1 porte %d facteurs, [...]" (suite inchangée).
- L'expression de `M23` est à mettre à jour en conséquence, et la mesure #514 est à refaire.

**(t3) Conforme.**
- « (D(5)(d)(ii)) » a la même forme courte que `R/display_helpers.R` l. 176.
- `.LEGENDE_SIGMA_REGLE` (l. 1912) écrit « annexe XVII, D(5)(d)(ii) ». Le graphique est propre à la section D, l'ajout n'est donc pas nécessaire ; il ferait d'ailleurs passer la chaîne au-delà de 79 caractères.

**(t4) À corriger (E4).**
- « annexe XVII, section D, paragraphe 4 » est identique à la chaîne actuelle (l. 2496), et le renvoi est exact. Sous la lecture (B), la phrase sur les années i = 0 à I−J est exacte : contribution nulle à R, par Ĉ(i,J) = C(i,J).
- En revanche, le texte n'écrit que C(i,I−i), et Ĉ n'est défini par D(4) que pour i ≥ I−J. Sous le titre « Formule appliquee (annexe XVII, [...] paragraphe 4) », écrire min(I−i, J) sans le signaler prête cette écriture au texte.
- Formulation corrigée de la troisième ligne :
  "où R = somme_i (C^(i,J) - C(i,min(I-i,J))) est la reserve chain-ladder totale (min(I-i,J) : convention de l'outil pour I > J, le texte ecrivant C(i,I-i)),"
- Le reste est inchangé : D n'a pas de correction de taille finie ; la durée I + 1 relève de G(3)(c).

**Numérotation à employer :** « annexe XVII, section D, point (2)(d) » pour (t1), « paragraphe 4 » pour (t4), « D(5)(d)(ii) » pour (t2) et (t3). Tout cela est cohérent avec l'existant, au mélange de formes près signalé en (t1).

termine sans question
