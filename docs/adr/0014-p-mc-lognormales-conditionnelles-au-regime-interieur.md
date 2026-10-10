---
status: accepted
date: 2026-10-10
---

# Les p-values Monte-Carlo de la méthode lognormale visent la calibration conditionnelle au régime de δ̂ quand δ̂ est intérieur, et restent la p marginale du moteur quand δ̂ est au bord (variante hybride V3h)

## Contexte

**Constat de départ.** La p-value Monte-Carlo des 34 statistiques d'`USP_CATALOGUE_MC` (V1 dans la suite) est calculée par `.mc_p_values()` / `engine_p_mc()` sur les 999 tirages de `usp_bootstrap()`, sans tenir compte du régime de δ̂ (bord 0, intérieur, bord 1 au sens de `TOL_DELTA_BORD`, `usp_regime()`). La calibration des p-values Monte-Carlo à T = 8 (#166, rejouée par #221 : `docs/tableaux/20261008-issue166-calibration-J{1,2}.md`, T1 bis) a localisé un conservatisme au régime δ̂* intérieur ; #175 l'a mesuré (`docs/tableaux/20261009-issue175-conservatisme-interieur.md`) : à α = 0,10, au régime intérieur de J2 (464 réplications sur 2 000), les huit statistiques de F_8 (BP, BP79, GQ, BF, Grubbs, Grubbsr, DAgo, JB) rejettent de 0 à 0,028 (JB). #175 a conclu à « proposer une évolution » sous sept réserves (R1 à R7) : variante δ fixé abandonnée, variante conditionnelle au régime prometteuse mais mesurée en partie de façon tautologique, p absente dans 69 réplications intérieures sur 75 de J1, verdict du jeu observé J2 changé (GQ). La question « faut-il changer la p_mc du moteur ? » a été confiée à la mesure #229.

**Ce qu'apporte la théorie, et ce qu'elle n'apporte pas** (consultation « théorie » d'`actuary-approfondi`, modèle Fable, 09/10/2026, #229 commentaire `6082311976` ; scripts non versionnés) :
- à l'intérieur, la condition de Kuhn-Tucker rive en partie la régression de z² sur un contraste en x (même famille de cas que MeanZ et VarZ, ADR 0001, atténuée) : V1, calibrée sur la loi **marginale**, admet des sous-ensembles reconnaissables au sens de Buehler (1959) ; le conservatisme n'est pas une erreur de plug-in du bootstrap mais l'écart entre la loi conditionnelle au régime et la loi marginale ;
- le régime **n'est pas ancillaire** (P(bord 0 | δ₀) de 0,63 à 0,31) ; seule P(intérieur) l'est presque. Cox (1958) et Buehler (1959) fondent le principe d'un test conditionnel, sans le justifier ici ; le prépivotage (Beran, 1988) et le double bootstrap calibrent le niveau marginal ; les tests conditionnels exacts (Fithian, Sun et Taylor ; Lee et al., 2016) supposent des familles exponentielles ou gaussiennes, hors de ce modèle ;
- **rien n'est établi à T = 8.**

**Mesure #229** (branche `claude/mesure-p-conditionnelle`, PR #238). Pièces :
- spécification et annotations datées (critère C1 à C5, profils D1 à D5, lectures L0 à L20, décisions A1 et A2) : `docs/specifications/229-p-conditionnelle-regime.md` ;
- grille semi-analytique : `docs/tableaux/20261009-issue229-grille.md` (pièce de A2) et `docs/tableaux/20261010-issue229-grille.md` (relancée avec le scénario A4), valeurs brutes `-grille-brut.tsv` ;
- partie régime (T0 à T3 sur J1, J2, J3, R = 2 000) : `docs/tableaux/20261010-issue229-p-conditionnelle-regime.md` et `-brut.tsv` (`1c14760`) ;
- partie puissance (six scénarios sur le modèle ajusté de J2, R = 1 000) : `docs/tableaux/20261010-issue229-p-conditionnelle-puissance.md` (`042aee2`) et `-brut.tsv` ;
- journaux : `docs/tableaux/20261010-issue229-journal-mesure.md`, `20261010-issue229-journal-combinaison-puissance.md` ; valeurs brutes et journaux versionnés en `3fda31a` (Q-A3-6) ;
- exécution : 48 tranches au commit mesuré `fee9968`, toutes « INTEGRITE OK », aucune réplication en erreur ; lecture d'`actuary` : #229, commentaire « Point d'arrêt A3 » (`6096322624`).

