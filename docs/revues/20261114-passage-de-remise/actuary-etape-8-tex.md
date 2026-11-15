# Avis d'`actuary-approfondi`, KR étape 8 : diff cumulé du `.tex` (14/11/2026)

> *Rapport de l'agent `actuary-approfondi` (IA), rendu à la session principale le 14/11/2026 et versé intégralement par elle (Q-54-10). Arbre lu : `claude/passage-de-remise` `e86e27c`.*

## Avis d'`actuary-approfondi` : KR, étape 8, validation du diff cumulé du `.tex` (règle 9)

Arbre lu : `claude/passage-de-remise`, tête `e86e27c`. Le code n'a pas bougé depuis le gel : `git diff a2f9c3a HEAD -- R/ app.R DESCRIPTION tests/` est vide. Je n'ai rien écrit dans le dépôt.

**Préalable de procédure à transmettre (pour l'étape 9 aussi).** Sur le poste, la branche locale `main` est en retard, à `7b8d2af`. `git diff main...HEAD -- docs/latex/doc_tests_usp.tex` donne donc 674 lignes et embarque K2b. Le bon diff est `origin/main...HEAD`, base `f8ff168` : +94 / −45 lignes, soit exactement les sept commits de `docwriter` soumis. C'est ce diff que j'ai validé. Il faut lancer `git fetch` avant la revue finale de l'étape 9.

### Lot 1 : `06d6717` (#573). **Conforme.**
- Le rappel « la méthode n° 2 reste ouverte » est retiré aux deux endroits (l. 4397 et 4408), comme dans le code. « ce point prévoyant aussi » est exact.
- La nouvelle puce de `sec:mw` (l. 14745-14752) reprend le texte de la matrice de `regulatory`. Le fond actuariel est inchangé : le refus de R̂ < 0 reste une interprétation, appuyée sur deux appuis et une orientation.
- « Un troisième appui » (l. 14769) est cohérent avec la phrase d'introduction (l. 14733).
- Aucun constat.

### Lot 2 : `ea9449e` (#559). **Conforme.**
- **Ancrage** : je l'ai vérifié contre le code (`.retirer_lignes_colonnes_vides()`, l. 7982-7997).
  - Une colonne vide intercalée, avec ou sans en-tête, reçoit « annee de developpement manquante presumee ».
  - Une colonne vide qui porte un en-tête, en bord de tableau à gauche comme à droite, reçoit le motif distinct « annee de developpement sans valeur ».
  - Le `.tex` le dit exactement. L'argument de l'enchaînement des facteurs f̂ par D(4)(c) est juste du point de vue actuariel.
- **Inventaire d'`engine_valider_serie_retenue()`** : conforme au code. Si T est refusé : série non tronquée, avertissements retirés, `validation$T` à `NA`. Si les longueurs diffèrent : pas de troncature, refus par le motif de longueur.
- **Hors `.tex`, mineur (gel, issue à rédiger)** : le commentaire de `R/engine.R` l. 7753-7755 dit encore qu'une colonne « portant un en-tete » reçoit « manquante presumee ». C'est faux pour une colonne en bord.

### Lot 3 : `1350e13` (#548, `sec:graines`, avec `I.md`). **Conforme avec réserves.**

Je l'ai remesuré sur le poste (Windows 11, R 4.3.3), le 14/11 :
- `Rscript tests/comparer_references.R --deux-parts` sur les six cas (52 s) ;
- `Rscript tests/test_reproductibilite.R`.

Les chiffres du texte sont tous retrouvés :
- 3,454e-8 sur les quatre cas à δ̂ = 1. J'ai vérifié δ̂ = 1 dans `premium`, `reserve1`, `premium_ii6` et `premium_net`, et δ̂ = 0,664 dans `premium_interieur`.
- Merz-Wüthrich : 8 feuilles sur 18 725, toutes dans `bootstrap$stats_boot`, donc bien des « tirages bootstrap ».
- Aucune feuille `parametre_final` dans la liste au seuil 0.
- Aucune feuille `p_mc`, `p_min_mc`, `B_effectif` ni `p_mc_regime` dans cette liste. Seules y figurent des p non simulées, à 4e-15 au plus.
- Les deux feuilles de `premium_interieur` ont les valeurs écrites.
- Les marges 1,32e-3 et 1,96e-4 reprennent l'avis sur #548 (je ne les ai pas recalculées). Elles valent respectivement 727 et 110 fois la dérive maximale (1,814e-6), ce que dit le texte.
- Le volet `identical()` ne signale rien.

**Paraphrase du critère.** Je l'ai confrontée point par point au texte de l'avis (§ 2) ; elle est fidèle.
- (1) part non numérique et structure ; (2) `parametre_final` ; (3) p-values, `B_effectif` (« nombre de réplications retenues ») et `p_mc_regime`, qui ne porte que des décomptes et des réglages (vérifié par `str()`) ; p Monte-Carlo identiques au bit ; (4) `identical()` ; (5) marge à l'observée ; puis la clause d'arrêt.
- Les seuls éléments omis sont procéduraux : « listée et expliquée », renvoi à `actuary` ou au mainteneur. Leur omission est légitime au regard de CONVENTIONS.
- « Le poste … satisfait ce critère » : c'est un résultat mesuré, recoupé par ma remesure. Il est acceptable tel quel (voir aussi m7).

**Constats :**

- **G1, majeur : « La cause de ces deux écarts n'est pas établie. »**
  - Lue par l'ACPR dans la section reproductibilité, la phrase annonce un écart d'origine inconnue.
  - Or l'origine est établie par élimination : même code (md5 égaux au gel), mêmes données, mêmes graines, résultat identique au bit d'une exécution à l'autre sur chaque machine, et 0 feuille non identique sous Linux (avis sur #548).
  - Seul le mécanisme numérique est inconnu. La compensation dans la somme expliquée de BP est probable, non démontrée.
  - Remplacer par :
    > Ces deux écarts viennent de la plateforme~: à code, données et graines identiques, chaque machine reproduit son propre résultat au bit près, et la CI reproduit ses références~; le mécanisme numérique qui les porte au-delà du seuil, pour cette seule réplication, n'est pas établi.

- **G2, mineur : « Ces tirages, petits (…) et donc jugés en relatif ».**
  - Le lien causal est faux. Toute valeur de référence supérieure à 1e-6 est jugée en relatif (la même section le dit plus haut). La petitesse explique seulement qu'un petit écart absolu (2,87e-8 et 4,23e-9, que j'ai recalculés) dépasse le seuil.
  - Remplacer par :
    > Ces tirages sont petits ($0{,}0158$ et $0{,}0024$)~: jugés en relatif, comme toute valeur dont la référence dépasse $10^{-6}$, des écarts absolus d'environ $2{,}9\cdot 10^{-8}$ et $4{,}2\cdot 10^{-9}$ y franchissent le seuil. Ils sont loin des statistiques observées ($0{,}0750$ et $0{,}0551$)~: l'écart relatif minimal de toute réplication à la statistique observée, $1{,}3\cdot 10^{-3}$ et $2{,}0\cdot 10^{-4}$, dépasse cent fois la dérive maximale, …
  - La suite de la phrase est inchangée.

