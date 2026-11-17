<!-- Rapport de l'agent regulatory (effort high), branche S2, etape 1, 16/11/2026, verse integralement par la session principale (l'agent n'a pas d'outil d'ecriture). -->

# Lecture amont regulatory, branche S2, étape 1 (#585, #586)

**Je n'ai pas créé `docs/revues/20261116-s2-textes/regulatory-lecture-amont.md`.** Je n'ai pas d'outil d'écriture, et ma fiche m'interdit de modifier le dépôt par `Bash`. Le texte ci-dessous est le rapport complet, à verser tel quel par la session (CLAUDE.md, « Revues périodiques »). Je n'ai fait aucun commit, push ni issue. Pendant ma lecture, `git status` montrait `R/engine.R`, `tests/calibration_mc_mw_t8.R` et `tests/unitaires/test_merz_wuthrich.R` modifiés : c'est `coder`, pas moi. Tous les numéros de ligne ci-dessous sont pris sur `940f941`. Le `.tex` n'a pas changé jusqu'à `011ccda`.

**Synthèse.** Le code ne présente aucun écart de calcul. B(4)-(6) et C(4)-(6) sont conformes : je les ai vérifiés sur l'image et recalculés avec `Rscript` sur trois exemples. Il reste trois écarts mineurs, tous déjà couverts par #585 et #586 : le motif « art. 19 », le silence du `.tex` sur l'art. 219(1)(b), (c) et (2), et l'absence de la forme imprimée des formules. Deux lectures sont à porter à `actuary` puis au mainteneur, et aucune ne change de résultat. **Aucune issue nouvelle n'est proposée.**

## 0. Sources et méthode

- **Version d'origine** : `Règlement délégué.pdf`, JOUE L 12 du 17.1.2015. Page du PDF = page du JOUE ; je l'ai vérifié sur les en-têtes « L 12/n » des p. 31, 143, 272-277 et 282.
- **Rendu** : `pdftoppm` à 130 dpi pour les pages entières (p. 143, 272-277), puis à 300 dpi en découpe pour chaque formule. Je les ai toutes lues sur l'image. L'extraction de texte n'a servi qu'à repérer les pages et à lire la prose.
- **Version consolidée** : `TEXTE consolidé_ 32015R0035 — FR — 14.11.2024.xhtml`. J'ai extrait les 36 images base64 de l'annexe XVII, B et C (lignes 82041-82716 du XHTML) et je les ai lues.
  - Identité contrôlée par md5 : l'image de B(5) est identique à celle de C(5), celle de B(6) à celle de C(6), et les quatre images de x̄ sont identiques entre elles.
- Les marqueurs de modification ont été relevés dans le XHTML.

## 1. #585

### 1.1 Motif d'`engine_valider_donnees()`

`R/engine.R` l. 10953, dans la fonction qui commence l. 10938.

- **Avant** : `Valeurs manquantes : le calibrage exige des series completes (art. 19).`
- **Proposé, mot pour mot, en ASCII sans accents** :

```
Valeurs manquantes : le calibrage exige des series completes (art. 219, paragraphe 1, point a), renvoyant a l'art. 19, paragraphe 1 ; annexe XVII, B/C(1) et B/C(2)(b)).
```

**Points de forme**
- Le préfixe « Valeurs manquantes » est conservé, donc `contient()` de `test_controles_entree.R` l. 5008 reste vrai.
- Le libellé est aligné mot pour mot sur le tableau du `.tex`, l. 4367 (« Art. 219, paragraphe 1, point a), renvoyant à l'art. 19, paragraphe 1 »).
- Le style est celui du motif de `R/engine.R` l. 17531-17532 (« art. 219, paragraphe 1, point a), renvoyant a l'art. 19, paragraphe 1, point b) »).
- La notation B/C est celle du `.tex` (`sec:notations` : « B/C(n)(y) désigne la division de même numéro dans chacune des sections B et C ») et de l'autre motif de la même fonction (« Annexe XVII, B/C(2)(b) : au moins %d annees consecutives… »).

**Ancrage, cité par le texte**

