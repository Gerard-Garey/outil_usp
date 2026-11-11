# K4, étape 1 : inventaire des messages de #527

Base : `claude/textes-du-moteur`, tête `d6a4d98`, `R/engine.R` de `12872c3`. Lecture seule. `LC_ALL=C.UTF-8`. Chaque message ci-dessous a été **déclenché par un appel R** sauf mention « *hypothèse (lecture)* ». Scripts dans `docs/revues/20261111-avis-amont-k4/scripts/` (copies versées par la session ; les `dump_*.rds`, intermédiaires, ne sont pas versés) : `trig_ln.R` (validation lognormale, avertissements), `trig_mw.R` (triangle), `trig_lec.R` (lecteurs), `trig_us.R` (usage), `trig_post.R` (refus après ajustement, défaut de calcul), `trig_misc.R` (forme 2, réinitialisation de T), `len.R` (longueurs). Le préambule `pre.R` charge le moteur par `source("R/charger_moteur.R"); charger_moteur()` (ADR 0016).

## 1. Ce qui est restitué, et où (lecture de `app.R`, *vérifié* par lecture des lignes citées)

L'application restitue du texte du moteur sur **cinq surfaces** ; aucune ne le réécrit (`app.R` : `refuser()` l. 815-820, `conserver()` l. 828-885, `validation_live` l. 1091-1119, `statut_ui()` l. 186-195, import l. 1160-1250, démarrage l. 258-300).

| Surface | Source du texte | Code |
|---|---|---|
| **Bandeau de refus** (`bandeau_refus`, titre + liste des motifs) | `v$erreurs` du contrôle préalable au clic (`TITRE_NON_LANCE`) ; `res$validation$erreurs` d'un `run_engine()` en `ok = FALSE` (`TITRE_REFUSE`, ou `TITRE_DEFAUT` si `erreur_r`) ; `conditionMessage()` d'une erreur levée par `run_engine()` (`TITRE_ERREUR`, **et** aussi en notification, l. 837-838) | `app.R:1263-1320`, `828-885`, `1337-1345` |
| **Aperçu** `validation_live` (« Saisie non exploitable : » + avertissements) | `engine_valider_serie_retenue()$validation` (lognormale), `mw_valider_triangle()` (triangle) | `app.R:1091-1119` |
| **Statut d'import / de démarrage** (onglet Données) | `engine_lire_donnees_csv()$erreurs`, `engine_lire_triangle()$erreurs`, puis `engine_valider_donnees()$erreurs` ; avertissements de lecture | `app.R:258-300`, `1157-1250` |
| **Notification de réinitialisation** | `engine_valider_profondeur(T, n = Inf, T_min = 1)` | `app.R:728, 1141-1150` |
| **Avertissements du calcul affiché** | `res$validation$avertissements` | `app.R:1347-1372` |
| texte restitué avant le clic | `engine_motif_b_alpha(input$B, input$alpha)` sous le champ alpha (`avert_b_alpha`) | `app.R:1377-1379` |

Hors de ces surfaces, le message R d'une erreur n'est **jamais** montré : `lire_tableau()` remplace toute erreur de lecture par un texte fixe (`MESSAGE_ILLISIBLE`, `app.R:202-250`, le message R va au journal) ; un défaut de calcul intercepté montre un motif neutre (`.engine_calcul_protege()`), le message R va au journal (`app.R:857-865`).

Les textes de l'application elle-même (`TITRE_*`, `AIDE_*`, `MESSAGE_ILLISIBLE`, `refus_dimension_series()`, `refus_dimension_triangle()`, « Profondeur T : champ vide. », `message_reinitialisation()`) ne sont **pas** des textes du moteur et sont hors périmètre de K4 (`app.R` hors périmètre, plan).

## 2. Inventaire : messages dans le périmètre (45)

Colonnes : **Réf.** = présent dans l'un des six `tests/reference/*.rds` (*vérifié* : pour chaque référence, `x$validation$erreurs` est vide, 0 erreur ; seuls deux avertissements y figurent, § 3). **Reproche** : l'issue ne reproche qu'une chose, le « jargon R » ; ma colonne liste les éléments de jargon relevés dans le texte (observation, jugement à `actuary`). « Longueur » en caractères quand elle dépasse 400.

Légende nature : `validation` = `ok = FALSE` avec `validation$erreurs` (aucune erreur R levée) ; `stop()` = erreur d'usage levée (`call. = FALSE`, texte restitué par `conditionMessage()`).

### G1 — Lognormale : validation des données (`engine_valider_donnees()`, `engine_valider_serie_retenue()`)

