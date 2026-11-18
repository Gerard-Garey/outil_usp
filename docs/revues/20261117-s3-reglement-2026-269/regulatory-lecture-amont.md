# Lecture amont du règlement délégué (UE) 2026/269 : S3, étape 1 (D1), #504

> *Rédigé par l'agent regulatory (IA), le 17/11/2026.* Circuit 2, effort `high`, lecture seule. Branche `claude/reglement-2026-269` à `d6a9ecc` (arbre propre). md5 lus : `R/engine.R` `a73c2f2028d2005d64d1a6a215c14900`, `docs/latex/doc_tests_usp.tex` `a294f76429f64d47a2d7fcd937e8e97c`. Rien n'a été écrit dans le dépôt.

## 0. Sources et méthode

| Pièce | Accès | Empreinte |
|---|---|---|
| **Texte primaire FR** : règlement délégué (UE) 2026/269 du 29.10.2025, JO série L, 2026/269 du 18.2.2026, 187 p. | `Règlement délégué 2026-269.pdf` (racine) | SHA-256 `ebe0968a62c2…ab1f4127` (conforme au brief). La manifestation CELLAR `129a01db-…ed71a1.0010.01/DOC_1` a la même taille (11 624 451 octets) |
| JOUE L 12 du 17.1.2015 (FR) | `Règlement délégué.pdf` (racine) ; page n du PDF = p. L 12/n | SHA-256 `bdd6c697…7aac` |
| Consolidation du 14.11.2024 (FR) | `TEXTE consolidé_ … 14.11.2024.xhtml` (racine) | SHA-256 `f9a73f44…cef8e` |
| **Consolidation `02015R0035-20270130` (FR)**, libellé « 02015R0035 — FR — 30.01.2027 — 011.001 », M13 = 2026/269 | CELLAR `publications.europa.eu/resource/celex/02015R0035-20270130` → `cellar/f437fc5b-7aa8-11f1-bf5e-01aa75ed71a1.0005.02/DOC_1`, HTTP 200, 17/11/2026 08:42:24 UTC | SHA-256 `09ed8907…65241` |
| **2026/269, texte primaire EN** (PDF/A-2a, 187 p.) | `cellar/129a01db-0c6c-11f1-8870-01aa75ed71a1.0006.01/DOC_1` (expression 0006 = EN, établie par le titre `L_202600269EN`), 08:45:06 UTC | SHA-256 `86d42281…7abd08` |
| **JOUE EN L 12 du 17.1.2015** (`L_2015012EN.01000101.xml`) | `cellar/e0c803af-9e0f-11e4-872e-01aa75ed71a1.0006.03/DOC_477` | SHA-256 `210316ea…f8471` |
| Consolidation EN du 14.11.2024 | `cellar/d4117d51-ac28-11ef-acb1-01aa75ed71a1.0001.02/DOC_1` | SHA-256 `26b61236…be7da61` |
| AEAPP, Q&A 2580 | page de l'AEAPP, lue le 17/11 | — |

**Méthode.**
- Les formules et les passages cités ont été lus **en rendu graphique** (`pdftoppm -r 200`). Pour la consolidation de 2027, la lecture porte sur les images JPEG intégrées (300 dpi natifs).
- L'extraction de texte n'a servi qu'à localiser les passages, à comparer les consolidations au caractère près et à faire des recherches plein texte. Celles-ci sont signalées comme telles.
- Les pièces téléchargées sont hors dépôt, dans `/tmp/claude-0/-home-user-outil-usp/7785da0b-f095-5cab-9c27-b986f3ac865f/scratchpad/dl_consol/` et `…/scratchpad/dl_en/`.

## 1. Synthèse

1. **Application et transition.** 2026/269 entre en vigueur le 20ᵉ jour suivant sa publication (10.3.2026, date calculée) et **s'applique à partir du 30 janvier 2027** (art. 2, p. 94). Il ne contient **aucune disposition transitoire** pour les art. 117 et 148. Le texte ne dit pas à quelle « date » se juge l'applicabilité pour un calcul de SCR, ni pour un paramètre propre déjà approuvé (R-1, **interprétation**).
2. **Facteur NP du risque de primes, annexe II** (art. 1er, point 29) b), p. 25). Le facteur NP ne s'applique plus que « s'il existe une telle réassurance non proportionnelle pour ce segment précis » ; sinon le facteur est de 100 %. Les valeurs 80 % (segments 1, 4 et 5) et 100 % (autres segments) sont inchangées.
   - Effet : sur données nettes, segments II-1, II-4 et II-5, **sans** réassurance NP, le paramètre standard du mélange devient σ brut.
   - Exemple de #504 (`premium_net`) *vérifié* : 0,1032524114 → 0,1114524114, écart +0,0082. Recalculé avec NP = 1 depuis les composantes de la référence, le résultat est `identical()` au σ_USP de `premium`.
   - Le sens de « il existe » n'est pas défini (R-2, **interprétation**).