| Disposition | Texte | Page JOUE |
|---|---|---|
| Art. 219(1)(a) | « les données répondent aux conditions énoncées à l'article 19, paragraphes 1, 2 et 3, […] les références au calcul des provisions techniques s'entendant comme des références au calcul des paramètres propres à l'entreprise » | p. 143, vérifié sur l'image |
| Art. 19(1), exhaustivité | (a) « suffisamment d'informations historiques » ; (b) « des données sont disponibles pour chacun des groupes de risques homogènes […], et aucune donnée pertinente n'est exclue de ce calcul sans justification » | p. 31 ; texte identique et sous ▼B dans la consolidée |
| B(1), dernier alinéa | « Ces pertes agrégées et primes acquises sont disponibles séparément pour chaque année d'accident » | p. 272 |
| C(1), dernier alinéa | « Les montants visés aux points a) et b) sont disponibles séparément pour des exercices différents » | p. 274 |
| B(2)(b) | « cinq années d'accident consécutives au moins » | p. 272 |
| C(2)(b) | « cinq exercices consécutifs au moins » | p. 274 |

*Remarque d'ancrage, sans conséquence sur le texte proposé* : B/C(2)(b) fonde la notion d'année « disponible ». Mais une série de six années ou plus avec un seul trou garderait parfois cinq années consécutives complètes. Refuser toute la série plutôt que retirer l'année tient donc à trois choses : l'art. 19(1)(b) (exclusion à justifier), B/C(3)(a) (numérotation consécutive) et un choix de l'outil. Le motif reste exact.

**Variante écartée** : citer « B(1) et B(2)(b) » ou « C(1) et C(2)(b) » selon `methode`. Elle exigerait un `sprintf` et un argument parfois `NULL`, sans gain sur le fond. Je recommande le texte fixe.

### 1.2 Phrase du `.tex` sur l'art. 219(1)(b), (c) et (2)

Dans `sec:controles`, liste « Exigences de données non vérifiables par l'outil » (l. 5512-5536). À insérer après la phrase qui se termine par « (article~219, paragraphe~1, points~a), d) et~e)) », avant « Ce sont, pour la méthode du risque de primes… », ou en fin de paragraphe, au choix de `docwriter`.

```latex
Il en va de même des critères de l'article~219 qui ne relèvent pas de l'annexe~XVII~:
les données peuvent être intégrées aux méthodes standardisées (paragraphe~1, point~b)), ce dont
l'outil ne contrôle que la forme (séries ou triangle recevables par la méthode), non que les
montants fournis soient ceux de B(1), C(1) ou D(1)~; elles n'empêchent pas l'entreprise de se
conformer aux exigences de l'article~101, paragraphe~3, de la directive~2009/138/CE (paragraphe~1,
point~c), dont le texte écrit «~2009/13/CE~», §\ref{sec:segments})~; lorsque des données externes
sont utilisées, elles satisfont aux critères supplémentaires du paragraphe~2, points~a) à~e)~:
processus de collecte transparent, vérifiable par audit et connu de l'entreprise, comparabilité
des données de sources différentes, données d'entreprises d'activité et de profil de risque
similaires, éléments statistiques suffisants d'un degré élevé de similitude des distributions de
probabilité, en particulier quant à la volatilité, et d'homogénéité des distributions sous-jacentes
aux données externes. Leur respect est à la charge de l'entreprise et à établir dans le dossier
(\emph{Journal officiel} L~12 du 17.1.2015, p.~143--144).
```

Pages : art. 219(1) et (2)(a)-(b) en p. 143 ; (2)(c)-(e) en p. 144. Le texte est identique dans la consolidée (sous ▼B, XHTML l. 25949 pour le point c)).

### 1.3 « 2009/13/CE »

| Source | Lecture | Statut |
|---|---|---|
| Version d'origine, art. 219(1)(c), JOUE L 12, p. 143 | « article 101, paragraphe 3, de la directive 2009/13/CE » | **vérifié sur l'image** |
| Version consolidée du 14.11.2024 | même texte (XHTML l. 25949) ; aucun marqueur ni rectificatif sur l'art. 219, qui est sous ▼B | vérifié |
| Version EN | « Directive 2009/13/EC » selon le Single Rulebook d'EIOPA (article 219) | source secondaire ; JOUE EN *non vérifié* |