- **m3, mineur : « la dérive reste sous 3,454·10⁻⁸ ».** La valeur maximale est atteinte. Écrire « la dérive atteint au plus $3{,}454\cdot 10^{-8}$ en relatif ».

- **m4, mineur : la tournure « ne diffère au bit près » (deux occurrences) est ambiguë.** Elle se lit « diffère à un bit près ». Écrire :
  - « aucune valeur de \code{parametre\_final}, donc aucun $\sigma_{\mathrm{USP}}$, ne s'écarte de sa référence, fût-ce d'un bit » ;
  - « et chaque p-value de Monte-Carlo est identique au bit près à sa référence ».

- **m5, mineur : Merz-Wüthrich, « d'ordre 10⁻¹⁶, relève de l'arrondi du dernier bit (constat, non démontré) ».**
  - La parenthèse mêle un fait mesuré et une interprétation.
  - Mesuré : les 8 écarts valent 3, 2, 2, 1, 1, 1, 1 et 1 unités du dernier bit (ulp) des valeurs concernées. Calcul : écart × |x| / 2^(⌊log2|x|⌋−52).
  - Remplacer par :
    > mais son écart, au plus $4{,}545\cdot 10^{-16}$ en relatif, vaut une à trois unités du dernier bit des valeurs concernées (mesuré)~; il est de l'ordre de l'arrondi en double précision, sans que son mécanisme soit établi.