3. **σ(res,s), annexe II** (points 29) a) et c), p. 25-26). σ(res,s) devient le produit de l'écart-type « brut » de l'annexe II par le facteur NP. Ce facteur vaut Adjust(NP,s) pour une couverture pour développements défavorables (CDD) qui remplit les conditions, et 100 % dans tous les autres cas.
   - L'art. 218(1)(a)(iv), **non modifié**, renvoie à l'art. 117(2)(b), désormais redéfini.
   - Le paramètre standard du mélange de C(4) et D(4) peut donc se lire comme la valeur ajustée ou comme la valeur de l'annexe (R-3, **interprétation**, deux lectures et une variante).
   - Sans CDD qualifiante, toutes les lectures donnent la valeur de l'annexe : `reserve1` et `reserve2` sont inchangés.
4. **Annexe XIV** (point 39), p. 29-30).
   - Seule la **première** phrase de l'art. 148(3) est remplacée. La deuxième phrase (« facteur d'ajustement par défaut … égal à 100 % ») est **maintenue** : le risque de primes de l'annexe XIV est inchangé (*vérifié*).
   - Le risque de réserve suit le même schéma que l'annexe II (R-4).
5. **Autres dispositions** (R-5, *vérifié* sur la liste continue des points 1) à 148)).
   - Ne sont **pas** modifiés : les art. 19, 116, 147, 218 à 220, 338 et 356, ni les annexes I, II, XIV, XVII et XVIII.
   - L'**art. 31(4)** est remplacé (point 6) : sans effet, l'outil ne cite l'art. 31 que par la Q&A 2580, qui porte sur l'art. 31(1).
   - Les art. 210 à 212, auxquels renvoient les art. 116(6) et 218(2)(d), sont modifiés (points 70 à 73) : sans effet sur le code.
6. **Consolidation de 2027** (R-6, *vérifiée* sur les passages lus).
   - Les art. 117(2)(b)-(5) et 148(2)(b)-(5) concordent avec le JO, à deux différences typographiques près.
   - L'annexe XVII est identique à la consolidation de 2024 : texte identique, 85 images de formules identiques à l'octet.
   - Les annexes II et XIV sont identiques (valeurs, marqueur ▼M6).
7. **Versions anglaises** (R-7, *vérifiées*).
   - 2026/269 EN confirme les lectures FR. Le texte anglais emploie « in place », et l'anomalie « fourth subparagraph » de l'art. 148(4) y figure aussi.
   - Le JOUE EN de 2015 confirme les hypothèses de S2 : B(1)(a) et B(3)(c) emploient le même terme « aggregated losses », et l'art. 219(1)(c) écrit aussi « Directive 2009/13/EC ».
8. **Conformité actuelle.** Dans le domaine déclaré (date de référence antérieure au 30.1.2027), l'outil est **conforme**. La borne supérieure de l'en-tête de `R/engine.R` et de `sec:segments` est **exacte** au regard de 2026/269. **Aucune nouvelle issue** n'est proposée : les trois interprétations relèvent de #504 (décision D2).

## 2. Texte lu (FR, texte primaire)

**Art. 1er, point 29) a)** (p. 25, image à 200 dpi). Art. 117(2)(b) nouveau : « σ(res,s) représente l'écart type du risque de réserve en non-vie du segment s, tel que visé aux paragraphes 4 et 5 ».

**Point 29) b)** (p. 25). Art. 117(3) nouveau, cité intégralement :

> « Pour tous les segments visés à l'annexe II, l'écart type du risque de primes en non-vie d'un segment donné est égal au produit de l'écart type du risque de primes brut en non-vie indiqué à l'annexe II pour ce segment par le facteur d'ajustement pour la réassurance non proportionnelle, s'il existe une telle réassurance non proportionnelle pour ce segment précis, ou par un facteur de 100 % dans les autres cas. Dans le cas des segments 1, 4 et 5 visés à l'annexe II, le facteur d'ajustement pour la réassurance non proportionnelle est de 80 %. Pour tous les autres segments visés à l'annexe II, le facteur d'ajustement pour la réassurance non proportionnelle est de 100 %. »

**Point 29) c)** (p. 25-26). Art. 117(4) et (5) ajoutés, formules *vérifiées sur l'image*, p. 25 et 26, 200 dpi :
- 117(4), premier alinéa : σ(res,s) = écart-type « brut » de l'annexe II × facteur NP, « s'il existe une telle réassurance non proportionnelle pour ce segment précis, ou par un facteur de 100 % dans les autres cas ».
- 117(4), deuxième alinéa : pour une CDD qui remplit les conditions du troisième alinéa,
  **Adjust(NP,s) = max(0 ; [V(net,res,s) · 3 · σ(res,s,annex) − ADC(rec,s) · C · Pr + Par] / [V(net,res,s) · 3 · σ(res,s,annex)])**.
  Définitions : a) V(net,res,s), meilleure estimation **nominale**, « après déduction des montants recouvrables au titre des contrats de réassurance et des véhicules de titrisation de la couverture pour développements défavorables » ; b) σ(res,s,annex), « tel que visé à l'annexe II » ; c) ADC(rec,s) ; d) Par = max(prime de réassurance supplémentaire ou équivalent ; 0) ; e) C, cession au réassureur en % entre les points d'attachement et de détachement ; f) Pr = 100 %. **Aucun plafond à 1** : le rapport dépasse 1 si Par > ADC·C·Pr.
