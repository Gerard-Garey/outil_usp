# Spécification de l'issue #514 : `detail` des lignes de test limité à deux phrases et 400 caractères

> *Rapport de l'agent `actuary-approfondi` (fiche de jugement, Opus, effort `high`), version amendée après les décisions du mainteneur du 09/11/2026 ; reproduit intégralement par la session principale (IA). Dépôt lu à `8be6e3b` puis `54fd80a`. Les décisions Q-4 (seuil confirmé à 400) et Q-5 (années du jackknife) ont été prises par le mainteneur après la remise de ce rapport : voir la synthèse `../20261109-detail-deux-phrases.md`.*

**Ce que la spécification produit :**
- **Phrases.** Le texte propre de chaque ligne compte au plus 2 phrases, dans toute branche.
- **Longueur.** Le texte propre fait au plus 400 caractères. Tous les textes cibles tiennent, y compris dans les combinaisons de branches les plus longues : le maximum mesuré est de 392 caractères.
- **Mentions conditionnelles.** Elles sont hors compte pour les phrases comme pour les caractères. Sept d'entre elles sont ramenées à une phrase par le changement de séparateur « ` ; `» en «`, `».
- **Énumérations numériques.** Celles visées par Q-3 sortent du `detail`. Quatre familles de valeurs disparaissent alors de l'objet résultat ; elles restent recalculables par la fonction nommée de la ligne (§ 4). C'est une perte à signaler au mainteneur et à `docwriter`.
- **Effet sur les résultats.** Aucun σ_USP, aucune p-value, aucun verdict ne change. Seul `tests[[i]]$detail` change, d'où un patch chirurgical des six références.