- **m6, mineur : « un écart au-delà du seuil y signale un changement de résultat, non une dérive de plateforme ».**
  - C'est trop absolu : la même section dit que GitHub met à jour l'image du système.
  - Remplacer par :
    > un écart au-delà du seuil y est traité comme un changement de résultat, à identifier et à expliquer, la CI reproduisant ses références au bit près~; une mise à jour de l'image du système, consignée, peut aussi en produire un.

- **m7, facultatif.** Écrire « Mesuré sur le code que décrit le présent document, le poste ci-dessus satisfait ce critère. »

- **`I.md`** : conforme. Le texte retiré est cité intégralement, les motifs sont donnés et l'enseignement sur la version mineure de R n'est pas reconduit, ce qui est juste.

### Lot 4 : `dcd43e2` puis `e8a60d4` (#574, #575). **Conforme avec réserves.**

**Limite de #575.** Le texte est exact. Les versions sont mesurées et nommées (4.2.5.2 sous Linux ; 4.2.9 sous Linux et sous Windows), l'hypothèse est déclarée non vérifiée, et l'exposition d'un poste qui a installé `openxlsx` est dite. Le déplacement par `e8a60d4` hors de l'énumération des « trois limites » est correct.

- **A, majeur : la phrase du contrôle compensatoire de #574-1 surestime l'empreinte.**
  - « qu'un tiers peut recalculer à partir des valeurs de la source » ne tient que si le tiers reproduit le texte canonique exact. Ce texte est fait d'en-têtes `t;xt;yt` ou `triangle;n;m`, de valeurs en `%.17g`, du séparateur `;`, de fins de ligne LF et d'UTF-8. Le `.tex` ne le décrit nulle part ; `texte_donnees` n'est ni affiché ni restitué par le rapport figé (grep).
  - Le code déclare lui-même « Constance entre plateformes : attendue, non verifiee » (`R/engine.R` l. 9127).
  - L'empreinte n'apporte rien si on la recalcule avec le lecteur de l'outil, qui reproduit la même valeur fausse. Le seul contrôle effectif est la relecture contre la source.
  - Remplacer, à partir de « et le rapport figé restitue … », par :
    > et le rapport figé restitue les données du calcul et porte, dans sa table «~Empreintes~», l'empreinte md5 de leur texte canonique (\code{engine\_empreinte()}~: une ligne d'en-tête, puis une ligne par année ou par ligne du triangle, valeurs écrites à 17 chiffres significatifs et séparées par «~\code{;}~»), fonction des seules valeurs utilisées. Elle identifie ces valeurs~; elle ne révèle une valeur fausse que si un tiers la recalcule à partir des valeurs de la source, sans passer par le lecteur de l'outil, en reproduisant ce texte~; sa constance entre plateformes est attendue, non vérifiée.
  - Même nuance au README (voir plus bas).

- **B, majeur : un complément de #574 qui donne lui aussi une valeur fausse sans message n'est pas consigné.**
  - Il s'agit du constat m1 de l'`audit` `high` (ii), versé en commentaire de #574 : deux cellules de même référence, la dernière l'emporte sans message, sur les deux chemins. La mesure de l'`audit` : `<c r="E2">` répété, `ok TRUE`, C(0,4) = 999.
  - C'est la même classe que #574-1, que le plan a décidé de consigner. Le `.tex` (l. 4621) ne vise qu'un attribut `r` répété dans une même balise, pas deux cellules.
  - Ajouter après la phrase de `<x:si>` :
    > Deux cellules de même référence (\code{<c r="E2">} écrit deux fois) ne sont pas refusées~: la dernière l'emporte, sans message, sur les deux chemins (valeur fausse, mesuré)~; aucun tableur n'est supposé écrire cette forme (hypothèse non vérifiée).
  - Puis écrire « Faute de refus, le contrôle de ces valeurs revient à l'utilisateur ».
  - `docwriter` remesure avant d'écrire « mesuré ».