- 117(4), troisième alinéa : a) chaque couverture ne s'applique qu'à un groupe précis de polices, de mêmes caractéristiques de risque et du même segment, avec un point d'attachement et un point de détachement séparés et distincts ; b) point d'attachement ≤ V(net,res,s) × (1 + σ(res,s,annex)). C'est bien **1 + σ**, et non 1 + 3σ : même chose en EN, ce n'est pas une coquille à corriger.
- 117(4), quatrième alinéa : « Pour la réassurance non proportionnelle autre que celle visée au deuxième alinéa, le facteur d'ajustement est de 100 %. »
- 117(5) : **ADC(rec,s) = min[V(net,res,s) · (1 + 3 · σ(res,s,annex)) − R(ap) ; R(cs)]**. R(ap) est le point d'attachement de la structure de réassurance ; R(cs) la taille de la couverture dont dispose l'entreprise.

**Point 39)** (p. 29-30). Même schéma pour l'art. 148.
- a) 148(2)(b) renvoie aux § 4 et 5.
- b) « au paragraphe 3, **la première phrase** est remplacée » : texte parallèle à 117(3), première phrase, sans les phrases sur 80 % et 100 %.
- c) 148(4)-(5), formules *vérifiées sur l'image*, p. 29-30, 200 dpi, identiques en structure à 117(4)-(5) avec σ de l'annexe XIV. Le deuxième alinéa de 148(4) renvoie aux « conditions énoncées au **quatrième** alinéa », alors qu'elles figurent au troisième (anomalie rédactionnelle, § 3, R-4). En 148(5), l'ordre des définitions diffère de 117(5) (σ en d)), sans effet.

**Art. 2** (p. 94, image) : « Le présent règlement entre en vigueur le vingtième jour suivant celui de sa publication au Journal officiel de l'Union européenne. Il est applicable à partir du 30 janvier 2027. »

**Considérant 19** (p. 5, image). Il justifie la reconnaissance « de manière simple » de « certaines formes de réassurance, en particulier les couvertures pour développements défavorables permettant de transférer le risque de réserve ». Aucun considérant lu ne motive la condition nouvelle du facteur NP du risque de primes.

## 3. Réponses aux questions

### R-1 : version des art. 117 et 148 applicable à un calcul de paramètre propre ; dispositions transitoires