| ID | Source | Texte exact actuel | Entrée déclenchante (*vérifié*) | Nature | Réf. | Reproche |
|---|---|---|---|---|---|---|
| LN-01 | `engine.R:587` (`.nature_erreurs()`) | « Nature des donnees non declaree : pour la methode du risque de primes, declarer des donnees "brutes" (non ajustees de la reassurance, annexe XVII, B(2)(c) : sigma brut de l'annexe) ou "nettes" (ajustees de la reassurance, B(2)(d) : NP standard x sigma brut) ; aucune valeur par defaut. » (285) | `engine_valider_serie_retenue(xt, yt, T = 8, methode = "premium", nature_donnees = NULL, segment = 1L)` ; dans l'app : méthode « prime », radio non cochée (`app.R:582-584`) | validation | non | aucun jargon R ; texte long |
| LN-02 | `engine.R:8141` | « Valeurs manquantes : le calibrage exige des series completes (art. 19). » | `xt` avec un `NA` (cellule vide de la grille, `lire_saisie()` rend `NA_real_`) | validation | non | aucun |
| LN-03 | `engine.R:8145` | « Valeurs infinies : xt et yt doivent etre des nombres finis. » | atteint **à l'import / au démarrage seulement** : `engine_lire_donnees_csv()` accepte une cellule « Inf » (`C5d`, `ok = TRUE`), puis `engine_valider_donnees()` (`app.R:1239`) refuse | validation | non | « xt », « yt » (noms de variables R) |
| LN-04 | `engine.R:8147` | « Toutes les valeurs de xt doivent etre strictement positives. » | `xt[3] = 0` | validation | non | « xt » |
| LN-05 | `engine.R:8149` | « Toutes les valeurs de yt doivent etre strictement positives (loi lognormale). » | `yt[3] = -1` | validation | non | « yt » |
| LN-06 | `engine.R:8166` | « Valeur de xt hors du domaine numerique [1e-50 ; 1e+50] : xt = 1e-108 (< 1e-50, borne inferieure) ; 8 valeurs hors du domaine. sigma_USP et les tests sont invariants par un changement d'unite commun a xt et yt (et a delta_equiv s'il est fourni) : exprimer les montants dans une unite qui les ramene dans le domaine. » (314 pour xt, 331 pour yt, deux motifs ; `yt = 7.0000000000000007e-109` cité à 17 chiffres) | `xt` et `yt` multipliés par 1e-110 | validation | non | « xt », « yt », « delta_equiv », valeur citée à 17 chiffres, `1e+50` en notation R |
| LN-07 | `engine.R:8174` (donnees) et `8300` (profondeur) | « Annexe XVII, B/C(2)(b) : au moins 5 annees consecutives (T = 4). » | série de 4 années, `T = 4` ; **le texte sort deux fois** (une par site de code) : sortie `trig_ln.R` L9, deux lignes `ERR:` identiques | validation | non | aucun jargon ; **doublon** (voir § 6) |
| LN-08 | `engine.R:8186` | « Marge Delta du test d'equivalence (delta_equiv = NA_real_) : un nombre fini strictement positif est attendu. » | `delta_equiv = NA_real_` (champ « Marge Delta » vide, case « fixée a priori » cochée) | validation | non | « delta_equiv », « NA_real_ » |
| LN-09 | `engine.R:8197` | « Marge Delta du test d'equivalence (delta_equiv = 500) superieure ou egale a la perte moyenne (96.25) : l'equivalence ne se lirait plus comme une proportionnalite ; 0 < Delta < moyenne(yt) est attendu. » | `delta_equiv = 500`, perte moyenne 96,25 | validation | non | « delta_equiv », « yt » |
| LN-10 | `engine.R:8202` | « Marge theta du test d'equivalence (theta_equiv = NA_real_) : un nombre fini, 0 < theta < 1 (fraction de la perte moyenne), est attendu. » | `theta_equiv = NA_real_` (champ vide) ou `1.5` | validation | non | « theta_equiv », « NA_real_ » |

### G1b — Profondeur T (`engine_valider_profondeur()`)