- **C, majeur sous condition (décision du mainteneur, dégel ou non).**
  - Constat : le majeur M1 de l'`audit` `high` (ii). Sur le chemin `openxlsx`, une colonne dont toutes les cellules à valeur sont booléennes (`t="b"`) ou des textes « TRUE »/« FALSE » devient logique, puis est lue 1 par `.en_numerique()`. Mesuré par l'`audit` avec `openxlsx` 4.2.5.2 : un triangle accepté avec C(0,4) = 1 ; une série `xt` booléenne donne `ok TRUE`, σ = 0,20176. La voie de repli, elle, refuse.
  - Cette forme peut venir d'un vrai tableur : une cellule booléenne saisie s'écrit `t="b"`. C'est donc plus exposant que #574-1, et la limite n'est pas dans le `.tex`.
  - Les lignes d'inventaire l. 832 et 877 (« cellule non numérique refusée ») sont fausses sur ce chemin.
  - Si le code reste gelé, ajouter dans `sec:controles` :
    > Sur le chemin \code{openxlsx}, une colonne dont toutes les cellules à valeur sont booléennes (\code{t="b"}) ou des textes «~\code{TRUE}~» ou «~\code{FALSE}~» est rendue logique, puis convertie par \code{.en\_numerique()}, \code{TRUE} étant lu~1, sans message (valeur fausse, mesuré)~; la voie de repli la refuse comme cellule non numérique. Un tableur peut écrire une cellule booléenne~; le contrôle de l'utilisateur décrit ci-dessus s'applique.
  - Ajouter aussi une ligne au README. En cas de dégel, il n'y a rien à écrire.

- **#574-3, -4 et -5 : réponse à la question de `docwriter`. Leur consignation n'est pas requise.**
  - -3 (erreur R brute sur une référence hors bornes) et -4 (coût quadratique) ne produisent aucune valeur fausse : ce sont un refus et une affaire de performance sur fichier forgé.
  - -5 (UTF-8 invalide) ne produit pas non plus de valeur fausse, mais il rend inexacte la généralité « Sont refusées de même, avant l'appel à openxlsx et sur les deux chemins » (l. 4649) pour les contrôles Q-F, P2 et X1.
  - **Mineur, facultatif**, après remesure par `docwriter` :
    > Ces refus supposent une table des chaînes partagées en UTF-8 valide~; une table en UTF-8 invalide n'y est pas soumise, sans valeur fausse (mesuré).

### Lot 5 : `7fceed2` (E-L1-1, règlement délégué (UE) 2026/269). **Conforme avec réserves.**

- **Fond actuariel vérifié.**
  - Le sens est juste : sans réassurance non proportionnelle après l'application, l'outil garde 0,8·σ brut là où le texte modifié retient σ brut. Le résultat est donc non prudent.
  - L'écart −(1−c)(1−NP)σ = −0,0082 correspond à `premium` 0,1114524114 contre `premium_net` 0,1032524114, que j'ai remesurés.
  - La réserve sur σ(res,s) en présence d'une couverture pour développements défavorables est dite non établie, ce qui est honnête.
- **Sources secondaires.** Elles confirment adoption le 29/10/2025, publication le 18/02/2026 et application le 30/01/2027 (Debevoise, documents du Conseil). Je n'ai pas pu lire le texte primaire : EUR-Lex a rendu des pages vides. `regulatory` et `docwriter` l'ont lu.
- **D, mineur, à trancher : la date du 30/01/2027.**
  - Le renvoi à « la date d'application de cet acte, fixée par son article 2 » est exact et vérifiable. Il ne suffit pas pour un lecteur de l'ACPR : la borne qui dit si l'outil vaut pour son dossier est le fait décisif, et la borne inférieure, elle, est écrite en clair (« 1er janvier 2020 », l. 2185). L'asymétrie oblige à une recherche externe.
  - Une date d'application réglementaire n'est pas de la vie du dépôt. CONVENTIONS admet deux lectures : la règle en prose « ni date postérieure au 31 décembre 2025 », et l'esprit de l'exception E4 (dates réglementaires, le format « 25.3.2015 » étant hors motifs).
  - Je recommande une exception nommée (« dates d'application d'un acte réglementaire », plage `sec:segments`), puis :
    > L'outil ne vaut donc que pour un calcul dont la date de référence est antérieure au 30~janvier 2027, date d'application de cet acte fixée par son article~2.
  - Au même endroit, on peut écrire « série~L, 2026/269 du 18.2.2026 », comme pour L 168 du 25.6.2019.
- **Hors `.tex`, mineur (gel, issue)** : l'en-tête de `R/engine.R` (l. 57-61) ne porte que la borne inférieure.

### Lot 6 : `f174f5d` (version 3.8). **Conforme.**
`\versiondoc` vaut 3.8 ; `\datedoc` sera fixé à l'étape 11.

