# Spécification finale de l'issue #514 : `detail` des lignes de test, usage et tests liés, mentions de régime

> *Rapport de l'agent `actuary-approfondi` (fiche de jugement, Opus, effort `high`), version finale du 09/11/2026 après les décisions Q-1 à Q-7 du mainteneur, reproduit intégralement par la session principale (IA). Elle remplace les deux versions précédentes (`40cfa66`). **Q-8 tranchée par le mainteneur le 09/11 : M23 non posée** (recommandation suivie).*

**Statut : complet.** Il reste une question nouvelle, Q-8, à trancher par le mainteneur (§ 10). Ce document remplace intégralement `docs/revues/20261109-detail-deux-phrases/specification-actuary.md`.

Rédigé par `actuary-approfondi` en lecture seule. Ancres textuelles, avec leurs numéros de ligne à `bcc4997` : le code bouge, `coder` doit retrouver chaque site par son ancre.

## 0. Décisions intégrées (09/11/2026)

- **Q-1. Comptage.** Règle (P) (§ 1). Les mentions conditionnelles sont hors compte.
- **Q-2. Séparateurs.** « ` ; `» devient «`, `» dans M3, M4, M5, M7, M8, M9, M14 et T-3b.
- **Q-3. Énumérations.** Les énumérations numériques sortent du `detail` (§ 6).
- **Q-4. Plafond.** 400 caractères sur le texte propre.
- **Q-5. Jackknife.** Années citées jusqu'à 3, leur nombre au-delà.
- **Orientation.** Le `detail` dit de façon concise comment utiliser le test et quels tests lui sont liés : phrase 1 = usage, phrase 2 = tests liés.
- **Q-6. Raisons propres aux données.** Quand la nature de la p-value change pour une raison propre aux données, une phrase pédagogique le dit dans le `detail`. C'est une **mention conditionnelle de régime** (M17 à M22), hors des 2 phrases et des 400 caractères.
  - J'adopte la lecture de la session. Elle ne trahit pas la décision.
  - J'y ajoute le cas que cite le mainteneur, **δ au bord**. À δ = 1, la p-value devient exacte, mais sous le seul modèle restreint δ = 1 (M20). C'est la réserve qui change la lecture.
  - Le renvoi générique `PHRASE_RENVOI_NATURE_P`, qui n'explique aucune raison, sort du `detail`.
- **Q-7.** (a) membres de famille cités par leurs clés `mc_nom` ; (b) phrase 2 de la constante et de Spearman ratio / volume seulement sous le renvoi de #215. Les deux points sont acceptés.

## 1. Règles

- **(P) Fins de phrase.** Une fin de phrase est :
  - un « . » suivi d'une espace puis d'un caractère non blanc, quelle que soit la casse ;
  - ou un « ; » suivi d'une espace ;
  
  à profondeur nulle de parenthèses et de crochets. Le « . » ne compte pas après un mot de `.ABREV_FIN_PHRASE` (liste recopiée dans le test), ni après une lettre isolée précédée d'un « . » (« i.i.d. »). « ! » et « ? » ne comptent pas (factorielles « T! »). Nombre de phrases = nombre de fins + 1 ; vide ou NA = 0.
- **Lettre isolée suivie de « . » et d'une espace.** Elle compte comme fin de phrase. Écrire « famille B (H1) » et « famille D (H3, lognormalite) », jamais « famille B. » suivi d'une espace.
- **(L1) Texte propre** = le `detail` moins toutes ses mentions conditionnelles (M1 à M22), séparateurs de bord retirés. Il fait au plus 2 phrases et au plus 400 caractères, dans toute branche.
- **(L2) Mentions conditionnelles.** Chacune fait exactement une phrase, sauf celles marquées « telle quelle » au § 2, qui sont des textes approuvés. Le `detail` entier peut donc dépasser 2 phrases et 400 caractères.
- **Ordre dans le `detail` :**
  1. préfixes posés par `add()` (M1, M3, M4/M5, M9) ;
  2. mentions de régime M17 à M22, posées par `usp_tests()` **en tête du texte de l'appelant**, comme l'ancien préfixe R7 ;
  3. phrase 1 ;
  4. phrase 2 ;
  5. suffixes posés par `add()` et `mw_tests()` (M6, M7, M8, M10, M12, M13, puis M11 en dernier).
  
  Le renvoi de #215 (`.usp_poser_renvois()`, 14572) s'insère en fin, avant M11, sans changement de code.
