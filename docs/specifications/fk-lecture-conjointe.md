# Spécification de Fk : lecture conjointe des tests, p-value de famille (#297), avec les points de fond de #331 — point d'arrêt D1-Fk

> **Décisions du mainteneur du 25/10/2026, vers 08:30 UTC (E-25/10 (D1-Fk)) : point d'arrêt D1-Fk franchi.**
>
> *Consignées par la session principale (IA)* ; source : réponses du mainteneur aux questions de la session principale. Le présent document reprend à la lettre la spécification D1-Fk d'`actuary-approfondi` du 24/10/2026 (lecture seule), versionnée avant décision dans `c369da0`.
>
> **Toutes les décisions suivent les recommandations d'`actuary-approfondi`** :
>
> - **Q-D1-Fk-1** : familles B. à F. et M1 à M4 ; aucune ligne pour G., M5 et M6. Membres : tests, variante principale, sens « ne pas rejeter », `mc_nom` et `p_mc` finie, composition figée à l'observé ; Pitman et TOST exclus par le sens, rapport de vraisemblance par le type.
> - **Q-D1-Fk-2** : **(a)**, pas de ligne pour une famille d'un seul test.
> - **Q-D1-Fk-3** : **(B)**, une ligne globale minP par méthode, préfixe `LC` déclaré dans `GROUPES`, revue par `app-review`, mention des préfixes dans `CLAUDE.md` par un commit `claude:` (accord donné). Écart assumé à la fiche Fk (« sans changer `GROUPES` »).
> - **Q-D1-Fk-4** : rang symétrique, observé compris, en arithmétique entière, pour tous les membres ; les lignes à p exacte retenue entrent par leur p Monte-Carlo. Le rang « parmi les autres réplications » du corps de #297 est abandonné.
> - **Q-D1-Fk-5** : matrice des p des lignes (V1 ou V3b, Merz-Wüthrich) ; B_eff de famille = réplications complètes sur les membres ; seuil de 50 ; phrases T-3a et T-3b.
> - **Q-D1-Fk-6** : diagnostic par nature ; champs du § 4.2 ; p dans `p_monte_carlo` par `p_mc_ext`, `err_mc` binomial ; textes T-1 et T-2 à la lettre ; lignes ajoutées après les lignes existantes ; ni phrase de #244 ni phrase de #204 ; phrase datée du § 4.5 si le relevé de Westfall et Young manque.
> - **Q-D1-Fk-7** : Q-41-4 confirmée ; matrice `bootstrap$stats_boot` entière, passée à `.mc_p_values()`, en fin d'objet, pour les deux méthodes (+1,04 Mo de références).
> - **Q-D1-Fk-8** : plan du § 5.2, budget plafond de 10 h d'horloge sur 4 cœurs, échelle L0 à L4 au pré-vol ; critère K-F1 à K-F4 et profils Φ0 à Φ5 approuvés tels quels avant toute exécution ; ensemble « à la frontière » par la règle de #244 lue dans la référence ; `puissance_mw_t8.R` et `p_conditionnelle_regime_t8.R` non relancés.
> - **Q-D1-Fk-9** : D2-Fk soumise au mainteneur sous Φ0, Φ4 et Φ5 ; sous Φ1 à Φ3, constat documenté, délégué.
> - **Q-D1-Fk-10 (#331)** : les comparaisons à une borne donnée passent par `usp_delta_bord()`, changement documenté au seul double fl(1 − 10⁻⁶) ; convention actuelle conservée pour δ non fini.
> - **Q-D1-Fk-11** : commentaire de mise à jour publié sur #297 (annexe B) ; annotation de la spécification de #206 (annexe A) insérée en premier commit `docs:` de #297 ; scripts et sorties de la consultation versionnés dans `docs/tableaux/20261024-fk-mesures.md` (commit `docs:` préparatoire).
>
> **Issue proposée** : création acceptée (« tests: p_conditionnelle_regime_t8.R, périmètre F_8 et population de T2 bis après #299 et #303 », `bug`, `needs-triage`, Fg).

> *Rédigé par l'agent actuary (IA).* Consultation `actuary-approfondi` du 24/10/2026, en lecture seule, demandée par la session principale. Elle porte sur la fiche « Branche Fk » du quarante et unième point d'étape (E-24/10 (41e point), M41), sur la branche `claude/lecture-conjointe-familles` (tête `1efa88b`, partie de `main` `44cdaa3`, PR brouillon #374). Le périmètre est fermé, dans l'ordre des commits : #292, #331, #330, #297. La spécification suit l'ordre des questions S-Fk-1 à S-Fk-7.
>
> **Point d'arrêt D1-Fk** : aucun code de #297 tant que le mainteneur n'a pas tranché les questions Q-D1-Fk. #292 et #330 n'en dépendent pas. #331 n'en dépend que par Q-D1-Fk-10.

**Marques** : **[V]** vérifié (source citée avec `fichier:ligne`, ou commande exécutée et sortie lue) ; **[P]** vérification partielle (source secondaire, notice, résumé) ; **[H]** hypothèse ou raisonnement non mesuré ; **[NV]** non vérifié.

## 0. Sources, mesures, contraintes

**Lu [V]** :
- les issues #297 (corps, commentaires `6337960078` et `6367489696`), #330, #331, #292 (sans commentaire), #206 (corps, commentaires `6015442145` et `6098283639`) ;
- la fiche « Branche Fk » de `docs/feuille-de-route.md` (l. 2287-2365), les lignes E-24/10 (41e point) (l. 2594) et M41 (l. 2595) ;
- `docs/specifications/206-calibration-mc-merz-wuthrich.md` (§ 1, § 5, annotations) et `docs/specifications/fm-merz-wuthrich-restitution.md` (modèle de forme) ;
- `CONTEXT.md` : « Test », « Diagnostic », « Verdict », « P-value Monte-Carlo », « P-value retenue » ; ADR 0001 (décision et amendement du 23/09/2026, point 1) ;
- `R/engine.R` (tête `1efa88b`, md5 `8e7feb47744a191c15b2ff59862d5886`) :
  - `engine_p_mc()` (l. 3946-3989), `.mc_p_values()` (l. 4009-4053) ;
  - `engine_registre_tests()` et `add()` (l. 4189-4522) ;
  - `usp_bootstrap()` (l. 4532-4705), `usp_lr_delta()` (l. 4798-4850) ;
  - `usp_tests()` : TOST (l. 5324-5352), Pitman (l. 5511-5524), retour (l. 6754) ; `.usp_poser_renvois()` (l. 12846) ;
  - `mw_bootstrap()` (l. 10425-10507), `MW_CATALOGUE_MC` (l. 10602), `mw_tests()` (retour l. 11396) ;
  - `usp_condition_premier_ordre()` (l. 1462-1474), `usp_regime()` (l. 1898-1909), `usp_gamma_bord()` (l. 1438-1442) ;
  - `usp_parametre()` (l. 1913) et `mw_parametre()` (l. 8644) ;
- `R/display_helpers.R` (md5 `cc2f1733f4e0e0117ff950dab292e575`) : `GROUPES` (l. 88), lecture par `substr(famille, 1, 2)` (l. 146), `FONCTIONS_P_MC_EXTERNE` et `granularite_lignes()` (l. 400-411) ;
- `tests/calibration_mc_mw_t8.R` (md5 `f0b12ce8be1b19bede91f8592c7c3557`) : `NL_MAX` (l. 708), liste « à la frontière » écrite en dur (l. 1211) ;
- `tests/calibration_mc_t8.R` (md5 `625fac8ed155b6769234ef7caecb06b0`) : options (l. 290-315), pas de mode `--essai` ;
- `tests/p_conditionnelle_regime_t8.R` : `F_8` (l. 733) ; `tests/conservatisme_interieur_t8.R` (l. 1222-1250) ;
- le `.tex` : constat de multiplicité lognormal (l. 17431-17437) et Merz-Wüthrich (l. 19393) ; Dwass (1957) et Hope (1968) cités (l. 4361, l. 5828).

**Mesures [V]** : `Rscript` R 4.3.3, `LC_ALL=C.UTF-8`, moteur `1efa88b` chargé par `source()`, conteneur à 4 cœurs, sans autre charge connue. Scripts (annexe C) et sorties hors du dépôt, dans le scratchpad de la session, lancés depuis la racine du dépôt :

| Script (md5) | Objet | Sortie (md5) |
|---|---|---|
| `b_capture.R` (`457943b75202e6cc90c05cf296ab0c8a`) | rejoue les six cas de référence en capturant, par enveloppe d'`add()` et de `.mc_p_values()`, le `mc_nom` de chaque ligne et la matrice passée à `.mc_p_values()` | `b_capture.txt` (`a8b5324d188462f0e038f126237fe349`) |
| `c_lignes.R` (`2b76f14b2e5eff5f4b6f90d5c6c30dee`) | table des lignes par cas : type, variante, sens, nature, p, `mc_nom` | `c_lignes.txt` (`cfdbbf0910f8a349bcc0a7c2d6ba9c0b`) |
| `d_proto.R` (`0e08253f715450817d1f4ac45da25086`) | prototype hors moteur de la p de famille, deux constructions (rang symétrique, rang parmi les autres réplications), durées, taille sérialisée de la matrice | `d_proto.txt` (`6bb21555e429a38f3a820fbdff3554ae`) |
| `e_cout_exact.R` (`9032da72230a87689299885dec81b025`) | coût du recalcul des p exactes par réplication (option (ii) de S-Fk-2 (a)) | `e_cout_exact.txt` (`a739686b5497ed3c28c9de5098d675ea`) |
| `f_compte.R` (`d4755bf4b477a4b443ee2c8359276074`) | variante « nombre de lignes à p < α » de la ligne globale | `f_compte.txt` (`b9cb169f40d8502ba5460ff57d8d1389`) |
| — (commande `Rscript -e`) | décomptes actuels des six références | `g_decomptes.txt` (`69a7bbf6e3e3494cada46d14e6f99617`) |

**Contrôle de l'instrumentation [V]** : les six cas rejoués sous capture sont conformes à leur référence par `comparer_objets()` (0 feuille différente sur 23 715, 23 714 ou 4 547). Les enveloppes ne perturbent donc aucun calcul.

**Sources externes** :
- Westfall, P. H. et Young, S. S. (1993), *Resampling-Based Multiple Testing: Examples and Methods for p-Value Adjustment*, Wiley : **[NV]** pour le contenu (aucune formule, aucune page relue). **[P]** pour l'existence de l'ouvrage et l'attribution de l'ajustement minP par rééchantillonnage : résultats de recherche web du 24/10/2026 (notices ; résumé de Ge, Dudoit et Speed (2003), *TEST* 12(1), p. 1-77, qui présente « a fast algorithm for implementing the minP adjustment »). Les accès aux textes (rapport technique 633 de Berkeley, arXiv) ont été refusés par le proxy de la session [V]. Le relevé groupé est commandé (commentaire `6388285797` de la PR #374).
- Dwass (1957), Hope (1968) : déjà cités par le `.tex` pour le principe du test de Monte-Carlo (l. 5828) [V]. L'argument d'échangeabilité du § 2.1 est un raisonnement écrit ici, **[V, raisonnement]**, qui ne cite aucun énoncé de ces articles au-delà de ce que le `.tex` leur attribue déjà.
- **Aucune affirmation de cette spécification ne dépend du contenu de Westfall et Young (1993).** La construction et sa validité sous échangeabilité sont établies ici ; l'ouvrage n'est cité que pour le nom et l'origine de la procédure.

**Contraintes du code [V]** :
- `add()` admet `p_mc_ext` et `err_mc_ext` seulement sans `mc_nom` (`R/engine.R:4243-4248`).
- Une ligne de type autre que `test` ou `procedure de decision` sort INFO, sans `sens`, `p_retenue` ni `nature_p` (`R/engine.R:4484-4501`). La phrase de #244 n'est posée que sur une ligne de type `test` (`R/engine.R:4462-4478`).
- Chaque ligne est ajoutée en fin de liste (`R/engine.R:4502`). `usp_tests()` rend `.usp_poser_renvois(reg$lignes())` (`R/engine.R:6754`) ; `mw_tests()` rend `reg$lignes()` (`R/engine.R:11396`).
- Matrice des réplications passée à `.mc_p_values()` :
  - V1 : `sim`, B lignes, ligne b remplie si et seulement si la réplication b est retenue (`R/engine.R:4545`, `4562`, `4602`) ;
  - V3b : `S[seq_len(n), ]`, tirages retenus dans le régime intérieur, ceux de V1 d'abord (par b croissant), puis ceux du flux complémentaire (`R/engine.R:4618-4650`) ;
  - Merz-Wüthrich : `sim`, B lignes, NA pour une réplication écartée (`R/engine.R:10447`, `10465`, `10492`).
- Les deux objets bootstrap se terminent par `p_min_mc` (`R/engine.R:4704`, `10506`).
- σ_USP ne lit ni les tests ni le bootstrap : `usp_parametre(fit, sigma_standard, bareme)` (`R/engine.R:1913`) et `mw_parametre(aj, msep, sigma_standard, bareme)` (`R/engine.R:8644`).
- L'affichage groupe les lignes par `substr(famille, 1, 2)` (`R/display_helpers.R:146`) : tout préfixe nouveau doit être déclaré dans `GROUPES`.

---

## 1. S-Fk-1 : familles

### 1.1 Ce que teste une ligne de famille

**Hypothèse visée.** Pour une famille f, l'hypothèse nulle est l'intersection H0^(f) des hypothèses nulles des tests de la famille, sous le modèle ajusté : par exemple, pour H1, la forme E[Y_t] = β x_t sans constante (annexe XVII, B(2)(g)(i)), telle que la vérifient les tests retenus de la famille, chacun sur sa base de résidus.

**Statistique.** m_obs, la plus petite des p Monte-Carlo des tests de la famille.

**P-value.** p_f = P*(m ≤ m_obs), estimée sur les mêmes réplications que les p des lignes (§ 2). C'est l'ajustement minP en une étape, appliqué à la seule plus petite p : la ligne teste l'intersection. Elle **contrôle le taux d'erreur de la famille au sens faible**, c'est-à-dire quand toutes les hypothèses de la famille sont vraies. Elle ne donne pas de p ajustée par ligne : le contrôle au sens fort et la condition de pivotalité des sous-ensembles ne sont pas en cause. Le corps de #297 dit « contrôlé » sans préciser ; la précision « au sens faible » est à reporter.

**Statut.** Le même que celui de chaque p Monte-Carlo : une p plug-in, non exacte, parce que les réplications sont tirées sous le modèle ajusté et non sous le modèle vrai. Son niveau réel à T = 8 n'est établi par aucun résultat publié que je connaisse : c'est l'objet de la mesure de l'étape 5 (§ 5).

### 1.2 Familles retenues

- **Méthode lognormale** : B. (H1), C. (H2), D. (H3), E. (H4) et F. (stabilité). La famille G. (robustesse) n'a aucun test dans les six cas de référence [V, `g_decomptes.txt` et `c_lignes.txt`] : elle n'a pas de ligne de famille, par construction (règle du § 1.3), sans exclusion nommée.
- **Méthode Merz-Wüthrich** : M1 à M4. M5 et M6 n'ont que des diagnostics [V] : pas de ligne, par la même règle.

Les familles sont lues dans le préfixe du champ `famille` (`substr(famille, 1, 2)`, la même lecture que `GROUPES`). Ni les catalogues ni `GROUPES` ne changent pour les lignes de famille.

### 1.3 Règle d'appartenance, figée à l'observé

Une ligne enregistrée est **membre** de sa famille si et seulement si les cinq conditions suivantes sont réunies sur l'objet observé, après toutes les règles qui fixent le type (R1, R3, R13, R14, R15 et décisions de type) :
1. `type == "test"` ;
2. `variante == "principale"` ;
3. `sens == "ne pas rejeter"` ;
4. `mc_nom` renseigné (#330), c'est-à-dire que sa p Monte-Carlo vient du bootstrap principal ;
5. `p_mc` finie.

S'y ajoute une règle technique : les membres sont dédoublonnés par `mc_nom` (une colonne de la matrice ne compte qu'une fois). Aucun doublon n'existe dans les six cas [V, `d_proto.txt` : k = nombre de lignes membres].

**Exclusions et leurs raisons :**
- *Variantes secondaires, diagnostics (tests inopérants compris), lignes non applicables* : sans verdict, ou masquées par défaut ; le minP par famille ne porte que sur les tests.
- *Sens « rejeter »* : la ligne de Pitman (`R/engine.R:5511-5524`) et le TOST (`R/engine.R:5324-5352`). Pour elles, une petite p **conforte** le modèle ; les mettre dans un minimum compterait une confirmation comme une alarme. Cette raison est de principe, indépendante du coût.
- *Lignes sans `mc_nom` ou à `p_mc` absente* : leur statistique n'a pas de colonne dans la loi jointe des réplications. Il s'agit des lignes du rapport de vraisemblance sur δ (G., diagnostics), de Pitman sous permutations aléatoires (T ≥ 10 seulement), et d'une ligne de test dont seule la p exacte existerait (Cox-Stuart avec ex æquo). Aucune ligne de ce dernier type n'existe dans les six cas [V].

**Composition figée à l'observé.** Dans chaque réplication, on lit les colonnes des membres, même si la ligne correspondante aurait un autre type à la configuration de la réplication. C'est la forme standard du minP : la famille est un ensemble fixé d'hypothèses.

**Composition sur les références [V, `c_lignes.txt`, `d_proto.txt`]** (k = nombre de membres) :

| Cas | B. | C. | D. | E. | F. | Membres exclus |
|---|---|---|---|---|---|---|
| `premium`, `reserve1`, `premium_ii6`, `premium_net` | 4 (Intercept, RESET, SpearVol, MK) | 1 (BP) | 6 | 3 (DW, LB2, Runs) | 3 (supF, CUSUM, Grubbs) | Pitman (sens « rejeter ») |
| `premium_interieur` | 4 | 1 | 6 | 5 (+ DWr, Runsr) | 6 (+ supFr, CUSUMr, Grubbsr) | Pitman, TOST (sens « rejeter ») |

| Cas | M1 | M2 | M3 | M4 |
|---|---|---|---|---|
| `reserve2` | 5 (PenteIntra, Origine, HomogF, Courbure, Alpha) | 2 (BP, ExpVar) | 4 (Calendrier, KruskalAcc, CorrDev, DW) | 1 (MinP4) |

La fiche Fk annonçait B. 5 sur `premium` et 6 sur `premium_interieur`. Ces chiffres comptent Pitman (et le TOST) : la règle 3 les retire (4 et 4).

### 1.4 Famille à un seul test (C. sur les cas lognormaux, M4 sur `reserve2`)

**Constat [V, `d_proto.txt`]** : pour k = 1, la p de famille est **exactement** la p Monte-Carlo du test. Par exemple, C. vaut 18/1000 = 0,018, égal à la p de Breusch-Pagan, et M4 vaut 0,898, égal à MinP4. C'est une identité, puisque le rang de m = p_1 est celui de p_1.

**Options (Q-D1-Fk-2)** :
- **(a) Pas de ligne de famille pour k ≤ 1** (recommandé). Une ligne qui ne fait que répéter une p n'apporte rien, et le lecteur pourrait la prendre pour une confirmation indépendante. La documentation énonce la règle, et la ligne globale (§ 1.5) couvre ce test.
- (b) Une ligne pour toute famille à au moins un test : la structure est uniforme, mais la ligne est redondante.
- (c) Une ligne sans p, avec une phrase fixe (« famille d'un seul test : la p de la ligne fait foi ») : la structure est uniforme et rien n'est dupliqué, mais la ligne n'apporte aucune information.

### 1.5 Ligne globale

**Pourquoi.** Le constat de #297 est global : il porte sur la part des jeux conformes qui reçoivent au moins une ALERTE ou un ECHEC. Les lignes de famille n'y répondent pas pour l'ensemble de la batterie.

**Ce que dit la mesure [V, `f_compte.txt`]** :
- Sous la loi bootstrap du cas lui-même, P*(au moins un test membre a une p < 0,10) vaut 0,509 sur `premium`, 0,630 sur `premium_interieur` et 0,658 sur `reserve2`. C'est la quantité du constat de #297, recalculée pour chaque cas et pour les tests actuels.
- L'événement « au moins une p < α » est l'événement {m < α}. La p globale minP est donc la lecture directe de ce constat. P*(m < α) est la probabilité, sous le modèle, d'avoir au moins un verdict ALERTE ou ECHEC ; la p globale situe le m observé dans cette loi.

**p globales minP prévues [V, prototype, construction du § 2.1]** :
- `premium` (k = 17) : m_obs = 0,018, p = 0,131 (Bonferroni 0,306) ;
- `premium_interieur` (k = 22) : m_obs = 0,105, p = 0,650 ;
- `reserve2` (k = 12) : m_obs = 0,002, p = 0,024 (Bonferroni 0,024).

**Variante « nombre de verdicts » [V, `f_compte.txt`]** : p = P*(N ≥ N_obs), où N est le nombre de membres à p < α. Elle répond littéralement à « k ALERTE ou ECHEC sur n lignes sont-ils conformes à l'attendu ? ».
- `reserve2` : N_obs = 7 tests à p < 0,10, pour E*[N] = 1,18 et p = 0,003 ; à 0,05, N_obs = 4 et p = 0,010.
- `premium` : N_obs = 1, p = 0,509.
- Même validité sous échangeabilité que le minP (§ 2.1, raisonnement identique). Mais sa puissance est dirigée vers des écarts diffus et dépend de α, et je n'ai retrouvé **aucune source publiée** qui la fonde : je ne la recommande pas en Fk.

**Placement.** La ligne globale n'appartient à aucune famille : il lui faut un préfixe nouveau, donc une entrée de `GROUPES` (`R/display_helpers.R:88`). C'est un changement d'affichage, avec `app-review`, et la mention des préfixes dans `CLAUDE.md` (« Structure d'un résultat de test »), commit `claude:` soumis à l'accord du mainteneur. La fiche Fk prévoit « sans changer … `GROUPES` » pour les familles : la ligne globale sort donc du plan.

**Options (Q-D1-Fk-3)** :
- (A) pas de ligne globale, dans les limites du plan ;
- **(B) une ligne globale minP par méthode** (recommandé), préfixe commun `LC` (« Lecture conjointe »), famille `"LC. Lecture conjointe de la batterie (toutes familles)"`, une entrée de `GROUPES` ;
- (C) (B) plus une ligne « nombre de verdicts », sans source publiée retrouvée.

Les membres de la ligne globale sont la réunion des membres des familles, familles d'un seul test comprises (C., M4).

---

## 2. S-Fk-2 : p de chaque réplication

### 2.1 Construction recommandée : rang symétrique, observé compris

**Notations.** Soit la matrice des réplications retenues, restreinte aux colonnes des membres et aux lignes où toutes ces colonnes sont finies (n lignes, § 3). On note item 0 l'observé (statistiques `bootstrap$stats_obs`) et items 1..n les réplications. Pour chaque membre j, de queue q_j lue au catalogue, et chaque item k :
- c⁺_j(k) = #{k' ∈ 0..n : S_j(k') ≥ S_j(k)} et c⁻_j(k) = #{k' : S_j(k') ≤ S_j(k)}, comptes qui incluent l'item lui-même ;
- numérateur a_j(k) = c⁺ (queue haute), c⁻ (queue basse) ou min(2 min(c⁺, c⁻), n + 1) (bilatéral) ;
- p_j(k) = a_j(k)/(n + 1) ;
- m(k) = min_j p_j(k).

La p de famille est :

  p_f = #{k ∈ 0..n : m(k) ≤ m(0)} / (n + 1) = (1 + #{b ∈ 1..n : m(b) ≤ m(0)}) / (n + 1).

**Propriété 1 [V, `d_proto.txt`, colonne `p_obs_identiques`]** : p_j(0) est **identique** (`==`, et non à une tolérance près) à la `p_mc` de la ligne, pour chaque membre des six cas. En effet, (1 + #{b : S_b ≥ s_obs})/(B_eff + 1) est la formule d'`engine_p_mc()` (`R/engine.R:3963-3969`). Conséquence : m_obs est la plus petite `p_mc` des membres, telle qu'elle est affichée.

**Propriété 2 [V, raisonnement]** : si les n + 1 items étaient échangeables, p_f serait sur-uniforme, P(p_f ≤ u) ≤ u pour tout u, ex æquo compris.
- Chaque m(k) est la même fonction symétrique de l'item k et du multi-ensemble des n + 1 items. Le vecteur (m(0), …, m(n)) est donc échangeable.
- Le rang de m(0), compté avec « ≤ », est alors sur-uniforme.
- C'est le principe du test de Monte-Carlo (Dwass 1957, Hope 1968, tel que le `.tex` le cite, l. 5828), appliqué à la statistique m.
- Dans le moteur, les items **ne sont pas** échangeables (réplications sous le modèle ajusté) : la propriété ne fonde que le cas idéal, comme pour chaque `p_mc` (spécification de #206, § 0).

**Arithmétique exacte.** On compare les numérateurs entiers a_j(k) sur le dénominateur commun n + 1, et non des quotients en virgule flottante. Le calcul de `engine_p_mc()` est reproduit à l'identique, et l'égalité des minima aux atomes est exacte.

**Construction du corps de #297 (« rang parmi les autres réplications ») : déconseillée [V, `d_proto.txt`].**

Dans cette construction :
- la p d'une réplication est mise sur la grille k/n, celle de l'observé sur la grille k/(n + 1) ;
- aux atomes, une réplication de même rang que l'observé reçoit r/n > r/(n + 1) et n'est pas comptée ;
- le biais va donc vers le **libéral**, et il est maximal quand m_obs est au plancher.

| Cas, famille | Symétrique | Parmi les autres |
|---|---|---|
| `reserve2`, M3 (m_obs = 0,002, plancher bilatéral) | 0,008 | 0,003 |
| `reserve2`, globale | 0,024 | 0,010 |
| `reserve2`, M1 | 0,023 | 0,020 |
| `premium`, globale | 0,131 | 0,123 |

**Coût [V]** : de 0,002 à 0,033 s par famille. Ni tirage, ni graine : l'invariant de l'ADR 0004 est tenu par construction.

### 2.2 (a) Lignes dont la p exacte est retenue

Elles n'existent qu'à π_t constant (règle R7) : SpearVol, MK, DW et Runs sur les quatre cas au bord [V, `c_lignes.txt`]. Chacune a aussi sa `p_mc`. Les écarts p_ex − p_mc valent +0,004, −0,038, +0,007 et −0,019, tous inférieurs ou égaux à 1,2 `err_mc` [V].

**Option (i), recommandée** : rang Monte-Carlo pour tous les membres. L'observé entre par sa `p_mc`, non par sa `p_retenue`.

**Option (ii), texte de #297** : p exacte recalculée par réplication, observé par sa p exacte.
- Coût [V, `e_cout_exact.txt`] : `dw_p_exacte()` sur 999 réplications, 0,49 s ; `runs_p_exacte()`, 0,11 s. Le coût n'est donc pas l'obstacle.
- Obstacles réels :
  - les données des réplications ne sont pas toutes conservées : `z_boot` couvre les lignes de V1, mais ni les ratios y*/x de SpearVol et MK, ni les tirages du flux de V3b ;
  - le code des p exactes (aplatissement des ex æquo, R7) serait dupliqué par réplication.
- Gain nul de statut : la loi de m reste la loi bootstrap, et une p exacte par ligne ne rend pas la p de famille exacte.

**Recommandation (Q-D1-Fk-4)** : (i). Le texte T-1 le dit.

### 2.3 (b) Lignes hors catalogue : Pitman, TOST, rapport de vraisemblance sur δ

- **Pitman et TOST** : exclus par la règle du sens (§ 1.3), avant toute question de colonne.
- **Rapport de vraisemblance** : diagnostics de la famille G., exclus par le type.
- **Les ajouter au catalogue n'est pas recommandé en Fk.** Une colonne de plus dans `USP_CATALOGUE_MC` change la longueur de `bootstrap$p_mc` et des vecteurs associés : c'est une modification de structure des chemins existants, contraire au critère « seuls de nouveaux chemins » de la fiche. Une erreur de calcul de la nouvelle statistique écarterait en outre la réplication pour toutes les autres (`R/engine.R:4560-4561`).

### 2.4 (c) Lignes à p non simulée retenue

Une seule dans les six cas : le TOST de `premium_interieur` (nature « sous le modele auxiliaire pondere : loi de Student… », sens « rejeter ») [V]. Il est exclu par le sens.

**Règle générale** : une ligne de sens « ne pas rejeter » à p non simulée retenue n'a pas de `mc_nom` (#181, `R/engine.R:4415-4421`). Elle est exclue par la condition 4 du § 1.3, sans repli : sa p n'appartient pas à la loi jointe.

---

## 3. S-Fk-3 : régime (V3h) et B effectif de famille

- **Matrice** : celle que `.mc_p_values()` reçoit.
  - Lognormale en V1 : `sim`, B lignes.
  - Lognormale en V3b : `S[seq_len(n), ]`, tirages retenus au régime intérieur.
  - Merz-Wüthrich : `sim`.

  La p de famille est donc **conditionnelle au régime intérieur de δ̂ quand les p des lignes le sont** (V3b), marginale sinon (V1), comme ces p (ADR 0014). Aucun choix nouveau n'est fait : le minP porte sur les réplications qui fondent les p des membres.
- **B_eff de famille** : nombre de lignes de la matrice où **toutes** les colonnes des membres sont finies. Il vaut 999 pour chaque famille des six cas [V, `d_proto.txt`]. En V3b, il est au plus égal au nombre de tirages retenus n.
- **Cas où B_eff de famille est inférieur au B_eff d'un membre** : la p de ce membre recalculée sur les lignes communes peut différer de sa `p_mc` affichée. La statistique m_obs restituée (`stat`) est celle des lignes communes. Ce cas est dit par la phrase fixe T-3a, sans nombre. Il n'existe dans aucun cas de référence [V].
- **B_eff de famille < B_MIN_DEGENERESCENCE (50)** : pas de p (`p_monte_carlo` NA), phrase T-3b, ligne conservée en diagnostic. Le seuil est le même que celui d'`engine_p_mc()` (`R/engine.R:3895`).
- B_eff de famille n'est pas imprimé dans `detail` (#76). Il se recalcule depuis `bootstrap$stats_boot` (§ 9) et la liste des membres (T-1).

---

## 4. S-Fk-4 : restitution

### 4.1 Type : diagnostic

- **« Test »** (`CONTEXT.md`) : une hypothèse nulle, une statistique, une p-value **et un verdict**. La ligne de famille a les trois premiers éléments. Lui donner un verdict ferait coexister deux niveaux de décision sur les mêmes hypothèses : une famille « OK » pourrait contenir une ligne ECHEC. Le dossier deviendrait ambigu sur ce qui fait foi. Son niveau à T = 8 n'est pas non plus mesuré avant D2-Fk.
- **« Diagnostic »** (`CONTEXT.md`) : « une quantité … présentée sans verdict, pour éclairer la lecture des tests ». C'est exactement l'objet : la lecture conjointe. C'est un diagnostic **par nature**, posé `type = "diagnostic"` dès sa création, comme le diagnostic par diagonale de #275.
- **ADR 0001**, amendement du 23/09/2026, point 1 : toute ligne non test sort INFO, sans p retenue ni verdict. Les colonnes de p restent remplies, comme pour les lignes de rapport de vraisemblance (G., `p_mc_ext`) ou la ligne des suites de Merz-Wüthrich (#312).
- Une ligne de type « procédure de décision » ne convient pas : il n'y a pas de décision sans p.
- **Révision possible** : un passage en test ne pourrait se discuter qu'après D2-Fk, sur un profil Φ1 (§ 5.3), par une nouvelle décision du mainteneur. Hors périmètre.

### 4.2 Champs de la ligne

| Champ | Ligne de famille | Ligne globale (si Q-D1-Fk-3 (B)) |
|---|---|---|
| `famille` | chaîne `famille` des membres (identique pour tous [V]) | `"LC. Lecture conjointe de la batterie (toutes familles)"` |
| `test` | `"p de famille (minP, lecture conjointe)"` | `"p globale (minP, lecture conjointe de la batterie)"` |
| `reference` | `"Westfall & Young (1993), minP en une etape ; Dwass (1957), Hope (1968)"` | idem |
| `type` / `base` / `variante` | `"diagnostic"` / `"commun"` / `"principale"` | idem |
| `H0` | `"toutes les hypotheses nulles des tests de la famille sont vraies (modele ajuste)"` | `"… des tests de toutes les familles …"` |
| `H1` | `"au moins une est fausse"` | idem |
| `stat_nom`, `stat` | `"plus petite p Monte-Carlo de la famille"`, m_obs | idem |
| `loi` | `"minimum des p Monte-Carlo -> Monte-Carlo (memes replications, rangs avec l'observe)"` | idem |
| `estim_nom`, `estim` | `"nombre de tests de la famille"`, k | `"nombre de tests"`, k |
| `p_monte_carlo` | p_f, par `p_mc_ext` | p globale |
| `erreur_MC` | √(p_f (1 − p_f)/B_eff_f), par `err_mc_ext`, queue simple | idem |
| `p_exacte`, `p_asymptotique`, `p_min`, `p_min_mc` | NA | NA |
| `p_retenue`, `nature_p`, `sens`, `verdict` | NA, NA, NA, INFO (posés par `add()`) | idem |
| `mc_nom` (#330) | NA | NA |
| `fonction` | `"engine_p_famille"` | idem |
| `inoperant` | FALSE | FALSE |

Remarques :
- `err_mc` est l'erreur de Monte-Carlo de p_f, fonction de B_eff. Elle ne mesure pas l'erreur d'approximation liée à T.
- Après #330, `granularite_lignes()` rend un tiret pour ces lignes (`mc_nom` NA). La granularité est de 1/(B_eff_f + 1), recalculable ; aucun champ nouveau n'est proposé.
- Ni la phrase de #244 ni celles de #204 ou #257 ne sont posées. #244 ne vaut que pour une ligne de type test (`R/engine.R:4462`), et l'exception bornée de #204 (ADR 0003 annoté le 12/10/2026, point 4) n'est pas étendue.

### 4.3 Position et appel

- `engine_p_famille()` est appelée en fin d'`usp_tests()`, sur `reg$lignes()` et **avant** `.usp_poser_renvois()`, et en fin de `mw_tests()`. Elle prend en entrée les lignes, `boot` (dont `stats_boot` et `stats_obs`) et le catalogue de la méthode.
- Les lignes de famille sont **ajoutées après la dernière ligne existante**, dans l'ordre des préfixes, puis la ligne globale. Aucune ligne existante ne change d'indice, ce qui garde identiques les chemins existants des références (`tests[[i]]`).
- **[H]** : `.usp_poser_renvois()` ne touche pas ces lignes, puisque `usp_renvois()` les apparie par nom de test. À vérifier par l'audit.
- La sélection de restitution (ADR 0009) ne change aucun calcul : la p de famille porte sur tous ses membres, même si l'utilisateur en masque. T-1 liste les membres. C'est un point pour `app-review`.

### 4.4 Textes fixes (ASCII, sans aucun nombre issu du bootstrap, règle #76)

**T-1** : `detail` d'une ligne de famille. Source : la construction du § 2.1 et les décisions D1-Fk. `%s` est la liste des `mc_nom` des membres, séparés par `", "`, dans l'ordre des lignes.
> `Lecture conjointe des tests de la famille (issue #297) : p minP en une etape, proportion des replications, observe compris, dont la plus petite p Monte-Carlo des tests de la famille est au plus egale a l'observee ; rangs calcules sur les replications qui fondent les p Monte-Carlo des lignes, l'observe compris, et p Monte-Carlo utilisee aussi pour les tests dont la p exacte est retenue. Tests de la famille : %s. Hors famille : lignes de sens rejeter, variantes secondaires, diagnostics et lignes sans p Monte-Carlo du bootstrap principal. Controle du taux d'erreur de la famille au sens faible (toutes ses hypotheses vraies), sous le modele ajuste : p plug-in, non exacte, comme les p Monte-Carlo des lignes. Diagnostic sans verdict : aucun verdict de ligne n'est modifie.`

**T-2** : `detail` de la ligne globale (option (B)). `%d` est k, compte de lignes, nombre qui ne vient pas du bootstrap.
> `Lecture conjointe de la batterie (issue #297) : p minP en une etape sur les %d tests des familles, meme construction que les lignes de famille. Elle situe la plus petite p Monte-Carlo observee dans sa loi sous le modele ajuste, compte tenu du nombre de tests et de leur dependance ; au moins un verdict ALERTE ou ECHEC correspond a une plus petite p inferieure a alpha. Controle du taux d'erreur de la batterie au sens faible, sous le modele ajuste : p plug-in, non exacte. Diagnostic sans verdict : aucun verdict de ligne n'est modifie.`

**T-3a** (B_eff de famille < B), jointe à T-1 ou T-2 par `.engine_joindre()` :
> `Calculee sur les seules replications ou les statistiques de tous les tests de la famille sont finies, moins nombreuses que B.`

**T-3b** (B_eff de famille < B_MIN_DEGENERESCENCE), en tête du `detail`, la liste des membres de T-1 étant conservée :
> `p de famille non calculee : replications completes insuffisantes (B_effectif < B_MIN_DEGENERESCENCE = 50) ; aucune p-value (ADR 0001).`

Le nombre 50 vient de la constante, pas du bootstrap. Le gabarit est construit par `sprintf()` depuis `B_MIN_DEGENERESCENCE`.

### 4.5 Sources et phrase datée (Q-Fc-10)

- Le champ `reference` cite Westfall et Young (1993) pour le **nom et l'origine** de la procédure minP [P]. La validité de la construction ne s'appuie que sur le § 2.1 [V, raisonnement].
- **Phrase datée** à employer par `docwriter` si le relevé groupé n'est pas rendu avant son passage :
  > « Westfall et Young (1993) n'a pas été relu sur le texte intégral au 24 octobre 2026 : l'ouvrage est cité pour le nom et l'origine de la procédure minP ; la construction décrite ici et sa validité sous échangeabilité sont établies dans cette section, sans référence aux formules de l'ouvrage. »
- **À vérifier sur pièce par le relevé** :
  - (i) la définition de la p ajustée minP en une étape ;
  - (ii) l'usage des mêmes rééchantillons pour les p brutes et pour la loi du minimum ;
  - (iii) les notions de contrôle faible et fort, et la pivotalité des sous-ensembles.

  Si (ii) y est écrit différemment, par exemple avec un rang parmi les autres rééchantillons, le § 2.1 reste justifié par la mesure et le raisonnement, et l'écart sera documenté.

---

## 5. S-Fk-5 : mesure (étape 5)

### 5.1 Objet

Une seule exécution, sur le moteur de l'étape 4. Elle mesure :
- **(1)** le niveau réel sous H0, à T = 8, de chaque p de famille et de la p globale ;
- **(2)** T4 : multiplicité sous H0, c'est-à-dire la part des jeux à au moins une ALERTE ou un ECHEC, et à au moins un ECHEC, sur les tests ;
- **(3)** pour Merz-Wüthrich, la remesure du T1 de #206 sur les 13 clés après #276, #301, #300, #307 et #312. C'est le préalable du commentaire `6367489696`.

Ce sont des **constats de simulation sous un plan** (jeux J1 et J2 de #166 ; plan `reserve2` de #206, lois N et E), jamais un résultat général.

### 5.2 Plan réduit et budget

**Budget plafond : 10 h d'horloge sur 4 cœurs.** Le pré-vol et les essais sont hors budget, au plus 0,5 h.

Coûts unitaires mesurés en un seul processus [V] :
- `mw_bootstrap()` et `mw_tests()` sur `reserve2` : 20,1 + 2,3 = 22,4 s par triangle ;
- `run_engine()` lognormal : 8,1 à 10,4 s (δ̂ au bord) et 14,2 s (δ̂ intérieur), d'après `b_capture.txt`.

Hypothèse de débit linéaire à 4 processus [H], comme P4 de #229. Oracle de #206 : 20 000 évaluations de `.mw_stats()` par loi, soit environ 0,6 h CPU par loi [H, d'après les 108 ms par appel mesurés pour #206].

| Niveau | Configuration | h CPU [H] | Horloge, 4 cœurs [H] |
|---|---|---|---|
| L0 | MW : N et E, pool redressé, R = 2 000 chacune, oracles N et E ; LN : J1 et J2, R = 2 000 chacun | ≈ 39 | ≈ 9,8 h |
| L1 | MW E à R = 1 000 | ≈ 33 | ≈ 8,3 h |
| L2 | LN J1 à R = 1 000 | ≈ 30,5 | ≈ 7,6 h |
| L3 | MW N à R = 1 000 | ≈ 24 | ≈ 6,1 h |
| L4 (minimum) | LN J2 à R = 1 000 (IC ≈ ±0,019 à 0,10) | ≈ 20 | ≈ 5,1 h |

**Règle de choix.** On retient le premier niveau dont la durée planifiée, calculée avec le débit agrégé et les c_b **mesurés au pré-vol** à 4 processus, tient dans 10 h. Sous L4, la décision revient au mainteneur.

**Hors plan** (raisons : budget, et questions déjà tranchées ou sans objet pour D2-Fk) :
- le pool brut et la loi A de #206 (K2 tranché en B3 ; A seulement si le budget le permet, après L0) ;
- la sous-mesure N (#119, close) ;
- `tests/puissance_mw_t8.R` (31 à 33 h, repère M39) : la puissance de la p de famille n'est pas l'objet de D2-Fk ;
- `tests/p_conditionnelle_regime_t8.R` : la condition V3h est déjà exercée par J2 au travers de `run_engine()`.

Par suite, le contrôle `--controle-i2prime --cle-moteur MinP4 --candidat MinP4` et l'option `--i3-grille-anterieure` (M41 (b)) sont **sans objet** dans Fk. La correction de `F_8` et de la population de T2 bis de `p_conditionnelle_regime_t8.R`, qui contient encore BP79, GQ, BF et Grubbsr (l. 733), devient une issue proposée, rattachée à Fg ou au prochain essai M39.

### 5.3 Critère, fixé avant toute exécution (reporté sans modification dans les scripts et au T0)

**Grandeurs.**
- Pour chaque jeu simulé d, chaque famille f dont la ligne est présente (k_f ≥ 2, ou ≥ 1 sous Q-D1-Fk-2 (b)) et chaque α ∈ {0,10 ; 0,05} : D = 1 si p_f,d < α.
- Une p de famille absente (T-3b) compte comme un non-rejet, comptée à part (#242).
- τ_f(α) = (Σ D) / n_f, où n_f est le nombre de jeux où la ligne est présente. IC de Clopper-Pearson à 95 %, calculé sur les valeurs non arrondies.
- La composition de la famille varie avec le jeu. Elle est rapportée : distribution de k_f et part des jeux où la ligne existe.

**Référence ρ_F(α)** : la taille du test de Monte-Carlo idéal à B_eff = 999, pour une statistique sans atome, P((1 + K)/1000 < α) = (⌈1 000 α⌉ − 1)/1 000. Elle vaut **0,099** et **0,049** [V, arithmétique]. Avec des atomes de m, nombreux près du plancher, le test idéal est plus conservateur : ρ_F en est un **majorant** [V, raisonnement du § 2.1]. La masse de p_f au plancher 1/(B_eff + 1) est rapportée.

**Classes**, celles de #166 et #206 avec ρ_F :
- *compatible* : ρ_F ∈ IC ;
- *écart mineur* : estimation dans [ρ_F/2 ; 3ρ_F/2] ;
- *non tranché* : estimation hors de la bande, IC qui la recoupe ;
- *distorsion matérielle* : IC disjoint de la bande, côté libéral ou conservateur.

**Conditions** (évaluées mécaniquement, sans conclusion dans le tableau) :
- **K-F1** (principal) : classe de τ_f(α) pour chaque (jeu ou loi, famille ou globale, α).
- **K-F2** (descriptif, T4) : part des jeux à au moins une ALERTE ou un ECHEC et à au moins un ECHEC, sur les tests ; part des jeux à p globale < α ; par famille, part à au moins un test membre à p < α contre part à p_f < α.
- **K-F3** (intégrité) : les contrôles existants des deux scripts, plus un contrôle nouveau. Sur le premier jeu de chaque tranche, p_f et m_obs recalculés **dans le script**, en R de base, depuis `bootstrap$stats_boot`, `stats_obs`, le catalogue et les lignes, par une écriture indépendante d'`engine_p_famille()`, doivent être `identical()` aux champs de la ligne. Un échec met INTEGRITE à ECHEC.
- **K-F4** (frontière, descriptif) : par clé et pour chaque p de famille, la fréquence sous H0 de |p − s| < 2 err_mc, pour s ∈ {α ; α/2} (T4 de #206, étendu).
- **Merz-Wüthrich, remesure par clé** : K1 à K5 de la spécification de #206, § 5, inchangés, avec ses annotations du 10 et du 11/10/2026. La clé Runs, dont la ligne est un diagnostic depuis #312, est lue à titre descriptif.

**Profils de lecture pour D2-Fk** (actuary propose, le mainteneur tranche) :

| Profil | Condition | Lecture proposée |
|---|---|---|
| Φ0 | K-F3, ou K3 ou K4 de #206, en défaut sans explication | Lecture suspendue ; mesure à reprendre |
| Φ1 | Toutes les p de famille et la p globale compatibles ou en écart mineur, aux deux α, sous chaque jeu et chaque loi | Diagnostic conservé ; niveau documenté comme constat ; **aucune décision** |
| Φ2 | Pas de distorsion matérielle, mais des écarts non tranchés | Idem, avec les IC |
| Φ3 | Distorsion matérielle **conservatrice** seulement | Conservé ; la documentation dit qu'une p de famille élevée est une preuve faible ; aucune décision |
| Φ4 | Distorsion matérielle **libérale** pour au moins une (famille, jeu ou loi, α) | **Décision du mainteneur** : garder avec une phrase fixe sourcée par la mesure, retirer la ou les lignes, ou reformuler |
| Φ5 | Distorsions de côtés opposés entre jeux ou lois pour une même famille | **Décision du mainteneur** ; documenter, aucune correction calibrée sur un seul plan |

Pour les clés Merz-Wüthrich, un Π3 ou un Π4 (profils de #206) donne lieu à une **issue proposée**, sans changement de verdict en Fk. L'issue est rapportée à D2-Fk à titre d'information.

### 5.4 Ensemble « à la frontière » (règle du commentaire `6367489696`, point 2)

- **Règle** : une ligne de type test est « à la frontière » si |p_mc − s| < 2 `err_mc` pour un seuil atteignable s ∈ {α ; α/2} (sens « ne pas rejeter »), sur la **référence versionnée**. C'est exactement la règle de #244 posée par `add()` (`R/engine.R:4462-4478`).
- **Lecture dans le script** : `tests/calibration_mc_mw_t8.R` (l. 1211) remplace la liste `c("BP", "Origine", "HomogF")` par les lignes de `readRDS(chemin_reference("reserve2"))$tests` dont le `detail` se termine par `PHRASE_VERDICT_SENSIBLE_MC`. C'est une source unique de la règle, lue comme `NL_MAX` (l. 708). Un contrôle recalcule l'inégalité depuis `p_mc` et `err_mc` et refuse tout désaccord.
- **Sur la référence actuelle [V]** : PenteIntra (0,090 ; |p − α|/err = 0,76) et Origine (0,085 ; 1,70). HomogF (0,080 ; 2,33) est juste au-delà, BP (0,285) hors de l'ensemble. Sur les cas lognormaux, seule la ligne Grubbs de `premium_interieur` (0,105) porte la phrase.

### 5.5 Préalables, dans l'ordre

1. **M41 (a)** : `git fetch --unshallow` en session cloud, avant tout essai ou toute mesure. Le dépôt de la session est superficiel [V : `git rev-parse --is-shallow-repository` rend `true`]. Le contrôle (i4) de `calibration_mc_mw_t8.R` relit `b827726^:R/engine.R`.
2. **Annotation datée de la spécification de #206**, en premier commit `docs:` de #297 (texte fourni à part).
3. **`calibration_mc_mw_t8.R`** : la règle du § 5.4 remplace la liste écrite en dur ; table nouvelle des p de famille (K-F1, K-F4) ; contrôle K-F3 ; sorties nommées `issue297`.
4. **`calibration_mc_t8.R`** : mode **`--essai`** ajouté (M41 (c)), avec la sémantique des autres scripts (R réduit, sorties non versionnables, `--ecrire` refusé) ; mêmes tables des p de famille et K-F3 ; T2 (verdicts des lignes) étendu aux lignes ajoutées, qui sont INFO.
5. **Pré-vol** : `--essai` de chaque mode (J1, J2, N, E) sur le moteur de l'étape 4, débit à 1, 2, 3 et 4 processus, choix du niveau L0 à L4 par la règle du § 5.2, écrit au JOURNAL avant le lancement.
6. **M40 (a)** : sortie de `bash .claude/outils/bilan_journal.sh` collée dans la PR avant l'exécution longue.

### 5.6 Sorties, et ce qui déclenche D2-Fk

**Sorties** : `docs/tableaux/<AAAAMMJJ>-issue297-calibration-famille-ln.md` et `-mw.md`, leurs bruts `.tsv`, et les journaux de mesure et de combinaison. Elles sont nouvelles et jamais patchées, et respectent les critères génériques de #242 (D-a, D-e, D-g ; libellés en `\u`).

**D2-Fk** :
- est **toujours tenu** (le mainteneur reçoit le tableau d'évaluation mécanique de K-F1 à K-F4 et des profils) ;
- **exige une décision** si et seulement si Φ0, Φ4 ou Φ5 ;
- sous Φ1 à Φ3, il est délégable : constat documenté seul, sans modification du moteur.

---

## 6. S-Fk-6 : décomptes prévisionnels des six cas

**Avant** : état actuel [V, `g_decomptes.txt`].

**Après** : recommandations Q-D1-Fk-2 (a) (pas de ligne pour k = 1) et Q-D1-Fk-3 (B) (ligne globale). Les p prévues sont exactes, de la forme numérateur/1 000 [V, prototype `d_proto.txt`]. Ce sont des oracles de test unitaire, à l'égalité exacte des numérateurs.

| Cas | Avant : lignes / test / diag. / NA ; OK / ALERTE / ECHEC / INFO | Après | Lignes ajoutées (p prévue) |
|---|---|---|---|
| `premium`, `reserve1`, `premium_ii6`, `premium_net` | 47 / 18 / 28 / 1 ; 16 / 1 / 1 / 29 | 52 / 18 / 33 / 1 ; 16 / 1 / 1 / 34 | B. 950/1000 ; D. 438 ; E. 316 ; F. 961 ; LC 131 |
| `premium_interieur` | 47 / 24 / 22 / 1 ; 23 / 1 / 0 / 23 | 52 / 24 / 27 / 1 ; 23 / 1 / 0 / 28 | B. 955 ; D. 579 ; E. 423 ; F. 290 ; LC 650 |
| `reserve2` | 21 / 12 / 9 / 0 ; 5 / 3 / 4 / 9 | 25 / 12 / 13 / 0 ; 5 / 3 / 4 / 13 | M1 23 ; M2 471 ; M3 8 ; LC 24 |

**Variantes** :
- sans ligne globale (Q-D1-Fk-3 (A)) : une ligne et un diagnostic de moins par cas ;
- avec les familles d'un seul test (Q-D1-Fk-2 (b)) : une de plus par cas, C. (18 ou 377) et M4 (898) ;
- avec la ligne « nombre de verdicts » (Q-D1-Fk-3 (C)) : une de plus par cas.

**Ce qui ne change pas** : aucun test, aucun verdict existant, aucune p existante. σ_USP est inchangé [V : signatures d'`usp_parametre()` et de `mw_parametre()`].

**Effets à prévoir** :
- Le registre `DECOMPTES` de `tests/concordance_doc_moteur.R` (entrées par type, total de lignes) signalera un écart après la régénération de #297 : commit `docs:` minimal (M32).
- Le `.tex` cite les décomptes de lignes dans plusieurs sections (tableaux 1 et 2, structure d'un résultat), à reprendre par `docwriter`.

**Taille des références [V, `d_proto.txt`]** : la matrice `stats_boot` sérialisée seule pèse 191 542 octets par cas lognormal et 81 178 octets pour `reserve2`. Les références passent d'environ 145 Ko à environ 335 Ko (lognormal) et de 23 Ko à environ 104 Ko (`reserve2`), soit environ +1,04 Mo au total. `comparer_objets()` compare environ 31 000 feuilles de plus par cas lognormal.

---

## 7. S-Fk-7 : mise à jour de #297

Le texte du commentaire proposé est fourni à part, en dehors de cette spécification. Les corrections qu'il porte :
- « 34 lignes » remplacé par les décomptes actuels ;
- M4 = MinP4 (#300) ;
- M3 à quatre tests (#312) ;
- contrôle au sens faible ;
- rang symétrique, observé compris ;
- p Monte-Carlo pour les lignes à p exacte retenue ;
- exclusion des lignes de sens « rejeter » ;
- familles d'un seul test ;
- ligne globale.

---

## 8. Points de fond de #331 et #292

### 8.1 #331, comparaisons à une borne donnée

**Constat [V, mesure]** : la convention du bord de δ diverge aujourd'hui, sur un seul nombre en virgule flottante.
- `usp_regime()` juge « au bord haut » par `delta >= 1 - tol` (`R/engine.R:1899`).
- `usp_lr_delta()` et la ligne G. d'`usp_tests()` jugent « δ̂ sur la borne 1 » par `abs(fit$delta - d0) <= TOL_DELTA_BORD` (`R/engine.R:4810`, `6738`).
- Au double δ = fl(1 − 10⁻⁶) = 0,99999899999999997124, la première vaut TRUE et la seconde FALSE. Les doubles voisins, à ±4 ulp, concordent. À la borne 0, les deux formes concordent sur les doubles testés autour de tol, puisque δ − 0 est exact.

**Recommandation (Q-D1-Fk-10)** : faire relever les deux comparaisons du prédicat, par `identical(usp_delta_bord(fit$delta), if (d0 == 0) "basse" else "haute")`. d0 ne prend que les valeurs 0 et 1 (`R/engine.R:4848`).
- C'est précisément la divergence que #331 veut supprimer : une seule convention de bord.
- Le changement de comportement est limité au double fl(1 − tol). Il est à documenter dans le commit comme correction d'incohérence.
- Les références restent identiques au bit près (critère de #331) : aucun δ̂ des six cas n'est sur ce double [H, à vérifier par l'audit sur `res$ajustement$delta`].
- Grille du test `identical()` étendue :
  - à fl(1 − tol) ± 1 ulp et à tol ± 1 ulp ;
  - `identical()` exigé pour `usp_condition_premier_ordre()` et `usp_regime()` ;
  - changement attendu et testé, au seul double fl(1 − tol), pour les deux sites de comparaison.

**Convention pour un δ non fini.** Reproduire le comportement actuel bit pour bit :
- −Inf est jugé au bord bas et +Inf au bord haut (par les comparaisons) ;
- NA et NaN propagent NA dans `usp_regime()`, sans erreur.

Ne **pas** reprendre telle quelle la convention d'`usp_gamma_bord()` (« non fini → basse ») : elle changerait `usp_regime(NA)`. La convention est écrite dans l'en-tête du prédicat.

### 8.2 #292

Aucun choix de fond : une constante, la ponctuation restant à l'appelant, des `detail` identiques.

---

## 9. `bootstrap$stats_boot` (confirmation de Q-41-4)

- **Contenu** : la matrice exacte passée à `.mc_p_values()`, avec ses noms de colonnes (ordre du catalogue).
  - V1 : B lignes, ligne b = réplication b, NA si elle est écartée. Les lignes s'alignent sur `z_boot`.
  - V3b : n lignes retenues, celles de V1 d'abord puis celles du flux. Elles **ne s'alignent pas** sur `z_boot` ; à documenter.
  - Merz-Wüthrich : B lignes.
- **Position** : élément ajouté **en fin** de chaque objet bootstrap, après `p_min_mc`. Les commentaires « dernier élément » des deux fonctions sont à mettre à jour.
- **Propriété vérifiable par un réviseur** : pour chaque clé j, `engine_p_mc(stats_boot[, j], stats_obs[[j]], queue_j, extremes_j)` redonne `p_mc[j]`, `err_mc[j]`, `B_effectif[j]` et `p_min_mc[j]`. C'est un test unitaire.
- **Coût** : environ +1,04 Mo de références (§ 6). Aucun calcul ni tirage supplémentaire. `tests/conservatisme_interieur_t8.R` compare les champs du bootstrap un à un (l. 1245-1250) : il n'est pas cassé par un champ ajouté [V].
- **Alternative** : ne stocker que les colonnes des membres. Elle est déconseillée : la propriété ci-dessus ne vaudrait plus pour toutes les p.

## 10. Tests unitaires attendus (étape 4)

`engine_p_famille()` sur une matrice jouet :
- rangs et ex æquo, en arithmétique entière ;
- queues haute, basse et bilatérale (plafond n + 1) ;
- identité p_j(0) = `engine_p_mc()` ;
- famille d'un seul test : p = p du test ;
- exclusion des diagnostics, des variantes secondaires, du sens « rejeter » et des lignes sans `mc_nom` ;
- indifférence à l'ordre des colonnes et des lignes de réplication ;
- lignes NA (B_eff de famille) ;
- seuil de 50 (T-3b) ;
- aucune consommation d'aléa : `.Random.seed` inchangé.

Sur les six cas :
- numérateurs du § 6 exacts ;
- T-1 et T-2 à la lettre ;
- `identical()` des 47 ou 21 lignes existantes avant et après ;
- `stats_boot` et `engine_p_mc()` (§ 9).

---

## Questions au mainteneur pour D1-Fk

- **Q-D1-Fk-1 — familles et règle d'appartenance** (S-Fk-1, S-Fk-2 (b) et (c)).
  - *Recommandation* : familles B. à F. et M1 à M4 ; aucune ligne pour G., M5 et M6, qui n'ont pas de test.
  - Membres : tests, variante principale, sens « ne pas rejeter », `mc_nom` et `p_mc` finie, composition figée à l'observé. Pitman et TOST sont exclus par le sens ; le rapport de vraisemblance l'est par le type.
- **Q-D1-Fk-2 — famille d'un seul test.**
  - *Recommandation* : (a), pas de ligne. Pour k = 1, la p de famille est exactement celle du test [V].
  - *Alternatives* : (b) ligne redondante ; (c) ligne sans p.
- **Q-D1-Fk-3 — ligne globale.**
  - *Recommandation* : (B), une ligne globale minP par méthode, préfixe `LC` déclaré dans `GROUPES`, avec `app-review` et la mention des préfixes dans `CLAUDE.md` (commit `claude:` sur votre accord). Elle sort de la fiche (« sans changer `GROUPES` »).
  - *Alternatives* : (A) aucune, dans le plan ; (C) (B) plus une ligne « nombre de verdicts », sans source publiée retrouvée (`reserve2` : p = 0,003).
- **Q-D1-Fk-4 — p de chaque réplication.**
  - *Recommandation* : rang symétrique, observé compris, en arithmétique entière, pour **tous** les membres. Les lignes à p exacte retenue entrent par leur p Monte-Carlo.
  - Le texte de #297 prévoyait un rang parmi les autres réplications : il est libéral aux atomes (`reserve2`, globale : 0,010 au lieu de 0,024 ; M3 : 0,003 au lieu de 0,008 [V]). Il prévoyait aussi la p exacte par réplication : données non conservées, gain de statut nul.
- **Q-D1-Fk-5 — régime et B effectif.**
  - *Recommandation* : la matrice des p des lignes (V1 ou V3b, Merz-Wüthrich), donc une p conditionnelle au régime intérieur quand celles des lignes le sont ; B_eff de famille = lignes complètes sur les membres ; seuil de 50 ; phrases T-3a et T-3b.
- **Q-D1-Fk-6 — restitution.**
  - *Recommandation* : diagnostic par nature ; champs du § 4.2 ; p dans `p_monte_carlo` par `p_mc_ext`, `err_mc` binomial ; textes T-1 et T-2 à la lettre ; lignes ajoutées après les lignes existantes ; ni phrase de #244 ni phrase de #204 ; phrase datée du § 4.5 si le relevé de Westfall et Young manque.
- **Q-D1-Fk-7 — `bootstrap$stats_boot`.**
  - *Recommandation* : confirmer Q-41-4, avec la matrice entière passée à `.mc_p_values()`, en fin d'objet, pour les deux méthodes (+1,04 Mo de références).
  - *Alternative* : colonnes des membres seulement, déconseillée.
- **Q-D1-Fk-8 — mesure de l'étape 5.**
  - *Recommandation* : plan du § 5.2, budget plafond de 10 h d'horloge sur 4 cœurs, échelle L0 à L4 appliquée au pré-vol ; critère K-F1 à K-F4 et profils Φ0 à Φ5 approuvés tels quels avant toute exécution ; ensemble « à la frontière » par la règle de #244 lue dans la référence.
  - `puissance_mw_t8.R` et `p_conditionnelle_regime_t8.R` ne sont pas relancés ; la correction de `F_8` et de T2 bis fait l'objet d'une issue proposée.
- **Q-D1-Fk-9 — D2-Fk.**
  - *Recommandation* : décision du mainteneur requise sous Φ0, Φ4 et Φ5 seulement ; sous Φ1 à Φ3, constat documenté, délégable.
- **Q-D1-Fk-10 — #331, comparaisons à une borne donnée.**
  - *Recommandation* : les faire relever d'`usp_delta_bord()` (une seule convention), en documentant le changement au seul double fl(1 − 10⁻⁶) [V] ; convention actuelle conservée pour δ non fini.
  - *Alternative* : les laisser en l'état, avec un commentaire qui renvoie au prédicat ; la divergence d'un double subsiste.
- **Q-D1-Fk-11 — publications.**
  - *Recommandation* : publier le commentaire de mise à jour de #297 (texte fourni) et insérer l'annotation de la spécification de #206 en premier commit `docs:` de #297.
  - Versionner les scripts et sorties de cette consultation dans un tableau daté `docs/tableaux/20261024-fk-mesures.md` (commit `docs:` préparatoire, précédent Q-D1-Fm-3), pour que le `.tex` et les tests cités s'appuient sur une pièce.

Issue proposée, sur accord seulement : **« tests: p_conditionnelle_regime_t8.R, périmètre F_8 et population de T2 bis après #299 et #303 »**, libellés `bug` et `needs-triage`, rattachement à Fg.

---

# Annexe A — annotation proposée de la spécification de #206 (à insérer après Q-D1-Fk-11)

---

## Annotation du 24/10/2026 : remesure de la branche Fk (#297), quatre changements du moteur et ensemble « à la frontière »

> *Rédigé par l'agent actuary (IA), versionné par la session principale en premier commit `docs:` de #297 (branche Fk, `claude/lecture-conjointe-familles`).* Source : commentaire `6367489696` de #297, points 1 et 2, publié sur accord du mainteneur le 23/10/2026. Les sorties du 11/10/2026 (commit mesuré `3a95e11`) ne sont ni modifiées ni régénérées. Le critère du § 5 (K1 à K5, profils Π0 à Π5, R1 à R3), le DGP du § 2, les graines du § 7 et les annotations antérieures restent en vigueur. Le plan de la remesure (lois, R, budget) et la lecture de la p de famille sont fixés par la spécification de Fk (`docs/specifications/fk-lecture-conjointe.md`, § 5).

**1. Quatre changements de statistique ou de sens depuis la mesure du 11/10/2026** (commits [V], `git log`) :

| Clé | Changement | Issue, commit du moteur | Décision |
|---|---|---|---|
| Calendrier (M3) | test calendaire de Mack en queue basse ; bilatéral dans le tableau du § 1 | #276, `bfec999` (16/10/2026) | Q-Fd-1 (D1-Fd, 14/10/2026) |
| BP (M2) | hétéroscédasticité en régression à effets fixes de colonne, variante FWr | #301, `62828e4` (21/10/2026) | Q-D2-Fi-1 (21/10/2026) |
| Grubbs → MinP4 (M4) | minimum des p de Student des résidus studentisés externes ; clé Grubbs retirée de `MW_CATALOGUE_MC` | #300, `969cc98` (21/10/2026) | Q-D2-Fi-2 (21/10/2026) |
| PenteIntra (M1) | pente intra-colonne relative commune, à effets fixes de colonne | #307, `2e69cc3` (23/10/2026) | Q-D1-Fj-3 (23/10/2026) |

Deux autres changements ne modifient aucune statistique.
- **#312** (`455038b`, Q-D1-Fm-1) : la ligne du test des suites (clé Runs) est une variante secondaire restituée en diagnostic, sans verdict. La clé et sa statistique sont inchangées ; son niveau se lit désormais à titre descriptif.
- **#307**, option (b′) de la famille α (Q-D1-Fj-5) : il a changé les textes de la ligne Alpha (référence, H1, `detail`), mais pas sa statistique.

**2. Tableau du § 1 pour la remesure.** Il remplace celui du § 1 pour la remesure de Fk seulement. Valeurs de `tests/reference/reserve2.rds` à `1efa88b`, B_effectif = 999 pour les 13 clés [V] :

| Clé | Ligne de `mw_tests()` | Famille | Queue | p_mc | err_mc | Type, verdict |
|---|---|---|---|---|---|---|
| PenteIntra | Absence de tendance des facteurs avec le cumul, à colonne donnée | M1 | deux | 0,090 | 0,0131 | test, ALERTE |
| Origine | Nullité de l'ordonnée à l'origine, colonne par colonne | M1 | haut | 0,085 | 0,0088 | test, ALERTE |
| HomogF | Homogénéité de f_j entre années de survenance | M1 | haut | 0,080 | 0,0086 | test, ALERTE |
| Courbure | Absence de courbure de la régression | M1 | haut | 0,030 | 0,0054 | test, ECHEC |
| Alpha | Stabilité du facteur selon la pondération (famille alpha) | M1 | haut | 0,005 | 0,0022 | test, ECHEC |
| BP | Hétéroscédasticité résiduelle vs cumul | M2 | haut | 0,285 | 0,0143 | test, OK |
| ExpVar | Adéquation de l'exposant de variance, colonne par colonne | M2 | haut | 0,428 | 0,0157 | test, OK |
| Calendrier | Effets d'année calendaire (test de Mack) | M3 | bas | 0,002 | 0,0014 | test, ECHEC |
| KruskalAcc | Homogénéité des résidus entre années de survenance | M3 | haut | 0,300 | 0,0145 | test, OK |
| CorrDev | Corrélation entre années de développement adjacentes | M3 | deux | 0,170 | 0,0176 | test, OK |
| DW | Autocorrélation des résidus (Durbin-Watson) | M3 | deux | 0,032 | 0,0079 | test, ECHEC |
| Runs | Test des suites sur les résidus de Mack | M3 | deux | 0,374 | 0,0247 | diagnostic (variante secondaire), INFO |
| MinP4 | Cellule aberrante du triangle (résidus studentisés externes) | M4 | bas | 0,898 | 0,0096 | test, OK |

Les neuf clés hors des quatre changements gardent la p_mc du tableau du 11/10/2026 [V, comparaison des deux tableaux].

**3. Points de comparaison.** Les cellules du 11/10/2026 (T1, T1 bis, T2, T3, T4) des clés **Calendrier, BP, Grubbs et PenteIntra** portent sur des statistiques ou des sens que le moteur ne calcule plus. Elles **ne servent pas de point de comparaison** pour la remesure : aucune évolution n'est lue entre les deux mesures pour ces quatre clés. Pour les neuf autres clés, la comparaison reste descriptive. Les empreintes (i3) des deux mesures diffèrent, puisque le moteur a changé ailleurs. Les cellules du pool brut et de la loi A, que la remesure de Fk ne reprend pas, restent valides à leur commit cité (C-206-2), pour ces neuf clés seulement.

**4. Ensemble « à la frontière »** (§ 5, paragraphe « Lignes à la frontière de `reserve2` »).
- **Liste retirée** : la liste figée (BP 0,103 ; Origine 0,085 ; HomogF 0,080) date du moteur d'avant #301 et #307.
- **Règle** : est « à la frontière » toute ligne de type test telle que |p_mc − s| < 2 err_mc pour un seuil atteignable s ∈ {α ; α/2} (sens « ne pas rejeter »), **calculée sur la référence versionnée**. C'est la règle de #244, que `add()` applique en posant `PHRASE_VERDICT_SENSIBLE_MC` (`R/engine.R:4462-4478`).
- **Lecture dans le script** : `tests/calibration_mc_mw_t8.R` (l. ~1211) la lit dans la référence, comme `NL_MAX` (l. 708), et non dans une liste écrite en dur.
- **Sur `reserve2` à `1efa88b` [V]** : PenteIntra (0,090 ; |p − α| = 0,76 err_mc) et Origine (0,085 ; 1,70 err_mc). HomogF (0,080 ; 2,33 err_mc) est juste au-delà du critère, et BP (0,285) hors de l'ensemble.
- La lecture de ces lignes avec leur τ (§ 5) est inchangée.

---

# Annexe B — commentaire proposé pour #297 (à publier après Q-D1-Fk-11)

> *Rédigé par l'agent actuary (IA)*, d'après la spécification D1-Fk du 24/10/2026 (`docs/specifications/fk-lecture-conjointe.md`, branche Fk, PR #374). Publié sur accord du mainteneur le <date>, après les décisions Q-D1-Fk.

**Mise à jour du corps de l'issue.** Le corps date du 15/10/2026. Les points ci-dessous le remplacent là où ils divergent ; le moteur de référence est à `1efa88b`.

**1. Constat.**
- La phrase « Avec 34 lignes indépendantes, on attendrait 97 % » n'est plus à jour. Les références comptent aujourd'hui :
  - 18 tests sur `premium` (δ̂ au bord) ;
  - 24 sur `premium_interieur` (δ̂ intérieur) ;
  - 12 sur `reserve2`.

  Le repère 1 − 0,9^k vaut 0,850, 0,920 et 0,718 ; c'est un ordre de grandeur, pas une référence.
- Sous la loi bootstrap de chaque cas, la probabilité qu'au moins un test ait une p Monte-Carlo inférieure à 0,10 vaut 0,509 (`premium`), 0,630 (`premium_interieur`) et 0,658 (`reserve2`). Source : spécification, § 1.5, mesure sur les réplications des références.
- Les fréquences citées restent celles de leurs mesures :
  - lognormal : `doc_tests_usp.tex`, l. 17431-17437 (63,45 % sur J1, 66,0 % sur J2) ;
  - Merz-Wüthrich : l. 19393 (63,6 à 65,5 %), mesurées avant #276, #301, #300 et #312.

**2. Familles.**
- **M4** est la ligne MinP4 (#300) ; Grubbs n'y figure plus.
- **M3** a quatre tests (Calendrier, KruskalAcc, CorrDev, DW) : le test des suites est un diagnostic depuis #312.
- M1 compte 5 tests, M2 2.
- Lognormal : B. 4 (Intercept, RESET, SpearVol, MK), C. 1, D. 6, E. 3 au bord ou 5 à δ̂ intérieur, F. 3 ou 6.
- G., M5 et M6 n'ont aucun test, donc aucune ligne de famille.

**3. Membres d'une famille.** Une ligne en est membre si elle réunit toutes les conditions suivantes :
- type `test` ;
- variante principale ;
- sens « ne pas rejeter » ;
- `mc_nom` renseigné (#330) et p Monte-Carlo finie.

La composition est figée à l'observé. Le test de Pitman et le TOST, de sens « rejeter », sont exclus : une petite p y conforte le modèle.

**4. Construction.**
- Le rang de chaque réplication est calculé **parmi toutes les réplications, observé compris**, en arithmétique entière. La p de l'observé est alors exactement la `p_mc` de la ligne.
- La p de famille vaut (1 + #{b : m(b) ≤ m_obs}) / (B_eff + 1).
- Le rang « parmi les autres réplications » du corps est abandonné. Il met les réplications sur une autre grille que l'observé et devient libéral aux atomes : sur `reserve2`, la p globale vaudrait 0,010 au lieu de 0,024, et celle de M3 0,003 au lieu de 0,008.

**5. Lignes dont la p exacte est retenue** (SpearVol, MK, DW et Runs, à π_t constant). Elles entrent par leur p Monte-Carlo, et non par une p exacte recalculée par réplication. Les données des réplications ne sont pas toutes conservées, et la p de famille resterait de toute façon une p bootstrap. *[Selon Q-D1-Fk-4.]*

**6. Portée.** La p de famille contrôle le taux d'erreur de la famille **au sens faible** (toutes ses hypothèses vraies), sous le modèle ajusté. C'est une p plug-in, non exacte, au même titre que chaque p Monte-Carlo.

**7. Famille d'un seul test et ligne globale.** *[Selon Q-D1-Fk-2 et Q-D1-Fk-3.]*
- Une famille d'un seul test (C. ; M4) n'a pas de ligne : sa p serait exactement celle du test.
- Une ligne globale minP par méthode est ajoutée, sous le préfixe `LC`.

**8. Effet sur les résultats.**
- Aucune simulation nouvelle, aucune graine nouvelle. Aucune p, aucun verdict et aucune ligne existante ne change ; σ_USP est inchangé.
- Lignes ajoutées en diagnostic, INFO, après les lignes existantes :
  - quatre familles et la ligne globale sur les cas lognormaux ;
  - trois familles et la ligne globale sur `reserve2`.
- La matrice des réplications est rendue dans `bootstrap$stats_boot`.
- Les références sont régénérées pour la structure ; les chemins existants restent identiques.

**9. Référence.** Westfall et Young (1993) n'a toujours pas été relu sur pièce ; le relevé groupé est commandé. L'ouvrage est cité pour le nom et l'origine de la procédure minP. La construction et sa validité sous échangeabilité sont établies dans la spécification, § 2.1, sans dépendre de ses formules.

**10. Mesure.** Le niveau réel de la p de famille à T = 8 est mesuré à l'étape 5 de Fk, en une seule exécution au budget plafonné, avec un critère fixé avant l'exécution. Le point d'arrêt D2-Fk suit.

---

# Annexe C — scripts de la consultation (lecture seule, sorties hors du dépôt)

Lancés sous `LC_ALL=C.UTF-8` le 24/10/2026, depuis la racine du dépôt à `1efa88b`. Les sorties `.txt` et les captures `.rds` étaient dans le scratchpad de la session. Elles ne sont pas versionnées : la décision sur leur versionnement en tableau daté revient à Q-D1-Fk-11. La variable d'environnement `D` désigne le dossier de sortie, hors du dépôt, à créer avant le lancement. Ordre : `b_capture.R` (écrit `capture.rds`, lu par les autres), puis `c_lignes.R`, `d_proto.R`, `e_cout_exact.R`, `f_compte.R`.

## `b_capture.R`

```r
# Capture, hors depot, de mc_nom par ligne et de la matrice des replications
# retenues passee a .mc_p_values(), pour les six cas de reference.
suppressMessages(source("tests/outils_tests.R"))
CAPT <- new.env()
.orig_reg <- engine_registre_tests
engine_registre_tests <- function(boot, catalogue, alpha, nature_mc) {
  reg <- .orig_reg(boot, catalogue, alpha, nature_mc)
  a0 <- reg$add
  reg$add <- function(fam, nom, ref, ..., mc_nom = NA_character_, p_mc_ext = NA_real_) {
    CAPT$lignes[[length(CAPT$lignes) + 1]] <- list(famille = fam, test = nom,
      mc_nom = mc_nom, ext = !is.na(p_mc_ext))
    if (missing(ref)) a0(fam, nom, ..., mc_nom = mc_nom, p_mc_ext = p_mc_ext)
    else a0(fam, nom, ref, ..., mc_nom = mc_nom, p_mc_ext = p_mc_ext)
  }
  reg
}
.orig_mcp <- .mc_p_values
.mc_p_values <- function(sim, obs, catalogue, e = NULL) {
  CAPT$sim <- sim; CAPT$obs <- obs
  .orig_mcp(sim, obs, catalogue, e)
}
out <- list()
for (cas in names(CAS)) {
  CAPT$lignes <- list(); CAPT$sim <- NULL
  t0 <- proc.time()[["elapsed"]]
  res <- executer_cas(cas)
  dt <- proc.time()[["elapsed"]] - t0
  ref <- readRDS(chemin_reference(cas))
  cmp <- comparer_objets(ref, res); cmp_ok <- if (is.data.frame(cmp)) nrow(cmp) == 0 else NA
  cat(sprintf("%s : %.1f s ; comparaison a la reference : %s ; lignes capturees %d, res$tests %d\n",
              cas, dt, if (isTRUE(cmp_ok)) "OK" else paste(capture.output(str(cmp, max.level=1)), collapse=" "),
              length(CAPT$lignes), length(res$tests)))
  out[[cas]] <- list(res = res, lignes = CAPT$lignes, sim = CAPT$sim, obs = CAPT$obs, duree = dt)
}
saveRDS(out, file.path(Sys.getenv("D"), "capture.rds"))
```

## `c_lignes.R`

```r
cap <- readRDS(file.path(Sys.getenv("D"), "capture.rds"))
pref <- function(f) sub("^([A-G]\\.|M[0-9]).*$", "\\1", f)
for (cas in names(cap)) {
  x <- cap[[cas]]; L <- x$res$tests
  stopifnot(identical(vapply(L, `[[`, "", "test"), vapply(x$lignes, `[[`, "", "test")))
  d <- data.frame(
    pf = pref(vapply(L, `[[`, "", "famille")),
    test = substr(vapply(L, `[[`, "", "test"), 1, 44),
    type = substr(vapply(L, `[[`, "", "type"),1,5),
    var = substr(vapply(L, `[[`, "", "variante"),1,4),
    base = vapply(L, `[[`, "", "base"),
    verd = vapply(L, `[[`, "", "verdict"),
    nat = substr(vapply(L, function(l) as.character(l$nature_p), ""),1,12),
    p_ex = signif(vapply(L, `[[`, 0, "p_exacte"),3),
    p_mc = signif(vapply(L, `[[`, 0, "p_mc"),3),
    e_mc = signif(vapply(L, `[[`, 0, "err_mc"),2),
    p_as = signif(vapply(L, `[[`, 0, "p_asymptotique"),3),
    mc = vapply(x$lignes, function(l) as.character(l$mc_nom), ""),
    ext = vapply(x$lignes, `[[`, TRUE, "ext"),
    sens = substr(vapply(L, function(l) as.character(l$sens), ""),1,6),
    stringsAsFactors = FALSE)
  cat("\n=====", cas, ": lignes", nrow(d), "; matrice", nrow(x$sim), "x", ncol(x$sim),
      "; lignes finies (toutes colonnes) ", sum(stats::complete.cases(x$sim)),
      "; lignes non toutes NA", sum(rowSums(is.finite(x$sim))>0), "\n")
  print(d, row.names = FALSE, width = 250)
}
```

## `d_proto.R`

```r
# Prototype hors moteur de la p de famille (minP sur les rangs Monte-Carlo),
# sur les matrices capturees par b_capture.R. Aucune ecriture dans le depot.
suppressMessages(source("R/engine.R"))
cap <- readRDS(file.path(Sys.getenv("D"), "capture.rds"))
pref <- function(f) sub("^([A-G]\\.|M[0-9]).*$", "\\1", f)
# numerateurs entiers des p de rang de chaque item (lignes de A) dans sa colonne
num_p <- function(v, queue) {
  N <- length(v)
  up <- rank(-v, ties.method = "max"); dn <- rank(v, ties.method = "max")
  switch(queue, haut = up, bas = dn, deux = pmin(2 * pmin(up, dn), N))
}
famille_p <- function(S, obs, cols, queues, variante = c("sym", "loo")) {
  variante <- match.arg(variante)
  X <- S[, cols, drop = FALSE]
  ok <- apply(is.finite(X), 1L, all); X <- X[ok, , drop = FALSE]; n <- nrow(X)
  o <- vapply(cols, function(c) obs[[c]], 0)
  if (variante == "sym") {
    A <- rbind(o, X); N <- n + 1
    P <- vapply(seq_along(cols), function(j) num_p(A[, j], queues[[j]]), numeric(N))
    P <- matrix(P, nrow = N)
    m <- apply(P, 1L, min)
    list(p = (sum(m[-1] <= m[1]) + 1) / (n + 1), m_obs = m[1] / N, B_eff = n,
         p_obs = P[1, ] / N)
  } else {
    # rangs des replications parmi les autres replications seulement (texte de #297)
    Pr <- vapply(seq_along(cols), function(j) {
      v <- X[, j]; up <- rank(-v, ties.method = "max"); dn <- rank(v, ties.method = "max")
      # (1 + #{autres >= v_b}) / n = up / n
      switch(queues[[j]], haut = up, bas = dn, deux = pmin(2 * pmin(up, dn), n)) }, numeric(n))
    Pr <- matrix(Pr, nrow = n)
    po <- vapply(seq_along(cols), function(j) {
      r <- engine_p_mc(X[, j], o[[j]], queues[[j]]); r$p_mc }, 0)
    mb <- apply(Pr, 1L, min) / n
    list(p = (sum(mb <= min(po)) + 1) / (n + 1), m_obs = min(po), B_eff = n, p_obs = po)
  }
}
res_tab <- list()
for (cas in names(cap)) {
  x <- cap[[cas]]; L <- x$res$tests
  cat_mc <- if (x$res$metadata$methode == "reserve2") MW_CATALOGUE_MC else USP_CATALOGUE_MC
  info <- data.frame(pf = pref(vapply(L, `[[`, "", "famille")),
                     type = vapply(L, `[[`, "", "type"),
                     var = vapply(L, `[[`, "", "variante"),
                     sens = vapply(L, function(l) as.character(l$sens), ""),
                     p_mc = vapply(L, `[[`, 0, "p_mc"),
                     mc = vapply(x$lignes, function(l) as.character(l$mc_nom), ""),
                     ext = vapply(x$lignes, `[[`, TRUE, "ext"), stringsAsFactors = FALSE)
  memb <- info$type == "test" & info$var == "principale" & info$sens %in% "ne pas rejeter" &
    !is.na(info$mc) & !info$ext & is.finite(info$p_mc)
  hors <- info$type == "test" & info$var == "principale" & !memb
  fams <- c(sort(unique(info$pf[memb])), "GLOBAL")
  for (f in fams) {
    sel <- memb & (f == "GLOBAL" | info$pf == f)
    cols <- info$mc[sel]; q <- lapply(cols, function(c) cat_mc[[c]]$queue)
    t0 <- proc.time()[["elapsed"]]
    a <- famille_p(x$sim, x$obs, cols, q, "sym")
    dt <- proc.time()[["elapsed"]] - t0
    b <- famille_p(x$sim, x$obs, cols, q, "loo")
    repro <- isTRUE(all(a$p_obs == info$p_mc[sel]))
    res_tab[[length(res_tab) + 1]] <- data.frame(cas = cas, famille = f, k = length(cols),
      exclus_test = if (f == "GLOBAL") sum(hors) else sum(hors & info$pf == f),
      B_eff = a$B_eff, m_obs = signif(a$m_obs, 4), p_fam = round(a$p, 4),
      err = round(sqrt(a$p * (1 - a$p) / a$B_eff), 4), p_loo = round(b$p, 4),
      p_obs_identiques = repro, duree_s = round(dt, 3), stringsAsFactors = FALSE)
  }
}
tab <- do.call(rbind, res_tab)
print(tab, row.names = FALSE)
# Bonferroni pour memoire (k * m_obs, borne a 1)
tab$bonf <- pmin(1, tab$k * tab$m_obs)
cat("\nBonferroni k*m_obs (repere) :\n"); print(tab[, c("cas","famille","k","m_obs","p_fam","bonf")], row.names = FALSE)
saveRDS(tab, file.path(Sys.getenv("D"), "proto_tab.rds"))
# taille de la matrice serialisee
for (cas in names(cap)) {
  f <- tempfile(fileext = ".rds"); saveRDS(cap[[cas]]$sim, f)
  cat(sprintf("%s : matrice %d x %d, rds %d octets\n", cas, nrow(cap[[cas]]$sim), ncol(cap[[cas]]$sim), file.size(f)))
  unlink(f)
}
```

## `e_cout_exact.R`

```r
suppressMessages(source("R/engine.R"))
cap <- readRDS(file.path(Sys.getenv("D"), "capture.rds"))
zb <- cap$premium$res$bootstrap$z_boot
ok <- apply(is.finite(zb), 1, all)
cat("lignes finies de z_boot (premium) :", sum(ok), "\n")
t0 <- proc.time()[["elapsed"]]; pdw <- apply(zb[ok, ], 1, dw_p_exacte); t1 <- proc.time()[["elapsed"]]
pru <- apply(zb[ok, ], 1, runs_p_exacte); t2 <- proc.time()[["elapsed"]]
cat(sprintf("dw_p_exacte x %d : %.2f s ; runs_p_exacte : %.2f s\n", sum(ok), t1 - t0, t2 - t1))
cat("DW exacte NA :", sum(!is.finite(pdw)), " ; Runs exacte NA :", sum(!is.finite(pru)), "\n")
# coherence : DW de la replication = colonne DW de la matrice ?
cat("DW(z_boot) identique a la colonne DW de la matrice :",
    isTRUE(all.equal(apply(zb[ok, ], 1, stat_dw), unname(cap$premium$sim[ok, "DW"]), tolerance = 0)), "\n")
cat("premium_interieur, variante :", cap$premium_interieur$res$bootstrap$p_mc_regime$variante,
    "retenus V1 :", cap$premium_interieur$res$bootstrap$p_mc_regime$retenus_v1,
    "retenus :", cap$premium_interieur$res$bootstrap$p_mc_regime$retenus,
    "tirages :", cap$premium_interieur$res$bootstrap$p_mc_regime$tirages, "\n")
```

## `f_compte.R`

```r
# Variante "compte" (nombre de lignes membres a p < alpha), construction symetrique.
suppressMessages(source("R/engine.R"))
cap <- readRDS(file.path(Sys.getenv("D"), "capture.rds"))
pref <- function(f) sub("^([A-G]\\.|M[0-9]).*$", "\\1", f)
num_p <- function(v, queue) { N <- length(v)
  up <- rank(-v, ties.method = "max"); dn <- rank(v, ties.method = "max")
  switch(queue, haut = up, bas = dn, deux = pmin(2 * pmin(up, dn), N)) }
for (cas in c("premium", "reserve2", "premium_interieur")) {
  x <- cap[[cas]]; L <- x$res$tests
  cat_mc <- if (x$res$metadata$methode == "reserve2") MW_CATALOGUE_MC else USP_CATALOGUE_MC
  ty <- vapply(L, `[[`, "", "type"); va <- vapply(L, `[[`, "", "variante")
  se <- vapply(L, function(l) as.character(l$sens), ""); mc <- vapply(x$lignes, function(l) as.character(l$mc_nom), "")
  ext <- vapply(x$lignes, `[[`, TRUE, "ext"); pm <- vapply(L, `[[`, 0, "p_mc")
  memb <- ty == "test" & va == "principale" & se %in% "ne pas rejeter" & !is.na(mc) & !ext & is.finite(pm)
  cols <- mc[memb]
  X <- x$sim[, cols, drop = FALSE]; ok <- apply(is.finite(X), 1, all); X <- X[ok, , drop = FALSE]
  A <- rbind(vapply(cols, function(c) x$obs[[c]], 0), X); N <- nrow(A)
  P <- sapply(seq_along(cols), function(j) num_p(A[, j], cat_mc[[cols[j]]]$queue)) / N
  for (a in c(0.10, 0.05)) {
    cnt <- rowSums(P < a)
    cat(sprintf("%s alpha %.2f : k = %d, N_obs = %d, P*(N >= N_obs) = %.4f ; E*[N] = %.2f ; P*(N >= 1) = %.3f\n",
                cas, a, length(cols), cnt[1], mean(cnt >= cnt[1]), mean(cnt[-1]), mean(cnt[-1] >= 1)))
  }
}
```

---

## Annotation du 25/10/2026 : validation du code de #297, décisions du mainteneur sur les textes et sur l'invariant I5

> *Consignée par la session principale (IA)* ; sources : validation de fond du code de #297 par `actuary-approfondi` (deux consultations, lecture seule), audit léger (`audit`, conforme avec réserves) et revue légère de l'affichage (`app-review`, sans écart bloquant), puis réponses du mainteneur aux questions de la session principale. Toutes les décisions suivent les recommandations d'`actuary-approfondi`. Aucune valeur numérique, aucun σ_USP ni aucun verdict ne change ; seuls changent des textes, l'ordre des lignes ajoutées et l'affichage. Le présent document reste inchangé au-dessus de cette annotation, qui le corrige là où elle diverge.

1. **Invariant I5 de #59** (`CONTEXT.md`) : le mainteneur accepte une **exception limitée aux lignes de lecture conjointe**. La présence d'une ligne de famille dépend des données (à volumes constants, la famille B. ne garde que MK et n'a pas de ligne : 51 lignes au lieu de 52) ; I5 reste vrai pour toutes les autres lignes. Une ligne de famille absente pour k = 1 ne cache aucune information, la ligne du test portant la même p (§ 1.4). Un test positif protège l'exception ; `architect` l'annote dans `CONTEXT.md`. La spécification n'avait pas confronté la règle de Q-D1-Fk-2 à I5 (omission reconnue par son auteur).
2. **Condition de T-3a** (contradiction interne levée par son auteur, sans décision du mainteneur) : la phrase est posée quand le B effectif de famille est inférieur au B effectif d'au moins un membre (§ 3), et non quand il est inférieur à B (intitulé du § 4.4, raccourci écrit en supposant B_eff = B pour chaque membre). Les deux conditions coïncident sur les six cas.
3. **T-2 remplacé** (décision du mainteneur) : la clause « au moins un verdict ALERTE ou ECHEC correspond a une plus petite p inferieure a alpha » est réfutée par la mesure (TOST de sens « rejeter » en ALERTE sur `premium_interieur` avec m_obs = 0,105 > α ; m_obs porte sur les p Monte-Carlo et non sur les p retenues). Nouveau texte : celui de la recommandation d'`actuary-approfondi`, qui précise que la ligne porte sur les p Monte-Carlo des tests, que les lignes de sens « rejeter » n'y entrent pas et qu'elle porte sur tous les tests quelle que soit la sélection de restitution.
4. **T-1** (décision du mainteneur) : les membres sont cités sous la forme « nom du test [clé] », introduits par « Tests de la famille (tous, quelle que soit la selection de restitution) : … ».
5. **T-3a, texte précisé** (décision du mainteneur) : « Calculee sur les seules replications ou les statistiques de tous les tests de la famille sont finies, moins nombreuses que celles d'au moins un test : la plus petite p peut alors differer de la plus petite p Monte-Carlo affichee. »
6. **Champs de la ligne globale** (décision du mainteneur) : `stat_nom` « plus petite p Monte-Carlo de la batterie » (inchangé pour les lignes de famille) ; `reference` complétée par Ge, Dudoit et Speed (2003), rapport technique 633, éq. (10), relu dans le relevé groupé (`docs/references/verifications-fk.md`, `a19c792`), Westfall et Young (1993) restant cité pour le nom de la procédure.
7. **Affichage** (sans décision du mainteneur) : la vue Synthèse affiche, pour les seules lignes de `engine_p_famille`, la p de famille comme valeur non retenue (« p de famille (Monte-Carlo) = … — diagnostic, aucune p retenue ») ; « p retenue » et « Nature » restent à « – » (ADR 0001). Pas de règle générale pour les autres diagnostics.
8. **§ 4.4, nombre k** : k ne lit aucune valeur numérique du bootstrap, mais peut dépendre de la *disponibilité* d'une p Monte-Carlo (événement discret) ; formulation à reprendre par `docwriter`.