### README (`e86e27c`, « Prérequis »). **Conforme avec réserves.**
- **Mineur.** « sous `openxlsx` 4.2.5.2 et 4.2.9 (mesurés sous Linux et sous Windows 11) » laisse croire que 4.2.5.2 a été mesurée sous Windows. Écrire « sous `openxlsx` 4.2.5.2 (mesuré sous Linux) et 4.2.9 (mesuré sous Linux et sous Windows 11) ».
- La puce #574-1 se nuance comme en A : « … l'empreinte md5 des données du calcul (table « Empreintes », `engine_empreinte()`) ; recalculée à partir des valeurs de la source, sans le lecteur de l'outil, elle révèle une valeur lue de travers. »
- Ajouter les points B, et C selon la décision.

### Constats hors périmètre (issues à rédiger, à créer sur accord du mainteneur)
1. `.claude/rules/moteur.md` (« Reproductibilité ») porte encore « seuil ≈ 3 fois ce maximum, décision M9 », ce que l'annotation de l'ADR 0006 du 14/11 contredit. C'est le domaine `claude:`, à modifier sur instruction du mainteneur.
2. `tests/comparer_references.R` imprime « ce n'est plus de la derive de plateforme » pour `premium_interieur` sur le poste, ce que le `.tex` et l'annotation contredisent. `tests:`, gel.
3. `R/engine.R` : commentaire l. 7753-7755 périmé (lot 2) et en-tête l. 57-61 sans borne supérieure (lot 5). Gel.

### Retour
- **Statut** : `complet`. Chaque lot a un verdict. Les chiffres de `sec:graines` sont remesurés, les assertions sur le code relues.
- **Résultat** : lots 1, 2 et 6 conformes ; lots 3, 4, 5 et README conformes avec réserves. Aucun bloquant. Les majeurs : G1 (lot 3), A et B (lot 4), C sous condition. Aucun ne touche σ_USP, une p-value ni un verdict.
- **Preuves vérifiées** :
  - `comparer_references.R --deux-parts` (six cas) et `test_reproductibilite.R` sur le poste ;
  - δ̂ des six références ; écarts en ulp ; écarts absolus ; structure de `p_mc_regime` ;
  - code de `.retirer_lignes_colonnes_vides()`, `engine_valider_serie_retenue()` et `engine_empreinte()` ;
  - rapports d'`audit` (ii) et matrice de `regulatory` (lot 1) ; issue #574 et son commentaire ; CONVENTIONS (A10, E4, E10).
- **Hypothèses** : origine de plateforme des deux écarts, par élimination ; marges 1,32e-3 et 1,96e-4 reprises de l'avis sur #548, non recalculées.
- **Non vérifié** :
  - le texte primaire du règlement 2026/269 (sources secondaires seulement) ;
  - les mesures de l'`audit` sur M1 et m1, non rejouées ;
  - #574-5, non remesuré ;
  - le volet `identical()`, jugé sur l'absence du message comme au relevé de l'étape 3.
- **Informations manquantes** : EUR-Lex inaccessible depuis l'agent.
- **Décisions non résolues** (mainteneur) :
  - (1) exception de CONVENTIONS pour la date du 30/01/2027 (point D) ;
  - (2) dégel ou consignation pour le M1 booléen (point C) ;
  - (3) issues hors périmètre 1 à 3.
- **Critères déclenchés** :
  - deux lectures d'une règle de CONVENTIONS sur une date réglementaire : problème de documentation, non de source ;
  - limite à valeur fausse connue (M1 de l'`audit`) que le plan de KR n'a pas couverte ;
  - aucun changement de résultat ; aucun désaccord avec `audit` ni avec l'ADR 0006.
- **Prochaine action recommandée** : `docwriter` reprend G1, G2, m3 à m6, A et B (et C selon la décision) en commits `docs:`. La session corrige le README. `actuary` revoit seulement le diff de ces reprises. L'étape 9 part de `git fetch` et de `origin/main...HEAD`.

Sources :
- [Debevoise, European Commission Adopts Amendments to the Solvency II Delegated Regulation](https://www.debevoise.com/insights/publications/2026/03/european-commission-adopts-amendments-to-the-solve)
- [Conseil de l'UE, ST-14846-2026-INIT](https://data.consilium.europa.eu/doc/document/ST-14846-2026-INIT/fr/pdf)