**Numéros de ligne :** ceux de `git show 54fd80a:R/engine.R`. Le code bouge (#513) : retrouver chaque site par son ancre textuelle.

---

## 0. Décisions intégrées (09/11/2026)

- **Q-1.** Règle de comptage (P) ; texte propre de deux phrases au plus ; mentions M1 à M16 hors compte.
- **Q-2.** Le séparateur « ` ; `» devient «`, `» dans M3, M4, M5, M7, M8, M9, M14 et T-3b.
- **Q-3.** Retrait du `detail` des énumérations numériques suivantes : valeurs par colonne de l'identifiabilité (W6), diagonales de Mack 1997 (W11), sensibilité de la MSEP en M6 (W18), rangs de Rosner (U26, W15), cellule du minimum (W14), rangs de Cook (U27).
- **Q-4.** Plafond dur de 400 caractères sur le texte propre (confirmé par le mainteneur).
- **Q-5.** Jackknife (U35) : années citées jusqu'à 3, leur seul nombre au-delà (décision du mainteneur, après ce rapport).

## 1. Règles

**(P) Fins de phrase.** Une fin de phrase est :
- un « . » suivi d'une espace puis d'un caractère non blanc, quelle que soit sa casse ;
- ou un « ; » suivi d'une espace ;

à profondeur nulle de parenthèses et de crochets. Le « . » ne compte pas s'il suit un mot de `.ABREV_FIN_PHRASE` (liste recopiée dans le test) ou une lettre isolée précédée d'un « . » (« i.i.d. »). « ! » et « ? » ne comptent pas : dans le moteur, ils ne servent qu'aux factorielles (« T! »). Le nombre de phrases est le nombre de fins + 1 ; un texte vide ou NA compte 0.

Pourquoi pas `.fins_de_phrase()` telle quelle : elle exige une majuscule après le point. Or #264 interdit la majuscule après une jonction. Elle ignore donc les fragments joints, alors que ce sont précisément les fragments empilés.

**(L1) Texte propre.** Le `detail` privé de ses mentions conditionnelles (§ 2) ; les « ` ; `» et espaces qui restent en bord sont retirés. Il fait au plus 2 phrases et au plus `PLAFOND_TEXTE_PROPRE = 400` caractères, dans toute branche.

**(L2) Mentions conditionnelles.** Elles sont listées au § 2 et hors compte.

**Contraintes de construction :**
- `.engine_joindre()` est inchangée.
- Les parenthèses s'insèrent **à la source** : base écrite sans point final, puis `paste0(base, " (", fragment, ").")`. Aucun nouveau `grepl` ni `sub` sur `"\\.$"` (contrôle J3 de `test_jonction_detail.R`).
- Chaînes ASCII sans accents.
- Aucun nombre issu du bootstrap (règle #76). L'exception bornée de #204 reste en M13.
- `PHRASE_RENVOI_NATURE_P` et `PHRASE_VERDICT_SENSIBLE_MC` sont inchangées.
- Le jeton « CONTROLE SANS OBJET ICI » est conservé sur les cinq lignes de la règle R15 (lu par la concordance).

**Mesure de départ** (règle (P), références à 8be6e3b, `LC_ALL=C.UTF-8`) *(vérifié)* :
- `premium`, `premium_ii6`, `premium_net`, `reserve1` : 31 lignes sur 53 dépassent deux phrases (max 7) ;
- `premium_interieur` : 30 sur 53 ;
- `reserve2` : 18 sur 25 (max 10) ;
- 1 130 caractères au plus.

**Mesure de la cible** *(vérifié par scripts de la session, non versés)* avec les pires substitutions plausibles (`ecart_tol` le plus long, alpha = 0.001, c_pct à 5 chiffres, N_t à 4 chiffres, préfixes de régime cumulés) :
- toutes les cibles font au plus 2 phrases ;
- les plus longues sont U24 en bande de tolérance (392), U3 permutations aléatoires (≈ 388), U18 (388), U31 (≈ 387), U2 en R14 (386), U1 (384), U32 (≈ 382), Runsr branche 1b (≈ 381).

**Seuil minimal :** 392 caractères suffiraient ; 400 laisse une marge de 8. Aucun texte ne perd d'information nécessaire à la lecture du verdict.

## 2. Mentions conditionnelles, hors compte

| Mention | Ligne | Traitement |
|---|---|---|
| M1 `.prefixe_motif_mc()` et complément | 4096, 4484, 4488 | inchangée |
| M2 « `<motif>` : test non applicable. » | 4491 | inchangée |
| M3 « Monte-Carlo indisponible : `<motif>`, `<libelle>` non retenue. » | 4499 | réécrite |
| M4 « TEST INOPERANT au seuil alpha = %g : %s = %.4f%s, aucun verdict. » | 4598 | réécrite |
| M5 « TEST INOPERANT au seuil alpha = %g : plus petite p-value Monte-Carlo atteignable sur ces replications >= alpha%s, aucun verdict. » | 4584-4587 | réécrite |
| M6 « ECHEC inatteignable … » (deux formes) | 4589-4591, 4607 | inchangée |
| M7 « p_min de la loi de reference echangeable = … , mais la p-value Monte-Carlo retenue, … : ECHEC possible » | 4608-4613 | réécrite |
| M8 chaînes `effectifs` jointes par `add()` (4622) | `eff_rangs` 5641-5648, `eff_sm_ea` 6324, `.mw_p_min_ligne` 11604-11643 | réécrite (« ` ; `» → «`, `»), cf. § 3 |
| M9 `pre_mc` = « Monte-Carlo indisponible : `<motif>`, » devant « aucune p-value disponible sur ces donnees : aucun verdict. » | 4629-4633 | réécrite |
| M10 plancher Monte-Carlo | 4664-4675 | inchangée |
| M11 `PHRASE_VERDICT_SENSIBLE_MC` | 4273, 4700 | inchangée |
| M12 `PHRASE_MW_CUMULS_RETIRES`, `PHRASE_MW_PLAFOND_CUMULS` | 12170-12176 | inchangée |
| M13 `.mw_phrase_b_effectif()` (#204/#279) | 12126-12159 | inchangée |
| M14 `.mw_phrase_colonnes_ecartees()` | 10771-10786 | réécrite (texte ci-dessous) |
| M15 T-3a / T-3b | 4804 / 4810 | T-3a inchangée ; T-3b : « p de famille non calculee : replications completes insuffisantes (B_effectif < B_MIN_DEGENERESCENCE = %d), aucune p-value. » |
| M16 motif Monte-Carlo des lignes de rapport de vraisemblance (« `<motif>` : aucune p-value Monte-Carlo. » + complément) | 7286-7288 | inchangée |

**Texte de M14 :** `sprintf("%s : %s, %s, %s hors de la combinaison de Fisher%s, exclusion qui ne vaut pas preuve %s.", sujet, liste, quoi, "colonne"/"colonnes", clause_K)`. La clause vaut `clause_K = ", K = %d colonne(s) testee(s) sur %d eligible(s)"`, ou rien si K est NA.

## 3. Textes cibles (texte propre)

**Fragments partagés de `usp_tests()`**
- **`txt_pi_variable` (5537).** « p exacte non attribuee : loi de reference exacte a pi_t constant seulement (z non echangeable, r_t non identiquement distribues). »
- **`txt_bande` (5540).** `sprintf("loi exacte a un ecart pres, pi_t n'etant constant qu'a TOL_DELTA_BORD = %g pres : %s", TOL_DELTA_BORD, ecart_tol)`. Inséré en parenthèse par `detail_r7()`, ou employé seul comme phrase si le détail est vide.
- **`detail_r7(detail, p_ex)` (5550).** Le détail est reçu sans ponctuation finale.
  - π_t variable : `joindre(txt_pi_variable, paste0(detail, "."))`.
  - Bande de tolérance avec `p_ex` finie : `paste0(detail, " (", txt_bande, ").")`.
  - Sinon : `paste0(detail, ".")`.
  - Un détail vide reste vide (ou se réduit à `txt_bande` seul dans la bande).
- **`txt_edgeworth` (5656).** « T > 9 : Edgeworth, non loi exacte ». `detail_spearman()` (5666) l'ajoute en parenthèse à la base.
- **`eff_rangs` (5641).** Avec ex aequo : `sprintf("T = %d, ex aequo %s : loi conditionnelle non tabulee, p_min et p exacte non attribuees", T, quoi)`. Sans ex aequo : inchangé.
- **`detail_diag(nm, detail, raison, regle, motif_ea)` (5613).** Rend `joindre(detail, paste0("Diagnostic par decision, sans verdict ni p-value retenue", si motif_ea non vide " (" motif_ea ")", " : ", raison, "."))`. Les phrases `txt_diag_*` sont remplacées par les raisons ci-dessous.
- **`txt_h3_pi_variable` (6405).** « p non simulee etablie pour un echantillon i.i.d. normal, que z n'est pas a pi_t variable : restituee pour information, jamais retenue. »
- **`note_r` (6911).** « CONTROLE SANS OBJET ICI : pi_t constant (delta = 1, ou volumes x_t constants), aucun artefact de ponderation a detecter, quasi-doublon de la ligne homologue sur residus standardises. »
- **`detail_r(txt)` (6917).** Devient `if (nzchar(note_r)) note_r else txt`. À π_t constant, la phrase descriptive de supFr et Grubbsr est omise (présente dans `fiche:sup-f-ratios-bruts`, rubrique Usage *(vérifié)*, et dans `fiche:grubbs-ratios-bruts` *(vérifié par mot-clé)*).
- **`txt_r15` (6931).** « Diagnostic (regle R15), sans verdict ni p-value retenue : la ligne homologue sur residus standardises fait foi. »
- **`txt_mc_indispo` (5572).** Inchangé.

**USP, famille B**
- **U1 Constante** (5697-5740, renvoi 14449).
  - Avec seuil : `sprintf("Le non-rejet ne prouve pas la proportionnalite (voir le TOST), et le seuil de rejet de Student, approche, est |a| >= t(1-alpha/2, T-2) x se(a) = %.0f %% de la moyenne de y (seuil que la p Monte-Carlo retenue n'a pas exactement).", c_pct)`.
  - Sans seuil : « Le non-rejet ne prouve pas la proportionnalite : voir le TOST. »
  - `USP_TXT_RENVOI_CST` : « pi_t constant : une constante non nulle rend le ratio S/P monotone en x_t, alternative aussi visee, sans specificite, par la ligne Spearman ratio / volume. »
  - Retiré : « au seuil alpha = %g » (alpha reste dans la formule et dans `res$metadata`), « E[r_t] = b + a/x_t » et « l'alternative de Spearman est plus large que a != 0 » (dans `fiche:student-constante`, *vérifié par mot-clé*).
- **U2 TOST** (5821-5848).
  - Règle R14 : `sprintf("EQUIVALENCE NON DEMONTRABLE AVEC CES DONNEES au seuil alpha = %g, aucun verdict : t(1-alpha, T-2) x se(a) / Delta = %.2f >= 1, donc p >= p_plancher = %.3f >= alpha quelle que soit la constante estimee (OK inatteignable%s). Absence de preuve, non ecart a la proportionnalite : p du TOST non retenue (p_bas = %.4f, p_haut = %.4f).", ...)`. Le %s vaut `sprintf(", et meme ALERTE inatteignable : p_plancher >= %g", SEUIL_ECHEC_SENS_REJETER)` ou rien.
  - Ligne de type test : `sprintf("Rejeter H0 fournit une preuve POSITIVE de proportionnalite (condition necessaire remplie : t(1-alpha, T-2) x se(a) / Delta = %.2f < 1). Delta = %s (estimation \"marge Delta\"), p_bas = %.4f, p_haut = %.4f.", ...)`.
  - Retiré en R14 : la valeur de Delta (dans `estim`) et la loi de la p (champs `loi` et `nature`). « Plan de volumes, dispersion » est dans `fiche:tost-constante` *(vérifié)*.
- **U3 Pitman** (5880-5986).
  - Énumération, phrase 1 : « Ici on souhaite REJETER H0 : p exacte par enumeration des T! appariements, hors modele reglementaire, un rejet pouvant aussi venir d'une dispersion liee au volume ou d'une tendance commune a x et y. »
  - Énumération, phrase 2 : `sprintf("Non retenues : p bilaterale de permutation = %.4f et p de Student (non etablie a T = 8)%s.", p_bil, puis)`.
  - Permutations aléatoires, phrase 1 : `sprintf("Ici on souhaite REJETER H0 : p Monte-Carlo de B permutations aleatoires, hors modele reglementaire%s, un rejet pouvant aussi venir d'une dispersion liee au volume ou d'une tendance commune a x et y.", pl)`, avec `pl = sprintf(" (plancher 1/(B + 1) >= alpha = %g : OK inatteignable)", alpha)` sous la condition actuelle, sinon rien.
  - Permutations aléatoires, phrase 2 : `sprintf("Non retenues : p bilaterale (non imprimee) et p de Student (non etablie a T = 8)%s.", puis)`.
  - `puis` vaut `sprintf(", puissance approchee a posteriori = %.2f (lambda = %.2f) en contexte de lecture", ...)` si t_b > 0, « , puissance non restituee (lien observe nul ou negatif) » si t_b <= 0, rien si la puissance n'est pas finie.
  - Retiré : la formule (1 + k)/(B + 1), le théorème central limite combinatoire, « mauvaise en queue, sous p_min », la définition de lambda (dans `fiche:student-pente`, *vérifié par mot-clé* ; `docwriter` confirme « sous p_min »).
- **U4 Student** (5997) : « Diagnostic sans verdict, la pente etant testee par le seul test de Pitman : p de Student t(T-2) bilaterale, exacte sous le modele auxiliaire MCO seulement (non reglementaire), restituee pour information, non retenue. Egale a la p de la ligne "Test de Fisher (significativite globale)" (F = t^2). »
- **U5 Fisher** (6039) : « Diagnostic sans verdict, redondant avec le test de Pitman (F = t^2) : p de Fisher F(1,T-2) bilaterale sous le modele auxiliaire MCO, pour information, non retenue. Egale a la p de la ligne "Test de Student sur la pente (modele auxiliaire MCO)". »
- **U6 R2** (6054) : `sprintf("R2 ajuste = %.4f, sous H0 (b = 0) E[R2] = 1/(T-1) = %.3f, %s du repere conventionnel R2 < 0.5. Diagnostic, pas un test.", ..., "en dessous"/"au-dessus")`.
- **U7 RESET** (6071-6085).
  - Phrase 1 : « La loi F(2,T-3) n'est pas exacte sous le modele de l'annexe XVII (erreur multiplicative lognormale, asymetrique et heteroscedastique). »
  - Phrase 2 : « La p Monte-Carlo, simulee sous le modele ajuste, est calculee, et » + `PHRASE_RENVOI_NATURE_P` + « . » ; indisponible : « La p Monte-Carlo, simulee sous le modele ajuste, est indisponible sur ces donnees : aucune p-value n'est retenue. »
  - Milliken-Graybill retiré (dans `fiche:reset`, *vérifié*).
- **U8 Spearman ratio / volume** (6103-6106, `txt_pertes_cst_sv` 5495, renvoi 14456).
  - Base : « Une correlation signale un effet d'echelle non modelise ».
  - Pertes constantes : la base est **remplacée** par « Pertes y_t constantes a TOL_DELTA_BORD pres (voir l'avertissement sur les donnees) : le ratio varie en sens inverse du volume, et un rejet traduit des pertes non proportionnelles au volume ».
  - `USP_TXT_RENVOI_SV` : « pi_t constant : p exacte sous le modele restreint delta = 1 seulement, et une constante non nulle est une alternative non specifique de ce test (ligne Nullite de la constante). »
  - Pires cas : 385 et 376 caractères. Le renvoi est exclu à pertes constantes (`usp_renvois`, *vérifié*).
- **U9 Spearman ratio / temps** (6134-6152). Raison : « meme alternative que la ligne Mann-Kendall, qui fait foi » ; `motif_ea` = `txt_edgeworth` (si T > 9) et `eff_rangs` (si ex aequo), joints par « , ». Pire cas : 379.
- **U10 Mann-Kendall** (6165) : base inchangée, sans point final.
- **U11 Cox-Stuart** (6176-6183). Branche avec ex aequo : `sprintf("m = %d differences non nulles sur n_p = %d paires, p_mc non calculee (replications sans ex aequo)", ...)`. Autres branches inchangées.

**USP, famille C**
- **U12 Breusch-Pagan studentisé (Koenker)** (6227-6253).
  - Calculé : `sprintf("Doit etre non significatif si la ponderation pi_t est correcte, mais un OK ne demontre pas la structure de variance : puissance maximale, au seuil alpha = %g, d'un test invariant de delta = 1 contre delta = 0 ou de delta = 0 contre delta = 1 = %.2f avec ces volumes.", ...)`.
  - Échec numérique : « … mais un OK ne demontre pas la structure de variance : puissance maximale d'un test invariant de delta = 1 contre delta = 0 ou de delta = 0 contre delta = 1 non calculee avec ces volumes (echec numerique, usp_puissance_enveloppe_h2()). »
  - Calcul non tenté : la première proposition seule, terminée par un point.
  - Retiré : « faibles coefficients de variation » (`.tex` l. 9827, *vérifié*).
- **U13 Breusch-Pagan 1979** (6267). Base : « Version publiee (facteur 1/2 issu de Var(u^2) = 2 sigma^4), NON ROBUSTE : sur-rejette si les erreurs ne sont pas normales. » Raison H2 : « la structure de variance releve de la ligne Breusch-Pagan studentise (Koenker), qui fait foi ».
- **U14 White, Goldfeld-Quandt, Brown-Forsythe** (6282, 6293, 6303) : la phrase de diagnostic avec la raison H2.
- **U15 Smirnov** (6340-6357). Base supprimée. Raison : « compare la position de z entre petits et gros volumes (alternative de H1), les lignes de la famille B font foi ». Ne jamais écrire « B. » suivi d'une espace. `eff_sm_ea` : `sprintf("n1 = %d, n2 = %d, ex aequo dans z : p_min et p exacte non attribuees", ...)`. Retiré : « Voir aussi le QQ-plot » et la p minimale atteignable (champ `p_min`) ; « D = 1 » et le QQ-plot sont dans `fiche:smirnov` *(vérifié)*.

**USP, famille D**
- **U16 Anderson-Darling** (6461). Base : « Sensible aux queues, p non simulee par l'ajustement empirique de D'Agostino & Stephens (1986) sur la statistique re-standardisee. » `txt_plage` (6441) inchangé.
- **U17 Cramer-von Mises** (6477-6492). Raison : « W2 etant tres correlee a A2, la ligne Anderson-Darling fait foi ».
- **U18 Kolmogorov-Smirnov** (6480-6510). Base vide. Raison : « loi de Kolmogorov a parametres connus, conservatrice sur des residus standardises par le modele (tres conservatrice a T = 8 sur le jeu de controle, par simulation), la ligne Lilliefors fait foi » (constat C2 dans `fiche:kolmogorov-smirnov`, *vérifié*).
- **U19 Lilliefors** (6519). Base : « Loi de reference de Lilliefors, qui tient compte de l'estimation des parametres (la loi de Kolmogorov rendrait le test extremement conservateur). »
- **U20 Jarque-Bera** (6536) : inchangé.

**USP, famille E**
- **U21 Durbin-Watson** (6596). Base : « Statistique calculee sur residus centres, loi par integration numerique d'Imhof (bornes d_L/d_U des residus MCO non utilisees) ». Le mot « exacte » est retiré : il contredisait le préfixe R7 à π_t variable, et le champ `loi` dit EXACTE à π_t constant (retrait d'affirmation à signaler à `audit`).
- **U23 Centrage** (6715-6781). Chaque branche commence par « Grandeur rivee par l'estimation, aucune p-value retenue : ».
  - π_t exactement constant : « …a pi_t constant, moyenne(z) = 0 est une identite algebrique (ln(beta) en forme fermee). La valeur affichee n'est que du bruit d'arrondi et ne renseigne pas sur l'arret de l'optimiseur. »
  - Bande de tolérance : `sprintf("…pi_t n'etant constant qu'a TOL_DELTA_BORD = %g pres (%s), moyenne(z) n'est nulle qu'a un ecart de cet ordre pres. Cet ecart, proportionnel a (1 - delta) ou a l'etendue relative des volumes, ne renseigne pas sur la convergence en gamma.", TOL_DELTA_BORD, ecart_tol)`.
  - δ au bord : « …delta au bord de [0,1] sans pi_t constant, seule la contrainte ponderee somme(sqrt(pi_t) z_t) = 0 subsiste. La valeur affichee, non nulle, mesure l'ecart entre versions ponderee et non ponderee. »
  - δ intérieur : « …delta interieur a [0,1] et pi_t non constant, seule la contrainte ponderee somme(sqrt(pi_t) z_t) = 0 subsiste. La valeur affichee mesure l'ecart entre versions ponderee et non ponderee. »
- **U24 Variance unitaire.** Même premier membre.
  - π_t exactement constant : `sprintf("…a pi_t constant, var(z) = T/(T-1) suppose un optimum interieur en gamma (domaine %s) et tombe si gamma bute sur une borne. L'egalite ne tient qu'a la tolerance d'arret pres, et son ecart renseigne sur la convergence en gamma.", dom_gamma)`.
  - Bande de tolérance : `sprintf("…pi_t n'etant constant qu'a TOL_DELTA_BORD = %g pres (%s), var(z) = T/(T-1) suppose un optimum interieur en gamma (domaine %s). L'egalite ne tient qu'a la tolerance d'arret et a un ecart de cet ordre pres, et l'ecart renseigne sur la convergence en gamma sous ces reserves.", ...)` (pire cas : 392).
  - δ intérieur : « …delta interieur a [0,1] et pi_t non constant, seule subsiste la condition du premier ordre en gamma, qui ne fixe pas somme(z_t^2). L'ecart de var(z) a T/(T-1) n'a donc pas de valeur de reference. »
  - δ au bord : même texte avec « delta au bord de [0,1] sans pi_t constant ».
  - Retiré (U23, U24) : les dérivations du premier ordre (dans `fiche:centrage` et `fiche:variance-unitaire`, *vérifié par mot-clé*).
- **U28 Durbin-Watson et OLS-CUSUM sur ratios bruts ; supFr et Grubbsr à π_t constant** : `note_r` puis `txt_r15`.
- **U29 Suites sur ratios bruts** (6959-7046).
  - **Branche 1** : « CONTROLE SANS OBJET ICI : pi_t constant et signes de u et de z identiques, statistique et p exacte (doublement) egales a celles de la ligne sur z », puis en branche 1b `sprintf(" (a l'ecart de pi_t a la constance pres : TOL_DELTA_BORD = %g, %s)", ...)`, puis « . », puis `txt_r15`. En cas de dégénérescence, remplacer « statistique et p exacte (doublement) egales a celles de la ligne sur z » par « statistique egale a celle de la ligne sur z, p exacte ecartee par le motif de degenerescence en tete ».
  - **Branche 2**, π_t exactement constant : « CONTROLE SANS OBJET ICI : pi_t exactement constant, mais un signe au moins differe entre u et z par le traitement numerique (centrage de u, ex aequo), d'ou ni identite garantie ni loi combinatoire de R attribuee. »
  - **Branche 2**, bande : `sprintf("CONTROLE SANS OBJET ICI : pi_t constant a TOL_DELTA_BORD = %g pres seulement (%s), mais sa variation residuelle inverse un signe au moins entre u et z, d'ou ni identite garantie ni loi combinatoire de R attribuee.", ...)`. Puis `txt_r15`.
  - **Branche 2b** : « CONTROLE SANS OBJET ICI : pi_t constant, aucun artefact de ponderation a detecter, et loi combinatoire de R non definie (un seul cote de la mediane represente), donc sans p-value exacte. » Puis `txt_r15`.
  - **Branche 3** : « pi_t varie avec t : signes de u_t - med(u) non equiprobables sous le modele ajuste, loi combinatoire de R approximative, sans borne d'erreur connue a T = 8 (statistique en general differente de celle sur z). Seule la p-value Monte-Carlo, simulee sous le modele ajuste avec ses pi_t, est calculee, et » + `PHRASE_RENVOI_NATURE_P` + « . » Indisponible, seconde phrase : « La p-value Monte-Carlo, simulee sous le modele ajuste avec ses pi_t, est indisponible sur ces donnees : aucune p-value n'est retenue. »
  - Retiré : « r_t i.i.d. … », « p_mc estime la meme quantite », le détail de l'aplatissement des ex aequo (`docwriter` vérifie leur présence dans `fiche:suites-ratios-bruts`).

**USP, familles F et G**
- **U25 OLS-CUSUM** (6813-6817). Calculée : « La formule asymptotique n'a aucune validite a T = 8 : p_mc est calculee, et » + `PHRASE_RENVOI_NATURE_P` + « . » Indisponible : « La formule asymptotique n'a aucune validite a T = 8, et p_mc est indisponible sur ces donnees : aucune p-value n'est retenue. »
- **U26 Rosner, base z** (6854-6868 ; Q-3) : `sprintf("Diagnostic par decision, sans verdict ni p-value retenue : procedure ESD de Rosner (1983) a niveau nominal alpha = %g, nombre de valeurs declarees en estimation (valeurs critiques jugees adequates par l'auteur a partir de n = 25, niveau superieur a alpha a T = 8). La ligne Grubbs sur residus standardises fait foi pour une valeur aberrante isolee.", alpha)`.
- **U27 Cook** (`.usp_ligne_cook` 5387 ; Q-3) **et leviers** (7118). Cook : `sprintf("repere conventionnel 4/T = %.3f, %d observation(s) au-dessus", REPERE_COOK_LN / T, nb)`, sans les rangs. Leviers : `sprintf("repere conventionnel 2k/T = %.3f, %d observation(s) au-dessus", ...)`. Motif « non applicable » inchangé.
- **U30 IC bootstrap** (7211) : « Intervalle bootstrap de percentile du parametre retenu, niveau nominal 90 % (res$ic_bootstrap), et intervalle basic sur l'echelle logarithmique en regard (res$ic_bootstrap_basic_log). A T = 8, couverture inferieure au niveau nominal sous les modeles simules (constat de simulation, voir la documentation). »
- **U31 IC à δ fixé** (7232) : « Bootstrap parametrique a delta estime fixe (seul gamma reajuste, echecs ecartes : res$bootstrap$n_echec_restreint), bornes res$ic_bootstrap_restreint : incertitude conditionnelle a la structure de variance retenue. Couverture inferieure au niveau nominal a T = 8 en simulation, et non-convergence au bord d'Andrews (2000), etablie pour une moyenne contrainte, non demontree pour delta. » (dans `fiche:ic-bootstrap`, *vérifié*).
- **U32 Rapport de vraisemblance** (7246-7302).
  - Texte : `sprintf("Aucun verdict : le LR dit si les donnees distinguent cette borne de l'optimum, non si le modele est adequat (%s%s). p asymptotique (melange de Chernoff) pour memoire, non retenue (ecart mesure a T = 8).", lecture, ici)`.
  - `lecture` vaut « LR = 0 : borne atteinte, p_mc elevee : borne aussi defendable que delta estime, p_mc faible : borne moins compatible » si p_mc existe, sinon « LR = 0 : borne atteinte ».
  - `ici` vaut `sprintf(", ici SOLUTION AU BORD delta = %d : LR = 0 par construction", d0)`, ou « , ici VOLUMES CONSTANTS : LR nul par construction, delta non identifie », ou rien.
  - M16, s'il y a lieu, reste en tête ; branche « non applicable » (7279-7282) inchangée.
- **U33 / W20 p de famille** (`DETAIL_P_FAMILLE` 4772, assemblage 4914-4917) : `sprintf("Lecture conjointe minP en une etape des tests [%s] (cles mc_nom), sur les replications de leurs p Monte-Carlo, observe compris, p exacte retenue ou non. Diagnostic sans verdict, aucun verdict de ligne modifie : controle du taux d'erreur de la famille au sens faible sous le modele ajuste, p plug-in non exacte.", paste(cles, collapse = ", "))`. Seules les **clés** sont listées (chaque ligne membre porte la sienne dans `mc_nom`).
- **U34 p globale** (`DETAIL_P_GLOBALE` 4789) : `sprintf("Lecture conjointe minP en une etape des %d tests des familles, sur leurs p Monte-Carlo et non sur leurs p retenues (un verdict fonde sur une p exacte peut ne pas s'y retrouver, lignes de sens rejeter hors batterie). Diagnostic sans verdict, aucun verdict de ligne modifie : controle du taux d'erreur de la batterie au sens faible sous le modele ajuste, p plug-in non exacte.", k)`. Retiré (U33, U34) : « Hors famille : … », « comme les p Monte-Carlo des lignes », « situe la plus petite p … dependance » (composition dans `sec:lecture-conjointe`, *vérifié*).
- **U35 Jackknife** (7152-7191) : selon Q-5, années citées jusqu'à 3 (les plus influentes à égalité, les non évaluables), leur seul nombre au-delà ; elles restent dans `res$plots_data$influence` (`plus_influente`, `non_evaluable`, *vérifié*).
- **Inchangés :** position de δ ; Shapiro-Wilk, Shapiro-Francia, D'Agostino ; Anscombe-Glynn ; suites (z) ; sup-F ; Grubbs ; motifs « non applicable » (le plus long, `txt_pertes_cst_test`, environ 260 caractères).

**Merz-Wüthrich (`mw_tests()`, 12220)**
- **W1 Pente relative** (12275) : « Regression ponderee de F(i,j)/f_j sur (C(i,j) - Cbar_j)/Cbar_j, poids C(i,j) f_j^2/sigma_j^2, avec effets fixes d'annee de developpement : t de la pente commune b, elasticite du facteur au volume a colonne donnee. » (approximation -a_j/(f_j Cbar_j) dans `mw:m1`, *vérifié*).
- **W2 Ordonnée à l'origine** (12298) : « Regression ponderee avec constante, de poids 1/C(i,j), colonne par colonne : sans constante, son estimateur est exactement f_j (identite de Mack), d'ou le test naturel de la proportionnalite. » Exclusions en M14. `docwriter` vérifie « 1e-16 ».
- **W3 Homogénéité de f_j, W4 Courbure** : bases inchangées, exclusions en M14.
- **W5 Famille alpha** (12359-12372).
  - Statistique finie : `sprintf("alpha = 0, 1 et 2 (moyenne simple, chain-ladder du reglement, poids C(i,j)^2) : estimateurs sans biais pour f_j sous l'hypothese (iii) lue avec f_j commun (interpretation de l'outil), la ligne porte donc sur la proportionnalite des cumules (M1), non sur la variance (M2). Ecart relatif maximal = %.2f %% (colonne j = %d), seul f_j^(alpha = 1) entrant dans sigma_USP.", ...)`.
  - Statistique NA : « alpha = 0, 1 et 2 : moyenne simple des facteurs, chain-ladder du reglement et ponderation par le carre du volume. »
  - Lecture en covariance dans `mw:m1d` *(vérifié)*.
- **W6 Identifiabilité** (12389-12407 ; Q-3). « Diagnostic sans verdict : dispersion des cumuls a colonne donnee (colonnes n_j >= 3 hors colonnes degenerees), dont depend la puissance des lignes M1 (ordonnee a l'origine, pente relative) et M2 (exposant de variance). CV moyen des colonnes en estimation, valeurs par colonne (CV, R = max/min, e_a) rendues par mw_identifiabilite_intra(). » Aucune colonne retenue : « Diagnostic sans verdict : aucune colonne retenue (n_j >= 3 hors colonnes degenerees). »
- **W7 Hétéroscédasticité M2** (12434) : `sprintf("LM = n R^2 partiel de la regression des carres des residus de Mack redresses (variance 1 sous H0 a sigma_j connu) sur C(i,j), avec effets fixes de colonne (Frisch-Waugh) : seule la dependance au cumul a colonne donnee est testee. Colonnes n_j >= 3 seulement (a n_j = 2, |r~| = 1 identiquement) : %d cellules dans %d colonnes.", ...)`.
- **W8 Exposant de variance** (12488) : « Sous H0, les residus de Mack non redresses ont une variance 1 - h (h levier de la cellule) et ne sont pas echangeables dans la colonne. La p-value de Monte-Carlo (cle ExpVar), recalculee sur chaque replication, reproduit cet effet de levier, que la p chi2(2K) et la plus petite p-value atteignable, fondees sur une loi echangeable, ignorent. »
- **W9 Variance unitaire des résidus de Mack** (12517). `sprintf("Valeur de reference %s%s, var(r) etant contrainte par construction (somme_i r(i,j)^2 = n_j - 1, N - k = %d - %d = %d) : la ligne ne teste PAS la structure de variance (testee par les lignes M2). L'ecart a la reference vaut N moyenne(r)^2/(N-1) et donne a lire le CENTRAGE des residus, ici %s.", ...)`, variante k = 1 conservée. Retiré : la mesure ponctuelle « 2.5e-03 / 1e-15 » et « coherence interne de la standardisation » (dans `mw:m2var`, *vérifié*).
- **W11 Diagonales calendaires** (12560-12583 ; Q-3). `sprintf("Repere par diagonale de Mack (1997, D6, p. D6.49), sans controle de multiplicite ni verdict (le test est la ligne precedente) : P(Z_k <= z_k) exacte sous la loi binomiale independante de Mack, non sous le modele de Mack. Seule une diagonale d'au moins %d etiquettes peut descendre a %s %%, nombre de diagonales sous ce repere en estimation.", ...)`. Sans diagonale : inchangé.
- **W12 Kruskal-Wallis** (12607) : inchangé.
- **W13 Suites sur résidus de Mack** (12660-12678). Raison : « la ligne Autocorrelation des residus (Durbin-Watson), calculee sur les memes residus dans le meme ordre de parcours, fait foi » ; `ea_ru` devient la parenthèse de motif.
- **W14 Cellule aberrante** (12727-12740 ; Q-3) : `sprintf("M = min des p_ij = 2 F_Student(n_j - 2)(-|t(i,j)|), t(i,j) residu studentise externe (cellule retiree de l'estimation), sur les N_t = %d cellules des colonnes n_j >= %d hors colonnes degenerees, %d cellule(s) des colonnes n_j = 3 non couverte(s). Borne de Bonferroni min(1, N_t M), sous erreurs gaussiennes seulement : p non simulee jamais retenue a la place de la p Monte-Carlo.", ca$N_t, MW_NJ_MIN_CELLULE, n_nj3)` (« colonnes n_j <= 2 sans degre de liberte » dans `mw:m4gr`, *vérifié par mot-clé*).
- **W15 Rosner, résidus de Mack** (`PHRASE_MW_ROSNER_DIAGNOSTIC` 12183 et suite 12755-12761 ; Q-3), remplacées par `sprintf("Diagnostic sans verdict : procedure ESD generalisee de Rosner (1983) sur les residus de Mack, a alpha = %.2f, dont les valeurs critiques (eq. (2.5)) et le domaine (n >= 25) valent pour un echantillon i.i.d. normal que ces residus, contraints par colonne, ne sont pas. Le nombre de cellules declarees (estimation) se lit comme un repere, sans p-value.", alpha)`. Remplace un texte arrêté par le mainteneur (Q-D1-Fi-7) : signalé.
- **W16 Shapiro-Wilk, M5** (12787) : « Diagnostic sans verdict : la normalite n'est pas une hypothese du modele (annexe XVII, D(2)(h) : deux premiers moments). La loi nulle de W, celle d'un echantillon i.i.d. normal que les residus de Mack ne sont pas, rejette trop souvent sous erreurs gaussiennes (simulation sous un plan) : p-value pour information, utile seulement pour un quantile de la MSEP. »
- **W17 Lilliefors, M5** (12806) : « Diagnostic sans verdict : approximation de Dallal et Wilkinson de la loi de D sous echantillon i.i.d. normal, que les residus de Mack ne sont pas, qui rejette plus souvent que le seuil nominal sous erreurs gaussiennes (constat de simulation sous un plan). p-value restituee pour information. »
- **W18 Extrapolation de σ, M6** (`.mw_detail_extrapolation` 9425-9535, appel 12827 ; Q-3).
  - Phrase 1 : `sprintf("Valeur fixee par la regle de minimum de l'annexe XVII, D(5)(d)(ii), seconde ligne, non estimee : min(sigma2_(J-2) = %s, sigma2_(J-3) = %s, sigma2_(J-2)^2/sigma2_(J-3) = %s) = %s, atteint par %s.", ...)`. Quotient NA : « non defini (sigma2_(J-3) = 0) ». `retenus` vaut « sigma2_(J-2) et sigma2_(J-3) (ex aequo) » si J-2 et J-3 sont dégénérées, « sigma2_(J-2) (colonne J-2 degeneree, quotient non compte) » si J-2 seule l'est, sinon la règle actuelle.
  - Phrase 2, branches dégénérées seulement : « Colonnes J-3 et J-2 degenerees (facteurs egaux a f_j a 1e-12 pres) : voir l'avertissement sur les donnees. » (ou « Colonne J-3 degeneree … », « Colonne J-2 degeneree … »).
  - Branche non applicable inchangée. L'argument `sens` et la phrase de sensibilité sont supprimés de `.mw_detail_extrapolation()` ; `mw_sensibilite_sigma2_dernier()` reste ; `RAPPORT_MAX_ECART_MW` devient sans usage (retrait à trancher par `coder` et `audit`). Pire cas : 374.
- **W19 Part de la dernière année** (12839) : `sprintf("part = %.1f %% de la reserve totale : une part elevee concentre la MSEP sur la ligne la moins developpee du triangle, aux facteurs les plus extrapoles. Repere indicatif de 40 %%, sans fondement reglementaire ni statistique, qui n'emporte aucun verdict.", ...)`.

**Branches rares.** Tous les textes ci-dessus sont mesurés dans leur pire combinaison de régime. Les chaînes `non_applicable` des fonctions `mw_*`, `test_reset` et `test_white` n'ont pas été mesurées une à une : le test A3 les attrape ; elles se réécrivent selon les mêmes principes si besoin.

## 4. Valeurs retirées du `detail` (Q-3) : où les retrouver

| Valeur retirée | Ailleurs dans l'objet ? | Statut |
|---|---|---|
| Rangs de Cook (U27) | `res$plots_data$influence$influent` et `$cook`, même modèle et même repère *(vérifié par lecture)* | disponible |
| Leviers (U27, compte conservé) | `res$plots_data$influence$levier` et `$fort_levier` | disponible |
| Rangs de Rosner, base z (U26) | absents ; z dans `res$plots_data$influence$z`, nombre dans `estim` | **perte** ; recalculable par `test_rosner(z, alpha)` |
| Rangs de Rosner, résidus de Mack (W15) | absents ; résidus dans `res$residus$residu` (ordre identique à celui de `mw_tests()`, *hypothèse*), nombre dans `estim` | **perte** ; recalculable par `test_rosner(r, alpha)` |
| Identifiabilité par colonne : CV, R, e_a (W6) | absentes ; CV moyen dans `estim` | **perte** ; recalculable par `mw_identifiabilite_intra(res$ajustement, jd)` |
| Diagonales de Mack 1997 : n, L, S, Z, P (W11) | absentes ; nombre sous le repère dans `estim` | **perte** ; recalculable par `mw_calendrier_diagonales(mw_test_annees_calendaires(res$ajustement, jd))` |
| Cellule du minimum (i, j, n_j) (W14) | t de la cellule dans `estim` ; recalculable à partir de `res$plots_data$influence` (*hypothèse* : h = `levier`) | **perte** de la localisation stockée |
| Sensibilité de la MSEP en M6 (W18) | racine avec la règle = √`res$msep$msep` ; arguments du minimum dans le `detail` | **perte** des valeurs alternatives ; recalculables par `mw_sensibilite_sigma2_dernier(res$ajustement)` |
| Noms des tests membres de famille (U33/W20) | clé de chaque ligne dans `mc_nom` | disponible |

`jd` se recalcule par `.mw_colonnes_degenerees(res$ajustement)`. Pour `docwriter` : les fiches `mw:m1id`, `mw:m3caldiag`, `mw:m4gr`, `mw:m4ros`, `mw:m6sig`, `fiche:rosner-esd` et `fiche:cook` doivent dire où ces valeurs se trouvent désormais ou par quelle fonction on les recalcule, et retirer toute phrase du type « restitué dans le commentaire ».

## 5. Contrôle mécanique

Nouveau fichier `tests/unitaires/test_detail_deux_phrases.R`, découvert par le glob du lanceur. Constantes : `PLAFOND_TEXTE_PROPRE <- 400L`, `PHRASES_MAX <- 2L`. Aucun contrôle dans `add()` (pas d'arrêt à l'exécution sur des données d'utilisateur).

- **A0.** `compter_phrases()` selon (P) : « a. b » → 2 ; « a ; b » → 2 ; « fin. » → 1 ; « » → 0 ; « x (a ; b. C) y » → 1 ; « i.i.d. normal » → 1 ; « p. 12 » → 1 ; « D6.49 » → 1 ; « T! appariements » → 1.
- **A1.** `MENTIONS` (nom, expression régulière) pour M1 à M16, construite à partir des constantes du moteur et des formats ; chaque expression reconnaît en entier un exemple réellement produit ; les mentions réécrites font une phrase ; `texte_propre(detail)` retire les mentions puis les séparateurs en bord.
- **A2, six références**, pour chaque ligne : `compter_phrases(texte_propre) <= 2` et `nchar(texte_propre) <= 400` ; l'ensemble des lignes où `compter_phrases(detail) > 2`, mentions comprises, vaut exactement {`premium_interieur` × « Tendance par signes du ratio S/P », `premium_interieur` × « Test des suites sur ratios bruts »} ; longueurs maximales imprimées.
- **A3, branches rares.** `verifier_detail(lignes, contexte)` ajoutée à `tests/unitaires/outils_unitaires.R` (phrases et plafond), appelée sur les objets que construisent déjà `test_volumes_constants.R`, `test_regimes_p_exactes.R`, `test_ex_aequo.R`, `test_inoperance.R`, `test_plancher_mc.R`, `test_sans_repli_p_non_simulee.R`, `test_lr_delta.R`, `test_p_famille.R`, `test_b_effectif_mw.R`, `test_retirage_mw.R`, `test_origine_non_identifiable.R`, `test_m5_diagnostic.R` et `test_verdict_sensible_mc.R` ; scénarios manquants ajoutés au nouveau fichier. Couverture : S1 volumes constants ; S2 pertes constantes ; S3 bande de tolérance avec les deux termes de `ecart_tol` ; S4 δ intérieur ; S5 δ au bord avec π_t variable ; S6 T = 10 ; S7 T = 5 ; S8 ex aequo ; S9 partition de Smirnov non calculable ; S10 les deux branches de R1 ; S11 « ECHEC possible » ; S12 p Monte-Carlo indisponible ; S13 TOST (R14 avec et sans ALERTE inatteignable, type test) ; S14 rapport de vraisemblance ; S15 jackknife (sans année évaluable, σ nul, plus de 3 années) ; S16 T-3a et T-3b ; S17 colonnes dégénérée et non identifiable ; S18 B effectif < B, cumuls retirés, plafond ; S19 un résidu par année ; S20 identifiabilité sans colonne retenue ; S21 M6 (J-2, J-3, les deux, quotient NA, non applicable) ; S22 Runsr (branches 1, 1b, 1 dégénérée, 2 exacte, 2 tolérance, 2b, 3 avec et sans p Monte-Carlo).
- **A4.** Contrôle de source : `.mw_detail_extrapolation()` sans argument `sens` ; aucun `detail` ne contient « rangs », « residus declares », « Valeurs : j = », « k = 1 (» ni « Sensibilite indicative ».

## 6. Effets

- **Résultats.** Aucun σ_USP, p-value, `p_min`, verdict, type ni `inoperant` ne change. Le moteur ne lit le `detail` qu'à trois endroits, inchangés dans leur comportement : `add()` (`grepl(motif_boot, detail)`), `.usp_poser_renvois()` (`endsWith` sur les renvois), l'affichage (`endsWith(PHRASE_VERDICT_SENSIBLE_MC)`).
- **Références.** Seul `tests[[i]]$detail` change *(vérifié)*. Patch chirurgical des six cas (`tests/patcher_reference.R`), puis `comparer_references.R --deux-parts` (partie numérique vide) et `test_reproductibilite.R`. Aucun visa de σ_USP ni de verdict requis.
- **Tests unitaires à mettre à jour** : `test_inoperance.R` (≈118 assertions), `test_regimes_p_exactes.R` (≈92), `test_merz_wuthrich_suite.R` (≈54), `test_verdict_sensible_mc.R`, `test_defauts_connus.R`, `test_rapport_html.R`, `test_plancher_mc.R`, `test_merz_wuthrich.R`, `test_b_effectif_mw.R`, `test_p_famille.R`, `test_sans_repli_p_non_simulee.R`, `test_lr_delta.R`, `test_ex_aequo.R`, `test_retirage_mw.R`, `test_constante_ponderee.R`, `test_forme_close_m1.R`, `test_textes_inconditionnels.R`, `test_volumes_constants.R`, `test_origine_non_identifiable.R`, `test_m5_diagnostic.R`.
- **Concordance.** Seul le décompte « CONTROLE SANS OBJET ICI » est lu ; conservé. Relancer en `--strict`.
- **`docwriter` (fin de branche).** Remplacer les citations littérales de `detail` dans le `.tex` : lignes 3474, 3533, 3562, 5755 et 5801 (R1) ; 5948-5949 (R15) ; 5995 (diagnostic par décision) ; `fiche:breusch-pagan-koenker` ; citations de `DETAIL_P_FAMILLE` et `DETAIL_P_GLOBALE` (`sec:lecture-conjointe`) ; `mw:m1id` ; fiches du § 4. Vérifier la présence des contenus retirés marqués « à vérifier » : 1e-16 (W2), « sous p_min » (U3), Runsr (U29).

## Retour de l'agent

- **Statut : complet** (Q-4 et Q-5 tranchées ensuite par le mainteneur).
- *Vérifié :* comptage et longueur des cibles dans leurs pires substitutions ; mesure de départ ; numéros de ligne sur `54fd80a` ; contenu de `res$plots_data`, `res$jackknife`, `res$msep`, `res$residus` ; `usp_renvois` ; usages de `mw_sensibilite_sigma2_dernier` et `RAPPORT_MAX_ECART_MW`.
- *Hypothèse :* ordre de `res$residus` identique à celui de `mw_tests()` ; h = `levier` dans `mw_influence()` ; ensemble d'exceptions de A2 calculé à la main.
- *Non vérifié :* les chaînes non applicables des fonctions `mw_*` une à une ; le contenu exact des fiches au-delà des mots-clés.
- **Critères déclenchés :** changement de sortie non numérique (`detail` des six références) ; perte de valeurs stockées dans l'objet (§ 4), décidée par Q-3 ; remplacement de textes arrêtés antérieurement (R1, #181, Rosner MW Q-D1-Fi-7).
