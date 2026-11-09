# Revue finale, volet réglementaire : PR #511 (K1 « Entrées et validation »)

> *Rédigé par l'agent regulatory (IA).* Lecture seule : aucune écriture, aucun commit, aucune issue créée.

**Ce qui a été revu.** Branche `claude/entrees-et-validation`, tête `39111c0`. Diff relu : `main...HEAD` pour `R/engine.R` et les références, `c80e641^..39111c0` pour `docs/latex/doc_tests_usp.tex`.

**Textes de référence.**
- Règlement délégué (UE) 2015/35, annexe XVII. Texte de référence de l'outil : la version consolidée du 14.11.2024 versionnée à la racine (`TEXTE consolidé_ 32015R0035 — FR — 14.11.2024.xhtml`).
- Pour les formules, lecture en rendu graphique des pages du JOUE L 12 du 17.1.2015 (`Règlement délégué.pdf`), p. L 12/276 et L 12/277 (section D, paragraphes 1 à 5). Le texte des paragraphes 2 et 3 a été recoupé avec la version consolidée ; il est identique pour les passages cités.

## Verdict global

**Conforme. Aucun écart sur une formule, un paramètre ou un barème réglementaire.**
- Aucun σ_USP, facteur de crédibilité ni barème n'a changé.
- Les quatre contrôles d'entrée revus (#482, #483/#490, #489, #491) sont conformes à l'annexe XVII ou plus stricts qu'elle, sans contredire la lettre du texte.
- Les affirmations réglementaires retirées des libellés par #514 se retrouvent toutes dans le `.tex`.
- Un seul écart, **documentaire et mineur**, hors formule réglementaire : une phrase du `.tex` (l. 7420) est restée périmée après #514 (point 5.3).
- Trois observations sans gravité.

## Matrice de conformité

### 1. Paramètres réglementaires et σ_USP (non-régression)