- *Vérifié* (art. 2, p. 94, image) : application à partir du 30.1.2027. Entrée en vigueur le 20ᵉ jour suivant la publication du 18.2.2026, soit le 10.3.2026 (date calculée).
- *Vérifié* (recherche plein texte des 187 pages sur « transitoire », « 29/30 janvier 2027 », « première application » ; art. 2 lu sur l'image) : **aucune disposition transitoire** pour les art. 117, 148 ou 218 à 220. Les dates du 29.1.2027 trouvées (p. 14, art. 43 ; p. 54, fonds cantonnés) portent sur d'autres matières.
- *Vérifié* : l'art. 218 n'est pas modifié. Ses renvois aux art. 117(2)(a) et (b), 117(3), 148(2)(a) et 148(3) pointent, à partir du 30.1.2027, vers les dispositions réécrites. Il n'existe pas de « version USP » distincte des art. 117 et 148.
- **Interprétation (le texte ne tranche pas).** Le règlement ne dit pas quelle date fixe le texte applicable à un calcul. Trois lectures :
  - **R1-a** : la date de référence (date d'évaluation) du calcul de SCR dans lequel le paramètre est employé. Un SCR au 31.12.2026 relève de l'ancien texte, même établi en 2027. C'est la convention de l'outil, pour la borne M6 comme pour la borne de 2027 (`sec:segments`, l. 2280-2301 ; `R/engine.R` l. 57-68).
  - **R1-b** : la date d'établissement ou de remise du calcul. Après le 30.1.2027, seul le texte nouveau s'appliquerait, quelle que soit la date de référence.
  - **R1-c** (propre aux paramètres propres) : un σ_USP approuvé avant le 30.1.2027, calculé en mélange avec 0,8 × σ brut sur données nettes sans réassurance NP, serait employé dans des SCR postérieurs alors que le paramètre « à remplacer » a changé. La nécessité d'un nouveau calcul ou d'une nouvelle approbation ne se lit pas dans 2026/269. *Non vérifié* : ni pratique de l'ACPR ni position de l'AEAPP consultées, aucune n'est citée.
  - L'outil retient R1-a. Choix renvoyé à `actuary` et au mainteneur (D2).

### R-2 : sens de « s'il existe une telle réassurance non proportionnelle pour ce segment précis » ; segments visés ; renvoi de l'art. 218(1)(a), point i)

- *Vérifié* (p. 25) : la condition porte sur « tous les segments visés à l'annexe II ». Comme le facteur vaut 100 % hors des segments 1, 4 et 5, l'effet numérique se limite à **II-1, II-4 et II-5**.
- *Vérifié* : le texte ne précise ni la date d'appréciation, ni le type de réassurance NP, ni de critère de reconnaissance. Il ne renvoie ni à l'art. 218(2) (contrat « reconnaissable ») ni aux art. 209 à 213.
- EN (p. 25) : « where such non-proportional reinsurance **is in place** for that particular segment ».
- *Vérifié* (consolidation 2024, FR et EN ; L 12/142 pour l'art. 218(1) d'origine) : le **renvoi de l'art. 218(1)(a)(i)** désigne « l'écart type du risque de primes en non-vie visé à l'article 117, paragraphe 2, point a) ». C'est σ(prem,s), « calculé conformément au paragraphe 2 » (sic, lu comme le § 3, anomalie déjà relevée par le `.tex`, l. 2557, et non corrigée par 2026/269). Ce paramètre suit donc la condition nouvelle.
- Le point a)(iii) (facteur NP propre, sous ▼M6, conditionné à un contrat « reconnaissable » au sens de l'art. 218(2)) et l'alinéa final de l'art. 218(1) sont inchangés.
- **Interprétation, sur la date d'appréciation :**
  - **R2-a** : contrats de réassurance NP en vigueur à la date de référence du calcul.
  - **R2-b** : contrats « mis en place pour fournir une couverture pour les douze mois à venir », par cohérence avec B(2)(d)(i)-(ii), qui fixe le contenu des données nettes du point a)(i). En EN : « in place to provide cover for the following twelve months », même verbe « in place » que le 117(3) nouveau ; on peut aussi invoquer l'art. 218(2)(b)-(c), « 12 mois à venir ».
  - Les deux lectures divergent au renouvellement d'un traité à l'échéance. Sous R2-b, l'ensemble de contrats que la déclaration « nettes » de l'outil atteste déjà (`sec:segments`, l. 2500-2503) serait le même que celui qui décide du facteur (*hypothèse*).
- **Interprétation, sur la portée de « telle » :**
  - **R2-c** : toute réassurance NP couvrant le segment.
  - **R2-d** : seule une réassurance NP prise en compte comme technique d'atténuation du risque, c'est-à-dire conforme aux art. 209 à 211 tels que modifiés par les points 70 et 71 de 2026/269. Le nouvel art. 211(1) (p. 53, couche texte) subordonne la prise en compte de la réassurance dans le SCR de base aux critères des art. 209 et 210 et de l'art. 211(2) à (7). Le texte de 117(3) ne fait pas ce renvoi.
  - Aucune des quatre lectures n'est tranchée. Ce choix détermine la charge déclarative de l'entrée « réassurance NP en place » de E-B.

### R-3 : σ(res,s) des art. 117(2)(b), (4) et (5) ; Adjust(NP,s) ; paramètre « à remplacer » de l'art. 218(1)(a), point iv), en C(4) et D(4) ; données exigées

Textes *vérifiés sur l'image* :
- 218(1)(a)(iv) (L 12/142 ; consolidation 2027 identique) : « l'écart type du risque de réserve en non-vie visé à l'article 117, paragraphe 2, point b) » ;
- C(4) (L 12/275, 200 dpi) : la formule écrit σ(res,s), la légende (e) dit « σ(prem,s) représente le paramètre standard à remplacer » (anomalie déjà relevée) ;
- D(4)(d) (L 12/277, 200 dpi) : « σ(res,s) représente le paramètre standard pour le risque de réserve … du segment s » ;
- l'annexe XVII est inchangée en 2027 (§ R-6).

Sans réassurance NP, ou avec une réassurance NP autre qu'une CDD qualifiante, le facteur vaut 100 % (117(4), premier et quatrième alinéas) : **toutes les lectures donnent σ(res,s,annex)**. L'outil est alors conforme avant comme après le 30.1.2027 (*vérifié*). La question ne se pose qu'en présence d'une **CDD qualifiante** :

- **Lecture R3-A (« σ ajusté »).** Le paramètre standard du mélange de C(4) et D(4) est σ(res,s) du 117(2)(b) nouveau, soit σ(res,s,annex) × Adjust(NP,s).
  - Appuis : chaîne littérale 218(1)(a)(iv) → 117(2)(b) → 117(4)-(5) ; données nettes exigées par C(2)(c) et D(2)(f), qui intègrent les recouvrements de la CDD si elle est en place pour les douze mois à venir, d'où une cohérence entre les deux termes du mélange.
  - Effet sur l'outil (σ de l'annexe) : σ standard trop élevé d'un facteur 1/Adjust, donc σ_USP plus élevé (côté prudent) si Adjust < 1, plus bas (côté non prudent) si Adjust > 1, ce que la formule permet.