**Lecture** : il faut lire « directive 2009/138/CE ».
- Le règlement complète cette directive (titre, JOUE p. 1). L'art. 101(3) de la directive 2009/138/CE porte sur le calibrage du capital de solvabilité requis.
- La directive 2009/13/CE du Conseil du 16 février 2009 met en œuvre l'accord sur la convention du travail maritime de 2006 (source secondaire : dossiers du Conseil et du Parlement européen). Elle n'a pas d'objet prudentiel.
- La coquille est **déjà dans la version d'origine** : ce n'est pas une anomalie propre à la consolidée.

**Ajout proposé à l'encadré** (l. 2551-2562, `sec:segments`), avant « le moteur suit la formule » ou en fin d'énumération :

```latex
l'article~219, paragraphe~1, point~c), renvoie à l'article~101, paragraphe~3, «~de la
directive 2009/13/CE~», lue comme la directive 2009/138/CE que complète le règlement~: le moteur
n'en dépend pas~;
```

**Précision à porter dans le même encadré**
- L'intitulé dit « Anomalies rédactionnelles du texte consolidé », « relevées sur la version consolidée ». Or trois des anomalies figurent **aussi dans la version d'origine** :
  - C(4)(e) « σ_(prem,s) » en p. 275 (**vérifié sur l'image**, découpe à 300 dpi) ;
  - art. 218(1)(c)(iv) « article 148, paragraphe 2, point a) » en p. 142 (prose lue par extraction, identique dans la consolidée, XHTML l. 25826) ;
  - « 2009/13/CE » en p. 143.
- Je n'ai pas vérifié l'anomalie de l'art. 117(2)(a) sur la version d'origine.
- Proposition : « présentes aussi dans la version d'origine (JOUE L 12, p. 142, 143 et 275) », pour celles qui ont été vérifiées.

## 2. #586 : transcription imprimée

Notation LaTeX alignée sur le document (`\text{prem}`). Les termes et facteurs sont dans l'ordre et sous la forme imprimés. La prose est citée mot pour mot.

### 2.1 Pages du JOUE (vérifiées sur les en-têtes)

| Passage | Page |
|---|---|
| A(1)(a)-(d), B(1)(a)-(b) et dernier alinéa, B(2)(a)-(f) | p. 272 |
| B(2)(g), B(3), B(4) et (a)-(e), B(5) et (a)-(d)(i) | p. 273 |
| B(5)(d)(ii), B(6) et (a)-(d), dernier alinéa | p. 274 |
| C(1)-(2)(e)(ii) | p. 274 |
| C(2)(e)(iii)-(iv), C(3), C(4) et (a)-(e), C(5) et (a)-(d)(ii) | p. 275 |
| C(6) et (a)-(d), dernier alinéa | p. 276 |

L'issue annonçait p. 273-274 pour B(4)-(6) et p. 275-276 pour C(4)-(6) : c'est **exact**. B(1)(a) et A(1)(a) sont en p. 272.

### 2.2 A(1)(a), p. 272, vérifié sur l'image

> « "année d'accident", en ce qui concerne le paiement d'un sinistre d'assurance ou de réassurance, l'année au cours de laquelle l'événement assuré ayant donné lieu à ce sinistre s'est produit; »

L'équivalence à écrire : « année de survenance » (document) = « année d'accident » (A(1)(a)). Elle vaut pour **B et D seulement**.
- En **C**, t indexe des **exercices**. A(1)(d) les définit ainsi : « l'année au cours de laquelle ce paiement est intervenu ». C(3)(a) : « les exercices sont représentés par des nombres consécutifs… ».
- L'équivalence ne doit donc pas être étendue à la méthode de réserve n° 1.

### 2.3 B(1)(a), p. 272, vérifié sur l'image

> « les paiements effectués et les meilleures estimations de la provision pour sinistres à payer dans le segment s après la première année de développement suivant l'année d'accident de ces sinistres (pertes agrégées); »

- B(1)(b) : « les primes acquises dans le segment s; »
- Dernier alinéa : « Ces pertes agrégées et primes acquises sont disponibles séparément pour chaque année d'accident des sinistres d'assurance et de réassurance dans le segment s. »
- B(3)(c) (p. 273) nomme y_t « les pertes accumulées dans le segment s durant une année d'accident donnée t » (« accumulées », pas « agrégées »). Le mot est le même dans les deux versions. Je le lis comme les pertes agrégées de B(1)(a), seules pertes que définit B(1).

