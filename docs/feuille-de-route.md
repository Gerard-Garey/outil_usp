# Feuille de route

> *Rédigé par l'agent architect (IA), point d'étape du 21 septembre 2026, sur `main` au commit `1a4e726`. Ce document se met à jour à chaque série de PR fusionnées (revue périodique prévue par `CLAUDE.md`, « Sous-agents ») : cocher les cases, déplacer les jalons terminés dans l'historique en fin de document, ne pas réécrire le reste.*

Finalité qui ordonne tout : un dossier soumis à l'ACPR, où le relecteur doit pouvoir suivre chaque résultat de la formule réglementaire au code, du code à la documentation, et de la documentation aux tests. Un chantier est **indispensable à la remise** s'il corrige un écart au règlement, un résultat faux, ou une affirmation fausse de la documentation sur ce que fait le code. Tout le reste est de la qualité de forme : utile, mais différable.

## 1. État des lieux

Six issues ouvertes, aucune PR ouverte, batterie de 242 assertions unitaires dont 20 échecs attendus qui documentent les défauts connus (`tests/unitaires/test_defauts_connus.R` et fichiers thématiques).

| Issue | Objet | Libellé | Bloquée par |
|---|---|---|---|
| #1 | Doc : sous-section « graines » incomplète | `ready-for-agent` | rien (mais à faire *après* la piste 2 de #4 pour documenter l'état final) |
| #2 | `docs/exigences.md` tronqué au § 5.5 | `ready-for-human` | **mainteneur** (seul détenteur du texte) |
| #3 | Test de centrage dégénéré quand δ̂ est au bord | `ready-for-agent` | rien |
| #4 | Revue d'architecture, quatre pistes | `needs-triage` | rien ; pistes triées ci-dessous |
| #5 | Revue actuarielle à T = 8, sept chantiers | `needs-triage` | rien ; chantiers triés ci-dessous |
| #7 | MSEP réserve n° 2 non conforme à D(5) ; σ_USP sous-estimé | `ready-for-human` | **mainteneur** (lecture du texte à arbitrer) |

### Recoupements entre issues