| Élément | Contrôle | Résultat | Verdict |
|---|---|---|---|
| `ANNEXE_II` (`R/engine.R:66`), `ANNEXE_XIV` (`:106`) | empreinte md5 du bloc, `main` contre la tête | identique (0724b56e, 0ac5993c) | Conforme, inchangé |
| `CRED_LONG` (`:141`), `CRED_COURT` (`:146`), annexe XVII, section G | `diff` des blocs | identiques | Conforme, inchangé |
| `usp_parametre()`, `mw_parametre()`, `usp_ajuster()`, `mw_ajuster()`, `mw_msep()`, `usp_noyau()` | empreinte du corps de fonction | identique | Conforme, inchangé |
| `usp_objectif()`, `usp_gradient()`, `usp_gradient_optim()` (#513) | lecture du diff | seul ajout : un argument `noyau` / `k` mémoïsé ; même appel `usp_noyau(par[1], par[2], x, y, xbar)`, donc même critère B(6) / C(6) | Conforme (aucun changement de formule) |
| σ_USP des six cas de référence | `res$parametre` des `.rds` de `main` et de la tête comparés par `identical()`, plus recalcul à la tête par `executer_cas()` | `identical = TRUE` pour les six cas ; reserve2 = **0,049776461289** (cas de l'audit 0,04977646, inchangé) ; premium 0,1114524114 ; reserve1 0,1073524114 ; premium_net 0,1032524114 ; premium_ii6 0,1483524114 ; premium_interieur 0,0871308679 ; c = 0,59 partout | Conforme, inchangé |

Les `.rds` reserve1 et reserve2 ont changé de taille. Cela vient des textes `detail` de #514 : `res$parametre` y est identique au bit près.

### 2. B(2)(b) et C(2)(b), séries des méthodes lognormales : #482

**Ce que dit le texte.**
- B(1), dernier alinéa : « Ces pertes agrégées et primes acquises sont disponibles séparément pour chaque année d'accident ».
- B(2)(b) : « les données sont disponibles pour cinq années d'accident consécutives au moins ».
- B(3)(a)-(b) : années « représentées par des nombres consécutifs, commençant par 1 » ; « T représente la dernière année d'accident pour laquelle des données sont disponibles ».
- C(1), dernier alinéa, C(2)(b) (« cinq exercices consécutifs au moins ») et C(3)(a)-(b) sont homologues.
- Les formules de B(5) et B(6) (images, p. L 12/276) somment sur t = 1..T des termes en x_t **et** y_t de la même année.

**Ce que fait le code.**
- `engine_valider_serie_retenue()` (`R/engine.R:8122`, garde `:8134`) ne tronque plus à T si `length(yt) != length(xt)`.
- La série est alors refusée par le motif de longueur d'`engine_valider_donnees()` (`:7950`).
- Mesuré à la tête : xt de 10 valeurs, yt de 9 valeurs, `T = 8` → `ok = FALSE`, motif « xt (10 valeurs) et yt (9 valeurs) doivent avoir la meme longueur. »

**Analyse.** Avant le correctif, la troncature sur les indices de xt appariait x_t à y_{t+1}. C'était un écart à B(5)/B(6) : x_t et y_t n'y désignent pas la même année d'accident. Le refus rétablit l'appariement exigé par B(1) et B(3)(c)-(d). Le texte ne prescrit aucun réalignement automatique ; l'outil n'a d'ailleurs pas les libellés d'année pour en faire un sans colonne t.

**Doc.** `doc_tests_usp.tex:3916-3926`, ligne « Profondeur minimale », citation « Annexe XVII, B/C(2)(b) ». Fidèle.

**Verdict : conforme.** Gravité : sans objet.

### 3. Lecture des fichiers : #483 et #490

**Ce que dit le texte.**
- B(2)(b), C(2)(b), D(2)(b) : années consécutives.
- B(3)(a), C(3)(a), D(3)(a) : numérotation consécutive.
- Art. 219, paragraphe 1, point a) : données exhaustives et exactes.

**Ce que fait le code.**
- `.retirer_lignes_colonnes_vides()` (`R/engine.R:7400`, motifs vers `:7412-7413`) :
  - une ligne entièrement vide en tête ou intercalée est refusée comme « année manquante présumée ». Le motif cite « l'annexe XVII, B(2)(b) et C(2)(b) » pour les séries et « l'annexe XVII, D(2)(b) » pour le triangle ;
  - les lignes vides de fin de tableau sont retirées sans refus.
- Mesuré à la tête : triangle reserve2 avec la ligne 3 vidée → motif « Ligne(s) vide(s) intercalee(s) dans le triangle (ligne(s) de donnees 3) : … l'annexe XVII, D(2)(b), exige des annees d'accident consecutives. »
- #490 refuse l'hexadécimal, l'exposant incomplet et le point sous `dec = ","`. Ces refus protègent l'exactitude (art. 219(1)(a)), par exemple un séparateur de milliers lu comme décimale. Aucune incidence sur une formule.

**Analyse.**
- Lue avec B(3)(a) / D(3)(a), la citation est juste : une année vide intercalée rompt la numérotation consécutive de la série ou du triangle.
- Lecture « plus stricte » à noter : B(2)(b) n'exige que cinq années consécutives *au moins*. L'outil refuse au lieu de retenir le bloc consécutif le plus récent. Ce refus ne contredit pas le texte : une exclusion d'années est un choix de périmètre à justifier (art. 219(1)(a) et (e)), déjà porté par la ligne « profondeur » d'`engine_derogations()` (#104).

**Doc.** Paragraphe « Lecture des fichiers » (ajouts de `20c3903`, `f2d4f33`, `39111c0` : « année d'accident manquante présumée (D(2)(b)) », « année manquante présumée (B(2)(b) et C(2)(b)) »). Fidèle.

**Verdict : conforme.** Deux observations sans gravité (O1, O2 ci-dessous).

### 4. D(2) et D(3), triangle : #491, cellules i + j > I

**Ce que dit le texte.**
- D(2)(b) : « cinq années d'accident consécutives au moins ».
- D(3)(b) : I est la dernière année d'accident disponible.
- D(4)(c), en image p. L 12/277 : Ĉ(i,j) = C(i,I−i) · f̂_{I−i} ⋯ f̂_{j−1}, et f̂_j = Σ_{i=0}^{I−j−1} C(i,j+1) / Σ_{i=0}^{I−j−1} C(i,j).
- D(5), même page : seuls C(i,I−i), S_j = Σ_{i=0}^{I−j−1} C(i,j) et S′_j interviennent.
- Aucune formule des paragraphes 4 et 5 ne lit une cellule i + j > I.

**Ce que fait le code.**
- `mw_valider_triangle()` (`R/engine.R:8910` ; avertissement `:9109-9124`) signale toute cellule i + j > I renseignée, NaN compris, par un **avertissement non bloquant**.
- `.run_engine_mw()` la met à `NA` après la validation (`:13192`).
- Les contrôles D(2)(b) (`:8918`), D(2)(c) et D(2)(e) sont inchangés. Ils portent sur les dimensions, que la remise à NA ne change pas.
- Mesuré à la tête : les 28 cellules sous la diagonale du triangle reserve2 remplies à 1e9 → `ok = TRUE`, σ_USP = 0,04977646, identique au triangle d'origine ; 28 NA restitués dans `res$triangle` ; avertissement émis (5 positions « et 23 autre(s) »).

**Analyse.** Ignorer ces cellules est exactement ce que fait le texte, puisque D(4)(c) et D(5) ne les lisent pas. L'avertissement est une convention de l'outil, sans source réglementaire, et le `.tex` le dit.

**Doc.** `doc_tests_usp.tex:4449-4454`, ligne « Cellules sous la diagonale ». Fidèle (observation O3).

**Verdict : conforme.** Gravité : sans objet.

### 5. #514 : affirmations réglementaires retirées des `detail`, et passage de `docwriter` (`c80e641` → `39111c0`)

J'ai relevé toutes les lignes supprimées du diff (moteur et `.tex`) qui portent une référence réglementaire (annexe, article, B(·)/C(·)/D(·)/G(·), « règlement »), puis j'ai cherché si chacune est reprise ailleurs.

| Affirmation retirée | Où elle est reprise | Verdict |
|---|---|---|
| Phrase #409, famille α : « alpha = 1 : chain-ladder du reglement » et « la ligne porte sur … M1, non sur l'exposant de variance (M2) » | Libellé (`R/engine.R:12358`) : « … esperance non proportionnelle au cumul (M1), non un defaut de variance (…, seul alpha = 1 entre dans sigma_USP) ». Fiche `\ref{mw:m1d}`, `doc_tests_usp.tex:15259-15271` : « α = 1 le facteur chain-ladder du règlement », « le règlement retient α = 1 », « seul f̂_j^{(1)} entre ». L'identification α = 1 ↔ f̂_j de D(4)(c) est juste (moyenne pondérée par C(i,j), image p. L 12/277). | Conforme, reprise |
| Exposant de variance : « interpretation de l'outil, D(4)(c) et D(5)(d)(ii) » | `.tex:15733`, `15749` (« interprétation de l'outil, D(4)(c) et D(5)(d)(ii) ») | Conforme, reprise |
| Homogénéité des années de survenance : « ne teste pas a elle seule l'independance de D(2)(h)(i) » | Nouveau libellé (« sans tester a elle seule l'independance de D(2)(h)(i) »), cité au `.tex` | Conforme, reprise |
| Shapiro–Wilk M5 : « l'annexe XVII, D(2)(h), ne specifie que les deux premiers moments » | Nouveau libellé : « la normalite n'est pas exigee par le modele (D(2)(h) : deux premiers moments) ». Juste : D(2)(h)(iii)-(iv) ne posent que l'espérance et la variance. | Conforme, reprise |
| M6 : « Valeur fixee par la regle de minimum de l'annexe XVII, D(5)(d)(ii), **seconde ligne** » | Libellé raccourci en « … D(5)(d)(ii), non estimee : » (`R/engine.R:9430`, `:9472`). La précision « seconde ligne » reste dans la fiche (`\refl`, `.tex:17176` ; Cadre `:17182`) et dans le tableau `:7417`. | Conforme : référence juste, moins fine dans le libellé seul |
| RESET, Pitman, pente MCO : « n'est pas exacte sous le modele de l'annexe XVII », « hors modele reglementaire », « modele auxiliaire MCO … non reglementaire » | Fond statistique (domaine `actuary`). Le nouveau libellé garde « (non reglementaire) » ; le `.tex` garde « hors modèle réglementaire » (par ex. `:6689`). | Hors périmètre réglementaire strict ; aucune perte constatée |
| Concentration M6 : « sans fondement reglementaire ni statistique » | Gardé dans le nouveau libellé | Conforme |
| Puissance de l'enveloppe H2 : « famille de l'annexe XVII » | Retirée de la parenthèse du libellé ; la fiche H2 du `.tex` n'est pas touchée sur ce point | Pas une affirmation de conformité ; sans gravité |

**5.3, écart documentaire mineur (hors formule réglementaire).**
- Où : `docs/latex/doc_tests_usp.tex:7420`, tableau des convergences, ligne « Extrapolation de σ̂²_{J−1} (diagnostic) ».
- Ce qu'on y lit : « sensibilité indicative de √MSEP, hors règle, **restituée par la ligne** (triangle de contrôle : +13,5 % et +36,0 % …) ».
- Pourquoi c'est faux : depuis #514 (Q-3), cette sensibilité ne figure plus dans le `detail`, et `run_engine()` n'appelle plus `mw_sensibilite_sigma2_dernier()` (commentaire `R/engine.R`, hunk de `mw_msep`). La phrase contredit le `.tex` lui-même, l. 1482 (« sensibilité ne figurant pas dans le commentaire de la ligne ») et la fiche `mw:m6sig` (l. 17205 environ).
- Ce qui reste vrai : « hors règle », « sans effet sur σ_(res,s,USP) ».
- Gravité : **mineure**. Aucun calcul n'est touché, mais le dossier contient une affirmation fausse sur le contenu d'une sortie.
- Correction proposée : un commit `docs:` minimal dans la branche, sous Refs #514, avant la sortie du brouillon, par exemple « … hors règle, rendue par `mw_sensibilite_sigma2_dernier()` et non restituée par la ligne (…) ». À confier à `docwriter`. Cela ne justifie pas d'issue séparée.

### 6. #489 : choix exact de `methode` et d'`annexe` (contrôle annexe)

**Ce que dit le texte.** Annexe XVII, A(2) : le segment s est un segment de l'annexe II **ou** de l'annexe XIV. Le choix de l'annexe détermine σ standard et barème.

**Ce que fait le code.** `choix_exact()` dans `run_engine()` (`R/engine.R:13798`) refuse toute abréviation. Avant le correctif, `match.arg()` lisait `annexe = "X"` comme XIV, soit σ standard 0,05 au lieu de 0,10 pour un segment voulu ailleurs. Le comportement rejoint celui de `.annexe_verifiee()` (`:367`).

**Doc.** Tableau des erreurs d'usage (ajouts de `6fcc6b1`). Fidèle.

**Verdict : conforme.** Le correctif supprime un risque d'application du mauvais paramètre standard.

## Observations sans gravité (aucune action requise)

- **O1.** Le motif du refus de ligne vide pour la réserve n° 1 parle d'« année » et cite « B(2)(b) et C(2)(b) ». C(2)(b) dit « exercices consécutifs ». Le vocabulaire est approximatif, mais la référence est juste.
- **O2.** Une colonne vide intercalée du triangle est refusée « sans renvoi réglementaire » (commentaire `R/engine.R` avant `:7400`, et `.tex`). Il existe pourtant un fondement : D(1) (« chaque année de développement »), D(2)(c) (« cinq années de développement consécutives ») et D(3)(c). Le citer serait plus précis. Ce n'est pas une erreur.
- **O3.** La ligne « Cellules sous la diagonale » du `.tex` (l. 4449) qualifie l'avertissement de « convention de l'outil sans source réglementaire ». C'est juste pour l'avertissement. On pourrait ajouter que **ne pas lire** ces cellules découle de D(4)(c) et D(5), qui somment sur i ≤ I − j − 1.

## Issue proposée

Aucune. Le seul écart (5.3) relève du périmètre de #514 et se corrige dans la branche par un commit `docs:` minimal.

## Retour (routage)

Effort de la fiche (`medium`). Aucun critère d'escalade rencontré. Aucune question d'interprétation à porter à `actuary` ni au mainteneur. Les retraits de fond statistique (RESET, Pitman) ne sont pas jugés ici ; ils relèvent de la validation de fin de branche d'`actuary`.
