<!-- Rapport de `regulatory`, contrôle de conformité de l'énoncé de H3 (commit `75c9c01`, #524), sur la tête `91b16a4`, 10/11/2026. Texte intégral rendu par l'agent. -->

> *Rédigé par l'agent regulatory (IA).*

# Contrôle de conformité réglementaire : énoncé de H3 et texte voisin modifiés par le commit 75c9c01 (#524), branche K5

**Objet.** Commit 75c9c01 (docwriter, Refs #524) sur `/home/user/outil_usp/docs/latex/doc_tests_usp.tex`. Contexte lu dans `git diff main...HEAD`. Tête de branche : 91b16a4.

**Texte de référence.**
- Version consolidée `TEXTE consolidé_ 32015R0035 — FR — 14.11.2024.xhtml`, annexe XVII, sections B et C, toutes deux sous ▼B pour les passages en cause.
- Contrôle croisé sur `Règlement délégué.pdf` (JOUE L 12 du 17.1.2015) :
  - p. 273 : B(2)(g)(iii) et B(3) ;
  - p. 275 : C(2)(e)(iii).

**Méthode.**
- Les hypothèses B(2)(g)(i)-(iv) et C(2)(e)(i)-(iv) sont du texte : je les ai lues par extraction.
- Les formules de B(5), B(6), C(5) et C(6) sont des images : je les ai extraites du XHTML et lues en rendu graphique.
  - σ̂(δ̂,γ̂) et le montant à minimiser sont des images identiques octet pour octet entre B et C.
  - Les deux images de π_t diffèrent en octets mais donnent la même formule au rendu.

## 1. Lecture du texte (formules lues en rendu graphique)

- **B(5) = C(5).** σ̂(δ̂,γ̂) = exp( γ̂ + [½T + Σ_t π_t(δ̂,γ̂)·ln(y_t/x_t)] / Σ_t π_t(δ̂,γ̂) ).
- **B(5)(d) = C(5)(d).** π_t(δ̂,γ̂) = 1 / ln( 1 + ((1−δ̂)·x̄/x_t + δ̂)·e^{2γ̂} ), avec x̄ = (1/T)·Σ x_t (point ii.).
- **B(6) = C(6).** Montant à minimiser : Σ_t π_t·( ln(y_t/x_t) + 1/(2π_t) + γ̂ − ln σ̂(δ̂,γ̂) )² − Σ_t ln π_t. Le paramètre de mélange δ est borné à [0, 1].
- **B(2)(g)(iii).** « les pertes agrégées suivent une distribution log-normale ».
- **C(2)(e)(iii).** « le montant visé au paragraphe 1, point a), suit une distribution log-normale ».
- **B(2)(g)(i)-(ii) et C(2)(e)(i)-(ii).** Ces points sont posés « pour un segment et une année d'accident particuliers » (B) et « pour un segment et un exercice particuliers » (C).
- **Indépendance.** Aucune hypothèse d'indépendance entre années n'est énoncée.

Conséquence algébrique, vérifiée à la main :
- On pose ln β := ln σ̂ − γ̂.
- Le montant de B(6) devient Σ π_t (ln r_t + 1/(2π_t) − ln β)² − Σ ln π_t.
- C'est, à une constante près, −2 fois la log-vraisemblance de ln r_t, indépendants, de loi N(ln β − 1/(2π_t), 1/π_t).
- Minimiser en ln β redonne exactement ln β̂ = (T/2 + Σ π_t ln r_t)/Σ π_t, donc le σ̂ de B(5).

## 2. Matrice de conformité