**Pendant de C**, C(1), p. 274 :
> « (a) la somme de la meilleure estimation de la provision établie à la fin de l'exercice pour les sinistres qui étaient à payer en début d'exercice dans le segment s et des paiements effectués durant l'exercice pour les sinistres qui étaient à payer en début d'exercice dans le segment s; (b) la meilleure estimation de la provision pour sinistres à payer dans le segment s au début de l'exercice. Les montants visés aux points a) et b) sont disponibles séparément pour des exercices différents. »

Les notations l. 3450-3453 sont fidèles en substance pour C.

**Deux lectures de « après la première année de développement suivant l'année d'accident »** (I-1)
- **(i)** La situation à la fin de l'année qui suit l'année d'accident : année de développement 1 au sens de A(1)(b), qui la définit comme la différence entre l'année de paiement et l'année d'accident. « Suivant » se lit « qui suit ».
- **(ii)** La situation à la fin de la première année de développement numérotée 0 par A(1)(b), c'est-à-dire l'année d'accident elle-même.
- (i) me paraît la lecture littérale la plus naturelle, mais le texte ne numérote pas explicitement les années de développement en B. D(3) ne la fixe pas non plus (p. 277).
- **Le moteur n'en dépend pas** : il ne voit que les montants fournis.
- **Recommandation** : citer B(1)(a) entre guillemets, sans paraphrase. Si le document veut paraphraser, `actuary` donne son avis et le mainteneur tranche d'abord.

### 2.4 B(4), p. 273 : formule et points vérifiés sur l'image ; consolidée identique (image 1)

Chapeau : « L'écart type propre à l'entreprise dans le segment s se calcule comme suit: »

```latex
\sigma_{(\text{prem},s,\text{USP})} = c\cdot\hat\sigma(\hat\delta,\hat\gamma)\cdot\sqrt{\frac{T+1}{T-1}}
  + (1-c)\cdot\sigma_{(\text{prem},s)}
```

« où: »
- (a) « c représente le facteur de crédibilité visé à la section G; »
- (b) « σ̂ représente la fonction d'écart type définie au paragraphe 5; »
- (c) « δ̂ représente le paramètre de mélange défini au paragraphe 6; »
- (d) « γ̂ représente le coefficient de variation logarithmique défini au paragraphe 6; »
- (e) « σ_(prem,s) représente le paramètre standard à remplacer par le paramètre propre à l'entreprise. »

### 2.5 B(5), p. 273-274 : formules vérifiées sur l'image ; consolidée identique (images 5, 8, 12)

Chapeau : « La fonction d'écart type est égale à la fonction de deux variables suivante: »

```latex
\hat\sigma(\hat\delta,\hat\gamma) = \exp\!\left(\hat\gamma +
  \frac{\tfrac{1}{2}T + \sum_{t=1}^{T}\pi_t(\hat\delta,\hat\gamma)\cdot\ln\!\left(\frac{y_t}{x_t}\right)}
       {\sum_{t=1}^{T}\pi_t(\hat\delta,\hat\gamma)}\right)
```

« où: »
- (a) « δ̂ et γ̂ sont définis aux points (c) et (d) du paragraphe 4; »
- (b) « exp représente la fonction exponentielle; »
- (c) « ln représente le logarithme naturel; »
- (d) « π_t représente la fonction de deux variables suivante: »

```latex
\pi_t(\hat\delta,\hat\gamma) = \frac{1}{\ln\!\left(1 + \left((1-\hat\delta)\cdot\frac{\bar x}{x_t} + \hat\delta\right)\cdot e^{2\cdot\hat\gamma}\right)}
```

« où: »
- i. « δ̂ et γ̂ sont définis aux points (c) et (d) du paragraphe 4; »
- ii. « x̄ représente le montant suivant: » (p. 274)

```latex
\bar x = \frac{1}{T}\cdot\sum_{t=1}^{T} x_t
```

### 2.6 B(6), p. 274 : formules vérifiées sur l'image ; consolidée identique (images 15, 12)

Chapeau : « Le paramètre de mélange et le coefficient de variation logarithmique sont les valeurs δ̂ et γ̂, respectivement, qui minimisent le montant suivant: »

```latex
\sum_{t=1}^{T}\pi_t(\hat\delta,\hat\gamma)\left(\ln\!\left(\frac{y_t}{x_t}\right)
  + \frac{1}{2\cdot\pi_t(\hat\delta,\hat\gamma)} + \hat\gamma - \ln\!\big(\hat\sigma(\hat\delta,\hat\gamma)\big)\right)^{2}
  - \sum_{t=1}^{T}\ln\!\big(\pi_t(\hat\delta,\hat\gamma)\big)
```

