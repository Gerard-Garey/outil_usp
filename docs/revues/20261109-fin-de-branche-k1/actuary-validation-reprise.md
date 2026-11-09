# Validation du diff postérieur à la validation de fin de branche K1 (`git diff 2f35c76..85ca922`, branche `claude/entrees-et-validation`, tête `85ca922`)

> *Rédigé par l'agent actuary (IA), en lecture seule, le 09/11/2026.*

## Verdict

**Conforme avec réserves mineures, non bloquantes.**

Les constats C1 à C8 de ma validation du `.tex` (`actuary-validation-tex.md`) sont repris fidèlement.
- C1, C4 et C5 reprennent mot pour mot les textes que j'avais proposés.
- C2 reprend la variante qui garde Andrews, retenue par le mainteneur.
- Dans les références, seuls des `detail` changent, et seulement sur les lignes visées.
- La concordance stricte ne relève aucun écart.

Il reste deux réserves, toutes deux mineures :
- **R1.** Pour C3, le texte que j'avais proposé (« en simulation ») omet la condition du constat C7.a, qui est établi sous i.i.d. normal. L'imprécision vient de ma proposition, pas de `coder`.
- **R2.** Derrière un point, la phrase fixe de #244 commence par une minuscule et n'a pas de point final. C'est un défaut de typographie, sans effet sur le fond.

Aucune des deux n'exige de reprise dans K1. Je propose une issue plus bas.

## Périmètre et méthode

Lu :
- le diff complet `2f35c76..85ca922` de `R/engine.R`, de `docs/latex/doc_tests_usp.tex` et des tests touchés (`test_detail_deux_phrases.R`, `test_defauts_connus.R`) ;
- mon rapport `actuary-validation-tex.md` et les « Questions pour actuary » 1 à 7 d'`audit-revue-finale.md` ;
- l'observation O2 de `regulatory-revue-finale.md` ;
- l'annexe XVII, section D(1) à D(3), dans la version consolidée versionnée. C'est une lecture du texte : D(1) à D(3) ne contiennent pas de formule.

Je n'ai pas revu `c117451` (CI) ni la partie mécanique de `324d315` (tests), qui relèvent d'`audit`.