- **Lecture R3-C (« valeur de l'annexe », choix actuel de l'outil).** `usp_parametre_standard()`, l. 727-734 : « sigma(res,s) de l'annexe, sans NP ». Le paramètre standard est σ(res,s,annex) ; l'effet de la CDD n'entre que par les données nettes du paramètre propre.
  - Appuis : D(4)(d) désigne « le paramètre standard » sans renvoi à l'art. 117 ; la formule d'Adjust prend elle-même σ(res,s,annex) comme entrée.
  - Objection : le renvoi inchangé de l'art. 218(1)(a)(iv) vise une définition qui a changé.
- **Variante R3-B (« le paramètre propre remplace la seule valeur de l'annexe, l'ajustement s'applique ensuite dans le SCR »).** Elle touche l'emploi de σ_USP hors de l'outil, mais implique, comme R3-C, de mélanger avec la valeur de l'annexe. Constats textuels :
  - l'art. 218(1) ne désigne aucun « écart-type de réserve brut » remplaçable, contrairement au risque de primes (point a)(ii) « brut ») ;
  - Adjust est défini avec σ(res,s,annex) « tel que visé à l'annexe II », non avec un paramètre propre ;
  - avec des données nettes (C(2)(c), D(2)(f), inchangés), appliquer Adjust par-dessus compterait deux fois la CDD.
- **Chiffrage illustratif**, `Rscript` sur les composantes des références, contrat fictif, non passé par `run_engine()`, ordre de grandeur seulement.
  - Contrat : V(net,res,s) = 100, σ(res,s,annex) = 0,09, R(ap) = 105 (≤ 100 × 1,09, condition b) remplie), R(cs) = 20, C = 100 %, Pr = 100 %, Par = 2. D'où ADC = min(127 − 105 ; 20) = 20 et Adjust = (27 − 20 + 2)/27 = 1/3, soit σ ajusté = 0,03.
  - Sous R3-A, c = 0,59 à T = 8 (barème long) : `reserve1` 0,1073524114 → 0,0827524114 ; `reserve2` 0,0497764613 → 0,0251764613.
  - Écart −(1 − c)(1 − Adjust)σ = −0,0246 dans les deux cas. Sous R3-C et R3-B : inchangés.
- **Données qu'exige l'ajustement** (*vérifié*, 117(4)-(5)) :
  - V(net,res,s), meilleure estimation **nominale**, nette des recouvrables « de la couverture pour développements défavorables ». Le texte ne dit pas, en FR comme en EN, si elle est aussi nette des autres réassurances : **interprétation**, à comparer à V(res,s) de l'art. 116(6), nette de toute réassurance conforme aux art. 209 à 211 et 213 ;
  - R(ap), R(cs), C et Par ; Pr fixé à 100 % ; σ(res,s,annex) (table) ;
  - le contrôle des deux conditions du troisième alinéa (groupe précis de polices d'un même segment, points d'attachement et de détachement distincts ; R(ap) ≤ V(net,res,s) × (1 + σ(res,s,annex))) ;
  - ce sont des données de contrat à la date du calcul, absentes des séries et triangles que reçoit l'outil.

### R-4 : art. 148, même lecture pour l'annexe XIV ; deuxième phrase de l'art. 148(3)

- *Vérifié* (p. 29, image ; consolidation 2027 : ►M13 … ◄ suivi de la phrase de 2015 sous ▼B) : seule la première phrase de l'art. 148(3) est remplacée. La deuxième phrase, « Pour tous les segments visés à l'annexe XIV, le facteur d'ajustement par défaut pour la réassurance non proportionnelle est égal à 100 % » (L 12/94, image), est **maintenue**. Le paramètre standard du risque de primes de l'annexe XIV vaut σ brut × 100 % avec ou sans réassurance NP. `np_standard` = 1 (`R/engine.R` l. 129) est **conforme avant et après**.
- Risque de réserve santé non-SLT : mêmes lectures R3-A, R3-C et R3-B (148(4)-(5), p. 29-30, formules *vérifiées sur l'image*, 200 dpi).
- L'anomalie de l'art. 218(1)(c)(iv), qui renvoie à l'art. 148(2)(**a**), n'est pas corrigée par 2026/269 (*vérifié*, consolidation 2027 identique). La lecture de l'outil, « sens évident », point b), mène désormais à 148(4)-(5).
- **Anomalie rédactionnelle nouvelle** (*vérifiée*, FR p. 29 et EN p. 29, « fourth subparagraph ») : l'art. 148(4), deuxième alinéa, renvoie aux conditions du « quatrième alinéa », alors qu'elles sont au troisième ; le quatrième alinéa fixe le facteur de 100 %. Sens évident : les conditions a) et b) du troisième alinéa. **Interprétation** sans effet sur l'outil, sauf option E-C.

