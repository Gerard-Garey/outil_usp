# Avis d'actuary sur la lecture amont de 2026/269 : S3, étape 2 (D1), #504

> *Rédigé par l'agent actuary (IA), le 17/11/2026.* Branche `claude/reglement-2026-269` à `f95d796`, arbre propre. Lecture seule : rien n'a été écrit dans le dépôt et aucune référence n'a été régénérée. Calculs sous `LC_ALL=C.UTF-8`, moteur chargé par `charger_moteur()`. Scripts hors dépôt, dans `/tmp/claude-0/-home-user-outil-usp/7785da0b-f095-5cab-9c27-b986f3ac865f/scratchpad/actuary/` (`chiffrage.R`, `diff.R`, `diff2.R`, `diff3.R`, `contrefactuels.R`, `invariance.R`, `r3a.R`).

**Ce que j'ai lu**
- La fiche S3 entière (`docs/feuille-de-route.md` l. 3973-4013).
- Le rapport de `regulatory` en entier.
- L'issue #504 avec ses six commentaires.
- `docs/exigences.md` § 1, 2, 4 et 5.
- Dans `R/engine.R` :
  - l. 57-131 (en-tête de périmètre, `ANNEXE_II`, `ANNEXE_XIV`), l. 150-156 (barèmes) ;
  - `usp_parametre_standard()` (l. 695-751) et `usp_parametre()` (l. 2170) ;
  - `.engine_trace_sigma()` (l. 17317) et ses deux appelants, `engine_parametre_standard()` (l. 17388) et `engine_derogations()` (l. 17472).
- Dans le `.tex`, l. 2270-2310 (« Borne supérieure du domaine ») et l. 2475-2563 (« Paramètre remplacé… », « Anomalies rédactionnelles »).
- Les p. 25 et 26 du JO 2026/269, relues **sur l'image** (rendus de `regulatory`, 200 dpi) : art. 117(3), 117(4) avec Adjust et les conditions a) et b), 117(5) avec ADC.

---

## 1. Synthèse

