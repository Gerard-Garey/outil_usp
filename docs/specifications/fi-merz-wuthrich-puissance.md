# Spécification de Fi : Merz-Wüthrich, ensembles figés, puissance à T = 8, M2 et M4 — point d'arrêt D1-Fi (#290, #289, #309, #301, #300)

> **Décisions du mainteneur du 19/10/2026 (E-19/10 (D1-Fi)) : point d'arrêt D1-Fi franchi.**
>
> *Consignées par l'agent architect (IA)* (fiche de base), à la demande de la session principale ; source : brief de la session principale. Le présent document reprend la spécification D1-Fi d'`actuary-approfondi` du 19/10/2026 ; l'assemblage n'en change pas le fond (seuls les chemins des scripts de session sont retirés, et des renvois en italique signalent les passages que les décisions modifient). Les scripts de mesure et le pilote sont **hors dépôt, non versionnés**. En cas de divergence entre le corps du document et cet encadré, l'encadré l'emporte.
>
> - **Q-D1-Fi-1 (#309)** : selon la recommandation. **Plan (A)** (R = 1 000 sur les huit cellules de référence et de décision, R = 500 ailleurs) **plus le volet A**, exécutés sur une **branche de sauvegarde `claude/sauvegarde-309`** (annotation du 09/10 de l'ADR 0007, traits 1 à 6 ; décision consignée dans la fiche Fi de la feuille de route, comme l'exige la « Portée » de cette annotation).
> - **Q-D1-Fi-2** : selon la recommandation (scénarios et paramètres du § 2.3 : θ = 0,10, γ = 0,20, λ = 4 et 6, cellule ciblée (2,1)).
> - **Q-D1-Fi-3 (#309)** : **plan P3 permuté retenu, contre la recommandation**. P2 (κ = 3,4) est conservé ; P3 = P2 avec une **permutation fixe** de la première colonne amplifiée, sur les cellules **H0, CST20 et DFI**, coût d'environ **+5 h** d'horloge. La **permutation exacte, les effectifs R et les graines** (plage disjointe de celles du § 2.6, de #206 et de Fd) **restent à fixer par `actuary` avant l'écriture du script** de #309 (étape 3). Durée totale de #309 : environ **31 à 33 h** d'horloge (plan (A) 22-24 h, volet A 4 h, P3 5 h).
> - **Q-D1-Fi-4** : selon la recommandation (niveau de #301 et #300 par le volet A, puis contrôle (i2′)).
> - **Q-D1-Fi-5 (#301)** : selon la recommandation : variante **FWr**, sous le critère K-301 (FWb à défaut, arrêt D2-Fi sinon) ; Harvey non retenue.
> - **Q-D1-Fi-6 (#300)** : selon la recommandation : statistique **M = minimum des p de Student** (MinP ou MinP4 selon K-300), p Monte-Carlo retenue, borne de Bonferroni en p non simulée ; elle **remplace la statistique de Grubbs** sur la même ligne ; `test_grubbs()` inchangée.
> - **Q-D1-Fi-7 (#300, Rosner)** : **Rosner sur résidus de Mack restitué en diagnostic sans verdict (diagnostic par décision), et non retiré, contre la recommandation.** La ligne est conservée, avec `type = "diagnostic"` posé par `mw_tests()`, verdict INFO, k̂ et rangs restitués ; une **phrase fixe**, à écrire par `actuary` au moment du code, dit que le cadre i.i.d. normal de Rosner (1983) ne couvre pas des résidus à contraintes exactes (#347, écart 1) ; `test_rosner()` inchangée (C3⁗). Effets du § 4.4 révisés : **20 lignes conservées** (et non 20 → 19) ; Rosner OK → INFO ; décomptes sur `reserve2`, *déduits par `architect` des chiffres du § 4.4, à constater au tableau avant / après* : OK 8 → 7, INFO 6 → 7, ALERTE 2 et ECHEC 4 inchangés ; **visa du mainteneur** requis (commit de #300). Le § 4.5 se lit en conséquence : `mw:m4ros` est réécrite en fiche de diagnostic (écarts 1, 2, 3, 6 et 7 de #347, report `6262412191`), non retirée.
> - **Q-D1-Fi-8** : selon la recommandation, option **(iii)** (statistique observée non définie, motif propre, ligne en diagnostic par le mécanisme existant). *(Précisé le 21/10/2026 par le mainteneur : la ligne est un test sans p-value retenue, verdict INFO, et non un diagnostic ; code de `969cc98` inchangé ; voir l'annotation du § 4.1, point 4.)*
> - **Q-D1-Fi-9** : selon la recommandation : la **pente relative de #307** est mesurée dans #309 (volets A et B), **sans décision** dans Fi.
> - **Q-D1-Fi-10** : selon la recommandation : **point d'arrêt D2-Fi** après les tableaux de #309 (choix des variantes sur K-301 et K-300, ou décision du mainteneur si un critère échoue).
> - **Q-D1-Fi-11** : selon la recommandation : **deux régénérations** de `reserve2`, une par issue, #301 puis #300 ; #301 validée par `actuary` (verdict inchangé), #300 sous **visa du mainteneur**.
>
> **Signalements.**
>
> - **(i) Sources externes non vérifiées.** L'accès réseau de la session d'`actuary-approfondi` a été refusé par le proxy : Harvey (1976), Cook et Weisberg (1982) et Belsley, Kuh et Welsch (1980) sont **[NV]** (existence des deux derniers attestée par l'aide R `?influence.measures`, contenu non lu). La loi de Student de t(i,j) (§ 4.2) est à vérifier sur le texte par `docwriter` avant toute citation.
> - **(ii) Rosner (1983).** Les citations et pages viennent des **relevés de #347** (session de recherche documentaire du 19/10), non relus ici ; `actuary-approfondi` les a contrôlés sur les valeurs numériques (λ de l'éq. (2.5)) et sur le code seulement (§ 4.3). Même acte que pour Fh : confrontation à la copie de l'article fournie par le mainteneur avant la validation de fin de branche.

> **Complément du 19/10/2026 — éléments fixés par `actuary` avant le script de #309 (Q-D1-Fi-3, Q-D1-Fi-7).**
>
> *Rédigé par la session principale (IA)*, d'après l'avis d'`actuary` (fiche de base, lecture seule, 19/10/2026). Scripts de mesure hors dépôt, non versionnés. Les deux points que l'avis laisse ouverts sont pris selon sa recommandation et le texte de Q-D1-Fi-7, **sous réserve du mainteneur** (signalés dans la PR #349).
>
> - **Permutation de P3.** C′(i,0) de P2 = C̄₀ + 3,4 (C(i,0) − C̄₀), équidistantes (204 ; 242,857143 ; … ; 476). Sous P3, la ligne i reçoit C′(π(i),0), avec **π = (1, 7, 5, 3, 2, 4, 6, 0)** (indices 0..7 ; en R, `C3 <- C2[c(2, 8, 6, 4, 3, 5, 7, 1)]`). Critère : énumération des 8! permutations ; admissibilité (K0-c tenu ; |corrélation avec (i − 3)²| ≤ 0,3 et |autocorrélation de rang 1| ≤ 0,3 sur les lignes 0..6) ; minimax de |ρ de Spearman| et |ρ de Pearson| entre i et C″ sur les sous-ensembles emboîtés des lignes 0..m−1, m = 8 à 4 (minimax 0,2143, atteint par quatre permutations) ; départage par le profil de CV le plus proche de P2 (π seule). Corrélations de Spearman [V] : −0,190 (lignes 0..7), 0,214 (0..6), 0,029 (0..5), 0,000 (0..4), 0,200 (0..3), 0,500 (0..2, colonne j = 4 : minimum possible à trois points, colinéarité résiduelle inévitable, à dire dans la fiche).
> - **CV réalisés** (exploratoire, 4 000 triangles par plan, non citable) : moyenne pour j = 0..3 de 0,229 sous P2 et de 0,257 sous P3. K0-c est inchangé et **évalué séparément sur P2 et sur P3** ; la différence de profil de CV est un facteur confondant résiduel, rapporté au T0. L'attente « ≈ 0,25 » du § 2.2 pour P2 ([H]) se lit en conséquence : K0-c y tient près de sa borne basse.
> - **Effectifs sous P3** : H0 R = 1 000, CST20 R = 1 000, **DFI R = 500** (comme sous P2), et **oracle N0 = 20 000** sous P3 (loi N, candidats compris) pour ρ. Environ 2 500 triangles, ≈ 4,2 h d'horloge [H, à confirmer par `--essai`] ; la variante DFI à 1 000 (≈ 5,0 h) n'est pas retenue.
> - **Graines de P3** (c₃ = 1 pour H0, 2 pour CST20, 3 pour DFI ; tous les tirages sous `engine_sous_graine()`) : triangles 34 000 000 + 20 000 (c₃ − 1) + b ; bootstrap 34 200 000 + 20 000 (c₃ − 1) + b ; oracle 34 400 000 + k, k = 1..20 000. Plages 34 000 001-34 060 000, 34 200 001-34 260 000 et 34 400 001-34 420 000, disjointes du volet B, de #206 et de Fd, sans collision avec les littéraux de `R/` et `tests/` [V]. La recherche de collisions du script couvre ces plages.
> - **Phrase fixe du diagnostic Rosner** (ligne M4 conservée, `type = "diagnostic"`, verdict INFO posé par `add()`) :
>   `Diagnostic sans verdict (ADR 0001) : procedure ESD generalisee de Rosner (1983) appliquee aux residus de Mack. Ses valeurs critiques (eq. (2.5), approximation de Student-Bonferroni) et son domaine declare (n >= 25) valent pour un echantillon i.i.d. normal ; les residus de Mack, soumis a des contraintes exactes par colonne, n'en sont pas un, et le cadre de Rosner (1983) ne les couvre pas. La procedure n'est donc pas un test de la ligne : le nombre de cellules declarees se lit comme un repere, sans p-value.`
>   Elle est suivie du fragment `" Valeurs critiques calculees a alpha = %.2f"` et, si k̂ > 0, des rangs (aucun nombre issu du bootstrap, #76). Ancrage : #347 (écarts 1 et 2, § 1.a-c, § 3) ; pages de Rosner (1983) [NV], même réserve que le signalement (ii). `estim_nom` : « nb de cellules declarees (repere de Rosner) ». Seuls les **rangs** sont restitués, selon Q-D1-Fi-7 (les coordonnées (i, j) ne sont pas ajoutées).
>
> **Second complément du 19/10/2026 — lectures fixées par `actuary` avant le commit mesuré de #309.**
>
> *Rédigé par la session principale (IA)*, d'après l'avis d'`actuary` (fiche de base, lecture seule) sur les questions de `coder` relatives au script `tests/puissance_mw_t8.R`. Aucune de ces lectures ne change les données brutes ; elles fixent la combinaison. **Pour information du mainteneur** : deux lectures de K-300 et K-301 sont précisées ici, le texte des critères (§ 2.7) restant inchangé ; le mainteneur peut y revenir à D2-Fi.
>
> - **Rang c des cellules** (graines du § 2.6) : ordre de `CELLULES` du script, P1 de 1 à 13 dans l'ordre du tableau du § 2.6, puis P2 de 14 à 19 ; P3 selon le premier complément (c₃ = 1, 2, 3).
> - **Option (iii)** (Q-D1-Fi-8) : statistique NA à l'observé ; en réplication p_ij = 0 pour MinP et MinP4, |t| = `.Machine$double.xmax` pour TMax (valeur finie, la réplication reste dans B effectif) ; TMax sur les mêmes cellules que MinP (n_j ≥ 3).
> - **Oracle de P1** : celui de la loi N du volet A (même générateur, graines de #206).
> - **Scénarios** : CAL7, CAL4 et DCAL modifient aussi la colonne 0 (convention de Fd, `appliquer_effet()` de `tests/mesure_calendaire_t8.R`) ; « première colonne fixée » qualifie H0. CEL4, CEL6 et CELx4 : choc sur l'incrément P(2,2) puis recumul (C(2,j), j ≥ 2, décalés), σ̂₁ de `reserve2` comme σ₁ vrai du DGP.
> - **K-300, « le McNemar favorise X contre Y »** : à CEL4 **et** à CEL6, au moins un des deux seuils (0,10 ; 0,05) donne un McNemar exact bilatéral < 0,05 en faveur de X, et aucun des quatre couples (CEL4, CEL6) × (0,10 ; 0,05) ne le donne en faveur de Y. MinP4 n'est retenu contre MinP que s'il est favorisé ; sinon MinP. **TMax domine** s'il est éligible et favorisé contre MinP **et** contre MinP4. Condition (ii) : à 0,10 non-infériorité ponctuelle (≥), à 0,05 supériorité établie (taux strictement plus grand et McNemar < 0,05 en faveur) ; asymétrie voulue (le défaut de Grubbs est au seuil de l'ECHEC).
> - **K-301** : lu à la lettre (un « écart non tranché » sous N ou E n'est pas admis) ; le côté de l'écart (conservateur si taux < ρ/2, libéral si taux > 3ρ/2) est affiché pour D2-Fi.
> - **K0-x** : test exact de Fisher bilatéral entre le taux mesuré (R = 500) et le taux publié du T2 de #276 (401/1 000 et 319/1 000), tenu si p ≥ 0,025 par cellule (Bonferroni sur deux cellules). La règle « publié ∈ IC du taux mesuré » est écartée : fausse alerte ≈ 0,10 par cellule, mesurée [V]. Garde-fou avant exécution : au contrôle (sc), les scénarios CAL7, CAL4 et DCAL sont `identical()` à `appliquer_effet()` de Fd (« dernier », « median » à 0,10 ; « derive » à 0,05) sur 20 triangles H0 de P1.
> - **T5** : part de S_xx entre colonnes, S_xy entre et intra, nR² de BP, entre et intra, écart de la contrainte Σ r² = n_j − 1 ; plus la part de S_xy entre dans S_xy et le contrôle |n S_xy²/(S_xx S_yy) − BP observé| ≤ 1e-10.
> - **Pièces versionnées** : journaux de mesure et de combinaison (`docs/tableaux/AAAAMMJJ-issue309-journal-mesure.md` et `-journal-combinaison.md`), comme pour #206, dans le commit unique des sorties ; le T0 cite leur chemin. (i2′) porte par défaut sur tous les triangles marqués (i2) des volets A et B, et admet le seul écart de motif « statistique observée non définie » (option (iii)), compté à part.
> - **Durée** : essais à 32,9 h et 34,5 h ; un dépassement net de 36 h est signalé au mainteneur.
>
> **Décisions du mainteneur du 21/10/2026 au point d'arrêt D2-Fi (Q-D2-Fi-1 à 4) : point d'arrêt franchi.**
>
> *Consignées par la session principale (IA).* Elles s'appuient sur les tableaux de #309 (`docs/tableaux/20261021-issue309-puissance-mw.md`, commit `1e3979c`) et sur l'avis d'`actuary` (fiche de base, lecture seule, 21/10/2026), versé en commentaire `6315239862` de la PR #349. Toutes suivent les recommandations.
>
> - **Q-D2-Fi-1 (#301)** : **FWr** retenue (K-301), à la place de BP sur la ligne M2. Effet attendu sur `reserve2` : statistique 0,6502 → 1,4373 ; p_mc 0,103 → 0,285 ; verdict OK inchangé ; validation d'`actuary`. L'algèbre du moteur reproduit exactement celle de `stat_fw()` de `tests/puissance_mw_t8.R`, pour que (i2′) soit `identical()`.
> - **Q-D2-Fi-2 (#300)** : **MinP4** retenue (K-300), à la place de Grubbs sur la ligne M4. Ses trois limites sont acceptées et seront écrites en rubrique 7 :
>   - niveau conservateur sous N (0,065 à 0,10) ;
>   - perte face à Grubbs à CEL4 au seuil de 0,10 (0,183 contre 0,211) ;
>   - les 3 cellules de la colonne n_j = 3 ne sont pas couvertes, et la puissance y est non mesurée.
>
>   **Visa donné** pour Rosner OK → INFO (diagnostic par décision). Décomptes attendus sur `reserve2` : OK 8 → 7, INFO 6 → 7, 20 lignes, σ_USP inchangé, à constater au tableau avant / après.
> - **Q-D2-Fi-3** : la rubrique 7 de M2 dira que la ligne n'a pas de puissance mesurable à T = 8 sous P1. Le constat est transmis à Fj (#308).
> - **Q-D2-Fi-4** : le § 3.4 et le `.tex` (`mw:m2bp`) seront corrigés avec les seuls chiffres du T5. La formule « terme quasi constant (≈ 0,65) » est réfutée par le T5 et sera retirée. Le lien BP / S_yy, calcul de session non versionné, n'est pas cité, et les sorties ne sont pas recombinées.

> *Rédigé par l'agent actuary (IA).* Le 19/10/2026, consultation `actuary-approfondi` en lecture seule, sur demande de la session principale, pour la fiche Fi du trente-huitième point d'étape (`docs/feuille-de-route.md`, § 3, fiche « Branche Fi (parallèle) ») et les décisions du mainteneur du 19/10 : Fi = #290, #289, #309, #301, #300, dans cet ordre ; #308 passe en Fj ; pas de Fable ; T = 8. Complément de la session principale (même jour) : Rosner (1983) a été lu en texte intégral (issue #347) ; Q-38-10 est révisée et la règle Q-Fc-10 ne s'applique plus. À versionner en premier commit de Fi sous `docs/specifications/fi-merz-wuthrich-puissance.md`. **Point d'arrêt D1-Fi** : aucun code de Fi avant que le mainteneur ait tranché Q-D1-Fi-1 à Q-D1-Fi-11. **Point d'arrêt D2-Fi** : après les tableaux de #309 (§ 2.7), le mainteneur choisit les variantes de #301 et #300 avant leur code.

**Marques** : **[V]** vérifié (source citée, ou commande exécutée et sortie lue) ; **[H]** hypothèse ou raisonnement non mesuré ; **[NV]** non vérifié.

## 0. Sources, mesures, contraintes

**Lu [V]** : issues #290, #289, #309, #301, #300 (sans commentaire), #308, #307, #340, #347 et son commentaire `6262306477`. `R/engine.R` de `main` `f1689cc` : `test_grubbs()` (l. 3372), `test_rosner()` (l. 3390), `.mc_entree()` (l. 3500), `engine_p_mc()` (l. 3847), `.mc_p_values()` (l. 3910), `.mw_colonnes_origine_non_identifiables()` (l. 9012), `mw_test_ordonnee_origine()` (l. 9048), `.mw_colonnes_courbure_non_identifiables()` (l. 9314), `.mw_ensembles_figes()` (l. 9348), `mw_test_courbure()` (l. 9363), `.mw_simuler_triangle_etat()` (l. 9711), `.mw_pool_residus()` (l. 9818), `mw_bootstrap()` (l. 9840), `MW_CATALOGUE_MC` (l. 10017), `mw_tests()` (l. 10188 ; M2 l. 10316-10326, M4 l. 10483-10502), `mw_influence()` (l. 11103), `mw_plots_data()` (l. 11242). `tests/calibration_mc_mw_t8.R` (DGP, l. 535-605 ; graines, l. 445-450), `tests/mesure_calendaire_t8.R` (en-tête), `docs/specifications/fd-test-calendaire.md` (forme), `docs/tableaux/20261011-issue206-calibration-mw.md` (T0, T1, T5) et son `-brut.tsv` (colonnes `pR:<clé>` par triangle), `docs/tableaux/20261016-issue276-calendaire.md` (T0, T2), les scripts de sonde de la revue (`docs/revues/20261015-pertinence-tests-graphiques/mesures/bloc-5/*.R`, `bloc-6/puissance_m3m4.R` et sa sortie), ADR 0007 (annotation du 09/10, branche de sauvegarde), `docs/exigences.md` § 2 et § 3, `.tex` (`mw:m2bp` l. 14290-14320, `mw:m4gr` l. 15120-15157, `mw:m4ros` l. 15160-15192, l. 6032-6038, l. 16247, `sec:calib-mc-mw` l. 16320).

**Mesures [V]** : `Rscript` R 4.3.3, `LC_ALL=C.UTF-8`, 4 cœurs, moteur `f1689cc` chargé par `source()`. Scripts de session hors dépôt, non versionnés : `m1.R` à `m7.R` (mesures sur `reserve2`), `pilote.R` (pilote du § 4.4). Les candidats sont calculés **par injection d'entrées dans `MW_CATALOGUE_MC`** de l'environnement du moteur, rétabli par `finally`, puis appel de `mw_bootstrap()`. La boucle de tirage n'est pas recopiée. Contrôle : avec cinq entrées ajoutées, les 13 `p_mc` du moteur sur `reserve2` (graine 20260831, B = 999) sont `identical()` à celles de `tests/reference/reserve2.rds`, avec B effectif = 999.

**Sources externes** : l'accès réseau de la session est refusé par le proxy (CRAN, documentation R en ligne, éditeurs). Harvey (1976) **[NV]**. Rosner (1983) : relevés de #347, contrôlés au § 4.3. Belsley, Kuh et Welsch (1980) et Cook et Weisberg (1982) : leur existence est attestée par les références de l'aide R `?influence.measures`, lue localement ; leur contenu n'a pas été lu **[NV]**.

**Contraintes de la paire (C3⁗)** : `test_grubbs()`, `test_rosner()`, `add()`, `engine_registre_tests()`, `engine_p_mc()`, `.mc_p_values()`, `engine_sous_graine()` et `R/display_helpers.R` (dont `GROUPES`) restent inchangés. Fi ne touche que les fonctions `mw_*` et `.mw_*`, `MW_CATALOGUE_MC`, les tests unitaires Merz-Wüthrich, `tests/calibration_mc_mw_t8.R`, le script de #309 et `tests/reference/reserve2.rds`. Toute recommandation ci-dessous respecte ce périmètre ; un besoin hors de lui arrête la branche.

## 1. #290 (sans spécification)

Circuit 3, résultats identiques au bit près. Seule exigence d'ordre : #290 précède #289, pour que le contrôle de #289 porte sur le prédicat factorisé `.mw_colonnes_non_identifiables()`. Oracle complémentaire possible pour `coder` : les ensembles par défaut des deux tests de M1, appelés seuls, sont `identical()` à `.mw_ensembles_figes(aj)` sur `reserve2` et sur les triangles de `test_tables_mw.R`.

## 2. #309 : puissance à T = 8 des lignes M1 à M4 (S-Fi-1)

### 2.1 Ce que la mesure doit établir

Les lignes M1 à M4 n'ont aujourd'hui qu'un niveau, mesuré sous un seul plan (#206). La mesure fournit, sous deux plans de dispersion :
- la puissance des 13 statistiques de `MW_CATALOGUE_MC`, des candidats de #300 et #301 et de Rosner ;
- le niveau des candidats ;
- les grandeurs dont Fj a besoin (§ 6).

Statut : **constat de simulation sous un plan** (modèle de Mack ajusté à `reserve2`, géométrie 8 × 8). Aucun théorème ne couvre ces tests bootstrap à T = 8.

### 2.2 Plans

**Fait structurant [V].** La première colonne de `reserve2` est linéaire en i : 300, 311, 323, 334, 346, 357, 369, 380 (arrondis). Le volume C(i,j) est donc colinéaire à l'année de survenance i dans les deux plans ci-dessous. Une dépendance au volume et une dépendance à i ne sont pas séparables : HomogF (F contre i) et la pente intra-colonne (F contre C) visent presque la même direction. C'est très probablement **[H]** la cause de la « non-spécificité » d'HomogF sous le scénario « constante » relevée par la sonde du bloc 5 (0,80). La fiche le dira.

- **P1 (CV intra-colonne ≈ 7 %)** : DGP de #206, sans changement. Modèle de Mack ajusté à `reserve2` (f̂, σ̂² de `mw_ajuster()`), première colonne observée fixée. Générateur `gen_triangle_h0()` et règle d'admission `admettre()` copiés de `tests/calibration_mc_mw_t8.R` : triangle refusé au premier cumul ≤ 0, refus comptés et signalés au-delà de 1 %. La copie se limite au DGP (côté test, contrôle (g) de #206), jamais au calcul mesuré.
- **P2 (CV intra-colonne ≈ 25 %)** : même DGP, première colonne remplacée par C′(i,0) = C̄₀ + κ (C(i,0) − C̄₀), avec C̄₀ moyenne des 8 valeurs et **κ = 3,4**. f̂ et σ̂² sont ceux de `reserve2`, non réestimés.
  - **[V]** : CV des 8 valeurs 0,28 (0,082 sur P1) ; minimum 0,60 C̄₀ (cumuls positifs).
  - CV intra-colonne attendu ≈ 3,4 × (0,074 ; 0,076 ; 0,080 ; 0,075 ; 0,060), soit environ 0,25 pour j = 0 à 3 **[H]**.
  - Le T0 rapporte le CV réalisé par colonne (moyenne sur les triangles H0). Critère K0-c : la moyenne pour j = 0 à 3 est dans [0,22 ; 0,28].
- **P3 (volumes non monotones en i)**, facultatif, Q-D1-Fi-3 : P2 avec une permutation fixe de la première colonne amplifiée. C'est le seul plan qui sépare volume et année. Non recommandé dans Fi. *(Retenu par le mainteneur, Q-D1-Fi-3 : sur H0, CST20 et DFI ; permutation, effectifs et graines à fixer par `actuary` avant le script.)*

Loi des erreurs : N (`rnorm`) pour toutes les cellules de puissance ; N, E et A (§ 2.5) pour le niveau.

### 2.3 Scénarios (définitions chiffrées)

Notation : C̄_j est la moyenne des C(0..I−j−1, j) **simulés** de la colonne (définition du bloc 5) ; σ̂_j² est celui de `reserve2`. Les scénarios de cellule et de ligne modifient les **incréments** P du triangle simulé sous H0, puis recumulent (forme de Fd et du bloc 6).

| Code | Scénario | Définition | Origine |
|---|---|---|---|
| H0 | — | DGP du plan | #206 |
| CST10, CST20 | ordonnée à l'origine | E[C(i,j+1) \| C] = a_j + f_j(1 − δ) C, a_j = δ f_j C̄_j, δ = 0,10 ; 0,20 ; variance σ̂_j² C inchangée | bloc 5 (δ = 0,20) |
| EXP0, EXP2 | exposant de variance | Var(C(i,j+1) \| C) = σ̂_j² C^κ C̄_j^(1−κ), κ = 0 ; 2 (variance moyenne conservée à C = C̄_j) ; moyenne inchangée | bloc 5 |
| DFI | dérive de f_j en i | E[C(i,j+1) \| C] = [f_j + γ (σ̂_j/√C̄_j)(i − ī_j)] C, ī_j = (I − j − 1)/2, **γ = 0,20** : dérive d'un écart-type de bruit du facteur sur cinq années de survenance | nouveau, paramètre fixé ici |
| CAL7, CAL4 | choc calendaire | incréments de l'exercice t = i + j multipliés par 1 + θ, t = 7 ; t = 4, **θ = 0,10** | Fd (T2 de #276) ; le bloc 6 prenait 0,15 |
| DCAL | dérive calendaire | incréments multipliés par 1,05^max(0, i + j − 3) | Fd, bloc 6 |
| LIG | ligne atypique | incréments P(2, j), j ≥ 2, multipliés par 1,5 | bloc 6 |
| CEL4, CEL6 | cellule aberrante modérée | P(2,2) ← P(2,2) + λ σ̂₁ √C(2,1) (valeurs simulées), λ = 4 ; 6 : F(2,1) déplacé de λ écarts-types de bruit | nouveau |
| CELx4 | cellule aberrante forte | P(2,2) × 4 | bloc 6, exemple de #300 |

**Coordonnées de la cellule ciblée [V].** L'incrément P(2,2) entre dans C(2,2), donc au numérateur de F(2,1) = C(2,2)/C(2,1). La cellule visée en coordonnées de résidus de Mack est **(i, j) = (2, 1)**.
- Sur l'exemple × 4 de #300, Grubbs, max|t| et le minimum des p désignent tous (2,1) (`m3.R`).
- La sonde du bloc 6 testait la désignation de (2,2) et trouvait 0 : c'est un écart de coordonnées, non un défaut de localisation de Grubbs. Le T4 mesure la désignation de (2,1).

Choix de θ = 0,10 : la colonne `Calendrier` des cellules CAL7 et CAL4 doit retrouver, aux IC près, les taux publiés de la forme « bas » (T2 de #276 : 0,401 et 0,319 à 0,10). Ce contrôle K0-x vaut mieux qu'une continuité avec une sonde non citable.

### 2.4 Statistiques mesurées et calcul des candidats

Pour chaque triangle (B = 999) :
- les 13 `p_mc` du moteur ;
- les candidats ci-dessous, par **injection dans `MW_CATALOGUE_MC`** (jamais par copie de la boucle de `mw_bootstrap()`, constat de #340) ;
- les grandeurs observées : Rosner (k̂ à α = 0,10 et 0,05, par `test_rosner()` sur `mw_residus()`), la p de Bonferroni du candidat de #300, la p χ²(1) des variantes de #301, la cellule désignée par chaque statistique de M4 et, pour Fj, le § 6.

**Candidats de #300** (définitions au § 4.1) :
- `MinP` : min des p de Student par cellule, n_j ≥ 3, queue basse ;
- `MinP4` : même statistique sur n_j ≥ 4, queue basse ;
- `TMax` : max |t(i,j)| brut, queue haute, comparateur nommé par l'issue.

Calcul : un seul appel à `mw_influence(e$aj)` par réplication, mis en cache dans le script. On en tire t(i,j) = DFBETAS · √((1 − h)/h), avec (1 − h)/h calculé comme `.mw_sommes_autres(C)/C` (forme stable de #233). La règle de gel est celle du § 4.1, point 3.

**Candidats de #301** (§ 3.1) :
- `FWb` : nR² partiel de r² ~ facteur(j) + C, 27 cellules (proposition de l'issue) ;
- `FWr` : même construction sur r̃² = r²/(1 − h), colonnes n_j ≥ 3 (recommandée).

### 2.5 Volet A (niveau des candidats ; sert #301 et #300)

- **Plan** : celui de #206, avec **les mêmes graines** (`graine_tri`, `graine_boot`, `graine_ora` de `calibration_mc_mw_t8.R`) : N 2 000, E 2 000, A 1 000, oracle N0 = 20 000 par loi pour ρ (taille lissée de #206, classes de #166).
- **Catalogue réduit injecté** : {BP, Grubbs (témoins), FWb, FWr, MinP, MinP4, TMax}.
- **Contrôle K0-t (témoins)** : `p_mc` de BP et de Grubbs **identiques** aux colonnes `pR:BP` et `pR:Grubbs` du brut de #206, triangle par triangle. Toute différence est listée et expliquée (par exemple `cumuls_retires` vrai, retirage de #257 postérieur à #206).
- **Appariement** : il permet le McNemar entre BP et chaque variante sur les mêmes triangles et les mêmes réplications.
- **Coût mesuré** : 10,8 s CPU par triangle avec ce catalogue réduit à B = 999 (pilote, 4 processus) **[V]**. Environ 15 h CPU, soit environ 4 h d'horloge sur 4 cœurs, plus l'oracle (quelques minutes).
- **Effet sur le plan de la fiche Fi** : ce volet remplace la remesure par `calibration_mc_mw_t8.R` de l'étape 4. Après le code, le contrôle (i2′) du § 2.6 établit que la ligne implémentée est celle qui a été mesurée (Q-D1-Fi-4).

### 2.6 Volet B (puissance), effectifs, graines, durée

Loi N, B = 999, catalogue complet (13 statistiques) plus les candidats.

| Plan | R = 1 000 | R = 500 |
|---|---|---|
| P1 | H0, CST20, EXP2, CEL4, CEL6 | CST10, EXP0, DFI, CAL7, CAL4, DCAL, LIG, CELx4 |
| P2 | H0, CST20, EXP2 | CST10, EXP0, DFI |

Plus un oracle N0 = 20 000 sous P2 pour ρ.

**Plan (A), recommandé** : R = 1 000 sur les huit cellules de référence et de décision, R = 500 ailleurs (IC de Clopper-Pearson de ±4,4 points à 0,5 et ±2,7 points à 0,1), soit 13 500 triangles. **Plan (B)** : R = 1 000 partout, comme le demande l'issue, soit 19 000 triangles.

**Coût** : `mw_bootstrap()` complet à B = 999 coûte 17,7 à 18,6 s par triangle en processus seul **[V]**. Les candidats ajoutent environ 3 s **[H]** ; disons 22,5 s par triangle et une efficacité parallèle de 3,75 (#206).
- (A) : environ 84 h CPU, **environ 22 à 24 h d'horloge** sur 4 cœurs ;
- (B) : environ 32 h d'horloge ;
- volet A en plus : environ 4 h.

À confirmer par `--essai`, qui imprime la durée par triangle. **Branche de sauvegarde `claude/sauvegarde-309` nécessaire** (annotation du 09/10 de l'ADR 0007 ; décision du mainteneur à consigner dans la fiche Fi, Q-D1-Fi-1).

**Graines** : triangles 32 000 000 + 20 000 (c − 1) + b ; bootstrap 32 500 000 + 20 000 (c − 1) + b ; oracle P2 33 000 000 + k. c est le rang de la cellule (au plus 19), et les plages sont 32 000 001-32 380 000, 32 500 001-32 880 000 et 33 000 001-33 020 000.
- Aucun littéral de graine du dépôt entre 30 et 51 millions (`grep` sur `R/` et `tests/`) **[V]** ; plages disjointes de #206 et de Fd.
- Recherche de collisions de #206 reprise dans le script ; tous les tirages sous `engine_sous_graine()`.

**Contrôles (arrêt si l'un échoue)** :
- **(a)** sur `reserve2`, les 13 `p_mc` du script sont identiques à `reserve2.rds` ;
- **(i2)** sur `reserve2` et un triangle sur 50, les 13 `p_mc` et les B effectifs avec catalogue injecté sont `identical()` à ceux de `mw_bootstrap()` sans injection ;
- **(c)** valeurs des candidats sur `reserve2` égales à celles du § 7 ;
- **K0-x** (§ 2.3), **K0-t** (§ 2.5), **K0-c** (§ 2.2) ;
- **(i2′)**, lancé par `audit` après #301 et après #300 : la p du moteur modifié est identique à celle du candidat retenu, sur `reserve2` et sur les triangles marqués (i2).

Le script passe `audit` léger et `/code-review` **avant** l'exécution longue (leçon (2) de Ff). Ses empreintes md5 sont citées au T0.

### 2.7 Sorties et critères fixés avant exécution

**Sorties** : `docs/tableaux/AAAAMMJJ-issue309-puissance-mw.md` et `-brut.tsv`.
- **T0** : provenance, CV réalisés, refus.
- **T1** : niveau des candidats (volet A : loi × statistique × seuil, taux, IC, ρ, classe) ; P2 sous N.
- **T2** : puissance (plan × scénario × statistique × seuil), Rosner P(k̂ ≥ 1).
- **T3** : McNemar exact sur les paires de décision : MinP/Grubbs, MinP/MinP4, MinP/TMax, FWr/FWb, FWr/BP, FWb/BP.
- **T4** : part des triangles CEL où la statistique désigne (2,1).
- **T5** : décomposition de BP sous H0 (§ 3.4).
- **T6** : niveau des p non simulées (Bonferroni, χ² des variantes).
- **T7** : grandeurs pour Fj (§ 6).

Les valeurs reprises dans les rubriques 7 de M1 à M4 sont celles des T1 et T2, avec leur statut.

**Critères** (recopiés tels quels dans le script et au T0, évalués mécaniquement) :
- **K-301 (choix de la variante de BP)** :
  1. FWr est retenue si, sous N et E, aux deux seuils, sa classe est compatible, écart mineur ou distorsion conservatrice, sans distorsion matérielle libérale sous A ;
  2. à défaut, FWb aux mêmes conditions ;
  3. à défaut, arrêt D2-Fi.
- **K-300 (choix de la statistique de M4)**. Un candidat est éligible si :
  - (i) son niveau Monte-Carlo n'a aucune distorsion matérielle libérale sous N, E et A ;
  - (ii) sous P1, son taux de rejet est au moins celui de Grubbs à 0,10, à CEL6 et CELx4, et strictement plus grand à 0,05 (McNemar exact à 0,05).

  Entre MinP et MinP4 éligibles, on retient celui que le McNemar favorise à CEL4 et CEL6 ; à égalité, MinP, qui couvre plus de cellules. TMax n'est retenu que s'il domine les deux. Aucun candidat éligible : arrêt D2-Fi, et Grubbs reste en l'état.
- Les autres grandeurs sont descriptives, sans seuil.

## 3. #301 : Breusch-Pagan sur résidus de Mack (S-Fi-3)

### 3.1 Ce que teste la ligne actuelle, et la variante

**Hypothèse visée** : D(2)(h)(iv), variance proportionnelle à C(i,j).

**Ligne actuelle.** LM = nR² de r² ~ C sur les 27 cellules. **Verdict : à remplacer.**
- 98,6 % de S_xx est entre colonnes **[V]**, et les moyennes de colonne de r² valent exactement (n_j − 1)/n_j **[V]** (`reserve2` : 0,8571 … 0,5).
- La covariance de la statistique est dominée par une part entre colonnes fixée par construction : S_xy entre = −1 762 contre S_xy intra = −412 **[V]**.

**Deux artefacts de construction subsistent dans la variante de l'issue (r²)** :
1. Colonne n_j = 2 : r₁² = C₂/(C₁ + C₂) exactement **[V]** (0,513538 ; 0,486462). La relation intra-colonne entre r² et C y est purement mécanique et décroissante.
2. Plus généralement, Var(r_ij | C) = 1 − h_ij à σ_j connu (en-tête de `.mw_pool_residus()`). E[r²] décroît donc avec C dans chaque colonne **[H]** (effet faible à CV de 7 %, plus marqué à 25 %).

**Variante recommandée (FWr)** :
- **Statistique** : LM = n · [1 − SCR(r̃² ~ facteur(j) + C) / SCR(r̃² ~ facteur(j))], avec r̃² = r²/(1 − h) et 1 − h = S_sans/S (`.mw_sommes_autres()`, redressement de #46).
- **Cellules** : colonnes n_j ≥ 3, où r̃² n'est pas identiquement 1 (à n_j = 2, |r̃| = 1 exactement, en-tête du moteur) ; colonnes dégénérées exclues par `e$res`. n = 25 sur `reserve2`.
- **Garde** : statistique NA si SCR(r̃² ~ facteur(j)) = 0 ou si C est constant dans toutes les colonnes retenues.
- **Construction** : nR² de Koenker (1981) avec effets fixes de colonne, par partialisation (Frisch-Waugh). La forme « n × R² partiel » est celle d'un multiplicateur de Lagrange à paramètres de nuisance estimés sous H0 **[H, dérivation non sourcée ici]**. C'est une construction de l'outil pour des résidus de Mack, parallèle à la pente intra-colonne (#119), et non un test publié.
- **p-value** : Monte-Carlo (bootstrap du moteur, queue haute), retenue. La p χ²(1) reste une p non simulée, jamais retenue (#181).

**Variante de Harvey** (log r² ~ facteur(j) + log C) : **non retenue**.
- La forme du test auxiliaire n'est pas vérifiée sur le texte **[NV]**.
- Le logarithme de résidus proches de 0 est instable ; l'estimation de la pente α − 1 relève du diagnostic (#308) et d'ExpVar.
- Sur `reserve2`, p Monte-Carlo 0,822 **[V]**, sans apport.

### 3.2 Valeurs sur `reserve2` [V] (graine 20260831, B = 999)

| Variante | Statistique | p χ²(1) | p_mc | err_mc | Quantile 0,90 bootstrap | Écart-type bootstrap |
|---|---|---|---|---|---|---|
| actuelle (BP) | 0,6502 | 0,4200 | 0,103 | 0,0096 | 0,657 | 0,183 |
| FWb (issue) | 1,7598 | 0,1846 | 0,214 | 0,0130 | 3,03 | 1,526 |
| FWr (recommandée) | 1,4373 | 0,2306 | 0,285 | 0,0143 | — | — |

Repère χ²(1) : quantile 0,90 = 2,706, écart-type √2 = 1,414. Les chiffres de l'issue (0,657 ; 3,03 ; 0,214) sont reproduits.

**Verdict sur `reserve2`** : OK inchangé.

### 3.3 Protocole de niveau, puissance attendue

**Niveau** : volet A (§ 2.5).

**Pilote (non citable)** : H0, P1, loi N, R = 240, B = 999.

| Statistique | Taux à 0,10 | Taux à 0,05 |
|---|---|---|
| BP | 0,021 | 0,004 |
| FWb | 0,083 | 0,058 |
| FWr | 0,092 | 0,058 |

La valeur de BP retrouve le 0,016 de #206.

**Puissance** : nulle ou presque attendue sous P1 contre EXP0 et EXP2 (réserve de l'issue), à mesurer sous P2. **Non-spécificité constatée au pilote** : contre CELx4, FWr rejette 1,000 et FWb 0,900 à 0,10 (R = 60) ; une cellule aberrante crée une hétéroscédasticité apparente. La rubrique 7 le dira.

**Verdict sur la variante** : pertinente sous réserve de K-301 ; preuve faible sous P1 quel que soit le niveau (dispersion de C).

### 3.4 Cause du sous-rejet de la p χ² (à écrire dans `mw:m2bp`, l. 14313-14317, et l. 16247)

Constats sur `reserve2` **[V]** :
1. Σ_i r(i,j)² = n_j − 1 fixe les moyennes de colonne de r².
2. La variance de C est entre colonnes à 98,6 %.
3. La part entre colonnes de la covariance r²/C est donc quasi déterministe : elle ne dépend que de la géométrie et des moyennes de colonne de C.
4. nR² est dominé par un terme quasi constant (≈ 0,65), de dispersion bootstrap 0,183 contre 1,414 pour χ²(1).

La loi de la statistique n'est donc pas χ²(1), ni par sa position ni par sa dispersion, et la p χ² est très supérieure à la p réelle.

Statut : identités exactes et mesures sous un plan ; mécanisme **[H]**, confirmé ou non par le T5 (moyenne et écart-type des parts entre et intra colonnes sous H0, sous P1 et P2). La phrase actuelle « Cause non établie » est remplacée par ce constat. Le conservatisme du niveau Monte-Carlo de BP (0,016 sous N) et sa dépendance à la loi des erreurs restent **non expliqués** : le dire.

### 3.5 Critères d'acceptation de #301

- K-301 tenu ; T1 cité ;
- (i2′) conforme ;
- tableau avant / après (§ 7) ;
- `mw:m2bp` corrigée selon le § 3.4 ;
- détail de la ligne : effets fixes de colonne, résidus redressés, colonnes n_j ≥ 3 ;
- `loi` = « chi2(1) asymptotique (effets fixes de colonne) -> Monte-Carlo ».

## 4. #300 : M4, cellule aberrante (S-Fi-2)

### 4.1 Statistique, cellules et colonnes exclues

1. **t(i,j)** : résidu studentisé externe de la régression pondérée C(·,j+1) ~ 0 + C(·,j), poids 1/C(·,j).
   - Il est égal à `stats::rstudent()` de cette régression à 1e-13 près sur les colonnes j = 0 à 4 de `reserve2` **[V]**, ce qui fournit un oracle de test unitaire.
   - Calcul : `mw_influence()` (DFBETAS) et (1 − h)/h = S_sans/C. **`mw_influence()` n'est pas modifiée** : sa sortie alimente `res$plots_data$influence`.
   - Nouvelle fonction nommée, par exemple `mw_test_cellule_aberrante(aj, j_degeneres = NULL)`, qui rend t, p_ij, la cellule de l'extremum, N_t et la statistique.
2. **Statistique M = min_{(i,j)} p_ij**, avec p_ij = 2 F_{t(n_j − 2)}(−|t(i,j)|). Queue basse.
   - **Pourquoi pas max|t| brut** : les degrés de liberté vont de 1 (n_j = 3, loi de Cauchy) à 5. Sous le bootstrap de `reserve2`, la colonne n_j = 3 porte 55 % des maxima de |t| **[V]**.
   - Sur l'exemple × 4 de #300 : p_mc de TMax 0,054 contre 0,002 pour M **[V]**. Au pilote (CELx4, R = 60) : TMax 0,750 contre M 1,000 au seuil 0,05.
3. **Exclusions et gel** :
   - cellules des colonnes n_j ≤ 2 (aucun degré de liberté) ;
   - colonnes de `figes$degeneres` ;
   - variante MinP4 : colonnes n_j ≤ 3, selon K-300.
   - N_t (25 sur `reserve2`, 22 pour MinP4) est fixé par la configuration observée.
   - Dans une réplication, une colonne retenue à l'observé qui devient dégénérée (t NA) rend la statistique NA ; la réplication sort de B effectif (volet 2 de #56).
4. **Cellule à influence non bornée** (`dfbetas_non_borne`, les autres cellules de la colonne étant proportionnelles). Cas réaliste dans les colonnes tardives, quand plusieurs F valent exactement 1. Trois options (Q-D1-Fi-8) :
   - **(iii), recommandée** : statistique observée non définie, motif propre posé par le champ `non_definie` du catalogue (« cellule (i,j) : autres cellules de la colonne proportionnelles, résidu studentisé non borné »), ligne en diagnostic par le mécanisme existant. Dans une réplication, p_ij = 0.
   - (i) p_ij = 0 à l'observé aussi : ECHEC mécanique à 1/(B + 1), que le bootstrap continu ne reproduit pas.
   - (ii) un ensemble figé de plus dans `.mw_ensembles_figes()`.
   - *Annotation du 21/10/2026 (agent architect (IA), décision 1 du mainteneur du 21/10/2026 au soir, handoff `6326788489` de la PR #349, #300)* : **option (iii) retenue, code de `969cc98` conservé tel quel** ; la ligne M4 (MinP4) à cellule à influence non bornée est un **test sans p-value retenue**, et non un diagnostic (`CONTEXT.md`, « Test sans p-value retenue », second cas avec réplications finies). La rédaction « ligne en diagnostic par le mécanisme existant » ci-dessus, et celle de l'encadré (Q-D1-Fi-8), ne décrivent pas ce que fait ce mécanisme : à l'observé, `mw_test_cellule_aberrante()` rend `stat` et `p` (borne de Bonferroni) à `NA` ; le champ `non_definie` de l'entrée `MinP4` de `MW_CATALOGUE_MC` (`.mw_motif_cellule_non_bornee()`) substitue son motif propre (« statistique observee non definie : residu studentise non borne en cellule (i,j) (autres cellules de la colonne proportionnelles) ») au motif générique `MOTIF_MC_OBS_NON_FINIE` ; aucune p non simulée n'existant, la frontière de #181 laisse la ligne de `type = "test"` : `p_retenue = NA`, `nature_p = NA`, verdict INFO, `sens` conservé, `inoperant = FALSE`, `detail` ouvert par « Monte-Carlo indisponible : <motif> ; aucune p-value disponible sur ces donnees : aucun verdict (ADR 0001). ». En réplication (`replique = TRUE`), p_ij = 0 et la réplication reste dans B effectif. Constaté [V] sur le triangle `tri_nb300` de `tests/unitaires/test_merz_wuthrich.R` (`mw_bootstrap(a, B = 99)`, puis `mw_tests()`) ; test unitaire « M4 (#300) option (iii) : mw_bootstrap() -> … verdict INFO ». Terme à employer par `docwriter` dans la fiche `mw:m4gr`.
5. **Descriptifs** : `estim` = t(i,j) de la cellule du minimum ; le `detail` la nomme (i, j, n_j), sans nombre issu du bootstrap (#76). La statistique est continue : `p_min` NA, pas d'`extremes`, et les « 13 statistiques discrètes » de `CLAUDE.md` sont inchangées.

### 4.2 p-values

- **Retenue : Monte-Carlo**, par le bootstrap existant, queue basse, sans tirage supplémentaire.
- **p non simulée : borne de Bonferroni** min(1, N_t · M), en colonne `p_asymptotique`, jamais retenue (#181). C'est une borne sous le modèle auxiliaire « Mack à erreurs gaussiennes » (famille (iii) de `CONTEXT.md`), et non une approximation asymptotique.
  - Sous ce modèle, t(i,j) suit une loi de Student(n_j − 2) conditionnellement à C(·,j) : résultat classique de la régression gaussienne, référence à vérifier par `docwriter` sur le texte (Cook et Weisberg 1982 ; Belsley, Kuh et Welsch 1980) **[NV]**.
  - Simulation **[V]** (4 000 triangles, Mack ajusté à `reserve2`, erreurs gaussiennes) : P(p_ij ≤ 0,10) = 0,101, 0,092 et 0,106 pour les cellules (0,0), (0,1) et (0,4) ; test de Kolmogorov-Smirnov contre la loi uniforme, p = 0,31 et 0,06.
  - La borne de Bonferroni y rejette 0,099 à 0,10 et 0,049 à 0,05 : elle est quasi exacte, à l'inverse de celle de Grubbs (aucun rejet sur 5 000 triangles, `mw:m4gr`).
- **Prédiction à mesurer, [H]** : la loi bootstrap (vivier discret de 27 valeurs) a une queue basse de M plus lourde que la loi gaussienne. Sur `reserve2` : P*(N_t · M < 0,10) = 0,179, contre 0,099 sous la loi gaussienne. Les colonnes courtes portent le minimum plus souvent (j = 4 : 0,209 contre 0,122).
  - La p Monte-Carlo serait donc conservatrice sous N. Pilote (H0, P1, N, R = 240) : M 0,075 et 0,037 ; MinP4 0,083 et 0,037 ; Bonferroni 0,104 et 0,067.
  - Coût en puissance au pilote (CEL4, R = 60) : M 0,167, Bonferroni 0,333, Grubbs 0,233.
  - **Une cellule aberrante modérée reste donc peu détectable à T = 8**, et Grubbs n'y est pas dominé au pilote. C'est la raison de K-300 et du point D2-Fi.

### 4.3 Rosner et Grubbs (sur la base de #347, relevés contrôlés)

**Contrôlé [V]** :
- `test_rosner()` rend λ = 2,0317 et 1,9381 (T = 8, α = 0,10), 2,1266 et 2,0200 (α = 0,05), 2,9450 (n = 25, l + 1 = 10, α = 0,005), soit les valeurs que #347 donne pour l'éq. (2.5) ;
- 2,6981 à n = 27, α = 0,10 (λ₁ de l'issue) ;
- la conformité du code à la formule (2.5) transcrite par #347, à la lecture.

Les citations et pages de Rosner (1983) (cadre i.i.d. normal p. 165 ; « approximate percentiles » ; domaine n ≥ 25, p. 165, 167 et 171 ; non-normalité renvoyée à des travaux futurs, p. 171 ; Monte-Carlo pour les petits n, p. 171) sont **reprises de #347, non relues ici**.

**Rosner sur résidus de Mack : à retirer** (recommandation, Q-D1-Fi-7). *(Décision du mainteneur, contre la recommandation : ligne conservée en diagnostic par décision, verdict INFO, k̂ et rangs restitués, phrase fixe d'`actuary` ; voir l'encadré.)*
- Le cadre de l'article (i.i.d. normal, p. 165, #347) ne couvre pas des résidus à contraintes exactes ; l'argument « 27 ≥ 25 » ne tient pas (écart 1 de #347).
- La puissance est pratiquement nulle **[V]** :
  - 0 déclaration sur 2 000 triangles sous H0 (#206) ;
  - 0 au pilote sous H0 (R = 240), CEL4 et CELx4 (R = 60) ;
  - exemple × 4 : R₁ = 2,221 < λ₁ = 2,698.

  Une procédure qui ne déclare jamais rien n'apporte aucune preuve d'absence.
- **« Rosner porté sur t » : sans appui** (#347 § 3).
  - Les λ_i de (2.5) supposent un échantillon i.i.d. normal restudentisé par sa propre moyenne et son propre écart-type. Les t(i,j) sont déjà studentisés, de degrés de liberté variables et dépendants.
  - Le conserver exigerait des seuils calibrés par Monte-Carlo : une méthode nouvelle, sans source, non recommandée dans Fi.
- Si le mainteneur veut une procédure à plusieurs cellules, une procédure de Holm sur les p_ij est à proposer hors de Fi, avec sa source à vérifier **[NV]**.
- `test_rosner()` reste inchangée (Fh, #304).

**Grubbs sur résidus de Mack : statistique remplacée par M, la ligne subsiste** (tableau de la revue, ligne « Cellule aberrante (Grubbs) » ; sous réserve de K-300).
- G est borné par √(n_j − 1) dans chaque colonne et se masque lui-même (exemple × 4 : G = 2,221, p_mc 0,085 **[V]**).
- Au pilote, contre CELx4 : 0,717 à 0,10 mais **0,000 à 0,05** : jamais ECHEC.
- Niveau sous A : 0,159 (#206, écart non tranché du côté libéral).
- #347 n'apporte rien sur Grubbs appliqué à des résidus.
- La clé `Grubbs` de `MW_CATALOGUE_MC` est remplacée par une clé nouvelle (par exemple `CelluleT`) : 13 entrées au total. `test_grubbs()` reste inchangée.
- Libellé : « Cellule aberrante du triangle (residus studentises externes) ». H0 et H1 inchangés.

**Verdict sur la ligne nouvelle** : pertinente comme test d'une cellule aberrante isolée sous réserve de K-300 ; puissance faible contre un écart modéré (environ 4 écarts-types de bruit) à T = 8, à écrire en rubrique 7.

### 4.4 Verdicts prévisionnels sur `reserve2` [V] (graine 20260831, B = 999)

| Ligne | Avant | Après (M, recommandé) |
|---|---|---|
| Cellule aberrante | Grubbs : G = 1,5932, p_mc 0,892, p Bonferroni 1, OK | M = 0,1033 (cellule (0,2), t = −2,318, n_j = 5), p_mc 0,944, err_mc 0,0073, Bonferroni 1, **OK** |
| Rosner | k̂ = 0, OK | **ligne retirée** *(décision Q-D1-Fi-7 : ligne conservée en diagnostic, INFO)* |

Variantes : MinP4 donne M = 0,1033 et p_mc 0,898 (OK) ; TMax donne 2,7242 et p_mc 0,944 (OK).

Effet : 20 lignes → 19 ; OK 8 → 7 ; ALERTE 2, ECHEC 4 et INFO 6 inchangés. *(Après Q-D1-Fi-7 : 20 lignes conservées ; OK 8 → 7, INFO 6 → 7, ALERTE et ECHEC inchangés ; à constater au tableau avant / après.)* Objet `bootstrap` : clé `Grubbs` remplacée, les 12 autres `p_mc` inchangées **[V par injection]**. σ_USP inchangé : `mw_parametre()` ne reçoit aucun test, et le flux de tirages est inchangé **[V, lecture]**. **Visa du mainteneur requis** (retrait d'une ligne à verdict, statistique changée).

### 4.5 Passages du `.tex` (pour `docwriter`, en fin de branche)

- `mw:m4gr` (l. 15120-15157) : réécrite pour M.
- `mw:m4ros` (l. 15160-15192) : retrait, en conservant la trace selon `CONVENTIONS.md` *(après Q-D1-Fi-7 : réécrite en fiche de diagnostic, non retirée)* ; écarts 1 et 2 de #347 : « tabulées » l. 15173 et l. 6036, domaine « n ≥ 25 » l. 15179-15183.
- `tab:nature`, l. 6032-6038.
- Rubriques 7 de M1 à M4 (T1, T2).
- `sec:calib-mc-mw` (l. 16320) ; `mw:m2bp` et l. 16247 (§ 3.4).
- Index des fonctions.

Les numéros cités par #300 (14314, 14320-14324, 5765) ont glissé : ce sont les lignes ci-dessus.

**Frontière** : les écarts 3 à 8 de #347 relèvent de Fh ; #317 (Fl, « cause du sous-rejet de BP », « Rosner tabulées ») se réduit d'autant.

### 4.6 Critères d'acceptation de #300

- K-300 tenu (T1, T2, T3, T4 cités) ;
- (i2′) conforme ;
- oracle `rstudent()` en test unitaire ;
- règle de non-borne testée (triangle construit) ;
- `test_grubbs()` et `test_rosner()` inchangées (`git diff`) ;
- tableau avant / après ; visa.

## 5. #289 : contrôle des ensembles figés (S-Fi-4)

1. **À l'observé** : sur les 5 000 triangles du plan de #206 (graines de #206), les trois éléments de `.mw_ensembles_figes(aj)` sont vides, K vaut 5 pour l'ordonnée et 4 pour la courbure. Coût de quelques minutes.
   - *Annotation du 19/10/2026 (session principale, d'après `actuary` et `audit`, #289)* : inexact pour `degeneres`, qui vaut {6} sur tous les triangles (colonne j = 6, un seul facteur, n_j = 1, hors des seuils n_min des deux tests ; déjà traitée ainsi au commit de #206) ; seuls les deux ensembles de #270 et #273 sont vides. Constaté au T1 de `docs/tableaux/20261019-issue289-ensembles-figes-mw.md` ; sans effet sur les niveaux.
2. **Réplications** : **50 triangles par loi (N, E, A), soit 150**, b = 1 à 50 de chaque loi, B = 999 aux graines de #206, environ 150 000 réplications. Catalogue réduit injecté {Origine, Courbure, sonde}. La sonde compte, par réplication :
   - les colonnes à moins de 2 (ordonnée) ou 3 (courbure) valeurs distinctes, par le prédicat de #290 ;
   - les statistiques NA par cause : `lm()` qui écarte une colonne, ou colonne dégénérée.

   On lit aussi le B effectif d'Origine et de Courbure. Coût environ 35 min CPU, 10 min d'horloge ; pas de sauvegarde.
3. **Lecture** : zéro événement sur environ 150 000 réplications borne le taux à 2,0e-5 par réplication (règle de trois, 95 %), soit un effet sur une p_mc inférieur à 1e-3 par triangle et négligeable devant les IC de #206 (±0,013).
   - **Nul attendu [H]** : première colonne à 8 valeurs distinctes et erreurs continues, ou vivier sans coïncidence exacte.
   - Comparaison descriptive des p_mc d'Origine et de Courbure de ces 150 triangles aux colonnes `pR:` du brut de #206, avec les différences listées. Ce n'est pas un critère : #253 a pu changer des bits.
4. **Si le contrôle n'est pas nul** : remesure des niveaux d'Origine et de Courbure par le protocole de #206 réduit à ces deux clés (N 2 000, E 2 000, A 1 000, même graines, McNemar apparié avec #206), environ 18 h CPU et 5 h d'horloge, branche de sauvegarde. Décision du mainteneur.

**Sortie** : `docs/tableaux/AAAAMMJJ-issue289-ensembles-figes-mw.md`. Contrôle nul : la phrase de réserve de `sec:calib-mc-mw` devient un constat mesuré.

## 6. Frontière avec Fj (#308, #307) (S-Fi-5)

#309 fournit à Fj, sans rien décider :
- la puissance d'Origine, de PenteIntra, de Courbure, d'HomogF, d'ExpVar, de BP et des variantes de BP sous P1 et P2 contre CST, EXP et DFI : effet du CV ;
- le CV réalisé par colonne ;
- au T7, le taux de rejet **par colonne** du t de Student de l'ordonnée à l'observé (`mw_test_ordonnee_origine()$detail$p`), à confronter aux effets minimaux détectables de #308 (20, 16, 26, 36 et 67 %) ;
- le constat de colinéarité volume / année (§ 2.2).

Facultatif (Q-D1-Fi-9) : la pente relative de #307, injectée comme candidat mesuré sans décision, niveau (volet A) et puissance (volet B), pour un coût d'environ 0,3 ms par réplication. Elle épargnerait à Fj une seconde mesure longue et satisferait le critère « niveau sous le protocole de #206 » de #307.

Hors Fi : toute ligne ou tout `detail` nouveau de M1 et M2 (#308), la pente relative et le statut de la famille α (#307).

## 7. Effets, régénérations, ordre

- **σ_USP inchangé** dans toutes les étapes. Aucun cas lognormal touché.
- **#290** : identiques au bit près.
- **#289 et #309** : mesures hors CI, aucune référence.
- **#301** : régénération `claude/regeneration-301`. Ligne M2 BP, avec FWr :
  - stat 0,6502 → 1,4373 ; p_as 0,4200 → 0,2306 ; p_mc 0,103 → 0,285 ; err_mc 0,0096 → 0,0143 ;
  - verdict OK → OK ;
  - phrase de #244 probablement retirée (|0,103 − 0,10| < 2 err_mc avant ; plus après) **[H, à constater]** ;
  - `loi`, `detail`, `bootstrap$p_mc["BP"]`, `stats_obs` changés.

  Avec FWb : 1,7598 ; 0,1846 ; 0,214 ; 0,0130. **Aucun verdict ne change sur `reserve2`** : `actuary` valide.
- **#300** : régénération `claude/regeneration-300` (§ 4.4) ; **visa du mainteneur**.
- **Ordre** : #290 → #289 → #309 (script, `audit` léger, `/code-review`, `--essai`, exécution des volets A et B sur la branche de sauvegarde) → **D2-Fi** → #301 → #300 → `docwriter`.
  - #301 peut commencer dès le volet A terminé, pendant le volet B.
  - Une seule régénération à la fois sur les deux branches (C4⁗).

## Questions au mainteneur pour D1-Fi

- **Q-D1-Fi-1 — Taille et sauvegarde de #309.** *Recommandation* : plan (A) (R = 1 000 sur huit cellules, 500 ailleurs, environ 22-24 h) plus le volet A (environ 4 h), sur une **branche de sauvegarde `claude/sauvegarde-309`** consignée dans la fiche Fi. *Alternative* : (B), R = 1 000 partout, environ 32 h.
- **Q-D1-Fi-2 — Scénarios et paramètres** du § 2.3 (θ = 0,10 aligné sur Fd ; γ = 0,20 ; λ = 4 et 6 ; cellule ciblée (2,1)). *Recommandation* : oui.
- **Q-D1-Fi-3 — Second plan** : κ = 3,4, monotone comme `reserve2`. *Recommandation* : oui, sans P3 dans Fi. *Alternative* : P3 permuté sur H0, CST20 et DFI (environ +5 h). *(Tranchée : P2 et P3 permuté.)*
- **Q-D1-Fi-4 — Niveau de #301 et #300** par le volet A (graines de #206, témoins identiques) puis (i2′), au lieu d'une remesure par `calibration_mc_mw_t8.R` après le code. *Recommandation* : oui.
- **Q-D1-Fi-5 — #301** : variante FWr (r̃², n_j ≥ 3, effets fixes de colonne), sous K-301 ; Harvey non retenue. *Alternative* : FWb (forme de l'issue).
- **Q-D1-Fi-6 — #300** : statistique M = min des p de Student (MinP ou MinP4 selon K-300), p Monte-Carlo retenue, Bonferroni en p non simulée ; elle remplace la statistique de Grubbs sur la même ligne ; `test_grubbs()` inchangée. *Alternative* : max|t| brut, déconseillé (§ 4.1, point 2).
- **Q-D1-Fi-7 — Rosner** (M4) : *recommandation* : **retrait de la ligne**. *Alternatives* : diagnostic sans verdict ; Rosner sur t à seuils calibrés par Monte-Carlo (sans source, #347). *(Tranchée : diagnostic sans verdict, diagnostic par décision.)*
- **Q-D1-Fi-8 — Cellule à influence non bornée** : *recommandation* : option (iii), ligne en diagnostic avec motif. *Alternatives* : (i) ou (ii) (§ 4.1, point 4). *(Option (iii) retenue ; ligne précisée le 21/10/2026 en test sans p-value retenue, non en diagnostic : annotation du § 4.1, point 4.)*
- **Q-D1-Fi-9 — Pente relative de #307** mesurée dans #309, sans décision. *Recommandation* : oui.
- **Q-D1-Fi-10 — Point d'arrêt D2-Fi** après les tableaux de #309 : choix des variantes sur K-301 et K-300, ou décision du mainteneur si un critère échoue. *Recommandation* : oui.
- **Q-D1-Fi-11 — Régénérations** : deux, une par issue (#301, puis #300) ; validation d'`actuary` pour #301 (verdict inchangé), visa du mainteneur pour #300.

---

## Retour

- **Statut** : `revue requise`. La spécification est complète, mais elle dépend de onze décisions du mainteneur (D1-Fi), et le choix final des statistiques de #300 et #301 dépend d'une mesure non encore faite (D2-Fi).
- **Résultat** :
  - #309 : protocole chiffré, en deux volets, avec critères fixés avant exécution. Durée d'environ 26-28 h d'horloge sur 4 cœurs en plan (A) ; branche de sauvegarde nécessaire.
  - #301 : la statistique actuelle est **à remplacer** ; variante FWr recommandée.
  - #300 : max|t| brut **écarté** au profit du minimum des p de Student ; Rosner Merz-Wüthrich **à retirer** *(décision : diagnostic par décision)* ; Grubbs Merz-Wüthrich **remplacé** sous K-300.
  - #289 : 150 triangles × 999 réplications.
  - #290 : sans spécification.
- **Preuves** :
  - *Vérifié (mesures reproductibles par les scripts de session, hors dépôt, non versionnés)* :
    - identité t = `rstudent()` à 1e-13 près ;
    - 13 `p_mc` identiques à `reserve2.rds` sous injection ;
    - toutes les valeurs des § 3.2 et 4.4 ;
    - chiffres des issues #300 et #301 reproduits (σ̂₁ 0,844 → 24,9 ; r 2,05 ; G 2,22 ; t 60,3 ; quantiles 0,657 et 3,03 ; p 0,214) ;
    - cellule ciblée (2,1) ;
    - identité de la colonne n_j = 2 ;
    - décomposition de BP en parts entre et intra colonnes ;
    - loi de Student par cellule et borne de Bonferroni sous le modèle gaussien (R = 4 000) ;
    - queue plus lourde de M sous le bootstrap ;
    - λ_i de #347 ;
    - première colonne linéaire en i ;
    - durées (17,7-18,6 s par triangle, catalogue complet ; 10,8 s, catalogue réduit) ;
    - aucun littéral de graine entre 30 et 51 millions.
  - *Pilote (R = 240 et 60)* : ordres de grandeur seulement, non citables.
  - *Hypothèses* : mécanisme du sous-rejet de BP (à confirmer par le T5) ; biais de levier de r² ; conservatisme de la p Monte-Carlo de M sous N ; résultat nul de #289 ; coût des candidats (+3 s par triangle).
  - *Non vérifié* : Harvey (1976) ; loi de Student de t sur les textes de Cook et Weisberg et de Belsley, Kuh et Welsch ; Holm ; pages de Rosner (1983), relevés de #347 contrôlés seulement sur les valeurs numériques et le code.
- **Informations manquantes** : accès réseau refusé (proxy 403), donc aucune source externe consultable dans cette session.
- **Décisions non résolues** : Q-D1-Fi-1 à 11 (mainteneur), puis D2-Fi.
- **Critères déclenchés** :
  - changement de résultat : #301 (p), #300 (lignes et verdicts, visa) ;
  - validité à T = 8 qu'aucun résultat exact ne tranche : niveau Monte-Carlo de M et de FWr, que tranchera la mesure du volet A ;
  - écart avec la sonde du bloc 6 (désignation de (2,2), erreur de coordonnées) et avec la proposition de #301 (artefacts de r²) : je propose une variante, sans contredire l'issue sur le fond ;
  - pas de désaccord avec `audit` ni avec un ADR.
- **Prochaine action recommandée** : soumettre Q-D1-Fi-1 à 11 au mainteneur. Versionner la spécification et les décisions en annotation datée. Ouvrir Fi par #290 (`coder`), puis #289 ; le script de #309 passe `audit` léger et `/code-review` avant `--essai`.

Scripts de session (hors dépôt, non versionnés) : `m1.R` à `m7.R`, avec les définitions communes de `m2_defs.R`, et `pilote.R` (§ 0) ; fiche Fi : `docs/feuille-de-route.md`, § 3.
