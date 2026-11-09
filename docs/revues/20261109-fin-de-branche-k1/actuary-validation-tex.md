# Validation de fond du diff du `.tex` de la branche K1 « Entrées et validation » (PR #511, tête `39111c0`)

> *Rédigé par l'agent actuary (fiche de jugement, IA), en lecture seule, le 09/11/2026.*

## Verdict

**Conforme avec réserves.**

Le diff du `.tex` (`git diff main...HEAD -- docs/latex/ docs/suivi-documentation/`) suit fidèlement le code de la tête. Il ne confond pas les statuts épistémiques et n'introduit aucune référence nouvelle. La concordance stricte ne relève aucun écart. Le fond retiré du `.tex` est consigné dans les fichiers de suivi.

Les réserves portent surtout sur des **textes de `detail` du moteur**, que le `.tex` cite fidèlement :
- un texte est faux dans une branche rare (constat C1) ;
- un texte réintroduit une attribution à Andrews (2000) que le mainteneur avait corrigée (Q-D2-Fn-5 bis, constat C2) ;
- trois textes perdent le statut ou la portée d'un constat de simulation (C3 à C5).

S'y ajoutent trois précisions mineures du `.tex` (C6 à C8).

Les textes de C1 et de C2 viennent de **ma propre spécification de #514** (`docs/revues/20261109-detail-deux-phrases/specification-actuary.md`, § 4, lignes « Variance unitaire » et G3). L'erreur est donc en amont du code.

Je recommande de corriger C1 à C5 **dans K1**, avant la revue finale de la règle 10. Il faut pour cela :
- un commit `moteur:` de #514 ;
- un patch chirurgical des références, sur les seuls champs `detail` ;
- un commit `docs:` minimal.

## Périmètre et méthode

Lu :
- le diff complet du `.tex` (1 807 lignes de diff) et des cinq fichiers de `docs/suivi-documentation/` ;
- les messages de commit de `23c6441`, `d8e4a09` et `3de7731` ;
- le dossier `docs/revues/20261109-detail-deux-phrases/` ;
- le corps et les commentaires de la PR #511 (API REST), et l'issue #409 ;
- `docs/specifications/fn-d2-lecture-couverture.md` (Q-D2-Fn-5 bis) et `docs/specifications/fi-merz-wuthrich-puissance.md` (Q-D1-Fi-7) ;
- les fiches touchées : `sec:notations`, `sec:base-residus`, `fiche:variance-unitaire`, `fiche:rosner-esd`, `fiche:ic-bootstrap`, `fiche:breusch-pagan-1979`, `mw:m4ros`, `mw:m5sw`, `mw:m5li`, `mw:m6sig` ;
- le code correspondant de `R/engine.R`.

Mesures exécutées sous `LC_ALL=C.UTF-8`, moteur chargé par `source("R/charger_moteur.R"); charger_moteur()`, scripts dans le scratchpad :
1. Les `detail` des références `premium`, `premium_interieur` et `reserve2` de la tête, comparés à ceux de `main`.
2. `mw_sensibilite_sigma2_dernier(res$ajustement)` sur la référence `reserve2`.
3. Les trois scénarios de mesure de la règle R8 (`run_engine()`, méthode prime, segment 1, `B = 99`, `nature_donnees = "brutes"`).
4. La bande de tolérance par $1-\hat\delta$ et par l'étendue relative des volumes, avec les outils `force514()`/`ut514()` de `tests/unitaires/test_detail_deux_phrases.R`.
5. La branche dégénérée de la ligne des suites sur ratios bruts (Runsr), à $\hat\delta = 1$ et dans la bande.
6. `tests/concordance_doc_moteur.R --strict` : `0 ecart(s)`, code 0.
7. Longueurs des textes proposés ci-dessous, avec `nchar()`.

## Constats

### C1 — Variance unitaire des résidus standardisés, bande de tolérance due aux volumes : texte faux. **Majeur** (faux, mais branche rare). *Vérifié.*