| ID | Source | Texte exact actuel | Entrée | Nature | Réf. | Reproche |
|---|---|---|---|---|---|---|
| PR-01 | `engine.R:8293` | « Profondeur T = NA : un nombre entier d'annees est attendu (annexe XVII, B/C(2)(b)) ; la serie n'est pas tronquee. » (sans le renvoi à l'annexe si `T_min = 1`) | `T = NA` (champ T vide) ou `5.5` | validation | non | « NA » |
| PR-02 | `engine.R:8296` | « Profondeur T = 12 superieure au nombre d'annees fournies (8). » | `T = 12`, 8 années | validation | non | aucun |
| PR-03 | `engine.R:8302` | « Profondeur T = 0 : T >= 1 attendu. » | **réinitialisation** (`T_min = 1`), `T = 0` ou `-3` ; surface : notification | validation | non | aucun jargon |

(Le motif « T < 5 » à `T_min = 5` est LN-07, même texte, autre site de code, `engine.R:8300`.)

### G2 — Refus après ajustement et défaut de calcul

| ID | Source | Texte exact actuel | Entrée | Nature | Réf. | Reproche |
|---|---|---|---|---|---|---|
| AJ-01 | `engine.R:1930` (`usp_valider_ajustement()`, bord bas) | « Maximum de vraisemblance non atteint (annexe XVII, B(6)) : gamma estime sur la borne basse du domaine de recherche [-12 ; 3] (BORNES_GAMMA, bornes de l'outil, non reglementaires) ; les valeurs delta et gamma qui minimisent le montant de B(6), dont depend le parametre de B(4), ne sont pas determinees dans ce domaine. Cause : ratios y_t/x_t egaux ou quasi egaux ; s'ils sont exactement egaux, ce minimum n'existe pas. L'outil ne calcule pas de parametre sur ces donnees (article 220, paragraphe 1, point a)), qui ne permettent d'etablir ni la distribution log-normale ni l'adequation de l'estimation de la vraisemblance maximum (B(2)(g), iii et iv ; article 219, paragraphe 1, point d)). Verifier que y_t est observe (B(1)(a)) et non deduit de x_t par un coefficient fixe. » (772 ; 837 en `reserve1`, qui ajoute « La methode du risque de reserve no 2 reste ouverte (meme point). ») | `run_engine(xt = x, yt = 0.8 * x, methode = "premium", segment = 1L, nature_donnees = "nettes", B = 99)` | validation | non | « BORNES_GAMMA », « gamma », « delta », « y_t/x_t » ; texte de 772-837 caractères |
| AJ-02 | `engine.R:1930` (bord haut) | même gabarit, « borne haute ... Cause : dispersion des ratios y_t/x_t extreme ; le minimum, s'il existe, est au-dela de la borne. ... Verifier les unites, la correspondance des annees et les valeurs aberrantes (C(1) et C(2)(a)). » (845, `reserve1`) | `yt = c(0.1, 500, 0.2, 800, 0.05, 900, 0.3, 700)`, `reserve1` | validation | non | idem |
| AJ-03 | `engine.R:1908` (forme 2, #227) | « Maximum de vraisemblance non etabli (annexe XVII, B(6)) : parmi les demarrages qui atteignent l'objectif minimal a la tolerance de l'outil, au moins un a gamma sur une borne du domaine de recherche [-12 ; 3] (BORNES_GAMMA, ...) et aucun ne satisfait la condition du premier ordre (KKT) ; le demarrage retenu, de gamma interieur, n'est pas un point stationnaire certifie, [...] » (1 181 en `premium`) | **fit fictif** : `usp_valider_ajustement(list(gamma = -11.5, kkt_au_moins_un = FALSE, gamma_bord_au_moins_un = TRUE), "premium")` (forme 2 exige des démarrages multiples : non produite par une série concrète, *hypothèse (lecture)* pour l'entrée réelle ; fixture dans `tests/unitaires/test_controles_entree.R:3294-3331`) | validation | non | « BORNES_GAMMA », « KKT », « demarrages », « gamma » ; 1 181 caractères |
| AJ-04 | `engine.R:13382` (`.engine_calcul_protege()`) | « Defaut de calcul intercepte (erreur R dans usp_controle_donnees()) : aucun resultat n'est produit ; diagnostic dans validation$erreur_r. » | `stop("boom")` injecté **en mémoire** dans `usp_controle_donnees` (`trig_post.R` D1, objet du moteur restauré) ; chemin réel : toute erreur R après validation | validation | non | « erreur R », « usp_controle_donnees() » (nom de fonction variable), « validation$erreur_r » |

### G3 — Merz-Wüthrich : triangle et refus après ajustement

| ID | Source | Texte exact actuel | Entrée | Nature | Réf. | Reproche |
|---|---|---|---|---|---|---|
| MW-01 | `engine.R:9148` | « D(2)(b) : au moins 5 annees d'accident consecutives (4 fournies). » | grille de 4 lignes (`trig_mw.R` M2/M3) | validation | non | aucun |
| MW-02 | `engine.R:9151` | « D(2)(c) : au moins 5 annees de developpement pour la premiere annee d'accident (4 fournies). » | idem ; sort avec MW-01 | validation | non | aucun |
| MW-03 | `engine.R:9154` | « D(2)(e) : le nombre d'annees d'accident ne peut etre inferieur au nombre d'annees de developpement. » | **import** d'un triangle 6 × 8 (`engine_lire_triangle()`) ; la grille de l'application est carrée (`lire_triangle()`, `app.R:1021-1028`) | validation | non | aucun |
| MW-04 | `engine.R:9156` | « Triangle non carre (I = 7, J = 5) : cas non couvert par les formules des paragraphes 4 et 5 (voir la note d'implementation). » | **import** d'un triangle 8 × 6 | validation | non | « I », « J », renvoi à une « note d'implementation » inaccessible à l'utilisateur |
| MW-05 | `engine.R:9169` | « Cellule observee manquante en (i=0, j=2). » | cellule vide dans la partie observée | validation | non | « (i=0, j=2) » |
| MW-06 | `engine.R:9171` | « Valeur non finie en (i=0, j=2) : Inf. » | atteint à l'**import** (cellule « Inf », `trig_lec.R` T7) ; `NaN` / `Inf` ne sortent pas de la grille | validation | non | « Inf », « NaN » |
| MW-07 | `engine.R:9173` | « Cumul non strictement positif en (i=0, j=2). » | cellule -5 | validation | non | « (i=0, j=2) » |
| MW-08 | `engine.R:9194` | « Cumul hors du domaine numerique [1e-50 ; 1e+50] en (i=0, j=2) : 1e+120 (> 1e+50, borne superieure). sigma_USP et les tests sont invariants par un changement d'unite commun a toutes les cellules du triangle : exprimer les cumuls dans une unite qui les ramene dans le domaine. » | cellule 1e120 | validation | non | notation `1e+50` |
| MW-09 | `engine.R:9934` (`mw_valider_ajustement()`) | « Reserve chain-ladder totale negative ou nulle (R = 0) : sigma(res,s,USP) est defini par D(4) comme racine(MSEP) / R et n'a pas de sens pour R <= 0 ; la methode du risque de reserve no 2 n'est pas applicable a ce triangle. » | triangle à cumuls constants par ligne (tous les facteurs = 1), `reserve2` (`trig_mw.R` MP1) | validation | non | « R » |
| MW-10 | `engine.R:9968` | « Triangle totalement degenere : pour chaque annee de developpement j = 0..J-2, les facteurs individuels C(i,j+1)/C(i,j) sont identiques (a la tolerance relative 1e-12 de l'outil pres : [...]) [...] L'outil n'applique donc pas a ce triangle la methode du risque de reserve no 2 (article 220, paragraphe 1, point b)). Verifier qu'il s'agit de paiements cumules observes (D(1)) et non de montants projetes ou lisses. » (1 321) | triangle à facteurs identiques (`1000 * 1.5^j`), `reserve2` (`trig_mw.R` MP2) | validation | non | « sigma2_j », « MSEP », « j = 0..J-2 », 1 321 caractères |

### G4 — Lecteurs (`engine_lire_donnees_csv()`, `engine_lire_triangle()`, `.retirer_lignes_colonnes_vides()`)

Surface : statut d'import / de démarrage (onglet Données), pas le bandeau.

| ID | Source | Texte exact actuel | Entrée (`trig_lec.R`) | Nature | Réf. | Reproche |
|---|---|---|---|---|---|---|
| LE-01 | `engine.R:7656, 7680, 7744, 7755` | « Fichier vide ou illisible comme tableau. » | tableau sans ligne | validation | non | aucun |
| LE-02 | `engine.R:7669` | « Colonne(s) manquante(s) : yt. Colonnes attendues : t, xt, yt (format d'export de l'application). Colonnes presentes : t, xt, y. » | en-tête `y` au lieu de `yt` | validation | non | « xt », « yt » (noms de colonnes du fichier d'export, donc légitimes) |
| LE-03 | `engine.R:7600` | « Ligne(s) vide(s) en tete, sous l'en-tete (ligne(s) de donnees 1) : une ligne vide est refusee comme annee manquante presumee ; l'annexe XVII, B(2)(b) et C(2)(b), exige des annees consecutives. Renseigner l'annee manquante ou retirer la ligne vide. » (variante triangle : « ... en tete dans le triangle ... annee d'accident ... D(2)(b) ... ») | première ligne de données vide | validation | non | aucun |
| LE-04 | `engine.R:7605` | « Ligne(s) vide(s) intercalee(s) (ligne(s) de donnees 4) : une ligne vide est refusee comme annee manquante presumee ; ... » (mêmes variantes) | ligne 4 vide | validation | non | aucun |
| LE-05 | `engine.R:7623` | « Colonne(s) vide(s) intercalee(s) dans le triangle (colonne(s) 5) : annee de developpement manquante presumee ; la renseigner ou retirer la colonne vide. » | triangle, colonne vide au milieu | validation | non | aucun |
| LE-06 | `engine.R:7627` | « Colonne(s) vide(s) portant un en-tete dans le triangle (colonne(s) 9 : 7) : annee de developpement sans valeur ; la renseigner ou retirer la colonne. » | triangle, dernière colonne vidée avec en-tête | validation | non | « colonne(s) 9 : 7 » (position du fichier : numéro de colonne et en-tête séparés par deux-points) |
| LE-07 | `engine.R:7694` | « Certaines valeurs de xt ou yt ne sont pas numeriques (xt : ligne(s) de donnees 3). » (+ « Une cellule "NA" est lue comme du texte, non comme une valeur manquante : renseigner la valeur. » si la cellule vaut « NA ») | cellule « abc » / « NA » / vide | validation | non | « xt », « yt », « NA » |
| LE-08 | `engine.R:7705` | « Colonne t incomplete ou non numerique (ligne(s) de donnees 3) : chaque ligne doit porter son annee. » | cellule de `t` vide | validation | non | aucun |
| LE-09 | `engine.R:7709` | « Colonne t : les annees doivent etre des entiers finis. » | `t = 2016.5` | validation | non | aucun |
| LE-10 | `engine.R:7711` | « Colonne t : annee(s) dupliquee(s) (2015). » | `t` dupliqué | validation | non | aucun |
| LE-11 | `engine.R:7714` | « Colonne t : annees non consecutives (2015, 2016, 2018, ..., 2030) ; l'annexe XVII, B(2)(b) et C(2)(b), exige des annees consecutives. » | `t = 2030` | validation | non | aucun |
| LE-12 | `engine.R:7759` | « Aucune colonne d'annee de developpement. » | triangle réduit à la colonne `i` | validation | non | aucun |
| LE-13 | `engine.R:7777` | « Cellule(s) non numerique(s) en (i=1, j=3). » (+ « Une cellule "NA" est lue comme du texte : renseigner la valeur, ou laisser vide une cellule non observee. ») | cellule « xyz » / « NA » | validation | non | « (i=1, j=3) », « NA » |

### G5 — Usage : `stop()` de `.engine_verifier_usage()`, restitués au bandeau (`TITRE_ERREUR`) et en notification

Atteignables par saisie libre dans le panneau de droite : `numericInput` rend `NA` si le champ est vidé, et ne borne pas côté serveur (*hypothèse (lecture)*, comportement usuel de Shiny, non testé ; `app.R:1376` : « au clic, run_engine() leve la meme erreur d'usage »).

| ID | Source | Texte exact actuel (sortie de `trig_us.R`) | Entrée | Nature | Réf. | Reproche |
|---|---|---|---|---|---|---|
| US-01 | `engine.R:13277` | « B = NA_real_ : un nombre scalaire fini entier de replications, B >= B_MIN_USAGE = 99, sans attribut, est attendu. » | `B = NA_real_` (champ B vidé) ou `50` | `stop()` | non | « NA_real_ », « scalaire », « B_MIN_USAGE », « sans attribut » |
| US-02 | `engine.R:13281` | « seed = NA_real_ : un nombre scalaire fini entier, \|seed\| <= 2147483647, sans attribut, est attendu (NULL refuse : calcul non reproductible). » | champ graine vidé | `stop()` | non | « NA_real_ », « scalaire », « sans attribut », « NULL », 2147483647 |
| US-03 | `engine.R:13291` | « alpha = NA_real_ : un nombre scalaire fini, sans attribut, 0 < alpha < SEUIL_ECHEC_SENS_REJETER = 0.3, est attendu ; au-dela, la zone ALERTE des tests en sens rejeter disparait et le verdict ne suit plus la regle documentee. » | alpha vidé ou `0.5` | `stop()` | non | « NA_real_ », « SEUIL_ECHEC_SENS_REJETER », « sans attribut » ; contradiction apparente avec le champ de l'application (`max = 0.20`) |
| US-04 | `engine.R:13123` (`engine_motif_b_alpha()`, levée l. 13299) | « B = 99 et alpha = 0.01 : B + 1 > 4/alpha est requis, soit B >= 400 a ce seuil (en plus de B >= B_MIN_USAGE = 99). Le plancher bilateral de la p-value Monte-Carlo, 2/(B+1) = 0.02, n'est pas inferieur a alpha/2 = 0.005 : l'ECHEC des tests dont la seule p-value est Monte-Carlo serait inatteignable (regle des verdicts d'engine_registre_tests()). » (343) | `B = 99, alpha = 0.01` ; **même texte avant le clic** (`avert_b_alpha`, `app.R:1377`) : `identical(engine_motif_b_alpha(99, 0.01), <message du stop>)` = `TRUE` (`trig_misc.R`) | `stop()` + texte d'interface | non | « B_MIN_USAGE », « engine_registre_tests() » |
| US-05 | `engine.R:13301` | « sigma_standard = NA_real_ : NULL ou un nombre scalaire fini, sans attribut, sigma_standard > 0, est attendu. » | case « Saisir sigma standard manuellement » cochée, champ vidé ; ou `0` | `stop()` | non | « NA_real_ », « sigma_standard », « NULL », « scalaire », « sans attribut » |

### Compte

| Groupe | Messages |
|---|---|
| G1 lognormale : validation des données (LN-01 à LN-10) | 10 |
| G1b profondeur (PR-01 à PR-03 ; LN-07 partage le texte de la borne) | 3 |
| G2 refus après ajustement et défaut de calcul (AJ-01 à AJ-04) | 4 |
| G3 Merz-Wüthrich (MW-01 à MW-10) | 10 |
| G4 lecteurs (LE-01 à LE-13) | 13 |
| G5 usage (US-01 à US-05) | 5 |
| **Total : erreurs et refus dans le périmètre** | **45** |

Comptage au texte distinct : un gabarit à variantes (série / triangle, `T_min` 5 / 1, bord bas / haut, suffixe « NA ») compte pour un message, sauf AJ-01 et AJ-02 (bord bas et bord haut) comptés séparément.

## 3. Avertissements de validation (14 de plus, à trancher : dans le périmètre ou non)

Ils ne sont pas des « erreurs » mais font partie du champ `validation` que #527 liste (« chaînes de `validation` »). Ils portent les **seules chaînes de #527 présentes dans les références** : « credibilite partielle » et « lois asymptotiques peu fiables / estimateurs de variance tres bruites » (2 par référence, 12 occurrences) ; la fiche de K4 prévoit un patch seulement si une référence porte une chaîne de `validation` : c'est le cas **si ces deux avertissements sont reformulés**.

| ID | Source | Texte (début) | Déclencheur (*vérifié*, `trig_ln.R`, `trig_mw.R`) | Réf. | Jargon |
|---|---|---|---|---|---|
| AV-01 | `engine.R:8215` | « Ratio y/x hors de la plage plausible [0.1 ; 5[ : verifier les unites. » | `yt * 1000` | non | « y/x » |
| AV-02 | `engine.R:8218` | « Amplitude des volumes >= 10 : rupture de perimetre possible. » | volumes 10 à 110 | non | aucun |
| AV-03 | `engine.R:8220` | « Couples (xt, yt) dupliques detectes. » | couples répétés | non | « xt, yt » |
| AV-04 | `engine.R:8229` | « Volumes x_t constants a la tolerance relative TOL_DELTA_BORD = 1e-06 pres (etendue relative = 0) : delta non identifie [...] » (418) | `xt` constant | non | « TOL_DELTA_BORD », « delta », liste de tests |
| AV-05 | `engine.R:8241` | « Pertes y_t constantes a la tolerance relative TOL_DELTA_BORD = 1e-06 pres (etendue relative = 0) : regression de y sur x sans objet [...] » | `yt` constant | non | « TOL_DELTA_BORD » |
| AV-06 | `engine.R:8252` | « T = 8 : credibilite partielle, c = 59% (bareme long du segment II-1 (annexe XVII, G(1)) ; pleine a partir de T = 15). » | T < pleine crédibilité | **oui** (5 références lognormales : 1 chacune) | aucun |
| AV-07 | `engine.R:8260` | « T = 8 : lois asymptotiques peu fiables. Privilegier les p-values exactes ou Monte-Carlo. Une p-value elevee ne demontre pas la validite de l'hypothese : elle ne permet pas de la rejeter. » | T < 10 ; **aussi `validation$repere_profondeur`** | **oui** (5 : 1 chacune, dans `avertissements` et dans `repere_profondeur`) | aucun |
| AV-08 | `engine.R:9114` (`.mw_avert_sous_diagonale()`) | « Cellule(s) renseignee(s) sous la diagonale (i + j > I) en (i=7, j=7) : hors de la partie observee du triangle [...] » | cellule sous la diagonale (aussi `avertissements_lecture` à l'import) | non | « i + j > I » |
| AV-09 | `engine.R:9343` | « Annee d'accident 0 : cumul decroissant (recouvrement ou boni). » | cumul qui décroît | non | aucun |
| AV-10 | `engine.R:9352` | « I + 1 = 8 annees d'accident (duree, G(3)(c)) : credibilite partielle, c = 59% (bareme long du segment II-1 ... ; pleine a partir de I + 1 = 15). » | I + 1 < pleine crédibilité | **oui** (`reserve2`) | « I + 1 » |
| AV-11 | `engine.R:9360` | « I + 1 = 8 annees d'accident : estimateurs de variance tres bruites en fin de triangle. Une p-value elevee ne demontre pas la validite de l'hypothese : elle ne permet pas de la rejeter. » | I + 1 < 10 ; aussi `repere_profondeur` | **oui** (`reserve2`) | « I + 1 » |
| AV-12 | `engine.R:10042` | « Colonne(s) de developpement ..., a facteurs individuels egaux a f_j a la tolerance relative 1e-12 [...] la MSEP ne porte donc AUCUNE variance sur la derniere annee de developpement. [...] » (extrapolation de sigma2_(J-1)) | *hypothèse (lecture)* : non déclenché (tentative `len.R` : aucun avertissement rendu sur mon triangle ; fixtures dans `tests/unitaires/test_merz_wuthrich*.R`) | non | « sigma2_(J-1) », « MSEP », formule |
| AV-13 | `engine.R:10066` | « ... a facteurs individuels egaux a f_j [...] sont exclus des residus de Mack ; ... » (colonnes exclues) | *hypothèse (lecture)* : non déclenché | non | « f_j », « M4 », noms de lignes |
| AV-14 | `engine.R:10099` | « Reserve chain-ladder positive mais faible devant son incertitude : sigma estime = racine(MSEP) / R = ... >= 1 (R = ...). Le parametre est defini (annexe XVII, D(4)) mais hors de toute plage ou le melange par credibilite a un sens [...] ; le calcul n'est pas refuse. » | *hypothèse (lecture)* : non déclenché (sigma estimé >= 1) | non | « sigma », « MSEP », « R » |

Si les avertissements entrent : 45 + 14 = **59**. Si seuls AV-06, AV-07, AV-10, AV-11 sont touchés (les quatre présents dans les références) : 49.

## 4. Hors périmètre : gardes internes jamais atteintes depuis l'application

Méthode : fonction par fonction, lecture de qui l'appelle (`grep` dans `app.R` et `R/display_helpers.R`) et de ce que l'application passe (`app.R:1277-1281`, `1313-1320`). `R/engine.R` compte **116 lignes `stop(`** hors lignes de commentaire (`awk`, `stops.tsv`) ; **5 sont dans le périmètre** (US-01 à US-05) ; 111 sont hors périmètre, par groupes. Le décompte par fonction est dans `stops.tsv` (même dossier).

| Groupe | Sites (nombre de `stop(`) | Motif | Preuve |
|---|---|---|---|
| **A. Arguments d'usage que l'application passe toujours valides ou ne passe pas** | `run_engine()` `choix_exact` methode / annexe (1) ; `.engine_verifier_usage()` « arguments sans effet », `plus_recent_en_dernier`, `bareme`, « Fournir soit sigma_standard, soit segment » (4) ; `.run_engine_mw()` triangle NULL et même message (2) ; `.segment_verifie()`, `.segment_ligne()`, `.annexe_verifiee()`, `.engine_credibilite_appliquee()` (4) ; `usp_credibilite()` (2) ; `usp_parametre_standard()` (2) | `methode` et `annexe` viennent de `selectInput` / `radioButtons` à choix fermés (`app.R:566, 571`) ; l'application n'envoie ni `bareme`, ni `plus_recent_en_dernier` ; en `reserve2` elle ne passe que `triangle` ; `segment` est une valeur du `selectInput("segment")` (`app.R:909`) ; le triangle est toujours fourni (`lire_triangle()`) ; `usp_credibilite()` et `usp_parametre_standard()` sont appelées après validation. Appels directs : messages déclenchés dans `trig_us.R` (U1, U1b, U2, U5, UM, UA, U9 à U10b, UR2) ; **hypothèse** pour `segment` : une valeur `integer(0)` / `NA` ne peut sortir de `selectInput` que dans une fenêtre transitoire au changement d'annexe (non vérifié dans le navigateur) | *vérifié* (appels directs) / *hypothèse* (aucune saisie hors liste) |
| **B. Contrôles de validation sur des entrées que la grille ne produit pas** | `engine_valider_donnees()` : « xt et yt doivent etre numeriques » (LN-X1), « doivent avoir la meme longueur » (LN-X2), bareme / segment / annexe invalides (via `.engine_credibilite_appliquee()`) ; `mw_valider_triangle()` : « Le triangle doit etre une matrice numerique » (MW-X1), trois motifs de noms de ligne (MW-X2 à X4), bareme ; `.nature_erreurs()` : « brutes refusees » en reserve1/2 et « non reconnue » (l'application passe `NULL` hors prime) ; `mw_valider_ajustement()` : « Reserve ... non finie », « MSEP ... non finie ou negative » | `lire_saisie()` et `lire_triangle()` rendent toujours des vecteurs / matrice `numeric` de même longueur, sans noms de ligne (`app.R:1010-1028`) ; `nature_saisie()` rend `NULL` hors « premium » (`app.R:809`) ; le domaine numérique borné évite R ou MSEP non finis (*hypothèse (lecture)*) | texte déclenché par appel direct : `trig_ln.R` L2, L3, L13 ; `trig_mw.R` M1, M10, M10b, M11 ; `trig_mw.R` MN |
| **C. Erreurs R du calcul protégé** | `.engine_calcul_protege()` couvre toute la chaîne après validation : `usp_ajuster()` (2), `usp_ajuster_*` (2), `usp_tests()` (10), `engine_registre_tests()` (15), `.mc_*` (9), `engine_p_mc()` / `engine_p_famille()` (4), `mw_*` et `.mw_*` (≈ 15), `.usp_mco_qr()` (2), `dw_puissance_ar1()` (4), `usp_puissance_enveloppe_h2()` (2), `.engine_trace_*` (8, appelées par l'affichage sur un résultat valide) … | l'erreur est interceptée ; ce que l'utilisateur lit est AJ-04 (motif neutre, texte fixe), le message R va au journal (`app.R:857-865`) | *vérifié* : stop injecté, `trig_post.R` D1 (`ok = FALSE`, motif neutre) ; chaque garde individuelle : *hypothèse (lecture)* |
| **D. Fonctions que l'application n'appelle pas ou dont le message est remplacé** | `usp_lire_vecteur()` (8), `usp_charger()` (2), `engine_ecrire_xlsx()` (1), `engine_lire_xlsx()` (1), `engine_b_minimal()` (3, appelée sous `tryCatch` par `engine_motif_b_alpha()`), `engine_regle_verdicts()` (1, alpha d'un résultat valide) | `grep -n 'usp_lire_vecteur\|usp_charger' app.R R/display_helpers.R` : aucune occurrence ; `engine_lire_xlsx` : toute erreur est remplacée par `MESSAGE_ILLISIBLE$xlsx` (`app.R:231, 250`) ; message déclenché : « Classeur illisible : aucune feuille trouvee. » (`trig_misc.R`) | *vérifié* (grep, appel direct) |

Écart de décompte avec la fiche de K4 (123 appels, dont 27 entre les l. 4000 et 4999 et 28 après la l. 13000) : les 123 comptent aussi les occurrences dans les commentaires et les lignes `stop(` multiples ; mon décompte (116) ne retient que les lignes de code (`awk '/stop\(/ && !/^[ \t]*#/'`).

## 5. Ce que les tests lisent (partiel, à refaire à l'étape 9)

Recherche en texte fixe de préfixes (`grep -rlF`) dans `tests/*.R`, `tests/unitaires/*.R`, `app.R`, `R/display_helpers.R` (*vérifié*, mais partiel : les tests lisent aussi par `grepl` sur un mot, non retrouvé ici). Préfixes retrouvés, par message :
- LN-01 : `test_calibration.R` ; LN-06 / MW-08 (« hors du domaine numerique ») : `test_controles_entree.R`, `test_merz_wuthrich.R` ; PR-02 : `test_application.R`, `test_controles_entree.R` (+ 1 fichier non nommé par ma commande) ;
- AJ-01 à AJ-03 (« Maximum de vraisemblance non ... ») : `test_controles_entree.R`, `test_rapport_html.R` ; AJ-04 : `test_controles_entree.R` (+ 1) ;
- MW-05 : `test_application.R`, `test_controles_entree.R`, `test_merz_wuthrich.R` ; MW-06 : `test_controles_entree.R`, `test_ex_aequo.R` ; MW-07 : `test_merz_wuthrich.R` ; MW-10 : `test_merz_wuthrich.R`, `test_merz_wuthrich_suite.R` ;
- LE-03 : `test_controles_entree.R` ; LE-04, LE-07, LE-13 : `test_application.R`, `test_controles_entree.R` ; LE-11 : `test_controles_entree.R` ;
- US-03, US-05 : `test_controles_entree.R` ; US-04 : `test_controles_entree.R` (+ 1).
Aucun préfixe retrouvé (0 fichier) pour LN-02 à LN-05, LN-07, LN-08, LN-10, PR-01, MW-01 à MW-04, MW-09, LE-01, LE-02, LE-08, US-01 (*vérifié* pour les préfixes testés ; ces messages peuvent être lus par un motif plus court). `test_controles_entree.R` est le fichier le plus concerné.

## 6. Constats nouveaux

1. **Doublon dans le bandeau** : à `T < 5` sur une série de moins de 5 années, `engine_valider_serie_retenue()` sort deux fois « Annexe XVII, B/C(2)(b) : au moins 5 annees consecutives (T = 4). » (sorties `ERR:` répétées, `trig_ln.R` L9, via `engine_valider_profondeur()` et `engine_valider_donnees()`). Un `unique()` ou la suppression d'un des deux sites relève de la forme, non du texte ; c'est un défaut de contenu de `validation$erreurs`, donc de l'objet `usp_engine` : à signaler à `actuary` / `audit`.
2. **Contradiction apparente de US-03** : le champ « Seuil alpha » de l'application annonce `max = 0.20` (`app.R:613`) alors que le message cite `SEUIL_ECHEC_SENS_REJETER = 0.3`.
3. **Une erreur d'usage est montrée deux fois** : bandeau (`refuser()`) et notification pleine (`showNotification(paste("Erreur d'usage :", conditionMessage(cond)))`, `app.R:837-838`), alors que les refus de validation n'utilisent plus que le texte fixe en notification (#226, #287) ; hors périmètre de K4 (`app.R`), à signaler.
4. **Messages cités avec des valeurs R brutes** : « NA_real_ » (LN-08, LN-10, US-01 à US-03, US-05) vient de `.engine_saisie()` (`deparse()`), qui reste le point de production : on peut y corriger le jargon une fois pour tous les messages qui citent une valeur refusée (`engine.R:473-481`).

## 7. Taille et proposition de regroupement

**45 messages d'erreur ou de refus** dans le périmètre (59 avec les avertissements de validation). Au-delà de ~20 : **question au mainteneur**, Q-58-2 (c), scission éventuelle. Regroupement naturel, cinq commits possibles si la branche garde #527 :

| Commit | Contenu | Messages | Références à patcher | Fixtures principales |
|---|---|---|---|---|
| 9a | usage (`.engine_verifier_usage()` et `.engine_saisie()`) | 5 (US-01 à US-05) | aucune | `test_controles_entree.R` (US-04, US-05) |
| 9b | lognormale : validation, profondeur, ajustement, défaut | 17 (LN-01 à LN-10, PR-01 à PR-03, AJ-01 à AJ-04) | aucune | `test_controles_entree.R`, `test_rapport_html.R` |
| 9c | Merz-Wüthrich | 10 (MW-01 à MW-10) | aucune | `test_merz_wuthrich.R`, `test_merz_wuthrich_suite.R`, `test_application.R` |
| 9d | lecteurs | 13 (LE-01 à LE-13) | aucune | `test_controles_entree.R`, `test_application.R` |
| 9e (facultatif) | avertissements AV-06, AV-07, AV-10, AV-11 | 4 | **les six références** (`validation$avertissements` et `repere_profondeur`, 12 chaînes) | `test_merz_wuthrich*.R`, `test_controles_entree.R` |

Les commits 9a à 9d ne touchent aucune référence (les erreurs n'y figurent pas) : leur effet attendu sur les références est **nul**, vérifiable par `comparer_references.R`. Seul 9e exigerait un patch non numérique.
