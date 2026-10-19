# Spécification de Fh : lignes sans puissance ou redondantes de la méthode lognormale (H2 à H4, ESD), jackknife — point d'arrêt D1-Fh (#339, #327, #303, #302, #299, #304, #347)

> **Décisions du mainteneur du 19/10/2026 (E-19/10 (D1-Fh)) : point d'arrêt D1-Fh franchi.**
>
> *Consignées par l'agent architect (IA)* (fiche de base), à la demande de la session principale ; source : brief de la session principale. Le présent document assemble deux textes d'`actuary-approfondi` du 19/10/2026 : la spécification D1-Fh et son complément (#304 refondée sur #347, #347 intégrée à Fh). Le complément **remplace** le § 7, **ajoute** le § 7 bis et **modifie** les § 0, 10, 11, 13 et le Retour ; l'assemblage n'en change pas le fond. Les deux textes sources et les scripts de mesure sont **hors dépôt, non versionnés**. En cas de divergence entre le corps du document et cet encadré, l'encadré l'emporte.
>
> - **Q-D1-Fh-1 (#339)** : option 1, garde explicite ρ ≥ −1 + 1e-6 pour ρ < 0, uniforme en T ; domaine de validité dans le commentaire du moteur (§ 2).
> - **Q-D1-Fh-2 (#327)** : tolérance τ = 2 · `REP_SIGMA_KKT` · (2 + Δ(1) + Δ(2)) (et non la constante 1e-5) ; liste des années « d'influence égale à la précision numérique près » ; test du chemin réel de #329 sur le jeu construit du § 3.4.
> - **Q-D1-Fh-3 (#303)** : drapeau `regime$pi_constant`, bande `TOL_DELTA_BORD` comprise ; DWr, Runsr, supFr, CUSUMr et Grubbsr en diagnostic par règle à π̂ constant, **règle R15** (numéro fixé) ; retrait de Ljung-Box (1) sur ratios bruts (ligne et entrée `LB1r`) dans tous les régimes.
> - **Q-D1-Fh-4 (#302)** : sorts du tableau du § 5.1 : retrait de Shapiro-Wilk à loi nulle simulée, de Box-Pierce (2) (entrée `BP2`) et de Ljung-Box (1) sur z (entrée `LB1`) ; Kolmogorov-Smirnov et Cramér-von Mises en diagnostic par décision. Phrase H3 à π̂ variable (§ 5.3) ; Anscombe-Glynn non applicable à π̂ variable ; lecture conjointe de H3 renvoyée à #297 (Fk).
> - **Q-D1-Fh-5 (#299)** : **option (A)**. Breusch-Pagan studentisé (Koenker) reste un test, sans bascule ; son `detail` porte la phrase de puissance enveloppe π_env (fonction nouvelle propre à la branche lognormale, nom proposé `usp_puissance_enveloppe_h2(x, alpha)`, appelée par `usp_tests()`) ; **pas de règle R16**. Breusch-Pagan 1979, White, Goldfeld-Quandt, Brown-Forsythe, Smirnov (famille `C.` inchangée) et Spearman ratio-temps en diagnostic par décision. `usp_regime()` inchangée : #331 reste en Fk.
> - **Q-D1-Fh-6 (#304)** : **option (a)**. L'ESD lognormale passe en diagnostic par décision, pour tout T, avec la phrase du complément (§ 7.3). Les options (b) et (c) sont écartées ; `test_rosner()` est inchangée.
> - **Q-D1-Fh-7 (vocabulaire, `architect`)** : aucun terme « variante sans verdict » ; terme employé : « diagnostic par décision » (précédent #245). Règle **R15** numérotée ; R16 non créée (Q-D1-Fh-5). La formule « d'influence égale à la précision numérique près » (§ 3.3) est distincte d'« ex æquo », que `CONTEXT.md` réserve à `TOL_EX_AEQUO`. La liste des fonctions communes de C3⁗ est complétée par `lillie_p()`, `runs_p_min()`, `sw_p_loi_nulle()` et `sw_loi_nulle()` (§ 8.3 ; ADR 0007, annotation du 19/10). Les entrées de `CONTEXT.md` (§ 10) sont reprises par `architect` à l'étape 8 de Fh, sur l'état final.
> - **Q-D1-Fh-8 (#347)** : les parties `mw:m4ros` des écarts 3, 6 et 7 (avec les écarts 1 et 2) suivent #300 (Fi) ; Fh ne modifie pas `mw:m4ros`. La PR de Fh porte `Closes #347` (écarts 3 à 8, parties lognormales). Le report a été posté sur #300 (commentaire `6262412191`). #347 est le **septième numéro de Fh**, par décision expresse, en circuit 4 (commentaire `6262306477` de #347).
> - **Visa des changements de verdicts annoncés** (§ 4.4, 5.5, 6.4 sous (A), 7.4 ; tableau du § 9), donné sur la prévision. Les lignes passent de **51 à 47** à T = 8. Les lignes à verdict passent de 36 à 18 sur les quatre cas à δ̂ = 1 et de 36 à 24 sur `premium_interieur`. **σ_USP est inchangé** partout et `reserve2` n'est pas touché. Rappel de la règle : chaque commit qui change un résultat porte son tableau avant / après mesuré (skill `verifier-reproductibilite`) ; un écart entre ce tableau et la prévision revient au mainteneur.
>
> **Décision du mainteneur du 19/10/2026, en cours d'étape 3 (Q-D1-Fh-9, LB1r et LB1).** Sur la question d'`actuary-approfondi` (avis du 19/10 sur #303, Q4), le mainteneur retient l'**option (A)** : le retrait de Ljung-Box (1) sur ratios bruts (`LB1r`) et sur z (`LB1`, #302) est **maintenu**, sur un **motif reformulé**. Le motif « même information » (§ 1 (i), § 4.3, § 5.1) est **réfuté par la mesure** : Q = T(T + 2)ρ̂₁²/(T − 1) est fonction de |ρ̂₁| et non quasi monotone en DW. À T = 8, sous H0, ρ̂₁ est décentré (E = −0,126, écart-type 0,283), et 90,8 % des rejets de LB1 au seuil 0,10 ont lieu pour ρ̂₁ < 0. L'« égalité des puissances à 0,01 près » citée de #229 et #116 était une égalité de niveau. Puissances au seuil 0,10, calibration « oracle » sous le modèle ajusté à J2, sans réajustement, 20 000 tirages par alternative [V, constat de simulation, script hors dépôt] :
>
> | ρ | DWr | LB1r |
> |---|---|---|
> | −0,6 | 0,324 | 0,491 |
> | −0,3 | 0,155 | 0,237 |
> | +0,3 | 0,159 | 0,077 |
> | +0,6 | 0,332 | 0,146 |
>
> **Motif retenu, cas de retrait (iii) ajouté à la doctrine du § 1.** Un seul test d'autocorrélation d'ordre 1 est désigné par base : Durbin-Watson bilatéral, symétrique et le plus puissant contre l'autocorrélation positive (persistance, cycles de souscription), qui est l'alternative actuarielle plausible. Garder les deux reviendrait à tester deux fois la même H0 (environ 14 % de rejet d'au moins une des deux sous H0 au seuil 0,10). La fiche déclare la perte de puissance contre ρ < 0, chiffres à l'appui. Les commentaires du moteur qui disent « doublon de DWr » sont corrigés. Le tableau avant / après de #303 est inchangé, et σ_USP n'est pas touché.
>
> **Errata qui en découlent** (avis d'`actuary-approfondi` du 19/10 sur les questions de `coder-approfondi`) :
> - **§ 1, § 4.3, § 5.1** : le motif de retrait de LB1r et de LB1 est le cas (iii) ci-dessus, non le cas (i). Les phrases « deux fonctions quasi monotones de ρ̂₁ » et « égalité des puissances à 0,01 près » sont fausses. La revue du bloc 3, § 4.8, porte la même erreur ; elle n'est pas modifiée, mais la fiche du `.tex` ne la cite plus. Box-Pierce (2) contre LB2 n'est pas touché par ce mécanisme (poids relatifs 1 contre 7/6), mais cette proximité reste non mesurée [H].
> - **§ 4.2** : le `detail` propre à la ligne (`detail_r()`, `detail_runsr`) reste tel quel, hors la proposition retirée. Les suffixes qu'`add()` ne pose qu'aux lignes de type test (texte de R1 et effectifs, mention du plancher Monte-Carlo, phrase de #244) disparaissent, conformément au § 1. Sur le jeu de #214 à α = 0,05, Runsr en régime 1 passe ainsi de `inoperant` TRUE à `inoperant` FALSE : c'est un changement de champ, non de verdict (INFO dans les deux cas), et la ligne homologue sur z reste inopérante.
> - **§ 4.2, phrase fixe de R15** (question de l'audit léger de #303, retouche de libellé validée par `actuary-approfondi`) : la phrase est remplacée par `Restituee en diagnostic (regle R15) : aucun verdict ni p-value retenue ; l'hypothese releve de la ligne homologue sur residus standardises, dont le type et le verdict font foi.` Motif : la ligne homologue peut n'avoir aucun verdict. C'est le cas d'un diagnostic par R1 (Runs sur z à T = 5, volumes constants) ou d'un test sans p-value retenue (Monte-Carlo indisponible).
> - **§ 4.2, motif Monte-Carlo d'une ligne R15** : `usp_tests()` pose le motif en tête. La forme dépend de la classe du motif, comme dans `add()`. Pour un motif de dégénérescence, la forme est « <motif> : aucune p-value retenue (ADR 0001). » suivie du complément. Pour les autres motifs, elle est « Monte-Carlo indisponible : <motif>. ».

> **Signalements.**
>
> - **(i) Statut de Rosner (1983).** Le texte de base de la spécification (en-tête, ancien § 7, § 13) le tenait pour « non relu » (Q-Fc-10). Le complément corrige : l'article a été **lu en texte intégral par la session de recherche documentaire du 19/10/2026** (#347), et Q-38-10 est révisée (commentaire `6262306477` de #347). La règle Q-Fc-10 ne s'applique plus à Rosner ; elle s'applique encore à Thompson (1935).
> - **(ii) Relevés non contrôlés sur la source.** `actuary-approfondi` n'a pas pu relire l'article : accès refusé par le proxy (`CONNECT tunnel failed, response 403`). Les citations, pages et tables de #347 n'ont donc **pas été contrôlées sur la source** [NV] ; elles l'ont été par recoupement interne et contre le code. Il reste une **discordance de 0,002 sur les λ de la table 5** (exemple p. 171, n = 54, α = 0,05) : #347 relève 3,157 et 3,149, l'éq. (2.5) donne 3,159 et 3,151. La cause n'est pas établie (interpolation [H], ou erreur de relevé). Ces valeurs ne sont à citer qu'après vérification sur la source (critère É3).
> - **(iii) Acte.** Le mainteneur fournit une copie de l'article dans la session **avant la validation de fin de branche** (étape 8, `actuary` : confrontation de chaque page citée à la source).

> *Rédigé par l'agent actuary (IA)* (fiche `actuary-approfondi`, sans Fable : décision du mainteneur du 19/10/2026), le 19/10/2026, à la demande de la session principale. Lecture seule. Code de référence : `main` `f1689cc`. R18b (PR #345, affichage seul) n'est pas encore fusionnée.
>
> Décisions déjà prises, appliquées ici :
> - **Q-38-1** : Fh = #339, #327, #303, #302, #299, #304, dans cet ordre ; #306 passe en Fk *(#347 ajoutée le 19/10 en septième numéro, circuit 4 : § 7 bis)* ;
> - **Q-Fc-10** : Rosner (1983) n'est pas accessible en texte intégral ; la phrase qui le cite sera datée, sans bloquer la branche *(révisée le 19/10 : Rosner (1983) lu en texte intégral, #347 ; voir l'encadré, § 7 et § 13)* ;
> - **commentaire `6261951079` de #327** : tester le chemin réel de #329 ;
> - **T = 8**.
>
> Contraintes de forme, celles de la fiche Fh :
> - `add()` et `engine_registre_tests()` restent intacts ;
> - `type = "diagnostic"` est posé par `usp_tests()` ;
> - `inoperant` reste réservé à la règle R1 ;
> - l'entrée de `USP_CATALOGUE_MC` part avec sa ligne ;
> - C3⁗ est respecté.
>
> **La spécification respecte toutes ces contraintes. Aucun arrêt vers `architect` n'est requis.**

**Marques** : **[V]** vérifié (source citée, ou commande exécutée et sortie lue) ; **[H]** hypothèse ; **[NV]** non vérifié.

## 0. Objet, sources, mesures

**Sources lues [V].**
- `docs/feuille-de-route.md` (worktree, non commité) : fiche Fh (l. 1938-1978), traits C2⁗ à C10⁗ (l. 2020-2034), Q-Fc-10 (l. 3198).
- Issues #339, #327, #303, #302, #299, #304, avec leurs commentaires (`6251290836`, `6251820925`, `6261951079`, `6239775571`), et #297.
- `CONTEXT.md` : « Diagnostic », « Verdict », « Test inopérant », « Test sans p-value retenue », « Équivalence non démontrable (R14) », « Ligne non applicable », « `inoperant` ».
- `R/engine.R` à `f1689cc` :
  - `usp_regime()` l. 1898-1909 ; `dw_puissance_ar1()` l. 2296-2355 ;
  - `USP_CATALOGUE_MC` l. 3574-3691 ; `engine_registre_tests()`/`add()` l. 4090-4423 ; `usp_jackknife()` l. 4770-4785 ;
  - `usp_tests()` l. 4852-6420 (familles B à G, ratios bruts l. 6081-6278, jackknife l. 6310-6338) ;
  - bloc de robustesse de `run_engine()` l. 11360-11390 ;
  - `mw_tests()` l. 10188-10616 (fonctions partagées, § 8.3).
- `R/display_helpers.R` l. 149-166 (`selection_defaut()` : seules les lignes `variante == "principale"` de base `commun` ou `z` sont affichées par défaut) et l. 2170-2190.
- Revue du 15/10/2026 : `docs/revues/20261015-pertinence-tests-graphiques/bloc-2.md` (§ 4.5, 4.7-4.10), `bloc-3.md` (§ 4.2, 4.5, 4.8, 4.12, 4.14), `bloc-4.md` (§ 4.4, 4.6, errata #313).
- `docs/tableaux/20261018-issue174-esd.md` (C7, mesure versionnée de l'ESD).
- `.tex` : tableaux `tab:nature` (l. 5669), `tab:conv` (l. 6079), `tab:pmin` (l. 6415) ; étiquettes des fiches (§ 10).
- Issue #347 (corps, et commentaire `6262306477` : septième numéro de Fh, circuit 4) *(ajout du complément)*.
- `test_rosner()`, `R/engine.R` l. 3390-3408 *(ajout du complément)*.

**Mesures exécutées [V].** Session cloud Linux, R 4.3.3, `LC_ALL=C.UTF-8`, moteur de `f1689cc`. Scripts de session hors dépôt, non versionnés : `lire_refs.R`, `jack.R`, `chemin329.R`, `dw339.R`, `env299.R`, `env299_mc.R`, `env299b.R` (et `ros.R`, `ros2.R` pour le complément). Durée totale : moins de 2 minutes. Statut de chaque mesure indiqué.

| Mesure | Objet | Résultat |
|---|---|---|
| **(M1)** | `engine_table_tests()` sur les cinq `.rds` lognormaux | Les quatre cas à δ̂ = 1 (`premium`, `premium_net`, `premium_ii6`, `reserve1`) ont des tables **identiques hors famille G** (mêmes x, y à l'échelle près ; x_max/x_min = 1,2949). `premium_interieur` : δ̂ = 0,6640, x_max/x_min = 6, p Monte-Carlo V3b. 51 lignes, 36 lignes à verdict dans chaque cas. Verdicts cités aux § 4 à 7 et 9. |
| **(M2)** | Jackknife, écart entre les deux plus grands Δ_t = \|σ_USP^(−t) − σ_USP\|/σ_USP | `premium` 2,889e-2 (années 8 et 6) ; `premium_net` 3,118e-2 ; `premium_ii6` 2,170e-2 ; `reserve1` 2,999e-2 ; `premium_interieur` 9,691e-2 (années 3 et 4). Jeu de #224 (x de J1, y = 0,7 x, y₅ = 0,8 x₅, σ standard 0,1, barème court) : année 5 non évaluable, sept Δ_t dans [0,036684175243 ; 0,036684175535] (étendue 3,0e-10), écart des deux plus grands **6,6e-12**, `which.max` = 6. |
| **(M3)** | Chemin réel de #329 | Jeu construit : x de J1 ; y_t = 0,7 x_t exp(a s_t), s = (+1, −1, +1, …), a = e^(−11,9925).<br>Échantillon complet : γ̂ = −11,9925 (intérieur, à 0,0075 de la borne −12), KKT satisfaite, accepté.<br>Les 8 réajustements : γ sur la borne, sans KKT, **tous refusés**.<br>`run_engine(B = 99, segment = 1, annexe = "II", nature_donnees = "brutes")` : `ok = TRUE` en 4,6 s ; ligne jackknife `diagnostic`, INFO, `estim` = `NA`, `detail` = phrase fixe de R18a ; `res$jackknife` entièrement `NA` ; pas d'`ecart_jackknife` dans `res$ajustement`.<br>Même issue à γ̂ = −11,995 et −11,990.<br>À a = 1e-5 (γ̂ = −11,513) : 8 réajustements évaluables, minimum −11,528, soit un décalage de −0,0149 en γ au retrait d'une année. |
| **(M4)** | `dw_puissance_ar1()` près de ρ = −1, 1 − \|ρ\| = 10^−k, k = 4 à 10 par demi-décade | Déficit 1 − P régulier, ∝ (1 − \|ρ\|)^(1/2), jusqu'à une rupture (cassure résumée ci-dessous ; table au § 2). |
| **(M5)** | Puissance enveloppe de H2 dans la famille réglementaire (§ 6.2) | Calcul par `.imhof_p_sup0()`, contrôlé par Monte-Carlo (R = 2e5) : J1 0,1279 contre 0,126 par Imhof ; J2 0,3242 contre 0,3242. |
| **(M6)** | F(4, 4) bilatéral, α = 0,10 (`pf`) | Puissance 0,108 au rapport 1,2949 et 0,478 au rapport 6. Recoupe le bloc 2, § 4.10 (0,106 à 1,26). |

Cassure de (M4), par cas :
- T = 8 (α = 0,10 et 0,05) : déficit 1,2e-4 à 1e-8, puis **0 (valeur 1) dès 10^−8,5** ;
- T = 5 (α = 0,10) : 1,8e-4 à 10^−8,5, puis 0 à 1e-9 ;
- T = 9, 12, 15 : 0 dès 1e-8 ;
- T = 10 : **erreur d'intégration à 10^−7,5**, valeur fausse (1,1e-13) à 1e-8 ;
- T = 4 : erreur à 10^−7,5 ;
- T = 20, 30 : 0 dès 10^−8,5 ;
- T = 50 : ≈ 0 dès 1e-9.

Le déficit extrapolé à T = 8, α = 0,10, 10^−8,5, vaut 6,9e-5, contre 6,3e-5 mesuré par Monte-Carlo dans l'audit cité par #339.

Mesures (M2) à (M5) : calculs déterministes, sauf les deux contrôles Monte-Carlo de (M5). Constats sur ces jeux seulement ; ils ne sont pas à citer au dossier sans version tracée (§ 10).

**Accès à la source (complément).** L'auteur de la spécification **n'a pas pu relire l'article lui-même**. Le téléchargement depuis l'archive de Carnegie Mellon a été refusé (WebFetch : échec DNS ; curl : `CONNECT tunnel failed, response 403`). Les relevés de #347 n'ont donc **pas été contrôlés sur la source** [NV]. Ils ont été contrôlés par recoupement interne et contre le code [V], ce qui fait apparaître une discordance non expliquée (exemple de la table 5). Pour que la validation de fin de branche (circuit 4, `actuary`) confronte chaque citation à sa page, il faut que le mainteneur fournisse une copie de l'article dans la session.

**Contrôles de #347 [V].**
- **Formule des λ_i.** Le code transcrit exactement l'éq. (2.5) telle que #347 la relève : `nn = n − i + 1`, `qt(1 − α/(2 nn), nn − 2)`, `(nn − 1) t / sqrt((nn − 2 + t²) nn)`.
  - À T = 8, la formule donne λ₁ = 2,0317 et λ₂ = 1,9381 (α = 0,10), puis 2,1266 et 2,0200 (α = 0,05). C'est conforme à #347 et à C7.0.
  - À n = 25, l + 1 = 10, α = 0,005, elle donne 2,9450, conforme au « cas limite » cité par #347.
- **Règle k̂.** `max(c(0, which(R > lam)))` est bien la règle du plus grand indice dépassant son seuil (éq. (1.2) selon #347), et non un arrêt au premier non-rejet. k par défaut = max(1, ⌊n/4⌋) = 2 à T = 8.
- **Arithmétique de #347.**
  - Rapports tirés de la table 1 à k = 1 ou 2 : de 1,0 à 1,4 fois α.
  - Erreur Monte-Carlo √(0,05 × 0,95/2000) = 0,0049.
  - Pour n = 10, α = 0,05 : λ₁ = 2,290 et 2λ₁² = 10,49 > 9. L'étape 1 y est donc exactement de niveau α par l'argument du document, et le 0,06 de la table 1 est compatible avec cette exactitude à environ deux erreurs Monte-Carlo, comme le dit #347.
- **Discordance non expliquée** (exemple p. 171, table 5, n = 54, α = 0,05).
  - #347 relève λ₁ = 3,157 et λ₂ = 3,149 ; l'éq. (2.5) donne **3,159 et 3,151**.
  - L'écart de 0,002 ne remet pas en cause le code, qui calcule par (2.5). Il peut venir d'une interpolation entre n = 50 et 60 de la table 3 [H], ou d'une erreur de relevé.
  - Conséquence : ne citer ces valeurs qu'après vérification sur la source (critère É3 ci-dessous).

**Mesure (M7) [V, constat de simulation].** Script `ros2.R`, hors dépôt, non versionné ; 2e5 échantillons i.i.d. N(0, 1) de taille 8 ; graine 20261019 sous `engine_sous_graine()` ; erreur Monte-Carlo environ 5e-4.
- Les λ de (2.5) reproduisent C7.a :
  - à α = 0,10 : P(k̂ ≥ 1) = 0,1501 et P(R₂ > λ₂) = 0,0601 ;
  - à α = 0,05 : 0,0755 et 0,0278.
- **Calibration selon (1.3)** à T = 8, k = 2.
  - λ₂ est fixé par la condition sous H₁. Selon (2.5), il est déjà exact pour n = 7 (2λ₂² = 7,51 > 6) ; ce point vient de l'argument du document, il n'est pas de Rosner.
  - λ₁ est alors relevé pour que P(k̂ ≥ 1 | H₀) = α :
    - **λ₁ calibré = 2,1405** à α = 0,10, et la première étape seule tombe à 0,0446 ;
    - **λ₁ calibré = 2,2073** à α = 0,05, première étape seule 0,0235.
  - Dans les deux cas, P(k̂ = 2 | H₀) reste à 0,060 et 0,028 : l'étape « deux valeurs aberrantes » consomme **plus de la moitié** du niveau.

## 1. Doctrine commune de Fh

**Règle de restitution (D1-Fh).** Une ligne de `type = "test"` qui n'apporte pas de preuve propre à T = 8 suit l'un de deux sorts.
- **(i) Retrait**, avec son entrée de catalogue, si elle porte la **même information** qu'une ligne conservée. C'est le cas d'une statistique fonction quasi monotone d'une statistique conservée, sur la même base.
- **(ii) Diagnostic** si sa statistique est distincte mais **dominée**, ou mal rattachée à l'hypothèse. Le diagnostic est posé « par décision » quand le motif ne dépend pas des données (précédent : les lignes M5, #245), « par règle » quand il en dépend (précédents : R1, R3, R14).

Dans les deux cas, les p-values calculées restent dans leurs colonnes. `add()` pose seule `p_retenue`, `nature_p` et `sens` à `NA`, et le verdict à INFO.

**Ce que la règle ne fait pas.** Une puissance faible ôte sa valeur de preuve à un `OK`, mais **pas** à un rejet dont le niveau est contrôlé. R1 et R14 ne basculent une ligne que lorsqu'un verdict est **certain** : ECHEC inatteignable, ou équivalence indémontrable. Ce n'est pas le cas d'un test calibré de faible puissance. Ce principe commande le § 6.3.

**Forme imposée.**
- `type = "diagnostic"` est passé à `add()` par `usp_tests()`. `add()` reste inchangée ; `inoperant` vaut FALSE ; la règle R1 ne s'applique plus, faute de `type = "test"`.
- **Priorité.** Les motifs « non applicable » (R13, R12, pertes constantes, partition de Smirnov, statistique non définie, Runsr d'un seul côté de la médiane) priment sur tout diagnostic de Fh.
- Aucun champ `variante` n'est modifié : la sélection par défaut de l'affichage reste inchangée, et Fh ne touche pas l'affichage (C3⁗).
- Le `detail` porte une phrase fixe ASCII, sans aucun nombre issu du bootstrap (#76). Il peut porter des nombres déterministes des données ou des paramètres, comme R14 ou Smirnov.
- L'invariant I5 (« la liste des lignes ne dépend pas du régime ») est conservé : les retraits sont inconditionnels. Le décompte passe de **51 à 47 lignes à T = 8** (§ 9).

**Avis par ligne touchée** (ce qu'elle teste ; p-value ; validité à T = 8 ; puissance ; verdict d'actuary) :

| Ligne | Hypothèse (annexe XVII), base | p retenue aujourd'hui, validité à T = 8 | Puissance plausible à T = 8 | Avis |
|---|---|---|---|---|
| DWr, Runsr, supFr, CUSUMr, Grubbsr à π̂ constant | (iv), stabilité ; u_t | MC (Runsr : exacte), calibrées | celle de l'homologue sur z : même information à la transformation log près | **à remplacer** (diagnostic, § 4) |
| LB1r | (iv) ; u_t | MC | ≈ DWr (même ρ̂₁) [H sur u, mesuré sur z] | **à remplacer** (retrait) |
| SW à loi nulle simulée | (iii) ; z | « exacte » simulée à π̂ constant, non applicable sinon | même W que la ligne principale | **à remplacer** (retrait) |
| Box-Pierce (2) | (iv) ; z | MC | ≈ LB2 (mêmes ρ̂₁, ρ̂₂, poids voisins) | **à remplacer** (retrait) |
| LB1 (z) | (iv) ; z | MC | ≈ DW à 0,01 près (#229, #116, bloc 3 § 4.8) | **à remplacer** (retrait) |
| KS contre N(0,1) | (iii) ; z | MC (Kolmogorov invalide, paramètres estimés) | la plus faible de H3 dans toutes les alternatives mesurées (bloc 3 § 4.5) | **fragile** → diagnostic |
| Cramér-von Mises | (iii) ; z | MC | corrélation 0,98 avec AD, légèrement dominée | **fragile** → diagnostic |
| BP 1979, White, GQ, BF | (ii) ; z | MC | 0,07-0,38 sur J1, 0,11-0,30 sur J2 ; même SCE que Koenker (BP79) | **fragile** → diagnostic |
| Smirnov | (ii) de nom, position de fait ; z | exacte à π̂ constant, MC sinon | 0,04-0,05 contre σ × 2 ou × 3 | **à remplacer** → diagnostic |
| Spearman ratio-temps | (i) ; r | exacte à π̂ constant | corrélation 0,982 avec MK sur les 8! ordres, jamais de verdicts opposés | **fragile** → diagnostic |
| BP Koenker | (ii) ; z | MC calibrée (niveau 0,0955 / 0,085) | 0,09-0,24 sur J1 ; enveloppe de la famille 0,13 (J1) et 0,34 (J2) (§ 6.2) | **pertinent, à compléter** (seule ligne H2 à verdict) |
| ESD | (iii)/(iv), aberrants ; z | aucune p ; niveau réel 0,1506 à α = 0,10 (C7.a) | — | **à remplacer** → diagnostic (§ 7) |

## 2. #339 : `dw_puissance_ar1()` près de ρ = −1

- **Ce que fait la fonction.** C'est un outil de mesure : `run_engine()` ne l'appelle pas. Elle approche numériquement (Imhof, `uniroot()`) une quantité exacte : la puissance du test bilatéral exact de Durbin-Watson contre un AR(1) gaussien.
- **Intérêt du domaine 1 − |ρ| < 1e-8 en ρ < 0 à T = 8 : aucun.** Un AR(1) à ρ < −0,99999999 n'est pas une alternative plausible pour des sinistres annuels, et le `.tex` n'emploie que ρ ∈ [−0,5 ; 0,9].
- **Option retenue : 1** (garde explicite), au seuil **1 − |ρ| ≥ 1e-6** pour ρ < 0, uniforme en T. L'option 2 n'apporte rien au dossier ; l'option 3 laisse rendre une valeur fausse sans erreur.
- **Justification du seuil [V], (M4).** La défaillance (valeur 1, ou erreur d'intégration) apparaît, selon T, entre 10^−9 et 10^−7,5 ; le cas le plus précoce mesuré est l'erreur de T = 10 et T = 4 à 10^−7,5. Le seuil 1e-7 proposé par l'issue n'en laisse qu'une demi-décade ; 1e-6 en laisse une décade et demie. En deçà de la cassure, le déficit suit une loi régulière ∝ (1 − |ρ|)^(1/2) et recoupe le Monte-Carlo de l'audit. C'est un contrôle de cohérence, pas une preuve de justesse.
- **Seuil dépendant de T** (commentaire `6251290836`) : il ne sert plus à la garde. Le commentaire du moteur cite les ruptures mesurées, résumées au § 0 (M4).
- **Domaine de validité énoncé** (commentaire du moteur et index du `.tex`, l. 688) :
  - T entier, 4 ≤ T ≤ `.Machine$integer.max` ; −1 + 1e-6 ≤ ρ ≤ 1 − 1e-10 ; 0 < α < 1 ;
  - précision mesurée au voisinage de ρ = −1 pour T ∈ {4, …, 10, 12, 15, 20, 30, 50, 100} à α = 0,10, et pour T ∈ {5, 8, 12, 20, 30} à α = 0,05 (mesure du 19/10/2026, non versionnée) ;
  - grille de 88 points de #170 (T ∈ {5, 8, 12, 20}, ρ de −0,99 à 0,99) ;
  - hors de ces T : non mesurée.
- **Constat accessoire.** À T = 4 (α = 0,10) et T = 5 (α = 0,05), la puissance tend vers 0 quand ρ → −1, sans signature de défaillance. C'est cohérent avec un vecteur alterné centré de longueur impaire ou très courte [H] ; à dire dans le domaine, sans conséquence.

**Critères d'acceptation (étape 1).**
- (a) `dw_puissance_ar1(8, -1 + 1e-7, 0.10)` lève l'erreur « rho doit verifier -1 + 1e-6 <= rho <= 1 - 1e-10 (domaine de precision numerique) ».
- (b) `dw_puissance_ar1(8, -1 + 1e-6, 0.10)` rend une valeur finie dans ]0 ; 1[ ; 1 − valeur ≈ 1,2e-3.
- (c) La grille de 88 points est `identical()` avant et après.
- (d) Garde positive inchangée.
- (e) Le commentaire l. ~2330-2334 donne le domaine et les ruptures par T.

Références : identiques (aucun chemin de `run_engine()`). Circuit 3, `coder`.

## 3. #327 : année la plus influente du jackknife (et chemin réel de #329)

**3.1 Nature.** C'est un défaut **numérique**, non statistique.
- Sur le jeu de #224, les sept années évaluables ont des influences **égales en droit** : à δ̂ = 1, σ ne dépend que de l'ensemble des ratios, identique pour tout retrait d'une année t ≠ 5.
- Les Δ_t ne diffèrent que du bruit d'optimiseur (étendue 3,0e-10, (M2)).
- La tolérance se rapporte donc à la précision certifiée de σ, non à un argument statistique. **Circuit 3, `coder`** ; `coder-approfondi` n'est pas requis selon la règle du plan.

**3.2 Tolérance.** On désigne une seule année si et seulement si Δ(1) − Δ(2) > τ, avec

  τ = 2 · `REP_SIGMA_KKT` · (2 + Δ(1) + Δ(2)).

- **Fondement [V, propagation au premier ordre].** σ_USP est linéaire en σ, de coefficient ≤ σ_USP/σ. Une erreur relative ε ≤ `REP_SIGMA_KKT` sur chaque σ donne |δΔ_t| ≤ (1 + Δ_t)(ε_t + ε_0). La différence de deux Δ_t est donc connue à 2 · `REP_SIGMA_KKT` · (2 + Δ(1) + Δ(2)) près.
- Aucune constante nouvelle ; ancrage sur M9 par `REP_SIGMA_KKT`.
- **Limite [H].** La précision n'est certifiée que pour un réajustement qui satisfait KKT. Un réajustement accepté sans KKT (γ intérieur) n'a pas de précision garantie : la tolérance y est une convention.
- **Alternative** (Q-D1-Fh-2) : constante fixe 1e-5, qui couvre la borne tant que Δ(1) + Δ(2) ≤ 3.
- Ne pas employer le mot « ex aequo » : `CONTEXT.md` en réserve la seule définition à `TOL_EX_AEQUO`, et 1e-12 ne couvre pas ce cas (5e-10 en relatif).

**3.3 Comportement.**
- `run_engine()` calcule, sur les années évaluables :
  - `jack_annees <- which(Δ ≥ Δ(1) − τ)` (au moins un élément) ;
  - `jack_annee` reste celle de `which.max` quand `length(jack_annees) == 1` ;
  - avec une seule année évaluable : pas de τ, désignation directe.
- `robustesse` n'est pas stocké (C-Fc-1 conservé).
- `detail` de la ligne jackknife, phrase précédant celle des années non évaluables :
  - une année : inchangé, octet pour octet (« Annee la plus influente : 8 (sigma_USP en baisse). ») ;
  - plusieurs : `Annees les plus influentes, d'influence egale a la precision numerique pres : 1, 2, 3, 4, 6, 7 et 8 (sigma_USP en baisse).` Années jointes comme `txt_ne` (« , » puis « et ») ;
  - signe : « en baisse » ou « en hausse » s'il est commun aux années citées, sinon « (sigma_USP en hausse ou en baisse selon l'annee) ».
- Seuls des entiers sont imprimés (#76).
- *Erratum du 19/10/2026 (avis d'`actuary`, à la demande de la session principale, sur une question de l'audit léger de #327).*
  - Sur le jeu de #224, le sens est « en hausse » (et non « en baisse »). Il a été mesuré dans les deux configurations : segment 1, annexe II (Δ_t ≈ 0,02063, configuration du test et de la phrase attendue) et σ standard 0,1, barème court (Δ_t ≈ 0,03668, configuration de (M2)).
  - Signe commun nul : « (sigma_USP inchange) », valeur reprise de la phrase singulière. Ensemble de signes non uniforme qui contient 0 : « (sens de la variation de sigma_USP selon l'annee) ». La phrase « (sigma_USP en hausse ou en baisse selon l'annee) » est réservée au mélange {−, +}.
  - Réserve pour la fiche du `.tex` (`docwriter`) : τ est certifiée pour un réajustement qui satisfait KKT. Si un réajustement est accepté sans KKT (γ intérieur), les années citées restent indiscernables, mais la liste peut être incomplète.
- **Stabilité [H].** L'ensemble des années citées ne change entre plateformes que si un écart vaut τ au bruit près ; τ (≈ 4e-6) dépasse de quatre ordres le bruit mesuré (≤ 3e-10).

**3.4 Chemin réel de #329 (S-Fh-5 (c)).**
- **Un jeu existe** [V, (M3)]. Il est construit, non réaliste : ratios égaux à 6e-6 près.
- Mécanisme, démontré pour la variance MCO :
  - Σ_i SC_(−i) = (T − 2)/(T − 1) · T · SC/T ;
  - avec des écarts de même module (configuration ±a), chaque retrait réduit la variance du maximum de vraisemblance du même facteur ;
  - un γ̂ complet placé juste au-dessus de la borne bascule donc sur la borne pour **tous** les retraits.
- Marges : 0,0075 en γ des deux côtés, très au-dessus du bruit (`TOL_DELTA_BORD` = 1e-6). Stabilité entre plateformes non mesurée [H].
- **Test ordinaire** à ajouter (`test_defauts_connus.R`, ou fichier des contrôles du jackknife) :
  - jeu : x de J1, `y <- 0.7 * x * exp(exp(-11.9925) * rep(c(1, -1), 4))`, B = 99, segment 1, annexe II, `nature_donnees = "brutes"` ;
  - attendus : `ok`, ligne jackknife `type = "diagnostic"`, `estim` `NA`, `detail` identique à la phrase de R18a, 8 lignes `NA` dans `res$jackknife`, absence d'`ecart_jackknife`.
- Le test par substitution d'`usp_jackknife()` est conservé, comme garde du cas « tous en échec ».

**3.5 Critères d'acceptation (étape 2).**
- (a) Jeu de #224 : `detail` contenant « Annees les plus influentes, d'influence egale a la precision numerique pres : 1, 2, 3, 4, 6, 7 et 8 » et « Annee 5 non evaluable » ; pas de « Annee la plus influente : 6 ».
- (b) Les cinq cas : `comparer_references.R --seuil 0` sans écart (écarts de 2,2e-2 à 9,7e-2, contre τ ≈ 4e-6).
- (c) Test du chemin réel, § 3.4.
- (d) Cas synthétique de deux années à Δ distincts de 1e-3 : une seule année désignée.

## 4. #303 : lignes sur ratios bruts à π̂ constant ; retrait de Ljung-Box (1) sur ratios bruts

**4.1 (a) Drapeau : `regime$pi_constant`**, bande `TOL_DELTA_BORD` comprise.
- Dans la bande, z et la transformée logarithmique de u ne diffèrent qu'à l'ordre (1 − δ) ≤ 1e-6 : l'argument de doublon vaut à cet ordre.
- Le motif « CONTROLE SANS OBJET ICI » est déjà posé sous ce drapeau (`note_r`, `detail_runsr`, y compris dans les sous-cas de signes différents).
- La règle R7 attribue déjà les p exactes dans la bande.
- `pi_constant_exact` laisserait des lignes de test dont le `detail` dit « sans objet » : incohérence.
- `usp_regime()` n'est pas modifiée (#331 reste en Fk).

**4.2 (b) Restitution.** À `pi_constant` vrai, DWr, Runsr, supFr, CUSUMr et Grubbsr passent en `type = "diagnostic"`. C'est un **diagnostic par règle**, règle nouvelle proposée **R15** ; le numéro est à fixer par `architect`.
- Une ligne Runsr non applicable (un seul côté de la médiane) le reste.
- p-values (p_mc ; p exacte de Runsr) conservées dans leurs colonnes, non retenues.
- `detail` : le motif actuel reste tel quel, suivi de la phrase fixe `Restituee en diagnostic (regle R15) : aucun verdict ni p-value retenue ; la ligne homologue sur residus standardises porte le verdict.`
- Dans `detail_runsr` (régime 1), la proposition « la p-value retenue, s'il en est une, est nommee par nature_p » est retirée des branches à π̂ constant.
- Règle #76 respectée. À π̂ variable, rien ne change.
- Constat [V, (M1)] : sur J1, Grubbs (z) désigne l'année 6 et Grubbsr l'année 8 (p 0,861 contre 0,777), parce que la transformation log change le côté de l'écart extrême. Ce n'est pas une information sur le modèle : sous le modèle à π̂ constant, l'échelle log est celle où les r_t sont i.i.d. normaux.

**4.3 (c) Retrait de LB1r dans tous les régimes : oui**, ligne et entrée `LB1r`.
- Q = T(T + 2)ρ̂₁²/(T − 1) et DW ≈ 2(1 − ρ̂₁) − (u₁² + u_T²)/Σu² sont deux fonctions quasi monotones de ρ̂₁.
- DWr, bilatéral et calibré par Monte-Carlo, couvre la même alternative d'ordre 1.
- L'égalité des puissances à 0,01 près est mesurée sur z (#229, #116 ; bloc 3, § 4.8, non remesurée ici). Sur u à π̂ variable, elle n'est pas mesurée [H].
- Le commentaire « ces six lignes » devient « cinq ».

**4.4 (d) Verdicts prévisionnels** (visa du mainteneur) :
- quatre cas à δ̂ = 1 : DWr, Runsr, supFr, CUSUMr, Grubbsr **OK → INFO** ; LB1r **OK → retirée** ;
- `premium_interieur` : LB1r **OK → retirée** ; les cinq autres inchangées.
- `p_retenue` des cinq lignes : valeur → `NA` sur les quatre cas. Aucune autre p-value ; σ_USP inchangé.

**4.5 Critères d'acceptation (étape 3).**
- (a) Tableau avant / après.
- (b) `comparer_references.R` : chemins communs identiques ; seuls diffèrent les cinq lignes et l'entrée `LB1r` retirée (bootstrap : vecteurs par statistique). L'indépendance des autres statistiques vis-à-vis de la liste du catalogue est [H], prouvée par cette comparaison.
- (c) Mêmes lignes en test à π̂ variable (jeu J2).
- (d) Mise à jour, au même commit, des références à `LB1r` : `tests/unitaires/test_lois_exactes.R` l. 443, `tests/calibration_mc_t8.R` l. 440, `tests/p_conditionnelle_regime_t8.R` l. 777, et toute autre relevée par `git grep`.
- (e) Régénération structurelle des cinq cas, par la CI.

## 5. #302 : batterie H3/H4

**5.1 (a) Sort de chaque ligne** (recommandations ; Q-D1-Fh-4) :

| Ligne | Sort recommandé | Raison | Alternative |
|---|---|---|---|
| Shapiro-Wilk à loi nulle simulée | **retrait** | même W que la ligne principale ; son apport, valider l'approximation de Royston, est acquis par C4 et documenté. `sw_p_loi_nulle()` reste appelée par `mw_tests()` (l. 10527) : aucune fonction morte, `SEED_LOI_NULLE_SW` et la métadonnée restent | diagnostic |
| Box-Pierce (2) | **retrait** (+ entrée `BP2`) | mêmes ρ̂₁, ρ̂₂ que LB2, poids voisins ; la documentation l'écrit dominé | — |
| Ljung-Box (1) sur z | **retrait** (+ entrée `LB1`) | même raison que LB1r (§ 4.3) ; traitement identique sur les deux bases | diagnostic |
| KS contre N(0,1) | **diagnostic par décision** | statistique la plus faible de H3 ; sa ligne porte le constat tracé « 0 rejet sur 3 000 à 5 % », contrôlé par `tests/constats_puissance_t8.R` (C2, l. 815-825), qui lit la ligne de `run_engine()`. Le retrait casserait ce contrôle | retrait (contrôle C2 et fiche à reprendre) |
| Cramér-von Mises | **diagnostic par décision** | statistique distincte (pondération uniforme de la fonction de répartition empirique), corrélée à 0,98 avec AD qui la domine ; garde `stat_cvm()` et `cvm_p_stephens()` et leurs tests externes | retrait |

- **Phrases fixes.**
  - KS : `Restituee en diagnostic par decision (issue #302) : la statistique D est testee par la ligne Lilliefors ; aucun verdict.`
  - CvM : `Restituee en diagnostic par decision (issue #302) : statistique tres correlee a celle d'Anderson-Darling, qui porte le verdict ; aucun verdict.`
- **Terme « variante sans verdict » : à ne pas créer.** Une ligne sans verdict est un diagnostic (ADR 0001) ; `variante` est un champ de sélection de l'affichage, que Fh ne modifie pas. Terme employé : **« diagnostic par décision »**, qui existe dans `CONTEXT.md` (précédent #245). Consignation par `architect`.

**5.2 (b) Lecture conjointe de H3 : renvoyée à #297** (Fk), comme le propose `architect`. Fh fixe la liste des lignes à verdict (§ 8.1). #297 calcule son minP sur les seules lignes `type == "test"` de l'état final ; son exclusion « variantes secondaires, CONTROLE SANS OBJET » devient automatique.

**5.3 (c) p non simulées de H3 à π̂ variable.**
- **Phrase de `detail`, sans changement de type.** La ligne a une p Monte-Carlo calibrée sous le modèle, seule retenue. « Non applicable » supprimerait un test valide.
- À `pi_constant` faux, sur SW, SF, AD, Lilliefors, JB et D'Agostino (et KS, CvM devenus diagnostics), phrase jointe par `.engine_joindre()` : `p non simulee etablie pour un echantillon i.i.d. normal, que z = P epsilon ne verifie pas a pi_t variable : restituee pour information, jamais retenue.`
- **Anscombe-Glynn (constat nouveau).** La ligne n'a pas de p Monte-Carlo : à T ≥ 20 et π̂ variable, sa p d'approximation sous i.i.d. normal est **retenue et porte un verdict** sans justification. Elle devient **non applicable** à π̂ variable, comme Shapiro-Wilk à loi nulle simulée (extension de la règle R9 amendée). Motif : `approximation a n fini etablie pour un echantillon i.i.d. normal, sans objet a pi_t variable (z = P epsilon non i.i.d.) ; aucune p-value de Monte-Carlo prevue : test non applicable`. Aucun cas de référence n'est touché (T = 8 < 20).
- La mesure d'`actuary` du 17/10 sur Shapiro-Francia (0,1008 et 0,0819) reste hors dépôt : à ne pas citer.

**5.4 (d) Fonctions.** Aucune n'est supprimée.
- `.shapiro_sur()`, `stat_lilliefors()`, `stat_dw()` et `sw_p_loi_nulle()` ne sont pas modifiées.
- LB1 et BP2 sont calculées en ligne (`stats::Box.test`) : leurs fermetures partent avec les entrées.

**5.5 Verdicts prévisionnels** (visa) :
- quatre cas à δ̂ = 1 : SW à loi nulle simulée **OK → retirée** ; BP2 **OK → retirée** ; LB1 **OK → retirée** ; KS et CvM **OK → INFO** ;
- `premium_interieur` : SW à loi nulle simulée **INFO (non applicable) → retirée** ; BP2 et LB1 **OK → retirées** ; KS et CvM **OK → INFO** ; phrase du § 5.3 sur les lignes H3.

**Critères d'acceptation (étape 4).**
- (a) Tableau avant / après.
- (b) `comparer_references.R` : chemins communs identiques.
- (c) Aucune fonction appelée par `mw_tests()` modifiée (`git diff` sur ces fonctions vide).
- (d) Anscombe-Glynn non applicable à π̂ variable et T ≥ 20 (jeu J2 étendu, test unitaire).
- (e) Mise à jour des noms `LB1`, `BP2` dans `tests/grille_regime_t8.R` l. 350, `tests/p_conditionnelle_regime_t8.R` l. 719 et 772, `tests/calibration_mc_t8.R` l. 435, et des tests unitaires relevés par `git grep`.
- (f) Régénération structurelle.

## 6. #299 : H2 à faible dispersion des volumes ; lignes H1/H2 à verdict

**6.1 Lignes rendues diagnostics par décision, dans tous les régimes.** R13 et les gardes de non-applicabilité gardent la priorité.
- BP 1979, White, Goldfeld-Quandt, Brown-Forsythe : `Restituee en diagnostic par decision (issue #299) : la structure de variance est testee par la seule ligne Breusch-Pagan studentise (Koenker) ; aucun verdict.`
- **Smirnov** : diagnostic, famille `C.` inchangée (aucun déplacement de ligne) : `Restituee en diagnostic par decision (issue #299) : compare la position de z entre petits et gros volumes, alternative de H1 plutot que de H2 ; aucun verdict.` Alternative : rattachement à `B.` (préfixe existant) ; je ne la recommande pas, la ligne Spearman ratio / volume dominant l'alternative monotone de H1.
- **Spearman ratio-temps** : `Restituee en diagnostic par decision (issue #299) : meme alternative (tendance monotone du ratio) que la ligne Mann-Kendall, qui porte le verdict ; aucun verdict.`

**6.2 Forme du « seuil » : puissance enveloppe exacte, fonction de x et de α seulement.**
- La forme LR observé aux deux bornes de δ est **écartée** : elle dépend de y, donc conditionne la restitution par le résultat même qu'elle qualifie.
- Le rapport x_max/x_min borne le contraste de variance de la famille [V, algèbre] :
  - Var(ln Y_t) = ln(1 + c a_t), a_t = δ + (1 − δ) x̄/x_t, c = e^(2γ) ;
  - a_max/a_min ≤ x_max/x_min et ln(1 + ca)/ln(1 + cb) ≤ a/b pour a > b.
- Mais la puissance dépend de toute la configuration de x. Le seuil pourrait être lu sur R_x = x_max/x_min (plan à deux niveaux, le plus favorable des trois plans mesurés) ; je recommande plutôt de calculer directement la grandeur suivante.
- **Grandeur.** Puissance π_env du **test le plus puissant invariant** (translations de ln y le long de 1, changements d'échelle) entre H0 : Var ∝ 1 (δ = 1) et H1 : Var ∝ x̄/x_t (δ = 0), dans la limite c → 0. On prend le maximum des deux sens.
- **Calcul exact** (approximation numérique d'une quantité exacte) :
  - H, base orthonormée du complément de 1 ; A_i = H′Σ_iH ;
  - Q_k = w′(A₁⁻¹ − kA₀⁻¹)w ;
  - k tel que P_{A₁}(Q_k > 0) = α, puis π_env = P_{A₀}(Q_k > 0), par `.imhof_p_sup0()`, appelée sans modification.
- **Fondement.** Lemme de Neyman-Pearson appliqué à l'invariant maximal (direction de H′e, loi gaussienne centrale angulaire) : dérivation faite ici et contrôlée par Monte-Carlo, (M5). Cadre : Lehmann et Romano (2005), ch. 6, § 6.3 (table des matières vérifiée, contenu non relu).
- **Valeurs [V]** :
  - J1 : π_env = **0,127** (α = 0,10), 0,066 (α = 0,05) ;
  - J2 : **0,343** et 0,223 ;
  - la limite c → 0 est la plus favorable sur J2 (0,324 à c → 0, puis 0,320 à c = 0,021, 0,293, 0,237 et 0,169 à c = 7,4).
- **Ce n'est pas une puissance a posteriori** : aucun paramètre estimé. La critique de Hoenig et Heisey (2001), qui a fait retirer R4, ne s'y applique pas.
- **Hypothèses [H].**
  - Les tests H2 du moteur ne sont invariants sous ce groupe que dans la limite des faibles CV.
  - Le terme de moyenne −½ ln(1 + c a_t) est négligé.
  - La décroissance en c n'est mesurée que sur J2.
  - Hors famille (variance ∝ x^k raide), la puissance des tests H2 peut dépasser π_env : π_env borne la détection d'un écart **dans** la famille réglementaire.

**6.3 Statut de Breusch-Pagan Koenker, et lieu du seuil.**

**(A) recommandée — pas de bascule.** BP Koenker reste un test. Son `detail` porte une phrase dont le nombre est déterministe, calculé à l'α du calcul :

`Puissance maximale, au seuil alpha = %g, d'un test invariant de delta = 1 contre delta = 0 (ecart le plus grand de la famille de l'annexe XVII, limite des faibles coefficients de variation) : %.2f avec ces volumes ; un OK ne demontre pas la structure de variance.`

- Raison : un rejet calibré au niveau α garde sa valeur de preuve quelle que soit la puissance (§ 1). R14 et R1 ne basculent qu'un verdict certain.
- Fonction nouvelle, propre à la branche lognormale : nom proposé `usp_puissance_enveloppe_h2(x, alpha)`, appelée par `usp_tests()` ; non calculée à volumes constants (ligne non applicable par R13).
- Aucun seuil, aucune constante nouvelle.

**(B) — bascule.** Si π_env < π*, BP Koenker passe aussi en diagnostic **par règle** (R16 proposée). Valeur de π* au choix du mainteneur ; c'est une convention de restitution sans source.
- π* = 2α : J1 bascule, J2 reste un test. Équivalent R_x ≈ 1,78 (deux niveaux) ; 2,42 (géométrique) ; 2,33 (linéaire).
- π* = 0,5 : bascule dans tous les cas de référence. R_x ≈ 4,99 ; 13,2 ; 11,5.

**(d) Lieu, sous (A) comme sous (B) : `usp_tests()`.** Le prédicat dépend de α, ce que `usp_regime(delta, x)` ne reçoit pas. `usp_regime()` n'est pas modifiée : **#331 reste en Fk**, et l'alternative de Q-Ff-10 ne se déclenche pas.

**6.4 (e) Verdicts prévisionnels** (visa) :
- quatre cas à δ̂ = 1 :
  - BP 1979 et White **ALERTE → INFO** ;
  - GQ, BF, Smirnov, Spearman ratio-temps **OK → INFO** ;
  - BP Koenker **ECHEC inchangé** sous (A), phrase avec 0,13 ; **ECHEC → INFO** sous (B) ;
- `premium_interieur` :
  - GQ **ECHEC → INFO** ;
  - BP 1979, White, BF, Smirnov, Spearman ratio-temps **OK → INFO** ;
  - BP Koenker OK inchangé, phrase avec 0,34 (sous (B), π* = 0,5 : OK → INFO).
- σ_USP inchangé [V : `usp_parametre()` et `candidats` ne lisent aucun test].

**Critères d'acceptation (étape 5).**
- (a) Tableau avant / après.
- (b) Test unitaire de la fonction nouvelle :
  - J1 → 0,127 et J2 → 0,343 à 1e-3 près (α = 0,10) ;
  - invariance par x → λx ;
  - π_env ≥ α ;
  - croissance sur les plans à deux niveaux de R_x = 1,1 à 30 ;
  - contrôle Monte-Carlo hors CI (R = 2e5) consigné dans le commit.
- (c) Priorité des motifs non applicables conservée (volumes constants, White à moins de trois volumes distincts, partition de Smirnov).
- (d) Seuil, sous (B), cité dans le commentaire avec sa justification.
- (e) Régénération (`p_retenue` → `NA` est une valeur numérique).

## 7. #304 : procédure ESD lognormale *(texte du complément, qui remplace celui de la spécification de base)*

**7.1 Ce que dit la source**, d'après #347 (non relu par l'auteur de la spécification : accès refusé, § 0).
- **Cadre** : échantillon dont le corps est normal (p. 165) ; aucun emploi sur des résidus.
- **Valeurs critiques.** Ce sont des « approximate percentiles », obtenus par la conjecture (2.1) et la borne de Bonferroni (2.3). Aucune exactitude n'est affirmée, même à l'étape 1.
- **Domaine** : jugé adéquat à partir de n = 25 (résumé p. 165, p. 167, p. 171). Niveau réel jusqu'à 2 à 2,5 fois α pour n ≤ 15 aux k élevés (p. 167).
- **Simulations** : seulement pour n ≥ 10 ; table 1 à α = 0,05, 2 000 itérations.
- **Petits n.** Rosner suggère des simulations Monte-Carlo « to estimate the exact percentiles » (p. 171).
- **Aucune p-value n'est définie.**
- **Conclusion : l'article ne permet aucune conclusion chiffrée à T = 8.** Seule la mesure C7 du dépôt (versionnée) en donne une.

**7.2 Niveau à T = 8.**
- [V, C7.a et (M7)] : P(k̂ ≥ 1) = 0,1506 à α = 0,10 et 0,0752 à 0,05.
- Inégalité stricte P(k̂ ≥ 1) > α à ces deux α. Elle vient de la **démonstration du document**, non de Rosner (écart 4 de #347) : la première étape est exacte grâce à la loi d'un écart studentisé et à la disjonction quand 2λ₁² > T − 1, et la seconde étape a une probabilité positive.

**7.3 Options.**

- **(a) Diagnostic par décision, pour tout T : recommandée.**
  - Rien dans la source ne s'y oppose : Rosner écarte lui-même son approximation en deçà de n = 25 (p. 171).
  - Grubbs (p Monte-Carlo calibrée) couvre l'alternative à une valeur aberrante.
  - Le gain de l'ESD contre le masquage, à T = 8 et deux valeurs aberrantes sur huit, n'est ni mesuré ni établi par la source.
  - `estim` = k̂ ; rangs dans le `detail`. `test_rosner()` est inchangée.
  - Phrase **modifiée** par rapport à D1-Fh :

    `procedure ESD de Rosner (1983) a niveau nominal alpha = %.2f, sans p-value%s. Restituee en diagnostic par decision (issue #304) : valeurs critiques approchees, jugees adequates par l'auteur a partir de n = 25 ; a T = 8, niveau superieur a alpha (voir la fiche) ; une valeur aberrante isolee est testee par la ligne Grubbs.`

- **(b) p Monte-Carlo sur k̂ : déconseillée.**
  - C'est une construction du projet : la source ne définit pas de p-value.
  - k̂ dépend de α, que `usp_bootstrap()` ne reçoit pas : le contrat changerait, hors du périmètre de Fh.
  - **Plancher.** p_min_mc = P*(k̂* = 2) : environ 0,059 (J1) et 0,055 (J2) à α = 0,10 ; 0,027 et 0,0245 à α = 0,05 (C7.b ; la valeur exacte dépend de B).
    - À α = 0,10, l'ECHEC est inatteignable (plancher ≥ α/2) et la ligne n'est **pas** inopérante (plancher < α).
    - À α = 0,05, l'ECHEC n'est atteignable de justesse qu'au voisinage de J2.
  - Résultat : une ligne OK ou ALERTE, redondante avec Grubbs.
  - L'affirmation de #304 selon laquelle « R1 rendrait la ligne inopérante à k̂ = 1 » est **inexacte** : la règle R1 lit le plancher, non la p observée.

- **(c) Variante de #347 : calibrer les λ_i à T = 8 par Monte-Carlo sous H₀**, à soumettre au mainteneur. C'est la plus fidèle à la source (p. 171), et elle garde une procédure de décision sans p-value. Mais, d'après (M7) :
  - **(i)** Sous (1.3), λ₂ ne bouge pas. P(k̂ = 2 | H₀) reste à 0,060 (α = 0,10), au-dessus de α/2 : le verdict actuel « ECHEC si k̂ = 2 » dépasserait le taux d'ECHEC des autres lignes. Il faudrait donc aussi revoir la correspondance entre k̂ et les verdicts, décision qu'aucune source ne fonde.
  - **(ii)** La calibration n'est exacte qu'à π̂ constant, où z est une fonction affine de ln r, i.i.d. normal, avec la même réserve de conditionnement au régime que pour DW. À π̂ variable, z = Pε n'est pas i.i.d. ; C7.b donne 0,118 sur J2 avec les λ de (2.5). Il faudrait une règle par régime.
  - **(iii)** Ce serait une source d'aléa nouvelle (graine explicite, cache par (T, k, α), métadonnée), sur le modèle de `sw_loi_nulle()`. Elle touche la liste des graines de `CLAUDE.md` et `res$metadata`, hors du périmètre de Fh, et demanderait un retour vers `architect`.
  - **(iv)** Le gain de puissance sur Grubbs n'est pas mesuré. Je ne la recommande pas sans une mesure préalable de puissance contre deux valeurs aberrantes, qui relèverait d'une issue séparée.

**7.4 Verdicts, régénération, source.**
- Sous (a) : ESD **OK → INFO** sur les cinq cas (visa) ; patch chirurgical [H : accepté par le patcheur].
- La règle Q-Fc-10 ne s'applique plus à Rosner (1983) : aucune phrase « non relue » pour cette source.
- Elle s'applique encore à **Thompson (1935)**, cité par Rosner p. 172 selon #347 et non lu.
- La citation du NIST n'est plus nécessaire.

## 7 bis. #347 : fiches ESD (circuit 4, `docwriter` puis `actuary`, fin de branche) *(ajout du complément)*

**Rattachement : oui, à Fh**, conformément à la décision du mainteneur.
- La fiche lognormale `fiche:rosner-esd` est de toute façon réécrite par #304 (a) : rubriques `\Loi`, `\Pval`, `\Usage`.
- Les écarts 3 à 8 s'y appliquent au même passage.
- Aucun effet sur les résultats ; aucun commit `moteur:`.
- **Ordre** : après le commit `docs:` de #304, ou fusionné avec lui, selon `docs/latex/CONVENTIONS.md` : un commit `docs:` par issue (règle 9).

**Point à trancher (Q-D1-Fh-8).** Les écarts 3, 6 et 7 touchent aussi `mw:m4ros`, fiche Merz-Wüthrich que #300 (Fi) peut réécrire, voire retirer si Rosner sort de M4 (S-Fi-2 (c)).
- **Recommandation** : Fh n'applique à `mw:m4ros` aucune modification. Les parties Merz-Wüthrich des écarts 3, 6 et 7 suivent #300, avec les écarts 1 et 2.
- Cela évite deux réécritures parallèles de la même fiche (C3⁗, C6⁗).
- Conséquence de forme : la PR de Fh porte `Closes #347` pour les écarts 3 à 8 lognormaux. Un commentaire sur #300 reporte les parties Merz-Wüthrich des écarts 1, 2, 3, 6 et 7. À défaut, Fh porte `Refs #347` et c'est Fi qui ferme #347.
- **Alternative** : Fh fait aussi les retouches minimales de `mw:m4ros`, et la seconde branche fusionnée résout le conflit (C6⁗).

**Critères d'acceptation.** Lignes de `f1689cc`. Chaque citation porte sa page.

- **É3 (`\Hzero`, l. 11386-11388).**
  - Formulation : H_l = « l valeurs aberrantes détectées et retirées » (p. 166) ; tous les R_i sont calculés, k̂ = max{i : R_i > λ_i} (éq. (1.2)).
  - La formule « on teste séquentiellement les alternatives » disparaît de `fiche:rosner-esd` (contrôle par `grep`).
  - L'exemple de la p. 171 n'est cité avec ses λ (table 5) qu'**après vérification sur la source**, en raison de la discordance de 0,002 relevée plus haut.
- **É4 (l. 11400-11405, 11429-11436, 5935).**
  - L'exactitude de l'étape 1 est attribuée à **la démonstration du document** (C7), et non à Rosner, qui présente λ₁ comme une approximation de Bonferroni (éq. (2.3)).
  - Thompson (1935, *Ann. Math. Statist.* 6, 214-219) est cité comme « référence donnée par Rosner (1983, p. 172) pour la loi d'un écart studentisé », avec la phrase datée « non relue sur le texte intégral » (Q-Fc-10).
- **É5 (l. 11380-11381).**
  - k = max(1, ⌊T/4⌋) est présenté comme un choix du projet.
  - Ajouts : Rosner laisse k à l'utilisateur (p. 165) et simule jusqu'à min([n/2], 10) (p. 166), soit k = 4 à T = 8.
  - Ajout : à n = 10, le niveau croît avec k, de 0,06 à 0,13 (table 1, α = 0,05, 2 000 itérations, erreur Monte-Carlo ≈ 0,005).
- **É6 (`\Usage`, l. 11411).**
  - « résout le problème de masquage » et « constitue la référence » sont remplacés par « atténue le masquage d'un test à une valeur aberrante (exemple de Rosner, 1983, p. 171) ».
  - Ajout : l'avantage revendiqué par l'auteur est le contrôle du niveau sous H_l.
- **É7 (`mw:m4ros`, l. 15164).** Selon Q-D1-Fh-8 : suit #300 (recommandé), ou correction « max(1, ⌊n/4⌋) » dans Fh.
- **É8 (l. 11413, 7523, 17636).**
  - « T ≥ 25 » est appuyé par les trois passages : résumé p. 165, p. 167, p. 171.
  - Nuance de la table 1 : 0,06 à n = 25 et 30 pour α = 0,05. « Adéquat » ne veut pas dire « exact ».
  - Le seul chiffre à T = 8 reste C7, constat de simulation versionné.
- **Concordance** : la concordance `--strict` relève 0 écart.
- **Validation par `actuary`** : confrontation de chaque page citée à la source. Cela exige l'accès à l'article (voir plus haut).

## 8. Transverse

**8.1 Frontière avec Fk (#297).** Lignes à verdict après Fh (T = 8, hors bascules R1, R3 et R14 selon les données) :
- **H1** : constante, TOST, Pitman, RESET, Spearman ratio / volume, Mann-Kendall (Cox-Stuart reste inopérant par R1) ;
- **H2** : Breusch-Pagan Koenker seule (aucune sous (B) quand π_env < π*) : le minP de la famille H2 est alors trivial ;
- **H3** : Shapiro-Wilk, Shapiro-Francia, Anderson-Darling, Lilliefors, Jarque-Bera, D'Agostino (Anscombe-Glynn à T ≥ 20 et π̂ constant) ;
- **H4** : DW, LB2, suites (z) ; DWr, Runsr à π̂ variable ;
- **F** : sup-F, OLS-CUSUM, Grubbs ; supFr, CUSUMr, Grubbsr à π̂ variable.

#297 travaille sur cet état et sur `type == "test"`. Aucune règle de lecture conjointe n'est fixée dans Fh.

**8.2 Décompte prévisionnel des tableaux 1 et 2** (à recompter par `docwriter` sur l'état final).

`tab:nature` :
- 2 lignes retirées (Box-Pierce ; Ljung-Box (1) sur ratios bruts) ;
- « Ljung-Box (1, 2) » devient « Ljung-Box (2) » ;
- « Shapiro-Wilk » sans la loi nulle simulée ;
- environ 15 lignes à « Voie retenue » modifiée : BP 1979, White, GQ, BF, Smirnov, Spearman (dédoublé : volume test, temps diagnostic), CvM, KS, Rosner, et les cinq lignes sur ratios bruts « diagnostic à π̂ constant, Monte-Carlo sinon » ;
- Anscombe-Glynn « non applicable à π̂ variable » ; BP Koenker, mention de π_env ;
- paragraphe « les 33 p-values retenues de Monte-Carlo » de `premium_interieur` : **22** [V par décompte sur (M1) : 33 − 11].

`tab:conv` : « Ljung-Box, Box-Pierce » devient « Ljung-Box (retard 2) » ; les autres lignes restent (p toujours calculées). π_env n'est pas une p-value : sa place est `tab:tracabilite-puissance`.

`tab:pmin` : Smirnov, Spearman ratio-temps et Runsr (à π̂ constant) gardent leur p_min, mais la règle R1 ne s'y applique plus.

Décomptes datés « 51 lignes » : 47 à T = 8.

**8.3 C3⁗ incomplet [V].** `mw_tests()` appelle aussi `lillie_p()`, `runs_p_min()` et `sw_p_loi_nulle()` (donc `sw_loi_nulle()`), absentes de la liste des six fonctions communes (elle a été tirée des champs `fonction`). Fh ne les modifie pas. À ajouter à la liste par `architect`, dans l'annotation de l'ADR 0007.

## 9. Effets attendus par cas de référence et régénérations

| Issue | Quatre cas à δ̂ = 1 | `premium_interieur` | Mode | Visa |
|---|---|---|---|---|
| #339 | — | — | aucun | non |
| #327 | `detail` inchangé | idem | `--seuil 0`, aucun écart | non |
| #303 | 5 × OK → INFO ; LB1r retirée | LB1r retirée | régénération CI | **oui** |
| #302 | 3 lignes retirées ; KS, CvM OK → INFO | 3 retirées ; KS, CvM OK → INFO ; phrases H3 | régénération CI | **oui** |
| #299 (A) | BP79, White ALERTE → INFO ; GQ, BF, Smirnov, Spearman-temps OK → INFO ; BP ECHEC + phrase | GQ ECHEC → INFO ; 5 × OK → INFO ; BP OK + phrase | régénération CI | **oui** |
| #304 (a) | ESD OK → INFO | idem | patch chirurgical | **oui** |

- Lignes : 51 → 47.
- Lignes à verdict : 36 → 18 sur les cas à δ̂ = 1, 36 → 24 sur `premium_interieur` (sous (A)).
- Entrées de `USP_CATALOGUE_MC` : 34 → 31 (`LB1r`, `BP2`, `LB1`), aucune discrète.
- σ_USP inchangé partout.
- `reserve2` non touché.
- Une régénération à la fois, partagée avec Fi (C4⁗).

## 10. Surface documentaire (passage unique de `docwriter`)

Fiches :
- `fiche:durbin-watson-ratios-bruts`, `fiche:suites-ratios-bruts`, `fiche:sup-f-ratios-bruts`, `fiche:ols-cusum-ratios-bruts`, `fiche:grubbs-ratios-bruts` (règle R15) ; `fiche:ljung-box-ratios-bruts` (retrait) ;
- `fiche:shapiro-wilk-sans-royston` (retrait, contenu porté en note de validation dans `fiche:shapiro-wilk`) ; `fiche:ljung-box` (LB1 et Box-Pierce retirés) ; `fiche:kolmogorov-smirnov`, `fiche:cramer-von-mises` ; fiches de H3 (phrase à π̂ variable ; Anscombe-Glynn) ;
- `fiche:breusch-pagan-koenker` (π_env ; ECHEC de `premium` à documenter, bloc 2 § 4.11) ; `fiche:breusch-pagan-1979` (la « règle de lecture » ne vaut pas sous p Monte-Carlo) ; `fiche:white`, `fiche:goldfeld-quandt`, `fiche:brown-forsythe`, `fiche:smirnov`, `fiche:spearman` (volet temps) ;
- `fiche:rosner-esd` (C7 versionné ; #304 et #347, écarts 3 à 6 et 8 ; Thompson (1935) daté, Q-Fc-10) ; `mw:m4ros` : selon Q-D1-Fh-8 ; lignes 5935, 7523, 11378-11451 et 17636 *(modifié par le complément)* ;
- `fiche:jackknife` (#327, avec les deux phrases `Refs #329` / `Refs #328` du plan, ajustées à l'état final de R18b) ;
- index l. 688 (`dw_puissance_ar1()`, domaine) et fonction nouvelle de #299 (A).

Sections et tableaux :
- `sec:t8` et l'encadré H2 : le LR sur δ et π_env portent l'argumentation H2 (#299, point 5) ;
- tableaux du § 8.2 ; décomptes datés.

Hors du `.tex` : `CONTEXT.md`, par `architect` :
- « Diagnostic » : R15, R16 éventuelle, diagnostics par décision de #302, #299 et #304 ;
- « Verdict » : l'ESD lognormale n'est plus une procédure de décision, la ligne Merz-Wüthrich l'est encore jusqu'à #300 ;
- « Ligne non applicable » : 47 lignes ; motif d'Anscombe-Glynn ;
- jackknife l. 170 : #327, #328 ;
- formule « influence égale à la précision numérique », distincte d'« Ex æquo ».

Scripts de mesures du § 0 (hors dépôt, non versionnés) : à verser au dépôt seulement si le mainteneur veut citer (M3) à (M5) au dossier.

## 11. Questions au mainteneur (Q-D1-Fh)

- **Q-D1-Fh-1 (#339)** : option 1, garde ρ ≥ −1 + 1e-6. *Recommandation* : oui (1e-7 ne laisse qu'une demi-décade sur une erreur mesurée).
- **Q-D1-Fh-2 (#327)** : (a) τ = 2 · `REP_SIGMA_KKT` · (2 + Δ(1) + Δ(2)), ou constante 1e-5 ; (b) liste des années à influence égale, ou « non déterminée » ; (c) test du chemin réel sur le jeu construit du § 3.4. *Recommandation* : τ par formule, liste, test.
- **Q-D1-Fh-3 (#303)** : drapeau `pi_constant` ; cinq lignes en diagnostic par règle (R15) ; retrait de LB1r ; visa de 5 × OK → INFO sur quatre cas. *Recommandation* : oui.
- **Q-D1-Fh-4 (#302)** : sort des lignes (tableau du § 5.1) ; phrase H3 à π̂ variable ; Anscombe-Glynn non applicable à π̂ variable ; lecture conjointe renvoyée à #297. *Recommandation* : selon le tableau, oui, oui, oui.
- **Q-D1-Fh-5 (#299)** : (A) phrase π_env sans bascule, ou (B) bascule à π* (valeur : 2α ou 0,5) ; BP79, White, GQ, BF, Smirnov, Spearman ratio-temps en diagnostics ; visa. *Recommandation* : **(A)**. Sous (B), l'ECHEC de BP Koenker sur `premium` (p Monte-Carlo 0,018, calibrée) devient INFO.
- **Q-D1-Fh-6 (#304, révisée par le complément)** : (a), (b) ou (c). *Recommandation* : **(a)**. (c) exige trois décisions supplémentaires : la correspondance k̂ → verdicts, la règle par régime de π̂, et une source d'aléa nouvelle, hors du périmètre de Fh. Elle n'est à envisager qu'après une mesure de puissance contre deux valeurs aberrantes.
- **Q-D1-Fh-7 (vocabulaire, `architect`)** : pas de terme « variante sans verdict » ; numéros R15 (et R16) ; formule du § 3.3 ; liste C3⁗ complétée (§ 8.3).
- **Q-D1-Fh-8 (#347, ajoutée par le complément)** : parties `mw:m4ros` des écarts 3, 6 et 7, et forme `Closes` ou `Refs #347` dans Fh. *Recommandation* : elles suivent #300 ; `Closes #347` dans Fh, avec un commentaire de report sur #300.
- **Acte** : fournir l'article dans la session pour la validation de fin de branche.

## 12. Hors périmètre

- `add()`, `engine_registre_tests()`, `usp_regime()`, `usp_bootstrap()`.
- Champs `variante` ; `test_rosner()` ; fonctions partagées avec Merz-Wüthrich.
- Lecture conjointe (#297) ; affichage (#306, #305) ; #331.
- Seuils de crédibilité ; σ_USP.

## 13. Références

- B. Rosner, « Percentage Points for a Generalized ESD Many-Outlier Procedure », *Technometrics* 25(2), 1983, 165-172 : **lu en texte intégral par la session de recherche documentaire du 19/10/2026 (#347)** ; non relu par l'auteur de la spécification, accès refusé (403). Notice et résumé consultés auparavant par sources secondaires ([résumé reproduit](https://synapsesocial.com/papers/W1969456163), [PixInsight](https://pixinsight.com/developer/pcl/doc/html/classpcl_1_1GeneralizedESDRejection.html), [VSP/PNNL](https://vsp.pnnl.gov/help/Vsample/Rosners_Outlier_Test.htm)) ; la notice NIST est retirée *(modifié par le complément)*.
- W. R. Thompson (1935), *Ann. Math. Statist.* 6, 214-219 : référence relayée par #347 (Rosner, 1983, p. 172), pour la loi d'un écart studentisé ; non lue (Q-Fc-10) *(ajout du complément)*.
- E. L. Lehmann, J. P. Romano, *Testing Statistical Hypotheses*, 3e éd., Springer, 2005, ch. 6 « Invariance », § 6.3 « Most Powerful Invariant Tests » : table des matières seule ([notice](https://campusstore.miamioh.edu/testing-statistical-hypotheses-3rd-lehmann/bk/9780387988641)) ; contenu non relu. Le résultat employé est dérivé au § 6.2 et contrôlé par Monte-Carlo.
- J. M. Hoenig, D. M. Heisey (2001) : déjà cité ; résumé lu par la revue du 15/10 ; non relu ici (Q-Fc-10).
- Mesures du dépôt : `docs/tableaux/20261018-issue174-esd.md` (C7) ; revue du 15/10, blocs 2 à 4 (chiffres repris, non remesurés, sauf (M1) et (M6)).
- Aucune autre référence. Les autres résultats invoqués sont algébriques (§ 3.2, 3.4, 6.2, 7) ou mesurés (§ 0).

---

## Retour

- **Statut** : `partiel`. D1-Fh est complète sur les six numéros initiaux. Pour #304 et #347, les relevés de l'article n'ont pas été contrôlés sur la source : l'accès au PDF est refusé par le proxy.

- **Résultat** :
  - #304 : option **(a)** maintenue, phrase du `detail` modifiée.
  - (b) déconseillée ; correction de l'issue sur la règle R1.
  - (c) analysée et non recommandée en l'état : P(k̂ = 2 | H₀) reste à 0,060 sous (1.3) à T = 8, la calibration n'est exacte qu'à π̂ constant, et la variante introduit une source d'aléa nouvelle.
  - #347 intégrée (§ 7 bis), avec les critères É3 à É8 et une recommandation sur `mw:m4ros`.

- **Preuves.**
  - *Vérifiées* :
    - code de `test_rosner()` conforme à l'éq. (2.5) et à la règle (1.2) telles que #347 les transcrit ;
    - λ à T = 8 et cas limite n = 25 ;
    - arithmétique des rapports et de l'erreur Monte-Carlo de la table 1 ;
    - (M7).
  - *Hypothèses* :
    - interpolation comme cause de la discordance de la table 5 ;
    - acceptation du patch de #304 par le patcheur.
  - *Non vérifiés* : toutes les citations et pages de l'article ; Thompson (1935).

- **Informations manquantes** : texte de l'article (accès refusé, `CONNECT tunnel failed, response 403`).

- **Décisions non résolues** :
  - mainteneur : Q-D1-Fh-6 (a, b ou c) et Q-D1-Fh-8 ;
  - mainteneur et `architect` : forme `Closes` / `Refs #347`.

- **Critères déclenchés** :
  - deux lectures d'une source (valeurs de la table 5 contre l'éq. (2.5)) : problème de documentation disponible ;
  - changement de résultat (verdict ESD) ;
  - validité à T = 8 qu'aucune source ne tranche : niveau et puissance de l'ESD reposent sur la seule simulation (C7, M7) ;
  - désaccord avec le texte de #304 (règle R1).

- **Prochaine action recommandée** : soumettre Q-D1-Fh-6 et Q-D1-Fh-8 au mainteneur, puis versionner D1-Fh avec ce complément. Le mainteneur fournit la copie de Rosner (1983) avant la validation de fin de branche.

### Retour de la consultation initiale (remplacé par le bloc ci-dessus, conservé pour la traçabilité)

- **Statut** : `complet`. Chaque question a un avis justifié et des critères d'acceptation. Les mesures prévues ont été exécutées. Les hypothèses sont listées ci-dessous.

- **Résultat** :
  - **#339** : option 1, garde 1e-6.
  - **#327** : tolérance numérique ancrée sur `REP_SIGMA_KKT`, années à influence égale listées ; chemin réel de #329 **atteignable** sur un jeu construit.
  - **#303** : `pi_constant`, cinq lignes en diagnostic (R15), retrait de LB1r.
  - **#302** : retrait de SW à loi nulle simulée, BP2 et LB1 ; KS et CvM en diagnostic ; phrase H3 à π̂ variable ; Anscombe-Glynn non applicable à π̂ variable (constat nouveau) ; lecture conjointe renvoyée à #297.
  - **#299** : quatre lignes H2, Smirnov et Spearman ratio-temps en diagnostic ; BP Koenker seule ligne H2 à verdict, avec une puissance enveloppe exacte (J1 0,127, J2 0,343), option (A) sans bascule recommandée ; seuil dans `usp_tests()`, donc #331 reste en Fk.
  - **#304** : option (a).

- **Preuves.**
  - *Vérifiées* :
    - lecture du code et des issues listés au § 0 ;
    - (M1) à (M6), dont l'accord Imhof / Monte-Carlo de (M5) ;
    - C7 versionné ;
    - notices de Rosner (1983) et de Lehmann et Romano (2005) au niveau du résumé ou de la table des matières.
  - *Hypothèses* :
    - égalité des puissances de LB1r et DWr sur u à π̂ variable ;
    - plan à deux niveaux le plus favorable pour un R_x donné ;
    - invariance des tests H2 du moteur hors de la limite des faibles CV ;
    - stabilité entre plateformes du jeu de #329 et de τ ;
    - acceptation du patch de #304 par le patcheur ;
    - indépendance des autres statistiques vis-à-vis de la liste du catalogue (à montrer par `comparer_references.R`).
  - *Non vérifiés* : textes intégraux de Rosner (1983) et de Lehmann et Romano (2005) ; chiffres de la revue repris sans remesure (puissances de #229 et #116, corrélations du bloc 3).

- **Informations manquantes** : Rosner (1983) en texte intégral (règle Q-Fc-10 appliquée). Mesures hors dépôt, non versionnées.

- **Décisions non résolues** (mainteneur) : Q-D1-Fh-1 à Q-D1-Fh-6, en particulier l'option (A) ou (B) de #299 et le sort de KS et CvM. Pour `architect` : Q-D1-Fh-7 et C3⁗.

- **Critères déclenchés** (§ 4) :
  - **changement de résultat** : verdicts de #303, #302, #299 et #304, σ_USP inchangé ;
  - **désaccords avec les textes des issues et du plan** :
    - #304 : la règle R1 ne rendrait pas la ligne inopérante à k̂ = 1 ;
    - #299 : je recommande de **ne pas** basculer l'ECHEC de BP Koenker ;
    - C3⁗ : liste incomplète ;
  - **validité à T = 8** : le niveau de l'ESD et les puissances de H2 ne reposent que sur des simulations et sur le calcul enveloppe ; aucune source ne les tranche.
  - Aucun désaccord avec `audit` ni avec un ADR.

- **Prochaine action recommandée** : la session principale soumet Q-D1-Fh-1 à Q-D1-Fh-7 au mainteneur, puis versionne ce texte au premier commit de Fh. `architect` complète C3⁗ dans l'annotation de l'ADR 0007 avant la création de la branche.