### R-5 : aucune autre disposition citée par l'outil ou le `.tex` modifiée

Liste complète des points de l'art. 1er : points 1) à 148), continus (*vérifié* par contrôle de la numérotation, p. 11 à 93). Annexes modifiées ou remplacées (points 131 à 148) : III, V, VI, VII, VIII, VIII bis (insérée), IX, X, XIII, XVI, XIX, XX, XXI, XXII, XXIII, XXIV, XXV et XXVI.

Inventaire des articles et annexes cités dans `R/engine.R`, `app.R`, `R/display_helpers.R`, `README.md`, `docs/exigences.md` et le `.tex`, confronté à cette liste :

| Disposition citée | Modifiée par 2026/269 ? | Effet sur l'outil | Statut |
|---|---|---|---|
| Art. 19 (qualité des données) | non (les points 4 et 5 visent les art. 18 et 20) ; texte 2027 identique (diff nul) | aucun | *vérifié* |
| Art. 31 (cité dans `sec:biblio`, l. 20742, comme objet de la Q&A 2580) | **oui, § 4 seul** (point 6, p. 13 : projections de dépenses et décisions de l'organe d'administration sur les contrats nouveaux) | aucun : la Q&A 2580 ne vise que l'art. 31(1), points a) à d) | *vérifié* |
| Art. 116(6) et 147(6) (cités l. 15323-15333) | non ; diff nul entre consolidations | aucun | *vérifié* |
| Art. 117 et 148 | oui (points 29 et 39) | voir R-1 à R-4 | *vérifié* |
| Art. 218, 219 et 220 | non ; diff nul entre consolidations (marqueurs ▼B et ▼M6 seulement) | aucun | *vérifié* |
| Art. 338 et 356 (cités l. 20765-20767) | non (les points 105 à 129 visent les art. 328 à 336 ter, 341, 343 et 359 à 375) | aucun | *vérifié* |
| Annexes I, II, XIV, XVII et XVIII | non | aucun ; annexes II et XIV : valeurs identiques et toujours sous ▼M6 en 2027 | *vérifié* |
| Art. 209 à 213, non cités directement mais auxquels renvoient les art. 116(6) et 218(2)(d) | **oui** : art. 210(3 bis) et (6), 211(1), (2 bis) et (7), 212(1), 212 bis (points 70 à 73, p. 52-53) | aucun sur le code, qui ne les contrôle pas ; pertinent pour R2-d | *vérifié* (couche texte) |
| Art. 1er, 2 et 3 cités par le `.tex` | ce sont les articles des règlements 2019/981 et 2015/498, pas du 2015/35 | — | *vérifié* (l. 439, 2274, 9909-9921) |

### R-6 : concordance de la consolidation `02015R0035-20270130` avec le texte primaire (passages lus)