Mesures exécutées sous `LC_ALL=C.UTF-8`, moteur chargé par `charger_moteur()` :
1. **Comparaison feuille par feuille des six références** `2f35c76` contre `85ca922`. Les seules feuilles qui diffèrent sont des `detail` : 3 par cas lognormal (Breusch-Pagan original, ESD de Rosner, IC restreint G3) et 2 pour `reserve2` (Shapiro-Wilk et Lilliefors sur résidus de Mack). Aucun nombre, aucun verdict et aucun σ_USP ne change. *Vérifié.*
2. **Batteries ciblées** : `test_detail_deux_phrases.R` passe 65/65 et `test_defauts_connus.R` 127/127. `concordance_doc_moteur.R --strict` : 0 écart, code 0. *Vérifié.*
3. **Textes et longueurs relus dans les références** : G3 fait 379 caractères, ESD de Rosner 317, Breusch-Pagan original 286, Shapiro-Wilk sur résidus de Mack 376, Lilliefors 302. *Vérifié.*
4. **`engine_lire_triangle()`** avec une cellule (i=4, j=4) sous la diagonale valant « NaN », « NA », « abc », « -5 » et « Inf » (texte) : « NaN », « NA » et « abc » sont refusés comme non numériques ; « -5 » et « Inf » sont acceptés avec l'avertissement de #491. *Vérifié.*
5. **Valeurs retirées du `detail`, recalculées depuis `res` par les fonctions nommées** (question 6 d'audit) : `test_rosner(res$ajustement$z, alpha = 0.10)` sur `premium` ; `mw_test_cellule_aberrante(res$ajustement, integer(0))` sur `reserve2` : stat 0,1032899 et t = −2,317818, identiques à la ligne de la référence, cellule (i=0, j=2, n_j=5) ; `mw_sensibilite_sigma2_dernier(res$ajustement)` : 199,494 / 226,413 / 199,494 / 271,305 / 166,480. *Vérifié.*

## Contrôle des constats C1 à C8

| Constat | Reprise | Statut |
|---|---|---|
| C1 (variance unitaire, bande due aux volumes) | Texte proposé repris. Test A4 : volumes 100 (1 ± 2·10⁻⁷) avec δ = 0, et contrôle négatif hors de la bande | Conforme, *vérifié* |
| C2 (G3, Andrews) | Variante qui garde Andrews, portée de Q-D2-Fn-5 bis. Cohérent avec `fiche:ic-bootstrap`, rubrique Loi, et avec `sec:graines`, qui redevient exact | Conforme, *vérifié* |
| C3 (ESD de Rosner, lognormale) | « en simulation » ajouté, citation de `fiche:rosner-esd` mise à jour | Conforme à ma proposition ; réserve R1 |
| C4 (Shapiro-Wilk et Lilliefors sur résidus de Mack) | Portée « a erreurs gaussiennes (simulation sous un plan) » rétablie | Conforme, *vérifié* |
| C5 (Breusch-Pagan original) | « sous des erreurs a queues plus lourdes que la normale » ; plus rien sur les queues légères, ce qui écarte l'hypothèse non mesurée signalée | Conforme, *vérifié* |
| C6 (`mw:m6sig` et index des fonctions) | Les deux conditions sont rétablies, conformes au code de `mw_sensibilite_sigma2_dernier()` | Conforme, *vérifié* |
| C7 (`mw:m4ros`, rubrique 5) | Renvoi « au Cadre et à la rubrique 4 » | Conforme |
| C8 (`sec:graines`) | Sans changement : exact avec la variante retenue pour C2 | Conforme, *vérifié* |

## Autres changements du `.tex`

- **Tableau des convergences.** « rendue par `mw_sensibilite_sigma2_dernier()` et non restituée par la ligne » : exact, `run_engine()` n'appelle pas cette fonction. **Conforme, *vérifié*.**
- **Parenthèse de `sec:controles`.** Constat 1 d'audit corrigé, sans effet sur le fond. **Conforme.**
- **Colonne vide intercalée.** D(1), D(2)(c) et D(3)(c) : paraphrase fidèle ; « la présomption est une lecture retenue par l'outil » est juste. **Conforme, *vérifié* sur le texte.**
- **Cellules sous la diagonale.** « renseignée d'une valeur numérique (NaN et Inf compris) », refus en amont d'une cellule non numérique : conforme à la mesure 4. Non-lecture fondée sur D(4)(c) et D(5) : cohérente avec la transcription des formules que le document porte déjà ; « seul l'avertissement est une convention de l'outil » est juste. **Conforme.** *Limite* : formules-images non relues en rendu graphique par actuary (contrôle fait par `regulatory`, `regulatory-controle-o2-o3.md`).

## Réserves

### R1. ESD de Rosner (méthode lognormale) : « en simulation » sans sa condition. **Mineur.** *Vérifié.*

- **Où** : `R/engine.R:6913` ; citation à `doc_tests_usp.tex:12279`.
- **Constat** : C7.a est mesuré sur 10⁶ échantillons i.i.d. N(0,1) de taille 8, avec k = 2 (`fiche:rosner-esd`) ; la fiche précise qu'« à π̂_t variable, C7.a ne s'applique pas ». « a niveau superieur a alpha a T = 8 en simulation » se lit comme un constat général.
- **Gravité** : diagnostic par décision (INFO, aucune p-value retenue) ; la fiche porte la portée exacte.
- **Correction proposée** : « … en simulation sous i.i.d. normal (valeurs critiques … » (+19 caractères, moins de 345 au pire).
- **Coût** : patch des `detail` des cinq références lognormales, assertion `detail_esd_attendu`, citation du `.tex`. À traiter par issue, sauf autre commit `moteur:` dans K1.

### R2. Typographie de la phrase de #244 derrière un point. **Mineur, forme.** *Vérifié.*

- `.engine_joindre()` joint par une espace après un point final ; `PHRASE_VERDICT_SENSIBLE_MC` commence par une minuscule et n'a pas de point final. Exemple (`premium_interieur`, ligne Grubbs) : « … sur ratios bruts". verdict sensible a l'alea de simulation (p a moins de 2 erreurs de Monte-Carlo du seuil) ».
- Aucun effet sur le fond. Correction dans la constante ou dans la jonction : issue proposée.

## Réponses aux questions ouvertes de `coder`

1. **C2 : 379 caractères, et non 378.** Texte identique à la proposition ; l'écart vient du décompte d'actuary. Sans effet.
2. **C3 : « en simulation » sans « sous i.i.d. normal ».** Pas tout à fait suffisant : voir R1 ; non bloquant pour K1.
3. **« T > 9 » en dur dans le `.tex`.** À laisser : citation littérale du texte produit tant que `T_MAX_ENUM_PERMUTATION = 9`, la constante étant nommée deux lignes plus haut ; `MENTION_EDGEWORTH` garde à bon droit son « T > 9 » (borne externe, prho.c).

## Réponses aux « Questions pour actuary » d'audit (revue finale, 1 à 7)

1. **`FORMAT_MENTION_BANDE`, « un écart de cet ordre ».** Assez précis : le gabarit imprime juste avant la grandeur en cause, nommée et chiffrée. Que l'écart à la loi exacte soit du premier ordre reste une **hypothèse** de continuité, qualitative, antérieure à K1.
2. **`DETAIL_P_FAMILLE` et `DETAIL_P_GLOBALE`, « au sens faible » retiré.** Retrait préférable ; la phrase restante est exacte : une p minP faible rejette l'hypothèse intersection sans désigner laquelle ; avec une p plug-in à T = 8, aucun contrôle du taux d'erreur n'est garanti à distance finie.
3. **TOST sous R14.** Exact : la p du TOST est au moins 1 − F_t(Δ/se), égalité en a = 0 ; la preuve positive par un OK du TOST est la logique de Schuirmann (1987).
4. **Pitman et Koenker.** Juste et prudent (non-échangeabilité sous dispersion liée à x ; tendance commune). « Seul test de H2 a verdict » vérifié sur `premium` et `premium_interieur`.
5. **`PHRASE_MW_ROSNER_DIAGNOSTIC`.** Pas faux, conforme à Q-D1-Fi-7 ; la parenthèse « (n >= 25) » peut faire croire que l'effectif est en cause (n = 27 sur un 8×8). Texte facultatif joint à l'issue proposée.
6. **Valeurs retirées du `detail`.** Toutes recalculables depuis `res` par la fonction nommée de la ligne (convention du gabarit) : `plots_data$influence` ; `test_rosner()` ; `mw_test_cellule_aberrante()` (reproduit stat et t au bit près) ; `mw_sensibilite_sigma2_dernier()` ; `metadata$permutation_pente$p_bilateral`. *Limite* : sur un triangle à colonnes dégénérées, la cellule du minimum demande l'ensemble figé de `mw_bootstrap()` ; voie de recalcul complète à désigner par la fiche (non vérifié).
7. **Typographie de M11 derrière un point.** Acceptable pour K1 ; défaut réel (R2).

## Issue proposée (à créer seulement sur accord du mainteneur)

**Titre** : « moteur: retouches de forme et de portée de quatre textes du `detail` (Rosner lognormale et Merz-Wüthrich, phrase de #244) » — libellés `enhancement`, `needs-triage`.

1. ESD de Rosner, méthode lognormale : « en simulation » → « en simulation sous i.i.d. normal ».
2. `PHRASE_MW_ROSNER_DIAGNOSTIC` : « son cadre i.i.d. normal (n >= 25) » → « son cadre (echantillon i.i.d. normal) … contraints par colonne » ; à regrouper avec l'alpha imprimé en `%.2f` (audit).
3. `PHRASE_VERDICT_SENSIBLE_MC` : majuscule et point final, ou correction de la jonction `.engine_joindre()`.

Critères : seules des feuilles `$tests[[*]]$detail` changent ; deux phrases et 400 caractères au plus ; concordance `--strict` à 0 écart.

## Retour

- **Statut** : complet. **Résultat** : conforme avec réserves mineures (R1, R2), non bloquantes.
- **Décisions non résolues** : R1 dans K1 ou par issue (mainteneur) ; création de l'issue proposée (mainteneur) ; forme de la correction de R2.
- **Critères déclenchés** : aucun changement de résultat numérique, de verdict ou de σ_USP ; aucun désaccord avec `audit`, `regulatory` ni un ADR.