Variantes mesurées sur les mêmes réplications : **V1** (moteur) ; **V3a** (les tirages de V1 dont δ̂** est dans le régime de δ̂*, B effectif variable) ; **V3b** (V3a complétée, sur un flux distinct, jusqu'à 999 tirages retenus dans le régime ou 25 000 tirages au total) ; **V3h** (V3b si δ̂* est intérieur, V1 sinon).

**Résultats** (constats de simulation à T = 8, sous les modèles ajustés à J1 et J2 et sous le plan synthétique J3 ; pas des résultats établis) :
- **Profils mécaniques** (tableau de la partie puissance, « Profils ») : V3b **D3**, V3a **D3**, **V3h D1** (C1, C2, C3 et C4 remplies : la variante domine V1 quelle que soit la cible).
- **Intérieur** : V1 n'y rejette presque jamais sur F_8 (J2 : BP 0 sur 464). V3b, et donc V3h, corrige : C2a remplie avec 7 statistiques sur 5 requises sur J2 (BP, BP79, GQ, BF, Grubbs, DAgo, JB ; n = 464) et 4 sur 4 sur J3 (BP, BP79, GQ, BF ; n = 1 125, m₃ = 4).
- **Bords** : V1 y est proche du nominal (moyenne de F_8 entre 0,099 et 0,101 sur J2 et J3) ; V3b y devient conservatrice (0,071 à 0,083) et perd de la puissance : C4a de V3b en défaut, 52 pertes significatives (V3a : 53).
- **V3h** : aucune perte de puissance significative (C4a remplie) ; gains intérieurs significatifs dans 5 scénarios sur 6 (par exemple, scénario C4, contamination λ = 4 : puissance de Grubbs à l'intérieur de 0,194 sous V1 à 0,537 sous V3h). Pour la famille H (hétéroscédasticité), le gain intérieur est une restauration de la taille ; pour les familles C (contamination) et A (asymétrie), c'est un gain de puissance.
- **Marge de C1** : C1 de V3h est remplie **à une réponse près** : sur J3, BP à α = 0,05 donne 120 rejets sur 2 000 (0,0600, IC de Clopper-Pearson [0,0500 ; 0,0713], borne basse 0,049993 < α ; McNemar contre V1 69 / 0). Un rejet de plus aurait porté la borne basse au-dessus de α (0,050452 à 121 rejets, `qbeta(0.025, 121, 1880)`, recalculé par `architect`) et fait échouer C1b. Les marges sont d'une réponse pour V3a et de trois pour V3b.
- **Multiplicité (T2, sous H0)** : la part des réplications avec au moins une ligne en ECHEC passe, avec V3h, de 0,4835 à 0,5050 sur J2 et de 0,4425 à 0,5005 sur J3.
- **Témoins (C5)** : trois témoins de F_T, supposés indépendants du régime, sont significatifs sur J3 à α = 0,10 (AD 27 / 7, Intercept 58 / 18, Smirnov 13 / 0, après Holm) ; tous « expliqués » au sens de L15 (signe et ampleur prédits par la grille à e* près). La lecture d'A3 n'est pas suspendue, mais la partition F_T / F_R, fondée sur une indépendance au régime observée par simulation, **ne tient pas sur J3** pour ces trois statistiques.
- **V3a** : sur l'intérieur de J1 (hors critère, q faible), sa p est absente dans 69 réplications sur 75 (B effectif sous `B_MIN_DEGENERESCENCE`) : V3a est inutilisable quand la probabilité du régime intérieur est faible.
- **Coût de V3b à l'intérieur** (T3) : J2, 4 613 tirages en moyenne (maximum 5 459) pour 999 retenus ; J3, 2 103 (maximum 2 965) ; J1, hors critère, B_max = 25 000 atteint dans 35 réplications intérieures sur 75, sans p absente.
- **Jeux observés** : J2 (δ̂ = 0,663991, intérieur), p de GQ de 0,268 (V1) à 0,018 (V3b, 4 490 tirages, 999 retenus) : **le verdict change** ; J1 (δ̂ = 1, bord) : inchangé sous V3h, qui y reprend V1.

**Statut de V3h.** La p de V3h est une **p-value Monte-Carlo** : loi nulle simulée à paramètres estimés, erreur fonction de B (ADR 0002 : elle n'est pas exacte). L'arrêt adaptatif de V3b n'introduit pas de biais par rapport à un test de Monte-Carlo à B effectif fixé : conditionnellement au B effectif, les statistiques retenues sont i.i.d. sous la loi conditionnelle au régime (argument élémentaire de la spécification, § 5, sans référence). Que V3h soit « calibrée conditionnellement » à T = 8 est un **constat de simulation** sur trois jeux, non un résultat théorique.

## Décision

Arrêtée par le mainteneur le 10/10/2026 au point d'arrêt A3, en suivant les recommandations d'`actuary` (#229, commentaires `6096322624` et `6096356318`) :

1. **Cible** (Q-A3-1 (a), Q-A3-7) : la p-value Monte-Carlo d'une statistique d'`USP_CATALOGUE_MC` vise la **calibration conditionnelle au régime de δ̂** quand δ̂ observé est **intérieur**, et la **calibration marginale** du moteur actuel (V1) quand δ̂ est **au bord** (bord 0 ou bord 1). C'est la variante hybride **V3h**.
2. **Composition** (Q-A3-3 (a)), telle que mesurée : à l'intérieur, V3b — tirages du bootstrap dont δ̂** est intérieur, complétés par des tirages supplémentaires sur un flux distinct jusqu'à **B_cible = 999** retenus ou **B_max = 25 000** tirages au total (999 de V1 compris) ; au bord, V1 inchangée. Tout écart à cette composition (autre B_cible, autre B_max, V3a à l'intérieur) rouvre la décision.
3. **V3b et V3a écartées comme variantes autonomes** (Q-A3-2 (a)) : V3b (profil D3) est conservatrice aux bords et y perd de la puissance (52 pertes significatives) ; V3a (D3) a les mêmes pertes et devient inutilisable quand la probabilité du régime intérieur est faible (p absente dans 69 réplications intérieures sur 75 de J1). Aucune n'est conservée en option du moteur.
4. **Périmètre** (Q-A3-4 (a)) : toute la branche lognormale, `premium` (et ses variantes) et `reserve1`. L'extension à `reserve1` est une **hypothèse** : la mesure porte sur des modèles de primes (J1, J2) et un plan synthétique (J3). La méthode Merz-Wüthrich n'est pas concernée.
5. **Changements de verdict** (Q-A3-5 (b)) : approuvés **au cas par cas** par le tableau avant / après de l'implémentation (skill `verifier-reproductibilite`), dont GQ sur J2 observé (0,268 → 0,018). Aucune approbation de principe.
6. **Hausse de multiplicité consignée** : avec V3h, la part des réplications à au moins un ECHEC sous H0 monte (J2 : 0,4835 → 0,5050 ; J3 : 0,4425 → 0,5005). Elle est le prix d'un niveau rétabli à l'intérieur, non une distorsion créée (C1 et C2b remplies), et la documentation la restitue.
7. **Mise en œuvre hors de la branche de mesure** (point d'arrêt A4) : par une **issue nouvelle**, circuit 1, créée sur accord du mainteneur. La branche `claude/mesure-p-conditionnelle` ne modifie pas la p_mc du moteur.

## Options écartées

- **V1 conservée et documentée** (Q-A3-1 (c)) : V1 ne rejette presque jamais à l'intérieur (J2 : BP 0 sur 464) et V3h la domine sur les quatre conditions mesurées (D1).
- **V3h subordonnée à une mesure de confirmation de C1** (Q-A3-1 (b)) : non retenue ; la marge d'une réponse est consignée (Contexte) et documentée, et le tableau avant / après de l'implémentation reste soumis au visa.
- **V3b seule, V3a seule, ou l'une d'elles en option du moteur** (Q-A3-2 (b), Q-A3-3 (b)) : voir Décision, point 3.
- **Variante δ fixé** (#175) : aucune statistique corrigée, GQ et JB aggravés.
- **Prépivotage (Beran, 1988) et double bootstrap** : ils calibrent le niveau marginal et ne corrigeraient pas l'écart conditionnel (consultation « théorie », citations de seconde main).
- **Arrêt séquentiel de Besag-Clifford** : procédure différente de V3b, gain borné (consultation « accélération », #229 commentaire `6082311976`).
- **Ajusteur à un seul démarrage pour les tirages** : il fait basculer le régime de δ̂** dans 0,74 % des tirages sur J2 et 2,57 % sur J1, inadmissible pour une variante qui sélectionne sur ce régime (même consultation).

## Conséquences

- **Implémentation (A4)** : issue nouvelle, circuit 1 (`actuary` spécifie → `coder` → `audit` → `docwriter` → `actuary` valide), domaines `moteur:`, `tests:` et `docs:`. Fonctions touchées attendues : `usp_bootstrap()` (tirages supplémentaires quand δ̂ est intérieur, sur un flux distinct) et `.mc_p_values()` (p calculée sur les tirages retenus) ; `engine_p_mc()` et le catalogue (ADR 0003) gardent leur rôle. **Contrat partagé** : les champs de l'objet `bootstrap` lus par `usp_tests()`, `add()` et l'application (B effectif par statistique, granularité, `err_mc`, `p_min`, `res$metadata`) ; forme à fixer avec `architect` à la spécification.
- **Aléa** : les tirages supplémentaires sont une nouvelle source d'aléa ; ils passent par `engine_sous_graine()` avec une graine explicite consignée dans `res$metadata` (ADR 0004). Les 999 tirages de V1 restent inchangés, de sorte que `sigma_boot`, `delta_boot`, `z_boot` (enveloppe du QQ-plot) et l'intervalle bootstrap de σ ne changent pas (*hypothèse* à vérifier par `audit`).
- **Résultats** : changement des p_mc du moteur pour les seuls jeux à δ̂ intérieur ; p_retenue et verdicts susceptibles de changer (visa du mainteneur au cas par cas, point 5) ; références régénérées par la CI (ADR 0011). **σ_USP présumé inchangé** : `usp_parametre()` ne lit pas le bootstrap (`R/engine.R`, signature `usp_parametre(fit, sigma_standard, bareme)`) ; à vérifier par `audit` sur les cinq cas.
- **Hiérarchie des p-values** (ADR 0001, ADR 0002) : inchangée ; la p reste « Monte-Carlo ». Si l'implémentation change le libellé de `nature_p` ou ajoute un motif d'absence (B_max atteint avec B effectif sous `B_MIN_DEGENERESCENCE`), l'ADR 0003 est annoté et #181 (politique de repli quand la p Monte-Carlo manque) en tient compte.
- **Coût** : `run_engine()` s'allonge quand δ̂ est intérieur (de l'ordre de 2 000 à 5 500 tirages au total sur J2 et J3 pour 999 retenus ; jusqu'à 25 000 quand le régime intérieur est rare) ; à mesurer à l'implémentation.
- **Points à reprendre avec A4** : la partition F_T / F_R ne tient pas sur J3 (AD, Intercept, Smirnov) ; la documentation ne présente pas F_T comme « indépendante du régime » sans cette réserve. La marge de C1 et la hausse de multiplicité sont restituées dans `sec:calibration-mc`.
- **Documentation de cette branche** : `docwriter` (étape 9 de la fiche « Branche #229 ») documente la mesure, la décision A3 et cet ADR dans `sec:calibration-mc`, sans décrire V3h comme implémentée.
- **Branche de sauvegarde** `claude/sauvegarde-229` : supprimée après le commit des valeurs brutes (`3fda31a`) et sa CI verte (ADR 0007, annotation du 9 octobre 2026, trait 6).

Issues : #229 (mesure et décision) ; #175, #221 (constats de départ) ; #237, #231 (préalables de la mesure) ; issue A4 à créer ; #181 (repli, à articuler). PR #238.