« où: »
- (a) « ln représente le logarithme naturel; »
- (b) « π_t représente la fonction définie au point (d) du paragraphe 5; »
- (c) « σ̂ représente la fonction d'écart type définie au paragraphe 5; »
- (d) « x̄ représente le montant suivant: » x̄ = (1/T)·Σ_{t=1}^{T} x_t (**vérifié sur l'image**)

Dernier alinéa : « Pour la détermination du montant minimum, aucune valeur du paramètre de mélange inférieure à zéro ou supérieure à 1 n'est prise en considération. »

### 2.7 C(4) à C(6), p. 275-276 : vérifiés sur l'image ; consolidée identique (images 19, 23, 26, 30, 33, 36)

- **C(4)**, chapeau : « L'écart type propre à l'entreprise pour le risque de réserve en non-vie ou le risque de réserve en santé non-SLT dans le segment s est le suivant: »

```latex
\sigma_{(\text{res},s,\text{USP})} = c\cdot\hat\sigma(\hat\delta,\hat\gamma)\cdot\sqrt{\frac{T+1}{T-1}}
  + (1-c)\cdot\sigma_{(\text{res},s)}
```

- Points (a)-(d) : identiques à B(4).
- Point (e) : « σ_(prem,s) représente le paramètre standard à remplacer… ». Il est imprimé ainsi **dans les deux versions** (p. 275, **vérifié sur l'image**). C'est l'anomalie de l'encadré : le moteur suit la formule, σ_(res,s).
- **C(5)** et (a)-(d)(i)-(ii) : identiques mot pour mot et formule pour formule à B(5). La formule de π_t de C est une autre image dans la consolidée (295×80 contre 306×81 ; md5 différent) mais elle est **identique à la lecture**.
- **C(6)** et (a)-(d), dernier alinéa compris : identiques à B(6).

### 2.8 Écarts entre la version d'origine et la consolidée

| Passage | Écart | Statut au `.tex` |
|---|---|---|
| A(1), B(1), B(3)-(6), C(1), C(3)-(6) | **aucun** ; sous ▼B, sans marqueur ; formules identiques à l'image | — |
| B(2)(c) et (d) | intervertis par **▼M1** (renvoi aux points a) ii)/c) ii) et a) i)/c) i) échangés) | déjà traité, l. 2485-2498 |
| C(2)(e)(ii) | corrigé par **►C4** (« la variance du montant visé… », « meilleure estimation de la provision ») | déjà traité, l. 10755-10770 |

Ces deux derniers passages sont hors de la liste demandée et n'appellent aucune action.

### 2.9 Équivalence avec le moteur

Fonctions à `940f941`.

**π_t** : `usp_pi()` l. 1432, `1 / log1p(exp(2*gamma) * (delta + (1-delta) * xbar / x))`.
- Égal à B(5)(d) par commutativité.
- `log1p(u)` = ln(1+u) en arithmétique réelle (plus précis pour u petit).
- `xbar = mean(x)` = B(5)(d)(ii), calculé dans `usp_ajuster()` l. 1777 sur la série retenue.

**B(5)** : `usp_noyau()` l. 1437.
- `ln_beta <- (T/2 + sum(p*r)) / sum(p)` (l. 1444), avec `r = log(y/x)`, est la fraction de l'exposant.
- `sigma = exp(gamma + ln_beta)` (l. 1452) est B(5) terme à terme.
- La forme du `.tex` σ̂ = β̂ e^γ̂ (l. 3476) en découle en posant ln β̂ := la fraction ; le texte ne nomme pas β.

**B(6)** : par B(5), γ̂ − ln σ̂(δ̂,γ̂) = −ln β̂.
- Le terme au carré devient donc `v = r + 1/(2p) - ln_beta`, et le montant devient `obj = sum(p*v^2) - sum(log(p))` (l. 1453).
- C'est une identité exacte. La « forme profilée » du `.tex` (l. 12030-12033) **est** le montant imprimé, puisque le σ̂ de B(6) est la fonction de B(5) évaluée au même (δ, γ). Le moteur ne remplace donc rien.
- **Dernier alinéa** : δ ∈ [0, 1] est tenu par `lower = c(0, …)`, `upper = c(1, …)` (l. 1790) et par le renvoi 1e12 hors de [0, 1] dans `usp_objectif()` (l. 1461).
- γ n'est borné par aucun texte. Le moteur le borne par `BORNES_GAMMA = c(-12, 3)` (l. 183), borne de l'outil documentée comme non réglementaire (`.tex` l. 4511, 4540, 4550) et signalée quand elle est atteinte. **Interprétation déjà documentée, rien de nouveau.**