- **Où** : `R/engine.R:6799-6800` (fonction `contrainte()` de `usp_tests()`).
- **Mesure** : volumes $100\,(1 \pm 2\cdot 10^{-7})$ et pertes du jeu de contrôle, `run_engine()` avec `B = 99`. On obtient $\hat\delta = 0$ et le `detail` « … bloque sur une borne de son domaine [-12, 3] (a un ecart d'ordre (1 - delta) pres, pi_t n'etant constant qu'a TOL_DELTA_BORD pres) ».
  - À $\hat\delta = 0$, « ordre $(1-\delta)$ » vaut 1 : c'est faux.
  - L'ordre réel est celui de l'étendue relative des volumes ($4\cdot10^{-7}$).
- **Origine** : régression de #514. Le texte de `main` disait « d'ordre (1 - delta), ou de l'etendue relative des volumes x_t, ». La fiche `fiche:variance-unitaire` (`doc_tests_usp.tex:11749-11751`) décrit bien la réserve complète : le `.tex` est juste, le code ne l'est plus.
- **Texte proposé** (branche bande ; texte propre de 388 caractères, deux phrases) : « Grandeur rivee par l'estimation, aucune p-value retenue : a pi_t constant a TOL_DELTA_BORD pres seulement, un ecart de var(z) a T/(T-1) signale une convergence imparfaite en gamma, ou gamma bloque sur une borne de son domaine [-12, 3], a un ecart d'ordre (1 - delta), ou de l'etendue relative des volumes, pres. A lire avec "Centrage des residus standardises" et les controles numeriques. »
- **Effet** : aucune des six références n'est dans la bande. Il n'y a donc aucun patch, seulement le code et un test de la branche (scénario S3 « etendue relative des volumes » de `test_detail_deux_phrases.R`). Le `.tex` est inchangé.

### C2 — Ligne « Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) » : attribution à Andrews (2000) au-delà de la source, contraire à une décision du mainteneur. **Majeur.** *Vérifié.*

- **Où** : `R/engine.R:7240-7244`.
- **Texte actuel** : « …, a couverture inferieure au niveau nominal a T = 8, bootstrap au bord non justifie pour delta (Andrews, 2000). »
- **Ce qui ne va pas** :
  1. **Q-D2-Fn-5 bis** (`docs/specifications/fn-d2-lecture-couverture.md:13`) a fixé la portée : « Andrews (2000) montre que le bootstrap n'est pas convergent quand le parametre est au bord, dans un modele de moyenne contrainte ; sa transposition a l'estimateur de delta n'est pas demontree, et l'effet sur sigma n'est pas etabli. » Le commentaire de code juste au-dessus (`R/engine.R:7228-7230`) le rappelle encore. Le texte de #514 rattache à nouveau à Andrews une conclusion sur $\delta$ : c'est la réintroduction d'une formulation déjà corrigée.
  2. Le `.tex` dit, pour cet intervalle précis, qu'il « ne réestime pas $\delta$, hors du champ d'Andrews » (`fiche:ic-bootstrap`, vers `doc_tests_usp.tex:12924-12926`).
  3. Le statut « en simulation » de la sous-couverture manque. La ligne G2 le porte.
- **Texte proposé** (378 caractères, deux phrases, portée de Q-D2-Fn-5 bis conservée) : « Incertitude conditionnelle a delta fixe a delta estime (res$ic_bootstrap_restreint), a couverture inferieure au niveau nominal a T = 8 en simulation, bootstrap au bord non convergent pour une moyenne contrainte (Andrews, 2000), sans transposition demontree a delta ni effet etabli sur sigma. A lire avec "Largeur relative de l'IC bootstrap 90%" et "Position de delta dans [0,1]". »
- **Variante** (271 caractères) : retirer Andrews du `detail` et le laisser à la fiche. Elle s'écarte aussi de Q-D2-Fn-5 bis : **décision du mainteneur**.
- **Effet** : patch des cinq références lognormales (champ `detail` de G3). Reprise de `sec:graines` (C8).

### C3 — ESD de Rosner (méthode lognormale) : niveau supérieur à α présenté sans son statut. **Mineur.** *Vérifié.*

- **Où** : `R/engine.R:6900` ; citation à `doc_tests_usp.tex:12266-12270`.
- « a niveau superieur a alpha a T = 8 » repose sur le seul constat de simulation C7.a (0,1506 à α = 0,10, `fiche:rosner-esd`, rubriques 5 et 6). La fiche dit que l'article ne permet aucune conclusion chiffrée à T = 8. L'ancien texte renvoyait à la fiche.
- **Texte proposé** (319 caractères au pire, α = 0.001) : « … a niveau superieur a alpha a T = 8 en simulation (valeurs critiques adequates a partir de n = 25 selon l'auteur). … »
- **Effet** : patch des cinq références lognormales. Mise à jour de la citation de `fiche:rosner-esd`.

### C4 — Shapiro-Wilk et Lilliefors sur résidus de Mack : portée du constat de simulation perdue. **Mineur.** *Vérifié.*

- **Où** : `R/engine.R:12751` et `12767`.
- « rejette trop souvent sur des residus de Mack (simulation) » généralise un constat fait **sous un plan, à erreurs gaussiennes** : `mw:m5sw` donne 0,221 [0,203 ; 0,240], et la fiche précise que sous les lois E et A « les taux mesurés ne sont pas des niveaux ». L'ancien texte disait « sous erreurs gaussiennes, elle rejette plus souvent que le seuil nominal (constat de simulation sous un plan) ».
- **Textes proposés** :
  - Shapiro-Wilk (376 caractères) : « … et la loi de W, celle d'un echantillon i.i.d. normal, rejette plus souvent que le seuil nominal sur des residus de Mack a erreurs gaussiennes (simulation sous un plan), p-value utile seulement pour un quantile de la MSEP. … »
  - Lilliefors (302 caractères) : « … qui rejette plus souvent que le seuil nominal sur des residus de Mack a erreurs gaussiennes (simulation sous un plan), … »
- **Effet** : patch de `reserve2`. Le `.tex` ne cite pas ces textes.

### C5 — Breusch-Pagan original : « sur-rejette si les erreurs ne sont pas normales ». **Mineur, antérieur à K1**, repris tel quel par #514. *Vérifié.*

- **Où** : `R/engine.R:6316`.
- Le `.tex` limite à juste titre le sur-rejet aux **queues plus lourdes** que la normale : `fiche:breusch-pagan-1979`, `doc_tests_usp.tex:10061-10064` (« à queues plus lourdes que la normale, Var(u_t²) > 2σ⁴ … le test sur-rejette ») et le tableau de la ligne 8714.
- Sous des erreurs à queues légères, le facteur 1/2 surestime la variance de la statistique, et le sur-rejet ne suit pas. Cette dernière phrase est une déduction de la même formule, que le `.tex` ne développe pas : *hypothèse de lecture*.
- **Texte proposé** (286 caractères) : « Version publiee du test de Breusch-Pagan, non robuste (sur-rejette sous des erreurs a queues plus lourdes que la normale), pour comparaison. … »
- **Effet** : patch des cinq références lognormales, à joindre au même patch que C2 et C3. Sinon, issue à part.

### C6 — `mw:m6sig`, paragraphe « Sensibilité indicative » : deux précisions de condition omises. **Mineur.** *Vérifié.*

- **Où** : `doc_tests_usp.tex:17215` et `1480`.
- « `NA` pour un quotient non défini » ne dit plus que `mw_sensibilite_sigma2_dernier()` met ce `NA` aussi quand la colonne $J-3$ est dégénérée à la tolérance relative $10^{-12}$ (`R/engine.R:9594-9605`), alors que le `detail` ne dit « non defini » qu'à $\hat\sigma^2_{J-3} = 0$ exactement (`R/engine.R:9432`).
- Le `.tex` ne dit plus que la fonction rend `applicable = FALSE` et des `NA` quand la règle n'est pas applicable ou quand la $\sqrt{\mathrm{MSEP}}$ de la règle n'est pas finie et strictement positive (`R/engine.R:9577-9588`). L'ancien `.tex` le disait.
- **Texte proposé** : « … (\code{NA} pour un quotient non défini, $\hat\sigma^2_{J-3}$ nul ou colonne $J-3$ dégénérée à la tolérance relative $10^{-12}$) … ; la fonction rend \code{applicable} faux et des valeurs \code{NA} si la règle n'est pas applicable ou si la $\sqrt{\mathrm{MSEP}}$ de la règle n'est pas finie et strictement positive, les écarts relatifs n'ayant alors pas de sens. »

### C7 — `mw:m4ros`, rubrique 5 : raison répétée. **Mineur** (condensation). *Vérifié.*

- **Où** : `doc_tests_usp.tex:16947-16950`.
- La phrase « La raison qu'il résume est développée ici : … » répète le Cadre (16910-16913) et la rubrique Loi (16931-16933).
- **Texte proposé** : « La raison qu'il résume est développée au Cadre et à la rubrique~4. »

### C8 — `sec:graines` : « la portée du résultat d'Andrews (2000) ». **Mineur.** *Vérifié.*

- **Où** : `doc_tests_usp.tex:2658-2659`.
- Le `detail` actuel ne donne pas cette portée (C2).
- Si la variante de C2 qui garde Andrews est retenue, le texte du `.tex` redevient exact. Si la variante sans Andrews est retenue, remplacer par « ajoute le même constat de couverture ».

### Observations sans action dans K1

- **Cramér–von Mises** (`R/engine.R:6548`, citation à `doc_tests_usp.tex:10725`). « tres correlee a celle d'Anderson-Darling » est une affirmation que le `.tex` déclare non chiffrée par aucun script versionné (rubrique 6 de la fiche). Le défaut est antérieur à K1. Il fait l'objet de l'issue proposée n° 2.
- **ESD de Rosner sur résidus de Mack** (`R/engine.R:12181`). La parenthèse « (n >= 25) » accolée à « cadre i.i.d. normal » peut faire croire que l'effectif est en cause, alors qu'un triangle 8×8 fournit n = 27 ≥ 25 (`mw:m4ros`, Cadre). Le texte n'est pas faux et reste conforme à Q-D1-Fi-7. Texte facultatif, à joindre au patch si l'on en fait un : « son cadre (echantillon i.i.d. normal) ne couvre pas les residus de Mack, contraints par colonne ».

## Réponses aux questions

### 1. Paragraphe M6 « Sensibilité indicative »

**Fond conservé, sous la réserve C6.** *Vérifié.*
- Le rapport des quantiles à 5 % et 95 % du χ²(2) est cité : 5,9915 / 0,10259 = 58,40, d'où « 58 ».
- Sa condition est conservée : hypothèse auxiliaire d'erreurs gaussiennes, que le modèle de Mack ne fait pas, avec $2\hat\sigma^2_{J-3}/\sigma^2_{J-3} \sim \chi^2(2)$ exactement sous cette hypothèse.
- « continu en la dispersion de la colonne $J-3$ » et l'absence de seuil distinct de la tolérance $10^{-12}$ restent.
- Les valeurs du tableau sont remesurées à l'identique par `mw_sensibilite_sigma2_dernier()` sur `reserve2` : 199,494 ; 226,413 (+13,5 %) ; 271,305 (+36,0 %) ; 166,480 (−16,5 %).
- Les noms d'éléments cités existent (`racine_msep_regle`, `racine_msep_arguments`, `racine_msep_zero`).
- Le retrait de la mécanique d'impression (`RAPPORT_MAX_ECART_MW`, omissions du contrefactuel) relève de la grille de condensation. Il est consigné dans `III-M.md`.

### 2. Règle R8 réécrite et gabarit du `detail` en `sec:notations`

**Statut juste.** *Vérifié.*
- Les deux textes sont des conventions de restitution. R8 renvoie expressément à « section~\ref{sec:notations}, convention de restitution » (`doc_tests_usp.tex:8380`). Aucun des deux ne revendique de source.
- Le contenu de R8 est exact. Les trois mesures citées sont reproduites :
  - sur `premium`, mention de la borne 1 sur Spearman ratio contre volume, Mann–Kendall, Cox–Stuart, Durbin–Watson et suites ;
  - à volumes égaux à 100, mention des volumes constants sur Mann–Kendall, Cox–Stuart, Durbin–Watson et suites ;
  - dans la bande des volumes, « etendue relative des volumes = 4e-07 » sur Spearman ratio contre temps, Mann–Kendall, Cox–Stuart, Durbin–Watson et suites.
- Suggestion facultative pour le paragraphe du gabarit (`doc_tests_usp.tex:3561`) : ajouter « (convention de l'outil) » à la première phrase, comme ailleurs dans le document.

### 3. `mw:m4ros` : raison reportée en rubrique 5

**Convient sur le fond**, mais elle double le Cadre et la rubrique 4 : voir C7. La phrase courte du `detail` reste conforme à Q-D1-Fi-7 (« le cadre i.i.d. normal de Rosner (1983) ne couvre pas des résidus à contraintes exactes »).

### Q-A2 (audit de #514) — texte de Runsr, branche 1b dégénérée

**Acceptable, sans changement.** *Vérifié par mesure* (motif `MOTIF_MC_DISPERSION_NULLE` imposé à Runsr, $\hat\delta = 1$ puis $1 - 5\cdot10^{-7}$).
- Le `detail` est : « CONTROLE SANS OBJET ICI : pi_t constant, statistique identique a celle de la ligne homologue sur residus standardises, p exacte ecartee par le motif de degenerescence en tete. »
- « statistique identique » est exact sous la double condition : R ne dépend que des signes et des effectifs n1, n2, identiques par construction.
- La p exacte (0,7429) reste dans sa colonne et n'est pas retenue. C'est le sens d'« écartée » dans `sec:nature` (« sans p-value retenue, p-value exacte comprise », `doc_tests_usp.tex:6188-6190`).
- Dans la bande, l'absence de la mention M18 sur une ligne de la règle R15 est cohérente : la ligne homologue sur $z_t$ la porte, mesurée sur ce cas.

### Q-A3 — affirmations de simulation dans les `detail`

| Ligne | Texte | Statut |
|---|---|---|
| Kolmogorov–Smirnov contre N(0,1) | « tres conservatrice a T = 8 sur le jeu de controle, par simulation » | juste |
| G2, intervalle complet | « en simulation » | juste |
| G3, intervalle restreint | statut absent, Andrews hors portée | C2 |
| ESD de Rosner, méthode lognormale | statut absent | C3 |
| Shapiro-Wilk et Lilliefors sur résidus de Mack | portée perdue | C4 |
| Breusch-Pagan original | sur-généralisation antérieure | C5 |
| Cramér–von Mises | corrélation affirmée sans mesure | observation, issue proposée n° 2 |

### Q-a à Q-e (coder, #514, premier passage)

Leur texte exact n'est versé ni dans le dépôt, ni dans les messages de commit, ni dans la PR : seul leur objet figure dans le handoff de la PR #511. Je réponds aux trois objets connus.

- **Phrase de #409, exposant de variance, retirée du `detail`** : acceptable du point de vue actuariel. *Vérifié.* La lecture de l'outil (« sigma_j^2 et f_j communs (interpretation de l'outil) ») reste dans le champ `reference` de la ligne, inchangé entre `main` et la tête. La dérivation de l'effet de levier, qui en dépendait, a quitté le `detail` pour `mw:m2b`, qui garde « sous l'interprétation de l'outil ». Le contrôle de conformité de `regulatory`, prévu à la revue finale, reste à faire.
- **Retrait d'« exacte » pour Durbin–Watson** : justifié. *Vérifié.* Sur `main`, le `detail` disait « la loi exacte est obtenue par integration numerique d'Imhof » même à $\hat\pi_t$ variable, où aucune p exacte n'est attribuée : c'était une contradiction. Désormais :
  - l'exactitude est portée par la mention de régime (M20a ou M20b) et par le champ `loi` (« loi EXACTE par la methode d'Imhof (1961) », p exacte 0,5649 sur `premium`) ;
  - à $\hat\pi_t$ variable, la mention M17a dit que la loi exacte ne s'applique pas.
  La ligne Durbin–Watson sur résidus de Mack n'a pas de p exacte (nature Monte-Carlo).
- **Rosner sur résidus de Mack (Q-D1-Fi-7)** : conforme à la décision (diagnostic sans verdict, phrase fixe sur le cadre i.i.d. normal). Voir l'observation sur « (n >= 25) ».
- Q-d et Q-e : non identifiées (voir « Informations manquantes »).

### Écart signalé par docwriter (variance unitaire, bande)

**Défaut à corriger dans K1** (C1). C'est une régression introduite par #514, dans le périmètre de K1. La correction coûte peu : aucune référence n'est touchée, le `.tex` est déjà juste. La renvoyer à une issue laisserait sur `main` un texte faux connu.

## Correction recommandée dans K1, avant la revue finale de la règle 10

1. **`coder-approfondi`, commit `moteur:` de #514** : C1 à C5, plus la parenthèse « (n >= 25) » si le mainteneur le souhaite. Pour C2, la variante est à trancher par le mainteneur.
   - Patch chirurgical par `tests/patcher_reference.R`, motif `^tests\[\[[0-9]+\]\]\$detail$` : cinq références lognormales (G3, Rosner, Breusch-Pagan original) et `reserve2` (Shapiro-Wilk, Lilliefors).
   - Aucune valeur numérique, aucun σ_USP, aucun verdict ne change.
   - Contrôles : `test_detail_deux_phrases.R` et les assertions de texte exact touchées.
2. **`audit` léger** sur ce diff.
3. **`docwriter`, commit `docs:` minimal** : citation de `fiche:rosner-esd` (12266-12270), C6, C7, C8.
4. Validation de ce dernier diff par `actuary`.

## Issues proposées (à créer sur accord du mainteneur)

1. *Seulement si C1 à C5 ne sont pas corrigés dans K1.* **moteur: commentaires de #514, statut et portée de cinq textes** (sans objet : le mainteneur a décidé la correction dans K1).

2. **moteur: Cramér–von Mises, « tres correlee a celle d'Anderson-Darling » affirmé sans mesure**. Libellés `enhancement`, `needs-triage`. Corps :

   > *Rédigé par l'agent actuary (IA).*
   >
   > Le `detail` (`R/engine.R:6548`) affirme une corrélation forte que la fiche `fiche:cramer-von-mises` déclare non chiffrée par aucun script versionné. Deux options :
   > - (a) chiffrer la corrélation de $W^2$ et $A^2$ à T = 8 sous le modèle ajusté de J1 et J2, par un script versionné et un fichier de `docs/tableaux/` ;
   > - (b) réécrire le `detail` sans l'adjectif : « Distance de Cramer-von Mises a la loi normale, de meme construction que celle d'Anderson-Darling sans ponderation des queues, pour information. »
   >
   > Effet : patch du `detail` des cinq références lognormales pour (b) ; aucun résultat numérique ne change.

## Retour

- **Statut** : `revue requise` (C2 : choix de variante au mainteneur).
- **Résultat** : conforme avec réserves.
- **Preuves** *vérifiées* : concordance `--strict` à 0 écart ; texte faux de C1 mesuré par `run_engine()` ($\hat\delta = 0$, volumes dans la bande) ; mesures R8 reproduites ; tableau M6 remesuré ; rapport 58,40 du χ²(2) ; branche dégénérée de Runsr ; $N = 27$, $k = 6$ et $\bar r = -0{,}0151$ sur `reserve2` ; $p_{\min}$ de Smirnov restituée à $\hat\pi_t$ variable (2/70) ; longueurs des textes proposés, toutes ≤ 400 caractères. Sources : Q-D2-Fn-5 bis, Q-D1-Fi-7, issue #409, fiches du `.tex` aux lignes citées.
- *Hypothèses* : le sur-rejet de Breusch-Pagan original ne suit pas sous des queues légères (déduction de la formule, non mesurée) ; la lecture d'Andrews (2000) est celle du `.tex` et de Q-D2-Fn-5 bis, l'article n'a pas été relu.
- *Non vérifié* : conformité réglementaire des renvois B(2)(b), C(2)(b) et D(2)(b) (à `regulatory`) ; compilation du `.tex`.
- **Informations manquantes** : texte exact de Q-a à Q-e (`coder`) et de Q-A2 et Q-A3 (`audit`).