| Zone du dépôt | Issues qui s'y rencontrent | Conséquence |
|---|---|---|
| `.stats_bootstrapables()`, `queue` de `usp_bootstrap()`, `add()` de `usp_tests()`, fiches « Centrage » et « Variance unitaire », tableaux 1-2, index | #3, #4 piste 1, #5 chantier 1 | même jalon, PR séquencées (J1) |
| `usp_bootstrap()`, `mw_bootstrap()`, `sw_loi_nulle()`, `engine_plots_data()`, xlsx, sous-section « graines » | #1, #4 piste 2, #5 chantier 6 | même jalon (J2) |
| `usp_ajuster_rapide()` et la loi bootstrap de tout ce qui suit | #5 chantier 2 (préalable) | à trancher **avant** tout chantier qui régénère des p_mc lognormales (J0) |
| `mw_msep()` / `mw_parametre()` (#7) contre `mw_bootstrap()` / `mw_residus()` (#5 chantier 5) | #7, #5 chantier 5 | fonctions distinctes, mais même fichier de référence `reserve2.rds` et même IC bootstrap : PR séquencées (J3 puis J6) |
| `engine_valider_donnees()`, lecture CSV/xlsx, `usp_charger()`, `mw_valider_triangle()`, `charger_ln()`/`charger_mw()` de `app.R` | #4 piste 3, #7 points mineurs | même jalon (J7) |

### Écarts constatés à la lecture (en plus des revues #4, #5, #7)

- `docs/latex/doc_tests_usp.tex`, sous-section « Reproductibilité et gestion des graines » : affirme qu'aucune fonction hors `usp_bootstrap()` et `engine_plots_data()` ne tire d'aléa ; faux (#1). Indispensable à corriger : c'est l'affirmation de reproductibilité du dossier.
- Ligne « Position de delta dans [0,1] » de `usp_tests()` : `type = "diagnostic"` mais verdict `ALERTE`/`OK`, contraire à `CONTEXT.md` (un diagnostic est affiché INFO). À résoudre avec le chantier « identifiabilité de δ » (J5), où `actuary` dira si cette ligne devient un test (LR de Self & Liang) ou reste un diagnostic INFO.
- `tests/reference/*.rds` sont comparées par `all.equal()` sur l'objet **complet** : tout champ ajouté ou retiré, toute ligne de test ajoutée impose une régénération, même sans changement de valeur. Un refactor n'est donc protégé par la non-régression que s'il laisse la structure et les valeurs strictement identiques ; c'est la règle de découpage des PR ci-dessous.
- Sondage (200 réplications, graine 20260831, données de test, non versionné) : `usp_ajuster_rapide()` et `usp_ajuster()` donnent 97,5 % de δ* au bord l'un comme l'autre, une seule réplication diverge (|Δδ*| > 10⁻³), et les quantiles 5 %, 50 %, 95 % de σ* coïncident à 10⁻⁵. C'est un constat empirique, pas une démonstration : le protocole de #5 (J0) reste à exécuter et à consigner, mais il rend peu probable une invalidation des p_mc existantes.

## 2. Règles de découpage adoptées

> *Depuis le 22 septembre 2026 (ADR 0007) : une seule branche de travail à la fois, au périmètre fermé d'issues ; la règle 1 ci-dessous s'applique désormais au **commit** et non plus à la PR — un commit par issue qui change un résultat, avec son tableau avant / après.*

1. **Une PR ne porte qu'un seul motif de changement de résultats.** Une PR qui change des valeurs (σ_USP, p-value, verdict) ne contient aucun refactor ; le refactor suit dans une PR dont le critère d'acceptation est « références strictement identiques ». Corollaire : la PR de refactor n'a pas de tableau avant / après, et c'est ce qui la protège.
2. **Un changement de structure sans changement de valeur** (champ ajouté, ligne de test ajoutée) régénère les références, mais son tableau avant / après ne doit contenir que des lignes « absent / ajouté » ; toute ligne de valeur modifiée est une régression.
3. **Régénérations à valeurs modifiées** — le seul coût réel, car chaque ligne du tableau doit être expliquée et approuvée. Elles sont limitées à : J1a (deux verdicts OK → INFO, méthodes lognormales), J3 (σ_USP réserve n° 2), J4 (verdicts et `nature_p`, méthodes lognormales), J6 (p_mc et IC bootstrap Merz-Wüthrich), et J0 seulement si le préalable révèle une divergence. Aucun autre jalon ne doit modifier une valeur existante.
4. **Fichiers de référence séparés** : `premium.rds` et `reserve1.rds` ne bougent que pour les jalons lognormaux, `reserve2.rds` que pour les jalons Merz-Wüthrich. `Rscript tests/generer_references.R <cas>` ne régénère que le cas concerné.
5. **Un ADR par décision de forme** avant le code : ADR 0003 (catalogue Monte-Carlo, J1b), ADR 0004 (graine locale, J2), ADR 0005 à rédiger après l'arbitrage du mainteneur sur #7 (J3).
6. **`docwriter` passe après `coder` sur une même branche**, jamais en parallèle ; la piste documentaire D, qui ne touche que des sections sans rapport avec les jalons de code en cours, est la seule exception, sur sa propre branche.

## 3. Jalons

Légende des colonnes « Effet » : σ = σ_USP, V = verdicts, p = p-values, S = structure de l'objet résultat seulement, Ø = aucun.

### Vue d'ensemble

| Ordre | Jalon | Issues | Effet | Démarrage conditionné par | Indispensable à la remise |
|---|---|---|---|---|---|
| J0 | Préalable : ajusteur rapide contre ajusteur complet | #5-2 (préalable) | Ø (ou p si divergence) | rien | oui (fonde toutes les p_mc) |
| J1 | Tests dégénérés puis catalogue Monte-Carlo | #3, #5-1, #4-1 | J1a : V (2 lignes) + S ; J1b : Ø | rien | J1a oui ; J1b oui (retire un défaut silencieux) |
| J2 | Aléa à graine locale, doc des graines, enveloppe QQ | #4-2, #1, #5-6 | J2a : Ø ; J2b : S (graphique) | J1 fusionné (même code) | J2a oui ; J2b non |
| J3 | MSEP réserve n° 2 | #7 (bloquant) | σ, IC | **arbitrage du mainteneur** ; analyses `regulatory` et `actuary` déblocables tout de suite | **oui, prioritaire** |
| J4 | Verdicts et p-values retenues | #5-3, #5-4 | V, `nature_p`, p retenue | J1 fusionné ; spécification `actuary` | oui |
| J5 | Identifiabilité de δ | #5-2 (restitution) | S (test ajouté) | J0 conclu, J2 fusionné (graine locale), J4 fusionné (règle inopérant) | oui |
| J6 | Bootstrap Merz-Wüthrich | #5-5 | p_mc MW, IC, V possibles | J3 fusionné | oui |
| J7 | Entrées et validation | #4-3, #7 mineurs et majeur | Ø | J3 fusionné (touche `mw_parametre()`) | partiellement (refus d'une réserve ≤ 0) |
| J8 | Forme de résultat commune | #4-4 | S | J7 fusionné | non, sauf le défaut visible de `bloc_final` |
| D | Écarts code ↔ doc sans changement de code | #5-7 (partie doc) | Ø | rien | oui |
| J9 | Test de Bartels, table de puissance | #5-7 (reste) | S | décision de périmètre du mainteneur | non |
| JF | Relecture intégrale avant remise | #2 | Ø | #2 résolu, tous les jalons « oui » fusionnés | oui |

Parallélisme possible dès maintenant : J0, J1a, D, et les analyses de J3 (sans code). Ensuite J1b, puis J2 et J4 sur des branches distinctes (J2 touche `usp_bootstrap()`/`mw_bootstrap()`, J4 touche `add()` et `usp_tests()` : fusionner J2 avant J4 ou rebaser).

---

### J0 — Préalable : `usp_ajuster_rapide()` contre `usp_ajuster()`

**Pourquoi d'abord.** Toutes les p_mc lognormales et la loi bootstrap de σ* reposent sur le réajustement à chaud (un démarrage, `factr = 1e7`, départ à (δ̂, γ̂)). Si ce réajustement fabriquait le taux de δ* au bord, chaque jalon suivant régénérerait des références qu'il faudrait régénérer encore. Le protocole coûte une dizaine de secondes de calcul par centaine de réplications : il n'y a aucune raison de le différer. Le sondage de l'architecte (§ 1) laisse attendre une conclusion négative (pas de divergence).

- Périmètre : script hors CI sous `tests/` (à côté de `tests/unitaires/generer_valeurs_externes.R`), protocole de #5 : ≥ 100 réplications sous le modèle ajusté, comparaison des distributions de δ*, γ*, σ* et du taux au bord entre les deux ajusteurs, avec la graine et les données consignées ; paragraphe de résultat dans la section « Vérification empirique de l'implémentation » de la doc.
- Circuit : `actuary` fixe le protocole et les critères de divergence → `coder` écrit le script et rend le tableau → `actuary` conclut → `docwriter` consigne.
- Effet sur les résultats : aucun si conclusion négative. Si divergence : PR corrective séparée (`coder` → `audit` → `actuary`), qui change **toutes** les p_mc lognormales et l'IC bootstrap ; elle passe alors **avant** J1a et J4, et le mainteneur approuve son tableau (des verdicts peuvent bouger).
- Critères d'acceptation : script reproductible à graine fixe ; tableau des deux distributions ; conclusion écrite par `actuary` avec le statut épistémique « constat de simulation ».
- [ ] protocole `actuary` — [ ] script et tableau `coder` — [ ] conclusion `actuary` — [ ] paragraphe doc `docwriter`

### J1 — Tests dégénérés (J1a) puis catalogue Monte-Carlo (J1b)

**Désaccord avec #4 et #5**, qui proposent une même branche pour #3 et la piste 1 : je les sépare en deux PR successives. Faire les deux ensemble priverait le refactor de sa seule protection efficace (références identiques), puisque la PR régénérerait de toute façon les références pour le passage à INFO.

**J1a — #3 et #5 chantier 1** (brief déjà rédigé en commentaire de #3, complété par #5) :
- Périmètre : « Centrage » et « Variance unitaire » deviennent des diagnostics (INFO, sans p-value retenue, `detail` expliquant la contrainte par construction à δ̂ = 1) ; `MeanZ`, `VarZ`, `LB2r`, `BP2r` retirés de `.stats_bootstrapables()` et du vecteur `queue` ; `INSTABLES` vidé ; échecs attendus correspondants transformés en tests ordinaires (`test_defauts_connus.R` : « Centrage … verdict INFO », « pas d'orpheline » ; la marque « statistique affichée = simulée » sur le centrage disparaît avec la p_mc) ; fiches « Centrage » et « Variance unitaire », tableaux 1-2, index (« 38 statistiques » → 34) ; sous-section « graines » : retirer la phrase sur la grandeur instable (le reste de cette sous-section relève de J2).
- Circuit : `coder` → `audit` → `docwriter` → `actuary`.
- Effet : deux verdicts OK → INFO (méthodes prime et réserve n° 1), quatre champs de `bootstrap$p_mc`/`err_mc` retirés ; **aucune autre p-value, aucun autre verdict, σ_USP inchangé** — c'est le critère d'acceptation, vérifié par le tableau de `comparer_references.R`. Le principe OK → INFO est acquis (ADR 0001) ; le tableau est néanmoins joint à la PR et le mainteneur le vise (règle de `CLAUDE.md`).
- [ ] PR J1a fusionnée — [ ] `INSTABLES` vide — [ ] fiches et tableaux à jour — [ ] #3 fermée

**J1b — #4 piste 1, ADR 0003** :
- Périmètre : un catalogue par méthode (nom → fonction de calcul, sens du rejet, condition de dégénérescence) ; une seule fonction d'enregistrement des lignes de test partagée par `usp_tests()` et `mw_tests()` (le libellé de nature « bootstrap paramétrique » / « bootstrap de résidus » devient un paramètre) ; erreur explicite sur un `mc_nom` inconnu ; statistique affichée lue au catalogue (renommer `"Intercept"` de Merz-Wüthrich en un nom qui dit ce qu'il mesure) ; dégénérescence d'une statistique simulée détectée par le moteur et restituée comme diagnostic INFO, jamais par repli sur l'asymptotique.
- Circuit : `coder` → `audit` → `docwriter` (index des fonctions seulement).
- Effet : **aucun** ; critère d'acceptation : `tests/test_reproductibilite.R` vert sans régénération. Échecs attendus « add() refuse un mc_nom absent » → test ordinaire.
- Hors périmètre : toute modification de la liste des tests ou d'une p-value.
- [x] ADR 0003 accepté — [ ] PR J1b fusionnée sans régénération — [ ] #4 piste 1 cochée

### J2 — Aléa à graine locale (J2a), documentation des graines, enveloppe du QQ-plot (J2b)

- **J2a — #4 piste 2 + #1, ADR 0004** : une fonction unique « exécuter sous graine locale » qui sauvegarde l'état du générateur (ou son absence), pose la graine, exécute, restaure ; `usp_bootstrap()`, `mw_bootstrap()`, `sw_loi_nulle()`, `engine_plots_data()` passent par elle avec leurs graines actuelles (résultats inchangés) ; `engine_lire_xlsx()`/`engine_ecrire_xlsx()` utilisent `tempfile()` et `on.exit(unlink(…, recursive = TRUE))` ; propriété nouvelle testée : `run_engine()` laisse `.Random.seed` de l'appelant intact. Puis `docwriter` réécrit la sous-section « Reproductibilité et gestion des graines » à partir de l'état final : liste exhaustive des fonctions qui tirent, leur graine, leur portée, la restauration. Circuit : `coder` → `audit` → `docwriter`. Effet : **aucun** (mêmes graines, mêmes flux) ; critère : références identiques sans régénération ; les deux échecs attendus « état du générateur » deviennent ordinaires.
- **J2b — #5 chantier 6** : l'enveloppe du QQ-plot est aujourd'hui simulée sous N(0,1) i.i.d. alors que la doc annonce « sous le modèle ajusté ». `actuary` précise la construction (réutiliser les z* triés de chaque réplication de `usp_bootstrap()`, donc conserver une matrice B × T dans l'objet bootstrap, ou simuler à part sous graine locale) ; `coder` → `audit` → `docwriter` (fiche du QQ-plot). Effet : `plots_data$qqnorm` (colonnes `env_bas`, `env_haut`) et un champ ajouté au bootstrap ; **aucune p-value, aucun verdict**. Régénération à lignes graphiques seulement. Si J2b prend du retard, J2a part seule : le tableau de #1 doit décrire l'état effectif du code au moment où il est fusionné.
- [x] ADR 0004 accepté — [ ] PR J2a fusionnée sans régénération — [ ] #1 fermée — [ ] spécification J2b `actuary` — [ ] PR J2b fusionnée (tableau : lignes graphiques seulement)

### J3 — MSEP de la méthode réserve n° 2 (#7, bloquant)

**Le seul jalon où le moteur est en écart avec le règlement sur le paramètre final** : σ_USP réserve n° 2 est sous-estimé et ne correspond à aucune des deux lectures possibles de D(5). C'est la priorité absolue pour la remise, et c'est aussi le jalon bloqué sur le mainteneur.

- Déblocable immédiatement, sans code : `regulatory` établit la lettre de D(5) (JOUE L 12/277-278, indices, bornes, ensembles d'indices) et décrit les deux lectures (double somme littérale i = 1..I, k = 1..I ; Merz-Wüthrich 2008 telle que `ChainLadder::CDR`) avec leur chiffrage sur Taylor & Ashe ; `actuary` donne son avis sur la lecture, sur la convention pour σ²_{J−1} quand σ²_{J−3} = 0, et sur le traitement d'une réserve négative ou nulle. Les deux avis sont postés en commentaire de #7.
- **Décision du mainteneur** (forme : commentaire sur #7 « lecture retenue : … »), puis ADR 0005 par `architect` si la lecture retenue n'est pas la lettre du texte, ou ADR consignant le choix de la lettre si elle l'est (dans les deux cas, le relecteur ACPR doit trouver la raison).
- Puis : `coder` (`mw_msep()`, ligne de calcul dans `mw_bootstrap()` inchangée) → `audit` → `regulatory` (contrôle de conformité) → `docwriter` (formule l. 3853-3856 et « double implémentation indépendante », à réécrire honnêtement : la vérification indépendante est désormais le test unitaire `msep_reglement()` et la valeur `ChainLadder::CDR`). Des deux échecs attendus de `test_merz_wuthrich.R`, on garde celui qui correspond à la lecture retenue et on supprime l'autre, comme le commentaire du test le prévoit.
- Effet : σ_USP réserve n° 2 (0,0466 → 0,0507 ou 0,0498 sur le triangle de test), `racine_msep`, IC bootstrap MW ; **p_mc MW inchangées** (les statistiques simulées ne dépendent pas de la MSEP). Régénération de `reserve2.rds` (première des deux prévues). Tableau avant / après approuvé par le mainteneur.
- [ ] lecture `regulatory` — [ ] avis `actuary` — [ ] **arbitrage mainteneur** — [ ] ADR 0005 — [ ] PR fusionnée avec tableau — [ ] contrôle `regulatory` — [ ] #7 (partie bloquante) fermée, points mineurs déplacés (voir § 5)

### J4 — Verdicts et p-values retenues (#5 chantiers 3 et 4)

C'est l'application concrète des ADR 0001 et 0002, qui exigent une évaluation test par test avant tout changement d'étiquette.

- Périmètre : règle générale « test inopérant » dans la fonction d'enregistrement partagée (J1b) : pour tout test à loi exacte discrète, calcul de la p-value minimale atteignable ; si p_min > α, diagnostic INFO avec p_min (Cox-Stuart, suites, Smirnov…) ; verdict INFO conditionné à l'identifiabilité pour pente, Fisher et R² quand le coefficient de variation des x_t est faible ; hiérarchie pour la constante (p_mc retenue, ADR 0002) ; p de Stephens pour AD et CvM recalculée sur des z re-standardisés ou retirée ; évaluation `actuary` de chaque p-value étiquetée « exacte » (Durbin-Watson, suites, Mann-Kendall, Spearman, Shapiro-Wilk par loi nulle simulée) sous le modèle réglementaire, comme l'ADR 0002 le prescrit.
- Circuit : `actuary` spécifie (une note par test : statut, raison, référence) → `coder` → `audit` → `docwriter` (fiches, tableaux 1-2, section « Tests structurellement inopérants ») → `actuary` valide.
- Effet : verdicts OK/ECHEC → INFO, `nature_p` et p_retenue modifiées pour quelques tests ; **σ_USP inchangé**. Régénération de `premium.rds` et `reserve1.rds` ; chaque ligne du tableau attribuée à son chantier (3 ou 4) ; approbation du mainteneur (verdicts). Une seule PR si la spécification des deux chantiers est prête ensemble ; sinon deux PR, chantier 3 d'abord.
- [ ] spécification `actuary` — [ ] PR fusionnée avec tableau approuvé — [ ] fiches et tableaux à jour — [ ] #5 chantiers 3 et 4 cochés

### J5 — Identifiabilité de δ (#5 chantier 2, restitution)

**Désaccord avec #5**, qui place ce chantier entier en deuxième position : seul son préalable (J0) est urgent ; la restitution ajoute des éléments et n'en corrige aucun, elle vient donc après les jalons qui changent des valeurs, et après J2 (le bootstrap restreint sous H0 est une nouvelle source d'aléa : il doit naître sous graine locale, ADR 0004, pour ne pas décaler les flux existants) et J4 (règle d'inopérance et statut de la ligne « Position de delta »).

- Périmètre : restituer le LR sur δ ∈ {0, 1} (déjà calculé dans `usp_profil()$lr_delta0/1`, jamais affiché) avec la p-value de Self & Liang (1987), mélange ½χ²(0) + ½χ²(1), et une p-value par bootstrap restreint sous H0 ; ligne de seuil O_min + 1,642 sur `plot_profil_delta` / `plot_coupe_delta` ; paragraphe Andrews (2000) sur l'IC bootstrap quand δ̂ est au bord ; décision sur la ligne « Position de delta dans [0,1] » (diagnostic INFO ou test).
- Circuit : `actuary` spécifie → `coder` → `audit` → `docwriter` (la fiche du LR existe déjà, l. 3334 ; tableaux 1-2 ; fiche du profil) → `actuary` valide ; `app-review` si l'affichage change.
- Effet : ligne(s) de test ajoutée(s), champs ajoutés à `profil` et `plots_data` ; **aucune p-value existante modifiée** (critère d'acceptation). Régénération structurelle de `premium.rds` et `reserve1.rds`.
- [ ] spécification `actuary` — [ ] PR fusionnée (tableau : ajouts seulement) — [ ] #5 chantier 2 coché

### J6 — Bootstrap Merz-Wüthrich (#5 chantier 5)

- Périmètre : redressement des résidus de Mack avant rééchantillonnage, facteur √(n_j/(n_j−1)) par colonne (England 2002, transposé du modèle ODP au modèle de Mack : choix à justifier dans la doc comme une interprétation, pas comme une formule du règlement) ; remplacement du diagnostic « variance unitaire des résidus de Mack », dont la valeur Σ(n_j−1)/(N−1) ≈ 0,81 est acquise par construction.
- Circuit : `actuary` spécifie → `coder` → `audit` → `docwriter` → `actuary` valide ; mainteneur si un verdict bouge.
- Effet : toutes les p_mc Merz-Wüthrich, l'IC bootstrap MW, verdicts possibles ; **σ_USP inchangé** (la MSEP ne dépend pas du bootstrap). Régénération de `reserve2.rds` (seconde et dernière prévue). Après J3 pour que les deux tableaux MW restent lisibles séparément ; si l'arbitrage de J3 tarde beaucoup, J6 peut passer avant, à condition de ne jamais fusionner les deux dans une même PR.
- [ ] spécification `actuary` — [ ] PR fusionnée avec tableau — [ ] #5 chantier 5 coché

### J7 — Entrées et validation (#4 piste 3, #7 points majeur et mineurs)

Regroupés parce qu'ils touchent le même module (lecture, validation, données par défaut) et que la plupart ont déjà leur test en échec attendu.

- Périmètre : conversion fichier → triangle en une seule fonction du moteur (trois copies aujourd'hui) ; règles métier de `charger_mw()` remplacées par `mw_valider_triangle()`, `charger_ln()` appelant `engine_valider_donnees()` ; aucun remplacement silencieux par les données par défaut (message explicite, `docs/exigences.md` § 5.2) ; données par défaut dans le moteur ; `note_m1` lisant `alpha` des métadonnées ; refus explicite d'une réserve ≤ 0 et d'une MSEP non finie (`mw_parametre()`, `ok = FALSE` avec `validation`) ; `Inf` refusé ; lecture CSV : facteur converti par ses valeurs, années dupliquées ou non consécutives refusées (ou signalées, selon l'avis `actuary`), NA signalé ; cellule vide refusée ; `usp_controle_donnees()` renvoie une ligne ECHEC au lieu d'une erreur ; annexe inconnue refusée ; `usp_credibilite()` refuse une durée non entière ; partie non observée remplie signalée par `mw_valider_triangle()` ; γ̂ sur la borne −12 signalé ; `.imhof_p_sup0()` renommé ou corrigé.
- Circuit : `actuary` répond aux trois questions ouvertes de #7 (réserve négative, années consécutives, convention σ²_{J−1}) en commentaire → `coder` → `audit` → `app-review` (car `app.R` change).
- Effet : **aucun** sur les références (les données de test sont valides) ; les échecs attendus concernés deviennent ordinaires. Si l'avis sur σ²_{J−1} change la convention, il touche `mw_ajuster()` : à isoler dans J3 ou J6, pas ici.
- [ ] avis `actuary` (3 questions) — [ ] PR fusionnée sans régénération — [ ] #4 piste 3 cochée — [ ] issue « contrôles d'entrée » fermée

### J8 — Forme de résultat commune (#4 piste 4)

- Périmètre : mêmes champs pour les deux méthodes (`NULL` explicite là où la notion n'existe pas), objets `ok = FALSE` de même forme, méthode lue dans `metadata` par `.influence_*()` au lieu d'être devinée ; suppression des gardes redondantes de `app.R` / `display_helpers.R` ; `bloc_final` n'affiche la correction √((T+1)/(T−1)) que pour les méthodes lognormales.
- Circuit : `coder` → `audit` → `app-review`.
- Effet : structure seulement. Régénération structurelle des trois fichiers, tableau « ajouts / renommages » sans valeur modifiée.
- Le défaut visible de `bloc_final` peut être extrait en PR courte (`coder` → `app-review`) avant une démonstration, sans attendre le reste.
- [ ] PR fusionnée — [ ] #4 piste 4 cochée, #4 fermée

### D — Piste documentaire parallèle (#5 chantier 7, partie doc)

**Désaccord avec #5**, qui renvoie ces corrections en dernier : une affirmation fausse de la doc sur ce que fait le code est un défaut de traçabilité, donc un défaut de dossier, et ces corrections n'attendent aucun code.

- Périmètre (seulement ce qui ne dépend d'aucun jalon de code) : encadré « Portée » qui nie la mise en œuvre de la méthode réserve n° 2 ; « `usp_run()` » → `run_engine()` ; fiches Spearman, Mann-Kendall et suites décrivant l'asymptotique alors que le moteur retient l'exacte ; tout autre écart de la liste de #5 dont la correction consiste à décrire le code actuel. **Hors périmètre** : la fiche du LR (J5), les fiches « Centrage » / « Variance unitaire » (J1a), la sous-section « graines » (J2a), la formule MSEP (J3).
- Circuit : `docwriter` → `actuary` (fond), `regulatory` si une formule du règlement est touchée. Branche `docs/…`, à rebaser après chaque fusion de J1a/J2a pour éviter les conflits sur le `.tex`.
- [ ] PR fusionnée, PDF recompilé

### J9 — Test de Bartels et table de puissance (#5 chantier 7, reste)

Nouveau test (rapport de von Neumann sur les rangs, p exacte par énumération des 8! permutations) et script de puissance à T = 8. Apport réel pour le dossier (puissance des tests à T = 8 est une question qu'un relecteur posera), mais ni un écart ni une correction : à faire si le calendrier le permet, sinon après la remise. Circuit : `actuary` → `coder` → `audit` → `docwriter` → `actuary`. Effet : ligne ajoutée (structure). **Décision de périmètre demandée au mainteneur.**

### JF — Relecture intégrale avant remise

Conditionnée par #2 (le § 5.5 et la suite de `docs/exigences.md` fixent ce que `app-review` doit vérifier) et par la fusion de tous les jalons « indispensables ». `regulatory` : matrice de conformité complète ; `app-review` et `docwriter` : relecture intégrale ; `architect` : point d'étape final et mise à jour de ce document.

## 4. Décisions attendues du mainteneur

| # | Décision | Forme attendue | Débloque |
|---|---|---|---|
| M1 | **Lecture de la MSEP D(5)** : lettre du texte (double somme i, k = 1..I) ou Merz-Wüthrich (2008) | commentaire sur #7 après les avis `regulatory` et `actuary` ; ADR 0005 ensuite | J3, puis J6 et J7 |
| M2 | **Texte manquant de `docs/exigences.md`** (§ 5.5 et suite) | commit du texte d'origine ; une issue par exigence restaurée ayant un impact | JF ; éventuellement de nouveaux jalons |
| M3 | Visa des tableaux avant / après à verdict ou σ_USP modifié | approbation sur la PR (case du modèle) | J1a (principe déjà acquis par ADR 0001), J3, J4, J6, et J0 en cas de divergence |
| M4 | Politique métier : une réserve ≤ 0 ou une MSEP non finie **refuse** le calcul (`ok = FALSE`) plutôt que de produire un σ_USP | commentaire sur #7 ou sur l'issue « contrôles d'entrée » | J7 |
| M5 | Périmètre avant remise : J9 (Bartels, puissance) et J8 (forme commune) inclus ou différés | commentaire sur #5 et #4 | planification de fin de projet |

## 5. Gestion des issues recommandée

- **#3** : inchangée (`ready-for-agent`), première PR de code (J1a). Fermée par la PR.
- **#4** : ne plus la traiter comme une issue exécutable mais comme un suivi : retirer `needs-triage`, ajouter une liste de tâches (piste 1 → J1b, piste 2 → J2a, piste 3 → J7, piste 4 → J8) renvoyant à ce document ; fermer quand les quatre cases sont cochées. Créer une issue `enhancement`, `ready-for-agent` par piste dès que son ADR est accepté : « moteur : catalogue unique des statistiques Monte-Carlo (ADR 0003) », « moteur : simulation sous graine locale et documentation des graines (ADR 0004, ferme #1) ».
- **#5** : même traitement (suivi avec liste de tâches par chantier, retirer `needs-triage`). Créer les issues exécutables : « tests : préalable, ajusteur rapide contre ajusteur complet » (`ready-for-agent`, J0) ; « moteur : verdicts inopérants et p-values retenues » (`needs-info` jusqu'à la spécification `actuary`, puis `ready-for-agent`, J4) ; « moteur : restitution du LR sur δ et bootstrap restreint » (`needs-info`, J5) ; « moteur : redressement des résidus de Mack dans `mw_bootstrap()` » (`needs-info`, J6) ; « docs : écarts code ↔ doc sans changement de code » (`ready-for-agent`, D) ; « moteur : test de Bartels et table de puissance » (`needs-triage`, J9, décision M5).
- **#7** : la garder pour le seul point bloquant (MSEP), `ready-for-human` jusqu'à M1 puis `ready-for-agent` ; déplacer le point majeur (réserve ≤ 0, NaN) et les points mineurs dans une issue `bug`, `ready-for-agent` « moteur : contrôles d'entrée et de validité (#7 mineurs, #4 piste 3) » qui porte J7, avec les trois questions ouvertes pour `actuary` en tête.
- **#1** : inchangée ; fermée par la PR J2a.
- **#2** : inchangée, `ready-for-human`.

## 6. Historique des jalons terminés

*(vide au 21 septembre 2026)*