| # | Paragraphe du règlement | Énoncé de la doc (après 75c9c01) | Verdict |
|---|---|---|---|
| 1 | B(2)(g)(i), C(2)(e)(i) : espérance « en relation linéaire proportionnelle » avec x_t, pour une année donnée | `sec:notations` : E[Y_t ∣ x_t] = β x_t (ajout du conditionnement) | **Conforme.** Proportionnel, sans constante. Le conditionnement par x_t traduit « pour une année d'accident particulière ». |
| 2 | B(2)(g)(ii), C(2)(e)(ii) : variance « en relation quadratique » avec x_t ; forme fixée par π_t en B(5)(d)/C(5)(d) | Var(Y_t ∣ x_t) = σ²[(1−δ) x̄ x_t + δ x_t²], δ∈[0,1], σ = β e^γ | **Conforme**, en tant que lecture déjà déclarée (« lecture retenue par l'outil »). Le texte de (ii) dit seulement « quadratique ». La forme exacte découle de π_t : Var/E² = e^{2γ}(δ + (1−δ)x̄/x_t), donc ψ_t = 1/π_t, identique au rendu de l'image. Seul le conditionnement a changé dans ce commit. |
| 3 | B(5)(d), C(5)(d) : π_t | ψ_t = ln(1 + Var(Y_t∣x_t)/E[Y_t∣x_t]²) = 1/π_t ; formule de π_t inchangée | **Conforme.** Même ordre des termes que le texte au facteur près : (1−δ)x̄/x_t + δ contre δ + (1−δ)x̄/x_t. |
| 4 | B(2)(g)(iii), C(2)(e)(iii) : loi log-normale | Y_t ∣ x_t ~ LN(μ_t, ψ_t), avec μ_t = ln(βx_t) − ψ_t/2 (ajout) | **Conforme au calcul** : la moyenne d'une LN(μ,ψ) est e^{μ+ψ/2} = βx_t. **Interprétation** sur la portée de « suivent une distribution log-normale » : voir § 3, lecture A ou B. |
| 5 | B(5)-(6), C(5)-(6) : critère en ln(y_t/x_t), π_t et 1/(2π_t) | Proposition « forme en ratio » : ln(Y_t/x_t) ∣ x_t ~ N(ln β − 1/(2π_t), 1/π_t), avec preuve par translation | **Conforme.** C'est exactement la loi dont le montant de B(6)/C(6) est la −2 log-vraisemblance (§ 1). La preuve est juste dans les deux sens. |
| 6 | Pas de paragraphe propre (conséquence de B(5)(d)) | Variance du ratio β²(e^{1/π_t} − 1) = σ²[δ + (1−δ)x̄/x_t] ; ratios identiquement distribués si et seulement si π_t est constant (δ = 1 ou x_t tous égaux) | **Conforme** (identités vérifiées). π_t ne dépend de t que par (1−δ)x̄/x_t, qui est constant si et seulement si δ = 1 ou si les x_t sont égaux. |
| 7 | Indépendance entre années : **non énoncée** par l'annexe XVII ; supposée par la forme additive en t du montant de B(6)/C(6) | `sec:notations` : « les Y_t étant indépendants conditionnellement aux x_t » ; encadré `sec:h3` : « Avec l'espérance et la variance du modèle et l'indépendance des années, elle équivaut à ε_t … i.i.d. » | **Interprétation**, correctement placée sous « lecture retenue par l'outil » dans `sec:notations`. Dans l'encadré, l'indépendance est citée sur le même plan que H1 et H2 alors qu'aucun texte ne la pose. Constat **mineur M1** (§ 4). |
| 8 | B(2)(g)(iii), C(2)(e)(iii) : citation et pages | Citation et références inchangées : B(2)(g)(iii) p. 273, C(2)(e)(iii) p. 275, « texte identique dans la version consolidée » | **Conforme.** Contrôlé sur le PDF du JOUE (p. 273 l. 8 et p. 275 l. 3) et sur la version consolidée. |
| 9 | C(1)(a) : définition du montant y_t (réserve n° 1) | Description dans l'encadré, inchangée | **Conforme** à C(1)(a). |
| 10 | B(2)(g)(iii), C(2)(e)(iii), lus avec (i)-(ii) | Encadré : « deux formes équivalentes à x_t connu, y_t lognormal de paramètres (μ_t, ψ_t), ou ln r_t normal d'espérance ln β − 1/(2π_t) et de variance 1/π_t, propres à l'année » | **Conforme** à la lecture B (§ 3). Deux réserves de forme, sans incidence sur le fond : constats **mineurs M2 et M3**. |
| 11 | Hors règlement (conséquence statistique) | Encadré : équivalence exacte pour les ε_t non observés ; test sur les z_t ; un rejet peut venir de H1 ou H2 | **Sans objet réglementaire.** Rien ne contredit le texte : l'annexe XVII ne prescrit aucun test de H3. Voir la remarque R1 pour `actuary`. |
| 12 | Hors règlement | Tableau des résidus : z_t ~ N(0, P), z = Pε, π̂_t tenu pour connu | **Sans objet réglementaire.** Exact sous la lecture B à π connu : P = I − w w′/w′w, avec w = √π, est un projecteur orthogonal. |
| 13 | B(2)(g)(iii), C(2)(e)(iii) (conséquence) | Tableau de bascule `sec:base-residus`, ligne H3 : « r_t est lognormal sachant x_t, de paramètres propres à l'année ; ni r_t ni u_t ne sont normaux » | **Conforme** à la lecture B. Corrige l'ancien « approximativement lognormal », qui n'avait pas de fondement dans le texte. |

## 3. Interprétation : portée de « suivent une distribution log-normale »

- **Lecture A (loi commune).** Les y_t, ou les ratios y_t/x_t, pris ensemble, forment un échantillon d'une seule loi log-normale.
  - Pour les y_t, cette lecture est incompatible avec B(2)(g)(i) dès que les x_t varient, puisque l'espérance est proportionnelle à x_t.
  - Pour les ratios, elle n'est compatible avec B(5)-(6) que si π_t est constant, c'est-à-dire δ = 1 ou des volumes égaux.
- **Lecture B (loi par année, sachant le volume) : celle de l'outil et de la doc.** Chaque y_t est log-normal sachant x_t, avec des paramètres propres à l'année, déterminés par (i) et (ii).
  - Les points (i) et (ii) sont eux-mêmes posés « pour une année d'accident / un exercice particulier ».
  - Le montant à minimiser de B(6)/C(6) est exactement la vraisemblance gaussienne de ln r_t avec une moyenne ln β − 1/(2π_t) et une variance 1/π_t propres à l'année.
  - La lecture B est donc la seule qui rende cohérents B(2)(g), B(5) et B(6), et de même pour C.
- **Verdict.** Interprétation, mais la lecture retenue est imposée par la cohérence du texte. Elle est déjà examinée par `actuary` dans #524 (issue approuvée par le mainteneur). Je ne propose pas d'issue nouvelle. Le choix reste formellement au mainteneur ; je recommande de le garder.
- Aucun impact sur σ_USP ni sur un verdict : le moteur calcule déjà selon la lecture B, comme le constate « code conforme » dans #524.

## 4. Constats

**Bloquant : aucun. Majeur : aucun.**

### M1 (mineur) : l'indépendance des années présentée comme une donnée du modèle, sans dire que le texte ne l'énonce pas

- **Où.** Encadré de `sec:h3` (vers la l. 10512) ; accessoirement `sec:notations` (vers la l. 3176).
- **Problème.** Le lecteur d'un dossier ACPR peut croire que l'indépendance des années figure parmi les hypothèses B(2)(g) ou C(2)(e), ce qui n'est pas le cas. Elle n'est que supposée par la forme additive en t du montant de B(6)/C(6).

Remplacements proposés :

- Dans l'encadré `sec:h3`, remplacer
  `Avec l'espérance et la variance du modèle et l'indépendance des années, elle équivaut à`
  par
  `Avec l'espérance et la variance du modèle et l'indépendance des années (que l'annexe~XVII n'énonce pas, mais que suppose la forme additive en~$t$ du montant à minimiser de B(6) et C(6)), elle équivaut à`
- Dans `sec:notations`, remplacer
  `les $Y_t$ étant indépendants conditionnellement aux $x_t$.`
  par
  `les $Y_t$ étant indépendants conditionnellement aux $x_t$ (hypothèse que l'annexe~XVII n'énonce pas, et que suppose la forme additive en~$t$ du montant à minimiser de B(6) et C(6)).`

### M2 (mineur) : la lecture « par année » n'est pas rattachée au texte qui la fonde

- **Où.** Encadré de `sec:h3`.
- **Problème.** La phrase « deux formes équivalentes à x_t connu … propres à l'année » est juste, mais elle ne dit pas pourquoi la loi s'entend année par année. Le fondement textuel est double : le libellé « pour une année d'accident particulière » de (i)-(ii), et la vraisemblance de B(6)/C(6).

Remplacement proposé, dans l'encadré : remplacer
`l'hypothèse s'énonce sous deux formes équivalentes à $x_t$ connu,`
par
`les hypothèses i. et ii. étant posées pour une année d'accident (un exercice) particulière, et le montant à minimiser de B(6) et C(6) étant la vraisemblance gaussienne des $\ln r_t$ de paramètres propres à l'année, l'hypothèse s'entend année par année, sachant le volume, et s'énonce sous deux formes équivalentes à $x_t$ connu,`

### M3 (mineur, notation) : y_t désigne dans l'encadré la variable aléatoire, alors que `sec:notations` l'écrit Y_t

- **Problème.** La proposition de `sec:notations` porte sur Y_t et ln(Y_t/x_t) ; l'encadré emploie « y_t lognormal » et « la loi de y_t ». Le règlement (B(3)(c), C(3)(c)) n'emploie que y_t, et la phrase d'ouverture de l'encadré, qui reprend le texte, peut garder y_t. La forme traduite gagne à suivre la notation de la proposition.

Remplacements proposés, dans l'encadré :
- `$y_t$ lognormal de paramètres $(\mu_t, \psi_t)$, ou $\ln r_t$ normal` → `$Y_t$ lognormal sachant $x_t$, de paramètres $(\mu_t, \psi_t)$, ou $\ln(Y_t/x_t)$ normal` ;
- `même quand la loi de $y_t$ est lognormale` → `même quand la loi de $Y_t$ sachant $x_t$ est lognormale`.

## 5. Remarques hors périmètre du commit (aucun verdict demandé)

- **R1, pour `actuary`.** L'encadré dit qu'un rejet sur les z_t « peut aussi venir d'un écart à H1 ou à H2 ». L'équivalence énoncée juste avant repose aussi sur l'indépendance des années : un rejet peut donc venir aussi d'une dépendance entre années. Faut-il le compléter ? C'est une question de fond statistique, pas de conformité.
- **R2, pour `actuary`.** La sous-section « Résidus » de `sec:notations` n'a pas été touchée par le commit. Elle dit toujours que les z_t sont « approximativement indépendants et de loi N(0,1) ».
  - Le tableau voisin dit désormais z ~ N(0, P), avec P de rang T − 1 et des covariances hors diagonale de l'ordre de −1/T, soit environ −1/8 à T = 8.
  - Ce n'est pas réglementaire, mais il y a un risque d'incohérence interne. Les critères d'acceptation de #524 ne visent que la loi « i.i.d. N(0,1) comme loi de z_t » : à apprécier.
- **R3, texte non modifié.** B(3)(c) écrit « pertes accumulées » pour y_t, à l'identique dans le JOUE (p. 273, l. 15) et dans la version consolidée. La doc écrit « pertes agrégées », conformément à B(1)(a) et B(2)(g)(iii).
  - Assimiler les deux expressions va de soi : B(1) ne définit qu'une seule donnée de pertes.
  - Ni écart ni action ; je le relève pour la traçabilité.

## 6. Issue proposée

**Aucune.**
- Aucun écart.
- La seule interprétation (§ 3) est déjà instruite dans #524 et y est retenue.
- Les constats M1 à M3 sont des précisions rédactionnelles du `.tex` relevant de #524. Ils peuvent être traités sur la branche K5 par un commit `docs:` Refs #524 (docwriter, puis validation du diff par `actuary`), au choix du mainteneur, sans nouvelle issue.

## 7. Conclusion

Le texte modifié par 75c9c01 est **conforme** à l'annexe XVII, sections B et C (hypothèses (i)-(iv) et formules des paragraphes 5 et 6 lues en rendu graphique).
- Chaque identité ajoutée (μ_t, ψ_t = 1/π_t, forme en ratio, variance du ratio, condition d'égalité des lois) est exacte.
- La loi de ln r_t énoncée est exactement celle dont B(6)/C(6) est la vraisemblance.
- Les citations et les pages du JOUE sont justes.
- Trois constats mineurs, sans effet sur σ_USP, un verdict ou une p-value.

Fichiers et sources :
- `/home/user/outil_usp/docs/latex/doc_tests_usp.tex` (`sec:notations` vers les l. 3119-3202 ; `sec:base-residus`, tableau de bascule vers la l. 8558 ; `sec:h3`, encadré vers les l. 10500-10518) ;
- `/home/user/outil_usp/TEXTE consolidé_ 32015R0035 — FR — 14.11.2024.xhtml` ;
- `/home/user/outil_usp/Règlement délégué.pdf`, p. 273 et 275 ;
- images de formules extraites pour lecture, fichiers temporaires hors dépôt : `/tmp/claude-0/-home-user-outil-usp/44e0e2fa-1b3c-4ab0-b9ae-f0ba84a16766/scratchpad/img/05.jpg` (σ̂), `/tmp/claude-0/-home-user-outil-usp/44e0e2fa-1b3c-4ab0-b9ae-f0ba84a16766/scratchpad/img/08.jpg` (π_t, section B), `/tmp/claude-0/-home-user-outil-usp/44e0e2fa-1b3c-4ab0-b9ae-f0ba84a16766/scratchpad/img/15.jpg` (montant de B(6)), `/tmp/claude-0/-home-user-outil-usp/44e0e2fa-1b3c-4ab0-b9ae-f0ba84a16766/scratchpad/img/26.jpg` (π_t, section C).

Aucune écriture dans le dépôt, aucune issue créée.