**B(4)/C(4)** : `usp_parametre()` l. 2164.
- `corr <- sqrt((T+1)/(T-1))` (l. 2167) et `sigma_usp = cred*sigma_ech + (1-cred)*sigma_standard` (l. 2175), avec `sigma_ech = fit$sigma*corr`. C'est la formule imprimée.
- `T = length(x)` = B/C(3)(b) sous la numérotation consécutive de B/C(3)(a) (lecture retenue, déjà documentée).
- `cred = usp_credibilite(T, bareme)` vient de la section G, p. 282. J'ai vérifié en passant que le barème court donne 81 % et le long 59 % à T = 8.

**Preuve numérique** (`Rscript`, moteur chargé par `charger_moteur()`)
- Transcription littérale indépendante de B(5)(d), B(5) et B(6), écrite d'après les images, comparée à `usp_noyau()` sur 12 points (δ ∈ {0 ; 0,3 ; 0,7 ; 1}, γ ∈ {−3 ; −1,5 ; −0,5}), pour trois séries T = 8 :
  - écart relatif maximal de π_t, σ̂ et du montant : **4,2e-14 ; 7,4e-14 ; 6,0e-14**.
- σ_USP de `usp_parametre()` contre B(4) littéral au (δ̂, γ̂) ajusté, σ_standard = 0,10, barèmes court et long : écart relatif **≤ 2,2e-16**.
- Minimisation littérale indépendante de B(6), L-BFGS-B sur δ ∈ [0, 1] :
  - même montant minimal à 1e-10 près ;
  - δ̂ à 5e-7 près et σ̂ à 3e-7 près en relatif. Cet écart vient de la tolérance de mon optimiseur d'essai, pas du moteur.
- Cas couverts : δ̂ = 1, δ̂ = 0, et δ̂ = 0,7101 (intérieur ; x = 133, 197, 414, 1426, 105, 1375, 1631, 572 ; y = 97,1, 89,5, 322,2, 1160,6, 86,7, 866,1, 1593,8, 430,2).
- Scripts hors dépôt : `/tmp/claude-0/-home-user-outil-usp/ccd41644-3789-51ad-8f10-9224610a5985/scratchpad/r/equiv.R`, `equiv2.R`, `equiv3.R` (le répertoire temporaire peut être purgé). Le noyau du script :

```r
xbar <- (1/T)*sum(x)
pi_lit  <- function(d,g) 1/log(1 + ((1-d)*xbar/x + d)*exp(2*g))
sig_lit <- function(d,g){p<-pi_lit(d,g); exp(g + (0.5*T + sum(p*log(y/x)))/sum(p))}
crit_lit<- function(d,g){p<-pi_lit(d,g); sum(p*(log(y/x)+1/(2*p)+g-log(sig_lit(d,g)))^2) - sum(log(p))}
```

## 3. Matrice de conformité