- **Art. 117(2)(b), (3), (4) et (5)** sous ▼M13 : texte identique au JO, p. 25-26. La fraction d'Adjust est une image dans la consolidation (`a117_2.jpg`, 505 × 71 px) ; même structure que le JO, mais **sans les points de multiplication**, le produit restant implicite. ADC : séparateur « ; » comme au JO. *Vérifié sur l'image.*
- **Art. 148(2)(b), (3) et (4)-(5)** : texte identique, « quatrième alinéa » compris. Phrase 1 du § 3 sous ►M13 … ◄, phrase 2 sous ▼B. Seule différence typographique : en 148(5), le séparateur du min est « , » au lieu de « ; » dans le JO. *Vérifié.*
- **Art. 31(4)** : texte du point 6 sous ▼M13. *Vérifié.*
- **Art. 19, 116, 147 et 218 à 220** : texte identique à la consolidation du 14.11.2024 (diff nul après normalisation des balises d'image). *Vérifié.*
- **Annexe XVII** : 602 lignes de texte identiques, à deux artefacts de balisage près (texte de remplacement d'une accolade en F(5) ; caractère « v » isolé avant une image en D(5)(d)(ii)). **85 images de formules identiques à l'octet** (SHA-256 comparés). La MSEP de D(5) (ADR 0005) est donc inchangée en 2027. *Vérifié.*
- **Annexes II et XIV** : 24 et 8 valeurs identiques à la consolidation de 2024 et aux tables `ANNEXE_II` et `ANNEXE_XIV`, sous ▼M6. *Vérifié.* L'en-tête de colonne reste « Écart type pour le risque de réserve du segment », sans « brut », alors que le 117(4) nouveau parle de l'écart-type « brut … indiqué à l'annexe II » : écart terminologique sans effet numérique.

**R-6 : vérifiée** sur les passages lus.

### R-7 : versions anglaises

- **2026/269 EN** (p. 25-26 et 29-30, images à 200 dpi) : formules identiques au FR ; « where such non-proportional reinsurance is in place for that particular segment » (117(3), 117(4), 148(3), 148(4)) ; « the sum of 1 and σ(res,s,annex) » (condition b)) ; 148(4) « fourth subparagraph » (même anomalie qu'en FR). Art. 2 (p. 94, couche texte) : application identique. *Vérifié.*
- **JOUE EN L 12 du 17.1.2015** (couche texte de la manifestation xhtml ; pagination EN non relevée) :
  - B(1)(a) : « … after the first development year of the accident year of those claims (aggregated losses) » ;
  - B(3)(c) : « the aggregated losses in segment s in a particular accident year t are denoted by y_t » : même terme qu'en B(1)(a). L'hypothèse de S2 (`docs/revues/20261116-s2-textes/regulatory-controle-aval.md` § 3 et § 5) est **vérifiée** : « pertes accumulées » est une variante de traduction ;
  - art. 219(1)(c) : « Article 101(3) of Directive **2009/13/EC** » : la coquille existe aussi en EN, et la lecture « 2009/138/CE » reste une **interprétation** de sens évident.
- La consolidation EN du 14.11.2024 donne les mêmes textes, ainsi que C(4)(e) « σ(prem,s) » et D(4)(d). *Vérifié.*

## 4. Matrice de conformité (code et documentation face au texte)

| # | Élément | Texte | Code / doc | Avant le 30.1.2027 | À partir du 30.1.2027 |
|---|---|---|---|---|---|
| 1 | `np_standard` annexe II : 0,8 (segments 1, 4, 5) et 1 | 117(3) d'origine, L 12/75 (image) ; 117(3) nouveau, JO 2026/269 p. 25 | `R/engine.R` l. 94-104 ; `.tex` l. 2353-2358 | **conforme** | valeur conforme ; condition d'emploi nouvelle (R-2) ; hors du domaine déclaré, écart de +0,0082 sur `premium_net` sans réassurance NP (*vérifié*). Suivi : #504 |
| 2 | `np_standard` annexe XIV = 1 | 148(3), phrase 2 maintenue (p. 29) | l. 126-129 | **conforme** | **conforme** |
| 3 | `ANNEXE_II` et `ANNEXE_XIV` | annexes non modifiées ; consolidation 2027 identique | l. 75-131 | **conforme** | **conforme** |
| 4 | Paramètre standard, primes brutes (points a)(ii) et c)(ii)) = σ brut | 117(3), 148(3) ; B(2)(c) | `usp_parametre_standard()` l. 710 | **conforme** | **conforme** (sortie brute inchangée ; le facteur NP s'applique hors de l'outil) |
| 5 | Paramètre standard, primes nettes (points a)(i) et c)(i)) = NP × σ brut | 117(3) ; B(2)(d) ; B(4)(e) (L 12/273, image) | l. 708-712 | **conforme** | **conforme** si une réassurance NP « existe » (R-2) ; sinon écart, côté non prudent : écart = −(1 − c)(1 − NP)σ brut. Exemple II-1, T = 8 : −0,0082 (*vérifié*). Hors du domaine déclaré. Suivi : #504 |
| 6 | Paramètre standard, réserve = σ(res,s) de l'annexe | 218(1)(a)(iv) → 117(2)(b) ; C(4), D(4) (L 12/275, 277, images) | l. 727-734 ; `.run_engine_mw()` l. 16310 | **conforme** | **conforme** sans CDD qualifiante ; avec CDD : **interprétation** R-3 |
| 7 | En-tête « LIMITE DE PERIMETRE », borne supérieure | art. 2 ; points 29) et 39) | `R/engine.R` l. 57-68 | — | **conforme** : date, articles et points exacts (117(3) ; 117(2)(b) ; art. 148 ; annexes II et XIV restées sous M6). La date d'appréciation (« date de référence ») relève de l'interprétation R-1 |
| 8 | « Borne supérieure du domaine » | idem ; citation de 117(3) | `.tex` l. 2288-2307 | — | **conforme** : la citation entre guillemets est exacte au caractère près (p. 25, image), le sens de l'écart (« inférieur à celui du texte modifié ») est exact, comme l'est la mention « 100 % pour le risque de primes » de l'annexe XIV |
| 9 | Écart chiffré du paragraphe « Paramètre remplacé… » | — | `.tex` l. 2506-2513 | **conforme** (−0,0082, c = 0,59) | idem |
| 10 | « Anomalies rédactionnelles » | 117(2)(a), 218(1)(c)(iv), C(4)(e), 219(1)(c) | `.tex` l. 2551-2563 | **conforme** | **conforme** : aucune n'est corrigée par 2026/269 ; 219(1)(c) est confirmé en EN. Anomalie nouvelle de 148(4) non encore transcrite (§ 6) |
| 11 | Commentaire de #504 du 14/11, points 2 et 3 | points 29), 39), art. 2 | issue #504 | — | **conforme** ; exemple 0,1032524 / 0,1114524 *vérifié* (`identical()` sur recalcul) |
| 12 | Fiche S3, « Constats » | — | `docs/feuille-de-route.md` l. 3977-3982 | — | exacte, sauf « six cas … tous au segment 1 » : `premium_ii6` est au segment 6 (§ 6) |