- **Lignes « non applicable ».** Elles gardent leur seul motif, en une phrase.
- **Contraintes de construction :**
  - `.engine_joindre()` est inchangée.
  - Parenthèses construites à la source ; aucun nouveau `grepl` ni `sub` sur `"\\.$"` (contrôle J3).
  - Chaînes ASCII sans accents.
  - Aucun nombre issu du bootstrap (règle #76).
  - Libellés cités exactement entre `\"…\"`. Pour les deux lignes de rapport de vraisemblance, le préfixe commun s'écrit `\"Rapport de vraisemblance : delta = ...\"`.
- **Éléments imposés, conservés :** « CONTROLE SANS OBJET ICI » ; les préfixes « Diagnostic par decision, sans verdict ni p-value retenue : » et « Diagnostic (regle R15), sans verdict ni p-value retenue : » ; « EQUIVALENCE NON DEMONTRABLE AVEC CES DONNEES » ; « Grandeur rivee par l'estimation » ; M11, M12 et M13 tels quels.
- **Règle des verdicts** (`add()`, 4726-4730 *(vérifié)*) :
  - sens « ne pas rejeter » : ECHEC si p < α/2, ALERTE si α/2 ≤ p < α, OK sinon ;
  - sens « rejeter » : OK si p < α, ALERTE si p < 0,30, ECHEC sinon.

## 2. Mentions conditionnelles

**M1 à M16** (inchangées depuis la version amendée)

| Mention | Ancre (ligne à `bcc4997`) | Traitement |
|---|---|---|
| M1 `.prefixe_motif_mc()` et complément | `.prefixe_motif_mc <-` (4104) | telle quelle |
| M2 « `<motif>` : test non applicable. » | dans `add()`, vers 4499 | telle quelle |
| M3 « Monte-Carlo indisponible : `<motif>`, `<libelle>` non retenue. » | 4507 | réécrite (Q-2) |
| M4 « TEST INOPERANT au seuil alpha = %g : %s = %.4f%s, aucun verdict. » | 4606 | réécrite |
| M5 « TEST INOPERANT au seuil alpha = %g : plus petite p-value Monte-Carlo atteignable sur ces replications >= alpha%s, aucun verdict. » | 4593 | réécrite |
| M6 « ECHEC inatteignable … » (deux formes) | vers 4597 et 4615 | telle quelle |
| M7 « … , mais la p-value Monte-Carlo retenue … : ECHEC possible » | 4620 | réécrite |
| M8 chaînes `effectifs` | 4631 ; sources `eff_rangs` (5670), `eff_sm_ea` (6353), `.mw_p_min_ligne` (11695) | réécrite |
| M9 « Monte-Carlo indisponible : `<motif>`, aucune p-value disponible sur ces donnees : aucun verdict. » | 4640 | réécrite |
| M10 plancher Monte-Carlo | 4674 | telle quelle |
| M11 `PHRASE_VERDICT_SENSIBLE_MC` | 4281 | telle quelle |
| M12 phrases de #257 | 12261 | telle quelle |
| M13 `.mw_phrase_b_effectif()` (#204/#279) | 12217 | telle quelle |
| M14 exclusions de colonnes M1 | 10814 | réécrite |
| M15 T-3a / T-3b | 4812 / 4818 | T-3a telle quelle ; T-3b réécrite |
| M16 motif Monte-Carlo des lignes de rapport de vraisemblance | dans `pref <- character(0)` (7314) | telle quelle |

- **M14 :** `sprintf("%s : %s, %s, %s hors de la combinaison de Fisher%s, exclusion qui ne vaut pas preuve %s.", sujet, liste, quoi, "colonne"/"colonnes", clause_K)`, avec `clause_K = ", K = %d colonne(s) testee(s) sur %d eligible(s)"` ou rien.
- **T-3b :** « p de famille non calculee : replications completes insuffisantes (B_effectif < B_MIN_DEGENERESCENCE = %d), aucune p-value. »
- **M8 :**
  - `eff_rangs` = `sprintf("T = %d, ex aequo %s : loi conditionnelle non tabulee, p_min et p exacte non attribuees", ...)`, la forme sans ex aequo étant inchangée ;
  - `eff_sm_ea` = `sprintf("n1 = %d, n2 = %d, ex aequo dans z : p_min et p exacte non attribuees", ...)`.

**M17 à M22, mentions de régime (Q-6 ; nouvelles).** À définir comme constantes du moteur, à côté de `PHRASE_VERDICT_SENSIBLE_MC`.

- **M17a `MENTION_PI_VARIABLE_TEST`** : « pi_t variable (delta < 1, volumes non constants) : les residus z ne sont pas echangeables ni les ratios r_t identiquement distribues, la loi exacte de la statistique ne s'applique donc pas et la p-value de Monte-Carlo, simulee sous le modele ajuste, en tient lieu. »
  - Lignes : à π_t variable, les lignes R7 qui ne sont pas des diagnostics par décision (« Independance ratio S/P vs volume », « Tendance monotone du ratio S/P », « Tendance par signes du ratio S/P », « Autocorrelation d'ordre 1 (Durbin-Watson) », « Test des suites (aleatoire des signes) »), plus « Test des suites sur ratios bruts », branche 3.
  - Remplace `txt_pi_variable` (5566) et la phrase d'approximation de la branche 3 de Runsr.
  - 264 caractères.
- **M17b `MENTION_PI_VARIABLE_DIAG`** : « pi_t variable (delta < 1, volumes non constants) : les residus z ne sont pas echangeables ni les ratios r_t identiquement distribues, la loi exacte de la statistique ne s'applique donc pas (p exacte non attribuee). »
  - Lignes : à π_t variable, les diagnostics par décision du groupe R7 (« Correlation ratio S/P vs temps », « Egalite des lois petits vs gros volumes (2 ech.) »).
  - 214 caractères.
- **M18 `FORMAT_MENTION_BANDE`** : `sprintf("pi_t n'est constant qu'a la tolerance TOL_DELTA_BORD = %g pres (%s) : la loi exacte, etablie pour pi_t exactement constant, ne vaut ici qu'a un ecart de cet ordre pres.", TOL_DELTA_BORD, ecart_tol)`.
  - Lignes : lignes R7, π_t constant dans la bande de tolérance, `p_ex` finie, quel que soit le type.
  - Remplace `txt_bande` (5569).
  - 224 caractères au pire (`ecart_tol` à deux termes).
- **M19 `MENTION_H3_PI_VARIABLE`** : « pi_t variable : les residus z ne forment pas un echantillon i.i.d. normal, et la p non simulee (colonne p asymptotique), etablie pour un tel echantillon, n'est donnee que pour information. »
  - Lignes : les huit lignes H3 à π_t variable dont la p non simulée est finie (Shapiro-Wilk, Shapiro-Francia, Anderson-Darling, Cramer-von Mises, Kolmogorov-Smirnov, Lilliefors, Jarque-Bera, D'Agostino).
  - Remplace `txt_h3_pi_variable` (6434).
  - 188 caractères.
- **M20a `MENTION_DELTA_BORNE_1`** : « delta estime a la borne 1 : pi_t constant rend les residus echangeables et la loi exacte s'applique, sous le modele restreint delta = 1 retenu par l'outil et non sous le modele complet. »
  - Lignes : lignes R7 qui ne sont pas des diagnostics par décision, π_t exactement constant **parce que δ = 1**, `p_ex` finie.
  - Sur `premium` : constante… non ; « Independance ratio S/P vs volume », « Tendance monotone du ratio S/P », « Tendance par signes du ratio S/P », « Autocorrelation d'ordre 1 (Durbin-Watson) », « Test des suites (aleatoire des signes) ».
  - C'est le cas « δ au bord » du mainteneur. La réserve (modèle restreint) reprend le texte de #215 (« vaut sous le modele restreint delta = 1, retenu par l'outil, et non sous le modele complet »).
  - 185 caractères.
- **M20b `MENTION_VOLUMES_CONSTANTS`** : « volumes constants : pi_t est constant quel que soit delta, ce qui rend les residus echangeables et la loi exacte applicable. »
  - Lignes : mêmes conditions que M20a, mais π_t constant parce que les volumes sont constants (sans bande).
  - 124 caractères.
- **M21 `MENTION_EDGEWORTH`** : « T > 9 : cor.test() ne fournit plus la loi exacte de permutation (developpement d'Edgeworth), la p exacte n'est donc pas attribuee. »
  - Lignes : les deux lignes Spearman (ratio / volume, ratio / temps) à T > 9.
  - Remplace `txt_edgeworth` (5685).
  - Environ 130 caractères.
- **M22 `MENTION_PERMUTATIONS_ALEATOIRES`** : « T > 9 : les T! appariements ne sont plus enumeres, la p-value est celle de B permutations aleatoires (Monte-Carlo, p = (1 + k)/(B + 1)) et non une p exacte. »
  - Lignes : « Test de Pitman sur la pente (lien positif pertes / volume) », branche des permutations aléatoires (`perm_alea`).
  - 156 caractères.
- **M23 (Q-8, non posée par défaut)** : « delta estime interieur a [0,1] : la p-value de Monte-Carlo est calculee sur les seules simulations ou delta estime reste interieur, conditionnellement a ce regime. » Posée seulement si le mainteneur la retient (163 caractères).

**Remarques :**
- Les mentions de régime ne dépendent que d'éléments connus de `usp_tests()` (régime, `type_diag`, `p_ex`, T, `perm_alea`), jamais de la bascule R1 faite plus tard dans `add()`. D'où le verbe neutre de M20a (« s'applique ») et « en tient lieu » en M17a, qui restent justes si R1 bascule ensuite la ligne.
- Les lignes R15 (ratios bruts à π_t constant) ne reçoivent ni M20 ni M18 : leur texte propre dit déjà le doublon.

## 3. Fragments partagés de `usp_tests()`

- **Convertis en mentions de régime :**
  - `txt_pi_variable` (5566) → M17a/M17b ;
  - `txt_bande` (5569) → M18 ;
  - `txt_h3_pi_variable` (6434) → M19 ;
  - `txt_edgeworth` (5685) → M21 ;
  - méthode aléatoire de Pitman (5946) → M22.
  
  `detail_r7()` (5579), `detail_spearman()` (5685 et suivantes) et `detail_h3()` posent désormais la mention de régime voulue **en tête** du texte, par `.engine_joindre(mention, texte)`.
- **Retirés (construction) :**
  - `txt_plage` (6470) : la p non simulée NA à T < 8 est visible dans le champ ;
  - `motif_ea` de `detail_diag()` (5642) et `ea_ru` (Merz-Wüthrich) ;
  - `txt_mc_indispo` (5601), redondant avec M3 et M9 ;
  - `PHRASE_RENVOI_NATURE_P` (4292), qui n'est plus employée.
- **`detail_diag(nm, detail, raison, regle)`** : `joindre(detail, paste0("Diagnostic par decision, sans verdict ni p-value retenue : ", raison, "."))`.
- **`txt_r15(homologue)`** (6960) : `paste0("Diagnostic (regle R15), sans verdict ni p-value retenue : la ligne \"", homologue, "\" fait foi.")`.
- **`note_r`** (6940) : « CONTROLE SANS OBJET ICI : pi_t constant, aucun artefact de ponderation a detecter, quasi-doublon de la ligne homologue sur residus standardises. »
- **`detail_r(txt)`** : devient `if (nzchar(note_r)) note_r else txt`.

## 4. Textes propres, ligne par ligne (phrase 1 ; phrase 2)

Les mentions de régime posées sur chaque ligne sont rappelées entre crochets.

### Famille B (H1)

- **U1 « Nullite de la constante (proportionnalite stricte) »** (`"Le NON-rejet ne prouve`, 5767 ; `txt_seuil_cst`, 5726).
  - P1 : `sprintf("Un ECHEC ou une ALERTE met en cause la proportionnalite stricte (constante non nulle), un OK ne la prouve pas (constante detectee seulement si |a| >= %.0f %% de la moyenne de y, seuil de Student approche) : la preuve positive est un OK de \"Equivalence de la constante a zero (TOST)\".", c_pct)`. Sans seuil calculable, la parenthèse est omise.
  - P2 = `USP_TXT_RENVOI_CST` (14543) : « Voir aussi "Independance ratio S/P vs volume", qui a une constante non nulle parmi ses alternatives. »
- **U2 « Equivalence de la constante a zero (TOST) »** (5871 ; R14 : 5854).
  - Ligne de type test : `sprintf("Un OK (rejet de H0) prouve la proportionnalite pratique, |a| < Delta (Delta = %s), une ALERTE ou un ECHEC n'etablit ni l'equivalence ni un ecart a la proportionnalite. A lire avec \"Nullite de la constante (proportionnalite stricte)\".", txt_delta)`.
  - Règle R14 : `sprintf("EQUIVALENCE NON DEMONTRABLE AVEC CES DONNEES au seuil alpha = %g, aucun verdict : avec ces volumes et cette dispersion, aucune constante estimee ne donnerait p < alpha (p_plancher = %.3f), absence de preuve et non ecart a la proportionnalite. La proportionnalite releve de \"Nullite de la constante (proportionnalite stricte)\".", alpha, p_plancher)`.
- **U3 « Test de Pitman sur la pente (lien positif pertes / volume) »** (5946, 5909, 5977). [M22 si `perm_alea`]
  - P1 : `sprintf("Ici on souhaite REJETER H0 : un OK etablit un lien positif pertes / volume, qui peut aussi venir d'une dispersion liee au volume ou d'une tendance commune, une ALERTE ou un ECHEC un lien non demontre%s.", ctx)`.
  - `ctx` vaut « (plancher 1/(B + 1) >= alpha : OK inatteignable) » sous la condition actuelle, sinon `sprintf(" (puissance approchee a posteriori = %.2f)", pw)` si la puissance est finie et t_b > 0, sinon rien.
  - P2 : « A lire avec "Test de Student sur la pente (modele auxiliaire MCO)" et "Coefficient de determination R2". »
- **U4 « Test de Student sur la pente (modele auxiliaire MCO) »** (6026). « Signe et intensite du lien pertes / volume sous le modele auxiliaire MCO (non reglementaire), pour information. Diagnostic sans verdict : la ligne "Test de Pitman sur la pente (lien positif pertes / volume)" fait foi, "Test de Fisher (significativite globale)" porte la meme p (F = t^2). »
- **U5 « Test de Fisher (significativite globale) »** (6069). « Significativite globale de la regression de y sur x sous le modele auxiliaire MCO, pour information. Diagnostic sans verdict : la ligne "Test de Pitman sur la pente (lien positif pertes / volume)" fait foi, "Test de Student sur la pente (modele auxiliaire MCO)" porte la meme p (F = t^2). »
- **U6 « Coefficient de determination R2 »** (6083). `sprintf("R2 ajuste = %.4f, %s du repere conventionnel R2 < 0.5 (E[R2] = %.3f sous b = 0) : part de la variance des pertes expliquee par le volume, sans valeur de test. La pente est testee par \"Test de Pitman sur la pente (lien positif pertes / volume)\".", ...)`.
- **U7 « RESET (forme fonctionnelle) »** (6100). « Un ECHEC ou une ALERTE signale une forme non lineaire de E[Y_t] en x_t, un OK ne demontre pas la linearite. A lire avec "Nullite de la constante (proportionnalite stricte)" et "Independance ratio S/P vs volume", autres alternatives a la proportionnalite. »
- **U8 « Independance ratio S/P vs volume »** (6133, 5524, renvoi 14550). [M17a | M18 | M20a/M20b ; M21]
  - P1 : « Un ECHEC ou une ALERTE signale un effet d'echelle non modelise (ratio S/P monotone en volume), un OK n'en demontre pas l'absence. »
  - P1 à pertes constantes : « Pertes y_t constantes (voir l'avertissement sur les donnees) : le ratio varie en sens inverse du volume, et un ECHEC ou une ALERTE traduit des pertes non proportionnelles au volume. »
  - P2 = `USP_TXT_RENVOI_SV` : « A lire avec "Nullite de la constante (proportionnalite stricte)", dont une constante non nulle est l'une des alternatives de ce test, sans specificite. »
- **U9 « Correlation ratio S/P vs temps »** (6163). [M17b | M18 ; M21] « Mesure une tendance monotone du ratio S/P dans le temps, pour information. Diagnostic par decision, sans verdict ni p-value retenue : la ligne "Tendance monotone du ratio S/P", meme alternative, fait foi. »
- **U10 « Tendance monotone du ratio S/P »** (6194). [M17a | M18 | M20] « Un ECHEC ou une ALERTE signale une derive monotone du ratio S/P dans le temps, contraire a la constance de beta. A lire avec "Tendance par signes du ratio S/P" et "Correlation ratio S/P vs temps", qui visent la meme alternative. »
- **U11 « Tendance par signes du ratio S/P »** (6205). [M17a | M18 | M20]
  - P1 : `sprintf("Un ECHEC ou une ALERTE signale une tendance du ratio S/P, par le signe des differences entre premiere et seconde moitie de la periode (%s).", eff)`.
  - `eff` vaut « m = %d paires », ou « m = %d differences non nulles sur n_p = %d paires, p_mc non calculee », ou « aucune difference non nulle : K non defini ».
  - P2 : « A lire avec "Tendance monotone du ratio S/P", meme alternative. »

### Famille C (H2)

- **U12 « Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker) »** (6280, 6256).
  - P1 : `sprintf("Un ECHEC ou une ALERTE signale une variance des residus liee au volume, contraire a la structure de variance de l'annexe XVII, un OK ne la demontre pas (puissance maximale %.2f avec ces volumes au seuil alpha = %g).", pi_env, alpha)`.
  - Variantes de la parenthèse : « (puissance maximale non calculee : echec numerique) », ou absente si le calcul n'est pas tenté.
  - P2 : « Seul test de H2 a verdict, a lire avec "Position de delta dans [0,1]" et les lignes "Rapport de vraisemblance : delta = ...". »
- **U13 « Heteroscedasticite vs volume - Breusch-Pagan original (non robuste) »** (6297). « Version publiee du test de Breusch-Pagan, non robuste (sur-rejette si les erreurs ne sont pas normales), pour comparaison. » Puis la phrase de diagnostic, raison H2 = « la ligne "Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker)" fait foi ».
- **U14 « Heteroscedasticite (forme quadratique) », « Egalite des variances petits vs gros volumes », « Homogeneite des dispersions (mediane) »** (6243). P1 respectives :
  - « Detecte une variance residuelle de forme quadratique en volume, pour information. »
  - « Compare les variances des residus entre petits et gros volumes, pour information. »
  - « Compare les dispersions, autour de la mediane, des residus entre petits et gros volumes, pour information. »
  
  P2 : phrase de diagnostic, raison H2.
- **U15 « Egalite des lois petits vs gros volumes (2 ech.) »** (6246). [M17b | M18] « Compare les lois des residus entre petits et gros volumes, ce qui vise surtout une difference de position (alternative de H1 plutot que de H2), pour information. Diagnostic par decision, sans verdict ni p-value retenue : les lignes de la famille B (H1), dont "Independance ratio S/P vs volume", font foi. » Motif « partition non calculable » inchangé.
- **U16 « Position de delta dans [0,1] »** (6401, 6418). Famille C., hors du tableau de robustesse (§ 5).
  - Bord : « SOLUTION AU BORD : structure de variance non identifiee par les donnees, delta retenu a la borne. »
  - Intérieur : « Interieur du domaine : melange des deux composantes de variance identifie par les donnees. »
  - Volumes constants : `paste0("VOLUMES CONSTANTS : la vraisemblance ne depend pas de delta", suite_cst, ".")`.
  - Volumes dans la bande : `sprintf("VOLUMES CONSTANTS a la tolerance TOL_DELTA_BORD = %g pres (etendue relative = %.2g) : la vraisemblance ne depend presque pas de delta%s.", ...)`.
  - `suite_cst` = « , qui n'est pas identifie, la valeur affichee etant celle ou l'optimiseur s'est arrete ».
  - P2 (toutes branches) : « A lire avec "Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker)" et les lignes "Rapport de vraisemblance : delta = ...". »

### Famille D (H3) [M19 à π_t variable, p non simulée finie]

- **« Shapiro-Wilk sur residus standardises »** (6444) **et « Shapiro-Francia »** (6457). « Un ECHEC ou une ALERTE signale des residus standardises non normaux, contraire a la lognormalite de l'annexe XVII. Meme hypothese que les autres tests de la famille D (H3, lognormalite), lus ensemble par "p de famille (minP, lecture conjointe)". »
- **« Anderson-Darling »** (6490). « Un ECHEC ou une ALERTE signale un ecart a la normalite, surtout dans les queues, contraire a la lognormalite. Meme hypothese que les autres tests de la famille D (H3, lognormalite). »
- **« Cramer-von Mises »** (6506). « Distance de Cramer-von Mises a la loi normale, tres correlee a celle d'Anderson-Darling, pour information. » Puis la phrase de diagnostic, raison « la ligne "Anderson-Darling" fait foi ».
- **« Kolmogorov-Smirnov contre N(0,1) »** (6509). « Distance de Kolmogorov a N(0,1) a parametres connus, conservatrice sur des residus standardises par le modele (tres conservatrice a T = 8 sur le jeu de controle, par simulation), pour information. » Puis la phrase de diagnostic, raison « la ligne "Lilliefors (KS a parametres estimes)" fait foi ».
- **« Lilliefors (KS a parametres estimes) »** (6548). « Un ECHEC ou une ALERTE signale un ecart a la normalite mesure par la distance de Kolmogorov, avec une loi qui tient compte de l'estimation des parametres. Version a retenir de "Kolmogorov-Smirnov contre N(0,1)", meme hypothese que les autres tests de la famille D (H3, lognormalite). »
- **« Jarque-Bera »** (6565). `sprintf("Un ECHEC ou une ALERTE signale une asymetrie ou un aplatissement non normaux (aplatissement borne mecaniquement par ~T = %d). Composantes lues sur \"Asymetrie (D'Agostino, T >= 8)\" et \"Aplatissement (Anscombe-Glynn, T >= 20)\".", T)`.
- **« Asymetrie (D'Agostino, T >= 8) »** (6574). « Un ECHEC ou une ALERTE signale une asymetrie des residus standardises, contraire a la lognormalite. A lire avec "Jarque-Bera" et les autres tests de la famille D (H3, lognormalite). » Motif « non applicable » inchangé.
- **« Aplatissement (Anscombe-Glynn, T >= 20) »** (6590). Ligne de type test : « Un ECHEC ou une ALERTE signale un aplatissement different de celui de la loi normale. A lire avec "Jarque-Bera". » Motifs « non applicable » inchangés.

### Famille E (H4)

- **« Autocorrelation d'ordre 1 (Durbin-Watson) »** (6625). [M17a | M18 | M20] « Un ECHEC ou une ALERTE signale une autocorrelation d'ordre 1 des residus standardises, contraire a l'independance des annees. A lire avec "Ljung-Box (retard 2)", "Test des suites (aleatoire des signes)" et la ligne homologue "Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts". »
- **« Ljung-Box (retard 2) »** (6639 ; nouveau `detail`). « Un ECHEC ou une ALERTE signale une autocorrelation jusqu'au retard 2 des residus standardises. A lire avec "Autocorrelation d'ordre 1 (Durbin-Watson)" et "Test des suites (aleatoire des signes)". »
- **« Test des suites (aleatoire des signes) »** (6662). [M17a | M18 | M20] « Un ECHEC ou une ALERTE signale un regroupement ou une alternance des signes des residus standardises, contraire a l'independance. A lire avec "Autocorrelation d'ordre 1 (Durbin-Watson)" et la ligne homologue "Test des suites sur ratios bruts". »
- **« Centrage des residus standardises »** (6744, 6807). P1 commence par « Grandeur rivee par l'estimation, aucune p-value retenue : ».
  - π_t exactement constant : « …a pi_t constant, moyenne(z) = 0 par construction et la valeur affichee n'est que du bruit d'arrondi, sans information sur l'ajustement. »
  - Bande de tolérance : « …a pi_t constant a TOL_DELTA_BORD pres seulement, moyenne(z) n'est nulle qu'a un ecart de cet ordre pres, sans information sur la convergence. »
  - δ au bord ou intérieur : « …pi_t n'etant pas constant, la valeur affichee mesure l'ecart entre versions ponderee et non ponderee de la contrainte de centrage. »
  - P2 : « La convergence se lit sur "Variance unitaire des residus standardises" et dans les controles numeriques. »
- **« Variance unitaire des residus standardises »**. Même premier membre.
  - π_t exactement constant : `sprintf("…a pi_t constant, un ecart de var(z) a T/(T-1) signale une convergence imparfaite en gamma, ou gamma bloque sur une borne de son domaine %s.", dom_gamma)`.
  - Bande de tolérance : même texte, suivi de « (a un ecart d'ordre (1 - delta) pres, pi_t n'etant constant qu'a TOL_DELTA_BORD pres) ».
  - δ au bord ou intérieur : « …pi_t n'etant pas constant, l'ecart de var(z) a T/(T-1) n'a pas de valeur de reference. »
  - P2 : « A lire avec "Centrage des residus standardises" et les controles numeriques. »
- **Ratios bruts à π_t constant (règle R15).** P1 = `note_r` ; P2 = `txt_r15(homologue)`. Les homologues :
  - « Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts » (7084) → « Autocorrelation d'ordre 1 (Durbin-Watson) » ;
  - « Stabilite cumulee (OLS-CUSUM) sur ratios bruts » (7130) → « Stabilite cumulee (OLS-CUSUM) » ;
  - « Rupture de niveau (sup-F) sur ratios bruts » (7121) → « Rupture de niveau (sup-F) » ;
  - « Valeur aberrante isolee (Grubbs) sur ratios bruts » (7141) → « Valeur aberrante isolee (Grubbs) ».
- **Les mêmes lignes à π_t variable (type test) :**
  - Durbin-Watson : « Un ECHEC ou une ALERTE signale une autocorrelation d'ordre 1 du ratio S/P, lu sans passer par le modele ajuste. A lire avec la ligne homologue "Autocorrelation d'ordre 1 (Durbin-Watson)". »
  - sup-F : « Un ECHEC ou une ALERTE signale un changement de regime du ratio S/P, lu sans passer par le modele ajuste. A lire avec la ligne homologue "Rupture de niveau (sup-F)". »
  - OLS-CUSUM : « Un ECHEC ou une ALERTE signale un niveau non constant du ratio S/P (derive ou rupture), lu sans passer par le modele ajuste. A lire avec la ligne homologue "Stabilite cumulee (OLS-CUSUM)". »
  - Grubbs : « Un ECHEC ou une ALERTE signale une annee au boni ou mali atypique dans le ratio S/P, lu sans passer par le modele ajuste. A lire avec la ligne homologue "Valeur aberrante isolee (Grubbs)". »
- **« Test des suites sur ratios bruts »** (6988). La phrase R15 cite « Test des suites (aleatoire des signes) ».
  - Branche 1 : « CONTROLE SANS OBJET ICI : pi_t constant, statistique et p exacte identiques a celles de la ligne homologue sur residus standardises (doublon exact). » + R15.
  - Branche 2 : « CONTROLE SANS OBJET ICI : pi_t constant, quasi-doublon de la ligne homologue sur residus standardises, mais un signe au moins differe entre u et z, d'ou ni identite garantie ni p exacte. » + R15.
  - Branche 2b : « CONTROLE SANS OBJET ICI : pi_t constant, quasi-doublon de la ligne homologue sur residus standardises, sans p exacte (un seul cote de la mediane represente). » + R15.
  - Branche 3, [M17a] : « Un ECHEC ou une ALERTE signale un regroupement ou une alternance des signes du ratio S/P centre, lu sans passer par le modele ajuste. A lire avec la ligne homologue "Test des suites (aleatoire des signes)", dont la statistique differe en general a pi_t variable. »

### Famille F

- **« Rupture de niveau (sup-F) »** (6829). « Un ECHEC ou une ALERTE signale une rupture de niveau des residus standardises a une date inconnue. A lire avec "Stabilite cumulee (OLS-CUSUM)" et la ligne homologue "Rupture de niveau (sup-F) sur ratios bruts". »
- **« Stabilite cumulee (OLS-CUSUM) »** (6843). « Un ECHEC ou une ALERTE signale un niveau non constant des residus standardises (derive ou rupture). A lire avec "Rupture de niveau (sup-F)" et la ligne homologue "Stabilite cumulee (OLS-CUSUM) sur ratios bruts". »
- **« Valeur aberrante isolee (Grubbs) »** (6871). « Un ECHEC ou une ALERTE signale une annee aberrante dans les residus standardises. A lire avec "Valeurs aberrantes multiples (ESD generalise)", "Points influents (distance de Cook)" et la ligne homologue "Valeur aberrante isolee (Grubbs) sur ratios bruts". »
- **« Valeurs aberrantes multiples (ESD generalise) »** (6890). `sprintf("Repere de valeurs aberrantes multiples (ESD de Rosner, alpha = %g, nombre en estimation), a niveau superieur a alpha a T = 8 (valeurs critiques adequates a partir de n = 25 selon l'auteur).", alpha)`. Puis la phrase de diagnostic, raison « la ligne "Valeur aberrante isolee (Grubbs)" fait foi ».
- **« Points influents (distance de Cook) »** (5416). `sprintf("Repere conventionnel 4/T = %.3f, %d annee(s) au-dessus : annees dont le retrait deplace fortement la pente de y = beta x. A lire avec \"Leviers (hat values)\" et \"Sensibilite au retrait d'une annee (jackknife)\".", ...)`.
- **« Leviers (hat values) »** (7147). `sprintf("Repere conventionnel 2k/T = %.3f, %d annee(s) au-dessus : volumes extremes qui pesent fortement sur l'ajustement. A lire avec \"Points influents (distance de Cook)\".", ...)`.

### Famille G : tableau « Robustesse du calibrage » (§ 5)

- **G1 « Sensibilite au retrait d'une annee (jackknife) »** (7181, 7195, 7211). P1 = `jk` + `ne` + « . ».
  - `jk`, une seule année : `sprintf("Annee la plus influente sur sigma_USP : %d (sigma_USP %s)", ...)`.
  - `jk`, 2 ou 3 années à égalité numérique : `sprintf("Annees les plus influentes sur sigma_USP, a egalite numerique : %s et %d (%s)", ...)`.
  - `jk`, plus de 3 années : `sprintf("%d annees les plus influentes sur sigma_USP, a egalite numerique (%s)", n, sens)`.
  - `jk`, non déterminée : « Annee la plus influente sur sigma_USP non determinee ».
  - `ne`, 1 à 3 années : `sprintf(", annee(s) %s non evaluable(s) (reajustement sans maximum de vraisemblance etabli ou en echec)", liste)`.
  - `ne`, plus de 3 années : `sprintf(", %d annees non evaluables (reajustement sans maximum de vraisemblance etabli ou en echec)", n)`.
  - Aucune année évaluable : « Aucune annee evaluable (reajustements sans maximum de vraisemblance etabli ou en echec) : influence des annees non mesuree. »
  - σ_USP nul, non fini ou trop petit : `paste0("sigma_USP nul, non fini ou trop petit : influence des annees non mesuree", ne, ".")`.
  - P2 : « A lire avec "Points influents (distance de Cook)" et "Largeur relative de l'IC bootstrap 90%". »
- **G2 « Largeur relative de l'IC bootstrap 90% »** (7240). « Incertitude d'estimation du parametre retenu (percentile a 90 %, res$ic_bootstrap, basic log en regard, res$ic_bootstrap_basic_log), a couverture inferieure au niveau nominal a T = 8 en simulation. A lire avec "Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime)" et "Sensibilite au retrait d'une annee (jackknife)". »
- **G3 « Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) »** (7261). « Incertitude conditionnelle a la structure de variance retenue (delta fixe a delta estime, res$ic_bootstrap_restreint), a couverture inferieure au niveau nominal a T = 8, bootstrap au bord non justifie pour delta (Andrews, 2000). A lire avec "Largeur relative de l'IC bootstrap 90%" et "Position de delta dans [0,1]". »
- **G4 « Rapport de vraisemblance : delta = 0 (variance lineaire en volume) » et G5 « Rapport de vraisemblance : delta = 1 (variance quadratique en volume) »** (7275, 7314).
  - P1 : `sprintf("Aucun verdict : le LR dit si les donnees distinguent la borne de l'optimum (%s%s), non si le modele est adequat.", lecture, ici)`.
  - `lecture` vaut « p_mc elevee : borne aussi defendable que delta estime, p_mc faible : moins compatible » si p_mc existe, sinon « LR = 0 : borne atteinte par l'estimation ».
  - `ici` vaut `sprintf(", ici SOLUTION AU BORD delta = %d : LR = 0 par construction", d0)`, ou « , ici VOLUMES CONSTANTS : LR nul par construction, delta non identifie », ou rien.
  - P2 : « A lire avec "Position de delta dans [0,1]" et "Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker)". »
  - Branche « non applicable » (`MOTIF_LR_DELTA_ECHEC`, 5278, précédé à volumes constants de « VOLUMES CONSTANTS : delta non identifie, LR nul attendu a cette borne mais non calcule. ») : inchangée.
  - M16 reste en tête.

### Lecture conjointe

- **« p de famille (minP, lecture conjointe) »** (`DETAIL_P_FAMILLE`, 4780). `sprintf("Diagnostic sans verdict : une p de famille faible signale qu'au moins une hypothese de la famille est mise en cause sous le modele ajuste (p plug-in non exacte), aucun verdict de ligne n'etant modifie. Tests de la famille (cles mc_nom) : [%s], voir aussi \"p globale (minP, lecture conjointe de la batterie)\".", paste(cles, collapse = ", "))`.
- **« p globale (minP, lecture conjointe de la batterie) »** (`DETAIL_P_GLOBALE`, 4797). `sprintf("Diagnostic sans verdict : une p globale faible signale qu'au moins une hypothese de la batterie est mise en cause sous le modele ajuste, compte tenu des %d tests et de leur dependance (p plug-in non exacte, sur les p Monte-Carlo et non les p retenues). A lire avec les lignes \"p de famille (minP, lecture conjointe)\" de chaque famille.", k)`.

### Merz-Wüthrich (`mw_tests <-`, 12311)

- **« Absence de tendance des facteurs avec le cumul, a colonne donnee »** (12366). « Un ECHEC ou une ALERTE signale un facteur de developpement qui varie avec le niveau du cumul a colonne donnee, contraire a la proportionnalite des cumules. A lire avec "Nullite de l'ordonnee a l'origine, colonne par colonne", dont une constante produit une telle pente, et "Stabilite du facteur selon la ponderation (famille alpha)". »
- **« Nullite de l'ordonnee a l'origine, colonne par colonne »** (12389). « Un ECHEC ou une ALERTE signale une composante fixe (ordonnee a l'origine) dans au moins une colonne, contraire a la proportionnalite des cumules. A lire avec "Absence de tendance des facteurs avec le cumul, a colonne donnee" et "Identifiabilite intra-colonne (dispersion des cumuls par colonne)", qui borne sa puissance. »
- **« Homogeneite de f_j entre annees de survenance »** (12419). « Un ECHEC ou une ALERTE signale des facteurs individuels qui derivent avec l'annee de survenance, contraire a un f_j commun. A lire avec "Effets d'annee calendaire (test de Mack)" et "Homogeneite des residus entre annees de survenance". »
- **« Absence de courbure de la regression »** (12434). « Un ECHEC ou une ALERTE signale une relation non lineaire entre cumuls successifs, qui invalide la proportionnalite meme si la constante est nulle. A lire avec "Nullite de l'ordonnee a l'origine, colonne par colonne". »
- **« Stabilite du facteur selon la ponderation (famille alpha) »** (12450).
  - P1 : `sprintf("Un ECHEC ou une ALERTE signale des estimateurs alpha = 0, 1 et 2 de f_j divergents, donc une esperance non proportionnelle au cumul (M1), non un defaut de variance (ecart relatif maximal %.2f %%, seul alpha = 1 entre dans sigma_USP).", ...)`. Statistique NA : sans la parenthèse.
  - P2 : « A lire avec "Absence de tendance des facteurs avec le cumul, a colonne donnee", meme association du facteur au volume, mais commune aux colonnes. »
- **« Identifiabilite intra-colonne (dispersion des cumuls par colonne) »** (12480).
  - P1 : « Diagnostic sans verdict : moins les cumuls d'une colonne sont disperses (CV moyen en estimation, detail par mw_identifiabilite_intra()), moins les lignes liees sont puissantes. »
  - Sans colonne retenue : « Diagnostic sans verdict : aucune colonne retenue (n_j >= 3 hors colonnes degenerees). »
  - P2 : « Lignes liees : "Nullite de l'ordonnee a l'origine, colonne par colonne", "Absence de tendance des facteurs avec le cumul, a colonne donnee" et "Adequation de l'exposant de variance, colonne par colonne". »
- **« Heteroscedasticite residuelle vs cumul »** (12525). « Un ECHEC ou une ALERTE signale une variance des residus de Mack liee au cumul a colonne donnee, contraire a une variance proportionnelle a C(i,j). A lire avec "Adequation de l'exposant de variance, colonne par colonne", meme hypothese, et "Variance unitaire des residus de Mack". »
- **« Adequation de l'exposant de variance, colonne par colonne »** (12579). « Un ECHEC ou une ALERTE signale un lien entre |r(i,j)| et C(i,j) dans au moins une colonne, au-dela de l'effet de levier, contraire a une variance proportionnelle au cumul. A lire avec "Heteroscedasticite residuelle vs cumul", meme hypothese, et les lignes de M1 pour un ecart d'esperance. »
- **« Variance unitaire des residus de Mack »** (12608). `sprintf("Grandeur contrainte par construction (reference %s%s), qui ne teste PAS la structure de variance : son ecart a la reference donne a lire le CENTRAGE des residus, ici %s. La structure de variance est testee par \"Heteroscedasticite residuelle vs cumul\" et \"Adequation de l'exposant de variance, colonne par colonne\".", ...)`. Variante k = 1 conservée.
- **« Effets d'annee calendaire (test de Mack) »** (12644). « Un ECHEC ou une ALERTE signale un effet d'annee calendaire (diagonales a dominante de facteurs grands ou petits : inflation, changement de cadence), contraire a l'independance des annees d'accident. A lire avec "Effets d'annee calendaire par diagonale (repere de Mack 1997)", qui localise la diagonale. »
- **« Effets d'annee calendaire par diagonale (repere de Mack 1997) »** (12651). `sprintf("Repere par diagonale, sans verdict ni controle de multiplicite : localise les diagonales a dominante L ou S (nombre sous le repere de %s %% en estimation, seule une diagonale d'au moins %d etiquettes pouvant l'atteindre). Le test est \"Effets d'annee calendaire (test de Mack)\", qui fait foi.", ...)`.
- **« Homogeneite des residus entre annees de survenance »** (12698).
  - Général : « Un ECHEC ou une ALERTE signale une annee de survenance dont les residus se distinguent (annee atypique, derive de f_j ou esperance non proportionnelle), sans tester a elle seule l'independance de D(2)(h)(i). »
  - Un résidu par année : « Un residu de Mack par annee de survenance : H = N - 1 par construction, la ligne ne mesure rien ici (ni homogeneite entre annees, ni independance de D(2)(h)(i)). »
  - P2 : « A lire avec "Homogeneite de f_j entre annees de survenance" et "Effets d'annee calendaire (test de Mack)". »
- **« Correlation entre annees de developpement adjacentes »** (12717). « Un ECHEC ou une ALERTE signale une correlation entre facteurs de developpement successifs (dependance entre cadences), contraire au modele de Mack. A lire avec "Autocorrelation des residus (Durbin-Watson)". »
- **« Autocorrelation des residus (Durbin-Watson) »** (12723 ; nouveau `detail`). « Un ECHEC ou une ALERTE signale une autocorrelation des residus de Mack dans l'ordre de parcours du triangle. A lire avec "Test des suites sur les residus de Mack" et "Correlation entre annees de developpement adjacentes". »
- **« Test des suites sur les residus de Mack »** (12751). « Detecte un regroupement ou une alternance des signes des residus de Mack, pour information. Diagnostic par decision, sans verdict ni p-value retenue : la ligne "Autocorrelation des residus (Durbin-Watson)", memes residus dans le meme ordre, fait foi. »
- **« Cellule aberrante du triangle (residus studentises externes) »** (12818). `sprintf("Un ECHEC ou une ALERTE signale une cellule aberrante du triangle (plus petit residu studentise externe) parmi les N_t = %d cellules des colonnes n_j >= %d, %d cellule(s) des colonnes n_j = 3 non couverte(s). A lire avec \"Cellules aberrantes multiples (ESD generalise)\".", ...)`.
- **« Cellules aberrantes multiples (ESD generalise) »** (12274 et 12847 remplacées). `sprintf("Repere du nombre de cellules aberrantes (ESD de Rosner a alpha = %.2f, nombre en estimation), sans p-value : son cadre i.i.d. normal (n >= 25) ne couvre pas les residus de Mack, contraints par colonne. Diagnostic sans verdict : la ligne \"Cellule aberrante du triangle (residus studentises externes)\" fait foi.", alpha)`.
- **« Shapiro-Wilk sur les residus de Mack »** (12878). « Diagnostic sans verdict : la normalite n'est pas exigee par le modele (D(2)(h) : deux premiers moments), et la loi de W, celle d'un echantillon i.i.d. normal, rejette trop souvent sur des residus de Mack (simulation), p-value utile seulement pour un quantile de la MSEP. A lire avec "Lilliefors sur les residus de Mack". »
- **« Lilliefors sur les residus de Mack »** (12897). « Diagnostic sans verdict : approximation de Dallal et Wilkinson etablie pour un echantillon i.i.d. normal, qui rejette trop souvent sur des residus de Mack (simulation), p-value pour information. A lire avec "Shapiro-Wilk sur les residus de Mack". »
- **M6-1 « Extrapolation de sigma pour la derniere annee de developpement »** (9454).
  - P1 : `sprintf("Valeur fixee par la regle de minimum de l'annexe XVII, D(5)(d)(ii), non estimee : min(sigma2_(J-2) = %s, sigma2_(J-3) = %s, quotient = %s) = %s, atteint par %s%s.", ...)`.
  - Le quotient NA s'écrit « non defini (sigma2_(J-3) = 0) ».
  - `retenus` vaut « sigma2_(J-2) et sigma2_(J-3) (ex aequo) », ou « sigma2_(J-2) (colonne J-2 degeneree, quotient non compte) », ou la règle actuelle.
  - Le dernier `%s` vaut « , colonnes J-3 et J-2 degenerees : voir l'avertissement sur les donnees » (ou la colonne seule concernée), ou rien.
  - Non applicable : « Valeur fixee par la regle de minimum de l'annexe XVII, D(5)(d)(ii), non estimee : la regle ne lit que les deux dernieres variances estimees. »
  - P2 : « A lire avec "Part de la reserve portee par la derniere annee d'accident". »
  - L'argument `sens` est supprimé. `mw_sensibilite_sigma2_dernier()` reste (voie de recalcul) ; `RAPPORT_MAX_ECART_MW` devient sans usage (à trancher par `coder` et `audit`).
- **M6-2 « Part de la reserve portee par la derniere annee d'accident »** (12930). `sprintf("part = %.1f %% de la reserve totale : une part elevee concentre la MSEP sur la ligne la moins developpee, aux facteurs les plus extrapoles (repere indicatif de 40 %%, sans fondement reglementaire ni statistique, sans verdict). A lire avec \"Extrapolation de sigma pour la derniere annee de developpement\".", 100 * part)`.
- **Familles M1, M2, M3 et globale :** textes de la lecture conjointe ci-dessus.

**Contenu retiré et sa place dans le `.tex`** (vérifié par mots-clés, fenêtres de 180 à 260 lignes) :

| Contenu retiré | Fiche du `.tex` |
|---|---|
| E[r_t] = b + a/x_t | `fiche:student-constante` |
| ρ, p_bas, p_haut du TOST | `fiche:tost-constante` |
| méthode d'énumération, lambda, théorème central limite combinatoire | `fiche:student-pente` |
| loi F non exacte, Milliken-Graybill | `fiche:reset` |
| QQ-plot à deux échantillons, D = 1 | `fiche:smirnov` |
| ajustement de D'Agostino et Stephens | `fiche:anderson-darling` |
| Imhof, bornes d_L/d_U | `fiche:durbin-watson` |
| loi de Fisher inapplicable | `fiche:sup-f` |
| formule asymptotique | `fiche:ols-cusum` |
| borne (T−1)/√T | `fiche:grubbs` |
| dérivations du premier ordre | `fiche:centrage`, `fiche:variance-unitaire` |
| loi combinatoire de Runsr, causes de l'inversion de signe | `fiche:suites-ratios-bruts`, `sec:base-residus` (à vérifier) |
| Chernoff | `fiche:rv-delta` |
| `n_echec_restreint`, Andrews (moyenne contrainte) | `fiche:ic-bootstrap` |
| construction minP | `sec:lecture-conjointe` |
| pente relative | `mw:m1` |
| identité de Mack, 1e-16 | `mw:m1a` (1e-16 à vérifier) |
| rang et combinaison de Fisher | `mw:m1b` |
| covariance de la famille alpha | `mw:m1d` |
| R^(k−1), multiplicateurs | `mw:m1id` |
| construction n R² | `mw:m2bp` |
| levier | `mw:m2b` |
| N − k | `mw:m2var` |
| loi binomiale de Mack 1997 | `mw:m3caldiag` |
| Bonferroni | `mw:m4gr` |

## 5. Tableau « Robustesse du calibrage »

`table_robustesse()` (`R/display_helpers.R`, 2361) retient les groupes de clé ROB (préfixe « G. ») et M6 *(vérifié)*. Il affiche donc :
- **Lognormale :**
  - G1 « Sensibilite au retrait d'une annee (jackknife) » ;
  - G2 « Largeur relative de l'IC bootstrap 90% » ;
  - G3 « Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime) » ;
  - G4 « Rapport de vraisemblance : delta = 0 (variance lineaire en volume) » ;
  - G5 « Rapport de vraisemblance : delta = 1 (variance quadratique en volume) ».
- **Merz-Wüthrich :**
  - M6-1 « Extrapolation de sigma pour la derniere annee de developpement » ;
  - M6-2 « Part de la reserve portee par la derniere annee d'accident ».

Le gabarit est appliqué à ces sept lignes dans toutes leurs branches (§ 4). Aucune mention de régime ne s'y applique. « Position de delta dans [0,1] » appartient à la famille C. et n'est pas dans ce tableau *(vérifié)* ; elle est révisée au gabarit (U16).

## 6. Valeurs qui quittent le `detail`

| Valeur | Ailleurs dans l'objet | Statut |
|---|---|---|
| Rangs de Cook ; compte des leviers | `res$plots_data$influence` (`influent`, `fort_levier`, `cook`, `levier`) *(vérifié)* | disponible |
| Années du jackknife au-delà de 3 | `res$plots_data$influence$plus_influente` et `$non_evaluable` *(vérifié)* | disponible |
| p bilatérale de Pitman | `res$metadata$permutation_pente` | disponible |
| p_bas et p_haut du TOST | absentes (seule la borne max est dans `p_asymptotique`) | **perte**, recalculables par `test_tost_intercept()` |
| Rangs de Rosner, base z | z dans `res$plots_data$influence$z` | **perte**, `test_rosner(z, alpha)` |
| Rangs de Rosner, résidus de Mack | `res$residus$residu` (ordre supposé identique, *hypothèse*) | **perte**, `test_rosner()` |
| CV, R, e_a par colonne | CV moyen dans `estim` | **perte**, `mw_identifiabilite_intra(res$ajustement, jd)` |
| Diagonales (n, L, S, Z, P) | nombre dans `estim` | **perte**, `mw_calendrier_diagonales(mw_test_annees_calendaires(res$ajustement, jd))` |
| Localisation de la cellule du minimum | t dans `estim`, DFBETAS et levier dans `res$plots_data$influence` | **perte**, *hypothèse* : t = DFBETAS × √((1 − h)/h) |
| Sensibilité de la MSEP en M6 | √`res$msep$msep` (valeur de la règle) | **perte**, `mw_sensibilite_sigma2_dernier(res$ajustement)` |
| Nombre de cellules et de colonnes de M2 | géométrie du triangle | **perte**, `mw_test_heteroscedasticite_intra()` |

`jd` se recalcule par `.mw_colonnes_degenerees(res$ajustement)`.

## 7. Mesure

**Méthode.** Pires substitutions plausibles : alpha = 0.001 ; c_pct à 5 chiffres ; N_t à 4 chiffres ; 6 clés de famille ; `ecart_tol` à deux termes ; sigma2 en notation scientifique ; plus de 3 années. Scripts :
- `/tmp/claude-0/-home-user-outil-usp/6f582a72-0d32-4388-bb3a-67d581150025/scratchpad/cibles5.R`
- `/tmp/claude-0/-home-user-outil-usp/6f582a72-0d32-4388-bb3a-67d581150025/scratchpad/c6.R`
- `/tmp/claude-0/-home-user-outil-usp/6f582a72-0d32-4388-bb3a-67d581150025/scratchpad/m17.R`

**Résultats** *(vérifié)* :
- **Texte propre :** toujours 2 phrases au plus et sous 400 caractères. Les plus longs : U1 avec renvoi ≈ 385, identifiabilité 380, famille alpha 379, rapport de vraisemblance à volumes constants 378, extrapolation de σ dégénérée 378, variance unitaire en bande 366. Seuil minimal : 391 caractères.
- **Mentions de régime :** une phrase chacune. M17a 264, M18 224, M17b 214, M19 188, M20a 185, M23 163, M22 156, M21 environ 130, M20b 124 caractères.
- **`detail` entier, mentions comprises :** il peut dépasser 400 caractères, conformément à la décision Q-6. Pire cas plausible : « Tendance par signes du ratio S/P » à π_t variable, en test inopérant (M5 + M17a + texte propre), environ 700 caractères et 4 phrases.

## 8. Contrôle mécanique

Nouveau fichier `tests/unitaires/test_detail_deux_phrases.R`. Constantes : `PLAFOND_TEXTE_PROPRE <- 400L`, `PHRASES_MAX <- 2L`. Aucun contrôle dans `add()`.

- **A0.** `compter_phrases()` sur chaînes fixes :
  - « a. b » → 2 ; « a ; b » → 2 ; « fin. » → 1 ; « » → 0 ;
  - « x (a ; b. C) y » → 1 ; « i.i.d. normal » → 1 ;
  - « p. 12 » → 1 ; « D6.49 » → 1 ; « T! appariements » → 1 ;
  - « famille B. font » → 2.
- **A1, mentions.** `MENTIONS` = liste (nom, expression, nombre de phrases).
  - **M1 à M16 :** expressions construites sur les constantes et les formats (comme dans la version amendée). Chaque expression reconnaît en entier un exemple produit par le moteur.
  - **M17a, M17b, M19, M20a, M20b, M21, M22 (et M23 si Q-8) :** recherche littérale de la constante (`grepl(cst, detail, fixed = TRUE)`).
  - **M18 :** expression R `"pi_t n'est constant qu'a la tolerance TOL_DELTA_BORD = [0-9.eE+-]+ pres \\([^()]+\\) : la loi exacte, etablie pour pi_t exactement constant, ne vaut ici qu'a un ecart de cet ordre pres\\."`.
  - Contrôle : chaque mention de régime fait exactement une phrase selon (P).
  - `texte_propre()` retire toutes les mentions, puis les séparateurs de bord.
- **A2, six références.** Pour chaque ligne :
  - `compter_phrases(texte_propre) <= 2` et `nchar(texte_propre) <= 400` ;
  - toute ligne de type test ou diagnostic a un texte propre non vide ;
  - `compter_phrases(detail) == compter_phrases(texte_propre) + somme des phrases des mentions présentes`.
  
  Garde contre une régression : l'ensemble des lignes à **plus de 2 phrases mentions comprises** vaut exactement ces 39 lignes :
  - **`premium`, `premium_ii6`, `premium_net`, `reserve1`** (δ = 1, π_t exactement constant *(vérifié)*), 5 lignes par cas, soit 20 :
    - « Independance ratio S/P vs volume » (M20a) ;
    - « Tendance monotone du ratio S/P » (M20a) ;
    - « Tendance par signes du ratio S/P » (M4 + M20a) ;
    - « Autocorrelation d'ordre 1 (Durbin-Watson) » (M20a) ;
    - « Test des suites (aleatoire des signes) » (M20a + M6).
  - **`premium_interieur`** (δ = 0,664, π_t variable *(vérifié)*), 17 lignes :
    - « Independance ratio S/P vs volume », « Tendance monotone du ratio S/P », « Autocorrelation d'ordre 1 (Durbin-Watson) » (M17a) ;
    - « Tendance par signes du ratio S/P » (M5 + M17a) ;
    - « Test des suites (aleatoire des signes) » (M17a + M6) ;
    - « Test des suites sur ratios bruts » (M17a + M6) ;
    - « Correlation ratio S/P vs temps », « Egalite des lois petits vs gros volumes (2 ech.) » (M17b) ;
    - « Shapiro-Wilk sur residus standardises », « Shapiro-Francia », « Anderson-Darling », « Cramer-von Mises », « Kolmogorov-Smirnov contre N(0,1) », « Lilliefors (KS a parametres estimes) », « Jarque-Bera », « Asymetrie (D'Agostino, T >= 8) » (M19) ;
    - « Valeur aberrante isolee (Grubbs) » (M11).
  - **`reserve2`**, 2 lignes : « Absence de tendance des facteurs avec le cumul, a colonne donnee » et « Nullite de l'ordonnee a l'origine, colonne par colonne » (M11).
  
  Cet ensemble est établi à la main d'après les conditions de pose et les références (*hypothèse* à confirmer à la première exécution ; un écart révèle une condition de pose mal codée ou une mention oubliée). Si Q-8 retient M23, il faut ajouter les lignes à p Monte-Carlo retenue de `premium_interieur` (22 selon `nature_p`).
- **A3, renvois.** Chaque libellé cité entre `\"…\"` est un libellé existant de la même méthode, ou le préfixe « Rapport de vraisemblance : delta = ... ».
- **A4, branches rares.** `verifier_detail(lignes, contexte)` est ajoutée à `tests/unitaires/outils_unitaires.R`. Elle contrôle le texte propre et la forme d'une phrase de chaque mention présente. Elle est appelée sur les objets de `test_volumes_constants.R`, `test_regimes_p_exactes.R`, `test_ex_aequo.R`, `test_inoperance.R`, `test_plancher_mc.R`, `test_sans_repli_p_non_simulee.R`, `test_lr_delta.R`, `test_p_famille.R`, `test_b_effectif_mw.R`, `test_retirage_mw.R`, `test_origine_non_identifiable.R`, `test_m5_diagnostic.R` et `test_verdict_sensible_mc.R`. Les scénarios manquants vont dans le nouveau fichier. Couverture :
  - S1 volumes constants (M20b) ; S2 pertes constantes ;
  - S3 bande de tolérance à deux termes (M18) ;
  - S4 δ intérieur (M17a, M17b, M19) ; S5 δ au bord bas avec π_t variable ;
  - S6 T = 10 (M21, M22, plancher de Pitman) ; S7 T = 5 ;
  - S8 ex aequo ; S9 partition de Smirnov ;
  - S10 les deux branches de R1 ; S11 « ECHEC possible » ;
  - S12 p Monte-Carlo indisponible (trois classes de motif) ;
  - S13 TOST en R14 et de type test ;
  - S14 rapport de vraisemblance : borne en échec, motif Monte-Carlo, volumes constants, solution au bord ;
  - S15 jackknife dans ses six formes ;
  - S16 familles T-3a et T-3b ;
  - S17 exclusions M1 ;
  - S18 B effectif < B, cumuls retirés, plafond ;
  - S19 un résidu par année de survenance ;
  - S20 identifiabilité sans colonne retenue ;
  - S21 M6 (J-2, J-3, les deux, quotient NA, non applicable) ;
  - S22 les cinq branches de Runsr.
  
  Test de pose : M20a absente des lignes R15 et des diagnostics par décision ; M17b présente seulement sur les deux diagnostics par décision du groupe R7.
- **A5, contrôle de source.** Aucun `detail` ne contient :
  - « rangs », « residus declares », « Valeurs : j = », « k = 1 (», « Sensibilite indicative » ;
  - les anciens textes « loi de reference exacte seulement a pi_t constant » et « que z = P epsilon ne verifie pas » ;
  - `PHRASE_RENVOI_NATURE_P`.

## 9. Effets

- **Résultats.** Aucun σ_USP, p-value, `p_min`, verdict, type ni `inoperant` ne change. Les champs `loi` sont inchangés. Le moteur ne lit le `detail` qu'à trois endroits, tous inchangés dans leur comportement : `grepl(motif_boot, detail)` dans `add()`, `endsWith` de `.usp_poser_renvois()`, et `endsWith(PHRASE_VERDICT_SENSIBLE_MC)` à l'affichage.
- **Références.** Patch chirurgical des six cas sur `tests[[i]]$detail` seul (`tests/patcher_reference.R`, puis `comparer_references.R --deux-parts` avec une partie numérique vide, puis `test_reproductibilite.R`). Aucun visa de σ_USP ni de verdict. Le libellé est validé par `actuary`.
- **Tests à mettre à jour.** `test_inoperance.R`, `test_regimes_p_exactes.R` et `test_textes_inconditionnels.R` (textes de régime réécrits en M17 à M21, pose par régime conservée) ; `test_merz_wuthrich_suite.R`, `test_merz_wuthrich.R`, `test_verdict_sensible_mc.R`, `test_defauts_connus.R`, `test_rapport_html.R` (tableau de robustesse), `test_plancher_mc.R`, `test_b_effectif_mw.R`, `test_p_famille.R`, `test_sans_repli_p_non_simulee.R`, `test_lr_delta.R`, `test_ex_aequo.R`, `test_retirage_mw.R`, `test_constante_ponderee.R`, `test_forme_close_m1.R`, `test_volumes_constants.R`, `test_origine_non_identifiable.R`, `test_m5_diagnostic.R`, `test_jonction_detail.R`.
- **Concordance.** « CONTROLE SANS OBJET ICI » est conservé sur les cinq lignes de la règle R15. Relancer en `--strict`.
- **`docwriter`.**
  - Réécrire la règle R8 (`sec:base-residus`, 8251-8252) : le commentaire suit toujours le régime, désormais par les mentions M17 à M21, en tête du `detail`, hors compte.
  - Remplacer les citations littérales : 3474, 3533, 3562, 5755, 5801, 5948-5949, 5995, 8233 ; `fiche:breusch-pagan-koenker` ; `sec:lecture-conjointe` ; `mw:m1id`.
  - Mettre à jour les fiches du § 6.
  - Décrire le gabarit « usage + tests liés + mentions conditionnelles » dans les conventions de restitution.

## 10. Questions au mainteneur

- **Q-8. M23 : p de Monte-Carlo conditionnelle au régime intérieur de δ.**
  - À δ̂ intérieur, la p-value de Monte-Carlo est conditionnelle au régime (#240, variante V3b). Le champ `nature_p` le dit déjà en clair : « Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime) ».
  - Poser M23 ajouterait une phrase à environ 22 lignes de `premium_interieur`.
  - Recommandation : **ne pas poser M23**. La raison est déjà nommée dans le champ, et la répéter noierait les mentions qui changent la lecture (M17 à M20).
  - Si le mainteneur la veut, son texte est prêt au § 2 et l'ensemble d'exceptions de A2 s'étend en conséquence.

## Retour

- **Statut : complet**, sous réserve de Q-8.
- **Résultat :** spécification finale intégrant Q-6 (mentions de régime M17 à M22, pédagogiques, hors compte, avec M20 pour le cas δ au bord) et Q-7, avec les tests A0 à A5 mis à jour.
- **Preuves.**
  - *Vérifié :* mesures des textes propres et des mentions ; δ et `variante` des six cas ; lignes à p exacte attribuée ; règle des verdicts ; filtre de `table_robustesse()` ; champs disponibles dans l'objet ; ancres à `bcc4997`.
  - *Hypothèse :* ensemble des 39 lignes de A2 (calculé à la main) ; ordre de `res$residus` ; formule de recalcul du t de la cellule.
  - *Non vérifié :* motifs « non applicable » des fonctions `mw_*` un à un (A4 les attrape).
- **Critères déclenchés :**
  - textes arrêtés antérieurement remplacés (R8/#70, section 5.3 de Fh/#302, #214, Rosner M4, renvois de #215) ;
  - perte de valeurs stockées (§ 6) ;
  - changement non numérique des six références.
- **Prochaine action recommandée :** obtenir Q-8, verser ce document, puis `coder-approfondi` sur ces textes, ensuite `audit`, `app-review` (vue Détail, tableau de robustesse, rapport figé), `docwriter`, et validation finale par `actuary`.