1. **Ce que change 2026/269 n'est pas un test statistique.** C'est une règle déterministe sur le paramètre standard du mélange. Aucune p-value et aucun verdict ne sont touchés (*vérifié*, § 3.1). L'écart sur σ_USP vaut exactement Δ = (1 − c)(1 − facteur) σ_annexe, quelles que soient les données. À T = 8, le poids du paramètre standard est 1 − c = 0,41 (barème long) ou 0,19 (barème court) : la règle pèse donc lourd précisément à la taille d'intérêt.
2. **Risque de primes sur données nettes, II-1, II-4 et II-5, sans réassurance NP.** σ_USP augmente de +0,0082 (II-1), +0,00304 (II-4) et +0,01148 (II-5), soit +2,8 % à +12,5 % selon le jeu et le segment. Le sens est toujours prudent par rapport à l'outil actuel (*vérifié* par `run_engine()`, § 3.2). Le contrefactuel II-1 est `identical()` à `premium` (*vérifié*).
3. **Le nouveau texte est plus cohérent que l'ancien.** Une quote-part constante laisse σ̂ inchangé (mesuré, § 3.3). Avec l'ancien 117(3), une entreprise sans réassurance NP qui déclarait ses données nettes obtenait donc un σ_USP plus bas que sur données brutes, sans aucune atténuation du risque. Le nouveau 117(3) supprime cet écart.
4. **Avis sur les lectures** (le mainteneur tranche) :
   - **R1-a** (date de référence du SCR dans lequel σ_USP est employé) ;
   - **R2-b** (contrats en place pour les douze mois à venir) combinée à **R2-d** (réassurance NP reconnue comme technique d'atténuation du risque, art. 209 à 211 modifiés) ;
   - **R-3 non tranché par le code dans S3.** Sur le fond, R3-A me paraît la lecture la plus cohérente. Mais aucune des lectures n'est uniformément prudente, et R3-A exige des données de contrat que l'outil ne reçoit pas.
5. **Recommandation d'étendue : E-B**, avec trois éléments :
   - une date de référence obligatoire, sans valeur par défaut ;
   - une déclaration « réassurance NP en place », exigée seulement là où elle agit ;
   - pour les méthodes de réserve, à date ≥ 30.1.2027, une déclaration « couverture pour développements défavorables (CDD) qualifiante » : si elle est présente, refus motivé (`ok = FALSE`, hors du domaine).

   E-C est reportée tant que R-3 n'est pas tranchée. E-A est le repli si le mainteneur veut le changement minimal tant que le dossier reste antérieur à 2027.

---

## 2. Avis sur les lectures doubles

### R-1 : date qui fixe le texte applicable

**Avis : R1-a**, avec une conséquence explicite pour R1-c.

- **Argument actuariel** (*hypothèse* de raisonnement, aucune source réglementaire ne le dit). B(4)(e) définit le terme standard du mélange comme « le paramètre standard à remplacer par le paramètre propre ». Ce paramètre est celui de la formule standard dans le calcul de SCR où σ_USP sera employé. Le mélange n'a de sens que si les deux termes visent la même grandeur, au même calcul. La date pertinente est donc celle de ce SCR, c'est-à-dire sa date de référence. R1-a est aussi la convention déjà retenue pour la borne M6 (#19 ; `R/engine.R` l. 57-62 ; `.tex` l. 2280-2287) : la garder évite deux conventions de date dans un même outil.
- **R1-b (date d'établissement)** casse ce lien. Un SCR au 31.12.2026 établi en mars 2027 mélangerait σ̂ avec un paramètre standard que la formule standard de ce même SCR n'emploie pas (*hypothèse* : ni pratique de l'ACPR ni position de l'AEAPP sur la date d'application consultées, aucune n'est citée).
- **R1-c (σ_USP approuvé avant 2027, employé après).** Avec R1-a, un σ_USP calculé avant 2027 sur données nettes II-1, II-4 ou II-5 sans réassurance NP sous-estime le σ_USP du texte d'emploi de Δ = (1 − c) × 0,2 × σ_brut. Exemple II-1 à T = 8 : 0,1032524 au lieu de 0,1114524, soit −7,4 % (*vérifié*, § 3.2). L'outil peut rendre la valeur pour chaque date d'emploi : c'est l'information dont le dossier a besoin. Faut-il alors recalculer ou faire réapprouver le paramètre ? Je ne le sais pas : cela relève du droit et de la pratique de l'autorité, que je n'ai pas consultés (*non vérifié*). La décision revient au mainteneur.

### R-2 : « s'il existe une telle réassurance non proportionnelle pour ce segment précis »

**Date d'appréciation : avis R2-b** (contrats en place pour les douze mois à venir à la date de référence).
- Le risque de primes est un risque à un an, sur les primes à acquérir. La réassurance NP qui l'atténue est celle qui couvre les douze mois suivants, pas celle qui expire le lendemain de la date de référence.
- R2-b aligne la condition sur la définition des données nettes de B(2)(d), qui ajuste les données « conformément aux contrats … en place pour les douze mois à venir ». Le même ensemble de contrats décide alors à la fois de la nature des données et du facteur.
- Le texte anglais emploie « in place » dans les deux passages (relevé de `regulatory`, R-7, que je n'ai pas relu).
- Sens de l'écart. Avec R2-a, un traité échu juste après la date de référence et non renouvelé donnerait 80 % pour une année non couverte : non prudent. Un traité qui prend effet au 1er janvier, pour une date de référence au 31 décembre, serait ignoré : prudent. R2-b évite le premier cas (*hypothèse* de raisonnement).

**Portée de « telle » : avis R2-d** (réassurance NP reconnue comme technique d'atténuation du risque).
- Le facteur de 80 % est forfaitaire : il ne dépend pas de l'efficacité de la couverture. Avec R2-c, n'importe quel contrat NP, même symbolique ou sans transfert de risque effectif, ouvrirait une réduction de 20 % du terme standard.
- R2-d est la lecture prudente. Elle reste une **interprétation** : le 117(3) ne renvoie pas aux art. 209 à 211 (*vérifié* par `regulatory`, et par moi sur l'image p. 25 pour l'absence de renvoi).
- L'outil ne peut vérifier ni R2-b ni R2-d. Le choix fixe seulement le **libellé de la déclaration**, sur le modèle de « nettes » (`.tex` l. 2500-2503).

**Point non tranché, à signaler à `regulatory`** : faut-il une couverture propre à « ce segment précis », ou une couverture multi-segments suffit-elle ? Ni `regulatory` ni moi ne l'avons traité (*non vérifié*).

### R-3 et R-4 : paramètre standard de réserve en présence d'une CDD qualifiante

**Sur le fond, je penche pour R3-A** (σ annexe × Adjust) :
- c'est la chaîne littérale 218(1)(a)(iv) → 117(2)(b) → 117(4)-(5) ;
- c'est l'analogue exact du choix déjà fait pour le risque de primes (décision M13) : données nettes mélangées avec un paramètre standard net. Sous R3-C, des données nettes de la CDD (C(2)(c), D(2)(f)) sont mélangées avec un paramètre standard qui ne l'est pas.

**Mais je recommande de ne pas l'implémenter dans S3**, pour quatre raisons :
1. **Aucune lecture n'est uniformément prudente.** La formule lue sur l'image p. 25 est max(0 ; [V·3·σ − ADC·C·Pr + Par] / [V·3·σ]), sans plafond. Adjust peut donc être nul ou supérieur à 1 dès que Par > ADC·C·Pr. Exemple : contrat fictif de `regulatory` avec Par = 25, Adjust = 1,185 (*calculé*). R3-C est plus prudente si Adjust < 1, et R3-A si Adjust > 1.
2. **L'enjeu est fort à T = 8.** De −0,0369 pour Adjust = 0 à +0,0092 pour Adjust = 1,25 (§ 3.4). Sur `reserve2`, σ_USP passerait de 0,0498 à 0,0129, soit −74 %. Avec Adjust = 0, on obtient σ_USP = c·σ̂ = 0,59·σ̂ : un paramètre inférieur à la propre estimation nette de l'entreprise, artefact du mélange (*vérifié* arithmétiquement).
3. **À T = 8, σ̂ ne refléterait presque pas la CDD** (*hypothèse*, ni simulée ni sourcée). Le point d'attachement est au plus V(1 + σ_annexe), condition b) lue sur l'image p. 26 ; la CDD tronque la queue au-delà. Sur huit années, seules quelques développements défavorables atteindraient ce point. Avec R3-C, l'avantage de la CDD serait donc en pratique perdu (prudent) ; avec R3-A, il entre par le terme standard avec le poids 1 − c. Par ailleurs, C(2)(c) et D(2)(f) ne disent pas comment ajuster des données historiques pour une couverture non linéaire calée sur V(net,res,s) à la date du calcul (*non vérifié* ; question pour `regulatory`).
4. **R3-B** (ajustement appliqué à σ_USP hors de l'outil) : je partage l'objection de `regulatory`. Avec des données nettes, elle compterait deux fois la CDD. Je ne la recommande pas.

**R-4 (annexe XIV)** : même avis. Le risque de primes XIV est inchangé, à 100 % (*vérifié* par `regulatory`, non relu par moi).

---

## 3. Effet chiffré

### 3.1 Champs qui dépendent du σ standard (*vérifié*, `premium` contre `premium_net`, `identical()` champ par champ)

**Changent :**
- `parametre` (`sigma_standard`, `sigma_usp`, `variation_relative`) ;
- `candidats`, `calibration$valeur` ;
- `ic_bootstrap`, `ic_bootstrap_restreint`, `ic_bootstrap_basic_log` ;
- `jackknife$sigma_usp` ;
- `ajustement` (`ecart_jackknife`, `largeur_ic`, `largeur_ic_restreint`) ;
- `plots_data` ;
- `metadata` (`sigma_standard`, `nature_donnees`) ;
- trois lignes de `tests`, toutes des diagnostics de la famille G au verdict `INFO` (lignes 44 à 46) :

| Ligne | Grandeur | `premium` | `premium_net` |
|---|---|---|---|
| 44 | jackknife, écart relatif maximal | 0,09376 | 0,10121 |
| 45 | largeur relative de l'IC 90 % | 0,55411 | 0,59812 |
| 46 | idem, δ fixé à δ̂ | 0,55546 | 0,59957 |

**Ne changent pas :** `bootstrap`, `profil`, `lr_delta`, `controles`, les p-values et les verdicts.

Conséquence pour l'étape 5 : le tableau avant / après doit porter ces champs, et pas seulement σ_USP. Aucun ne relève d'une validation de p-value.

### 3.2 Risque de primes, données nettes (*vérifié*, `run_engine()`, B = 999, graine 20260831)

| Jeu | Segment (c à T = 8) | Avec NP (outil actuel) | Sans NP (2026/269) | Δ | Δ relatif |
|---|---|---|---|---|---|
| `donnees_ln` | II-1 (0,59) | 0,1032524114 | 0,1114524114 | +0,0082 | +7,9 % |
| `donnees_ln` | II-4 (0,81) | 0,1088828021 | 0,1119228021 | +0,00304 | +2,8 % |
| `donnees_ln` | II-5 (0,59) | 0,1163724114 | 0,1278524114 | +0,01148 | +9,9 % |
| `donnees_ln_interieur` | II-1 | 0,0789308679 | 0,0871308679 | +0,0082 | +10,4 % |
| `donnees_ln_interieur` | II-4 | 0,0754922084 | 0,0785322084 | +0,00304 | +4,0 % |
| `donnees_ln_interieur` | II-5 | 0,0920508679 | 0,1035308679 | +0,01148 | +12,5 % |

Lecture et limites du tableau :
- **Origine des valeurs « sans NP ».** Pour II-1 sur `donnees_ln`, j'ai lancé `run_engine(…, nature_donnees = "nettes", sigma_standard = 0.10)`. Le σ_USP obtenu est `identical()` à celui de la référence `premium` ; verdicts et `p_retenue` sont identiques, ainsi que les trois diagnostics G (*vérifié*). Les autres valeurs « sans NP » sont les résultats de `run_engine()` sur données brutes, même σ double (1 × σ = σ). Leur égalité au chemin « nettes sans NP » est une *hypothèse* forte, vérifiée sur II-1 seulement.
- **II-4 et II-5 sont illustratifs** : ce sont les données de contrôle, réaffectées à un autre segment (seuls le σ standard et le barème changent). Δ = (1 − c) × 0,2 × σ_brut ne dépend pas des données (*vérifié* : formule de `usp_parametre()`, l. 2170-2183, et mesure).
- **Hors de ces cas, Δ = 0** : II-1, II-4 et II-5 avec réassurance NP, tout autre segment de l'annexe II, l'annexe XIV, les données brutes. Avant le 30.1.2027, les six cas sont inchangés sous toutes les options.
- **Ordre de grandeur face au bruit d'estimation.** L'IC bootstrap à 90 % de `premium` a une largeur relative de 0,55, soit environ 0,06 en absolu (*vérifié*, ligne 45). Δ est donc petit devant l'incertitude d'estimation à T = 8, mais c'est un **biais systématique**, pas du bruit.

### 3.3 Invariance par une cession proportionnelle (*vérifié* par mesure)

Avec `usp_ajuster()` sur (1 − q)x et (1 − q)y, pour q = 0 ; 0,3 ; 0,5, σ̂ est inchangé à 2e-10 près (tolérance de l'optimiseur), sur les deux jeux. δ̂ et β̂ le sont aussi. Ce résultat fonde l'argument du § 1, point 3.

*Hypothèse* : la mesure suppose une cession à taux constant et sans commission modifiant les primes nettes, ce que je n'ai pas examiné plus avant.

### 3.4 Méthodes de réserve, lecture R3-A (*calcul illustratif*, arithmétique sur les composantes des références, hors `run_engine()`)

Les composantes recombinées redonnent les σ_USP de référence, `identical()` (*vérifié*). Contrat fictif de `regulatory` : V = 100, R(ap) = 105, R(cs) = 20, C = Pr = 100 %, Par = 2, d'où ADC = 20 et Adjust = 1/3 ; la condition b) est remplie (*recalculé*).

| Adjust | `reserve1` (réf. 0,1073524) | `reserve2` (réf. 0,0497765) | Δ |
|---|---|---|---|
| 0 | 0,0704524 (−34,4 %) | 0,0128765 (−74,1 %) | −0,0369 |
| 1/3 | 0,0827524 (−22,9 %) | 0,0251765 (−49,4 %) | −0,0246 |
| 0,8 | 0,0999724 (−6,9 %) | 0,0423965 (−14,8 %) | −0,00738 |
| 1 | inchangé | inchangé | 0 |
| 1,25 | 0,1165774 (+8,6 %) | 0,0590015 (+18,5 %) | +0,0092 |

Avec R3-C, ou sans CDD qualifiante : inchangé dans tous les cas.

---

## 4. Options E-A, E-B, E-C

| | **E-A** borne gardée et contrôlée | **E-B** extension au risque de primes (recommandée) | **E-C** extension complète |
|---|---|---|---|
| **Entrées nouvelles de `run_engine()`** | date de référence | date de référence ; « réassurance NP en place » (logique) ; « CDD qualifiante » (logique) pour les méthodes de réserve | celles d'E-B, plus, si CDD : V(net,res,s) nominale, R(ap), R(cs), C, Par ; attestation de la condition a) ; Pr fixé à 100 % |
| **Charge de déclaration** | une date | une date ; un booléen pour II-1, II-4, II-5 nettes à date ≥ 30.1.2027 ; un booléen pour les réserves à date ≥ 30.1.2027 | lourde : données de contrat non vérifiables par le moteur ; question non lue du cumul de plusieurs CDD sur un segment (*non vérifié*) |
| **Effet de l'entrée** | date ≥ 30.1.2027 → `ok = FALSE`, motif ; date < 1.1.2020 → `ok = FALSE` (M6, #19) ; sinon comportement actuel | à date ≥ 30.1.2027 : facteur 80 % si NP déclarée, 100 % sinon ; CDD déclarée → `ok = FALSE`, motif « R-3 non tranchée » ; avant cette date : comportement actuel, déclarations consignées mais sans effet | R3-A appliquée ; contrôle b) R(ap) ≤ V(1 + σ_annexe) calculé par le moteur |
| **Erreur de l'utilisateur : date antérieure à la vraie** | II-1, II-4, II-5 nettes sans NP : σ_USP trop bas de Δ (**non prudent**) ; ailleurs, sans effet | idem | idem |
| **Erreur : NP déclarée à tort** | — | Δ = −(1 − c) × 0,2 × σ_brut (**non prudent**) | idem |
| **Erreur : NP omise à tort** | — | +Δ (prudent) | idem |
| **Erreur : CDD omise à tort** | — | σ annexe : prudent si Adjust < 1, non prudent si Adjust > 1, sous R3-A | idem |
| **Erreur : données de contrat fausses** (R(cs) ou C surestimés, Par sous-estimé) | — | — | Adjust trop bas, **non prudent**, jusqu'à −(1 − c) σ_annexe |
| **Valeur par défaut la plus sûre** | **aucune** : date obligatoire, `ok = FALSE` si absente. Un défaut « avant 2027 » est non prudent après cette date ; un défaut `Sys.Date()` est **à exclure** : le résultat dépendrait du jour du calcul et ne serait plus reproductible à entrées identiques (§ 4.5 du cahier des charges) | date : idem. NP : **aucune** (déclaration obligatoire là où elle agit, précédent M13 de `nature_donnees`) ; à défaut, `FALSE` (100 %, prudent), jamais `TRUE`. CDD : **aucune** ; à défaut, aucun défaut n'est sûr sous R3-A | comme E-B ; aucun défaut possible pour les données de contrat |
| **Six cas à date antérieure** | valeurs inchangées ; les appels de `CAS` (`tests/outils_tests.R`) prennent une date du domaine ; `metadata` gagne un champ, donc patch non numérique ou régénération (étape 4) | idem, plus les champs NP et CDD ; critère : seuil 0 en valeur | idem |
| **Tests nouveaux** | refus aux deux bornes, sans erreur levée | à date ≥ 30.1.2027 : II-1 nettes sans NP `identical()` à `premium` (mesuré ici par la voie « saisie ») ; avec NP `identical()` à `premium_net` ; II-4 et II-5 de même ; annexe XIV et brutes inchangées ; CDD → refus | ceux d'E-B, plus des tests unitaires d'Adjust et d'ADC (dont Adjust = 0 et Adjust > 1) et de la condition b) |
| **Documentation** | `sec:segments` : borne « documentée » devient « contrôlée » ; index des fonctions ; README « Usage sans Shiny » ; en-tête du rapport figé si D2 (§ 5.6) | celle d'E-A, plus : paragraphe « Paramètre remplacé… » (condition d'emploi de NP, lecture retenue de R-2 marquée *interprétation*, exigence de données non vérifiable, écart chiffré pour II-1, II-4, II-5) ; refus CDD et R-3 ouverte décrite | celle d'E-B, plus la transcription des formules d'Adjust et d'ADC et de la condition b) (« 1 + σ », pas « 1 + 3σ ») ; anomalie de 148(4) aux « Anomalies rédactionnelles » ; `regulatory` en `high` aux étapes 6 et 9 |
| **Lectures supposées** | aucune (hors domaine) ; R1-a pour le sens de la date | R1-a ; R2-b et R2-d (libellé de la déclaration) ; R-3 laissée ouverte | R1-a, R2-b, R2-d, **R3-A** (et la lecture de 148(4)) |

**Recommandation motivée : E-B.**
- E-B couvre le seul effet certain sous toutes les lectures de R-3 : le facteur NP du risque de primes. Pour une entreprise sans réassurance NP, le texte est sans ambiguïté (« ou par un facteur de 100 % dans les autres cas », image p. 25).
- Le changement est toujours du côté prudent par rapport à l'outil actuel.
- Il ne coûte qu'une date et deux booléens.
- Il fait d'une borne documentée mais non contrôlée (constat écarté de S2) une borne contrôlée.
- Le seul cas réellement ouvert, la CDD qualifiante, est refusé plutôt que chiffré selon une lecture non tranchée.

**E-C n'est pas recommandée maintenant.** R-3 est ouverte, aucune lecture n'est uniformément prudente, l'enjeu est fort à T = 8 et les données exigées sont étrangères aux séries reçues.

**E-A est acceptable** si le mainteneur veut le changement minimal tant que le dossier reste antérieur au 30.1.2027. L'outil deviendrait alors inutilisable pour tout SCR à date de référence ≥ 30.1.2027, c'est-à-dire dès les arrêtés de 2027.

**Point de forme pour l'étape 4** (*vérifié* sur le code). `engine_parametre_standard()` et `engine_derogations()` passent toutes deux par `.engine_trace_sigma()`. La conformité d'un σ standard saisi sera donc jugée selon la nouvelle règle, à condition que `.engine_trace_sigma()` relise les nouveaux champs de `metadata`. Le relevé des trois endroits par `architect` est exact.

---

## 5. Questions pour le mainteneur (D2), avec ma recommandation

1. **R-1** : la date qui fixe le texte applicable est-elle la date de référence du SCR dans lequel σ_USP sera employé ? *Recommandation : oui (R1-a).*
2. **R1-c** : le dossier doit-il dire qu'un σ_USP calculé selon l'ancien texte ne vaut pas, tel quel, pour un SCR à date ≥ 30.1.2027 (écart chiffré au § 3.2) ? *Recommandation* : oui, sous forme de constat chiffré. La nécessité d'une nouvelle approbation est hors de ma portée : décision du mainteneur, avec l'autorité si besoin.
3. **Étendue** : E-A, E-B ou E-C ? *Recommandation : E-B* (§ 4).
4. **Forme de l'entrée** : date de référence ou « texte applicable » déclaré ? Avec une valeur par défaut ? *Recommandation : une date*, obligatoire, sans défaut, lue au format ISO fixe (`%Y-%m-%d`, indépendant de la locale). La règle date → texte vit dans le moteur seul. **Exclure `Sys.Date()`.**
5. **Libellé et défaut de « réassurance NP en place »** : *recommandation* : « réassurance non proportionnelle couvrant ce segment, en place pour les douze mois suivant la date de référence et prise en compte comme technique d'atténuation du risque » (R2-b et R2-d). Déclaration obligatoire là où elle agit (II-1, II-4, II-5, nettes, date ≥ 30.1.2027), consignée ailleurs sans effet. À défaut d'obligation, `FALSE`.
6. **R-3** : trancher maintenant, ou garder la borne en présence d'une CDD qualifiante ? *Recommandation* : garder la borne (refus motivé) dans S3 et consigner R-3 comme question ouverte. Si le mainteneur veut trancher, ma préférence de fond va à R3-A, sous les réserves du § 2.
7. **σ standard saisi à date ≥ 30.1.2027 avec CDD déclarée** : le refus s'applique-t-il aussi ? *Recommandation : oui*, par simplicité d'audit (règle de domaine unique).
8. **Contrôle de la borne inférieure M6 (#19)** par la même date ? *Recommandation : oui*, pour un coût nul.
9. **Date de référence dans l'en-tête du rapport figé** (modification de `docs/exigences.md` § 5.6) ? *Recommandation : oui*, pour la traçabilité.

---

## Retour

- **Statut** : `complet` pour l'avis, les chiffrages et les options ; trois points de texte restent *non vérifiés* (voir ci-dessous) et sont signalés, sans bloquer l'avis.
- **Résultat** : R1-a ; R2-b et R2-d ; R-3 laissée ouverte dans S3, préférence de fond pour R3-A ; **E-B recommandée** ; neuf questions pour D2.
- **Preuves** :
  - *Vérifié* :
    - composantes des six références (`chiffrage.R`) ;
    - différences `premium` / `premium_net` : seuls trois diagnostics INFO dans `tests`, aucune p-value ni aucun verdict (`diff*.R`) ;
    - contrefactuels par `run_engine()`, dont le II-1 sans NP `identical()` à `premium` (`contrefactuels.R`, 2,9 min) ;
    - invariance de σ̂ par quote-part (`invariance.R`) ;
    - arithmétique de R3-A et recalcul `identical()` des σ_USP de réserve (`r3a.R`) ;
    - texte de 117(3), 117(4) et 117(5) relu sur l'image p. 25 et 26 ;
    - passage de `engine_parametre_standard()` et `engine_derogations()` par `.engine_trace_sigma()`.
  - *Hypothèses* :
    - les justifications actuarielles de R1-a, R2-b et R2-d ;
    - le faible reflet de la CDD dans σ̂ à T = 8 (ni simulé ni sourcé) ;
    - l'égalité du chemin « nettes sans NP » aux valeurs brutes pour II-4 et II-5 (vérifiée sur II-1 seulement) ;
    - la quote-part à taux constant sans commission.
  - *Non vérifié* :
    - la pratique de l'ACPR ou de l'AEAPP sur la date d'application et la réapprobation (non consultée, rien n'est cité) ;
    - la couverture multi-segments au sens de « ce segment précis » ;
    - l'ajustement des données historiques pour une CDD (C(2)(c), D(2)(f)) ;
    - le cumul de plusieurs CDD dans la formule d'ADC ;
    - 148(3) et (4), et le texte anglais : non relus par moi (je m'appuie sur `regulatory`).
- **Informations manquantes** : aucune source de l'autorité sur R-1 et R-2 ; aucune donnée de marché sur la fréquence des CDD qualifiantes.
- **Décisions non résolues** : les questions 1 à 9 du § 5, au mainteneur (D2). Les questions de texte sur la portée de « segment précis » et sur l'ajustement des données pour une CDD sont à porter à `regulatory` si E-C est un jour retenue.
- **Critères déclenchés** (`routage.md` § 4) :
  - deux lectures d'une source (R-1, R-2, R-3/R-4) : ambiguïté du texte lui-même, non un problème de documentation disponible ;
  - changement de résultat : σ_USP et champs associés pour une date ≥ 30.1.2027 avec E-B ou E-C, d'où le **visa du mainteneur** ;
  - aucun désaccord avec `regulatory`, aucun ADR contredit ;
  - aucune question de validité d'une p-value à T = 8 (aucun test touché).
- **Constats hors périmètre** :
  - le tableau avant / après prévu par la fiche ne nomme que σ_USP, alors que `ic_bootstrap*`, `jackknife$sigma_usp`, `ajustement`, `candidats`, `calibration`, `plots_data` et trois diagnostics G changent aussi (§ 3.1). Critère : **aucun** (information pour les étapes 4 et 5, dans le périmètre de S3) ; preuve : `diff.R`, `diff2.R`, `diff3.R` ;
  - l'*hypothèse* de la fiche (l. 3982 et 4007 : `premium_net` sans NP donne σ_USP de `premium`) est désormais mesurée (`identical()` TRUE, voie de saisie). Critère : **aucun** (information).
- **Prochaine action recommandée** : la session verse ce rapport dans `docs/revues/20261117-s3-reglement-2026-269/actuary-avis-etape-2.md`, puis porte les neuf questions du § 5 au mainteneur (D2, étape 3).