**Aucun écart dans le domaine déclaré.** Les écarts latents hors du domaine (lignes 1, 5 et 6) font l'objet de #504.

## 5. Issue proposée

**Aucune nouvelle issue.** Les trois interprétations à trancher relèvent de #504, déjà dans le périmètre de S3 :
- R-1 : date d'appréciation du texte applicable ;
- R-2 : date et portée de « il existe une telle réassurance NP » ;
- R-3 et R-4 : paramètre standard de réserve en présence d'une CDD.

Je propose que la session les porte à `actuary-approfondi` (étape 2) puis au mainteneur (D2), sans créer de doublon.

## 6. Constats hors périmètre (critères de l'ADR 0018 ; la session trie)

| Constat | Gravité | Critère | Preuve |
|---|---|---|---|
| La fiche S3 (l. 3982) dit des six cas de référence « tous au segment 1 de l'annexe II » ; `premium_ii6` est au segment 6, données brutes, σ standard 0,19, barème long. Sans effet sur S3 (NP = 1 pour II-6). | mineur | **aucun** (la feuille de route n'entre pas dans le champ de E5) | `readRDS("tests/reference/premium_ii6.rds")$metadata` |
| Anomalie rédactionnelle de 2026/269, art. 148(4), deuxième alinéa (« quatrième alinéa », FR et EN) : à ajouter aux « Anomalies rédactionnelles » (l. 2551-2563) si l'étape 8 transcrit 148(4). | mineur | **aucun** aujourd'hui (rien n'est transcrit) | JO 2026/269 p. 29 FR et EN, images |
| Si l'étape 8 transcrit 117(4) ou 148(4), garder « 1 + σ(res,s,annex) » dans la condition b) et « 1 + 3σ » dans ADC(rec,s) : ce n'est pas une coquille. Aucun plafond à 1 pour Adjust. | information pour `docwriter` | **aucun** | p. 25-26 et 29-30, FR et EN |
| Annexe XVII, F(4)(c) : « NP … visé à l'article 117, paragraphe 2 » au lieu du paragraphe 3. Section F hors du périmètre de l'outil ; non corrigé en 2027. | mineur | **aucun** | consolidations 2024 et 2027, texte |
| Hypothèses de S2 levées par R-7 (B(1)(a), B(3)(c) et art. 219(1)(c) en EN) : à consigner dans le dossier de revue ; le `.tex` ne mentionne pas la version anglaise, donc aucune affirmation fausse. | information | **aucun** | JOUE EN 2015, couche texte |
| L'absence de garde de date dans `run_engine()` (constat écarté de S2) reste le seul moyen de faire respecter la borne : la borne est documentée, non contrôlée. Déjà renvoyé à #504. | déjà suivi | E4 latent hors du domaine ; objet de #504 | `.tex` l. 2288-2307 ; `run_engine()` sans entrée de date |

## 7. Critères d'escalade signalés (sans décision)

- **σ_USP changé** pour une date de référence ≥ 30.1.2027 si D2 retient E-B ou E-C (II-1, II-4, II-5, données nettes, sans réassurance NP : +0,0082 à c = 0,59) : **visa du mainteneur**.
- **Deux lectures d'une source** sur R-1, R-2 et R-3/R-4 : avis d'`actuary`, puis décision du mainteneur. Aucun désaccord entre agents à ce stade.
- **Contrats partagés** probablement touchés (entrées de `run_engine()`, `res$metadata`, condition d'emploi de `np_standard`) : déjà signalés par la fiche (§ 4.2).
- Avec R3-A et E-C, une formule réglementaire nouvelle (Adjust, ADC) entrerait dans le moteur et le `.tex` : `regulatory` en `high` aux étapes 6 et 9.

## 8. Pages rendues en image et lues

- **2026/269, FR** (200 dpi) : p. 1, 5, 25, 26, 29, 30, 94.
- **2026/269, EN** (200 dpi) : p. 25, 26, 29, 30 (moitié haute recadrée).
- **JOUE L 12 du 17.1.2015, FR** (200 dpi) : L 12/75 (art. 117(2)-(3)), 94 (art. 148), 142 (art. 218(1)), 273 (B(3)-(5)), 274 (B(6), C(1)-(2)), 275 (C(3)-(5)), 277 (D(3)-(5)). Les p. 74, 276, 281 et 282 ont été rendues mais **non lues**.
- **Consolidation 2027, FR** : images natives (300 dpi) des art. 117 (5 images) et 148 (6 images), lues ; 85 images de l'annexe XVII comparées à l'octet, non relues une à une.
- Rendus conservés dans `/tmp/claude-0/-home-user-outil-usp/7785da0b-f095-5cab-9c27-b986f3ac865f/scratchpad/img/` et `/tmp/claude-0/-home-user-outil-usp/7785da0b-f095-5cab-9c27-b986f3ac865f/scratchpad/imgc/`.