| Élément | Texte, page | Moteur (`940f941`) | `.tex` | Verdict |
|---|---|---|---|---|
| Art. 219(1)(a) → 19(1), valeurs manquantes | p. 143, p. 31 ; B/C(1) p. 272/274 ; B/C(2)(b) | motif l. 10953 : « (art. 19) » | tableau l. 4367 : juste | Code : **écart** mineur de citation (#585) ; texte du § 1.1. `.tex` : **conforme** |
| Art. 219(1)(b) | p. 143 | forme seule contrôlée | absent | **écart** documentaire mineur (#585) ; phrase du § 1.2 |
| Art. 219(1)(c) | p. 143 (« 2009/13/CE ») | sans objet | absent | **écart** documentaire mineur (#585) ; § 1.2 et § 1.3 |
| Art. 219(2)(a)-(e) | p. 143-144 | sans objet | absent | **écart** documentaire mineur (#585) |
| A(1)(a) | p. 272 | sans objet | « survenance » sans équivalence écrite | **écart** documentaire mineur (#586) ; B et D seulement |
| B(1)(a), C(1)(a) | p. 272, p. 274 | `xt`, `yt` | l. 3452 : « pertes agrégées » sans définition | **écart** documentaire mineur (#586) ; **interprétation** I-1 |
| B(4)(a)-(e) | p. 273 | `usp_parametre()` | formule absente sous forme imprimée | Code **conforme** (≤ 2,2e-16) ; `.tex` : #586 |
| B(5), (a)-(d)(i)-(ii) | p. 273-274 | `usp_noyau()`, `usp_pi()` | l. 3476 (forme équivalente) | **conforme** (≤ 7,4e-14) ; forme imprimée : #586 |
| B(6), (a)-(d), dernier alinéa | p. 274 | `usp_noyau()$obj`, `usp_objectif()`, bornes l. 1790 | l. 12030-12033 (forme profilée) | **conforme** (identité exacte) ; γ borné : interprétation déjà documentée |
| C(4)(a)-(e) | p. 275 | `usp_parametre()` avec σ_(res,s) | encadré l. 2551-2562 | **conforme** à la formule. C(4)(e) est dans les deux versions : précision à ajouter à l'encadré |
| C(5), C(6) | p. 275-276 | identiques à B | — | **conforme** |

## 4. Interprétations à trancher (`actuary`, puis le mainteneur)

- **I-1. Repère temporel de B(1)(a)** (§ 2.3), lectures (i) et (ii). Effet sur le moteur : aucun. Effet sur le dossier : le contenu de y_t que l'entreprise doit fournir. Recommandation : citation littérale, sans paraphrase.
- **I-2. Art. 219(1)(b)**. Lecture retenue dans la phrase proposée : l'outil contrôle la forme, pas le contenu. L'autre lecture serait « non vérifié du tout ». La première est exacte au regard de `sec:controles`.

## 5. Constats hors périmètre (ADR 0018) : la session trie

| Constat | Gravité | Critère | Preuve |
|---|---|---|---|
| Encadré l. 2551-2562 : les anomalies C(4)(e), 218(1)(c)(iv) et « 2009/13/CE » sont attribuées au « texte consolidé » alors qu'elles sont aussi dans la version d'origine | mineur | **aucun** (énoncé exact mais incomplet) ; dans le périmètre de l'étape 6 si `docwriter` touche l'encadré | images p. 275 et p. 143 ; extraction p. 142 |
| B(1)(a) / C(1)(a) : le contenu de y_t n'est pas dans la liste « Exigences de données non vérifiables » (l. 5512-5536) | mineur | **aucun** ; rattachable à #586 (« y_t selon B(1)(a) ») | lecture de la liste |
| Style de citation hétérogène dans le moteur : « art. 219(1)(a) et 19(1)(b) » (l. 11919, l. 11998) contre la forme développée (l. 17531-17532) | mineur, forme | **aucun** | `git show 940f941:R/engine.R` |

## 6. Points non vérifiés

- Le JOUE en anglais pour « 2009/13/EC » : je n'ai qu'une source secondaire, le Single Rulebook d'EIOPA (https://www.eiopa.europa.eu/rulebook/solvency-ii-single-rulebook/article-5876_en).
- L'identité de la directive 2009/13/CE : sources secondaires seulement (résultats de recherche ; je n'ai pas ouvert EUR-Lex 32009L0013).
- L'anomalie de l'art. 117(2)(a) sur la version d'origine.
- La prose de l'art. 19 et de l'art. 218(1)(c)(iv), lue par extraction de texte et non à l'image. Ce n'est pas une formule.
- `legislation.gov.uk` est inaccessible depuis la session : le domaine doit être autorisé dans les réglages réseau pour le consulter.

Sources : [EIOPA Single Rulebook, art. 219 (EN)](https://www.eiopa.europa.eu/rulebook/solvency-ii-single-rulebook/article-5876_en) ; [Directive 2009/13/CE (CTM 2006), copie sur comite-peches.fr](https://www.comite-peches.fr/wp-content/uploads/2023/09/Directive_CE_2009-13_Convention-MLC2006.pdf) ; [Conseil de l'UE, PE-CONS 43/2/13](https://data.consilium.europa.eu/doc/document/PE-43-2013-REV-2/fr/pdf).
